#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"   

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDEFFAT
Classe responsável pelo evento das regras de negócio da 
localização Padrão Faturamento.
 
@type 		Classe 
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventDEFFAT From FwModelEvent 

	Data cVendAnt 	As Character
	Data cNomeAnt 	As Character
	Data cCGCAnt 		As Character
	
	Method New() CONSTRUCTOR
	
	//---------------------
	// PosValid do Model.
	//---------------------
	Method ModelPosVld()
	
	//----------------------------------------------------------------------
	// Bloco com regras de negócio dentro da transação do modelo de dados.
	//---------------------------------------------------------------------
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
Method New() Class CRM980EventDEFFAT	
	Self:cVendAnt 	:= ""
	Self:cNomeAnt 	:= ""
	Self:cCGCAnt 		:= ""
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método responsável por executar as validações das regras de negócio
do Faturamento antes da gravação do formulario.
Se retornar falso, não permite gravar.


@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cID) Class CRM980EventDEFFAT
	Local lValid 		:= .T.
	Local nOperation	:= oModel:GetOperation()
	
	If ( lValid .And. nOperation == MODEL_OPERATION_UPDATE )
		//---------------------------------------------
		// Propriedade utilizada na manutenção da ADL.
		//---------------------------------------------
		Self:cVendAnt := SA1->A1_VEND 	
		Self:cNomeAnt := SA1->A1_NOME	
		Self:cCGCAnt 	:= SA1->A1_CGC
	EndIf
Return lValid

///-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método responsável por executar regras de negócio do Faturamento 
dentro da transação do modelo de dados.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method InTTS(oModel,cID) Class CRM980EventDEFFAT
	
	Local lAtuADL 	:= SuperGetMv("MV_CRMADL",,.T.)  				//Indica se a ADL deverá ter manutenção.
	Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT	
	
		//------------------------------------------------------
		// Manutenção da tabela ADL - WorkArea do Faturamento 
		//------------------------------------------------------
		If ( lAtuADL .And. !Empty(SA1->A1_VEND) )
			Ft520Inc(SA1->A1_VEND,"SA1",SA1->A1_COD,SA1->A1_LOJA) 
		EndIf

	ElseIf nOperation == MODEL_OPERATION_UPDATE	
	
		//-----------------------------------------------------
		// Manutenção da tabela ADL - WorkArea do Faturamento 
		//-----------------------------------------------------
		If lAtuADL  
			If Empty( Self:cVendAnt ) .And. !Empty( SA1->A1_VEND )
				Ft520Inc( SA1->A1_VEND, "SA1", SA1->A1_COD, SA1->A1_LOJA )
			ElseIf !Empty( Self:cVendAnt ) .And. SA1->A1_VEND <> Self:cVendAnt
				Ft520Alt( Self:cVendAnt, SA1->A1_VEND, "SA1", SA1->A1_COD, SA1->A1_LOJA )
			EndIf 
			
			If ( ( Self:cCGCAnt <> SA1->A1_CGC ) .Or. ( Self:cNomeAnt <> SA1->A1_NOME ) )
				Ft520AtuEn("SA1", SA1->A1_COD, SA1->A1_LOJA, SA1->A1_NOME, SA1->A1_CGC)
			EndIf
		EndIf 
	
	ElseIf nOperation == MODEL_OPERATION_DELETE
		
		//-----------------------------------------------------
		// Manutenção da tabela ADL - WorkArea do Faturamento 
		//-----------------------------------------------------
		If lAtuADL .And. !Empty(SA1->A1_VEND)
			Ft520Del(SA1->A1_VEND,"SA1",SA1->A1_COD,SA1->A1_LOJA)
			Ft520AltEn(5,SA1->A1_VEND,"SA1",SA1->A1_COD,SA1->A1_LOJA)
		EndIf	
		
	EndIf 
	
Return Nil