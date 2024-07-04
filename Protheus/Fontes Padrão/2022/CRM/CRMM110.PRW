#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "CRMM110.CH"

//---------------------------------------------------------------
/*/{Protheus.doc} CRMMACTIVITIES

Classe responsável por manipular as atividades do CRM.

@author	Squad CRM/Faturamento
@since		11/06/2018
/*/
//---------------------------------------------------------------
WSRESTFUL CRMMACTIVITIES DESCRIPTION STR0001 // "Atividades para appCRM"

	WSDATA page         AS INTEGER OPTIONAL
	WSDATA pageSize     AS INTEGER OPTIONAL
	WSDATA sourceBranch AS STRING  OPTIONAL
	WSDATA resourceType AS STRING  OPTIONAL
	WSDATA resourceCode AS STRING  OPTIONAL
	WSDATA activityType AS STRING  OPTIONAL
	WSDATA searchKey    AS STRING  OPTIONAL
	WSDATA initDate     AS STRING  OPTIONAL
	WSDATA endDate      AS STRING  OPTIONAL
	WSDATA code	 		AS STRING

	WSMETHOD GET Main DESCRIPTION STR0002;  // "Retorno de atividades"
	WSSYNTAX "/CRMMACTIVITIES/{page, pageSize, sourceBranch, resourceType, resourceCode, activityType, searchKey, initDate, endDate}";
	PATH ""

	WSMETHOD POST     DESCRIPTION STR0003;  // "Criação de atividades"
	WSSYNTAX "/CRMMACTIVITIES";
	PATH ""

	WSMETHOD PUT      DESCRIPTION STR0004;  // "Atualização de atividades"
	WSSYNTAX "/CRMMACTIVITIES/{Code}";
	PATH "{code}"

	WSMETHOD DELETE   DESCRIPTION STR0005;  // "Exclusao de atividades"
	WSSYNTAX "/CRMMACTIVITIES/{Code}";
	PATH "{code}"

END WSRESTFUL


//---------------------------------------------------------------
/*/{Protheus.doc} GET
Método responsável por listar as atividades.

@author		Squad CRM/Faturamento
@since		16/07/2018
/*/
//---------------------------------------------------------------
WSMETHOD GET Main;
WSRECEIVE page, pageSize, sourceBranch, resourceType, resourceCode, activityType, searchKey, initDate, endDate;
WSSERVICE CRMMACTIVITIES

Local nError     := 0
Local cError     := ""
Local oResponse  := nil
Local oItem      := nil
Local oStatement := nil
Local cQuery     := ""
Local cAliasSQL  := ""
Local cCRMFilter := ""
Local nIndexJSon := 0
Local nSkip      := 0
Local aStatment  := {}
Local nSQLParam  := 0

// Variável usada pela função CRMXFilEnt().
Private nModulo    := 73

Self:SetContentType("application/json")

Default Self:page := 1
If Self:page < 0
	Self:page := 1
Endif

Default Self:pageSize := 20
If Self:pageSize < 0 .or. Self:pageSize > 30
	Self:pageSize := 20
Endif

// Monta query.
cQuery := "select distinct AOF.R_E_C_N_O_ AOFRecNo, " + CRLF
cQuery += "AOF.AOF_FILIAL, AOF.AOF_ENTIDA, AOF.AOF_CHAVE, AOF.AOF_DTINIC, AOF.AOF_HRINIC, AOF.AOF_CODIGO "
cQuery += "from " + RetSqlName('AOF') + " AOF " + CRLF

// Filtro de privilégios do usuário.
cCRMFilter := CRMXFilEnt("AOF", .T.)
If !empty(cCRMFilter)
	cQuery += "inner join " + RetSqlName('AO4') + " AO4 on AO4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and AO4.AO4_FILIAL = ? " + CRLF
	cQuery += "and AO4.AO4_ENTIDA = 'AOF' " + CRLF
	cQuery += "and AO4.AO4_CHVREG = AOF.AOF_FILIAL || AOF.AOF_CODIGO " + CRLF
	cQuery += "and " + cCRMFilter + CRLF
	aAdd(aStatment, {|| oStatement:SetString(nSQLParam, xFilial("AO4", Self:sourceBranch))})
