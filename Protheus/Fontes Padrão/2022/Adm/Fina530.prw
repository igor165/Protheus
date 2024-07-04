#INCLUDE "FINA530.CH"
#INCLUDE "PROTHEUS.CH"

// 17/08/2009 - Compilacao para o campo filial de 4 posicoes
// 18/08/2009 - Compilacao para o campo filial de 4 posicoes

/*�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
��� Fun�ao	    � FINA530    � Autor � Newton Rogerio Ghiraldelli   � Data � 17/04/2000 ���
���������������������������������������������������������������������������������������Ĵ��
��� Descri�ao   � Atualizacao da Tabela de Indices Aplicados                            ���
���������������������������������������������������������������������������������������Ĵ��
��� Sintaxe	    � FINA530()                                                             ���
���������������������������������������������������������������������������������������Ĵ��
��� Parametros  � Nao tem                                                               ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso		    � Generico                                                              ���
���������������������������������������������������������������������������������������Ĵ��
��� Observacoes � Nao tem																					 ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������  ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.  �������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
��� Programador �    BOPS    �    BOPS     �                 Alteracao                  ���
���������������������������������������������������������������������������������������Ĵ��
���             �            �             �                                            ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������*/

Function FINA530()

//����������������������������������������������������������������������������������������Ŀ
//�                                                                                        �
//� Definicao de variaveis                                                                 �
//�                                                                                        �
//������������������������������������������������������������������������������������������
//����������������������������������������������������������������������������������������Ŀ
//�                                                                                        �
//� Define Array contendo as Rotinas que serao executada pelo programa                     �
//�                                                                                        �
//� --------------------------- Elementos contidos por dimensao -------------------------- �
//�                                                                                        �
//� 1. Nome a aparecer no botao ( cabecalho )                                              �
//� 2. Nome da Rotina associada                                                            �
//� 3. Usado pela rotina                                                                   �
//� 4. Tipo de Transa��o a ser efetuada                                                    �
//�    1 - Pesquisa e Posiciona em um Banco de Dados                                       �
//�    2 - Visualiza os campos do registro corrente                                        �
//�    3 - Inclui registros no Bancos de Dados                                             �
//�    4 - Altera o registro corrente                                                      �
//�    5 - Remove o registro corrente                                                      �
//�                                                                                        �
//������������������������������������������������������������������������������������������

Private aRotina := MenuDef()
//����������������������������������������������������������������������������������������Ŀ
//�                                                                                        �
//� Define o cabecalho da tela de atualizacoes                                             �
//�                                                                                        �
//������������������������������������������������������������������������������������������

Private cCadastro := OemToAnsi(STR0006) //"Cadastro de Indices Aplicados"

//����������������������������������������������������������������������������������������Ŀ
//�                                                                                        �
//� Endereca a funcao de BROWSE                                                            �
//�                                                                                        �
//������������������������������������������������������������������������������������������

mBrowse( 06, 01, 22, 75, "SEP" )

Return nil

/*�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
��� Fun�ao	    � FA530DEL   � Autor � Newton Rogerio Ghiraldelli   � Data � 17/04/2000 ���
���������������������������������������������������������������������������������������Ĵ��
��� Descri�ao   � Exclusao de registros da tabela Indices Aplicados                     ���
���������������������������������������������������������������������������������������Ĵ��
��� Sintaxe	    � FA530DEL( cAlias, nReg, nOpc )                                        ���
���������������������������������������������������������������������������������������Ĵ��
��� Parametros  � cAlias : Alias do Arquivo                                             ���
���             � nReg   : Numero do Registro                                           ���
���             � nOpc   : Numero da opcao selecionada                                  ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso		    � Generico                                                              ���
���������������������������������������������������������������������������������������Ĵ��
��� Observacoes � Nao tem																					 ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������*/

Function FA530DEL( cAlias, nReg, nOpc )

//����������������������������������������������������������������������������������������Ŀ
//�                                                                                        �
//� Definicao de variaveis                                                                 �
//�                                                                                        �
//������������������������������������������������������������������������������������������

Local ni
Local nOpcA
Local oDlg
Local lDeleta	:= .t.
Local bCampo
Local aSize := MsAdvSize()
      
//����������������������������������������������������������������������������������������Ŀ
//�                                                                                        �
//� Monta a entrada de dados do arquivo                                                    �
//�                                                                                        �
//������������������������������������������������������������������������������������������

