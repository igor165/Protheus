#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

//-----------------------------------------------------------------
/*/{Protheus.doc} PLJBINTAUT
 Funcao da chamada do job
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Function PLJBINTAUT(cGuia)
	Default cGuia := ''
	startJob("PLINGINTER", getEnvServer(), .f., cEmpAnt, cFilAnt, cGuia)
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} PLINGINTER
 Classe para enviar atualizacoes da Internacao para o HAT
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Function PLINGINTER(cEmp,cFil,cGuia)

	Default cGuia := ''

    RpcSetType(3)
	RpcSetEnv(cEmp, cFil,,,'PLS',,)

    oIntern := PLINGINTER():New()
    oIntern:procComun(cGuia)

Return 


//-----------------------------------------------------------------
/*/{Protheus.doc} PLINGINTER
 Classe para enviar atualizacoes da Internacao para o HAT
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Class PLINGINTER

    Data cAliasTemp as String
    Data oObjGuias as Object
    Data lSuccess as Boolean
	Data oRest as Object
	Data oResponse as Object
    Data lAuto as Boolean

    Method new()
    Method procComun(cGuia)
	Method setAuto(lAuto)
	Method setAutoSuc(lSuccess)
	Method setJsonRes(cJson)
    Method getDadGuia(nI)
    Method getQuery(cGuia)
	Method getRestCfg()
	Method setCritica(cMsg)
	Method impLog(cMsg)
	Method post()
	Method updRespGui() 
	Method updBE4(cNumGuia,cStatus)
	Method dateMask(cDate)
	Method hourMask(cHour)

EndClass


Method new() Class PLINGINTER

    self:cAliasTemp := ""
    self:oObjGuias	:= JsonObject():New()
	self:oResponse  := JsonObject():New()
	self:oRest      := PlsRest():New()
	self:lSuccess   := .T.
	self:lAuto      := .F.
	self:oObjGuias['authorizations'] := {}   
	self:getRestCfg()
	
Return


Method setAuto(lAuto) Class PLINGINTER
	self:lAuto := lAuto
	self:oRest:setAuto(lAuto)
Return

Method setAutoSuc(lSuccess) Class PLINGINTER
    self:oRest:setAutoSuc(lSuccess)
Return

Method setJsonRes(cJson) Class PLINGINTER
	self:oRest:setJsonRes(cJson)
Return


Method procComun(cGuia) Class PLINGINTER

    Local nGuia   := 1
	Local cImpLog := iif(!empty(cGuia),"Iniciando processo de atualizacao via funcao, Guia: " + cGuia,'Iniciando processo de atualizacao via schedule')
	Default cGuia := ''

	self:impLog(Replicate('-',70))
	self:impLog(cImpLog)
	self:impLog(Replicate('-',70))

	if self:lSuccess

		self:cAliasTemp := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,self:getQuery(cGuia)),self:cAliasTemp,.F.,.T.)

		if !(self:cAliasTemp)->(Eof())
			while !(self:cAliasTemp)->(Eof())
				self:getDadGuia(nGuia)
				nGuia ++
				(self:cAliasTemp)->(dbSkip())
			endDo
		else
			self:setCritica('Nao foram encontrados registros BE4 atualizados para realizar a comunicacao')
		endIf
		(self:cAliasTemp)->(dbCloseArea())

		self:post()
		self:updRespGui()
		
	endIf
	self:impLog('Finalizando job de atualizacao de guias de internacao')

Return


Method getDadGuia(nI) Class PLINGINTER

    aAdd(self:oObjGuias['authorizations'], JsonObject():New())

    self:oObjGuias['authorizations',nI,'authorizationNumber'] := Alltrim( (self:cAliasTemp)->GUIA )
    self:oObjGuias['authorizations',nI,'authorizationDate']   := self:dateMask( (self:cAliasTemp)->BE4_DATPRO )
	self:oObjGuias['authorizations',nI,'password'] 			  := Alltrim( (self:cAliasTemp)->BE4_SENHA )
	self:oObjGuias['authorizations',nI,'passwordExpireDate']  := self:dateMask( (self:cAliasTemp)->BE4_DATVAL )
	self:oObjGuias['authorizations',nI,'dischargedDate']      := self:dateMask( (self:cAliasTemp)->BE4_DTALTA )
	self:oObjGuias['authorizations',nI,'dischargedHour']      := self:hourMask( (self:cAliasTemp)->BE4_HRALTA )
	self:oObjGuias['authorizations',nI,'dischargedType']      := Alltrim( (self:cAliasTemp)->BE4_TIPALT )

	self:impLog("Guia pendente comunicacao: "+(self:cAliasTemp)->GUIA)

Return


