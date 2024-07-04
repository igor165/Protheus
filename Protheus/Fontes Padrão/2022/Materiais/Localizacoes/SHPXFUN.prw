#INCLUDE "TOTVS.CH"
#INCLUDE "SHOPIFY.CH"
#INCLUDE "ShopifyExt.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} ShpIntAt
    Check if the Shopify integration is active
    @type  Function
    @author Yves Oliveira
    @since 25/02/2020
    /*/
Function ShpIntAt()

    Local lRet      := .F.
    Local cParName  := "INTEGRA"
    Local cParValue := ""
    
    If !IntegraShp()
	    Return .F. 
    Endif
    //Check if parameters table exists
    lRet := ChkFile("A1F")

    If lRet
        //Check if the integration is active
        cParValue := ShpGetPar(cParName)

        If cParValue == "2" // Inativa
            lRet := .F.
        EndIf
    EndIf
    
Return lRet


/*/{Protheus.doc} ShpGetPar
    Return a integration paramater value
    @author  Yves Oliveira
    @example Example
    @since   25-02-2020
/*/

Function ShpGetPar(cParName, cDefault,cDescription, cMandatory)
    Local aArea := getArea()
    Local cQuery  := ""
    Local cAliasA1F  := ""
    Local cRet    := Nil
    Local lError  := .F.
    Local lFound  := .F.

    Default cDefault     := ""
    Default cDescription := ""
    Default cMandatory   := "1"//1=Yes;2=No
    
  //  BEGIN SEQUENCE
       
       cAliasA1F := "QRYRET"

         If Select(cAliasA1F) > 0
            dbSelectArea(cAliasA1F)
            (cAliasA1F)->(DbCloseArea())
         EndIf

        cQuery := "SELECT A1F_CONT XVALUE" 
        cQuery += "  FROM " + RetSqlName("A1F") 
        cQuery += " WHERE A1F_FILIAL = '" + xFilial("A1F") + "'" 
        cQuery += "   AND D_E_L_E_T_ = ' '" 
        cQuery += "   AND A1F_PARAM = '" + cParName + "'" 

        cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasA1F)
        dbSelectArea(cAliasA1F)

        If (cAliasA1F)->(!EOF())
            lFound := .T. 
            cRet   := AllTrim((cAliasA1F)->XVALUE)
        Else
            If !Empty(cDescription)
                DbSelectArea("A1F")
                RecLock("A1F", .T.)
                A1F->A1F_FILIAL := xFilial("A1F")
                A1F->A1F_PARAM  := AllTrim(cParName)
                A1F->A1F_DESC   := AllTrim(Transform(cDescription, X3Picture("A1F_DESC")))
                A1F->A1F_CONT   := cDefault
                A1F->A1F_MANDAT := cMandatory
                A1F->(MsUnlock())
            EndIf
        EndIf
        (cAliasA1F)->(DbCloseArea())

   // RECOVER
       // lError := .T.
    //END SEQUENCE

    If lError
        Alert(FunName() + ":"+ STR0003) //"Error retrieving record"
    EndIf

    If !lFound .And. !Empty(cDefault)
        cRet := cDefault
    EndIf

    RestArea(aArea)

Return cRet

/*/{Protheus.doc} ShpGetId
    Method to get the id 
    @type  Function
    @author Yves Oliveira
    @since 27/02/2020
    /*/
Function ShpGetId(cAlias, cKey, cAliasPai, cIdPai, lFilIdExt)
    Local cQuery    := ""
    Local cAliasA1d := ""
    Local cRet      := Nil
    Local lError    := .F.

    Default lFilIdExt := .F.//Sinaliza se deve ser filtrado por id do Shopify e retorna o Recno do Protheus
    
    BEGIN SEQUENCE
        cAliasA1d := GetNextAlias()

        If Select(cAliasA1d) > 0
            (cAliasA1d)->(DbCloseArea())
        EndIf

        If lFilIdExt
            cQuery := "SELECT A1D_ID ID" + CRLF
        Else            
            cQuery := "SELECT A1D_IDEXT ID" + CRLF
        EndIf
        cQuery += "  FROM " + RetSqlTab("A1D") + CRLF
        cQuery += " WHERE A1D_FILIAL = '" + xFilial("A1D") + "'"  + CRLF
        cQuery += "   AND D_E_L_E_T_ = ' '" + CRLF
        cQuery += "   AND A1D_ALIAS = '" + cAlias + "'" + CRLF
        
        If lFilIdExt
            cQuery += "   AND A1D_IDEXT = '" + cKey + "'" + CRLF
        Else
            cQuery += "   AND A1D_ID = '" + cKey + "'" + CRLF
        EndIf

        If !Empty(cAliasPai)
            cQuery += "   AND A1D_ALIASP = '" + cAliasPai + "'" + CRLF
        EndIf

        If !Empty(cIdPai)
            cQuery += "   AND A1D_IDPAI = '" + cIdPai + "'" + CRLF
        EndIf

        TcQuery cQuery New Alias &cAliasA1d

        DbSelectArea(cAliasA1d)

        If (cAliasA1d)->(!EOF())
            cRet := (cAliasA1d)->ID
        EndIf
        (cAliasA1d)->(DbCloseArea())

    RECOVER
        lError := .T.
    END SEQUENCE

    If lError
        Alert(FunName() + ":"+ STR0003) //"Error retrieving record"
    EndIf
Return cRet

/*/{Protheus.doc} ShpExistId
    Function to check if the Shopify id exists
    @type  Function
    @author Yves Oliveira
    @since 13/03/2020    
    /*/
Function ShpExistId(cAlias,cId,cAliasPai, cIdPai, lFilIdExt)
    Local lRet   := .F.
    Local cIdAux := Nil

    Default cAliasPai := ""
    Default cIdPai     := "" 
    Default cAliasPai := .F. 

    cIdAux := ShpGetId(cAlias,cId,cAliasPai, cIdPai, lFilIdExt)
    If cIdAux <> Nil
        lRet := .T.
    EndIf
Return lRet



/*/{Protheus.doc} ShpSaveId
    Function to save the Shopify identifier
    @type  Function
    @author Yves Oliveira
    @since 13/03/2020    
    /*/
Function ShpSaveId(cAlias,cId,cIdExt,cAliasPai,cIdPai,cLastUpd)
    Local aArea  := GetArea()
    //Local cChave := ""
    Local lNew   := .T. 
    
    Default cAliasPai := ""
    Default cIdPai    := ""
    Default cLastUpd  := ""
    
    cAlias    := Pad(cAlias, TamSx3("A1D_ALIAS")[1])
    cId       := Pad(cId, TamSx3("A1D_ID")[1])
    cIdExt    := Pad(cIdExt, TamSx3("A1D_IDEXT")[1])
    cAliasPai := Pad(cAliasPai, TamSx3("A1D_ALIASP")[1])
    cIdPai    := Pad(cIdPai, TamSx3("A1D_IDPAI")[1])

    cChave := xFilial("A1D") + cAlias + cId + cIdExt + cAliasPai + cIdPai

    DbSelectArea("A1D")
    A1D->(DbSetOrder(2))//A1D_FILIAL+A1D_ALIAS+A1D_ID+A1D_IDEXT+A1D_ALIASP+A1D_IDPAI
    If A1D->(DbSeek(cChave))
        lNew := .F.
    EndIf

    RecLock("A1D", lNew)
    A1D->A1D_FILIAL := xFilial("A1D")
    A1D->A1D_ALIAS  := cAlias
    A1D->A1D_ID     := cId
    A1D->A1D_IDEXT  := cIdExt
    A1D->A1D_ALIASP := cAliasPai
    A1D->A1D_IDPAI  := cIdPai
    If !Empty(cLastUpd)
        A1D->A1D_LASTUP := cLastUpd
    EndIf
    A1D->(MsUnlock())

    RestArea(aArea)
    
Return 

/*/{Protheus.doc} ShpSaveErr    
    Function to save errors
    @type  Function
    @author Yves Oliveira
    @since 25/03/2020
    /*/
Function ShpSaveErr(id, idExt, cIntegration, error, path, apiVer, body, verb, cStatus) 

    Local aArea	:= GetArea()
    Local cNumReg := ""
    Default cStatus := "P" //P=Pending;R=Resolved

    //caso seja um internal erro eu altero o status para  I = internal error
    If Alltrim(cIntegration) == Alltrim(ID_INT_INTERNAL_ERROR)
        cStatus := "I"
    EndIf 

    cNumReg := ShpIDCons("A1C","A1C_NUMREG",1,TamSX3("A1C_NUMREG")[1],cIntegration)

    DbSelectArea("A1C")

    id    := iif(Valtype(id) == "N",cValToChar(id),id)
    idExt := iif(Valtype(idExt) == "N",cValToChar(idExt),idExt)

    Reclock("A1C",.T.)
    A1C->A1C_FILIAL := xFilial("A1C")
    A1C->A1C_ID     := id
    A1C->A1C_IDEXT  := idExt
    A1C->A1C_INTEGR := cIntegration
    A1C->A1C_MESSAG := error
    A1C->A1C_PATH   := path
    A1C->A1C_APIVER := apiVer
    A1C->A1C_BODY   := body
    A1C->A1C_VERB   := verb
    A1C->A1C_DATE   := Date()
    A1C->A1C_TIME   := Substr(Time(),1,8)
    A1C->A1C_STATUS := cStatus
    A1C->A1C_NUMREG := cNumReg
    A1C->(MsUnlock())
    //A1C->(DbCloseArea())

    //aqui envio o Email com os detalhes do erro
    ShpSendMail(cIntegration,id,error)     

    RestArea(aArea)

    
Return

/*/{Protheus.doc} ShpIDCons
    Return consecutivo para el historial
    @type  Function
    @author Alfredo Medrano
    @since 13/09/2020
    /*/
Static Function ShpIDCons(cAliasTBL,cCampoTBL,nIndice,nTam,cInteg)
Local cIdA1C	:= ""
Local aArea	:= GetArea()


If Empty(cAliasTBL) .OR. Empty(cCampoTBL) .OR. nIndice <= 0 .OR. nTam <= 0
    Return cIdA1C
EndIf

DbSelectArea(cAliasTBL)
DbSetOrder(nIndice)

cInteg := PadR(cInteg,TamSX3("A1C_INTEGR")[1])

While .T.
	cIdA1C := GetSxENum(cAliasTBL, cCampoTBL )
    //cIdA1C:= Strzero(VAL(cIdA1C),nTam)
	If !(MSSeek(xFilial(cAliasTBL) + cInteg + cIdA1C))
	 	Exit 
	Endif
Enddo

RestArea(aArea)

Return cIdA1C

/*/{Protheus.doc} ShpErrAut
    Return execauto error detailed
    @type  Function
    @author Yves Oliveira
    @since 25/03/2020
    /*/
Function ShpDetErr()
	//Local cErroFile := ''
	Local aErroAuto := {}
	Local cErroAuto := ''
	Local nError := 0
	
	Local cError := ''

	//cErroFile := NomeAutoLog()
	aErroAuto := GetAutoGrLog()
	//cErroAuto := MemoRead(cErroFile)

	/*If !Empty(cErroAuto)
		FErase(cErroFile)
	EndIf*/

	//If Empty(cErroAuto)
		For nError := 1 To Len(aErroAuto)
			cErroAuto += AllTrim(aErroAuto[nError]) + CRLF
		Next nError
	//EndIf

	cError += if(!empty( cError ), CRLF + CRLF, '') + cErroAuto