Endif

cQuery += "where AOF.D_E_L_E_T_ = ' ' " + CRLF
If empty(Self:sourceBranch)
	cQuery += "and AOF.AOF_FILIAL in (?) " + CRLF
	aAdd(aStatment, {|| oStatement:SetString(nSQLParam, xFilial("AOF"))})
Else
	cQuery += "and AOF.AOF_FILIAL = ? " + CRLF
	aAdd(aStatment, {|| oStatement:SetString(nSQLParam, xFilial("AOF", Self:sourceBranch))})
Endif

If !empty(Self:resourceType)
	cQuery += "and AOF.AOF_ENTIDA = ? " + CRLF
	aAdd(aStatment, {|| oStatement:SetString(nSQLParam, Self:resourceType)})
Endif

If !empty(Self:resourceCode)
	cQuery += "and AOF.AOF_CHAVE  = ? " + CRLF
	aAdd(aStatment, {|| oStatement:SetString(nSQLParam, Self:resourceCode)})
Endif

If !empty(Self:activityType)
	cQuery += "and AOF.AOF_TIPO   = ? " + CRLF
	aAdd(aStatment, {|| oStatement:SetString(nSQLParam, str(Self:activityType))})
Endif

If !empty(Self:searchKey)
	cQuery += "and (upper(AOF.AOF_ASSUNT) like '%' + ? + '%' or upper(AOF.AOF_DESCRI) like '%' + ? + '%')" + CRLF
	aAdd(aStatment, {|| oStatement:SetString(nSQLParam, upper(Self:searchKey))})
	aAdd(aStatment, {|| oStatement:SetString(nSQLParam, upper(Self:searchKey))})
Endif

If !empty(Self:initDate) .and. !empty(Self:endDate)
	cQuery += "and (AOF.AOF_DTINIC >= ? and AOF.AOF_DTINIC <= ?) " + CRLF
	aAdd(aStatment, {|| oStatement:SetString(nSQLParam, Self:initDate)})
	aAdd(aStatment, {|| oStatement:SetString(nSQLParam, Self:endDate)})
Endif

cQuery += "order by AOF.AOF_FILIAL, AOF.AOF_ENTIDA, AOF.AOF_CHAVE, AOF.AOF_DTINIC, AOF.AOF_HRINIC, AOF.AOF_CODIGO "

// Trata SQL para proteger de SQL injection.
oStatement := FWPreparedStatement():New()
oStatement:SetQuery(cQuery)

// Efetua a troca da string pelos parâmetros passados.
For nSQLParam := 1 to len(aStatment)
	Eval(aStatment[nSQLParam])
Next nSQLParam

cQuery := oStatement:GetFixQuery()
oStatement:Destroy()
oStatement := nil

cAliasSQL := MPSysOpenQuery(ChangeQuery(cQuery))

// Calcula quantos registros pular.
If (cAliasSQL)->(!eof())
	nSkip := ((Self:page - 1) * Self:pageSize)
	If nSkip > 0
		(cAliasSQL)->(dbSkip(nSkip))
	Endif
Endif

