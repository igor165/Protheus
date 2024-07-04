#INCLUDE "FINA500.CH"
#INCLUDE "PROTHEUS.CH"

/*�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
��� Fun�ao	    � FINA500    � Autor � Newton Rogerio Ghiraldelli   � Data � 14/04/2000 ���
���������������������������������������������������������������������������������������Ĵ��
��� Descri�ao   � Atualizacao da Tabela de IOC ( Imposto sobre Operacoes de Credito )   ���
���������������������������������������������������������������������������������������Ĵ��
��� Sintaxe	    � FINA500()                                                             ���
���������������������������������������������������������������������������������������Ĵ��
��� Parametros  � Nao tem                                                               ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso		    � Generico                                                              ���
���������������������������������������������������������������������������������������Ĵ��
��� Observacoes � Nao tem																		   ���
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

Function FINA500()

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

Private cCadastro := OemToAnsi(STR0006) //"Cadastro de Impostos sobre Operacoes de Credito"

//����������������������������������������������������������������������������������������Ŀ
//�                                                                                        �
//� Endereca a funcao de BROWSE                                                            �
//�                                                                                        �
//������������������������������������������������������������������������������������������

mBrowse( 06, 01, 22, 75, "SEO" )

Return nil

/*�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
��� Fun�ao	    � FA500DEL   � Autor � Newton Rogerio Ghiraldelli   � Data � 14/04/2000 ���
���������������������������������������������������������������������������������������Ĵ��
��� Descri�ao   � Exclusao de registros da da tabela de IOC - Imp. Operacoes de Credito ���
���������������������������������������������������������������������������������������Ĵ��
��� Sintaxe	    � FA500DEL( cAlias, nReg, nOpc )                                        ���
���������������������������������������������������������������������������������������Ĵ��
��� Parametros  � cAlias : Alias do Arquivo                                             ���
���             � nReg   : Numero do Registro                                           ���
���             � nOpc   : Numero da opcao selecionada                                  ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso		    � Generico                                                              ���
���������������������������������������������������������������������������������������Ĵ��
��� Observacoes � Nao tem								                                ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������*/

Function FA500DEL( cAlias, nReg, nOpc )

//����������������������������������������������������������������������������������������Ŀ
//�                                                                                        �
//� Definicao de variaveis                                                                 �
//�                                                                                        �
//������������������������������������������������������������������������������������������

Local ni
Local nOpcA
Local oDlg
Local bCampo
Local aSize := MsAdvSize()
Local oEnc01
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
aPos := {	oSize:GetDimension("ENCHOICE","LININI"),;
			oSize:GetDimension("ENCHOICE","COLINI"),;
			oSize:GetDimension("ENCHOICE","LINEND"),;
			oSize:GetDimension("ENCHOICE","COLEND")		}

//����������������������������������������������������������������������������������������Ŀ
//�                                                                                        �
//� Verifica se o arquivo est� realmente vazio ou se est� posicionado em outra filial.     �
//�                                                                                        �
//������������������������������������������������������������������������������������������

If Eof() .or. SEO->EO_FILIAL # xFilial( "SEO" )
	Help( " " , 1, "ARQVAZIO" )
	Return Nil
Endif

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
oEnc01:= MsMGet():New( cAlias, nReg, nOpc,,,,,aPos,,,,,,,,,,,,,,,,,)	
oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT	
ACTIVATE	MSDIALOG	oDlg;
	ON INIT	 EnchoiceBar( oDlg, { || nOpca := 2, oDlg:End() }, { || nOpca := 1, oDlg:End() } )

DbSelectArea( cAlias )

If nOpcA == 2
	Begin Transaction
		DbSelectArea( cAlias )
		RecLock( cAlias, .f., .t. )
		dbDelete()
		MsUnlock( )
	End Transaction
endif

dbSelectArea( cAlias )

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FA500Inc
Programa para inclus�o na Tabela de IOC (SEO)

@author		Sidney Silva
@since		16/06/2021
@version	P12
@sample		Fa500Inc()

/*/
//-------------------------------------------------------------------
Function FA500Inc()
Local lRetorno		As Logical
Local cAlias		As Character
Local nReg			As Numeric
Local nOpc			As Numeric

cAlias 	:= "SEO"
nReg	:= 0
nOpc	:= 3

	lRetorno := AxInclui( cAlias, nReg, nOpc, , , , "FA500TudOk()" )                             
	
Return(lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} FA500TudOk
Programa para valida��o se j� existe o indice na Tabela de IOC

@author		Sidney Silva
@since		16/06/2021
@version	P12
@sample		FA500TudOk()

/*/
//-------------------------------------------------------------------
Function FA500TudOk()

Local aAreaSEO 		As Array
Local lRetorno 		As Logical

aAreaSEO := GetArea()
lRetorno := .T.

DbSelectArea("SEO")
DbSetOrder(1)

	If DbSeek(xFilial("SEO") + M->EO_CODIGO)	
		lRetorno := .F.	
		Help(" ", 1, "FINA500CHV",,STR0010,1,0) // C�digo j� cadastrado para Filial corrente.		
    EndIf

RestArea(aAreaSEO)

Return(lRetorno)

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

Local aRotina := {	{ OemToAnsi( STR0001 ),	"AxPesqui",	0, 	1,,	.F.	},;	//	"Pesquisar"
					{ OemToAnsi( STR0002 ),	"AxVisual",	0, 	2 		},; //	"Visualizar"
					{ OemToAnsi( STR0003 ),	"FA500Inc",	0, 	3 		},; //	"Incluir"
					{ OemToAnsi( STR0004 ),	"AxAltera",	0, 	4 		},; //	"Alterar"
					{ OemToAnsi( STR0005 ),	"FA500Del",	0, 	5 		} ; //	"Excluir"
				} 

Return(aRotina)							
