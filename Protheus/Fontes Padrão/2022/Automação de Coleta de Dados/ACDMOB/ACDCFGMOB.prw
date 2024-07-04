#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'protheus.ch'
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "ACDCFGMOB.ch"



//------------------------------------------------------------------------------
/*/{Protheus.doc} ACDCFGMOB
Classe responsável por retornar uma Listagem com as configurações do MOBILE
@author	 	Andre Maximo 
@since		02/03/2020
@version	12.1.25
/*/
//------------------------------------------------------------------------------
WSRESTFUL ACDCFGMOB DESCRIPTION "retornar uma Listagem com as configurações do MOBILE

WSDATA Configure_mob 	AS STRING	OPTIONAL


/*-------------------Get config--------------------------------------*/


WSMETHOD GET  Configure_mob ;
DESCRIPTION "Retorna dados relacionados ao dicionario dados.";
WSSYNTAX "api/acdcfgmob/v1/config";
PATH "api/acdcfgmob/v1/config"       PRODUCES APPLICATION_JSON

WSMETHOD GET  identification_mob ;
DESCRIPTION "Retorna nome e CNPJ da empresa.";
WSSYNTAX "api/acdcfgmob/v1/identification";
PATH "api/acdcfgmob/v1/identification"       PRODUCES APPLICATION_JSON

END WSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} GET/Code/ACDMOB
Retorna dados da configuração do Mobile

@param  Code    , caracter, Codigo para Pesquisa.
@return cResponse	, Array, JSON com Array

@author	 	André Maximo
@since		03/03/2020
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET  Configure_mob WSRECEIVE Code WSSERVICE ACDCFGMOB
Local cPesqPict 
Local cResponse := " " 
Local cMessage  :=  STR0001//'erro interno'
Local nQuanti   := 0
Local nDecimal  := 0
Local lRet      := .F.
Local oJConfig  := JsonObject():New()

Self:SetContentType("application/json")


//Recebe a configuração do B2_QATU para ajuste de casas decimais.
cPesqPict   := CBPictQtde()
aQtdcpo     := TamSX3("B2_QATU")
If len(aQtdcpo) > 0 
    nQuanti    :=  aQtdcpo[1] 
    nDecimal   :=  aQtdcpo[2]
Endif

If !Empty(cPesqPict)  
    oJConfig["picture"] :=  cPesqPict
    oJConfig["quantity"] := nQuanti
    oJConfig["decimal"]  := nDecimal
    lRet:= .T.
EndIf

If lRet
	cResponse := oJConfig:toJson()
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

If ValType(oJConfig) == "O"
	FreeObj(oJConfig)
	oJConfig := Nil
Endif


Return (lRet)


/*/{Protheus.doc} retorna itens da nota/pre nota
 Altera o Status da separacao ou finaliza no protheus

@param	tabela Temp
@author	 	andre.maximo
@since		06/03/2020
@version	12.1.25
/*/
 
function AcdMobEmb(cProd,nQtdOri)

Local aEtiqueta	:= {}
Local nQtdEmb	:= 0
Local nQE		:= 1
Local nQtdeProd := 0
Default cProd	:= CriaVar("B1_COD",.F.)
Default nQtdOri := 0

aEtiqueta := CBRetEtiEAN(cProd)
If len(aEtiqueta) > 0
	nQtdEmb := aEtiqueta[2]
EndIf


If ! CBProdUnit(cProd)
	nQE := CBQtdEmb(cProd)
	If	Empty(nQE)
		nQE := 1
	EndIf
EndIf
nQtdeProd:= nQtdOri * nQE * nQtdEmb


Return nQtdeProd



//-------------------------------------------------------------------
/*/{Protheus.doc} GET/Code/ACDMOB
Retorna dados da configuração do Mobile

@return cResponse	, Array, JSON com Array
@author	 	Robson Santos
@since		12/06/2020
@version	12.1.25
/*/
//-------------------------------------------------------------------
WSMETHOD GET  identification_mob WSSERVICE ACDCFGMOB
Local aFil      := {}
Local cResponse := " " 
Local cMessage  :=  STR0001//'erro interno'
Local lRet      := .F.
Local oJIdent   := JsonObject():New()

Self:SetContentType("application/json")

aFil := FWArrFilAtu()

If Len(aFil) > 0
    oJIdent["companyName"]  := aFil[17]
    oJIdent["id"]           := aFil[18]
    lRet:= .T.
EndIf

If lRet
	cResponse := oJIdent:toJson()
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

If ValType(oJIdent) == "O"
	FreeObj(oJIdent)
	oJIdent := Nil
Endif

Return (lRet)


