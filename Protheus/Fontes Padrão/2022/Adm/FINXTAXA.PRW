#INCLUDE "Totvs.CH"
#INCLUDE 'RestFul.CH'
#INCLUDE 'FWMVCDEF.CH'

Static __oMdlSM2 As Object 

/*/{Protheus.doc} FINXTAXA
	Rotina que realiza a atualização do cadastro de Indicadores e Moedas com base em séries do Banco Central.
	Cliente deve localizar a serie que deseja na URL abaixo
	https://www3.bcb.gov.br/sgspub/localizarseries/localizarSeries.do?method=prepararTelaLocalizarSeries
	@type function
	@author Rogerio Nagy
	@since 12/04/2022
/*/
Function FINXTAXA()
	Local aIndices   as ARRAY
	Local cUrl       as Character
	Local aHeaders   as Array
	Local cPath      as Character
	Local cFaixa     as Character
	Local nIndice    as Numeric
	Local cResultado as Character
	Local lOk        as Logical
	Local jResultado as Json
	Local oRest      as Object
	Local nBegin     as Numeric
	Local nDias      as Numeric
	Local lAtualiza  as Logical
	Local lNextDSM2  as Logical
	Local lNextDFIU  as Logical

	aIndices   := {}
	cUrl       := ""
	aHeaders   := {}
	cPath      := ""
	cFaixa     := ""
	nIndice    := 1
	cResultado := ""
	lOk        := .T.
	nBegin     := 0
	nDias      := 45
	lAtualiza  := .F.
	lNextDSM2  := .F.
	lNextDFIU  := .F.

	If FIT->(FieldPos('FIT_BACEN')) > 0 .And. GetRpoRelease() >= "12.1.033"

		FWLsPutAsyncInfo("LS006", RetCodUsr(), '06', "FIN_API_BACEN")

		If MV_PAR01 ==  1
			lAtualiza :=  .T.
		EndIf
		If MV_PAR02 > 0
			nDias  :=  MV_PAR02
		EndIf
		If !Empty(MV_PAR03) .And. MV_PAR03 == 2		// soma 1 dia para moeda
			lNextDSM2 :=  .T.
		EndIf
		If !Empty(MV_PAR04) .And. MV_PAR04 == 2		// soma 1 dia para índices
			lNextDFIU :=  .T.
		EndIf
		nBegin    := SECONDS()
		__oMdlSM2 := FWLoadModel("MATA090")
		getFITBC(@aIndices)
		getSM2BC(@aIndices)

		// Formato da URL do Bacen
		// https://api.bcb.gov.br/dados/serie/bcdata.sgs.12/dados?formato=json&dataInicial=10/03/2022&dataFinal=11/03/2022
		cUrl     := 'https://api.bcb.gov.br/'
		// filtro de período
		cFaixa   := 'dataInicial=' + dtoc(dDataBase - nDias) + '&dataFinal=' + dtoc(dDatabase)
		aHeaders := {"User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")"}
		oRest    := FwRest():New(cUrl)
		jResultado := JsonObject():New()
		// Laço por índice
		For nIndice := 1 to Len(aIndices)
			cPath       := 'dados/serie/bcdata.sgs.' + aIndices[nIndice, 1] + '/dados'
			oRest:setPath(cPath)

			lOk := oRest:Get(aHeaders, cFaixa)
			checkLogMsg("ERROR", '02', oRest:GetLastError())

			// Se não existir erro atualizar as taxas
			If lOk
				jResultado := JsonObject():New()
				cResultado := oRest:GetResult()
				If !checkLogMsg('ERROR', '03', jResultado:fromJson(cResultado))
					If aIndices[nIndice, 3]  // Indice
						updFIU(aIndices[nIndice, 2], jResultado, lNextDFIU)
					Else
						updSM2(aIndices[nIndice, 2], jResultado, lAtualiza, lNextDSM2)
					EndIf
				EndIf
			EndIf
		Next nIndice

		__oMdlSM2:destroy()
		FreeObj(oRest)
		FreeObj(jResultado)
		FwFreeArray(aIndices)
		checkLogMsg("INFO", '01', "Job FINXTAXA finished", nBegin)
	EndIf
Return

/*/{Protheus.doc} getFITBC
	Retorna os índices configurados com código do bacen
	@type function
	@author renato.ito
	@since 05/04/2022
	@param aIndices, array, {Codigoo Bacen, Codigo Interno Protheus, .T. = indice / .F. = Moeda}
/*/
Function getFITBC(aIndices as Array)
	Local cQuery as Character
	Local cAlias as Character

	cQuery := ""
	cAlias := ""

	cQuery  := "SELECT FIT_FILIAL, FIT_CODIND, FIT_BACEN "
	cQuery  += " FROM "+RetSqlName("FIT")+" FIT "
	cQuery  += " WHERE FIT.D_E_L_E_T_ = ' ' "
	cQuery  += " AND FIT.FIT_BACEN <> ' ' "
	cQuery  += " AND FIT.FIT_FILIAL = ? "
	cQuery  += " ORDER BY FIT.FIT_CODIND,FIT.FIT_FILIAL "
	cQuery  := ChangeQuery(cQuery)

	cAlias  := MPSYSOpenQuery(cQuery, , , , {FWxFilial("FIT")})
	While (cAlias)->(!Eof())
		Aadd(aIndices, {AllTrim((cAlias)->FIT_BACEN), (cAlias)->FIT_CODIND, .T.})
		(cAlias)->(DbSkip())
	Enddo

	(cAlias)->(dbCloseArea())