oResponse := JsonObject():New()
oResponse['items'] := {}
Do While (cAliasSQL)->(!eof() .and. nIndexJSon < Self:pageSize)
	AOF->(dbGoTo((cAliasSQL)->AOFRecNo))

	oItem := JsonObject():New()
	oItem['code']            := RTrim(AOF->AOF_CODIGO)
	oItem['resourceType']    := AOF->AOF_ENTIDA
	oItem['resourceCode']    := RTrim(AOF->AOF_CHAVE)
	If AOF->AOF_ENTIDA == "SA1"
		oItem['resourceName']    := POSICIONE("SA1", 1, xFilial("SA1") + RTrim(AOF->AOF_CHAVE), "A1_NOME")
	ElseIf AOF->AOF_ENTIDA == "SUS"
		oItem['resourceName']    := POSICIONE("SUS", 1, xFilial("SUS") + RTrim(AOF->AOF_CHAVE), "US_NOME")
	ElseIf AOF->AOF_ENTIDA == "AD1"
		oItem['resourceName']    := POSICIONE("AD1", 1, xFilial("AD1") + RTrim(AOF->AOF_CHAVE), "AD1_DESCRI")
	Else
		oItem['resourceName']    := ""
	EndIf
	oItem['activityType']    := AOF->AOF_TIPO
	oItem['subject']         := EncodeUTF8(RTrim(AOF->AOF_ASSUNT))
	oItem['description']     := EncodeUTF8(RTrim(AOF->AOF_DESCRI))
	oItem['user']            := EncodeUTF8(RTrim(AOF->AOF_CODUSR))
	oItem['initDate']        := dtos(AOF->AOF_DTINIC)
	oItem['endDate']         := dtos(AOF->AOF_DTFIM)
	oItem['initTime']        := RTrim(AOF->AOF_HRINIC)
	oItem['endTime']         := RTrim(AOF->AOF_HRFIM)
	oItem['status']          := AOF->AOF_STATUS
	oItem['priority']        := AOF->AOF_PRIORI
	oItem['percentComplete'] := AOF->AOF_PERCEN
	oItem['participants']    := EncodeUTF8(RTrim(AOF->AOF_PARTIC))
	oItem['at']              := EncodeUTF8(RTrim(AOF->AOF_LOCAL))
	If AOF->(FieldPos("AOF_MSFIL") > 0 .and. !empty(AOF_MSFIL))
		oItem['sourceBranch']     := RTrim(AOF->AOF_MSFIL)
		oItem['sourceBranchName'] := EncodeUTF8(FWFilName(cEmpAnt, AOF->AOF_MSFIL))
	Endif
	oItem['bloqued']         := (AOF->AOF_MSBLQL = "1")
	aAdd(oResponse['items'], oItem)

	nIndexJSon ++
	(cAliasSQL)->(dbSkip())
EndDo
oResponse['hasNext'] := (cAliasSQL)->(!eof())
(cAliasSQL)->(dbCloseArea())

If nError = 0
	Self:SetResponse(oResponse:toJson())
Else
	SetRestFault(nError, EncodeUTF8(cError))
Endif

Return (nError = 0)


//---------------------------------------------------------------
/*/{Protheus.doc} POST
Método responsável por incluir atividades.

@author		Squad CRM/Faturamento
@since		17/07/2018
/*/
//---------------------------------------------------------------
WSMETHOD POST WSSERVICE CRMMACTIVITIES

Local nError     := 0
Local cError     := ""
Local aError     := {}
Local oModel     := nil
Local oResponse  := nil
Local cCode      := ""
Local oContent   := nil

Self:SetContentType("application/json")

