#include "FINR916.ch"
#include "protheus.ch"
#include "topconn.ch"

Static __lSOFEX	 As Logical
Static __lOracle As Logical
Static __lPostGre As Logical

//-------------------------------------------------------------------
/*/ {Protheus.doc} FINR916
Relatório de Conciliação de Vendas e Pagamento

@author Danilo Santos
@since 09/05/2018
@version 12.1.19
/*/
//-------------------------------------------------------------------
*/
Function FINR916()

	Local oReport As Object

	oReport := Nil
	__lSOFEX	:= .T.
	__lOracle	:= TcGetDb() $ "INFORMIX*ORACLE"
	__lPostGre	:= tcGetdb() $ "POSTGRES"

	oReport := ReportDef()
	oReport:PrintDialog()
	oReport := NIL

	Return

	//-------------------------------------------------------------------
	/*/ {Protheus.doc} ReportDef
	Definicao do layout do Relatorio

	@author Danilo Santos
	@since 09/05/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
	*/
Static Function ReportDef() As Object

	Local oReport    As Object
	Local oSection1  As Object
	Local oTotal  	 As Object
	Local oSubTot 	 As Object
	Local nTamVal    As Numeric
	Local nTamJus	 As Numeric

	oReport    	:= nil
	oSection1  	:= nil
	oTotal     	:= nil
	oSubTot    	:= nil
	nTamVal    	:= 0
	nTamJus		:= 0

	oReport := TReport():New("FINR916",STR0001,"FINR916", {|oReport| ReportPrint(oReport)},STR0002) //"Relatório de Conciliação TEF - Pagamentos e Vendas"###"Este programa imprimirá o relatório de Conciliação TEF - Pagamentos e Vendas"

	oReport:oPage:lLandScape := .T.
	oReport:oPage:lPortRait  := .F. //Aponta a orientação de página do relatório como retrato.
	oReport:lParamPage       := .T. //Existe parâmetros para impressão.
	oReport:nFontBody        := 6
	oReport:SetEdit(.F.)

	nTamVal	:= Len(Transform(0,PesqPict("FIF","FIF_VLBRUT")))
	nTamJus := Len(Transform(0,PesqPict("FIF","FIF_DESJUS")))

	oSection1 := TRSection():New(oReport,STR0003,,,,,,.T.) //"Conciliação TEF - Pagamentos e Vendas"

	TRCell():New(oSection1,"FIF_FILIAL"   	,/*Tabela*/, STR0004							,"@!",	TAMSX3("FIF_FILIAL")[1] 	) //"Filial"
	TRCell():New(oSection1,"MDE_DESC"   	,/*Tabela*/, STR0005							,"@!",	TAMSX3("MDE_DESC")[1] 	) //"Operadora"
	TRCell():New(oSection1,"ORIGEM"  	 	,/*Tabela*/, STR0006							,"@!",	6 	) //"Conciliacao"
	TRCell():New(oSection1,"STATUS"		   	,/*Tabela*/, STR0007							,"@!",	10 	) //"Status"
	TRCell():New(oSection1,"FIF_CODFIL"		,/*Tabela*/, AllTrim(RetTitle("FIF_CODFIL"))	,,,.F.,	)
	TRCell():New(oSection1,"E1_CLIENTE"		,/*Tabela*/, AllTrim(RetTitle("E1_CLIENTE"))	,/*Picture*/,	TAMSX3("E1_CLIENTE")[1]	)
	TRCell():New(oSection1,"E1_LOJA"		,/*Tabela*/, AllTrim(RetTitle("E1_LOJA"))		,/*Picture*/,	TAMSX3("E1_LOJA")[1]	)
	TRCell():New(oSection1,"E1_NOMCLI"		,/*Tabela*/, AllTrim(RetTitle("E1_NOMCLI"))		,/*Picture*/,	TAMSX3("E1_NOMCLI")[1]	)
	TRCell():New(oSection1,"FIF_NSUTEF"		,/*Tabela*/, AllTrim(RetTitle("FIF_NSUTEF"))	,/*Picture*/,	TAMSX3("FIF_NSUTEF")[1]	)
	TRCell():New(oSection1,"FIF_DTTEF"		,/*Tabela*/, AllTrim(RetTitle("FIF_DTTEF"))		,,,.F.,	)
	TRCell():New(oSection1,"FIF_DTCRED"		,/*Tabela*/, AllTrim(RetTitle("FIF_DTCRED"))	,,,.F.,	)
	TRCell():New(oSection1,"FIF_PARALF"		,/*Tabela*/, STR0030							,,,.F.,	) //"Parc.Arq."
	TRCell():New(oSection1,"E1_PREFIXO"		,/*Tabela*/, AllTrim(RetTitle("E1_PREFIXO"))	,,,.F.,	)
	TRCell():New(oSection1,"E1_NUM"			,/*Tabela*/, AllTrim(RetTitle("E1_NUM"))		,,,.F.,	)
	TRCell():New(oSection1,"E1_PARCELA"		,/*Tabela*/, AllTrim(RetTitle("E1_PARCELA"))	,,,.F.,	)
	TRCell():New(oSection1,"E1_TIPO"		,/*Tabela*/, AllTrim(RetTitle("E1_TIPO"))		,,,.F.,	)
	TRCell():New(oSection1,"E1_BAIXA"		,/*Tabela*/, AllTrim(RetTitle("E1_BAIXA"))		,,,.F.,	)
	TRCell():New(oSection1,"FIF_TPPROD"		,/*Tabela*/, AllTrim(RetTitle("FIF_TPPROD"))	,/*Picture*/,	8	)
	TRCell():New(oSection1,"FIF_VLBRUT"		,/*Tabela*/, AllTrim(RetTitle("FIF_VLBRUT"))	,PesqPict("FIF","FIF_VLBRUT"),nTamVal,,,,,"RIGHT")
	TRCell():New(oSection1,"FIF_VLLIQ"		,/*Tabela*/, AllTrim(RetTitle("FIF_VLLIQ"))		,PesqPict("FIF","FIF_VLLIQ"),nTamVal,,,,,"RIGHT")
	TRCell():New(oSection1,"VLRDIF"			,/*Tabela*/, STR0008	 						,PesqPict("FIF","FIF_VLLIQ"),nTamVal,,,,,"RIGHT") //"Valor Dif."
	TRCell():New(oSection1,"CODJUS"			,/*Tabela*/, AllTrim(RetTitle("FIF_CODJUS"))	,/*Picture*/,nTamJus,,,,,"RIGHT")
	TRCell():New(oSection1,"DESJUS"			,/*Tabela*/, AllTrim(RetTitle("FIF_DESJUS"))	,/*Picture*/,nTamJus,,,,,"RIGHT")
	TRCell():New(oSection1,"DESJUT"			,/*Tabela*/, AllTrim(RetTitle("FIF_DESJUT"))	,/*Picture*/,nTamJus,,,,,"RIGHT")
	TRCell():New(oSection1,"USRCONC"		,/*Tabela*/, STR0009							,/*Picture*/,30,,,,,"LEFT") //"Usuário Conc."
	TRCell():New(oSection1,"DTCONC"			,/*Tabela*/, STR0010							,,TamSX3("FIF_DTPAG")[1]+2) //"Data Conc."

	oSubTot := TRSection():New(oSection1,STR0012,{"FIF"}) //"Total por Operadora: "
	oSubTot:SetHeaderBreak(.F.)
	TRCell():New(oSubTot,'TXTTOTAL'    ,'FIF',"",/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSubTot,'VLBRUTVEN'   ,'FIF',STR0031,/*Picture*/,nTamVal,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,,,,.F.) //"Tot. Vendas"
	TRCell():New(oSubTot,'VLLIQVEN'    ,'FIF',STR0032,/*Picture*/,nTamVal,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,,,,.F.) //"Tot. Liq. Vendas"
	TRCell():New(oSubTot,'VLRDIFVEN'   ,'FIF',STR0033,/*Picture*/,nTamVal,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,,,,.F.) //"Dif. Tot. Vendas"
	TRCell():New(oSubTot,'VLBRUTPAG'   ,'FIF',STR0034,/*Picture*/,nTamVal,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,,,,.F.) //"Vlr. Tot. Pagamentos"
	TRCell():New(oSubTot,'VLLIQPAG'    ,'FIF',STR0035,/*Picture*/,nTamVal,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,,,,.F.) //"Tot. Liq. Pagamentos"
	TRCell():New(oSubTot,'VLRDIFPAG'   ,'FIF',STR0008,/*Picture*/,nTamVal,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,,,,.F.) //"Dif. Pagamentos"

	oTotal := TRSection():New(oSection1,STR0011,{"FIF"}) //"Total Geral"
	oTotal:SetHeaderBreak(.F.)
	TRCell():New(oTotal,'TXTTOTAL'    ,'FIF',"",/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oTotal,'VLBRUTVEN'   ,'FIF',STR0031,/*Picture*/,nTamVal,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,,,,.F.) //"Tot. Vendas"
	TRCell():New(oTotal,'VLLIQVEN'    ,'FIF',STR0032,/*Picture*/,nTamVal,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,,,,.F.) //"Tot. Liq. Vendas"
	TRCell():New(oTotal,'VLRDIFVEN'   ,'FIF',STR0033,/*Picture*/,nTamVal,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,,,,.F.) //"Dif. Vendas"
	TRCell():New(oTotal,'VLBRUTPAG'   ,'FIF',STR0034,/*Picture*/,nTamVal,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,,,,.F.) //"Tot. Pagamentos"
	TRCell():New(oTotal,'VLLIQPAG'    ,'FIF',STR0035,/*Picture*/,nTamVal,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,,,,.F.) //"Tot. Liq. Pagamentos"
	TRCell():New(oTotal,'VLRDIFPAG'	  ,'FIF',STR0008,/*Picture*/,nTamVal,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,,,,.F.) //"Dif. Tot. Pagamentos"

	oTotal:SetLeftMargin(118)
	oSection1:SetAutoSize()

	Return oReport

	//-------------------------------------------------------------------
	/*/ {Protheus.doc} ReportPrint
	Seleção dos registros a serem impressos no relatorio

	@author Danilo Santos
	@since 09/05/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
	*/
