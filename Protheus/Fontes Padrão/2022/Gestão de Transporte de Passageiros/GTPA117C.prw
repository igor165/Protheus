#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA117C.CH"

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPA117C()

@type Function
@author flavio.martins
@since 18/09/2020
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Function GTPA117C(nOpc)
Local lRet          := .T.
Local oWs
Local cIdEnt        := ""
Local cError        := ""
Local cXml          := ""
Local cChvBpe       := ""
Local cNumPro       := ""
Local nQtdBag       := ""
Local nVlrTax       := ""
Local cVersaoBpe    := GTPGetRules('VERSAOBPE')
Local cVerLayBpe    := GTPGetRules('VERLAYBPE')
Local cVerLayEve    := GTPGetRules('VERLAYEVEN')
Local nAmbiente     := GTPGetRules('AMBENVBPE')

If VldEnvio()

    If (isConnTSS(@cError))

        cIdEnt := RetIdEnti(.F.)

        dbSelectArea('GIC')
        GIC->(dbSetOrder(1))
        If G57->(FieldPos('G57_CODGIC')) > 0
            If GIC->(dbSeek(xFilial('GIC')+G57->G57_CODGIC))
                cChvBpe := GIC->GIC_CHVBPE
                cNumPro := GIC->GIC_NUMPRO
            Endif
        Endif
        If nOpc == 1

            If !Empty(cIdEnt)
                oWS :=  WsSpedCfgNFe():New()
                oWS:cUSERTOKEN      := "TOTVS"
                oWS:cID_ENT         := cIdEnt
                oWS:nAMBIENTEBPE    := nAmbiente
                oWS:cVERSAOBPE      := cVersaoBpe
                oWS:cVERBPELAYOUT   := cVerLayBpe
                oWS:cVERBPELAYEVEN  := cVerLayEve
                oWS:cHORAVERAOBPE   := "0"
                oWS:cHORARIOBPE     := "0"

                lRet := oWS:CfgBPe()
            Endif

            If lRet

                If G57->(FieldPos('G57_QTDBAG')) > 0
                    nQtdBag := G57->G57_QTDBAG
                Else
                    nQtdBag := 1
                Endif

                nVlrTax := G57->G57_VALOR

                cXml := RetXmlBag(nAmbiente, @cChvBpe, @cNumPro, nQtdBag, nVlrTax)

                lRet := EnviaEvento(cIdEnt, cXml, @cError)

                If lRet 
                    ConsultaEvento(cIdEnt, cChvBpe)
                Else
                    Aviso(STR0001, cError, {'OK'}, 2) // "Erro no Envio do Evento"
                Endif

            Endif

        ElseIf nOpc == 2
            ConsultaEvento(cIdEnt, cChvBpe)
        Endif

    Else
        If !isBlind()
            Help( ,, STR0002, STR0003, , 1, 0) // "Atenção"  "Falha de comunicação com TSS. Realize a configuração."
        EndIf
    Endif

Endif    

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} VldEnvio()

@type Function
@author flavio.martins
@since 18/09/2020
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function VldEnvio()
Local lRet       := .T.
Local isBlind    := isBlind()
Local cTpDocBag  := GTPGetRules('TPDOCEXBAG')
Local cVersaoBpe := GTPGetRules('VERSAOBPE')
Local cVerLayBpe := GTPGetRules('VERLAYBPE')
Local cVerLayEve := GTPGetRules('VERLAYEVEN')
Local nAmbiente  := GTPGetRules('AMBENVBPE')

If G57->(FieldPos('G57_STAENV')) == 0
    lRet := .F.
    If !isBlind
        Help( ,, "Help", STR0018, STR0019, 1, 0) //"Dicionário desatualizado" //"Atualize o dicionário para utilizar esta rotina"
    EndIf
Endif

If lRet .And. G57->(FieldPos('G57_STAENV')) > 0 .And. G57->G57_STAENV == '2'
    lRet := .F.
    If !isBlind
        Help( ,, "Help", STR0014, , 1, 0) // "Evento já transmitido para este registro"
    EndIf
Endif

If lRet .And. nAmbiente == 0
    lRet := .F.
    If !isBlind
        Help( ,, "Help", STR0020, , 1, 0) // "Configure o parâmetro AMBENVBPE para definir o ambiente a ser utilizado: 1-Produção ou 2-Homologação"
    EndIf
Endif

If lRet .And. (Empty(AllTrim(cVersaoBpe)) .Or. Empty(AllTrim(cVerLayBpe)) .Or. Empty(AllTrim(cVerLayEve)))
    lRet := .F.
    If !isBlind
        Help( ,, "Help", STR0004, , 1, 0) // "Para envio do evento de excesso de bagagem é necessário que os parâmetros VERSAOBPE, VERLAYBPE, AMBENVBPE e VERLAYEVEN estejam preenchidos."
    EndIf
Endif

If lRet .And. cTpDocBag != G57->G57_TIPO
	lRet := .F.
    If !isBlind
        Help( ,, "Help", STR0005, , 1, 0) // "Operação inválida para este tipo de taxa"
    EndIf
Endif

If lRet 
    If G57->(FieldPos('G57_CODGIC')) > 0
        If Empty(G57->G57_CODGIC)
            lRet := .F.
            If !isBlind
                Help( ,, "Help", STR0006, STR0007, 1, 0) // "Taxa de Excesso de Bagagem sem vínculo com um BP-e" "Vincule a taxa com o BPe antes de enviar o evento"
            EndIf
        Endif
    Endif
Endif