Return

/*/{Protheus.doc} getFItBC
	Retorna as moedas configuradas com código do bacen
	@type function
	@author renato.ito
	@since 05/04/2022
	@param aIndices, array, {Codigoo Bacen, Codigo Interno Protheus, .T. = indice / .F. = Moeda}
/*/
Function getSM2BC(aIndices)
	Local nMoeda   as Numeric
	Local cMoeda   as Character
	Local cMVMOEBC as Character

	nMoeda   := 0
	cMoeda   := ""
	cMVMOEBC := ""

	For nMoeda := 2 To MoedFin()
		cMoeda   := Str(nMoeda, IIf(nMoeda <= 9, 1, 2))
		cMVMOEBC := SuperGetMV("MV_MOEBC" + cMoeda, , "")
		If !EMPTY(cMVMOEBC)
			AADD(aIndices, {cMVMOEBC, cMoeda, .F.})
		EndIf
	Next nMoeda
Return

/*/{Protheus.doc} updFIU
	Atualiza as taxa na tabela FIU
	@type function
	@version
	@author renato.ito
	@since 06/04/2022
	@param cIndice, character, código da FIU
	@param jSerie, json, {Array<{data: string, valor: string}>}
	@param lNextDay, logical, soma 1 dia na data do bacen
/*/
Function updFIU(cIndice as Character, jSerie as Json, lNextDay as Logical)
	Local nResp    as Numeric
	Local cFilFIU  as Character
	Local dDataFIU as Date

	nResp   := 0
	cFilFIU := FWxFilial("FIU")

	BEGIN TRANSACTION
		For nResp := 1 To Len(jSerie)
			If jSerie[nResp]:hasProperty('data') .And. jSerie[nResp]:hasProperty('valor')
				If lNextDay
					FDiaNUtil("FIU", cIndice, Val(jSerie[nResp]['valor']), CTOD(jSerie[nResp]['data']))
				Else
					dDataFIU := CTOD(jSerie[nResp]['data'])
					FGrvFIU(dDataFIU, cFilFIU, cIndice, Val(jSerie[nResp]['valor']))
				EndIf	
			EndIf
		Next nResp
	END TRANSACTION

Return

/*/{Protheus.doc} updSM2
	Atualiza as taxa na tabela SM2
	@type function
	@version
	@author renato.ito
	@since 06/04/2022
	@param cMoeda, character, número da moeda
	@param jSerie, json, {Array<{data: string, valor: string}>}
	@param lAtualiza, logical, .T. = atualiza a taxa se existir
	@param lNextDay, logical, soma 1 dia na data do bacen
/*/
Function updSM2(cMoeda as Character, jSerie as Json, lAtualiza as Logical, lNextDay as Logical)
	Local nResp    as Numeric
	Local cFilSM2  as Character
	Local lInclui  as Logical
	Local nTaxa    as Numeric
	Local dDataSM2 as Date
	Local nSm2Vl   as Numeric

	nResp   := 0
	cFilSM2 := ""
	lInclui := .T.
	nTaxa   := 0
	nSm2Vl  := 0

	Default lAtualiza := .F.

	cFilSM2 := FWxFilial("SM2")

	DbSelectArea("SM2")
	SM2->(DBSetOrder(1))

	BEGIN TRANSACTION
		For nResp := 1 To Len(jSerie)
			If jSerie[nresp]:hasProperty('data') .And. jSerie[nresp]:hasProperty('valor')
				If lNextDay
					FDiaNUtil("SM2", cMoeda, Val(jSerie[nResp]['valor']), CTOD(jSerie[nResp]['data']))
				Else
					dDataSM2 := CTOD(jSerie[nResp]['data'])
					FGrvSM2(dDataSM2, cMoeda, Val(jSerie[nResp][ 'valor' ]))
				Endif
			EndIf
		Next nResp
	END TRANSACTION	

Return

