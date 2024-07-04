#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TECR871.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECR871()
Relatório de Reajuste Retroativo

@sample 	TECR871()
@return		oReport
@author 	Kaique Schiller
@since		25/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECR871()
Local cPerg		:= "TECR871"
Local oReport	:= Nil

If TecHasPerg("MV_PAR01", cPerg)
	If TRepInUse()
		Pergunte(cPerg,.T.)
		oReport := Rt871RDef(cPerg)
		oReport:SetLandScape()
		oReport:PrintDialog()
	EndIf
Else
	Help(,, "TECR871",, STR0034, 1, 0) //"Não é possível utilizar o relatório, realize a inclusão do pergunte TECR871."
Endif

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt871RDef()
Monta as Sections para impressão do relatório

@sample Rt871RDef(cPerg)
@param 	cPerg 
@return oReport

@author 	Kaique Schiller
@since		25/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt871RDef(cPerg)
Local oReport		:= Nil				
Local oSection1 	:= Nil				
Local oSection2  	:= Nil				
Local oSection3 	:= Nil
Local oSection4 	:= Nil
Local cAlias1		:= GetNextAlias()
Local nJan			:= 0
Local nFev			:= 0
Local nMar			:= 0
Local nAbr			:= 0
Local nMai			:= 0
Local nJun			:= 0
Local nJul			:= 0
Local nAgo			:= 0
Local nSet			:= 0
Local nOut			:= 0
Local nNov			:= 0
Local nDez			:= 0

MV_PAR11 := SubStr(MV_PAR11, 1, 2)+"/"+SubStr(MV_PAR11, 3, 4)

oReport   := TReport():New("TECR871",STR0001,cPerg,{|oReport| Rt871Print(oReport, cPerg, cAlias1)},STR0001) //"Reajuste Retroativo"

oSection1 := TRSection():New(oReport	,STR0002 ,{"TFJ"},,,,,,,,,,3,,,.T.) //"Orçamento"
DEFINE CELL NAME "TFJ_CONTRT"	OF oSection1 ALIAS "TFJ"
DEFINE CELL NAME "TFJ_CONREV"	OF oSection1 ALIAS "TFJ"
DEFINE CELL NAME "TFJ_CODIGO"	OF oSection1 ALIAS "TFJ"
DEFINE CELL NAME "TFJ_CODENT"	OF oSection1 ALIAS "TFJ" TITLE STR0003 //"Cod. Cliente"
DEFINE CELL NAME "TFJ_LOJA"		OF oSection1 ALIAS "TFJ" TITLE STR0004 //"Loja"
DEFINE CELL NAME "TFJ_DESCENT"	OF oSection1 TITLE STR0005 SIZE (TamSX3("A1_NOME")[1]) BLOCK {|| Posicione("SA1",1, xFilial("SA1")+(cAlias1)->(TFJ_CODENT+TFJ_LOJA),"SA1->A1_NOME") } //"Desc. Cliente"

oSection2 := TRSection():New(oSection1	,STR0006,{"TFL","ABS"},,,,,,,,,,6,,,.T.) //"Locais"
DEFINE CELL NAME "TFL_LOCAL"	OF oSection2 ALIAS "TFL"
DEFINE CELL NAME "TFL_DESCRI"	OF oSection2 TITLE STR0007 SIZE (TamSX3("ABS_DESCRI")[1]) BLOCK {|| Posicione("ABS",1, xFilial("ABS")+PadR(Trim((cAlias1)->(TFL_LOCAL)), TamSx3("ABS_DESCRI")[1]),"ABS->ABS_DESCRI") } //"Desc. Local"		
DEFINE CELL NAME "TFL_DTINI"	OF oSection2 ALIAS "TFL"
DEFINE CELL NAME "TFL_DTFIM"	OF oSection2 ALIAS "TFL"

