#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"

#DEFINE LOG_AUDITORIA_NOVO_AUTORIZADOR "auditoria_novo_autorizador.log"

#DEFINE HAT_CONSULTA 1
#DEFINE HAT_EXAME 2
#DEFINE HAT_EXAME_EXECUCAO 3
#DEFINE HAT_INTERNACAO 4
#DEFINE HAT_PRORROG 8
#DEFINE HAT_ODONTO 9
#DEFINE HAT_OPME 12
#DEFINE HAT_QUIMIO 13
#DEFINE HAT_RADIO 14

/*/{Protheus.doc} PLJBAUDAUT

Função que chama o Job de comunicação para atualizar o status do parecer da auditoria no novo autorizador
@paramc aGuias		Formato Guias da B53 { B53_ALIMOV, B53_RECMOV }

@author Karine Riquena Limp
@since 03/04/2018
/*/
Function PLJBAUDAUT(aGuias)
	Default aGuias := {}
	startJob("PLINAUTAUD", getEnvServer(), .f., cEmpAnt, cFilAnt, aGuias)
Return

/*/{Protheus.doc} PLINAUTAUD

Job de comunicação para atualizar o status do parecer da auditoria no novo autorizador

@paramc cEmp		Empresa que iniciou o JOB
@paramc cFil		Filial que iniciou o JOB
@paramc aGuias		Formato Guias da B53 { B53_ALIMOV, B53_RECMOV }

@author Karine Riquena Limp
@since 03/04/2018
/*/
Function PLINAUTAUD(cEmp,cFil,aGuias)

	Local cQuery := ""
	Local cAliasTemp := ""
	Local cJson  := ""
	Default aGuias := {}

	RpcSetType(3)
	RpcSetEnv(cEmp, cFil,,,'PLS',,)

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLINTEGAUT: EXECUÇÃO FUNÇÃO DE COMUNICAÇÃO",LOG_AUDITORIA_NOVO_AUTORIZADOR)

	if empty(aGuias)

		PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLINTEGAUT: FUNÇÃO CHAMADA VIA SCHEDULE",LOG_AUDITORIA_NOVO_AUTORIZADOR)
		cAliasTemp := GetNextAlias()
		cQuery := " SELECT "
		cQuery += " B53_ALIMOV,"
		cQuery += " B53_RECMOV "
		cQuery += "	FROM " + RetSqlName("B53")
		cQuery += "	WHERE B53_FILIAL = '" + xFilial("B53") + "' "
		cQuery += "			AND B53_SITUAC = '1' " //guia analisada
		cQuery += "			AND B53_COMAUT != '1' " //não comunicada com o novo autorizador
		cQuery += "			AND B53_ORIMOV = '6' " //envia somente guias do HAT
		cQuery += " 		AND D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTemp,.F.,.T.)

		While !(cAliasTemp)->(Eof())
			aAdd(aGuias, {(cAliasTemp)->B53_ALIMOV, (cAliasTemp)->B53_RECMOV})
			(cAliasTemp)->(dbSkip())
		EndDo

		(cAliasTemp)->(dbCloseArea())

	endIf


	if !empty(aGuias)
		cJson := PLJSONAUD(aGuias)
		PLCOAUDAUT(PLSINTPAD(), cJson)

		PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLINAUTAUD: FIM DO PROCESSO", LOG_AUDITORIA_NOVO_AUTORIZADOR)
	endIf


Return cJson

