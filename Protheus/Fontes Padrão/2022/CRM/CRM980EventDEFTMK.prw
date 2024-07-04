#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDEFTMK
Classe respons�vel pelo evento das regras de neg�cio do m�dulo de
Call Center TMK.

@type 		Classe
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		08/07/2019 
/*/
//-------------------------------------------------------------------
Class CRM980EventDEFTMK From FwModelEvent 

	Method New() CONSTRUCTOR
	
	//---------------------
	// PosValid do Model. 
	//---------------------
	Method ModelPosVld()
		
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo respons�vel pela constru��o da classe.

@type 		M�todo
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		08/07/2019 
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventDEFTMK
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
M�todo respons�vel por executar as valida��es das regras de neg�cio
gen�ricas do cadastro antes da grava��o do formulario.
Se retornar falso, n�o permite gravar.

@type 		M�todo

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		08/07/2019
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cID) Class CRM980EventDEFTMK
	Local lValid 		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oMdlSA1		:= oModel:GetModel("SA1MASTER")
	Local lPodeApagar   := .T.
	
	If nOperation == MODEL_OPERATION_DELETE  
		// Verifica se existe Atendimento no Teleatendimento ADE
		If FindFunction("Tk510TAxEn")
			lPodeApagar := Tk510TAxEn("SA1", oMdlSA1:GetValue("A1_FILIAL"), oMdlSA1:GetValue("A1_COD") + oMdlSA1:GetValue("A1_LOJA"))
		Endif
		lValid := lPodeApagar
	EndIf
		
Return lValid