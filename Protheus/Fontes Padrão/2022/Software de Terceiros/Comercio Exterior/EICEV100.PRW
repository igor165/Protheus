#Include "RwMake.ch"
#Include "Average.ch"
#Include "EICEV100.ch"

//Sistema......: EIC - Easy Import Control
//Empresa......: Average Tecnologia
//Programa.....: EICEV100.PRW
//Autor........: Jaílton Santos --> Adaptado por: Gustavo Carreiro (GFC)
//Adaptado para o Padrao: Daniel Rodrigo de Lima (DRL)
//Data.........: 14/09/09
*=================*
Function EICEV100()
*=================*
Private	aRotina:= MenuDef()
//**IGOR CHIBA 29/09/09 verificando se integra dados parar ERP financeiro
Private	LCAMBIO_EIC	:=  AVFLAGS('AVINT_CAMBIO_EIC')
Private	cCADASTRO:=	STR0001 //"Manutenção de Invoices Antecipadas"
Private	cFileHelp,	cNomArq1,	lInverte:=.F.,	cMarca:=GetMark()
IF LCAMBIO_EIC

   Private  cEICFI07 := EasyGParam('MV_EICFI07',,'') //define codigo da integração de INVOICE ANTECIPADA
   Private lEICFI07  := .F.

   E00->(DBSETORDER(1))
   IF E00->(DBSEEK(XFILIAL('E00')+AVKEY(cEICFI07,'E00_COD') ))  .AND. E00->E00_SITUAC='1'//esta ativo  INVOICE ANTECIPADA
      lEICFI07:=.T.
      AAdd(aRotina, {STR0050, "EV100EnvIN", 0, 07}) //Enviar Inclusão //igor chiba
      AAdd(aRotina, {STR0051, "EV100EnvEX", 0, 08}) //Enviar Estorno  //igor chiba
   ENDIF

ENDIF
//**

//ACB - 07/04/2010 - PONTO DE ENTRADA PARA CRIAÇÃO DE BOTOES NO MENU
If EasyEntryPoint("EICEV100")
   ExecBlock("EICEV100",.F.,.F.,"CRIA_BOTAO")
Endif

//
If	!EV100CRIAWORKS()        // Funcao para criacao de works
	HELP(" ",1,"AVG0000029") // "Nao foi possivel abrir o arquivo temporario"
	dbSelectArea("SX3")
	Return .T.
EndIf
//ACB - 07/04/2010 - PONTO DE ENTRADA PARA AJUSTE NO BROWSE DA ROTINA
If EasyEntryPoint("EICEV100")
   Execblock("EICEV100",.F.,.F.,"AJUSTA_BROWSE")
Endif

dbSelectArea("EW4")
mBrowse(,,,,"EW4")
WORK->(E_EraseArq(cNomArq1))
WORK_HLP->(E_EraseArq(cFileHelp))
//
SA5->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SW1->(dbSetOrder(1))
SW2->(dbSetOrder(1))
SW3->(dbSetOrder(1))
SW5->(dbSetOrder(1))
SW7->(dbSetOrder(1))
SW8->(dbSetOrder(1))
EW5->(dbSetOrder(1))
Return .T.

*===================================*
Function EV100MANUT(cAlias,nReg,nOpc)
*===================================*
LOCAL cTitulo       :=  cCadastro,nOpca:=0,aButtons:=NIL
LOCAL bOk           :=  {|| nOpca:=1,EV100FobTot(),If(nOpc<>2,If(Obrigatorio(aGets,aTela),oDlgmanut:End(),nOpca := 0),oDlgmanut:End())}
LOCAL bCancel       :=  {|| nOpca:=0,oDlgmanut:End()}
LOCAL TB_CAMPOS     :=  {}, I
LOCAL	nxInd       :=  0
LOCAL cSQLChv       :=  ""
Local oMsSelect, oGet
Local lIntegEAI     := AvFlags("EIC_EAI", .F., .F.)
Private cPictProd   :=  AVSX3("W3_COD_I",6)
Private cPictQtde	:=  AVSX3("W3_QTDE",6)
Private nLenProduto :=  AVSX3("B1_VM_I",3)
Private cPicTotPO   :=  AVSX3("W2_FOB_TOT",6)
Private aGets       :=  {},aTela:={},oDlgmanut, lAlterando
Private cObs        :=  ''
Private cForLoj     :=  ''
cFilSB1:=xFilial("SB1")
cFilSW2:=xFilial("SW2")
cFilSW3:=xFilial("SW3")
cFilSW5:=xFilial("SW5")
cFilSW7:=xFilial("SW7")
cFilSA5:=xFilial("SA5")
cFilEW4:=xFilial("EW4")
cFilEW5:=xFilial("EW5")
cFilSY8:=xFilial("SY8")

//LRS - 15/03/2016 - Essa mesma work é utilizada no relatório com estrutura diferente usado nas opções de alteração da invoice antecipada
If Select("WORK") # 0
	WORK->(E_EraseArq(cNomArq1))
	WORK_HLP->(E_EraseArq(cFileHelp))

	If	!EV100CRIAWORKS()        // Funcao para criacao de works
		HELP(" ",1,"AVG0000029") // "Nao foi possivel abrir o arquivo temporario"
		dbSelectArea("SX3")
	EndIf
ENDIF

//**igor chiba 10/06/2010
IF LCAMBIO_EIC .AND. lEICFI07
   Private cMsgCtr :=""  //usada pelo avinteg
   IF !EMPTY(EW4->EW4_CTRERP) .OR. !EMPTY(EW4->EW4_TITERP) //so nao vai validar se os dois tiverem vazio
      IF nOpc == 4 //alteracao
         IF !EMPTY(EW4->EW4_CTRERP)
            MSGINFO(STR0003, STR0002) //'Invoice Antecipada não pode ser alterada, aguardando retorno.', Atenção
            RETURN .T.
         ENDIF
      ELSEIF nOpc == 5 //exclusao
         MSGINFO(STR0004, STR0002) //'Invoice Antecipada não pode ser excluida.', Atenção
         RETURN .T.
      ENDIF
   ENDIF
ENDIF
// fim igor**
//
If nOpc==3 .OR.	nOpc==4
	AADD(TB_CAMPOS,{"WKFLAG",,,})
EndIf
AADD(TB_CAMPOS,{"WKPO_NUM"										,,AvSx3("W8_PO_NUM",5)})
AADD(TB_CAMPOS,{"WKCC"											,,AvSx3("W8_CC",5)})
AADD(TB_CAMPOS,{"WKSI_NUM"										,,AvSx3("W8_SI_NUM",5)})
AADD(TB_CAMPOS,{"WKCOD_I"										,,AvSx3("W8_COD_I",5)})
AADD(TB_CAMPOS,{"WKFABR"										,,AvSx3("W8_FABR",5)})
IF EICLoja()
   AADD(TB_CAMPOS,{"WKFABLOJ"										,,AvSx3("W8_FABLOJ",5)})
EndIf

If lIntegEAI
   AAdd(TB_CAMPOS, {{|| TRAN(WORK->WKQTDE, cPictQtde)}   ,, AvSx3("W3_QTDE", AV_TITULO)})
   AAdd(TB_CAMPOS, {"WKUNIDAD"					            ,, AvSx3("W3_UM", AV_TITULO)})
   AAdd(TB_CAMPOS, {{|| TRAN(WORK->WKQTSEGUM, cPictQtde)},, AvSx3("W3_QTSEGUM", AV_TITULO)})
   AAdd(TB_CAMPOS, {"WKSEGUM"                            ,, AvSx3("W3_SEGUM", AV_TITULO)})
Else
   AADD(TB_CAMPOS,{"WKUNIDAD"								        ,,AvSx3("W8_UNID",5)})
   AADD(TB_CAMPOS,{{|| TRAN(WORK->WKQTDE,cPictQtde )}				,,AvSx3("W8_QTDE",5)})
EndIf

AADD(TB_CAMPOS,{{|| TRAN(WORK->WKPRECO,cPicTotPO)}				,,AvSx3("W8_PRECO",5)})
AADD(TB_CAMPOS,{{|| TRAN(WORK->WKTOTAL,'@E 999,999,999,999.99')},,"Preco Total"})
AADD(TB_CAMPOS,{"WKPOSICAO"										,,AvSx3("W8_POSICAO",5)})
AADD(TB_CAMPOS,{{|| TRAN(WORK->WKPESOL,AvSX3("EW5_PESOL",6) )}	,,AvSx3("W7_PESO",5)})
AADD(TB_CAMPOS,{{|| TRAN(WORK->WKPESOB,AvSX3("EW5_PESOB",6) )}	,,AvSx3("B1_PESBRU",5)})

If AvFlags("RATEIO_DESP_PO_PLI")
   AADD(TB_CAMPOS,{{|| TRAN(WORK->WKFRETE,AvSX3("EW5_FRETE",6) )}	,,AvSx3("EW5_FRETE",5)})
   AADD(TB_CAMPOS,{{|| TRAN(WORK->WKSEGUR,AvSX3("EW5_SEGURO",6) )}	,,AvSx3("EW5_SEGURO",5)})
   AADD(TB_CAMPOS,{{|| TRAN(WORK->WKINLAN,AvSX3("EW5_INLAND",6) )}	,,AvSx3("EW5_INLAND",5)})
   AADD(TB_CAMPOS,{{|| TRAN(WORK->WKDESCO,AvSX3("EW5_DESCON",6) )}	,,AvSx3("EW5_DESCON",5)})
   AADD(TB_CAMPOS,{{|| TRAN(WORK->WKPACKI,AvSX3("EW5_PACKIN",6) )}	,,AvSx3("EW5_PACKIN",5)})
EndIf

