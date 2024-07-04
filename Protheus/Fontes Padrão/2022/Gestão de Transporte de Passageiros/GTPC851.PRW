#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH" 
#INCLUDE "APWIZARD.CH"
#INCLUDE "RPTDEF.CH"                                      
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "SPEDNFE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"    

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTeOSRetorno
Retorna dados do CTeOS

@param	oReq        { "msg": { "entidade": "", "cteos": [ {"id":"" }]}}
@param	oResp       {"xml": "","xmlProt": "","id": "","protocolo": "","rejeicao": null}

@return	Retorno logico indicando se o retorno foi gerado

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function CTeOSRet(oReq, oResp, lAut)

    local oWS    
    local nCTeOS
    Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    local cError
    local cJsonRet
    Default lAut := .F.

    oWS := wsNFeSBra():new()    
    oWS:oWSNFEID := NFESBRA_NFES2():New()
    oWS:oWSNFEID:oWSNOTAS := NFESBRA_ARRAYOFNFESID2():new()
    oWS:_URL := allTrim(cURL)+"/NFeSBRA.apw"			
    oWS:nDIASPARAEXCLUSAO := 0
    oWS:cUserToken := "TOTVS"
    if !lAut
        oWS:cID_ENT := oReq:msg:entidade

        for nCTeOS := 1 to len(oReq:msg:cteos)
            aadd(oWS:oWSNFEID:oWSNOTAS:oWSNFESID2, NFESBRA_NFESID2():new() )
            oWS:oWSNFEID:oWSNOTAS:oWSNFESID2[nCTeOS]:cID := oReq:msg:cteos[nCTeOS]:id
        next    
    Else
        oWs:cID_ENT    := ''
    EndIf
    
    if( oWS:retornaNotas() )
        
        cJsonRet := '{ "cteos":['
        
        for nCTeOS := 1 to len(oWS:oWSRETORNANOTASRESULT:oWSNotas:oWSNFES3)            
            
            if( nCTeOS > 1)
                cJsonRet += ","
            endif
            
            cJsonRet += '{'
            cJsonRet += '"xml": "' + encode64(oWS:oWSRETORNANOTASRESULT:oWSNotas:oWSNFES3[nCTeOS]:oWSNfe:cXml)+ '"'
            cJsonRet += ',"xmlProt": "' + encode64(oWS:oWSRETORNANOTASRESULT:oWSNotas:oWSNFES3[nCTeOS]:oWSNfe:cXmlProt) + '"'
            cJsonRet += ',"id": "' + alltrim(oWS:oWSRETORNANOTASRESULT:oWSNotas:oWSNFES3[nCTeOS]:cId) + '"'
            cJsonRet += ',"protocolo": "' + oWS:oWSRETORNANOTASRESULT:oWSNotas:oWSNFES3[nCTeOS]:oWSNfe:cProtocolo + '"'
            cJsonRet += ',"rejeicao": null'
            cJsonRet += '}'

        next
    
        cJsonRet += ']}'
    
    else
        cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))    
    endif
    
    freeObj(oWS)
    oWs := nil
    
    oResp := getJsonResponse(cJsonRet, cError)

return oResp <> nil

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTeOSConsEvento
Consulta Status dos Eventos do CTe

@param	oReq    { "msg": {"entidade": "", "canc": [ {"chaveCTe": "", "protocolo": "","justificativa": ""}]} }
@param	oResp   {"status": 1,"details": "","autorizacao":{"protocolo": ""},"rejeicao": {"codigo": "", "motivo": ""}}

@return	Retorno logico indicando se o retorno foi gerado

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function CTeOSConEv(oReq, oResp, lAut)
    
    local oWS      
    Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    local cStatEven := ""
    local cMotEven  := ""
    local cProtocolo:= ""    
    local cJsonRet
    local cError
    Default lAut := .F.

    oWS  := wsNFeSBra():new()
    oWS:_URL       := AllTrim(cURL) + "/NFeSBRA.apw"
    oWS:cUserToken := "TOTVS"
    oWS:cID_ENT     := iif(lAut, '', oReq:msg:entidade)
    oWS:cEvento     := iif(lAut, '', oReq:msg:codEvento)
    oWS:cChvInicial := iif(lAut, '', oReq:msg:chaveCTe)
    oWS:cChvFinal   := iif(lAut, '', oReq:msg:chaveCTe)
 
    if(oWS:nfeMonitorLoteEvento()) .or. lAut
        nLote := len(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO)
        if ( nLote > 0 ) 
	        cStatEven := str(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nCStatEven, 3)
	        cMotEven  := alltrim(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:cCMotEven)
	        
	        if( oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nCStatEven == 0 )            
	        
	            cJsonRet :='{"status": 1, "details": "Aguardando Processamento.", '
	            cJsonRet += '"autorizacao":{"protocolo": ""}, '
	            cJsonRet += '"rejeicao": {"codigo": "", "motivo": ""} }' 
	        
	        elseif(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nProtocolo > 0 )
	
	            cProtocolo:= alltrim(str(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nProtocolo))
	            cJsonRet := '{"status": 2, "details": "Evento Autorizado.", '
	            cJsonRet += '"autorizacao":{"protocolo": "' + cProtocolo + '"}, '
	            cJsonRet += '"rejeicao": {"codigo": "", "motivo": ""} }'
	            
	        else
	            cJsonRet := '{"status": 3, "details": "Evento Rejeitado.", '
	            cJsonRet += '"autorizacao":{"protocolo": "" }, "rejeicao": '
	            cJsonRet += '{ "codigo": "' + cStatEven +'", "motivo":"' + cMotEven + '"}}' 
	
	        endif
		else
			cError := "Documento não possui evento."	  
		endif        
    else
        cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))
    endif
    
    oResp := getJsonResponse(cJsonRet, cError)
    
