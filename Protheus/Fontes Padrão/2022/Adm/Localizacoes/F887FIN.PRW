#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887FIN
Clase responsable por el evento de reglas de negocio de 
localización padrón

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		12/01/2021
/*/
Class F887FIN From FwModelEvent 

	//Fecha de referencia
    DATA dDataRef 
    
    DATA cCredMed As Character
    
    DATA cCredInm As Character
    
    DATA cTiposAdm As Character
    
    DATA cDocCred As Character
    
    DATA lChaveSE1 As logical
    
    DATA lDelRA	As logical
    
    DATA lDelEAI As logical
    
    DATA lBDGA As logical
	
	DATA lBInteg As logical
	
	DATA nRecnoSAQ	As numeric
	
	DATA lCredInm As logical

	DATA lProcede As logical

	DATA lTasa 	As Logical
	
	DATA lDocTran As logical
	
	DATA lValidITF As logical
	
	DATA lRoundVal	As logical
	
	DATA lSerRec As logical
	
	DATA nSaveSX8 As numeric

	DATA nDescoSlv	As numeric
	
	DATA nMultaSlv	As numeric

	DATA nJurosSlv	As numeric

	DATA nVlLiqSlv	As numeric

	Method New() CONSTRUCTOR
	
	Method VldActivate()
	
	Method ModelPosVld()
 
	Method BeforeTTS()
	
	Method InTTS()
	
	Method AfterTTS()
	
	Method FINUPDSEL()
	
	Method FINUPDSE()
	
	Method FINUPDSE1()
	
	Method FINGRVTAX()
	
	Method FINGrvSE5()
	
	Method FINCREDMED()
	
	Method FINUPDSEA()
	
	Method FINCOB()
	
	Method FINCOM()
	
	Method FINGERNCC()
	
	Method F887DEL()

	Method F887CAN()
	
	Method F887CkPG()
	
	Method GridLinePreVld()
 
	Method Destroy()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		12/04/2017 
/*/
Method New() Class F887FIN
	
Return Nil

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		30/04/2021 
/*/
Method VldActivate(oModel) Class F887FIN
Local nOperation	:= oModel:GetOperation()
Local lRet			:= .T.
	
	self:dDataRef	:= dDatabase

	self:lProcede	:= .T.
	
	self:cCredMed	:= GetSESTipos({|| ES_RCOPGER == "1"},"1")
	self:cCredMed	:= IIf(Empty(self:cCredMed),GetSESNew("CH|CC","3") ,self:cCredMed)
	
	self:cCredInm	:= GetSESTipos({|| ES_RCOPGER == "1"},"1")
	self:cCredInm	:= IIf(Empty(self:cCredInm),"TF /EF /CC /CD ",self:cCredInm)
	
	self:cTiposAdm 	:= GetSAETipos()
	
	self:cDocCred	:= ""
	
	self:lChaveSE1	:= .T.
	
	self:lDelRA		:= .F.
	
	self:lDelEAI	:= .F.
	
	self:lCredInm	:= .F.
	
	self:lDocTran 	:= .F.
	
	self:lValidITF	:= .F.
	
	self:lRoundVal 	:= .F.
	
	self:lSerRec	:= SuperGetMV('MV_SERREC')
	
	self:nSaveSX8	:= GetSX8Len()
	
	self:lTasa 		:= .T.

	self:nDescoSlv	:= 0

	self:nMultaSlv	:= 0

	self:nJurosSlv	:= 0

	self:nVlLiqSlv	:= 0

Return lRet

/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		30/04/2021 
/*/
Method Destroy() Class F887FIN

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
@since		05/05/2021 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cModelID) Class F887FIN
Local lValid 		:= .T.
Local nOperation	:= oModel:GetOperation()
Local oModelFJT		:= oModel:GetModel("FJT_MASTER")
Local oModelSEL		:= oModel:GetModel("SEL_DETAIL")
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local aArea			:= {}
Local cRecProv		:= ""
Local cCobrador		:= ""
Local cSerie		:= ""
Local cTipo			:= ""
Local cDocCred		:= ""
Local nLine			:= 0
Local nSelLine		:= 0
Local aCaixaFin		:= xCxFina()
Local cBlockBco		:= ""		
Local cRecibo		:= ""
Local cBanco		:= ""
Local cAgencia		:= ""
Local cNumcon		:= ""
Local nAux 			:= 1

	If nOperation == MODEL_OPERATION_INSERT
		cRecibo		:= oModelFJT:GetValue("FJT_RECIBO")
		cRecProv	:= oModelFJT:GetValue("FJT_RECPRV")
		cCobrador	:= oModelFJT:GetValue("FJT_COBRAD")
		cSerie 		:= oModelFJT:GetValue("FJT_SERIE")	
		cDocCred	:= oModelFJT:GetValue("DOCUMEN")
		self:dDataRef := oModelFJT:GetValue("FJT_EMISSA")

		If lValid .and. Empty(oModelFJT:getValue("FJT_RECIBO"))
			Help( ,, STR0017 ,, STR0030 ,1, 0 )//"Aviso" //"Indique el número de Recibo "
			lValid:= .F.
		EndIf
		If lValid
			DbSelectArea("FJT")
			FJT->(DbSetorder(1)) ////FJT_FILIAL+FJT_SERIE+FJT_RECIBO+FJT_VERSAO
			If FJT->(dbSeek(xFilial("FJT")+cSerie+cRecibo))
				Help( ,, STR0017 ,,STR0026  ,1, 0 )   // "Aviso" // "El Número del Recibo ya Existe "
				lValid := .F.
			EndIf
		EndIf
		If lValid .and. Empty(oModelFJT:getValue("FJT_CLIENT"))
			Help( " " , 1 , "NUMCLI" ,,, 2 , 0 )
			lValid:= .F.
		endIf
		If lValid .and. Empty(oModelFJT:getValue("FJT_LOJA"))
			Help( " " , 1 , "NUMCLI" ,,, 2 , 0 )
			lValid:= .F.
		endIF
		If lValid .and. !(dtMovFin(self:dDataRef,,"2") )      // Verificar data do recibo com o parametro MV_DATAFIN
			lValid:= .F. 
		EndIf           
		If lValid .and. Empty(self:dDataRef)
			Help( ,,STR0017 ,, STR0031 ,1, 0 )//"Aviso" //"Fecha de emision invalida."
			lValid := .F.
		EndIf
	
		If lValid .And. !Empty(oModelFJT:getValue("FJT_COBRAD"))
			aArea:=GetArea()       
			DbSelectArea("SAQ")
			DbSetOrder(1)
			If dbSeek(xFilial("SAQ")+oModelFJT:getValue("FJT_COBRAD")) 
				ctipo:= SAQ->AQ_TIPOREC // TIPO recibo
				If cTipo<> "3"
					lValid := self:FINCOB(cTipo, cCobrador, cRecProv, cSerie, cRecibo)
				EndIf
		   EndIf	
		   RestArea(aArea)
		EndIf
		
		For nLine := 1 To oModelMOE:Length()
			If oModelMOE:GetValue("SALDO",nLine) > 0 .and. oModelFJT:getValue("GERANCC") <> "S"
				oModel:SetErrorMessage('MOE_DETAIL', '' , 'MOE_DETAIL' , '' , STR0050, STR0075, STR0076)
				lValid := .F.
			EndIf
		Next nLine
	
		nSelLine := oModelSEL:GetLine()
		
		For nLine := 1 To oModelSEL:Length()
			oModelSEL:GoLine(nLine)
			If oModelSEL:IsDeleted() .Or. !oModelSEL:IsUpdated()
				loop
			Endif
			Iif(lValid, lValid := oModelSEL:GetValue("EL_DTVCTO",nLine)>=oModelSEL:GetValue("EL_EMISSAO",nLine),)
			
			If lValid
				DbSelectArea("SA6")
				DbSetOrder(1)
				If oModelSEL:GetValue("EL_TIPODOC",nLine) $ self:cCredMed+"/"+self:cCredInm .and. Subs(oModelSEL:GetValue("EL_TIPODOC",nLine),1,2) != "EF"
					If Empty(oModelSEL:GetValue("EL_BANCO",nLine) + oModelSEL:GetValue("EL_AGENCIA",nLine) + oModelSEL:GetValue("EL_CONTA",nLine))
						Help("",1,"FA087BCO")  //"Caja no existente"
						lValid	:=	.F.
					EndIf
				ElseIf oModelSEL:GetValue("EL_TIPODOC",nLine) $ self:cCredMed+"/"+self:cCredInm .and. Subs(oModelSEL:GetValue("EL_TIPODOC",nLine),1,2) == "EF".AND. Empty(oModelSEL:GetValue("EL_BANCO",nLine) + oModelSEL:GetValue("EL_AGENCIA",nLine) + oModelSEL:GetValue("EL_CONTA",nLine))
					oModelSEL:LoadValue("EL_BANCO",aCaixaFin[1])
					oModelSEL:LoadValue("EL_AGENCIA",aCaixaFin[2])
					oModelSEL:LoadValue("EL_CONTA",aCaixaFin[3])
				EndIf
				If lValid
					cBlockBco := GetAdvFVal("SA6","A6_BLOCKED",xFilial("SA6")+PadR(oModelSEL:GetValue("EL_BANCO",nLine),GetSx3Cache("A6_COD","X3_TAMANHO"))+PadR(oModelSEL:GetValue("EL_AGENCIA",nLine),GetSx3Cache("A6_AGENCIA","X3_TAMANHO"))+PadR(oModelSEL:GetValue("EL_CONTA",nLine),GetSx3Cache("A6_NUMCON","X3_TAMANHO")),1,"")
					If cBlockBco == "1"
						Help(" ",1,"CCBLOCKED")
						lValid	:=	.F.
					EndIf
				EndIf
				If lValid
					If oModelSEL:GetValue("EL_TIPODOC",nLine) == "DC" //Pagaré
						If !Empty(oModelSEL:GetValue("EL_BANCO",nLine)) .And. !(oModelSEL:GetValue("EL_BANCO",nLine) $ (GetNewPar("MV_CARTEIR","") + "/" + Left(GetNewPar("MV_CXFIN",""),TamSX3("A6_COD")[1])))
							Help( " ", 1, "FA840BCO")//"Banco inválido para Pagaré"				
							lValid := .F.
						EndIf
					EndIf
				EndIf
			EndIf
			
			If lValid
				SE1->(DbSetOrder(1))
				If SE1->(DbSeek(xFilial("SE1")+oModelSEL:GetValue("EL_PREFIXO",nLine)+oModelSEL:GetValue("EL_NUMERO",nLine)+oModelSEL:GetValue("EL_PARCELA",nLine)+Padr(oModelSEL:GetValue("EL_TIPODOC",nLine),GetSx3Cache("E1_TIPO","X3_TAMANHO"))))
					Help( " ", 1, "DOCUEXIST",,STR0073+STR0074,1,0)
					lValid := .F.
				EndIf
			EndIf
			
			If lValid
				If oModelSEL:GetValue("EL_TIPODOC",nLine) $ self:cCredInm .and. oModelSEL:GetValue("EL_DTVCTO",nLine) <> dDataBase
					Help(" ",1,"BLOQDTVENC")
					lValid := .F.
				EndIf
			EndIf	

			IF lValid
				cBanco		:= oModelSEL:GetValue("EL_BANCO",nLine)
				cAgencia	:= oModelSEL:GetValue("EL_AGENCIA",nLine)
				cNumcon		:= oModelSEL:GetValue("EL_CONTA",nLine)

				SA6->(DbSetOrder(1)) //A6_FILIA+A6_CODE+A6_AGENCIA+A6_NUMCON
				IF SA6->(MsSeek(xFilial("SA6")+cBanco+cAgencia+cNumcon))
					nMoneda := SA6->A6_MOEDA
					FOR nAux := 1 to oModelMOE:Length()
						IF oModelMOE:GetValue("MOEDA",nAux) == CVALTOCHAR(nMoneda) .AND. oModelMOE:GetValue("TASA",nAux) == 0
								Help( ,, STR0017 ,,STR0081 ,1, 0 )   // "Aviso" // "Error en la tasa del banco, verifique la tasa."
							lValid := .F.
						ENDIF
					NEXT
				ENDIF
			ENDIF
		Next nLine
		
		oModelSEL:GoLine(nSelLine)
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		lValid:= self:F887CAN()	
	EndIf
	
	If Empty(self:cDocCred)
		self:cDocCred	:= IIf(Empty(cDocCred) .Or. !(cDocCred$MV_CRNEG+"|"+MVRECANT), "NCC", cDocCred)
	EndIf


