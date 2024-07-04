#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887FINBOL
Clase responsable por el evento de reglas de negocio de 
localización de Bolivia

@type 		Class
@author 	luis.aboytes
@version	12.1.33 / Superior
@since		08/06/2022
/*/
Class F887FINBOL From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method VldActivate()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	luis.aboytes
@version	12.1.33 / Superior
@since		08/06/2022
/*/
Method New() Class F887FINBOL
	
Return Nil	

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	luis.aboytes
@version	12.1.33 / Superior
@since		08/06/2022
/*/
Method VldActivate(oModel) Class F887FINBOL
Local lRet		:= .T.

	self:GetEvent("F887FIN"):lProcede := .F.
	self:GetEvent("F887FIN"):lTasa 	:= .F.

Return lRet
