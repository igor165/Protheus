#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'REPORT.CH'
#INCLUDE 'TRMR100.ch'

/**********************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: TRMR100.PRW    Autor: RH_INOV     Data:27/08/15                 ***
***********************************************************************************
***Descrição..: Relatório de Vencimento de Cursos                               ***
***********************************************************************************
***Uso........: SIGATRM                                                         ***
***********************************************************************************
***Parâmetros.: ${param}, ${param_type}, ${param_descr}                         ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***                ALTERAÇÕES FEITAS DESDE A CONSTRUÇÃO INICIAL                 ***
***********************************************************************************
***Chamado....:                                                                 ***
**********************************************************************************/

/*/{Protheus.doc} TRMR100
	Relatorio de Vencimento de Cursos
@author RH_INOV
@since 27/08/15
@version P12.1.8
@return Nil, sem retorno 
/*/
Function TRMR100()
	Local aArea 	:= GetArea()
	Local oReport	:= Nil
	Private cAxAlias:= GetNextAlias()

	oReport := ReportDef()
	
	if(oReport <> Nil)
		oReport:PrintDialog()
	endIf
	
	oReport := Nil
	RestArea(aArea)
	
Return (Nil)

/*/{Protheus.doc} ReportDef
	Definicao do objeto do relatorio personalizavel e das secoes que serao utilizadas 
@author RH_INOV
@since 27/08/15
@version P12.1.8
@return oReport, objeto,instância de TReport
/*/
Static Function ReportDef()
	Local oReport	:= Nil	
	Local oSecFunc	:= Nil	
	Local cRptTitle	:= OemToAnsi(STR0001)
	Local cRptDescr	:= OemToAnsi(STR0002)
	Local aOrderBy	:= {}
	Local cNomePerg	:=	"TRMR100"
	
	aAdd(aOrderBy,OemToAnsi(STR0003))
	aAdd(aOrderBy,OemToAnsi(STR0004))
	aAdd(aOrderBy,OemToAnsi(STR0005))
	
	Pergunte(cNomePerg,.F.)
	
	DEFINE REPORT oReport NAME "TRMR100" TITLE cRptTitle PARAMETER cNomePerg ACTION {|oReport| PrintReport(oReport,cNomePerg)} DESCRIPTION cRptDescr
		
	DEFINE SECTION oSecFunc	OF oReport TITLE cRptTitle	TABLES "SRA","CTT","RA4","RA1","RA2" ORDERS aOrderBy
		DEFINE CELL NAME "RA_FILIAL" 	OF 	oSecFunc ALIAS "SRA"
		DEFINE CELL NAME "RA_CC" 	 	OF 	oSecFunc ALIAS "SRA"
		DEFINE CELL NAME "CTT_DESC01" 	OF 	oSecFunc ALIAS "CTT"	TITLE STR0023	Size 25
		DEFINE CELL NAME "RA_MAT" 	 	OF 	oSecFunc ALIAS "SRA"
		DEFINE CELL NAME "RA_NOME" 	 	OF 	oSecFunc ALIAS "SRA"
		DEFINE CELL NAME "RA4_CURSO" 	OF 	oSecFunc ALIAS "RA4"
		DEFINE CELL NAME "RA1_DESC" 	OF 	oSecFunc ALIAS "RA1"
		DEFINE CELL NAME "RA4_VALIDA" 	OF 	oSecFunc ALIAS "RA4" Title STR0008
		DEFINE CELL NAME "DIASVENC" 	OF 	oSecFunc Align Center  Size 7 BLOCK {|| fRetDVenc() }  Title STR0009
		DEFINE CELL NAME "SITUACAO" 	OF 	oSecFunc BLOCK {|| fRetSit() } Title STR0010 SIZE 15
		DEFINE CELL NAME "RA2_DATAIN" 	OF 	oSecFunc ALIAS "RA2" Title STR0006
		DEFINE CELL NAME "QTDDIAS"  	OF 	oSecFunc Align Center Size 7 BLOCK {|| Iif(! Empty((cAxAlias)->RA2_DATAIN) .AND. ! Empty((cAxAlias)->RA2_DATAFI ),Alltrim(Str((cAxAlias)->RA2_DATAFI - (cAxAlias)->RA2_DATAIN + 1)),"-") } Title STR0007 
		DEFINE CELL NAME "ORIGEM" 		OF 	oSecFunc Title STR0022
		
	oSecFunc:SetHeaderBreak(.T.)
	
	
	oReport:SetLandScape(.T.)
