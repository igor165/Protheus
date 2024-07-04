#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FINR856.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinR856   บAutor  ณMicrosiga           บ Data ณ  24/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Demonstrativo: Rela็ใo de extratos bancแrios               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FinR856()
Local oReport	:= Nil
Local lTReport	:= TRepInUse()
Local lDefTop	:= IfDefTopCTB() //verificar se pode executar query (TOPCONN)

Private aSelFil	:= {}
Private cAlias	:= GetNextAlias()

If !lDefTop
	Help("  ",1,"FINR856TOP",,STR0001,1,0) //"Fun็ใo disponํvel apenas para ambientes TopConnect" //"Fun็ใo disponํvel apenas para ambientes TopConnect"
	Return
EndIf

If !lTReport
	Help("  ",1,"FINR856R4",,STR0002,1,0) //"Fun็ใo disponํvel apenas para TReport, por favor atualizar ambiente e verifique o parametro MV_TREPORT" //"Fun็ใo disponํvel apenas para TReport, por favor atualizar ambiente e verifique o parametro MV_TREPORT"
	Return
EndIf

If Pergunte("FIR856",.T.)

	If MV_PAR09 == 1 .And. Len(aSelFil) <= 0
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			Return
		EndIf
	EndIf

	oReport := ReportDef()
	oReport:PrintDialog()

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef บAutor  ณMicrosiga           บ Data ณ  24/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a estrutura de impressao do relatorio                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef()
Local oReport		:= Nil
Local oSection1		:= Nil
Local oSection2		:= Nil
Local oSection3		:= Nil
Local lImpAnalit	:= MV_PAR01 == 1

DEFINE REPORT oReport NAME "FINR856" TITLE STR0003 PARAMETER "FIR856" ACTION {|oReport| PrintReport(oReport)} //"Rela็ใo de extratos bancแrios"

	DEFINE SECTION oSection1 OF oReport TITLE "Bancos" TABLES "SA6"

		DEFINE CELL NAME "A6_FILIAL"	OF oSection1 ALIAS "SA6" //Filial do Sistema
		DEFINE CELL NAME "A6_COD"		OF oSection1 ALIAS "SA6" //Codigo do Banco
		DEFINE CELL NAME "A6_AGENCIA"	OF oSection1 ALIAS "SA6" //Agencia do banco
		DEFINE CELL NAME "A6_NUMCON"	OF oSection1 ALIAS "SA6" //Conta Corrente no Banco
		DEFINE CELL NAME "A6_NOME"		OF oSection1 ALIAS "SA6" //Nome do banco

	DEFINE SECTION oSection2 OF oSection1 TITLE "Extratos" TABLES "FJE"

		DEFINE CELL NAME "FJE_CODEXT"	OF oSection2 ALIAS "FJE" //Cod. Extrato
		DEFINE CELL NAME "FJE_DTEXT"	OF oSection2 ALIAS "FJE" //Data corte
		DEFINE CELL NAME "FJE_NUMEXT"	OF oSection2 ALIAS "FJE" //Num. Extrato
		DEFINE CELL NAME "FJE_SLDEXT"	OF oSection2 ALIAS "FJE" //Saldo
		DEFINE CELL NAME "FJE_DTCONC"	OF oSection2 ALIAS "FJE" //Data concil.
		DEFINE CELL NAME "FJE_ESTEXT"	OF oSection2 ALIAS "FJE" SIZE 20 BLOCK {|| Finr856JE()} //Est. extrato

	If lImpAnalit

		DEFINE SECTION oSection3 OF oSection2 TITLE "Movimentos" TABLE "FJF"

			DEFINE CELL NAME "FJF_DATMOV"	OF oSection3 ALIAS "FJF" //Data
			DEFINE CELL NAME "FJF_CODCON"	OF oSection3 ALIAS "FJF" //Conceito
			DEFINE CELL NAME "FJF_DESCON"	OF oSection3 ALIAS "FJF" //Descricao
			DEFINE CELL NAME "FJF_VALOR"	OF oSection3 ALIAS "FJF" //Valor movim.
			DEFINE CELL NAME "FJF_COMPRO"	OF oSection3 ALIAS "FJF" //Comprovante
			DEFINE CELL NAME "FJF_ESTMOV"	OF oSection3 ALIAS "FJF" SIZE 20 BLOCK {|| Finr856JF()} //Estado mov.

	EndIf

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintReportบAutor  ณMicrosiga          บ Data ณ  24/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtem os dados e realiza a impressใo                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrintReport(oReport)
Local cCondFil		:= ""
Local cCondEstad	:= ""
Local lImpAnalit	:= MV_PAR01 == 1

Pergunte("FIR856",.F.)

cCondFil := "A6_FILIAL " + GetRngFil( aSelfil , "SA6" )
cCondFil := "%" + cCondFil + "%"

Do Case
 	Case MV_PAR08 == 1 //Todos
		cCondEstad := "('1','2','3','4')"
	Case MV_PAR08 == 2 //Conciliados
		cCondEstad := "('3')"
	Case MV_PAR08 == 3 //Nใo conciliados
		cCondEstad := "('2')"
	Case MV_PAR08 == 4 //Inconsistentes
		cCondEstad := "('1')"