return cError


/*/{Protheus.doc} ShpGetArcId
    Return the Shopify location Id
    @type  Function
    @author Yves Oliveira
    @since 28/03/2020
    /*/
Function ShpGetLoId()
    Local nRecno     := 0
    Local cRet       := ""
    Local cQuery     := ""
    Local cAlias     := GetNextAlias()
    Local cWarehouse := ""
    Local oLocation  := Nil

    cWarehouse := ShpGetPar("LOCPAD")

    If Select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    EndIf
    
    cQuery += "SELECT R_E_C_N_O_ RECNO" + CRLF
    cQuery += "  FROM " + RetSqlTab("NNR") + CRLF
    cQuery += " WHERE D_E_L_E_T_ = ' '" + CRLF
    cQuery += "   AND NNR_CODIGO = '" + cWarehouse +"'" + CRLF
    
    TcQuery cQuery new Alias &cAlias
    
    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())
    
    If !(cAlias)->(Eof())
        nRecno := (cAlias)->RECNO
    EndIf

    cRet := ShpGetId(SHP_ALIAS_LOCATION, cValToChar(nRecno))

    // Create record if not exists
    If Empty(cRet)
        oLocation := ShpLocation():New()
        oLocation:id := cValToChar(nRecno)
        oLocation:requestToShopify()
        cRet := oLocation:idExt
    EndIf
    
    (cAlias)->(DbCloseArea())
Return cRet

/*/{Protheus.doc} getSb2Recno
    Return the SB2 recno number
    @author Yves Oliveira
    @since 19/03/2020
    /*/
