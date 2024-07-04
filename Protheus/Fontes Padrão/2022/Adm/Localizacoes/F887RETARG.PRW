#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887RETARG
Clase responsable por el evento de reglas de negocio de 
localización de retenciones de Argentina

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		12/05/2021
/*/
Class F887RETARG From FwModelEvent 

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
@since		12/05/2021 
/*/
Method New() Class F887RETARG
	
Return Nil	

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		12/05/2021 
/*/
Method VldActivate(oModel) Class F887RETARG
Local nOperation	:= oModel:GetOperation()
Local lRet			:= .T.



Return lRet

/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		12/05/2021 
/*/
Method Destroy() Class F887RETARG

Return Nil

/*/{Protheus.doc} ModelPosVld
Metodo responsable 

@type 		Method

@param 		oModel	,objeto	, modelo de datos
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		13/05/2021 
/*/
Method ModelPosVld(oModel, cModelId) Class F887RETARG
Local lRet 			:= .T.
Local cTpDoc		:= ""
Local oModelFJT		:= oModel:GetModel("FJT_MASTER")
Local oModeSEL		:= oModel:GetModel("SEL_DETAIL")
Local nOperation	:= oModel:GetOperation()
Local nLine			:= 0
Local cCliente		:= ""
Local cLoja			:= ""
Local cCgc			:= ""
Local nTamCod		:= GetSx3Cache("A1_COD","X3_TAMANHO")
Local nTamLoja		:= GetSx3Cache("A1_LOJA","X3_TAMANHO")

	If nOperation == MODEL_OPERATION_INSERT
		cCliente 	:= oModelFJT:GetValue('FJT_CLIENT')
		cLoja 		:= oModelFJT:GetValue("FJT_LOJA")
		For nLine := 1 To oModeSEL:Length()
			cTpDoc := oModeSEL:GetValue("EL_TIPODOC",nLine)
			If cTpDoc $ ("RB|RI|RG|RS|RM")
				If oModeSEL:GetValue("EL_VALOR",nLine) > 0 .And. oModeSEL:GetValue("EL_VALBASE",nLine) == 0 //Campo validado en el front
					oModel:SetErrorMessage('SEL_DETAIL', 'EL_VALBASE' , 'SEL_DETAIL' , 'EL_VALBASE' , STR0050, STR0063, STR0064)
					lRet := .F.
				ElseIf oModeSEL:GetValue("EL_VALOR",nLine) > 0 .And. oModeSEL:GetValue("EL_ALIQ",nLine) == 0//TCampo validado en el front
					oModel:SetErrorMessage('SEL_DETAIL', 'EL_ALIQ' , 'SEL_DETAIL' , 'EL_ALIQ' , STR0050, STR0061, STR0062)
					lRet := .F.
				EndIf
				
				If cTpDoc == "RB" .And. lRet
					If Empty(Alltrim(oModeSEL:GetValue("EL_EST",nLine)))  //Campo validado en el front
						oModel:SetErrorMessage('SEL_DETAIL', 'EL_EST' , 'SEL_DETAIL' , 'EL_EST' , STR0050, STR0051, STR0052)
						lRet := .F.
					ElseIf Empty(Alltrim(oModeSEL:GetValue("EL_CFO",nLine))) //Campo validado en el front
						oModel:SetErrorMessage('SEL_DETAIL', 'EL_CFO' , 'SEL_DETAIL' , 'EL_CFO' , STR0050, STR0053, STR0054)
						lRet := .F.	
					EndIf
				ElseIf cTpDoc == "RI" .And. lRet
					If Empty(Alltrim(oModeSEL:GetValue("EL_CFO",nLine))) //Campo validado en el front
						oModel:SetErrorMessage('SEL_DETAIL', 'EL_CFO' , 'SEL_DETAIL' , 'EL_CFO' , STR0050, STR0053, STR0054)
						lRet := .F.	
					EndIf
				ElseIf cTpDoc == "RG" .And. lRet
					If Empty(Alltrim(oModeSEL:GetValue("EL_AGREGAN",nLine))) 
						Help( ,, STR0050,,STR0055+" "+STR0056,1, 0 ) // Error-Act. para Ret. de Ganancias vacio. - Informar Act. para Ret. de Ganancias.
						lRet := .F.	
					EndIf
				ElseIf cTpDoc == "RS" .And. lRet
					If Empty(Alltrim(oModeSEL:GetValue("EL_CONCSUS",nLine))) 
						Help( ,, STR0050,,STR0057+" "+STR0058,1, 0 )  // Error - Concepto SUSS vacio. - Informar concepto SUSS.
						lRet := .F.	
					ELSEIF Empty(Alltrim(oModeSEL:GetValue("EL_SIRESEG",nLine)))
						Help( ,, STR0050,,STR0067+" "+STR0068,1, 0 )  // Error - Código de seguridad del SIRE no valido. - Informe un código de seguridad del SIRE valido.
						lRet := .F.
					ENDIF
					If Len(Alltrim(oModeSEL:GetValue("EL_SIRECER",nLine))) < 25
						Help( ,, STR0050,,STR0065+" "+STR0066,1, 0 ) // Error - Código de seguridad del SIRE no valido. - Informe un código de seguridad del SIRE valido.
						lRet := .F.
					Else 
						cCgc := GetAdvFVal("SA1","A1_CGC",xFilial("SA1")+PadR(cCliente,nTamCod)+PadR(cLoja,nTamLoja),1,"")
						If !(AllTrim(cCgc) $ Alltrim(oModeSEL:GetValue("EL_SIRECER",nLine)))
							Help( ,, STR0050,,STR0065+" "+STR0066,1, 0 )  // Error - Código de seguridad del SIRE no valido. - Informe un código de seguridad del SIRE valido.
							lRet := .F.
						EndIf
					EndIf
				ElseIf cTpDoc == "RM" .And. lRet
					If Empty(Alltrim(oModeSEL:GetValue("EL_CFO",nLine))) //Campo validado en el front
						oModel:SetErrorMessage('SEL_DETAIL', 'EL_CFO' , 'SEL_DETAIL' , 'EL_CFO' , STR0050, STR0053, STR0054)
						lRet := .F.
					ElseIf Empty(Alltrim(oModeSEL:GetValue("EL_EST",nLine))) //Campo validado en el front
						oModel:SetErrorMessage('SEL_DETAIL', 'EL_EST' , 'SEL_DETAIL' , 'EL_EST' , STR0050, STR0051, STR0052)
						lRet := .F. 
					ElseIf SFE->(FieldPos("FE_RET_MUN"))>0 .And. SEL->(FieldPos("EL_RET_MUN"))>0
						If Empty(Alltrim(oModeSEL:GetValue("EL_RET_MUN",nLine))) 
							Help( ,, STR0050,,STR0059+" "+STR0060,1, 0 ) //Error - Cod. Ret. municipal vacio. Informar Cod. ret. municipal.
							lRet := .F.
						EndIf
					ENDIF
				EndIf
			EndIf
		Next nX
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
@since		12/05/2021 
/*/
Method BeforeTTS(oModel, cModelId) Class F887RETARG
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
@since		12/05/2021 
/*/
Method InTTS(oModel, cModelId) Class F887RETARG
Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		self:UPDSFE(oModel)
	EndIf
	

