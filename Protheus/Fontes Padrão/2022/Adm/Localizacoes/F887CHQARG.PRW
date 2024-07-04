#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887CHQARG
Clase responsable por el evento de reglas de negocio de 
localización padrón para contabilidad

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		06/05/2021
/*/
Class F887CHQARG From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method VldActivate()

	Method Destroy()
	
	Method BeforeTTS()
	
	Method InTTS()
	
	Method UPDFRF()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		06/05/2021 
/*/
Method New() Class F887CHQARG
	
Return Nil	

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		06/05/2021 
/*/
Method VldActivate(oModel) Class F887CHQARG
Local nOperation	:= oModel:GetOperation()
Local lRet			:= .T.

	self:GetEvent("F887CHQ"):lCpoArg := .T.

Return lRet

/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		06/05/2021 
/*/
Method Destroy() Class F887CHQARG

Return Nil

/*/{Protheus.doc} BeforeTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacción
del modelo de datos.

@type 		Method

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	raul.medina	
@version	12.1.27 / Superior
@since		06/05/2021 
/*/
Method BeforeTTS(oModel, cModelId) Class F887CHQARG
Local nOperation	:= oModel:GetOperation()


Return Nil

/*/{Protheus.doc} InTTS
Metodo responsable por ejecutar reglas de negocio genericas 
dentro de la transacción del modelo de datos.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		06/05/2021 
/*/
Method InTTS(oModel, cModelId) Class F887CHQARG
Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		self:UPDFRF(oModel)
	EndIf
	

Return Nil

/*/{Protheus.doc} UPDFRF
Metodo responsable por ejecutar reglas de negocio para cheques 
para la localización de Argentina

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.

@author 	raul.medina
@version	12.1.27 / Superior
@since		06/05/2021 
/*/
Method UPDFRF(oModel) Class F887CHQARG
Local nOperation	:= oModel:GetOperation()
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local oModelSE1 	:= oModel:GetModel('SE1_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local nX			:= 0
Local cFilFRF		:= xFilial("FRF")
Local cSeqFRF		:= ""
Local nSaveSX8 		:= GetSX8Len()


	For nX := 1 To oModelSEL:Length()
		If oModelSEL:GetValue("EL_TIPODOC",nX) $ MVCHEQUE
			
			cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
			
			FRF->(RecLock("FRF",.T.))
				FRF->FRF_FILIAL		:= cFilFRF
				FRF->FRF_BANCO		:= oModelSEL:GetValue("EL_BCOCHQ",nX)
				FRF->FRF_AGENCIA	:= oModelSEL:GetValue("EL_AGECHQ",nX)
				FRF->FRF_CONTA		:= oModelSEL:GetValue("EL_CTACHQ",nX)
				FRF->FRF_NUM		:= oModelSEL:GetValue("EL_NUMERO",nX)
				FRF->FRF_PREFIX		:= oModelSEL:GetValue("EL_PREFIXO",nX)
				FRF->FRF_CART		:= "R"
				FRF->FRF_DATPAG		:= dDataBase 
				FRF->FRF_CLIENT		:= oModelSEL:GetValue("EL_CLIENTE",nX)
				FRF->FRF_LOJA		:= oModelSEL:GetValue("EL_LOJA",nX)
				FRF->FRF_NUMDOC		:= oModelSEL:GetValue("EL_RECIBO",nX)
				If oModelSEL:GetValue("EL_TRANSIT",nX)  == "1"				    
					FRF->FRF_MOTIVO		:= "A0"
					FRF->FRF_DESCRI		:= STR0048 //"Entrada de Cheque via Recibo de Cobrança"
				ElseIf oModelSEL:GetValue("EL_TRANSIT",nX)  == "2"
					FRF->FRF_MOTIVO		:= "A1"
					FRF->FRF_DESCRI		:= STR0049 //"Entrada de Cheque em Trânsito via Recibo de Cobrança"
				EndIf
				FRF->FRF_SEQ		:= cSeqFRF
			FRF->(MsUnLock())
			If  __lSX8
				While ( GetSX8Len() > nSaveSx8 )
					ConfirmSX8()
				End
			Endif
		EndIf
	Next nX


Return Nil