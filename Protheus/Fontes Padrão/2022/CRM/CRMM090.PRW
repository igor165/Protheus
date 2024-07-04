#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "CRMM090.CH"

Static aBranchs   := FWAllFilial(nil, nil, nil, .F.)
Static nLenBranch := Len(aBranchs)

//---------------------------------------------------------------
/*/{Protheus.doc} CRMMBRANCHS

Classe responsável por retornar as Filiais do Protheus.

@author	Squad CRM/Faturamento
@since		11/06/2018
@version	12.1.21
/*/
//---------------------------------------------------------------
WSRESTFUL CRMMBRANCHS DESCRIPTION STR0001  // "Retorna as Filiais do Protheus."

	WSDATA page      AS INTEGER OPTIONAL
	WSDATA pageSize  AS INTEGER OPTIONAL

	WSMETHOD GET DESCRIPTION STR0002 WSSYNTAX "/CRMMBRANCHS/{page, pageSize}"  // "Retorna as Filiais"

END WSRESTFUL

//----------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET/CRMMBRANCHS
Retorna as Filiais do Protheus.

@param  Page     	- numérico - Posição da página para ser considerada na consulta. Ex: a partir da página 3.
        PageSize	- numérico - Quantidade de registros a ser retornado na consulta. Ex: 10 registros.

@return lReturn		- lógico   - Indica se a consulta foi bem sucedida ou não.

@author     Squad CRM/Faturamento
@since		11/06/2018
@version	12.1.21
/*/
//---------------------------------------------------------------------------------------------------------------------
WSMETHOD GET WSRECEIVE page, pageSize WSSERVICE CRMMBRANCHS

Local lReturn    := .T.
Local oResponse  := nil
Local oItem      := nil
Local nStart     := 0
Local nFinish    := 0
Local nX

Self:SetContentType("application/json")

If nLenBranch > 0

	Default Self:page := 1
	If Self:page < 0
		Self:page := 1
	Endif

	Default Self:pageSize := 20
	If Self:pageSize < 0 .or. Self:pageSize > 30
		Self:pageSize := 20
	Endif

	oResponse := JsonObject():New()
	oResponse["items"] := {}

	nStart  := ((Self:page - 1) * Self:pageSize) + 1
	nFinish := min((nStart + Self:pageSize - 1), nLenBranch)
	For nX := nStart to nFinish
		oItem := JsonObject():New()
		oItem["code"]        := aBranchs[nX]
		oItem["description"] := EncodeUTF8(FWFilName(cEmpAnt, aBranchs[nX]))
		aAdd(oResponse["items"], oItem)
	Next nX
	oResponse['hasNext'] := (nLenBranch > nFinish)

	Self:SetResponse(oResponse:toJson())
Else
	SetRestFault(400, EncodeUTF8(STR0003))  // "Filiais não encontradas..."
	lReturn := .F.
EndIf

Return lReturn
