#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPPRDCOST.CH"

Function PCPPrdCost()
Return

/*/{Protheus.doc} pcpproductcost
API para consulta de solicitações e pedidos de compra

Function PCPPrdCost()
Return

@type  API
@author douglas.heydt
@since 14/05/2021
@version P12.1.30
/*/
WSRESTFUL pcpproductcost DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Custos de produto"

	WSDATA product  AS STRING  OPTIONAL

	WSMETHOD GET productcost;
	    DESCRIPTION STR0002; //"Busca o custo de um produto"
		WSSYNTAX "api/pcp/v1/pcpproductcost" ;
		PATH "/api/pcp/v1/pcpproductcost" ;
		TTALK "v1"

ENDWSRESTFUL

WSMETHOD GET productcost WSRECEIVE product WSSERVICE pcpproductcost
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := GetPrdCost(Self:product)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil
Return lRet


/*/{Protheus.doc} GetPrdCost
Busca todos os registros de solicitações e pedidos de compra
@type  Function
@author douglas.heydt
@since 14/05/2021
@version P12.1.30
@param 01 cProduct, Caracter, produto que terá o custo buscado
/*/
Function GetPrdCost(cProduct)
	Local aAreaSB1 	 := SB1->(GetArea())
	Local aResult    := {.T.,"",200}
	Local nCusto     := 0
	Local nPos       := 1
	Local nTipoCusto := SuperGetMv("MV_CUSTPRD",.F.,1)
	Local oDados     := JsonObject():New()

	cProduct := Padr(cProduct, GetSx3Cache("B1_COD", "X3_TAMANHO"))
	
	SB1->(MsSeek(xFilial("SB1") + cProduct))
	
	If nTipoCusto == 1
		nCusto := RetFldProd(cProduct,"B1_CUSTD")
	ElseIf nTipoCusto == 2
		nCusto := PegaCmAtu(cProduct, RetFldProd(cProduct,"B1_LOCPAD"))[1]
	ElseIf nTipoCusto == 3
		nCusto := RetFldProd(cProduct,"B1_UPRC")
	EndIf

	oDados["items"] := {}
	aAdd(oDados["items"], JsonObject():New())

	oDados["items"][nPos]['productCost'] := nCusto

	If nPos > 0
		aResult[1] := .T.
		aResult[2] := oDados:toJson()
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003 //"Nenhum registro encontrado"
		aResult[3] := 400
	EndIf

    aSize(oDados["items"],0)
	FreeObj(oDados)
	RestArea( aAreaSB1 )

Return aResult
