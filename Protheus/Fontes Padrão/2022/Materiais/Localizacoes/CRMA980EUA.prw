#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"   
#INCLUDE "SHOPIFY.CH"
#INCLUDE "ShopifyExt.ch"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA980EUA
Cadastro de clientes para localiza��o EUA.
@param		Nenhum
@return	Nenhum
@author 	Alfredo Medrano 
@version	12.1.17 / Superior
@since		30/03/2021 
/*/
//-------------------------------------------------------------------
Function CRMA980EUA()
	Local oMBrowse	:= BrowseDef()
	
	Private aRotina	:= MenuDef()
	
	//------------------------------------------------------------
	// Variaveis ser�o mantidas at� descontinuar o fonte MATA030
	// devido o uso nas valida��es de campos.
	//------------------------------------------------------------
	Private lCGCValido 	:= .F. // Variavel usada na validacao do CNPJ/CPF (utilizando o Mashup) 
	Private l030Auto   	:= .F. // Variavel usada para saber se � rotina autom�tica
	
	oMBrowse:SetMenuDef("CRMA980EUA")
	oMBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Configura��es do browse de clientes para localiza��o EUA.
@param		Nenhum
@return	Nenhum
@author 	Alfredo Medrano 
@version	12.1.17 / Superior
@since		30/03/2021 
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
	Local oMBrowse := FWLoadBrw("CRMA980")
Return oMBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de clientes para localiza��o EUA.
@param		Nenhum
@return	Nenhum
@author 	Alfredo Medrano 
@version	12.1.17 / Superior
@since		30/03/2021 
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel 	:= FWLoadModel("CRMA980")
	Local oEvtEUA
	
	//-------------------------------------
	// Instala��o do evento da EUA.
	//-------------------------------------
     If SuperGetMv("MV_SHOPIFY",.F.,.F.) .AND. FindFunction("ShpIntAt") 
		If ShpIntAt()
			oEvtEUA := ShpInteg():New()
			oModel:InstallEvent("SHP_" + ID_INT_CUSTOMER ,/*cOwner*/, oEvtEUA)
		EndIf
    EndIf
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface do modelo de dados de clientes para localiza��o EUA.
@param		Nenhum
@return	Nenhum
@author 	Alfredo Medrano 
@version	12.1.17 / Superior
@since		30/03/2021 
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView := FWLoadView("CRMA980")
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu do cadastro de clientes para localiza��o EUA.
@param		Nenhum
@return	Nenhum
@author 	Alfredo Medrano 
@version	12.1.17 / Superior
@since		30/03/2021 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := FWLoadMenuDef("CRMA980")
Return aRotina 