Private aTELA[0][0]
Private aGETS[0]

oSize := FWDefSize():New(.T.)
oSize:AddObject( "ENCHOICE", 100,100, .T., .T. ) // Adiciona enchoice
oSize:Process()
aPos := {oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI"),oSize:GetDimension("ENCHOICE","LINEND"),oSize:GetDimension("ENCHOICE","COLEND")}

//����������������������������������������������������������������������������������������Ŀ
//�                                                                                        �
//� Verifica se o arquivo est� realmente vazio ou se est� posicionado em outra filial.     �
//�                                                                                        �
//������������������������������������������������������������������������������������������

If Eof() .or. SEP->EP_FILIAL # xFilial( "SEP" )
	Help( " " , 1, "ARQVAZIO" )
	Return Nil
Endif

While .t.

		//����������������������������������������������������������������������������������Ŀ
		//�                                                                                  �
		//� Envia para processamento dos Gets.                                               �
		//�                                                                                  �
		//������������������������������������������������������������������������������������

		DbSelectArea( cAlias )
		bCampo := { |nCPO| Field( nCPO ) }
		For ni := 1 TO FCount()
			M->&( EVAL( bCampo, ni ) ) := FieldGet( ni )
		Next ni

		nOpca := 1

		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5] of oMainWnd PIXEL

		EnChoice( cAlias, nReg, nOpc, , "AC", OemToAnsi( STR0009 ),, aPos ) //"Quanto � exclus�o?"

		ACTIVATE	MSDIALOG	oDlg;
					ON INIT	EnchoiceBar( oDlg, { || nOpca := 2, oDlg:End() }, { || nOpca := 1, oDlg:End() } )

		DbSelectArea( cAlias )

		If nOpcA == 2
/*
			//�������������������������������������������������������������������������������Ŀ
			//�                                                                               �
			//� Antes de deletar, verificar se existe arramacao com outros arquivos.          �
			//�                                                                               �
			//���������������������������������������������������������������������������������

			DbSelectArea( "SEM" ) 
			DbSetOrder(  )

			//�������������������������������������������������������������������������������Ŀ
			//�                                                                               �
			//� SEM - Arquivo de Contratos CDCI.                                              �
			//�                                                                               �
			//���������������������������������������������������������������������������������

			If ( dbSeek( cFilial +  ) )
				Help(" ", 1, "FIA500NDEL" )
				lDeleta := .f.
				MsUnlock()
			Else
				DbSelectArea( "SEN" )
				DbSetOrder(  )

				//����������������������������������������������������������������������������Ŀ
				//�                                                                            �
				//� SEN - Arquivo de Planos de Venda.                                          �
				//�                                                                            �
				//������������������������������������������������������������������������������

				If ( dbSeek( cFilial + ) )
					Help(" ", 1, "FIA500NDEL" )
					lDeleta := .f.
					MsUnlock()
				Endif
			Endif

			//�������������������������������������������������������������������������������Ŀ
			//�                                                                               �
			//� Se nao houver amarracao deleta o registro corrente.                           �
			//�                                                                               �
			//���������������������������������������������������������������������������������
*/
			If lDeleta
				Begin Transaction
						DbSelectArea( cAlias )
						RecLock( cAlias, .f., .t. )
						dbDelete()
				End Transaction
			Endif
		Else
			MsUnlock( )
		Endif
		Exit
Enddo

//����������������������������������������������������������������������������������������Ŀ
//�                                                                                        �
//� Devolve as ordens aos arquivos pesquisados.                                            �
//�                                                                                        �
//������������������������������������������������������������������������������������������
/*
dbSelectArea( "SEM" )
dbSetOrder( 1 )

dbSelectArea( "SEN" )
dbSetOrder( 1 )
*/
dbSelectArea( cAlias )

Return nil

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �27/11/06 ���
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
Local aRotina := {	{ OemToAnsi( STR0001 ) ,"AxPesqui", 0, 1,,.F. },; //"Pesquisar"
							{ OemToAnsi( STR0002 ) ,"AxVisual", 0, 2 },; //"Visualizar"
							{ OemToAnsi( STR0003 ) ,"AxInclui", 0, 3 },; //"Incluir"
							{ OemToAnsi( STR0004 ) ,"AxAltera", 0, 4 },; //"Alterar"
							{ OemToAnsi( STR0005 ) ,"FA530Del", 0, 5 } } //"Excluir"
Return(aRotina)