#include 'protheus.ch'

/*/{Protheus.doc} OFJDDTFConfig
	Classe de Configuracao do DTF
	
	@type function
	@author Jose Silveira
	@since 30/09/2021
/*/
Class OFJDDTFConfig from LongNameClass
	Data cCodigo
	Data oConfig

	Method New() CONSTRUCTOR

	Method saveConfig()
	Method getConfig()

	Method getCGPoll()
	Method getCotacao_Maquina()
	Method getPMMANAGE()
	Method getDPMEXT()
	Method getWarranty()
	Method getIncentivo_Maquina()
	Method get_UP_Incentivo_Maquina()
	Method getJDPRISM()
	Method getParts_Info()
	Method getParts_Locator()
	Method getAuthorized_Parts_Returns()
	Method getParts_Surplus_Returns()
	Method getParts_Subs()
	Method getSMManage()
	Method getDFA()
	Method getELIPS()
	Method getNAO_CLASSIFICADOS()
	Method criaDirDTF()

EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type function
	@author Jose Silveira
	@since 30/09/2021
/*/
Method New() Class OFJDDTFConfig
	::cCodigo := "OFIA410"
Return SELF

/*/{Protheus.doc} saveConfig
	Salva a configuracao no lugar da atual

	@type function
	@author Jose Silveira
	@since 30/09/2021
