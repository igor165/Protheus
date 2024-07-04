#Include "Protheus.ch"
#Include "ParmType.ch"

User Function APRFLG01()
	
	Local aCardData := {}
	
	If ExistBlock("SCACOM52")
		aCardData := ExecBlock("SCACOM52", .F., .F., ParamIXB)
	EndIf
	
Return aCardData