oSection3 := TRSection():New(oSection2	,"Postos" ,{"TFF","TDW","SRJ","TGT"},,,,,,,,,,9,,,.T.) //"Postos"
DEFINE CELL NAME "TFF_COD"		OF oSection3 TITLE STR0008  ALIAS "TFF" //"Cod. Posto" 
DEFINE CELL NAME "TFF_PRODUT"	OF oSection3 ALIAS "TFF"
DEFINE CELL NAME "TFF_DESCPRD"	OF oSection3 TITLE STR0009 SIZE (TamSX3("B1_DESC")[1]) BLOCK {|| Posicione("SB1",1, xFilial("SB1")+(cAlias1)->(TFF_PRODUT),"SB1->B1_DESC") } //"Desc. Produto"		
DEFINE CELL NAME "TFF_ESCALA"	OF oSection3 ALIAS "TFF"
DEFINE CELL NAME "TFF_DESESC" 	OF oSection3 TITLE STR0010 SIZE (TamSX3("TDW_DESC")[1]) BLOCK {|| Posicione("TDW",1, xFilial("TDW")+PadR(Trim((cAlias1)->(TFF_ESCALA)), TamSx3("TDW_DESC")[1]),"TDW->TDW_DESC") } //"Desc. Escala"
DEFINE CELL NAME "TFF_FUNCAO"	OF oSection3 ALIAS "TFF"
DEFINE CELL NAME "TFF_DESFUN" 	OF oSection3 TITLE STR0011 SIZE (TamSX3("RJ_DESC")[1]) BLOCK {|| Posicione("SRJ",1, xFilial("SRJ")+PadR(Trim((cAlias1)->(TFF_FUNCAO)), TamSx3("RJ_DESC")[1]),"SRJ->RJ_DESC") } //"Desc. Função"
DEFINE CELL NAME "TFF_PERINI"	OF oSection3 ALIAS "TFF" TITLE STR0012 //"Inicio Posto"
DEFINE CELL NAME "TFF_PERFIM"	OF oSection3 ALIAS "TFF" TITLE STR0013 //"Final Posto"
DEFINE CELL NAME "TGT_COMPET"	OF oSection3 TITLE STR0014  BLOCK {|| MV_PAR11 } //"Competência" 
DEFINE CELL NAME "TGT_INDICE"	OF oSection3 TITLE STR0015 	BLOCK {|| TGTReajust((cAlias1)->(TFF_COD),MV_PAR11,"TGT_INDICE") } //"Indice"
DEFINE CELL NAME "TGT_VALOR"	OF oSection3 TITLE STR0016 	BLOCK {|| TGTReajust((cAlias1)->(TFF_COD),MV_PAR11,"TGT_VALOR") } //"Valor" 
DEFINE CELL NAME "TGT_DTINI"	OF oSection3 TITLE STR0017 	BLOCK {|| TGTReajust((cAlias1)->(TFF_COD),MV_PAR11,"TGT_DTINI") } //"Dia Inicio Reaj"
DEFINE CELL NAME "TGT_DTFIM"	OF oSection3 TITLE STR0018  BLOCK {|| TGTReajust((cAlias1)->(TFF_COD),MV_PAR11,"TGT_DTFIM") } //"Dia Final Reaj"

