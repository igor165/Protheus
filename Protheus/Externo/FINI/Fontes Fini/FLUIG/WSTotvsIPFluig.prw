#Include "Protheus.ch"
#Include "ApWebSrv.ch"
#Include "MsObject.ch"
#Include "FWCommand.ch"
#Include "TbiConn.ch"

#Define USER_ID	2
#Define LOGIN	3

#Define COMPANY	1
#Define BRANCH	2
#Define NAME	7
#Define CNPJ	18

/*/{Protheus.doc} WsTotvsIPFluig

Web Service genérico para uso no Fluig

@author 	Ectore Cecato - Totvs IP Jundiaí
@since 		01/03/2017
@version 	Protheus 12

@obs Baseado no programa WsTotvsIPFluig, desenvolvido por Daniel Braga

/*/

WsService WsTotvsIPFluig DESCRIPTION "WebService Genérico para uso no Fluig"  NameSpace "http://totvsip.com.br"

	WsData sendJSON	    As String
	WsData receiveJSON  As String

	WsMethod ExecQuery		DESCRIPTION "Método responsável por executar consulta retornando seu resultset"  				
	WsMethod ExistReg 	   	DESCRIPTION "Método responsável por verificar se existe um registro. Usa o DbSeek para esta verificação"
	WsMethod ExecMsExecAuto	DESCRIPTION "Método responsável por cadastrar registro via rotina automática"   
	WsMethod GetTable       DESCRIPTION "Método responsável por retornar o nome da tabela real"
	WsMethod GetBranch      DESCRIPTION "Método responsável por retornar a filial da tabela"
	WsMethod ExecFunction   DESCRIPTION "Método responsável por executar função sem e com retorno"
	WsMethod GetUserId  	DESCRIPTION "Método responsável por retornar o código do usuário"
	WsMethod GetUserBranch  DESCRIPTION "Método responsável por retornar as filias do usuário"

EndWsService

WsMethod ExecQuery WsReceive receiveJSON WsSend sendJSON WsService WsTotvsIPFluig

	Local lRet := .F.
	Local oObj := Nil

	If !FWJsonDeserialize(receiveJSON, @oObj)

		SetSoapFault("KEY", "Erro na conversão do JSON. Verifique a estrutura")

		Return .F.

	EndIf

	RpcSetType(3)

	RpcSetEnv(oObj:company, oObj:branch)

	cEmpAnt := oObj:company
	cFilAnt := oObj:branch

	ConOut("[WSTotvsIPFluig][ExecQuery] ===> "+ ::receiveJSON)
	
	lRet := wsExecQuery(oObj, ::receiveJSON, @::sendJSON)
	
	ConOut("[WSTotvsIPFluig][ExecQuery] ===> "+ ::sendJSON)
	
	FreeObj(oObj)
	
Return lRet

WsMethod ExistReg WsReceive receiveJSON WsSend sendJSON WsService WsTotvsIPFluig

	Local lRet := .F.
	Local oObj := Nil

	If !FWJsonDeserialize(receiveJSON, @oObj)
		
		SetSoapFault("KEY", "Erro na conversão do JSON. Verifique a estrutura")

		Return .F.

	EndIf

	RpcSetType(3)

	RpcSetEnv(oObj:company, oObj:branch)

	cEmpAnt := oObj:company
	cFilAnt := oObj:branch
	
	ConOut("[WSTotvsIPFluig][ExistReg] ===> "+ ::receiveJSON)
	
	lRet := WsExistReg(oObj, ::receiveJSON, @::sendJSON)

	ConOut("[WSTotvsIPFluig][ExistReg] ===> "+ ::sendJSON)
	
	FreeObj(oObj)
	
Return lRet

