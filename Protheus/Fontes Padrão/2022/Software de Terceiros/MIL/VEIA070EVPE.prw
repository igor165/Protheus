#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} VEIA070EVPE
Eventos especificos para tratar chamadas a pontos de entrada já suportados pelo MVC.

Essa classe existe para manter o legado dos pontos de entrada do VEIXA010 quando não era MVC.
Os pontos de entrada são chamados nos mesmos momentos que é chamado no VEIXA010 sem MVC.

@type classe
 
@author Totvs
@since 08/12/2019
@version P12.1.17
 
/*/

CLASS VEIA070EVPE FROM FWModelEvent
	DATA nOpc
	DATA cIDVV1
	
	DATA lXA010Ok
	DATA lXA010DPGR
	
	METHOD New() CONSTRUCTOR
	METHOD FieldPosVld()
	METHOD InTTS()
	
ENDCLASS

METHOD New(cIDVV1) CLASS VEIA070EVPE
	Default cIDVV1 := "MODEL_VV1"
	
	::cIDVV1 			:= cIDVV1	
	::lXA010Ok   		:= Existblock("VXA010OK")
	::lXA010DPGR  		:= Existblock("VA010DPGR")
Return


METHOD FieldPosVld(oSubModel, cID) CLASS VEIA070EVPE
	Local lRet := .T.
	
	::nOpc := oSubModel:getOperation()
	If cID == ::cIDVV1

		If ::lXA010Ok
			lRet := ExecBlock("VXA010OK",.f.,.f.,{::nOpc})
		EndIf

	EndIf
	
Return lRet


METHOD InTTS(oModel,cID) CLASS VEIA070EVPE

	Local nReg := VV1->(Recno())

	If ::lXA010DPGR
		ExecBlock("VA010DPGR", .f., .f., {VV1->VV1_CHAINT, ::nOpc, nReg})
	EndIf
	
Return