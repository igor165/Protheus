#include "oga262.ch"
#include "protheus.ch"


#DEFINE CRLF CHR(13)+CHR(10)
Static __oMBrowse 	:= Nil
Static __aCpsBrow	:= {}
Static __cTabPen	:= ""
Static __oArqTemp   := Nil
Static __lAutomato  := isBlind()
Static __lCalcSer	:= SuperGetMv('MV_AGRO044', , .F.) // Parametro de utilização de calculo de serviços incluindo romaneios atualizados
Static __lDataCalc	:= SuperGetMv('MV_AGRO046', , "1") // Parâmetro que indica qual data será utilizada para cálculo do serviço de armz (1 - Documento Fiscal | 2 - Romaneio)
Static __lRLS12123 	:= GetRpoRelease() >= "12.1.023"


/** {Protheus.doc} OGA262
Rotina para cálculo de serviços de armazenagem

@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
**/
Function OGA262()
	Local   aAreaAtu 	:= GetArea()
	Local   oReport	:= Nil
	Private cPergSX1	:= "OGA262"
	Private aMovServR := {}
	Private aMovServV := {}
	
	Private aServico  := {}
	Private _cTabela  := Space(4)
	Private _cCombo1  := ""
	Private lExibe    := .F.
	Private lVazio    := .T.
	Private lOKSelec  := .F.    
			
	If TRepInUse()

		If Pergunte( cPergSX1, .T. )			
			If ValType(MV_PAR19) != "U"
				If MV_PAR19 == 2
					OGA262BROW()
					If !lOKSelec
						Return
					EndIf
				EndIf
			EndIf	
			
			oReport:= ReportDef()
			oReport:PrintDialog()
		   
		EndIf
	EndIf
	
	RestArea( aAreaAtu )	
Return( Nil )

/** {Protheus.doc} ReportDef
Definição da impressão

@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	05/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function ReportDef()
	Local oReport		:= Nil
	Local oSection1	:= Nil
	
	oReport := TReport():New( "OGA262", STR0017, cPergSX1, {| oReport | PrintReport( oReport ) }, STR0018 )	//"Calculo de Serviços"##"Este relatório traz os cálculos dos movimentos de serviço" 
	
	oReport:SetTotalInLine( .f. )
	oReport:SetLandScape()
	
	oSection1 := TRSection():New( oReport, STR0019, ) 	//"Calculo de Retenção"
	
	TRCell():New( oSection1, "NKG_CODCTR"	,  	, STR0020 	, PesqPict('NKG', 'NKG_CODCTR')	, 20)	//"Contrato"
	TRCell():New( oSection1, "NKG_ITEMOV"	,  	, STR0021 	, PesqPict('NKG', 'NKG_ITEMOV')	, 20)	//"Seq.Calc"
	TRCell():New( oSection1, "NKG_CODROM"	,  	, STR0022 	, PesqPict('NKG', 'NKG_CODROM')	, 25)	//"Romaneio"
	TRCell():New( oSection1, "NKG_CODDEV"	,  	, STR0024 	, PesqPict('NKG', 'NKG_CODDEV')	, 15)	//"Dev."
	TRCell():New( oSection1, "NKG_LOJDEV"	,  	, STR0025 	, PesqPict('NKG', 'NKG_LOJDEV')	, 10)	//"Loj."
	TRCell():New( oSection1, "NKG_CODSAF"	, 	, STR0028 	, PesqPict('NKG', 'NKG_CODSAF')	, 20)	//"Safra"
	TRCell():New( oSection1, "NKG_CODPRO"	, 	, STR0029 	, PesqPict('NKG', 'NKG_CODPRO')	, 20)	//"Produto"
	TRCell():New( oSection1, "NKG_DOCSER"	,  	, STR0030 	, PesqPict('NKG', 'NKG_DOCSER')	, 10)	//"Ser"
	TRCell():New( oSection1, "NKG_DOCNUM"	,	, STR0031 	, PesqPict('NKG', 'NKG_DOCNUM')	, 25) 	//"Doc"
	TRCell():New( oSection1, "NKG_DOCEMI"	,  	, STR0032 	, "!@"	, 15)								//"Transação"
	TRCell():New( oSection1, "NKG_CODTSE"	,  	, STR0036 	, PesqPict('NKG', 'NKG_CODTSE')	, 15)	//"Tab.Ser"
	TRCell():New( oSection1, "NKG_CODDES"	,	, STR0039 	, PesqPict('NKG', 'NKG_CODDES')	, 15) 	//"Desp."
	TRCell():New( oSection1, "FATGER"	    ,	, STR0040 	, "!@", 10) 								//"FG"
	TRCell():New( oSection1, "PERCOB"	    ,	, STR0041 	, "!@", 5)									//"P"
	TRCell():New( oSection1, "NKG_QTDPER"	,	, STR0044 	, PesqPict('NKG', 'NKG_QTDPER')	, 20, , , "RIGHT", , "RIGHT" )	//"Qtd.Per."
	TRCell():New( oSection1, "NKG_QTDBAS"	,	, STR0034 	, PesqPict('NKG', 'NKG_QTDBAS')	, 20, , , "RIGHT", , "RIGHT" )	//"Qtd.Base"
	TRCell():New( oSection1, "NKG_PERRET"	,	, STR0045 	, PesqPict('NKG', 'NKG_PERRET')	, 10, , , "RIGHT", , "RIGHT" ) 	//"% Ret."
	TRCell():New( oSection1, "NKG_UMTAR"	,	, STR0047 	, PesqPict('NKG', 'NKG_UMTAR')	, 5)								//"UM"
	TRCell():New( oSection1, "NKG_QTDRET"	,	, STR0049 	, PesqPict('NKG', 'NKG_QTDRET')	, 20, , , "RIGHT", , "RIGHT" ) 	//"Qtd.Ret."
	
	oBreak1 := TRBreak():New( oSection1, "", STR0027, .f. )	//"Total"
	TRFunction():New(oSection1:Cell("NKG_QTDRET")	, Nil, "SUM" , oBreak1, , , , .f., .f. )
	
	oSection2 := TRSection():New( oReport, STR0026, ) 	//"Calculo de Serviços"
	
	TRCell():New( oSection2, "NKG_CODCTR"	,  	, STR0020 	, PesqPict('NKG', 'NKG_CODCTR')	, 20)	//"Contrato"
	TRCell():New( oSection2, "NKG_ITEMOV"	,  	, STR0021 	, PesqPict('NKG', 'NKG_ITEMOV')	, 20)	//"Seq.Calc"
	TRCell():New( oSection2, "NKG_CODROM"	,  	, STR0022 	, PesqPict('NKG', 'NKG_CODROM')	, 25)	//"Romaneio"
	TRCell():New( oSection2, "NKG_CODDEV"	,  	, STR0024 	, PesqPict('NKG', 'NKG_CODDEV')	, 15)	//"Dev."
	TRCell():New( oSection2, "NKG_LOJDEV"	,  	, STR0025 	, PesqPict('NKG', 'NKG_LOJDEV')	, 10)	//"Loj."
	TRCell():New( oSection2, "NKG_CODSAF"	, 	, STR0028 	, PesqPict('NKG', 'NKG_CODSAF')	, 20)	//"Safra"
	TRCell():New( oSection2, "NKG_CODPRO"	, 	, STR0029 	, PesqPict('NKG', 'NKG_CODPRO')	, 20)	//"Produto"
	TRCell():New( oSection2, "NKG_DOCSER"	,  	, STR0030 	, PesqPict('NKG', 'NKG_DOCSER')	, 10)	//"Ser"
	TRCell():New( oSection2, "NKG_DOCNUM"	,	, STR0031 	, PesqPict('NKG', 'NKG_DOCNUM')	, 25) 	//"Doc"
	TRCell():New( oSection2, "NKG_DOCEMI"	,  	, STR0032 	, "!@"	, 15)								//"Transação"
	TRCell():New( oSection2, "NKG_CODTSE"	,  	, STR0036 	, PesqPict('NKG', 'NKG_CODTSE')	, 15)	//"Tab.Ser"
	TRCell():New( oSection2, "NKG_CODDES"	,	, STR0039 	, PesqPict('NKG', 'NKG_CODDES')	, 15) 	//"Desp."
	TRCell():New( oSection2, "FATGER"	    ,	, STR0040 	, "!@", 10) 								//"FG"
	TRCell():New( oSection2, "PERCOB"	    ,	, STR0041 	, "!@", 5)									//"P"
	TRCell():New( oSection2, "NKG_QTDPER"	,	, STR0044 	, PesqPict('NKG', 'NKG_QTDPER')	, 20, , , "RIGHT", , "RIGHT" )	//"Qtd.Per."
	TRCell():New( oSection2, "NKG_QTDBAS"	,	, STR0034 	, PesqPict('NKG', 'NKG_QTDBAS')	, 20, , , "RIGHT", , "RIGHT" ) 	//"Qtd.Base"
	TRCell():New( oSection2, "NKG_VALTAR"	,	, STR0046 	, PesqPict('NKG', 'NKG_VALTAR')	, 20, , , "RIGHT", , "RIGHT" ) 	//"Val.Tar."
	TRCell():New( oSection2, "NKG_UMTAR"	,	, STR0047 	, PesqPict('NKG', 'NKG_UMTAR')	, 5)								//"UM"
	TRCell():New( oSection2, "NKG_VALSER"	,	, STR0048 	, PesqPict('NKG', 'NKG_VALSER')	, 20, , , "RIGHT", , "RIGHT" ) 	//"Val.Ser."
	
	oBreak2 := TRBreak():New( oSection2, "", STR0027, .f. )	//"Total"
	TRFunction():New(oSection2:Cell("NKG_VALSER")	, Nil, "SUM" , oBreak2, , , , .f., .f. )
	
Return( oReport )

/** {Protheus.doc} PrintReport
Rotina para impressão do cálculo de serviços

@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	05/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function PrintReport( oReport )
	Local oS1		:= oReport:Section( 1 )
	Local oS2		:= oReport:Section( 2 )
	Local nCount  := 0
	
	If oReport:Cancel()
		Return( Nil )
	EndIf
	
	// Realiza o calculo dos serviços
	OGA262CALC( {}, , , , .T., cPergSX1 )
	
	/************************************************************************************/
	/*******                                                                      *******/
	/*******                    IMPRIME CALCULO DE RETENÇÃO                       *******/
	/*******                                                                      *******/
	/************************************************************************************/
	
	If Len(aMovServR) > 0
		oS1:Init()
		oReport:PrintText(STR0019,(oReport:Row()),1100,CLR_BLACK) 	//"Calculo de Retenção"
		oReport:IncRow(100)
		For nCount := 1 to Len(aMovServR)
			
			oS1:Cell( "NKG_CODCTR"):SetValue( aMovServR[ nCount,  1])
			oS1:Cell( "NKG_ITEMOV"):SetValue( aMovServR[ nCount,  2]) 
			oS1:Cell( "NKG_CODROM"):SetValue( aMovServR[ nCount,  3]) 
			oS1:Cell( "NKG_CODDEV"):SetValue( aMovServR[ nCount,  4]) 
			oS1:Cell( "NKG_LOJDEV"):SetValue( aMovServR[ nCount,  5]) 
			oS1:Cell( "NKG_CODSAF"):SetValue( aMovServR[ nCount,  6]) 
			oS1:Cell( "NKG_CODPRO"):SetValue( aMovServR[ nCount,  7]) 
			oS1:Cell( "NKG_DOCSER"):SetValue( aMovServR[ nCount,  8])
			oS1:Cell( "NKG_DOCNUM"):SetValue( aMovServR[ nCount,  9])
			oS1:Cell( "NKG_DOCEMI"):SetValue( FormatDate(aMovServR[ nCount, 10]) )
			oS1:Cell( "NKG_CODTSE"):SetValue( aMovServR[ nCount, 11])
			oS1:Cell( "NKG_CODDES"):SetValue( aMovServR[ nCount, 12])
			oS1:Cell( "FATGER"):SetValue( GetFatoGer((aMovServR[ nCount, 13])))
			oS1:Cell( "PERCOB"):SetValue( GetPerCob(aMovServR[ nCount, 14]))
			oS1:Cell( "NKG_QTDPER"):SetValue( aMovServR[ nCount, 15])
			oS1:Cell( "NKG_QTDBAS"):SetValue( aMovServR[ nCount, 16])
			oS1:Cell( "NKG_PERRET"):SetValue( aMovServR[ nCount, 17])
			oS1:Cell( "NKG_UMTAR" ):SetValue( aMovServR[ nCount, 18])
			oS1:Cell( "NKG_QTDRET"):SetValue( aMovServR[ nCount, 19])
			
			oS1:PrintLine( )
			
		Next nCount
		oS1:Finish()
	Endif	
	
	/************************************************************************************/
	/*******                                                                      *******/
	/*******                    IMPRIME CALCULO DE SERVIÇOS                       *******/
	/*******                                                                      *******/
	/************************************************************************************/
	
	If Len(aMovServV) > 0 
		oS2:Init()	
		oReport:PrintText(STR0026,(oReport:Row()),1100,CLR_BLACK)	//"Calculo de Serviços"
		oReport:IncRow(100) 
		For nCount := 1 to Len(aMovServV)
			
			oS2:Cell( "NKG_CODCTR"):SetValue( aMovServV[ nCount,  1])
			oS2:Cell( "NKG_ITEMOV"):SetValue( aMovServV[ nCount,  2]) 
			oS2:Cell( "NKG_CODROM"):SetValue( aMovServV[ nCount,  3]) 
			oS2:Cell( "NKG_CODDEV"):SetValue( aMovServV[ nCount,  4]) 
			oS2:Cell( "NKG_LOJDEV"):SetValue( aMovServV[ nCount,  5]) 
			oS2:Cell( "NKG_CODSAF"):SetValue( aMovServV[ nCount,  6]) 
			oS2:Cell( "NKG_CODPRO"):SetValue( aMovServV[ nCount,  7]) 
			oS2:Cell( "NKG_DOCSER"):SetValue( aMovServV[ nCount,  8])
			oS2:Cell( "NKG_DOCNUM"):SetValue( aMovServV[ nCount,  9])
			oS2:Cell( "NKG_DOCEMI"):SetValue( FormatDate(aMovServV[ nCount, 10]) )
			oS2:Cell( "NKG_CODTSE"):SetValue( aMovServV[ nCount, 11])
			oS2:Cell( "NKG_CODDES"):SetValue( aMovServV[ nCount, 12])
			oS2:Cell( "FATGER"):SetValue( GetFatoGer(aMovServV[ nCount, 13]))
			oS2:Cell( "PERCOB"):SetValue( GetPerCob(aMovServV[ nCount, 14]))
			oS2:Cell( "NKG_QTDPER"):SetValue( aMovServV[ nCount, 15])
			oS2:Cell( "NKG_QTDBAS"):SetValue( aMovServV[ nCount, 16])
			oS2:Cell( "NKG_VALTAR"):SetValue( aMovServV[ nCount, 17])
			oS2:Cell( "NKG_UMTAR" ):SetValue( aMovServV[ nCount, 18])
			oS2:Cell( "NKG_VALSER"):SetValue( aMovServV[ nCount, 19])
			
			oS2:PrintLine( )
			
		Next nCount
		oS2:Show()
		oS2:Finish()
	Endif	
	
