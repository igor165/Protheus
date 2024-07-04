#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#Include 'FINI087A.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINI087A ºAutor  ³Luis E. Enriquez Mata º Data ³ 20/02/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³ Mensaje único de actalización de financiación.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINI087A()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³Integración con EAI, mensaje de actualización de financiero º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINI087A()
	Local aIntegDef
	Local lRet		:= .T.
	Local oFWEAI
	
	Private cMsgVer	:= ""
	
	aIntegDef := FWIntegDef("FINI087A",,,,"FINI087A",.T.)
		
	oFWEAI := FWEAI():New()
	oFWEAI:SetFuncCode( "UPDATECONTRACTPARCEL" )
	oFWEAI:SetFuncDescription( "UpdateContractParcel" ) 
	oFWEAI:SetDocType( PROC_SYNC ) //< PROC_SYNC = Sincrono, PROC_ASYNC = Assincrono > ) // olhar a configuração do ADAPTER
	oFWEAI:AddLayout( "FINI087A", cMsgVer, "FINI087A", aIntegDef[2] )
	oFWEAI:SetTypeMessage( EAI_MESSAGE_BUSINESS ) // olhar a configuração do ADAPTER para ver se é Mensagem ÚNICA ou MVC
	oFWEAI:SetSendChannel( EAI_CHANNEL_EAI )//< EAI_CHANNEL_ESB = ESB, EAI_CHANNEL_EAI = EAI > ) // olhar a configuração do ADAPTER para ver se é Mensagem ÚNICA ou MVC
	oFWEAI:Activate()
		
	lRet := oFWEAI:Save() // Genera el mensaje EAI
