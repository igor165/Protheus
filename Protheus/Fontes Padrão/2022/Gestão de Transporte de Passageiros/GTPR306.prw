#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE 'GTPR306.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR306()
Relatório Quadro de Movimentação de Passageiros

@sample GTPR306()

@author Flavio Martins
@since 14/11/2018
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR306()

	Local oReport
	
	Local cPerg  := 'GTPR423'
	
	Pergunte(cPerg, .T.)
	
	oReport := ReportDef(cPerg)
	oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Relatório Quadro de Movimentação de Passageiros

@sample ReportDef(cPerg)

@param cPerg - caracter - Nome da Pergunta

@return oReport - Objeto - Objeto TREPORT

@author Flavio Martins
@since 14/11/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)

Local cTitle   := STR0001 //'Rel. Quadro de Movimento de Passageiros'
Local cHelp    := STR0002 //'Gera o relatório demonstrativo de movimento de passageiros'
Local cAliasQry   := GetNextAlias()
Local oReport
Local oSection1
Local oSection2

oReport := TReport():New('GTPR306',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry)},cHelp,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,.F./*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
oReport:SetLandScapet(.T.)
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport, cTitle, cAliasQry)
TRCell():New(oSection1,"TIPLIN", cAliasQry,"Tipo de Linha" , /*Picture*/, 100/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 

oSection1:SetHeaderSection(.F.)

oSection2 := TRSection():New(oReport, cTitle, cAliasQry)
TRCell():New(oSection2,"NUMLIN", cAliasQry, "Núm. Linha", /*Picture*/, 10 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,"LEFT") // "Número da Linha"
TRCell():New(oSection2,"PREFIX", cAliasQry, "Prefixo", /*Picture*/, TamSX3("GI2_PREFIX")[1] /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,"LEFT") // "Prefixo"
TRCell():New(oSection2,"DESCLINHA", cAliasQry, "Descrição", /*Picture*/, 90 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,"LEFT") // "Descrição"
TRCell():New(oSection2,"TOTBIL1", cAliasQry, "Tot.Passag.1", /*Picture*/, 12 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,"CENTER") // ""
TRCell():New(oSection2,"TOTBIL2", cAliasQry, "Tot.Passag.2", /*Picture*/, 12 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,"CENTER") // ""
TRCell():New(oSection2,"TOTBIL3", cAliasQry, "Tot.Passag.3", /*Picture*/, 12 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,"CENTER") // ""
TRCell():New(oSection2,"VLRECEITA", cAliasQry, "Vl.Receita", "@E 9,999,999.99", 20 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,"RIGHT") // "Vl. Receita"
TRCell():New(oSection2,"VLICMS", cAliasQry, "Vl.ICMS", "@E 9,999,999.99", 20 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,"RIGHT") // "Vl. ICMS"

oSection2:SetAutoSize(.F.)

oSection2:Cell("NUMLIN"):lHeaderSize		:= .T.
oSection2:Cell("PREFIX"):lHeaderSize 		:= .F.
oSection2:Cell("DESCLINHA"):lHeaderSize	:= .F.
oSection2:Cell("TOTBIL1"):lHeaderSize		:= .F.
oSection2:Cell("TOTBIL2"):lHeaderSize		:= .F.
oSection2:Cell("TOTBIL3"):lHeaderSize		:= .F.
oSection2:Cell("VLRECEITA"):lHeaderSize	:= .F.
oSection2:Cell("VLICMS"):lHeaderSize		:= .F.

oBreak:= TRBreak():New(oSection1,{||(cAliasQry)->(DESC_TIPLIN)},"",.T.)
TRFunction():New(oSection2:Cell('VLRECEITA'),'TOTREC', 'SUM',oBreak ,,"@E 9,999,999.99",,.F.,.F.,.F.,oSection2,,,)
TRFunction():New(oSection2:Cell('VLICMS'),'TOTICM', 'SUM',oBreak ,,"@E 9,999,999.99",,.F.,.F.,.F.,oSection2,,,)

oBreak:SetTotalInLine(.F.)
oBreak:SetTitle(STR0003)//'Subtotal'

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()

@sample ReportPrint(oReport, cAliasQry)

@param oReport - Objeto - Objeto TREPORT
	   cAliasQry  - Alias  - Nome do Alias para utilização na Query

