#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} F0100801
Client de Web Service REST agendado para manutenção da tabela de log de traduções (ZA1),
Enviando os registros gerados localmente para o servidor de traduções.Essa funcionalidade deverá ser agendada.

@Project 	Rússia
@author	Lucas Graglia Cardozo
@since		20/07/2017

@return	Nil
/*/
User Function F0100201(aEmp)

	Local aHeaderWS   := {}
	Local cURLServer  := ""
	Local cPostParams := ""
	Local cAlias      := ""
    Local cAuth       := ""
	Local oModel
	Local oServer

	InitProc(aEmp)

    cURLServer := GetNewPar("FS_TSERVER", "http://localhost:8084/rest")
    cAuth      := GetNewPar("FS_TSAUTH", "")
	oModel     := FwLoadModel("FLAVOREDT")
	oServer    := FWRest():New(cURLServer)

	cAlias := GetNextAlias()

	BeginSQL Alias cAlias
        SELECT ZA1.R_E_C_N_O_ ZA1RECNO
          FROM %Table:ZA1% ZA1
         WHERE ZA1.ZA1_STATUS  = '1'
           AND ZA1.ZA1_SENT   != '1'
           AND ZA1.%NotDel%
        ORDER BY ZA1_ORIGIN, ZA1_SEEK
    EndSQL

	aHeaderWS := {"Content-Type: application/json"}

    If !Empty(cAuth)
        AAdd(aHeaderWS, "Authorization: Basic " + Encode64(cAuth))
    EndIf


	While (cAlias)->(!Eof())
		ZA1->(DbGoTo((cAlias)->ZA1RECNO))

		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()

		cPostParams := oModel:GetJsonData()
		oServer:SetPath("/fwmodel/TranslationLog")
		oServer:SetPostParams(cPostParams)

		If oServer:Post(aHeaderWS)
            cJSONResult := oServer:GetResult()
            If!("error" $ cJSONResult)
                oModel:GetModel("ZA1MASTER"):LoadValue("ZA1_SENT"  , "1")
                oModel:GetModel("ZA1MASTER"):LoadValue("ZA1_STATUS", "2")
                FwFormCommit(oModel)

                RecLock("ZA1", .F.)
                ZA1->ZA1_HIST := U_ZA1Hist("Sent to Translation Server")
                ZA1->(MsUnLock())
            EndIf
        Else
            ConOut(oServer:GetLastError())
        EndIf
		oModel:DeActivate()
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
