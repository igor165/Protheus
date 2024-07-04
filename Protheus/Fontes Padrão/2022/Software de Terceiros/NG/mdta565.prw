#INCLUDE "MDTA565.ch"
#Include "Protheus.ch"

#DEFINE _nVERSAO 2 //Versao do fonte
/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDTA565      � Autor � Jackson Machado       � Data � 13/05/11 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �  Programa de Cadastro de Conjuntos Hidr�ulicos                 ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � MDTA565()                                                      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�                                                                ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   � Booleano                                                       ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � SIGAMDT - Medicina e Seguranca do Trabalho                     ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/ 
Function MDTA565()

//------------------------------------------------------------------
// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
//------------------------------------------------------------------
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
//------------------------------------------------------------------
// Array que recebe as opcoes do campo, ja identificando as
// respectivas cores
//------------------------------------------------------------------
Local aCores := {{"TKS->TKS_SITUAC = '1'", 'BR_VERDE'    },;
                 {"TKS->TKS_SITUAC = '2'", 'BR_VERMELHO' }}
                 
If !NGCADICBASE("TKS_CODCJN","A","TKS",.F.)
	If !NGINCOMPDIC("UPDMDT38","TDGQ95")
		Return .F.
	Endif
Endif

//------------------------------------------------------------------
// Define o cabecalho da tela de atualizacoes
//------------------------------------------------------------------
PRIVATE cCadastro
PRIVATE aRotina
PRIVATE bNGGRAVA
//-----------------------------------------------------------------
// aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-
// s�o do registro.
//
// 1 - Chave de pesquisa
// 2 - Alias de pesquisa
// 3 - Ordem de pesquisa
//------------------------------------------------------------------
Private aChkDel :=  {{'TKS->TKS_CODCJN' ,"TLD",2}} 

If AMiIn( 35 ) // Somente autorizado para SIGAMDT
	
	//------------------------------------------------------------------
	// Endereca a funcao de BROWSE
	//------------------------------------------------------------------
	aRotina := MenuDef()
	cCadastro := OemtoAnsi(STR0001)   //"Conjuntos Hidr�ulicos"
	
	DbSelectArea("TKS")
	DbSetOrder(1)
	mBrowse( 6, 1,22,75,"TKS",,,,,,aCores)
EndIf

//------------------------------------------------------------------
//� Devolve variaveis armazenadas (NGRIGHTCLICK)
//------------------------------------------------------------------
NGRETURNPRM(aNGBEGINPRM)

Return .T. 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Jackson Machado		  � Data �16/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Utilizacao de Menu Funcional.                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMDT                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ�� 
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local	aRotina :=	{ 	{ STR0003, "AxPesqui" , 0 , 1},;  //"Pesquisar"
					{ STR0004, "NGCAD01"  , 0 , 2},;   //"Visualizar"
					{ STR0006, "NGCAD01", 0 , 3},;  //"Incluir"
					{ STR0007, "NGCAD01"  , 0 , 4},; //"Alterar"
					{ STR0008, "NGCAD01", 0 , 5, 3} }  //"Excluir" 
					
Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MDT565LBEM�Autor  �Jackson Machado     � Data �  05/12/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Limpa as campos relacionados ao cadastro do bem            ���
�������������������������������������������������������������������������͹��
���Uso       � MDTA565 (When de campo)                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MDT565LBEM()
Local nFor := If((TAMSX3("A2_COD")[1]) < 1,6,(TAMSX3("A2_COD")[1]))
Local nLoj := If((TAMSX3("A2_LOJA")[1]) < 1,2,(TAMSX3("A2_LOJA")[1]))
Local nCC  := If((TAMSX3("CTT_CUSTO")[1]) < 1,9,(TAMSX3("CTT_CUSTO")[1]))

If Empty(M->TKS_BEM)
	M->TKS_DESCJN := SPACE(40)
	M->TKS_FAMCJN := SPACE(16)
	M->TKS_NFACJN := SPACE(20)
	M->TKS_FORNEC := SPACE(nFor)
	M->TKS_LOJA   := SPACE(nLoj)
	M->TKS_NOMFOR := SPACE(40)
	M->TKS_CCCJN  := SPACE(nCC)
	M->TKS_NCCCJN := SPACE(20)
	M->TKS_TURCJN := SPACE(9)
	M->TKS_NTUCJN := SPACE(20)
	M->TKS_DTCOMP := STOD(SPACE(8))
	M->TKS_ANOFAB := SPACE(4)
	M->TKS_FABRIC := SPACE(6)
	M->TKS_NOMFAB := SPACE(40)
	M->TKS_MODELO := SPACE(10)
Endif

Return .T.