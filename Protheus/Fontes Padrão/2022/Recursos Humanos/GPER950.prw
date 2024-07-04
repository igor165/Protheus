#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'REPORT.CH'
#INCLUDE 'GPER950.CH'

/**********************************************************************************
***********************************************************************************
***********************************************************************************
***Func�o.....: GPER950.PRW    Autor: PHILIPE.POMPEU    Data:07/06/2016 		   ***
***********************************************************************************
***Descri��o..: Imprime o relat�rio de Historico Salarial                       ***
***********************************************************************************
***Uso........:        																   ***
***********************************************************************************
***Par�metros.:				     									            	   ***
***********************************************************************************
***Retorno....:                                                                 ***
***********************************************************************************
***					Altera��es feitas desde a constru��o inicial       	 		   ***
***********************************************************************************
***RESPONS�VEL.|DATA....|C�DIGO|BREVE DESCRI��O DA CORRE��O.....................***
***********************************************************************************
***P. Pompeu...|07/06/16|TUTJHR    |Melhoria: Cria��o do Relat�rio.         ***
*** Marco A.   �09/10/17�TSSERMI01-�Se agregan localizaciones para el campo ***
***            �        �172       �R3_DTCDISS, que es de uso exclusivo para***
***            �        �          �Brasil. (MEX)                           ***
***Oswaldo L   �28/11/17|DRHPAG9116�Ajuste de erro ao deixar ' no filtro de *** 
***            �        �          �Categoria                               ***
**********************************************************************************/

/*/{Protheus.doc} GPER950
	Fun��o respons�vel pela impress�o do relat�rio de Hist�rico Salarial
@author PHILIPE.POMPEU
@since 06/06/2016
@version P11
@return Nil, Valor Nulo
/*/
Function GPER950()
	Local	aArea 	:= GetArea()
	Local	oReport:= Nil
	Private aTpsAltSal := {}
	
	oReport := ReportDef()
	
	if(oReport <> Nil)
		aTpsAltSal := gtTpAltSal()
	 
		oReport:PrintDialog()
	endIf
	
	oReport := Nil
	RestArea(aArea)	
Return Nil

/*/{Protheus.doc} ReportDef
	Define o Objeto da Classe TReport utilizado na impress�o do relat�rio
@author PHILIPE.POMPEU
@since 06/06/2016
@version P11
@return oReport, inst�ncia da classe TReport
/*/
Static Function ReportDef()	
	Local oReport	:= Nil
	Local oSecFil	:= Nil
	Local oSecCab		:= Nil
	Local oSecItems	:= Nil
	Local cRptTitle	:= OemToAnsi(STR0001) //"Relat�rio de Hist�rico Salarial"
	Local cRptDescr	:= OemToAnsi(STR0002) //"Este programa emite a Impress�o do Relat�rio de Hist�rico Salarial."
	Local cRptAba	:= OemToAnsi(STR0009) //"Dados - Hist�rico Salarial."
	Local aOrderBy	:= {}
	Local cNomePerg	:=	"GPER950"
	Local cMyAlias	:= GetNextAlias()
	
	aAdd(aOrderBy, OemToAnsi(STR0003))//'1 - Matr�cula + Data'
	aAdd(aOrderBy, OemToAnsi(STR0008))//'2 - Data + Matr�cula'	
	
	Pergunte(cNomePerg,.F.)
	
	DEFINE REPORT oReport NAME "GPER950" TITLE cRptTitle PARAMETER cNomePerg ACTION {|oReport| PrintReport(oReport,cNomePerg,cMyAlias)} DESCRIPTION cRptDescr	TOTAL IN COLUMN

	DEFINE SECTION oSecFil OF oReport TITLE cRptTitle 	TABLES "SR7" TOTAL IN COLUMN ORDERS aOrderBy 
	DEFINE CELL NAME "R7_FILIAL" 	OF 	oSecFil ALIAS "SR7"		
	
	DEFINE SECTION oSecCab OF oSecFil 	TITLE cRptAba TABLES "SR7","SRA","SR3" TOTAL IN COLUMN
	DEFINE CELL NAME "R7_MAT" 		OF 	oSecCab ALIAS "SR7" SIZE TamSX3( "RA_MAT" )[1] + 6
	DEFINE CELL NAME "RA_NOME" 		OF 	oSecCab ALIAS "SRA" 
	DEFINE CELL NAME "R7_DATA" 		OF 	oSecCab ALIAS "SR7"  SIZE 15
	DEFINE CELL NAME "R7_TIPO" 		OF 	oSecCab BLOCK {||GetDescTip((cMyAlias)->R7_TIPO)} ALIAS "SR7" SIZE 35
	DEFINE CELL NAME "R7_CATFUNC"	OF 	oSecCab ALIAS "SR7" SIZE 4 TITLE "Cat."
	DEFINE CELL NAME "VLRHR"		OF 	oSecCab BLOCK {||Transform((cMyAlias)->VLRHR,'@E 999.99')} TITLE OemToAnsi(STR0004)
	DEFINE CELL NAME "R3_VALOR" 	OF 	oSecCab ALIAS "SR3"
	DEFINE CELL NAME "R7_CARGO" 	OF 	oSecCab ALIAS "SR7"
	DEFINE CELL NAME "R7_DESCCAR" 	OF 	oSecCab ALIAS "SR7" TITLE ""
	If cPaisLoc == "BRA"
		DEFINE CELL NAME "R3_DTCDISS" 	OF 	oSecCab ALIAS "SR3" SIZE 15
	EndIf
	DEFINE CELL NAME "TMT_CBO" 		OF 	oSecCab BLOCK {||GetDescCBO((cMyAlias)->R7_FILIAL, (cMyAlias)->R7_MAT,(cMyAlias)->R7_DATA,(cMyAlias)->R7_TIPO)} ALIAS "SRJ" SIZE ( TamSX3("RJ_CODCBO")[1] + 2 )
		
