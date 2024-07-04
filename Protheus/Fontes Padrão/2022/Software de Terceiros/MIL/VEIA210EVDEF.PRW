#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "VEIA210.CH"

CLASS VEIA210EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()

ENDCLASS


METHOD New() CLASS VEIA210EVDEF
RETURN .T.


METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS VEIA210EVDEF
Local lRet    := .t.
Local cQuery  := ""
Local cGruNeg := ""
Local cCodCli := ""
Local cLojCli := ""
Local aVet    := {}
Local aHead   := {}
Local nPosVet := 0
Local nPosCod := 0
Local nPosLoj := 0
if cModelId == "VJXDETAIL"
	Do Case
		Case cAction == "SETVALUE" // Valid do campo
			If cId $ "VJX_CODCLI/VJX_LOJCLI/"
				If cId == "VJX_CODCLI"
					cCodCli := xValue
					cLojCli := oSubModel:GetValue("VJX_LOJCLI")
				Else
					cCodCli := oSubModel:GetValue("VJX_CODCLI")
					cLojCli := xValue
				EndIf
				cQuery := "SELECT VJX_GRUNEG "
				cQuery += "  FROM " + RetSqlName("VJX")
				cQuery += " WHERE VJX_FILIAL ='" + xFilial("VJX") + "'"
				cQuery += "   AND VJX_CODCLI ='" + cCodCli + "'"
				cQuery += "   AND VJX_LOJCLI ='" + cLojCli + "'"
				cQuery += "   AND D_E_L_E_T_=' '"
				cGruNeg := FM_SQL(cQuery)
				If !Empty(cGruNeg) .and. oSubModel:GetValue("VJX_GRUNEG") <> cGruNeg
					lRet := .f.
					Help("",1,"VALIDVJX",,STR0013+" ("+cGruNeg+")",1,0) // Cliente/Loja já existente no Grupo de Negócios.
				EndIf
			EndIf
	EndCase
EndIf

RETURN lRet