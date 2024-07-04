#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH" 
#INCLUDE "ORGR080.CH"


/*/{Protheus.doc} ORGR080
Relatorio de Controle Orcamentario: comparativo entre os totais de salarios definidos para os postos, conforme as quantidades
de vagas abertas e ocupadas e os totais de salarios que efetivamente estao sendo pagos aos funcionarios que ocupam os postos. 

@author Esther de Viveiro - Carlos Olivieri
@since 02/04/2014
@version P12

@return nil
/*/
Function ORGR080()

	Local oReport
	Local aArea := GetArea()
	
	Private cPerg := "ORG80R"
	Private lCorpManage		:= fIsCorpManage( FWGrpCompany() )	// Verifica se o cliente possui Gestão Corporativa no Grupo Logado
	
	If lCorpManage
		Private lUniNeg		:= !Empty(FWSM0Layout(cEmpAnt, 2)) // Verifica se possui tratamento para unidade de Negocios
		Private lEmpFil		:= !Empty(FWSM0Layout(cEmpAnt, 1)) // Verifica se possui tratamento para Empresa
		Private cLayoutGC 		:= FWSM0Layout(cEmpAnt)
		Private nStartEmp		:= At("E",cLayoutGC)
		Private nStartUnN		:= At("U",cLayoutGC)
		Private nEmpLength		:= Len(FWSM0Layout(cEmpAnt, 1))
		Private nUnNLength		:= Len(FWSM0Layout(cEmpAnt, 2))
	EndIf
	
	Pergunte(cPerg,.F.)
	
	oReport := ReportDef()
	oReport:PrintDialog()
	
	RestArea(aArea)
	
Return