Return oReport

/*/{Protheus.doc} PrintReport
	Realiza a impress�o do relat�rio
@author PHILIPE.POMPEU
@since 06/06/2016
@version P11
@param oReport, objeto, inst�ncia da classe TReport
@param cNomePerg, caractere, Nome do Pergunte
@param cMyAlias, caractere, Alias utilizado p/ consulta
@return nil, valor nulo
/*/
Static Function PrintReport(oReport, cNomePerg, cMyAlias)
	Local oSecFil		:= oReport:Section(1)
	Local oSecCab		:= oSecFil:Section(1)
	Local nOrderBy	:= oSecFil:GetOrder()
	Local cOrderBy	:= ''
	Local oBreakFil	:= Nil
	Local oBreakUni	:= Nil
	Local oBreakEmp	:= Nil
	Local cTitFil		:= ''
	Local cTitUniNeg	:= ''
	Local cTitEmp		:= ''
	Local cJoin		:= ""	
	Local lCorpManage	:= fIsCorpManage( FWGrpCompany() )	// Verifica se o cliente possui Gest�o Corporativa no Grupo Logado
	Local cLayoutGC 	:= ''
	Local nStartEmp	:= 0
	Local nStartUnN	:= 0
	Local nEmpLength	:= 0
	Local nUnNLength	:= 0
	Local cDataDeAte	:= ''
	Local cInSitucao	:= ''
	Local cInCategor	:= ''
	Local cColumnSel	:= ""
	
	Default cMyAlias	:= GetNextAlias()	
	
	If lCorpManage
		cLayoutGC 	:= FWSM0Layout(cEmpAnt)
		nStartEmp	:= At("E",cLayoutGC)
		nStartUnN	:= At("U",cLayoutGC)
		nEmpLength	:= Len(FWSM0Layout(cEmpAnt, 1))
		nUnNLength	:= Len(FWSM0Layout(cEmpAnt, 2))	
	EndIf	
	
	cJoin := "%" + FWJoinFilial("SR3", "SRA") + "%"
	
	if(nOrderBy == 1)
		cOrderBy := "%R7_FILIAL, R7_MAT, R7_DATA%"
	elseIf(nOrderBy == 2)
		cOrderBy := "%R7_FILIAL, R7_DATA, R7_MAT%"
	endIf
	
	If cPaisLoc == "BRA"
		cColumnSel := "%R7_FILIAL, R7_MAT, RA_NOME, R7_DATA, R7_TIPO, R7_CATFUNC, (R3_VALOR / RA_HRSMES) AS VLRHR,R3_VALOR, R7_CARGO, R7_DESCCAR, R3_DTCDISS%"
	Else
		cColumnSel := "%R7_FILIAL, R7_MAT, RA_NOME, R7_DATA, R7_TIPO, R7_CATFUNC, (R3_VALOR / RA_HRSMES) AS VLRHR,R3_VALOR, R7_CARGO, R7_DESCCAR%"
	EndIf	
	
	MakeSqlExpr(cNomePerg)
	
	cDataDeAte:= "(R7_DATA BETWEEN '"+ DtoS(MV_PAR03) +"' AND '"+ DtoS(MV_PAR04) +"')"
	
	if(Len(MV_PAR07) > 0)		
		cInSitucao := "(RA_SITFOLH IN (" + fSqlIn(MV_PAR07,1) + "))"		 
	endIf
	
	MV_PAR09 := StrTran(MV_PAR09, '*')
	MV_PAR09 := StrTran(MV_PAR09, "'")
	if(Len(MV_PAR09) > 0)		
		cInCategor := "(R7_CATFUNC IN (" + fSqlIn(MV_PAR09,1) + "))"		 
	endIf
	
	BEGIN REPORT QUERY oSecFil	
	
		BeginSql alias cMyAlias
			COLUMN R7_DATA AS DATE
			SELECT %exp:cColumnSel%
			FROM %table:SR7% SR7
			INNER JOIN %table:SRA% SRA ON(SRA.RA_FILIAL = R7_FILIAL AND SRA.%notDel% AND SRA.RA_MAT = R7_MAT)
			INNER JOIN %table:SR3% SR3 ON(%exp:cJoin% AND SR3.%notDel% AND R3_MAT = R7_MAT AND R3_DATA = R7_DATA AND R3_SEQ = R7_SEQ)
			WHERE
			SR7.%notDel%
			ORDER BY %exp:cOrderBy%			
		EndSql	
	
	END REPORT QUERY oSecFil PARAM MV_PAR01, MV_PAR02, MV_PAR05, MV_PAR06,cDataDeAte,cInSitucao,MV_PAR08,cInCategor
	
	if(lCorpManage)
		
		//QUEBRA FILIAL
		DEFINE BREAK oBreakFil OF oReport WHEN {|| (cMyAlias)->R7_FILIAL }		
		oBreakFil:OnBreak({|x|cTitFil := OemToAnsi(STR0005) +" " + x, oReport:ThinLine()})
		oBreakFil:SetTotalText({||cTitFil})
		oBreakFil:SetTotalInLine(.T.)			
		DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("R7_MAT")  FUNCTION COUNT	BREAK oBreakFil NO END SECTION NO END REPORT
		DEFINE FUNCTION NAME "DB" FROM oSecCab:Cell("R3_VALOR")FUNCTION SUM	BREAK oBreakFil NO END SECTION NO END REPORT		
		
		//QUEBRA UNIDADE DE NEG�CIO
		DEFINE BREAK oBreakUni OF oReport WHEN {|| Substr((cMyAlias)->R7_FILIAL, nStartUnN, nUnNLength) }		
		oBreakUni:OnBreak({|x|cTitUniNeg := OemToAnsi(STR0006) +" " + x, oReport:ThinLine()})
		oBreakUni:SetTotalText({||cTitUniNeg})
		oBreakUni:SetTotalInLine(.T.)			
		DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("R7_MAT")  FUNCTION COUNT	BREAK oBreakUni NO END SECTION NO END REPORT
		DEFINE FUNCTION NAME "DB" FROM oSecCab:Cell("R3_VALOR")FUNCTION SUM	BREAK oBreakUni NO END SECTION NO END REPORT
		
		//QUEBRA EMPRESA
		DEFINE BREAK oBreakEmp OF oReport WHEN {|| Substr((cMyAlias)->R7_FILIAL, nStartEmp, nEmpLength) }		
		oBreakEmp:OnBreak({|x|cTitEmp := OemToAnsi(STR0007) + " " + x, oReport:ThinLine()})
		oBreakEmp:SetTotalText({||cTitEmp})
		oBreakEmp:SetTotalInLine(.T.)			
		DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("R7_MAT")  FUNCTION COUNT	BREAK oBreakEmp NO END SECTION NO END REPORT
		DEFINE FUNCTION NAME "DB" FROM oSecCab:Cell("R3_VALOR")FUNCTION SUM	BREAK oBreakEmp NO END SECTION NO END REPORT
			
	Else
		DEFINE BREAK oBreakFil OF oReport WHEN {|| (cMyAlias)->R7_FILIAL }		
		oBreakFil:OnBreak({|x|cTitFil := OemToAnsi(STR0005) +" " + x, oReport:ThinLine()})
		oBreakFil:SetTotalText({||cTitFil})
		oBreakFil:SetTotalInLine(.T.)			
		DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("R7_MAT")  FUNCTION COUNT	BREAK oBreakFil NO END SECTION NO END REPORT
		DEFINE FUNCTION NAME "DB" FROM oSecCab:Cell("R3_VALOR")FUNCTION SUM	BREAK oBreakFil NO END SECTION NO END REPORT	
	endIf
	
	oSecCab:SetParentQuery()
	oSecCab:SetParentFilter({|cParam|(cMyAlias)->R7_FILIAL == cParam},{||(cMyAlias)->R7_FILIAL})
	oSecFil:Print()
