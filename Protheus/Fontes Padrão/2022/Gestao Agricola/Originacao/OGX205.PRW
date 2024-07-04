#Include 'Protheus.ch'

/**{Protheus.doc} OGX205
Ponto de entrada utilizado para mostrar campos
customizados na tela de importação de Pedidos de Compra
na rotina de Documento de Entrada.
@param: 	Nil
@author: 	Fernando Pereira Leite
@since: 	20/08/2013
@Uso: 		SIGAAGR - Originação de Grãos
@Alterado por: Marcelo R. Ferrari
@Alterado em: 21/08/2014
**/

//Programa Original: ARMXPE22
Function OGX205()
/* Retirado 04/01/2016 - cpos n. utilizados (veio do Template), e não devem ser criados ( Emerson / Fernanda )
Local 	nPosArm	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_CTROG"})
Local 	nPosSaf	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_CODSAF"})

If IsBlind()
	Return ( .t. )
EndIf
	
If FunName() $ "MATA103"
	aCols[Len(aCols),nPosArm]	:= SC7->( C7_CTROG )
	aCols[Len(aCols),nPosSaf]	:= SC7->( C7_CODSAF )
EndIf

Return ( Nil )
*/
Return( .t. )




