#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECR984.CH"
#INCLUDE "REPORT.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECR984()
Relatório de Presença no posto

@sample 	TECR984()
@return		oReport
@author 	Kaique Schiller
@since		25/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECR984()
Local cPerg		:= "TECR984"
Local oReport	:= Nil

If TRepInUse() 
	Pergunte(cPerg,.T.)
	oReport := Rt984RDef(cPerg)
	oReport:SetLandScape()
	oReport:PrintDialog()
EndIf

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt984RDef()
Monta as Sections para impressão do relatório

@sample Rt984RDef(cPerg)
@param 	cPerg 
@return oReport

@author 	Kaique Schiller
@since		25/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt984RDef(cPerg)
Local oReport		:= Nil				
Local oSection1 	:= Nil				
Local oSection2  	:= Nil				
Local oSection3 	:= Nil
Local oSection4		:= Nil
Local cAlias1		:= GetNextAlias()

oReport   := TReport():New("TECR984",STR0001,cPerg,{|oReport| Rt984Print(oReport, cPerg, cAlias1)},STR0001) //"Presença no posto"

oSection1 := TRSection():New(oReport	,STR0002 ,{"TFJ"},,,,,,,,,,3,,,.T.) //"Orçamento"
DEFINE CELL NAME "TFJ_CONTRT"	OF oSection1 ALIAS "TFJ"
DEFINE CELL NAME "TFJ_CONREV"	OF oSection1 ALIAS "TFJ"

oSection2 := TRSection():New(oSection1	,STR0003 ,{"TFL","ABS"},,,,,,,,,,6,,,.T.) //"Locais"
DEFINE CELL NAME "TFL_LOCAL"	OF oSection2 ALIAS "TFL"
DEFINE CELL NAME "TFL_DESCRI"	OF oSection2 TITLE STR0005 SIZE (TamSX3("ABS_DESCRI")[1]) BLOCK {|| Posicione("ABS",1, xFilial("ABS")+PadR(Trim((cAlias1)->(TFL_LOCAL)), TamSx3("ABS_DESCRI")[1]),"ABS->ABS_DESCRI") } //"Desc. Local"		
DEFINE CELL NAME "TFL_DTINI"	OF oSection2 ALIAS "TFL"
DEFINE CELL NAME "TFL_DTFIM"	OF oSection2 ALIAS "TFL"

oSection3 := TRSection():New(oSection2	,STR0004 ,{"TFF","TDW","SRJ"},,,,,,,,,,9,,,.T.) //"Postos"
DEFINE CELL NAME "TFF_COD"		OF oSection3 TITLE STR0006 ALIAS "TFF" //"Cod. Posto" 
DEFINE CELL NAME "TFF_ESCALA"	OF oSection3 ALIAS "TFF"
DEFINE CELL NAME "TFF_DESESC" 	OF oSection3 TITLE STR0007 SIZE (TamSX3("TDW_DESC")[1]) BLOCK {|| Posicione("TDW",1, xFilial("TDW")+PadR(Trim((cAlias1)->(TFF_ESCALA)), TamSx3("TDW_DESC")[1]),"TDW->TDW_DESC") } //"Desc. Local"
DEFINE CELL NAME "TFF_PERINI"	OF oSection3 ALIAS "TFF"
DEFINE CELL NAME "TFF_PERFIM"	OF oSection3 ALIAS "TFF"
DEFINE CELL NAME "TFF_FUNCAO"	OF oSection3 ALIAS "TFF"
DEFINE CELL NAME "TFF_DESFUN" 	OF oSection3 TITLE STR0008 SIZE (TamSX3("RJ_DESC")[1]) BLOCK {|| Posicione("SRJ",1, xFilial("SRJ")+PadR(Trim((cAlias1)->(TFF_FUNCAO)), TamSx3("RJ_DESC")[1]),"SRJ->RJ_DESC") } //"Desc. Função"