/*/{Protheus.doc} PLJSONAUD

Cria o JSON de comunicação para o REST do autorizador

@paramc aGuias		Formato Guias da B53 { B53_ALIMOV, B53_RECMOV }

@return cJson Retorna a string do json de comunicação

@author Karine Riquena Limp
@since 03/04/2018
/*/
static Function PLJSONAUD(aGuias)
	local cAlias		:= ""
	local cJson			:= ""
	local nI			:= 1
    local nJ			:= 1
	local cRecno		:= ""
	local oObjGuias		:= JsonObject():new()
	local cPadBkp		:= ""
	local cCodBkp		:= ""
	local cTipGui		:= ""
	local cCodPad		:= ""
	local cCodPro		:= ""
	local lOdonto		:= .F.
	local cObservacao 	:= ""
	local cDatPro		:= ""
	local cHorPro		:= ""
	local cValSen		:= ""
	local cSenha		:= ""
	local aDePara		:= {}
	default aGuias		:= {}

    oObjGuias['authorizations'] := {}

	for nI := 1 to len(aGuias)

		aAdd(oObjGuias['authorizations'], JsonObject():new())
		cAlias 	:= aGuias[nI][1]
		cRecno 	:= aGuias[nI][2]
		cPadBkp := ''
		cCodBkp := ''
		cSenha 	:= ''
		nJ := 1
		(cAlias)->(dbGoTo(val(cRecno)))

		if cAlias == "B4Q"
			oObjGuias['authorizations'][nI]['authorizationNumber'] := allTrim(B4Q->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT))
			cTipGui := "11"
			cSenha 	:= alltrim(B4Q->B4Q_SENHA)
		elseIf cAlias == "B4A"
			oObjGuias['authorizations'][nI]['authorizationNumber'] := allTrim(B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT))
			cTipGui := allTrim(B4A->B4A_TIPGUI)
			cSenha 	:= alltrim(B4A->B4A_SENHA)
		elseif cAlias == "BEA"
			oObjGuias['authorizations'][nI]['authorizationNumber'] := alltrim(iif(!empty(BEA->BEA_GUIPRE),BEA->BEA_GUIPRE,BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))
			cDatPro := dtos(BEA->BEA_DATPRO)
			cHorPro := substr(alltrim(BEA->BEA_HORPRO),1,5)
			cSenha 	:= alltrim(BEA->BEA_SENHA)
			cValSen := dtos(BEA->BEA_VALSEN)
			cTipGui := alltrim(BEA->BEA_TIPGUI)
			lOdonto := alltrim(BEA->BEA_TIPO) == "4"
		elseif cAlias == "BE4"
			cGuia 	:= alltrim(BE4->BE4_GUIPRE)
			cDatPro := dtos(BE4->BE4_DATPRO)
			cHorPro := substr(alltrim(BE4->BE4_HORPRO),1,5)
			cValSen := dtos(BE4->BE4_DATVAL)
			cSenha 	:= alltrim(BE4->BE4_SENHA)
			cTipGui := alltrim(BE4->BE4_TIPGUI)
			if empty(cDatPro)
				getBEAInfo(BE4->BE4_CODOPE,BE4->BE4_CODLDP,BE4->BE4_CODPEG,BE4->BE4_NUMERO,@cDatPro,@cHorPro,@cGuia)				
			endif
			oObjGuias['authorizations'][nI]['authorizationNumber'] := cGuia
		endIf
		oObjGuias['authorizations'][nI]['authorizationDate'] 	:= cDatPro
		oObjGuias['authorizations'][nI]['authorizationTime'] 	:= cHorPro
		oObjGuias['authorizations'][nI]['password'] 			:= cSenha
		oObjGuias['authorizations'][nI]['passwordExpireDate'] 	:= cValSen
		oObjGuias['authorizations'][nI]['authorizationType'] 	:= PLTPGUIHAT(cTipGui, lOdonto)
		oObjGuias['authorizations'][nI]['procedures'] := {}
		
		B72->(dbSetOrder(1))

        if B72->(msSeek(xFilial("B72") + cAlias + cRecno))

            while !B72->(eof()) .and. xFilial("B72") + (cAlias + cRecno) == B72->(B72_FILIAL + B72_ALIMOV + B72_RECMOV)
				if !empty(cPadBkp+cCodBkp) .and. cPadBkp+cCodBkp == AllTrim(B72->B72_CODPAD) + AllTrim(B72->B72_CODPRO)
					B72->(dbSkip())
					loop
				endIf
				cObservacao := ""
                aAdd(oObjGuias['authorizations'][nI]['procedures'],  JsonObject():new())				
				cPadBkp := AllTrim(B72->B72_CODPAD)
				cCodBkp := AllTrim(B72->B72_CODPRO)
				aDePara := PLGETPROC(cPadBkp,cCodBkp)
				cCodPad := aDePara[2]
				cCodPro := aDePara[3]
				if BCT->(msSeek(xFilial("BCT") + PLSINTPAD() + B72->B72_MOTIVO)) .and. !empty(BCT->BCT_GLTISS)
					cObservacao := alltrim(BCT->BCT_GLTISS) + " - " + alltrim(BCT->BCT_DESTIS)
				endif
				oObjGuias['authorizations'][nI]['procedures'][nJ]['table'] 				:= cCodPad
				oObjGuias['authorizations'][nI]['procedures'][nJ]['code'] 				:= cCodPro
				oObjGuias['authorizations'][nI]['procedures'][nJ]['status'] 			:= iif(B72->B72_PARECE == "0", "1", "0")
				oObjGuias['authorizations'][nI]['procedures'][nJ]['authorizedQuantity'] := B72->B72_QTDAUT
				oObjGuias['authorizations'][nI]['procedures'][nJ]['feedback'] 			:= alltrim(B72->B72_OBSANA)
				oObjGuias['authorizations'][nI]['procedures'][nJ]['observation'] 		:= cObservacao
                nJ++
				B72->(dbSkip())

			endDo

		endIf

	next nI

	cJson := FWJsonSerialize(oObjGuias, .F., .F.)
	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLJSONAUD: JSON GERADO PARA COMUNICAÇÃO: ",LOG_AUDITORIA_NOVO_AUTORIZADOR)
	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLJSONAUD: " + cJson,LOG_AUDITORIA_NOVO_AUTORIZADOR)

