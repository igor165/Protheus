#include 'totvs.ch' 
#include 'tmsac18.ch' 

/*/{Protheus.doc} TMSBCATPRNeolog
    Integraçã TPR Neolog
    @type  Class
    @author caio.y
    @since 17/08/2021
    @version 1.0
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
CLASS TMSBCATPRNeolog

    DATA url_token          As Character 
    DATA end_token          As Character
    DATA auth_google        As Character 
    DATA message_error      As Character 
    DATA show_error         As Logical
    DATA result_post        As Character
    DATA json_post          As Character
    DATA access_token       As Character
    DATA date_expiration    As Data
    DATA hour_expiration    As Character 
    DATA callback_url       As Character
    DATA callback_auth      As Character
    DATA callback_value     As Character
    DATA geo_url            As Character
    DATA geo_endpoint       As Character
    DATA geo_endpoAs        As Character 
    DATA rout_url           As Character
    DATA rout_endpoint      As Character
    
    //-- Routings
    DATA aOrders            As Array
    DATA aVehicles          As Array
    DATA aAddress           As Array 
    DATA oTPRAddress        As Object
    DATA oRoutingRestri     As Object
    DATA oRoutingOptions    As Object
    DATA routing_id         As Character
    
    DATA origem_Ident       As Character
    DATA origem_country     As Character
    DATA origem_latitude    As Numeric
    DATA origem_longitude   As Numeric
    DATA origem_operation   As Character
    DATA origem_name        As Character
	DATA origem_state       As Character
    DATA destino_Ident      As Character
    DATA destino_country    As Character
    DATA destino_latitude   As Numeric
    DATA destino_longitude  As Numeric
    DATA destino_operation  As Character
    DATA destino_name       As Character
	DATA destino_state      As Character

    DATA aGeoCode           As Array

    METHOD New()  //-- Constructor
    
    //-- Token 
    METHOD Auth() 
    METHOD GetAcessToken()
    METHOD GetDateToken()
    METHOD GetHourToken()
    METHOD VldToken()
    METHOD GrvToken()

    //-- Routing
     //-- Métodos para input de informações para a Roteirização
    METHOD AddOrders()
    METHOD AddVehicles()
    METHOD AddRestriction()
    METHOD AddOption()
    METHOD AddLocality()
    METHOD SetOrigem()
    METHOD SetDestino()
    METHOD PostRouting()
    METHOD SetRoutID()

    //-- Métodos para input de informações para a Geolocalização
    METHOD AddAddress()

	METHOD AddCustOp() //Adiciona a janela de entrega
	METHOD AddRestVeic() //Adiciona veiculos restritos ao cliente

    METHOD GetOrders()
    METHOD GetVehicles()
    METHOD GetRestriction()
    METHOD GetOption()
    METHOD PostGeoLoc()
    METHOD GetGeoLoc()
    
    //-- Grava DLU 
    METHOD InsertDLU() 
    METHOD UpdateDLU()
    METHOD RemoveDLU() 

    //-- CallBack
    METHOD SetCallBack()

    //-- Error
    METHOD GetError()
    METHOD ShowError() 
    METHOD GetResult()
    METHOD GetJsonEnv()
   
    METHOD Destroy()

END CLASS  

/*/{Protheus.doc} New
    New
    @type  Method
    @author caio.y
    @since 17/08/2021
    @version 1.0
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
METHOD New() CLASS TMSBCATPRNeolog
Local lRet      := .T. 
Local cUrlTk    := "" 
Local cEndTk    := "" 
Local cAuth     := "" 
Local cUrlCall  := "" 
Local cUrlGeo   := "" 
Local cEndGeo   := ""
Local cEndGeoAs := ""
Local cUrlRout  := ""
Local cEndRout  := "" 

DLV->(DBSetOrder(1))
If DLV->( MsSeek( xFilial("DLV") ))
	While DLV->(!Eof()) .And.DLV->DLV_FILIAL ==  xFilial("DLV")
		If DLV->DLV_MSBLQL == '2' .And. DLV->DLV_ROTERI == "2" 
            cAuth       := RTrim( DLV->DLV_AUTH )
            cUrlCall    := RTrim(  DLV->DLV_URLCAL ) 

            //-- URL e EndPoint
			cUrlTk      := SubStr( DLV->DLV_URLTK , 1, At("/" , DLV->DLV_URLTK , 10 )  )
            cEndTk      := SubStr( DLV->DLV_URLTK , At("/" , DLV->DLV_URLTK , 10 ) + 1 )            
            cUrlGeo     := SubStr( DLV->DLV_URLGEO , 1, At("/" , DLV->DLV_URLGEO , 10 )  )
            cEndGeo     := SubStr( DLV->DLV_URLGEO , At("/" , DLV->DLV_URLGEO , 10 ) + 1 )
            If DLV->(FieldPos("DLV_URLGAS")) > 0  
                cEndGeoAs   := SubStr( DLV->DLV_URLGAS , At("/" , DLV->DLV_URLGAS , 10 ) + 1 )
            EndIf 
            cUrlRout    := SubStr( DLV->DLV_URLROT , 1, At("/" , DLV->DLV_URLROT , 10 )  )
            cEndRout    := SubStr( DLV->DLV_URLROT , At("/" , DLV->DLV_URLROT , 10 ) + 1 )
		EndIf 
		DLV->( dbSkip() ) 
	EndDo
