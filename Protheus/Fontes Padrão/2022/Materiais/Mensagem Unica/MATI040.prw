#include "MATI040.CH"  
#Include "PROTHEUS.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE "FWADAPTEREAI.CH"
 
Static __cVerSup := "1.000|1.001|2.000|2.001"   

//----------------------------------------------------------------	-----------------------------------------------
/*/{Protheus.doc} MATI040

Rotina de processamento para integração da Mensagem Única do vendedor

@sample	MATI040( cXml, nType, cTypeMsg, cVersionRec ) 

@param	 	cXml 		- Xml da mensagem recebida
			cType 		- Tipo de operação que será processada
			cTypeMsg	- Tipo da Mensagem recebida
			cVerReceive	- Versão da Mensagem
 
@return	 Array ->  lRet retorno lógico
						cXml estrutura Xml da Mensagem

@author	Anderson Silva
@since		13/11/2015
@version 	12.1.4

/*/
//---------------------------------------------------------------------------------------------------------------
Function MATI040( cXml, nType, cTypeMsg, cVerReceive )

Local aArea 		:= GetArea()			
Local aAreaXX4	:= XX4->(GetArea())
Local aAreaSA3	:= SA3->(GetArea())	  
Local aRetMsg 	:= {}

If ( nType == TRANS_RECEIVE .And. cTypeMsg == EAI_MESSAGE_WHOIS )
	aRetMsg := {.T., __cVerSup, "SELLER" } 
ElseIf ( cTypeMsg <> EAI_MESSAGE_WHOIS )	
	If ( AllTrim(cVerReceive) $ __cVerSup )
		If AllTrim(cVerReceive) $ "1.000|1.001"
			aRetMsg := v1000(cXml, nType, cTypeMsg, cVerReceive)
		ElseIf AllTrim(cVerReceive) $ "2.000|2.001"
			aRetMsg := v2000(cXml, nType, cTypeMsg, cVerReceive)
		EndIf
	Else
		aRetMsg := {.F., STR0005 + __cVerSup }  //"Versão da mensagem não tratada pelo Protheus, as possíveis são: "
	EndIf
EndIf

RestArea( aAreaSA3 )
RestArea( aAreaXX4 )
RestArea( aArea )

Return( aRetMsg ) 

//-------------------------------------------------------------------
/*{Protheus.doc} v1000
Programa de interpretacao da Mensagem Unica de Vendedor

@since 	13/11/2015
@version 	P12.1.7
@author	Anderson Silva
@param		cXML - Variavel com conteudo xml para envio/recebimento.
@param		nTypeTrans - Tipo de transacao. (Envio/Recebimento)
@param		cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc)
@return	aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno
			aRet[1] - (boolean) Indica o resultado da execução da função
			aRet[2] - (caracter) Mensagem Xml para envio
*/
//-------------------------------------------------------------------
Static Function v1000(cXml, nType, cTypeMsg, cVerReceive)

Local cXmlRet		:= ""					
Local cValInt		:= ""
Local cEvent		:= "upsert"	    	
Local lRet			:= .T.
Local aRetMsg		:= {}
Local cXmlErro	:= ""
Local cXmlWarn	:= ""
Local cMarca		:= ""
Local oXmlMsgRes	:= Nil
Local cErroXml	:= ""
Local cWarnXml	:= ""
Local cValExt		:= ""
Local lManut		:= .T.					
Local nOpcx		:= 0
Local aAux			:= {}
Local aDadosSA3	:= {}
Local oXmlMsgBus	:= Nil
Local lIniPad 	:= ( !Empty( GetSX3Cache( "A3_COD", "X3_RELACAO" ) ) )
Local nZ			:= 0
Local cEvento		:= ""
Local cVendActiv	:= ""

//Trata o envio de mensagens
If nType == TRANS_SEND
	
	cValInt := IntVenExt(cEmpAnt,/*cFilAnt*/,SA3->A3_COD,cVerReceive)[2]
	
	If ( !INCLUI .AND. !ALTERA )
		cEvent := "delete"
		CFGA070Mnt(  Nil, "SA3", "A3_COD",	Nil, cValInt, .T. ) // remove do de/para
	EndIf
	
	cXMLRet += '<BusinessEvent>'
	cXmlRet +=     '<Entity>SELLER</Entity>'
	cXmlRet +=     '<Event>'+ cEvent +'</Event>'
	cXmlRet +=     '<Identification>'
	cXmlRet +=         '<key name = "Code">' +  cValInt + '</key>'
	cXmlRet +=     '</Identification>'
	cXmlRet += '</BusinessEvent>'
	
	cXmlRet += '<BusinessContent>'
	cXmlRet += 		'<CompanyId>'	+ cEmpAnt 	+ '</CompanyId>'
	cXmlRet += 		'<BranchId>'	+ cFilAnt	+ '</BranchId>'
	cXmlRet += 		'<CompanyInternalId>'	+ cEmpAnt + '|' + cFilAnt	+ '</CompanyInternalId>'
	cXmlRet += 		'<InternalId>'	+ cValInt	+ '</InternalId>'
	cXmlRet += 		'<Code>'	+ AllTrim(SA3->A3_COD)	+ '</Code>'
	cXmlRet += 		'<Name>'	+ AllTrim(SA3->A3_NOME)	+ '</Name>'
	cXmlRet += 		'<ShortName>'	+ AllTrim(SA3->A3_NREDUZ)	+ '</ShortName>'
	cXMLRet +=    	'<Active>' + SA3->A3_MSBLQL + '</Active>'
	cXmlRet += 		'<Login></Login>'
	cXmlRet += 		'<SellerPassword></SellerPassword>'
	cXmlRet += 		'<SellerPhoneDDD>' +  AllTrim(SA3->A3_DDDTEL)	+ '</SellerPhoneDDD>'
	cXmlRet += 		'<SellerPhone>'    +  AllTrim(SA3->A3_TEL)   	+ '</SellerPhone>'
	cXmlRet += 		'<SellerEmail>'    +  AllTrim(SA3->A3_EMAIL)	+ '</SellerEmail>'
	cXmlRet += 		'<SellerAddress>'  +  AllTrim(SA3->A3_END)	+ '</SellerAddress>'
	cXmlRet += 		'<SellerCity>'     +  AllTrim(SA3->A3_MUN)	+ '</SellerCity>'
	cXmlRet += 		'<SellerNeighborhood>' + AllTrim(SA3->A3_BAIRRO) + '</SellerNeighborhood>'
	cXmlRet += '</BusinessContent>'
	
	aRetMsg := {lRet, cXmlRet }
	
