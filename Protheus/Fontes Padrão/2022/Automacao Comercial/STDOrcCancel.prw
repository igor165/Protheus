#Include 'Protheus.ch'

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/* {Protheus.doc} STDGrvCancel
Funcao que permite o cancelamento das operacoes realizadas pelo GrvBatch.

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	09/04/2013
@return  	
@obs     	
@sample
*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

Function STDGrvCancel( aRegs )
Local aArea 		:= GetArea()
Local cMarca 		:= oMark:Mark()
Local nX 			:= 0
Local lExcOk		:= .F.
Local nSL1Recno		:= 0
Local nPos			:= 0

Private lMsErroAuto := .F.  

DEFAULT aRegs := {}

DbSelectArea("SL1")
DbSetOrder(1)

Begin Transaction
	For nX := 1 To Len(aRegs)
		If SL1->(DbSeek(aRegs[nX]))
			If oMark:IsMark(cMarca)
				nSL1Recno := SL1->(RECNO())
				
				MsExecAuto({|a,b,c,d,e,f,g| lExcOk := LJ140EXC(a,b,c,d,e,f,g)}, "SL1", /*nReg*/, 5, /*aReserv*/, .T., SL1->L1_FILIAL, SL1->L1_NUM )
				
				If ValType(lExcOk) == "U"
		       		lExcOK := .F.
		      	ElseIf ValType(lExcOk) == "N"
					lExcOK := IIF(lExcOk == 1, .T., .F.)
				ElseIf ValType(lExcOk) == "L"
					lExcOK := lExcOk
				EndIf 
				
				If !lExcOK
					ConOut("Erro na exclusao do registro: "+SL1->L1_FILIAL+SL1->L1_NUM)
				Else
					ConOut("Registro "+SL1->L1_FILIAL+SL1->L1_NUM+" excluido com sucesso.")
					
					// Posiciono no recno do registro selecionado, apenas por garantia.
					DbGoTo(nSL1Recno)
					Reclock("SL1",.F.)
					REPLACE SL1->L1_UNDOBTC	WITH "  "
					REPLACE SL1->L1_SITUA 	WITH "RX"
					REPLACE SL1->L1_STBATCH 	WITH "1"
					SL1->(MsUnlock())
				EndIf 
			EndIf
		EndIf
	Next nX
End Transaction

aRegs := {}

RestArea( aArea )

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/* {Protheus.doc} STDMarkAllRegistries
Funcao que, ao selecionar um orcamento, o adiciona em aRegs para ser estornado posteriormente.

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	09/04/2013
@return  	
@obs     	
@sample
*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STDOCMarkAllRegistries(oMark)
Local cMarca 	:= oMark:Mark()
Local aArea	:= GetArea()

oMark:AllMark()

DbSelectArea("SL1")
SL1->(DbSetOrder(4))
SL1->(DbGoTop())

While SL1->(!EOF())
	If oMark:IsMark(cMarca)
		Aadd(aRegs,SL1->L1_FILIAL+SL1->L1_NUM)
	EndIf
	SL1->(DbSkip())
End

RestArea(aArea)

Return