// Verifica se o body veio no formato JSon.
If lower(Self:GetHeader("Content-Type", .F.)) == "application/json"

	FWJsonDeserialize(Self:GetContent(), @oContent)
	If !AttIsMemberOf(oContent, "resourceType") .or. !AttIsMemberOf(oContent, "resourceCode") .or.;
		!AttIsMemberOf(oContent, "activityType") .or.;
		!AttIsMemberOf(oContent, "subject") .or. !AttIsMemberOf(oContent, "description") .or.;
		!AttIsMemberOf(oContent, "initDate") .or. !AttIsMemberOf(oContent, "endDate")

		nError := 400
		cError := STR0007  // "Parâmetros obrigatórios não informados."
	Else
		oModel := FwLoadModel('CRMA180')
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		If oModel:Activate()
			oModel:SetValue('AOFMASTER', 'AOF_ENTIDA', oContent:resourceType)
			oModel:SetValue('AOFMASTER', 'AOF_CHAVE',  oContent:resourceCode)
			oModel:SetValue('AOFMASTER', 'AOF_TIPO',   oContent:activityType)
			oModel:SetValue('AOFMASTER', 'AOF_ASSUNT', DecodeUTF8(RTrim(oContent:subject)))
			oModel:SetValue('AOFMASTER', 'AOF_DESCRI', DecodeUTF8(RTrim(oContent:description)))
			oModel:SetValue('AOFMASTER', 'AOF_DTINIC', stod(oContent:initDate))
			oModel:SetValue('AOFMASTER', 'AOF_DTFIM',  stod(oContent:endDate))

			If AttIsMemberOf(oContent, "initTime")
				oModel:SetValue('AOFMASTER', 'AOF_HRINIC', oContent:initTime)
			Endif
			If AttIsMemberOf(oContent, "endTime")
				oModel:SetValue('AOFMASTER', 'AOF_HRFIM',  oContent:endTime)
			Endif
			If AttIsMemberOf(oContent, "status")
				oModel:SetValue('AOFMASTER', 'AOF_STATUS', oContent:status)
			Endif
			If AttIsMemberOf(oContent, "priority")
				oModel:SetValue('AOFMASTER', 'AOF_PRIORI', oContent:priority)
			Endif
			If AttIsMemberOf(oContent, "percentComplete")
				oModel:SetValue('AOFMASTER', 'AOF_PERCEN', oContent:percentComplete)
			Endif
			If AttIsMemberOf(oContent, "user")
				oModel:SetValue('AOFMASTER', 'AOF_CODUSR', oContent:user)
			Endif
			If AttIsMemberOf(oContent, "participants")
				oModel:SetValue('AOFMASTER', 'AOF_PARTIC', DecodeUTF8(RTrim(oContent:participants)))
			Endif
			If AttIsMemberOf(oContent, "at")
				oModel:SetValue('AOFMASTER', 'AOF_LOCAL',  DecodeUTF8(RTrim(oContent:at)))
			Endif
			If AttIsMemberOf(oContent, "bloqued")
				oModel:SetValue('AOFMASTER', 'AOF_MSBLQL', If(oContent:bloqued, '1', '2'))
			Endif
			cCode := oModel:GetValue('AOFMASTER', 'AOF_CODIGO')

			If (oModel:VldData() .and. oModel:CommitData())
				oResponse := JsonObject():New()
				oResponse["sucessCode"] := 201
				oResponse["sucessMessage"] := EncodeUTF8(STR0018)  // "Atividade incluída com sucesso."
				oResponse["code"] := cCode
			Else
				nError := 400
				cError := STR0008  // "A integração não foi bem sucedida."
				aError := oModel:GetErrorMessage()
				If !Empty(aError)
					cError += CRLF + STR0009 + Alltrim(aError[5]) + '-' + AllTrim(aError[6])  // "Foi retornado o seguinte problema: "
					If !Empty(Alltrim(aError[7]))
						cError += CRLF + STR0010 + AllTrim(aError[7])  // "Solução: "
					Endif
				Else
					cError += CRLF + STR0011  // "Verifique os dados enviados"
				Endif
			Endif
		Else
			nError := 400
			cError := STR0012  // "Erro ao ativar modelo CRMA180."
		Endif

		oModel:Deactivate()
		oModel:Destroy()
		oModel := nil
	Endif
Else
	nError := 400
	cError := STR0013  // "Body esperado no formato 'application/json'."
Endif

If nError = 0
	Self:SetResponse(oResponse:toJson())
Else
	SetRestFault(nError, EncodeUTF8(cError))
Endif

Return (nError = 0)


//---------------------------------------------------------------
/*/{Protheus.doc} PUT
Método responsável por alterar atividades.

@author		Squad CRM/Faturamento
@since		17/07/2018
/*/
//---------------------------------------------------------------
WSMETHOD PUT WSSERVICE CRMMACTIVITIES

Local nError     := 0
Local cError     := ""
Local aError     := {}
Local oModel     := nil
Local oResponse  := nil
Local cQuery     := ""
Local cAliasSQL  := ""
Local oContent   := nil
Local cCode      := Self:code

Self:SetContentType("application/json")

