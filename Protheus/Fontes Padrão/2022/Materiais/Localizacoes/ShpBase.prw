#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"
#INCLUDE "TOPCONN.CH"

#DEFINE PARAM 1
#DEFINE VALUE 2

/*/{Protheus.doc} ShpBase
    Base class to center the common methods
    @author Yves Oliveira
    @since 26/02/2020
    /*/
Class ShpBase
    Data id     As String//Recno
    Data idExt  As String//Id Shopify
    Data apiVer As String
    Data verb   As String
    Data path   As String
    Data body   As String
    Data error  As String
    Data params As Array
    Data bError       As CodeBlock
    Data cIntegration As String    
    
    Method new() Constructor
    Method setErrorBlock()
    Method setRequestBody(cBody)//Implemented in subclasses
    Method setPath(cPath)
    Method setVerb(cVerb)
    Method setUrlParams(aParams)
    Method buildUrlParams()
    Method requestToShopify()
    Method saveError()
    Method isIntValid()
    Method procResponse(oResponse,cResponse)//Implemented in subclasses
    Method procError(oResponse,cResponse)//Implemented in subclasses
EndClass

/*/{Protheus.doc} new
This method sets the constructor
@author Yves Oliveira
@since 26/02/2020
@type method
/*/
Method new() Class ShpBase
    ::id     := ""
    ::path   := ""
    ::apiVer := ShpGetPar("VERAPI")
	::error  := ""
    ::body   := ""
    ::verb   := ""
    ::params := {}
    ::setErrorBlock()
Return


/*/{Protheus.doc} setErrorBlock
This method sets the error block used to handle errors from the Shopify API
@author Yves Oliveira
@since 17/02/2020
@type method
/*/
Method setErrorBlock() class ShpBase
	::bError   := ErrorBlock({ |oError| ::error += oError:Description})
Return

/*/{Protheus.doc} setPath
    Method to set the request
    @author Yves Oliveira
    @since 26/02/2020
    /*/
Method setPath(cPath) Class ShpBase
    Local lRet := .F.

    Default cPath := ""
    
    BEGIN SEQUENCE
        If !Empty(cPath)
            ::path := cPath
        Else
            If Empty(::cIntegration)
                ::error := STR0009//"Integration Id not defined."
                BREAK
            EndIf

            If !Empty(::idExt) .And. Val(::idExt) > 0
                ::path := "/admin/api/" + ::apiVer + "/" + Lower(::cIntegration) + "/" + AllTrim(::idExt) +  ".json"
            Else
                ::path := "/admin/api/" + ::apiVer + "/" + Lower(::cIntegration) + ".json"
            EndIf
        EndIf
        lRet := .T.
    RECOVER
        lRet := .F.
    END SEQUENCE
Return lRet 

/*/{Protheus.doc} setVerb
    Method to set the verb
    @author Yves Oliveira
    @since 27/02/2020
    /*/
Method setVerb(cVerb) Class ShpBase

    Default cVerb := ""

    If !Empty(cVerb)
        ::verb := cVerb
    Else
        If !Empty(::idExt) .And. Val(::idExt) > 0
            ::verb := REST_METHOD_PUT
        Else
            ::verb := REST_METHOD_POST
        EndIf
    EndIf
    
Return 

/*/{Protheus.doc} setParameters
    Method to set the parameters of Shopify request
    @author Yves Oliveira
    @since 25/03/2020    
    /*/
Method setUrlParams(aParams) Class ShpBase
    ::params := aClone(aParams)
Return 

/*/{Protheus.doc} buildUrlParams
    Method to append the parameters on Shopify path
    @author Yves Oliveira
    @since 25/03/2020    
    /*/
Method buildUrlParams() Class ShpBase
    Local nI
    If Len(::params) > 0
        ::path += "?"
        for nI := 1 to Len(::params)
            ::path += ::params[nI][PARAM] + "=" + ::params[nI][VALUE]
        next nI
    EndIf
Return

/*/{Protheus.doc} isIntValid
    Method to implement validations
    @author Yves Oliveira
    @since 02/03/2020
    /*/
Method isIntValid() Class ShpBase    
Return .T.

/*/{Protheus.doc} setRequestBody
    Method to create a request body
    @author Yves Oliveira
    @since 17/02/2020
/*/
Method setRequestBody(cBody) Class ShpBase
    
    Default cBody := Nil

    If cBody <> Nil
        ::body := cBody
    Else
        Alert(STR0008)
        BREAK
    EndIf    