Return (oReport)

/*/{Protheus.doc} PrintReport
	Impressão do Relatorio
@author RH_INOV
@since 27/08/15
@version P12.1.8
@param oReport, objeto, instância de TReport
@param cNomePerg, caractere, (Descrição do parâmetro)
@return Nil, sem retorno
/*/
Static Function PrintReport(oReport,cNomePerg)
	Local oSecFunc		:= oReport:Section(1)	
	Local nOrdem		:= oSecFunc:GetOrder()
	Local cSitQuery 	:= ""
	Local cSituacao 	:= ""
	Local cCatQuery 	:= ""
	Local cCategoria	:= ""
	Local nI			:= 0
	Local cOrdem		:= ""	
	Local cTitFil		:= ''
	Local cTitUniNeg	:= ''
	Local cTitEmp		:= ''	
	Local oBreakFil		:= Nil
	Local oBreakUni		:= Nil
	Local oBreakEmp		:= Nil
	Local cBetween		:= ""
	Local aWhere		:= {}
	Local cWhere		:= ""
	Local aMatri		:= {}
	Local cCellBreak	:= ""
	Local aJoins		:= {}	
	Local lCorpManage	:= fIsCorpManage( FWGrpCompany() )
	Local cLayoutGC 	:= ''
	Local nStartEmp		:= 0
	Local nStartUnN		:= 0
	Local nEmpLength	:= 0
	Local nUnNLength	:= 0
	Local bComp 		:= Nil
	Local bAdd 			:= Nil	
			
	MakeSqlExpr(cNomePerg)
	
	aAdd(aWhere,MV_PAR01)
	aAdd(aWhere,MV_PAR02)
	aAdd(aWhere,MV_PAR03)	
		
	cCategoria := MV_PAR04
	cCatQuery := ""
	For nI:=1 to Len(cCategoria)
		cCatQuery += "'"+ SubStr(cCategoria,nI,1) +"'"
		If ( nI+1) <= Len(cCategoria)
			cCatQuery += "," 
		Endif
	Next nI
	
	aAdd(aWhere,"(RA_CATFUNC IN("+cCatQuery+"))")	
	
	cSituacao := MV_PAR05
	cSitQuery := ""
	For nI:=1 to Len(cSituacao)
		cSitQuery += "'"+ SubStr(cSituacao,nI,1) +"'"
		If ( nI+1) <= Len(cSituacao)
			cSitQuery += "," 
		Endif
	Next nI	
	
	aAdd(aWhere,"(RA_SITFOLH IN("+cSitQuery+"))")
	
	If ! Empty(MV_PAR08) .AND. ! Empty(MV_PAR09)
		cBetween := "(RA4_VALIDA BETWEEN '"+ DtoS(MV_PAR08) +"' AND '"+ DtoS(MV_PAR09) +"')"	
	ElseIf Empty(MV_PAR08) .AND. ! Empty(MV_PAR09)
		cBetween := "RA4_VALIDA <= "+ DtoS(MV_PAR09) 
	ElseIf ! Empty(MV_PAR08) .AND. Empty(MV_PAR09)	
		cBetween := "RA4_VALIDA >= "+ DtoS(MV_PAR08) 
	EndIf
	
	
	aAdd(aWhere,cBetween)	
	
	//Remove posições inválidas
	for nI:= Len(aWhere) to 1 Step - 1		
		if(Empty(aWhere[nI]))
			aDel(aWhere,nI)
			aSize(aWhere,Len(aWhere)-1)
		endIf				
	next nI
						
	cWhere := ""
	for nI:= 1 to Len(aWhere)		
		cWhere+= aWhere[nI]
		if(nI < Len(aWhere))
			cWhere+=" AND "
		endIf
	next nI		
	
	aWhere := {}
	aAdd(aWhere,'%'+ cWhere)
	aAdd(aWhere,'%'+ cWhere)	
	
	if!(Empty(MV_PAR06))		
		aWhere[1]+= ' AND ' + MV_PAR06
		aWhere[2]+= ' AND ' + StrTran(MV_PAR06,'Q3_CARGO','RA_CARGO')			
	endIf
	
	if!(Empty(MV_PAR07))			
		aWhere[2]+= ' AND ' + MV_PAR07
		aWhere[1]+= ' AND ' + StrTran(MV_PAR07,'RJ_FUNCAO','RA_CODFUNC')				
	endIf
	
	aWhere[1]+='%'
	aWhere[2]+='%'
	
	Do Case
		Case (nOrdem == 1) // filial 
			cTitFil := STR0011
			cCellBreak:= "RA_FILIAL"						 
			cOrdem  := "%RA_FILIAL,RA4_VALIDA,RA_MAT%"		
		Case (nOrdem == 2) // centro de custo
			cTitFil := STR0013
			cCellBreak:= "RA_CC"			
			cOrdem  := "%RA_FILIAL,RA_CC,RA4_VALIDA%"			
		Case (nOrdem == 3) // curso 
			cTitFil := STR0014
			cCellBreak:= "RA4_CURSO"
			cOrdem  := "%RA_FILIAL,RA4_CURSO,RA4_VALIDA%"				
	EndCase	
	
	cSitQuery := STR0021
	cCatQuery := STR0020
		
	aAdd(aJoins,'%'+ FWJoinFilial('CTT', 'SRA') +'%')
	aAdd(aJoins,'%'+ FWJoinFilial('RA4', 'SRA') +'%')
	aAdd(aJoins,'%'+ FWJoinFilial('RA1', 'RA4') +'%')
	aAdd(aJoins,'%'+ FWJoinFilial('RA2', 'RA4') +'%')
	aAdd(aJoins,'%'+ FWJoinFilial('RA3', 'RA2') +'%')
	aAdd(aJoins,'%'+ FWJoinFilial('RA5', 'SRA') +'%')	
	aAdd(aJoins,'%'+ FWJoinFilial('RAL', 'SRA') +'%')
	aAdd(aJoins,'%'+ FWJoinFilial('SQ3', 'SRA') +'%') //8
	aAdd(aJoins,'%'+ FWJoinFilial('SRJ', 'SRA') +'%') //9	

	BEGIN REPORT QUERY oSecFunc
		BeginSql alias cAxAlias				
			SELECT RA_FILIAL, RA_CC, CTT_DESC01,RA_MAT, RA_NOME, RA4_CURSO, RA1_DESC, RA2_DATAIN, RA2_DATAFI, RA3_RESERV,%exp:cSitQuery% as ORIGEM, 
			MAX(RA4_VALIDA) AS RA4_VALIDA			 		
			FROM %table:SRA% SRA
			LEFT JOIN %table:CTT% CTT ON (%exp:aJoins[1]% AND CTT_CUSTO  = RA_CC  AND CTT.%notDel%)			
			INNER JOIN %table:RA4% RA4 ON (%exp:aJoins[2]% AND RA4_MAT = RA_MAT AND RA4.RA4_VALIDA != '' AND RA4.%notDel% )
			INNER JOIN %table:RA1% RA1 ON (%exp:aJoins[3]% AND RA1_CURSO  = RA4_CURSO  AND RA1.%notDel%)
			LEFT  JOIN %table:RA2% RA2 ON (%exp:aJoins[4]% AND RA2_CURSO  = RA4_CURSO  AND RA2.%notDel% AND RA2_REALIZ IN('','N') AND RA2_DATAIN >= %exp: DToS(dDataBase)%)			
			LEFT  JOIN %table:RA3% RA3 ON (%exp:aJoins[5]% AND RA3_MAT = RA_MAT AND RA3_CURSO = RA4_CURSO AND RA3.%notDel%
			AND RA3_CALEND = RA2_CALEND AND RA3_TURMA = RA2_TURMA AND RA3_CURSO = RA2_CURSO)			
			INNER JOIN %table:RA5% RA5 ON (%exp:aJoins[6]% AND RA5_CARGO  = RA_CARGO   AND RA5_CURSO = RA4_CURSO AND RA5.%notDel%)			
			INNER JOIN %table:SQ3% SQ3 ON (%exp:aJoins[8]% AND Q3_CARGO   = RA_CARGO   AND SQ3.%notDel%)
			WHERE SRA.%notDel%
			AND
			%exp:aWhere[1]%
			GROUP BY RA_FILIAL, RA_CC, CTT_DESC01, RA_MAT, RA_NOME, RA4_CURSO, RA1_DESC, RA2_DATAIN, RA2_DATAFI, RA3_RESERV
			UNION
			SELECT RA_FILIAL, RA_CC, CTT_DESC01, RA_MAT, RA_NOME, RA4_CURSO, RA1_DESC, RA2_DATAIN, RA2_DATAFI, RA3_RESERV,%exp:cCatQuery% as ORIGEM, 
			MAX(RA4_VALIDA) AS RA4_VALIDA			 		
			FROM %table:SRA% SRA
			LEFT JOIN %table:CTT% CTT ON (%exp:aJoins[1]% AND CTT_CUSTO  = RA_CC  AND CTT.%notDel%)			
			INNER JOIN %table:RA4% RA4 ON (%exp:aJoins[2]% AND RA4_MAT = RA_MAT AND RA4.RA4_VALIDA != '' AND RA4.%notDel%)
			INNER JOIN %table:RA1% RA1 ON (%exp:aJoins[3]% AND RA1_CURSO  = RA4_CURSO  AND RA1.%notDel%)
			LEFT  JOIN %table:RA2% RA2 ON (%exp:aJoins[4]% AND RA2_CURSO  = RA4_CURSO  AND RA2.%notDel% AND RA2_REALIZ IN('','N') AND RA2_DATAIN >= %exp: DToS(dDataBase)%)			
			LEFT  JOIN %table:RA3% RA3 ON (%exp:aJoins[5]% AND RA3_MAT = RA_MAT AND RA3_CURSO = RA4_CURSO AND RA3.%notDel%
			AND RA3_CALEND = RA2_CALEND AND RA3_TURMA = RA2_TURMA AND RA3_CURSO = RA2_CURSO)	
			INNER JOIN %table:RAL% RAL ON (%exp:aJoins[7]% AND RAL_FUNCAO = RA_CODFUNC AND RAL_CURSO = RA4_CURSO AND RAL.%notDel%)		
			INNER JOIN %table:SRJ% SRJ ON (%exp:aJoins[9]% AND RJ_FUNCAO  = RA_CODFUNC AND SRJ.%notDel%)
			WHERE SRA.%notDel%
			AND
			%exp:aWhere[2]%			
			GROUP BY RA_FILIAL, RA_CC, CTT_DESC01, RA_MAT, RA_NOME, RA4_CURSO, RA1_DESC, RA2_DATAIN, RA2_DATAFI, RA3_RESERV
			ORDER BY %exp:cOrdem%
		EndSql
	END REPORT QUERY oSecFunc	
				
	If lCorpManage
		
		If nOrdem == 1	

			cLayoutGC 	:= FWSM0Layout(cEmpAnt)
			nStartEmp	:= At("E",cLayoutGC)
			nStartUnN	:= At("U",cLayoutGC)
			nEmpLength	:= Len(FWSM0Layout(cEmpAnt, 1))
			nUnNLength	:= Len(FWSM0Layout(cEmpAnt, 2))
			
			aAdd(aMatri,{})
			aAdd(aMatri,{})
			aAdd(aMatri,{})		
			
			bAdd := {||{;
			Substr((cAxAlias)->RA_FILIAL, nStartEmp, nEmpLength),;
			Substr((cAxAlias)->RA_FILIAL, nStartUnN, nUnNLength),;
			(cAxAlias)->RA_FILIAL,;
			(cAxAlias)->RA_MAT}}		
				
			bComp:= {|x|x[1]+x[2]+x[3]+x[4] == ;
			Substr((cAxAlias)->RA_FILIAL, nStartEmp, nEmpLength)+;
			Substr((cAxAlias)->RA_FILIAL, nStartUnN, nUnNLength)+;
			(cAxAlias)->RA_FILIAL+;
			(cAxAlias)->RA_MAT}		

			//QUEBRA FILIAL
			DEFINE BREAK oBreakFil OF oReport WHEN {|| (cAxAlias)->RA_FILIAL }		
			oBreakFil:OnBreak({|x|cTitFil := OemToAnsi(STR0011) +" " + x, oReport:ThinLine()})
			oBreakFil:SetTotalText({||cTitFil})
			oBreakFil:SetTotalInLine(.T.)			
			DEFINE FUNCTION NAME "DA" FROM oSecFunc:Cell("RA_MAT" )  FUNCTION COUNT	BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 99999" TITLE STR0012		
			oBreakFil:aFunction[1]:bCondition := {||CountCond(aMatri[3],bComp,bAdd)}	
			oBreakFil:bOnPrintTotal:= {||aSize(aMatri[3],0)}				
			
			//QUEBRA UNIDADE DE NEGÓCIO
			DEFINE BREAK oBreakUni OF oReport WHEN {|| Substr((cAxAlias)->RA_FILIAL, nStartUnN, nUnNLength) }		
			oBreakUni:OnBreak({|x|cTitUniNeg := OemToAnsi(STR0024) +" " + x, oReport:ThinLine()})
			oBreakUni:SetTotalText({||cTitUniNeg})
			oBreakUni:SetTotalInLine(.T.)			
			DEFINE FUNCTION NAME "DA" FROM oSecFunc:Cell("RA_MAT" )  FUNCTION COUNT	BREAK oBreakUni NO END SECTION NO END REPORT PICTURE "@E 99999" TITLE STR0012
			oBreakUni:aFunction[1]:bCondition := {||CountCond(aMatri[2],bComp,bAdd)}	
			oBreakUni:bOnPrintTotal:= {||aSize(aMatri[2],0)}
			
			//QUEBRA EMPRESA
			DEFINE BREAK oBreakEmp OF oReport WHEN {|| Substr((cAxAlias)->RA_FILIAL, nStartEmp, nEmpLength) }		
			oBreakEmp:OnBreak({|x|cTitEmp := OemToAnsi(STR0025) + " " + x, oReport:ThinLine()})
			oBreakEmp:SetTotalText({||cTitEmp})
			oBreakEmp:SetTotalInLine(.T.)			
			DEFINE FUNCTION NAME "DA" FROM oSecFunc:Cell("RA_MAT" )  FUNCTION COUNT	BREAK oBreakEmp NO END SECTION NO END REPORT PICTURE "@E 99999" TITLE STR0012
			oBreakEmp:aFunction[1]:bCondition := {||CountCond(aMatri[1],bComp,bAdd)}	
			oBreakEmp:bOnPrintTotal:= {||aSize(aMatri[1],0)}
		
		ElseIf nOrdem == 2

			//QUEBRA CENTRO DE CUSTO
			DEFINE BREAK oBreakCC OF oReport WHEN {|| (cAxAlias)->RA_CC }		
			oBreakCC:OnBreak({|x|cTitFil := OemToAnsi(STR0026) +" " + x, oReport:ThinLine()})
			oBreakCC:SetTotalText({||cTitFil})
			oBreakCC:SetTotalInLine(.T.)			
			DEFINE FUNCTION NAME "DA" FROM oSecFunc:Cell("RA_MAT" )  FUNCTION COUNT	BREAK oBreakCC NO END SECTION NO END REPORT PICTURE "@E 99999" TITLE STR0012		
			oBreakCC:aFunction[1]:bCondition := {||CountCond(aMatri)}	
			oBreakCC:bOnPrintTotal:= {||aSize(aMatri,0)}
							
		ElseIf nOrdem == 3

			//QUEBRA CURSO
			DEFINE BREAK oBreakCur OF oReport WHEN {|| (cAxAlias)->RA4_CURSO }		
			oBreakCur:OnBreak({|x|cTitFil := OemToAnsi(STR0027) +" " + x, oReport:ThinLine()})
			oBreakCur:SetTotalText({||cTitFil})
			oBreakCur:SetTotalInLine(.T.)			
			DEFINE FUNCTION NAME "DA" FROM oSecFunc:Cell("RA_MAT" )  FUNCTION COUNT	BREAK oBreakCur NO END SECTION NO END REPORT PICTURE "@E 99999" TITLE STR0012		
			oBreakCur:aFunction[1]:bCondition := {||CountCond(aMatri)}	
			oBreakCur:bOnPrintTotal:= {||aSize(aMatri,0)}
		EndIf 
	Else
		DEFINE BREAK oBreakFil OF oSecFunc WHEN oSecFunc:Cell(cCellBreak) TITLE cTitFil 
		DEFINE FUNCTION NAME "QTDFUNC"  FROM oSecFunc:Cell("RA_MAT" ) FUNCTION COUNT BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 99999" TITLE STR0012
		oBreakFil:SetTotalText({||cTitFil})
		oBreakFil:SetTotalInLine(.T.)	
		oBreakFil:aFunction[1]:bCondition := {||CountCond(aMatri)}	
		oBreakFil:bOnPrintTotal:= {||aSize(aMatri,0)}
	EndIf	
	
	oSecFunc:Print()
	
