#INCLUDE "protheus.ch"
#INCLUDE "pmsr130.ch"
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

//--------------------------RELEASE 4-------------------------------------------//
Function PMSR130()
Local aArea		:= GetArea()

If PMSBLKINT()
	Return Nil
EndIf

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef()

If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf	

oReport:PrintDialog()

RestArea(aArea)

Return
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Paulo Carnelossi       � Data �04/07/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport
Local oProjeto
Local aOrdem := {}

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport := TReport():New("PMSR130",STR0002,"PMR130", ;
			{|oReport| ReportPrint(oReport)},;
			STR0001 )

//STR0002 //"Historico de Revisao"
//STR0001 //"Este relatorio ira imprimir um historico e os detalhes das revisoes efetuadas nos projetos de acordo com os parametros solicitados."

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//adiciona ordens do relatorio

oProjeto := TRSection():New(oReport, STR0006, {"AFE", "AF8"}, aOrdem /*{}*/, .F., .F.)

//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
TRCell():New(oProjeto,	"AFE_PROJET"	,"AFE",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAFE)->AFE_PROJET }*/)
TRCell():New(oProjeto,	"AF8_DESCRI"	,"AF8",/*Titulo*/,/*Picture*/,22/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAFE)->AF8_DESCRI }*/)
TRCell():New(oProjeto,	"AFE_REVISA"	,"AFE",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAFE)->AFE_REVISA }*/)
TRCell():New(oProjeto,	"AFE_DATAI"		,"AFE",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAFE)->AFE_DATAI }*/)
TRCell():New(oProjeto,	"AFE_HORAI"		,"AFE",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAFE)->AFE_HORAI }*/)
TRCell():New(oProjeto,	"AFE_DATAF"		,"AFE",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAFE)->AFE_DATAF }*/)
TRCell():New(oProjeto,	"AFE_HORAF"		,"AFE",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAFE)->AFE_HORAF }*/)
TRCell():New(oProjeto,	"AFE_USERF"		,"AFE",/*Titulo*/,/*Picture*/,17/*Tamanho*/,/*lPixel*/,{|| UsrRetName(AFE_USERF) })
TRCell():New(oProjeto,	"AFE_MEMO"		,"AFE",/*Titulo*/,/*Picture*/,28/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAFE)->AFE_MEMO }*/)

TRPosition():New(oProjeto, "AF8", 1, {|| xFilial("AF8") + AFE->AFE_PROJET + AFE->AFE_REVISA})

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor �Paulo Carnelossi      � Data �29/05/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �que faz a chamada desta funcao ReportPrint()                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �ExpO1: Objeto TReport                                       ���
���          �ExpC2: Alias da tabela de Planilha Orcamentaria (AK1)       ���
���          �ExpC3: Alias da tabela de Contas da Planilha (Ak3)          ���
���          �ExpC4: Alias da tabela de Revisoes da Planilha (AKE)        ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport )
Local oProjeto  := oReport:Section(1)
Local cAliasAFE := GetNextAlias()

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �	
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
//������������������������������������������������������������������������Ŀ
//�Query do relatorio da secao 1                                           �
//��������������������������������������������������������������������������
oProjeto:BeginQuery()	

BeginSql Alias cAliasAFE
SELECT AFE_PROJET, AF8_PROJET, AF8_DESCRI, AFE_REVISA, AFE_DATAI, AFE_HORAI, AFE_DATAF, AFE_HORAF, AFE_USERF, AFE_MEMO

FROM %table:AFE% AFE
	JOIN %table:AF8% AF8
	ON AF8.AF8_FILIAL = %xFilial:AF8% AND 
	AF8.AF8_PROJET = AFE.AFE_PROJET AND 
	AF8.%NotDel%

WHERE AFE.AFE_FILIAL = %xFilial:AFE% AND 
	AFE.AFE_PROJET >=%Exp:mv_par01% AND
	AFE.AFE_PROJET <=%Exp:mv_par02% AND 
	NOT (AFE.AFE_DATAF < %Exp:mv_par05% OR AFE.AFE_DATAF > %Exp:mv_par06% OR
		AFE.AFE_REVISA < %Exp:mv_par03% OR AFE.AFE_REVISA > %Exp:mv_par04%) AND
	AFE.%NotDel%

ORDER BY %Order:AFE%
		
EndSql 
//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oProjeto:EndQuery(/*Array com os parametros do tipo Range*/)

oProjeto:Print()

Return NIL