#include "protheus.ch"

function OFAGVmiWebService()
return .t.

/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  23/03/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*/{Protheus.doc} OFAGVmiWebService
	Classe responsavel por enviar os dados de um json a agco

	@type class
	@author Vinicius Gati
	@since 28/06/2017
/*/
Class OFAGVmiWebService
	Data cTkSv
	Data cDMS1Sv
	Data cDMS2Sv
	Data cDMS3Sv
	Data cDMS4Sv
	Data cDMS5Sv
	Data cDMS6Sv
	Data lNewTk
	Data lTestEnv
	Data cLastToken
	Data cLastError
	Data cLastRetReq
	Data oVmiParams
	Data nControle
	Data lImpeditivo
	Data oLog 

	Method New() CONSTRUCTOR
	Method Enviar()
	Method NovoToken()
	Method GetToken()
	Method EnviarPost()
	Method ErrorResp()
	Method ResetError()
	Method EndFor()
EndClass

/*/{Protheus.doc} New
	Construtor simples

	@type function
	@author Vinicius Gati
	@since 27/06/2017
/*/
Method New() Class OFAGVmiWebService
	::lTestEnv   := "TESTE" $ GetNewPar("MV_XMILDBG", "NAO") .AND. "AGCO" $ GetNewPar("MV_XMILDBG", "NAO")

	if ::lTestEnv
		::cTkSv   := "https://appsqa.agcoonline.com.br/SecurityApi/Token"
		::cDMS1Sv := "https://api-qa.sa.agcocorp.com/vmi/dealer/inventory"
		::cDMS2Sv := "https://api-qa.sa.agcocorp.com/vmi/dealer/parts"
		::cDMS3Sv := "https://api-qa.sa.agcocorp.com/vmi/dealer/purchaseOrders"
		::cDMS4Sv := "https://api-qa.sa.agcocorp.com/vmi/dealer/sales"
		::cDMS5Sv := "https://api-qa.sa.agcocorp.com/vmi/dealer/lostSales"
		::cDMS6Sv := "https://api-qa.sa.agcocorp.com/vmi/dealer/customer"
	else
		::cTkSv   := "https://apps.agcoonline.com.br/SecurityApi/Token"
		::cDMS1Sv := "https://api.sa.agcocorp.com/vmi/dealer/inventory"
		::cDMS2Sv := "https://api.sa.agcocorp.com/vmi/dealer/parts"
		::cDMS3Sv := "https://api.sa.agcocorp.com/vmi/dealer/purchaseOrders"
		::cDMS4Sv := "https://api.sa.agcocorp.com/vmi/dealer/sales"
		::cDMS5Sv := "https://api.sa.agcocorp.com/vmi/dealer/lostSales"
		::cDMS6Sv := "https://api.sa.agcocorp.com/vmi/dealer/customer"
	endif

	::oVmiParams  := OFAGVmiParametros():New()
	::oLog        := DMS_Logger():New()
	::lNewTk      := .T.
	::cLastError  := ""
	::lImpeditivo := .F.
	::nControle   := 0
Return SELF

/*/{Protheus.doc} Enviar
	Limpa variaveis de erro para conectar novamente

	@type function
	@author Vinicius Gati
	@since 27/06/2017
/*/
Method ResetError() Class OFAGVmiWebService
	self:lNewTk     := .T.
	self:cLastError := ""
	self:lImpeditivo := .F.
	self:nControle   := 0
Return .T.

/*/{Protheus.doc} EndFor
	Retorna o endereço para envio da interface

	@type function
	@author Vinicius Gati
	@since 27/06/2017
/*/
Method EndFor(cInterface) Class OFAGVmiWebService
	cInterface := ALLTRIM(STRTRAN(cInterface, '-', ''))
	Do Case
		case cInterface == 'DMS1'
			return self:cDMS1Sv
		case cInterface == 'DMS2'
			return self:cDMS2Sv
		case cInterface == 'DMS3'
			return self:cDMS3Sv
		case cInterface == 'DMS4'
			return self:cDMS4Sv
		case cInterface == 'DMS5'
			return self:cDMS5Sv
		case cInterface == 'DMS6'
			return self:cDMS6Sv
	End Do
Return ''

/*/{Protheus.doc} Enviar
	Função que repassa o enviar para o responsável correto

	@type function
	@author Vinicius Gati
	@since 27/06/2017