Method getQuery(cGuia) Class PLINGINTER

    Local cSql    := ''
	Default cGuia := ''
	
    cSql += " SELECT BE4_CODOPE || BE4_ANOINT || BE4_MESINT || BE4_NUMINT AS GUIA, "
    cSql += " BE4_DATPRO, BE4_SENHA, BE4_DTALTA, BE4_HRALTA, BE4_TIPALT, BE4_DATVAL "
	cSql += "	FROM " + RetSqlName("BE4")
	cSql += "	WHERE BE4_FILIAL = '" + xFilial("BE4") + "' "
    if !empty(cGuia)
		cSql += "	AND BE4_CODOPE = '" + Substr(cGuia,1,4) + "' "
		cSql += "	AND BE4_ANOINT = '" + Substr(cGuia,5,4) + "' "
		cSql += "	AND BE4_MESINT = '" + Substr(cGuia,9,2) + "' "
		cSql += "	AND BE4_NUMINT = '" + Substr(cGuia,11,8) + "' "
	else
		cSql += "	AND BE4_CODOPE = '"+PlsIntPad()+"' "
	endIf
	cSql += "	AND BE4_COMAUT = '0' " //não comunicada com o novo autorizador
	cSql += "	AND BE4_ORIMOV = '6' " //envia somente guias do HAT
	cSql += "	AND BE4_TIPGUI = '03' " //envia somente guias do HAT
	cSql += " 	AND D_E_L_E_T_ = ' ' "

    cSql := ChangeQuery(cSql)

Return cSql


Method getRestCfg() Class PLINGINTER

	Local cUrl := GetNewPar("MV_PHATURL","")
	Local nX   := 0
	Local aDadHeader := PLGDadHead()

    self:oRest:setGeraLog(.T.)
    self:oRest:setNameLog("upd_intern_novo_autorizador.log")

	if Alltrim(cUrl) == ""
		self:setCritica('URL do HAT nao informada no parametro MV_PHATURL')
	endIf

	if self:lSuccess

		if Substr(cUrl,len(cUrl),1) <> "/"
			cUrl += "/"
		endIf
		cUrl += 'v1/hospitalizationData'

		self:oRest:setEndPoin(cUrl)
		for nX := 1 to len(aDadHeader)
			self:oRest:setHeadPar(aDadHeader[nX,1],aDadHeader[nX,2])
		next

	endIf

Return


Method setCritica(cMsg) Class PLINGINTER

	Default cMsg := ''

	self:lSuccess := .F.
	self:impLog(cMsg)

Return


Method impLog(cMsg) Class PLINGINTER
	
	Default cMsg := ''

	if !Empty(cMsg)
		self:oRest:impLog(cMsg)
	endIf

Return


Method post() Class PLINGINTER

	Local cJson := ""

	if self:lSuccess
		cJson := FWJsonSerialize(self:oObjGuias, .F., .F.)
		self:oRest:setJson(cJson)
		self:oRest:comunPost()
		if self:oRest:getSuccess()
			self:oResponse:fromJSON(self:oRest:getResJson())
		else
			self:setCritica()
		endIf
	endIf

Return


Method updRespGui() Class PLINGINTER

	Local nI := 0
	Local nTamSucesso  := 0
	Local nTamInvalido := 0
	Local cNumGuia     := ""
	Local cErroGuia    := ""
	Local aArea	       := GetArea()
		
	if self:lSuccess .And. Valtype(self:oResponse['authorizations']) != "U"

		self:impLog('Iniciando Atualizacao das Guias:')
		BE4->(DbSetOrder(2)) //BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT

		if valtype(self:oResponse['authorizations','successAuthorizations']) != "U"
			nTamSucesso := Len(self:oResponse['authorizations','successAuthorizations'])
			for nI := 1 to nTamSucesso
				cNumGuia := self:oResponse['authorizations','successAuthorizations',nI,'authorizationNumber']
				if self:updBE4(cNumGuia,'1')
					self:impLog(cNumGuia - "Comunicacao realizada com sucesso")
				endIf
			next nI

		endIf

		if valtype(self:oResponse['authorizations','invalidAuthorizations']) != "U"

			nTamInvalido := Len(self:oResponse['authorizations','invalidAuthorizations'])
			for nI := 1 to nTamInvalido
				cNumGuia  := self:oResponse['authorizations','invalidAuthorizations',nI,'authorizationNumber']
				cCode     := self:oResponse['authorizations','invalidAuthorizations',nI,'code']
				cErroGuia := self:oResponse['authorizations','invalidAuthorizations',nI,'msgError']
				if self:updBE4(cNumGuia,'1')
					self:impLog(cNumGuia + " - "+ cCode + " - " + cErroGuia)
				endIf
			next nI
		endIf

	endIf

	RestArea(aArea)

Return


Method updBE4(cNumGuia,cStatus) Class PLINGINTER

	Local lRet := .T.

	if !Empty(cStatus)
		if BE4->(DbSeek(xFilial("BE4")+cNumGuia))
			BE4->(RecLock("BE4",.F.))
			BE4->BE4_COMAUT := cStatus
			BE4->(MsUnLock())
		else
			lRet := .F.
			self:impLog('Guia '+cNumGuia+' nao encontrada na tabela de Internacoes BE4')
		endIf
	endIf

Return lRet


Method dateMask(cDate) Class PLINGINTER
	Default cDate := ""
	if !Empty(cDate)
		cDate := Substr(cDate,1,4)+"-"+Substr(cDate,5,2)+"-"+Substr(cDate,7,2)
	endIf
Return Alltrim(cDate)


Method hourMask(cHour) Class PLINGINTER
	Default cHour := ""
	if !Empty(cHour)
		cHour := StrTran(cHour,":","")
		cHour := Substr(cHour,1,4)
	endIf
Return Alltrim(cHour)