// Verifica se o body veio no formato JSon.
If lower(Self:GetHeader("Content-Type", .F.)) == "application/json"

	If empty(cCode)
		nError := 400
		cError := STR0007  // "Parâmetros obrigatórios não informados."
	Else
		cQuery := "select AOF.R_E_C_N_O_ AOFRecNo " + CRLF
		cQuery += "from " + RetSqlName('AOF') + " AOF " + CRLF
		cQuery += "where AOF.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "and AOF.AOF_FILIAL = '" + xFilial("AOF") + "' " + CRLF
		cQuery += "and AOF.AOF_CODIGO = ? " + CRLF

		// Trata SQL para proteger de SQL injection.
		oStatement := FWPreparedStatement():New()
		oStatement:SetQuery(cQuery)
		oStatement:SetString(1, cCode)
		cQuery := oStatement:GetFixQuery()
		oStatement:Destroy()
		oStatement := nil

		cAliasSQL := MPSysOpenQuery(cQuery)

		// Posiciona no registro a alterar.
		If (cAliasSQL)->(eof())
			nError := 404
			cError := STR0014  // "Registro não encontrado para alteração."
		Else
			AOF->(dbGoTo((cAliasSQL)->AOFRecNo))
		Endif
		(cAliasSQL)->(dbCloseArea())

		If nError = 0
			oModel := FwLoadModel('CRMA180')
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			If oModel:Activate()
				FWJsonDeserialize(Self:GetContent(), @oContent)
				If AttIsMemberOf(oContent, "subject")
					oModel:SetValue('AOFMASTER', 'AOF_ASSUNT', DecodeUTF8(RTrim(oContent:subject)))
				Endif
				If AttIsMemberOf(oContent, "description")
					oModel:SetValue('AOFMASTER', 'AOF_DESCRI', DecodeUTF8(RTrim(oContent:description)))
				Endif
				If AttIsMemberOf(oContent, "initDate")
					oModel:SetValue('AOFMASTER', 'AOF_DTINIC', stod(oContent:initDate))
				Endif
				If AttIsMemberOf(oContent, "endDate")
					oModel:SetValue('AOFMASTER', 'AOF_DTFIM',  stod(oContent:endDate))
				Endif
				If AttIsMemberOf(oContent, "initTime")
					oModel:SetValue('AOFMASTER', 'AOF_HRINIC', oContent:initTime)
				Endif
				If AttIsMemberOf(oContent, "endTime")
					oModel:SetValue('AOFMASTER', 'AOF_HRFIM',  oContent:endTime)
				Endif
				If AttIsMemberOf(oContent, "status")
					oModel:SetValue('AOFMASTER', 'AOF_STATUS', oContent:status)
				Endif
				If AttIsMemberOf(oContent, "priority")
					oModel:SetValue('AOFMASTER', 'AOF_PRIORI', oContent:priority)
				Endif
				If AttIsMemberOf(oContent, "percentComplete")
					oModel:SetValue('AOFMASTER', 'AOF_PERCEN', oContent:percentComplete)
				Endif
				If AttIsMemberOf(oContent, "user")
					oModel:SetValue('AOFMASTER', 'AOF_CODUSR', oContent:user)
				Endif
				If AttIsMemberOf(oContent, "participants")
					oModel:SetValue('AOFMASTER', 'AOF_PARTIC', DecodeUTF8(RTrim(oContent:participants)))
				Endif
				If AttIsMemberOf(oContent, "at")
					oModel:SetValue('AOFMASTER', 'AOF_LOCAL',  DecodeUTF8(RTrim(oContent:at)))
				Endif
				If AttIsMemberOf(oContent, "bloqued")
					oModel:SetValue('AOFMASTER', 'AOF_MSBLQL', If(oContent:bloqued, '1', '2'))
				Endif
				If (oModel:VldData() .and. oModel:CommitData())
					oResponse := JsonObject():New()
					oResponse["sucessCode"] := 200
					oResponse["sucessMessage"] := EncodeUTF8(STR0017)  // "Atividade alterada com sucesso."
					oResponse["code"] := cCode
				Else
					nError := 400
					cError := STR0008  // "A integração não foi bem sucedida."
					aError := oModel:GetErrorMessage()
					If !Empty(aError)
						cError += CRLF + STR0009 + Alltrim(aError[5]) + '-' + AllTrim(aError[6])  // "Foi retornado o seguinte problema: "
						If !Empty(Alltrim(aError[7]))
							cError += CRLF + STR0010 + AllTrim(aError[7])  // "Solução: "
						Endif
					Else
						cError += CRLF + STR0011  // "Verifique os dados enviados"
					Endif
				Endif
			Else
				nError := 400
				cError := STR0012  // "Erro ao ativar modelo CRMA180."
			Endif

			oModel:Deactivate()
			oModel:Destroy()
			oModel := nil
		Endif
	Endif
