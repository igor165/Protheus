#INCLUDE "TMSR150.CH"
#include "protheus.ch"
#include "report.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSR150   � Autor �Rodolfo K. Rosseto     � Data �09/06/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime ocorrencias de entrega por filial.                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMSR150()

Local oReport
Local aArea := GetArea()

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef()
oReport:PrintDialog()

RestArea(aArea)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �                       � Data �          ���
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
Local oFilial
Local oOcorren
Local oTotFil
Local cAliasQry   := GetNextAlias()
Local cAliasTot   := GetNextAlias()

Pergunte("TMR150",.F.)

DEFINE REPORT oReport NAME "TMSR150" TITLE STR0016 DESCRIPTION STR0017 PARAMETER "TMR150" LANDSCAPE ACTION {|oReport| ReportPrint(oReport,cAliasQry,cAliasTot)}

	DEFINE SECTION oFilial OF oReport TITLE STR0024 TABLES "DUA"

		DEFINE CELL NAME "DUA_FILOCO" OF oFilial ALIAS "DUA"
		
	DEFINE SECTION oOcorren OF oFilial TITLE STR0022 TABLES "DUA" TOTAL IN COLUMN
		
		DEFINE CELL NAME "DUA_CODOCO" OF oOcorren ALIAS "DUA"
		DEFINE CELL NAME "DT2_DESCRI" OF oOcorren ALIAS "DT2"
		DEFINE CELL NAME "QTDTOTAL"	OF oOcorren ALIAS "   " TITLE STR0018	SIZE 3 BLOCK { || (cAliasQry)->MES+(cAliasQry)->ANT }
		DEFINE CELL NAME "QTDMES" 		OF oOcorren ALIAS "   " TITLE STR0019	SIZE 3 BLOCK { || (cAliasQry)->MES }
		DEFINE CELL NAME "QTDANTER" 	OF oOcorren ALIAS "   " TITLE STR0020	SIZE 3 BLOCK { || (cAliasQry)->ANT }
		DEFINE CELL NAME "PERC" 		OF oOcorren ALIAS "   " TITLE STR0021	SIZE 3 BLOCK { || ( ((cAliasQry)->MES+(cAliasQry)->ANT)/ TMSR150Cnt((cAliasQry)->DUA_FILOCO)) * 100 }

		DEFINE FUNCTION FROM oOcorren:Cell("QTDTOTAL") 	FUNCTION SUM NO END REPORT
		DEFINE FUNCTION FROM oOcorren:Cell("QTDMES") 	FUNCTION SUM NO END REPORT
		DEFINE FUNCTION FROM oOcorren:Cell("QTDANTER") 	FUNCTION SUM NO END REPORT
		DEFINE FUNCTION FROM oOcorren:Cell("PERC") 		FUNCTION SUM NO END REPORT
		
	DEFINE SECTION oTotFil OF oFilial TITLE STR0023 TABLES "DUA" TOTAL TEXT STR0023 TOTAL IN COLUMN

		DEFINE CELL NAME "DUA_CODOCO" OF oTotFil ALIAS "DUA" BLOCK { || (cAliasTot)->DUA_CODOCO }
		DEFINE CELL NAME "DT2_DESCRI" OF oTotFil ALIAS "DT2" TITLE STR0026
		DEFINE CELL NAME "QTDTOTAL"	OF oTotFil ALIAS "   " TITLE STR0018 	SIZE 3 BLOCK { || (cAliasTot)->MES+(cAliasTot)->ANT }
		DEFINE CELL NAME "QTDMES" 		OF oTotFil ALIAS "   " TITLE STR0019	SIZE 3 BLOCK { || (cAliasTot)->MES }
		DEFINE CELL NAME "QTDANTER" 	OF oTotFil ALIAS "   " TITLE STR0020	SIZE 3 BLOCK { || (cAliasTot)->ANT }
		DEFINE CELL NAME "PERC" 		OF oTotFil ALIAS "   " TITLE STR0021	SIZE 3 BLOCK { || Round((((cAliasTot)->MES+(cAliasTot)->ANT) / TMSR150Cnt()) * 100,2) }
		
Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo Riera          � Data �04.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport,cAliasQry,cAliasTot)

