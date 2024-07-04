
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FINA998.CH"

/*/{Protheus.doc} FINA998
FWCallApp funcion para inicar TOTVS RECIBOS
@type function
@version  1
@author luis.aboytes
@since 18/5/2021
/*/
Function FINA998()
	FWCallApp( "FINA998" )
Return

/*/{Protheus.doc} JsToAdvpl
Envíe un mensaje JavaScript a ADVPL. Este mensaje será recibido por el bloque de código bJsToAdvpl del componente TWebChannel asociado con el componente TWebEngine que muestra la página / componente HTML.
@type function
@version  1
@author luis.aboytes
@since 18/5/2021
@param oWebChannel, Object, Objeto Web
@param cType, character, Nombre del metodo ADVPL a ejecutar
@param cContent, character, contenido a buscar dentro del metodo ADVPL
/*/
Function JsToAdvpl(oWebChannel,cType,cContent)
	Local jBody   	As Character
	Local cSerie  	As Character
	Local cRecibo	As Character
	Local nCont 	As Numeric
	Local aResponse	As Array
	Local jData		As Object
	Local cResponse	As Character
	Local jResponse As Object
	Local aTemp,aAux As Array
	Local cSuccess	As Character
	Local nX		As Numeric
	Local aResTmp	As Array
	Local nY		As Numeric
	Local cTemp		As Character
	Local aCab		As Array
	Local jAux 		AS Array
	Local aData		As Array
	Local aJson,aJsonAux As Array
	Local cDate 	As Character
	Local oModel
	Local aError := {}
	local cSerieS :=""
	local cReciboS :=""
	local cMotC :=""
	local aRec :={}
	Private aDocuments	As Array
	Private dDataLanc	As Date
	Private cCadastro 	As Character
	Private aRotina 	As Array
	Private aTotRdpe	As Array
	Private cSublote	As Character
	Private __lCusto	As Logical
	Private __lItem 	As Logical
	Private __lCLVL		As Logical
	

	//Mensajes en la consola del AppServer
	conout("JsToAdvpl cType: "  + cValToChar(cType))
	conout("JsToAdvpl cContent: "  + cValToChar(cContent))

	//Comparamos el la variable cType y obtenemos el valor de un metodo ADVPL que sera regresado a la aplicacion WEB
	If  UPPER(Alltrim(cType)) == "GENERATEXML" .OR. UPPER(Alltrim(cType)) == "SENDEMAIL"
		jBody  		:= JsonObject():New()
		jData		:= JsonObject():New()
		jBody:fromJson(cContent)
		aResTmp		:= {}
		aResponse	:= {}
		aTemp		:= {}

		For nCont :=1  to LEN(jBody["values"])
			cRecibo := jBody["values"][nCont]["receipt"]
			cSerie	:= jBody["values"][nCont]["serie"]

			jData['origin']		:= "FINA998"
			jData['imppdf'] 	:= IIF(VAZIO(jBody["imppdf"]),.F.,.T.) 
			jData['sendemail']  := IIF(VAZIO(jBody["sendemail"]),.F.,.T.) 
			jData['email']		:= jBody["email"]
			jData['emailcc']	:= jBody['emailcc']
			jData['serie']		:= cSerie
			jData['recibo']		:= cRecibo
			jData['cliente']	:= jBody["values"][nCont]["client"] 
			jData['filial']		:= jBody["values"][nCont]["branch"] 
			aResTmp				:= {}

			//Objeto exclusivo para la seccion de enviar en buscar recibos, dado que puede traer mas de un cliente con diferentes recibos
			If jBody['receiptsByClient'] !=  Nil
				aAux 		:= {}
				aJsonAux 	:= {}
				jData['imppdf'] := .F.
				jData['joindocuments']	:= .T.
				For nCont := 1 to LEN(jBody['receiptsByClient'])
					jAux 	:= JsonObject():New()
					aData 	:= {}
					aJson 	:= {}
					aDocuments		:= {}
					jData['latest']	:= .F.

					//Se obtienen todos los recibos de un cliente y se agregan a un objeto json
					For nX := 1 to LEN(jBody['receiptsByClient'][nCont]['receipts'])
						cRecibo	:= jBody['receiptsByClient'][nCont]['receipts'][nX]['receipt']
						cSerie 	:= jBody['receiptsByClient'][nCont]['receipts'][nX]['serie']

						IF nX == LEN(jBody['receiptsByClient'][nCont]['receipts'])
							jData['latest']	:= .T.
						ENDIF

						//Se unifica un json obteniendo un objeto de un solo cliente con sus respectivos recibos
						jData['email']		:=jBody['receiptsByClient'][nCont]['email']
						jData['client']		:=jBody['receiptsByClient'][nCont]['client']

						//Se manda llamar la FISA815 para el timbrado
						//Los parametros son cRecibo el cual es el numero de recibo, cSerie la serie del recibo, aResponse es donde se retornaran los mensajes de error o mensajes satisfactorios para posteriormente mandarlos en un Json al front-end, y jData donde se mandara informacion reelevante como por ejemplo el nombre de origin paara dejar de usar cPaisLoc
						If cPaisLoc == "MEX" .And. !jBody["compensation"]
							IF jData['imppdf'] == .T.
								//FISA815(cRecibo, cSerie,1,,@aResTmp,jData)
							ELSE
								FISA815(cRecibo, cSerie,1,,@aResTmp,jData)
							ENDIF
						Else
							FISA815A(cRecibo, cSerie,,@aResTmp,.T.,jData)
						EndIf
						AADD(aResponse, {cRecibo, aClone(aResTmp)})
						aResTmp := {}
					End
				End

			Else
				//Se manda llamar la FISA815 para el timbrado
				//Los parametros son cRecibo el cual es el numero de recibo, cSerie la serie del recibo, aResponse es donde se retornaran los mensajes de error o mensajes satisfactorios para posteriormente mandarlos en un Json al front-end, y jData donde se mandara informacion reelevante como por ejemplo el nombre de origin paara dejar de usar cPaisLoc
				jData['client']	:= JBody["client"]

				If cPaisLoc == "MEX" .And. !jBody["compensation"]
					//Metodo que verifica los titulos que contenga el recibo a timbrar sean validos para timbrar
					If validTitles(jData)
						if !(alltrim(jBody['params']['mv_par04']) == "") .or.  !(alltrim(jBody['params']['mv_par05']) == "") 
							If SuperGetMv("MV_SERREC",.F.,.F.) 
								aRec := separa(jBody['params']['mv_par04'],"-")
								cSerieS 	:=aRec[1]
								cReciboS 	:= aRec[2]
							Else 
								cSerieS 	:= PadR( "",GetSx3Cache("EL_SERIE","X3_TAMANHO"))
								cReciboS 	:=  jBody['params']['mv_par05']
							EndIf
							cMotC := F998ObtMot(cSerieS,cReciboS) 
						EndIf
						If !( alltrim(jBody["values"][nCont]["sersus"]) == "") .or.  !(alltrim(jBody["values"][nCont]["recsus"]) == "") 
							If SuperGetMv("MV_SERREC",.F.,.F.)
								cSerieS 	:= PadR(alltrim(jBody["values"][nCont]["sersus"]),GetSx3Cache("EL_SERSUS","X3_TAMANHO"))
								cReciboS 	:= PadR(alltrim(jBody["values"][nCont]["recsus"]) ,GetSx3Cache("EL_RECSUS","X3_TAMANHO"))
							Else 
								cSerieS 	:= PadR( "",GetSx3Cache("EL_SERIE","X3_TAMANHO"))
								cReciboS 	:= PadR(alltrim(jBody["values"][nCont]["recsus"]) ,GetSx3Cache("EL_RECSUS","X3_TAMANHO"))
							EndIf
							cMotC := F998ObtMot(cSerieS,cReciboS) 
						EndIf
						IF jData['imppdf'] == .T. 
							FISA815(cRecibo, cSerie,1,,@aResTmp,jData,cSerieS,cReciboS,cMotC)
						ELSE
							FISA815(cRecibo, cSerie,,,@aResTmp,jData,cSerieS,cReciboS,cMotC)
						ENDIF
					ELSE
						aResTmp := {{.F.,400,"Este recibo contiene titulos que no pueden ser timbrados"}}
					ENDIF
				Else
					FISA815A(cRecibo, cSerie,,@aResTmp,.T.,jData)
				EndIf
				AADD(aResponse, {cRecibo, aClone(aResTmp)})
			EndIf
		Next
		For nX := 1 To  LEN(aResponse)
			cRecibo 	:= aResponse[nX][1]
			For nY := 1 To Len(aResponse[nX][2])

				If aResponse[nx][2][nY][1] == .T.
					cSuccess:= "true"
				else
					cSuccess:= "false"
				Endif
				cTemp := '{"receipt":"'+cRecibo+'","success":'+cSuccess+',"message":"'+aResponse[nx][2][nY][3]+'"}'
				AADD(aTemp,cTemp)
			Next nY
		Next

		aResponse := {}

		cResponse := "["
		For nCont := 1 to LEN(aTemp)
			If  nCont < LEN(aTemp)
				cResponse += aTemp[nCont] +","
			else
				cResponse += aTemp[nCont]
			Endif
		Next
		cResponse += "]"

		conout("JsToAdvpl cContent: "  + cValToChar(cResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cResponse)//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "CANCEL"
		IF ExistBlock("F998BRANU")
			aRet := ExecBlock("F998BRANU",.F.,.F.,{jBody['serie'],jBody['receipt']})
			IF aRet[1] != .T.
				cTemp := '{"receipt":"'+jBody['receipt']+'", "success":false, "message":"'+aRet[2]+'"}'
				AADD(aTemp,cTemp)
				aResponse := {}
				cResponse := "[" + aTemp[1] + "]"
				conout("JsToAdvpl cContent: "  + cValToChar(cResponse)) //Se retorna la respuesta al front-end
				oWebChannel:AdvplToJS('response', cResponse)//Se imprime en consola
				RETURN
			ENDIF
		EndIf
		FIN998TL("CANCELRECEIPT",cContent,,@cResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(cResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(cResponse))//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "DELETE" 
		jResponse := JsonObject():New()	
		FIN998TL("DELETERECEIPT",cContent,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse))//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "SAVERECEIPT" 
		jResponse := JsonObject():New()

		FIN998TL("SAVERECEIPT",cContent,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse["response"]))//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "DATESYSTEM"
		cDate := '{"datesystem": "'+dtos(dDataBase)+'"}'
		conout("JsToAdvpl cContent: "  + cValToChar(cDate)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(cDate))//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "PAYMENTFORM" 
		jResponse := JsonObject():New()

		FIN998TL("PAYMENTFORM",,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse["response"]))//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "GETCONTENTINI" 
		jResponse := JsonObject():New()

		FIN998TL("GETCONTENTINI",,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse["response"]))//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "CHECKREADER" 
		jResponse := JsonObject():New()

		FIN998TL("CHECKREADER",,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse))//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "LOCKTITLE" 
		jResponse := JsonObject():New()

		FIN998TL(UPPER(Alltrim(cType)),cContent,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse))//Se imprime en consola
	EndIf
