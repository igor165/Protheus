#INCLUDE 'MATA202.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'DBTREE.CH'
#INCLUDE 'APWIZARD.CH'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Descri��o � PLANO DE MELHORIA CONTINUA                                 ���
�������������������������������������������������������������������������Ĵ��
���ITEM PMC  � Responsavel              � Data         |BOPS:             ���
�������������������������������������������������������������������������Ĵ��
���      01  �                          �              |                  ���
���      02  �Patricia A. Salomao       �03/03/2006    | 00000094258      ���
���      03  �                          �              |                  ���
���      04  �                          �              |                  ���
���      05  �                          �              |                  ���
���      06  �                          �              |                  ���
���      07  �Patricia A. Salomao       �03/03/2006    | 00000094258      ���
���      08  �                          �              |                  ���
���      09  �                          �              |                  ���
���      10  �                          �              |                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � MATA202  � Autor � Rodrigo de A Sartorio � Data �01.03.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manuten��o na Pre-Estrutura dos produtos                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Gen�rico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function MatA202

//��������������������������������������������������������������Ŀ
//� Definicao dos status da pre-estrutura para controle de alcada�
//� ------------- Status da pre-estrutura sao: -------------     �
//� 1 - Em criacao					                             �
//� 2 - Pre-estrutura aprovada                                   �
//� 3 - Pre-estrutura rejeitada			                         �
//� 4 - Estrutura criada							             �
//� 5 - Submetida a aprovacao                                    �
//����������������������������������������������������������������
Local aCores := {{"GG_STATUS=='1'",'BR_AMARELO'},;
			{ "GG_STATUS=='2'",'BR_VERDE'},;
			{ "GG_STATUS=='3'",'BR_VERMELHO'},;
			{ "GG_STATUS=='4'",'BR_AZUL'},;
			{ "GG_STATUS=='5'",'BR_LARANJA'}}


//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais                                      �
//����������������������������������������������������������������
Local aAreaAnt  := GetArea()
Local lArqRev   := .F.
Local cFiltra   := ""
Local lContinua := .T.
Local aCorUsr   := {}
Local nCnt      := 0
//��������������������������������������������������������������Ŀ
//� Define Variaveis Private                                     �
//����������������������������������������������������������������
Private oTree
Private cCadastro  := OemToAnsi(STR0001)
Private cCodAtual  := Replicate('�', Len(SGG->GG_COD))
Private cValComp   := Replicate('�', Len(SGG->GG_COD)) + '�'
Private ldbTree    := .F.
Private cInd5      := ''
Private nNAlias    := 0
Private lRestEst   := SuperGetMv("MV_APRESTR",.F.,.F.)

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
Private aBkpARot := {}
Private aRotina := MenuDef(lRestEst)

// Tela com aviso de descontinua��o do programa
PCPMsgExp("MATA202", STR0125, "https://tdn.totvs.com/pages/viewpage.action?pageId=652584608", "https://tdn.totvs.com/pages/viewpage.action?pageId=445675647") // "Pr�-Estrutura - Nova Vers�o (PCPA135)"

//��������������������������������������������������������������Ŀ
//� Ponto de Entrada para adicionar cores na legenda             �
//����������������������������������������������������������������
If ExistBlock("MT202LEG")
	aCorUsr := ExecBlock("MT202LEG",.F.,.F., { 1 })
	If ValType(aCorUsr) <> "A"
		aCorUsr := {}
	EndIf
	For nCnt := 1 To Len(aCorUsr)
		Aadd( aCores , { aCorUsr[nCnt,1],aCorUsr[nCnt,2] } )
	Next nCnt
EndIf

dbSelectArea("SGG")
dbSetOrder(1)

If lContinua
	//��������������������������������������������������������������Ŀ
	//�MV_PAR01-Informacao Similar: Pre-Estrutura (Default)/Estrutura�
	//����������������������������������������������������������������
	Pergunte('MTA202', .F.)
	SetKey( VK_F12, { || Pergunte('MTA202', .T.) } )

	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	mBrowse( 6, 1,22,75,'SGG',,,,,,aCores)

	//�����������������������������������������������Ŀ
	//� Desativa tecla que aciona pergunta            �
	//�������������������������������������������������
	Set Key VK_F12 To

	//��������������������������������������������������������������Ŀ
	//� Recalcula os Niveis                                          �
	//����������������������������������������������������������������
	If GetMv('MV_NIVALTP') == 'S'
		MA320Nivel(NIL,NIL,NIL,NIL,.T.)
	EndIf
EndIf
//��������������������������������������������������������������Ŀ
//� Restaura Area de trabalho.                                   �
//����������������������������������������������������������������
RestArea(aAreaAnt)
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �  a202Proc  � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Processamento da Pre-Estrutura                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202Proc(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � True                                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function a202Proc(cAlias,nRecno,nOpcX)

Local oDlg
Local oUm
Local oQtdBase
Local oButPosic
Local cTitulo	 := STR0001 + ' - '
Local cProduto   := CriaVar('GG_COD')
Local cCodSim    := CriaVar('GG_COD')
Local cUm        := CriaVar('B1_UM')
Local nQtdBase   := CriaVar('B1_QB')
Local lRet       := .T.
Local lConfirma  := .F.
Local lAbandona  := .F.
Local lChkRej	 := .F.
Local lChkApr	 := .T.
Local aAreaAnt   := GetArea()
Local aUndo      := {}
Local lMudou     := .F.
Local aAltEstru  := {}
Local aObjects	 := {}
Local aPosObj 	 := {}
Local aInfo	 	 := {}
Local aSize	 	 := {}
Local aVldEng    := {3,4,5,8,10}

Local oPanel1
Local oPanel2
Local oPanel3
Local oPanelLeft
Local oPanelRight
Local oPanelB1
Local oPanelB2
Local oPanelB3
Local oPanelB4
Local oPanelB5
Local oPanelB6
Local oPanelB7
Local oChkRejei
Local oChkAprov
Local oButton2
Local oButton3
Local oButton4
Local oButton6
Local oButton7
Local oGroup
Local nValPre  := 1 // APROVAR -> 1 REJEITAR -> 2
Local cUsuario := RetCodUsr()
//��������������������������������������������������������������Ŀ
//� Variavel lPyme utilizada para Tratamento do Siga PyME        �
//����������������������������������������������������������������
Local lPyme:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)

//��������������������������������������������������������������Ŀ
//� VERIFICA AUTORIZACAO DO USUARIO                              �
//����������������������������������������������������������������
Private lCriaEstru:=SubStr( cAcesso,132,1 ) == "S"
Private lAprova   :=SubStr( cAcesso,131,1 ) == "S"
Private aDeletados := {}

Default lAutomacao := .F.
//�����������������������������������������������Ŀ
//� Desativa tecla que aciona pergunta            �
//�������������������������������������������������
Set Key VK_F12 To

//��������������������������������������������������������������Ŀ
//� Definicao dos status da pre-estrutura para controle de alcada�
//� ------------- Status da pre-estrutura sao: -------------     �
//� 1 - Em criacao					                             �
//� 2 - Pre-estrutura aprovada                                   �
//� 3 - Pre-estrutura rejeitada			                         �
//� 4 - Estrutura criada							             �
//� 5 - Submetida a aprovacao                                    �
//����������������������������������������������������������������

If !lRestEst
	If nOpcx == 4 .And. SGG->GG_STATUS # "1"
		Aviso(OemToAnsi(STR0036),OemToAnsi(STR0042),{"Ok"})
		RETURN
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Indica que usuario pode aprovar / rejeitar pre estrutura.    �
	//����������������������������������������������������������������
	If nOpcx == 8 .And. !lAprova
		Aviso(OemToAnsi(STR0036),OemToAnsi(STR0043),{"Ok"})
		RETURN
	EndIf

	//�������������������������������������������������������������������Ŀ
	//� Indica que usuario pode criar estrutura com base na pre-estrutura.�
	//���������������������������������������������������������������������
	If nOpcx == 9 .And. !lCriaEstru
		Aviso(OemToAnsi(STR0036),OemToAnsi(STR0044),{"Ok"})
		RETURN
	ElseIf nOpcx == 10 .And. !lCriaEstru
		Aviso(OemToAnsi(STR0036),OemToAnsi(STR0044),{"Ok"})
		RETURN
	EndIf
Else
	If aScan(aVldEng, {|x| x == nOpcx}) > 0 .And. Empty(UsrGrEng(cUsuario))
		Aviso(OemToAnsi("Acesso Restrito"),"O acesso e a utiliza��o desta rotina � destinada apenas aos usu�rios cadastrados como engenheiros.",{"Ok"})
		RETURN
	ElseIf nOpcX # 3 .And. aScan(aVldEng, {|x| x == nOpcx}) > 0 .And. !(GrpEng(cUsuario,SGG->GG_USUARIO))
		Aviso(OemToAnsi("Acesso Restrito"),"A realiza��o desta a��o � restrita aos usu�rios de um grupo de engenharia espec�fico.",{"Ok"})
		RETURN
    EndIf
	If nOpcx == 10 .And. SGG->GG_STATUS != "2"
		Aviso(OemToAnsi(STR0036),OemToAnsi(STR0085),{"Ok"})
		RETURN
	ElseIf nOpcx == 4 .And. SGG->GG_STATUS == "5"
		Aviso(OemToAnsi(STR0036),OemToAnsi(STR0084),{"Ok"})
		RETURN
	ElseIf nOpcx == 8 .And. SGG->GG_STATUS == "5"
		Aviso(OemToAnsi(STR0036),OemToAnsi(STR0087),{"Ok"})
		RETURN
	ElseIf nOpcx == 8 .And. SGG->GG_STATUS == "2"
		Aviso(OemToAnsi(STR0036),OemToAnsi(STR0095),{"Ok"})
		RETURN
	EndIf
EndIf

Private nIndex := 1
If nOpcX == 2
	cTitulo += OemToAnsi(STR0012)
ElseIf nOpcX == 3
	cTitulo += OemToAnsi(STR0010)
ElseIf nOpcX == 4
	ldbTree := .T.
	cTitulo += OemToAnsi(STR0009)
ElseIf nOpcX == 5
	ldbTree := .T.
	cTitulo += OemToAnsi(STR0011)
ElseIf nOpcX == 8
	ldbTree := .T.
	cTitulo += IIF(!lRestEst,OemToAnsi(STR0040),OemToAnsi(STR0088))
ElseIf nOpcX == 9 .Or. nOpcX == 10
	ldbTree := .T.
	cTitulo += OemToAnsi(STR0041)
EndIf

If nOpcX == 3
	cUm        := ''
	cProduto   := Space(Len(SGG->GG_COD))
	cCodAtual  := Replicate('�', Len(SGG->GG_COD))
	cValComp   := Replicate('�', Len(SGG->GG_COD)) + '�'
Else
	SB1->(dbSetOrder(1))
	If !SB1->(dbSeek(xFilial('SB1') + SGG->GG_COD, .F.))
		Help('  ', 1, 'NOFOUNDSB1')
		lRet := .F.
	EndIf
	cUm         := SB1->B1_UM
	nQtdBase	:= RetFldProd(SB1->B1_COD,"B1_QBP")
	cProduto    := SGG->GG_COD
	cCodAtual   := SGG->GG_COD
	cValComp    := SGG->GG_COD + '�'
EndIf

If lRet .And. (nOpcX == 4 .Or. nOpcX == 5) .And. IsProdProt(cProduto) .And. !IsInCallStack("DPRA340INT")
	Aviso(STR0036,STR0117,{"OK"}) //-- Prot�tipos podem ser manipulados somente atrav�s do m�dulo Desenvolvedor de Produtos (DPR).
	RETURN
EndIf

aSize := MsAdvSize()
aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

AADD(aObjects,{100,30,.T.,.F.})
AADD(aObjects,{100,100,.T.,.T.})
aPosObj := MsObjSize(aInfo, aObjects)

If !lAutomacao
	DEFINE MSDIALOG oDlg FROM  aSize[7],0 TO aSize[6],aSize[5]  TITLE cTitulo PIXEL
	oDlg:lMaximized := .T.

	@ 000,000 MSPANEL oPanel1 OF oDlg

	@ 001,005 GROUP oGroup TO 40,aPosObj[2,4] OF oPanel1  PIXEL
	oGroup:Align := CONTROL_ALIGN_ALLCLIENT
	@ 008, 038 SAY   OemToAnsi(STR0013) SIZE 037, 007 OF oPanel1 PIXEL
	@ 006, 060 MSGET cProduto           SIZE 105, 010 OF oPanel1 PIXEL PICTURE PesqPict('SGG','GG_COD') ;
		WHEN (!ldbTree .And. nOpcX==3) VALID A202Codigo(cProduto, @cUm,oUm,oDlg) ;
		F3 'SB1'

	@ 008, 180 SAY   OemToAnsi(STR0014) SIZE 040, 007 OF oPanel1 PIXEL
	@ 006, 205 MSGET oUm Var cUm        SIZE 013, 010 OF oPanel1 PIXEL ;
		WHEN .F.

	//@ 022, 007 SAY IIF(MV_PAR01 == 1,OemToAnsi(STR0015),OemToAnsi(STR0081)) SIZE 054, 007 OF oPanel1 PIXEL
	IF MV_PAR01 == 1
		@ 022, 007 SAY OemToAnsi(STR0015) SIZE 054, 007 OF oPanel1 PIXEL
	Else
		@ 022, 016 SAY OemToAnsi(STR0081) SIZE 054, 007 OF oPanel1 PIXEL
	EndIf

	@ 020, 060 MSGET cCodSim            SIZE 105, 010 OF oPanel1 PIXEL PICTURE PesqPict('SGG','GG_COD') ;
		WHEN !ldbTree VALID A202CodSim(cProduto, cCodSim, @aUndo,nOpcx,oDlg,oTree,@nQtdBase) ;
		F3 IIF(MV_PAR01 == 1,'SGG','SG1')

	@ 022, 180 SAY  RetTitle("B1_QBP")SIZE 053,007 Of oPanel1 PIXEL
	@ 020, 215 MSGET oQtdBase Var nQtdBase SIZE 050, 010 OF oPanel1 PIXEL PICTURE PesqPictQt("B1_QBP",20);
	VALID A202QBase(nQtdBase,nOpcX,cProduto,cCodSim,oTree,oDlg) WHEN �(nOpcx <> 2 .And. nOpcx <> 5 .And. nOpcx <> 6)


	@ 000,000 MSPANEL oPanel2 OF oDlg
	oTree := DbTree():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-25,aPosObj[2,4], oPanel2,,,.T.)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT

	@ 000,000 MSPANEL oPanel3 OF oDlg

	@ 000,000 MSPANEL oPanelLeft SIZE __DlgWidth(oMainWnd)/2,0 OF oPanel3
	oPanelLeft:Align := CONTROL_ALIGN_ALLCLIENT

	If !lPyme .and. nOpcx == 8
		@ 000,000 MSPANEL oPanelB1 SIZE 140,40 OF oPanelLeft
		lChkRej := (nValPre==2)
		lChkApr := !lChkRej

		IF !lRestEst
			oChkRejei :=TCheckBox():New( 000, 000, STR0039, {|| lChkRej}, oPanelB1, 70,15, ,{|| nValPre := 2,lChkRej := .T.,lChkApr := .F.,oChkAprov:Refresh()})
			oChkRejei:Align := CONTROL_ALIGN_RIGHT

			oChkAprov :=TCheckBox():New( 000, 000, STR0038, {|| lChkApr}, oPanelB1, 70,15, ,{|| nValPre := 1,lChkRej := .F.,lChkApr := .T.,oChkRejei:Refresh()})
			oChkAprov:Align := CONTROL_ALIGN_RIGHT
		Else
			oChkRejei :=TCheckBox():New( 000, 000, STR0093, {|| lChkRej}, oPanelB1, 70,15, ,{|| nValPre := 2,lChkRej := .T.,lChkApr := .F.,oChkAprov:Refresh()})
			oChkRejei:Align := CONTROL_ALIGN_RIGHT

			oChkAprov :=TCheckBox():New( 000, 000, STR0094, {|| lChkApr}, oPanelB1, 70,15, ,{|| nValPre := 1,lChkRej := .F.,lChkApr := .T.,oChkRejei:Refresh()})
			oChkAprov:Align := CONTROL_ALIGN_RIGHT
		EndIf
		oPanelB1:Align := CONTROL_ALIGN_RIGHT
	Endif

	@ 000,000 MSPANEL oPanelRight SIZE __DlgWidth(oMainWnd)/2,0 OF oPanel3
	oPanelRight:Align := CONTROL_ALIGN_RIGHT

	//������������������������������������������������������������������������Ŀ
	//� Defini��o dos Bot�es Utilizados                                        �
	//��������������������������������������������������������������������������
	//-- Inclus�o
	@ 000,000 MSPANEL oPanelB2 SIZE 30,40 OF oPanelRight
	If nOpcX == 2 .Or. nOpcX == 5 .Or. nOpcx == 8 .Or. IIF(!lRestEst, nOpcx == 9, nOpcx == 10)
		DEFINE SBUTTON oButton2 FROM 000,000  TYPE 4 DISABLE OF oPanelB2 //-- Desabilita Inlus�o
	Else
		DEFINE SBUTTON oButton2 FROM 000,000  TYPE 4 ENABLE OF oPanelB2 ;
			ACTION If(!ldbTree .And. nOpcX < 4, .T., Ma202Edita(nOpcX, oTree:GetCargo(), oTree, 3, @aUndo, @lMudou, @aAltEstru))
	EndIf

	@ 000,000 MSPANEL oPanelB3 SIZE 30,40 OF oPanelRight
	//-- Altera��o
	DEFINE SBUTTON oButton3 FROM 000,000 TYPE 11 ENABLE OF oPanelB3 ;
		ACTION If(!ldbTree .And. nOpcX < 4, .T., Ma202Edita(nOpcX, oTree:GetCargo(), oTree, 4, @aUndo, @lMudou, @aAltEstru))

	@ 000,000 MSPANEL oPanelB4 SIZE 30,40 OF oPanelRight
	//-- Exclus�o
	If nOpcX == 2 .Or. nOpcX == 5 .Or. nOpcx == 8 .Or. IIF(!lRestEst, nOpcx == 9, nOpcx == 10)
		DEFINE SBUTTON oButton4 FROM 000,000  TYPE 3 DISABLE OF oPanelB4 //-- Desabilita Exclus�o
	Else
		DEFINE SBUTTON oButton4 FROM 000,000  TYPE 3 ENABLE OF oPanelB4 ;
			ACTION If(!ldbTree .And. nOpcX < 4, .T., Ma202Edita(nOpcX, oTree:GetCargo(), oTree, 5, @aUndo, @lMudou, @aAltEstru))
	EndIf

	@ 000,000 MSPANEL oPanelB5 SIZE 30,40 OF oPanelRight
	//-- Pesquisa e Posiciona
	DEFINE SBUTTON oButPosic FROM 000,000 TYPE 15 ENABLE OF oPanelB5 ;
		ACTION If(!ldbTree .And. nOpcX < 4, .T., Ma202Posic(nOpcX, oTree:GetCargo(), oTree))
		oButPosic:cToolTip:=OemToAnsi(STR0016)
		oButPosic:cTitle := OemToAnsi(STR0002) // 'Pesquisar'

	@ 000,000 MSPANEL oPanelB6 SIZE 30,40 OF oPanelRight
	//-- Confirma
	If nOpcX == 5
		DEFINE SBUTTON oButton6 FROM 000,000 TYPE 1 ENABLE OF oPanelB6 ;
			ACTION (lConfirma:=.T., Ma202Del(cCodAtual), Ma202Fecha(oDlg, oTree, nOpcX, .T., cUm, cProduto,.T., aAltEstru,nValPre,nQtdBase))
	Else
		DEFINE SBUTTON oButton6 FROM 000,000 TYPE 1 ENABLE OF oPanelB6 ;
			ACTION (lConfirma:=.T., If(Btn202Ok(aUndo, cProduto) .And. ldbTree, (Ma202Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cProduto, .T., aAltEstru,nValPre,nQtdBase),IIF(SuperGetMv("MV_APRESTR",.F.,.F.),A202DelSGN(cCodAtual),"")), .T.))
	EndIf

	@ 000,000 MSPANEL oPanelB7 SIZE 30,40 OF oPanelRight

	//-- Abandona
	DEFINE SBUTTON oButton7 FROM 000,000  TYPE 2 ENABLE OF oPanelB7 ;
		ACTION (lAbandona := .T., Ma202Undo(aUndo), Ma202Fecha(oDlg, oTree, nOpcX, .F., cUm, cProduto, .F., aAltEstru,nValPre,nQtdBase))

	oPanelB2:Align := CONTROL_ALIGN_RIGHT
	oPanelB3:Align := CONTROL_ALIGN_RIGHT
	oPanelB4:Align := CONTROL_ALIGN_RIGHT
	oPanelB5:Align := CONTROL_ALIGN_RIGHT
	oPanelB6:Align := CONTROL_ALIGN_RIGHT
	oPanelB7:Align := CONTROL_ALIGN_RIGHT

	oButton2:Align := CONTROL_ALIGN_RIGHT
	oButton3:Align := CONTROL_ALIGN_RIGHT
	oButton4:Align := CONTROL_ALIGN_RIGHT
	oButPosic:Align := CONTROL_ALIGN_RIGHT
	oButton6:Align := CONTROL_ALIGN_RIGHT
	oButton7:Align := CONTROL_ALIGN_RIGHT

	ACTIVATE MSDIALOG oDlg ON INIT ( Ma202Monta(oTree, oDlg, cCodAtual, cCodSim,nOpcX),;
									AlignObject(oDlg,{oPanel1,oPanel2,oPanel3},1,2,{070,,020})) ;
							VALID If(nOpcX>2.And.nOpcX<=5.And.!(lConfirma.Or.lAbandona), (Ma202Undo(aUndo), Ma202Fecha(,, nOpcX, .F., cUm, cProduto, .F., aAltEstru,nValPre,nQtdBase)), .T.)
