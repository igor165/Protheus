#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSIB30ABP  ³ Autor ³ TIAGO DOS SANTOS   ³ Data ³ 23-09-2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ INTEGRACAO EAI GERA TITULO PAGAR - CONTROLE DE DIARIAS       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSIB30ABP()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMSIB30ABP(cXML,nType,cMsgType,cVersion)
Local aResult     := {}
Local cRotina     := ""

Private  cEntityName  := "TRANSPORTDOCUMENTS"

Default  cVersion     := "1.000"

//-- Trata o Envio/Recebimento do XML
If nType == TRANS_SEND
      aResult := TMIABPSND()
      
ElseIf nType == TRANS_RECEIVE
      aResult := TMIABPREC(cXML,cMsgType)
      
EndIf

//- Adiciona o nome da Transação da mensagem no cadastro do Adapter EAI
//- Gatilha o campo XX4_MODEL
AAdd(aResult,cEntityName)

Return aResult

/*
====================================================================================
/{Protheus.doc} TMIABPSND
//TODO Trata a montagem do XML de Envio
@author tiago.dsantos
@since 20/09/2016
@version 1.000
@type function
/===================================================================================
*/
Static Function TMIABPSND()
Local lRet        := .T.
Local cXMLRet     := ""
Local cDATATU     := Transform(DtoS(Date()),"@R 9999-99-99") + "T" + Time()
Local cMoeda      := "1"
Local cMoedaDesc  := ""
Local cMoedaSimb  := "$"
Local cDocumento  := ""
Local cTipoDocto  := ""
Local cSubTipDoc  := ""
Local cNomeFor40  := ""
Local cNomeFor20  := ""
Local dDocEmiss   := Date()
Local dDocTrans   := Date()
Local cFilDeb     := cFilAnt
Local cFilDoc     := ""
Local cDocto      := ""
Local cDocSer     := ""
Local nValDocto   := 0
Local nValPDG     := 0
Local nValAdto    := 0
Local cFilOri     := ""
Local cNumVgm     := ""
Local cInternalId := ""
Local bIsPreview  := .F.
Local cEvent      := "upsert"

      cInternalId := getIntlId()
      cDocumento  := oDTClass:NUMERO_VIAGEM
      cTipoDocto  := "CUSTOSTRANSPORTE"
      cSubTipDoc  := "DIARIAS"
      cCodCli     := oDTClass:CODIGO_CLIENTE
      cLojCli     := oDTClass:LOJA_CLIENTE
            
      SA2->(dbSetOrder(1))
      SA2->(MsSeek(xFilial("SA2")+cCodCli+cLojCli))
      cNomeFor    := _noTags(SA2->A2_NOME ) //oDTClass:DESCRICAO_CLIENTE
      cCNPJCPF    := AllTrim(SA2->A2_CGC  )
      cInscrEst   := AllTrim(SA2->A2_INSCR)
      
      cMoeda      := "01"
      cMoedaDesc  := "REAL"
      cMoedaSimb  := "$"
      dDocEmiss   := oDTClass:DATA_EMISSAO
      nValDocto   := oDTClass:VALOR_DOCUMENTO

      cFilDoc     := ""
      cDocto      := ""
      cDocSer     := ""
      
      
      cXMLRet := "<BusinessEvent>"
      cXMLRet +=     "<Entity>" + cEntityName + "</Entity>"
	  cXMLRet +=     "<Event>" + cEvent + "</Event>"
	  cXMLRet +=     "<Identification>"
	  cXMLRet +=          "<key name='InternalId'>" + cInternalId + "</key>"
	  cXMLRet +=     "</Identification>"
	  cXMLRet += "</BusinessEvent>"
	  

      cXMLRet += "<BusinessContent>"
      
      cXMLRet +=       "<CompanyId>"          + cEmpAnt     + "</CompanyId>"
      cXMLRet +=       "<BranchId>"           + cFilAnt     + "</BranchId>"
      cXMLRet +=       "<CompanyInternalId>"  + cInternalId + "<CompanyInternalId>"
      cXMLRet +=       "<DocumentId>"         + cDocumento  + "</DocumentId>"
      cXMLRet +=       "<DocumentType>"       + cTipoDocto  + "</DocumentType>"
      cXMLRet +=       "<DocumentSubType>"    + cSubTipDoc  + "</DocumentSubType>"
      cXMLRet +=       "<CustomerCode>"       + cCodCli     + "</CustomerCode>"
      cXMLRet +=       "<CustomerUnit>"       + cLojCli     + "</CustomerUnit>"
      cXMLRet +=       "<CustomerDescription>"+ cNomeFor    + "</CustomerDescription>"
      
      cXMLRet +=       "<GovernmentalInformation>"
      cXMLRet +=             "<Id name='CNPJ' expiresOn='' issueOn='" + cDATATU + "' scope=''>" + cCNPJCPF + "</Id>"
      cXMLRet +=             "<Id name='INSCRICAO_ESTADUAL' expiresOn='' issueOn='" + cDATATU + "' scope=''>" + cInscrEst + "</Id>"
      cXMLRet +=       "</GovernmentalInformation>"
      
      cXMLRet +=       "<LocalCurrency>"
      cXMLRet +=           "<Code>"        + cMoeda     + "</Code>"
      cXMLRet +=           "<Description>" + cMoedaDesc + "</Description>"
      cXMLRet +=           "<Simbol>"      + cMoedaSimb + "</Simbol>"
      cXMLRet +=       "</LocalCurrency>"
      
      cXMLRet +=       "<Preview>"         + Iif(bIsPreview,"true","false") + "</Preview>"
      cXMLRet +=       "<IssueDate>"       + DtoC(dDocEmiss) + "</IssueDate>"
      cXMLRet +=       "<TransactionDate>" + DtoC(dDocTrans) + "</TransactionDate> "
      cXMLRet +=       "<DebitBranchCode>" + cFilDeb         + "</DebitBranchCode>"

      cXMLRet +=       "<DocumentValues>"
      cXMLRet +=            "<Value>"         + Transform(nValDocto,"@R 99,999,999,999.99") + "</Value>"
      cXMLRet +=            "<TollValue>"     + Transform(nValPdg  ,"@R 99,999,999,999.99") + "</TollValue>"
      cXMLRet +=            "<AdvancesValue>" + Transform(nValAdto ,"@R 99,999,999,999.99") + "</AdvancesValue>"
      cXMLRet +=       "</DocumentValues>"

      //| Monta a lista de Documentos por Viagem
      cXMLRet +=        "<ListOfDocumentsPerTrip>"
      If cTipoDocto == "VIAGEM"
                cXMLRet +=            "<Document>"
                cXMLRet +=                  "<BranchId>" + cFilDoc + "</BranchId>"
                cXMLRet +=                  "<Number>"   + cDocto  + "</Number>"
                cXMLRet +=                  "<Serial>"   + cDocSer + "</Serial>"
                cXMLRet +=            "</Document>"
      EndIf
      cXMLRet +=        "</ListOfDocumentsPerTrip>"

      //| Monta a lista de Documentos por Contrato            
      cXMLRet +=        "<ListOfTripsPerContract>"
      If cTipoDocto == "CONTRATOCARRETEIRO"
                cXMLRet +=            "<Trip>"
                cXMLRet +=                  "<BranchId>" + cFilOri + "</BranchId>"
                cXMLRet +=                  "<Code>"     + cNumVGM + "</Code>"
                cXMLRet +=            "</Trip>"
      EndIf
      cXMLRet +=        "</ListOfTripsPerContract>

      cXMLRet += "</BusinessContent>"

