#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

WSRESTFUL UBAW04 DESCRIPTION "Cadastro de Filiais - SM0"

WSDATA dateDiff AS STRING OPTIONAL
WSDATA page     AS INTEGER OPTIONAL
WSDATA pageSize AS INTEGER OPTIONAL

WSMETHOD GET 		 DESCRIPTION "Retorna uma lista de filiais" 	   PATH "/v1/branchs" 				  PRODUCES APPLICATION_JSON
WSMETHOD GET GetDiff DESCRIPTION "Retorna uma lista de filiais - Diff" PATH "/v1/branchs/diff/{dateDiff}" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET QUERYPARAM page, pageSize WSSERVICE UBAW04
	Local lPost     := .T.
	Local oBranch   := JsonObject():New()
	Local cEmpCor   := FWArrFilAtu()[1]
	Local aFiliais  := {}
	Local nIt	    := 0
	Local cDateTime	:= ""
	Local oPage     := {}
	Local nPage 	:= IIf(!Empty(::page),::page,1)
	Local nPageSize := IIf(!Empty(::pageSize),::pageSize,30)
	Local nCount	:= 0
	Local lHasNext	:= .F.
	
	oPage := FwPageCtrl():New(nPageSize,nPage)
	
	// Coloca a data e hora atual
	// Formato UTC aaaa-mm-ddThh:mm:ss-+Time Zone (coloca a hora local + o timezone (ISO 8601))
	cDateTime := FWTimeStamp(5)
    
    ::SetContentType("application/json")
    
    oBranch["hasNext"] := .F.
    oBranch["items"]   := Array(0)
    oBranch["totvs_sync_date"] := cDateTime
    
    aFiliais := FWLoadSM0()
        
    For nIt := 1 to Len(aFiliais)
       If Alltrim(aFiliais[nIt][1]) == Alltrim(cEmpCor)
       		
       		nCount++
			If !oPage:CanAddLine()							
				If nCount <= (nPageSize * nPage)					
					LOOP					
				Else
					EXIT
				EndIf
			EndIf       
       
       		Aadd(oBranch["items"], JsonObject():New())
                   
            aTail(oBranch["items"])['code']        := Alltrim(aFiliais[nIt][2])
            aTail(oBranch["items"])['description'] := Alltrim(aFiliais[nIt][7])    
            aTail(oBranch["items"])['deleted']     := .F.
            
       EndIf
    Next nIt
    
    If nCount > (nPageSize * nPage)
    	lHasNext := .T.
    EndIf
    
    oBranch["hasNext"] := lHasNext
    
    cResponse := EncodeUTF8(FWJsonSerialize(oBranch, .F., .F., .T.))
    ::SetResponse(cResponse)
               
Return lPost

WSMETHOD GET GetDiff QUERYPARAM page, pageSize PATHPARAM dateDiff WSSERVICE UBAW04
	Local lPost     := .T.
	Local oBranch   := JsonObject():New()
	Local cEmpCor   := FWArrFilAtu()[1]
	Local aFiliais  := {}
	Local nIt	    := 0
	Local cDateTime	:= ""
	Local oPage     := {}
	Local nPage 	:= IIf(!Empty(::page),::page,1)
	Local nPageSize := IIf(!Empty(::pageSize),::pageSize,30)
	Local nCount	:= 0
	Local lHasNext	:= .F.
	
	oPage := FwPageCtrl():New(nPageSize,nPage)
	
	// Coloca a data e hora atual
	// Formato UTC aaaa-mm-ddThh:mm:ss-+Time Zone (coloca a hora local + o timezone (ISO 8601))
	cDateTime := FWTimeStamp(5)
	
	::SetContentType("application/json")
    
    oBranch["hasNext"] := .F.
    oBranch["items"]   := Array(0)
    oBranch["totvs_sync_date"] := cDateTime
    
    aFiliais := FWLoadSM0()
        
    For nIt := 1 to Len(aFiliais)
       If Alltrim(aFiliais[nIt][1]) == Alltrim(cEmpCor)
       		
       		nCount++
			If !oPage:CanAddLine()							
				If nCount <= (nPageSize * nPage)					
					LOOP					
				Else
					EXIT
				EndIf
			EndIf
       
       		Aadd(oBranch["items"], JsonObject():New())
                   
            aTail(oBranch["items"])['code']        := Alltrim(aFiliais[nIt][2])
            aTail(oBranch["items"])['description'] := Alltrim(aFiliais[nIt][7])    
            aTail(oBranch["items"])['deleted']     := .F.
            
       EndIf
    Next nIt
    
    If nCount > (nPageSize * nPage)
    	lHasNext := .T.
    EndIf
    
    oBranch["hasNext"] := lHasNext
    
    cResponse := EncodeUTF8(FWJsonSerialize(oBranch, .F., .F., .T.))
    ::SetResponse(cResponse)
           
Return lPost
