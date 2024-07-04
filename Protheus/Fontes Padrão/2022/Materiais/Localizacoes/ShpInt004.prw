#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"

/*/{Protheus.doc} ShpInt004
    Function used to update Shopify inventory
    @type  Function
    @author Yves Oliveira
    @since 03/04/2020    
    /*/
Function ShpInt004(aParam,_cProduct)
    Local cQuery    := ""
    Local cAlias    := ""
    Local oInvLevel := Nil
    Local nSaldo    := 0
    Local nRecnoSb2 := 0
    Local cLocalId  := ""
    Local dIni      := Nil
    Local dFim      := Date()
    Local dToday    := Date()
    Local _cEmpresa, _cFilial
    Local lHasItemPrice := .F. 

    Default _cProduct := ""

    FWLogMsg("INFO", , "SHOPIFY_INTEGRATION","SHOPIFY", FunName(), , STR0078)//"Start sending the balance of products to Shopify"

    If ValType(aParam) == "A"
        _cEmpresa    := aParam[1]
        _cFilial     := aParam[2]
    Else
        FWLogMsg("ERROR", , "SHOPIFY_INTEGRATION","SHOPIFY", FunName(), , STR0079)//"Company and branch not informed"
        Return
    EndIf
    
    FWLogMsg("INFO", , "SHOPIFY_INTEGRATION","SHOPIFY", FunName(), , STR0083 + " --> " + STR0080 + ": " + _cEmpresa + " " + STR0081 + ": " + _cFilial + " " + STR0082 + ": " + _cProduct)//"Parâmetros --> " + " Empresa: " + _cEmpresa + " Filial: " + _cFilial + " Produto: " + _cProduct


    //If  LockByName("ShpInt004", .F., .F. )

        If Select("SX2") == 0
            RpcSetType(3)
            If !RpcSetEnv(_cEmpresa,_cFilial)
                FWLogMsg("ERROR", , "SHOPIFY_INTEGRATION","SHOPIFY", FunName(), , STR0084 + ' [' + STR0080 + '/' + STR0081 + ': ' + _cEmpresa + '/' + _cFilial + ']')//Ambiente invalido [empresa/filial: ' + _cEmpresa + '/' + _cFilial + ']
            EndIf
        EndIf
        
        FWLogMsg("INFO", , "SHOPIFY_INTEGRATION","SHOPIFY", FunName(), , STR0001)//"Integrating with Shopify..."


        cLocalId := ShpGetLoId()

        If Empty(cLocalId)
            ShpSaveErr("", "", "", STR0015, "", "", "", "") // "Default warehouse not defined"
            FWLogMsg("INFO", , "SHOPIFY_INTEGRATION","SHOPIFY", FunName(), , STR0015)//"Default warehouse not defined"
            BREAK
        EndIf

        cAlias    := GetNextAlias()

        If Select(cAlias) > 0
            (cAlias)->(DbCloseArea())
        EndIf
        
        cQuery += "SELECT" + CRLF
        cQuery += "    SB1.B1_COD," + CRLF
        cQuery += "    A1D_INV.A1D_ID RECNOSB2," + CRLF
        cQuery += "    A1D_INV.A1D_IDPAI RECNOSB1," + CRLF
        cQuery += "    A1D_PROD.A1D_IDEXT PRODUCT_ID," + CRLF
        cQuery += "    A1D_INV.A1D_IDEXT INVENTORY_ID," + CRLF
        cQuery += "    A1D_INV.A1D_IDEXT INVENTORY_ID," + CRLF
        cQuery += "    A1K_INI," + CRLF
        cQuery += "    A1K_FIM," + CRLF
        cQuery += "    SB1.B1_MSBLQL" + CRLF    
        cQuery += "FROM" + CRLF
        cQuery += "    " + RetSqlName("A1D") + " A1D_PROD," + CRLF
        cQuery += "    " + RetSqlName("A1D") + " A1D_INV," + CRLF 
        cQuery += "    " + RetSqlName("SB1") + " SB1," + CRLF 
        cQuery += "    " + RetSqlName("A1K") + " A1K" + CRLF 
        cQuery += "WHERE A1D_PROD.A1D_FILIAL = '" + xFilial("A1D") + "'" + CRLF
        cQuery += "AND A1D_PROD.D_E_L_E_T_ = ' '" + CRLF
        cQuery += "AND A1D_PROD.A1D_ALIAS  = '" + SHP_ALIAS_VARIANT + "'" + CRLF
        
        cQuery += "AND A1D_INV.A1D_FILIAL = '" + xFilial("A1D") + "'" + CRLF
        cQuery += "AND A1D_INV.D_E_L_E_T_ = ' '" + CRLF
        cQuery += "AND A1D_INV.A1D_ALIAS = '" + SHP_ALIAS_INVENTORY + "'" + CRLF
        cQuery += "AND A1D_INV.A1D_ALIASP = A1D_PROD.A1D_ALIAS" + CRLF
        cQuery += "AND A1D_INV.A1D_IDPAI = A1D_PROD.A1D_ID" + CRLF
        
        cQuery += "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'" + CRLF
        cQuery += "AND SB1.D_E_L_E_T_ = ' '" + CRLF
        cQuery += "AND SB1.R_E_C_N_O_ = TRIM(A1D_PROD.A1D_ID)" + CRLF

        If !Empty(_cProduct)
            cQuery += "AND SB1.B1_COD = '" + _cProduct + "'" + CRLF
        EndIf
        
        cQuery += "AND A1K.A1K_FILIAL = '" + xFilial("A1K") + "'" + CRLF
        cQuery += "AND A1K.D_E_L_E_T_ = ' '" + CRLF
        cQuery += "AND A1K.A1K_COD = SB1.B1_COD" + CRLF

        cQuery := ChangeQuery(cQuery)

        TcQuery cQuery new Alias &cAlias
        
        DbSelectArea(cAlias)
        (cAlias)->(DbGoTop())
        
        While !(cAlias)->(Eof())
            nRecnoSb2 := Val((cAlias)->RECNOSB2)
            DbSelectArea("SB2")
            SB2->(DbGoTo(nRecnoSb2))
            nSaldo := SaldoSb2()
            nSaldo := iif(nSaldo < 0, 0, nSaldo)
            oInvLevel := ShpInvLevel():New()
            oInvLevel:id         := (cAlias)->RECNOSB2
            oInvLevel:idExt      := ShpGetId(SHP_ALIAS_INVENTORY, (cAlias)->RECNOSB2, SHP_ALIAS_VARIANT, (cAlias)->RECNOSB1)
            oInvLevel:inventId   := AllTrim((cAlias)->INVENTORY_ID)
            oInvLevel:locationId := AllTrim(cLocalId)

            dIni := STOD((cAlias)->A1K_INI)
            dFim := STOD((cAlias)->A1K_FIM)
            dFim := Iif(Empty(dFim), Date(), dFim)

            //aqui eu verifico se tem preco de venda caso nao deixo o estoque zerado
            lHasItemPrice :=  lHasPrice(_cProduct)
            
            //If product not expired or not blocked, send the balance
            If lHasItemPrice .AND.  (dToday >=  dIni .And. dToday <= dFim) .And. (cAlias)->B1_MSBLQL <> "1" 
                oInvLevel:quantity   := nSaldo
            Else
                oInvLevel:quantity   := 0
            EndIf

            oInvLevel:requestToShopify()
            If !Empty(oInvLevel:error)
                FWLogMsg("INFO", , "SHOPIFY_INTEGRATION","SHOPIFY", FunName(), , "[" + (cAlias)->B1_COD + "] - " + oInvLevel:error)
            EndIf
            (cAlias)->(DbSkip())
        EndDo
        
        (cAlias)->(DbCloseArea())
    //EndIf
   	//UnLockByName("ShpInt004", .F., .F. )
    FWLogMsg("INFO", , "SHOPIFY_INTEGRATION","SHOPIFY", FunName(), , STR0085)//End of sending the balance of products to Shopify
    