/*/{Protheus.doc} ReportDef
Definicao dos componentes do relatorio

@author Esther de Viveiro - Carlos Olivieri
@since 07/04/2014
@version P12

@return objeto, Estrutura do relatorio
/*/
Static Function ReportDef()

	Local oReport
	Local oSectionH
	Local oSectPosto	
	Local oSectCC
	Local oSectDepto
	
	Local cAliasQry := GetNextAlias()
	Local cTitulo := OemToAnsi(STR0001)	//"Relatorio de Controle Orcamentario"
	Local cDesc1  := OemToAnsi(STR0002) + OemToAnsi(STR0003)	//"Comparativo entre os salarios definidos para os postos e o salario dos funcionarios ocupando estes postos"
																		//### "Sera impresso de acordo com os parametros solicitados pelo usuario."
	Local aOrd := {}
	
	Aadd(aOrd, OemToAnsi(STR0008) + ' + ' + OemToAnsi(STR0004))	//1 - "Filial " +  " Cod. Posto"
	Aadd(aOrd, OemToAnsi(STR0008) + ' + ' + OemToAnsi(STR0005))	//2 - "Filial " + " Posto"
	Aadd(aOrd, OemToAnsi(STR0008) + ' + ' + OemToAnsi(STR0006) + ' + ' + OemToAnsi(STR0004))	//3 - "Filial " + " C. Custo " + " Cod. Posto"
	Aadd(aOrd, OemToAnsi(STR0008) + ' + ' + OemToAnsi(STR0006) + ' + ' + OemToAnsi(STR0005))	//4 - "Filial " + " C. Custo " + " Posto"
	Aadd(aOrd, OemToAnsi(STR0008) + ' + ' + OemToAnsi(STR0007) + ' + ' + OemToAnsi(STR0004))	//5 - "Filial " + " Departamento" + " Cod. Posto" 
	Aadd(aOrd, OemToAnsi(STR0008) + ' + ' + OemToAnsi(STR0007) + ' + ' + OemToAnsi(STR0005))	//6 - "Filial " + " Departamento" + " Posto"	
	
	//CRIACAO DOS COMPONENTES DE IMPRESSAO
	DEFINE REPORT oReport NAME "ORGR080" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| ORG80Imp(oReport, cAliasQry) } DESCRIPTION cDesc1
		
		oReport:SetTotalInLine(.F.)     // para totalizar em linhas
		oReport:nFontBody	:= 6.5
		oReport:SetDynamic()
		
		//SECTION 01
		DEFINE SECTION oSectionH OF oReport TITLE OemToAnsi(STR0008) TABLE "RCL" ORDERS aOrd //Filial
		
			DEFINE CELL NAME "RCL_FILIAL" OF oSectionH ALIAS "RCL"
			
			oSectionH:SetLineStyle()	
			oSectionH:SetDynamicKey(OemToAnsi(STR0008))	//"Filial"			
	
		//SECTION 02
		DEFINE SECTION oSectPosto OF oReport TITLE OemToAnsi(STR0005) TABLE "RCL", "RCJ", "SRJ" ORDERS aOrd	//"Posto" - ordem 01 e 02
		
			DEFINE CELL NAME "RCL_FILIAL"	OF oSectPosto ALIAS "RCL" 
			DEFINE CELL NAME "RCL_CC"		OF oSectPosto TITLE OemToAnsi(STR0006)	ALIAS "RCL" //"C.Custo"
			DEFINE CELL NAME "RCL_DEPTO"	OF oSectPosto TITLE OemToAnsi(STR0007)	ALIAS "RCL" //"Departamento"			
			DEFINE CELL NAME "RCL_POSTO"	OF oSectPosto TITLE OemToAnsi(STR0004)	ALIAS "RCL" //"Cod. Posto" 	
			DEFINE CELL NAME "RJ_DESC"		OF oSectPosto TITLE OemToAnsi(STR0005)	SIZE(20) ALIAS "SRJ" //"Posto"
			DEFINE CELL NAME "RCJ_DESCRI" 	OF oSectPosto TITLE OemToAnsi(STR0027)	SIZE(25) ALIAS "RCJ" //"Processo"	
			DEFINE CELL NAME "TIPO_POSTO"	OF oSectPosto TITLE OemToAnsi(STR0025)	SIZE(11) BLOCK {|| Iif((cAliasQry)->RCL_TPOSTO == '1',OemToAnsi(STR0009),OemToAnsi(STR0010))} //"Tp.Posto" - 1 = Individual, 2 = Generico	
			DEFINE CELL NAME "RCL_NPOSTO"	OF oSectPosto TITLE OemToAnsi(STR0016)	ALIAS "RCL" //"Tot.Vaga"
			DEFINE CELL NAME "RCL_OPOSTO"	OF oSectPosto TITLE OemToAnsi(STR0017)	ALIAS "RCL" //"Vaga.Ocup"
			DEFINE CELL NAME "VG_ABERTAS"	OF oSectPosto TITLE OemToAnsi(STR0018)	BLOCK {|| (cAliasQry)->RCL_NPOSTO - (cAliasQry)->RCL_OPOSTO } //"Vaga.Aberta""
			DEFINE CELL NAME "RCL_SALAR"	OF oSectPosto TITLE OemToAnsi(STR0019) ALIAS "RCL" //"Sal.Posto"
			DEFINE CELL NAME "SAL_POSTO"	OF oSectPosto TITLE OemToAnsi(STR0020) PICTURE "@E 99,999,999,999.99" BLOCK {|| (cAliasQry)->RCL_NPOSTO * (cAliasQry)->RCL_SALAR } //"Tot.Sal.Posto"
			DEFINE CELL NAME "SAL_ABERTA"	OF oSectPosto TITLE OemToAnsi(STR0021) PICTURE "@E 99,999,999,999.99" BLOCK {||((cAliasQry)->RCL_NPOSTO - (cAliasQry)->RCL_OPOSTO) * (cAliasQry)->RCL_SALAR } //"Tot.Sal.(A)"
			DEFINE CELL NAME "SAL_OCUPAD"	OF oSectPosto TITLE OemToAnsi(STR0022) PICTURE "@E 99,999,999,999.99" BLOCK {|| (cAliasQry)->RCL_OPOSTO * (cAliasQry)->RCL_SALAR} //"Tot.Sal.(O)"
			DEFINE CELL NAME "SAL_FUNCIO"	OF oSectPosto TITLE OemToAnsi(STR0023) PICTURE "@E 99,999,999,999.99" BLOCK {|| (cAliasQry)->SALFUN} //"Tot.Sal.Func"
			DEFINE CELL NAME "SAL_DIFERE"	OF oSectPosto TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" BLOCK {|| ((cAliasQry)->RCL_OPOSTO * (cAliasQry)->RCL_SALAR) - (cAliasQry)->SALFUN } //"Diferenca"
			DEFINE CELL NAME "PORC_DIFER"	OF oSectPosto TITLE '%' SIZE (5) BLOCK {|| ( ABS(((cAliasQry)->RCL_OPOSTO * (cAliasQry)->RCL_SALAR) - (cAliasQry)->SALFUN)*100 )/((cAliasQry)->RCL_OPOSTO * (cAliasQry)->RCL_SALAR)} 
	
			oSectPosto:Cell("RCL_FILIAL"):Disable()
		
		//SECTION 03		
		DEFINE SECTION oSectCC OF oReport TITLE OemToAnsi(STR0006) TABLE "CTT" ORDERS aOrd //"Centro de Custo" - ordem 03 e 04
		
			DEFINE CELL NAME "CTT_FILIAL" OF oSectCC ALIAS "CTT"
			DEFINE CELL NAME "CTT_CUSTO"  OF oSectCC TITLE OemToAnsi(STR0006) ALIAS "CTT"
			DEFINE CELL NAME "CTT_DESC01" OF oSectCC TITLE OemToAnsi(STR0028) ALIAS "CTT"
	
			oSectCC:SetLineStyle()
			oSectCC:SetDynamicKey(OemToAnsi(STR0006))							
			oSectCC:Cell("CTT_FILIAL"):Disable()
	
		//SECTION 04
		DEFINE SECTION oSectDepto OF oReport TITLE OemToAnsi(STR0007) TABLE "SQB" ORDERS aOrd //"Departamento" - ordem 05 e 06
		
			DEFINE CELL NAME "QB_FILIAL"  OF oSectDepto ALIAS "SQB"
			DEFINE CELL NAME "QB_DEPTO"   OF oSectDepto TITLE OemToAnsi(STR0007) ALIAS "SQB"
			DEFINE CELL NAME "QB_DESCRIC" OF oSectDepto TITLE OemToAnsi(STR0028) ALIAS "SQB"
			
			oSectDepto:SetLineStyle()
			oSectDepto:SetDynamicKey(OemToAnsi(STR0007))
			oSectDepto:Cell("QB_FILIAL"):Disable()
			
	oReport:SetLandscape()
			
