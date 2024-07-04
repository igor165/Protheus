#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FINR786.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FINR786
Função do relatório de relação de borderôs de pagamento pendentes de aprovação.

@author Marylly Araújo Silva
@since 01/07/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------

Function FINR786()

Local oReport	:= Nil
Local lTReport	:= TRepInUse()
Local lSelFil	:= .F.
Local aSM0Fils	:= AdmAbreSM0()
Local lRet		:= .T.
Local cPerg		:= "FINR786"
Local aSelFil	:= {}

If !lTReport
	Help("  ",1,"FINR786R4",,STR0001,1,0) //"Função disponível apenas para TReport, por favor atualizar ambiente e verificar parametro MV_TREPORT"
	Return
EndIf

lRet	:= Pergunte( cPerg , .T. )
lSelFil	:= (MV_PAR04 == 1)

If lRet
	If lSelFil .And. Len( aSelFil ) <= 0
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			Return
		EndIf
	EndIf

	oReport:= ReportDef(aSelFil,cPerg)
	oReport:PrintDialog()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Função de definição do layout e formato do relatório

@param aSelFil	Array com as informações da filiais selecionadas para emissão do relatório
@return oReport	Objeto criado com o formato do relatório
@author Marylly Araújo Silva
@since 01/07/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------

Static Function ReportDef(aSelFil,cPerg)

Local oReport		:= nil
Local oBordero		:= nil
Local cDesc			:= STR0002 //"Este relatório tem o objetivo de relacionar os borderôs de pagamento em processo de aprovação."
Local cTitulo		:= STR0003 // "Relatório de Aprovação de Borderôs de Pagamento"
Local cAlsBor 		:= GetNextAlias()
Local lSelFil		:= (MV_PAR04 == 1)

/*
 * Chamada do pergunte com os parâmetros para definir o comportamento e filtros
 * do relatório
 */
Pergunte(cPerg,.F.)

/*
 * Definição padrão do relatório TReport
 */
DEFINE REPORT oReport NAME "FINR786" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| PrintReport(oReport,cPerg,aSelFil,cAlsBor)} DESCRIPTION cDesc

/*
 * Seção dos dados principais do relatório
 */
