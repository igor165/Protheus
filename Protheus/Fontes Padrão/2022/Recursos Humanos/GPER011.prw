#Include "Protheus.ch"
#Include "Report.ch"
#Include "GPER011.ch"

Static lTemCCT

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ±±
±±≥FunÁ„o    	≥ GPER011                                                                ±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒ±±
±±≥DescriÁao 	≥ RelatÛrio de benefÌcios por funcion·rio                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ±±
±±≥Sintaxe   	≥ GPER011()                                                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ±±
±±≥Uso      	≥ GPER011()                                   	    	                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ±±
±±≥         ATUALIZACOES SOFRIDAS DESDE A CONSTRU«AO INICIAL.               	    	≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ±±
±±≥Programador  ≥Data      ≥FNC		 	    ≥Motivo da Alteracao           			    ≥±±
±±≥Raquel Hager ≥19/05/16  ≥TUZCZI          ≥Ajuste para impressao correto do tipo de   ≥±±
±±≥             ≥          ≥                ≥beneficio.								    ≥±±
±±≥Raquel Hager ≥17/08/16  ≥TVTVRC          ≥Ajuste para impressao de dados de Planos de≥±±
±±≥             ≥          ≥                ≥Assist. MÈdica e/ou OdontolÛgica quando    ≥±±
±±≥             ≥          ≥                ≥o Dependente e/ou Agregado possui tipo/cÛd.≥±±
±±≥             ≥          ≥                ≥distintos do titular - uso da chave correta≥±±
±±≥             ≥          ≥                ≥das tabelas.                               ≥±±
±±≥Raquel Hager ≥24/08/16  ≥TVTVRC          ≥Ajuste para impressao da descriÁ„o do Plano≥±±
±±≥             ≥          ≥                ≥de Assist. OdontolÛgica correto. Ajuste p/ ≥±±
±±≥             ≥          ≥                ≥impress„o do CÛdigo do Plano correto do Ti-≥±±
±±≥             ≥          ≥                ≥tular. Ajuste para impress„o dos totalizado≥±±
±±≥             ≥          ≥                ≥res.                                       ≥±±
±±≥Joao Balbino ≥05/05/17  ≥MPRIMESP-9969   ≥Efetuado todos os ajustes de concatenaÁ„o  ≥±±
±±≥             ≥          ≥                ≥de campo nas querys para que seja possivel ≥±±
±±≥             ≥          ≥                ≥emitir o relatÛrio para todso os bancos,   ≥±±
±±≥             ≥          ≥                ≥conforme doc do changequery a concatenaÁ„o ≥±±
±±≥             ≥          ≥                ≥deve ser feita com PIPE.                   ≥±±
±±≥             ≥          ≥                ≥Ajustado tambÈm o tamanhoa das variaveis   ≥±±
±±≥             ≥          ≥                ≥utilizado na EXP do Embedded pois a msm tem≥±±
±±≥             ≥          ≥                ≥limite de tamanho.                         ≥±±
±±≥Joao balbino ≥12/05/17  ≥MPRIMESP-10082  ≥Ajuste para n„o apresentar error log em ban≥±±
±±≥             ≥          ≥                ≥co Oracle.								    ≥±±
±±≥Isabel N.    ≥06/09/2017≥DRHPAG-4525     ≥Ajuste p/filtrar dependentes corretamente e≥±±
±±≥             ≥          ≥                ≥exibir somente os que possuam plano ativo. ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

/*/{Protheus.doc}GPER011
RelatÛrio de benefÌcios por funcion·rio
@author Gabriel de Souza Almeida
@since 29/04/2015
@version P12
/*/
Function GPER011()

	Local oReport
	Local aArea			:= GetArea()
	
	Private cPerg 		:= "GPER011"
	
	Private aFunc 		:= {}
	Private aBen 		:= {}
	Private aDep 		:= {}
	Private aFuncAux	:= {}
	
	Private oTmpTable

	DEFAULT lTemCCT 	:= fChkCCT()
	
	Pergunte(cPerg,.F.)
	
	oReport := ReportDef()
	
	oReport:PrintDialog()
	
	If type("oTmpTable") == "O"
		oTmpTable:Delete()	
	Endif
	
	RestArea(aArea)
Return

/*/{Protheus.doc} ReportDef
DefiniÁ„o dos componentes do relatÛrio
@author Gabriel de Souza Almeida
@since 29/04/2015
@version P12
@return oReport, Estrutura do relatÛrio
/*/
Static Function ReportDef()

	Local oReport
	Local oSecFunc
	Local oSecBen
	Local oSecDep
	Local oSecAgr
	Local aOrd := {}

	Local cPtVC := GetSx3Cache( "R0_VALCAL" , "X3_PICTURE" )
	Local cPtVF := GetSx3Cache( "R0_VLRFUNC" , "X3_PICTURE")
	Local cPtVE := GetSx3Cache( "R0_VLREMP" , "X3_PICTURE" )
	Local nTmVC := TamSx3("R0_VALCAL")[1]
	Local nTmVF := TamSx3("R0_VLRFUNC")[1]
	Local nTmVE := TamSx3("R0_VLREMP")[1]
	
	Aadd(aOrd, OemToAnsi(STR0002)) //1 - Funcion·rio
	If lTemCCT
		Aadd(aOrd, OemToAnsi("CCT + Filial + Centro Custo")) //2 - CCT + Filial + Centro de Custos + MatrÌcula
	EndIf
	
	DEFINE REPORT oReport NAME "GPER011" TITLE OemToAnsi(STR0003) PARAMETER cPerg ACTION {|oReport| RelatImp(oReport)}
	
		DEFINE SECTION oSecFunc OF oReport TITLE OemToAnsi(STR0004) ORDERS aOrd //Funcion·rios
			DEFINE CELL NAME "RA_FILIAL" OF oSecFunc BLOCK {|| aFunc[1][1]} TITLE OemToAnsi(STR0005)
			DEFINE CELL NAME "RA_MAT"    OF oSecFunc BLOCK {|| aFunc[1][2]} TITLE OemToAnsi(STR0007)
			DEFINE CELL NAME "RA_NOME"   OF oSecFunc BLOCK {|| aFunc[1][3]} TITLE OemToAnsi(STR0051)

			If lTemCCT
				DEFINE CELL NAME "CODCCT"   OF oSecFunc BLOCK {|| aFunc[1][4]} TITLE OemToAnsi("Conv. Colet. Trab.")				
			EndIf
			
			DEFINE BREAK oBreakFun OF oSecFunc WHEN {|| aFunc[1][1] + aFunc[1][2]} 	TITLE OemToAnsi(STR0002)			
			DEFINE FUNCTION FROM oSecFunc:Cell("RA_MAT") OF oSecFunc FUNCTION COUNT 	TITLE OemToAnsi(STR0004) NO END SECTION //Total de Funcion·rios

			oSecFunc:SetHeaderBreak(.T.)
			
			//SeÁ„o BenefÌcio
			DEFINE SECTION oSecBen OF oSecFunc TITLE OemToAnsi(STR0046) //BenefÌcios
				DEFINE CELL NAME "Tipo"    OF oSecBen BLOCK {|| aBen[1][1]} SIZE(06) TITLE OemToAnsi(STR0047)
				DEFINE CELL NAME "TipoBen" OF oSecBen BLOCK {|| aBen[1][3]} SIZE(30) TITLE OemToAnsi(STR0011)
				DEFINE CELL NAME "CodBen"  OF oSecBen BLOCK {|| aBen[1][2]} TITLE OemToAnsi(STR0010)				
				DEFINE CELL NAME "DescBen" OF oSecBen BLOCK {|| aBen[1][4]} SIZE(30) TITLE OemToAnsi(STR0012)
				DEFINE CELL NAME "VALCAL"  OF oSecBen BLOCK {|| aBen[1][5]} TITLE OemToAnsi(STR0013) PICTURE cPtVC SIZE (nTmVC)
				DEFINE CELL NAME "VLRFUNC" OF oSecBen BLOCK {|| aBen[1][6]} TITLE OemToAnsi(STR0014) PICTURE cPtVF SIZE (nTmVF)
				DEFINE CELL NAME "VLREMP"  OF oSecBen BLOCK {|| aBen[1][7]} TITLE OemToAnsi(STR0015) PICTURE cPtVE SIZE (nTmVE)
				
				DEFINE BREAK oBreakBen OF oSecBen WHEN {|| aFunc[1][1] + aFunc[1][2] + aBen[1][1] + aBen[1][2] + aBen[1][3] + aBen[1][4]} TITLE OemToAnsi(STR0002)
				
				oSecBen:SetLeftMargin(4)
				oSecBen:SetHeaderBreak(.T.)
			
				DEFINE SECTION oSecDep OF oSecBen TITLE OemToAnsi(STR0038) //Dependentes
					DEFINE CELL NAME "RB_NOME"    OF oSecDep BLOCK {|| aDep[1][1]} SIZE(70) TITLE OemToAnsi(STR0008) //Nome Dependente
					DEFINE CELL NAME "RHL_TPFORN" OF oSecDep BLOCK {|| aDep[1][3]} SIZE(30) TITLE OemToAnsi(STR0011)
					DEFINE CELL NAME "RHL_PLANO"  OF oSecDep BLOCK {|| aDep[1][2]} TITLE OemToAnsi(STR0010) //"Codigo Ben."					
					DEFINE CELL NAME "PLANO"      OF oSecDep BLOCK {|| aDep[1][4]} SIZE(30) TITLE OemToAnsi(STR0012)
					DEFINE CELL NAME "VALCAL"  	  OF oSecDep BLOCK {|| aDep[1][5]} TITLE OemToAnsi(STR0013) PICTURE cPtVC  SIZE (nTmVC) //VALOR DO PLANO
					DEFINE CELL NAME "VLRFUNC"    OF oSecDep BLOCK {|| aDep[1][6]} TITLE OemToAnsi(STR0014) PICTURE cPtVF  SIZE (nTmVF) // VALOR DO FUNCIONARIO
					DEFINE CELL NAME "VLREMP"  	  OF oSecDep BLOCK {|| aDep[1][7]} TITLE OemToAnsi(STR0015) PICTURE cPtVE  SIZE (nTmVE) // VALOR DA EMPRESA 
										
					DEFINE BREAK oBreakDep OF oSecDep WHEN {|| aBen[1][1] + aBen[1][2] + aBen[1][3] + aBen[1][4]} TITLE OemToAnsi(STR0002)
					
					oSecDep:SetLeftMargin(8)
					oSecDep:SetHeaderBreak(.T.)
					
				DEFINE SECTION oSecAgr OF oSecBen TITLE OemToAnsi(STR0039) //Agregados
					DEFINE CELL NAME "RHM_NOME"   OF oSecAgr BLOCK {|| aDep[1][1]} TITLE OemToAnsi(STR0048) //Nome Agregado
					DEFINE CELL NAME "RHM_TPFORN" OF oSecAgr BLOCK {|| aDep[1][3]} SIZE(30) TITLE OemToAnsi(STR0011)
					DEFINE CELL NAME "RHM_PLANO"  OF oSecAgr BLOCK {|| aDep[1][2]} TITLE OemToAnsi(STR0010) //"Codigo Ben."				
					DEFINE CELL NAME "PLANO"      OF oSecAgr BLOCK {|| aDep[1][4]} SIZE(30) TITLE OemToAnsi(STR0012)
					DEFINE CELL NAME "VALCAL"  	  OF oSecAgr BLOCK {|| aDep[1][5]} TITLE OemToAnsi(STR0013) PICTURE cPtVC SIZE (nTmVC) //VALOR DO PLANO
					DEFINE CELL NAME "VLRFUNC"    OF oSecAgr BLOCK {|| aDep[1][6]} TITLE OemToAnsi(STR0014) PICTURE cPtVF SIZE (nTmVF) // VALOR DO FUNCIONARIO
					DEFINE CELL NAME "VLREMP"  	  OF oSecAgr BLOCK {|| aDep[1][7]} TITLE OemToAnsi(STR0015) PICTURE cPtVE SIZE (nTmVE) // VALOR DA EMPRESA 
					
					DEFINE BREAK oBreakAgr OF oSecAgr WHEN {|| aBen[1][1] + aBen[1][2] + aBen[1][3] + aBen[1][4]} TITLE OemToAnsi(STR0002)
					
					oSecAgr:SetLeftMargin(8)
					oSecAgr:SetHeaderBreak(.T.)
					
					DEFINE FUNCTION NAME "VALCAL" 	FROM oSecBen:Cell("VALCAL")  	FUNCTION SUM TITLE OemToAnsi(STR0043) OF oSecBen PICTURE cPtVC  NO END SECTION //"Valor Calculado"
					DEFINE FUNCTION NAME "VALCAL" 	FROM oSecDep:Cell("VALCAL")  	FUNCTION SUM TITLE OemToAnsi(STR0049) OF oSecDep PICTURE cPtVF  NO END SECTION //"Valor Dependente"
					DEFINE FUNCTION NAME "VALCAL" 	FROM oSecAgr:Cell("VALCAL")  	FUNCTION SUM TITLE OemToAnsi(STR0050) OF oSecAgr PICTURE cPtVF  NO END SECTION //"Valor Agregado"
					DEFINE FUNCTION NAME "VLRFUNC"  FROM oSecBen:Cell("VLRFUNC")	FUNCTION SUM TITLE OemToAnsi(STR0044) OF oSecBen PICTURE cPtVF  NO END SECTION //"Valor Funcion·rio"
					DEFINE FUNCTION NAME "VLREMP" 	FROM oSecBen:Cell("VLREMP")  	FUNCTION SUM TITLE OemToAnsi(STR0045) OF oSecBen PICTURE cPtVE  NO END SECTION //"Valor Empresa"
				

