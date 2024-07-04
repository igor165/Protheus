#Include "Protheus.ch"
#Include "ParmType.ch"

/*/{Protheus.doc} SCACOL02

Rotina responsável pela gravação de itens personalizados (Regras Comerciais)

@type		function
@author 	Ectore Cecato - Totvs IP Jundiaí
@since 		22/11/2018
@version 	Protheus 12 - Totvs Colaboração

@see 		A140IGRV_PE.PRW

/*/

User Function SCACOL02()

	Local aArea			:= GetArea()
	Local aAreaSDS		:= SDS->(GetArea())
	Local aAreaSDT		:= SDT->(GetArea())
	Local aItens		:= {}
	Local cMsg			:= ""
	Local cCFOPRetAr	:= AllTrim(SuperGetMV("ZZ_CFORETA", .F., ""))
	Local cCFOPTrFil	:= AllTrim(SuperGetMV("ZZ_CFOTRFL", .F., ""))
	Local cEmail		:= AllTrim(SuperGetMV("ZZ_NTBLQTC", .F., ""))
	Local cFornSC		:= AllTrim(SuperGetMV("ZZ_FORNSC",  .F., ""))
	Local cDoc   		:= ParamIXB[1] 
	Local cSerie 		:= ParamIXB[2]
	Local cCliFor		:= ParamIXB[3]
	Local cLoja   		:= ParamIXB[4]
	Local oXML			:= ParamIXB[5]
	Local oFatura		:= Nil
	Local nProd			:= 0
	Local lBloq			:= .T.
	
	aItens	:= If(ValType(oXML:_InfNfe:_Det) == "O", {oXML:_InfNfe:_Det}, oXML:_InfNfe:_Det)			
	oFatura	:= If(ValType(XmlChildEx(oXML:_InfNfe, "_Cobr")) == "O", oXML:_InfNfe:_Cobr, Nil)
	
	For nProd := 1 To Len(aItens)
		
		If AllTrim(aItens[nProd]:_PROD:_CFOP:TEXT) $ cCFOPRetAr //Retorno remessa de armazenagem
			RetDevArm(aItens[nProd], nProd, @lBloq)
		ElseIf AllTrim(aItens[nProd]:_PROD:_CFOP:TEXT) $ cCFOPTrFil //Transferência de filial
			TransFil(aItens[nProd], @lBloq) 
		ElseIf SDS->DS_TIPO $ "D,B" //Devolução/Beneficiamento
			
			If cCliFor $ cFornSC 
				DevBen(aItens[nProd], nProd, @lBloq)
			EndIf
			
		ElseIf SDS->DS_TIPO == "N" 
		
			If cCliFor $ cFornSC
				VendaSC(aItens[nProd], nProd, @lBloq)
			Else 
				//Compra fornecedores SC
				VldInfNF(aItens[nProd], oFatura, @lBloq, cDoc, cSerie, cClifor, cLoja, nProd)
			EndIf
			
		EndIf

	Next nProd
	
	If !Empty(SDS->DS_DOCLOG)
	
		cMsg := "Documento: "+ AllTrim(SDS->DS_DOC) +"/"+ AllTrim(SDS->DS_SERIE) +" "
		cMsg += "Fornecedor: "+ AllTrim(SDS->DS_FORNEC) +"/"+ AllTrim(SDS->DS_LOJA) +" "
		cMsg += "Emissão: "+ DToC(SDS->DS_EMISSA) +" " 
		cMsg += "bloqueado por "+ AllTrim(SDS->DS_DOCLOG) 
		
		U_SCEMail(cEmail, "Aviso de bloqueio de NF-e [TOTVS Colaboracao]", cMsg, "")
	
	ElseIf lBloq
		
		SDS->(RecLock("SDS", .F.))
			SDS->DS_STATUS := "E"
			SDS->DS_DOCLOG := "Bloqueado por processo"
		SDS->(MsUnlock())
		
	EndIf
			
	RestArea(aAreaSDT)
	RestArea(aAreaSDS)
	RestArea(aArea)