Return lValid

/*/{Protheus.doc} F887FIN::GridLinePreVld
Método al que llama MVC que ejecuta acciones antes de las validaciones
@type method
@version  
@author luis.aboytes
@since 16/8/2022
/*/
Method GridLinePreVld (oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)  Class F887FIN
Local dDtVcto 	As Data 
Local dDtEmiss 	As Data 
Local lRet		As Logical
Local aresp		As Array
Local aServMod  As Array
Local cModoPago As Character

lRet	  	:= .T.  
aresp		:= {}	
aServMod	:= {}	

IF cModelID == 'SEL_DETAIL' .AND. cAction == 'SETVALUE'  .AND. cId=='EL_DTVCTO' 
	dDtVcto := xValue
	dDtEmiss := oSubModel:GetValue("EL_EMISSAO",nLine)	
	cModoPago := oSubModel:GetValue("EL_TIPO",nLine)	

	lRet := F840VldVct(dDtVcto,dDtEmiss,cModoPago,@aresp,aServMod)
	IIF(lRet==.F.,Help( ,,STR0050 ,, aresp[1] ,1, 0 ),"")
ENDIF

Return lRet

/*/{Protheus.doc} BeforeTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacción
del modelo de datos.

@type 		Method

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	raul.medina	
@version	12.2.27 / Superior
@since		12/04/2021 
/*/
Method BeforeTTS(oModel, cModelId) Class F887FIN
Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		self:FINUPDSEL(oModel)
	ElseIf nOperation == MODEL_OPERATION_DELETE 
		self:F887DEL()	 	
	EndIf  

Return

/*/{Protheus.doc} InTTS
Metodo responsable por ejecutar reglas de negocio genericas 
dentro de la transacción del modelo de datos.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		12/04/2021 
/*/
Method InTTS(oModel, cModelId) Class F887FIN
Local nOperation	:= oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_INSERT
		Begin Transaction
			self:FINUPDSE(oModel)
		End Transaction
	EndIf

Return Nil


/*/{Protheus.doc} AfterTTS
Metodo responsable por ejecutar reglas de negocio genericas 
después de la transacción del modelo de datos.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		24/05/2021 
/*/
Method AfterTTS(oModel, cModelId) Class F887FIN
Local nOperation	:= oModel:GetOperation()
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local cSerie		:= oModelFJT:GetValue('FJT_SERIE')
Local cRecibo		:= oModelFJT:GetValue('FJT_RECIBO')
Local nTamRec		:= GetSx3Cache("EL_RECIBO","X3_TAMANHO")
	
	If nOperation == MODEL_OPERATION_INSERT
		If !self:lSerRec
			If __lSX8
				While ( GetSX8Len() > self:nSaveSx8 )
					ConfirmSX8()
				End
			Endif
		Else
			//Grava Nr do proximo Recibo da tabela RN no SX5.
			DbSelectArea("SX5")
			DbSetOrder(1)
			If DbSeek( xFilial("SX5")+"RN"+cSerie )
				If StrZero(Val(X5DESCRI()),nTamRec) <  StrZero((Val(cRecibo)+1),nTamRec)
					RecLock("SX5",.F.)
					Replace X5_DESCRI  With StrZero((Val(cRecibo)+1),nTamRec)
					Replace X5_DESCENG With StrZero((Val(cRecibo)+1),nTamRec)
					Replace X5_DESCSPA With StrZero((Val(cRecibo)+1),nTamRec)
					MsUnlock()
				Endif
			EndIf
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} FINUPDSEL
Metodo responsable por realizar el tratamiento de la tabla SEL

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados SEL.
@param 		nLin	 ,numerico	,linea procesada del modelo SEL.

@author 	raul.medina
@version	12.1.27 / Superior
@since		19/04/2021 
/*/
Method FINUPDSEL(oModel, nLin) Class F887FIN
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local oModelSE1 	:= oModel:GetModel('SE1_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelADM 	:= oModel:GetModel('ADM_DETAIL')
Local oModelFAC 	:= oModel:GetModel('FAC_DETAIL')

Local cSerie		:= oModelFJT:GetValue('FJT_SERIE')
Local cRecibo		:= oModelFJT:GetValue('FJT_RECIBO')
Local cNatureza		:= oModelFJT:GetValue('FJT_NATURE')
lOCAL cRecProv		:= ALLTRIM(oModelFJT:GetValue("FJT_RECPRV"))
Local cCliOri 		:= oModelFJT:GetValue('FJT_CLIENT')
Local cLojOri		:= oModelFJT:GetValue("FJT_LOJA")
Local cCobrador		:= oModelFJT:GetValue("FJT_COBRAD")
Local nValMoe1		:= 0
Local cMoeda		:= ""
Local nTaxa			:= 1
Local nX			:= 0
Local nSelLine		:= 0

	For nX := 1 To oModelSE1:Length()
		If oModelSE1:GetValue("RECNO",nX) <> 0
			SE1->(MsGoto(oModelSE1:GetValue("RECNO",nX)))
			
			If oModelSEL:Length() > 1 .Or. (oModelSEL:Length() == 1 .and. !Empty(oModelSEL:GetValue("EL_NUMERO")) .and. !Empty(oModelSEL:GetValue("EL_TIPO")))
				oModelSEL:AddLine()
			EndIf

			oModelSEL:loadValue("EL_FILIAL"	, xFilial("SEL"))
			oModelSEL:loadValue("EL_TIPODOC", "TB")
			oModelSEL:loadValue("EL_PREFIXO", SE1->E1_PREFIXO)
			oModelSEL:loadValue("EL_NUMERO"	, SE1->E1_NUM)
			oModelSEL:loadValue("EL_PARCELA", SE1->E1_PARCELA)
			oModelSEL:loadValue("EL_TIPO"	, SE1->E1_TIPO)
			oModelSEL:loadValue("EL_BCOCHQ"	, SE1->E1_BCOCHQ)
			oModelSEL:loadValue("EL_AGECHQ"	, SE1->E1_AGECHQ)
			oModelSEL:loadValue("EL_CTACHQ"	, SE1->E1_CTACHQ)
			oModelSEL:loadValue("EL_EMISSAO", SE1->E1_EMISSAO)
			oModelSEL:loadValue("EL_DTDIGIT", dDataBase)
			oModelSEL:loadValue("EL_DTVCTO"	, SE1->E1_VENCREA)
			oModelSEL:loadValue("EL_NATUREZ", SE1->E1_NATUREZ)
			oModelSEL:loadValue("EL_MOEDA"	, STRZERO(SE1->E1_MOEDA,2))			
			oModelSEL:loadValue("EL_DESCONT", oModelSE1:GetValue("E1_DESCONT", nX))
			oModelSEL:loadValue("EL_MULTA"	, oModelSE1:GetValue("E1_MULTA", nX))
			oModelSEL:loadValue("EL_JUROS"	, oModelSE1:GetValue("E1_JUROS", nX))
			oModelSEL:loadValue("EL_VALOR" 	, oModelSE1:GetValue("BAIXAR", nX) - oModelSE1:GetValue("E1_DESCONT", nX) + oModelSE1:GetValue("E1_JUROS", nX) + oModelSE1:GetValue("E1_MULTA", nX))
			oModelSEL:loadValue("EL_CLIENTE", cCliOri)
			oModelSEL:loadValue("EL_LOJA"	, cLojOri)
			oModelSEL:loadValue("EL_VERSAO"	, "00")
			oModelSEL:loadValue("EL_CLIORIG", SE1->E1_CLIENTE)
			oModelSEL:loadValue("EL_LOJORIG", SE1->E1_LOJA)
			IF SEL->(ColumnPos("EL_FACTOR"))
				oModelSEL:loadValue("EL_FACTOR", oModelFAC:GetValue("FACTOR"))
				oModelSEL:loadValue("EL_COMPEN", oModelFAC:GetValue("VALUE"))
			ENDIF
		EndIf
	Next nX
	
	
	nSelLine := oModelSEL:GetLine()
	
	//Actualización de tasas y datos
	For nX := 1 To oModelSEL:Length()
	
		oModelSEL:GoLine(nX)
		// Gravar Taxa
		self:FINGRVTAX(oModelMOE, @oModelSEL)
			
		nTaxa 	 := oModelMOE:GetValue("TASA", Val(oModelSEL:GetValue('EL_MOEDA')))
		nValMoe1 := Round( oModelSEL:GetValue('EL_VALOR') * nTaxa, MsDecimais(1) )
		oModelSEL:loadValue("EL_VLMOED1", nValMoe1)
		
		
		If oModelSEL:GetValue("EL_TIPODOC",nX) <> "TB" 
			oModelSEL:loadValue("EL_NATUREZ", cNatureza)
			//Reemplazo del cliente por la caja financiera cuando es un documento tipo CC
			IF oModelSEL:GetValue("EL_TIPODOC",nX) == 'CC' .AND. oModelADM:Length()>0
				oModelADM:GoLine(nX)
				oModelSEL:loadValue("EL_CLIENTE", IIF(!VAZIO(oModelADM:GetValue("CODE")),oModelADM:GetValue("CODE"),cCliOri))
			ELSE
				oModelSEL:loadValue("EL_CLIENTE", cCliOri)
			ENDIF
			oModelSEL:loadValue("EL_LOJA"	, cLojOri)
			oModelSEL:loadValue("EL_CLIORIG", cCliOri)
			oModelSEL:loadValue("EL_LOJORIG", cLojOri)
		EndIf
		oModelSEL:loadValue("EL_SERIE"	, cSerie)
		oModelSEL:loadValue("EL_RECIBO"	, cRecibo)
		oModelSEL:loadValue("EL_COBRAD"	, cCobrador)
		oModelSEL:loadValue("EL_RECPROV", cRecProv)
		
		
	Next nX
	oModelSEL:GoLine(nSelLine)

Return Nil

/*/{Protheus.doc} FINUPDSE
Metodo responsable por realizar las actualizaciones de las tablas SE1, SE5, FK1, Fk5

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes..