EndIf
//-- Reinicializa Variaveis
cInd5     := ''
ldbTree   := .F.
cValComp  := Replicate('�', Len(SGG->GG_COD)) + '�'
cCodAtual := Replicate('�', Len(SGG->GG_COD))

RestArea(aAreaAnt)

//�����������������������������������������������Ŀ
//� Ativa tecla que aciona pergunta.              �
//�������������������������������������������������
SetKey( VK_F12, { || Pergunte('MTA202', .T.) } )

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Ma202Monta � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Montagem do Arquivo Temporario para o Tree(Func.Recurssiva)���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ma202Monta(ExpO1, ExpO2, ExpC1, ExpN1, ExpC2)              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � False se o Codigo do Produto nao existir, e True em C.C.   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto Tree                                        ���
���          � ExpO2 = Objeto Dlg                                         ���
���          � ExpC1 = Codigo do Produto                                  ���
���          � ExpN1 = Numero da Op��o Escolhida                          ���
���          � ExpC2 = Cargo do Produto no Tree                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Ma202Monta(oTree, oDlg, cProduto, cCodSim,nOpcX, cCargo, cTRTPai)

Local nRecAnt    := 0
Local cComp      := ''
Local cPrompt    := ''
Local cFolderA   := 'FOLDER5'
Local cFolderB   := 'FOLDER6'
Local nRecCargo  := 0
Local dValIni    := CtoD('  /  /  ')
Local dValFim    := CtoD('  /  /  ')
Local nQuant     := 0
Static nNivelTr  := 0

Default lAutomacao := .F.

nNivelTr += 1
nOpcX := If(nOpcX==Nil,0,nOpcX)

If !ldbTree .And. nOpcX < 4
	if nOpcx == 2
		ldbTree   := .T.
		Ma202Monta(oTree, oDlg, cProduto, '',nOpcX)
		Return .T.
	Else
		oDlg:SetFocus()
		Return .F.
	EndIf
EndIf

//-- Posiciona no SB1
cPrompt := cProduto + Space(200)
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial('SB1') + cProduto, .F.))
	cPrompt := AllTrim(cProduto) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(cProduto))+Space(200)
EndIf

SGG->(dbSetOrder(1))
If nOpcX == 3 .And. cProduto # Replicate('�', Len(SGG->GG_COD)) .And. Empty(cCodSim)

	//-- Cria��o de uma nova pre-estrutura
	DBADDTREE oTree PROMPT A202Prompt(cPrompt, "") OPENED RESOURCE cFolderA, cFolderB CARGO cProduto + Space(LEN(SGG->GG_TRT)) + cProduto + '000000000' + '000000000' + 'NOVO'
	DBENDTREE oTree
	oTree:Refresh()
	oTree:SetFocus()
	Return .T.

ElseIf !SGG->(dbSeek(xFilial('SGG') + cProduto, .F.))
	If ldbTree		
		oTree:Refresh()
		oTree:SetFocus()
	Else
		If !lAutomacao
			oDlg:SetFocus()
		EndIf
	EndIf
	Return .F.
EndIf

cTRTPai := If(cTRTPai==Nil,SGG->GG_TRT,cTRTPai)

dValIni := SGG->GG_INI
dValFim := SGG->GG_FIM
If cCargo == Nil
	cCargo := SGG->GG_COD + cTRTPai + SGG->GG_COMP + StrZero(SGG->(Recno()), 9) + StrZero(nIndex ++, 9) + 'CODI'
ElseIf (nRecCargo := Val(SubStr(cCargo,Len(SGG->GG_COD + SGG->GG_TRT + SGG->GG_COMP) + 1, 9))) > 0
	nRecAnt := SGG->(Recno())
	SGG->(dbGoto(nRecCargo))
	dValIni := SGG->GG_INI
	dValFim := SGG->GG_FIM
	nQuant  := SGG->GG_QUANT
	SGG->(dbGoto(nRecAnt))
EndIf

//-- Define as Pastas a serem usadas
cFolderA := 'FOLDER5'
cFolderB := 'FOLDER6'
If Right(cCargo, 4) == 'COMP' .And. ;
	(dDataBase < dValIni .Or. dDataBase > dValFim)
	cFolderA := 'FOLDER7'
	cFolderB := 'FOLDER8'
EndIf


//-- Adiciona o Pai na Pre-Estrutura
If !lAutomacao
	DBADDTREE oTree PROMPT A202Prompt(cPrompt, cCargo, nQuant) OPENED RESOURCE cFolderA, cFolderB CARGO cCargo
EndIf

Do While !SGG->(Eof()) .And. SGG->GG_FILIAL+SGG->GG_COD == xFilial("SGG")+cProduto

	nRecAnt := SGG->(Recno())
	cComp   := SGG->GG_COMP
	nQuant  := SGG->GG_QUANT
	cCargo  := SGG->GG_COD + SGG->GG_TRT + SGG->GG_COMP + StrZero(SGG->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'

	//-- Define as Pastas a serem usadas
	cFolderA := 'FOLDER5'
	cFolderB := 'FOLDER6'
	If dDataBase < SGG->GG_INI .Or. dDataBase > SGG->GG_FIM
		cFolderA := 'FOLDER7'
		cFolderB := 'FOLDER8'
	EndIf

	//-- Posiciona no SB1
	cPrompt := cComp + Space(200)
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial('SB1') + cComp, .F.))
		cPrompt := AllTrim(cComp) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(cComp))+Space(200)
	EndIf
	If SGG->(dbSeek(xFilial('SGG') + SGG->GG_COMP, .F.))
		//-- Adiciona um Nivel a Pre-Estrutura
		Ma202Monta(oTree, oDlg, SGG->GG_COD, '',If(nOpcX==3,0,nOpcX), cCargo, cTRTPai)
	Else
		//-- Adiciona um Componente a Pre-Estrutura
		DBADDITEM oTree PROMPT A202Prompt(cPrompt, cCargo, nQuant) RESOURCE cFolderA CARGO cCargo
	EndIf

	SGG->(dbGoto(nRecAnt))
	SGG->(dbSkip())
EndDo

If !lAutomacao
	DBENDTREE oTree

	If ldbTree
		If nNivelTr == 1
			oTree:TreeSeek(oTree:GetCargo())
			oTree:Refresh()
			oTree:SetFocus()
		EndIf
	Else
		oDlg:SetFocus()
	EndIf
EndIf
nNivelTr -= 1

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Ma202ATree � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Adiciona Componentes ao Tree existente (Func.Recurssiva)   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ma202ATree(ExpO1, ExpO2, ExpC1, ExpN1, ExpC2)              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � False se o Codigo do Produto nao existir, e True em C.C.   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto Tree                                        ���
���          � ExpO2 = Objeto Dlg                                         ���
���          � ExpC1 = Codigo do Produto                                  ���
���          � ExpN1 = Numero da Op��o Escolhida                          ���
���          � ExpC2 = Cargo do Produto no Tree                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Ma202ATree(oTree, cProduto, cCargo, cTRTPai)

Local aAreaAnt   := GetArea()
Local nRecAnt    := 0
Local cComp      := ''
Local cPrompt    := ''
Local cFolderA   := 'FOLDER5'
Local cFolderB   := 'FOLDER6'
Local dValIni    := CtoD('  /  /  ')
Local dValFim    := CtoD('  /  /  ')
Local nRecCargo  := 0
Local cCargoPai  := ''
Local nQuant     := 0

Default lAutomacao := .F.
cTRTPai := If(cTRTPai==Nil,SGG->GG_TRT,cTRTPai)

dValIni := SGG->GG_INI
dValFim := SGG->GG_FIM
nQuant  := SGG->GG_QUANT
If cCargo == Nil
	cCargo := SGG->GG_COD + cTRTPai + SGG->GG_COMP + StrZero(SGG->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'
ElseIf (nRecCargo := Val(SubStr(cCargo,Len(SGG->GG_COD + SGG->GG_TRT + SGG->GG_COMP) + 1, 9))) > 0
	nRecAnt := SGG->(Recno())
	SGG->(dbGoto(nRecCargo))
	dValIni := SGG->GG_INI
	dValFim := SGG->GG_FIM
	nQuant  := SGG->GG_QUANT
	SGG->(dbGoto(nRecAnt))
EndIf

//-- Define as Pastas a serem usadas
cFolderA := 'FOLDER5'
cFolderB := 'FOLDER6'
If Right(cCargo, 4) == 'COMP' .And. ;
	(dDataBase < dValIni .Or. dDataBase > dValFim)
	cFolderA := 'FOLDER7'
	cFolderB := 'FOLDER8'
EndIf

//-- Posiciona no SB1
cPrompt := cProduto + Space(33)
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial('SB1') + cProduto, .F.))
	cPrompt := AllTrim(cProduto) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(cProduto))
EndIf
//-- Adiciona o Componente na Pre-Estrutura
If !lAutomacao
	oTree:AddItem(A202Prompt(cPrompt, cCargo,nQuant), cCargo, cFolderA, cFolderB,,, 2)
	oTree:TreeSeek(cCargo)
EndIf
cCargoPai := cCargo

//-- Se o Componente for Pai, Adiciona sua Pre-Estrutura
SGG->(dbSetOrder(1))
If SGG->(dbSeek(xFilial('SGG') + cProduto, .F.))
	Do While !SGG->(Eof()) .And. SGG->GG_FILIAL+SGG->GG_COD == xFilial("SGG")+cProduto
		nRecAnt := SGG->(Recno())
		cComp   := SGG->GG_COMP
		cCargo  := SGG->GG_COD + cTRTPai + SGG->GG_COMP + StrZero(SGG->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'
		nQuant  := SGG->GG_QUANT
		cFolderA := 'FOLDER5'
		cFolderB := 'FOLDER6'
		If dDataBase < SGG->GG_INI .Or. dDataBase > SGG->GG_FIM
			cFolderA := 'FOLDER7'
			cFolderB := 'FOLDER8'
		EndIf

		//-- Posiciona no SB1
		cPrompt := cComp + Space(33)
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial('SB1') + cComp, .F.))
			cPrompt := AllTrim(cComp) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(cComp))
		EndIf
		If SGG->(dbSeek(xFilial('SGG') + SGG->GG_COMP, .F.))
			//-- Adiciona um Nivel a Pre-Estrutura
			Ma202ATree(oTree, SGG->GG_COD, cCargo, cTRTPai)
			oTree:TreeSeek(cCargoPai)
		Else
			//-- Adiciona um Componente a Pre-Estrutura
			oTree:AddItem(A202Prompt(cPrompt, cCargo, nQuant), cCargo, cFolderA, cFolderB,,, 2)
		EndIf

		SGG->(dbGoto(nRecAnt))
		SGG->(dbSkip())
	EndDo
EndIf

If !lAutomacao
	oTree:Refresh()
	oTree:SetFocus()
EndIf
RestArea(aAreaAnt)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Ma202Edita � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Edi��o dos Itens da Pre-Estrutura                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ma202Edita(ExpN1, ExpC1, ExpO1, ExpN2, ExpA1)              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � True                                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Op��o da Edi��o                                    ���
���          � ExpC1 = Chave do Registro                                  ���
���          � ExpO1 = Objeto Tree                                        ���
���          � ExpN2 = Op��o escolhida no Bot�o                           ���
���          � ExpA1 = Array com os Recnos dos Componentes Incl/Excl      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Ma202Edita(nOpcX, cCargo, oTree, nOpcY, aUndo, lMudou, aAltEstru)