Return Nil

Static Function RetDevArm(oProd, nItem, lBloq)

	
	Local cIndAdProd	:= If(ValType(XmlChildEx(oProd, "_INFADPROD")) == "O", oProd:_INFADPROD:TEXT, "")
	Local cNFOrig 		:= "" 
	Local cSerNFOrig	:= ""
	Local cItem 		:= ""
	Local cSerNFOrig	:= SuperGetMV("ZZ_SERNFOR", .F., "")
	//	Local cNFOrig 		:= If(ValType(XmlChildEx(oProd:_Prod, "_XPED")) == "O", oProd:_PROD:_XPED:TEXT, "") 
	Local cQuery  		:= ""
	
	
	
	InfNFOrig(AllTrim(cIndAdProd), @cNFOrig, @cSerNFOrig, @cItem)

	If !Empty(cNFOrig) .And. !Empty(cItem)

		cQuery := "UPDATE "+ RetSqlName("SDT") +" "+ CRLF
		cQuery += "SET "+ CRLF
		cQuery += "		DT_NFORI = '"+ cNFOrig +"', "+ CRLF
		cQuery += "		DT_SERIORI = '"+ cSerNFOrig +"', "+ CRLF
		cQuery += "		DT_ITEMORI = '"+ cItem +"' "+ CRLF
		cQuery += "WHERE "+ CRLF
		cQuery += "		D_E_L_E_T_ = ' ' "+ CRLF
		cQuery += "		AND DT_FILIAL = '"+ FWxFilial("SDT") +"' "+ CRLF
		cQuery += "		AND DT_FORNEC = '"+ SDS->DS_FORNEC +"' "+ CRLF
		cQuery += "		AND DT_LOJA = '"+ SDS->DS_LOJA +"' "+ CRLF
		cQuery += "		AND DT_DOC = '"+ SDS->DS_DOC +"' "+ CRLF
		cQuery += "		AND DT_SERIE = '"+ SDS->DS_SERIE +"' "+ CRLF
		cQuery += "		AND DT_ITEM = '"+ PADL(nItem, TamSX3("DT_ITEMPC")[1], "0") +"' "
		
		If TcSqlExec(cQuery) != 0

			SDS->(RecLock("SDS", .F.))
				SDS->DS_STATUS := "E"
				SDS->DS_DOCLOG := "Nota de origem não encontrada (Retorno de Armazenagem)"
			SDS->(MsUnlock())

			UserException(TCSQLError())

		EndIf

	Else

		SDS->(RecLock("SDS", .F.))
			SDS->DS_STATUS := "E"
			SDS->DS_DOCLOG := "Nota de origem não informada (Retorno de Armazenagem)"
		SDS->(MsUnlock())

	EndIf

Return Nil	

