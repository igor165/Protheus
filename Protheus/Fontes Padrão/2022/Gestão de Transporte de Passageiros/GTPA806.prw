#INCLUDE "GTPA806.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWBROWSE.CH"

/*/{Protheus.doc} CteCanc
(Rotina responsavel por realizar o cancelamento de um CTe)
@type function
@author gustavo.silva2
@since 14/10/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPA806()
Local cStatus	:= G99->G99_STATRA
Local cProtoc	:= G99->G99_PROTCA
Local cSerie	:= G99->G99_SERIE
Local cNota		:= G99->G99_NUMDOC

If cStatus=='8'
	FwAlertHelp(STR0001,"Esse CTe já está cancelado")
ElseIf cStatus=='0'
	FwAlertHelp(STR0001,"Esse CTe não foi enviado para o Sefaz, e portanto, não pode ser cancelado")
Else
	ExclDoc(cSerie, cNota)
	cStatus	:= G99->G99_STATRA
	If cStatus $ '6|7' .And. Empty(cProtoc)
		G99Cancelamento()
	Else
		FwAlertHelp(STR0001,STR0002)
	EndIf
EndIf
	
Return
/*/{Protheus.doc} G99Cancelamento
(Função cria o Wizard de cancelamento)
@type function
@author gustavo.silva2
@since 14/10/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function G99Cancelamento(cAlias, nReg, nOpc) 
Local cError         := ""
Local cEntidade      := getCfgEntidade(@cError)
Local lContinua      := .T.
Local cChaveCte
Local cProtocolo
Local cTipoEvento    := "110111"
Local oFont
Local oWizard
Local cLbStatus      := ""
Local oImgStatus
Local cJustificativa := ""
Local cBtmStatus     := ""
Local cRetorno       := ""
Local oSay
Local cId

lContinua := !empty(cEntidade)

If(lContinua)

    cChaveCte := G99->G99_CHVCTE
    cId       := (alltrim(G99->G99_SERIE) + alltrim(G99->G99_NUMDOC))

    cTexto := STR0003

    DEFINE FONT oFont NAME "Arial" SIZE 0, -13 BOLD

    oWizard := APWizard():new( STR0004,STR0005,;
                               STR0006 + CRLF,cTexto,,,,,,.F.)

    oWizard:NewPanel (STR0007 ,"" , {||.T.} ,;
        {|| processa({|| processCanc(cEntidade, cId, cChaveCTe, cJustificativa, @cLbStatus, @oImgStatus, @cRetorno) }), .T.} , {|| .T.})

    @000,000 GET cJustificativa MEMO SIZE 299, 138 PIXEL OF oWizard:oMPanel[2]

    oWizard:NewPanel ( STR0008, cRetorno , {|| .T.} , {|| .T.} , {|| .T.})

    oImgStatus := TBitmap():New(010,010,260,184,,cBtmStatus,.T.,oWizard:oMPanel[3], {||},,.F.,.F.,,,.F.,,.T.,,.F.)
    @012,025 SAY oSay PROMPT cLbStatus OF  oWizard:oMPanel[3] PIXEL FONT oFont SIZE 150, 015
    @032,010 GET cRetorno MEMO SIZE 290, 115 READONLY PIXEL OF oWizard:oMPanel[3]

    ACTIVATE WIZARD oWizard CENTERED
Else
    aviso(STR0009, cError, {STR0010}, 3)
EndIf

