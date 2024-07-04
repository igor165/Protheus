#include 'protheus.ch'

/*/{Protheus.doc} OFJDOktaConfig
	Classe de Configuracao do Okta
	
	@type function
	@author Rubens Takahashi
	@since 27/03/2020
/*/
Class OFJDOktaConfig from LongNameClass
	Data cCodigo
	Data oConfig

	Method New() CONSTRUCTOR

	Method saveConfig()
	Method getConfig()

	Method warranty()
	Method pmLinkJDPoint()
	Method orderStatusJDPoint()
	Method maintainQuoteJDQuote()
	Method poDataJDQuote()
	Method notaFiscalCompra()
	Method DTFGETAPI()
	Method DTFPUTAPI()

	Method getClientID()
	Method getClientSecret()
	Method getRedirURI()

	Method getURLOktaWarranty()
	Method getAuthSrvWarranty()
	Method getPathAuthWarranty()
	Method getScopeWarranty()
	Method getUrlWSWarranty()

	Method getURLOktaPmLinkJdPoint()
	Method getAuthSrvPmLinkJdPoint()
	Method getPathAuthPmLinkJdPoint()
	Method getScopePmLinkJdPoint()
	Method getUrlWSPmLinkJDPoint()

	Method getURLOktaOrderStatusJdPoint()
	Method getAuthSrvOrderStatusJdPoint()
	Method getPathAuthOrderStatusJdPoint()
	Method getScopeOrderStatusJdPoint()
	Method getUrlWSOrderStatusJDPoint()

	Method getURLOktaMaintainQuoteJDQuote()
	Method getAuthSrvMaintainQuoteJDQuote()
	Method getPathAuthMaintainQuoteJDQuote()
	Method getScopeMaintainQuoteJDQuote()
	Method getUrlWSMaintainQuoteJDQuote()

	Method getURLOktaPoDataJDQuote()
	Method getAuthSrvPoDataJDQuote()
	Method getPathAuthPoDataJDQuote()
	Method getScopePoDataJDQuote()
	Method getUrlWSPoDataJDQuote()

	Method getURLOktaNotaFiscalCompra()
	Method getAuthSrvNotaFiscalCompra()
	Method getPathAuthNotaFiscalCompra()
	Method getScopeNotaFiscalCompra()
	Method getUrlWSNotaFiscalCompra()

	Method getURLOktaDTFGETAPI()
	Method getAuthSrvDTFGETAPI()
	Method getPathAuthDTFGETAPI()
	Method getScopeDTFGETAPI()
	Method getUrlWSDTFGETAPI()

	Method getURLOktaDTFPUTAPI()
	Method getAuthSrvDTFPUTAPI()
	Method getPathAuthDTFPUTAPI()
	Method getScopeDTFPUTAPI()
	Method getUrlWSDTFPUTAPI()

	Method _getURLOkta()
	Method _getAuthSrv()
	Method _getPathAuth()
	Method _getScope()
	Method _getURLWS()

EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type function
	@author Rubens Takahashi
	@since 27/03/2020
/*/
Method New() Class OFJDOktaConfig
	::cCodigo := "OFIOA280"
Return SELF

/*/{Protheus.doc} saveConfig
	Salva a configuracao no lugar da atual

	@type function
	@author Rubens Takahashi
	@since 27/03/2020
/*/
Method saveConfig(oConfig) Class OFJDOktaConfig
	local cJson := oConfig:toJson()
	VRN->(dbSetOrder(1))
	if VRN->(dbSeek(xFilial("VRN") + self:cCodigo))
		reclock("VRN", .F.)
		VRN->VRN_CONFIG := cJson
		VRN->(MsUnlock())
	else
		return .f.
	endif
return .t.

/*/{Protheus.doc} getConfig
	Pega a configuracao em formato de data container

	@type function
	@author Rubens Takahashi
	@since 27/03/2020