Function ShpSb2Rec(cProduct)
    Local aArea      := GetArea()
    Local nRecno     := 0
    Local cQuery     := ""
    Local cAlias     := GetNextAlias()
    Local cWarehouse := ""
    
    cWarehouse := ShpGetPar("LOCPAD")

    If Select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    EndIf    
    
    cQuery += "SELECT R_E_C_N_O_" + CRLF
    cQuery += "  FROM " + RetSqlTab("SB2") + CRLF
    cQuery += " WHERE D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "   AND B2_FILIAL  = '" + xFilial("SB2") + "'" + CRLF
    cQuery += "   AND B2_COD     = '" + cProduct       + "'" + CRLF
    cQuery += "   AND B2_LOCAL   = '" + cWarehouse     + "'" + CRLF
    
    TcQuery cQuery new Alias &cAlias
    
    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())
    
    If !(cAlias)->(Eof())
        nRecno := (cAlias)->R_E_C_N_O_
    Else
        CriaSB2(cProduct,cWarehouse)
        nRecno := SB2->(Recno())
    EndIf
    
    (cAlias)->(DbCloseArea())    
    RestArea(aArea)
    
Return nRecno

/*/{Protheus.doc} ShpInvInf
    Return SB1 info based on Shopify Id
    @type  Function
    @author Yves Oliveira
    @since 28/03/2020
    /*/
Function ShpInvInf(cInvId,cField)
    Local oRet   := Nil
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    
    If Select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    EndIf
    
    cQuery += "SELECT " + cField + " VALUE" + CRLF
    cQuery += "  FROM " + RetSqlTab("SB1,A1D") + CRLF
    cQuery += " WHERE SB1.D_E_L_E_T_  = ' '" + CRLF
    cQuery += "   AND A1D.D_E_L_E_T_ = ' '" + CRLF
    cQuery += "   AND A1D_ALIAS = '" + SHP_ALIAS_INVENTORY + "'" + CRLF
    cQuery += "   AND A1D_ALIASP = '" + SHP_ALIAS_VARIANT + "'" + CRLF
    cQuery += "   AND A1D_IDPAI = SB1.R_E_C_N_O_" + CRLF 
    cQuery += "   AND A1D_IDEXT = '" + cInvId +  "'" + CRLF
    
    TcQuery cQuery new Alias &cAlias
    
    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())
    
    If !(cAlias)->(Eof())
        oRet := (cAlias)->VALUE
    EndIf
    
    (cAlias)->(DbCloseArea())

Return oRet

/*/{Protheus.doc} ShpDateTime
    Return date time in Shopify format
    @type  Function
    @author Yves Oliveira
    @since 01/04/2020
    /*/
Function ShpGetTime(dDate,cTime)
    Local cRet := ""
    Default dDate := Date()
    Default cTime := Time()

    cRet := FWTimeStamp(5, dDate, cTime) //5 - Formato UTC aaaa-mm-ddThh:mm:ss-+Time Zone (coloca a hora local + o timezone (ISO 8106))
Return cRet

/*/{Protheus.doc} ShpCurrPrice
    Return the current product Price
    @type  Function
    @author Yves Oliveira
    @since 01/04/2020
    /*/
Function ShpCurrPrice(cProduct)
    Local aArea      := GetArea()
    Local nCurrPrice := 0
    Local cTable     := ShpGetPar("TABPRECO",, STR0019)//"Shopify table price"

    If !Empty(cTable)
        DA1->(dbSetOrder(2))//DA1_FILIAL+DA1_CODPRO+DA1_CODTAB+DA1_ITEM                                                                                                                       
        If DA1->(dbSeek(xFilial("DA1")+PADR(cProduct,TAMSX3("B1_COD")[1])+cTable))
            nCurrPrice := DA1->DA1_PRCVEN  
        Else
            nCurrPrice := 0.00
        EndIf      
    Else
        nCurrPrice := 0.00
    EndIf	

    RestArea(aArea)

Return nCurrPrice

/*/{Protheus.doc} ShpInitPar
    Initialize all integration parameters
    @type  Function
    @author Yves Oliveira
    @since 04/04/2020    
    /*/
Function ShpInitPar()
    ShpGetPar("BASEURL"  , "" , STR0020, "1")//"Integration base URL"
    ShpGetPar("APIKEY"   , "" , STR0021, "1")//"API KEY for Shopify API authentication"
    ShpGetPar("APIPSW"   , "" , STR0022, "1")//"Password for Shopify API authentication"
    ShpGetPar("VERAPI"   , "" , STR0023, "1")//"Shopify API version"
    ShpGetPar("LOCPAD"   , "" , STR0024, "1")//"Default Shopify warehouse"
    ShpGetPar("SERIEPAD" , "" , STR0025, "1")//"Defaut Serie to generate invoice"
    ShpGetPar("CONPAD"   , "" , STR0026, "1")//"Default Payment to generate invoice"
    ShpGetPar("TESTAXA"  , "" , STR0027, "1")//"Default TES"
    ShpGetPar("BANCOBX"  , "" , STR0028, "1")//"Default Bank to post bills"
    ShpGetPar("TIPOCLI"  , "1", STR0016, "1")//"Default customer type"
    ShpGetPar("NATUCLI"  , "" , STR0017, "1")//"Default customer class"
    ShpGetPar("PAISCLI"  , "" , STR0018, "1")//"Default customer country"
    ShpGetPar("TABPRECO" , "" , STR0019, "1")//"Shopify table price"
    
    //Product Grid parameters
    ShpGetPar("GRIDTYPE"    , SHP_ALIAS_GRID  , STR0057, "1")//"Indicates how the integration will group grid products. Possible values: CUSTOM or SB4"
    

    //novos parametros
    ShpGetPar("CONTAEMAIL"  ,"SHOPIFY"  ,STR0119) //"Email account using on Shopify have to add in table WF7    
    ShpGetPar("EMAILS"      ,""         ,STR0091) //"Emails para Envio dos erros"
    ShpGetPar("VENDEDOR"    ,""         ,STR0117) //"Vendedor Padrao" //TODO ALTERAR PARA U
    ShpGetPar("TRANSPORT"   ,""         ,STR0118) //"Transportadora Padrao"    

    ShpGetPar("GRPBFNAME"  ,""         ,STR0120,"2") //"Group Body - (Fiel Name - SBM)" 

    ShpGetPar("TESFRETE" ,"",STR0165 )//"Tes use from freight refunds"
    ShpGetPar("PRODFRETE","" ,STR0166,)//"Product code use to freight refunds"

    //aqui eu crio na tabela SFB a formula para ser usado no protheus para calculo de impostos
    SFB->(DbSetOrder(1))	// C0_FILIAL+C0_NUM+C0_PRODUTO+C0_LOCAL
    If !SFB->(MsSeek( xFilial("SFB")+ "EUA" ))
        SFB->( RecLock("SFB",.T.)  ) 
        SFB->FB_CODIGO  := 'EUA'
        SFB->FB_DESCR   := 'EUA SALES TAX'
        SFB->FB_FORMENT := 'EUATAX'
        SFB->FB_FORMSAI := 'EUATAX'
        SFB->FB_DIAVENC := '1'
        SFB->FB_JNS     := 'N''
        SFB->FB_COLBAS  := 1
        SFB->FB_COLVAL  := 1
        SFB->FB_CPOLVRO := '1'
        SFB->FB_DUPLO   :=  'N'           
        SFB->FB_RELACIO := 'S'
        SFB->FB_INTEIC  := '2'
        SFB->(MsUnLock())
    EndIf
    
 Return

