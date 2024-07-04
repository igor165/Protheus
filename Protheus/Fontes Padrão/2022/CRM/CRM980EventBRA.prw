#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRM980EventBRA.CH"     
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventBRA
Classe respons�vel pelo evento das regras de neg�cio da 
localiza��o Brasil.

@type 		Classe
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventBRA From FwModelEvent 
		
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
Method New() Class CRM980EventBRA
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
Method ModelPosVld(oModel,cID) Class CRM980EventBRA
	Local lValid 		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oModelSA1	:= oModel:GetModel("SA1MASTER") 
	Local cTpPessoa 	:= "" 
	
	If ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE )
		
		//-------------------------------------------------------------------------
		// N�o permite configurar um cliente do tipo exporta��o do Pa�s Brasil.
		//-------------------------------------------------------------------------
		If ( oModelSA1:GetValue("A1_TIPO") == "X" .And. ( oModelSA1:GetValue("A1_PAIS") == "105" .Or. Val(oModelSA1:GetValue("A1_CODPAIS")) == 1058 ) )
			//"N�o ser� poss�vel escolher o Pa�s Brasil para Cliente do Tipo Exporta��o ( Origem Estrangeira )."
			//"Escolha um outro Tipo de Cliente ou altere o c�digo do pa�s dos campos Pa�s ou Pa�s Bacen."
			Help(,,1,"A030VDTEXP",STR0001,2,,,,,,, {STR0002} )  
			lValid := .F.
		EndIf 
		 
		//------------------------------------------------------
		// Valida��o da inscri��o estadual
		//------------------------------------------------------
		If lValid .And. oModelSA1:GetValue("A1_EST") <> "EX"
			lValid := IE(oModelSA1:GetValue("A1_INSCR"),oModelSA1:GetValue("A1_EST"))
		EndIf
		
		//------------------------------------------------------
		// Valida��o do tipo de pessoa.
		//------------------------------------------------------
		If ( lValid .And. !Empty( oModelSA1:GetValue("A1_CGC") ) .And. oModelSA1:GetValue("A1_EST") <> "EX" .And. oModelSA1:GetValue("A1_TIPO") <> "X" )
			
			cTpPessoa 	:= oModelSA1:GetValue("A1_PESSOA")
			
			If Empty( cTpPessoa )
				cTpPessoa := IIF( Len( AllTrim( oModelSA1:GetValue("A1_CGC") ) ) == 11,"F","J" )
			EndIf
			
			lValid := A030CGC(cTpPessoa,oModelSA1:GetValue("A1_CGC"))
		
		EndIf
		
	EndIf            
Return lValid