Local cSerTms   := StrZero(3,Len(DT2->DT2_SERTMS)) // Entrega
Local cFilOco   := ''
Local cIniRef   := StrZero(MV_PAR02,4) + StrZero(MV_PAR01,2)+ "01"
Local cFimRef   := StrZero(MV_PAR02,4) + StrZero(MV_PAR01,2)+ "31"
//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
//������������������������������������������������������������������������Ŀ
//�Query do relatorio da secao Ocorrencias                                 �
//��������������������������������������������������������������������������
BEGIN REPORT QUERY oReport:Section(1)

	BeginSql Alias cAliasQry

	SELECT DUA_FILIAL, DUA_FILOCO, DUA_CODOCO, DT2_DESCRI, SUM(MES) MES, SUM(ANT) ANT
	FROM (
	SELECT DUA_FILIAL, DUA_FILOCO, DUA_CODOCO, DT2_DESCRI, COUNT(*) MES, 0 ANT
	
	FROM  %table:DUA% DUA
	
	JOIN  %table:DT2% DT2
	ON DT2_FILIAL = %xFilial:DT2%
	AND DT2_CODOCO = DUA_CODOCO
	AND DT2.%NotDel%
	
	JOIN  %table:DT6% DT6
	ON DT6_FILIAL = %xFilial:DT6%
	AND DT6_DATEMI BETWEEN %Exp:cIniRef% AND %Exp:cFimRef%
	AND DT6_FILDOC = DUA_FILDOC
	AND DT6_DOC = DUA_DOC
	AND DT6_SERIE = DUA_SERIE
	AND DT6.%NotDel%
	
	WHERE DUA_FILIAL = %xFilial:DUA%
		AND DUA_FILOCO BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
		AND DUA_SERTMS = %Exp:cSerTms%
		AND DUA.%NotDel%

	GROUP BY DUA_FILIAL, DUA_FILOCO, DUA_CODOCO, DT2_DESCRI
	
	UNION ALL
	SELECT DUA_FILIAL, DUA_FILOCO, DUA_CODOCO, DT2_DESCRI, 0 MES, COUNT(*) ANT
	
	FROM  %table:DUA% DUA
	
	JOIN  %table:DT2% DT2
	ON DT2_FILIAL = %xFilial:DT2%
	AND DT2_CODOCO = DUA_CODOCO
	AND DT2.%NotDel%
	
	JOIN  %table:DT6% DT6
	ON DT6_FILIAL = %xFilial:DT6%
	AND DT6_DATEMI < %Exp:cIniRef%
	AND DT6_FILDOC = DUA_FILDOC
	AND DT6_DOC = DUA_DOC
	AND DT6_SERIE = DUA_SERIE
	AND DT6.%NotDel%
	
	WHERE DUA_FILIAL = %xFilial:DUA%
		AND DUA_FILOCO BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
		AND DUA_SERTMS = %Exp:cSerTms%
		AND DUA.%NotDel%
	
	GROUP BY DUA_FILIAL, DUA_FILOCO, DUA_CODOCO, DT2_DESCRI ) QUERY
	GROUP BY DUA_FILIAL, DUA_FILOCO, DUA_CODOCO, DT2_DESCRI
	ORDER BY DUA_FILIAL, DUA_FILOCO, DUA_CODOCO, DT2_DESCRI
	
	EndSql

END REPORT QUERY oReport:Section(1)

BEGIN REPORT QUERY oReport:Section(1):Section(2)

	BeginSql Alias cAliasTot

	%noparser%
	
	SELECT DUA_FILIAL, DUA_CODOCO, DT2_DESCRI, SUM(MES) MES, SUM(ANT) ANT
	FROM (
	SELECT DUA_FILIAL, DUA_FILOCO, DUA_CODOCO, DT2_DESCRI, COUNT(*) MES, 0 ANT
	
	FROM  %table:DUA% DUA
	
	JOIN  %table:DT2% DT2
	ON DT2_FILIAL = %xFilial:DT2%
	AND DT2_CODOCO = DUA_CODOCO
	AND DT2.%NotDel%
	
	JOIN  %table:DT6% DT6
	ON DT6_FILIAL = %xFilial:DT6%
	AND DT6_DATEMI BETWEEN %Exp:cIniRef% AND %Exp:cFimRef%
	AND DT6_FILDOC = DUA_FILDOC
	AND DT6_DOC = DUA_DOC
	AND DT6_SERIE = DUA_SERIE
	AND DT6.%NotDel%
	
	WHERE DUA_FILIAL = %xFilial:DUA%
		AND DUA_FILOCO BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
		AND DUA_SERTMS = %Exp:cSerTms%
		AND DUA.%NotDel%

	GROUP BY DUA_FILIAL, DUA_FILOCO, DUA_CODOCO, DT2_DESCRI
	
	UNION ALL
	SELECT DUA_FILIAL, DUA_FILOCO, DUA_CODOCO, DT2_DESCRI, 0 MES, COUNT(*) ANT
	
	FROM  %table:DUA% DUA
	
	JOIN  %table:DT2% DT2
	ON DT2_FILIAL = %xFilial:DT2%
	AND DT2_CODOCO = DUA_CODOCO
	AND DT2.%NotDel%
	
	JOIN  %table:DT6% DT6
	ON DT6_FILIAL = %xFilial:DT6%
	AND DT6_DATEMI < %Exp:cIniRef%
	AND DT6_FILDOC = DUA_FILDOC
	AND DT6_DOC = DUA_DOC
	AND DT6_SERIE = DUA_SERIE
	AND DT6.%NotDel%
	
	WHERE DUA_FILIAL = %xFilial:DUA%
		AND DUA_FILOCO BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
		AND DUA_SERTMS = %Exp:cSerTms%
		AND DUA.%NotDel%
	
	GROUP BY DUA_FILIAL, DUA_FILOCO, DUA_CODOCO, DT2_DESCRI ) QUERY
	GROUP BY DUA_FILIAL, DUA_CODOCO, DT2_DESCRI
	ORDER BY DUA_FILIAL, DUA_CODOCO, DT2_DESCRI	
	
	EndSql

