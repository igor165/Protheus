#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TECAPI01.CH"
#INCLUDE "TBICONN.CH"

Static __oSt01 := Nil//TecBusNSR()
Static __oSt02 := Nil//TecProNum()
Static __oSt03 := Nil//TecBusDat()

/*/{Protheus.doc} TECAPI01
//Realiza a busca pelas marcações da API Clock In da Carol e grava as informações na tabela de TSA do Protheus.
@author Equipe TECA
@since 17/08/2022
@version undefined
@return return, return_description
/*/
Function TECAPI01()
Local aDisps		:= {} //Array de dispositivos da Carol
Local aDados    	:= {} //Array de Marcações da Carol
Local aRetDisps		:= {}
Local aSays		   	:= {}
Local aButtons	   	:= {}
Local cDtIni    	:= ""
Local cDtFim    	:= ""
Local cTempDisp 	:= ""
Local cPerg 		:= "TECAPI01"
Local nCoutDisp 	:= 0
Local nI		 	:= 0
Local nLoopFor	 	:= 0
Local nOpcA		 	:= 0
Local nPosDados 	:= 3
Local nTpIntegr		:= 1
Local lIntegCar		:= .F.
Local lProcIni  	:= .F.
Local lExistPerg 	:= TeExigPer(cPerg)
Local cLockName 	:= "TECAPI01"+DTOS(DATE())
Local oSay

Private aLog		:= {{}}
Private aLogIntegC	:= {}
Private aLogTecInt	:= {}
Private lApiToken	:= .F.
Private lGeraTokn	:= .F.
Private lTemT40		:= .F.
Private aParams		:= {}

If lExistPerg
	aAdd(aSays,OemToAnsi(STR0001)) //"Este programa tem como objetivo realizar a integração"
	aAdd(aSays,OemToAnsi(STR0002)) //"de marcações realizadas no Clock In."
	aAdd(asays,OemToAnsi(STR0003))//"Obs.: Verifique os parâmetros de integração antes de executar a rotina"
	
	aAdd(aButtons, {5,.T.,{|| Pergunte(cPerg,.T. )}})
	aAdd(aButtons, {1, .T. , {|o| nOpcA := 1, If(GpConfOk(), FechaBatch(), nOpcA := 0)}})
	aAdd(aButtons, {2, .T. , {|o| FechaBatch()}})
			
	FormBatch(STR0004, aSays, aButtons) //"Integração Carol"

	If nOpcA == 0
		Return
	EndIf
EndIf

lTemT40	:= AliasInDic("T40")

If lExistPerg
	Pergunte(cPerg,.F.)
	nTpIntegr := mv_par01 // 1-Padrao / 2-Por Periodo / 3-Por Data
	If nTpIntegr == 2
		cDtIni := dToS(FirstDate(FirstDate(Date())-1))
		cDtFim := dToS(LastDate(LastDate(Date())+1))
		cDtIni := Substr(cDtIni,1,4) + '-' + Substr(cDtIni,5,2) + '-' + Substr(cDtIni,7,2)
		cDtFim := Substr(cDtFim,1,4) + '-' + Substr(cDtFim,5,2) + '-' + Substr(cDtFim,7,2)
	ElseIf nTpIntegr == 3
		If Empty(mv_par02)
			mv_par02 := dDataBase
		EndIf
		If Empty(mv_par03)
			mv_par03 := dDataBase
		EndIf
		If mv_par03 < mv_par02
			cDtIni := dToS(mv_par03)
			cDtFim := dToS(mv_par02)
		Else
			cDtIni := dToS(mv_par02)
			cDtFim := dToS(mv_par03)
		EndIf
		cDtIni := Substr(cDtIni,1,4) + '-' + Substr(cDtIni,5,2) + '-' + Substr(cDtIni,7,2)
		cDtFim := Substr(cDtFim,1,4) + '-' + Substr(cDtFim,5,2) + '-' + Substr(cDtFim,7,2)
	EndIf
EndIf

aParams		:= TecBuspar()
lIntegCar	:= aParams[1]
lProcIni	:= aParams[14]

If !LockByName(cLockName,.F.,.F.,.T.)
	Help( ,, 'HELP',, STR0005, 1, 0) //"Esta rotina já está sendo utilizada em outro processo!"
	Return (.F.)
EndIf

aDisps := TecBudisp()

If aDisps[1] .and. Len(aDisps[nPosDados]) > 0
	For nCoutDisp := 1 To Len(aDisps[nPosDados])
		If lProcIni
			nLoopFor := Len(aDisps[nPosDados,nCoutDisp])
		Else
			nLoopFor := 1
		EndIf
		For nI := 1 To nLoopFor
			If lProcIni
				aRetDisps := {aDisps[nPosDados,nCoutDisp,nI]}
			Else
				aRetDisps := aDisps[nPosDados,nCoutDisp]
			EndIf
			aDados := TecMkbus(cTempDisp, aRetDisps, nTpIntegr, cDtIni, cDtFim)
			If aDados[1] .AND. Len (aDados[nPosDados]) > 0
				FwMsgRun(Nil,{|oSay| fProcessa(cTempDisp, aDados[nPosDados],oSay)}, Nil, STR0075) //"Incluindo as marcações na tabela"
			EndIf
		Next nI
	Next nCoutDisp
Else
	If !aDisps[1]
		If at("code",aDisps[2]) > 0		
			ConsoleJob(STR0006 + "  " + aDisps[2]) //"Não foi possível acessar a API Clockin da Carol. "
		Else
			If !Empty(aDisps[2])
				ConsoleJob(aDisps[2]) //Mensagem de erro da API.
			EndIf
		EndIf
	EndIf
	UnLockByName(cLockName,.F.,.F.,.T.)
	Return (.F.)
EndIf

ConsoleJob(STR0008+' '+STR0009) //" Processo Finalizado." + "Verifique as informações gravadas na tabela de marcações!"
UnLockByName(cLockName,.F.,.F.,.T.)

Return (.T.) 

/*/{Protheus.doc} fProcessa
Processa os dados recebidos gravando na tabela de referencia.
@author Equipe TECA
@since 17/08/2022
/*/
Static Function fProcessa(cDispo,aInfor,oSay)
Local nRegCount := 0
Local nTotCount := 0
Local nHoraMarc := 0
Local cDataMarc := ''
Local nProxireg := 0
Local nNumDirec := 3
Local nNumFeder := 2
Local cNumdoPis := ''
Local cNumdoNSR := ''
Local cTempHora := ''
Local cCodclien := ''
Local clatitude := ''
Local cLongitude:= ''
Local cGeofence := ''
Local lProcIni	:= .F.
Local lProcNew	:= Empty(cDispo)

cCodclien := aParams[4]
lProcIni  := aParams[14]

If aParams[15]
	aAdd(aLogIntegC,STR0010 + cValToChar(Len(aInfor)) + STR0012) //"Foram encontradas " " marcações"
	aAdd(aLogIntegC,STR0075) //"Incluindo as marcações na tabela"
	aAdd(aLogTecInt,STR0010 + cValToChar(Len(aInfor)) + STR0012) //"Foram encontradas " " marcações"
	aAdd(aLogTecInt,STR0075) //"Incluindo as marcações na tabela"
EndIf

nTotCount := Len(aInfor)

For nRegCount := 1 To nTotCount
	
	oSay:SetText("Gravando Registro " + cValToChar(nRegCount) + " / " + cValToChar(nTotCount))
	ProcessMessage() // Força atualização no smartclient

	nProxireg := 0
	cTempHora := ''
	nHoraMarc := 0
	cNumdoPis := ''
	cNumdoNSR := ''
	cDataMarc := ''	
	nNumDirec := 0
	nNumFeder := 0
	clatitude := ''
	cLongitude:= ''
	cGeofence := ''
	If lProcNew
		cDispo := aInfor[nRegCount][9]
	EndIf

	If aInfor[nRegCount][8] <> Nil
		cTempHora := SubStr(aInfor[nRegCount][8],At("T",aInfor[nRegCount][8])+1,5)
		nHoraMarc := (( Val(SubStr(cTempHora,4,2))/60) + (Val(SubStr(cTempHora,1,2)))) * 3600		
		cDataMarc := aInfor[nRegCount][8]
	EndIf

	If aInfor[nRegCount][1] <> Nil
		cNumdoPis := aInfor[nRegCount][1] 
	EndIf

	If aInfor[nRegCount][1] <> Nil
		cNumdoNSR := cValToChar(aInfor[nRegCount][2]) 
	EndIf

	If Len(aInfor[nRegCount]) == 12
		cLongitude := If(!Empty(aInfor[nRegCount][10]), cValToChar(aInfor[nRegCount][10]), "")
		clatitude := If(!Empty(aInfor[nRegCount][11]), cValToChar(aInfor[nRegCount][11]), "")
		cGeofence := cValToChar(aInfor[nRegCount][12])
	EndIf
	
	nProxireg := TecProNum()
	If T40->( Reclock("T40", .T.) )
		T40->T40_FILIAL := xFilial("T40",cFilAnt)
		T40->T40_VALCON	:= nProxireg
		T40->T40_CODREL	:= cDispo
		T40->T40_LOGIP	:= "0"
		T40->T40_CODNSR	:= Val(cNumdoNSR)
		T40->T40_CODPIS	:= cNumdoPis
		T40->T40_DATMAR	:= sToD( StrTran( SubStr(cDataMarc, 1, 10), "-" ) )
		T40->T40_NUMMAR	:= nHoraMarc
		T40->T40_CODREP	:= "00001"
		T40->T40_CODUNI	:= cCodclien
		T40->T40_LATITU	:= clatitude
		T40->T40_LONGIT	:= cLongitude
		T40->T40_GEOFEN	:= cGeofence
		T40->( MsUnlock() )
	EndIf