Return nil
/*/{Protheus.doc} processCanc
(Processa o cancelamento)
@type function
@author gustavo.silva2
@since 14/10/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function processCanc(cEntidade, cID, cChave, cJustificativa, cLbStatus, oImgStatus, cRetorno)
Local oReq
Local oResp
Local cReq
Local lValid

lValid := validaJustificativa(cJustificativa)

If(lValid)

    cReq := '{ "msg": {"entidade": "' + cEntidade +'", "notas": ['
    cReq += '{"id": "' + cID + '", "chave":"' + cChave + '","justificativa": "' + cJustificativa + '"} ] } }'

    If(fwJsonDeserialize(cReq, @oReq) )

        CTeCancelamento(oReq, @oResp)

        If(oResp:error == nil)
        	
            cReq := '{ "msg":{'
            cReq += ' "entidade": "' + cEntidade + '"'
            cReq += ', "modelo": "57"'
            cReq += ', "id": "' + cID + '"'
            cReq += ', "serie": "'+ G99->G99_SERIE + '"'
            cReq += ', "nota": "'+ G99->G99_NUMDOC + '" }}'

            If(fwJsonDeserialize(cReq, @oReq))

               CTeMonitor(oReq, @oResp, cChave)
               
               
               oImgStatus:setBmp("qmt_ok.png")

               If(oResp:error == nil)
                    cRetorno := "Id: "           + cID + CRLF//oResp:response:id + CRLF
                    cRetorno += "Protocolo: "    + oResp:response:protocolo + CRLF
                    cRetorno += "Situação: "     + oResp:response:situacao + CRLF
                    cRetorno += "Status Sefaz: " + oResp:response:statusSef
                    cRetorno += " - "            + oResp:response:descSef + CRLF

                    If(oResp:response:status == "3")
                        AtuStatus('G99_STATRA', "8")//Cancelado
                        AtuProtocol(oResp:response:protocolo)
                        oImgStatus:setBmp("qmt_ok.png")

                    ElseIf(oResp:response:status $ "1|2")
                        oImgStatus:setBmp("qmt_cond.png")
                        cLbStatus := STR0018//"Cancelamento não Processado"
                    ElseIf(oResp:response:status == "4")
                        oImgStatus:setBmp("qmt_no.png")
                        AtuStatus('G99_STATRA', "7")//Não cancelado

                    EndIf

                    cLbStatus := oResp:response:descSef

                Else
                    cRetorno := decode64(oResp:error)
                    oImgStatus:setBmp("qmt_no.png")
                    cLbStatus := STR0011 //Falha na Consulta do Cancelamento
                EndIf

            Else
                cRetorno  := STR0013 +CRLF + cReq//Requisição invalida
                oImgStatus:setBmp("qmt_no.png")
                cLbStatus := STR0011 //Falha na Consulta do Cancelamento

            EndIf

        Else
            cRetorno := decode64(oResp:error)
            oImgStatus:setBmp("qmt_no.png")
            cLbStatus := STR0012//Falha na Transmissao do cancelamento

        EndIf
    Else
        oImgStatus:setBmp("qmt_no.png")
        cLbStatus := STR0012//Falha na Transmissão do Cancelamento.
        cRetorno := STR0013 +CRLF + cReq//Requisição Inválida
    EndIf

    oImgStatus:refresh()
EndIf

Return lValid

/*/{Protheus.doc} CTeMonitor
Monta a resposta do webservice para ser exibida
@type function
@author gustavo.silva2
@since 14/10/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function CTeMonitor(oReq, oResp, cChave)   
Local oWS
Local cEntidade := ''//getCfgEntidade(@cError)
Local cJsonRet
Local lSend       := .F.
Local cStatusSef  := ""
Local cDescSef    := STR0014//Doc. Não processado
Local cURL        := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
Local cStatusProc := "1"
Local aRetorno      := {}
Local nX            := 0
Private cError := ""
cEntidade := getCfgEntidade(@cError)

If(!empty(cEntidade))
    oWS := wsNFeSBra():new()    
    oWS:_URL := allTrim(cURL) + "/NFeSBRA.apw"
    oWS:cUserToken := "TOTVS"
    oWS:cID_ENT    := oReq:msg:entidade
    oWS:cIdInicial := oReq:msg:id
    oWS:cIdFinal   := oReq:msg:id
    oWS:cModelo    := "57"
    
    lSend := oWS:monitorFaixa()
    
     //sleep(15000)
    
EndIf

