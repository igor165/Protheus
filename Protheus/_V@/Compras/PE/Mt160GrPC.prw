#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} Mt160GrPC
    Ponto de entrada disponibilizado para grava��o de valores e campos espec�ficos do Pedido de Compra (SC7).
    Executado durante a gera��o do pedido de compra na an�lise da cota��o.
    Grava��o da marca utilizada para cota��o.
/*/
user function Mt160GrPC()
// local aVencedor := ParamIXB[1]
// local aSC8 := ParamIXB[2]

    SC7->C7_XMARCA := SC8->C8_XMARCA 
	
return nil

/*
	MJ : 10.08.2017
		Grava Item de Solicitacao na tabela de Log
*/
User function MT160OK()
	RecLock("COI",.T.)
		COI->COI_FILIAL := xFilial("COI")
		COI->COI_NUMSC  := SC8->C8_NUMSC
		COI->COI_ITEM   := SC8->C8_ITEM
		COI->COI_DTHSOL := DtoC(Date()) + ' ' + Time()
		COI->COI_USOL   := cUserName
		COI->COI_DOCSC  := SC8->C8_NUM
	COI->(MsUnlock())
Return .T.