Return


/*/{Protheus.doc} validTitles
Metodo que verifica los titulos de cada recibo, si un recibo contiene titulos que son validos para timbrar traera un True de lo contrario un False
@type function
@version  1
@author luis.aboytes
@since 20/2/2022
@param jData, json, parametro que contiene datos del recibo
/*/
Function validTitles(jData)
	Local lTimbrar 		:= .T.
	Local nType			:= 0
	Local aTiposDoc 	:= ""
	Local cQueryFields	:= ""
	Local cQueryWhere	:= ""
	Local cQuery		:= ""
	Local cAlias		:= ""

	If ExistBLock('F998FLOTIT')
		cAlias := GetNextAlias()

		aTiposDoc 	:= StrTokArr(ExecBlock('F998FLOTIT',.F.,.F.), "/")
		cQueryFields := " EL_TIPO,EL_NUMERO "

		cQueryWhere := " EL_FILIAL ='"		+ xFilial("SEL",jData['filial'] )+"' "
		cQueryWhere += " AND EL_RECIBO ='"	+ jData['recibo'] 	+"' "
		cQueryWhere += " AND EL_CLIORIG ='"	+ jData['cliente']	+"' "
		cQueryWhere += " AND EL_SERIE ='"	+ jData['serie']	+"' "

		cQueryWhere += " AND D_E_L_E_T_ = ' ' "

		cQuery := "SELECT "+ cQueryFields +" FROM "+ RetSqlName("SEL") +" WHERE "+ cQueryWhere

		cQuery := ChangeQuery(cQuery)
		MPSysOpenQuery(cQuery, cAlias)

		WHILE (cAlias)->(!EOF())
			nType := AScanx(aTiposDoc,{|x| ALLTRIM(x) == ALLTRIM((cAlias)->EL_TIPO)})
			IF nType != 0
				lTimbrar := .F.
			ENDIF
			(cAlias)->(DbSkip())
		ENDDO
	EndIf
