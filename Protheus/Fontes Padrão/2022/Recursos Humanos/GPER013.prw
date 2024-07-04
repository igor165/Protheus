#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'REPORT.CH'
#INCLUDE 'GPER013.CH'

/*/{Protheus.doc} GPER013
	Relatório de Critérios de Benefícios
@author PHILIPE.POMPEU
@since 24/04/2015
@version P12.1.5
@return Nil, Valor Nulo
/*/
Function GPER013()
	Local	aArea 	:= GetArea()
	Local	oReport:= Nil
	
	oReport := GetReport()
	
	if(oReport <> Nil)
		oReport:PrintDialog()
	endIf
	
	oReport := Nil
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} GetReport
	Retorna um objeto da Classe TReport utilizado na impressão do relatório;
	Define o título, o Pergunte utilizado e as seções do relatório;
@author PHILIPE.POMPEU
@since 24/04/2015
@version P12.1.5
@return oReport, Instância da Classe TReport
/*/
Static Function GetReport()
	Local oReport	:= Nil
	Local oSecFil	:= Nil
	Local oSecCab		:= Nil
	Local oSecItems	:= Nil
	
	Local cRptTitle	:= OemToAnsi(STR0001)
	Local cRptDescr	:= OemToAnsi(STR0002)
	Local aOrderBy	:= {}
	Local cNomePerg	:=	"GPR013"
	
	aAdd(aOrderBy,OemToAnsi(STR0003))//'1 - Filial + Código + Sequência'
	
	Pergunte(cNomePerg,.F.)
	
	DEFINE REPORT oReport NAME "GPR013" TITLE cRptTitle PARAMETER cNomePerg ACTION {|oReport| PrintReport(oReport,cNomePerg)} DESCRIPTION cRptDescr
	
	DEFINE SECTION oSecFil	OF oReport TITLE cRptTitle	TABLES "SJQ" ORDERS aOrderBy
		DEFINE CELL NAME "JQ_FILIAL" 	OF 	oSecFil ALIAS "SJQ"
		
	DEFINE SECTION oSecCab	OF oSecFil TITLE '' 			TABLES "SJQ"
		DEFINE CELL NAME "JQ_CODIGO" 	OF 	oSecCab ALIAS "SJQ"
		DEFINE CELL NAME "JQ_DESCR" 	OF 	oSecCab ALIAS "SJQ"
		DEFINE CELL NAME "JQ_PERINI" 	OF 	oSecCab ALIAS "SJQ"
		DEFINE CELL NAME "JQ_PERFIM" 	OF 	oSecCab ALIAS "SJQ"
		DEFINE CELL NAME "JQ_STATUS" 	OF 	oSecCab ALIAS "SJQ"
		
	DEFINE SECTION oSecItems	OF oSecCab TITLE '' 			TABLES "SJQ","SJS"
		DEFINE CELL NAME "JS_SEQ" 		OF 	oSecItems ALIAS "SJS"
		DEFINE CELL NAME "JS_TABELA" 	OF 	oSecItems ALIAS "SJS"
	
Return oReport


/*/{Protheus.doc} PrintReport
	Define a consulta à ser executada e as quebras do relatório;
	Imprime o relatório;