EndIF 

::auth_google       := cAuth
::message_error     := "" 
::show_error        := .T. 
::access_token      := "" 
::date_expiration   := CtoD("")
::hour_expiration   := ""

//-- URL Token
::url_token         := RTrim( Lower(cUrlTk))
::end_token         := RTrim( Lower(cEndTk ))

//-- Geolocation
::geo_url           := RTrim( Lower(cUrlGeo ))
::geo_endpoint      := RTrim(Lower(cEndGeo))
::geo_endpoAs       := Rtrim(Lower(cEndGeoAs))
//-- Routing
::rout_url          := RTrim( Lower(cUrlRout ))
::rout_endpoint     := RTrim( Lower(cEndRout))
::routing_id        := "" 
//-- CALLBACK
::callback_url      := RTrim(cUrlCall) 
::callback_auth     := "NONE"
::callback_value    := "" 

::aOrders           := {}
::aVehicles         := {}
::aAddress          := {}
::oTPRAddress       := Nil

::origem_Ident      := ""
::origem_country    := ""
::origem_latitude   := 0
::origem_longitude  := 0
::origem_operation  := ""
::origem_name       := ""
::origem_state      := ""
::destino_Ident     := ""
::destino_country   := ""
::destino_latitude  := 0
::destino_longitude := 0
::destino_operation := ""
::destino_name      := ""
::destino_state     := ""
::oRoutingRestri    := Nil
::oRoutingOptions   := Nil
::result_post       := "" 
::json_post         := "" 

Return lRet 

/*/{Protheus.doc} Auth
    Auth
    @type  Method
    @author caio.y
    @since 17/08/2021
    @version 1.0
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
METHOD Auth() CLASS TMSBCATPRNeolog
Local lRet      := .F. 
Local aHeader   := {} 
Local oRest     := FwRest():New( lower(::url_token) ) 
Local cResult   := ""
Local oObj      := Nil 
Local cParams   := ""
Local oBody     := JsonObject():New()
Local aSM0      := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt )
Local cCgc      := ""
Local nPos      := 0 
Local cQualif   := "" 
Local cName     := ""
Local cEmail    := RTrim( UsrRetMail( RetCodUsr() ) )
Local aMessages := {} 
Local nCount    := 0 
Local oQualif   := JsonObject():New()
Local cEndPoint := ::end_token
Local aData     := {} 

lRet    := ::VldToken()

If !lRet
    //-- Obtém dados da filial
    If Len(aSM0) > 0 
        nPos    := ASCAN(aSM0,{|X|X[1]=="M0_CGC"})
        If nPos > 0 
            cCGC    := aSM0[nPos,2]
        EndIf 

        nPos    := ASCAN(aSM0,{|X|X[1]=="M0_NOMECOM"})
        If nPos > 0 
            cName    := RTrim( aSM0[nPos,2] )
        EndIf 

    EndIf 

    //-- Qualifiers
    oQualif["usuario"]  := RTrim(PswChave(RetCodUsr()))
    cQualif := oQualif:ToJson()

    //-- Monta header
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Content-Type: application/json" )
    Aadd(aHeader, "Authorization: Bearer " + ::auth_google  )

    //-- Body message
    oBody["dateCall"]       := FwTimeStamp(3,dDataBase, Time() ) //"2021-08-16T17:44:35.558+00:00"
    oBody["system"]         := cModulo
    oBody["version"]        := GetBuild()
    oBody["identifierType"] := "CNPJ"
    oBody["identifier"]     := cCGC
    oBody["qualifiers"]     := cQualif
    oBody["name"]           := cName
    oBody["shortName"]      := cName
    oBody["email"]          := cEmail

    cParams := oBody:ToJson()

    oRest:SetPath( cEndPoint ) 
    oRest:SetPostParams( EncodeUTF8(cParams) )

    //-- Post TPR - Neolog
    FwMsgRun( , { || lRet := oRest:Post( aHeader ) }  ,STR0001 , STR0003  ) //Integração de Roteirização. Aguardando retorno da TPR

    //-- Tratamento retorno
    If lRet
        cResult     := oRest:GetResult()        
        If FWJsonDeserialize(cResult,@oObj)
            If oObj:success
                ::access_token      := oObj:key
                aData               := FwDateTimeToLocal( oObj:dateExpiration )
                If Len(aData) > 0 
                    ::date_expiration   := aData[1]
                    ::hour_expiration   := aData[2]
                EndIf 
                
                //-- Grava Token
                ::GrvToken()
            Else 
                lRet    := .F. 
                aMessages   := oObj:messages 
                For nCount := 1 To Len(aMessages)
                    ::message_error += Decodeutf8( AllTrim( aMessages[nCount]:messageCode + " " + aMessages[nCount]:message ) ) + chr(10) + chr(13)
                Next 
            EndIf 
        EndIf

    Else
        ::message_error   := Decodeutf8( AllTrim( oRest:GetLastError()  ) + CHR(13) + AllTrim(  oRest:GetResult()  ) )
    EndIf    
EndIf 

FwFreeArray( aSM0 )
FwFreeArray( aMessages )
FwFreeArray( aHeader )
FwFreeArray( aData )
FwFreeObj(oRest)
FwFreeObj(oBody)
FwFreeObj(oQualif)

Return lRet 

/*/{Protheus.doc} ShowError
    ShowError
    @type  Method
    @author caio.y
    @since 17/08/2021
    @version 1.0
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
METHOD ShowError() CLASS TMSBCATPRNeolog

    If !Empty(::message_error)
        MsgAlert( ::message_error )
    EndIf 

