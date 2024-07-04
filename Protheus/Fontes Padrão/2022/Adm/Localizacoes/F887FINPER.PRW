#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887FINPER
Clase responsable por el evento de reglas de negocio de 
localización de Perú

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		19/05/2021
/*/
Class F887FINPER From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method VldActivate()

	Method Destroy()
	
	Method BeforeTTS()
	
	Method InTTS()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		19/05/2021 
/*/
Method New() Class F887FINPER
	
Return Nil	

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		19/05/2021 
/*/
Method VldActivate(oModel) Class F887FINPER
Local nOperation	:= oModel:GetOperation()
Local lRet		:= .T.

	self:GetEvent("F887FIN"):cDocCred := Substr(MVRECANT,1,3) // Sempre sera tipo RA no Perú
	
	self:GetEvent("F887FIN"):lValidITF := .T.

Return lRet

/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		19/05/2021 
/*/
Method Destroy() Class F887FINPER

Return Nil

/*/{Protheus.doc} BeforeTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacción
del modelo de datos.

@type 		Method

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	raul.medina	
@version	12.1.27 / Superior
@since		19/05/2021 
/*/
Method BeforeTTS(oModel, cModelId) Class F887FINPER
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
@since		19/05/2021 
/*/
Method InTTS(oModel, cModelId) Class F887FINPER
Local nOperation	:= oModel:GetOperation()


Return Nil