Return( )

/** {Protheus.doc} OGA262CALC
Rotina para cálculo de tarifas
@param:	aParams	- array com as perguntas do SX1 pré-preenchidas. Formato: { {"MV_PAR01", "VALOR"} , {"MV_PAR02", 99} }
							MV_PAR01	//"Contrato De"
							MV_PAR02	//"Contrato Até"	
							MV_PAR03	//"Entidade De"
							MV_PAR04	//"Loja De"
							MV_PAR05	//"Entidade Até"
							MV_PAR06	//"Loja Até"
							MV_PAR07	//"Tabela Tarifas de"
							MV_PAR08	//"Tabela Tarifas até"
							MV_PAR09	//"Tipo Despesa de"
							MV_PAR10	//"Tipo Despesa até"
							MV_PAR11	//"Produto De"
							MV_PAR12	//"Produto Ate"
							MV_PAR13	//"Safra De"
							MV_PAR14	//"Safra Ate"
							MV_PAR15	//"Data Movimento de"
							MV_PAR16	//"Data Movimento Ate"
							MV_PAR17	//"Doc. Origem"
							MV_PAR18	//"Serie Origem"
@author: 	Marlon Richard Trettin
@since: 	21/07/2015
@Uso: 		SIGAAGR 
*/
Function OGA262CALC( aParams, nQtSimul, dDTSimul, cTCSimul, lGeraArr, cPerg )
	Local oProcess
	Local bRotina  	:= { |lEnd| fProcCalc( nQtSimul, dDTSimul, cTCSimul, lGeraArr, @oProcess, @lEnd ) }
	Private cPergSX1	:= iIf( Empty( cPerg ), "OGA262", cPerg )
	//Private cMVPAR	:= ""
	
	If ! Empty( aParams )
		
		// Carrega as perguntas mas não mostra a tela
		Pergunte( cPergSX1, .F. )
		
		//atualiza os campos do perguntes com array vindo por parâmetro
		SetMVValue(cPergSX1, "MV_PAR01", aParams[1][2])  //"Contrato De"  
		SetMVValue(cPergSX1, "MV_PAR02", aParams[2][2])  //"Contrato Até"
		SetMVValue(cPergSX1, "MV_PAR03", aParams[3][2])  //"Entidade De"
		SetMVValue(cPergSX1, "MV_PAR04", aParams[4][2])  //"Loja De"
		SetMVValue(cPergSX1, "MV_PAR05", aParams[5][2])  //"Entidade Até"
		SetMVValue(cPergSX1, "MV_PAR06", aParams[6][2])  //"Loja Até"
		SetMVValue(cPergSX1, "MV_PAR07", aParams[7][2])  //"Tabela Tarifas de"
		SetMVValue(cPergSX1, "MV_PAR08", aParams[8][2])  //"Tabela Tarifas até"
		SetMVValue(cPergSX1, "MV_PAR09", aParams[9][2])  //"Tipo Despesa de"
		SetMVValue(cPergSX1, "MV_PAR10", aParams[10][2]) //"Tipo Despesa até"
		SetMVValue(cPergSX1, "MV_PAR11", aParams[11][2]) //"Produto De"
		SetMVValue(cPergSX1, "MV_PAR12", aParams[12][2]) //"Produto Ate"
		SetMVValue(cPergSX1, "MV_PAR13", aParams[13][2]) //"Safra De"
		SetMVValue(cPergSX1, "MV_PAR14", aParams[14][2]) //"Safra Ate"
		
		If VALTYPE(aParams[15][2]) == "D"
			SetMVValue(cPergSX1, "MV_PAR15", aParams[15][2]) //"Data Movimento de"
		Else
			SetMVValue(cPergSX1, "MV_PAR15", CTOD(aParams[15][2])) //"Data Movimento de"
		EndIf
		
		If VALTYPE(aParams[16][2]) == "D"	
			SetMVValue(cPergSX1, "MV_PAR16", aParams[16][2]) //"Data Movimento Ate"
		Else	
			SetMVValue(cPergSX1, "MV_PAR16", CTOD(aParams[16][2])) //"Data Movimento Ate"
		EndIf
		
		If !__lAutomato

			// Abre a tela de parâmetros de perguntas
			If ! Pergunte( cPergSX1, .T. ) 
				Return( .F. )
			EndIf
		Else
			SetMVValue(cPergSX1, "MV_PAR17", "         ") //Docto. Origem?
			SetMVValue(cPergSX1, "MV_PAR18", "         ") //Serie Origem?
			SetMVValue(cPergSX1, "MV_PAR19", 0) 		  //Exibir Contratos Seleção?
		EndIf
	EndIf
		
	// Executa a função de cálculo
    If !__lAutomato
        oProcess := MsNewProcess():New( bRotina, STR0035, STR0033, .F. )  //"Cálculo de Serviços"###"Calculando Tarifa..."
        oProcess:Activate()
    Else
        Eval(bRotina)
    EndIf
		
Return( .T. )

/** {Protheus.doc} fProcCalc
Rotina de processamento do cálculo de tarifas

@author: 	Bruna Fagundes Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fProcCalc( nQtSimul, dDTSimul, cTCSimul, lGeraArr, oProcess, lEnd )
	Local cAliasNJR    := GetNextAlias()
	Local cAliasNJM    := GetNextAlias()
	Local dInicioMov   := MV_PAR15
	Local dFinalMov    := MV_PAR16
	Local cDocOri      := MV_PAR17 
	Local cSerOri      := MV_PAR18
	Local dFirstEntC   := ""
	Local cFiltroNJR   := ""
	Local cFiltroNKQ   := ""
	lOCAL lSimula      := .f.
	Local lGeraNKG     := .f.
	Local aDRetSimul   := {}
	Local nRecCount    := 0

	cFiltroNJR += " AND NJR_CODCTR >= '" + iIf( Empty( MV_PAR01 ), Replicate( " ", TamSX3("NJR_CODCTR")[1] ), MV_PAR01 ) + "'" 
	cFiltroNJR += " AND NJR_CODCTR <= '" + iIf( Empty( MV_PAR02 ), Replicate( "Z", TamSX3("NJR_CODCTR")[1] ), MV_PAR02 ) + "'"
	cFiltroNJR += " AND NJR_CODENT >= '" + iIf( Empty( MV_PAR03 ), Replicate( " ", TamSX3("NJR_CODENT")[1] ), MV_PAR03 ) + "'"
	cFiltroNJR += " AND NJR_CODENT <= '" + iIf( Empty( MV_PAR05 ), Replicate( "Z", TamSX3("NJR_CODENT")[1] ), MV_PAR05 ) + "'"
	cFiltroNJR += " AND NJR_LOJENT >= '" + iIf( Empty( MV_PAR04 ), Replicate( " ", TamSX3("NJR_LOJENT")[1] ), MV_PAR04 ) + "'"
	cFiltroNJR += " AND NJR_LOJENT <= '" + iIf( Empty( MV_PAR06 ), Replicate( "Z", TamSX3("NJR_LOJENT")[1] ), MV_PAR06 ) + "'"
	cFiltroNJR += " AND NJR_CODTSE >= '" + iIf( Empty( MV_PAR07 ), Replicate( " ", TamSX3("NJR_CODTSE")[1] ), MV_PAR07 ) + "'"
	cFiltroNJR += " AND NJR_CODTSE <= '" + iIf( Empty( MV_PAR08 ), Replicate( "Z", TamSX3("NJR_CODTSE")[1] ), MV_PAR08 ) + "'"
	cFiltroNJR += " AND NJR_CODPRO >= '" + iIf( Empty( MV_PAR11 ), Replicate( " ", TamSX3("NJR_CODPRO")[1] ), MV_PAR11 ) + "'"
	cFiltroNJR += " AND NJR_CODPRO <= '" + iIf( Empty( MV_PAR12 ), Replicate( "Z", TamSX3("NJR_CODPRO")[1] ), MV_PAR12 ) + "'"
	cFiltroNJR += " AND NJR_CODSAF >= '" + iIf( Empty( MV_PAR13 ), Replicate( " ", TamSX3("NJR_CODSAF")[1] ), MV_PAR13 ) + "'"
	cFiltroNJR += " AND NJR_CODSAF <= '" + iIf( Empty( MV_PAR14 ), Replicate( "Z", TamSX3("NJR_CODSAF")[1] ), MV_PAR14 ) + "'"	
	cFiltroNJR := "%" + cFiltroNJR + "%"	 
	
	cFiltroNKQ += " AND NKQ_CODDES >= '" + iIf( Empty( MV_PAR09 ), Replicate( " ", TamSX3("NKQ_CODDES")[1] ), MV_PAR09 ) + "'" 
	cFiltroNKQ += " AND NKQ_CODDES <= '" + iIf( Empty( MV_PAR10 ), Replicate( "Z", TamSX3("NKQ_CODDES")[1] ), MV_PAR10 ) + "'"		
	cFiltroNKQ := "%" + cFiltroNKQ + "%"	 	
	
	//Query Contratos
	BeginSql Alias cAliasNJR
		SELECT *
		  FROM %Table:NJR% NJR
		 WHERE NJR.%notDel%
		   AND NJR_FILIAL  = %XFilial:NJR%
		   AND NJR_TIPO    = '3' //Depósito de 3
		   AND NJR_STATUS  <> 'F'
		   %exp:cFiltroNJR% 
	EndSQL
	
	DbSelectArea( cAliasNJR )
	Count to nRecCount
    If !__lAutomato
	    oProcess:SetRegua1( nRecCount )
    EndIf

	(cAliasNJR)->( DbGoTop() )
	While  ! (cAliasNJR)->( Eof() )  
		
		If !__lAutomato
            oProcess:IncRegua1( OemToAnsi( STR0033 + " " + STR0020 ) +" ["+ (cAliasNJR)->NJR_CODCTR +"]" ) //"Calculando Tarifa..."##" Contrato"##" [999999]" 
        EndIf
		
		If Empty( (cAliasNJR)->NJR_CODTSE )
			(cAliasNJR)->( dbSkip() )
			Loop
		Endif

        If __lDataCalc == "1"
            cWhere := "%AND NJM.NJM_DTRANS <= '" + dtos(dFinalMov)+"'%"
        else
            cWhere := "%AND NJJ.NJJ_DATA <= '" + dtos(dFinalMov)+"'%"
        EndIf

		If  ! __lCalcSer 
			BeginSql Alias cAliasNJM
				SELECT NJM.*, NJJ.*
				FROM %Table:NJM% NJM
				INNER JOIN %Table:NJJ% NJJ 
					ON NJJ.%notDel%
				AND NJJ.NJJ_FILIAL  = %xFilial:NJJ%
				AND NJJ.NJJ_CODROM  = NJM.NJM_CODROM
				AND NJJ.NJJ_STATUS  = '3' //Confirmado
				AND NJJ.NJJ_TIPENT <> '3'
				WHERE NJM.%notDel%
				AND NJM.NJM_FILIAL  = %XFilial:NJM% 
				AND NJM.NJM_CODCTR  = %exp:(cAliasNJR)->NJR_CODCTR%
				AND NJM.NJM_QTDFCO  > 0 	
				%exp:cWhere%	
				ORDER BY NJM.NJM_DTRANS, NJM.NJM_CODROM 	      
			EndSQL
        Else
			BeginSql Alias cAliasNJM
				SELECT NJM.*, NJJ.*
				FROM %Table:NJM% NJM
				INNER JOIN %Table:NJJ% NJJ 
					ON NJJ.%notDel%
				AND NJJ.NJJ_FILIAL  = %xFilial:NJJ%
				AND NJJ.NJJ_CODROM  = NJM.NJM_CODROM
				AND NJJ.NJJ_STATUS  = '3' //Confirmado 
				OR  NJJ.NJJ_STATUS  = '2' //Atualizado
				AND NJJ.NJJ_TIPENT <> '3'
				WHERE NJM.%notDel%
				AND NJM.NJM_FILIAL  = %XFilial:NJM% 
				AND NJM.NJM_CODCTR  = %exp:(cAliasNJR)->NJR_CODCTR%
				AND NJM.NJM_QTDFCO  > 0 	
				%exp:cWhere%	
				ORDER BY NJM.NJM_DTRANS, NJM.NJM_CODROM 	      
			EndSQL
		EndIf
//			 ORDER BY NJM.NJM_CODROM, NJM.NJM_CODCTR 	serviços      
		dbSelectArea( cAliasNJM )
		Count to nRecCount
		If !__lAutomato
            oProcess:SetRegua2( nRecCount )
        EndIf
		
		(cAliasNJM)->( DbGoTop() )
		If ! (cAliasNJM)->( Eof() ) 
			If __lDataCalc == "1"
                dFirstEntC := (cAliasNJM)->NJM_DTRANS
            else
                dFirstEntC := (cAliasNJM)->NJJ_DATA
            EndIf
		Endif		   
		
		If !Empty(nQtSimul) .and. !Empty(dDTSimul) .and. cTCSimul $ "0|2"
			lSimula  := .T. 
			lGeraNKG := .T.
		endif
		
		// percorrer os registros de comercialização para o contrato; deve ignorar os que sejam do tipo 3 = Retenção 				
		While ! (cAliasNJM)->( Eof() )   
			
			If !__lAutomato 
                oProcess:IncRegua2( OemToAnsi( STR0051 + "... " + STR0022 ) +" ["+ (cAliasNJM)->NJM_CODROM +"]" ) //"Processando"##"... "##"Romaneio"##" [999999]" 
            EndIf
			OGA262TARIF( cAliasNJR, cAliasNJM, dFirstEntC, dInicioMov, dFinalMov, cFiltroNKQ, lGeraArr, lSimula, cDocOri, cSerOri )
			
			(cAliasNJM)->( dbSkip() )
		EndDo //Fim laço NJM	
		(cAliasNJM)->( DbCloseArea() )
		
		// verificar se tem simulação, nesta situação será o cálculo de um contrato por vez
		If ! Empty(nQtSimul) .and. ! Empty(dDTSimul) .and. cTCSimul $ "0|2"
			//Buscar notas de origem com saldo para retornar e guardar na aDRetSimul 
			aDRetSimul := fSelecNFOri( cAliasNJR, nQtSimul )
			
			If Len( aDRetSimul ) > 0 
				lGeraNKG   := .T.
				If !__lAutomato
                    oProcess:SetRegua2( 0 )
                    oProcess:IncRegua2( OemToAnsi( STR0042 ) ) //"Simulando Cálculo de Serviços..." 
                EndIf
				
				aDRetSimul := A262SIMUL(cAliasNJR, nQtSimul, dDTSimul, cTCSimul, dFirstEntC, dInicioMov, dFinalMov, cFiltroNKQ, lGeraArr, lGeraNKG, aDRetSimul )
			EndIf
		EndIf
		
		(cAliasNJR)->( dbSkip() )		
	EndDo //Fim laço NJR
	(cAliasNJR)->( dbCloseArea() )
	
Return ( .T. )


/** {Protheus.doc} OGA262TARIF
Rotina para calculo das tarifas sobre serviço

@param: 	pcAliasNJR    -> Recebe ponteiro da NJR Contrato
			pcAliasNJM    -> Recebe ponteiro da NJM e NJJ Comercialização Romaneio e Romaneio 
			dFirstEnt		-> Recebe data da primeira entrega para o contrato 
			dInicioMov		-> Recebe data inicio seleção
			dFinalMov		-> Recebe data final  seleção 
			cFiltroSer		-> Recebe filtros para a Tabela NKQ Tarifas de Serviços 
			lGeraArr		-> Receber flag indica se deve gerar array para impressão
			lSimula		-> Receber flag indica se está em uma simulação
@return:	NIL
@author: 	Bruna Fagundes Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA262TARIF( pcAliasNJR, pcAliasNJM, dFirstEnt, dInicioMov, dFinalMov, cFiltroSer, lGeraArr, plSimula, cDocOri, cSerOri )
	Local cAliasNKG    := GetNextAlias()
	Local cAliasNKQ    := GetNextAlias()
	Local cAliasSD2    := GetNextAlias()
	
	Local dLastCalc 
	Local dNextCal
	local dDTrans
	Local dIniPerCalc
	Local dFimCaren
	Local dIni1aEntr
	Local nTarifa       := 0.00
	Local nTotRom       := 0.00
	Local nPesoRom      := 0
	Local nFatMul       := 1
	Local nPer          := 0
	Local nValTar       := 0
	Local aCalcPer      := {}
	Local nQuant        := 0.00
	Local nX            := 0 
	Local nS            := 0
	Local lPerVal       := .T.
	Local qtPerAnt      := 0.00
	Local aNotasRet     := {}
	Local nVezes        := 0
	Local cTabela       := (pcAliasNJR)->NJR_CODTSE  
	Local cCodProdut    := (pcAliasNJR)->NJR_CODPRO 
    Local dBaseCalcOrig := nil
    Local dBaseCalc     := nil
    Local lNfRet        := .F.
	Local nRetPE        := 0
 
	
	Private aPeriodos  := {}
	Private cEntDev    := ""
	Private cLojDev    := ""
	
	Default cDocOri	:= Space( TamSX3("NJM_DOCNUM")[1] )
	Default cSerOri	:= Space( TamSX3("NJM_DOCSER")[1] )
	
	If ValType(MV_PAR19) != "U"
		If IsInCallStack("OGA262") .And. MV_PAR19 == 2 //Mostra dados cálculo
			cTabela := IIf(_cCombo1 == '2', _cTabela, (pcAliasNJR)->NJR_CODTSE  )
		EndIf
	Else
		cTabela := (pcAliasNJR)->NJR_CODTSE
	EndIf	

    If __lDataCalc == "1" //documento fiscal
        dBaseCalc := (pcAliasNJM)->NJM_DTRANS
    else    
        dBaseCalc := (pcAliasNJM)->NJJ_DATA
    EndIf
		
	BeginSql Alias cAliasNKQ
		SELECT *
		  FROM %Table:NKQ% NKQ
		 WHERE NKQ.%notDel%
		   AND NKQ_FILIAL  = %xFilial:NKQ%
		   AND NKQ_CODTSE  = %exp:cTabela%
		   AND NKQ_ATIVO   = '1'
		   %exp:cFiltroSer% 
		 ORDER BY NKQ_ORDEM		   
	EndSQL	
	
	DbSelectArea( cAliasNKQ )
	(cAliasNKQ)->( DbGoTop() )	
	While ! (cAliasNKQ)->( Eof() ) 
		
		/* NKQ_FATGER			   0= Entrada				1= Saída		      2= Saldo  */
		
		If   ( ( (cAliasNKQ)->NKQ_CONFIS = '1' .And. (pcAliasNJM)->NJJ_TIPENT = '0' ); 		//NJJ_TIPENT 0=Fisico
		  .Or. ( (cAliasNKQ)->NKQ_CONSIM = '1' .And. (pcAliasNJM)->NJJ_TIPENT = '2' ) ); 	//NJJ_TIPENT 2=Simbolico
		.And.( ( (cAliasNKQ)->NKQ_FATGER = '0' .And. (pcAliasNJM)->NJJ_TIPO   = '3' );		//NJJ_TIPO 3= (E) Entrada para Deposito
		  .Or. ( (cAliasNKQ)->NKQ_FATGER = '1' .And. (pcAliasNJM)->NJJ_TIPO   = '6' );		//NJJ_TIPO 6= (S) Devolucao de Deposito  
		  .Or. ( (cAliasNKQ)->NKQ_FATGER = '2' .And. (pcAliasNJM)->NJJ_TIPO   = '3' ) )		//NJJ_TIPO 3= (E) Entrada para Deposito
			
			/* verificar qual o último movimento para a tarifa na NKG e salvar a maior data encontrada em uma variável */
			
			BeginSql Alias cAliasNKG
				SELECT MAX(NKG_DATFIM) as dQLastCalc
				  FROM %Table:NKG% NKG
				 WHERE NKG.%notDel%
				   AND NKG_FILIAL = %XFilial:NKG%
				   AND NKG_CODROM = %exp:(pcAliasNJM)->NJM_CODROM%
				   AND NKG_ITEROM = %exp:(pcAliasNJM)->NJM_ITEROM%
				   AND NKG_CODTSE = %exp:(cAliasNKQ)->NKQ_CODTSE%
				   AND NKG_ITETSE = %exp:(cAliasNKQ)->NKQ_ITETSE%
			EndSQL
			
			dbSelectArea( cAliasNKG )
			(cAliasNKG)->(dbGoTop())
			
			dLastCalc := Nil		
			if 	!empty(( cAliasNKG )->dQLastCalc)
				dLastCalc := ( cAliasNKG )->dQLastCalc
			endif				
			(cAliasNKG)->( dbCloseArea() )
			
			/* se a tarifa já tiver calculada, nao é necessário continuar, 
			   Exceção: só quando o fator gerador for 2-Saldo, e a data fim for maior que o último cálculo */