WsMethod ExecMsExecAuto WsReceive receiveJSON WsSend sendJSON WsService WsTotvsIPFluig

	Local aArea	  		:= GetArea()
	Local aHeader 		:= {}
	Local aCols   		:= {}
	Local aLine			:= {}
	Local aError   		:= {}
	Local cError   		:= ""
	Local cCpoAcento	:= ""
	Local nField		:= 0
	Local nItem			:= 0
	Local nOpc  		:= 0
	Local oObj			:= Nil
	Local oModel 		:= Nil
	Local lSetEmp		:= .F.
	Local nCntAll		:= 0
	Local nCntItem		:= 0
	Local aMATA105		:= {}

	Private aRotina        	:= {}
	Private lMsErroAuto		:= .F. //Determina se houve algum tipo de erro durante a execucao do ExecAuto
	Private lMsHelpAuto		:= .T. //Define se mostra ou não os erros na tela (T= Nao mostra; F=Mostra)
	Private lAutoErrNoFile	:= .T. //Habilita a gravacao de erro da rotina automatica

	If !FWJsonDeserialize(::receiveJSON, @oObj)

		SetSoapFault("KEY", "Erro na conversão do JSON. Verifique a estrutura")

		Return .F.

	EndIf
	
	// Seta o ambiente (empresa e filial)
	RpcClearEnv()
	RpcSetType(3)
	lSetEmp := RpcSetEnv(oObj:company, oObj:branch)	
	if lSetEmp
		ConOut("[WSTotvsIPFluig][ExecMsExecAuto] ===> Inicializou o ambiente correto (empresa e filial).")
	else
		ConOut("[WSTotvsIPFluig][ExecMsExecAuto] ===> Houve problema para inicializar o ambiente (empresa e filial).")
	endif
	
	ConOut("[WSTotvsIPFluig][ExecMsExecAuto] ===> "+ ::receiveJSON)
	
	cEmpAnt 	:= oObj:company
	cFilAnt 	:= oObj:branch
	nOpc 		:= Val(oObj:operation)
	cCpoAcento	:= SuperGetMV("ZZ_CPOACEN", .F., "")
	 
	If Type("oObj:user") != "U" .And. !Empty(oObj:user)
		__cUserId := oObj:user
	EndIf

	//Monta aHeader
	For nField := 1 To Len(oObj:data)

		If InfoSX3(oObj:data[nField]:field)[3] == "N"
			aAdd(aHeader, {oObj:data[nField]:field, Val(oObj:data[nField]:value1), IIf(Empty(oObj:data[nField]:value2), Nil, oObj:data[nField]:value2)})				 
		ElseIf InfoSX3(oObj:data[nField]:field)[3] == "D"
			aAdd(aHeader, {oObj:data[nField]:field, CToD(oObj:data[nField]:value1), IIf(Empty(oObj:data[nField]:value2), Nil, oObj:data[nField]:avlue2)})
		Else

			If oObj:data[nField]:field $ cCpoAcento  
				aAdd(aHeader, {oObj:data[nField]:field, StrTran(oObj:data[nField]:value1, "@", '"'), IIf(Empty(oObj:data[nField]:value2), Nil, oObj:data[nField]:value2)})
			Else
				aAdd(aHeader, {oObj:data[nField]:field, oObj:data[nField]:value1, IIf(Empty(oObj:data[nField]:value2), Nil, oObj:data[nField]:value2)})
			EndIf

		EndIf

	Next nField	

	//Monta aCols
	For nItem := 1 To Len(oObj:item)

		For nField := 1 To Len(oObj:item[nItem])

			If InfoSX3(oObj:item[nItem, nField]:field)[3] == "N"
				aAdd(aLine, {oObj:item[nItem, nField]:field, Val(oObj:item[nItem, nField]:value1), IIf(Empty(oObj:item[nItem, nField]:value2), Nil, oObj:item[nItem, nField]:value2)})
			ElseIf InfoSX3(oObj:item[nItem, nField]:field)[3] == "D"
				aAdd(aLine, {oObj:item[nItem, nField]:field, CToD(oObj:item[nItem, nField]:value1), IIf(Empty(oObj:item[nItem, nField]:value2), Nil, oObj:item[nItem, nField]:value2)})
			Else
				//Tratativa para caracter especial "
				If oObj:item[nItem, nField]:field $ cCpoAcento
					aAdd(aLine, {oObj:item[nItem, nField]:field, StrTran(PadR(oObj:item[nItem, nField]:value1, TamSX3(oObj:item[nItem, nField]:field)[1]), "@", '"'), IIf(Empty(oObj:item[nItem, nField]:value2), Nil, oObj:item[nItem, nField]:value2)})
				Else
					aAdd(aLine, {oObj:item[nItem, nField]:field, PadR(oObj:item[nItem, nField]:value1, TamSX3(oObj:item[nItem, nField]:field)[1]), IIf(Empty(oObj:item[nItem, nField]:value2), Nil, oObj:item[nItem, nField]:value2)})
				EndIf

			EndIf

		Next nField

		aadd(aCols, aLine)

		aLine := {}

	Next nItem

	Do Case 

		Case oObj:routine == "MATA410"

			nModulo := 5

			MSExecAuto({|x,y,z| MATA410(x,y,z)}, aHeader, aCols, nOpc)

		Case oObj:routine == "MATA415"

			MATA415(aHeader, aCols, nOpc)	

		Case oObj:routine == "MATA030"	

			MATA030(aHeader, nOpc)				

		Case oObj:routine == "MATA020"	

			MATA020(aHeader, nOpc)

		Case oObj:routine == "MATA121"	

			nModulo := 2
	
			MsExecAuto({|v,x,y,z| MATA120(v,x,y,z)}, 1, FWVetByDic(aHeader, "SC7"), FWVetByDic(aCols, "SC7", .T.), nOpc)

		Case oObj:routine == "MATA010"

			aHeader := FWVetByDic(aHeader, "SB1")
	
			nModulo := 4
	
			MSExecAuto({|x,Y| MATA010(x,Y)}, aHeader, nOpc)

		Case oObj:routine == "MATA061"

			oModel := FWLoadModel("MATA061")
	
			FwMvcRotAuto(oModel, "SA5", nOpc, {{"MdFieldSA5", aHeader}, {"MdGridSA5", aCols}})

		Case oObj:routine == "MATA110"

			aCols := FWVetByDic(aCols, "SC1", .T.)

			nModulo := 2
	
			MsExecAuto({|x, y, z| MATA110(x, y, z)}, aHeader, aCols, nOpc)

		Case oObj:routine == "EECPS400" 

			nModulo := 85
	
			MSExecAuto({|x,y,w,z| EECPS400(x,y,w,z)}, aHeader, aCols, {}, nOpc)	

		Case oObj:routine == "EICPS400" 

			nModulo := 85
	
			MSExecAuto({|x,y,w,z| EICPS400(x,y,w,z)}, aHeader, aCols, {}, nOpc)	

		Case oObj:routine == "MATA018"

			aHeader := FWVetByDic(aHeader, "SBZ")
	
			MSExecAuto({|x, y| MATA018(x, y)}, aHeader, nOpc)

		Case oObj:routine == "MATA180"

			oModelMVC 	:= FwLoadModel("MATA180")
			aHeader 	:= FWVetByDic(aHeader, "SB5")
	
			//MSExecAuto({|x, y| MATA180(x, y)}, aHeader, nOpc)
			FWMVCRotAuto(oModelMVC, "SB5", nOpc, {{"SB5MASTER", aHeader}}) 

		Case oObj:routine == "MATA105"
			
			aAreaSB1	:= SB1->(getArea())
			nModulo 	:= 4
			
			for nCntAll := 1 to len(aCols)
					
				aMATA105 := aCols[nCntAll]
				
				for nCntItem := 1 to len(aMATA105)

					if allTrim(aMATA105[nCntItem,1]) == "CP_PRODUTO"										
						SB1->(dbSetOrder(1))
						if SB1->(dbSeek(FWxFilial("SB1")+aMATA105[nCntItem, 2]))
							ConOut("[WSTotvsIPFluig][ExecMsExecAuto] ===> Localizou o produto: " + aMATA105[nCntItem, 2])
						else
							ConOut("[WSTotvsIPFluig][ExecMsExecAuto] ===> Não localizou o produto: " + aMATA105[nCntItem, 2])
						endif
					endif						
				
				next nCntItem
					
			next nCntAll
				
			
			restArea(aAreaSB1)
																										
			MsExecAuto({|x, y, z| MATA105(x, y, z)}, aHeader, aCols, nOpc)
			
			
		OtherWise

		SetSoapFault("routine", "Essa rotina não existe ou não foi implementada")

		Return .F.

	EndCase

	If lMsErroAuto

		aError := GetAutoGRLog()

		For nItem := 1 To Len(aError)
			cError += aError[nItem] + CRLF
		Next nItem

		ConOut("ExecMsExecAuto -> ["+ oObj:routine +"] - "+ cError)

		SetSoapFault(oObj:routine, cError)

		Return .F.

	Else 
		
		::sendJSON := '{'
		::sendJSON += '"message": "ok"'	
		::sendJSON += '}'

	Endif

	If oObj:routine == "MATA180"

		oModelMVC:DeActivate()
		oModelMVC:Destroy()

		oModelMVC := Nil

	EndIf

	RestArea(aArea)
	
	ConOut("[WSTotvsIPFluig][ExecMsExecAuto] ===> "+ ::sendJSON)
	
	FreeObj(oObj)
	