Return (oReport)


/*/{Protheus.doc} RelatImp
Definicoes de uso das sections.
Definicoes de uso dos totalizadores (functions e collections).
Realizacao da query para o relatorio.
@author Gabriel de Souza Almeida
@version P12
@param oReport, objeto, Objeto TReport
/*/
Static Function RelatImp(oReport)

	Local oSecFunc
	Local oSecBen
	Local oSecDep
	Local oSecAgr
	
	Local aArea := GetArea()
	
	//Par‚metros
	Local cProc
	Local cPer
	Local cNroPag
	Local cFil
	Local cCC
	Local cMat
	Local cSit
	Local cCat
	Local cVR
	Local cVA
	Local cVT
	Local cOB
	Local cPS
	Local cDep
	Local cAgr
	Local cCCT			:= ""
	
	//Auxiliares
	Local cSitQry  		:= ""
	Local cCatQry		:= ""
	Local cWhereVrf 	:= ""
	Local cWhereVtr 	:= ""
	Local cWhereVal 	:= ""
	Local cWhereOB 		:= ""
	Local cWherePS 		:= ""
	Local cWhereAgr		:= ""
	Local cWhereDep		:= ""
	Local cJoinSR0 		:= "% " + fTableJoin("SR0", "SRA") + " %"
	Local cJoinRFO 		:= "% " + fTableJoin("RFO", "SRA") + " %"
	Local cJoinSRN 		:= "% " + fTableJoin("SRN", "SRA") + " %"
	Local cJoinRIQ 		:= "% " + fTableJoin("RIQ", "SRA") + " %"
	Local cJoinRIR 		:= "% " + fTableJoin("RIR", "SRA") + " %"
	Local cJoinRHK 		:= "% " + fTableJoin("RHK", "SRA") + " %"
	Local cJoinRHM 		:= "% " + fTableJoin("RHM", "SRA") + " %"
	Local cJoinRHL 		:= "% " + fTableJoin("RHL", "SRA") + " %"
	Local cJoinRHR 		:= "% " + fTableJoin("RHR", "SRA") + " %"
	Local cJoinRHS 		:= "% " + fTableJoin("RHS", "SRA") + " %"
	Local cJoinRG2 		:= "% " + fTableJoin("RG2", "SRA") + " %"
	Local cJoinSRB 		:= "% " + fTableJoin("SRB", "SRA") + " %"
	Local cAliasQry1 	:= GetNextAlias()
	Local cAliasQry2 	:= GetNextAlias()
	Local cAliasQry3 	:= GetNextAlias()
	Local cAliasQry4 	:= GetNextAlias()
	Local cAliasQry5 	:= GetNextAlias()
	Local cAliasAgreg 	:= GetNextAlias()
	Local cAliasDepen 	:= GetNextAlias()
	Local cQryVrf 		:= "%%"
	Local cQryVal 		:= "%%"
	Local cQryVtr 		:= "%%"
	Local cQryPS 		:= "%%"
	Local cQryOB 		:= "%%"
	Local cQryaGgr 		:= "%%"
	Local cQryDep 		:= "%%"
	
	Local cNQryVrf 		:= ""
	Local cNQryVal 		:= ""
	Local cNQryVtr 		:= ""
	Local cNQryPS 		:= ""
	Local cNQryOB 		:= ""
	Local cNQryaGgr 	:= ""
	Local cNQryDep 		:= ""
	Local cOrdem 		:= ""
	Local cR0CCT 		:= "%%"
	Local cRG2CCT		:= "%%"
	Local cRHRCCT		:= "%%"
	Local cRHSCCT 		:= "%%"
	Local cNULLCCT		:= "%%"
	Local cSR0GRP		:= "%%"
	Local cRG2GRP		:= "%%"
	
	Local aColumns 		:= {}
	Local cAliasQry 	:= GetNextAlias()
	Local cAliasMain	:= GetNextAlias()
	Local cFuncAux 		:= ""
	Local cRtBen		:= ""
	Local nReg 			:= 0
	Local nOrdem		:= 0
	Local lOracle		:= Iif(Upper(TcGetDb()) == "ORACLE", .T. , .F.)

	
	//DefiniÁ„o da estrutura do relatÛrio
	oSecFunc := oReport:Section(1)
	oSecBen := oReport:Section(1):Section(1)
	oSecDep := oReport:Section(1):Section(1):Section(1)
	oSecAgr := oReport:Section(1):Section(1):Section(2)
	nOrdem := oSecFunc:GetOrder()

	MakeSqlExpr("GPER011")
	
	cProc 	:= MV_PAR01
	cPer 	:= MV_PAR02
	cNroPag := MV_PAR03
	cFil 	:= MV_PAR04
	cCC	 	:= MV_PAR05
	cMat 	:= MV_PAR06
	cSit 	:= MV_PAR07
	cCat 	:= MV_PAR08
	cVR 	:= MV_PAR09
	cVA 	:= MV_PAR10
	cVT 	:= MV_PAR11
	cOB 	:= MV_PAR12
	cPS 	:= MV_PAR13
	cDep 	:= MV_PAR14
	cAgr 	:= MV_PAR15

	If lTemCCT
		cCCT 		:= MV_PAR16
		cR0CCT 		:= "% ,R0_CODCCT as FuncCCT %"
		cRG2CCT		:= "% ,RG2_CODCCT as FuncCCT %"
		cRHRCCT		:= "% ,RHR_CODCCT as FuncCCT %"
		cRHSCCT		:= "% ,RHS_CODCCT as FuncCCT %"
		cNULLCCT	:= "% ,'' as FuncCCT %"
		cSR0GRP		:= "% , R0_CODCCT %"
		cRG2GRP		:= "% , RG2_CODCCT %"
	EndIf
	
	cSitQry	:= ""
	For nReg:= 1 To Len(cSit)
		cSitQry += "'"+Subs(cSit,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cSit)
			cSitQry += "," 
		Endif
	Next nReg

	cCatQry	:= ""
	For nReg:= 1 To Len(cCat)
		cCatQry += "'"+Subs(cCat,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cCat)
			cCatQry += "," 
		Endif
	Next nReg
	
	If !(Empty(cProc))
		cWhereVtr += " SRA.RA_PROCES = '" + cProc + "' AND "
		cWhereVrf += " SRA.RA_PROCES = '" + cProc + "' AND "
		cWhereVal += " SRA.RA_PROCES = '" + cProc + "' AND "
		cWhereOB  += " SRA.RA_PROCES = '" + cProc + "' AND "
		cWherePS  += " SRA.RA_PROCES = '" + cProc + "' AND "
		cWhereAgr += " SRA.RA_PROCES = '" + cProc + "' AND "
		cWhereDep += " SRA.RA_PROCES = '" + cProc + "' AND "

	EndIf

	If !(Empty(cPer))
		
		If cVR == 1
			cRtBen := fGetCalcRot("D") // VRF
			If !Empty(cRtBen)
				If !fPerAbert(MV_PAR02, cRtBen) 
					cWhereVrf += " (RG2.RG2_PERIOD || RG2.RG2_NROPGT || RG2.RG2_ROTEIR= '" + cPer + cNroPag + cRtBen + "' OR RG2.RG2_PERIOD || RG2.RG2_NROPGT || RG2.RG2_ROTEIR IS NULL) AND "
				EndIf
			EndIf
		EndIf
		
		If cVA == 1
			cRtBen := fGetCalcRot("E") //VAL
			If !Empty(cRtBen)
				If !fPerAbert(MV_PAR02, cRtBen) 
					cWhereVal += " (RG2.RG2_PERIOD || RG2.RG2_NROPGT || RG2.RG2_ROTEIR= '" + cPer + cNroPag + cRtBen + "' OR RG2.RG2_PERIOD || RG2.RG2_NROPGT || RG2.RG2_ROTEIR IS NULL) AND "
				EndIf
			EndIf
		EndIf
		
		If cVT == 1
			cRtBen := fGetCalcRot("8") //VTR
			If !Empty(cRtBen)
				If !fPerAbert(MV_PAR02, cRtBen) 
					cWhereVtr += " (RG2.RG2_PERIOD || RG2.RG2_NROPGT || RG2.RG2_ROTEIR= '" + cPer + cNroPag + cRtBen + "' OR RG2.RG2_PERIOD || RG2.RG2_NROPGT || RG2.RG2_ROTEIR IS NULL) AND "
				EndIf
			EndIf
		EndIf
				
		If cOB == 1
			If fPerAbert(MV_PAR02,fGetCalcRot("I")) //BEN
				cWhereOB += " (RIQ.RIQ_PERIOD = '" + cPer + "')" + " AND "
			Else
				cWhereOB += " (RIR.RIR_PERIOD = '" + cPer + "')" + " AND "
			EndIf
		EndIf
		
		If !lOracle
			If cPS == 1
				cWherePS += " ((((CAST((SUBSTRING(RHK.RHK_PERINI,3,4) || SUBSTRING(RHK.RHK_PERINI,1,2)) AS VARCHAR(6)) <= '" + cPer + "' AND RHK.RHK_PERFIM = '')) OR "
				cWherePS += " ((CAST((SUBSTRING(RHK.RHK_PERINI,3,4) || SUBSTRING(RHK.RHK_PERINI,1,2)) AS VARCHAR(6)) <= '" + cPer + "') AND "
				cWherePS += " (CAST((SUBSTRING(RHK.RHK_PERFIM,3,4) || SUBSTRING(RHK.RHK_PERFIM,1,2)) AS VARCHAR(6)) <= '" + cPer + "'))) OR "
				cWherePS += " (RHK_PERINI IS NULL AND RHK_PERFIM IS NULL)) AND "
			EndIf
			
			If cAgr == 1
				cWhereAgr += " ((((CAST((SUBSTRING(RHM.RHM_PERINI,3,4) || SUBSTRING(RHM.RHM_PERINI,1,2)) AS VARCHAR(6)) <= '" + cPer + "' AND RHM.RHM_PERFIM = '')) OR "
				cWhereAgr += " ((CAST((SUBSTRING(RHM.RHM_PERINI,3,4) || SUBSTRING(RHM.RHM_PERINI,1,2)) AS VARCHAR(6)) <= '" + cPer + "') AND "
				cWhereAgr += " (CAST((SUBSTRING(RHM.RHM_PERFIM,3,4) || SUBSTRING(RHM.RHM_PERFIM,1,2)) AS VARCHAR(6)) <= '" + cPer + "'))) OR "
				cWhereAgr += " (RHM_PERINI IS NULL AND RHM_PERFIM IS NULL)) AND "
			EndIf
			
			
			If cDep == 1
				cWhereDep += " ((((CAST((SUBSTRING(RHL.RHL_PERINI,3,4) || SUBSTRING(RHL.RHL_PERINI,1,2)) AS VARCHAR(6)) <= '" + cPer + "' AND RHL.RHL_PERFIM = '')) OR "
				cWhereDep += " ((CAST((SUBSTRING(RHL.RHL_PERINI,3,4) || SUBSTRING(RHL.RHL_PERINI,1,2)) AS VARCHAR(6)) <= '" + cPer + "') AND "
				cWhereDep += " (CAST((SUBSTRING(RHL.RHL_PERFIM,3,4) || SUBSTRING(RHL.RHL_PERFIM,1,2)) AS VARCHAR(6)) <= '" + cPer + "'))) OR "
				cWhereDep += " (RHL_PERINI IS NULL AND RHL_PERFIM IS NULL)) AND "
			EndIf
		Else
			If cPS == 1
				cWherePS += " ((((CAST((TRIM(SUBSTRING(RHK.RHK_PERINI,3,4) || SUBSTRING(RHK.RHK_PERINI,1,2))) AS VARCHAR(6)) <= '" + cPer + "' AND RHK.RHK_PERFIM = '')) OR "
				cWherePS += " ((CAST((TRIM(SUBSTRING(RHK.RHK_PERINI,3,4) || SUBSTRING(RHK.RHK_PERINI,1,2))) AS VARCHAR(6)) <= '" + cPer + "') AND "
				cWherePS += " (CAST((TRIM(SUBSTRING(RHK.RHK_PERFIM,3,4) || SUBSTRING(RHK.RHK_PERFIM,1,2))) AS VARCHAR(6)) <= '" + cPer + "'))) OR "
				cWherePS += " (RHK_PERINI IS NULL AND RHK_PERFIM IS NULL)) AND "
			EndIf
			
			If cAgr == 1
				cWhereAgr += " ((((CAST((TRIM(SUBSTRING(RHM.RHM_PERINI,3,4) || SUBSTRING(RHM.RHM_PERINI,1,2))) AS VARCHAR(6)) <= '" + cPer + "' AND RHM.RHM_PERFIM = '')) OR "
				cWhereAgr += " ((CAST((TRIM(SUBSTRING(RHM.RHM_PERINI,3,4) || SUBSTRING(RHM.RHM_PERINI,1,2))) AS VARCHAR(6)) <= '" + cPer + "') AND "
				cWhereAgr += " (CAST((TRIM(SUBSTRING(RHM.RHM_PERFIM,3,4) || SUBSTRING(RHM.RHM_PERFIM,1,2))) AS VARCHAR(6)) <= '" + cPer + "'))) OR "
				cWhereAgr += " (RHM_PERINI IS NULL AND RHM_PERFIM IS NULL)) AND "
			EndIf
			
			If cDep == 1
				cWhereDep += " ((((CAST((TRIM(SUBSTRING(RHL.RHL_PERINI,3,4) || SUBSTRING(RHL.RHL_PERINI,1,2))) AS VARCHAR(6)) <= '" + cPer + "' AND RHL.RHL_PERFIM = '')) OR "
				cWhereDep += " ((CAST((TRIM(SUBSTRING(RHL.RHL_PERINI,3,4) || SUBSTRING(RHL.RHL_PERINI,1,2))) AS VARCHAR(6)) <= '" + cPer + "') AND "
				cWhereDep += " (CAST((TRIM(SUBSTRING(RHL.RHL_PERFIM,3,4) || SUBSTRING(RHL.RHL_PERFIM,1,2))) AS VARCHAR(6)) <= '" + cPer + "'))) OR "
				cWhereDep += " (RHL_PERINI IS NULL AND RHL_PERFIM IS NULL)) AND "
			EndIf
		EndIf
		
	EndIf
     
	If !(Empty(cFil))
		cWhereVtr += cFil  + " AND "
		cWhereVrf += cFil  + " AND "
		cWhereVal += cFil  + " AND "
		cWhereOB  += cFil  + " AND "
		cWherePS  += cFil  + " AND "
		cWhereAgr += cFil  + " AND "
		cWhereDep += cFil  + " AND "
	EndIf
	
	If !(Empty(cCC))
		cWhereVtr += cCC  + " AND "
		cWhereVrf += cCC  + " AND "
		cWhereVal += cCC  + " AND "
		cWhereOB  += cCC  + " AND "
		cWherePS  += cCC  + " AND "
		cWhereAgr += cCC  + " AND "
		cWhereDep += cCC  + " AND "
	EndIf
	
	If !(Empty(cMat))
		cWhereVtr += cMat  + " AND "
		cWhereVrf += cMat  + " AND "
		cWhereVal += cMat  + " AND "
		cWhereOB  += cMat  + " AND "
		cWherePS  += cMat  + " AND "
		cWhereAgr += cMat  + " AND "
		cWhereDep += cMat  + " AND "
	EndIf
	
	If !(Empty(cSit))
		cWhereVtr += " (SRA.RA_SITFOLH IN (" + Upper(cSitQry) + ") "
		cWhereVrf += " (SRA.RA_SITFOLH IN (" + Upper(cSitQry) + ") "
		cWhereVal += " (SRA.RA_SITFOLH IN (" + Upper(cSitQry) + ") "
		cWhereOB  += " (SRA.RA_SITFOLH IN (" + Upper(cSitQry) + ") "
		cWherePS  += " (SRA.RA_SITFOLH IN (" + Upper(cSitQry) + ") "
		cWhereAgr += " (SRA.RA_SITFOLH IN (" + Upper(cSitQry) + ") "
		cWhereDep += " (SRA.RA_SITFOLH IN (" + Upper(cSitQry) + ") "

		If cPaisLoc == "BRA"	//TransferÍncia entre empresas/filiais deixa RA_SITFOLH="D"
			If ("T" $ cSit) .And. !("D" $ cSit)		//sÛ transferidos
				cWhereVtr += " OR (SRA.RA_SITFOLH = 'D' AND SRA.RA_RESCRAI IN ('30','31'))"
				cWhereVrf += " OR (SRA.RA_SITFOLH = 'D' AND SRA.RA_RESCRAI IN ('30','31'))"
				cWhereVal += " OR (SRA.RA_SITFOLH = 'D' AND SRA.RA_RESCRAI IN ('30','31'))"
				cWhereOB  += " OR (SRA.RA_SITFOLH = 'D' AND SRA.RA_RESCRAI IN ('30','31'))"
				cWherePS  += " OR (SRA.RA_SITFOLH = 'D' AND SRA.RA_RESCRAI IN ('30','31'))"
				cWhereAgr += " OR (SRA.RA_SITFOLH = 'D' AND SRA.RA_RESCRAI IN ('30','31'))"
				cWhereDep += " OR (SRA.RA_SITFOLH = 'D' AND SRA.RA_RESCRAI IN ('30','31'))"
			ElseIf ("D" $ cSit) .And. !("T" $ cSit)	//sÛ demitidos
				cWhereVtr += " AND (SRA.RA_SITFOLH = 'D' AND SRA.RA_RESCRAI NOT IN ('30','31'))"
				cWhereVrf += " AND (SRA.RA_SITFOLH = 'D' AND SRA.RA_RESCRAI NOT IN ('30','31'))"
				cWhereVal += " AND (SRA.RA_SITFOLH = 'D' AND SRA.RA_RESCRAI NOT IN ('30','31'))"
				cWhereOB  += " AND (SRA.RA_SITFOLH = 'D' AND SRA.RA_RESCRAI NOT IN ('30','31'))"
				cWherePS  += " AND (SRA.RA_SITFOLH = 'D' AND SRA.RA_RESCRAI NOT IN ('30','31'))"
				cWhereAgr += " AND (SRA.RA_SITFOLH = 'D' AND SRA.RA_RESCRAI NOT IN ('30','31'))"
				cWhereDep += " AND (SRA.RA_SITFOLH = 'D' AND SRA.RA_RESCRAI NOT IN ('30','31'))"
			EndIf
		EndIf
		
		cWhereVtr += ") AND "
		cWhereVrf += ") AND "
		cWhereVal += ") AND "
		cWhereOB  += ") AND "
		cWherePS  += ") AND "
		cWhereAgr += ") AND "
		cWhereDep += ") AND "
	EndIf
	
	If !(Empty(cCat))
		cWhereVtr += " SRA.RA_CATFUNC IN (" + Upper(cCatQry) + ") AND "
		cWhereVrf += " SRA.RA_CATFUNC IN (" + Upper(cCatQry) + ") AND "
		cWhereVal += " SRA.RA_CATFUNC IN (" + Upper(cCatQry) + ") AND "
		cWhereOB  += " SRA.RA_CATFUNC IN (" + Upper(cCatQry) + ") AND "
		cWherePS  += " SRA.RA_CATFUNC IN (" + Upper(cCatQry) + ") AND "
		cWhereAgr += " SRA.RA_CATFUNC IN (" + Upper(cCatQry) + ") AND "
		cWhereDep += " SRA.RA_CATFUNC IN (" + Upper(cCatQry) + ") AND "
	EndIf

	If lTemCCT .and. !Empty(cCCT)
		cWhereVtr += cCCT + " AND "
		cWhereVrf += cCCT + " AND "
		cWhereVal += cCCT + " AND "
		cWherePS  += cCCT + " AND "
		cWhereAgr += cCCT + " AND "
		cWhereDep += cCCT + " AND "
	EndIf
	
	If !(Empty(cWhereVrf))
		cWhereVrf	:= "%" + cWhereVrf + "%"
	Else
		cWhereVrf	:= "% %"
	EndIf
	
	If !(Empty(cWhereVtr))
		cWhereVtr	:= "%" + cWhereVtr + "%"
	Else
		cWhereVtr	:= "% %"
	EndIf
	
	If !(Empty(cWhereVal))
		cWhereVal	:= "%" + cWhereVal + "%"
	Else
		cWhereVal	:= "% %"
	EndIf
	
	If !(Empty(cWhereOB))
		cWhereOB	:= "%" + cWhereOB + "%"
	Else
		cWhereOB	:= "% %"
	EndIf
	
	If !(Empty(cWherePS))
		cWherePS	:= "%" + cWherePS + "%"
	Else
		cWherePS	:= "% %"
	EndIf
	
	If !(Empty(cWhereAgr))
		cWhereAgr	:= "%" + cWhereAgr + "%"
	Else
		cWhereAgr	:= "% %"
	EndIf
	
	If !(Empty(cWhereDep))
		cWhereDep	:= "%" + cWhereDep + "%"
	Else
		cWhereDep	:= "% %"
	EndIf

	//Busca no banco de dados
	
	//vale refeiÁ„o
	If cVR == 1 
		If fPerAbert(MV_PAR02,fGetCalcRot("D"))

			cWhereVrf := Replace(cWhereVrf, "RCE_CCT", "R0_CODCCT")

			BeginSql Alias cAliasQry1
				SELECT    
					'VR' AS Tipo
					, RA_FILIAL AS FilFunc, RA_MAT AS MatFunc, RA_NOME AS NomeFunc, RA_CC AS CCFunc
					, R0_CODIGO AS CodBen, R0_TPVALE AS TpBen, SUM(R0_VALCAL) AS ValCal, SUM(R0_VLRFUNC) AS ValFunc, SUM(R0_VLREMP) AS ValEmp
					, '' AS CodBen2, '' AS DescBen2
					, RFO_CODIGO AS CodDes, RFO_DESCR AS DescBen, '' AS OrigemPLA %exp:cR0CCT%
				FROM
					%table:SRA% SRA
					INNER JOIN %table:SR0% SR0 ON %exp:cJoinSR0%
						AND R0_MAT = RA_MAT AND R0_TPVALE = '1'
						AND SR0.%notDel%
					LEFT JOIN %table:RFO% RFO ON %exp:cJoinRFO%
						AND RFO_CODIGO = R0_CODIGO
						AND RFO_TPVALE = R0_TPVALE
						AND RFO.%notDel%
				WHERE
					%exp:cWhereVrf%
					SRA.%notDel%
				GROUP BY RA_FILIAL , RA_MAT, RA_NOME, RA_CC  , R0_CODIGO , R0_TPVALE , RFO_CODIGO, RFO_DESCR %exp:cSR0GRP%
			EndSql			
		Else

			cWhereVrf := Replace(cWhereVrf, "RCE_CCT", "RG2_CODCCT")

			BeginSql Alias cAliasQry1
				SELECT    
					'VR' AS Tipo
					, RA_FILIAL AS FilFunc, RA_MAT AS MatFunc, RA_NOME AS NomeFunc, RA_CC AS CCFunc
					, RG2_CODIGO AS CodBen, RG2_TPVALE AS TpBen, SUM(RG2_VALCAL) AS VALCAL,SUM(RG2_CUSFUN) AS VALFUNC,SUM(RG2_CUSEMP) AS VALEMP
					, '' AS CodBen2, '' AS DescBen2
					, RFO_CODIGO AS CodDes, RFO_DESCR AS DescBen, '' AS OrigemPLA %exp:cRG2CCT%
				FROM
					%table:SRA% SRA
					INNER JOIN %table:RG2% RG2 ON %exp:cJoinRG2%
						AND RG2_MAT = RA_MAT AND RG2_TPVALE = '1'
						AND RG2.%notDel%
					LEFT JOIN %table:RFO% RFO ON %exp:cJoinRFO%
						AND RFO_CODIGO = RG2_CODIGO
						AND RFO_TPVALE = RG2_TPVALE
						AND RFO.%notDel%
				WHERE
					%exp:cWhereVrf%
					SRA.%notDel%
				GROUP BY RA_FILIAL,RA_MAT ,RA_NOME ,RA_CC ,RG2_CODIGO, RG2_TPVALE ,RFO_CODIGO , RFO_DESCR %exp:cRG2GRP%
			EndSql
		EndIf
	Else
		BeginSql Alias cAliasQry1
			SELECT    DISTINCT
				'' AS Tipo
				, '' AS FilFunc, '' AS MatFunc, '' AS NomeFunc, '' AS CCFunc
				, '' AS CodBen, '' AS TpBen, 0 AS ValCal, 0 AS ValFunc, 0 AS ValEmp
				, '' AS CodBen2, '' AS DescBen2
				, '' AS CodDes, '' AS DescBen, '' AS OrigemPLA %exp:cNULLCCT%
			FROM
				%table:SRA% SRA
			WHERE 0 <> 0				
		EndSql
	EndIf
	
	cQryVrf := "%" + GetLastQuery()[2] + "%"
	VldStrQry(@cQryVrf,@cNQryVrf)	
	
	//vale alimentaÁ„o
	If cVA == 1 
		If fPerAbert(MV_PAR02,fGetCalcRot("E"))

			cWhereVal := Replace(cWhereVal, "RCE_CCT", "R0_CODCCT")

			BeginSql Alias cAliasQry2
				SELECT    
					'VA' AS Tipo
					, RA_FILIAL AS FilFunc, RA_MAT AS MatFunc, RA_NOME AS NomeFunc, RA_CC AS CCFunc
					, R0_CODIGO AS CodBen, R0_TPVALE AS TpBen, SUM(R0_VALCAL) AS ValCal, SUM(R0_VLRFUNC) AS ValFunc, SUM(R0_VLREMP) AS ValEmp
					, '' AS CodBen2, '' AS DescBen2
					, RFO_CODIGO AS CodDes, RFO_DESCR AS DescBen, '' AS OrigemPLA %exp:cR0CCT%
				FROM
					%table:SRA% SRA
					INNER JOIN %table:SR0% SR0 ON %exp:cJoinSR0%
						AND R0_MAT = RA_MAT AND R0_TPVALE = '2'
						AND SR0.%notDel%
					LEFT JOIN %table:RFO% RFO ON %exp:cJoinRFO%
						AND RFO_CODIGO = R0_CODIGO
						AND RFO_TPVALE = R0_TPVALE
						AND RFO.%notDel%
				WHERE
					%exp:cWhereVal%
					SRA.%notDel%
				GROUP BY RA_FILIAL , RA_MAT, RA_NOME, RA_CC  , R0_CODIGO , R0_TPVALE , RFO_CODIGO, RFO_DESCR %exp:cSR0GRP%
			EndSql
		Else

			cWhereVal := Replace(cWhereVal, "RCE_CCT", "RG2_CODCCT")

			BeginSql Alias cAliasQry2
				SELECT    
					'VA' AS Tipo
					, RA_FILIAL AS FilFunc, RA_MAT AS MatFunc, RA_NOME AS NomeFunc, RA_CC AS CCFunc
					, RG2_CODIGO AS CodBen, RG2_TPVALE AS TpBen, SUM(RG2_VALCAL) AS VALCAL,SUM(RG2_CUSFUN) AS VALFUNC,SUM(RG2_CUSEMP) AS VALEMP
					, '' AS CodBen2, '' AS DescBen2
					, RFO_CODIGO AS CodDes, RFO_DESCR AS DescBen, '' AS OrigemPLA %exp:cRG2CCT%
				FROM
					%table:SRA% SRA
					INNER JOIN %table:RG2% RG2 ON %exp:cJoinRG2%
						AND RG2_MAT = RA_MAT AND RG2_TPVALE = '2'
						AND RG2.%notDel%
					LEFT JOIN %table:RFO% RFO ON %exp:cJoinRFO%
						AND RFO_CODIGO = RG2_CODIGO
						AND RFO_TPVALE = RG2_TPVALE
						AND RFO.%notDel%
				WHERE
					%exp:cWhereVal%
					SRA.%notDel%
				GROUP BY RA_FILIAL,RA_MAT ,RA_NOME ,RA_CC ,RG2_CODIGO, RG2_TPVALE ,RFO_CODIGO , RFO_DESCR %exp:cRG2GRP%
			EndSql
		EndIf
	Else
		BeginSql Alias cAliasQry2
			SELECT    DISTINCT
				'' AS Tipo
				, '' AS FilFunc, '' AS MatFunc, '' AS NomeFunc, '' AS CCFunc
				, '' AS CodBen, '' AS TpBen, 0 AS ValCal, 0 AS ValFunc, 0 AS ValEmp
				, '' AS CodBen2, '' AS DescBen2
				, '' AS CodDes, '' AS DescBen, '' AS OrigemPLA %exp:cNULLCCT%
			FROM
				%table:SRA% SRA
			WHERE 0 <> 0				
		EndSql
	EndIf
	
	cQryVal := "%" + SubStr(GetLastQuery()[2],9) + "%"
	VldStrQry(@cQryVal,@cNQryVal)
	
	//vale transporte
	If cVT == 1
		If fPerAbert(MV_PAR02,fGetCalcRot("8"))

			cWhereVtr := Replace(cWhereVtr, "RCE_CCT", "R0_CODCCT")

			BeginSql Alias cAliasQry3
				SELECT    
					'VT' AS Tipo
					, RA_FILIAL AS FilFunc, RA_MAT AS MatFunc, RA_NOME AS NomeFunc, RA_CC AS CCFunc
					, R0_CODIGO AS CodBen, R0_TPVALE AS TpBen, SUM(R0_VALCAL) AS ValCal, SUM(R0_VLRFUNC) AS ValFunc, SUM(R0_VLREMP) AS ValEmp
					, RN_COD AS CodBen2, RN_DESC AS DescBen2
					, '' AS CodDes, '' AS DescBen, '' AS OrigemPLA %exp:cR0CCT%
				FROM
					%table:SRA% SRA
					INNER JOIN %table:SR0% SR0 ON %exp:cJoinSR0%
						AND R0_MAT = RA_MAT AND R0_TPVALE = '0'
						AND SR0.%notDel%
					LEFT JOIN %table:SRN% SRN ON %exp:cJoinSRN%
						AND RN_COD = R0_CODIGO
						AND R0_TPVALE = '0'
						AND SRN.%notDel%
				WHERE
					%exp:cWhereVtr%
					SRA.%notDel%
				GROUP BY RA_FILIAL , RA_MAT, RA_NOME, RA_CC  , R0_CODIGO , R0_TPVALE , RN_COD, RN_DESC %exp:cSR0GRP%
			EndSql
		Else

			cWhereVtr := Replace(cWhereVtr, "RCE_CCT", "RG2_CODCCT")

			BeginSql Alias cAliasQry3
				SELECT    
					'VT' AS Tipo
					, RA_FILIAL AS FilFunc, RA_MAT AS MatFunc, RA_NOME AS NomeFunc, RA_CC AS CCFunc
					, RG2_CODIGO AS CodBen, RG2_TPVALE AS TpBen, SUM(RG2_VALCAL) AS VALCAL,SUM(RG2_CUSFUN) AS VALFUNC,SUM(RG2_CUSEMP) AS VALEMP
					, RN_COD AS CodBen2, RN_DESC AS DescBen2 
					, '' AS CodDes, '' AS DescBen, '' AS OrigemPLA %exp:cRG2CCT%
				FROM
					%table:SRA% SRA
					INNER JOIN %table:RG2% RG2 ON %exp:cJoinRG2%
						AND RA_MAT = RG2_MAT AND RG2_TPVALE ='0'
						AND RG2.%notDel%
					LEFT JOIN %table:SRN% SRN ON %exp:cJoinSRN%
						AND RN_COD = RG2_CODIGO
						AND RG2_TPVALE = '0'
						AND SRN.%notDel%
				WHERE
					%exp:cWhereVtr%
					SRA.%notDel%
				GROUP BY RA_FILIAL , RA_MAT, RA_NOME, RA_CC  , RG2_CODIGO , RG2_TPVALE , RN_COD, RN_DESC %exp:cRG2GRP%
			EndSql
		EndIf
	Else
		BeginSql Alias cAliasQry3
			SELECT    DISTINCT
				'' AS Tipo
				, '' AS FilFunc, '' AS MatFunc, '' AS NomeFunc, '' AS CCFunc
				, '' AS CodBen, '' AS TpBen, 0 AS ValCal, 0 AS ValFunc, 0 AS ValEmp
				, '' AS CodBen2, '' AS DescBen2
				, '' AS CodDes, '' AS DescBen, '' AS OrigemPLA %exp:cNULLCCT%
			FROM
				%table:SRA% SRA
			WHERE 0 <> 0				
		EndSql
	EndIf
	
	cQryVtr := "%" + GetLastQuery()[2] + "%"
	VldStrQry(@cQryVtr,@cNQryVtr)
	
	//outros beneficios 
	If cOB == 1
		If fPerAbert(MV_PAR02,fGetCalcRot("I"))
			BeginSql Alias cAliasQry4
				SELECT DISTINCT
					'Outros' AS Tipo
					, RA_FILIAL AS FilFunc, RA_MAT AS MatFunc, RA_NOME AS NomeFunc, RA_CC AS CCFunc
					, RIQ_COD AS CodBen,  RIQ_TPBENE AS TpBen,  RIQ_VALBEN AS ValCal,  RIQ_VLRFUN AS ValFunc,  RIQ_VLREMP AS ValEmp
					, '' AS CodBen2, '' AS DescBen2
					, '' AS CodDes,  '' AS DescBen, '' AS OrigemPLA %exp:cNULLCCT%
				FROM
					%table:SRA% SRA
					INNER JOIN %table:RIQ% RIQ ON %exp:cJoinRIQ%
						AND RIQ_MAT = RA_MAT
						AND RIQ.%notDel%
				WHERE
					%exp:cWhereOB%
					SRA.%notDel%
			EndSql
		Else
			BeginSql Alias cAliasQry4
				SELECT DISTINCT
					'Outros' AS Tipo
					, RA_FILIAL AS FilFunc, RA_MAT AS MatFunc, RA_NOME AS NomeFunc, RA_CC AS CCFunc
					, RIR_COD AS CodBen,  RIR_TPBENE AS TpBen,  RIR_VALBEN AS ValCal,  RIR_VLRFUN AS ValFunc,  RIR_VLREMP AS ValEmp
					, '' AS CodBen2, '' AS DescBen2
					, '' AS CodDes,  '' AS DescBen, '' AS OrigemPLA %exp:cNULLCCT%
				FROM
					%table:SRA% SRA
					INNER JOIN %table:RIR% RIR ON %exp:cJoinRIR%
						AND RIR_MAT = RA_MAT
						AND RIR.%notDel%
				WHERE
					%exp:cWhereOB%
					SRA.%notDel%
			EndSql
		EndIf
	Else
		BeginSql Alias cAliasQry4
			SELECT    DISTINCT
				'' AS Tipo
				, '' AS FilFunc, '' AS MatFunc, '' AS NomeFunc, '' AS CCFunc
				, '' AS CodBen, '' AS TpBen, 0 AS ValCal, 0 AS ValFunc, 0 AS ValEmp
				, '' AS CodBen2, '' AS DescBen2
				, '' AS CodDes, '' AS DescBen, '' AS OrigemPLA %exp:cNULLCCT%
			FROM
				%table:SRA% SRA
			WHERE 0 <> 0
		EndSql
	EndIf
	
	cQryOB := "%" + GetLastQuery()[2] + "%"
	VldStrQry(@cQryOB,@cNQryOB)
	
	// plano de saude titular 
	If cPS == 1
		If fPerAbert(MV_PAR02,fGetCalcRot("C"))

			cWherePS := Replace(cWherePS, "RCE_CCT", "RHR_CODCCT")

			BeginSql Alias cAliasQry5
				SELECT DISTINCT
					'PS' AS Tipo
					, RA_FILIAL AS FilFunc, RA_MAT AS MatFunc, RA_NOME AS NomeFunc, RA_CC AS CCFunc
					, RHK_TPPLAN AS CodBen , RHK_TPFORN AS TpBen , RHR_VLRFUN+RHR_VLREMP AS ValCal , RHR_VLRFUN AS ValFunc , RHR_VLREMP AS ValEmp
					, RHK_PLANO AS CodBen2, '' AS DescBen2
					, RHK_CODFOR AS CodDes, '' AS DescBen, RHR_ORIGEM AS OrigemPLA %exp:cRHRCCT%
				FROM
					%table:SRA% SRA
					INNER JOIN %table:RHK% RHK ON %exp:cJoinRHK%
						AND RHK.RHK_MAT = SRA.RA_MAT
						AND RHK.D_E_L_E_T_= ' '
					INNER JOIN %table:RHR% RHR ON %exp:cJoinRHR%
						AND RHR.RHR_MAT||RHR.RHR_TPFORN||RHR.RHR_CODFOR||RHR.RHR_TPPLAN||RHR.RHR_PLANO = RHK.RHK_MAT||RHK.RHK_TPFORN||RHK.RHK_CODFOR||RHK.RHK_TPPLAN||RHK.RHK_PLANO 
						AND RHR.RHR_ORIGEM = '1' AND RHR.D_E_L_E_T_= ' '
				WHERE
					%exp:cWherePS%
					SRA.%notDel%
			EndSql
		Else

			cWherePS := Replace(cWherePS, "RCE_CCT", "RHS_CODCCT")

			BeginSql Alias cAliasQry5
				SELECT DISTINCT
					'PS' AS Tipo
					, RA_FILIAL AS FilFunc, RA_MAT AS MatFunc, RA_NOME AS NomeFunc, RA_CC AS CCFunc
					, RHK_TPPLAN AS CodBen , RHK_TPFORN AS TpBen , RHS_VLRFUN+RHS_VLREMP AS ValCal , RHS_VLRFUN AS ValFunc , RHS_VLREMP AS ValEmp
					, RHK_PLANO AS CodBen2, '' AS DescBen2
					, RHK_CODFOR AS CodDes, '' AS DescBen, RHS_ORIGEM AS OrigemPLA %exp:cRHSCCT%
				FROM
					%table:SRA% SRA
					INNER JOIN %table:RHK% RHK ON %exp:cJoinRHK%
						AND RHK.RHK_MAT = SRA.RA_MAT
						AND RHK.D_E_L_E_T_= ' '
					INNER JOIN %table:RHS% RHS ON %exp:cJoinRHS%
						AND RHS.RHS_MAT||RHS.RHS_TPFORN||RHS.RHS_CODFOR||RHS.RHS_TPPLAN||RHS.RHS_PLANO = RHK.RHK_MAT||RHK.RHK_TPFORN||RHK.RHK_CODFOR||RHK.RHK_TPPLAN||RHK.RHK_PLANO 
						AND RHS.RHS_ORIGEM = '1' AND RHS.D_E_L_E_T_= ' '
				WHERE
					%exp:cWherePS%
					SRA.%notDel%
			EndSql
		Endif
	Else
		BeginSql Alias cAliasQry5
			SELECT    DISTINCT
				'' AS Tipo
				, '' AS FilFunc, '' AS MatFunc, '' AS NomeFunc, '' AS CCFunc
				, '' AS CodBen, '' AS TpBen, 0 AS ValCal, 0 AS ValFunc, 0 AS ValEmp
				, '' AS CodBen2, '' AS DescBen2
				, '' AS CodDes, '' AS DescBen, '' AS OrigemPLA %exp:cNULLCCT%
			FROM
				%table:SRA% SRA
			WHERE 0 <> 0				
		EndSql
	EndIf
		
	cQryPS := "%" + GetLastQuery()[2] + "%"
	VldStrQry(@cQryPS,@cNQryPS)	
	
	//agregados
	If cAgr == 1 .AND. cPS == 1
		If fPerAbert(MV_PAR02,fGetCalcRot("C"))

			cWhereAgr := Replace(cWhereAgr, "RCE_CCT", "RHR_CODCCT")

			BeginSql Alias cAliasAgreg
				SELECT DISTINCT 'PS' AS Tipo,    RA_FILIAL  AS FilFunc, RA_MAT AS MatFunc, RHM_NOME AS NomeFunc, RA_CC AS CCFunc, 
						RHM_TPPLAN AS CodBen,  RHM_TPFORN AS TpBen,   RHR_VLRFUN+RHR_VLREMP AS ValCal,
						RHR_VLRFUN AS ValFunc, RHR_VLREMP AS ValEmp,  RHM_PLANO AS CodBen2, '' AS DescBen2 , RHM_CODFOR AS CodDes, '' AS DescBen, 
						RHR_ORIGEM AS OrigemPLA %exp:cRHRCCT%
				FROM
					%table:SRA% SRA
					INNER JOIN %table:RHM% RHM ON %exp:cJoinRHM%
						AND RHM.RHM_MAT = SRA.RA_MAT
						AND RHM.D_E_L_E_T_= ' '
					INNER JOIN %table:RHR% RHR ON %exp:cJoinRHR%
						AND RHR.RHR_MAT||RHR.RHR_TPFORN||RHR.RHR_CODFOR||RHR.RHR_TPPLAN||RHR.RHR_PLANO = RHM.RHM_MAT||RHM.RHM_TPFORN||RHM.RHM_CODFOR||RHM.RHM_TPPLAN||RHM.RHM_PLANO 
						AND RHR.RHR_ORIGEM = '3' AND RHR.D_E_L_E_T_= ' '
				WHERE
					%exp:cWhereAgr%
					SRA.%notDel%
			EndSql
		Else

			cWhereAgr := Replace(cWhereAgr, "RCE_CCT", "RHS_CODCCT")

			BeginSql Alias cAliasAgreg
				SELECT DISTINCT 'PS' AS Tipo,    RA_FILIAL  AS FilFunc, RA_MAT AS MatFunc, RHM_NOME AS NomeFunc, RA_CC AS CCFunc, 
						RHM_TPPLAN AS CodBen,  RHM_TPFORN AS TpBen,   RHS_VLRFUN+RHS_VLREMP AS ValCal,
						RHS_VLRFUN AS ValFunc, RHS_VLREMP AS ValEmp,  RHM_PLANO AS CodBen2, '' AS DescBen2 , RHM_CODFOR AS CodDes, '' AS DescBen, 
						RHS_ORIGEM AS OrigemPLA %exp:cRHSCCT%
				FROM
					%table:SRA% SRA
					INNER JOIN %table:RHM% RHM ON %exp:cJoinRHM%
						AND RHM.RHM_MAT = SRA.RA_MAT
						AND RHM.D_E_L_E_T_= ' '
					INNER JOIN %table:RHS% RHS ON %exp:cJoinRHS%
						AND RHS.RHS_MAT||RHS.RHS_TPFORN||RHS.RHS_CODFOR||RHS.RHS_TPPLAN||RHS.RHS_PLANO = RHM.RHM_MAT||RHM.RHM_TPFORN||RHM.RHM_CODFOR||RHM.RHM_TPPLAN||RHM.RHM_PLANO 
						AND RHS.RHS_ORIGEM = '3' AND RHS.D_E_L_E_T_= ' '
				WHERE
					%exp:cWhereAgr%
					SRA.%notDel%
			EndSql
		Endif
	Else
		BeginSql Alias cAliasAgreg
			SELECT    DISTINCT
				'' AS Tipo
				, '' AS FilFunc, '' AS MatFunc, '' AS NomeFunc, '' AS CCFunc
				, '' AS CodBen, '' AS TpBen, 0 AS ValCal, 0 AS ValFunc, 0 AS ValEmp
				, '' AS CodBen2, '' AS DescBen2
				, '' AS CodDes, '' AS DescBen, '' AS OrigemPLA %exp:cNULLCCT%
			FROM
				%table:SRA% SRA
			WHERE 0 <> 0				
		EndSql
	EndIf
	
	cQryaGgr		:=  "%" + GetLastQuery()[2] + "%"
	VldStrQry(@cQryaGgr,@cNQryaGgr)	
	
	//Dependentes
	If cDep == 1 .AND. cPS == 1
		If fPerAbert(MV_PAR02,fGetCalcRot("C"))

			cWhereDep := Replace(cWhereDep, "RCE_CCT", "RHR_CODCCT")

			BeginSql Alias cAliasDepen
				SELECT DISTINCT 'PS' AS Tipo,    RA_FILIAL  AS FilFunc, RA_MAT AS MatFunc, RB_NOME AS NomeFunc, RA_CC AS CCFunc, 
						RHL_TPPLAN AS CodBen,  RHL_TPFORN AS TpBen,   RHR_VLRFUN+RHR_VLREMP AS ValCal,
						RHR_VLRFUN AS ValFunc, RHR_VLREMP AS ValEmp,  RHL_PLANO AS CodBen2, '' AS DescBen2 , RHL_CODFOR AS CodDes, '' AS DescBen, 
						RHR_ORIGEM AS OrigemPLA %exp:cRHRCCT%
				FROM
					%table:SRA% SRA
					INNER JOIN %table:RHL% RHL ON %exp:cJoinRHL%
						AND RHL.RHL_MAT = SRA.RA_MAT
						AND RHL.D_E_L_E_T_= ' '
					INNER JOIN %table:RHR% RHR ON %exp:cJoinRHR%
						AND RHR.RHR_MAT||RHR.RHR_TPFORN||RHR.RHR_CODFOR||RHR.RHR_TPPLAN||RHR.RHR_PLANO = RHL.RHL_MAT||RHL.RHL_TPFORN||RHL.RHL_CODFOR||RHL.RHL_TPPLAN||RHL.RHL_PLANO 
						AND RHR.RHR_ORIGEM = '2' AND RHR.D_E_L_E_T_= ' '
					INNER JOIN %table:SRB% SRB ON %exp:cJoinSRB%
						AND SRB.RB_MAT = SRA.RA_MAT AND SRB.RB_COD = RHR.RHR_CODIGO AND SRB.D_E_L_E_T_ = ''
				WHERE
					%exp:cWhereDep%
					SRA.%notDel%
			EndSql
		Else 

			cWhereDep := Replace(cWhereDep, "RCE_CCT", "RHS_CODCCT")

			BeginSql Alias cAliasDepen
				SELECT DISTINCT 'PS' AS Tipo,    RA_FILIAL  AS FilFunc, RA_MAT AS MatFunc, RB_NOME AS NomeFunc, RA_CC AS CCFunc, 
						RHL_TPPLAN AS CodBen,  RHL_TPFORN AS TpBen,   RHS_VLRFUN+RHS_VLREMP AS ValCal,
						RHS_VLRFUN AS ValFunc, RHS_VLREMP AS ValEmp,  RHL_PLANO AS CodBen2, '' AS DescBen2 , RHL_CODFOR AS CodDes, '' AS DescBen, 
						RHS_ORIGEM AS OrigemPLA %exp:cRHSCCT%
				FROM
					%table:SRA% SRA
					INNER JOIN %table:RHL% RHL ON %exp:cJoinRHL%
						AND RHL.RHL_MAT = SRA.RA_MAT
						AND RHL.D_E_L_E_T_= ' '
					INNER JOIN %table:RHS% RHS ON %exp:cJoinRHS%
						AND RHS.RHS_MAT||RHS.RHS_TPFORN||RHS.RHS_CODFOR||RHS.RHS_TPPLAN||RHS.RHS_PLANO = RHL.RHL_MAT||RHL.RHL_TPFORN||RHL.RHL_CODFOR||RHL.RHL_TPPLAN||RHL.RHL_PLANO 
						AND RHS.RHS_ORIGEM = '2' AND RHS.D_E_L_E_T_= ' '
					INNER JOIN %table:SRB% SRB ON %exp:cJoinSRB%
						AND SRB.RB_MAT = SRA.RA_MAT AND SRB.RB_COD = RHS.RHS_CODIGO AND SRB.D_E_L_E_T_ = ''
				WHERE
					%exp:cWhereDep%
					SRA.%notDel%
			EndSql
		Endif
	Else
		BeginSql Alias cAliasDepen
			SELECT    DISTINCT
				'' AS Tipo
				, '' AS FilFunc, '' AS MatFunc, '' AS NomeFunc, '' AS CCFunc
				, '' AS CodBen, '' AS TpBen, 0 AS ValCal, 0 AS ValFunc, 0 AS ValEmp
				, '' AS CodBen2, '' AS DescBen2
				, '' AS CodDes, '' AS DescBen, '' AS OrigemPLA %exp:cNULLCCT%
			FROM
				%table:SRA% SRA
			WHERE 0 <> 0				
		EndSql
	EndIf
	
	cQryDep		:=  "%" + GetLastQuery()[2] + "%"
	VldStrQry(@cQryDep,@cNQryDep)

	If nOrdem == 1
		cOrdem := "% 3,15 %"
	Else 
		cOrdem := "% 16,2,5,3,15 %"
	EndIf
		
	//Query princial
	BeginSql Alias cAliasQry
		SELECT %exp:cQryVal+cNQryVal%
		UNION
		%exp:cQryVrf+cNQryVrf%
		UNION
		%exp:cQryVtr+cNQryVtr%
		UNION
		%exp:cQryOB+cNQryOB%
		UNION
		%exp:cQryPS+cNQryPS%
		UNION
		%exp:cQryaGgr+cNQryaGgr%
		UNION
		%exp:cQryDep+cNQryDep%
		ORDER BY %exp:cOrdem%
	EndSql
	
	//CriaÁ„o das tabelas tempor·rias com os dados de impress„o	
	Aadd( aColumns, { "TIPOBEN"    , "C", 6                       , 0                       ,                                           } )
	Aadd( aColumns, { "RA_FILIAL"  , "C", TAMSX3("RA_FILIAL")[1]  , TAMSX3("RA_FILIAL")[2]  , GetSx3Cache( "RA_FILIAL" , "X3_PICTURE" ) } )
	Aadd( aColumns, { "RA_MAT"     , "C", TAMSX3("RA_MAT")[1]     , TAMSX3("RA_MAT")[2]	    , GetSx3Cache( "RA_MAT" , "X3_PICTURE"    ) } )
	Aadd( aColumns, { "RA_NOME"    , "C", TAMSX3("RB_NOME")[1]    , TAMSX3("RB_NOME")[2]	, GetSx3Cache( "RB_NOME" , "X3_PICTURE"   ) } )
	Aadd( aColumns, { "RA_CC"      , "C", TAMSX3("RA_CC")[1]      , TAMSX3("RA_CC")[2]      , GetSx3Cache( "RA_CC" , "X3_PICTURE"     ) } )
	If lTemCCT
		Aadd( aColumns, { "CODCCT"     , "C", TAMSX3("R0_CODCCT")[1]  , TAMSX3("R0_CODCCT")[2]  , GetSx3Cache( "R0_CODCCT" , "X3_PICTURE" ) } )
	EndIf
	Aadd( aColumns, { "CODBEN"     , "C", TAMSX3("R0_CODIGO")[1]  , TAMSX3("R0_CODIGO")[2]  , GetSx3Cache( "R0_CODIGO" , "X3_PICTURE" ) } )
	Aadd( aColumns, { "DESCBEN"    , "C", TAMSX3("RFO_DESCR")[1]  , TAMSX3("RFO_DESCR")[2]  , GetSx3Cache( "RFO_DESCR" , "X3_PICTURE" ) } )
	Aadd( aColumns, { "DESCBEN2"   , "C", TAMSX3("RIQ_DESCBN")[1] , TAMSX3("RIQ_DESCBN")[2] , GetSx3Cache( "RIQ_DESCBN", "X3_PICTURE" ) } )
	Aadd( aColumns, { "VALCAL"     , "N", TAMSX3("R0_VALCAL")[1]  , TAMSX3("R0_VALCAL")[2]  , GetSx3Cache( "R0_VALCAL" , "X3_PICTURE" ) } )
	Aadd( aColumns, { "VALFUNC"    , "N", TAMSX3("R0_VLRFUNC")[1] , TAMSX3("R0_VLRFUNC")[2] , GetSx3Cache( "R0_VLRFUNC" , "X3_PICTURE") } )
	Aadd( aColumns, { "VALEMP"     , "N", TAMSX3("R0_VLREMP")[1]  , TAMSX3("R0_VLREMP")[2]  , GetSx3Cache( "R0_VLREMP" , "X3_PICTURE" ) } )  
	Aadd( aColumns, { "CODPLAN"    , "C", TAMSX3("RHL_PLANO")[1]  , TAMSX3("RHL_PLANO")[2]  , GetSx3Cache( "RHL_PLANO" , "X3_PICTURE" ) } )  
	Aadd( aColumns, { "CODFORN"    , "C", TAMSX3("RHL_CODFOR")[1] , TAMSX3("RHL_CODFOR")[2] , GetSx3Cache( "RHL_CODFOR" , "X3_PICTURE") } )
	Aadd( aColumns, { "TPPLAN"     , "C", TAMSX3("RHL_TPPLAN")[1] , TAMSX3("RHL_TPPLAN")[2] , GetSx3Cache( "RHL_TPPLAN" , "X3_PICTURE") } ) 
	Aadd( aColumns, { "TPFORN"     , "C", TAMSX3("RHL_TPFORN")[1] , TAMSX3("RHL_TPFORN")[2] , GetSx3Cache( "RHL_TPFORN" , "X3_PICTURE") } )
	Aadd( aColumns, { "OrigemPLA"  , "C", 1						  , 0					    ,											} )
	
	If Select(cAliasMain) > 0
		DbSelectArea(cAliasMain)
		DbCloseArea()
	EndIf

	oTmpTable := FWTemporaryTable():New( cAliasMain, aColumns )
	
	If nOrdem == 1
		oTmpTable:AddIndex( "IND1", {"RA_FILIAL", "RA_MAT", "TIPOBEN"} )
	Else
		oTmpTable:AddIndex( "IND1", {"CODCCT", "RA_FILIAL", "RA_CC", "RA_MAT", "TIPOBEN"} )
	EndIf
	
	oTmpTable:Create()
	
	//GravaÁ„o na tabela tempor·ria
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While !(cAliasQry)->(Eof())
		RecLock(cAliasMain,.T.)
		
		(cAliasMain)->TIPOBEN 	:= (cAliasQry)->TIPO
		(cAliasMain)->RA_FILIAL := (cAliasQry)->FilFunc
		(cAliasMain)->RA_MAT 	:= (cAliasQry)->MatFunc
		(cAliasMain)->RA_CC 	:= (cAliasQry)->CCFunc
		(cAliasMain)->RA_NOME 	:= (cAliasQry)->NomeFunc
		(cAliasMain)->OrigemPLA := (cAliasQry)->OrigemPLA			
		(cAliasMain)->CODBEN 	:= (cAliasQry)->CodBen2
		
		Do Case
			Case Trim((cAliasQry)->TIPO) == "PS"
				(cAliasMain)->DESCBEN := If(AllTrim((cAliasQry)->TpBen) == "1",OemToAnsi(STR0040),OemToAnsi(STR0041))
			Case Trim((cAliasQry)->TIPO) == "Outros"
				(cAliasMain)->DESCBEN := fDescRCC("S011",(cAliasQry)->TpBen,1,2,3,30)
			OtherWise
				(cAliasMain)->DESCBEN := (cAliasQry)->Tipo
		EndCase
		
		Do Case
			Case Trim((cAliasQry)->TIPO) == "PS"
				(cAliasMain)->DESCBEN2 := fDesPlan(AllTrim((cAliasQry)->TpBen),AllTrim((cAliasQry)->CodBen),AllTrim((cAliasQry)->CodBen2))
			Case Trim((cAliasQry)->TIPO) == "Outros"
				(cAliasMain)->DESCBEN2 := fDesc('RIS',(cAliasQry)->TpBen+(cAliasQry)->CodBen,'RIS_DESC')
			Case Trim((cAliasQry)->TIPO) == "VT"
				(cAliasMain)->DESCBEN2 := (cAliasQry)->DescBen2
			OtherWise
				(cAliasMain)->DESCBEN2 := (cAliasQry)->DescBen
		EndCase
		
		(cAliasMain)->VALCAL  := (cAliasQry)->ValCal
		(cAliasMain)->VALEMP  := (cAliasQry)->ValEmp
		(cAliasMain)->VALFUNC := (cAliasQry)->ValFunc

		If lTemCCT 
			(cAliasMain)->CODCCT  := (cAliasQry)->FuncCCT			
		EndIf
		
		If Trim((cAliasQry)->TIPO) == "PS"
			(cAliasMain)->CODPLAN := (cAliasQry)->CodBen2
			(cAliasMain)->CODFORN := (cAliasQry)->CodDes
			(cAliasMain)->TPPLAN := (cAliasQry)->CodBen
			(cAliasMain)->TPFORN := (cAliasQry)->TpBen
		EndIf
		
		(cAliasMain)->(MsUnlock())
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	If lTemCCT .and. nOrdem == 2
		DEFINE BREAK oBreakCCT OF oSecFunc WHEN {|| aFunc[1][4] } 	TITLE OemToAnsi("Total Conv. Colet. Trab.")
		DEFINE FUNCTION NAME "CCTCAL"    FROM oSecBen:Cell("VALCAL") FUNCTION SUM BREAK oBreakCCT NO END SECTION NO END REPORT TITLE OemToAnsi(STR0043) PICTURE GetSx3Cache( "R0_VALCAL" , "X3_PICTURE" )
		DEFINE FUNCTION NAME "CCTFUN"    FROM oSecBen:Cell("VLRFUNC") FUNCTION SUM BREAK oBreakCCT NO END SECTION NO END REPORT TITLE OemToAnsi(STR0044) PICTURE GetSx3Cache( "R0_VLRFUNC" , "X3_PICTURE" )
		DEFINE FUNCTION NAME "CCTEMP"    FROM oSecBen:Cell("VLREMP") FUNCTION SUM BREAK oBreakCCT NO END SECTION NO END REPORT TITLE OemToAnsi(STR0045) PICTURE GetSx3Cache( "R0_VLREMP" , "X3_PICTURE" )
	EndIf

	//Impress„o do relatÛrio
	
	//Define o total da regua da tela de processamento do relatorio
	oReport:SetMeter(200)
	
	oSecFunc:Init()
	oSecBen:Init()
	oSecDep:Init()
	oSecAgr:Init()
	
	DbSelectArea(cAliasMain)
	
	(cAliasMain)->(DbSetOrder(1))
	(cAliasMain)->(DbGoTop())
	
	lXlsTable := oReport:lXlsTable

	While !((cAliasMain)->(Eof()))
		aBen := {}
		aFuncAux := aFunc
		aFunc := {}

		//Movimenta Regua Processamento
		oReport:IncMeter(1)
		
		//Cancela Impressao
		If oReport:Cancel()
			Exit
		EndIf

		If oReport:nDevice <> 4
			If lTemCCT
				Aadd( aFunc, { (cAliasMain)->RA_FILIAL, (cAliasMain)->RA_MAT, (cAliasMain)->RA_NOME, (cAliasMain)->CODCCT } )
			Else
				Aadd( aFunc, { (cAliasMain)->RA_FILIAL, (cAliasMain)->RA_MAT, (cAliasMain)->RA_NOME } )
			EndIf
		else
			If Len(aFuncAux) == 0 .Or. ((cAliasMain)->RA_FILIAL+(cAliasMain)->RA_MAT ) <> (aFuncAux[1][1] + aFuncAux[1][2] )
				If lTemCCT
					Aadd( aFunc, { (cAliasMain)->RA_FILIAL, (cAliasMain)->RA_MAT, (cAliasMain)->RA_NOME, (cAliasMain)->CODCCT } )
				Else
					Aadd( aFunc, { (cAliasMain)->RA_FILIAL, (cAliasMain)->RA_MAT, (cAliasMain)->RA_NOME } )
				EndIf
			Else
				aFunc := aFuncAux	
			Endif	
		Endif		
		
		If !(aFunc[1][1] + aFunc[1][2] $ cFuncAux) .Or. oReport:nDevice == 4
			oSecFunc:PrintLine()
			cFuncAux += aFunc[1][1] + aFunc[1][2] + "/"
		EndIf
		
		Aadd( aBen, { (cAliasMain)->TIPOBEN, (cAliasMain)->CODBEN, (cAliasMain)->DESCBEN, (cAliasMain)->DESCBEN2, (cAliasMain)->VALCAL, (cAliasMain)->VALFUNC, (cAliasMain)->VALEMP } )
		
		If lXlsTable
			oSecBen:EvalCell()
		EndIf

		If Trim((cAliasMain)->TIPOBEN) == "PS"
			If Trim((cAliasMain)->OrigemPLA) == "1"
				oSecBen:PrintLine()
			ElseIf Trim((cAliasMain)->OrigemPLA) == "2"
				Aadd( aDep, { (cAliasMain)->RA_NOME, (cAliasMain)->CODPLAN, (cAliasMain)->DESCBEN, (cAliasMain)->DESCBEN2, (cAliasMain)->VALCAL, (cAliasMain)->VALFUNC, (cAliasMain)->VALEMP } )
				oSecDep:PrintLine()
				aDep := {}
			Else
				Aadd( aDep, { (cAliasMain)->RA_NOME, (cAliasMain)->CODPLAN, (cAliasMain)->DESCBEN, (cAliasMain)->DESCBEN2, (cAliasMain)->VALCAL, (cAliasMain)->VALFUNC, (cAliasMain)->VALEMP } )
				oSecAgr:PrintLine()
				aDep := {}
			EndIf
			
		Else
			oSecBen:PrintLine()
		EndIf
			
		(cAliasMain)->(DbSkip())
	EndDo

	oSecFunc:Finish()

	// Caso seja formato tabela na lÛgica atual n„o È necess·rio realizar um finish
	If !lXlsTable
		oSecBen:Finish()
		oSecDep:Finish()
		oSecAgr:Finish()
	EndIf
	
	(cAliasMain)->(DbCloseArea())
	RestArea(aArea)
	 
