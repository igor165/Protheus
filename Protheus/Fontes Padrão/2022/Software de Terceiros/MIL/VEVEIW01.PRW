/////////////////
// Version 011 //
/////////////////

#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APWEBSRV.CH"

Function VEVEIW01()
Return .T.


/*/{Protheus.doc} WSSERVICE DMS_CORE
	Controlador de webservice utilizado nos projetos mobile da MIL

	@author Vinicius Gati
	@since 17/05/2016

/*/
WSSERVICE DMS_CORE
	WSDATA RESP          as String
	WSDATA cAToken       as String // token de acesso
	WSDATA cCpfSeller    as String
	WSDATA cRecno        as String
	WSDATA cJsonData     as String
	WSDATA cDataJson     as String

	WSMETHOD CRIAREG
	WSMETHOD XFILIAL
	WSMETHOD GTSXENUM
	WSMETHOD SDCOORD
//	WSMETHOD SDGERAL
	WSMETHOD INTFNC
	WSMETHOD SMZERO
ENDWSSERVICE

/*/{Protheus.doc} XFILIAL
	Comando XFILIAL para ser usado no cev plus em casos mais complicados

	@author Vinicius Gati
	@since 22/08/2016

/*/
WSMETHOD XFILIAL WSRECEIVE cDataJson WSSEND RESP WSSERVICE DMS_CORE
	oJsonParser := Mil_JsonParse():New(cDataJson)
	oJsonData   := oJsonParser:ParseToObj()
	cFilAnt     := oJsonData:GetValue('filial')
	cTabela     := oJsonData:GetValue('tabela')
	::RESP      := '{ "status":"ok", "filial": "' + xFilial(cTabela) + '" }'
RETURN .T.

/*/{Protheus.doc} SDGERAL
	Comando SDGERAL para ser usado no cev plus em casos de salvamentos de tabelas com campos customizados
	possívelmente todos os cadastros usaram este metodo de agora em diante.

	Será definido um modelo de json que será usado para resolver a necessidade de customizacao dos cadastros do cev plus

	@author Vinicius Gati
	@since 13/01/2017

/*/
//WSMETHOD SDGERAL WSRECEIVE cDataJson, cCpfSeller, cAtoken WSSEND RESP WSSERVICE DMS_CORE
//	FS_StFilial(cCpfSeller)
//	oJsonParser := Mil_JsonParse():New(cDataJson)
//	oJsonData   := oJsonParser:ParseToObj()
//RETURN .T.

/*/{Protheus.doc} INTFNC
	Comando usado para criar interfaces de comunicacao entre sistemas externos com o protheus

	formato de comunicação:
		{
			"nome": "U_VALIDA",
			"parametros": ":codigo, :peca, :teste",
			"valores": [
				{"nome": ":codigo", "valor": "10"  , "tipo": "number" },
				{"nome": ":peca"  , "valor": "JD01", "tipo": "string" },
				{"nome": ":teste" , "valor": "true", "tipo": "boolean"}
			]
		}

	@author Vinicius Gati
	@since 13/01/2017

/*/
WSMETHOD INTFNC WSRECEIVE cDataJson, cCpfSeller, cAtoken WSSEND RESP WSSERVICE DMS_CORE
	Local nIdx := 0
	FS_StFilial(cCpfSeller)
	oJsonParser := Mil_JsonParse():New(cDataJson)
	oDados      := oJsonParser:ParseToObj()

	cFuncao     := oDados:GetValue("nome", "")
	cParametros := oDados:GetValue("parametros", "")
	aValores    := oDados:GetValue("valores", {})
	if LEFT(cFuncao, 2) != "U_"
		::RESP := '{"erro": "Somente funções de usuário podem ser chamadas via integração por webservice"}'
	else
		for nIdx := 1 to LEN(aValores)
			oVal := aValores[nIdx]
			cValor := oVal:GetValue("valor","")

			If oVal:GetValue("tipo", "") == "string"
				cValor := "'" +cValor+ "'"
			ElseIf oVal:GetValue("tipo", "") == "boolean"
				if cValor == "true"
					cValor := ".T."
				else
					cValor := ".F."
				endif
			EndIf

			cParametros := STRTRAN( cParametros, oVal:GetValue("nome"), cValor )
		next
		conout(cFuncao +"("+ cParametros + ")")
		::RESP := &(cFuncao +"("+ cParametros + ")")
	EndIf
RETURN .T.

/*/{Protheus.doc} SMZERO
	Retorna o comando SM0 com dados interessantes para cev

	@author Vinicius Gati
	@since 23/01/2017

/*/
WSMETHOD SMZERO  WSRECEIVE cDataJson WSSEND RESP WSSERVICE DMS_CORE
	Local nIdx := 0
	Local cJson := ''
	aData := FWLOADSM0()

	for nIdx := 1 to LEN(aData)
		aSel := aData[nIdx]
		cObj := '{ "filial_completa": "'+aSel[2]+'", "empresa": "'+aSel[3]+'", "unidade": "'+aSel[4]+'", "filial": "'+aSel[5]+'", "nome": "'+aSel[7]+'"}'
		cJson += cObj
		if nIdx < LEN(aData)
			cJson += ","
		endIf
	next
	::RESP := ' { "dados": [' + cJson + '] } '
RETURN .T.


/*/{Protheus.doc} CRIARREG
	Cria um registro em branco e deletado e passa para um software não protheus para manuseio posterior
	Será utilizado em sistemas externos mobile da MIL

	@author Vinicius Gati
	@since 14/01/2015

/*/
WSMETHOD CRIAREG WSRECEIVE cDataJson, cCpfSeller, cAToken WSSEND RESP WSSERVICE DMS_CORE
	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		oJsonParser := Mil_JsonParse():New(cDataJson)
		oJsonData   := oJsonParser:ParseToObj()
		cTabela     := oJsonData:GetValue('tabela')

		if ! FS_FndCpf(cCpfSeller)
			::RESP := ' { "error" : "Cpf não econtrado" } '
			Return .F.
		endIf

		if EMPTY(cFilAnt)
			::RESP := ' { "error" : "Cpf não econtrado e filial não setada" } '
			Return .F.
		else
			//conout("Filial selecionada: " + cfilant)
		endIf

		RecLock(cTabela, .T.)
		DO CASE
		CASE cTabela == 'VDL'
			VDL->VDL_CODOPO := GETSXENUM('VDL', 'VDL_CODOPO')
			VDL->VDL_FILIAL := xFilial("VDL")
		Case cTabela == 'VDM'
			VDM->VDM_CODINT := GETSXENUM('VDM', 'VDM_CODINT')
			VDM->VDM_FILIAL := xFilial("VDM")
		CASE cTabela == 'SUS'
			SUS->US_COD := GETSXENUM('SUS', 'US_COD')
			SUS->US_FILIAL := xFilial("SUS")
		ENDCASE
		ConfirmSx8()
		MsUnLock()

		nRecno := recno()
		// Deleta registro
		dbGoTo(nRecno)
		RecLock(cTabela, .F.)
		dbdelete()
		MsUnlock()

		if (nRecno <= 0)
			cErr := IIF(nRecno == -3, "Cliente não encontrado", "Json inválido")
			::RESP := '{ "error":"'+cErr+'" }'
		Else
			::RESP := '{ "status":"ok", "recno": ' + STR(nRecno) + ', "filial_produtivo": "'+cFilAnt+'" }'
		end
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
Return .T.

/*/{Protheus.doc} CRIARREG
	Recebe dados de uma coordenada de um vendedor, provavelmente colhida via mil-mobile.
	modelo de json {"_latitude":-22.293365,"_longitude":-48.56191,"_created_at":"20161121|1752","_id":45}
	@author Vinicius Gati
	@since 21/11/2016

/*/
WSMETHOD SDCOORD WSRECEIVE cDataJson, cCpfSeller, cAToken WSSEND RESP WSSERVICE DMS_CORE
	conout(cDataJson)
	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		if ! FS_FndCpf(cCpfSeller)
			::RESP := ' { "error" : "Cpf não econtrado" } '
			Return .F.
		endIf

		oJsonParser := Mil_JsonParse():New(cDataJson)
		oJsonData   := oJsonParser:ParseToObj()

		//
		// {"_latitude":-22.293365,"_longitude":-48.56191,"_created_at":"20161121|175201","_id":45}
		//
		reclock("VR5", .T.)
		VR5->VR5_FILIAL := xFilial('VR5')
		VR5->VR5_CODIGO := GETSXENUM('VR5', 'VR5_CODIGO')
		ConfirmSx8()
		cData := LEFT(oJsonData:GetValue('_created_at'), 8)
		cHora := RIGHT(oJsonData:GetValue('_created_at'), 6)
		VR5->VR5_CODSA3 := SA3->A3_COD
		VR5->VR5_LATITU := VAL(oJsonData:GetValue('_latitude', "0"))
		VR5->VR5_LONGIT := VAL(oJsonData:GetValue('_longitude', "0"))
		VR5->VR5_DATA   := STOD(cData)
		VR5->VR5_HORA   := cHora
		VR5->(MsUnLock())

		::RESP := '{ "status":"ok", "recno": '+STR(VR5->(recno()))+' }'
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
Return .T.

WSMETHOD GTSXENUM WSRECEIVE cDataJson, cCpfSeller, cAToken WSSEND RESP WSSERVICE DMS_CORE
	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		oJsonParser := Mil_JsonParse():New(cDataJson)
		oJsonData   := oJsonParser:ParseToObj()
		cTabela     := oJsonData:GetValue('tabela')
		cCampo      := oJsonData:GetValue('campo')

		if ! FS_FndCpf(cCpfSeller)
			::RESP := ' { "error" : "Cpf não econtrado" } '
			Return .F.
		endIf

		::RESP := '{ "status":"ok", "numero": "' + GETSXENUM(cTabela, cCampo) + '", "filial_produtivo": "'+cFilAnt+'" }'
		ConfirmSx8()
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
Return .T.

/*/{Protheus.doc} WSSERVICE CEV
	Controlador de webservice utilizado no CEV Mobile como ponte para ter acesso ao protheus

	Utiliza VEIXFUNC e VEIXFUNB

	@author Vinicius Gati
	@since 14/01/2015

/*/
WSSERVICE CEV
	WSDATA RESP          as String
	WSDATA cAToken       as String // token de acesso
	WSDATA cCpfSeller    as String
	WSDATA cRnoCust      as String
	WSDATA cRecno        as String
	WSDATA cJsonData     as String
	WSDATA cDataJson     as String
	WSDATA cRnos         as String
	WSDATA cField        as String
	WSDATA nOFFSET       as Integer
	WSDATA nQUANT        as Integer

	WSMETHOD GtServerStatus
	WSMETHOD GtTpAgenda
	WSMETHOD GtTpAbordagem
	WSMETHOD GtTpContato
	WSMETHOD GtClientes
	WSMETHOD GtProspects
	WSMETHOD GtPProspects
	WSMETHOD GtProspect
	WSMETHOD GtRnoClis
	WSMETHOD GtCliente
	WSMETHOD GtAgendas
	WSMETHOD GtPAgendas
	WSMETHOD SdCliente
	WSMETHOD SdAgenda
	WSMETHOD GTTOKENACESSO
	WSMETHOD GtFiliais
	WSMETHOD GtX3Cbox
	WSMETHOD SdProAgenda
ENDWSSERVICE

/*/{Protheus.doc} WSSERVICE CEV
	Controlador de webservice utilizado no Mil - Mobile como ponte para ter acesso ao protheus

	Utiliza VEIXFUNC e VEIXFUNB

	@author Vinicius Gati
	@since 14/01/2015

/*/
WSSERVICE OPORT
	WSDATA RESP          as String
	WSDATA cAToken       as String // token de acesso
	WSDATA cCpfSeller    as String
	WSDATA cRecno        as String
	WSDATA cJsonData     as String
	WSDATA cDataJson     as String
	WSDATA cRnoInt       as String
	WSDATA nOFFSET       as Integer
	WSDATA nQUANT        as Integer

	WSMETHOD GTVeiCores
	WSMETHOD GTMotCanc
	WSMETHOD GtBancos
	WSMETHOD GtLinCred
	WSMETHOD GtModelos
	WSMETHOD GtPModelos
	WSMETHOD GTStFinan
	WSMETHOD GTStInter
	WSMETHOD GTCampanha
	WSMETHOD GTMarcas
	WSMETHOD GTOports
	WSMETHOD GTInter
	WSMETHOD GtHsStOp
	WSMETHOD GtHsStOpFi
	WSMETHOD SdOports
	WSMETHOD SdIntere
	WSMETHOD SdStsCh
	WSMETHOD SdProOpo
ENDWSSERVICE

/*/{Protheus.doc} WSSERVICE CEV
	Controlador de webservice utilizado no Mil - Mobile como ponte para ter acesso ao protheus

	Utiliza VEIXFUNC e VEIXFUNB

	@author Vinicius Gati
	@since 14/01/2015

/*/
WSSERVICE RAIC
	WSDATA RESP          as String
	WSDATA cAToken       as String // token de acesso
	WSDATA cCpfSeller    as String
	WSDATA cRecno        as String
	WSDATA cJsonData     as String
	WSDATA cDataJson     as String
	WSDATA cRnoInt       as String
	WSDATA nOFFSET       as Integer
	WSDATA nQUANT        as Integer

	WSMETHOD GtRaics
	WSMETHOD GtTpsReg
	WSMETHOD GtDeparts
	WSMETHOD GtEquipe
	WSMETHOD SdRaic
ENDWSSERVICE



/*/{Protheus.doc} GtX3Cbox
	Retorna o campo X3_CBOX do protheus de um determinado campo

	@author Vinicius Gati
	@since 09/03/2016

/*/
WSMETHOD GtX3Cbox WSRECEIVE cField WSSEND RESP WSSERVICE CEV
	DbSelectArea('SX3')
	DbSetOrder(2)
	MsSeek(cField)

	::RESP := ' { "x3_cbox": "'+SX3->X3_CBOX+'" } '
Return .T.

/*/{Protheus.doc} GtFiliais
	Retorna xFilial das filiais setando vendedor e filial do produtivo

	@author Vinicius Gati
	@since 14/01/2015

/*/
WSMETHOD GtFiliais WSRECEIVE cDataJson, cCpfSeller WSSEND RESP WSSERVICE CEV
	Local cErr  := ""
	Local aFils, aFils2
	Local oArHlp := DMS_ArrayHelper():New()
	FS_StFilial(cCpfSeller)


	aFils  := STRTOKARR(cDataJson, "#")
	aFils2 := oArHlp:Map(aFils, { |cFil| '"' +cFil+ '" : "' +xFilial(cFil)+ '"' })

	cJson := ' { "filial_produtivo": "'+cFilAnt+'", '
	cJson += '   "filiais": {' + oArHlp:Join(aFils2, ',') + '} '
	cJson += ' } '
	::RESP := cJson
Return .T.

/*/{Protheus.doc} SdAgenda
	Rota que sincroniza agenda recebida no formato
		{
			"recno":0, <-- 0 não nulo
			"recno_cliente":1,
			"recno_tipo_abordagem":1,
			"recno_tipo_agenda":1,
			"recno_tipo_contato":1,
			"dt_prox_contato":"02\/01\/2015",<-- remover, será enviado como agenda para criacao como uma agenda normal
			"dt_agenda":"01\/01\/2015",
			"ocorrencia":"ocorrencia teste",
			"objetivo":"objetivo teste",
			"dt_abordagem":"01\/01\/2015",
			"nome_contato":"Contato teste"
		}

	Utiliza VEIXFUNC e VEIXFUNB

	@author Vinicius Gati
	@since 14/01/2015

/*/
WSMETHOD SdAgenda WSRECEIVE cDataJson, cCpfSeller, cAToken WSSEND RESP WSSERVICE CEV
	Local cErr  := ""
	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		oJsonParser := Mil_JsonParse():New(cDataJson)
		oJsonData   := oJsonParser:ParseToObj()
		oAgenda     := oJsonData:GetValue('agenda')


		if FS_FndCpf(cCpfSeller)
			nRecnoV := SA3->(recno())
		else
			::RESP := ' { "error" : "Cpf não econtrado" } '
			Return .T.
		endIf

		nRecno      := WsGrvAgenda(oJsonParser, oAgenda, nRecnoV)
		if (nRecno <= 0)
			cErr := IIF(nRecno == -3, "Cliente não encontrado", "Json inválido")
			::RESP := '{ "error":"'+cErr+'" }'
		Else
			::RESP := '{ "status":"ok", "recno": ' + STR(nRecno) + '} '
		end
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

