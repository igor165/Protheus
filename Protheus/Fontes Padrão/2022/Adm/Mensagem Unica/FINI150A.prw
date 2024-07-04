#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#Include 'FINI150A.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINI150A
Mensagem unica de solicitação de "Nosso Número" - OurNumberBanking

@return lRet indica se a mensagem foi processada com sucesso
@return cXmlRet Xml de retorno da funcao

@author Pedro Pereira Lima
@since 08/10/2014
@version P12 
/*/
//-------------------------------------------------------------------
Function FINI150A()
Local aIntegDef
Local lRet 		:= .T.
Local oFWEAI

Private cMsgVer	:= ""

aIntegDef := FWIntegDef( "FINI150A",,,, "FINI150A", .T. )
	
oFWEAI:= FWEAI():New()
oFWEAI:SetFuncCode( "OURNUMBERBANKING" )
oFWEAI:SetFuncDescription( "OurNumberBanking" ) 
oFWEAI:SetDocType( PROC_SYNC ) //< PROC_SYNC = Sincrono, PROC_ASYNC = Assincrono > ) // olhar a configuração do ADAPTER
oFWEAI:AddLayout( "FINI150A", cMsgVer, "FINI150A", aIntegDef[2] )
oFWEAI:SetTypeMessage( EAI_MESSAGE_BUSINESS ) // olhar a configuração do ADAPTER para ver se é Mensagem ÚNICA ou MVC
oFWEAI:SetSendChannel( EAI_CHANNEL_EAI )//< EAI_CHANNEL_ESB = ESB, EAI_CHANNEL_EAI = EAI > ) // olhar a configuração do ADAPTER para ver se é Mensagem ÚNICA ou MVC
oFWEAI:Activate()

If !( lRet := oFWEAI:Save() ) // Gera a mensagem EAI
	// NAO GRAVOU A MENSAGEM
	//Self:AtualizarS("O")
EndIf
	
Return {lRet,oFWEAI:cResult}

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integração via mensagem única

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@return lRet indica se a mensagem foi processada com sucesso
@return cXmlRet Xml de retorno da funcao

@author Pedro Pereira Lima
@version P12
@since	08/10/2014											
/*/
//-------------------------------------------------------------------
Static Function IntegDef( cXml, nType, cTypeMsg, cVersion )
Local cXmlRet	:= ''
Local cRequest	:= 'OurNumberBanking'
Local lRet		:= .T.
Local cNewXml	:= ''
Local cErroXml	:= ''
Local cWarnXml	:= ''
Local aTitulo	:= {}
Local nX		:= 0

//Recupero a versão do adapter para poder utilizar no método AddLayout
cMsgVer := cVersion

Do Case
	Case nType == TRANS_SEND
		cXmlRet :=	FWEAIBusRequest(cRequest)
		cXmlRet +=	'<BusinessContent>'
		cXmlRet +=		'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXmlRet	+=		'<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=    	'<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXmlRet	+=		'<DocumentInternalId>' + SE1->E1_FILIAL + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + '</DocumentInternalId>'		
		cXmlRet	+=		'<DueDate>' + Transform(DtoS(SE1->E1_VENCREA),"@R 9999-99-99") + '</DueDate>'
		cXmlRet	+=		'<BankingCode>' + SE1->E1_PORTADO + '</BankingCode>'
		cXmlRet	+=		'<Agency>' + SE1->E1_AGEDEP + '</Agency>'
		cXmlRet	+=		'<Account>' + SE1->E1_CONTA + '</Account>'
		cXmlRet +=		'<Contract>' + SE1->E1_CONTRAT + '</Contract>'
		cXmlRet	+=	'</BusinessContent>'
	Case nType == TRANS_RECEIVE
		Do Case
			Case cTypeMsg == EAI_MESSAGE_WHOIS
				cXmlRet := '1.000'
			Case cTypeMsg == EAI_MESSAGE_RESPONSE
				If lRet
					//Tratamento para evitar que o XML sejá manipulado com condificação UTF8
					If (cNewXml := DecodeUtf8(cXml)) <> Nil
						cXml := cNewXml
					EndIf
									
					oXml := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
					If oXml <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)					
						If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:_TOTVSMessage:_BusinessMessage:_BusinessRequest:_Operation:Text") <> "U" .And.;
							!Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:_TOTVSMessage:_BusinessMessage:_BusinessRequest:_Operation:Text)
							cRequest := oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:_TOTVSMessage:_BusinessMessage:_BusinessRequest:_Operation:Text
						EndIf
						
						If Upper(Alltrim(cRequest)) != 'OURNUMBERBANKING'
							lRet := .F.
							cXmlRet += STR0001 + " " //'O conteúdo  da tag Request é inválido ou não foi enviado.'						
						EndIf
											
						If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_DocumentInternalId:Text") <> "U" .And.;
							!Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_DocumentInternalId:Text)
							
							cDocumentIternalId := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_DocumentInternalId:Text
							
							//Alimento o array com a chave do título (de filial à tipo)
							For nX := 1 To 5
								If nX == 5
									aAdd(aTitulo,SubStr(cDocumentInternalId,1,Len(cDocumentInternalId)))
								Else
									aAdd(aTitulo,SubStr(cDocumentInternalId,1,At("|",cDocumentInternalId)-1))
									cDocumentInternalId := SubStr(cDocumentInternalId,At("|",cDocumentInternalId)+1,Len(cDocumentInternalId)) 
								EndIf							
							Next nX

						Else
							lRet := .F.
							cXmlRet := STR0002 //'A tag DocumentInternalId não foi encontrada na mensagem.'								
						EndIf
						
						If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_OurNumber:Text") <> "U" .And.;
							!Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_OurNumber:Text)
							
							cOurNumber := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_OurNumber:Text
						EndIf																		
										
						If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_BarCode:Text") <> "U" .And.;
							!Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_BarCode:Text)
							
							cBarcode := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_BarCode:Text						
						EndIf
						
						DbSelectArea('SE1')
						DbSetOrder(1)
						If DbSeek(aTitulo[1] + aTitulo[2] + aTitulo[3] + aTitulo[4] + aTitulo[5])
							If !Empty(cOurNumber)
								If Empty(SE1->E1_NUMBCO)
									RecLock('SE1',.F.)
										SE1->E1_NUMBCO := cOurNumber
										SE1->E1_CODBAR := cBarcode
									MsUnlock()
								EndIf
								
								If Type('cOurNumberBanking') != Nil
									cOurNumberBanking := cOurNumber
								EndIf
												
							Else
								lRet := .F.
								cXmlRet := STR0003 //'A tag OurNumber não foi retornada ou seu conteúdo está vazio.'
							EndIf
						Else
							lRet := .F.
							cXmlRet := STR0004 //'Não foi encontrado o título para inserção do "Nosso Número".'						
						EndIf
					Else
						lRet := .F.
						cXmlRet := STR0005 //'Erro no xml recebido.'
					Endif
				Endif
												
			Case cTypeMsg == EAI_MESSAGE_RECEIPT
				
			Case cTypeMsg == EAI_MESSAGE_BUSINESS

		EndCase
EndCase

cXmlRet := EncodeUTF8(cXmlRet)

Return { lRet, cXmlRet }  
