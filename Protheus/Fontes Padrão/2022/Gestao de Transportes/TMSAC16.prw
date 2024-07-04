#Include 'Protheus.ch'

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSBCARepomRelat()
Classe criada para comunicação com a REPOM.RELATORIO

@type function
@author Caio Murakami
@since 07/12/2020
@version 1.0
/*/
//--------------------------------------------------------------------
CLASS TMSBCARepomRelat

    //-- Auth
    DATA url_repom      As Character
    DATA grant_type     As Character
    DATA username       As Character
    DATA password       As Character
    DATA partner        As Character 
    DATA api_version    As Character
    DATA access_token   As Character
    DATA expires        As Numeric

    DATA last_error As Character
    DATA message_error As Array 
    DATA exibe_erro As Logical 

    METHOD New()    Constructor  
    METHOD RepomInfo()
    METHOD GetRepom()
    //-- Token
    METHOD Auth()               //-- POST /token    

    //-- AccountingStatement
    METHOD GetAccByCust()      //-- GET /Statement/Accounting/GetByCustomer
    METHOD GetAccByDate()       //-- GET /Statement/Accounting/GetByCustomerDateInicialDateFinal/{dateInicial}/{dateFinal}
    METHOD GetAccByID()         //-- GET /Statement/Accounting/GetCustomerByContratoID/{contratoID}
    METHOD GetAccByVge()        //-- GET /Statement/Accounting/GetCustomerByViagemID/{viagemID}
    METHOD GetAccByCli()        //-- GET /Statement/Accounting/GetCustomerByCodigoCliente/{codigoCliente}

    //-- FinancialBalance
    METHOD GetFinByDate()       //-- GET /Balance/Financial/GetByDateInicialDateFinal/{dateInicial}/{dateFinal} Get all Financial Statement by Customer National ID and Date

    //-- FinancialStatement
    METHOD GetFinStCust()       //-- GET /Statement/Financial/GetByCustomer
    METHOD GetFinStDate()       //-- GET /Statement/Financial/GetByCustomerDate/{date}
    METHOD GetFinStStart()      //-- GET /Statement/Financial/GetByCustomerStartDateEndDate/{startDate}/{endDate}

    METHOD GetIdShipping()
    METHOD ProcResultGet()
    

END CLASS

//-----------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@type function
@author Caio Murakami
@since 07/12/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD New() CLASS TMSBCARepomRelat

::RepomInfo()

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} RepomInfo()
Método para carregar os dados de conexão.

@type function
@author Rodrigo Pirolo
@since 07/12/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD RepomInfo() CLASS TMSBCARepomRelat

    Local aArea         := GetArea()
    Local aAreaDEG      := DEG->(GetArea())
    Local cCodOpe       := "01"
    Local lRet          := .F.

    DbSelectArea("DEG")
    DEG->( DbSetOrder(1) )

    If DEG->( DbSeek( xFilial("DEG") + cCodOpe ) )
        ::url_repom     := "http://qa.repom.com.br/Repom.Relatorio.WebAPI"
        ::grant_type    := "password"
        ::username      := AllTrim(DEG->DEG_USER)   //"1601"
        ::password      := AllTrim(DEG->DEG_SENHA)  //"z=nF7v"
        ::partner       := AllTrim(DEG->DEG_CNPJOP) //"29081265000143"
        ::last_error    := ""
        ::message_error := {} 
        ::api_version   := "1.0"
        ::exibe_erro    := !IsBlind()
        
        lRet := .T.
    Else 
         ::url_repom    := ""
        ::grant_type    := ""
        ::username      := ""
        ::password      := ""
        ::partner       := ""
        ::last_error    := ""
        ::message_error := {} 
        ::api_version   := "1.0"
        ::exibe_erro    := !IsBlind()
        ::access_token  := "" 
        
    EndIf

    RestArea( aAreaDEG )
    RestArea(aArea)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} Auth()
Método autenticador

@type function
@author Caio Murakami
@since 15/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD Auth() CLASS TMSBCARepomRelat
Local cEndPoint     := "/token"
Local aHeader       := {} 
Local lRet          := .T. 
Local oRest         := FwRest():New( ::url_repom ) 
Local cResult       := ""
Local oObj          := Nil 
Local cParams       := ""
Local oBody         := JsonObject():New()

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Content-Type: application/json" )
Aadd(aHeader, "x-api-version: " + ::api_version )

oBody["usuario"]    := ::username
oBody["senha"]      := ::password

cParams := oBody:ToJson()

oRest:SetPath(cEndPoint) 
oRest:SetPostParams( EncodeUTF8(cParams) )

TmsRepTrac("TMSBCARepomRelat - Auth")
TmsRepTrac( cParams )

lRet    := oRest:Post( aHeader ) 

If lRet
    cResult     := oRest:GetResult()        
    If FWJsonDeserialize(cResult,@oObj)
        ::access_token  := oObj:accessToken
    EndIf

    TmsRepTrac( cResult )
Else
    ::last_error   := AllTrim( oRest:GetLastError() ) + CHR(13) + AllTrim( Decodeutf8( oRest:GetResult() ) )
    
    Aadd( ::message_error , { AllTrim( oRest:GetLastError() ) , "04", ""})
    Aadd( ::message_error , { AllTrim( Decodeutf8( oRest:GetResult() )) , "04" , "" } )  
    Aadd( ::message_error , { AllTrim(cParams) , "04" , "" } ) 

    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf
    
    TmsRepTrac( ::last_error )
EndIf

FwFreeObj(oRest)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetAccByCust()
GET /Statement/Accounting/GetByCustomer

@type function    
@author     Caio Murakami
@since      07/12/2020
@version    1.0
/*/
//-----------------------------------------------------------------
METHOD GetAccByCust() CLASS TMSBCARepomRelat
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Statement/Accounting/GetByCustomer/"
Local cGet      := ""
Local aArea     := GetArea()

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )
aRet        := ::ProcResultGet( cGet )

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetAccByDate()
GET /Statement/Accounting/GetByCustomerDateInicialDateFinal/{dateInicial}/{dateFinal}

