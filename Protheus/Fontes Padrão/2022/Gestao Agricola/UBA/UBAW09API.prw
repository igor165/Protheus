#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

/*/{Protheus.doc} UBAW09API
//Responsável por centralizar o recebimentos das requisições REST no que se trata 
// do emblocamento físico dos fardinhos
@author brunosilva
@since 18/07/2018
@version 1.0
/*/
WSRESTFUL UBAW09API DESCRIPTION ('Endpoint de emblocamento físico de fardinhos');
FORMAT "application/json,text/html" 

	WSDATA SourceBranch As CHARACTER
	
	WSDATA Page       	AS INTEGER 		OPTIONAL
    WSDATA PageSize    	AS INTEGER		OPTIONAL

	WSMETHOD GET bales;
	DESCRIPTION ("Retorna fardinhos disponíveis para emblocamento físico.");
	PATH "v1/bales" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj   

 	WSMETHOD PUT balesPut;
	DESCRIPTION ("Altera fardinhos e blocos pós-emblocamento físico.");
	PATH "/v1/balesPut" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj	

END WSRESTFUL

WSMETHOD GET bales QUERYPARAM Page,PageSize WSRECEIVE sourceBranch WSREST UBAW09API
	Local lRet    	as LOGICAL
	Local oFWBale 	as OBJECT
	Local aQryParam	as array
	
	aQryParam := {}
	
	lRet := .T. 
	
	oFWBale := FWBalesAdapter():new()
    oFWBale:oEaiObjRec := FWEaiObj():new()
	
	oFWBale:oEaiObjRec:setRestMethod('GET')
	
	aAdd(aQryParam,::sourceBranch)
	
	if !(EMPTY(self:Page))
        oFWBale:oEaiObjRec:setPage(self:Page)
    Else
        oFWBale:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWBale:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWBale:oEaiObjRec:setPageSize(30)
    endIf
    
    oFWBale:oEaiObjRec:Activate()
    
    oFWBale:lApi := .T.
    oFWBale:GetBale( aQryParam )

    if oFWBale:lOk
        ::SetResponse(EncodeUtf8(oFWBale:oEaiObjSnd:GetJson(,.T.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWBale:cError ))
        lRet := .F.
    EndIf
    
Return lRet


WSMETHOD PUT balesPut WSREST UBAW09API
	Local oResponse 	:= JsonObject():New()
    Local oRequest  	:= Nil
     
    Local cResponse		:= ""
    Local cBloco		:= ""
	Local cDXDFilial 	:= "" 
	Local cDXDSafra  	:= ""
	Local cDXDBloco  	:= "" 	    
    Local nLinha		:= 0
 	Local lRetorno 		:= .F.
	Local lNewBloco 	:= .F.

    // define o tipo de retorno do método
	::SetContentType("application/json")
	cContent := ::GetContent()

	FWJsonDeserialize(cContent,@oRequest)
	
	BEGIN Transaction
		For nLinha := 1 TO Len ( oRequest["Item"] )
			
			If nLinha = 1
				cBloco := oRequest["Item"][nLinha]["PACK"]
				lNewBloco := .T.
			ElseIf cBloco <> oRequest["Item"][nLinha]["PACK"]
				cBloco 	  := oRequest["Item"][nLinha]["PACK"]
				lNewBloco := .T.
			EndIf
			
			//--Tabela de Fardinhos
			nReg := oRequest["Item"][nLinha]["RECNO"]
			DbSelectArea("DXI")
			DXI->(dbGoTo(nReg))
			//--Verifica se a Etiqueta eh a mesma enviada
			IF AllTrim(DXI->DXI_ETIQ) == AllTrim(oRequest["Item"][nLinha]["BARCODE"]) 
				if !EMPTY(oRequest["Item"][nLinha]["WAREHOUSE"])
					//--Trava registro
					If RecLock("DXI", .F.)
						//--Emblocamento Fisico
						If .NOT. Empty( oRequest["Item"][nLinha]["EMBFIS"] )
							DXI->DXI_EMBFIS := "1" //oRequest["Item"][nLinha]["EMBFIS"]	//Emblocado Fisicamente - 1=Sim;2=Não
						EndIf
						
						//--Local
						If .NOT. Empty( oRequest["Item"][nLinha]["WAREHOUSE"] )
							DXI->DXI_LOCAL := oRequest["Item"][nLinha]["WAREHOUSE"]
						EndIf
						DXI->(MsUnLock())
						
						lRetorno := .T.
				    EndIf
				else
					//Erro armazem vazio!
					cResponse := "Local(warehouse) em branco. Não houve alteração."
					//cResponse := FWJsonSerialize(cResponse, .F., .F., .T.)
					//::SetResponse(EncodeUTF8(cResponse))	
				endIf
			else
				//Erro etiqueta não confere como o registro
				cResponse := "Etiqueta(barCode) não confere como o registro. Não houve alteração."
				//cResponse := FWJsonSerialize(cResponse, .F., .F., .T.)
				//::SetResponse(EncodeUTF8(cResponse))	 
			EndIf
			
			If lNewBloco .AND. lRetorno
				cDXDFilial := PadR(oRequest["Item"][nLinha]["SOURCEBRANCH"],TamSX3("DXD_FILIAL")[1] ) 
				cDXDSafra  := PadR(oRequest["Item"][nLinha]["CROP"],TamSX3("DXD_SAFRA")[1])
				cDXDBloco  := PadR(oRequest["Item"][nLinha]["PACK"],TamSX3("DXD_CODIGO")[1]) 				
				
				//--Tabela de Blocos 
		        dbSelectArea('DXD')
		        dbSetOrder(1)    	
		    	If MsSeek(cDXDFilial+cDXDSafra+cDXDBloco)
			    	RecLock("DXD",.F.)
			    		DXD->DXD_LOCAL := oRequest["Item"][nLinha]["WAREHOUSE"]
			    	MsUnLock()
			    EndIf
			    lNewBloco := .F.
			EndIf
			
			If nLinha = Len ( oRequest["Item"] ) .AND. lRetorno
				oResponse["content"] := {}
				Aadd(oResponse["content"], JsonObject():New())
				oResponse["content"][1]["Status"]	:= "OK" 
			    oResponse["content"][1]["Message"]	:= "Fardos/Blocos alterados com sucesso."
			EndIf 
		Next nLinha
		
	END Transaction

	If lRetorno 
		cResponse := EncodeUTF8(FWJsonSerialize(oResponse, .F., .F., .T.))
		::SetResponse(cResponse)
	Else
		//cResponse := "Fardos/Blocos não encontrados. Não houve alteração."
		cResponse := FWJsonSerialize(cResponse, .F., .F., .T.)
		::SetResponse(EncodeUTF8(cResponse))	
	EndIf
	
	DXI->(DbCloseArea())
	DXD->(DbCloseArea())
	
Return(lRetorno)