//			dbSelectArea( cAliasNKQ )
			
			If .Not. ( ! Empty(dLastCalc) .And. ( dLastCalc >= DtoS( dFinalMov ) .Or. (cAliasNKQ)->NKQ_FATGER $ "0|1" ) )    
			
				If ValType(MV_PAR19) != "U"
					If IsInCallStack("OGA262") .And. MV_PAR19 == 2 //Mostra dados cálculo
					
						cDesc := ''
						dbSelectArea('NJT')
						dbSetOrder(1)
						If dbSeek(xFilial('NJT')+ (cAliasNKQ)->NKQ_CODDES )
							cDesc := AllTrim(NJT->NJT_DESCRI)	
						EndIf

						DbSelectArea((__cTabPen))
						DbGoTop()
						If DbSeek((pcAliasNJR)->NJR_CODCTR)
						
							//Mostra dados para seleção antes de realizar o cálculo
							If lExibe
							 	If (__cTabPen)->CONTRATO == (pcAliasNJR)->NJR_CODCTR		
				
							 		If (nPos := aScan(aServico, { |x| x[1]+x[2] == (pcAliasNJR)->NJR_CODCTR + cDesc } ) ) == 0
										RecLock((__cTabPen),.F.)
											(__cTabPen)->SERVICO	:= Alltrim( (__cTabPen)->SERVICO ) + '/' +  cDesc
										MsUnlock()
										aAdd(aServico, { (pcAliasNJR)->NJR_CODCTR,  cDesc } )
									EndIf
								EndIF
							EndIf
					    	IF (__cTabPen)->MARK <>  "1" .Or. lExibe
					    		(cAliasNKQ)->( DbSkip() )
					    		Loop
					    	EndIf
					    ElseIf .NOT. (__cTabPen)->CONTRATO == (pcAliasNJR)->NJR_CODCTR
				    		
				    		If lExibe
								RecLock((__cTabPen),.T.)
								    (__cTabPen)->MARK	    :=  "1" //start marcado, execto quando já estava desmarcado 	
									(__cTabPen)->CONTRATO	:= (pcAliasNJR)->NJR_CODCTR
									(__cTabPen)->CODENT	    := (pcAliasNJR)->NJR_CODENT
									(__cTabPen)->LOJENT	    := (pcAliasNJR)->NJR_LOJENT
									(__cTabPen)->NOMENT	    := POSICIONE('NJ0',1,XFILIAL('NJ0')+(pcAliasNJR)->NJR_CODENT+(pcAliasNJR)->NJR_LOJENT,'NJ0_NOME') 
									(__cTabPen)->TABELA	    := (pcAliasNJR)->NJR_CODTSE
									(__cTabPen)->SERVICO	:= AllTrim(cDesc)
									aAdd(aServico, { (pcAliasNJR)->NJR_CODCTR,  cDesc } )
								MsUnlock()
								lVazio := .F.
							EndIf
							(cAliasNKQ)->( DbSkip() )
							Loop
					    EndIF
				    EndIF
				EndIf    			    
			    

                ////////////////////////////////////////////////////////////
				/// FATO GERADOR = ENTRADA                               ///
				////////////////////////////////////////////////////////////
				If (cAliasNKQ)->NKQ_FATGER = "0" //0=Entrada
					
                    cEntDev := (pcAliasNJR)->NJR_CODENT
					cLojDev := (pcAliasNJR)->NJR_LOJENT
					
					If StoD( dBaseCalc )  < dInicioMov //data movimento de
						(cAliasNKQ)->( DbSkip() )
						Loop
					EndIf	 

					// Se o parametro foi marcado para calcular somente para uma Nota fiscal
					If ! Empty( cDocOri ) .And. ! Empty( cSerOri )
						If (pcAliasNJM)->( NJM_DOCNUM + NJM_DOCSER ) <> cDocOri + cSerOri
							(cAliasNKQ)->( DbSkip() )
							Loop
						EndIf
					EndIf
					
					// Calcular a data fim conforme a periodicidade							
					aCalcPer := fCalcPer( cAliasNKQ, , dBaseCalc, , 1, dFinalMov )		
					
					dNextCal := aCalcPer[1]
					
					If dNextCal > dFinalMov
						// --- ir para próximo registro NKQ
						(cAliasNKQ)->( DbSkip() )
						Loop
					Endif			
					
					// verificar se tem tarifa por resultado de análise
					nTarifa := fTarAnalise( cAliasNKQ, (pcAliasNJM)->NJM_CODROM )
					
					If nTarifa = 0
						If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor 
							nTarifa := (cAliasNKQ)->NKQ_VALTAR
						Else
							nTarifa := (cAliasNKQ)->NKQ_PERRET
						EndIf
					EndIf
					
					If  (cAliasNKQ)->NKQ_FATMUL = '0'  // 0-Peso
						If (cAliasNKQ)->NKQ_TIPPES = '0'  // 0-Líquido
							nPesoRom := (pcAliasNJM)->NJM_QTDFCO
						Else
							/* neste caso é Peso Bruto, porém é necesssário ratear o valor de 
							   NJJ_PSSUBT entre todos os registros de comercialização do romaneio */
							/** Rateio: ler todos registros da NJM do mesmo romaneio, tomando cuidado para não
								desposicionar a NJM que já está lida  */
							
							nTotRom := 0 //Zera acumulador
							dbSelectArea('NJM')
							dbSetOrder(1)
							NJM->( dbSeek( xFilial('NJM') + (pcAliasNJM)->NJM_CODROM ) )
							While ! NJM->( Eof() ) .And. NJM->( NJM_FILIAL + NJM_CODROM ) == xFilial('NJM') + (pcAliasNJM)->NJM_CODROM
								nTotRom += NJM->NJM_QTDFCO
								NJM->( DbSkip() )	
							EndDo
							
//							dbSelectArea( pcAliasNJM )
							nPesoRom := (pcAliasNJM)->NJJ_PSSUBT * ( (pcAliasNJM)->NJM_QTDFCO / nTotRom )	// rateio do peso bruto 
						Endif	
					EndIf
					
					nFatMul := 1
					
					If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor
						nFatMul := AGRX001( (pcAliasNJM)->NJJ_UM1PRO , (cAliasNKQ)->NKQ_UMTAR, nPesoRom, cCodProdut)
					Else
						nFatMul := nPesoRom 
					Endif
					
					If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor 
						nValTar := nTarifa * nFatMul
					Else // 1=Retenção
						nValTar := (nTarifa * nFatMul) / 100   
					EndIf 
					
					If nValTar > 0
						dIniPer := StoD( dBaseCalc )
						dFimPer := dNextCal
						nPer    := 1
						
						fGravaNKG( cAliasNKQ, pcAliasNJM, pcAliasNJR, nTarifa, nFatMul, dIniPer, dFimPer, nPer, nValTar, , , lGeraArr,.F.)	
					EndIf					
					//Fim Fato Gerador Entrada	
					
				////////////////////////////////////////////////////////////
				/// FATO GERADOR = SAIDA                                 ///
				////////////////////////////////////////////////////////////
				ElseIf (cAliasNKQ)->NKQ_FATGER = "1"     // 1-Saída
					
					If StoD( dBaseCalc ) >= dInicioMov //data movimento de
						// verificar a carência, quando o tipo de carência for 1a entrega 
						If   (cAliasNKQ)->NKQ_TIPCAR         = '0' // 0-primeira entrega
							dIni1aEntr := fCalcDtIni( cAliasNKQ, dFirstEnt )
							
							if StoD( dBaseCalc ) < dIni1aEntr
								// --- ir para próximo registro NKQ
								(cAliasNKQ)->( DbSkip() )
								Loop
							endif	
						EndIf
						