@type function     
@author     Caio Murakami
@since      07/12/2020
@version    1.0
/*/
//-----------------------------------------------------------------
METHOD GetAccByDate( dDatIni , dDatFim ) CLASS TMSBCARepomRelat
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Statement/Accounting/GetByCustomerDateInicialDateFinal/"
Local cGet      := ""
Local aArea     := GetArea()

Default dDatIni := dDataBase
Default dDatFim := dDatFim 

cPathPar    += Escape( FWTimeStamp( 5 , dDatIni , Time() ) + "/" + FWTimeStamp( 5 , dDatFim , Time() ) ) 

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )
aRet        := ::ProcResultGet( cGet )

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetAccByVge()
GET /Statement/Accounting/GetCustomerByViagemID/{viagemID}

@type function     
@author     Caio Murakami
@since      07/12/2020
@version    1.0
/*/
//-----------------------------------------------------------------
METHOD GetAccByVge( cFilOri, cViagem ) CLASS TMSBCARepomRelat
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Statement/Accounting/GetCustomerByViagemID/"
Local cGet      := ""
Local aArea     := GetArea()
Local cIdShipp  := ""

Default cFilOri := ""
Default cViagem := "" 

cIdShipp    := ::GetIdShipping(cFilOri,cViagem)
cPathPar    += cIdShipp 

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )
aRet        := ::ProcResultGet( cGet )

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetAccByID()
GET /Statement/Accounting/GetCustomerByContratoID/{contratoID}