Return .T.

WsMethod GetTable WsReceive receiveJSON WsSend sendJSON WsService WsTotvsIPFluig

	Local oObj := Nil

	If !FWJsonDeserialize(::receiveJSON, @oObj)
		
		SetSoapFault("KEY", "Erro na conversão do JSON . Verifique a estrutura")

		Return .F.

	EndIf

	RpcSetType(3)

	RpcSetEnv(oObj:company, oObj:branch)

	cEmpAnt := oObj:company
	cFilAnt := oObj:branch

	ConOut("[WSTotvsIPFluig][GetTable] ===> "+ ::receiveJSON)

	::sendJSON := '{'
	::sendJSON += '"company":"'+ oObj:company +'",'
	::sendJSON += '"branch":"'+ oObj:branch +'",'
	::sendJSON += '"alias":"'+ oObj:alias +'",'
	::sendJSON += '"table":"'+ RetSqlName(oObj:alias) +'"'
	::sendJSON += '}'

	ConOut("[WSTotvsIPFluig][GetTable] ===> "+ ::sendJSON)
	
	FreeObj(oObj)
	
Return .T.

WsMethod ExecFunction WsReceive receiveJSON WsSend sendJSON WsService WsTotvsIPFluig

	local nItem  := 0
	local oObj 	 := Nil
	local xValor := Nil
	local xRet	 := Nil

	If !FWJsonDeserialize(::receiveJSON, @oObj)
		
		SetSoapFault("KEY", "Erro na conversão do JSON. Verifique a estrutura")

		Return .F.

	EndIf

	RpcSetType(3)

	RpcSetEnv(oObj:company, oObj:branch)
	
	ConOut("[WSTotvsIPFluig][ExecFunction] ===> "+ ::receiveJSON)
	
	cEmpAnt := oObj:company
	cFilAnt := oObj:branch
	
	If !Empty(oObj:function)

	xRet := &(oObj:function)

	If ValType(xRet) == "N"
		xValor := cValTochar(xRet)		
	ElseIf ValType(xRet) == "D"
		xValor := DToC(xRet)
	ElseIf ValType(xRet) == "L"

		If xRet
			xValor := '"T"'
		Else
			xValor := '"F"' 
		EndIf

	ElseIf ValType(xRet) == "A"

		xValor := ""

		For nItem := 1 To Len(xRet)

			If !Empty(xValor)
				xValor += ","
			EndIf

			xValor += AllTrim(xRet[nItem])

		Next nItem

		xValor := "["+ xValor +"]"

	Else
		xValor:= '"'+ AllTrim(StrTran(xRet, '"', '')) +'"'
	EndIf	

	::sendJSON := '{'
	::sendJSON += '"company":"'+ oObj:company +'",'
	::sendJSON += '"branch":"'+ oObj:branch +'",'
	::sendJSON += '"function":"'+ oObj:function +'",'
	::sendJSON += '"data":'+ xValor +''
	::sendJSON += '}'	

	Else

		SetSoapFault("ExecFunction", "Informe a função")

		Return .F.

	EndIf

	ConOut("[WSTotvsIPFluig][ExecFunction] ===> "+ ::sendJSON)
	
	FreeObj(oObj)
	
