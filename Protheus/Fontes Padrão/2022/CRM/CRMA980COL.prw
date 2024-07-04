#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"   
#INCLUDE "CRMA980COL.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA980COL
Cadastro de clientes para localização Colômbia.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT 
@version	12.1.17 / Superior
@since		30/06/2017 
/*/
//-------------------------------------------------------------------
Function CRMA980COL()
	Local oMBrowse	:= BrowseDef()
	
	Private aRotina	:= MenuDef()
	
	//------------------------------------------------------------
	// Variaveis serão mantidas até descontinuar o fonte MATA030
	// devido o uso nas validações de campos.
	//------------------------------------------------------------
	Private lCGCValido 	:= .F. // Variavel usada na validacao do CNPJ/CPF (utilizando o Mashup) 
	Private l030Auto   	:= .F. // Variavel usada para saber se é rotina automática
	
	oMBrowse:SetMenuDef("CRMA980COL")
	oMBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Configurações do browse de clientes para localização Colômbia.

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
Modelo de dados de clientes para localização Colômbia.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		30/06/2017 
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel 	:= FWLoadModel("CRMA980")
	Local oEvtCOL	:= CRM980EventCOL():New()
	
	//-------------------------------------
	// Instalação do evento da Colômbia.
	//-------------------------------------
	oModel:InstallEvent("LOCCOL",/*cOwner*/,oEvtCOL)
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface do modelo de dados de clientes para localização Colômbia.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		30/06/2017 
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView := FWLoadView("CRMA980")
	Local bRespCli := {|| FISA827('SA1',SA1->(RecNo()), 4,1) }
	Local bTribCli := {|| FISA827('SA1',SA1->(RecNo()), 4,2) }
	Local cProvFE  := SuperGetMV("MV_PROVFE",,"")
	
	If !Empty(cProvFE)
		oView:addUserButton(OemToAnsi(STR0005),"MAGIC_BMP", bRespCli, OemToAnsi(STR0005),, {MODEL_OPERATION_UPDATE} ) //"Resp. Obligaciones DIAN"
		oView:addUserButton(OemToAnsi(STR0006),"MAGIC_BMP", bTribCli, OemToAnsi(STR0006),, {MODEL_OPERATION_UPDATE} ) //"Tributos DIAN"
	EndIf
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu do cadastro de clientes para localização Colômbia.

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