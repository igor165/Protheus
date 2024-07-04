#INCLUDE "OGX110.ch"
#Include 'Protheus.ch'

/**{Protheus.doc} OGX110
Validação na Inclusão de Títulos a Pagar
garantindo que o título a ser incluso já não exista
e também que esteja amarrado a um contrato.
@param: 	Nil
@author: 	Fernando Pereira Leite
@since: 	03/05/2013
@Uso: 		SIGAFIN - Financeiro
@Alterado por: Marcelo R. Ferrari
@Data Alteração: 19/08/2014
**/

//Programa Original: ARMXPE15.PRW

Function OGX110()
Local lRetorno 	:= .T.
	If FindFunction("OGXUTOG") //Encontra a função
		If OGXUTOG()
			If FindFunction("OGX110A")
				lRetorno := OGX110A()
			Endif
		Endif 
	EndIf	
	
Return( lRetorno )