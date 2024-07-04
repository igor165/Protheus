#Include "Protheus.ch"
#Include "ParmType.ch"

User Function APRFLG02()
	
	Local aCardData := {}
	
	If ExistBlock("SCACOM53")
		aCardData := ExecBlock("SCACOM53", .F., .F., ParamIXB)
	EndIf
	
Return aCardData