Return ::message_error

/*/{Protheus.doc} GetError
    GetError
    @type  Method
    @author caio.y
    @since 17/08/2021
    @version 1.0
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
METHOD GetError() CLASS TMSBCATPRNeolog  

Return ::message_error

/*/{Protheus.doc} GetAcessToken
    GetAcessToken
    @type  Method
    @author caio.y
    @since 17/08/2021
    @version 1.0
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
METHOD GetAcessToken() CLASS TMSBCATPRNeolog
Return ::access_token 

/*/{Protheus.doc} GetDateToken
    GetDateToken
    @type  Method
    @author caio.y
    @since 17/08/2021
    @version 1.0
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
METHOD GetDateToken() CLASS TMSBCATPRNeolog
Return ::date_expiration 

/*/{Protheus.doc} GetHourToken
    GetHourToken
    @type  Method
    @author caio.y
    @since 17/08/2021
    @version 1.0
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
METHOD GetHourToken() CLASS TMSBCATPRNeolog
Return ::hour_expiration 

/*/{Protheus.doc} VldToken
    GetHourToken
    @type  Method
    @author caio.y
    @since 20/08/2021
    @version 1.0
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
METHOD VldToken() CLASS TMSBCATPRNeolog
Local lRet    := .F.

DLV->(DBSetOrder(1))
If DLV->( MsSeek( xFilial("DLV") ))
	While DLV->(!Eof()) .And.DLV->DLV_FILIAL ==  xFilial("DLV")
		If DLV->DLV_MSBLQL == '2' .And. DLV->DLV_ROTERI == "2" .And. !Empty(DLV->DLV_TOKEN)
			::access_token      := RTrim( DLV->DLV_TOKEN )
            ::date_expiration   := DLV->DLV_DTTOKE
            ::hour_expiration   := DLV->DLV_HRTOKE
            lRet    := .T. 
		EndIf 
		DLV->( dbSkip() ) 
	EndDo
EndIF 

Return lRet

/*/{Protheus.doc} GrvToken
    GrvToken
    @type  Method
    @author caio.y
    @since 20/08/2021
    @version 1.0
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
METHOD GrvToken() CLASS TMSBCATPRNeolog

DLV->(DBSetOrder(1))
If DLV->( MsSeek( xFilial("DLV") ))
	While DLV->(!Eof()) .And.DLV->DLV_FILIAL ==  xFilial("DLV")
		If DLV->DLV_MSBLQL == '2' .And. DLV->DLV_ROTERI == "2" 
            RecLock("DLV",.F.)
            DLV->DLV_TOKEN	:= ::GetAcessToken()
            DLV->DLV_DTTOKE	:= ::GetDateToken()
            DLV->DLV_HRTOKE	:= ::GetHourToken()
            MsUnlock() 
		EndIf 
		DLV->( dbSkip() ) 
	EndDo
EndIF 

Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} AddVehicles()
Adiciona os Veiculos
@author Katia
@since 18/08/2021
@version 12.1.37
/*/
//--------------------------------------------------------------------
METHOD AddVehicles( cIdent, nWeigth, nVolume, nSpeed, nQuantity, nTollAxes, nTollRetAx ) CLASS TMSBCATPRNeolog

Local oVehicles	 := Nil

Default cIdent   := ""
Default nWeigth  := 0
Default nVolume  := 0
Default nSpeed   := 0
Default nQuantity:= 0

oVehicles    := JsonObject():New()
    
oVehicles["identifier"]      := cIdent
oVehicles["weightCapacity"]  := nWeigth
oVehicles["volumeCapacity"]  := nVolume
oVehicles["speed"]           := Iif(nSpeed>0,nSpeed,Nil)
oVehicles["quantity"]        := nQuantity

oVehicles["tollAxes"]        := nTollAxes
oVehicles["tollReturnAxes"]  := nTollRetAx

Aadd( ::aVehicles , oVehicles )

FreeObj(oVehicles)    
oVehicles    := Nil 

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} AddOrders()
Adiciona os Documentos para Roteirização (TPRRoutingOrders)
@author Katia
@since 18/08/2021
@version 12.1.37
/*/
//--------------------------------------------------------------------
METHOD AddOrders( cIdent, nWeigth, nVolume, dIniCar, dFimCar, dIniEnt, dFimEnt, nTmpCar, nTmpDesCar, aJanelas, aVeiculos ) CLASS TMSBCATPRNeolog

Local oOrders  := Nil