oSection4 := TRSection():New(oSection3	,STR0021 ,{"ABB","AA1"},,,,,,,,,,12,,,.T.) //"Agendas"
DEFINE CELL NAME "ABB_CODTEC"		OF oSection4 TITLE STR0009 ALIAS "ABB" //"Codigo do Tec"
DEFINE CELL NAME "ABB_NOMTEC" 		OF oSection4 TITLE STR0010 SIZE (TamSX3("AA1_NOMTEC")[1]) BLOCK {|| Posicione("AA1",1, xFilial("AA1")+PadR(Trim((cAlias1)->(ABB_CODTEC)), TamSx3("AA1_NOMTEC")[1]),"AA1->AA1_NOMTEC") } //"Nome do Tecnico"
DEFINE CELL NAME "ABB_DTINI"		OF oSection4 TITLE STR0011 ALIAS "ABB" //"Dt. Início"
DEFINE CELL NAME "ABB_HRINI"		OF oSection4 TITLE STR0012 ALIAS "ABB" //"Hr. Inicial"
DEFINE CELL NAME "ABB_DTFIM"		OF oSection4 TITLE STR0013 ALIAS "ABB" //"Dt. Final"
DEFINE CELL NAME "ABB_HRFIM"		OF oSection4 TITLE STR0014 ALIAS "ABB" //"Hr. Final"
DEFINE CELL NAME "ABB_HRTOT"		OF oSection4 TITLE STR0015 BLOCK {|| SUBSTR((cAlias1)->ABB_HRTOT,6,10) } ALIAS "ABB" //"Hr. Total"
DEFINE CELL NAME "ABB_TIPALOC"		OF oSection4 TITLE STR0016 BLOCK {|| Iif( Posicione("TCU",1,xFilial("TCU")+(cAlias1)->ABB_TIPOMV , "TCU_ALOCEF") == "2",STR0019,STR0020) }  ALIAS "ABB" //"Tp. Mov."#"FT"#"Alocação Normal"

DEFINE FUNCTION NAME "ABB_TOTHRN" FROM oSection4:Cell("ABB_HRTOT") OF oSection3 FUNCTION TIMESUM;
FORMULA {||Iif(oSection4:Cell("ABB_TIPALOC"):GetValue(.T.) <> "FT",oSection4:Cell("ABB_HRTOT"):GetValue(.T.),"00:00")};
			PICTURE "@ 999999999:99" TITLE STR0017 //"Total de horas normais"

DEFINE FUNCTION NAME "ABB_TOTHRFT" FROM oSection4:Cell("ABB_HRTOT") OF oSection3 FUNCTION TIMESUM;
FORMULA {||Iif(oSection4:Cell("ABB_TIPALOC"):GetValue(.T.) == "FT",oSection4:Cell("ABB_HRTOT"):GetValue(.T.),"00:00")};
			PICTURE "@ 999999999:99" TITLE STR0018 //"Total de horas FT"  

DEFINE FUNCTION NAME "TFL_TOTHRN" FROM oSection4:Cell("ABB_HRTOT") OF oSection2 FUNCTION TIMESUM;
FORMULA {||Iif(oSection4:Cell("ABB_TIPALOC"):GetValue(.T.) <> "FT",oSection4:Cell("ABB_HRTOT"):GetValue(.T.),"00:00")};
			PICTURE "@ 999999999:99" TITLE STR0017 NO END REPORT //"Total de horas normais"

DEFINE FUNCTION NAME "TFL_TOTHRFT" FROM oSection4:Cell("ABB_HRTOT") OF oSection2 FUNCTION TIMESUM;
FORMULA {||Iif(oSection4:Cell("ABB_TIPALOC"):GetValue(.T.) == "FT",oSection4:Cell("ABB_HRTOT"):GetValue(.T.),"00:00")};
			PICTURE "@ 999999999:99" TITLE STR0018 NO END REPORT //"Total de horas FT"

DEFINE FUNCTION NAME "TFJ_TOTHRN" FROM oSection4:Cell("ABB_HRTOT") OF oSection1 FUNCTION TIMESUM;
FORMULA {||Iif(oSection4:Cell("ABB_TIPALOC"):GetValue(.T.) <> "FT",oSection4:Cell("ABB_HRTOT"):GetValue(.T.),"00:00")};
			PICTURE "@ 999999999:99" TITLE STR0017 NO END REPORT //"Total de horas normais"

DEFINE FUNCTION NAME "TFJ_TOTHRFT" FROM oSection4:Cell("ABB_HRTOT") OF oSection1 FUNCTION TIMESUM;
FORMULA {||Iif(oSection4:Cell("ABB_TIPALOC"):GetValue(.T.) == "FT",oSection4:Cell("ABB_HRTOT"):GetValue(.T.),"00:00")};
			PICTURE "@ 999999999:99" TITLE STR0018 NO END REPORT //"Total de horas FT"