Next nRegCount

If aParams[15]
	aAdd(aLogIntegC,STR0017) //"Finalizada a integração com a Carol"
	aAdd(aLogIntegC,dToC(Date())+" "+Time())
	fGeraLog(@aLogIntegC,STR0004) //"Integração Carol"
	aAdd(aLogTecInt,STR0017) //"Finalizada a integração com a Carol"
	aAdd(aLogTecInt,dToC(Date())+" "+Time())
	fGeraLog(@aLogTecInt,STR0018) //"Log Técnico Integração Carol"
EndIf
	
Return (.T.)

/*/{Protheus.doc} TecMkbus
Busca a listagem de marcações de um determinado dispositivo.
@author Equipe TECA
@since 17/08/2022
/*/
Function TecMkbus(cAccesCod, aRetDisp, nTpIntegr, cDtIni, cDtFim)
Local cSiteW    := '' 
Local aAccess	:= {} //AUTENTICAÇÃO DE USUÁRIO
Local aHeader	:= {} //ARRAY CONTENDO O AUTHORIZATION
Local oClient 	
Local cPageSize	:= "&pageSize=5000"
Local cURL		:= '' 
Local cURLQry	:= '/api/v3/queries/filter' 
Local cAsort	:= "?indexType=MASTER&sortBy=mdmGoldenFieldAndValues.nsrcode,mdmGoldenFieldAndValues.mdmeventdate&sortOrder=ASC&scrollable=false" 
Local cAsortNew	:= "?indexType=MASTER&sortBy=mdmGoldenFieldAndValues.devicecode.raw,mdmGoldenFieldAndValues.nsrcode,mdmGoldenFieldAndValues.mdmeventdate&sortOrder=ASC" 
Local cBody		:= ''
Local cFields	:= '&fields=mdmGoldenFieldAndValues.piscode,mdmGoldenFieldAndValues.nsrcode,mdmGoldenFieldAndValues.mdmeventdate,mdmGoldenFieldAndValues.eventdatestr,mdmGoldenFieldAndValues.mdmpersonid,mdmGoldenFieldAndValues.mdmname,mdmGoldenFieldAndValues.devicedescription,mdmGoldenFieldAndValues.mdmname,mdmGoldenFieldAndValues.devicecode,mdmGoldenFieldAndValues.coordinates,mdmGoldenFieldAndValues.isuserinsidegeofenceenum'
Local cFieldsQry:= '?fields=mdmGoldenFieldAndValues.piscode,mdmGoldenFieldAndValues.nsrcode,mdmGoldenFieldAndValues.mdmeventdate,mdmGoldenFieldAndValues.eventdatestr,mdmGoldenFieldAndValues.mdmpersonid,mdmGoldenFieldAndValues.mdmname,mdmGoldenFieldAndValues.devicedescription,mdmGoldenFieldAndValues.mdmname,mdmGoldenFieldAndValues.devicecode,mdmGoldenFieldAndValues.coordinates,mdmGoldenFieldAndValues.isuserinsidegeofenceenum'
Local cOffset	:= '&offset=0'
Local cRet		:= ''
Local cRetCarol	:= ''
Local cScroll	:= "&scrollable=true"
Local cScrollID	:= ""
Local aMarcac	:= {} //ARRAY CONTENDO TODAS AS MARCAÇÕES DE UM DISPOSITIVO
Local cAuthlg	:= '' //CHECAGEM DE SUCESSÃO NA CONEXÃO 
Local cDataBase	:= dToC(dDataBase)
Local oErro     := JsonObject():New()
Local oJson     := JsonObject():New()
Local lProcIni	:= .F.
Local lRet 		:= .F.
Local lProcNew	:= .F.
Local lRepost	:= .F.
Local lRepostF	:= .T.
Local nContDisp	:= 0
Local nUltNSR	:= 0
Local nI		:= 0

DEFAULT cAccesCod 	:= ""
DEFAULT aRetDisp 	:= {}
DEFAULT nTpIntegr 	:= 1
DEFAULT cDtIni		:= Substr(cDataBase,7,4) + '-' + Substr(cDataBase,4,2) + '-' + Substr(cDataBase,1,2)
DEFAULT cDtFim		:= Substr(cDataBase,7,4) + '-' + Substr(cDataBase,4,2) + '-' + Substr(cDataBase,1,2)

cSiteW 		:= aParams[2]
cURL   		:= aParams[9] 
lProcIni	:= aParams[14]

oClient := FwRest():New(cSiteW)

AAdd( aHeader, "Accept: application/json" )
AAdd( aHeader, "content-type: application/json" ) 
AAdd( aHeader, "charset: UTF-8" )  

aAccess	:= TecCoCarol()
	
cAuthlg	:= IIF(Len(aAccess) > 2 .And. aAccess[2] != NIL ,aAccess[2],"") 