@author PHILIPE.POMPEU
@since 24/04/2015
@version P12.1.5
@param oReport, objeto, Instância da Classe TReport que será impresso
@param cNomePerg, caractere, Nome do Grupo de Perguntas utilizado no relatório
@return Nil, Valor Nulo
/*/
Static Function PrintReport(oReport,cNomePerg)
	Local oSecFil		:= oReport:Section(1)
	Local oSecCab		:= oSecFil:Section(1)
	Local oSecItems	:= oSecCab:Section(1)
	Local oBreakItems	:= Nil
	Local oBreakFil	:= Nil
	Local oBreakUni	:= Nil
	Local oBreakEmp	:= Nil
	Local lCorpManage	:= fIsCorpManage( FWGrpCompany() )	// Verifica se o cliente possui Gestão Corporativa no Grupo Logado
	Local cLayoutGC 	:= ''
	Local nStartEmp	:= 0
	Local nStartUnN	:= 0
	Local nEmpLength	:= 0
	Local nUnNLength	:= 0	
	Local cMyAlias	:= GetNextAlias()
	Local cTitFil		:= ''
	Local cTitUniNeg	:= ''
	Local cTitEmp		:= ''
	Local cTitCab		:= ''
	Local cTitItems	:= ''	
	Local cFilDe	:= ''
	Local cFilAte := ''
	
	If lCorpManage
		cLayoutGC 	:= FWSM0Layout(cEmpAnt)
		nStartEmp	:= At("E",cLayoutGC)
		nStartUnN	:= At("U",cLayoutGC)
		nEmpLength	:= Len(FWSM0Layout(cEmpAnt, 1))
		nUnNLength	:= Len(FWSM0Layout(cEmpAnt, 2))	
	EndIf
	
	MakeSqlExpr(cNomePerg)
	
	cFilDe := MV_PAR01	
	if(FWFilExist(cEmpAnt,cFilDe))
		cFilDe := FWxFilial('SJQ',cFilDe)	
	endIf
	
	cFilAte:= MV_PAR02
	if(FWFilExist(cEmpAnt,cFilAte))
		cFilAte:= FWxFilial('SJQ',cFilAte)	
	endIf	
	
	BEGIN REPORT QUERY oSecFil
		BeginSql alias cMyAlias	
			SELECT JQ_FILIAL,JQ_CODIGO,JQ_DESCR,JQ_PERINI,JQ_PERFIM,JQ_STATUS,JS_SEQ,JS_TABELA		
			FROM %table:SJQ% SJQ
			INNER JOIN %table:SJS% SJS ON(JS_FILIAL = JQ_FILIAL AND JQ_CODIGO = JS_CDAGRUP AND SJS.D_E_L_E_T_ = SJQ.D_E_L_E_T_)
			WHERE
			SJQ.%notDel%
			AND
			SJQ.JQ_FILIAL BETWEEN %exp:cFilDe% AND %exp:cFilAte% 
			ORDER BY JQ_FILIAL,JQ_CODIGO,JS_SEQ
		EndSql
	END REPORT QUERY oSecFil PARAM MV_PAR03
	
	oSecCab:SetParentQuery()
	oSecCab:SetParentFilter({|cParam|(cMyAlias)->JQ_FILIAL == cParam},{||(cMyAlias)->JQ_FILIAL})
	
	DEFINE BREAK oBreakItems OF oReport WHEN {|| ((cMyAlias)->JQ_FILIAL + (cMyAlias)->JQ_CODIGO)}
	oBreakItems:SetTotalInLine(.T.)	
	
	oSecItems:SetParentQuery()
	oSecItems:SetParentFilter({|cParam| ((cMyAlias)->JQ_FILIAL + (cMyAlias)->JQ_CODIGO) == cParam},{|| ((cMyAlias)->JQ_FILIAL + (cMyAlias)->JQ_CODIGO) })
	
	if(lCorpManage)		
		//QUEBRA FILIAL
		DEFINE BREAK oBreakFil OF oReport WHEN {|| (cMyAlias)->JQ_FILIAL }		
		oBreakFil:OnBreak({|x|cTitFil := OemToAnsi(STR0005) +" " + x, oReport:ThinLine()})
		oBreakFil:SetTotalText({||cTitFil})
		oBreakFil:SetTotalInLine(.T.)			
		DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("JQ_CODIGO")  FUNCTION COUNT	BREAK oBreakFil NO END SECTION NO END REPORT		
		
		//QUEBRA UNIDADE DE NEGÓCIO
		DEFINE BREAK oBreakUni OF oReport WHEN {|| Substr((cMyAlias)->JQ_FILIAL, nStartUnN, nUnNLength) }		
		oBreakUni:OnBreak({|x|cTitUniNeg := OemToAnsi(STR0006) +" " + x, oReport:ThinLine()})
		oBreakUni:SetTotalText({||cTitUniNeg})
		oBreakUni:SetTotalInLine(.T.)			
		DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("JQ_CODIGO")  FUNCTION COUNT	BREAK oBreakUni NO END SECTION NO END REPORT
		
		//QUEBRA EMPRESA
		DEFINE BREAK oBreakEmp OF oReport WHEN {|| Substr((cMyAlias)->JQ_FILIAL, nStartEmp, nEmpLength) }		
		oBreakEmp:OnBreak({|x|cTitEmp := OemToAnsi(STR0007) + " " + x, oReport:ThinLine()})
		oBreakEmp:SetTotalText({||cTitEmp})
		oBreakEmp:SetTotalInLine(.T.)			
		DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("JQ_CODIGO")  FUNCTION COUNT	BREAK oBreakEmp NO END SECTION NO END REPORT
			
	Else
		//QUEBRA FILIAL
		DEFINE BREAK oBreakFil OF oReport WHEN {|| (cMyAlias)->JQ_FILIAL}		
		oBreakFil:OnBreak({|x|cTitFil := OemToAnsi(STR0005) +" " + x, oReport:ThinLine()})
		oBreakFil:SetTotalText({||cTitFil})
		oBreakFil:SetTotalInLine(.T.)			
		DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("JQ_CODIGO")  FUNCTION COUNT	BREAK oBreakFil NO END SECTION NO END REPORT	
	endIf
	
	oSecFil:Print()	
Return Nil
