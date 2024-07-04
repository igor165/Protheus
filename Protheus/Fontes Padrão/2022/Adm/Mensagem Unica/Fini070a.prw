#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#Include 'FINI070A.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFini070A   บAutor  ณJandir Deodato      บ Data ณ 20/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescrio ณ M.U Mensagem unica de atualiz็ใo de financiamento          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Fini070A(                     )                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑบDesc.     ณFun็ใo para a intera็ใo com EAI                             บฑฑ
ฑฑบ          ณMensagem de atualiza็ใo de financiamento                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fini070A()
Local aIntegDef
Local lRet		:= .T.
Local oFWEAI
Local cResult := ""



aIntegDef := FWIntegDef("FINI070A",,,,"FINI070A",.T.)

If aIntegDef[2] <> "" 	
	oFWEAI := FWEAI():New()
	oFWEAI:SetFuncCode( "UPDATECONTRACTPARCEL" )
	oFWEAI:SetFuncDescription( "UpdateContractParcel" ) 
	oFWEAI:SetDocType( PROC_SYNC ) //< PROC_SYNC = Sincrono, PROC_ASYNC = Assincrono > ) // olhar a configura็ใo do ADAPTER
	oFWEAI:AddLayout( "FINI070A", aIntegDef[4], "FINI070A", aIntegDef[2] )
	oFWEAI:SetTypeMessage( EAI_MESSAGE_BUSINESS ) // olhar a configura็ใo do ADAPTER para ver se ้ Mensagem ฺNICA ou MVC
	oFWEAI:SetSendChannel( EAI_CHANNEL_EAI )//< EAI_CHANNEL_ESB = ESB, EAI_CHANNEL_EAI = EAI > ) // olhar a configura็ใo do ADAPTER para ver se ้ Mensagem ฺNICA ou MVC
	oFWEAI:SetDocVersion( FWAdapterVersion('FINI070A','UPDATECONTRACTPARCEL') )
	oFWEAI:Activate() 
		
	If (lRet := oFWEAI:Save()) // Gera a mensagem EAI
		cResult:= oFWEAI:cResult 
	Endif
	 
Endif

Return {lRet,cResult} 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINTEGDEF  บAutor  ณJandir Deodato       บ Data ณ 20/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para a intera็ใo com EAI                             บฑฑ
ฑฑบ          ณMensagem unica de pesquisa de valor presente do titulo       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function IntegDef( cXml, nType, cTypeMsg, cVersion, cTransaction)  

Local lRet			:= .T.
Local cXMLRet		:= ""
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