If !Empty(cAuthlg) .Or. lApiToken
	If !lApiToken
		aHeader[1] := "Authorization:" +cAuthlg
	Else
		AAdd( aHeader, "X-Auth-Key: " + aParams[12] )
		AAdd( aHeader, "X-Auth-ConnectorId: " + aParams[4] )
	EndIf
	
	If aParams[15]
		aAdd(aLogIntegC,"")
		aAdd(aLogIntegC,STR0019) //"Solicitando as marcações para os dispositivos encontrados"
		aAdd(aLogIntegC,dToC(Date())+" "+Time())
		aAdd(aLogTecInt,"")
		aAdd(aLogTecInt,STR0019) //"Solicitando as marcações para os dispositivos encontrados"
		aAdd(aLogTecInt,dToC(Date())+" "+Time())
	EndIf
	
	If !Empty(aRetDisp)
		cBody := ""
		cBody += '{'
		cBody +=	'"minimumShouldMatch": 1,'
		cBody +=	'"resolveRelationships": false,'
		cBody +=	'"mustList": ['
		cBody +=		'{'
		cBody +=			'"mdmFilterType": "TYPE_FILTER",'
		cBody +=			'"mdmValue": "clockinrecordsGolden"'
		cBody +=		'},'
		cBody +=		'{'
		cBody +=			'"mdmFilterType": "TERM_FILTER",'
		cBody +=			'"mdmKey": "mdmMergePending",'
		cBody +=			'"mdmValue": false'
		cBody +=		'}'
		cBody +=	'],'
		cBody +=	'"mustNotList": ['
		cBody +=		'{'
		cBody +=			'"mdmFilterType": "TYPE_FILTER",'
		cBody +=			'"mdmKey": "mdmGoldenFieldAndValues.nsrcode",'
		cBody +=			'"mdmValue": "0"'
		cBody +=		'}'
		cBody +=	'],'
		cBody +=	'"shouldList": ['
		For nContDisp := 1 To Len(aRetDisp)
			cBody +=		'{'
			cBody +=			'"mdmFilterType": "BOOL_FILTER",'
			cBody +=			'"mdmValue": '
			cBody +=				'{'
			cBody +=					'"mustList": ['
			If (nTpIntegr == 2 .Or. nTpIntegr == 3) .And. !lProcIni
				TecBusDat(aRetDisp[nContDisp],@cDtIni)
				cBody +=							'{'
				cBody +=								'"mdmFilterType": "TERM_FILTER",'
				cBody +=								'"mdmKey": "mdmGoldenFieldAndValues.devicecode.raw",'
				cBody +=								'"mdmValue": "' + aRetDisp[nContDisp]  + '"'
				cBody +=							'},'
				cBody +=							'{'
				cBody +=								'"mdmFilterType": "RANGE_FILTER",'
				cBody +=								'"mdmKey": "mdmGoldenFieldAndValues.nsrcode",'
				cBody +=								'"mdmValue": ['
				cBody +=										'"1"'
				cBody +=								']'
				cBody +=							'},'
				cBody +=							'{'
				cBody +=								'"mdmFilterType": "RANGE_FILTER",'
				cBody +=								'"mdmKey": "mdmGoldenFieldAndValues.mdmeventdate",'
				cBody +=								'"mdmRangeValues": ['
				cBody +=									'"' + cDtIni + '",'
				cBody +=									'"' + cDtFim + '",'
				cBody +=								'],'
				cBody +=								'"rangeStartOperator" : "GREATER_THAN_OR_EQUAL_TO",'
				cBody +=								'"rangeEndOperator" : "LESS_THAN_OR_EQUAL_TO"'
				cBody +=							'}'
				cBody +=							'{'
				cBody +=								'"mdmFilterType": "TERM_FILTER",'
				cBody +=								'"mdmKey": "mdmGoldenFieldAndValues.devicecode.raw",'
				cBody +=								'"mdmValue": "' + aRetDisp[nContDisp]  + '"'
				cBody +=							'}'
			Else
				cBody +=							'{'
				cBody +=								'"mdmFilterType": "TERM_FILTER",'
				cBody +=								'"mdmKey": "mdmGoldenFieldAndValues.devicecode.raw",'
				cBody +=								'"mdmValue": "' + aRetDisp[nContDisp]  + '"'
				cBody +=							'},'
				cBody +=							'{'
				cBody +=								'"mdmFilterType": "RANGE_FILTER",'
				cBody +=								'"mdmKey": "mdmGoldenFieldAndValues.nsrcode",'
				cBody +=								'"mdmValue": ['
				cBody +=										TecBusNSR(aRetDisp[nContDisp], lProcIni)
				cBody +=								']'
				cBody +=							'}'
			EndIf
			cBody +=					']'
			cBody +=				'}'
			cBody +=	'}' + Iif(nContDisp < Len(aRetDisp),",","")
		Next nContDisp
		cBody +=	']'
		cBody +='}'
		lProcNew := .T.
	EndIf
	
	oClient:SetPostParams(cBody)
	
	If !lProcNew
		oClient:SetPath(cURL + cAsort + cPageSize + cFields)
		If aParams[15]
			aAdd(aLogIntegC,STR0020 + aParams[2]) //"URL Base: "
			aAdd(aLogIntegC,STR0021 + cURL) //"URL Requisição: "
			aAdd(aLogTecInt,STR0022 + aParams[2]) //" - URL: "
			aAdd(aLogTecInt,STR0023 + cURL) //" - Patch: "
			aAdd(aLogTecInt,STR0024 + cAsort + cPageSize + cFields) //" - Parâmetros: "
			For nI := 1 To Len(aHeader)
				aAdd(aLogTecInt,STR0025 + aHeader[nI]) //" - Header"
			Next
			aAdd(aLogTecInt,STR0026 + cBody) //" - Body: "
		EndIf
	Else
		If lProcIni
			cPageSize := "&pageSize=-1"
			oClient:SetPath(cURLQry + cAsortNew + cPageSize + cFields + cScroll)
		Else
			oClient:SetPath(cURLQry + cAsortNew + cPageSize + cFields + cOffset + cScroll)
		EndIf
		
		If aParams[15]
			aAdd(aLogIntegC,STR0020 + aParams[2]) //"URL Base: "
			aAdd(aLogIntegC,STR0021 + cURLQry) //"URL Requisição: "
			aAdd(aLogTecInt,STR0022 + aParams[2]) //" - URL: "
			aAdd(aLogTecInt,STR0023 + cURLQry) //" - Patch: "
			
			If lProcIni
				aAdd(aLogTecInt,STR0024 + cAsortNew + cPageSize + cFields + cScroll) //" - Parâmetros: "
			Else
				aAdd(aLogTecInt,STR0024 + cAsortNew + cPageSize + cFields + cOffset + cScroll) //" - Parâmetros: "
			EndIf
			
			For nI := 1 To Len(aHeader)
				aAdd(aLogTecInt,STR0025 + aHeader[nI]) // " - Header: "
			Next
			aAdd(aLogTecInt,STR0026 + cBody) //" - Body: "
		EndIf
	EndIf
	
	If oClient:Post(aHeader) .And. at("totalHits",oClient:GetResult()) > 0
		lRet := .T.
		cRet := oClient:GetResult()
		oJson:fromJson(cRet)
		cScrollID	:= oJson["scrollId"]
		If oJson["count"] > 0
			TeAddMarc(oJson, @aMarcac, @nUltNSR, .T.)
		EndIf
		If oJson["count"] < oJson["totalHits"] 
			lRepost := .T.
			While lRepost
				If lRepostF
					oClient:SetPath(cURLQry + "/" + cScrollID + cFieldsQry)
					lRepostF := .F.
				EndIf
				If lRepost := (oClient:Post(aHeader) .And. at("totalHits",oClient:GetResult()) > 0)
					cRet := oClient:GetResult()
					oJson:fromJson(cRet)
					If lRepost := (oJson["count"] > 0)
						TeAddMarc( oJson, @aMarcac, @nUltNSR )
					EndIf
				EndIf
			End
		EndIf
		If Empty(aMarcac) .And. aParams[15]
			aAdd(aLogIntegC,STR0027) //"Nenhuma marcação encontrada"
			aAdd(aLogIntegC,STR0017) //"Finalizada a integração com a Carol"
			aAdd(aLogIntegC,dToC(Date())+" "+Time())
			aAdd(aLogTecInt,STR0028) //"Retorno da API:"
			aAdd(aLogTecInt,cRet)
			aAdd(aLogTecInt,STR0029) //"Nenhuma marcação nova encontrada"
			aAdd(aLogTecInt,STR0017) //"Finalizada a integração com a Carol"
			aAdd(aLogTecInt,dToC(Date())+" "+Time())
			fGeraLog(@aLogIntegC,STR0004) //"Integração Carol"
			fGeraLog(@aLogTecInt,STR0018) //"Log Técnico Integração Carol"
		EndIf
	Else	
		lRet 		:= .F.
		cRetCarol	:= oClient:GetResult()
		cRet 		:= "code:" + cRetCarol
		aMarcac 	:= {}
		oErro:fromJSON( cRetCarol )
		oErro:toJSON( cRetCarol )
		
		If Empty(aMarcac) .And. aParams[15]
			aAdd(aLogIntegC,STR0030) //"Erro na integração"
			aAdd(aLogIntegC,STR0031) //"Verifique se o path da API clockinrecordsList está informado corretamente no parâmetro MV_APICLO8."
			aAdd(aLogIntegC,STR0017) //"Finalizada a integração com a Carol"
			aAdd(aLogIntegC,dToC(Date())+" "+Time())
			aAdd(aLogTecInt,STR0030) //"Erro na integração"
			aAdd(aLogTecInt,STR0031) //"Verifique se o path da API clockinrecordsList está informado corretamente no parâmetro MV_APICLO8."
			aAdd(aLogTecInt,STR0028) //"Retorno da API:"
			aAdd(aLogTecInt,cRetCarol)
			aAdd(aLogTecInt,STR0017) //"Finalizada a integração com a Carol"
			aAdd(aLogTecInt,dToC(Date())+" "+Time())
			fGeraLog(@aLogIntegC,STR0004) //"Integração Carol"
			fGeraLog(@aLogTecInt,STR0004) //"Integração Carol"
		EndIf
		
		aAdd( aLog[1], STR0031 )//"Verifique se o path da API clockinrecordsList está informado corretamente no parâmetro MV_APICLO8."
		aAdd( aLog[1], "")
		aAdd( aLog[1], "")
		aAdd( aLog[1], STR0034 )//"Configuração dos parâmetros: "
		aAdd( aLog[1], "  MV_APICLO1: " + aParams[2] )
		aAdd( aLog[1], "  MV_APICLO2: " + aParams[3] )
		aAdd( aLog[1], "  MV_APICLO3: " + aParams[4] )
		aAdd( aLog[1], "  MV_APICLO4: " + aParams[5] )
		aAdd( aLog[1], "  MV_APICLO5: " + aParams[6] )
		aAdd( aLog[1], "  MV_APICLO6: " + aParams[7] )
		aAdd( aLog[1], "  MV_APICLO7: " + aParams[8] )
		aAdd( aLog[1], "  MV_APICLO8: " + aParams[9] )
		aAdd( aLog[1], "  MV_APICLO9: " + aParams[10] )
		
		If aParams[13]
			aAdd( aLog[1], "  MV_APICLOA: " + aParams[12] )
		EndIf
		aAdd( aLog[1], "  MV_APICLOB: " + cValToChar(aParams[14]) )
		
		aAdd( aLog[1], "")
		aAdd( aLog[1], STR0035)//"Erro completo retornado pela API da Carol: "
		FiltraLog( aLog[1], cRetCarol)
	EndIf
EndIf 

Return ( {lRet,cRet,aMarcac} )

/*/{Protheus.doc} TecBudisp
Função que retorna a lista de dispositivos.
@author Equipe TECA
@since 17/08/2022
@version undefined
/*/
Function TecBudisp()
Local cAuthlg	:= ""																//TOKEN DE ACESSO 
Local cPageSize	:= "&pageSize="+aParams[16]											//PARAMETRIZAÇÃO PADRÃO DA API DEVICELIST(QUANTIDADE DE REGISTROS QUE DEVERÃO RETORNAR)
Local cAsort	:= "&sortOrder=ASC"  												//PARAMETRIZAÇÃO PADRÃO DA API DEVICELIST(ORDENAÇÃO DOS REGISTROS)
Local cIndexType:= "?indexType=MASTER" 												//PARAMETRIZAÇÃO PADRÃO DA API DEVICELIST(TIPO DE INDICE)
Local cFields	:= "&fields=mdmGoldenFieldAndValues.devicecode"  					//PARAMETRIZAÇÃO PADRÃO DA API DEVICELIST(CAMPOS)
Local cFieldsQry:= "?fields=mdmGoldenFieldAndValues.devicecode"  					//PARAMETRIZAÇÃO PADRÃO DA API DEVICELIST(CAMPOS)
Local cScroll	:= "&scrollable=true"  												//PARAMETRIZAÇÃO PADRÃO DA API DEVICELIST(Scrollable ID)
Local cURL		:= "" 																//URL DE ACESSO A CAROL
Local cURLQry	:= "/api/v3/queries/filter/" 										//URL DE ACESSO A CAROL
Local cBody		:= "" 																//CORPO DA REQUISIÇÃO CASO NECESSÁRIO, NESTA DEVICELIST NÃO POSSUI.
Local cRet		:= "" 																//ARMAZENA O RETORNO EM TEXTO DA API COM A LISTA DE DISPOSITIVOS
Local cScrollID	:= ""
Local cRetCarol	:= "" 																//ARMAZENA O RETORNO EM TEXTO DA API COM A LISTA DE DISPOSITIVOS
Local lRepost	:= .F.
Local lRepostF	:= .T.
Local lSucess	:= .T.
Local nContIds	:= 0 																//VARIAVEL DE CONTROLE PARA USO EM ESTRUTURA DE REPETIÇÃO
Local nI		:= 0