Return cJson

/*/{Protheus.doc} PLTPGUIHAT
Retorna o tipo de guia de acordo com o que o HAT precisa

@param	cTipGui	Tipo de guia no protheus
@param	lOdonto	Indica que é uma guia tipo 02 porem de Odonto
@return	nTipGui	Retorna o tipo de guia para o HAT

@author Karine Riquena Limp
@since 10/04/2018
/*/
static Function PLTPGUIHAT(cTipGui, lOdonto)
	local nTipGui := 0

	do case
		case cTipGui == "01"
			nTipGui := HAT_CONSULTA
		case cTipGui == "02"
			if lOdonto
				nTipGui := HAT_ODONTO
			else
				nTipGui := HAT_EXAME
			endif
		case cTipGui == "03"
			nTipGui := HAT_INTERNACAO
		case cTipGui == "07"
			nTipGui := HAT_QUIMIO
		case cTipGui == "08"
			nTipGui := HAT_RADIO
		case cTipGui == "09"
			nTipGui := HAT_OPME
		case cTipGui == "11"
			nTipGui := HAT_PRORROG
		case cTipGui == "13"
			nTipGui := HAT_ODONTO
	end case

return nTipGui

/*/{Protheus.doc} PLCOAUDAUT

Comunica o PLS com o novo autorizador

@paramc cCodOpe		Código da operadora para pegar o endpoint do autorizador
@paramc cJson		JSON que será enviado para o autorizador

@author Karine Riquena Limp
@since 03/04/2018
/*/
static Function PLCOAUDAUT(cCodOpe, cJson)

	Local cEndPoint := alltrim(Posicione("BA0", 1, xFilial("BA0")+cCodOpe, "BA0_ENDPOI"))
	Local oRestClient := NIL
	Local cResponse := ""
	Local oJsonParser := JsonParser():New()
	Local hMap    := nil
	Local lOk	:= .F.
	Local cMsg := ""
	Local aHeader := {}
	Local lSuccess := .F.
	Local aDadHeader := PLGDadHead()
	Local nX := 1

	if !empty(cEndPoint)

		 oRestClient := FWRest():New(cEndPoint)

        // o Path completo do endpoint já vai vir da operadora,
        // passo uma string em branco pois dentro do FWREST é feita a concatenação do host+path
        // se o path estiver NIL vai ocorrer error.log
        oRestClient:setPath("")
        oRestClient:SetPostParams(cJson)
		aAdd(aHeader,'Content-Type: application/json')
		for nX := 1 to len(aDadHeader)
			aAdd(aHeader,aDadHeader[nX,1]+": "+aDadHeader[nX,2])
		next
		PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLCOAUDAUT: INÍCIO DE COMUNICAÇÃO COM O AUTORIZADOR ",LOG_AUDITORIA_NOVO_AUTORIZADOR)

		If oRestClient:Post(aHeader)
			cResponse := oRestClient:GetResult()
			oJsonParser:setJson(cResponse)
			hMap := oJsonParser:parseJson()
			if hMap:get("success",@lOk) .and. !lOk
				hMap:get("msgError",@cMsg)
				PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLCOAUDAUT: COMUNICAÇÃO FALHOU ERRO: " + cMsg,LOG_AUDITORIA_NOVO_AUTORIZADOR)
			Else
				lSuccess := .T.
				PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLCOAUDAUT: COMUNICAÇÃO OBTEVE ÊXITO", LOG_AUDITORIA_NOVO_AUTORIZADOR)
				PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLCOAUDAUT: RESPOSTA DO AUTORIZADOR: " + cResponse, LOG_AUDITORIA_NOVO_AUTORIZADOR)
				PLATUCOB53(cResponse)
			endIf
		Else
			PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLCOAUDAUT: COMUNICAÇÃO FALHOU ERRO: " + oRestClient:GetLastError(),LOG_AUDITORIA_NOVO_AUTORIZADOR)
		EndIf

	else
		PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLCOAUDAUT: ENDPOINT NÃO CONFIGURADO PARA A OPERADORA",LOG_AUDITORIA_NOVO_AUTORIZADOR)
	endIf


