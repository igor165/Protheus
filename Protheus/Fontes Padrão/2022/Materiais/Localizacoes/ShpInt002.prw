#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} ShpInt002
    Function used to get Shopify customers and insert in Protheus
    @type  Function
    @author Yves Oliveira
    @since 25/03/2020
    /*/
Function ShpInt002(aParam)
    Local aParams    := {}
    Local oInt       := Nil
    Local aCustomers := {}
    Local nI         := 0
	Local cError	 := ""
	Local nRecno	 := 0
	Local cIdExt	 := ""
	Local cDtIni	 := ""
	Local cDtFim	 := ""
	Local _cEmpresa, _cFilial

	If ValType(aParam) == "A"
        _cEmpresa    := aParam[1]
        _cFilial     := aParam[2]
	else
		_cEmpresa    := "01"
        _cFilial     := "01"
	EndIf

    If Select("SX2") == 0
        RpcSetType(3)
        RpcSetEnv(_cEmpresa,_cFilial)
    EndIf

	oInt := ShpCustomer():New()
	oInt:setVerb(REST_METHOD_GET)
	oInt:setRequestBody("{}")
	
	cDtIni  := ShpGetTime(Date()-1, "00:00:00")
	cDtFim	:= ShpGetTime(Date()  , "23:59:59")

	//AAdd(aParams,{"ids","3016475246658"})
	AAdd(aParams,{"updated_at_min", cDtIni})
	AAdd(aParams,{"updated_at_max", cDtFim})
	oInt:setUrlParams(aParams)
	
	oInt:requestToShopify()

	If Empty(oInt:error)
		aCustomers := aClone(oInt:oCustomer:customers)
		For nI := 1 To Len(aCustomers)
			cIdExt := aCustomers[nI]:id
			nRecno := 0
			cError := ""
			If !ShpUpdCust(aCustomers[nI], aCustomers[nI]:default_address, @nRecno, @cError)
				ShpSaveErr(cValToChar(nRecno), cIdExt, oInt:cIntegration, cError, oInt:path, oInt:apiVer, oInt:body, oInt:verb)
			EndIf
		Next nI
	EndIf

	freeObj(oInt)
	
Return

/*/{Protheus.doc} ShpUpdCust
    Function to add/update a customer on Protheus
    @type  Static Function
    @author Yves Oliveira
    @since 25/03/2020
    /*/
Function ShpUpdCust(oCustomer, oAddress, nRecno, cError, oShipAddress, nRecnoShip)
    Local aArea    := GetArea()
    Local aAreaSA1 := {}
	Local aAreaCC2 := {}
	Local cId      := ""
	Local cAddrId  := ""
	Local nOpcX	   := 3
    
	Local cCode    := ""
	Local cSite	   := ""
	Local cEmail   := ""
	Local cName    := ""
	Local cPhone   := ""
	Local cAddress := ""
	Local cComplem := ""
	Local cCity    := ""
	Local cState   := ""
	Local cCompany := ""
	Local cType    := ShpGetPar("TIPOCLI", "1", STR0016)//"Default customer type"
	Local cClass   := ShpGetPar("NATUCLI", "" , STR0017)//PADR("10101001", TamSx3("A1_NATUREZ")[1])
	Local cCountry := ShpGetPar("PAISCLI", "" , STR0018)//"249"
	Local cZipCode := ""
	Local cLastUpd := ""	
	Local cShpStr  := ""	
	Local cProtStr := ""
	Local oError   := ErrorBlock({|e| cError += e:Description })
	Local lChanged := .F.
	Local lRet	   := .T.


	//Caso tenha objeto de ShipAddresss
	Local lShipAddress := iif( !empty(oShipAddress),.T.,.F. ) //variavel que verifica se tem ou nao endereco de entrga para integrar
	Local cShipSite    := "" //A1_LOJA
	Local cShipName    := "" //A1_NOME
	Local cShipAddress := "" //A1_ENDENT
	Local cShipCompl   := "" //A1_COMPLEM
	Local cShipCompa   := "" //A1_NREDUZ
	Local cShipCity    := "" //A1_MUNE
	Local cShipState   := "" //A1_ESTE	
	Local cShipZipCode := "" //A1_CEPE

	

	Private lMsErroAuto   := .F.
	Private lAutoErrNoFile:= .T.

	Default cError := ""
	Default oShipAddress := ""

	cClass := GetAdvFVal("SED","ED_CODIGO", xFilial("SED") + cClass ,1)
	If Empty(cClass)
		cError := STR0014 + ": " + cClass //"Class not found"
		nRecno := 0
		Return .F.
	EndIf

	DBSelectArea('SA1')
	aAreaSA1 := SA1->(getArea())
	SA1->(DbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA

	DBSelectArea('CC2')
	aAreaCC2 := CC2->(getArea())
	CC2->(DbSetOrder(1))//CC2_FILIAL+CC2_EST+CC2_CODMUN

	
	BEGIN SEQUENCE
		cId    := cValToChar(oCustomer:id)
		nRecno := ShpGetId(SHP_ALIAS_CUSTOMER, cId, /*cAliasPai*/, /*cIdPai*/, .T./*lFilIdExt*/)
		If nRecno <> Nil
			nRecno := Val(nRecno)
		Else
			nRecno := 0
		EndIf

		If nRecno > 0
			SA1->(DbGoTo(nRecno))
			cCode := SA1->A1_COD
			cSite := SA1->A1_LOJA
			nOpcX := 4				
		Else
			cSite := strZero(1, tamSX3('A1_LOJA')[1])
		EndIf

		If oAddress:first_name == Nil .And. oAddress:first_name == Nil
			cName    := PADR(ClearStr(FwNoAccent(AllTrim(oCustomer:first_name) + " " +  AllTrim(oCustomer:last_name))), TamSx3("A1_NOME")[1])
		Else
			cName    := PADR(ClearStr(FwNoAccent(AllTrim(iif(oAddress:first_name == Nil, "", oAddress:first_name)) + " " + ;
			                            AllTrim(iif(oAddress:last_name == Nil, "", oAddress:last_name)))), TamSx3("A1_NOME")[1])		
		EndIf
		
		cEmail   := PADR(FwNoAccent(oCustomer:email), TamSx3("A1_EMAIL")[1])
		//cName    := PADR(FwNoAccent(AllTrim(oCustomer:first_name) + " " +  AllTrim(oCustomer:last_name)), TamSx3("A1_NOME")[1])
		cPhone   := PADR(FwNoAccent(iif(oCustomer:phone == Nil, "", oCustomer:phone)), TamSx3("A1_TEL")[1])
		cAddrId  := oAddress:id
		cAddress := PADR(ClearStr(FwNoAccent(oAddress:address1)), TamSx3("A1_END")[1])
		cComplem := PADR(ClearStr(FwNoAccent(iif(oAddress:address2 == Nil, "", oAddress:address2))), TamSx3("A1_COMPLEM")[1])
		cCity    := PADR(ClearStr(FwNoAccent(iif(oAddress:city == Nil, "", oAddress:city))), TamSx3("A1_MUN")[1])
		cCompany := iif(oAddress:company == Nil, "", oAddress:company)
		cCompany := PADR(ClearStr(FwNoAccent(iif(Empty(cCompany), cName, cCompany))), TamSx3("A1_NREDUZ")[1])
		cState   := FwNoAccent(oAddress:province_code)
		cZipCode := PADR(ClearStr(FwNoAccent(oAddress:zip)), TamSx3("A1_CEP")[1])

		
		cState := GetAdvFVal("SX5","X5_CHAVE", xFilial("SX5") + "12" + cState ,1)
		If Empty(cState)
			cState := "EX"
		EndIf			
		cState := PADR(AllTrim(cState), TamSx3("A1_EST")[1])

		If Empty(oCustomer:updated_at)				
			cLastUpd := oCustomer:created_at
		Else
			cLastUpd := oCustomer:updated_at
		EndIf

		//Check if the default address has been changed
		If !Empty(cCode)
			
			cShpStr  := AllTrim(cEmail + cName + cPhone + cAddress + cComplem + cCity + cCompany + cState + cZipCode)
			cProtStr := AllTrim(SA1->(A1_EMAIL + A1_NOME + A1_TEL + A1_END + A1_COMPLEM + A1_MUN + A1_NREDUZ + A1_EST + A1_CEP))
			//ajuste izo para nunca alterar no Protheus o endereco de billing eu comentei o fonte abaixo
			If cShpStr <> cProtStr
				//Funcão para buscar o cliente de billing
				GetCliBill(cId, oAddress, @nRecno)
				If nRecno == Nil .Or. nRecno == 0				
					lChanged := .T.
					nOpcX    := 3
					cSite 	 := CliLastSite(cCode)
				Else
					SA1->(DbGoTo(nRecno))
					cCode := SA1->A1_COD
					cSite := SA1->A1_LOJA				
				EndIF
			EndIf
		EndIf

		If Empty(cCode) .Or. lChanged
			lRet := CliExecAut(nOpcX, cCode, cSite, cName, cCompany, cType, cAddress, cComplem, ;
							cState, cCity, cZipCode, cPhone, cEmail, cCountry, cType, cClass, @nRecno, @cError)
			If lRet
				ShpSaveId(SHP_ALIAS_CUSTOMER, cValToChar(nRecno), cId,,,cLastUpd)
				ShpSaveId(SHP_ALIAS_CUSTOMER_ADDRESS, cValToChar(nRecno), cId /*	*/, SHP_ALIAS_CUSTOMER, cValToChar(nRecno), cLastUpd)
			EndIf
		EndIf

		If lRet .And. lShipAddress
			GetCliShip(cId, oShipAddress, @nRecnoShip)
			If nRecnoShip == Nil .Or. nRecnoShip == 0
				cShipName	 := PADR(ClearStr(FwNoAccent(AllTrim(oShipAddress:first_name) + " " +  AllTrim(oShipAddress:last_name))), TamSx3("A1_NOME")[1])			
				cShipAddress := PADR(ClearStr(FwNoAccent(oShipAddress:address1)), TamSx3("A1_END")[1])
				cShipCompl   := PADR(ClearStr(FwNoAccent(iif(oShipAddress:address2 == Nil, "", oShipAddress:address2))), TamSx3("A1_COMPLEM")[1])
				cShipCompa   := iif(oShipAddress:company == Nil, "", ClearStr(FwNoAccent(oShipAddress:company)))
				cShipCompa   := PADR(ClearStr(FwNoAccent(iif(Empty(cShipCompa), cName, cShipCompa))), TamSx3("A1_NREDUZ")[1])
				cShipCity    := PADR(ClearStr(FwNoAccent(iif(oShipAddress:city == Nil, "", FwNoAccent(oShipAddress:city)))), TamSx3("A1_MUNE")[1]) //A1_MUNE
				cShipState   := FwNoAccent(oShipAddress:province_code)  //A1_ESTE	
				cShipZipCode := PADR(FwNoAccent(oShipAddress:zip), TamSx3("A1_CEPE")[1]) //A1_CEPE	
				cShipPhone   := PADR(FwNoAccent(iif(oShipAddress:phone == Nil, "", oShipAddress:phone)), TamSx3("A1_TEL")[1])
				cShipPhone   := PADR(FwNoAccent(iif(oShipAddress:phone == Nil, "", oShipAddress:phone)), TamSx3("A1_TEL")[1])
				cShipPhone	 := PADR(FwNoAccent(iif(Empty(cShipPhone), cPhone, cShipPhone)), TamSx3("A1_TEL")[1])
				cShipSite 	 := CliLastSite(cCode) //Soma1(cSite,TamSx3("A1_LOJA")[1])
				BEGIN TRANSACTION
					
					lRet := CliExecAut(3, cCode, cShipSite, cShipName, cShipCompa, cType, cShipAddress, cShipCompl, cShipState,;
						               cShipCity, cShipZipCode, cShipPhone, cEmail, cCountry, cType, cClass, @nRecnoShip, @cError)
					If lRet
						cLastUpd := ShpGetTime()
						ShpSaveId(SHP_ALIAS_CUSTOMER, cValToChar(nRecnoShip), cId,,,cLastUpd)
						ShpSaveId(SHP_ALIAS_CUSTOMER_ADDRESS, cValToChar(nRecnoShip), cId, SHP_ALIAS_CUSTOMER, cValToChar(nRecnoShip), cLastUpd)
					EndIf
				END TRANSACTION
			EndIf
		EndIf
	
	RECOVER 
		lRet := .F.
	END SEQUENCE
	ErrorBlock(oError)

    RestArea(aAreaCC2)
	RestArea(aAreaSA1)
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} GetCliShip
	Return the shipping customer
	@type  Static Function
	@author Yves Oliveira
	@since 30/04/2020
	/*/
Static Function GetCliShip(cIdExt, oShipAddr, nRecnoShip)
	Local lFound    := .F.
	Local cShpStr   := ""
	Local cProtStr  := ""
	Local cQuery    := ""
	Local cShipName := ""
	Local cAlias    := GetNextAlias()
	
	nRecnoShip := 0

    cShipName	:= PADR(ClearStr(FwNoAccent(AllTrim(oShipAddr:first_name) + " " +  AllTrim(oShipAddr:last_name))), TamSx3("A1_NOME")[1])
	cAddress 	:= PADR(ClearStr(FwNoAccent(oShipAddr:address1)), TamSx3("A1_END")[1])
	cComplem 	:= PADR(ClearStr(FwNoAccent(iif(oShipAddr:address2 == Nil, "", oShipAddr:address2))), TamSx3("A1_COMPLEM")[1])
	cZipCode 	:= PADR(FwNoAccent(oShipAddr:zip), TamSx3("A1_CEP")[1])
	cShipCity   := PADR(ClearStr(FwNoAccent(iif(oShipAddr:city == Nil, "", FwNoAccent(oShipAddr:city)))), TamSx3("A1_MUN")[1]) //A1_MUNE	
	
	cShpStr  := AllTrim(cShipName + cZipCode + cAddress + cComplem + cShipCity)

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
	cQuery += "SELECT SA1.R_E_C_N_O_ RECNOSA1, A1_NOME, A1_COD, A1_LOJA, A1_CEP, A1_END, A1_COMPLEM, A1_MUN" + CRLF
	cQuery += "  FROM " + RetSqlTab("A1D,SA1") + CRLF
	cQuery += " WHERE SA1.D_E_L_E_T_  = ' '" + CRLF
	cQuery += "   AND A1D.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "   AND A1_FILIAL = '" + xFilial("SA1") + "'" + CRLF
	cQuery += "   AND A1D_FILIAL = '" + xFilial("A1D") + "'" + CRLF
	cQuery += "   AND (A1D_ALIAS    = '" + SHP_ALIAS_CUSTOMER         /*SHP_ALIAS_CUSTOMER */+ "'" + CRLF
	cQuery += "        OR A1D_ALIAS = '" + SHP_ALIAS_CUSTOMER_ADDRESS /*SHP_ALIAS_CUSTOMER */+ "')" + CRLF	
	cQuery += "   AND A1D_ID = SA1.R_E_C_N_O_" + CRLF
	cQuery += "   AND A1D_IDEXT = '" + cIdExt + "'" + CRLF
	
	TcQuery cQuery new Alias &cAlias
	
	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())
	
	While !(cAlias)->(Eof())
		cProtStr := AllTrim((cAlias)->(A1_NOME + A1_CEP + A1_END + A1_COMPLEM + A1_MUN))

		If cShpStr == cProtStr
			nRecnoShip := (cAlias)->RECNOSA1
			lFound  := .T.
			Exit
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	
	(cAlias)->(DbCloseArea())
	