WSMETHOD SdProAgenda WSRECEIVE cDataJson, cCpfSeller, cAToken WSSEND RESP WSSERVICE CEV
	Local cErr  := ""
	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	conout("SdProAgenda - " + cDataJson)
	if .T. // oToken:Busca(cAToken)
		oJsonParser := Mil_JsonParse():New(cDataJson)
		oJsonData   := oJsonParser:ParseToObj()
		oAgenda     := oJsonData:GetValue('agenda')


		if FS_FndCpf(cCpfSeller)
			nRecnoV := SA3->(recno())
		else
			::RESP := ' { "error" : "Cpf não econtrado" } '
			Return .T.
		endIf

		//conout("vendedor selecionado , gravando agenda/prospect")

		nRecno      := WsGrvAgenda(oJsonParser, oAgenda, nRecnoV, .T.)
		//conout("fim gravacao prospect")
		if (nRecno <= 0)
			cErr := IIF(nRecno == -3, "Prospect não encontrado", "Json inválido")
			::RESP := '{ "error":"'+cErr+'" }'
		Else
			::RESP := '{ "status":"ok", "recno": ' + STR(nRecno) + '} '
		end
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} WsGrvAgenda
	Rota que sincroniza cliente recebido no formato
		{
			"recno":0, <-- 0 não nulo
			"recno_cliente":1,
			"recno_tipo_abordagem":1,
			"recno_tipo_agenda":1,
			"recno_tipo_contato":1,
			"dt_prox_contato":"02\/01\/2015",<-- remover, será enviado como agenda para criacao como uma agenda normal
			"dt_agenda":"01\/01\/2015",
			"ocorrencia":"ocorrencia teste",
			"objetivo":"objetivo teste",
			"dt_abordagem":"01\/01\/2015",
			"produtivo": true,
			"nome_contato":"Contato teste",
			"prospect:" {
				nome: "xxx",
				documento: "xxxx",
				telefone: "xxx"
			}
		}

	Utiliza VEIXFUNC e VEIXFUNB

	@author Vinicius Gati
	@since 14/01/2015

/*/
Function WsGrvAgenda( oJsonParser, oAgenda, nRecnoV, lPro )
	Local nRecno  := 0
	Local oCev
	Local oRet    := nil
	default lPro  := .f.

	if (lPro) .and. FindClass("VEDMSCEV")

		oCev := VEDMSCev():New()

		conout("Prospect recebido na agenda")
		oRet := oCev:ConvCli(oAgenda:getvalue('prospect'))
		if oRet:GetValue('erro', .F.)
			return
		else
			if oRet:GetValue('prospect')
				SUS->(DBGOTO(oRet:getvalue('recno')))
			else
				SA1->(DBGOTO(oRet:getvalue('recno')))
				lPro := .F.
			end
		endif
	else
		SA1->(DBGOTO( VAL( oAgenda:GetValue('recno_cliente', '0') ) ))
	endif

	conout("|> gravando agenda")
	SET DELETE OFF
	BEGIN TRANSACTION

	nRecno  := oJsonParser:readInt( oAgenda:GetValue('recno', '0') )

	if nRecno > 0
		VC1->(DBGOTO( nRecno ))
		RecLock( "VC1", IIF(!EOF(), .F., .T.) ) // .F. = (alteracao | ja existe)
	Else
		RecLock( "VC1", .T. )
	EndIf
	SA3->(DBGOTO(nRecnoV))
	if EMPTY( VC1->VC1_CODVEN ) // novo registro
		if oJsonParser:readInt( oAgenda:GetValue('recno_tipo_agenda') ) > 0
			VC5->(DBGOTO( oJsonParser:readInt( oAgenda:GetValue('recno_tipo_agenda') ) ))
			VC1->VC1_TIPAGE := VC5->VC5_TIPAGE // I
		EndIf
		VC1->VC1_DATAGE := STOD( oJsonParser:readDate( oAgenda:GetValue('dt_agenda') ) )
		VC1->VC1_FILIAL := xFilial('VC1')
	EndIf

	if oJsonParser:readInt(oAgenda:GetValue('recno_tipo_abordagem')) > 0
		VCA->(DBGOTO( oJsonParser:readInt( oAgenda:GetValue('recno_tipo_abordagem') ) ))
		VC1->VC1_CODABO := VCA->VCA_CODABO // IA
	endif

	if oJsonParser:readInt(oAgenda:GetValue('recno_tipo_contato')) > 0
		VC0->(DBGOTO( oJsonParser:readInt( oAgenda:GetValue('recno_tipo_contato') ) ))
		VC1->VC1_TIPCON := VC0->VC0_TIPCON // IA
	endif

	VC1->VC1_NOMCON := oAgenda:GetValue('nome_contato')
	VC1->VC1_DATVIS := STOD( oJsonParser:readDate( oAgenda:GetValue('dt_abordagem') ) )
	if !EMpty(oAgenda:GetValue('dt_prox_contato'))
		VC1->VC1_PROCON := STOD( oJsonParser:readDate( oAgenda:GetValue('dt_prox_contato') ) )
	endIf
	cOcorrencia := STRTRAN( oAgenda:GetValue('ocorrencia'), "\r\n", chr(10) + chr(3) )
	cObjetivo   := STRTRAN( oAgenda:GetValue('objetivo')  , "\r\n", chr(10) + chr(3) )
	MSMM(VC1->VC1_OCOMEM,TamSx3("VC1_OCORRE")[1],, cOcorrencia ,1,,,"VC1","VC1_OCOMEM")
	MSMM(VC1->VC1_OBSOBJ,TamSx3("VC1_OBJETI")[1],, cObjetivo   ,1,,,"VC1","VC1_OBSOBJ")

	VC1->VC1_CONPRO := IIF(oAgenda:GetValue('produtivo', "") == "true", "1", "0")

	if lPro .AND. ! Empty(SUS->US_COD) .AND. ! Empty( SUS->US_LOJA )
		VC1->VC1_CDPROS := SUS->US_COD
		VC1->VC1_LJPROS := SUS->US_LOJA
		VC1->VC1_CODCLI := ''
		VC1->VC1_LOJA   := ''
	else
		VC1->VC1_CODCLI := SA1->A1_COD
		VC1->VC1_LOJA   := SA1->A1_LOJA
		VC1->VC1_CDPROS := ''
		VC1->VC1_LJPROS := ''
	endIf

	VC1->VC1_CODVEN := SA3->A3_COD
	VC1->(MsUnLock())
	nRecno := VC1->(recno())

	END TRANSACTION
	SET DELETE ON
Return nRecno

/*/{Protheus.doc} SdCliente
	Rota que sincroniza cliente recebido no formato
	"cliente":{"recno":0,"telefone":"00000000000","documento":"","nome":"CLIENTE AVALIACAO DE CREDITO"}

	Utiliza VEIXFUNC e VEIXFUNB

	@author Vinicius Gati
	@since 14/01/2015

/*/
WSMETHOD SdCliente WSRECEIVE cCpfSeller, cDataJson, cAToken WSSEND RESP WSSERVICE CEV
	Local oCev := VEDMSCev():New()
	FS_StFilial(cCpfSeller)
	conout(cDataJson)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		oJsonParser := Mil_JsonParse():New(cDataJson)
		oJsonData   := oJsonParser:ParseToObj()
		oCliente    := oJsonData:GetValue('cliente')

		if oCliente:GetValue("prospect") == "true"
			oRet := oCev:AtuSus(oCliente:GetValue('recno', '0'), oCliente)
		else
			oRet := oCev:AtuSa1(oCliente:GetValue('recno', '0'), oCliente)
		endIf
		::RESP := '{ "status":"ok", "recno": ' + cValToChar(oRet:GetValue('recno')) + '} '
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GtAgendas
	Retorna as agendas associadas a determinado cliente(cpf)

	@author Vinicius Gati
	@since 14/01/2015

	@return json, retorna as agendas em formato json

/*/
WSMETHOD GtAgendas WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE CEV
	Local cJson := '{ "agendas" : ['
	Local lFirst := .T.
	Local oSqlHlp := DMS_SqlHelper():New()
	Local cQuery
	Local nIdx := 1

	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		// POG
		INCLUI     := .F.
		ALTERA     := .F.
		VISUALIZA  := .T.
		// END POG

		if FS_FndCpf(cCpfSeller)

			cQuery := ""
			cQuery += " SELECT R_E_C_N_O_  as recno FROM " + oSqlHlp:NoLock('VC1')
			cQuery += "  WHERE VC1_FILIAL = '"+xFilial('VC1')+"' AND VC1_CODVEN = '"+SA3->A3_COD+"' "
			cQuery += "    AND (VC1_DATVIS = '' OR VC1_DATAGE >= '"+DTOS(dDatabase-30)+"') AND D_E_L_E_T_ = ' ' "
			aRecnos := oSqlHlp:GetSelect({;
				{'campos', {'recno'}},;
				{'query' , cQuery } ;
			})

			For nIdx := 1 to LEN(aRecnos)
				VC1->(DbGoTo(aRecnos[nIdx]:GetValue('recno')))

				// não está em aberto
				if ! Empty(VC1->VC1_DATVIS)
//					if VC1->VC1_DATAGE < MonthSub( dDatabase , 2 )
					VC1->(DbSkip()) // não vai
					LOOP
//					endif
				endif

				// tipo de agenda
				VC5->(DbSetOrder(1))
				If !Empty(VC1->VC1_TIPAGE)
					VC5->(MsSeek( xFilial('VC5') + VC1->VC1_TIPAGE ))
					cVC5Recno := STR(VC5->(Recno()))
				else
					cVC5Recno := "null"
				EndIf

				// tipo de contato
				VC0->(DbSetOrder(1))
				If !Empty(VC1->VC1_TIPCON)
					VC0->(MsSeek( xFilial('VC0') + VC1->VC1_TIPCON ))
					cVC0Recno := STR(VC0->(Recno()))
				else
					cVC0Recno := "null"
				EndIf

				// tipo de abordagem
				VCA->(DbSetOrder(1))
				If !Empty(VC1->VC1_CODABO)
					VCA->(MsSeek( xFilial('VCA') + VC1->VC1_CODABO ))
					cVCARecno := STR(VCA->(Recno()))
				else
					cVCARecno := "null"
				EndIf

				if ! Empty(VC1->VC1_CODCLI)
					SA1->(DbSetOrder(1))
					SA1->(MsSeek( xFilial("SA1") + VC1->VC1_CODCLI + VC1->VC1_LOJA ))
					lPros := .F.
				Else
					SUS->(DbSetOrder(1))
					SUS->(MsSeek( xFilial("SUS") + VC1->VC1_CDPROS + VC1->VC1_LJPROS ))
					lPros := .T.
				EndIf

				if(lFirst) // primeiro?
					lFirst := .F.
				else
					cJson += ',' // separa os itens do SetArray
				EndIf

				cJson += ' {'
				cJson += '"recno":' + STR(VC1->(Recno())) + ','
				cJson += '"recno_tipo_agenda":' + cVC5Recno + ','
				cJson += '"recno_tipo_contato":' + cVC0Recno + ','
				cJson += '"recno_tipo_abordagem":' + cVCARecno + ','
				cJson += '"recno_cliente":' +STR(  IIF(lPros, SUS->(recno()), SA1->(recno()))  ) + ','
				cJson += '"objetivo":"' + WSCEV001_ConcatJson( FS_StoJS(ALLTRIM(E_MSMM(VC1->VC1_OBSOBJ,TamSx3("VC1_OBJETI")[1]))) ) + '",'
				cJson += '"ocorrencia":"' + WSCEV001_ConcatJson( FS_StoJS(ALLTRIM(E_MSMM(VC1->VC1_OCOMEM,TamSx3("VC1_OCORRE")[1]))) ) + '",'
				cJson += '"dt_agenda":"' + FS_DtoJS(VC1->VC1_DATAGE) + '",'
				cJson += '"dt_abordagem":"' + FS_DtoJS(VC1->VC1_DATVIS) + '",'
				cJson += '"nome_contato":"' + WSCEV001_ConcatJson(VC1->VC1_NOMCON) + '", '
				if lPros
					cJson += '"is_prospect": true '
				else
					cJson += '"is_prospect": false '
				endif
				cJson += ' }'

			Next
			cJson  += '] }'
		else
			cJson := ' { "error" : "Cpf não econtrado" } '
		endIf
		SA3->(DbSetOrder(1))


		::RESP := cJson
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf

	::RESP := NOACENTO(::RESP)
Return .T.

WSMETHOD GtPAgendas WSRECEIVE cCpfSeller, cAToken, nOFFSET, nQUANT  WSSEND RESP WSSERVICE CEV
	Local cJson := '{ "agendas" : ['
	Local lFirst := .T.
	Local oSqlHlp := DMS_SqlHelper():New()
	Local cQuery
	Local nIdx := 1

	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		// POG
		INCLUI     := .F.
		ALTERA     := .F.
		VISUALIZA  := .T.
		// END POG

		if FS_FndCpf(cCpfSeller)

			cQuery := ""
			cQuery += " SELECT R_E_C_N_O_  as recno FROM " + oSqlHlp:NoLock('VC1')
			cQuery += "  WHERE VC1_FILIAL = '"+xFilial('VC1')+"' AND VC1_CODVEN = '"+SA3->A3_COD+"' "
			cQuery += "    AND (VC1_DATVIS = '' OR VC1_DATAGE >= '"+DTOS(dDatabase-30)+"') AND D_E_L_E_T_ = ' ' "
			cQuery += " ORDER BY R_E_C_N_O_ OFFSET "+STR(nOFFSET)+" ROWS FETCH NEXT "+STR(nQUANT)+" ROWS ONLY "
			aRecnos := oSqlHlp:GetSelect({;
				{'campos', {'recno'}},;
				{'query' , cQuery } ;
			})

			For nIdx := 1 to LEN(aRecnos)
				VC1->(DbGoTo(aRecnos[nIdx]:GetValue('recno')))

				// tipo de agenda
				VC5->(DbSetOrder(1))
				If !Empty(VC1->VC1_TIPAGE)
					VC5->(MsSeek( xFilial('VC5') + VC1->VC1_TIPAGE ))
					cVC5Recno := STR(VC5->(Recno()))
				else
					cVC5Recno := "null"
				EndIf

				// tipo de contato
				VC0->(DbSetOrder(1))
				If !Empty(VC1->VC1_TIPCON)
					VC0->(MsSeek( xFilial('VC0') + VC1->VC1_TIPCON ))
					cVC0Recno := STR(VC0->(Recno()))
				else
					cVC0Recno := "null"
				EndIf

				// tipo de abordagem
				VCA->(DbSetOrder(1))
				If !Empty(VC1->VC1_CODABO)
					VCA->(MsSeek( xFilial('VCA') + VC1->VC1_CODABO ))
					cVCARecno := STR(VCA->(Recno()))
				else
					cVCARecno := "null"
				EndIf

				if ! Empty(VC1->VC1_CODCLI)
					SA1->(DbSetOrder(1))
					SA1->(MsSeek( xFilial("SA1") + VC1->VC1_CODCLI + VC1->VC1_LOJA ))
					lPros := .F.
				Else
					SUS->(DbSetOrder(1))
					SUS->(MsSeek( xFilial("SUS") + VC1->VC1_CDPROS + VC1->VC1_LJPROS ))
					lPros := .T.
				EndIf

				if(lFirst) // primeiro?
					lFirst := .F.
				else
					cJson += ',' // separa os itens do SetArray
				EndIf

				cJson += ' {'
				cJson += '"recno":' + STR(VC1->(Recno())) + ','
				cJson += '"recno_tipo_agenda":' + cVC5Recno + ','
				cJson += '"recno_tipo_contato":' + cVC0Recno + ','
				cJson += '"recno_tipo_abordagem":' + cVCARecno + ','
				cJson += '"recno_cliente":' +STR(  IIF(lPros, SUS->(recno()), SA1->(recno()))  ) + ','
				cJson += '"objetivo":"' + WSCEV001_ConcatJson( FS_StoJS(ALLTRIM(E_MSMM(VC1->VC1_OBSOBJ,TamSx3("VC1_OBJETI")[1]))) ) + '",'
				cJson += '"ocorrencia":"' + WSCEV001_ConcatJson( FS_StoJS(ALLTRIM(E_MSMM(VC1->VC1_OCOMEM,TamSx3("VC1_OCORRE")[1]))) ) + '",'
				cJson += '"dt_agenda":"' + FS_DtoJS(VC1->VC1_DATAGE) + '",'
				cJson += '"dt_abordagem":"' + FS_DtoJS(VC1->VC1_DATVIS) + '",'
				cJson += '"nome_contato":"' + WSCEV001_ConcatJson(VC1->VC1_NOMCON) + '", '
				if lPros
					cJson += '"is_prospect": true '
				else
					cJson += '"is_prospect": false '
				endif
				cJson += ' }'

			Next
			cJson  += '] }'
		else
			cJson := ' { "error" : "Cpf não econtrado" } '
		endIf
		SA3->(DbSetOrder(1))


		::RESP := cJson
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf

	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GtServerStatus
	Retorna um status simples para verificar se o servidor esta acessivel

	@author Vinicius Gati
	@since 14/01/2015

	@return json, retorna os tipos de agenda em formato json