/*/{Protheus.doc} ShpIsGrid
    Returns whether the product belongs to a grid. Copy of A010Grade
    @type  Function
    @author Yves Oliveira
    @since 06/04/2020    
    /*/
Function ShpIsGrid(cProduct)
	
	Local aArea    := {}
	Local lRet	   :=.T.

    aArea := SB1->(GetArea())
    DbSelectArea("SB1")
	SB1->(DbSetOrder(1))//B1_FILIAL+B1_COD 
    If SB1->(MsSeek(xFilial("SB1")+cProduct))
        If SB1->B1_GRADE <> "S"
            lRet := .F.
        EndIf
    Else
        lRet := .F.
    Endif
    RestArea(aArea)
	
Return(lRet)

/*/{Protheus.doc} ShpExisA1M
    Returns whether the product belongs to a grid. Copy of A010Grade
    @type  Function
    @author Yves Oliveira
    @since 06/04/2020    
    /*/
Function ShpExisA1M(cProduct)
	
	Local aArea    := {}
	Local lRet	   :=.F.
    aArea := A1M->(GetArea())
    DbSelectArea("A1M")
	A1M->(DbSetOrder(1))
    If A1M->(MsSeek(xFilial("A1M")+cProduct))
    	Alert(STR0097) // "Produto já cadastrado!"
        lRet := .T.
    Endif
    RestArea(aArea)
	
Return(lRet)

/*/{Protheus.doc} ShpIntProd
    Return if a product can be integrated with Shopify
    @type  Function
    @author Yves Oliveira
    @since 07/04/2020
    /*/
Function ShpIntProd(cProduct)
    Local lRet    := .F.
    Local aArea   := GetArea()
    Local cSearch := ""
    Local dToday  := Date()
    Local dIni    := Nil
    Local dFim    := Date()

    cSearch := xFilial("A1K") + PADR(AllTrim(cProduct), TamSx3("A1K_COD")[1])

    DbSelectArea("A1K")
    A1K->(DbSetOrder(1))//A1K_FILIAL+A1K_COD
    If A1K->(DbSeek(cSearch))
        //If exists, check if it is valid
        dIni := A1K->A1K_INI
        dFim := Iif(Empty(A1K->A1K_FIM), Date(), A1K->A1K_FIM)
        If dToday >=  dIni .And. dToday <= dFim
            lRet := .T.
        EndIf 
    EndIf
    
    RestArea(aArea)
Return lRet

/**
*
* @author: Izo Cristiano Montebugnoli
* @since: May 26, 2020 - 11:51:17 PM
* @description: metodo responsável pelo envio de email. 
*/ 
Function ShpSendMail(cIntegration,id,error)  //ShpSendMail(aDados,cId,lJob,cStatus) 
	
	local aArea		:= getArea()
	local oSendMail	:= ShpSendMail():new()
	local cTo		:= ShpGetPar("EMAILS","izocristiano@hotmail.com;marcos.morais@totvspartners.com.br;darlon.bortolini@totvs.com.br",STR0091) //"Emails para Envio dos erros"
	local cCc		:= ""        
	local cBcc		:= ""
	local cSubject	:= STR0092 + ": " + Alltrim(cIntegration) + " - ID: " + Alltrim(id) //"Log Integration Shopify"
	local cBody		:= ""

    if !Empty(Alltrim(cTo))

        cBody :=  '<HTML> '
        cBody +=  '    <HEAD>'
        cBody +=  '       <TITLE>Log Integration Shopify</TITLE>'
        cBody +=  '       <META http-equiv=Content-Type content="text/html; charset=windows-1252">'
        cBody +=  '       <META content="MSHTML 6.00.6000.16735" name=GENERATOR>'
        cBody +=  '     </HEAD>'
        cBody +=  '     <BODY>'
        cBody +=  '         <H3><FONT color=#ff0000>' + Alltrim(cSubject) + '</FONT></H3>'
        cBody +=  '         <TABLE cellSpacing=0 cellPadding=0 width="100%" background="" border=1>'
        cBody +=  '             <TBODY>'
        cBody +=  '                 <TR>'
        cBody +=  '                    <TD style="width:20%">Error Log Detail id Number:</TD>'
        cBody +=  '                    <TD style="width:80%">'+ Alltrim(id) +'</TD> '
        cBody +=  '                 </TR>'
        cBody +=  '                 <TR>'
        cBody +=  '                     <TD>Msg:</TD>'
        cBody +=  '                     <TD>' + error + '</TD>'
        cBody +=  '                 </TR>'
        cBody +=  '              </TBODY>'
        cBody +=  '         </TABLE>'
        cBody +=  '         <P>&nbsp;</P>'
        cBody +=  '     </BODY>'
        cBody +=  '</HTML>'

        //realizando o envio de email - CONFIRMAR SE NA WF7 TEMOS A CONTA CHAMADA 'WORKFLOW' -> primeiro parametro do metodo é o nome da conta.
        oSendMail:send(, cTo, cCc, cBcc, cSubject,cBody)

    EndIf 

	restArea(aArea)
	
return

/*/{Protheus.doc} ShpChkSql
    Return if a product the Invalid SQL statement is correct.
    @type  Function
    @author Marcos Furtado Morais
    @since 26/05/2020
    /*/
