#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH" 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA980ARG
Cadastro de clientes para localiza��o Argentina.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior 
@since		30/06/2017
/*/
//-------------------------------------------------------------------
Function CRMA980ARG()
	Local oMBrowse 	:= BrowseDef()
	
	Private aRotina	:= MenuDef()
	
	//------------------------------------------------------------
	// Variaveis ser�o mantidas at� descontinuar o fonte MATA030
	// devido o uso nas valida��es de campos.
	//------------------------------------------------------------
	Private lCGCValido 	:= .F. // Variavel usada na validacao do CNPJ/CPF (utilizando o Mashup) 
	Private l030Auto   	:= .F. // Variavel usada para saber se � rotina autom�tica
	
	oMBrowse:SetMenuDef("CRMA980ARG")
	oMBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Configura��es do browse de clientes para localiza��o Argentina.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		30/06/2017 
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
	Local oMBrowse := FWLoadBrw("CRMA980")
Return oMBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de clientes para localiza��o Argentina.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		30/06/2017 
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel 		:= FWLoadModel("CRMA980")
	Local oEvtARG		:= CRM980EventARG():New()
	Local oEvtARGLOJ	:= CRM980EventARGLOJ():New()
	
	//-------------------------------------
	// Instala��o do evento da Argentina.
	//-------------------------------------
	oModel:InstallEvent("LOCARG",/*cOwner*/,oEvtARG)
	oModel:InstallEvent("LOCARGLOJ",/*cOwner*/,oEvtARGLOJ)
	
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface do modelo de dados de clientes para localiza��o Argentina.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		30/06/2017 
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView := FWLoadView("CRMA980")
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu do cadastro de clientes para localiza��o Argentina.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		30/06/2017 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := FWLoadMenuDef("CRMA980")
Return aRotina 