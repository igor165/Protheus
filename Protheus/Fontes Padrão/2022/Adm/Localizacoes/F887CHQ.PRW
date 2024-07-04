#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887CHQ
Clase responsable por el evento de reglas de negocio de 
localización padrón para contabilidad

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		06/05/2021
/*/
Class F887CHQ From FwModelEvent 

	DATA lNoDocTran As logical
	
	DATA lCpoArg As logical
	
	DATA cCredInm As Character

	Method New() CONSTRUCTOR
	
	Method VldActivate()

	Method Destroy()
	
	Method BeforeTTS()
	
	Method InTTS()
	
	Method UPDSEF()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		06/05/2021 
/*/
Method New() Class F887CHQ
	
Return Nil	

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		06/05/2021 
/*/
Method VldActivate(oModel) Class F887CHQ
Local nOperation	:= oModel:GetOperation()
Local lRet			:= .T.

	self:lNoDocTran	:= .F.
	
	self:lCpoArg	:= .F.
	
	self:cCredInm	:= GetSESTipos({|| ES_RCOPGER == "1"},"1")
	self:cCredInm	:= IIf(Empty(self:cCredInm),"TF /EF /CC /CD ",self:cCredInm)	
	

Return lRet

/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		06/05/2021 
/*/
Method Destroy() Class F887CHQ

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
Method BeforeTTS(oModel, cModelId) Class F887CHQ
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
Method InTTS(oModel, cModelId) Class F887CHQ
Local nOperation	:= oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_INSERT
		self:UPDSEF(oModel)
	EndIf

Return Nil