@type function     
@author     Caio Murakami
@since      07/12/2020
@version    1.0
/*/
//-----------------------------------------------------------------
METHOD GetAccByID( cContrato ) CLASS TMSBCARepomRelat
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Statement/Accounting/GetCustomerByContratoID/"
Local cGet      := ""
Local aArea     := GetArea()

Default cContrato := ""

cPathPar    += cContrato 

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )
aRet        := ::ProcResultGet( cGet )

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetAccByCli()
GET /Statement/Accounting/GetCustomerByCodigoCliente/{codigoCliente}

@type function    
@author     Caio Murakami
@since      07/12/2020
@version    1.0
/*/
//-----------------------------------------------------------------
METHOD GetAccByCli( cFilOri , cViagem ) CLASS TMSBCARepomRelat
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Statement/Accounting/GetCustomerByCodigoCliente/"
Local cGet      := ""
Local aArea     := GetArea()

Default cFilOri := ""
Default cViagem := ""

cPathPar    += Escape(cFilOri + cViagem)

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )
aRet        := ::ProcResultGet( cGet )

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetIdShipping()
Obtém código da operação gerado na integração Shipping

@type function
@author Caio Murakami
@since 07/12/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetIdShipping( cFilOri, cViagem , cCodVei ) CLASS TMSBCARepomRelat
Local cRet      := "" 
Local aArea     := GetArea()
Local aAreaDTR  := DTR->(GetArea())

Default cFilOri := ""
Default cViagem := ""
Default cCodVei := ""

DTR->(dbSetOrder(3))
If DTR->( dbSeek( xFilial("DTR") + cFilOri + cViagem + RTrim(cCodVei) ))
    cRet    := RTrim( DTR->DTR_PRCTRA )
EndIf 

RestArea(aAreaDTR)
RestArea(aArea)
Return cRet 
//-----------------------------------------------------------------
/*/{Protheus.doc} ProcResultGet()
Processa resultado do JSON

@type function
@author Caio Murakami
@since 08/12/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD ProcResultGet( cGet ) CLASS TMSBCARepomRelat
Local aRet      := {}
Local aArea     := GetArea()
Local cJson     := ""
Local oResult   := ""
Local oJson     := Nil 
Local aNames    := {}
Local nCount    := 1 
Local nAux      := 1 

Default cGet    := ""

If FwJsonDeserialize(cGet,@oResult)
    If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSERESULT" ) 

        If  ValType( oResult:RESPONSERESULT )  == "A"
            For nAux := 1 To Len( oResult:RESPONSERESULT )
                aNames  := {}
                cJson   := FwJsonSerialize(oResult:RESPONSERESULT[nAux],.F.,.T.)
                oJson   := JsonObject():New()
                oJson:FromJson(cJson)

                aNames  := oJson:GetNames()
                Aadd( aRet , {} )
                For nCount := 1 To Len(aNames)                    
                    Aadd( aRet[Len(aRet)] , { aNames[nCount] ,  oJson[aNames[nCount]]   })
                Next nCount

                FwFreeArray(aNames)
                FwFreeObj(oJson)

            Next nAux 
        ElseIf  ValType( oResult:RESPONSERESULT )  == "O"
            aNames  := {}
            cJson   := FwJsonSerialize(oResult:RESPONSERESULT,.F.,.T.)
            oJson   := JsonObject():New()
            oJson:FromJson(cJson)

            aNames  := oJson:GetNames()
            Aadd( aRet , {} )
            For nCount := 1 To Len(aNames)                    
                Aadd( aRet[Len(aRet)] , { aNames[nCount] ,  oJson[aNames[nCount]]   })
            Next nCount

            FwFreeArray(aNames)
            FwFreeObj(oJson)
        EndIf 
    EndIf 
EndIf 

RestArea(aArea)
Return aRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} GetFinByDate()
Get all Financial Statement by Customer National ID and Date

@type function
@author Caio Murakami
@since 08/12/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetFinByDate(dDatIni, dDatFim ) CLASS TMSBCARepomRelat
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Balance/Financial/GetByDateInicialDateFinal/"
Local cGet      := ""
Local aArea     := GetArea()

Default dDatIni     := dDataBase
Default dDatFim     := dDataBase

cPathPar    += Escape( FWTimeStamp( 5 , dDatIni , Time() )  + "/" + FWTimeStamp( 5 , dDatFim , Time() ) ) 

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )
aRet        := ::ProcResultGet( cGet )

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetFinStCust()
GET /Statement/Financial/GetByCustomer
Get all Financial Statement by Customer

@type function
@author Caio Murakami
@since 08/12/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetFinStCust() CLASS TMSBCARepomRelat
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Statement/Financial/GetByCustomer"
Local cGet      := ""
Local aArea     := GetArea()

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )
aRet        := ::ProcResultGet( cGet )

RestArea( aArea )
Return aRet

 //-----------------------------------------------------------------
/*/{Protheus.doc} GetFinStDate()
GET /Statement/Financial/GetByCustomerDate/{date}
Get all Financial Statement by Customer National ID and Date