Static Function TransFil(oProd, lBloq)
	
	Local cSerNFOrig	:= SuperGetMV("ZZ_SERNFOR", .F., "")
	Local cNFOrig 		:= If(ValType(XmlChildEx(oProd:_Prod, "_XPED")) == "O", oProd:_PROD:_XPED:TEXT, "") 
	Local cItem 		:= If(ValType(XmlChildEx(oProd:_Prod, "_NITEMPED")) == "O", oProd:_PROD:_NITEMPED:TEXT, "") 
	Local cQuery  		:= ""

	If !Empty(cNFOrig)

		cQuery := "UPDATE "+ RetSqlName("SDT") +" "+ CRLF
		cQuery += "SET "+ CRLF
		cQuery += "		DT_NFORI = '"+ AllTrim(cNFOrig) +"', "+ CRLF
		cQuery += "		DT_SERIORI = '"+ cSerNFOrig +"', "+ CRLF
		cQuery += "		DT_ITEMORI = '"+ cItem +"' "+ CRLF
		cQuery += "WHERE "+ CRLF
		cQuery += "		D_E_L_E_T_ = ' ' "+ CRLF
		cQuery += "		AND DT_FILIAL = '"+ FWxFilial("SDT") +"' "+ CRLF
		cQuery += "		AND DT_FORNEC = '"+ SDS->DS_FORNEC +"' "+ CRLF
		cQuery += "		AND DT_LOJA = '"+ SDS->DS_LOJA +"' "+ CRLF
		cQuery += "		AND DT_DOC = '"+ SDS->DS_DOC +"' "+ CRLF
		cQuery += "		AND DT_SERIE = '"+ SDS->DS_SERIE +"' "+ CRLF
		cQuery += "		AND DT_ITEM = '"+ PADL(nItem, TamSX3("DT_ITEMPC")[1], "0") +"' "
		
		If TcSqlExec(cQuery) != 0

			SDS->(RecLock("SDS", .F.))
				SDS->DS_STATUS := "E"
				SDS->DS_DOCLOG := "Nota de origem não informada (Transferência de Filiais)"
			SDS->(MsUnlock())

			UserException(TCSQLError())

		EndIf

	Else
				
		SDS->(RecLock("SDS", .F.))
			SDS->DS_STATUS := "E"
			SDS->DS_DOCLOG := "Nota de origem não informada (Transferência de Filiais)"
		SDS->(MsUnlock())

	EndIf
	
Return Nil

Static Function DevBen(oProd, nItem, lBloq)
	
	Local cIndAdProd	:= If(ValType(XmlChildEx(oProd, "_INFADPROD")) == "O", oProd:_INFADPROD:TEXT, "")
	Local cNFOrig 		:= "" 
	Local cSerNFOrig	:= ""
	Local cItem 		:= ""
	Local cLote			:= ""
	Local cVldLote		:= ""
	Local cProcWMS		:= ""
	Local cLocal		:= ""
	Local cQuery  		:= ""
	
	InfNFOrig(AllTrim(cIndAdProd), @cNFOrig, @cSerNFOrig, @cItem, @cLote, @cVldLote, @cProcWMS)
	
	             
	cValidLot := SUBSTR(cVldLote,7,4) + SUBSTR(cVldLote,4,2) + SUBSTR(cVldLote,1,2)
	
	If !Empty(cNFOrig) .And. !Empty(cItem)
		
		//cLocal := ArmProcWMS(cProcWMS)
		
		cQuery := "UPDATE "+ RetSqlName("SDT") +" "+ CRLF
		cQuery += "SET "+ CRLF
		cQuery += "		DT_NFORI = '"+ cNFOrig +"', "+ CRLF
		cQuery += "		DT_SERIORI = '"+ cSerNFOrig +"', "+ CRLF
		cQuery += "		DT_ITEMORI = '"+ cItem +"', "+ CRLF
		//cQuery += "		DT_LOCAL = '"+ cLocal +"', "+ CRLF
		
		
		cQuery += "		DT_LOTE = '"+ cLote +"', "+ CRLF
		cQuery += "		DT_DTVALID = '"+ cValidLot +"' "+ CRLF
		cQuery += "WHERE "+ CRLF
		cQuery += "		D_E_L_E_T_ = ' ' "+ CRLF
		cQuery += "		AND DT_FILIAL = '"+ FWxFilial("SDT") +"' "+ CRLF
		cQuery += "		AND DT_FORNEC = '"+ SDS->DS_FORNEC +"' "+ CRLF
		cQuery += "		AND DT_LOJA = '"+ SDS->DS_LOJA +"' "+ CRLF
		cQuery += "		AND DT_DOC = '"+ SDS->DS_DOC +"' "+ CRLF
		cQuery += "		AND DT_SERIE = '"+ SDS->DS_SERIE +"' "+ CRLF
		cQuery += "		AND DT_ITEM = '"+ PADL(nItem, TamSX3("DT_ITEMPC")[1], "0") +"' "
		
		If TcSqlExec(cQuery) != 0

			SDS->(RecLock("SDS", .F.))
				SDS->DS_STATUS := "E"
				SDS->DS_DOCLOG := "Nota/item de origem não informada (Devolução/Beneficiamento)"
			SDS->(MsUnlock())

			UserException(TCSQLError())
		
		Else
			
			If !Empty(cProcWMS)
			
				SDS->(RecLock("SDS", .F.))
					SDS->DS_XWMSPRC := cProcWMS
				SDS->(MsUnlock())
			
			EndIf
			
			lBloq := .F.
			
		EndIf

	Else
				
		SDS->(RecLock("SDS", .F.))
			SDS->DS_STATUS := "E"
			SDS->DS_DOCLOG := "Nota/item de origem não informada (Devolução/Beneficiamento)"
		SDS->(MsUnlock())

	EndIf
	
