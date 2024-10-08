#INCLUDE "MATA318.ch"
#include "PROTHEUS.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA318   �Autor  � Daniel Leme        � Data �  10/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Planilhas de Forma��o de Pre�os                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������͹��
���              ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.        ���
�������������������������������������������������������������������������Ĵ��
���Programador   � Data   � BOPS/FNC  �  Motivo da Alteracao              ���
�������������������������������������������������������������������������Ĵ��
���Jesus Pe�aloza�25/07/14�TQBCEE     �Se eliminan las llamadas a las     ���
���              �        �           �funciones MTC010SX1() y            ���
���              �        �           �C010AJUSX1()                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA318()
Local aArea		:= GetArea()
Local cArea		:= Alias()
Local cFiltro	:= ""

Private aRotina	:= MenuDef()

PRIVATE aArray    :={}
PRIVATE aHeader   :={}
PRIVATE aTotais   :={}
Private cCadastro	:= OemToAnsi(STR0001) //"Revis�es de Planilhas de Forma��o de Pre�o "
PRIVATE cProg     := "A318"  
PRIVATE nQtdFormula
PRIVATE nQtdTotais
PRIVATE cCusto

//�����������������������������������������������������������������Ŀ
//� Funcao utilizada para verificar a ultima versao do fonte        �
//� SIGACUSA.PRX aplicados no rpo do cliente, assim verificando     |
//| a necessidade de uma atualizacao nestes fontes. NAO REMOVER !!!	�
//�������������������������������������������������������������������
If !(FindFunction("SIGACUSA_V") .And. SIGACUSA_V() >= 20060321)
    Final(STR0002) //"Atualizar SIGACUSA.PRX !!!"
EndIf

//���������������������������������������������������������Ŀ
//� Caso o M�dulo que chama a fun��o seja o SIGALOJA        �
//� abre o arquivo SG1. esta implementa��o visa a libera��o �
//� de FILES do MS-DOS para o Sigaloja                      �
//�����������������������������������������������������������
If nModulo == 12 .Or. nModulo == 72 // SIGALOJA //SIGAPHOTO
	ChkFile("SG1")
	ChkFile("SGG")
EndIf

//����������������������������������������������������������������Ŀ
//� Ativa tecla F12 para acionar perguntas                         �
//������������������������������������������������������������������
Set Key VK_F12 To MTC010PERG()

Pergunte("MTC010", .F.)

//����������������������������������������������������������������Ŀ
//� Forca utilizacao da estrutura caso nao tenha SGG               �
//������������������������������������������������������������������
If MC010SX2("SGG") == .F.
	mv_par09:=1
EndIf

// Verifica o Nivel de Estrutura
If Empty(mv_par11) 
	mv_par11 := 999
EndIf

If SuperGetMV("MV_REVPLAN",.F.,.F.) .And. FindFunction("MC010FORM2")

	dbSelectArea("SCO")
	dbSetOrder(3) //CO_FILIAL+CO_CODIGO+CO_REVISAO+CO_PRODUTO
	dbGoTop()
	
	cFiltro := " CO_LINHA = '" + StrZero( 1, TamSX3("CO_LINHA")[1] ) + "'"
	mBrowse(06,01,22,75,"SCO",,,,,,,,,,,,,,cFiltro)
Else
	Alert(STR0003) //"N�o dispon�vel! Para acessar esta rotina � necess�rio ativa��o do controle de Revis�o de Planilhas"
EndIf
//����������������������������������������������������������������Ŀ
//� Desativa tecla que aciona perguntas                            �
//������������������������������������������������������������������
Set Key VK_F12 To

RestArea(aArea)
Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   														    ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta o menu                                               ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()     
Private aRotina	:= {}

AADD (aRotina, {STR0004,"AxPesqui"  	, 0 , 1,0 ,.F.}) //"Pesquisar"
AADD (aRotina,	{STR0005,"A318FormPrc", 0 , 2, 0,nil}) //"Forma Pre�os"


Return (aRotina)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} A318FormPrc()
Planilha de Forma��o de Pre�os

@param		cAlias - Caracter - Alias do arquivo
			nReg - Num�rico - N�mero do registro
			nOpcx - Num�rico - N�mero da op��o selecionada
@author 	Squad CRM & Fat
@since 		22/03/2021
@version 	12.1.27
@return 	Nil - Nenhum
/*/
//-------------------------------------------------------------------------------
Function A318FormPrc(cAlias,nReg,nOpcx)

PRIVATE lDirecao   := .T.
PRIVATE lExibeHelp := .T.
PRIVATE nQualCusto := 1
PRIVATE cArqMemo   := SCO->CO_NOME

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+SCO->CO_PRODUTO)

MC010Form2(cAlias,nReg,nOpcx,,,,,.T.,SCO->CO_CODIGO,SCO->CO_REVISAO)

Return Nil
