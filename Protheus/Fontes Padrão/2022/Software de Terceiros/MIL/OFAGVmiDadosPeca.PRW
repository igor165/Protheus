#include "protheus.ch"

function OFAGVmiDadosPeca()
return .t.


/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  13/06/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*/{Protheus.doc} OFAGVmiDadosPeca
	Interface DMS - 2 da definição do VMI<br>
	Exemplo:<br>
	{<br>
		"data": {<br>
			"dealerLegalNumber": "99.999.999/0001-99",<br>
			"extractionDateTime": "2016-11-23T10:45:00+03:00",<br>
			"order": {<br>
				"orderId": "34562",<br>
				"orderAgco": "AOL-123456",<br>
				"orderIdOriginal": "4567",<br>
				"deliveredDealerLegalNumber": "11.000.000/0001-00",<br>
				"orderDate": "2016-11-23",<br>
				"orderType": "STOCK_ORDER",<br>
				"supplierLegalNumber": "00.000.000/0001-00",<br>
				"supplierName": "NOME FANTASIA DO FORNECEDOR",<br>
				"filter1": "",<br>
				"filter2": "",<br>
				"filter3": "",<br>
				"items": [<br>
					{<br>
						"sourceLocation": "REPVT03",<br>
						"orderLineNumber": "1",<br>
						"partNumber": "1444437P",<br>
						"receivedDate": "2016-11-23",<br>
						"requestedQuantity": 1.5,<br>
						"receivedQuantity": 1.5,<br>
						"openQuantity": 1.5,<br>
						"canceledQuantity": 1.5,<br>
						"lineStatus": "OPEN"<br>
					}<br>
				]<br>
			}<br>
		}<br>
	}
	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiDadosPeca from OFAGVmiBase
	Data oVmiJson
	Data oSqlHlp
	Data oDPM
	Data cIntName
	Method New() CONSTRUCTOR
	Method GetDadosPeca()
	Method Trigger()
	Method TriggerDer()
	Method LastSaleDate()
	Method FornecedorPreferencial()
EndClass

/*/{Protheus.doc} New
	Construtor simples

	@author Vinicius Gati
	@since 13/06/2017
/*/
Method New() Class OFAGVmiDadosPeca
	_Super:New()
	::cIntName := "DMS-2"
	::oSqlHlp  := DMS_SqlHelper():New()
	::oDPM     := DMS_DPM():New()
return self

/*/{Protheus.doc} Trigger
	Gera cabecalho do json, manda buscar os dados das peças grava json e retorna numero de controle, todas as classes vmi de interface terão esse método

	@param oParams, DMS_DataContainer , Traz os dados basicos para criar uma requisição de interface, neste caso peças
	@author Vinicius Gati
	@since 19/06/2017
/*/
Method Trigger(oParams) class OFAGVmiDadosPeca
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
		oJson:SetValue("part", self:GetDadosPeca(aPecasOk)[1])

		cControle := self:oVmiJson:Persist(self:cIntName, oParams, {oJson}, oParams:GetValue('NUMCONTROLE'))

		if oParams:GetBool('INICIALIZACAO', .F.) == .F.
			self:TriggerDer(oJson:GetValue("part"), cControle)
		end

	EndIf
Return cControle

/*/{Protheus.doc} TriggerDer
	Engatilha os eventos derivados para atualizar AGCO

	@author Andre Luis Almeida
	@since 10/12/2019
/*/
Method TriggerDer(oItem, cControle) Class OFAGVmiDadosPeca
		Local oVmi := OFAGVmi():New()
		oVMi:Trigger({;
				{'EVENTO', oVmi:oVmiMovimentos:Inventario },;
				{'NUMCONTROLE' , cControle                },;
				{'ORIGEM', "DMS2_DMS1"                    },;
				{'PECAS' , {oItem:GetValue('partNumber') }} ;
		})
Return .T.

