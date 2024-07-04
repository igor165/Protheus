#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'REPORT.CH'
#INCLUDE 'GPER970.CH'

/**********************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: GPER970.PRW    Autor: PHILIPE.POMPEU    Data:23/06/2016 		   ***
***********************************************************************************
***Descrição..: Imprime o relatório de Estabilidade do Funcionário              ***
***********************************************************************************
***Uso........:        																   ***
***********************************************************************************
***Parâmetros.:				     									            	   ***
***********************************************************************************
***Retorno....:                                                                 ***
***********************************************************************************
***					Alterações feitas desde a construção inicial       	 		   ***
***********************************************************************************
***RESPONSÁVEL.|DATA....|CÓDIGO|BREVE DESCRIÇÃO DA CORREÇÃO.....................***
***********************************************************************************
***P. Pompeu...|23/06/16|TU3264|Melhoria: Criação do Relatório.                 ***
**********************************************************************************/

/*/{Protheus.doc} GPER970
	Função responsável pela impressão do relatório de Estabilidade
@author PHILIPE.POMPEU
@since 23/06/2016
@version P11
@return Nil, Valor Nulo
/*/
Function GPER970()
	Local	aArea 	:= GetArea()
	Local	oReport:= Nil
		
	oReport := ReportDef()
	
	if(oReport <> Nil)	 
		oReport:PrintDialog()
	endIf
	
	oReport := Nil
	RestArea(aArea)	
Return Nil

/*/{Protheus.doc} ReportDef
	Define o Objeto da Classe TReport utilizado na impressão do relatório
@author PHILIPE.POMPEU
@since 23/06/2016
@version P11
@return oReport, instância da classe TReport
/*/
Static Function ReportDef()	
	Local oReport	:= Nil
	Local oSecFil	:= Nil
	Local oSecCab		:= Nil
	Local oSecItems	:= Nil
	Local cRptTitle	:= OemToAnsi(STR0001) //"Relatório de Estabilidade"
	Local cRptDescr	:= OemToAnsi(STR0002) //"Este programa emite a Impressão do Relatório de Estabilidade."
	Local aOrderBy	:= {}
	Local cNomePerg	:=	"GPER970"
	Local cMyAlias	:= GetNextAlias()	
	
	aAdd(aOrderBy, OemToAnsi(STR0003))//'1 - Matrícula + Data'
	aAdd(aOrderBy, OemToAnsi(STR0004))//'2 - Data + Matrícula'
	
	dbSelectarea("SX1")
	DbSetOrder(1)
	If ! dbSeek(cNomePerg)
		Help(" ",1,"NOPERG")
		Return 
	Else	
		Pergunte(cNomePerg,.F.)
	
		DEFINE REPORT oReport NAME "GPER970" TITLE cRptTitle PARAMETER cNomePerg ACTION {|oReport| PrintReport(oReport,cNomePerg,cMyAlias)} DESCRIPTION cRptDescr	TOTAL IN COLUMN
		
		DEFINE SECTION oSecFil OF oReport TITLE cRptTitle 	TABLES "RFX" TOTAL IN COLUMN ORDERS aOrderBy 
			DEFINE CELL NAME "RFX_FILIAL" 	OF 	oSecFil ALIAS "RFX"		
		
		DEFINE SECTION oSecCab OF oSecFil 	TITLE cRptTitle TABLES "RFX","SRA" TOTAL IN COLUMN // Title não pode ser vazio. Da erro na impressão do relatório no "Formato Tabela".
			DEFINE CELL NAME "RFX_MAT" 		OF 	oSecCab ALIAS "RFX" SIZE TamSx3("RA_MAT")[1]
			DEFINE CELL NAME "RA_NOME" 		OF 	oSecCab ALIAS "SRA" 
			DEFINE CELL NAME "RFX_TPESTB" 	OF 	oSecCab ALIAS "RFX"  SIZE 5 TITLE OemToAnsi(STR0009)
			DEFINE CELL NAME "DESCTIPO" 	OF 	oSecCab BLOCK {||GetDescTip((cMyAlias)->RFX_TPESTB)} SIZE 35 TITLE OemToAnsi(STR0008)		
			DEFINE CELL NAME "RFX_DATAI" 	OF 	oSecCab ALIAS "RFX" SIZE 15
			DEFINE CELL NAME "RFX_DATAF" 	OF 	oSecCab ALIAS "RFX" SIZE 15
	Endif
	
Return oReport

