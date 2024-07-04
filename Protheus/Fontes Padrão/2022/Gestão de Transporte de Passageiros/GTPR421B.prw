#include 'protheus.ch'
#include 'parmtype.ch'
#include 'gtpr421b.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR421B
Relatório de Valores Adicionais da Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 01/12/2017
@version 1.0

@type function
/*/
//-------------------------------------------------------------------

Function GTPR421B()

Private oReport
Private cPerg   := "GTPR421B"

	Pergunte( cPerg, .T. )
	
	oReport := ReportDef( cPerg )
	oReport:PrintDialog()
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Relatório de Valores Adicionais da Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 01/12/2017
@version 1.0

@type function
/*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)
Local oReport   := Nil
Local oBreak    := Nil
Local oSection1  := Nil
Local oSection2 := Nil
	
	oReport := TReport():New("GTPR421B",STR0001,cPerg,{|oReport| ReportPrint(oReport)},STR0001) //"Relatório de Valores Adicionais - Ficha de Remessa", "Este relatório irá demonstrar os valores adicionais da Ficha de Remessa"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
	oReport:SetPortrait()   		
	
	oSection1:= TRSection():New(oReport,STR0003, {"GZG"}, , .F., .T.) //"Agência"
	oSection1:SetAutoSize(.F.)
	
	TRCell():New(oSection1,"GZG_AGENCI"  ,"GZG",STR0003	 ,X3Picture("GZG_AGENCI")	  ,TamSX3("GZG_AGENCI")[1]+1 ) //"Agencia"
	TRCell():New(oSection1,"NOMEAGENCIA" ,"GZG",STR0004	 ,X3Picture("G6X_DESCAG")	  ,TamSX3("G6X_DESCAG")[1] ) //"Nome Agencia"
	
	oSection2:= TRSection():New(oReport,STR0005, {"GZG"}, , .F., .T.) //"Valores Adicionais"
	oSection2:SetAutoSize(.F.)
	
	
	TRCell():New(oSection2,"GZG_COD"	,"GZG",STR0006	  ,X3Picture("GZG_COD")	   ,TamSX3("GZG_COD")[1]+4  ) //"Código"
	TRCell():New(oSection2,"GZG_DESCRI"	,"GZG",STR0007	  ,X3Picture("GZG_DESCRI")   ,TamSX3("GZG_DESCRI")[1]+4  ) //"Descrição"
	TRCell():New(oSection2,"GZG_TIPO"	,"GZG",STR0008    ,X3Picture("GZG_TIPO")     ,TamSX3("GZG_TIPO")[1]+10 ) //"Tipo"
	TRCell():New(oSection2,"GZG_NUMFCH"	,"GZG",STR0009    ,X3Picture("GZG_NUMFCH")   ,TamSX3("GZG_NUMFCH")[1]+4 ) //"Número da Ficha"
	TRCell():New(oSection2,"GZG_VALOR"	,"GZG",STR0010    ,X3Picture("GZG_VALOR")    ,TamSX3("GZG_VALOR")[1]+4 ) //"Valor"
	
	//TRFunction():New(oSection2:Cell("GZG_VALOR") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	
	oSection3:= TRSection():New(oReport,"Totais de Receitas e Despesas", {"GZG"}, , .F., .T.) //"Valores Receiras e Despesas"
	oSection3:SetAutoSize(.F.)
	TRCell():New(oSection3,"GZGVALREC"	,"GZG",STR0011      ,X3Picture("GZG_VALOR")    ,TamSX3("GZG_VALOR")[1]+4 ) //"Valor"
	TRCell():New(oSection3,"GZGVALDEP"	,"GZG",STR0012      ,X3Picture("GZG_VALOR")    ,TamSX3("GZG_VALOR")[1]+4 ) //"Valor"
	TRCell():New(oSection3,"GZGVALSAL"	,"GZG",STR0013      ,X3Picture("GZG_VALOR")    ,TamSX3("GZG_VALOR")[1]+4 ) //"Valor"
			
	oSection1:SetLeftMargin(5)	
	oSection1:SetTotalInLine(.F.)
	oSection2:SetLeftMargin(5)	
	oSection2:SetTotalInLine(.F.)
	
	TRPage():New(oReport)
			
Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Função responsável pela impressão da Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 01/12/2017
@version 1.0

@type function
/*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport)
Local oSection1	 := oReport:Section(1)
Local oSection2  := oReport:Section(2)
Local oSection3  := oReport:Section(3) 
Local lFooter  	 := .T.			
Local cNomeAgen  := ''
Local cAliasTemp := GetNextAlias()
Local cNumFch 	 := MV_PAR01
Local cTipo      := ''
Local nReceita   := 0
Local nDespesa   := 0


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query com os resultados a serem exibidos³
	//³na Secao                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN REPORT QUERY oSection1
		BeginSQL alias cAliasTemp    
	
			SELECT *									
			FROM   %Table:GZG% GZG
			WHERE   GZG_FILIAL = %Exp:xfilial('GZG')%
					AND GZG_NUMFCH = %Exp:cNumFch% 
					AND GZG.%NotDel%			
		EndSQL
		
	END REPORT QUERY oSection1
	
	oReport:SetMeter((cAliasTemp)->(RecCount()))
	
	oReport:StartPage()	
	oReport:SkipLine()
	
	oSection1:Init()
	
	
	If (cAliasTemp)->(!Eof())	
		
		cNomeAgen := POSICIONE("GI6",1,XFILIAL("GI6")+(cAliasTemp)->(GZG_AGENCI),"GI6_DESCRI")                                                                    
		oSection1:Cell("NOMEAGENCIA"):SetValue(cNomeAgen)
		
		oSection1:Printline()
				
	EndIf
	
	oSection1:Finish()
	
	oSection2:Init()
	
	While (cAliasTemp)->(!Eof())
	
		
		
		If (cAliasTemp)->(GZG_TIPO) == "1"
			nReceita += (cAliasTemp)->(GZG_VALOR)
			cTipo := STR0014 
		ElseIf (cAliasTemp)->(GZG_TIPO) == "2"
			nDespesa += (cAliasTemp)->(GZG_VALOR)
			cTipo := STR0015
		EndIf
		
		oSection2:Cell("GZG_COD"):SetValue((cAliasTemp)->(GZG_COD) )
		oSection2:Cell("GZG_DESCRI"):SetValue((cAliasTemp)->(GZG_DESCRI) )
		oSection2:Cell("GZG_TIPO"):SetValue(cTipo)	 
		oSection2:Cell("GZG_NUMFCH"):SetValue((cAliasTemp)->(GZG_NUMFCH) )
		oSection2:Cell("GZG_VALOR"):SetValue((cAliasTemp)->(GZG_VALOR) )	 
		
		oSection2:Printline()
		 
		(cAliasTemp)->(DbSkip())  
	End
	
	oSection2:Finish()
	
	nSaldo := nReceita - nDespesa
	
	oSection3:Init()
	oSection3:Cell("GZGVALREC"):SetValue(nReceita)
	oSection3:Cell("GZGVALDEP"):SetValue(nDespesa)
	oSection3:Cell("GZGVALSAL"):SetValue(nSaldo)		
	oSection3:Printline()
	
	oSection3:Finish()
	
	oReport:ThinLine()
	oReport:EndPage()
	
Return