ElseIf nType == TRANS_RECEIVE
	
	Do Case
		
		Case ( cTypeMsg == EAI_MESSAGE_RESPONSE )
			
			oXmlMsgRes := XmlParser( cXml, "_", @cXmlErro, @cXmlWarn )
			
			If oXmlMsgRes <> Nil .And. Empty( cXmlErro ) .And. Empty( cXmlWarn )
				
				cMarca := oXmlMsgRes:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				
				If XmlChildEx( oXmlMsgRes:_TotvsMessage:_ResponseMessage:_ProcessingInformation, "_STATUS" ) <> Nil .And. ;
					Upper( oXmlMsgRes:_TotvsMessage:_ResponseMessage:_ProcessingInformation:_Status:Text ) == "OK"
					
					oXmlMsgRes := XmlChildEx( oXmlMsgRes:_TotvsMessage:_ResponseMessage:_ReturnContent, "_LISTOFINTERNALID" )
					
					If oXmlMsgRes <> Nil
						
						If XmlChildEx( oXmlMsgRes, "_INTERNALID" ) <> Nil
							
							If Valtype( oXmlMsgRes:_InternalId ) <> "A"
								XmlNode2Arr( oXmlMsgRes:_InternalId, "_InternalId" )
							EndIf
							
							For nZ := 1 To Len( oXmlMsgRes:_InternalId )
								If XmlChildEx( oXmlMsgRes:_InternalId[nZ], "_NAME" ) <> Nil .And. ;
									Upper( oXmlMsgRes:_InternalId[nZ]:_Name:Text ) == "SELLER" .And. ;
									XmlChildEx( oXmlMsgRes:_InternalId[nZ], "_ORIGIN" ) <> Nil .And. ;
									XmlChildEx( oXmlMsgRes:_InternalId[nZ], "_DESTINATION" ) <> Nil
									
									CFGA070Mnt( cMarca,"SA3", "A3_COD", ;
									oXmlMsgRes:_InternalId[nZ]:_Destination:Text, ;
									oXmlMsgRes:_InternalId[nZ]:_Origin:Text )
									
									Exit
								EndIf
							Next nZ
							
						Else
							aRetMsg := {.F., STR0007 } //"Não enviado conteúdo de retorno para cadastro de de-para"
						EndIf
					EndIf
					
				Else
					
					cXmlRet :=  STR0008 + "|" //"Erro no processamento pela outra aplicação"
					
					If XmlChildEx( oXmlMsgRes:_TotvsMessage:_ResponseMessage:_ProcessingInformation, "_LISTOFMESSAGES" ) <> Nil
						
						oXmlMsgRes := oXmlMsgRes:_TotvsMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages
						
						If XmlChildEx( oXmlMsgRes, "_MESSAGE" ) <> Nil
							
							If Valtype( oXmlMsgRes:_Message ) <> "A"
								XmlNode2Arr( oXmlMsgRes:_Message, "_Message" )
							EndIf
							
							For nZ := 1 To Len( oXmlMsgRes:_Message )
								cXmlRet += Alltrim( oXmlMsgRes:_Message[nZ]:Text ) + "|"
							Next nZ
							
						Else
							lRet := .F.
							cXmlRet := STR0009//"Erro no processamento, mas sem detalhes do erro pela outra aplicação"
						EndIf
						
					EndIf
					
					aRetMsg := {.F., cXmlRet }
					
				EndIf
			Else
				aRetMsg := {.F., cXmlRet :=  + "|" + cXmlErro + "|" + cXmlWarn } // "Falha na leitura da resposta, de-para não será gravado"
			EndIf
			
			If ValType(oXmlMsgRes) == 'O'
				FreeObj(oXmlMsgRes)
				oXmlMsgRes := Nil
			EndIf
			
		//Receipt Message (Aviso de recebimento em transmissoes assincronas)
		Case ( cTypeMsg == EAI_MESSAGE_RECEIPT )	
			aRetMsg := {.T., '<Receipt>' + STR0021 + '</Receipt>' } //Mensagem recebida
		//Business Message (Mensagem de dados)
		Case ( cTypeMsg == EAI_MESSAGE_BUSINESS )
			
			SA3->(DbSetOrder(1))
			
			oXmlMsgBus := XmlParser( cXML, '_', @cErroXml, @cWarnXml)
			
			If oXmlMsgBus <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
				
				cMarca := oXmlMsgBus:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				
				oXmlMsgBus := oXmlMsgBus:_TOTVSMessage:_BusinessMessage
				
				If XmlChildEx(oXmlMsgBus, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlMsgBus:_BusinessEvent, '_EVENT' ) <> Nil
					
					
					cEvento := oXmlMsgBus:_BusinessEvent:_Event:Text
					
					cValExt := IIF( ( XmlChildEx(oXmlMsgBus:_BusinessEvent, '_IDENTIFICATION') <> Nil .And. ;
					XmlChildEx( oXmlMsgBus:_BusinessEvent:_Identification, '_KEY') <> Nil ), ;
					oXmlMsgBus:_BusinessEvent:_Identification:_Key:Text, "" )
					
					cValExt := IIF( ( Empty( cValExt ) .And. XmlChildEx( oXmlMsgBus:_BusinessContent, "_INTERNALID" ) <> Nil ), ;
					oXmlMsgBus:_BusinessContent:_InternalId:Text, ;
					cValExt )
					
					If !Empty(cValExt)
						
						cValInt := CFGA070Int( cMarca, 'SA3', 'A3_COD', cValExt )
						
						//Verifica qual a acao (Inclusao/Alteracao ou Exclusao)
						If ( Upper( oXmlMsgBus:_BusinessEvent:_Event:Text ) == "UPSERT" )
							If	Empty(cValInt)
								nOpcx := 3	//Inclusao
							Else
								nOpcx := 4	//Alteracao
							EndIf
						Else
							nOpcx := 5	//Exclusao
						EndIf
						
						// Pegando proximo numero
						If !lIniPad .AND. nOpcx == 3
							aAdd( aDadosSA3, { "A3_COD", MATI40PNum(), Nil } )
						Else
							aAux := aBIToken( cValInt, "|", .F. )
							aAdd( aDadosSA3, { "A3_FILIAL",  IIF(Len(aAux) >= 2, aAux[2], "" )  , Nil } )
							aAdd( aDadosSA3, { "A3_COD",    AllTrim(IIF(Len(aAux) >= 3, AllTrim(aAux[3]), "" ))  , Nil } )
						EndIf
						
						//Nome do vendedor
						If( XmlChildEx( oXmlMsgBus:_BusinessContent, "_NAME" ) <> Nil )
							aAdd( aDadosSA3, { "A3_NOME", oXmlMsgBus:_BusinessContent:_Name:Text, Nil } )
						EndIf
						
						//Nome reduzido do vendedor
						If( XmlChildEx( oXmlMsgBus:_BusinessContent, "_SHORTNAME" ) <> Nil )
							aAdd( aDadosSA3, { "A3_NREDUZ", oXmlMsgBus:_BusinessContent:_ShortName:Text, Nil } )
						EndIf
						
						//Verifica se o usuario passado esta cadastrado no sistema para gravar o codigo
						If( XmlChildEx( oXmlMsgBus:_BusinessContent, "_LOGIN" ) <> Nil )
							PswOrder(2)	//Ordena por nome de usuario
							PswSeek( oXmlMsgBus:_BusinessContent:_Login:Text, .T. )
							
							If ( PswID() <> "" )
								aAdd( aDadosSA3, { "A3_CODUSR", PswID(), Nil } )
							EndIf
						EndIf
						
						//DDD do vendedor
						If( XmlChildEx( oXmlMsgBus:_BusinessContent, "_SELLERPHONEDDD" ) <> Nil )
							aAdd( aDadosSA3, { "A3_DDDTEL", oXmlMsgBus:_BusinessContent:_SELLERPHONEDDD:Text, Nil } )
						EndIf
						
						//Telefone do vendedor
						If( XmlChildEx( oXmlMsgBus:_BusinessContent, "_SELLERPHONE" ) <> Nil )
							aAdd( aDadosSA3, { "A3_TEL", oXmlMsgBus:_BusinessContent:_SELLERPHONE:Text, Nil } )
						EndIf
						
						//Email do vendedor
						If( XmlChildEx( oXmlMsgBus:_BusinessContent, "_SELLEREMAIL" ) <> Nil )
							aAdd( aDadosSA3, { "A3_EMAIL", oXmlMsgBus:_BusinessContent:_SELLEREMAIL:Text, Nil } )
						EndIf
						
						//Endereco do vendedor
						If( XmlChildEx( oXmlMsgBus:_BusinessContent, "_SELLERADDRESS" ) <> Nil )
							aAdd( aDadosSA3, { "A3_END", oXmlMsgBus:_BusinessContent:_SELLERADDRESS:Text, Nil } )
						EndIf
						
						//Cidade do vendedor
						If( XmlChildEx( oXmlMsgBus:_BusinessContent, "_SELLERCITY" ) <> Nil )
							aAdd( aDadosSA3, { "A3_MUN", oXmlMsgBus:_BusinessContent:_SELLERCITY:Text, Nil } )
						EndIf
						
						//Bairro do vendedor
						If( XmlChildEx( oXmlMsgBus:_BusinessContent, "_SELLERNEIGHBORHOOD" ) <> Nil )
							aAdd( aDadosSA3, { "A3_BAIRRO", oXmlMsgBus:_BusinessContent:_SELLERNEIGHBORHOOD:Text, Nil } )
						EndIf
						
						//Ativo
			            If( XmlChildEx( oXmlMsgBus:_BusinessContent, "_ACTIVE" ) <> Nil )
			            	cVendActiv := AllTrim(oXmlMsgBus:_BusinessContent:_Active:Text)
			            	 If (cVendActiv == '0' .Or. Upper(cVendActiv) == 'FALSE') .And. (nOpcx != 5) // Nao Ativo 
								aAdd( aDadosSA3, { "A3_MSBLQL", '1', Nil } )
							 ElseIf (cVendActiv == '1' .Or. Upper(cVendActiv) == 'TRUE') .And. (nOpcx != 5) // Ativo 
								aAdd( aDadosSA3, { "A3_MSBLQL", '2', Nil } )	
							 EndIf
			            EndIf
						
						// verifica se exite a chave interna no de\para
						lManut :=  (nOpcx == 5  .OR. nOpcx == 4) .AND. !Empty( cValInt )
						
						If lManut .OR. nOpcx == 3
							aAux    := MATI40PVend(aDadosSA3, nOpcx, cValInt, cValExt, cMarca, cVerReceive )
							aRetMsg := {aAux[1],aAux[2]}
						Else
							aRetMsg	:= {.F.,STR0001} //'O registro não foi encontrado na base de destino.'
						EndIf
						
					Else
						aRetMsg	:= {.F.,STR0002} //'Chave do registro não enviada, é necessária para cadastrar o de-para'
					EndIf
					
				Else
					aRetMsg	:= {.F.,STR0003} //"Tag de operação STR0004 inexistente."//'Event'//"Tag de operação 'Event' inexistente."
				EndIf
			Else
				aRetMsg	:= {.F.,STR0006 + cErroXml + "|" + cWarnXml} //"Xml mal formatado "
			EndIf
			
			If ValType(oXmlMsgBus) == 'O'
				FreeObj(oXmlMsgBus)
				oXmlMsgBus := Nil
			EndIf
			
	EndCase
	
