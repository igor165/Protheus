#Include 'Protheus.ch'
#Include 'FINR915.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} FINR915
Emiss�o do relat�rio de conferencia

@author Totvs
@since 19/01/2015	
@version 11.80
/*/

//-------------------------------------------------------------------
Function FINR915()

Local oReport		:= Nil
Local lTReport	:= TRepInUse()
Local lDefTop		:= IfDefTopCTB() // verificar se pode executar query (TOPCONN) 
Local lRet			:= .T.
Local cPerg		:= "FINR915"

If !lDefTop
	Help("  ",1,"FINR915TOP",,STR0001,1,0) //"Fun��o dispon�vel apenas para ambientes TopConnect"
	Return
EndIf

If !lTReport
	Help("  ",1,"FINR915R4",,,1,0) //"Fun��o dispon�vel apenas para TReport, por favor atualizar ambiente e verificar parametro MV_TREPORT"
	Return
EndIf

lRet := Pergunte( cPerg , .T. )

If lRet
	oReport := ReportDef(cPerg)
	oReport:PrintDialog()
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Defini��o de layout do relat�rio   

@author Totvs
@since 19/01/2015	
@version 11.80
/*/
//-------------------------------------------------------------------


Static Function ReportDef(cPerg)

Local oSection	:= Nil
Local oReport		:= Nil
Local oTotal		:= Nil
Local oBreak		:= Nil
Local cAliasFJP	:= GetNextAlias()
Local cReport		:= "FINR915"
Local cTitulo		:= STR0002//"Importa��o Minha Casa Minha Vida"
Local cDescri		:= STR0003 //"Relat�rio para apresentar os registros de importa��o para processamento do recebimento Minha Casa Minha Vida."

						//cReport	,cTitle		,uParam	,bAction											,cDescription	,lLandscape	,uTotalText	,lTotalInLine	,cPageTText	,lPageTInLine	,lTPageBreak	,nColSpace
oReport := TReport():New(cReport	,cTitulo	,cPerg	,{|oReport| PrintReport(oReport,cPerg,cAliasFJP)}	,cDescri		,.T.		,			,.F.			,			,				,				,			)

							//oParent	,cTitle		,uTable	,aOrder	,lLoadCells	,lLoadOrder	,uTotalText	,lTotalInLine	,lHeaderPage	,lHeaderBreak	,lPageBreak	,lLineBreak	,nLeftMargin	,lLineStyle	,nColSpace	,lAutoSize	,cCharSeparator	,nLinesBefore	,nCols	,nClrBack	,nClrFore	,nPercentage
oSection := TRSection():New( oReport	,	,"FJP"	,		,			,			,			,.F.			,				,				,			,			,				,			,			,			,				,				,		,			,			,			) //Participante

			//oParent	,cName			,cAlias	,cTitle	,cPicture	,nSize	,lPixel	,bBlock	,cAlign	,lLineBreak	,cHeaderAlign	,lCellBreak	,nColSpace	,lAutoSize	,nClrBack	,nClrFore	,lBold
TRCell():New( oSection	,"FJP_FILIAL"	,"FJP"	,		,			,		,		,		,		,		    ,				,			,			,	.T.	,			,			,		) //FILIAL
TRCell():New( oSection	,"FJP_CONTR"	,"FJP"	,		,			,		,		,		,		,	    	,				,			,			,	.T.	,			,			,		) //CONTRATO
TRCell():New( oSection	,"FJP_DTIMP"	,"FJP"	,		,			,		,		,		,		,	    	,				,			,			,	.T.	,			,			,		) //Data Importa��o
TRCell():New( oSection	,"FJP_DTPARC"	,"FJP"	,		,			,		,		,		,		,	    	,				,			,			,	.T.	,			,			,		) //Data Parcela
TRCell():New( oSection	,"FJP_VALOR"	,"FJP"	,		,			,		,		,		,		,	    	,				,			,			,	.T.	,			,			,		) //Valor
TRCell():New( oSection	,"FJP_SITUAC"	,"FJP"	,		,			,		,		,		,		,	    	,				,			,			,	.T.	,			,			,		) //Situa��o
TRCell():New( oSection	,"FJP_TITULO"	,"FJP"	,		,			,		,		,		,		,	    	,				,			,			,	.T.	,			,			,		) //Titulo


Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Rotina de Impress�o de dados      

@author Totvs
@since 19/01/2015	
@version 11.80
/*/
//-------------------------------------------------------------------


Static Function PrintReport(oReport,cPerg,cAliasFJP)
Local oSection		:= oReport:Section(1)
Local cWhere		:= ""

If MV_PAR05 == 2 //Aguardando processamento
	cWhere += "AND FJP.FJP_SITUAC = '1' "
ElseIf MV_PAR05 == 3 //Processados
	cWhere += "AND FJP.FJP_SITUAC = '2' "
ElseIf MV_PAR05 == 4 //Falha de processamento
	cWhere += "AND FJP.FJP_SITUAC = '3' "
EndIf
cWhere := "%" + cWhere + "%"

MakeSqlExp(cPerg)

BEGIN REPORT QUERY oSection

BeginSql alias cAliasFJP
	SELECT
		FJP_FILIAL,
		FJP_CONTR,
		FJP_DTIMP,
		FJP_DTPARC,
		FJP_VALOR,
		FJP_SITUAC,
		FJP_TITULO

	FROM
		%table:FJP% FJP

	WHERE
		FJP.FJP_FILIAL	BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
		AND FJP.FJP_DTPARC	BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04%
		AND FJP.%notDel%
		%exp:cWhere%
	ORDER BY
		FJP_DTPARC
EndSql

END REPORT QUERY oSection

oSection:Print()

Return 
