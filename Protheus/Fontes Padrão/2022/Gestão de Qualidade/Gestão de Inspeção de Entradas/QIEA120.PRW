#INCLUDE "QIEA120.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA120  � Autor � Vera Lucia S. Simoes  � Data � 11/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Skip-Lote (Opcoes de Skip-Lote) ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAQIE													  ���
�������������������������������������������������������������������������Ĵ��
���STR 	     � Ultimo utilizado -> STR0014                                ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Paulo Emidio�16/04/02� META � Disponibilizacao do parametro MV_QFRQSKP ���
���			   �		�      � que Indica se a frequencia por Documento ���
���			   �		�      � de Entrada podera ser alterado.		  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRotina := {{OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},;    // "Pesquisar"
                   {OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;    // "Visualizar"
                   {OemToAnsi(STR0003),"A120ISkL"  , 0 , 3},;    // "Incluir"
                   {OemToAnsi(STR0004),"A120ISkL"  , 0 , 4},;    // "Alterar"
                   {OemToAnsi(STR0005),"A120DSkL"  , 0 , 5, 3} } // "Excluir"
                   
Return aRotina

Function QIEA120
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0006)  //"Skip-Lote"
Private lQFrqSkp  := GetMv("MV_QFRQSKP") //Indica se a frequencia do Skip-Lote por Documento de Entrada sera podera ser alterado  

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
Private aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
QEF->(dbSetOrder(2))
mBrowse( 6, 1,22,75,"QEF")
QEF->(dbSetOrder(1))

Set Key VK_F12 To
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A120DSkL � Autor � Vera Lucia S. Simoes  � Data � 11/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Skip-Lote - Delecao             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A120DSkL(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION A120DSkL(cAlias,nReg,nOpc)
Local nOpcA    := 0
Local cCod     := ""
Local oDlg
                       
//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]

While .T.
	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA:=0
	dbSelectArea(cAlias)
	RecLock(cAlias,.F.)

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009))  //"Quanto � exclus�o?"
		nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

	dbSelectArea(cAlias)

	IF nOpcA == 2

		cCod := QEF->QEF_SKPLOT
		//���������������������������������������������������������Ŀ
		//� Antes de deletar verif. se e' util. em Amarr. FornXProd �
		//�����������������������������������������������������������
  		dbSelectArea('SA5')
		dbSetOrder(1)
		dbSeek(xFilial("SA5"))
		lAchou := .f.
		While A5_FILIAL == xFilial("SA5") .and. ! Eof()
			if A5_SKPLOT == cCod
				lAchou := .t.
				Exit
			endif
			dbSkip()
		Enddo
		if lAchou
			MessageDlg(OemToAnsi(STR0010)+SA5->A5_PRODUTO+' - '+SA5->A5_FORNECE,,1) // "Skip-Lote � utilizado na amarra��o Produto X Fornecedor: "
			dbSelectArea(cAlias)
			Exit
		EndIf

		//������������������������������������������������������������Ŀ
		//� Antes de deletar verif. se e' util. em Criterios Skip-Lote �
		//��������������������������������������������������������������
		QEX->(dbSetOrder(2))
		QEX->(dbSeek(xFilial("QEX")+cCod))
		QEX->(dbSetOrder(1))
		If !QEX->(Eof())
			MessageDlg(OemToAnsi(STR0011),,1) // "Skip-Lote � utilizado nos Crit�rios do Skip-Lote."
			dbSelectArea(cAlias)
			Exit
		EndIf

		Begin Transaction

			//��������������������������������������������������������������Ŀ
			//� Apos passar por todas as verificacoes , deleta o registro    �
			//����������������������������������������������������������������
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.T.)
			dbDelete()
			MsUnLock()

		End Transaction
	Else
		MsUnLock()

   EndIf

   Exit
EndDo

dbSelectArea(cAlias)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A120ISkL � Autor � Vera Lucia S. Simoes  � Data � 11/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Skip-Lote - Inclusao/Alteracao  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A120ISkL(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION A120ISkL(cAlias,nReg,nOpc)
LOCAL nOpcA:=0

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]

