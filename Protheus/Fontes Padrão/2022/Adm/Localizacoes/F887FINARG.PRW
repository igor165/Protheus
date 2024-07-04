#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887FINARG
Clase responsable por el evento de reglas de negocio de 
localización de Argentina

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		11/05/2021
/*/
Class F887FINARG From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method VldActivate()

	Method Destroy()

	Method ModelPosVld()
	
	Method BeforeTTS()
	
	Method InTTS()

	Method FINUPDSE()

	Method FINUPDSEL()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		11/05/2021 
/*/
Method New() Class F887FINARG
	
Return Nil	

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		11/05/2021 
/*/
Method VldActivate(oModel) Class F887FINARG
Local bFilt1 	:= {|| ((FJS->FJS_RCOP == "1") 	.and. (FJS->FJS_CARTE $ "1|3") .and. (FJS->FJS_FILIAL == xFilial("FJS")))} 
Local bFilt2 	:= {|| ((FJS->FJS_RCOP == "2") 	.and. (FJS->FJS_CARTE $ "1|3") .and. (FJS->FJS_FILIAL == xFilial("FJS")))}
Local cChave	:= xFilial("FJS")
Local cAlias	:= "FJS"
Local cCampo	:= "FJS_TIPO" 
Local nOrder	:= 1  
Local cCredMed	:= ""
Local cCredInm	:= ""
Local lRet		:= .T.

	cCredMed := FinGetTipo(bFilt1,cAlias,cChave,cCampo,nOrder)
	cCredInm := FinGetTipo(bFilt2,cAlias,cChave,cCampo,nOrder)

	self:GetEvent("F887FIN"):cCredMed := IIf(Empty(cCredMed),GetSESNew("CH","3"),cCredMed)
	self:GetEvent("F887FIN"):cCredInm := IIf(Empty(cCredInm),"TF /EF /CC /CD ",cCredInm)
	self:GetEvent("F887FIN"):lCredInm := .T.
	self:GetEvent("F887FIN"):lDocTran := .T.

Return lRet

/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		11/05/2021 
/*/
Method Destroy() Class F887FINARG

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método responsable por ejecutar las validaçioes de las reglas de negocio
genéricas del cadastro antes de la grabación del formulario.
Si retorna falso, no permite grabar.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelID ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		23/06/2021 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cModelID) Class F887FINARG
Local lValid 		:= .T.
Local nOperation	:= oModel:GetOperation()
Local oModelSEL		:= oModel:GetModel("SEL_DETAIL")
Local nLine			:= 0
Local nSelLine		:= 0	

	If nOperation == MODEL_OPERATION_INSERT
	
		nSelLine := oModelSEL:GetLine()
		
		For nLine := 1 To oModelSEL:Length()
			oModelSEL:GoLine(nLine)
			If oModelSEL:IsDeleted() .Or. !oModelSEL:IsUpdated()
				loop
			Endif
			
			If lValid
				If AllTrim(oModelSEL:GetValue("EL_TIPODOC",nLine)) == "CH"  
					If Empty(oModelSEL:GetValue("EL_BCOCHQ",nLine))
						Help(NIL, NIL, "EL_BCOCHQ", NIL, STR0079, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0080})
						lValid	:=	.F.
					EndIf
				Else 
					If !Empty(oModelSEL:GetValue("EL_BCOCHQ",nLine))
						Help(NIL, NIL, "EL_BCOCHQ", NIL, STR0077, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0078})
						lValid	:=	.F.
					EndIf
				EndIf
			EndIf
			
		Next nLine
		
		oModelSEL:GoLine(nSelLine)
		
	EndIf

Return lValid

/*/{Protheus.doc} BeforeTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacción
del modelo de datos.

@type 		Method

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	raul.medina	
@version	12.1.27 / Superior
@since		11/05/2021 
/*/
Method BeforeTTS(oModel, cModelId) Class F887FINARG
	Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		self:FINUPDSEL(oModel)
	EndIf 

Return Nil

/*/{Protheus.doc} InTTS
Metodo responsable por ejecutar reglas de negocio genericas 
dentro de la transacción del modelo de datos.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		11/05/2021 
/*/
Method InTTS(oModel, cModelId) Class F887FINARG
Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		Begin Transaction
			self:FINUPDSE(oModel)
		End Transaction
	EndIf

Return Nil


/*/{Protheus.doc} F887FINARG::FINUPDSE
Metodo responsable de actualizar la tabla SE1 
@type method
@version  1	
@author luis.aboytes
@since 16/6/2022
/*/
Method FINUPDSE(oModel) Class F887FINARG
Local nOperation	:= oModel:GetOperation()
Local oModelSE1 	:= oModel:GetModel('SE1_DETAIL')
Local nX			:= 0

	For nX := 1 To oModelSE1:Length()
		If oModelSE1:GetValue("RECNO",nX) <> 0
			SE1->(MsGoto(oModelSE1:GetValue("RECNO",nX)))
			RecLock("SE1",.F.)
				SE1->E1_DESCONT		+= self:GetEvent("F887FIN"):nDescoSlv 
				SE1->E1_MULTA		+= self:GetEvent("F887FIN"):nMultaSlv 
				SE1->E1_JUROS		+= self:GetEvent("F887FIN"):nJurosSlv 
				SE1->E1_VALLIQ		+= self:GetEvent("F887FIN"):nVlLiqSlv 
			MsUnlock()
		EndIf
	Next nX

Return Nil

/*/{Protheus.doc} F887FINARG::FINUPDSEL
Metodo responsable para la actualización de la tabla SEL para ARG
@type method
@version  1
@author luis.aboytes
@since 13/7/2022
@param oModel, object, Modelo de dados SEL.
@param nLin, numeric, Linea a editar
/*/
Method FINUPDSEL(oModel, nLin) Class F887FINARG
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local nX			:= 0
Local nSelLine		:= 0

	nSelLine := oModelSEL:GetLine()
	For nX := 1 To oModelSEL:Length()
		oModelSEL:GoLine(nX)
		If oModelSEL:GetValue("EL_TRANSIT",nX) == "2" 
			oModelSEL:SetValue("EL_DTENTRA", dDataBase)
		EndIf	
	Next nX
	oModelSEL:GoLine(nSelLine)

Return Nil
