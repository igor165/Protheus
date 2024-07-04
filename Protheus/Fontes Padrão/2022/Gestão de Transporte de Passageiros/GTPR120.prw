#Include "GTPR120.ch"
#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.ch"

 //-------------------------------------------------------------------
/*/{Protheus.doc} GTPR120()
Relatório Controle-Pendência de Documentos

@sample GTPR120()

@author	gustavo.silva2
@since	18/02/2019
@version	P12
/*/
//-------------------------------------------------------------------

Function GTPR120()

Local oReport
Local cPerg  := 'GTPR120'
	
Pergunte(cPerg, .T.)
	
oReport := ReportDef(cPerg)
oReport:PrintDialog()

Return

Static Function ReportDef(cPerg)

Local cTitle   	:= STR0001  //"Consulta Pendência Formulário de Passagens"
Local cHelp    	:= STR0002  //"Gera Relatório de Documentos não utilizados"
Local cAliasFix	:= GetNextAlias()
Local oSecBilhetes
Local oSecAge
Local oReport

oReport := TReport():New('GTPR120',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasFix)},cHelp,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,.F./*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
oReport:SetPortrait(.T.)
oReport:nFontBody := 5
oReport:SetTotalInLine(.F.)

oSecAge := TRSection():New(oReport, cTitle, cAliasFix)
oSecAge:SetTotalInLine(.F.)

TRCell():New(oSecAge,	"AGENCIA",  ,STR0003 , /*Picture*/, 60/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,/*cAlign*/,.F./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.T.)  //"Agencia"
oSecAge:SetHeaderSection(.F.)

oSecAge:Cell("AGENCIA"):SetBorder("ALL",0,0,.T.)
oSecAge:Cell("AGENCIA")	:SetHeaderAlign("CENTER")

oSecBilhetes := TRSection():New(oReport, cTitle, cAliasFix)
oSecBilhetes:SetTotalInLine(.F.)

