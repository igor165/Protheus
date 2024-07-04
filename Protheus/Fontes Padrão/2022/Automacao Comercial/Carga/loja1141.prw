#INCLUDE "PROTHEUS.CH"  

// O protheus necessita ter ao menos uma função pública para que o fonte seja exibido na inspeção de fontes do RPO.
Function LOJA1141() ; Return


//---------------------------------------------------------------------------------
/*/{Protheus.doc} LJCInitialLoadClient

Classe que representa um terminal, alguma vezes denomidado também como cliente.
  
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
  
@param cLocation Endereço IP ou nome da máquina
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

Retorna um texto amigável com as informações do cliente.  
  
@param cSeparator Texto de separação das informações. 

@return cString Texto amigável

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