If lRet
    dbSelectArea('GIC')
    GIC->(dbSetOrder(1))
    If G57->(FieldPos('G57_CODGIC')) > 0
        If GIC->(dbSeek(xFilial('GIC')+G57->G57_CODGIC))
            If Empty(GIC->GIC_CHVBPE)
                lRet := .F.
                If !isBlind
                    Help( ,, "Help", STR0008 , ,1, 0) // "Bilhete vinculado não possui chave do BPe"
                EndIf
            ElseIf Empty(GIC->GIC_NUMPRO)
                lRet := .F.
                If !isBlind
                    Help( ,, "Help", STR0009, , 1, 0) // "Bilhete vinculado não possui protocolo do BPe"
                EndIf
            Endif
        Else
            lRet := .F.
            If !isBlind
                Help( ,, "Help", STR0010, , 1, 0) // "Bilhete vinculado a taxa não encontrado"
            EndIf
        Endif
    Endif

Endif
Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} RetXmlBag(nAmbiente, cChvBpe, cNumPro, nQtdBag, nVlrTax)

@type Function
@author flavio.martins
@since 18/09/2020
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function RetXmlBag(nAmbiente, cChvBpe, cNumPro, nQtdBag, nVlrTax)
Local cXml          := ""
Local cTipoEvento   := "110117"

cXml +='<envEvento>'
cXml +='<eventos>'
cXml +='<detEvento>'
cXml +='<tpEvento>' + cTipoEvento + '</tpEvento>'

cXml +='<chnfe>' + cChvBpe + '</chnfe>'
cXml +='<ambiente>' + Str(nAmbiente) + '</ambiente>'      	
cXml +='<nProt>' + cNumPro + '</nProt>'      	
cXml +='<qBagagem>' + Str(nQtdBag) + '</qBagagem>'      
cXml +='<vTotBag>' + AllTrim(Str(nVlrTax)) + '</vTotBag>'   

cXml +='</detEvento>'
cXml +='</eventos>'
cXml +='</envEvento>'

Return cXml

//------------------------------------------------------------------------------
/* /{Protheus.doc} EnviaEvento(cEntidade, cXml, cError)

@type Function
@author flavio.martins
@since 18/09/2020
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function EnviaEvento(cEntidade, cXml, cError)
Local oWS
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
Local lRet      := .F.
Local nEventos  := 0
Local aIdEvento := {}
    
oWs:= WsNFeSBra():New()
oWs:cUserToken	:= "TOTVS"
oWs:cID_ENT		:= cEntidade
oWs:cXML_LOTE	:= cXml
oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"

    If( oWS:remessaEvento() )
        
        For nEventos := 1 To len(oWS:oWSREMESSAEVENTORESULT:cString)
            aadd(aIdEvento, oWS:oWSREMESSAEVENTORESULT:cString[nEventos])
        Next    
        
        lRet := !Empty(aIdEvento)

    Else
        cError := iif(empty( getWscError(3)), getWscError(1), getWscError(3))
    Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} ConsultaEvento(cEntidade, cChvBpe)

@type Function
@author flavio.martins
@since 18/09/2020
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function ConsultaEvento(cEntidade, cChvBpe)
Local oWS        := Nil
Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
Local nTime      := GTPGetRules("RETSTAEVEN")

Local cStatEven  := ''
Local cMotEven   := ''
Local nProtocolo := '' 
Local cAmbiente  := ''   
Local cError     := ''
Local cMsgRet    := ''

oWS             := wsNFeSBra():new()
oWS:_URL        := AllTrim(cURL) + "/NFeSBRA.apw"
oWS:cUserToken  := "TOTVS"
oWS:cID_ENT     := cEntidade
oWS:cEvento     := "110117"
oWS:cChvInicial := cChvBpe
oWS:cChvFinal   := cChvBpe

Sleep(nTime)

If(oWS:nfeMonitorLoteEvento())

    nLote := Len(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO)

    If (nLote > 0)
        cStatEven   := Str(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nCStatEven, 3)
        cMotEven    := AllTrim(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:cCMotEven)
        cMensagem   := AllTrim(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:cMensagem)
        cAmbiente   := Iif(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nAmbiente == 1, STR0015, STR0016) //'1-Produção', '2-Homologação'
        nProtocolo  := oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nProtocolo

        If cStatEven == '0'

            cMsgRet := STR0011 // 'Evento recebido e aguardando envio pelo TSS'

            Reclock('G57', .F.)
                G57->G57_STAENV := '1'
            G57->(MsUnLock())
        
            Aviso(STR0012, cMsgRet, {'OK'}, 2)	 // "Status do Envio"
        
        ElseIf nProtocolo > 0
			cMsgRet := 'Mensagem: ' + cMensagem + CRLF
			cMsgRet += 'Motivo: ' + cMotEven + CRLF
            cMsgRet += 'Ambiente: ' + cAmbiente + CRLF
            cMsgRet += 'Protocolo: ' + AllTrim(Str(nProtocolo))

            Reclock('G57', .F.)
                G57->G57_STAENV := '2'
                G57->G57_PROENV := Str(nProtocolo)
            G57->(MsUnLock())

        Else
			cMsgRet := 'Mensagem: ' + cMensagem + CRLF
			cMsgRet += 'Motivo: ' + cMotEven + CRLF
            cMsgRet += 'Ambiente: ' + cAmbiente + CRLF

            Reclock('G57', .F.)
                G57->G57_STAENV := '3'
            G57->(MsUnLock())

        Endif

        Aviso(STR0012, cMsgRet, {'OK'}, 2) // "Status do Envio"	

    Else
       /// cError := STR0068 //"Documento não possui evento."
    Endif        
Else
    cError := Iif( empty( getWscError(3)), getWscError(1), getWscError(3))
    
    Aviso(STR0013, cError, {'OK'}, 2)	// "Erro"
    
Endif
    
Return 
