#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*{Protheus.doc} STDUpdB2B3
Funcao que atualiza a tabela SB2, ou seja, o estoque do produto.

@param
@author  	Vendas & CRM
@version 	P12
@since   	15/05/2012
@return
@obs
@sample
*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STDUpdB2B3(xParam,cFil)
Local aFiliais	:= {}
Local nX		:= 0

If ValType(xParam) == "A" .AND. Len(xParam) > 2

	RpcSetEnv(xParam[1],xParam[2])

	STDUpdateStock()

	RESET ENVIRONMENT

ElseIf !Empty(xParam) .AND. !Empty(cFil)
	aFiliais := STBCreateFilArray(cFil)

	For nX := 1 To Len(aFiliais)
		RpcSetEnv(xParam,aFiliais[nX])

		STDUpdateStock()

		RESET ENVIRONMENT
	Next nX

EndIf

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} STDUpdateStock
Realiza o processamento da atualizacao de estoque.

@param
@author  Varejo
@version P12
@since   11/09/2013
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STDUpdateStock()
Local cQuery
Local cAlias	:= GetNextAlias()
Local cCliente	:= ""
Local cLoja		:= ""

cQuery	:= "SELECT * "
cQuery	+= "FROM " + RetSqlName("SL2") + " SL2 "
cQuery	+= "WHERE L2_FILIAL = '"+xFilial("SL2")+"' AND L2_BLEST = 'ZZ' AND SL2.D_E_L_E_T_ = '' "
cQuery += "ORDER BY L2_NUM"

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T.)

While (cAlias)->(!EOF())

	SL1->(DbSelectArea("SL1"))
	SL1->(DbSetOrder(1))
	If SL1->(DbSeek(xFilial("SL1")+(cAlias)->L2_NUM))
		cCliente 	:= SL1->L1_CLIENTE
		cLoja		:= SL1->L1_LOJA
	EndIf

	SD2->(DbSelectArea("SD2"))
	SD2->(DbSetOrder(3))
	If SD2->(DbSeek(xFilial("SD2")+(cAlias)->L2_DOC+(cAlias)->L2_SERIE+cCliente+cLoja+(cAlias)->L2_PRODUTO+(cAlias)->L2_ITEM))

		B2AtuComD2(GravaCusD2(PegaCMAtu((cAlias)->L2_PRODUTO , (cAlias)->L2_LOCAL , "N") , "N") 	, ;
	   		NIL 							, NIL 						, !Empty((cAlias)->L2_RESERVA)	, 0				 ,;
			"SC0"						, NIL 						, .T.						, (cAlias)->L2_RESERVA,;
			(cAlias)->L2_ITEM	,Space(TamSX3("DC_SEQ")[1]))

		SB2->(MsUnlock())

		SL2->(DbSelectArea("SL2"))
		SL2->(DbSetOrder(1))
		If SL2->(DbSeek((cAlias)->L2_FILIAL+(cAlias)->L2_NUM+(cAlias)->L2_ITEM+(cAlias)->L2_PRODUTO))
			RecLock("SL2",.F.)
			Replace L2_BLEST With "10"
			SL2->(MsUnlock())
		EndIf
	EndIf

	LjGrvSB3()

	(cAlias)->(DbSkip())
End

(cAlias)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STBCreateFilArray
Transforma uma string com as filiais em um array

@param
@author  Varejo
@version P12
@since   11/09/2013
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STBCreateFilArray( cFil )
Local nCount				:= 1
Local cTemp					:= ""
Local aFiliais				:= {}

DEFAULT cFil := ""

While nCount <= Len( cFil )

	cTemp := ""
	While SubStr( cFil, nCount, 1 ) <> "," .AND. nCount <= Len( cFil )
		cTemp += SubStr( cFil, nCount, 1 )
		nCount++
	End

	AADD( aFiliais, cTemp )
	nCount++

End

Return aFiliais