Local aAccess	:= TecCoCarol()														//AUTENTICAÇÃO DE USUÁRIO
Local aHeader	:= {} 																//ARRAY CONTENDO O AUTHORIZATION
Local aDisp		:= {} 																//ARRAY CONTENDO OS IDS DOS DISPOSITIVOS

Local oJson     := JsonObject():New()												//JSON QUE RECEBERÁ O RETORNO DA API
Local oErro     := JsonObject():New()												//JSON QUE RECEBERÁ O RETORNO DA API
Local oClient 	:= nil 																//OBJETO REST QUE SERÁ USADO NA REQUISIÇÃO

 	cAuthlg	:= IIF(Len(aAccess) > 2 .And. aAccess[2] != NIL ,aAccess[2],"") 		//CHECAGEM DE SUCESSO NA CONEXÃO E RETORNO DE TOKEN

	If !Empty(cAuthlg) .Or. lApiToken
		oClient 	:= FwRest():New(aParams[2])
		cURL		:= aParams[8] 
		
		If aParams[15]
			aAdd(aLogIntegC,"")
			aAdd(aLogIntegC,STR0036) //"Iniciando a integração com a Carol"
			aAdd(aLogIntegC,dToC(Date())+" "+Time())
			aAdd(aLogIntegC,STR0037) //"Buscando os dispositivos"
			aAdd(aLogIntegC,STR0020 + aParams[2]) //"URL Base: "
			aAdd(aLogIntegC,STR0021 + cURL) //"URL Requisição: "
			aAdd(aLogTecInt,"")
			aAdd(aLogTecInt,STR0036) //"Iniciando a integração com a Carol"
			aAdd(aLogTecInt,dToC(Date())+" "+Time())
			aAdd(aLogTecInt,STR0037) //"Buscando os dispositivos"
			aAdd(aLogTecInt,STR0022 + aParams[2]) //" - URL: "
			aAdd(aLogTecInt,STR0023 + cURL) //" - Path: "
			aAdd(aLogTecInt,STR0024 + cIndexType + cPageSize + cAsort + cFields + cScroll) //" - Parâmetros: "
		EndIf

		oClient:SetPath(cURL + cIndexType + cPageSize + cAsort + cFields + cScroll)
		
		If !lApiToken
			aHeader:= { "Authorization: Bearer " + cAuthlg,;
					"Content-Type: application/json; charset=UTF-8";
					}
		Else
			aHeader:= { "X-Auth-Key: " + aParams[12],;
					"X-Auth-ConnectorId: " + aParams[4],;
					"Content-Type: application/json; charset=UTF-8";
					}			
			If aParams[15]
				For nI := 1 To Len(aHeader)
					aAdd(aLogTecInt,STR0025 + aHeader[nI]) //" - Header: "
				Next
			EndIf
		EndIf

		oClient:SetPostParams(cBody)

		If oClient:Post(aHeader) .And. at("hits",oClient:GetResult()) > 0
			cRet := oClient:GetResult()
			oJson:fromJson(cRet)
			cScrollID	:= oJson["scrollId"]

			If oJson["count"] > 0
				aAdd(aDisp, {})
				If aParams[15]
					aAdd(aLogIntegC,STR0073 + cValToChar(oJson["totalHits"])) //"Dispositivos encontrados: "
					aAdd(aLogTecInt,STR0073 + cValToChar(oJson["totalHits"])) //"Dispositivos encontrados: "
					aAdd(aLogTecInt,STR0063) //"Retorno da API:"
					aAdd(aLogTecInt,cRet)
				EndIf
				For nContIds:= 1 to Len(oJson["hits"])
					aAdd(aDisp[Len(aDisp)], oJson["hits"][nContIds]["mdmGoldenFieldAndValues"]["devicecode"])
				Next
			EndIf

			If oJson["count"] < oJson["totalHits"]
				lRepost := .T.
				While lRepost
					If lRepostF
						oClient:SetPath(cURLQry + cScrollID + cFieldsQry)
						lRepostF := .F.
					EndIf
					If lRepost := (oClient:Post(aHeader) .And. at("hits",oClient:GetResult()) > 0)
						cRet := oClient:GetResult()
						oJson:fromJson(cRet)
						If lRepost := (oJson["count"] > 0)
							aAdd(aDisp, {})
							For nContIds:= 1 to Len(oJson["hits"])
								aAdd(aDisp[Len(aDisp)], oJson["hits"][nContIds]["mdmGoldenFieldAndValues"]["devicecode"])
							Next
						EndIf
					EndIf
				EndDo
			EndIf

			lSucess:= .T.
			
			If aParams[15]
				If Len(aDisp) == 0 .Or. Len(aDisp[Len(aDisp)]) == 0
					aAdd(aLogIntegC,STR0038) //"Nenhum dispositivo encontrado"
					aAdd(aLogIntegC,STR0017) //"Finalizada a integração com a Carol"
					aAdd(aLogIntegC,dToC(Date())+" "+Time())
					aAdd(aLogTecInt,STR0038) //"Nenhum dispositivo encontrado"
					aAdd(aLogTecInt,STR0017) //"Finalizada a integração com a Carol"
					aAdd(aLogTecInt,dToC(Date())+" "+Time())
				EndIf
			EndIf
			
		Else
			cRet:= oClient:GetResult()
			lRet 		:= .F.
			cRetCarol	:= oClient:GetResult()
			cRet 		:= "code:" + cRetCarol
			oErro:fromJSON( cRetCarol )
			oErro:toJSON( cRetCarol )

			aAdd( aLog[1], STR0009 )//"Verifique o parametro MV_APICLO7 pois ele é responsável pelo cadastro do path da api DeviceList  para a integração de Clockin da Carol."
			aAdd( aLog[1], "")

			If aParams[15]
				aAdd(aLogIntegC,STR0039) //"Verifique o parametro MV_APICLO7 pois ele é responsável pelo cadastro do path da api DeviceList  para a integração de Clockin da Carol."
				aAdd(aLogIntegC,STR0017) //"Finalizada a integração com a Carol"
				aAdd(aLogIntegC,dToC(Date())+" "+Time())
				aAdd(aLogTecInt,STR0039) //"Verifique o parametro MV_APICLO7 pois ele é responsável pelo cadastro do path da api DeviceList  para a integração de Clockin da Carol."
				aAdd(aLogTecInt,STR0028) //"Retorno da API:"
				aAdd(aLogTecInt,cRetCarol) 
				aAdd(aLogTecInt,STR0017) //"Finalizada a integração com a Carol"
				aAdd(aLogTecInt,dToC(Date())+" "+Time())
				fGeraLog(@aLogIntegC,STR0004) //"Integração Carol"
				fGeraLog(@aLogTecInt,STR0018) //"Log Técnico Integração Carol"
			EndIf

			If !Empty( oErro:getJSONText( "errorCode" ) ) .And. oErro:getJSONText( "errorCode" ) != "null"
				aAdd( aLog[1], STR0032 + oErro:getJSONText( "errorCode" ) )//"Código do erro retornado pela API: "
			EndIf
			If !Empty( oErro:getJSONText( "errorMessage" ) ) .And. oErro:getJSONText( "errorMessage" ) != "null"
				aAdd( aLog[1], STR0033 + oErro:getJSONText( "errorMessage" ) )//"Mensagem de erro retornado pela API: "
			EndIf
			aAdd( aLog[1], "")
			aAdd( aLog[1], STR0034 )//"Configuração dos parâmetros: "
			aAdd( aLog[1], "  MV_APICLO1: " + aParams[2] )
			aAdd( aLog[1], "  MV_APICLO2: " + aParams[3] )
			aAdd( aLog[1], "  MV_APICLO3: " + aParams[4] )
			aAdd( aLog[1], "  MV_APICLO4: " + aParams[5] )
			aAdd( aLog[1], "  MV_APICLO5: " + aParams[6] )
			aAdd( aLog[1], "  MV_APICLO6: " + aParams[7] )
			aAdd( aLog[1], "  MV_APICLO7: " + aParams[8] )
			aAdd( aLog[1], "  MV_APICLO8: " + aParams[9] )
			aAdd( aLog[1], "  MV_APICLO9: " + aParams[10] )

			If aParams[13]
				aAdd( aLog[1], "  MV_APICLOA: " + aParams[12] )
			EndIf
			aAdd( aLog[1], "  MV_APICLOB: " + cValToChar(aParams[14]) )

			aAdd( aLog[1], "")
			aAdd( aLog[1], STR0035)//"Erro completo retornado pela API da Carol: "
			FiltraLog( aLog[1], cRetCarol)
			lSucess:= .F.
		EndIf

	Else
		lSucess:= .F.
		cRet:= aAccess[5]
	EndIf 
	
Return {lSucess,cRet,aDisp}


/*/{Protheus.doc} TecCoCarol
Programa de liberação de Token para acesso a API´s Clock In da Carol
@author Equipe TECA
@since 17/08/2022
@return return, return_description
/*/
Function TecCoCarol()

Local aHeader   := {}
Local aRetorno  := {}
Local cParams   := ""
Local cRet      := ""
Local cRetCarol := ""
Local cPath     := ""
Local ccURL		:= ""
Local cErro     := ""
Local nCont		:= 0
Local nI		:= 0
Local oErro     := JsonObject():New()
Local oRet      := JsonObject():New()
Local lSucess   := .T.
Local lErro		:= .F.
Local lAtuaToken:= .F.
Local oObj		:= Nil
Local oClient   := Nil
Local lGeraLog	:= .F.

