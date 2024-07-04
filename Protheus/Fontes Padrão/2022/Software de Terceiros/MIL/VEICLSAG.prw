////////////////
// Versao 002 //
////////////////

#include "protheus.ch"

Function VEICLSAG()
Return()

/*/{Protheus.doc} DMS_GetDAuto

	@author       Rubens Takahashi
	@since        04/08/2015
	@description  Classe para compatibilizacao - MsNewGetDados vs ExecAuto

/*/
CLASS DMS_GetDAuto
	DATA aHeader
	DATA aCols
	DATA nAt

	METHOD Create() CONSTRUCTOR
	METHOD Enable()
	METHOD Disable()
ENDCLASS

METHOD Create() CLASS DMS_GetDAuto
	::aHeader := {}
	::aCols := {}
	::nAt := 0
Return SELF

METHOD Enable() CLASS DMS_GetDAuto
Return

METHOD Disable() CLASS DMS_GetDAuto
Return

/*/{Protheus.doc} DMS_Geracao

	@author       Vinicius Gati
	@since        03/12/2015
	@description  Classe para guardar dados de configuração de uma geração do PMM

/*/
Class DMS_Geracao
	Data cDia
	Data cHora
	Data cTipo
	Data cProg

	METHOD New() CONSTRUCTOR
	METHOD GetTime()
ENDCLASS

/*/{Protheus.doc} DMS_Geracao
	Simples construtor que formata a hora em padrao 4 digitos pois JD só trabalha com hora e minuto

	@author       Vinicius Gati
	@since        03/12/2015
	@description  Classe para guardar dados de configuração de uma geração do PMM

/*/
METHOD New(cTipo, cProg, cDia, cHora) Class DMS_Geracao
	::cTipo := cTipo
	::cProg := cProg
	::cDia  := cDia
	If LEN(cHora) == 3
		::cHora := "0" + cHora
	Else
		::cHora := cHora
	Endif
Return SELF

/*/{Protheus.doc} DMS_Geracao
	retorna a hora com os segundos zerados para ser usada em comparacao
	
	@author       Vinicius Gati
	@since        03/12/2015
	@description  Classe para guardar dados de configuração de uma geração do PMM

/*/
METHOD GetTime() Class DMS_Geracao
Return self:cHora + "00"