Function ShpInOGrid(cProduct, cCodPai)

	Local cQuery:= ""
	Local _lRet := .F.
	Local cAlias    := GetNextAlias()
	
	If Empty(cProduct) .or. Empty(cCodPai)
		Return(_lRet)
	EndIf
	
	cQuery := "SELECT A1K_COD " 
	cQuery += " FROM " + RetSqlName("A1K") + " A1K " 
	cQuery += "WHERE A1K_FILIAL =  '" + xFilial("A1K") + "' " + CRLF
	cQuery += "	AND A1K_COD     =  '" + cProduct       + "' " + CRLF	
	cQuery += "	AND A1K_CODPAI  <> '" + cCodPai        + "' " + CRLF
	cQuery += "	AND A1K_CODPAI  <> '" + cCodPai        + "' " + CRLF	
	cQuery += "	AND (A1K_FIM = ' '  OR  A1K_FIM >= '"+DTOS(dDataBase)+"') " + CRLF	
	cQuery += "	AND D_E_L_E_T_ = ' ' " + CRLF	
	
	TcQuery cQuery new Alias &cAlias

	If !Empty((cAlias)->A1K_COD)
		_lRet := .T.
	EndIf

Return(_lRet)

/*/{Protheus.doc} ShpChkSql
    Return if a product the Invalid SQL statement is correct.
    @type  Function
    @author Marcos Furtado Morais
    @since 26/05/2020
    /*/
Function ShpChkSql(_cStrSql)
//U_ShpInt010(M->A1K_SQLTIT)
	Local cQuery:= ""
	Local _lRet := .T.
	
	If Empty(_cStrSql)
		Return(.T.)
	EndIf
	
	cQuery := "SELECT "+ Alltrim(Upper(_cStrSql)) + " " 
	cQuery += " FROM " + RetSqlName("SB1") + " SB1 " 
	/*cQuery +=            RetSqlName("SBM") + " SBM, " 
	cQuery +=            RetSqlName("SB4") + " SB4, " 
	cQuery +=            RetSqlName("SB5") + " SB5, " 
	cQuery +=            RetSqlName("SBV") + " LIN, " 
	cQuery +=            RetSqlName("SBV") + " COL " */

	cQuery += "LEFT JOIN " + RetSqlName("SBM") + " SBM ON" + CRLF
	cQuery += "	SBM.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	AND BM_FILIAL = '" + xFilial("SBM") + "'" + CRLF
	cQuery += "	AND SBM.BM_GRUPO = SB1.B1_GRUPO" + CRLF
	
	cQuery += "LEFT JOIN " + RetSqlName("SB4") + " SB4 ON" + CRLF
	cQuery += "	SB4.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	AND B4_FILIAL = '" + xFilial("SB4") + "'" + CRLF
	cQuery += "	AND B4_COD = SB1.B1_COD " + CRLF
	
	cQuery += "LEFT JOIN " + RetSqlName("SBV") + " LIN ON" + CRLF
	cQuery += "	LIN.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	AND LIN.BV_FILIAL = '" + xFilial("SBV") + "'" + CRLF
	cQuery += "	AND LIN.BV_TABELA = B4_LINHA" + CRLF
	cQuery += "	AND LIN.BV_CHAVE = SB1.B1_COD " + CRLF

	cQuery += "LEFT JOIN " + RetSqlName("SBV") + " COL ON" + CRLF
	cQuery += "	COL.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	AND COL.BV_FILIAL = '" + xFilial("SBV") + "'" + CRLF
	cQuery += "	AND COL.BV_TABELA = B4_COLUNA" + CRLF
	cQuery += "	AND COL.BV_CHAVE = SB1.B1_COD " + CRLF

    cQuery += "LEFT JOIN " + RetSqlName("SB5") + " SB5 ON" + CRLF
	cQuery += "	SB5.D_E_L_E_T_ = ' '" + CRLF
	cQuery += " AND SB5.B5_FILIAL = '" + xFilial("SB5") + "'" + CRLF
	cQuery += " AND SB5.B5_COD = SB1.B1_COD" + CRLF

	cQuery += "WHERE" + CRLF
	cQuery += "	SB1.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	AND B1_FILIAL = '99'" + CRLF

	// Igualo a filial a '99' apenas para testar a consulta

	_nRetSql := TcSqlExec(cQuery)
	If _nRetSql < 0
		 Alert(STR0095) // ("Invalid SQL statement!")
		_lRet := .F.
	EndIf

Return(_lRet)

/*/{Protheus.doc} ShpComCha
    Return if a product the Invalid SQL statement is correct.
    @type  Function
    @author Marcos Furtado Morais
    @since 27/05/2020
    /*/

Function ShpComCha(firstWord, secondWord, matchWindow)

	Local CommonChars := ""
	Local cCopy       := ""
	Local cChar       := Space(1)
	Local foundIT     := 0
	
	
	Local f1_len := 0
	Local f2_len := 0
	Local i := 0
	Local j := 0
	Local j_Max := 0

	CommonChars = ''
	
    IF !Empty(firstWord) .And. !Empty(secondWord)  
		f1_len := Len(firstWord)
		f2_len := Len(secondWord)
		cCopy  := secondWord

		i := 1
		While i < (f1_len + 1)
			cChar   := SUBSTR(firstWord, i, 1)
			foundIT := 0

			// Set J starting value
			If i - matchWindow > 1
				j := i - matchWindow
			Else
				j := 1
			EndIf
			
			// Set J stopping value
			If i + matchWindow <= f2_len
				j_Max := i + matchWindow
			ElseIf f2_len < i + matchWindow
				j_Max := f2_len
			EndIf

			While j < (j_Max + 1) .And. foundIT == 0
				If SubStr(cCopy, j, 1) == cChar
					foundIT 	:= 1
					CommonChars := CommonChars + cChar
					cCopy 		:= STUFF(cCopy, j, 1, '#')
				EndIf
				j++
			End
			i++
		End
    EndIf

Return(CommonChars)

/*/{Protheus.doc} ShpCMatWin - fCalcMatchWindow
    Return if a product the Invalid SQL statement is correct.
    @type  Function
    @author Marcos Furtado Morais
    @since 27/05/2020
    /*/
    
Function ShpCMatWin(s1_len , s2_len)
	Local matchWindow 	:= 0
	Default s1_len 		:= 0
	Default s2_len 		:= 0
	matchWindow :=	IIf(s1_len >= s2_len,(s1_len / 2) - 1, (s2_len / 2) - 1)

Return(matchWindow)


/*/{Protheus.doc} ShpCalTran - fCalculateTranspositions
    Return if a product the Invalid SQL statement is correct.
    @type  Function
    @author Marcos Furtado Morais
    @since 27/05/2020
    /*/

Function ShpCalTran(s1_len, str1, str2) 

	Local transpositions := 0
	Local i 			 := 0
	Default s1_len  := 0
	Default str1 	:= "" 
	Default str2 	:= ""
	
	While i < s1_len
		If SubStr(str1, i+1, 1) <> SubStr(str2, i+1, 1)
			transpositions := transpositions + 1
		EndIF
		i := i + 1
	END

	transpositions := transpositions / 2