EndCase
cCondEstad := "%" + cCondEstad +"%"

MakeSqlExp("FIR856")

//----------------------
// Query Analitico
//----------------------
If lImpAnalit
	BEGIN REPORT QUERY oReport:Section(1)
	
	BeginSql alias cAlias
		SELECT
			A6_FILIAL	,A6_COD		,A6_AGENCIA	,A6_NUMCON	,A6_NOME	,
			FJE_BCOCOD	,FJE_CODEXT	,FJE_DTEXT	,FJE_NUMEXT	,FJE_SLDEXT	,FJE_DTCONC	,FJE_ESTEXT	,
			FJF_CODEXT	,FJF_DATMOV	,FJF_CODCON	,FJF_DESCON	,FJF_VALOR	,FJF_COMPRO	,FJF_ESTMOV
	
		FROM
			%table:SA6% SA6 INNER JOIN %table:FJE% FJE ON
			A6_COD		= FJE_BCOCOD	AND
			A6_AGENCIA	= FJE_BCOAGE	AND
			A6_NUMCON	= FJE_BCOCTA
	
			INNER JOIN %table:FJF% FJF  ON
			FJE_CODEXT = FJF_CODEXT
	
		WHERE
			%exp:cCondFil%	AND
			SA6.%notDel%	AND
			FJE.%notDel%	AND
			FJF.%notDel%	AND
			A6_COD		BETWEEN %exp:mv_par02%	AND %exp:mv_par03%	AND
			FJE_DTEXT	BETWEEN %exp:mv_par04%	AND %exp:mv_par05%	AND
			FJE_CODEXT	BETWEEN %exp:mv_par06%	AND %exp:mv_par07%	AND
			FJE_ESTEXT IN %exp:cCondEstad%
	
		ORDER BY
			A6_FILIAL,A6_COD,A6_AGENCIA,A6_NUMCON,FJE_CODEXT,FJE_DTEXT,FJE_NUMEXT,FJF_DATMOV,FJF_CODCON
	
	EndSql
	
	END REPORT QUERY oReport:Section(1)
Else
//----------------------
// Query Sintetico
//----------------------
	BEGIN REPORT QUERY oReport:Section(1)
	
	BeginSql alias cAlias
		SELECT
			A6_FILIAL	,A6_COD		,A6_AGENCIA	,A6_NUMCON	,A6_NOME	,
			FJE_BCOCOD	,FJE_CODEXT	,FJE_DTEXT	,FJE_NUMEXT	,FJE_SLDEXT	,FJE_DTCONC	,FJE_ESTEXT
	
		FROM
			%table:SA6% SA6 INNER JOIN %table:FJE% FJE ON
			A6_COD		= FJE_BCOCOD	AND
			A6_AGENCIA	= FJE_BCOAGE	AND
			A6_NUMCON	= FJE_BCOCTA
	
		WHERE
			%exp:cCondFil%	AND
			SA6.%notDel%	AND
			FJE.%notDel%	AND
			A6_COD		BETWEEN %exp:mv_par02%	AND %exp:mv_par03%	AND
			FJE_DTEXT	BETWEEN %exp:mv_par04%	AND %exp:mv_par05%	AND
			FJE_CODEXT	BETWEEN %exp:mv_par06%	AND %exp:mv_par07%	AND
			FJE_ESTEXT IN %exp:cCondEstad%
	
		ORDER BY
			A6_FILIAL,A6_COD,A6_AGENCIA,A6_NUMCON,FJE_CODEXT,FJE_DTEXT,FJE_NUMEXT
	
	EndSql
	
	END REPORT QUERY oReport:Section(1)
EndIf

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter({|cParam| (cAlias)->FJE_BCOCOD == cParam},{|| (cAlias)->A6_COD})

If lImpAnalit
	oReport:Section(1):Section(1):Section(1):SetParentQuery()
	oReport:Section(1):Section(1):Section(1):SetParentFilter({|cParam| (cAlias)->FJF_CODEXT == cParam},{|| (cAlias)->FJE_CODEXT})
EndIf

oReport:Section(1):Print()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINR856   บAutor  ณMicrosiga           บ Data ณ  09/25/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtem a descricao do estado do extrato ou do movimento     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Finr856JE( )
Local cRet := ""

Local cEstado	:= (cAlias)->FJE_ESTEXT

Do Case
	Case cEstado == "1"
		cRet := STR0004 //"Inconsistente"
	Case cEstado == "2"
		cRet := STR0005 //"Nใo conciliado"
	Case cEstado == "3"
		cRet := STR0006 //"Conciliado"
	Case cEstado == "4"
		cRet := STR0007 //"Finalizado"
EndCase

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINR856   บAutor  ณMicrosiga           บ Data ณ  09/25/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtem a descricao do estado do extrato ou do movimento     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Finr856JF()

Local cRet    := " "
Local cEstado := (cAlias)->FJF_ESTMOV

Do Case
	Case cEstado == "1"
		cRet := STR0004		//"Inconsistente"
	Case cEstado == "2"
		cRet := STR0005		//"Nใo conciliado"
	Case cEstado == "3"
		cRet := STR0006		//"Conciliado"
	Case cEstado == "4"
		cRet := STR0007		//"Finalizado"
EndCase

Return cRet