Return (oReport)

/*/{Protheus.doc} ORG80Imp
Definicoes de uso das sections.
Definicoes dos totalizadores (functions e collections).
Realizacao da query para o relatorio.

@author Esther de Viveiro - Carlos Olivieri
@since 08/04/2014
@version P12

@param oReport, objeto, Objeto TReport
@param cAliasQry, caractere, Alias da área utilizada para busca no banco

@return caractere, Alias da área utilizada na busca ao banco de dados
/*/
Static Function ORG80Imp(oReport, cAliasQry)

Local oSectHead
Local oSectPosto
Local oSectCC 	
Local oSectDept	

Local oBreakDept
Local oBreakCC
Local oBreakFil
Local oBreakUnN
Local oBreakEmp

Local nOrdem		:= 1
Local cOrdem 		:= ""
Local cJoinRCJ	:= fGR080join( "RCL", "RCJ", "%" )
Local cJoinCTT	:= fGR080join( "RCL", "CTT", "%" )
Local cJoinSQB	:= fGR080join( "RCL", "SQB", "%" )
Local cJoinSRJ	:= fGR080join( "RCL", "SRJ", "%" )
Local cJoinSRA	:= fGR080join( "RCL", "SRA", "%" )
Local cTitDept	:= ""
Local cTitCC		:= ""
Local cTitFil		:= ""
Local cTitUnN		:= ""
Local cTitEmp		:= ""
Local cProcesso	:= ALLTRIM(mv_par05)
Local nTipoPosto	:= mv_par06
Local cWhere		:= ""

