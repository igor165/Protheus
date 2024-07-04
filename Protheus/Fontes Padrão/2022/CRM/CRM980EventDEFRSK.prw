#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"    

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDEFRSK 
Classe respons�vel pelo evento das regras de neg�cio da 
localiza��o Padr�o RISK.

@type 		Classe
@author 	Squad NT
@version	12.1.25 / Superior
@since		05/06/2020
/*/
//-------------------------------------------------------------------
Class CRM980EventDEFRSK From FwModelEvent 
	
	Method New() CONSTRUCTOR
	
	//---------------------------------------------------------------------
	// Bloco com regras de neg�cio dentro da transa��o do modelo de dados.
	//---------------------------------------------------------------------
	Method InTTS()
	
	//-------------------------------------------------------------------
	// Metodo respons�vel por destruir a classe.
	//-------------------------------------------------------------------
	Method Destroy()
		
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo respons�vel pela constru��o da classe.

@type 		M�todo
@author 	Squad NT
@version	12.1.25 / Superior
@since		05/06/2020
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventDEFRSK
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
M�todo respons�vel por executar regras de neg�cios do RISK dentro da
transa��o do modelo de dados.

@type 		M�todo

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad NT
@version	12.1.25 / Superior
@since		05/06/2020
/*/
//-------------------------------------------------------------------
Method InTTS(oModel,cID) Class CRM980EventDEFRSK
		
	Local nOperation	:= oModel:GetOperation()
	Local lVldOffBalance := FindFunction( "RskIsActive" ) .And. FindFunction( "RskNCtoCli" )

	//-------------------------------------------
	//  Adiciona o privilegios deste registro.
	//-------------------------------------------
	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		//-------------------------------------------
		//  Cria um contato e relaciona ao cliente.
		//-------------------------------------------
		If lVldOffBalance .And. RskIsActive()
			RskNCtoCli()
		EndIf
	EndIf
		
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Metodo respons�vel por destruir os atributos da classe como 
arrays e objetos.

@type 		M�todo
@author 	Squad NT
@version	12.1.25 / Superior
@since		05/06/2020
/*/
//-------------------------------------------------------------------
Method Destroy() Class CRM980EventDEFRSK
Return Nil
