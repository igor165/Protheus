#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887DIFCAM
Clase responsable por el evento de reglas de negocio de 
localización de retenciones de Argentina

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		14/05/2021
/*/
Class F887DIFCAM From FwModelEvent 

	DATA lDifCam As logical
	
	Method New() CONSTRUCTOR
	
	Method VldActivate()

	Method Destroy()
	
	Method AfterTTS()
	
	Method DIFCAM()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		14/05/2021 
/*/
Method New() Class F887DIFCAM
	
Return Nil	

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		14/05/2021 
/*/
Method VldActivate(oModel) Class F887DIFCAM
Local nOperation	:= oModel:GetOperation()
Local lRet			:= .T.

	self:lDifCam := (GetNewPar("MV_DIFCAMR","N") == "S")


Return lRet

/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		14/05/2021 
/*/
Method Destroy() Class F887DIFCAM

Return Nil

/*/{Protheus.doc} AfterTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacción
del modelo de datos.

@type 		Method

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	raul.medina	
@version	12.1.27 / Superior
@since		14/05/2021 
/*/
Method AfterTTS(oModel, cModelId) Class F887DIFCAM
Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		If self:lDifCam
			self:DIFCAM(oModel)
		EndIf
	EndIf

Return Nil


/*/{Protheus.doc} DIFCAM
Metodo responsable por ejecutar reglas de negocio para cheques 
para la localización de Argentina

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.

@author 	raul.medina
@version	12.1.27 / Superior
@since		14/05/2021 
/*/
Method DIFCAM(oModel) Class F887DIFCAM
Local nOperation	:= oModel:GetOperation()
Local oModelSE1 	:= oModel:GetModel('SE1_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local nX			:= 0
Local cNum			:= ""
Local cPrefixo 		:= ""
Local cParcela		:= ""
Local cMoeda		:= ""
Local lExterno		:= .T.
Local lExecCor		:= .T.
Local nPosIni		:= 0
Local aArea			:= {}
Local nMoedaCor		:= 0

//Variables sólo usadas en la rutina FINA074, no usar para otra cosa
Private nTxaAtual	:= 0
Private nMdaTit		:= 0


	DbSelectArea("SE1")

	For nX := 1 To oModelSE1:Length()
		cNum 		:= oModelSE1:GetValue("E1_NUM",nX)
		cPrefixo	:= oModelSE1:GetValue("E1_PREFIXO",nX)
		cParcela	:= oModelSE1:GetValue("E1_PARCELA",nX)
		cMoeda		:= oModelSE1:GetValue("E1_MOEDA",nX)
		
		SE1->(dbSetOrder(1))
		SE1->(dbSeek(xFilial("SE1")+cPrefixo+cNum+cParcela))
		
		If xFilial("SE1") == SE1->E1_FILIAL .And. cNum == SE1->E1_NUM .And. cPrefixo == SE1->E1_PREFIXO .And. SE1->(!EOF())
			lExterno 	:= .T.
			lExecCor 	:= .T.
			nPosIni		:= 1
			While lExecCor
				nMoedaCor 	:= Val(Subs(SuperGetMV("MV_MDCFIN"),nPosIni,2))
				aArea 		:= GetArea()
				If !Empty(nMoedaCor) 
					If !Empty(SuperGetMV("MV_MOEDA"+Alltrim(Str(nMoedaCor))))
						If SE1->E1_MOEDA <> nMoedaCor .and. oModelMOE:Length() >= nMoedaCor
							SetMVValue("FIN74A","MV_PAR01", 0)	//Tasa
							SetMVValue("FIN74A","MV_PAR07", 2)	//Genera para saldo 
							SetMVValue("FIN74A","MV_PAR08", 1)	//Genera para pago
							SetMVValue("FIN74A","MV_PAR10", nMoedaCor)	//
							
							cMoeda	:= SE1->E1_MOEDA
							
							nTxaAtual	:= Iif( oModelMOE:Length() >= SE1->E1_MOEDA, oModelMOE:GetValue('TASA', SE1->E1_MOEDA), oModelMOE:GetValue('TASA', nMoedaCor))
							nMdaTit		:= oModelMOE:GetValue('TASA', cMoeda)
							Pergunte("FIN74A",.F.) 
							FA074GDif(.F.,,,lExterno,,,)
							lExecCor	:= .F.
						EndIf
					EndIf
					nPosIni	:= nPosIni + 3
					RestArea(aArea)		
				Else
					lExecCor	:= .F.
				EndIf
			EndDo
		EndIf
	Next nX

Return Nil