nOrdem := oReport:GetOrder()

oSectHead := oReport:Section(1)
oSectPosto := oReport:Section(2)

If nOrdem == 3 .OR. nOrdem == 4
	oSectCC  := oReport:Section(3)
	oSectPosto:Cell("RCL_CC"):Disable()
Endif
	
If nOrdem == 5 .OR. nOrdem == 6
	oSectDept := oReport:Section(4)	
	oSectPosto:Cell("RCL_DEPTO"):Disable()
EndIf

If nOrdem == 1 .OR. nOrdem == 3 .OR. nOrdem == 5
	oSectPosto:SetDynamicKey(OemToAnsi(STR0004))	//"Codigo Posto"
								
Else
	oSectPosto:SetDynamicKey(OemToAnsi(STR0005))	//"Descricao"	
EndIf

If nOrdem == 3 .OR. nOrdem == 4
	//---------------------------------------------------------------------------------------------------------------------------------------
	//QUEBRA POR CENTRO DE CUSTO
	//---------------------------------------------------------------------------------------------------------------------------------------
	DEFINE BREAK oBreakCC OF oSectCC WHEN {|| (cAliasQry)->RCL_FILIAL+(cAliasQry)->RCL_CC} TITLE OemToAnsi(STR0012)
	
	oBreakCC:OnBreak({|x|cTitCC := OemToAnsi(STR0012) + " " + oSectCC:Cell("CTT_CUSTO"):GetText(), oReport:ThinLine()}) //TOTAL DO CENTRO DE CUSTO
	oBreakCC:SetTotalText({||cTitCC})
	oBreakCC:SetTotalInLine(.F.)			 
	
	DEFINE FUNCTION NAME "CA" FROM oSectPosto:Cell("RCL_POSTO")  FUNCTION COUNT	BREAK oBreakCC NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "CB" FROM oSectPosto:Cell("RCL_NPOSTO") FUNCTION SUM	BREAK oBreakCC NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "CC" FROM oSectPosto:Cell("RCL_OPOSTO") FUNCTION SUM	BREAK oBreakCC NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "CD" FROM oSectPosto:Cell("VG_ABERTAS") FUNCTION SUM	BREAK oBreakCC NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "CE" FROM oSectPosto:Cell("RCL_SALAR")  FUNCTION SUM	BREAK oBreakCC NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "CF" FROM oSectPosto:Cell("SAL_POSTO")  FUNCTION SUM	BREAK oBreakCC NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "CG" FROM oSectPosto:Cell("SAL_ABERTA") FUNCTION SUM	BREAK oBreakCC NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "CH" FROM oSectPosto:Cell("SAL_OCUPAD") FUNCTION SUM	BREAK oBreakCC NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "CI" FROM oSectPosto:Cell("SAL_FUNCIO") FUNCTION SUM	BREAK oBreakCC NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "CJ" FROM oSectPosto:Cell("SAL_DIFERE") FUNCTION SUM	BREAK oBreakCC NO END SECTION NO END REPORT
	
		