Default cIdent    := ""
Default nWeigth   := 0
Default nVolume   := 0
Default dIniCar   := Nil
Default dFimCar   := Nil
Default dIniEnt   := Nil
Default dFimEnt   := Nil
Default nTmpCar   := Nil
Default nTmpDesCar:= Nil

oOrders	 := JsonObject():New()    

oOrders["identifier"]              := cIdent
oOrders["weight"]                  := nWeigth
oOrders["volume"]                  := nVolume
oOrders["pickupTimeWindowStart"]   := dIniCar
oOrders["pickupTimeWindowEnd"]     := dFimCar
oOrders["deliveryTimeWindowStart"] := dIniEnt
oOrders["deliveryTimeWindowEnd"]   := dFimEnt
oOrders["serviceLoadDuration"]     := nTmpCar
oOrders["serviceUnloadDuration"]   := nTmpDesCar
oOrders["origin"]                  :=  ::AddLocality(::origem_Ident, ::origem_country, ::origem_latitude, ::origem_longitude, ::origem_operation, ::origem_name, ::origem_state) 
oOrders["destination"]             :=  ::AddLocality(::destino_Ident, ::destino_country, ::destino_latitude, ::destino_longitude, ::destino_operation, ::destino_name, ::destino_state, aJanelas, aVeiculos) 

Aadd( ::aOrders , oOrders )

FreeObj(oOrders)    
oOrders    := Nil 

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} AaddLocality()
Adiciona o Local de Origem (TPRRoutingLocality)
@author Katia
@since 18/08/2021
@version 12.1.37
/*/
//--------------------------------------------------------------------
METHOD AddLocality( cIdent, cPais, nLatitu, nLongit, cOperation, cName, cState, aJanelas, aVeiculos ) CLASS TMSBCATPRNeolog

Local oLocality:= Nil

Default cIdent    := ""
Default cPais     := ""
Default nLatitu   := 0
Default nLongit   := 0
Default cOperation:= "UNRESTRICTED"
Default cName     := ""

oLocality:= JsonObject():New()

oLocality["identifier"]:= cIdent
oLocality["country"]   := cPais
oLocality["state"]   := cState
oLocality["latitude"]  := nLatitu
oLocality["longitude"] := nLongit
oLocality["operation"] := cOperation
oLocality["name"]      := cName
If !Empty(aJanelas)
	oLocality["customizedOperations"] := ::AddCustOp(aJanelas)
EndIf
If !Empty(aVeiculos)
	oLocality["restrictedVehicles"] := ::AddRestVeic(aVeiculos)
EndIf
Return oLocality


//-----------------------------------------------------------------
/*/{Protheus.doc} AddRestriction()
Adiciona o Local de Origem (TPRRoutingLocality)
@author Katia_
@since 18/08/2021
@version 12.1.37
/*/
//--------------------------------------------------------------------
METHOD AddRestriction( nMaxLoad, nMaxUnload, lInter, nMaxDistLoad, nMaxDistUnload, lMVOrdUF) CLASS TMSBCATPRNeolog

Local oRestriction:= Nil

Default nMaxLoad      := Nil
Default nMaxUnload    := Nil
Default lInter        := .F.
Default nMaxDistLoad  := Nil
Default nMaxDistUnload:= Nil
Default lMVOrdUF      := .F.

oRestriction:= JsonObject():New()

oRestriction["maxLoadingStops"]              := nMaxLoad
oRestriction["maxUnloadingStops"]            := nMaxUnload
oRestriction["allowInterleaving"]            := Iif(lInter,'True','False')
oRestriction["maxDistanceBetweenLoadStops"]  := nMaxDistLoad
oRestriction["maxDistanceBetweenUnloadStops"]:= nMaxDistUnload
oRestriction["stateReturnForbidden"]         := Iif(lMVOrdUF,'True','False')

::oRoutingRestri:= oRestriction

FreeObj(oRestriction)    
oRestriction := Nil 

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} AddOption()
Adiciona as Opções para Roteirização (TPRRoutingOptions)
@author Katia
@since 18/08/2021
@version 12.1.37
/*/
//--------------------------------------------------------------------
METHOD AddOption(cCapCriteria, cRoutInstant, lReturnDist, nMinServDur, nMaxServDur, cDriverRest, lTollCalc, routingType) CLASS TMSBCATPRNeolog
Local oOption         := Nil

Default cCapCriteria  := "WEIGHT"  //WEIGHT, VOLUME OU BOTH
Default cRoutInstant  := "NOW"     //D+1 , NOW
Default lReturnDist   := .F.
Default nMinServDur   := 0
Default nMaxServDur   := 0
Default cDriverRest   := "Default"
Default lTollCalc     := .F.
Default routingType   := "ROUTING"

oOption:= JsonObject():New()

oOption["capacityCriteria"]       := cCapCriteria
oOption["routingInstantType"]     := cRoutInstant
oOption["considerReturnDistance"] := Iif(lReturnDist,'True','False')
oOption["minServiceDuration"]     := nMinServDur
oOption["maxServiceDuration"]     := nMaxServDur
oOption["driverRestTimes"]        := cDriverRest
oOption["tollCalculation"]        := Iif(lTollCalc,'True','False')
oOption["routingType"]        	  := routingType

