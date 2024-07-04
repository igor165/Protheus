#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "CRM980EVENTARG.CH"                                                                                       

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventARG
Classe respons�vel pelo evento das regras de neg�cio da 
localiza��o Argentina.

@type 		Classe
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventARG From FwModelEvent 
		
	Method New() CONSTRUCTOR
	
	//----------------------
	// PosValid do Model.
	//----------------------
	Method ModelPosVld()
		
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
Method New() Class CRM980EventARG
Return Nil

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
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cID) Class CRM980EventARG
	Local lValid 		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oMdlSA1		:= oModel:GetModel("SA1MASTER")
	
	If ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE )
		
		//--------------------------------------------------------------------------------------------------
		// Quando o tipo de cliente for I, M, X ou E o campo do numero de inscricao torna-se obrigatorio.
		// Localizacao Argentina
		//--------------------------------------------------------------------------------------------------
		If oMdlSA1:GetValue("A1_TIPO") $ "IMXE" .And. Empty( oMdlSA1:GetValue("A1_CGC") )
			Help(,,"MDLPVLD",,STR0001,1,0) //"O tipo de cliente selecionado exige o preenchimento do campo CUIT/CUIL."
			lValid := .F.
		EndIf 
		     	
		//--------------------------------------------------------------------------------------------------
		// Se o Tipo de documento (AFIP) for 80 ou 86 devera ser obrigatorio o campo A1_CGC (C.U.I.T.)  
		// qualquer outro valor selecionado devera ser obrigatorio o campo A1_RG. Localizacao Argentina
		// Conforme tabela "OC" do configurador. 
		//--------------------------------------------------------------------------------------------------
		If AllTrim( oMdlSA1:GetValue("A1_AFIP") ) $ "1/7" .And. Empty( oMdlSA1:GetValue("A1_CGC") )
			Help(,,"MDLPVLD",,STR0002,1,0) //"O tipo de documento (AFIP) selecionado exige o preenchimento do campo CUIT/CUIL."
			lValid := .F.
		ElseIf !(AllTrim( oMdlSA1:GetValue("A1_AFIP") ) $ "1/7") .AND. Empty( oMdlSA1:GetValue("A1_RG") ) .AND. !Empty( oMdlSA1:GetValue("A1_AFIP") )
			Help(,,"MDLPVLD",,STR0003,1,0) //"O tipo de documento (AFIP) selecionado exige o preenchimento do campo ID."
			lValid := .F.
		ElseIf !Empty(oMdlSA1:GetValue("A1_CGC")) .AND. Str(Val(oMdlSA1:GetValue("A1_AFIP")),2) $ "80|86| 1"
			//Valida��o do CUIT no TudoOK pois o usuario poder� escolher outro tipo de documento que n�o possui valida��o no A1_CGC. 
			//Caso o usuario volte para op��es de CUIT valida��o do formulario pegara a inconsistencia.
			lValid := CUIT(oMdlSA1:GetValue("A1_CGC"),"A1_CGC")
		EndIf
		 
	EndIf		
Return lValid