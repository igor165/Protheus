#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'REPORT.CH'
#INCLUDE 'GPER980.CH'

/**********************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: GPER980.PRW    Autor: Leandro Drumond	   :19/08/2016 		    ***
***********************************************************************************
***Descrição..: Imprime o relatório de Histórico de Afastamentos                ***
***********************************************************************************
***Parâmetros.:				    								                ***
***********************************************************************************
***Retorno....:                                                                 ***
***********************************************************************************
***					Alterações feitas desde a construção inicial       	 	    ***
***********************************************************************************
***RESPONSÁVEL.|DATA....|CÓDIGO|BREVE DESCRIÇÃO DA CORREÇÃO.....................***
***********************************************************************************
***         ...|        |      |                                                ***
***Cícero Alves|08/09/16|TVXPEZ|Ajuste para verificar se existe o grupo de perg.***
**********************************************************************************/

/*/{Protheus.doc} GPER980
	Função responsável pela impressão do relatório de Funcionários por Cargos
@author Leandro Drumond
@since 19/08/2016
@version P11
@return Nil, Valor Nulo
/*/
Function GPER980()
Local	aArea 	:= GetArea()
Local	oReport	:= Nil

oReport := ReportDef()

oReport:PrintDialog()

RestArea(aArea)	

Return Nil

/*/{Protheus.doc} ReportDef
	Define o Objeto da Classe TReport utilizado na impressão do relatório
@author Leandro Drumond
@since 19/08/2016
@version P11
@return oReport, instância da classe TReport
/*/
Static Function ReportDef()	
Local oReport	:= Nil
Local oSecFil	:= Nil
Local oSecCab	:= Nil
Local cRptTitle	:= OemToAnsi(STR0001) //"Relatório de Histórico de Afastamentos"
Local cRptDescr	:= OemToAnsi(STR0002) //"Este programa emite a Impressão do Relatório de Histórico de Afastamentos."
Local aOrderBy	:= {}
Local cNomePerg	:=	"GPER980"
Local cMyAlias	:= GetNextAlias()	

aAdd(aOrderBy, OemToAnsi(STR0003))//'1 - Filial + Matrícula'
aAdd(aOrderBy, OemToAnsi(STR0004))//'2 - Filial + Nome'
aAdd(aOrderBy, OemToAnsi(STR0005))//'3 - Filial + Centro de Custo'

//--Verifica se o grupo de perguntas existe na base
dbSelectarea("SX1")
DbSetOrder(1)
If ! dbSeek(cNomePerg)
	Help(" ",1,"NOPERG")
	Return 
EndIf
Pergunte(cNomePerg,.F.)

DEFINE REPORT oReport NAME "GPER980" TITLE cRptTitle PARAMETER cNomePerg ACTION {|oReport| PrintReport(oReport,cNomePerg,cMyAlias)} DESCRIPTION cRptDescr	TOTAL IN COLUMN

DEFINE SECTION oSecFil OF oReport TITLE "Cabeçalho" 	TABLES "SRA" TOTAL IN COLUMN ORDERS aOrderBy
	DEFINE CELL NAME "RA_FILIAL" 	OF 	oSecFil ALIAS "SRA" SIZE Max(6,Len(xFilial("SRA")))
	DEFINE CELL NAME "RA_MAT" 	 	OF 	oSecFil ALIAS "SRA" SIZE 22
	DEFINE CELL NAME "RA_NOME" 	 	OF 	oSecFil ALIAS "SRA" SIZE 30

oSecFil:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao

DEFINE SECTION oSecCab OF oSecFil 	TITLE 'Itens' TABLES "SRA","SR8" TOTAL IN COLUMN
	DEFINE CELL NAME "R8_DATAINI" 	OF 	oSecCab ALIAS "SR8" SIZE 14
	DEFINE CELL NAME "R8_DATAFIM"	OF 	oSecCab ALIAS "SR8" SIZE 14
	DEFINE CELL NAME "MOTIVO"		OF 	oSecCab BLOCK {|| (cMyAlias)->MOTIVO + " " + FDesc("RCM",(cMyAlias)->MOTIVO,"RCM_DESCRI",60)} SIZE 65 TITLE STR0011	// "Motivo de Afastamento"
	DEFINE CELL NAME "RA_CC" 	 	OF 	oSecCab BLOCK {|| (cMyAlias)->RA_CC + " " + (cMyAlias)->CTT_DESC01 } SIZE 40  
	
