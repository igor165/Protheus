#include "protheus.ch"

function OFAGVmiOrdemServico()
return .t.

/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  12/06/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*/{Protheus.doc} OFAGVmiOrdemServico
	Interface DMS - 4 da definição do VMI
	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiOrdemServico from OFAGVmiBase
	Data cIntName
	Data oSqlHlp
	Data oVmi

	Method New() CONSTRUCTOR
	Method Trigger()
	Method TriggerDer()
	Method GetOS()
	Method GetItems()
	Method UnusualSale()
	// Method HaveInvoice()
EndClass

Method New() Class OFAGVmiOrdemServico
	_Super:New()
	::cIntName := "DMS-4"
	::oSqlHlp := DMS_SqlHelper():New()
	AADD(::aMapValid, {"data:order:items:sourceLocation"      , "V005"})
	AADD(::aMapValid, {"data:order:orderType"                 , "V007"})
	AADD(::aMapValid, {"data:order:orderType"                 , "Obri"})
	AADD(::aMapValid, {"data:order:items:unusualSale"         , "V011"})
	AADD(::aMapValid, {"data:order:items:lineStatus"          , "V009"})
	AADD(::aMapValid, {"data:order:items:lineStatus"          , "Obri"})
	AADD(::aMapValid, {"data:order:orderId"                   , "Obri"})
	AADD(::aMapValid, {"data:order:deliveredDealerLegalNumber", "Obri"})
	AADD(::aMapValid, {"data:order:orderDate"                 , "Obri"})
	AADD(::aMapValid, {"data:order:items:sourceLocation"      , "Obri"})
	AADD(::aMapValid, {"data:order:items:orderLineNumber"     , "Obri"})
	AADD(::aMapValid, {"data:order:items:partNumber"          , "Obri"})
	AADD(::aMapValid, {"data:order:items:receivedDate"        , "Obri"})
	AADD(::aMapValid, {"data:order:items:requestedQuantity"   , "Obri"})
	AADD(::aMapValid, {"data:order:items:receivedQuantity"    , "Obri"})
	AADD(::aMapValid, {"data:order:items:openQuantity"        , "Obri"})
return self

/*/{Protheus.doc} Trigger
	Dispara evento para envio de dados ao VMI, interface DMS-4

	@author Vinicius Gati
	@since 22/06/2017
	@param oParams, DMS_DataContainer, com os dados: NUMERO_OS
/*/
Method Trigger(oParams) Class OFAGVmiOrdemServico
	Local oJson := DMS_DataContainer():New()
	Local cCoord := ""
	Local cVO1_NUMOSV := oParams:GetValue("NUMERO_OS")

	if self:oVmiJson:Exist(oParams)
		return 'ja_gerado'
	endif

	self:oVmi := OFAGVmi():New()

	dbSelectArea("VO1")
	dbSetOrder(1)
	if dbSeek(xFilial('VO1') + cVO1_NUMOSV)
		if VO1->VO1_TEMFEC == "S"
			SA1->(dbGoTo(self:oFilHlp:GetCliente(cFilAnt)))
			oJson:SetValue("dealerLegalNumber", self:fmtDoc(self:oVmiParametros:DocMatriz()))
			oJson:SetValue("extractionDateTime", FWTIMESTAMP(5))
			oJson:SetValue("order", self:GetOS(cVO1_NUMOSV))
			if ValType( oJson:GetValue("order", Nil) ) == "U" // não envia se não gerou dados
				return "0"
			end
			if LEN( oJson:GetValue("order"):GetValue("items") ) == 0
				return .F. // nenhum item elegível.
			end
			cCoord := self:oVmiJson:Persist(self:cIntName, oParams, {oJson})
			if oParams:GetBool('INICIALIZACAO', .F.) == .F.
				self:TriggerDer(oJson:GetValue('order'):GetValue('items'), cCoord)
			end
		endif
	end
Return cCoord

