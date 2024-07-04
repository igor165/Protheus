#include "protheus.ch"

function OFAGVmiOrcamento()
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

/*/{Protheus.doc} OFAGVmiOrcamento
	Interface DMS - 4 da definição do VMI
	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiOrcamento from OFAGVmiBase
	Data cIntName
	Data oSqlHlp
	Data oVmi
	Data aItemsDer
	Method New() CONSTRUCTOR
	Method Trigger()
	Method TriggerDer()
	Method TriggerLostSales()
	Method ControleVB6()
	Method GetOrder()
	Method GetType()
	Method GetItems()
	Method QtdReservada()
	Method QtdDevolvida()
	Method isFaturado()
	Method GetDtFat()
EndClass

Method New() Class OFAGVmiOrcamento
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
	::aItemsDer := {}
return self

/*/{Protheus.doc} Trigger
	Dispara evento para envio de dados ao VMI, interface DMS-4

	@author Vinicius Gati
	@since 22/06/2017
	@param oParams, DMS_DataContainer, com os dados: NUMERO_ORCAMENTO, CLIENTE e LOJA
/*/
Method Trigger(oParams) Class OFAGVmiOrcamento
	Local oJson  := DMS_DataContainer():New()
	Local cCoord := ""
	Local cVS1_NUMORC := oParams:GetValue("NUMERO_ORCAMENTO")

	if oParams:GetBool('INICIALIZACAO', .F.) == .T.
		if self:oVmiJson:Exist(oParams)
			return 'ja_gerado'
		endif
	endif

	self:oVmi := OFAGVmi():New()

	dbSelectArea("VS1")
	dbSetOrder(1)
	msSeek(xFilial('VS1') + cVS1_NUMORC)

	if VS1->VS1_STATUS != 'X'
		return .f.
	endif

	if VS1->VS1_TIPORC == "3" .and. Empty(VS1->VS1_FILDES)
		return .f.
	endif

	// Pedidos não são tratados como orçamento, apenas é disparado venda perdida dele
	if VS1->VS1_TIPORC == "P" .and. oParams:GetBool('INICIALIZACAO', .F.) == .F.
		self:TriggerLostSales(cVS1_NUMORC)
	endif

	SA1->(dbGoTo(self:oFilHlp:GetCliente(cFilAnt)))
	oJson:SetValue("dealerLegalNumber", self:fmtDoc(self:oVmiParametros:DocMatriz()))
	oJson:SetValue("extractionDateTime", FWTIMESTAMP(5))
	oJson:SetValue("order", self:GetOrder(cVS1_NUMORC))
	if ValType( oJson:GetValue("order", Nil) ) == "U" // não envia se não gerou dados
		return "0"
	endif

	if LEN(oJson:GetValue("order"):GetValue("items")) > 0 // pode acontecer de um orçamento não ter peças AGCO, nesse caso nada será enviado
		If VS1->VS1_TIPORC <> "3" 
			cCoord := self:oVmiJson:Persist(self:cIntName, oParams, {oJson})
			if oParams:GetBool('INICIALIZACAO', .F.) == .F.
				self:oVmi:Trigger({;
					{'EVENTO'      , self:oVmi:oVmiMovimentos:Cliente },;
					{'NUMCONTROLE' , cCoord          },;
					{'ORIGEM'      , "DMS4_DMS6"     },;
					{'CODIGO'      , VS1->VS1_CLIFAT },;
					{'LOJA'        , VS1->VS1_LOJA   } ;
				})
				self:TriggerDer(self:aItemsDer, cCoord)
			endif
		Else
			if oParams:GetBool('INICIALIZACAO', .F.) == .F.
				cCoord := self:ControleVB6() // Necessario batizar o Nro de Controle pq Orcamentos de Transferencia nao tem DMS4/DMS6
				self:TriggerDer(self:aItemsDer,cCoord)
			EndIf
		EndIf
	endif
Return cCoord

/*/{Protheus.doc} TriggerDer
	Engatilha os eventos derivados para atualizar AGCO
	é feito de 7 em 7 peças para melhorar performance de geração e envio de jsons

	@author Vinicius Gati
	@since 21/06/2017