EndIf

Return(aRetMsg)

//-------------------------------------------------------------------
/*{Protheus.doc} v2000
Programa de interpretacao da Mensagem Unica de Vendedor

@since 	13/11/2015
@version 	P12.1.7
@author	Anderson Silva
@param		cXML - Variavel com conteudo xml para envio/recebimento.
@param		nTypeTrans - Tipo de transacao. (Envio/Recebimento)
@param		cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc)
@return	aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno
			aRet[1] - (boolean) Indica o resultado da execução da função
			aRet[2] - (caracter) Mensagem Xml para envio
*/
//-------------------------------------------------------------------
Static Function v2000(cXml, nType, cTypeMsg, cVerReceive)

Local cXmlRet		:= ""
Local cValInt		:= ""
Local cEvent		:= "upsert"
Local cBusiCont	:= ""
Local cAddress	:= ""
Local cComInfor	:= ""
Local cStatus		:= ""
Local cValExt		:= ""
Local cAliasEnt	:= "SA3"
Local cCampo		:= "A3_COD"
Local cMarca		:= ""
Local cEvento		:= ""
Local cCode		:= ""
Local lRet			:= .T.
Local lManut		:= .T.
Local lIniPad 	:= ( !Empty( GetSX3Cache( "A3_COD", "X3_RELACAO" ) ) )
Local nOpcx		:= 0
Local nX			:= 0
Local aAux			:= {} 
Local aRetMsg		:= {}
Local aDadosSA3	:= {}
Local aDadosSA2	:= {}
Local oXML			:= Nil
Local cExtFornec := ""
Local aFornec := {}
Local cFornec := ""
Local cLoja := ""
Local cComissao := "" 
Local lHotel := SuperGetMV( "MV_INTHTL", , .F. )
Local cBCSalesC := ""
Local cVendActiv	:= ""
Local cTipoVend		:= ""
Local cVendSup      := ""
Local aVendSup      := {}
Local cSupExt := ""