Return(transpositions)

/*/{Protheus.doc} ShpCalTran - fCalcJarp
    Return if a product the Invalid SQL statement is correct.
    @type  Function
    @author Marcos Furtado Morais
    @since 27/05/2020
    /*/

Function ShpCalJaro(str1, str2) 

	local Common1 		:= ""
	local Common2 		:= ""
	local Common1_Len 	:= 0
	local Common2_Len 	:= 0
	local s1_len 		:= 0  
	local s2_len 		:= 0 
	local transpose_cnt := 0
	local match_window 	:= 0
	local jaro_distance := 0

	Default str1 	:= "" 
	Default str2 	:= ""
	
	transpose_cnt := 0
	match_window  := 0
	jaro_distance := 0
	
	s1_len := Len(str1)
	s2_len := Len(str2)
	
	match_window := ShpCMatWin(@s1_len, @s2_len)
	Common1 	 := ShpComCha(@str1, @str2, @match_window)
	Common1_Len  := LEN(@Common1)
	
	If Common1_Len == 0 .Or.  Empty(Common1)
		Return(0)		
	EndIf
	
	Common2     := ShpComCha(@str2, @str1, @match_window)
	Common2_Len := Len(Common2)
	IF AllTrim(Common1_Len) <> AllTrim(Common2_Len) .Or. Empty(Common2)
		Return(0)
	EndIf

	transpose_cnt := ShpCalTran(@Common1_Len, @Common1, @Common2)
	jaro_distance := @Common1_Len / (3.0 * @s1_len) +; 
					 @Common1_Len / (3.0 * @s2_len) +;
					 (@Common1_Len - @transpose_cnt) / (3.0 * @Common1_Len)

Return(jaro_distance)

/*/{Protheus.doc} ShpCJaroWk - fn_calculatePrefixLength
    Return if a product the Invalid SQL statement is correct.
    @type  Function
    @author Marcos Furtado Morais
    @since 27/05/2020
    /*/

Function ShpCPreLen(firstWord, secondWord)


	Local f1_len 				:= 0
	Local f2_len 				:= 0
    Local minPrefixTestLength 	:= 0
	Local i 					:= 0 
	Local n 					:= 0
	Local foundIT 				:= 0
	
	Default firstWord 			:= ""
	Default secondWord  		:= ""

	minPrefixTestLength := 4
    IF !Empty(firstWord) .And. !Empty(secondWord) 
		f1_len 	:= LEN(firstWord)
		f2_len 	:= LEN(secondWord)
		i 		:= 0
		foundIT := 0
		
		If minPrefixTestLength < @f1_len .And. minPrefixTestLength < @f2_len 
			n := minPrefixTestLength
		ElseIf f1_len < f2_len .And. f1_len < minPrefixTestLength 
			n := @f1_len
		Else
			n := f2_len
		EndIf
		
		While i < n .And. foundIT == 0
			If SubStr(firstWord, i+1, 1) <> SubStr(secondWord, i+1, 1)
				minPrefixTestLength := i
				foundIT 			:= 1
			EndIf
			i++
		END
	EndIF
Return(minPrefixTestLength)

/*/{Protheus.doc} ShpCJaroWk - fn_calculateJaroWinkler
    Return if a product the Invalid SQL statement is correct.
    @type  Function
    @author Marcos Furtado Morais
    @since 27/05/2020
    /*/
    
Function ShpCJaroWk(str1 , str2) 

	Local jaro_distance			:= 0 
	Local jaro_winkler_distance	:= 0
	Local prefixLength			:= 0
	Local prefixScaleFactor		:= 0

	Default str1 				:= ""
	Default str2 				:= ""

	prefixScaleFactor			:= 0.1 //Constant = .1

	jaro_distance	:= ShpCalJaro(@str1, @str2)	
	prefixLength	:= ShpCPreLen(@str1, @str2)

	jaro_winkler_distance := jaro_distance + ((prefixLength * prefixScaleFactor) * (1.0 - jaro_distance))
	
Return(jaro_winkler_distance)


/*/{Protheus.doc} ShpCJaroWk - fn_calculateJaroWinkler
    Return if a product the Invalid SQL statement is correct.
    @type  Function
    @author Marcos Furtado Morais
    @since 27/05/2020
    /*/
    
Function ShpRetCC2(cMun,cUF)

Local nX      	:= 0
Local nY      	:= 0
Local nZ       	:= 0
Local cQuery  	:= ""
Local cCodMun 	:= ""
Local cDescMun	:= ""
Local nNota   	:= 0
Local aEstMun 	:= {}
Local cAlias    := GetNextAlias()
Local _aRetCC2  := {}
    
Default cMun  	:= {}
Default cUF   	:= {}

cMun 		    := AllTrim(NOACENTO(Upper(cMun)))
cMun 		    := StrTran(AllTrim(cMun)," ","")
cUF  		  	:= AllTrim(Upper(cUF))

cQuery := " SELECT DISTINCT CC2_EST, CC2_MUN, CC2_CODMUN "
cQuery += "   FROM "+RetSqlName("CC2")+" C2 "
cQuery += "  WHERE CC2_FILIAL = '"+xFilial("CC2")+"' "
cQuery += "   AND C2.D_E_L_E_T_ = ' '               "
cQuery += "   AND CC2_EST    = '" + cUF + 		  "' "    
cQuery += " GROUP BY CC2_CODMUN, CC2_MUN, CC2_EST    "
cQuery += " ORDER BY 1,2							 "

TcQuery cQuery new Alias &cAlias
  
If (cAlias)->(EOF())
	Alert("Não Existe cidade cadastrada para esta UF!")
	AADD( _aRetCC2, " " )
	AADD( _aRetCC2, " " )
	AADD( _aRetCC2, 0 )
	
	Return _aRetCC2
EndIf

cCodMun  := (cAlias)->CC2_CODMUN
cDescMun := AllTrim((cAlias)->CC2_MUN)

//Alert("Inicio da busca")
While (cAlias)->(!EOF())
	nX := AScan(aEstMun, {|x| x[1] == (cAlias)->CC2_MUN})
	If nX == 0
		aAdd( aEstMun, { (cAlias)->CC2_EST, (cAlias)->CC2_MUN, (cAlias)->CC2_CODMUN } )
		nX := Len(aEstMun)
	EndIf
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(DbCloseArea())

For nY := 1 To Len( aEstMun )
	nZ := ShpCJaroWk(AllTrim(cMun), AllTrim(aEstMun[nY, 2]))
	//nZ := fCalcJaro(AllTrim(aEstMun[nY, 2]),AllTrim(cMun))
	If nZ > nNota
		nNota     := nZ
		cCodMun   := aEstMun[nY,3]
		cDescMun  := aEstMun[nY,2]
		nNotaJaro := nZ
	EndIf