Return lFound

/*/{Protheus.doc} GetCliBill
	Return the Billing customer
	@type  Static Function
	@author Marcos Furtado Morais
	@since 30/04/2020
	/*/
Static Function GetCliBill(cIdExt, oAddress, nRecno)
	Local lFound    := .F.
	Local cBillStr   := ""
	Local cProtStr  := ""
	Local cQuery    := ""
	Local cBillName := ""
	Local cAlias    := GetNextAlias()
	
	nRecno := 0

    cBillName	:= PADR(ClearStr(FwNoAccent(AllTrim(oAddress:first_name) + " " +  AllTrim(oAddress:last_name))), TamSx3("A1_NOME")[1])
	cAddress 	:= PADR(ClearStr(FwNoAccent(oAddress:address1)), TamSx3("A1_END")[1])
	cComplem 	:= PADR(ClearStr(FwNoAccent(iif(oAddress:address2 == Nil, "", oAddress:address2))), TamSx3("A1_COMPLEM")[1])
	cZipCode 	:= PADR(FwNoAccent(oAddress:zip), TamSx3("A1_CEP")[1])
	cCity       := PADR(ClearStr(FwNoAccent(iif(oAddress:city == Nil, "", oAddress:city))), TamSx3("A1_MUN")[1])	
	
	cBillStr    := AllTrim(cBillName + cZipCode + cAddress + cComplem + cCity)

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
	cQuery += "SELECT SA1.R_E_C_N_O_ RECNOSA1, A1_NOME, A1_COD, A1_LOJA, A1_CEP, A1_END, A1_COMPLEM, A1_MUN" + CRLF
	cQuery += "  FROM " + RetSqlTab("A1D,SA1") + CRLF
	cQuery += " WHERE SA1.D_E_L_E_T_  = ' '" + CRLF
	cQuery += "   AND A1D.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "   AND A1_FILIAL = '" + xFilial("SA1") + "'" + CRLF
	cQuery += "   AND A1D_FILIAL = '" + xFilial("A1D") + "'" + CRLF
	cQuery += "   AND (A1D_ALIAS    = '" + SHP_ALIAS_CUSTOMER         /*SHP_ALIAS_CUSTOMER */+ "'" + CRLF
	cQuery += "        OR A1D_ALIAS = '" + SHP_ALIAS_CUSTOMER_ADDRESS /*SHP_ALIAS_CUSTOMER */+ "')" + CRLF	
	cQuery += "   AND A1D_ID = SA1.R_E_C_N_O_" + CRLF
	cQuery += "   AND A1D_IDEXT = '" + cIdExt + "'" + CRLF
	
	TcQuery cQuery new Alias &cAlias
	
	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())
	
	While !(cAlias)->(Eof())
		cProtStr := AllTrim((cAlias)->(A1_NOME + A1_CEP + A1_END + A1_COMPLEM + A1_MUN))

		If cBillStr == cProtStr
			nRecno := (cAlias)->RECNOSA1
			lFound  := .T.
			Exit
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	
	(cAlias)->(DbCloseArea())
	