If !IsBlind()
	If MV_PAR11 == 2
		oSection4:Hide()
	Endif
EndIf

Return oReport

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt984Print()
Monta a Query e imprime o relatorio de acordo com os parametros

@sample 	Rt984Print(oReport, cPerg, cAlias1)
@param		oReport, 	Object,	Objeto do relatório de postos vagos
			cPerg, 		String,	Nome do grupo de perguntas
			cAlias1,	String,	Nome do alias da Query do relatório 
			
@return 	Nenhum
@author 	Kaique Schiller
@since		27/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt984Print(oReport, cPerg, cAlias1)
Local oSection1	:= oReport:Section(1)		
Local oSection2	:= oSection1:Section(1) 	
Local oSection3	:= oSection2:Section(1) 	
Local oSection4	:= oSection3:Section(1)

BEGIN REPORT QUERY oSection1

BeginSQL Alias cAlias1

	SELECT TFJ_CONTRT, TFJ_CONREV, TFL_LOCAL, TFL_DTINI, TFL_DTFIM, 
           TFF_COD, TFF_ESCALA, TFF_FUNCAO, TFF_QTDVEN, TFF_PERINI, TFF_PERFIM, 
           TFL_CODPAI, TFJ_CODIGO, TFF_CODPAI, TFL_CODIGO, ABB_CODTEC, ABB_HRINI,
		   ABB_HRFIM, ABB_DTINI, ABB_DTFIM, ABB_HRTOT, ABQ_CODTFF,ABB_TIPOMV
	FROM %table:TFJ% TFJ
	INNER JOIN %table:TFL% TFL ON (TFL.TFL_FILIAL = %xFilial:TFL% AND TFL.TFL_CODPAI = TFJ_CODIGO AND TFL.%NotDel%)
	INNER JOIN %table:TFF% TFF ON (TFF.TFF_FILIAL = %xFilial:TFF% AND TFF.TFF_CODPAI = TFL.TFL_CODIGO AND TFF.%NotDel%)
	INNER JOIN %table:ABQ% ABQ ON (ABQ.ABQ_FILTFF = %xFilial:TFF% AND ABQ.ABQ_CODTFF = TFF.TFF_COD AND ABQ.ABQ_FILIAL = %xFilial:ABQ% AND ABQ.%NotDel%)
	INNER JOIN %table:ABB% ABB ON (ABB.ABB_FILIAL = %xFilial:ABB% AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND ABB.%NotDel%)
	INNER JOIN %table:TDV% TDV ON (TDV.TDV_FILIAL = %xFilial:TDV% AND ABB.ABB_CODIGO = TDV.TDV_CODABB AND (TDV.TDV_DTREF BETWEEN TFF.TFF_PERINI AND TFF.TFF_PERFIM) AND TDV.%NotDel% )
	WHERE TFJ.TFJ_FILIAL=%xFilial:TFJ%
		AND TFJ.TFJ_CONTRT <> ''
		AND TFF.TFF_ESCALA <> ''
		AND TFJ.TFJ_STATUS = '1'
		AND TFJ.%NotDel%
		AND ABB.ABB_ATIVO = '1'
		AND ABB.ABB_ATENDE = '1'
        AND TDV.TDV_DTREF 	BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        AND TFF.TFF_ESCALA 	BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        AND TFL.TFL_LOCAL 	BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
        AND TFJ.TFJ_CONTRT 	BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
        AND TFF.TFF_COD 	BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10%
	ORDER BY TFJ_CODIGO,TFL_CODIGO,TFF_COD,ABB_CODTEC,TDV.TDV_DTREF,ABB.ABB_DTINI,ABB_HRINI

EndSql

END REPORT QUERY oSection1

(cAlias1)->(DbGoTop())

oSection2:SetParentQuery()
oSection2:SetParentFilter({|cParam| (cAlias1)->TFJ_CODIGO == cParam},{|| (cAlias1)->TFL_CODPAI })

oSection3:SetParentQuery()
oSection3:SetParentFilter({|cParam| (cAlias1)->TFL_CODIGO == cParam},{|| (cAlias1)->TFF_CODPAI })

oSection4:SetParentQuery()
oSection4:SetParentFilter({|cParam| (cAlias1)->TFF_COD == cParam},{|| (cAlias1)->ABQ_CODTFF })

oSection1:Print()

(cAlias1)->(DbCloseArea())
          
Return(.T.)