/*/
Method TriggerDer(aItems, cCoord) Class OFAGVmiOrcamento
		Local nX     := 1
		For nX:= 1 to Len(aItems)
			oItem := aItems[nX]
			self:oVmi:Trigger({;
				{'EVENTO', self:oVmi:oVmiMovimentos:Inventario},;
				{'NUMCONTROLE' , cCoord                       },;
				{'ORIGEM', "DMS4_DMS1"                        },;
				{'PECAS' , {oItem:GetValue('partNumber')}     } ;
			})
		Next
Return .T.

/*/{Protheus.doc} ControleVB6
	Pega Nro de Controle do VB6

	@author Andre Luis Almeida
	@since 30/12/2019
/*/
Method ControleVB6() Class OFAGVmiOrcamento
Local cCoord := Soma1(FM_SQL("SELECT MAX(VB6_NCONTR) FROM "+RetSqlName('VB6')+" WHERE VB6_FILIAL = '"+xFilial('VB6')+"' AND D_E_L_E_T_ = ' '")) // Único para todos os aJsons que serão salvos
VB6->(dbGoTo(VB6->(Recno())))
Return cCoord

/*/{Protheus.doc} TriggerLostSales
	Dispara evento para envio de dados ao VMI, interface DMS-5 vendas perdidas para pedido

	@author Vinicius Gati
	@since 22/06/2017
	@param cVS1_NUMORC, string, numero do orcamento(pedido)
/*/
Method TriggerLostSales(cVS1_NUMORC, cOrigem) Class OFAGVmiOrcamento
	local cQuery     := ""
	local aResults   := {}
	local nX         := 0
	local oVmiParams := OFAGVmiParametros():New()
	default cOrigem  := "INTERNA"

	dbSelectArea("VS1")
	dbSetOrder(1)
	msSeek(xFilial('VS1') + cVS1_NUMORC)

	cQuery += " SELECT B1_COD, VS3_QTDINI "
	cQuery += "   FROM " + self:oSqlHlp:NoLock('VS3')
	cQuery += "   JOIN " + self:oSqlHlp:NoLock('SB1') + " ON B1_FILIAL = '"+xFilial('SB1')+"' AND B1_CODITE = VS3_CODITE AND B1_GRUPO = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE VS3_FILIAL = '"+xFilial('VS3')+"' "
	cQuery += "   AND VS3_NUMORC = '"+cVS1_NUMORC+"' "
	cQuery += "   AND VS3_MOTPED = '"+oVmiParams:codVendaPerdida()+"' "
	cQuery += "   AND VS3.D_E_L_E_T_  = ' ' "
	aResults := self:oSqlHlp:GetSelectArray(cQuery, 2)

	for nX := 1 to LEN(aResults)
		if VS1->VS1_TIPORC == 'P'
			cTipo := self:oVmi:oVmiVendaPerdida:TipoBalcao()
		else
			cTipo := self:oVmi:oVmiVendaPerdida:TipoOficina()
		end
		self:oVMi:Trigger({;
			{'EVENTO'         , self:oVmi:oVmiMovimentos:VendaPerdida },;
			{'CODIGO_PECA'    , aResults[nX, 1]                       },;
			{'QUANTIDADE'     , aResults[nX, 2]                       },;
			{'CODIGO_CLIENTE' , VS1->VS1_CLIFAT                       },;
			{'LOJA'           , VS1->VS1_LOJA                         },;
			{'DATA'           , VS1->VS1_DATORC                       },;
			{'ORIGEM'         , cOrigem                               },;
			{'TIPO'           , cTipo                                 } ;
		})
	next
Return .T.

/*/{Protheus.doc} GetOrder
	Retorna objeto data container no formato de order para VMI que serã cnvertido em json

	@author Vinicius Gati
	@since 23/06/2017
	@param cVS1_NUMORC, String , código do orçamento
