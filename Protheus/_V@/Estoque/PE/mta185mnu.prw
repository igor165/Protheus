#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} mta185mnu
//TODO Descri��o auto-gerada.
@author Renato de Bianchi
@since 16/02/2018
@type function
@return Array, Conte�do de aButtons.
/*/
user function mta185mnu()
local aButtons := {}
	AAdd(aRotina, {'Ficha Entrega EPI', "u_VaEstR07(.T.)"   , 0 , 9,0,Nil })
	AAdd(aRotina, {'Termo Ret Material', "u_VaEstR15(.T.)"   , 0 , 9,0,Nil })
return aButtons