oSecCab:SetLeftMargin(2)
oSecCab:SetTotalInLine(.F.) 
oSecCab:SetHeaderBreak(.T.)  

Return oReport

/*/{Protheus.doc} PrintReport
	Realiza a impressão do relatório
@author Leandro Drumond
@since 18/08/2016
@version P11
@param oReport, objeto, instância da classe TReport
@param cNomePerg, caractere, Nome do Pergunte
@param cMyAlias, caractere, Alias utilizado p/ consulta
@return nil, valor nulo
/*/
Static Function PrintReport(oReport, cNomePerg, cMyAlias)
Local oSecFil		:= oReport:Section(1)
Local oSecCab		:= oSecFil:Section(1)
Local oBreakFil		:= Nil
Local oBreakUni		:= Nil
Local oBreakEmp		:= Nil
Local oBreakCC		:= Nil
Local cTitFil		:= ""
Local cTitUniNeg	:= ""
Local cTitEmp		:= ""
Local cJoinCTT		:= ""
Local cCatQuery		:= ""
Local cOrder		:= ""
Local cCategoria	:= MV_PAR03
Local dDataDe		:= MV_PAR05
Local dDataAte		:= MV_PAR06
Local lCorpManage	:= fIsCorpManage( FWGrpCompany() )	// Verifica se o cliente possui Gestão Corporativa no Grupo Logado
Local cLayoutGC 	:= ''
Local nStartEmp		:= 0
Local nStartUnN		:= 0
Local nEmpLength	:= 0
Local nUnNLength	:= 0
Local nReg			:= 0
Local nOrdem		:= oSecFil:GetOrder()

If nOrdem == 1
	cOrder := "%SRA.RA_FILIAL,SRA.RA_MAT,SR8.R8_DATAINI%"
ElseIf nOrdem == 2
	cOrder := "%SRA.RA_FILIAL,SRA.RA_NOME,SR8.R8_DATAINI%"
ElseIf nOrdem == 3
	cOrder := "%SRA.RA_FILIAL,SRA.RA_CC,SRA.RA_MAT,SR8.R8_DATAINI%"
EndIf

If lCorpManage
	cLayoutGC 	:= FWSM0Layout(cEmpAnt)
	nStartEmp	:= At("E",cLayoutGC)
	nStartUnN	:= At("U",cLayoutGC)
	nEmpLength	:= Len(FWSM0Layout(cEmpAnt, 1))
	nUnNLength	:= Len(FWSM0Layout(cEmpAnt, 2))	
EndIf	

cCatQuery := ""
For nReg:=1 to Len(cCategoria)
	cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCategoria)
		cCatQuery += "," 
	Endif
Next nReg        
cCatQuery := "%" + cCatQuery + "%"

cJoinCTT := "%" + FWJoinFilial("CTT", "SRA") + "%"

MakeSqlExpr(cNomePerg)

BEGIN REPORT QUERY oSecFil	

	BeginSql alias cMyAlias		
		SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_CC, R8_DATAINI, R8_DATAFIM, R8_TIPOAFA AS MOTIVO, CTT_DESC01
		FROM %table:SRA% SRA
		INNER JOIN %table:SR8% SR8 ON SR8.%notDel% AND R8_FILIAL = RA_FILIAL AND R8_MAT = RA_MAT
		LEFT JOIN %table:CTT% CTT ON CTT.%notDel% AND %exp:cJoinCTT% AND CTT_CUSTO = RA_CC
		WHERE
		SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%)	AND
		SR8.R8_DATAINI >= (%exp:DtoS(dDataDe)%) AND
		SR8.R8_DATAINI <= (%exp:DtoS(dDataAte)%) AND
		SRA.%notDel%
		ORDER BY %exp:cOrder%	
	EndSql	

