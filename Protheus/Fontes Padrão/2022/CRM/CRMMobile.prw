#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "CRMMOBILE.CH"
WSRESTFUL CRMMobile DESCRIPTION STR0001 //"Informação da API para o grupo de recursos: CRM Mobile "
    WSMETHOD GET DESCRIPTION STR0002 WSSYNTAX "/CRMMobile/api" PRODUCES APPLICATION_JSON //"Retorna o nível de API suportado por esta instância do Protheus"
END WSRESTFUL

WSMETHOD GET WSSERVICE CRMMobile
 
    Local apiLevel := 5 
    Local aSourcesNames := {}
    Local i := 1
    Local oResponse     := JsonObject():New()
    Local oFrameInfo    := JsonObject():New()
    Local aSources      := {}
    Local sourceData    := {}
    Local tmpObj
    
    aSourcesNames := { "CRMM010.prw", "CRMM020.prw","CRMM030.prw",;
    "CRMM040.prw","CRMM050.prw","CRMM060.prw","CRMM070.prw",;
    "CRMM080.prw", "CRMXFUNGEN.prw", "TMKA070.PRX",;
    "CRMM090.prw","CRMM100.prw","CRMM110.prw","CRMM120.prw" }

    ::SetContentType("application/json")
    
    If FindFunction( 'GetApoInfo' )
        FOR i := 1 TO LEN(aSourcesNames)
            sourceData := GetApoInfo( aSourcesNames[i] )
            tmpObj := JsonObject():New()
 
            if LEN(sourceData) >= 5 
                tmpObj['name'] := sourceData[1]
                tmpObj['date'] := DtoC(sourceData[4])
                tmpObj['hour'] := sourceData[5] 
            Else 
                tmpObj['name'] := aSourcesNames[i]
                tmpObj['message'] := 'Source not found'
            EndIf

            AAdd( aSources, tmpObj )
            FreeObj(tmpObj)
        NEXT
    EndIf
        
    If FindFunction( '__FWLibVersion' )
        oFrameInfo['lib_version'] := __FWLibVersion()
    EndIf

    If FindFunction( '__FWLibDate' )
        oFrameInfo['lib_date'] := __FWLibDate()
    EndIf

    If FindFunction( '__FWCommitID' )
        oFrameInfo['lib_commit_id'] := __FWCommitID()
    EndIf

    If FindFunction( 'GetRPORelease' )
        oFrameInfo['rpo_release'] := GetRPORelease()
    EndIf

    oResponse['api_level'] := apiLevel
    oResponse['sources'] := aSources
    oResponse['framework'] := oFrameInfo

    cResponse := FWJsonSerialize(oResponse, .F., .F., .T.)
    ::SetResponse(cResponse)

    FreeObj(oFrameInfo)
    FreeObj(oResponse)
    ASize(aSourcesNames, 0)
    ASize(aSources, 0)
    ASize(sourceData, 0)
Return .T.