/*	
//* **MARLON** - Trecho abaixo comentado porque é errado buscar a NF simplesmente pelo código do cliente
						// Buscar as notas de origem, pois as saídas dependem das origens, para períodos, carência, classificação, etc.
						dbSelectArea('NJ0')
						dbSetOrder( 1 )
						If dbSeek( xFilial( "NJ0" ) + (pcAliasNJM)->NJM_CODENT + (pcAliasNJM)->NJM_LOJENT ) 
							
							dbSelectArea('SF2')
							dbSetOrder(2)
							If dbSeek( xFilial('SF2') + NJ0->NJ0_CODCLI + NJ0->NJ0_LOJCLI + (pcAliasNJM)->NJM_DOCNUM + (pcAliasNJM)->NJM_DOCSER)
*/
						DbSelectArea( "SC5" )
						DbSetOrder( 1 ) //C5_FILIAL+C5_NUM
						If DbSeek( xFilial( "SC5" ) + (pcAliasNJM)->( NJM_PEDIDO ) )
							
							DbSelectArea( "SF2" )
							DbSetOrder( 1 ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
							If DbSeek( xFilial( "SF2" ) + SC5->( C5_NOTA + C5_SERIE + C5_CLIENTE + C5_LOJACLI ) )								
								
								cEntDev := (pcAliasNJR)->NJR_CODENT
								cLojDev := (pcAliasNJR)->NJR_LOJENT	
								
								// Necessário tratar transferencia Origem e destino, não está fazendo ainda.... incompleto
								If (pcAliasNJM)->NJM_TRSERV $ '1|2' // NJM_TRSERV    0=Não;1=Tarifa Origem;2=Tarifa Destino
									
									//Buscar entidade devedora
									dbSelectArea('NJJ')
									dbSetOrder(1)
									If dbSeek( (pcAliasNJM)->NJJ_FILIAL + (pcAliasNJM)->NJJ_ROMREL ) 
										cEntDev := NJJ->NJJ_CODENT
										cLojDev := NJJ->NJJ_LOJENT		
									Endif								
								Endif
								
								/*ler SD2 	ITENS DA NOTA FISCAL SAÍDA/RETORNO, 'n' registro    		*/			
								BeginSql Alias cAliasSD2
									SELECT *
									  FROM %Table:SD2% SD2
									 WHERE SD2.%notDel%
									   AND D2_FILIAL  = %XFilial:SD2%
									   AND D2_DOC     = %exp:SF2->F2_DOC%
									   AND D2_SERIE   = %exp:SF2->F2_SERIE%
									   AND D2_CLIENTE = %exp:SF2->F2_CLIENTE%
									   AND D2_LOJA    = %exp:SF2->F2_LOJA%
								EndSQL
								
								dbSelectArea( cAliasSD2 ) // ITENS DA NOTA DE SAÍDA 
								While ! (cAliasSD2)->( Eof() )  
									
									// Se o parametro foi marcado para calcular somente para uma Nota fiscal
									If ! Empty( cDocOri ) .And. ! Empty( cSerOri )
										If (cAliasSD2)->( D2_NFORI + D2_SERIORI ) <> cDocOri + cSerOri
											(cAliasSD2)->( DbSkip() )
											Loop
										EndIf
									EndIf
									
									dbSelectArea( "SD1" )  // ITENS DA NOTA DE ENTRADA ORIGINAL
									dbSetOrder( 1 )
									If dbSeek( xFilial( "SD1" ) + (cAliasSD2)->( D2_NFORI + D2_SERIORI + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEMORI ) ) 
										
										/***---------------------------------------------------
											A leitura abaixo utiliza um espelho da tabela NJM,
											já posicionada com o alias pcAliasNJM.
											Ao manutenir esse código favor dar atenção a essa
											interação, pois, afeta toda a criação de movimentos
											para fato gerador de saída.
										----------------------------------------------------***/
										dbSelectArea('NJM')
										dbSetOrder(1)
										If NJM->( dbSeek( xFilial('NJM') + SD1->( D1_CODROM + D1_ITEROM ) ) )
											If __lDataCalc == "1" //documento fiscal
                                                dBaseCalcOrig := NJM->NJM_DTRANS
                                            else    
                                                dBaseCalcOrig := POSICIONE("NJJ",1,NJM->(NJM_FILIAL+NJM_CODROM),"NJJ_DATA") 
                                            EndIf

                                            If (cAliasNKQ)->NKQ_TIPCAR  == '1' // 1=cada entrega												
                                                dIniPerCalc := fCalcDtIni ( cAliasNKQ, DtoS( dBaseCalcOrig ) )
												
												// verificar a carência, quando o tipo de carência for a Cada Entrega 
												if StoD( dBaseCalc ) <  dIniPerCalc
													// --- ir para próximo registro SD2
													(cAliasSD2)->( DbSkip() )
													Loop
												endif
											else 
												// carencia pela 1a entrega, porém não poderia calcular antes da própria entrega acontecer
												If 	dIni1aEntr > dBaseCalcOrig
													dIniPerCalc := dIni1aEntr  
												Else 
													dIniPerCalc := dBaseCalcOrig
												Endif			
											EndIf
											
											// calcular a data fim conforme a periodicidade																						
											aCalcPer := fCalcPer( cAliasNKQ, , DtoS( dIniPerCalc ), StoD( dBaseCalc ), 2, dFinalMov )	
											
											nPer     := aCalcPer[2]
											
											If nPer = 0	//  --- ir para próximo registro SD2
												(cAliasSD2)->( DbSkip() )
												Loop
											EndIf
											
											// verificar se tem tarifa por resultado de análise
											nTarifa := fTarAnalise( cAliasNKQ, NJM->NJM_CODROM )   // este da NJM registro é de origem 
											
											If nTarifa = 0
												If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor
													nTarifa := (cAliasNKQ)->NKQ_VALTAR
												ELSE
													nTarifa := (cAliasNKQ)->NKQ_PERRET
												EndIf
											EndIf

											//Ponto de Entrada para Alterar a Tarifa
											If ExistBlock('OG262S1')
											   nRetPE := 0
											   nRetPE := ExecBlock('OG262S1', .F.,.F.,{cAliasNKQ, pcAliasNJM, nTarifa } )
											 
											   If ValType( nRetPE) == "N"
													nTarifa := nRetPE		
											   EndIf
											Endif

											// verificar a base de cálculo 
											nFatMul := 1
											
											If  (cAliasNKQ)->NKQ_FATMUL = '0'  // 0-Peso
												If (cAliasNKQ)->NKQ_TIPPES = '1' .and. NJM->NJM_QTDFCO > 0 // 1-Peso Bruto
													
													dbSelectArea('NJJ')
													dbSetOrder(1)
													nPesoBruto := 0
													If( dbSeek( xFilial('NJJ') + SD1->D1_CODROM))
														nPesoBruto := NJJ->NJJ_PSSUBT 
													Endif											    
													
													nPesoRom := (nPesoBruto * ( NJM->NJM_PERDIV / 100 )) * ( (cAliasSD2)->D2_QUANT / NJM->NJM_QTDFCO )  
												Else  
													nPesoRom := (cAliasSD2)->D2_QUANT
												Endif    
												
												If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor
													nFatMul := AGRX001( (pcAliasNJM)->NJJ_UM1PRO , (cAliasNKQ)->NKQ_UMTAR, nPesoRom, cCodProdut)
												Else
													nFatMul := nPesoRom
												EndIf
											EndIf
											
											If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor
												nValTar := nTarifa * nFatMul
											Else                   // 1=Retenção, na saída a base será 100% menos - o % retenção
												nValTar := (nTarifa * nFatMul) / (100 - nTarifa)  
											EndIf 
											
											If (cAliasNKQ)->NKQ_FATMPE = '0' // 0=Qt.Períodos
												nValTar := nValTar * nPer
											EndIf
											
											//Se valor tarifa > 0 então cria movimento	
											If nValTar > 0 
												dIniPer := dBaseCalcOrig
												dFimPer := StoD( dBaseCalc )
												
												//Criação NKG
												fGravaNKG( cAliasNKQ, pcAliasNJM, pcAliasNJR, nTarifa, nFatMul, dIniPer, dFimPer, nPer, nValTar, NJM->NJM_DOCSER, NJM->NJM_DOCNUM, lGeraArr,.F. )
												
											EndIf				
											
											//NJM->( DbSkip() )							
										EndIf											
									EndIf
									
									(cAliasSD2)->( DbSkip() )										    
								EndDo //Fim laço SD2
								(cAliasSD2)->( dbCloseArea() )
								
							Endif
						Endif								
					EndIf			       
					// Fim Fato Gerador Saida    
				
				////////////////////////////////////////////////////////////
				/// FATO GERADOR = SALDO                                 ///
				////////////////////////////////////////////////////////////
				ElseIf (cAliasNKQ)->NKQ_FATGER = "2"     // 2-Saldo 
					
					cEntDev := (pcAliasNJR)->NJR_CODENT
					cLojDev := (pcAliasNJR)->NJR_LOJENT
					
					// Se o parametro foi marcado para calcular somente para uma Nota fiscal
					If ! Empty( cDocOri ) .And. ! Empty( cSerOri )
						If (pcAliasNJM)->( NJM_DOCNUM + NJM_DOCSER ) <> cDocOri + cSerOri
							(cAliasNKQ)->( DbSkip() )
							Loop
						EndIf
					EndIf
					
					// Data final de carencia, considerando dias corridos
					dFimCaren := StoD(dBaseCalc) + ( cAliasNKQ )->NKQ_DIACAR
					If   (cAliasNKQ)->NKQ_TIPCAR   = '0' // 0-primeira entrega
					    dFimCaren := StoD(dFirstEnt) + ( cAliasNKQ )->NKQ_DIACAR
					EndIf   
					
					// calcular todos os períodos para a entrega 			
					aCalcPer := fCalcPer( cAliasNKQ, pcAliasNJM, dBaseCalc, dFinalMov, 3, dFinalMov) 
					
					dNextCal := aCalcPer[1]   
					
					// Verificar se tem retenção já calculadas para esta nota 
					aNotasRet := X262NOTA( (pcAliasNJM)->NJM_CODCTR, (pcAliasNJM)->NJM_DOCNUM, (pcAliasNJM)->NJM_DOCSER )
					
					If (cAliasNKQ)->NKQ_PERCOB = '0' // diario -> criar os períodos
						fPerDiario (pcAliasNJM, aNotasRet, dFinalMov, dFimCaren, dLastCalc)
					EndIf 
					
					// Procura todas as NFs de Saída que tiveram como origem a NF de Entrada a Depósito do romaneio posicionado em pcAliasNJM
					dbSelectArea( 'SD2' ) // ITENS DA NOTA DE SAÍDA 
					dbSetOrder( 10 )
					dbSeek( xFilial( 'SD2' ) + (pcAliasNJM)->NJM_DOCNUM + (pcAliasNJM)->NJM_DOCSER )
					While ! SD2->( Eof() ) ;
					.And. SD2->( D2_FILIAL + D2_NFORI + D2_SERIORI ) == xFilial("SD2") + (pcAliasNJM)->NJM_DOCNUM + (pcAliasNJM)->NJM_DOCSER
						
						lNfRet := .F.

                        If (cAliasNKQ)->NKQ_TIPCOB == '1' .AND. __lRLS12123 //retenção
                            lNfRet := fNotaRet(pcAliasNJM)
                        Endif 
                        
                        If !lNfRet
                            If LEN(aPeriodos) > 0 .And. SD2->D2_EMISSAO <= dFinalMov
                                nVezes := LEN(aPeriodos)
                                
                                For nX := 1 to nVezes
                                    If (cAliasNKQ)->NKQ_PERCOB = '0' // diario
                                        if aPeriodos[ nX, 1] >= SD2->D2_EMISSAO  
                                            aPeriodos[ nX, 3] := aPeriodos[ nX, 3] - SD2->D2_QUANT		
                                        endif
                                    else 
                                        If   ( dFimCaren >= aPeriodos[ nX, 1] .and. dFimCaren <= aPeriodos[ nX, 2] .and. dFimCaren >= SD2->D2_EMISSAO .and. (cAliasNKQ)->NKQ_PERCOB <> '0' .and. (cAliasNKQ)->NKQ_DIACAR > 0) ;
                                        .or. (aPeriodos[ nX, 2] >= SD2->D2_EMISSAO .and. (cAliasNKQ)->NKQ_PEPARC = '0') ; // tarifa livre  0 – Livre 1 – Cheia 2 – Proporcional
                                        .or. (aPeriodos[ nX, 1] >= SD2->D2_EMISSAO .and. (cAliasNKQ)->NKQ_PEPARC $ '1|2') // tarifa cheia - Atenção Proporcional não pode utilizar - tem validação no cadastro
                                            aPeriodos[ nX, 3] := aPeriodos[ nX, 3] - SD2->D2_QUANT					
                                        Endif
                                    
                                    endif
                                Next nX
                            EndIf
                        EndIf
                        SD2->( DbSkip() )
					EndDo         
					
					// VERIFICAR SE TEM RETENÇÕES JÁ CALCULADAS
					For nS := 1 to Len( aNotasRet )
						
						nQuant	 := aNotasRet[ nS, 2 ]
						dDtrans := StoD(aNotasRet[ nS, 1 ])
						
						If LEN(aPeriodos) > 0 .And. dDtrans <= dFinalMov
							nVezes := LEN(aPeriodos)
							
							For nX := 1 to nVezes
								If (cAliasNKQ)->NKQ_PERCOB = '0' // diario
								
									if aPeriodos[ nX, 1] >= dDtrans 
								   		aPeriodos[ nX, 3] := aPeriodos[ nX, 3] - nQuant		
									endif
								else
									If   (dFimCaren >= aPeriodos[ nX, 1] .and. dFimCaren <= aPeriodos[ nX, 2] .and. dFimCaren >= dDtrans .and. (cAliasNKQ)->NKQ_PERCOB <> '0'  .and. ( cAliasNKQ )->NKQ_DIACAR > 0 ) ;
									.or. (aPeriodos[ nX, 2] > dDtrans .and. (cAliasNKQ)->NKQ_PEPARC = '0') ; // tarifa livre  0 – Livre 1 – Cheia 2 – Proporcional
									.Or. (aPeriodos[ nX, 1] > dDtrans .and. (cAliasNKQ)->NKQ_PEPARC $ '1|2') // tarifa cheia - Atenção Proporcional não pode utilizar - tem validação no cadastro
										aPeriodos[ nX, 3] := aPeriodos[ nX, 3] - nQuant		
									Endif
								endif 
							Next nX
						endif
					Next nS
					
					/*********/
				
					If LEN(aPeriodos) > 0
						qtperAnt := 0
						
						For nX := 1 to LEN(aPeriodos)
							If (cAliasNKQ)->NKQ_DESCPE = '1' .And. (cAliasNKQ)->NKQ_TIPCOB = '1' //Sim##Peso 
								aPeriodos[ nX, 3] -= qtPerAnt
							Endif		 
							If aPeriodos[ nX, 3] >= 0
								lPerVal := .T.	
								
								// verificar a carência E se os períodos são maiores que último cálculo
								If   (cAliasNKQ)->NKQ_TIPCAR   = '0' // 0-primeira entrega
									dIniPerCalc := fCalcDtIni( cAliasNKQ, dFirstEnt )
								Else
									dIniPerCalc := fCalcDtIni( cAliasNKQ, dBaseCalc )
								EndIf    						                         
								
								If   aPeriodos[ nX, 2] < dIniPerCalc ;
								.Or. ( ! Empty(dLastCalc) .And. DtoS( aPeriodos[ nX, 2] ) <= dLastCalc );
								.Or. ( (cAliasNKQ)->NKQ_PERCOB == '0' .and. aPeriodos[ nX, 2] = dIniPerCalc ) ; 
								.OR. (pcAliasNJR)->NJR_SLDFIS = 0 
									//--- ir para próximo registro WT
									lPerVal := .F. 
								EndIf
								
								IF lPerVal
									// valor tarifa  
									If (cAliasNKQ)->NKQ_TIPCOB  = '0' // 0=Valor 
										nTarifa := (cAliasNKQ)->NKQ_VALTAR
									ELSE
										nTarifa := (cAliasNKQ)->NKQ_PERRET
									EndIf
									
									// verificar a base de cálculo 
									nFatMul := 1
									
									If  (cAliasNKQ)->NKQ_FATMUL   = '0'  // 0-Peso
										nPesoRom := aPeriodos[ nX, 3]
										
										If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor 
											nFatMul := AGRX001( (pcAliasNJM)->NJJ_UM1PRO , (cAliasNKQ)->NKQ_UMTAR, nPesoRom, cCodProdut)
										Else
											nFatMul := nPesoRom 
										EndIf
									EndIf
									
									If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor 
										nValTar :=  nTarifa * nFatMul
									ELSE                   // 1=Retenção
										nValTar := (nTarifa * nFatMul) / 100   
									EndIf 
									
									nPer := 1      // saldo sempre será 1 período
									If (cAliasNKQ)->NKQ_FATMPE = '0' /* Qt Periodos = 0 */ ;  
									.And. (cAliasNKQ)->NKQ_PERCOB = '0' // diario
										nPer    := aPeriodos[ nX, 2] - aPeriodos[ nX, 1] 											   
										nValTar := nValTar * nPer
									EndIf
									
									If nValTar > 0 
										qtPerAnt += nValTar
										dIniPer  := aPeriodos[ nX, 1]
										dFimPer  := aPeriodos[ nX, 2]
										
										fGravaNKG( cAliasNKQ , pcAliasNJM , pcAliasNJR, nTarifa, nFatMul, dIniPer, dFimPer, nPer, nValTar, , , lGeraArr,plSimula) 										
									EndIf	
									
								Endif								
							Endif
						Next nX 							
					Endif
					
					// Fim Fato Gerador Saldo
				EndIf
				
			Endif		   	   
		Endif
		
		(cAliasNKQ)->( DbSkip() )
	EndDo //Fim laço NKQ
	(cAliasNKQ)->( dbCloseArea() )
	
Return( NIL )

/** {Protheus.doc} A262SIMUL
Rotina para simular o calculo das tarifas sobre serviço

@param: 	pcAliasNJR    -> Recebe ponteiro da NJR Contrato
			nQtSimul      -> Recebe quantidade da simulação de retirada
			dDTSimul		-> Recebe data da simulação de retirada 
			cTCSimul		-> Recebe tipo de controle da simulação de retirada 0=Físico;2=Simbólico
			dFirstEnt		-> Recebe data da primeira entrega para o contrato 
			dInicioMov		-> Recebe data inicio seleção
			dFinalMov		-> Recebe data final  seleção 
			cFiltroSer		-> Recebe filtros para a Tabela NKQ Tarifas de Serviços 
			lGeraArr		-> Receber flag indica se deve gerar array para impressão
			lGeraNKG	 	-> Receber flag indica se deve gerar tabela NKG
			
@author: 	Bruna Fagundes Rocio
@since: 	22/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function A262SIMUL( pcAliasNJR, nQtSimul, dDTSimul, cTCSimul, dFirstEnt, dInicioMov, dFinalMov, cFiltroSer, lGeraArr, lGeraNKG, aRetSimul)
	/* aRetSimul, colunas:
		2-Documento 
		3-Série 
		4-Data Emissão 
		7-Quantidade
		8-romaneio
		9-item rom
		10-trans
		11-retençaõ ou valor serviço 	
	*/
	
	Local cAliasNKQ    := GetNextAlias() 
	Local nX           := 0
	Local dIniPerCalc
	Local dIni1aEntr
	Local   nDecPeso   := SuperGetMV("MV_OGDECPS",,0)
	Local cCodProdut   := (pcAliasNJR)->NJR_CODPRO
	
	Private aCalcPer   := {}
	
	If Len( aRetSimul ) <= 0 
		//---- revisar esta mensagem pois copiei do ogx008
		//Help( , , STR0001, , STR0002, 1, 0 ) //"AJUDA"###"E obrigatoria a selecao dos documentos de Origem!"
		Return( aRetSimul )
	EndIf
	
	//Efetuar o cálculo do retorno simulado 
	
	BeginSql Alias cAliasNKQ
		SELECT *
		  FROM %Table:NKQ% NKQ
		 WHERE NKQ.%notDel%
		   AND NKQ_FILIAL  = %xFilial:NKQ%
		   AND NKQ_CODTSE  = %exp:(pcAliasNJR)->NJR_CODTSE%
		   AND NKQ_ATIVO   = '1'
		   %exp:cFiltroSer% 
	EndSQL	
	
	DbSelectArea( cAliasNKQ )	
	(cAliasNKQ)->( DbGoTop() )	
	While ! (cAliasNKQ)->( Eof() ) 
		
		/* NKQ_FATGER			   0= Entrada				1= Saída		      2= Saldo  */
		
		If    ((( cAliasNKQ )->NKQ_CONFIS = '1' .And. cTCSimul = '0') ; 
		 .Or. ( ( cAliasNKQ )->NKQ_CONSIM = '1' .And. cTCSimul = '2')); 
		.And. ( ( cAliasNKQ )->NKQ_FATGER = '1' ) // simulação somente saída 
			
			If dDTSimul >= dInicioMov //data movimento de
				
				// verificar a carência, quando o tipo de carência for 1a entrega 
				If ( cAliasNKQ )->NKQ_TIPCAR         = '0' // 0-primeira entrega
						dIni1aEntr := fCalcDtIni( cAliasNKQ, dFirstEnt )
					If dDTSimul < dIni1aEntr
						// --- ir para próximo registro NKQ
						(cAliasNKQ)->( DbSkip() )
						Loop
					EndIf	
				EndIf	
				
				// Buscar as notas de origem, pois as saídas dependem das origens, para períodos, carência, classificação, etc.
				cEntDev := (pcAliasNJR)->NJR_CODENT
				cLojDev := (pcAliasNJR)->NJR_LOJENT	
				
				For nX := 1 to Len( aRetSimul )
					
					nQuant		:= aRetSimul[ nX, 6 ]
					cNfOri		:= aRetSimul[ nX, 2 ]
					cSeriOri	:= aRetSimul[ nX, 3 ]
					cRom      	:= aRetSimul[ nX, 8 ]
					cItRom    	:= aRetSimul[ nX, 9 ]
					
					If !empty(aRetSimul[ nX, 10 ])
						dDtrans   	:= StoD(aRetSimul[ nX, 4 ])
					Else
						dDtrans   	:= StoD(aRetSimul[ nX, 10 ])
					Endif 
					
					/***---------------------------------------------------
					A leitura abaixo utiliza um espelho da tabela NJM,
					já posicionada com o alias pcAliasNJM.
					Ao manutenir esse código favor dar atenção a essa
					interação, pois, afeta toda a criação de movimentos
					para fato gerador de saída.
					----------------------------------------------------***/
					nTotRom    := 0 //Zera acumulador
					nPesoBruto := 0
					
					If  ( cAliasNKQ )->NKQ_FATMUL = '0'  // 0-Peso
						If ( cAliasNKQ )->NKQ_TIPPES = '1'  // 1-Peso Bruto
							/* neste caso é Peso Bruto, porém é necesssário ratear o valor de 
							NJJ_PSSUBT entre os registros de comercialização do romaneio */
							
							dbSelectArea('NJM')
							dbSetOrder(1)
							NJM->( dbSeek( xFilial('NJM') + cRom ) )
							While ! NJM->( Eof() ) .And. NJM->( NJM_FILIAL + NJM_CODROM ) == xFilial('NJM') + cRom
								nTotRom += NJM->NJM_QTDFCO
								NJM->( DbSkip() )	
							EndDo
							
							//Buscar peso bruto do romaneio de origem
							dbSelectArea('NJJ')
							dbSetOrder(1)
							If(dbSeek( xFilial('NJJ') + cRom))
								nPesoBruto := NJJ->NJJ_PSSUBT 
							Endif
						Endif	
					EndIf
					
					If ( cAliasNKQ  )->NKQ_TIPCAR   = '1' // 1-cada entrega
						dIniPerCalc := fCalcDtIni( cAliasNKQ , DtoS(dDtrans) )																																		  		
					Else 
						// carencia pela 1a entrega, porém não poderia calcular antes da própria entrega acontecer
						If 	dIni1aEntr > DtoS(dDtrans)
							dIniPerCalc := dIni1aEntr  
						Else 
							dIniPerCalc := DtoS(dDtrans)
						Endif			
					EndIf
					
					// verificar a carência, quando o tipo de carência for a Cada Entrega, e continuar caso não for  
					If    dDTSimul >= dIniPerCalc
						
						// calcular a data fim conforme a periodicidade																											
						aCalcPer := fCalcPer(  cAliasNKQ , , DtoS(dIniPerCalc), dDTSimul, 2, dFinalMov ) 
						nPer     := aCalcPer[2]
						
						If nPer > 0	//  --- tem pelo menos um período
							
							// verificar se tem tarifa por resultado de análise
							nTarifa := fTarAnalise( ( cAliasNKQ ), cRom )   // este romaneio é de origem 
							
							If nTarifa = 0
								If ( cAliasNKQ )->NKQ_TIPCOB = '0' // 0=Valor
									nTarifa := ( cAliasNKQ )->NKQ_VALTAR
								Else
									nTarifa := ( cAliasNKQ )->NKQ_PERRET
								EndIf
							EndIf
							
							// verificar a base de cálculo 
							nFatMul := 1
							
							If  ( cAliasNKQ )->NKQ_FATMUL = '0'  // 0-Peso
								If ( cAliasNKQ )->NKQ_TIPPES = '1' .and. nTotRom > 0 // 1-Peso Bruto
									nPesoRom := nPesoBruto * (nQuant / nTotRom)
								Else  
									nPesoRom := nQuant
								Endif    
								
								If ( cAliasNKQ )->NKQ_TIPCOB = '0' // 0=Valor
									nFatMul := AGRX001( (pcAliasNJR)->NJR_UM1PRO , (cAliasNKQ)->NKQ_UMTAR, nPesoRom, cCodProdut)
								Else
									nFatMul := nPesoRom
								EndIf
							EndIf
							
							If ( cAliasNKQ )->NKQ_TIPCOB = '0' // 0=Valor
								nValTar := nTarifa * nFatMul
							Else                   // 1=Retenção
								If lGeraNKG
									//Nesta situação a quantidade já está liquida
									nValTar := (nTarifa * nFatMul) / (100 - nTarifa)
								Else	
									//Nesta situação a quantidade é o saldo total para simulação
									nValTar := (nTarifa * nFatMul) / (100)
								Endif	   
							EndIf 
							
							If ( cAliasNKQ )->NKQ_FATMPE = '0' // 0=Qt.Períodos
								nValTar := nValTar * nPer
							EndIf
							
							//Se valor tarifa > 0 então cria movimento	
							If nValTar > 0 
								dIniPer 				:= dDtrans
								dFimPer 				:= dDTSimul
								aRetSimul[ nX, 11 ] 	:= Round(nValTar,nDecPeso)		// quantidade de retenção ou valor tarifa
													
								If lGeraNKG 
									//Criação NKG
									fGravaNKG( cAliasNKQ, , pcAliasNJR, nTarifa, nFatMul, dIniPer, dFimPer, nPer, nValTar, cSeriOri, cNfOri, lGeraArr,.T.)
									
								Endif	
							EndIf
							
							// Fim Fato Gerador Saida/Simulação
						Endif
					Endif	
					
				Next nX
			Endif
		Endif
		
		(cAliasNKQ)->( DbSkip() )
	Enddo
	(cAliasNKQ)->( dbCloseArea() )
	
Return ( aRetSimul )

/** {Protheus.doc} fSelecNFOri
Função auxiliar para seleção de documentos de origem para amarracao na simulação da NF de retorno.

@param: 	pcAliasNJR    -> Recebe ponteiro da NJR Contrato
			nQtSimul      -> Recebe quantidade da simulação de retirada
			
@author: 	Bruna Fagundes Rocio
@since: 	22/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
**/
Static Function fSelecNFOri( pcAliasNJR, nQtSimul )
Local aRetorno 	:= {}
Local aAreaAtu	:= GetArea()
Local aAux			:= {}
Local nY			:= 0
Local nQtdAdl	    := nQtSimul
Local nQtdSel	    := 0
Local aNota       := {}
Local aRetencao   := {}
Local nDecPeso   := SuperGetMV("MV_OGDECPS",,0)
Local nQuebra    := 0
Local nRetencao  := 0 

//ler itens das notas de entrada SD1
BeginSql Alias "Qry1"
	Select
		SD1.D1_DOC,
		SD1.D1_SERIE,
		SD1.D1_EMISSAO,
		SD1.D1_ITEM,
		SD1.D1_CODROM,
		SD1.D1_ITEROM,
		SD1.D1_QUANT,
		SD1.D1_VUNIT,
		SD1.D1_TOTAL,
		( SD1.D1_QUANT - SD1.D1_QTDEDEV ) as D1_SALDO,
		SD1.D1_IDENTB6,
		SB6.B6_SALDO
	From
		%Table:SD1% SD1, %Table:SB6% SB6
	Where
		SD1.D1_FILIAL  = %xFilial:SD1% And
		SD1.D1_CTROG   = %exp:(pcAliasNJR)->NJR_CODCTR% And
		SD1.D1_COD     = %exp:(pcAliasNJR)->NJR_CODPRO% AND
		( SD1.D1_QUANT - SD1.D1_QTDEDEV ) > 0 And
		SD1.%NotDel% And
		SB6.B6_FILIAL = SD1.D1_FILIAL And
		SB6.B6_IDENT  = SD1.D1_IDENTB6 And
		SB6.%NotDel% And
		SB6.B6_SALDO > 0
	Order By
		SD1.D1_EMISSAO,
		SD1.D1_SERIE,
		SD1.D1_DOC
EndSql

Qry1->( dbGoTop() )
If Qry1->( Eof() )
	Qry1->( dbCloseArea() )
	RestArea( aAreaAtu )
	lNFOrigem := .F.
	Return( aRetorno )
EndIf
While .Not. Qry1->( Eof() )
	
	aAdd( aAux, Array(12) )
	aAux[ Len( aAux ), 1 ] := "0"                   // 0-não marcado 1-marcado
	aAux[ Len( aAux ), 2	] := Qry1->( D1_DOC   )    // documento
	aAux[ Len( aAux ), 3 ] := Qry1->( D1_SERIE )    // serie 
	aAux[ Len( aAux ), 4 ] := Qry1->( D1_EMISSAO)   // data de emissão
	aAux[ Len( aAux ), 5 ] := Qry1->( D1_QUANT )    // quantidade
	aAux[ Len( aAux ), 6 ] := Qry1->( B6_SALDO )    // saldo 
	aAux[ Len( aAux ), 7 ] := 0						   // DISTRIB
	aAux[ Len( aAux ), 8 ] := Qry1->( D1_CODROM )    // romaneio
	aAux[ Len( aAux ), 9 ] := Qry1->( D1_ITEROM )    // seq comerc romaneio
	
	dbSelectArea('NJM')
	dbSetOrder(1)
	If dbSeek( xFilial('NJM') + Qry1->D1_CODROM + Qry1->D1_ITEROM ) 
		// ROMANEIO DA NOTA DE ENTRADA ORIGEM, cuidar para não desposicionar o que já está lido da NJM		
        aAux[ Len( aAux ), 10 	] := NJM->NJM_DTRANS	// data transacao         
	EndIf
	
	aNota := {"0", Qry1->( D1_DOC ), Qry1->( D1_SERIE ), Qry1->( D1_EMISSAO), Qry1->( D1_QUANT ),;
		      Qry1->( B6_SALDO ), 0, Qry1->( D1_CODROM ), Qry1->( D1_ITEROM ) , , 0 }
	
	aRetencao := X262QTRET( (pcAliasNJR)->NJR_CODCTR, aNota, .f. )
	
	If Len(aRetorno) > 0
		nQuebra                    := Round(aRetencao[1],nDecPeso)
		nRetencao                  := Round(aRetencao[2],nDecPeso)
		aAux[ Len( aAux ), 11 	] := nRetencao	// quantidade retenção ou valor serviço
		aAux[ Len( aAux ), 12 	] := nQuebra
	Endif
	
	aAux[ Len( aAux ), 6 	] := aAux[ Len( aAux ), 6 	] - (nRetencao + nQuebra)	
	
	If nQtdAdl > 0
		If nQtdAdl >= aAux[ Len( aAux ), 6 ]
			aAux[ Len( aAux ), 1 	] := "1"	// marcado 
			aAux[ Len( aAux ), 7 	] := aAux[ Len( aAux ), 6 ]
			nQtdAdl -= aAux[ Len( aAux ), 6 ]
			nQtdSel += aAux[ Len( aAux ), 6 ]
		Else
			aAux[ Len( aAux ), 1 	] := "1"	// marcado
			aAux[ Len( aAux ), 7 	] := nQtdAdl 
			nQtdSel += nQtdAdl
			nQtdAdl := 0
		EndIf
	EndIf
	
	Qry1->( DbSkip() )
EndDo
Qry1->( dbCloseArea() )

For nY := 1 to Len( aAux )
	
	If aAux[ nY, 1 ] = "1"
		aAdd( aRetorno, aAux[ nY ] )
	EndIf
Next nY

RestArea( aAreaAtu )

Return( aRetorno )


/** {Protheus.doc} fCalcPer
Rotina para calculo da data do proximo periodo

@param: 	pAlias    -> Recebe ponteiro da NKQ
			pdDataIni -> Data de transação de comercializacao
@return:	aRetorno[1] := dNextCal
			aRetorno[2] := nPer
			aRetorno[3] := nDiasProp
@author: 	Bruna Fagundes Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fCalcPer( pAlias, pAliasNJM, pdDataIni, pDataFim, pPer, pdFinal )
	Local lContinua := .T.
	Local dNextCal  
	Local nPer      := 0  
	Local nDiasProp := 0
	Local aRetorno  := { , , }
	
	aPeriodos := {} //Limpa Array
	
	/* *** Ver qual sera o proximo calculo *** */
	If pPer = 1
		
		If   ((( pAlias )->NKQ_PERCOB = '2') .Or. (( pAlias )->NKQ_PERCOB = '1') .And. (Day(StoD(pdDataIni)) > 15) )
			// quinzenal > 15 ou mensal -> dia 01 do mes seguinte */
			
			If Month(StoD(pdDataIni)) = 12
				dNextCal := CtoD('01/01/' + STR(YEAR(StoD(pdDataIni))+1,4))
			Else
				dNextCal := CtoD('01/' + STR(MONTH(StoD(pdDataIni)) + 1,2) + '/' + STR(YEAR(StoD(pdDataIni)),4))
			Endif
		Else
			If ( pAlias )->NKQ_PERCOB = '1' // quinzenal
				dNextCal := Ctod( '16/' + STR(MONTH(StoD(pdDataIni)),2) + '/' + STR(YEAR(StoD(pdDataIni)),4))
			Else
				// diario ou nulo 
				dNextCal := StoD(pdDataIni) + 1
			EndIf
				
			dNextCal := dNextCal - 1
		Endif
	Else
		If ( pAlias )->NKQ_PERCOB = '0' // diario
          nPer := pDataFim - StoD(pdDataIni)   // retorna a quantidade de dias
       	Else 
          	While lContinua
       
              	If ( pAlias )->NKQ_PERCOB = '2' .Or. (( pAlias )->NKQ_PERCOB = '1' .And. Day(StoD(pdDataIni)) > 15 ) 
              	// quinzenal > 15 ou mensal -> dia 01 do mes seguinte */
              	
					If MONTH(StoD(pdDataIni)) = 12
						dNextCal := CtoD('01/01/' + STR(YEAR(StoD(pdDataIni)) + 1,4))
					Else
						dNextCal := CtoD('01/' + STR(MONTH(StoD(pdDataIni)) + 1,2) + '/' + STR(YEAR(StoD(pdDataIni)),4))
					Endif
				Elseif ( pAlias )->NKQ_PERCOB = '1' // quinzenal
					dNextCal := CtoD( '16/' + STR(MONTH(StoD(pdDataIni)),2) + '/' + STR(YEAR(StoD(pdDataIni)),4))
				Endif
	           
				If !Empty(dNextCal)
						dNextCal := dNextCal - 1
				Endif	
				
				// quando chegar na data fim, parar de contar períodos
				If dNextCal >= pdFinal .Or. dNextCal >= pDataFim
				    
					// verificar se tem período parcial ou cheio para cobrar  
					if ( pAlias )->NKQ_PEPARC = '1'  // tarifa CHEIA  0 – Livre 1 – Cheia 2 – Proporcional
				   		If pPer = 3 //saldo    
							aAdd( aPeriodos, { StoD(pdDataIni), dNextCal, ( pAliasNJM )->NJM_QTDFCO })
						Endif	 					   
				       	nPer := nPer + 1
				   	elseif ( pAlias )->NKQ_PEPARC = '2'  // tarifa PROPORCIONAL  0 – Livre 1 – Cheia 2 – Proporcional
				      	 nDiasProp := (pDataFim - StoD(pdDataIni)) 
				       
						If nDiasProp > 0 
							if ( pAlias )->NKQ_PERCOB = '1' // quinzenal 
								nPer := nPer + (nDiasProp / 15)
							else 
								nPer := nPer + (nDiasProp / 30) 
							endif
						Endif         
				   	endif
				
					lContinua := .F.
				Else 
					If pPer = 3 //saldo    
						/* Este bloco precisa de uma worktable para guardar os períodos
						 WT_DATINI
						 WT_DATFIM
						 WT_QTSALDO   -> ESTE CAMPO SERÁ ALIMENTADO COM BASE NAS SAÍDAS */
					  	aAdd( aPeriodos, { StoD(pdDataIni), dNextCal, ( pAliasNJM )->NJM_QTDFCO }) 					  	
   		           EndIf	 
					nPer      := nPer + 1
					pdDataIni := DtoS(dNextCal + 1)
   		       EndIf        
		   EndDo
		EndIf     
	Endif		
	
	aRetorno[1] := dNextCal
	aRetorno[2] := nPer
	aRetorno[3] := nDiasProp
	
Return (aRetorno)

/** {Protheus.doc} fPerDiario
Rotina para retornar os períodos conforme notas de retorno e retenções já efetuadas

ATENÇÃO:  APENAS PARA CÁLCULO DIÁRIO (cAliasNKQ)->NKQ_PERCOB = '0' - DIÁRIO
		   *****************************************************************
@param: 	pAliasNJM -> Recebe ponteiro da NJM
		   aRetAnt		-> Recebe retornos já efetuados para a nota 
			pdDataFim -> Data Final 
@return:	.T.
@author: 	Fernanda
@since: 	31/08/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fPerDiario( pAliasNJM, aRetAnt, pDataFim, pFimCaren, pdLastCalc )
	Local nX  		   := 0
    Local dBaseCalc    := nil
	
	Default aRetAnt  := {}   // pode não ter retenção anterior já calculada 
	
	aPeriodos  := {} //Limpa Array
	aDatDia    := {}

	If !Empty(pdLastCalc)
		pdLastCalc := StoD(pdLastCalc) //converte para formato de data
	EndIf
	 			
	// Procura todas as NFs de Saída que tiveram como origem a NF de Entrada a Depósito do romaneio posicionado em pAliasNJM
	dbSelectArea( 'SD2' ) // ITENS DA NOTA DE SAÍDA 
	dbSetOrder( 10 )
	dbSeek( xFilial( 'SD2' ) + (pAliasNJM)->NJM_DOCNUM + (pAliasNJM)->NJM_DOCSER )
	While ! SD2->( Eof() ) ;
	  .And. SD2->( D2_FILIAL + D2_NFORI + D2_SERIORI ) == xFilial("SD2") + (pAliasNJM)->NJM_DOCNUM + (pAliasNJM)->NJM_DOCSER
				
		if SD2->D2_EMISSAO <= pDataFim		
			if Len( aDatDia ) = 0 .or. ASCAN(aDatDia, {|x| x[1] == SD2->D2_EMISSAO }) = 0
				// criar mais um registro com a data da saída
				aAdd( aDatDia, { SD2->D2_EMISSAO , })
			endif
		endif  				
		SD2->( DbSkip() )
	EndDo         
    
	// VERIFICAR AS DATA DE RETENÇÕES JÁ CALCULADAS
	For nX := 1 to Len( aRetAnt )
		If StoD(aRetAnt[ nX, 1 ]) <= pDataFim
	
			// Neste ponto poderia verificar qual serviço que está no aRetAnt, e só considerar os que forem do tipo Quebra Técnica na NKQ ou Desconta Período
			 
			if Len( aDatDia ) = 0 .or. ASCAN(aDatDia, {|x| x[1] == StoD(aRetAnt[ nX, 1 ]) }) = 0
				// criar mais um registro com a data da saída
				aAdd( aDatDia, {StoD(aRetAnt[ nX, 1 ]), })
			endif
		ENDIF
		  				
	Next nX	

    If __lDataCalc == "1" //documento fiscal
        dBaseCalc := (pAliasNJM)->NJM_DTRANS
    else    
        dBaseCalc := (pAliasNJM)->NJJ_DATA
    EndIf
	
	// Verificar o final da carência por dias corridos
	if pFimCaren > StoD( dBaseCalc ) .and. pFimCaren < pDataFim .and. (Len( aDatDia ) = 0 .or. ASCAN(aDatDia, {|x| x[1] == pFimCaren }) = 0)
		// criar mais um registro com a data final da carência
		aAdd( aDatDia, {pFimCaren, })
	endif  				
	
	// Verificar a data final de corte, no mínimo terá esta data no aDataDia, ou seja uma linha no array 
	if Len( aDatDia ) = 0 .or. ASCAN(aDatDia, {|x| x[1] == pDataFim }) = 0
		// criar mais um registro com a data final de corte do cálculo 
		aAdd( aDatDia, {pDataFim, })
	endif  

	If !Empty(pdLastCalc) .and. pdLastCalc < pDataFim .and. ASCAN(aDatDia, {|x| x[1] == pdLastCalc }) = 0
		aAdd( aDatDia, {pdLastCalc, }) //ajuste quando é diario e não é retenção, para calcular o periodo correto 
	EndIf
	
	if  Len( aDatDia ) = 0
		// criar pelo menos um registro quando não teve nenhuma movimentação
	   aAdd( aDatDia, {StoD( dBaseCalc ), pDataFim })
	else    
		//Ordena o Array Multidimensional levando em consideração somente a primeira coluna
		aSortComp  := ASORT(aDatDia,,, { |x, y| x[1] < y[1] })
	endif
		
	For nX := 1 to Len( aDatDia )
		
		// data inicial do período diário, depois da primeira saída   	
		if  nX = 1
			aDatDia[nX, 2] := aDatDia[nX, 1]
			aDatDia[nX, 1] := StoD( dBaseCalc )
		else 
			aDatDia[nX, 2] := aDatDia[nX, 1]
			aDatDia[nX, 1] := aDatDia[nX - 1, 2]     // dia final do registro anterior   
		endif
		 
	Next nX	
	
	For nX := 1 to Len( aDatDia )
		aAdd( aPeriodos, { aDatDia[nX, 1], aDatDia[nX, 2], (pAliasNJM)->NJM_QTDFCO })
		
	Next nX	

Return (.T.)


/** {Protheus.doc} fCalcDtIni
Rotina para calculo da data início considerando a carência

@param: 	pAlias    -> Recebe ponteiro da NKQ
			pdDataIni -> Data de transação de início do movimento 
@author: 	Bruna Fagundes Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fCalcDtIni( pAlias, pdDataIni)

	Local dRetIni   := StoD(pdDataIni)
	Local iPerCar   := 0 
	Local iPer      := 0
	Local nX		  := 0
	
	If     ( pAlias )->NKQ_DIACAR = 0  ; // sem carencia  
	.or.	( pAlias )->NKQ_PERCOB = '0'; // Diário
	.or.   ( pAlias )->NKQ_PEPARC = '2'; // Cobrança proporcional em período parcial
	.or.   ( pAlias )->NKQ_FATMPE = '1'  // 0=Qt.Períodos;1=Unidade
	 
		dRetIni := StoD(pdDataIni) + ( pAlias )->NKQ_DIACAR 
			
	else
		if ( pAlias )->NKQ_PERCOB = '1' // Quinzenal
			iPerCar := ( pAlias )->NKQ_DIACAR / 15
		else 
			iPerCar := ( pAlias )->NKQ_DIACAR / 30	// mensal
		endif
		
		if     ( pAlias )->NKQ_PEPARC = '0' // Livre 
			iPer	:= int(iPerCar)
		
		elseif ( pAlias )->NKQ_PEPARC = '1'  // 1 – Cheia
			iPer    := int(iPerCar)
			iPerCar := iPerCar - iPer
			
			// se for período parcial, considera um período inteiro 
			if iPerCar > 0
				iPer    := iPer + 1
			endif
		endif
		
		if iper > 0
			// calcular a data do ultimo período de carência
			for nX := 1 to iPer
				If ( pAlias )->NKQ_PERCOB = '2' .Or. (( pAlias )->NKQ_PERCOB = '1' .And. Day(dRetIni) > 15 ) 
              	// quinzenal > 15 ou mensal -> dia 01 do mes seguinte */
              	
              	If MONTH(dRetIni) = 12
              		dRetIni := CtoD('01/01/' + STR(YEAR(dRetIni) + 1,4))
              	Else
              		dRetIni := CtoD('01/' + STR(MONTH(dRetIni) + 1,2) + '/' + STR(YEAR(dRetIni),4))
	              Endif
	           Elseif ( pAlias )->NKQ_PERCOB = '1' // quinzenal
	           	dRetIni := CtoD( '16/' + STR(MONTH(dRetIni),2) + '/' + STR(YEAR(dRetIni),4))
	           Endif
			next nX
		endif
	endif 	 
	
Return (dRetIni)

/** {Protheus.doc} fTarAnalise
Rotina para calculo da data do proximo periodo

@param: 	pAliasNKQ   -> Recebe ponteiro da NKQ
			pAliasNJM   -> Recebe ponteiro de comercialização
@author: 	Bruna Fagundes Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fTarAnalise ( pAliasNKQ, pcRomaneio ) 
	Local nTarifa   := 0.00
	Local cAliasNKR := GetNextAlias()
	
	// Ler todas as tarifas por resultado analise da tabela  
	// Ler NKR com chave: "NKR_FILIAL+NKR_CODTSE+NKR_ITETSE"
	BeginSql Alias cAliasNKR
		SELECT *
		  FROM %Table:NKR% NKR
		 WHERE NKR.%notDel%
		   AND NKR_FILIAL = %XFilial:NKR%
		   AND NKR_CODTSE = %exp:( pAliasNKQ )->NKQ_CODTSE%
		   AND NKR_ITETSE = %exp:( pAliasNKQ )->NKQ_ITETSE%		   
	EndSQL
	
	dbSelectArea( cAliasNKR )
	(cAliasNKR)->(dbGoTop())
	While ! (cAliasNKR)->( Eof() ) 
		
		// Ler todas classificações do romaneio 
		// Ler NJK com chave NJK_FILIAL+ NJK_CODROM
		
		dbSelectArea('NJK')
		dbSetOrder(1)
		NJK->( dbSeek( xFilial('NJK') + pcRomaneio ) )
		While ! NJK->( Eof() ) .And. NJK->( NJK_FILIAL + NJK_CODROM ) == xFilial('NJK') + pcRomaneio 
			
			If    NJK->NJK_CODDES  = (cAliasNKR)->NKR_CODDES;
			.And. NJK->NJK_PERDES >= (cAliasNKR)->NKR_PERINI;
			.And. NJK->NJK_PERDES <= (cAliasNKR)->NKR_PERFIM
			
				If ( pAliasNKQ )->NKQ_TIPCOB = '0' // 0=Valor 
					nTarifa := (cAliasNKR)->NKR_VALTAR
				Else
					nTarifa := (cAliasNKR)->NKR_PERRET
				EndIf
			Endif
			
			NJK->( DbSkip() )
		EndDo		
		//NJK->( dbCloseArea() )
		
		(cAliasNKR)->( DbSkip() )
	EndDo //Fim laço NKR
	(cAliasNKR)->( dbCloseArea() ) 
	
Return ( nTarifa ) 

/** {Protheus.doc} fGravaNKG
Rotina para criação do movimento

@param: 	pcAliasNKQ   -> Recebe ponteiro da NKQ
			pcAliasNJM   -> Recebe ponteiro de comercialização
			pcAliasNJR   -> Recebe ponteiro de contrato
			pnTarifa     -> Recebe tarifa
			pnFatMul     -> Recebe fator multiplicador 
			pdIniPer     -> Recebe data inicio periodo
			pdFimPer     -> Recebe data fim periodo
			pnPer        -> Recebe quantidade periodo
			pnValTar     -> Recebe valor tarifa
			pcSerOri     -> Serie Origem
			pcNfOri      -> Documento Origem 
			lGeraArr     -> Gera Array de Impressão
			lSimul       -> Simulação de Cálculo
			
			
@author: 	Bruna Fagundes Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fGravaNKG( pcAliasNKQ, pcAliasNJM, pcAliasNJR, pnTarifa, pnFatMul, pdIniPer, pdFimPer, pnPer, pnValTar, pcSerOri, pcNfOri, lGeraArr, lSimul )
	Local nDecPeso   := SuperGetMV("MV_OGDECPS",,0)
	Local cCtrCtrl   := ""
	Local nNextItem  := 0
	Local lRetPE     := .t.
	
	//Ponto de Entrada que permite não salvar o valor do serviço calculado.
	If ExistBlock('OG262S2')
		lRetPE := ExecBlock('OG262S2', .F.,.F.,{pcAliasNJR, pcAliasNKQ, pcAliasNJM,cEntDev,cLojDev,pnFatMul,pdIniPer,pdFimPer,pnPer,pcSerOri,pcNfOri } )
		
		If ValType( lRetPE) == "L"
			IF .not. lRetPE
			    Return .t.
			EndIf	
		EndIf

	Endif

	
	If cCtrCtrl == (pcAliasNJR)->NJR_CODCTR
		nNextItem += 1
	Else 
		cCtrCtrl  := (pcAliasNJR)->NJR_CODCTR
		nNextItem := fGetNextNKG( (pcAliasNJR)->NJR_CODCTR )
	Endif	
	
	RecLock( 'NKG', .t. )
		NKG->NKG_FILIAL := xFilial('NKG')
		NKG->NKG_CODCTR := (pcAliasNJR)->NJR_CODCTR
		NKG->NKG_ITEMOV := Strzero( nNextItem, 8 )
		NKG->NKG_CODDEV := cEntDev 
		NKG->NKG_LOJDEV := cLojDev
		NKG->NKG_CODENT := (pcAliasNJR)->NJR_CODENT
		NKG->NKG_LOJENT := (pcAliasNJR)->NJR_LOJENT
		NKG->NKG_CODSAF := (pcAliasNJR)->NJR_CODSAF
		NKG->NKG_CODPRO := (pcAliasNJR)->NJR_CODPRO
		NKG->NKG_UM1PRO := (pcAliasNJR)->NJR_UM1PRO
		NKG->NKG_DATCAL := dDatabase 
		NKG->NKG_QTDBAS := pnFatMul
		NKG->NKG_QTDAJU := 0                // inicialmente o ajuste é zero, pois poderá ser ajustado em tela
		NKG->NKG_CODTSE := (pcAliasNKQ)->NKQ_CODTSE
		NKG->NKG_ITETSE := (pcAliasNKQ)->NKQ_ITETSE
		NKG->NKG_CODDES := (pcAliasNKQ)->NKQ_CODDES
		NKG->NKG_FATGER := (pcAliasNKQ)->NKQ_FATGER
		NKG->NKG_PERCOB := (pcAliasNKQ)->NKQ_PERCOB
		NKG->NKG_DATINI := pdIniPer
		NKG->NKG_DATFIM := pdFimPer
		NKG->NKG_QTDPER := pnPer
		NKG->NKG_PERRET := (pcAliasNKQ)->NKQ_PERRET
		NKG->NKG_SERORI := pcSerOri
		NKG->NKG_NFORI  := pcNfOri
		
		If !lSimul 
			NKG->NKG_CODROM := (pcAliasNJM)->NJM_CODROM
			NKG->NKG_ITEROM := (pcAliasNJM)->NJM_ITEROM
			NKG->NKG_DOCSER := (pcAliasNJM)->NJM_DOCSER
			NKG->NKG_DOCNUM := (pcAliasNJM)->NJM_DOCNUM
			NKG->NKG_DOCEMI := StoD( (pcAliasNJM)->NJM_DTRANS )
			
			If (pcAliasNKQ)->NKQ_APROV = "0" // Automatica
				if (pcAliasNKQ)->NKQ_TIPRET = '1' // Cobrança Retenção
					NKG->NKG_STATUS := '4' //Pend Comerc
				else  
					NKG->NKG_STATUS := '1' //Atualizado
				endif	 
			Else			
				NKG->NKG_STATUS := '0' //Pendente 
			EndIf
		ELSE 
			NKG->NKG_DOCEMI := dFimPer    // DATA DA SIMULAÇÃO
			NKG->NKG_STATUS := '9'        //Simulado 
		ENDIF
		
		If (pcAliasNKQ)->NKQ_TIPCOB = "0" // 0=Valor
			NKG->NKG_VALTAR := pnTarifa
			NKG->NKG_UMTAR  := (pcAliasNKQ)->NKQ_UMTAR
			NKG->NKG_VALSER := pnValTar
			NKG->NKG_VLTARC := pnValTar
		Else
			NKG->NKG_QTDRET := ROUND( pnValTar, nDecPeso )
			NKG->NKG_QTRETC := ROUND( pnValTar, nDecPeso )
			NKG->NKG_TIPRET := (pcAliasNKQ)->NKQ_TIPRET
		EndIf
		
	NKG->( msUnLock() )	 
	
	//Ponto de Entrada para manipulação da NKG
	If ExistBlock('OGA262PE')
		ExecBlock('OGA262PE', .F.,.F.,{"NKG", NKG->(Recno()) ,  } )
	Endif

	If lGeraArr	
		
		If NKG->NKG_QTDRET > 0
			
			aAdd( aMovServR,{;
			NKG->NKG_CODCTR,;
			NKG->NKG_ITEMOV,;
			NKG->NKG_CODROM,;
			NKG->NKG_CODDEV,;
			NKG->NKG_LOJDEV,;
			NKG->NKG_CODSAF,;
			NKG->NKG_CODPRO,;
			NKG->NKG_DOCSER,;
			NKG->NKG_DOCNUM,;
			NKG->NKG_DOCEMI,;
			NKG->NKG_CODTSE,;
			NKG->NKG_CODDES,;
			NKG->NKG_FATGER,;
			NKG->NKG_PERCOB,; 
			NKG->NKG_QTDPER,;
			NKG->NKG_QTDBAS,;
			NKG->NKG_PERRET,;
			NKG->NKG_UMTAR,;
			NKG->NKG_QTDRET})
			
		Else
			
			aAdd( aMovServV,{;
			NKG->NKG_CODCTR,;
			NKG->NKG_ITEMOV,;
			NKG->NKG_CODROM,;
			NKG->NKG_CODDEV,;
			NKG->NKG_LOJDEV,;
			NKG->NKG_CODSAF,;
			NKG->NKG_CODPRO,;
			NKG->NKG_DOCSER,;
			NKG->NKG_DOCNUM,;
			NKG->NKG_DOCEMI,;
			NKG->NKG_CODTSE,;
			NKG->NKG_CODDES,;
			NKG->NKG_FATGER,; 
			NKG->NKG_PERCOB,;   
			NKG->NKG_QTDPER,;
			NKG->NKG_QTDBAS,;
			NKG->NKG_VALTAR,;
			NKG->NKG_UMTAR,;
			NKG->NKG_VALSER})		
			
		Endif
		
		/*aAdd( aMovServ, {NKG->NKG_CODCTR, NKG->NKG_ITEMOV, NKG->NKG_CODROM, NKG->NKG_ITEROM, NKG->NKG_CODDEV, NKG->NKG_LOJDEV, NKG->NKG_CODENT,; 
	                 NKG->NKG_LOJENT, NKG->NKG_CODSAF, NKG->NKG_CODPRO, NKG->NKG_DOCSER, NKG->NKG_DOCNUM, NKG->NKG_DOCEMI, NKG->NKG_DATCAL,; 
	                 NKG->NKG_QTDBAS, NKG->NKG_QTDAJU, NKG->NKG_CODTSE, NKG->NKG_ITETSE, NKG->NKG_CODDES, X3CboxDesc("NKG_FATGER",NKG->NKG_FATGER),; 
	                 X3CboxDesc("NKG_PERCOB",NKG->NKG_PERCOB), NKG->NKG_DATINI, NKG->NKG_DATFIM, NKG->NKG_QTDPER, NKG->NKG_PERRET, NKG->NKG_VALTAR, NKG->NKG_UMTAR ,; 
	                 NKG->NKG_VALSER, NKG->NKG_QTDRET} )*/
	Endif                 
	
Return( .T. )	

/** {Protheus.doc} fGetNextNKG
Rotina para retornar proximo sequencial da NKG 

@param: 	pcContrato  -> Recebe contrato do movimento
@return: 	nNextItem   -> retorna o próximo sequencial da NKG
@author: 	Bruna Fagundes Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fGetNextNKG( pcContrato )
	Local cAliasQuery :=	GetNextAlias()
	Local nNextItem := 0
	
	BeginSql Alias cAliasQuery
		SELECT NKG_ITEMOV
		  FROM %Table:NKG% NKG
		 WHERE NKG.%notDel%
		   AND NKG_FILIAL = %exp:xFilial('NKG')%
		   AND NKG_CODCTR = %exp:pcContrato%
		 ORDER BY NKG_ITEMOV DESC			
	EndSql	
	
	dbSelectArea(cAliasQuery)
	(cAliasQuery)->( dbGoTop() )
	
	if ! (cAliasQuery)->( Eof() )
		nNextItem := Val( (cAliasQuery)->NKG_ITEMOV )
	endif
	
	/*
	While ! (cAliasQuery)->( Eof() )
		nNextItem := Val( (cAliasQuery)->NKG_ITEMOV )
		(cAliasQuery)->( dbSkip() )
	EndDo
	*/
	
	(cAliasQuery)->( dbCloseArea() )
	
Return( nNextItem + 1 )

/** {Protheus.doc} FormatDate

@param: 	pcDate - Recebe data 
@author: 	Bruna Rocio
@since: 	08/01/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function FormatDate( pcDate )
	Local cDat := ""
	Local cDia := AllTrim(STRZERO(DAY(pcDate),2))
	Local cMes := AllTrim(STRZERO(MONTH(pcDate),2))
	Local cAno := AllTrim(STRZERO(YEAR(pcDate),4))
	cAno := SUBSTR(cAno,3,2)
	
	cDat := cDia + "/" + cMes + "/" + cAno
	
Return ( cDat )

/** {Protheus.doc} GetPerCob
Função para retornar a abreviação do periodo de cobrança

@param: 	Nil
@author: 	Bruna Rocio
@since: 	07/01/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function GetPerCob( pcCob )
	//"0=Diário;1=Quinzenal;2=Mensal"
	Local cPer := ""

	If pcCob = '0'
		cPer := 'D'
	ElseIf pcCob = '1'
		cPer := 'Q'
	Else
		cPer := 'M'
	End

Return ( cPer )

/** {Protheus.doc} GetFatoGer
Função para retornar a abreviação do fato gerador

@param: 	Nil
@author: 	Bruna Rocio
@since: 	07/01/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function GetFatoGer( pcFat )
	//0=Entrada;1=Saída;2=Saldo
	
	Local cFat := ""
	
	If pcFat = '0'
		cFat := 'ENT'
	ElseIf pcFat = '1'
		cFat := 'SAI'
	Else
		cFat := 'SLD'
	End

Return ( cFat )

/** {Protheus.doc} OGA262BROW
Função que executa a montagem do browser de contratos para calculo de serviços
@param: 	Nil
@author: 	Marcelo.wesan
@since: 	02/10/2017
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function OGA262BROW()

    Local aCoors      := FWGetDialogSize( oMainWnd )
	Local oSize       := {}
	Local oFWL        := ""
	Local oDlg		  := Nil
	Local aFilBrowCtr := {}
	Local aBrowCtr    := {}
	Local nCont       := 0
	Local aButtons    := {}
	Local lContinua	  := .T.
	Local aItems      := {STR0059,STR0060}
	Local oCombo1     := Nil
	
     //-------------    [1]         [2]                        [3]                         [4]                         [5] 			            [6] 
	 aBrowCtr := {{STR0057 , "MARK"    	, "C" ,  1, , "@!"},;
	                {STR0058,                 "CONTRATO", TamSX3( "NJR_CODCTR" )[3]	, TamSX3( "NJR_CODCTR" )[1]	, TamSX3( "NJR_CODCTR" )[2]	, PesqPict("NJR","NJR_CODCTR") 	},;	//"Contrato"
                    {AgrTitulo("NJR_CODENT") , "CODENT"	, TamSX3( "NJR_CODENT" )[3]	, TamSX3( "NJR_CODENT" )[1]	, TamSX3( "NJR_CODENT" )[2]	, PesqPict("NJR","NJR_CODENT") 	},;	//Cod. Entidade
		            {AgrTitulo("NJR_LOJENT") , "LOJENT"	, TamSX3( "NJR_LOJENT" )[3]	, TamSX3( "NJR_LOJENT" )[1]	, TamSX3( "NJR_LOJENT" )[2]	, PesqPict("NJR","NJR_LOJENT") 	},;	//Lj. Entidade
		            {AgrTitulo("NJR_NOMENT") , "NOMENT"	, TamSX3( "NJR_NOMENT" )[3]	, TamSX3( "NJR_NOMENT" )[1]	, TamSX3( "NJR_NOMENT" )[2]	, PesqPict("NJR","NJR_NOMENT") 	},; //Nome Entidade
                    {AgrTitulo("NJR_CODTSE") , "TABELA"	, TamSX3( "NJR_CODTSE" )[3]	, TamSX3( "NJR_CODTSE" )[1]	, TamSX3( "NJR_CODTSE" )[2]	, PesqPict("NJR","NJR_CODTSE") 	},; //Tabela
                    {AgrTitulo("NJT_DESCRI") , "SERVICO", TamSX3( "NJT_DESCRI" )[3]	, TamSX3( "NJT_DESCRI" )[1]+100	, TamSX3( "NJT_DESCRI" )[2]	, PesqPict("NJT","NJT_DESCRI") 	}}	//Desc. Serviços

    Processa({|| __cTabPen := MontaTabel(aBrowCtr, {{"", "CONTRATO"}})},STR0061)
    
    //--Deleta tudo da temporaria para realizar nova busca de blocos
    
	DbSelectArea((__cTabPen))
	DbGoTop()
	If DbSeek((__cTabPen)->CONTRATO) 
		While !(__cTabPen)->(Eof())
							
			If RecLock((__cTabRom),.f.)	
				(__cTabPen)->(DbDelete())
				(__cTabPen)->(MsUnlock())
			EndIf			
			(__cTabPen)->( dbSkip() )	
		EndDo 
	EndIF
	
    // Realiza o calculo dos serviços
    lExibe := .T.
    OGA262CALC( {}, , , , .T., cPergSX1)
	lExibe := .F.
	
	(__cTabPen)->(dbGoTop())
	
	If lVazio
		Help(" ",1,"OGC020VAZIO") //Não há dados para ser listados.
		Return(.F.)
	EndIf
	
   If lContinua
		//tamanho da tela principal
		oSize := FWDefSize():New(.t.) //considerar o enchoice
		oSize:AddObject('DLG',100,100,.T.,.T.)
		oSize:SetWindowSize(aCoors)
		oSize:lProp 	:= .T.
		oSize:aMargins := {0,0,0,0}
		oSize:Process()
		
		oDlg := TDialog():New(  oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0062, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //Calculo de serviços
		
		oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3] - 30 /*enchoice bar*/)
	        
		// Instancia o layer
		oFWL := FWLayer():New()
	
		// Inicia o Layer
		oFWL:init( oPnl1, .F. )
		
		// Cria as divisões horizontais
		oFWL:addLine( 'MASTER'   , 100 , .F.)
		oFWL:addCollumn( 'CENTER' ,100,.F., 'MASTER' )
			
		//cria as janelas
		oFWL:addWindow( 'CENTER' , 'Wnd1', STR0063,  80 /*tamanho*/, .F., .T.,, 'MASTER' )//Contratos
		oFWL:addWindow( 'CENTER' 	, 'Wnd2',STR0064,  20 /*tamanho*/, .T., .F.,, 'MASTER' ) 	//"Tabela"
			
		// Recupera os Paineis das divisões do Layer
		oPnlWnd1:= oFWL:getWinPanel( 'CENTER' , 'Wnd1', 'MASTER' )
		oPnlWnd2:= oFWL:getWinPanel( 'CENTER' 	, 'Wnd2', 'MASTER' )
			
			//- Recupera coordenadas 
		oSize2 := FWDefSize():New(.F.)
		oSize2:AddObject(STR0002,100,100,.T.,.T.)
		oSize2:SetWindowSize({0,0,oPnlWnd2:NHEIGHT,oPnlWnd2:NWIDTH})
		oSize2:lProp 	:= .T.
		oSize2:aMargins := {0,0,0,0}
		oSize2:Process()	
			
		_cCombo1:= aItems[1]	
		
		oSay   := TSay():New(oSize2:aPosObj[1,1]+6,oSize2:aPosObj[1,2],{||STR0065},oPnlWnd2,,,,,,.T.,,,80,10,,,,,,.f.)
		oCombo1 := TComboBox():New(oSize2:aPosObj[1,1]+15,oSize2:aPosObj[1,2],{|u|if(PCount()>0,_cCombo1:=u,_cCombo1)},aItems,100,20,oPnlWnd2,, ,{||OGA262VAD()},,,.T.,,,,,,,,,'_cCombo1')
			//cria os componentes
	    oSay1   := TSay():New(oSize2:aPosObj[1,1]+6,oSize2:aPosObj[1,2]+120,{||STR0066},oPnlWnd2,,,,,,.T.,,,40,10,,,,,,.f.)
	    oTGet1 := TGet():New(oSize2:aPosObj[1,1]+15,oSize2:aPosObj[1,2]+120,{|u| If(PCount()>0,_cTabela:=u,_cTabela) },oPnlWnd2,oSize2:aPosObj[1,3]+10,013,"@!",,0,,,.F.,,.T.,,.F.,{|| Iif(_cCombo1 == "1", .F. ,.T.)},.F.,.F.,{|| /*SetDataBlc(), AGRX720UP(oBrowse3) */ },.F.,.F.,,"_cTabela",,,,.t.,.f. )
		oTGet1:cF3 := "NKP" //consulta padrão	
		
		/****************** BLOCOS ********************************/
		//adicionando os widgets de tela
		oBrowse1 := FWMBrowse():New()    
	    oBrowse1:SetAlias(__cTabPen)
	    oBrowse1:DisableDetails()
	    oBrowse1:SetMenuDef( "" )
	    oBrowse1:DisableReport(.T.) 
	    oBrowse1:DisableSeek(.T.) 
	    oBrowse1:SetProfileID("OGA262CTR")
	    
	    //marcação de itens
		oBrowse1:AddMarkColumns( { ||Iif( !Empty( (__cTabPen)->MARK = "1" ),"LBOK","LBNO" ) },{ || OGA262DB(oBrowse1), OGA262UP(oBrowse1, .F.), oBrowse1:SetFocus(), oBrowse1:GoColumn(1)  }, { || OGA262HD(oBrowse1, "B") , OGA262UP(oBrowse1), oBrowse1:SetFocus()  } )     
	    
	    For nCont := 2  to Len(aBrowCtr) //desconsiderar MARK
	        oBrowse1:AddColumn( {aBrowCtr[nCont][1]  , &("{||"+aBrowCtr[nCont][2]+"}") ,aBrowCtr[nCont][3],aBrowCtr[nCont][6],1,aBrowCtr[nCont][4],aBrowCtr[nCont][5],.f.} )
	        aADD(aFilBrowCtr,  {aBrowCtr[nCont][2], aBrowCtr[nCont][1], aBrowCtr[nCont][3], aBrowCtr[nCont][4], aBrowCtr[nCont][5], aBrowCtr[nCont][6] } )
	    Next nCont  
	
	    oBrowse1:SetFieldFilter(aFilBrowCtr)    
	    oBrowse1:Activate(oPnlWnd1)   
	    
		oDlg:Activate( , , , .t., , , EnchoiceBar(oDlg,{||lOKSelec:=.T.,oDlg:End()} , {||  oDlg:End() } /*Fechar*/,,@aButtons) )
    EndIf
    
