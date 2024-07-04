#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"    
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventBRAFIS
Classe responsável pelo evento das regras de negócio da 
localização Brasil fiscal.

@type 		Classe
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventBRAFIS From FwModelEvent 
	
	Data lHistFiscal	As Logical
	Data aCmps			As Array
	Data lFacFis        As Logical
	Data cCodigo        As Character
	Data cLoja          As Character
		
	Method New() CONSTRUCTOR
	
	//---------------------
	// PosValid do Model.
	//---------------------
	Method ModelPosVld()
		
	//-------------------------------------------------------------------
	// Bloco com regras de negócio dentro da transação do modelo de dados.
	//-------------------------------------------------------------------
	Method InTTS()
	
	//-------------------------------------------------------------------
	// Bloco com regras de negócio após a transação do modelo de dados.
	//-------------------------------------------------------------------
	Method AfterTTS()
	
	Method Destroy()
			
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo responsável pela construção da classe.

@type 		Método
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventBRAFIS
	Self:lHistFiscal	:= HistFiscal()
	Self:aCmps			:= {}
	Self:lFacFis        := IIf(FindFunction("FSA172VLD"), FSA172VLD(), .F.)
	Self:cCodigo        := ""
	Self:cLoja          := ""
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
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cID) Class CRM980EventBRAFIS
	Local lValid 		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oMdlSA1		:= oModel:GetModel("SA1MASTER")
	Local bCampoSA1  	:= { |x| SA1->(Field(x)) }

	Self:cCodigo := oModel:GetValue("SA1MASTER","A1_COD")
	Self:cLoja := oModel:GetValue("SA1MASTER","A1_LOJA")
	
	If ( nOperation == MODEL_OPERATION_UPDATE )
		
		If Self:lHistFiscal
			//---------------------------------------------
			// Salva dados antes da alteracao.
			//---------------------------------------------
			Self:aCmps := RetCmps("SA1",bCampoSA1)
			oMdlSA1:LoadValue("A1_IDHIST", IdHistFis())
		EndIf
		
	EndIf
Return lValid
 
//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método responsável por executar regras de negócio do Fiscal dentro da
transação do modelo de dados.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Method InTTS(oModel,cID) Class CRM980EventBRAFIS
	Local nOperation	:= oModel:GetOperation()
	
	If ( nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE )
		//---------------------------------------
		// Gravacao do Historico das alterações
		//---------------------------------------
		If Self:lHistFiscal
			GrvHistFis("SA1", "SS2", Self:aCmps ) 
		EndIf
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS
Método responsável por executar regras de negócio do Fiscal depois da
transação do modelo de dados.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/09/2018
/*/
//-------------------------------------------------------------------
Method AfterTTS(oModel, cID) Class CRM980EventBRAFIS

Local nOperation	:= oModel:GetOperation()

// Não acionar o facilitador de dentro do FISA170 pois se o cliente estiver sendo cadastrado pela
// consulta padrão ele já será vinculado ao perfil.
If Self:lFacFis .And. nOperation == MODEL_OPERATION_INSERT .And. FunName() <> "FISA170"
	FSA172FAC({"CLIENTE", Self:cCodigo, Self:cLoja})
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Metodo responsável por destruir os atributos da classe como 
arrays e objetos.

@type 		Método
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method Destroy() Class CRM980EventBRAFIS
	aSize(Self:aCmps,0)
	Self:aCmps := Nil
Return Nil
