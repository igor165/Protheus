#INCLUDE "OGX180.ch"
#include "protheus.ch"


/** {Protheus.doc} OGX180
Rotina chamada a partir do botão "Estorno" da rotina de Documentos de Saída ( MATA460A )
Chamado: Ma461Estor (MATA461)

@param: 	Nil
@return:	Nil
@author: 	Equipe Agroindustria
@since: 	02/03/2018
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGX180()
	Local aArea	:= GetArea()
	Local lRetorno := .t.

	dbSelectArea("NJ5")
	dbSetOrder(1)
	If dbSeek(xFilial("NJ5") + SC9->C9_PEDIDO)
		Help("",1,STR0001,,STR0002,1) //"Estorno não permitido!"###"Já foi realizada a Programação de Entrega para o pedido!"
		lRetorno := .f.
	EndIf

	RestArea(aArea)

Return(lRetorno)