aButtons:={}
//--- ADC Somente permite botões de manutenção, se a Invoice não participar de algum processo de embarque...
If	nOpc == 3 .Or. (nOpc == 4 .And. Empty(EW4->EW4_HAWB)) //DRL 03/03/10 - Ajustado para aparecer sempre na Inclusao
	AADD(aButtons,{"NOVACELULA",{|| EV100GetPO(), WORK->(dbSetOrder(2)), oMSSelect:oBrowse:Refresh()}, STR0005}) //"Novo P.O."
	AADD(aButtons,{"RESPONSA"  ,{|| Processa({|| EV100MarkAll() }), oMSSelect:oBrowse:Refresh()}     , STR0006}) //"Marca/Desmarca Todos"
EndIf
// MFR 17/05/2017 TE-5740 MTRADE-1011
AADD(aButtons,{"RESPONSA"  ,{|| EV100FobTt(), WORK->(dbSetOrder(2)), oMSSelect:oBrowse:Refresh()}, STR0053}) //"Calcula despesas"
AADD(aButtons,{"PESQUISA"  ,{|| If(EV100GetItem(), SetFocus(oMSSelect:oBrowse:hWnd),)}               , STR0007}) //"Pesquisar Item"
bMarca:={|| EV100MARCA(), oMSSelect:oBrowse:Refresh()}
//
If nOpc==2 .OR. nOpc==5//VISUAL OU EXCLUIR
	bOk:={||nOpca:=1,,oDlgmanut:End()}
	aButtons:=NIL
	bMarca:={|| .T. }
EndIf
//
M->EW5_PO_NUM:=Space(Len(SW2->W2_PO_NUM))
cIncor:=cMoeda:=cForn:=cCond:=''
WORK->(avzap())
lAlterando := .f.
If nOpc==3 //Incluir
	If !EV100GetPO()
		Return nOpc
	EndIf
Else
    lAlterando := .T.    // Esta var auxilia no controle de quantidade quando For
						 // Alteração, onde eu tenho que considerar o valor gravado
						 // Como parte da qtde disponivel.
	Processa({|| EV100GrvWork(.F.) })
	lItemEmb:=.F.
	cPO:=''
	WORK->(dbGoTop())
	WORK->(DBEVAL({|| lItemEmb:=.T.,cPO:=WORK->WKPO_NUM},{|| WORK->WKFASE_GI },{|| !lItemEmb}))
	If lItemEmb .AND. nOpc # 2
		MsgInfo(StrTran(STR0008, "####", AllTrim(cPO)), STR0002)//"O pedido #### possui item(ns) embarcado(s) ou em fase de preparação da licença de importação (P.L.I.). A invoice não pode ser alterada/ estornada.", "Atenção"
		Return nOpc
	EndIf
	WORK->(dbGoTop())
EndIf
WORK->(dbGoTop())
//
If WORK->(EOF()) .AND. WORK->(BOF())
	If nOpc<>3
		MsgInfo(STR0009, STR0002) //"A Invoice não possui itens.","Atenção"
	EndIf