Return .T.

WsMethod GetBranch WsReceive receiveJSON WsSend sendJSON WsService WsTotvsIPFluig

	Local oObj := Nil

	If !FWJsonDeserialize(::receiveJSON, @oObj)
		
		SetSoapFault("KEY", "Erro na conversão do JSON. Verifique a estrutura")

		Return .F.

	EndIf

	RpcSetType(3)

	RpcSetEnv(oObj:company, oObj:branch)
	
	ConOut("[WSTotvsIPFluig][GetBranch] ===> "+ ::receiveJSON)
	
	cEmpAnt := oObj:company
	cFilAnt := oObj:branch

	::sendJSON := '{'
	::sendJSON += '"company":"'+ oObj:company +'",'
	::sendJSON += '"branch":"'+ oObj:branch +'",'
	::sendJSON += '"alias":"'+ oObj:alias +'",'
	::sendJSON += '"tableBranch":"'+ FWxFilial(oObj:alias) +'"'
	::sendJSON += '}'

	ConOut("[WSTotvsIPFluig][GetBranch] ===> "+ ::sendJSON)
	
	FreeObj(oObj)
	
Return .T.     

WsMethod GetUserId WsReceive receiveJSON WsSend sendJSON WsService WsTotvsIPFluig

	Local cUserId	:= ""
	Local cJSON		:= ""
	Local nBranch	:= 0
	Local oObj		:= Nil

	If !FWJsonDeserialize(receiveJSON, @oObj)

		SetSoapFault("KEY", "Erro na conversão do JSON. Verifique a estrutura")

		Return .F.

	EndIf

	RpcSetType(3)

	RpcSetEnv(oObj:company, oObj:branch)
	
	ConOut("[WSTotvsIPFluig][GetUserId] ===> "+ ::receiveJSON)
	
	cEmpAnt := oObj:company
	cFilAnt := oObj:branch

	cUserId := WsGetUserId(oObj:user)

	::sendJSON := '{'
	::sendJSON += '"company":"'+ oObj:company +'",'
	::sendJSON += '"branch":"'+ oObj:branch +'",'
	::sendJSON += '"user":"'+ oObj:user +'",'
	::sendJSON += '"userId":"'+ cUserId +'"'
	::sendJSON += '}'
	
	ConOut("[WSTotvsIPFluig][GetUserId] ===> "+ ::sendJSON)
	
	FreeObj(oObj)
	
