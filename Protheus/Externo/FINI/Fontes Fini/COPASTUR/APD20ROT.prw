#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} APD20ROT

Ponto de entrada utilizado para adicionar rotinas ao menu da rotina de Cadastro de Participantes.
@author  Allan Constantino Bonfim
@since   01/03/2020
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------  
User Function APD20ROT()

	Local aRotAdd 	:= {}
	
	AADD(aRotAdd, {"Gerar Fornecedor"	, "U_FIWS8RD0", 0, 7})  
	AADD(aRotAdd, {"Integrar Alatur"	, "U_FIWS3RD0", 0, 7})  

Return aRotAdd