Local aAreaAnt   := GetArea()
Local aCampos    := {}
Local aAreaSGG   := SGG->(GetArea())
Local nRecno	 := 0
Local nPos       := 0
Local nX         := 0
Local lInclui    := (nOpcY==3 .And. nOpcX#2)
Local lAltera    := (nOpcY==4 .And. nOpcX#2)
Local lExclui    := (nOpcY==5 .And. nOpcX#2)
Local lRet       := .T.
Local cTipo      := ''
Local nUndoRecno := 0
Local cFolderA   := 'FOLDER5'
Local cFolderB   := 'FOLDER6'
Local aDescend   := {}
Local cCargoPai  := ''
Local cPrompt    := ""
Local cProdNAlt	 := ""
Local aTamQtde   := TamSX3("G1_QUANT")

//-- Variaveis utilizadas nos Ax's
Private aAlter     := {}
Private aAcho      := {}
Private cDelFunc   := 'a202TudoOk("E")'
Private lDelFunc   := .T.
Private cCodPai    := ''
Private aEndEstrut := {}

Default lAutomacao := .F.

If !lAutomacao
	cTreeCargo := oTree:GetCargo()
EndIf

aUndo := If(aUndo==Nil,{},aUndo)

//-- Variaveis do Componente Tree referentes ao registro Atual
nRecno := Val(SubStr(cCargo,Len(SGG->GG_COD + SGG->GG_TRT + SGG->GG_COMP) + 1, 9))
cTipo  := Right(cCargo,4)

//��������������������������������������������������������������Ŀ
//� Deleta do Array aAcho os campos que n�o devem aparecer       �
//����������������������������������������������������������������
a202Fields(@aAcho)
If (nPos := aScan(aAcho, {|x| 'GG_FILIAL' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'GG_COD'    $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'GG_NIV'    $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'GG_NIVINV' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'GG_OK' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'GG_STATUS' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'GG_USUARIO' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'GG_LISTA' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'GG_LOCCONS' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'GG_FANTASM' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If !lInclui
	If (nPos := aScan(aAcho, {|x| 'GG_DESC' $ Upper(x)})) > 0
		//aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Deleta do Array aAlter os campos que n�o devem ser alterados �
//����������������������������������������������������������������
aAlter := aClone(aAcho)
If lAltera .And. (nPos := aScan(aAlter, {|x| 'GG_COMP' $ Upper(x)})) > 0
	aDel(aAlter, nPos); aSize(aAlter, Len(aAlter)-1)
EndIf

//������������������������������������������������������������������������Ŀ
//�Posiciona o SGG no registro a ser editado                               �
//��������������������������������������������������������������������������
If cTipo # 'NOVO' .And. nRecno <= 0
	Help(' ', 1, 'CODNEXIST')
	RestArea(aAreaAnt)
	Return .F.
EndIf

dbSelectArea('SGG')
dbSetOrder(1)
dbGoto(If(nRecno>0,nRecno,aAreaSGG[3]))

If lRet .And. FindFunction("RodaNewPCP") .And. RodaNewPCP() .And. lAltera .And. (!Empty(SGG->GG_LISTA) .Or. !Empty(SGG->GG_FANTASM) .Or. !Empty(SGG->GG_LOCCONS))
	Aviso(STR0120,STR0122,{"Ok"}) //"Aviso" // "Esse componente possui informa��es exclusivas do novo programa de cadastro de pr�-estrutura. A altera��o ser� permitida apenas no PCPA135."
	Return .F.
EndIf

//������������������������������������������������������������������������Ŀ
//�N�o edita o Pai                                                         �
//��������������������������������������������������������������������������
If !lInclui .And. (cTipo == 'CODI' .Or. cTipo == 'NOVO')
	Aviso(STR0120,STR0119,{"Ok"},1,STR0121)  //"Aviso" #"N�o � possivel alterar o Produto Pai." # "Produto n�o passivel de altera��o"
	RestArea(aAreaAnt)
	Return .F.
EndIf

cCodPai   := If(nRecno>0,If(cTipo=='CODI',SGG->GG_COD,SGG->GG_COMP),cCodAtual)
cCargoPai := cTreeCargo

If nOpcX == 3 .Or. nOpcX == 4	//-- Inclui ou Altera
	aDescend := {}
	If !lAutomacao
		a202Descen(@cValComp, @aDescend, oTree)
	EndIf
	If lInclui
		//������������������������������������������������������������������������Ŀ
		//�Comando utilizado para habilitar chamada do PE generico em cada chamada �
		//��������������������������������������������������������������������������
		SetStartMod(.T.)
		aRotina := ACLONE(aBkpARot)
		If AxInclui(Alias(), Recno(), 3, aAcho,, aAlter, 'a202TudoOK("I")') == 1
			aAdd(aDescend, GG_COMP)
			lMudou := .T.
			Begin Transaction
			//��������������������������������������������������������������Ŀ
			//� Definicao dos status da pre-estrutura para controle de alcada�
			//� ------------- Status da pre-estrutura sao: -------------     �
			//� 1 - Em criacao					                             �
			//� 2 - Pre-estrutura aprovada                                   �
			//� 3 - Pre-estrutura rejeitada			                         �
			//� 4 - Estrutura criada							             �
			//� 5 - Submetida a aprovacao                                    �
			//����������������������������������������������������������������
				RecLock('SGG', .F.)
				Replace GG_COD     With cCodPai
				Replace GG_STATUS  With "1"
				Replace GG_USUARIO With IIF(!lRestEst,Subs(cUsuario,7,6),RetCodUsr())
				MsUnlock()
			End Transaction
			If aScan(aUndo, {|x| x[1]==Recno()}) == 0
				aAdd(aUndo, {Recno(), 1}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
			EndIf
			//-- Alimenta Array com a Descend�ncia dos Produtos Incluidos
			If Len(aDescend) > 0
				For nX := 1 to Len(aDescend)
					If aScan(aAltEstru, aDescend[nX]) == 0
						aAdd(aAltEstru, aDescend[nX])
					EndIf
				Next nX
			EndIf
			If cTipo == 'NOVO'
				oTree:DelItem()
				Ma202ATree(oTree, SGG->GG_COD, SGG->GG_COD + SGG->GG_TRT + SGG->GG_COMP + StrZero(SGG->(Recno()),9) + StrZero(nIndex ++, 9) + 'CODI')
			Else
				Ma202ATree(oTree, SGG->GG_COMP, SGG->GG_COD + SGG->GG_TRT + SGG->GG_COMP + StrZero(SGG->(Recno()),9) + StrZero(nIndex ++, 9) + 'COMP')
			EndIf
			oTree:TreeSeek(cCargoPai)
		EndIf
	ElseIf lAltera
		//�������������������������������������Ŀ
		//� Guarda o Status inicial do Registro �
		//���������������������������������������
		aCampos := {}
		If aScan(aUndo, {|x| x[1]==Recno()}) == 0
			For nX := 1 To FCount()
				aAdd(aCampos, FieldGet(nX))
			Next nX
		EndIf
		//������������������������������������������������������������������������Ŀ
		//�Comando utilizado para habilitar chamada do PE generico em cada chamada �
		//��������������������������������������������������������������������������
		SetStartMod(.T.)
		aRotina := ACLONE(aBkpARot)
		If !lAutomacao
			lAtuSx := AxAltera(Alias(), Recno(), 4, aAcho, aAlter,,, 'a202TudoOk("A")') == 1
		Else
			lAtuSx := .T.
		EndIf

		If lAtuSx

			If aScan(aUndo, {|x| x[1]==Recno()}) == 0
				aAdd(aUndo, {Recno(), 3, aCampos}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
			EndIf

			//-- Alimenta Array com a Descend�ncia dos Produtos Alterados
			If Len(aDescend) > 0
				For nX := 1 to Len(aDescend)
					If aScan(aAltEstru, aDescend[nX]) == 0
						aAdd(aAltEstru, aDescend[nX])
					EndIf
				Next nX
			EndIf

			//-- Remonta o Prompt do Tree
			SB1->(dbSeek(xFilial("SB1")+SGG->GG_COMP))
			If !lAutomacao
				dbSelectArea(oTree:cArqTree)
				RecLock((oTree:cArqTree), .F.)
				Replace T_CARGO With (SGG->GG_COD+SGG->GG_TRT+SGG->GG_COMP+StrZero(SGG->(Recno()),9)+StrZero(nIndex ++, 9)+'COMP')
				MsUnlock()
				cCargo  := T_CARGO
				
				cPrompt := AllTrim(SGG->GG_COMP) + " - " + AllTrim(SB1->B1_DESC)
				cPrompt := AllTrim(A202Prompt(cPrompt,cCargo, SGG->GG_QUANT))
				oTree:ChangePrompt(cPrompt, cCargo)

				//-- Define as Pastas a serem usadas
				cFolderA := 'FOLDER5'
				cFolderB := 'FOLDER6'
				If Right(oTree:GetCargo(), 4) == 'COMP' .And. ;
					(dDataBase < SGG->GG_INI .Or. dDataBase > SGG->GG_FIM)
					cFolderA := 'FOLDER7'
					cFolderB := 'FOLDER8'
				EndIf
				oTree:ChangeBMP(cFolderA, cFolderB)
				EndIf
			//-- Retorna status para Em Criacao
			If SuperGetMV("MV_APRESTR",.F.,.F.)
				nRecno := SGG->(Recno())
				cProdNAlt := SGG->GG_COD
				SGG->(dbSetOrder(1))
				SGG->(dbSeek(xFilial("SGG")+cProdNAlt))
				While !SGG->(EOF()) .And. SGG->(GG_FILIAL+GG_COD) == xFilial("SGG")+cProdNAlt
					RecLock("SGG",.F.)
					SGG->GG_STATUS := '1'
					SGG->(MsUnLock())
					If aScan(aUndo, {|x| x[1] == Recno()}) == 0
						aCampos := {}
						For nX := 1 To FCount()
							aAdd(aCampos, FieldGet(nX))
						Next nX
						aAdd(aUndo,{Recno(), 3, aCampos}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
					EndIf
					SGG->(dbSkip())
				End
				SGG->(dbGoTo(nRecno))
			EndIf
		EndIf
	ElseIf lExclui
		a202Desc(SGG->GG_COMP)
		nUndoRecno := Recno()
		//������������������������������������������������������������������������Ŀ
		//�Comando utilizado para habilitar chamada do PE generico em cada chamada �
		//��������������������������������������������������������������������������
		SetStartMod(.T.)
		aRotina := ACLONE(aBkpARot)
		If AxDeleta(Alias(), Recno(), 5) == 2
			If lDelFunc
				lMudou := .T.
				nPos:=aScan(aUndo, {|x| x[1]==nUndoRecno})
				If nPos == 0
					aAdd(aUndo, {nUndoRecno, 2}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
				EndIf
				//-- Alimenta Array com a Descend�ncia dos Produtos Alterados
				If Len(aDescend) > 0
					For nX := 1 to Len(aDescend)
						If aScan(aAltEstru, aDescend[nX]) == 0
							aAdd(aAltEstru, aDescend[nX])
						EndIf
					Next nX
				EndIf
				oTree:DelItem()
				oTree:Refresh()
				oTree:SetFocus()
			EndIf
		EndIf
	EndIf

ElseIf nOpcX == 2 .Or. nOpcX == 5 .Or. nOpcx == 8 .Or. IIF(!lRestEst, nOpcx == 9, nOpcx == 10)//-- Visualiza ou Exclui
	aRotina := ACLONE(aBkpARot)
	AxVisual(Alias(), Recno(), 2, aAcho)
EndIf


//���������������������������������������������������������������������Ŀ
//� Efetua o EndEstrut2 apos o End Transaction                          �
//�����������������������������������������������������������������������
If Len(aEndEstrut) > 0
	For nX := 1 to Len(aEndEstrut)
		FimEstrut2(aEndEstrut[nX,1],aEndEstrut[nX,2])
	Next nX
	aEndEstrut := {}
EndIf

//��������������������������������������������������������������Ŀ
//� Restaura Area de trabalho.                                   �
//����������������������������������������������������������������
RestArea(aAreaAnt)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���                                                                       ���
���                                                                       ���
���                   ROTINAS DE CRITICA DE CAMPOS                        ���
���                                                                       ���
���                                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � a202Codigo � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o do C�digo do Produto na Pre-Estrutura            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202Codigo(ExpC1, ExpC2, ExpC3)                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � True para C�digos Validos e False para C�digos Inv�lidos   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = C�digo a ser Validado                              ���
���          � ExpC2 = Unidade de Medida a ser Atualizada                 ���
���          � ExpC3 = Numero da Revis�o a ser atualizado                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function A202Codigo(cProduto, cUm,oUm,oDlg)

Local aAreaAnt   := GetArea()
Local aAreaSB1   := SB1->(GetArea())
Local aAreaSGG   := SGG->(GetArea())
Local cSeek      := ''
Local lRet       := .T.

SB1->(dbSetOrder(1))
If !SB1->(dbSeek(xFilial('SB1') + cProduto, .F.))
	Help(' ',1, 'NOFOUNDSB1')
	lRet := .F.
Else
	cUm:= SB1->B1_UM
	If oUm # Nil
		oUm:Refresh()
	EndIf
EndIf

If lRet .And. !ldbTree
	If oDlg # Nil
		oDlg:Refresh()
	EndIf
	SGG->(dbSetOrder(1))
	If SGG->(dbSeek(xFilial('SGG') + cProduto, .F.))
		Help(' ',1, 'CODEXIST')
		lRet := .F.
	EndIf
	SGG->(dbSetOrder(2))
	If lRet .And. SGG->(dbSeek(cSeek := xFilial('SGG') + cProduto, .F.))
		Do While !SGG->(Eof()) .And. SGG->GG_FILIAL + SGG->GG_COMP == cSeek
			If SGG->GG_QUANT < 0 .And. !GetMV('MV_NEGESTR')
				Help(' ',1,'A202NAOINC')
				lRet := .F.
				Exit
			EndIf
			SGG->(dbSkip())
		EndDo
	EndIf
	If lRet
		If ExistBlock("MT202PAI")
			lRet:=ExecBlock("MT202PAI",.F.,.F.,cProduto)
		EndIf
	EndIf
EndIf

If lRet .And. IsProdProt(cProduto) .And. !IsInCallStack("DPRA340INT")
	Aviso(STR0036,STR0117,{"OK"}) //-- Prot�tipos podem ser manipulados somente atrav�s do m�dulo Desenvolvedor de Produtos (DPR).
	lRet := .F.
EndIf

// Restaura Area de trabalho.
RestArea(aAreaSGG)
RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � a202CodSim � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida Pre-Estrutura Similar                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � a202CodSim(ExpC1, ExpC2)                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � True se a Pre-Estrutura Silinar for Validada, False se n�o.���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = C�digo do Produto                                  ���
���          � ExpC2 = C�digo do Produto Similar                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function A202CodSim(cProduto, cCodSim, aUndo,nOpcx,oDlg,oTree,nQtdBase)

Local aAreaAnt   := GetArea()
Local aAreaSB1   := SB1->(GetArea())
Local aAreaSGG   := SGG->(GetArea())
Local aAreaSG1   := SG1->(GetArea())
Local cNomeArq   := ''
Local cAliasSTRU := IIF(MV_PAR01 ==1 ,"SGG","SG1")
Local oTempTable := NIL
Private nEstru     := 0

If !Empty(cCodSim) .And. nOpcx == 3
	SB1->(dbSetOrder(1))
	If !SB1->(dbSeek(xFilial('SB1') + cCodSim))
		Help(' ',1,'NOFOUNDSB1')
		//��������������������������������������������������������������Ŀ
		//� Restaura Area de trabalho.                                   �
		//����������������������������������������������������������������
		RestArea(aAreaSGG)
		RestArea(aAreaSB1)
		RestArea(aAreaAnt)
		Return .F.
	ElseIf lRestEst
		nQtdBase := RetFldProd(cCodSim,If(MV_PAR01 == 1,"B1_QBP","B1_QB"))
	EndIf
	(cAliasSTRU)->(dbSetOrder(1))
	If !(cAliasSTRU)->((dbSeek(xFilial(cAliasSTRU) + cCodSim)))
		Help(' ',1,'ESTNEXIST')
		//��������������������������������������������������������������Ŀ
		//� Restaura Area de trabalho.                                   �
		//����������������������������������������������������������������
		RestArea(aAreaSGG)
		RestArea(aAreaSG1)
		RestArea(aAreaSB1)
		RestArea(aAreaAnt)
		Return .F.
	EndIf
	//�������������������������������������������������Ŀ
	//� Verifica se o produto similar n�o contem o      �
	//� produto principal em sua Pre-estrutura.         �
	//���������������������������������������������������
	cNomeArq := Estrut2(cCodSim,NIL,NIL,@oTempTable,NIL,IIF(MV_PAR01 == 1,.T.,.F.),NIL,NIL,.F.)	
	dbSelectArea('ESTRUT')
	ESTRUT->(dbGotop())
	Do While !ESTRUT->(Eof())
		If ESTRUT->COMP == cProduto
			Help(' ',1,'SIMINVALID')
			//��������������������������������������������������������������Ŀ
			//� Restaura Area de trabalho.                                   �
			//����������������������������������������������������������������
			RestArea(aAreaSGG)
			RestArea(aAreaSG1)
			RestArea(aAreaSB1)
			RestArea(aAreaAnt)
			Return .F.
		EndIf
		ESTRUT->(dbSkip())
	EndDo
	FimEstrut2(Nil,oTempTable)
	//��������������������������������������������������������������Ŀ
	//� Gera Registros da Pre-Estrutura Similar                      �
	//����������������������������������������������������������������
	Ma202GrSim(cProduto, cCodSim, @aUndo)
	//��������������������������������������������������������������Ŀ
	//� Ponto de Entrada para alteracao da Pre-Estrutura Similar     �
	//����������������������������������������������������������������
	If ExistBlock('MT202CSI')
		//-- Sao passados os seguintes parametros:
		//-- aParamIXB[1] = Codigo do Produto
		//-- aParamIXB[2] = Codigo do Produto Similar
		ExecBlock('MT202CSI', .F., .F., {cProduto, cCodSim})
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Restaura Area de trabalho.                                   �
//����������������������������������������������������������������
RestArea(aAreaSGG)
RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �  A202Comp  � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o c�digo do componente na Pre-Estrutura             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202Comp()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � True caso o c�digo seja validado e False em caso contr�rio ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function a202Comp()

Local lRet := .T.

lRet := A202ChkNod(M->GG_COMP, cValComp)
If lRet
	lRet := A202Codigo(M->GG_COMP, '')
	If lRet
		lRet := A202OutPai(M->GG_COMP, cValComp)
	EndIf
EndIf

If lRet .And. IsProdProt(M->GG_COMP) .And. !IsInCallStack("DPRA340INT")
	Aviso(STR0036,STR0117,{"OK"}) //-- Prot�tipos podem ser manipulados somente atrav�s do m�dulo Desenvolvedor de Produtos (DPR).
	lRet := .F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A202ChkNod  � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica existencia de um mesmo c�digo em um n� da estrutur���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202ChkNod(ExpN1, ExpC1, ExpO1)                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � True                                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = C�digo a ser pesquisado                            ���
���          � ExpC2 = Lista de C�digos a ser pesquizada                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function A202ChkNod(cProduto, cLista)

Local aAreaAnt := GetArea()
Local aAreaSGG := SGG->(GetArea())
Local cNomeArq := ''
Local cNomeAli := ''
Local lRet     := .T.
Local oTempTable := NIL

Private nEstru     := 0

Default lAutomacao := .F.

If cProduto $(cLista)
	Help(' ',1,'A202NODES')
	lRet := .F.
EndIf

//-- Verifica se o Produto possui Pre-Estrutura
If lRet
	dbSelectArea('SGG')
	dbSetorder(1)
	If dbSeek(xFilial('SGG') + cProduto, .F.)
		nNAlias ++
		cNomeAli := "ES"+StrZero(nNAlias,3)
		cNomeArq := Estrut2(cProduto, 1,cNomeAli,@oTempTable,NIL,.T.)
		dbSelectArea(cNomeAli)
		dbGoTop()
		Do While !Eof() .And. lRet
			If COMP $(cLista)
				Help(' ',1,'A202NODES')
				lRet := .F.
				Exit
			EndIf
			dbSkip()
		EndDo
		If Type('aEndEstrut') == 'A'
			aAdd(aEndEstrut,{cNomeAli,oTempTable})
		Else
			If !lAutomacao
				FimEstrut2(Nil, oTempTable)
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSGG)
RestArea(aAreaAnt)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A202OutPai  � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica a existencia de uma mesmo c�digo em um n� da estru���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202OutPai(ExpN1, ExpC1, ExpO1)                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � False caso encontre um c�digo repetido e True em C.C.      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = C�digo a ser pesquizado                            ���
���          � ExpC2 = Lista de C�gigos a ser pesquizada                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function A202OutPai(cProduto, cLista)

Local cPai   := Substr(cLista,1,15)
Local nRecno := Recno()
Local nOrdem := IndexOrd()
Local lRet   := .T.

SGG->(dbSetOrder(2))
SGG->(dbSeek(xFilial('SGG')+cPai))
Do While !SGG->(Eof()) .And. SGG->GG_FILIAL == xFilial("SGG")
	If SGG->GG_COD == cProduto
		Help(' ',1,'A202NODES2',,cProduto,2,26)
		lRet := .F.
		Exit
	EndIf
	SGG->(dbSeek(xFilial('SGG')+SGG->GG_COD))
EndDo
dbSetOrder(1)

dbSetOrder(nOrdem)
dbGoto(nRecno)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �  A202Desc  � Autor �Rodrigo de A.Sartorio� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � True                                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202Desc(ExpC1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � False caso encontre um c�digo repetido e True em C.C.      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do Produto a ser pesquizado                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function A202Desc(cCod)

Local aAreaAnt := GetArea()
Local lRet     := .T.

cCod := If(cCod==Nil,M->GG_COMP,cCod)

//���������������������������������������������������������Ŀ
//� Posiciona no produto desejado e preenche descricao      �
//�����������������������������������������������������������
If SB1->(dbSeek(xFilial('SB1')+cCod, .F.))
	M->GG_DESC := SB1->B1_DESC
Else
	Help(' ', 1, 'NOFOUNDSB1')
	lRet := .F.
EndIf

RestArea(aAreaAnt)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MA202Quant � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o da quantidade do Produto na Pre-Estrutura        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ma202Quant(ExpN1, ExpC1)                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � False caso o valor nao possa ser negativo, e True em C.C.  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Quantidade a ser validada                          ���
���          � ExpC1 = Codigo do Produto                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function MA202Quant(nQuant,cCod)

Local nVar       := 0
Local lRet       := .T.
Local cAlias     := ''
Local nRecno     := 0
Local nOrder     := 0

nVar := If(nQuant==Nil,&(ReadVar()),nQuant)

If IsProdMod(cCod) .And. GetMV('MV_TPHR') == 'N'
	nVar := nVar - Int(nVar)
	If nVar > .5999999999
		HELP(' ',1,'NAOMINUTO')
		lRet := .F.
	EndIf
ElseIf QtdComp(nVar) < QtdComp(0) .And. !GetMV('MV_NEGESTR')
	Help(' ',1,'A202NAONEG')
	lRet := .F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MA202Fecha � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a Integridade do Sistema apos a finaliza��o        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ma202Fecha(ExpO1, ExpO2)                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � False caso ocorra algum problema no fechamento, True C.C.  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto Dlg                                         ���
���          � ExpO2 = Objeto Tree                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Ma202Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cProduto, lConfirma, aAltEstru,nValPre,nQtdBase)
Local nOkAceRj   := 3
Local lRet       := .T.
Local cArqTrab   := ''
Local nRecno	 := 0
Local cProdInt	 := ''
Local lAchou 	 := .F.
Local cUsuario	 := ''
LOCAL oWizard,oUsado,oUsado2,oUsado3,oUsado4,oUsado5
LOCAL oGet1,oGet2,oChk1
LOCAL nTipoItens := 3
LOCAL nNivelCal  := 1
LOCAL nTipodata  := 2
LOCAL dDataIni   := ddatabase
LOCAL dDataFim   := ddatabase
LOCAL nTipoSobre := 1
LOCAL nTipoApaga := 2
LOCAL lMudaNome  := .F.
LOCAL cNomePai   := Criavar("B1_COD",.F.)
Local cAliasB1BZ := If(SuperGetMv('MV_ARQPROD',.F.,"SB1")=="SBZ","SBZ","SB1")
Local aDocto	 := {}
Local cProdCtrl  := ""

If lConfirma
	//�����������������������������������������������������������Ŀ
	//� Aprovacao / Rejeicao                                      �
	//�������������������������������������������������������������
	If nOpcx == 8
		If !lRestEst
			//�������������������������������������������������������Ŀ
			//� Carrega dados da Pre-estrutura para aceitar / rejeitar�
			//���������������������������������������������������������
			// Aprovou
			If nValPre == 1
				nOkAceRj:=Aviso(OemToAnsi(STR0045),OemToAnsi(STR0046),{OemToAnsi(STR0047),OemToAnsi(STR0048),OemToAnsi(STR0049)})
			// Rejeitou
			ElseIf nValPre == 2
				nOkAceRj:=Aviso(OemToAnsi(STR0050),OemtoAnsi(STR0051),{OemToAnsi(STR0047),OemToAnsi(STR0048),OemToAnsi(STR0049)})
			EndIf
			If nOkAceRj # 3
				Processa({|| A202Aprova(cProduto,nOkAceRj,nValPre) })
			Else
				lRet:=.F.
			EndIf
		Else
			SGG->(dbSetOrder(1))
			If SuperGetMv('MV_APRESTR',.F.,.F.)
				A202CriSGN(cProduto,RetCodUsr(),UsrGrEng(RetCodUsr()),nValPre==1)
			EndIf
		Endif
	//�����������������������������������������������������������Ŀ
	//� Criacao de Pre-estrutura                                  �
	//�������������������������������������������������������������
	ElseIf IIF(!lRestEst, nOpcx == 9, nOpcx == 10)
		DEFINE WIZARD oWizard TITLE OemToAnsi(STR0041) HEADER OemToAnsi(STR0056) MESSAGE " " TEXT OemtoAnsi(STR0057) PANEL NEXT {|| .T.} FINISH {|| .T.}
		// Painel 2
		CREATE PANEL oWizard HEADER OemToAnsi(STR0058)  MESSAGE OemToAnsi(STR0059) PANEL BACK {|| .T.} NEXT {|| .T.  } FINISH {|| .T.} EXEC {|| .T.}
		// Painel 3
		CREATE PANEL oWizard HEADER OemToAnsi(STR0060) MESSAGE OemToAnsi(STR0061) PANEL BACK {|| .T.} NEXT {|| .F.  } FINISH {|| A202PrG1(cProduto,nNivelCal,nTipoItens,nTipoData,dDataIni,dDataFim,nTipoSobre,nTipoApaga,lMudaNome,cNomePai) } EXEC {|| .F.}
		// Objetos do Painel 2
		@ 04,22 TO 50,80 LABEL OemToAnsi(STR0062) OF oWizard:oMPanel[2] PIXEL
		@ 14,27 RADIO oUsado VAR nNivelCal 3D SIZE 40,15 PROMPT OemToAnsi(STR0047),OemToAnsi(STR0048) OF oWizard:oMPanel[2] PIXEL

        If !lRestEst
			@ 60,22 TO 125,80 LABEL OemToAnsi(STR0063) OF oWizard:oMPanel[2] PIXEL
			@ 70,27 RADIO oUsado2 VAR nTipoItens 3D SIZE 50,15 PROMPT STR0064,STR0065,STR0066 OF oWizard:oMPanel[2] PIXEL
		EndIf

		@ 04,90 TO 125,260 LABEL OemToAnsi(STR0067) OF oWizard:oMPanel[2] PIXEL

		@ 14,95 RADIO oUsado3 VAR nTipodata 3D SIZE 45,15 PROMPT STR0068,STR0069,STR0070 OF oWizard:oMPanel[2] PIXEL
		oUsado3:bChange := { || IIF(nTipoData=3,(oGet1:Enable(),oGet2:Enable()),(oGet1:Disable(),oGet2:Disable())) }

		@ 65,120 Say OemToAnsi(STR0071) SIZE 30,10 OF oWizard:oMPanel[2] PIXEL
		@ 65,150 MSGET oGet1 VAR dDataIni When IIF(nTipoData=3,.T.,.F.) Valid dDataFim >= dDataIni SIZE 48,10 OF oWizard:oMPanel[2] PIXEL
		@ 80,120 Say OemToAnsi(STR0072) SIZE 30,10 OF oWizard:oMPanel[2] PIXEL
		@ 80,150 MSGET oGet2 VAR dDataFim When IIF(nTipoData=3,.T.,.F.) Valid dDataFim >= dDataIni SIZE 48,10 OF oWizard:oMPanel[2] PIXEL

		// Objetos do Painel 3
		@ 004,22 TO 50,200 LABEL OemToAnsi(STR0073) OF oWizard:oMPanel[3] PIXEL
		@ 014,27 RADIO oUsado4 VAR nTipoSobre 3D SIZE 60,15 PROMPT STR0074,STR0075 OF oWizard:oMPanel[3] PIXEL

		@ 60,22 TO 100,200 LABEL OemToAnsi(STR0076) OF oWizard:oMPanel[3] PIXEL
		@ 70,27 RADIO oUsado5 VAR nTipoApaga 3D SIZE 50,15 PROMPT STR0077,STR0078 OF oWizard:oMPanel[3] PIXEL

		@ 110,22 CHECKBOX oChk1 VAR lMudaNome PROMPT OemToAnsi(STR0079) SIZE 80, 10 OF oWizard:oMPanel[3] PIXEL ;oChk1:oFont := oDlg:oFont
		ochk1:bChange := { || IIF(lMudaNome,oGet3:Enable(),oGet3:Disable()) }
		@ 110,110 MSGET oGet3 VAR cNomePai F3 "SB1" When lMudaNome Valid A202CodDes(cNomePai) SIZE 80,10 OF oWizard:oMPanel[3] PIXEL

		ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }
	Else
		//���������������������������������������������������������������������������������Ŀ
		//� Altera o STATUS para em criacao quando o parametro MV_APRESTR estiver habilitado�
		//�����������������������������������������������������������������������������������
		If (lMudou .And. lRestEst) .And. nOpcx == 4
			nRecno := SGG->(Recno())
			SGG->(dbSetOrder(1))
			If SGG->(dbSeek(xFilial("SGG")+cProduto))
				SGN->(dbSeek(xFilial("SGN")+"SGG"+cProduto))
				While !SGN->(EOF()) .And. SGN->GN_NUM == cProduto
					RecLock("SGN",.F.)
					SGN->(dbDelete())
					SGN->(MsUnLock())
					SGN->(dbSkip())
				End
				SGG->(dbSetOrder(1))
				While !SGG->(Eof()) .And. SGG->GG_FILIAL+SGG->GG_COD == xFilial("SGG")+cProduto
					RecLock('SGG', .F.,.T.)
					Replace GG_STATUS With "1"
					MsUnlock()
					SGG->(dbSkip())
				EndDo
			EndIf
			SGG->(dbGoto(nRecno))
		EndIf
		If lMudou .And. (nOpcX > 2 .And. nOpcX <= 5)
			a202NivAlt()
		EndIf
		//--Atualiza a quantidade base
		dbSelectArea(cAliasB1BZ)
		dbSetOrder(1)
		dbSeek(xFilial(cAliasB1BZ)+cProduto)
		If cAliasB1BZ == "SBZ" .And. Found()
			RecLock("SBZ",.F.)
			Replace BZ_QBP With nQtdBase
			MsUnLock()
		Else
			SB1->(dbSeek(xFilial("SB1")+cProduto))
			RecLock("SB1",.F.)
			Replace B1_QBP With nQtdBase
			MsUnLock()
		EndIf
		//�����������������������������������������������������������Ŀ
		//� Seta o parametro MV_NIVALT                                �
		//�������������������������������������������������������������
		If lMudou .And. (nOpcX > 2 .And. nOpcX <= 5)
			a202NivAlt()
		EndIf
		//�����������������������������������������������������������Ŀ
		//� Executa Ponto de Entrada na Grava��o da Pre-Estrutura     �
		//�������������������������������������������������������������
		If ExistBlock('A202GrvE')
			Execblock('A202GrvE',.F.,.F.)
		EndIf
	EndIf
EndIf

If lRet
	//���������������������������������������������������������������������Ŀ
	//� Deleta o 5o Indice de Trabalho do arquivo dbTree                    �
	//�����������������������������������������������������������������������
	If !Empty(cInd5) .And. File(cInd5+OrdBagExt())
		cArqTrab := oTree:cArqTree
		dbSelectArea(cArqTrab)
		dbClearIndex()
		fErase(cInd5+OrdBagExt())
		cInd5 := ''
		dbSetIndex(SubStr(cArqTrab,2)+'A'+OrdBagExt())
		dbSetIndex(SubStr(cArqTrab,2)+'B'+OrdBagExt())
		dbSetIndex(SubStr(cArqTrab,2)+'C'+OrdBagExt())
		dbSetIndex(SubStr(cArqTrab,2)+'D'+OrdBagExt())
		dbSetOrder(1)
	EndIf

	If oDlg # Nil .And. oTree # Nil
		Release Object oTree
		oDlg:End()
	Endif
EndIf
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MA202Del   � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Deleta a Pre-Estrutura Atual                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ma202Del(ExpC1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � False caso ocorra algum problema na Dele��o, True C.C.     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do Produto                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Ma202Del(cProduto)

Local aAreaAnt   := GetArea()
Local cSeek      := xFilial('SGG')+cProduto
Local aDelet     := {}
Local nX         := 0
Local lRet       := .T.

dbSelectArea('SGG')
dbSetOrder(1)
If !(lRet:=dbSeek(cSeek, .F.))
	Help(' ', 1, 'REGNOIS')
Else
	Do While !Eof() .And. GG_FILIAL+GG_COD == cSeek
		aAdd(aDelet, Recno())
		dbSkip()
	EndDo
	Begin Transaction
		For nX := 1 to Len(aDelet)
			dbGoto(aDelet[nX])
			RecLock('SGG', .F., .T.)
			dbDelete()
			MsUnlock()
		Next nX
		IF lRestEst
			SGN->(dbSetOrder(1))
			If SGN->(dbSeek(xFilial("SGN")+"SGG"+cProduto))
				Do While SGN->(!Eof()) .And. SGN->GN_FILIAL+SGN->GN_TIPO+SGN->GN_NUM == xFilial("SGN")+"SGG"+cProduto
					RecLock("SGN", .F., .T.)
					dbDelete()
					MsUnlock()
					SGN->(dbSkip())
				EndDo
			EndIf
		EndIf
	End Transaction
EndIf

RestArea(aAreaAnt)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MA202Undo  � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Desfaz as Inclus�es/Exclus�es/Alteracoes                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ma202Undo(ExpA1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � False caso ocorra algum problema, True em caso contrasio   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array com os recnos                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Ma202Undo(aUndo)

Local lRet       := .T.
Local nX         := 0
Local nY         := 0
Local aAreaAnt   := GetArea()

Begin Transaction

	dbSelectArea('SGG')
	For nX := 1 to Len(aUndo)
		If aUndo[nX,1] > 0 .And. aUndo[nX,1] <= LastRec()
			dbGoto(aUndo[nX,1])
			If (lRet:=RecLock('SGG', .F.))
				If aUndo[nX, 2] == 1 //-- O Registro foi Incluido
					//-- Deleta o Registro
					If !Deleted()
						dbDelete()
					EndIf
				ElseIf aUndo[nX, 2] == 2 //-- O Registro foi Excluido
					//-- Restaura O REGISTRO
					If Deleted()
						dbRecall()
					EndIf
				ElseIf aUndo[nX, 2] == 3 //-- O Registro foi Alterado
					//-- Restaura OS DADOS do Registro
					For nY := 1 to Len(aUndo[nX, 3])
						FieldPut(nY, aUndo[nX, 3, nY])
					Next nY
				EndIf
				MsUnlock()
			Else
				Exit
			EndIf
		EndIf

	Next nX

	For nY := 1 to Len(aDeletados)
		RecLock('SGG', .T.)
		For nX := 2 to Len(aDeletados[nY])
			&('SGG->'+aDeletados[nY][nX][1]) := aDeletados[nY][nX][2]
		Next nX
		SGG->(MsUnlock())
	Next nY

	If ExistBlock("A202UNDO")
		//--- Parametros passados para PARAMIXB:
		//--- PARAMIXB[nX,1] = Nro. do Registro
		//--- PARAMIXB[nX,2] = Tipo - 1. Inclusao/2. Exclusao/3. Alteracao
		//--- PARAMIXB[nX,3,nY] = Campos Alterados do componente
		ExecBlock("A202UNDO",.F.,.F.,aUndo)
	EndIf

End Transaction

RestArea(aAreaAnt)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A202Descen � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Preenche a Variavel cValComp com a Descendencia do Produto ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202Descen(ExpC1, ExpO1)                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � False caso ocorra algum problema na Montagem, True C.C.    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Variavel Caracter com a Descend�ncia do Produto    ���
���          � ExpO1 = Objeto Tree                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function A202Descen(cValComp, aDescend, oTree)

Local aAreaAnt   := GetArea()
Local aAreaTRE   := {}
Local cPai       := ''
Local cCod       := ''
Local lRet       := .T.
Local nX		 := 0

cValComp := ''
aDescend := {}

dbSelectArea(oTree:cArqTree)
aAreaTRE := GetArea()
cPai     := T_IDTREE
cCod     := If(Right(T_CARGO, 4)=='COMP',SubStr(T_CARGO, Len(SGG->GG_COD) + Len(SGG->GG_TRT) + 1, Len(SGG->GG_COD) ),Left(T_CARGO, Len(SGG->GG_COD)))
aAdd(aDescend, cCod)

Do While .T.
	dbSetOrder(3) //-- Ordem de T_IDCODE (Filho)
	If Val(cPai) # 0 .And. dbSeek(cPai, .F.)
		cCod   := If(Right(T_CARGO, 4)=='COMP',SubStr(T_CARGO, Len(SGG->GG_COD) + Len(SGG->GG_TRT) + 1, Len(SGG->GG_COD) ),Left(T_CARGO, Len(SGG->GG_COD)))
		aAdd(aDescend, cCod)
		cPai := T_IDTREE
		Loop
	Else
		Exit
	EndIf
EndDo

If Len(aDescend) > 0
	For nX := Len(aDescend) to 1 Step -1
		cValComp += aDescend[nX] + '�'
	Next nX
EndIf

//-- Restaura a Area de Trabalho
dbSetOrder(aAreaTRE[2])
dbGoto(aAreaTRE[3])
RestArea(aAreaAnt)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A202TudoOk � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o Final da Inclus�o/Altera��o                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202TudoOk(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � False caso ocorra algum problema na Valida��o, True C.C.   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Variavel Caracter com o a Origem da Chamada (I/A/E)���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function A202TudoOk(cOpc)

Local aAreaAnt   := GetArea()
Local aAreaTRE   := {}
Local aAreaSGG   := {}
Local cSeek      := ''
Local lRet       := .T.
Local lRetPE     := .T.
Local nRecno     := 0

cOpc := If(cOpc==Nil,Space(1),cOpc) //-- "I" = Inclus�o / "A" = Altera��o / "E" = Exclus�o

If !(cOpc=='E')



	//�������������������������������������������������Ŀ
	//� Valida grupo de opcionais e item de opcionais   �
	//���������������������������������������������������
	If AliasInDic("SVC") .And. (!Empty(M->GG_GROPC) .Or. !Empty(M->GG_OPC))
		dbSelectArea("SVC")
		dbSetOrder(1)
		If SVC->(DbSeek(xFilial("SVC")))
			Help( ,  , "Help", ,  STR0123,;  //"N�o � permitido utilizar a vers�o da produ��o em conjunto com o conceito de Componentes Opcionais."
	 		1, 0, , , , , , {STR0124})  //"Para a utiliza��o dos opcionais, n�o pode haver vers�o de produ��o cadastrada."
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. ((!Empty(M->GG_GROPC).And.Empty(M->GG_OPC)) .Or. (!Empty(M->GG_OPC).And.Empty(M->GG_GROPC)))
		Help(' ',1,'A202OPCOBR')
		lRet := .F.
	EndIf

	//��������������������������������������������������������������������Ŀ
	//� Valida a Existencia de Similaridade na Pre-Estrutura Atual (DBTree)�
	//����������������������������������������������������������������������
	If lRet
		dbSelectArea(oTree:cArqTree)
		aAreaTRE := GetArea()
		dbSetOrder(4)
		nRecno := Recno()
		dbSeek(cSeek := cCodPai + M->GG_TRT + M->GG_COMP, .T.)
		If ! Eof()
			Do While !Eof() .And. cSeek == Left(T_CARGO, Len(cSeek))
				If !(nRecno==Recno()) .And. !(Right(T_CARGO,4)$'CODI�NOVO')
					Help(' ',1,'MESMASEQ')
					lRet := .F.
					Exit
				EndIf
				dbSkip()
			EndDo
		EndIf
		dbSetOrder(aAreaTRE[2])
		dbGoto(aAreaTRE[3])
	EndIf
	//��������������������������������������������������������������������Ŀ
	//� Valida a Existencia de Similaridade na Pre-Estrutura Gravada (SGG) �
	//����������������������������������������������������������������������
	If lRet
		dbSelectArea('SGG')
		aAreaSGG := GetArea()
		dbSetOrder(1)
		If dbSeek(xFilial('SGG')+cCodPai+M->GG_COMP+M->GG_TRT, .F.)
			Help(' ',1,'MESMASEQ')
			lRet := .F.
		EndIf
		RestArea(aAreaSGG)
	EndIf

EndIf

//�������������������������������������������������������������������Ŀ
//� Execblock MTA202 ap�s Conf.da Inclus�o/Altera��o/Dele��o          �
//���������������������������������������������������������������������
If lRet
	If ExistBlock('MTA202')
		lRet := If(ValType(lRetPE:=ExecBlock('MTA202',.F.,.F.,cOpc))=='L',lRetPE,.T.)
	EndIf
EndIf

If cOpc == 'E' .And. Type('lDelFunc') == 'L'
	lDelFunc := lRet
EndIf

RestArea(aAreaAnt)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Ma202GrSim � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava��o das Pre-Estruturas Similares                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202TudoOk(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � False caso ocorra algum problema na Valida��o, True C.C.   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Variavel Caracter com o Codigo do Produto          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Ma202GrSim(cProduto, cCodSim, aUndo)
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aAreaTRE   := {}
Local aRecnos    := {}
Local nAcho      := 0
Local nX         := 0
Local i          := 0
Local aCampos    := {}
Local lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
lOCAL cRevAtu		:= ''
Local cNomeArq   := ''
Local oTempTable := NIL
Local cChave     := ''
Local cGG_COD    := ''
Local cGG_COMP   := ''
Local cGG_TRT    := ''
Private nEstru   := 0

aDeletados := {}

If Empty(cCodSim)
	Return lRet
EndIf
If MV_PAR01 == 1
	dbSelectArea('SGG')
	dbSetOrder(1)
	If dbSeek(xFilial('SGG') + cCodSim, .F.)
		Do While !Eof() .And. SGG->GG_FILIAL+SGG->GG_COD == xFilial("SGG")+cCodSim
			aAdd(aRecnos, Recno())
			dbSkip()
		EndDo
	EndIf
Else
	dbSelectArea('SG1')
	dbSetOrder(1)
	If dbSeek(xFilial('SG1') + cCodSim, .F.)
		/*
		Do While !Eof() .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cCodSim
			If /*lRestEst .And.*//* SB1->(dbSeek(xFilial("SB1")+cCodSim))
				cRevAtu		:= IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )

				If SG1->G1_REVINI <= cRevAtu .And. SG1->G1_REVFIM >= cRevAtu
					aAdd(aRecnos, Recno())
				EndIf
			Else
				aAdd(aRecnos, Recno())
			EndIf
			dbSkip()
		EndDo  */
		cNomeArq := Estrut2(cCodSim,,,@oTempTable,NIL,NIL,NIL,NIL,.F.)	
		dbSelectArea('ESTRUT')
		ESTRUT->(dbGotop())
		Do While !ESTRUT->(Eof())

			aAdd(aRecnos,ESTRUT->REGISTRO )
    		ESTRUT->(dbSkip())

		EndDo

		FimEstrut2(Nil,oTempTable)


	EndIf
EndIf

If Len(aRecnos) > 0
	For nX := 1 to Len(aRecnos)

		If MV_PAR01 == 1
			dbSelectArea('SGG')
		Else
			dbSelectArea('SG1')
		EndIf
		dbGoto(aRecnos[nX])
		//-- Grava o Campo Atual
		aCampos := {}
		For i := 1 To FCount()
			aAdd(aCampos,{FieldGet(i),"GG"+Substr(FieldName(i),3)})
		Next i

		If MV_PAR01 == 2
			nAcho := aScan(aCampos,{|x| x[2] == 'GG_COD'})
			cGG_COD := aCampos[nAcho,1]
			nAcho := aScan(aCampos,{|x| x[2] == 'GG_COMP'})
			cGG_COMP := aCampos[nAcho,1]
			nAcho := aScan(aCampos,{|x| x[2] == 'GG_TRT'})
			cGG_TRT := aCampos[nAcho,1]
			IF cGG_COD = cCodSim
				cGG_COD := cProduto
			EndIF
			cChave := xFilial("SGG") + cGG_COD + cGG_COMP + cGG_TRT

			dbSelectArea('SGG')
			dbSetOrder(1)
			If dbSeek(cChave)
				aAdd(aDeletados, {"REGDEL"})
				For i:=1 To FCount()
					aAdd(aDeletados[Len(aDeletados)], {FieldName(i), &("SGG->"+FieldName(i))})
				Next 1
				RecLock('SGG', .f.)
				dbDelete()
				SGG->(MsUnlock())
			EndIf
		EndIf

		//-- Cria o Novo Registro
		Begin Transaction
			RecLock('SGG', .T.)
			If aScan(aUndo, {|x| x[1]==Recno()}) == 0
				aAdd(aUndo, {Recno(), 1}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
			EndIf
			For i:=1 To FCount()
				nAcho:=aScan(aCampos,{|x| x[2] == FieldName(i)})
				If nAcho > 0
					FieldPut(i,aCampos[nAcho,1])
				EndIf
			Next 1
			Replace GG_FILIAL  With xFilial("SGG")
			//Replace GG_COD     With cProduto
			IF GG_COD = cCodSim
				Replace GG_COD     With cProduto
			EndIF
			Replace GG_STATUS  With "1"
			Replace GG_USUARIO With IIF(!lRestEst,Subs(cUsuario,7,6),RetCodUsr())
			MsUnlock()
		End Transaction
	Next nX
EndIf
//-- Restaura a Area de Trabalho
RestArea(aAreaAnt)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A202NivAlt � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Seta o Parametro MV_NIVALT para 'S'                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202NivAlt()                                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � False caso ocorra algum problema na Valida��o, True C.C.   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function a202NivAlt()

Local aAreaAnt   := GetArea()
Local lRet       := .F.

//-- Seta o Parametro para Altera��o de Niveis
If !(GetMV('MV_NIVALTP')=='S')
	lRet := .T.
	PutMV('MV_NIVALTP','S')
EndIf

RestArea(aAreaAnt)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A202Fields � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria um Array com os Campos do SGG                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202Fields(ExpA1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � False caso ocorra algum problema na Valida��o, True C.C.   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array com os campos do SGG                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function A202Fields(aAcho)

Local aAreaAnt   := GetArea()
Local aAreaSX3   := {}
Local lRet       := .T.

dbSelectArea('SX3')
aAreaSX3 := GetArea()
dbSetOrder(1)
If dbSeek('SGG' + '01', .F.)
	aAcho := {}
	Do While !Eof() .And. X3_ARQUIVO == 'SGG'
		If ! __lPyme .Or. (__lPyme .And. X3_PYME <> "N")
			aAdd(aAcho, X3_CAMPO)
		EndIf
		dbSkip()
	EndDo
Else
	aAcho := Array(SGG->(fCount()))
	SGG->(aFields(aAcho))
EndIf

RestArea(aAreaSX3)
RestArea(aAreaAnt)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   � Explode  � Autor � Rodrigo de A. Sartorio� Data � 03/08/95 ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Faz a explosao de uma Pre-estrutura                        ���
�������������������������������������������������������������������������Ĵ��
��� Sintaxe  � Explode(ExpC1,ExpA1,ExpC2)                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do produto a ser explodido                  ���
���          � ExpA1 = Array com estrutura                                ���
���          � ExpC2 = Revisao da Estrutura Utilizada                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Explode(cProduto, aExplode,nCount, oTree)

Local aAreaAnt   := GetArea()
Local aAreaSGG   := SGG->(GetArea())
Local aAreaTRE   := {}
Local cCod       := cProduto
Local cSeq       := ''
Local cComp      := ''
Local nRecno     := 0
Local cFilSGG    := xFilial('SGG')

nCount++
SGG->(dbSetOrder(1))

dbSelectArea(oTree:cArqTree)
aAreaTRE := GetArea()
dbSetOrder(1)
dbGoTop()

Do While !Eof()
	cCod   := Left(T_CARGO, Len(SGG->GG_COD))
	cSeq   := SubStr(T_CARGO, Len(SGG->GG_COD) + 1, Len(SGG->GG_TRT))
	cComp  := SubStr(T_CARGO, Len(SGG->GG_COD + SGG->GG_TRT) + 1, Len(SGG->GG_COMP))
	nRecno := Val(SubStr(T_CARGO,Len(SGG->GG_COD + SGG->GG_TRT + SGG->GG_COMP) + 1, 9))

	If cCod # cProduto
		dbSkip()
		Loop
	EndIf

	If nRecno > 0
		SGG->(dbGoto(nRecno))
	Else
		Exit
	EndIf
	If cCod # cComp
		nPos := aScan(aExplode,{|x| x[1] == nCount .And. x[2] == cCod .And. x[3] == cComp .And. x[5] == cSeq})
		If nPos == 0 .And. dDataBase >= SGG->GG_INI .And. dDataBase <= SGG->GG_FIM
			aAdd(aExplode,{nCount, cCod, cComp, SGG->GG_QUANT, cSeq})
		EndIf

		//�������������������������������������������������Ŀ
		//� Verifica se existe sub-estrutura                �
		//���������������������������������������������������
		nRecno := SGG->(Recno())
		If SGG->(dbSeek(cFilSGG+cComp, .F.))
			Explode( SGG->GG_COD, @aExplode, @nCount, oTree)
			nCount --
		Else
			SGG->(dbGoto(nRecno))
			nPos := aScan(aExplode,{|x| x[1] == nCount .And. x[2] == cCod .And. x[3] == cComp .And. x[5] == cSeq})
			If nPos == 0 .And. dDataBase >= SGG->GG_INI .And. dDataBase <= SGG->GG_FIM
				aAdd(aExplode,{nCount, cCod, cComp, SGG->GG_QUANT, cSeq})
			EndIf
		Endif
	EndIf
	dbSkip()
Enddo

RestArea(aAreaTRE)
RestArea(aAreaSGG)
RestArea(aAreaAnt)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �Ma202Posic�Autor  �Fernando Joly       � Data �  10/15/99   ���
�������������������������������������������������������������������������͹��
���Desc.     �Posiciona sobre o Item desejado na Pre-Estrutura            ���
���          �Esta fun��o  cria o  5o  indice  do dbTree , atualizando  a ���
���          �variavel cInd5. Para  tal  assume-se  como  nomes para os 4 ���
���          �primeiros : SubStr(oTree:cArqTree,2) + "A", "B", "C" e "D". ���
�������������������������������������������������������������������������͹��
���Parametros� ExpN1 = Op��o da Edi��o                                    ���
���          � ExpC1 = Chave do Registro                                  ���
���          � ExpO1 = Objeto Tree                                        ���
�������������������������������������������������������������������������͹��
���Uso       � MATA202.PRW                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ma202Posic(nOpcX, cCargo, oTree)

//���������������������������������������������������������������������Ŀ
//� Inicializa Variaveis Locais                                         �
//�����������������������������������������������������������������������
Local aAreaAnt   := GetArea()
Local aAreaTRB   := ''
Local cComp      := Space(Min(TamSX3('GG_COMP')[1],15))
Local cOrdem     := ''
Local cTarget    := ''
Local cArqTrab   := oTree:cArqTree
Local nRecno     := 0

Private cA202ICod := AllTrim(Str(Len(SGG->GG_COD+SGG->GG_TRT)+1))
Private cA202TCod := AllTrim(Str(Len(SGG->GG_COMP)))

If Ma202Pesq(@cComp)
	If !Empty(cComp)
		dbSelectArea(cArqTrab)
		aAreaTRB  := GetArea()
		cOrdem    := T_IDCODE
		nRecno    := Recno()
		If cComp==cCodAtual
			dbGoto(1)
			cTarget := T_CARGO
		Else
			//���������������������������������������������������������������������Ŀ
			//� Cria o 5o Indice de Trabalho do arquivo dbTree                      �
			//�����������������������������������������������������������������������
			If Empty(cInd5) .Or. !File(cInd5+OrdBagExt())
				cInd5 := CriaTrab('', .F.)
				IndRegua(Alias(),cInd5,'Subs(T_CARGO,'+cA202ICOD+', '+cA202TCOD+')',,,STR0007)
				dbClearIndex()
				dbSetIndex(SubStr(cArqTrab,2)+'A'+OrdBagExt())
				dbSetIndex(SubStr(cArqTrab,2)+'B'+OrdBagExt())
				dbSetIndex(SubStr(cArqTrab,2)+'C'+OrdBagExt())
				dbSetIndex(SubStr(cArqTrab,2)+'D'+OrdBagExt())
				dbSetIndex(cInd5+OrdBagExt())
			EndIf
			dbSetOrder(5)
			dbGoto(nRecno)
			If dbSeek(cComp, .F.)

				//-- Desconsidera a linha do Produto Pai
				If !(Right(T_CARGO,4)=='COMP')
					Do While !Eof() .And. Subs(T_CARGO,Len(SGG->GG_COD+SGG->GG_TRT)+1,Len(SGG->GG_COMP)) == cComp
						If	Right(T_CARGO,4)=='COMP'
							cTarget := T_CARGO
							Exit
						EndIf
						dbSkip()
					EndDo
				Else
					cTarget := T_CARGO
				EndIf

				//-- Caso J� esteja posicionado procura a Pr�xima ocorr�ncia
				If !Empty(cTarget) .And. T_IDCODE <= cOrdem
					Do While !Eof() .And. Subs(T_CARGO,Len(SGG->GG_COD+SGG->GG_TRT)+1,Len(SGG->GG_COMP)) == cComp
						If Right(T_CARGO,4) == 'COMP' .And. T_IDCODE > cOrdem
							cTarget := T_CARGO
							Exit
						EndIf
						dbSkip()
					EndDo
				EndIf

			EndIf
		EndIf
		//���������������������������������������������������������������������Ŀ
		//� Retorna Integridade do Sistema                                      �
		//�����������������������������������������������������������������������
		RestArea(aAreaTRB)
		RestArea(aAreaAnt)

		//-- Posiciona o dbTree sobre o Componente Encontrado
		If !Empty(cTarget)
			oTree:TreeSeek(cTarget)
		Else
			Help(' ',1, 'REGNOIS')
		EndIf
	EndIf
EndIf

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ma202Pesq � Autor �Larson Zordan       � Data �  12/03/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Pesquisa o codigo e o nome do compnente no Tree            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ma202Pesq(cComp)
Local oDlg
Local oCbx
Local oGet
Local cOrd  := STR0008
Local aOrd  := {STR0008,STR0017}
Local lRet  := .F.
Local lSB1  := .F.
Local aArea := SB1->(GetArea())

SB1->(dbSetOrder(3))

Define MsDialog oDlg From 0,0 To 100,490 Pixel Title OemToAnsi(STR0002)
@  5, 5 ComboBox oCbx Var cOrd  Items aOrd Size 206,36 Pixel Of oDlg FONT oDlg:oFont Valid ( If(cOrd==STR0017,cComp:=Space(Len(SB1->B1_DESC)),Space(Len(cComp))) )
@ 22, 5 MsGet    oGet Var cComp Size 206,10 Pixel Valid( Ma202Descr(cOrd,@cComp,@lSB1),If(lSB1,(lRet:=.T.,oDlg:End()),.T.) )
Define SButton From  5,215 Type 1 Of oDlg Enable Action (lRet:=.T.,oDlg:End())
Define SButton From 20,215 Type 2 Of oDlg Enable Action oDlg:End()
Activate MsDialog oDlg Centered

cComp := If(lRet.And.lSB1,SB1->B1_COD,cComp)

RestArea(aArea)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ma202Descr� Autor �Larson Zordan       � Data �  12/03/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Pesquisa a descricao no SB1                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ma202Descr(cOrd,cComp,lSB1)
Local aAreaAnt := GetArea()
Local lRet     := .T.
If cOrd == STR0017
	If !SB1->(dbSeek(xFilial("SB1")+cComp,.T.))
		lSB1  := lRet := ConPad1(,,,"SB1",,, .F.)
		cComp := SB1->B1_DESC
	Else
		lSB1  := .T.
	EndIf
EndIf
RestArea(aAreaAnt)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA202   �Autor  �Marcelo Iuspa       � Data �  10/04/01   ���
�������������������������������������������������������������������������͹��
���Desc.     � FUNCAO ACIONADA NO BOTAO DE CONFIRMACAO DA PRE-ESTRUTURA   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Btn202Ok(aUndo, c202Cod)
Local lRet := .T.
Local aArea := {SGG->(IndexOrd()), SGG->(RecNo()), Alias()}
If ExistBlock('A202BOK')
	lRet := If(ValType(lRet:=ExecBlock('A202BOK',.F.,.F.,{aUndo, c202Cod}))=='L',lRet,.T.)
	SGG->(dbSetOrder(aArea[1]))
	SGG->(dbGoto(aArea[2]))
	dbSelectArea(aArea[3])
EndIf
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA202   �Autor  �Marcelo Iuspa       � Data �  24/04/01   ���
�������������������������������������������������������������������������͹��
���Desc.     � Acrescenta TRT ao prompt do dbtree baseado no conteudo     ���
���          � da propriedade cargo                                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A202Prompt(cPrompt, cCargo, nQuant)
Local cTRT     := Space(Len(SGG->GG_TRT)+3)
Local cQuant   := " "
Local aTamQtde := TamSX3("GG_QUANT")
Default nQuant := 0

If ! (cCargo == Nil .Or. Empty(cCargo) .Or. Right(cCargo, 4) $ "CODI,NOVO")
	If ! Empty(cTRT := SubStr(cCargo, Len(SGG->GG_COD)+1,Len(SGG->GG_TRT)))
		cTRT := " - " + cTRT
	Endif
	cQuant := " / " + STR0118 + Str(nQuant,aTamQtde[1],aTamQtde[2])
Endif
Return(Pad(AllTrim(cPrompt) + cTRT + cQuant, Len(cPrompt+cTRT+cQuant)))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A202Potenc  �Autor�Rodrigo de A. Sartorio� Data � 09/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao para digitar a potencia do Lote corretamente     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mata202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A202Potenc()
LOCAL lRet      := .T.
LOCAL cCod		:= M->GG_COMP
LOCAL nPotencia := &(ReadVar())
If !Rastro(cCod)
	Help(" ",1,"NAORASTRO")
	lRet:=.F.
Else
	If !PotencLote(cCod)
		Help(" ",1,"NAOCPOTENC")
		lRet:=.F.
	EndIf
EndIf
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �  a202CEst  � Autor �Rodrigo de A Sartorio� Data �29.10.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Comparacao de Pre-estruturas                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202CEst                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function A202CEst(cAlias,nRecno,nOpcX)
Local aArea:=GetArea()
Local cCodOrig:=Criavar("GG_COMP",.F.),cCodDest:=Criavar("GG_COMP",.F.)
Local cDescOrig:=Criavar("B1_DESC",.F.),cDescDest:=Criavar("B1_DESC",.F.)
Local cOpcOrig:=Criavar("C2_OPC",.F.),cOpcDest:=Criavar("C2_OPC",.F.)
Local dDtRefOrig:=dDataBase,dDtRefDest:=dDataBase
Local oSay,oSay2
Local lOk:=.F.
Local mOpcOrig := ""
Local mOpcDest := ""

DEFINE MSDIALOG oDlg FROM  140,000 TO 350,670 TITLE OemToAnsi(STR0019) PIXEL
DEFINE SBUTTON oBtn FROM 800,800 TYPE 5 ENABLE OF oDlg

@ 026,006 TO 056,330 LABEL OemToAnsi(STR0020) OF oDlg PIXEL
@ 062,006 TO 092,330 LABEL OemToAnsi(STR0021) OF oDlg PIXEL

@ 038,030 MSGET cCodOrig   F3 "SB1" Picture PesqPict("SGG","GG_COMP") Valid NaoVazio(cCodOrig) .And. ExistCpo("SB1",cCodOrig) SIZE 105,09 OF oDlg PIXEL
@ 038,175 MSGET dDtRefOrig Picture PesqPict("SD3","D3_EMISSAO") Valid NaoVazio(dDtRefOrig) SIZE 40,09 OF oDlg PIXEL
@ 038,249 MSGET cOpcOrig   When .F. SIZE 65,09 OF oDlg PIXEL
@ 038,317 BUTTON "?" SIZE 09,11 Action (cOpcOrig:=SeleOpc(4,"MATA202",cCodOrig,,,,,,1,dDtRefOrig,,,@mOpcOrig)) OF oDlg FONT oDlg:oFont PIXEL

@ 074,030 MSGET cCodDest   F3 "SB1" Picture PesqPict("SGG","GG_COMP") Valid NaoVazio(cCodDest) .And. ExistCpo("SB1",cCodDest) SIZE 105,9 OF oDlg PIXEL
@ 074,175 MSGET dDtRefDest Picture PesqPict("SD3","D3_EMISSAO") Valid NaoVazio(dDtRefDest) SIZE 40,09 OF oDlg PIXEL
@ 074,249 MSGET cOpcDest   When .F. SIZE 65,09 OF oDlg PIXEL
@ 074,317 BUTTON "?" SIZE 09,11 Action (cOpcDest:=SeleOpc(4,"MATA202",cCodDest,,,,,,1,dDtRefDest,,,@mOpcDest)) OF oDlg FONT oDlg:oFont PIXEL

@ 048,030 SAY oSay Prompt cDescOrig SIZE 130,6 OF oDlg PIXEL
@ 084,030 SAY oSay2 Prompt cDescDest SIZE 130,6 OF oDlg PIXEL

@ 040,009 SAY OemtoAnsi(STR0022) SIZE 24,7  OF oDlg PIXEL
@ 035,145 SAY OemToAnsi(STR0023) SIZE 35,15 OF oDlg PIXEL
@ 040,223 SAY OemtoAnsi(STR0024) SIZE 24,7  OF oDlg PIXEL

@ 075,009 SAY OemToAnsi(STR0022) SIZE 24,7  OF oDlg PIXEL
@ 072,145 SAY OemToAnsi(STR0023) SIZE 35,15 OF oDlg PIXEL
@ 075,223 SAY OemtoAnsi(STR0024) SIZE 24,7  OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| If(A202COk(cCodOrig,dDtRefOrig,cOpcOrig,cCodDest,dDtRefDest,cOpcDest),(lOk:=.T.,oDlg:End()),lOk:=.F.) },{||(lOk:=.F.,oDlg:End())})

// Processa comparacao das Pre-estruturas
If lOk
	Processa({|| A202PrCom(cCodOrig,dDtRefOrig,cOpcOrig,cCodDest,dDtRefDest,cOpcDest,mOpcOrig,mOpcDest) })
EndIf
RestArea(aArea)
RETURN

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A202Cok     � Autor �Rodrigo de A Sartorio� Data �29.10.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se pode efetuar a comparacao das pre-estruturas     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202Cok(ExpC1,ExpC2,ExpD1,ExpC3,ExpC4,ExpC5,ExpD2,ExpC6)   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � True                                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do produto origem                           ���
���          � ExpC2 = Codigo da revisao origem                           ���
���          � ExpD1 = Data de referencia origem                          ���
���          � ExpC3 = Opcionais do produto origem                        ���
���          � ExpC4 = Codigo do produto destino                          ���
���          � ExpC5 = Codigo da revisao destino                          ���
���          � ExpD2 = Data de referencia destino                         ���
���          � ExpC6 = Opcionais do produto destino                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function A202COk(cCodOrig,dDtRefOrig,cOpcOrig,cCodDest,dDtRefDest,cOpcDest)
Local lRet:=.T.
Local aEstruOrig:={},aEstruDest:={}
Private nEstru:=0
// Verifica se todas as informacoes estao iguais
If cCodOrig+DTOS(dDtRefOrig)+cOpcOrig == cCodDest+DTOS(dDtRefDest)+cOpcDest
	Help('  ',1,'A202COMPIG')
	lRet:=.F.
EndIf
If lRet .And. cCodOrig <> cCodDest
	// Verifica se existe item dentro da outra pre-estrutura - NAO PERMITE COMPARAR PARA EVITAR RECURSIVIDADE
	nEstru:=0;aEstruOrig:=Estrut(cCodOrig,1,NIL,.T.)
	nEstru:=0;aEstruDest:=Estrut(cCodDest,1,NIL,.T.)
	If (aScan(aEstruOrig,{|x| x[3] == cCodDest}) > 0) .Or. (aScan(aEstruDest,{|x| x[3] == cCodOrig}) > 0)
		Help('  ',1,'A202COMPES')
		lRet:=.F.
	EndIf
	// Avisa ao usuario sobre produtos diferentes
	If lRet
		Help('  ',1,'A202COMPDF')
	EndIf
EndIf
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A202PrCom   � Autor �Rodrigo de A Sartorio� Data �29.10.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua a comparacao das pre-estruturas                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202PrCom (ExpC1,ExpC2,ExpD1,ExpC3,ExpC4,ExpC5,ExpD2,ExpC6)���
�������������������������������������������������������������������������Ĵ��
���Retorno   � True                                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do produto origem                           ���
���          � ExpC2 = Codigo da revisao origem                           ���
���          � ExpD1 = Data de referencia origem                          ���
���          � ExpC3 = Opcionais do produto origem                        ���
���          � ExpC4 = Codigo do produto destino                          ���
���          � ExpC5 = Codigo da revisao destino                          ���
���          � ExpD2 = Data de referencia destino                         ���
���          � ExpC6 = Opcionais do produto destino                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function A202PrCom(cCodOrig,dDtRefOrig,cOpcOrig,cCodDest,dDtRefDest,cOpcDest,mOpcOrig,mOpcDest)
Local aEstruOri:={}
Local aEstruDest:={}
Local aSize    := MsAdvSize(.T.)
Local oDlg,oTree,oTree2,aObjects:={},aInfo:={},aPosObj:={},aButtons:={}

//��������������������������������������������������������������Ŀ
//�Monta a  tela com o tree da versao base e com o tree da versao�
//�resultado da comparacao.                                      �
//����������������������������������������������������������������
aAdd( aObjects, { 100, 100, .T., .T., .F. } )
aAdd( aObjects, { 100, 100, .T., .T., .F. } )
aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
aPosObj:= MsObjSize( aInfo, aObjects, .T.,.T. )

//�����������������������������������������������������������������������
//�Monta array com os conteudos dos tree                                �
//�����������������������������������������������������������������������
SGG->(dbSeek(xFilial("SGG")+cCodOrig))
M202Expl(cCodOrig,dDtRefOrig,cOpcOrig,1,aEstruOri,0,mOpcOrig)
SGG->(dbSeek(xFilial("SGG")+cCodDest))
M202Expl(cCodDest,dDtRefDest,cOpcDest,1,aEstruDest,0,mOpcDest)
//�����������������������������������������������������������������������
//�Iguala os arrays de origem e destino da comparacao                   �
//�����������������������������������������������������������������������
Mt202CpAr(aEstruOri,aEstruDest,cCodOrig,cCodDest)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0019) FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
	oTree:= dbTree():New(aPosObj[1,1], aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], oDlg,,,.T.)
	oTree:lShowHint := .F.
	A202TreeCm(oTree,aEstruOri,NIL,NIL)
	oTree2:=dbTree():New(aPosObj[2,1], aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], oDlg,,,.T.)
	oTree:lShowHint := .F.
	A202TreeCm(oTree2,aEstruDest,NIL,NIL)
	AAdd( aButtons, { "PMSSETADOWN", { || Mt202Nav(1,@oTree,@oTree2,aEstruOri,aEstruDest) },OemToAnsi(STR0025)} ) //"Desce"
	AAdd( aButtons, { "PMSSETAUP"  , { || Mt202Nav(2,@oTree,@oTree2,aEstruOri,aEstruDest) },OemToAnsi(STR0026)} ) //"Sobe"
	AAdd( aButtons, { "DBG09"      , { || Mt202Inf() }, STR0031 } )
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||oDlg:End()} ,{||oDlg:End()},,aButtons)
Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   �M202Expl  � Autor �Rodrigo A Sartorio     � Data � 29/10/03 ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Faz a explosao de uma pre-estrutura para comparacao        ���
�������������������������������������������������������������������������Ĵ��
��� Sintaxe  � M202Expl(ExpC1,ExpC2,ExpD1,ExpC3,ExpN1,ExpA1,ExpN2)        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do produto a ser explodido                  ���
���          � ExpC2 = Revisao do produto a ser explodido                 ���
���          � ExpD1 = Data de referencia para explosao do produto        ���
���          � ExpC3 = Grupo de opcionais para explosao do produto        ���
���          � ExpN1 = Quantidade base para explosao                      ���
���          � ExpA1 = Array com o retorno da pre-estrutura               ���
���          � ExpN2 = Nivel da pre-estrutura                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
STATIC Function M202Expl(cProduto,dDataRef,cOpcionais,nQuantPai,aEstru,nNivelEstr,mOpc,cProdAnt)
LOCAL nReg:=0,nQuantItem:=0,nHistorico:=4

Local cComp   := ""
Local cTrt    := ""
Local cOpcPar := ""
Local aOpc    := Str2Array(mOpc,.F.)
Local nPos    := 0

Default cProdAnt := PadR(cProduto,TamSX3("GG_COD")[1])

// Estrutura do array
// [1] Produto PAI
// [2] Componente
// [3] TRT
// [4] Quantidade
// [5] Historico
// [6] Nivel
// [7] Cargo = [6]+[2]+[3]

dbSelectArea("SB1")
dbSetOrder(1)
dbSelectArea("SGG")
dbSetOrder(1)
While !Eof() .And. GG_FILIAL+GG_COD == xFilial("SGG")+cProduto
	nReg := Recno()                                                    "
	//�������������������������������������������������Ŀ
	//� Calcula a qtd dos componentes                   �
	//���������������������������������������������������
	nHistorico := 4
	cOpcPar    := cOpcionais
	If aOpc != Nil .And. Len(aOpc) > 0 .And. !Empty(SGG->GG_GROPC)
		nPos := aScan(aOpc,{|x| x[1] == cProdAnt+SGG->GG_COMP+SGG->GG_TRT})
		If nPos > 0
			cOpcPar := aOpc[nPos,2]
		Else
			cOpcPar := "*NAOENTRA*"
		EndIf
	EndIf
	nQuantItem := ExplEstr(nQuantPai,dDataRef,cOpcPar,NIL,@nHistorico,.T.)
	dbSelectArea("SGG")
	SB1->(dbSeek(xFilial("SB1")+SGG->GG_COMP))
	If QtdComp(nQuantItem) < QtdComp(0)
		nQuantItem:=If(QtdComp(RetFldProd(SB1->B1_COD,"B1_QB"))>0,RetFldProd(SB1->B1_COD,"B1_QB"),1)
	EndIf
	AADD(aEstru,{SGG->GG_COD,SGG->GG_COMP,SGG->GG_TRT,nQuantItem,nHistorico,nNivelEstr,StrZero(nNivelEstr,5,0)+SGG->GG_COMP+SGG->GG_TRT})
	cComp := SGG->GG_COMP
	cTrt  := SGG->GG_TRT
	//�������������������������������������������������Ŀ
	//� Verifica se existe sub-estrutura                �
	//���������������������������������������������������
	dbSelectArea("SGG")
	If dbSeek(xFilial("SGG")+SGG->GG_COMP)
		nNivelEstr++
		M202Expl(SGG->GG_COD,dDataRef,cOpcionais,nQuantItem,aEstru,nNivelEstr,mOpc,cProdAnt+cComp+cTrt)
		nNivelEstr--
	EndIf
	dbGoto(nReg)
	dbSkip()
EndDo
Return(.T.)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Mt202CpAr � Autor �Rodrigo de A Sartorio  � Data � 05/11/2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Compara e ajusta os arrays de origem e destino                ���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe  � Mt202CpAr(ExpA1,ExpA2,ExpC1,ExpC2)                           ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array com os dados pre-estrutura origem da comparacao���
���          � ExpA2 = Array com os dados pre-estrutura destino da comparaca���
���          � ExpC1 = Codigo do produto origem                             ���
���          � ExpC2 = Codigo do produto destino                            ���
���������������������������������������������������������������������������Ĵ��
���Uso       �MATA202                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function Mt202CpAr(aEstruOri,aEstruDest,cCodOrig,cCoddest)
Local nz:=0,nw:=0,nAcho:=0
Local cProcura:="",lFirstLevel:=.F.

// Estrutura do array
// [1] Produto PAI
// [2] Componente
// [3] TRT
// [4] Quantidade
// [5] Historico
// [6] Nivel
// [7] Cargo = [6]+[2]+[3]

// Compara os elementos em comum do array
// Adiciona no array origem os componentes do array destino diferentes
For nz:=1 To Len(aEstruDest)
	// Verifica se esta no primeiro nivel
	If aEstruDest[nz,6]==0
		lFirstLevel:=.T.
	Else
		lFirstLevel:=.F.
	EndIf
	// Nao procura o produto pai junto
	If lFirstLevel
		cProcura:=aEstruDest[nz,2]+aEstruDest[nz,3]
	// Procura o produto pai junto
	Else
		cProcura:=aEstruDest[nz,1]+aEstruDest[nz,2]+aEstruDest[nz,3]
	EndIf
	// Efetua procura no array origem
	nAcho:=ASCAN(aEstruOri,{|x| x[6] == aEstruDest[nz,6] .And. (If(lFirstLevel,x[2]+x[3],x[1]+x[2]+x[3]) == cProcura)})
	// Caso nao achou soma componentes no array origem com a pre-estrutura do item
	If nAcho == 0
		For nw:=nz to Len(aEstruDest)
			AADD(aEstruOri,{If(lFirstLevel,If(Len(aEstruOri)> 0,aEstruOri[1,1],cCodOrig),aEstruDest[nw,1]),aEstruDest[nw,2],aEstruDest[nw,3],aEstruDest[nw,4],5,aEstruDest[nw,6],aEstruDest[nw,7]})
			// Desliga flag de primeiro nivel
			If lFirstLevel
				lFirstLevel:=.F.
			EndIf
			If nw == Len(aEstruDest) .Or. (aEstruDest[nz,6] == aEstruDest[nw+1,6])
				nz:=nw
				Exit
			EndIf
		Next nw
	EndIf
Next nz

// Adiciona no array destino os componentes do array origem diferentes
For nz:=1 To Len(aEstruOri)
	// Verifica se esta no primeiro nivel
	If aEstruOri[nz,6]==0
		lFirstLevel:=.T.
	Else
		lFirstLevel:=.F.
	EndIf
	// Nao procura o produto pai junto
	If lFirstLevel
		cProcura:=aEstruOri[nz,2]+aEstruOri[nz,3]
	// Procura o produto pai junto
	Else
		cProcura:=aEstruOri[nz,1]+aEstruOri[nz,2]+aEstruOri[nz,3]
	EndIf
	// Efetua procura no array origem
	nAcho:=ASCAN(aEstruDest,{|x| x[6] == aEstruOri[nz,6] .And. (If(lFirstLevel,x[2]+x[3],x[1]+x[2]+x[3]) == cProcura)})
	// Caso nao achou soma componentes no array origem com a pre-estrutura do item
	If nAcho == 0
		For nw:=nz to Len(aEstruOri)
			AADD(aEstruDest,{If(lFirstLevel,If(Len(aEstruDest)> 0,aEstruDest[1,1],cCodDest),aEstruOri[nw,1]),aEstruOri[nw,2],aEstruOri[nw,3],aEstruOri[nw,4],5,aEstruOri[nw,6],aEstruOri[nw,7]})
			// Desliga flag de primeiro nivel
			If lFirstLevel
				lFirstLevel:=.F.
			EndIf
			If nw == Len(aEstruOri) .Or. (aEstruOri[nz,6] == aEstruOri[nw+1,6])
				nz:=nw
				Exit
			EndIf
		Next nw
	EndIf
Next nz

// Ordena arrays por nivel
ASORT(aEstruOri,,,{|x,y| x[7] < y[7] })
ASORT(aEstruDest,,,{|x,y| x[7] < y[7] })
RETURN(.T.)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �A202TreeCM� Autor �Rodrigo de A Sartorio  � Data � 05/11/2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta o objeto TREE - FUNCAO RECURSIVA                        ���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe  �A202TreeCM(ExpO1,ExpA1,ExpC1,ExpN1)                           ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto tree utilizado                                ���
���          � ExpA1 = Array com os dados da pre-estrutura                  ���
���          � ExpC1 = Codigo do produto a ter a pre-estrutura explodida    ���
���          � ExpN1 = Posicao do array de pre-estrutura utilizado          ���
���������������������������������������������������������������������������Ĵ��
���Uso       �MATA202                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function A202TreeCm(oObjTree,aEstru,cProduto,nz)
Local nAcho:=0
Local aOcorrencia :={}
Local cTexto:=""
Local cCargoVazio:=Space(5+Len(SGG->GG_COMP+SGG->GG_TRT))
Default nz:=1
Default cProduto:=""

// Ordem de pesquisa por codigo
SB1->(dbSetOrder(1))

// Array com as ocorrencias cadastradas
AADD(aOcorrencia,"PMSTASK4") //"Componente fora das datas inicio / fim"
AADD(aOcorrencia,"PMSTASK5") //"Componente fora dos grupos de opcionais"
AADD(aOcorrencia,NIL) //"Componente fora das revisoes" - Nao existe na pre-estrutura
AADD(aOcorrencia,"PMSTASK6") //"Componente ok"
AADD(aOcorrencia,"PMSTASK1") //"Componente nao existente"

// Monta tree na primeira vez
If Empty(cProduto) .And. Len(aEstru) > 0
	cProduto:=aEstru[1,1]
	oObjTree:BeginUpdate()
	oObjTree:Reset()
	oObjTree:EndUpdate()
	// Coloca titulo no TREE
	SB1->(dbSeek(xFilial("SB1")+aEstru[1,1]))
	oObjTree:AddTree(AllTrim(aEstru[1,1])+" - "+Alltrim(Substr(SB1->B1_DESC,1,30))+Space(40),.T.,,,aOcorrencia[4],aOcorrencia[4],cCargoVazio)
EndIf

While nz <= Len(aEstru)
	// Verifica se componente tem pre-estrutura
	nAcho:=ASCAN(aEstru,{|x| x[1] == aEstru[nz,2]})
	// Monta Texto
	SB1->(dbSeek(xFilial("SB1")+aEstru[nz,2]))
	cTexto:=Alltrim(aEstru[nz,2])+" - "+Alltrim(Substr(SB1->B1_DESC,1,30))+Space(40)
	If nAcho > 0
		// Coloca titulo no TREE
		oObjTree:AddTree(cTexto,.T.,,,aOcorrencia[aEstru[nz,5]],aOcorrencia[aEstru[nz,5]],aEstru[nz,7])
		// Chama funcao recursiva
		A202TreeCm(oObjTree,aEstru,aEstru[nz,2],nAcho)
		// Encerra TREE
		oObjTree:EndTree()
	ElseIf aEstru[nz,1] == cProduto
		// Adiciona item no tree
		oObjTree:AddTreeItem(cTexto,aOcorrencia[aEstru[nz,5]],aOcorrencia[aEstru[nz,5]],aEstru[nz,7])
	EndIf
	nz++
End
RETURN(.T.)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Mt202Nav  � Autor �Rodrigo de A Sartorio  � Data � 04/11/2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Mantem o posicionamento das duas pre-estruturas               ���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe  � Mt202Nav(ExpN1,Exp01,Exp02,ExpA1,ExpA2)                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Codigo do Evento - 0 - Muda posicionamento           ���
���          �                          - 1 - Desce Linha   - 2 - Sobe linha���
���          � Exp01 = Tree da origem da comparacao                         ���
���          � Exp02 = Tree do destino da comparacao                        ���
���          � ExpA1 = Array com os dados da estrutura origem da comparacao ���
���          � ExpA2 = Array com os dados da estrutura destino da comparacao���
���������������������������������������������������������������������������Ĵ��
���Uso       �MATA202                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function Mt202Nav(nTipo,oTree,oTree2,aEstruOri,aEstruDest)
Local cCargoAtu  :=oTree2:GetCargo()
Local cCargoVazio:=Space(5+Len(SGG->GG_COMP+SGG->GG_TRT))
Local nPos       :=Ascan(aEstruDest,{|x| x[7] == cCargoAtu})

//����������������������������������������������������������������Ŀ
//�Posiciona o tree na linha de baixo
//������������������������������������������������������������������
If nTipo == 1 .And. nPos < Len(aEstruDest)
	oTree:TreeSeek(aEstruOri[nPos+1,7])
	oTree2:TreeSeek(aEstruDest[nPos+1,7])
	oTree:Refresh()
	oTree2:Refresh()
ElseIf nTipo == 2 .And. nPos >= 1
	oTree :TreeSeek(If(nPos-1<=0,cCargoVazio,aEstruOri[nPos-1,7]))
	oTree2:TreeSeek(If(nPos-1<=0,cCargoVazio,aEstruDest[nPos-1,7]))
	oTree:Refresh()
	oTree2:Refresh()
Else
	oTree:TreeSeek(If(nPos>0,aEstruOri[nPos,7],cCargoVazio))
	oTree2:TreeSeek(If(nPos>0,aEstruDest[nPos,7],cCargoVazio))
	oTree:Refresh()
	oTree2:Refresh()
EndIf
Return(.T.)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Mt202Inf  � Autor �Rodrigo de A Sartorio  � Data � 05/11/2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Legenda do comparador de estruturas                           ���
���������������������������������������������������������������������������Ĵ��
���Uso       �MATA202                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function Mt202Inf()
Local oDlg,oBmp1,oBmp2,oBmp3,oBmp4,oBmp5
Local oBut1
DEFINE MSDIALOG oDlg TITLE STR0031 OF oMainWnd PIXEL FROM 0,0 TO 202,550
@ 2,3 TO 080,273 LABEL STR0031 PIXEL //"Legenda"
@ 18,10 BITMAP oBmp1 RESNAME "PMSTASK1" SIZE 16,16 NOBORDER PIXEL
@ 18,20 SAY OemToAnsi(STR0030) OF oDlg PIXEL
@ 18,150 BITMAP oBmp2 RESNAME "PMSTASK6" SIZE 16,16 NOBORDER PIXEL
@ 18,160 SAY OemToAnsi(STR0029) OF oDlg PIXEL
@ 30,10 BITMAP oBmp4 RESNAME "PMSTASK5" SIZE 16,16 NOBORDER PIXEL
@ 30,20 SAY OemToAnsi(STR0028) OF oDlg PIXEL
@ 42,10 BITMAP oBmp5 RESNAME "PMSTASK4" SIZE 16,16 NOBORDER PIXEL
@ 42,20 SAY OemToAnsi(STR0027) OF oDlg PIXEL
DEFINE SBUTTON oBut1 FROM 085,244 TYPE 1  ACTION (oDlg:End())  ENABLE of oDlg
ACTIVATE MSDIALOG oDlg CENTERED
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �  A202Subs  � Autor �Rodrigo de A Sartorio� Data �23.06.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Substituicao de componentes na Estrutura                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202Subs                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function A202Subs(cAlias,nRecno,nOpcX)
Local aArea:=GetArea()
Local cCodOrig:=Criavar("GG_COMP",.F.),cCodDest:=Criavar("GG_COMP",.F.)
Local cGrpOrig:=Criavar("GG_GROPC",.F.),cGrpDest:=Criavar("GG_GROPC",.F.)
Local cDescOrig:=Criavar("B1_DESC",.F.),cDescDest:=Criavar("B1_DESC",.F.)
Local cOpcOrig:=Criavar("GG_OPC",.F.),cOpcDest:=Criavar("GG_OPC",.F.)
Local oSay,oSay2
Local lOk:=.F.
Local aAreaSX3:=SX3->(GetArea())
//��������������������������������������������������������������Ŀ
//� Variavel lPyme utilizada para Tratamento do Siga PyME        �
//����������������������������������������������������������������
Local lPyme:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)

dbSelectArea("SX3")
dbSetOrder(2)
If dbSeek("GG_OK")
	dbSelectArea("SX3")//manter provisoriamente por causa da mark browse
	dbSetOrder(1) //voltar para indice 1 do sx3
	dbSelectArea("SGG")
	DEFINE MSDIALOG oDlg FROM  140,000 TO 370,670 TITLE OemToAnsi(STR0032) PIXEL
	DEFINE SBUTTON oBtn FROM 800,800 TYPE 5 ENABLE OF oDlg
	@ 036,006 TO 066,320 LABEL OemToAnsi(STR0033) OF oDlg PIXEL
	@ 072,006 TO 102,320 LABEL OemToAnsi(STR0034) OF oDlg PIXEL
	@ 048,035 MSGET oProdOrig VAR cCodOrig   F3 "SB1" Picture PesqPict("SGG","GG_COMP") Valid NaoVazio(cCodOrig) .And. ExistCpo("SB1",cCodOrig) SIZE 115,09 OF oDlg PIXEL

	If !lPyme
		@ 048,195 MSGET cGrpOrig   F3 "SGA" Picture PesqPict("SGG","GG_GROPC") Valid Vazio(cGrpOrig) .Or. ExistCpo("SGA",cGrpOrig) SIZE 25,09 OF oDlg PIXEL
		@ 048,275 MSGET cOpcOrig   Picture PesqPict("SGG","GG_OPC") Valid IF(!Empty(cGrpOrig),NaoVazio(cOpcOrig).And.ExistCpo("SGA",cGrpOrig+cOpcOrig),Vazio(cOpcOrig)) SIZE 25,09 OF oDlg PIXEL
	EndIf

	@ 084,035 MSGET cCodDest   F3 "SB1" Picture PesqPict("SGG","GG_COMP") Valid NaoVazio(cCodDest) .And. ExistCpo("SB1",cCodDest) SIZE 115,9 OF oDlg PIXEL

	If !lPyme
		@ 084,195 MSGET cGrpDest   F3 "SGA" Picture PesqPict("SGG","GG_GROPC") Valid Vazio(cGrpDest) .Or. ExistCpo("SGA",cGrpDest) SIZE 25,09 OF oDlg PIXEL
		@ 084,275 MSGET cOpcDest   Picture PesqPict("SGG","GG_OPC") Valid IF(!Empty(cGrpDest),NaoVazio(cOpcDest).And.ExistCpo("SGA",cGrpDest+cOpcDest),Vazio(cOpcDest)) SIZE 25,09 OF oDlg PIXEL
	EndIf

	@ 058,030 SAY oSay Prompt cDescOrig SIZE 150,6 OF oDlg PIXEL
	@ 094,030 SAY oSay2 Prompt cDescDest SIZE 140,6 OF oDlg PIXEL
	@ 050,013 SAY OemtoAnsi(STR0022)   SIZE 34,7  OF oDlg PIXEL

	If !lPyme
		@ 050,160 SAY RetTitle("GG_GROPC") SIZE 42,13 OF oDlg PIXEL
		@ 050,240 SAY RetTitle("GG_OPC")   SIZE 30,7  OF oDlg PIXEL
	EndIf

	@ 086,013 SAY OemToAnsi(STR0022)   SIZE 34,7  OF oDlg PIXEL

	If !lPyme
		@ 086,160 SAY RetTitle("GG_GROPC") SIZE 42,13 OF oDlg PIXEL
		@ 086,240 SAY RetTitle("GG_OPC")   SIZE 30,7  OF oDlg PIXEL
	EndIf

	ACTIVATE MSDIALOG oDlg CENTER;
			ON INIT (EnchoiceBar(oDlg,{|| Iif(A202SubOK(cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest), (lOk := .T. , oDlg:End()), lOk := .F.)}, {|| (lOk := .F. , oDlg:End())}),;
					oProdOrig:SetFocus())

	// Processa substituicao dos componentes
	If lOk
		Processa({|| A202PrSubs(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest) })
	EndIf
Else
	Aviso(OemToAnsi(STR0036),OemToAnsi(STR0037),{"Ok"})
EndIf
SX3->(RestArea(aAreaSX3))
RestArea(aArea)
RETURN

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A202PrSubs  � Autor �Rodrigo de A Sartorio� Data �23.07.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta markbowse para selecao e substituicao dos componentes���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202PrSubs(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6)            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � True                                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do produto origem                           ���
���          � ExpC2 = Grupo de opcionais origem                          ���
���          � ExpC3 = Opcionais do produto origem                        ���
���          � ExpC4 = Codigo do produto destino                          ���
���          � ExpC5 = Grupo de opcionais destino                         ���
���          � ExpC6 = Opcionais do produto destino                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function A202PrSubs(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest)
Local cFilSGG     := ""
Local aIndexSGG   := {}
Local aBackRotina := ACLONE(aRotina)
Local lRet        := .T.
//��������������������������������������������������������������Ŀ
//� Variavel lPyme utilizada para Tratamento do Siga PyME        �
//����������������������������������������������������������������
Local lPyme:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)

PRIVATE aDadosDest:= {cCodDest,cGrpDest,cOpcDest}
PRIVATE cMarca202 := ThisMark()
PRIVATE cCadastro := OemToAnsi(STR0032)
PRIVATE aRotina   := {  {STR0035,"A202DoSub", 0 , 1}}

Default lAutomacao := .F.

If (Empty(cCodOrig) .Or. Empty(cCodDest))
	Help(" ",1,"A202OBRIG")
	lRet:=.F.
EndIF

If lRet
	cFilSGG := "GG_FILIAL='"+xFilial("SGG")+"'"
	cFilSGG += ".And.GG_COMP=='"+cCodOrig+"'"

	If lRestEst
		cFilSGG += ".And.GG_STATUS <> '5'"
		cFilSGG += ".And.GrpEng('" +RetCodUsr() +"',SGG->GG_USUARIO)"
	EndIf

	If !lPyme
		cFilSGG += ".And.GG_GROPC=='"+cGrpOrig+"'"
		cFilSGG += ".And.GG_OPC=='"+cOpcOrig+"'"
	EndIf

	If !IsProdProt(cCodOrig) .And. !IsProdProt(cCodDest)
		cFilSGG += " .And. .T. "
	Else
		cFilSGG += " .And. .F. "
	Endif

	//������������������������������������������������������������������������Ŀ
	//�Realiza a Filtragem                                                     �
	//��������������������������������������������������������������������������
	dbSelectArea("SGG")
	dbSetOrder(1)
	dbSelectArea("SGG")
	If !MsSeek(xFilial("SGG"))
		HELP(" ",1,"RECNO")
	Else
		//������������������������������������������������������������������������Ŀ
		//�Monta o browse para a selecao                                           �
		//��������������������������������������������������������������������������
		If !lAutomacao
			MarkBrow("SGG","GG_OK",,,,,,,,,,,,,,,,cFilSGG)
		EndIf
	EndIf

	//������������������������������������������������������������������������Ŀ
	//�Restaura condicao original                                              �
	//��������������������������������������������������������������������������
	dbSelectArea("SGG")
	RetIndex("SGG")
	dbClearFilter()
	aEval(aIndexSGG,{|x| Ferase(x[1]+OrdBagExt())})
	aRotina:=ACLONE(aBackRotina)
EndIf
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A202DoSub   � Autor �Rodrigo de A Sartorio� Data �23.07.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava a substituicao dos componentes                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A202DoSub()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA202                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function A202DoSub(cAlias,cCampo,nOpc,cMarca202,lInverte)
Local aRecnosSGG:={}
Local nz:=0
dbSelectArea("SGG")
dbSeek(xFilial("SGG"))
While !Eof() .And. GG_FILIAL == xFilial("SGG")
	// Verifica os registros marcados para substituicao
	If IsMark("GG_OK",cMarca202,lInverte)
		AADD(aRecnosSGG,Recno())
	EndIf
	dbSkip()
End
// Grava a substituicao de componentes

If Len(aRecnosSGG) < 1001  //tratamento para oracle pois tem limite de 1000 itens no "IN"
	cQuery := "UPDATE "
	cQuery += RetSqlName("SGG")+" "
	cQuery += "SET GG_COMP = '"+aDadosDest[1]+"' , GG_GROPC = '"+aDadosDest[2]+"' , GG_OPC = '"+aDadosDest[3]+"'"
	cQuery += " WHERE GG_COD <> '"+aDadosDest[1]+"' AND R_E_C_N_O_ IN ("
	For nz:=1 to Len(aRecnosSGG)
		If nz > 1
			cQuery+= ","
		EndIf
		cQuery+= "'"+Str(aRecnosSGG[nz],10,0)+"'"
	Next nz
	cQuery += ")"
	TcSqlExec(cQuery)
Else
	For nz:=1 to Len(aRecnosSGG)
		cQuery := "UPDATE "
		cQuery += RetSqlName("SGG")+" "
		cQuery += "SET GG_COMP = '"+aDadosDest[1]+"' , GG_GROPC = '"+aDadosDest[2]+"' , GG_OPC = '"+aDadosDest[3]+"'"
		cQuery += " WHERE GG_COD <> '"+aDadosDest[1]+"' AND R_E_C_N_O_ = "
		cQuery+= "'"+Str(aRecnosSGG[nz],10,0)+"'"

		TcSqlExec(cQuery)
	Next nz
EndIf


If lRestEst
	For nz:=1 to Len(aRecnosSGG)
		SGG->(dbGoto(aRecnosSGG[NZ]))
		Reclock("SGG",.F.)
		Replace GG_STATUS With '1'
		MsUnlock()
	Next nz
EndIf

// Altera conteudo do parametro de niveis
If Len(aRecnosSGG) > 0
	a202NivAlt()
EndIf
RETURN

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �A202Lege  �Rev.   �Rodrigo de A Sartorio  � Data �08.03.2005 ���
��������������������������������������������������������������������������Ĵ��
���          �Demonstra a legenda das cores da mbrowse                     ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina monta uma dialog com a descricao das cores da    ���
���          �Mbrowse.                                                     ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function A202Lege()

Local aCores := {}
Local aLegUsr  := {}
Local nCnt     := 0

Default lAutomacao := .F.

aAdd(aCores,{"BR_AMARELO"	,STR0052})
aAdd(aCores,{"BR_VERDE"		,STR0053})
aAdd(aCores,{"BR_VERMELHO"  ,STR0054})
aAdd(aCores,{"BR_AZUl"		,STR0055})
If(SuperGetMv('MV_APRESTR',.F.,.F.),aAdd(aCores,{"BR_LARANJA"	,STR0083}),"")

//��������������������������������������������������������������Ŀ
//� Ponto de Entrada para adicionar legendas na Dialog           �
//����������������������������������������������������������������
If ExistBlock("MT202LEG")
	aLegUsr := ExecBlock("MT202LEG",.F.,.F., { 2 })
	If ValType(aLegUsr) <> "A"
		aLegUsr := {}
	EndIf
	For nCnt := 1 To Len(aLegUsr)
		Aadd( aCores , { aLegUsr[nCnt,1],aLegUsr[nCnt,2] } )
	Next nCnt
EndIf
If !lAutomacao
	BrwLegenda(cCadastro,STR0031,aCores)
EndIf
Return (.T.)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �A202Aprova�Rev.   �Rodrigo de A Sartorio  � Data �08.03.2005 ���
��������������������������������������������������������������������������Ĵ��
���          �Grava o status de aprovacao / rejeicao nos itens da pre-estr ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function A202Aprova(cProduto,nOkAceRj,nValPre)
Local cAlias  := Alias()
Local cNomeArq   := ""
Local oTempTable := NIL
Private	nEstru:=0
cNomeArq := Estrut2(cProduto,NIL,NIL,@oTempTable,NIL,.T.)
dbSelectArea('ESTRUT')
ESTRUT->(dbGotop())
ProcRegua(Lastrec())
Do While !ESTRUT->(Eof())
	IncProc()
	// Caso tenha aceitado somente primeiro nivel valida
	If nOkAceRj == 2 .And. Val(ESTRUT->NIVEL) > 1
		ESTRUT->(dbSkip())
		Loop
	EndIf
	SGG->(dbGoto(ESTRUT->REGISTRO))
	Reclock("SGG",.F.)
	//��������������������������������������������������������������Ŀ
	//� Definicao dos status da pre-estrutura para controle de alcada�
	//� ------------- Status da pre-estrutura sao: -------------     �
	//� 1 - Em criacao					                             �
	//� 2 - Pre-estrutura aprovada                                   �
	//� 3 - Pre-estrutura rejeitada			                         �
	//� 4 - Estrutura criada							             �
	//� 5 - Submetida a aprovacao                                    �
	//����������������������������������������������������������������
	If nValPre == 1
		Replace GG_STATUS With "2"
	// Grava rejeicao
	ElseIf nValPre == 2
		Replace GG_STATUS With "3"
	EndIf
	Replace GG_USUARIO With IIF(!lRestEst,Subs(cUsuario,7,6),RetCodUsr())
	MsUnlock()
	ESTRUT->(dbSkip())
EndDo
FimEstrut2(Nil,oTempTable)
dbSelectArea(cAlias)

If nValPre == 1
	If ExistBlock ("MTA202APROV")
		ExecBlock ("MTA202APROV",.F.,.F.,{cProduto})
	Endif
EndIf

RETURN

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �A202CodDes�Rev.   �Rodrigo de A Sartorio  � Data �08.03.2005 ���
��������������������������������������������������������������������������Ĵ��
���          �Valida o codigo destino da estrutura                         ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function A202CodDes(cNomePai)
Local lRet:=ExistCpo("SB1",cNomePai)
SG1->(dbSetOrder(1))
If lRet
	If SG1->(dbSeek(xFilial("SG1")+cNomePai))
		Aviso(OemToAnsi(STR0036),STR0080,{"Ok"})
	EndIf
EndIf
Return lRet

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �A202PrG1  �Rev.   �Rodrigo de A Sartorio  � Data �09.03.2005 ���
��������������������������������������������������������������������������Ĵ��
���          �Chama a funcao de gravacao atraves da processa para regua    ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                         ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function A202PrG1(cProduto,nNivelCal,nTipoItens,nTipoData,dDataIni,dDataFim,nTipoSobre,nTipoApaga,lMudaNome,cNomePai)
Processa({|| A202GravG1(cProduto,nNivelCal,nTipoItens,nTipoData,dDataIni,dDataFim,nTipoSobre,nTipoApaga,lMudaNome,cNomePai) })
Return .T.

/*
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �A202GravG1�Rev.   �Rodrigo de A Sartorio  � Data �08.03.2005 ���
��������������������������������������������������������������������������Ĵ��
���          �Grava preestrutura como estrutura                            ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
���cProduto  � Codigo do produto origem                                    ���
���nNivelCal � Leitura dos itens     - 1 Todos niveis  2 - Primeiro nivel  ���
���nTipoItens� Leitura dos itens     - 1 Aprovados     2 - Rejeitados      ���
���          �                         3 - Todos                           ���
���nTipoData � Leitura dos itens     - 1 Qualquer data 2 - Data valida     ���
���          �                         3 - Data de/ate                     ���
���dDataIni  � Leitura dos itens     - data limite inicial para filtragem  ���
���dDataFim  � Leitura dos itens     - data limite final para filtragem    ���
���nTipoSobre� Gravacao dos itens    - 1 Sobrescreve   2 - Mantem          ���
���nTipoApaga� Pre estrutura gravada - 1 Apaga         2 - Mantem          ���
���lMudaNome � Nome do produto pai   - T Muda          F - Mantem          ���
���cNomePai  � Novo nome do produto pai                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function A202GravG1(cProduto,nNivelCal,nTipoItens,nTipoData,dDataIni,dDataFim,nTipoSobre,nTipoApaga,lMudaNome,cNomePai)
Local cAlias     := Alias()
Local aCodiSeek  :={}
Local aNomePos   :={}
Local aRegsSGG   :={}
Local aAliasAnt  :={}
Local cNomeArq   := ""
Local cCodiSeek  := ""
Local cProPai    := ""
Local cRevAtual  := ""
Local cAliasB1BZ := If(GetMv('MV_ARQPROD')=="SBZ","SBZ","SB1")
Local cCpoDest   := If(cAliasB1BZ=="SBZ","BZ_QB","B1_QB")
Local cRevIni    := CriaVar("G1_REVINI")
Local cRevFim    := CriaVar("G1_REVFIM")
Local lIntSFC	 := IntegraSFC()
Local lRevAut    := SuperGetMv("MV_REVAUT" ,.F.,.F.)
Local lPCPREVATU := FindFunction('PCPREVATU')
Local lGravouSG1 :=.F.
Local lQBase     :=.T.
Local lAchouCod  :=.F.
Local lArqRev    :=.F.
Local nx         :=0
Local nISGG      :=0
Local cNomeCamp  :=0
Local nPosicao   :=0
Local oTempTable := NIL

Private	nEstru := 0

//Carrega perguntas do MTA200 e MATA202
Pergunte("MTA200", .F.)
lArqRev := MV_PAR02 == 1
Pergunte('MTA202', .F.)

// Muda ordem Codigo + Componente
SG1->(dbSetOrder(1))
// Cria arquivo de trabalho com a estrutura completa
cNomeArq := Estrut2(cProduto,NIL,NIL,@oTempTable,NIL,.T.,.F.,,.F.)
// Percorre arquivo para atualizar estrutura
dbSelectArea('ESTRUT')
ESTRUT->(dbGotop())
ProcRegua(Lastrec())
Begin Transaction
Do While !ESTRUT->(Eof())
	IncProc()
	// Caso tenha aceitado somente primeiro nivel valida
	If nNivelCal == 2 .And. Val(ESTRUT->NIVEL) > 1
		ESTRUT->(dbSkip())
		Loop
	EndIf
	SGG->(dbGoto(ESTRUT->REGISTRO))
	/* Caso o paramento MV_APRESTR esteja habilitado somente devera ser gerado a estrutura para aquelas que foram
	aprovadas pelo grupo de aprovavao do controle de alcada */
	If (lRestEst .And. SGG->GG_STATUS <> "2")
		ESTRUT->(dbSkip())
		Loop
	EndIf
	// Verifica o tipo de item a ser considerado
	If (nTipoItens == 1 .And. SGG->GG_STATUS <> "2") .Or. (nTipoItens == 2 .And. SGG->GG_STATUS <> "3")
		dbSkip()
		Loop
	EndIf
	// Valida data com database
	If nTipodata == 2 .And. ((dDataBase < SGG->GG_INI)  .Or. (dDataBase > SGG->GG_FIM))
		dbSkip()
		Loop
	EndIf
	// Valida data com data de parametros
	If nTipodata == 3 .And. ((dDataIni < SGG->GG_INI)  .And. (SGG->GG_INI > dDataFim))
		dbSkip()
		Loop
	EndIf
	dbSelectArea("SG1")
	// Verifica qual o nome a ser alterado
	If lMudaNome .And. !Empty(cNomePai) .And. Val(ESTRUT->NIVEL) == 1
		cCodiSeek:=cNomePai
	Else
		cCodiSeek:=SGG->GG_COD
	EndIf
	lAchouCod:=dbSeek(xFilial("SG1")+cCodiSeek)
	// Processa gravacao se nao achou codigo ou se permite sobreposicao
	If nTipoSobre == 1 .Or. (nTipoSobre == 2 .And. !lAchouCod)
		lGravouSG1:=.T.
		// Sobrepoe estrutura caso necessario
		If lAchouCod .And. !lRevAut .And. !lArqRev
			While !EOF() .And. 	xFilial("SG1")+cCodiSeek == G1_FILIAL+G1_COD
				Reclock("SG1",.F.)
				dbDelete()
				MsUnlock()
				dbSkip()
			End
		EndIf
		// Array com caracteristicas de campo
		// Criado para acelerar o processo evitando fieldpos e fieldname a todo momento
		If Len(aNomePos) == 0
			For nx:=1 to SGG->(FCount())
				cNomeCamp:="G1_"+Substr(SGG->(FieldName(nx)),4)
				nPosicao :=SG1->(FieldPos(cNomeCamp))
				// Grava todos os campos de SGG (mesmo nao existindo em SG1)
				// Array com
				// 1 Nome do campo no SG1
				// 2 Posicao do campo no SG1
				// 3 Posicao do campo no SGG
				Aadd(aNomePos,{cNomecamp,nPosicao,nx})
			Next nx
		EndIf
		//Carrega as informacoes do registro SGG
		nISGG++
		Aadd(aCodiSeek,cCodiSeek)
		Aadd(aRegsSGG,Array(SGG->(FCount())))
		For nx:=1 to SGG->(FCount())
			aRegsSGG[nISGG,nx] := SGG->(FieldGet(nx))
		Next
		// Grava status atualizado
		Reclock("SGG",.F.)
		If lMudaNome .And. !Empty(cNomePai) .And. Val(ESTRUT->NIVEL) == 1
			// Novo codigo do produto
			Replace GG_COD With cNomePai
		EndIf
		Replace GG_STATUS With "4"
		Replace GG_USUARIO With IIF(!lRestEst,Subs(cUsuario,7,6),RetCodUsr())
		If nTipoApaga == 1
			dbDelete()
		EndIf
		MsUnlock()
		// Grava qtd base no SB1
		If Val(ESTRUT->NIVEL) == 1 .And. lQBase
			aAliasAnt := GetArea()
			dbSelectArea(cAliasB1BZ)
			(cAliasB1BZ)->(dbSetOrder(1))
			If (cAliasB1BZ)->(dbSeek(xFilial(cAliasB1BZ)+SGG->GG_COD))
				If Substr(cCpoDest,1,2) == "B1"
					SB1->(dbSeek(xFilial("SB1")+SGG->GG_COD))
				EndIf
				Reclock(If(cCpoDest=="BZ_QB","SBZ","SB1"),.F.)
				If cAliasB1BZ == "SBZ"
					Replace &(cCpoDest) With SBZ->BZ_QBP
				Else
					Replace &(cCpoDest) With SB1->B1_QBP
				EndIf
				MsUnlock()
			Else
				SB1->(dbSeek(xFilial("SB1")+SGG->GG_COD))
				RecLock("SB1",.F.)
				Replace SB1->B1_QB With SB1->B1_QBP
				MsUnLock()
			EndIf
			lQBase:=.F.
			RestArea(aAliasAnt)
		EndIf
	EndIf
	dbSelectArea('ESTRUT')
	dbSkip()
EndDo
If lGravouSG1
	DbSelectArea("SB1")
	DbSetOrder(1)
	SB1->(dbseek(xFilial("SB1")+cCodiSeek)) 
	cRevAtual := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
	//Le as informacoes dos registros de SGG contidas no array e grava as mesmas no arquivo SG1 
	For nISGG:=1 to Len(aRegsSGG)
		IF (lRevAut .Or. lArqRev)
		    cRevIni := ""
			If SG1->(dbSeek(xFilial("SG1")+cCodiSeek+aRegsSGG[nISGG,3]+aRegsSGG[nISGG,4]))
				DbSelectArea("SGG")
				DbSetOrder(1)
				If SGG->(dbSeek(xFilial("SGG")+cCodiSeek+aRegsSGG[nISGG,3]+aRegsSGG[nISGG,4]))
					If (SG1->G1_REVFIM == cRevAtual) .and. (SG1->G1_QUANT == SGG->GG_QUANT) 
						cRevIni := SG1->G1_REVINI
					EndIf
				EndIf
			EndIf 
			IF cProPai <> 	aCodiSeek[nISGG]
				cRevFim  := A200Revis(aCodiSeek[nISGG],.F.)
			EndIf
			IF empty(cRevIni)
				cRevIni  := cRevFim
			EndIf 			
			cProPai := aCodiSeek[nISGG]
		EndIf
		dbSelectArea("SG1")
		cCodiSeek := aCodiSeek[nISGG]
		Begin Transaction
		// Se ainda n�o existe o componente na estrutura ou se ele estava fora de uso. 
		If !dbSeek(xFilial("SG1")+cCodiSeek+aRegsSGG[nISGG,3]+aRegsSGG[nISGG,4]) .or. (cRevIni  == cRevFim)
			Reclock("SG1",.T.)
			For nx:=1 to Len(aNomePos)
				If aNomePos[nx,2] > 0  // Verifica se campo existe em SG1
					FieldPut(aNomePos[nx,2],aRegsSGG[nISGG,nx])
		    		EndIf
			Next nx
			// Grava informacoes especificas
			// Filial
			G1_FILIAL := xFilial("SG1")
			G1_COD	  := cCodiSeek		//Incluido para nao gerar erro se o codigo do pai for alterado
			Replace G1_REVINI With cRevIni
			Replace G1_REVFIM With cRevFim
		Else
			Reclock("SG1",.F.)
			Replace G1_REVFIM With cRevFim
			For nX := 1 To Len(aNomePos)
				If aNomePos[nx,2] > 0  //Verifica se campo existe em SG1
					If lRevAut
						//Se for revis�o autom�tica, considera a pr�xima revis�o no G1_REVINI e G1_REVFIM
						If aNomePos[nx,1] == "G1_REVINI"
							FieldPut(aNomePos[nx,2],cRevIni)
						ElseIf aNomePos[nx,1] == "G1_REVFIM"
							FieldPut(aNomePos[nx,2],cRevFim)
						ElseIf aNomePos[nx,1] == "G1_FILIAL"
							FieldPut(aNomePos[nx,2],xFilial("SG1"))
						Else 
							FieldPut(aNomePos[nx,2],aRegsSGG[nISGG,nx])
						EndIf
					Else
						FieldPut(aNomePos[nx,2],aRegsSGG[nISGG,nx])
					EndIf
		    	EndIf
			Next nX
		EndIf
		MsUnlock()
		If lIntSFC
			A200IntSFC(aCodiSeek[nISGG],'2')
		EndIf
		End Transaction
	Next
	// Atualiza parametro para recalcular nivel das estruturas
	a200NivAlt()
EndIf
End Transaction
FimEstrut2(Nil,oTempTable)
dbSelectArea(cAlias)

If ExistBlock ("MTA202CRIA")
	ExecBlock ("MTA202CRIA",.F.,.F.,{cProduto,cNomePai})
Endif

RETURN .T.

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �03/10/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef(lRestEst)
Private aRotina	 := {}
Default lRestEst := .F.

aAdd(aRotina, {OemToAnsi(STR0002), 'AxPesqui' , 0, 1,0,.F.})   //pesq
aAdd(aRotina, {OemToAnsi(STR0003), 'a202Proc' , 0, 2,0,nil})   //visu
aAdd(aRotina, {OemToAnsi(STR0004), 'a202Proc' , 0, 3,0,nil})   //inclui
aAdd(aRotina, {OemToAnsi(STR0005), 'a202Proc' , 0, 4,0,nil})   //altera
aAdd(aRotina, {OemToAnsi(STR0006), 'a202Proc' , 0, 5,0,nil})   //exclui
aAdd(aRotina, {OemToAnsi(STR0018), 'a202CEst' , 0, 6,0,nil})   //compara
aAdd(aRotina, {OemToAnsi(STR0035), 'a202Subs' , 0, 6,0,nil})   //substitui
If !lRestEst
	aAdd(aRotina, {OemToAnsi(STR0040), 'a202Proc' , 0, 4,0,nil}) //"Aprovar/Rejeitar"
Else
	aAdd(aRotina, {STR0096, 'a202Proc' , 0, 8,0,nil}) //"Enc. Aprovacao"
	aAdd(aRotina, {STR0097, 'a202Log' , 0, 2,0,nil}) //"Log. Aprovacao"
EndIf
aAdd(aRotina, { OemToAnsi(STR0041), 'a202Proc' , 0, 5,0,nil})   //"Criar Estrutura"
aAdd(aRotina, { OemToAnsi(STR0031), 'a202Lege' , 0, 2,0,.F.})    //Legenda

If ExistBlock ("MTA202MNU")
	ExecBlock ("MTA202MNU",.F.,.F.)
Endif

aBkpARot := ACLONE(aRotina)
Return (aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A200QBase  � Autor �Fernando Joly/Eduardo� Data �19.05.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consiste a Quantidade Basica da Estrutura                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A200QBase(ExpN1,ExpN2,ExpC1,ExpC2,ExpO1,ExpO2)             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Quantidade Basica Digitada                         ���
���          � ExpN2 = Op��o Escolhida                                    ���
���          � ExpC1 = codigo produto                                     ���
���          � ExpC2 = codigo produto similar                             ���
���          � ExpO1 = Objeto Tree                                        ���
���          � ExpO2 = Objeto Dlg                                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � True se a Quantidade Base for Maior que Zero, ou False C.C.���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function A202QBase(nQtdBase, nOpcX, cProduto, cCodSim, oTree, oDlg)
Local lRet := .T.
If QtdComp(nQtdBase) < QtdComp(0) .And. !GetMV('MV_NEGESTR')
	Help(' ',1,'MA200QBNEG')
	lRet := .F.
EndIf

If lRet
	nQtdBasePai := M->G1_QUANT := nQtdBase

	If !ldbTree
		ldbTree := .T.
		If nOpcX < 5
			cCodAtual := cProduto
			Ma202Monta(oTree, oDlg, cCodAtual, cCodSim,nOpcX)
			oTree:TreeSeek(oTree:GetCargo())
		EndIf
	EndIf
EndIf
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A206Visual� Autor � Rodrigo T. Silva 	    � Data �30/10/2010���
�������������������������������������������������������������������������Ĵ��
���DeSGNi��o � Programa de visualiza�ao da pre-estrutura				  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A206Visual(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A202Log(cAlias,nRecno)
Local aAreaAnt  := GetArea()
Local aHeadCols := {STR0098,STR0091,STR0100,STR0101,STR0102,STR0103}
Local aHeadSize := {30,20,40,100,38,100}
Local cTitle    := STR0104 +AllTrim(SGG->GG_COD)
Local cTipoLib  := ""
Local cStatus	:= ""
Local aBrowse   := {}
Local lRet		:= .F.
Default lAutomacao := .F.
If !lAutomacao
	If !(GrpEng(RetCodUsr(),SGG->GG_USUARIO))
		Aviso(OemToAnsi(STR0105),STR0106,{"Ok"})
		RETURN
	EndIf
EndIf

SGG->(dbSetOrder(1))
SGG->(dbGoto(nRecno))

dbSelectArea("SGN")
dbSetOrder(1)
If dbSeek(xFilial("SGN")+"SGG"+SGG->GG_COD)
	Do While !SGN->(Eof()) .And. SGN->GN_FILIAL+SGN->GN_TIPO+SGN->GN_NUM == xFilial("SGN")+"SGG"+	SGG->GG_COD
		Do Case
			Case SGN->GN_TIPOLIB == 'U'
				cTipoLib := STR0090
			Case SGN->GN_TIPOLIB == 'N'
				cTipoLib := STR0091
			Case SGN->GN_TIPOLIB == 'E'
				cTipoLib := STR0092
		EndCase

		Do Case
			Case SGN->GN_STATUS = '01'
				cStatus = STR0107
			Case SGN->GN_STATUS = '02'
				cStatus = STR0108
			Case SGN->GN_STATUS = '03'
				cStatus = STR0109
			Case SGN->GN_STATUS = '04'
				cStatus = STR0110
			Case SGN->GN_STATUS = '05'
				cStatus = STR0111
			Case SGN->GN_STATUS = '06'
				cStatus = STR0112
			Case SGN->GN_STATUS = '07'
				cStatus = STR0113
			Case SGN->GN_STATUS = '08'
				cStatus = STR0114
		EndCase
    	aAdd(aBrowse, {UsrRetName(SGN->GN_USER),SGN->GN_NIVEL,cTipoLib,cStatus,SGN->GN_DATALIB,SGN->GN_OBS})
		SGN->(dbSkip())
	EndDo
Else
	Aviso(OemToAnsi(STR0036),OemToAnsi(STR0089),{"Ok"})
	lRet := .T.
EndIf

If !lRet
	DEFINE MSDIALOG oDialog FROM 000,000 TO 300,980 TITLE cTitle OF oMainWnd PIXEL

	oBrowse := TWBrowse():New(01,01,500,150,,aHeadCols,aHeadSize,oDialog,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.F.,.T.)
	oBrowse:SetArray(aBrowse)
	oBrowse:bLine := { || aBrowse[oBrowse:nAT] }

	ACTIVATE MSDIALOG oDialog CENTERED
EndIf
RestArea(aAreaAnt)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A202CriSGN�Autor  �Rodrigo T. Silva    � Data �  23/11/10   ���
�������������������������������������������������������������������������͹��
���Descricao �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MATA202                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A202CriSGN(cProduto,cUsuario,cGrupoEng,lTodosNiv)
Local aArea    := GetArea()
Local aAreaSGG := SGG->(GetArea())
Local lRegSGn := .F.

//-- Deleta aprovacao anterior caso rejeitada
A202DelSGN(cProduto,.T.)


//-- Gera registro p/ aprovacao e chama recursivo para outros niveis
If SGG->(dbSeek(xFilial("SGG")+cProduto))
	MaAlcEng({PADR(cProduto,30),"SGG",cUsuario,cGrupoEng,""},,1,@lRegSGn)
	While !SGG->(EOF()) .And. SGG->(GG_FILIAL+GG_COD) == xFilial("SGG")+cProduto
		//Atualiza status
		IF ! lRegSGn
			RecLock('SGG',.F.)
			Replace GG_STATUS With "5"
			MsUnlock()
		EndIf

		If lTodosNiv
			A202CriSGN(SGG->GG_COMP,cUsuario,cGrupoEng)
		EndIf

		SGG->(dbSkip())
	End
EndIf

RestArea(aAreaSGG)
RestArea(aArea)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA202   �Autor  �Andre Anjos         � Data �  25/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao recursiva para exluir as pre-estruturas que foram   ���
���          � rejeitadas.                                                ���
�������������������������������������������������������������������������͹��
���Uso       � MATA202                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A202DelSGN(cChave,lSubmit)
Local aArea   := GetArea()
Local aAreaSGG := SGG->(GetArea())

Default cChave  := SGG->GG_COD
Default lSubmit := .F.

If SGG->(dbSeek(xFilial("SGG")+cChave)) .And. SGG->GG_STATUS <> If(lSubmit,'2','3')
	SGN->(dbSetOrder(1))
	SGN->(dbSeek(xFilial("SGN")+"SGG"+cChave))
	While !SGN->(EOF()) .And. SGN->(GN_FILIAL+GN_TIPO+GN_NUM) == xFilial("SGN")+"SGG"+cChave
		If SGN->GN_STATUS == '04' .Or. SGG->GG_STATUS == '1'
			SGN->(dbSeek(xFilial("SGN")+"SGG"+cChave))
			While !SGN->(EOF()) .And. SGN->(GN_FILIAL+GN_TIPO+GN_NUM) == xFilial("SGN")+"SGG"+cChave
				Reclock("SGN",.F.)
				SGN->(dbDelete())
				SGN->(MsUnlock())
				SGN->(dbSkip())
			End
			Exit
		EndIf
		SGN->(dbSkip())
	End
EndIf

RestArea(aAreaSGG)
RestArea(aArea)
Return

/*/{Protheus.doc} A202SubOK
Valida��o final da Substitui��o de Pr�-Estrutura
@author Carlos Alexandre da Silveira
@since 20/06/2019
@version 1.0
@param 01 - cCodOrig, caracter, C�digo do produto origem
@param 02 - cGrpOrig, caracter, Grupo de opcionais origem
@param 03 - cOpcOrig, caracter, Opcionais do produto origem
@param 04 - cCodDest, caracter, C�digo do produto destino
@param 05 - cGrpDest, caracter, Grupo de opcionais destino
@param 06 - cOpcDest, caracter, Opcionais do produto destino
@return lRet, l�gico, False caso ocorra algum problema na valida��o True OK
/*/
Static Function A202SubOK(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest)
	Local lRet := .T.

	//Valida a utiliza��o do conceito de vers�o da produ��o em conjunto com o conceito de componentes opcionais
	If AliasInDic("SVC") .And. (!Empty(cGrpDest) .Or. !Empty(cOpcDest))
		dbSelectArea("SVC")
		dbSetOrder(1)
		If SVC->(DbSeek(xFilial("SVC")))
			Help( ,  , "Help", ,  STR0123,;  //"N�o � permitido utilizar a vers�o da produ��o em conjunto com o conceito de Componentes Opcionais."
			1, 0, , , , , , {STR0124})  //"Para a utiliza��o dos opcionais, n�o pode haver vers�o de produ��o cadastrada."
			lRet := .F.
		EndIf
	EndIf

Return lRet
