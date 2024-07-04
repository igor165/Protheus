#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"  
#INCLUDE "CRM980EVENTDEFFIS.CH"    
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDEFFIS
Classe responsável pelo evento das regras de negócio do Fiscal.

@type 		Classe 
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventDEFFIS From FwModelEvent 

	Method New() CONSTRUCTOR
	
	//---------------------
	// PosValid do Model.
	//---------------------
	Method ModelPosVld()
	
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo responsável pela construção da classe.

@type 		Método
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventDEFFIS
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método responsável por executar as validações das regras de negócio
do Fiscal antes da gravação do formulario.
Se retornar falso, não permite gravar.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cID) Class CRM980EventDEFFIS
	
	Local lValid 		:= .T.
	Local nOperation	:= oModel:GetOperation()
		
	If ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE )	
		//------------------ 
		// Integração TAF 
		//------------------
		If TAFExstInt()
			FWMsgRun(/*oComponent*/,{|| TAFIntOnLn("T003CLI",nOperation,cFilAnt) },,STR0001) //"Relizando integração do produto com SIGATAF."
		EndIf 		
	EndIf
		
Return lValid