Return Nil

Static Function VldInfNF(oProd, oFatura, lBloq, cDoc, cSerie, cClifor, cLoja, nItem1)
	
	Local aVencimentos	:= {} 
	Local cPed 			:= If(ValType(XmlChildEx(oProd:_Prod, "_XPED")) == "O", oProd:_PROD:_XPED:TEXT, "") 
	Local cItemPed		:= If(ValType(XmlChildEx(oProd:_Prod, "_NITEMPED")) == "O", oProd:_PROD:_NITEMPED:TEXT, "") 
	Local cAliasQry		:= GetNextAlias()
	Local cCondPag		:= ""
	Local cQuery  		:= ""
	Local dEmissao		:= ""
	Local nQtdXML		:= Val(oProd:_Prod:_qCom:Text)
	Local nPrcXML 		:= Val(oProd:_Prod:_vUnCom:Text)
	Local nValFat		:= 0
	Local nItem			:= 0
	Local nPed			:= 0
	Local nItemPed		:= 0
	Local _aSDT			:= {}
	
	
	if !EMPTY(cPed) .AND. !EMPTY(cPed)
	
		nPed 		:= VAL(cPed)
		nItemPed	:= VAL(cItemPed)
		
		cPed 		:=PADL(CVALTOCHAR(nPed),TAMSX3("C7_NUM")[1],"0")
		cItemPed	:=PADL(CVALTOCHAR(nItemPed),TAMSX3("C7_ITEM")[1],"0")

		
	cQuery := "SELECT "+ CRLF
	cQuery += "		SC7.C7_QUANT, SC7.C7_PRECO, SC7.C7_COND, SC7.C7_EMISSAO "+ CRLF
	cQuery += "FROM "+ RetSqlTab("SC7") +" "+ CRLF
	cQuery += "WHERE "+ CRLF
	cQuery += "		"+ RetSqlDel("SC7") +" "+ CRLF
	cQuery += "		AND "+ RetSqlFil("SC7") +" "+ CRLF
	cQuery += "		AND SC7.C7_NUM = '"+ cPed +"' "+ CRLF
	cQuery += "		AND SC7.C7_ITEM = '"+ cItemPed +"' "
		
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasQry, .F., .T.)
	
	TcSetField(cAliasQry, "C7_EMISSAO", "D", 08, 00)
	
	If !(cAliasQry)->(Eof())
	
		cCondPag	:= (cAliasQry)->C7_COND
		dEmissao	:= (cAliasQry)->C7_EMISSAO
		
		//DT_FILIAL, DT_FORNEC, DT_LOJA, DT_DOC, DT_SERIE, DT_ITEM, R_E_C_N_O_, D_E_L_E_T_
		_aSDT 	:= GetArea('SDT')
		
		SDT->(DbSetOrder(8))
		If SDT->(DbSeek(XFILIAL('SDT')+cClifor+cLoja+cDoc+cSerie+PADL(nItem1, TamSX3("DT_ITEMPC")[1], "0") +"' "))
		//While !SDT->(EOF()) .AND. XFILIAL('SDT')+cClifor+cLoja+cDoc+cSerie == SDT->DT_FILIAL+SDT->DT_FORNEC+SDT->DT_LOJA+SDT->DT_DOC+SDT->DT_SERIE
		
		SDT->(RecLock("SDT", .F.))
				SDT->DT_PEDIDO := cPed
				SDT->DT_ITEMPC := cItemPed
		SDT->(MsUnlock())
		//SDT->(DBSKIP())
			
		//EndDo
		EndIf
		RestArea(_aSDT)
		
		
		If nQtdXML != (cAliasQry)->C7_QUANT
			
			SDS->(RecLock("SDS", .F.))
				SDS->DS_STATUS := "E"
				SDS->DS_DOCLOG := "Quantidade divergente do pedido de compras"
			SDS->(MsUnlock())
			
		ElseIf nPrcXML != (cAliasQry)->C7_PRECO
			
			SDS->(RecLock("SDS", .F.))
				SDS->DS_STATUS := "E"
				SDS->DS_DOCLOG := "Preço divergente do pedido de compras"
			SDS->(MsUnlock())
			
		Else
			
			If oFatura == Nil
				
				SDS->(RecLock("SDS", .F.))
					SDS->DS_STATUS := "E"
					SDS->DS_DOCLOG := "Fatura não informada no XML"
				SDS->(MsUnlock())
				
			Else
			
				nFaturas 	 := IIf(ValType(oFatura:_Dup) == "A", Len(oFatura:_Dup), 0)
				nValFat		 := If(ValType(oFatura:_Fat:_vLiq:TEXT) == "C", Val(oFatura:_Fat:_vLiq:TEXT), 0) 
				aVencimentos := Condicao(nValFat, (cAliasQry)->C7_COND,, (cAliasQry)->C7_EMISSAO)
				
				If nFaturas <> Len(aVencimentos)
					
					SDS->(RecLock("SDS", .F.))
						SDS->DS_STATUS := "E"
						SDS->DS_DOCLOG := "Quantidade de parcelas divergente da condição de pagamento"
						
					SDS->(MsUnlock())
					
				Else
					
					For nItem := 1 To nFaturas
						
						If aVencimentos[nItem, 1] != ConvDate(oFatura:_Dup[nItem]:_dVenc:TEXT)
							
							SDS->(RecLock("SDS", .F.))
								SDS->DS_STATUS := "E"
								SDS->DS_DOCLOG := "Vencimento divergente da condição de pagamento"
							SDS->(MsUnlock())
							
						EndIf
						
					Next nItem
					
				EndIf
				
			EndIf
			
		EndIf
			
	EndIf
	
	EndIf
		
	(cAliasQry)->(DbCloseArea())
	
