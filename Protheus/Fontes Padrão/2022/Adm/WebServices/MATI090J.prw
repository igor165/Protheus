#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"
#INCLUDE "MATI090J.CH"

Static __aFields  := {}
Static __oGetJson := JsonObject():New()

// Dummy Function
Function MATI090J()
Return

//-------------------------------------------------------------------
/*/ {REST Web Service} MATI090J
    @version 12.1.17
    @since 10/11/2018
    @author SquadCP
/*/
//-------------------------------------------------------------------
WSRESTFUL CurrencyQuotes	DESCRIPTION STR0001 //"Cadastro de Cambio."
    // Query Params
    WSDATA page         As INTEGER Optional
    WSDATA pageSize     As INTEGER Optional
    WSDATA fields       As STRING  Optional
    // URL Params
    WSDATA date         As STRING  Optional

    WSMETHOD GET Main ;
    DESCRIPTION STR0002 ; //"Carrega as taxas cambiais de todas as moedas."
    WSSYNTAX "/api/fin/v1/CurrencyQuotes" ;
    PATH "/api/fin/v1/CurrencyQuotes"

    WSMETHOD GET DailyQuote ;
    DESCRIPTION STR0003 ; //"Carrega as taxas cambiais de todas as moedas em uma data."
    WSSYNTAX "/api/fin/v1/CurrencyQuotes/{date}" ;
    PATH "/api/fin/v1/CurrencyQuotes/{date}"

    WSMETHOD POST Main ;
    DESCRIPTION STR0004 ; //"Inclui taxas de cambio para diversas moedas."
    WSSYNTAX "/api/fin/v1/CurrencyQuotes" ;
    PATH "/api/fin/v1/CurrencyQuotes"

    WSMETHOD PUT Main ;
    DESCRIPTION STR0005 ; //"Altera taxas de cambio por data."
    WSSYNTAX "/api/fin/v1/CurrencyQuotes/{date}" ;
    PATH "/api/fin/v1/CurrencyQuotes/{date}"

    WSMETHOD DELETE Main ;
    DESCRIPTION STR0006 ;   //"Exclui taxas de cambio por data."
    WSSYNTAX "/api/fin/v1/CurrencyQuotes/{date}" ;
    PATH "/api/fin/v1/CurrencyQuotes/{date}"
END WSRESTFUL 