TRCell():New(oSecBilhetes,	"MIN", 	    ,STR0004 , "@!"				, 50/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	  //'Nº Inicial'
TRCell():New(oSecBilhetes,	"MAX",	    ,STR0005 , "@!"				, 50/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) //'Nº Final'
TRCell():New(oSecBilhetes, 	"SERIE", 	,STR0006 , "@!"				, 30/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	  //'Série'
TRCell():New(oSecBilhetes, 	"SUBSERIE", ,STR0007 , "@!"				, 40/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	  //'Subsérie'
TRCell():New(oSecBilhetes, 	"NUMCOM", 	,STR0008 , "@!"				, 40/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	  //'Num.Comp'
TRCell():New(oSecBilhetes,	"DATAREM", 	,STR0009 , "@!"				, 60/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)   //'Data Remessa'
TRCell():New(oSecBilhetes,	"TIPO", 	,STR0010 , "@!"	, 60/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,'03'/*cAlign*/,/*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) //'Tipo Doc'
TRCell():New(oSecBilhetes,	"SUBTOTAL", ,STR0011 , 	, 35/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,'03'/*cAlign*/,/*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) //'Tot.Documentos'

oSecBilhetes:SetHeaderSection( .T.)

oBreak:= TRBreak():New(oSecBilhetes,{||("AGENCIA")},,.T.)
oBreak:SetPageBreak(.F.)
oBreak:SetTotalInLine(.F.)
oBreak:SetTitle(STR0012)//"Total de Documentos não utilizados: "
oBreak:SetBorder("BOTTOM",0,0,.T.)

TRFunction():New(oSecBilhetes:Cell('SUBTOTAL'),     , 'SUM'   ,oBreak ,,        ,        ,.F.        ,.T.       ,.T.     ,oSecBilhetes,          ,        ,         )

Return oReport

/*/{Protheus.doc} ReportPrint
Processamento dos dados
@type function
@author gustavo.silva2
@since 18/02/2019
@version 1.0
@param oReport, objeto, (Descrição do parâmetro)
@param cAliasFix, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportPrint(oReport,cAliasFix)
Local cAliasTmp		:= GetNextAlias()
Local nCount 		:= 0
Local aBilhet		:= {}
Local cMin			:= ""
Local cMax			:= ""
Local nMin			:= 0
Local nMax			:= 0
Local cSerie		:= ""
Local cSubser		:= ""
Local cNumCom		:= ""
Local cNumini		:= ""
Local cNumfim		:= ""
Local cAgencia		:= ""
Local cCodeAge		:= ""
Local nSubtotal		:= 0
Local oSecAge		:= oReport:Section(1)
Local oSecBilhetes	:= oReport:Section(2)
Local cFiltro		:= ""
Local cAgeDe		:= Alltrim(mv_par01)
Local cAgeAte		:= Alltrim(mv_par02)
Local cSerieDe		:= Alltrim(mv_par03)
Local cSerieAte		:= Alltrim(mv_par04)
Local cTipo			:= Alltrim(mv_par05)
Local cDataDe		:= DTOS(mv_par06)
Local cDataAte		:= DTOS(mv_par07)


If !Empty(mv_par01) .OR. !Empty(mv_par02)
	cFiltro += "AND GQG_AGENCI BETWEEN '"+cAgeDe+"' AND '" + cAgeAte + "' "
EndIf

If !Empty(mv_par03) .OR. !Empty(mv_par04)
	cFiltro += "AND GQG_SERIE BETWEEN '"+cSerieDe+"' AND '" + cSerieAte + "' "
EndIf

If !Empty(mv_par05)
	cFiltro += "AND GQG_TIPO = '"+cTipo+"'
EndIf

If !Empty(mv_par06) .OR. !Empty(mv_par07)
	cFiltro += "AND GQG_DTREM BETWEEN '"+cDataDe+"' AND '" + cDataAte + "' "
EndIf

	 		
	cFiltro:="%"+cFiltro+"%"
	//Query Fixa que recupera registros dos lotes de documentos das agências
	BeginSQL Alias cAliasFix
	
	SELECT GQG_AGENCI 				AS AGENCIA,
	 	   GQG_NUMINI			    AS NUMINI,
	 	   GQG_NUMFIM 				AS NUMFIM,
	 	   GQG_SERIE 				AS SERIE,
	 	   GQG_SUBSER 				AS SUBSERIE,
	 	   GQG_NUMCOM 				AS NUMCOM,
	 	   GQG_TIPO 				AS TIPO,
	 	   GQG_DTREM                AS DATAREM,
	 	   MIN(GII_BILHET) 			AS MINNUMINI,
	 	   MAX(GII_BILHET) 			AS MAXNUMFIM,
	 	   GI6_DESCRI			    AS DESCRI,
	 	   GYA_DESCRI               AS TIPODESCRI 
	FROM %Table:GQG% GQG
	
	INNER JOIN %table:GII% GII ON
	  	GII_FILIAL = GQG_FILIAL
		AND GII_AGENCI = GQG_AGENCI
		AND GII_SERIE = GQG_SERIE  
		AND GII_SUBSER = GQG_SUBSER 
		AND GII_NUMCOM = GQG_NUMCOM
		
	INNER JOIN %table:GI6% GI6 ON
		GI6_FILIAL = GQG_FILIAL
		AND GI6_CODIGO = GQG_AGENCI
		
	INNER JOIN %table:GYA% GYA ON
		 GYA_CODIGO = GQG_TIPO
		
	WHERE GQG_FILIAL=%xfilial:GQG% 
		AND GQG.%notDel%
		AND GII.%notDel%
		AND GI6.%notDel%
		AND GYA.%notDel%
		AND GII_UTILIZ = 'F'
		AND GII_BILHET Between GQG_NUMINI AND GQG_NUMFIM
		%exp:cFiltro%
		
		GROUP BY GQG_AGENCI, GQG_SERIE, GQG_SUBSER, GQG_NUMCOM, GQG_NUMINI,GQG_TIPO,GQG_DTREM, GQG_NUMFIM, GII_UTILIZ, GI6_DESCRI, GYA_DESCRI
		
		ORDER BY GQG_AGENCI, GQG_SERIE, GQG_SUBSER, GQG_NUMCOM
	
	EndSQL 

	oReport:SetMeter((cAliasFix)->(RecCount()))
		
If (cAliasFix)->(!Eof())
	oReport:StartPage()	
	oSecAge:Init()
	oSecAge:Cell("AGENCIA"):SetValue((cAliasFix)->AGENCIA + " - " + (cAliasFix)->DESCRI )
	oSecAge:PrintLine()
	
	cCodeAge:= (cAliasFix)->AGENCIA
	
	While !oReport:Cancel() .AND. (cAliasFix)->(!Eof())
	
		If cCodeAge != (cAliasFix)->AGENCIA
			oSecBilhetes:Finish()
			oReport:SkipLine()
			oSecAge:Cell("AGENCIA"):SetValue((cAliasFix)->AGENCIA + " - " + (cAliasFix)->DESCRI )
			oSecAge:PrintLine()
			cCodeAge:= (cAliasFix)->AGENCIA
		EndIf
		
		cAgencia  := (cAliasFix)->(AGENCIA)
		cSerie    := (cAliasFix)->(SERIE)
		cSubser   := (cAliasFix)->(SUBSERIE)
		cNumCom   := (cAliasFix)->(NUMCOM)
		cNumini   := (cAliasFix)->(MINNUMINI)
		cNumfim   := (cAliasFix)->(MAXNUMFIM)
		
		//Query Temporária que percorre cada bilhete definido no range dos lotes da query fixa					
		Beginsql alias cAliasTmp
		
		SELECT GII.GII_AGENCI, 
			   GII.GII_BILHET, 
			   GII.GII_UTILIZ 
		FROM %table:GII% GII
		
		WHERE GII.GII_FILIAL=%xfilial:GII% 
			AND GII.%notDel%
			AND GII.GII_AGENCI = %exp:cAgencia%
			AND GII.GII_SERIE = %exp:cSerie%
			AND GII.GII_SUBSER = %exp:cSubser%
			AND GII.GII_NUMCOM = %exp:cNumCom%
			AND GII.GII_BILHET Between %exp:cNumini% AND %exp:cNumfim%
		ORDER BY GII_BILHET	
		
		EndSQL
		(cAliasTmp)->(dbGotop())
	
		While (cAliasTmp)->(!EOF())
			If (cAliasTmp)->(GII_UTILIZ) == "F" .AND. nCount == 0
				Aadd(aBilhet,(cAliasTmp)->GII_BILHET)
			
			ElseIf (cAliasTmp)->(GII_UTILIZ)=='T'
				nCount++
			
			ElseIf (cAliasTmp)->(GII_UTILIZ)=='F' .AND. nCount<>0 .AND. Len(aBilhet)>=1
				cMin:= aBilhet[1]
				nMin:= Val(cMin)
				cMax:= aBilhet[Len(aBilhet)]
				nMax:= Val(cMax)
				nSubtotal:= nMax - nMin + 1
				oSecBilhetes:Cell("SERIE"):SetValue((cAliasFix)->SERIE)
				oSecBilhetes:Cell("SUBSERIE"):SetValue((cAliasFix)->SUBSERIE)
				oSecBilhetes:Cell("NUMCOM"):SetValue((cAliasFix)->NUMCOM)
				oSecBilhetes:Cell("DATAREM"):SetValue(STOD((cAliasFix)->DATAREM))
				oSecBilhetes:Cell("TIPO"):SetValue((cAliasFix)->TIPO + " - " + (cAliasFix)->TIPODESCRI)
				oSecBilhetes:Cell("MIN"):SetValue(cMin)
				oSecBilhetes:Cell("MAX"):SetValue(cMax)
				oSecBilhetes:Cell("SUBTOTAL"):SetValue(nSubtotal)
				
				oSecBilhetes:Init()
				oSecBilhetes:PrintLine()
				aBilhet:= {}
				nCount:= 0
				Aadd(aBilhet,(cAliasTmp)->GII_BILHET)
			
			EndIf
		
			(cAliasTmp)->(DbSkip())
		End
		
		If Len(aBilhet)>=1	
			cMin:= aBilhet[1]
			nMin:= Val(cMin)
			cMax:= aBilhet[Len(aBilhet)]
			nMax:= Val(cMax)
			nSubtotal:= nMax - nMin + 1
			oSecBilhetes:Cell("SERIE"):SetValue((cAliasFix)->SERIE)
			oSecBilhetes:Cell("SUBSERIE"):SetValue((cAliasFix)->SUBSERIE)
			oSecBilhetes:Cell("NUMCOM"):SetValue((cAliasFix)->NUMCOM)
			oSecBilhetes:Cell("DATAREM"):SetValue(STOD((cAliasFix)->DATAREM))
			oSecBilhetes:Cell("TIPO"):SetValue((cAliasFix)->TIPO)
			oSecBilhetes:Cell("TIPO"):SetValue((cAliasFix)->TIPO + " - " + (cAliasFix)->TIPODESCRI)
			oSecBilhetes:Cell("MIN"):SetValue(cMin)
			oSecBilhetes:Cell("MAX"):SetValue(cMax)
			oSecBilhetes:Cell("SUBTOTAL"):SetValue(nSubtotal)
			oSecBilhetes:Init()
			oSecBilhetes:PrintLine()
			aBilhet:= {}
			nCount:= 0
		EndIf
			(cAliasTmp)->(DbCloseArea())
			(cAliasFix)->(DbSkip())
	End	
	(cAliasFix)->(DbCloseArea())
	oSecAge:Finish()
	oSecBilhetes:Finish()
EndIf

Return