/*/
WSMETHOD GtServerStatus WSRECEIVE NULLPARAM WSSEND RESP WSSERVICE CEV
	::RESP := "{ 'status' : 'ok', 'version' : '1.0.9' }"
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GtTpAgenda
	Retorna uma lista de tipos de agenda

	@author Vinicius Gati
	@since 14/01/2015

	@return json, retorna os tipos de agenda em formato json

/*/
WSMETHOD GtTpAgenda     WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE CEV
	Local cJson := '{ "tipos_agenda" : ['
	Local lFirst := .T.

	FS_StFilial(cCpfSeller)

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)

		VC5->(DbSetOrder(1))
		VC5->(MsSeek(xFilial('VC5')))
		While !VC5->(EOF()) .and. VC5->VC5_FILIAL == xFilial("VC5")
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cJson += ' { "recno": ' + STR(VC5->(recno())) + ', "description": "' + VC5->VC5_DTPAGE + '" } '
			VC5->(DbSkip())
		End
		cJson  += '] }'

		::RESP := cJson
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GtTpAbordagem
	Retorna uma lista de tipos de abordagem

	@author Vinicius Gati
	@since 14/01/2015

	@return json, retorna os tipos de abordagem em formato json

/*/
WSMETHOD GtTpAbordagem  WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE CEV
	Local cJson := '{ "tipos_abordagem" : ['
	Local lFirst := .T.

	FS_StFilial(cCpfSeller)

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		VCA->(DbSetOrder(1))
		VCA->(MsSeek(xFilial('VCA')))
		While !VCA->(EOF())  .and. VCA->VCA_FILIAL == xFilial("VCA")
				if(lFirst) // primeiro?
					lFirst := .F.
				else
					cJson += ',' // separa os itens do SetArray
				EndIf
			cJson += ' { "recno": ' + STR(VCA->(recno())) + ', "description": "' + ALLTRIM(VCA->VCA_DESABO) + '" } '
			VCA->(DbSkip())
		End
		cJson  += '] }'

		::RESP := cJson
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GtTpContato
	Retorna uma lista de tipos de contato

	@author Vinicius Gati
	@since 14/01/2015

	@return json, retorna os tipos de contato em formato json

/*/
WSMETHOD GtTpContato WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE CEV
	Local cJson := '{ "tipos_contato" : ['
	Local lFirst := .T.

	FS_StFilial(cCpfSeller)

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		VC0->(DbSetOrder(1))
		VC0->(MsSeek( xFilial('VC0') ))
		While !VC0->(EOF()) .and. VC0->VC0_FILIAL == xFilial("VC0")
			if(lfirst) // primeiro?
				lfirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cJson += ' { "recno": ' + STR(VC0->(recno())) + ', "description": "' + ALLTRIM(VC0->VC0_DESCON) + '" } '
			VC0->(DbSkip())
		End
		cJson  += '] }'

		::RESP := cJson
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GtRnoClis
	Retorna uma lista de recnos de todos os clientes associados ao vendedor

	@author Vinicius Gati
	@since 14/01/2015

	@return json, retorna os clientes em formato json

/*/
WSMETHOD GtRnoClis WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE CEV
	Local cJson := '{ "recnos" : ['
	Local lFirst := .T.
	Local cQuery := ""
	Local cAlQ := GetnextAlias()
	FS_StFilial(cCpfSeller)

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		if FS_FndCpf(cCpfSeller)
			cCodVen := SA3->A3_COD
		else
			::RESP := ' { "error" : "Cpf não econtrado" } '
			::RESP := NOACENTO(::RESP)
			Return .T.
		endIf
		SA3->(DbSetOrder(1))
		lFirst := .T.

		cQuery += "  SELECT DISTINCT * FROM ("
		cQuery += "  SELECT SA1.R_E_C_N_O_ as RECNO "
		cQuery += "    FROM "+RetSqlName('SA1')+" SA1, "+RetSqlName('VCF')+" VCF "
		cQuery += "   WHERE SA1.A1_COD = VCF.VCF_CODCLI               "
		cQuery += "     AND SA1.A1_FILIAL  = '" + xFilial('SA1') + "' "
		cQuery += "     AND VCF.VCF_FILIAL = '" + xFilial('VCF') + "' "
		cQuery += "     AND                                           "
		cQuery += "      (   VCF.VCF_VENPEC = '"+ cCodVen  +"'        "
		cQuery += "     OR   VCF.VCF_VENVEI = '"+ cCodVen  +"'        "
		cQuery += "     OR   VCF.VCF_VENSRV = '"+ cCodVen  +"'        "
		cQuery += "      )                                            "
		cQuery += " Union ALL "
		cQuery += "  SELECT SA1.R_E_C_N_O_ as RECNO "
		cQuery += "    FROM "+RetSqlName('SA1')+" SA1, "+RetSqlName('VC1')+" VC1 "
		cQuery += "   WHERE SA1.A1_COD      = VC1_CODCLI                         "
		cQuery += "     AND SA1.A1_FILIAL   = '" + xFilial('SA1') + "'           "
		cQuery += "     AND VC1.VC1_FILIAL  = '" + xFilial('VC1') + "'           "
		cQuery += "     AND VC1.VC1_CODVEN  = '"+ cCodVen  +"'                   "
		cQuery += " Union ALL "
		cQuery += "  SELECT SA1.R_E_C_N_O_ as RECNO "
		cQuery += "    FROM "+RetSqlName('SA1')+" SA1 "
		cQuery += "   WHERE SA1.A1_FILIAL   = '" + xFilial('SA1') + "' "
		cQuery += "     AND SA1.A1_COD in (select VDL_CODCLI from "+RetSqlName('VDM')+" VDM, "+RetSqlName('VDL')+" VDL WHERE VDL.VDL_CODOPO = VDM_CODOPO AND VDM.VDM_CODVEN = '"+cCodVen+"' AND VDM.D_E_L_E_T_ = ' ' AND VDL.D_E_L_E_T_ = ' ' )"
		cQuery += " ) SA1 GROUP BY SA1.RECNO "
		dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAlQ , .F., .T. )

		(cAlQ)->(DbGoTop())
		While !(cAlQ)->(EOF())
			cJson += IIF(lFirst, '', ',')

			cJson += '' + ALLTRIM(STR((cAlQ)->RECNO)) + ''

			lFirst := .F.
			(cAlQ)->(DbSkip())
		End
		(cAlQ)->(dbCloseArea())

		cJson  += '] }'
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := cJson
Return .T.

/*/{Protheus.doc} GtClientes
	Retorna uma lista de clientes associados ao cpf do vendeddor

	@author Vinicius Gati
	@since 14/01/2015

	@return json, retorna os clientes em formato json

/*/
WSMETHOD GtClientes WSRECEIVE cCpfSeller, cRnos, cAToken WSSEND RESP WSSERVICE CEV
	Local cJson := '{ "clientes" : ['
	Local lFirst := .T.
	Local cQuery := ""
	Local cAlQ   := "Customers"
	DEFAULT cRnos := ""

	FS_StFilial(cCpfSeller)

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		if FS_FndCpf(cCpfSeller)
			cCodVen := SA3->A3_COD
		else
			::RESP := ' { "error" : "Cpf não econtrado" } '
			::RESP := NOACENTO(::RESP)
			Return .T.
		endIf
		SA3->(DbSetOrder(1))
		lFirst := .T.
		// segurança
		cRnos := StrTran(cRnos, '/', ',')
		cRnos := StrTran(cRnos, '*', ',')
		cRnos := StrTran(cRnos, '-', ',')
		cRnos := StrTran(cRnos, '#', ',')

		cQuery += "  SELECT DISTINCT * FROM ("
		cQuery += "  SELECT A1_END, A1_MUN, A1_EST, SA1.A1_COD, SA1.A1_LOJA, SA1.R_E_C_N_O_ as RECNO, SA1.A1_CGC, SA1.A1_NOME, SA1.A1_DDD, SA1.A1_TEL "
		cQuery += "    FROM "+RetSqlName('SA1')+" SA1, "+RetSqlName('VCF')+" VCF "
		cQuery += "   WHERE SA1.A1_COD = VCF.VCF_CODCLI                       "
		cQuery += "     AND SA1.A1_FILIAL  = '" + xFilial('SA1') + "'         "
		cQuery += "     AND VCF.VCF_FILIAL = '" + xFilial('VCF') + "'         "
		cQuery += "     AND                                                   "
		cQuery += "      (   VCF.VCF_VENPEC = '"+ cCodVen  +"'                "
		cQuery += "     OR   VCF.VCF_VENVEI = '"+ cCodVen  +"'                "
		cQuery += "     OR   VCF.VCF_VENSRV = '"+ cCodVen  +"'                "
		cQuery += "      )                                                    "
		cQuery += " Union ALL "
		cQuery += "  SELECT A1_END, A1_MUN, A1_EST, SA1.A1_COD, SA1.A1_LOJA, SA1.R_E_C_N_O_ as RECNO, SA1.A1_CGC, SA1.A1_NOME, SA1.A1_DDD, SA1.A1_TEL "
		cQuery += "    FROM "+RetSqlName('SA1')+" SA1, "+RetSqlName('VC1')+" VC1                                       "
		cQuery += "   WHERE SA1.A1_COD      = VC1_CODCLI                                                               "
		cQuery += "     AND SA1.A1_FILIAL   = '" + xFilial('SA1') + "'                                                 "
		cQuery += "     AND VC1.VC1_FILIAL  = '" + xFilial('VC1') + "'                                                 "
		cQuery += "     AND VC1.VC1_CODVEN  = '"+ cCodVen  +"'                                                         "
		cQuery += " Union ALL "
		cQuery += "  SELECT A1_END, A1_MUN, A1_EST, SA1.A1_COD, SA1.A1_LOJA, SA1.R_E_C_N_O_ as RECNO, SA1.A1_CGC, SA1.A1_NOME, SA1.A1_DDD, SA1.A1_TEL "
		cQuery += "    FROM "+RetSqlName('SA1')+" SA1 "
		cQuery += "   WHERE SA1.A1_FILIAL   = '" + xFilial('SA1') + "' "
		cQuery += "     AND SA1.A1_COD in (select VDL_CODCLI from "+RetSqlName('VDM')+" VDM, "+RetSqlName('VDL')+" VDL WHERE VDL.VDL_CODOPO = VDM_CODOPO AND VDM.VDM_CODVEN = '"+cCodVen+"' AND VDM.D_E_L_E_T_ = ' ' AND VDL.D_E_L_E_T_ = ' ' )"
		cQuery += " ) SA1 "
		If ! Empty(cRnos)
			cQuery += " WHERE RECNO IN ("+cRnos+") "
		EndIf
		cQuery += "GROUP BY A1_END, A1_MUN, A1_EST, SA1.A1_COD, SA1.A1_LOJA, SA1.RECNO, SA1.A1_CGC, SA1.A1_NOME, SA1.A1_DDD, SA1.A1_TEL "
		dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAlQ , .F., .T. )

		(cAlQ)->(DbGoTop())
		While !(cAlQ)->(EOF())
			cJson += IIF(lFirst, '', ',')
			nLatitu := 0
			nLongit := 0
			SA1->(dbGoTo((cAlQ)->RECNO))
			DbSelectArea('VCF')
			if dbSeek(xFilial('VCF') + SA1->A1_COD + SA1->A1_LOJA)
				if VCF->(FieldPos('VCF_LATITU')) > 0
					nLatitu := VCF->VCF_LATITU
					nLongit := VCF->VCF_LONGIT
				end
			end

			cJson += ' { "recno": ' + WSCEV001_ConcatJson(STR((cAlQ)->RECNO)) + ;
				', "document": "' + WSCEV001_ConcatJson((cAlQ)->A1_CGC) + '"' + ;
				', "_endereco": "' + WSCEV001_ConcatJson((cAlQ)->A1_END) + '"' + ;
				', "_cidade": "' + WSCEV001_ConcatJson((cAlQ)->A1_MUN) + '"' + ;
				', "_estado": "' + WSCEV001_ConcatJson((cAlQ)->A1_EST) + '"' + ;
				', "name" : "(' + WSCEV001_ConcatJson(SA1->A1_LOJA) + ") " + WSCEV001_ConcatJson((cAlQ)->A1_NOME) + '"' +;
				', "_latitude" : "' + WSCEV001_ConcatJson(STR(nLatitu)) + '", "_longitude" : "' + WSCEV001_ConcatJson(STR(nLongit)) + '" '+;
				', "phone_number" : "' + FS_PtoJS((cAlQ)->A1_DDD, (cAlQ)->A1_TEL) + '", "is_prospect": false }'

			lFirst := .F.
			(cAlQ)->(DbSkip())
		End
		(cAlQ)->(dbCloseArea())

		cJson  += '] }'
		// VCF
		::RESP := cJson

	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GtProspects
	Retorna uma lista de prospects

	@author Vinicius Gati
	@since 27/09/2016

	@return json, retorna os prospects em formato json

/*/
WSMETHOD GtProspects WSRECEIVE cCpfSeller, cAToken  WSSEND RESP WSSERVICE CEV
	Local cJson := '{ "prospects" : ['
	Local cQuery := ""
	Local cAlQ   := "Prospects"
	Local lFirst := .T.

	FS_StFilial(cCpfSeller)

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		if FS_FndCpf(cCpfSeller)
			cCodVen := SA3->A3_COD
		else
			::RESP := ' { "error" : "Cpf não econtrado" } '
			Return .T.
		endIf
		SA3->(DbSetOrder(1))

		cQuery += "  SELECT US_EST, US_END, US_MUN, US_NOME, US_CGC, US_COD, US_LOJA, US_DDD, US_TEL, R_E_C_N_O_ as RECNO "
		if SUS->(FieldPos('US_XLATITU')) > 0
			cQuery += ", US_XLATITU, US_XLONGIT "
		end
		cQuery += "     FROM "+RetSqlName('SUS')+" SUS "
		cQuery += "    WHERE US_FILIAL = '"+xFilial("SUS")+"' AND D_E_L_E_T_ =' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAlQ , .F., .T. )

		(cAlQ)->(DbGoTop())
		While !(cAlQ)->(EOF())
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cJson += ' { "recno": ' + WSCEV001_ConcatJson(STR((cAlQ)->RECNO))
			cJson += ', "document": "' + WSCEV001_ConcatJson((cAlQ)->US_CGC) + '"'
			cJson += ', "_endereco": "' + WSCEV001_ConcatJson((cAlQ)->US_END) + '"'
			cJson += ', "_cidade": "' + WSCEV001_ConcatJson((cAlQ)->US_MUN) + '"'
			cJson += ', "_estado": "' + WSCEV001_ConcatJson((cAlQ)->US_EST) + '"'
			cJson += ', "name" : "(' + (cAlQ)->US_LOJA + ") " + WSCEV001_ConcatJson((cAlQ)->US_NOME) + '"'
			cJson += ', "phone_number" : "' + FS_PtoJS((cAlQ)->US_DDD, (cAlQ)->US_TEL) + '" '
			if SUS->(FieldPos('US_XLATITU')) > 0
				cJson += ', "_latitude" : "' + WSCEV001_ConcatJson(STR((cAlQ)->US_XLATITU)) + '", "_longitude" : "' + WSCEV001_ConcatJson(STR((cAlQ)->US_XLONGIT)) + '" '
			end
			cJson += ', "is_prospect": true } '

			(cAlQ)->(DbSkip())
		End
		(cAlQ)->(dbCloseArea())

		cJson += "]}"
		// VCF
		::RESP := cJson
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GtPProspects
	Retorna uma lista de prospects

	@author Vinicius Gati
	@since 27/09/2016

	@return json, retorna os prospects em formato json

