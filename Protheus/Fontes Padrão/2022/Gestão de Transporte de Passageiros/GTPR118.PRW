#include "GTPR118.CH"
#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.ch"

#define DMPAPER_A4 9
//------------------------------------------------------------------------------  
/*/{Protheus.doc} GTPR118  
Fechamento de km   
@sample 	 GTPR118()  
@return	 Nil  
@author	 Fábio Veiga
@since	 18/06/2018  
@version	 P12  
@comments
/*///------------------------------------------------------------------------------
Function GTPR118()
Local oReport
Local cPerg     := "GTPR118"
	
If Pergunte(cPerg,.T.)
					
	oReport := ReportDef(  )
	oReport:PrintDialog()
			
EndIf

Return
//------------------------------------------------------------------------------  
/*/{Protheus.doc} ReportDef  
Defini‡äes de Relatorio  
@sample 	 ReportDef(cAliasTmp)   
@return	 Nil  
@author	 SI4503 - Marcio Martins Pereira    
@since	 12/02/2016  
@version	 P12  
@comments  
/*///------------------------------------------------------------------------------ 
Static Function ReportDef()
Local cAliasTmp	:= GetNextAlias()
Local oReport
Local oSecCbEx
Local oSection2
Local cTitulo := STR0001//'[GTPR118] - Relatorio de Fechamento de Km

SX3->(DBSETORDER(1))
	
oReport := TReport():New('GTPR118', cTitulo, 'GTPR118', {|oReport| PrintReport(oReport,cAliasTmp)}, STR0002  )//"Este relatorio ira imprimir o Fechamento de Km."

oSecCbEx := TRSection():New( oReport, "DATAINI" ,{cAliasTmp} )//"Datas"
TRCell():New(oSecCbEx, "DATAINI", cAliasTmp, STR0019,"@D",10)//'Data de:'
TRCell():New(oSecCbEx, "DATAFIM", cAliasTmp, STR0020,"@D",10)//'Data até:'
	
oSection2 := TRSection():New(oReport, STR0004 ,{cAliasTmp})//"Status de Viagens: "
	
TRCell():New(oSection2, "VEICULO"		, cAliasTmp, STR0012,"@"							, TamSX3("GQE_RECURS")[1]  )//Véiculo
TRCell():New(oSection2, "SETOR"   		, cAliasTmp, STR0005,PesqPict('GI1',"GI1_DESCRI")	, TamSX3("GI1_DESCRI")[1]  )//SETOR	
TRCell():New(oSection2, "KM_PRODUTIVA"  , cAliasTmp, STR0006,PesqPict('GI2',"GI2_KMIDA")	, TamSX3("GI2_KMIDA" )[1]+2)//KM Prod.
TRCell():New(oSection2, "KM_IMPRODUTIVA", cAliasTmp, STR0007,PesqPict('GI2',"GI2_KMVOLT")	, TamSX3("GI2_KMVOLT")[1]+2)//KM Imp.
TRCell():New(oSection2, "KM_TOTAL" 		, cAliasTmp, STR0008,PesqPict('GI2',"GI2_KMVOLT")	, 12                       )//KM Total
TRCell():New(oSection2, "MEDIA_MES"		, cAliasTmp, STR0009,PesqPict('GI2',"GI2_KMVOLT")	, 12                       )//Média Mês
TRCell():New(oSection2, "ESTILO"		, cAliasTmp, STR0010,"@"							, TamSX3("GYR_DESCRI")[1]  )//Estilo		
TRCell():New(oSection2, "CHASSI"		, cAliasTmp, STR0011,"@"							, TamSX3("T9_CHASSI")[1]   )//Chassi
		
oBreak := TRBreak():New(oSection2,oSection2:Cell("VEICULO"),,.F.)

TRFunction():New(oSection2:Cell("VEICULO")			,"TOTAL GERAL" ,"COUNT",,STR0013,"@E 999999"            ,,.F.,.T.)//"Qtd. veículo(s):"
																																				
