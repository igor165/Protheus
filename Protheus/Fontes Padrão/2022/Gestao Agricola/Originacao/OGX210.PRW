#Include "totvs.ch"

/**{Protheus.doc} OGX210
Ponto de entrada na exclusao dos pedidos de compra
utilizado para alterar o status das comissoes geradas pelo
sistema no modulo de originacao.
@param: 	Nil
@author: 	Fernando Pereira Leite
@since: 	26/09/2013
@Alterado por: Marcelo R. Ferrari
@Alterado em: 21/08/2014
**/

//Programa Original: ARMXPE23

Function OGX210(lExclui)
/* Retirado 04/01/2016 - Cpos não utilizados ( Veio do Template), e não devem ser criados;

If IsBlind()
	Return ( .t. )
EndIf

If lExclui
	dbSelectArea("NNF")
	dbSetOrder( 1 )
	if dbSeek(xFilial( "NNF" ) + SC7->( C7_CTROG ) + SC7->( C7_ITENNF ) )
	
		If RecLock( "NNF", .f. )
			NNF->( NNF_STATUS ) 	:= "2" 
			NNF->( MsUnLock() )
		EndIf
	EndIf
EndIf

*/

Return( .t. )