Return 

Function OGA262TAB()
    Local nCont 	:= 0
    Local cTabela	:= ''	
	Local aStrTab 	:= {}	//Estrutura da tabela

    //-- Busca no __aCpsBrow as propriedades para criar as colunas
    For nCont := 1 to Len(__aCpsBrow) 
        aADD(aStrTab,{__aCpsBrow[nCont][2], __aCpsBrow[nCont][3], __aCpsBrow[nCont][4], __aCpsBrow[nCont][5] })
    Next nCont 
   	//-- Tabela temporaria de pendencias
   	cTabela  := GetNextAlias()
   	//-- A função AGRCRTPTB está no fonte AGRUTIL01 - Funções Genericas 
    __oArqTemp := AGRCRTPTB(cTabela, {aStrTab, {{"","CONTRATO"}}})	   	

Return cTabela


/*{Protheus.doc} OGA262DB
Marcação de itens por Double Click
@author marcelo.wesan
@since 02/10/2017
@version undefined
@param oBrwObj, object, descricao
@param cBrwName, characters, descricao
@type function
*/
static function OGA262DB(oBrwObj)
	
		if RecLock((__cTabPen),.F.)	.and. !empty((__cTabPen)->CONTRATO) //tratamento de excessao - sempre posicionado
			(__cTabPen)->MARK = IIF((__cTabPen)->MARK  == "1", "", "1")	
			MsUnlock()	
		endif
	