::oRoutingOptions:= oOption

FreeObj(oOption)    
oOption := Nil 

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} AddAddress()
Adiciona dados do endereço para Geolocalização - TPRAddress
@author Katia
@since 18/08/2021
@version 12.1.37
/*/
//--------------------------------------------------------------------
METHOD AddAddress( cIdent, cCountry, cState, cCity, cZipCode, cAddress ) CLASS TMSBCATPRNeolog

Local oAddress	 := Nil

Default cIdent   := ""
Default cCountry := ""
Default cState   := ""
Default cCity    := ""
Default cZipCode := ""
Default cAddress := ""

oAddress    := JsonObject():New()

oAddress["identifier"]:= cIdent
oAddress["country"]	  := cCountry
oAddress["state"]     := cState
oAddress["city"]      := cCity
oAddress["zipCode"]   := cZipCode
oAddress["address"]   := cAddress

If IsInCallStack("GerDARProc")
    Aadd( ::aAddress , oAddress )
Else 
    ::oTPRAddress:=  oAddress 
EndIf 

FreeObj(oAddress)    
oAddress    := Nil 

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} GetVehicles()
Retorna os veículos 
@author Katia
@since 18/08/2021
@version 12.1.37
/*/
//--------------------------------------------------------------------
METHOD GetVehicles() CLASS TMSBCATPRNeolog
Local aRet      := {} 

aRet    := aClone(Self:aVehicles)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetOrders()
Retorna a lista dos Documentos
@author Katia
@since 18/08/2021
@version 12.1.37
/*/
//--------------------------------------------------------------------
METHOD GetOrders() CLASS TMSBCATPRNeolog
Local aRet      := {} 

aRet    := aClone(Self:aOrders)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} Destroy()
Destroi o objeto
@author Katia
@since 18/08/2021
@version 12.1.37
/*/
//--------------------------------------------------------------------
METHOD Destroy() CLASS TMSBCATPRNeolog

FwFreeObj(::aOrders)
FwFreeObj(::aVehicles)
FwFreeObj(::aAddress)

::aOrders       := {}
::aVehicles     := {}
::aAddress      := {}
::oTPRAddress   := Nil

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} SetOrigem()
Seta a Localidade de Origem (TPRRoutingLocality) 
para adicionar no método AaddLocality()
Adiciona o Local de Origem
@author Katia
@since 18/08/2021
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD SetOrigem( cIdentOri, cPaisOri, nLatiOri, nLongOri, cOperOri, cName, cState) CLASS TMSBCATPRNeolog

Default cIdentOri := ""
Default cPaisOri  := ""
Default nLatiOri  := ""
Default nLongOri  := ""
Default cOperOri  := "UNRESTRICTED"
Default cName     := ""

::origem_Ident     := cIdentOri
::origem_country   := cPaisOri
::origem_latitude  := nLatiOri
::origem_longitude := nLongOri
::origem_operation := cOperOri
::origem_name      := cName
::origem_state     := cState

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} SetDestino()
Seta a Localidade de Destino (TPRRoutingLocality) 
para adicionar no método AaddLocality()
@author Katia
@since 18/08/2021
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD SetDestino( cIdentDes, cPaisDes, nLatiDes, nLongDes, cOperDes, cName, cState ) CLASS TMSBCATPRNeolog

Default cIdentDes := ""
Default cPaisDes  := ""
Default nLatiDes  := ""
Default nLongDes  := ""
Default cOperDes  := "UNRESTRICTED"
Default cName     := ""

::destino_Ident     := cIdentDes
::destino_country   := cPaisDes
::destino_latitude  := nLatiDes
::destino_longitude := nLongDes
::destino_operation := cOperDes
::destino_name      := cName
::destino_state     := cState

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} PostRouting()
Envia os dados para Roteirização - TPRRoutingOrders 
@author Katia
@since 18/08/2021
@version 12.1.37
/*/
//--------------------------------------------------------------------
METHOD PostRouting() CLASS TMSBCATPRNeolog
Local aHeader       := {} 
Local oJson         := JsonObject():New() 
Local oQualif       := JsonObject():New()
Local cQualif       := ""
Local cResult       := "" 
Local cParams       := ""
Local cEndPoint     := ::rout_endpoint
Local oRest         := FwRest():New( lower( ::rout_url ))
Local nCount        := 1 
Local oObj          := Nil 
Local lRet          := .F.
Local aRetPE        := {}

//-- Qualifiers
oQualif["usuario"]  := RTrim(PswChave(RetCodUsr()))
oQualif["sistema"]  := "PROTHEUS"
oQualif["modulo"]   := cModulo
oQualif["empresa"]  := cEmpAnt
oQualif["filial"]   := cFilAnt  
oQualif["identifier"]   := ::routing_id
oQualif["routingType"]   := ::oRoutingOptions["routingType"]
cQualif := oQualif:ToJson()

//-- Monta header
Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Content-Type: application/json" )
Aadd(aHeader, "Authorization: Bearer " + ::auth_google  )
Aadd(aHeader, "TPR_AUTHORIZATION: " + ::access_token )

oJson["dateCall"]                   := FwTimeStamp(3,dDataBase, Time() ) 
//oJson["system"]                     := cModulo
//oJson["version"]                    := GetBuild()
oJson["qualifiers"]                 := cQualif
oJson["callbackURL"]                := ::callback_url
oJson["callbackAuthenticationType"] := ::callback_auth
//oJson["callbackAuthenticationValue"]:= ::callback_value
oJson["orders"]                     := ::aOrders
oJson["vehicles"]                   := ::aVehicles
oJson["restrictions"]               := ::oRoutingRestri
oJson["routingOptions"]             := ::oRoutingOptions

cParams := oJson:ToJson()

/* Ponto de entrada para alteração do json */
If ExistBlock("TMS18RPE")
	aRetPE := ExecBlock("TMS18RPE",.F.,.F.,{cParams,aHeader,cEndPoint})
	If ValType(aRetPE) == "A" .And. Len(aRetPE) == 3
		cParams   := aRetPE[1]
		aHeader   := aRetPE[2]
		cEndPoint := aRetPE[3]
	EndIf