oSection4 := TRSection():New(oSection3	,STR0019 ,{"TFF","TGT"},,,,,,,,,,12,,,.T.) //"Meses do Reajuste Retroativo"
DEFINE CELL NAME "TGT_JAN"	OF oSection4 SIZE 15 TITLE STR0020 	BLOCK {|| Transform( nJan := VlrReajust((cAlias1)->TFJ_CODIGO,(cAlias1)->TFJ_CONTRT,(cAlias1)->TFJ_CONREV,(cAlias1)->TFF_ENCE,(cAlias1)->TFF_DTENCE,(cAlias1)->TFF_COD,MV_PAR11,(cAlias1)->TFF_PERINI,(cAlias1)->TFF_PERFIM,(cAlias1)->TFF_QTDVEN,(cAlias1)->TFF_PRCVEN,1) , "@R 999,999,999.99" ) } //"Janeiro"
DEFINE CELL NAME "TGT_FEV"	OF oSection4 SIZE 15 TITLE STR0021 	BLOCK {|| Transform( nFev := VlrReajust((cAlias1)->TFJ_CODIGO,(cAlias1)->TFJ_CONTRT,(cAlias1)->TFJ_CONREV,(cAlias1)->TFF_ENCE,(cAlias1)->TFF_DTENCE,(cAlias1)->TFF_COD,MV_PAR11,(cAlias1)->TFF_PERINI,(cAlias1)->TFF_PERFIM,(cAlias1)->TFF_QTDVEN,(cAlias1)->TFF_PRCVEN,2) , "@R 999,999,999.99" ) } //"Fevereiro"
DEFINE CELL NAME "TGT_MAR"	OF oSection4 SIZE 15 TITLE STR0022 	BLOCK {|| Transform( nMar := VlrReajust((cAlias1)->TFJ_CODIGO,(cAlias1)->TFJ_CONTRT,(cAlias1)->TFJ_CONREV,(cAlias1)->TFF_ENCE,(cAlias1)->TFF_DTENCE,(cAlias1)->TFF_COD,MV_PAR11,(cAlias1)->TFF_PERINI,(cAlias1)->TFF_PERFIM,(cAlias1)->TFF_QTDVEN,(cAlias1)->TFF_PRCVEN,3) , "@R 999,999,999.99" ) } //"Março"
DEFINE CELL NAME "TGT_ABR"	OF oSection4 SIZE 15 TITLE STR0023 	BLOCK {|| Transform( nAbr := VlrReajust((cAlias1)->TFJ_CODIGO,(cAlias1)->TFJ_CONTRT,(cAlias1)->TFJ_CONREV,(cAlias1)->TFF_ENCE,(cAlias1)->TFF_DTENCE,(cAlias1)->TFF_COD,MV_PAR11,(cAlias1)->TFF_PERINI,(cAlias1)->TFF_PERFIM,(cAlias1)->TFF_QTDVEN,(cAlias1)->TFF_PRCVEN,4) , "@R 999,999,999.99" ) } //"Abril"
DEFINE CELL NAME "TGT_MAI"	OF oSection4 SIZE 15 TITLE STR0024	BLOCK {|| Transform( nMai := VlrReajust((cAlias1)->TFJ_CODIGO,(cAlias1)->TFJ_CONTRT,(cAlias1)->TFJ_CONREV,(cAlias1)->TFF_ENCE,(cAlias1)->TFF_DTENCE,(cAlias1)->TFF_COD,MV_PAR11,(cAlias1)->TFF_PERINI,(cAlias1)->TFF_PERFIM,(cAlias1)->TFF_QTDVEN,(cAlias1)->TFF_PRCVEN,5) , "@R 999,999,999.99" ) } //"Maio"
DEFINE CELL NAME "TGT_JUN"	OF oSection4 SIZE 15 TITLE STR0025 	BLOCK {|| Transform( nJun := VlrReajust((cAlias1)->TFJ_CODIGO,(cAlias1)->TFJ_CONTRT,(cAlias1)->TFJ_CONREV,(cAlias1)->TFF_ENCE,(cAlias1)->TFF_DTENCE,(cAlias1)->TFF_COD,MV_PAR11,(cAlias1)->TFF_PERINI,(cAlias1)->TFF_PERFIM,(cAlias1)->TFF_QTDVEN,(cAlias1)->TFF_PRCVEN,6) , "@R 999,999,999.99" ) } //"Junho"
DEFINE CELL NAME "TGT_JUL"	OF oSection4 SIZE 15 TITLE STR0026 	BLOCK {|| Transform( nJul := VlrReajust((cAlias1)->TFJ_CODIGO,(cAlias1)->TFJ_CONTRT,(cAlias1)->TFJ_CONREV,(cAlias1)->TFF_ENCE,(cAlias1)->TFF_DTENCE,(cAlias1)->TFF_COD,MV_PAR11,(cAlias1)->TFF_PERINI,(cAlias1)->TFF_PERFIM,(cAlias1)->TFF_QTDVEN,(cAlias1)->TFF_PRCVEN,7) , "@R 999,999,999.99" ) } //"Julho"
DEFINE CELL NAME "TGT_AGO"	OF oSection4 SIZE 15 TITLE STR0027 	BLOCK {|| Transform( nAgo := VlrReajust((cAlias1)->TFJ_CODIGO,(cAlias1)->TFJ_CONTRT,(cAlias1)->TFJ_CONREV,(cAlias1)->TFF_ENCE,(cAlias1)->TFF_DTENCE,(cAlias1)->TFF_COD,MV_PAR11,(cAlias1)->TFF_PERINI,(cAlias1)->TFF_PERFIM,(cAlias1)->TFF_QTDVEN,(cAlias1)->TFF_PRCVEN,8) , "@R 999,999,999.99" ) } //"Agosto"
DEFINE CELL NAME "TGT_SET"	OF oSection4 SIZE 15 TITLE STR0028 	BLOCK {|| Transform( nSet := VlrReajust((cAlias1)->TFJ_CODIGO,(cAlias1)->TFJ_CONTRT,(cAlias1)->TFJ_CONREV,(cAlias1)->TFF_ENCE,(cAlias1)->TFF_DTENCE,(cAlias1)->TFF_COD,MV_PAR11,(cAlias1)->TFF_PERINI,(cAlias1)->TFF_PERFIM,(cAlias1)->TFF_QTDVEN,(cAlias1)->TFF_PRCVEN,9) , "@R 999,999,999.99" ) } //"Setembro"
DEFINE CELL NAME "TGT_OUT"	OF oSection4 SIZE 15 TITLE STR0029 	BLOCK {|| Transform( nOut := VlrReajust((cAlias1)->TFJ_CODIGO,(cAlias1)->TFJ_CONTRT,(cAlias1)->TFJ_CONREV,(cAlias1)->TFF_ENCE,(cAlias1)->TFF_DTENCE,(cAlias1)->TFF_COD,MV_PAR11,(cAlias1)->TFF_PERINI,(cAlias1)->TFF_PERFIM,(cAlias1)->TFF_QTDVEN,(cAlias1)->TFF_PRCVEN,10) , "@R 999,999,999.99" ) } //"Outubro"
DEFINE CELL NAME "TGT_NOV"	OF oSection4 SIZE 15 TITLE STR0030 	BLOCK {|| Transform( nNov := VlrReajust((cAlias1)->TFJ_CODIGO,(cAlias1)->TFJ_CONTRT,(cAlias1)->TFJ_CONREV,(cAlias1)->TFF_ENCE,(cAlias1)->TFF_DTENCE,(cAlias1)->TFF_COD,MV_PAR11,(cAlias1)->TFF_PERINI,(cAlias1)->TFF_PERFIM,(cAlias1)->TFF_QTDVEN,(cAlias1)->TFF_PRCVEN,11) , "@R 999,999,999.99" ) } //"Novembro"
DEFINE CELL NAME "TGT_DEZ"	OF oSection4 SIZE 15 TITLE STR0031 	BLOCK {|| Transform( nDez := VlrReajust((cAlias1)->TFJ_CODIGO,(cAlias1)->TFJ_CONTRT,(cAlias1)->TFJ_CONREV,(cAlias1)->TFF_ENCE,(cAlias1)->TFF_DTENCE,(cAlias1)->TFF_COD,MV_PAR11,(cAlias1)->TFF_PERINI,(cAlias1)->TFF_PERFIM,(cAlias1)->TFF_QTDVEN,(cAlias1)->TFF_PRCVEN,12) , "@R 999,999,999.99" ) } //"Dezembro"
DEFINE CELL NAME "TGT_TOT"	OF oSection4 SIZE 15 TITLE STR0032 	BLOCK {|| Transform( nJan+nFev+nMar+nAbr+nMai+nJun+nJul+nAgo+nSet+nOut+nNov+nDez, "@R 999,999,999.99" ) } //"Total"

