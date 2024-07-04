#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"   

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDEFJUR
Classe respons�vel pelo evento das regras de neg�cio da 
localiza��o Padr�o do Jur�dico.
 
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
	// Bloco com regras de neg�cio dentro da transa��o do modelo de dados.
	//----------------------------------------------------------------------
	Method InTTS()
	
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo respons�vel pela constru��o da classe.

@type 		M�todo
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventDEFJUR	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
M�todo respons�vel por executar as valida��es das regras de neg�cio
do Juridico antes da grava��o do formulario.
Se retornar falso, n�o permite gravar.

@type 		M�todo

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
		// Verifica��o do cliente nos modulos Juridicos.
		//--------------------------------------------------
   		lValid := A30ValJUR()
	EndIf
Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
M�todo respons�vel por executar regras de neg�cio do Jur�dico dentro da
transa��o do modelo de dados.

@type 		M�todo

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
		// Verifica��o do cliente nos modulos Juridicos.
		//--------------------------------------------------
  		A30DelJUR(@aErrorJUR)
	EndIf
	
Return Nil
