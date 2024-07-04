#Include "MDTA554.ch"
#Include "Protheus.ch"

#DEFINE _nVERSAO 1 //Versao do fonte
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MDTA554   �Autor  �Wagner S. de Lacerda� Data �  24/05/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de Eventos de Inspecao de Extintores.             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Tabelas   � TK4 - Eventos da Inspecao Extintores.                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MDTA554()
//�����������������������������������������������������������������������Ŀ
//� Armazena variaveis p/ devolucao (NGRIGHTCLICK) 				  		  	  �
//�������������������������������������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

Private nEventos	:=	13	//	Quantidade de Eventos padroes
Private cCadastro
Private bNGGRAVA, aCHKDEL := {}

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

If !NGCADICBASE("TK4_CODIGO","A","TK4",.F.)
	If !NGINCOMPDIC("UPDMDT04","00000017302/2010")
		Return .F.
	Endif
Endif

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
cCadastro := OemtoAnsi(STR0006) //"Eventos da Inspe��o de Extintores"

//��������������������������������������������������������������Ŀ
//�aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-�
//�sao do registro.                                              �
//�                                                              �
//�1 - Chave de pesquisa                                         �
//�2 - Alias de pesquisa                                         �
//�3 - Ordem de pesquisa                                         �
//����������������������������������������������������������������
aCHKDEL := { {"TK4->TK4_CODIGO" , "TK6", 2} }

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
DbSelectArea("TK4")
DbSetOrder(1)
mBrowse( 6, 1,22,75,"TK4")

//�����������������������������������������������������������������������Ŀ
//� Devolve variaveis armazenadas (NGRIGHTCLICK)                          �
//�������������������������������������������������������������������������
NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �MDTA554MAN�Autor  �Wagner S. de Lacerda� Data �  24/05/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica a Manipulacao dos campos, nao permitindo a        ���
���          � alteracao nem a exclusao dos Eventos padroes da NR23.      ���
�������������������������������������������������������������������������͹��
���Retorno   � .F. se o registro for um dos Eventos da NR23 e,            ���
���          � .T. se a exclusao pode ser realizada.                      ���
�������������������������������������������������������������������������͹��
���Uso       � MDTA554                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MDTA554MAN(cAlias, cRecno, nOpcx)

Local nCont		:=	0		//	Contador para o 'For' que verifica os eventos padroes
Local cCod		:=	""		//	Codigo do Evento verificado
Local cCodAux	:=	""		//	Codigo do Evento posicionado
Local nOpca		:=	0		// Retorno do NGCAD

If nOpcx == 5
	For nCont := 1 To nEventos
		// Coloca 0's (zeros) a esquerda conforme tamanho do valor
		cCod := StrZero(nCont,3)
		cCodAux := StrZero(Val(TK4->TK4_CODIGO),3)
		
		// Se o codigo for um dos padroes nao permite a exclusao
		If cCodAux == cCod
			MsgInfo(STR0026, STR0020) //"Este Evento consta na NR23. Portanto, n�o � poss�vel exclu�-lo."###"ATEN��O"
			Return .F.
		EndIf
	Next nCont
Endif

// Se os codigos nao forem iguais, pode excluir
nOpca := NGCAD01(cAlias,cRecno,nOpcx)

Return nOpca

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �MenuDef   �Autor  �Wagner S. de Lacerda� Data �  24/05/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Utilizacao de Menu Funcional.                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   � Array com opcoes da rotina.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�	Parametros do array a Rotina:                              ���
���          �	1. Nome a aparecer no cabecalho                            ���
���          �	2. Nome da Rotina associada                                ���
���          �	3. Reservado                                               ���
���          �	4. Tipo de Transa��o a ser efetuada:                       ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �		2 - Simplesmente Mostra os Campos                       ���
���          �		3 - Inclui registros no Bancos de Dados                 ���
���          �		4 - Altera o registro corrente                          ���
���          �		5 - Remove o registro corrente do Banco de Dados        ���
���          � 5. Nivel de acesso                                         ���
���          �	6. Habilita Menu Funcional                                 ���
�������������������������������������������������������������������������͹��
���Uso       � MDTA554                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRotina 

aRotina := { { STR0001,   "AxPesqui"  , 0 , 1},; //"Pesquisar"
				 { STR0002,   "NGCAD01"   , 0 , 2},; //"Visualizar"
				 { STR0003,   "NGCAD01"   , 0 , 3},; //"Incluir"
				 { STR0004,   "MDTA554MAN"   , 0 , 4},; //"Alterar"
				 { STR0005,   "MDTA554MAN"   , 0 , 5, 3} } //"Excluir"

Return aRotina        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �MDTA554VC �Autor  �Wagner S. de Lacerda� Data �  24/05/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida o codigo do evento                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   � .F. se o codigo for vazio, ja existir ou for igual a um    ���
���          � da NR23.                                                   ���
���          � .T. se o codigo for valido.                                ���
�������������������������������������������������������������������������͹��
���Uso       � MDTA554                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MDTA554VC()

Local cCodigo := AllTrim(M->TK4_CODIGO)

If !NaoVazio(cCodigo)
	Return .F.
Else
	If NGIsAllNum(cCodigo, 3)
		cCodigo := StrZero(Val(cCodigo),3,0)
		If Val(cCodigo) == 0
			MsgInfo(STR0027+Chr(13)+STR0028, STR0020) //"O c�digo '000' n�o � v�lido."###"Por favor, insira outro c�digo."###"ATEN��O"
			Return .F.
		EndIf
	Else
		MsgInfo(STR0029, STR0020) //"O campo c�digo deve possuir somente n�meros."###"ATEN��O"
		Return .F.
	EndIf
	
	If !ExistChav("TK4",cCodigo)
		Return .F.
	EndIf
EndIf

M->TK4_CODIGO := cCodigo

Return .T.