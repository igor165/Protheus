#Include "Protheus.ch"
#Include "Report.ch"
#Include "GPER012.ch"

Static lCorpManage	:= fIsCorpManage( FWGrpCompany() )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Função    	³ GPER012                                                                  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Descriçao 	³ Relatório de divergências de plano de saúde                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Sintaxe   	³ GPER012()                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Uso      	³ GPER012()                                   	    	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL.              	    	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Programador  ³ Data     ³ FNC			³  Motivo da Alteracao         	  		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Gabriel A.   ³11/05/2015³PCREQ-4774		³Alteração realizada apenas para ligar o fonte³±±
±±³             ³          ³ 	     		³ao requisito PDR_SER_RH001-412\PCREQ-4774    ³±±
±±³Gabriel A.   ³13/05/2015³PCDEF-32120	    ³Alteração realizada apenas para ligar o fonte³±±
±±³             ³          ³ 	     		³ao requisito   PCDEF-32120\PCREQ-2682        ³±±
±±³Gabriel A.   ³13/05/2015³PCDEF-32175	    ³Alteração realizada apenas para ligar o fonte³±±
±±³             ³          ³ 	     		³ao requisito   PCDEF-32175\PCREQ-2682        ³±±
±±³Gabriel A.   ³13/05/2015³PCDEF-32202	    ³Alteração realizada apenas para ligar o fonte³±±
±±³             ³          ³ 	     		³ao requisito   PCDEF-32202\PCREQ-2682        ³±±
±±³Christiane V ³23/10/2015³TTJWMY          ³Alteração na estrutura do relatorio para     ³±±
±±³             ³          ³ 	     		³quando não possuir gestão corporativa        ³±±
±±³Raquel Hager ³24/08/2016³TVTVRC          ³Ajuste na função fDescPlan para considerar   ³±±
±±³             ³          ³ 	     		³o código da Tabela na busca da descrição.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*/{Protheus.doc}GPER012
Relatório de divergências de plano de saúde
@author Gabriel de Souza Almeida
@since 22/04/2015
@version P12
/*/
Function GPER012()
	Local oReport
	Local aArea := GetArea()
	
	Private cPerg := "GPR012"
	
	Private cEmpr := ""
	Private cUnid := ""
	Private cFili := ""
	Private cCentroC := ""
	Private cMatFun := ""
	Private cSindica := ""
	Private cNomeFun := ""
	Private cCodPA := ""
	Private cPlnAtu := ""
	Private cCodPD := ""
	Private cPlnDev := ""
	Private oTmpTable
		
	Pergunte(cPerg,.F.)
	
	oReport := ReportDef()
	oReport:PrintDialog()
	
	If Type("oTmpTable") == "O"
		oTmpTable:Delete()
	EndIf
	
	RestArea(aArea)
Return

/*/{Protheus.doc} ReportDef
Definição dos componentes do relatório
@author Gabriel de Souza Almeida
@since 24/04/2015
@version P12
@return objeto, Estrutura do relatório
/*/
Static Function ReportDef()

	Local oReport
	Local oSecEm
	Local oSecUN
	Local oSecFil
	Local oSecCC
	Local oSecFun
	Local cAliasQry := GetNextAlias()
	Local cAliasMain := GetNextAlias()
	
	Local aOrd := {}
	
	Static lUniNeg	:= !Empty(FWSM0Layout(cEmpAnt, 2)) // Verifica se possui tratamento para unidade de Negocios
	Static lEmpFil	:= !Empty(FWSM0Layout(cEmpAnt, 1)) // Verifica se possui tratamento para Empresa
	Static cLayoutGC 	:= FWSM0Layout(cEmpAnt)
	Static nStartEmp	:= At("E",cLayoutGC)
	Static nStartUnN	:= At("U",cLayoutGC)
	Static nEmpLength	:= Len(FWSM0Layout(cEmpAnt, 1))
	Static nUnNLength	:= Len(FWSM0Layout(cEmpAnt, 2))
	
	Aadd(aOrd, OemToAnsi(STR0003))//1 - Matrícula
	Aadd(aOrd, OemToAnsi(STR0004))//2 - Sindicato
	
	DEFINE REPORT oReport NAME "RELATORIO_DIVERGENCIAS" TITLE OemToAnsi(STR0005) PARAMETER cPerg ACTION {|oReport| RelatImp(oReport,cAliasQry,cAliasMain)}
	
	DEFINE SECTION oSecEm OF oReport TITLE OemToAnsi(STR0006) TABLE "SRA" ORDERS aOrd
		DEFINE CELL NAME "EMPRESA" OF oSecEm BLOCK {|| cEmpr}
		
		DEFINE BREAK oBreakEM OF oSecEm WHEN {|| cEmpr} TITLE OemToAnsi(STR0006)
						
		DEFINE FUNCTION FROM oSecEm:Cell("EMPRESA") OF oSecEm FUNCTION COUNT TITLE OemToAnsi(STR0006) NO END SECTION
		
		oSecEm:SetHeaderBreak(.T.)
		// - Verifica se o cliente possui Gestão Corporativa no Grupo Logado 
		// - Caso possua imprimi com UN na margem na posição (02)
		If lCorpManage
			DEFINE SECTION oSecUN OF oSecEm TITLE OemToAnsi(STR0007)
				DEFINE CELL NAME "UNID_NEG" OF oSecUN BLOCK {|| cUnid}
			
				DEFINE BREAK oBreakUN OF oSecUN WHEN {|| cUnid} TITLE OemToAnsi(STR0007)
									
				DEFINE FUNCTION FROM oSecUN:Cell("UNID_NEG") OF oSecUN FUNCTION COUNT TITLE OemToAnsi(STR0007) NO END SECTION
				
				oSecUN:SetLeftMargin(2)
				oSecUN:SetHeaderBreak(.T.)
			
			DEFINE SECTION oSecFil OF oSecUN TITLE OemToAnsi(STR0001)
				DEFINE CELL NAME "RA_FILIAL" OF oSecFil BLOCK {|| cFili} TITLE OemToAnsi(STR0001)
					
				DEFINE BREAK oBreakFil OF oSecFil WHEN oSecFil:Cell("RA_FILIAL") TITLE OemToAnsi(STR0001)
										
				DEFINE FUNCTION FROM oSecFil:Cell("RA_FILIAL") OF oSecFil FUNCTION COUNT TITLE OemToAnsi(STR0001) NO END SECTION
					
				oSecFil:SetLeftMargin(4)
				oSecFil:SetHeaderBreak(.T.)
			
			DEFINE SECTION oSecCC OF oSecFil TITLE OemToAnsi(STR0002)
				DEFINE CELL NAME "RA_CC" OF oSecCC BLOCK {|| cCentroC} TITLE OemToAnsi(STR0002)
						
				DEFINE BREAK oBreakCC OF oSecCC WHEN oSecCC:Cell("RA_CC") TITLE OemToAnsi(STR0002)
												
				DEFINE FUNCTION FROM oSecCC:Cell("RA_CC") OF oSecCC FUNCTION COUNT TITLE OemToAnsi(STR0002) NO END SECTION
			
				oSecCC:SetLeftMargin(6)
				oSecCC:SetHeaderBreak(.T.)
	
			DEFINE SECTION oSecFun OF oSecCC TITLE OemToAnsi(STR0008)						
							
				DEFINE CELL NAME "RA_MAT"       OF oSecFun BLOCK {|| cMatFun} TITLE OemToAnsi(STR0003)
				DEFINE CELL NAME "RA_SINDICA"   OF oSecFun BLOCK {|| cSindica} TITLE OemToAnsi(STR0004)
				DEFINE CELL NAME "RA_NOME"      OF oSecFun BLOCK {|| cNomeFun} TITLE OemToAnsi(STR0009)
				DEFINE CELL NAME "PLANO_ATUAL"  OF oSecFun TITLE OemToAnsi(STR0010) SIZE(30) BLOCK {|| cCodPA + " - " + cPlnAtu}
				DEFINE CELL NAME "PLANO_DEVIDO" OF oSecFun TITLE OemToAnsi(STR0011) SIZE(30) BLOCK {|| cCodPD + " - " + cPlnDev}
				
				DEFINE BREAK oBreakMat OF oSecFun WHEN oSecCC:Cell("RA_CC") TITLE OemToAnsi(STR0008)
				
				oSecFun:SetLeftMargin(8)
				oSecFun:SetHeaderBreak(.T.)
		Else
			DEFINE SECTION oSecFil OF oSecEm TITLE OemToAnsi(STR0001)
				DEFINE CELL NAME "RA_FILIAL" OF oSecFil BLOCK {|| cFili} TITLE OemToAnsi(STR0001)
					
				DEFINE BREAK oBreakFil OF oSecFil WHEN oSecFil:Cell("RA_FILIAL") TITLE OemToAnsi(STR0001)
										
				DEFINE FUNCTION FROM oSecFil:Cell("RA_FILIAL") OF oSecFil FUNCTION COUNT TITLE OemToAnsi(STR0001) NO END SECTION
					
				oSecFil:SetLeftMargin(2) // Sobe a margem pois não utiliza UNIDADE DE NEGÓCIO.
				oSecFil:SetHeaderBreak(.T.)
			
			DEFINE SECTION oSecCC OF oSecFil TITLE OemToAnsi(STR0002)
				DEFINE CELL NAME "RA_CC" OF oSecCC BLOCK {|| cCentroC} TITLE OemToAnsi(STR0002)
				
				DEFINE BREAK oBreakCC OF oSecCC WHEN oSecCC:Cell("RA_CC") TITLE OemToAnsi(STR0002)
										
				DEFINE FUNCTION FROM oSecCC:Cell("RA_CC") OF oSecCC FUNCTION COUNT TITLE OemToAnsi(STR0002) NO END SECTION
				oSecCC:SetLeftMargin(6)
				oSecCC:SetHeaderBreak(.T.)

			DEFINE SECTION oSecFun OF oSecCC TITLE OemToAnsi(STR0008)						
				
				DEFINE CELL NAME "RA_MAT"       OF oSecFun BLOCK {|| cMatFun} TITLE OemToAnsi(STR0003)
				DEFINE CELL NAME "RA_SINDICA"   OF oSecFun BLOCK {|| cSindica} TITLE OemToAnsi(STR0004)
				DEFINE CELL NAME "RA_NOME"      OF oSecFun BLOCK {|| cNomeFun} TITLE OemToAnsi(STR0009)
				DEFINE CELL NAME "PLANO_ATUAL"  OF oSecFun TITLE OemToAnsi(STR0010) SIZE(30) BLOCK {|| cCodPA + " - " + cPlnAtu}
				DEFINE CELL NAME "PLANO_DEVIDO" OF oSecFun TITLE OemToAnsi(STR0011) SIZE(30) BLOCK {|| cCodPD + " - " + cPlnDev}
				
				DEFINE BREAK oBreakMat OF oSecFun WHEN oSecCC:Cell("RA_CC") TITLE OemToAnsi(STR0008)
				
				oSecFun:SetLeftMargin(8)
				oSecFun:SetHeaderBreak(.T.)
		EndIF
Return (oReport)


/*/{Protheus.doc} RelatImp()
Definicoes de uso das sections.
Definicoes de uso dos totalizadores (functions e collections).
Realizacao da query para o relatorio.
@author Gabriel de Souza Almeida
@version P12
@param oReport, objeto, Objeto TReport
@param cAliasQry, caractere, Alias da area utilizada para busca no banco
@return caractere, Alias da area utilizada na busca ao banco de dados
/*/
Static Function RelatImp(oReport, cAliasQry, cAliasMain)

	Local oSecEm
	Local oSecUN
	Local oSecFil
	Local oSecCC
	Local oSecFun
	Local nOrdem := oReport:GetOrder()
	
	Local cSitQuery
	Local cCatQuery
	Local cFil := mv_par01
	Local cCC := mv_par02
	Local cMat := mv_par03
	Local cSind := mv_par04
	Local cCategoria := mv_par05
	Local cSituacao := mv_par06
	Local nReg := 0
	Local cWhere := ""
	
	Local cJoinRHK := "% " + fTableJoin("RHK", "SRA") + " %"
	Local cJoinRHL := "% " + fTableJoin("RHL", "SRA") + " %"
	Local cJoinRHM := "% " + fTableJoin("RHM", "SRA") + " %"
	Local cJoinSLY := "% " + fTableJoin("SLY", "SRA") + " %"
	Local cJoinSG0 := "% " + fTableJoin("SG0", "SRA") + " %"
	Local cJoinSJS := "% " + fTableJoin("SJS", "SRA") + " %"
	Local cJoinSJX := "% " + fTableJoin("SJX", "SRA") + " %"
	Local cJoinSL0 := "% " + fTableJoin("SL0", "SRA") + " %"
	Local cJoinSLE := "% " + fTableJoin("SLE", "SRA") + " %"
	
	Local aColumns := {}
	Local lOk
	Local cCodCri
	Local cCodAlias
	Local cFilSra
	Local aAloc := {}
	Local cMatOld := ""
	Local cQry := ""
	Local lGrava
	Local aArea := GetArea()
	Local lAgreg
	Local lDepend
	
	Local cEmprAux := ""
	Local cUnidAux := ""
	Local cFiliAux := ""
	Local cCCAux := ""
	Local nX := 0
	
	cSitQuery	:= ""
	For nReg:=1 To Len(cSituacao)
		cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cSituacao)
			cSitQuery += "," 
		Endif
	Next nReg

	cCatQuery	:= ""
	For nReg:=1 To Len(cCategoria)
		cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cCategoria)
			cCatQuery += "," 
		Endif
	Next nReg
	
	MakeSqlExpr("GPR012")
	
	If !(Empty(MV_PAR01))
		cWhere += MV_PAR01 + " AND "
	EndIf

	If !(Empty(MV_PAR02))
		cWhere += MV_PAR02 + " AND "
	EndIf

	If !(Empty(MV_PAR03))
		cWhere += MV_PAR03 + " AND "
	EndIf
     
	If !(Empty(MV_PAR04))
		cWhere += MV_PAR04  + " AND "
	EndIf
	
	If !(Empty(MV_PAR06))
		cWhere += " SRA.RA_SITFOLH IN (" + Upper(cSitQuery) + ") AND "
	EndIf
	
	If !(Empty(MV_PAR05))
		cWhere += " SRA.RA_CATFUNC IN (" + Upper(cCatQuery) + ") AND "
	EndIf
	
	If !(Empty(cWhere))
		cWhere		:= "%" + cWhere + "%"
	Else
		cWhere		:= "% %"
	EndIf
	
	If lCorpManage
		oSecEm := oReport:Section(1)
		oSecUN := oReport:Section(1):Section(1)
		oSecFil := oReport:Section(1):Section(1):Section(1)
		oSecCC := oReport:Section(1):Section(1):Section(1):Section(1)
		oSecFun := oReport:Section(1):Section(1):Section(1):Section(1):Section(1)
	Else
		oSecEm := oReport:Section(1)
		oSecFil := oReport:Section(1):Section(1)
		oSecCC := oReport:Section(1):Section(1):Section(1)
		oSecFun := oReport:Section(1):Section(1):Section(1):Section(1)
	EndIf
	
	//Busca no banco de dados
	BeginSql Alias cAliasQry
		SELECT
			SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CC, SRA.RA_SINDICA
			, RHK.RHK_CDPSAG
			, SLY.LY_CODIGO
			, RHK_MAT, RHK_PERINI, RHK_CDPSAG, RHK_TPFORN, RHK_TPCALC, RHK_PLANO, RHK_CODFOR, RHK_PD, RHK_PDDAGR, RHK_PERFIM, RHK_TPPLAN
			, RHL_MAT,RHL_PERINI, RHL_TPFORN,RHL_TPCALC,RHL_PLANO,RHL_CODFOR,RHL_PERFIM,RHL_TPPLAN
			, RHM_MAT,RHM_PERINI, RHM_TPFORN,RHM_TPCALC,RHM_PLANO,RHM_CODFOR,RHM_PERFIM,RHM_TPPLAN
			, JX_PERINI, JX_TPFORN,JX_PLANO,JX_CODFORN,JX_PD,JX_PDDEP,JX_PERFIM,JX_TPPLANO
			, L0_PERINI, L0_TPFORN,L0_PLANO,L0_CODFORN,L0_PERFIM,L0_TPPLANO
			, LE_PERINI, LE_TPFORN,LE_PLANO,LE_CODFORN,LE_PERFIM,LE_TPPLANO
			, LY_CHVENT,LY_CODIGO,LY_ALIAS,LY_FILENT,LY_AGRUP,LY_DTINI,LY_DTFIM	
		FROM
			%table:SRA% SRA
			LEFT JOIN %table:RHK% RHK
				ON %exp:cJoinRHK%
				AND RHK_MAT = RA_MAT
				AND RHK.%notDel%
			LEFT JOIN %table:RHL% RHL
				ON %exp:cJoinRHL%
				AND RHL_MAT+RHL_TPFORN+RHL_CODFOR+RHL_TPPLAN+RHL_PLANO = RHK_MAT+RHK_TPFORN+RHK_CODFOR+RHK_TPPLAN+RHK_PLANO
				AND RHL.%notDel%
			LEFT JOIN %table:RHM% RHM
				ON %exp:cJoinRHM%
				AND RHM_MAT+RHM_TPFORN+RHM_CODFOR+RHM_TPPLAN+RHM_PLANO = RHK_MAT+RHK_TPFORN+RHK_CODFOR+RHK_TPPLAN+RHK_PLANO
				AND RHM.%notDel%
			LEFT JOIN %table:SLY% SLY
				ON %exp:cJoinSLY%
				AND LY_TIPO= %exp:'PS'%
				AND ( %exp:dtos(ddatabase)% >= LY_DTINI AND (%exp:dtos(ddatabase)% <= LY_DTFIM or LY_DTFIM = %exp:''%))
				AND SLY.%notDel%
			LEFT JOIN %table:SG0% SG0
				ON %exp:cJoinSG0%
				AND SG0.G0_CODIGO = RHK_CDPSAG
				AND SG0.G0_STATUS = %exp:'1'%
				AND SG0.%notDel%
			INNER JOIN %table:SJS% SJS
				ON %exp:cJoinSJS%
				AND JS_CDAGRUP = LY_AGRUP
				AND JS_TABELA = LY_ALIAS
				AND SJS.%notDel%
			LEFT JOIN %table:SJX% SJX
				ON %exp:cJoinSJX%
				AND LY_CODIGO = JX_CODIGO
				AND RHK_CDPSAG = JX_CODIGO
				AND SJX.%notDel%
			LEFT JOIN %table:SL0% SL0
				ON %exp:cJoinSL0%
				AND LY_CODIGO = L0_CODIGO
				AND RHK_CDPSAG = L0_CODIGO
				AND SL0.%notDel%
			LEFT JOIN %table:SLE% SLE
				ON %exp:cJoinSLE%
				AND LY_CODIGO = LE_CODIGO
				AND RHK_CDPSAG = JX_CODIGO
				AND SLE.%notDel%
		WHERE
			SRA.%notDel%
			AND %exp:cWhere%
			SRA.RA_PLSAUDE <> %exp:'2'%
			AND (RHK.RHK_TPCALC <> %exp:'1'% OR RHK.RHK_TPCALC IS NULL)

	EndSql
	
	If lCorpManage
		Aadd( aColumns, { "RA_EM"      ,"C",nEmpLength,0,})
		Aadd( aColumns, { "RA_UN"      ,"C",nUnNLength,0,})
	EndIf
	
	Aadd( aColumns, { "RA_FILIAL"  ,"C",TAMSX3("RA_FILIAL")[1],TAMSX3("RA_FILIAL")[2]		,GetSx3Cache( "RA_FILIAL" , "X3_PICTURE" ) })
	Aadd( aColumns, { "RA_MAT"     ,"C",TAMSX3("RA_MAT")[1],TAMSX3("RA_MAT")[2]			,GetSx3Cache( "RA_MAT" , "X3_PICTURE" )})
	Aadd( aColumns, { "RA_NOME"    ,"C",TAMSX3("RA_NOME")[1],TAMSX3("RA_NOME")[2]			,GetSx3Cache( "RA_NOME" , "X3_PICTURE" )})
	Aadd( aColumns, { "RA_CC"      ,"C",TAMSX3("RA_CC")[1],TAMSX3("RA_CC")[2]	,GetSx3Cache( "RA_CC" , "X3_PICTURE" )})
	Aadd( aColumns, { "RA_SINDICA" ,"C",TAMSX3("RA_SINDICA")[1],TAMSX3("RA_SINDICA")[2]	,GetSx3Cache( "RA_SINDICA" , "X3_PICTURE" )})
	Aadd( aColumns, { "RHK_CDPSAG" ,"C",TAMSX3("RHK_CDPSAG")[1],TAMSX3("RHK_CDPSAG")[2]	,GetSx3Cache( "RHK_CDPSAG" , "X3_PICTURE" )})
	Aadd( aColumns, { "G0_DESCR"   ,"C",TAMSX3("G0_DESCR")[1],TAMSX3("G0_DESCR")[2]		,GetSx3Cache( "G0_DESCR" , "X3_PICTURE" )})
	Aadd( aColumns, { "LY_CODIGO"  ,"C",TAMSX3("LY_CODIGO")[1],TAMSX3("LY_CODIGO")[2]		,GetSx3Cache( "LY_CODIGO" , "X3_PICTURE" )})
	Aadd( aColumns, { "LY_ALIAS"  ,"C",TAMSX3("LY_ALIAS")[1],TAMSX3("LY_ALIAS")[2]		,GetSx3Cache( "LY_ALIAS" , "X3_PICTURE" )})
	Aadd( aColumns, { "G0_DESCR1"  ,"C",TAMSX3("G0_DESCR")[1],TAMSX3("G0_DESCR")[2]		,GetSx3Cache( "G0_DESCR" , "X3_PICTURE" )})
	
	If Select(cAliasMain) > 0
		DbSelectArea(cAliasMain)
		DbCloseArea()
	EndIf

	oTmpTable := FWTemporaryTable():New( cAliasMain, aColumns )
	
	Do Case
		Case nOrdem == 1//1 - Matrícula
			If lCorpManage
				oTmpTable:AddIndex( "IND1", {"RA_EM", "RA_UN", "RA_FILIAL", "RA_CC", "RA_MAT"} )
			Else
				oTmpTable:AddIndex( "IND1", {"RA_FILIAL", "RA_CC", "RA_MAT"} )
			EndIF
		Case nOrdem == 2//2 - Sindicato
			If lCorpManage
				oTmpTable:AddIndex( "IND1", {"RA_EM", "RA_UN", "RA_FILIAL", "RA_CC", "RA_SINDICA"} )
			Else
				oTmpTable:AddIndex( "IND1", {"RA_FILIAL", "RA_CC", "RA_SINDICA"} )
			EndIF
	End Case
	
	oTmpTable:Create()	
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	
	While !(cAliasQry)->(Eof())
	
		cCodCri := fRetCriter((cAliasQry)->RA_FILIAL)
		cCodAlias := fRetAlias(cCodCri, (cAliasQry)->RA_FILIAL)
		cFilSra := (cAliasQry)->RA_FILIAL
	
		If (cAliasQry)->LY_AGRUP == cCodCri
			lOk := .T.
		Endif

		If lOk .AND. !Empty((cAliasQry)->LY_ALIAS) .AND. (cAliasQry)->LY_ALIAS $ cCodAlias	
			lOk := .T.
		EndIf
	
		If lOk
		
			DbSelectArea("SRA")
			SRA->(DbSeek((cAliasQry)->RA_FILIAL + (cAliasQry)->RA_MAT))
			
			//Checa Criterio
			Do Case
				Case ((cAliasQry)->LY_ALIAS == "SQB")
					lOk := Alltrim(SRA->RA_DEPTO) == Alltrim((cAliasQry)->LY_CHVENT)
				Case ((cAliasQry)->LY_ALIAS == "RCE")
					lOk := Alltrim(SRA->RA_SINDICA) == Alltrim((cAliasQry)->LY_CHVENT)
				Case ((cAliasQry)->LY_ALIAS == "CTT")
					lOk := Alltrim(SRA->RA_CC) == Alltrim((cAliasQry)->LY_CHVENT)
				Case ((cAliasQry)->LY_ALIAS == "SQ3")
					lOk := Alltrim(SRA->RA_CARGO) == Alltrim((cAliasQry)->LY_CHVENT)
				Case ((cAliasQry)->LY_ALIAS == "RCL")
					lOk := Alltrim(SRA->RA_POSTO) == Alltrim((cAliasQry)->LY_CHVENT)
				Case ((cAliasQry)->LY_ALIAS == "SRJ")
					lOk := Alltrim(SRA->RA_CODFUNC) == Alltrim((cAliasQry)->LY_CHVENT)
				Case ((cAliasQry)->LY_ALIAS == "SR6")
					lOk := Alltrim(SRA->RA_TNOTRAB) == Alltrim((cAliasQry)->LY_CHVENT)
				Case ((cAliasQry)->LY_ALIAS == "SM0")
					lOk := Alltrim(SRA->RA_FILIAL) == Alltrim((cAliasQry)->LY_CHVENT)
				Case ((cAliasQry)->LY_ALIAS $ "ABS*SA1*TDX")
					dDtIni	:= sToD((cAliasQry)->LY_DTINI)
					If !Empty((cAliasQry)->LY_DTFIM)
						dDtFim := sToD((cAliasQry)->LY_DTFIM)
					Else
						dDtFim := cToD( StrZero( f_UltDia( dDtIni ), 2) + "/" + SubStr( (cAliasQry)->LY_DTINI, 5, 2 ) + "/" + SubStr( (cAliasQry)->LY_DTINI, 1, 4 ) )
					EndIf
					
					aAloc := TXRetAloc((cAliasQry)->RA_FILIAL, (cAliasQry)->RA_MAT , dDtIni, dDtFim)
					lOk := .F.
					For nX := 1 to Len(aAloc)
						If ((cAliasQry)->LY_ALIAS == "ABS" .AND. aAloc[nX][07] == Alltrim((cAliasQry)->LY_CHVENT )) .OR. ((cAliasQry)->LY_ALIAS == "SA1" .AND. aAloc[nX][10] + aAloc[nX][11] == Alltrim((cAliasQry)->LY_CHVENT)) .OR. ((cAliasQry)->LY_ALIAS == "TDX" .AND. aAloc[nX][15] + aAloc[nX][08] == Alltrim((cAliasQry)->LY_CHVENT ))
							lOk := .T.
							Exit
						EndIf
					Next nX		
				OtherWise
					lOk := .F.
			EndCase
		EndIf 
	
		If lOk
			//Checa Dependentes
			If cMatOld <> (cAliasQry)->RA_MAT
				cQry := GetNextAlias()
				BeginSql Alias cQry
					SELECT COUNT(1) AS QTD
					FROM %table:SRB% SRB
					WHERE RB_MAT=%exp:(cAliasQry)->RA_MAT% 
					AND SRB.%notdel%
				EndSql
				
				lDepend := .F.
				If (cQry)->QTD > 0
					lDepend := .T.
				EndIf
				cMatOld := (cAliasQry)->RA_MAT
				(cQry)->(DbCloseArea())
			EndIf
		
			//Checa Planos Agregados
			If !Empty((cAliasQry)->RHM_TPPLAN)
				If ((cAliasQry)->RHM_TPPLAN <> (cAliasQry)->LE_TPPLANO;
				.OR. (cAliasQry)->RHM_CODFOR <> (cAliasQry)->LE_CODFORN;
				.OR. (cAliasQry)->RHM_PLANO <> (cAliasQry)->LE_PLANO) 
					lAgreg := .T.
				EndIf
			EndIf
	
			If ((Alltrim((cAliasQry)->LY_CODIGO) <> Alltrim((cAliasQry)->RHK_CDPSAG))	.OR. Empty((cAliasQry)->RHK_CDPSAG));
			.OR. ((cAliasQry)->RHK_TPPLAN <> (cAliasQry)->JX_TPPLANO;
				.OR. (cAliasQry)->RHK_CODFOR <> (cAliasQry)->JX_CODFORN;
				.OR. (cAliasQry)->RHK_PD <> (cAliasQry)->JX_PD;
				.OR. (cAliasQry)->RHK_PDDAGR <> (cAliasQry)->JX_PDDEP;
				.OR. (cAliasQry)->RHK_PLANO <> (cAliasQry)->JX_PLANO;
				.OR. (cAliasQry)->RHK_PERFIM <> (cAliasQry)->JX_PERFIM);
			.OR. (lDepend;
				.AND. ( (cAliasQry)->RHL_TPPLAN	<> (cAliasQry)->L0_TPPLANO;
					.OR. (cAliasQry)->RHL_CODFOR <> (cAliasQry)->L0_CODFORN; 
					.OR. (cAliasQry)->RHL_PLANO <> (cAliasQry)->L0_PLANO));
			.OR. lAgreg				
				lGrava := .T.
				If !((cAliasMain)->(DbSeek((cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT)))
					RecLock(cAliasMain,.T.)
				Else
					//Definir Prioridade de Gravação
					aTmp := Separa(cCodAlias,"/")
					
					nPosNovo := ascan(aTmp,{|x| Alltrim(x)==Alltrim((cAliasQry)->LY_ALIAS)})
					nPos := ascan(aTmp,{|x| Alltrim(x)==Alltrim((cAliasMain)->LY_ALIAS)})
					
					If nPosNovo >= nPos
						lGrava := .F.
					Else
						RecLock(cAliasMain,.F.)
					EndIf
				EndIf
				
				If lGrava
					If lCorpManage
						(cAliasMain)->RA_EM := Substr((cAliasQry)->RA_FILIAL, nStartEmp, nEmpLength)
						(cAliasMain)->RA_UN := Substr((cAliasQry)->RA_FILIAL, nStartUnN, nUnNLength)
					EndIF
					(cAliasMain)->RA_FILIAL := (cAliasQry)->RA_FILIAL
					(cAliasMain)->RA_MAT := (cAliasQry)->RA_MAT
					(cAliasMain)->RA_CC := (cAliasQry)->RA_CC
					(cAliasMain)->RA_NOME := (cAliasQry)->RA_NOME
					(cAliasMain)->RA_SINDICA := (cAliasQry)->RA_SINDICA
					(cAliasMain)->RHK_CDPSAG := (cAliasQry)->RHK_CDPSAG
					(cAliasMain)->G0_DESCR := fDescDP((cAliasQry)->RHK_CDPSAG)
					(cAliasMain)->LY_CODIGO := (cAliasQry)->LY_CODIGO
					(cAliasMain)->LY_ALIAS := (cAliasQry)->LY_ALIAS
					(cAliasMain)->G0_DESCR1 := fDescDP((cAliasQry)->LY_CODIGO)
					
					(cAliasMain)->(MsUnlock())
				EndIf
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
		
	//Define o total da regua da tela de processamento do relatorio
	oReport:SetMeter(200)
	
	oSecEm:Init()
	IF lCorpManage
		oSecUN:Init()
	EndIF
	oSecFil:Init()
	oSecCC:Init()
	oSecFun:Init()
	
	DbSelectArea(cAliasMain)
	
	(cAliasMain)->(DbSetOrder(1))
	(cAliasMain)->(DbGoTop())
	
	While !((cAliasMain)->(Eof()))
		
		//Movimenta Regua Processamento
		oReport:IncMeter(1)
		
		//Cancela Impressao
		If oReport:Cancel()
			Exit
		EndIf
		
		cEmpr := cEmpAnt
	
		If !(cEmpr $ cEmprAux) .And. !lCorpManage
			oSecEm:PrintLine()
		ElseIf !(cEmpr $ cEmprAux) .And. lCorpManage
			oSecEm:PrintLine()
			cEmprAux += (cAliasMain)->RA_EM + "/"
		EndIf
				
		If lCorpManage
			cUnid := (cAliasMain)->RA_UN
			If !(cUnid $ cUnidAux)
				oSecUN:PrintLine()
				cUnidAux += (cAliasMain)->RA_UN + "/"
			EndIf		
		EndIF
		
		cFili := (cAliasMain)->RA_FILIAL
		
		If !(cFili $ cFiliAux)
			oSecFil:PrintLine()
			cFiliAux += (cAliasMain)->RA_FILIAL + "/"
		EndIf
		
		cCentroC := (cAliasMain)->RA_CC
		
		If !(cCentroC $ cCCAux)
			oSecCC:PrintLine()
			cCCAux += (cAliasMain)->RA_CC + "/"
		EndIf
		
		cMatFun := (cAliasMain)->RA_MAT
		cSindica := (cAliasMain)->RA_SINDICA
		cNomeFun := (cAliasMain)->RA_NOME
		cCodPA := (cAliasMain)->RHK_CDPSAG
		cPlnAtu := (cAliasMain)->G0_DESCR
		cCodPD := (cAliasMain)->LY_CODIGO
		cPlnDev := (cAliasMain)->G0_DESCR1
		
		oSecFun:PrintLine()
		
		(cAliasMain)->(DbSkip())
	EndDo
	
	//Termino do relatorio
	oSecEm:Finish()
	IF lCorpManage
		oSecUN:Finish()
	EndIF
	oSecFil:Finish()
	oSecCC:Finish()
	oSecFun:Finish()
	
	(cAliasMain)->(DbCloseArea())
	RestArea(aArea)

Return NIL

/*/{Protheus.doc} fDesPlan
Encontra a descrição do plano
@author Gabriel de Souza Almeida
@version P12
@param oReport, objeto, Objeto TReport
@param cAliasQry, caractere, Alias da area utilizada para busca no banco
@return caractere, Descrição do plano desejado
/*/
Function fDesPlan(cTpForn,cTpPlan,cCodPlan)
	Local cRetorno := ""
	Local nLineInc := 1
	Local nLine := 0
	Local aTab_Fol := {}
	Local cTab := ""
	
	If cTpForn = "1" //Assistencia Medica
		Do Case
			Case cTpPlan == "1" //Faixa Salarial
				cTab := "S008"
			Case cTpPlan == "2" //Faixa Etaria
				cTab := "S009"
			Case cTpPlan == "3" //Valor Fixo
				cTab := "S028"
			Case cTpPlan == "4" //% Salario
				cTab := "S029"
			Case cTpPlan == "5" //Salarial/Etaria
				cTab := "S059"
		EndCase
	Else //Assistencia Odontologica
		Do Case
			Case cTpPlan == "1" //Faixa Salarial
				cTab := "S013"
			Case cTpPlan == "2" //Faixa Etaria
				cTab := "S014"
			Case cTpPlan == "3" //Valor Fixo
				cTab := "S030"
			Case cTpPlan == "4" //% Salario
				cTab := "S031"
			Case cTpPlan == "5" //Salarial/Etaria
				cTab := "S060"
		EndCase
	EndIf
	
	fCarrTab(@aTab_Fol,cTab,dDataBase)
	
	While nLineInc <= Len(aTab_Fol)
		If aTab_Fol[nLineInc,1] == cTab .And. aTab_Fol[nLineInc,5] == cCodPlan 
			nLine := nLineInc
			cRetorno := aTab_Fol[nLine,6]
			Return cRetorno
		EndIf
		nLineInc++
	EndDo
	
	If nLine == 0
		cRetorno := ""
	Else
		cRetorno := aTab_Fol[nLine,6]
	EndIf
	
Return cRetorno

/*/{Protheus.doc} fTableJoin
Join de tabelas
@author Gabriel de Souza Almeida
@since 18/05/2015
@version P12
@param cTabela1, caractere, Primeira tabela do relacionamento
@param cTabela2, caractere, Segunda tabela do relacionamento
@param [cEmbedded], caractere, Simbolo para abertura/fechamento do Embedded
@return caractere, Comando SUBTRING tratado
/*/
Static Function fTableJoin(cTabela1, cTabela2,cEmbedded)

	Local cFiltJoin := ""
	Default cEmbedded := ""
	
	cFiltJoin := cEmbedded + FWJoinFilial(cTabela1, cTabela2) + cEmbedded	
	
Return (cFiltJoin)

/*/{Protheus.doc} fDescDP
Fornece a descrição da definição de plano
@author Gabriel de Souza Almeida
@since 18/05/2015
@version P12
@param cCodDP, caractere, Codigo da definição de plano
@return cDesc, caractere, Descrição da definição de plano
/*/
Function fDescDP(cCodDP)
	Local cDesc := ""
	
	DbSelectArea("SG0")
	SG0->(DbSetOrder(1))
	
	If SG0->(MsSeek(xFilial("SG0")+cCodDP))
		cDesc := SG0->G0_DESCR
	EndIf
Return cDesc

/*/{Protheus.doc} fRetAlias
Retorna os códigos dos Alias
@author Gabriel de Souza Almeida
@since 18/05/2015
@version P12
@param cFiltro, caractere, Codigo do critério
@return cCod, caractere, Codigos dos Alias
/*/
Static Function fRetAlias(cFiltro, cFilProc)
Local aArea 	 := GetArea()
Local cCod		 := ""
Local cQry 		 := GetNextAlias()
Local cFilSJS	 := ""
Default cFilProc := cFilant

cFilSJS := xFilial("SJS", cFilProc)

BEGINSQL ALIAS cQry

SELECT  JS_TABELA FROM %table:SJS% SJS 
Where JS_CDAGRUP = %exp:cFiltro%
and  %notDel%
AND JS_FILIAL = %exp:cFilSJS%
AND JS_SEQ > %exp:'01'%
order by JS_SEQ  
EndSql

cCod := ""
While !(cQry)->(Eof())
	cCod += (cQry)->JS_TABELA + " / "
	
	(cQry)->(dbSkip())
EndDo
(cQry)->(dbCloseArea())


RestArea(aArea)
Return cCod
