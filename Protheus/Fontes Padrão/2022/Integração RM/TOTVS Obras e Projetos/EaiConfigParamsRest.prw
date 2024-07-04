#Include "RESTFUL.CH"
#Include "TOTVS.CH"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "FWAdapterEAI.ch"  
#Include "COLORS.CH"                                                                                                     
#Include "TBICONN.CH"
#Include "COMMON.CH" 
#Include "XMLXFUN.CH"
#Include "fileio.ch" 
#Include 'FWMVCDEF.CH' 


#DEFINE  TAB  CHR ( 13 ) + CHR ( 10 )
WSRESTFUL EAICONFIGPARAMS DESCRIPTION "Serviço REST para manipulaçao dos Parametros do Protheus"
   WSDATA sourceApp     AS STRING
   WSDATA companyId     AS STRING
   WSDATA branchId      AS STRING
   WSDATA IdParametro   As STRING

   WSMETHOD GET IdParametro ;
   DESCRIPTION "Carrega o parametro especifico informado na URL" ;
   WSSYNTAX "/EAICONFIGPARAMS/{IdParametro}/{sourceApp, companyId, branchId}"

   WSMETHOD POST ALL;
   DESCRIPTION "Carrega os parametros especificos informados no Json" ;
   WSSYNTAX "/EAICONFIGPARAMS/";
   PATH  ""

   WSMETHOD POST UPSERT;
   DESCRIPTION " Upsert dos parametros especificos informados no Json" ;
   WSSYNTAX "/EAICONFIGPARAMS/{SourceApp,CompanyId,BranchId}/{EAICONFIGPARAMS}";
   PATH     "/EAICONFIGPARAMS/UPSERT"

END WSRESTFUL

WSMETHOD POST UPSERT PATHPARAM UPSERT WSSERVICE EAICONFIGPARAMS    
  Local cJson        := Self:GetContent()   
  Local lMetodo      := .t.
  Local nx           := 0
  Local oJson        As Object
  Local cCatch       As Character  
  Local oReturnJson  As Object
  Local vetParam     := {}
  Local jsParam      := NIL
  oJson              := JsonObject():New()
  cCatch             := oJson:FromJSON(cJson)

  If cCatch == Nil .and. PrePareContexto(oJson["SourceApp"],oJson["CompanyId"],oJson["BranchId"])      	 
    FOR nx:=1 To Len(oJson["Parameters"])      
	   cParam     := UPPER(oJson["Parameters"][nx]["Param"])
	   cTipo      := oJson["Parameters"][nx]["Tipo"]
	   cDescricao := oJson["Parameters"][nx]["Descricao"]
	   cConteudo  := oJson["Parameters"][nx]["Conteudo"]
     If !GetMV(cParam,.T.)
		    RecLock("SX6",.T.)	  
		    SX6->X6_VAR        :=  cParam
	   		SX6->X6_TIPO       :=  cTipo
		  	SX6->X6_PROPRI     :=  "U"			
			  SX6->X6_DESCRIC    :=  cDescricao
			  SX6->X6_DSCSPA     :=  cDescricao
		  	SX6->X6_DSCENG     :=  cDescricao		
		  	SX6->X6_CONTEUD    :=  alltrim(cValToChar(cConteudo))
		  	SX6->X6_CONTSPA    :=  alltrim(cValToChar(cConteudo))
		  	SX6->X6_CONTENG    :=  alltrim(cValToChar(cConteudo))
		  	MsUnLock()
	 	 Else
		  	PUTMV(cParam , cConteudo)
		 Endif		
     jsParam := JsonObject():new()	
     jsParam["Parameter"] := cParam
     jsParam["Valor"    ] := GetMv(cParam)	
     aadd(vetParam,jsParam)
    NEXT  	  
    oReturnJson := JsonObject():new()
    oReturnJson['ProtheusParameter'] := vetParam
  	ExportarJson(Self , oReturnJson, "EaiConfigParams")
  else
    lMetodo :=.f.
  ENDIF	  
Return lMetodo

WSMETHOD POST ALL PATHPARAM ALL WSSERVICE EAICONFIGPARAMS   
  LOCAL cJson        := Self:GetContent()   
  Local lMetodo      := .t.
  Local nx           := 0
  Local oJson        As Object
  Local cCatch       As Character  
  LOCAL oReturnJson  As Object
  oJson              := JsonObject():New()
  cCatch             := oJson:FromJSON(cJson)
  If cCatch == Nil .and. PrePareContexto(oJson["SOURCEAPP"],oJson["COMPANYID"],oJson["BRANCHID"])      
	  oReturnJson := JsonObject():new()
    FOR nx:=1 To Len(oJson["PARAMETERS"])   
        oReturnJson[ oJson["PARAMETERS"][nx]["PARAM"] ] := GetMv(oJson["PARAMETERS"][nx]["PARAM"])	
    NEXT  	  
	  ExportarJson(Self , oReturnJson, "EaiConfigParams")
  else
    lMetodo :=.f.
  ENDIF	  
Return lMetodo


WSMETHOD GET IdParametro WSRECEIVE sourceApp , companyId , branchId  WSSERVICE EAICONFIGPARAMS
  
  Local cCodParametro   := Self:IdParametro
  Local cValueParametro := ""
  Local lMetodo		    := .T.

  DEFAULT ::sourceApp	   := ""
  DEFAULT ::companyId	   := ""
  DEFAULT ::branchId	   := ""  
  DEFAULT ::IdParametro    := ""  

 IF PrePareContexto( ::sourceApp, ::companyId, ::branchId)      
  	cCodParametro := ::IdParametro
    cValueParametro := GetMv(cCodParametro)	
    oReturnJson := JsonObject():new()
    oReturnJson[cCodParametro] := cValueParametro
	  ExportarJson(Self , oReturnJson, "EaiConfigParams")
 ENDIF
Return lMetodo



Static Function ExportarJson(Self , oReturnJson, cApi)
  LOCAL	lMetodo := .t.
  LOCAL oJson  As Object  
  ::SetContentType("application/json")  
  oJson := JsonObject():new()
  oJson := oReturnJson
  IF ValType(oJson) == "J"
	   Conout("Api:" + cApi + "-> Json gerado com sucesso. ")
  else		
     Conout("Api:" + cApi + "-> Falha ao gerar Json. ")   	   
  ENDIF  
  ::SetResponse(oJson:toJson())   
Return lMetodo


Static Function PrePareContexto(cSourceApp , cCompanyId , cBrancId)
 LOCAL	lMetodo     := .f.
 LOCAL  cCodEmpresa := ""
 LOCAL  cCodFilial  := ""
 aEmpre := FWEAIEMPFIL(cCompanyId, cBrancId, cSourceApp)
 If Len (aEmpre) < 1
    SetRestFault(400, "Empresa: " + cCompanyId + " Nao existem para o Sistema: " + cSourceApp + " !")
	lMetodo := .f.
 else
    cCodEmpresa  := aEmpre[1]	
	cCodFilial   := aEmpre[2]
    RESET ENVIRONMENT
    RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA cCodEmpresa FILIAL cCodFilial TABLES "XX4" MODULO "CFG" 		
	lMetodo := .t.
 ENDIF	

Return lMetodo