Elseif nOrdem == 5 .OR. nOrdem == 6
	//---------------------------------------------------------------------------------------------------------------------------------------
	//QUEBRA POR DEPARTAMENTO
	//---------------------------------------------------------------------------------------------------------------------------------------	
	DEFINE BREAK oBreakDept OF oSectDept WHEN {|| (cAliasQry)->RCL_FILIAL+(cAliasQry)->RCL_DEPTO} TITLE OemToAnsi(STR0011)
	
	oBreakDept:OnBreak({|x|cTitDept := OemToAnsi(STR0011) + " " + oSectDept:Cell("QB_DEPTO"):GetText(), oReport:ThinLine()})
	oBreakDept:SetTotalText({||cTitDept})
	oBreakDept:SetTotalInLine(.F.)			 	 
	
	DEFINE FUNCTION NAME "DA" FROM oSectPosto:Cell("RCL_POSTO")  FUNCTION COUNT	BREAK oBreakDept NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "DB" FROM oSectPosto:Cell("RCL_NPOSTO") FUNCTION SUM	BREAK oBreakDept NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "DC" FROM oSectPosto:Cell("RCL_OPOSTO") FUNCTION SUM	BREAK oBreakDept NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "DD" FROM oSectPosto:Cell("VG_ABERTAS") FUNCTION SUM	BREAK oBreakDept NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "DE" FROM oSectPosto:Cell("RCL_SALAR")  FUNCTION SUM	BREAK oBreakDept NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "DF" FROM oSectPosto:Cell("SAL_POSTO")  FUNCTION SUM	BREAK oBreakDept NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "DG" FROM oSectPosto:Cell("SAL_ABERTA") FUNCTION SUM	BREAK oBreakDept NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "DH" FROM oSectPosto:Cell("SAL_OCUPAD") FUNCTION SUM	BREAK oBreakDept NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "DI" FROM oSectPosto:Cell("SAL_FUNCIO") FUNCTION SUM	BREAK oBreakDept NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "DJ" FROM oSectPosto:Cell("SAL_DIFERE") FUNCTION SUM	BREAK oBreakDept NO END SECTION NO END REPORT
	
EndIf

//---------------------------------------------------------------------------------------------------------------------------------------
//QUEBRA POR FILIAL
//---------------------------------------------------------------------------------------------------------------------------------------
DEFINE BREAK oBreakFil OF oReport WHEN {|| (cAliasQry)->RCL_FILIAL} TITLE OemToAnsi(STR0013) 

oBreakFil:OnBreak({|x|cTitFil :=OemToAnsi(STR0013) + " " + x, oReport:ThinLine()}) //Total da Filial
oBreakFil:SetTotalText({||cTitFil})
oBreakFil:SetTotalInLine(.F.)

DEFINE FUNCTION NAME "FA" FROM oSectPosto:Cell("RCL_POSTO")  FUNCTION COUNT	BREAK oBreakFil NO END SECTION NO END REPORT 
DEFINE FUNCTION NAME "FB" FROM oSectPosto:Cell("RCL_NPOSTO") FUNCTION SUM	BREAK oBreakFil NO END SECTION NO END REPORT
DEFINE FUNCTION NAME "FC" FROM oSectPosto:Cell("RCL_OPOSTO") FUNCTION SUM	BREAK oBreakFil NO END SECTION NO END REPORT
DEFINE FUNCTION NAME "FD" FROM oSectPosto:Cell("VG_ABERTAS") FUNCTION SUM	BREAK oBreakFil NO END SECTION NO END REPORT
DEFINE FUNCTION NAME "FE" FROM oSectPosto:Cell("RCL_SALAR")  FUNCTION SUM	BREAK oBreakFil NO END SECTION NO END REPORT
DEFINE FUNCTION NAME "FF" FROM oSectPosto:Cell("SAL_POSTO")  FUNCTION SUM	BREAK oBreakFil NO END SECTION NO END REPORT
DEFINE FUNCTION NAME "FG" FROM oSectPosto:Cell("SAL_ABERTA") FUNCTION SUM	BREAK oBreakFil NO END SECTION NO END REPORT
DEFINE FUNCTION NAME "FH" FROM oSectPosto:Cell("SAL_OCUPAD") FUNCTION SUM	BREAK oBreakFil NO END SECTION NO END REPORT
DEFINE FUNCTION NAME "FI" FROM oSectPosto:Cell("SAL_FUNCIO") FUNCTION SUM	BREAK oBreakFil NO END SECTION NO END REPORT
DEFINE FUNCTION NAME "FJ" FROM oSectPosto:Cell("SAL_DIFERE") FUNCTION SUM	BREAK oBreakFil NO END SECTION NO END REPORT