/*/
Method GetOrder(cVS1_NUMORC) Class OFAGVmiOrcamento
	Local aArea    := getArea()
	Local aAreaA1  := getArea('SA1')
	Local aAreaVS1 := getArea('VS1')
	Local oOrder   := Nil

	dbSelectArea("VS1")
	dbSetOrder(1)
	msSeek(xFilial('VS1') + cVS1_NUMORC)

	if VS1->VS1_TIPORC == "3" // transferencia
		SA1->(dbGoTo(self:oFilHlp:GetCliente(VS1->VS1_FILDES)))
	else
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial('SA1')+VS1->VS1_CLIFAT+VS1->VS1_LOJA)
	endif

	// se for cliente parceiro não envia dados
	if ! self:oVmi:oVmiParametros:ClienteValido(SA1->(RECNO()))
		return Nil
	end

	cIdent := iif(VS1->VS1_TIPORC == "P", VS1->VS1_NUMORC, VS1->VS1_PEDREF)
	if Empty(cIdent)
		cIdent := VS1->VS1_NUMORC
	endif
	oOrder := DMS_DataContainer():New({;
		{"orderId"            , xFilial('VS1') + "_" + cIdent  },;
		{"orderDate"          , VS1->VS1_DATORC                },;
		{"orderType"          , self:GetType(VS1->VS1_TIPORC)  },;
		{"customerLegalNumber", self:fmtDoc(SA1->A1_CGC)       },;
		{"items"              , self:GetItems(VS1->VS1_NUMORC) } ;
	})

	RestArea(aAreaVS1)
	RestArea(aAreaA1)
	RestArea(aArea)
Return oOrder

/*/{Protheus.doc} GetItems
	Retorna objeto data container no formato de order para VMI que serã cnvertido em json

	@author Vinicius Gati
	@since 23/06/2017
	@param cVS1_NUMORC, String , código do orçamento
/*/
Method GetItems(cVS1_NUMORC) Class OFAGVmiOrcamento
	Local aArea     := getArea()
	Local aAreaVS3  := getArea('VS3')
	local aItems    := {}
	local cQueryNA  := ''
	Local nQtdIni   := 0
	Local nQtdEstNa := 0
	Local cCodSit   := ''
	Local nQtdRes   := 0
	Local nQtdDev   := 0
	Local nQtdEst   := 0
//	Local nVlrTot   := 0
//	Local nVlrImp   := 0
	Local nSequen   := 0
	Local cStatus   := ""

	dbSelectArea('VS3')
	dbSetOrder(1)
	dbSeek(xFilial('VS3') + cVS1_NUMORC)

	do while VS3->VS3_FILIAL + VS3->VS3_NUMORC == xFilial('VS3') + cVS1_NUMORC
		if self:oVmi:GrupoValido( VS3->VS3_GRUITE )

			cB1_COD := FM_SQL("SELECT B1_COD FROM " + RetSqlName('SB1') +;
												" WHERE B1_FILIAL  = '"+xFilial('SB1')+"'"+;
												"   AND B1_CODITE  = '"+VS3->VS3_CODITE+"'"+;
												"   AND B1_GRUPO   = '"+VS3->VS3_GRUITE+"'"+;
												"   AND D_E_L_E_T_ = ' ' ")

			if ! Empty(cB1_COD)
				nQtdRes := self:QtdReservada(VS1->VS1_NUMORC, cB1_COD)
				nQtdDev := self:QtdDevolvida(VS1->VS1_NUMORC, cB1_COD)
				nQtdEst := self:EmEstoque(cB1_COD)
				nSequen++
				cStatus := IIf(VS1->VS1_STATUS=="C".or.VS3->VS3_QTDAGU==0,"CLOSED","OPEN")
				oItem := DMS_DataContainer():New({;
					{"orderLineNumber"  , Alltrim(str(nSequen))                        },;
					{"partNumber"       , cB1_COD                                      },;
					{"shippedQuantity"  , VS3->VS3_QTDITE - VS3->VS3_QTDAGU            },;
					{"reservedQuantity" , nQtdRes                                      },;
					{"returnedQuantity" , nQtdDev                                      },;
					{"canceledQuantity" , 0                                            },;
					{"requestedDate"    , VS1->VS1_DATORC                              },;
					{"quantityAvailable", nQtdEst                                      },;
					{"lineStatus"       , cStatus                                      },;
					{"firstPassFill"    , .T.                                          },;
					{"requestedQuantity", VS3->VS3_QTDITE                              },;
					{"unusualSale"      , self:UnusualSale(VS3->VS3_CODSIT)            } ;
				})
//					{"netValue"         , 0                                            },;
//					{"totalValue"       , 0                                            },;
//					{"taxes"            , 0                                            },;
//					{"currency"         , 'BRL'                                        },;

				/* 
					Se é o pedido usa os dados direto caso seja orçamento 
					preciso encontrar os dados do pedido para enviar 
				*/
				if Empty(VS1->VS1_PEDREF) 
					nQtdIni   := VS3->VS3_QTDINI
					nQtdEstNa := VS3->VS3_QESTNA
					cCodSit   := VS3->VS3_CODSIT
//					nVlrImp   := VS3->VS3_ICMCAL
//					nVlrTot   := VS3->VS3_VALTOT
				else
					cQueryNA := ""
					cQueryNA += " SELECT VS3_QTDINI, VS3_QESTNA, VS3_CODSIT "
