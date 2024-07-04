#include 'PROTHEUS.CH'
#include 'PARMTYPE.CH'
#include 'GTPR045.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR421
Relatório do Cabeçalho da Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 21/08/2017
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Function GTPR045()

Private oReport
Private cPerg   := "GTPR045"

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

	oReport := TReport():New("GTPR045",STR0001,cPerg,{|oReport| ReportPrint(oReport)},STR0001) //"Relatório de Cadastro de Cheques"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
	oReport:SetPortrait()    
			
	oSection:= TRSection():New(oReport,STR0001, {"GZD"}, , .F., .T.) //"Relatório de Cadastro de Cheques"
	oSection:SetAutoSize(.F.)
	
	TRCell():New(oSection,"GZD_CODIGO"  ,"GZD", STR0002 ,X3Picture("GZD_CODIGO")  ,TamSX3("GZD_CODIGO")[1]+4 ) //"Codigo"
	TRCell():New(oSection,"GZD_AGENCI"  ,"GZD", STR0003 ,X3Picture("GZD_AGENCI")  ,TamSX3("GZD_AGENCI")[1]+4 ) //"Agencia"
	TRCell():New(oSection,"NOMEAGENCIA"	,"GZD", STR0004 ,X3Picture("GZD_NAGENC")  ,TamSX3("GZD_NAGENC")[1]+4 ) //"Nome Agencia"
	TRCell():New(oSection,"GZD_NUMERO"	,"GZD", STR0005 ,X3Picture("GZD_NUMERO")  ,TamSX3("GZD_NUMERO")[1]+4 ) //"Num. Cheque"
	TRCell():New(oSection,"GZD_BANCO"	,"GZD", STR0006 ,X3Picture("GZD_BANCO")   ,TamSX3("GZD_BANCO")[1]+4  ) //"Banco"
	TRCell():New(oSection,"GZD_BCOAGE"	,"GZD", STR0007 ,X3Picture("GZD_BCOAGE")  ,TamSX3("GZD_BCOAGE")[1]+4  ) //"Bco. Agen.
	TRCell():New(oSection,"GZD_CONTA"	,"GZD", STR0008 ,X3Picture("GZD_CONTA")   ,TamSX3("GZD_CONTA")[1]+4  ) //"Conta"
	TRCell():New(oSection,"GZD_DTEMIS"	,"GZD", STR0010 ,X3Picture("GZD_DTEMIS")  ,TamSX3("GZD_DTEMIS")[1]+4 ) //"Dt. Emissao"
	TRCell():New(oSection,"GZD_DTDEPO"	,"GZD", STR0011 ,X3Picture("GZD_DTDEPO")  ,TamSX3("GZD_DTDEPO")[1]+4 ) //"Dt. Deposit"
	TRCell():New(oSection,"GZD_FICHAR"	,"GZD", STR0012 ,X3Picture("GZD_FICHAR")  ,TamSX3("GZD_FICHAR")[1]+4 ) //"Ficha Remessa"
	TRCell():New(oSection,"GZD_VALOR"	,"GZD", STR0009 ,X3Picture("GZD_VALOR")   ,TamSX3("GZD_VALOR")[1]+4 ) //"Valor"
	
	TRFunction():New(oSection:Cell("GZD_VALOR") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

    oSection:SetLeftMargin(5) 
    oSection:SetTotalInLine(.F.) 

	oSection:Cell("GZD_CODIGO"):lHeaderSize := .F.
	oSection:Cell("GZD_AGENCI"):lHeaderSize := .F.
	oSection:Cell("NOMEAGENCIA"):lHeaderSize := .F.
	oSection:Cell("GZD_NUMERO"):lHeaderSize := .F.
	oSection:Cell("GZD_BANCO"):lHeaderSize := .F.
	oSection:Cell("GZD_BCOAGE"):lHeaderSize := .F.
	oSection:Cell("GZD_CONTA"):lHeaderSize := .F.
	oSection:Cell("GZD_VALOR"):lHeaderSize := .F.
	oSection:Cell("GZD_DTEMIS"):lHeaderSize := .F.
	oSection:Cell("GZD_DTDEPO"):lHeaderSize := .F.
	oSection:Cell("GZD_FICHAR"):lHeaderSize := .F.
	
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
Local cAliasTot  := GetNextAlias()
Local cAgenDe 	 := MV_PAR01
Local cAgenAte   := MV_PAR02
Local cFiRDe     := MV_PAR03
Local cFiRAte    := MV_PAR04
Local cNumChqDe  := MV_PAR05
Local cNumChqAte := MV_PAR06
Local cBcoDe     := MV_PAR07
Local cBcoAgDe 	 := MV_PAR08
Local cCcDe      := MV_PAR09
Local cBcoAte 	 := MV_PAR10
Local cBcoAgAte  := MV_PAR11
Local cCcAte 	 := MV_PAR12
Local nValDe	 := MV_PAR13
Local nValAte    := MV_PAR14
Local dDataDpDe	 := MV_PAR15
Local dDataDpAte := MV_PAR16
Local cOrder     := "%GZD_CODIGO%"


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query com os resultados a serem exibidos³
	//³na Secao                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN REPORT QUERY oSection
		BeginSQL alias cAliasTemp    
	
			SELECT *									
			FROM   %Table:GZD% GZD
			WHERE   GZD_FILIAL = %Exp:xfilial('GZD')%
					AND GZD_AGENCI BETWEEN %Exp:cAgenDe%          AND %Exp:cAgenAte% 
					AND GZD_FICHAR BETWEEN %Exp:cFiRDe%           AND %Exp:cFiRAte%
					AND GZD_NUMERO BETWEEN %Exp:cNumChqDe%        AND %Exp:cNumChqAte%
					AND GZD_BANCO  BETWEEN %Exp:cBcoDe%           AND %Exp:cBcoAte%
					AND GZD_BCOAGE BETWEEN %Exp:cBcoAgDe%         AND %Exp:cBcoAgAte%
					AND GZD_CONTA  BETWEEN %Exp:cCcDe%            AND %Exp:cCcAte%
					AND GZD_VALOR  BETWEEN %Exp:nValDe%           AND %Exp:nValAte%
					AND GZD_DTDEPO BETWEEN %Exp:DtoS(dDataDpDe)%  AND %Exp:DtoS(dDataDpAte)%
					AND GZD.%NotDel%
					ORDER BY %Exp:cOrder%			
		EndSQL
	END REPORT QUERY oSection
	
	oReport:SetMeter((cAliasTemp)->(RecCount()))
	
	oReport:StartPage()	
	oReport:SkipLine()
	
	oSection:Init()
	
	While !oReport:Cancel() .AND. (cAliasTemp)->(!Eof())	
		
		cNomeAgen := POSICIONE("GI6",1,XFILIAL("GI6")+(cAliasTemp)->(GZD_AGENCI),"GI6_DESCRI")                                                                    
		oSection:Cell("NOMEAGENCIA"):SetValue(cNomeAgen)
		
		oSection:Printline()
		
		(cAliasTemp)->(DbSkip())  
		
	End
	
	oSection:Finish()

	oReport:ThinLine()
	oReport:EndPage()
	