Else
	nError := 400
	cError := STR0013  // "Body esperado no formato 'application/json'."
Endif

If nError = 0
	Self:SetResponse(oResponse:toJson())
Else
	SetRestFault(nError, EncodeUTF8(cError))
Endif

Return (nError = 0)


//---------------------------------------------------------------
/*/{Protheus.doc} DELETE
Método responsável por excluir atividades.

@author		Squad CRM/Faturamento
@since		18/07/2018
/*/
//---------------------------------------------------------------
WSMETHOD DELETE WSSERVICE CRMMACTIVITIES

Local nError     := 0
Local cError     := ""
Local aError     := {}
Local oModel     := nil
Local oResponse  := nil
Local cQuery     := ""
Local cAliasSQL  := ""
Local cCode      := Self:code

Self:SetContentType("application/json")

If empty(cCode)
	nError := 400
	cError := STR0007  // "Parâmetros obrigatórios não informados."
Else
	cQuery := "select AOF.R_E_C_N_O_ AOFRecNo " + CRLF
	cQuery += "from " + RetSqlName('AOF') + " AOF " + CRLF
	cQuery += "where AOF.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and AOF.AOF_FILIAL = '" + xFilial("AOF") + "' " + CRLF
	cQuery += "and AOF.AOF_CODIGO = ? " + CRLF

	// Trata SQL para proteger de SQL injection.
	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)
	oStatement:SetString(1, cCode)
	cQuery := oStatement:GetFixQuery()
	oStatement:Destroy()
	oStatement := nil

	cAliasSQL := MPSysOpenQuery(cQuery)

	// Posiciona no registro a excluir.
	If (cAliasSQL)->(eof())
		nError := 404
		cError := STR0015  // "Registro não encontrado para exclusão."
	Else
		AOF->(dbGoTo((cAliasSQL)->AOFRecNo))
	Endif
	(cAliasSQL)->(dbCloseArea())

	If nError = 0
		oModel := FwLoadModel('CRMA180')
		oModel:SetOperation(MODEL_OPERATION_DELETE)
		If oModel:Activate()
			If (oModel:VldData() .and. oModel:CommitData())
				oResponse := JsonObject():New()
				oResponse["sucessCode"] := 200
				oResponse["sucessMessage"] := EncodeUTF8(STR0016)  // "Atividade excluída com sucesso."
				oResponse["code"] := cCode
			Else
				nError := 400
				cError := STR0008  // "A integração não foi bem sucedida."
				aError := oModel:GetErrorMessage()
				If !Empty(aError)
					cError += CRLF + STR0009 + Alltrim(aError[5]) + '-' + AllTrim(aError[6])  // "Foi retornado o seguinte problema: "
					If !Empty(Alltrim(aError[7]))
						cError += CRLF + STR0010 + AllTrim(aError[7])  // "Solução: "
					Endif
				Else
					cError += CRLF + STR0011  // "Verifique os dados enviados"
				Endif
			Endif
		Else
			nError := 400
			cError := STR0012  // "Erro ao ativar modelo CRMA180."
		Endif

		oModel:Deactivate()
		oModel:Destroy()
		oModel := nil
	Endif
Endif

If nError = 0
	Self:SetResponse(oResponse:toJson())
Else
	SetRestFault(nError, EncodeUTF8(cError))
Endif

Return (nError = 0)