Static Function ReportPrint(oReport)

	Local oSection1		As Object
	Local oTotal		As Object
	Local oSubTot		As Object
	Local oBreak01  	As Object
	Local aSelFil 		As Array
	Local cQuery		As Character
	Local cSelFil 		As Character
	Local cTipo			As Character
	Local cDescri   	As Character
	Local cOrigem   	As Character
	Local nTotReg		As Numeric
	Local nTotGer		As Numeric
	Local nTotBPag		As Numeric
	Local nTotLPag		As Numeric
	Local nTotDifPag	As Numeric
	Local nTotBVen		As Numeric
	Local nTotLVen		As Numeric
	Local nTotDifVen	As Numeric
	Local nTotOpPgBr	As Numeric
	Local nTotOpPgLq	As Numeric
	Local nTotOpPgDf 	As Numeric
	Local nTotOpVnBr 	As Numeric
	Local nTotOpVnLq 	As Numeric
	Local nTotOpVnDf 	As Numeric

	Local nOperadora 	As Numeric
	Local nImpJustif 	As Numeric
	Local nImpConc	 	As Numeric
	Local nFilraFil	 	As Numeric
	Local nOrdem	 	As Numeric
	Local cBandeira	 	As Character
	Local cAdmFinan	 	As Character
	Local cCodCliDe	 	As Character
	Local cCodLjde	 	As Character
	Local cCodCliAte 	As Character
	Local cCodLjAte	 	As Character
	Local cNSUDe	 	As Character
	Local cNSUAte	 	As Character
	Local cStPagto 	 	As Character
	Local cUserPag	 	As Character
	Local cStVend 	 	As Character
	Local cUserVen	 	As Character
	Local cNVL		 	As Character
	Local dDtCredDe	 	As Date
	Local dDtCredAte 	As Date
	Local dDtPgDe	 	As Date
	Local dDtPgAte	 	As Date
	Local dDtVenDe 	 	As Date
	Local dDtVenAte	 	As Date
	Local cTamNSU  		As Character
	Local cAliasTRB     As Character 
	
	oSection1	:= oReport:Section(1)
	oSubTot		:= oReport:Section(1):Section(1)
	oTotal		:= oReport:Section(1):Section(2)
	oBreak01	:= Nil
	aSelFil 	:= {}
	cQuery		:= ""
	cSelFil 	:= ""
	cTipo		:= ""
	cDescri   	:= ""
	cOrigem   	:= ""
	nTotReg		:= 0
	nTotGer		:= 0
	nTotBPag	:= 0
	nTotLPag	:= 0
	nTotDifPag	:= 0
	nTotBVen	:= 0
	nTotLVen	:= 0
	nTotDifVen  := 0
	nTotOpPgBr  := 0
	nTotOpPgLq  := 0
	nTotOpPgDf  := 0
	nTotOpVnBr  := 0
	nTotOpVnLq  := 0
	nTotOpVnDf  := 0
	cNVL		:= IIF(__lOracle,"NVL","ISNULL")
	cTamNSU     := Alltrim(Str(TamSX3( "FIF_NSUTEF" )[1]))

	//--------------------------------------------------
	// Precisa ativar as perguntas antes das definicoes.
	Pergunte(oReport:uParam,.F.)
	//--------------------------------------------------
	// Transforma parametros Range em expressao SQL
	// Tratamento dos parâmetros MV_PAR16 e MV_PAR20
	//--------------------------------------------------
	BuildExpr()
	//--------------------------------------------------
	
	nOperadora	:= MV_PAR01
	cBandeira	:= Iif(!Empty(Alltrim(MV_PAR02)), FormatIn(Alltrim(MV_PAR02), ";"), "")
	cAdmFinan	:= Iif(!Empty(Alltrim(MV_PAR03)), FormatIn(Alltrim(MV_PAR03), ";"), "")
	nFilraFil	:= MV_PAR04
	cCodCliDe	:= MV_PAR05
	cCodLjde	:= MV_PAR06
	cCodCliAte	:= MV_PAR07
	cCodLjAte	:= MV_PAR08
	cNSUDe		:= MV_PAR09
	cNSUAte		:= MV_PAR10
	dDtCredDe	:= Iif(MV_PAR11 = Nil , ctod("") , MV_PAR11)
	dDtCredAte	:= Iif(MV_PAR12 = Nil , ctod("") , MV_PAR12)
	cStPagto 	:= Iif(!Empty(Alltrim(MV_PAR13)), FormatIn(Alltrim(MV_PAR13), ";"), "")
	dDtPgDe		:= Iif(MV_PAR14 = Nil , ctod("") , MV_PAR14)
	dDtPgAte	:= Iif(MV_PAR15 = Nil , ctod("") , MV_PAR15)
	cUserPag	:= MV_PAR16
	cStVend 	:= Iif(!Empty(Alltrim(MV_PAR17)), FormatIn(Alltrim(MV_PAR17), ";"), "")
	dDtVenDe 	:= Iif(MV_PAR18 = Nil , ctod("") , MV_PAR18)
	dDtVenAte	:= Iif(MV_PAR19 = Nil , ctod("") , MV_PAR19)
	cUserVen	:= MV_PAR20
	nImpJustif  := MV_PAR21
	nImpConc	:= MV_PAR22
	nOrdem		:= MV_PAR23

	__lSOFEX 	:= nOperadora == 1 // Software Express

	If !Empty(cStVend) // Ajusta status para contemplar Venda com Pagamento Conciliado
		cStVend := StrTran( cStVend, "'1'", ("'1','A'") )
		cStVend := StrTran( cStVend, "'2'", ("'2','B'") )
		cStVend := StrTran( cStVend, "'3'", ("'3','C'") )
		cStVend := StrTran( cStVend, "'4'", ("'4','D'") )
		cStVend := StrTran( cStVend, "'5'", ("'5','E'") )
		cStVend := StrTran( cStVend, "'6'", ("'6','F'") )
		cStVend := StrTran( cStVend, "'7'", ("'7','G'") )
	EndIf

	//Seleciona Filiais
	If nFilraFil == 1
		aSelFil := AdmGetFil(.F., .T., "FIF")
		If Len(aSelFil) > 0
			cSelFil := FormatIn(Upper(Alltrim(ArrayToStr( aSelFil ))), ";")
		EndIf
	EndIf

	If nOrdem==1
		oBreak01 := TRBreak():New(oSection1,oSection1:Cell('MDE_DESC'), {|| STR0012 + Alltrim(cDescri) + " - " + Alltrim(cOrigem) + " - " + STR0013 + Alltrim(Str(nTotReg)) } ) //"Total por Operadora: "###"Total Registros: "
		TRFunction():New(oSection1:Cell('VLRDIF'),Nil,"SUM",oBreak01,,PesqPict("FIF","FIF_VLLIQ"),,.F.,.F.)
		TRFunction():New(oSection1:Cell('FIF_VLBRUT'),Nil,"SUM",oBreak01,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell('FIF_VLLIQ'),Nil,"SUM",oBreak01,,,,.F.,.F.)
	EndIf

	If (nImpJustif = 2)
		oSection1:Cell("CODJUS"):Disable()
		oSection1:Cell("DESJUS"):Disable()
		oSection1:Cell("DESJUT"):Disable()

		oSection1:Cell("CODJUS"):Hide()
		oSection1:Cell("DESJUS"):Hide()
		oSection1:Cell("DESJUT"):Hide()
	EndIf

	If (nImpConc = 2)
		oSection1:Cell('USRCONC'):Disable()
		oSection1:Cell('USRCONC'):Hide()

		oSection1:Cell('DTCONC'):Disable()
		oSection1:Cell('DTCONC'):Hide()
	EndIf

	oReport:SetMeter(0)
	oReport:IncMeter()

	// Query para juncao de registros TEF e Vendas
	cQuery := "SELECT
	cQuery += " FIF_FILIAL, E1_CLIENTE,E1_LOJA, E1_NOMCLI, FIF_DTTEF, E1_VALOR, E1_SALDO, FIF_VLLIQ, "
	cQuery += " FIF_NSUTEF, FIF_DTCRED, E1_BAIXA, FIF_TPPROD, FIF_VLBRUT, "
	cQuery += " MDE_CODIGO, MDE_DESC, VLRDIF, CODJUS, DESJUS, DESJUT, "
	cQuery += " DTCONC, USRCONC, FIF_CODFIL, STATUS, ORIGEM, ORDEM,"
	cQuery += " FIF_PARALF, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "
	cQuery += " FROM (

	// Query para seleçao de registro da conciliação TEF
	cQuery += "SELECT "

	cQuery += "FIF.FIF_FILIAL, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NOMCLI, FIF.FIF_DTTEF, SE1.E1_VALOR,SE1.E1_SALDO, FIF.FIF_VLLIQ, "
	cQuery += "FIF.FIF_NSUTEF, FIF.FIF_DTCRED, SE1.E1_BAIXA, FIF.FIF_TPPROD, FIF.FIF_VLBRUT, "
	cQuery += "MDE.MDE_CODIGO, MDE.MDE_DESC, (FIF_VLBRUT - FIF_VLLIQ) VLRDIF, FIF.FIF_PGJUST CODJUS, FIF.FIF_PGDES1 DESJUS, FIF.FIF_PGDES2 DESJUT, "
	cQuery += "FIF.FIF_DTPAG DTCONC, FIF.FIF_USUPAG USRCONC, FIF.FIF_CODFIL, FIF.FIF_STATUS STATUS, 'PAGAMENTO' AS ORIGEM, '2' ORDEM, "
	cQuery += "FIF.FIF_PARALF, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO "

	cQuery += "FROM " + AllTrim(RetSqlName("FIF")) + " FIF "

	cQuery += "INNER JOIN " + AllTrim(RetSqlName("MDE")) + " MDE "
	cQuery += "ON MDE_FILIAL = '"+xFilial("MDE")+"' "
	cQuery += " AND MDE_CODIGO = FIF_CODADM "
	cQuery += " AND MDE_TIPO = 'RD' "
	cQuery += " AND MDE.D_E_L_E_T_ = ' ' "

	cQuery += "LEFT JOIN " + RetSqlName("SE1") + " SE1 "
	cQuery += " ON SE1.E1_FILORIG  = FIF.FIF_CODFIL "
	cQuery += " AND SE1.E1_EMISSAO = FIF.FIF_DTTEF "
	cQuery += " AND SE1.E1_PARCELA = FIF.FIF_PARALF "

	If __lOracle .Or. __lPostGre
		cQuery += " AND LPAD(TRIM(SE1.E1_NSUTEF), "+cTamNSU+", '0') = LPAD(TRIM(FIF.FIF_NSUTEF), "+cTamNSU+", '0') "
	Else
		cQuery += " AND REPLICATE('0', "+cTamNSU+" - LEN(SE1.E1_NSUTEF)) + RTrim(SE1.E1_NSUTEF) =  REPLICATE('0', "+cTamNSU+" - LEN(FIF.FIF_NSUTEF)) + RTrim(FIF.FIF_NSUTEF) "
	Endif

	cQuery += " AND SE1.E1_TIPO IN ('CD','CC') "
	If Empty(cSelFil)
		cQuery += " AND SE1.E1_FILORIG = '" + cFilAnt + "' "
	Else
		cQuery += " AND SE1.E1_FILORIG IN " + cSelFil
	EndIf
	cQuery += "AND SE1.D_E_L_E_T_ = ' ' "

	cQuery += "LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += " ON SA1.A1_FILIAL 	= '" + FWxFilial("SA1") + "' "
	cQuery += " AND SA1.A1_COD 		= SE1.E1_CLIENTE "
	cQuery += " AND SA1.A1_LOJA  	= SE1.E1_LOJA "
	cQuery += " AND SA1.D_E_L_E_T_	= ' ' "

	cQuery += "WHERE "

	If Empty(cSelFil)
		cQuery += "FIF.FIF_CODFIL = '" + cFilAnt + "' "
	Else
		cQuery += "FIF.FIF_CODFIL IN " + cSelFil
	EndIf

	cQuery += " AND FIF.FIF_DTCRED BETWEEN '" + dtos(dDtCredDe) + "' AND '" + dtos(dDtCredAte) + "'"
	cQuery += " AND FIF.FIF_NSUTEF BETWEEN '" + cNSUDe + "' AND '" + cNSUAte + "'"

	cQuery += " AND "+cNVL+"(SE1.E1_CLIENTE, '"+Space(TAMSX3("E1_CLIENTE")[1])+"')  BETWEEN '" + cCodCliDe + "' AND '" + cCodCliAte + "' "
	cQuery += " AND "+cNVL+"(SE1.E1_LOJA, '"+Space(TAMSX3("E1_LOJA")[1])+"') BETWEEN '" + cCodLjde + "' AND '" + cCodLjAte + "' "

	If !Empty(cStPagto)
		cQuery += " AND FIF.FIF_STATUS IN " + cStPagto
	EndIf
	cQuery += " AND FIF.FIF_STATUS <> ' ' "

	If __lSOFEX
		If !Empty(cBandeira)
			cQuery += " AND FIF.FIF_CODRED IN " + cBandeira
		EndIf
	Else
		If !Empty(cAdmFinan)
			cQuery += " AND FIF.FIF_CODADM IN " + cAdmFinan
		EndIf
	EndIf

	If !Empty(dDtPgAte)
		IF AT("1",cStPagto) > 0 // Se Estiver selecionado o 1=Nao Processado
			cQuery += " AND ( FIF.FIF_DTPAG = '"+Space(TAMSX3("FIF_DTPAG")[1])+"' OR FIF.FIF_DTPAG BETWEEN '" + dtos(dDtPgDe) + "' AND '" + dtos(dDtPgAte) + "' )"
		Else
			cQuery += " AND FIF.FIF_DTPAG BETWEEN '" + dtos(dDtPgDe) + "' AND '" + dtos(dDtPgAte) + "'"
		EndIf
	EndIf

	If !Empty(cUserPag)
		IF AT("1",cStPagto) > 0 // Se Estiver selecionado o 1=Nao Processado
			cQuery += " AND ( FIF.FIF_USUPAG = '"+Space(TAMSX3("FIF_USUPAG")[1])+"' OR " + cUserPag + " ) " //FIF_USUPAG
		Else
			cQuery += " AND " + cUserPag //FIF_USUPAG
		EndIf
	EndIf

	cQuery += " AND FIF.D_E_L_E_T_ = ' ' "


	cQuery += " UNION ALL "

	// Query para seleçao de registro da conciliação Vendas
	cQuery += "SELECT "

	cQuery += "FIF.FIF_FILIAL, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NOMCLI, FIF.FIF_DTTEF, SE1.E1_VALOR,SE1.E1_SALDO, FIF.FIF_VLLIQ, "
	cQuery += "FIF.FIF_NSUTEF, FIF.FIF_DTCRED, SE1.E1_BAIXA, FIF.FIF_TPPROD, FIF.FIF_VLBRUT, "
	cQuery += "MDE.MDE_CODIGO, MDE.MDE_DESC, (FIF_VLBRUT - FIF_VLLIQ) VLRDIF, FIF.FIF_CODJUS CODJUS, FIF.FIF_DESJUS DESJUS, FIF.FIF_DESJUT DESJUT, "
	cQuery += "FIF.FIF_DTVEN DTCONC, FIF.FIF_USUVEN USRCONC, FIF.FIF_CODFIL, FIF.FIF_STVEND STATUS,'VENDAS' AS ORIGEM, '1' ORDEM,"
	cQuery += "FIF.FIF_PARALF, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO "

	cQuery += "FROM " + AllTrim(RetSqlName("FIF")) + " FIF "

	cQuery += "INNER JOIN " + AllTrim(RetSqlName("MDE")) + " MDE "
	cQuery += "ON MDE_FILIAL = '"+xFilial("MDE")+"' "
	cQuery += " AND MDE_CODIGO = FIF_CODADM "
	cQuery += " AND MDE_TIPO = 'RD' "
	cQuery += " AND MDE.D_E_L_E_T_ = ' ' "

	cQuery += "LEFT JOIN " + RetSqlName("SE1") + " SE1 "
	cQuery += " ON SE1.E1_FILORIG  = FIF.FIF_CODFIL "
	cQuery += " AND SE1.E1_EMISSAO = FIF.FIF_DTTEF "
	cQuery += " AND SE1.E1_PARCELA = FIF.FIF_PARALF "

	If __lOracle .Or. __lPostGre
		cQuery += " AND LPAD(TRIM(SE1.E1_NSUTEF), "+cTamNSU+", '0') = LPAD(TRIM(FIF.FIF_NSUTEF), "+cTamNSU+", '0') "
	Else
		cQuery += " AND REPLICATE('0', "+cTamNSU+" - LEN(SE1.E1_NSUTEF)) + RTrim(SE1.E1_NSUTEF) =  REPLICATE('0', "+cTamNSU+" - LEN(FIF.FIF_NSUTEF)) + RTrim(FIF.FIF_NSUTEF) "
	Endif

	cQuery += " AND SE1.E1_TIPO IN ('CD','CC') "
	If Empty(cSelFil)
		cQuery += " AND SE1.E1_FILORIG = '" + cFilAnt + "' "
	Else
		cQuery += " AND SE1.E1_FILORIG IN " + cSelFil
	EndIf
	cQuery += "AND SE1.D_E_L_E_T_ = ' ' "

	cQuery += "LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += " ON SA1.A1_FILIAL 	= '" + FWxFilial("SA1") + "' "
	cQuery += "	AND SA1.A1_COD 	= SE1.E1_CLIENTE "
	cQuery += " AND SA1.A1_LOJA  	= SE1.E1_LOJA "
	cQuery += " AND SA1.D_E_L_E_T_	= ' ' "

	cQuery += "WHERE "

	If Empty(cSelFil)
		cQuery += "FIF.FIF_CODFIL = '" + cFilAnt + "' "
	Else
		cQuery += "FIF.FIF_CODFIL IN " + cSelFil
	EndIf

	cQuery += " AND FIF.FIF_DTCRED BETWEEN '" + dtos(dDtCredDe) + "' AND '" + dtos(dDtCredAte) + "'"
	cQuery += " AND FIF.FIF_NSUTEF BETWEEN '" + cNSUDe + "' AND '" + cNSUAte + "'"

	cQuery += " AND "+cNVL+"(SE1.E1_CLIENTE, '"+Space(TAMSX3("E1_CLIENTE")[1])+"') BETWEEN '" + cCodCliDe + "' AND '" + cCodCliAte + "' "
	cQuery += " AND "+cNVL+"(SE1.E1_LOJA, '"+Space(TAMSX3("E1_LOJA")[1])+"') BETWEEN '" + cCodLjde + "' AND '" + cCodLjAte + "' "

	If !Empty(cStVend)
		cQuery += " AND FIF.FIF_STVEND IN " + cStVend
	EndIf
	cQuery += " AND FIF.FIF_STVEND <> ' ' "

	If __lSOFEX
		If !Empty(cBandeira)
			cQuery += " AND FIF.FIF_CODRED IN " + cBandeira
		EndIf
	Else
		If !Empty(cAdmFinan)
			cQuery += " AND FIF.FIF_CODADM IN " + cAdmFinan
		EndIf
	EndIf

	If !Empty(dDtVenAte)
		IF AT("1",cStVend) > 0 // Se Estiver selecionado o 1=Nao Processado
			cQuery += " AND ( FIF.FIF_DTVEN = '"+Space(TAMSX3("FIF_DTVEN")[1])+"' OR FIF.FIF_DTVEN BETWEEN '" + dtos(dDtVenDe) + "' AND '" + dtos(dDtVenAte) + "' )"
		Else
			cQuery += " AND FIF.FIF_DTVEN BETWEEN '" + dtos(dDtVenDe) + "' AND '" + dtos(dDtVenAte) + "'"
		EndIf
	EndIf

	If !Empty(cUserVen)
		IF AT("1",cStVend) > 0 // Se Estiver selecionado o 1=Nao Processado
			cQuery += " AND (FIF.FIF_USUVEN = '"+Space(TAMSX3("FIF_USUVEN")[1])+"' OR " + cUserVen + ")" // FIF_USUVEN
		Else
			cQuery += " AND " + cUserVen // FIF_USUVEN
		EndIf
	EndIf

	cQuery += " AND FIF.D_E_L_E_T_ = ' ' "

	cQuery += " ) CONC "

	If nOrdem == 1
		cQuery += " ORDER BY MDE_DESC, ORDEM, FIF_CODFIL, FIF_NSUTEF, FIF_DTCRED, FIF_PARALF, E1_CLIENTE, E1_LOJA "
	Else
		cQuery += " ORDER BY MDE_DESC, FIF_CODFIL, FIF_NSUTEF, FIF_DTCRED, FIF_PARALF, ORDEM, E1_CLIENTE, E1_LOJA "
	EndIf

	cQuery := ChangeQuery(cQuery)
	cAliasTRB := GetNextAlias() 

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTRB, .F., .T.)

	TCSetField( cAliasTRB, "FIF_VLBRUT"	, TamSX3( "FIF_VLBRUT" )[3]	, TamSX3( "FIF_VLBRUT" )[1]	, TamSX3( "FIF_VLBRUT"  )[2] )
	TCSetField( cAliasTRB, "FIF_VLLIQ" 	, TamSX3( "FIF_VLLIQ" )[3]	, TamSX3( "FIF_VLLIQ" )[1] 	, TamSX3( "FIF_VLLIQ"  )[2] )
	TCSetField( cAliasTRB, "VLRDIF"		, TamSX3( "FIF_VLLIQ" )[3]	, TamSX3( "FIF_VLLIQ" )[1] 	, TamSX3( "FIF_VLLIQ"  )[2] )
	TCSetField( cAliasTRB, "FIF_DTTEF"	, TamSX3( "FIF_DTTEF" )[3]	, TamSX3( "FIF_DTTEF" )[1] 	, TamSX3( "FIF_DTTEF"  )[2] )
	TCSetField( cAliasTRB, "FIF_DTCRED"	, TamSX3( "FIF_DTCRED" )[3]	, TamSX3( "FIF_DTCRED" )[1] , TamSX3( "FIF_DTCRED"  )[2] )
	TCSetField( cAliasTRB, "E1_BAIXA"	, TamSX3( "E1_BAIXA" )[3]	, TamSX3( "E1_BAIXA" )[1] 	, TamSX3( "E1_BAIXA" )[2] )
	TCSetField( cAliasTRB, "DTCONC"		, TamSX3( "FIF_DTPAG" )[3]	, TamSX3( "FIF_DTPAG" )[1] 	, TamSX3( "FIF_DTPAG" )[2] )

	Do While (cAliasTRB)->(!Eof())

		If !Empty((cAliasTRB)->FIF_TPPROD) .and. (cAliasTRB)->FIF_TPPROD == 'C'
			cTipo := STR0014 //Crédito
		ElseIf !Empty((cAliasTRB)->FIF_TPPROD) .and. (cAliasTRB)->FIF_TPPROD == 'D'
			cTipo :=  STR0015 //"Débito"
		EndIf

		If Empty(cDescri)
			cDescri := (cAliasTRB)->MDE_DESC
			cOrigem := (cAliasTRB)->ORIGEM
		Else
			If (cAliasTRB)->MDE_DESC <> cDescri .Or. Iif(nOrdem==1, (cOrigem <> (cAliasTRB)->ORIGEM), .F.)
				oSection1:Finish()

				If nOrdem == 2
					oSubTot:Cell("TXTTOTAL"):SetBlock({|| STR0012 + Alltrim(cDescri) + " - " + STR0013 + Alltrim(Str(nTotReg)) }) //"Total por Operadora: "###"Total Registros: "
					oSubTot:Cell("VLBRUTVEN"):SetBlock({||nTotOpVnBr })
					oSubTot:Cell("VLLIQVEN"):SetBlock({||nTotOpVnLq })
					oSubTot:Cell("VLRDIFVEN"):SetBlock({|| Trans(nTotOpVnDf, PesqPict("FIF", "FIF_VLLIQ"))})
					oSubTot:Cell("VLBRUTPAG"):SetBlock({||nTotOpPgBr })
					oSubTot:Cell("VLLIQPAG"):SetBlock({||nTotOpPgLq })
					oSubTot:Cell("VLRDIFPAG"):SetBlock({|| Trans(nTotOpPgDf, PesqPict("FIF", "FIF_VLLIQ"))})

					oSubTot:Cell("TXTTOTAL"):SetHeaderAlign("RIGHT")
					oSubTot:Cell("VLBRUTVEN"):SetHeaderAlign("RIGHT")
					oSubTot:Cell("VLLIQVEN"):SetHeaderAlign("RIGHT")
					oSubTot:Cell("VLRDIFVEN"):SetHeaderAlign("RIGHT")
					oSubTot:Cell("VLBRUTPAG"):SetHeaderAlign("RIGHT")
					oSubTot:Cell("VLLIQPAG"):SetHeaderAlign("RIGHT")
					oSubTot:Cell("VLRDIFPAG"):SetHeaderAlign("RIGHT")
					oSubTot:Init()
					oSubTot:PrintLine()
					oSubTot:Finish()
					nTotOpPgBr := 0
					nTotOpPgLq := 0
					nTotOpPgDf := 0
					nTotOpVnBr := 0
					nTotOpVnLq := 0
					nTotOpVnDf := 0
				EndIf

				oReport:IncMeter()
				cDescri := (cAliasTRB)->MDE_DESC
				cOrigem := (cAliasTRB)->ORIGEM
				nTotReg := 0
			EndIF
		EndIf

		nTotGer++
		nTotReg++

		If (cAliasTRB)->ORIGEM == "PAGAMENTO"
			nTotBPag += (cAliasTRB)->FIF_VLBRUT
			nTotLPag += (cAliasTRB)->FIF_VLLIQ
			nTotDifPag += (cAliasTRB)->VLRDIF
			If nOrdem == 2
				nTotOpPgBr += (cAliasTRB)->FIF_VLBRUT
				nTotOpPgLq += (cAliasTRB)->FIF_VLLIQ
				nTotOpPgDf += (cAliasTRB)->VLRDIF
			EndIf
		Else
			nTotBVen += (cAliasTRB)->FIF_VLBRUT
			nTotLVen += (cAliasTRB)->FIF_VLLIQ
			nTotDifVen += (cAliasTRB)->VLRDIF
			If nOrdem == 2
				nTotOpVnBr += (cAliasTRB)->FIF_VLBRUT
				nTotOpVnLq += (cAliasTRB)->FIF_VLLIQ
				nTotOpVnDf += (cAliasTRB)->VLRDIF
			EndIf
		EndIf

		oSection1:Init()
		oSection1:Cell("ORIGEM"):SetValue((cAliasTRB)->ORIGEM)	//Conciliação
		oSection1:Cell("STATUS"):SetValue( GetSTSDesc(Alltrim((cAliasTRB)->STATUS), Iif((cAliasTRB)->ORIGEM = "PAGAMENTO", 1, 2) ) ) //Tipo de Registro
		oSection1:Cell("FIF_CODFIL"):SetValue(Alltrim((cAliasTRB)->FIF_CODFIL) + " - " + Alltrim(FWFilialName(,(cAliasTRB)->FIF_CODFIL)))			//Filial+Descrição
		oSection1:Cell("E1_CLIENTE"):SetValue((cAliasTRB)->E1_CLIENTE)			//Codigo de Cliente
		oSection1:Cell("E1_LOJA"):SetValue((cAliasTRB)->E1_LOJA)					//Codigo de Loja
		oSection1:Cell("E1_NOMCLI"):SetValue((cAliasTRB)->E1_NOMCLI)				//Nome do Cliente
		oSection1:Cell("FIF_NSUTEF"):SetValue((cAliasTRB)->FIF_NSUTEF)			//Num NSUTEF
		oSection1:Cell("FIF_DTTEF"):SetValue((cAliasTRB)->FIF_DTTEF)				//Data de TEF
		oSection1:Cell("FIF_DTCRED"):SetValue((cAliasTRB)->FIF_DTCRED)			//Data de Credito
		oSection1:Cell("FIF_PARALF"):SetValue((cAliasTRB)->FIF_PARALF)			//Parcela FIF
		oSection1:Cell("E1_PREFIXO"):SetValue((cAliasTRB)->E1_PREFIXO)			//Prefixo título
		oSection1:Cell("E1_NUM"):SetValue((cAliasTRB)->E1_NUM)					//Número Título
		oSection1:Cell("E1_PARCELA"):SetValue((cAliasTRB)->E1_PARCELA)			//Parcela
		oSection1:Cell("E1_TIPO"):SetValue((cAliasTRB)->E1_TIPO)					//Tipo
		oSection1:Cell("E1_BAIXA"):SetValue((cAliasTRB)->E1_BAIXA)				//Data de Baixa
		oSection1:Cell("FIF_TPPROD"):SetValue(cTipo)						//Tipo de Titulo --Credito ou Debito
		oSection1:Cell("FIF_VLBRUT"):SetValue((cAliasTRB)->FIF_VLBRUT)			//Valor Bruto
		oSection1:Cell("FIF_VLLIQ"):SetValue((cAliasTRB)->FIF_VLLIQ)				//Valor Liquido
		oSection1:Cell("VLRDIF"):SetValue((cAliasTRB)->VLRDIF)					//Valor de Diferença

		If (nImpJustif = 1)
			oSection1:Cell("CODJUS"):SetValue((cAliasTRB)->CODJUS)				//Codigo da Justificativa
			oSection1:Cell("DESJUS"):SetValue(Alltrim((cAliasTRB)->DESJUS))		//Descrição da Justificativa
			oSection1:Cell("DESJUT"):SetValue(Alltrim((cAliasTRB)->DESJUT))		//Justificativa
		EndIF

		If (nImpConc = 1)
			oSection1:Cell("USRCONC"):SetValue(UsrRetName((cAliasTRB)->USRCONC) )	//Usuario Conciliador
			oSection1:Cell("DTCONC"):SetValue(DTOC((cAliasTRB)->DTCONC))				//Data Conciliacao
		EndIF

		oSection1:SetLineBreak(.T.)
		oSection1:Printline()

		(cAliasTRB)->(dbSkip())
	Enddo

	(cAliasTRB)->(DbCloseArea())

	oSection1:Finish()

	If nOrdem == 2

		oSubTot:Cell("TXTTOTAL"):SetBlock({|| STR0012 + Alltrim(cDescri) + " - " + STR0013 + Alltrim(Str(nTotReg)) }) //"Total por Operadora: "###"Total Registros: "
		oSubTot:Cell("VLBRUTVEN"):SetBlock({||nTotOpVnBr })
		oSubTot:Cell("VLLIQVEN"):SetBlock({||nTotOpVnLq })
		oSubTot:Cell("VLRDIFVEN"):SetBlock({|| Trans(nTotOpVnDf, PesqPict("FIF", "FIF_VLLIQ"))})
		oSubTot:Cell("VLBRUTPAG"):SetBlock({||nTotOpPgBr })
		oSubTot:Cell("VLLIQPAG"):SetBlock({||nTotOpPgLq })
		oSubTot:Cell("VLRDIFPAG"):SetBlock({|| Trans(nTotOpPgDf, PesqPict("FIF", "FIF_VLLIQ"))})

		oSubTot:Cell("TXTTOTAL"):SetHeaderAlign("RIGHT")
		oSubTot:Cell("VLBRUTVEN"):SetHeaderAlign("RIGHT")
		oSubTot:Cell("VLLIQVEN"):SetHeaderAlign("RIGHT")
		oSubTot:Cell("VLRDIFVEN"):SetHeaderAlign("RIGHT")
		oSubTot:Cell("VLBRUTPAG"):SetHeaderAlign("RIGHT")
		oSubTot:Cell("VLLIQPAG"):SetHeaderAlign("RIGHT")
		oSubTot:Cell("VLRDIFPAG"):SetHeaderAlign("RIGHT")
		oSubTot:Init()
		oSubTot:PrintLine()
		oSubTot:Finish()
	EndIf

	oTotal:Cell("TXTTOTAL"):SetBlock({|| STR0016 + Alltrim(Str(nTotGer) )}) //"Total Geral Registros: "
	oTotal:Cell("VLBRUTVEN"):SetBlock({||nTotBVen })
	oTotal:Cell("VLLIQVEN"):SetBlock({||nTotLVen })
	oTotal:Cell("VLRDIFVEN"):SetBlock({|| Trans(nTotDifVen, PesqPict("FIF", "FIF_VLLIQ"))})
	oTotal:Cell("VLBRUTPAG"):SetBlock({||nTotBPag })
	oTotal:Cell("VLLIQPAG"):SetBlock({||nTotLPag })
	oTotal:Cell("VLRDIFPAG"):SetBlock({|| Trans(nTotDifPag, PesqPict("FIF", "FIF_VLLIQ"))})

	oTotal:Cell("TXTTOTAL"):SetHeaderAlign("RIGHT")
	oTotal:Cell("VLBRUTVEN"):SetHeaderAlign("RIGHT")
	oTotal:Cell("VLLIQVEN"):SetHeaderAlign("RIGHT")
	oTotal:Cell("VLRDIFVEN"):SetHeaderAlign("RIGHT")
	oTotal:Cell("VLBRUTPAG"):SetHeaderAlign("RIGHT")
	oTotal:Cell("VLLIQPAG"):SetHeaderAlign("RIGHT")
	oTotal:Cell("VLRDIFPAG"):SetHeaderAlign("RIGHT")

	oReport:SkipLine(4)
	oTotal:Init()
	oTotal:PrintLine()

	oTotal:Finish()

	Return

	//-------------------------------------------------------------------
	/*/ {Protheus.doc} F916STS
	Funcao utilizada no item Tipo do Pergunte FINR916

	@author Danilo Santos
	@since 15/05/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------

Function FR916STS(nOpc As Numeric) As Logical

	Local cMvRet   As Character
	Local cMVSitua As Character
	Local nIt	   As Numeric
	Local nX	   As Numeric
	Local aSitua   As Array
	Local aMvPar   As Array

	Default nOpc := 1

	cMvRet    	:= Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	cMVSitua	:= ""
	nIt		   	:= 8
	nX			:= 0
	aSitua 		:= {}
	aMvPar 		:= {}

	CursorWait()

	// Preenche array de status para o f_Opcoes
	GetSTSDesc("", nOpc, @aSitua)

	CursorArrow()
	/*
	// Executa f_Opcoes para Selecionar ou Mostrar os Registros Selecionados
	@uVarRet    ,;    //Variavel de Retorno
	cTitulo     ,;    //Titulo da Coluna com as opcoes
	@aOpcoes    ,;    //Opcoes de Escolha (Array de Opcoes)
	@cOpcoes    ,;    //String de Opcoes para Retorno
	NIL         ,;    //Nao Utilizado
	NIL         ,;    //Nao Utilizado
	.F.         ,;    //Se a Selecao sera de apenas 1 Elemento por vez
	nTamKey     ,;    //Tamanho da Chave
	nElemRet    ,;    //No maximo de elementos na variavel de retorno
	.T.         ,;    //Inclui Botoes para Selecao de Multiplos Itens
	.F.         ,;    //Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
	NIL         ,;    //Qual o Campo para a Montagem do aOpcoes
	.F.         ,;    //Nao Permite a Ordenacao
	.F.         ,;    //Nao Permite a Pesquisa
	.F.         ,;    //Forca o Retorno Como Array
	cF3          ;    //Consulta F3
	*/
	IF f_Opcoes(@aMvPar,STR0017,@aSitua,"",Nil,Nil,.F.,1,nIt,.T.,.F.,NIl,.T.,.T.,.T.,Nil) //"Status do Titulo"
		For nX := 1 to Len( aMvPar )
			cMVSitua += Substr(aMvPar[nX],1,1) + ";"
		Next
		&cMvRet := SUBSTR(cMVSitua,1,RAT(";",cMVSitua)-1)
	EndIf

	GetdRefresh()

	Return .T.


	//-------------------------------------------------------------------
	/*/ {Protheus.doc} GetSTSDesc
	Retorna Descrição do Status

	@author Marcelo Ferreira
	@since 27/07/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------

Static Function GetSTSDesc(cStatus As Character, nOpc As Numeric, aStatus As Array)  As Character

	Local cRet As Character
	Local aRet As Array
	Local nPos As Numeric
	Local nX   AS Numeric

	Default cStatus := ""
	Default nOpc	:= 1
	Default aStatus	:= {}

	cRet := ""
	aRet := {}
	nPos := 0
	nX	 := 0

	If nOpc == 1 // Status Conciliação TEF
		AAdd(aRet,{"1", STR0018}) //"Não Processado"
		AAdd(aRet,{"2", STR0019}) //"Conciliado Normal"
		AAdd(aRet,{"3", STR0020}) //"Divergentes"
		AAdd(aRet,{"4", STR0021}) //"Conciliado Manual"
		AAdd(aRet,{"5", STR0022}) //"Descartado"
		AAdd(aRet,{"6", STR0023}) //"Ant. Nao Processada"
		AAdd(aRet,{"7", STR0024}) //"Antecipado"
	ElseIf nOpc == 2 // Status Conciliação Vendas
		AAdd(aRet,{"1", STR0018}) //"Não Processado"
		AAdd(aRet,{"2", STR0025}) //"Conciliados"
		AAdd(aRet,{"3", STR0026}) //"Conc. Parc."
		AAdd(aRet,{"4", STR0020}) //"Divergentes"
		AAdd(aRet,{"5", STR0027}) //"Venda Conc. com Crítica"
		AAdd(aRet,{"6", STR0028}) //"Tit. s/ Venda"
		AAdd(aRet,{"7", STR0029}) //"Venda s/ TÍtulo"
	EndIf

	If !Empty(cStatus)
		If cStatus $ "A/B/C/D/E/F/G" // X-Venda com Pagamento Conciliado
			cStatus := F920aStVen( cStatus, .T.)			
		EndIf
		If (nPos := aScan(aRet, {|x| x[1] == cStatus})) > 0
			cRet := aRet[nPos][2]
		EndIf
	Else
		For nX := 1 to Len(aRet)
			AAdd(aStatus, ( aRet[nX][1] + " - " + aRet[nX][2] ) )
		Next nX
	EndIf

	Return cRet

// --------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BuildExpr
Controla a montagem de expressão SQL para os parâmetros MV_PAR16 e MV_PAR20.

@author Norberto M de Melo
@since 12/08/2021
@version 01
@return 
/*/
STATIC Function BuildExpr()
LOCAL oPergunte := NIL

	oPergunte := FwSx1Util():New()
	oPergunte:AddGroup("FINR916")
	oPergunte:SearchGroup()

	IF !EMPTY(oPergunte) .AND. LEN(oPergunte:GetGroup("FINR916")[2]) >= 20
		IF oPergunte:GetGroup("FINR916")[2][16]:CX1_GSC == 'R'
			MV_PAR16 := RangeExpr(MV_PAR16,'FIF.FIF_USUPAG',oPergunte:GetGroup("FINR916")[2][16]:CX1_TIPO)
		ENDIF
		IF oPergunte:GetGroup("FINR916")[2][20]:CX1_GSC == 'R'
			MV_PAR20 := RangeExpr(MV_PAR20,'FIF.FIF_USUVEN',oPergunte:GetGroup("FINR916")[2][20]:CX1_TIPO)
		ENDIF
	ENDIF

	FwFreeObj(oPergunte)
	oPergunte := NIL