Return .T.

WsMethod GetUserBranch WsReceive receiveJSON WsSend sendJSON WsService WsTotvsIPFluig

	Local aBranchUser 	:= {}
	Local cData			:= ""
	Local cJSON		  	:= ""
	Local nBranch		:= 0
	Local oObj			:= Nil

	If !FWJsonDeserialize(receiveJSON, @oObj)
		
		SetSoapFault("KEY", "Erro na conversão do JSON. Verifique a estrutura")

		Return .F.

	EndIf

	RpcSetType(3)

	RpcSetEnv(oObj:company, oObj:branch)
	
	ConOut("[WSTotvsIPFluig][GetUserBranch] ===> "+ ::receiveJSON)

	cEmpAnt := oObj:company
	cFilAnt := oObj:branch

	aBranchUser := FwUsrEmp(If(oObj:user == "admin", "000000", oObj:user))

	If !Empty(aBranchUser)

		DbSelectArea("SM0")

		SM0->(DbSetOrder(1))

		If AllTrim(aBranchUser[1]) == "@@@@" //Acessa todas as filiais

			aBranchUser := FWLoadSM0()

			For nBranch := 1 To Len(aBranchUser)

				If !Empty(cData)
					cData += ","
				EndIf

				If MsSeek(aBranchUser[nBranch, COMPANY]+aBranchUser[nBranch, BRANCH])

					cData += '{'
					cData += '"M0_CODIGO":"'+ 	AllTrim(SM0->M0_CODIGO)  +'",' 
					cData += '"M0_CODFIL":"'+ 	AllTrim(SM0->M0_CODFIL)  +'",'
					cData += '"M0_NOMECOM":"'+ 	AllTrim(SM0->M0_NOMECOM) +'",'
					cData += '"M0_FILIAL":"'+ 	AllTrim(SM0->M0_FILIAL)  +'",'
					cData += '"M0_ENDENT":"'+ 	AllTrim(SM0->M0_ENDENT)  +'",'
					cData += '"M0_COMPENT":"'+ 	AllTrim(SM0->M0_COMPENT) +'",'
					cData += '"M0_CIDENT":"'+ 	AllTrim(SM0->M0_CIDENT)  +'",'
					cData += '"M0_ESTENT":"'+ 	AllTrim(SM0->M0_ESTENT)  +'",'
					cData += '"M0_CEPENT":"'+ 	AllTrim(SM0->M0_CEPENT)  +'",'
					cData += '"M0_TEL_PO":"'+ 	AllTrim(SM0->M0_TEL_PO)  +'",'
					cData += '"M0_CGC":"'+ 		AllTrim(SM0->M0_CGC) 	 +'"'
					cData += '}'

				EndIf

			Next nBranch

		Else

			For nBranch := 1 To Len(aBranchUser)

				If !Empty(cData)
					cData += ","
				EndIf

				If MsSeek(aBranchUser[nBranch])

					cData += '{'
					cData += '"M0_CODIGO":"'+ 	AllTrim(SM0->M0_CODIGO)  +'",' 
					cData += '"M0_CODFIL":"'+ 	AllTrim(SM0->M0_CODFIL)  +'",'
					cData += '"M0_NOMECOM":"'+ 	AllTrim(SM0->M0_NOMECOM) +'",'
					cData += '"M0_FILIAL":"'+ 	AllTrim(SM0->M0_FILIAL)  +'",'
					cData += '"M0_ENDENT":"'+ 	AllTrim(SM0->M0_ENDENT)  +'",'
					cData += '"M0_COMPENT":"'+ 	AllTrim(SM0->M0_COMPENT) +'",'
					cData += '"M0_CIDENT":"'+ 	AllTrim(SM0->M0_CIDENT)  +'",'
					cData += '"M0_ESTENT":"'+ 	AllTrim(SM0->M0_ESTENT)  +'",'
					cData += '"M0_CEPENT":"'+ 	AllTrim(SM0->M0_CEPENT)  +'",'
					cData += '"M0_TEL_PO":"'+ 	AllTrim(SM0->M0_TEL_PO)  +'",'
					cData += '"M0_CGC":"'+ 		AllTrim(SM0->M0_CGC) 	 +'"'
					cData += '}'

				EndIf

			Next nBranch

		EndIf

		cJSON += '{'
		cJSON += '"data":['+ cData +']'		
		cJSON += '}'

		::sendJSON := cJSON

	Else

		SetSoapFault("GetUserBranch", "Nenhum Empresa/Filial encontrada")

		Return .F.

	EndIf
	
	ConOut("[WSTotvsIPFluig][GetUserBranch] ===> "+ ::sendJSON)
	
	FreeObj(oObj)
	