return


/*{Protheus.doc} OGA262UP
Função de Update do Browse
@author marcelo.wesan
@since 02/10/2017
@version undefined
@param objBrowser, object, descricao
@param lUpdAll, logical, descricao
@type function
*/
static function OGA262UP(objBrowser, lUpdAll) //tratamento de refresh	
	Default lUpdAll := .t.
	
	if lUpdAll
		objBrowser:UpdateBrowse() //reconstroi tudo	
	else	
		objBrowser:LineRefresh() //só refaz a linha
	endif
	objBrowser:GoColumn(1)	
return .t.


/*{Protheus.doc} OGA262HD
Marcação de itens no Header do Browse
@author marcelo.wesan
@since 02/10/2017
@version undefined
@param objBrowser, object, descricao
@param cBrwName, characters, descricao
@type function
*/
Static Function OGA262HD(objBrowser)
	Local cOperDat := 0
	
		DbSelectArea((__cTabPen))
		DbGoTop()
		If DbSeek((__cTabPen)->CONTRATO) 
			cOperDat := IIF((__cTabPen)->MARK  == "1", "", "1")
			While !(__cTabPen)->(Eof())
				If RecLock((__cTabPen),.f.)	
					(__cTabPen)->MARK = cOperDat
					MsUnlock()	
				EndIf			
				(__cTabPen)->( dbSkip() )	
			enddo
		endif	
