#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

#INCLUDE "VEIC030EVDEF.CH"

/*/{Protheus.doc} VEIC030EVDEF
//TODO Descri��o auto-gerada.

Importante: Use somente a fun��o Help para exibir mensagens ao usuario, pois apenas o help
� tratado pelo MVC. 

@author Rubens
@since 02/12/2018
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
CLASS VEIC030EVDEF FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()
ENDCLASS

METHOD New() CLASS VEIC030EVDEF
	
RETURN

METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cID, xValue, xCurrentValue) CLASS VEIC030EVDEF
	
	Local cNumPedido
	
	Default cID := ""
	Default xValue := ""
	Default xCurrentValue := ""


	If cModelID == "LISTA_CHASSI"

		If cAction == "SETVALUE"
			Do Case
			Case cID == "SELCHASSI"
				nQtdeSel := FWFldGet("PARSELEC")
				If xValue
					cNumPedido := ""
					If VC0300043_ChassiJaSelecionado(oSubModel:GetValue("VV1_CHAINT"),@cNumPedido)
						FMX_HELP("VC030EVDEFERR002",STR0001 + CRLF + CRLF + RetTitle("VRJ_PEDIDO") + ": " + cNumPedido) // "Ve�culo j� selecionado em outro pedido."
						Return .f.
					EndIf
					If nQtdeSel == FWFldGet("PARVENDIDO")
						FMX_HELP("VC030EVDEFERR001", STR0002, STR0003) // "A quantidade de ve�culos vendidos ja foram selecionadas." - "Desmarcar um ve�culo selecionado."
						Return .f.
					EndIf
					FWFldPut("PARSELEC",++nQtdeSel)
				Else
					FWFldPut("PARSELEC",--nQtdeSel)
				EndIf
			EndCase

		EndIf

	EndIf

RETURN .t.
