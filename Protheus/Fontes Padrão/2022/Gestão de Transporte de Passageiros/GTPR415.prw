#INCLUDE 'Protheus.ch'
#INCLUDE 'GTPR415.CH'
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPR415
Relatório de processamento de comissão de agência
@type function
@author crisf
@since 29/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Function GTPR415()

	Local lProcessa := .T.

	Private oReport
			
		If !TRepInUse()
			
			Alert(STR0001)//"A impressão em TREPORT deverá estar habilitada. Favor verificar o parâmetro MV_TREPORT."
			lProcessa := .F.
	
		EndIf
	
		If lProcessa
	
			oReport:= ReportDef()
			
			if oReport <> Nil
			
				oReport:PrintDialog()
	
			EndIf
			
		EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
(long_description)
@type function
@author crisf
@since 29/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function ReportDef()
	
	Local cPerg		:= "GTPR415"
	Local cTitulo	:= STR0002//"Relatório de Comissões de Contrato de Turismo"
	Local cDescrRel	:= STR0003//"Listará as comissões calculadas."
	Local oReport
	Local oSection1
	Local oDetalhes	
	Local oDetCTR
	
	
	oReport:= TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cDescrRel)
	oReport:SetLandscape()
	oReport:HideParamPage()
	
	if Pergunte(oReport:uParam,.T.)
		
		If Empty(MV_PAR01) .OR.  Empty(MV_PAR02) .OR.  Empty(MV_PAR03) .OR.  Empty(MV_PAR05)
			
			Help(,,"Help", cPerg, STR0004, 1, 0)//"Parâmetros não informados de forma correta."
			Return
			
		EndIf
		
		oSection1:= TRSection():New(oReport, STR0005,{"GI6"})// "Agência"
		oSection1:lHeaderVisible := .T.
		oSection1:SetReadOnly()
		
			TRCell():New(oSection1,"G94_AGENCI"	,"G94"	,STR0006			,/*Picture*/,TamSx3("G94_AGENCI")[1],/*lPixel*/	,/* {|| }*/)//"Código"
			TRCell():New(oSection1,"DESCAGENCI"	,"GIC"	,STR0007			,/*Picture*/,TamSx3("GI6_DESCRI")[1],/*lPixel*/	,/* {|| }*/)//"Nome"
			
			//oSection1:SetPageBreak(.T.) //Define se salta a página na quebra de seção
			
			oDetalhes := TRSection():New(oSection1,"Detalhes","G95")
			
			TRCell():New(oDetalhes,"G95_PROD"	,"G95"	,	STR0008,/*Picture*/,TamSx3("B1_COD")[1],/*lPixel*/	,/* {|| }*/)//"Código Produto"
			TRCell():New(oDetalhes,"DESCPROD"	,"SB1"	,	STR0009,/*Picture*/,TamSx3("B1_DESC")[1],/*lPixel*/	,/* {|| }*/)//"Descrição Produto"
			TRCell():New(oDetalhes,"G94_VEND"	,"G94"	,	STR0010,/*Picture*/,TamSx3("A3_COD")[1],/*lPixel*/	,/* {|| }*/)//"Cód. Vendedor"	
			TRCell():New(oDetalhes,"NOMEVEND"	,"SA3"	,	STR0011,/*Picture*/,TamSx3("A3_NOME")[1],/*lPixel*/	,/* {|| }*/)//"Nome Venndedor"
			TRCell():New(oDetalhes,"G95_VALTOT"	,"G95"	,	STR0012,/*Picture*/,TamSx3("G95_VALTOT")[1],/*lPixel*/	,/* {|| }*/)//"Vl.total faturado"
			TRCell():New(oDetalhes,"G94_VLBXFI"	,"G95"	,	STR0013,/*Picture*/,TamSx3("G94_VLBXFI")[1],/*lPixel*/	,/* {|| }*/)//"Vl.Baixado"
			TRCell():New(oDetalhes,"G95_COMISS"	,"G95"	,	STR0014,/*Picture*/,TamSx3("G95_COMISS")[1],/*lPixel*/	,/* {|| }*/)//"% Comissão"
			TRCell():New(oDetalhes,"G95_VLRCOM"	,"G95"	,	STR0015,PesqPict("G95","G95_VLRCOM"),TamSx3("G95_VLRCOM")[1],/*lPixel*/	,/* {|| }*/)//"Valor da Comissão"
		
			//oDetalhes:Cell('G95_VLRCOM'):SetTitle('Valor total de comissão')
			TRFunction():New(oDetalhes:Cell("G95_VLRCOM"),NIL,"SUM")
			oReport:GetFunction(1):SetEndReport(.F.)
		
		//1-Sim: Imprime dados dos contratos
		if MV_PAR06 == 1
			
			oDetCTR := TRSection():New(oReport,"Dados do Contrato","G95")
			
			TRCell():New(oDetCTR,"CJ_PROPOST"	,"SCJ"	,	STR0016,/*Picture*/,TamSx3("CJ_PROPOST")[1],/*lPixel*/	,/* {|| }*/)//"Numero do Contrato"
			TRCell():New(oDetCTR,"GIN_LOCOR"	,"GIN"	,	STR0017,/*Picture*/,TamSx3("GIN_LOCOR")[1],/*lPixel*/	,/* {|| }*/)//"Local de Origem"
			TRCell():New(oDetCTR,"DESCORIG"		,"G94"	,	STR0018,/*Picture*/,TamSx3("A3_COD")[1],/*lPixel*/	,/* {|| }*/)//"Descrição Local Origem"
			TRCell():New(oDetCTR,"GIN_LOCDES"	,"GIN"	,	STR0019,/*Picture*/,TamSx3("GIN_LOCDES")[1],/*lPixel*/	,/* {|| }*/)//"Local de Destino"
			TRCell():New(oDetCTR,"DESCDESTI"	,"G95"	,	STR0020,/*Picture*/,TamSx3("G95_VALTOT")[1],/*lPixel*/	,/* {|| }*/)//"Descrição Local Destino"
			TRCell():New(oDetCTR,"TOTAL"		,"G95"	,	STR0021,PesqPict("G95","G95_VLRCOM"),TamSx3("G95_VLRCOM")[1],/*lPixel*/	,/* {|| }*/)//"Total do Contrato"
			
		EndIf
		
		Return(oReport)
	
	Else
	
		Alert(STR0022)//"Cancelado pelo usuário"
		
	EndIf
			
