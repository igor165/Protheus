#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "CRM980EventARGLOJ.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventARGLOJ
Classe respons�vel pelo evento das regras de neg�cio da
localiza��o Argentina Controle de Lojas.

@type 		Classe
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventARGLOJ From FwModelEvent 
		
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
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventARGLOJ
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
M�todo respons�vel por executar as valida��es das regras de neg�cio
do Controle de Lojas antes da grava��o do formulario.
Se retornar falso, n�o permite gravar.


@type 		M�todo

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cID) Class CRM980EventARGLOJ
	Local lValid 		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oMdlSA1		:= oModel:GetModel("SA1MASTER")
	Local lIntSynt 	:= SuperGetMV("MV_LJSYNT",,"0") == "1"	 // Informa se a integracao Synthesis esta ativa
	
	If ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE )
   		
   		//----------------------------------------------------------------
		// Valida��es de campos para integra��o Protheus x Synthesis
		//----------------------------------------------------------------
 		If lIntSynt 
 			
 			If Empty( oMdlSA1:GetValue("A1_DTNASC") )          
				Help(" ",1,"MDLPVLDLOJ",,STR0004,3,0) //"Para integra��o com o sistema Synthesis o campo Data de Nascimento(A1_DTNASC) � obrigat�rio."
		     	lValid := .F.
		  	EndIf
		    	
			If ( lValid .And. Empty( oMdlSA1:GetValue("A1_TEL") ) )        
		  		Help(" ",1,"MDLPVLDLOJ",,STR0005,3,0) //"Para integra��o com o sistema Synthesis o campo Telefone(A1_TEL) � obrigatorio."
     			lValid := .F.      
     		EndIf
     		
			If ( lValid .And. !Empty( oMdlSA1:GetValue("A1_TEL") ) )
				If Empty(oMdlSA1:GetValue("A1_DDI"))   
					Help(" ",1,"MDLPVLDLOJ",,STR0006,3,0) //"Para integra��o com o sistema Synthesis o campo DDI(A1_DDI) � obrigat�rio."
					lValid := .F.         
				EndIf
				
				If ( lValid .And. Empty( oMdlSA1:GetValue("A1_DDD") ) )  
					Help(" ",1,"MDLPVLDLOJ",,STR0007,3,0) //"Para integra��o com o sistema Synthesis o campo DDD(A1_DDD) � obrigat�rio."
					lValid := .F.         
				EndIf
			EndIf                  
     		
     		If ( lValid .And. Empty( oMdlSA1:GetValue("A1_EMAIL") ) )        
		  		Help(" ",1,"MDLPVLDLOJ",,STR0008,3,0) //"Para integra��o com o sistema Synthesis o campo Email(A1_EMAIL) � obrigat�rio."
     			lValid := .F.      
     		EndIf
     		
     		If ( lValid .And. Empty( oMdlSA1:GetValue("A1_COD_MUN") ) )        
		  		Help(" ",1,"MDLPVLDLOJ",,STR0009,3,0) //"Para integra��o com o sistema Synthesis o campo Cd. Munic�pio(A1_COD_MUN) na pasta fiscal e obrigat�rio."
     			lValid := .F.      
     		EndIf
     		
     		If ( lValid .And. Empty( oMdlSA1:GetValue("A1_PAIS") ) )        
		  		Help(" ",1,"MDLPVLDLOJ",,STR0010,3,0) //"Para integracao com o sistema Synthesis o campo Pais(A1_PAIS) e obrigatorio."
     			lValid := .F.      
     		EndIf
     		
     		If ( 	lValid .And. nOperation == MODEL_OPERATION_INSERT )
     			
     			If !Empty( oMdlSA1:GetValue("A1_RG") )
     				cCodSynt := AllTrim( oMdlSA1:GetValue("A1_RG") )
     				cCodSynt := StrZero(Val(cCodSynt),11)
     				cCodSynt := "01"+cCodSynt			
     				oMdlSA1:LoadValue("A1_COD",cCodSynt)      
     				MsgAlert(STR0001 + oMdlSA1:GetValue("A1_COD") )	//"Gerado o c�digo do cliente Nr.: "	
				ElseIf !Empty( oMdlSA1:GetValue("A1_OBS") ) // verificar campo de passaporte	     
					cCodSynt := AllTrim( oMdlSA1:GetValue("A1_OBS") )
					cCodSynt := StrZero(Val(cCodSynt),11)
					cCodSynt := "02"+cCodSynt			
					oMdlSA1:LoadValue("A1_COD",cCodSynt)       
					//Testar na execauto.				    		
					MsgAlert(STR0001+ oMdlSA1:GetValue("A1_COD") )	//"Gerado o c�digo do cliente Nr.: "		
				ElseIf !Empty( oMdlSA1:GetValue("A1_CGC") )
					cCodSynt := AllTrim( oMdlSA1:GetValue("A1_CGC") )
					cCodSynt := StrZero(Val(cCodSynt),11)
					cCodSynt := "03"+cCodSynt			
					oMdlSA1:LoadValue("A1_COD",cCodSynt)  
					MsgAlert(STR0001 + oMdlSA1:GetValue("A1_COD") )	//"Gerado o c�digo do cliente Nr.: "			    				  		     
			    Else
			    	Help(" ",1,"MDLPVLDLOJ",,STR0002,3,0) //"Para gera��o do c�digo autom�tico para integra��o com a sistema Synthesis � necess�rio preencher o campo DNI para PF ou CUIT para PJ."
				  	lValid := .F.
				EndIf
     				
     		EndIf
     		
		EndIf
   		
   	EndIf
		
Return lValid