@author 	raul.medina
@version	12.1.27 / Superior
@since		03/05/2021 
/*/
Method FINUPDSE(oModel) Class F887FIN
Local nOperation	:= oModel:GetOperation()
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local oModelSE1 	:= oModel:GetModel('SE1_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local nX			:= 0
//SE1
Local cSerie		:= oModelFJT:GetValue('FJT_SERIE')
Local cRecibo		:= oModelFJT:GetValue('FJT_RECIBO')
Local cNatureza		:= oModelFJT:GetValue('FJT_NATURE')
Local cRecProv		:= oModelFJT:GetValue("FJT_RECPRV")
Local cCliOri 		:= oModelFJT:GetValue('FJT_CLIENT')
Local cLojOri		:= oModelFJT:GetValue("FJT_LOJA")
Local cCobrador		:= oModelFJT:GetValue("FJT_COBRAD")
Local cGeraNCC		:= oModelFJT:GetValue("GERANCC")
Local cDiario 		:= ""
Local cTpCred		:= ""
Local cTpDoc		:= ""
Local cTipo			:= ""

Local nPosSEL		:= 0
Local nSelLine		:= 0

Local cIDProc		:= FINFKSID('FKA','FKA_IDPROC')
Local oEventFin 	:= self:GetEvent("F887FIN")

	SA1->(msSeek( xFilial("SA1") +cCliOri+ cLojOri)) //Posicionamiento para rutinas externas
	
	For nX := 1 To oModelSEL:Length()
		cTpCred	:= oModelSEL:GetValue("EL_TPCRED",nX)
		cTipo	:= oModelSEL:GetValue("EL_TIPO",nX)
		cTpDoc	:= oModelSEL:GetValue("EL_TIPODOC",nX)
		cDiario	:= oModelSEL:GetValue("EL_DIACTB",nX)
		
		If Iif(self:lDocTran, cTipo $ self:cCredMed .and. oModelSEL:GetValue("EL_TRANSIT",nX) == "2", AllTrim(cTpDoc) $ self:cCredMed)
			self:FINCREDMED(oModelSEL, oModelMOE, nX, cSerie, cRecibo, cTpCred, self:cCredInm, .T., self:lCredInm, .T. , self:lProcede)
			self:FINUPDSEA(oModelSEL, nX)
			If !(cTpCred $ "1|2")
				AtuSalDup("+",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,oModelMOE:GetValue("TASA",SE1->E1_MOEDA),SE1->E1_EMISSAO)
			EndIf
		EndIf
		
		If Iif(self:lDocTran, cTipo $ self:cCredInm .and. oModelSEL:GetValue("EL_TRANSIT",nX) == "2", cTpCred $ "1|2" .or. AllTrim(cTpDoc) $ self:cCredInm) 
			If !self:FINGrvSE5(2,cTpCred,cNatureza,cRecibo,cSerie,cDiario,,cIDProc,oModelFJT,oModelSEL,oModelSE1,oModelMOE, .T.,nX, .F., .T.)
				DisarmTransaction()
				Return .F.
			EndIf
			
			If FinProcITF( SE5->(Recno()),1,,,,,cNatureza ) .AND. F887CkPG(3,self:lValidITF,oModelSEL:GetValue("EL_BANCO",nX))
				FinProcITF( SE5->(Recno()),3,SE5->E5_VALOR, .F.,,,cNatureza,@aRecnoITF)
			EndIf
		EndIf
		
		If !Empty(cCobrador)
			self:FINCOM(oModelSEL,nX)
		EndIf	 
	Next nX

	For nX := 1 To oModelSE1:Length()
		If oModelSE1:GetValue("RECNO",nX) <> 0
			SE1->(MsGoto(oModelSE1:GetValue("RECNO",nX)))
			RecLock("SE1",.F.)
				SE1->E1_BAIXA 	:=	self:dDataRef
				SE1->E1_MOTIVO	:=	oModelSE1:GetValue("E1_MOTIVO", nX)
				SE1->E1_MOVIMEN	:=	self:dDataRef 
				SE1->E1_SALDO	:=	SE1->E1_SALDO - oModelSE1:GetValue("BAIXAR", nX)
				self:nDescoSlv		:= 	SE1->E1_DESCONT
				self:nMultaSlv		:= 	SE1->E1_MULTA
				self:nJurosSlv		:= 	SE1->E1_JUROS
				self:nVlLiqSlv		:= 	SE1->E1_VALLIQ
				SE1->E1_DESCONT	:=	oModelSE1:GetValue("E1_DESCONT", nX)
				SE1->E1_MULTA	:= 	oModelSE1:GetValue("E1_MULTA", nX)
				SE1->E1_JUROS	:= 	oModelSE1:GetValue("E1_JUROS", nX)
				SE1->E1_VALLIQ	:=	oModelSE1:GetValue("BAIXAR", nX) - oModelSE1:GetValue("E1_DESCONT", nX) + oModelSE1:GetValue("E1_JUROS", nX) + oModelSE1:GetValue("E1_MULTA", nX) 
				SE1->E1_SERREC  :=	cSerie
				SE1->E1_RECIBO	:=	cRecibo
				SE1->E1_DTACRED	:=	self:dDataRef
				SE1->E1_STATUS	:= 	IF(SE1->E1_SALDO<=0,"B","A")
				If ExistBlock('F998GSE1')
					ExecBLock('F998GSE1',.F.,.F.)
				Endif	
			MsUnlock()
			If !self:FINGrvSE5(1,,,cRecibo,cSerie,,,cIDProc,oModelFJT,oModelSEL,oModelSE1,oModelMOE, .T., nX, .F., .T.)
				DisarmTransaction()
				Return .F.
			EndIf
		EndIf
	Next nX
	
	If cGeraNCC == "S"
		self:FINGERNCC(cRecibo, cSerie, cCliOri, cLojOri, cCobrador, cRecProv, cCliOri, cLojOri, oEventFin:cDocCred, cNatureza, self:lRoundVal, .F. ,oModelSEL, oModelMOE)
	EndIf
	

Return Nil


/*/{Protheus.doc} FINUPDSE1
Metodo responsable por realizar el tratamiento de la tabla SE!

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados SEL.
@param 		cSerie	 ,caracter	,serie del recibo
@param 		cRecibo	 ,caracter	,numero de recibo
@param 		nLine	 ,numerico	,linea procesada del modelo SE1.

@author 	raul.medina
@version	12.1.27 / Superior
@since		19/04/2021 
/*/
Method FINUPDSE1(oModelSE1, cSerie, cRecibo, nLine) Class F887FIN
Local nDescoSlv		:= 0
Local nMultaSlv		:= 0 
Local nJurosSlv		:= 0

		SE1->E1_BAIXA 	:=	self:dDataRef
		SE1->E1_MOTIVO	:=	oModelSE1:GetValue("E1_MOTBX",nX)
		SE1->E1_MOVIMEN	:=	self:dDataRef 
		SE1->E1_SALDO	:=	SE1->E1_SALDO - oModelSE1:GetValue("BAIXAR",nLine)
		nDescoSlv		:= 	SE1->E1_DESCONT
		nMultaSlv		:= 	SE1->E1_MULTA
		nJurosSlv		:= 	SE1->E1_JUROS
		SE1->E1_DESCONT	:=	oModelSE1:GetValue("E1_DESCONT",nLine)
		SE1->E1_MULTA	:= 	oModelSE1:GetValue("E1_MULTA",	nLine)
		SE1->E1_JUROS	:= 	oModelSE1:GetValue("E1_JUROS",	nLine)
		SE1->E1_VALLIQ	:=	oModelSE1:GetValue("BAIXAR",nLine) - oModelSE1:GetValue("E1_DESCONT",nLine) + oModelSE1:GetValue("E1_JUROS",	nLine) + oModelSE1:GetValue("E1_MULTA",	nLine) 
		SE1->E1_SERREC  :=	cSerie
		SE1->E1_RECIBO	:=	cRecibo
		SE1->E1_DTACRED	:=	self:dDataRef
		SE1->E1_STATUS	:= 	IF(SE1->E1_SALDO<=0,"B","A")

Return Nil

/*/{Protheus.doc} FINCREDMED
Metodo responsable por realizar el tratamiento para documentos
de credito med

@type 		Method