return oResp <> nil

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTeOSMonitor
Retorna dados do CTeOS

@param	oReq        {"msg":{"entidade": "","modelo": "67","id": ""}}
@param	oResp       {"id": "", "protocolo": "", "situacao": "","statusSef": "","descSef": "", "status": boolean}'

@return	Retorno logico indicando se o retorno foi gerado

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function CTeOSMnt(oReq, oResp)
    
    local oWS
    local cError
    local cEntidade := getCfgEntidade(@cError)
    local cJsonRet
    local lSend       := .F.
    local nLote
    local cStatusSef  := ""
    local cDescSef    := "Documento não Processado"
    Local cURL        := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    local cStatusProc := "1"
    local aRetorno      := {}
    local nX            := 0
    
    if(!empty(cEntidade))
        oWS := wsNFeSBra():new()    
        oWS:_URL := allTrim(cURL) + "/NFeSBRA.apw"
        oWS:cUserToken := "TOTVS"
        oWS:cID_ENT    := oReq:msg:entidade
        oWS:cIdInicial := oReq:msg:id
        oWS:cIdFinal   := oReq:msg:id
        oWS:cModelo    := "67"
        
        lSend := oWS:monitorFaixa()
        
    endif
    
    if(lSend)
        
        if(!empty(oWs:oWSMonitorFaixaResult:oWSMonitorNFE))
            
            nLote := len(oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:oWSErro:oWSLoteNFe)                
            cStatusSef := oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:oWSErro:oWSLoteNFe[nLote]:cCodRetNFe
            cDescSef   := oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:oWSErro:oWSLoteNFe[nLote]:cMsgRetNFe
            
            if( left(cStatusSef, 1) == "1" )            
                //Autorizado
                if( cStatusSef $ "100|134|135|136")
                    cStatusProc := "2"                
                //Cancelado
                elseif( cStatusSef $ "101|102")
                    cStatusProc := "3"                  
                //lote nao encontrado/Uso denegado
                elseif( cStatusSef $ "106|110")
                    cStatusProc := "4"
                //Não processado
                else
                    cStatusProc := "1"
                endif    
            //Rejeitado
            else
                cStatusProc := "4"
            endif
            
                     
            cJsonRet := '{'  
            cJsonRet += ' "id": "' + oWs:oWSMonitorFaixaResult:oWSMONITORNFE[1]:cId + '"'
            cJsonRet += ', "protocolo": "' + oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:cProtocolo + '"'
            cJsonRet += ', "situacao": "' + oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:cRecomendacao + '"'
            cJsonRet += ', "statusSef": "' + cStatusSef + '"'
            cJsonRet += ', "descSef": "' + cDescSef + '"'
            cJsonRet += ', "status": "' + cStatusProc + '"'

            //-------------------------------------------------------------
            // Chave Eletronica
            // Realizado ajuste para gravar nas tabelas SF3 e SFT, e com 
            // isso, trouxe para ser exibido no Browse.
            // @Douglas Parreja
            // @Date: 20/03/2018
            //-------------------------------------------------------------
            if (  (valtype(oWs:oWSMonitorFaixaResult:oWSMONITORNFE[1]:cId) <> "U") .and.;
                     (valtype(oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:cProtocolo) <> "U") .and.;
                         (valtype(oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:cRecomendacao) <> "U") .and.;
                            (valtype(cStatusSef) <> "U") .and.;
                                (valtype(cDescSef) <> "U") .and.;
                                    (valtype(cStatusProc) <> "U") .and.;
                                        (valtype(oReq:msg:serie) <> "U") .and.;
                                            (valtype(oReq:msg:Nota) <> "U") )


                aAdd( aRetorno, {   oWs:oWSMonitorFaixaResult:oWSMONITORNFE[1]:cId              ,;  // 1-Id
                                    oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:cProtocolo       ,;  // 2-Protocolo
                                    oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:cRecomendacao    ,;  // 3-Situacao
                                    cStatusSef                                                  ,;  // 4-Status Sefaz
                                    cDescSef                                                    ,;  // 5-Descricao Sefaz
                                    cStatusProc                                                 ,;  // 6-Status Processamento
                                    oReq:msg:serie                                              ,;  // 7-Serie
                                    oReq:msg:Nota                                               ;   // 8-Nota
                                })
             
                if len( aRetorno ) > 0                                   
                    if getXMLNFE( oReq:msg:entidade, @aRetorno )
                        if (len( aRetorno ) > 0)
                            monitorUpd( oReq:msg:entidade, aRetorno )
                        endif
                    endif
                endif                
			endif

            //-------------------------------------------------------------
            // Sera exibido no Browse a chave
            //-------------------------------------------------------------
            if len(aRetorno) > 0
                for nX := 1 to len(aRetorno)
                    if valtype(aRetorno[nX][9]) <> "U"
                        if len(aRetorno[nX][9]) > 0
                            cJsonRet += ', "chave eletronica": "' + SubStr(NfeIdSPED(aRetorno[nX][9],"Id"),4)     
                        endif
                    endif
                next nX
            endif
            cJsonRet +=    + '"}'

            FreeObj( oWs )
	        oWs	:= nil

        else
            cError := "Documento não transmitido para o TSS"
        endif
    else
        cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))
    endif

    oResp := getJsonResponse(cJsonRet, cError)
    