//					cQueryNA += " SELECT VS3_QTDINI, VS3_QESTNA, VS3_CODSIT, VS3_ICMCAL, VS3_VALTOT "
					cQueryNA += "   FROM " + self:oSqlHlp:NoLock('VS3')
					cQueryNA += "  WHERE VS3_FILIAL = '"+VS3->VS3_FILIAL+"' "
					cQueryNA += "    AND VS3_NUMORC = '"+VS1->VS1_PEDREF+"' "
					cQueryNA += "    AND VS3_GRUITE = '"+VS3->VS3_GRUITE+"' "
					cQueryNA += "    AND VS3_CODITE = '"+VS3->VS3_CODITE+"' "
					cQueryNA += "    AND VS3_SEQUEN = '"+VS3->VS3_SEQUEN+"' "
					cQueryNA += "    AND D_E_L_E_T_ = ' ' "
					aValues := self:oSqlHlp:GetSelectArray(cQueryNA, 3)
					if LEN(aValues) >= 1
						nQtdIni   := aValues[1,1]
						nQtdEstNa := aValues[1,2]
						cCodSit   := aValues[1,3]
//						nVlrImp   := aValues[1,4]
//						nVlrTot   := aValues[1,5]
					end
					oItem:SetValue("shippedDate", self:GetDtFat(VS1->VS1_FILIAL, VS1->VS1_NUMORC))
				end
				oItem:SetValue("firstPassFill"    , IIF(nQtdIni <= nQtdEstNa, .T., .F.))
				oItem:SetValue("requestedQuantity", nQtdIni)
				oItem:SetValue("unusualSale"      , self:UnusualSale(cCodSit))
				oItem:SetValue("shippedDate"      , self:GetDtFat(VS1->VS1_NUMNFI, VS1->VS1_SERNFI))
//				oItem:SetValue("netValue"         , nVlrTot - nVlrImp ) // Valor Liquido de Venda
//				oItem:SetValue("totalValue"       , nVlrTot ) // Valor TOTAL de Venda
//				oItem:SetValue("taxes"            , nVlrImp ) // Valor Impostos de Venda (ICMS)
				If cStatus == "CLOSED"
					AADD(aItems, oItem)
				EndIf
				AADD(self:aItemsDer, oItem)
			end
		end

		VS3->(dbSkip())
	end

	RestArea(aAreaVS3)
	RestArea(aArea)
Return aItems

/*/{Protheus.doc} GetType
	Converte o tipo do orçamento conforme documentado no VMI

	@author Vinicius Gati
	@since 23/06/2017
	@param cType, String , VS1_TIPORC
/*/
Method GetType(cVS1_TIPORC) Class OFAGVmiOrcamento
	do case
	case cVS1_TIPORC == 'P'
		return 'S'
	case cVS1_TIPORC == '1'
		return 'S'
	case cVS1_TIPORC == '2'
		return 'W'
	case cVS1_TIPORC == '3'
		return 'T'
	end
Return 'S'

/*/{Protheus.doc} QtdReservada
	Quantidade reservada da peça para o orcamento

	@author Vinicius Gati
	@since 23/06/2017
	@param cVS1_NUMORC, String , Numero do orcamento
	@param cB1_COD, String, Codigo do produto
/*/
Method QtdReservada(cVS1_NUMORC, cB1_COD) Class OFAGVmiOrcamento
// todos os status menos em branco e C para filtrar
	local cVldsts := JD06ResFases("' ', 'C'") // not in parametro
// todos os status menos X para o filtro do loja
	local cVldLj  := JD06ResFases("'X'") // not in parametro

	local cSQL := " SELECT COALESCE( SUM(VE6_QTDITE), 0) "
	cSQL += "        FROM "+self:oSqlHlp:NoLock('VE6')
	cSQL += "        JOIN "+self:oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_GRUPO = VE6_GRUITE AND B1_CODITE = VE6_CODITE  AND SB1.D_E_L_E_T_ = ' ' "
	cSQL += "   LEFT JOIN "+self:oSqlHlp:NoLock('VS1')+" ON VS1.VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMORC = VE6_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
	cSQL += "       WHERE VE6.VE6_FILIAL='"+xFilial('VE6')+"' "
	cSQL += "         AND VE6.VE6_INDREG = '3' "
	cSQL += "         AND (CASE WHEN VS1_NUMNFI = ' ' THEN '0' ELSE VS1_STATUS END ) IN (" + cVldLj + ") "  // só X não entra // tratamento do loja
	cSQL += "         AND VS1_STATUS IN (" + cVldsts + ") "
	cSQL += "         AND VS1_NUMORC = '"+cVS1_NUMORC+"' "
	cSQL += "         AND B1_COD     = '"+cB1_COD+"' "
	cSQL += "         AND VE6.D_E_L_E_T_ = ' ' "