/*/{Protheus.doc} GetDadosPeca
	Metodo que vai gerar os nós de pecas com dados necessários para atender <br>
	a interface inventario passadas por parametro

	@author Vinicius Gati
	@since 19/06/2017
	@param aPec, Array , Array Com b1_cods
/*/
Method GetDadosPeca(aPec) class OFAGVmiDadosPeca
	local nIdx := 1
	local cSQL := ""
	local oArHlp := DMS_ArrayHelper():New()
	local aCampos := {;
		'partNumber','agcoPartNumber','originalPart','description','firstPurchase',; // primeira compra... e não primeira vez que foi vendido
		'stockable','lastSaleDate','mainBinLocation',;
		'minimumThreshold','maximumThreshold','preferredSupplierLegalNumber',;
		'netPrice','averageCost','unitOfMeasure',;
		'currencyCode','lastPurchasePrice','openPurchaseOrders',;
		'firstAvailableDate';
	}
	Local cInPec     := "'" + oArHlp:Join(aPec, "','") + "'"
	Local lCtrlLote  := GetNewPar("MV_RASTRO","N") == "S"
	Local lSBZ       := ( SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ" )
	Local lLocaliz   := ( GetMv("MV_LOCALIZ") == "S" ) // Trabalha com estoque Enderecado ?

	cInOriGrps := "'" + oArHlp:Join(self:oVmiParametros:grupos(), "','") + "'"

	cSQL += "SELECT "
	cSQL += " B1_COD partNumber,
	If SB1->(FieldPos("B1_XPNAGC")) > 0 // PartNumber AGCO
		cSQL += " CASE WHEN B1_XPNAGC = ' ' THEN B1_CODITE ELSE B1_XPNAGC END agcoPartNumber, "
	Else
		cSQL += " B1_CODITE agcoPartNumber, "
	EndIf
	cSQL += " B1_DESC description, "
	cSQL += " B1_EMIN minimumThreshold,"
	cSQL += " B1_EMAX maximumThreshold,"
	cSQL += " B1_UM unitOfMeasure,"
	cSQL += " 'BRL' currencyCode,"
	cSQL += " CASE WHEN B1_LOCALIZ = 'N' THEN 0 ELSE 1 END stockable,"

	cSQL += "("
	cSQL += " SELECT CASE WHEN COALESCE(COUNT(*),0) > 0 THEN 1 ELSE 0 END "
	cSQL += "   FROM "+self:oSqlHlp:NoLock('SBM')
	cSQL += "  WHERE BM_FILIAL = '"+xFilial('SBM')+"' "
	cSQL += "    AND BM_GRUPO = SB1.B1_GRUPO "
	cSQL += "    AND BM_GRUPO IN ("+cInOriGrps+") "
	cSQL += ") originalPart,"

	if lCtrlLote .AND. lLocaliz
		cSQL += "( SELECT TOP 1 CASE WHEN BZ_LOCALI2 = ' ' THEN B5_LOCALI2 ELSE BZ_LOCALI2 END "
		cSQL += "    FROM ("
		cSQL += "        SELECT BZ_LOCALI2, B5_LOCALI2 "
		cSQL += "          FROM "+self:oSqlHlp:NoLock('SB1', 'SB12')
		cSQL += "     LEFT JOIN "+self:oSqlHlp:NoLock('SBZ')+" ON BZ_COD = SB12.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
		cSQL += "     LEFT JOIN "+self:oSqlHlp:NoLock('SB5')+" ON B5_COD = SB12.B1_COD AND SB5.D_E_L_E_T_ = ' ' "
		cSQL += "         WHERE SB12.B1_COD = B1_COD "
		cSQL += "           AND SB12.D_E_L_E_T_ = ' ' "
		cSQL += "    ) T "
		cSQL += ") as mainBinLocation,"
	else
		cSQL += " B1_LOCPAD as mainBinLocation," // sem locação vai o codigo mesmo
	end

	cSQL += " B1_PRV1 as netPrice,"
	cSQL += " B2_CM1 as averageCost,"
	cSQL += " ULT_PED.C7_PRECO as lastPurchasePrice,"

	cSQL += "( 0 ) as openPurchaseOrders,"

	cSQL += "("
	cSQL += " SELECT MIN(D1_DTDIGIT) "
	cSQL += "   FROM "+self:oSqlHlp:NoLock('SD1')
	cSQL += "  WHERE D1_FILIAL = '"+xFilial('SD1')+"' "
	cSQL += "    AND D1_COD    = SB1.B1_COD "
	cSQL += "    AND SD1.D_E_L_E_T_ = ' ' "
	cSQL += ") as firstAvailableDate,"

	cSQL += " '' as preferredSupplierLegalNumber,"

	cSQL += "("
	cSQL += " SELECT MAX(D2_EMISSAO) "
	cSQL += "   FROM "+self:oSqlHlp:NoLock('SD2')
	cSQL += "  WHERE D2_FILIAL = '"+xFilial('SD2')+"' "
	cSQL += "    AND D2_COD    = SB1.B1_COD "
	cSQL += "    AND SD2.D_E_L_E_T_ = ' ' "
	cSQL += ") as lastSaleDate,"

// Para saber se item está tendo a primeira compra sendo contemplada no dia da geração
// vemos se a data da venda é a mesma do dia, pois no parts data
// não é enviado dados de pedidos nesse caso, então a única forma de saber isso é se a venda foi no dia
// e se a quantidade de vendas total for = 1
	cSQL += "("
	cSQL += " SELECT CASE WHEN MAX(D2_EMISSAO) = '"+DTOS(date())+"' AND ( SELECT COUNT(*) FROM "+self:oSqlHlp:NoLock('SD2', 'D2_CNT')+" WHERE D2_CNT.D2_FILIAL = '"+xFilial('SD2')+"' AND D2_CNT.D2_COD = B1_COD AND D2_CNT.D_E_L_E_T_ = ' ') = 1 "
	cSQL += "             THEN 1 ELSE 0 END "
	cSQL += "   FROM "+self:oSqlHlp:NoLock('SD2')
	cSQL += "  WHERE D2_FILIAL = '"+xFilial('SD2')+"' "
	cSQL += "    AND D2_COD    = SB1.B1_COD "
	cSQL += "    AND SD2.D_E_L_E_T_ = ' ' "
	cSQL += ") as firstPurchase " // primeira compra... e não primeira vez que foi vendido

	cSQL += "  FROM "+self:oSqlHlp:NoLock('SB1')
	cSQL += "  LEFT JOIN "+self:oSqlHlp:NoLock('SB2')+" ON B2_FILIAL = '"+xFilial('SB2')+"' AND B2_COD  = B1_COD  AND B2_LOCAL = B1_LOCPAD AND SB2.D_E_L_E_T_ = ' ' "
	cSQL += "  LEFT JOIN "+self:oSqlHlp:NoLock('SB5')+" ON B5_FILIAL = '"+xFilial('SB5')+"' AND B5_COD  = B1_COD  AND SB5.D_E_L_E_T_ = ' ' "
	if lSBZ
		cSQL += "  LEFT JOIN "+self:oSqlHlp:NoLock('SBZ')+" ON BZ_FILIAL = '"+xFilial('SBZ')+"' AND BZ_COD   = B1_COD    AND SB5.D_E_L_E_T_ = ' ' "
	end
	cSQL += " LEFT JOIN ( "
	cSQL += "   SELECT TOP 1 C7_PRODUTO, C7_PRECO FROM "+self:oSqlHlp:NoLock('SC7')+" WHERE C7_FILIAL = '"+xFilial('SC7')+"' AND SC7.D_E_L_E_T_ = ' ' ORDER BY C7_EMISSAO DESC "
	cSQL += " ) as ULT_PED "
	cSQL += " ON ULT_PED.C7_PRODUTO = B1_COD "
	cSQL += " WHERE B1_FILIAL = '"+xFilial('SB1')+"' "
	cSQL += "   AND B1_COD in ("+cInPec+") AND B1_COD <> ' ' "

	aDados := self:oSqlHlp:GetSelect({;
		{'campos', aCampos},;
		{'query' , cSQL   } ;
	})

	for nIdx := 1 to Len(aDados)
		oObj := aDados[nIdx]
		// transformando dados de 0/1 para booleano
		oObj:SetValue("stockable",     IIF(oObj:GetValue('stockable'    , 0) == 1, .T., .F.) )
		oObj:SetValue("originalPart",  IIF(oObj:GetValue('originalPart' , 0) == 1, .T., .F.) )
		oObj:SetValue("firstPurchase", IIF(oObj:GetValue('firstPurchase', 0) == 1, .T., .F.) ) // primeira compra... e não primeira vez que foi vendido
		// formatando cpnj no formato pedido pelo vmi
		if Empty( oObj:GetValue("preferredSupplierLegalNumber", "") )
			if oObj:GetValue('firstPurchase') == .T.
				oObj:RemAttr("preferredSupplierLegalNumber")
			else
				oObj:SetValue("preferredSupplierLegalNumber", self:FornecedorPreferencial(oObj:GetValue('partNumber')))
			end
		else
			oObj:SetValue("preferredSupplierLegalNumber", cSupName )
		end

		oObj:SetValue("dealerPartsPerPackage", 1)
		
		if oObj:GetValue("averageCost", 0) < 0
			oObj:SetValue("averageCost", 0 )
		endif
		
		oObj:SetValue("description", LEFT(STRTRAN(oObj:GetValue('description'),'"',"''"), 60)) // limite não documentado
		oObj:SetValue("preferredSupplierLegalNumber", self:fmtDoc(oObj:getValue("preferredSupplierLegalNumber")))
		oObj:SetValue("firstAvailableDate", STOD(oObj:getValue("firstAvailableDate")))
		oObj:SetValue("lastSaleDate", STOD(oObj:getValue("lastSaleDate")))
	Next

Return aDados

/*/{Protheus.doc} Join
	Pega data de última venda para VMI (não deve ser usado em geral pois poderá conter regras diferenciadas)
	@author Vinicius Gati
	@since 20/06/2017
	@param cCod, String, Código da peça
/*/
Method LastSaleDate(cCod) Class OFAGVmiDadosPeca
	cSQL := ""
	cSQL += " SELECT MAX(D2_EMISSAO) "
	cSQL += "   FROM "+self:oSqlHlp:NoLock('SD2')
	cSQL += "  WHERE D2_FILIAL = '"+xFilial('SD2')+"' "
	cSQL += "    AND D2_COD    = '"+cCod+"' "
	cSQL += "    AND SD2.D_E_L_E_T_ = ' ' "
Return FM_SQL(cSQL)

/*/{Protheus.doc} FornecedorPreferencial
	Retorna um fornecedor preferencial da peça
	
	@type function
	@author Vinicius Gati
	@since 21/07/2017
/*/
Method FornecedorPreferencial(cB1_COD) Class OFAGVmiDadosPeca
	local aAreaB1 := getArea('SB1')
	local aAreaA2 := getArea('SA2')
	local aArea   := getArea()
	local cDocForn := "99.999.999/0001-99"

	dbSelectArea('SB1')
	dbSetOrder(1)
	dbSeek(xFilial('SB1') + cB1_COD)
	if Empty(SB1->B1_PROC)
		cDocForn := self:oVmiParametros:DocFornPadrao()
	else
		dbSelectArea('SA2')
		dbSelectArea(1)
		dbSeek(xFilial('SA2') + SB1->B1_PROC)
		cDocForn := SA2->A2_CGC
		if Empty(cDocForn)
			cDocForn := self:oVmiParametros:DocFornPadrao()
		endif
	endif

	restArea(aAreaB1)
	restArea(aAreaA2)
	restArea(aArea)
Return cDocForn