Return lFound

/*/{Protheus.doc} CliExecAut
	Call customer execauto
	@type  Static Function
	@author Yves Oliveira
	@since 01/05/2020	
	/*/
Static Function CliExecAut(nOpcX, cCode, cSite, cName, cCompany, cType, cAddress, cComplem, ;
						   cState, cCity, cZipCode, cPhone, cEmail, cCountry, cType, cClass, nRecno, cError)
	Local lRet 		 := .F.
	Local aCustomer  := {}
	Local cCodMun    := ""
	local aArea      := GetArea()
	Local cCGC		 := "00000000000"
	Local _aRetCC2   := {}
	Local _xj		 := 0
	Local _nX		 := 0
	
	If !Empty(cCode)
		AADD(aCustomer, {'A1_COD'	  , cCode	, nil})
	EndIf
	//TODO - Alterar aqui para geraï¿½ï¿½o na mesma loja?
	
	//Chamada da funï¿½ï¿½o para verificar o cï¿½digo da cidade.
	DbSelectArea("CC2")
	DbSetOrder(4)
	//CC2_FILIAL+CC2_EST+CC2_MUN
	If DbSeek(xFilial("CC2")+UPPER(AllTrim(cState))+AllTrim(UPPER(cCity)))
		cCodMun := CC2->CC2_CODMUN
	Else
		_aRetCC2 := ShpRetCC2(cCity,cState)
		cCodMun := _aRetCC2[1]

	EndIF
	DbSelectArea("CC2")
	DbSetOrder(1)//CC2_FILIAL+CC2_EST+CC2_CODMUN
	
	If !Empty(cCodMun)
		__oModelAut := Nil

		BEGIN TRANSACTION

			If __oModelAut == Nil //somente uma unica vez carrega o modelo CTBA020-Plano de Contas CT1
				__oModelAut := FWLoadModel("MATA030")
			EndIf
			//cCity   := Posicione("CC2",1,xFilial("CC2")+AllTrim(cState)+AllTrim(cCodMun),"CC2_MUN")
			//TODO : Definir tratativa do codigo de atividade padrao do cliente.
			DbSelectArea("CCN")
			DbSetOrder(1)//CNN_FILIAL+CNN_USRCOD+CNN_CONTRA+CNN_TRACOD 
			If DbSeek(xFilial("CCN")+cState)
				_cAtivida := CCN->CCN_CIIU
			Else
				_cAtivida := ""
			EndIF

			DbSelectArea("SA1")
			If Empty(cSite)	
				cSite :='01'
			Endif

			AADD(aCustomer, {'A1_LOJA'    , cSite   , nil})
			AADD(aCustomer, {'A1_NOME'    , cName   , nil})
			AADD(aCustomer, {'A1_NREDUZ'  , cCompany, nil})
			AADD(aCustomer, {'A1_TIPO'    , cType   , nil})
			AADD(aCustomer, {'A1_END'     , cAddress, nil})
			AADD(aCustomer, {'A1_COMPLEM' , cComplem, nil})			 
			AADD(aCustomer, {'A1_EST'     , cState  , nil})
			AADD(aCustomer, {'A1_COD_MUN' , cCodMun , nil})
			AADD(aCustomer, {'A1_MUN'     , cCity   , nil})
			AADD(aCustomer, {'A1_CEP'     , cZipCode, nil})
			AADD(aCustomer, {'A1_TEL'  	  , cPhone  , nil})
			AADD(aCustomer, {'A1_EMAIL'   , cEmail  , nil})
			AADD(aCustomer, {'A1_PAIS' 	  , cCountry, nil})
			AADD(aCustomer, {'A1_CONTRBE' , cType   , nil})
			AADD(aCustomer, {'A1_ATIVIDA' , _cAtivida , nil})		
			AADD(aCustomer, {'A1_NATUREZ' , cClass  , nil})
			AADD(aCustomer, {'A1_CGC'     , cCGC    , nil})
			AADD(aCustomer, {'A1_RETIVA'  , '1'     , nil})

			__oModelAut:SetOperation(nOpcX) // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
			__oModelAut:Activate() //ativa modelo

			//---------------------------------------------------------
			// Preencho os valores da SA1
			//---------------------------------------------------------
			oSA1 := __oModelAut:getModel("MATA030_SA1") //Objeto similar enchoice SA1 

			For _xj := 1 to Len(aCustomer)

				_cX3Tipo := GETSX3CACHE(aCustomer[_xj][1],"X3_TIPO")
				If  _cX3Tipo == 'C' 
					_nTamC   := TamSx3(aCustomer[_xj][1])[1]
					_xCampo  := SUBSTR(aCustomer[_xj][2],1,_nTamC)
				ElseIf _cX3Tipo == 'N'  
					_nTamC   := TamSx3(aCustomer[_xj][1])[1]
					_nTamD   := TamSx3(aCustomer[_xj][1])[2]
					_xCampo  := Val(StrTran(aCustomer[_xj][2],",","."))
				ElseIf _cX3Tipo == 'D'
					_xCampo := CTOD(aCustomer[_xj][2])
				else
					_xCampo := aCustomer[_xj][2]
				ENDIF  

				If AllTrim(aCustomer[_xj][1]) == 'A1_EMAIL'
					oSA1:SETVALUE(aCustomer[_xj][1],StrTran(_xCampo,"|",";") )	
				else
					oSA1:SETVALUE(aCustomer[_xj][1], _xCampo)				
				EndIF
			Next _xj

			If __oModelAut:VldData() //validacao dos dados pelo modelo

				__oModelAut:CommitData() //gravacao dos dados

				nRecno := SA1->(recno())
				lRet := .T.
				//Tratativa para mandar email de aviso caso o municipio nao foi devidamente informado.
				If Len(_aRetCC2) > 0
					If _aRetCC2[3] < 0.85 //Nota do Retorno da ComparaÃ§Ã£o
					//Chamar envio de e-mail
						ShpSendMail("CUSTOMER",SA1->A1_COD + "-" + SA1->A1_LOJA, STRSHP0098 + cCity + ". It was used the code: " + cCodMun + "-" + _aRetCC2[2] + ". Rate: " + AllTrim(Str(ROUND(_aRetCC2[3],2))))  ////"It was imposible to find the City Code.  City: 
						//Futuramente gravar no log do monitoramento tb.
					ENDIF				
				EndIf				
				//fGeralog(.T.,_aLinha[_nPosCOD],_aLinha[_nPosDesc])

			Else

				aLog := __oModelAut:GetErrorMessage() //Recupera o erro do model quando nao passou no VldData
				cLog := ""
				//laco para gravar em string cLog conteudo do array aLog
				For _nX := 1 to Len(aLog)
					If !Empty(aLog[_nX])
						cLog += Alltrim(aLog[_nX]) + CRLF
					EndIf
				Next _nX			

				cError := cLog				
				//cError := ShpDetErr()
				lRet   := .F.
				DisarmTransaction()

			EndIf

			__oModelAut:DeActivate() //desativa modelo

			__oModelAut:Destroy()
		// Fim de Teste MVC

		END TRANSACTION		
	Else
		cError := STR0098 + cCity + ". " //"It was imposible to find the City Code.  City: 
		lRet   := .F.		
	EndIf

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} CliExecAut
	Call customer execauto
	@type  Static Function
	@author Izo Cristiano Montebugnoli
	@since 05/29/2020	
	/*/
Static Function CliLastSite(cCodeCli)


    Local aArea    := GetArea()
	Local cQuery   := ""
	Local cAlias   := GetNextAlias()
	Local cNextSite := StrZero("1",TamSx3("A1_LOJA")[1])

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
	cQuery := "SELECT A1_LOJA FROM  " + RetSqlTab("SA1") + CRLF
	cQuery += "WHERE D_E_L_E_T_ = ' ' "
	cQuery += "AND A1_FILIAL = '" + xFilial("SA1") + "'" + CRLF
	cQuery += "AND A1_COD = '" + cCodeCli + "' " + CRLF
	cQuery += "ORDER BY A1_LOJA DESC  " + CRLF
	
	TcQuery cQuery new Alias &cAlias
	
	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())
	
	If !(cAlias)->(Eof())
		cNextSite := Soma1( (cAlias)->A1_LOJA,TamSx3("A1_LOJA")[1] )		
	EndIf
	
	(cAlias)->(DbCloseArea())

	RestArea(aArea)	

Return cNextSite


/*/{Protheus.doc} CliExecAut
	Call customer execauto
	@type  Static Function
	@author Izo Cristiano Montebugnoli
	@since 05/29/2020	
	/*/
Static Function ClearStr(_cString)
    Local aArea       := GetArea()

    //Retirando caracteres
    _cString := StrTran(_cString, "'", "")
  /*  cConteudo := StrTran(cConteudo, "#", "")
    cConteudo := StrTran(cConteudo, "%", "")
    cConteudo := StrTran(cConteudo, "*", "")
    cConteudo := StrTran(cConteudo, "&", "E")
    cConteudo := StrTran(cConteudo, ">", "")
    cConteudo := StrTran(cConteudo, "<", "")
    cConteudo := StrTran(cConteudo, "!", "")
    cConteudo := StrTran(cConteudo, "@", "")
    cConteudo := StrTran(cConteudo, "$", "")
    cConteudo := StrTran(cConteudo, "(", "")
    cConteudo := StrTran(cConteudo, ")", "")
    cConteudo := StrTran(cConteudo, "_", "")
    cConteudo := StrTran(cConteudo, "=", "")
    cConteudo := StrTran(cConteudo, "+", "")
    cConteudo := StrTran(cConteudo, "{", "")
    cConteudo := StrTran(cConteudo, "}", "")
    cConteudo := StrTran(cConteudo, "[", "")
    cConteudo := StrTran(cConteudo, "]", "")
    cConteudo := StrTran(cConteudo, "/", "")
    cConteudo := StrTran(cConteudo, "?", "")
    cConteudo := StrTran(cConteudo, ".", "")
    cConteudo := StrTran(cConteudo, "\", "")
    cConteudo := StrTran(cConteudo, "|", "")
    cConteudo := StrTran(cConteudo, ":", "")
    cConteudo := StrTran(cConteudo, ";", "")
    cConteudo := StrTran(cConteudo, '"', '')
    cConteudo := StrTran(cConteudo, '°', '')
    cConteudo := StrTran(cConteudo, 'ª', '')*/
    
    
    RestArea(aArea)
Return _cString
