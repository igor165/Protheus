#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA711
	Job para calculo dos saldos para o Novo Gestor Financeiro

	@param cCompany, character, código do grupo de empresas
	@param cBranch , character, código da filial

	@author renato.ito
	@since 23/02/2021
/*/
//-------------------------------------------------------------------
Function FINA711(cCompany As Character)
	Local cLastDate   as Character
	Local cJobTime    as Character
	Local oDocSer     as Object
	Local lStamp      as Logical
	Local cStartTime  as Character
	Local cStartJob   as Character
	Local cFnc        as Character // macro executar função tlpp pra não gerar erro de compilação no release 17
	Local cLockName   as Character

	cLockName := cEmpAnt + " - FINA711"

	If (AliasInDic('F76') .And. AliasInDic('F75') )
		// Verifica se exite um job em execução
		If LockByName( cLockName, .T./*lEmpresa*/, .F./*lFilial*/ )
			lStamp      := .T.
			cStartJob   := Time()
			cJobTime    := FWTimeStamp(6, DATE(), TIME())

            If FindFunction("gfin.util.GetDBTimeStamp")
                cJobTime := &("gfin.util.GetDBTimeStamp(TcGetDB())")
            Endif

			cJobTime    := StrTran(cJobTime, 'T', ' ')
			cJobTime    := StrTran(cJobTime, 'Z', '')

			cLastDate := GetMV("MV_TFCJOBT",,'')
			ConOut(CRLF + "["+ cLockName + "] Started")
			// inicia o job de titulos
			cStartTime := Time()
			cFnc := 'gfin.job.DocumentsBalance():new()'
			oDocSer := &cFnc
			oDocSer:setLastUpdateDate(cLastDate)
			oDocSer:processDocuments()
			If oDocSer:lOk
				ConOut(CRLF + "["+ cLockName + "] Documents processing time: "+ ElapTime(cStartTime, Time()))
				ConOut("["+ cLockName + "] Documents updated: "+ cValToChar(oDocSer:insertions))
			EndIf
			// inicia o job de pedidos
			cStartTime := Time()
			cFnc := 'gfin.job.OrdersBalance():new()'
			oOrders := &cFnc
			oOrders:setLastDateTime(cLastDate)
			oOrders:setCurrentDateTime(cJobTime)
			oOrders:processOrders()
			If oOrders:isOK()
				ConOut(CRLF + "["+ cLockName + "] Orders processing time: "+ ElapTime(cStartTime, Time()))
				ConOut("["+ cLockName + "] Orders updated: "+ cValToChar(oOrders:getInserts()))
			EndIf

			If oDocSer:lOk .AND. oOrders:isOK()
				PutMv("MV_TFCJOBT", cJobTime)
				ConOut(CRLF + "["+ cLockName + "] finished. Duration: "+ ElapTime(cStartJob, Time()))
			Else
				ConOut(CRLF + "["+ cLockName + "] finished with error"+ ElapTime(cStartJob, Time()))
				If !oDocSer:lOk
					ConOut(CRLF + "["+ cLockName + "][ERROR] " + oDocSer:errorMessage)
				EndIf
				If !oOrders:isOK()
					ConOut(CRLF + "["+ cLockName + "][ERROR] " + oOrders:getErrorMessage())
				EndIf
			EndIf
			UnLockByName(cLockName, .T./*lEmpresa*/, .F./*lFilial*/ )
		Else
			ConOut(CRLF + "["+ cLockName + "] Running on another thread" )
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
	Execucao da rotina via Schedule.
	@return  aParam
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
	Local aParam := {}

	aParam := 	{"P"	,;	//Tipo R para relatorio P para processo
				""		,;	//Nome do grupo de perguntas (SX1)
				Nil		,;	//cAlias (para Relatorio)
				Nil		,;	//aArray (para Relatorio)
				Nil		}	//Titulo (para Relatorio)
Return aParam
