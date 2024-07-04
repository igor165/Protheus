#INCLUDE "SGAA450.ch"
#include "Protheus.ch"
#DEFINE _nVERSAO 2 //Versao do fonte

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGAA450   �Autor  �Roger Rodrigues     � Data �  10/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de Gases do Efeito Estufa                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SIGASGA                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGAA450()
//�����������������������������������������������������������������������Ŀ
//� Armazena variaveis p/ devolucao (NGRIGHTCLICK) 	   					  �
//�������������������������������������������������������������������������
Local aNGBEGINPRM 	:= NGBEGINPRM(_nVERSAO)

If Amiin(56) //Verifica se o usu�rio possui licen�a para acessar a rotina.

Private cCadastro 	:= STR0001 //"Gases do Efeito Estufa"
Private aRotina		:= MenuDef()
Private aMemos		:= {{"TD0_OBSERV", "TD0_MEMO1"}}
Private aChkSql		:= NGRETSX9("TD0")//Tabelas a serem verificadas na exclusao

If !SGAUPDGEE()//Verifica se o update de GEE esta aplicado
	Return .F.
Endif

If !SGAUPDCAMP()
	Return .F.
EndIf

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("TD0")
dbSetOrder(1)
mBrowse( 6, 1,22,75,"TD0")

EndIf
//�����������������������������������������������������������������������Ŀ
//� Devolve variaveis armazenadas (NGRIGHTCLICK) 					 	  �
//�������������������������������������������������������������������������
NGRETURNPRM(aNGBEGINPRM)

Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Roger Rodrigues       � Data �10/08/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Utilizacao de Menu Funcional.                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaSGA                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {	{ STR0002	, "AxPesqui", 0 , 1},; //"Pesquisar"
                    { STR0003	, "NGCAD01"	, 0 , 2},; //"Visualizar"
                    { STR0004	, "NGCAD01"	, 0 , 3},; //"Incluir"
                    { STR0005	, "NGCAD01"	, 0 , 4},; //"Alterar"
                    { STR0006	, "NGCAD01"	, 0 , 5, 3}} //"Excluir"

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGAUPDGEE �Autor  �Roger Rodrigues     � Data �  10/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se o update de GEE foi aplicado                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA450/SGAA460/SGAA470                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGAUPDGEE()

dbSelectArea("SX2")
dbSetOrder(1)
If !dbSeek("TD0") .or. !dbSeek("TD1") .or. !dbSeek("TD2") .or. !dbSeek("TD9")
	If !NGINCOMPDIC("UPDSGA02","00000020820/2010")
		Return .F.
	Endif
EndIf

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG450F3   �Autor  �Roger Rodrigues     � Data �  12/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta tela de consulta F3                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA470                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SG450F3(cAlias, nRecno, nOpcx)
Local nOpca := 0
Local lOldInclui := Inclui
Local lOldAltera := Altera
Private aMemos := {{"TD0_OBSERV", "TD0_MEMO1"}}
Inclui := (nOpcx == 3)
Altera := (nOpcx == 4)
nOpca := NGCAD01(cAlias, nRecno, nOpcx)
Inclui := lOldInclui
Altera := lOldAltera
If nOpca == 0
	Return .F.
Endif
Return .T.