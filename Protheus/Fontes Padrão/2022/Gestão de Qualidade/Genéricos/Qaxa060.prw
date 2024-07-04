#INCLUDE "QAXA060.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QAXA060    � Autor � Eduardo de Souza   � Data � 12/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Cadastro Empresa / Filial utilizado no QUALITY.           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � QAXA060()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � QUALITY                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���   Data   �  BOPS  � Programador � Alteracao                           ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function MenuDef()

Local aRotina  := {{OemToAnsi(STR0001),"AxPesqui"	,	0, 1,,.F.},; // "Pesquisar"
					 {OemToAnsi(STR0002),"QX060Telas",	0, 2},; // "Visualizar"
					 {OemToAnsi(STR0003),"QX060Telas",	0, 3},; // "Incluir"
					 {OemToAnsi(STR0004),"QX060Telas",	0, 4},; // "Alterar"
					 {OemToAnsi(STR0005),"QX060Telas",	0, 5}}  // "Excluir"

Return aRotina

Function QAXA060()

Local lAdm:=.F.
Private aRotina  := MenuDef()

//�����������������������������������������������������������Ŀ
//�Somente os Administradores do sistema tem acesso a rotina. �
//�������������������������������������������������������������
If ( __CUSERID == '000000' )
	// eh usuario administrador.	
	lAdm:=.T.
Else			
	// Para verificar se faz parte do grupo de administradores
	PswOrder(1)	
	If ( PswSeek(__CUSERID) )						
		aGrupos := Pswret(1)						
		If ( Ascan(aGrupos[1][10],"000000") <> 0 )			
			// O usuario corrente faz parte do grupo de administradores
			lAdm:=.T.			
		EndIf		
	EndIf
Endif	

IF lAdm
	DbSelectArea("QAJ")
	DbSetOrder(1)
	DbGoTop()
	mBrowse(006,001,022,075,"QAJ")
Else
	Help(" ",1,"ACESS_ROT") // "Usuario que esta utilizando o sistema nao tem acesso a esta rotina."
Endif	

/*
//�����������������������������������������������������������Ŀ
//�Somente os Administradores do sistema tem acesso a rotina. �
//�������������������������������������������������������������
If PswAdmin(SubStr(cUsuario,7,15),cSenha) == 0
	DbSelectArea("QAJ")
	DbSetOrder(1)
	DbGoTop()
	mBrowse(006,001,022,075,"QAJ")
Else
	Help(" ",1,"ACESS_ROT") // "Usuario que esta utilizando o sistema nao tem acesso a esta rotina."
EndIf
*/
Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QX060Telas� Autor � Eduardo de Souza      � Data � 12/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela Cadastro Empresa + Filial                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QX060Telas(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias do arquivo                                   ���
���          � ExpN1 - Numero do registro                                 ���
���          � ExpN2 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QUALITY                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QX060Telas(cAlias,nReg,nOpc)

Local oDlg
Local nI      := 0
Local lDeleta := .F.
Local lRet    := .F.

Private bCampo := {|nCPO| Field( nCPO ) }
Private aTELA[0][0]
Private aGETS[0]

DbSelectArea("QAJ")
DbSetOrder(1)

If nOpc == 3
	For nI := 1 To FCount()
		cCampo := Eval( bCampo, nI )
		lInit  := .F.
		If ExistIni( cCampo )
			lInit := .T.
			M->&( cCampo ) := InitPad( GetSx3Cache(cCampo, 'X3_RELACAO') )
			If ValType( M->&( cCampo ) ) = "C"
				M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo, 'X3_TAMANHO') )
			EndIf
			If M->&( cCampo ) == Nil
				lInit := .F.
			EndIf
		EndIf
		If !lInit
			M->&( cCampo ) := FieldGet( nI )
			If ValType( M->&( cCampo ) ) = "C"
				M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
			ElseIf ValType( M->&( cCampo ) ) = "N"
				M->&( cCampo ) := 0
			ElseIf ValType( M->&( cCampo ) ) = "D"
				M->&( cCampo ) := CtoD( "  /  /  " )
			ElseIf ValType( M->&( cCampo ) ) = "L"
				M->&( cCampo ) := .f.
			EndIf
		EndIf
	Next nI
	M->QAJ_FILIAL:= xFilial("QAJ")
Else
	For nI := 1 To FCount()
		M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
	Next nI
EndIf

//������������������������������������������������Ŀ
//�Verifica permissao para deletar linha do Acols. �
//��������������������������������������������������
If nOpc == 3 .Or. nOpc == 4
	lDeleta:= .T.
ElseIf nOpc == 2 .Or. nOpc == 5
	lDeleta:= .F.
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) FROM 000,000 TO 385,625 OF oMainWnd PIXEL //"Cadastro de Empresa/Filial"

Enchoice("QAJ",nReg,nOpc,,,,,{014,002,190,312})

