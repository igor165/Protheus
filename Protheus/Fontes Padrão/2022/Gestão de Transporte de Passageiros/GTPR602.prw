#Include 'Protheus.ch'
#include 'GTPR602.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR602()
Relatório de receita de clientes de contrato de turismo
@sample GTPR602()
@author Flavio Martins
@since 17/02/2022
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR602()
Local oReport
Local cPerg  := 'GTPR602'

If Pergunte(cPerg, .T.)
	oReport := ReportDef(cPerg)
	oReport:PrintDialog()
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
@sample ReportDef(cPerg)
@param cPerg - caracter - Nome da Pergunta
@return oReport - Objeto - Objeto TREPORT
@author Flavio Martins 
@since 17/02/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)
Local cTitle    := STR0001 //"Receita de Clientes de Contrato de Turismo"
Local cHelp  	:= STR0001 //"Gera o relatório de receita de clientes de contrato de turismo"
Local cAliasQry := GetNextAlias()
Local oReport
Local oSection1
Local oSection2

oReport := TReport():New('GTPR602',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry)},cHelp,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
oReport:SetLandscape(.T.)
oReport:nFontBody := 5
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport, cTitle, cAliasQry)
TRCell():New(oSection1,"CLIENTE", "G6R", , /*Picture*/, 100/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
oSection1:SetHeaderSection(.F.)  

oSection2 := TRSection():New(oReport,cTitle,cAliasQry)
oSection2:SetTotalInLine(.F.)

TRCell():New(oSection2,"G6R_DTINCL"	,"G6R"		,STR0003, /*Picture*/, TamSX3("G6R_DTINCL")[1] /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Data Emissão"
TRCell():New(oSection2,"VENDEDOR"	,"G6R"		,STR0004, /*Picture*/, 40 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Vendedor"
TRCell():New(oSection2,"G6R_TIPITI"	,"G6R"		,STR0005, /*Picture*/, 20/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Itinerário"
TRCell():New(oSection2,"ORIGEM"		,"GI1ORI"	,STR0006, /*Picture*/, 50/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Origem"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
TRCell():New(oSection2,"DESTINO"	,"GI1DES"	,STR0007, /*Picture*/, 50 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) //"Destino" 
TRCell():New(oSection2,"DTHRINI"	,"G6R"		,STR0008, /*Picture*/, 16/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Início" 
TRCell():New(oSection2,"DTHRFIM"	,"G6R"		,STR0009, /*Picture*/, 16/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Fim" 
TRCell():New(oSection2,"G6R_KMCONT"	,"G6R"		,STR0010, /*Picture*/, TamSX3("G6R_KMCONT")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) //"KM Contratado"
TRCell():New(oSection2,"G6R_PDTOT"	,"G6R"		,STR0011, /*Picture*/, TamSX3("G6R_PDTOT")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) //"Total Pedágio" 
TRCell():New(oSection2,"G6R_VALTOT"	,"G6R"		,STR0012, /*Picture*/, TamSX3("G6R_VALTOT")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Valor Custo"
TRCell():New(oSection2,"G6R_VALACO"	,"G6R"		,STR0013, /*Picture*/, TamSX3("G6R_VALACO")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Valor Acordado" 

oSection2:Cell("G6R_TIPITI"):lHeaderSize := .F. 
oSection2:Cell("DTHRINI"):lHeaderSize 	 := .F. 
oSection2:Cell("DTHRFIM"):lHeaderSize    := .F. 

oBreak:= TRBreak():New(oSection2,{||(cAliasQry)->(A1_COD)},"",.T.)
 
oBreak:SetPageBreak(.F.)

TRFunction():New(oSection2:Cell("G6R_VALTOT"),NIL,"SUM",,,"@E 9,999,999.99",,,,,,{|| .T.})
TRFunction():New(oSection2:Cell("G6R_VALACO"),NIL,"SUM",,,"@E 99,999,999.99",,,,,,{|| .T.})

oSection2:SetColSpace(1,.T.)
oSection2:SetAutoSize(.F.)
oSection2:SetLineBreak(.F.)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()
@sample ReportPrint(oReport, cAliasQry)
@param oReport - Objeto - Objeto TREPORT
	   cAliasQry  - Alias  - Nome do Alias para utilização na Query
@author Flavio Martins 
@since 17/02/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasQry)
Local oSection1   := oReport:Section(1)
Local oSection2   := oReport:Section(2)
Local cCodCli     := ""
Local cDtHrIni 	  := ""
Local cDtHrFim 	  := ""

	oSection2:SetTotalText(STR0014) // "Totais do Cliente"

	oSection2:BeginQuery()

	BeginSql Alias cAliasQry
		
		SELECT G6R.G6R_DTINCL,
				G6R.G6R_TIPITI,
				G6R.G6R_KMCONT,
				G6R.G6R_PDTOT,
				G6R.G6R_VALTOT,
				G6R.G6R_VALACO,
				G6R.G6R_DTIDA,
				G6R.G6R_HRIDA,
				G6R.G6R_DTVLTA,
				G6R.G6R_HRVLTA,
				SA3.A3_COD,
				SA3.A3_NOME,
				SA1.A1_COD,
				SA1.A1_NOME,
				GI1ORI.GI1_COD AS LOCORI,
				GI1ORI.GI1_DESCRI AS DESCORI,
				GI1DES.GI1_COD AS LOCDES,
				GI1DES.GI1_DESCRI AS DESCDES
		FROM %Table:G6R% G6R
		INNER JOIN %Table:SA1% SA1 ON SA1.A1_FILIAL = %xFilial:SA1%
		AND SA1.A1_COD = G6R.G6R_SA1COD
		AND SA1.A1_LOJA = G6R.G6R_SA1LOJ
		AND SA1.%NotDel%
		INNER JOIN %Table:SA3% SA3 ON SA3.A3_FILIAL = %xFilial:SA3%
		AND SA3.A3_COD = G6R.G6R_SA3COD
		AND SA3.%NotDel%
		INNER JOIN %Table:GI1% GI1ORI ON GI1ORI.GI1_FILIAL = %xFilial:GI1%
		AND GI1ORI.GI1_COD = G6R.G6R_LOCORI
		AND GI1ORI.%NotDel% 
		INNER JOIN %Table:GI1% GI1DES ON GI1DES.GI1_FILIAL = %xFilial:GI1%
		AND GI1DES.GI1_COD = G6R.G6R_LOCDES
		AND GI1DES.%NotDel% 
		WHERE G6R.G6R_FILIAL = %xFilial:G6R%
			AND G6R.G6R_DTINCL BETWEEN %Exp:DtoS(MV_PAR01)% AND %Exp:DtoS(MV_PAR02)%
			AND G6R.G6R_SA1COD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR05%
			AND G6R.G6R_SA1LOJ BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR06%
			AND G6R.G6R_CODIGO BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
			AND G6R.G6R_SA3COD BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10%
			AND G6R.%NotDel%
		ORDER BY G6R.G6R_SA1COD, G6R.G6R_SA1LOJ

	EndSql 

	oSection2:EndQuery()

	oReport:SetMeter((cAliasQry)->(RecCount()))

	oReport:StartPage()	
	oReport:SkipLine()

	While !oReport:Cancel() .And. (cAliasQry)->(!Eof())	

		If cCodCli != (cAliasQry)->A1_COD

			oSection2:Finish()
			oSection1:Init()
			oSection1:Cell("CLIENTE"):SetValue(STR0015 + (cAliasQry)->A1_COD + ' ' + (cAliasQry)->A1_NOME) // "Cliente: "
			oSection1:PrintLine()
			oReport:ThinLine()
			oReport:SkipLine(2)
			oSection1:Finish()

			cCodCli := (cAliasQry)->A1_COD

		Endif

		cDtHrIni := DtoC((cAliasQry)->G6R_DTIDA) + ' ' + Substr((cAliasQry)->G6R_HRIDA, 1, 2) + ':' + Substr((cAliasQry)->G6R_HRIDA, 3, 2) 
		cDtHrFim := DtoC((cAliasQry)->G6R_DTVLTA) + ' ' + Substr((cAliasQry)->G6R_HRVLTA, 1, 2) + ':' + Substr((cAliasQry)->G6R_HRVLTA, 3, 2) 

		oSection2:Init()

		oSection2:Cell("VENDEDOR"):SetValue((cAliasQry)->A3_COD + ' ' + (cAliasQry)->A3_NOME) 
		oSection2:Cell("ORIGEM"):SetValue((cAliasQry)->LOCORI + ' ' + (cAliasQry)->DESCORI) 
		oSection2:Cell("DESTINO"):SetValue((cAliasQry)->LOCDES + ' ' + (cAliasQry)->DESCDES) 
		oSection2:Cell("DTHRINI"):SetValue(cDtHrIni) 
		oSection2:Cell("DTHRFIM"):SetValue(cDtHrFim) 

		oSection2:PrintLine()

		(cAliasQry)->(dbSkip())  

	EndDo

	oSection2:Finish()

Return
