#include "protheus.ch"

function OFAGVmiInventario()
return .t.

/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  23/03/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*/{Protheus.doc} OFAGVmiInventario
	Interface DMS - 1 da definição do VMI

	{
		"data": {
			"dealerLegalNumber": "99.999.999/0001-99",
			"extractionDateTime": "2016-11-23T10:45:00+03:00",
			"part": {
				"partNumber": "1444437P",
				"availableQuantity": 20,
				"onOrderQuantity": 1.5,
				"reservedQuantityWorkOrders": 1.5,
				"reservedQuantityPartTickets": 1.5,
				"openCustomerOrders": 1.5,
				"quantityReturnedByDealer": 10,
				"quantityReturnedByCustomerCounter": 1.5,
				"quantityReturnedByCustomerShop": 1.5,
				"quantityReturnedTotal": 1.5
			}
		}
	}

	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiInventario from OFAGVmiBase
	Data oVmiJson
	Data oSqlHlp
	Data oDPM
	Data cIntName

	Method New() CONSTRUCTOR
	Method GetDadosPeca()
	Method Trigger()
EndClass

Method New() Class OFAGVmiInventario
	_Super:New()
	AADD(::aMapValid, {"data:dealerLegalNumber"                     , "Obri"})
	AADD(::aMapValid, {"data:part"                                  , "Obri"})
	AADD(::aMapValid, {"data:part:partNumber"                       , "Obri"})
	AADD(::aMapValid, {"data:part:availableQuantity"                , "Obri"})
	AADD(::aMapValid, {"data:part:onOrderQuantity"                  , "Obri"})
	AADD(::aMapValid, {"data:part:reservedQuantityWorkOrders"       , "Obri"})
	AADD(::aMapValid, {"data:part:reservedQuantityPartTickets"      , "Obri"})
	AADD(::aMapValid, {"data:part:quantityReturnedByDealer"         , "Obri"})
	AADD(::aMapValid, {"data:part:quantityReturnedByCustomerCounter", "Obri"})
	AADD(::aMapValid, {"data:part:quantityReturnedByCustomerShop"   , "Obri"})
	AADD(::aMapValid, {"data:part:quantityReturnedTotal"            , "Obri"})
	::cIntName := "DMS-1"
	::oSqlHlp  := DMS_SqlHelper():New()
	::oDPM     := DMS_DPM():New()
return self

/*/{Protheus.doc} Trigger
	Gera cabecalho do json, manda buscar os dados das peças grava json e retorna numero de controle, todas as classes vmi de interface terão esse método

	@author Vinicius Gati
	@since 16/06/2017
	@param oParams, DMS_DataContainer , Traz os dados basicos para criar uma requisição de interface, neste caso peças
/*/
Method Trigger(oParams) class OFAGVmiInventario
	Local cControle := ""
	Local cSQL      := ""
	Local nCntFor   := 0
	local oArHlp    := DMS_ArrayHelper():New()
	Local oJson     := DMS_DataContainer():New()
	Local aPecas    := oParams:GetValue("PECAS")
	Local aPecasOk  := {}
	Local cGrupos   := "'" + oArHlp:Join(self:oVmiParametros:grupos(), "','") + oArHlp:Join(self:oVmiParametros:gruposparalelos(), "','") + "'"
	For nCntFor := 1 to len(aPecas)
		cSQL := " SELECT COUNT(*) "
		cSQL += "   FROM "+self:oSqlHlp:NoLock('SB1')
		cSQL += "  WHERE B1_FILIAL = '"+xFilial('SB1')+"' "
		cSQL += "    AND B1_COD    = '"+aPecas[nCntFor]+"' "
		cSQL += "    AND B1_GRUPO IN ("+cGrupos+")"
		cSQL += "    AND D_E_L_E_T_ = ' ' "
		If FM_SQL(cSQL) > 0
			aAdd(aPecasOk,aPecas[nCntFor])
		EndIf
	Next

	If len(aPecasOk) > 0

		SA1->(dbGoTo(self:oFilHlp:GetCliente(cFilAnt)))
		oJson:SetValue("dealerLegalNumber", self:fmtDoc(self:oVmiParametros:DocMatriz()))
		oJson:SetValue("extractionDateTime", FWTIMESTAMP(5))
		oJson:SetValue("part", self:GetDadosPeca(aPecasOk))

		cControle := self:oVmiJson:Persist(self:cIntName, oParams, {oJson}, oParams:GetValue('NUMCONTROLE'))
	
	EndIf