EndIf

oRest:SetPath( cEndPoint ) 
oRest:SetPostParams( EncodeUTF8(cParams) )

::json_post         := cParams

If nModulo = 39
	OMSTPRCLOG(Nil, "TMSAC18", STR0001 + cParams)
EndIf

//-- Post Routing
FwMsgRun( , { || lRet := oRest:Post( aHeader ) }  ,STR0001 , STR0003  ) //Integração de Roteirização. Aguardando retorno da TPR

If nModulo = 39
	OMSTPRCLOG(Nil, "TMSAC18", STR0001 + "||" +  cValToChar(lRet) + "||" + cValToChar(oRest:GetLastError()) + "||" +  cValToChar(oRest:GetResult()))
EndIf

//-- Tratamento retorno
If lRet
 
    cResult     := oRest:GetResult()      

    ::result_post   := cResult  
    
    If FWJsonDeserialize(cResult,@oObj)
        If oObj:success

        Else 
            lRet    := .F. 
            aMessages   := oObj:messages 
            For nCount := 1 To Len(aMessages)
                ::message_error += Decodeutf8( AllTrim( aMessages[nCount]:messageCode + " " + aMessages[nCount]:message ) ) + chr(10) + chr(13)
            Next 
        EndIf 
    EndIf

Else
	::message_error := ""
	IIf(!Empty(oRest:GetLastError()),::message_error += Decodeutf8(  AllTrim( cValToChar( oRest:GetLastError()))),)
	IIf(!Empty(oRest:GetResult()),::message_error += Decodeutf8(  AllTrim( cValToChar( oRest:GetResult()))),)
EndIf


Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PostGeoLoc()
Envia os dados para Geolocalização - TPRGeolocation
@author Katia
@since 18/08/2021
@version 12.1.37
/*/
//--------------------------------------------------------------------
METHOD PostGeoLoc() CLASS TMSBCATPRNeolog
Local aHeader       := {} 
Local oJson         := JsonObject():New() 
Local oQualif       := JsonObject():New()
Local cQualif       := ""
Local cResult       := "" 
Local cParams       := ""
Local cEndPoint     := Iif(IsInCallStack("GerDARProc"),::geo_endpoAs,::geo_endpoint) 
Local oRest         := FwRest():New( lower( ::geo_url ))
Local nCount        := 1 
Local oObj          := Nil 
Local lRet          := .F.
Local aRet          := {}

//-- Qualifiers
oQualif["usuario"]  := RTrim(PswChave(RetCodUsr()))

If IsInCallStack("GerDARProc")
    oQualif["sistema"]  := "PROTHEUS"
    oQualif["modulo"]   := cModulo
    oQualif["empresa"]  := cEmpAnt
    oQualif["filial"]   := cFilAnt  
    oQualif["identifier"]   := ::routing_id
EndIf 
cQualif := oQualif:ToJson()

//-- Monta header
Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Content-Type: application/json" )
Aadd(aHeader, "Authorization: Bearer " + ::auth_google  )
Aadd(aHeader, "TPR_AUTHORIZATION: " + ::access_token )

oJson["dateCall"]                   := FwTimeStamp(3,dDataBase, Time() ) 
oJson["system"]                     := cModulo
oJson["version"]                    := GetBuild()
oJson["qualifiers"]                 := cQualif
oJson["callbackURL"]                := ::callback_url
oJson["callbackAuthenticationType"] := ::callback_auth
oJson["callbackAuthenticationValue"]:= ::callback_value
If IsInCallStack("GerDARProc")
    oJson["addresses"]              := ::aAddress
Else 
    oJson["address"]                := ::oTPRAddress 
EndIf 

cParams := oJson:ToJson()

::json_post := cParams

oRest:SetPath( cEndPoint ) 
oRest:SetPostParams( EncodeUTF8(cParams) )

If nModulo = 39
	OMSTPRCLOG(Nil, "TMSAC18", STR0002 + cParams)
EndIf

//-- Post GeoLocation
FwMsgRun( , { || lRet := oRest:Post( aHeader ) }  , STR0002 , STR0003 ) //Integração de Geolocalização. Aguardando retorno da TPR.

If nModulo = 39
	OMSTPRCLOG(Nil, "TMSAC18", STR0002 + "||" +  cValToChar(lRet) + "||" + cValToChar(oRest:GetLastError()) + "||" +  cValToChar(oRest:GetResult()))
EndIf

//-- Tratamento retorno
If lRet
    cResult         := oRest:GetResult()       
    ::result_post   := cResult 

    If FWJsonDeserialize(cResult,@oObj)
        If IsInCallStack("GerDARProc")
            oObj:success 
        ElseIf !IsInCallStack("GerDARProc")
            oObj:geolocationresult:success
            If AttIsMemberOf(oObj:geolocationresult,"latitude") 
                Aadd(aRet, oObj:geolocationresult:latitude)
                Aadd(aRet, oObj:geolocationresult:longitude)

                ::aGeoCode:= aClone(aRet)
            EndIf 
        Else 
           lRet    := .F. 
            aMessages   := oObj:messages 
            For nCount := 1 To Len(aMessages)
                ::message_error += Decodeutf8( AllTrim( aMessages[nCount]:messageCode + " " + aMessages[nCount]:message ) ) + chr(10) + chr(13)
            Next 
        EndIf 
    EndIf

Else
	::message_error   := ""
	IIf(!Empty(oRest:GetLastError()),::message_error += AllTrim( cValToChar(oRest:GetLastError())),) //Nao vem como UTF8
	IIf(!Empty(oRest:GetResult()),   ::message_error += AllTrim( cValToChar(oRest:GetResult())),)    //Nao vem como UTF8
EndIf


Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} SetCallBack()
SetCallBack - Set informações de autenticação do callback
@author Caio
@since 20/08/2021
@version 12.1.37
/*/
//--------------------------------------------------------------------
METHOD SetCallBack( cUrlCal , cAuthType , cValue ) CLASS TMSBCATPRNeolog

