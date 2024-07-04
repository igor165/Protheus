#INCLUDE "pmsa500.ch"
#INCLUDE "PROTHEUS.CH"
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � PMSA500  � Autor � Edson Maricate        � Data � 04-07-2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de manutecao das simulacoes de projetos             ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PMSA500()

Local aButtons := {}
PRIVATE cCadastro	:= STR0013 //"Simula��es de Projetos"

Private aRotina := MenuDef()

If PMSBLKINT()
	Return Nil
EndIf

If Existblock("PMA500BOT")
	aButtons := ExecBlock("PMA500BOT",.F.,.F.,{aRotina}) 
	If ValType(aButtons) == "A"
		aRotina := aClone(aButtons)	
	EndIf
EndIF


aAdd(aRotina ,{ STR0014, "PMS501Pln" , 0 , 5})

If ExistBlock("PMA500aRot")
	ExecBlock("PMA500aRot" ,.F. ,.F.)
EndIf

mBrowse(6,1,22,75,"AJB")


Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PMS500Dlg� Autor � Edson Maricate         � Data � 09-02-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ���
���          � de Projetos.                                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PMS500Dlg(cAlias,nReg,nOpcx)
Local l500Inclui	:= .F.
Local l500Visual	:= .F.
Local l500Altera	:= .F.
Local l500Exclui	:= .F.

Private lSimulaAJB := .T.

//���������������������������������������������������������Ŀ
//� Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  �
//�����������������������������������������������������������
Do Case
	Case (aRotina[nOpcx][4] == 2)
		l500Visual := .T.
	Case (aRotina[nOpcx][4] == 3) .Or. (aRotina[nOpcx,4] == 6)
		l500Inclui	:= .T.
	Case (aRotina[nOpcx][4] == 4)
		l500Altera	:= .T.
	Case (aRotina[nOpcx][4] == 5)
		l500Exclui	:= .T.
EndCase

If l500Inclui
	AxInclui(cAlias,nReg,nOpcx,,,,,,"Pms500Atu()")
Endif

If l500Altera
	AF8->(dbSetOrder(1))
	AF8->(dbSeek(xFilial()+AJB->AJB_PROJET))
	PMSA200(4,AJB->AJB_REVISA,.T.)
EndIf

If l500Visual
	AF8->(dbSetOrder(1))
	AF8->(dbSeek(xFilial()+AJB->AJB_PROJET))
	PMSA200(2,AJB->AJB_REVISA,.T.)
EndIf

If l500Exclui
	If Empty(AJB->AJB_VERATU)
		AxDeleta(cAlias,nReg,nOpcx,"Pms500Del()") // <>1
	Else
		Help("  ",1,"PMSA5001")	
	EndIf
EndIf


Return
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Pms500Atu� Autor � Edson Maricate         � Data � 06-08-2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao das tabelas auxiliares do cadastro   ���
���          � de simulacoes de projetos.                                   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function Pms500Atu()

AF8->(dbSetOrder(1))
AF8->(dbSeek(xFilial()+AJB->AJB_PROJET))
//���������������������������������������������������������Ŀ
//� Grava o arquivo de revisoes com o historico inicial.    �
//�����������������������������������������������������������
RecLock("AFE",.T.)
AFE->AFE_FILIAL := xFilial("AFE")
AFE->AFE_PROJET := AF8->AF8_PROJET
AFE->AFE_REVISA := AJB->AJB_REVISA
AFE->AFE_DATAI  := MsDate()
AFE->AFE_HORAI  := Time()
AFE->AFE_DATAF  := MsDate()
AFE->AFE_HORAF  := Time()
AFE->AFE_USERI  := RetCodUsr()
AFE->AFE_USERF  := RetCodUsr()
AFE->AFE_MEMO   := STR0001 //"Simulacao do Projeto"
AFE->AFE_TIPO   := "2" //Tipo 2 - Simulacao do Projeto
MsUnlock()
MSMM(AJB->AJB_CODMEM,,,M->AJB_MEMO,1,,,"AJB","AJB_CODMEM")
MaPmsRevisa(AF8->(RecNo()),2,AJB->AJB_VERBAS,AJB->AJB_REVISA,.T.)

If ExistBlock("PMA500ATU")
	ExecBlock("PMA500ATU" ,.F. ,.F.)
EndIf

Return .T.

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Pms500Del� Autor � Edson Maricate         � Data � 06-08-2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao das tabelas auxiliares do cadastro  de  ���
���          � simulacoes de projetos.                                      ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function Pms500Del()

AF8->(dbSetOrder(1))
If AF8->(dbSeek(xFilial()+AJB->AJB_PROJET))
	//���������������������������������������������������������Ŀ
	//� Deleta as tabelas utilizadas na simulaca                �
	//�����������������������������������������������������������
	MaPmsRevisa(AF8->(RecNo()),3,AJB->AJB_REVISA,,.T.)
	dbSelectArea("AFE")
	dbSetOrder(1)
	If dbSeek(xFilial()+AJB->AJB_PROJET+AJB->AJB_REVISA)
		//���������������������������������������������������������Ŀ
		//� Delete o arquivo de revisoes                            �
		//�����������������������������������������������������������
		RecLock("AFE",.F.,.T.)
		dbDelete()
		MsUnlock()
	EndIf