/*/{Protheus.doc} PrintReport
	Realiza a impressão do relatório
@author PHILIPE.POMPEU
@since 23/06/2016
@version P11
@param oReport, objeto, instância da classe TReport
@param cNomePerg, caractere, Nome do Pergunte
@param cMyAlias, caractere, Alias utilizado p/ consulta
@return nil, valor nulo
/*/
Static Function PrintReport(oReport, cNomePerg, cMyAlias)
	Local oSecFil		:= oReport:Section(1)
	Local oSecCab		:= oSecFil:Section(1)
	Local nOrderBy		:= oSecFil:GetOrder()
	Local cOrderBy		:= ''
	Local oBreakFil		:= Nil
	Local oBreakUni		:= Nil
	Local oBreakEmp		:= Nil
	Local cTitFil		:= ''
	Local cTitUniNeg	:= ''
	Local cTitEmp		:= ''
	Local lCorpManage	:= fIsCorpManage( FWGrpCompany() )	// Verifica se o cliente possui Gestão Corporativa no Grupo Logado
	Local cLayoutGC 	:= ''
	Local nStartEmp		:= 0
	Local nStartUnN		:= 0
	Local nEmpLength	:= 0
	Local nUnNLength	:= 0
	Local cDataDeAte	:= ''
	Local cInSitucao	:= ''
	Local cInCategor	:= ''
	Local lImpTabela	:= oReport:lXlstable
	Local lQueryEOF 	:= .F.
	Default cMyAlias	:= GetNextAlias()	
	
	If lCorpManage
		cLayoutGC 	:= FWSM0Layout(cEmpAnt)
		nStartEmp	:= At("E",cLayoutGC)
		nStartUnN	:= At("U",cLayoutGC)
		nEmpLength	:= Len(FWSM0Layout(cEmpAnt, 1))
		nUnNLength	:= Len(FWSM0Layout(cEmpAnt, 2))	
	EndIf
	
	if(nOrderBy == 1)
		cOrderBy := "%RFX_FILIAL, RFX_MAT, RFX_DATAI%"
	elseIf(nOrderBy == 2)
		cOrderBy := "%RFX_FILIAL, RFX_DATAI, RFX_MAT%"
	endIf
	
	MakeSqlExpr(cNomePerg)
	
	cDataDeAte:= "(RFX_DATAI >= '"+ DtoS(MV_PAR03) +"' AND RFX_DATAF <='"+ DtoS(MV_PAR04) +"')"	
	 
	if(Len(MV_PAR07) > 0)		
		cInSitucao := "(RA_SITFOLH IN (" + fSqlIn(MV_PAR07,1) + "))"		 
	endIf
	MV_PAR09 := StrTran(MV_PAR09, '*')
	if(Len(MV_PAR09) > 0)		
		cInCategor := "(RA_CATFUNC IN (" + fSqlIn(MV_PAR09,1) + "))"		 
	endIf	
	
	BEGIN REPORT QUERY oSecFil	
	
		BeginSql alias cMyAlias		
			SELECT RFX_FILIAL,RFX_MAT,RA_NOME,RFX_TPESTB,RFX_DATAI, RFX_DATAF
			FROM %table:RFX% RFX
			INNER JOIN %table:SRA% SRA ON(SRA.RA_FILIAL = RFX_FILIAL AND SRA.%notDel% AND SRA.RA_MAT = RFX_MAT)			
			WHERE
			RFX.%notDel%			
			ORDER BY %exp:cOrderBy%		
		EndSql	
	
	END REPORT QUERY oSecFil PARAM MV_PAR01, MV_PAR02, MV_PAR05, MV_PAR06,cDataDeAte,cInSitucao,MV_PAR08,cInCategor
	
	lQueryEOF := (cMyAlias)->(EOF())

	If!(lImpTabela .AND. lQueryEOF) //Se for impressão de Planilha no "Formato tabela"(lImpTabela), e resultado da query for vazio(lQueryEOF), não trará resultados na impressão do Formato Tabela.
		if(lCorpManage)
			//QUEBRA FILIAL
			DEFINE BREAK oBreakFil OF oReport WHEN {|| (cMyAlias)->RFX_FILIAL }		
			oBreakFil:OnBreak({|x|cTitFil := OemToAnsi(STR0005) +" " + x, oReport:ThinLine()})
			oBreakFil:SetTotalText({||cTitFil})
			oBreakFil:SetTotalInLine(.T.)			
			DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("RFX_MAT")  FUNCTION COUNT	BREAK oBreakFil NO END SECTION NO END REPORT		
			
			//QUEBRA UNIDADE DE NEGÓCIO
			DEFINE BREAK oBreakUni OF oReport WHEN {|| Substr((cMyAlias)->RFX_FILIAL, nStartUnN, nUnNLength) }		
			oBreakUni:OnBreak({|x|cTitUniNeg := OemToAnsi(STR0006) +" " + x, oReport:ThinLine()})
			oBreakUni:SetTotalText({||cTitUniNeg})
			oBreakUni:SetTotalInLine(.T.)			
			DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("RFX_MAT")  FUNCTION COUNT	BREAK oBreakUni NO END SECTION NO END REPORT
			
			//QUEBRA EMPRESA
			DEFINE BREAK oBreakEmp OF oReport WHEN {|| Substr((cMyAlias)->RFX_FILIAL, nStartEmp, nEmpLength) }		
			oBreakEmp:OnBreak({|x|cTitEmp := OemToAnsi(STR0007) + " " + x, oReport:ThinLine()})
			oBreakEmp:SetTotalText({||cTitEmp})
			oBreakEmp:SetTotalInLine(.T.)			
			DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("RFX_MAT")  FUNCTION COUNT	BREAK oBreakEmp NO END SECTION NO END REPORT			
		Else
			DEFINE BREAK oBreakFil OF oReport WHEN {|| (cMyAlias)->RFX_FILIAL }		
			oBreakFil:OnBreak({|x|cTitFil := OemToAnsi(STR0005) +" " + x, oReport:ThinLine()})
			oBreakFil:SetTotalText({||cTitFil})
			oBreakFil:SetTotalInLine(.T.)			
			DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("RFX_MAT")  FUNCTION COUNT	BREAK oBreakFil NO END SECTION NO END REPORT	
		EndIf
	EndIf
	oSecCab:SetParentQuery()
	oSecCab:SetParentFilter({|cParam|(cMyAlias)->RFX_FILIAL == cParam},{||(cMyAlias)->RFX_FILIAL})
	oSecFil:Print()
Return Nil

/*/{Protheus.doc} GetDescTip
	Retorna a descrição do Tipo de Aumento
@author PHILIPE.POMPEU
@since 23/06/2016
@version P11
@param cTipo, caractere, código
@return cResult, descrição
/*/
Static Function GetDescTip(cTipo)
	Local cResult := ""
	Default cTipo := ""
	
	cResult := AllTrim(fDescRCC("S053", cTipo, 1, 3, 4, 100))	
	
Return cResult
