#include "protheus.ch"
#include "report.ch"
#include "plsr267.ch"

Static objCENFUNLGP := CENFUNLGP():New()

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSR267
Relatório de documentos a vencer
@author	Karine Riquena Limp
@since		21/06/2017
@version	P12
/*/
//---------------------------------------------------------------------------------------
Function PLSR267()
Local oReport
Local oBA1
Local oBCP

//-- LGPD ----------
if !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif
//------------------

if Pergunte("PLSR267",.T.)

	DEFINE REPORT oReport NAME "PLSR267" TITLE STR0001 + " " + alltrim(str(mv_par01)) + " " + STR0002 PARAMETER "PLSR267" ACTION {|oReport| PrintReport(oReport)} /*"Documentos a vencer nos próximos " // " dias "*/

		DEFINE SECTION oBA1 OF oReport TITLE STR0003 TABLES "BA1" /*"Beneficiário"*/
		
			DEFINE CELL NAME "MATRIC" OF oBA1 TITLE STR0004 SIZE 20 /*"Matrícula"*/
			DEFINE CELL NAME "BA1_NOMUSR" OF oBA1 ALIAS "BA1" 

		if(mv_par03 == 1)
		
			DEFINE SECTION oBCP OF oBA1 TITLE STR0005 TABLE "BCP" /*"Documento"*/

				DEFINE CELL NAME "BCP_CODDOC" OF oBCP ALIAS "BCP"
				DEFINE CELL NAME "BD2_DESCRI" OF oBCP ALIAS "BD2"
				DEFINE CELL NAME "BCP_DATINC" OF oBCP ALIAS "BCP"
				DEFINE CELL NAME "BCP_DATVAL" OF oBCP ALIAS "BCP"
				DEFINE CELL NAME "BCP_ENTREG" OF oBCP ALIAS "BCP"

				DEFINE FUNCTION FROM oBCP:Cell("BCP_CODDOC") OF oBA1 FUNCTION COUNT TITLE STR0006/*"Documentos"*/
			
		else
	
			DEFINE CELL NAME "BCP_CODDOC" OF oBA1 ALIAS "BCP"
			DEFINE CELL NAME "BD2_DESCRI" OF oBA1 ALIAS "BD2"
			DEFINE CELL NAME "BCP_DATINC" OF oBA1 ALIAS "BCP"
			DEFINE CELL NAME "BCP_DATVAL" OF oBA1 ALIAS "BCP"
			DEFINE CELL NAME "BCP_ENTREG" OF oBA1 ALIAS "BCP"
	
		endIf

	oReport:PrintDialog()

endIf

Return

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSR267
Query de impressão do relatório
@author	Karine Riquena Limp
@since		21/06/2017
@version	P12
/*/
//---------------------------------------------------------------------------------------
Static Function PrintReport(oReport)

Local cMatric := ""
Local oBA1    := oReport:Section(1)
Local oBCP    := iif(mv_par03 == 1, oReport:Section(1):Section(1),nil)

#IFDEF TOP
	
	Local cAlias := GetNextAlias()

	MakeSqlExp("REPORT")
	
	If TcSrvType() <> "AS/400"
		BEGIN REPORT QUERY oReport:Section(1)
		
		BeginSQL Alias cAlias
		
		SELECT BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG,BA1_DIGITO, BA1_NOMUSR, 
				(BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO) as MATRIC, 
				BCP_CODOPE,BCP_CODEMP,BCP_MATRIC,BCP_TIPREG, 
				BCP_CODDOC,BD2_DESCRI,BCP_DATINC,BCP_DATVAL,BCP_ENTREG 
	
		FROM %table:BA1% BA1 
		
		INNER JOIN %table:BCP% BCP ON( 
				BCP_CODOPE = BA1_CODINT AND 
				BCP_CODEMP = BA1_CODEMP AND 
				BCP_MATRIC = BA1_MATRIC AND 
				BCP_TIPREG = BA1_TIPREG 
		)
		
		INNER JOIN %table:BD2% BD2 ON( BD2_CODDOC = BCP_CODDOC )
	
		WHERE 
		
			BA1_FILIAL = %xFilial:BA1% AND BA1.%notDel% AND 
			BCP_FILIAL = %xFilial:BCP% AND BCP.%notDel% AND 
			BD2_FILIAL = %xFilial:BD2% AND BD2.%notDel%
			AND BCP_DATVAL >= %exp:ddatabase% AND BCP_DATVAL <= %exp:ddatabase+mv_par01%	
	
		ORDER BY BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG,BA1_DIGITO 
			
		EndSql
			
		END REPORT QUERY oBA1
		
	EndIf

#ENDIF	

	if(!empty(mv_par02))
		oBA1:SetLineCondition({|| (cAlias)->BCP_CODDOC == MV_PAR02})
	endIf
	
	//aqui eu relaciono com a tabela filha quando o usuário quiser agrupar os documentos pendentes por beneficiário
	if(mv_par03 == 1)
		oBCP:SetParentQuery()
		oBCP:SetParentFilter({|cParam| (cAlias)->(BCP_CODOPE+BCP_CODEMP+BCP_MATRIC+BCP_TIPREG) == cParam},{|| (cAlias)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)})	
		if(!empty(mv_par02))
			oBCP:SetLineCondition({|| (cAlias)->BCP_CODDOC == MV_PAR02})
		endIf
	endIf
	
	oBA1:Print()
	
Return