Default cUrlCal     := ""
Default cAuthType   := "NONE"
Default cValue      := ""  

::callback_url      := cUrlCal
::callback_auth     := cAuthType
::callback_value    := cValue

Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} InsertDLU()
Insere DLU 
@author Caio
@since 20/08/2021
@version 12.1.37
/*/
//--------------------------------------------------------------------
METHOD InsertDLU( cFilEnt, cEntidade , cChaveEnt , cApi, cIDRequis, cRotina, cRet, cEnvio , cStatus ) CLASS TMSBCATPRNeolog

Local aArea         := GetArea()
Local aAreaDLU      := DLU->(GetArea()) 
Local aCab          := {} 

Default cFilEnt     := ""
Default cEntidade   := ""
Default cChaveEnt   := ""
Default cApi        := ""
Default cIDRequis   := ""
Default cRotina     := ""
Default cRet        := ""
Default cEnvio      := ""
Default cStatus     := ""


Aadd( aCab  , {"DLU_FILIAL" , xFilial("DLU")	  , Nil } )
Aadd( aCab  , {"DLU_FILENT" , cFilEnt        , Nil } )
Aadd( aCab  , {"DLU_ENTIDA" , cEntidade      , Nil } )
Aadd( aCab  , {"DLU_CHVENT" , cChaveEnt      , Nil } )
Aadd( aCab  , {"DLU_MODULO" , cModulo           , Nil } )
Aadd( aCab  , {"DLU_ROTINA" , cRotina         , Nil } )
Aadd( aCab  , {"DLU_API"    , cApi          , Nil } )
Aadd( aCab  , {"DLU_DATENV" , dDataBase         , Nil } )
Aadd( aCab  , {"DLU_HORENV" , StrTran(Left(Time(),5),':','')        , Nil } )
Aadd( aCab  , {"DLU_IDREQ"  , cIDRequis      , Nil } )
Aadd( aCab  , {"DLU_RETENV" , cRet           , Nil } )
Aadd( aCab  , {"DLU_USER"   , __cUserID        , Nil } )
Aadd( aCab  , {"DLU_ENVIO"  , cEnvio          , Nil } )
Aadd( aCab  , {"DLU_STATUS" , cStatus         , Nil } )

If Len(aCab) > 0 
    TMSMdlAuto( aCab ,,3, "TMSAO50" , "MdFieldDLU" ,, "DLU",)
EndIf 

RestArea( aAreaDLU )
RestArea( aArea )

Return 


//-----------------------------------------------------------------
/*/{Protheus.doc} UpdateDLU()
Método responsável pela alteração da tabela DLU

@author Katia Tiemi
@since 12/06/2019
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD UpdateDLU( cFilEnt, cEntidade , cChaveEnt , cApi, cIDRequis, cRotina, cRet ) CLASS TMSBCATPRNeolog

Local aArea         := GetArea()
Local aAreaDLU      := DLU->(GetArea()) 
Local aCab          := {} 

Default cFilEnt     := ""
Default cEntidade   := ""
Default cChaveEnt   := ""
Default cApi        := ""
Default cIDRequis   := ""
Default cRotina     := ""
Default cRet        := ""

