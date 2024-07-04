#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "GCPR007.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GCPR007 บAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relatorio de rela็ใod de licita็ใo por modalidade             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCP - Gestใo de Compras Publicas                             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCPR007()

Local   oReport		:= nil
Private cTitulo		:= STR0001//"Relatorio de rela็ใo de licita็ใo por modalidade"
Private cPerg		:= "GCR007"   
Private cAliasQry 	:= GetNextAlias()
Private cModCli		:= SuperGetMV("MV_GCPMCLI",,"LL\")

If TRepInUse()
	oReport:= ReportDef()
	oReport:PrintDialog()  // Imprime o Relat๓rio
Else
	Alert(STR0002)//"Este relat๓rio s๓ estแ disponํvel a partir da Release 4."
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDefบAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as defini็oes do relatorio                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCP - Gestใo de Compras Publicas                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef()
Local oReport  	:= nil
Local oCO1 	   	:= nil
Local cDesc		:= ""
Local oBreak	:= nil 

cDesc += STR0003 //"Este programa tem como objetivo imprimir relatorio "
cDesc += STR0004 //"de acordo com os parametros informados pelo usuario."

DEFINE REPORT oReport NAME "GCPR007" TITLE cTitulo PARAMETER cPerg ACTION {|oReport|RepGCP(oReport)} DESCRIPTION cDesc
		oReport:SetLandScape()    
		DEFINE SECTION oCO1 			OF oReport TITLE STR0005 TABLES "CO1","SB1","CO2","SC7","CN9","SC5" 
		DEFINE CELL NAME "CO1_CODEDT"  	OF oCO1 ALIAS "CO1" 
		DEFINE CELL NAME "CO1_NUMPRO"   OF oCO1 BLOCK {||  GCPR07EDT() } ALIGN CENTER SIZE 20 TITLE STR0008 LINE BREAK AUTO SIZE HEADER ALIGN CENTER//"Nบ Contrato" //ALIAS "CO1" 
		DEFINE CELL NAME "CO1_DTABER" 	OF oCO1 ALIAS "CO1" 
		DEFINE CELL NAME "B1_DESC"   	OF oCO1 ALIAS "SB1"
		DEFINE CELL NAME "VALOR"		OF oCO1 BLOCK {||  GCPR07TOT() }  PICTURE "@E 999,999,999.99"	TITLE STR0006 SIZE 14 HEADER ALIGN RIGHT //"VALOR"
		DEFINE CELL NAME "A2_NOME"		OF oCO1 BLOCK {||  GCPR07VENC() } ALIGN CENTER SIZE 15 TITLE STR0007 LINE BREAK AUTO SIZE HEADER ALIGN CENTER//"Vencedor"
		DEFINE CELL NAME "CONTRATO"		OF oCO1 BLOCK {||  GCPR07CONT() } ALIGN CENTER SIZE 15 TITLE STR0008 LINE BREAK AUTO SIZE HEADER ALIGN CENTER//"Nบ Contrato"
		DEFINE CELL NAME "DATA" 		OF oCO1 BLOCK {||  GCPR07DATA() } ALIGN CENTER SIZE 10 TITLE STR0009 LINE BREAK AUTO SIZE HEADER ALIGN CENTER//"Data Ped/Contr" 
		DEFINE CELL NAME "X" 			OF oCO1 BLOCK {||"      "} ALIGN CENTER SIZE 6 TITLE " " LINE BREAK AUTO SIZE HEADER ALIGN CENTER
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuebra por modalidade e m๊sณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DEFINE BREAK oBreak OF oCO1 WHEN {|| (cAliasQry)->CO1_MODALI+ cValtoChar(Month((cAliasQry)->CO1_DTABER)) } PAGE BREAK
		oBreak:OnBreak({|x,y| oReport:SetTitle(cTitulo + FDESC("SX5","LF"+(cAliasQry)->CO1_MODALI,"X5DESCRI()") ) })
		oCO1:OnPrintLine({|| oReport:SkipLine()})
		oReport:nFontBody := 8
		oCO1:SetAutoSize()		
Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRepGCP  บAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as defini็oes as informa็๕es do relatorio          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCP - Gestใo de Compras Publicas                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RepGCP(oReport)

Local oCO1 		:= oReport:Section(1)
Local cMesDe    := ""
Local cMesAte	:= ""

Pergunte(cPerg, .F.)  //Carrega as perguntas

cMesDe  := Right(DtoC(MV_PAR03),5)
cMesAte	:= Right(DtoC(MV_PAR04),5)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefini็ใo do Tํtuloณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTitulo := STR0010+cMesDe+STR0011+cMesAte+STR0012 //"Rela็ใo de licita็๕es por modalidade: Perํodo "##" at้ "##" Modalidade: "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณO uso do Distinct foi necessario pois a liga็ใo    ณ
//ณCO2_ITEM com C7_ITEM,C5_ITEM                       ณ
//ณnใo ้ possํvel pois os campos tem tamanho diferenteณ
//ณ000001      0001                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
BEGIN REPORT QUERY oCO1

BeginSql alias cAliasQry

SELECT DISTINCT   
	CO1_CODEDT	,
	CO1_NUMPRO	,
	CO1_DTABER	,
	CO1_MODALI	,
	CO2_ITEM	,
	CO2_CODPRO	,
	CO2_QUANT	,
	CO3_CODIGO	,
	CO3_LOJA	,
	CO3_VLUNIT	,
	CO3_TIPO	,
	CNC_NUMERO  ,
	C7_NUM		,
	C7_EMISSAO	,
	C5_NUM		,
	C5_EMISSAO		
FROM 
	%table:CO1% CO1 INNER JOIN %table:CO2% CO2 ON
		CO1_CODEDT		= CO2_CODEDT	AND
		CO1_NUMPRO		= CO2_NUMPRO	AND
		CO1_FILIAL		= %xfilial:CO1%	AND
		CO2_FILIAL		= %xfilial:CO2%	AND
		CO1.%NotDel%					AND
		CO2.%NotDel%
	LEFT JOIN  %table:CO3% CO3 ON
		CO2_CODEDT		= CO3_CODEDT	AND
		CO2_NUMPRO		= CO3_NUMPRO	AND
		CO2_CODPRO		= CO3_CODPRO	AND
		(CO3_CLASS		= '1'			OR
		CO3_CLAANT		= '1')          AND
		CO3_REVOGA		<> '1'			AND
		CO3_FILIAL		= %xfilial:CO3%	AND
		CO3.%NotDel%
	LEFT JOIN  %table:SC7% SC7 ON
		C7_CODED		= CO2_CODEDT	AND
		C7_NUMPR		= CO2_NUMPRO	AND
		C7_PRODUTO		= CO2_CODPRO	AND
		C7_FILIAL		= %xfilial:SC7%	AND
		C7_FORNECE		= CO3_CODIGO	AND
		C7_LOJA			= CO3_LOJA		AND
		SC7.%NotDel%
	LEFT JOIN  %table:SC5% SC5 ON
		C5_CODED		= CO2_CODEDT	AND
		C5_NUMPR		= CO2_NUMPRO	AND
		C5_FILIAL		= %xfilial:SC5%	AND
		C5_CLIENTE		= CO3_CODIGO	AND
		C5_LOJACLI		= CO3_LOJA		AND
		SC5.%NotDel%
	LEFT JOIN  %table:CNC% CNC ON
		CNC_CODIGO		= CO3_CODIGO	AND
		CNC_LOJA		= CO3_LOJA		AND
		CNC_CODED		= CO2_CODEDT	AND
		CNC_NUMPR		= CO2_NUMPRO	AND
		CNC_FILIAL		= %xfilial:CNC%	AND
		CNC.%NotDel%
WHERE
	CO1_ETAPA	IN ('PC','CO','PE','FV') AND					// Somente encerrados
	CO1_MODALI	>= %EXP:MV_PAR01%	AND
	CO1_MODALI	<= %EXP:MV_PAR02%	AND
	CO1_DTABER	>= %EXP:MV_PAR03%	AND
	CO1_DTABER	<= %EXP:MV_PAR04%	AND
	CO1_CODEDT	>= %EXP:MV_PAR05%	AND
	CO1_NUMPRO	>= %EXP:MV_PAR06%	AND
	CO1_CODEDT	<= %EXP:MV_PAR07%	AND
	CO1_NUMPRO	<= %EXP:MV_PAR08%	
ORDER BY
	CO1_MODALI	,
	CO1_DTABER	,
	CO1_CODEDT	,
	CO1_NUMPRO	
EndSql

END REPORT QUERY oCO1

TRPosition():New(oCO1, "SB1", 1, {|| xFilial("SB1") + (cAliasQry)->CO2_CODPRO }) //B1_FILIAL+B1_COD
TRPosition():New(oCO1, "SC7", 2, {|| xFilial("SC7") + (cAliasQry)->(CO2_CODPRO+CO3_CODIGO+CO3_LOJA+C7_NUM) }) //C7_FILIAL+C7_PRODUTO+C7_FORNECE+C7_LOJA+C7_NUM
TRPosition():New(oCO1, "CN9", 1, {|| xFilial("CN9") + (cAliasQry)->(CNC_NUMERO) }) //CN9_FILIAL+CN9_NUMERO+CN9_REVISA
TRPosition():New(oCO1, "SC5", 1, {|| xFilial("SC5") + (cAliasQry)->(C5_NUM) }) //C5_FILIAL+C5_NUM  

oReport:SetTitle(cTitulo + FDESC("SX5","LF"+(cAliasQry)->CO1_MODALI,"X5DESCRI()"))
oCO1:Print()	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCPR07VENC บAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o nome do vencedor                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCP - Gestใo de Compras Publicas                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCPR07VENC()
Local aArea := GetArea()
Local cRet	:= ""
Local cModCli := SuperGetMV("MV_GCPMCLI",,"LL\") 

If !(Empty( (cAliasQry)->CO3_CODIGO ))
    If (cAliasQry)->CO3_TIPO == "2" 
		If (cAliasQry)->CO1_MODALI $ cModCli
			cRet:= GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+(cAliasQry)->(CO3_CODIGO+CO3_LOJA)	,1) 
	    Else
	    	cRet:= GetAdvFVal("SA2","A2_NOME",xFilial("SA2")+(cAliasQry)->(CO3_CODIGO+CO3_LOJA)	,1)
	    EndIf
	 Else
	 	cRet:= GetAdvFVal("CO6",'CO6_NOME',xFilial("CO6")+(cAliasQry)->(CO3_CODIGO)	,1)
	 EndIf
EndIf

RestArea( aArea )
Return cRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCPR07CONT บAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o numero do contrato                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCP - Gestใo de Compras Publicas                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCPR07CONT()
Local aArea := GetArea()
Local cRet	:= ""
	
If !Empty((cAliasQry)->CNC_NUMERO) 
	cRet := (cAliasQry)->CNC_NUMERO
	cRet := Transform(cRet,PesqPict("CN9","CN9_NUMERO"))
Else
	cRet	:= "-"
EndIf

RestArea( aArea )
Return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCPR07DATA บAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a data do pedido ou do contrato                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCP - Gestใo de Compras Publicas                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCPR07DATA()
Local aArea := GetArea()
Local cRet	:= ""

Do Case
    Case !Empty((cAliasQry)->CNC_NUMERO) 
    	cRet 	:= dToc( GetAdvFVal("CN9","CN9_DTINIC",xFilial("CN9")+(cAliasQry)->CNC_NUMERO,1) )
    Case !Empty((cAliasQry)->C7_EMISSAO)
    	cRet	:= dToc((cAliasQry)->C7_EMISSAO)	    
    Case !Empty((cAliasQry)->C5_EMISSAO) 
    	cRet	:= dToc((cAliasQry)->C5_EMISSAO)
	Otherwise
		cRet	:= "-"
EndCase

RestArea( aArea )
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCPR07CONT บAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o numero do contrato                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCP - Gestใo de Compras Publicas                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCPR07EDT()
Local aArea := GetArea()
Local cRet	:= ""
	
If !Empty((cAliasQry)->CO1_NUMPRO) 
	cRet := (cAliasQry)->CO1_NUMPRO
Else
	cRet	:= "-"
EndIf

RestArea( aArea )
Return cRet
//-------------------------------------------------------------------
/*{Protheus.doc} GCPR07TOT
Calcula o valor do item conforme quantidade

@author Alex Egydio
@since 28/06/2013
@version P11.80
*/
//-------------------------------------------------------------------
Function GCPR07TOT()
Local aArea		:= {}
Local aSldItem	:= {}
Local nRet		:= (cAliasQry)->CO2_QUANT
aSldItem := {(cAliasQry)->CO1_CODEDT,(cAliasQry)->CO1_NUMPRO,(cAliasQry)->CO2_CODPRO}
GCPSldItem("3",aSldItem)

If	aSldItem[1]>0 .Or. (aSldItem[1]==0 .And. Empty((cAliasQry)->CNC_NUMERO))
	//-- Se nao efetuou a entrega total, abate a quantidade ja entregue (CO2_QUANT - C7_QUJE)
	//-- Se efetuou a entrega total devera permanecer com a quantidade original CO2_QUANT
	If	aSldItem[1]<nRet
		nRet -= aSldItem[1]
	EndIf		
	If	aSldItem[1]==0 .Or. (Empty((cAliasQry)->CNC_NUMERO) .And. Empty((cAliasQry)->C7_NUM))
		nRet := 0
	Else
		nRet := nRet * (cAliasQry)->CO3_VLUNIT
	EndIf
//-- Obtem o valor direto no contrato gerado pelo processo remanescente
ElseIf	!Empty((cAliasQry)->CNC_NUMERO)
	aArea := GetArea()
	BeginSQL Alias "SLDREM"

	SELECT CNB.CNB_VLTOT nVlTot
		
	FROM %table:CNB% CNB
		
	WHERE CNB.CNB_FILIAL = %xfilial:CNB%
		AND CNB.CNB_CONTRA = %exp:(cAliasQry)->CNC_NUMERO%
		AND CNB.CNB_PRODUT = %exp:(cAliasQry)->CO2_CODPRO%
		AND CNB.%NotDel%

	EndSql
	If	SLDREM->(Eof())
		nRet := 0
	Else
		nRet := SLDREM->nVlTot
	EndIf
	SLDREM->(DbCloseArea())
	RestArea(aArea)
EndIf

Return(nRet)