return

/*
Função que monta as Temp-Tables da Rotina
@param:     Nil
@return:    boolean - True ou False
@author:    marcelo.wesan
@since:     02/10/2017
@Uso:       
*/
Static Function MontaTabel(aCpsBrow, aIdxTab)
    Local nCont 	:= 0
    Local cTabela	:= ''	
	Local aStrTab 	:= {}	//Estrutura da tabela
	Local oArqTemp	:= Nil	//Objeto retorno da tabela

    //-- Busca no aCpsBrow as propriedades para criar as colunas
    For nCont := 1 to Len(aCpsBrow) 
        aADD(aStrTab,{aCpsBrow[nCont][2], aCpsBrow[nCont][3], aCpsBrow[nCont][4], aCpsBrow[nCont][5] })
    Next nCont 
   	//-- Tabela temporaria de pendencias
   	cTabela  := GetNextAlias()
   	//-- A função AGRCRTPTB está no fonte AGRUTIL01 - Funções Genericas 
    oArqTemp := AGRCRTPTB(cTabela, {aStrTab, aIdxTab})	   	
Return cTabela


/*
Função de validação de campos
@param:     Nil
@return:    boolean - True ou False
@author:    marcelo.wesan
@since:     03/10/2017
@Uso:       
*/
Function OGA262VAD()

	If _cCombo1 =="2"
      _cTabela := _cTabela
	ElseIf _cCombo1 == "1"
	  _cTabela := "    "
	EndIf