Return Nil

Static Function ConvDate(cData)

	Local dData := Nil
	
	cData  := StrTran(cData, "-", "")
	dData  := SToD(cData)

Return dData

Static Function InfNFOrig(cIndAdProd, cNFOrig, cSerNFOrig, cItem, cLote, cVldLote, cProcWMS)
	
	Local aInfOrig := {}
	
	If At("[", cIndAdProd) > 0 .And. At("]", cIndAdProd) > 0
		cIndAdProd 	:= SubStr(cIndAdProd, At("[", cIndAdProd) + 1, At("]", cIndAdProd) - 2)
	EndIf
	 
	aInfOrig := StrTokArr2(cIndAdProd, "|", .T.)
	
	If Len(aInfOrig) >= 1
		cNFOrig := Substr(AllTrim(aInfOrig[1]), 4, 6)
	EndIf
	
	If Len(aInfOrig) >= 2
		cSerNFOrig := AllTrim(aInfOrig[2])
	EndIf
	
	If Len(aInfOrig) >= 3
		cItem := STRZERO(Val(aInfOrig[3]), 2, 0)
	EndIf
	
	If Len(aInfOrig) >= 4
		cLote := AllTrim(aInfOrig[4])
	EndIf
	
	If Len(aInfOrig) >= 5
		cVldLote := AllTrim(aInfOrig[5])
	EndIf
	
	If Len(aInfOrig) >= 6
		cProcWMS := AllTrim(aInfOrig[6])
	EndIf
	
