#include "protheus.ch"
#include "report.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLR002
Relatório analitivo para atender a resolução ANP 45/2013

@author Alexandre Gimenez
@since 05/5/2016
@version P11/P12
/*/
//-------------------------------------------------------------------
Static Function DCLR002()
Local oReport
Local oD39
Local oD34
Local oBreakSem

Private cAlias := GetNextAlias()

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

Pergunte("ANP45REL",.F.)

DEFINE REPORT oReport NAME "MYREPORT" TITLE "ANP 45"  ACTION {|oReport| PrintReport(oReport)} PARAMETER "ANP45REL"

	DEFINE SECTION oD39 OF oReport TITLE "Relatório ANP45 Gerencial" TABLES "D39","SB1" 

		DEFINE CELL NAME "D39_LOCMNT" OF oD39 ALIAS "D39"
		DEFINE CELL NAME "D39_CODPRO" OF oD39 ALIAS "D39"
		DEFINE CELL NAME "B1_DESC" OF oD39 ALIAS "SB1"
		DEFINE CELL NAME "D39_MES" OF oD39 ALIAS "D39"
		DEFINE CELL NAME "D39_OBS" OF oD39 ALIAS "D39"
		
	DEFINE SECTION oD34 OF oD39 TITLE "Detalhamento" TABLE "D34","D39" TOTAL IN COLUMN

		DEFINE CELL NAME "D34_SEMANA" OF oD34 ALIAS "D34" TITLE "Semana"
		DEFINE CELL NAME "D34_DATA" OF oD34 ALIAS "D34" TITLE "Data"
		DEFINE CELL NAME "D34_LASTRO" OF oD34 ALIAS "D34" Title "Latro"
		DEFINE CELL NAME "D34_VOLLOC" OF oD34 ALIAS "D34" Title "Vol. Armazenado"
		DEFINE CELL NAME "D34_VOLTRA" OF oD34 ALIAS "D34" Title "Vol. Transito"
		If lSaldoTer
			DEFINE CELL NAME "D34_VOLTER" OF oLBC ALIAS "LBC" Title "Vol. Em Terceiros" PICTURE "@E 999,999,999,999.999"
		EndIf
		DEFINE CELL NAME "TEMP_TOTAL" OF oD34 ALIAS "D34" Title "Total" PICTURE "@E 999,999,999,999.999"
		DEFINE CELL NAME "D39_ESDMOB" OF oD34 ALIAS "D39" Title "EsdM Objetivo"
		DEFINE CELL NAME "TEMP_DIF" OF oD34 ALIAS "D34" Title "Diferença" 
		
		DEFINE BREAK oBreakSem OF oD34 WHEN oD34:Cell("D34_SEMANA")
		
		DEFINE FUNCTION FROM oD34:Cell("D34_VOLLOC") FUNCTION AVERAGE BREAK oBreakSem NO END REPORT
		DEFINE FUNCTION FROM oD34:Cell("D34_VOLTRA") FUNCTION AVERAGE BREAK oBreakSem NO END REPORT
		DEFINE FUNCTION FROM oD34:Cell("TEMP_TOTAL") FUNCTION AVERAGE BREAK oBreakSem NO END REPORT 
		DEFINE FUNCTION FROM oD34:Cell("D39_ESDMOB") FUNCTION AVERAGE BREAK oBreakSem NO END REPORT
		If lSaldoTer
			DEFINE FUNCTION FROM oLBC:Cell("D34_VOLTER") FUNCTION AVERAGE BREAK oBreakSem NO END REPORT
		EndIf
		
		DEFINE FUNCTION FROM oD34:Cell("TEMP_DIF") FUNCTION SUM BREAK oBreakSem NO END REPORT

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
Local cWhere	:= DclGetWhere()
Local cCampos := ""
Local cCampos2:= ""
Local cCpoSel	:= ""
Local lSaldoTer	:= SuperGetMV("MV_ANP45TE",.F.,.F.)
Local cANPUM	:= SuperGetMv("MV_ANP45UM",.F.,1)
Local cESDMOB	:= CaseUM('D39_ESDMOB',cANPUM)
Local cLastro	:= CaseUM('D34_LASTRO',cANPUM)
Local cVolLoc	:= CaseUM('D34_VOLLOC',cANPUM,.F.)
Local cVolTer	:= CaseUM('D34_VOLTER',cANPUM,.F.) 
Local cVolTra	:= CaseUM('D34_VOLTRA',cANPUM) 
Local cGroup	:= "D39_LOCMNT,D39_CODPRO,B1_DESC,D39_MES,D39_OBS,D34_DATA,D39_ESDMOB,D34_CODREG,D34_LOCMNT,D34_CODPRO,D39_CODREG,D39_LOCMNT,D39_CODPRO,D34_SEMANA"

If lSaldoTer
	cCampos := CaseUM("SUM(D34_VOLLOC + D34_VOLTRA + D34_VOLTER)",cANPUM) // Somatario do total
	cCampos2:= CaseUM("(SUM(D34_VOLLOC + D34_VOLTRA + D34_VOLTER + D34_LASTRO) - D39_ESDMOB)",cANPUM) //Somatoria da diferenca
	cCpoSel := "%SUM("+cVolLoc+") D34_VOLLOC, SUM("+cVolter+") D34_VOLTER%"  
Else
	cCampos := CaseUM("SUM(D34_VOLLOC + D34_VOLTRA)",cANPUM)  // Somatario do total
	cCampos2:= CaseUM("(SUM(D34_VOLLOC + D34_VOLTRA + D34_LASTRO) - D39_ESDMOB)",cANPUM)//Somatoria da diferenca
	cCpoSel := "%SUM("+cVolLoc+") D34_VOLLOC%"
EndIf
//Ajusta groupBy
IF cANPUM == 2
	cGroup += ",B1_TIPCONV,B1_CONV"
ElseIF cANPUM == 3
	cGroup += ",DH5_TCONDCL,DH_CONVDCL"
EndIf

cGroup := "%" +cGroup+ "%"

MakeSqlExp("ANP45REL")
	
BEGIN REPORT QUERY oReport:Section(1)
	
	BeginSql alias cAlias
		SELECT 
			//---------------------	
			//Campos Secção D39 
			//---------------------
			D39_LOCMNT,D39_CODPRO,B1_DESC,D39_MES,D39_OBS,
			//--------------------------
			//Campos Somados Secção D34
			//--------------------------
			D34_DATA,D39_ESDMOB,D34_SEMANA,%Exp:cESDMOB% AS D39_ESDMOB,
			//--------------------------
			//Campos Somados Secção D34
			//--------------------------
			SUM(D34_LASTRO) D34_LASTRO ,%Exp:cCpoSel%,SUM(%Exp:cVoltra%) D34_VOLTRA, 
			//---------------------
			//Campos Temporarios
			//---------------------
			SUM(D34_VOLLOC+D34_VOLTRA) TEMP_TOTAL,	%Exp:cCampos2% TEMP_DIF,
			//----------------------------
			//Campos para relacionamento
			//----------------------------
			D34_CODREG,D34_LOCMNT,D34_CODPRO,D39_CODREG,D39_LOCMNT,D39_CODPRO
		
		FROM %table:D39% D39, %table:D34% D34,%table:SB1% SB1 
			LEFT JOIN %table:DH5% DH5 
				ON DH5_FILIAL = %xfilial:DH5% 
				AND SB1.B1_COD = DH5.DH5_COD 
				AND DH5.%NotDel%
		WHERE 
		
		D39_NATURE = D34_NATURE AND D39_CODREG = D34_CODREG AND
		D39_INST1 = D34_INST1 AND D39_INST2 = D34_INST2 AND
		D39_LOCMNT = D34_LOCMNT AND D39_CODPRO = D34_CODPRO AND
		D39_SEMANA = D34_SEMANA
		AND // Join D39 e SB1
		B1_FILIAL = %xfilial:SB1% AND B1_COD = D39_CODPRO
		AND SB1.%NotDel%
		AND D39.%NotDel%
		AND D34.%NotDel%
		AND %Exp:cWhere% 
		
		Group BY 
		%Exp:cGroup%
	
		
	EndSql
	
END REPORT QUERY oReport:Section(1) PARAM MV_PAR02,MV_PAR04
	
	oReport:Section(1):Section(1):SetParentQuery()
	oReport:Section(1):Section(1):SetParentFilter({|cParam| (cAlias)->D34_CODREG+D34_LOCMNT+D34_CODPRO == cParam},{|| (cAlias)->D39_CODREG+D39_LOCMNT+D39_CODPRO })
	
	oReport:Section(1):Print()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CaseUM
Retorna case para montagem de query com conversao de UM

@author Alexandre Gimenez
@since 24/07/2017
@version P11/P12
/*/
//-------------------------------------------------------------------
Static function CaseUM(cCampo,nMult,lExp)
Local cRet := ""

Default lExp := .T.

If nMult = 2
	cRet := "Case when B1_TIPCONV = 'M' THEN ( Case WHEN B1_CONV > 0 then("+cCampo+" * B1_CONV ) Else ("+cCampo+") END ) 	When B1_TIPCONV = 'D' THEN ( Case WHEN B1_CONV > 0 then("+cCampo+" / B1_CONV ) Else ("+cCampo+")  END ) ELSE ("+cCampo+") End"
ElseIF nMult = 3
	cRet := "Case when DH5_TCONDCL = 'M' THEN ( Case WHEN DH5_CONVDCL > 0 then("+cCampo+" * DH5_CONVDCL ) Else ("+cCampo+") END ) When DH5_TCONDCL = 'D' THEN ( Case WHEN DH5_CONVDCL > 0 then("+cCampo+" / DH5_CONVDCL ) Else ("+cCampo+")  END ) ELSE ("+cCampo+") End"
Else
	cRet := cCampo
EndIf

If lExp
	cRet := "%" + cRet + "%"
EndIf

Return cRet