@param 		oModelSEL	,objeto		,Modelo de dados SEL.
@param 		oModelMOE 	,objeto		,Modelo de dados de monedas y saldos.
@param 		nPosLine 	,numerico	,linea procesada del modelo SEL.
@param 		cSerie	 	,caracter	,serie del recibo
@param 		cRecibo	 	,caracter	,numero de recibo
@param 		cTipoCred	,caracter	,tipo de credito
@param 		cCredInm	,caracter	,documentos de credito inmediato
@param 		lCred		,logico		,indica si realiza tratamiento para credito med
@param 		lCredIm		,logico 	,indica si realiza tratamiento para credito inmediato
@param 		lMsUnLock	,logico 	,indica si se realiza el msunlook

@author 	raul.medina
@version	12.1.27 / Superior
@since		20/04/2021 
/*/

Method FINCREDMED(oModelSEL, oModelMOE, nPosLine, cSerie, cRecibo, cTipoCred, cCredInm, lCred, lCredIm ,lMsUnLock,lProcede) Class F887FIN

Local nDias		:= 0
Local dBase
Local aFeriados := {}

Default cSerie 		:= ""
Default cRecibo 	:= ""
Default cTipoCred 	:= ""
Default cCredInm 	:= ""
Default lCred		:= .T.
Default lCredIm		:= .F.
Default lMsUnLock	:= .T.

	SE1->(DbSetOrder(2)) // 
	If SE1->(DbSeek(xFilial("SE1")+oModelSEL:GetValue("EL_CLIENTE",nPosLine)+oModelSEL:GetValue("EL_LOJA",nPosLine)+oModelSEL:GetValue("EL_PREFIXO",nPosLine)+oModelSEL:GetValue("EL_NUMERO",nPosLine)+;
		oModelSEL:GetValue("EL_PARCELA",nPosLine)+oModelSEL:GetValue("EL_TIPODOC",nPosLine)))
		RecLock("SE1",.F.)
	Else
		RecLock("SE1",.T.)
	Endif
	
	SE1->E1_FILIAL := xFilial("SE1")
	SE1->E1_FILORIG:= cFilant
	SE1->E1_SERREC := oModelSEL:GetValue("EL_SERIE",nPosLine)
	SE1->E1_RECIBO := oModelSEL:GetValue("EL_RECIBO",nPosLine)
	SE1->E1_PREFIXO:= oModelSEL:GetValue("EL_PREFIXO",nPosLine)
	SE1->E1_NUM    := oModelSEL:GetValue("EL_NUMERO",nPosLine)
	SE1->E1_PARCELA:= oModelSEL:GetValue("EL_PARCELA",nPosLine)
	SE1->E1_TIPO   := oModelSEL:GetValue("EL_TIPODOC",nPosLine)          // ALTERADO oModelSEL:GetValue("",nPosLine)EL_TIPODOC (conteudo do FJS_TIPOIN  
	SE1->E1_PORTADO:= oModelSEL:GetValue("EL_BANCO",nPosLine)
	SE1->E1_AGEDEP := oModelSEL:GetValue("EL_AGENCIA",nPosLine)
	SE1->E1_CONTA  := oModelSEL:GetValue("EL_CONTA",nPosLine)
	SE1->E1_BCOCHQ := oModelSEL:GetValue("EL_BCOCHQ",nPosLine)
	SE1->E1_AGECHQ := oModelSEL:GetValue("EL_AGECHQ",nPosLine)
	SE1->E1_CTACHQ := oModelSEL:GetValue("EL_CTACHQ",nPosLine)
	SE1->E1_EMISSAO:= oModelSEL:GetValue("EL_EMISSAO",nPosLine)   //dDataRef
	SE1->E1_EMIS1  := CtoD("")
	SE1->E1_VENCREA:= DATAVALIDA(oModelSEL:GetValue("EL_DTVCTO",nPosLine))
	SE1->E1_VENCTO := oModelSEL:GetValue("EL_DTVCTO",nPosLine)
	SE1->E1_VENCORI:= oModelSEL:GetValue("EL_DTVCTO",nPosLine)
	SE1->E1_NATUREZ:= oModelSEL:GetValue("EL_NATUREZ",nPosLine)
	SE1->E1_MOEDA  := Val(oModelSEL:GetValue("EL_MOEDA",nPosLine))
	SE1->E1_CLIENTE:= oModelSEL:GetValue("EL_CLIENTE",nPosLine)
	SE1->E1_LOJA   := oModelSEL:GetValue("EL_LOJA",nPosLine)
	SE1->E1_VALOR  := oModelSEL:GetValue("EL_VALOR",nPosLine)
	SE1->E1_SALDO  := oModelSEL:GetValue("EL_VALOR",nPosLine)
	
	SE1->E1_VLCRUZ := oModelSEL:GetValue("EL_VALOR",nPosLine)*oModelMOE:GetValue("TASA",SE1->E1_MOEDA)
	
	SE1->E1_NOMCLI := GetAdvFVal("SA1","A1_NREDUZ",xFilial("SA1")+PadR(oModelSEL:GetValue("EL_CLIENTE",nPosLine),GetSx3Cache("A1_COD","X3_TAMANHO"))+PadR(oModelSEL:GetValue("EL_LOJA",nPosLine),GetSx3Cache("A1_LOJA","X3_TAMANHO")),1,"")
	SE1->E1_EMIS1  := dDataBase
	SE1->E1_TXMOEDA:= oModelMOE:GetValue("TASA",SE1->E1_MOEDA)
	
	If lCred .and. (cTipoCred $ "1|2" .Or. ( lCredIm .and. oModelSEL:GetValue("EL_TIPO",nPosLine) $ cCredInm))  .and. lProcede //Cheques vindos de credito imediato devem entrar como baixados
		SE1->E1_BAIXA		:=If(cTipoCred == "1",dDatabase,DataValida(oModelSEL:GetValue("EL_DTVCTO",nPosLine)))
		SE1->E1_LA			:='S'
		SE1->E1_MOTIVO  	:=""
		SE1->E1_MOVIMEN     :=SE1->E1_BAIXA
		SE1->E1_SALDO       :=0
		SE1->E1_DESCONT     :=0
		SE1->E1_MULTA       :=0
		SE1->E1_JUROS       :=0
		SE1->E1_VALLIQ      := oModelSEL:GetValue("EL_VALOR",nPosLine)
		SE1->E1_SERREC      := cSerie
		SE1->E1_RECIBO      := cRecibo
		SE1->E1_DTACRED     := SE1->E1_BAIXA
	EndIf
	
	//+--------------------------------------------------------------------------------+
	//¦Si no se ingreso el banco o se ingreso en una caja, SITUACA es 0 (en cartera)   ¦
	//+--------------------------------------------------------------------------------+
	If (Empty(oModelSEL:GetValue("EL_BANCO",nPosLine)).And.Empty(oModelSEL:GetValue("EL_CONTA",nPosLine)).And.Empty(oModelSEL:GetValue("EL_AGENCIA",nPosLine))).Or.;
		(oModelSEL:GetValue("EL_BANCO",nPosLine) $ (GetNewPar("MV_CARTEIR","")+"/"+Left(GetNewPar("MV_CXFIN",""),GetSx3Cache("A6_COD","X3_TAMANHO"))))
		SE1->E1_SITUACA:= "0"
	ElseIf oModelSEL:GetValue("EL_BANCO",nPosLine) $ (GetNewPar("MV_CARTEIR","")+"/"+Left(GetNewPar("MV_CXFIN",""),GetSx3Cache("A6_COD","X3_TAMANHO")))
		SE1->E1_SITUACA:= "0"
	Else
		SE1->E1_SITUACA:= "1" //840 - 0; 087a - 1
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo para o tempo de Clearing, o tempo de Clearing esta³
	//³sendo calculado somente com dias uteis corridos.          ³
	//³Se o Tempo for de mais de uma semana, coloco uma data de  ³
	//³aqui a dez anos assim tem que ser acreditado manualmente. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If cTipoCred == "1"
		SE1->E1_DTACRED:=dDatabase
	ElseIf cTipoCred == "2"
		SE1->E1_DTACRED:=DataValida(oModelSEL:GetValue("EL_DTVCTO",nPosLine))
	ElseIf cTipoCred == "3"
		nDias:=Val(oModelSEL:GetValue("EL_ACREBAN",nPosLine))
		dBase:=  SE1->E1_VENCREA
		If nDias > 5
			dBase += 3650
		Else
			aFeriados:=RetFeriados()
			While nDias > 0
				dBase++
				If Ascan(aFeriados,Dtos(dBase)) == 0 .And. Dow(dBase) <> 1 .And. Dow(dBase) <> 7
					nDias--
				EndIf
			EndDo
		Endif
		SE1->E1_DTACRED:= dBase
	EndIf
	
	SE1->E1_ORIGEM := "FINA887"
	
	SE1->E1_VLCRUZ := oModelSEL:GetValue("EL_VLMOED1",nPosLine)
	SE1->E1_LA     := "S"
	SE1->E1_STATUS := IF(SE1->E1_SALDO<=0,"B","A")
	SE1->E1_MOVIMEN:= SE1->E1_DTACRED
		      
	MsUnLock()
	FKCOMMIT()

Return Nil

/*/{Protheus.doc} FINUPDSEA
Metodo responsable por realizar el tratamiento de la tabla SEA

@type 		Method

@param 		oModelSEL	,objeto		,Modelo de dados SEL.
@param 		nPosLine 	,numerico	,linea procesada del modelo SE1.