While .T.

	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA:=0

	Begin Transaction

		if nOpc == 3  // Inclusao
			nOpcA:=AxInclui( cAlias, nReg, nOpc,,,,"A120ENOK()")

		elseif nOpc == 4  // Alteracao
			nOpcA:=AxAltera( cAlias, nReg, nOpc,,,,,"A120ENOK()")
		endif

		If nOpcA == 1	// Confirma
			RecLock("QEF", .F.)
			QEF->QEF_QTDINV := Inverte(StrZero(QEF->QEF_QTDE,4))
			MsUnLock()
		EndIf

	End Transaction

   Exit
EndDo
dbSelectArea(cAlias)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A120DUSL � Autor � Vera Lucia S. Simoes  � Data � 12/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Descricao da Unidade de Skip-Lote                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A120DUSL(ExpC1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo da Unidade de Skip-Lote                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA120 - Inic. do browse - X3_INIBRW                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION A120DUSL(cUnSkLt)

Do Case
   Case cUnSkLt == 'E'
         Return(padr(OemToAnsi(STR0012),20)) // "Entradas"
   Case cUnSkLt == 'D'
         Return(padr(OemToAnsi(STR0013),20)) // "Dias"
   Case cUnSkLt == 'L'
         Return(padr(OemToAnsi(STR0014),20)) // "Documento de Entrada"
EndCase

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A120WhSk � Autor � Vera Lucia S. Simoes  � Data � 29/05/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Sugere o proximo codigo do Skip-Lote                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A120WhSk()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION A120WhSk()
Local lRetu := .t.,;
		nOrd 	:= QEF->(IndexOrd()),;
		nRec	:= QEF->(Recno()),;
		cSkLt	:= "  "

If ReadVar() == "M->QEF_SKPLOT"
	If INCLUI
		QEF->(dbSetOrder(1))
		QEF->(dbSeek(xFilial("QEF")))
		While QEF->QEF_FILIAL == xFilial("QEF") .And. !QEF->(Eof())
			cSkLt := QEF->QEF_SKPLOT
			QEF->(dbSkip())
		EndDo

		cSkLt := StrZero(Val(cSkLt)+1,2)

		// Atualiza variavel da tela
		M->QEF_SKPLOT := cSkLt

		QEF->(dbSetOrder(nOrd))
		QEF->(dbGoTo(nRec))
	EndIf
EndIf
Return(lRetu)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A120EnOK � Autor � Vera Lucia S. Simoes  � Data � 01/06/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o dos campos da Enchoice                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA120 - E' chamada no AxInclui/AxAltera                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A120EnOK()
Local lRetu := .T.
Local nOrd  := QEF->(IndexOrd())

//����������������������������������������������������������������������Ŀ
//� Verifica se j� existe a Unidade/Frequencia                           �
//������������������������������������������������������������������������
QEF->(dbSetOrder(2))
If QEF->(dbSeek(xFilial("QEF")+M->QEF_UNSKLT+Str(M->QEF_QTDE,4)))
	If QEF->QEF_SKPLOT <> M->QEF_SKPLOT
		Help(" ",1,"A120SKPEXI")	// "J� existe Skip-Lote com esta Unidade / Frequencia"
		lRetu := .f.
	EndIf
EndIf

//����������������������������������������������������������������������Ŀ
//� Verifica se existe a Unidade "E" e Frequencia 1: Controla Todas      �
//������������������������������������������������������������������������
QEF->(dbSetOrder(2))
If !QEF->(dbSeek(xFilial("QEF")+"E"+Str(1,4))) .And.;
		(M->QEF_UNSKLT <> "E" .Or. M->QEF_UNSKLT == "E" .And. M->QEF_QTDE <> 1)
	Help(" ",1,"A120SKPOBR")	// "O Skip-Lote para Controlar todas as Entradas � obrigatorio."
	lRetu := .f.
EndIf

QEF->(dbSetOrder(nOrd))
Return(lRetu)

/*             
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIEA120FRQ� Autor � Paulo Emidio de Barros� Data � 16/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se o campo Frequencia podera ser editado		  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA120													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QIE120FRQ()     

Local  lRetorno := .T.
Private lQFrqSkp  := GetMv("MV_QFRQSKP") //Indica se a frequencia do Skip-Lote por Documento de Entrada sera podera ser alterado  

If !lQFrqSkp    
	If M->QEF_UNSKLT=="L"
		lRetorno := .F. 
	EndIf		
EndIf

Return(lRetorno)