lGeraLog := If(aParams[15] .And. FWIsInCallStack("TecBudisp"),.T.,.F.)

If lGeraLog
	aAdd(aLogIntegC,STR0040) //"Início do processo de autenticação"
	aAdd(aLogIntegC,dToC(Date())+" "+Time())
	aLogTecInt := aClone(aLogIntegC)
EndIf

If Empty(aParams[2])
	aAdd( aLog[1], STR0041 ) //"Verifique o parametro MV_APICLO1 pois ele é responsável pelo cadastro da URL de EndPoint para a integração de Clockin da Carol."
	If lGeraLog
		aAdd(aLogIntegC,STR0041)
		aAdd(aLogTecInt,STR0041)
	EndIf
	lErro := .T.
EndIf

If Empty(aParams[3]) .OR. aParams[3] == "/" 
	aAdd( aLog[1], STR0042 ) //"Verifique o parametro MV_APICLO2 pois ele é responsável pelo cadastro do path da api Token para a integração de Clockin da Carol."
	If lGeraLog
		aAdd(aLogIntegC,STR0042) //"Verifique o parametro MV_APICLO2 pois ele é responsável pelo cadastro do path da api Token para a integração de Clockin da Carol."
		aAdd(aLogTecInt,STR0042) //"Verifique o parametro MV_APICLO2 pois ele é responsável pelo cadastro do path da api Token para a integração de Clockin da Carol."
	EndIf
	lErro := .T.
EndIf

If Empty(aParams[4])
	aAdd( aLog[1], STR0043 ) //"Verifique o parametro MV_APICLO3 pois ele é responsável pelo cadastro do Id Conector para a integração de Clockin da Carol."
	If lGeraLog
		aAdd(aLogIntegC,STR0043) //"Verifique o parametro MV_APICLO3 pois ele é responsável pelo cadastro do Id Conector para a integração de Clockin da Carol."
		aAdd(aLogTecInt,STR0043) //"Verifique o parametro MV_APICLO3 pois ele é responsável pelo cadastro do Id Conector para a integração de Clockin da Carol."
	EndIf
	lErro := .T.
EndIf

If Empty(aParams[7])
	aAdd( aLog[1], STR0044 ) //"Verifique o parametro MV_APICLO6 pois ele é responsável pelo cadastro do Domain Name para a integração de Clockin da Carol."
	If lGeraLog
		aAdd(aLogIntegC,STR0044) //"Verifique o parametro MV_APICLO6 pois ele é responsável pelo cadastro do Domain Name para a integração de Clockin da Carol."
		aAdd(aLogTecInt,STR0044) //"Verifique o parametro MV_APICLO6 pois ele é responsável pelo cadastro do Domain Name para a integração de Clockin da Carol."
	EndIf
	lErro := .T.
EndIf

If Empty(aParams[8]) .OR. aParams[8] == "/" 
	aAdd( aLog[1], STR0045 ) 
	If lGeraLog
		aAdd(aLogIntegC,STR0045) //"Verifique o parametro MV_APICLO7 pois ele é responsável pelo cadastro do path da api DeviceList  para a integração de Clockin da Carol."
		aAdd(aLogTecInt,STR0045) //"Verifique o parametro MV_APICLO7 pois ele é responsável pelo cadastro do path da api DeviceList  para a integração de Clockin da Carol."
	EndIf
	lErro := .T.
EndIf

If Empty(aParams[9]) .OR. aParams[9] == "/" 
	aAdd( aLog[1], STR0046 ) //"Verifique o parametro MV_APICLO8 pois ele é responsável pelo cadastro do path da api clockinrecordsList para a integração de Clockin da Carol."
	If lGeraLog
		aAdd(aLogIntegC,STR0046) //"Verifique o parametro MV_APICLO8 pois ele é responsável pelo cadastro do path da api clockinrecordsList para a integração de Clockin da Carol."
		aAdd(aLogTecInt,STR0046) //"Verifique o parametro MV_APICLO8 pois ele é responsável pelo cadastro do path da api clockinrecordsList para a integração de Clockin da Carol."
	EndIf
	lErro := .T.
EndIf

If Empty(aParams[10]) 
	aAdd( aLog[1], STR0047 ) //"Verifique o parametro MV_APICLO9 pois ele é responsável pelo cadastro do Organization Name para a integração de Clockin da Carol."
	If lGeraLog
		aAdd(aLogIntegC,STR0047) //"Verifique o parametro MV_APICLO9 pois ele é responsável pelo cadastro do Organization Name para a integração de Clockin da Carol."
		aAdd(aLogTecInt,STR0047) //"Verifique o parametro MV_APICLO9 pois ele é responsável pelo cadastro do Organization Name para a integração de Clockin da Carol."
	EndIf
	lErro := .T.
EndIf

If ( (Empty(aParams[5]) .Or. Empty(aParams[6]) ) .And. Empty(aParams[12]) )
	aAdd( aLog[1], STR0048 ) //"Para realizar a integração será necessário preencher os parâmetros MV_APICLO4 e MV_APICLO5 ou MV_APICLOA."
	If lGeraLog
		aAdd(aLogIntegC,STR0048) //"Para realizar a integração será necessário preencher os parâmetros MV_APICLO4 e MV_APICLO5 ou MV_APICLOA."
		aAdd(aLogTecInt,STR0048) //"Para realizar a integração será necessário preencher os parâmetros MV_APICLO4 e MV_APICLO5 ou MV_APICLOA."
	EndIf
	lErro := .T.
EndIf

If lErro
	lSucess := .F.

	aAdd( aLog[1], "")
	aAdd( aLog[1], STR0034 )//"Configuração dos parâmetros: "
	aAdd( aLog[1], "  MV_APICLO1: " + aParams[2] )
	aAdd( aLog[1], "  MV_APICLO2: " + aParams[3] )
	aAdd( aLog[1], "  MV_APICLO3: " + aParams[4] )
	aAdd( aLog[1], "  MV_APICLO4: " + aParams[5] )
	aAdd( aLog[1], "  MV_APICLO5: " + aParams[6] )
	aAdd( aLog[1], "  MV_APICLO6: " + aParams[7] )
	aAdd( aLog[1], "  MV_APICLO7: " + aParams[8] )
	aAdd( aLog[1], "  MV_APICLO8: " + aParams[9] )
	aAdd( aLog[1], "  MV_APICLO9: " + aParams[10] )

	If aParams[13]
		aAdd( aLog[1], "  MV_APICLOA: " + aParams[12] )	
	EndIf
	aAdd( aLog[1], "  MV_APICLOB: " + cValToChar(aParams[14]) )	

	aAdd(aRetorno,lSucess)
	aAdd(aRetorno,Nil)
	aAdd(aRetorno,Nil)
	aAdd(aRetorno,"")
	aAdd(aRetorno,STR0042)

	If lGeraLog
		aAdd(aLogIntegC,STR0049) //"Falha na autenticação"
		aAdd(aLogTecInt,STR0049) //"Falha na autenticação"
		aAdd(aLogIntegC,STR0050) //"Fim do processo de autenticação"
		aAdd(aLogTecInt,STR0050) //"Fim do processo de autenticação"
		fGeraLog(@aLogIntegC,STR0004) //"Integração Carol"
		fGeraLog(@aLogTecInt,STR0018) //"Log Técnico Integração Carol"
	EndIf

	Return (aRetorno)
EndIf

// Verifica se a autenticação deve ser realizada via API Token
If !Empty(aParams[12])
	// Faz um teste do Connector Token informado
	ccURL	:= aParams[2]
	cPath	:= "/api/v3/apiKey/details"
	cParams := "apiKey=" + aParams[12] +"&"
	cParams += "connectorId=" + aParams[4]

	AAdd( aHeader, "Accept: application/json" )
	AAdd( aHeader, "X-Auth-Key: " + aParams[12] )
	AAdd( aHeader, "X-Auth-ConnectorId: " + aParams[4] )

	oClient := FwRest():New(ccURL)
	oClient:SetPath(cPath)
	oClient:SetPostParams(cParams)
	oClient:Get(aHeader,cParams)

	If lGeraLog
		aAdd(aLogIntegC,STR0051) //"Validando o API Token"
		aAdd(aLogIntegC,STR0020 + ccURL) //"URL Base: "
		aAdd(aLogIntegC,STR0021 + cPath) //"URL Requisição: "
		aAdd(aLogIntegC,STR0052) //"Iniciando a validação do API Token"
		aAdd(aLogTecInt,STR0051) //"Validando o API Token"
		aAdd(aLogTecInt,STR0022 + ccURL) //" - URL: "
		aAdd(aLogTecInt,STR0023 + cPath) //" - Path: "
		aAdd(aLogTecInt,STR0024 + cParams) //" - Parâmetros: "
		For nI := 1 To Len(aHeader)
			aAdd(aLogTecInt,STR0025 + aHeader[nI]) // " - Header: "
		Next
		aAdd(aLogTecInt,STR0052) //"Iniciando a validação do API Token"
		aAdd(aLogTecInt,STR0053 + oClient:oResponseh:cStatusCode) //" - Http status code: "
	EndIf

	If FWJsonDeserialize(oClient:GetResult(),@oObj)
		If oObj <> Nil
			cRet := oClient:GetResult()
			If oRet:fromJson(cRet) == Nil .And. oRet["errorCode"] == Nil
				lApiToken := .T.
				lSucess := .T.
				cErro := "ok"
				If lGeraLog
					aAdd(aLogIntegC,STR0054) //"API Token validado com sucesso"
					aAdd(aLogTecInt,STR0054) //"API Token validado com sucesso"
					aAdd(aLogTecInt,STR0055) //"Retorno da API:"
					aAdd(aLogTecInt,cRet)
				EndIf
			EndIf
		EndIf
	EndIf
