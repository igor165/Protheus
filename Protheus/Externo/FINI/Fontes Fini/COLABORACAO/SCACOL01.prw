#Include "Protheus.ch"
#Include "ParmType.ch"

/*/{Protheus.doc} SCACOL01

Rotina para determinar qual o produto deverá ser utilizado na entrada 

@type		function
@author 	Ectore Cecato - Totvs IP Jundiaí
@since 		22/11/2018
@version 	Protheus 12 - Totvs Colaboração

@return 	caracter, Código do produto

@see 		A140IPRD_PE.PRW

/*/

User Function SCACOL01()

	Local cCliFor 		:= ParamIXB[1]
	Local cLoja 		:= ParamIXB[2]
	Local cProdXML 		:= ParamIXB[3]
	Local oXML 			:= ParamIXB[4] 
	Local cRef 			:= Alltrim(ParamIXB[5])
	Local cProd			:= ""
	Local cCFOPTrFil	:= AllTrim(SuperGetMV("ZZ_CFOTRFL", .F., ""))
	Local cCFOPRetAr	:= AllTrim(SuperGetMV("ZZ_CFORETA", .F., ""))
	Local cFornSC		:= AllTrim(SuperGetMV("ZZ_FORNSC",  .F., ""))
		
	If (AllTrim(oXML:_PROD:_CFOP:TEXT) $ cCFOPRetAr) .Or. (AllTrim(oXML:_PROD:_CFOP:TEXT) $ cCFOPTrFil) //Retorno remessa de armazenagem 
		cProd := cProdXML 
	ElseIf cRef == "SA7" //Devolução/Beneficiamento
		
		If cCliFor $ cFornSC
			cProd := cProdXML
		Else
			cProd := ProdNFS(oXML)
		EndIf
		
	Else
		
		If cCliFor $ cFornSC //Venda Sanchez x Fini
			cProd := cProdXML 
		
		Else
			cProd := ProdPC(oXML)
		EndIf
	EndIf
			
Return cProd

Static Function ProdNFS(oProd)
	
	Local cSerNFOrig	:= SuperGetMV("ZZ_SERNFOR", .F., "")
	Local cNFOrig		:= If(ValType(XmlChildEx(oProd:_Prod, "_XPED")) == "O", oProd:_PROD:_XPED:TEXT, "") 
	Local cItemNF		:= If(ValType(XmlChildEx(oProd:_Prod, "_NITEMPED")) == "O", oProd:_PROD:_NITEMPED:TEXT, "")
	Local cAliasQry		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cProd 		:= ""
	
	cQuery := "SELECT "+ CRLF
	cQuery += "		SD2.D2_COD "+ CRLF
	cQuery += "FROM "+ RetSqlTab("SD2") +" "+ CRLF
	cQuery += "WHERE "+ CRLF
	cQuery += "		"+ RetSqlDel("SD2") +" "+ CRLF
	cQuery += "		AND "+ RetSqlFil("SD2") +" "+ CRLF
	cQuery += "		AND SD2.D2_DOC = '"+ cNFOrig +"' "+ CRLF
	cQuery += "		AND SD2.D2_ITEM = '"+ cItemNF +"' "
	
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasQry, .F., .T.)
	
	If !(cAliasQry)->(Eof())
		cProd := (cAliasQry)->D2_COD
	EndIf
	
	(cAliasQry)->(DbCloseArea())
	
Return cProd

Static Function ProdPC(oProd)
	
	Local cNFOrig		:= If(ValType(XmlChildEx(oProd:_Prod, "_XPED")) == "O", oProd:_PROD:_XPED:TEXT, "") 
	Local cItemNF		:= If(ValType(XmlChildEx(oProd:_Prod, "_NITEMPED")) == "O", oProd:_PROD:_NITEMPED:TEXT, "")
	Local cAliasQry		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cProd 		:= ""
	Local nNFOrig		:= 0
	Local NItemNF		:= 0
	
	if !EMPTY(cNFOrig) .AND. !EMPTY(cItemNF)
	 	
		nNFOrig := VAL(cNFOrig)
		NItemNF := VAL(cItemNF)
		
		cNFOrig :=PADL(CVALTOCHAR(nNFOrig),TAMSX3("C7_NUM")[1],"0")
		cItemNF :=PADL(CVALTOCHAR(NItemNF),TAMSX3("C7_ITEM")[1],"0")

	
	cQuery := "SELECT "+ CRLF
	cQuery += "		SC7.C7_PRODUTO "+ CRLF
	cQuery += "FROM "+ RetSqlTab("SC7") +" "+ CRLF
	cQuery += "WHERE "+ CRLF
	cQuery += "		"+ RetSqlDel("SC7") +" "+ CRLF
	cQuery += "		AND "+ RetSqlFil("SC7") +" "+ CRLF
	cQuery += "		AND SC7.C7_NUM = '"+ cNFOrig +"' "+ CRLF
	cQuery += "		AND SC7.C7_ITEM = '"+ cItemNF +"' "
		
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasQry, .F., .T.)
	
	If !(cAliasQry)->(Eof())
		cProd := ALLTRIM((cAliasQry)->C7_PRODUTO)
	EndIf
	
	(cAliasQry)->(DbCloseArea())
	
	endif
	
Return cProd