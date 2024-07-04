#include "protheus.ch"

function OFAGVmi()
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
	Classe responsavel por direcionar corretamente as chamadas para as classes
	com a responsabilidade correta.

	@type class
	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmi
	Data oVmiMovimentos
	Data oVmiParametros
	Data oVmiDadosPeca
	Data oVmiCliente
	Data oVmiInventario
	Data oVmiVendaPerdida
	Data oVmiPedido
	Data oVmiOrcamento
	Data oVmiWs
	Data oVmiOrdemServico
	Data oEmailHlp
	Data lUsaVmi

	Method New() CONSTRUCTOR
	Method Trigger()
	Method Recriar()
	Method GrupoValido()
	Method Enviar()
	Method EmUso()
EndClass

/*/{Protheus.doc} New
	Construtor básico

	@type function
	@author Vinicius Gati
	@since 12/06/2017
/*/
Method New() Class OFAGVmi
	::oVmiMovimentos    := OFAGVmiMovimentos():New()
	::oVmiParametros    := OFAGVmiParametros():New()
	::oVmiDadosPeca     := OFAGVmiDadosPeca():New()
	::oVmiCliente       := OFAGVmiCliente():New()
	::oVmiInventario    := OFAGVmiInventario():New()
	::oVmiVendaPerdida  := OFAGVmiVendaPerdida():New()
	::oVmiPedido        := OFAGVmiPedido():New()
	::oVmiOrcamento     := OFAGVmiOrcamento():New()
	::oVmiWs            := OFAGVmiWebService():New()
	::oVmiOrdemServico  := OFAGVmiOrdemServico():New()
	::oEmailHlp         := DMS_EmailHelper():New()
	::lUsaVmi           := ! Empty(::oVmiParametros:pass())
return self


/*/{Protheus.doc} Trigger
	Será responsável por chamar o gerador de json correto

	@type function
	@author Vinicius Gati
	@since 12/06/2017
/*/
Method Trigger(aData) Class OFAGVmi
	Local oParams
	Local cEvento
	Default aData := {}
	oParams := DMS_DataContainer():New(aData)
	cEvento := oParams:GetValue("EVENTO")
	if self:EmUso() .and. self:oVmiParametros:FilialValida(cFilAnt)
		Do Case
		Case cEvento == self:oVmiMovimentos:DadosPeca
			nControle  := self:oVmiDadosPeca:Trigger(oParams)
		Case cEvento == self:oVmiMovimentos:Inventario
			nControle  := self:oVmiInventario:Trigger(oParams)
		Case cEvento == self:oVmiMovimentos:Cliente
			nControle  := self:oVmiCliente:Trigger(oParams)
		Case cEvento == self:oVmiMovimentos:VendaPerdida
			nControle  := self:oVmiVendaPerdida:Trigger(oParams)
		Case cEvento == self:oVmiMovimentos:Orcamento
			nControle  := self:oVmiOrcamento:Trigger(oParams)
		Case cEvento == self:oVmiMovimentos:Pedido
			nControle  := self:oVmiPedido:Trigger(oParams)
		Case cEvento == self:oVmiMovimentos:OS
			nControle  := self:oVmiOrdemServico:Trigger(oParams)
		EndCase
	else
		nControle := 0
	endif
Return nControle

/*/{Protheus.doc} Enviar
	Função que repassa o enviar para o responsável correto

	@type function
	@author Vinicius Gati
	@since 27/06/2017
	@param aData, Array, Array em formato hash contendo:<br>
		{"CODIGO", %Codigo do VE6%}

/*/
Method Enviar(aData) Class OFAGVmi
	cResp := self:oVmiWs:Enviar(aData)
Return cResp

/*/{Protheus.doc} Recriar
	Função que recria o json que está impeditivo, usado para refazer jsons<br>
	após envio de patch para alguma correção.

	@type function
	@author Vinicius Gati
	@since 27/07/2017
	@param aData, Array, Array em formato hash contendo: {"CODIGO", %Codigo do VB6%}
/*/
Method Recriar(cCodVB6) Class OFAGVmi
	local cJson        := FM_SQL("SELECT VB6_CONTRO FROM " + RetsqlName('VB6') + " WHERE "+IIF(valtype(cCodVB6) == 'C', 'VB6_CODIGO', 'R_E_C_N_O_')+" = '"+cValtoChar(cCodVB6)+"' AND D_E_L_E_T_ = ' ' ")
	local oJsonParse   := DMS_JsonParse():New(cJson)
	local oDtContainer := oJsonParse:ParseToObj()
Return self:Trigger(oDtContainer:aData)

/*/{Protheus.doc} GrupoValido
	Verifica se o grupo do item é valido para o VMI

	@type function
	@author Vinicius Gati
	@since 27/06/2017
/*/
Method GrupoValido(cB1_GRUPO) Class OFAGVmi
	cB1_GRUPO := ALLTRIM(cB1_GRUPO)
	if ASCAN(self:oVmiParametros:grupos(), {|x| x == cB1_GRUPO }) > 0
		return .T.
	else
		if ASCAN(self:oVmiParametros:gruposParalelos(), {|x| x == cB1_GRUPO }) > 0
			return .T.
		endif
	endif
Return .F.

/*/{Protheus.doc} EmUso
	Verifica se O VMI foi configurado e está sendo usado no sistema

	@type function
	@author Vinicius Gati
	@since 05/07/2017
/*/
Method EmUso() Class OFAGVmi
Return self:lUsaVmi
