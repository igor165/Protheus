#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"   
#INCLUDE "CRM980EVENTDEFTMS.CH"  

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDEFTMS
Classe responsável pelo evento das regras de negócio de Gestão de
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
Method New() Class CRM980EventDEFTMS	
	Self:cCEPAnt	:= ""
	Self:cTelAnt	:= ""
	Self:cDDDAnt 	:= ""
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método responsável por executar as validações das regras de negócio
do TMS antes da gravação do formulario.
Se retornar falso, não permite gravar.

@type 		Método

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
				Help("",1,"CDRDES") //--"Informe um código de região válida para este cliente."
				lValid := .F.
			Endif
		Endif
	EndIf
Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método responsável por executar regras de negócio do TMS depois da
transação do modelo de dados.

@type 		Método

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
			// Integração Rota Inteligente Ou Cadastro Solicitante automático 
			If (lRotaInt .And. ExistFunc("TMSIntRot")) .Or. ( ExistFunc("TMSIntRot") .And. lSoliAut != "0" ) 
				TMSIntRot("SA1",SA1->(Recno())) 
			EndIf
	ElseIf nOperation == MODEL_OPERATION_UPDATE 
		
		If IntTMS()
			//------------------------------------------------------
			// Atualização do movimento de viagem 
			//------------------------------------------------------
			If Self:cCEPAnt <> SA1->A1_CEP
				FWMsgRun(/*oComponent*/,{|| TmsCEPDUD(SA1->A1_CEP,SA1->A1_COD,SA1->A1_LOJA) },,STR0001) //"Atualizando movimento de viagem."
			EndIf
			
			//------------------------------------------------------
			//  Atualização do telefone na Seq.Endereco
			//------------------------------------------------------
			If ( Self:cTelAnt <> SA1->A1_TEL .Or. Self:cDDDAnt <> SA1->A1_DDD )
				FWMsgRun(/*oComponent*/,{|| TmsTELDUL(SA1->A1_DDD,SA1->A1_TEL,SA1->A1_COD,SA1->A1_LOJA,Self:cDDDAnt,Self:cTelAnt)},,STR0001) //"Atualizando movimento de viagem."
			EndIf

			// Integração Rota Inteligente Ou Cadastro Solicitante automático 
			If (lRotaInt .And. ExistFunc("TMSIntRot")) .Or. ( ExistFunc("TMSIntRot") .And. lSoliAut != "0" ) 
				TMSIntRot("SA1",SA1->(Recno())) 
			EndIf
			 
		EndIf
	ElseIf nOperation == MODEL_OPERATION_DELETE 
		If ExistFunc("TMSExcDAR") // Integração Rota Inteligente
			TMSExcDAR(SA1->A1_COD, SA1->A1_LOJA)
		EndIf
	EndIf
	
Return Nil
