#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"    
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventBRAFIS
Classe respons�vel pelo evento das regras de neg�cio da 
localiza��o Brasil fiscal.

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
	// Bloco com regras de neg�cio dentro da transa��o do modelo de dados.
	//-------------------------------------------------------------------
	Method InTTS()
	
	//-------------------------------------------------------------------
	// Bloco com regras de neg�cio ap�s a transa��o do modelo de dados.
	//-------------------------------------------------------------------
	Method AfterTTS()
	
	Method Destroy()
			
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo respons�vel pela constru��o da classe.

@type 		M�todo
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
M�todo respons�vel por executar as valida��es das regras de neg�cio
do Fiscal antes da grava��o do formulario.
Se retornar falso, n�o permite gravar.

@type 		M�todo

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
M�todo respons�vel por executar regras de neg�cio do Fiscal dentro da
transa��o do modelo de dados.

@type 		M�todo

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
		// Gravacao do Historico das altera��es
		//---------------------------------------
		If Self:lHistFiscal
			GrvHistFis("SA1", "SS2", Self:aCmps ) 
		EndIf
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS
M�todo respons�vel por executar regras de neg�cio do Fiscal depois da
transa��o do modelo de dados.

@type 		M�todo

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/09/2018
/*/
//-------------------------------------------------------------------
Method AfterTTS(oModel, cID) Class CRM980EventBRAFIS

Local nOperation	:= oModel:GetOperation()

// N�o acionar o facilitador de dentro do FISA170 pois se o cliente estiver sendo cadastrado pela
// consulta padr�o ele j� ser� vinculado ao perfil.
If Self:lFacFis .And. nOperation == MODEL_OPERATION_INSERT .And. FunName() <> "FISA170"
	FSA172FAC({"CLIENTE", Self:cCodigo, Self:cLoja})
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Metodo respons�vel por destruir os atributos da classe como 
arrays e objetos.

@type 		M�todo
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method Destroy() Class CRM980EventBRAFIS
	aSize(Self:aCmps,0)
	Self:aCmps := Nil
Return Nil
