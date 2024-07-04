#Include 'Protheus.ch'
#INCLUDE 'GTPR416.CH'
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPR416
Relatório de Comissão de Agência
@type function
@author crisf
@since 30/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Function GTPR416()

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
@since 30/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function ReportDef()
	
	Local cPerg		:= "GTPR416"
	Local cTitulo	:= STR0002//"Relatório de Comissões de Agência"
	Local cDescrRel	:= STR0003//"Listará as comissões calculadas."
	Local oReport
	Local oSection1
		
		oReport:= TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cDescrRel)
		oReport:SetLandscape()
		oReport:HideParamPage()
		
		if Pergunte(oReport:uParam,.T.)
			
			If Empty(MV_PAR02) .OR.  Empty(MV_PAR04) .OR.  Empty(MV_PAR05)
				
				Help(,,"Help", cPerg,STR0004 , 1, 0)//"Parâmetros não informados de forma correta."
				Return
				
			EndIf
			
			oSection1:= TRSection():New(oReport, STR0005,{"GQ6"})// "Relatório de Extrato de Comissões de Agência"
			oSection1:lHeaderVisible := .T.
			oSection1:SetReadOnly()
			
				TRCell():New(oSection1,"GQ6_AGENCI"	,"GQ6"	,	STR0006	,/*Picture*/,TamSx3("GQ6_AGENCI")[1],/*lPixel*/	,/* {|| }*/)//"Agência"
				TRCell():New(oSection1,"NOMEAG"		,"GQ6"	,	STR0007	,/*Picture*/,TamSx3("GI6_DESCRI")[1],/*lPixel*/	,/* {|| }*/)//"Nome"
				TRCell():New(oSection1,"GQ6_CODCOL"	,"GQ6"	,	STR0008	,/*Picture*/,TamSx3("GQ6_CODCOL")[1],/*lPixel*/	,/* {|| }*/)//"Cod.Resp."	
				TRCell():New(oSection1,"NOMERESP"	,"GQ6"	,	STR0009	,/*Picture*/,TamSx3("GYG_NOME")[1],/*lPixel*/	,/* {|| }*/)//"Nome Responsável"
				TRCell():New(oSection1,"GQ6_FORNEC"	,"GQ6"	,	STR0010	,/*Picture*/,TamSx3("GQ6_FORNEC")[1],/*lPixel*/	,/* {|| }*/)//"Cod.Fornec"
				TRCell():New(oSection1,"NOMEFORNEC"	,"GQ6"	,	STR0011	,/*Picture*/,TamSx3("A2_NOME")[1],/*lPixel*/	,/* {|| }*/)//"Nome Fornecedor"
				TRCell():New(oSection1,"GQ6_LOJA"	,"GQ6"	,	STR0012	,/*Picture*/,TamSx3("GQ6_LOJA")[1],/*lPixel*/	,/* {|| }*/)//"Loja"
				TRCell():New(oSection1,"GQ6_VTCOMI"	,"GQ6"	,	STR0013	,PesqPict("G95","G95_VLRCOM"),TamSx3("GQ6_VTCOMI")[1],/*lPixel*/	,/* {|| }*/)//""Valor Comissão"
			
				TRFunction():New(oSection1:Cell("GQ6_VTCOMI"),NIL,"SUM")
				oReport:GetFunction(1):SetEndReport(.F.)
						
			Return(oReport)
		
		Else
		
			Alert(STR0014)//"Cancelado pelo usuário"
			
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
	Local cTmpGQ6	:= GetNextAlias()

		oSection1:BeginQuery()
			
			BeginSql Alias cTmpGQ6
				
				SELECT GQ6.GQ6_FILIAL, GQ6.GQ6_CODIGO, GQ6.GQ6_AGENCI,
					 (SELECT GI6.GI6_DESCRI
					 FROM %Table:GI6%  GI6
					 WHERE GI6.GI6_FILIAL = %xFilial:GI6%
						  AND GQ6.GQ6_AGENCI = GI6.GI6_CODIGO
						  AND GI6.D_E_L_E_T_ = ' ' ) NOMEAG,  
						  GQ6.GQ6_DATADE, GQ6.GQ6_DATATE, 
					  GQ6.GQ6_CODCOL,
					  ISNULL((SELECT GYG.GYG_NOME
					  FROM %Table:GYG% GYG
					  WHERE GYG.GYG_FILIAL =  %xFilial:GYG%
					    AND GYG.GYG_CODIGO = GQ6.GQ6_AGENCI
					    AND GYG.D_E_L_E_T_ = ' '),'') NOMERESP, GQ6.GQ6_FORNEC,
						ISNULL((SELECT A2_NOME
						FROM %Table:SA2% SA2
						WHERE SA2.A2_FILIAL =  %xFilial:SA2%
						  AND SA2.A2_COD = GQ6.GQ6_FORNEC
						  AND SA2.A2_LOJA = GQ6.GQ6_LOJA
						  AND SA2.D_E_L_E_T_ = ' '),'') NOMEFORNEC,
						 GQ6.GQ6_LOJA, GQ6.GQ6_VTCOMI
				FROM %Table:GQ6% GQ6
				WHERE GQ6.GQ6_FILIAL =  %xFilial:GQ6%
				  AND GQ6.D_E_L_E_T_ = ' '
				  AND GQ6.GQ6_CODIGO BETWEEN %exp:MV_PAR01% AND  %exp:MV_PAR02%
				  AND GQ6.GQ6_AGENCI BETWEEN %exp:MV_PAR03% AND  %exp:MV_PAR04%
				  AND GQ6.GQ6_DATADE BETWEEN %exp:Dtos(MV_PAR05)% AND  %exp:Dtos(MV_PAR06)%
				  AND GQ6.GQ6_DATATE BETWEEN %exp:Dtos(MV_PAR05)% AND  %exp:Dtos(MV_PAR06)%
				  AND GQ6.GQ6_SIMULA = ''
	
			EndSql
		
		oSection1:EndQuery()
		
		oSection1:Print()
		oSection1:Finish()
		
Return
