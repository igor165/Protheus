#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "GCPR001.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GCPR001 �Autor  � Totvs              � Data �  01/04/10   ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio de Posicao do Edital                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GCP - Gest�o de Compras Publicas                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GCPR001()

Local   oReport		:= nil
Private cTitulo		:= STR0001 //"Posicao do Edital"
Private cPerg		:= "GCR001"   
Private cAliasQry 	:= GetNextAlias()

If TRepInUse()
	oReport:= ReportDef()
	oReport:PrintDialog()  // Imprime o Relat�rio
Else
	Alert(STR0002) //"Este relat�rio s� est� dispon�vel a partir da Release 4." 
EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportDef�Autor  � Totvs              � Data �  01/04/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Carrega as defini�oes do relatorio                         ���
�������������������������������������������������������������������������͹��
���Uso       � GCP - Gest�o de Compras Publicas                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport  	:= nil
Local oCO1 	   	:= nil
Local cDesc		:= ""
Local oBreak	:= nil 

cDesc += STR0003 //"Este programa tem como objetivo imprimir a  "
cDesc += STR0004 //"listagem dos editais e sua posi��o atual "

DEFINE REPORT oReport NAME "GCPR001" TITLE cTitulo PARAMETER cPerg ACTION {|oReport|RepGCP(oReport)} DESCRIPTION cDesc 
		DEFINE SECTION oCO1 			OF oReport TITLE STR0005 TABLES "CO1"  //"Licita��o"  
		DEFINE CELL NAME "CO1_CODEDT"  	OF oCO1 ALIAS "CO1"
		DEFINE CELL NAME "CO1_NUMPRO"   OF oCO1 ALIAS "CO1"
		DEFINE CELL NAME "CO1_DTABER" 	OF oCO1 ALIAS "CO1" 
		DEFINE CELL NAME "CO1_DTPUBL" 	OF oCO1 ALIAS "CO1" 
		DEFINE CELL NAME "ETAPA"		OF oCO1 BLOCK {|| GCPR01ETP() } SIZE 25 TITLE STR0006 LINE BREAK AUTO SIZE //"Etapa" 
		oCO1:SetAutoSize()		
Return oReport

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GCPR01ETP �Autor  � Totvs              � Data �  01/04/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a etapa do Edital                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GCP - Gest�o de Compras Publicas                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GCPR01ETP()
Local aArea := GetArea()
Local cRet	:= ""

dbSelectArea("SX5")
dbSetOrder(1)
If MsSeek(xFilial()+"LE"+(cAliasQry)->CO1_ETAPA)
	cRet := (cAliasQry)->CO1_ETAPA + " - " + AllTrim(X5Descri())
EndIf

RestArea( aArea )
Return cRet 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RepGCP  �Autor  � Totvs              � Data �  01/04/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Carrega as defini�oes as informa��es do relatorio          ���
�������������������������������������������������������������������������͹��
���Uso       � GCP - Gest�o de Compras Publicas                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RepGCP(oReport)
Local oCO1 		:= oReport:Section(1)

Pergunte(cPerg,.F.)

BEGIN REPORT QUERY oCO1

BeginSql alias cAliasQry

SELECT 
	CO1_CODEDT,
	CO1_NUMPRO,
	CO1_ETAPA
FROM 
	%table:CO1% CO1 
WHERE 
	CO1_CODEDT >= %EXP:MV_PAR01%	AND
	CO1_NUMPRO >= %EXP:MV_PAR02%	AND
	CO1_CODEDT <= %EXP:MV_PAR03%	AND
	CO1_NUMPRO <= %EXP:MV_PAR04%	AND
	CO1_DTABER >= %EXP:MV_PAR05%	AND
	CO1_DTABER <= %EXP:MV_PAR06%	AND
	CO1_FILIAL	= %xfilial:CO1%	AND
	CO1.%NotDel%
					
ORDER BY CO1_CODEDT

EndSql

END REPORT QUERY oCO1

oCO1:Print() 
	
Return