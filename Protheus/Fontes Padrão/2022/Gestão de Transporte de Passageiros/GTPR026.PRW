#Include 'Protheus.ch'
#include 'GTPR026.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR026()
Relatório de Estatística de Linhas Analítico

@sample GTPR026()

@author Flavio Martins
@since 24/09/2018
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR026()

Local oReport
Local cPerg  := 'GTPR026'

If Pergunte(cPerg, .T.)

	oReport := ReportDef(cPerg)
	oReport:PrintDialog()

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Relatório de Estatística de Linhas Analítico

@sample ReportDef(cPerg)

@param cPerg - caracter - Nome da Pergunta

@return oReport - Objeto - Objeto TREPORT

@author Flavio Martins 
@since 24/09/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)
Local cTitle   := STR0001 // "Estatística Geral de Linhas"
Local cHelp    := STR0002 // "Gera o relatório de estatísticas geral de linhas"
Local cAliasQry   := GetNextAlias()
Local oReport
Local oSection1
Local oSection2
Local oSection3

oReport := TReport():New('GTPR026',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry)},cHelp)
oReport:SetLandScape(.T.)
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport, cTitle, cAliasQry)
TRCell():New(oSection1,"TIPO_LINHA", "GQC", , /*Picture*/, 100/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
oSection1:SetHeaderSection(.F.)  

oSection2 := TRSection():New(oReport,cTitle,cAliasQry)
TRCell():New(oSection2,"DESCR_LINHA", "GQC", , /*Picture*/, 100/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
oSection2:SetHeaderSection(.F.) 

oSection3 := TRSection():New(oReport,cTitle,cAliasQry)
oSection3:SetTotalInLine(.F.)

TRCell():New(oSection3,"ANO",             cAliasQry, STR0003, ,                    06, , ,"LEFT"  ) //"Ano" 
TRCell():New(oSection3,"LUGARES",         cAliasQry, STR0004, ,                    06, , ,"CENTER") // "Lugares" 
TRCell():New(oSection3,"TARIFA",          cAliasQry, STR0005, "@E 999,999,999.99", 10, , ,"CENTER") // "Tarifa" 
TRCell():New(oSection3,"OCUPACAO",        cAliasQry, STR0006, "@E 9,999,999.99",   08, , ,"CENTER") // "Ocupação" 
TRCell():New(oSection3,"KM_VIAGEM",       cAliasQry, STR0007, ,                    08, , ,"CENTER") // "KM Viagem"
TRCell():New(oSection3,"KM_TOTAL",        cAliasQry, STR0008, ,                    08, , ,"CENTER") // "KM Total" 
TRCell():New(oSection3,"VIAGENS",         cAliasQry, STR0009, ,                    06, , ,"CENTER") // "Nº de Viagens" 
TRCell():New(oSection3,"TOT_PASSAG",      cAliasQry, STR0010, ,                    08, , ,"CENTER") // "Nº de Passag." 
TRCell():New(oSection3,"FROTA",           cAliasQry, STR0011, ,                    06, , ,"CENTER") // "Frota" 
TRCell():New(oSection3,"PERC_APROV",      cAliasQry, STR0012, "@E 99.99",          08, , ,"CENTER") // "% Aprov." 
TRCell():New(oSection3,"REC_KM_BRUTO",    cAliasQry, STR0013, "@E 999,999,999.99", 10, , ,"CENTER") // "Rec. p/ KM" 
TRCell():New(oSection3,"REC_KM_LIQ",      cAliasQry, STR0014, "@E 999,999,999.99", 10, , ,"CENTER") // "Rec. p/ KM s/Imp." 
TRCell():New(oSection3,"RECEITA_OFERTADA",cAliasQry, STR0015, "@E 999,999,999.99", 16, , ,"CENTER") // "Receita Ofertada" 
TRCell():New(oSection3,"VALOR_ICMS",      cAliasQry, STR0016, "@E 999,999,999.99", 16, , ,"CENTER") // "Valor Impostos" 
TRCell():New(oSection3,"RECEITA_AFERIDA", cAliasQry, STR0017, "@E 999,999,999.99", 16, , ,"CENTER") // "Receita Aferida"
TRCell():New(oSection3,"TOTAL_LIQUIDO",   cAliasQry, STR0018, "@E 999,999,999.99", 16, , ,"CENTER") // "Valor Liquido"

oSection3:Cell("ANO"):lHeaderSize                := .T.
oSection3:Cell("LUGARES"):lHeaderSize            := .T.
oSection3:Cell("TARIFA"):lHeaderSize             := .T.
oSection3:Cell("OCUPACAO"):lHeaderSize           := .T.
oSection3:Cell("KM_VIAGEM"):lHeaderSize          := .T.
oSection3:Cell("KM_TOTAL"):lHeaderSize           := .T.
oSection3:Cell("VIAGENS"):lHeaderSize            := .T.
oSection3:Cell("TOT_PASSAG"):lHeaderSize         := .T.
oSection3:Cell("FROTA"):lHeaderSize              := .T.
oSection3:Cell("PERC_APROV"):lHeaderSize         := .T.
oSection3:Cell("REC_KM_BRUTO"):lHeaderSize       := .T.
oSection3:Cell("REC_KM_LIQ"):lHeaderSize         := .T.
oSection3:Cell("RECEITA_OFERTADA"):lHeaderSize   := .T.
oSection3:Cell("VALOR_ICMS"):lHeaderSize         := .T.
oSection3:Cell("RECEITA_AFERIDA"):lHeaderSize    := .T.
oSection3:Cell("TOTAL_LIQUIDO"):lHeaderSize      := .T.

oBreak:= TRBreak():New(oSection3,{||(cAliasQry)->(GQC_DESCRI)},"",.T.)
 
oBreak:SetPageBreak(.F.)

oSection3:SetColSpace(1,.F.)
oSection3:SetAutoSize(.F.)
oSection3:SetLineBreak(.F.)

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
Local oSection2	:= oReport:Section(2)
Local oSection3	:= oReport:Section(3)
Local cDataDe   := DtoS(MV_PAR01)
Local cDataAte	:= DtoS(MV_PAR02)
Local cDtAntDe	:= ""
Local cDtAntAte	:= ""
Local cAnoAtu   := ""
Local cAnoAnt   := ""
Local cTipoDe   := MV_PAR03
Local cTipoAte	:= MV_PAR04
Local cLinhaDe	:= MV_PAR05
Local cLinhaAte	:= MV_PAR06
Local cTipLin   := ""
Local cLinha    := ""
Local nPercAprv	:= 0
Local nRecKM_Brt := 0
Local nRecKM_Liq := 0
Local nVlrLiq   := 0
Local nOcupacao	:= 0

	cAnoAtu	:= cValToChar(Year(MV_PAR01))
	cAnoAnt	:= cValToChar(Year(MV_PAR01)-1)
	
	cDtAntDe  := cValToChar((Year(MV_PAR01)-1)) + StrZero(Month(MV_PAR01),2) + StrZero(Day(MV_PAR01),2)
	cDtAntAte := cValToChar((Year(MV_PAR02)-1)) + StrZero(Month(MV_PAR02),2) + StrZero(Day(MV_PAR02),2)
	
	oSection3:BeginQuery()

	BeginSQL Alias cAliasQry
	
		SELECT T.ANO
		     , T.GI2_TIPLIN
			 , T.GQC_DESCRI
			 , T.GI2_FILIAL
			 , T.GI2_COD
			 , T.GI2_NUMLIN
			 , T.ORIGEM
			 , T.DESTINO
			 , T.LUGARES
			 , T.TARIFA
			 , T.KM_VIAGEM
			 , T.VIAGENS
			 , T.KM_TOTAL
			 , T.TOT_PASSAG
			 , T.RECEITA_AFERIDA
			 , T.VALOR_ICMS
			 , T.FROTA
			 , T.RECEITA_OFERTADA
		FROM
			(
				SELECT
					%Exp:cAnoAnt% ANO
				  , GI2.GI2_TIPLIN
				  , GQC.GQC_DESCRI
				  , GI2.GI2_FILIAL
				  , GI2.GI2_COD
				  , GI2.GI2_NUMLIN
				  , GI1ORI.GI1_DESCRI   AS ORIGEM
				  , GI1DES.GI1_DESCRI   AS DESTINO
				  , AVG(GID.GID_LOTACA)    LUGARES
				  ,
					MAX(GI4.GI4_TAR)                          TARIFA
				  , MAX(GI4.GI4_KM)                           KM_VIAGEM
				  , COUNT(GYN.GYN_CODIGO)                     VIAGENS
				  , (MAX(GI4.GI4_KM) * COUNT(GYN.GYN_CODIGO)) KM_TOTAL
				  , (
						SELECT
							COUNT(*)
						FROM
							%Table:GIC%
						WHERE
							%NotDel%
							AND GIC_FILIAL = GI2.GI2_FILIAL
							AND GIC_DTVEND BETWEEN %Exp:cDtAntDe% AND %Exp:cDtAntAte%
							AND GIC_LINHA = GI2.GI2_COD
							AND
							(
								(
									GIC_TIPO IN ('I'
											   ,'E'
											   ,'M')
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
				  , ISNULL(
							(
								SELECT
									SUM(GIC_VALTOT)
								FROM
									%Table:GIC%
								WHERE
									%NotDel%
									AND GIC_FILIAL = GI2.GI2_FILIAL
									AND GIC_DTVEND BETWEEN %Exp:cDtAntDe% AND %Exp:cDtAntAte%
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
				  , ISNULL(
							(
								SELECT
									SUM(GIC_VLICMS)
								FROM
									%Table:GIC%
								WHERE
									%NotDel%
									AND GIC_FILIAL = GI2.GI2_FILIAL
									AND GIC_DTVEND BETWEEN %Exp:cDtAntDe% AND %Exp:cDtAntAte%
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
							AND GYN.GYN_DTINI BETWEEN %Exp:cDtAntDe% AND %Exp:cDtAntAte%
					)
					                                                                   FROTA
				  , ((COUNT(GYN.GYN_CODIGO) * AVG(GID.GID_LOTACA)) * MAX(GI4.GI4_TAR)) RECEITA_OFERTADA
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
							AND GYN.GYN_DTINI BETWEEN %Exp:cDtAntDe% AND %Exp:cDtAntAte%
							AND GYN.%NotDel%
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
					AND GI2.GI2_COD BETWEEN %Exp:cLinhaDe% AND %Exp:cLinhaAte%
				GROUP BY
					GI2.GI2_TIPLIN
				  , GQC.GQC_DESCRI
				  , GI2.GI2_FILIAL
				  , GI2.GI2_COD
				  , GI2.GI2_NUMLIN
				  , GI1ORI.GI1_DESCRI
				  , GI1DES.GI1_DESCRI
				UNION ALL
				SELECT
					%Exp:cAnoAtu% ANO
				  , GI2.GI2_TIPLIN
				  , GQC.GQC_DESCRI
				  , GI2.GI2_FILIAL
				  , GI2.GI2_COD
				  , GI2.GI2_NUMLIN
				  , GI1ORI.GI1_DESCRI                         AS ORIGEM
				  , GI1DES.GI1_DESCRI                         AS DESTINO
				  , AVG(GID.GID_LOTACA)                          LUGARES
				  , MAX(GI4.GI4_TAR)                             TARIFA
				  , MAX(GI4.GI4_KM)                              KM_VIAGEM
				  , COUNT(GYN.GYN_CODIGO)                        VIAGENS
				  , (MAX(GI4.GI4_KM) * COUNT(GYN.GYN_CODIGO))    KM_TOTAL
				  , (
						SELECT
							COUNT(*)
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
											   ,'E'
											   ,'M')
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
				  , ISNULL(
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
				  , ISNULL(
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
				  , ((COUNT(GYN.GYN_CODIGO) * AVG(GID.GID_LOTACA)) * MAX(GI4.GI4_TAR)) RECEITA_OFERTADA
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
							AND GYN.GYN_DTINI BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
							AND GYN.%NotDel%
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
					AND GI2.GI2_COD BETWEEN %Exp:cLinhaDe% AND %Exp:cLinhaAte%
				GROUP BY
					GI2.GI2_TIPLIN
				  , GQC.GQC_DESCRI
				  , GI2.GI2_FILIAL
				  , GI2.GI2_COD
				  , GI2.GI2_NUMLIN
				  , GI1ORI.GI1_DESCRI
				  , GI1DES.GI1_DESCRI
			)
			T
		ORDER BY
			T.GI2_TIPLIN
		  , T.GI2_COD
		  , T.ANO	
					
	EndSQL 
	
	oSection3:EndQuery()

	oReport:SetMeter((cAliasQry)->(RecCount()))
	
	oReport:StartPage()	
	oReport:SkipLine()
	
	While !oReport:Cancel() .AND. (cAliasQry)->(!Eof())	
	
		If cTipLin != (cAliasQry)->GQC_DESCRI
			
			oSection3:Finish()
			oSection2:Finish()
			oSection1:Init()
			oSection1:Cell("TIPO_LINHA"):SetValue(STR0019 + (cAliasQry)->GQC_DESCRI) // "Tipo de Linha: "
			oSection1:PrintLine()
			oReport:ThinLine()
			oReport:SkipLine(2)
			oSection1:Finish()
			
			cTiplin := (cAliasQry)->GQC_DESCRI
			
		Endif
		
		If cLinha != (cAliasQry)->GI2_COD
			
			oSection3:Finish()
			oSection2:Init()
			oSection2:Cell("DESCR_LINHA"):SetValue(STR0020 + (cAliasQry)->GI2_COD + ' - ' +  AllTrim((cAliasQry)->ORIGEM) + ' x ' + AllTrim((cAliasQry)->DESTINO)) // "Linha: " 
			oSection2:PrintLine()
			oReport:ThinLine()
			oSection2:Finish()
			
			cLinha := (cAliasQry)->GI2_COD
			
		Endif
		
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
		
		oSection3:Init()
		
		oSection3:Cell("PERC_APROV"):SetValue(nPercAprv)  
		oSection3:Cell("REC_KM_BRUTO"):SetValue(nRecKM_Brt)  
		oSection3:Cell("REC_KM_LIQ"):SetValue(nRecKm_Liq)  
		oSection3:Cell("TOTAL_LIQUIDO"):SetValue(nVlrLiq)  
		oSection3:Cell("OCUPACAO"):SetValue(nOcupacao)  

		oSection3:PrintLine()
		
		(cAliasQry)->(DbSkip())  
		
	End

   oSection3:Finish()

Return
