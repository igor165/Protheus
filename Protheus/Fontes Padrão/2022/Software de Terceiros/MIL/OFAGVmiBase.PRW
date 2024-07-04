#include "protheus.ch"

function OFAGVmiBase()
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

/*/{Protheus.doc} OFAGVmi
	Classe para ser herdada por todos as classes de interface do VMI, define os dados
	e variaveis utilizadas em validacoes futuras.

	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiBase from LongClassName
	Data aMapValid // dados que serão usados para validar os valores antes de enviar ao VMI
	Data oDados    // dados que serão transformados em JSON
	Data aErros    // Array contendo erros de validação do objeto VMI
	Data oVmiParametros
	Data oArHlp
	Data oFilHlp
	Data oVmiJson

	Method New() CONSTRUCTOR
	Method valid()
	Method Trigger()
	Method EmEstoque()
	Method UnusualSale()
	Method fmtDoc()
EndClass

Method New(oDados) Class OFAGVmiBase
	Default oDados := DMS_DataContainer():New()
	::oDados    := oDados
	::aErros    := {}
	::aMapValid := {}
	::oVmiParametros := OFAGVmiParametros():New()
	::oArHlp         := DMS_ArrayHelper():New()
	::oFilHlp        := DMS_FilialHelper():New()
	::oVmiJson       := OFAGVmiJson():New()
	AADD(::aMapValid, {"data:extractionDateTime", "P001"})
	AADD(::aMapValid, {"data:extractionDateTime", "Obri"})
	AADD(::aMapValid, {"data:dealerLegalNumber" , "Obri"})
return self

Method valid() class OFAGVmiBase
	Local lValid := .T.
Return lValid

Method Trigger() class OFAGVmiBase
Return 0

Method fmtDoc(cDoc) Class OFAGVmiBase
	Local cFmtDoc := ""
	cDoc := ALLTRIM(cDoc)
	if LEN(cDoc) > 11
		cFmtDoc := TRANSFORM(cDoc,"@R 99.999.999/9999-99") //CNPJ
	else
		cFmtDoc := TRANSFORM(cDoc, "@R 999.999.999-99") // CPF
	EndIf
Return cFmtDoc

/*/{Protheus.doc} EmEstoque
	Retorna qtd em estoque usando nnr_vdadms

	@author Vinicius Gati
	@since 04/07/2017
	@param cCodSit, String, Código da situação
/*/
Method EmEstoque(cB1_COD) Class OFAGVmiBase
	local cQuery := ""
	if NNR->(FieldPos("NNR_VDADMS")) > 0
		cQuery += "    SELECT COALESCE(SUM(CASE WHEN NNR_VDADMS = '1' OR B2_LOCAL = '01' THEN B2_QATU ELSE NULL END),0) "
		cQuery += "      FROM " + RetSqlName('SB2') + " SB2 "
		cQuery += " LEFT JOIN " + RetSqlName('NNR') + " NNR ON NNR_FILIAL = '"+xFilial('NNR')+"' AND NNR_CODIGO = B2_LOCAL AND NNR_VDADMS = '1' AND NNR.D_E_L_E_T_ = ' ' "
		cQuery += "     WHERE B2_FILIAL = '" + xFilial('SB2') + "' "
	else
		cQuery += " SELECT COALESCE(SUM(B2_QATU),0) "
		cQuery += "   FROM " + RetSqlName('SB2') + " SB2 "
		cQuery += "   JOIN " + RetSqlName('SB1') + " SB1 ON B1_FILIAL = '"+xFilial('SB1')+"' AND B2_COD = B1_COD AND B1_LOCPAD = B2_LOCAL AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "  WHERE B2_FILIAL = '" + xFilial('SB2') + "' "
		cQuery += "    AND B2_LOCAL = B1_LOCPAD "
	end
	cQuery += " AND B2_COD   = '"+cB1_COD+"' "
	cQuery += " AND SB2.D_E_L_E_T_ = ' ' "
	nQtd := FM_SQL(cQuery)
	if nQtd < 0
		nQtd := 0
	end
return nQtd

/*/{Protheus.doc} UnusualSale
	Verifica se a venda é não normal(queima de estoque, promoção, liquidação, etc)

	@author Vinicius Gati
	@since 23/06/2017
	@param cCodSit, String, Código da situação
/*/
Method UnusualSale(cCodSit) Class OFAGVmiBase
	If cCodSit == self:oVmiParametros:codSitVendaAnormal()
		return .T.
	Endif
Return .F.