/*/
Method getConfig() Class OFJDOktaConfig
	local oUtil   := Nil
	local oConfig := JsonObject():New()
	local lVRN := FWAliasInDic("VRN")
	local lExistCfg := .f.

	If lVRN
		VRN->(dbSetOrder(1))
		lExistCfg := VRN->(dbSeek(xFilial("VRN") + self:cCodigo))
		if lExistCfg
			oConfig:FromJson(VRN->VRN_CONFIG)
		endif
	endif

	if ! lVRN .or. ! lExistCfg
		oConfig["OKTA_ID"]  := Space(50)
		oConfig["OKTA_SEC"] := Space(50)
		oConfig["OKTA_REDURI"] := Space(50)

		oConfig['WAROKTA'] := '0'
		oConfig['WARURL'] := PadR("https://sso.johndeere.com",50)
		oConfig['WARAUTHSRV'] := PadR("aus9ddz3lqJc5gDhH1t7",50)
		oConfig['WARURLAUTH'] := PadR("/api/v1/authn",50)
		oConfig['WARSCOPE'] := PadR("openid",50)
		oConfig['WARURLWS'] := PadR("https://servicesext.deere.com:443/PIAbstractProxyOAuth/PIAbstractProxyService", 150)

		oConfig['PMLOKTA'] := '0'
		oConfig['PMLURL'] := PadR("https://sso.johndeere.com",50)
		oConfig['PMLAUTHSRV'] := PadR("aus9mir6too6AdwSD1t7",50)
		oConfig['PMLURLAUTH'] := PadR("/api/v1/authn",50)
		oConfig['PMLSCOPE'] := PadR("openid offline_access",50)
		oConfig['PMLURLWS'] := PadR("https://servicesext.deere.com:443/dns/services/V2/PMLinkMWS_2_3",150)

		oConfig['JDPOKTA'] := '0'
		oConfig['JDPURL'] := PadR("https://sso.johndeere.com",50)
		oConfig['JDPAUTHSRV'] := PadR("aus9mir6too6AdwSD1t7",50)
		oConfig['JDPURLAUTH'] := PadR("/api/v1/authn",50)
		oConfig['JDPSCOPE'] := PadR("openid offline_access",50)
		oConfig['JDPURLWS'] := PadR("https://servicesext.deere.com/dns/services/V2/OrderStatusMWS_2_4",150)

		oConfig['QTMOKTA'] := '0'
		oConfig['QTMURL'] := PadR("https://sso.johndeere.com",50)
		oConfig['QTMAUTHSRV'] := PadR("aus9k0fb8kUjG8S5Z1t7",50)
		oConfig['QTMURLAUTH'] := PadR("/api/v1/authn",50)
		oConfig['QTMSCOPE'] := PadR("openid profile authorities offline_access",50)
		oConfig['QTMURLWS'] := PadR("https://servicesext.deere.com:443/jdquote/v6/maintainquote",150)

		oConfig['QTPOKTA'] := '0'
		oConfig['QTPURL'] := PadR("https://sso.johndeere.com",50)
		oConfig['QTPAUTHSRV'] := PadR("aus9k0fb8kUjG8S5Z1t7",50)
		oConfig['QTPURLAUTH'] := PadR("/api/v1/authn",50)
		oConfig['QTPSCOPE'] := PadR("openid profile authorities offline_access",50)
		oConfig['QTPURLWS'] := PadR("https://servicesext.deere.com:443/jdquote/v1/podataservice",150)

		oConfig['NFSOKTA'] := '0'
		oConfig['NFSURL'] := PadR("https://sso.johndeere.com",50)
		oConfig['NFSAUTHSRV'] := PadR("aus9mir6too6AdwSD1t7",50)
		oConfig['NFSURLAUTH'] := PadR("/api/v1/authn",50)
		oConfig['NFSSCOPE'] := PadR("openid",50)
		oConfig['NFSURLWS'] := PadR("https://servicesext.deere.com/FDSWeb/services/AdvanceShipNoticeWS_1_1",150)

		oConfig['DTFGOKTA'] := '0'
		oConfig['DTFGURL'] := PadR("https://sso.johndeere.com",50)
		oConfig['DTFGAUTHSRV'] := PadR("aus9k0fb8kUjG8S5Z1t7",50)
		oConfig['DTFGURLAUTH'] := PadR("/v1/token",50)
		oConfig['DTFGSCOPE'] := PadR("dtf:dbs:file:read",50)
		oConfig['DTFGURLWS'] := PadR("https://servicesext.deere.com/dtfapi/",150)

		oConfig['DTFPOKTA'] := '0'
		oConfig['DTFPURL'] := PadR("https://sso.johndeere.com",50)
		oConfig['DTFPAUTHSRV'] := PadR("aus9k0fb8kUjG8S5Z1t7",50)
		oConfig['DTFPURLAUTH'] := PadR("/v1/token",50)
		oConfig['DTFPSCOPE'] := PadR("dtf:dbs:file:write",50)
		oConfig['DTFPURLWS'] := PadR("https://servicesext.deere.com/dtfapi/",150)

		if lVRN
			reclock("VRN", .T.)
			VRN->VRN_FILIAL := xFilial("VRN")
			VRN->VRN_CODIGO := self:cCodigo
			oUtil := oConfig:toJson()
			VRN->VRN_CONFIG := oUtil
			VRN->(MsUnlock())
		endif
	endif
	self:oConfig := oConfig
Return oConfig

Method warranty() Class OFJDOktaConfig
return (self:oConfig['WAROKTA'] == '1')

Method pmLinkJDPoint() Class OFJDOktaConfig
return (self:oConfig['PMLOKTA'] == '1')

Method orderStatusJDPoint() Class OFJDOktaConfig
return (self:oConfig['JDPOKTA'] == '1')

Method maintainQuoteJDQuote() Class OFJDOktaConfig
return (self:oConfig['QTMOKTA'] == '1')

Method poDataJDQuote() Class OFJDOktaConfig
return (self:oConfig['QTPOKTA'] == '1')

Method notaFiscalCompra() Class OFJDOktaConfig
return (self:oConfig['NFSOKTA'] == '1')

Method DTFGETAPI() Class OFJDOktaConfig
return (self:oConfig['DTFGOKTA'] == '1')

Method DTFPUTAPI() Class OFJDOktaConfig
return (self:oConfig['DTFPOKTA'] == '1')

Method getClientID() Class OFJDOktaConfig
return self:oConfig['OKTA_ID']

Method getClientSecret() Class OFJDOktaConfig
return self:oConfig['OKTA_SEC']

Method getRedirURI(cPrefixo) Class OFJDOktaConfig
return self:oConfig[ 'OKTA_REDURI']


Method getURLOktaWarranty() Class OFJDOktaConfig
return self:_getURLOkta('WAR')

Method getAuthSrvWarranty() Class OFJDOktaConfig
return self:_getAuthSrv('WAR')

Method getPathAuthWarranty() Class OFJDOktaConfig
return self:_getPathAuth('WAR')

Method getScopeWarranty() Class OFJDOktaConfig
return self:_getScope('WAR')

Method getUrlWSWarranty() Class OFJDOktaConfig
return self:_getUrlWs('WAR')


Method getURLOktaPmLinkJdPoint() Class OFJDOktaConfig
return self:_getURLOkta('PML')

Method getAuthSrvPmLinkJdPoint() Class OFJDOktaConfig
return self:_getAuthSrv('PML')

Method getPathAuthPmLinkJdPoint() Class OFJDOktaConfig
return self:_getPathAuth('PML')

Method getScopePmLinkJdPoint() Class OFJDOktaConfig
return self:_getScope('PML')

Method getUrlWSPmLinkJDPoint() Class OFJDOktaConfig
return self:_getUrlWs('PML')


Method getURLOktaOrderStatusJdPoint() Class OFJDOktaConfig
return self:_getURLOkta('JDP')

Method getAuthSrvOrderStatusJdPoint() Class OFJDOktaConfig
return self:_getAuthSrv('JDP')

Method getPathAuthOrderStatusJdPoint() Class OFJDOktaConfig
return self:_getPathAuth('JDP')

Method getScopeOrderStatusJdPoint() Class OFJDOktaConfig
return self:_getScope('JDP')

Method getUrlWSOrderStatusJDPoint() Class OFJDOktaConfig
return self:_getUrlWs('JDP')


Method getURLOktaMaintainQuoteJDQuote() Class OFJDOktaConfig
return self:_getURLOkta('QTM')

Method getAuthSrvMaintainQuoteJDQuote() Class OFJDOktaConfig
return self:_getAuthSrv('QTM')

Method getPathAuthMaintainQuoteJDQuote() Class OFJDOktaConfig
return self:_getPathAuth('QTM')

Method getScopeMaintainQuoteJDQuote() Class OFJDOktaConfig
return self:_getScope('QTM')

Method getUrlWSMaintainQuoteJDQuote() Class OFJDOktaConfig
return self:_getUrlWs('QTM')


Method getURLOktaPoDataJDQuote() Class OFJDOktaConfig
return self:_getURLOkta('QTP')

Method getAuthSrvPoDataJDQuote() Class OFJDOktaConfig
return self:_getAuthSrv('QTP')

Method getPathAuthPoDataJDQuote() Class OFJDOktaConfig
return self:_getPathAuth('QTP')

Method getScopePoDataJDQuote() Class OFJDOktaConfig
return self:_getScope('QTP')

Method getUrlWSPoDataJDQuote() Class OFJDOktaConfig
return self:_getUrlWs('QTP')


Method getURLOktaNotaFiscalCompra() Class OFJDOktaConfig
return self:_getURLOkta('NFS')

Method getAuthSrvNotaFiscalCompra() Class OFJDOktaConfig
return self:_getAuthSrv('NFS')

Method getPathAuthNotaFiscalCompra() Class OFJDOktaConfig
return self:_getPathAuth('NFS')

Method getScopeNotaFiscalCompra() Class OFJDOktaConfig
return self:_getScope('NFS')

Method getUrlWSNotaFiscalCompra() Class OFJDOktaConfig
return self:_getUrlWs('NFS')


Method getURLOktaDTFGETAPI() Class OFJDOktaConfig
return self:_getURLOkta('DTFG')

Method getAuthSrvDTFGETAPI() Class OFJDOktaConfig
return self:_getAuthSrv('DTFG')

Method getPathAuthDTFGETAPI() Class OFJDOktaConfig
return self:_getPathAuth('DTFG')

Method getScopeDTFGETAPI() Class OFJDOktaConfig
return self:_getScope('DTFG')

Method getUrlWSDTFGETAPI() Class OFJDOktaConfig
return self:_getURLWS('DTFG')


Method getURLOktaDTFPUTAPI() Class OFJDOktaConfig
return self:_getURLOkta('DTFP')

Method getAuthSrvDTFPUTAPI() Class OFJDOktaConfig
return self:_getAuthSrv('DTFP')

Method getPathAuthDTFPUTAPI() Class OFJDOktaConfig
return self:_getPathAuth('DTFP')

Method getScopeDTFPUTAPI() Class OFJDOktaConfig
return self:_getScope('DTFP')

Method getUrlWSDTFPUTAPI() Class OFJDOktaConfig
return self:_getURLWS('DTFP')


Method _getURLOkta(cPrefixo) Class OFJDOktaConfig
return self:oConfig[ cPrefixo + 'URL']

Method _getAuthSrv(cPrefixo) Class OFJDOktaConfig
return self:oConfig[ cPrefixo + 'AUTHSRV']

Method _getPathAuth(cPrefixo) Class OFJDOktaConfig
return self:oConfig[ cPrefixo + 'URLAUTH']

Method _getScope(cPrefixo) Class OFJDOktaConfig
return self:oConfig[ cPrefixo + 'SCOPE']

Method _getUrlWs(cPrefixo) Class OFJDOktaConfig
return self:oConfig[ cPrefixo + 'URLWS']