Return .T.

Static Function WsExecQuery(oObj, cReceiveJSON, cSendJSON)

	Local cAliasQry  := GetNextAlias()
	Local cFieldName := ""
	Local cData	 	 := ""
	Local cTable	 := ""
	Local nTotReg	 := 0
	Local nContReg   := 0
	Local nQtdFields := 0
	Local nField	 := 0
	Local xValor     := Nil

	Default cReceiveJSON := ""
	Default cSendJSON    := ""

	DbUseArea(.T., "TOPCONN", TcGenQry(,, oObj:query), cAliasQry, .F., .T.)	

	Count To nTotReg

	(cAliasQry)->(DbGoTop())

	While !(cAliasQry)->(Eof())

		cData += '{'

		nQtdFields := (cAliasQry)->(FCount())

		For nField := 1 To nQtdFields

			cFieldName := (cAliasQry)->(FieldName(nField))

			If !cFieldName $ "D_E_L_E_T_|R_E_C_N_O_|R_E_C_D_E_L_"

				Do Case

					Case InfoSX3((cAliasQry)->(FieldName(nField)))[3] == "N"

						cTable := Left(cFieldName, At("_", cFieldName) - 1)
						cTable := IIF(Len(cTable) == 2, "S"+ cTable, cTable)
						xValor := AllTrim(Transform((cAliasQry)->(FieldGet(FieldPos((cAliasQry)->(cFieldName)))), PesqPict(cTable, cFieldName)))
						xValor := StrTran(xValor, ".", "")
						xValor := StrTran(xValor, ",", ".") 	
	
						//xValor := cValToChar((cAliasQry)->(FieldGet(FieldPos((cAliasQry)->(cFieldName)))))
	
						cData += IIf(nField <  nQtdFields, '"'+ cFieldName +'":'+ xValor +',', '"'+ cFieldName +'":'+ xValor)

					Case InfoSX3((cAliasQry)->(FieldName(nField)))[3] == "D"

						xValor :=  DToC(SToD((cAliasQry)->(FieldGet(FieldPos((cAliasQry)->(cFieldName))))))
	
						cData += IIf(nField < nQtdFields,'"'+ cFieldName +'":"'+ xValor +'",', '"'+ cFieldName +'":"'+ xValor +'"')

					OtherWise

						xValor := StrTran(AllTrim((cAliasQry)->(FieldGet(FieldPos((cAliasQry)->(cFieldName))))), '"', '')
						xValor := StrTran(xValor, '“', '')
						xValor := StrTran(xValor, '”', '')
	
						cData += IIf(nField < nQtdFields,'"'+ cFieldName +'":"'+ xValor +'",', '"'+ cFieldName +'":"'+ xValor +'"')

				EndCase		

			EndIf

		Next nField

		nContReg++

		cData += "}"

		If nContReg < nTotReg
			cData += ","
		EndIf

		(cAliasQry)->(DbSkip())

	EndDo

	cSendJSON :='{'
	cSendJSON +=' "company":"'+ oObj:company +'",'
	cSendJSON +=' "branch":"'+ oObj:branch +'",'
	cSendJSON +=' "data":['+ cData +"]"
	cSendJSON +='}
	
	(cAliasQry)->(DbCloseArea())

