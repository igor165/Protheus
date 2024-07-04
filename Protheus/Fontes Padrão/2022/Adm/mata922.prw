#INCLUDE "MATA922.CH"
#INCLUDE "PROTHEUS.CH"
/*
���������������������������������������������������������������������������
���������������������������������������������������������������������������
�����������������������������������������������������������������������ͻ��
���Programa  �MATA922 �Autor  �Luciana Pires       � Data �  28/11/06   ���
�����������������������������������������������������������������������͹��
���Desc.     �Cadastro das Esp�cies de Publica��es - DIF Papel          ���
�����������������������������������������������������������������������͹��
���Uso       �SIGACDA                                                   ���
�����������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������
���������������������������������������������������������������������������
*/
Function Mata922()

                                                                        
Private cCadastro := 	STR0001 //"Cadastro das Esp�cies de Publica��es"
Private aRotina   :=	MenuDef()

If FindFunction("ALIASINDIC") .And. AliasIndic("AHH")
	mBrowse( 6, 1,22,75,"AHH")
Endif
Return

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Funcao    �A922Inclui�Autor �Luciana Pires       � Data �  28/11/06   ���
������������������������������������������������������������������������͹��
���Desc.     �Verifica se a esp�cie da publica��o esta cadastrada        ���
���          �                                                           ���
������������������������������������������������������������������������͹��
���Uso       �SIGACDA                                                    ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Function a922Inclui()
Local cAlias	:="AHH"
Local nReg		:=AHH->(Recno())
Local nOpc		:=3
Local nGravou	:=0

nGravou :=AxInclui( cAlias, nReg, nOpc,,,,"A922ChkInc()")

Return(.T.)


/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Funcao    �A922ChkInc�Autor �Luciana Pires       � Data �  28/11/06   ���
������������������������������������������������������������������������͹��
���Desc.     �Checa se a Esp�cie da Publica��o ja existe.                ���
���          �                                                           ���
������������������������������������������������������������������������͹��
���Uso       �SIGACDA                                                    ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Function a922ChkInc()
Local lRet			:=	.T.

AHH->(DbSetOrder(1))
SX5->(DbSetOrder(1))
If AHH->(dbSeek(xFilial("AHH")+M->AHH_CODPUB+M->AHH_CODELE))
   Help(" ",1,"ESPEXISTE",,STR0002,1,0) //"Esp�cie da Publica��o j� existe"
   lRet := .F.
ElseIf !(SX5->(DbSeek(xFilial("SX5")+"LN"+M->AHH_CODELE)))
	Help(" ",1,"ELEMENTO",,STR0003,1,0) //"Elemento da Publica��o n�o existe"
	lRet := .F.
ElseIf !Empty(M->AHH_CODPAP) .and. !(AHI->(DbSeek(xFilial("AHI")+M->AHH_CODPAP)))
	Help(" ",1,"PAPEL",,STR0004,1,0) //"Tipo de Papel n�o existe"
	lRet := .F.
Endif
Return lRet

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Funcao    �A922Alter �Autor �Luciana Pires       � Data �  28/11/06   ���
������������������������������������������������������������������������͹��
���Desc.     �Verifica as validacoes para alteracao.                     ���
���          �                                                           ���
������������������������������������������������������������������������͹��
���Uso       �SIGACDA                                                    ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Function a922Alter()
Local nReg	:=AHH->(Recno())
Local nOpc	:=4
Local cAlias:="AHH"
Local nX    :=0
Local aCpos :={}

For nX := 1 To FCount()
	M->&(FieldName(nX)) := CriaVar(FieldName(nX))
    // Campos nao editaveis
	If !(FieldName(nX)) $ "AHH_CODPUB/AHH_CODELE"
		Aadd(aCpos,FieldName(nX))
	EndIf
Next nX

AxAltera( cAlias, nReg, nOpc,,aCpos)
Return(.T.)

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Luciana Pires         � Data �28/11/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de Menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    	2 - Simplesmente Mostra os Campos                     ���
���          �    	3 - Inclui registros no Bancos de Dados               ���
���          �    	4 - Altera o registro corrente                        ���
���          �    	5 - Remove o registro corrente do Banco de Dados      ���
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
     
Private aRotina := {	{ "Pesquisar"	,"AxPesqui"		, 0 , 1, 0,.F.},;          
						{ "Visualizar" 	,"AxVisual"		, 0 , 2, 0,NIL},;          
						{ "Incluir" 	,"A922Inclui"	, 0 , 3, 0,NIL},;        
						{ "Alterar" 	,"A922Alter"	, 0 , 4, 2,NIL},;     
						{ "Excluir" 	,"AxDeleta"		, 0 , 5, 3,NIL}}  

If ExistBlock("MT922MNU")
	ExecBlock("MT922MNU",.F.,.F.)
EndIf

Return(aRotina)