RETURN

/*/{Protheus.doc} RangeExpr
Monta expressão SQL para os parâmetros MV_PAR16 e MV_PAR20.

@author Norberto M de Melo
@since 12/08/2021
@version 01
@return 
*/
STATIC FUNCTION RangeExpr(cRange AS CHARACTER, cExp AS CHARACTER, cType AS CHARACTER, nCpoSize AS NUMERIC) AS CHARACTER
LOCAL cRet AS CHARACTER
LOCAL aRange AS ARRAY
LOCAL cExpIn AS CHARACTER
LOCAL cChar AS CHARACTER
LOCAL cExp1 AS CHARACTER
LOCAL cExp2 AS CHARACTER
LOCAL nI AS NUMERIC

DEFAULT cExp := ''
DEFAULT cType := "C"
DEFAULT nCpoSize := 0

	aRange := StrTokArr(cRange,";")
	cRet := ""
	cExpIn := ""
	cChar := IF(cType $ "CD","'","")
	cExp1 := ''
	cExp2 := ''
	nI := 0
	cExp := ALLTRIM(cExp)

	IF SUBSTR(cExp,1,1) == "&"
		cExp := &(SUBSTR(cExp,2))
	ENDIF

	FOR nI := 1 TO LEN(aRange)
		If !EMPTY(aRange[ni])
			aRange[ni] := TRIM(aRange[ni])
		
			aRange[ni] := VldHifen(aRange[ni], .T.)
		
			nAt := AT("-",aRange[ni])
			IF nAt > 0
				cExp1 := SUBSTR(aRange[ni],1,nAt-1) 
				cExp1 := VldHifen(cExp1, .F.)
				
				cExp2 := Subs(aRange[ni],nAt+1)
				cExp2 := VldHifen(cExp2, .F.) 
		
				IF cType == "D"
					cExp1 := Dtos(Ctod(cExp1))
					cExp2 := Dtos(Ctod(cExp2))
				ELSEIF nCpoSize > 0
					cExp1 := PadR(cExp1+Space(nCpoSize),nCpoSize)
					cExp2 := PadR(cExp2+Space(nCpoSize),nCpoSize)
				ENDIF
		
				IF !EMPTY(cRet)
					cRet += " OR "
				ENDIF

				cRet += cExp + " BETWEEN " + cChar + cExp1 + cChar + " AND " + cChar + cExp2 + cChar
			ELSE
				IF !EMPTY(cExpIn)
					cExpIn += ","
				ENDIF
		
				IF nCpoSize > 0
					cExp1 := PADR(aRange[ni]+SPACE(nCpoSize),nCpoSize)
				ELSE
					cExp1 := aRange[ni]
				ENDIF
		
				IF cType == "D"
					cExp1 := DTOS(CTOD(cExp1))
				ENDIF
		
				// Retira a substituição do caracter "-", que foi utilizada para
				// montar a expressão
				cExp1 := VldHifen(cExp1, .F.)
		
				cExpIn += cChar + cExp1 + cChar
			ENDIF
		ENDIF
	NEXT nI

	IF !EMPTY(cExpIn)
		If !EMPTY(cRet)
			cRet += " OR "
		EndIf
		cRet += cExp + " IN(" + cExpIn + ")"
	ENDIF

	IF !empty(cRet)
		cRet := "("+cRet+")
	ENDIF

RETURN cRet

/*/{Protheus.doc} VldHifen
Auxiliar no tratamento expressões

@author Norberto M de Melo
@since 12/08/2021
@version 01
@return 
*/
STATIC FUNCTION VldHifen(cExp AS CHARACTER, lConvert AS LOGICAL) AS CHARACTER
LOCAL cRet AS CHARACTER
LOCAL cChar AS CHARACTER
LOCAL lTransf AS LOGICAL
LOCAL nI AS NUMERIC

	cChar := ""
	cRet := ""
	lTransf := .F.
	nI := 0

	IF lConvert
		FOR nI := 1 TO LEN(cExp)
			cChar := SUBSTR(cExp, nI, 1)
			IF cChar == "'"
				lTransf := !lTransf
			ELSE
				IF cChar == "-" .AND. lTransf
					cRet += "*@*"
				ELSE
					cRet += cChar
				ENDIF
			ENDIF
		NEXT nI
	ELSE
		cRet := STRTRAN(cExp, "*@*", "-")
	ENDIF

RETURN cRet