/*/{Protheus.doc} TriggerDer
	Engatilha os eventos derivados para atualizar AGCO
	é feito de 7 em 7 peças para melhorar performance de geração e envio de jsons

	@author Vinicius Gati
	@since 21/06/2017
/*/
Method TriggerDer(aItems, cCoord) Class OFAGVmiOrdemServico
	Local nX     := 1
	Local aPecas := self:oArHlp:Map(aItems, {|oItem| oItem:GetValue('partNumber') })
	aPecas := self:oArHlp:Uniq(aPecas)
	For nX:= 1 to Len(aPecas)
		self:oVmi:Trigger({;
			{'EVENTO', self:oVmi:oVmiMovimentos:Inventario},;
			{'NUMCONTROLE' , cCoord                       },;
			{'ORIGEM', "DMS4_DMS1"                        },;
			{'PECAS' , {aPecas[nX]} } ;
		})
	Next
Return .T.

/*/{Protheus.doc} GetOS
	Retorna objeto data container no formato de order para VMI que sera convertido em json

	@author Vinicius Gati
	@since 03/06/2017
	@param cVO1_NUMORC, String , código da os
/*/
Method GetOS(cVO1_NUMOSV) Class OFAGVmiOrdemServico
	Local aArea    := getArea()
	Local aAreaA1  := getArea('SA1')
	Local aAreaVO1 := getArea('VO1')
	Local oOrder   := Nil

	dbSelectArea("VO1")
	dbSetOrder(1)
	msSeek(xFilial('VO1') + cVO1_NUMOSV)

	dbSelectArea("SA1")
	dbSetOrder(1)
	if Empty(VO1->VO1_FATPAR)
		dbSeek(xFilial('SA1')+VO1->VO1_PROVEI+VO1->VO1_LOJPRO)
	else
		dbSeek(xFilial('SA1')+VO1->VO1_FATPAR+VO1->VO1_LOJA)
	end

	// se for cliente parceiro não envia dados
	if ! self:oVmi:oVmiParametros:ClienteValido(SA1->(RECNO()))
		return Nil
	end

	oOrder := DMS_DataContainer():New({;
		{"orderId"            , xFilial('VS1') + cVO1_NUMOSV + "_OS"  },;
		{"orderDate"          , VO1->VO1_DATABE               },;
		{"orderType"          , "W"                           },; //oficina somente
		{"customerLegalNumber", self:fmtDoc(SA1->A1_CGC)      },;
		{"items"              , self:GetItems(VO1->VO1_NUMOSV)} ;
	})

	RestArea(aAreaVO1)
	RestArea(aAreaA1)
	RestArea(aArea)
Return oOrder

