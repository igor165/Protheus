#include 'TOTVS.ch'
#Include "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'VEIA145.CH'

CLASS VEIA145EVF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()

ENDCLASS


METHOD New() CLASS VEIA145EVF

RETURN .T.

METHOD ModelPosVld(oModel, cModelId) CLASS VEIA145EVF

	Local lRet := .t.

	If	Empty(oModel:GetValue("VJUMASTER","VJU_MODEID")) .and.;
		Empty(oModel:GetValue("VJUMASTER","VJU_BASECD"))
		HELP(' ',1,"CPOVAZIO" ,, STR0003 ,2,0,,,,,,) //"Informe o modelo da fábrica ou o base code John Deere"
		lRet := .f.
	EndIf

RETURN lRet