Return .T.

Static Function WsExistReg(oObj, cReceiveJSON, cSendJSON)

	Local aArea := GetArea()

	Default cReceiveJSON := ""
	Default cSendJSON    := ""

	If !Empty(oObj:alias) .And. !Empty(oObj:indice) .And. !Empty(oObj:seek)

		If ExistCpo(oObj:alias, oObj:seek, oObj:indice)

			cSendJSON :='{'
			cSendJSON +='"company":"'+ oObj:company +'",'
			cSendJSON +='"branch":"'+ oObj:branch +'",'
			cSendJSON +='"alias":"'+ oObj:alias +'",'
			cSendJSON +='"indice":'+ cValToChar(oObj:indice) +','
			cSendJSON +='"seek":"'+ oObj:seek +'",'	
			cSendJSON +='"message":"find"'	
			cSendJSON +='}'

		Else 

			cSendJSON :='{'
			cSendJSON +='"company":"'+ oObj:company +'",'
			cSendJSON +='"branch":"'+ oObj:branch +'",'
			cSendJSON +='"alias":"'+ oObj:alias +'",'
			cSendJSON +='"indice":'+ cValToChar(oObj:indice) +','
			cSendJSON +='"seek":"'+ oObj:seek +'",'	
			cSendJSON +='"message":"notfind"'	
			cSendJSON +='}'

		EndIf

	Else

		SetSoapFault("JSON", "Informações incompletas")

		Return .F.

	EndIf

	RestArea(aArea)

Return .T.

Static Function WsGetUserId(cLogin)

	Local aAllUsers := FWSFAllUsers()
	Local cUserId	:= ""
	Local nUser		:= 0

	For nUser := 1 To Len(aAllUsers)

		If AllTrim(aAllUsers[nUser, LOGIN]) == AllTrim(cLogin) .Or. AllTrim(cLogin) == "admin" .Or. AllTrim(cLogin) == "Admin"

			cUserId := AllTrim(aAllUsers[nUser, USER_ID])

			Exit

		EndIf

	Next nUser

Return cUserId

Static Function InfoSX3(cField)

	Local aArea	   	:= GetArea()
	Local aAreaSX3 	:= SX3->(GetArea())
	Local aRet		:= {0, 0, ""}

	SX3->(DbSetOrder(2))

	SX3->(DbSeek(cField))

	If SX3->(Found())

		aRet[1] := SX3->X3_TAMANHO
		aRet[2] := SX3->X3_DECIMAL
		aRet[3] := SX3->X3_TIPO

	EndIf

	RestArea(aAreaSX3)
	RestArea(aArea)

Return aRet