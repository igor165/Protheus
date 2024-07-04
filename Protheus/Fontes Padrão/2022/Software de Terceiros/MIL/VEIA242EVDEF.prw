#include 'TOTVS.ch'
#Include "PROTHEUS.CH"
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

CLASS VEIA242EVDEF FROM FWModelEvent

	DATA lDispEMail

	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()

ENDCLASS


METHOD New() CLASS VEIA242EVDEF

RETURN .T.


METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS VEIA242EVDEF

	Local lRet := .t.
	Local oView := FWViewActive()

	If cModelId == "LISTA_PACOTES" 
	
		If cAction == "CANSETVALUE"

			If cId == "VLRTOTAL"

				oSubModel:GoLine(nLine)
				If oSubModel:GetValue("VLRINICIAL") == 0
					lRet := .f. // Não deixar Alterar o Valor TOTAL se não existe Valor Inicial
				EndIf

			EndIf

		EndIf
		
	EndIf

RETURN lRet