Return oReport

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt871Print()
Monta a Query e imprime o relatorio de acordo com os parametros

@sample 	Rt871Print(oReport, cPerg, cAlias1)
@param		oReport, 	Object,	Objeto do relatório de postos vagos
			cPerg, 		String,	Nome do grupo de perguntas
			cAlias1,	String,	Nome do alias da Query do relatório 
			
@return 	Nenhum
@author 	Kaique Schiller
@since		27/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt871Print(oReport, cPerg, cAlias1)
Local oSection1	:= oReport:Section(1)		
Local oSection2	:= oSection1:Section(1) 	
Local oSection3	:= oSection2:Section(1) 	
Local oSection4	:= oSection3:Section(1)

BEGIN REPORT QUERY oSection1

BeginSQL Alias cAlias1

	SELECT TFJ_CONTRT, TFJ_CONREV, TFJ_CODENT, TFJ_LOJA, TFL_LOCAL, TFL_DTINI, TFL_DTFIM, 
           TFF_COD, TFF_ESCALA, TFF_FUNCAO, TFF_QTDVEN, TFF_PERINI, TFF_PERFIM, 
           TFL_CODPAI, TFJ_CODIGO, TFF_CODPAI, TFL_CODIGO, TFF_CONTRT, TFF_CONREV, TFF_ENCE, TFF_DTENCE,TFF_PRCVEN,
		   TFF_PRODUT
	FROM %table:TFJ% TFJ
	INNER JOIN %table:TFL% TFL ON (TFL.TFL_FILIAL = %xFilial:TFL% AND TFL.TFL_CODPAI = TFJ_CODIGO AND TFL.%NotDel%)
	INNER JOIN %table:TFF% TFF ON (TFF.TFF_FILIAL = %xFilial:TFF% AND TFF.TFF_CODPAI = TFL.TFL_CODIGO AND TFF.%NotDel%)
	INNER JOIN %table:ABS% ABS ON (ABS.ABS_FILIAL = %xFilial:ABS% AND ABS.ABS_LOCAL  = TFL.TFL_LOCAL AND ABS.%NotDel%)
	WHERE TFJ.TFJ_FILIAL=%xFilial:TFJ%
		AND TFJ.TFJ_CONTRT <> ''
		AND TFJ.TFJ_STATUS = '1'
		AND TFJ.%NotDel%
        AND TFJ.TFJ_CONTRT 	BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        AND TFL.TFL_LOCAL 	BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        AND TFF.TFF_COD 	BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
        AND ABS.ABS_CODIGO 	BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR09%
        AND ABS.ABS_LOJA 	BETWEEN %Exp:MV_PAR08% AND %Exp:MV_PAR10%
		AND EXISTS (SELECT 1 
					FROM %table:TGT% TGT 
					WHERE TGT.TGT_FILIAL = %xFilial:TGT% 
						AND TGT.TGT_TPITEM = "TFF" 
						AND TGT.TGT_CDITEM = TFF.TFF_COD 
						AND TGT.TGT_EXCEDT = '1'
						AND TGT.TGT_COMPET = %Exp:MV_PAR11%
						AND TGT.%NotDel%)

	ORDER BY TFJ_CODIGO,TFL_CODIGO,TFF_COD
