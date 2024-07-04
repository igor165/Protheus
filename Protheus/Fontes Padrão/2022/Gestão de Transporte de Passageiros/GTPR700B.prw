#include 'protheus.ch'
#include 'parmtype.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR700B
Relatório de Lançamentos de Depósitos

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 21/08/2017
@version 1.0

@type function
/*/
//-------------------------------------------------------------------


Function GTPR700B()
Private oReport
Private cPerg   := "GTPR700B"

	If Pergunte( cPerg, .T. )
	
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definições do Relatório de Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 21/08/2017
@version 1.0

@type function
/*/
//-------------------------------------------------------------------

Static Function ReportDef()
Local oBreak    := Nil
Local oSection  := Nil
Local oSection1 := Nil
	
	oReport := TReport():New("GTPR700B", "Relatório de Lançamento de Depósitos", "GTPR700B",{|oReport| ReportPrint(oReport)}, "Este relatório irá gerar os lançamentos de depósitos referente a Tesouraria") //"Relatório de Ficha de Remessa"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
	oReport:SetPortrait()   
	
	oSection:= TRSection():New(oReport, "Agências", {"G6Y"}, , .F., .T.) //"Agências"
	oSection:SetAutoSize(.F.)
	
	TRCell():New(oSection,"G6Y_CODAGE"  ,"G6Y",  "Agência"      ,X3Picture("G6Y_CODAGE")	    ,TamSX3("G6Y_CODAGE")[1]+1 ) //"Tp. Deposito"
	TRCell():New(oSection,"NOMEAGENCIA" ,"G6Y",  "Descrição"    ,X3Picture("G6Y_CODAGE")	    ,TamSX3("G6Y_CODAGE")[1]+30 ) //"Tp. Deposito"
	
	
	oSection1:= TRSection():New(oReport, "Depositos", {"G6Y"}, , .F., .T.) //"Depositos"
	oSection1:SetAutoSize(.F.)
	
	oSection1:SetAutoSize()
	oSection1:lHeaderVisible := .T. 
	
	TRCell():New(oSection1,"G6Y_ITEM"    ,"G6Y",  "Item"  		   ,X3Picture("G6Y_ITEM")	    ,TamSX3("G6Y_ITEM")[1]+1 ) //"Tp. Deposito"
	TRCell():New(oSection1,"G6Y_IDDEPO"  ,"G6Y",  "ID Deposito"     ,X3Picture("G6Y_IDDEPO")	,TamSX3("G6Y_IDDEPO")[1]+1 ) //"ID Deposito"
	TRCell():New(oSection1,"G6Y_BANCO"	,"G6Y",  "Banco"           ,X3Picture("G6Y_BANCO")	    ,TamSX3("G6Y_BANCO")[1]+1  )//"Banco"
	TRCell():New(oSection1,"NOMEBANCO"	,"G6Y",  "Nome"           ,X3Picture("G6Y_BANCO")	    ,TamSX3("G6Y_BANCO")[1]+40  )//"Banco"
	TRCell():New(oSection1,"G6Y_AGEBCO"	,"G6Y",  "Agência"         ,X3Picture("G6Y_AGEBCO")     ,TamSX3("G6Y_AGEBCO")[1]+1  ) //"Agencia"
	TRCell():New(oSection1,"G6Y_CTABCO"	,"G6Y",  "Conta Corrente"  ,X3Picture("G6Y_CTABCO")     ,TamSX3("G6Y_CTABCO")[1]+1 ) //"Conta Corrente"
	TRCell():New(oSection1,"G6Y_VALOR"	,"G6Y",  "Vlr Deposito"    ,X3Picture("G6Y_VALOR")      ,TamSX3("G6Y_VALOR")[1]+1 )  //"Vlr Deposito"
	TRCell():New(oSection1,"G6Y_DATA"	,"G6Y",  "Dt. Deposito"    ,X3Picture("G6Y_DATA")       ,TamSX3("G6Y_DATA")[1]+1 )  //"Dt. Deposito"
	TRCell():New(oSection1,"G6Y_FORPGT"	,"G6Y",  "Forma"           ,X3Picture("G6Y_FORPGT")     ,TamSX3("G6Y_FORPGT")[1]+30 )  //"Forma"
	TRCell():New(oSection1,"G6Y_NUMFCH"	,"G6Y",  "Ficha de Remessa",X3Picture("G6Y_NUMFCH")     ,TamSX3("G6Y_NUMFCH")[1]+1 )  //"Forma"
	TRCell():New(oSection1,"DATAFICHA"	,"G6Y",  "Dt Ficha de Remessa",X3Picture("G6Y_DATA")     ,TamSX3("G6Y_DATA")[1]+1 )  //"Forma"
	TRCell():New(oSection1,"G6Y_STSDEP"	,"G6Y",  "Status"          ,X3Picture("G6Y_NUMFCH")     ,TamSX3("G6Y_NUMFCH")[1]+1 )  //"Forma"
	
	TRFunction():New(oSection1:Cell("G6Y_VALOR") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
		
	oSection:SetLeftMargin(5)	
	oSection:SetTotalInLine(.F.)
	
	oSection1:SetLeftMargin(5)	
	oSection1:SetTotalInLine(.F.)
	
	TRPage():New(oReport)
	
Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} RptDef
Definições do Relatório de Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 21/08/2017
@version 1.0