Else
	If Len(aLog) > 0
		If Len(aLog[1]) > 0
			If !aScan(aLog, {|x| x[1] == "Falha na autenticação por API Key (Opcional)."}) > 0
				aAdd( aLog[1], STR0059 )//"Falha na autenticação por API Key (Opcional)."
				aAdd( aLog[1], STR0060 )//"Para utilizar a autenticação por API Key crie o parâmetro MV_APICLOA e preencha com o token gerado pela Carol."
				aAdd( aLog[1], STR0061 )//"Foi realizado uma tentativa de autenticação por usuário e senha."
				aAdd( aLog[1], "" )
			EndIf
		Else
			aAdd( aLog[1], STR0039 )//"Falha na autenticação por API Key (Opcional)."
			aAdd( aLog[1], STR0041 )//"Para utilizar a autenticação por API Key crie o parâmetro MV_APICLOA e preencha com o token gerado pela Carol."
			aAdd( aLog[1], STR0040 )//"Foi realizado uma tentativa de autenticação por usuário e senha."
			aAdd( aLog[1], "" )
		EndIf
	EndIf
EndIf

If !lApiToken
	// Autenticação utilizando usuário e senha para gerar o Access Token
	aHeader := {}
	AAdd( aHeader, "Accept: application/json" )
	AAdd( aHeader, "Content-Type: application/x-www-form-urlencoded" )
	ccURL := aParams[2]
	cPath := aParams[3]
	cParams := "grant_type=password&"
	cParams += "connectorId=" + aParams[4] + "&"
	cParams += "username=" + aParams[5] + "&"
	cParams += "password=" + aParams[6] + "&"
	cParams += "subdomain=" + AllTrim(aParams[10]) + "&"
	cParams += "orgSubdomain=" + aParams[7]

	oClient := FwRest():New(ccURL)
	oClient:SetPath(cPath)
	oClient:SetPostParams(cParams)

	If lGeraLog
		aAdd(aLogIntegC,STR0062) //"Inicializando autenticação utilizando usuário e senha"
		aAdd(aLogIntegC,STR0020 + ccURL) //"URL Base: "
		aAdd(aLogIntegC,STR0021 + cPath) //"URL Requisição: "
		aAdd(aLogTecInt,STR0062) //"Inicializando autenticação utilizando usuário e senha"
		aAdd(aLogTecInt,STR0022 + ccURL) //" - URL: "
		aAdd(aLogTecInt,STR0023 + cPath) //" - Path: "
		aAdd(aLogTecInt,STR0024 + cParams) //" - Parâmetros: "
		For nI := 1 To Len(aHeader)
			aAdd(aLogTecInt,STR0059 + aHeader[nI]) // " - Header: "
		Next
	EndIf

	If lSucess .And. oClient:Post(aHeader)
		If lGeraLog
			aAdd(aLogTecInt,STR0053 + oClient:oResponseh:cStatusCode) //" - Http status code: "
		EndIf
		If FWJsonDeserialize(oClient:GetResult(),@oObj)
			If oObj <> Nil			
				cRet := oClient:GetResult()
				If oRet:fromJson(cRet) == Nil .And. oRet["access_token"] <> Nil
					lSucess := .T.
					cErro := "ok"
					If lGeraLog
						aAdd(aLogIntegC,STR0063) //"Usuário e senha validado com sucesso"
						aAdd(aLogTecInt,STR0063) //"Usuário e senha validado com sucesso"
						aAdd(aLogTecInt,STR0055) //"Retorno da API:"
						aAdd(aLogTecInt,cRet)
					EndIf
					// Tenta gerar o API Token se não existir, para ser utilizado
					// em integrações futuras
					If ( !lGeraTokn .And. aParams[13] .And. Empty( aParams[12] ) ) .Or. lAtuaToken
						TeChvApi(aParams[2], oRet:GetJsonText( "access_token" ), aParams[4], aParams[10], lGeraLog)
					EndIf
				EndIf
			EndIf
		EndIf	
	Else	
		lSucess := .F.
		cRet := oClient:GetResult()

		If Empty(cRet)
			aAdd( aLog[1], STR0006) //"Não foi possível acessar a API Clockin da Carol. "
			aAdd( aLog[1], STR0065 ) //"Verifique se a URL de Endpoint da Carol está informada corretamente no parâmetro MV_APICLO1."
			
			If lGeraLog
				aAdd(aLogIntegC,STR0053 + oClient:oResponseh:cStatusCode) //" - Http status code: "
				aAdd(aLogIntegC,STR0006) //"Não foi possível acessar a API Clockin da Carol. "
				aAdd(aLogIntegC,STR0065) //"Verifique se a URL de Endpoint da Carol está informada corretamente no parâmetro MV_APICLO1."
				aAdd(aLogTecInt,STR0053 + oClient:oResponseh:cStatusCode) //" - Http status code: "
				aAdd(aLogTecInt,STR0006) //"Não foi possível acessar a API Clockin da Carol. "
				aAdd(aLogTecInt,STR0065) //"Verifique se a URL de Endpoint da Carol está informada corretamente no parâmetro MV_APICLO1."
			EndIf
		Else
			cRetCarol := cRet
			oErro:fromJSON( cRet )
			oErro:toJSON( cRet )
			If !Empty( oErro:getJSONText( "errorCode" ) ) .And. oErro:getJSONText( "errorCode" ) != "null" .And. ( Empty( oErro:getJSONText( "code" ) ) .Or. oErro:getJSONText( "code" ) == "null")
				If lGeraLog
					aAdd(aLogIntegC,STR0053 + oClient:oResponseh:cStatusCode) //" - Http status code: "
					aAdd(aLogTecInt,STR0053 + oClient:oResponseh:cStatusCode) //" - Http status code: "
				EndIf
				If oErro:getJSONText( "errorCode" ) == "400" .Or. oErro:getJSONText( "errorCode" ) == "401"
					aAdd( aLog[1], STR0067 ) //"Verifique se o usuário e a senha estão informados corretamente nos parâmetros MV_APICLO4 e MV_APICLO5."
					If lGeraLog
						aAdd(aLogIntegC,STR0067) //"Verifique se o usuário e a senha estão informados corretamente nos parâmetros MV_APICLO4 e MV_APICLO5."
						aAdd(aLogTecInt,STR0067) //"Verifique se o usuário e a senha estão informados corretamente nos parâmetros MV_APICLO4 e MV_APICLO5."
					EndIf
				ElseIf !Empty( oErro:getJSONText( "errorCode" ) ) .And. oErro:getJSONText( "errorCode" ) == "404" .And. oErro:getJSONText( "possibleResponsibleField" ) == "mdmSubdomain" 
					aAdd( aLog[1], STR0068 ) //"Verifique se o subdomínio e a organização estão informados corretamente nos parâmetros MV_APICLO6 e MV_APICLO9."
					If lGeraLog
						aAdd(aLogIntegC,STR0068) //"Verifique se o subdomínio e a organização estão informados corretamente nos parâmetros MV_APICLO6 e MV_APICLO9."
						aAdd(aLogTecInt,STR0068) //"Verifique se o subdomínio e a organização estão informados corretamente nos parâmetros MV_APICLO6 e MV_APICLO9."
					EndIf
				ElseIf !Empty( oErro:getJSONText( "errorCode" ) ) .And. oErro:getJSONText( "errorCode" ) == "404" .And. oErro:getJSONText( "possibleResponsibleField" ) == "mdmName" 
					aAdd( aLog[1], STR0069) //"Verifique se o Connector Id preenchido no parâmetro MV_APICLO3 está correto."
					If lGeraLog
						aAdd(aLogIntegC,STR0069) //"Verifique se o Connector Id preenchido no parâmetro MV_APICLO3 está correto."
						aAdd(aLogTecInt,STR0069) //"Verifique se o Connector Id preenchido no parâmetro MV_APICLO3 está correto."
					EndIf
				EndIf
				aAdd( aLog[1], "")
			EndIf
			If !Empty( oErro:getJSONText( "errorCode" ) ) .And. oErro:getJSONText( "errorCode" ) != "null"
				aAdd( aLog[1], STR0032 + oErro:getJSONText( "errorCode" ) )//"Código do erro retornado pela API: "
			EndIf
			If !Empty( oErro:getJSONText( "errorMessage" ) ) .And. oErro:getJSONText( "errorMessage" ) != "null"
				aAdd( aLog[1], STR0033 + oErro:getJSONText( "errorMessage" ) )//"Mensagem de erro retornado pela API: "
				If lGeraLog
					aAdd(aLogIntegC,STR0033) //"Mensagem de erro retornado pela API: "
					aAdd(aLogIntegC,oErro:getJSONText( "errorMessage" )) //"Mensagem de erro retornado pela API: "
				EndIf
			EndIf
			If !Empty( oErro:getJSONText( "possibleResponsibleField" ) ) .And. oErro:getJSONText( "possibleResponsibleField" ) != "null"
				aAdd( aLog[1], STR0070 + oErro:getJSONText( "possibleResponsibleField" ) ) //"Possível campo responsável pelo erro retornado pela API: "
				If lGeraLog
					aAdd(aLogIntegC,STR0070 + oErro:getJSONText( "possibleResponsibleField" )) //"Possível campo responsável pelo erro retornado pela API: "
				EndIf
			EndIf
		EndIf
		aAdd( aLog[1], "")
		aAdd( aLog[1], STR0034 )//"Configuração dos parâmetros: "
		aAdd( aLog[1], "  MV_APICLO1: " + aParams[2] )
		aAdd( aLog[1], "  MV_APICLO2: " + aParams[3] )
		aAdd( aLog[1], "  MV_APICLO3: " + aParams[4] )
		aAdd( aLog[1], "  MV_APICLO4: " + aParams[5] )
		aAdd( aLog[1], "  MV_APICLO5: " + aParams[6] )
		aAdd( aLog[1], "  MV_APICLO6: " + aParams[7] )
		aAdd( aLog[1], "  MV_APICLO7: " + aParams[8] )
		aAdd( aLog[1], "  MV_APICLO8: " + aParams[9] )
		aAdd( aLog[1], "  MV_APICLO9: " + aParams[10] )

		If aParams[13]
			aAdd( aLog[1], "  MV_APICLOA: " + aParams[12] )
		EndIf
		aAdd( aLog[1], "  MV_APICLOB: " + cValToChar(aParams[14]) )

		If !Empty(cRetCarol)
			aAdd( aLog[1], "")
			aAdd( aLog[1], STR0035)//"Erro completo retornado pela API da Carol: "
		EndIf
		
		If lGeraLog
			aAdd(aLogIntegC,STR0072) //"Fim do processo de autenticação"
			aAdd(aLogIntegC,dToC(Date())+" "+Time())
			If !Empty(cRet)
				aAdd(aLogTecInt,STR0055) //"Retorno da API:"
				aAdd(aLogTecInt,cRet)
			EndIf
			aAdd(aLogTecInt,STR0072) //"Fim do processo de autenticação"
			aAdd(aLogTecInt,dToC(Date())+" "+Time())
			fGeraLog(@aLogIntegC,STR0004) //"Integração Carol"
			fGeraLog(@aLogTecInt,STR0018) //"Log Técnico Integração Carol"
		EndIf
	EndIf