Return cControle

/*/{Protheus.doc} GetDadosPeca
	Metodo que vai gerar os nós de pecas com dados necessários para atender <br>
	a interface inventario passadas por parametro

	@author Vinicius Gati
	@since 16/06/2017
	@param aPec, Array , Array Com b1_cods
/*/
Method GetDadosPeca(aPec) class OFAGVmiInventario
	local nIdx := 1
	local cSQL := ""


	cInPec     := "'" + self:oArHlp:Join(aPec, "','") + "'"
//	cInOriGrps := "'" + self:oArHlp:Join(self:oVmiParametros:grupos(), "','") + "'"
//	cInParGrps := "'" + self:oArHlp:Join(self:oVmiParametros:gruposParalelos(), "','") + "'"
//	cInForAGCO := self:oArHlp:Join(self:oVmiParametros:aFornAGCO, ",")

// todos os status menos em branco e C para filtrar
	cVldsts := JD06ResFases("' ', 'C'") // not in parametro
// todos os status menos X para o filtro do loja
	cVldLj  := JD06ResFases("'X'") // not in parametro

	cSQL += "SELECT B1_COD partNumber,"

// availableQuantity // SB2

	cSQL += "(     SELECT "
	cSQL += "             CASE "
	cSQL += "               WHEN SB1.B1_CONV <> 0 AND SB1.B1_TIPCONV = 'M' THEN COALESCE(SUM(B2_QTSEGUM),0) "
	cSQL += "               ELSE COALESCE(SUM(B2_QATU),0) "
	cSQL += "             END "
	
	if  NNR->(FieldPos("NNR_VDADMS")) > 0
		cSQL += "        FROM "+self:oSqlHlp:NoLock('SB2')
		cSQL += "        JOIN "+self:oSqlHlp:NoLock('NNR')+" ON NNR_FILIAL = '"+xFilial('NNR')+"' AND NNR_CODIGO = B2_LOCAL AND NNR_VDADMS = '1' AND NNR.D_E_L_E_T_ = ' ' "
		cSQL += "       WHERE B2_FILIAL = '"+xFilial('SB2')+"' AND B2_COD = SB1.B1_COD "
		cSQL += "         AND SB2.D_E_L_E_T_ = ' ' "
	else
		cSQL += "   FROM " + RetSqlName('SB2') + " SB2 "
		cSQL += "  WHERE SB2.B2_FILIAL = '" + xFilial('SB2') + "' AND SB2.B2_COD = SB1.B1_COD"
		cSQL += "    AND SB2.B2_LOCAL = SB1.B1_LOCPAD "
		cSQL += "    AND SB2.D_E_L_E_T_ = ' ' "
	end
	cSQL += ") availableQuantity,"

// onOrderQuantity // Nao tem mais Pendencia de Pedido
	cSQL += "( 0 ) onOrderQuantity,"

// openCustomerOrders // VS3
	cSQL += "(     SELECT COUNT(VS3_QTDINI) "
	cSQL += "        FROM "+self:oSqlHlp:NoLock('VS3')
	cSQL += "        JOIN "+self:oSqlHlp:NoLock('VS1')+" ON VS1_FILIAL = VS3_FILIAL AND VS1_NUMORC = VS3_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
	cSQL += "       WHERE VS3_FILIAL = '"+ xFilial("VS3") +"' "
	cSQL += "         AND VS3_CODITE = SB1.B1_CODITE AND VS3_GRUITE = SB1.B1_GRUPO "
	cSQL += "         AND VS3_MOTPED = ' ' AND VS3.D_E_L_E_T_ = ' ' "
	cSQL += "         AND VS1_STATUS IN (" + JD06ResFases(" 'X', 'C', 'I' ") + ") "
	cSQL += ") openCustomerOrders,"