@type function
/*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport)
Local oSection	 := oReport:Section(1)
Local oSection1	 := oReport:Section(2)
Local cAliasTemp := GetNextAlias()
Local dDataDe    := MV_PAR01
Local dDataAte	 := MV_PAR02
Local cAgeDe	 := MV_PAR03
Local cAgeAte	 := MV_PAR04 
Local cNuFcDe	 := MV_PAR05 
Local cNuFcAte	 := MV_PAR06 
Local cTpLanc    := '2'
Local cNomeAgen  := ''
Local cFormaPag	 := ''
LOcal cNomeBanco := ''
Local cStsDep    := ''
	
	BEGIN REPORT QUERY oSection
		BeginSQL alias cAliasTemp    
	
			SELECT *									
			FROM   %Table:G6Y% G6Y
			WHERE   
				G6Y.G6Y_FILIAL = %xFilial:G6Y%
				AND G6Y.G6Y_DATA	BETWEEN %Exp:dDataDe%	AND %Exp:dDataAte%
				AND G6Y.G6Y_CODAGE	BETWEEN %Exp:cAgeDe%	AND %Exp:cAgeAte%
				AND G6Y.G6Y_NUMFCH	BETWEEN %Exp:cNuFcDe%	AND %Exp:cNuFcAte%
				AND G6Y.G6Y_TPLANC = %Exp:cTpLanc%
				AND G6Y.%NotDel%		
		EndSQL
	END REPORT QUERY oSection
	
	oReport:SetMeter((cAliasTemp)->(RecCount()))
	
	oReport:StartPage()	
	oReport:SkipLine()
	
	oSection:Init()
	
	
	If !oReport:Cancel() .AND. (cAliasTemp)->(!Eof())	
		cNomeAgen := POSICIONE("GI6",1,XFILIAL("GI6")+(cAliasTemp)->(G6Y_CODAGE),"GI6_DESCRI")                                                                    
		oSection:Cell("NOMEAGENCIA"):SetValue(cNomeAgen)
		
		oSection:Printline()
		
	End
	
	oSection:Finish()
	
	oSection1:Init()
	
	cNomeBanco	:= POSICIONE("SA6",1,XFILIAL("SA6")+(cAliasTemp)->(G6Y_BANCO),"A6_NOME")
			
	While !oReport:Cancel() .AND. (cAliasTemp)->(!Eof())
	
		oSection1:Cell("G6Y_ITEM"):SetValue((cAliasTemp)->(G6Y_ITEM))
		oSection1:Cell("G6Y_IDDEPO"):SetValue((cAliasTemp)->(G6Y_IDDEPO))
		oSection1:Cell("G6Y_BANCO"):SetValue((cAliasTemp)->(G6Y_BANCO))
		oSection1:Cell("NOMEBANCO"):SetValue(cNomeBanco)
		oSection1:Cell("G6Y_AGEBCO"):SetValue((cAliasTemp)->(G6Y_AGEBCO))
		oSection1:Cell("G6Y_CTABCO"):SetValue((cAliasTemp)->(G6Y_CTABCO))
		oSection1:Cell("G6Y_VALOR"):SetValue((cAliasTemp)->(G6Y_VALOR))
		oSection1:Cell("G6Y_DATA"):SetValue((cAliasTemp)->(G6Y_DATA))
		If (cAliasTemp)->(G6Y_FORPGT) == '1'
			cFormaPag	:= "Cheque"
		ElseIf (cAliasTemp)->(G6Y_FORPGT) == '2'
			cFormaPag	:= "Dinheiro"
		ElseIf (cAliasTemp)->(G6Y_FORPGT) == '3'
			cFormaPag	:= "Transferencia Eletronica"
		EndIf
		oSection1:Cell("G6Y_FORPGT"):SetValue(cFormaPag)
		oSection1:Cell("G6Y_NUMFCH"):SetValue((cAliasTemp)->(G6Y_NUMFCH))
		oSection1:Cell("DATAFICHA"):SetValue(StoD((cAliasTemp)->(G6Y_NUMFCH)))
		
		If (cAliasTemp)->(G6Y_STSDEP) == '1'
			cStsDep	:= "Aceito"
		ElseIf (cAliasTemp)->(G6Y_STSDEP) == '2'
			cStsDep	:= "Rejeitado"
		Endif

		oSection1:Cell("G6Y_STSDEP"):SetValue(cStsDep)
		oSection1:Printline()
		
		(cAliasTemp)->(DbSkip())  
	End
	
	oSection1:Finish()
	
	oReport:ThinLine()
	oReport:EndPage()
	
	(cAliasTemp)->(DbCloseArea())
	