/*/{Protheus.doc} GetItems
	Retorna objeto data container no formato de order para VMI que serã cnvertido em json

	@author Vinicius Gati
	@since 23/06/2017
	@param cVO1_NUMOSV, String , código da Ordem de Servico
/*/
Method GetItems(cVO1_NUMOSV) Class OFAGVmiOrdemServico
	local aItems  := {}
	local aDevols := {}
	local cAl     := GetNextAlias()
	local cQuery  := ""
	local nIdx    := 1
	local nIdx2   := 1
	Private oVmiPars  := OFAGVmiParametros():New()
	Private oVmi      := OFAGVmi():New()
	Private cGrupos   := "'" + self:oArHlp:Join(oVmiPars:grupos(), "','") + self:oArHlp:Join(oVmiPars:gruposParalelos(), "','") + "'"
	
	cQuery += "    SELECT VO2_DEVOLU, VO1_DATABE, B1_COD, VO3_QTDREQ, VO3_NUMNFI, VO3_SERNFI, VO3_DATFEC, VO1_STATUS, VO3.R_E_C_N_O_ recno "
	cQuery += "      FROM " + self:oSqlHlp:NoLock('VO1')
	cQuery += "      JOIN " + self:oSqlHlp:NoLock('VO2') + " ON VO2_FILIAL = '"+xFilial('VO2')+"' AND VO2_NUMOSV = VO1_NUMOSV AND VO2.D_E_L_E_T_ = ' ' "
	cQuery += "      JOIN " + self:oSqlHlp:NoLock('VO3') + " ON VO3_FILIAL = '"+xFilial('VO3')+"' AND VO3_NUMOSV = VO2_NUMOSV AND VO3_NOSNUM = VO2_NOSNUM AND VO3.D_E_L_E_T_ = ' ' "
	cQuery += "      JOIN " + self:oSqlHlp:NoLock('SB1') + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_GRUPO   = VO3_GRUITE AND B1_CODITE  = VO3_CODITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "     WHERE VO1_FILIAL = '"+xFilial('VO1')+"' "
	cQuery += "       AND VO1_NUMOSV = '"+cVO1_NUMOSV+"' "
	cQuery += "       AND VO1.D_E_L_E_T_ = ' ' "
	cQuery += "       AND VO3.VO3_DATFEC != ' ' "
	cQuery += "       AND SB1.B1_GRUPO IN ("+cGrupos+") "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )
	while !( (cAl)->(eof()) )
		// se for devolucao vou adicionar em um vetor pra depois abater como qtd retornada... pra ficar legal e condizente os dados
		if (cAl)->VO2_DEVOLU == '0'
			AADD(aDevols, { (cAl)->B1_COD, VO3->VO3_QTDREQ })
		else
			if !Empty((cAl)->B1_COD)
				nQtdEst := self:EmEstoque((cAl)->B1_COD)
				cStatus := "CLOSED" // IIF((cAl)->VO1_STATUS == "F", "CLOSED", "OPEN") // faturado ou não
				oItem := DMS_DataContainer():New({;
					{"orderLineNumber"  , STR((cAl)->recno) },; // usarei recno aqui, pois nao existe sequencia nas requisicoes oficina
					{"partNumber"       , (cAl)->B1_COD     },;
					{"shippedDate"      , STOD( (cAl)->VO3_DATFEC )},;
					{"shippedQuantity"  , (cAl)->VO3_QTDREQ },;
					{"requestedQuantity", (cAl)->VO3_QTDREQ },;
					{"reservedQuantity" , (cAl)->VO3_QTDREQ },;
					{"requestedDate"    , STOD( (cAl)->VO1_DATABE )},;
					{"returnedQuantity" , 0                 },;
					{"canceledQuantity" , 0                 },;
					{"quantityAvailable", nQtdEst           },;
					{"lineStatus"       , cStatus           },;
					{"firstPassFill"    , .T.               },;
					{"unusualSale"      , .F.               } ;
				})
//					{"netValue"         , 0                 },;
//					{"totalValue"       , 0                 },;
//					{"taxes"            , 0                 },;
//					{"currency"         , 'BRL'             },;
				AADD(aItems, oItem)
			endif
		end

		(cAl)->(DBSkip())
	enddo

	(cAl)->(DbCloseArea())

	if LEN(aDevols) > 0
		// devoluções
		for nIdx := 1 to LEN(aItems)
			nIdx2 := ASCAN(aDevols, {|aDev| aDev[1] == aItems[nIdx]:GetValue("partNumber") })
			if nIdx2 > 0
				nQtdRet := aItems[nIdx]:GetValue("returnedQuantity")
				aItems[nIdx]:SetValue("returnedQuantity", nQtdRet + aDevols[nIdx2][2])
				// se está aberta calculo reservado, mas se estiver fechada, o "reservado" seria a qtd faturada, então fica 0 sempre
				if cStatus == "OPEN"
					nQtdRes := aItems[nIdx]:GetValue("reservedQuantity")
					aItems[nIdx]:SetValue("reservedQuantity", nQtdRes - aDevols[nIdx2][2])
					if aItems[nIdx]:GetValue("reservedQuantity", 0) < 0
						aItems[nIdx]:SetValue("reservedQuantity", 0)
					endif
				endif
			endif
		next
	endif
Return aItems