Return lSuccess

/*/{Protheus.doc} PLCOAUDAUT

Comunica o PLS com o novo autorizador

@paramc cCodOpe		Código da operadora para pegar o endpoint do autorizador
@paramc cJson		JSON que será enviado para o autorizador

@author Karine Riquena Limp
@since 03/04/2018
/*/
static Function PLATUCOB53(cResponse)

	Local nI := 0
	Local nTamSucesso := 0
	Local nTamInvalido := 0
	Local aArea	:= getArea()
	Local oResponse := JsonObject():New()
	Local cNumGuia := ""
	Local cErroGuia := ""
	Local cRecno := 0
	Local cAlias := ""
	Local lFound := .F.
	Local aRet   := {}
	
	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLATUCOB53: ATUALIZANDO REGISTRO NA AUDITORIA ", LOG_AUDITORIA_NOVO_AUTORIZADOR)

	oResponse:fromJSON(cResponse)

	if valtype(oResponse['authorizations']) != "U"

		B53->(dbSetOrder(4))
		BEA->(dbSetOrder(24))
		BE4->(dbSetOrder(17))

		if valtype(oResponse['authorizations']['successAuthorizations']) != "U"
			nTamSucesso := Len(oResponse['authorizations']['successAuthorizations'])

			for nI := 1 to nTamSucesso
				
				cNumGuia := oResponse['authorizations']['successAuthorizations'][nI]['authorizationNumber']
				
				aRet := buscGuiAli(cNumGuia)
				lFound := aRet[1]
				cRecno := aRet[2]
				cAlias := aRet[3]				
				atB53ComAut(lFound,cAlias,cRecno,cNumGuia)

			next nI

		endIf

		if valtype(oResponse['authorizations']['invalidAuthorizations']) != "U"
			nTamInvalido := Len(oResponse['authorizations']['invalidAuthorizations'])
			for nI := 1 to nTamInvalido
				cNumGuia := oResponse['authorizations']['invalidAuthorizations'][nI]['authorizationNumber']
				cErroGuia := oResponse['authorizations']['invalidAuthorizations'][nI]['msgError']
				PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLATUCOB53: Guia " + cNumGuia + " inválida. (";
				 + cErroGuia + ")" ,LOG_AUDITORIA_NOVO_AUTORIZADOR)

				if valtype(oResponse['authorizations']['invalidAuthorizations'][nI]['code']) != "U" .And. ;
					oResponse['authorizations']['invalidAuthorizations'][nI]['code'] == '0003'

					aRet := buscGuiAli(cNumGuia)
					lFound := aRet[1]
					cRecno := aRet[2]
					cAlias := aRet[3]					
					atB53ComAut(lFound,cAlias,cRecno,cNumGuia)
				endIf

			next nI
		endIf

	endIf

	restArea(aArea)

Return

/*/{Protheus.doc} getBEAInfo
Pega informações do BEA caso não existam nas guias vinculadas.

@author Lucas Nonato
@since 	07/02/2022
/*/
static function getBEAInfo(cCodOpe,cCodLdp,cCodPeg,cNumero,cDatPro,cHorPro,cGuia)
local cSql := ""

cSql := " SELECT BEA_DATPRO,BEA_HORPRO,BEA_OPEMOV,BEA_ANOAUT,BEA_MESAUT,BEA_NUMAUT  "
cSql += " FROM " +RetSQLName("BEA")
cSql += " WHERE BEA_FILIAL = '"+xfilial("BEA")+"'"
cSql += " AND BEA_OPEMOV = '"+cCodOpe+"'"
cSql += " AND BEA_CODLDP = '"+cCodLdp+"'"
cSql += " AND BEA_CODPEG = '"+cCodPeg+"'"
cSql += " AND BEA_NUMGUI = '"+cNumero+"'"
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TrbBEADT",.f.,.t.)

