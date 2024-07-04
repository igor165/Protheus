#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'
#Include 'GTPC300F.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPC300F()

Rotina de Consulta de Aloca��o de Recurso.
Para GQE_TRECUR == '1' Colaborador (GYG - Colaborador)
Para GQE_TRECUR == '2' Ve�culo (ST9 - Bem)

@author		SIGAGTP | Gabriela Naomi Kamimoto
@since		
@version 	P12.1.16
/*/
//-------------------------------------------------------------------

Function GTPC300F()

Local oViewMonitor	:= GC300GetMVC('V')
Local cTpRecur		:= ""	
Local cCodBem		:= ""
Local cCodRec		:= ""
Local lTerceiro		:= .F.

	
	If ValType(oViewMonitor) == 'O' .AND. oViewMonitor:IsActive()
		
		cTpRecur := oViewMonitor:GetModel("GQEDETAIL"):GetValue("GQE_TRECUR")
		cCodBem  := oViewMonitor:GetModel("GQEDETAIL"):GetValue("GQE_RECURS")
		cCodRec  := oViewMonitor:GetModel("GQEDETAIL"):GetValue("GQE_RECURS")
		lTerceiro:= (oViewMonitor:GetModel("GQEDETAIL"):GetValue("GQE_TERC")=='1')
		
		If lTerceiro
			G6Z->(DbSetOrder(1))
			G6Z->(DbSeek(xFilial("G6Z")+cCodBem))
			FWExecView( STR0005, 'VIEWDEF.GTPC300N', MODEL_OPERATION_VIEW, , { || .T. },,,,,,, ) //'Recurso Terceiro'
		Else
			If cTpRecur ==  '2' //Ve�culo
				ST9->(DbSetOrder(1))
				ST9->(DbSeek(xFilial("ST9")+cCodBem))
				FWExecView( STR0004, 'VIEWDEF.MNTA084', MODEL_OPERATION_VIEW, , { || .T. },,,,,,, ) //'Ve�culo'
			ElseIf cTpRecur == '1' //Colaborador
				GYG->(DbSetOrder(1))
				GYG->(DbSeek(xFilial("GYG")+cCodRec))
				FWExecView( STR0003, 'VIEWDEF.GTPA008', MODEL_OPERATION_VIEW, , { || .T. },,,,,,, ) //'Colaborador'
			EndIf
		EndIf
	Else
		FwAlertHelp(STR0001,STR0002) //"Esta rotina s� funciona com monitor ativo"
	EndIf
	
Return