@author 	raul.medina
@version	12.1.27 / Superior
@since		19/04/2021 
/*/
Method FINUPDSEA(oModelSEL, nPosLine) Class F887FIN


	If SE1->E1_SITUACA=="1"
		SEA->(DbSetOrder(1))
		If SEA->(DbSeek(xFilial("SEA")+oModelSEL:GetValue("EL_PREFIXO",nPosLine)+oModelSEL:GetValue("EL_NUMERO",nPosLine)+oModelSEL:GetValue("EL_PARCELA",nPosLine)))
			RecLock("SEA",.F.)
			SEA->EA_DATABOR := oModelSEL:GetValue("EL_DTVCTO",nPosLine)
			SEA->EA_PORTADO := oModelSEL:GetValue("EL_BANCO",nPosLine)
			SEA->EA_AGEDEP  := oModelSEL:GetValue("EL_AGENCIA",nPosLine)
			SEA->EA_NUMCON  := oModelSEL:GetValue("EL_CONTA",nPosLine)
			SEA->EA_TIPO    := oModelSEL:GetValue("EL_TIPODOC",nPosLine)
			SEA->EA_CART    := "R"
			SEA->EA_SITUACA := "1"
			SEA->EA_FILORIG := SE1->E1_FILIAL
			SEA->(MsUnlock())
			FKCOMMIT()
		Else
			If ! Empty(oModelSEL:GetValue("EL_BANCO",nPosLine))
				RecLock("SEA",.T.)
				SEA->EA_FILIAL  := xFilial("SEA")
				SEA->EA_DATABOR := oModelSEL:GetValue("EL_DTVCTO",nPosLine)
				SEA->EA_PORTADO := oModelSEL:GetValue("EL_BANCO",nPosLine)
				SEA->EA_AGEDEP  := oModelSEL:GetValue("EL_AGENCIA",nPosLine)
				SEA->EA_NUMCON  := oModelSEL:GetValue("EL_CONTA",nPosLine)
				SEA->EA_NUM     := oModelSEL:GetValue("EL_NUMERO",nPosLine)
				SEA->EA_PARCELA := oModelSEL:GetValue("EL_PARCELA",nPosLine)
				SEA->EA_PREFIXO := oModelSEL:GetValue("EL_PREFIXO",nPosLine)
				SEA->EA_TIPO    := oModelSEL:GetValue("EL_TIPODOC",nPosLine)
				SEA->EA_CART    := "R"
				SEA->EA_SITUACA := "1"
				SEA->EA_FILORIG := SE1->E1_FILIAL
				SEA->(MsUnlock())
				FKCOMMIT()
			EndIf
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} FINGRVTAX
Metodo responsable por realizar el tratamiento de informar las tasas.

@type 		Method

@param 		oModelMOE	,objeto		,Modelo de dados de monedas y saldos.
@param 		oModelSEL	,objeto		,Modelo de dados SEL.
@param 		lTab	 	,logico 	,indica si actualiza tabla o modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		19/04/2021 
/*/
Method FINGRVTAX(oModelMOE, oModelSEL, lTab) Class F887FIN
Local nTx		:= 0
Local nMoeda	:= 0
Local cCpoMoe	:= ""
Local cCpoSEL	:= ""

Default lTab	:= .F.

	For nTx	:= 1 To oModelMOE:Length()
		cCpoMoe	:= oModelMOE:GetValue('MOEDA',nTx)
		nMoeda	:= Val(cCpoMoe)
		cCpoSEL	:= "EL_TXMOE"+StrZero(nMoeda,2)
		If aScan(oModelSEL:aHeader, {|cpo| AllTrim(cpo[2]) == cCpoSEL})
			If lTab
				SEL->&(cCpoSEL) := oModelMOE:GetValue('TASA',nTx)
			Else
				oModelSEL:loadValue(cCpoSEL, oModelMOE:GetValue('TASA',nTx))
			EndIf
		EndIf
	Next nTx

Return Nil

/*/{Protheus.doc} FINGERNCC
Metodo responsable por realizar el tratamiento de documentos 
por credito (RA, NCC)


@type 		Method

@param 		cSerie	 	,caracter	,serie del recibo
@param 		cRecibo	 	,caracter	,numero de recibo
@param 		cCliente 	,caracter	,cliente del recibo
@param 		cLoja	 	,caracter	,loja del cliente
@param 		cCobrador 	,caracter	,cobrador usado en el recibo
@param 		cRecProv 	,caracter	,recibo provisional
@param 		cCliOri 	,caracter	,cliente del recibo
@param 		cLojOri	 	,caracter	,loja del cliente
@param 		cDocCred	,caracter	,documento usado para el credito
@param 		cNatureza	,caracter	,naturaliza usada en el recibo
@param 		lRoundVal	,logico		,indica si realiza tratamiento de redondeo.
@param 		lValImp		,logico 	,indica si usa impuestos para el valor del titulo
@param 		oModelSEL	,objeto		,Modelo de dados SEL.
@param 		oModelMOE 	,objeto		,Modelo de dados de monedas y saldos.

@author 	raul.medina
@version	12.1.27 / Superior
@since		21/04/2021 
/*/
Method FINGERNCC(cRecibo, cSerie, cCliente, cLoja, cCobrador, cRecProv, cCliOri, cLojOri, cDocCred, cNatureza, lRoundVal, lValImp ,oModelSEL, oModelMOE) Class F887FIN
Local cParc		:= " "
Local nValMoed	:= 0
Local cNomCli	:= GetAdvFVal("SA1","A1_NREDUZ",xFilial("SA1")+PadR(cCliente,GetSx3Cache("A1_COD","X3_TAMANHO"))+PadR(cLoja,GetSx3Cache("A1_LOJA","X3_TAMANHO")),1,"")


Default lValImp		:= .F.
Default lRoundVal	:= .F.

	
	While SE1->(DbSeek(xFilial("SE1")+"REC"+Padr(cRecibo,GetSx3Cache("E1_NUM","X3_TAMANHO")," ")+Padr(cParc,GetSx3Cache("E1_PARCELA","X3_TAMANHO")," ")+cDocCred))
		cParc:=Soma1(cParc)
	Enddo
		
	For nValMoed := 1 To oModelMOE:Length()
		If !lValImp
			nVlrTit	:= oModelMOE:GetValue("SALDO", nValMoed)
		EndIf
		
		If nVlrTit > 0
			RecLock("SEL",.T.)
				SEL->EL_FILIAL		:= xFilial("SEL")
				SEL->EL_TIPODOC 	:= "RA"
				SEL->EL_PREFIXO  	:= "REC"
				SEL->EL_NUMERO   	:= cRecibo
				SEL->EL_PARCELA  	:= cParc
				SEL->EL_TIPO   	 	:= cDocCred
				SEL->EL_EMISSAO  	:= self:dDataRef
				SEL->EL_DTDIGIT		:= dDataBase
				SEL->EL_DTVCTO   	:= self:dDataRef
				SEL->EL_NATUREZ  	:= cNatureza
				SEL->EL_MOEDA    	:= StrZero(nValMoed,2)//Aqui representa qual e a moeda
				SEL->EL_VLMOED1  	:= Round( nVlrTit*oModelMOE:GetValue("TASA", nValMoed), MsDecimais(1))
				SEL->EL_VALOR    	:= nVlrTit
				SEL->EL_CLIENTE  	:= cCliente
				SEL->EL_LOJA	 	:= cLoja
				SEL->EL_SERIE 	 	:= cSerie
				SEL->EL_RECIBO 	 	:= cRecibo
				SEL->EL_COBRAD		:= cCobrador
				SEL->EL_RECPROV		:= cRecProv
				SEL->EL_CLIORIG		:= cCliOri
				SEL->EL_LOJORIG		:= cLojOri
				SEL->EL_VERSAO		:= "00"
				
				self:FINGRVTAX(oModelMOE, @oModelSEL,.T.)
	
			SEL->(MsUnlock())
			
			RecLock("SE1",.T.)
				SE1->E1_FILIAL   	:= xFILIAL("SE1")
				SE1->E1_FILORIG     := cFilant
				SE1->E1_PREFIXO  	:= "REC"
				SE1->E1_NUM			:= cRecibo
				SE1->E1_PARCELA		:= cParc
				SE1->E1_TIPO     	:= cDocCred  // correto grava o tipo do SX1 
				SE1->E1_EMISSAO  	:= self:dDataRef
				SE1->E1_EMIS1    	:= dDataBase
				SE1->E1_VENCTO  	:= self:dDataRef
				SE1->E1_VENCREA 	:= DataValida(self:dDataRef)
				SE1->E1_NATUREZ  	:= SEL->EL_NATUREZ
				SE1->E1_MOEDA   	:= nValMoed
				If lRoundVal
					SE1->E1_VLCRUZ	:= Round( nVlrTit * oModelMOE:GetValue("TASA", nValMoed), MsDecimais(1) )
				Else
					SE1->E1_VLCRUZ	:= nVlrTit*oModelMOE:GetValue("TASA", nValMoed)
				Endif
				SE1->E1_VALOR   	:= nVlrTit
				SE1->E1_SALDO   	:= nVlrTit
				SE1->E1_CLIENTE 	:= cCliente
				SE1->E1_LOJA    	:= cLoja
				SE1->E1_SERREC      := cSerie
				SE1->E1_RECIBO  	:= cRecibo
				SE1->E1_NOMCLI   	:= cNomCli
				SE1->E1_SITUACA  	:= "0"
				SE1->E1_ORIGEM   	:= "FINA887"
				SE1->E1_LA       	:= "S"
				SE1->E1_STATUS   	:= "A"
				SE1->E1_TXMOEDA		:= oModelMOE:GetValue("TASA", nValMoed)
			SE1->(MsUnlock())
			
			AtuSalDup("-",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,oModelMOE:GetValue("TASA",SE1->E1_MOEDA),SE1->E1_EMISSAO)
			cParc := Soma1(cParc)//Atualiza a proxima parcela
		EndIf
	Next nValMoed

Return

/*/{Protheus.doc} FINCOM
Metodo responsable por realizar el tratamiento 

@type 		Method

@param 		oModelSEL	,objeto		,Modelo de dados SEL.
@param 		nPosLine 	,numerico	,linea procesada del modelo SEL.

@author 	raul.medina
@version	12.1.27 / Superior
@since		20/04/2021 
/*/
Method FINCOM(oModelSEL, nPosLine) Class F887FIN

Local aCpoSEX	:= {}
	
	SAQ->(Recno())
	//SE MUDAR ALGUMA POSICAO DO ARRAY ABAIXO, PRECISA CORRIGIR TB NOS FONTES FINA016/FINA87A/FINA088.
	AADD(aCpoSEX, oModelSEL:GetValue("EL_COBRAD",nPosLine) )
	AADD(aCpoSEX, oModelSEL:GetValue("EL_SERIE",nPosLine) )
	AADD(aCpoSEX, oModelSEL:GetValue("EL_RECIBO",nPosLine) )
	AADD(aCpoSEX, oModelSEL:GetValue("EL_DTDIGIT",nPosLine) )
	AADD(aCpoSEX, oModelSEL:GetValue("EL_CLIORIG",nPosLine))
	AADD(aCpoSEX, oModelSEL:GetValue("EL_LOJORIG",nPosLine) )
	AADD(aCpoSEX, oModelSEL:GetValue("EL_VALOR",nPosLine)  )
	AADD(aCpoSEX, SAQ->AQ_COMIS)
	AADD(aCpoSEX, Val( oModelSEL:GetValue("EL_MOEDA",nPosLine)))
	AADD(aCpoSEX, (oModelSEL:GetValue("EL_VALOR",nPosLine) ) * (SAQ->AQ_COMIS/100) )
	AADD(aCpoSEX, oModelSEL:GetValue("EL_TIPODOC",nPosLine) )	
	AADD(aCpoSEX, oModelSEL:GetValue("EL_NUMERO",nPosLine))
	
	Fa016Calc(aCpoSEX)	

