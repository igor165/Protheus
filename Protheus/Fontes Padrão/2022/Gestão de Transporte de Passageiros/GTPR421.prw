#include 'PROTHEUS.CH'
#include 'PARMTYPE.CH'
#include 'GTPR421.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR421
Relatório do Cabeçalho da Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 21/08/2017
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Function GTPR421()

Private oReport
Private cPerg   := "GTPR421"

	Pergunte( cPerg, .T. )
	
	oReport := ReportDef( cPerg )
	oReport:PrintDialog()
	
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

Static Function ReportDef(cPerg)
Local oReport   := Nil
Local oBreak    := Nil
Local oSection := Nil
	
	oReport := TReport():New("GTPR421",STR0001,cPerg,{|oReport| ReportPrint(oReport)},STR0001) //"Relatório de Ficha de Remessa"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
	oReport:SetPortrait()    
	//oReport:SetLandscape()		
	
	oSection:= TRSection():New(oReport,STR0001, {"G6X"}, , .F., .T.) //"Ficha de Remessa"
	oSection:SetAutoSize(.F.)
	
	TRCell():New(oSection,"G6X_AGENCI"  ,"G6X",STR0003	 ,X3Picture("G6X_AGENCI")	  ,TamSX3("G6X_AGENCI")[1]+1 ) //"Agencia"
	TRCell():New(oSection,"NOMEAGENCIA" ,"G6X",STR0004	 ,X3Picture("G6X_DESCAG")	  ,TamSX3("G6X_DESCAG")[1] ) //"Nome Agencia"
	TRCell():New(oSection,"G6X_DTINI"	,"G6X",STR0005	 ,X3Picture("G6X_DTINI")	  ,TamSX3("G6X_DTINI")[1]+4  ) //"Dt. Inicial"
	TRCell():New(oSection,"G6X_DTFIN"	,"G6X",STR0006	 ,X3Picture("G6X_DTFIN")      ,TamSX3("G6X_DTFIN")[1]+4  ) //"Dt. Final"
	TRCell():New(oSection,"G6X_NUMFCH"	,"G6X",STR0007   ,X3Picture("G6X_NUMFCH")     ,TamSX3("G6X_NUMFCH")[1]+4 ) //"Ficha Remessa"
	TRCell():New(oSection,"G6X_VLRREI"	,"G6X",STR0008   ,X3Picture("G6X_VLRREI")     ,TamSX3("G6X_VLRREI")[1]+4 ) //"Total Receita"
	TRCell():New(oSection,"G6X_VLRDES"	,"G6X",STR0009   ,X3Picture("G6X_VLRDES")     ,TamSX3("G6X_VLRDES")[1]+4 ) //"Total Despesa"
	TRCell():New(oSection,"G6X_VLRLIQ"	,"G6X",STR0010   ,X3Picture("G6X_VLRLIQ")     ,TamSX3("G6X_VLRLIQ")[1]+4 ) //"Rem. Liquida"
	TRCell():New(oSection,"G6X_VLTODE"	,"G6X",STR0011   ,X3Picture("G6X_VLTODE")     ,TamSX3("G6X_VLTODE")[1]+4 ) //"Tot. Deposito"
	TRCell():New(oSection,"G6X_STATUS"	,"G6X",STR0012 	 ,X3Picture("G6X_STATUS")     ,TamSX3("G6X_STATUS")[1]+10 ) //"Status"
	
	TRFunction():New(oSection:Cell("G6X_VLRREI") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection:Cell("G6X_VLRDES") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection:Cell("G6X_VLRLIQ"),,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection:Cell("G6X_VLTODE") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
		
	oSection:SetLeftMargin(5)	
	oSection:SetTotalInLine(.F.)
	
	oSection:Cell("G6X_AGENCI"):lHeaderSize	:= .F.
	oSection:Cell("NOMEAGENCIA"):lHeaderSize	:= .F.
	oSection:Cell("G6X_DTINI"):lHeaderSize	:= .F.
	oSection:Cell("G6X_DTFIN"):lHeaderSize	:= .F.
	oSection:Cell("G6X_NUMFCH"):lHeaderSize	:= .F.
	oSection:Cell("G6X_VLRREI"):lHeaderSize	:= .F.
	oSection:Cell("G6X_VLRDES"):lHeaderSize	:= .F.
	oSection:Cell("G6X_VLRLIQ"):lHeaderSize	:= .F.
	oSection:Cell("G6X_VLTODE"):lHeaderSize	:= .F.
	oSection:Cell("G6X_STATUS"):lHeaderSize	:= .F.
	
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
Local lFooter  	 := .T.			
Local cNomeAgen  := ''
Local cAliasTemp := GetNextAlias()
Local cAgenDe 	 := MV_PAR01
Local cAgenAte   := MV_PAR02
Local dDataDe    := MV_PAR03
Local dDataAte   := MV_PAR04
Local cNumDe 	 := MV_PAR05
Local cNumAte	 := MV_PAR06
Local cStatus    := cValtoChar(MV_PAR07)
Local cOrder     := "%G6X_CODIGO%"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query com os resultados a serem exibidos³
	//³na Secao                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN REPORT QUERY oSection
		BeginSQL alias cAliasTemp    
	
			SELECT *									
			FROM   %Table:G6X% G6X
			WHERE   G6X_FILIAL = %Exp:xfilial('G6X')%
					AND G6X_AGENCI BETWEEN %Exp:cAgenDe% AND %Exp:cAgenAte% 
					AND G6X_NUMFCH BETWEEN %Exp:cNumDe%  AND %Exp:cNumAte%
					AND G6X_DTINI >= %Exp:DtoS(dDataDe)% 
					AND G6X_DTFIN <= %Exp:DtoS(dDataAte)%
					AND G6X_STATUS = %Exp:cStatus%
					AND G6X.%NotDel%
					ORDER BY %Exp:cOrder%			
		EndSQL
	END REPORT QUERY oSection
	
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
	oReport:ThinLine()
	oReport:EndPage()
	
Return