Return {lRet,cXMLRet}


/*
====================================================================================
/{Protheus.doc} TMIABPREC
//TODO Trata o XML Recebido pelo Adapter
@author tiago.dsantos
@since 20/09/2016
@version 1.000
@param cXML, characters, 'XML Recebido do Adapter Externo'
@param cMsgType, characters, Tipo de Mensagem onde que: 
@type function
/===================================================================================
*/
Static Function TMIABPREC(cXML,cTypeMessage)
Local lRet    := .T.
Local cXMLRet := ""

      //- Recebimento da Mensagem de Negócio
      If     cTypeMessage == EAI_MESSAGE_BUSINESS
      
      //- Recebimento da Mensagem de Retorno
      ElseIf cTypeMessage == EAI_MESSAGE_RECEIVE
      
      //- Recebimento da Mensagem de recepção
      ElseIf cTypeMessage == EAI_MESSAGE_RECEIPT
      
      //- Retorna a versao atual da rotina, caso haja a necessidade de mudar a versao
      //- o retorno 'cXMLRET deverá constar todas as versoes separadas por '|' e tem
      //- que estar no formato Versao.Release(3digitos)
      //- exemplo: cXMLRET := "1.000|1.001|2.000"  
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
             cXMLRET := "1.000"
             
      EndIf
      
Return {lRet,cXMLRet}

/*/{Protheus.doc} getIntlId
//TODO Recupera a identificação interna da mensagem trafegada.
@author tiago.dsantos
@since 15/09/2016
@version 1.001

@type function
/*/
Static Function getIntlId()
Local cResult := ""

      cResult := ""
      
Return cResult
