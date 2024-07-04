#include 'totvs.ch'
#include "restful.ch"
/*/{Protheus.doc} FWINGETSX5
Classe Adapter para consulta da tabela do SX5
@author Alessandro Afonso
@since 17/12/2020
@version 1.0
@Date 26/01/2022
@type function
/*/ 
CLASS FWINGETSX5 //FROM FWAdapterBaseV2
    DATA cJson   AS CHARACTER 
    METHOD New()
    METHOD GetListConnect() 
EndClass
 
Method New( cVerb ) CLASS FWINGETSX5
return
 
/*/{Protheus.doc} FWIGETSX5
Classe Adapter para consulta da tabela do SX5
@author Alessandro Afonso
@since 17/12/2020
@version 1.0
@type function
/*/
WSRESTFUL FWIGETSX5 DESCRIPTION 'Consulta da tabela SX5' FORMAT "application/json,text/html"
    WSDATA View     AS CHARACTER 
    WSMETHOD GET DESCRIPTION "Retorna os registros da tabela SX5."  WSSYNTAX "/api/v1/FWIGETSX5" 
     
END WSRESTFUL

WSMETHOD GET WSRECEIVE Page WSSERVICE FWIGETSX5  
Return getConnList(self)
 
Static Function getConnList( oWS, lLocal )
   Local lRet      as logical
   Local oConnList as object
   DEFAULT oWS:View      := "ND|"
   DEFAULT lLocal        := .F.
   
   If !lLocal 
         oWS:SetContentType("application/json;charset=utf-8")
   Endif
  
   oWS:View :=  Upper(oWS:View) 
   lRet        := .T.

   oConnList := FWINGETSX5():new()  
   
   // Esse metodo ira processar as informaçoes
   oConnList:GetListConnect( oWS )

    If !lLocal
        oWS:SetResponse(oConnList:cJson)
    Else    
        cxSelView := Upper(oWS:View)
        FErase("c:\temp\views\" + cxSelView + ".json")
        MemoWrit("c:\temp\views\" + cxSelView + ".json",oConnList:cJson )
    Endif

   oConnList := nil  

Return lRet

Method GetListConnect( oWS, lLocal ) CLASS FWINGETSX5
    Local aJson      := {}
    Local cRet       := ''
    Local ni         := 1 
    DEFAULT oWS:View := "ND|"
    Default lLocal   := .F.

    cRet := '{ "items": ['
    aJson := FWGetSX5( oWS:View )
    For ni := 1 to  Len(aJson) 
        cRet += '{'
        cRet += '    "tabela" : "' + Alltrim(oWS:View) + '",' 
        cRet += '    "data" :   "' + SubStr(DTOS(dDatabase),1,4) + "-" + SubStr(DTOS(dDatabase),5,2) + "-" + SubStr(DTOS(dDatabase),7,2) + "T" + Time() + 'Z",' 
        cRet += '    "companyid":  "' + cEmpAnt + '",' 
        cRet += '    "branchid": "' + cFilAnt +  '",' 
        cRet += '    "code":  "' + Alltrim(aJson[ni][3]) + '",' 
        cRet += '    "description":  "' + StrTran(Alltrim(aJson[ni][4]),'"', '') + '",' 
        cRet += '    "internalid":  "' + cEmpAnt  + "|" + Alltrim(xFilial("SX5")) + "|" + Alltrim(aJson[ni][3]) + '" ' 
        
        if ni == Len(aJson)
            cRet += '}'
        Else'
            cRet += '},'
        Endif    
    Next ni   
    cRet += '],"hasNext": false}'

    ::cJson := cRet
Return

/*/{Protheus.doc} TConAd5
    Classe simula o envio do json pelo client.
    @author Alessandro Afonso
    @since 07/10/2021
    @type class
    @version V6
    /*/
Class TConAd5
    data View 
    data Page      
    data PageSize  
    data Fields    
    data DROP      
    data aQueryString
    data Filial
    data Order
    Method New() 
EndClass
Method New() Class TConAd5
    ::View      := "HB"
    ::Fields    := "" 
    ::Filial        := 'D MG 001'
Return 

Static Function FWIX5Adp()
    Local cFil :=  'D MG 001'
    RpcSetEnv(cEmp,cFil,,,,,)

    oWS := TConAd5():New()
    getConnList( oWS, .T. )
    FreeObj(oWs)

Return Nil
