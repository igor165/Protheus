#INCLUDE "PRR010.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PRR010   � Autor � Tatiana L Campos      � Data � 03/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Pesquisas por Questionario                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Gestao de pesquisa e resultado - GPR                       ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PRR010()

Local oReport
Local aArea := GetArea()

If FindFunction("TRepInUse") .OR. TRepInUse()

	//���������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                          �
	//� Mv_Par01           // De pesquisa                             �
	//� Mv_Par02           // Ate pesquisa                            �
	//�����������������������������������������������������������������
	Pergunte("PRR010",.F.)

	//����������������������Ŀ
	//�Interface de impressao�
	//������������������������
	oReport := Prr010RptDef()
	oReport:PrintDialog()
EndIf

RestArea( aArea )
Return

/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �Prr010RptDef �Autor  �Tatiana L Campos    � Data �  04/08/06   ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela-  ���
���          �latorio                                                        ���
����������������������������������������������������������������������������͹��
���Uso       � PRR010                                                        ���
����������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                            ���
����������������������������������������������������������������������������͹��
���          �        �      �                                               ���
���          �        �      �                                               ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function Prr010RptDef()
Local oReport			// Objeto do relatorio
Local oSection1			// Objeto da secao 1
Local oSection2			// Objeto da secao 2

//�������������������������������������������������������������������Ŀ
//�Gera a tela com os dados para a confirmacao da geracao do relatorio�
//���������������������������������������������������������������������

//"Emissao de Pesquisa e questionario. "
// "Este programa ira emitir uma relacao das Pesquisas e questionario." 
DEFINE REPORT oReport NAME "PRR010" TITLE STR0001 PARAMETER "PRR010" ACTION {|oReport| Prr010PrtRpt(oReport)} DESCRIPTION STR0002

//���������������������������������������������������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal utlizado eh o SKC e o complementar o SKP�
//�����������������������������������������������������������������������������������������������������������

DEFINE SECTION oSection1 OF oReport TITLE STR0001 TABLES "SKC"		// "Itens da pesquisa"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������

DEFINE CELL NAME "KC_CODPQ"	OF oSection1 ALIAS "SKC"	//Codigo da pesquisa
DEFINE CELL NAME "KC_DESC"	OF oSection1 ALIAS "SKC"	//Descricao da pesquisa
DEFINE CELL NAME "KC_DTDE"	OF oSection1 ALIAS "SKC"	//Data inicial
DEFINE CELL NAME "KC_DTATE"	OF oSection1 ALIAS "SKC"	//Data final

//�������������������������������������������������������������������������������������Ŀ
//�Define a secao2 (que sera filha da secao1)  e o arquivo principal utilizado na secao �
//���������������������������������������������������������������������������������������
DEFINE SECTION oSection2 OF oSection1 TITLE STR0002 TABLES "SKP"	// "Dados do question�rio"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao2�
//�����������������������������������������������
DEFINE CELL NAME "KP_CODQUE"	OF oSection2 ALIAS "SKP"	//Codigo do questionario
DEFINE CELL NAME "KP_DESC"		OF oSection2 ALIAS "SKP"	//Descricao do questionario

Return oReport

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �PRR010PrtRpt�Autor  �Tatiana L Campos    � Data �  04/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio personalizavel             ���
���������������������������������������������������������������������������͹��
���Uso       � PRR010                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function Prr010PrtRpt( oReport )
Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
Local oSection2 := oSection1:Section(1)				// Define que a secao 2 serah filha da secao 1
Local cAlias1	:= GetNextAlias()					// Pega o proximo Alias Disponivel
Local cFiltro	:= ""								// Variavel utilizada para o filtro

#IFDEF TOP
	DbSelectArea("SKC")
	DbSetOrder(1)
	//���������������������������������������������������������������������������������Ŀ
	//�Transforma parametros do tipo Range em expressao SQL para ser utilizada na query �
	//�Exemplo Word, nao intervalos pre definidos (mais utilizado pelo RH - Ferias)     �
	//�����������������������������������������������������������������������������������
	MakeSqlExpr("PRR010")

	//��������������������Ŀ
	//�Inicializa a secao 1�
	//����������������������
	BEGIN REPORT QUERY oSection1

	//����������������Ŀ
	//�Query da secao 1�
	//������������������

	BeginSql alias cAlias1
		SELECT	KC_CODPQ,	KC_DESC,	KC_DTDE,	KC_DTATE,	
				KP_CODQUE, KP_DESC
				

		FROM %table:SKC% SKC,%table:SKP% SKP,%table:SKD% SKD
		WHERE	KC_FILIAL	=	%xfilial:SKC%	AND
				KP_FILIAL	=	%xfilial:SKP%	AND
				KD_FILIAL	=   %xfilial:SKD%	AND 
				KC_CODPQ	>=	%exp:mv_par01%	AND
				KC_CODPQ	<=	%exp:mv_par02%	AND
				KC_CODPQ	=	KD_CODPQ 		AND
				KP_CODQUE	=	KD_CODQT		AND
				SKC.%notDel%					AND
				SKP.%notDel%					AND
				SKD.%notDel%
		ORDER BY %Order:SKC%
	EndSql
	END REPORT QUERY oSection1

	oSection2:SetParentQuery()
	oSection2:SetParentFilter({|cParam| (cAlias1)->KC_CODPQ == cParam},{|| (cAlias1)->KC_CODPQ})

#ENDIF

//��������������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou query�
//����������������������������������������������������������������
oSection1:Print()
Return