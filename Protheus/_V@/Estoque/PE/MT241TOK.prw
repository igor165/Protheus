#INCLUDE "TOTVS.CH"

/* MB : 23.02.2022
	-> Testando esse ponto de entrada;
		-> Funcao de movimentacao sera descontinuada no dia: 04/04/2022;
			* https://tdn.totvs.com/pages/releaseview.action?pageId=606431987 
*/
User Function MT241TOK()
Local nI         := 1
Local _cMsg      := ""

// Local nD3COD     := aScan( aHeader, { |x| AllTrim(x[2])=="D3_COD"} )
// Local nD3XOBS    := aScan( aHeader, { |x| AllTrim(x[2])=="D3_X_OBS"} )
// Local nD3LOTECTL := aScan( aHeader, { |x| AllTrim(x[2])=="D3_LOTECTL"} )

For nI := 1 to Len( aCols )
	// TM DA MORTE
	If cTM == GetMV("JR_TMMORTE",,"511") .and. Empty( GdFieldGet("D3_X_OBS", nI) )
		_cMsg += iIf(Empty(_cMsg),"",CRLF) + "Campo OBSERVACAO nao informado na linha: " + cValToChar(nI)
	EndIf
	
	// LOTE
	// if SB1->B1_RASTRO=="L" .and. Empty( GdFieldGet("D3_LOTECTL", nI) )
	if Posicione("SB1", 1, xFilial("SB1")+GdFieldGet("D3_COD", nI), "B1_RASTRO")=="L" .and. Empty( GdFieldGet("D3_LOTECTL", nI) )
		_cMsg += iIf(Empty(_cMsg),"",CRLF) + "Campo LOTE nao informado na linha: " + cValToChar(nI)
	EndIf
Next nI

If !Empty( _cMsg )
	Aviso("Aviso", "Campos obrigatórios nao preenchidos: " + CRLF + _cMsg + CRLF + "Esta operacao será cancelada.", {"Sair"} )
	Return .F.
EndIf

// RestArea(aArea)
Return .T.