Next nY

AADD( _aRetCC2, cCodMun )
AADD( _aRetCC2, cDescMun )
AADD( _aRetCC2, nNota )

/*If nNota < 0.70
	Alert("Não foi possível encontrar uma cidade (> 0.70)")
	cCodMun := ""
EndIF*/

Return(_aRetCC2)


/*/{Protheus.doc} IntegShp
    Run Shopify integration
    @type  Static Function
    @author Yves Oliveira
    @since 13/04/2020
    /*/
Function IntegShp(lAll)
    
    Local cMessage := ""
    Local cSearch  := xFilial("A1K") + A1M->A1M_COD
    Local oInt     := Nil
    Local lOk      := .T.
    Local aArea    := {}
    Local lErro    := .F.
    Default   lAll := .F. 

    If lAll 

        If  MsgYesNo(STR0100)   //Are you sure to integrate all products to Shopify ? 

            DbSelectArea("A1M")
            dbGotop()
            ProcRegua(RecCount())


            While A1M->(!Eof())

                DbSelectArea("A1K")
                A1K->(DbSetOrder(2))//A1K_FILIAL+A1K_CODPAI
                A1K->(DbSeek( xFilial("A1K") + A1M->A1M_COD) )

                A1MaArea := A1M->(GetArea())


                While A1K->(!Eof()) .And. A1K->(A1K_FILIAL + A1K_CODPAI) == (xFilial("A1K") + A1M->A1M_COD) .And. lOk

                    aArea := A1K->(GetArea())
                    DbSelectArea("SB1")
                    SB1->(DbSetOrder(1))//B1_FILIAL+B1_COD

                    If SB1->(DbSeek(xFilial("SB1") + A1K->A1K_COD))
                        oInt := ShpInteg():New()
                        cMessage := AllTrim(SB1->B1_COD) + " - " + AllTrim(SB1->B1_DESC)
                        
                        lRet := oInt:intProduct(SB1->(Recno()))
                        	
                        If "404 NOTFOUND" $ Upper(oInt:error)
                            lRet := oInt:intProduct(SB1->(Recno()))
                        EndIf
                        
                        If !lRet
                        	lErro := .T.
                        EndIF
                    EndIf
                    RestArea(aArea)
                    A1K->(DbSkip()) 

                EndDo

                RestArea(A1MaArea)
                A1M->(dbSkip())
                IncProc(STR0001 + " " + cMessage)//"Integrating with Shopify..."             

            EndDo

        endif 
    else

        DbSelectArea("A1K")
        A1K->(DbSetOrder(2))//A1K_FILIAL+A1K_CODPAI
        A1K->(DbSeek(cSearch))

        While !A1K->(Eof()) .And. A1K->(A1K_FILIAL + A1K_CODPAI) == cSearch .And. lOk
            aArea := A1K->(GetArea())
            DbSelectArea("SB1")
            SB1->(DbSetOrder(1))//B1_FILIAL+B1_COD 
            If SB1->(DbSeek(xFilial("SB1") + A1K->A1K_COD))
               
                oInt := ShpInteg():New()
                cMessage := AllTrim(SB1->B1_COD) + " - " + AllTrim(SB1->B1_DESC)
                MsgRun( cMessage, STR0001, {|| lOk := oInt:intProduct(SB1->(Recno()))  } )//"Integrating with Shopify..."
                If "404 NOTFOUND" $ Upper(oInt:error)
                    MsgRun( cMessage, STR0001, {|| lOk := oInt:intProduct(SB1->(Recno()))  } ) //"Integrating with Shopify..."
                EndIf

            EndIf
            RestArea(aArea)
            A1K->(DbSkip()) 
        EndDo
    endif

    If lErro
    	MSGINFO( STR0012, "" )//"Process finished!"
    EndIF
    
    If lOk
        MSGINFO( STR0069, "" )//"Process finished!"
    EndIf
Return

/*/{Protheus.doc} ShpDelProd
    Returns whether the product belongs in the ShopiFy
    @type  Function
    @author Marcos Furtado Morais
    @since 03/06/2020    
    /*/
Function ShpDelProd(cProduct)
	
	Local aArea    := {}
	Local lRet	   :=.T.
    aArea := GetArea()
    DbSelectArea("A1K")
	A1K->(DbSetOrder(1))//A1K_FILIAL+A1K_COD
    If A1K->(MsSeek(xFilial("A1K")+cProduct))
    	Aviso(STR0115, STR0114  + AllTrim(cProduct),{STR0116},2) //"Warning!!"###"This product is integrated with ShopiFy and cannot be deleted."###"Ok"    
        lRet := .F.
    Endif
    RestArea(aArea)
	
Return(lRet)

/*/{Protheus.doc} ShpProdC
    Inicializa la integracion del producto con shopify
    @type  Function
    @author Alfredo Medrano
    @since 04/12/2020    
    /*/
Function ShpProdC(aProdutos,aProdAlt)

Local nX := 0
Local oIntShp
default aProdutos:= {}
default aProdAlt := {}

	If ShpIntAt()
		For nX := 1 to Len(aProdutos)
			If !Empty(aProdutos[nX][1]) .And. ShpIntProd(aProdutos[nX][1])
				oIntShp := ShpInteg():New()
				MsgRun( aProdutos[nX][1], STR0001, {|| oIntShp:intProdByCod(aProdutos[nX][1]) } )//"Integrating with Shopify..."
			Endif
		Next nX
		
		For nX := 1 to Len(aProdAlt)
			If !Empty(aProdAlt[nX][1]) .And. ShpIntProd(aProdAlt[nX][1])
				oIntShp := ShpInteg():New()
				MsgRun( aProdAlt[nX][1], STR0001, {|| oIntShp:intProdByCod(aProdAlt[nX][1]) } )//"Integrating with Shopify..."
			Endif
		Next nX
	Endif

return



/*/{Protheus.doc} SPYOMSA010
    incluye o borra items del producto con shopify OMSA010
    @type  Function
    @author Alfredo Medrano
    @since 17/12/2020    
    /*/
function SPYOMSA010(oMdlDA1,oMdl2DA1,oMdl,nPosItem,nPosCodPro,aUmovStatus)

