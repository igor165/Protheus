#include 'protheus.ch'
#include 'parmtype.ch'
#include 'GTPR421A.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR421A
Relatório de Impressão da Ficha de Remessa.
Com seguintes Sections:
1- Cabeçalho da Ficha de Remessa.
2- 

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 21/08/2017
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Function GTPR421A()

Private oReport

	oReport := ReportDef()
	oReport:PrintDialog()
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RptDef
Definições do Relatório de Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 21/08/2017
@version 1.0

@type function
/*/
//-------------------------------------------------------------------

Static Function ReportDef()
Local oReport   := Nil
Local oBreak    := Nil
Local oSection := Nil
	
	oReport := TReport():New("GTPR421A", STR0001, /* cPerg */,{|oReport| ReportPrint(oReport)}, STR0001) //"Relatório de Ficha de Remessa"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
	oReport:SetPortrait()   
			
	oSection1:= TRSection():New(oReport, STR0002, {"G6X"}, , .F., .T.) //"Ficha de Remessa"
	oSection1:SetAutoSize()
	oSection1:lHeaderVisible := .T. 
	
	TRCell():New(oSection1,"G6X_AGENCI"  ,"G6X", STR0003   ,X3Picture("G6X_AGENCI")	  ,TamSX3("G6X_AGENCI")[1]+1 ) //"Agencia"
	TRCell():New(oSection1,"NOMEAGENCIA" ,"G6X", STR0004   ,X3Picture("G6X_DESCAG")	  ,TamSX3("G6X_DESCAG")[1]+1 ) //"Nome Agencia"
	TRCell():New(oSection1,"G6X_DTINI"	,"G6X",  STR0005   ,X3Picture("G6X_DTINI")	  ,TamSX3("G6X_DTINI")[1]+1  ) //"Dt. Inicial"
	TRCell():New(oSection1,"G6X_DTFIN"	,"G6X",  STR0006   ,X3Picture("G6X_DTFIN")      ,TamSX3("G6X_DTFIN")[1]+1  ) //"Dt. Final"
	TRCell():New(oSection1,"G6X_NUMFCH"	,"G6X",  STR0007   ,X3Picture("G6X_NUMFCH")     ,TamSX3("G6X_NUMFCH")[1]+1 ) //"Ficha Remessa"
	TRCell():New(oSection1,"G6X_VLRREI"	,"G6X",  STR0008   ,X3Picture("G6X_VLRREI")     ,TamSX3("G6X_VLRREI")[1]+1 ) //"Total Receita"
	TRCell():New(oSection1,"G6X_VLRDES"	,"G6X",  STR0009   ,X3Picture("G6X_VLRDES")     ,TamSX3("G6X_VLRDES")[1]+1 ) //"Total Despesa"
	TRCell():New(oSection1,"G6X_VLRLIQ"	,"G6X",  STR0010   ,X3Picture("G6X_VLRLIQ")     ,TamSX3("G6X_VLRLIQ")[1]+1 ) //"Rem. Liquida"
	TRCell():New(oSection1,"G6X_VLTODE"	,"G6X",  STR0011   ,X3Picture("G6X_VLTODE")     ,TamSX3("G6X_VLTODE")[1]+1 ) //"Tot. Deposito"
	TRCell():New(oSection1,"G6X_STATUS"	,"G6X",  STR0012   ,X3Picture("G6X_STATUS")     ,TamSX3("G6X_STATUS")[1]+1 ) //"Status"
	
	TRFunction():New(oSection1:Cell("G6X_VLRREI") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection1:Cell("G6X_VLRDES") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection1:Cell("G6X_VLRLIQ") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection1:Cell("G6X_VLTODE") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)	
	oSection1:SetLeftMargin(5)	
	oSection1:SetTotalInLine(.F.)
	
	oSection2:= TRSection():New(oSection1, STR0013, {"GZF"}, , .F., .T.) //"Totais"
	oSection2:SetAutoSize()
	oSection2:lHeaderVisible := .T. 

	TRCell():New(oSection2,"GZF_TPPASS"  ,"GZF", STR0048 ,X3Picture("GZF_TPPASS")	 ,TamSX3("GZF_TPPASS")[1]+1 ) //"Tp. Passagem"
	TRCell():New(oSection2,"GZF_LOCORI"  ,"GZF", STR0014 ,X3Picture("GZF_LOCORI")	 ,TamSX3("GZF_LOCORI")[1]+1 ) //"Loc. Origem"
	TRCell():New(oSection2,"GZF_QUANT"	 ,"GZF", STR0015 ,X3Picture("GZF_QUANT")	 ,TamSX3("GZF_QUANT")[1]+1  ) //"Quantidade"
	TRCell():New(oSection2,"GZF_TARIFA"	 ,"GZF", STR0016 ,X3Picture("GZF_TARIFA")    ,TamSX3("GZF_TARIFA")[1]+1  ) //"Tarifa"
	TRCell():New(oSection2,"GZF_TXEMB"	 ,"GZF", STR0017 ,X3Picture("GZF_TXEMB")     ,TamSX3("GZF_TXEMB")[1]+1 ) //"Tx. Embarque"
	TRCell():New(oSection2,"GZF_PEDAGI"	 ,"GZF", STR0018 ,X3Picture("GZF_PEDAGI")    ,TamSX3("GZF_PEDAGI")[1]+1 ) //"Pedagio"
	TRCell():New(oSection2,"GZF_SEGURO"	 ,"GZF", STR0019 ,X3Picture("GZF_SEGURO")    ,TamSX3("GZF_SEGURO")[1]+1 ) //"Seguro"
	TRCell():New(oSection2,"GZF_OUTROS"	 ,"GZF", STR0020 ,X3Picture("GZF_OUTROS")    ,TamSX3("GZF_OUTROS")[1]+1 ) //"Outros"
	TRCell():New(oSection2,"GZF_TOTAL"	 ,"GZF", STR0021 ,X3Picture("G6X_VLTODE")    ,TamSX3("GZF_TOTAL ")[1]+1 ) //"Total"
	
	TRFunction():New(oSection2:Cell("GZF_QUANT") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("GZF_TARIFA") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("GZF_TXEMB") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("GZF_PEDAGI"),,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("GZF_SEGURO") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("GZF_OUTROS"),,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("GZF_TOTAL") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
		
	oSection2:SetLeftMargin(5)	
	oSection2:SetTotalInLine(.F.)
	
	oSection3:= TRSection():New(oSection1, STR0022, {"GZG"}, , .F., .T.) //"Valores Adicionais Receitas"
	oSection3:SetAutoSize()
	oSection3:lHeaderVisible := .T. 

	TRCell():New(oSection3,"GZG_COD"    ,"GZG", STR0023 ,X3Picture("GZG_COD")	 ,TamSX3("GZG_COD")[1]+1 ) //"Código"
	TRCell():New(oSection3,"GZG_TIPO"   ,"GZG", STR0024 ,X3Picture("GZG_TIPO")	 ,TamSX3("GZG_TIPO")[1]+1 ) //"Tipo"
	TRCell():New(oSection3,"GZG_DESCRI"	,"GZG", STR0025 ,X3Picture("GZG_DESCRI") ,TamSX3("GZG_DESCRI")[1]+1  ) //"Descricao"
	TRCell():New(oSection3,"GZG_VALOR"	,"GZG", STR0026 ,X3Picture("GZG_VALOR")  ,TamSX3("GZG_VALOR")[1]+1  ) //"Valor"
	
	TRFunction():New(oSection3:Cell("GZG_VALOR") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
		
	oSection3:SetLeftMargin(5)	
	oSection3:SetTotalInLine(.F.)
	
	
	oSection3B:= TRSection():New(oSection1, STR0027, {"GZG"}, , .F., .T.) //"Valores Adicionais Despesas"
	oSection3B:SetAutoSize()
	oSection3B:lHeaderVisible := .T. 

	TRCell():New(oSection3B,"GZG_COD"     ,"GZG", STR0023 ,X3Picture("GZG_COD")	   ,TamSX3("GZG_COD")[1]+1 ) //"Código"
	TRCell():New(oSection3B,"GZG_TIPO"    ,"GZG", STR0024 ,X3Picture("GZG_TIPO")   ,TamSX3("GZG_TIPO")[1]+1 ) //"Tipo"
	TRCell():New(oSection3B,"GZG_DESCRI"  ,"GZG", STR0025 ,X3Picture("GZG_DESCRI") ,TamSX3("GZG_DESCRI")[1]+1  ) //"Descricao"
	TRCell():New(oSection3B, "GZG_VALOR" ,"GZG", STR0026 ,X3Picture("GZG_VALOR")  ,TamSX3("GZG_VALOR")[1]+1  ) //"Valor"
	
	TRFunction():New(oSection3B:Cell("GZG_VALOR") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
		
	oSection3B:SetLeftMargin(5)	
	oSection3B:SetTotalInLine(.F.)
	oSection3C:= TRSection():New(oSection1, STR0027, {"GZG"}, , .F., .T.) //"Valores Adicionais Receitas/Despesas"
	oSection3C:SetAutoSize()
	oSection3C:lHeaderVisible := .T. 

	TRCell():New(oSection3B,"GZG_COD"     ,"GZG", STR0023 ,X3Picture("GZG_COD")	   ,TamSX3("GZG_COD")[1]+1 ) //"Código"
	TRCell():New(oSection3B,"GZG_TIPO"    ,"GZG", STR0024 ,X3Picture("GZG_TIPO")   ,TamSX3("GZG_TIPO")[1]+1 ) //"Tipo"
	TRCell():New(oSection3B,"GZG_DESCRI"  ,"GZG", STR0025 ,X3Picture("GZG_DESCRI") ,TamSX3("GZG_DESCRI")[1]+1  ) //"Descricao"
	TRCell():New(oSection3B, "GZG_VALOR" ,"GZG", STR0026 ,X3Picture("GZG_VALOR")  ,TamSX3("GZG_VALOR")[1]+1  ) //"Valor"

	oSection4:= TRSection():New(oSection1, STR0049, {"GZE"}, , .F., .T.) //"Depositos"
	oSection4:SetAutoSize()
	oSection4:lHeaderVisible := .T. 

	TRCell():New(oSection4,"GZE_TPDEPO" ,"GZE", STR0028  ,X3Picture("GZE_TPDEPO")	 ,TamSX3("GZE_TPDEPO")[1]+1 ) //"Tp. Deposito"
	TRCell():New(oSection4,"GZE_IDDEPO" ,"GZE", STR0029  ,X3Picture("GZE_IDDEPO")	 ,TamSX3("GZE_IDDEPO")[1]+1 ) //"ID Deposito"
	TRCell():New(oSection4,"GZE_CODBCO"	,"GZE", STR0030  ,X3Picture("GZE_CODBCO")	 ,TamSX3("GZE_CODBCO")[1]+1  )//"Banco"
	TRCell():New(oSection4,"GZE_AGEBCO"	,"GZE", STR0031  ,X3Picture("GZE_AGEBCO")     ,TamSX3("GZE_AGEBCO")[1]+1  ) //"Agencia"
	TRCell():New(oSection4,"GZE_CTABCO"	,"GZE", STR0032  ,X3Picture("GZE_CTABCO")     ,TamSX3("GZE_CTABCO")[1]+1 ) //"Conta Corrente"
	TRCell():New(oSection4,"GZE_VLRDEP"	,"GZE", STR0033 ,X3Picture("GZE_VLRDEP")     ,TamSX3("GZE_VLRDEP")[1]+1 )  //"Vlr Deposito"
	TRCell():New(oSection4,"GZE_DTDEPO"	,"GZE", STR0034  ,X3Picture("GZE_DTDEPO")     ,TamSX3("GZE_DTDEPO")[1]+1 )  //"Dt. Deposito"
	TRCell():New(oSection4,"GZE_FORPGT"	,"GZE", STR0035  ,X3Picture("GZE_FORPGT")     ,TamSX3("GZE_FORPGT")[1]+1 )  //"Forma"
	
	TRFunction():New(oSection4:Cell("GZE_VLRDEP") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
		
	oSection4:SetLeftMargin(5)	
	oSection4:SetTotalInLine(.F.)
	
	oSection5:= TRSection():New(oSection1, STR0036, {"GIC"}, , .F., .T.) //"Bilhetes"
	oSection5:SetAutoSize()
	oSection5:lHeaderVisible := .T. 

	TRCell():New(oSection5,"GIC_CODIGO" ,"GIC", STR0037   ,X3Picture("GIC_CODIGO")	 ,TamSX3("GIC_CODIGO")[1]+1 )  //"Código"
	TRCell():New(oSection5,"GIC_TIPO"   ,"GIC", STR0038   ,X3Picture("GIC_TIPO"  )	 ,TamSX3("GIC_TIPO"  )[1]+1 )  //"Tp. Passagem"
	TRCell():New(oSection5,"GIC_LOCORI"	,"GIC", STR0039   ,X3Picture("GIC_LOCORI")	 ,TamSX3("GIC_LOCORI")[1]+1  ) //"Loc. Origem"
	TRCell():New(oSection5,"GIC_LINHA"	,"GIC", STR0040   ,X3Picture("GIC_LINHA")      ,TamSX3("GIC_LINHA")[1]+1  )  //"Linha"
	TRCell():New(oSection5,"GIC_TAR"	,"GIC", STR0041   ,X3Picture("GIC_TAR")        ,TamSX3("GIC_TAR")[1]+1 )     //"Tarifa"
	TRCell():New(oSection5,"GIC_TAX"	,"GIC", STR0042   ,X3Picture("GIC_TAX")        ,TamSX3("GIC_TAX")[1]+1 )     //"Tx. Embarque"
	TRCell():New(oSection5,"GIC_PED"	,"GIC", STR0043   ,X3Picture("GIC_PED")        ,TamSX3("GIC_PED")[1]+1 )     //"Pedagio"
	TRCell():New(oSection5,"GIC_SGFACU"	,"GIC", STR0044   ,X3Picture("GIC_SGFACU")     ,TamSX3("GIC_SGFACU")[1]+1 )  //"Seguro"
	TRCell():New(oSection5,"GIC_OUTTOT"	,"GIC", STR0045   ,X3Picture("GIC_OUTTOT")     ,TamSX3("GIC_OUTTOT")[1]+1 )  //"Outros"
	TRCell():New(oSection5,"GIC_VALTOT"	,"GIC", STR0046   ,X3Picture("GIC_VALTOT")     ,TamSX3("GIC_VALTOT")[1]+1 )  //"Total"
	
	TRFunction():New(oSection5:Cell("GIC_TAR") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection5:Cell("GIC_TAX") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection5:Cell("GIC_PED") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection5:Cell("GIC_SGFACU") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)	
	TRFunction():New(oSection5:Cell("GIC_OUTTOT") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection5:Cell("GIC_VALTOT") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	
	oSection5:SetLeftMargin(5)	
	oSection5:SetTotalInLine(.F.)
	
	oSection6:= TRSection():New(oSection1, STR0047, {"GIC"}, , .F., .T.) //"Bilhetes Cancelados"
	oSection6:SetAutoSize()
	oSection6:lHeaderVisible := .T. 

	TRCell():New(oSection6,"GIC_CODIGO" ,"GIC", STR0037  ,X3Picture("GIC_CODIGO")	 ,TamSX3("GIC_CODIGO")[1]+1 )  //"Código"
	TRCell():New(oSection6,"GIC_TIPO"   ,"GIC", STR0038  ,X3Picture("GIC_TIPO"  )	 ,TamSX3("GIC_TIPO"  )[1]+1 )  //"Tp. Passagem"
	TRCell():New(oSection6,"GIC_LOCORI"	,"GIC", STR0039  ,X3Picture("GIC_LOCORI")	 ,TamSX3("GIC_LOCORI")[1]+1  ) //"Loc. Origem"
	TRCell():New(oSection6,"GIC_LINHA"	,"GIC", STR0040  ,X3Picture("GIC_LINHA")      ,TamSX3("GIC_LINHA")[1]+1  )  //"Linha"
	TRCell():New(oSection6,"GIC_TAR"	,"GIC", STR0041  ,X3Picture("GIC_TAR")        ,TamSX3("GIC_TAR")[1]+1 )     //"Tarifa"
	TRCell():New(oSection6,"GIC_TAX"	,"GIC", STR0042  ,X3Picture("GIC_TAX")        ,TamSX3("GIC_TAX")[1]+1 )     //"Tx. Embarque"
	TRCell():New(oSection6,"GIC_PED"	,"GIC", STR0043  ,X3Picture("GIC_PED")        ,TamSX3("GIC_PED")[1]+1 )     //"Pedagio"
	TRCell():New(oSection6,"GIC_SGFACU"	,"GIC", STR0044  ,X3Picture("GIC_SGFACU")     ,TamSX3("GIC_SGFACU")[1]+1 )  //"Seguro"
	TRCell():New(oSection6,"GIC_OUTTOT"	,"GIC", STR0045  ,X3Picture("GIC_OUTTOT")     ,TamSX3("GIC_OUTTOT")[1]+1 )  //"Outros"
	TRCell():New(oSection6,"GIC_VALTOT"	,"GIC", STR0046  ,X3Picture("GIC_VALTOT")     ,TamSX3("GIC_VALTOT")[1]+1 )  //"Total"

	TRFunction():New(oSection6:Cell("GIC_TAR") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection6:Cell("GIC_TAX") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection6:Cell("GIC_PED") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection6:Cell("GIC_SGFACU") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)	
	TRFunction():New(oSection6:Cell("GIC_OUTTOT") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection6:Cell("GIC_VALTOT") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	
	oSection6:SetLeftMargin(5)	
	oSection6:SetTotalInLine(.F.)
	
	TRPage():New(oReport)
			
Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Função responsável pela impressão da Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 21/08/2017
@version 1.0

@type function
/*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport)
Local oSection	 := oReport:Section(1)
Local oSection2	 := oSection:Section(1)
Local oSection3	 := oSection:Section(2)
Local oSection3B := oSection:Section(3)
Local oSection3C := oSection:Section(4)
Local oSection4	 := oSection:Section(5)
Local oSection5	 := oSection:Section(6)
Local oSection6	 := oSection:Section(7)
Local lFooter  	 := .T.			
Local cNomeAgen  := ''
Local cAliasTemp := GetNextAlias()
Local cAliasTot := GetNextAlias()
Local cAliasRec := GetNextAlias()
Local cAliasDesp := GetNextAlias()
Local cAliasRcDs := GetNextAlias()
Local cAliasDep := GetNextAlias()
Local cAliasTkt := GetNextAlias()
Local cAliasTktc := GetNextAlias()
Local cAgen  	 := G6X->G6X_AGENCI
Local cAgenAte   := MV_PAR02
Local dDataDe    := MV_PAR03
Local dDataAte   := MV_PAR04
Local cNum  	 := G6X->G6X_NUMFCH
Local cNumAte	 := MV_PAR06
Local cStatus    := MV_PAR07
Local cOrder     := "%G6X_CODIGO%"


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query com os resultados a serem exibidos³
	//³na Secao                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Ficha de Remessa
	BEGIN REPORT QUERY oSection
		BeginSQL alias cAliasTemp    
	
			SELECT *									
			FROM   %Table:G6X% G6X
			WHERE   G6X.G6X_FILIAL = %Exp:xfilial('G6X')%
					AND G6X.G6X_NUMFCH = %Exp:cNum%
					AND G6X.G6X_AGENCI = %Exp:cAgen%
					AND G6X.%NotDel%		
		EndSQL
	END REPORT QUERY oSection

	// Totais
	BEGIN REPORT QUERY oSection2
		BeginSQL alias cAliasTot    
			SELECT *									
			FROM   %Table:GZF% GZF
			WHERE   GZF.GZF_FILIAL = %Exp:xfilial('GZF')%
					AND GZF.GZF_AGENCI = %Exp:cAgen%
					AND GZF.GZF_NUMFCH = %Exp:cNum%
					AND GZF.%NotDel%		
		EndSQL
	END REPORT QUERY oSection2

	// Receitas 
	BEGIN REPORT QUERY oSection3
		BeginSQL alias cAliasRec    
			SELECT *									
			FROM   %Table:GZG% GZG
			WHERE   GZG.GZG_FILIAL = %Exp:xfilial('GZG')%
					AND GZG.GZG_AGENCI = %Exp:cAgen%
					AND GZG.GZG_NUMFCH = %Exp:cNum%
					AND GZG.GZG_TIPO = '1'
					AND GZG.%NotDel%		
		EndSQL
	END REPORT QUERY oSection3

	// Despesas
	BEGIN REPORT QUERY oSection3B
		BeginSQL alias cAliasDesp    
			SELECT *									
			FROM   %Table:GZG% GZG
			WHERE   GZG.GZG_FILIAL = %Exp:xfilial('GZG')%
					AND GZG.GZG_AGENCI = %Exp:cAgen%
					AND GZG.GZG_NUMFCH = %Exp:cNum%
					AND GZG.GZG_TIPO = '2'
					AND GZG.%NotDel%		
		EndSQL
	END REPORT QUERY oSection3B

// Receitas/Despesas
	BEGIN REPORT QUERY oSection3C
		BeginSQL alias cAliasRcDs    
			SELECT *									
			FROM   %Table:GZG% GZG
			WHERE   GZG.GZG_FILIAL = %Exp:xfilial('GZG')%
					AND GZG.GZG_AGENCI = %Exp:cAgen%
					AND GZG.GZG_NUMFCH = %Exp:cNum%
					AND GZG.GZG_TIPO = '3'
					AND GZG.%NotDel%		
		EndSQL
	END REPORT QUERY oSection3C

	// Depósitos
	BEGIN REPORT QUERY oSection4
		BeginSQL alias cAliasDep    
			SELECT *									
			FROM   %Table:GZE% GZE
			WHERE   GZE.GZE_FILIAL = %Exp:xfilial('GZE')%
					AND GZE.GZE_AGENCI = %Exp:cAgen%
					AND GZE.GZE_NUMFCH = %Exp:cNum%
					AND GZE.%NotDel%		
		EndSQL
	END REPORT QUERY oSection4

	// Bilhetes
	BEGIN REPORT QUERY oSection5
		BeginSQL alias cAliasTkt    
			SELECT *									
			FROM   %Table:GIC% GIC
			WHERE   GIC.GIC_FILIAL = %Exp:xfilial('GIC')%
					AND GIC.GIC_AGENCI = %Exp:cAgen%
					AND GIC.GIC_NUMFCH = %Exp:cNum%
					AND GIC.GIC_STATUS <> 'C'
					AND GIC.%NotDel%		
		EndSQL
	END REPORT QUERY oSection5

	// Bilehtes Cancelados
	BEGIN REPORT QUERY oSection6
		BeginSQL alias cAliasTktc  
			SELECT *									
			FROM   %Table:GIC% GIC
			WHERE   GIC.GIC_FILIAL = %Exp:xfilial('GIC')%
					AND GIC.GIC_AGENCI = %Exp:cAgen%
					AND GIC.GIC_NUMFCH = %Exp:cNum%
					AND GIC.GIC_STATUS <> 'C'
					AND GIC.%NotDel%		
		EndSQL
	END REPORT QUERY oSection6
	
	oReport:SetMeter((cAliasTemp)->(RecCount()))
	
	oReport:StartPage()	
	oReport:SkipLine()
	
	oSection:Init()
	
	While !oReport:Cancel() .AND. (cAliasTemp)->(!Eof())	
		
		cNomeAgen := POSICIONE("GI6",1,XFILIAL("GI6")+(cAliasTemp)->(G6X_AGENCI),"GI6_DESCRI")                                                                    
		oSection:Cell("NOMEAGENCIA"):SetValue(cNomeAgen)
		
		oSection:Printline()
		
		(cAliasTemp)->(DbSkip())  
		
	End
	
	
	oSection:Finish()
	
	oSection2:Init()
	oSection2:Print()
	oSection2:Finish()
	
	oSection3:Init()
	oSection3:Print()
	oSection3:Finish()

	oSection3B:Init()
	oSection3B:Print()
	oSection3B:Finish()

	oSection3C:Init()
	oSection3C:Print()
	oSection3C:Finish()

	oSection4:Init()
	oSection4:Print()
	oSection4:Finish()
	
	oSection5:Init()
	oSection5:Print()
	oSection5:Finish()
	
	oSection6:Init()
	oSection6:Print()
	oSection6:Finish()
	
	oReport:ThinLine()
	oReport:EndPage()
	
Return
