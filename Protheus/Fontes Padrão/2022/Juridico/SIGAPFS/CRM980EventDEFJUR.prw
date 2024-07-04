#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"   

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDEFJUR
Classe responsável pelo evento das regras de negócio da 
localização Padrão do Jurídico.
 
@type 		Classe
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventDEFJUR From FwModelEvent 
		
	Method New() CONSTRUCTOR
	
	//---------------------
	// PosValid do Model. 
	//---------------------
	Method ModelPosVld()
	
	//----------------------------------------------------------------------
	// Bloco com regras de negócio dentro da transação do modelo de dados.
	//----------------------------------------------------------------------
	Method InTTS()
	
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
Method New() Class CRM980EventDEFJUR	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método responsável por executar as validações das regras de negócio
do Juridico antes da gravação do formulario.
Se retornar falso, não permite gravar.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cID) Class CRM980EventDEFJUR
	Local lValid 		:= .T.
	Local nOperation	:= oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_DELETE
   		//--------------------------------------------------
		// Verificação do cliente nos modulos Juridicos.
		//--------------------------------------------------
   		lValid := A30ValJUR()
	EndIf
Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método responsável por executar regras de negócio do Jurídico dentro da
transação do modelo de dados.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method InTTS(oModel,cID) Class CRM980EventDEFJUR
	
	Local aErrorJUR	:= {}
	Local nOperation	:= oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_DELETE
   		//--------------------------------------------------
		// Verificação do cliente nos modulos Juridicos.
		//--------------------------------------------------
  		A30DelJUR(@aErrorJUR)
	EndIf
	
Return Nil