EndIf

Return .T.

/*/{Protheus.doc} Pms500Eft
Programa de efetivacao de uma versao simulada do projeto.
@author Edson Maricate 
@since 06-08-2003
@version 1.0
@param cAlias, character, Alias da tabela corrente
@param nReg, num�rico, recno da tabela corrente
@param nOpcx, num�rico, op��o selecionada do array aRotina
@return nulo
/*/
Function Pms500Eft(cAlias,nReg,nOpcx)
Local lContinua := .T.
Local cNextVer	:= ""

AF8->(dbSetOrder(1))
AF8->(dbSeek(xFilial()+AJB->AJB_PROJET))

If lContinua .And. ExistBlock("PMS500_1")
	lContinua := ExecBlock("PMS500_1",.F.,.F.)
	If !lContinua
		Return
	EndIf
EndIf

If lContinua .And. Empty(AJB->AJB_VERATU)
	//������������������������������������������������������Ŀ
	//� Verifica se o projeto nao esta reservado.            �
	//��������������������������������������������������������
	If AF8->AF8_STATUS=="2"
		Help("  ",1,"PMSA2101")
		lContinua := .F.
	Else
		M->AJB_MEMO := MSMM(AJB->AJB_CODMEM)
	EndIf
	
	If lContinua .And. AxAltera(cAlias,nReg,nOpcx) == 1
		Begin Transaction
		cNextVer := Soma1(AF8->AF8_REVISA)
		//�����������������������������������������������������������������Ŀ
		//� Verifica se a versao nao existe e pega a proxima                �
		//�������������������������������������������������������������������
		dbSelectArea("AFE")
		dbSetOrder(1)
		While dbSeek(xFilial()+AF8->AF8_PROJET+cNextVer)
			cNextVer := Soma1(cNextVer)
		End
		//���������������������������������������������������������Ŀ
		//� Grava o arquivo de revisoes com o historico inicial.    �
		//�����������������������������������������������������������
		RecLock("AFE",.T.)
		AFE->AFE_FILIAL := xFilial("AFE")
		AFE->AFE_PROJET := AF8->AF8_PROJET
		AFE->AFE_REVISA := cNextVer
		AFE->AFE_DATAI  := MsDate()
		AFE->AFE_HORAI  := Time()
		AFE->AFE_DATAF  := MsDate()
		AFE->AFE_HORAF  := Time()
		AFE->AFE_USERI  := RetCodUsr()
		AFE->AFE_USERF  := RetCodUsr()
		AFE->AFE_MEMO   := STR0002+AJB->AJB_REVISA //"Versao criada a partir da simulacao : "
		// SIMULACAO DE PROJETO PARA PROJETO NORMAL.
		AFE->AFE_TIPO   := "1"
		MsUnlock()
		cRevisa := MaPmsRevisa(AF8->(RecNo()),1,AJB->AJB_REVISA,cNextVer,.T.)
		RecLock("AJB",.F.)
		AJB->AJB_VERATU := cNextVer
		MsUnlock()
		MSMM(AJB->AJB_CODMEM,,,M->AJB_MEMO,1,,,"AJB","AJB_CODMEM")
		End Transaction
		
		If ExistBlock("PMS500_2")
			ExecBlock("PMS500_2",.F.,.F.)
		EndIf
		
		//"Simulacao efetivada om sucesso." "Vers�o atual do projeto " " criada a partir da versao simulada : "
		Aviso(STR0003,STR0004+AF8->AF8_PROJET+" : "+cNextVer+STR0005+AJB->AJB_REVISA+".",{"Ok"},2 ) //"Simulacao efetivada om sucesso."###"Versao atual do projeto "###" criada a partir da versao simulada : "
	EndIf
Else
	Help("  ",1,"PMSA5002")	
EndIf
	
Return


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PMS500Ver� Autor � Adriano Ueda           � Data � 23-12-2004 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para comparacao de simulacoes                         ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PMS500Ver(cAlias, nReg, nOpcx)
	Local aAreaAF8 := AF8->(GetArea())

	dbSelectArea("AF8")
	dbSetOrder(1)
	
	If AF8->(MsSeek(xFilial() + AJB->AJB_PROJET))
		PMS210Ver(cAlias, nReg, nOpcx)
	EndIf
	
	RestArea(aAreaAF8)
Return

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �30/11/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
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
Static Function MenuDef()
Local aRotina 	:= {	{ STR0006, "AxPesqui"  , 0 , 1,,.F.},; //"Pesquisar"
						{ STR0007, "PMS500Dlg" , 0 , 2},; //"Visualizar"
						{ STR0008, "PMS500Dlg" , 0 , 3},; //"Incluir"
						{ STR0009, "PMS500Dlg" , 0 , 4},; //"Alt.Estrutura"
						{ STR0010, "PMS500Dlg" , 0 , 5},; //"Excluir"
						{ STR0011, "PMS500Ver", 0 , 5},;  //"Comparar"
						{ STR0012, "PMS500Eft" , 0 , 4} } //"Efetivar"
Return(aRotina)						