Return

/*/{Protheus.doc} CliExecAut
	Call customer execauto
	@type  Static Function
	@author Izo Cristiano Montebugnoli
	@since 05/29/2020	
	/*/
Static Function lHasPrice(cSKU)

    Local aArea    := GetArea()
	Local cQuery   := ""
	Local cAlias   := GetNextAlias()
    Local cTable     := Alltrim(ShpGetPar("TABPRECO",, STR0019))//"Shopify table price"
    Local lRet     := .F. 

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf


    //Busco o preco de venda do produto caso esteja zerado ou nao exista e volto false para deixar o estoque zerado no site
    cQuery := "SELECT DA1_PRCVEN FROM " + RetSqlTab("DA1") + CRLF
    cQuery += "WHERE D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "AND DA1_FILIAL = '" + xFilial("DA1") + "'" + CRLF
    cQuery += "AND DA1_CODTAB = '" + cTable        + "'" + CRLF
    cQuery += "AND DA1_CODPRO = '" + cSKU           + "'" + CRLF
	
	TcQuery cQuery new Alias &cAlias
	
	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())
	
	If !(cAlias)->(Eof()) .AND. (cAlias)->DA1_PRCVEN > 0 
		lRet     := .T. 		
	EndIf
	
	(cAlias)->(DbCloseArea())

	RestArea(aArea)	

Return lRet

