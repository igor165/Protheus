#Include "Rwmake.ch" 
#Include "Protheus.ch"
#Include "TopConn.ch"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  05.01.2018                                                              |
 | Desc:  Este PE tem como objetivo, validar o preenchimento do campo Lote, caso  |
 |       o produto esteja marcado como tal.                                       |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/

User Function MT410TOK()
Local aArea			:= GetArea()
Local lRet          := .T.				// Conteudo de retorno
// Local cMsg         	:= ""				// Mensagem de alerta
// Local nOpc         	:= PARAMIXB[1]	// Opcao de manutencao
// Local aRecTiAdt 	:= PARAMIXB[2]	// Array com registros de adiantamentoc
// Msg := "Entrou no PE(MT410TOK) ap�s acionamento do bot�o de OK, passando os seguintes par�metros:"+Chr(10)+Chr(10)+Chr(13)+"nOpc: "+AllTrim(Str(nOpc));
//              +"    e   aRecTiAdt: "+AllTrim(Str(Len(aRecTiAdt)))+" elementos"
// Aviso("Teste PE - A410VldTOK",cMsg,{"OK"}) 
Local nPos			:= 0
Local nI			:= 0

DbSelectArea("SB1")
SB1->(DbSetOrder(1))

DbSelectArea("SB8")
SB8->(DbSetOrder(3))

	For nI := 1 to len(aCols)
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek( xFilial("SB1") + GdFieldGet("C6_PRODUTO", nI) )) .AND.  SB1->B1_RASTRO == "L" .AND. ;
				Posicione('SF4', 1, xFilial('SF4')+GdFieldGet("C6_TES", nI), 'F4_ESTOQUE')=="S"
			If !(lRet := !Empty( GdFieldGet("C6_LOTECTL", nI) )) 
				Aviso( "Campo Lote nao informado",;
					   "N�o foi localizado Endere�o do Lote para o produto: " + AllTrim(SB1->B1_COD) + ;
					   " informado na linha: " + cValToChar(nI) , {"OK"})
			    Exit
			EndIf
			
			SB8->(DbSetOrder(3))
			If !( lRet := SB8->(DbSeek( xFilial("SB8")+GdFieldGet("C6_PRODUTO", nI)+GdFieldGet("C6_LOCAL", nI)+GdFieldGet("C6_LOTECTL", nI) )) )
				Aviso( "Lote n�o localizado",;
					   "O Lote " + AllTrim(GdFieldGet("C6_LOTECTL", nI)) + " n�o foi localizado para o produto: " + AllTrim(SB1->B1_COD) + ;
					   " informado na linha: " + cValToChar(nI) , {"OK"})
			    Exit
			EndIf
		EndIf
	Next nI 

RestArea(aArea)
Return lRet //  := MsgYesNo('MT410TOK' + CRLF + 'Deseja continuar ???', 'Aten��o' )




// Ponto de entrada na abertura do pedido
/*
User Function M410ALOK()
Return lRet := MsgYesNo('M410ALOK' + CRLF + 'Deseja continuar ???', 'Aten��o' )
*/