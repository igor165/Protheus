#INCLUDE "TMKR033.CH"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKR033  � Autor � Armando M. Tessaroli  � Data � 19/03/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de clientes por segmento de negocios				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Call Center                                                ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Conrado Q.�17/08/06� 8.11 � Bops. 99202 Conversao para relatorio perso-���
���          �        �      � nalizado (Release 4)                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKR033()

Local oReport				// Objeto utilizado para a criacao do relatorio
Local aArea := GetArea()   // Armazena a area atual

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� Mv_Par01           // Do Vendedor                            �
//� Mv_Par02           // Ate o Vendedor                         �
//� Mv_Par03	         // Segmento Principal                     �
//� Mv_Par04 	         // Segmentos Secundarios                  �                       
//����������������������������������������������������������������
Pergunte("TMK033N",.F.)

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
���Programa  �ReportDef    �Autor  �Conrado Q. Gomes    � Data �  17/08/06   ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela-  ���
���          �latorio                                                        ���
����������������������������������������������������������������������������͹��
���Uso       � TMKR033 R4                                                    ���
����������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                            ���
����������������������������������������������������������������������������͹��
���          �        �      �                                               ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport			// Objeto do relatorio
Local oSection1			// Objeto da secao 1
Local cSA1 := "SA1"		// Alias da consulta Embedded SQL

#IFDEF TOP
	cSA1:=GetNextAlias()
#ENDIF	

//�������������������������������������������������������������������Ŀ
//�Gera a tela com os dados para a confirma��o da geracao do relatorio�
//���������������������������������������������������������������������

// "Listagem de Clientes x Segmentos"
// "Este Programa ira emitir listagens de Clientes x Segmentos de Negocios"
// " obedecendo os parametros, diferente das regras de valida��o de segmento, "
// " para manutencao da base de dados de clientes em relacao aos segmentos"
DEFINE REPORT oReport NAME "TMKR033" TITLE STR0001 PARAMETER "TMK033N" ACTION {|oReport| Tkr033PrtRpt(oReport, cSA1)} DESCRIPTION STR0002+STR0003+STR0004

//����������������������������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal utlizado eh o SA1�
//������������������������������������������������������������������������������������
DEFINE SECTION oSection1 OF oReport TITLE STR0010 TABLES "SA1"	// "Clientes"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������              
DEFINE CELL NAME "A1_COD"		OF oSection1 ALIAS "SA1" 
DEFINE CELL NAME "A1_LOJA"		OF oSection1 ALIAS "SA1"
DEFINE CELL NAME "A1_NOME"		OF oSection1 ALIAS "SA1"
DEFINE CELL NAME "A1_END"		OF oSection1 ALIAS "SA1"
DEFINE CELL NAME "A1_MUN"		OF oSection1 ALIAS "SA1"
DEFINE CELL NAME "A1_EST"		OF oSection1 ALIAS "SA1"
DEFINE CELL NAME "A1_DDD"		OF oSection1 ALIAS "SA1"
DEFINE CELL NAME "A1_TEL"		OF oSection1 ALIAS "SA1"

Return oReport

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �TKR033PrtRpt�Autor  �Conrado Q. Gomes    � Data �  17/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio personalizavel             ���
���������������������������������������������������������������������������͹��
���Uso       � TMKR033 R4                                                   ���
���������������������������������������������������������������������������͹��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������͹��
���Parametros� oReport: Objeto TReport do relatorio                         ���
���          � cAlias1: Alias criado para a utilizacao com o relatorio      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/              
Static Function TKR033PrtRpt( oReport, cAlias1 )
Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
Local cFiltro	:= ""								// Variavel utilizada para o filtro da secao 1
Local cSeg      := ""
Local cQuery      := ""
Local cJoin       := ""

DbSelectArea("SA1")
DbSetOrder(1)
	
//������������������������������������������������������������
//�Transforma parametros do tipo Range em expressao SQL      �
//�para ser utilizada na query  Exemplo Word, nao intervalos �
//�pre definidos (mais utilizado pelo RH - Ferias)           �
//������������������������������������������������������������
MakeSqlExpr("TMK033N")
	
If !Empty(Mv_Par03)

	cFiltro += " AND A1_CODSEG = '" + AllTrim(mv_par03) + "' "
		
Endif

If !Empty(Mv_Par04)		

	cJoin := " INNER JOIN " + RetSqlName("AOW") + " AOW "
	cJoin += " ON ( AOW.AOW_FILIAL = '" + xFilial("AOW") + "' "
	cJoin += "  AND AOW.AOW_CODSEG = SA1.A1_CODSEG "
	cJoin += "  AND AOW.AOW_FILENT = '" + xFilial("SA1") + "' "
	cJoin += "  AND AOW.AOW_ENTIDA = 'SA1' "
	cJoin += "  AND AOW.AOW_CODCNT = SA1.A1_COD "
	cJoin += "  AND AOW.AOW_LOJCNT = SA1.A1_LOJA "
	cJoin += "  AND AOW.D_E_L_E_T_ = ' ' ) "
		
	cFiltro  +=  " AND " + STRTRAN ( Alltrim(Mv_Par04) , ';', "','", , )

Endif				
		
cJoin    := "% " + cJoin + " %"
cFiltro  := "% " + cFiltro + " %"

//��������������������Ŀ
//�Inicializa a se��o 1�
//����������������������
BEGIN REPORT QUERY oSection1
	
//����������������Ŀ
//�Query da se��o 1�
//������������������
BeginSql alias cAlias1    
	SELECT	Distinct A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_END,
			A1_MUN, A1_EST, A1_DDD, A1_TEL
	FROM	%table:SA1% SA1
			%exp:cJoin%
	WHERE	 SA1.A1_FILIAL	=	%xfilial:SA1%
		AND	 SA1.A1_COD 		>=	%exp:mv_par01%
		AND	 SA1.A1_COD		<=	%exp:mv_par02%
		AND	 SA1.%notDel%  %exp:cFiltro%
	Group by A1_COD,A1_LOJA,A1_NOME,A1_END,A1_MUN,A1_EST,A1_DDD,A1_TEL,A1_FILIAL
	ORDER BY %Order:SA1%
EndSql
	
//�������������������Ŀ
//�Finaliza a se��o 1.�
//���������������������
END REPORT QUERY oSection1

//��������������������������������������������Ŀ
//�Quebra a linha, caso existam muitas colunas.�
//����������������������������������������������
oSection1:SetLineBreak()

//���������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou �
//�query.                                                   �
//�����������������������������������������������������������
oSection1:Print()

Return Nil