//Trata o envio de mensagens
If nType == TRANS_SEND
	
	cValInt := IntVenExt(cEmpAnt,/*cFilAnt*/,SA3->A3_COD,cVerReceive)[2]
	
	If ( !INCLUI .AND. !ALTERA )
		cEvent := "delete"
		CFGA070Mnt(  Nil, cAliasEnt, cCampo,	Nil, cValInt, .T. ) // remove do de/para
	EndIf

	cXMLRet += '<BusinessEvent>'
	cXmlRet +=     '<Entity>SELLER</Entity>'
	cXmlRet +=     '<Event>'+ cEvent +'</Event>'
	cXmlRet +=     '<Identification>'
	cXmlRet +=         '<key name = "Code">' +  cValInt + '</key>'
	cXmlRet +=     '</Identification>'
	cXmlRet += '</BusinessEvent>'
	
	cXmlRet += '<BusinessContent>'
	
	cXmlRet += 		'<CompanyId>'	+ cEmpAnt 	+ '</CompanyId>'
	cXmlRet += 		'<BranchId>'	+ cFilAnt	+ '</BranchId>'
	cXmlRet += 		'<CompanyInternalId>'	+ cEmpAnt + '|' + cFilAnt	+ '</CompanyInternalId>'
	cXmlRet += 		'<InternalId>'	+ cValInt	+ '</InternalId>'
	cXmlRet += 		'<Code>'	+ AllTrim(SA3->A3_COD)	+ '</Code>'
	cXmlRet += 		'<Name>'	+ AllTrim(SA3->A3_NOME)	+ '</Name>'
	cXmlRet += 		'<ShortName>'	+ AllTrim(SA3->A3_NREDUZ)	+ '</ShortName>'
	cXmlRet += 		'<PersonalIdentification>' +AllTrim(SA3->A3_CGC)+ '</PersonalIdentification>'
	cXMLRet +=    	'<Active>' + SA3->A3_MSBLQL + '</Active>'
	cXmlRet += 		'<Login>' + SA3->A3_CODUSR + '</Login>' 
	cXmlRet += 		'<SellerPassword>' + SA3->A3_SENHA + '</SellerPassword>'
	cXMLRet +=    	'<RepresentativeType>' + SA3->A3_TIPO + '</RepresentativeType>'
	cXMLRet +=    	'<SellerSupervisor>' + SA3->A3_SUPER + '</SellerSupervisor>'
	cXMLRet +=    	'<ComissionPercent>' + SA3->A3_COMIS + '</ComissionPercent>'
	cXmlRet += 		'<SalesChargeInformation>'
	If !Empty(SA3->A3_FORNECE) .And. !Empty(SA3->A3_LOJA)
		cXmlRet += 	'<CustomerVendorInternalId>' + IntForExt(,,SA3->A3_FORNECE ,SA3->A3_LOJA)[2] + '</CustomerVendorInternalId>'
		cXmlRet += 	'<SalesChargeInterface>' + SA3->A3_GERASE2 + '</SalesChargeInterface>'
	Else
		cXmlRet += 		'<CustomerVendorInternalId></CustomerVendorInternalId>'
		cXmlRet += 		'<SalesChargeInterface></SalesChargeInterface>'
	EndIF
	cXmlRet += 		'</SalesChargeInformation>'
   
	cXMLRet += 		'<Address>'
	cXMLRet += 			'<Address>' + SA3->A3_END + '</Address>'
	cXMLRet +=     		'<District>' + SA3->A3_BAIRRO + '</District>'
	cXMLRet += 			'<City>'
	cXMLRet +=        		'<Description>' + SA3->A3_MUN + '</Description>'
	cXMLRet +=				'</City>'
	cXMLRet += 			'<ZIPCode>' + SA3->A3_CEP + '</ZIPCode>
	cXMLRet +=    		'<State>'
	cXMLRet +=       		'<StateCode>' + SA3->A3_EST + '</StateCode>'
	cXMLRet +=       		'<StateInternalId>' + SA3->A3_EST + '</StateInternalId>'
	cXMLRet +=       		'<StateDescription>' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "12" + SA3->A3_EST, "X5DESCRI()" )) + '</StateDescription>'
	cXMLRet +=    		'</State>'
	cXMLRet += 		'</Address>' 
	
	cXMLRet += 		'<CommunicationInformation>'
	cXMLRet += 			'<PhoneDDD>' + SA3->A3_DDDTEL + '</PhoneDDD>'
	cXMLRet +=     		'<PhoneNumber>' + AllTrim(SA3->A3_TEL) + '</PhoneNumber>'
	cXMLREt +=				'<PhoneExtension></PhoneExtension>'
	cXMLREt +=				'<FaxDDD></FaxDDD>'
	cXMLREt +=				'<FaxNumber></FaxNumber>'
	cXMLREt +=				'<FaxNumberExtension></FaxNumberExtension>'
	cXMLREt +=				'<HomePage></HomePage>'
	cXMLRet += 			'<Email>' + SA3->A3_EMAIL + '</Email>'
	cXMLRet += 		'</CommunicationInformation>'
			
	cXmlRet += '</BusinessContent>'
	  
	aRetMsg := {lRet, cXmlRet }
	