/*/
WSMETHOD GtPProspects WSRECEIVE cCpfSeller, cAToken, nOFFSET, nQUANT  WSSEND RESP WSSERVICE CEV
	Local cJson := '{ "prospects" : ['
	Local cQuery := ""
	Local cAlQ   := "Prospects"
	Local lFirst := .T.

	if nQUANT > 100
		nQUANT := 100
	endIf

	FS_StFilial(cCpfSeller)

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		if FS_FndCpf(cCpfSeller)
			cCodVen := SA3->A3_COD
		else
			::RESP := ' { "error" : "Cpf não econtrado" } '
			Return .T.
		endIf
		SA3->(DbSetOrder(1))

		cQuery += "  SELECT US_EST, US_END, US_MUN, US_NOME, US_CGC, US_COD, US_LOJA, US_DDD, US_TEL, R_E_C_N_O_ as RECNO "
		if SUS->(FieldPos('US_XLATITU')) > 0
			cQuery += ", US_XLATITU, US_XLONGIT "
		end
		cQuery += "     FROM "+RetSqlName('SUS')+" SUS "
		cQuery += "    WHERE US_FILIAL = '"+xFilial("SUS")+"' AND D_E_L_E_T_ =' ' "
		cQuery += " ORDER BY R_E_C_N_O_ OFFSET "+STR(nOFFSET)+" ROWS FETCH NEXT "+STR(nQUANT)+" ROWS ONLY "
		dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAlQ , .F., .T. )

		(cAlQ)->(DbGoTop())
		While !(cAlQ)->(EOF())
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cJson += ' { "recno": ' + WSCEV001_ConcatJson(STR((cAlQ)->RECNO))
			cJson += ', "document": "' + WSCEV001_ConcatJson((cAlQ)->US_CGC) + '"'
			cJson += ', "_endereco": "' + WSCEV001_ConcatJson((cAlQ)->US_END) + '"'
			cJson += ', "_cidade": "' + WSCEV001_ConcatJson((cAlQ)->US_MUN) + '"'
			cJson += ', "_estado": "' + WSCEV001_ConcatJson((cAlQ)->US_EST) + '"'
			cJson += ', "name" : "(' + (cAlQ)->US_LOJA + ") " + WSCEV001_ConcatJson((cAlQ)->US_NOME) + '"'
			cJson += ', "phone_number" : "' + FS_PtoJS((cAlQ)->US_DDD, (cAlQ)->US_TEL) + '" '
			if SUS->(FieldPos('US_XLATITU')) > 0
				cJson += ', "_latitude" : "' + WSCEV001_ConcatJson(STR((cAlQ)->US_XLATITU)) + '", "_longitude" : "' + WSCEV001_ConcatJson(STR((cAlQ)->US_XLONGIT)) + '" '
			end
			cJson += ', "is_prospect": true } '

			(cAlQ)->(DbSkip())
		End
		(cAlQ)->(dbCloseArea())

		cJson += "]}"
		// VCF
		::RESP := cJson
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.


/*/{Protheus.doc} GtCliente
	Retorna uma lista de clientes associados ao cpf do vendeddor

	@author Vinicius Gati
	@since 14/01/2015

	@return json, retorna os clientes em formato json

/*/
WSMETHOD GtCliente WSRECEIVE cCpfSeller, cRnoCust, cAToken WSSEND RESP WSSERVICE CEV
	Local cJson := '{ "cliente" : '
	Local cQuery := ""
	Local cAlQ   := "Customers"

	FS_StFilial(cCpfSeller)

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		if FS_FndCpf(cCpfSeller)
			cCodVen := SA3->A3_COD
		else
			::RESP := ' { "error" : "Cpf não econtrado" } '
			Return .T.
		endIf
		SA3->(DbSetOrder(1))

		cQuery += "  SELECT A1_END, A1_MUN, A1_EST, SA1.A1_COD, SA1.A1_LOJA, SA1.R_E_C_N_O_ as RECNO, SA1.A1_CGC, SA1.A1_NOME, SA1.A1_DDD, SA1.A1_TEL "
		cQuery += "    FROM "+RetSqlName('SA1')+" SA1 "
		cQuery += "   WHERE R_E_C_N_O_ = " + ALLTRIM(cRnoCust)
		dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAlQ , .F., .T. )

		(cAlQ)->(DbGoTop())
		While !(cAlQ)->(EOF())
			cJson += ' { "recno": ' + WSCEV001_ConcatJson(STR((cAlQ)->RECNO)) + ;
				', "_endereco": "' + WSCEV001_ConcatJson((cAlQ)->A1_END) + '"' + ;
				', "_cidade": "' + WSCEV001_ConcatJson((cAlQ)->A1_MUN) + '"' + ;
				', "_estado": "' + WSCEV001_ConcatJson((cAlQ)->A1_EST) + '"' + ;
				', "document": "' + WSCEV001_ConcatJson((cAlQ)->A1_CGC) + '"' + ;
				', "name" : "(' + A1_LOJA + ") " + WSCEV001_ConcatJson(STRTRAN((cAlQ)->A1_NOME, '"', "'")) + '"' +;
				', "phone_number" : "' + FS_PtoJS((cAlQ)->A1_DDD, (cAlQ)->A1_TEL) + '", "is_prospect": false }'
			(cAlQ)->(DbSkip())
		End
		(cAlQ)->(dbCloseArea())

		cJson += "}"
		// VCF
		::RESP := cJson
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GtProspect
	Retorna uma lista de prospects

	@author Vinicius Gati
	@since 27/09/2016

	@return json, retorna os prospects em formato json

/*/
WSMETHOD GtProspect WSRECEIVE cCpfSeller, cRnoCust, cAToken WSSEND RESP WSSERVICE CEV
	Local cJson := '{ "prospect" : '
	Local cQuery := ""
	Local cAlQ   := "Prospect"

	FS_StFilial(cCpfSeller)

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		if FS_FndCpf(cCpfSeller)
			cCodVen := SA3->A3_COD
		else
			::RESP := ' { "error" : "Cpf não econtrado" } '
			Return .T.
		endIf
		SA3->(DbSetOrder(1))

		cQuery += "  SELECT US_NOME, US_CGC, US_COD, US_END, US_MUN, US_EST, US_LOJA, US_DDD, US_TEL, R_E_C_N_O_ as RECNO "
		cQuery += "    FROM "+RetSqlName('SUS')+" SUS "
		cQuery += "   WHERE R_E_C_N_O_ = " + ALLTRIM(cRnoCust) + " AND D_E_L_E_T_ = ' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAlQ , .F., .T. )

		(cAlQ)->(DbGoTop())
		While !(cAlQ)->(EOF())
			cJson += ' { "recno": ' + WSCEV001_ConcatJson(STR((cAlQ)->RECNO)) + ;
				', "document": "' + WSCEV001_ConcatJson((cAlQ)->US_CGC) + '"' + ;
				', "_endereco": "' + WSCEV001_ConcatJson((cAlQ)->US_END) + '"' + ;
				', "_cidade": "' + WSCEV001_ConcatJson((cAlQ)->US_MUN) + '"' + ;
				', "_estado": "' + WSCEV001_ConcatJson((cAlQ)->US_EST) + '"' + ;
				', "name" : "(' + (cAlQ)->US_LOJA + ") " + WSCEV001_ConcatJson((cAlQ)->US_NOME) + '"' +;
				', "phone_number" : "' + FS_PtoJS((cAlQ)->US_DDD, (cAlQ)->US_TEL) + '", "is_prospect": true }'
			(cAlQ)->(DbSkip())
		End
		(cAlQ)->(dbCloseArea())

		cJson += "}"
		// VCF
		::RESP := cJson
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.


/*/{Protheus.doc} GTTOKENACESSO
	Cria e retorna um token de acesso

	@author Vinicius Gati
	@since 14/01/2015

	@return String, 32 caracteres MD5 com salt

/*/
WSMETHOD GTTOKENACESSO WSRECEIVE cCpfSeller WSSEND RESP WSSERVICE CEV
	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	cToken := oToken:Gerar()
	::RESP := ' { "token" : "' + cToken + '" } '
Return .T.

/*/{Protheus.doc} Mil_Token

	@author       Vinicius Gati
	@since        14/01/2015
	@description  Da manutenção nos tokens de acesso para ftp(tabela VQF)
/*/
Class Mil_Token
	Data salt

	Method New() CONSTRUCTOR
	Method Gerar()
	Method Busca()
EndClass

/*/{Protheus.doc} New
	Construtor simples
	@author Vinicius Gati
	@since 14/01/2015
/*/
Method New() Class Mil_Token
	::salt := "83a800deec1930f65f82cfc478041784#@!123!MILMOBILE!123!@#83a800deec1930f65f82cfc478041784"
Return SELF

/*/{Protheus.doc} Gerar
	Gera um token de acesso e grava no banco com dados de expiracao

	@author Vinicius Gati
	@since 14/01/2015

	@return VQF_ATOKEN, token gerado
/*/
Method Gerar() Class Mil_Token
	Local nHora := 0
	Local nMinu := 0
	Local nRes  := 0

	DbselectArea('VQF')
	RecLock( "VQF", .T. ) // novo
	VQF->VQF_FILIAL := xFilial('VQF')
	VQF->VQF_CODIGO := GETSXENUM('VQF', 'VQF_CODIGO')
	VQF->VQF_ATOKEN := MD5( DTOS(DATE()) + TIME() + CVALTOCHAR( SECONDS() ) + self:salt )
	VQF->VQF_DTAEXP := DATE()


	nHora := VAL(STRTRAN( LEFT( TIME(), 2 ), ':', ''))
	nMinu := VAL(RIGHT( STRTRAN( LEFT( TIME(), 5 ), ':', '') , 2))
	// somar 25 segundos a hora
	nMinu += 5
	nRes := nMinu - 60 // logica para deixar base 60 e mudar a hora
	if nRes > 0
		nHora += 1
		nMinu := nRes
	endif

	VQF->VQF_HOREXP := VAL( STRTRAN(TRANSFORM(nHora, "@R 99"), " ", "0") + STRTRAN(TRANSFORM(nMinu, "@R 99"), " ", "0") )
	VQF->VQF_STATUS := 'AGUARDA_USO'
	VQF->(MsUnLock())
	CONFIRMSX8()

Return VQF->VQF_ATOKEN

/*/{Protheus.doc} Busca
	Busca um token de acesso válido, não expirado.

	@author Vinicius Gati
	@since 14/01/2015

	@return Boolean, true se encontrou e false se não
/*/
Method Busca(cTokenRecebido) Class Mil_Token
	Local cTime   := TIME()
	Local dDate   := DATE()
	Local cHora   := STRTRAN( LEFT( cTime, 2 ), ':', '')
	Local cMinu   := RIGHT( STRTRAN( LEFT( cTime, 5 ), ':', '') , 2)
	Local nOk     := .F.
	Local cSQLVQF := "aliasVQF"

	cQuery := "SELECT * FROM " + RetSqlName('VQF') + " VQF WHERE D_E_L_E_T_ = ' ' AND VQF.VQF_FILIAL = '" + xFilial('VQF') + "' "
	cQuery += " AND VQF.VQF_HOREXP >= " + cHora + cMinu + " AND VQF.VQF_DTAEXP = '" + DTOS(dDate) + "' AND VQF.VQF_STATUS = 'AGUARDA_USO' "
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cSQLVQF , .F., .T. )
	(cSQLVQF)->(DbGoTop())
	While !(cSQLVQF)->(EOF())
		if cTokenRecebido == md5( (cSQLVQF)->VQF_ATOKEN + self:salt )
			VQF->(MsSeek( xFilial('VQF') + (cSQLVQF)->VQF_CODIGO ))
			RecLock( "VQF", .F. ) // novo
			VQF->VQF_STATUS = "USADO"
			MsUnLock()
			nOk := .T.
			EXIT
		endif
		(cSQLVQF)->(DbSkip())
	End
	(cSQLVQF)->(dbCloseArea())

Return nOk



/*/{Protheus.doc} GTVeiCores
	Retorna as cores de veiculos para MIL - Mobile

	@author Vinicius Gati
	@since 09/01/2015

/*/
WSMETHOD GTVeiCores  WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE OPORT
	Local cJson := '{ "cores_veiculos" : ['
	Local lFirst := .T.

	FS_StFilial(cCpfSeller)

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)

		VVC->(DbSetOrder(1))
		VVC->(MsSeek(xFilial('VVC')))
		While !VVC->(EOF()) .and. VVC->VVC_FILIAL == xFilial("VVC")
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cRecnoMar := FM_SQL(" SELECT R_E_C_N_O_ FROM " + RetSqlName('VE1') + " WHERE VE1_FILIAL = '" + xFilial('VE1') + "' AND VE1_CODMAR = '"+ VVC->VVC_CODMAR +"' " )

			cJson += ' { "recno": ' + STR(VVC->(recno())) + ', "description": "' + VVC->VVC_DESCRI + '", "recno_marca": "' +STR(cRecnoMar)+ '" } '
			VVC->(DbSkip())
		End
		cJson  += '] }'
		::RESP := cJson

	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GTMotCanc
	Retorna os motivos de cancelamento para MIL - Mobile area de oportunidades/interesses

	@author Vinicius Gati
	@since 09/01/2015

/*/
WSMETHOD GTMotCanc   WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE OPORT
	Local cJson := '{ "motivos_cancelamento_oportunidade" : ['
	Local lFirst := .T.

	FS_StFilial(cCpfSeller)

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)

		VS0->(DbSetOrder(1))
		VS0->(MsSeek( xFilial('VS0') + '000011' ))
		While !VS0->(EOF()) .and. VS0->VS0_FILIAL == xFilial("VS0")
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cJson += ' { "recno": ' + STR(VS0->(recno())) + ', "description": "' + VS0->VS0_DESMOT + '" } '
			VS0->(DbSkip())
		End
		cJson  += '] }'
		::RESP := cJson

	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GTStFinan
	Retorna os status de financiamento para MIL - Mobile area de oportunidades/interesses

	@author Vinicius Gati
	@since 09/01/2015

/*/
WSMETHOD GTStFinan   WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE OPORT
	Local cJson     := '{ "status_financiamento" : ['
	Local lFirst    := .T.
	Local oFasesFin := Mil_FaseFinanciamento():New()
	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		VX5->(DbSetOrder(1))
		VX5->(MsSeek( xFilial('VX5') + oFasesFin:GetTbCode() ))
		While !VX5->(EOF()) .and. VX5->VX5_FILIAL == xFilial("VX5")  .and. VX5->VX5_CHAVE == oFasesFin:GetTbCode()
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cJson += ' { "recno": ' + STR(VX5->(recno())) + ', "description": "' + ALLTRIM(VX5->VX5_DESCRI) + '" } '
			VX5->(DbSkip())
		End
		cJson  += '] }'
		::RESP := cJson

	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GTCampanha
	Retorna as campanhas para MIL - Mobile area de oportunidades/interesses

	@author Vinicius Gati
	@since 09/01/2015

/*/
WSMETHOD GTCampanha  WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE OPORT
	Local cJson := '{ "campanhas" : ['
	Local lFirst := .T.
	Local oCampanha := Mil_Campanha():New()
	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		VX5->(DbSetOrder(1))
		VX5->(MsSeek( xFilial('VX5') + oCampanha:GetTbCode() ))
		While !VX5->(EOF()) .and. VX5->VX5_FILIAL == xFilial("VX5") .and. VX5->VX5_CHAVE == oCampanha:GetTbCode()
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cJson += ' { "recno": ' + STR(VX5->(recno())) + ', "description": "' + ALLTRIM(VX5->VX5_DESCRI) + '" } '
			VX5->(DbSkip())
		End


		cJson  += '] }'
		::RESP := cJson

	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GTMarcas
	Retorna as marcas para MIL - Mobile area de oportunidades/interesses

	@author Vinicius Gati
	@since 09/01/2015

/*/
WSMETHOD GTMarcas    WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE OPORT
	Local cJson := '{ "marcas" : ['
	Local lFirst := .T.

	FS_StFilial(cCpfSeller)

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)

		VE1->(DbSetOrder(1))
		VE1->(MsSeek(xFilial('VE1')))
		While !VE1->(EOF()) .and. VE1->VE1_FILIAL == xFilial("VE1")
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cJson += ' { "recno": ' + ALLTRIM(STR(VE1->(recno()))) + ', "description": "' + ALLTRIM(VE1->VE1_DESMAR) + '" } '
			VE1->(DbSkip())
		End
		VE1->(dbCloseArea())
		cJson  += '] }'

		::RESP := cJson

	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GTStInter
	Retorna os status dos interesses para o MIL - Mobile area de oportunidades/interesses

	@author Vinicius Gati
	@since 09/01/2015

