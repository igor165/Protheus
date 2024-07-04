#Include 'Protheus.ch'
#include 'GTPR025.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR025()
Relatório Resumo de Estatística Geral de Linhas

@sample GTPR025()

@author Flavio Martins
@since 26/09/2018
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR025()

Local oReport
Local cPerg  := 'GTPR025'

If Pergunte(cPerg, .T.)

	oReport := ReportDef(cPerg)
	oReport:PrintDialog()

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Relatório Resumo de Estatística Geral de Linhas

@sample ReportDef(cPerg)

@param cPerg - caracter - Nome da Pergunta

@return oReport - Objeto - Objeto TREPORT

@author Flavio Martins 
@since 26/09/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)
Local cTitle   := STR0001 // "Resumo - Estatística Geral de Linhas"
Local cHelp    := STR0002 // "Gera o resumo de estatística geral de linha"
Local cAliasQry   := GetNextAlias()
Local oReport
Local oSection1

oReport := TReport():New('GTPR025',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry)},cHelp,,,,,,,)
oReport:SetLandScape(.T.)
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport,cTitle,cAliasQry)
oSection1:SetTotalInLine(.F.)

TRCell():New(oSection1,"TIPO_LINHA",      cAliasQry, STR0003,                    ,40, , ,"LEFT"  ) // "Tipo de Linha" 
TRCell():New(oSection1,"KM_TOTAL",        cAliasQry, STR0004,                    ,08, , ,"CENTER") // "KM Total" 
TRCell():New(oSection1,"OCUPACAO",        cAliasQry, STR0005, "@E 9,999,999.99"  ,08, , ,"CENTER") // "Ocupação" 
TRCell():New(oSection1,"VIAGENS",         cAliasQry, STR0006,                    ,06, , ,"CENTER") // "Nº de Viagens" 
TRCell():New(oSection1,"TOT_PASSAG",      cAliasQry, STR0007,                    ,08, , ,"CENTER") // "Nº de Passag." 
TRCell():New(oSection1,"FROTA",           cAliasQry, STR0008,                    ,06, , ,"CENTER") // "Frota" 
TRCell():New(oSection1,"PERC_APROV",      cAliasQry, STR0009, "@E 99.99"         ,08, , ,"CENTER") // "% Aprov." 
TRCell():New(oSection1,"REC_KM_BRUTO",    cAliasQry, STR0010, "@E 999,999,999.99",10, , ,"CENTER") // "Rec. p/ KM" 
TRCell():New(oSection1,"REC_KM_LIQ",      cAliasQry, STR0011, "@E 999,999,999.99",10, , ,"CENTER") // "Rec. p/ KM s/Imp." 
TRCell():New(oSection1,"RECEITA_OFERTADA",cAliasQry, STR0012, "@E 999,999,999.99",16, , ,"CENTER") // "Receita Ofertada" 
TRCell():New(oSection1,"VALOR_ICMS",      cAliasQry, STR0013, "@E 999,999,999.99",16, , ,"CENTER") // "Valor Impostos" 
TRCell():New(oSection1,"RECEITA_AFERIDA", cAliasQry, STR0014, "@E 999,999,999.99",16, , ,"CENTER") // "Receita Aferida"
TRCell():New(oSection1,"TOTAL_LIQUIDO",   cAliasQry, STR0015, "@E 999,999,999.99",16, , ,"CENTER") // "Valor Liquido"

TRFunction():New(oSection1:Cell("KM_TOTAL"),        NIL,"SUM",,,/*Picture*/,,.F.,,,)
TRFunction():New(oSection1:Cell("VIAGENS"),         NIL,"SUM",,,/*Picture*/,,.F.,,,)
TRFunction():New(oSection1:Cell("TOT_PASSAG"),      NIL,"SUM",,,/*Picture*/,,.F.,,,,)
TRFunction():New(oSection1:Cell("FROTA"),           NIL,"SUM",,,/*Picture*/,,.F.,,,)
TRFunction():New(oSection1:Cell("PERC_APROV"),      NIL,"AVERAGE",,,"@E 99.99",,.F.,,,)
TRFunction():New(oSection1:Cell("REC_KM_BRUTO"),    NIL,"AVERAGE",,,"@E 999,999,999.99",,.F.,,,)
TRFunction():New(oSection1:Cell("REC_KM_LIQ"),      NIL,"AVERAGE",,,"@E 999,999,999.99",,.F.,,,)
TRFunction():New(oSection1:Cell("RECEITA_OFERTADA"),NIL,"SUM",,,"@E 999,999,999.99",,.F.,,,)
TRFunction():New(oSection1:Cell("RECEITA_AFERIDA"), NIL,"SUM",,,"@E 999,999,999.99",,.F.,,,)
TRFunction():New(oSection1:Cell("VALOR_ICMS"),      NIL,"SUM",,,"@E 999,999,999.99",,.F.,,,)
TRFunction():New(oSection1:Cell("TOTAL_LIQUIDO"),   NIL,"SUM",,,"@E 999,999,999.99",,.F.,,,)

