#INCLUDE "PROTHEUS.CH"
#INCLUDE "QDOA060.CH"
                      
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QDOA060    � Autor � Eduardo de Souza   � Data � 22/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Manutencao da Devolucao de Revisao Anterior (Copia Papel) ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � QDOA060()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � SIGAQDO                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���  Data  � BOPS �Programador� Alteracao                                 ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function MenuDef()

Local cFilPend := GetMv("MV_QDOPDEV",.F.,"S")
Local aRotina  := {{OemToAnsi(STR0002), "AxPesqui", 0,1,,.F.},; //"Pesquisar"
					{OemToAnsi(STR0010), "QD060Telas",0,2},; //"Visualizar"
					{OemToAnsi(STR0003), "QD060Telas",0,3}}  //"Baixar"

//If cFilPend == "N"
//	Aadd(aRotina, {OemToAnsi(STR0004),"QD060Sele",0,6,,.F.}) // "Muda Selecao"
//EndIf
Aadd(aRotina,{OemToAnsi(STR0005),"QD060Legen",	0,6,,.F.}) // "Legenda"

Return aRotina

Function QDOA060()

Local aCores := {}
Local aUsrMat:= QA_USUARIO()

Private cFilPend := GetMv("MV_QDOPDEV",.F.,"S")
Private lFunDev  := .F.
Private cMatFil  := aUsrMat[2]
Private cMatCod  := aUsrMat[3]
Private cMatDep  := aUsrMat[4]
Private cCadastro:= OemToAnsi(STR0001) // "Devolucao de Revisao"
Private aRotina  := MenuDef() 

DbSelectArea("QDU")
QDU->(DbSetOrder(1))
aCores := {{"QDU->QDU_PENDEN == 'B'", 'ENABLE' },;
		  { "QDU->QDU_PENDEN == 'P'", 'BR_AMARELO'}}

If cFilPend == "S"
	MsgRun(OemToAnsi(STR0008),OemToAnsi(STR0009),{ || QD060Fil()}) //"Selecionando Dados" ### "Aguarde..."
	QD060Pend(.T.) // Verifica se Existe solicitacao em Analise
EndIf     
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'QDU' )
oBrowse:SetDescription( cCadastro )  
oBrowse:AddLegend( "QDU->QDU_PENDEN == 'B'", 'ENABLE', 		STR0007 )//"Baixado"
oBrowse:AddLegend( "QDU->QDU_PENDEN == 'P'", 'BR_AMARELO', STR0006)  //"Pendente"
If cFilPend == "N"
	oBrowse:AddFilter("Muda Sele��o","QDU->QDU_PENDEN == 'P'")		
EndIf
oBrowse:Activate()

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QD060Telas� Autor � Eduardo de Souza      � Data � 22/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela Devolucao de Revisao                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QD060Telas(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias do arquivo                                   ���
���          � ExpN1 - Numero do registro                                 ���
���          � ExpN2 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQDO                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QD060Telas(cAlias,nReg,nOpc)

Local oDlg
Local nI     	:= 0
Local nPosQDU	:= QDU->(Recno())
Local cFilQdu	:= If(xFilial("QDU") <> xFilial("QD1"), xFilial("QD1"), QDU->QDU_FILIAL)

Private bCampo:= {|nCPO| Field( nCPO ) }

QD1->(DbSetOrder(7))
If !QD1->(DbSeek(cFilQdu+QDU->QDU_DOCTO+QDU->QDU_RV+cMatDep+cMatFil+cMatCod+"I"))
	Help(" ",1,"QD_USRNDST") // Usuario nao e Distribuidor
	Return .F.
EndIf

If nOpc <> 2 .And. QDU->QDU_PENDEN == "B"
	Help(" ",1,"QD060JBX") // "Devolucao da Revisao Anterior do Documento ja Baixada"
	Return .F.
EndIf

DbSelectArea("QDU")
QDU->(DbSetOrder(1))
For nI := 1 To FCount()
	M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
Next nI

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 000,000 TO 385,625 OF oMainWnd PIXEL //"Devolucao de Revisao"

Enchoice("QDU",nReg,2,,,,,{033,003,190,312})     

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(nOpc == 3,If(QD060BxDev(),(QD060Pend(.F.),oDlg:End()),.F.),oDlg:End())},{|| oDlg:End()}) CENTERED

QDU->(DbGoto(nPosQDU))

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �QD060Legen� Autor �Eduardo de Souza       � Data � 22/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Cria uma janela contendo a legenda da mBrowse              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QD060Legen( )              										  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � QDOA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QD060Legen()

Local aLegenda := {}

Aadd(aLegenda, {'BR_AMARELO', OemtoAnsi(STR0006)}) // "Pendente"
Aadd(aLegenda, {'ENABLE'    , OemtoAnsi(STR0007)}) // "Baixada"

BrwLegenda(cCadastro,OemtoAnsi(STR0005),aLegenda) 	// "Legenda"

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QD060Sele � Autor �Eduardo de Souza       � Data � 22/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Filtra os Lancamtos Pendentes/Baixados de Devolucao        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QD060Sele()                                                ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � QDOA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QD060Sele