// Só efetua quebra por empresa/Unidade de negócio caso tenha gestão corporativa
If lCorpManage 

	//---------------------------------------------------------------------------------------------------------------------------------------
	//QUEBRA POR UNIDADE DE NEGOCIO
	//---------------------------------------------------------------------------------------------------------------------------------------
	DEFINE BREAK oBreakUnN OF oReport WHEN { || Substr((cAliasQry)->RCL_FILIAL, nStartUnN, nUnNLength) } TITLE OemToAnsi(STR0015) 
	
	oBreakUnN:OnBreak({|x|cTitUnN := OemToAnsi(STR0014) + " " + x, oReport:ThinLine()})
	oBreakUnN:SetTotalText({||cTitUnN})
	oBreakUnN:SetTotalInLine(.F.)
	
	DEFINE FUNCTION NAME "UA" FROM oSectPosto:Cell("RCL_POSTO")  FUNCTION COUNT	BREAK oBreakUnN NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "UB" FROM oSectPosto:Cell("RCL_NPOSTO") FUNCTION SUM	BREAK oBreakUnN NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "UC" FROM oSectPosto:Cell("RCL_OPOSTO") FUNCTION SUM	BREAK oBreakUnN NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "UD" FROM oSectPosto:Cell("VG_ABERTAS") FUNCTION SUM	BREAK oBreakUnN NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "UE" FROM oSectPosto:Cell("RCL_SALAR")  FUNCTION SUM	BREAK oBreakUnN NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "UF" FROM oSectPosto:Cell("SAL_POSTO")  FUNCTION SUM	BREAK oBreakUnN NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "UG" FROM oSectPosto:Cell("SAL_ABERTA") FUNCTION SUM	BREAK oBreakUnN NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "UH" FROM oSectPosto:Cell("SAL_OCUPAD") FUNCTION SUM	BREAK oBreakUnN NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "UI" FROM oSectPosto:Cell("SAL_FUNCIO") FUNCTION SUM	BREAK oBreakUnN NO END SECTION NO END REPORT
	DEFINE FUNCTION NAME "UJ" FROM oSectPosto:Cell("SAL_DIFERE") FUNCTION SUM	BREAK oBreakUnN NO END SECTION NO END REPORT
	
	
	//---------------------------------------------------------------------------------------------------------------------------------------
	//QUEBRA POR EMPRESA
	//---------------------------------------------------------------------------------------------------------------------------------------
	DEFINE BREAK oBreakEmp OF oReport WHEN { || Substr((cAliasQry)->RCL_FILIAL, nStartEmp, nEmpLength) } TITLE OemToAnsi(STR0016)
	
	oBreakEmp:OnBreak({|x|cTitEmp := OemToAnsi(STR0015) + " " + x, oReport:ThinLine()})
	oBreakEmp:SetTotalText({||cTitEmp})
	oBreakEmp:SetTotalInLine(.F.)
	
	DEFINE FUNCTION NAME "EA" FROM oSectPosto:Cell("RCL_POSTO")  FUNCTION COUNT	BREAK oBreakEmp NO END SECTION
	DEFINE FUNCTION NAME "EB" FROM oSectPosto:Cell("RCL_NPOSTO") FUNCTION SUM	BREAK oBreakEmp NO END SECTION
	DEFINE FUNCTION NAME "EC" FROM oSectPosto:Cell("RCL_OPOSTO") FUNCTION SUM	BREAK oBreakEmp NO END SECTION
	DEFINE FUNCTION NAME "ED" FROM oSectPosto:Cell("VG_ABERTAS") FUNCTION SUM	BREAK oBreakEmp NO END SECTION
	DEFINE FUNCTION NAME "EE" FROM oSectPosto:Cell("RCL_SALAR")  FUNCTION SUM	BREAK oBreakEmp NO END SECTION
	DEFINE FUNCTION NAME "EF" FROM oSectPosto:Cell("SAL_POSTO")  FUNCTION SUM	BREAK oBreakEmp NO END SECTION
	DEFINE FUNCTION NAME "EG" FROM oSectPosto:Cell("SAL_ABERTA") FUNCTION SUM	BREAK oBreakEmp NO END SECTION
	DEFINE FUNCTION NAME "EH" FROM oSectPosto:Cell("SAL_OCUPAD") FUNCTION SUM	BREAK oBreakEmp NO END SECTION
	DEFINE FUNCTION NAME "EI" FROM oSectPosto:Cell("SAL_FUNCIO") FUNCTION SUM	BREAK oBreakEmp NO END SECTION
	DEFINE FUNCTION NAME "EJ" FROM oSectPosto:Cell("SAL_DIFERE") FUNCTION SUM	BREAK oBreakEmp NO END SECTION

