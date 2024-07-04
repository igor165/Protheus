#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECR961.CH"
#INCLUDE "REPORT.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECR961()
Relatório de Escala de Serviços

@sample 	TECR961()
@return		oReport
@author 	Kaique Schiller
@since		25/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECR961()
Local cPerg		:= "TECR961"
Local oReport	:=  Nil

If TRepInUse() 
	Pergunte(cPerg,.F.)		
	oReport := Rt961RDef(cPerg)
	oReport:SetLandScape()
	oReport:PrintDialog()
EndIf

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt961RDef()
Monta as Sections para impressão do relatório

@sample Rt961RDef(cPerg)
@param 	cPerg 
@return oReport

@author 	Kaique Schiller
@since		25/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt961RDef(cPerg)
Local oReport		:= Nil				
Local oSection1 	:= Nil				
Local oSection2  	:= Nil				
Local oSection3 	:= Nil
Local oSection4 	:= Nil
Local cAlias1		:= GetNextAlias()

oReport   := TReport():New("TECR961",STR0001,cPerg,{|oReport| Rt961Print(oReport, cPerg, cAlias1)},STR0001) //"Escala de Serviços"

oSection1 := TRSection():New(oReport	,FwX2Nome("TFJ") ,{"TFJ"},,,,,,,,,,,,,.T.)
TRPosition():New(oSection1,"TFJ",1,{|| xFilial("TFJ") + (cAlias1)->TFJ_CODIGO })
DEFINE CELL NAME "TFJ_CONTRT"	OF oSection1 ALIAS "TFJ" BLOCK {|| TFJ->TFJ_CONTRT }
DEFINE CELL NAME "TFJ_CONREV"	OF oSection1 ALIAS "TFJ" BLOCK {|| TFJ->TFJ_CONREV }

oSection2 := TRSection():New(oSection1	,FwX2Nome("TFL") ,{"TFL","ABS"},,,,,,,,,,3,,,.T.)
TRPosition():New(oSection2,"TFL",1,{|| xFilial("TFL") + (cAlias1)->TFL_CODIGO })
DEFINE CELL NAME "TFL_LOCAL"	OF oSection2 ALIAS "TFL" BLOCK {|| TFL->TFL_LOCAL }
DEFINE CELL NAME "TFL_DESCRI"	OF oSection2 ALIAS "TFL" TITLE STR0002 SIZE (TamSX3("ABS_DESCRI")[1]) BLOCK {|| Posicione("ABS",1, xFilial("ABS")+PadR(Trim(TFL->TFL_LOCAL), TamSx3("ABS_DESCRI")[1]),"ABS->ABS_DESCRI") } //"Desc. Local"
DEFINE CELL NAME "TFL_DTINI"	OF oSection2 ALIAS "TFL" BLOCK {|| TFL->TFL_DTINI }
DEFINE CELL NAME "TFL_DTFIM"	OF oSection2 ALIAS "TFL" BLOCK {|| TFL->TFL_DTFIM }

oSection3 := TRSection():New(oSection2	,FwX2Nome("TFF") ,{"TFF","TDW","SRJ"},,,,,,,,,,6,,,.T.)
TRPosition():New(oSection3,"TFF",1,{|| xFilial("TFF") + (cAlias1)->TFF_COD })
DEFINE CELL NAME "TFF_COD"		OF oSection3 TITLE STR0003  ALIAS "TFF" //"Cod. Posto" 
DEFINE CELL NAME "TFF_ESCALA"	OF oSection3 ALIAS "TFF" BLOCK {|| TFF->TFF_ESCALA }
DEFINE CELL NAME "TFF_DESESC" 	OF oSection3 TITLE STR0004 SIZE (TamSX3("TDW_DESC")[1]) BLOCK {|| Posicione("TDW",1, xFilial("TDW")+PadR(Trim(TFF->(TFF_ESCALA)), TamSx3("TDW_DESC")[1]),"TDW->TDW_DESC") } //"Desc. Escala"
DEFINE CELL NAME "TFF_FUNCAO"	OF oSection3 ALIAS "TFF" BLOCK {|| TFF->TFF_FUNCAO }
DEFINE CELL NAME "TFF_DESFUN" 	OF oSection3 TITLE STR0005 SIZE (TamSX3("RJ_DESC")[1]) BLOCK {|| Posicione("SRJ",1, xFilial("SRJ")+PadR(Trim(TFF->(TFF_FUNCAO)), TamSx3("RJ_DESC")[1]),"SRJ->RJ_DESC") } //"Desc. Função"
DEFINE CELL NAME "TFF_QTDVEN"	OF oSection3 ALIAS "TFF" BLOCK {|| TFF->TFF_QTDVEN } TITLE STR0006 //"Qtd. Posto"
DEFINE CELL NAME "TFF_PERINI"	OF oSection3 ALIAS "TFF" BLOCK {|| TFF->TFF_PERINI }
DEFINE CELL NAME "TFF_PERFIM"	OF oSection3 ALIAS "TFF" BLOCK {|| TFF->TFF_PERFIM }

oSection4 := TRSection():New(oSection3	,FwX2Nome("AA1") ,{"AA1"},,,,,,,,,,9,,,.T.)
TRPosition():New(oSection4,"AA1",1,{|| xFilial("AA1") + (cAlias1)->AA1_CODTEC }) 
DEFINE CELL NAME "AA1_CODTEC"		OF oSection4 ALIAS "AA1" 
DEFINE CELL NAME "AA1_NOMTEC"	 	OF oSection4 ALIAS "AA1" BLOCK {|| AA1->AA1_NOMTEC }
DEFINE CELL NAME "AA1_QTDAGD"	 	OF oSection4 ALIAS TITLE STR0007 BLOCK {|| At961QtdAg(TFF->TFF_COD,AA1->AA1_CODTEC) } //"Qtd. Dias Trab"

