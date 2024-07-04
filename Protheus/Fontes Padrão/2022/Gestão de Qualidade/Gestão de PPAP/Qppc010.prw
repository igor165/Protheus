#INCLUDE "QPPC010.CH"
#INCLUDE "PROTHEUS.CH"

/*
������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao	 � QPPC010   � Autor �Robson Ramiro A. Oliveir� Data � 30/07/02 ���
���������������������������������������������������������������������������Ĵ��
���Descricao �Verifica se existem pendencias para o usuario logado          ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 �QPPC010(lAuto)                                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�Exp1L := Disparado automatico    							    ���
���������������������������������������������������������������������������Ĵ��
���Uso		 �SigaPPAP                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Function QPPC010(lAuto)

Local aUsrMat := {}
Local nI


Private aCols 	:= {}
Private aHeader	:= {}
Private nUsado	:= 0
Private INCLUI	:= .F. // Apenas para nao dar erro na funcao QPPNUSR()
Private ALTERA	:= .F.

Default lAuto := .F.

aUsrMat	:= QA_USUARIO()

QPP110Ahead("QKP",.T.)
nUsado := Len(aHeader)

DbSelectArea("QKP")
DbSetOrder(6)
DbSeek(xFilial("QKP")+aUsrMat[3])

Do While !Eof() .and. QKP_PCOMP <> "4" .and. QKP_MAT == aUsrMat[3]

	If Empty(QKP_DTPRA)
		DbSkip()
		Loop
	Endif

	aAdd(aCols,Array(nUsado+1))

	For nI := 1 to nUsado
		If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
			cCpo := AllTrim(Upper(aHeader[nI,2]))
			
			If cCpo == "QKP_SEQ"
				aCols[Len(aCols),nI] := StrZero(Len(aCols),3)
			Else
				aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
			Endif
		Else										// Campo Virtual
			aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
		Endif
	Next nI

	aCols[Len(aCols),nUsado+1] := .F.
	
	DbSkip()
Enddo

If Len(aCols) > 0
	If !lAuto
		PPC010VisP()
	Elseif MsgYesNo(STR0001+Str(Len(aCols),4)+STR0002) //"Tem "###" Pendencias para voce, deseja visualiza-las ?"
		PPC010VisP()
	Endif
Else
	If !lAuto
		Alert(STR0003) //"Nao ha pendencias para voce !"
	Endif
Endif

Return


/*
������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao	 �PPC010VisP � Autor �Robson Ramiro A. Oliveir� Data � 30/07/02 ���
���������������������������������������������������������������������������Ĵ��
���Descricao �Visualiza Pendencias                                          ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 �PPC0100VisP(Void)                                             ���
���������������������������������������������������������������������������Ĵ��
���Parametros� 																���
���������������������������������������������������������������������������Ĵ��
���Uso		 �SigaPPAP                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function PPC010Visp

Local oDlg		:= NIL
Local aAlter	:= {}

Private oGet 	:= NIL
Private aRotina := { 	{ OemToAnsi(STR0004)	,"AxPesqui" , 0, 1},; //"Pesquisar"
						{ OemToAnsi(STR0005)	,"AxInclui"	, 0, 2},; //"Visualizar"
						{ OemToAnsi(STR0006)	,"AxVisual"	, 0, 3},; //"Incluir"
						{ OemToAnsi(STR0007)	,"AxAltera"	, 0, 4},; //"Alterar"
						{ OemToAnsi(STR0008)	,"AxExlui"	, 0, 5} } //"Excluir"

aAlter := {"QKP_OBS"}

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009); //"Pendencias"
						FROM 120,000 TO 370,665 OF oMainWnd PIXEL

oGet := MSGetDados():New(33,03,115,332, 4,"AllwaysTrue","AllwaysTrue","+QKP_SEQ",.F.,aAlter,,,Len(Acols))

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()},,) CENTERED

Return