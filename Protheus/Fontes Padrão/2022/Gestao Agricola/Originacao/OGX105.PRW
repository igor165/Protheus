#INCLUDE "OGX105.ch"
#Include 'Protheus.ch'

/**{Protheus.doc} OGX105
Validação no cancelamento da Baixa de Títulos a pagar
Gerar titulos do tipo NDF de comissao para a corretora
@param: 	Nil
@author: 	José Leite de Barros Neto
@since: 	15/07/2013
@alterado por: Marcelo R. Ferrari
@Alterado em: 18/08/2014
@Uso: 		SIGAFIN - Financeiro
@alterado por: VANIDA MOGGIO
@Alterado em: 10/04/2015
@Uso: 		SIGAFIN - Financeiro
**/
//Programa Original: ARMXPE17
Function OGX105()

	If FindFunction("OGXUTOG") //Encontra a função
		If OGXUTOG()
			If FindFunction("OGX105A")
				OGX105A()
		   Endif
		Endif 
	EndIf
	
Return( Nil )	