EndIf    

If cRet == Nil
	cRet := ""
EndIf

aAdd(aRetorno,lSucess)

If lSucess
	If !lApiToken
		aAdd(aRetorno,oRet:GetJsonText("access_token"))
		aAdd(aRetorno,oRet)
	EndIf
Else
	aAdd(aRetorno,Nil)
	aAdd(aRetorno,Nil)

	For nCont := 1 To Len( aLog[1] )
		cErro += aLog[1, nCont] + CRLF
	Next nCont
EndIf


If !lApiToken
	aAdd(aRetorno,cRet)
	aAdd(aRetorno,cErro)
EndIf

If lGeraLog
	aAdd(aLogIntegC,STR0072) //"Fim do processo de autenticação"
	aAdd(aLogIntegC,dToC(Date())+" "+Time())
	aAdd(aLogTecInt,STR0072) //"Fim do processo de autenticação"
	aAdd(aLogTecInt,dToC(Date())+" "+Time())
EndIf

Return (aRetorno)

/*/{Protheus.doc} TecBuspar
Carregando os parâmetros
@author Equipe TECA
@since 17/08/2022
/*/
Function TecBuspar()
Local aParam 	:= {}
Local lTipoI 	:= SUPERGETMV('MV_APICLO0', .F., .F.)			// Utiliza integração com Carol Clockin?
Local cSiteW 	:= Alltrim(SUPERGETMV('MV_APICLO1', .F., ''))	// Clockin da Carol - Enderço de Acesso ao EndPoint.
Local cPathW 	:= Alltrim(SUPERGETMV('MV_APICLO2', .F., ''))	// Clockin da Carol - Patch de Acesso ao EndPoint.
Local cConec 	:= Alltrim(SUPERGETMV('MV_APICLO3', .F., ''))	// Clockin da Carol - ID de Conexão de Acesso
Local cUsern 	:= Alltrim(SUPERGETMV('MV_APICLO4', .F., ''))	// Clockin da Carol - Username de Acesso ao EndPoint.
Local cPassw 	:= Alltrim(SUPERGETMV('MV_APICLO5', .F., ''))	// Clockin da Carol - Password de Acesso ao EndPoint
Local cDomin 	:= Alltrim(SUPERGETMV('MV_APICLO6', .F., ''))	// Clockin da Carol - Domain Name de Acesso EndPoint
Local cPathD 	:= Alltrim(SUPERGETMV('MV_APICLO7', .F., ''))	// Path do EndPoint DeviceList -ClockIn Carol.
Local cPathM 	:= Alltrim(SUPERGETMV('MV_APICLO8', .F., ''))	// Path EndPoint clockinrecordsList - Clockin Carol
Local lOrgExist	:= SUPERGETMV('MV_APICLO9',.F.,.F.)
Local cOrg	 	:= Alltrim(SUPERGETMV('MV_APICLO9', .F., ''))	// Clockin da Carol - Nome da Organizacao de acesso EndPoint.
Local lApiExist	:= SUPERGETMV('MV_APICLOA',.F.,.F.)
Local cApiToken	:= Alltrim(SUPERGETMV('MV_APICLOA', .F., ''))	// Codigo do API Token (Connector Token)
Local lProcIni	:= SUPERGETMV('MV_APICLOB',.F.,.F.)				// Determina se revalida NSR caso haja lacunas na numeração (.T.), ou se processa a partir do último
Local lGeraLog	:= SUPERGETMV('MV_APICLOC',.F.,.F.)				// Define se será gerado o log de integração com a Carol. .T. = Gera o log; .F. = Não gera o log
Local cPageSize := SUPERGETMV('MV_GSPAGSZ',.F.,'1000')			// Define tamanho de pagina de retorno da API

lOrgExist := ValType(lOrgExist) == "C"
lApiExist := ValType(lApiExist) == "C"

aAdd(aParam,lTipoI)		// 01
aAdd(aParam,cSiteW)		// 02
aAdd(aParam,Iif(Substr(cPathW,1,1) <> '/', '/'+cPathW, cPathW ))	//03
aAdd(aParam,cConec)		//04
aAdd(aParam,cUsern)		//05
aAdd(aParam,cPassw)		//06
aAdd(aParam,cDomin)		//07
aAdd(aParam,Iif(Substr(cPathD,1,1) <> '/', '/'+cPathD, cPathD ))	//08
aAdd(aParam,Iif(Substr(cPathM,1,1) <> '/', '/'+cPathM, cPathM ))	//09
aAdd(aParam,cOrg)		//10
aAdd(aParam,lOrgExist)	//11
aAdd(aParam,cApiToken)	//12
aAdd(aParam,lApiExist)	//13
aAdd(aParam,lProcIni)	//14
aAdd(aParam,lGeraLog)	//15
aAdd(aParam,cPageSize)	//16

Return (aParam)


/*/{Protheus.doc} TecBusDat
Busca a última Data do dispositivo lido.
@author Equipe TECA
@since 17/08/2022
/*/
Static Function TecBusDat(cAccesCod, cDtini)
Local cRet		:= ""
Local cAliasTMP := GetNextAlias()
Local cSelect	:= ""
Local cTabInteg := ""
Local cWhere 	:= ""
Local cQuery 	:= ""

cSelect 	:= "T40_DATMAR MAXIMO"
cTabInteg 	:= RetSqlName("T40") + " T40"
cWhere 		+= "INNER JOIN ( "
cWhere 		+= "SELECT T40_CODREL, MAX(T40_VALCON) T40_VALCON "
cWhere 		+= "FROM " + RetSqlName("T40")
cWhere 		+= "WHERE T40_CODREL = ? AND D_E_L_E_T_= ' ' GROUP BY T40_CODREL) ULTDT "
cWhere 		+= "ON ULTDT.T40_CODREL=T40.T40_CODREL AND ULTDT.T40_VALCON=T40.T40_VALCON"

If __oSt03 == Nil
	__oSt03 := FWPreparedStatement():New()

	cQuery := "SELECT " + cSelect
	cQuery += " FROM " + cTabInteg
	cQuery += " " + cWhere
	cQuery := ChangeQuery(cQuery)

	__oSt03:SetQuery(cQuery)
EndIf

__oSt03:SetString(1, cAccesCod)

cQuery := __oSt03:getFixQuery()

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTMP, .T., .T.)
TCSetField(cAliasTMP, "MAXIMO", "D" )
If (cAliasTMP)->(!EOF())
	cRet := (cAliasTMP)->(MAXIMO)+1
	If cRet <= dDataBase
		cDtini := dTOS(cRet)
	EndIf
	cDtIni := Substr(cDtIni,1,4) + '-' + Substr(cDtIni,5,2) + '-' + Substr(cDtIni,7,2)
EndIf
( cAliasTMP )->(dbCloseArea())

Return Nil

/*/{Protheus.doc} TecBusNSR
Busca o código NSR do último dispositivo lido.
@author Equipe TECA
@since 17/08/2022
/*/
Static Function TecBusNSR(cAccesCod, lProcIni)

Local nContador := 0
Local cAliasTMP := GetNextAlias()
Local cSelect	:= ""
Local cTabInteg := ""
Local cWhere 	:= ""
Local cQuery 	:= ""

If !lProcIni
	cSelect 	:= "MAX(T40_CODNSR) AS MAXIMO"
Else
	cSelect 	:= "MIN(T40_CODNSR) AS MAXIMO"
