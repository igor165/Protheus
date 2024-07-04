#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"

WSRESTFUL OFIA140 Description "SEEDZ" 

	WSDATA USER    As Base64Binary		// Usuario Protheus
	WSDATA PASS    As Base64Binary		// Senha Protheus
	WSDATA INICIAL As String
	WSDATA FINAL   As String
	WSDATA EMP     As String
	WSDATA FIL     As String

WSMETHOD GET DESCRIPTION "Relacão de Vendas" WSSYNTAX "/USUARIO || SENHA || DATA INI || DATA FIM || EMPRESA || FILIAL /{}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE USER, PASS,EMP, FIL, INICIAL, FINAL WSSERVICE OFIA140

Local cError     := ""	// Mensagem de erro de retorno
Local aArea      := GetArea()
Local cQuery     := ""
Local cAlias     := GetNextAlias()
Local lRest      := .T.
Local cUser      := Self:USER
Local cPass      := Self:PASS
Local cInicial   := Self:INICIAL
Local cFinal     := Self:FINAL
Local cCdEmp     := Self:EMP
Local cCdFil     := Self:FIL
Local aMovtos    := {}
Local oResponse  := JsonObject():New()
Local oSql       := DMS_SqlHelper():New() 
Local oWk        := Nil 
Local lBM_XSEEDZ := SBM->(FieldPos("BM_XSEEDZ")) > 0
Local oDpm       := DMS_DPM():New()
Local aSM0       := oDpm:GetFiliais()
Local nCont      := 0
Local lConout    := ( "OFIA140" $ GetNewPar("MV_XMILDBG", "NAO") )
Local dDataStart := GetNewPar("MV_XDPSUPA", date()-731)
Local cCampoSKU  := GetNewPar("MV_XJD0001", "")

Private cUsrWS   := ""	// Usuario Protheus
Private cPswWS   := ""	// Senha Protheus

lSkuFldOk := ! empty(cCampoSKU) .and. ("VV1_" = LEFT(cCampoSKU, 4) .or. "VV2_" = left(cCampoSKU, 4))

// define o tipo de retorno do método
::SetContentType("application/json")

If Empty(cUser) .or. Empty(cPass) .or.  Empty(cInicial) .or. Empty(cFinal)

	If Empty(cUser)
		SetRestFault(400,"Favor informar o usuário!")
	Endif
	If Empty(cPass)
		SetRestFault(400,"Favor informar a senha!")
	Endif
	If Empty(cInicial)
		SetRestFault(400,"Favor informar o período inicial!")
	Endif
	If Empty(cFinal)
		SetRestFault(400,"Favor informar o período final!")
	Endif

	Return(.F.)