DEFINE SECTION oBordero OF oReport TITLE STR0003 TABLES (cAlsBor)  //"Relação de Borderôs de Pagamento Pendentes de Aprovação"
	TRCell():New( oBordero, "FRY_FILIAL"	, "FRY", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,{|| (cAlsBor)->FRY_FILIAL }		,/*nALign*/ "LEFT"	,/*lLineBreak*/,/*cHeaderAlign*/"LEFT"	,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/.F. )
	TRCell():New( oBordero, "FRY_BORDER"	, "FRY", /*X3Titulo*/, /*Picture*/, /*Tamanho*/10,/*lPixel*/,{|| (cAlsBor)->FRY_BORDER }		,/*nALign*/ "LEFT"	,/*lLineBreak*/,/*cHeaderAlign*/"LEFT"	,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/.F. )
	TRCell():New( oBordero, "FRY_VERSAO"	, "FRY", /*X3Titulo*/, /*Picture*/, /*Tamanho*/5,/*lPixel*/,{|| (cAlsBor)->FRY_VERSAO }		,/*nALign*/ "LEFT"	,/*lLineBreak*/,/*cHeaderAlign*/"LEFT"	,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/.F. )
	TRCell():New( oBordero, "FRY_TOTAL"		, "FRY", /*X3Titulo*/, /*Picture*/, /*Tamanho*/10,/*lPixel*/.T.,{|| (cAlsBor)->FRY_TOTAL }		,/*nALign*/ "RIGHT"	,/*lLineBreak*/,/*cHeaderAlign*/"RIGHT"	,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/.F. )
	TRCell():New( oBordero, "FRY_TIPOPG"	, "FRY", /*X3Titulo*/, /*Picture*/, /*Tamanho*/40,/*lPixel*/,{|| (cAlsBor)->FRY_TIPOPG + " - " + AllTrim((cAlsBor)->X5_DESCRI) }		,/*nALign*/ "LEFT"	,/*lLineBreak*/,/*cHeaderAlign*/"LEFT"	,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/.F. )
	TRCell():New( oBordero, "FRY_DATA"		, "FRY", /*X3Titulo*/, /*Picture*/, /*Tamanho*/10,/*lPixel*/,{|| (cAlsBor)->FRY_DATA }		,/*nALign*/ "LEFT"	,/*lLineBreak*/,/*cHeaderAlign*/"LEFT"	,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/.F. )
	TRCell():New( oBordero, "FWK_CODAPR"	, "FWK", /*X3Titulo*/, /*Picture*/, /*Tamanho*/40,/*lPixel*/,{|| (cAlsBor)->FWK_CODAPR + " - " + AllTrim(UsrFullName((cAlsBor)->FWK_CODAPR))}		,/*nALign*/ "LEFT"	,/*lLineBreak*/,/*cHeaderAlign*/"LEFT"	,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/.F. )
	TRCell():New( oBordero, "FWK_PAPEL"		, "FWK", /*X3Titulo*/, /*Picture*/, /*Tamanho*/40,/*lPixel*/,{|| (cAlsBor)->FWK_PAPEL + " - " + AllTrim((cAlsBor)->FRW_DESCR) }		,/*nALign*/ "LEFT"	,/*lLineBreak*/,/*cHeaderAlign*/"LEFT"	,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/.F. )
	TRCell():New( oBordero, "FWL_MOVIME"	, "FWL", /*X3Titulo*/, /*Picture*/, /*Tamanho*/5,/*lPixel*/.T.,{|| AFR786St((cAlsBor)->FWL_MOVIME) }		,/*nALign*/ "LEFT"	,/*lLineBreak*/,/*cHeaderAlign*/"LEFT"	,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/.F. )
	TRCell():New( oBordero, "FWL_HISTOR"	, "FWL", /*X3Titulo*/, /*Picture*/, /*Tamanho*/80,/*lPixel*/.T.,{|| AFR786GMM((cAlsBor)->FWL_RECNO) }		,/*nALign*/ "LEFT"	,/*lLineBreak*/,/*cHeaderAlign*/"LEFT"	,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/.F. )

oBordero:SetAutoSize()

oReport:SetLandScape()
oReport:DisableOrientation()

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Função para busca das informações que serão impressas no relatório

@param oReport	Objeto para manipulação das seções, atributos e dados do relatório.
@param cPerg	Identificação do Grupo de Perguntas do relatório
@param aSelFil	Array com as informações de todas as filiais do sistema.
@return void
@author Marylly Araújo Silva
@since 01/07/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------

Static Function PrintReport(oReport,cPerg,aSelFil,cAlsBor)

Local oBordero		:= oReport:Section(1)
Local cConsTodos	:= ""
Local cBordIni		:= ""
Local cBordFim		:= ""
Local lSelFil		:= .F.
Local cTmpFil		:= ""
Local cCondFil		:= ""
Local cCondSta		:= "% 1 = 1 %"

/*
 * Chamada do pergunte com os parâmetros para definir o comportamento e filtros
 * do relatório
 */
Pergunte( cPerg , .F. )

cBordIni	:= MV_PAR01
cBordFim	:= MV_PAR02
cConsTodos	:= MV_PAR03
lSelFil		:= (MV_PAR04 == 1)

/*
 * Tratamento do Filtro de Filiais de acordo com Pergunte "Seleciona Filial ?"
 */
If lSelFil
	cCondFil 	:= "% FRY.FRY_FILIAL " + GetRngFil( aSelfil , "FRY", .T., @cTmpFil ) + " %"
Else
	cCondFil 	:= "% FRY.FRY_FILIAL = '" + FWXFILIAL("FRY") + "' %"
EndIf

If cConsTodos == 2
	cCondSta := "% FWL.FWL_MOVIME = '1' %"