Return Nil

/*/{Protheus.doc} FINCOB
Metodo responsable por realizar el tratamiento para documentos
de credito med

@type 		Method

@param 		cTipo	 	,caracter	,tipo
@param 		cCobrador	,caracter	,cobrador
@param 		cRecProv 	,caracter	,numero de recibo provisional
@param 		cSerie	 	,caracter	,serie del recibo

@author 	raul.medina
@version	12.1.27 / Superior
@since		20/04/2021 
/*/
Method FINCOB(cTipo, cCobrador, cRecProv, cSerie, cRecibo) Class F887FIN
Local aArea		:= GetArea()       
Local lRet		:= .F.
Local lValSer 	:= .F.
Local cRecComp	:= ""

Default cCobrador := ""
	
	lValSer := SuperGetMv('MV_SERREC') // Usando serie nos recibos 
	
	If !Empty(cCobrador)
		DbSelectArea("SAQ")
		DbSetOrder(1)
		If dbSeek(xFilial("SAQ")+cCobrador) 
			self:nRecnoSAQ := Recno()
			If SAQ->AQ_TIPOREC=="3" .or. cTipo <> SAQ->AQ_TIPOREC .or. cTipo= "3"
				lRet:=.T.
			Else
				cRecComp	:= Iif(SAQ->AQ_TIPOREC =="1",cRecibo,cRecProv)
				cTipo 	:= SAQ->AQ_TIPOREC // Valida Tipo do Recibo do Cobrador  
				DbSelectArea("SEY")
				DbSetOrder(1)
				If dbSeek(xFilial("SEY")+cCobrador)      
					//So validar a serie quando é um recibo definitivo, provisorio nao tem serie
					While !EOF() .and. cCobrador == SEY->EY_COBRAD 	
						If SEY->EY_STATUS<>"2" .and. cTipo == SEY->EY_TIPOREC .and. ;
							cRecComp  >= SEY->EY_RECINI .and. cRecComp <= SEY->EY_RECFIN .and.;
							If(lValser .And. cTipo == '1', cSerie== SEY->EY_SERIE .Or. Empty(SEY->EY_SERIE),.T.)
								
							lRet:=.T.
							nRecnoSEY := SEY->(Recno())
							Exit
						EndIf
						DbSkip()
					EndDo
				EndIf
				If !lRet
					HELP(" ",1,"A087NUMV")
				EndIf
			EndIf
		Else
			Help(" ",1,"RECNO")
		EndIf
	Else	
		lRet:=.T.
	EndIf	
	RestArea(aArea)
	
Return(lRet)

/*/{Protheus.doc} FINGrvSE5
Metodo responsable por realizar la grabación de las tablas SE5 y Fk's'
de credito med

@type 		Method

@param 		nTipo		,numeri		,tipo
@param 		cTpCred 	,caracter	,tipo de credito
@param 		cNatureza 	,caracter	,naturaleza del recibo
@param 		cRecibo	 	,caracter	,numero de recibo
@param 		cSerie	 	,caracter	,serie del recibo
@param 		cDiarioSE5	,caracter	,
@param 		cMotBxSE5	,caracter	,motivo de baja
@param 		cIDProc		,caracter	,id de proceso
@param 		oModelFJT	,objeto		,Modelo de dados FJT.
@param 		oModelSEL 	,objeto		,Modelo de dados SEL.
@param 		oModelSE1	,objeto		,Modelo de dados SE1.
@param 		oModelMOE 	,objeto		,Modelo de dados de monedas y saldos.
@param 		lAlt		,logico 	,indica si realiza historico de cobranza
@param 		nPosLin		,logico 	,linea procesada
@param 		lCheque		,logico 	,indica si realiza tratamiento para cheques (ARG)
@param 		lCorrMon	,logico 	,indica si realiza tratamiento para correcion monetaria

@author 	raul.medina
@version	12.1.27 / Superior
@since		20/04/2021 
/*/
Method FINGrvSE5(nTipo, cTpCred, cNatureza, cRecibo, cSerie, cDiarioSE5, cMotBxSE5, cIDProc, oModelFJT, oModelSEL, oModelSE1, oModelMOE, lAlt, nPosLin, lCheque, lCorrMon) Class F887FIN
Local lAdiantamento	:= .F.
Local nTxMoeda 		:= 0   
Local nMoedaF	 	:= 1
Local lGrvMov 		:= .T.
Local oModMovBco	:= Nil
Local oFK5MovBco	:= Nil
Local oFKAMovBco	:= Nil
Local oModelMov		:= FWLoadModel("FINM030") //Model de Mov. Bco.
Local oSubFKA		:= Nil	//RELACIONAMENTO
Local oSubFK5		:= Nil //MOVTO BANCARIO
Local oSubFK6     	:= Nil //MOVTO acessoorios
Local cFilSE5		:= FWxFilial("SE5")
Local cCamposE5		:= ""
Local cIdFK5		:= ""
Local cLog			:= ""
Local nTamHist    	:= GetSx3Cache("FK5_HISTOR","X3_TAMANHO")
Local cHistMov    	:= ""   
Local lRet			:= .T. //Validação do Modelo
Local aAlt 			:= {}
Local cFilFK6		:= FWxFilial("FK6")
Local cIdFK2		:= ''
Local cChaveCH 		:= ""
Local cMoeda		:= ""

Local lExistFKD	:= ExistFunc("FAtuFKDBx")

Local nTaxa			:= 1
Local aBaixas		:= {}

Local nTxCor		:= 0
Local nValOrig		:= 0
Local nValAtu		:= 0

Local aDiario 		:= {}
//Private aBaixas		:= {}

Default nTipo		:= ""
Default cTpCred		:= ""
Default cNatureza	:= ""
Default cRecibo 	:= ""
Default cSerie		:= ""
Default cDiarioSE5	:= ""
Default cMotBxSE5	:= "NOR"
Default cIDProc		:= ""
Default oModelFJT	:= Nil
Default oModelSEL	:= Nil
Default oModelSE1	:= Nil
Default oModelMOE	:= Nil
Default lAlt		:= .F.
Default lCheque		:= .F.
Default lCorrMon	:= .F.


If nTipo==1

	lAdiantamento := .F.
	
	nTaxa := oModelMOE:GetValue("TASA",SE1->E1_MOEDA)
	
	If self:lTasa  //!(cPaisloc$"PAR|BOL") 
		nDescont	  := SE1->E1_DESCONT * nTaxa
		nJuros		  := SE1->E1_JUROS   * nTaxa
		nMulta		  := SE1->E1_MULTA   * nTaxa
		nValRec		  := SE1->E1_VALLIQ  * nTaxa
	Else
		nDescont	  := SE1->E1_DESCONT
		nJuros		  := SE1->E1_JUROS
		nMulta		  := SE1->E1_MULTA
		nValRec		  := SE1->E1_VALLIQ
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Taxa da moeda: calcula segundo valores do titulo SE1         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTxMoeda := Round( SE1->E1_VLCRUZ/SE1->E1_VALOR , GetSx3Cache("M2_MOEDA"+AllTrim(STR(SE1->E1_MOEDA)),"X3_DECIMAL") )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A correcao monetaria nao deve ser gravada pois os pagamentos sao feitos em bloco,    ³
	//³e nao temos como saber se o titulo foi pago com a mesma moeda (neste caso nao existe ³
	//³correcao monetaria) ou com outra moeda diferente.                                    ³
	//³A correcao eh tratada nos relatorios.                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCM			:=	0
	nValToler	:=	0
	cLoteFin	:= GetSx8Num("SE5", "E5_LOTE", "E5_LOTE" + cEmpAnt)
	If lAdiantamento
		cBanco		:= SE1->E1_PORTADO
		cAgencia	:= SE1->E1_AGEDEP
		cConta		:= SE1->E1_CONTA
	Else
		cBanco		:= ""
		cAgencia	:= ""
		cConta		:= ""
	Endif
	nValEstrang	:= SE1->E1_VALLIQ
	dBaixa  	:= SE1->E1_DTACRED
	cMotBx		:= IF(Empty(SE1->E1_MOTIVO),"NOR",SE1->E1_MOTIVO)
	cHist070	:= STR0046 + cRecibo + "-" + cSerie //"Valor recebido por Recibo "
	nMoedaF:= If(SA1->A1_MOEDALC > 0,SA1->A1_MOEDALC,Val(SuperGETMV("MV_MCUSTO")))
	nTotAbat := 0
	
	//Atualiza saldo dos valores acessórios (FKD)
	If lExistFKD
		FAtuFKDBx(.F.)
	EndIf	
	
	FA070Mov(.T.,.T.,lAdiantamento,SE1->E1_DTACRED,@aBaixas,,,nTaxa,,,,,cIDProc)
	ConfirmSX8()
	AtuSalDup(IIf(SE1->E1_TIPO$MV_CRNEG+"/"+MVRECANT,"+","-"),SE1->(E1_VALLIQ+E1_DESCONT-E1_JUROS-E1_MULTA),SE1->E1_MOEDA,SE1->E1_TIPO,oModelMOE:GetValue('TASA', nMoedaF),dDataBase)
	dbSelectArea("SE1")
	nSalvRec	:= SE1->(RecNo())
	cNum	  	:= SE1->E1_NUM
	cPrefixo	:= SE1->E1_PREFIXO
	cParcela	:= SE1->E1_PARCELA
	cCliente	:= SE1->E1_CLIENTE
	cLoja     	:= SE1->E1_LOJA
	cTipo   	:= ""
	If SuperGETMV("MV_TPCOMIS") == "O"
		aBaixas:={}
		If UsaSeqCor()
			AAdd(aDiario,{"SE5",SE5->(Recno()),cDiario,"E5_NODIA","E5_DIACTB"})
  		EndIf
		AAdd(aBaixas,{SE5->E5_MOTBX,SE5->E5_SEQ,SE5->(Recno()),,SE1->E1_VEND1})
		Pergunte("AFI440",.F.)
		Fa440CalcB(aBaixas,.F.,.F.,"FINA887",,,,.T.,SE1->(Recno()))
	Endif
	
	If lAlt

		///numbor			
		aAlt := {}
	    aadd( aAlt,{ STR0044 ,'','','',STR0045  + Alltrim(Transform(nValEstrang,PesqPict("SE5","E5_VALOR"))) })//"Baja vía recibo" //"Se realizó una baja por el valor de "
		///chamada da Função que cria o Histórico de Cobrança
		FinaCONC(aAlt)	
	EndIf