else

	If sTod(cFinal) - sTod(cInicial) > 31
		SetRestFault(400,"Favor informar um periodo de no maximo 1 mes por Vez!")
		Return(.F.)
	Endif

	cUsrWS	:= cUser
	cPswWS	:= cPass

	If !OA1400012_Valida(cUsrWS,cPswWS,@cError)
		SetRestFault(400,@cError)
		Return(.F.)
	Endif  

	If !Empty(cCdFil)
		aSM0 := { {cCdFil} }
	Endif

	For nCont := 1 to Len(aSM0)

		cFilAnt := aSM0[nCont,1]

		// VENDAS
		cQuery	:= " SELECT 			  "
		cQuery	+= " 	D2_FILIAL FILIAL, "
		cQuery	+= " 	A1_CGC, "
		cQuery	+= " 	A1_CEP, "
		cQuery	+= " 	A3_CGC, "
		cQuery	+= " 	D2_QUANT, "
		cQuery	+= " 	D2_VALBRUT, "
		If lSkuFldOk
			cQuery += cCampoSKU + ","
		EndIf
		cQuery  += "  VV1_CHASSI, "
		cQuery	+= " 	D2_EMISSAO, "
		cQuery	+= " 	"+oSql:Concat({"D2_FILIAL","D2_DOC","D2_SERIE","D2_CLIENTE","D2_LOJA","D2_ITEM"})+" UUID, "
		cQuery	+= " 	"+oSql:Concat({"D2_FILIAL", "'-'", "D2_DOC", "'-'", "D2_SERIE"})+" NUMNF, "
		cQuery	+= " 	F2_HORA, "
		cQuery  += "  D2_COD PRODUTO, "
		cQuery  += "  'ITEM DE ESTOQUE' CATEGORIA, "
		cQuery  += "  CASE WHEN BM_TIPGRU = '7 ' "
		cQuery  += "  THEN 'MAQUINA' "
		cQuery  += "  ELSE  "
		cQuery  += "       CASE WHEN BM_TIPGRU = '4 ' "
		cQuery  += "       THEN 'SERVICO' "
		cQuery  += "       ELSE "
		cQuery  += "            CASE WHEN VE1_MARFAB = 'JD ' "
		cQuery  += "            THEN 'PEÇAS JD ' "
		cQuery  += "            ELSE 'PEÇAS NÃO JD' "
		cQuery  += "            END "
		cQuery  += "       END "
		cQuery  += "  END TIPO "
		cQuery	+= " FROM "+oSql:NoLock('SD2', 'D2')
		cQuery	+= " JOIN "+oSql:NoLock('SF4', 'F4') +" ON F4_FILIAL  = '"+xFilial("SF4")+"' AND F4_CODIGO  = D2_TES     AND F4_OPEMOV ='05'      AND F4.D_E_L_E_T_ = ' ' "  //F4_OPEMOV=05 (TES de venda)
		cQuery	+= " JOIN "+oSql:NoLock('SF2', 'F2') +" ON F2_FILIAL  = D2_FILIAL            AND F2_DOC     = D2_DOC     AND D2_SERIE  = F2_SERIE AND F2_CLIENTE    = D2_CLIENTE AND F2_LOJA = D2_LOJA  AND F2.D_E_L_E_T_ = ' ' "
		cQuery	+= " JOIN "+oSql:NoLock('SA1', 'A1') +" ON A1_FILIAL  = '"+xFilial("SA1")+"' AND A1_COD     = D2_CLIENTE AND A1_LOJA   = D2_LOJA  AND A1.D_E_L_E_T_ = ' ' "
		cQuery	+= " JOIN "+oSql:NoLock('SB1', 'B1') +" ON B1_FILIAL  = '"+xFilial("SB1")+"' AND B1_COD     = D2_COD     AND B1.D_E_L_E_T_  = ' ' "
		cQuery	+= " JOIN "+oSql:NoLock('SBM', 'BM') +" ON BM_FILIAL  = '"+xFilial("SBM")+"' AND BM_GRUPO   = B1_GRUPO   AND BM.D_E_L_E_T_  = ' ' "
		If lBM_XSEEDZ
			cQuery	+= " AND BM_XSEEDZ = '1'  "
		Endif
		cQuery  += "  LEFT JOIN "+oSql:NoLock('VV1')  +" ON VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1_CHAINT = B1_CODITE  AND VV1.D_E_L_E_T_ = ' ' "
		cQuery  += "  LEFT JOIN "+oSql:NoLock('VV2')  +" ON VV2_FILIAL = '"+xFilial("VV2")+"' AND VV2_CODMAR = VV1_CODMAR AND VV2_MODVEI = VV1_MODVEI AND VV2.D_E_L_E_T_=' ' "
		cQuery	+= "  LEFT JOIN "+oSql:NoLock('VE1', 'VE1') +" ON VE1_CODMAR = BM_CODMAR AND VE1_FILIAL =  BM_FILIAL AND VE1.D_E_L_E_T_ = ' '	 "
		cQuery	+= "     JOIN "+oSql:NoLock('SA3', 'A3') +" ON A3_COD = F2_VEND1 AND A3_FILIAL = '"+xFilial("SA3")+"' AND A3.D_E_L_E_T_ = ' ' "
		cQuery	+= "    WHERE D2.D_E_L_E_T_ = ' ' "
		cQuery	+= "      AND D2_EMISSAO BETWEEN '"+cInicial+"' AND '"+cFinal+"' AND D2_FILIAL = '"+xFilial("SD2")+"' "
		cQuery  += "      AND D2_EMISSAO >= '"+DToS(dDataStart)+"' "
		If lConout
		   conout(cquery)
		Endif
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAlias , .T., .F. )

		While (cAlias)->(!Eof())
			oWk:= JsonObject():new()
			
			oWk["CnpjConcessionaria"] := AllTrim(Posicione("SM0",1,cCdEmp+(cAlias)->FILIAL,"M0_CGC"))
			oWk["CepCliente"]         := AllTrim((cAlias)->A1_CEP)
			oWk["CpfCliente"]         := AllTrim((cAlias)->A1_CGC)
			oWk["CpfVendedor"]        := AllTrim((cAlias)->A3_CGC)
			oWk["Categoria"]          := AllTrim((cAlias)->CATEGORIA)
			oWk["Tipo"]               := AllTrim((cAlias)->TIPO)
			oWk["Produto"]            := AllTrim((cAlias)->PRODUTO)
			oWk["Quantidade"]         := (cAlias)->D2_QUANT
			oWk["Valor"]              := (cAlias)->D2_VALBRUT
			oWk["Data"]               := AllTrim(DTOC(STOD((cAlias)->D2_EMISSAO)))
			oWk["Hora"]               := AllTrim((cAlias)->F2_HORA)
			oWk["uuid"]               := STRTRAN(AllTrim((cAlias)->UUID), " ", "#")
			oWk["NumerNota"]          := AllTrim((cAlias)->NUMNF)
			if ! empty(AllTrim((cAlias)->VV1_CHASSI))
				oWk["Chassi"]             := alltrim((cAlias)->VV1_CHASSI)
				oWk["ModeloExtraido"]     := Right(left( alltrim((cAlias)->VV1_CHASSI) ,7),4)
			endif
			If lSkuFldOk
				oWk["SKU"]              := AllTrim((cAlias)->&(cCampoSKU))
			else
				oWk["SKU"]              := ""
			endif
			AADD(aMovtos,oWk)
			oWk:= Nil
							
			(cAlias)->(Dbskip())
		Enddo
		(cAlias)->(DbCloseArea())

		// DEVOLUÇÔES
		cQuery	:= " SELECT 			  "
		cQuery	+= " 	D1_FILIAL FILIAL, "
		cQuery	+= " 	A1_CGC, "
		cQuery	+= " 	A1_CEP, "
		cQuery	+= " 	A3_CGC, "
		cQuery	+= " 	D1_QUANT, "
		If lSkuFldOk
			cQuery += cCampoSKU + ","
		EndIf
		cQuery  += "  VV1_CHASSI, "
		cQuery	+= " 	D1_TOTAL - D1_VALDESC as D1_TOTAL, "
		cQuery	+= " 	D1_DTDIGIT, "
		cQuery	+= " 	F1_HORA, "
		cQuery	+= " 	"+oSql:Concat({"D1_FILIAL","D1_DOC","D1_SERIE","D1_FORNECE","D1_LOJA","D1_ITEM","D1_FORMUL","D1_ITEMGRD"})+" UUID, "
		cQuery	+= " 	"+oSql:Concat({"D1_FILIAL", "'-'", "D1_DOC", "'-'", "D1_SERIE"})+" NUMNF, "
		cQuery  += "  D1_COD PRODUTO, "
		cQuery  += "  'ITEM DE ESTOQUE' CATEGORIA, "
		cQuery  += "  CASE WHEN BM_TIPGRU = '7 ' "
		cQuery  += "  THEN 'MAQUINA' "
		cQuery  += "  ELSE  "
		cQuery  += "       CASE WHEN BM_TIPGRU = '4 ' "
		cQuery  += "       THEN 'SERVICO' "
		cQuery  += "       ELSE "
		cQuery  += "            CASE WHEN VE1_MARFAB = 'JD ' "
		cQuery  += "            THEN 'PEÇAS JD ' "
		cQuery  += "            ELSE 'PEÇAS NÃO JD' "
		cQuery  += "            END "
		cQuery  += "       END "
		cQuery  += "  END TIPO "
		cQuery	+= " FROM "+oSql:NoLock('SD1', 'D1')
		cQuery	+= " JOIN "+oSql:NoLock('SF4', 'F4') +" ON F4_FILIAL  = '"+xFilial("SF4")+"' AND F4_CODIGO  = D1_TES     AND F4_OPEMOV = '09'        AND F4.D_E_L_E_T_ = ' ' "  //F4_OPEMOV=09 (TES de devolução)
		cQuery	+= " JOIN "+oSql:NoLock('SF2', 'F2') +" ON F2_FILIAL  = D1_FILIAL            AND F2_DOC     = D1_NFORI   AND F2_SERIE = D1_SERIORI   AND F2.D_E_L_E_T_ = ' ' "
		cQuery	+= " JOIN "+oSql:NoLock('SF1', 'F1') +" ON F1_FILIAL  = D1_FILIAL            AND F1_DOC     = D1_DOC     AND F1_SERIE = D1_SERIE     AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND D1.D_E_L_E_T_ = ' ' "
		cQuery	+= " JOIN "+oSql:NoLock('SA1', 'A1') +" ON A1_FILIAL  = '"+xFilial("SA1")+"' AND A1_COD     = F2_CLIENTE AND A1_LOJA  = F2_LOJA      AND A1.D_E_L_E_T_ = ' ' "
		cQuery	+= " JOIN "+oSql:NoLock('SB1', 'B1') +" ON B1_FILIAL  = '"+xFilial("SB1")+"' AND B1_COD     = D1_COD     AND B1.D_E_L_E_T_  = ' ' "
		cQuery	+= " JOIN "+oSql:NoLock('SBM', 'BM') +" ON BM_FILIAL  = '"+xFilial("SBM")+"' AND BM_GRUPO   = B1_GRUPO   AND BM.D_E_L_E_T_  = ' ' "
		cQuery += "  LEFT JOIN "+oSql:NoLock('VV1')  +" ON VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1_CHAINT = B1_CODITE  AND VV1.D_E_L_E_T_ = ' ' "
		cQuery += "  LEFT JOIN "+oSql:NoLock('VV2')  +" ON VV2_FILIAL = '"+xFilial("VV2")+"' AND VV2_CODMAR = VV1_CODMAR AND VV2_MODVEI = VV1_MODVEI AND VV2.D_E_L_E_T_=' ' "
		If lBM_XSEEDZ
			cQuery	+= " AND BM_XSEEDZ = '1' "
		Endif
		cQuery	+= " LEFT JOIN "+oSql:NoLock('VE1', 'VE1') +" ON VE1_CODMAR = BM_CODMAR           AND VE1_FILIAL =  BM_FILIAL AND VE1.D_E_L_E_T_ = ' ' "
		cQuery	+= "      JOIN "+oSql:NoLock('SA3', 'A3')  +" ON A3_FILIAL = '"+xFilial("SA3")+"' AND A3_COD     = F2_VEND1   AND  A3.D_E_L_E_T_ = ' ' "
		cQuery	+= "     WHERE D1_FILIAL = '"+xFilial("SD1")+"' "
		cQuery	+= "       AND D1_DTDIGIT BETWEEN '"+cInicial+"' AND '"+cFinal+"' "
		cQuery  += "       AND D1.D_E_L_E_T_ = ' ' "
		cQuery  += "       AND D1_DTDIGIT >= '"+DToS(dDataStart)+"' "
		If lConout
		   conout(cquery)
		Endif
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAlias , .T., .F. )

		While (cAlias)->(!Eof())
			oWk:= JsonObject():new()
			
			oWk["CnpjConcessionaria"] := AllTrim(Posicione("SM0",1,cCdEmp+(cAlias)->FILIAL,"M0_CGC"))
			oWk["CepCliente"]			    := AllTrim((cAlias)->A1_CEP)
			oWk["CpfCliente"]			    := AllTrim((cAlias)->A1_CGC)
			oWk["CpfVendedor"]			  := AllTrim((cAlias)->A3_CGC)
			oWk["Categoria"]			    := AllTrim((cAlias)->CATEGORIA)
			oWk["Tipo"]				        := AllTrim((cAlias)->TIPO)
			oWk["Produto"]				    := AllTrim((cAlias)->PRODUTO)
			oWk["Quantidade"]			    := (cAlias)->D1_QUANT * -1
			oWk["Valor"]				      := (cAlias)->D1_TOTAL * -1
			oWk["Data"]				        := AllTrim(DTOC(STOD((cAlias)->D1_DTDIGIT)))
			oWk["Hora"]				        := AllTrim((cAlias)->F1_HORA)
			oWk["uuid"]               := STRTRAN(AllTrim((cAlias)->UUID), " ", "#")
			oWk["NumerNota"]          := AllTrim((cAlias)->NUMNF)
			if ! empty(AllTrim((cAlias)->VV1_CHASSI))
				oWk["Chassi"]             := alltrim((cAlias)->VV1_CHASSI)
				oWk["ModeloExtraido"]     := Right(left( alltrim((cAlias)->VV1_CHASSI) ,7),4)
			endif
			If ! empty(cCampoSKU) .and. ("VV1_" = LEFT(cCampoSKU, 4) .or. "VV2_" = left(cCampoSKU, 4))
				oWk["SKU"]                := AllTrim((cAlias)->&(cCampoSKU))
			else
				oWk["SKU"]                := ""
			endif
			AADD(aMovtos,oWk)
			oWk:= Nil
							
			(cAlias)->(Dbskip())
		Enddo
		(cAlias)->(DbCloseArea())

		DbSelectarea("SF2")

	
	Next

	oResponse['Vendas'] := aMovtos
	
	::SetResponse(Noacento(oResponse:toJson()))
Endif

RestArea(aArea)

Return(.T.)


// Verificaçaõ do usuário e senha
Static Function OA1400012_Valida(cUsr,cPsw,cError)
	
PswOrder(1)
If PswSeek(cUsr,.T.)
	If !PswName(cPsw)
		cError := "TOTVS: Senha inválida!"
		Return(.F.)
	EndIf
Else
	PswOrder(2)
	If PswSeek(cUsr,.T.)
		If !PswName(cPsw)
			cError := "TOTVS: Senha inválida!"
			Return(.F.)
		EndIf
	Else
		cError := "TOTVS: Login inválido!"
		Return(.F.)
	Endif
Endif


SetModulo("SIGAFAT","FAT")
__cUserId := PswID()

//==========================================================================
//Seta o modo de compatibilidade                                           |
//==========================================================================
	
SetCompP10(.T.)

Return(.T.)