/*/
WSMETHOD GTStInter  WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE OPORT
	Local cJson := '{ "status_interesse" : [' // fases de op. de negocios
	Local lFirst := .T.

	FS_StFilial(cCpfSeller)

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)

		VDK->(DbSetOrder(1))
		VDK->(MsSeek( xFilial('VDK') ))
		While !VDK->(EOF()) .and. VDK->VDK_FILIAL == xFilial("VDK")
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cFinal := iif(VDK->VDK_FIMFAS == "1", "true", "false")
			cObCli := iif(VDK->VDK_OBRCLI == "1", "true", "false")
			cJson += ' { "recno": ' + STR(VDK->(recno())) + ', "description": "' + WSCEV001_ConcatJson(VDK->VDK_DESFAS) ;
				+ '" , "final?": ' +cFinal+ ', "cliente_obrigatorio?": ' +cObCli+ ' } '
			VDK->(DbSkip())
		End
		cJson  += '] }'
		::RESP := cJson

	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.


/*/{Protheus.doc} GTModelos
	Retorna os modelos para o MIL - Mobile area de oportunidades/interesses

	@author Vinicius Gati
	@since 09/01/2015

/*/
WSMETHOD GtModelos  WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE OPORT
	Local cJson := '{ "modelos" : ['
	Local lFirst := .T.

	FS_StFilial(cCpfSeller)

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)

		VV2->(DbSetOrder(1))
		VV2->(MsSeek( xFilial('VV2') ))
		While !VV2->(EOF()) .and. VV2->VV2_FILIAL == xFilial("VV2")
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cRecnoMar := FM_SQL(" SELECT R_E_C_N_O_ FROM " + RetSqlName('VE1') + " WHERE VE1_FILIAL = '" + xFilial('VE1') + "' AND VE1_CODMAR = '"+ ALLTRIM(VV2->VV2_CODMAR) +"' AND D_E_L_E_T_ = ' ' " )
			cJson += ' { "recno": ' + WSCEV001_ConcatJson(STR(VV2->(recno()))) + ', "description": "' + WSCEV001_ConcatJson(VV2->VV2_DESMOD) + '", "recno_marca": "' + WSCEV001_ConcatJson(STR(cRecnoMar)) + '" } '
			VV2->(DbSkip())
		End
		VV2->(dbCloseArea())
		cJson  += '] }'

		::RESP := cJson

	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GtPModelos
	Retorna os modelos para o MIL - Mobile area de oportunidades/interesses

	@author Vinicius Gati
	@since 09/01/2015

/*/
WSMETHOD GtPModelos WSRECEIVE cCpfSeller, cAToken, nOFFSET, nQUANT WSSEND RESP WSSERVICE OPORT
	Local cJson := '{ "modelos" : ['
	Local lFirst := .T.
	Local cQuery := ""
	Local cAl := GetNextAlias()

	FS_StFilial(cCpfSeller)
	if nQUANT > 100
		nQUANT := 100
	end

	cQuery := "SELECT VV2_DESMOD, VV2.R_E_C_N_O_ recno_modelo, VE1.R_E_C_N_O_ recno_marca"
	cQuery += "  FROM " + RetSqlName('VV2') + " VV2 "
	cQuery += "  JOIN " + RetSqlName('VE1') + " VE1 ON VE1_FILIAL = '"+xFilial('VE1')+"' AND VE1_CODMAR = VV2_CODMAR AND VE1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VV2_FILIAL = '"+xFilial('VV2')+"' AND VV2.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY VV2.R_E_C_N_O_ OFFSET "+STR(nOFFSET)+" ROWS FETCH NEXT "+STR(nQUANT)+" ROWS ONLY "
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAl , .F., .T. )
	While !(cAl)->(EOF())
		if(lFirst) // primeiro?
			lFirst := .F.
		else
			cJson += ',' // separa os itens do SetArray
		EndIf
		cJson += ' { "recno": ' + STR((cAl)->(recno_modelo)) + ;
			', "description": "' + WSCEV001_ConcatJson((cAl)->VV2_DESMOD) + ;
			'", "recno_marca": ' + STR((cAl)->(recno_marca)) + ' } '
		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())

	cJson  += '] }'
	::RESP := NOACENTO(cJson)
Return .T.

/*/{Protheus.doc} GtBancos
	Retorna os bancos para o MIL - Mobile area de oportunidades/interesses

	@author Vinicius Gati
	@since 11/01/2015

/*/
WSMETHOD GtBancos  WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE OPORT
	Local cJson   := '{ "bancos" : ['
	Local lFirst  := .T.
	Local cQuery  := ""
	Local cAl     := "aSA6"

	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)

		cQuery := " SELECT DISTINCT R_E_C_N_O_ , A6_COD , A6_NOME FROM " + RetSqlName('SA6') + " SA6 WHERE SA6.D_E_L_E_T_ = ' ' AND SA6.A6_FILIAL = '" + xFilial('SA6') + "' "
		dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAl , .F., .T. )

		While !(cAl)->(EOF())
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cJson += ' { "recno": ' + ALLTRIM(STR((cAl)->(R_E_C_N_O_))) + ', "code": "' + ALLTRIM((cAl)->(A6_COD)) + '", "description": "' + ALLTRIM((cAl)->(A6_NOME)) + '" } '
			(cAl)->(DbSkip())
		End
		(cAl)->(dbCloseArea())

		cJson  += '] }'
		::RESP := cJson

	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.


/*/{Protheus.doc} GTLinCred
	Retorna as linhas de credito para o MIL - Mobile area de oportunidades/interesses

	@author Vinicius Gati
	@since 11/01/2015

/*/
WSMETHOD GTLinCred  WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE OPORT
	Local cJson    := '{ "linhas_credito" : ['
	Local lFirst   := .T.
	Local oLinCred := Mil_LinhasDeCredito():New()
	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		VX5->(DbSetOrder(1))
		VX5->(MsSeek( xFilial('VX5') + oLinCred:GetTbCode() ))
		While !VX5->(EOF()) .and. VX5->VX5_FILIAL == xFilial("VX5")  .and. VX5->VX5_CHAVE == oLinCred:GetTbCode()
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cJson += ' { "recno": ' + STR(VX5->(recno())) + ', "description": "' + ALLTRIM(VX5->VX5_DESCRI) + '" } '
			VX5->(DbSkip())
		End
		cJson  += '] }'
		::RESP := cJson

	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GTOports
	Retorna as oportunidades de negocios para o MIL - Mobile area de oportunidades/interesses

	@author Vinicius Gati
	@since 11/01/2015

/*/
WSMETHOD GTOports  WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE OPORT
	Local cJson  := '{ "oportunidades" : [ '
	Local lFirst := .T.
	Local oToken := nil
	Local cAlOpt := "hohoho"
	Local oArHlp := Mil_ArrayHelper():New()

	FS_StFilial(cCpfSeller)

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		aVDLCodes := FS_OptsSeller(cCpfSeller, "VDL_CODOPO")
		aVDLCodes := oArHlp:Map(aVDLCodes, { |code| "'" + ALLTRIM(code) + "'" })

		cQuery := "    SELECT VDL_TMPNEG, VDL_CODCLI, VDL_LOJCLI, VDL_NOMCLI, VDL_EMACLI , VDL_DDDCLI , VDL_TELCLI , VDL_CDPROS, VDL_LJPROS, R_E_C_N_O_ as codigo  "
		cQuery += "      FROM "+RetSqlName("VDL")+" VDL "
		cQuery += "     WHERE VDL.VDL_FILIAL = '"+xFilial("VDL")+"' "
		cQuery += "       AND VDL.D_E_L_E_T_ = ' ' "
		if LEN(aVDLCodes) > 0
			cQuery += "       AND VDL.VDL_CODOPO IN ("+oArHlp:Join(aVDLCodes, ',')+")"
		else
			cQuery += "       AND VDL.VDL_CODOPO IN (null)"
		endIf
		dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAlOpt , .F., .T. )
		While !(cAlOpt)->(EOF())

			if EMPTY( (cAlOpt)->VDL_CODCLI )
				SUS->(DbSetOrder(1))
				SUS->(MsSeek( xFilial('SUS') + (cAlOpt)->VDL_CDPROS + (cAlOpt)->VDL_LJPROS))
			else
				SA1->(DbSetOrder(1))
				SA1->(MsSeek( xFilial('SA1') + (cAlOpt)->VDL_CODCLI + (cAlOpt)->VDL_LOJCLI))
			Endif

			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf

			cJson += ' { "recno": ' + STR((cAlOpt)->(codigo)) + ', "customer_name": "' + WSCEV001_ConcatJson( (cAlOpt)->VDL_NOMCLI ) + '" , '
			cJson += ' "customer_email" : "' + WSCEV001_ConcatJson( (cAlOpt)->VDL_EMACLI ) + '" , '
			cJson += ' "customer_phone" : "' + FS_PtoJS( (cAlOpt)->VDL_DDDCLI, (cAlOpt)->VDL_TELCLI ) + '" , '
			cJson += ' "recno_customer" : "' + WSCEV001_ConcatJson(STR( IIF( EMPTY( (cAlOpt)->VDL_CODCLI ), SUS->(recno()) , SA1->(recno()) ) )) + '",  '
			cJson += ' "is_prospect": ' + IIF(Empty( (cAlOpt)->VDL_CODCLI ), "true", "false")
			cJson += ' } '
			(cAlOpt)->(DbSkip())
		End
		(cAlOpt)->(dbCloseArea())
		cJson  += '] }'
		::RESP := cJson

	Else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	Endif
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GTInter
	Retorna os interesses em automoveis para o MIL - Mobile area de oportunidades/interesses

	@author Vinicius Gati
	@since 11/01/2015

/*/
WSMETHOD GTInter  WSRECEIVE cCpfSeller, cAToken WSSEND RESP WSSERVICE OPORT
	Local cJson       := '{ "interesses" : [' // interesses
	Local lFirst      := .T.
	Local cQuery      := ""
	Local cAl         := "lolVDM"
	Local oArHlp      := Mil_ArrayHelper():New()
	Local oLinCred    := Mil_LinhasDeCredito():New()
	Local oFasesFin   := Mil_FaseFinanciamento():New()
	Local oCampanha   := Mil_Campanha():New()
	Local cRnoCamp    := ""
	Local cRnoFinFas  := ""
	Local cRnoLinCre  := ""

	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		aVDLCodes := FS_OptsSeller(cCpfSeller, "VDL_CODOPO")
		aVDLCodes := oArHlp:Map(aVDLCodes, { |code| "'" + ALLTRIM(code) + "'" })


		cQuery := " SELECT * FROM " + RetSqlName('VDM') + " VDM WHERE VDM.VDM_FILIAL = '" + xFilial('VDM') + "' AND VDM.D_E_L_E_T_ = ' ' "
		if LEN(aVDLCodes) > 0
			cQuery += "    AND VDM.VDM_CODOPO in ("+oArHlp:Join(aVDLCodes, ',')+")"
		else
			cQuery += "    AND VDM.VDM_CODOPO in (null)"
		endIf
		dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAl , .F., .T. )
		While !(cAl)->(EOF())
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf

			// oportunidade
			VDL->(DbSetOrder(1))
			VDL->(MsSeek( xFilial('VDL') + (cAl)->VDM_CODOPO))

			// marca
			VE1->(DbSetOrder(1))
			VE1->(MsSeek(xFilial('VE1') + (cAl)->VDM_CODMAR))

			// campanha
			VX5->(DbSetOrder(1))
			VX5->(MsSeek( xFilial('VX5') + oCampanha:GetTbCode() + (cAl)->VDM_CAMPOP))
			cRnoCamp := IIf( VX5->(EOF()) , "0", ALLTRIM(STR(VX5->(recno()))) )

			//modelo
			VV2->(DbSetOrder(1))
			VV2->(MsSeek( xFilial('VV2') + (cAl)->VDM_CODMAR + (cAl)->VDM_MODVEI ))

			// cor veiculos
			VVC->(DbSetOrder(1))
			VVC->(MsSeek(xFilial('VVC')+(cAl)->VDM_CODMAR+(cAl)->VDM_CORVEI))

			// motivo cancelamento
			VS0->(DbSetOrder(1))
			VS0->(MsSeek( xFilial('VS0') + '000011' + (cAl)->VDM_MOTCAN))

			// banco
			SA6->(DbSetOrder(1))
			SA6->(MsSeek( xFilial('SA6') + (cAl)->VDM_CODBCO ))

			// fase interesse
			VDK->(DbSetOrder(1))
			VDK->(MsSeek( xFilial('VDK') + (cAl)->VDM_CODFAS ))


			// fase financiamento
			VX5->(DbSetOrder(1))
			VX5->(MsSeek( xFilial('VX5') + oFasesFin:GetTbCode() + (cAl)->VDM_FASFIN ))
			cRnoFinFas := IIf( VX5->(EOF()), "0", ALLTRIM(STR(VX5->(recno()))) )

			// linhas de credito
			VX5->(DbSetOrder(1))
			VX5->(MsSeek( xFilial('VX5') + oLinCred:GetTbCode() + (cAl)->VDM_LINCRE))
			cRnoLinCre := IIf( VX5->(EOF()), "0", ALLTRIM(STR(VX5->(recno()))))

			// Cria o json com os dados
			cJson += '{'
			cJson += ' "recno" :  ' + alltrim(STR( (cAl)->R_E_C_N_O_ )) + ' ,'
			cJson += ' "recno_opportunity" : ' + FS_RnoToJson('VDL') + ' ,'
			cJson += ' "recno_campaign" : ' + cRnoCamp + ' ,'
			cJson += ' "recno_brand" : ' + FS_RnoToJson('VE1') + ' ,'
			cJson += ' "recno_model" : ' + FS_RnoToJson('VV2') + ' ,'
			cJson += ' "recno_vehicle_color" : ' + FS_RnoToJson('VVC') + ' ,'
			cJson += ' "recno_cancellation_reason" : ' + FS_RnoToJson('VS0') + ' ,'
			cJson += ' "recno_bank" : ' + FS_RnoToJson('SA6') + ' ,'
			cJson += ' "recno_financing_status" : ' + cRnoFinFas + ' ,'
			cJson += ' "recno_interest_status" : ' + FS_RnoToJson('VDK') + ' ,'
			cJson += ' "recno_credit_line" : ' + cRnoLinCre + ' ,'
			cJson += ' "date": "'+FS_DtoJS( STOD((cAl)->VDM_DATINT) ) + '" ,'
			cJson += ' "quantity" : '+ALLTRIM(STR((cAl)->VDM_QTDINT))+' ,'
			cJson += ' "valid_until" : "'+FS_DtoJS(STOD((cAl)->VDM_DATLIM))+'" ,'
			cJson += ' "optionals" : "'+ WSCEV001_ConcatJson( (cAl)->VDM_OPCFAB )+'" ,'
			cJson += ' "agency_number" : "'+(cAl)->VDM_CODAGE+'" ,'
			cJson += ' "account_number" : "'+(cAl)->VDM_CONCOR+'" ,'
			cJson += ' "negotiated_value" : '+WSCEV002_NumToJson((cAl)->VDM_VLRNEG)+' ,'
			cJson += ' "negotiation_temperature": "' + VDL->VDL_TMPNEG + '", '
			cJson += ' "bank_contact" : "'+ WSCEV001_ConcatJson( (cAl)->VDM_NOMGER ) +'" '
			cJson += '}'

			(cAl)->(DbSkip())
		End
		(cAl)->(dbCloseArea())

		cJson  += '] }'
		::RESP := cJson
		//conout(cJson)
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.