/*/{Protheus.doc} FDiaNUtil
	Gravação das informações nas tabelas SM2 e FIU em dia não util
	@type  Static Function
	@author Vitor Duca
	@since 08/07/2022
	@version 1.0
	@param cTable, Character, Tabela que sera considerada (FIU ou SM2)
	@param cIndice, Character, Codigo do indice do BACEN ou moeda quando for SM2
	@param nValor, Numeric, Valor do indice retornado pelo BACEN
	@param dDataIni, Date, Data inicial 
/*/
Static Function FDiaNUtil(cTable As Character, cIndice As Character, nValor As Numeric, dDataIni As Date)
	Local dDataProx As Date
	Local dDataVld As Date
	Local dDataGrv As Date
	Local nDias As Numeric
	Local nX As Numeric
	Local cFilFIU as Character

	nDias := 1
	dDataProx := DaySum(dDataIni, 1)
	dDataVld := DataValida(dDataProx, .T.)
	cFilFIU := FWxFilial("FIU")

	If dDataVld <> dDataProx
		nDias := DateDiffDay(dDataIni,dDataVld)
	Endif

	dDataGrv := dDataProx

	For nX := 1 to nDias

		if nX > 1
			dDataGrv := DaySum(dDataGrv, 1)
		Endif	

		If cTable == "FIU"
			FGrvFIU(dDataGrv, cFilFIU, cIndice, nValor)
		Else
			FGrvSM2(dDataGrv, cIndice, nValor)
		Endif
	Next nX
	
Return 

/*/{Protheus.doc} FGrvSM2
	Gravação das taxas no cadastro de moedas SM2
	@type  Static Function
	@author Vitor Duca
	@since 11/07/2022
	@version version
	@param dDataGrv, Date, Data que sera gravada 
	@param cMoeda, Character, Moeda que deve ser alterada na SM2 
	@param nValor, Numeric, Valor retornado pelo BACEN
/*/
Static Function FGrvSM2(dDataGrv As Date, cMoeda As Character, nValor As Numeric)
	Local nOperation As Numeric
	Local nSm2Vl As Numeric

	nOperation := MODEL_OPERATION_INSERT
	nSm2Vl := 0

	If SM2->(DBSeek(DTOS(dDataGrv)))
		nSm2Vl   := SM2->&("M2_MOEDA" + cMoeda)
		If nSm2Vl == 0 .or. (MV_PAR01 ==  1 .and. nSm2Vl <> nValor) 
			nOperation := MODEL_OPERATION_UPDATE
		Endif	
	Endif

	__oMdlSM2:SetOperation(nOperation)
	__oMdlSM2:Activate()

	iF nOperation == MODEL_OPERATION_INSERT
		__oMdlSM2:SetValue("SM2MASTER", "M2_DATA", dDataGrv)
	Endif	

	__oMdlSM2:SetValue("SM2MASTER", "M2_MOEDA" + cMoeda, nValor)
	__oMdlSM2:VldData()
	__oMdlSM2:CommitData()
	__oMdlSM2:DeActivate()

Return 

/*/{Protheus.doc} FGrvFIU
	Gravação das movimentações dos indices FIU
	@type  Static Function
	@author Vitor Duca
	@since 11/07/2022
	@version 1.0
	@param dDataGrv, Date, Data que sera gravada 
	@param cFilFIU, Character, Filial para gravação da FIU
	@param cIndice, Character, Indice que sera alterado 
	@param nValor, Numeric, Valor retornado pelo BACEN
/*/
Static Function FGrvFIU(dDataGrv As Date, cFilFIU As Character, cIndice As Character, nValor As Numeric)

	If !FIU->(DbSeek(cFilFIU + cIndice + DTOS(dDataGrv)))
		Reclock("FIU", .T.)
		FIU_FILIAL := cFilFIU
		FIU_CODIND := cIndice
		FIU_DATA   := dDataGrv
		FIU_INDICE := nValor
		FIU_BLOQ   := '2'
		MsUnlock()
	Endif

Return 
/*/{Protheus.doc} checkLogMsg
	registra mensagem de log
	gera log de erro no console
	@type  Static Function
	@author renato.ito
	@since 08/04/2022
	@param cError, character, mensagem de erro
/*/
Static Function checkLogMsg(cMsgType as Character, cMsgId as Character, cMsgLog as Character, nSeconds as Numeric)
	Local lLogOk  as Logical
	Default cMsgLog  := ""
	Default nSeconds := 0
	lLogOk := .F.

	If !Empty(cMsgLog)
		lLogOk := .T.
		FwLogMsg(cMsgType,, "FINXTAXA", "FINXTAXA", "", cMsgId, cMsgLog , 0, IIF(nSeconds > 0, SECONDS() - nSeconds, 0))
	EndIf
Return lLogOk

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
	Execucao da rotina via Schedule.
	@return  aParam
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
	Local aParam := {}

	aParam := {"P",;           //Tipo R para relatorio P para processo
				"FINXTAXA",;   //Nome do grupo de perguntas (SX1)
				Nil,;          //cAlias (para Relatorio)
				Nil,;          //aArray (para Relatorio)
				Nil}           //Titulo (para Relatorio)
Return aParam
