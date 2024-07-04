#INCLUDE "protheus.ch"
#INCLUDE "report.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLR001
Relatório resumido para atender a resolução ANP 45/2013

@author Alexandre Gimenez
@since 05/5/2016
@version P11/P12
/*/
//-------------------------------------------------------------------
Static Function DCLR001()
Local oReport
Local oD39
Local lRet := AliasInDic("D39")

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

Pergunte("ANP45REL",.F.)

DEFINE REPORT oReport NAME "DCLR001" TITLE "ANP 45"  ACTION {|oReport| PrintReport(oReport)} PARAMETER "ANP45REL"

	DEFINE SECTION oD39 OF oReport TITLE "Relatorio ANP45" TABLES "D39" 

		DEFINE CELL NAME "D39_NATURE" OF oD39 ALIAS "D39"
		DEFINE CELL NAME "D39_CODREG" OF oD39 ALIAS "D39"
		DEFINE CELL NAME "D39_INST1" OF oD39 ALIAS "D39"
		DEFINE CELL NAME "D39_INST2" OF oD39 ALIAS "D39"
		DEFINE CELL NAME "D39_LOCMNT" OF oD39 ALIAS "D39"
		DEFINE CELL NAME "D39_CODPRO" OF oD39 ALIAS "D39"
		DEFINE CELL NAME "D39_SEMANA" OF oD39 ALIAS "D39"
		DEFINE CELL NAME "D39_MES" OF oD39 ALIAS "D39"
		DEFINE CELL NAME "D39_ANOREF" OF oD39 ALIAS "D39"
		DEFINE CELL NAME "D39_ESMD" OF oD39 ALIAS "D39"
		
oReport:PrintDialog()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Impressão de Relatório

@author Alexandre Gimenez 
@since 05/5/2016
@version P11/P12
/*/
//-------------------------------------------------------------------
Static Function PrintReport(oReport)
Local cAlias := GetNextAlias()
Local cWhere	:= DclGetWhere()

MakeSqlExp("ANP45REL")
	
BEGIN REPORT QUERY oReport:Section(1)
	
	BeginSql alias cAlias
		SELECT D39_NATURE,D39_CODREG,D39_INST1,D39_INST2,D39_LOCMNT,D39_CODPRO,
				D39_SEMANA,D39_MES,D39_ANOREF,D39_ESMD
		
		FROM %table:D39% D39
		WHERE D39.%NotDel% 
		AND %Exp:cWhere%
	EndSql
	
END REPORT QUERY oReport:Section(1) PARAM MV_PAR02,MV_PAR04

	oReport:Section(1):Print()
Return