If(lSend)
    
    If(!empty(oWs:oWSMonitorFaixaResult:oWSMonitorNFE))
        
        nLote := len(oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:oWSErro:oWSLoteNFe)                
        cStatusSef := oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:oWSErro:oWSLoteNFe[nLote]:cCodRetNFe
        cDescSef   := oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:oWSErro:oWSLoteNFe[nLote]:cMsgRetNFe
        
        If( left(cStatusSef, 1) == "1" )            
            //Autorizado
            If( cStatusSef $ "100|134|135|136")
                cStatusProc := "2"                
            //Cancelado
            ElseIf( cStatusSef $ "101|102")
                cStatusProc := "3"                  
            //lote nao encontrado/Uso denegado
            ElseIf( cStatusSef $ "106|110")
                cStatusProc := "4"
            //Não processado
            Else
                cStatusProc := "1"
            EndIf    
        //Rejeitado
        Else
            cStatusProc := "4"
        EndIf
                             
        cJsonRet := '{'  
        cJsonRet += ' "id": "' + oWs:oWSMonitorFaixaResult:oWSMONITORNFE[1]:cId + '"'
        cJsonRet += ', "protocolo": "' + oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:cProtocolo + '"'
        cJsonRet += ', "situacao": "' + oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:cRecomendacao + '"'
        cJsonRet += ', "statusSef": "' + cStatusSef + '"'
        cJsonRet += ', "descSef": "' + cDescSef + '"'
        cJsonRet += ', "status": "' + cStatusProc + '"'

        GTPA812RET(G99->G99_CODIGO, '2', cChave, oWS,cJsonRet,'2')  
        //-------------------------------------------------------------
        // Chave Eletronica
        // Realizado ajuste para gravar nas tabelas SF3 e SFT, e com 
        // isso, trouxe para ser exibido no Browse.
        //-------------------------------------------------------------
        If (  (valtype(oWs:oWSMonitorFaixaResult:oWSMONITORNFE[1]:cId) <> "U") .and.;
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
                                oReq:msg:Nota                                               ,;  // 8-Nota
                                cChave														 ;  //9 - ChaveCte
                            })
         
            If len( aRetorno ) > 0                                   
                If Len(getXMLNFE( oReq:msg:entidade, @aRetorno, getCfgEntidade(@cError), '57' ))>0
                    If (len( aRetorno ) > 0)
                        monitorUpd( oReq:msg:entidade, aRetorno )
                    EndIf
                EndIf
            EndIf                
		EndIf

        //-------------------------------------------------------------
        // Sera exibido no Browse a chave
        //-------------------------------------------------------------
        If len(aRetorno) > 0
            for nX := 1 to len(aRetorno)
                If valtype(aRetorno[nX][9]) <> "U"
                    If len(aRetorno[nX][9]) > 0
                        cJsonRet += ', "chave eletronica": "' + SubStr(NfeIdSPED(aRetorno[nX][9],"Id"),4)     
                    EndIf
                EndIf
            next nX
        EndIf
        cJsonRet +=    + '"}'

        FreeObj( oWs )
        oWs	:= nil

    else
        cError := STR0015//"Documento não transmitido para o TSS"
        EndIf
    else
        cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))
    EndIf

    oResp := getJsonResponse(cJsonRet, cError)
    
return oResp <> nil