ElseIf nType == TRANS_RECEIVE 
	
	Do Case
		
		Case ( cTypeMsg == EAI_MESSAGE_RESPONSE )
			
			oXML	:= TXMLManager():New()
			
			If oXML:Parse(cXml) .And. Empty(oXml:Error())
				
				cStatus := Upper(oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ProcessingInformation/Status'))
				
				If cStatus == "OK"  
					
					cMarca 	:= oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
					nLenList	:= oXml:xPathChildCount('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId')
					
					For nX := 1 To nLenList
						cValInt := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Origin')
						cValExt := oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId[' + cValToChar(nX) + ']/Destination')
						If !Empty(cValInt) .And. !Empty(cValExt)
							CFGA070Mnt(cMarca, cAliasEnt, cCampo, cValExt, cValInt)
						Endif
					Next nX
					
					If nLenList == 0
						aRetMsg := {.F., STR0007 } //"Não enviado conteúdo de retorno para cadastro de de-para"
					Endif
					
				Else
					
					cXmlRet :=  STR0008 + "|" //"Erro no processamento pela outra aplicação"
					nLenList := oXml:xPathChildCount('/TOTVSMessage/ResponseMessage/ProcessingInformation/ListOfMessages')
					
					For nX := 1 To nLenList
						cXmlRet += Alltrim( oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ProcessingInformation/ListOfMessages/Message[' + cValToChar(nX) + ']' ) ) + "|"
					Next nX
					
					If nLenList == 0
						lRet := .F.
						cXmlRet := STR0009//"Erro no processamento, mas sem detalhes do erro pela outra aplicação"
					EndIf
					
					aRetMsg := {.F., cXmlRet }
					
				EndIf
			Else
				aRetMsg := {.F., cXmlRet :=  + "|" + oXml:Error() } // "Falha na leitura da resposta, de-para não será gravado"
			EndIf
			
			If ValType(oXml) == "O"
				FreeObj(oXml)
				oXml := Nil 
			EndIf
			 
			//Receipt Message (Aviso de recebimento em transmissoes assincronas)
		Case ( cTypeMsg == EAI_MESSAGE_RECEIPT )
			
			aRetMsg := {.T., '<Receipt>' + STR0021 + '</Receipt>' } //Mensagem recebida
			
			//Business Message (Mensagem de dados)
		Case ( cTypeMsg == EAI_MESSAGE_BUSINESS ) 
			
			SA3->(DbSetOrder(1))
			
			oXML := TXMLManager():New()
			
			If oXML:Parse(cXml) .And. Empty(oXml:Error())
				
				cBusiCont	:= '/TOTVSMessage/BusinessMessage/BusinessContent'
				cAddress	:= '/TOTVSMessage/BusinessMessage/BusinessContent/Address'
				cComInfor	:= '/TOTVSMessage/BusinessMessage/BusinessContent/CommunicationInformation'
				cBCSalesC   := '/TOTVSMessage/BusinessMessage/BusinessContent/SalesChargeInformation'
		 				
				cCode		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Code'))
				cEvent		:= AllTrim(oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event'))
				cMarca		:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
				cValExt	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
				
				If !Empty(cValExt)
					
					cValInt := CFGA070Int( cMarca, cAliasEnt, cCampo, cValExt )
					
					//Verifica qual a acao (Inclusao/Alteracao ou Exclusao)
					If ( Upper(cEvent) == "UPSERT" )
						If	Empty(cValInt)
							nOpcx := 3	//Inclusao
						Else
							nOpcx := 4	//Alteracao
						EndIf
					Else
						nOpcx := 5	//Exclusao
					EndIf
					
					// Pegando proximo numero
					If !lIniPad .And. nOpcx == 3
						If AllTrim(cVerReceive) == "2.001"	
							If !Empty( cCode )				
								//Valida tamanho do codigo enviado
								If TamSx3("A3_COD")[1] >= Len(cCode) 
									aAdd( aDadosSA3, { "A3_COD", cCode , Nil } )
								Else
									lRet := .F.
			         				cXmlRet := STR0017 + " " + cCode + " " + STR0018 + Chr(10) //#"O Codigo do Vendedor" ##"possui tamanho maior que o permitido."
									cXmlRet += STR0019 + cValToChar( TamSx3("A3_COD")[1] ) + Chr(10) //#"Maximo:"
									cXmlRet += STR0020 + cValToChar( Len( AllTrim( cCode ) ) ) //#"Enviado:"
								EndIf   
							Else 
								aAdd( aDadosSA3, { "A3_COD", MATI40PNum(), Nil } )
							EndIf
						Else
							aAdd( aDadosSA3, { "A3_COD", MATI40PNum(), Nil } )
						EndIf																	
					Else
						aAux := aBIToken( cValInt, "|", .F. )
						aAdd( aDadosSA3, { "A3_FILIAL",  IIF(Len(aAux) >= 2, aAux[2], "" )  , Nil } )
						aAdd( aDadosSA3, { "A3_COD",    AllTrim(IIF(Len(aAux) >= 3, AllTrim(aAux[3]), "" ))  , Nil } )
					EndIf 
					
					//Nome do vendedor
					aAdd( aDadosSA3, { "A3_NOME",AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Name')), Nil } )
					
					//Nome reduzido do vendedor
					aAdd( aDadosSA3, { "A3_NREDUZ", AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ShortName')), Nil } )

					//CPF do vendedor
					aAdd( aDadosSA3, { "A3_CGC", AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/PersonalIdentification')), Nil } )
					
					
					//Declarar
					cLogin := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Login'))
															
					If !Empty(cLogin)
						//Verifica se o usuario passado esta cadastrado no sistema para gravar o codigo
						PswOrder(2)	//Ordena por nome de usuario
						PswSeek( cLogin , .T. )
						
						If ( PswId() <> "" )
							aAdd( aDadosSA3, { "A3_CODUSR", PswId(), Nil } )
						EndIf
					EndIf 
					
					//Tipo do Vendedor
					If Type(oXml:XPathGetNodeValue(cBusiCont + '/RepresentativeType')) <> "U" .And. !Empty(oXml:XPathGetNodeValue(cBusiCont + '/RepresentativeType'))
						cTipoVend := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/RepresentativeType'))
						aAdd( aDadosSA3, { "A3_TIPO", cTipoVend, Nil } )
					EndIf 
					
					//Comissão do Vendedor 
					If nComVend:= Val(oXml:XPathGetNodeValue(cBusiCont + '/ComissionPercent')) 
						If nComVend > 0
							aAdd( aDadosSA3, { "A3_COMIS", nComVend, Nil } )
						Endif
					EndIf
					
					//Supervisor do Vendedor
					cSupExt := Alltrim(oXml:XPathGetNodeValue(cBusiCont + '/SellerSupervisor'))
					If !Empty ( cSupExt )
						cVendSup :=  CFGA070INT( cMarca, 'SA3', 'A3_COD', cSupExt )				
						If !Empty ( AllTrim(cVendSup) )
							aVendSup := aBIToken( cVendSup, "|", .F. )
							aAdd( aDadosSA3, { "A3_SUPER",    AllTrim(IIF(Len(aVendSup) >= 3, AllTrim(aVendSup[3]), "" ))  , Nil } )
						EndIf						
					EndIf		
						 
					//Endereco do vendedor
					aAdd( aDadosSA3, { "A3_END", AllTrim(oXml:XPathGetNodeValue(cAddress + '/Address')), Nil } )
					
					//Bairro do vendedor
					aAdd( aDadosSA3, { "A3_BAIRRO", AllTrim(oXml:XPathGetNodeValue(cAddress + '/District')), Nil } )
					
					//Cidade do vendedor
					aAdd( aDadosSA3, { "A3_MUN", AllTrim(oXml:XPathGetNodeValue(cAddress + '/City/Description')), Nil } )
					
					//Cidade do vendedor
					aAdd( aDadosSA3, { "A3_EST", AllTrim(oXml:XPathGetNodeValue(cAddress + '/State/StateInternalId')), Nil } )
										
					If !Empty( oXml:XPathGetNodeValue(cAddress + '/ZIPCode') )
						//Cep do Vendedor
						aAdd( aDadosSA3, { "A3_CEP", AllTrim(oXml:XPathGetNodeValue(cAddress + '/ZIPCode')), Nil } )
					EndIf
					
					//Telefone do vendedor
					aAdd( aDadosSA3, { "A3_DDDTEL", AllTrim(oXml:XPathGetNodeValue(cComInfor + '/PhoneDDD')), Nil } )
					
					//Telefone do vendedor
					aAdd( aDadosSA3, { "A3_TEL", AllTrim(oXml:XPathGetNodeValue(cComInfor + '/PhoneNumber')), Nil } )
					
					//Email do vendedor
					aAdd( aDadosSA3, { "A3_EMAIL", AllTrim(oXml:XPathGetNodeValue(cComInfor + '/Email')), Nil } )
									
					//Código de fornecedor para comissão					
					cExtFornec := AllTrim( oXml:XPathGetNodeValue( cBCSalesC + '/CustomerVendorInternalId' ) )
					If ! Empty ( cExtFornec )
						aFornec := IntForInt( cExtFornec, cMarca )
											
						//Se encontrou o fornecedor no de/para
						If aFornec[1]
							cFornec := PadR( aFornec[2][3], TamSX3("A3_FORNECE")[1] )
							cLoja := PadR( aFornec[2][4], TamSX3("A3_LOJA")[1] )
												
							aAdd( aDadosSa3, { "A3_FORNECE", cFornec, Nil } )
							aAdd( aDadosSa3, { "A3_LOJA", cLoja, Nil } )
						Else
							//Se for integração com hotelaria, obriga a informar o fornecedor
							If lHotel .OR. ! Empty( cExtFornec )
								lRet := .F. 
								cXmlRet := STR0010 //"Fornecedor não encontrado no Protheus."
							Endif
						Endif		
						aSize( aFornec, 0 )
					Else
						//Se for integração com hotelaria, obriga a informar o fornecedor
						If lHotel
							lRet := .F.  
							cXmlRet	:= STR0011 //"Fornecedor não informado."
						Endif		
					EndIf
																									
					//Interface de comissão
					cComissao := AllTrim( oXml:XPathGetNodeValue( cBCSalesC + '/SalesChargeInterface' ) )
					If ! Empty ( cComissao )						
						If lHotel .AND. cComissao <> "S"
							lRet := .F. 
							cXmlRet	:= STR0012 //"Para a integração com hotelaria, a interface de comissão deve ser 'S' - Contas a Pagar."
						Else
							If ! Empty( cComissao )
								aAdd( aDadosSa3, { "A3_GERASE2", cComissao, Nil } )
							Endif
						Endif
					Else
						//Se for integração com hotelaria, obriga a informar o tipo de comissão
						If lHotel
							lRet := .F. 
							cXmlRet	:= STR0013 //"Interface de comissão não informada."
						Endif
					Endif
					
					//Ativo
					cVendActiv := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Active'))
	            	If (cVendActiv == '0' .Or. Upper(cVendActiv) == 'FALSE') .And. (nOpcx != 5) // Nao Ativo 
						aAdd( aDadosSA3, { "A3_MSBLQL", '1', Nil } )
					ElseIf (cVendActiv == '1' .Or. Upper(cVendActiv) == 'TRUE') .And. (nOpcx != 5) // Ativo 
						aAdd( aDadosSA3, { "A3_MSBLQL", '2', Nil } )	
					EndIf
					
					If lRet									
						lManut :=  (nOpcx == 5  .OR. nOpcx == 4) .AND. !Empty( cValInt )
						
						If lManut .OR. nOpcx == 3
							aAux    := MATI40PVend(aDadosSA3, nOpcx, cValInt, cValExt, cMarca, cVerReceive )
							aRetMsg := {aAux[1],aAux[2]}
						Else
							aRetMsg	:= {.F.,STR0001} //'O registro não foi encontrado na base de destino.'
						EndIf
					Else
						aRetMsg	:= {.F., cXmlRet}
					EndIf
					
				Else
					aRetMsg	:= {.F.,STR0002} //'Chave do registro não enviada, é necessária para cadastrar o de-para'
				EndIf
				
			Else
				aRetMsg	:= {.F.,STR0003} //"Tag de operação STR0004 inexistente."//'Event'//"Tag de operação 'Event' inexistente."
			EndIf
			
			If ValType(oXml) == "O"
				FreeObj(oXml)
				oXml := Nil
			EndIf
	EndCase
	
EndIf

Return(aRetMsg)

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI40PVend

Rotina para gravar dados originados de uma Business mensagem

@sample	MATI40PVend( aDadosSA3, nOpcx, cVlInt, cVlExt, cMarca )

@param	 aDadosSA3 - Array contendo os dados
nOpcx  -  Tipo de operação
cVlInt - Valor da Chave Interno
cVlExt - Valor da chave esterno
cMarca - Marca que está enviando a mensagem
cVerReceive - Versao da mensagem

@return	 Array ->  lRet  retorno lógico
cXmlRet estrutura Xml da Mensagem

@author  Victor Bitencourt
@since	  23/02/2015
@version 12.1.4

/*/
//---------------------------------------------------------------------------------------------------------------
Static Function MATI40PVend( aDadosSA3, nOpcx, cValInt, cValExt, cMarca, cVerReceive )

	Local lRet 		:= .T.
	Local cXmlRet		:= ""
	Local cLogErro	:= ""
	Local aErroAuto	:= {}
	Local aRetMsg		:= {}
	Local nCount		:= 0
	Local cAliasEnt	:= "SA3"
	Local cCampo		:= "A3_COD"
	
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile 	:= .T.
	
	Default aDadosSa3 := {}
	Default nOpcx     := 0
	Default cValInt    := ""
	Default cValExt    := ""
	Default cMarca    := ""
	
	Begin Transaction
	
	//Aciona rotina automatica para gravacao/exclusão/alteração do vendedor
	MSExecAuto( { |x, y| MATA040( x, y ) }, aDadosSA3, nOpcx )
	
	//Tratamento em caso de erro na execucao da rotina automatica
	If ( lMsErroAuto )
	
		aErroAuto := GetAutoGRLog()
		 
		For nCount := 1 To Len(aErroAuto)
			cLogErro += StrTran( StrTran( aErroAuto[nCount], "<", "" ), "-", "" ) + (" ")
			ConOut( aErroAuto[nCount] )
		Next nCount
		
		If Empty( cLogErro )
			cLogErro := STR0014 //"Ocorreu um erro não identificado na gravação do registro."
		EndIf
		
		// Monta XML de Erro de execucao da rotina automatica.
		lRet	 := .F.
		
		aRetMsg := { lRet, cLogErro }
		
		DisarmTransaction()
	 
	Else
	
		If nOpcx == 5 // Deletar
			CFGA070Mnt( cMarca  , cAliasEnt, cCampo, Nil, cValInt, .T. ) // remove do de/para
		ElseIf nOpcx == 3 // Incluir
			cValInt := IntVenExt(cEmpAnt,/*cFilAnt*/,SA3->A3_COD,cVerReceive)[2]
			CFGA070Mnt( cMarca, cAliasEnt, cCampo , cValExt, cValInt )
		EndIf
		 
		//----------------------------------------------------------------
		//  Dados ok para gravação
		cXmlRet := '<ListOfInternalId>'
		cXmlRet += 	'<InternalId>'
		cXmlRet += 		'<Name>'+ "SELLER" +'</Name>'
		cXmlRet += 		'<Origin>'+ cValExt +'</Origin>'
		cXmlRet += 		'<Destination>'+ cValInt +'</Destination>'
		cXmlRet += 	'</InternalId>'
		cXmlRet += '</ListOfInternalId>'
			
		aRetMsg := { lRet, cXmlRet }
	
	EndIf
	
	End Transaction 

Return( aRetMsg )

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI40PNum

Rotina para retornar o Proximo numero para gravação

@sample	MATI40PNum( )

@param	  	Nenhum

@return	cProxnum := Proximo numero para gravação

@author  Victor Bitencourt
@since	  23/02/2015
@version 12.1.4

/*/
//----------------------------------------------------------------------------------------------------
Static Function MATI40PNum()

Local cProxNum := ""

cProxNum := GETSX8NUM("SA3","A3_COD")
While .T.
	If SA3->( DbSeek( xFilial("SA3")+cProxNum ) )
		ConfirmSX8()
		cProxNum:=GetSXeNum("SA3","A3_COD")
	Else
		Exit
	Endif
Enddo

Return(cProxNum)

//-------------------------------------------------------------------
/*/{Protheus.doc} IntInpInt
Recebe um InternalID e retorna o código do Vendedor.

@param   	cVersao     Versão da mensagem única (Default 1.001)

@author 	Anderson Silva
@version	P12.1.7
@since		13/11/2015
@return	aResult Array contendo no primeiro parâmetro uma variável
			lógica indicando se o registro foi encontrado no de/para.
			No segundo parâmetro uma variável array com a empresa,
			filial ,Numero do Documento,Seria do Documento,Código do Fornecedor
			Código da loja do fornecedor e o Tipo da Documento
/*/
//-------------------------------------------------------------------
Function IntVenExt(cEmp,cFil,cInternalId,cVersao)
Local aResult  		:= {}

Default cEmp			:= cEmpAnt
Default cFil			:= xFilial("SA3") 
Default cInternalID	:= ""
Default cVersao		:= '1.001'

If AllTrim(cVersao) $ __cVerSup
	aAdd(aResult, .T.)
	aAdd(aResult, cEmp + '|' + RTrim(cFil) + '|' + RTrim(cInternalId) )
Else
	aAdd(aResult, .F.)
	aAdd(aResult, STR0015 + Chr(10) + STR0016 + __cVerSup) //"Versão do produto não suportada." -- "A versão suportada é: "
EndIf

Return(aResult)