Local nY := 0
Local nX := 0
Local cCodTab := ""
Local aColsGrd :={}
Local aShpDel := {}
default nPosItem:= 0
default nPosCodPro:=0
default aUmovStatus:={}
		
    If ShpIntAt()
        aColsGrd := aGradeCols(oGrade,oMdlDA1:aCols,oMdlDA1:aHeader,"DA1_CODPRO","DA1_ITEMGR","DA1_PRCVEN","DA1_ITEM")	
        If nPosItem > 0
            nY := Ascan(oMdl2DA1:aHeader,{|x| AllTrim(x[2]) == "DA1_PRCVEN"})
            If nY > 0
                cCodTab := oMdl:GetValue("DA0MASTER","DA0_CODTAB")
                DA1->(dbSetOrder(3))
                // Quando usar grade explode os itens para gravação
                For nX := 1 To Len(aColsGrd)
                    If oMdl2DA1:IsDeleted()
                        //Trato os itens que foram deletados do Grid.
                        aAdd( aShpDel, oMdl2DA1:GetValue(oMdl2DA1:aHeader[nPosCodPro,2]) )
                    ElseIf oMdl2DA1:SeekLine({{"DA1_ITEM",aColsGrd[nX,nPosItem]},{"DA1_CODPRO",aColsGrd[nX,nPosCodPro]}}) .AND. !oMdl2DA1:IsDeleted()
                        If !Empty(aColsGrd[nX,nY])
                            If DA1->(MsSeek(xFilial("DA1")+PadR(cCodTab,TamSX3("DA0_CODTAB")[1])+oMdl2DA1:GetValue(oMdl2DA1:aHeader[nPosItem,2])))
                                If DA1->DA1_PRCVEN <> aColsGrd[nX,nY] 
                                    aAdd( aUmovStatus, oMdl2DA1:GetValue(oMdl2DA1:aHeader[nPosCodPro,2]) )
                                EndIf
                            Else
                                //Se não encontrar trata-se de uma Inclusão
                                aAdd( aUmovStatus, oMdl2DA1:GetValue(oMdl2DA1:aHeader[nPosCodPro,2]) )
                            Endif
                        EndIf
                    EndIf
                Next nX
            EndIf
        EndIf	
        
        //Inclusão dos produtos que foram deletados da tabela
        For nX := 1 to Len(aShpDel)
            If aScan(aUmovStatus, aShpDel[nX] ) == 0
                aAdd( aUmovStatus, aShpDel[nX] )
            EndIF
        Next nX
        

    EndIf

return

/*/{Protheus.doc} SPYUOMSA10
    Verifica integração com ShopiFy OMSA010
    @type  Function
    @author Alfredo Medrano
    @since 17/12/2020    
/*/
Function SPYUOMSA10(aUmovStatus)
Local nX := 0
Local oIntShp
Default aUmovStatus := {}

If ShpIntAt()	
    For nX := 1 to Len(aUmovStatus)
        If ShpIntProd(aUmovStatus[nX]) //Verifica integração com ShopiFy
            oIntShp := ShpInteg():New()
            MsgRun( aUmovStatus[nX], STR0001, {|| oIntShp:intProdByCod(aUmovStatus[nX]) } )
        EndIF
    Next nX
EndIf   

Return 

/*/{Protheus.doc} SPYICRM980
    Verifica cliente ShopiFy CRMA980
    @type  Function
    @author Alfredo Medrano
    @since 17/12/2020    
/*/
function SPYICRM980(oModel)
    If ShpIntAt()
        oModel:InstallEvent("SHP_" + ID_INT_CUSTOMER ,, ShpInteg():New())
    EndIf
return

/*/{Protheus.doc} SPYPMTA010
    Elimina o altera producto ShopiFy MATA010
    @type  Function
    @author Alfredo Medrano
    @since 17/12/2020    
/*/
function SPYPMTA010(oModel,cB1_COD, nDEL, nUPD)
    If ShpIntAt()
        If (oModel:GetOperation() == nDEL .Or. oModel:GetOperation() == nUPD) ;
            .AND. ShpIntProd(cB1_COD)
           oModel:InstallEvent("SHP_" + ID_INT_PRODUCT ,, ShpInteg():New())
        EndIF
    EndIf
return

/*/{Protheus.doc} SPYDMTA010
    Elimina producto ShopiFy MATA010
    @type  Function
    @author Alfredo Medrano
    @since 17/12/2020    
/*/
function SPYDMTA010(cB1_COD)
Local lRet := .T.
    If ShpIntAt()
        If !ShpDelProd(cB1_COD)
            lRet:= .F.
        Endif		
	EndIf
return lRet

/*/{Protheus.doc} SPYCMAT035
    integra cliente en ShopiFy MATA035
    @type  Function
    @author Alfredo Medrano
    @since 17/12/2020    
/*/
function SPYCMAT035()

   	If ShpIntAt()
		    Processa( {|| SHP00001(ID_INT_CUSTOM_COLLECTION) }, STR0002, STR0001 ,.F.)//"Wait..."/"Integrating with Shopify..."
	EndIf   

return


/*/{Protheus.doc} SPYIMAT035  
    Verifica integração com ShopiFy MATA035
    @type  Function
    @author Alfredo Medrano
    @since 17/12/2020    
/*/
function SPYIMAT035(oModel)
	If ShpIntAt()
		oModel:InstallEvent("SHP_" + ID_INT_CUSTOM_COLLECTION ,, ShpInteg():New())
	EndIf
Return


/*/{Protheus.doc} SPYIMAT550
    integra productos ShopiFy MATA550
    @type  Function
    @author Alfredo Medrano
    @since 17/12/2020    
/*/
function SPYIMAT550(aProdutos,aProdAlt)
    default aProdutos := {}
    default aProdAlt := {}

	If ShpIntAt()
		ShpProdC(aProdutos, aProdAlt)
	EndIf
Return


/*/{Protheus.doc} SPYDMAT550
    Elimina productos ShopiFy MATA550
    @type  Function
    @author Alfredo Medrano
    @since 17/12/2020    
/*/
function SPYDMAT550(cCod)
    Local lRet := .T.
    default cCod := ""
	
    If ShpIntAt()
	    lRet := ShpDelProd(cCod)
	EndIf
Return lRet

/*/{Protheus.doc} IntegraShp
    Verifica si será activada la integhracion Shopify 
    @type  Function
    @author Alfredo Medrano
    @since 21/04/2021    
/*/
Function IntegraShp()
    Local lRet := .F.
    Local lShopify := SuperGetMv("MV_SHOPIFY",.F.,.F.)

    If cPaisLoc == "EUA" 
        If lShopify
            lRet := .T.
        Else
            Help( ,, 'Help',, STR0164, 1, 0 ) //"Para hacer uso de la integración E commerce Shopify con Protheus es necesario activar el parámetro MV_SHOPIFY = .T."
       Endif
    EndIf

Return lRet