/*/{Protheus.doc} FS_OptsSeller
	Retorna um array com os codigos(recnos que valem mais que códigos kkk) dos VDL(oportunidades) pertencentes ao vendedor
	Primeiro pega-se os codigos dos clientes em carteira do vendedor
	Em seguida pegamos as oportunidades sem vendedor relacionado mas com cliente da carteira do vendedor
	Depois pegamos as oportunidades diretamente relacionadas ao vendedor

	@author Vinicius Gati
	@since 11/01/2015
	@param cCpfSeller , cpf do vendedor usuario do ambiente mobile

/*/
Static Function FS_OptsSeller(cCpfSeller, cCampo)
	Local aVDLCodes := {}
	Local cAlQ      := "aliasVCF"
	Local cAlQ2     := "aliasVDM"
	Local aCliCodes := {}
	Local cQuery := ""
	Local oArHlp    := Mil_ArrayHelper():New()
	DEFAULT cCampo  := "R_E_C_N_O_"


	if FS_FndCpf(cCpfSeller)
		cCodVen := SA3->A3_COD
	else
		Return .F.
	endIf
	SA3->(DbSetOrder(1))

	cQuery += "  SELECT SA1.A1_COD FROM ("
	cQuery += "  SELECT SA1.A1_COD "
	cQuery += "    FROM "+RetSqlName('SA1')+" SA1, "+RetSqlName('VCF')+" VCF "
	cQuery += "   WHERE SA1.A1_COD = VCF.VCF_CODCLI                       "
	cQuery += "     AND SA1.A1_FILIAL  = '" + xFilial('SA1') + "'         "
	cQuery += "     AND VCF.VCF_FILIAL = '" + xFilial('VCF') + "'         "
	cQuery += "     AND                                                   "
	cQuery += "      (   VCF.VCF_VENPEC = '"+ cCodVen  +"'                "
	cQuery += "     OR   VCF.VCF_VENVEI = '"+ cCodVen  +"'                "
	cQuery += "     OR   VCF.VCF_VENSRV = '"+ cCodVen  +"'                "
	cQuery += "      )                                                    "
	cQuery += " Union ALL "
	cQuery += "  SELECT SA1.A1_COD "
	cQuery += "    FROM "+RetSqlName('SA1')+" SA1, "+RetSqlName('VC1')+" VC1 "
	cQuery += "   WHERE SA1.A1_COD      = VC1_CODCLI                         "
	cQuery += "     AND SA1.A1_FILIAL   = '" + xFilial('SA1') + "'           "
	cQuery += "     AND VC1.VC1_FILIAL  = '" + xFilial('VC1') + "'           "
	cQuery += "     AND VC1_CODVEN = '"+ cCodVen  +"'                        "
	cQuery += " ) SA1 GROUP BY SA1.A1_COD "
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAlQ , .F., .T. )
	(cAlQ)->(DbGoTop())
	While !(cAlQ)->(EOF())
		AADD( aCliCodes, "'" + (cAlQ)->(A1_COD) + "'" )
		(cAlQ)->(DbSkip())
	End
	(cAlQ)->(dbCloseArea())

	// Interesses sem vendedor com cliente da carteira do vendedor
	cQuery := "    SELECT DISTINCT VDL." + cCampo + " CAMPO"
	cQuery += "      FROM "+RetSqlName("VDM")+" VDM "
	cQuery += " LEFT JOIN "+RetSqlName("VDL")+" VDL ON VDM.VDM_CODOPO = VDL.VDL_CODOPO "
	cQuery += "     WHERE VDM.VDM_FILIAL = '"+xFilial("VDM")+"' "
	cQuery += "       AND VDL.VDL_FILIAL = '"+xFilial("VDL")+"' "
	cQuery += "       AND VDL.D_E_L_E_T_ = ' ' "
	cQuery += "       AND VDM.D_E_L_E_T_ = ' ' "
	//cQuery += "       AND ( VDM.VDM_CODVEN is null OR VDM.VDM_CODVEN = ''   "
	//cQuery += "        OR "
	if LEN(aCliCodes) > 0
		cQuery += "     AND VDL.VDL_CODCLI IN (" + oArHlp:Join(aCliCodes, ',') + ") "
	else
		cQuery += "     AND VDL.VDL_CODCLI IN (null) "
	endIf
	//cQuery += "           ) "
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAlQ2 , .F., .T. )

	While !(cAlQ2)->(EOF())
		AADD( aVDLCodes, (cAlQ2)->(CAMPO) )
		(cAlQ2)->(DbSkip())
	End
	(cAlQ2)->(dbCloseArea())

	// Interesses com vendedor usuário do celular
	cQuery := "    SELECT DISTINCT VDL." + cCampo + " CAMPO"
	cQuery += "      FROM "+RetSqlName("VDM")+" VDM "
	cQuery += " LEFT JOIN "+RetSqlName("VDL")+" VDL ON VDM.VDM_CODOPO = VDL.VDL_CODOPO  "
	cQuery += "     WHERE VDM.VDM_FILIAL = '"+xFilial("VDM")+"' "
	cQuery += "       AND VDL.VDL_FILIAL = '"+xFilial("VDL")+"' "
	cQuery += "       AND VDL.D_E_L_E_T_ = ' ' "
	cQuery += "       AND VDM.D_E_L_E_T_ = ' ' "
	cQuery += "       AND VDM.VDM_CODVEN = '"+cCodVen+"' "
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAlQ2 , .F., .T. )

	While !(cAlQ2)->(EOF())
		AADD( aVDLCodes, (cAlQ2)->(CAMPO) )
		(cAlQ2)->(DbSkip())
	End
	(cAlQ2)->(dbCloseArea())
Return aVDLCodes

/*/{Protheus.doc} SdOports
	Recebe json contendo dados de uma oportunidade e grava os mesmos no Protheus

	@author Vinicius Gati
	@since 31/03/2015

/*/
WSMETHOD SdOports  WSRECEIVE cDataJson, cCpfSeller, cAToken WSSEND RESP WSSERVICE OPORT
	FS_StFilial(cCpfSeller)
	//conout(cDataJson)
	if FS_FndCpf(cCpfSeller)
		nRecnoV := SA3->(recno())
	else
		::RESP := ' { "error" : "Cpf não econtrado" } '
		Return .T.
	endIf

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		oJsonParser := Mil_JsonParse():New(cDataJson)
		oJsonData   := oJsonParser:ParseToObj()
		oOport      := oJsonData:GetValue('oportunidade')
		recno       := WsGrvOpo(oJsonParser, oOport, .F.)
		::RESP      := '{ "status":"ok", "recno": ' + STR(recno) + '} '
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} SdProOpo
	Recebe json contendo dados de uma oportunidade e grava os mesmos no Protheus

	@author Vinicius Gati
	@since 31/03/2015

/*/
WSMETHOD SdProOpo  WSRECEIVE cDataJson, cCpfSeller, cAToken WSSEND RESP WSSERVICE OPORT
	Local cErr  := ""
	conout("SdProOpo - " + cDataJson)
	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)

		if FS_FndCpf(cCpfSeller)
			nRecnoV := SA3->(recno())
		else
			::RESP := ' { "error" : "Cpf não econtrado" } ' 
			Return .T.
		endIf
		oJsonParser := Mil_JsonParse():New(cDataJson)
		oJsonData   := oJsonParser:ParseToObj()
		oOport      := oJsonData:GetValue('oportunidade')

		//conout("vendedor selecionado , gravando oportunidade/prospect")

		nRecno := WsGrvOpo(oJsonParser, oOport, .T.)
		//conout("fim gravacao prospect")
		if (nRecno <= 0)
			cErr := IIF(nRecno == -3, "Prospect não encontrado", "Json inválido")
			::RESP := '{ "error":"'+cErr+'" }'
		Else
			::RESP := '{ "status":"ok", "recno": ' + STR(nRecno) + '} ' // TODO: retornar recno
		end
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} SdIntere
	Recebe json contendo dados de um interesse e grava os mesmos no Protheus

	@author Vinicius Gati
	@since 31/03/2015

/*/
WSMETHOD SdIntere  WSRECEIVE cDataJson, cCpfSeller, cAToken WSSEND RESP WSSERVICE OPORT
	FS_StFilial(cCpfSeller)
	if FS_FndCpf(cCpfSeller)
		nRecnoV := SA3->(recno())
	else
		::RESP := ' { "error" : "Cpf não econtrado" } '
		Return .T.
	endIf

	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		oJsonParser := Mil_JsonParse():New(cDataJson)
		oJsonData   := oJsonParser:ParseToObj()
		oInteresse  := oJsonData:GetValue('interesse')
		recno       := WsGrvInt(oJsonParser, oInteresse, nRecnoV)
		::RESP      := '{ "status":"ok", "recno": ' + STR(recno) + '} '
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} WsGrvOpo
	Gravara os dados da oportunidade no banco de dados do protheus
		{
		recno
		recno_customer
		customer_name
		customer_email
		customer_phone
		}

	@author Vinicius Gati
	@since 31/03/2015

/*/
Static Function WsGrvOpo(oJsonParser, oOport, lPro )

	Local nRecno := oJsonParser:readInt( oOport:GetValue('recno', '0') )
	Local oCev   := VEDMSCev():New()
	Local oRet   := nil
	default lPro := .F.

	if (lPro)
		conout("Prospect recebido na oport")
		oRet := oCev:ConvCli( oOport:GetValue("prospect") )
		if oRet:GetValue('erro', .F.)
			return
		else
			if oRet:GetValue('prospect')
				SUS->(DBGOTO(oRet:getvalue('recno')))
			else
				SA1->(DBGOTO(oRet:getvalue('recno')))
				lPro := .F. // CONVERTEU PRA CLIENTE
			end
		endif
	else
		nRecnoC := VAL( oOport:GetValue('recno_customer', 0) )
		SA1->(DBGOTO(nRecnoC))
	endif

	conout('Gravando oportunidade na Filial '+cFilAnt)

	if nRecno > 0
		VDL->(DBGOTO(nRecno))
		RecLock( "VDL", .F. ) // altera
	else
		RecLock( "VDL", .T. ) // novo
		VDL->VDL_CODOPO := GETSXENUM('VDL', 'VDL_CODOPO')
		CONFIRMSX8()
	endIf

	VDL->VDL_FILIAL := xFilial('VDL')
	if VDL->(FieldPos('VDL_TMPNEG')) > 0
		VDL->VDL_TMPNEG := oOport:GetValue('negotiation_temperature')
	endif

	if ! Empty(oOport:GetValue('recno_customer', '0'))

		if lPro
			VDL->VDL_CDPROS := SUS->US_COD
			VDL->VDL_LJPROS := SUS->US_LOJA
			VDL->VDL_NOMCLI := SUS->US_NOME
			VDL->VDL_EMACLI := SUS->US_EMAIL
			VDL->VDL_TELCLI := SUS->US_TEL
			VDL->VDL_DDDCLI := SUS->US_DDD
			VDL->VDL_CODCLI := ''
			VDL->VDL_LOJCLI := ''
		else
			VDL->VDL_CODCLI := SA1->A1_COD
			VDL->VDL_LOJCLI := SA1->A1_LOJA
			VDL->VDL_NOMCLI := SA1->A1_NOME
			VDL->VDL_EMACLI := SA1->A1_EMAIL
			VDL->VDL_TELCLI := SA1->A1_TEL
			VDL->VDL_DDDCLI := SA1->A1_DDD
			VDL->VDL_CDPROS := ''
			VDL->VDL_LJPROS := ''
		endIf
	else
		VDL->VDL_NOMCLI := oOport:GetValue('customer_name')
		VDL->VDL_EMACLI := oOport:GetValue('customer_email')

		if LEN( ALLTRIM(oOport:GetValue('customer_phone')) ) == 8 .OR. LEN( ALLTRIM(oOport:GetValue('customer_phone')) ) == 9
			VDL->VDL_TELCLI  := oOport:GetValue('customer_phone')
			VDL->VDL_DDDCLI  := ""
		elseIf LEN( ALLTRIM(oOport:GetValue('customer_phone')) ) == 10
			VDL->VDL_TELCLI  := RIGHT( oOport:GetValue('customer_phone'), 8)
			VDL->VDL_DDDCLI  := LEFT( oOport:GetValue('customer_phone') , 2 )
		else
			VDL->VDL_TELCLI  := RIGHT( oOport:GetValue('customer_phone'), LEN(oOport:GetValue('customer_phone')) - 2 )
			VDL->VDL_DDDCLI  := LEFT( oOport:GetValue('customer_phone') , 2 )
		endIf
	endIf

	VDL->(MsUnLock())
Return VDL->(recno())

/*/{Protheus.doc} WsGrvInt
	Gravara os dados do interesse no banco de dados do protheus
		{
			recno
			recno_opportunity
			recno_brand
			recno_campaign
			recno_model
			recno_vehicle_color
			recno_cancellation_reason
			recno_bank
			recno_financing_status
			recno_status
			recno_credit_line
			valid_until
			interest_date
			optionals
			account_number
			agency_number
			bank_contact
			quantity
		}
	@author Vinicius Gati
	@since 31/03/2015

/*/
Static Function WsGrvInt(oJsonParser, oInteresse, nRecnoV)
	Local nRecno := oJsonParser:readInt( oInteresse:GetValue('recno', "0") )

	if nRecno > 0
		VDM->(DBGOTO(nRecno))
		RecLock( "VDM", .F. ) // altera
	else
		RecLock( "VDM", .T. ) // novo
	endIf

	if Empty(VDM->VDM_CODOPO)
		recnoVdm := oJsonParser:readInt( oInteresse:GetValue('recno_opportunity', '0') )
		VDL->(DBGOTO(recnoVdm))
		VDM->VDM_CODOPO := VDL->VDL_CODOPO
		VDM->VDM_CODINT := GETSXENUM('VDM', 'VDM_CODINT') // PK codigo do interesse
		CONFIRMSX8()
	endIf

	if oJsonParser:readInt(oInteresse:GetValue('recno_brand', "0")) > 0
		VE1->(DBGOTO(oJsonParser:readInt(oInteresse:GetValue('recno_brand', "0"))))
		VDM->VDM_CODMAR := VE1->VE1_CODMAR
	EndIf

	if oJsonParser:readInt(oInteresse:GetValue('recno_campaign', "0")) > 0
		VX5->(DBGOTO(oJsonParser:readInt(oInteresse:GetValue('recno_campaign', "0"))))
		VDM->VDM_CAMPOP := VX5->VX5_CODIGO
	EndIf

	if oJsonParser:readInt(oInteresse:GetValue('recno_model', "0")) > 0
		VV2->(DBGOTO(oJsonParser:readInt(oInteresse:GetValue('recno_model', "0"))))
		VDM->VDM_MODVEI := VV2->VV2_MODVEI
	EndIf

	if oJsonParser:readInt(oInteresse:GetValue('recno_vehicle_color', "0")) > 0
		VVC->(DBGOTO(oJsonParser:readInt(oInteresse:GetValue('recno_vehicle_color', "0"))))
		VDM->VDM_CORVEI := VVC->VVC_CORVEI
	EndIf

	if oJsonParser:readInt(oInteresse:GetValue('recno_cancellation_reason', "0")) > 0
		VS0->(DBGOTO(oJsonParser:readInt(oInteresse:GetValue('recno_cancellation_reason', "0"))))
		VDM->VDM_MOTCAN := VS0->VS0_CODMOT
	EndIf

	if oJsonParser:readInt(oInteresse:GetValue('recno_bank', "0")) > 0
		SA6->(DBGOTO(oJsonParser:readInt(oInteresse:GetValue('recno_bank', "0"))))
		VDM->VDM_NOMBCO := SA6->A6_NOME
		VDM->VDM_CODBCO := SA6->A6_COD
	EndIf

	// fase financiamento
	if oJsonParser:readInt(oInteresse:GetValue('recno_financing_status', "0")) > 0
		VX5->(DBGOTO(oJsonParser:readInt(oInteresse:GetValue('recno_financing_status', "0"))))
		VDM->VDM_FASFIN := VX5->VX5_CODIGO
	EndIf

	// fase interesse
	if oJsonParser:readInt(oInteresse:GetValue('recno_status', "0")) > 0
		VDK->(DBGOTO(oJsonParser:readInt(oInteresse:GetValue('recno_status', "0"))))
		VDM->VDM_CODFAS :=VDK->VDK_CODFAS
	EndIf

	if oJsonParser:readInt(oInteresse:GetValue('recno_credit_line', "0")) > 0
		VX5->(DBGOTO(oJsonParser:readInt(oInteresse:GetValue('recno_credit_line', "0"))))
		VDM->VDM_LINCRE := VX5->VX5_CODIGO
	EndIf

	// vendedor
	SA3->(DBGOTO(nRecnoV))
	VDM->VDM_CODVEN := SA3->A3_COD

	if ! Empty(oInteresse:GetValue("valid_until"))
		VDM->VDM_DATLIM := STOD( oJsonParser:readDate( oInteresse:GetValue("valid_until") ) )
	endIf
	if ! Empty(oInteresse:GetValue("interest_date"))
		VDM->VDM_DATINT := STOD( oJsonParser:readDate( oInteresse:GetValue("interest_date") ) )
	endIf

	if VDM->(FieldPos('VDM_XESTVE')) > 0
		VDM->VDM_XESTVE := oInteresse:GetValue('VDM_XESTVE', '')
	endif
	if VDM->(FieldPos('VDM_XTPFAT')) > 0
		VDM->VDM_XTPFAT := oInteresse:GetValue('VDM_XTPFAT', '')
	endif
	if VDM->(FieldPos('VDM_X1JD')) > 0
		VDM->VDM_X1JD := oInteresse:GetValue('VDM_X1JD', '')
	endif

	if VDM->(FieldPos('VDM_VLRNEG')) > 0
		VDM->VDM_VLRNEG := VAL( STRTRAN(oInteresse:GetValue('negotiated_value', '0'), ",", ".") )
	endif
	VDM->VDM_OPCFAB := oInteresse:GetValue("optionals")
	VDM->VDM_CONCOR := oInteresse:GetValue("account_number")
	VDM->VDM_TIPMID := oInteresse:GetValue("VDM_TIPMID")
	VDM->VDM_CODAGE := oInteresse:GetValue("agency_number")
	VDM->VDM_NOMGER := oInteresse:GetValue("bank_contact")
	VDM->VDM_QTDINT := VAL(oInteresse:GetValue("quantity"))
	VDM->VDM_FILIAL := xFilial('VDM')

	// TODO: Os status serao feitos como novas entidades, terao rotas de envio/recebimento assim como oportunidade e interesse

	VDM->(MsUnLock())
	if ! Empty(oInteresse:GetValue("negotiation_temperature", ""))
		reclock("VDL", .F.)
		VDL->VDL_TMPNEG := oInteresse:GetValue("negotiation_temperature")
		MsUnlock()
	endif
Return VDM->(recno())

/*/{Protheus.doc} GtHsStOpFi
	Recebe json contendo dados de um interesse e grava os mesmos no Protheus

	@author Vinicius Gati
	@since 31/03/2015