if !TrbBEADT->( eof() )
	cDatPro := alltrim(TrbBEADT->BEA_DATPRO)
	cHorPro := alltrim(TrbBEADT->BEA_HORPRO)
	if empty(cGuia)
		cGuia := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
	endif
endif
TrbBEADT->( dbCloseArea() )

return

/*/{Protheus.doc} buscGuiAli
Busca Alias que se encontra a guia

@author sakai
@since 	13/05/2022
/*/
Static Function buscGuiAli(cNumGuia)

	Local lFound := .F.
	Local cRecno := ""
	Local cAlias := ""
	Local aAreaBEA := {}

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLATUCOB53: Nº GUIA PRESTADOR RETORNADO PELO AUTORIZADOR: " + cNumGuia, LOG_AUDITORIA_NOVO_AUTORIZADOR)
	
	BE4->(dbGoTop())
	if BE4->(MsSeek(xFilial("BE4")+cNumGuia))

		cRecno := allTrim(str(BE4->(RECNO())))
		cAlias := "BE4"
		lFound := .T.
		PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLATUCOB53: GUIA ENCONTRADA NA BE4: " + BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT), LOG_AUDITORIA_NOVO_AUTORIZADOR)

	endIf

	if !lFound
		B4A->(dbGoTop())
		if B4A->(MsSeek(xFilial("B4A")+cNumGuia))

			cRecno := allTrim(str(B4A->(RECNO())))
			cAlias := "B4A"
			lFound := .T.
			PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLATUCOB53: GUIA ENCONTRADA NA B4A: " + B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT), LOG_AUDITORIA_NOVO_AUTORIZADOR)

		endIf
	endIf

	if !lFound
		B4Q->(dbsetorder(1))
		if B4Q->(MsSeek(xFilial("B4Q")+cNumGuia))

			cRecno := allTrim(str(B4Q->(RECNO())))
			cAlias := "B4Q"
			lFound := .T.
			PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLATUCOB53: GUIA ENCONTRADA NA B4Q: " + B4Q->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT), LOG_AUDITORIA_NOVO_AUTORIZADOR)

		endIf
	endIf

	if !lFound

		aAreaBEA := BEA->(GetArea())
		BEA->(dbSetOrder(24)) //BEA_FILIAL+BEA_GUIPRE
		lFound := BEA->(MsSeek(xFilial("BEA")+cNumGuia))
		
		if !lFound
			BEA->(dbSetOrder(1)) //BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+DTOS(BEA_DATPRO)+BEA_HORPRO
			lFound := BEA->(MsSeek(xFilial("BEA")+cNumGuia))
		endIf

		if lFound
			cRecno := allTrim(str(BEA->(RECNO())))
			cAlias := "BEA"
			PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLATUCOB53: GUIA ENCONTRADA NA BEA: " + BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT), LOG_AUDITORIA_NOVO_AUTORIZADOR)
		endIf

		restArea(aAreaBEA)
	endIf

Return {lFound,cRecno,cAlias}

/*/{Protheus.doc} atB53ComAut
Atualiza B53

@author sakai
@since 	13/05/2022
/*/
Static Function atB53ComAut(lFound,cAlias,cRecno,cNumGuia)

	Local cTamRecMov := TamSx3("B53_RECMOV")[1]
	
	if lFound
		B53->(dbGoTop())
		if B53->(MsSeek(xFilial("B53") + cAlias + cRecno + Space(cTamRecMov - Len(cRecno))))
			PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLATUCOB53: GUIA ENCONTRADA NA AUDITORIA: " + cNumGuia, LOG_AUDITORIA_NOVO_AUTORIZADOR)
			B53->(RecLock("B53",.F.))
				B53->B53_COMAUT := '1'
			B53->(MsUnLock())
		else
			PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLATUCOB53: GUIA NÃO ENCONTRADA NA AUDITORIA: " + cNumGuia, LOG_AUDITORIA_NOVO_AUTORIZADOR)
		endIf

	else
		PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLATUCOB53: GUIA RETORNADA PELO AUTORIZADOR NÃO ENCONTRADA: " + cNumGuia, LOG_AUDITORIA_NOVO_AUTORIZADOR)
	endIf

Return