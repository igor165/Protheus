#INCLUDE "PROTHEUS.CH"  

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA1141() ; Return


//---------------------------------------------------------------------------------
/*/{Protheus.doc} LJCInitialLoadClient

Classe que representa um terminal, alguma vezes denomidado tamb�m como cliente.
  
@author Vendas CRM
@since 07/02/10
/*/
//----------------------------------------------------------------------------------
Class LJCInitialLoadClient From FWSerialize
	Data cLocation
	Data nPort
	Data cEnvironment
	Data cCompany	
	Data cBranch

	Method New()
	Method ToString()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New()

Constructor
  
@param cLocation Endere�o IP ou nome da m�quina
@param nPort Porta
@param cEnvironment Ambiente 
@param cCompany Empresa
@param cBranch Filial

@return Self

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method New( cLocation, nPort, cEnvironment, cCompany, cBranch ) Class LJCInitialLoadClient
	Self:cLocation		:= cLocation
	Self:nPort			:= nPort
	Self:cEnvironment	:= cEnvironment
	Self:cCompany		:= cCompany
	Self:cBranch		:= cBranch
Return    


//-------------------------------------------------------------------
/*/{Protheus.doc} ToString()

Retorna um texto amig�vel com as informa��es do cliente.  
  
@param cSeparator Texto de separa��o das informa��es. 

@return cString Texto amig�vel

@author Vendas CRM
@since 07/02/10 
/*/
//--------------------------------------------------------------------
Method ToString( cSeparator ) Class LJCInitialLoadClient
	Local cString := ""
	Default cSeparator := Chr(13) + Chr(10)
	
	cString := "Location: " + Self:cLocation + cSeparator
	cString += "Port: " + AllTrim(Str(Self:nPort)) + cSeparator
	cString += "Environment: " + Self:cEnvironment + cSeparator
	cString += "Company: " + Self:cCompany + cSeparator
	cString += "Branch: " + Self:cBranch + cSeparator
Return cString