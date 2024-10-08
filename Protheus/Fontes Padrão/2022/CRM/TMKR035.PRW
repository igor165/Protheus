#INCLUDE "TMKR035.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKR035  � Autor � Rafael M. Quadrotti   � Data � 30/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Eventos-Gerencia de Campanhas                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Call Center - Relatorios 			                      ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKR035()

Local oReport
Local aArea := GetArea()

//���������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                          �
//� Mv_Par01           // Do Evento                               �
//� Mv_Par02           // Ate Evento                              �
//�����������������������������������������������������������������
Pergunte("TMK035",.F.)

//����������������������Ŀ
//�Interface de impressao�
//������������������������
oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �ReportDef    �Autor  �Hanna               � Data �  23/06/06   ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela-  ���
���          �latorio                                                        ���
����������������������������������������������������������������������������͹��
���Uso       � TMKR035                                                       ���
����������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                            ���
����������������������������������������������������������������������������͹��
���Hanna C   �26/07/06�R4    � Inclusao SetLineStyle para impressao estilo   ���
���          �        �      � Enchoice                                      ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport			// Objeto do relatorio
Local oSection1			// Objeto da secao 1
Local oSection2			// Objeto da secao 2

//�������������������������������������������������������������������Ŀ
//�Gera a tela com os dados para a confirma��o da geracao do relatorio�
//���������������������������������������������������������������������

//"Emiss�o de Eventos de Marketing. "
// "Este programa ira emitir uma relacao dos Eventos " # "de Marketing cadastrados no Call Center."
DEFINE REPORT oReport NAME "TMKR035" TITLE STR0001 PARAMETER "TMK035" ACTION {|oReport| Tkr035PrtRpt(oReport)} DESCRIPTION STR0002 + STR0003

//���������������������������������������������������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal utlizado eh o SL3 e o complementar o SB1�
//�����������������������������������������������������������������������������������������������������������
DEFINE SECTION oSection1 OF oReport TITLE STR0046 TABLES "ACD"		// "Cadastro de Eventos"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������
DEFINE CELL NAME "ACD_CODIGO"	OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_DESC"		OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_TEMA"		OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_TIPEXP"	OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_GRATUI"	OF oSection1 ALIAS "ACD"	//Alltrim(If((cACD)->ACD_GRATUI = "1",STR0018,STR0019)) //"Gratuito    : "###"SIM"###"N�O"
DEFINE CELL NAME "ACD_PRECO"	OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_LOCAL"	OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_END"		OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_MUN"		OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_EST"		OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_PAIS"		OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_TEL"		OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_HPAGE"	OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_EMAIL"	OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_DTINI"	OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_DTFIM"	OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_HRINI"	OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_HRFIM"	OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_ESTAC"	OF oSection1 ALIAS "ACD"
DEFINE CELL NAME "ACD_ENDEST"	OF oSection1 ALIAS "ACD"

//���������������������������������������������
//�Pula pagina quando houver a quebra da secao�
//���������������������������������������������
oSection1:SetPageBreak ( .T. ) 
oSection1:SetLineStyle()

//�������������������������������������������������������������������������������������Ŀ
//�Define a secao2 (que sera filha da secao1)  e o arquivo principal utilizado na secao �
//���������������������������������������������������������������������������������������
DEFINE SECTION oSection2 OF oSection1 TITLE STR0047 TABLES "ACE"	// "Grade de Eventos"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao2�
//�����������������������������������������������
DEFINE CELL NAME "ACE_GRADE"	OF oSection2 ALIAS "ACE"
DEFINE CELL NAME "ACE_TEMA"		OF oSection2 ALIAS "ACE"
DEFINE CELL NAME "ACE_HRINI"	OF oSection2 ALIAS "ACE"
DEFINE CELL NAME "ACE_HRFIM"	OF oSection2 ALIAS "ACE"
DEFINE CELL NAME "ACE_DATA"		OF oSection2 ALIAS "ACE"
DEFINE CELL NAME "ACE_SALA"		OF oSection2 ALIAS "ACE"
DEFINE CELL NAME "ACE_PALEST"	OF oSection2 ALIAS "ACE"
DEFINE CELL NAME "ACE_EMP"		OF oSection2 ALIAS "ACE"

Return oReport

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �TKR035PrtRpt�Autor  �Hanna               � Data �  17/05/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio personalizavel             ���
���������������������������������������������������������������������������͹��
���Uso       � TMKR035                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function TKR035PrtRpt( oReport )
Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
Local oSection2 := oSection1:Section(1)				// Define que a secao 2 serah filha da secao 1
Local cAlias1	:= GetNextAlias()					// Pega o proximo Alias Disponivel
Local cFiltro	:= ""								// Variavel utilizada para o filtro

DbSelectArea("ACD")
DbSetOrder(1)
//���������������������������������������������������������������������������������Ŀ
//�Transforma parametros do tipo Range em expressao SQL para ser utilizada na query �
//�Exemplo Word, nao intervalos pre definidos (mais utilizado pelo RH - Ferias)     �
//�����������������������������������������������������������������������������������
MakeSqlExpr("TMK035")

//��������������������Ŀ
//�Inicializa a secao 1�
//����������������������
BEGIN REPORT QUERY oSection1

//������������������
//�Query da secao 1�
//������������������
BeginSql alias cAlias1
	SELECT	ACD_CODIGO,	ACD_DESC,	ACD_TEMA,	ACD_TIPEXP,	ACD_GRATUI, 
			ACD_PRECO,	ACD_LOCAL,	ACD_END,	ACD_MUN,	ACD_EST,
			ACD_PAIS,	ACD_TEL,	ACD_HPAGE,	ACD_EMAIL,	ACD_DTINI,	
			ACD_DTFIM,	ACD_HRINI,	ACD_HRFIM,	ACD_ESTAC,	ACD_ENDEST,
			ACE_GRADE,	ACE_TEMA,	ACE_HRINI,	ACE_HRFIM,	ACE_DATA,
			ACE_SALA,	ACE_PALEST,	ACE_EMP

	FROM %table:ACD% ACD,%table:ACE% ACE
	WHERE	ACD_FILIAL	=	%xfilial:ACD%	AND
			ACE_FILIAL	=	%xfilial:ACE%	AND
			ACD_CODIGO	>=	%exp:mv_par01%	AND
			ACD_CODIGO	<=	%exp:mv_par02%	AND
			ACE_CODIGO	=	ACD_CODIGO		AND
			ACD.%notDel%					AND
			ACE.%notDel%

	ORDER BY %Order:ACD%
EndSql

//���������������������������������������������������������������������������Ŀ
//�Indica o fim da query, caso utilize range, deve-se informar como parametro �
//�{MV_?,MV_?} para que seja incluido no select automaticamente               �
//�����������������������������������������������������������������������������
END REPORT QUERY oSection1 //PARAM mv_par01,mv_par02

oSection2:SetParentQuery()
oSection2:SetParentFilter({|cParam| (cAlias)->ACD_CODIGO == cParam},{|| (cAlias)->ACD_CODIGO})

//�������������������������������������������Ŀ
//�Quebra a linha, caso existam muitas colunas�
//���������������������������������������������
oSection1:SetLineBreak()

//��������������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou query�
//����������������������������������������������������������������
oSection1:Print()
Return