@type function
@author Caio Murakami
@since 08/12/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetFinStDate(dDate ) CLASS TMSBCARepomRelat
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Statement/Financial/GetByCustomerDate/"
Local cGet      := ""
Local aArea     := GetArea()

Default dDate    := dDataBase

cPathPar    += Escape( FWTimeStamp( 5 , dDate , Time() ) ) 

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )
aRet        := ::ProcResultGet( cGet )

RestArea( aArea )
Return aRet   
    
 //-----------------------------------------------------------------
/*/{Protheus.doc} GetFinStStart()
Get all Financial Statement by Customer National ID and Start Date and End Date

@type function
@author Caio Murakami
@since 08/12/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetFinStStart(dDatIni , dDatFim ) CLASS TMSBCARepomRelat
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Statement/Financial/GetByCustomerStartDateEndDate/"
Local cGet      := ""
Local aArea     := GetArea()

Default dDatIni     := dDataBase
Default dDatFim     := dDataBase

cPathPar    += Escape( FWTimeStamp( 5 , dDatIni , Time() )  + "/" + FWTimeStamp( 5 , dDatFim , Time() ) ) 

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )
aRet        := ::ProcResultGet( cGet )

RestArea( aArea )
Return aRet   

//-----------------------------------------------------------------
/*/{Protheus.doc} GetREPOM()
Realiza comunicação com a api da REPOM utilizando os parametros passados

@type function
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cPath       url repom 
@param      cPathPar    Parametro de Endereço 
@param      cToken      Senha
@param      cQueryPar   Parametro a ser buscado
@param      cVersion    Versão
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

METHOD GetREPOM( cPath, cPathPar, cToken, cQueryPar, cVersion ) CLASS TMSBCARepomRelat

    Local cResult       := ""
    Local oClient       := NIL
    Local oJBody        := NIL
    Local aHeader       := {}

    Default cPath       := ""
    Default cPathPar    := ""
    Default cToken      := ""
    Default cQueryPar   := ""
    Default cVersion    := ""

    If !Empty(cPath) .AND. !Empty(cPathPar) .AND. !Empty(cToken) .AND. !Empty(cVersion)
        
        cQueryPar := EncodeUTF8( cQueryPar )
        oJBody  := JsonObject():New()

        // Definição do tipo de envio JSON ou URLEncode
        AAdd( aHeader, "Accept: application/json"               )
        AAdd( aHeader, "Authorization: " + "Bearer " + cToken   )
        AAdd( aHeader, "Content-Type: application/json"         )

        // Setting e Consumo da API
        oClient := FwRest():New( cPath )
        
        oClient:SetPath( cPathPar + cQueryPar + "?x-api-version=" + cVersion )

        If oClient:Get( aHeader, cQueryPar )
            cResult := oClient:GetResult()
        Else
            cResult := oClient:GetLastError()
        EndIf

        FreeObj(oJBody)
    EndIf

Return cResult

    
