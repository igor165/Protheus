#INCLUDE "pmsa020.ch"
#INCLUDE "protheus.ch"
//Teste
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � PMSA020  � Autor � Edson Maricate        � Data � 09-02-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Grupos de Composicoes                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PMSA020()

PRIVATE cCadastro	:= STR0001 //"Composicoes"
PRIVATE aRotina := MenuDef()

If AMIIn(44) .And. !PMSBLKINT()
	mBrowse(6,1,22,75,"AE5")
EndIf


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
Local aRotina 	:= {	{ STR0002, "AxPesqui"  , 0 , 1,,.F.},; //"Pesquisar"
							{ STR0003,"AxVisual", 0 , 2},;	 //"Visualizar"
							{ STR0004,   "AxInclui", 0 , 3},;	 //"Incluir"
							{ STR0005,   "PMA020ALT", 0 , 4},;	 //"Alterar"
							{ STR0006,   "PMA020EXC", 0 , 5} } //"Excluir"

Return(aRotina)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PMA020ALT �Autor  �Clovis Magenta      � Data �  04/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para encapsular o AxAltera afim de validarmos a    ���
���          � altera��o do codigo do grupo                               ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION PMA020ALT()
Local cTudoOk := "PMA020TOK()"
Local nReg := AE5->(Recno())

AxAltera("AE5",nReg,4,,,,,cTudoOk)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PMA020ALT �Autor  �Clovis Magenta      � Data �  04/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para encapsular o AxDeleta afim de validarmos a    ���
���          � exclus�o do codigo do grupo                               ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION PMA020EXC()
Local cTudoOk 	:= "PMA020TOK()"
Local nReg 		:= AE5->(Recno())
Local lOk		:= .T.
Local cCodGrp 	:= AE5->AE5_GRPCOM
Local aArea := getArea()
                       
dbSelectArea("AE1")
dbSetOrder(1)
DbSeek(xFilial("AE1"))

While AE1->(!EOF())
	If AE1->AE1_GRPCOM == cCodGrp
		lOk := .F.
		MsgAlert(STR0007 + Alltrim(AE1->AE1_COMPOS) + STR0008) // "Este Grupo de composi��o est� em uso pela Composi��o " ". N�o ser� poss�vel Alterar ou Excluir seu c�digo para manter a integridade dos dados."
		Exit	
	Endif
	AE1->(DbSkip())
ENDDO

RestArea(aArea)

If lOk
	AxDeleta("AE5",nReg,5,cTudoOk)
Endif

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PMA020TOK �Autor  �Clovis Magenta      � Data �  04/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para realizar o TUDOOK da rotina de ALTERA��O      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION PMA020TOK()
Local lOk := .T.
Local aArea := getArea()
Local cCodGrp := AE5->AE5_GRPCOM
                       
dbSelectArea("AE1")
dbSetOrder(1)
DbSeek(xFilial("AE1"))

While AE1->(!EOF())
	If AE1->AE1_GRPCOM == cCodGrp
		lOk := .F.
		MsgAlert(STR0007 + Alltrim(AE1->AE1_COMPOS) + STR0008) // "Este Grupo de composi��o est� em uso pela Composi��o " ". N�o ser� poss�vel Alterar ou Excluir seu c�digo para manter a integridade dos dados."
		Exit	
	Endif
	AE1->(DbSkip())
ENDDO

RestArea(aArea)

Return lOk