Return Nil

/*/{Protheus.doc} fRetDVenc
	Função para retornar dias que faltam para vencimento curso 
@author RH_INOV
@since 27/08/15
@version P12.1.8
@return cRet, dias restantes
/*/
Static Function fRetDVenc()
	Local cRet := ""

	IF ( ( (cAxAlias)->RA4_VALIDA - dDataBase + 1 ) ) > 0 
		cRet :=  Alltrim(Str( ( (cAxAlias)->RA4_VALIDA - dDataBase) + 1 ))
	Else
		cRet :=  STR0018		
	EndIf

Return (cRet)

/*/{Protheus.doc} fRetSit
	Função para retornar a sitação do curso
@author RH_INOV
@since 27/08/15
@version P12
@return cRet, caractere,descrição situação do curso
/*/
Static Function fRetSit()
	Local aArea:= GetArea()
	Local cRet := ""
	
	Do Case
		Case ((cAxAlias)->RA3_RESERV == "R")
			cRet := STR0015
		Case ((cAxAlias)->RA3_RESERV == "S")
			cRet := STR0016  
		Case ((cAxAlias)->RA3_RESERV == "L")		
			cRet := STR0017
		Case(Empty((cAxAlias)->RA3_RESERV))
			cRet := STR0019
	EndCase
	
	RestArea(aArea)
Return (cRet)

/*/{Protheus.doc} CountCond
	Condição para o Count
@author PHILIPE.POMPEU
@since 13/10/2015
@version P12.1.8
@param aMatri, array, vetor usado pra armazenar as matrículas
@param bComp, bloco, bloco para comparação
@param bAdd, bloco, bloco para adicão
@return lResult, lógico, .T. se deve somar +1
/*/
Static Function CountCond(aMatri, bComp, bAdd)
	Local lResult 	:= .F.
	Default bComp 	:= {|x|x[1]+x[2] == (cAxAlias)->RA_FILIAL + (cAxAlias)->RA_MAT}	
	Default bAdd 	:= {||{(cAxAlias)->RA_FILIAL, (cAxAlias)->RA_MAT}}
		
	lResult := (aScan(aMatri,bComp) == 0)
	
	if(lResult)		
		aAdd(aMatri,eVal(bAdd))
	endIf
	
Return (lResult)