/*/
Method Enviar(aParams) Class OFAGVmiWebService
	local oParams  := DMS_DataContainer():New(aParams)
	local aAreaVB6 := GetArea("VB6")
	local aArea    := GetArea()

	dbSelectArea("VB6")
	dbSetOrder(1)
	dbGoTo(oParams:GetValue("RECNO"))
	self:cLastRetReq := ""
	If VB6->VB6_FLGENV == '0'
		if VB6->VB6_NUMTEN < 6 .OR. oParams:GetValue('FORCE', .F.)
			cRetorno := self:EnviarPost(VB6->VB6_INTERF, VB6->VB6_JSON)

			VB6->(reclock("VB6", .f.))
			if Empty(cRetorno)
				VB6->VB6_FLGENV := '1'
			else
				VB6->VB6_ERRO   := self:cLastError
			endif
			VB6->VB6_RETREQ := self:cLastRetReq
			VB6->VB6_NUMTEN += 1
			VB6->VB6_ULTTEN := date()
			VB6->(msunlock())
		else
			if VB6->(fieldPos('VB6_IMPEDI')) > 0
				if VB6->VB6_IMPEDI == '0'
					VB6->(reclock("VB6", .f.))
					VB6->VB6_IMPEDI := '1'
					VB6->(msunlock())
				endif
			endif
		endif
	endif

	RestArea(aAreaVB6)
	RestArea(aArea)
	cErr := self:cLastError
	self:ResetError()
Return cErr

/*/{Protheus.doc} EnviarPost
	Envia o json e caso nao de certo cria um novo token e tenta novamente

	@type function
	@author Vinicius Gati
	@since 28/06/2017
/*/
Method EnviarPost(cInterface, cJson) Class OFAGVmiWebService
	local oResp
	Local cHeadRet := ""
	local aHeadStr
	Local oRestClient

	cEnder := self:EndFor(cInterface)
	cToken := self:GetToken()
	aHeadStr := {;
		"Authorization: Bearer " + cToken,;
		"Content-Type: application/json";
	}

	oRestClient := FWRest():New(cEnder)
	oRestClient:SetPostParams(cJson)
	oRestClient:setPath("")
	oRestClient:Post(aHeadStr)
	self:cLastRetReq := oRestClient:GetResult()
	if ::ErrorResp(self:cLastRetReq)
		// tenta gerar novo token se erro for de autorização
		if "Usuário não autorizado" $ self:cLastError
			self:lNewTk := .T.
			cToken := self:GetToken()
			aHeadStr := {;
				"Authorization: Bearer " + cToken,;
				"Content-Type: application/json";
			}
			oRestClient:Post(aHeadStr)
			self:ErrorResp(oRestClient:GetResult()) // so pra atualizar o erro
		end
	end
return self:cLastError

/*/{Protheus.doc} GetToken
	Retorna um token para ser utilizado

	@type function
	@author Vinicius Gati
	@since 28/06/2017
/*/
Method GetToken() Class OFAGVmiWebService
	Local cHeadRet := ""
	local cResp
	local oFileData
	local oJson
	if self:lNewTk
		aHeadStr := {;
			"X-OpenAM-Username:" + self:oVmiParams:user(),;
			"X-OpenAM-Password:" + self:oVmiParams:pass() ;
		}
		cResp := HttpPost(self:cTkSv,,, 60, aHeadStr, @cHeadRet)
		if cResp != nil
			oJson := DMS_JsonParse():New(cResp)
			oFileData := oJson:ParseToObj()
			self:cLastToken := oFileData:GetValue("tokenId")
		else
			conout("ERRO VMI SERVER: Erro de comunicacao - Nao foi possivel gerar novo token")
			self:cLastToken := "Erro de comunicação"
		endif
	end
	self:lNewTk := .F.
Return self:cLastToken

/*/{Protheus.doc} ErrorResp
	Verifica se a resposta foi de erro

	@type function
	@author Vinicius Gati
	@since 03/07/2017
/*/
Method ErrorResp(cResp) Class OFAGVmiWebService
	if VALTYPE(cResp) == "U"
		cResp := self:cLastError := "Configuração SSL não ok, ou servidor fora do ar."
	elseif '"meta":{"status":400' $ cResp
		self:cLastError := "Requisição inválida, rever formato dos dados enviados"
	elseif '"meta":{"status":401' $ cResp
		self:cLastError := "Usuário não autenticado, verificar usuário e senha"
	elseif '"meta":{"status":403' $ cResp
		self:cLastError := "Usuário não autorizado, usuário não tem acesso aos dados ou token expirado"
	elseif '"meta":{"status":404' $ cResp .or. '"meta":{"status":303' $ cResp
		self:cLastError := "Endereço não encontrado, revisar url de acesso ao serviço."
	elseif '"meta":{"status":409' $ cResp
		self:cLastError := "Conflito no banco de dados, rever dados enviados."
	elseif '"meta":{"status":422' $ cResp
		self:cLastError := "Dados inválidos, rever dados enviados."
	elseif '"meta":{"status":500' $ cResp
		self:cLastError := "Erro inesperado, entrar em contato com o DSS."
	elseif '"meta":{"status":504' $ cResp
		self:cLastError := "Problema de comunicação entre proxy e aplicação, entrar em contato com o DSS."
	end
	self:cLastRetReq := cResp
Return ! Empty(self:cLastError)