/*/
WSMETHOD GtHsStOp    WSRECEIVE  cCpfSeller, cAToken, cRnoInt WSSEND RESP WSSERVICE OPORT
	Local cJson    := '{ "history_interest_status" : ['
	Local lFirst   := .T.
	Local cAlVDN   := "tttt"

	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		VDM->(DBGOTO(VAL(cRnoInt)))

		cQuery := "    SELECT R_E_C_N_O_, VDN_NOMCLI, VDN_DATHIS, VDN_HORHIS, VDN_MOTCAN, VDN_CODFAS, VDN_CODCLI, VDN_LOJCLI"
		cQuery += "      FROM "+RetSqlName("VDN")+" VDN "
		cQuery += "     WHERE VDN.VDN_FILIAL = '"+xFilial("VDN")+"' "
		cQuery += "       AND VDN.D_E_L_E_T_ = ' ' AND VDN.VDN_TIPHIS = '1' "
		cQuery += "       AND VDN.VDN_CODINT = '" + VDM->VDM_CODINT + "' "
		dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAlVDN , .F., .T. )
		While !(cAlVDN)->(EOF())

			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf

			// motivo cancelamento
			VS0->(DbSetOrder(1))
			VS0->(MsSeek( xFilial('VS0') + '000011' + (cAlVDN)->VDN_MOTCAN))

			// fase interesse
			VDK->(DbSetOrder(1))
			VDK->(MsSeek( xFilial('VDK') + (cAlVDN)->VDN_CODFAS ))

			// cliente
			SA1->(DbSetOrder(1))
			SA1->(MsSeek( xFilial("SA1") + (cAlVDN)->(VDN_CODCLI) + (cAlVDN)->(VDN_LOJCLI) ))

			cJson += '{'
			cJson += ' "recno"                     :  ' + ALLTRIM(STR( (cAlVDN)->R_E_C_N_O_ )) + ' ,'
			cJson += ' "recno_cancellation_reason" :  ' + FS_RnoToJson('VS0')                  + ' ,'
			cJson += ' "recno_interest_status"     :  ' + FS_RnoToJson('VDK')                  + ' ,'
			cJson += ' "recno_customer"            :  ' + FS_RnoToJson('SA1')                  + ' ,'
			cJson += ' "customer_name"             : "' + WSCEV001_ConcatJson((cAlVDN)->VDN_NOMCLI)     + '",'
			cJson += ' "history_date"              :  ' + FS_DtoJS((cAlVDN)->VDN_DATHIS)       + ' ,'
			cJson += ' "history_hour"              :  ' + STR((cAlVDN)->VDN_HORHIS)            + ' '
			cJson += '}'

			(cAlVDN)->(DbSkip())
		End
		(cAlVDN)->(dbCloseArea())

		cJson  += '] }'
		::RESP := cJson

	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GtHsStOpFi
	Recebe json contendo dados de um interesse e grava os mesmos no Protheus

	@author Vinicius Gati
	@since 31/03/2015

/*/
WSMETHOD GtHsStOpFi  WSRECEIVE  cCpfSeller, cAToken, cRnoInt WSSEND RESP WSSERVICE OPORT
	Local cJson     := '{ "history_interest_financing_status" : ['
	Local lFirst    := .T.
	Local oLinCred  := Mil_LinhasDeCredito():New()
	Local oFasesFin := Mil_FaseFinanciamento():New()
	Local cAlVDN    := "eita"
	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		VDM->(DBGOTO( VAL(cRnoInt) ))

		cQuery := "    SELECT VDN_FASFIN, VDN_LINCRE, R_E_C_N_O_, VDN_NOMBCO, VDN_CODAGE, VDN_CONCOR, VDN_NOMGER, VDN_DATHIS, VDN_HORHIS "
		cQuery += "      FROM "+RetSqlName("VDN")+" VDN "
		cQuery += "     WHERE VDN.VDN_FILIAL = '"+xFilial("VDN")+"' "
		cQuery += "       AND VDN.D_E_L_E_T_ = ' ' AND VDN.VDN_TIPHIS = '2' "
		cQuery += "       AND VDN.VDN_CODINT = '" + VDM->VDM_CODINT + "' "
		dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAlVDN , .F., .T. )
		While !(cAlVDN)->(EOF())

			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf

			// fase financiamento
			VX5->(DbSetOrder(1))
			VX5->(MsSeek( xFilial('VX5') + oFasesFin:GetTbCode() + (cAlVDN)->VDN_FASFIN ))
			cRnoFinFas := IIf( VX5->(EOF()), "0", ALLTRIM(STR(VX5->(recno()))) )

			// linhas de credito
			VX5->(DbSetOrder(1))
			VX5->(MsSeek( xFilial('VX5') + oLinCred:GetTbCode() + (cAlVDN)->VDN_LINCRE))
			cRnoLinCre := IIf( VX5->(EOF()), "0", ALLTRIM(STR(VX5->(recno()))))

			cJson += '{'
			cJson += ' "recno"                     :  ' + ALLTRIM(STR((cAlVDN)->R_E_C_N_O_ ))  + ' ,'
			cJson += ' "recno_financing_status"    :  ' + cRnoFinFas                           + ' ,'
			cJson += ' "recno_credit_line"         :  ' + cRnoLinCre                           + ' ,'
			cJson += ' "bank_description"          : "' + WSCEV001_ConcatJson( (cAlVDN)->VDN_NOMBCO )   + '",'
			cJson += ' "agency_number"             : "' + WSCEV001_ConcatJson( (cAlVDN)->VDN_CODAGE )   + '",'
			cJson += ' "account_number"            : "' + WSCEV001_ConcatJson( (cAlVDN)->VDN_CONCOR )   + '",'
			cJson += ' "bank_contact"              : "' + WSCEV001_ConcatJson( (cAlVDN)->VDN_NOMGER )   + '",'
			cJson += ' "history_date"              :  ' + FS_DtoJS((cAlVDN)->VDN_DATHIS)       + ' ,'
			cJson += ' "history_hour"              :  ' + STR((cAlVDN)->VDN_HORHIS)            + '  '
			cJson += '}'

			(cAlVDN)->(DbSkip())
		End
		(cAlVDN)->(dbCloseArea())
		cJson  += '] }'
		::RESP := cJson

	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GtHsStOpFi
	Recebe json contendo dados de um interesse e grava os mesmos no Protheus

	@author Vinicius Gati
	@since 31/03/2015

/*/
WSMETHOD SdStsCh WSRECEIVE cCpfSeller, cDataJson, cAToken, cRnoInt WSSEND RESP WSSERVICE OPORT
	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		oJsonParser := Mil_JsonParse():New(cDataJson)
		oJsonData   := oJsonParser:ParseToObj()
		oStsHist    := oJsonData:GetValue('status_change')
		//conout(cDataJson)
		recno := WsGHisSt(oJsonParser, oStsHist, VAL(cRnoInt))
		::RESP := '{ "status":"ok", "recno": ' + STR(recno) + '} '
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} WsGHisSt
	Gravara os dados da oportunidade no banco de dados do protheus

	@author Vinicius Gati
	@since 02/03/2015

/*/
Static Function WsGHisSt(oJsonParser, oStsHist, nRnoInt)
	VDM->(DBGOTO(nRnoInt))
	RecLock( "VDN", .T. ) // novo

	if oStsHist:GetValue("type") == "1"
		VDN->VDN_TIPHIS := "1"

		// motivo cancelamento
		VS0->(DBGOTO( VAL(oStsHist:GetValue("recno_cancellation_reason", "0")) ))
		if ! Empty(VS0->VS0_CODMOT)
			VDN->VDN_MOTCAN := VS0->VS0_CODMOT
		endIf

		if VDN->(FieldPos('VDN_VLRNEG')) > 0
			VDN->VDN_VLRNEG := VAL( STRTRAN(oStsHist:GetValue('negotiated_value', '0'), ",", ".") )
			VDN->VDN_TMPNEG := oStsHist:GetValue("negotiation_temperature", "F")
		endif

		// fase interesse
		VDK->(DBGOTO( VAL(oStsHist:GetValue("recno_interest_status", "0")) ))
		if ! Empty(VDK->VDK_CODFAS)
			VDN->VDN_CODFAS := VDK->VDK_CODFAS
		Else
			VDN->VDN_CODFAS := VDM->VDM_CODFAS
		endIf

		if oJsonParser:readInt( oStsHist:GetValue('prospect', 0) ) == 0
			SA1->(DBGOTO( oJsonParser:readInt(oStsHist:GetValue('recno_customer', '0')) ))
			conout("||>> Cliente passado por parametro ||")
			if SA1->(recno()) > 0
				VDN->VDN_CODCLI := SA1->A1_COD
				VDN->VDN_LOJCLI := SA1->A1_LOJA
				VDN->VDN_NOMCLI := SA1->A1_NOME
			endIf
		else
			SUS->(DBGOTO( oJsonParser:readInt(oStsHist:GetValue('recno_customer', '0')) ))
			conout("||>> Prospect passado por parametro ||")
			if SUS->(recno()) > 0
				VDN->VDN_CDPROS := SUS->US_COD
				VDN->VDN_LJPROS := SUS->US_LOJA
				VDN->VDN_NOMCLI := SUS->US_NOME
			endIf
		endif
		VDN->VDN_OBSERV := oStsHist:GetValue('observations')
	elseIf oStsHist:GetValue("type") == "2"
		VDN->VDN_TIPHIS := "2"

		// fase financiamento
		VX5->(DBGOTO(VAL(oStsHist:GetValue("recno_financing_status", "0"))))
		if ! Empty(VX5->VX5_CODIGO)
			VDN->VDN_FASFIN := VX5->VX5_CODIGO
		Else
			VDN->VDN_FASFIN := VDM->VDM_FASFIN
		endif
		// linhas de credito
		VX5->(DBGOTO(VAL(oStsHist:GetValue("recno_credit_line", "0"))))
		if ! Empty(VX5->VX5_CODIGO)
			VDN->VDN_LINCRE := VX5->VX5_CODIGO
		endIf

		VDN->VDN_NOMBCO := oStsHist:GetValue('bank_description')
		VDN->VDN_CODAGE := oStsHist:GetValue('agency_number')
		VDN->VDN_CONCOR := oStsHist:GetValue('account_number')
		VDN->VDN_NOMGER := oStsHist:GetValue('bank_contact')
	endIf

	VDN->VDN_HORHIS := VAL(oStsHist:GetValue("history_hour"))
	VDN->VDN_DATHIS := STOD(oStsHist:GetValue("history_date", "19000101"))
	VDN->VDN_CODVEN := SA3->A3_COD
	VDN->VDN_FILIAL := xFilial('VDN')
	VDN->VDN_CODHIS := GETSXENUM("VDN", "VDN_CODHIS")
	CONFIRMSX8()
	VDN->VDN_CODINT := VDM->VDM_CODINT
	VDN->(MsUnLock())
Return VDN->(RECNO())

/*/{Protheus.doc} GtRaics
	Devolve os raics relacionados ao cpf do vendedor

	@author Vinicius Gati
	@since 31/03/2015

/*/
WSMETHOD GtRaics  WSRECEIVE  cCpfSeller, cAToken WSSEND RESP WSSERVICE RAIC
	Local cJson    := '{ "raics" : ['
	Local lFirst   := .T.
	Local oSqlHlp  := DMS_SqlHelper():New()
	Local cQuery   := ""
	Local aRecnos  := {}
	Local nIdx     := 1
	Local cCodUsu  := ""

	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()

	cCodUsu := FM_SQL(" SELECT VAI_CODUSR FROM " + oSqlHlp:NoLock('VAI') + " WHERE VAI_CODVEN = '" + SA3->A3_COD + "' AND D_E_L_E_T_ = ' ' ")

	cQuery += " SELECT R_E_C_N_O_ recno FROM " + oSqlHlp:NoLock('VAO')
	cQuery += "  WHERE VAO.VAO_USURES =  '" + cCodUsu + "' "
	cQuery += "    AND VAO_DATREC     >= '" + DTOS(dDatabase-90) + "' "
	cQuery += "    AND VAO.D_E_L_E_T_ =  '' "

	if .T. // oToken:Busca(cAToken)
		aRecnos := oSqlHlp:GetSelect({;
			{'campos', {'recno'}},;
			{'query' ,    cQuery} ;
		})

		For nIdx := 1 to LEN(aRecnos)
			DbSelectArea('VAO')
			DbGoTo( aRecnos[1]:GetValue('recno') )

			// POG para E_MSMM
			INCLUI     := .F.
			ALTERA     := .F.
			VISUALIZA  := .T.
			// END POG
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf

			DbselectArea("VAQ")
			DbSetOrder(1)
			VAQ->(MsSeek( xFilial('VAQ') + VAO->VAO_TIPREC ))

			recno_vai := ALLTRIM(STR(FM_SQL("SELECT R_E_C_N_O_ from " + RetSqlName("VAI") + " WHERE VAI_CODUSR = '" + VAO->VAO_USURES + "' AND D_E_L_E_T_ = ' ' ")))

			DbselectArea("SA1")
			SA1->(DbSetOrder(1))
			SA1->(MsSeek( xFilial('SA1') + VAO->VAO_CODCLI ))

			DbselectArea("VAP")
			DbSetOrder(1)
			VAP->(MsSeek( xFilial('VAP') + VAO->VAO_DEPART ))

			cJson += '{'
			cJson += ' "recno": '                   + FS_RnoToJson("VAO")
			cJson += ',"recno_customer": '          + FS_RnoToJson("SA1")                                                         // -> Cliente atendido;
			cJson += ',"recno_responsible": '       + recno_vai                                                                   // -> diz quem vai ser o responsável em responder essa insatisfação/satisfação;
			cJson += ',"recno_type": '              + FS_RnoToJson("VAQ")                                                         // -> se é insatisfação/satisfação;
			cJson += ',"source_type_id": "'         + VAO->VAO_TIPORI + '"'                                                       // -> 1=Atendimento Veiculos;2=OS de Oficina;3=Pecas Balcao;4=CEV;
			cJson += ',"status_id": "'              + VAO->VAO_SITUAC + '"'                                                       // -> 0=Aberto;1=Prorrogado;2=Encerrado;
			cJson += ',"prorrogation_date": "'      + FS_DtoJS(VAO->VAO_DATPRO)  + '"'                                            // -> Prorrogar atendimento;
			cJson += ',"closing_date": "'           + FS_DtoJS(VAO->VAO_DATENC)  + '"'                                            // -> Data de encerramento;
			cJson += ',"complaint_date": "'         + FS_DtoJS(VAO->VAO_DATREC)  + '"'                                            // -> Data Criacao
			cJson += ',"recno_department": '        + FS_RnoToJson('VAP')
			cJson += ',"type_detail": "'            + VAO->VAO_ORIGEM + '"'                                                       // -> Detalhe do tipo de origem, se veio de Atendimento deixe aqui o Numero do atendimento, etc...;
			cJson += ',"detail": "'                 + FS_StoJS(ALLTRIM(E_MSMM(VAO->VAO_RECLAO,TamSx3("VAO_RECLAM")[1]))) + '"'    // -> MEMO reclamação VAO_RECLAO(OCO-MEMO) FS_StoJS(ALLTRIM(E_MSMM(VAO->VAO_RECLAM,TamSx3("VAO_RECLAO")[1])))
			cJson += ',"complaint_source_id": "'    + VAO->VAO_RECLDE + '"'                                                       // -> 1=Assist.Tecnica;2=Pecas;3=Vendas;4=Administracao
			cJson += ',"compromise_detail" : "'     + NOACENTO(VAO->VAO_CMPASS) + '"'                                             // -> Compromisso
			cJson += ',"compromise_date": "'        + FS_DtoJS(VAO->VAO_DTCASS)  + '"'                                            // -> Data compromisso
			cJson += ',"compromise_hour": '         + STR(VAO->VAO_HRCASS)                                                        // -> Hora compromisso
			cJson += ',"correction_detail": "'      + VAO->VAO_CORESP + '"'                                                       // -> Correção
			cJson += ',"correction_date": "'        + FS_DtoJS(VAO->VAO_DTCESP)  + '"'                                            // -> Data correção
			cJson += ',"correction_hour": '         + STR(VAO->VAO_HRCESP)                                                        // -> Hora correção
			cJson += ',"cause_detail": "'           + VAO->VAO_CAUPRB + '"'                                                       // -> Causa provavel
			cJson += ',"cause_date": "'             + FS_DtoJS(VAO->VAO_DTCPRB)  + '"'                                            // -> Data causa
			cJson += ',"cause_hour": '              + STR(VAO->VAO_HRCPRB)                                                        // -> Hora causa
			cJson += ',"post_correction_detail": "' + VAO->VAO_APOCOR + '"'                                                       // -> Observação pós correção
			cJson += ',"post_correction_date": "'   + FS_DtoJS(VAO->VAO_DTACOR)  + '"'                                            // -> Data pós correção
			cJson += ',"post_correction_hour": '    + STR(VAO->VAO_HRACOR)                                                        // -> Hora pós correção
			cJson += '}'
		Next
		cJson  += '] }'
		::RESP := cJson
		//conout( LEFT(cJson, 100) )
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GtTpsReg
	Devolve os tipos de registro relacionados ao cpf do vendedor

	@author Vinicius Gati
	@since 31/03/2015