EndIf

//---------------------------------------------------------------------------------------------------------------------------------------
MakeSqlExpr("ORG80R")

//DEFINICAO - WHERE
If nTipoPosto == 1 .OR. nTipoPosto == 2
	cWhere := "RCL_TPOSTO = '" + alltrim(STR(nTipoPosto)) +"'"
Else
	cWhere := "(RCL_TPOSTO = '1' OR RCL_TPOSTO = '2')" 
EndIf

If cProcesso <> ""
	cWhere += " AND RCL_PROCES = '" + cProcesso + "'"
EndIf

cWhere := "%" + cWhere + "%"


//DEFINICAO - ORDER BY
If nOrdem == 1 
	cOrdem := "%RCL_FILIAL, RCL_POSTO, RCL_PROCES%"

ElseIf nOrdem == 2 
	cOrdem := "%RCL_FILIAL, RJ_DESC, RCL_PROCES%"

ElseIf nOrdem == 3 
	cOrdem := "%RCL_FILIAL, RCL_CC, RCL_POSTO, RCL_PROCES%"

ElseIf nOrdem == 4
	cOrdem := "%RCL_FILIAL, RCL_CC, RJ_DESC, RCL_PROCES%"

ElseIf nOrdem == 5
	cOrdem := "%RCL_FILIAL, RCL_DEPTO, RCL_POSTO, RCL_PROCES%"

ElseIf nOrdem == 6
	cOrdem := "%RCL_FILIAL, RCL_DEPTO, RJ_DESC, RCL_PROCES%"
EndIf

//BUSCA NO BANCO DE DADOS
BEGIN REPORT QUERY oSectHead

	BEGINSQL ALIAS cAliasQry
		SELECT RCL_FILIAL, RCL_CC, RCL_DEPTO, RCL_POSTO, RCL_TPOSTO, RCL_FUNCAO, RCL_SALAR, RCL_NPOSTO, RCL_OPOSTO,
				CTT_FILIAL, CTT_CUSTO, CTT_DESC01, QB_FILIAL, QB_DEPTO, QB_DESCRIC, RA_POSTO, SALFUN, RCJ_DESCRI,
				RCL_PROCES, RJ_DESC
		
		FROM %table:RCL%  RCL //Posto
		
		INNER JOIN %table:RCJ% RCJ //Processo
			ON %exp:cJoinRCJ%
			AND RCL_PROCES = RCJ_CODIGO
			AND RCJ.%notDel%
	
		INNER JOIN %table:CTT% CTT //Centro de Custo
			ON %exp:cJoinCTT%
			AND RCL_CC = CTT_CUSTO
			AND CTT.%notDel%
			
		INNER JOIN %table:SQB% SQB //Departamento
			ON %exp:cJoinSQB%
			AND RCL_DEPTO = SQB.QB_DEPTO
			AND SQB.%notDel%
		
		INNER JOIN %table:SRJ% SRJ //Funcao
			ON %exp:cJoinSRJ%
			AND RCL_FUNCAO = RJ_FUNCAO
			AND SRJ.%notDel%		
		
		LEFT JOIN 
				(SELECT RA_FILIAL, RA_POSTO, SUM (RA_SALARIO) SALFUN, D_E_L_E_T_ 
				 FROM %table:SRA% SRA 
				 GROUP BY RA_FILIAL, RA_POSTO, D_E_L_E_T_) SRA
			ON %exp:cJoinSRA% AND SRA.%notDel%				
			AND RCL_POSTO = SRA.RA_POSTO
		WHERE %exp:cWhere%
		ORDER BY %exp:cOrdem%
	
	ENDSQL
	