Return 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
(long_description)
@type function
@author crisf
@since 29/11/2017
@version 1.0
@param oReport, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)
Local oDetalhes	:= oReport:Section(1):Section(1)
Local oDetCTR	:= oReport:Section(2)
Local cAliasG95	:= GetNextAlias()
Local cTMP		:= GetNextAlias()
Local lBOracle	:= Trim(TcGetDb()) == 'ORACLE'
Local cSelect   := ""

If lBOracle
	cSelect := "%CAST(SUBSTR(TO_CHAR(CONVERT(VARBINARY(8000),GZJ_DADOS)),1,19) AS VARCHAR(19))%"
Else
	cSelect := "%SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),GZJ_DADOS)),1,19)%"
EndIf
oSection1:BeginQuery()
	
BeginSql Alias cAliasG95
	
	SELECT
		G94.G94_FILIAL
	, G94.G94_AGENCI
	, G94.G94_AGENCI G95AGENCI
	, (
			SELECT
				GI6.GI6_DESCRI
			FROM
				%Table:GI6% GI6
			WHERE
				GI6.GI6_FILIAL     = %xFilial:GI6%
				AND GI6.GI6_CODIGO = G94.G94_AGENCI
				AND GI6.%NotDel%
		)
		DESCAGENCI
	, G94.G94_DATADE
	, G94.G94_DATATE
	, G94.G94_CODIGO
	, G94.G94_SIMULA
	, G94.G94_VEND
	, (
			SELECT
				SA3.A3_NOME
			FROM
				%Table:SA3% SA3
			WHERE
				SA3.A3_FILIAL  = %xFilial:SA3%
				AND SA3.A3_COD = G94.G94_VEND
				AND SA3.%NotDel%
		)
		NOMEVEND
	, G94.G94_AGENCI
	, G94.G94_VALTSB
	, G94.G94_VALDSR
	, G94.G94_VALCSP
	, G94.G94_VALDSR
	, G94.G94_VLBXFI
	, G94.G94_ESTCSP
	, G94.G94_ESTTSB
	, G95_CODG94
	, G95_PROD
	, (
			SELECT
				SB1.B1_DESC
			FROM
				%Table:SB1% SB1
			WHERE
				SB1.B1_FILIAL  = %xFilial:SB1%
				AND SB1.B1_COD = G95.G95_PROD
				AND SB1.%NotDel%
		)
		DESCPROD
	, G95_VALTOT
	, G95_COMISS
	, G95_VLRCOM
	FROM
		%Table:G95% G95
		INNER JOIN
			%Table:G94% G94
			ON
				G94.G94_FILIAL     = %xFilial:G94%
				AND G94.G94_AGENCI = %exp:MV_PAR01%
				AND G94.G94_DATADE BETWEEN %exp:Dtos(MV_PAR02)% AND %exp:Dtos(MV_PAR03)%
				AND G94.G94_DATATE BETWEEN %exp:Dtos(MV_PAR02)% AND %exp:Dtos(MV_PAR03)%
				AND G94.G94_VEND BETWEEN %exp:MV_PAR04% AND %exp:MV_PAR05%
				AND G94.%NotDel%
				AND G94.G94_SIMULA = '   '
				AND G94.G94_FILIAL = G95.G95_FILIAL
				AND G94.G94_CODIGO = G95.G95_CODG94
				AND G94.G94_SIMULA = G95.G95_SIMULA
				AND G95.G95_SIMULA = '   '
				AND G95.%NotDel%
	ORDER BY
		G94.G94_FILIAL
	, G94.G94_AGENCI
	
