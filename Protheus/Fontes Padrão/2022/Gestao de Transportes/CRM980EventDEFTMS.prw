#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"   
#INCLUDE "CRM980EVENTDEFTMS.CH"  

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDEFTMS
Classe respons�vel pelo evento das regras de neg�cio de Gest�o de
Transporte.

@type 		Classe
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventDEFTMS From FwModelEvent 
	
	Data cCEPAnt		As Character
	Data cTelAnt  		As Character
	Data cDDDAnt 		As Character	
	
	Method New() CONSTRUCTOR
	
	//------------------------------------------------------
	// PosValid do Model por modulo.
	//------------------------------------------------------
	Method ModelPosVld()
	
	//---------------------------------------------------------------------
	// Bloco com regras de neg�cio dentro da transa��o do modelo de dados.
	//---------------------------------------------------------------------
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
Method New() Class CRM980EventDEFTMS	
	Self:cCEPAnt	:= ""
	Self:cTelAnt	:= ""
	Self:cDDDAnt 	:= ""
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
M�todo respons�vel por executar as valida��es das regras de neg�cio
do TMS antes da grava��o do formulario.
Se retornar falso, n�o permite gravar.

@type 		M�todo

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cID) Class CRM980EventDEFTMS
	Local lValid 		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oMdlSA1		:= oModel:GetModel("SA1MASTER")
	
	If nOperation == MODEL_OPERATION_UPDATE 
		//---------------------------------------------
		// Propriedade utilizada no TMS.
		//---------------------------------------------
		Self:cCEPAnt	:= SA1->A1_CEP
		Self:cTelAnt  	:= SA1->A1_TEL
		Self:cDDDAnt	:= SA1->A1_DDD	
	EndIf
		
	If ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE ) 
		//---------------------------------------------
		// Integracao com o Modulo de Transporte (TMS)
		//---------------------------------------------		
		If IntTms() .And. nModulo == 43
			If Empty(oMdlSA1:GetValue("A1_CDRDES"))
				Help("",1,"CDRDES") //--"Informe um c�digo de regi�o v�lida para este cliente."
				lValid := .F.
			Endif
		Endif
	EndIf
Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
M�todo respons�vel por executar regras de neg�cio do TMS depois da
transa��o do modelo de dados.

@type 		M�todo

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method InTTS(oModel,cID) Class CRM980EventDEFTMS
	
	Local nOperation	:= oModel:GetOperation()
	Local lRotaInt   	:= SuperGetMV("MV_ROTAINT",,.F.)
	Local lSoliAut      := SuperGetMV("MV_SOLIAUT",,"0")

	If nOperation == MODEL_OPERATION_INSERT
			// Integra��o Rota Inteligente Ou Cadastro Solicitante autom�tico 
			If (lRotaInt .And. ExistFunc("TMSIntRot")) .Or. ( ExistFunc("TMSIntRot") .And. lSoliAut != "0" ) 
				TMSIntRot("SA1",SA1->(Recno())) 
			EndIf
	ElseIf nOperation == MODEL_OPERATION_UPDATE 
		
		If IntTMS()
			//------------------------------------------------------
			// Atualiza��o do movimento de viagem 
			//------------------------------------------------------
			If Self:cCEPAnt <> SA1->A1_CEP
				FWMsgRun(/*oComponent*/,{|| TmsCEPDUD(SA1->A1_CEP,SA1->A1_COD,SA1->A1_LOJA) },,STR0001) //"Atualizando movimento de viagem."
			EndIf
			
			//------------------------------------------------------
			//  Atualiza��o do telefone na Seq.Endereco
			//------------------------------------------------------
			If ( Self:cTelAnt <> SA1->A1_TEL .Or. Self:cDDDAnt <> SA1->A1_DDD )
				FWMsgRun(/*oComponent*/,{|| TmsTELDUL(SA1->A1_DDD,SA1->A1_TEL,SA1->A1_COD,SA1->A1_LOJA,Self:cDDDAnt,Self:cTelAnt)},,STR0001) //"Atualizando movimento de viagem."
			EndIf

			// Integra��o Rota Inteligente Ou Cadastro Solicitante autom�tico 
			If (lRotaInt .And. ExistFunc("TMSIntRot")) .Or. ( ExistFunc("TMSIntRot") .And. lSoliAut != "0" ) 
				TMSIntRot("SA1",SA1->(Recno())) 
			EndIf
			 
		EndIf
	ElseIf nOperation == MODEL_OPERATION_DELETE 
		If ExistFunc("TMSExcDAR") // Integra��o Rota Inteligente
			TMSExcDAR(SA1->A1_COD, SA1->A1_LOJA)
		EndIf
	EndIf
	
Return Nil