Return {lRet,oFWEAI:cResult}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IntegDef   ³ Autor ³ Luis Enriquez         ³ Data ³ 20.02.18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mensaje único de busqueda de valor presente del titulo.      ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINI087A                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IntegDef( cXml, nType, cTypeMsg, cVersion)  
	Local lRet			:= .T.
	Local cxmlRet		:= ""
	Local cRequest		:= "UpdateContractParcel"
	Local cNewXml		:= ""
	Local cExternalId	:= ""
	Local cVlBolsa		:= ""
	Local cVlDesconto	:= ""
	Local nCount		:= 0
	Local cErroXml		:= ''
	Local cWarnXml		:= ''
	Local aTitulo		:= {}
	Local cMarca		:= ""
	Local cFil			:= ""
	Local cPrefixo		:= ""
	Local cNumero		:= ""
	Local cParcela		:= ""
	Local cTipo			:= ""
	Local cMsgVersion	:= AllTrim(MsgUVer('UPDATECONTRACTPARCEL','FINI087A'))
	//Recupero a versão do adapter para poder utilizar no método AddLayout
	cMsgVer := cVersion
	
	Do Case
		Case (nType ==TRANS_SEND )
			cXMLRet := '<BusinessRequest>'
			cXMLRet +=     '<Operation>'+cRequest+'</Operation>'
			cXMLRet += '</BusinessRequest>'
			cXmlRet += '<BusinessContent>'
			If cMsgVersion == "1.000"
				cXMLRet +='<CompanyInternalId>' + cEmpAnt + '</CompanyInternalId>'			
			ElseIf cMsgVersion == "1.001" .OR. cMsgVersion == "1.002" 
				cXMLRet +='<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
			EndIf
	
			If IsInCallStack("FINA080") .or. IsInCallStack("FINA090") .or. IsInCallStack("FINA091")
				cXmlRet += '<AccountDocumentInternalId>'+F55MontInt(,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,"SE2")+'</AccountDocumentInternalId>'
			Else	
				cXmlRet += '<AccountDocumentInternalId>'+F55MontInt(,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,,,"SE1")+'</AccountDocumentInternalId>'
			Endif
			If IsInCallStack("FINA200")
				cXmlRet += '<Date>'+Transform(dToS(dBaixa),"@R 9999-99-99")+'</Date>'
			Else
				cXmlRet += '<Date>'+Transform(dToS(dDataBase),"@R 9999-99-99")+'</Date>'
			Endif
			cXmlRet	+=		'<BusinessContentType>'
			cXmlRet	+=			'<BranchId>' + cFilAnt + '</BranchId>'
			cXmlRet	+=		'</BusinessContentType>'
			cXmlRet +=		'<Date>'+Transform(dToS(dDataBase),"@R 9999-99-99")+'</Date>'
			If cMsgVersion == "1.001" .OR. cMsgVersion == "1.002" 
				cXmlRet	+=		'<BranchId>' + cFilAnt + '</BranchId>'
			EndIf
			cXmlRet	+=	'<Process>' + F70CancTB() + '</Process>'
			cXmlRet +=	'</BusinessContent>'
	
		Case ( nType == TRANS_RECEIVE )
			Do Case
				Case (cTypeMsg == EAI_MESSAGE_WHOIS )
					cXmlRet := '1.000|1.001|1.002'
				Case (cTypeMsg == EAI_MESSAGE_RESPONSE )
					If cMsgVersion == "1.001" .OR. cMsgVersion == "1.002" 
						//Tratamento para evitar que o XML sejá manipulado com condificação UTF8
						If (cNewXml := DecodeUtf8(cXml)) <> Nil
							cXml := cNewXml
						EndIf
										
						oXml := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
						If oXml <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)					
							If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status,'TEXT') != Nil .And.;
								XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status,'TEXT') == "ERROR"
								If ValType(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) != "A"
									// Transforma em array
									XmlNode2Arr(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
								EndIf		
								
								For nCount := 1 To Len(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
									cXmlRet += oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + Chr(10)
								Next nCount
								
								lRet := .F.					
							EndIf
							
							If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:_TOTVSMessage:_BusinessMessage:_BusinessRequest:_Operation:Text") <> "U" .And.;
								!Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:_TOTVSMessage:_BusinessMessage:_BusinessRequest:_Operation:Text) .And. lRet
								cRequest := oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:_TOTVSMessage:_BusinessMessage:_BusinessRequest:_Operation:Text
							
								If Upper(Alltrim(cRequest)) != 'UPDATECONTRACTPARCEL'
									lRet := .F.
									cXmlRet += STR0001 + " " //'El contenido de la etiqueta Request es inválido o no se envió.'						
								EndIf
							EndIf
	
							If XmlChildEx(oXml:_TotvsMessage:_MessageInformation,'_PRODUCT') <> nil .and. XmlChildEx(oXml:_TotvsMessage:_MessageInformation:_Product,'_NAME') <> NIL
								cMarca := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
							Else
								lRet:=.F.
								cXmlRet += STR0002 + " " //'No se encontró la etiqueta que identifica la marca integrada.' 
							Endif
												
							If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_AccountDocumentInternalId:Text") <> "U" .And.;
								!Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_AccountDocumentInternalId:Text) .And. lRet
								
								cExternalId := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_AccountDocumentInternalId:Text
								
								aTitulo := IntTRcInt(cExternalId, cMarca)
	
							Else
								lRet := .F.
								cXmlRet := STR0003 //'La etiqueta AccountDocumentInternalId no se encontró en el mensaje.'								
							EndIf
							
							If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_DiscountValue:Text") <> "U" .And.;
								!Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_DiscountValue:Text) .And. lRet
								
								cVlDesconto := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_DiscountValue:Text
							EndIf																		
											
							If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_ScholarshipValue:Text") <> "U" .And.;
								!Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_ScholarshipValue:Text) .And. lRet
								
								cVlBolsa := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_ScholarshipValue:Text						
							EndIf
							
							DbSelectArea('SE1')
							DbSetOrder(1)
							If aTitulo[1] 
								cFil := PadR(aTitulo[2][2],TamSX3("E1_FILIAL")[1])
								cPrefixo := PadR(aTitulo[2][3],TamSX3("E1_PREFIXO")[1])
								cNumero := PadR(aTitulo[2][4],TamSX3("E1_NUM")[1])
								cParcela := PadR(aTitulo[2][5],TamSX3("E1_PARCELA")[1])
								cTipo := PadR(aTitulo[2][6],TamSX3("E1_TIPO")[1])
								If DbSeek(cFil + cPrefixo + cNumero + cParcela + cTipo)
									RecLock('SE1',.F.)
										SE1->E1_VLBOLSA := Val(StrTran(cVlBolsa,",","."))
										SE1->E1_DESCONT := Val(StrTran(cVlDesconto,",","."))
									MsUnlock()
								
									If ExistBlock("FI70POSATU")
										ExecBlock( "FI70POSATU", .f., .f., {oXML } ) 
			    					EndIf
								Else
									lRet := .F.
									cXmlRet := STR0004 //'No se encontró el título para actualización del valor.'						
								EndIf
							EndIf
						Else
							lRet := .F.
							cXmlRet := STR0005 //'Error en el XML recibido.'
						EndIf				
					EndIf
				Case (cTypeMsg == EAI_MESSAGE_RECEIPT )
				
				Case ( cTypeMsg == EAI_MESSAGE_BUSINESS )
			EndCase
	EndCase
Return { lRet, cXmlRet }