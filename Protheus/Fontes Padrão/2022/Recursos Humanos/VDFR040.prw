#include "VDFR040.CH"
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "report.ch"

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Funcao    � VDFR040  � Autor � Totvs                      � Data � 12/12/2012 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o �Relatorio de periodo de afastamento                                ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                          ���
��������������������������������������������������������������������������������Ĵ��
���              ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               �����������
����������������������������������������������������������������������������������������Ŀ��
���Programador   � Data   � PRJ/REQ-Chamado �  Motivo da Alteracao                       ���
����������������������������������������������������������������������������������������Ĵ��
���              �        �                 �                                            ���
��������������������������������������������������������������������������������������������
*/
Function VDFR040(oModel)
Local nL  		:= 0
Local oReport
Local oStruRH4:= oModel:GetModel( 'TCFA040_RH4' )
Private cAliQry   := GetNextAlias()
Private cFilSRA
Private cMatSra
Private cDataIni
Private cDataFim
Private cPeriodo


For nL := 1 to oStruRH4:Length()
	If Alltrim(oModel:GetValue('TCFA040_RH4','RH4_CAMPO',nL)) == 'RA_FILIAL'
		cFilSRA := Alltrim(oModel:GetValue('TCFA040_RH4','RH4_VALNOV',nL))
	ElseIf Alltrim(oModel:GetValue('TCFA040_RH4','RH4_CAMPO',nL)) == 'RA_MAT'
		cMatSra := Alltrim(oModel:GetValue('TCFA040_RH4','RH4_VALNOV',nL))
	ElSeIf Alltrim(oModel:GetValue('TCFA040_RH4','RH4_CAMPO',nL)) == 'TMP_DTINI'
		cDataIni:=	dtOS(ctoD(Alltrim(oModel:GetValue('TCFA040_RH4','RH4_VALNOV',nL))))
	ElSeIf Alltrim(oModel:GetValue('TCFA040_RH4','RH4_CAMPO',nL)) == 'TMP_DTFIM'
		cDataFim:= dtOS(ctoD(Alltrim(oModel:GetValue('TCFA040_RH4','RH4_VALNOV',nL))))
	EndIf	
Next

cPeriodo:= " De: "+dToC(StOD(cDataIni))+" At�: "+dToC(STOD(cDataFim))
oReport := ReportDef(/*cPerg*/)
oReport:PrintDialog()


Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportDef  � Autor � Everson S P Junior    � Data �12/12/2013���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de periodo de afastamento    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ReportDef()
Local oReport
Local cTitulo := STR0001//'Relatorio de periodo de afastamento'
Local aOrd    := {STR0002}//'Centro de Custo'//'Departamento'//'Matricula'//'Nome'//'Data Inicio'
Local cPerg   := '' 
Local cString := 'SRA'
Local oSection1
Local oSection2 
Local cDesc1	:= STR0008	//"Matricula"


//������������������������������������������������������������������������Ŀ
//�Criacao dos componentes de impressao                                    �
//��������������������������������������������������������������������������
DEFINE REPORT oReport NAME STR0009 TITLE cTitulo  ACTION {|oReport| ReportPrint(oReport)} DESCRIPTION STR0003 TOTAL IN COLUMN//'Relatorio de periodo de afastamento'
	
	DEFINE SECTION oSection1 OF oReport TITLE STR0009 TABLES "SRA" TOTAL IN COLUMN ORDERS aOrd
	   	DEFINE CELL NAME "RA_MAT" 	 	  OF oSection1 ALIAS cString
		DEFINE CELL NAME "RA_NOME" 	 	  OF oSection1 ALIAS cString
		DEFINE CELL NAME STR0004	  	  OF oSection1 TITLE STR0004 SIZE 50 BLOCK {||cPeriodo}//STR0005//"Per�odo"
	
	DEFINE SECTION  oSection2 OF oSection1 TITLE STR0006 TABLES "SR8" TOTAL IN COLUMN ORDERS aOrd	   	//'Afastamento'
	   	
	   	DEFINE CELL NAME "R8_DATAINI"  		OF oSection2 ALIAS cString
		DEFINE CELL NAME "R8_DATAFIM" 		OF oSection2 ALIAS cString
	   	DEFINE CELL NAME "R8_DURACAO"     	OF oSection2 ALIAS cString
	   	DEFINE CELL NAME STR0007     		OF oSection2 TITLE STR0007 SIZE 30 BLOCK {||POSICIONE("RCM",1,XFILIAL("RCM")+(cAliQry)->R8_TIPOAFA,"RCM_DESCRI")}//STR0008//"Motivo"
	   	
	   	DEFINE FUNCTION FROM oSection1:Cell("RA_MAT")		FUNCTION COUNT NO END SECTION 
   		oSection1:SETLINESTYLE(.T.) // Deixa o titulo do campo ao lado exemplo Matricula: 00017
Return(oReport)
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    �
���������������������������������������������������������������������������Ĵ��
���Descri�ao �     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                            ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/

Static Function ReportPrint(oReport)
Local cOrdem    := ''

//Cria��o da oSection para impress�o, conforme c�lulas definidas no RepordDef
Private oSection 	:= oReport:Section(1)    
Private oSection2	:= oReport:Section(1):Section(1)
Private aRet        := {}
Private nOrdem	    := oSection:GetOrder()


//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
//MakeSqlExpr(cPerg)
//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������

//Associa a query � section que voc� vai imprimir
oSection:BeginQuery()

cOrdem := "%SR8.R8_DATAINI,SR8.R8_DATAFIM%"

BeginSql alias cAliQry
	
	COLUMN R8_DATAFIM AS DATE
	COLUMN R8_DATA AS DATE                             
	COLUMN R8_DATAINI AS DATE

	SELECT R8_DATAINI,R8_DATAFIM,R8_TIPOAFA,R8_DURACAO
	FROM  %table:SRA%  SRA
	INNER JOIN %table:SR8%  SR8 ON
	SR8.R8_FILIAL = SRA.RA_FILIAL
	AND SR8.R8_MAT = SRA.RA_MAT

	WHERE 
	SRA.RA_FILIAL = %exp:cFilSRA%
	AND SRA.RA_MAT = %exp:cMatSRA%
	AND SRA.%NotDel%	
	AND(  ( ( R8_DATAINI >= %exp:cDataIni% AND R8_DATAINI <= %exp:cDataFim% ) OR (%exp:cDataIni%   >= R8_DATAINI AND %exp:cDataFim% <= R8_DATAFIM) )
	OR ( ( R8_DATAFIM >= %exp:cDataIni%  AND R8_DATAFIM <= %exp:cDataFim% ) OR (%exp:cDataIni%  >= R8_DATAINI AND %exp:cDataFim%<= R8_DATAFIM) ) )
		
	ORDER BY %Exp:cOrdem%

EndSql
//END REPORT QUERY oSection PARAM mv_par01, mv_par02, mv_par03, mv_par04, mv_par05
oSection:EndQuery()

oSection2:SETPARENTQUERY()// diz que a query do pai pertece ao filho dependecia.
//oSection:SetLineCondition({||aRet:=FDIAS((cAliQry)->RA_MAT),.T.})//Fun��o Inicia o Modelo de dados Para cada RA_MAT.

oReport:SetMeter((cAliQry)->(LastRec()))

oReport:Section(1):Print(.T.,cAliQry)

oReport:Section(1):Finish()	

oReport:Section(1):SetPageBreak(.T.) 

Return