If nOpc == 3 .Or. nOpc == 4
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(QX060Grv(nOpc,nReg),oDlg:End(),.F.) },{|| oDlg:End() }) CENTERED
ElseIf nOpc == 2 .Or. nOpc == 5
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(nOpc == 5,QX060Dele(),),oDlg:End()},{|| oDlg:End()}) CENTERED
EndIf

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QX060Grv � Autor � Eduardo de Souza      � Data � 12/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Empresa/Filial                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QX060Grv(ExpN1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao do Browse                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QUALITY                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QX060Grv(nOpc,nReg)

Local lRecLock:= If(nOpc == 3,.T.,.F.)
Local nI      := 0
Local nPosQAJ := QAJ->(RecNo())

//�������������������������������������������������������������������Ŀ
//�Verifica se a Empresa / Filial Origem existe.    						 �
//���������������������������������������������������������������������
If !QX060VdFil(M->QAJ_EMPDE,M->QAJ_FILDE)
	Return .F.
EndIf	

//�������������������������������������������������������������������Ŀ
//�Verifica se a Empresa / Filial Destino existe.    						 �
//���������������������������������������������������������������������
If !QX060VdFil(M->QAJ_EMPPAR,M->QAJ_FILPAR)
	Return .F.
EndIf	

//�������������������������������������������������������������������Ŀ
//�Verifica se Empresa/Filial eh diferente do Destino.                �
//���������������������������������������������������������������������
If M->QAJ_EMPDE+M->QAJ_FILDE == M->QAJ_EMPPARA+M->QAJ_FILPARA
	Help(" ",1,"QX60DEPA") // "A Empresa/Filial Origem nao pode obrigatoriamente ser igual ao Destino."
	Return .F.
EndIf

//�������������������������������������������������������������������Ŀ
//�Verifica se Empresa/Filial ja encontra-se cadastrada como Destino. �
//���������������������������������������������������������������������
QAJ->(DbSetOrder(2))
If QAJ->(DbSeek(M->QAJ_FILIAL+M->QAJ_EMPDE+M->QAJ_FILDE))
	If nOpc == 3 .Or. (nOpc == 4 .And. nReg <> QAJ->(Recno()))
		QAJ->(DbGoto(nPosQAJ))
		QAJ->(DbSetOrder(1))
		Help(" ",1,"QX60JPARA") // "Nao sera possivel a finalizacao, pois a Empresa/Filial ja encontra-se cadastrada como Destino."
		Return .F.
	EndIf
EndIf

//�������������������������������������������������������������������Ŀ
//�Verifica se Empresa/Filial ja encontra-se cadastrada como Origem.  �
//���������������������������������������������������������������������
QAJ->(DbSetOrder(1))
If QAJ->(DbSeek(M->QAJ_FILIAL+M->QAJ_EMPPARA+M->QAJ_FILPARA))
	If nOpc == 3 .Or. (nOpc == 4 .And. nReg <> QAJ->(Recno()))
		QAJ->(DbGoto(nPosQAJ))
		Help(" ",1,"QX60JDE") //"Nao sera possivel a finalizacao, pois a Empresa/Filial ja encontra-se cadastrada como Origem.",1)
		Return .F.
	EndIf
EndIf
If QAJ->(DbSeek(M->QAJ_FILIAL+M->QAJ_EMPDE+M->QAJ_FILDE))
	If nOpc == 3 .Or. (nOpc == 4 .And. nReg <> QAJ->(Recno()))
		QAJ->(DbGoto(nPosQAJ))
		Help(" ",1,"QX60JDE") //"Nao sera possivel a finalizacao, pois a Empresa/Filial ja encontra-se cadastrada como Origem.",1)
		Return .F.
	EndIf
EndIf

//�������������������������������������������������������������������Ŀ
//�Grava Empresa / Filial. 								                   �
//���������������������������������������������������������������������
QAJ->(DbGoto(nPosQAJ))
RecLock("QAJ",lRecLock)
For nI := 1 TO FCount()
	FieldPut(nI,M->&(Eval(bCampo,nI)))
Next nI
QAJ->(MsUnLock())
	
Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QX060Dele  � Autor � Eduardo de Souza   � Data � 12/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Exclusao de registros de Empresa/Filial                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � QX060Dele()                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � QUALITY                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QX060Dele()

Begin Transaction
RecLock("QAJ",.F.)
QAJ->(DbDelete())
QAJ->(MsUnlock())
QAJ->(DbSkip())
End Transaction

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QX060NEmp  � Autor � Eduardo de Souza   � Data � 17/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Retorna o nome da Empresa                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � QX060NEmp()                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � QUALITY                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QX060NEmp(cEmpCod,cFilCod)

Local nPosSM0:= 0
Local cNEmp  := Space(15)

Default cEmpCod:= ""
Default cFilCod:= ""

DbSelectArea("SM0")
DbSetOrder(1)
nPosSM0:= Recno()

If SM0->(DbSeek(cEmpCod+cFilCod))
	cNEmp:= SM0->M0_NOME+" / "+SM0->M0_FILIAL
EndIf

SM0->(DbGoto(nPosSM0))
DbSelectArea("SX7")

Return cNEmp

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QX060VdEmp � Autor � Eduardo de Souza   � Data � 17/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Valida Empresa                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � QX060VdEmp()                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � QUALITY                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QX060VdEmp(cEmpCod)

Local nPosSM0:= 0
Local lReturn:= .T.

Default cEmpCod:= ""

DbSelectArea("SM0")
DbSetOrder(1)
nPosSM0:= Recno()
If !SM0->(DbSeek(cEmpCod))
	Help(" ",1,"QX60NEMP") //"Empresa nao existe."
	lReturn:= .F.
EndIf
SM0->(DbGoto(nPosSM0))

Return lReturn

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QX060VdFil � Autor � Eduardo de Souza   � Data � 17/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Valida Empresa / Filial                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � QX060VdFil()                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � QUALITY                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QX060VdFil(cEmpCod,cFilCod)

Local nPosSM0:= 0
Local lReturn:= .T.

Default cEmpCod:= ""
Default cFilCod:= ""

DbSelectArea("SM0")
DbSetOrder(1)
nPosSM0:= Recno()
If !SM0->(DbSeek(cEmpCod+cFilCod))
	Help(" ",1,"QX60NFIL") //"Empresa / Filial nao existe."
	lReturn:= .F.
EndIf
SM0->(DbGoto(nPosSM0))

Return lReturn