/*/--------------------------------------------------------------------------/*/
WSMETHOD GET Main WSRECEIVE page,pageSize,fields WSSERVICE CurrencyQuotes

    Local aFatherAlias  As Array
    Local aQryStrAux    As Array
    Local cError        As Character
    Local cIndexKey     As Character
    Local lRet          As Logical
    Local nI            As Numeric
    Local nX            As Numeric
    Local oApiManager   As Object

    Default Self:page       := 1
    Default Self:pageSize   := 10
    Default Self:fields     := ""


    aFatherAlias	:= {"SM2", "items", "items"}
	cIndexKey		:= "M2_DATA"
    // Trata parametro fields
    If Type("Self:fields") != "U" .and. !Empty(Self:fields)
        __aFields   := StrToKarr(Self:fields,",")
        Self:fields := ""
        nI := aScan(Self:aQueryString,{|x| x[1] == "FIELDS" })
        Self:aQueryString[nI] := {"FIELDS"}
        For nX := 1 to Len(__aFields)
            If !(__aFields[nX] = "ListOfCurrency")
                aAdd(Self:aQueryString[nI], __aFields[nX])
                Self:fields += __aFields[nX]
            EndIf
        Next nX
        If Len(Self:aQueryString[nI]) == 1  // Por default, traz todos os campos do ApiMap
            If Len(Self:aQueryString) > 1
                For nX := 1 to Len(Self:aQueryString)
                    If Self:aQueryString[nX][1] != "FIELDS" 
                        aAdd(aQryStrAux,Self:aQueryString[nX])
                    EndIf
                Next nX
                Self:aQueryString := aQryStrAux
            Else
                aSize(Self:aQueryString, 0)
            EndIf
        EndIf
    EndIf

    Self:SetContentType("application/json")

	oApiManager := GetFWAPIMan("MATI090J","1.000",aFatherAlias)

	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)
	
	If lRet
		Self:SetResponse( FWJsonSerialize(__oGetJson, .T., .T., .T.) )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
    __oGetJson := Nil

Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD GET DailyQuote PATHPARAM date WSRECEIVE page,pageSize,fields WSSERVICE CurrencyQuotes

    Local aFatherAlias  As Array
    Local aQryStrAux    As Array
    Local aFilter       As Array
    Local cError        As Character
    Local cIndexKey     As Character
    Local nI            As Numeric
    Local nX            As Numeric
    Local lRet          As Logical
    Local oApiManager   As Object 

    Default Self:date       := ""
    Default Self:page       := 1
    Default Self:pageSize   := 10
    Default Self:fields     := ""

    Self:date := CastUTC(Self:date)

    aFilter         := {}
    aFatherAlias	:= {"SM2", "items", "items"}
	cIndexKey		:= "M2_DATA"
    // Trata parametro fields
    If Type("Self:fields") != "U" .and. !Empty(Self:fields)
        __aFields   := StrToKarr(Self:fields,",")
        Self:fields := ""
        nI := aScan(Self:aQueryString,{|x| x[1] == "FIELDS" })
        Self:aQueryString[nI] := {"FIELDS"}
        For nX := 1 to Len(__aFields)
            If !(__aFields[nX] = "ListOfCurrency")
                aAdd(Self:aQueryString[nI], __aFields[nX])
                Self:fields += __aFields[nX]
            EndIf
        Next nX
        If Len(Self:aQueryString[nI]) == 1  // Por default, traz todos os campos do ApiMap
            If Len(Self:aQueryString) > 1
                For nX := 1 to Len(Self:aQueryString)
                    If Self:aQueryString[nX][1] != "FIELDS" 
                        aAdd(aQryStrAux,Self:aQueryString[nX])
                    EndIf
                Next nX
                Self:aQueryString := aQryStrAux
            Else
                aSize(Self:aQueryString, 0)
            EndIf
        EndIf
    EndIf

    Aadd(aFilter, {"SM2", "items",{"M2_DATA = '" + Self:date + "'"}})

    Self:SetContentType("application/json")

	oApiManager := GetFWAPIMan("MATI090J","1.000",aFatherAlias,aFilter)

	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, .F., cIndexKey)
	
	If lRet
		Self:SetResponse( FWJsonSerialize(__oGetJson, .T., .T., .T.) )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
    __oGetJson := Nil

Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD POST Main WSSERVICE CurrencyQuotes

    Local aQueryString As Array
    Local aFatherAlias As Array
    Local aRet         As Array 
    Local cBody 	   As Character
    Local cIndexKey    As Character
	Local cError	   As Character
    Local lRet		   As Logical
	Local oApiManager  As Object

	Self:SetContentType("application/json")

    aFatherAlias := {"SM2", "items", "items"}
	cIndexKey	 := "M2_DATA"
    aQueryString := Self:aQueryString
    cBody 	     := Self:GetContent()
    oApiManager  := GetFWAPIMan("MATI090J","1.000",{"SM2","items", "items"})

    // [1] = .T. caso a inclusao tenha sido efetuada, no contrario .F.
    // [2] = se [1], internalId, no contrario errorMessage
	aRet := SetQuote(MODEL_OPERATION_INSERT, , cBody)

	If aRet[1]
		aAdd(aQueryString,{"Date",aRet[2]})
		lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)
    Else
        lRet := .F.
	EndIf

	If lRet
		Self:SetResponse( FWJsonSerialize(__oGetJson, .T., .T., .T.) )
	Else
		cError := aRet[2]
		SetRestFault( aRet[3], EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
    __oGetJson := Nil
	FreeObj( aQueryString )

Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD PUT Main PATHPARAM date WSSERVICE CurrencyQuotes

    Local aFilter      As Array
    Local aQueryString As Array
    Local aFatherAlias As Array
    Local aRet         As Array
    Local cBody 	   As Character
    Local cIndexKey    As Character
	Local cError	   As Character
    Local lRet		   As Logical
	Local oApiManager  As Object

    Default Self:date  := ""

    Self:date := CastUTC(Self:date)

	Self:SetContentType("application/json")

    aFilter      := {}
    aFatherAlias := {"SM2", "items", "items"}
	cIndexKey	 := "M2_DATA"
    aQueryString := Self:aQueryString
    cBody 	     := Self:GetContent()
    Aadd(aFilter, {"SM2", "items",{"M2_DATA = '" + Self:date + "'"}})
	oApiManager  := GetFWAPIMan("MATI090J","1.000",{"SM2","items", "items"},aFilter)

    // [1] = .T. caso a alteracao tenha sido efetuada, no contrario .F.
    // [2] = se [1], internalId, no contrario errorMessage
	aRet := SetQuote(MODEL_OPERATION_UPDATE, Self:date, cBody)

	If aRet[1]
		lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias,.F. , cIndexKey)
    Else
        oApiManager:SetJsonError("417","Expectation Failed", aRet[2])
        lRet := .F.
	EndIf

	If lRet
		Self:SetResponse( FWJsonSerialize(__oGetJson, .T., .T., .T.) )
	Else
		cError := aRet[2]
		SetRestFault( aRet[3], EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
    __oGetJson := Nil
	FreeObj( aQueryString )

Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD DELETE Main PATHPARAM date WSSERVICE CurrencyQuotes

    Local aRet         As Array
    Local cJson        As Character
	Local cError	   As Character
    Local lRet		   As Logical
    Local oResponse    As Object

    Default Self:date  := ""

    Self:date := CastUTC(Self:date)

	Self:SetContentType("application/json")

    oResponse    := JsonObject():New()

    // [1] = .T. caso a exclusao tenha sido efetuada, no contrario .F.
    // [2] = se [1], sucessMessage, no contrario errorMessage
    // [3] = codigo de erro http
	aRet := DeleteSM2(Self:date)

	If aRet[1]
        oResponse["OK"] := aRet[2]
		cJson := FWJsonSerialize(oResponse, .F., .F., .T.)
        Self:SetResponse(cJson)
	Else
		cError := aRet[2]
		SetRestFault( aRet[3], EncodeUtf8(cError) )
	EndIf

    lRet := aRet[1]

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMain
    Estrutura a ser utilizada na classe ServicesApiManager
    @author Igor Sousa do Nascimento
    @since 22/11/2018
/*/
//-------------------------------------------------------------------
Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey) As Logical

	Local aArea             As Array
    Local aRelation 		As Array
	Local aChildrenAlias	As Array
    Local aCpos      		As Array
	Local lRet 				As Logical
    Local nI                As Numeric
    Local nX                As Numeric
    Local oList             As Object
    Local oModel            As Object
    Local oModelSub         As Object

	Default oApiManager		:= Nil
	Default aQueryString	:= {,}
	Default lHasNext		:= .T.
	Default cIndexKey		:= ""

    aRelation 		:= {}
	aChildrenAlias	:= {}
    aCpos           := {}
	lRet 			:= .T.

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

	FreeObj( aRelation )
	FreeObj( aChildrenAlias )
	FreeObj( aFatherAlias )

    If lRet
        aArea       := GetArea()
        
        dbSelectArea("SM2")
        dbSetOrder(1)
        oModel:= FWLoadModel("MATA090")
        oModel:SetOperation(1)
        oModel:Activate()
        oModelSub:= oModel:GetModel("SM2MASTER")

        If lHasNext
            __oGetJson  := oApiManager:GetJsonObject()

            If !Empty(__aFields)
                If aScan(__aFields,{|x| x == "ListOfCurrency" }) > 0
                    aAdd(aCpos, .T.)
                    aAdd(aCpos, .T.)
                    aAdd(aCpos, .T.)
                Else
                    aAdd(aCpos, aScan(__aFields,{|x| x == "ListOfCurrency.Code"   }) > 0)
                    aAdd(aCpos, aScan(__aFields,{|x| x == "ListOfCurrency.Name"   }) > 0)
                    aAdd(aCpos, aScan(__aFields,{|x| x == "ListOfCurrency.Symbol" }) > 0)
                EndIf
                If aCpos[1] .or. aCpos[2] .or. aCpos[3]
                    For nI := 1 to Len(__oGetJson["items"])
                        SM2->(dbSeek(CastUTC(__oGetJson["items"][nI]["Date"])))
                        __oGetJson["items"][nI]["ListOfCurrency"] := {}
                        nX := 1
                        While oModelSub:HasField("M2_MOEDA"+cValToChar(nX))
                            oList  := JsonObject():New()
                            oList["Quote"]   := SM2->&("M2_MOEDA"+cValToChar(nX))
                            If aCpos[1]
                                oList["Code"] := cValToChar(nX)
                            EndIf
                            If aCpos[2]
                                oList["Name"]  := SuperGetMV("MV_MOEDA"+cValToChar(nX),,"")
                            EndIf
                            If aCpos[3]
                                oList["Symbol"] := SuperGetMV("MV_SIMB"+cValToChar(nX),,"")
                            EndIf
                            aAdd(__oGetJson["items"][nI]["ListOfCurrency"],oList)
                            nX++
                        EndDo
                    Next nI
                EndIf
            Else
                For nI := 1 to Len(__oGetJson["items"])
                    SM2->(dbSeek(CastUTC(__oGetJson["items"][nI]["Date"])))
                    __oGetJson["items"][nI]["ListOfCurrency"] := {}
                    nX := 1
                    While oModelSub:HasField("M2_MOEDA"+cValToChar(nX))
                        oList  := JsonObject():New()
                        oList["Quote"]   := SM2->&("M2_MOEDA"+cValToChar(nX))
                        oList["Code"]    := cValToChar(nX)
                        oList["Name"]    := SuperGetMV("MV_MOEDA"+cValToChar(nX),,"")
                        oList["Symbol"]  := SuperGetMV("MV_SIMB"+cValToChar(nX),,"")
                        aAdd(__oGetJson["items"][nI]["ListOfCurrency"],oList)
                        nX++
                    EndDo
                Next nI
            EndIf
        Else
            __oGetJson:FromJSON(oApiManager:ToObjectJson())

            If !Empty(__aFields)
                If aScan(__aFields,{|x| x == "ListOfCurrency" }) > 0
                    aAdd(aCpos, .T.)
                    aAdd(aCpos, .T.)
                    aAdd(aCpos, .T.)
                Else
                    aAdd(aCpos, aScan(__aFields,{|x| x == "ListOfCurrency.Code"   }) > 0)
                    aAdd(aCpos, aScan(__aFields,{|x| x == "ListOfCurrency.Name"   }) > 0)
                    aAdd(aCpos, aScan(__aFields,{|x| x == "ListOfCurrency.Symbol" }) > 0)
                EndIf
                If aCpos[1] .or. aCpos[2] .or. aCpos[3]
                    SM2->(dbSeek(CastUTC(__oGetJson["Date"])))
                    __oGetJson["ListOfCurrency"] := {}
                    nX := 1
                    While oModelSub:HasField("M2_MOEDA"+cValToChar(nX))
                        oList  := JsonObject():New()
                        oList["Quote"]   := SM2->&("M2_MOEDA"+cValToChar(nX))
                        If aCpos[1]
                            oList["Code"] := cValToChar(nX)
                        EndIf
                        If aCpos[2]
                            oList["Name"]  := SuperGetMV("MV_MOEDA"+cValToChar(nX),,"")
                        EndIf
                        If aCpos[3]
                            oList["Symbol"] := SuperGetMV("MV_SIMB"+cValToChar(nX),,"")
                        EndIf
                        aAdd(__oGetJson["ListOfCurrency"],oList)
                        nX++
                    EndDo
                EndIf
            Else
                SM2->(dbSeek(CastUTC(__oGetJson["Date"])))
                __oGetJson["ListOfCurrency"] := {}
                nX := 1
                While oModelSub:HasField("M2_MOEDA"+cValToChar(nX))
                    oList  := JsonObject():New()
                    oList["Quote"]   := SM2->&("M2_MOEDA"+cValToChar(nX))
                    oList["Code"]    := cValToChar(nX)
                    oList["Name"]    := SuperGetMV("MV_MOEDA"+cValToChar(nX),,"")
                    oList["Symbol"]  := SuperGetMV("MV_SIMB"+cValToChar(nX),,"")
                    aAdd(__oGetJson["ListOfCurrency"],oList)
                    nX++
                EndDo
            EndIf
        EndIf
        RestArea(aArea)
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetQuote
    Realiza inclusao e alteracao do cambio
    @author Igor Sousa do Nascimento
    @since 22/11/2018
/*/
//-------------------------------------------------------------------
Static Function SetQuote(nOpc, cId, cBody) As Array

    Local cRet      As Character
    Local cCatch    As Character
    Local cCpoM2    As Character
    Local lRet      As Logical
    Local nCodeErr  As Numeric
    Local nI        As Numeric
    Local oModel    As Object
    Local oModelSub As Object
    Local oJson     As Object

    Default nOpc    := MODEL_OPERATION_INSERT
    Default cId     := DtoS(dDatabase)
    Default cBody   := ""

    oJson    := JsonObject():New()
    cCatch   := oJson:FromJSON(cBody)

    If cCatch == Nil
        lRet := .T.
        If nOpc == MODEL_OPERATION_UPDATE
            dbSelectArea("SM2")
            dbSetOrder(1)
            If !SM2->(dbSeek(cId))
                cRet := STR0007 // "Cotacao nao localizada."
                lRet := .F.
                nCodeErr := 404
            EndIf
        EndIf
        If lRet
            oModel:= FWLoadModel("MATA090")
            oModel:SetOperation(nOpc)
            oModel:Activate()
            oModelSub:= oModel:GetModel("SM2MASTER")
            Begin Transaction
                If nOpc == MODEL_OPERATION_INSERT
                    oModelSub:SetValue("M2_DATA", CastUTC(oJson["Date"],.T.))
                    For nI := 1 to Len(oJson["ListOfCurrency"])
                        If oModelSub:HasField("M2_MOEDA" + oJson["ListOfCurrency"][nI]["Code"])
                            cCpoM2 := "M2_MOEDA" + oJson["ListOfCurrency"][nI]["Code"]
                            oModelSub:SetValue(cCpoM2, oJson["ListOfCurrency"][nI]["Quote"])
                        EndIf
                    Next nI
                Else
                    For nI := 1 to Len(oJson["ListOfCurrency"])
                        If oModelSub:HasField("M2_MOEDA" + oJson["ListOfCurrency"][nI]["Code"])
                            cCpoM2 := "M2_MOEDA" + oJson["ListOfCurrency"][nI]["Code"]
                            oModelSub:SetValue(cCpoM2, oJson["ListOfCurrency"][nI]["Quote"])
                        Else
                            cRet := STR0007 // "Cotacao nao localizada."
                            lRet := .F.
                            nCodeErr := 404
                        EndIf
                    Next nI
                EndIf
                If oModel:VldData()
                    oModel:CommitData()
                    cRet := DtoS(oModelSub:GetValue("M2_DATA"))
                    lRet := .T.
                Else
                    cRet := cValToChar(oModel:GetErrorMessage()[6])
                    lRet := .F.
                    nCodeErr := 417
                EndIf
            End Transaction
        EndIf
    Else
        lRet := .F.
        cRet := cCatch
    EndIf

Return {lRet,cRet,nCodeErr}

//-------------------------------------------------------------------
/*/{Protheus.doc} DeleteSM2
    Realiza exclusao das cotacoes em uma data
    @author Igor Sousa do Nascimento
    @since 22/11/2018
/*/
//-------------------------------------------------------------------
Static Function DeleteSM2(cId)

    Local cRet      As Character
    Local nCodeErr  As Numeric
    Local lRet      As Logical
    Local oModel    As Object

    Default cId     := DtoS(dDatabase)

    dbSelectArea("SM2")
    dbSetOrder(1)

    If SM2->(dbSeek(CastUTC(cId)))
        oModel:= FWLoadModel("MATA090")
        oModel:SetOperation(MODEL_OPERATION_DELETE)
        oModel:Activate()
        If oModel:VldData()
            oModel:CommitData()
            cRet := STR0008 //"Operacao realizada com sucesso."
            lRet := .T.
        Else
            cRet    := cValToChar(oModel:GetErrorMessage()[6])
            nCodeErr := 417
            lRet    := .F.
        EndIf
    Else
        cRet    := STR0009 //"Cotacao nao encontrada na data especificada."
        nCodeErr := 400
        lRet    := .F.
    EndIf

Return {lRet,cRet,nCodeErr}

//-------------------------------------------------------------------
/*/{Protheus.doc} ApiMap
    Estrutura a ser utilizada na classe ServicesApiManager
/*/
//-------------------------------------------------------------------
Static Function ApiMap() As Array

	Local aApiMap, aStructDef, aStructAlias As Array

    aApiMap		 := {}
    aStructDef	 := {}
    aStructAlias := {}

	aStructDef			:=	{"SM2","fields","items","items",;
                                {;
                                    {"CompanyId"					, "Exp:cEmpAnt"					},;
                                    {"BranchId"				    	, "Exp:cFilAnt"					},;
                                    {"CompanyInternalId"			, "M2_DATA"			            },;								
                                    {"Date"							, "M2_DATA"						};	
                                };
						    }

	aStructAlias  := {aStructDef}

	aApiMap := {"MATI090J","items","1.000","MATA090",aStructAlias, "items"}

Return aApiMap

//-------------------------------------------------------------------
/*/{Protheus.doc} CastUTC
    Trata formato UTC (AAAA-MM-DDTHH:MM:SS) da data
    @param cDate = Data a ser tratada
    @param lDtFormat = Se o retorno sera em tipo D ou C
    @author Igor Sousa do Nascimento
    @since 06/12/2018
/*/
//-------------------------------------------------------------------
Static Function CastUTC(cDate,lDtFormat)

    Local cAux   As Character
    Local lHifen As Logical
    Local lBarra As Logical
    Local lUTC   As Logical
    Local nAt    As Numeric

    Default cDate     := DtoS(dDataBase)
    Default lDtFormat := .F.

    nAt    := At("-",cDate,1)
    lHifen := nAt != 0
    lUTC   := nAt == 5  // AAAA-MM-DD
    lBarra := At("/",cDate,1) != 0
    If lBarra
        If ValType(cDate) == "C"
            cAux  := CToD(cDate)
        EndIf
        If !lDtFormat
            cDate := DtoS(cAux)
        EndIf
    ElseIf lHifen
        cAux :=  StrTran(cDate,"-","")
        If !lUTC
            // Conversao de DDMMAAAA para AAAAMMDD
            cDate := ""
            cDate += SubStr(cAux,5,4)
            cDate += SubStr(cAux,3,2)
            cDate += SubStr(cAux,1,2)
        Else
            cDate := cAux
        EndIf

        If lDtFormat 
            cDate := StoD(cDate)
        EndIf
    EndIf

Return cDate

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFWAPIMan
    Instancia e retorna uma referência da classe FWAPIManager
    @param cNome = Nome de identificação
    @param cVersion = Versão
    @param aFatherAlias = Alias da Tabela Alvo
    @param aFilter = Dados de Filtro Tabela alvo
    @author Norberto Monteiro de Melo
    @since 01/07/2020
/*/
//-------------------------------------------------------------------
Static Function GetFWAPIMan(cName AS Character, cVersion AS Character, aFatherAlias AS Array, aFilter AS Array) AS Object
    Local oApiManager As Object
    Default cName := "MATI090J"
    Default cVersion := "1.000"

	oApiManager := FWAPIManager():New(cName,cVersion)
	oApiManager:SetApiMap(ApiMap())
    If !EMPTY(aFatherAlias) .AND. VALTYPE(aFatherAlias) == 'A'
 	    oApiManager:SetApiAlias(aFatherAlias)
    EndIf
    If !EMPTY(aFilter) .AND. VALTYPE(aFilter) == 'A'
        oApiManager:SetApiFilter(aFilter)
    EndIf
	oApiManager:Activate()
    
Return oAPIManager