Return FM_SQL(cSQL)

/*/{Protheus.doc} QtdDevolvida
	Quantidade com devolucao do orcamento e peca

	@author Vinicius Gati
	@since 23/06/2017
	@param cVS1_NUMORC, String , Numero do orcamento
	@param cB1_COD, String, Codigo do produto
/*/
Method QtdDevolvida(cVS1_NUMORC, cB1_COD) Class OFAGVmiOrcamento
	local cQuery := " SELECT SUM(D1_QUANT) "
	cQuery += "    FROM "+self:oSqlHlp:NoLock('SD1')
	cQuery += "    JOIN "+self:oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD     = SD1.D1_COD      AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "    JOIN "+self:oSqlHlp:NoLock('SF2')+" ON SF2.F2_FILIAL = '"+xFilial("SD1")+"' AND SF2.F2_DOC     = SD1.D1_NFORI    AND SF2.F2_SERIE   = SD1.D1_SERIORI  AND SF2.D_E_L_E_T_ = ' '  "
	cQuery += "    JOIN "+self:oSqlHlp:NoLock('SD2')+" ON SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND SD2.D2_DOC     = SF2.F2_DOC      AND SD2.D2_SERIE   = SF2.F2_SERIE    AND SD2.D2_COD     = SD1.D1_COD     AND SD1.D1_ITEMORI = SD2.D2_ITEM AND SD2.D_E_L_E_T_=' '  "
	cQuery += "    JOIN "+self:oSqlHlp:NoLock('VS1')+" ON VS1.VS1_FILIAL= '"+xFilial("VS1")+"' AND VS1.VS1_NUMNFI = SD2.D2_DOC      AND VS1.VS1_SERNFI = SD2.D2_SERIE    AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "         AND VS1.VS1_NUMORC = '"+cVS1_NUMORC+"' "
	cQuery += "    JOIN "+self:oSqlHlp:NoLock('SF4')+" ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4.F4_CODIGO  = SD2.D2_TES      AND SF4.F4_OPEMOV  = '05'            AND SF4.D_E_L_E_T_ =' '  "
	cQuery += "    JOIN "+self:oSqlHlp:NoLock('SF4', 'SF4_SD1')+" ON SF4_SD1.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4_SD1.F4_CODIGO  = SD1.D1_TES AND SF4_SD1.F4_OPEMOV  = '09' AND SF4_SD1.D_E_L_E_T_ =' '  "
	cQuery += "   WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"'  "
	cQuery += "     AND SD1.D1_COD = '"+cB1_COD+"' "
	cQuery += "     AND SF4_SD1.F4_OPEMOV = '09' "
	cQuery += "     AND SD1.D_E_L_E_T_ = ' ' "
Return FM_SQL(cQuery)

/*/{Protheus.doc} isFaturado
	Retorna se o orçamento foi faturado

	@type function
	@author Vinicius Gati
	@since 11/09/2019
/*/
Method isFaturado(cFili, cNumOrc) Class OFAGVmiOrcamento
	local cNumNfi := ""
	local cQuery := " SELECT VS1_NUMNFI "
	cQuery += "   FROM "+self:oSqlHlp:NoLock('VS1')
	cQuery += "  WHERE VS1_FILIAL = '"+cFili+"' "
	cQuery += "    AND VS1_NUMORC = '"+cNumOrc+"' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	cNumNfi := fm_sql(cQuery)
	if ! Empty(cNumNfi)
		return .T. /* Faturado? */	
	endif
Return .F.

/*/{Protheus.doc} GetDtFat
	Data de faturamento

	@type function
	@author Vinicius Gati
	@since 11/09/2019
/*/
Method GetDtFat(cNumNfi, cSerNfi) Class OFAGVmiOrcamento
	local dData
	cArea := GetArea()
	dbSelectArea('SD2')
	dbSetOrder(3)
	if dbSeek(xFilial('SD2')+cNumNfi+cSerNfi)
		dData := SD2->D2_EMISSAO
	endif
	RestArea(cArea)
Return dData