cFilEnt       := Padr((cFilEnt),Len(DLU->DLU_FILENT))
cEntidade     := Padr((cEntidade),Len(DLU->DLU_ENTIDA))
cChaveEnt     := Padr((cChaveEnt),Len(DLU->DLU_CHVENT))
cApi          := cApi 
cIDRequis     := cIDRequis

DLU->(dbSetOrder(2))
If DLU->( MsSeek( xFilial("DLU") + cFilEnt + cEntidade + cChaveEnt ) )
    Aadd( aCab  , {"DLU_DATRET" , dDataBase                             , Nil } )
    Aadd( aCab  , {"DLU_HORRET" , StrTran(Left(Time(),5),':','')        , Nil } )
    Aadd( aCab  , {"DLU_RETORN" , cRet                                  , Nil } )  
	Aadd( aCab  , {"DLU_QTDTEN" , DLU->DLU_QTDTEN + 1                   , Nil } )  

    If Len(aCab) > 0 
        TMSMdlAuto( aCab ,,4, "TMSAO50" , "MdFieldDLU" ,, "DLU",)
    EndIf 

EndIf 

RestArea( aAreaDLU )
RestArea( aArea )

Return 


//-----------------------------------------------------------------
/*/{Protheus.doc} RemoveDLU()
Método responsável pela exclusão da tabela DLU

@author Katia Tiemi
@since 12/06/2019
@version 1.0
@type function
/*/
//--------------------------------------------------------------------

METHOD RemoveDLU( cFilEnt, cEntidade , cChaveEnt , cApi, cIDRequis, cRotina ) CLASS TMSBCATPRNeolog

Local aArea         := GetArea()
Local oMdlDLU       := Nil
Local lRet          := .F.

Default cFilEnt     := ""
Default cEntidade   := ""
Default cChaveEnt   := ""
Default cApi        := ""
Default cIDRequis   := ""
Default cRotina     := ""

DLU->(dbSetOrder(2))
If DLU->( MsSeek( xFilial("DLU") + cFilEnt + cEntidade + cChaveEnt + DLU->DLU_CODIGO ) )
    oMdlDLU := FWLoadModel( 'TMSAO50' )
	oMdlDLU :SetOperation( MODEL_OPERATION_DELETE )
	oMdlDLU :Activate()
	lRet := oMdlDLU:VldData()
			
	If lRet
		lRet := oMdlDLU:CommitData()
	EndIf
		
	oMdlDLU:DeActivate()
EndIf 

RestArea( aArea )

Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} GetResult()
Get Resultados

@author Caio Murakami
@since 31/08/2021
@version 1.0
@type function
/*/
//--------------------------------------------------------------------
METHOD GetResult() CLASS TMSBCATPRNeolog
Return ::result_post

//-----------------------------------------------------------------
/*/{Protheus.doc} GetJsonEnv()
Get Resultados

@author Caio Murakami
@since 31/08/2021
@version 1.0
@type function
/*/
//--------------------------------------------------------------------
METHOD GetJsonEnv() CLASS TMSBCATPRNeolog
Return ::json_post

//-----------------------------------------------------------------
/*/{Protheus.doc} SetRoutID()
Set ::routing_id para ser utilizado no qualifiers

@author Caio Murakami
@since 31/08/2021
@version 1.0
@type function
/*/
//--------------------------------------------------------------------
METHOD SetRoutID(cId) CLASS TMSBCATPRNeolog

Default cId     := "" 

::routing_id    := cId 

Return ::routing_id



//-----------------------------------------------------------------
/*/{Protheus.doc} GetGeoLoc()
Get GeoLocation

@author Katia
@since 14/09/2021
@version 1.0
@type function
/*/
//--------------------------------------------------------------------
METHOD GetGeoLoc() CLASS TMSBCATPRNeolog
Return ::aGeoCode


//-----------------------------------------------------------------
/*/{Protheus.doc} AddCustOp()
Adiciona operacao customizada do cliente
@author Equipe OMS
@since 27/06/2022
@version 12.1.2210
/*/
//--------------------------------------------------------------------
METHOD AddCustOp( aCustOp ) CLASS TMSBCATPRNeolog

	Local oCustOper := Nil
	Local aListCust := {}
	Local nX 		:= 1

	For nX := 1 To Len(aCustOp)
		oCustOper:= JsonObject():New()
		oCustOper["weekDay"]	:= aCustOp[nX][1]
		oCustOper["startTime"] 	:= aCustOp[nX][2]
		oCustOper["endTime"] 	:= aCustOp[nX][3]
		Aadd(aListCust, oCustOper)
	Next nX

Return aListCust


//-----------------------------------------------------------------
/*/{Protheus.doc} AddRestVeic()
Adiciona restricao de veiculos ao cliente
@author Equipe OMS
@since 27/06/2022
@version 12.1.2210
/*/
//--------------------------------------------------------------------
METHOD AddRestVeic(aVeiculos) CLASS TMSBCATPRNeolog

	Local oRestVehic := Nil
	Local aListVeic := {}
	Local nX 		:= 1

	For nX := 1 To Len(aVeiculos)
		oRestVehic:= JsonObject():New()
		oRestVehic["identifier"] := aVeiculos[nX]
		Aadd(aListVeic, oRestVehic)
	Next nX

Return aListVeic