END REPORT QUERY oReport:Section(1):Section(2)

oReport:Section(1):Section(1):SetParentQuery()

oReport:SetMeter(DUA->(LastRec()))

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
		cFilOco := (cAliasQry)->DUA_FILOCO
	
		oReport:Section(1):Init()
		oReport:Section(1):PrintLine()
		oReport:Section(1):Finish()
	
		oReport:Section(1):Section(1):Init()
		While !oReport:Cancel() .And. !(cAliasQry)->(Eof()) .And. (cAliasQry)->DUA_FILOCO == cFilOco
			oReport:Section(1):Section(1):PrintLine()
			dbSelectArea(cAliasQry)
			dbSkip()
		EndDo
		oReport:Section(1):Section(1):Finish()
	
	EndDo
	
	oReport:Skipline(1)
	oReport:PrintText(STR0027,oReport:Row(),10) //"Resumo Geral por Ocorrencia"
	oReport:PrintText("_____________________________",oReport:Row(),10)
	oReport:Skipline(1)
	
	oReport:Section(1):Section(2):Init()
	While !oReport:Cancel() .And. !(cAliasTot)->(Eof())
		oReport:Section(1):Section(2):PrintLine()
		dbSelectArea(cAliasTot)
		dbSkip()
	EndDo
	oReport:Section(1):Section(2):Finish()
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSR150Cnt� Autor �Rodolfo K. Rosseto     � Data �09/06/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Calculo das Quantidades por Filial e Total					     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Numerico                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 - Filial da Ocorrencia                                ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMSR150Cnt(cFilOco)

Local cSerTms      := StrZero(3,Len(DT2->DT2_SERTMS)) // Entrega
Local nQtdFil      := 0
Local cAliasTotFil := GetNextAlias()
Local cWhere       := ''
Local cGroup       := ''
Local cOrder       := ''
Local cFimRef      := StrZero(MV_PAR02,4) + StrZero(MV_PAR01,2)+ "31"

Default cFilOco    := ''

cWhere := "%"
If !Empty(cFilOco)
	cWhere += "AND DUA_FILOCO = '" + cFilOco + "' "
Else
	cWhere += "AND DUA_FILOCO BETWEEN '" +mv_par03+ "'  AND '" + mv_par04 + "' "
EndIf
cWhere += "%"

cGroup := "%"
If !Empty(cFilOco)
	cGroup += " DUA_FILIAL, DUA_FILOCO "
Else
	cGroup += " DUA_FILIAL "
EndIf
cGroup += "%"

cOrder := "%"
If !Empty(cFilOco)
	cOrder += " DUA_FILIAL, DUA_FILOCO "
Else
	cOrder += " DUA_FILIAL "
EndIf
cOrder += "%"

BeginSql Alias cAliasTotFil

	SELECT MIN(DUA_FILOCO), COUNT(*) TOTFIL

	FROM %table:DUA% DUA

	JOIN %table:DT2% DT2
	ON DT2_FILIAL  = %xFilial:DT2%
	AND DT2_CODOCO = DUA_CODOCO
	AND DT2.%NotDel%

	JOIN %table:DT6% DT6
	ON DT6_FILIAL  = %xFilial:DT6%
	AND DT6_DATEMI <= %Exp:cFimRef%
	AND DT6_FILDOC = DUA_FILDOC
	AND DT6_DOC    = DUA_DOC
	AND DT6_SERIE  = DUA_SERIE
	AND DT6.%NotDel%

	WHERE DUA_FILIAL  = %xFilial:DUA%
		AND DUA_SERTMS = %Exp:cSerTms%
		AND DUA.%NotDel%
		%Exp:cWhere%

	GROUP BY %Exp:cGroup%
	ORDER BY %Exp:cOrder%

EndSql

nQtdFil := (cAliasTotFil)->TOTFIL

Return nQtdFil