Return

/*/{Protheus.doc} fNotaRet
    Função para verificar se o romaneio em questão é referente a uma confirmação de retenção, 
    nesse caso não deve subtrair o volume, visto que o saldo do contrato já está correto.
    @type  Static Function
    @author user
    @since 04/09/2020
    @version version
    @param pcAliasNJM, char, Alias da NJM e NJJ
    @return lRet, boolean, Indica se o romaneio é referente a uma confirmação de retenção.    
    /*/
Static Function fNotaRet(pcAliasNJM)
    Local cAliasQry  := GetNextAlias()
    Local lRet       := .F.

    BeginSql Alias cAliasQry
        SELECT COUNT(*) QTD_NF_RETENCAO
          FROM %table:N8J% N8J
        INNER JOIN %table:NKS% NKS 
           ON NKS.NKS_FILIAL = %xFilial:NKS% 
          AND NKS.NKS_CODROM = N8J.N8J_CODROM 
          AND NKS.NKS_QTDRET > 0 
          AND NKS.%notDel%
        WHERE N8J.N8J_FILIAL = %Exp:SD2->D2_FILIAL%
          AND N8J.N8J_DOC    = %Exp:SD2->D2_DOC%
          AND N8J.N8J_SERIE  = %Exp:SD2->D2_SERIE%
          AND N8J.N8J_CLIFOR = %Exp:SD2->D2_CLIENTE%
          AND N8J.N8J_LOJA   = %Exp:SD2->D2_LOJA%
          AND N8J.N8J_CODCTR = %Exp:(pcAliasNJM)->NJM_CODCTR%
          AND N8J.%NotDel%
    EndSql

    If (cAliasQry)->QTD_NF_RETENCAO > 0 
        lRet := .T.
    EndIf

    (cAliasQry)->(dbCloseArea())
    
Return lRet