oSection4:Cell("AA1_QTDAGD"):SetAlign("LEFT")
Return oReport

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt961Print()
Monta a Query e imprime o relatorio de acordo com os parametros

@sample 	Rt961Print(oReport, cPerg, cAlias1)
@param		oReport, 	Object,	Objeto do relatório de postos vagos
			cPerg, 		String,	Nome do grupo de perguntas
			cAlias1,	String,	Nome do alias da Query do relatório 
			
@return 	Nenhum
@author 	Kaique Schiller
@since		27/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt961Print(oReport, cPerg, cAlias1)
Local oSection1	:= oReport:Section(1)		
Local oSection2	:= oSection1:Section(1)
Local oSection3	:= oSection2:Section(1)
Local oSection4	:= oSection3:Section(1)

BEGIN REPORT QUERY oSection1

BeginSQL Alias cAlias1

	SELECT DISTINCT TFJ_CODIGO,
	       TFL_CODIGO,
    	   TFF_COD,
		   AA1_CODTEC
	FROM %table:TFJ% TFJ
	INNER JOIN %table:TFL% TFL ON (TFL.TFL_FILIAL=%xFilial:TFL% AND TFL.TFL_CODPAI=TFJ_CODIGO AND TFL.%NotDel%)
	INNER JOIN %table:TFF% TFF ON (TFF.TFF_FILIAL=%xFilial:TFF% AND TFF.TFF_CODPAI=TFL.TFL_CODIGO AND TFF.%NotDel%)
	INNER JOIN %table:ABQ% ABQ ON (ABQ.ABQ_FILIAL=%xFilial:ABQ% AND ABQ.ABQ_CODTFF=TFF.TFF_COD AND ABQ.ABQ_FILTFF=TFF.TFF_FILIAL AND ABQ.%NotDel%)
	INNER JOIN %table:ABB% ABB ON (ABB.ABB_FILIAL=%xFilial:ABB% AND ABB.ABB_IDCFAL=ABQ.ABQ_CONTRT||ABQ.ABQ_ITEM||'CN9' AND ABB.%NotDel%)
	INNER JOIN %table:TDV% TDV ON (TDV.TDV_FILIAL=%xFilial:TDV% AND TDV.TDV_CODABB=ABB.ABB_CODIGO AND TDV.%NotDel%)
	INNER JOIN %table:AA1% AA1 ON (AA1.AA1_FILIAL=%xFilial:AA1% AND AA1.AA1_CODTEC=ABB.ABB_CODTEC AND AA1.%NotDel%)
	WHERE TFJ.TFJ_FILIAL=%xFilial:TFJ%
		AND TFJ.%NotDel%
        AND AA1.AA1_CODTEC BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        AND TDV.TDV_DTREF  BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        AND TFL.TFL_LOCAL  BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
        AND TFF.TFF_ESCALA BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
        AND TFJ.TFJ_CONTRT BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10%
		AND ABB.ABB_ATIVO = '1'
	ORDER BY TFJ_CODIGO,TFL_CODIGO,TFF_COD,AA1_CODTEC
EndSql

END REPORT QUERY oSection1

(cAlias1)->(DbGoTop())

oSection2:SetParentQuery()
oSection2:SetParentFilter({|cParam| (cAlias1)->TFJ_CODIGO == cParam},{|| (cAlias1)->TFJ_CODIGO })

oSection3:SetParentQuery()
oSection3:SetParentFilter({|cParam| (cAlias1)->TFL_CODIGO == cParam},{|| (cAlias1)->TFL_CODIGO })

oSection4:SetParentQuery()
oSection4:SetParentFilter({|cParam| (cAlias1)->TFF_COD == cParam},{|| (cAlias1)->TFF_COD })

oSection1:Print()

(cAlias1)->(DbCloseArea())
          
Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At961QtdAg()
Quantidade de dias trabalhados

@sample 	At961QtdAg(cCodTFF,cCodAtend)
@param		cCodTFF, 	String,	Codigo de posto
			cCodAtend, 	String,	Codigo do atendente
			
@return 	nQtdAgd, Numeric, Quantidade de dias trabalhados
@author 	Kaique Schiller
@since		27/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At961QtdAg(cCodTFF,cCodAtend)
Local cAliasQry	:= GetNextAlias()
Local nQtdAgd	:= 0

BeginSQL Alias cAliasQry
	SELECT COUNT(TDV.TDV_DTREF)
	FROM %table:ABQ% ABQ
		INNER JOIN %table:ABB% ABB ON (ABB.ABB_FILIAL=%xFilial:ABB% AND ABB.ABB_IDCFAL=ABQ.ABQ_CONTRT+ABQ.ABQ_ITEM+'CN9' AND ABB.%NotDel%)
		INNER JOIN %table:TDV% TDV ON (TDV.TDV_FILIAL=%xFilial:TDV% AND TDV.TDV_CODABB = ABB.ABB_CODIGO AND TDV.%NotDel%)
	WHERE ABQ.ABQ_FILIAL=%xFilial:ABQ% AND ABQ.ABQ_CODTFF=%Exp:cCodTFF% AND ABQ.%NotDel%
	AND TDV.TDV_DTREF BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
	AND ABB.ABB_CODTEC = %Exp:cCodAtend%
	AND ABB.ABB_ATIVO = '1'
	GROUP BY TDV.TDV_DTREF
EndSql

(cAliasQry)->(DbGoTop())

While !(cAliasQry)->(EOF())
	nQtdAgd++
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

Return nQtdAgd
