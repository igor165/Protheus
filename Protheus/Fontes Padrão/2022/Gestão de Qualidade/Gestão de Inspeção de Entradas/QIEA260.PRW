#INCLUDE "QIEA260.CH"
#include "PROTHEUS.CH"
/*/ 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA260  � Autor � Vera Lucia S. Simoes  � Data � 17/04/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao de Fatores do IQP                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},; // "Pesquisar" 
                     {OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;     // "Visualizar"
                     {OemToAnsi(STR0003),"A260IFat"  , 0 , 3},;     // "Incluir"   
                     {OemToAnsi(STR0004),"A260IFat"  , 0 , 4},;     // "Alterar"   
                     {OemToAnsi(STR0005),"A260DFat"  , 0 , 5, 3} }  // "Excluir"
                     
Return aRotina

Function QIEA260()

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro

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
PRIVATE aRotina := MenuDef()

dbSelectArea("QED")

cCadastro := OemtoAnsi(STR0006)  // "Fatores do I.Q.P."

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QED")

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A260DFat � Autor � Vera Lucia S. Simoes  � Data � 17/04/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Fatores do IQP - Delecao              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A260DFat(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA260                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A260DFat(cAlias,nReg,nOpc)
LOCAL nOpcA ,cCod 
LOCAL oDlg, lAchou

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

		cCod := QED->QED_CODFAT

 		//������������������������������������������������������������Ŀ
		//� Antes de deletar verif. se e' util. em Laudos das Entradas �
		//��������������������������������������������������������������
		dbSelectArea('QEL')
		dbSetOrder(1)
		dbSeek(xFilial("QEL"))
		lAchou := .f.
		While QEL_FILIAL == xFilial("QEL") .and. ! eof()
			if QEL_LAUDO == cCod
				lAchou := .t.
				Exit
			endif
			dbSkip()
		Enddo
		if lAchou
			HELP(" ",1,"A160DFILAU",,QEL->QEL_FORNEC+'-'+;	// "Fator IQP nao pode ser excluido"
				QEL->QEL_PRODUT+'-'+dtoc(QEL->QEL_DTENTR)+;	// "por ser utilizado no laudo da Entrada:"
				'-'+QEL->QEL_LOTE,3,1)
			dbSelectArea(cAlias)
			Exit
		EndIf
		//��������������������������������������������������������������Ŀ
		//� Antes de deletar verif. se e' util. em Laudos dos relat. IQF �
		//����������������������������������������������������������������
		dbSelectArea('QEW') 
		dbSetOrder(1)
 		dbSeek(xFilial("QEW"))
		lAchou := .f.
		While QEW_FILIAL == xFilial("QEW") .and. ! eof()
			if QEW_LAUDO == cCod
				lAchou := .t.
				Exit
			endif
			dbSkip()
		Enddo
		if lAchou
			HELP(" ",1,"A160DFIREL",,QEW->QEW_ANO+' - '+;	// "Fator IQP nao pode ser excluido por"
				QEW->QEW_MES,4,1)										// "ser utilizado no relatorio Indice Qualidade"
			                      									// "gerado em:"
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
return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A260IFat � Autor � Vera Lucia S. Simoes  � Data � 17/04/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Fatores IQP - Inclusao/Alteracao      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A260IFat(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA260                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A260IFat(cAlias,nReg,nOpc)
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
			nOpcA:=AxInclui( cAlias, nReg, nOpc)

		elseif nOpc == 4  // Alteracao
			nOpcA:=AxAltera( cAlias, nReg, nOpc)
		endif
	
	End Transaction

   Exit
EndDo
dbSelectArea(cAlias)
return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A260VlFa � Autor � Vera Lucia S. Simoes  � Data � 02/02/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Fator                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA260 - E' chamada no X3_VALID do cpo. QED_FATOR  - SX3  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A260VlFa()
Local lRetu := .t. 
Local cVar := M->QED_FATOR

//�����������������������������������������������������Ŀ
//� Verifica se o valor digitado e' um numero valido    �
//�������������������������������������������������������
If ! Positivo(val(cVar))
	lRetu := .f.
EndIf

//�����������������������������������������������������Ŀ
//� Verifica se o valor digitado e' um numero valido    �
//�������������������������������������������������������
If lRetu
	If ! QA_VerNum(@cVar)
		HELP(" ",1,"QA_NUMINV")
		lRetu := .f.
	EndIf
	M->QED_FATOR := cVar   // atualizacao p/ enchoice
EndIf
Return(lRetu)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A260VlCa � Autor � Cleber Souza          � Data � 20/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Categoria                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA260 - E' chamada no X3_VALID do cpo. QED_CATEG  - SX3  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A260VlCa()  
            
Local lRet    := .T.
Local lBlqCat := GetMv("MV_QBLIQP",.T.,.F.) 

If lBlqCat
	QED->(dbGoTop())
	While QED->(!EOF())
		If QED->QED_CODFAT <> M->QED_CODFAT .and. QED->QED_CATEG == M->QED_CATEG  	
			MsgAlert(STR0010 + M->QED_CATEG + STR0011 + QED->QED_CODFAT)     //"A categoria "###" ja foi cadastrada para a situac�o "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
			lRet := .F.
			Exit			
	    EndIf
		QED->(dbSkip())
    EndDo
EndIF

Return(lRet)
