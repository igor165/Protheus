#Include 'totvs.ch'

/**{Protheus.doc} OGX200
Ponto de Entrada na Importa��o de Pedidos de Compra
na Entrada de Documentos
@param: 	Nil
@author: 	Fernando Pereira Leite
@since: 	20/08/2013
@Uso: 		SIGAAGR - Origina��o de Gr�os
@Alterado Por: Marcelo R. Ferrari
@Alterado em: 21/08/2014
**/

//Programa Original: ARMXPE21
Function OGX200()
	Local 	_aCampos	:= {}
	
	// Retirado em 04/01/2016 - Pois veio do Template e n�o � utilizado para nada
	// e estes cpos n. seram criados ( Emerson / Fernanda)
	
/*	aAdd( _aCampos, SC7->C7_CTROG )
	aAdd( _aCampos, SC7->C7_CODSAF )
*/	
Return(_aCampos)