/*/{Protheus.doc} CTeCancelamento
(Cria o xml de cancelamento)
@type function
@author gustavo.silva2
@since 14/10/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function CTeCancelamento(oReq, oResp)
Local cURL        := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
Local cJsonRet
Local cTipoEvento := "110111"    
Local cXml        := ""
Local cError    
Local oWs
Local cModelo     := "57"
Local cModalidade := getCfgModalidade(@cError)
Local nNotas

oWs:= WsNFeSBra():New()
oWs:cUserToken := "TOTVS"
oWs:cID_ENT    := oReq:msg:entidade
oWS:_URL       := AllTrim(cURL) + "/NFeSBRA.apw"
oWs:oWsNFe:oWsNotas :=  NFESBRA_ARRAYOFNFES():New()

For nNotas := 1 to Len(oReq:msg:notas)
    
    cXml += '<cancelamento Id="' + oReq:msg:notas[nNotas]:chave + '">'
    cXml += '<xJust>' + oReq:msg:notas[nNotas]:justificativa + '</xJust>
    cXml += '</cancelamento>'

    Aadd(oWs:oWsNFe:oWsNotas:oWSNFES,NFESBRA_NFES():New())	
    oWs:oWsNFe:oWsNotas:oWSNFES[nNotas]:cID := oReq:msg:notas[nNotas]:id
    oWs:oWsNFe:oWsNotas:oWSNFES[nNotas]:cXML:= cXml
Next

If( oWS:cancelanotas() )        

    cJsonRet := '{ "motivo": "Cancelamento Transmitido com Sucesso", "id": ['  
    
    For nNotas := 1 to len(oWS:oWSCANCELANOTASRESULT:oWSID:cSTRING)        
        cJsonRet += '{"id": "' + oWS:oWSCANCELANOTASRESULT:oWSID:cSTRING[nNotas] + '"}'
    Next
    
    cJsonRet += ']}'
    
    //Atualização do Status da G99
    AtuStatus('G99_STATRA',"6")  
    GTPA812RET(G99->G99_CODIGO, '2', oReq:msg:notas[1]:chave, NIL,cJsonRet,'1',cXml)  
    
EndIf    

freeObj(oWs)
oWS := nil

oResp :=  getJsonResponse(cJsonRet, cError) 

sleep(15000)
    
Return (oResp <> nil)

/*/{Protheus.doc} validaJustificativa
(Realiza a validação da justificativa)
@type function
@author gustavo.silva2
@since 14/10/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function  validaJustificativa(cJustificativa)
Local lValid := .T.

cJustificativa := Alltrim(cJustificativa)
cJustificativa := StrTran(cJustificativa,Chr(10),"")
cJustificativa := StrTran(cJustificativa,Chr(13),"")
cJustificativa := StrTran(cJustificativa,Chr(135),"&Amp;")
cJustificativa := StrTran(cJustificativa,Chr(198),"&atilde;")

If( Len(cJustificativa) < 15 )
    lValid := .F.
    cJustificativa := STR0016//"A Correção deve ter o mínimo de 15 caracteres"
ElseIf(len(cJustificativa) > 255)
    cJustificativa := STR0017//"A Correção deve ter o máximo de 255 caracteres"
    lValid := .F.
EndIf

If(!lValid)
    aviso(STR0009, cJustificativa, {STR0010}, 3)//"CTe - Cancelamento" / OK
EndIf
return lValid

/*/{Protheus.doc} s
(Atualiza o status da G99)
@type function
@author gustavo.silva2
@since 14/10/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function AtuStatus(cCampo,cStatus)

RecLock("G99", .F.)
G99->G99_STATRA := cStatus
MSUnlock()
									
Return

/*/{Protheus.doc} AtuProtocol
(Atualiza o campo de Protocolo de cancelamento)
@type function
@author gustavo.silva2
@since 14/10/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function AtuProtocol(cProtocol)

RecLock("G99", .F.)
G99->G99_PROTCA := cProtocol
MSUnlock()

Return

