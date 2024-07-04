#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER241.CH"

/*/{Protheus.doc}GPER241()
- Relatório de conferência GPS.
@Type Function
@author:	Jônatas Alves	
@since:		22/05/2017
@param:
@version 1.0
@return
/*/
Function GPER241()

	Local oReport
	
	Local aArea := GetArea()
	
	Private cPerg		:= "GPR241"
	Private cAliasTbl	:= GetNextAlias()
	Private cAliasFil	:= GetNextAlias()
	Private cAliasCC	:= GetNextAlias()
	Private cAliasFun	:= GetNextAlias()
	Private cImpTpCtr	:= ""
	
	Private aParTab		:= {}
	
	Private oTmpTbl
	Private oBreakPar
	Private oBreakFil
	Private oBreakCc
	Private oBreakFun
	Private oBreakLct
	
	Private lOnBrkCC	:= .F.
	Private lDicInter		:= FindFunction("fChkInterm") .And. fChkInterm()	
	//------------------------------------
	// Verifica as perguntas selecionadas
	//------------------------------------
	Pergunte( "GPR241", .F. )
	oReport := ReportDef()
	oReport:PrintDialog()
	
	If Select( cAliasTbl ) > 0
		( cAliasTbl )->( dbCloseArea() )
	EndIf
	
	If Select( cAliasFil ) > 0
		( cAliasFil )->( dbCloseArea() )
	EndIf
	
	If Select( cAliasCC ) > 0
		( cAliasCC )->( dbCloseArea() )
	EndIf
	
	If Select( cAliasFun ) > 0
		( cAliasFun )->( dbCloseArea() )
	EndIf
	
	If oTmpTbl <> Nil
		oTmpTbl:Delete()
		oTmpTbl := Nil
	Endif
	
	RestArea( aArea )
Return

