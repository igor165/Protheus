#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887RETPER
Clase responsable por el evento de reglas de negocio de 
localización de retenciones de Perú

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		18/05/2021
/*/
Class F887RETPER From FwModelEvent 

	DATA lEmComRet As logical //Emite comprobantes de retención
	
	DATA cNomRotCom As Character //Nombre de la rutina de comprobantes
	
	Method New() CONSTRUCTOR
	
	Method VldActivate()

	Method Destroy()
	
	Method ModelPosVld()
	
	Method BeforeTTS()
	
	Method InTTS()
	
	Method UPDSFE()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		18/05/2021 
/*/
Method New() Class F887RETPER
	
Return Nil	

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		18/05/2021 
/*/
Method VldActivate(oModel) Class F887RETPER
Local nOperation	:= oModel:GetOperation()
Local lRet			:= .T.

	self:lEmComRet := .F.
	
	self:cNomRotCom := ""

Return lRet

/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		18/05/2021 
/*/
Method Destroy() Class F887RETPER

Return Nil

/*/{Protheus.doc} ModelPosVld
Metodo responsable 

@type 		Method

@param 		oModel	,objeto	, modelo de datos
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		18/05/2021 
/*/
Method ModelPosVld(oModel, cModelId) Class F887RETPER
Local lRet 			:= .T.
Local oModelFJT		:= oModel:GetModel("FJT_MASTER")
Local oModeSEL		:= oModel:GetModel("SEL_DETAIL")
Local nOperation	:= oModel:GetOperation()
Local nLine			:= 0
Local cCliente		:= ""
Local cLoja			:= ""

	If nOperation == MODEL_OPERATION_INSERT
		For nLine := 1 To oModeSEL:Length()
			cTpDoc := oModeSEL:GetValue("EL_TIPODOC",nLine)
			If SEL->(ColumnPos('EL_SERRET')) > 0
				If cTpDoc $ ("RI") .and. Empty(oModeSEL:GetValue("EL_SERRET",nLine)) //Campos  validados en el front
					oModel:SetErrorMessage('SEL_DETAIL', 'EL_SERRET' , 'SEL_DETAIL' , 'EL_SERRET' , STR0050, STR0069, STR0070)
					lRet := .F.
				ElseIf !(cTpDoc $ ("RI")) .and. !Empty(oModeSEL:GetValue("EL_SERRET",nLine)) //Campos  validados en el front
					oModel:SetErrorMessage('SEL_DETAIL', 'EL_SERRET' , 'SEL_DETAIL' , 'EL_SERRET' , STR0050, STR0071, STR0072)
					lRet := .F.
				EndIf
			EndIf
		Next nLine
		
		self:lEmComRet := oModelFJT:GetValue("EMITCOM") == 1
	
		self:cNomRotCom := oModelFJT:GetValue("RUTCOM")
	EndIf
	
Return lRet

/*/{Protheus.doc} BeforeTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacción
del modelo de datos.

@type 		Method

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	raul.medina	
@version	12.1.27 / Superior
@since		18/05/2021 
/*/
Method BeforeTTS(oModel, cModelId) Class F887RETPER
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
@since		18/05/2021 
/*/
Method InTTS(oModel, cModelId) Class F887RETPER
Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		self:UPDSFE(oModel)
	EndIf
	

Return Nil

/*/{Protheus.doc} UPDSFE
Metodo responsable por ejecutar reglas de negocio de Retenciones 
para la localización de Perú

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.

@author 	raul.medina
@version	12.1.27 / Superior
@since		20/05/2021 
/*/
Method UPDSFE(oModel) Class F887RETPER
Local nOperation	:= oModel:GetOperation()
Local oModelSE1 	:= oModel:GetModel('SE1_DETAIL')
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local nX			:= 0
Local nY			:= 0
Local nTamPar		:= GetSx3Cache("E1_PARCELA","X3_TAMANHO")
Local cCliente		:= ""
Local cLoja			:= ""
Local cCert			:= ""
Local aCert			:= {}
Local cSerieC		:= GETNEWPAR("MV_SERPERC","")
Local nItensC		:= GETNEWPAR("MV_ITENSC",1)
Local nItem			:= 0
Local nMoedDesc		:= 1
Local bBlock		
Local nI			:= 0

	For nX := 1 To oModelSEL:Length()
		If oModelSEL:GetValue("EL_TIPODOC",nX) $ "RI" 
			If oModelSEL:GetValue("EL_VALOR",nX) > 0
				RecLock("SFE",.T.)
					FE_TIPO		:=  "I" 
					FE_FILIAL   := xFilial('SE1')   
					FE_EMISSAO  := oModelSEL:GetValue("EL_EMISSAO"	,nX)
					FE_CLIENTE  := oModelSEL:GetValue("EL_CLIENTE"	,nX)
					FE_LOJCLI 	:= oModelSEL:GetValue("EL_LOJA"		,nX)
					FE_RECIBO   := oModelSEL:GetValue("EL_RECIBO"	,nX)
					FE_NFISCAL	:= oModelSEL:GetValue("EL_DOCTO"	,nX)
					FE_SERIE    := oModelSEL:GetValue("EL_SDOCTO"	,nX)							
					FE_RETENC 	:= oModelSEL:GetValue("EL_VALOR"	,nX)
					FE_NROCERT	:= oModelSEL:GetValue("EL_NUMERO"	,nX)
					FE_SERIE2	:= oModelSEL:GetValue("EL_SERRET"	,nX)
 
					FOR nY := 1 to  oModelSE1:Length()
						IF ALLTRIM(oModelSEL:GetValue("EL_DOCTO",nX)) == ALLTRIM(oModelSE1:GetValue("E1_NUM",nY)) .And. ALLTRIM(oModelSEL:GetValue("EL_SDOCTO",nX)) == ALLTRIM(oModelSE1:GetValue("E1_PREFIXO",nY))  .And. ALLTRIM(oModelSEL:GetValue("EL_PARDOC",nX)) == ALLTRIM(oModelSE1:GetValue("E1_PARCELA",nY) )
							FE_ESPECIE	:= oModelSE1:GetValue("E1_TIPO",nY)
							FE_PARCELA	:= oModelSE1:GetValue("E1_PARCELA", nY)
						EndIf
					Next nY
				MsUnlock()
			EndIf
		EndIf
	Next nX
	
	//Se Elimina codigo con la validacion de "FE_TIPO" == "P" para cobertura
		
	If self:lEmComRet .and. Len(aCert) > 0
		For nI := 1 to Len(aCert)
	  		bBlock := &("{||"+Alltrim(self:cNomRotCom)+"(aCert[nI][1],aCert[nI][2],.T.)"+"}")
	  		Eval(bBLock)
		Next nI
	EndIf

Return Nil
