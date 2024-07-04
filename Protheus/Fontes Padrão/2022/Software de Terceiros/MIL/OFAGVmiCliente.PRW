#include "protheus.ch"

function OFAGVmiCliente()
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

/*/{Protheus.doc} OFAGVmiCliente
	Interface DMS-6 da definição do VMI

	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiCliente from OFAGVmiBase
	Data cIntName

	Method New() CONSTRUCTOR
	Method GetDadosCliente()
	Method Trigger()
EndClass

Method New() Class OFAGVmiCliente
	_Super:New()
	::cIntName := "DMS-6"
	AADD(::aMapValid, {"data:customer:countryCode"  , "P003"})
	AADD(::aMapValid, {"data:customer:stateCode"    , "P004"})
	AADD(::aMapValid, {"data:customer:lastSalesDate", "P001"})
return self

/*/{Protheus.doc} Trigger
	Gera cabecalho do json, manda buscar os dados das peças grava json e retorna numero de controle, todas as classes vmi de interface terão esse método

	@param oParams, DMS_DataContainer , Traz os dados basicos para criar uma requisição de interface, neste caso peças
	@author Vinicius Gati
	@since 20/06/2017
/*/
Method Trigger(oParams) class OFAGVmiCliente
	Local oJson := DMS_DataContainer():New()

	SA1->(dbGoTo(self:oFilHlp:GetCliente(cFilAnt)))
	oJson:SetValue("dealerLegalNumber", self:fmtDoc(self:oVmiParametros:DocMatriz()))
	oJson:SetValue("extractionDateTime", FWTIMESTAMP(5))
	oJson:SetValue("customer", self:GetDadosCliente(;
		oParams:GetValue("CODIGO"),;
		oParams:GetValue("LOJA")   ;
	))
Return self:oVmiJson:Persist(self:cIntName, oParams, {oJson}, oParams:GetValue('NUMCONTROLE'))

/*/{Protheus.doc} GetDadosCliente
	Retorna um DataContainer com dados necessarios para geração do json interface dms-6 conforme:<br>
	"customer": {<br>
      "customerLegalNumber": "00.000.000/0001-00",<br>
      "customerId": "AAA-12345678",<br>
      "customerName": "NOME DO CLIENTE",<br>
      "countryCode": "BR",<br>
      "stateCode": "BR-RS",<br>
      "cityName": "Canoas",<br>
      "lastSalesDate": "2016-11-23T10:45:00+03:00",<br>
      "type": "RC"<br>
    }<br>

	@param oParams, DMS_DataContainer , Traz os dados basicos para criar uma requisição de interface, neste caso peças
	@author Vinicius Gati
	@since 20/06/2017
/*/
Method GetDadosCliente(cCod, cLoja) class OFAGVmiCliente
	Local oCli := Nil
	Local cInd := xFilial('SA1') + cCod + cLoja // o indice 1 vai servir de codigo para o VMI pois o codigo somente não serve de data
	Local cDoc

	dbselectArea('SA1')
	dbSetOrder(1)
	dbSeek( cInd )

	oCli := DMS_DataContainer():New({;
		{'customerLegalNumber', SA1->A1_CGC },;
		{'customerId'         , cInd        },;
		{'customerName'       , SA1->A1_NOME},;
		{'countryCode'        , 'BR'        },;
		{'stateCode'          , 'BR-' + SA1->A1_EST },;
		{'cityName'           , SA1->A1_MUN } ;
	})
	cDoc := oCli:GetValue('customerLegalNumber')
	if empty(cDoc)
		oCli:RemAttr('customerLegalNumber')
	elseif LEN(ALLTRIM(cDoc)) > 11
		oCli:SetValue('customerLegalNumber', TRANSFORM(cDoc,"@R 99.999.999/9999-99")) //CNPJ
	else
		oCli:SetValue('customerLegalNumber', TRANSFORM(cDoc, "@R 999.999.999-99")) // CPF
	EndIf
Return oCli
