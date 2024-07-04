#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "CRM980EventCOL.CH"   

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventCOL
Classe respons�vel pelo evento das regras de neg�cio da 
localiza��o Col�mbia.

@type 		Classe
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventCOL From FwModelEvent 
		
	Method New() CONSTRUCTOR
	
	//---------------------
	// PosValid do Model. 
	//---------------------
	Method ModelPosVld()

	//----------------------------------------------------------------------
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
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventCOL
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
Method ModelPosVld(oModel,cID) Class CRM980EventCOL
	Local lValid 		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oMdlSA1		:= oModel:GetModel("SA1MASTER")
	
	If ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE )
		
		If !Empty( oMdlSA1:GetValue("A1_TIPDOC") )
		
			If AllTrim(oMdlSA1:GetValue("A1_TIPDOC")) == "31" //Tipo de Documento de Indetificacion NIT
				If Empty( oMdlSA1:GetValue("A1_CGC") )	                                          
					Help(,,"MDLPVLD",,STR0001,1,0) //"Deve ser indicado o campo NIT do Cliente."
			   		lValid := .F.
			    EndIf              
			    If !Empty( oMdlSA1:GetValue("A1_PFISICA") )
			    	Help(,,"MDLPVLD",,STR0002,1,0) //"O campo RG/Ced. Ext. deve estar vazio."
			    	lValid := .F.
			    EndIf
			Else
			    If !Empty( oMdlSA1:GetValue("A1_CGC") )	                                          
			    	Help(,,"MDLPVLD",,STR0003,1,0) //"O campo NIT do Cliente deve estar vazio."
			    	lValid := .F.
			    EndIf              
			    If Empty( oMdlSA1:GetValue("A1_PFISICA") )
			    	Help(,,"MDLPVLD",,STR0004,1,0) //"Deve ser indicado o campo RG/Ced Ext."
			    	lValid := .F.
			    EndIf
			EndIf
		
		EndIf
		If lValid .And. nOperation == MODEL_OPERATION_UPDATE .And. FindFunction("M030ValMov") .And. M030ValMov(oMdlSA1:GetValue("A1_COD"), oMdlSA1:GetValue("A1_LOJA"))
			Help(,,"MDLPVLD",,STR0005,1,0,,,,,,{STR0006}) //"Hubo cambios en el NIT o la C�dula Extranjera, sin embargo, existen movimientos contables asociados (tablas CT2, CVX o CVY) a esos ID." # "Debe retornar los valores de dichos campos para continuar."
			lValid := .F.
		EndIf
	EndIf            	
Return lValid

///-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
M�todo respons�vel por executar regras de neg�cio do Faturamento 
dentro da transa��o do modelo de dados.

@type 		M�todo

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad Mercado Internacional - Colombia
@version	12.1.17 / Superior
@since		15/06/2022 
/*/
//-------------------------------------------------------------------
Method InTTS(oModel,cID) Class CRM980EventCOL
	Local nOperation := oModel:GetOperation()
	Local lOpc       := .T.
	Local cFilCV0    := xFilial("CV0")
	If nOperation == MODEL_OPERATION_INSERT	.Or. nOperation == MODEL_OPERATION_UPDATE //Inclusi�n - Modificaci�n
		If nOperation == MODEL_OPERATION_UPDATE
			lOpc := .F.
		EndIf
		//Inclusi�n/Modificaci�n de registro en CV0
		M030AltCV0(lOpc) 
	ElseIf nOperation == MODEL_OPERATION_DELETE //Borrado
		DbSelectArea("CV0")
		CV0->(DbSetOrder(4)) //CV0_FILIAL + CV0_COD + CV0_TIPO00 + CV0_CODIGO
		If CV0->(DbSeek(cFilCV0 + SA1->A1_COD + '01' + SA1->A1_CGC)) .Or. CV0->(DbSeek(cFilCV0 + SA1->A1_COD + '01' + SA1->A1_PFISICA))
			RecLock("CV0",.F.)
			CV0->(dbDelete())
			CV0->(MsUnlock())
		EndIf                
	EndIf
Return Nil