/*/{Protheus.doc}ReportDef()
- Definição do componente de impressão do relatório
@Type Static Function
@author:	Jônatas Alves	
@since:		22/05/2017
@param:
@version 1.0
@return
/*/
Static Function ReportDef()

	Local oReport
	Local oSecParm
	Local oSecTb35
	Local oSecTb37
	Local oSecTb38
	Local oSecFil
	Local oSecCc
	Local oSecFun
	Local oSecLct
	
	Local cSalCAte	:= "0013*0019"
	Local cSalCAci	:= "0014*0020"
	Local cAutPro	:= "0221"
	Local cAutProV 	:= "0225*0350*0353"
	Local cValINSS	:= "0064*0065*0070*0351*0354*0340*0401"
	Local cEmpresa	:= "0148*0943"
	Local cAcident	:= "0150*0945"
	Local cTerceir	:= "0149*0184*0185*0186*0187*0188*0189*0190*0191*0192*0193*0200*0201*0204*0782*0944*0437*1456"
	Local cMatern	:= "0670*0040*0407*1338*1339*1340*1341*1423"
	Local cSalFam	:= "0034"
	Local cDevoluc	:= "1412"
	Local cDissid 	:= "0338*0399"
	
	Private aOrd		:={}
	
	Aadd( aOrd, OemToAnsi( STR0003 ) + " + " + OemToAnsi( STR0004 ) + " + " + OemToAnsi( STR0005 ) + " + " + OemToAnsi( STR0006 ) )  //1  - "Filial + C. Custo + Tp. Contr. + Matrícula"
	
	oReport := TReport():New( "GPER241", STR0001, "GPR241", { | oReport | PrintReport( oReport ) }, STR0002 )	//"Relatório de conferência GPS"#"Relatório que detalha parâmetros, tabelas e valores utilizados para composição da GPS - Guia da Previdência Social."
	
	oReport:SetTotalInLine( .F. )
	
	//--------------------------------------
	// Criação da Primeira Seção: Parâmetros
	//--------------------------------------
	oSecParm := TRSection():New( oReport, OemToAnsi( "Parâmetros da GPS" ), { ( cAliasTbl ) }, aOrd )	
	oSecParm:SetTotalInLine( .F. )
	oSecParm:SetHeaderBreak( .F. )
	oSecParm:ShowHeader( .T. )
	
	// SX6
	TRCell():New( oSecParm, "X6COD",	( cAliasTbl ), "Parametro", "@!", 10, , , , , , , , .T. )
	TRCell():New( oSecParm, "X6DESC",	( cAliasTbl ), "Descriçao", "@!", , , , , , , , , .T. )
	TRCell():New( oSecParm, "X6CONT",	( cAliasTbl ), "Conteúdo", "@!", 8, , , , , , , , .T. )
	
	oSecParm:OnPrintLine( { || AllTrim( ( cAliasTbl )->TIPO ) == "PAR" } )
	
	oSecParm:Cell( "X6COD" ):Disable()
	
	oSecParm:SetDynamicKey( OemToAnsi( "Parâmetros GPS" ) )

	//--------------------------------------
	// Criação da Segunda Seção: Tabela S035
	//--------------------------------------
	oSecTb35 := TRSection():New( oReport, OemToAnsi( "S035 - Complemento GPS" ), { ( cAliasTbl ) },,,,,,,,,,,,,,,2 )	
	oSecTb35:SetTotalInLine( .F. )
	oSecTb35:SetHeaderBreak( .F. )
	oSecTb35:ShowHeader( .T. )
	
	// S035
	TRCell():New( oSecTb35, "FILPROC",		( cAliasTbl ), OemToAnsi( STR0003 ), "@!", 8, , , , , , , , .T. )
	TRCell():New( oSecTb35, "CDECUSTO",		( cAliasTbl ), OemToAnsi( STR0004 ), "@!", 20, , , , , , , , .T. )
	TRCell():New( oSecTb35, "VERBA",		( cAliasTbl ), OemToAnsi( STR0016 ), "@!", 3, , , , , , , , .T. )
	TRCell():New( oSecTb35, "BASE",			( cAliasTbl ), "Base", "@E 999,999,999.99", 12, , , , , , , , .T. )
	TRCell():New( oSecTb35, "PERCENTUAL",	( cAliasTbl ), "Percentual", "@E 9,999.99", 7, , , , , , , , .T. )
	TRCell():New( oSecTb35, "VALOR",		( cAliasTbl ), "Valor", "@E 999,999,999.99", 12, , , , , , , , .T. )
	TRCell():New( oSecTb35, "RECDED",		( cAliasTbl ), "Rec./Ded.", "@!", 1, , , , , , , , .T. )
	TRCell():New( oSecTb35, "OBSERVACAO",	( cAliasTbl ), "Observaçao", "@!", 30, , , , , , , , .T. )
	//TRCell():New( oSecTb35, "TPCONTR",		( cAliasTbl ), "Tp. Contrato", "9", 1, , , , , , , , .T. )
	TRCell():New( oSecTb35, "CMPINI",		( cAliasTbl ), "Ano/Mes Comp.Ini", "9999/99", 6, , , , , , , , .T. )
	TRCell():New( oSecTb35, "CMPFIM",		( cAliasTbl ), "Ano/Mes Comp.Fim", "9999/99", 6, , , , , , , , .T. )
	
	oSecTb35:OnPrintLine( { || ( cAliasTbl )->TIPO == "S035" } )
	
	oSecTb35:SetDynamicKey( OemToAnsi( "Tabelas GPS S035" ) )

	//---------------------------------------
	// Criação da Terceira Seção: Tabela S037
	//---------------------------------------
	oSecTb37 := TRSection():New( oReport, OemToAnsi( "S037 - Encargos Empresa" ), { ( cAliasTbl ) },,,,,,,,,,,,,,,2 )	
	oSecTb37:SetTotalInLine( .F. )
	oSecTb37:SetHeaderBreak( .F. )
	oSecTb37:ShowHeader( .T. )
	
	TRCell():New( oSecTb37, "FILPROC",	( cAliasTbl ), OemToAnsi( STR0003 ), "@!", 8, , , , , , , , .T. )
	TRCell():New( oSecTb37, "TPCONTR",	( cAliasTbl ), "Tp. Contrato", "9", 1, , , , , , , , .T. )
	// S037
	TRCell():New( oSecTb37, "EMPRESA",	( cAliasTbl ), "% Empresa", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb37, "ACIDTRB",	( cAliasTbl ), "% Acid.Trab.", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb37, "RAT",		( cAliasTbl ), "% Rat", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb37, "FGTS",		( cAliasTbl ), "% FGTS", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb37, "RECFATUR",	( cAliasTbl ), "% Recolhe S/ Fatur.", "9", 1, , , , , , , , .T. )
	TRCell():New( oSecTb37, "CDPTOGPS",	( cAliasTbl ), "Cod. Pagto GPS", "9999", 4, , , , , , , , .T. )
	TRCell():New( oSecTb37, "VLRMINGP",	( cAliasTbl ), "Vlr.Min. GPS", "@E 999,999.99", 10, , , , , , , , .T. )
	
	oSecTb37:OnPrintLine( { || ( cAliasTbl )->TIPO == "S037" } ) 	

	oSecTb37:SetDynamicKey( OemToAnsi( "Tabelas GPS S037" ) )
	
	//-------------------------------------
	// Criação da Quarta Seção: Tabela S038
	//-------------------------------------
	oSecTb38 := TRSection():New( oReport, OemToAnsi( "S038 - Outras Entidades" ), ( cAliasTbl ),,,,,,,,,,,,,,,2 )	
	oSecTb38:SetTotalInLine( .F. )
	oSecTb38:SetHeaderBreak( .F. )
	oSecTb38:ShowHeader( .T. )
	
	TRCell():New( oSecTb38, "FILPROC",	( cAliasTbl ), OemToAnsi( STR0003 ), "@!", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "TPCONTR",	( cAliasTbl ), "Tp. Contrato", "9", 1, , , , , , , , .T. )
	// S038
	TRCell():New( oSecTb38, "CODTERC",	( cAliasTbl ), "Cod.Terceiros", "@!", 4, , , , , , , , .T. )
	TRCell():New( oSecTb38, "TERCEIRO",	( cAliasTbl ), "% Terceiros", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "SALEDU",	( cAliasTbl ), "% Sal. Educacao", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "INCRA",	( cAliasTbl ), "% INCRA", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "SENAI",	( cAliasTbl ), "% SENAI", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "SESI",		( cAliasTbl ), "% SESI", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "SENAC",	( cAliasTbl ), "% SENAC", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "SESC",		( cAliasTbl ), "% SESC", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "SEBRAE",	( cAliasTbl ), "% SEBRAE", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "DPC",		( cAliasTbl ), "% DPC", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "FAER",		( cAliasTbl ), "% FAER", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "SENAR",	( cAliasTbl ), "% SENAR", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "SECONC",	( cAliasTbl ), "% SECONC", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "SEST",		( cAliasTbl ), "% SEST", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "SENAT",	( cAliasTbl ), "% SENAT", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "SESCOOP",	( cAliasTbl ), "% SESCOOP", "@E 999.9999", 8, , , , , , , , .T. )
	TRCell():New( oSecTb38, "SENAI5",	( cAliasTbl ), "% Adic.SENAI", "@E 999.9999", 8, , , , , , , , .T. )
	
	oSecTb38:OnPrintLine( { || ( cAliasTbl )->TIPO == "S038" } ) 	

	oSecTb38:SetDynamicKey( OemToAnsi( "Tabelas GPS S038" ) )

	//--------------------------------
	// Criação da Quinta Seção: Filial
	//----------------------------------
	oSecFil := TRSection():New( oReport, OemToAnsi( STR0010 ), { ( cAliasFun ) } )	
	oSecFil:SetTotalInLine( .F. )
	oSecFil:SetHeaderBreak( .F. )
	oSecFil:ShowHeader( .T. )
	
	TRCell():New( oSecFil, "RC_FILIAL", ( cAliasFun ) )
	
	oBreakFil := TRBreak():New( oSecFil, { || cImpTpCtr := "", lOnBrkCC := .F., ( cAliasFun )->RC_FILIAL } ) 	

	oSecFil:SetDynamicKey( OemToAnsi( STR0003 ) )
	
	//---------------------------------
	// Criação da Sexta Seção: C. Custo
	//---------------------------------
	oSecCc := TRSection():New( oSecFil, OemToAnsi( STR0011 ), { ( cAliasFun ) } )
	oSecCc:SetTotalInLine( .F. )
	oSecCc:SetHeaderBreak( .F. )
	oSecCc:ShowHeader( .T. )
	oSecCc:SetLeftMargin( 2 )      
	
	TRCell():New( oSecCc, "RC_FILIAL", ( cAliasFun ) )
	TRCell():New( oSecCc, "RC_CC", ( cAliasFun ) )
	TRCell():New( oSecCc, "CTT_DESC01", ( cAliasFun ), OemToAnsi( STR0013 ) )
	
	oBreakCc := TRBreak():New( oSecCc, { || cImpTpCtr := "", ( cAliasFun )->( RC_FILIAL + RC_CC ) }  ) 	
	
	oSecCc:SetDynamicKey( OemToAnsi( STR0004 ) )
	
	//-------------------------------------
	// Criação da Sétima Seção: Funcionário
	//-------------------------------------
	oSecFun := TRSection():New( oSecCc, OemToAnsi( STR0014 ), { ( cAliasFun ) } )	
	oSecFun:SetTotalInLine( .F. )
	oSecFun:SetHeaderBreak( .F. )
	oSecFun:ShowHeader( .T. )
	oSecFun:SetLeftMargin( 4 )      
	
	TRCell():New( oSecFun, "RC_FILIAL", ( cAliasFun ) )
	TRCell():New( oSecFun, "RC_CC", ( cAliasFun ) )
	TRCell():New( oSecFun, "CTT_DESC01", ( cAliasFun ), OemToAnsi( STR0013 ) )
	TRCell():New( oSecFun, "RC_MAT", ( cAliasFun ) )
	TRCell():New( oSecFun, "RA_NOME", ( cAliasFun ) )
	TRCell():New( oSecFun, "RA_TPCONTR", ( cAliasFun ) )
	
	oBreakFun := TRBreak():New( oSecFun, { || cImpTpCtr := "", ( cAliasFun )->( RC_FILIAL + RC_CC + RC_MAT ) } ) 	
	
	//oSecFun:Cell( "RC_FILIAL" ):Disable()
	//oSecFun:Cell( "RC_CC" ):Disable()
	//oSecFun:Cell( "CTT_DESC01" ):Disable()
	
	oSecFun:SetDynamicKey( OemToAnsi( STR0006 ) )
	
	//-------------------------------------
	// Criação da Oitava Seção: Lançamentos
	//-------------------------------------
	oSecLct := TRSection():New( oSecFun, OemToAnsi( STR0012 ), { ( cAliasFun ) } )	
	oSecLct:SetTotalInLine( .F. )
	oSecLct:SetHeaderBreak( .F. )
	oSecLct:ShowHeader( .T. )
	oSecLct:SetLeftMargin( 4 )
	
	TRCell():New( oSecLct, "RC_FILIAL", ( cAliasFun ) )
	TRCell():New( oSecLct, "RC_CC", ( cAliasFun ) )
	TRCell():New( oSecLct, "RC_MAT", ( cAliasFun ) )
	TRCell():New( oSecLct, "RA_TPCONTR", ( cAliasFun ), , , , , { || fImpTpCtr() } )
	TRCell():New( oSecLct, "RC_PD", ( cAliasFun ), OemToAnsi( STR0016 ) )
	TRCell():New( oSecLct, "RV_DESC", ( cAliasFun ), OemToAnsi( STR0017 ) )
	TRCell():New( oSecLct, "SALCOATE", ( cAliasFun ), OemToAnsi( STR0018 ), "@E 999,999,999.99", , , { || ( cAliasFun )->( If( RV_CODFOL $ cSalCAte, RC_VALOR, 0 ) ) }, , , , , , .T. )
	TRCell():New( oSecLct, "SALCOACI", ( cAliasFun ), OemToAnsi( STR0019 ), "@E 999,999,999.99", , , { || ( cAliasFun )->( If( RV_CODFOL $ cSalCAci, RC_VALOR, 0 ) ) }, , , , , , .T. )
	TRCell():New( oSecLct, "AUTPRO", ( cAliasFun ), OemToAnsi( STR0020 ), "@E 999,999,999.99", , , { || ( cAliasFun )->( If( RV_CODFOL $ cAutPro, RC_VALOR, 0 ) ) }, , , , , , .T. )
	TRCell():New( oSecLct, "AUTPROVI", ( cAliasFun ), OemToAnsi( STR0021 ), "@E 999,999,999.99", , , { || ( cAliasFun )->( If( RV_CODFOL $ cAutProV, RC_VALOR, 0 ) ) }, , , , , , .T. )
	TRCell():New( oSecLct, "VALINSS", ( cAliasFun ), OemToAnsi( STR0022 ), "@E 999,999,999.99", , , { || ( cAliasFun )->( If( RV_CODFOL $ cValINSS, RC_VALOR, 0 ) ) }, , , , , , .T. ) 
	TRCell():New( oSecLct, "EMPRESA", ( cAliasFun ), OemToAnsi( STR0023 ), "@E 999,999,999.99", , , { || ( cAliasFun )->( If( RV_CODFOL $ cEmpresa, RC_VALOR, 0 ) ) }, , , , , , .T. )
	TRCell():New( oSecLct, "ACIDENTE", ( cAliasFun ), OemToAnsi( STR0024 ), "@E 999,999,999.99", , , { || ( cAliasFun )->( If( RV_CODFOL $ cAcident, RC_VALOR, 0 ) ) }, , , , , , .T. )
	TRCell():New( oSecLct, "TERCEIRO", ( cAliasFun ), OemToAnsi( STR0025 ), "@E 999,999,999.99", , , { || ( cAliasFun )->( If( RV_CODFOL $ cTerceir, RC_VALOR, 0 ) ) }, , , , , , .T. )
	TRCell():New( oSecLct, "MATERN", ( cAliasFun ), OemToAnsi( STR0026 ), "@E 999,999,999.99", , , { || ( cAliasFun )->( If( RV_CODFOL $ cMatern, RC_VALOR, 0 ) ) }, , , , , , .T. )
	TRCell():New( oSecLct, "SALFAM", ( cAliasFun ), OemToAnsi( STR0027 ), "@E 999,999,999.99", , , { || ( cAliasFun )->( If( RV_CODFOL $ cSalFam, RC_VALOR, 0 ) ) }, , , , , , .T. )
	TRCell():New( oSecLct, "DEVOLUC", ( cAliasFun ), OemToAnsi( STR0028 ), "@E 999,999,999.99", , , { || ( cAliasFun )->( If( RV_CODFOL $ cDevoluc, RC_VALOR, 0 ) ) }, , , , , , .T. )
	TRCell():New( oSecLct, "DISSIDIO", ( cAliasFun ), OemToAnsi( STR0029 ), "@E 999,999,999.99", , , { || ( cAliasFun )->( If( RV_CODFOL $ cDissid, RC_VALOR, 0 ) ) }, , , , , , .T. )
	
	oBreakLct := TRBreak():New( oSecLct, { || ( cAliasFun )->( RC_FILIAL + RC_CC + RC_MAT + RC_PD ) }, , .T. ) 	
	oBreakLct:SetPageBreak( .F. )

	oSecLct:Cell( "RC_FILIAL" ):Disable()
	oSecLct:Cell( "RC_CC" ):Disable()
	oSecLct:Cell( "RC_MAT" ):Disable()
	
	oSecLct:SetDynamicKey( OemToAnsi( STR0012 ) )