ElseIf cConsTodos == 3
	cCondSta := "% FWL.FWL_MOVIME = '2' %"
EndIf 	

/*
 * Seção de Borderôs (Borderô)
 */
BEGIN REPORT QUERY oBordero

BeginSql alias cAlsBor

SELECT
	FRY.FRY_BORDER
	,FRY.FRY_PROAPR
	,FRY.FRY_TOTAL
	,FRY.FRY_STATUS
	,FRY.FRY_VERSAO
	,FRW.FRW_DESCR
	,FWK.FWK_PAPEL
	,FWK.FWK_CODAPR
	,FRY.FRY_TIPOPG
	,FRY.FRY_DATA
	,FWL.FWL_MOVIME
	,FRY.FRY_FILIAL
	,SX5.X5_DESCRI
	,FWL.R_E_C_N_O_ FWL_RECNO
FROM
	%table:FRY% FRY
INNER JOIN %table:FWJ% FWJ ON
	FWJ.FWJ_FILIAL = %xfilial:FWJ% AND
	FWJ.FWJ_CODIGO = FRY.FRY_PROAPR 
INNER JOIN %table:FWK% FWK ON
	FWK.FWK_FILIAL = %xfilial:FWK% AND
	FWK.FWK_CODIGO = FWJ.FWJ_CODIGO
INNER JOIN %table:FRW% FRW ON
	FRW.FRW_FILIAL = %xfilial:FRW% AND
	FWK.FWK_PAPEL  = FRW.FRW_CODIGO
INNER JOIN %table:FWL% FWL ON
	FWL.FWL_FILIAL = %xfilial:FWL% AND
	FWL.FWL_PROAPR = FRY.FRY_PROAPR AND
	FWL.FWL_BORDER = FRY.FRY_BORDER AND
	FWL.FWL_VERSAO = FRY.FRY_VERSAO
INNER JOIN %table:SX5% SX5 ON
	SX5.X5_FILIAL = %xfilial:SX5% AND
	SX5.X5_TABELA = '59' AND
	SX5.X5_CHAVE = FRY.FRY_TIPOPG
WHERE
	%exp:cCondSta%	AND
	%exp:cCondFil%	AND
	FRY.FRY_RECPAG 	= 'P' AND
	FRY.FRY_SITBRD = '1' AND
	FRY.FRY_BORDER BETWEEN %exp:cBordIni% AND %exp:cBordFim%
ORDER BY
	FRY.FRY_FILIAL, FRY.FRY_BORDER

EndSql

END REPORT QUERY oBordero

CtbTmpErase(cTmpFil)
oBordero:Print()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AFR786St

Função que retorna a descrição do Status do movimento de aprovação grid de Borderô de Pagamentos

@author Marylly Araújo Silva
@since 01/07/2015
@version 12.1.6
@param cStatus Situação do Borderô de Pagamento
@return cDesc Descrição Status do Movimento de Aprovação
/*/
//-------------------------------------------------------------------

Function AFR786St(cStatus)
Local cDesc		:= ""

DEFAULT cStatus := ""

If cStatus == "1" 
	cDesc := STR0004 //"Aprovado" 
ElseIf cStatus == "2"
	cDesc := STR0005 //"Reprovado"
EndIf
	
Return cDesc


//-------------------------------------------------------------------
/*/{Protheus.doc} AFR786GMM

Função que retorna o conteúdo do campo de histórico do movimento de aprovação grid de Borderô de Pagamentos

@author Marylly Araújo Silva
@since 02/07/2015
@version 12.1.6
@param nRec Recno do registro do movimento de aprovação
@return cDesc Conteúdo do campo de histórico do movimento de aprovação
/*/
//-------------------------------------------------------------------

Function AFR786GMM(nRec)
Local cDesc		:= ""
Local aFWLArea	:= FWL->(GetArea())

DEFAULT nRec := 0

FWL->(DbGoTo(nRec))
cDesc := FWL->FWL_HISTOR

RestArea(aFWLArea)	
Return cDesc		