ElseIf nTipo==2
	
	If lGrvMov
		SE5->(DbSetOrder(3))//	E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)
		IF !(SE5->(DbSeek(xFilial("SE5")+oModelSEL:GetValue("EL_BANCO", nPosLin)+oModelSEL:GetValue("EL_AGENCIA", nPosLin)+oModelSEL:GetValue("EL_CONTA", nPosLin)+;
			oModelSEL:GetValue("EL_PREFIXO", nPosLin)+oModelSEL:GetValue("EL_NUMERO", nPosLin)+oModelSEL:GetValue("EL_PARCELA", nPosLin)+oModelSEL:GetValue("EL_TIPODOC", nPosLin)+ DTOS(oModelSEL:GetValue("EL_DTVCTO",nPosLin)))))
			oModelMov:SetOperation( MODEL_OPERATION_INSERT )
			oModelMov:Activate()
			oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //habilita gravação de SE5
			oModelMov:SetValue( "MASTER", "IDPROC", cIDProc )
			oModelMov:SetValue( "MASTER", "NOVOPROC", .F. ) //Informa que a inclusão não será feita com um novo número de processo
			
		Else
			Return
		Endif
		
		oSubFK5	:= oModelMov:GetModel("FK5DETAIL")
		oSubFK6    := oModelMov:GetModel("FK6DETAIL")
		oSubFKA	:= oModelMov:GetModel("FKADETAIL")
	
		//Reposiciono o banco informado no Recibo
		SA6->(DbSetOrder(1))
		SA6->(DbSeek(xFilial()+oModelSEL:GetValue("EL_BANCO", nPosLin)+oModelSEL:GetValue("EL_AGENCIA",nPosLin)+oModelSEL:GetValue("EL_CONTA", nPosLin)))
	
		//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
		cCamposE5 += " { "
		cCamposE5 += " {'E5_FILIAL'		,'" + cFilSE5 + "'}"
		cCamposE5 += ",{'E5_PREFIXO'	,'" + oModelSEL:GetValue("EL_PREFIXO", nPosLin) +"'}"
		cCamposE5 += ",{'E5_NUMERO'		,'" + oModelSEL:GetValue("EL_NUMERO", nPosLin) + "'}"
		cCamposE5 += ",{'E5_PARCELA'	,'" + oModelSEL:GetValue("EL_PARCELA", nPosLin) + "'}"
		cCamposE5 += ",{'E5_CLIFOR'		,'" + oModelSEL:GetValue("EL_CLIENTE", nPosLin) + "'}"
		cCamposE5 += ",{'E5_LOJA'		,'" + oModelSEL:GetValue("EL_LOJA", nPosLin) + "'}"
		cCamposE5 += ",{'E5_BENEF'		,'" + SE1->E1_NOMCLI + "'}"
		cCamposE5 += ",{'E5_TIPO'		,'" + oModelSEL:GetValue("EL_TIPODOC", nPosLin) + "'}"
		cCamposE5 += ",{'E5_DTDIGIT'	, STOD('" + DTOS(dDataBase) + "')}"
		cCamposE5 += ",{'E5_SERREC'		,'" + oModelFJT:GetValue("FJT_SERIE") + "'}"
		cCamposE5 += ",{'E5_VENCTO'		, STOD('" + DTOS(oModelSEL:GetValue("EL_DTVCTO", nPosLin)) + "')}"
		If !oSubFKA:IsEmpty()
			oSubFKA:AddLine()
		EndIf
		cIdFK5 := FWUUIDV4()
		oSubFKA:SetValue( "FKA_IDORIG"  , cIdFK5 )
		oSubFKA:SetValue( "FKA_TABORI" 	, 'FK5' ) //Todo o recibo precisa do mesmo número de processo
		
		cHistMov := Left( STR0046 + oModelFJT:GetValue("FJT_RECIBO") + "-" + oModelFJT:GetValue("FJT_SERIE") , nTamHist )	//"Valor cobrado por recibo "
		oSubFK5:SetValue( "FK5_RECPAG"	, "R" )
		oSubFK5:SetValue( "FK5_HISTOR"	, cHistMov ) //"Valor recebido por Recibo "
		oSubFK5:SetValue( "FK5_DATA"	, oModelFJT:GetValue("FJT_EMISSA") ) 
		oSubFK5:SetValue( "FK5_DTDISP"	, IIf(cTpCred=="1",self:dDataRef,oModelSEL:GetValue("EL_DTVCTO", nPosLin)) )	// 1-Imediato  2-Vencimento
		oSubFK5:SetValue( "FK5_TPDOC"	, "VL" )
		oSubFK5:SetValue( "FK5_VLMOE2"	, oModelSEL:GetValue("EL_VALOR",nPosLin) )
		oSubFK5:SetValue( "FK5_ORDREC"	, oModelFJT:GetValue("FJT_RECIBO") )
		oSubFK5:SetValue( "FK5_MOEDA"	, StrZero( SA6->A6_MOEDA, 2) )
		cMoeda := oModelSEL:GetValue("EL_MOEDA", nPosLin)
		oSubFK5:SetValue( "FK5_VALOR"	, xMoeda(oModelSEL:GetValue("EL_VALOR", nPosLin),Val(cMoeda),Max(SA6->A6_MOEDA,1),,,oModelMOE:GetValue("TASA", Val(cMoeda)),oModelMOE:GetValue("TASA", Max(SA6->A6_MOEDA,1)) ) )
		oSubFK5:SetValue( "FK5_BANCO"	, oModelSEL:GetValue("EL_BANCO", nPosLin) )
		oSubFK5:SetValue( "FK5_AGENCI"	, oModelSEL:GetValue("EL_AGENCIA", nPosLin) )
		oSubFK5:SetValue( "FK5_CONTA"	, oModelSEL:GetValue("EL_CONTA", nPosLin) )
		oSubFK5:SetValue( "FK5_SEQ"		, PadL("1",GetSx3Cache("E5_SEQ","X3_TAMANHO"),"0") )
		oSubFK5:SetValue( "FK5_LA"		, "S" )
		oSubFK5:SetValue( "FK5_NATURE"	, cNatureza )	
		oSubFK5:SetValue( "FK5_TXMOED"	, oModelMOE:GetValue("TASA", Max(SA6->A6_MOEDA,1)) )
		oSubFK5:SetValue( "FK5_ORIGEM"	, "FINA887" )
		oSubFK5:SetValue( "FK5_FILORI"	, cFilAnt )

		If lCorrMon .And. cMoeda <> "1"
			nTxCor:= Iif(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA, RecMoeda(SE1->E1_EMISSAO, SE1->E1_MOEDA))
			nValOrig:= xMoeda(oModelSEL:GetValue("EL_VALOR", nPosLin),Val(cMoeda),1,,,nTxCor)
			nValAtu:= xMoeda(oModelSEL:GetValue("EL_VALOR", nPosLin),Val(cMoeda),1,,,oModelMOE:GetValue("TASA", Val(cMoeda)),oModelMOE:GetValue("TASA", Max(SA6->A6_MOEDA,1)))

			cCamposE5 += ",{'E5_VLCORRE'," + CVALTOCHAR(nValAtu - nValOrig) + "}"
			If nValAtu - nValOrig != 0
				/*
				 * Adicionando valores acessórios (Correção Monetária)
				 */
				cIdFK2		:= FWUUIDV4()
				If !oSubFK6:IsEmpty()
					oSubFK6:AddLine()
				EndIf
				oSubFK6:SetValue( 'FK6_FILIAL'	, cFilFK6 )
				oSubFK6:SetValue( 'FK6_IDFK6'	, GetSxEnum('FK6','FK6_IDFK6') )
				oSubFK6:SetValue( 'FK6_TABORI'	, 'SE2' )
				oSubFK6:SetValue( 'FK6_TPDOC'	, 'CM' )
				oSubFK6:SetValue( 'FK6_VALCAL'	, nValAtu - nValOrig  )
				oSubFK6:SetValue( 'FK6_VALMOV'	, nValAtu - nValOrig  )
				oSubFK6:SetValue( 'FK6_RECPAG'	, "R" )
				oSubFK6:SetValue( 'FK6_IDORIG'	, cIdFK2 )
				oSubFK6:SetValue( 'FK6_GRVSE5'	, .F.)
			Endif
		EndIf
		
		cCamposE5 += " } "

		//Informo os campos que devem ser gravados somente na SE5
		oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 )
		
		//Se for movimento de cheque, vincula o cheque no processo 	
		If lCheque .and. oModelSEL:GetValue("EL_TIPODOC", nPosLin) == "CH" 
			aAreaSEF := GetArea()
			//Verifica se o  possui ID se não ele cria
			dbSelectArea( "SEF" )
			dbSetOrder( 1 )

			If msSeek( xFilial("SEF") + oModelSEL:GetValue("EL_BCOCHQ", nPosLin) + oModelSEL:GetValue("EL_AGECHQ", nPosLin) + oModelSEL:GetValue("EL_CTACHQ", nPosLin) + oModelSEL:GetValue("EL_NUMERO", nPosLin) )
				If Empty( SEF->EF_IDSEF )
					cChaveCH := FWUUIDV4()             
					Reclock( "SEF", .F. )
					SEF->EF_IDSEF	:= cChaveCH
					SEF->( msUnlock() )
				Else
					cChaveCH := SEF->EF_IDSEF
				Endif

				oFKAMovBco:AddLine()
				oFKAMovBco:SetValue( "FKA_IDORIG", cChaveCH )
				oFKAMovBco:SetValue( "FKA_TABORI", "SEF" )
			Endif

			RestArea( aAreaSEF )
		Endif
		
		
		If oModelMov:VldData()
			oModelMov:CommitData()
			
			If UsaSeqCor()
				AAdd(aDiario,{"SE5",SE5->(Recno()),oModelSEL:GetValue("EL_DIACTB", nPosLin),"E5_NODIA","E5_DIACTB"})
			EndIf
			
		
			nValToler	:= 0
			cBanco		:= oModelSEL:GetValue("EL_BANCO", nPosLin)
			cAgencia	:= oModelSEL:GetValue("EL_AGENCIA", nPosLin)
			cConta		:= oModelSEL:GetValue("EL_CONTA", nPosLin)
			cLoteFin	:= ""
			
			nValEstrang	:= SE1->E1_VALLIQ
			
			If oModelSEL:GetValue("EL_TPCRED", nPosLin) == "1"
				dBaixa := dDataBase
			Else
				dBaixa := oModelSEL:GetValue("EL_DTVCTO", nPosLin)
			Endif	
					
			cHist070:=STR0046+cRecibo+"-"+cSerie //"Valor recebido por Recibo "
			
			IF !EMPTY(cBanco).And. MovBcoBx(cMotBxSE5, .T.) .and. !lAdiantamento 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gravar Saldo Banc rio	        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AtuSalBco(cBanco,cAgencia,cConta,dBaixa,oModelSEL:GetValue("EL_VALOR",nPosLin),"+")
			EndIf
				
		Else
			lRet := .F.
			cLog := cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
			cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
			cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_MESSAGE])         	
			Help( ,,"MF887GSE5",,cLog, 1, 0 ) 
			lRet := .F.
			lMsErroAuto := .T.
		Endif
		oModelMov:DeActivate()		
	EndIf		