@author Flavio Martins
@since 14/11/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasQry)
Local cAliasTar	:= GetNextAlias()
Local cAliasTmp := GetNextAlias()
Local oSection1		:= oReport:Section(1)
Local oSection2		:= oReport:Section(2)
Local cMV_PAR01		:= AllTrim(MV_PAR01)
Local cCCS			:= ''
Local nTarifa		:= 0
Local aDados		:= {}
Local aTarifa		:= {}
Local cStatus		:= ''
Local cCCS			:= ''
Local nPos			:= 0
Local nTarifa		:= 0
Local nX			:= 0
Local cTipLin		:= ''
Local cISento		:= AllTrim(GTPGetRules("ISENTOIMP")) //Relação dos tipos de linhas com isenção de impostos
Local nAlqICMS	:= SuperGetMv("MV_GTPICM",,12 )
Local nVlICMS		:= 0
Local cStLinha	:= ''
Local cStTrecho	:= ''
	
	If MV_PAR08 == 1
	
		cStLinha := "%GI2.GI2_MSBLQL = 2%"
		
	ElseIf MV_PAR08 == 2
	
		cStLinha := "%GI2.GI2_MSBLQL = 1%"
	
	Else
	
		cStLinha := "%GI2.GI2_MSBLQL IN (1,2)%"
	
	Endif
	
	
	If MV_PAR09 == 1
	
		cStTrecho := "%GI4.GI4_MSBLQL = 2%"
		
	ElseIf MV_PAR09 == 2
	
		cStTrecho := "%GI4.GI4_MSBLQL = 1%"
	
	Else
	
		cStTrecho := "%GI4.GI4_MSBLQL IN (1,2)%"
	
	Endif
	
	If MV_PAR10 == 1
		
		cCCS := "%GI4.GI4_CCS <> ''%"
			
	Elseif MV_PAR10 == 2
		
		cCCS := "%GI4.GI4_CCS <> ''%"
			
	Else
	
		cCCS := "%GI4.GI4_CCS = GI4.GI4_CCS%"
	
	Endif

 	BeginSql Alias cAliasQry
	 	
		SELECT
			T.NUMLIN
		  , T.COD_TIPLIN
		  , T.DESC_TIPLIN
		  , T.PREFIX
		  , T.TARIFA
		  , T.LINHA
		  , T.LOCORI
		  , T.LOCDES
		  , T.DESCORI
		  , T.DESCDES
		  , T.DATA_VENDA
		  , SUM(T.TOT_BILHETES) TOT_BILHETES
		FROM
			(
				SELECT
					'IDA'          SENTIDO
				  , GI2.GI2_NUMLIN NUMLIN
				  , GI2.GI2_PREFIX PREFIX
				  , GI2.GI2_TIPLIN COD_TIPLIN
				  , GQC.GQC_DESCRI DESC_TIPLIN
				  , GI4.GI4_LINHA  LINHA
				  , GI4.GI4_TAR    TARIFA
				  , GI4.GI4_LOCORI LOCORI
				  , GI4.GI4_LOCDES LOCDES
				  ,
					(
						CASE
							WHEN GI4.GI4_CCS = ''
								THEN '0'
								ELSE GI4.GI4_CCS
						END
					)
					CCS
				  , CASE
						WHEN GYN.GYN_EXTRA IS NULL
							THEN 'F'
							ELSE GYN.GYN_EXTRA
					END                   VIAGEM_EXTRA
				  , GI1ORI.GI1_DESCRI     DESCORI
				  , GI1DES.GI1_DESCRI     DESCDES
				  , GI1ORI.GI1_CODINT     CODINT_ORI
				  , GI1DES.GI1_CODINT     CODINT_DES
				  , GIC.GIC_DTVEND        DATA_VENDA
				  , COUNT(GIC.GIC_CODIGO) TOT_BILHETES
				FROM
					%Table:GI2% GI2
					INNER JOIN
						%Table:GI4% GI4
						ON
							GI4.GI4_FILIAL    = GI2.GI2_FILIAL
							AND GI4.GI4_LINHA = GI2.GI2_COD
							AND GI4.GI4_HIST  = '2'
							AND GI4.GI4_KM    > 0
							AND GI4.%NotDel%
							AND %Exp:cStTrecho%
							AND %Exp:cCCS%
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
					LEFT JOIN
						%Table:GIC% GIC
						ON
							GIC.GIC_FILIAL     = GI2.GI2_FILIAL
							AND GIC.GIC_LINHA  = GI2.GI2_COD
							AND GIC.GIC_LOCORI = GI4.GI4_LOCORI
							AND GIC.GIC_LOCDES = GI4.GI4_LOCDES
							AND GIC.%NotDel%
							AND GIC.GIC_DTVEND BETWEEN %exp:Dtos(MV_PAR06)% AND %exp:Dtos(MV_PAR07)%
							AND
							(
								(
									(
										GIC.GIC_TIPO IN ('I'
													   ,'T'
													   ,'E'
													   ,'M')
										AND GIC.GIC_STATUS IN ('V'
															 ,'E'
															 ,'T')
									)
									OR
									(
										GIC.GIC_TIPO IN ('P'
													   ,'W')
										AND GIC.GIC_STATUS = 'E'
									)
								)
							)
					LEFT JOIN
						%Table:GYN% GYN
						ON
							GYN.GYN_FILIAL     = GI2.GI2_FILIAL
							AND GYN.GYN_CODIGO = GIC.GIC_CODSRV
				WHERE
					GI2.GI2_FILIAL = %xFilial:GI2%
					AND GI2.%NotDel%
					AND GI2.GI2_HIST = '2'
					AND GI2.GI2_NUMLIN BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05%
					AND GI2.GI2_TIPLIN BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%
					AND %Exp:cStLinha%
					AND GI2.GI2_KMIDA > 0
				GROUP BY
					GI2.GI2_NUMLIN
				  , GI2.GI2_PREFIX
				  , GI2.GI2_TIPLIN
				  , GQC.GQC_DESCRI
				  , GI4.GI4_LINHA
				  , GI4.GI4_TAR
				  , GI4.GI4_LOCORI
				  , GI4.GI4_LOCDES
				  , GI4.GI4_CCS
				  , GYN.GYN_EXTRA
				  , GIC.GIC_DTVEND
				  , GI1ORI.GI1_DESCRI
				  , GI1DES.GI1_DESCRI
				  , GI1ORI.GI1_CODINT
				  , GI1DES.GI1_CODINT
				UNION ALL
				SELECT
					'VOLTA'        SENTIDO
				  , GI2.GI2_NUMLIN NUMLIN
				  , GI2.GI2_PREFIX PREFIX
				  , GI2.GI2_TIPLIN COD_TIPLIN
				  , GQC.GQC_DESCRI DESC_TIPLIN
				  , GI4.GI4_LINHA  LINHA
				  , GI4.GI4_TAR    TARIFA
				  , GI4.GI4_LOCDES LOCDES
				  , GI4.GI4_LOCORI LOCORI
				  ,
					(
						CASE
							WHEN GI4.GI4_CCS = ''
								THEN '0'
								ELSE GI4.GI4_CCS
						END
					)
					CCS
				  , CASE
						WHEN GYN.GYN_EXTRA IS NULL
							THEN 'F'
							ELSE GYN.GYN_EXTRA
					END                   VIAGEM_EXTRA
				  , GI1DES.GI1_DESCRI     DESCDES
				  , GI1ORI.GI1_DESCRI     DESCORI
				  , GI1DES.GI1_CODINT     CODINT_DES
				  , GI1ORI.GI1_CODINT     CODINT_ORI
				  , GIC.GIC_DTVEND        DATA_VENDA
				  , COUNT(GIC.GIC_CODIGO) TOT_BILHETES
				FROM
					%Table:GI2% GI2
					INNER JOIN
						%Table:GI4% GI4
						ON
							GI4.GI4_FILIAL    = GI2.GI2_FILIAL
							AND GI4.GI4_LINHA = GI2.GI2_COD
							AND GI4.GI4_HIST  = '2'
							AND GI4.GI4_KM    > 0
							AND GI4.%NotDel%
							AND %Exp:cStTrecho%
							AND %Exp:cCCS%
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
					LEFT JOIN
						%Table:GIC% GIC
						ON
							GIC.GIC_FILIAL     = GI2.GI2_FILIAL
							AND GIC.GIC_LINHA  = GI2.GI2_COD
							AND GIC.GIC_LOCORI = GI4.GI4_LOCORI
							AND GIC.GIC_LOCDES = GI4.GI4_LOCDES
							AND GIC.%NotDel%
							AND GIC.GIC_DTVEND BETWEEN %exp:Dtos(MV_PAR06)% AND %exp:Dtos(MV_PAR07)%
							AND
							(
								(
									(
										GIC.GIC_TIPO IN ('I'
													   ,'T'
													   ,'E'
													   ,'M')
										AND GIC.GIC_STATUS IN ('V'
															 ,'E'
															 ,'T')
									)
									OR
									(
										GIC.GIC_TIPO IN ('P'
													   ,'W')
										AND GIC.GIC_STATUS = 'E'
									)
								)
							)
					LEFT JOIN
						%Table:GYN% GYN
						ON
							GYN.GYN_FILIAL     = GI2.GI2_FILIAL
							AND GYN.GYN_CODIGO = GIC.GIC_CODSRV
				WHERE
					GI2.GI2_FILIAL = %xFilial:GI2%
					AND GI2.%NotDel%
					AND GI2.GI2_HIST = '2'
					AND GI2.GI2_NUMLIN BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05%
					AND GI2.GI2_TIPLIN BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%
					AND GI2.GI2_KMVOLT > 0
				GROUP BY
					GI2.GI2_NUMLIN
				  , GI2.GI2_PREFIX
				  , GI2.GI2_TIPLIN
				  , GQC.GQC_DESCRI
				  , GI4.GI4_LINHA
				  , GI4.GI4_TAR
				  , GI4.GI4_LOCORI
				  , GI4.GI4_LOCDES
				  , GI4.GI4_CCS
				  , GYN.GYN_EXTRA
				  , GIC.GIC_DTVEND
				  , GI1ORI.GI1_DESCRI
				  , GI1DES.GI1_DESCRI
				  , GI1ORI.GI1_CODINT
				  , GI1DES.GI1_CODINT
			)
			T
		GROUP BY
			T.NUMLIN
		  , T.PREFIX
		  , T.COD_TIPLIN
		  , T.DESC_TIPLIN
		  , T.TARIFA
		  , T.LINHA
		  , T.LOCORI
		  , T.LOCDES
		  , T.DESCORI
		  , T.DATA_VENDA
		  , T.DESCDES
		ORDER BY
			T.DESC_TIPLIN
		  , T.NUMLIN
		  , T.LOCORI
		  , T.LOCDES
		         
 	EndSql	
 	
 	(cAliasQry)->(dbGoTop())
	 	
 	If !(cAliasQry)->(Eof())
	 	
		While !(cAliasQry)->(Eof())
			
			BeginSql Alias cAliasTmp
				SELECT
					G5G.G5G_VALOR AS TAR
				FROM
					%Table:G5G% G5G
				WHERE
					G5G.%NotDel%
					AND G5G.G5G_FILIAL  = %xFilial:G5G%
					AND G5G.G5G_VIGENC <= %Exp:IIF(EMPTY((cAliasQry)->DATA_VENDA),Dtos(MV_PAR07),(cAliasQry)->DATA_VENDA)%
					AND
					(
						(
							G5G.G5G_LOCORI     = %Exp:(cAliasQry)->LOCORI%
							AND G5G.G5G_LOCDES = %Exp:(cAliasQry)->LOCDES%
						)
						OR
						(
							G5G.G5G_LOCORI     = %Exp:(cAliasQry)->LOCDES%
							AND G5G.G5G_LOCDES = %Exp:(cAliasQry)->LOCORI%
						)
					)
					AND G5G.G5G_TPREAJ  = '1'
					AND G5G.G5G_VIGENC != ''
					AND G5G.G5G_CODLIN  = %Exp:(cAliasQry)->LINHA%
				ORDER BY
					G5G.G5G_VIGENC
				  , G5G.G5G_DTREAJ
				  , G5G.G5G_HRREAJ
			EndSql
			
			BeginSql Alias cAliasTar
	
				SELECT
					GIC_TAR TARIFA
				  , COUNT(*)   TOTAL
				FROM
					%Table:GIC% GIC
					INNER JOIN
						%Table:GI2% GI2
						ON
							GI2.GI2_COD        = GIC.GIC_LINHA
							AND GI2.GI2_HIST   = '2'
							AND GI2.GI2_NUMLIN = %exp:(cAliasQry)->NUMLIN%
							AND GI2.%NotDel%
				WHERE
					GIC_FILIAL = %xFilial:GIC%
					AND
					(
						(
							GIC_LOCORI     = %Exp:(cAliasQry)->LOCORI%
							AND GIC_LOCDES = %Exp:(cAliasQry)->LOCDES%
						)
						OR
						(
							GIC_LOCORI     = %Exp:(cAliasQry)->LOCDES%
							AND GIC_LOCDES = %Exp:(cAliasQry)->LOCORI%
						)
					)
					AND GIC_DTVEND BETWEEN %exp:Dtos(MV_PAR06)% AND %exp:Dtos(MV_PAR07)%
					AND GIC_TIPO IN ('I'
								   ,'P'
								   ,'W')
					AND GIC_STATUS = 'V'
				GROUP BY
					GIC_TAR
				ORDER BY
					COUNT(*) DESC
				SELECT
					GIC_TARTAB TARIFA
				  , COUNT(*)   TOTAL
				FROM
					%Table:GIC% GIC
					INNER JOIN
						%Table:GI2% GI2
						ON
							GI2.GI2_COD        = GIC.GIC_LINHA
							AND GI2.GI2_HIST   = '2'
							AND GI2.GI2_NUMLIN = %exp:(cAliasQry)->NUMLIN%
							AND GI2.%NotDel%
				WHERE
					GIC_FILIAL = %xFilial:GIC%
					AND
					(
						(
							GIC_LOCORI     = %Exp:(cAliasQry)->LOCORI%
							AND GIC_LOCDES = %Exp:(cAliasQry)->LOCDES%
						)
						OR
						(
							GIC_LOCORI     = %Exp:(cAliasQry)->LOCDES%
							AND GIC_LOCDES = %Exp:(cAliasQry)->LOCORI%
						)
					)
					AND GIC_DTVEND BETWEEN %exp:Dtos(MV_PAR06)% AND %exp:Dtos(MV_PAR07)%
					AND GIC_TIPO IN ('I'
								   ,'P'
								   ,'W')
					AND GIC_STATUS = 'V'
				GROUP BY
					GIC_TARTAB
				ORDER BY
					COUNT(*) DESC		
	
			EndSql	
			
			(cAliasTmp)->(dbGoTop())
			
			If !(cAliasTmp)->(Eof())
				nTarifa := (cAliasTmp)->TAR
			Else
				
				(cAliasTar)->(dbGoTop())
				
				If !(cAliasTar)->(Eof())
				
					nTarifa := (cAliasTar)->TARIFA
				
				Else
				
					nTarifa := 0
				
				Endif
				
				If nTarifa == 0
				
					nTarifa := (cAliasQry)->TARIFA
				
				Endif
				
			Endif
			(cAliasTar)->(dbCloseArea())
			(cAliasTmp)->(dbCloseArea())
		
	 		If (nPos := Ascan(aDados,{|x,y| x[3] == (cAliasQry)->NUMLIN }) ) == 0
 		
		 		If (cAliasQry)->DESC_TIPLIN $ cIsento
		 		
		 			nVlICMS := 0
		 		
		 		Else
		 		
					nVlICMS := ((cAliasQry)->TOT_BILHETES * nAlqICMS) / 100
		 		
		 		Endif
		 		
		 		Aadd(aDados, {(cAliasQry)->COD_TIPLIN,;
		 						(cAliasQry)->DESC_TIPLIN,;
 								(cAliasQry)->NUMLIN,;
								(cAliasQry)->PREFIX,;
								(cAliasQry)->DESCORI,;
								(cAliasQry)->DESCDES,;
								(cAliasQry)->TOT_BILHETES,;
								0,;
								0,;
								nTarifa * (cAliasQry)->TOT_BILHETES,;
								nVlICMS})
							
			Else
		
				aDados[nPos][7] += (cAliasQry)->TOT_BILHETES
				aDados[nPos][10] += ((cAliasQry)->TOT_BILHETES * nTarifa)


		 		If (cAliasQry)->DESC_TIPLIN $ cIsento
		 		
		 			aDados[nPos][11] := 0
		 		
		 		Else
		 		
					aDados[nPos][11] := (aDados[nPos][10] * nAlqICMS) / 100
		 		
		 		Endif
				
		
			Endif
				
			(cAliasQry)->(dbSkip())
	
		End
		
		For nX := 1 to Len(aDados)
	
			If cTipLin != aDados[nX][2]
		
				oSection1:Cell('TIPLIN'):SetValue('Tipo de Linha : ' + aDados[nX][2])

				oSection2:Finish()
				oSection1:Finish()
				
				oSection1:Init()
				
				oSection1:PrintLine()
				oReport:ThinLine()
				
				cTipLin := aDados[nX][2]
				
				oReport:SkipLine(2)
				oSection2:Init()
				
			Endif
			
			oSection2:Cell('NUMLIN'):SetValue(aDados[nX][3])
			oSection2:Cell('PREFIX'):SetValue(aDados[nX][4])
			oSection2:Cell('DESCLINHA'):SetValue(AllTrim(aDados[nX][5]) + ' x ' + AllTrim(aDados[nX][6]))
			oSection2:Cell('TOTBIL1'):SetValue(aDados[nX][7])
			oSection2:Cell('TOTBIL2'):SetValue(aDados[nX][8])
			oSection2:Cell('TOTBIL3'):SetValue(aDados[nX][9])
			oSection2:Cell('VLRECEITA'):SetValue(aDados[nX][10])
			oSection2:Cell('VLICMS'):SetValue(aDados[nX][11])
				
			oSection2:PrintLine()
			
		Next 
		
		
		oSection2:Finish()
		oSection1:Finish()
	Endif
   
Return