Return NIL

/*/{Protheus.doc}fPergVld
Carrega os par‚metros 14 e 15 de acordo com o valor do 13
@author Gabriel de Souza Almeida
@version P12
@param nPar, numÈrico, valor do par‚metro
@return lRet, lÛgico
/*/
Function fPergVld(nPar)
	Local lRet := .T.
	
	If MV_PAR13 == 2 .AND. (MV_PAR14 == 1 .OR. MV_PAR15 == 1)
		//"Os par‚metros 'Plano de Sa˙de Depend.' e 'Plano de Sa˙de Agreg.' tambÈm ser„o alterados para 'N„o'."
		Help( , , 'HELP', , OemToAnsi(STR0042), 1, 0)
		MV_PAR14 := 2
		MV_PAR15 := 2
	EndIf
Return lRet

/*/{Protheus.doc} fPerAbert
Verifica se o perÌodo È ativo
@author Gabriel de Souza Almeida
@version P12
@param cPer, caracter, perÌodo
@param cRot, caracter, roteiro
@return lÛgico, lRet, .T. quando o periodo est· ativo
/*/
Function fPerAbert(cPer,cRot)
	Local lRet := .T.
	Local aPerAbert := {}
	Local nAux := 0
	
	fRetPerComp(Substr(cPer,5,2),Substr(cPer,1,4),,MV_PAR01,cRot,@aPerAbert)
	
	If Len(aPerAbert)>0 .AND. Len(aPerAbert[1])>1
		For nAux := 1 To Len(aPerAbert)
			lRet := (cPer == aPerAbert[nAux][1])
			If lRet
				Exit
			EndIf
		Next
	Else
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc}fTableJoin
Join de tabelas
@author Gabriel de Souza Almeida
@since 07/05/2015
@version P12
@param cTabela1, caractere, Primeira tabela do relacionamento
@param cTabela2, caractere, Segunda tabela do relacionamento
@param [cEmbedded], caractere, Simbolo para abertura/fechamento do Embedded
@return caractere, Comando SUBTRING tratado
/*/
Static Function fTableJoin(cTabela1, cTabela2,cEmbedded)

	Local cFiltJoin := ""
	Local cNameDB	  := ""
	Default cEmbedded := ""
	
	cFiltJoin := cEmbedded + FWJoinFilial(cTabela1, cTabela2) + cEmbedded	
	
	If ( cNameDB $ 'DB2|ORACLE|POSTGRES|INFORMIX' )
		cFiltJoin := STRTRAN(cFiltJoin, "SUBSTRING", "SUBSTR")
	EndIf
	
Return (cFiltJoin)


/*/{Protheus.doc} VldStrQry
//TODO DescriÁ„o auto-gerada.
@author joao.balbino
@since 05/05/2017
@version P12
@param cString, characters, String da query
@param cNewString, characters, Nova String quebrando a query
@type function
/*/
Static Function VldStrQry(cString,cNewString)

Local nTamStr := Len(cString) 

If nTamStr > 899
	cNewString := SubStr(cString,900,nTamStr)
	cString := SubStr(cString,1,899) 
EndIf

Return

/*/{Protheus.doc} fChkCCT
//Verifica se a pergunta e campos da CCT existem
@author Leandro Drumond
@since 13/06/2022
/*/
Static Function fChkCCT()
Local lRet 		:= .F.
Local oSX1

If SR0->(ColumnPos("R0_CODCCT")) > 0
	//Verifica se existe a pergunta GPCR14
	oSX1 := FWSX1Util():New()
	oSX1:AddGroup("GPER011")
	oSX1:SearchGroup()
	
	If (Len(oSX1:aGrupo) >= 1 .And. Len(oSX1:aGrupo[1][2]) >= 16)
		lRet := .T.
	EndIf

	FreeObj(oSX1)
EndIf

Return lRet