Return lTimbrar



/*/{Protheus.doc} F998ObtMot
Función que obtiene el motivo del recibo a sustituir.
@type function
@author José Gonzalez
@since 10/03/2022
@version 1.0
@param cSerSus, caracter, Serie el Recibo cancelado.
@param cRecSus, caracter, Folio de Recibo cancelado.
/*/
Function F998ObtMot(cSerSus,cRecSus)
	Local aSELArea := SEL->(GetArea())
	Local cFilSEL  := xFilial("SEL")
	Local cMotivo  := "01"
	
	Default cSerSus := ""
	Default cRecSus := ""

	DbSelectArea("SEL")
	SEL->(DbSetOrder(8)) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	If SEL->(DbSeek(cFilSEL + cSerSus + cRecSus))
		cMotivo := SEL->EL_TIPAGRO
	EndIf
	RestArea(aSELArea)
Return cMotivo

/*/{Protheus.doc} Bcotrigger
Función que obtiene la moneda del Banco 
@type function
@author José Gonzalez
@since 01/01/2022
@version 1.0
/*/                                                                             
Function Bcotrigger(cValor) 

local cresp := ""
local aCampos :={}
local cCod
local cAgen
local cNum
default cValor := ""

If !(cValor == "")
	aCampos := Separa(cValor,"-")
	cCod 	:= PadR(  aCampos[1] ,GetSx3Cache("A6_COD","X3_TAMANHO"))
	cAgen	:= PadR(  aCampos[2] ,GetSx3Cache("A6_AGENCIA","X3_TAMANHO"))
	cNum	:= PadR(  aCampos[3] ,GetSx3Cache("A6_NUMCON","X3_TAMANHO"))

	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	If  SA6->(MsSeek(xFilial("SA6")+cCod+cAgen+cNum )	)		
		cresp := alltrim(STR(SA6->A6_MOEDA))
	EndIf
EndIf
 
Return cresp