// Reservados balcão
	cSQL += "(     SELECT SUM(VE6_QTDITE) "
	cSQL += "        FROM "+self:oSqlHlp:NoLock('VE6')
	cSQL += "        JOIN "+self:oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_GRUPO = VE6_GRUITE AND B1_CODITE = VE6_CODITE  AND SB1.D_E_L_E_T_ = ' ' "
	cSQL += "   LEFT JOIN "+self:oSqlHlp:NoLock('VS1')+" ON VS1.VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMORC = VE6_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
	cSQL += "       WHERE VE6.VE6_FILIAL='"+xFilial('VE6')+"' AND  VE6.VE6_INDREG = '3' AND VE6.D_E_L_E_T_ = ' ' "
	cSQL += "         AND VS1_TIPORC = '1' AND (CASE WHEN VS1_NUMNFI = ' ' THEN '0' ELSE VS1_STATUS END ) IN (" + cVldLj + ") "  // só X não entra // tratamento do loja
	cSQL += "         AND VS1_STATUS IN (" + cVldsts + ") "
	cSQL += ") reservedQuantityPartTickets,"

// Reservados oficina
	cSQL += "(     SELECT  COALESCE( SUM(VE6_QTDITE - VE6_QTDATE - VE6_QTDEST) , 0 ) "
	cSQL += "        FROM "+self:oSqlHlp:NoLock('VE6')
	cSQL += "        JOIN "+self:oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND B1_GRUPO = VE6_GRUITE AND B1_CODITE = VE6_CODITE  AND SB1.D_E_L_E_T_ = ' ' "
	cSQL += "   LEFT JOIN "+self:oSqlHlp:NoLock('VS1')+" ON VS1.VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMORC = VE6_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
	cSQL += "       WHERE VE6.VE6_FILIAL='"+xFilial('VE6')+"' AND  VE6.VE6_INDREG = '3' AND VE6.D_E_L_E_T_ = ' ' "
	cSQL += "         AND VS1_TIPORC = '2' AND VE6_NUMOSV = ' ' "
	cSQL += "         AND VS1_STATUS IN (" + cVldsts + ") "
	cSQL += "         AND (CASE WHEN VS1_NUMNFI = ' ' THEN '0' ELSE VS1_STATUS END ) IN (" + cVldLj + ") "
	cSQL += ") reservedQuantityWorkOrders "

	cSQL += "  FROM "+self:oSqlHlp:NoLock('SB1')
	cSQL += " WHERE B1_FILIAL = '"+xFilial('SB1')+"' "
	cSQL += "   AND B1_COD IN ("+cInPec+") "
	cSQL += "   AND SB1.D_E_L_E_T_ = ' ' "

	aDados := self:oSqlHlp:GetSelect({;
		{'campos', {'partNumber','availableQuantity','onOrderQuantity','openCustomerOrders',;
								'reservedQuantityWorkOrders','reservedQuantityPartTickets'}},;
		{'query', cSQL} ;
	})

	for nIdx := 1 to Len(aDados)
		aDevsBal := self:oDPM:GetDevData(cFilAnt, Date(), aDados[nIdx]:GetValue("partNumber"), 1, "'"+GetNewPar("MV_PREFBAL","BAL")+"'", "")
		nQtdDevB := self:oArHlp:SumBlk(aDevsBal, { |dev| dev:GetValue("QTD_ITENS") })

		aDevsOfi := self:oDPM:GetDevData(cFilAnt, Date(), aDados[nIdx]:GetValue("partNumber"), 1, "'"+GetNewPar("MV_PREFOFI","OFI")+"'", "")
		nQtdDevO := self:oArHlp:SumBlk(aDevsOfi, { |dev| dev:GetValue("QTD_ITENS") })

		aDados[nIdx]:SetValue('quantityReturnedByCustomerCounter', nQtdDevB)
		aDados[nIdx]:SetValue('quantityReturnedByCustomerShop', nQtdDevO)
		aDados[nIdx]:SetValue('quantityReturnedByDealer', 0)
		aDados[nIdx]:SetValue('quantityReturnedTotal', nQtdDevB+nQtdDevO)

		If aDados[nIdx]:GetValue('availableQuantity',-1) < 0
			aDados[nIdx]:SetValue('availableQuantity', 0)
		EndIf

	Next

Return aDados[1] // Não tem envio de vários para inventario ainda