lFunDev:= !lFunDev
If !lFunDev
	DbSelectArea("QDU")
	QDU->(DbGotop())
	cFilter:=''
Else
	MsgRun(OemToAnsi(STR0008),OemToAnsi(STR0009),{ || QD060Fil()}) //"Selecionando Dados" ### "Aguarde..."
	QD060Pend(.T.) // Verifica se Existe Devolucao de Revisao Pendente
Endif

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 � QD060Fil � Autor �Eduardo de Souza       � Data � 22/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Filtra os Lactos Pendentes                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QD060Fil()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � QDOA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QD060Fil()

Local cFiltro:= "QDU->QDU_PENDEN == 'P'"
cfilter:=cFiltro
DbSelectArea("QDU")
Set Filter To &(cFiltro)   
QDU->(DbGotop())

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 � QD060Pend� Autor �Eduardo de Souza       � Data � 22/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Verifica se existe Lancamentos de Devolucao Pendente       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QD060Pend(ExpL1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpL1 - Apresenta Help (.T./.F.)                           ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � QDOA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QD060Pend(lHelp)

QDU->(DbSeek(xFilial("QDU")))
If QDU->(Eof())
	If cFilPend == "N"
		If lHelp
			Help(" ",1,"QD060NPEND") // "Nao existe Devolucao de Revisao de Documento Pendente"
		EndIf
		DbSelectArea("QDU")
		QDU->(DbGotop())
		lFunDev:= .F.
	EndIf
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QD060BxDev� Autor �Eduardo de Souza       � Data � 22/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Baixa Devolucao de Revisao                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QD060BxDev()                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � QDOA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QD060BxDev()

Local oCopPen
Local oCopDev
Local oJustif
Local oBtn1
Local nCopPen:= QDU->QDU_COPPEN
Local nCopDev:= 0
Local nOpc1  := 0
Local nTamJus:= TamSx3("QDU_JUSTIF")[1]
Local cJustif:= Space(nTamJus)

DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(STR0013) FROM 000,000 TO 138,340 OF oMainWnd PIXEL // "Numero de Copias Devolvidas"

@ 010,003 SAY OemToAnsi(STR0014) SIZE 050,010 OF oDlg1 PIXEL // "Copias Pendentes"
@ 009,055 MSGET oCopPen VAR nCopPen SIZE 033,008 OF oDlg1 PIXEL
oCopPen:lReadOnly:= .T.

@ 023,003 SAY OemToAnsi(STR0015) SIZE 050,010 OF oDlg1 PIXEL // "Copias Devolvidas"
@ 022,055 MSGET oCopDev VAR nCopDev PICTURE "9999" SIZE 033,008 OF oDlg1 PIXEL;
				VALID (If((nCopPen-nCopDev) > 0,oBtn1:Enable(),;
						(oBtn1:Disable(),cJustif:= Space(nTamJus),oDlg1:CoorsUpdate(),oDlg1:nHeight:= 135)),oBtn1:Refresh())

DEFINE SBUTTON oBtn1 FROM 037,075 TYPE 5 ENABLE OF oDlg1;
			ACTION (oDlg1:CoorsUpdate(),oDlg1:nHeight:= If(oDlg1:nHeight == 165,135,165))
oBtn1:cToolTip:= OemToAnsi(STR0016) // "Justificativa"
oBtn1:cCaption:= OemToAnsi(STR0017)  //"Justif"
	
DEFINE SBUTTON FROM 037,105 TYPE 1 ENABLE OF oDlg1 ACTION (nOpc1:=1,oDlg1:End())

DEFINE SBUTTON FROM 037,135 TYPE 2 ENABLE OF oDlg1 ACTION oDlg1:End()

@ 057,003 SAY OemToAnsi(STR0016) SIZE 050,010 OF oDlg1 PIXEL // "Justificativa"
@ 057,055 MSGET oJustif VAR cJustif SIZE 110,008 OF oDlg1 PIXEL

ACTIVATE MSDIALOG oDlg1 ON INIT (oDlg1:CoorsUpdate(),oDlg1:nHeight:= If(oDlg1:nHeight == 165,135,165)) CENTERED

If nOpc1 == 1
	If (nCopPen - nCopDev) <> QDU->QDU_NCOP .Or. !Empty(cJustif)
		RecLock("QDU",.F.)
		If (nCopPen - nCopDev) == 0 .Or. !EmpTy(cJustif)
			QDU->QDU_PENDEN:= "B"
			QDU->QDU_JUSTIF:= cJustif	
		EndIf
		QDU->QDU_DTBAIX:= dDataBase
		QDU->QDU_HRBAIX:= SubStr(Time(),1,5)
		QDU->QDU_FMATBX := cMatFil
		QDU->QDU_MATBX  := cMatCod
		QDU->QDU_DEPBX  := cMatDep
		QDU->QDU_COPPEN := (nCopPen - nCopDev)
		QDU->(MsUnlock())
	EndIf
EndIf

Return If(nOpc1 == 1,.T.,.F.)