END REPORT QUERY oSecFil PARAM MV_PAR01, MV_PAR02, MV_PAR04

//QUEBRA CENTRO DE CUSTO
If !(cMyAlias)->(Eof())
	If nOrdem == 3
		DEFINE BREAK oBreakCC OF oReport WHEN {|| (cMyAlias)->RA_FILIAL + (cMyAlias)->RA_CC}
		oBreakCC:OnBreak({|x|cTitFil := STR0008 + x, oReport:ThinLine(),oSecFil:SetHeaderSection(.T.)}) //"Total de Afastamentos no Centro de Custos "		
		oBreakCC:SetTotalText({||cTitFil})
		oBreakCC:SetTotalInLine(.F.)
		DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("R8_DATAINI")  FUNCTION COUNT BREAK oBreakCC NO END SECTION NO END REPORT
	EndIf

	//QUEBRA FILIAL
	DEFINE BREAK oBreakFil OF oReport WHEN {|| (cMyAlias)->RA_FILIAL }		
	oBreakFil:OnBreak({|x|cTitFil := STR0007 + x, oReport:ThinLine(),oSecFil:SetHeaderSection(.T.)}) //"Total de Afastamentos na Filial "
	oBreakFil:SetTotalText({||cTitFil})
	oBreakFil:SetTotalInLine(.F.)
	DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("R8_DATAINI")  FUNCTION COUNT BREAK oBreakFil NO END SECTION NO END REPORT

	If(lCorpManage)
		
		//QUEBRA UNIDADE DE NEGÓCIO
		DEFINE BREAK oBreakUni OF oReport WHEN {|| Substr((cMyAlias)->RA_FILIAL, nStartUnN, nUnNLength) }		
		oBreakUni:OnBreak({|x|cTitUniNeg := STR0009 + x, oReport:ThinLine(),oSecFil:SetHeaderSection(.T.)}) //"Total de Afastamentos na Unidade de Negócio "
		oBreakUni:SetTotalText({||cTitUniNeg})
		oBreakUni:SetTotalInLine(.F.)
		DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("R8_DATAINI")  FUNCTION COUNT BREAK oBreakUni NO END SECTION NO END REPORT
		
		//QUEBRA EMPRESA
		DEFINE BREAK oBreakEmp OF oReport WHEN {|| Substr((cMyAlias)->RA_FILIAL, nStartEmp, nEmpLength) }		
		oBreakEmp:OnBreak({|x|cTitEmp := STR0010 + x, oReport:ThinLine(),oSecFil:SetHeaderSection(.T.)}) //"Total de Afastamentos na Empresa "
		oBreakEmp:SetTotalText({||cTitEmp})
		oBreakEmp:SetTotalInLine(.F.)
		DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("R8_DATAINI")  FUNCTION COUNT	BREAK oBreakEmp NO END SECTION NO END REPORT
			
	EndIf

	If oReport:nDevice == 4 // Planilha Excel
		oSecCab:SetParentFilter({|cParam|If((cMyAlias)->RA_FILIAL+(cMyAlias)->RA_MAT == cParam,(oSecFil:SetHeaderSection(.T.),oReport:OnPageBreak({|| oSecFil:SetHeaderSection(.T.),oSecFil:Init(), oSecFil:PrintLine()}),.T.),.F.)},{||(cMyAlias)->RA_FILIAL+(cMyAlias)->RA_MAT})
	Else
		oSecCab:SetParentFilter({|cParam|If((cMyAlias)->RA_FILIAL+(cMyAlias)->RA_MAT == cParam,(oSecFil:SetHeaderSection(.F.),oReport:OnPageBreak({|| oSecFil:SetHeaderSection(.T.),oSecFil:Init(), oSecFil:PrintLine()}),.T.),.F.)},{||(cMyAlias)->RA_FILIAL+(cMyAlias)->RA_MAT})	
	EndIf

EndIf

If oReport:nDevice == 4 // Planilha Excel
	oSecCab:SetHeaderPage(.T.)	//Exibe Cabecalho da Secao
Else
	oSecCab:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
EndIf

oSecCab:SetParentQuery()
oSecFil:Print()

Return Nil