EndIf
cTabInteg 		:= RetSqlName("T40")
If !lProcIni
	cWhere 		:= "T40_CODREL = ?"
Else
	cWhere 		:= "T40_CODREL = ? AND T40_CODNSR+1 NOT IN (SELECT T40_CODNSR FROM "+RetSqlName('T40')+" WHERE T40_CODREL = ?)"
EndIf

If __oSt01 == Nil
	__oSt01 := FWPreparedStatement():New()

	cQuery := "SELECT " + cSelect
	cQuery += " FROM " + cTabInteg
	cQuery += " WHERE " + cWhere
	cQuery := ChangeQuery(cQuery)
		
	__oSt01:SetQuery(cQuery)
EndIf

__oSt01:SetString(1, cAccesCod)
If lProcIni
	__oSt01:SetString(2, cAccesCod)
EndIf

cQuery := __oSt01:getFixQuery()

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTMP, .T., .T.)

nContador := (cAliasTMP)->(MAXIMO)
nContador++

( cAliasTMP )->(dbCloseArea())

Return (cValToChar(nContador))

/*/{Protheus.doc} TecProNum
Busca o proximo registro sequencial da tabela.
@author Equipe TECA
@since 17/08/2022
/*/
Static Function TecProNum()

Local nContador := 0
Local cAliasTMP := GetNextAlias()
Local cSelect	:= ""
Local cTabInteg := ""
Local cQuery 	:= ""

cSelect 	:= "MAX(T40_VALCON) AS MAXIMO"
cTabInteg 	:= RetSqlName('T40')

If __oSt02 == Nil
	__oSt02 := FWPreparedStatement():New()

	cQuery := "SELECT " + cSelect
	cQuery += " FROM " + cTabInteg
	cQuery := ChangeQuery(cQuery)
		
	__oSt02:SetQuery(cQuery)
EndIf

cQuery := __oSt02:getFixQuery()

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTMP, .T., .T.)

nContador := (cAliasTMP)->(MAXIMO)

( cAliasTMP )->(dbCloseArea())

nContador += 1

Return (nContador)

/*/{Protheus.doc} ConsoleJob
Exibe uma mensagem no console quando a rotina for via Schedule.
@author Equipe TECA
@since 17/08/2022
/*/
Static Function ConsoleJob(cMensagem)

Conout(Replicate("-",30))
Conout(FwNoAccent(OemToAnsi(STR0013))) //"Execução da Rotina PONAPI01 - Via Schedule"
Conout(FwNoAccent(OemToAnsi(cMensagem)))
Conout(Replicate("-",30))

Return (.T.)

/*/{Protheus.doc} FiltraLog
//Função que quebra o texto para gravação no log
@author Equipe TECA
@since 17/08/2022
@version 1.0
@return NIL
@param aLogCalc, array, Array que deve ser preenchido com a mensagem do log
@param cTexto, characters, Texto que deve ser apresentado no log
@type function
/*/
Static Function FiltraLog(aLogCalc, cTexto)
Local nPos := 0

If Len(Alltrim(cTexto)) >= 210
	nPos := At(" ",cTexto,200)
	If nPos > 0
		aAdd(aLogCalc, substr(cTexto,1,nPos))
		aAdd(aLogCalc, substr(cTexto,nPos))
	Else
		aAdd(aLogCalc, substr(cTexto,1,209))
		aAdd(aLogCalc, substr(cTexto,210))
	EndIf
Else
	aAdd(aLogCalc, cTexto)
EndIf

Return( NIL )
*/
/*/{Protheus.doc} TeChvApi
//Função para gerar o API Token 
@author Equipe TECA
@since 17/08/2022
@version 1.0
@return NIL
@param URL Carol, Access Token, Conector Id, Organização
@type function
/*/
Static Function TeChvApi( ccURL, cAccesTokn, cConecId, cOrg, lGeraLog)
Local aHeader	:= {}
Local cPath		:= ""
Local cParams	:= ""
Local cRet		:= ""
Local oClient	:= Nil
Local oObj		:= Nil
Local oRet		:= JsonObject():New()
Local nI		:= 0

Default ccURL		:= ""
Default cAccesTokn	:= ""
Default cConecId	:= ""
Default cOrg		:= ""
Default lGeraLog	:= .F.

	If !Empty(cAccesTokn) .And. !Empty(cConecId) .And. !Empty(ccURL) .And. !Empty(cOrg)
		cPath	:= "/api/v1/apiKey/issue"
		cParams := "connectorId=" + cConecId + "&
		cParams += "description=%7B%22en-US%22%3A%22API%20Token%20Protheus%22%7D"

		aAdd( aHeader, "Accept: application/json" )
		aAdd( aHeader, "Authorization:" + cAccesTokn )
		aAdd( aHeader, "Content-type: application/x-www-form-urlencoded" )
		aAdd( aHeader, "Origin:" + ccURL )
		aAdd( aHeader, "Referer:" + ccURL + "/" + cOrg + "/carol-ui/environment/connector-tokens" )

		oClient := FwRest():New(ccURL)
		oClient:SetPath(cPath)
		oClient:SetPostParams(cParams)
		oClient:Post(aHeader)

		If lGeraLog
			aAdd(aLogIntegC,STR0073) //"Iniciado o processo automático para geração da API Token"
			aAdd(aLogIntegC,STR0020 + ccURL) //"URL Base: "
			aAdd(aLogIntegC,STR0021 + cPath) //"URL Requisição: "
			aAdd(aLogTecInt,STR0073) //"Iniciado o processo automático para geração da API Token"
			aAdd(aLogTecInt,STR0022 + ccURL) //" - URL: "
			aAdd(aLogTecInt,STR0023 + cPath) //" - Patch: "
			aAdd(aLogTecInt,STR0024 + cParams) //" - Parâmetros: "
			For nI := 1 To Len(aHeader)
				aAdd(aLogTecInt,STR0025 + aHeader[nI]) //" - Header: "
			Next
		EndIf
		
		If FWJsonDeserialize(oClient:GetResult(),@oObj)
			If oObj <> Nil
				cRet := oClient:GetResult()
				If oRet:fromJson(cRet) == Nil .And. oRet["errorCode"] == Nil
					PutMv("MV_APICLOA",oRet["X-Auth-Key"])
					lGeraTokn := .T.
					If lGeraLog
						aAdd(aLogIntegC,STR0074) //"API Token gerada com sucesso e salvo no parâmetro MV_APICLOA"
						aAdd(aLogTecInt,STR0074) //"API Token gerada com sucesso e salvo no parâmetro MV_APICLOA"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return

/*/{Protheus.doc} TeAddMarc
//Função para adicionar marcações no array para posterior gravação 
@author Equipe TECA
@since 17/08/2022
@version 1.0
@return NIL
@type static function
/*/
Static Function TeAddMarc(oJson, aMarcac, nUltNSR, lDashBoard)

Local aTemp		:= {}
Local nCoutRegs	:= 0

Default lDashBoard := .T.

For nCoutRegs:= 1 to Len(oJson["hits"])			
	If !Empty( oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["piscode"] )	.Or. lDashBoard				
		aTemp   := {oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["piscode"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["nsrcode"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["mdmeventdate"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["eventdatestr"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["mdmpersonid"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["mdmname"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["devicedescription"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["eventdatestr"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["devicecode"]}
					
		If ValType(oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["coordinates"]) != "U"
			aAdd(aTemp, oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["coordinates"]["lon"])
			aAdd(aTemp, oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["coordinates"]["lat"])
			aAdd(aTemp, oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["isuserinsidegeofenceenum"])
		EndIf

		//nUltNSR := oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["nsrcode"]
		aAdd(aMarcac,aTemp)					
	EndIf				
Next nCoutRegs

Return

/*/{Protheus.doc} fGeraLog
//Função para gerar arquivo de log em txt
@author Equipe TECA
@since 17/08/2022
@version 1.0
@return NIL
@type static function
/*/
Static Function fGeraLog(aLog,cNomeArq)
Local nLenArq		:= 0
Local nI			:= 0
Local nHandle		:= 0
Local cLogPatch		:= GetSrvProfString("Startpath","")

DEFAULT aLog		:= {}
DEFAULT cNomeArq	:= ""

If !Empty(aLog) .And. !Empty(cNomeArq)
	nLenArq := Len(aLog)
	If (nHandle := fopen(cLogPatch + cNomeArq + ".txt",2,Nil,.F.)) == -1
		If (nHandle := FCREATE(cLogPatch + cNomeArq + ".txt",,Nil,.F.)) != -1
			FSeek(nHandle, 0, 2)
			For nI:=1 To nLenArq
				FWrite(nHandle, aLog[nI] + CRLF )
			Next
			FWrite(nHandle,CRLF)
		EndIf
  	Else
		FSeek(nHandle, 0, 2)
		For nI:=1 To nLenArq
			FWrite(nHandle, aLog[nI] + CRLF )
		Next
		FWrite(nHandle,CRLF)
	EndIf

	fClose(nHandle)
EndIf

aLog := {}
Return

/*/{Protheus.doc}
TeExigPer 
@author Equipe TECA
@since 17/08/2022
@version 1.0
@return NIL
@type static function
/*/
Static Function TeExigPer(cPergunte)
Local lRet	:= .F.
Local oSX1	:= FWSX1Util():New()

oSX1:AddGroup(cPergunte)
oSX1:SearchGroup()

If !Empty(oSX1:aGrupo[1,2])
	lRet:= .T.
EndIf

FreeObj(oSX1)
Return lRet