oSection1:SetColSpace(1,.F.)
oSection1:SetAutoSize(.F.)
oSection1:SetLineBreak(.F.)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()

@sample ReportPrint(oReport, cAliasQry)

@param oReport - Objeto - Objeto TREPORT
	   cAliasQry  - Alias  - Nome do Alias para utilização na Query

@author Flavio Martins 
@since 26/09/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasQry)
Local oSection1	:= oReport:Section(1)
Local cDataDe		:= DtoS(MV_PAR01)
Local cDataAte	:= DtoS(MV_PAR02)
Local cTipoDe		:= MV_PAR03
Local cTipoAte	:= MV_PAR04
Local nPercAprv	:= 0
Local nRecKM_Brt	:= 0
Local nRecKM_Liq	:= 0
Local nVlrLiq		:= 0
Local nOcupacao	:= 0

	oSection1:BeginQuery()

	BeginSQL Alias cAliasQry
	
		SELECT
			T.GI2_TIPLIN
		  , T.GQC_DESCRI            TIPO_LINHA
		  , SUM(T.KM_TOTAL)         KM_TOTAL
		  , SUM(T.VIAGENS)          VIAGENS
		  , SUM(T.TOT_PASSAG)       TOT_PASSAG
		  , SUM(T.FROTA)            FROTA
		  , SUM(T.RECEITA_OFERTADA) RECEITA_OFERTADA
		  , SUM(T.RECEITA_AFERIDA)  RECEITA_AFERIDA
		  , SUM(T.VALOR_ICMS)       VALOR_ICMS
		  , AVG(T.LUGARES)          LUGARES
		FROM
			(
				SELECT
					GI2.GI2_TIPLIN
				  , GQC.GQC_DESCRI
				  , GI2.GI2_FILIAL
				  , AVG(GID.GID_LOTACA)                       LUGARES
				  , MAX(GI4.GI4_TAR)                          TARIFA
				  , MAX(GI4.GI4_KM)                           KM_VIAGEM
				  , COUNT(GYN.GYN_CODIGO)                     VIAGENS
				  , (MAX(GI4.GI4_KM) * COUNT(GYN.GYN_CODIGO)) KM_TOTAL
				  , (
						SELECT
							COUNT(*)
						FROM
							%Table:GIC% GIC
						WHERE
							GIC.%NotDel%
							AND GIC_FILIAL = GI2.GI2_FILIAL
							AND GIC_DTVEND BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
							AND GIC_LINHA = GI2.GI2_COD
							AND
							(
								(
									GIC_TIPO IN ('I'
											   , 'E'
											   , 'M')
									AND GIC_STATUS = 'V'
								)
								OR
								(
									GIC_TIPO IN ('P'
											   ,'W')
									AND GIC_STATUS = 'E'
								)
							)
					)
					TOT_PASSAG
				  , COALESCE(
							  (
								  SELECT
									  SUM(GIC_VALTOT)
								  FROM
									  %Table:GIC%
								  WHERE
									  %NotDel%
									  AND GIC_FILIAL = GI2.GI2_FILIAL
									  AND GIC_DTVEND BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
									  AND GIC_LINHA = GI2.GI2_COD
									  AND
									  (
										  (
											  GIC_TIPO IN ('I'
														 , 'E'
														 , 'M')
											  AND GIC_STATUS = 'V'
										  )
										  OR
										  (
											  GIC_TIPO IN ('P'
														 , 'W')
											  AND GIC_STATUS = 'E'
										  )
									  )
							 )
							 ,0) RECEITA_AFERIDA
				  , COALESCE(
							  (
								  SELECT
									  SUM(GIC_VLICMS)
								  FROM
									  %Table:GIC%
								  WHERE
									  %NotDel%
									  AND GIC_FILIAL = GI2.GI2_FILIAL
									  AND GIC_DTVEND BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
									  AND GIC_LINHA = GI2.GI2_COD
									  AND
									  (
										  (
											  GIC_TIPO IN ('I'
														 , 'E'
														 , 'M')
											  AND GIC_STATUS = 'V'
										  )
										  OR
										  (
											  GIC_TIPO IN ('P'
														 , 'W')
											  AND GIC_STATUS = 'E'
										  )
									  )
							 )
							 ,0) VALOR_ICMS
				  , (
						SELECT
							COUNT(DISTINCT(GQE_RECURS))
						FROM
							%Table:GYN% GYN
							INNER JOIN
								%Table:GQE% GQE
								ON
									GQE.GQE_FILIAL = GI2.GI2_FILIAL
									AND GQE.%NotDel%
									AND GQE.GQE_VIACOD = GYN.GYN_CODIGO
									AND GQE.GQE_TRECUR = '2'
									AND GQE.GQE_TERC IN (' '
													   , '2')
						WHERE
							GYN.GYN_FILIAL = GI2.GI2_FILIAL
							AND GYN.%NotDel%
							AND GYN.GYN_LINCOD = GI2.GI2_COD
							AND GYN.GYN_DTINI BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
					)
					                                                                               FROTA
				  , COALESCE(((COUNT(GYN.GYN_CODIGO) * AVG(GID.GID_LOTACA)) * MAX(GI4.GI4_TAR)),0) RECEITA_OFERTADA
				FROM
					%Table:GI2% GI2
					INNER JOIN
						%Table:GI1% GI1ORI
						ON
							GI1ORI.GI1_COD = GI2.GI2_LOCINI
							AND GI1ORI.%NotDel%
					INNER JOIN
						%Table:GI1% GI1DES
						ON
							GI1DES.GI1_COD = GI2.GI2_LOCFIM
							AND GI1DES.%NotDel%
					INNER JOIN
						%Table:GQC% GQC
						ON
							GQC.GQC_CODIGO = GI2.GI2_TIPLIN
							AND GQC.%NotDel%
					INNER JOIN
						%Table:GI4% GI4
						ON
							GI4.GI4_FILIAL     = GI2.GI2_FILIAL
							AND GI4.GI4_LINHA  = GI2.GI2_COD
							AND GI4.GI4_HIST   ='2'
							AND GI4.GI4_LOCORI = GI2.GI2_LOCINI
							AND GI4.GI4_LOCDES = GI2.GI2_LOCFIM
							AND GI4.%NotDel%
					LEFT JOIN
						%Table:GYN% GYN
						ON
							GYN.GYN_FILIAL     = GI2.GI2_FILIAL
							AND GYN.GYN_LINCOD = GI2.GI2_COD
							AND GYN.GYN_CANCEL = '1'
							AND GYN.%NotDel%
							AND GYN.GYN_DTINI BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
					LEFT JOIN
						%Table:GID% GID
						ON
							GID.GID_FILIAL  = GI2.GI2_FILIAL
							AND GID.GID_COD = GYN.GYN_CODGID
							AND GID.%NotDel%
							AND GID.GID_HIST = '2'
				WHERE
					GI2.GI2_FILIAL = %xFilial:GI2%
					AND GI2.%NotDel%
					AND GI2.GI2_HIST = '2'
					AND GI2.GI2_TIPLIN BETWEEN %Exp:cTipoDe% AND %Exp:cTipoAte%
				GROUP BY
					GI2.GI2_TIPLIN
				  , GQC.GQC_DESCRI
				  , GI2.GI2_FILIAL
				  , GI2.GI2_COD
			)
			T
		GROUP BY
			T.GI2_TIPLIN
		  , T.GQC_DESCRI
		ORDER BY
			GI2_TIPLIN
		
	EndSQL 
	
	oSection1:EndQuery()

	oReport:SetMeter((cAliasQry)->(RecCount()))
	
	oReport:StartPage()	
	oReport:SkipLine()
	
	While !oReport:Cancel() .AND. (cAliasQry)->(!Eof())	
		
		nVlrLiq	:= ((cAliasQry)->RECEITA_AFERIDA - (cAliasQry)->VALOR_ICMS)

		If (cAliasQry)->RECEITA_OFERTADA > 0 
			nPercAprv	:= (((cAliasQry)->RECEITA_AFERIDA / (cAliasQry)->RECEITA_OFERTADA) * 100)
		Else
			nPercAprv := 0
		Endif
		
		nOcupacao	:=	 (((cAliasQry)->LUGARES * nPercAprv) / 100)
		
		If (cAliasQry)->KM_TOTAL > 0
			nRecKM_Brt	:= ((cAliasQry)->RECEITA_AFERIDA / (cAliasQry)->KM_TOTAL) 
			nRecKm_Liq	:= (nVlrLiq / (cAliasQry)->KM_TOTAL) 
		Else
			nRecKM_Brt	:= 0
			nRecKm_Liq	:= 0
		Endif
		
		oSection1:Init()
		
		oSection1:Cell("PERC_APROV"):SetValue(nPercAprv)  
		oSection1:Cell("REC_KM_BRUTO"):SetValue(nRecKM_Brt)  
		oSection1:Cell("REC_KM_LIQ"):SetValue(nRecKm_Liq)  
		oSection1:Cell("TOTAL_LIQUIDO"):SetValue(nVlrLiq)  
		oSection1:Cell("OCUPACAO"):SetValue(nOcupacao)  

		oSection1:PrintLine()
		
		(cAliasQry)->(DbSkip())  
		
	End

   oSection1:Finish()

Return
