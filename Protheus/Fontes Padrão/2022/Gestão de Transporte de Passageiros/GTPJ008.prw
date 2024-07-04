#Include 'Protheus.ch'

Function GTPJ008(aParam)

local lJob			:= Iif(Select("SX6")==0,.T.,.F.)  //Rotina automatica (schedule)


If lJob // Schedule
	//---Inicio Ambiente
	RPCSetType(3)
	RpcSetEnv(aParam[1],aParam[2])
EndIf   

GTPA008X(lJob)

If ( lJob )
	RpcClearEnv()
EndIf

Return()