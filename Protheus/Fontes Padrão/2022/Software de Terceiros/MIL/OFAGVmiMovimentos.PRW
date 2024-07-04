#include "protheus.ch"

function OFAGVmiMovimentos()
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

/*/{Protheus.doc} OFAGVmiMovimentos
	Classe criada para padronizar as chamadas de ação da api do VMI

	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiMovimentos from OFAGVmiBase
	DATA Devolucao
	DATA Entrada
	DATA Orcamento
	DATA Pedido
	DATA Saida
	DATA Transferencia
	DATA VendaPerdida
	DATA Inventario
	DATA DadosPeca
	DATA Cliente
	DATA OS

	Method New() CONSTRUCTOR
EndClass

Method New() Class OFAGVmiMovimentos
	// Interfaces
	self:Pedido        := 'P'//edido
	self:Orcamento     := 'O'//rcamento
	self:OS            := 'OS'//rcamento
	self:Transferencia := 'T'//ransferencia
	self:VendaPerdida  := 'V'//endaPerdida
	self:Inventario    := 'I'//nventario
	self:DadosPeca     := 'DP'//Dados peça
	self:Cliente       := 'C'
return self