EndSql

END REPORT QUERY oSection1

(cAlias1)->(DbGoTop())

oSection2:SetParentQuery()
oSection2:SetParentFilter({|cParam| (cAlias1)->TFJ_CODIGO == cParam},{|| (cAlias1)->TFL_CODPAI })

oSection3:SetParentQuery()
oSection3:SetParentFilter({|cParam| (cAlias1)->TFL_CODIGO == cParam},{|| (cAlias1)->TFF_CODPAI })

oSection4:SetParentQuery()
oSection4:SetParentFilter({|cParam| (cAlias1)->TFF_COD == cParam},{|| (cAlias1)->TFF_COD })

oSection1:Print()

(cAlias1)->(DbCloseArea())
		
Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VlrReajust
(long_description) Valor do Reajuste da tabela TGT
@author Kaique Schiller
@since 25/05/2022
@return nValRet, Numerico, Valor reajustado
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function VlrReajust(cCodOrc,cContr,cRevAtu,cEncerr,dDtEncerr,cCodTFF,cCompet,dDtIniTFF,dDtFimTFF,nQtdVend,nPrcVen,nMes)
Local nValRet := 0
Local aTFFAtu  := {}
Local aMesVlr  := {}
Default cCodOrc := "" 
Default cContr := ""
Default cRevAtu := "" 
Default cEncerr := ""
Default dDtEncerr := sTod("")
Default cCodTFF := ""
Default cCompet := ""
Default dDtIniTFF := sTod("")
Default dDtFimTFF := sTod("") 
Default nQtdVend := 0 
Default nPrcVen := 0
Default nMes	:= 0