Endif

Return lRet

/*/{Protheus.doc} F887DEL
Metodo responsable por realizar la llamada de la rutina fina088 para realizar el proceso de borrado.

@type 		Method

@author 	raul.medina
@version	12.1.27 / Superior
@since		05/05/2021 
/*/
Method F887DEL() Class F887FIN
Local lRet			:= .T.
Local nX			:= 0
Local oModel 		:= FWModelActivate()
Local nOperation	:= oModel:GetOperation()
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local cRecibo		:= oModelFJT:GetValue("FJT_RECIBO")
Local cSerie		:= oModelFJT:GetValue("FJT_SERIE")
Local aCab			:= {}

	Pergunte("FIN088",.F.)
	SetMVValue("FIN088","MV_PAR01", 2)			//Filtra Canceladas - 1 = Si / 2 = No
	SetMVValue("FIN088","MV_PAR02", cRecibo)	//De Recibo 
	SetMVValue("FIN088","MV_PAR03", cRecibo)	//A Recibo
	SetMVValue("FIN088","MV_PAR06", 0)			//Moeda - 1
	SetMVValue("FIN088","MV_PAR07", cSerie)		//Serie de Recibo

	If oModelSEL:Length() > 0
		aAdd(aCab, {"EL_FILIAL" , oModelSEL:GetValue("EL_FILIAL")	, Nil})
		aAdd(aCab, {"EL_RECIBO" , oModelSEL:GetValue("EL_RECIBO")	, Nil})
		aAdd(aCab, {"EL_CLIORIG", oModelSEL:GetValue("EL_CLIORIG")	, Nil})
		aAdd(aCab, {"EL_LOJORIG", oModelSEL:GetValue("EL_LOJORIG")	, Nil})
		aAdd(aCab, {"EL_TIPO" 	, oModelSEL:GetValue("EL_TIPO")		, Nil})
		aAdd(aCab, {"EL_TIPODOC", oModelSEL:GetValue("EL_TIPODOC")	, Nil})
		aAdd(aCab, {"EL_PREFIXO", oModelSEL:GetValue("EL_PREFIXO")	, Nil})
		aAdd(aCab, {"EL_NUMERO" , oModelSEL:GetValue("EL_NUMERO")	, Nil})
		aAdd(aCab, {"EL_PARCELA", oModelSEL:GetValue("EL_PARCELA")	, Nil})
		aAdd(aCab, {"EL_VALOR" 	, oModelSEL:GetValue("EL_VALOR")	, Nil})
		aAdd(aCab, {"EL_MOEDA" 	, oModelSEL:GetValue("EL_MOEDA")	, Nil})
	
		MSExecAuto({|x,y,z| FINA088(x,y,z)},1,.T.,aCab)
		
		SEL->(DbSetOrder(8))
		If SEL->(DbSeek(xFilial("SEL")+cSerie+cRecibo))
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} F887CAN
Metodo responsable por realizar la llamada de la rutina fina088 para realizar el proceso de Cancelación.
	
	Esta función se ejecutara ModelPosVld hasta no pasar la funcionalidad de la fina088 al modelo
	Las validaciones se ejecuten en ModelPosVld y el grabado de datos de la FJT y SEL serán en el InTTS

@type 		Method

@author 	Jose.Gonzalez
@version	12.1.33 / Superior
@since		15/07/2022 
/*/
Method F887CAN() Class F887FIN
Local lRet			:= .F.
Local nX			:= 0
Local oModel 		:= FWModelActivate()

Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local cRecibo		:= oModelFJT:GetValue("FJT_RECIBO")
Local cSerie		:= oModelFJT:GetValue("FJT_SERIE")
Local aCab			:= {}
local jData		:= JsonObject():New()
local aResponse := {}
local cError := ""

IF cPaisLoc <> "ARG"
	jData['origin']	:= "FINA998"
	If SEL->(ColumnPos("EL_TIPAGRO")) >0 
		jData['motCanc'] := oModelSEL:GetValue("EL_TIPAGRO")
	EndIf	
	jData['mv_par01']	:= If( oModelFJT:GetValue("ASIENTO")  ==1,.T.,.F.) 
	jData['mv_par02']	:= If( oModelFJT:GetValue("AGRUPA")  == 1,.T.,.F.) 	
	Pergunte("FIN088",.F.)
	
	MV_PAR01 := 2
	MV_PAR02 := cRecibo
	MV_PAR03 := cRecibo
	MV_PAR06 := 1
	MV_PAR07 := cSerie

	If oModelSEL:Length() >  0
		aAdd(aCab, {"EL_FILIAL" , oModelSEL:GetValue("EL_FILIAL")	, Nil})
		aAdd(aCab, {"EL_RECIBO" , oModelSEL:GetValue("EL_RECIBO")	, Nil})
		aAdd(aCab, {"EL_CLIORIG", oModelSEL:GetValue("EL_CLIORIG")	, Nil})
		aAdd(aCab, {"EL_LOJORIG", oModelSEL:GetValue("EL_LOJORIG")	, Nil})
		aAdd(aCab, {"EL_TIPO" 	, oModelSEL:GetValue("EL_TIPO")		, Nil})
		aAdd(aCab, {"EL_TIPODOC", oModelSEL:GetValue("EL_TIPODOC")	, Nil})
		aAdd(aCab, {"EL_PREFIXO", oModelSEL:GetValue("EL_PREFIXO")	, Nil})
		aAdd(aCab, {"EL_NUMERO" , oModelSEL:GetValue("EL_NUMERO")	, Nil})
		aAdd(aCab, {"EL_PARCELA", oModelSEL:GetValue("EL_PARCELA")	, Nil})
		aAdd(aCab, {"EL_VALOR" 	, oModelSEL:GetValue("EL_VALOR")	, Nil})
		aAdd(aCab, {"EL_MOEDA" 	, oModelSEL:GetValue("EL_MOEDA")	, Nil})
			
		MSExecAuto({|v,w,x,y,z| FINA088(v,w,x,y,z)},3,.T.,aCab,@aResponse,jData)

		For nX := 1 To  LEN(aResponse)
			If aResponse[nX][1] = .T.
				lRet := .T.
			ElseIf aResponse[nX][1] = .F.
				cError += " "+aResponse[nX][3]+" "+ aResponse[nX][4]
				oModel:SetErrorMessage('FJT_MASTER', '' , 'FJT_MASTER' , '' ,cError , cError, cError)
				lRet := .F. 
			EndIf
		Next 
	EndIf
Else
	DbSelectArea('FJT')
	FJT->(DbSetorder(1)) //FJT_FILIAL+FJT_SERIE+FJT_RECIBO+FJT_VERSAO
	If FJT->(MSSeek( xFilial("FJT") +cSerie+cRecibo))
		oModel := FwLoadModel("FINA846")
		oModel:SetOperation( MODEL_OPERATION_DELETE )
		MV_PAR01 := oModelFJT:GetValue("ASIENTO") 
		MV_PAR02 := oModelFJT:GetValue("AGRUPA")
		MV_PAR03 := oModelFJT:GetValue("ONLINE")

		//-- Activación del modelo de datos
		oModel:Activate()
		SetFunName("FINA998")
		//-- Grabación de los datos
		lRet := (oModel:CommitData())

		oModel:DeActivate()
	Endif
	FJT->(DbCloseArea())
ENDIF

Return lRet

/*/{Protheus.doc} F887CkPG
Metodo responsable por realizar validaciones para Perú
@type 		Method

@param 		nOpc		,numeri		,opción
@param 		lValida 	,caracter	,indica si se realiza la validación, sólo se activa en la rutina F887FINPER
@param 		cBanco	 	,caracter	,banco a ser usado en las validaciones
@param 		nPagar	 	,caracter	,pagar

@author 	raul.medina
@version	12.1.27 / Superior
@since		20/05/2021 
/*/
Method F887CkPG(nOpc,lValida,cBanco,nPagar) Class F887FIN
Local lRet := .T.

Default nPagar 	:= 0

If lValida
	If nOpc == 0
		If cBanco $ (Left(SuperGetMV("MV_CXFIN"),GetSx3Cache("A6_COD","X3_TAMANHO"))+"/"+SuperGetMV("MV_CARTEIR")) .or. IsCaixaLoja(cBanco)
			If nPagar == 2
				lRet := .F.
			Endif
		Endif
	Elseif nOpc == 3
		If cBanco $ (Left(SuperGetMV("MV_CXFIN"),GetSx3Cache("A6_COD","X3_TAMANHO"))+"/"+SuperGetMV("MV_CARTEIR"))  .or. IsCaixaLoja(cBanco)
			lRet := .F.
		Endif
	Endif
Endif

Return (lRet)
