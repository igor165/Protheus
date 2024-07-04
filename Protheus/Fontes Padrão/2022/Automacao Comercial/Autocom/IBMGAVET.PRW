#INCLUDE "Protheus.ch"

Function IBMGav4610_Dummy			// Funcao "Dummy" para poder gerar o Patch
Return(NIL)

CLASS IBMGAV4610
//	DATA 
	DATA nHandle
	METHOD New()
	METHOD GavetaAbr 	(cModelo, cPorta )
	METHOD GavetaAci 	(cPorta)
	METHOD GavetaFec 	()
ENDCLASS

METHOD New() CLASS IBMGAV4610
Return

METHOD GavetaAbr(cModelo, cPorta ) CLASS IBMGAV4610
Return(0)

METHOD GavetaAci(cPorta) CLASS IBMGAV4610
Return(0)

METHOD GavetaFec() CLASS IBMGAV4610
Return(0)