TRFunction():New(oSection2:Cell("KM_PRODUTIVA")		,"TOTAL GERAL" ,"SUM",	,STR0014,"@E 999,999,999.99"	,,.F.,.T.)//"KM Produtivo...:"
TRFunction():New(oSection2:Cell("KM_IMPRODUTIVA")	,"TOTAL GERAL" ,"SUM",	,STR0018,"@E 999,999,999.99"	,,.F.,.T.)//"KM Improdutivo.:"/
TRFunction():New(oSection2:Cell("KM_TOTAL")			,"TOTAL GERAL" ,"SUM",	,STR0015,"@E 999,999,999.99"	,,.F.,.T.)//"KM Total.......:"
TRFunction():New(oSection2:Cell("MEDIA_MES")		,"TOTAL GERAL" ,"SUM",	,STR0016,"@E 999,999,999.99"	,,.F.,.T.)//"Média por mês..:"
	
Return (oReport)

//------------------------------------------------------------------------------  
/*/{Protheus.doc} PrintReport  
ImpressÆo de Relat¢rio   
@sample 	 PrintReport(oReport)  
@return	 Nil  
@author	 SI4503 - Marcio Martins Pereira     
@since	 12/02/2016
@version	 P12  
@comments  
/*///------------------------------------------------------------------------------
Static Function PrintReport( oReport,cAliasTmp, cTmpTaxa, cTmpDesc, cTmpBoni  )
Local oSecCbEx	:= oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local lCabec	:= .T.
Local nKmProd	:= 0
Local nKmImprd	:= 0
Local nKmTotal  := 0
Local nQtdMeses	:= DateDiffMonth(MV_PAR01, MV_PAR02) + 1

QryKm(@cAliasTmp)

DbSelectArea(cAliasTmp)
(cAliasTmp)->(dbGoTop())
oReport:SetMeter((cAliasTmp)->(RecCount()))
If (cAliasTmp)->(!Eof())
	oSecCbEx:Init()		

	oSecCbEx:Cell("DATAINI")		:SetValue(MV_PAR01)
	oSecCbEx:Cell("DATAFIM")		:SetValue(MV_PAR02)
	oSecCbEx:PrintLine()

	While (cAliasTmp)->(!Eof())
		
		If oReport:Cancel()
			Exit
		EndIf
		
		oReport:IncMeter()

		oSection2:init()
		oSection2:lPrintHeader := lCabec
		
		oSection2:Cell("VEICULO"):SetValue((cAliasTmp)->VEICULO)
		oSection2:Cell("SETOR"):SetValue((cAliasTmp)->SETOR)
		oSection2:Cell("ESTILO"):SetValue((cAliasTmp)->ESTILO)
		oSection2:Cell("CHASSI"):SetValue((cAliasTmp)->CHASSI)

		nKmImprd := (cAliasTmp)->KM_IMPRODUTIVA * (cAliasTmp)->QTD_VIAGENS

		If (cAliasTmp)->KM_NOVO > 0
			nKmProd := (cAliasTmp)->KM_NOVO
		ElseIf (cAliasTmp)->KM > 0
			nKmProd	:= (cAliasTmp)->KM
		Endif 

		nKmTotal := nKmProd + nKmImprd

		oSection2:Cell("KM_PRODUTIVA"):SetValue(nKmProd)
		oSection2:Cell("KM_TOTAL"):SetValue(nKmTotal)
		oSection2:Cell("MEDIA_MES"):SetValue(nKmTotal / nQtdMeses)
		oSection2:Cell("KM_IMPRODUTIVA"):SetValue(nKmImprd)

		oSection2:PrintLine()
		oSection2:Finish()
		oReport:ThinLine()

		(cAliasTmp)->(dbSkip())

	Enddo

	oSection2:Finish()
	oSecCbEx:Finish()
EndIf

If Select(cAliasTmp) > 0 
	(cAliasTmp)->(DbCloseArea())
Endif