EndIf
//
dbSelectArea("EW4")
For I := 1 TO EW4->(FCount())
	M->&(FieldName(i)) := If(nOpc#3,FieldGet(i),CriaVar(FieldName(i)))
Next
//
WORK->(dbGoTop())
SW2->(dbSetOrder(1))
If SW2->(dbSeek(xFilial("SW2")+WORK->WKPO_NUM))
	M->EW4_AGENTE:= iIf(Empty(M->EW4_AGENTE),SW2->W2_AGENTE, M->EW4_AGENTE)
	M->EW4_MOEDA := cMoeda := SW2->W2_MOEDA
	M->EW4_FORN  := cForn  := SW2->W2_FORN
	IF EICLoja()
	   M->EW4_FORLOJ := cForLoj := SW2->W2_FORLOJ
	EndIf
EndIf

If nOpc == INCLUIR
   M->EW4_INCOTER := SW2->W2_INCOTER
   If AvFlags("RATEIO_DESP_PO_PLI")
      M->EW4_FREINC := SW2->W2_FREINC
      M->EW4_SEGINC := SW2->W2_SEGINC
      M->EW4_RATPOR := If(Empty(SW2->W2_RAT_POR),"2",SW2->W2_RAT_POR)
   EndIf
EndIf

If !EMPTY(EW4->EW4_CODOBS)
	cOBS := MSMM(EW4->EW4_CODOBS,AVSX3("EW4_OBS",03))
EndIf
While .T.
	EV100FobTot()
	WORK->(dbSetOrder(2))
	WORK->(dbGoTop())
	nOpca:=0
	aGets:={}
	aTela:={}
	//
 //**igor chiba 29/09/09 recebendo dados para verificar posteriormente se algo foi modificado
   IF LCAMBIO_EIC
      IF nOpc == 4
         nTotInv:= EW4->EW4_TOTINV
         cCondP := EW4->EW4_COND_P
      ENDIF
   ENDIF
   //FIM igor**
	oMainWnd:ReadClientCoors()
	Define MsDialog oDlgmanut	Title cTitulo;
										From oMainWnd:nTop+125,oMainWnd:nLeft+5;
										TO oMainWnd:nBottom-60,oMainWnd:nRight - 10;
										OF oMainWnd PIXEL

	   nMeio:=INT( ((oMainWnd:nBottom-60)-(oMainWnd:nTop+125) ) / 4 ) + 1

	   //Enchoice("EW4",nReg,nOpc,,,,,{15,1,nMeio-1,(oDlgmanut:nClientWidth-4)/2 })
	   oGet:= MsMGet():New("EW4",nReg,nOpc,,,,,{15,1,nMeio-1,(oDlgmanut:nClientWidth-4)/2 })

	   //GFP 20/10/2010
	   TB_CAMPOS := AddCpoUser(TB_CAMPOS,"SW8","2")

	   oMsSelect:= MsSelect():New("WORK", If(nOpc == 3 .Or. nOpc == 4, "WKFLAG",),, TB_CAMPOS, @lInverte, @cMarca,{nMeio,1,(oDlgmanut:nClientHeight-6)/2,(oDlgmanut:nClientWidth-6)/2})

	   oMSSelect:oBrowse:bWhen:={|| dbSelectArea("WORK"),.T.}
	   oMSSelect:bAval:=bMarca

	   oMSSelect:oBrowse:Align:= CONTROL_ALIGN_BOTTOM
	   oGet:oBox:Align:= CONTROL_ALIGN_ALLCLIENT
	   oDlgmanut:lMaximized := .T.

	Activate MsDialog oDlgmanut On Init Enchoicebar(oDlgmanut,bOk,bCancel,,aButtons)
	//
	WORK->(dbSetOrder(1))
	If nOpca==1
		If nOpc==3 .OR. nOpc==4	//Incluir  ou Alterar
			lItemOK:=.F.
			WORK->(dbGoTop())
			WORK->(DBEVAL({||lItemOK:=.T.},{|| !EMPTY(WORK->WKFLAG) },{|| !lItemOK  } ))
			WORK->(dbGoTop())
			If !lItemOK
				MsgInfo(STR0010, STR0002)//"Não há itens selecionados.","Atenção"
				Loop
			EndIf

			If (AvRetInco(M->EW4_INCOTE,"CONTEM_FRETE") .And. M->EW4_FREINC == "2" .And. Empty(M->EW4_FRETEI)) .Or. (AvRetInco(M->EW4_INCOTE,"CONTEM_SEGURO") .And. M->EW4_SEGINC == "2" .And. Empty(M->EW4_SEGURO))
				EasyHelp(STR0057,STR0002)//"O Incoterm informado prevê o lançamento de Frete/Seguro e o valor da despesa não foi informado."
			EndIf

			//ACB - 07/04/2010 - Ponto de entrada que permite manutenção ANTES de gravação da tabela EW4
			If EasyEntryPoint("EICEV100")
			   Execblock("EICEV100",.F.,.F.,"ANTES_GRAVA_EW4")
			Endif

			EW4->(RECLOCK("EW4",Inclui))
			AVREPLACE("M","EW4")
			EW4->(MSUNLOCK())

            //**igor chiba  10/06/2010
			IF LCAMBIO_EIC  .AND. lEICFI07
			   IF nOpc == 4  //alteracao
			      cChave:=XFILIAL('EW4')+EW4->EW4_HAWB+EW4->EW4_INVOIC+EW4->EW4_FORN
			      cSQLChv:="EW4_FILIAL = '"+XFILIAL('EW4')  +"' AND "+;
			               "EW4_HAWB = '"  +EW4->EW4_HAWB   +"' AND "+;
			               "EW4_INVOIC = '"+EW4->EW4_INVOIC +"' AND "+;
			               "EW4_FORN = '"  +EW4->EW4_FORN   +"' "


                  IF EMPTY(EW4->EW4_CTRERP ) .AND. !EMPTY(EW4->EW4_TITERP)
                     IF  nTotInv <> EW4->EW4_TOTINV .OR. cCondP <> EW4->EW4_COND_P//se houve alteração
                         cMsgCtrl := "ENVIADO ALT"
								 If FindFunction("EICINTEI17")
								 	EasyExRdm("EICINTEI17", 'A','INVANT',cChave,"AB",cSQLChv)                         	
								 EndIf
                     ENDIF
                  ENDIF
                  nTotInv:=0
                  cCondP :=''
               ENDIF
            ENDIF
           //fim igor chiba**

            PROCESSA({|| EV100Grava() })

			//ACB - 07/04/2010 - Ponto de entrada que permite manutenção DEPOIS de gravação da tabela EW4
			If EasyEntryPoint("EICEV100")
			   Execblock("EICEV100",.F.,.F.,"DEPOIS_GRAVA_EW4")
			Endif

		EndIf
		If nOpc==5 //Excluir
			If		!Empty(EW4->EW4_HAWB)
				MsgStop(StrTran(STR0011, "####", AllTrim(EW4->EW4_HAWB))) //"A Invoice não pode ser excluída, pois ela pertence ao processo de embarque ####."
				Loop
			ElseIf	EW4->EW4_OK_SHP=="1"
				MsgStop(STR0012) //"A Invoice não pode ser excluída, pois seu embarque está autorizado!"
				Loop
			ElseIf	MSGYESNO(STR0013) //"Confirma exclusao?"
				PROCESSA({|| EV100EXCLUIR()})
				If !EMPTY(EW4->EW4_CODOBS)
					MSMM(EW4->EW4_CODOBS,,,,2) // exclui campo memo
				EndIf
				EW4->(RECLOCK("EW4",.F.))
				EW4->(DBDELETE())
				EW4->(MSUNLOCK())
			Else
				Loop
			EndIf
		EndIf
	EndIf
	Exit
EndDO
Return .T.

*==========================*
Static Function EV100GetPO()
*==========================*
LOCAL oDlggetpo
Local cTitulo:= STR0014 //"Seleção de P.O."
Local oPanel

M->EW5_PO_NUM:=SPACE(LEN(SW2->W2_PO_NUM))
nOpca:=0


Define MsDialog oDlggetpo Title cTitulo From 0,0 TO 10,55 OF oMainWnd

   oPanel:= TPanel():New(0, 0, "", oDlggetpo,, .F., .F.) //MCF - 16/07/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   @ 02,01 SAY STR0015 Of oPanel //"Pedido"
   @ 02,04 MsGet M->EW5_PO_NUM F3 "SW2" Picture "@!" SIZE 80,08 Of oPanel HASBUTTON

ACTIVATE MsDialog oDlggetpo ON INIT ;
						Enchoicebar(oDlggetpo,{|| If(EV100VALID("PO"),(nOpca:=1,oDlggetpo:End()),)},;
						{|| nOpca:=0,oDlggetpo:End() } ) CENTERED
If nOpca == 0
	Return .F.
EndIf
//
SW2->(dbSetOrder(1))
SW2->(dbSeek(cFilSW3+M->EW5_PO_NUM))
cMoeda:=SW2->W2_MOEDA
cForn :=SW2->W2_FORN

If EICLoja()
   cForLoj:= SW2->W2_FORLOJ
EndIf

lOK   :=.F.

PROCESSA({|| lOK:=EV100GrvWork(.T.) })

If !lOK
	Return .F.
EndIf

Return .T.

*==============================*
Static Function EV100CRIAWORKS()
*==============================*
Local lIntegEAI     := AvFlags("EIC_EAI", .F., .F.)
LOCAL   nPos:=0
LOCAL	aDBF_Stru:=	{	{"WKFLAG",		"C",	02,							0},;
						{"WKFASE_GI", 	"L",	01,							0},;
						{"WKPO_NUM",	AVSX3("W2_PO_NUM",2),	AVSX3("W2_PO_NUM",3),	AVSX3("W2_PO_NUM",4)},;
						{"WKCOD_I",		AVSX3("W3_COD_I",2),	AVSX3("W3_COD_I",3),	AVSX3("W3_COD_I",4)},;
						{"WKPART_O",	AVSX3("A5_PARTOPC",2),	AVSX3("A5_PARTOPC",3),	AVSX3("A5_PARTOPC",4)},;
						{"WKUNIDAD",	AVSX3("B1_UM",2),		AVSX3("B1_UM",3),		AVSX3("B1_UM",4)},;
						{"WKSI_NUM",	AVSX3("W3_SI_NUM",2),	AVSX3("W3_SI_NUM",3),	AVSX3("W3_SI_NUM",4)},;
						{"WKFABR",		AVSX3("W3_FABR",2),		AVSX3("W3_FABR",3),		AVSX3("W3_FABR",4)},;
						{"WKFABR_OLD",	AVSX3("W3_FABR",2),		AVSX3("W3_FABR",3),		AVSX3("W3_FABR",4)},;
						{"WKFORN",		AVSX3("W3_FORN",2),		AVSX3("W3_FORN",3),		AVSX3("W3_FORN",4)},;
						{"WKCC",		AVSX3("W3_CC",2),	    AVSX3("W3_CC",3),		AVSX3("W3_CC",4)},;
						{"WKPOSICAO",	AVSX3("W3_POSICAO",2),	AVSX3("W3_POSICAO",3),	AVSX3("W3_POSICAO",4)},;
						{"WKREG",		AVSX3("W3_REG",2),		AVSX3("W3_REG",3),		AVSX3("W3_REG",4)},;
						{"WKSEQ",		AVSX3("W3_SEQ",2),		AVSX3("W3_SEQ",3),		AVSX3("W3_SEQ",4)},;
						{"WKTOTAL",		"N",	                15,                     02},;
						{"WKRECNO",		"N",	                07,                     00},;
						{"WKQTDE",		AVSX3("W3_QTDE",2),		AVSX3("W3_QTDE",3),		AVSX3("W3_QTDE",4)},;
						{"WKPRECO",		AVSX3("W3_PRECO",2),	AVSX3("W3_PRECO",3),	AVSX3("W3_PRECO",4)},;
						{"WKPESOL",		AVSX3("EW5_PESOL",2),	AVSX3("EW5_PESOL",3),	AVSX3("EW5_PESOL",4)},;
						{"WKPESOB",		AVSX3("EW5_PESOB",2),	AVSX3("EW5_PESOB",3),	AVSX3("EW5_PESOB",4)}}
LOCAL aStru:={{"WK_FABR","C",6,0},{"WKNOME_FB","C",30,0}}

If EICLOJA() .And. (nPos := aScan(aDBF_Stru, {|x| x[1] == "WKFABR" })) > 0
   aAdd(aDBF_Stru, Nil)
   aIns(aDBF_Stru, nPos + 1)
   aDBF_Stru[nPos+1] := {"WKFABLOJ", "C", AvSx3("W3_FABLOJ", AV_TAMANHO),0}
EndIf

/*If EICLOJA() .And. (nPos := aScan(aDBF_Stru, {|x| x[1] == "WKFABR_OLD" })) > 0
   aAdd(aDBF_Stru, Nil)
   aIns(aDBF_Stru, nPos + 1)
   aDBF_Stru[nPos+1] := {"WKFABLOJOLD", "C", AvSx3("W3_FABLOJ", AV_TAMANHO),0}
EndIf*/

If EICLOJA() .And. (nPos := aScan(aDBF_Stru, {|x| x[1] == "WKFORN" })) > 0
   aAdd(aDBF_Stru, Nil)
   aIns(aDBF_Stru, nPos + 1)
   aDBF_Stru[nPos+1] := {"WKFORLOJ", "C", AvSx3("W3_FORLOJ", AV_TAMANHO),0}
EndIf

If EICLOJA() .And. (nPos := aScan(aStru, {|x| x[1] == "WK_FABR" })) > 0
   aAdd(aStru, Nil)
   aIns(aStru, nPos + 1)
   aStru[nPos+1] := {"WKFORLOJ", "C", AvSx3("W3_FORLOJ", AV_TAMANHO),0}
EndIf

If lIntegEAI
   AAdd(aDBF_Stru, {"WKSEGUM"  , AvSx3("W3_SEGUM", AV_TIPO), AvSx3("W3_SEGUM", AV_TAMANHO), AvSx3("W3_SEGUM", AV_DECIMAL)})
   AAdd(aDBF_Stru, {"WKQTSEGUM", AvSx3("W3_QTSEGUM", AV_TIPO), AvSx3("W3_QTSEGUM", AV_TAMANHO), AvSx3("W3_QTSEGUM", AV_DECIMAL)})
EndIf
If AvFlags("RATEIO_DESP_PO_PLI")
   AADD(aDBF_Stru,{"WKFRETE",AVSX3("W3_FRETE",AV_TIPO)  ,AVSX3("W3_FRETE",AV_TAMANHO)  ,AVSX3("W3_FRETE",AV_DECIMAL)})
   AADD(aDBF_Stru,{"WKSEGUR",AVSX3("W3_SEGURO",AV_TIPO) ,AVSX3("W3_SEGURO",AV_TAMANHO) ,AVSX3("W3_SEGURO",AV_DECIMAL)})
   AADD(aDBF_Stru,{"WKINLAN",AVSX3("W3_INLAND",AV_TIPO) ,AVSX3("W3_INLAND",AV_TAMANHO) ,AVSX3("W3_INLAND",AV_DECIMAL)})
   AADD(aDBF_Stru,{"WKDESCO",AVSX3("W3_DESCONT",AV_TIPO),AVSX3("W3_DESCONT",AV_TAMANHO),AVSX3("W3_DESCONT",AV_DECIMAL)})
   AADD(aDBF_Stru,{"WKPACKI",AVSX3("W3_PACKING",AV_TIPO),AVSX3("W3_PACKING",AV_TAMANHO),AVSX3("W3_PACKING",AV_DECIMAL)})

   AADD(aDBF_Stru,{"W3_FRETE"  ,AVSX3("W3_FRETE",AV_TIPO)  ,AVSX3("W3_FRETE",AV_TAMANHO)  ,AVSX3("W3_FRETE",AV_DECIMAL)})
   AADD(aDBF_Stru,{"W3_SEGURO" ,AVSX3("W3_SEGURO",AV_TIPO) ,AVSX3("W3_SEGURO",AV_TAMANHO) ,AVSX3("W3_SEGURO",AV_DECIMAL)})
   AADD(aDBF_Stru,{"W3_INLAND" ,AVSX3("W3_INLAND",AV_TIPO) ,AVSX3("W3_INLAND",AV_TAMANHO) ,AVSX3("W3_INLAND",AV_DECIMAL)})
   AADD(aDBF_Stru,{"W3_DESCONT",AVSX3("W3_DESCONT",AV_TIPO),AVSX3("W3_DESCONT",AV_TAMANHO),AVSX3("W3_DESCONT",AV_DECIMAL)})
   AADD(aDBF_Stru,{"W3_PACKING",AVSX3("W3_PACKING",AV_TIPO),AVSX3("W3_PACKING",AV_TAMANHO),AVSX3("W3_PACKING",AV_DECIMAL)})
EndIf
aHeader:={}
aCampos:={}
cFileHelp:=E_CriaTrab(,aStru,"Work_Hlp")

//GFP 20/10/2010
aDBF_Stru := AddWkCpoUser(aDBF_Stru,"SW8")

cNomArq1:=E_CriaTrab(,aDBF_Stru,"Work")
If !USED()
	Return .F.
EndIf
INDREGUA("WORK",cNomArq1+TEOrdBagExt(),"WKPO_NUM+WKPOSICAO")
cNomArq2:=E_Create(,.F.)
INDREGUA("WORK",cNomArq2+TEOrdBagExt(),"WKCOD_I")
dbSelectArea("WORK")
SET INDEX TO (cNomArq1+TEOrdBagExt()), (cNomArq2+TEOrdBagExt())
Return .T.

*==================================*
Static Function EV100GrvWork(lPOnew)
*==================================*
LOCAL nSaldoDis
LOCAL aInvEmb:={}, cOrdSW8:=SW8->(indexOrd()), cFilSW8:=xFilial("SW8")       // RJB 16/12/2005
//
SA5->(dbSetOrder(3))
SW3->(dbSetOrder(8))
SW7->(dbSetOrder(2))
PROCREGUA(10)
nCont:=0
lAchouItem:=.F.
If lPOnew
	EW5->(dbSetOrder(2))
	SW3->(dbSeek(cFilSW3+M->EW5_PO_NUM))
	While SW3->(!EOF()) .AND. SW3->W3_PO_NUM == M->EW5_PO_NUM .AND. cFilSW3 == SW3->W3_FILIAL
		ASIZE(aInvEmb,0) // RJB 16/12/2005
		If nCont > 10
			nCont:=0
			PROCREGUA(10)
		Else
			INCPROC(STR0016 + SW3->W3_COD_I) //"Lendo item: "
			nCont++
		EndIf
		If SW3->W3_SEQ # 0
			SW3->(dbSkip())
			Loop
		EndIf
		//
		WORK->(dbSetOrder(1)) // JBS - 25/04/2003
		If WORK->(dbSeek(SW3->W3_PO_NUM+SW3->W3_POSICAO))
			SW3->(dbSkip())
			Loop
		EndIf
		//
		nSaldoDis := 0
		If EW5->(dbSeek(cFilEW5+SW3->W3_PO_NUM+SW3->W3_POSICAO))
			While SW3->(cFilEW5+W3_PO_NUM+W3_POSICAO) == EW5->(EW5_FILIAL+EW5_PO_NUM+EW5_POSICA)
				nSaldoDis += EW5->EW5_QTDE
				AADD(aInvEmb,EW5->EW5_INVOIC+EW5->EW5_FORN+EICRetLoja("EW5","EW5_FORLOJ"))
				EW5->(dbSkip())
			Enddo
		EndIf

		// JBS, 30 de Abril de 2003
		// Subtrai da quantidade Disponível, a quantidade que já foi enviada, ou seja,
		// a quantidade do item do Processo
		If SW7->(dbSeek(cFilSW7+SW3->W3_PO_NUM))
			SW8->(dbSetOrder(3))
			DO While SW7->(W7_Filial+W7_PO_NUM)==SW3->(cFilSW7+W3_PO_NUM).and.SW7->(! EOF())
				If SW3->W3_POSICAO == SW7->W7_POSICAO	.AND.;
					SW7->W7_SEQ     == 0						.AND.;
					Empty(SW7->W7_INVOICE)
					// INICIO - RJB 16/12/2005 VERIfICAR A INVOICE QUANDO O EMBARQUE NAO É COM INVOICE ANTECIPADA.
					If SW8->(dbSeek(cFilSW8+SW7->W7_HAWB+SW7->W7_PGI_NUM+SW7->W7_PO_NUM+SW7->W7_SI_NUM+SW7->W7_CC+SW7->W7_COD_I))
						While SW8->(!EOF())                      .AND. ;
							SW8->W8_FILIAL  == SW7->W7_FILIAL  .AND. ;
							SW8->W8_HAWB    == SW7->W7_HAWB    .AND. ;
							SW8->W8_PGI_NUM == SW7->W7_PGI_NUM .AND. ;
							SW8->W8_PO_NUM  == SW7->W7_PO_NUM  .AND. ;
							SW8->W8_SI_NUM  == SW7->W7_SI_NUM  .AND. ;
							SW8->W8_CC      == SW7->W7_CC      .AND. ;
							SW8->W8_COD_I   == SW7->W7_COD_I
							If ASCAN(aInvEmb,SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("EW5","EW5_FORLOJ")) = 0 .AND. SW8->W8_POSICAO == SW7->W7_POSICAO // RJB 16/12/2005
								nSaldoDis += SW7->W7_QTDE
							EndIf                                  // RJB 16/12/2005
							SW8->(dbSkip())
						EndDO
					Else                                      // RJB 16/12/2005 - ITENS EMBARCADO SEM INVOICE
						nSaldoDis += SW7->W7_QTDE
					EndIf
				EndIf
				SW7->(dbSkip())
			EndDO
			SW8->(dbSetOrder(cOrdSW8))
		EndIf
		If SW3->W3_QTDE-nSaldoDis <= 0
			SW3->(dbSkip())
			Loop
		EndIf
		EV100APPEnd(.F.)
		SW3->(dbSkip())
	EndDO
	dbSelectArea("EW4")
	//
Else
	lAchouItem:=.T.
	EW5->(dbSetOrder(1))
	EW5->(dbSeek(cFilEW5+EW4->EW4_INVOIC+EW4->EW4_FORN+EICRetLoja("EW4","EW4_FORLOJ")))
	While EW5->(!EOF())								.AND.;
			EW5->EW5_INVOIC == EW4->EW4_INVOIC	.AND.;
			EW5->EW5_FORN   == EW4->EW4_FORN	.AND.  IIF(EICLoja(),EW5->EW5_FORLOJ == EW4->EW4_FORLOJ,.T.) .And.;
			EW5->EW5_FILIAL == cFilEW5
		If nCont > 10
			nCont:=0
			PROCREGUA(10)
		Else
			INCPROC(STR0016 + EW5->EW5_COD_I) //"Lendo item: "
			nCont++
		EndIf
		If !SW3->(dbSeek(cFilSW3+EW5->EW5_PO_NUM+EW5->EW5_POSICA))
			MSGSTOP(StrTran(StrTran(STR0017, "####", AllTrim(EW5->EW5_POSICA)), "$$$$", AllTrim(EW5->EW5_PO_NUM)), STR0002) //"O item #### não foi encontrado no pedido $$$$.", Atenção
			EW5->(dbSkip())
			Loop
		EndIf
		WORK->(dbSetOrder(1)) // JBS - 25/04/2003
		If WORK->(dbSeek(EW5->EW5_PO_NUM+EW5->EW5_POSICA))
			EW5->(dbSkip())
			Loop
		EndIf
		EV100APPEnd(.T.)
		WORK->WKRECNO :=EW5->(RECNO())
		EW5->(dbSkip())
	EndDO
EndIf
dbSelectArea("EW4")
If !lAchouItem
	MsgInfo(STR0018) //"Não foram encontrados itens diponíveis para esse pedido."
	Return .F.
EndIf
If(EasyEntryPoint("EICEV100"),Execblock("EICEV100",.F.,.F.,"GRVWORK"),)  // GFP - 26/05/2014
Return .T.

*================================*
Static Function EV100APPEnd(lFlag)
*================================*
Local lIntegEAI     := AvFlags("EIC_EAI", .F., .F.)
Local aSegUM:= {}
If lFlag
	//SA5->(dbSeek(cFilSA5+EW5->EW5_COD_I+EW5->EW5_FABR+EW5->EW5_FORN))
	EICSFabFor(cFilSA5+EW5->EW5_COD_I+EW5->EW5_FABR+EW5->EW5_FORN, EICRetLoja("EW5","EW5_FABLOJ"), EICRetLoja("EW5","EW5_FORLOJ"))
	SB1->(dbSeek(cFilSB1+EW5->EW5_COD_I))
Else
	//SA5->(dbSeek(cFilSA5+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN))
	EICSFabFor(cFilSA5+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN, EICRetLoja("SW3","W3_FABLOJ"), EICRetLoja("SW3","W3_FORLOJ"))
	SB1->(dbSeek(cFilSB1+SW3->W3_COD_I))
EndIf
//
lAchouItem:=.T.
WORK->(DBAPPEnd())
If !lFlag
	WORK->WKFLAG    := " "
	WORK->WKPO_NUM  := SW3->W3_PO_NUM
	WORK->WKCOD_I   := SW3->W3_COD_I
	WORK->WKPART_O  := SA5->A5_PARTOPC
	If lIntegEAI
	   WORK->WKUNIDAD  := SW3->W3_UM
	Else
	   WORK->WKUNIDAD  := If(!EMPTY(SA5->A5_UNID),SA5->A5_UNID,SB1->B1_UM)
	EndIf
	WORK->WKCC      := SW3->W3_CC
	WORK->WKSI_NUM  := SW3->W3_SI_NUM
	WORK->WKQTDE    := EV100SdoOk()
	WORK->WKPRECO   := SW3->W3_PRECO
	WORK->WKFABR    := SW3->W3_FABR
	WORK->WKFABR_OLD:= SW3->W3_FABR
	WORK->WKFORN    := SW3->W3_FORN
	WORK->WKTOTAL   := SW3->W3_QTDE*SW3->W3_PRECO
	WORK->WKPOSICAO := SW3->W3_POSICAO
	WORK->WKREG		 := SW3->W3_REG
	WORK->WKSEQ		 := SW3->W3_SEQ
	IF EICLoja()
	   WORK->WKFABLOJ   := SW3->W3_FABLOJ
	   //WORK->WKFABLOJOLD:= SW3->W3_FABLOJ
	   WORK->WKFORLOJ   := SW3->W3_FORLOJ
	ENDIF
	WORK->WKPESOL   := If(	!EMPTY(SA5->A5_PESO),;
									SA5->A5_PESO,;
									B1Peso(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ")))
	WORK->WKPESOB   := If(	SB1->B1_PESBRU<>0,;
									SB1->B1_PESBRU,;
									SA5->A5_PESO)
   If lIntegEAI
      Work->WKSEGUM:= SW3->W3_SEGUM
      Work->WKQTSEGUM:= SW3->W3_QTSEGUM
   EndIf
   If AvFlags("RATEIO_DESP_PO_PLI")
      Work->W3_FRETE   := SW3->W3_FRETE
      Work->W3_SEGURO  := SW3->W3_SEGURO
      Work->W3_INLAND  := SW3->W3_INLAND
      Work->W3_DESCONT := SW3->W3_DESCONT
      Work->W3_PACKING := SW3->W3_PACKING
   EndIf
Else
	WORK->WKFLAG    := cMarca
	WORK->WKPO_NUM  := EW5->EW5_PO_NUM
	WORK->WKCOD_I   := EW5->EW5_COD_I
	WORK->WKPART_O  := SA5->A5_PARTOPC
	WORK->WKUNIDAD  := If(!EMPTY(SA5->A5_UNID),SA5->A5_UNID,SB1->B1_UM)
	WORK->WKCC      := EW5->EW5_CC
	WORK->WKSI_NUM  := EW5->EW5_SI_NUM
	WORK->WKQTDE    := EW5->EW5_QTDE
	WORK->WKPRECO   := EW5->EW5_PRECO
	WORK->WKFABR    := EW5->EW5_FABR
	WORK->WKFABR_OLD:= EW5->EW5_FABR
	WORK->WKFORN    := EW5->EW5_FORN
	WORK->WKTOTAL   := EW5->EW5_QTDE*EW5->EW5_PRECO
	WORK->WKPOSICAO := EW5->EW5_POSICA
	WORK->WKREG		 := EW5->EW5_REG
	WORK->WKSEQ		 := EW5->EW5_SEQ
	WORK->WKPESOL   := EW5->EW5_PESOL
	WORK->WKPESOB   := EW5->EW5_PESOB
	IF EICLoja()
	   WORK->WKFABLOJ   := EW5->EW5_FABLOJ
	   //WORK->WKFABLOJOLD:= EW5->W5_FABLOJ
	   WORK->WKFORLOJ   := EW5->EW5_FORLOJ
	ENDIF

   If lIntegEAI
      aSegUM:= Busca_2UM(EW5->EW5_PO_NUM, EW5->EW5_POSICAO)

      If Len(aSegUM) > 0
         Work->WKSEGUM  := aSegUM[2]
         Work->WKQTSEGUM:= Work->WKQTDE * aSegUM[3]
      EndIf
   EndIF
// MFR 17/05/2017 TE-5740 MTRADE-1011
   If AvFlags("RATEIO_DESP_PO_PLI")
     Work->W3_FRETE   := EW5->EW5_FRETE
     Work->W3_SEGURO  := EW5->EW5_SEGURO
     Work->W3_INLAND  := EW5->EW5_INLAND
     Work->W3_DESCONT := EW5->EW5_DESCON
     Work->W3_PACKING := EW5->EW5_PACKIN
   Endif

   If AvFlags("RATEIO_DESP_PO_PLI")
      Work->WKFRETE := EW5->EW5_FRETE
      Work->WKSEGUR := EW5->EW5_SEGURO
      Work->WKINLAN := EW5->EW5_INLAND
      Work->WKDESCO := EW5->EW5_DESCON
      Work->WKPACKI := EW5->EW5_PACKIN
   EndIf

EndIf

IF(EasyEntryPoint("EICEV100"),Execblock("EICEV100",.F.,.F.,"ALTERA_WORK"),)  // GFP - 19/08/2015
Return .T.

*============================*
Static Function EV100MarkAll()
*============================*
LOCAL cMarcaNew:=If(EMPTY(WORK->WKFLAG),cMarca,'  ')
WORK->(dbGoTop())
PROCREGUA(WORK->(LASTREC()))
While WORK->(!EOF())
	If WORK->WKFASE_GI
		WORK->(dbSkip())
		Loop
	EndIf
// MFR 17/05/2017 TE-5740 MTRADE-1011 	aqui
   Work->WKFRETE := Work->W3_FRETE
   Work->WKSEGUR := Work->W3_SEGURO
   Work->WKINLAN := Work->W3_INLAND
   Work->WKDESCO := Work->W3_DESCONT
   Work->WKPACKI := Work->W3_PACKING
   SW3->(dbSeek(cFilSW3+WORK->WKPO_NUM+WORK->WKPOSICAO))
   WORK->WKQTDE := EV100SdoOk()
   WORK->WKTOTAL:= Round( WORK->WKQTDE*WORK->WKPRECO , 2)
	IncProc()
	WORK->WKFLAG:=cMarcaNew
	WORK->(dbSkip())
EndDO
Ev100FobTot()
WORK->(dbGoTop())
Return .T.

*==========================*
Static Function EV100MARCA()
*==========================*
If WORK->WKFASE_GI
	MSGSTOP(STR0019) //"Item embarcado ou em fase de P.L.I."
	Return .t.
EndIf
If !SW3->(dbSeek(cFilSW3+WORK->WKPO_NUM+WORK->WKPOSICAO)) //SEEK SW3
	MSGSTOP(STR0020) //"Item não encontrado no PO!"
	Return .f.
EndIf
If empty(M->EW4_INVOIC)
	MSGSTOP(STR0021) //"O código da Invoice não foi informado!"
	Return .f.
EndIf
If	!Empty(M->EW4_HAWB)
	MSGSTOP(STR0022) //"A Invoice foi embarcada. A manutenção nos itens não é permitida!"
	Return .f.
EndIf
If	M->EW4_OK_SHP=="1"
	MSGSTOP(STR0023) //"Embarque da Invoice autorizado. A manutenção nos itens não é permitida!"
	Return .f.
EndIf
//
If EMPTY(WORK->WKFLAG)
	WORK->WKFLAG:=cMarca // Marca x no item selecionando.
	EV100Saldo()         // Cria a tela para Informar a quantidade a ser embarcada.
Else
	WORK->WKFLAG :="  "                         // Desmarca o item selecionado
	WORK->WKQTDE := EV100SdoOk()
	WORK->WKTOTAL:= Round( WORK->WKQTDE*WORK->WKPRECO, 2)
EndIf
Ev100FobTot()
SA5->(dbSetOrder(3))
SB1->(dbSetOrder(1))
//SA5->(dbSeek(cFilSA5+WORK->WKCOD_I+WORK->WKFABR+WORK->WKFORN))
EICSFabFor(cFilSA5+WORK->WKCOD_I+WORK->WKFABR+WORK->WKFORN, EICRetLoja("WORK","WKFABLOJ"), EICRetLoja("WORK","WKFORLOJ"))
SB1->(dbSeek(cFilSB1+WORK->WKCOD_I))
SA5->(dbSetOrder(1))
WORK->WKPESOL   := If(	!EMPTY(SA5->A5_PESO),;
									SA5->A5_PESO,;
									B1Peso(WORK->WKCC,WORK->WKSI_NUM,WORK->WKCOD_I,WORK->WKREG,WORK->WKFABR,WORK->WKFORN,EICRetLoja("WORK","WKFABLOJ"), EICRetLoja("WORK","WKFORLOJ")))
WORK->WKPESOB   := If(	SB1->B1_PESBRU<>0,;
								SB1->B1_PESBRU,;
								SA5->A5_PESO)
//
Return .T.

*==========================*
Static Function EV100Grava()
*==========================*
WORK->(dbGoTop())
EW5->(dbSetOrder(2))
SW3->(dbSetOrder(8))
ProcRegua(WORK->(LASTREC()))
While ! WORK->(EOF())
	INCPROC(STR0016 + WORK->WKCOD_I) //"Lendo item: "
	If EMPTY(WORK->WKFLAG) .AND. EMPTY(WORK->WKRECNO)
		WORK->(dbSkip())
		Loop
	EndIf
	If !EMPTY(WORK->WKFLAG)
		If !EMPTY(WORK->WKRECNO)
			EW5->(dbGoTo(WORK->WKRECNO))
		EndIf
		EV100GrvEW5(EMPTY(WORK->WKRECNO))
		WORK->(dbSkip())
		Loop
	EndIf
	If EMPTY(WORK->WKFLAG) .AND. !EMPTY(WORK->WKRECNO)
		EW5->(dbGoTo(WORK->WKRECNO))
		SW5->(dbSetOrder(8))
		If SW5->(dbSeek(xFilial("SW5")+EW5->EW5_PGI_NU+EW5->EW5_PO_NUM+EW5->EW5_POSICA))
			SW5->(RecLock("SW5"),.F.)
			SW5->W5_INVANT := SPACE(LEN(EW5->EW5_INVOIC))
			SW5->(MSUnlock())
		EndIf
		EW5->(RECLOCK("EW5",.F.))
		EW5->(DBDELETE())
		EW5->(MSUNLOCK())
	EndIf
	WORK->(dbSkip())
EndDO
// gravacao de campo memo
If (!empty(EW4->EW4_CODOBS) .OR. !empty(M->EW4_OBS))
	lExiste := .T.
	MSMM(If(lExiste,EW4_CODOBS,),AVSX3("EW4_OBS" ,3),,M->EW4_OBS ,1,,,"EW4","EW4_CODOBS")
EndIf

//ACB - 07/04/2010 - Ponto de entrada para manutenção DEPOIS da gravação da tabela EW5
If EasyEntryPoint("EICEV100")
   Execblock("EICEV100",.F.,.F.,"DEPOIS_GRAVA_EW5")
Endif
Return .T.

*==================================*
Static Function EV100GrvEW5(lAppEnd)
*==================================*
//LOCAL cPGI_NUM:=''
//ACB - 07/04/2010 - Ponto de entrada para manutenção ANTES da gravação da tabela EW5
If EasyEntryPoint("EICEV100")
   Execblock("EICEV100",.F.,.F.,"ANTES_GRAVA_EW5")
Endif

EW5->(RECLOCK("EW5",lAppEnd))
If lAppEnd
	//   Quando FOR Registro novo
	EW5->EW5_FILIAL:= cFilEW5
	EW5->EW5_INVOIC:= M->EW4_INVOIC
	EW5->EW5_FORN  := WORK->WKFORN
	EW5->EW5_SI_NUM:= WORK->WKSI_NUM
	EW5->EW5_COD_I := WORK->WKCOD_I
	EW5->EW5_PO_NUM:= WORK->WKPO_NUM
	EW5->EW5_PRECO := WORK->WKPRECO
	EW5->EW5_CC    := WORK->WKCC
	EW5->EW5_POSICA:= WORK->WKPOSICAO
	EW5->EW5_REG	:=	WORK->WKREG
	EW5->EW5_SEQ	:=	WORK->WKSEQ
	EW5->EW5_FABR  := WORK->WKFABR
	If EICLoja()
	   EW5->EW5_FORLOJ:= WORK->WKFORLOJ
	   EW5->EW5_FABLOJ:= WORK->WKFABLOJ
	EndIf
EndIf
EW5->EW5_PESOL := WORK->WKPESOL
EW5->EW5_PESOB := WORK->WKPESOB

If AvFlags("RATEIO_DESP_PO_PLI")
      EW5->EW5_FRETE := Work->WKFRETE
      EW5->EW5_SEGURO := Work->WKSEGUR
      EW5->EW5_INLAND := Work->WKINLAN
      EW5->EW5_DESCON := Work->WKDESCO
      EW5->EW5_PACKIN := Work->WKPACKI
   EndIf

EV100AtulizaPLI()
EW5->EW5_QTDE  :=WORK->WKQTDE
EW5->(MSUNLOCK())
If !SW3->(dbSeek(cFilSW3+WORK->WKPO_NUM+WORK->WKPOSICAO))
	MSGSTOP(StrTran(StrTran(STR0017, "####", AllTrim(WORK->WKPOSICAO)), "$$$$", AllTrim(WORK->WKPO_NUM)), STR0002) //"O item #### não foi encontrado no pedido $$$$.", Atenção
	Return .F.
EndIf
Return .T.

*============================*
Static Function EV100EXCLUIR()
*============================*
PROCREGUA(WORK->(LASTREC()))
EW5->(dbSetOrder(1))
EW5->(dbSeek(cFilEW5+M->EW4_INVOIC+M->EW4_FORN+EICRetLoja("EW4","EW4_FORLOJ")))
While	EW5->(!EOF())										.AND.;
		EW5->EW5_FILIAL					==	cFilEW5	.AND.;
		EW5->EW5_INVOIC+EW5->EW5_FORN+EICRetLoja("EW5","EW5_FORLOJ")	==	M->EW4_INVOIC+M->EW4_FORN+EICRetLoja("M","EW4_FORLOJ")
	INCPROC(STR0024 + EW5->EW5_COD_I) //"Item estornado: "
	SW5->(dbSetOrder(8))
	If SW5->(dbSeek(xFilial("SW5")+EW5->EW5_PGI_NU+EW5->EW5_PO_NUM + EW5->EW5_POSICA))
		SW5->(RecLock("SW5"),.F.)
		SW5->W5_INVANT := SPACE(LEN(EW5->EW5_INVOIC))
		SW5->(MSUnlock())
	EndIf
	EW5->(RECLOCK("EW5",.F.))
	EW5->(DBDELETE())
	EW5->(MSUNLOCK())
	EW5->(dbSkip())
EndDO
Return .T.

*===============================*
Function EV100VALID(cTipo)
*===============================*
Local lIntegEAI:= AvFlags("EIC_EAI")
Local aSegUM:= {}
Private lSair := .F.
Private cCampo := cTipo

//ACB - 07/04/2010 - Ponto de entrada para validações de campos.
If EasyEntryPoint("EICEV100")
   Execblock("EICEV100",.F.,.F.,"VALIDA_CAMPOS")
   If lSair
      Return .F.
   EndIf
Endif

If cTipo == NIL
	cTipo:=UPPER(Readvar())
EndIf
DO CASE
	CASE cTipo $ "M->EW4_INLAND,M->EW4_FRETEI,M->EW4_PACKIN,M->EW4_DESCON"
		If !POSITIVO()
			Return .F.
		EndIf
	CASE cTipo=="FABR"
		If EMPTY(cFabr)
			Return .F.
		EndIf
		If !SA2->(dbSeek(xfilial("SA2")+cFabr))
			MsgInfo(STR0025, STR0002) //"Fabricante não cadastrado. Verifique o cadastro de Fabricante/ Fornecedor.", Atenção
			Return .F.
		EndIf
		SA5->(dbSetOrder(3))
		If !SA5->(dbSeek(xFilial()+WORK->WKCOD_I+cFabr+WORK->WKFORN))
			MsgInfo(STR0026, STR0002) //"Não existe cadastro de relacionamento entre o Item, o Fabricante e o Fornecedor.", Atenção
			SA5->(dbSetOrder(1))
			Return .F.
		EndIf
	CASE cTipo=="PO"
		If EMPTY(M->EW5_PO_NUM)
			Return .F.
		EndIf
		If !SW2->(dbSeek(XFILIAL("SW2")+M->EW5_PO_NUM))
			MsgInfo(StrTran(STR0027, "####", AllTrim(M->EW5_PO_NUM)), STR0002) //"Purchase Order #### não encontrado. Informe um P.O. cadastrado.", Atenção
			Return .F.
		EndIf
		If !EMPTY(cMoeda)
			If cMoeda # SW2->W2_MOEDA
				MsgInfo(StrTran(StrTran(STR0028, "####", AllTrim(SW2->W2_MOEDA)), "$$$$", AllTrim(cMoeda)), STR0002) //"A moeda do pedido informado (####) difere da moeda do(s) pedido(s) cadastrado(s) - $$$$.", Atenção
				Return .F.
			EndIf
		EndIf
		If !EMPTY(cFORn)  .And. IIF(EICLoja(),!Empty(cForLoj),.T.)
			If cFORn # SW2->W2_FORN  .Or. IIF(EICLoja(),cForLoj # SW2->W2_FORLOJ,.T.)
				MsgInfo(StrTran(StrTran(STR0029, "####", AllTrim(SW2->W2_FORN) +IIF(EICLoja(), " - " + SW2->W2_FORLOJ, "")), "$$$$", AllTrim(cForn) + IIF(EICLoja()," - " + cForLoj, "")), STR0002) //"O fornecedor do pedido informado (####)difere do fornecedor do(s) pedido(s) cadastrado(s) - $$$$.", Atenção
				Return .F.
			EndIf
		EndIf
		cMoeda:=SW2->W2_MOEDA
		cForn :=SW2->W2_FORN
		If EICLoja()
		   cForLoj := SW2->W2_FORLOJ
		EndIf
	CASE cTipo=="INVOICE"
		If empty(M->EW4_INVOIC)
			MsgInfo(STR0021, STR0002) //"O código da Invoice não foi informado!", Atenção
			Return(.f.)
		ElseIf EW4->(dbSeek(xfilial("EW4")+M->EW4_INVOIC+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")))
			MsgInfo(StrTran(StrTran(STR0052, "####", AllTrim(M->EW4_INVOIC)), "$$$$", DtoC(EW4->EW4_DT_EMI)), STR0002) //"Invoice #### cadastrada em: $$$$.", Atenção
			Return(.f.)
		EndIf
	CASE cTipo == "TSALDO_Q"
		If empty(Tsaldo_q)
			MsgInfo(STR0030, STR0002) //"Informe a quantidade embarcada!", Atenção
			Return(.f.)
		ElseIf TSaldo_q > EV100SdoOK()
			MsgInfo(STR0031, STR0002) //"A quantidade informada é maior que o quantidade diponível no Purchase Order.", Atenção
			Return(.f.)
		EndIf
		nFobTotal:= TSaldo_Q * TFobUnit

		If lIntegEAI
          aSegUM:= Busca_2UM(WORK->WKPO_NUM, WORK->WKPOSICAO)

          If Len(aSegUM) > 0
             nQtSegUM:= TSaldo_Q * aSegUM[3]
          EndIf
		EndIf
	CASE cTipo=="ITEM"
		If empty(M->EW5_COD_I)
			MsgInfo(STR0032, STR0002) //"O código do item precisa ser informado!", Atenção
			Return(.f.)
		ElseIf !WORK->(dbSeek(M->EW5_COD_I))
			MsgInfo(STR0033, STR0002)//"Item não cadastrado nesta invoice!", Atenção
			Return(.f.)
		EndIf
EndCASE
Return .T.

*==========================*
Static Function EV100Saldo()
*==========================*
LOCAL cMsg := STR0031 //"A quantidade informada é maior que o quantidade diponível no Purchase Order."
Local cTitulo:= STR0034 //"Informando a Quantidade Embarcada"
Local lIntegEAI:= AvFlags("EIC_EAI")
Local oPanel, aPos:= {}, nLinha, cSegUM
Local bOk:= {|| nOpca:= 1, iIf(ev100SdoOK() >= TSaldo_Q, oDlgSaldo:End(), {||MsgInfo(cMsg)})}
Local bCancel:= {||nOpca:= 0, oDlgSaldo:End()}
Private oDlgSaldo
Private Tsaldo_Q, TFobUnit, nTotal, nOpca
Private _PictItem := AllTrim(X3Picture("W3_COD_I"))
Private _PictPrUn := AllTrim(X3Picture("W3_PRECO")),_PictQtde:=AllTrim(X3Picture("W7_QTDE"))
Private nQtSegUM:= 0
//
Define MsDialog oDlgSaldo Title cTitulo From 15, 03 To 40, 55 OF oMainWnd

   aPos:= PosDlg(oDlgSaldo)
   oPanel:= TPanel():New(0, 0, "", oDlgSaldo,, .F., .F.,,, aPos[4], aPos[3])
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   TSaldo_Q := WORK->WKQTDE
   TFobUnit := WORK->WKPRECO

   If lIntegEAI
      cSegUM:= WORK->WKSEGUM
      nQtSegUM:= WORK->WKQTSEGUM
   EndIf

   dbSelectArea("Work")

   nLinha:= 0.5
   @	nLinha,	0.5	SAY	AVSX3("W3_COD_I",5)			SIZE	40,08 Of oPanel //PIXEL	//STR0103 'Codigo Item'
   @	nLinha,	4.5	SAY	TRAN(WKCOD_I,_PictItem)		SIZE	80,08 Of oPanel //PIXEL

   nLinha += 1
   @	nLinha,	0.5	SAY	AVSX3("W3_FABR",5)			SIZE	40,08 Of oPanel //PIXEL	//STR0104 'Fabricante'
   @	nLinha,	4.5	SAY	AllTrim(WORK->WKFABR) + IIF(EICLoja()," - "+WORK->WKFABLOJ,"")				SIZE	80,08 Of oPanel //PIXEL

   nLinha += 1
   @	nLinha,	0.5	SAY	AVSX3("W3_FORN",5)			SIZE	40,08 Of oPanel//PIXEL	//STR0105 'Fornecedor'
   @	nLinha,	4.5	SAY	AllTrim(WORK->WKFORN) + IIF(EICLoja()," - "+WORK->WKFORLOJ,"")				SIZE	80,08 Of oPanel //PIXEL

   nLinha += 1
   @	nLinha,	0.5	SAY	STR0035                		SIZE    40,08 Of oPanel //PIXEL	//"Quantidade"
   @	nLinha,	4.5	MsGet	TSaldo_Q Picture _PictQtde	VALID	EV100VALID('TSALDO_Q') WHEN .T. SIZE 80,08 Of oPanel //PIXEL

   If lIntegEAI
      nLinha += 1
      @	nLinha,	0.5	SAY	AvSx3("W3_UM", AV_TITULO)	SIZE	80,08 Of oPanel //PIXEL
      @	nLinha,	4.5	MsGet WORK->WKUNIDAD				SIZE	80,08 WHEN .F.	Of oPanel // PIXEL
   EndIf

   nLinha += 1
   nFobTotal:=TSaldo_Q * TFobUnit
   @	nLinha,	0.5	SAY	STR0036								SIZE	80,08 Of oPanel //PIXEL //"FOB Unitário"
   @	nLinha,	4.5	MsGet	TFobUnit Picture _PictPrUn		SIZE	80,08 WHEN .F.	Of oPanel // PIXEL

   nLinha += 1
   @	nLinha,	0.5	SAY	STR0037							SIZE	80,08 Of oPanel //PIXEL //"FOB Total"
   @	nLinha,	4.5	MsGet	nFobTotal Picture _PictPrUn	SIZE	80,08 WHEN .F.	Of oPanel // PIXEL


   If lIntegEAI
      nLinha += 1
      @	nLinha,	0.5	SAY	AvSx3("W3_SEGUM", AV_TITULO)	SIZE	80,08 Of oPanel //PIXEL
      @	nLinha,	4.5	MsGet cSegUM							SIZE	80,08 WHEN .F.	Of oPanel // PIXEL

      nLinha += 1
      @	nLinha,	0.5	SAY	AvSx3("W3_QTSEGUM", AV_TITULO)	SIZE	80,08 Of oPanel //PIXEL
      @	nLinha,	4.5	MsGet nQtSegUM Picture _PictQtde	SIZE	80,08 WHEN .F.	Of oPanel // PIXEL
   EndIf

ACTIVATE MSDIALOG oDlgSaldo ON INIT EnchoiceBar(oDlgSaldo,;
                     bOk,;
                     bCancel) CENTERED
//
If nOpcA == 0
	Return .f.
ElseIf nOpcA == 1
	If AvFlags("RATEIO_DESP_PO_PLI")
      Work->WKFRETE := Work->W3_FRETE   * (TSaldo_Q/WORK->WKQTDE)
      Work->WKSEGUR := Work->W3_SEGURO  * (TSaldo_Q/WORK->WKQTDE)
      Work->WKINLAN := Work->W3_INLAND  * (TSaldo_Q/WORK->WKQTDE)
      Work->WKDESCO := Work->W3_DESCONT * (TSaldo_Q/WORK->WKQTDE)
      Work->WKPACKI := Work->W3_PACKING * (TSaldo_Q/WORK->WKQTDE)
	EndIf

	WORK->WKQTDE    := TSaldo_Q
	WORK->WKTOTAL   := Tsaldo_Q*TFobUnit

	If lIntegEAI
	   WORK->WKQTSEGUM:= nQtSegUM
	EndIf
EndIf
dbSelectArea("WORK")
Return .T.

*===========================*
Function EV100FobTot()
*===========================*
LOCAL nRecno:=WORK->(RECNO())
Local cCampo:=Readvar()
Local lContemFrt := AvRetInco(M->EW4_INCOTE,"CONTEM_FRETE")
Local lContemSeg := AvRetInco(M->EW4_INCOTE,"CONTEM_SEGURO")

WORK->(dbGoTop())

// MFR 17/05/2017 TE-5740 MTRADE-1011
M->EW4_FOBTOT:=0
/*
M->EW4_FRETEI:=0
M->EW4_INLAND:=0
M->EW4_PACKIN:=0
M->EW4_DESCON:=0
If AvFlags("RATEIO_DESP_PO_PLI")
   M->EW4_SEGURO:=0
EndIf
*/

While WORK->(!EOF())
	If EMPTY(WORK->WKFLAG)
		WORK->(dbSkip())
		Loop
	EndIf
	M->EW4_FOBTOT += Round(WORK->WKQTDE*WORK->WKPRECO,2)
	/*
	If AvFlags("RATEIO_DESP_PO_PLI")
		M->EW4_SEGURO += WORK->WKSEGUR
		M->EW4_FRETEI += WORK->WKFRETE
		M->EW4_INLAND += WORK->WKINLAN
		M->EW4_PACKIN += WORK->WKPACKI
		M->EW4_DESCON += WORK->WKDESCO
	EndIf
	*/
	WORK->(dbSkip())
EndDO

Do Case
	Case cCampo == "M->EW4_FRETEI"
		If !lContemFrt .And. !Empty(M->EW4_FRETEI)
			EasyHelp(STR0054,STR0002,STR0056)//"O Incoterm informado não prevê o lançamento do Frete."####"O valor da despesa não deve ser informado ou o Incoterm deve ser revisado."
		EndIf

	Case cCampo == "M->EW4_SEGURO"
		If !lContemSeg .And. !Empty(M->EW4_SEGURO)
			EasyHelp(STR0055,STR0002,STR0056)//"O Incoterm informado não prevê o lançamento do Seguro."####"O valor da despesa não deve ser informado ou o Incoterm deve ser revisado."
		EndIf

EndCase

M->EW4_TOTINV := M->((EW4_FOBTOT+EW4_INLAND+EW4_PACKIN)-EW4_DESCON)+If(M->EW4_FREINC=="1" .Or. !lContemFrt,0,M->EW4_FRETEI)+ If(AvFlags("RATEIO_DESP_PO_PLI"),If(M->EW4_SEGINC=="1" .Or. !lContemSeg,0,M->EW4_SEGURO),0)
WORK->(dbGoTo(nRecno))
lRefresh:=.T.
Return .T.

// MFR 17/05/2017 TE-5740 MTRADE-1011
*===========================*
Static Function EV100FobTt()
*===========================*
LOCAL nRecno:=WORK->(RECNO())
WORK->(dbGoTop())
M->EW4_FOBTOT:=0
M->EW4_FRETEI:=0
M->EW4_INLAND:=0
M->EW4_PACKIN:=0
M->EW4_DESCON:=0
//// MFR 17/05/2017 TE-5740 MTRADE-1011
//If AvFlags("RATEIO_DESP_PO_PLI")
   M->EW4_SEGURO:=0
//EndIf
While WORK->(!EOF())
	If EMPTY(WORK->WKFLAG)
		WORK->(dbSkip())
		Loop
	EndIf
	M->EW4_FOBTOT += WORK->WKQTDE*WORK->WKPRECO
	If AvFlags("RATEIO_DESP_PO_PLI")
		M->EW4_SEGURO += WORK->WKSEGUR
		M->EW4_FRETEI += WORK->WKFRETE
		M->EW4_INLAND += WORK->WKINLAN
		M->EW4_PACKIN += WORK->WKPACKI
		M->EW4_DESCON += WORK->WKDESCO
	EndIf
	WORK->(dbSkip())
EndDO
M->EW4_TOTINV := M->((EW4_FOBTOT+EW4_INLAND+EW4_PACKIN)-EW4_DESCON)+If(M->EW4_FREINC=="1",0,M->EW4_FRETEI)+ If(AvFlags("RATEIO_DESP_PO_PLI"),If(M->EW4_SEGINC=="1",0,M->EW4_SEGURO),0)
WORK->(dbGoTo(nRecno))
lRefresh:=.T.
Return .T.

*==========================*
Static Function EV100SdoOk()
*==========================*
LOCAL cOrder  := EW5->(indexOrd()), nSaldoAlt, nSaldoDis
LOCAL aInvEmb :=  {} , cOrdSW8:=SW8->(indexOrd()) , cFilSW8:= xFilial("SW8")
//
lAlterando := If(lAlterando == NIL, .f., lAlterando)
nSaldoDis := nSaldoAlt := 0
EW5->(dbSetOrder(2))
SW7->(dbSetOrder(2))
If EW5->(dbSeek(cFilEW5+SW3->W3_PO_NUM+SW3->W3_POSICAO))
	While SW3->(cFilEW5+W3_PO_NUM+W3_POSICAO) == EW5->(EW5_FILIAL+EW5_PO_NUM+EW5_POSICA)
		If lAlterando .and. M->EW4_INVOIC == EW5->EW5_INVOIC
			nSaldoAlt := EW5->EW5_QTDE
		EndIf
		nSaldoDis += EW5->EW5_QTDE
		AADD(aInvEmb,EW5->EW5_INVOIC+EW5->EW5_FORN+EICRetLoja("EW5","EW5_FORLOJ"))
		EW5->(dbSkip())
	Enddo
EndIf
//
If SW7->(dbSeek(cFilSW7+SW3->W3_PO_NUM))
	SW8->(dbSetOrder(3))
	Do While SW7->(!EOF()) .And. SW7->W7_FILIAL == cFilSW7 .And. SW7->W7_PO_NUM == SW3->W3_PO_NUM
		If SW3->W3_POSICAO == SW7->W7_POSICAO	.AND.;
			SW7->W7_SEQ     == 0						.AND.;
			Empty(SW7->W7_INVOICE)
			// INICIO - RJB 16/12/2005 VERIFICAR A INVOICE QUANDO O EMBARQUE NAO É COM INVOICE ANTECIPADA.
			If SW8->(dbSeek(cFilSW8+SW7->(W7_HAWB+W7_PGI_NUM+W7_PO_NUM+W7_SI_NUM+W7_CC+W7_COD_I)))
				While SW8->(!EOF())                      .AND. ;
					SW8->W8_FILIAL  == SW7->W7_FILIAL  .AND. ;
					SW8->W8_HAWB    == SW7->W7_HAWB    .AND. ;
					SW8->W8_PGI_NUM == SW7->W7_PGI_NUM .AND. ;
					SW8->W8_PO_NUM  == SW7->W7_PO_NUM  .AND. ;
					SW8->W8_SI_NUM  == SW7->W7_SI_NUM  .AND. ;
					SW8->W8_CC      == SW7->W7_CC      .AND. ;
					SW8->W8_COD_I   == SW7->W7_COD_I
					//
					If ASCAN(aInvEmb,SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("EW5","EW5_FORLOJ")) == 0 .AND. SW8->W8_POSICAO == SW7->W7_POSICAO // RJB 16/12/2005
						nSaldoDis += SW7->W7_QTDE
					EndIf                                  // RJB 16/12/2005
					SW8->(dbSkip())
				EndDo
			Else                                      // RJB 16/12/2005 - ITENS EMBARCADO SEM INVOICE
				nSaldoDis += SW7->W7_QTDE
			EndIf
		EndIf
		SW7->(dbSkip())
	EndDo
	SW8->(dbSetOrder(cOrdSW8))
EndIf
EW5->(dbSetOrder(cOrder))
Return(SW3->W3_QTDE-(nSaldoDis-nSaldoAlt))

*===============================*
Static Function EV100AtulizaPLI()
*===============================*
// OBJETIVO: Atualizar o campo PGI_NU => Numero da PLI
// Para Itens não anuentes ou seja : W3_Fluxo ="7"
// Pesquisa w3_Seq = "1"
// Gravando o Campo no EW5
LOCAL cOrdSw3  := SW3->(IndexOrd())
LOCAL nSw3Recno:= SW3->(Recno())
LOCAL bSw3Valid:= {|| SW3->(!EOF())	.And.;
								SW3->W3_FILIAL	==	cFilEW5			.AND.;
								SW3->W3_PO_NUM	==	EW5->EW5_PO_NUM.AND.;
								SW3->W3_FORN	==	EW5->EW5_FORN	.AND. IIF(EICLoja(),SW3->W3_FORLOJ == EW5->EW5_FORLOJ,.T.) .And. ;
								SW3->W3_POSICAO==	EW5->EW5_POSICA}
//
SW3->(dbSetOrder(8))
If SW3->(dbSeek(cFilEW5+EW5->EW5_PO_NUM+EW5->EW5_POSICA))
	If SW3->W3_FLUXO == "7"  // Não anuentes = "7"
		cPli := ""
		While eval(bSw3Valid)
			If SW3->W3_SEQ <> 1
				SW3->(dbSkip())
				Loop
			EndIf
			EW5->EW5_PGI_NU := SW3->W3_PGI_NUM
			SW5->(dbSetOrder(8))
			If SW5->(dbSeek(xFilial("SW5")+EW5->EW5_PGI_NU+EW5->EW5_PO_NUM+EW5->EW5_POSICA))
				SW5->(RecLock("SW5"),.F.)
				SW5->W5_INVANT := EW5->EW5_INVOIC
				SW5->(MSUnlock())
			EndIf
			Exit
		EndDo
	EndIf
EndIf
SW3->(dbSetOrder(cOrdSw3))
SW3->(dbGoTo(nSw3Recno))
Return(.T.)

*============================*
Static Function EV100GetItem()
*============================*
LOCAL oDlggetIt
Local cTitulo:= STR0038 //"Seleção de item"
Local oPanel

M->EW5_COD_I:=SPACE(LEN(WORK->WKCOD_I))
nOpca:=0
//
Define MsDialog oDlggetIt Title cTitulo From 0,0 TO 10,55 OF oMainWnd

   oPanel:= TPanel():New(0, 0, "", oDlgGetIt,, .F., .F.)
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   @ 02,01 SAY STR0039 of oPanel //Pproduto
   @ 02,04 MsGet M->EW5_COD_I F3 "SB1" Picture "@!" SIZE 60,08 of oPanel

ACTIVATE MsDialog oDlggetIt ON INIT ;
						Enchoicebar(oDlggetIt,{|| If(EV100VALID("ITEM"),(nOpca:=1,oDlggetIt:End()),)},;
						{|| nOpca:=0,oDlggetIt:End() } ) CENTERED
If nOpca == 0
	If	WORK->(EOF())
		WORK->(dbGoTop())
	EndIf
	Return .F.
EndIf
Return .T.
/*
Autor    : Igor CHiba
Data     : 10/06/2009
Objetivo : Enviar a integracao de inclusao da Invoice Antecipada para o AvInteg...tabela EI17
Funcao   : EV100ENVIN
*/
*============================*
Function  EV100ENVIN()
*============================*
Local cChave  :=""
Local cSQLChv :=""

IF LCAMBIO_EIC .AND. lEICFI07
   IF EMPTY(EW4->EW4_CTRERP)
      cChave:=XFILIAL('EW4')+EW4->EW4_HAWB+EW4->EW4_INVOIC+EW4->EW4_FORN
      cSQLChv:="EW4_FILIAL = '"+XFILIAL('EW4') +"' AND "+;
               "EW4_HAWB = '"  +EW4->EW4_HAWB  +"' AND "+;
               "EW4_INVOIC = '"+EW4->EW4_INVOIC+"' AND "+;
               "EW4_FORN = '"  +EW4->EW4_FORN  +"' "

      cMsgCtrl :=  	"ENVIADO INC"
		If FindFunction("EICINTEI17")
			EasyExRdm("EICINTEI17", 'I','INVANT',cChave,"AB",cSQLChv)      	
		EndIf	
   ELSE
      MsgInfo(STR0040, STR0002) //"Invoice já integrada, só poderá ser reenviada pela manutenção.", Atenção
   ENDIF
ELSE
   MsgInfo(STR0041, STR0002) //"Integração da Invoice Antecipada não ativada. Entre em contato com o suporte.", Atenção
ENDIF


Return .T.


/*
Autor    : Igor CHiba
Data     : 10/06/2009
Objetivo : Envia estorno da invoice antecipada
Funcao   : EV100ENVEX
*/
*============================*
Function  EV100ENVEX()
*============================*
Local cChave  :=""
Local cSQLChv :=""

IF LCAMBIO_EIC .AND. lEICFI07
   IF EMPTY(EW4->EW4_CTRERP)
      IF !EMPTY(EW4->EW4_TITERP)
         cChave:=XFILIAL('EW4')+EW4->EW4_HAWB+EW4->EW4_INVOIC+EW4->EW4_FORN
         cSQLChv:="EW4_FILIAL = '"+XFILIAL('EW4') +"' AND "+;
                  "EW4_HAWB = '"  +EW4->EW4_HAWB  +"' AND "+;
                  "EW4_INVOIC = '"+EW4->EW4_INVOIC+"' AND "+;
                  "EW4_FORN = '"  +EW4->EW4_FORN  +"' "

         cMsgCtrl := "ENVIADO EX"
			If FindFunction("EICINTEI17")
				EasyExRdm("EICINTEI17", 'E','INVANT',cChave,"EXC",cSQLChv)         	
			EndIf
      ELSE
         MsgInfo(STR0042, STR0002) //"Envio de estorno não permitido; título inexistente.", Atenção
      ENDIF
   ELSE
      MsgInfo(STR0043, STR0002) //"Envio de estorno não permitido; aguardando retorno da integração.", Atenção
   ENDIF
ELSE
   MsgInfo(STR0041, STR0002) //"Integração da Invoice Antecipada não ativada. Entre em contato com o suporte.", Atenção
ENDIF


Return .T.

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : WFS
Data/Hora  : 25/09/2014
*/
Static Function MenuDef()
Local aRotina:=	{{STR0044, "AxPesqui"  ,0,01},; // Pesquisar
                   {STR0045, "EV100MANUT",0,02},; //Visualizar
                   {STR0046, "EV100MANUT",0,03},; //Incluir
                   {STR0047, "EV100MANUT",0,04},; //Alterar
                   {STR0048, "EV100MANUT",0,05},; //Excluir
                   {STR0049, "EicReInvAn",0,02}} //Relatório
Private aRotAdic:= {}


Begin Sequence

   If EasyEntryPoint("EICEV100")
      ExecBlock("EICSI400",.F.,.F.,"AROTINA")
   EndIf

   If ValType(aRotAdic) == "A" .And. Len(aRotAdic) > 0
      AEval(aRotAdic, {|x| AAdd(aRotina, x)})
   EndIf

End Sequence
Return aRotina