Return Nil

/*/{Protheus.doc} gtTpAltSal
	Retorna um vetor com os tipos de Altera��o Salarial
@author philipe.pompeu
@since 06/06/2016
@version P11
@return aReturn, vetor, cont�m todos os tipos de Altera��o Salarial
/*/
Static Function gtTpAltSal()
	Local aArea	:= GetArea()
	Local cMyAlias:= GetNextAlias()
	Local aResult	:= {}	
	
	BeginSql alias cMyAlias
		SELECT X5_CHAVE, X5_DESCRI
		FROM %table:SX5% SX5
		WHERE X5_FILIAL = %xFilial:SX5% AND X5_TABELA = %exp:'41'% AND %notDel%		  
	EndSql
	
	while ( (cMyAlias)->(!Eof()) )		
		aAdd(aResult,{AllTrim((cMyAlias)->X5_CHAVE), AllTrim((cMyAlias)->X5_DESCRI)})		
		(cMyAlias)->(dbSkip())
	End
	(cMyAlias)->(dbCloseArea())
	
	RestArea(aArea)
Return aResult

/*/{Protheus.doc} GetDescTip
	Retorna a descri��o do Tipo de Aumento
@author PHILIPE.POMPEU
@since 06/06/2016
@version P11
@param cTipo, caractere, c�digo
@return cResult, descri��o
/*/
Static Function GetDescTip(cTipo)
	Local cResult := ""
	Local nPos		:= 0
	Default cTipo := ""
	
	nPos := aScan(aTpsAltSal,{|x|x[1] == cTipo})
	
	if(nPos > 0)
		cResult := AllTrim(cTipo) + " - " + aTpsAltSal[nPos,2]
	else
		cResult := cTipo
	endIf
	
Return cResult

/*/{Protheus.doc} GetDescCBO
Retorna o c�digo CBO 2002
@author Wesley Alves Pereira
@since 14/10/2019
@version P12
@return cResult
/*/
Static Function GetDescCBO(cFilCont,cMatCont,dData,cTipo)
Local cResult := ""

DBSelectArea("SR7")
DBSetOrder(1)
If DBSeek(xFilial("SR7", cFilCont)+cMatCont+DTOS(dData)+cTipo)
	DBSelectArea("SRJ")
	DBSetOrder(1)
	If DBSeek(xFilial("SRJ", SR7->R7_FILIAL)+SR7->R7_FUNCAO)	
		If !Empty( SRJ->RJ_CODCBO )	
			cResult := SRJ->RJ_CODCBO	
		EndIf
	EndIf
EndIf

Return ( cResult )
