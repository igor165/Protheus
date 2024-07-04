#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887FINCHI
Clase responsable por el evento de reglas de negocio de 
localización de Chile

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		25/05/2021
/*/
Class F887FINCHI From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method VldActivate()

	Method Destroy()
	
	Method BeforeTTS()
	
	Method InTTS()
	
	Method FINUPDSE()
	
	Method FINGERNCC()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		25/05/2021 
/*/
Method New() Class F887FINCHI
	
Return Nil	

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		25/05/2021 
/*/
Method VldActivate(oModel) Class F887FINCHI
Local nOperation	:= oModel:GetOperation()
Local lRet		:= .T.


	self:GetEvent("F887FIN"):lRoundVal := .T.

Return lRet

/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		25/05/2021 
/*/
Method Destroy() Class F887FINCHI

Return Nil

/*/{Protheus.doc} BeforeTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacción
del modelo de datos.

@type 		Method

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	raul.medina	
@version	12.1.27 / Superior
@since		25/05/2021 
/*/
Method BeforeTTS(oModel, cModelId) Class F887FINCHI
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
@since		25/05/2021 
/*/
Method InTTS(oModel, cModelId) Class F887FINCHI
Local nOperation	:= oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_INSERT
		self:FINUPDSE(oModel)
	EndIf

Return Nil

/*/{Protheus.doc} FINUPDSE
Metodo responsable por realizar las actualizaciones de las tablas SE1, SE5, FK1, Fk5

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes..

@author 	raul.medina
@version	12.1.27 / Superior
@since		26/05/2021 
/*/
Method FINUPDSE(oModel) Class F887FINCHI
Local nOperation	:= oModel:GetOperation()
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local cSerie		:= oModelFJT:GetValue('FJT_SERIE')
Local cRecibo		:= oModelFJT:GetValue('FJT_RECIBO')
Local cCliOri 		:= oModelFJT:GetValue('FJT_CLIENT')
Local cLojOri		:= oModelFJT:GetValue("FJT_LOJA")
Local cGeraNCC		:= oModelFJT:GetValue("GERANCC")

	If cGeraNCC == "S"
		self:FINGERNCC(cRecibo, cSerie, cCliOri, cLojOri)
	EndIf
	
Return Nil

/*/{Protheus.doc} FINGERNCC
Metodo responsable por realizar el tratamiento de documentos 
por credito (RA, NCC)


@type 		Method

@param 		cSerie	 	,caracter	,serie del recibo
@param 		cRecibo	 	,caracter	,numero de recibo
@param 		cCliente 	,caracter	,cliente del recibo
@param 		cLoja	 	,caracter	,loja del cliente
@author 	raul.medina
@version	12.1.27 / Superior
@since		26/05/2021 
/*/
Method FINGERNCC(cRecibo, cSerie, cCliente, cLoja) Class F887FINCHI
Local cCGC	:= GetAdvFVal("SA1","A1_CGC",xFilial("SA1")+PadR(cCliente,GetSx3Cache("A1_COD","X3_TAMANHO"))+PadR(cLoja,GetSx3Cache("A1_LOJA","X3_TAMANHO")),1,"")

	If SE1->(DbSeek(xFilial("SE1")+"REC"+Padr(cRecibo,GetSx3Cache("E1_NUM","X3_TAMANHO")," ")))
		While xFilial("SE1") == SE1->E1_FILIAL .and. AllTrim(SE1->E1_PREFIXO) == "REC" .and. AllTrim(SE1->E1_RECIBO) == AllTrim(cRecibo) .and. AllTrim(SE1->E1_SERREC) == AllTrim(cSerie) .and.;
			AllTrim(SE1->E1_CLIENTE) ==  AllTrim(cCliente) .and. AllTrim(SE1->E1_LOJA) == AllTrim(cLoja)
			RecLock("SE1",.F.)	
				SE1->E1_CGC	:= cCGC
			MsUnlock()
			SE1->(DbSkip())
		Enddo
	EndIf
	
Return Nil