Return Nil

Static Function ArmProcWMS(cProcWMS)
	
	Local cAlias	:= GetNextAlias()
	Local cQuery	:= ""
	Local cLocal 	:= ""
	
	cQuery := "SELECT "+ CRLF
	cQuery += "		ZWO.ZWO_ARMENT "+ CRLF
	cQuery += "FROM "+ RetSqlTab("ZWO") +" "+ CRLF
	cQuery += "WHERE "+ CRLF
	cQuery += "		"+ RetSqlDel("ZWO") +" "+ CRLF
	cQuery += "		AND "+ RetSqlFil("ZWO") +" "+ CRLF
	cQuery += "		AND ZWO.ZWO_CODIGO = '"+ cProcWMS +"' "
	ConOut("ArmProcWMS -> "+ cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlias, .F., .T.)
	
	If !(cAlias)->(Eof())
		cLocal := (cAlias)->ZWO_ARMENT
	EndIf
	
	(cAlias)->(DbCloseArea())
	
Return cLocal

Static Function VendaSC(oProd, nItem, lBloq)

	Local cIndAdProd	:= If(ValType(XmlChildEx(oProd, "_INFADPROD")) == "O", oProd:_INFADPROD:TEXT, "")
	Local cNFOrig 		:= "" 
	Local cSerNFOrig	:= ""
	Local cItem 		:= ""
	Local cLote			:= ""
	Local cVldLote		:= ""
	Local cProcWMS		:= ""
	Local cLocal		:= ""
	Local cQuery  		:= ""
	
	InfNFOrig(AllTrim(cIndAdProd), @cNFOrig, @cSerNFOrig, @cItem, @cLote, @cVldLote, @cProcWMS)
	ConOut("cProcWMS -> "+ cProcWMS)
	cLocal := ArmProcWMS(cProcWMS)
		
	cQuery := "UPDATE "+ RetSqlName("SDT") +" "+ CRLF
	cQuery += "SET "+ CRLF
	cQuery += "		DT_LOCAL = '"+ cLocal +"', "+ CRLF
	cQuery += "		DT_LOTE = '"+ cLote +"', "+ CRLF
	cQuery += "		DT_DTVALID = '"+ cVldLote +"' "+ CRLF
	cQuery += "WHERE "+ CRLF
	cQuery += "		D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += "		AND DT_FILIAL = '"+ FWxFilial("SDT") +"' "+ CRLF
	cQuery += "		AND DT_FORNEC = '"+ SDS->DS_FORNEC +"' "+ CRLF
	cQuery += "		AND DT_LOJA = '"+ SDS->DS_LOJA +"' "+ CRLF
	cQuery += "		AND DT_DOC = '"+ SDS->DS_DOC +"' "+ CRLF
	cQuery += "		AND DT_SERIE = '"+ SDS->DS_SERIE +"' "+ CRLF
	cQuery += "		AND DT_ITEM = '"+ PADL(nItem, TamSX3("DT_ITEMPC")[1], "0") +"' "
	ConOut("cProcWMS 2 -> "+ cQuery)	
	If TcSqlExec(cQuery) != 0

		SDS->(RecLock("SDS", .F.))
			SDS->DS_STATUS := "E"
			SDS->DS_DOCLOG := "Local/Lote/Validade não informada (Venda Sanchez)"
		SDS->(MsUnlock())

		UserException(TCSQLError())
		
	Else
			
		If !Empty(cProcWMS)
			
			SDS->(RecLock("SDS", .F.))
				SDS->DS_XWMSPRC := cProcWMS
			SDS->(MsUnlock())
		
		EndIf
			
		lBloq := .F.
			
	EndIf

Return Nil