/*/
WSMETHOD GtTpsReg WSRECEIVE  cCpfSeller, cAToken WSSEND RESP WSSERVICE RAIC
	Local cJson    := '{ "tipos_registro" : ['
	Local lFirst   := .T.

	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		DbselectArea("VAQ")
		DbSetOrder(1)
		VAQ->( MsSeek( xFilial('VAQ') ) )
		While ! VAQ->(EOF()) .AND. VAQ->VAQ_FILIAL == xFilial('VAQ')
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cJson += ' { "recno": ' + STR(VAQ->(recno())) + ', "description": "' + ALLTRIM(VAQ->VAQ_DESTIP) + '" } '

			VAQ->(DbSkip())
		End
		VAQ->(dbCloseArea())

		cJson  += '] }'
		::RESP := cJson

	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} GtDeparts
	Devolve os departamentos relacionados ao cpf do vendedor

	@author Vinicius Gati
	@since 31/03/2015

/*/
WSMETHOD GtDeparts WSRECEIVE  cCpfSeller, cAToken WSSEND RESP WSSERVICE RAIC
	Local cJson    := '{ "departamentos" : ['
	Local lFirst   := .T.

	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		DbselectArea("VAP")
		DbSetOrder(1)
		VAP->(MsSeek( xFilial('VAP') ))
		While ! VAP->(EOF()) .AND. VAP->VAP_FILIAL == xFilial('VAP')
			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cJson += ' { "recno": ' + STR(VAP->(recno())) + ', "description": "' + ALLTRIM(VAP->VAP_DESDEP) + '" } '

			VAP->(DbSkip())
		End
		VAP->(dbCloseArea())

		cJson  += '] }'
		::RESP := cJson

	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} SdRaic
	Grava dados de raic recebido

	@author Vinicius Gati
	@since 31/03/2015

/*/
WSMETHOD SdRaic WSRECEIVE  cCpfSeller, cDataJson, cAToken WSSEND RESP WSSERVICE RAIC
	FS_StFilial(cCpfSeller)
	//oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		oJsonParser  := Mil_JsonParse():New(cDataJson)
		//conout(cDataJson)
		oJsonData    := oJsonParser:ParseToObj()
		oRaic        := oJsonData:GetValue('raic')
		iRecno       := WsGrvRaic(oJsonParser, oRaic) // i de icognito
		//TODO: todas as funcoes de WSGrv devem retornar ou INT ou STR, deve ser feita checagem e tratamento de erro quando string
		::RESP       := '{ "status":"ok", "recno": ' + STR(iRecno) + '} '
	else
		::RESP       := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} WsGrvRaic
	Grava dados de raic

	@author Vinicius Gati
	@since 13/05/2015

/*/
Function WsGrvRaic(oJsonParser, oRaic)
	Local nRecno  := 0
	Local nRecnoC := oJsonParser:readInt( oRaic:GetValue('recno_customer', '0') )

	if (nRecnoC == 0)
		Return "Cliente inválido" // erro
	end

	BEGIN TRANSACTION
		nRecno  := oJsonParser:readInt( oRaic:GetValue('recno', '0') )

		if nRecno > 0
			VAO->(DBGOTO( nRecno ))
			RecLock( "VAO", IIF(!EOF(), .F., .T.) ) // .F. = (alteracao | já existe)
		Else
			RecLock( "VAO", .T. )
		EndIf

		VAO->VAO_FILIAL := xFilial("VAO")
		VAO->VAO_FILORI := xFilial("VAO")
		//raic
		SA1->(DBGOTO( oJsonParser:readInt(oRaic:GetValue('recno_customer', '0')) ))
		VAO->VAO_CODCLI := SA1->A1_COD
		VAO->VAO_LOJCLI := SA1->A1_LOJA

		VAI->(DbGOTO( oJsonParser:readInt(oRaic:GetValue('recno_responsible', '0')) ))
		VAO->VAO_USURES := VAI->VAI_CODUSR

		VAQ->(DBGOTO( oJsonParser:readInt(oRaic:GetValue('recno_customer_relation_type', '0')) ))
		VAO->VAO_TIPREC := VAQ->VAQ_TIPREC

		VAP->(DBGOTO( oJsonParser:readInt(oRaic:GetValue('recno_department', '0')) ))
		VAO->VAO_DEPART := VAP->VAP_CODDEP

		VAO->VAO_TIPORI := oRaic:GetValue('id_source_type', '0')
		VAO->VAO_SITUAC := oRaic:GetValue('id_source'     , '0')

		//	FS_DtoJS(VAO->VAO_DATENC) TODO: fazer antes da versão final
		MSMM(VAO->VAO_RECLAO,TamSx3("VAO_RECLAM")[1],,oRaic:GetValue('detail'),1,,,"VAO","VAO_RECLAO")

		VAO->VAO_DATPRO  := STOD(oJsonParser:readDate(oRaic:GetValue('prorrogation_date')))
		VAO->VAO_DATREC  := STOD(oJsonParser:readDate(oRaic:GetValue('complaint_date')))
		VAO->VAO_ORIGEM  := oRaic:GetValue('type_detail', '')
		VAO->VAO_RECLDE  := oRaic:GetValue('id_complaint_source')

		////compromisso
		VAO->VAO_CMPASS  := oRaic:GetValue('compromise_detail', '')
		VAO->VAO_DTCASS  := STOD(oJsonParser:readDate(oRaic:GetValue('compromise_date')))
		VAO->VAO_HRCASS  := oJsonParser:readHour( oRaic:GetValue('compromise_hour', "0") )

		////correção
		VAO->VAO_CORESP  := oRaic:GetValue('correction_detail', '')
		VAO->VAO_DTCESP  := STOD(oJsonParser:readDate(oRaic:GetValue('correction_date')))
		VAO->VAO_HRCESP  := oJsonParser:readHour( oRaic:GetValue('correction_hour', "0") )

		////causa
		VAO->VAO_CAUPRB  := oRaic:GetValue('cause_detail', '')
		VAO->VAO_DTCPRB  := STOD(oJsonParser:readDate(oRaic:GetValue('cause_date')))
		VAO->VAO_HRCPRB  := oJsonParser:readHour( oRaic:GetValue('cause_hour', "0") )

		//// pós correção
		VAO->VAO_APOCOR  := oRaic:GetValue('post_correction_detail', '')
		VAO->VAO_DTACOR  := STOD(oJsonParser:readDate(oRaic:GetValue('post_correction_date')))
		VAO->VAO_HRACOR  := oJsonParser:readHour( oRaic:GetValue('post_correction_hour', "0") )

		VAO->(MsUnLock())
	END TRANSACTION
Return VAO->(recno())

/*/{Protheus.doc} GtEquipe
	Devolve todos os registros de equipe para cadastro do RAIC

	@author Vinicius Gati
	@since 31/03/2015

/*/
WSMETHOD GtEquipe WSRECEIVE  cCpfSeller, cAToken WSSEND RESP WSSERVICE RAIC
	Local cJson    := '{ "equipe" : ['
	Local lFirst   := .T.

	FS_StFilial(cCpfSeller)
	oToken := Mil_Token():New()
	if .T. // oToken:Busca(cAToken)
		DbselectArea("VAI")
		DbSetOrder(1)
		VAI->( MsSeek( xFilial('VAI') ) )
		While ! VAI->(EOF()) .AND. VAI->VAI_FILIAL == xFilial('VAI')
			if EMPTY(VAI->VAI_CODUSR)
				VAI->(DbSkip())
				LOOP
			endif

			if(lFirst) // primeiro?
				lFirst := .F.
			else
				cJson += ',' // separa os itens do SetArray
			EndIf
			cJson += ' { "recno": ' + STR(VAI->(recno())) + ', "name": "' + ALLTRIM(STRTRAN(VAI->VAI_NOMTEC, '"', "'")) + '" } '

			VAI->(DbSkip())
		End
		VAI->(dbCloseArea())

		cJson  += '] }'
		::RESP := cJson
	else
		::RESP := '{ "error" : "Token de acesso inválido" }'
	endIf
	::RESP := NOACENTO(::RESP)
Return .T.

/*/{Protheus.doc} LGCPFSELLER
	Função usada para logar um usuario via webservice, hoje o controle é somente o cpf
	
	@type function
	@author Vinicius Gati
	@since 31/08/2017
/*/
Function LGCPFSELLER(cCpfSeller)
	Local cSQLSA3 := "aliasSA3"
	Local cQuery  := ""
	Local cFili    := ""
	cCpfSeller    := STRTRAN(cCpfSeller, '.', '')
	cCpfSeller    := STRTRAN(cCpfSeller, ',', '')
	cCpfSeller    := STRTRAN(cCpfSeller, '-', '')

	cQuery := " SELECT R_E_C_N_O_ as RECNO FROM " + RetSqlName('SA3') + " SA3 WHERE SA3.D_E_L_E_T_ = ' ' AND SA3.A3_FILIAL = '" + xFilial('SA3') + "' "
	cQuery += "    AND REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(A3_CGC, '.', ''), ',', ''), '-', ''), '\', ''), '/', '') =  '" + cCpfSeller +"' "
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cSQLSA3 , .F., .T. )
	(cSQLSA3)->(DbGoTop())
	While !(cSQLSA3)->(EOF())
		DbselectArea('SA3')
		SA3->(DBGOTO((cSQLSA3)->(RECNO)))
		(cSQLSA3)->(dbCloseArea())

		nRecno:= FM_SQL(" SELECT R_E_C_N_O_ FROM " + RetSqlName("VAI") +" VAI WHERE VAI.VAI_CODVEN = '" + SA3->A3_COD + "' AND VAI.D_E_L_E_T_ =  ' ' ")

		VAI->(dbGoTo(nRecno))
		__cUserId := VAI->VAI_CODUSR
		cFilAnt   := VAI->VAI_FILPRO
		conout("Vendedor com cpf:" + cCpfSeller + " Logado na filial: " + cFilAnt + " Teste de login correto: "+ xFilial('VS3')+" Usuario: " + VAI->VAI_CODUSR)
		return .T.
	End
	(cSQLSA3)->(dbCloseArea())
Return .t.


/*/{Protheus.doc} FS_StoJS
	Usado para converter string em advpl para formato valido em java/javascript/json

	@author Vinicius Gati
	@since 05/01/2015
/*/
Static Function FS_StoJS(cStr)
	Local aRem := {(CHR(13)+ CHR(10)), CHR(13), CHR(10), CHR(9), CHR(11)}
	Local var := 0

	for var:= 1 to Len(aRem)
		cStr := STRTRAN( cStr, aRem[var], "\n" )
	next
	cStr := LTRIM(cStr)
Return cStr


/*/{Protheus.doc} FS_DtoJS
	Formata uma data ADVPL forcando 4 digitos no ano, coisa que muda no advpl de acordo com configuracao de usuario
	e não pode mudar no webservice

	@author Vinicius Gati
	@since 08/01/2015
/*/
Static Function FS_DtoJS(dDate)
	Local cData := nil
	Local cDataOk := ""

	if VALTYPE(dDate) == "D"
		cData := DTOS(dDate)
		cDataOk += RIGHT(cData, 2) + "/"
		cDataOk += RIGHT( LEFT(cData,6) , 2) + "/"
		cDataOk += LEFT(cData, 4)
	else
		Return "null"
	endIf
Return cDataOk


/*/{Protheus.doc} FS_PtoJS
	Recebe ddd e telefone do cadastro de clientes e formata de modo que fique bacana para colocar no json para sofwares cliente usarem

	@author Vinicius Gati
	@since 14/01/2015

	@return String, formato "00 0000-0000"

/*/
Static Function FS_PtoJS(cDDD, cTel)
	// se nulo retorna ""
	cDDD := IIF(EMPTY(cDDD), "", cDDD)
	cTel := IIF(EMPTY(cTel), "", cTel)

	// removendo espacos em branco
	cDDD := ALLTRIM(STRTRAN(cDDD, " ", ""))
	cTel := ALLTRIM(STRTRAN(cTel, " ", ""))

	// pegando somente o numero correto em caso de bases teste e celulares com 9 nros pegamos 8
	cDDD := RIGHT(cDDD , 2)
	cTel := cTel
Return cDDD + cTel



/*/{Protheus.doc} FS_FndCpf
	Retorna se o cpf existe cadastrado ou não

	@author Vinicius Gati
	@since 14/01/2015

	@return String, formato "00 0000-0000"

/*/
Static Function FS_FndCpf(cCpfSeller)
	return LGCPFSELLER(cCpfSeller)
Return .F.

/*/{Protheus.doc} FS_StFilial
	Retorna se o cpf existe cadastrado ou não

	@author Vinicius Gati
	@since 14/01/2015

	@return Boolean , caso falso não tem o campo preenchido e deve-se abortar

/*/
Static Function FS_StFilial(cCpfSeller)
	return LGCPFSELLER(cCpfSeller)
Return .F.

/*/{Protheus.doc} FS_RnoToJson
	Retorna recno do json verificando se foi selecionado o alias, caso não retorna "0" para o json

	@author Vinicius Gati
	@since 17/01/2015
	@param cCpfSeller , cpf do vendedor usuario do ambiente mobile
/*/
Static Function FS_RnoToJson(cAl)
	If ((cAl)->(EOF()))
		Return "0"
	End
Return ALLTRIM(STR((cAl)->(recno())))

/*/{Protheus.doc} WSCEV001_ConcatJson
	Remove caractere problematico para json

	@author Vinicius Gati
	@since 10/04/2017

/*/
Function WSCEV001_ConcatJson(cValue)
	cValue := STRTRAN(cValue, '"', "'")
	cValue := STRTRAN(cValue, '/', '_  ')
	cValue := STRTRAN(cValue, '\', '_ ')
	cValue := STRTRAN(cValue, '}', '__ ')
	cValue := STRTRAN(cValue, '{', '__  ')
RETURN ALLTRIM(cValue)

/*/{Protheus.doc} WSCEV002_NUMToJson
	Retorna o valor 
	
	@type function
	@author Vinicius Gati
	@since 06/02/2018
/*/
Function WSCEV002_NumToJson(nVal)
	Local cVal := ''
	cVal := TRANSFORM(nVal, "@E 999999999.99")
	cVal := " " + ALLTRIM(STRTRAN(cValToChar(cVal), ',', '.'))
Return cVal