Do Case
	Case (nType ==TRANS_SEND )
		cXMLRet := '<BusinessRequest>'
		cXMLRet +=     '<Operation>'+cRequest+'</Operation>'
		cXMLRet += '</BusinessRequest>'
		cXMLRet += '<BusinessContent>'
		If AllTrim(cVersion) == "1.000"
			cXMLRet +='<CompanyInternalId>' + cEmpAnt + '</CompanyInternalId>'			
		ElseIf AllTrim(cVersion) > "1.000"
			cXMLRet +='<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		EndIf

		If IsInCallStack("FINA080") .or. IsInCallStack("FINA090") .or. IsInCallStack("FINA091")
			cXMLRet += '<AccountDocumentInternalId>'+F55MontInt(,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,"SE2")+'</AccountDocumentInternalId>'
		Else	
			cXMLRet += '<AccountDocumentInternalId>'+F55MontInt(,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,,,"SE1")+'</AccountDocumentInternalId>'
		Endif
		If IsInCallStack("FINA200")
			cXMLRet += '<Date>'+Transform(dToS(dBaixa),"@R 9999-99-99")+'</Date>'
		Else
			cXMLRet += '<Date>'+Transform(dToS(dDataBase),"@R 9999-99-99")+'</Date>'
		Endif
		cXMLRet	+=		'<BusinessContentType>'
		cXMLRet	+=			'<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet	+=		'</BusinessContentType>'
		cXMLRet +=		'<Date>'+Transform(dToS(dDataBase),"@R 9999-99-99")+'</Date>'
		If AllTrim(cVersion) > "1.000"
			cXMLRet	+=		'<BranchId>' + cFilAnt + '</BranchId>'
		EndIf
		cXMLRet	+=	'<Process>' + F70CancTB() + '</Process>'
		cXMLRet +=	'</BusinessContent>'

	Case ( nType == TRANS_RECEIVE )
		Do Case
			Case (cTypeMsg == EAI_MESSAGE_WHOIS )
				cXMLRet := '1.000|1.001|1.002'
			Case (cTypeMsg == EAI_MESSAGE_RESPONSE )
				If AllTrim(cVersion) > "1.000"
					//Tratamento para evitar que o XML sejแ manipulado com condifica็ใo UTF8
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
								cXMLRet += oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + Chr(10)
							Next nCount
							
							lRet := .F.					
						EndIf
						
						If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:_TOTVSMessage:_BusinessMessage:_BusinessRequest:_Operation:Text") <> "U" .And.;
							!Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:_TOTVSMessage:_BusinessMessage:_BusinessRequest:_Operation:Text) .And. lRet
							cRequest := oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:_TOTVSMessage:_BusinessMessage:_BusinessRequest:_Operation:Text
						
							If Upper(Alltrim(cRequest)) != 'UPDATECONTRACTPARCEL'
								lRet := .F.
								cXMLRet += STR0001 + " " //'O conte๚do  da tag Request ้ invแlido ou nใo foi enviado.'						
							EndIf
						EndIf

						If XmlChildEx(oXml:_TotvsMessage:_MessageInformation,'_PRODUCT') <> nil .and. XmlChildEx(oXml:_TotvsMessage:_MessageInformation:_Product,'_NAME') <> NIL
							cMarca := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
						Else
							lRet:=.F.
							cXMLRet += STR0002 + " "//'Nใo foi encontrada a tag que identifica a marca integrada.' 
						Endif
											
						If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_AccountDocumentInternalId:Text") <> "U" .And.;
							!Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_AccountDocumentInternalId:Text) .And. lRet
							
							cExternalId := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_AccountDocumentInternalId:Text
							
							aTitulo := IntTRcInt(cExternalId, cMarca)

						Else
							lRet := .F.
							cXMLRet := STR0003 //'A tag DocumentInternalId nใo foi encontrada na mensagem.'								
						EndIf
						
						If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_DiscountValue:Text") <> "U" .And.;
							!Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_DiscountValue:Text) .And. lRet
							
							cVlDesconto := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_DiscountValue:Text
						EndIf																		
										
						If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_ScholarshipValue:Text") <> "U" .And.;
							!Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_ScholarshipValue:Text) .And. lRet
							
							cVlBolsa := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem:_ScholarshipValue:Text						
						EndIf 
							
						If Len(aTitulo) > 0 .And. aTitulo[1] 
							dbSelectArea('SE1')
							SE1-> ( dbSetOrder( 1 ) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
						
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
							
								IF ExistBlock("FI70POSATU")
									ExecBlock( "FI70POSATU", .f., .f., {oXML } ) 
		    					Endif
							Else
								lRet := .F.
								cXMLRet := STR0004 //'Nใo foi encontrado o tํtulo para atualiza็ใo do valor!'						
							EndIf
						EndIf
					Else
						lRet := .F.
						cXMLRet := STR0005 //'Erro no xml recebido.'
					Endif				
				EndIf
			Case (cTypeMsg == EAI_MESSAGE_RECEIPT )
			
			Case ( cTypeMsg == EAI_MESSAGE_BUSINESS )
		EndCase
EndCase

Return { lRet, cXMLRet, "UPDATECONTRACTPARCEL" , cVersion }