Return

/*/{Protheus.doc} requestToShopify
    Method to send a request against Shopify API
    @author Yves Oliveira
    @since 26/02/2020
    /*/
Method requestToShopify() Class ShpBase
    Local nVarNameLen := 100
    Local lRet        := .F.
    Local oApiClient  := Nil

    SetVarNameLen(nVarNameLen)

    BEGIN SEQUENCE

        If !::isIntValid()
            ::error := STR0010 + CRLF + ::error //"There are errors in the integration"
			BREAK
        EndIf

        oApiClient := ShpApi():new()

        If !oApiClient:setURL()
			::error := oApiClient:error
			BREAK
		EndIf

        If !::setPath()
            ErrorBlock(::bError)  
        EndIf

        ::buildUrlParams()

        If !oApiClient:setPath(::path)
			::error := oApiClient:error
			BREAK
		EndIf

		If !oApiClient:setHeader({})
			::error := oApiClient:error
			BREAK
		EndIf

        If !::setRequestBody()
            ::error := STR0005//"Failed to build the request body"
			BREAK
        EndIf

        If Empty(::verb)
            ::setVerb()
        EndIf

        if !oApiClient:sendRequest(::verb, .T., ::body)
			::error := oApiClient:error
			BREAK
		endif

        lRet := .T.
    RECOVER
        lRet := .F.
    END SEQUENCE
    ErrorBlock(::bError)  
    
    If !Empty(::error)
        lRet := .F.
 
        If !::procError(oApiClient:resultParsedObject,oApiClient:resultString) //methodo para tratar erros se possivel
 
            ::saveError()

            If IsBlind()
                FWLogMsg(STR0151, , STR0152, STR0153, FunName(), , STR0012 + CRLF + ::error)//"ERROR"//SHOPIFY_INTEGRATION//SHOPIFY      
            EndIf
        EndIf

    Else
        ::procResponse(oApiClient:resultParsedObject,oApiClient:resultString)
    EndIf

    SetVarNameLen(nVarNameLen)

Return lRet

/*/{Protheus.doc} saveError
    Method to save errors
    @author Yves Oliveira
    @since 27/02/2020
    /*/
Method saveError() Class ShpBase   
    Local aArea := GetArea()
    Local lRet  := .F.

    BEGIN SEQUENCE
        ShpSaveErr(::id, ::idExt, ::cIntegration, ::error, ::path, ::apiVer, ::body, ::verb, SHP_STATUS_PENDING)
        lRet := .T.
    END SEQUENCE
    RestArea(aArea)
Return lRet


/*/{Protheus.doc} procResponse()
    Method for processing the API response
    @author Yves Oliveira
    @since 11/03/2020
    /*/
Method procResponse(oResponse,cResponse) Class ShpBase
    Alert(STR0011)
    BREAK
Return


/*/{Protheus.doc} procResponse()
    Method for processing the API response
    @author Yves Oliveira
    @since 11/03/2020
    /*/