Return oReport          

/*/{Protheus.doc}PrintReport( oReport )
- Impressão do relatório
@Type Static Function
@author:	Jônatas Alves	
@since:		22/05/2017
@param: oReport, Objeto da classe TReport() 
@version 1.0
@return
/*/
Static Function PrintReport( oReport )

	Local cRot13o	:= ""
	Local aRot213	:= fGetRotTipo("6")
	Local nRot213	:= 0

	Local oSecParm	:= oReport:Section( 1 )
	Local oSecTb35	:= oReport:Section( 2 )
	Local oSecTb37	:= oReport:Section( 3 )
	Local oSecTb38	:= oReport:Section( 4 )
	Local oSecFil	:= oReport:Section( 5 )
	Local oSecCc	:= oReport:Section( 5 ):Section( 1 )
	Local oSecFun	:= oReport:Section( 5 ):Section( 1 ):Section( 1 )
	Local oSecLct	:= oReport:Section( 5 ):Section( 1 ):Section( 1 ):Section( 1 )

	Private aPerAb		:= {}
	Private aPerFec		:= {}
	
	Private cPeriodo	:= ""
	Private cNameDB		:= Upper( TcGetDb() )
	
	cFilPar		:= MV_PAR01 //"Filial ?"
	cCcPar		:= MV_PAR02 //"Centro de Custo ?"
	nOrdImp		:= MV_PAR03 //"Imprime Por ?"
	nTpMov		:= MV_PAR04 //"Tipo ?"
	cMesAno		:= MV_PAR05 //"Mes/Ano Competencia ?"
	cTpCtr		:= MV_PAR06 //"Qual Tipo Contrato ?"
	nImpTot		:= MV_PAR07 //"Imprime Totais ?"
	nApenTot	:= MV_PAR08 //"Apenas Totais ?"
	nQuebCc		:= MV_PAR09 //"C. Custo Outra Pag. ?"
	nQuebFil	:= MV_PAR10 //"Filial Outra Pag. ?"
	cNivCCusto	:= "" 		//"Filial Outra Pag. ?"
	
	If lDicInter
		cTpCtr := Alltrim(Replace(cTpCtr,"*",""))
	EndIf
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	
	If SX1->( dbSeek( "GPR241    " + "11" ) )
		cNivCCusto	:= MV_PAR11 //"Filial Outra Pag. ?"
	Else
		If nOrdImp == 2
			nOrdImp := 1
		EndIf
	EndIf
	
	lImpTot		:= ( nImpTot == 1 )
	lApenTot	:= ( nApenTot == 1 )
	lQuebCc		:= ( nQuebCc == 1 )
	lQuebFil	:= ( nQuebFil == 1 )
	
	cPeriodo 	:= Right( cMesAno, 4 ) + Left( cMesAno, 2 )
	
	//---------------------------------------------
	// Transforma parametros Range em expressao SQL
	//---------------------------------------------
	MakeSqlExpr( cPerg )
	
	cFilSQL	:= MV_PAR01 //"Filial ?"
	cCcSQL	:= MV_PAR02 //"Centro de Custo ?"
	
	//------------------------------------
	// Valida períodos a serem processados
	//------------------------------------
	fRetPerComp( Left( MV_PAR05, 2 ), Right( MV_PAR05, 4 ), Nil, Nil, Nil, @aPerAb, @aPerFec )
	
	If Len( aPerAb ) == 0 .And. Len( aPerFec ) == 0
		Return .F.
	Endif

	For nRot213 := 1 To Len(aRot213)
		cRot13o  += aRot213[nRot213]
	Next nRot213
	
	//-----------------------------------
	// Carrega Tabelas(S035 e S037) e SX6
	//-----------------------------------
	fTabGPS( cRot13o )
	
	oBreakCc:OnPrintTotal( { || lOnBrkCC := lQuebCc } )
	
	If nOrdImp == 1 .Or. nOrdImp == 2
		cTipQry := "CC"
		
		oSecFil:SetPageBreak( lQuebFil )
		
		oSecCc:SetPageBreak( lOnBrkCC .And. lQuebCc )

		oSecFun:Cell( "RC_MAT" ):Disable()
		oSecFun:Cell( "RA_NOME" ):Disable()
		oSecFun:Cell( "RA_TPCONTR" ):Disable()
		
		oBreakFun:SetBreak( { || ( cAliasFun )->( RC_FILIAL + RC_CC ) } )

		oSecLct:Cell( "RC_MAT" ):Disable()
		oSecLct:SetTotalText( { || OemToAnsi( STR0031 ) } )
		
		oBreakLct:SetBreak( { || ( cAliasFun )->( RC_FILIAL + RC_CC + RC_PD ) } )
	ElseIf nOrdImp == 3
		cTipQry := "FIL"
		
		oSecFil:SetPageBreak( lQuebFil )

		oSecCc:Cell( "RC_CC" ):Disable()
		oSecCc:Cell( "CTT_DESC01" ):Disable()
		
		oBreakCc:SetBreak( { || ( cAliasFun )->( RC_FILIAL ) } )

		oSecFun:Cell( "RC_CC" ):Disable()
		oSecFun:Cell( "CTT_DESC01" ):Disable()
		oSecFun:Cell( "RC_MAT" ):Disable()
		oSecFun:Cell( "RA_NOME" ):Disable()
		oSecFun:Cell( "RA_TPCONTR" ):Disable()
		
		oBreakFun:SetBreak( { || ( cAliasFun )->( RC_FILIAL ) } )

		oSecLct:Cell( "RC_MAT" ):Disable()
		oSecLct:SetTotalText( { || OemToAnsi( STR0032 ) } )
		
		oBreakLct:SetBreak( { || ( cAliasFun )->( RC_FILIAL + RC_PD ) } )
	Else
		cTipQry := "FUN"
		
		oSecFil:SetPageBreak( lQuebFil )
		
		oSecCc:SetPageBreak( lOnBrkCC .And. lQuebCc )
		
		oSecLct:SetTotalText( { || OemToAnsi( STR0030 ) } )
	EndIf
	
	If lApenTot .Or. lImpTot
		TRFunction():New( oSecLct:Cell( "SALCOATE" ), /*cId*/,"SUM", /*oBreak*/, OemToAnsi( STR0018 ), "@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New( oSecLct:Cell( "SALCOACI" ), /*cId*/,"SUM", /*oBreak*/, OemToAnsi( STR0019 ), "@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New( oSecLct:Cell( "AUTPRO" ), /*cId*/,"SUM", /*oBreak*/, OemToAnsi( STR0020 ), "@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New( oSecLct:Cell( "AUTPROVI" ), /*cId*/,"SUM", /*oBreak*/, OemToAnsi( STR0021 ), "@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New( oSecLct:Cell( "VALINSS" ), /*cId*/,"SUM", /*oBreak*/, OemToAnsi( STR0022 ), "@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New( oSecLct:Cell( "EMPRESA" ), /*cId*/,"SUM", /*oBreak*/, OemToAnsi( STR0023 ), "@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New( oSecLct:Cell( "ACIDENTE" ), /*cId*/,"SUM", /*oBreak*/, OemToAnsi( STR0024 ), "@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New( oSecLct:Cell( "TERCEIRO" ), /*cId*/,"SUM", /*oBreak*/, OemToAnsi( STR0025 ), "@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New( oSecLct:Cell( "MATERN" ), /*cId*/,"SUM", /*oBreak*/, OemToAnsi( STR0026 ), "@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New( oSecLct:Cell( "SALFAM" ), /*cId*/,"SUM", /*oBreak*/, OemToAnsi( STR0027 ), "@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New( oSecLct:Cell( "DEVOLUC" ), /*cId*/,"SUM", /*oBreak*/, OemToAnsi( STR0028 ), "@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New( oSecLct:Cell( "DISSIDIO" ), /*cId*/,"SUM", /*oBreak*/, OemToAnsi( STR0029 ), "@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	EndIf
	
	If lApenTot	
		oSecLct:Hide()
	EndIf
	
	//------------------------
	// Executa Query Principal 
	//------------------------
	oSecFil:BeginQuery() 
	fQryMov( cRot13o, cTipQry )
	oSecFil:EndQuery()
	
	oSecParm:Cell( "X6COD" ):Disable()
	
	If nOrdImp == 1 .Or. nOrdImp == 2
		oSecCc:SetParentQuery()
		oSecCc:SetParentFilter( { | cParam | RC_FILIAL == cParam }, { || ( cAliasFun )->RC_FILIAL } )
		
		oSecFun:SetParentQuery()
		oSecFun:SetParentFilter( { | cParam | RC_FILIAL + RC_CC == cParam }, { || ( cAliasFun )->( RC_FILIAL + RC_CC ) } )
		oSecFun:Hide()
		
		oSecLct:SetParentQuery()
		oSecLct:SetParentFilter( { | cParam | RC_FILIAL + RC_CC == cParam }, { || ( cAliasFun )->( RC_FILIAL + RC_CC ) } )
	ElseIf nOrdImp == 3
		oSecCc:SetParentQuery()
		oSecCc:SetParentFilter( { | cParam | RC_FILIAL == cParam }, { || ( cAliasFun )->RC_FILIAL } )
		oSecCc:Hide()
		
		oSecFun:SetParentQuery()
		oSecFun:SetParentFilter( { | cParam | RC_FILIAL == cParam }, { || ( cAliasFun )->( RC_FILIAL ) } )
		oSecFun:Hide()
		
		oSecLct:SetParentQuery()
		oSecLct:SetParentFilter( { | cParam | RC_FILIAL == cParam }, { || ( cAliasFun )->( RC_FILIAL ) } )	
	Else
		oSecCc:SetParentQuery()
		oSecCc:SetParentFilter( { | cParam | RC_FILIAL == cParam }, { || ( cAliasFun )->RC_FILIAL } )
		
		oSecFun:SetParentQuery()
		oSecFun:SetParentFilter( { | cParam | RC_FILIAL + RC_CC == cParam }, { || ( cAliasFun )->( RC_FILIAL + RC_CC ) } )
		
		oSecLct:SetParentQuery()
		oSecLct:SetParentFilter( { | cParam | RC_FILIAL + RC_CC + RC_MAT == cParam }, { || ( cAliasFun )->( RC_FILIAL + RC_CC + RC_MAT ) } )
		oSecLct:Cell( "RA_TPCONTR" ):SetTitle( "" )
		oSecLct:Cell( "RA_TPCONTR" ):Hide()
	EndIf
	
	oReport:SetMeter( ( cAliasFun )->( LastRec() ) )
	
	oSecParm:Print()
	oSecTb35:Print()
	oSecTb37:Print()
	oSecTb38:Print()
	oReport:EndPage()
	oReport:StartPage()
	oSecFil:Print()
Return Nil

/*/{Protheus.doc}fQryMov( cRot13o, cTipQry, cAliasQry )
- Monta query dinâmica sobre movimento aberto/fechado e totalizadores
@Type Static Function
@author:	Jônatas Alves	
@since:		22/05/2017
@param: cTipQry, Tipo de query(filial, c.custo, lançamento); cRot13o, Roteiro de 13o.
@version 1.0
@return
/*/
Static Function fQryMov( cRot13o, cTipQry, cAliasQry )

	//-------------------
	//Variáveis uso geral
	//-------------------
	Local cCodFQry	:= ""
	Local cOrder	:= ""
	
	//-------------------
	//Variáveis query SRC
	//-------------------
	Local cFilRCQry	:= ""
	Local cRotRCQry	:= ""
	Local cSelSRC	:= ""
	Local cJnSRCCTT:= ""
	Local cJnSRCSRV	:= ""
	Local cGrpSRC	:= ""
	
	//-------------------
	//Variáveis query SRD
	//-------------------
	Local cFilRDQry	:= ""
	Local cRotRDQry	:= ""
	Local cSelSRD	:= ""
	Local cJnSRDCTT:= ""
	Local cJnSRDSRV	:= ""
	Local cGrpSRD	:= ""
	
	//-------------------
	//Variáveis query RHH
	//-------------------
	Local cFilRHHQry:= ""
	Local cSelRHH	:= ""
	Local cJnRHHCTT	:= ""
	Local cJnRHHSRV	:= ""
	Local cGrpRHH	:= ""
	
	//-------------------
	//Variáveis query SRR
	//-------------------
	Local cFilRRQry	:= ""
	Local cSelSRR	:= ""
	Local cJnSRRCTT	:= ""
	Local cJnSRRSRV	:= ""
	Local cGrpSRR	:= ""
	Local cDataDe	:= Left( cPeriodo, 4 ) + Right( cPeriodo, 2 ) + "01"
	Local cDataAte	:= Left( cPeriodo, 4 ) + Right( cPeriodo, 2 ) + StrZero( f_UltDia( StoD( cDataDe ) ), 2 )
			
	DEFAULT cTipQry		:= "FUN"
	DEFAULT cAliasQry	:= ( cAliasFun )
	
	//--------------
	// Filtra Filial
	//--------------
	If !Empty( cFilSQL ) 
		cFilRCQry	:= "%" + StrTran( cFilSQL, "RA_", "SRC.RC_" ) + "%"
		cFilRDQry	:= "%" + StrTran( cFilSQL, "RA_", "SRD.RD_" ) + "%"
		cFilRHHQry	:= "%" + StrTran( cFilSQL, "RA_", "RHH.RHH_" ) + "%"
		cFilRRQry	:= "%" + StrTran( cFilSQL, "RA_", "SRR.RR_" ) + "%"
	Else
		cFilRCQry 	:= "% '' = '' %"
		cFilRDQry 	:= "% '' = '' %"
		cFilRHHQry 	:= "% '' = '' %"
		cFilRRQry 	:= "% '' = '' %"
	EndIf
	
	//-----------------------
	// Filtra Centro de Custo
	//-----------------------
	If !Empty( cCcSQL ) 
		cCcSRAQry	:= "%" + StrTran( cCcSQL, "RA_", "SRA.RA_" ) + "%"
	Else
		cCcSRAQry	:= "% '' = '' %"
	EndIf
	
	//------------------------------------
	// Filtra roteiro de 13o. na opção "2"
	//------------------------------------
	If nTpMov == 2 
		cRotRCQry :=  "% SRC.RC_ROTEIR IN (" + fSqlIN(cRot13o, 3) + ") %"
		cRotRDQry :=  "% SRD.RD_ROTEIR IN (" + fSqlIN(cRot13o, 3) + ") %"
	Else
		cRotRCQry :=  "% SRC.RC_ROTEIR NOT IN (" + fSqlIN(cRot13o, 3) + ") %"
		cRotRDQry :=  "% SRD.RD_ROTEIR NOT IN (" + fSqlIN(cRot13o, 3) + ") %"
	EndIf
	
	//------------------------
	// Filtra tipo de contrato
	//------------------------
	If lDicInter
		If "1" $ cTpCtr
			cTpcSRAQry	:= "% SRA.RA_TPCONTR IN (" + fSqlIN(cTpCtr, 1) + ", ' ') %"
		Else
			cTpcSRAQry	:= "% SRA.RA_TPCONTR IN (" + fSqlIN(cTpCtr, 1) + ") %"
		EndIf
	Else
		If cTpCtr == "3"
			cTpcSRAQry	:= "% SRA.RA_TPCONTR IN ( '1', '2', ' ' ) %"
		ElseIf cTpCtr == "1"
			cTpcSRAQry	:= "% SRA.RA_TPCONTR IN ( '1', ' ' ) %"
		Else
			cTpcSRAQry	:= "% SRA.RA_TPCONTR = '2' %"
		EndIf
	EndIf
	//------------------------------------------------------
	// Define campos do Select de acordo a seção e movimento
	//------------------------------------------------------	
	If cTipQry == "FIL"
		cSelSRC := "% SRC.RC_FILIAL, 				SRA.RA_TPCONTR, SRC.RC_PD, 				SRV.RV_DESC, SRV.RV_CODFOL, SUM( SRC.RC_VALOR )  AS RC_VALOR,	'SRC' AS TABELA %"
		cSelSRD := "% SRD.RD_FILIAL  AS RC_FILIAL,  SRA.RA_TPCONTR, SRD.RD_PD     AS RC_PD,	SRV.RV_DESC, SRV.RV_CODFOL, SUM( SRD.RD_VALOR )	 AS RC_VALOR,	'SRD' AS TABELA %"
		cSelRHH := "% RHH.RHH_FILIAL AS RC_FILIAL,  SRA.RA_TPCONTR, RHH.RHH_VERBA AS RC_PD,	SRV.RV_DESC, SRV.RV_CODFOL, SUM( RHH.RHH_VALOR ) AS RC_VALOR,	'RHH' AS TABELA %"
		cSelSRR := "% SRR.RR_FILIAL  AS RC_FILIAL,	SRA.RA_TPCONTR, SRR.RR_PD 	  AS RC_PD,	SRV.RV_DESC, SRV.RV_CODFOL, SUM( SRR.RR_VALOR )  AS RC_VALOR,	'SRR' AS TABELA %"
		
		cGrpSRC	:= "% SRC.RC_FILIAL, 	SRA.RA_TPCONTR, SRC.RC_PD, 		SRV.RV_DESC, SRV.RV_CODFOL %"
		cGrpSRD	:= "% SRD.RD_FILIAL, 	SRA.RA_TPCONTR, SRD.RD_PD, 		SRV.RV_DESC, SRV.RV_CODFOL %"
		cGrpRHH	:= "% RHH.RHH_FILIAL,	SRA.RA_TPCONTR, RHH.RHH_VERBA,	SRV.RV_DESC, SRV.RV_CODFOL %"
		cGrpSRR	:= "% SRR.RR_FILIAL, 	SRA.RA_TPCONTR, SRR.RR_PD,		SRV.RV_DESC, SRV.RV_CODFOL %"
		
		cOrder	:= "% 1, 2, 3, 4, 5 %"
	ElseIf cTipQry == "CC"
		If nOrdImp == 2
			If ( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
				cSelSRC := "% SRC.RC_FILIAL,				SUBSTR( SRC.RC_CC, 1, " + cNivCCusto + " ) AS RC_CC, CTT.CTT_DESC01, SRA.RA_TPCONTR, SRC.RC_PD, 			 SRV.RV_DESC, SRV.RV_CODFOL, SUM( SRC.RC_VALOR )  AS RC_VALOR, 'SRC' AS TABELA %"
				cSelSRD := "% SRD.RD_FILIAL	 AS RC_FILIAL,	SUBSTR( SRD.RD_CC, 1, " + cNivCCusto + " ) AS RC_CC, CTT.CTT_DESC01, SRA.RA_TPCONTR, SRD.RD_PD AS RC_PD, 	 SRV.RV_DESC, SRV.RV_CODFOL, SUM( SRD.RD_VALOR )  AS RC_VALOR, 'SRD' AS TABELA %"
				cSelRHH := "% RHH.RHH_FILIAL AS RC_FILIAL,	SUBSTR( RHH.RHH_CC,1, " + cNivCCusto + " ) AS RC_CC, CTT.CTT_DESC01, SRA.RA_TPCONTR, RHH.RHH_VERBA AS RC_PD, SRV.RV_DESC, SRV.RV_CODFOL, SUM( RHH.RHH_VALOR ) AS RC_VALOR, 'RHH' AS TABELA %"
				cSelSRR := "% SRR.RR_FILIAL  AS RC_FILIAL,	SUBSTR( SRR.RR_CC,1,  " + cNivCCusto + " ) AS RC_CC, CTT.CTT_DESC01, SRA.RA_TPCONTR, SRR.RR_PD AS RC_PD,     SRV.RV_DESC, SRV.RV_CODFOL, SUM( SRR.RR_VALOR )  AS RC_VALOR, 'SRR' AS TABELA %"
			Else
				cSelSRC := "% SRC.RC_FILIAL,				SUBSTRING( SRC.RC_CC, 1, " + cNivCCusto + " ) AS RC_CC, CTT.CTT_DESC01, SRA.RA_TPCONTR, SRC.RC_PD, 			 SRV.RV_DESC, SRV.RV_CODFOL, SUM( SRC.RC_VALOR )  AS RC_VALOR, 'SRC' AS TABELA %"
				cSelSRD := "% SRD.RD_FILIAL	 AS RC_FILIAL,	SUBSTRING( SRD.RD_CC, 1, " + cNivCCusto + " ) AS RC_CC, CTT.CTT_DESC01, SRA.RA_TPCONTR, SRD.RD_PD AS RC_PD, 	 SRV.RV_DESC, SRV.RV_CODFOL, SUM( SRD.RD_VALOR )  AS RC_VALOR, 'SRD' AS TABELA %"
				cSelRHH := "% RHH.RHH_FILIAL AS RC_FILIAL,	SUBSTRING( RHH.RHH_CC,1, " + cNivCCusto + " ) AS RC_CC, CTT.CTT_DESC01, SRA.RA_TPCONTR, RHH.RHH_VERBA AS RC_PD, SRV.RV_DESC, SRV.RV_CODFOL, SUM( RHH.RHH_VALOR ) AS RC_VALOR, 'RHH' AS TABELA %"
				cSelSRR := "% SRR.RR_FILIAL  AS RC_FILIAL,	SUBSTRING( SRR.RR_CC,1,  " + cNivCCusto + " ) AS RC_CC, CTT.CTT_DESC01, SRA.RA_TPCONTR, SRR.RR_PD AS RC_PD,     SRV.RV_DESC, SRV.RV_CODFOL, SUM( SRR.RR_VALOR )  AS RC_VALOR, 'SRR' AS TABELA %"
			EndIf
		Else
			cSelSRC := "% SRC.RC_FILIAL,				SRC.RC_CC, 			 CTT.CTT_DESC01, SRA.RA_TPCONTR, SRC.RC_PD, 			 SRV.RV_DESC, SRV.RV_CODFOL, SUM( SRC.RC_VALOR )  AS RC_VALOR, 'SRC' AS TABELA %"
			cSelSRD := "% SRD.RD_FILIAL	 AS RC_FILIAL,	SRD.RD_CC  AS RC_CC, CTT.CTT_DESC01, SRA.RA_TPCONTR, SRD.RD_PD AS RC_PD, 	 SRV.RV_DESC, SRV.RV_CODFOL, SUM( SRD.RD_VALOR )  AS RC_VALOR, 'SRD' AS TABELA %"
			cSelRHH := "% RHH.RHH_FILIAL AS RC_FILIAL,	RHH.RHH_CC AS RC_CC, CTT.CTT_DESC01, SRA.RA_TPCONTR, RHH.RHH_VERBA AS RC_PD, SRV.RV_DESC, SRV.RV_CODFOL, SUM( RHH.RHH_VALOR ) AS RC_VALOR, 'RHH' AS TABELA %"
			cSelSRR := "% SRR.RR_FILIAL  AS RC_FILIAL,	SRR.RR_CC  AS RC_CC, CTT.CTT_DESC01, SRA.RA_TPCONTR, SRR.RR_PD AS RC_PD,     SRV.RV_DESC, SRV.RV_CODFOL, SUM( SRR.RR_VALOR )  AS RC_VALOR, 'SRR' AS TABELA %"
		EndIf
		
		cGrpSRC	:= "% SRC.RC_FILIAL,  SRC.RC_CC,  CTT.CTT_DESC01, SRA.RA_TPCONTR, SRC.RC_PD, 	 SRV.RV_DESC, SRV.RV_CODFOL %"
		cGrpSRD	:= "% SRD.RD_FILIAL,  SRD.RD_CC,  CTT.CTT_DESC01, SRA.RA_TPCONTR, SRD.RD_PD,	 SRV.RV_DESC, SRV.RV_CODFOL %"
		cGrpRHH	:= "% RHH.RHH_FILIAL, RHH.RHH_CC, CTT.CTT_DESC01, SRA.RA_TPCONTR, RHH.RHH_VERBA, SRV.RV_DESC, SRV.RV_CODFOL %"
		cGrpSRR	:= "% SRR.RR_FILIAL,  SRR.RR_CC,  CTT.CTT_DESC01, SRA.RA_TPCONTR, SRR.RR_PD, 	 SRV.RV_DESC, SRV.RV_CODFOL %"
		
		cOrder	:= "% 1, 2, 3, 4, 5, 6, 7 %"
	ElseIf cTipQry == "FUN"
		cSelSRC := "% SRC.RC_FILIAL,				SRC.RC_CC,			 CTT.CTT_DESC01, SRC.RC_MAT,			SRA.RA_NOME, SRA.RA_TPCONTR, SRC.RC_PD,				 SRV.RV_DESC, SRV.RV_CODFOL, SUM( SRC.RC_VALOR )  AS RC_VALOR, 'SRC' AS TABELA %"
		cSelSRD := "% SRD.RD_FILIAL  AS RC_FILIAL,	SRD.RD_CC  AS RC_CC, CTT.CTT_DESC01, SRD.RD_MAT  AS RC_MAT,	SRA.RA_NOME, SRA.RA_TPCONTR, SRD.RD_PD     AS RC_PD, SRV.RV_DESC, SRV.RV_CODFOL, SUM( SRD.RD_VALOR )  AS RC_VALOR, 'SRD' AS TABELA %"
		cSelRHH := "% RHH.RHH_FILIAL AS RC_FILIAL,	RHH.RHH_CC AS RC_CC, CTT.CTT_DESC01, RHH.RHH_MAT AS RC_MAT, SRA.RA_NOME, SRA.RA_TPCONTR, RHH.RHH_VERBA AS RC_PD, SRV.RV_DESC, SRV.RV_CODFOL, SUM( RHH.RHH_VALOR ) AS RC_VALOR, 'RHH' AS TABELA %"
		cSelSRR := "% SRR.RR_FILIAL  AS RC_FILIAL,	SRR.RR_CC  AS RC_CC, CTT.CTT_DESC01, SRR.RR_MAT  AS RC_MAT,	SRA.RA_NOME, SRA.RA_TPCONTR, SRR.RR_PD     AS RC_PD, SRV.RV_DESC, SRV.RV_CODFOL, SUM( SRR.RR_VALOR )  AS RC_VALOR, 'SRR' AS TABELA %"
		
		cGrpSRC	:= "% SRC.RC_FILIAL,  SRC.RC_CC,  CTT.CTT_DESC01, SRA.RA_TPCONTR, SRC.RC_MAT,  SRA.RA_NOME, SRC.RC_PD,		SRV.RV_DESC, SRV.RV_CODFOL %"
		cGrpSRD	:= "% SRD.RD_FILIAL,  SRD.RD_CC,  CTT.CTT_DESC01, SRA.RA_TPCONTR, SRD.RD_MAT,  SRA.RA_NOME, SRD.RD_PD, 		SRV.RV_DESC, SRV.RV_CODFOL %"
		cGrpRHH	:= "% RHH.RHH_FILIAL, RHH.RHH_CC, CTT.CTT_DESC01, SRA.RA_TPCONTR, RHH.RHH_MAT, SRA.RA_NOME, RHH.RHH_VERBA,	SRV.RV_DESC, SRV.RV_CODFOL %"
		cGrpSRR	:= "% SRR.RR_FILIAL,  SRR.RR_CC,  CTT.CTT_DESC01, SRA.RA_TPCONTR, SRR.RR_MAT,  SRA.RA_NOME, SRR.RR_PD, 		SRV.RV_DESC, SRV.RV_CODFOL %"
		
		cOrder	:= "% 1, 2, 3, 6, 4, 5, 7, 8, 9 %"
	Else
		cSelSRC := "% SRC.RC_FILIAL %"
		cSelSRD := "% SRD.RD_FILIAL  AS RC_FILIAL %"
		cSelRHH := "% RHH.RHH_FILIAL AS RC_FILIAL %"
		cSelSRR := "% SRR.RR_FILIAL  AS RC_FILIAL %"
		
		cGrpSRC	:= "% SRC.RC_FILIAL %"
		cGrpSRD	:= "% SRD.RD_FILIAL %"
		cGrpRHH	:= "% RHH.RHH_FILIAL %"
		cGrpSRR	:= "% SRR.RR_FILIAL %"
		
		cOrder	:= "% 1 %"
	EndIf
	
	//------------------------
	// Cláusulas Join da query
	//------------------------
	cJnSRCCTT	:= "% " + FWJoinFilial( "SRC", "CTT" ) + " %"
	cJnSRDCTT	:= "% " + FWJoinFilial( "SRD", "CTT" ) + " %"
	cJnRHHCTT	:= "% " + FWJoinFilial( "RHH", "CTT" ) + " %"
	cJnSRRCTT	:= "% " + FWJoinFilial( "SRR", "CTT" ) + " %"
	
	cJnSRCSRV	:= "% " + FWJoinFilial( "SRC", "SRV" ) + " %"
	cJnSRDSRV	:= "% " + FWJoinFilial( "SRD", "SRV" ) + " %"
	cJnRHHSRV	:= "% " + FWJoinFilial( "RHH", "SRV" ) + " %"
	cJnSRRSRV	:= "% " + FWJoinFilial( "SRR", "SRV" ) + " %"
	
	//----------------------------------
	// Id. de cálculo filtrados na query
	//----------------------------------
	If nTpMov == 3 .Or. nTpMov == 4
		cCodFQry :=	"%	'0338', '0399', '0221', '0225', '0340', '0401', "
		cCodFQry +=	"	'0943', '0945', '0670', '0040', '0407', '1338', "
		cCodFQry +=	"	'1339', '1340', '1341', '0944', '0034', '0350', "
		cCodFQry +=	"	'0353', '1423', '0437', '1456'  %"
	Else
		cCodFQry :=	"%	'0013', '0019', '0014', '0020', '0221', '0225', "
		cCodFQry +=	"	'0064', '0065', '0070', '0351', '0354', '0148', "
		cCodFQry +=	"	'0150', '0149', '0184', '0185', '0186', '0187', "
		cCodFQry +=	"	'0188', '0189', '0190', '0191', '0192', '0193', "
		cCodFQry +=	"	'0200', '0201', '0204', '0782', '0670', '0034', "
		cCodFQry +=	"	'1412', '0670', '0040', '0407', '1338', '1339', "
		cCodFQry +=	"	'1340', '1341', '0350', '0353', '1423', '0437', "
		cCodFQry +=	"	'1456'  %"
	EndIf
	
	//-------------------
	// Query para oSecFil
	//-------------------
	If nTpMov <> 3

		BeginSql alias cAliasQry
		
			SELECT %exp:Upper( cSelSRC )%
			FROM %table:SRC% SRC
			INNER JOIN %table:SRA% SRA
			ON 	    	SRC.RC_FILIAL	= SRA.RA_FILIAL
					AND	SRC.RC_MAT		= SRA.RA_MAT
					AND %exp:Upper( cCcSRAQry )%
			   		AND %exp:Upper( cTpcSRAQry )%
			   		AND SRA.%notDel%
			INNER JOIN %table:CTT% CTT
			ON			%exp:cJnSRCCTT%
					AND	SRC.RC_CC		= CTT.CTT_CUSTO
					AND CTT.%notDel%
			INNER JOIN %table:SRV% SRV
			ON			%exp:cJnSRCSRV%
					AND	SRV.RV_CODFOL IN ( %exp:Upper( cCodFQry )% )
					AND SRV.RV_COD = SRC.RC_PD
					AND SRV.%notDel%
			WHERE	SRC.RC_PERIODO	=   %exp:Upper( cPeriodo )%	
					AND %exp:Upper( cFilRCQry )%
					AND %exp:Upper( cRotRCQry )%
					AND SRC.%notDel%
			GROUP BY %exp:Upper( cGrpSRC )%

			UNION
			
			SELECT %exp:Upper( cSelSRD )%
			FROM %table:SRD% SRD
			INNER JOIN %table:SRA% SRA
			ON 	    	SRD.RD_FILIAL	= SRA.RA_FILIAL
					AND	SRD.RD_MAT		= SRA.RA_MAT
					AND %exp:Upper( cCcSRAQry )%
			   		AND %exp:Upper( cTpcSRAQry )%
			   		AND SRA.%notDel%
			INNER JOIN %table:CTT% CTT
			ON			%exp:cJnSRDCTT%
					AND	SRD.RD_CC		= CTT.CTT_CUSTO
					AND CTT.%notDel%
			INNER JOIN %table:SRV% SRV
			ON			%exp:cJnSRDSRV%
					AND	SRV.RV_CODFOL IN ( %exp:Upper( cCodFQry )% )
					AND SRV.RV_COD = SRD.RD_PD
					AND SRV.%notDel%
			WHERE	SRD.RD_PERIODO	=   %exp:Upper( cPeriodo )%	
					AND %exp:Upper( cFilRDQry )%
					AND %exp:Upper( cRotRDQry )%
					AND SRD.%notDel%
			GROUP BY %exp:Upper( cGrpSRD )% 
			ORDER BY %exp:Upper( cOrder )%
		EndSql
	Else

		BeginSql alias cAliasQry
		
			SELECT %exp:Upper( cSelRHH )%
			FROM %table:RHH% RHH
			INNER JOIN %table:SRA% SRA
			ON 	    	RHH.RHH_FILIAL	= SRA.RA_FILIAL
					AND	RHH.RHH_MAT		= SRA.RA_MAT
					AND %exp:Upper( cCcSRAQry )%
			   		AND %exp:Upper( cTpcSRAQry )%
			   		AND SRA.%notDel%
			INNER JOIN %table:CTT% CTT
			ON			%exp:cJnRHHCTT%
					AND	RHH.RHH_CC		= CTT.CTT_CUSTO
					AND CTT.%notDel%
			INNER JOIN %table:SRV% SRV
			ON			%exp:cJnRHHSRV%
					AND	SRV.RV_CODFOL IN ( %exp:Upper( cCodFQry )% )
					AND SRV.RV_COD = RHH.RHH_VERBA
					AND SRV.%notDel%
			WHERE	RHH.RHH_MESANO	=   %exp:Upper( cPeriodo )%	
					AND %exp:Upper( cFilRHHQry )%
					AND RHH.RHH_VALOR <> 0
					AND RHH.%notDel%
			GROUP BY %exp:Upper( cGrpRHH )%
			
			UNION
			
			SELECT %exp:Upper( cSelSRR )%
			FROM %table:SRR% SRR
			INNER JOIN %table:SRA% SRA
			ON 	    	SRR.RR_FILIAL	= SRA.RA_FILIAL
					AND	SRR.RR_MAT		= SRA.RA_MAT
					AND %exp:Upper( cCcSRAQry )%
			   		AND %exp:Upper( cTpcSRAQry )%
			   		AND SRA.%notDel%
			INNER JOIN %table:CTT% CTT
			ON			%exp:cJnSRRCTT%
					AND	SRR.RR_CC		= CTT.CTT_CUSTO
					AND CTT.%notDel%
			INNER JOIN %table:SRV% SRV
			ON			%exp:cJnSRRSRV%
					AND	SRV.RV_CODFOL IN ( %exp:Upper( cCodFQry )% )
					AND SRV.RV_COD = SRR.RR_PD
					AND SRV.%notDel%
			INNER JOIN %table:SRG% SRG
			ON			SRG.RG_FILIAL	= SRR.RR_FILIAL
					AND	SRG.RG_MAT		= SRR.RR_MAT
					AND SRG.RG_DTGERAR	= SRR.RR_DATA
					AND	SRG.RG_EFETIVA	= %exp:( 'S' )%
					AND	SRG.RG_DTGERAR BETWEEN %exp:cDataDe% AND %exp:cDataAte%
					AND SRR.RR_TIPO2 <> %exp:( 'G' )%
					AND SRG.RG_RESCDIS = '2' //Filtrar somente os dados que vieram de dissidio.
					AND SRG.%notDel%
			WHERE		SRR.RR_VALOR <> 0
					AND SRR.%notDel%
			GROUP BY %exp:Upper( cGrpSRR )%
			ORDER BY %exp:Upper( cOrder )%
		EndSql
	EndIf
Return

/*/{Protheus.doc}fTabGPS( cRot13o )
- Monta query dinâmica sobre parâmetros e tabelas da GPS
@Type Static Function
@author:	Jônatas Alves	
@since:		22/05/2017
@param: 
@version 1.0
@return
/*/
Static Function fTabGPS( cRot13o )

	Local aParam	:= { "MV_SALMGRP", "MV_LIMDMAT", "MV_ENCINSS" }
	Local aInssEmp	:= {}
	Local aColumns	:= {}
	Local aFilGPS	:= {}
	Local aGPSVal	:= {}
	Local aTabS035	:= {}
	Local aTabS037	:= {}
	
	Local nParam	:= 0
	Local nParTab	:= 0
	Local nFil		:= 0
	Local nTpCtr	:= 0
	Local nGps		:= 0
	
	Local cAliasTmp	:= GetNextAlias()
	Local cCodFil	:= ""
	Local cCount	:= "0"

	//---------------------------------------------
	// Imprime parâmetros utilizados na conferência
	//---------------------------------------------
	For nParam := 1 To Len( aParam )	
	    dbSelectArea( "SX6" )
	    SX6->( dbSetOrder( 1 ) )
	    If SX6->( dbSeek( Space( FwSizeFilial() ) + aParam[ nParam ] ) )
	    	cDescSX6 := AllTrim( aParam[ nParam ] ) + " | " + AllTrim( X6Descric() ) + AllTrim( X6Desc1() ) + AllTrim( X6Desc2() )
	    	xRetSX6	:= X6Conteud()
	    	xRetSX6	:= Alltrim( If( ValType( xRetSX6 ) == "C", xRetSX6, cValToChar( xRetSX6 ) ) )
	    	aAdd( aParTab, { "PAR", Alltrim( aParam[ nParam ] ), Alltrim( cDescSX6 ), Alltrim( xRetSx6 )} )
	    EndIf
	Next
	
	//-----------------------------------
	// Executa Query para Filtrar Filiais
	//-----------------------------------
	fQryMov( cRot13o, "TBL", cAliasTmp )
	
	dbSelectArea( cAliasTmp )
	While ( cAliasTmp )->( !Eof() )
		aAdd( aFilGPS, ( cAliasTmp )->RC_FILIAL )
		( cAliasTmp )->( dbSkip() )
	EndDo
	
	( cAliasTmp )->( dbCloseArea() )
	
	For nFil := 1 To Len( aFilGPS )
		cCodFil := aFilGPS[ nFil ]
		//----------------------------------------
		// Carrega Tabelas Enc. Emp. e Out. Entid.
		//----------------------------------------
		aInssEmp := {}
		If !fInssEmp( cCodFil, @aInssEmp, , cPeriodo )
			Return
		Else
			aAdd( aTabS037, { cCodFil, aClone( aInssEmp ) } )
		EndIf
		
		//--------------------------
		// Carrega Tabela Compl. GPS
		//--------------------------
		aGPSVal := {}
		fGPSVal( cCodFil, If( nTpMov == 2, Left( cPeriodo, 4 ) + "13", cPeriodo ), @aGPSVal, cTpCtr )
		If !Empty( aGPSVal )
			For nGps := 1 To Len( aGPSVal )
				If ( Empty( aTabS035 ) .Or.;
				aScan( aTabS035,	{ | x |	x[ 01 ] == aGPSVal[ nGps, 01 ] .And.;
				 							x[ 02 ] == aGPSVal[ nGps, 02 ] .And.;
				 							x[ 03 ] == aGPSVal[ nGps, 03 ] .And.;
				 							x[ 04 ] == aGPSVal[ nGps, 04 ] .And.;
				 							x[ 05 ] == aGPSVal[ nGps, 05 ] .And.;
				 							x[ 06 ] == aGPSVal[ nGps, 06 ] .And.;
				 							x[ 07 ] == aGPSVal[ nGps, 07 ] .And.;
				 							x[ 08 ] == aGPSVal[ nGps, 08 ] .And.;
				 							x[ 09 ] == aGPSVal[ nGps, 09 ] .And.;
				 							x[ 10 ] == aGPSVal[ nGps, 10 ] .And.;
				 							x[ 11 ] == aGPSVal[ nGps, 11 ];
				 					} ) == 0 )
				 	aAdd( aTabS035, aClone( aGPSVal[ nGps ] ) )
				EndIf
			Next
		EndIf
	Next
	
	// Campos chaves
	aAdd( aColumns, { "TIPO",	"C",   4, 0 } ) // "PAR" ou "S03X"
	aAdd( aColumns, { "CONT",	"C",   3, 0 } ) // Contador para índice
	aAdd( aColumns, { "FILPROC","C",  FwGetTamFilial, 0 } ) // Filial utilizada para carga da tabela - @!

	// SX6
	aAdd( aColumns, { "X6COD",	"C",  10, 0 } ) // Codigo do MV_ (SX6)
	aAdd( aColumns, { "X6DESC",	"C", 150, 0 } ) // Descrição do MV_ (SX6)
	aAdd( aColumns, { "X6CONT",	"C",   8, 0 } ) // Conteúdo do MV_ (SX6)
		
	// S035
	aAdd( aColumns, { "CDECUSTO",	"C",  20, 0 } ) // Centro de Custo - @!
	aAdd( aColumns, { "VERBA",		"C",   3, 0 } ) // Verba - @!
	aAdd( aColumns, { "BASE",		"N",  12, 2 } ) // Base - @E 999,999,999.99
	aAdd( aColumns, { "PERCENTUAL",	"N",   7, 2 } ) // Percentual - @E 9,999.99
	aAdd( aColumns, { "VALOR",		"N",  12, 2 } ) // Valor - @E 999,999,999.99
	aAdd( aColumns, { "RECDED",		"C",   1, 0 } ) // Rec./Ded. - @!
	aAdd( aColumns, { "OBSERVACAO",	"C",  30, 0 } ) // Observação - @!
	aAdd( aColumns, { "TPCONTR",	"C",   1, 0 } ) // Tipo de Contrato - 9
	aAdd( aColumns, { "CMPINI",		"C",   6, 0 } ) // Mes Comp. Ini - 9999/99
	aAdd( aColumns, { "CMPFIM",		"C",   6, 0 } ) // Ano Comp. Fim - 9999/99

	// S037
	aAdd( aColumns, { "EMPRESA", "N",  8, 4 } ) // % Empresa - @E 999.9999
	aAdd( aColumns, { "ACIDTRB", "N",  8, 4 } ) // % Acid.Trab. - @E 999.9999
	aAdd( aColumns, { "RAT", 	 "N",  8, 4 } ) // % Rat - @E 999.9999
	aAdd( aColumns, { "FGTS", 	 "N",  8, 4 } ) // % FGTS - @E 999.9999
	aAdd( aColumns, { "RECFATUR","C",  1, 0 } ) // % Recolhe S/ Fatur. - 9
	aAdd( aColumns, { "CDPTOGPS","C",  4, 0 } ) // Cod. Pagto GPS - 9999
	aAdd( aColumns, { "VLRMINGP","N", 10, 2 } ) // Vlr.Min. GPS - @E 999,999.99
	
	// S038
	aAdd( aColumns, { "CODTERC",	"C",  4, 0 } ) // Cod. Terceiros - @!
	aAdd( aColumns, { "TERCEIRO",	"N",  8, 4 } ) // % Terceiros - @E 999.9999
	aAdd( aColumns, { "SALEDU",		"N",  8, 4 } ) // % Sal. Educacao - @E 999.9999
	aAdd( aColumns, { "INCRA",		"N",  8, 4 } ) // % INCRA - @E 999.9999
	aAdd( aColumns, { "SENAI",		"N",  8, 4 } ) // % SENAI - @E 999.9999
	aAdd( aColumns, { "SESI",		"N",  8, 4 } ) // % SESI - @E 999.9999
	aAdd( aColumns, { "SENAC",		"N",  8, 4 } ) // % SENAC - @E 999.9999
	aAdd( aColumns, { "SESC",		"N",  8, 4 } ) // % SESC - @E 999.9999
	aAdd( aColumns, { "SEBRAE",		"N",  8, 4 } ) // % SEBRAE - @E 999.9999
	aAdd( aColumns, { "DPC",		"N",  8, 4 } ) // % DPC - @E 999.9999
	aAdd( aColumns, { "FAER",		"N",  8, 4 } ) // % F. AER. - @E 999.9999
	aAdd( aColumns, { "SENAR",		"N",  8, 4 } ) // % SENAR - @E 999.9999
	aAdd( aColumns, { "SECONC",		"N",  8, 4 } ) // % SECONC - @E 999.9999
	aAdd( aColumns, { "SEST",		"N",  8, 4 } ) // % SEST - @E 999.9999
	aAdd( aColumns, { "SENAT",		"N",  8, 4 } ) // % SENAT - @E 999.9999
	aAdd( aColumns, { "SESCOOP",	"N",  8, 4 } ) // % SESCOOP - @E 999.9999
	aAdd( aColumns, { "SENAI5",		"N",  8, 4 } ) // % Adic.SENAI - @E 999.9999

	oTmpTbl := FWTemporaryTable():New( cAliasTbl )
	oTmpTbl:SetFields( aColumns )
	oTmpTbl:AddIndex( "IND", { "TIPO", "CONT" } )
	oTmpTbl:Create()
	
	dbSelectArea( cAliasTbl )
	
	For nParTab := 1 To Len( aParTab )
	
		cCount := Soma1( cCount )
		RecLock( cAliasTbl, .T. )
		
		// Campos chaves
		( cAliasTbl )->TIPO		:= aParTab[ nParTab, 1 ]
		( cAliasTbl )->CONT 	:= cCount
		
		// SX6
		( cAliasTbl )->X6COD	:= aParTab[ nParTab, 2 ]
		( cAliasTbl )->X6DESC	:= aParTab[ nParTab, 3 ]
		( cAliasTbl )->X6CONT	:= aParTab[ nParTab, 4 ]
		
		( cAliasTbl )->( MsUnLock() )
	Next
	
	For nParTab := 1 To Len( aTabS035 )
	
		cCount := Soma1( cCount )
		
		If !Empty( aTabS035[ nParTab ] )

			RecLock( cAliasTbl, .T. )

			// Campos chaves
			( cAliasTbl )->TIPO		:= "S035"
			( cAliasTbl )->CONT 	:= cCount
			( cAliasTbl )->FILPROC	:= aTabS035[ nParTab, 10 ]
			
			// S035
			( cAliasTbl )->CDECUSTO		:= aTabS035[ nParTab, 1 ]
			( cAliasTbl )->VERBA		:= aTabS035[ nParTab, 2 ]
			( cAliasTbl )->BASE			:= aTabS035[ nParTab, 3 ]
			( cAliasTbl )->PERCENTUAL	:= aTabS035[ nParTab, 4 ]
			( cAliasTbl )->VALOR		:= aTabS035[ nParTab, 5 ]
			( cAliasTbl )->RECDED		:= aTabS035[ nParTab, 6 ]
			( cAliasTbl )->OBSERVACAO	:= aTabS035[ nParTab, 7 ]
			( cAliasTbl )->TPCONTR		:= ""
			( cAliasTbl )->CMPINI		:= aTabS035[ nParTab, 8 ]
			( cAliasTbl )->CMPFIM		:= aTabS035[ nParTab, 9 ]
		
			( cAliasTbl )->( MsUnLock() )
		EndIf
	Next
	
	For nParTab := 1 To Len( aTabS037 )
	
		If !Empty( aTabS037[ nParTab, 2 ] )
			
			For nTpCtr := 1 To 2
				
				If !lDicInter
					If cTpCtr <> "3" .And. ( ( cTpCtr == "1" .And. nTpCtr == 2 ) .Or. ( cTpCtr == "2" .And. nTpCtr == 1 ) )
						Loop
					EndIf
				EndIf
				
				cCount := Soma1( cCount )
				
				// S037
				RecLock( cAliasTbl, .T. )

				// Campos chaves
				( cAliasTbl )->TIPO		:= "S037"
				( cAliasTbl )->CONT 	:= cCount
				( cAliasTbl )->FILPROC	:= aTabS037[ nParTab, 1 ]
				
				// Tipo de contrato para controle
				( cAliasTbl )->TPCONTR	:= Alltrim( Str( nTpCtr ) )
				
				// Dados da tabela
				( cAliasTbl )->EMPRESA	:= aTabS037[ nParTab, 2,  1, nTpCtr ] * 100
				( cAliasTbl )->ACIDTRB	:= aTabS037[ nParTab, 2,  3, nTpCtr ] * 100
				( cAliasTbl )->RAT		:= aTabS037[ nParTab, 2, 29, nTpCtr ] * 100
				( cAliasTbl )->FGTS		:= aTabS037[ nParTab, 2,  4, nTpCtr ] * 100
				( cAliasTbl )->RECFATUR	:= aTabS037[ nParTab, 2, 27, nTpCtr ]
				( cAliasTbl )->CDPTOGPS	:= aTabS037[ nParTab, 2, 24, nTpCtr ]
				( cAliasTbl )->VLRMINGP	:= aTabS037[ nParTab, 2, 28, nTpCtr ]

				( cAliasTbl )->( MsUnLock() )
				
				// S038
				RecLock( cAliasTbl, .T. )

				// Campos chaves
				( cAliasTbl )->TIPO		:= "S038"
				( cAliasTbl )->CONT 	:= cCount
				( cAliasTbl )->FILPROC	:= aTabS037[ nParTab, 1 ]

				// Tipo de contrato para controle
				( cAliasTbl )->TPCONTR	:= Alltrim( Str( nTpCtr ) )
				
				// Dados da tabela
				( cAliasTbl )->CODTERC	:= aTabS037[ nParTab, 2, 25, nTpCtr ]
				( cAliasTbl )->TERCEIRO	:= aTabS037[ nParTab, 2,  2, nTpCtr ] * 100
				( cAliasTbl )->SALEDU	:= aTabS037[ nParTab, 2,  9, nTpCtr ] * 100
				( cAliasTbl )->INCRA	:= aTabS037[ nParTab, 2, 10, nTpCtr ] * 100
				( cAliasTbl )->SENAI	:= aTabS037[ nParTab, 2, 11, nTpCtr ] * 100
				( cAliasTbl )->SESI		:= aTabS037[ nParTab, 2, 12, nTpCtr ] * 100
				( cAliasTbl )->SENAC	:= aTabS037[ nParTab, 2, 13, nTpCtr ] * 100
				( cAliasTbl )->SESC		:= aTabS037[ nParTab, 2, 14, nTpCtr ] * 100
				( cAliasTbl )->SEBRAE	:= aTabS037[ nParTab, 2, 15, nTpCtr ] * 100
				( cAliasTbl )->DPC		:= aTabS037[ nParTab, 2, 16, nTpCtr ] * 100
				( cAliasTbl )->FAER		:= aTabS037[ nParTab, 2, 17, nTpCtr ] * 100
				( cAliasTbl )->SENAR	:= aTabS037[ nParTab, 2, 18, nTpCtr ] * 100
				( cAliasTbl )->SECONC	:= aTabS037[ nParTab, 2, 19, nTpCtr ] * 100
				( cAliasTbl )->SEST		:= aTabS037[ nParTab, 2, 22, nTpCtr ] * 100
				( cAliasTbl )->SENAT	:= aTabS037[ nParTab, 2, 23, nTpCtr ] * 100
				( cAliasTbl )->SESCOOP	:= aTabS037[ nParTab, 2, 26, nTpCtr ] * 100
				( cAliasTbl )->SENAI5	:= aTabS037[ nParTab, 2, 30, nTpCtr ] * 100
			
				( cAliasTbl )->( MsUnLock() )
			Next
		EndIf
	Next
Return

/*/{Protheus.doc}fImpTpCtr()
- Imprime a descrição do Tipo de Contrato apenas para o primeiro lançamento da verba encontrada para o mesmo em oSecLct
@Type Static Function
@author:	Jônatas Alves	
@since:		22/05/2017
@param: 
@version 1.0
@return cRet, Descrição do Tipo de Contrato
/*/
Static Function fImpTpCtr()
	
	Local cRet	:= ""
	
	If cImpTpCtr # RA_TPCONTR
		cImpTpCtr	:= ( cAliasFun )->RA_TPCONTR
		If lDicInter
			If  cImpTpCtr == "1"
				cRet		:= "Indeterminado"
			ElseIf  cImpTpCtr == "2"
				cRet := "Determinado"
			ElseIf  cImpTpCtr == "3"
				cRet := "Intermitente"
			EndIf 
		Else
			cRet		:= If( cImpTpCtr == "1", "Indeterminado", "Determinado" )
		EndIf
	EndIf
Return( cRet )