return oResp <> nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getXMLNFE
executa e Retorna dados do metodo retornaNotas

@param  cIdEnt			Entidade no TSS
        aDados			array de retorno do monitorFaixa
        cModelo			Modelo do documento
        lReprocesso	    Reprocesso de documentos nao retornados 

@return	aDados          aDados[1] - Protocolo
                        aDados[2] - Xml do CTEOs
                        aDados[3] - Data hora Recebimento

@author  Douglas Parreja
@since   20/03/2018
@version 12
/*/
//-------------------------------------------------------------------
static Function getXMLNFE( cIdEnt, aDados )

	local cURL				:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
	local cProtocolo		:= ""
	local cXml				:= ""
	local cDHRecbto		    := ""
	local cDtHrRec   		:= ""
	local cDtHrRec1		    := "" 
	local dDtRecib			:=	CToD("")
	local nDtHrRec1		    := 0
    local nX                := 0
	local oWS	
    
	private oDHRecbto

    default cIdEnt  := ""
    default aDados  := {}
	
    if ( !empty(cIdEnt) .and. (len(aDados) > 0) )

        oWS:= WSNFeSBRA():New()
        oWS:cUSERTOKEN        := "TOTVS"
        oWS:cID_ENT           := cIdEnt
        oWS:oWSNFEID          := NFESBRA_NFES2():New()
        oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        oWS:nDIASPARAEXCLUSAO := 0
        oWS:_URL := AllTrim(cURL)+"/NFeSBRA.apw"


        for nX := 1 to len( aDados )
            //---------------------------------------------------------------
            // Como a rotina de CTEOs nao tem a opcao de Range monitor,
            // neste caso estou adicionando unico registro.
            //---------------------------------------------------------------
            aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
            Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := alltrim( aDados[nX][1] ) 

            if len(oWS:oWSNFEID:oWSNotas:oWSNFESID2) > 0
                
                if oWS:RETORNANOTASNX() 

                    if len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0 
                        
                        nPosId := aScan(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5,{|X| alltrim(X:cID) == alltrim( aDados[nX][1] ) }) 
                        
                        if nPosId > 0
                            //---------------------------------------------------------------
                            // Modalidade Normal
                            //---------------------------------------------------------------
                            cProtocolo	:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nPosId]:oWSNFE:CPROTOCOLO
                            cXml		:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nPosId]:oWSNFE:CXML
                            cDHRecbto	:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nPosId]:oWSNFE:CXMLPROT
                        
                            
                            //---------------------------------------------------------------
                            //Tratamento para gravar a hora da transmissao da NFe
                            //---------------------------------------------------------------
                            If !empty(cProtocolo)
                                oDHRecbto		:= XmlParser(cDHRecbto,"","","")
                                cDtHrRec		:= IIf(Type("oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT,"")
                                oDHRecbto		:= NIL
                                nDtHrRec1		:= RAT("T",cDtHrRec)
                                
                                If nDtHrRec1 <> 0
                                    cDtHrRec1	:=	SubStr(cDtHrRec,nDtHrRec1+1)
                                    dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
                                EndIf
                
                            EndIf
                            //---------------------------------------------------------------
                            // Atribuindo valores no array
                            //---------------------------------------------------------------                            
                            aAdd( aDados[nX], cXml      ) // 9-Xml
                            aAdd( aDados[nX], cDHRecbto ) // 10-Hora Recebimento 										
                            aAdd( aDados[nX], cDtHrRec1 ) // 11-Hora Recebimento
                            aAdd( aDados[nX], dDtRecib  ) // 12-Data Recebimento                        												
                        
                        endif            
                    endif
                else
                    Aviso("CTEOS",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
                endif
            endif
        next nX
        
        FreeObj( oWS )
        oWs	:=	nil
    
    endif
	
return ( iif( len(aDados)>0, .T., .F.) )

//-------------------------------------------------------------------
/*/{Protheus.doc} monitorUpd
Funcao responsavel por atualizar os livros fiscais.