DbSelectArea("TGT")
TGT->(DbSetOrder(2)) //TGT_FILIAL+TGT_TPITEM+TGT_CDITEM+TGT_COMPET
If TGT->(DbSeek(xFilial("TGT")+"TFF"+cCodTFF+cCompet)) 
	While TGT->(!EOF()) .And. xFilial("TGT") == TGT->TGT_FILIAL .And.;
										TGT->TGT_CODTFJ = cCodOrc.And.;
										TGT->TGT_TPITEM == "TFF" .And.;
										TGT->TGT_CDITEM == cCodTFF .And.;
										TGT->TGT_COMPET == cCompet
		If TGT->TGT_EXCEDT == "1"
			aTFFAtu := {}
			aAdd(aTFFAtu,{"TFF_COD"		,cCodTFF})
			aAdd(aTFFAtu,{"TFF_QTDVEN"	,nQtdVend})
			aAdd(aTFFAtu,{"TFF_PRCVEN"	,nPrcVen})
			If dDtIniTFF <= TGT->TGT_DTINI
				aAdd(aTFFAtu,{"TFF_PERINI",TGT->TGT_DTINI})
			Else 
				aAdd(aTFFAtu,{"TFF_PERINI",dDtIniTFF})
			EndIf
			If dDtFimTFF >= TGT->TGT_DTFIM
				aAdd(aTFFAtu,{"TFF_PERFIM",TGT->TGT_DTFIM})
			Else 
				aAdd(aTFFAtu,{"TFF_PERFIM",dDtFimTFF})
			EndIf
			aTFFAtu := U_GetTFFAnt("TFF",cContr,cRevAtu,cCodTFF,TGT->TGT_DTINI,TGT->TGT_DTFIM,aTFFAtu,cEncerr = '1',dDtEncerr)
			If !Empty(aTFFAtu)
				aMesVlr := U_ValRetMes(aTFFAtu,nMes,TGT->TGT_INDICE,TGT->TGT_VALREA)
				If !Empty(aMesVlr)
					nValRet := aMesVlr[1,2]
					Exit
				Endif
			Endif
		Endif
		TGT->(DbSkip())
	EndDo
Endif

Return nValRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Atr87VlCmp
(long_description) Validação da competência do pergunte TECR871
@type  Function 
@author Kaique Schiller
@since 25/05/2022
@return lRet, Logico, Retorno validação da competência do pergunte TECR871
/*/
//--------------------------------------------------------------------------------------------------------------------
Function Atr87VlCmp(cCompet)
Local lRet := .T.

If Empty(Strtran(cCompet,"/"))
	Help(,, "Atr87VlCmp",, STR0033, 1, 0) //"A competência não está preenchida."
	lRet := .F.
Endif

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TGTReajust
(long_description) Query para selecionar as informações da TGT
@type  Function 
@author Kaique Schiller
@since 25/05/2022
@return cRet, Caracter, Retorno do campo da query
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TGTReajust(cCodTFF,cCompet,cCampo)
Local cCampRet := ""
Local cAliasTGT := ""

If !Empty(cCodTFF)
	cAliasTGT := GetNextAlias()
	BeginSql Alias cAliasTGT
	
	COLUMN TGT_DTINI AS DATE 
	COLUMN TGT_DTFIM AS DATE 

	SELECT TGT_INDICE,
		   TGT_VALOR,
		   TGT_DTINI,
		   TGT_DTFIM
		FROM %Table:TGT% TGT
		WHERE TGT.TGT_FILIAL = %xFilial:ABR%
			AND TGT.TGT_TPITEM = %Exp:"TFF"%
			AND TGT.TGT_CDITEM = %Exp:cCodTFF%
			AND TGT.TGT_COMPET = %Exp:cCompet%
			AND TGT.TGT_EXCEDT = '1'
			AND TGT.%NotDel%
	EndSql

	If (cAliasTGT)->(!Eof())
		cCampRet := (cAliasTGT)->&(cCampo)
	Endif

	(cAliasTGT)->(DbCloseArea())
Endif

Return cCampRet