Return
/*/{Protheus.doc} QryKm
Consulta as taxas
@type function
@author crisf
@since 01/12/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------
Static Function QryKm(cTmpAlias)
Local cTipoViagem 	:= ""
 	
	If !Empty(MV_PAR05) .And. MV_PAR05 == 1
		cTipoViagem := "% AND GYN.GYN_FINAL = '1' %"
	Else
		cTipoViagem := "%%"
	Endif

	BeginSql Alias cTmpAlias

		SELECT
		  GYN.GYN_FILIAL
		, GYN.GYN_LOCORI
		, GQE.GQE_RECURS                            VEICULO
		, GI1SET.GI1_COD + ' - ' + GI1SET.GI1_DESCRI SETOR
		, ST9.T9_CHASSI                              CHASSI
		, GYN.GYN_LINCOD
		, GYR.GYR_DESCRI ESTILO
		, GI2.GI2_KMIDA
		, GI2.GI2_KMVOLT
		, COUNT(DISTINCT(GYN_CODIGO)) QTD_VIAGENS
		, COUNT(DISTINCT(GYN_CODIGO)) *
				(
					CASE
						WHEN GI2.GI2_KMIDA > 0
							THEN GI2.GI2_KMIDA
							ELSE GI2.GI2_KMVOLT
					END
				)
							KM_NOVO
		, SUM(GI4.GI4_KM) KM
		,
			(
				SELECT
					SUM(GI1_KMGRRD + GI1_KMRDGR)
				FROM
					%Table:GI1%
				WHERE
					GI1_FILIAL    = %xFilial:GI1%
					AND GI1_COD   = GYN.GYN_LOCORI
					AND %NotDel%
			)
			KM_IMPRODUTIVA
		FROM
			%Table:GYN% GYN
			INNER JOIN
				%Table:G55% G55
				ON
					G55.G55_FILIAL     = %xFilial:G55%
					AND G55.G55_CODVIA = GYN.GYN_CODIGO
					AND G55.%NotDel%
			INNER JOIN
				%Table:GI4% GI4
				ON
					GI4.GI4_FILIAL     = %xFilial:GI4%
					AND GI4.GI4_LINHA  = GYN.GYN_LINCOD
					AND GI4.GI4_LOCORI = G55.G55_LOCORI
					AND GI4.GI4_LOCDES = G55.G55_LOCDES
					AND GI4.GI4_HIST   = '2'
					AND GI4.%NotDel%
			INNER JOIN
				%Table:GQE% GQE
				ON
					GQE.GQE_FILIAL     = %xFilial:GQE%
					AND GQE.GQE_VIACOD = G55.G55_CODVIA
					AND GQE.GQE_SEQ    = G55.G55_SEQ
					AND GQE_TRECUR     = '2'
					AND GQE.GQE_RECURS BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
					AND GQE.GQE_TERC IN (' '
									, '2')
					AND GQE.%NotDel%
			INNER JOIN
				%Table:ST9% ST9
				ON
					ST9.T9_FILIAL     = %xFilial:ST9%
					AND ST9.T9_CODBEM = GQE.GQE_RECURS
					AND ST9.%NotDel%
			INNER JOIN
				%Table:GYU% GYU
				ON
					GYU.GYU_CODVEI = GQE.GQE_RECURS
					AND GYU.%NotDel%
			INNER JOIN
				%Table:GYT% GYT
				ON
					GYT.GYT_CODIGO = GYU.GYU_CODSET
					AND GYT.%NotDel%
			INNER JOIN
				%Table:GI1% GI1SET
				ON
					GI1SET.GI1_FILIAL    = %xFilial:GI1%
					AND GI1SET.GI1_COD   = GYT.GYT_LOCALI
					AND GI1SET.%NotDel%
			INNER JOIN
				%Table:GI2% GI2
				ON
					GI2.GI2_FILIAL    = %xFilial:GI2%
					AND GI2.GI2_COD   = GYN.GYN_LINCOD
					AND GI2.GI2_HIST  = '2'
					AND GI2.%NotDel%
			LEFT JOIN
				%Table:GYR% GYR
				ON
					GYR.GYR_FILIAL     = %xFilial:GYR%
					AND GYR.GYR_CODIGO = GI2.GI2_CATEG
					AND GYR.%NotDel%
		WHERE
			GYN.GYN_FILIAL = %xFilial:GYN%
			AND GYN.GYN_DTINI BETWEEN %Exp:Dtos(MV_PAR01)% AND %Exp:Dtos(MV_PAR02)%
			AND GYN_CANCEL <> '2'
			%Exp:cTipoViagem%
			AND GYN.%NotDel%
		GROUP BY
			GYN.GYN_FILIAL
			, GYN.GYN_LOCORI
			, GQE.GQE_RECURS
			, GI1SET.GI1_COD
			, GI1SET.GI1_DESCRI
			, ST9.T9_CHASSI
			, GYN.GYN_LINCOD
			, GYR.GYR_DESCRI
			, GI2.GI2_KMIDA
			, GI2.GI2_KMVOLT	

	EndSql	

Return