@param  cIdEnt			Entidade no TSS
        aDados			array de retorno do monitorFaixa
        
@author  Douglas Parreja
@since   20/03/2018
@version 12
/*/
//-------------------------------------------------------------------
static function monitorUpd(cIdEnt, aDados, lAut)

	local cId			:= ""
	local cProtocolo	:= ""
	local cSituacao		:= ""
	local cStatusSef	:= ""
	local cDescSef		:= ""
	local cStatusProc	:= ""
	local cXml 		    := ""
    local cSerie        := ""
    local cNota 	    := ""
	local cDHRecbto		:= ""
	local cDtHrRec1	    := ""
	local dDtRecib		:= date()
    local nX            := 0

    default aDados      := {}
    default lAut        := .F.
	
    for nX := 1 to len( aDados )
								
        cId				:= iif( valtype(aDados[nX][1])<>"U" ,  aDados[nX][1], cId           ) // 1-Id
		cProtocolo		:= iif( valtype(aDados[nX][2])<>"U" ,  aDados[nX][2], cProtocolo    ) // 2-Protocolo		
		cSituacao		:= iif( valtype(aDados[nX][3])<>"U" ,  aDados[nX][3], cSituacao     ) // 3-Situacao 		
		cStatusSef		:= iif( valtype(aDados[nX][4])<>"U" ,  aDados[nX][4], cStatusSef    ) // 4-Status Sefaz		
		cDescSef		:= iif( valtype(aDados[nX][5])<>"U" ,  aDados[nX][5], cDescSef      ) // 5-Descricao Sefaz
		cStatusProc		:= iif( valtype(aDados[nX][6])<>"U" ,  aDados[nX][6], cStatusProc   ) // 6-Status Processamento
		cSerie 		    := iif( valtype(aDados[nX][7])<>"U" ,  aDados[nX][7], cSerie         ) // 7-Serie
        cNota 		    := iif( valtype(aDados[nX][8])<>"U" ,  aDados[nX][8], cNota         ) // 8-Numero da Nota
        cXml 		    := iif( valtype(aDados[nX][9])<>"U" ,  aDados[nX][9], cXml          ) // 9-Xml
        cDHRecbto		:= iif( valtype(aDados[nX][10])<>"U" ,  aDados[nX][10], cDHRecbto   ) // 10-Hora Recebimento 
		cDtHrRec1	    := iif( valtype(aDados[nX][11])<>"U" ,  aDados[nX][11], cDtHrRec1   ) // 11-Hora Recebimento					 		
		dDtRecib		:= iif( valtype(aDados[nX][12])<>"U",  aDados[nX][12], dDtRecib     ) // 12-Data Recebimento 
		
        dbSelectArea("SF3")
        SF3->(dbSetOrder(5))
		if lAut .or. SF3->(dbSeek(xFilial("SF3")+ cSerie + cNota) ) 
            if ( (SF3->(ColumnPos("F3_CHVNFE") > 0)) .and. (SF3->(ColumnPos("F3_CODRSEF")) > 0) .and.  (SF3->(ColumnPos("F3_PROTOC")) > 0) .and. (SF3->(ColumnPos("F3_DESCRET")) > 0) ) 
                SF3->(reclock("SF3",.F.))
                SF3->F3_PROTOC  := cProtocolo  
                SF3->F3_CODRSEF := cStatusSef  
                SF3->F3_DESCRET := cDescSef  
                SF3->F3_CHVNFE  := SubStr(NfeIdSPED(cXml,"Id"),4)
                SF3->(MsUnLock())
            endif
            if( SFT->(ColumnPos("FT_CHVNFE") > 0) ) 
                SFT->(reclock("SFT",.F.))
                SFT->FT_CHVNFE  := SubStr(NfeIdSPED(cXml,"Id"),4)
                SFT->(MsUnLock())
            endif
        endif                
		
	next nX
	
return
