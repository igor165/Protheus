#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRM980EventBRA.CH"     
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventBRA
Classe responsável pelo evento das regras de negócio da 
localização Brasil.

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
Metodo responsável pela construção da classe.

@type 		Método
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventBRA
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método responsável por executar as validações das regras de negócio
genéricas do cadastro antes da gravação do formulario.
Se retornar falso, não permite gravar.

@type 		Método

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
		// Não permite configurar um cliente do tipo exportação do País Brasil.
		//-------------------------------------------------------------------------
		If ( oModelSA1:GetValue("A1_TIPO") == "X" .And. ( oModelSA1:GetValue("A1_PAIS") == "105" .Or. Val(oModelSA1:GetValue("A1_CODPAIS")) == 1058 ) )
			//"Não será possível escolher o País Brasil para Cliente do Tipo Exportação ( Origem Estrangeira )."
			//"Escolha um outro Tipo de Cliente ou altere o código do país dos campos País ou País Bacen."
			Help(,,1,"A030VDTEXP",STR0001,2,,,,,,, {STR0002} )  
			lValid := .F.
		EndIf 
		 
		//------------------------------------------------------
		// Validação da inscrição estadual
		//------------------------------------------------------
		If lValid .And. oModelSA1:GetValue("A1_EST") <> "EX"
			lValid := IE(oModelSA1:GetValue("A1_INSCR"),oModelSA1:GetValue("A1_EST"))
		EndIf
		
		//------------------------------------------------------
		// Validação do tipo de pessoa.
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