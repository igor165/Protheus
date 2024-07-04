#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "VEIA251.CH"

CLASS VEIA251EVDEF FROM FWModelEvent

	DATA lDispEMail

	METHOD New() CONSTRUCTOR
	METHOD Activate()
	METHOD FieldPreVld()
	METHOD ModelPosVld()
	METHOD DeActivate()

ENDCLASS


METHOD New() CLASS VEIA251EVDEF

	::lDispEMail := .f. // Não Disparar E-Mail

RETURN .T.


METHOD Activate(oModel, lCopy) CLASS VEIA251EVDEF
	
	::lDispEMail := .f. // Não Disparar E-Mail

RETURN .T.


METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS VEIA251EVDEF
Local lRet    := .t.
Local cTipo   := ""
Local dData   := ctod("")
Local cQuery  := ""
if cModelId == "VN3MASTER"
	If cId == "VN3_TIPO" .or. cId == "VN3_DATINI"
		If cAction == "SETVALUE" // Valid do campo
			If cId == "VN3_TIPO"
				cTipo := xValue
				dData := oSubModel:GetValue("VN3_DATINI")
			ElseIf cId == "VN3_DATINI"
				cTipo := oSubModel:GetValue("VN3_TIPO")
				dData := xValue
			EndIf
			cQuery := "SELECT R_E_C_N_O_ AS RECVN3 "
			cQuery += "  FROM " + RetSqlName("VN3")+" VN3 "
			cQuery += " WHERE VN3_FILIAL ='" + xFilial("VN3") + "'"
			cQuery += "   AND VN3_CODMAR ='" + oSubModel:GetValue("VN3_CODMAR") + "'"
			cQuery += "   AND VN3_MODVEI ='" + oSubModel:GetValue("VN3_MODVEI") + "'"
			cQuery += "   AND VN3_SEGMOD ='" + oSubModel:GetValue("VN3_SEGMOD") + "'"
			cQuery += "   AND VN3_TIPO   ='" + cTipo + "'"
			cQuery += "   AND VN3_DATINI ='" + dtos(dData) + "'"
			cQuery += "   AND VN3_USRDES = ' ' " // ativo
			cQuery += "   AND D_E_L_E_T_=' '"
			If FM_SQL(cQuery) > 0
				lRet := .f.
				Help("",1,"VALIDVN3",,STR0012,1,0) // Cadastro já existente para a mesma data.
			EndIf
		EndIf
	EndIf
EndIf

RETURN lRet


METHOD ModelPosVld(oModel, cID) CLASS VEIA251EVDEF
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If !IsInCallStack("VEIA252") // Não chamado pela rotina de Replica de % Geral de Markup's e Desconto
			::lDispEMail := .t. // Disparar E-mail
		EndIf
	EndIf
RETURN .T.


METHOD DeActivate(oModel) CLASS VEIA251EVDEF
	If ::lDispEMail
		VA2400171_EnviarEmail(.t.,.f.) // Enviar E-mail referente a alteração na Lista de Preços dos Pacotes
	EndIf
RETURN .T.