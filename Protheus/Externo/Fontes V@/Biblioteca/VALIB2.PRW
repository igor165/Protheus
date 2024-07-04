#INCLUDE "RWMAKE.CH"

//-----------------------------------------------------------------------------------------------
// Ponto de Entrada para validações após a confirmação, antes da gravação do fornecedor.
//-----------------------------------------------------------------------------------------------
/*
User Function MA020TDOK

If M->A2_X_PRUR=='S'
	If M->A2_TIPORUR <> 'J'
		Alert('Para Produtor Rural, o Tipo para Contribuição Social deverá ser "Jurídico"')
		Return .F.
	EndIf
	
	If Empty(M->A2_CODMUN)
		Alert('Para Produtor Rural, é obrigatório o preenchimento do campo "Cod. Mun. ZF"')
		Return .F.
	EndIf
EndIf     

//If M->A2_TIPORUR == 'J' 
//	If M->A2_X_PRUR<>'S'
//		Alert('Para Produtor Rural, o Tipo Produtor Rural deverá ser "S"')
//		Return .F.
//	EndIf
//	If Empty(M->A2_CODMUN)
//		Alert('Para Produtor Rural, é obrigatório o preenchimento do campo "Cod. Mun. ZF"')
//		Return .F.
 //	EndIf
//EndIf

Return .T.
*/