/*/{Protheus.doc} UPDSEF
Metodo responsable por ejecutar reglas de negocio genericas 
de la actualización de la tabla SEF para cheques.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.

@author 	raul.medina
@version	12.1.27 / Superior
@since		06/05/2021 
/*/
Method UPDSEF(oModel) Class F887CHQ
Local nOperation	:= oModel:GetOperation()
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local oModelSE1 	:= oModel:GetModel('SE1_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local nX			:= 0
Local cIdSEF		:= ""
Local nDias			:= 0
Local dBase		
Local aFeriados		:= {}
Local nTamCod		:= GetSx3Cache("A1_COD","X3_TAMANHO")
Local nTamLoja		:= GetSx3Cache("A1_LOJA","X3_TAMANHO")


	For nX := 1 To oModelSEL:Length()
		If oModelSEL:GetValue("EL_TIPODOC",nX) == "CH" .and. Iif(self:lNoDocTran,oModelSEL:GetValue("EL_TRANSIT",nX) == "2",.T.)
			cIdSEF 		:= FWUUIDV4()
			nDias		:= Val(oModelSEL:GetValue("EL_ACREBAN",nX))
			dBase		:= oModelSEL:GetValue("EL_DTVCTO",nX)
        	aFeriados	:= RetFeriados()
        	
        	While nDias > 0
			   	dBase ++
			   	If Ascan(aFeriados,Dtos(dBase)) == 0 .And. Dow(dBase) <> 1 .And. Dow(dBase) <> 7
			   		nDias--
			   	EndIf
			EndDo
			
			RecLock("SEF", .T.)
				Replace SEF->EF_FILIAL		WITH xFilial("SEF")
				Replace SEF->EF_BANCO		WITH oModelSEL:GetValue("EL_BCOCHQ",nX)
				Replace SEF->EF_AGENCIA		WITH oModelSEL:GetValue("EL_AGECHQ",nX)
				Replace SEF->EF_CONTA		WITH oModelSEL:GetValue("EL_CTACHQ",nX)
				Replace SEF->EF_NUM			WITH oModelSEL:GetValue("EL_NUMERO",nX)
				Replace SEF->EF_VALOR		WITH oModelSEL:GetValue("EL_VALOR",nX)
				Replace SEF->EF_DATA		WITH dDatabase
				Replace SEF->EF_VENCTO		WITH dBase //Clearing
				Replace SEF->EF_BENEF		WITH SM0->M0_NOMECOM
				Replace SEF->EF_CART		WITH "R"
				Replace SEF->EF_LA			WITH "S"
				Replace SEF->EF_LIBER		WITH "S"
				Replace SEF->EF_SEQUENC 	WITH "01"
				Replace SEF->EF_TEL			WITH GetAdvFVal("SA1","A1_TEL",xFilial("SA1")+PadR(oModelSEL:GetValue("EL_CLIENTE",nX),nTamCod)+PadR(oModelSEL:GetValue("EL_LOJA",nX),nTamLoja),1,"")
				Replace SEF->EF_PREFIXO		WITH oModelSEL:GetValue("EL_PREFIXO",nX)
				Replace SEF->EF_TITULO		WITH oModelSEL:GetValue("EL_RECIBO",nX)
				Replace SEF->EF_TIPO		WITH oModelSEL:GetValue("EL_TIPODOC",nX)
				Replace SEF->EF_PARCELA		WITH oModelSEL:GetValue("EL_PARCELA",nX)
				Replace SEF->EF_CLIENTE		WITH oModelSEL:GetValue("EL_CLIENTE",nX)
				Replace SEF->EF_LOJACLI		WITH oModelSEL:GetValue("EL_LOJA",nX)
				Replace SEF->EF_TERCEIR		WITH .F.
				Replace SEF->EF_EMITENT		WITH GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+PadR(oModelSEL:GetValue("EL_CLIENTE",nX),nTamCod)+PadR(oModelSEL:GetValue("EL_LOJA",nX),nTamLoja),1,"")
				Replace SEF->EF_CPFCNPJ		WITH GetAdvFVal("SA1","A1_CGC",xFilial("SA1")+PadR(oModelSEL:GetValue("EL_CLIENTE",nX),nTamCod)+PadR(oModelSEL:GetValue("EL_LOJA",nX),nTamLoja),1,"")
				Replace SEF->EF_HIST    	WITH "Recibo "+oModelSEL:GetValue("EL_RECIBO",nX)
				Replace SEF->EF_ORIGEM		WITH "FINA887"
				Replace SEF->EF_STATUS  	WITH "01" //Carteira
				Replace SEF->EF_PORTADO  	WITH oModelSEL:GetValue("EL_BANCO",nX)
				Replace SEF->EF_IDSEF 		WITH cIdSEF //Identificador Unico do Titulo
				
				If self:lCpoArg
					Replace SEF->EF_DATA	WITH Iif(SEL->EL_EMISSAO < dDatabase,SEL->EL_EMISSAO,dDatabase)
					Replace SEF->EF_VENCTO	WITH DATAVALIDA(SEL->EL_DTVCTO)
					If oModelSEL:GetValue("EL_TIPO",nX) $ self:cCredInm
						Replace SEF->EF_STATUS  WITH "04"
					EndIf
					Replace SEF->EF_NATUR		WITH oModelSEL:GetValue("EL_NATUREZ",nX)
					Replace SEF->EF_PORTADO		WITH oModelSEL:GetValue("EL_BANCO",nX) 
					Replace SEF->EF_ENDOSSA		WITH oModelSEL:GetValue("EL_ENDOSSA",nX)
					Replace SEF->EF_TERCEIR		WITH Iif(oModelSEL:GetValue("EL_TERCEIR",nX) == "2",.T.,.F.)
					If oModelSEL:GetValue("EL_ENDOSSA",nX) == "1"
						Replace SEF->EF_CPFCNPJ	WITH oModelSEL:GetValue("EL_CGC",nX)
					Endif
					Replace SEF->EF_POSTAL	WITH oModelSEL:GetValue("EL_POSTAL",nX)
				EndIf
			SEF->(MSUnlock())
		
		EndIf
	Next nX


Return Nil