Return Nil

/*/{Protheus.doc} UPDSFE
Metodo responsable por ejecutar reglas de negocio de Retenciones 
para la localización de Argentina

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.

@author 	raul.medina
@version	12.1.27 / Superior
@since		12/05/2021 
/*/
Method UPDSFE(oModel) Class F887RETARG
Local nOperation	:= oModel:GetOperation()
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local nX			:= 0

	SE1->(DbSetorder(1))
	For nX := 1 To oModelSEL:Length()
		If oModelSEL:GetValue("EL_TIPODOC",nX) $ "RS|RL|RB|RI|RG|RM" .and. oModelSEL:GetValue("EL_TRANSIT",nX)  == "2"
			//Valor retención mayor a 0
			If oModelSEL:GetValue("EL_VALOR",nX) > 0 .Or.;
				(SE1->(MsSeek(xFilial("SE1") + oModelSEL:GetValue("EL_EST",nX) + oModelSEL:GetValue("EL_CFO",nX) + STR(oModelSEL:GetValue("EL_VALBASE",nX)) + STR(oModelSEL:GetValue("EL_ALIQ",nX)) )))
				RecLock("SFE",.T.)
					FE_FILIAL   := xFilial('SFE')   
					FE_EMISSAO  := oModelSEL:GetValue("EL_EMISSAO",nX) //Verificar para RI
					FE_CLIENTE  := oModelSEL:GetValue("EL_CLIENTE",nX)
					FE_LOJCLI 	:= oModelSEL:GetValue("EL_LOJA",nX)
					FE_EST 		:= oModelSEL:GetValue("EL_EST",nX)
					FE_CFO	 	:= oModelSEL:GetValue("EL_CFO",nX)
					FE_VALBASE 	:= oModelSEL:GetValue("EL_VALBASE",nX)
					FE_ALIQ		:= oModelSEL:GetValue("EL_ALIQ",nX)
					FE_RETENC 	:= oModelSEL:GetValue("EL_VALOR",nX)
					FE_RECIBO   := oModelSEL:GetValue("EL_RECIBO",nX)
					FE_NROCERT	:= oModelSEL:GetValue("EL_NUMERO",nX)
					FE_SERIE 	:= oModelSEL:GetValue("EL_SERIE",nX) 
					If oModelSEL:GetValue("EL_TIPODOC",nX) == "RB"
						FE_TIPO   	:= "B"
					ElseIf oModelSEL:GetValue("EL_TIPODOC",nX) == "RM"
						FE_TIPO   	:= "M"
						FE_RET_MUN	:= oModelSEL:GetValue("EL_RET_MUN",nX)
					ElseIf oModelSEL:GetValue("EL_TIPODOC",nX) == "RI"
						FE_TIPO   	:= "I"
					ElseIf oModelSEL:GetValue("EL_TIPODOC",nX) == "RG"
						FE_TIPO   	:= "G"
						FE_CONCEPT 	:= oModelSEL:GetValue("EL_AGREGAN",nX)
					ElseIf oModelSEL:GetValue("EL_TIPODOC",nX) == "RS"
						FE_TIPO   	:= "S"
						FE_CONCEPT	:= oModelSEL:GetValue("EL_CONCSUS",nX)
						If SFE->(ColumnPos("FE_SIRECER")) > 0
							FE_SIRECER := oModelSEL:GetValue("EL_SIRECER",nX)
						EndIf
						If SFE->(ColumnPos("FE_SIRESEG")) > 0
							FE_SIRESEG := oModelSEL:GetValue("EL_SIRESEG",nX)
						EndIf
					EndIf 
				MsUnlock()
			EndIf
		EndIf
	Next nX

Return Nil