EndSql

oSection1:EndQuery()

oDetalhes:SetParentQuery(.T.)//Define se a seção filha utilizara a query da seção pai no processamento do método Print
oDetalhes:SetParentFilter({|cParam| (cAliasG95)->(G94_FILIAL)+(cAliasG95)->G94_AGENCI == cParam},{|| xFilial('G94')+(cAliasG95)->G95AGENCI})
//SetParentFilter->Define a regra de saída do loop de processamento do método Print das seções filhas

oSection1:Print()

//1-Sim: Imprime dados dos contratos
if MV_PAR06 == 1

	oDetCTR:BeginQuery()
			
		BeginSQL Alias cTMP
			
			SELECT
				SCJ.CJ_NUM
			, SCJ.CJ_PROPOST
			, SCJ.CJ_NROPOR
			, GIN.GIN_LOCOR
			, GIN.GIN_LOCDES
			, (
					SELECT
						GI1.GI1_DESCRI
					FROM
						%Table:GI1% GI1
					WHERE
						GI1.GI1_FILIAL      = %xFilial:GI1%
						AND GI1.GI1_COD     = GIN.GIN_LOCOR
						AND GI1.%NotDel%
				)
				DESCORIG
			, GIN.GIN_LOCDES
			, (
					SELECT
						GI1.GI1_DESCRI
					FROM
						%Table:GI1% GI1
					WHERE
						GI1.GI1_FILIAL      = %xFilial:GI1%
						AND GI1.GI1_COD     = GIN.GIN_LOCDES
						AND GI1.%NotDel%
				)
				DESCDESTI
			,
				(
					CASE
						WHEN GIN.GIN_ITEM = '01'
							THEN
							(
								SELECT
									SUM(ADZ.ADZ_TOTAL)
								FROM
									%Table:ADZ% ADZ
								WHERE
									ADZ.ADZ_FILIAL      = %xFilial:ADZ%
									AND ADZ.ADZ_ORCAME  = SCJ.CJ_NUM
									AND ADZ.%NotDel%
							)
							ELSE 0
					END
				)
				TOTAL
			FROM
				%Table:GIN% GIN
				INNER JOIN
					%Table:SCJ% SCJ
					ON
						SCJ.CJ_FILIAL       = %xFilial:SCJ%
						AND SCJ.%NotDel%
						AND EXISTS
						(
							SELECT
								SC6.C6_FILIAL
							, SC6.C6_NUM
							, SC6.C6_CLI
							, SC6.C6_LOJA
							, SC6.C6_NUMORC
							FROM
								%Table:SC6% SC6
							WHERE
								SC6.C6_FILIAL       = %xFilial:SC6%
								AND SC6.%NotDel%
								AND SC6.C6_NOTA||SC6.C6_SERIE IN
								(
									SELECT
										F2_DOC||F2_SERIE
									FROM
										%Table:SF2% SF2
									WHERE
										SF2.F2_FILIAL||SF2.F2_CLIENTE||SF2.F2_LOJA||SF2.F2_PREFIXO||SF2.F2_DUPL IN
										(
											SELECT
												%exp:cSelect%
											FROM
												%Table:GZJ% GZJ
												INNER JOIN
													%Table:G94% G94
													ON
														G94.G94_FILIAL     = %xFilial:G94%
														AND G94.G94_AGENCI = %exp:MV_PAR01%
														AND G94.G94_DATADE BETWEEN %exp:Dtos(MV_PAR02)% AND %exp:Dtos(MV_PAR03)%
														AND G94.G94_DATATE BETWEEN %exp:Dtos(MV_PAR02)% AND %exp:Dtos(MV_PAR03)%
														AND G94.G94_VEND BETWEEN %exp:MV_PAR04% AND %exp:MV_PAR05%
														AND G94.%NotDel%
														AND G94.G94_SIMULA  = '   '
														AND GZJ.GZJ_FILIAL  = %xFilial:GZJ%
														AND GZJ.%NotDel%
														AND GZJ.GZJ_CODG94  = G94.G94_CODIGO
										)
										AND SF2.%NotDel%
								)
								AND SCJ.CJ_FILIAL                = %xFilial:SCJ%
								AND SUBSTRING(SC6.C6_NUMORC,1,6) = SCJ.CJ_NUM
								AND SC6.C6_CLI                   = SCJ.CJ_CLIENTE
								AND SC6.C6_LOJA                  = SCJ.CJ_LOJA
								AND SCJ.%NotDel%
						)
						AND GIN.GIN_PROPOS = SCJ.CJ_NROPOR
			
			EndSql
		
		oDetCTR:EndQuery()	

EndIf

oDetCTR:Print()
		
Return