/*/
Method saveConfig(oConfig) Class OFJDDTFConfig
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
	@author Jose Silveira
	@since 30/09/2021
/*/
Method getConfig() Class OFJDDTFConfig
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

		oConfig['CGPoll'] := Alltrim("\dtf\CGPoll\")
		oConfig['Cotacao_Maquina'] := Alltrim("\dtf\Cotacao_Maquina\")
		oConfig['PMMANAGE'] := Alltrim("\dtf\PMMANAGE\")
		oConfig['DPMEXT'] := Alltrim("\dtf\DPMEXT\")
		oConfig['Warranty'] := Alltrim("\dtf\Warranty\")
		oConfig['Incentivo_Maquina'] := Alltrim("\dtf\Incentivo_Maquina\")
		oConfig['JDPRISM'] := Alltrim("\dtf\JDPRISM\")
		oConfig['Parts_Info'] := Alltrim("\dtf\Parts_Info\")
		oConfig['Parts_Locator'] := Alltrim("\dtf\Parts_Locator\")
		oConfig['Authorized_Parts_Returns'] := Alltrim("\dtf\Authorized_Parts_Returns\")
		oConfig['Parts_Surplus_Returns'] := Alltrim("\dtf\Parts_Surplus_Returns\")
		oConfig['Parts_Subs'] := Alltrim("\dtf\Parts_Subs\")
		oConfig['SMManage'] := Alltrim("\dtf\SMManage\")
		oConfig['DFA'] := Alltrim("\dtf\DFA\")
		oConfig['ELIPS'] := Alltrim("\dtf\ELIPS\")
		oConfig['UP_Incentivo_Maquina'] := Alltrim("\dtf\UP_Incentivo_Maquina\")
		oConfig['NAO_CLASSIFICADOS'] := Alltrim("\dtf\NAO_CLASSIFICADOS\")

		IF lVRN
			reclock("VRN", .T.)
			VRN->VRN_FILIAL := xFilial("VRN")
			VRN->VRN_CODIGO := self:cCodigo
			oUtil := oConfig:toJson()
			VRN->VRN_CONFIG := oUtil
			VRN->(MsUnlock())
		endif

	endif
	IF !ExistDir("\dtf\")
		FM_Direct("\dtf\",.f.,.f.)
	endif

	self:oConfig := oConfig
Return oConfig

Method getCGPoll() Class OFJDDTFConfig
Return self:oConfig['CGPoll']

Method getCotacao_Maquina() Class OFJDDTFConfig
Return self:oConfig['Cotacao_Maquina']

Method getPMMANAGE() Class OFJDDTFConfig
Return self:oConfig['PMMANAGE']

Method getDPMEXT() Class OFJDDTFConfig
Return self:oConfig['DPMEXT']

Method getWarranty() Class OFJDDTFConfig
Return self:oConfig['Warranty']

Method getIncentivo_Maquina() Class OFJDDTFConfig
Return self:oConfig['Incentivo_Maquina']

Method get_UP_Incentivo_Maquina() Class OFJDDTFConfig
Return self:oConfig['UP_Incentivo_Maquina']

Method getJDPRISM() Class OFJDDTFConfig
Return self:oConfig['JDPRISM']

Method getParts_Info() Class OFJDDTFConfig
Return self:oConfig['Parts_Info']

Method getParts_Locator() Class OFJDDTFConfig
Return self:oConfig['Parts_Locator']

Method getAuthorized_Parts_Returns() Class OFJDDTFConfig
Return self:oConfig['Authorized_Parts_Returns']

Method getParts_Surplus_Returns() Class OFJDDTFConfig
Return self:oConfig['Parts_Surplus_Returns']

Method getParts_Subs() Class OFJDDTFConfig
Return self:oConfig['Parts_Subs']

Method getSMManage() Class OFJDDTFConfig
Return self:oConfig['SMManage']

Method getDFA() Class OFJDDTFConfig
Return self:oConfig['DFA']

Method getELIPS() Class OFJDDTFConfig
Return self:oConfig['ELIPS']

Method getNAO_CLASSIFICADOS() Class OFJDDTFConfig
Return self:oConfig['NAO_CLASSIFICADOS']

Method criaDirDTF() Class OFJDDTFConfig

Local aDealer := {}
local i := 1

VE4->(DBSetOrder(1))
DBSelectArea("SX6")
DBSetOrder(1)
DBGoTop()
while !eof()
	if Alltrim(SX6->X6_VAR) == "MV_MIL0005"
		VE4->(DBSeek(SX6->X6_FIL))
		aadd(aDealer, AllTrim(SX6->X6_CONTEUD) )
	endif
	DBSkip()
enddo

IF left(self:oConfig['CGPoll'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['CGPoll'])
		FM_Direct(self:oConfig['CGPoll'],.f.,.f.)
		FM_Direct(self:oConfig['CGPoll']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['CGPoll']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Cotacao_Maquina'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Cotacao_Maquina'])
		FM_Direct(self:oConfig['Cotacao_Maquina'],.f.,.f.)
		FM_Direct(self:oConfig['Cotacao_Maquina']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Cotacao_Maquina']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['PMMANAGE'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['PMMANAGE'])
		FM_Direct(self:oConfig['PMMANAGE'],.f.,.f.)
		FM_Direct(self:oConfig['PMMANAGE']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['PMMANAGE']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['DPMEXT'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['DPMEXT'])
		FM_Direct(self:oConfig['DPMEXT'],.f.,.f.)
		FM_Direct(self:oConfig['DPMEXT']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['DPMEXT']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Warranty'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Warranty'])
		FM_Direct(self:oConfig['Warranty'],.f.,.f.)
		FM_Direct(self:oConfig['Warranty']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Warranty']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Incentivo_Maquina'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Incentivo_Maquina'])
		FM_Direct(self:oConfig['Incentivo_Maquina'],.f.,.f.)
		FM_Direct(self:oConfig['Incentivo_Maquina']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Incentivo_Maquina']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['UP_Incentivo_Maquina'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['UP_Incentivo_Maquina'])
		FM_Direct(self:oConfig['UP_Incentivo_Maquina'],.f.,.f.)
		FM_Direct(self:oConfig['UP_Incentivo_Maquina']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['UP_Incentivo_Maquina']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['JDPRISM'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['JDPRISM'])
		FM_Direct(self:oConfig['JDPRISM'],.f.,.f.)
		FM_Direct(self:oConfig['JDPRISM']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['JDPRISM']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Parts_Info'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Parts_Info'])
		FM_Direct(self:oConfig['Parts_Info'],.f.,.f.)
		FM_Direct(self:oConfig['Parts_Info']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Parts_Info']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Parts_Locator'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Parts_Locator'])
		FM_Direct(self:oConfig['Parts_Locator'],.f.,.f.)
		FM_Direct(self:oConfig['Parts_Locator']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Parts_Locator']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Authorized_Parts_Returns'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Authorized_Parts_Returns'])
		FM_Direct(self:oConfig['Authorized_Parts_Returns'],.f.,.f.)
		FM_Direct(self:oConfig['Authorized_Parts_Returns']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Authorized_Parts_Returns']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Parts_Surplus_Returns'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Parts_Surplus_Returns'])
		FM_Direct(self:oConfig['Parts_Surplus_Returns'],.f.,.f.)
		FM_Direct(self:oConfig['Parts_Surplus_Returns']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Parts_Surplus_Returns']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Parts_Subs'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Parts_Subs'])
		FM_Direct(self:oConfig['Parts_Subs'],.f.,.f.)
		FM_Direct(self:oConfig['Parts_Subs']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Parts_Subs']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['SMManage'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['SMManage'])
		FM_Direct(self:oConfig['SMManage'],.f.,.f.)
		FM_Direct(self:oConfig['SMManage']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['SMManage']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['DFA'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['DFA'])
		FM_Direct(self:oConfig['DFA'],.f.,.f.)
		FM_Direct(self:oConfig['DFA']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['DFA']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['ELIPS'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['ELIPS'])
		FM_Direct(self:oConfig['ELIPS'],.f.,.f.)
		FM_Direct(self:oConfig['ELIPS']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['ELIPS']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif

IF left(self:oConfig['NAO_CLASSIFICADOS'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['NAO_CLASSIFICADOS'])
		FM_Direct(self:oConfig['NAO_CLASSIFICADOS'],.f.,.f.)
		FM_Direct(self:oConfig['NAO_CLASSIFICADOS']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['NAO_CLASSIFICADOS']+aDealer[i]+"\",.f.,.f.)
		Next
	Endif
Endif

return