END REPORT QUERY oSectHead PARAM mv_par01, mv_par02, mv_par03, mv_par04

//RELACIONAMENTO ENTRE SECTIONS
If nOrdem == 01 .OR. nOrdem == 02

	oSectPosto:SetParentQuery()
	oSectPosto:SetParentFilter({|cParam| (cAliasQry)->RCL_FILIAL == cParam},{|| (cAliasQry)->RCL_FILIAL})	

Elseif nOrdem == 03 .OR. nOrdem == 04

	oSectCC:SetParentQuery()
	oSectCC:SetParentFilter({|cParam| (cAliasQry)->RCL_FILIAL == cParam},{|| (cAliasQry)->RCL_FILIAL})
	
	oSectPosto:SetParentQuery()
	oSectPosto:SetParentFilter({|cParam| (cAliasQry)->RCL_FILIAL+(cAliasQry)->RCL_CC == cParam},{|| (cAliasQry)->RCL_FILIAL+(cAliasQry)->CTT_CUSTO})		
	
Elseif nOrdem == 05 .OR. nOrdem == 06

	oSectDept:SetParentQuery()
	oSectDept:SetParentFilter({|cParam| (cAliasQry)->RCL_FILIAL == cParam},{|| (cAliasQry)->RCL_FILIAL})
	
	oSectPosto:SetParentQuery()
	oSectPosto:SetParentFilter({|cParam| (cAliasQry)->RCL_FILIAL+(cAliasQry)->RCL_DEPTO == cParam},{|| (cAliasQry)->RCL_FILIAL+(cAliasQry)->QB_DEPTO})
	
EndIf

	//No bloco de codigo da direita conceitualmente deveria estar o campo QB_FILIAL/CTT_FILIAL, porem foi necessario
	//manter RCL_FILIAL devido aos niveis de compartilhamento diferentes pela gestao de empresas, caso contrario o
	//conteudo dos campos não bateria dado algum seria apresentado.

oSectHead:Print()

Return (cAliasQry)

/*/{Protheus.doc} fGR080join
O tratamento para o embedded SQL
Conversão da clausula "SUBSTRING" em "SUBSTR" ao usar alguns banco de dados.        

@author Esther de Viveiro
@since 03/04/2014
@version P12

@param cTabela1, caractere, Primeira tabela do relacionamento
@param cTabela2, caractere, Segunda tabela do relacionamento
@param [cEmbedded], caractere, Simbolo para abertura/fechamento do Embedded

@return caractere, Comando SUBTRING tratado
/*/
Static Function fGR080join(cTabela1, cTabela2,cEmbedded)

	Local cFiltJoin := ""
	Local cNameDB	  := ""
	Default cEmbedded := ""
	
	cFiltJoin := cEmbedded + FWJoinFilial(cTabela1, cTabela2) + cEmbedded	
	
	If ( cNameDB $ 'DB2|ORACLE|POSTGRES|INFORMIX' )
		cFiltJoin := STRTRAN(cFiltJoin, "SUBSTRING", "SUBSTR")
	EndIf
	
Return (cFiltJoin)