Method procError(oResponse,cResponse) Class ShpBase
    //ShpSaveErr(::id, ::idExt, ::cIntegration, ::error, ::path, ::apiVer, ::body, ::verb, SHP_STATUS_PENDING)
    Local aArea    := GetArea()
	Local cQuery   := ""
	Local cAlias   := GetNextAlias()
	Local cAliasTmp
	Local cAliasTm2
    Local lRet := .F. 

    If ::cIntegration == "PRODUCTS" .AND. "404 NOTFOUND" $ Upper(::error)

        If Select(cAlias) > 0
            (cAlias)->(DbCloseArea())
        EndIf

        cQuery := "SELECT * FROM  " + RetSqlTab("A1D") + CRLF
        cQuery += " WHERE (D_E_L_E_T_ = ' ' " + CRLF
        cQuery += "  AND A1D_FILIAL = '" + xFilial("A1D") + "'" + CRLF
        cQuery += "  AND A1D_ALIAS = 'A1M' " + CRLF
        cQuery += "  AND A1D_IDEXT   = '" + ::idExt + "' "  + CRLF
        cQuery += "  AND A1D_ID      = '" + ::id      + "') " + CRLF
        cQuery += "ORDER BY R_E_C_N_O_ " + CRLF
        TcQuery cQuery new Alias &cAlias
        
        DbSelectArea(cAlias)
        (cAlias)->(DbGoTop())

    	While !(cAlias)->(Eof())

            DbSelectArea("A1D")
            A1D->(DbSetOrder(2))//A1D_FILIAL+A1D_ALIAS+A1D_ID+A1D_IDEXT+A1D_ALIASP+A1D_IDPAI
            cSearch := (cAlias)->A1D_FILIAL+(cAlias)->A1D_ALIAS+(cAlias)->A1D_ID+(cAlias)->A1D_IDEXT+(cAlias)->A1D_ALIASP+(cAlias)->A1D_IDPAI

            If A1D->(DbSeek(cSearch))

                RecLock("A1D",.F.)
                A1D->(DbDelete())
                A1D->(MsUnlock())

                //aqui eu busco todos ai pai
                cAliasTmp:= GetNextAlias()
                cQuery := "SELECT * FROM  " + RetSqlTab("A1D") + CRLF
                cQuery += " WHERE D_E_L_E_T_     = ' ' " + CRLF
                cQuery += "  AND A1D_FILIAL       = '" + xFilial("A1D") + "'" + CRLF
                cQuery += "  AND A1D_IDPAI       = '" + ::id      + "' " + CRLF
                cQuery += "ORDER BY R_E_C_N_O_ " + CRLF   
                TcQuery cQuery new Alias &cAliasTmp
                
                DbSelectArea(cAliasTmp)
                (cAliasTmp)->(DbGoTop())

                While !(cAliasTmp)->(Eof())

                    DbSelectArea("A1D")
                    A1D->(DbSetOrder(2))//A1D_FILIAL+A1D_ALIAS+A1D_ID+A1D_IDEXT+A1D_ALIASP+A1D_IDPAI
                    cSearch :=  (cAliasTmp)->A1D_FILIAL+ (cAliasTmp)->A1D_ALIAS+ (cAliasTmp)->A1D_ID+ (cAliasTmp)->A1D_IDEXT+ (cAliasTmp)->A1D_ALIASP+ (cAliasTmp)->A1D_IDPAI
                    If A1D->(DbSeek(cSearch))
                        RecLock("A1D",.F.)
                        A1D->(DbDelete())
                        A1D->(MsUnlock())

                        //aqui eu desco mais um niverl
                        //aqui eu busco todos ai pai
                        cAliasTm2:= GetNextAlias()
                        cQuery := "SELECT * FROM  " + RetSqlTab("A1D") + CRLF
                        cQuery += " WHERE (D_E_L_E_T_     = ' ' " + CRLF
                        cQuery += "  AND A1D_FILIAL       = '" + xFilial("A1D") + "'" + CRLF
                        cQuery += "  AND A1D_IDPAI       = '" + (cAliasTmp)->A1D_ID     + "') " + CRLF
                        cQuery += "ORDER BY R_E_C_N_O_ " + CRLF   
                        TcQuery cQuery new Alias &cAliasTm2
                        
                        DbSelectArea(cAliasTm2)
                        (cAliasTm2)->(DbGoTop())

                        While !(cAliasTm2)->(Eof())

                            DbSelectArea("A1D")
                            A1D->(DbSetOrder(2))//A1D_FILIAL+A1D_ALIAS+A1D_ID+A1D_IDEXT+A1D_ALIASP+A1D_IDPAI
                            cSearch :=  (cAliasTm2)->A1D_FILIAL+ (cAliasTm2)->A1D_ALIAS+ (cAliasTm2)->A1D_ID+ (cAliasTm2)->A1D_IDEXT+ (cAliasTm2)->A1D_ALIASP+ (cAliasTm2)->A1D_IDPAI
                            If A1D->(DbSeek(cSearch))
                                RecLock("A1D",.F.)
                                A1D->(DbDelete())
                                A1D->(MsUnlock())
                            endIf     
                            (cAliasTm2)->(dbSkip())  

                        EndDo     
                        (cAliasTm2)->(dbCloseArea())  

                    EndIf                         

                    (cAliasTmp)->(dbSkip()) 
                EndDo

                (cAliasTmp)->(DbCloseArea())

            EndIf 

            (cAlias)->(dbSkip()) 

        EndDo
	
	    (cAlias)->(DbCloseArea())

        lRet := .T.
    endif


	RestArea(aArea)	

Return lRet
