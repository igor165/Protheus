#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} F0100801
Client de Web Service REST agendado para verificar se existem traduções realizadas no servidor de traduções.
Caso existam os registros locais de log de tradução são atualizados, juntamente com o Flavour.
@Project 	Rússia
@author	Lucas Graglia Cardozo
@since		20/07/2017
@return	Nil
/*/
User Function F0100801(aEmp)
	
	Local cURLServer := ""
	Local cPK		 := ""
	Local cStatus	 := ""	
    Local cAuth      := ""
	Local aHeaderWS	 := {}
	Local oModel	 := Nil
	Local oServer	 := Nil
	Local oObjJson	 := Nil
	
	InitProc(aEmp)
	
    cURLServer := GetNewPar("FS_TSERVER", "http://localhost:8084/rest")
	cAuth      := GetNewPar("FS_TSAUTH", "")
    oModel     := FwLoadModel("FLAVOREDT")
	oServer    := FWRest():New(cURLServer)

	cAlias := GetNextAlias()

	BeginSQL Alias cAlias
        SELECT ZA1.ZA1_FILIAL,
               ZA1.ZA1_IDIOM ,
               ZA1.ZA1_ORIGIN,
               ZA1.ZA1_KEY   ,
               ZA1.ZA1_THREAD,
               ZA1.R_E_C_N_O_ ZA1RECNO
          FROM %Table:ZA1% ZA1
         WHERE ZA1_STATUS   = '2'
           AND ZA1.ZA1_SENT = '1'
           AND ZA1.%NotDel%
    EndSQL

	aHeaderWS := {"Content-Type: application/json"}	

    If !Empty(cAuth)
        AAdd(aHeaderWS, "Authorization: Basic " + Encode64(cAuth))
    EndIf
	
	While (cAlias)->(!Eof())		
		// POR ALGUM MOTIVO O WS SÓ LOCALIZA SE PASSARMOS A FILIAL COM 4 POSIÇÕES
		cPK := Encode64(PadR((cAlias)->ZA1_FILIAL, 4) + (cAlias)->ZA1_IDIOM + (cAlias)->ZA1_ORIGIN + (cAlias)->ZA1_KEY )
		oServer:SetPath("/fwmodel/TranslationLog/" + cPK)
		
		If !oServer:Get(aHeaderWS)
			conOut(oServer:GetLastError())
            Loop
		Endif
		
		If !FWJsonDeserialize(oServer:cResult, @oObjJson)
			ConOut("Ocorreu erro no processamento do Json")
			Return
		EndIf
		
		cStatus := oObjJson:Models[1]:Fields[1]:Value
		
		If 	cStatus == '4'
			ZA1->(DbGoTo((cAlias)->ZA1RECNO))
			oModel:SetOperation(4)
			oModel:Activate()
			oModel:LoadJsonData(oServer:cResult) 
			oModel:GetModel("ZA1MASTER"):SetValue("ZA1_STATUS", '4') 
			FwFormCommit(oModel)
			oModel:DeActivate()
            
            RecLock("ZA1", .F.)
            ZA1->ZA1_HIST   := u_ZA1Hist("Translation Received from the Translation Server.")
            ZA1->(MsUnlock())
		EndIf
		
		(cAlias)->(DbSkip())		
	EndDo
	
	(cAlias)->(DbCloseArea())
	
    ClearProc()
	
Return

Static Function InitProc(aEmp)

    Default aEmp := {"99", "01"}

    Static lInitialize := .F.

    If Select("SX2") == 0
        lInitialize := .T.
        RPCSetEnv(aEmp[1], aEmp[2])
    EndIf

Return

Static Function ClearProc()

    If lInitialize 
	    RpcClearEnv()
        lInitialize := Nil
    EndIf

Return
// Russia_R5