/*/{Protheus.doc} monitorUpd
(Atualiza as tabelas F3 e FT)
@type function
@author gustavo.silva2
@since 14/10/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function monitorUpd( cIdEnt, aDados )
Local cId			:= ""
Local cProtocolo	:= ""
Local cSituacao		:= ""
Local cStatusSef	:= ""
Local cDescSef		:= ""
Local cStatusProc	:= ""
Local cChave 		:= ""
Local cSerie        := ""
Local cNota 	    := ""
Local nX            := 0

default aDados      := {}

For nX := 1 to Len( aDados )
							
    cId				:= iif( valtype(aDados[nX][1])<>"U" ,  aDados[nX][1], cId           ) // 1-Id
	cProtocolo		:= iif( valtype(aDados[nX][2])<>"U" ,  aDados[nX][2], cProtocolo    ) // 2-Protocolo		
	cSituacao		:= iif( valtype(aDados[nX][3])<>"U" ,  aDados[nX][3], cSituacao     ) // 3-Situacao 		
	cStatusSef		:= iif( valtype(aDados[nX][4])<>"U" ,  aDados[nX][4], cStatusSef    ) // 4-Status Sefaz		
	cDescSef		:= iif( valtype(aDados[nX][5])<>"U" ,  aDados[nX][5], cDescSef      ) // 5-Descricao Sefaz
	cStatusProc		:= iif( valtype(aDados[nX][6])<>"U" ,  aDados[nX][6], cStatusProc   ) // 6-Status Processamento
	cSerie 		    := iif( valtype(aDados[nX][7])<>"U" ,  aDados[nX][7], cSerie         ) // 7-Serie
    cNota 		    := iif( valtype(aDados[nX][8])<>"U" ,  aDados[nX][8], cNota         ) // 8-Numero da Nota
    cChave 		    := iif( valtype(aDados[nX][9])<>"U" ,  aDados[nX][9], cChave         ) // 9-Chave
    
    dbSelectArea("SF3")
    SF3->(dbSetOrder(5))
	If SF3->(dbSeek(xFilial("SF3")+ cSerie + cNota) )
        If ( (SF3->(ColumnPos("F3_CHVNFE") > 0)) .and. (SF3->(ColumnPos("F3_CODRSEF")) > 0) .and.  (SF3->(ColumnPos("F3_PROTOC")) > 0) .and. (SF3->(ColumnPos("F3_DESCRET")) > 0) )
            SF3->(reclock("SF3",.F.))
            SF3->F3_PROTOC  := cProtocolo  
            SF3->F3_CODRSEF := cStatusSef  
            SF3->F3_DESCRET := cDescSef  
            SF3->F3_CHVNFE  := cChave
            SF3->(MsUnLock())
        EndIf
        If( SFT->(ColumnPos("FT_CHVNFE") > 0) ) 
            SFT->(reclock("SFT",.F.))
            SFT->FT_CHVNFE  := cChave
            SFT->(MsUnLock())
        EndIf
    EndIf                
	
Next nX
	
Return
/*/{Protheus.doc} ConsDocSaida
(Verifica se documento de saída foi excluído)
@type function
@author gustavo.silva2
@since 14/10/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function ConsDocSaida(cSerie,cNota)
Local lRet := .F.

DBselectArea('SF2')
DbSetOrder(1)
If MsSeek(xFilial('SF2')+cNota+cSerie)
	lRet:= .T.
EndIf

Return lRet
/*/{Protheus.doc} ExclDoc
(Realiza a exclusão das notas)
@type function
@author gustavo.silva2
@since 14/10/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ExclDoc(cSerie, cNota)
Local cCliRem	:= G99->G99_CLIREM
Local cLojRem	:= G99->G99_LOJREM
Local cCliDes	:= G99->G99_CLIDES
Local cLojDes	:= G99->G99_LOJDES
Local cTomador	:= G99->G99_TOMADO
Local dDtdigit  := Stod('')
Local cChvNF	:= ''
Local aRegSD2   := {}
Local aRegSE1   := {}
Local aRegSE2   := {}
Local lRet		:= .T.

SF2->(DbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
If cNota<>"" 
    cChvNF  :=  xFilial('SF2')+cNota+cSerie

    If cTomador == "0"
        cChvNF += cCliRem+cLojRem
    Else
        cChvNF += cCliDes+cLojDes
    Endif

    If SF2->(DbSeek(cChvNF))
        // Exclui a nota
        dDtdigit 	:= IIf(!Empty(SF2->F2_DTDIGIT),SF2->F2_DTDIGIT,SF2->F2_EMISSAO)
        IF dDtDigit >= MVUlmes()
            If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
                SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.T.,.F.))
                AtuStatus('G99_STATRA','6')
            Else
                lRet:= .F.
                Help( ,, 'Help',"ExclDoc", "Não foi possivel excluir o documento", 1, 0 )//Não foi possivel excluir o documento
            Endif     
        EndIf
    Else
    	lRet:= .F.
    	Help( ,, 'Help',"ExclDoc", "Essa nota já foi excluída ou não existe na base de dados", 1, 0 )//Essa nota já foi excluída ou não existe na base de dados
    Endif
EndIf

Return lRet