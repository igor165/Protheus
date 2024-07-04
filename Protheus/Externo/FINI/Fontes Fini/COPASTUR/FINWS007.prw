#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINWS007

Copastur - Webservice RequestServices - (Pagamentos)

@author CM Solutions - Allan Constantino Bonfim
@since  12/02/2020
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FINWS007(_cWSMetodo, _cWSRequest, _aWSRequest, _cEmpXML, _cFilXML, _lExclusiv)

	Local _aArea		:= GetArea()
	Local _cURL    		:= GETNEWPAR("ZZ_FWS7URL", "https://altjtb0065.alatur.com/RequestService.svc?wsdl")
	Local _cUserWS		:= "" //GETNEWPAR("ZZ_FWSUSER", "FINI HOMOLOG")
	Local _cPassWS		:= "" //GETNEWPAR("ZZ_FWSPASS", "homolog123")
	Local _cMsg      	:= ""
	Local _cMsgRet   	:= ""
	Local _cError    	:= ""
	Local _cDetErro		:= ""
	Local _cWarning  	:= ""
	Local _oWsdl     	:= NIL
	Local _oXmlRet		:= NIL
	Local _nX			:= 0
	Local _nY			:= 0
	Local _nCC			:= 0
	Local _aWSRet		:= ARRAY(8)
	Local _cUrlRet		:= ""
	Local _cCode		:= ""
	Local _cMessage		:= ""
	Local _oWSRet		:= NIL
	Local _aRetList		:= {}
	Local _lDActive 	:= .F.
	Local _lDAprova 	:= .F.
	Local _aAdtTmp 		:= {}
	Local _aAdiant 		:= {}
	Local _aDespTmp 	:= {}
	Local _aDesp 		:= {}
	Local _aCC 			:= {}
	Local _aCCTmp 		:= {}
	Local _cIdAlatur 	:= ""
	Local _cCpfPart 	:= ""
	Local _cEmailPart 	:= ""
	Local _cLoginPart 	:= ""
	Local _cEmpSol		:= ""
	Local _lVldApr		:= GETNEWPAR("ZZ_FWS7APR", .F.)
	Local _cPrefWs		:= "tem"//"ws:"

	Default _cWSMetodo	:= ""
	Default _cWSRequest	:= ""
	Default _aWSRequest	:= {}												
	Default _cEmpXML	:= FwCodEmp() //GetNewPar("ZZ_WSALAEP", "02")
	Default _cFilXML	:= FwCodFil() //GetNewPar("ZZ_WSALAFP", "01") 
	Default _lExclusiv	:= .F.

	
	If !Empty(_cWSMetodo) .AND. !Empty(_aWSRequest)
		If !Empty(_cEmpXML) .AND. !Empty(_cFilXML)
			If _lExclusiv
				RPCSetType(3)
				RpcSetEnv(_cEmpXML, _cFilXML,,,, GetEnvServer(), {})				
			EndIf		
		
			_aArea		:= GetArea()

			If GETNEWPAR("ZZ_WSALATU", .F.)
				DbSelectArea("FL2") //Cadastro empresas Copastur
				DbSetOrder(1) //FL2_FILIAL, FL2_BKOEMP, FL2_LICENC	
				If FL2->(DbSeek(FwxFilial("FL2")+_cEmpXML+_cFilXML))				
					_cUserWS	:= ALLTRIM(FL2->FL2_USER)
					_cPassWS	:= ALLTRIM(FL2->FL2_PSWRES)
							
					//Instância a classe, setando as parâmetrizações necessárias
					_oWsdl := TWsdlManager():New()
					
					//Se houver mensagem definida, envia a mensagem. Do contrário, mostra o erro do objeto.
					_oWsdl:lVerbose := .T.
					_oWsdl:SetAuthentication(_cUserWS, _cPassWS)
					_oWsdl:lSSLInsecure 	:= .T.
					_oWsdl:nSSLVersion		:= 0		
					_oWsdl:nTimeout			:= 120
					//_oWsdl:lRemEmptyTags := .T.
					//_oWsdl:lAlwaysSendSA := .T.
					_oWsdl:lProcResp		:= .F. //Não processa o retorno automaticamente no objeto (será tratado através do método GetSoapResponse)
					_oWsdl:lRemEmptyTags 	:= .T.
					//_oWsdl:nSOAPVersion 	:= X
					//_oWsdl:lCompressed 	:= .T.
					//_oWsdl:SetAuthentication(_cUserWS, _cPassWS)

					//Tenta fazer o Parse da URL		
					If _oWsdl:ParseURL(_cURL)		
						//Tenta definir a operação
						If _oWsdl:SetOperation(_cWSMetodo)
							/*			
							If Alltrim(_cWSMetodo) $ "get/disable"
								//_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.root">'
								_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">'

							ElseIf Alltrim(_cWSMetodo) $ "update"
								_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.root" xmlns:req="http://request.webservice.models.root">'							

							Else
								//_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.root" xmlns:web="http://webservice.models.root">'
								_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">'
							EndIf											
							*/
							_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">'

							_cMsg += '<soapenv:Header/>'
							_cMsg += '<soapenv:Body>'
							_cMsg += '<'+_cPrefWs+':'+_cWSMetodo+'>'
							_cMsg += '<'+_cPrefWs+':client_name>'+_cUserWS+'</'+_cPrefWs+':client_name>'
							_cMsg += '<'+_cPrefWs+':client_password>'+_cPassWS+'</'+_cPrefWs+':client_password>'
							
							If !Empty(_cWSRequest)
								_cMsg += '<'+_cPrefWs+':'+_cWSRequest+'>'
							EndIf										
		
							For _nX := 1 to Len(_aWSRequest)
								_cMsg += '<'+ALLTRIM(_aWSRequest[_nX][1])+'>'+_aWSRequest[_nX][2]+'</'+ALLTRIM(_aWSRequest[_nX][1])+'>'
							Next
							
							If !Empty(_cWSRequest)				
								_cMsg += '</'+_cPrefWs+':'+_cWSRequest+'>'
							EndIf
							
							_cMsg += '</'+_cPrefWs+':'+_cWSMetodo+'>'						
							_cMsg += '</soapenv:Body>'				
							_cMsg += '</soapenv:Envelope>'
																
							//Envia uma mensagem SOAP personalizada ao servidor					
							If _oWsdl:SendSoapMsg(_cMsg) 	
								//Pega a resposta do SOAP
								//Pega a resposta do SOAP
								_cMsgRet 	:= _oWsdl:GetSoapResponse()
								_cError		:= ""
								_cWarning	:= ""
													
								//Transforma a resposta em um objeto
								_oXmlRet := XmlParser(_cMsgRet, "_", @_cError, @_cWarning)
									
								If Empty(_cError)	
									_cUrlRet := "_oXmlRet:_S_ENVELOPE:_S_BODY:_"+Upper(Alltrim(_cWSMetodo))+"RESPONSE:_"+Upper(Alltrim(_cWSMetodo))+"RESULT"
									
									If Alltrim(_cWSMetodo) $ "list"
										If AttIsMemberOf(&_cUrlRet, "_A_REQUEST_LIST")
											_cUrlRet += ":_A_REQUEST_LIST"
											If !Valtype(&_cUrlRet) = "A"
												XmlNode2Arr(&_cUrlRet, "_A_REQUEST_LIST")
											EndIf
										EndIf
									EndIf

									_oWSRet := &(_cUrlRet)

									If Valtype(_oWSRet) == "A"
										For _nX := 1 to Len(_oWSRet)
											If AttIsMemberOf(_oWSRet[_nX], "_A_MESSAGE") .AND. AttIsMemberOf(_oWSRet[_nX], "_A_CODE")
												_cCode		:= _oWSRet[_nX]:_A_CODE:TEXT
												_cMessage	:= _oWSRet[_nX]:_A_MESSAGE:TEXT
												_cError		:= ""
												_cDetErro	:= ""

												If _cMessage == "OK" .OR. _cCode == "OK"
													If AttIsMemberOf(_oWSRet[_nX], "_A_REQUEST_NUMBER_ID")
														_cIdAlatur := Alltrim(_oWSRet[_nX]:_A_REQUEST_NUMBER_ID:TEXT)
													EndIf

													If AttIsMemberOf(_oWSRet[_nX], "_A_REQUEST_NUMBER")
														_cNumAlatur := Alltrim(_oWSRet[_nX]:_A_REQUEST_NUMBER:TEXT)
													EndIf

													If AttIsMemberOf(_oWSRet[_nX], "_A_REQUEST_PASSENGER_CPF")
														_cCpfPart := Alltrim(_oWSRet[_nX]:_A_REQUEST_PASSENGER_CPF:TEXT)
													EndIf
													
													If AttIsMemberOf(_oWSRet[_nX], "_A_REQUEST_PASSENGER_EMAIL")
														_cEmailPart := Alltrim(_oWSRet[_nX]:_A_REQUEST_PASSENGER_EMAIL:TEXT)
													EndIf

													If AttIsMemberOf(_oWSRet[_nX], "_A_REQUEST_PASSENGER_LOGIN")
														_cLoginPart := Alltrim(_oWSRet[_nX]:_A_REQUEST_PASSENGER_LOGIN:TEXT)
													EndIf

													If AttIsMemberOf(_oWSRet[_nX], "_A_REQUEST_COMPANY_NAME")
														_cEmpSol := Alltrim(_oWSRet[_nX]:_A_REQUEST_COMPANY_NAME:TEXT)
													EndIf

													If Upper(Alltrim(_cEmpSol)) == Upper(Alltrim(FL2->FL2_GRPEMP))
														If AttIsMemberOf(_oWSRet[_nX], "_A_REQUEST_ACCOUNTS")
															If Valtype(_oWSRet[_nX]:_A_REQUEST_ACCOUNTS)  == "A"
																For _nY := 1 to Len (_oWSRet[_nX]:_A_REQUEST_ACCOUNTS)
																	_aCCTmp := {}
																	AADD(_aCCTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ACCOUNTS[_nY]:_A_REQUEST_ACCOUNTS:_A_ACCOUNT_CODE:TEXT))
																	AADD(_aCCTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ACCOUNTS[_nY]:_A_REQUEST_ACCOUNTS:_A_ACCOUNT_PERCENTAGE:TEXT))
																	AADD(_aCCTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ACCOUNTS[_nY]:_A_REQUEST_ACCOUNTS:_A_COMPANY_NAME:TEXT))

																	AADD(_aCC, _aCCTmp)
																Next
															Else
																If Valtype(_oWSRet:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS)  == "A"
																	For _nY := 1 to Len (_oWSRet[_nX]:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS)
																		_aCCTmp := {}
																		AADD(_aCCTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS[_nY]:_A_ACCOUNT_CODE:TEXT))
																		AADD(_aCCTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS[_nY]:_A_ACCOUNT_PERCENTAGE:TEXT))
																		AADD(_aCCTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS[_nY]:_A_COMPANY_NAME:TEXT))

																		AADD(_aCC, _aCCTmp)																
																	Next
																Else
																	_aCCTmp := {}
																	AADD(_aCCTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS:_A_ACCOUNT_CODE:TEXT))
																	AADD(_aCCTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS:_A_ACCOUNT_PERCENTAGE:TEXT))
																	AADD(_aCCTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS:_A_COMPANY_NAME:TEXT))

																	AADD(_aCC, _aCCTmp)
																EndIf
															EndIf
														ENDIF

														If AttIsMemberOf(_oWSRet[_nX], "_A_REQUEST_ADVANCES")
															If Valtype(_oWSRet[_nX]:_A_REQUEST_ADVANCES)  == "A"
																For _nY := 1 to Len (_oWSRet[_nX]:_A_REQUEST_ADVANCES)
																	_aAdtTmp := {}
																	AADD(_aAdtTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE:_A_ADVANCE_NOTE:TEXT))
																	AADD(_aAdtTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE:_A_ADVANCE_INCLUDE_DATE:TEXT))
																	AADD(_aAdtTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE:_A_ADVANCE_PAYMENT_DATE:TEXT))
																	AADD(_aAdtTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE:_A_ADVANCE_CURRENCY_CODE:TEXT))
																	AADD(_aAdtTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE:_A_ADVANCE_PRICE:TEXT))
																	AADD(_aAdtTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE:_A_ADVANCE_QUANTITY:TEXT))
																
																	AADD(_aAdiant, _aAdtTmp)
																Next
															Else
																_aAdtTmp := {}
																AADD(_aAdtTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE:_A_ADVANCE_NOTE:TEXT))
																AADD(_aAdtTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE:_A_ADVANCE_INCLUDE_DATE:TEXT))
																AADD(_aAdtTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE:_A_ADVANCE_PAYMENT_DATE:TEXT))
																AADD(_aAdtTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE:_A_ADVANCE_CURRENCY_CODE:TEXT))
																AADD(_aAdtTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE:_A_ADVANCE_PRICE:TEXT))
																AADD(_aAdtTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE:_A_ADVANCE_QUANTITY:TEXT))
															
																AADD(_aAdiant, _aAdtTmp)
															EndIf
														ENDIF		

														If AttIsMemberOf(_oWSRet[_nX], "_A_REQUEST_REFUNDS")
															If Valtype(_oWSRet[_nX]:_A_REQUEST_REFUNDS)  == "A"
																For _nY := 1 to Len (_oWSRet[_nX]:_A_REQUEST_REFUNDS)
																	_lDActive := UPPER(Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_ACTIVE:TEXT)) = "TRUE"
																	
																	//ALLAN
																	If _lVldApr
																		_lDAprova := UPPER(Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_APPROVED:TEXT)) = "TRUE"
																	Else
																		_lDAprova := .T.
																	EndIf
																	
																	If _lDActive .AND. _lDAprova
																		_aDespTmp := {}
																		AADD(_aDespTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_EXPENSE:TEXT))
																		AADD(_aDespTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_INCLUDE_DATE:TEXT))
																		AADD(_aDespTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_PAYMENT_DATE:TEXT))
																		AADD(_aDespTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_CURRENCY_CODE:TEXT))
																		AADD(_aDespTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_PRICE:TEXT))
																		AADD(_aDespTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_QUANTITY:TEXT))
																	
																		AADD(_aDesp, _aDespTmp)
																	EndIf
																Next
															Else
																_lDActive := UPPER(Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_ACTIVE:TEXT)) = "TRUE"
																//ALLAN
																If _lVldApr
																	_lDAprova := UPPER(Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_APPROVED:TEXT)) = "TRUE"
																Else
																	_lDAprova := .T.
																EndIf
																	
																If _lDActive .AND. _lDAprova
																	_aDespTmp := {}
																	AADD(_aDespTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_EXPENSE:TEXT))
																	AADD(_aDespTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_INCLUDE_DATE:TEXT))
																	AADD(_aDespTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_PAYMENT_DATE:TEXT))
																	AADD(_aDespTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_CURRENCY_CODE:TEXT))
																	AADD(_aDespTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_PRICE:TEXT))
																	AADD(_aDespTmp, Alltrim(_oWSRet[_nX]:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_QUANTITY:TEXT))

																	AADD(_aDesp, _aDespTmp)
																EndIf
															EndIf
														ENDIF												
														AADD(_aRetList, {_cIdAlatur, _cLoginPart, _cEmailPart, _cCpfPart, _cEmpSol, _aCC, _aDesp, _aAdiant})
													EndIf
												ElseIf Alltrim(_cWSMetodo) $ "list" .AND. (Empty(_cMessage) .OR. Empty(_cCode))
													If AttIsMemberOf(_oWSRet[_nX], "_A_REQUEST_NUMBER_ARB") 
														AADD(_aRetList, _oWSRet[_nX]:_A_REQUEST_NUMBER_ARB:TEXT)
													EndIf																								
												Else
													_cError	:= _oWSRet[_nX]:_A_MESSAGE:TEXT
													_cDetErro := "Erro no consumo do webservice"												
												EndIf
											Else
												_cCode	:= ""									
												_cError	:= "Atributo _A_MESSAGE e/ou _A_CODE não encontrado no retorno do webservice."
												_aWSRet := {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList} 
												Exit
											EndIf
										Next
																						
										If _cMessage == "OK" .OR. _cCode == "OK"																																			
											_aWSRet := {"0", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList}
										ElseIf Alltrim(_cWSMetodo) $ "list" .AND. (Empty(_cMessage) .OR. Empty(_cCode))
											_aWSRet := {"0", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList}
										Else
											_aRetList	:= {}
											//_cError		:= _oWSRet[_nX]:_A_MESSAGE:TEXT
											//_cDetErro 	:= "Erro no consumo do webservice"
											_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList}
										EndIf
									Else
										If AttIsMemberOf(_oWSRet, "_A_MESSAGE") .AND. AttIsMemberOf(_oWSRet, "_A_CODE")
											_cCode		:= _oWSRet:_A_CODE:TEXT
											_cMessage	:= _oWSRet:_A_MESSAGE:TEXT
											_cError		:= ""
											_cDetErro	:= ""

											If _cMessage == "OK" .OR. _cCode == "OK"
												If AttIsMemberOf(_oWSRet, "_A_REQUEST_NUMBER_ID")
													_cIdAlatur := Alltrim(_oWSRet:_A_REQUEST_NUMBER_ID:TEXT)
												EndIf

												If AttIsMemberOf(_oWSRet, "_A_REQUEST_NUMBER")
													_cNumAlatur := Alltrim(_oWSRet:_A_REQUEST_NUMBER:TEXT)
												EndIf

												If AttIsMemberOf(_oWSRet, "_A_REQUEST_PASSENGER_CPF")
													_cCpfPart := Alltrim(_oWSRet:_A_REQUEST_PASSENGER_CPF:TEXT)
												EndIf
												
												If AttIsMemberOf(_oWSRet, "_A_REQUEST_PASSENGER_EMAIL")
													_cEmailPart := Alltrim(_oWSRet:_A_REQUEST_PASSENGER_EMAIL:TEXT)
												EndIf

												If AttIsMemberOf(_oWSRet, "_A_REQUEST_PASSENGER_LOGIN")
													_cLoginPart := Alltrim(_oWSRet:_A_REQUEST_PASSENGER_LOGIN:TEXT)
												EndIf

												If AttIsMemberOf(_oWSRet, "_A_REQUEST_COMPANY_NAME")
													_cEmpSol := Alltrim(_oWSRet:_A_REQUEST_COMPANY_NAME:TEXT)
												EndIf

												If Upper(Alltrim(_cEmpSol)) == Upper(Alltrim(FL2->FL2_GRPEMP))
													If AttIsMemberOf(_oWSRet, "_A_REQUEST_ACCOUNTS")													
														If Valtype(_oWSRet:_A_REQUEST_ACCOUNTS)  == "A"
															For _nY := 1 to Len (_oWSRet:_A_REQUEST_ACCOUNTS)
																If AttIsMemberOf(_oWSRet:_A_REQUEST_ACCOUNTS[_nY], "_A_REQUEST_ACCOUNTS")	
																	_aCCTmp := {}
																	AADD(_aCCTmp, Alltrim(_oWSRet:_A_REQUEST_ACCOUNTS[_nY]:_A_REQUEST_ACCOUNTS:_A_ACCOUNT_CODE:TEXT))
																	AADD(_aCCTmp, Alltrim(_oWSRet:_A_REQUEST_ACCOUNTS[_nY]:_A_REQUEST_ACCOUNTS:_A_ACCOUNT_PERCENTAGE:TEXT))
																	AADD(_aCCTmp, Alltrim(_oWSRet:_A_REQUEST_ACCOUNTS[_nY]:_A_REQUEST_ACCOUNTS:_A_COMPANY_NAME:TEXT))

																	AADD(_aCC, _aCCTmp)
																	//AADD(_aCC, {Alltrim(_oWSRet:_A_REQUEST_ACCOUNTS[_nY]:_A_REQUEST_ACCOUNTS:_A_ACCOUNT_CODE:TEXT), Alltrim(_oWSRet:_A_REQUEST_ACCOUNTS[_nY]:_A_REQUEST_ACCOUNTS:_A_ACCOUNT_PERCENTAGE:TEXT)})
																EndIf
															Next
														Else
															If AttIsMemberOf(_oWSRet:_A_REQUEST_ACCOUNTS, "_A_REQUEST_ACCOUNTS")
																If Valtype(_oWSRet:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS)  == "A"
																	For _nY := 1 to Len (_oWSRet:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS)
																		_aCCTmp := {}
																		AADD(_aCCTmp, Alltrim(_oWSRet:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS[_nY]:_A_ACCOUNT_CODE:TEXT))
																		AADD(_aCCTmp, Alltrim(_oWSRet:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS[_nY]:_A_ACCOUNT_PERCENTAGE:TEXT))
																		AADD(_aCCTmp, Alltrim(_oWSRet:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS[_nY]:_A_COMPANY_NAME:TEXT))

																		AADD(_aCC, _aCCTmp)																
																	Next
																Else
																	_aCCTmp := {}
																	AADD(_aCCTmp, Alltrim(_oWSRet:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS:_A_ACCOUNT_CODE:TEXT))
																	AADD(_aCCTmp, Alltrim(_oWSRet:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS:_A_ACCOUNT_PERCENTAGE:TEXT))
																	AADD(_aCCTmp, Alltrim(_oWSRet:_A_REQUEST_ACCOUNTS:_A_REQUEST_ACCOUNTS:_A_COMPANY_NAME:TEXT))

																	AADD(_aCC, _aCCTmp)
																EndIf
															EndIf
														EndIf
													ENDIF

													If AttIsMemberOf(_oWSRet, "_A_REQUEST_ADVANCES")
														If Valtype(_oWSRet:_A_REQUEST_ADVANCES)  == "A"
															For _nY := 1 to Len (_oWSRet:_A_REQUEST_ADVANCES)
																//lDActive := UPPER(Alltrim(_oWSRet:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_ACTIVE:TEXT)) = "TRUE"
																//lDAprova := UPPER(Alltrim(_oWSRet:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_APPROVED:TEXT)) = "TRUE"
																
																//If lDActive .AND. lDAprova
																If AttIsMemberOf(_oWSRet:_A_REQUEST_ADVANCES[_nY], "_A_REQUEST_ADVANCE")
																	If Valtype(_oWSRet:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE) == "A"
																		For _nCC := 1 to Len (_oWSRet:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE)
																			_aAdtTmp := {}
																			AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE[_nCC]:_A_ADVANCE_NOTE:TEXT))
																			AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE[_nCC]:_A_ADVANCE_INCLUDE_DATE:TEXT))
																			AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE[_nCC]:_A_ADVANCE_PAYMENT_DATE:TEXT))
																			AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE[_nCC]:_A_ADVANCE_CURRENCY_CODE:TEXT))
																			AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE[_nCC]:_A_ADVANCE_PRICE:TEXT))
																			AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE[_nCC]:_A_ADVANCE_QUANTITY:TEXT))
																		
																			AADD(_aAdiant, _aAdtTmp)
																		Next
																	Else
																		_aAdtTmp := {}
																		AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE:_A_ADVANCE_NOTE:TEXT))
																		AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE:_A_ADVANCE_INCLUDE_DATE:TEXT))
																		AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE:_A_ADVANCE_PAYMENT_DATE:TEXT))
																		AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE:_A_ADVANCE_CURRENCY_CODE:TEXT))
																		AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE:_A_ADVANCE_PRICE:TEXT))
																		AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES[_nY]:_A_REQUEST_ADVANCE:_A_ADVANCE_QUANTITY:TEXT))
																	
																		AADD(_aAdiant, _aAdtTmp)
																	EndIF
																EndIf
															Next
														Else
															If AttIsMemberOf(_oWSRet:_A_REQUEST_ADVANCES, "_A_REQUEST_ADVANCE")
																If Valtype(_oWSRet:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE) == "A"
																	For _nCC := 1 to Len (_oWSRet:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE)
																		_aAdtTmp := {}
																		AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE[_nCC]:_A_ADVANCE_NOTE:TEXT))
																		AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE[_nCC]:_A_ADVANCE_INCLUDE_DATE:TEXT))
																		AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE[_nCC]:_A_ADVANCE_PAYMENT_DATE:TEXT))
																		AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE[_nCC]:_A_ADVANCE_CURRENCY_CODE:TEXT))
																		AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE[_nCC]:_A_ADVANCE_PRICE:TEXT))
																		AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE[_nCC]:_A_ADVANCE_QUANTITY:TEXT))
																	
																		AADD(_aAdiant, _aAdtTmp)
																	Next
																Else
																	_aAdtTmp := {}
																	AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE:_A_ADVANCE_NOTE:TEXT))
																	AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE:_A_ADVANCE_INCLUDE_DATE:TEXT))
																	AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE:_A_ADVANCE_PAYMENT_DATE:TEXT))
																	AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE:_A_ADVANCE_CURRENCY_CODE:TEXT))
																	AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE:_A_ADVANCE_PRICE:TEXT))
																	AADD(_aAdtTmp, Alltrim(_oWSRet:_A_REQUEST_ADVANCES:_A_REQUEST_ADVANCE:_A_ADVANCE_QUANTITY:TEXT))
															
																	AADD(_aAdiant, _aAdtTmp)
																EndIF
															EndIf
														EndIf
													ENDIF		

													If AttIsMemberOf(_oWSRet, "_A_REQUEST_REFUNDS")
														If Valtype(_oWSRet:_A_REQUEST_REFUNDS)  == "A"
															For _nY := 1 to Len (_oWSRet:_A_REQUEST_REFUNDS)
																If AttIsMemberOf(_oWSRet:_A_REQUEST_REFUNDS[_nY], "_A_REQUEST_REFUND")	
																	_lDActive := UPPER(Alltrim(_oWSRet:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_ACTIVE:TEXT)) = "TRUE"
																	
																	//ALLAN
																	If _lVldApr
																		_lDAprova := UPPER(Alltrim(_oWSRet:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_APPROVED:TEXT)) = "TRUE"
																	Else
																		_lDAprova := .T.
																	EndIf
																	
																	If _lDActive .AND. _lDAprova
																		_aDespTmp := {}
																		AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_EXPENSE:TEXT))
																		AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_INCLUDE_DATE:TEXT))
																		AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_PAYMENT_DATE:TEXT))
																		AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_CURRENCY_CODE:TEXT))
																		AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_PRICE:TEXT))
																		AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS[_nY]:_A_REQUEST_REFUND:_A_REFUND_QUANTITY:TEXT))
																	
																		AADD(_aDesp, _aDespTmp)
																	EndIf
																EndIf
															Next
														Else
															If AttIsMemberOf(_oWSRet:_A_REQUEST_REFUNDS, "_A_REQUEST_REFUND")	
																If Valtype(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND) == "A"
																	For _nY := 1 to Len (_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND)
																		_lDActive := UPPER(Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND[_nY]:_A_REFUND_ACTIVE:TEXT)) = "TRUE"
																			
																		//ALLAN
																		If _lVldApr
																			_lDAprova := UPPER(Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND[_nY]:_A_REFUND_APPROVED:TEXT)) = "TRUE"
																		Else
																			_lDAprova := .T.
																		EndIf	

																		If _lDActive .AND. _lDAprova
																			_aDespTmp := {}
																			AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND[_nY]:_A_REFUND_EXPENSE:TEXT))
																			AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND[_nY]:_A_REFUND_INCLUDE_DATE:TEXT))
																			AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND[_nY]:_A_REFUND_PAYMENT_DATE:TEXT))
																			AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND[_nY]:_A_REFUND_CURRENCY_CODE:TEXT))
																			AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND[_nY]:_A_REFUND_PRICE:TEXT))
																			AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND[_nY]:_A_REFUND_QUANTITY:TEXT))

																			AADD(_aDesp, _aDespTmp)
																		EndIf
																	Next
																Else
																	_lDActive := UPPER(Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_ACTIVE:TEXT)) = "TRUE"
																																
																	//ALLAN
																	If _lVldApr
																		_lDAprova := UPPER(Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_APPROVED:TEXT)) = "TRUE"
																	Else
																		_lDAprova := .T.
																	EndIf
																		
																	If _lDActive .AND. _lDAprova
																		_aDespTmp := {}
																		AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_EXPENSE:TEXT))
																		AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_INCLUDE_DATE:TEXT))
																		AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_PAYMENT_DATE:TEXT))
																		AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_CURRENCY_CODE:TEXT))
																		AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_PRICE:TEXT))
																		AADD(_aDespTmp, Alltrim(_oWSRet:_A_REQUEST_REFUNDS:_A_REQUEST_REFUND:_A_REFUND_QUANTITY:TEXT))

																		AADD(_aDesp, _aDespTmp)
																	EndIf
																EndIf
															EndIf
														EndIf
													ENDIF
													AADD(_aRetList, {_cIdAlatur, _cLoginPart, _cEmailPart, _cCpfPart, _cEmpSol, _aCC, _aDesp, _aAdiant})
												EndIf
												_aWSRet 	:= {"0", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList}
											ElseIf Alltrim(_cWSMetodo) $ "list" .AND. (Empty(_cMessage) .OR. Empty(_cCode))
												AttIsMemberOf(_oWSRet, "_A_REQUEST_LIST")

												_aRetList := {}

												_aWSRet 	:= {"0", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList}
											Else
												_cError	:= _oWSRet:_A_MESSAGE:TEXT
												_cDetErro	:= "Erro no consumo do webservice"
											
												_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList}
											EndIf
										Else
											_cCode		:= ""									
											_cError	:= "Atributo _A_MESSAGE e/ou _A_CODE não encontrado no retorno do webservice."
											
											_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList} 												
										EndIf
									EndIf
								Else
									If !Empty(_cWarning)
										_cDetErro	:= _cError +CHR(13)+CHR(10)+ " Warning: " + _cWarning											
									Else
										_cDetErro	:= _cError											
									EndIf
																
									_cCode		:= ""
									_cError 	:= "Erro no SendSoapMsg do webservice."								
									
									_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList} 											
								EndIf	
							Else
								_cMsgRet	:= ""
								_cCode		:= ""
								_cError 	:= "Erro no SendSoapMsg do webservice."
								_cDetErro	:= _oWsdl:cError + " Erro SendSoapMsg FaultCode: " + _oWsdl:cFaultCode
								
								_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList} 																																				
							EndIf
						Else	
							_cMsg		:= ""
							_cMsgRet	:= ""
							_cCode		:= ""
							_cError 	:= "Erro na consulta do webservice SetOperation ("+_cWSMetodo+")."
							_cDetErro	:= _oWsdl:cError
							
							_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList} 															
						EndIf			
					Else
						_cMsg		:= ""
						_cMsgRet	:= ""
						_cCode		:= ""
						_cError 	:= "Erro na consulta do webservice ParseURL ("+_cURL+")."
						_cDetErro	:= _oWsdl:cError
						
						_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList} 					 								
					EndIf					
				Else
					_cMsg		:= ""
					_cMsgRet	:= ""
					_cCode		:= ""
					_cError 	:= "Empresa("+_cEmpXML+") / Filial ("+_cFilXML+") não localizada no cadastro de empresas Copastur."
					_cDetErro	:= ""
					
					_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList} 					
				EndIf
			Else
				_cMsg		:= ""
				_cMsgRet	:= ""
				_cCode		:= ""
				_cError 	:= "Integração com o Copastur desativada."
				_cDetErro	:= ""
				
				_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage,  _cError, _cDetErro, _aRetList} 				
			EndIf		
		Else
			_cMsg		:= ""
			_cMsgRet	:= ""
			_cCode		:= ""
			_cError 	:= "Empresa / Filial não informada."
			_cDetErro	:= ""
			
			_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage,  _cError, _cDetErro, _aRetList} 
		EndIf
	Else
		_cMsg		:= ""
		_cMsgRet	:= ""
		
		_cCode		:= ""
		_cError 	:= "Parâmetros método e request para a pesquisa no webservice não informados."
		_cDetErro	:= ""
		
		_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList}	
	EndIf

/*
	If Valtype(_aAdtTmp) == "A"
		aSize(_aAdtTmp, 0)
	EndIf

	If Valtype(_aDespTmp) == "A"
		aSize(_aDespTmp, 0)
	EndIf

	If Valtype(_aDesp) == "A"
		aSize(_aDesp, 0)
	EndIf

	If Valtype(_aCCTmp) == "A"
		aSize(_aCCTmp, 0)
	EndIf

	If Valtype(_aCC) == "A"
		aSize(_aCC, 0)
	EndIf
*/
	If Valtype(_oWSRet) == "A"
		aSize(_oWSRet, 0)
		_oWSRet := NIL
	EndIf

	If Valtype(_oWSRet) == "O"
		FreeObj(_oWSRet)
		_oWSRet := NIL
	EndIf

	If Valtype(_oXmlRet) == "O"
		FreeObj(_oXmlRet)
		_oXmlRet := NIL
	EndIf

	If Valtype(_oWsdl) == "O"
		FreeObj(_oWsdl)
		_oWsdl := NIL
	EndIf

	RestArea(_aArea)

Return _aWSRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINWS07A

Copastur - Webservice RequestServices - (Pagamentos)

@author CM Solutions - Allan Constantino Bonfim
@since  12/02/2020
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FINWS07A(_aDadosReq, _nOpcA, _cEmpOri, _cFilOri, _dDataIni, _dDataFim, _cReqStat, _cDespStat, _cNumAlatur, _cTipoPag, _cMoedaPag, _cBancoPag, _cObsPag, _nRD0Indice, _cRD0FilChv, _cRD0Chave)

	Local _aArea		:= GetArea()
	Local _aRetPrc		:= ARRAY(7) 
	Local _aRequest 	:= {}
	Local _cNomeEmp 	:= ""	
	Local _lContinua 	:= .T.
//	Local _cCodeEmp		:= "" 
	Local _cMsgVld		:= ""
	Local _cDataTipo	:= ""
	Local _cModoPag		:= ""
	Local _cPrefWs		:= "tem"//"ws:"

	Default _nOpcA		:= 0
	Default _cEmpOri	:= FwCodEmp() //GetNewPar("ZZ_WSALAEP", "02")
	Default _cFilOri	:= FwCodFil() //GetNewPar("ZZ_WSALAFP", "01")
	Default _dDataIni	:= dDataBase - GetNewPar("ZZ_WSALADP", 30)
	Default _dDataFim	:= dDataBase 
	Default _cReqStat	:= ""
	Default _cDespStat	:= ""
	Default _cNumAlatur	:= ""
	Default _cTipoPag	:= ""
	Default _cMoedaPag	:= ""
	Default _cBancoPag	:= ""
	Default _cObsPag	:= ""

	Default _nRD0Indice	:= 1 
	Default _cRD0FilChv	:= ""
	Default _cRD0Chave	:= ""
	Default _aDadosReq	:= {}

	
	If Len(_aDadosReq) > 0
		_lContinua := .T.
	Else
		DbSelectArea("FL2") //Cadastro empresas Copastur
		DbSetOrder(1) //FL2_FILIAL, FL2_BKOEMP, FL2_LICENC
		If !FL2->(DbSeek(FwxFilial("FL2")+_cEmpOri+_cFilOri))
			_lContinua := .F.
			_aRetPrc 	:= {"1", "", "", "", "", "Empresa do participante não cadastrada no Copastur.", "Empresa ("+_cEmpOri+") / Filial ("+_cFilOri+") não localizada no cadastro de empresas Copastur. Verifique o cadastro da empresa (FL2)."}
		EndIf			
	ENDIF

	If _lContinua	
		//Campos Obrigatórios
		_cDataIni	:= Year2Str(_dDataIni)+"-"+Month2Str(_dDataIni)+"-"+Day2Str(_dDataIni)	
		_cDataFim	:= Year2Str(_dDataFim)+"-"+Month2Str(_dDataFim)+"-"+Day2Str(_dDataFim)	
		
		//If Alltrim(_cReqStat) $ "REE/FAT" .AND. Alltrim(_cDespStat) == "PAG"
		If Alltrim(_cReqStat) == "REE" .AND. Alltrim(_cDespStat) == "PAG"
			_cDataTipo	:= "dtAprovReemb"
		Else
			_cDataTipo	:= "dtAprovacao"
		EndIf

		If Alltrim(_cTipoPag) == "R"
			_cModoPag := "1"
		Else
			_cModoPag := "0"
		EndIf

		//Campos Opicionais
		_cNomeEmp	:= ALLTRIM(FL2->FL2_GRPEMP)

		//Validação campos obrigatórios
		If _nOpcA == 1 //LIST
			If Empty(_cDataIni)
				_cMsgVld := "Parâmetro _cDataIni (request_date_start) em branco. Verifique os parâmetros obrigatórios do método LIST."
			EndIf
				
			If Empty(_cDataFim)
				_cMsgVld := "Parâmetro _cDataFim (request_date_end) em branco. Verifique os parâmetros obrigatórios do método LIST."
			EndIf

			If Empty(_cReqStat)
				_cMsgVld := "Parâmetro _cReqStat (request_status) em branco. Verifique os parâmetros obrigatórios do método LIST."
			EndIf

			If Empty(_cDespStat)
				_cMsgVld := "Parâmetro _cDespStat (expense_status) em branco. Verifique os parâmetros obrigatórios do método LIST."
			EndIf
		ElseIf _nOpcA == 2 //GET
			If Empty(_cNumAlatur)
				_cMsgVld := "Parâmetro _cNumAlatur (request_number_arb) em branco. Verifique os parâmetros obrigatórios do método GET."
			EndIf
		ElseIf _nOpcA == 3 //PAY
			If Empty(_cNumAlatur)
				_cMsgVld := "Parâmetro _cNumAlatur (request_number_arb) em branco. Verifique os parâmetros obrigatórios do método PAY."
			EndIf

			If Empty(_cDataIni)
				_cMsgVld := "Parâmetro _cDataIni (payment_Date) em branco. Verifique os parâmetros obrigatórios do método PAY."
			EndIf

			If Empty(_cTipoPag)
				_cMsgVld := "Parâmetro _cTipoPag (payment_Type) em branco. Verifique os parâmetros obrigatórios do método PAY."
			EndIf

			If Empty(_cMoedaPag)
				_cMsgVld := "Parâmetro _cMoedaPag (payment_Currency) em branco. Verifique os parâmetros obrigatórios do método PAY."
			EndIf

			If Empty(_cBancoPag)
				_cMsgVld := "Parâmetro _cBancoPag (payment_Bank_Account) em branco. Verifique os parâmetros obrigatórios do método PAY."
			EndIf
	
			If Empty(_cModoPag)
				_cMsgVld := "Parâmetro _cModoPag (payment_pay_provision) em branco. Verifique os parâmetros obrigatórios do método PAY."
			EndIf
		EndIf

		If !Empty(_cMsgVld)		
			_lContinua	:= .F.			
			_aRetPrc 	:= {"1", "", "", "", "", "Erro nos campos obrigatórios para o envio do webservice RequestServices - (Pagamentos).", _cMsgVld}			
		EndIf
	EndIf
	
	If _lContinua
		If _nOpcA == 1 //LIST
		
			If Len(_aDadosReq) > 0			
				_aRequest := aClone(_aDadosReq)
			Else								
				_aRequest := {}
				//CAMPO - nome - conteúdo - descrição - tipo - tamanho - obrigatoriedade
				AADD(_aRequest, {_cPrefWs+":request_date_start", _cDataIni}) //Data de início da pesquisa da solicitação. (Formato AAAA-MM-DD) - date - 10 - Sim
				AADD(_aRequest, {_cPrefWs+":request_date_end", _cDataFim}) //Data final da pesquisa da solicitação. (Formato AAAA-MM-DD) - date - 10 - Sim
				AADD(_aRequest, {_cPrefWs+":request_status", _cReqStat}) //Status da requisição (ABE - Em Aberto, COT - Aguardando cotação, ESC - Aguardando escolha, AUT - Aguardando autorização de custo, EMI - Aguardando emissão, FAT - Emitida liberada para faturamento, CAN - Cancelada, REE - Reembolso, RES - Reservando, LAN - Adiantamento Reprovado, ENC - Adiantamento Aprovado, MER - Aguardando Mérito, ORC - Aguardando Orçamento, EXP - Expirada, REP - Reprovada) - char - 3 - Sim
				AADD(_aRequest, {_cPrefWs+":expense_status", _cDespStat}) //Tipo de data (dtAprovacao, dtCotacao, dtEmissao, dtEscolha, dtSolicitacao, dtInicioViagem, dtTerminoViagem, dtAprovReemb, dtPagtoReemb, dtAlteracao) - char - 20 - Sim
				AADD(_aRequest, {_cPrefWs+":date_type", _cDataTipo}) //Status despesas (EMI - Aguardando emissão, quando associada com uma viagem, LAN - Aguardando lançamento, CON - Aguardando conferência, AUT - Aguardando autorização, PAG - Aguardando pagamento, ENC - Encerrada) - char - 3 - Sim
			EndIf
			
			_aRetPrc := U_FINWS007("list",, _aRequest, _cEmpOri, _cFilOri)

		ElseIf _nOpcA == 2 //GET

			If Len(_aDadosReq) > 0			
				_aRequest := aClone(_aDadosReq)
			Else								
				_aRequest := {}
			
				//CAMPO - nome - conteúdo - descrição - tipo - tamanho - obrigatoriedade
				AADD(_aRequest, {_cPrefWs+":request_number_arb", _cNumAlatur})  //Número da requisição no ARBeB - varchar - 64 - Sim		
			EndIf
			
			_aRetPrc := U_FINWS007("getV2",, _aRequest, _cEmpOri, _cFilOri) //Get

		ElseIf _nOpcA == 3 //PAY

			If Len(_aDadosReq) > 0			
				_aRequest := aClone(_aDadosReq)
			Else								
				_aRequest := {}
			
				//CAMPO - nome - conteúdo - descrição - tipo - tamanho - obrigatoriedade
				AADD(_aRequest, {_cPrefWs+":request_Number", _cNumAlatur})  //Número da requisição no ARBeB - varchar - 64 - Sim		
				AADD(_aRequest, {_cPrefWs+":payment_Date", _cDataIni})  //Data do pagamento (Formato AAAA-MM-DD) - Data - 10 - Sim		
				AADD(_aRequest, {_cPrefWs+":payment_Type", _cTipoPag})  //Tipo de pagamento (A: Adiantamento / R: Reembolso / D:Devolução) - varchar - 1 - Sim	
				AADD(_aRequest, {_cPrefWs+":payment_Currency", _cMoedaPag})  //Moeda de pagamento (BRL - Real / USD - Dolar, EUR - Euro) - varchar - 3 - Sim
				AADD(_aRequest, {_cPrefWs+":payment_Bank_Account", _cBancoPag})  //Conta bancária - varchar - 30 - Sim
				AADD(_aRequest, {_cPrefWs+":payment_Remmarks", Substr(_cObsPag, 1, 255)})  //Observações - varchar - 256 - Sim
				AADD(_aRequest, {_cPrefWs+":payment_pay_provision", _cModoPag})  //Provisão de pagamento - varchar - 128 - Sim
			EndIf
			
			_aRetPrc := U_FINWS007("pay",, _aRequest, _cEmpOri, _cFilOri)

		EndIf
	EndIf	
	
	RestArea(_aArea)

Return _aRetPrc


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINWS05I

Copastur - Geração da tabela integradora

@author CM Solutions - Allan Constantino Bonfim
@since  26/11/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
/*USER FUNCTION FINWS07I(cEmpOri, cFilOri, cFilPart, cCodPart, cTpInteg) //1=Inclusao 2=Alteracao 3=Exclusao 4=Consulta

	Local aArea			:= GetArea()
	Local cQDados		:= ""
	Local cTmpInt		:= GetNextAlias()
	//Local aCTTDados		:= {}
	Local lRet			:= .T.

	Default cEmpOri		:= ""
	Default cFilOri		:= ""
	Default cTpInteg	:= "2"
	Default cFilPart	:= FwxFilial("RD0")
	Default cCodPart	:= ""
	

	If !Empty(cCodPart)

		DbSelectArea("RD0") //Cadastro Participantes
		DbSetOrder(1) //RD0_FILIAL, RD0_CODIGO
		If RD0->(DbSeek(cFilPart+cCodPart))		

			If !Empty(RD0->RD0_EMPATU)							
				_cEmpOri	:= RD0->RD0_EMPATU
			ENDIF

			If !Empty(RD0->RD0_FILATU)	
				_cFilOri 	:= RD0->RD0_FILATU
			ENDIF

			If !FL2->(DbSeek(FwxFilial("FL2")+RD0->RD0_EMPATU+RD0->RD0_FILATU))	
				_cEmpOri	:= FwCodEmp() //GETNEWPAR("ZZ_WSALAEP", "02")
				_cFilOri 	:= FwCodFil() //GETNEWPAR("ZZ_WSALAFP", "01")
			EndIf	

			cQDados := "SELECT RD0_FILIAL, RD0_CODIGO, RD0_NOME, RD0_XLOGIN, RD0_EMAIL, R_E_C_N_O_ AS RD0REC "+CHR(13)+CHR(10) 
			cQDados += "FROM " +RetSqlName("RD0")+ " RD0 (NOLOCK) "+CHR(13)+CHR(10) 
			cQDados += "WHERE RD0.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10) 
			
			If !Empty(cFilPart)
				cQDados += "AND RD0_FILIAL = '"+cFilPart+"' "+CHR(13)+CHR(10)
			EndIf
			
			If !Empty(cCodPart)
				cQDados += "AND RD0_CODIGO = '"+cCodPart+"' "+CHR(13)+CHR(10)
			EndIf
			
			cQDados += "AND RD0_XALATU = 'S' "+CHR(13)+CHR(10)
			cQDados += "AND NOT EXISTS(SELECT ZWQ_CODIGO FROM " +RetSqlName("ZWQ")+ " ZWQ (NOLOCK) WHERE ZWQ.D_E_L_E_T_ = ' ' AND ZWQ_FILIAL = '"+FwxFilial("ZWQ")+"' AND ZWQ_CALIAS = 'RD0' AND ZWQ_FILALI = RD0_FILIAL AND ZWQ_CHAVE = RD0_CODIGO AND ZWQ_TINTEG = '"+cTpInteg+"' AND ZWQ_APROVA <> 'S' AND ZWQ_STATUS <> '05') "+CHR(13)+CHR(10)			
			
			cQDados += "ORDER BY RD0_FILIAL, RD0_CODIGO "+CHR(13)+CHR(10)

			cQDados := ChangeQuery(cQDados)	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados), cTmpInt)	
			
			While !(cTmpInt)->(EOF())
				lRet := U_FINWS2GR(3,,, cEmpOri, cFilOri, "RD0", 1, (cTmpInt)->RD0_FILIAL, (cTmpInt)->RD0_CODIGO, (cTmpInt)->RD0REC, "01", "1", cTpInteg, "1",,,,, ALLTRIM((cTmpInt)->RD0_XLOGIN), ALLTRIM((cTmpInt)->RD0_EMAIL))

				(cTmpInt)->(DbSkip())
			ENDDo

		ENDIF
	EndIf

	If Select(cTmpInt) > 0
		(cTmpInt)->(DbCloseArea())
	EndIf

	RestArea(aArea)
	
Return lRet
*/


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIWS7FAL

Copastur - Verifica as integrações de adiantamento e reembolso no Copastur

@author CM Solutions - Allan Constantino Bonfim
@since  23/02/2020
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FIWS7FAL(_cEmpOri, _cFilOri, _cFilPart, _cCodPart, _lAdto, _lDesp, _cCodDesp)

	Local _aArea		:= GetArea()
	Local _aRetWs		:= {}
	Local _aRetFin		:= {}
	Local _aDesp		:= {}
	Local _aAdto		:= {}
	Local _nX			:= 0	
	Local _aCodDesp		:= {}
	Local _aRetGet		:= {}
	Local _aRateio		:= {}
	Local _lFinOk		:= .F.
	Local _cLogin		:= ""
	
	Default _cEmpOri	:= FwCodEmp()
	Default _cFilOri	:= FwCodFil()
	Default _cFilPart	:= ""
	Default _cCodPart	:= ""
	Default _lAdto		:= .F.
	Default _lDesp		:= .T.
	Default _cCodDesp	:= ""


	If !Empty(_cEmpOri) .AND. !Empty(_cFilOri)

		//REEMBOLSO AVULSO
		_aRetWs := U_FINWS07A(,1, _cEmpOri, _cFilOri,,, "REE", "PAG")

		If _aRetWs[1] == "0"
			//_lFinOk		:= .F.
			_aRetGet 	:= _aRetWs[8]

			For _nX := 1 to Len(_aRetGet)
				_lFinOk		:= .F.
				_aRetWs := U_FINWS07A(,2, _cEmpOri, _cFilOri,,,,, _aRetGet[_nX])
				
				//If ALLTRIM(_aRetGet[_nX]) $ "6748/6768/6769/6579/6604/6700/6761/6138/6745/6464/6739"
				//	ALERT(_aRetGet[_nX])
				//EndIf
				
				If _aRetWs[1] == "0"
					_aRetFin	:= _aRetWs[8]

					If Len(_aRetFin) > 0
						_aRateio	:= _aRetFin[1][6]
						_aDesp		:= _aRetFin[1][7]
						_aAdto		:= _aRetFin[1][8]
						_cLogin		:= _aRetFin[1][2]

						If !_lFinOk
							If _lAdto
								If Len(_aAdto) > 0
									_lFinOk := .T.
								EndIf
							Else
								_aAdto := {}
							EndIf
						EndIf

						If !_lFinOk
							If _lDesp
								If Len(_aDesp) > 0
									_lFinOk := .T.
								EndIf
							Else
								_aDesp := {}
							EndIf
						EndIf

						If _lFinOk
							If !Empty(_cCodPart)
								_lFinOk := .F.

								DbSelectArea("RD0")
								DbOrderNickName("RD00000002") //RD0_FILIAL+RD0_XLOGIN
								If RD0->(Dbseek(FwxFilial("RD0")+Upper(Alltrim(_cLogin))))
									If _cFilPart == RD0->RD0_FILIAL .AND. _cCodPart == RD0->RD0_CODIGO
										_lFinOk := .T.
									EndIf
								ENDIF
							EndIf
						ENDIF
					EndIF

					If _lFinOk
						//If Ascan(_aCodDesp, {|x| Alltrim(x) == Alltrim(_aRetGet[_nX])}) == 0
						If Ascan(_aCodDesp, {|x| Alltrim(x[1]) == Alltrim(_aRetGet[_nX])}) == 0
							If !Empty(_cCodDesp)
								If Alltrim(_cCodDesp) == Alltrim(_aRetGet[_nX])
									//AADD(_aCodDesp, _aRetGet[_nX])
									AADD(_aCodDesp, {_aRetGet[_nX], _cLogin, _aAdto, _aDesp, _aRateio})
								EndIf
							Else
								//AADD(_aCodDesp, _aRetGet[_nX])
								AADD(_aCodDesp, {_aRetGet[_nX], _cLogin, _aAdto, _aDesp, _aRateio})
							EndIf
						EndIf
					EndIf
				EndIf
			Next
		EndIf

		//VIAGEM COM REEMBOLSO
		_aRetWs := U_FINWS07A(,1, _cEmpOri, _cFilOri,,, "FAT", "PAG")

		If _aRetWs[1] == "0"
			//_lFinOk		:= .F.
			_aRetGet 	:= _aRetWs[8]

			For _nX := 1 to Len(_aRetGet)
				_lFinOk		:= .F.
				_aRetWs := U_FINWS07A(,2, _cEmpOri, _cFilOri,,,,, _aRetGet[_nX])

				If _aRetWs[1] == "0"
					_aRetFin	:= _aRetWs[8]
					
					If Len(_aRetFin) > 0
						_aRateio	:= _aRetFin[1][6]
						_aDesp		:= _aRetFin[1][7]
						_aAdto		:= _aRetFin[1][8]
						_cLogin		:= _aRetFin[1][2]

						If !_lFinOk
							If _lAdto
								If Len(_aAdto) > 0
									_lFinOk := .T.
								EndIf
							Else
								_aAdto := {}
							EndIf
						EndIf

						If !_lFinOk
							If _lDesp
								If Len(_aDesp) > 0
									_lFinOk := .T.
								EndIf
							Else
								_aDesp := {}
							EndIf
						EndIf

						If _lFinOk
							If !Empty(_cCodPart)
								_lFinOk := .F.

								DbSelectArea("RD0")
								DbOrderNickName("RD00000002") //RD0_FILIAL+RD0_XLOGIN
								If RD0->(Dbseek(FwxFilial("RD0")+Upper(Alltrim(_cLogin))))
									If _cFilPart == RD0->RD0_FILIAL .AND. _cCodPart == RD0->RD0_CODIGO
										_lFinOk := .T.
									EndIf
								ENDIF
							EndIf
						ENDIF
					EndIF

					If _lFinOk
						//If Ascan(_aCodDesp, {|x| Alltrim(x) == Alltrim(_aRetGet[_nX])}) == 0
						If Ascan(_aCodDesp, {|x| Alltrim(x[1]) == Alltrim(_aRetGet[_nX])}) == 0
							If !Empty(_cCodDesp)
								If Alltrim(_cCodDesp) == Alltrim(_aRetGet[_nX])
								//AADD(_aCodDesp, _aRetGet[_nX])
									AADD(_aCodDesp, {_aRetGet[_nX], _cLogin, _aAdto, _aDesp, _aRateio})
								EndIf
							Else
								//AADD(_aCodDesp, _aRetGet[_nX])
								AADD(_aCodDesp, {_aRetGet[_nX], _cLogin, _aAdto, _aDesp, _aRateio})
							EndIf
						EndIf
					EndIf
				EndIf
			Next
		EndIf

		//ADIANTAMENTO PAGO - PRESTAÇÃO DE CONTAS
		_aRetWs := U_FINWS07A(,1, _cEmpOri, _cFilOri,,, "ENC", "PAG")

		If _aRetWs[1] == "0"
			//_lFinOk		:= .F.
			_aRetGet 	:= _aRetWs[8]

			For _nX := 1 to Len(_aRetGet)
				_lFinOk		:= .F.
				_aRetWs := U_FINWS07A(,2, _cEmpOri, _cFilOri,,,,, _aRetGet[_nX])

				If _aRetWs[1] == "0"
					_aRetFin	:= _aRetWs[8]

					If Len(_aRetFin) > 0
						_aRateio	:= _aRetFin[1][6]
						_aDesp		:= _aRetFin[1][7]
						_aAdto		:= _aRetFin[1][8]
						_cLogin		:= _aRetFin[1][2]

						If !_lFinOk
							If _lAdto
								If Len(_aAdto) > 0
									_lFinOk := .T.
								EndIf
							Else
								_aAdto := {}
							EndIf
						EndIf

						If !_lFinOk
							If _lDesp
								If Len(_aDesp) > 0
									_lFinOk := .T.
								EndIf
							Else
								_aDesp := {}
							EndIf
						EndIf

						If _lFinOk
							If !Empty(_cCodPart)
								_lFinOk := .F.

								DbSelectArea("RD0")
								DbOrderNickName("RD00000002") //RD0_FILIAL+RD0_XLOGIN
								If RD0->(Dbseek(FwxFilial("RD0")+Upper(Alltrim(_cLogin))))
									If _cFilPart == RD0->RD0_FILIAL .AND. _cCodPart == RD0->RD0_CODIGO
										_lFinOk := .T.
									EndIf
								ENDIF
							EndIf
						ENDIF
					EndIF

					If _lFinOk
						//If Ascan(_aCodDesp, {|x| Alltrim(x) == Alltrim(_aRetGet[_nX])}) == 0
						If Ascan(_aCodDesp, {|x| Alltrim(x[1]) == Alltrim(_aRetGet[_nX])}) == 0
							If !Empty(_cCodDesp)
								If Alltrim(_cCodDesp) == Alltrim(_aRetGet[_nX])
									//AADD(_aCodDesp, _aRetGet[_nX])
									AADD(_aCodDesp, {_aRetGet[_nX], _cLogin, _aAdto, _aDesp, _aRateio})
								EndIf
							Else
								//AADD(_aCodDesp, _aRetGet[_nX])
								AADD(_aCodDesp, {_aRetGet[_nX], _cLogin, _aAdto, _aDesp, _aRateio})
							EndIf
						EndIf
					EndIf
				EndIf
			Next
		EndIf

		//ADIANTAMENTO AVULSO
		_aRetWs := U_FINWS07A(,1, _cEmpOri, _cFilOri,,, "ENC", "EMI")

		If _aRetWs[1] == "0"
			//_lFinOk		:= .F.
			_aRetGet 	:= _aRetWs[8]

			For _nX := 1 to Len(_aRetGet)
				_lFinOk	:= .F.
				_aRetWs := U_FINWS07A(,2, _cEmpOri, _cFilOri,,,,, _aRetGet[_nX])

				If _aRetWs[1] == "0"
					_aRetFin	:= _aRetWs[8]

					If Len(_aRetFin) > 0
						_aRateio	:= _aRetFin[1][6]
						_aDesp		:= _aRetFin[1][7]
						_aAdto		:= _aRetFin[1][8]
						_cLogin		:= _aRetFin[1][2]

						If !_lFinOk
							If _lAdto
								If Len(_aAdto) > 0
									_lFinOk := .T.
								EndIf
							Else
								_aAdto := {}
							EndIf
						EndIf

						If !_lFinOk
							If _lDesp
								If Len(_aDesp) > 0
									_lFinOk := .T.
								EndIf
							Else
								_aDesp := {}
							EndIf
						EndIf

						If _lFinOk
							If !Empty(_cCodPart)
								_lFinOk := .F.

								DbSelectArea("RD0")
								DbOrderNickName("RD00000002") //RD0_FILIAL+RD0_XLOGIN
								If RD0->(Dbseek(FwxFilial("RD0")+Upper(Alltrim(_cLogin))))
									If _cFilPart == RD0->RD0_FILIAL .AND. _cCodPart == RD0->RD0_CODIGO
										_lFinOk := .T.
									EndIf
								ENDIF
							EndIf
						ENDIF
					EndIF

					If _lFinOk
						//If Ascan(_aCodDesp, {|x| Alltrim(x) == Alltrim(_aRetGet[_nX])}) == 0
						If Ascan(_aCodDesp, {|x| Alltrim(x[1]) == Alltrim(_aRetGet[_nX])}) == 0
							If !Empty(_cCodDesp)
								If Alltrim(_cCodDesp) == Alltrim(_aRetGet[_nX])
										//AADD(_aCodDesp, _aRetGet[_nX])
									AADD(_aCodDesp, {_aRetGet[_nX], _cLogin, _aAdto, _aDesp, _aRateio})
								EndIf
							Else
								//AADD(_aCodDesp, _aRetGet[_nX])
								AADD(_aCodDesp, {_aRetGet[_nX], _cLogin, _aAdto, _aDesp, _aRateio})
							EndIf
						EndIf
					EndIf
				EndIf
			Next
		EndIf
		//Retirado após confirmação do Renato que esse cenário não se aplica no ambiente Produção.
		//VIAGEM COM ADIANTAMENTO
	/*	_aRetWs := U_FINWS07A(,1, _cEmpOri, _cFilOri,,, "FAT", "EMI") //U_FINWS07A(,1, _cEmpOri, _cFilOri,,, "FAT", "LAN")

		If _aRetWs[1] == "0"
			//_lFinOk		:= .F.
			_aRetGet 	:= _aRetWs[8]

			For _nX := 1 to Len(_aRetGet)
				_lFinOk	:= .F.
				_aRetWs := U_FINWS07A(,2, _cEmpOri, _cFilOri,,,,, _aRetGet[_nX])

				If _aRetWs[1] == "0"
					_aRetFin	:= _aRetWs[8]

					If Len(_aRetFin) > 0
						_aRateio	:= _aRetFin[1][6]
						_aDesp		:= _aRetFin[1][7]
						_aAdto		:= _aRetFin[1][8]
						_cLogin		:= _aRetFin[1][2]

						If !_lFinOk
							If _lAdto
								If Len(_aAdto) > 0
									_lFinOk := .T.
								EndIf
							Else
								_aAdto := {}
							EndIf
						EndIf

						If !_lFinOk
							If _lDesp
								If Len(_aDesp) > 0
									_lFinOk := .T.
								EndIf
							Else
								_aDesp := {}
							EndIf
						EndIf

						If _lFinOk
							If !Empty(_cCodPart)
								_lFinOk := .F.

								DbSelectArea("RD0")
								DbOrderNickName("RD00000002") //RD0_FILIAL+RD0_XLOGIN
								If RD0->(Dbseek(FwxFilial("RD0")+Upper(Alltrim(_cLogin))))
									If _cFilPart == RD0->RD0_FILIAL .AND. _cCodPart == RD0->RD0_CODIGO
										_lFinOk := .T.
									EndIf
								ENDIF
							EndIf
						ENDIF
					EndIF

					If _lFinOk
						//If Ascan(_aCodDesp, {|x| Alltrim(x) == Alltrim(_aRetGet[_nX])}) == 0
						If Ascan(_aCodDesp, {|x| Alltrim(x[1]) == Alltrim(_aRetGet[_nX])}) == 0
							If !Empty(_cCodDesp)
								If Alltrim(_cCodDesp) == Alltrim(_aRetGet[_nX])
									//AADD(_aCodDesp, _aRetGet[_nX])
									AADD(_aCodDesp, {_aRetGet[_nX], _cLogin, _aAdto, _aDesp, _aRateio})
								EndIf
							Else
								//AADD(_aCodDesp, _aRetGet[_nX])
								AADD(_aCodDesp, {_aRetGet[_nX], _cLogin, _aAdto, _aDesp, _aRateio})
							EndIf
						EndIf
					EndIf
				EndIf
			Next
		EndIf  */
	ENDIF

	RestArea(_aArea)

Return _aCodDesp


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIWS7FIN

Copastur - Função parar gerar os títulos a pagar de adiantamento e reembolso

@author CM Solutions - Allan Constantino Bonfim
@since  23/02/2020
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FIWS7FIN(_cEmpOri, _cFilOri, _cFilPart, _cCodPart, _lAdto, _lDesp, _cCodDesp, _nValTit)

	Local _lRet 		:= .T.
	Local _cMsgRet		:= ""
	Local _aArea		:= GetArea()
	Local _aRetWs		:= {}
	Local _aRetFin		:= {}
	Local _aDesp		:= {}
	Local _aAdto		:= {}
	Local _nX			:= 0	
	Local _nY			:= 0
	Local _aRet			:= {}
	Local _cMsg			:= ""
	//Local _cMsgRet		:= ""
	Local _cMessage		:= ""
	Local _cCode		:= ""
	Local _cError 		:= ""
	Local _cDetErro		:= ""
	//Local _aCodDesp		:= {}
	Local _aRetTit		:= {}
	//Local _lFinOk		:= .F.
	Local _cLogin		:= ""
	Local _cId			:= ""
	Local _cEmail		:= ""
	Local _cCpf			:= ""
	Local _cAlaEmp		:= ""
	Local _aCCusto		:= {}	
	Local _aTmpCCusto	:= {}
	Local _cFornece 	:= ""
	Local _cLoja		:= ""
	//Local _aRetExec		:= ""
	Local _nVlrTit		:= 0
	Local _nVlrDes		:= 0
	Local _cHist		:= ""
	Local _aMoedas		:= {"BRL", "USD", "UFR", "EUR"}
	Local _aMoedDsc		:= {"R$", "US$", "UFIR", "€"}
	Local _nTamHist		:= TamSx3("E2_HIST")[1]
	Local _cHistTmp		:= ""
	Local _aRetPag		:= {}
	Local _dDataPag
	Local _cTipoPag 	:= ""
	Local _cMoedaPag	:= ""
	Local _cBancoPag	:= ""
	Local _cObsPag		:= ""
	Local _ccPadPag		:= GetNewPar("ZZ_WSALACC", "110401")
	Local _lTitPgOk		:= .F.

	Default _cEmpOri	:= FwCodEmp()
	Default _cFilOri	:= FwCodFil()
	Default _cFilPart	:= ""
	Default _cCodPart	:= ""
	Default _lAdto		:= .F.
	Default _lDesp		:= .F.
	Default _cCodDesp	:= ""
	Default _nValTit	:= 0


	If !Empty(_cCodDesp)
		_aRetWs := U_FINWS07A(,2, _cEmpOri, _cFilOri,,,,, _cCodDesp)
		
		If _aRetWs[1] == "0"
			_aRetFin := _aRetWs[8]
			
			_cId		:= _aRetFin[1][1]
			_cLogin		:= _aRetFin[1][2]
			_cEmail		:= _aRetFin[1][3]
			_cCpf		:= _aRetFin[1][4]
			_cAlaEmp	:= _aRetFin[1][4]
			_aCCusto	:= _aRetFin[1][6]
			//_aTmpCCusto	:= _aRetFin[1][6]
			_aDesp		:= _aRetFin[1][7]
			_aAdto		:= _aRetFin[1][8]
			
			_cFornece 	:= ""//aRetFin[1][1]
			_cLoja		:= ""//aRetFin[1][2]
			//_cCodAlatur	:= _cCodDesp
			_nVlrTit	:= 0
			_nVlrDes	:= 0
			_cHist		:= ""

			DbSelectArea("FL2")
			DbSetOrder(1) //FL2_FILIAL, FL2_BKOEMP, FL2_LICENC
			FL2->(DbSeek(FwxFilial("FL2")+_cEmpOri+_cFilOri))
		
			DbSelectArea("RD0")
			RD0->(DbOrderNickName("RD00000002")) //RD0_FILIAL+RD0_XLOGIN
			If RD0->(Dbseek(FwxFilial("RD0")+Upper(Alltrim(_cLogin))))
				If !Empty(RD0->RD0_FORNEC) .AND. !Empty(RD0->RD0_LOJA)
					_cFornece	:= RD0->RD0_FORNEC
					_cLoja		:= RD0->RD0_LOJA
				EndIf
			EndIf

			If _lAdto .AND. Len(_aAdto) > 0
				_aCCusto := {}

				If !Empty(RD0->RD0_CC)
					If ValidaCusto(RD0->RD0_CC,,,, .F.,.F.)
						AADD(_aCCusto, {RD0->RD0_CC, "100", FL2->FL2_GRPEMP})
					Else
						AADD(_aCCusto, {_ccPadPag, "100", FL2->FL2_GRPEMP})
					EndIf
				Else
					AADD(_aCCusto, {_ccPadPag, "100", FL2->FL2_GRPEMP})
				EndIf
				
				_aTmpCCusto	:= aClone(_aCCusto)
				_lTitPgOk	:= .F.

				Begin Transaction
					For _nX := 1 to Len(_aMoedas)
						_nVlrTit	:= 0
						_cHistTmp	:= ""
						_nMoeda 	:= _nX

						For _nY := 1 to Len(_aAdto)
							If Alltrim(_aAdto[_nY][4]) == _aMoedas[_nX]
								_cHistTmp	+= Upper(Alltrim(_aAdto[_nY][1]))+" "
								_nVlrTit 	+= (VAL(_aAdto[_nY][5]) * VAL(_aAdto[_nY][6]))
							EndIf
						Next

						If _nVlrTit > 0
							//_cHist	:= Substr("ADIANTAMENTO COPASTUR No "+Alltrim(_cCodDesp)+" - "+_cHistTmp, 1, _nTamHist)
							_cHist	:= Substr("ADIANTAMENTO COPASTUR No "+Alltrim(_cCodDesp), 1, _nTamHist)

							If !Empty(_cFornece) .AND. !Empty(_cLoja)
								If Len(_aCCusto) > 0
									//Valor total informado na tela de seleção
									If _nValTit > 0
										If !_lTitPgOk
											FWMsgRun(, {|| _aRetTit := U_FWS07TIT(1, _cFornece, _cLoja,, _cCodDesp,  1, _nValTit, _nVlrDes, _cHist, _aCCusto, RD0->RD0_CC)}, "Integrando os adiantamentos do participante...", RD0->RD0_CODIGO + " - " + ALLTRIM(RD0->RD0_NOME))
											_lTitPgOk := .T.
										EndIf
									Else
										FWMsgRun(, {|| _aRetTit := U_FWS07TIT(1, _cFornece, _cLoja,, _cCodDesp,  _nMoeda, _nVlrTit, _nVlrDes, _cHist, _aCCusto, RD0->RD0_CC)}, "Integrando os adiantamentos do participante...", RD0->RD0_CODIGO + " - " + ALLTRIM(RD0->RD0_NOME))
									EndIf
									
									_aCCusto := aClone(_aTmpCCusto)
									If _aRetTit[1][1]
										If Valtype(_aRetTit[1][3]) == "A"
											_dDataPag 	:= _aRetTit[1][3][1]
											_cTipoPag 	:= _aRetTit[1][3][2]
											_cMoedaPag	:= _aMoedas[_nX]
											_cBancoPag	:= _aRetTit[1][3][4]

											If _nValTit > 0
												//If _aMoedas[_nX] == "BRL"
												//	_cObsPag	:= _aRetTit[1][3][5]
												//Else
												_cObsPag := _aRetTit[1][3][5]+" Valor R$ "+Alltrim(Transform(_nValTit, PesqPict("SE2","E2_VALOR")))
												//EndIf
											Else
												_cObsPag := _aRetTit[1][3][5]+" Valor "+_aMoedDsc[_nX]+" "+Alltrim(Transform(_nVlrTit, PesqPict("SE2","E2_VALOR")))
											EndIF

											_aRetPag := U_FINWS07A(,3, _cEmpOri, _cFilOri, _dDataPag,,,, _cCodDesp, _cTipoPag, _cMoedaPag, _cBancoPag, _cObsPag)

											_aRet := _aRetPag
										EndIf

										//If _nValTit > 0
										//	Exit
										//EndIf
									Else
										//Help(NIL, NIL, "FIWS7FIN", NIL, "Falha na geração do título do adiantamento "+Alltrim(_cCodDesp)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o log de processamento das integrações e tente novamente."})
										_lRet 		:= .F.
										_cMsg		:= ""
										_cMsgRet	:= ""
										_cMessage	:= ""
										_cCode		:= ""
										_cError 	:= "Falha na geração do título a pagar da despesa "+Alltrim(_cCodDesp)
										_cDetErro	:= _aRetTit[1][2]
										
										_aRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 
										
										Exit
									EndIf
								Else
									//Help(NIL, NIL, "FIWS7FIN", NIL, "Centro de custo não informado para a geração do título do adiantamento "+Alltrim(_cCodDesp)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o adiantamento no Copastur e tente novamente."})
									_lRet 		:= .F.
									_cMsg		:= ""
									_cMsgRet	:= ""
									_cMessage	:= ""
									_cCode		:= ""
									_cError 	:= "Centro de custo não informado para a geração do título do adiantamento "+Alltrim(_cCodDesp)+"."
									_cDetErro	:= "Verifique o adiantamento no Copastur e tente novamente." 
									
									_aRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 
														
									Exit
								EndIf
							Else
								//Help(NIL, NIL, "FIWS7FIN", NIL, "Código do fornecedor não informado para a geração do título do adiantamento "+Alltrim(_cCodDesp)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do participante e tente novamente."})
								_lRet 		:= .F.
								_cMsg		:= ""
								_cMsgRet	:= ""
								_cMessage	:= ""
								_cCode		:= ""
								_cError 	:= "Código do fornecedor não informado para a geração do título do adiantamento "+Alltrim(_cCodDesp)
								_cDetErro	:= "Verifique o adiantamento no Copastur e tente novamente." 
								
								_aRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 
				
								Exit
							EndIf
						EndIf
					Next

					If !_lRet
						DisarmTransaction()
						Break
					EndIf
				End Transaction
/*
				Begin Transaction
					
					For _nX := 1 to Len(_aMoedas)
						_nVlrTit	:= 0
						_cHistTmp	:= ""
						_nMoeda 	:= _nX

						For _nY := 1 to Len(_aAdto)
							If Alltrim(_aAdto[_nY][4]) == _aMoedas[_nX]
								_cHistTmp	+= Upper(Alltrim(_aAdto[_nY][1]))+" "
								_nVlrTit 	+= (VAL(_aAdto[_nY][5]) * VAL(_aAdto[_nY][6]))
							EndIf
						Next
						
						//Valor total informado na tela de seleção
						If _nValTit > 0
							_nVlrTit := _nValTit
							_nMoeda  := 1
						EndIf

						If _nVlrTit > 0
							_cHist	:= Substr("ADIANTAMENTO COPASTUR No "+Alltrim(_cCodDesp)+" - "+_cHistTmp, 1, _nTamHist)

							If !Empty(_cFornece) .AND. !Empty(_cLoja)
								If Len(_aCCusto) > 0
									FWMsgRun(, {|| _aRetTit := U_FWS07TIT(1, _cFornece, _cLoja,, _cCodDesp,  _nMoeda, _nVlrTit, _nVlrDes, _cHist, _aCCusto, RD0->RD0_CC)}, "Integrando os adiantamentos do participante...", RD0->RD0_CODIGO + " - " + ALLTRIM(RD0->RD0_NOME))
									
									_aCCusto := aClone(_aTmpCCusto)

									If _aRetTit[1][1]
										If Valtype(_aRetTit[1][3]) == "A"
											_dDataPag 	:= _aRetTit[1][3][1]
											_cTipoPag 	:= _aRetTit[1][3][2]
											_cMoedaPag	:= _aMoedas[_aRetTit[1][3][3]]
											_cBancoPag	:= _aRetTit[1][3][4]
											_cObsPag	:= _aRetTit[1][3][5]

											_aRetPag := U_FINWS07A(,3, _cEmpOri, _cFilOri, _dDataPag,,,, _cCodDesp, _cTipoPag, _cMoedaPag, _cBancoPag, _cObsPag)

											_aRet := _aRetPag
										EndIf

										If _nValTit > 0
											Exit
										EndIf
									Else
										//Help(NIL, NIL, "FIWS7FIN", NIL, "Falha na geração do título do adiantamento "+Alltrim(_cCodDesp)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o log de processamento das integrações e tente novamente."})
										_lRet 		:= .F.
										_cMsg		:= ""
										_cMsgRet	:= ""
										_cMessage	:= ""
										_cCode		:= ""
										_cError 	:= "Falha na geração do título a pagar da despesa "+Alltrim(_cCodDesp)
										_cDetErro	:= _aRetTit[1][2]
										
										_aRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 
										
										Exit
									EndIf
								Else
									//Help(NIL, NIL, "FIWS7FIN", NIL, "Centro de custo não informado para a geração do título do adiantamento "+Alltrim(_cCodDesp)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o adiantamento no Copastur e tente novamente."})
									_lRet 		:= .F.
									_cMsg		:= ""
									_cMsgRet	:= ""
									_cMessage	:= ""
									_cCode		:= ""
									_cError 	:= "Centro de custo não informado para a geração do título do adiantamento "+Alltrim(_cCodDesp)+"."
									_cDetErro	:= "Verifique o adiantamento no Copastur e tente novamente." 
									
									_aRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 
														
									Exit
								EndIf
							Else
								//Help(NIL, NIL, "FIWS7FIN", NIL, "Código do fornecedor não informado para a geração do título do adiantamento "+Alltrim(_cCodDesp)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do participante e tente novamente."})
								_lRet 		:= .F.
								_cMsg		:= ""
								_cMsgRet	:= ""
								_cMessage	:= ""
								_cCode		:= ""
								_cError 	:= "Código do fornecedor não informado para a geração do título do adiantamento "+Alltrim(_cCodDesp)
								_cDetErro	:= "Verifique o adiantamento no Copastur e tente novamente." 
								
								_aRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 
				
								Exit
							EndIf
						EndIf
					Next

					If !_lRet
						DisarmTransaction()
						Break
					EndIf
				End Transaction
				*/
			EndIf

			If _lDesp .AND. Len(_aDesp) > 0
				If Len(_aCCusto) > 0
					For _nX := 1 to Len(_aCCusto)
						If !ValidaCusto(_aCCusto[_nX][1],,,, .F.,.F.) //!CTB105CC(_aCCusto[_nX][1]) //Validação do centro de custo
							If !Empty(RD0->RD0_CC)
								If ValidaCusto(RD0->RD0_CC,,,, .F.,.F.)
									_aCCusto[_nX][1] := RD0->RD0_CC
								Else
									_aCCusto[_nX][1] := _ccPadPag
								EndIf
							Else
								_aCCusto[_nX][1] := _ccPadPag
							EndIf
						EndIf
					Next
				EndIf

				If Len(_aCCusto) == 0
					If !EMpty(RD0->RD0_CC)
						If ValidaCusto(RD0->RD0_CC,,,, .F.,.F.)
							AADD(_aCCusto, {RD0->RD0_CC, "100", FL2->FL2_GRPEMP})
						Else
							AADD(_aCCusto, {_ccPadPag, "100", FL2->FL2_GRPEMP})
						EndIf
					Else
						AADD(_aCCusto, {_ccPadPag, "100", FL2->FL2_GRPEMP})
					EndIf
				ENDIF
				
				_aTmpCCusto	:= ACLONE(_aCCusto)
				_lTitPgOk	:= .F.

				Begin Transaction
					For _nX := 1 to Len(_aMoedas)
						_nVlrTit	:= 0
						_cHistTmp	:= ""
						_nMoeda 	:= _nX

						For _nY := 1 to Len(_aDesp)
							If Alltrim(_aDesp[_nY][4]) == _aMoedas[_nX]
								_cHistTmp	+= Upper(Alltrim(_aDesp[_nY][1]))
								_nVlrTit 	+= (VAL(_aDesp[_nY][5]) * VAL(_aDesp[_nY][6]))
							EndIf
						Next

						If _nVlrTit > 0
							//_cHist	:= Substr("REEMBOLSO COPASTUR No "+Alltrim(_cCodDesp)+" - "+_cHistTmp, 1, _nTamHist)
							_cHist	:= Substr("REEMBOLSO COPASTUR No "+Alltrim(_cCodDesp), 1, _nTamHist)

							If !Empty(_cFornece) .AND. !Empty(_cLoja)
								If Len(_aCCusto) > 0
									If _nValTit > 0
										If !_lTitPgOk
											FWMsgRun(, {|| _aRetTit := U_FWS07TIT(2, _cFornece, _cLoja,, _cCodDesp, 1, _nValTit, _nVlrDes, _cHist, _aCCusto, RD0->RD0_CC)}, "Integrando as despesas do participante...", RD0->RD0_CODIGO + " - " + ALLTRIM(RD0->RD0_NOME))
											_lTitPgOk := .T.
										EndIf
									Else
										FWMsgRun(, {|| _aRetTit := U_FWS07TIT(2, _cFornece, _cLoja,, _cCodDesp, _nMoeda, _nVlrTit, _nVlrDes, _cHist, _aCCusto, RD0->RD0_CC)}, "Integrando as despesas do participante...", RD0->RD0_CODIGO + " - " + ALLTRIM(RD0->RD0_NOME))
									EndIf
									//aRetTit := U_FWS03TIT(_cFornece, _cLoja,, _cCodDesp,  _nVlrTit, _nVlrDes, _cHist, _aCCusto)

									_aCCusto := ACLONE(_aTmpCCusto)

									If _aRetTit[1][1]
										If Valtype(_aRetTit[1][3]) == "A"
											_dDataPag 	:= _aRetTit[1][3][1]
											_cTipoPag 	:= _aRetTit[1][3][2]
											_cMoedaPag	:= _aMoedas[_nX] //_aMoedas[_aRetTit[1][3][3]]
											_cBancoPag	:= _aRetTit[1][3][4]

											If _nValTit > 0
												_cObsPag := _aRetTit[1][3][5]+" Valor R$ "+Alltrim(Transform(_nValTit, PesqPict("SE2","E2_VALOR")))
											Else		
												_cObsPag := _aRetTit[1][3][5]+" Valor "+_aMoedDsc[_nX]+" "+Alltrim(Transform(_nVlrTit, PesqPict("SE2","E2_VALOR")))
											EndIF

											_aRetPag := U_FINWS07A(,3, _cEmpOri, _cFilOri, _dDataPag,,,, _cCodDesp, _cTipoPag, _cMoedaPag, _cBancoPag, _cObsPag)

											_aRet := _aRetPag
										EndIf
									Else
										//Help(NIL, NIL, "FIWS7FIN", NIL, "Falha na geração do título da despesa "+Alltrim(_cCodDesp)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o log de processamento das integrações e tente novamente."})
										_lRet 		:= .F.
										_cMsg		:= ""
										_cMsgRet	:= ""
										_cCode		:= ""
										_cMessage	:= ""
										_cError 	:= "Falha na geração do título a pagar da despesa "+Alltrim(_cCodDesp)
										_cDetErro	:= _aRetTit[1][2]

										_aRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 
									
										Exit
									EndIf
								Else
									//Help(NIL, NIL, "FIWS7FIN", NIL, "Centro de custo não informado para a geração do título da despesa "+Alltrim(_cCodDesp)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique a despesa no Copastur e tente novamente."})
									_lRet 		:= .F.
									_cMsg		:= ""
									_cMsgRet	:= ""
									_cCode		:= ""
									_cMessage	:= ""
									_cError 	:= "Falha na geração do título a pagar da despesa "+Alltrim(_cCodDesp)
									_cDetErro	:= _aRetTit[1][2]
									
									_aRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 
									
									Exit
								EndIf
							Else
								//Help(NIL, NIL, "FIWS7FIN", NIL, "Código do fornecedor não informado para a geração do título da despesa "+Alltrim(_cCodDesp)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do participante e tente novamente."})
								_lRet 		:= .F.
								_cMsg		:= ""
								_cMsgRet	:= ""
								_cCode		:= ""
								_cMessage	:= ""
								_cError 	:= "Código do fornecedor não informado para a geração do título da despesa "+Alltrim(_cCodDesp)
								_cDetErro	:= "Verifique a despesa no Copastur e tente novamente." 
								
								_aRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 
				
								Exit
							EndIf
						EndIf
					Next

					If !_lRet
						//Alert("Disarm")
						//Alert("Disarm")
						DisarmTransaction()
						Break
					EndIf
				End Transaction
/*
				Begin Transaction
					For _nX := 1 to Len(_aMoedas)
						_nVlrTit:= 0

						_cHistTmp	:= ""

						For _nY := 1 to Len(_aDesp)
							If Alltrim(_aDesp[_nY][4]) == _aMoedas[_nX]
								_cHistTmp	+= Upper(Alltrim(_aDesp[_nY][1]))
								_nVlrTit 	+= (VAL(_aDesp[_nY][5]) * VAL(_aDesp[_nY][6]))
							EndIf
						Next

						If _nVlrTit > 0
							_nMoeda := _nX
							_cHist	:= Substr("REEMBOLSO COPASTUR No "+Alltrim(_cCodDesp)+" - "+_cHistTmp, 1, _nTamHist)

							If !Empty(_cFornece) .AND. !Empty(_cLoja)
								If Len(_aCCusto) > 0
									FWMsgRun(, {|| _aRetTit := U_FWS07TIT(2, _cFornece, _cLoja,, _cCodDesp, _nMoeda, _nVlrTit, _nVlrDes, _cHist, _aCCusto, RD0->RD0_CC)}, "Integrando as despesas do participante...", RD0->RD0_CODIGO + " - " + ALLTRIM(RD0->RD0_NOME))
									//aRetTit := U_FWS03TIT(_cFornece, _cLoja,, _cCodDesp,  _nVlrTit, _nVlrDes, _cHist, _aCCusto)

									_aCCusto := _aTmpCCusto

									If _aRetTit[1][1]
										If Valtype(_aRetTit[1][3]) == "A"
											_dDataPag 	:= _aRetTit[1][3][1]
											_cTipoPag 	:= _aRetTit[1][3][2]
											_cMoedaPag	:= _aMoedas[_aRetTit[1][3][3]]
											_cBancoPag	:= _aRetTit[1][3][4]
											_cObsPag	:= _aRetTit[1][3][5]

											_aRetPag := U_FINWS07A(,3, _cEmpOri, _cFilOri, _dDataPag,,,, _cCodDesp, _cTipoPag, _cMoedaPag, _cBancoPag, _cObsPag)

											_aRet := _aRetPag
										EndIf
									Else
										//Help(NIL, NIL, "FIWS7FIN", NIL, "Falha na geração do título da despesa "+Alltrim(_cCodDesp)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o log de processamento das integrações e tente novamente."})
										_lRet 		:= .F.
										_cMsg		:= ""
										_cMsgRet	:= ""
										_cCode		:= ""
										_cMessage	:= ""
										_cError 	:= "Falha na geração do título a pagar da despesa "+Alltrim(_cCodDesp)
										_cDetErro	:= _aRetTit[1][2]

										_aRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 
									
										Exit
									EndIf
								Else
									//Help(NIL, NIL, "FIWS7FIN", NIL, "Centro de custo não informado para a geração do título da despesa "+Alltrim(_cCodDesp)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique a despesa no Copastur e tente novamente."})
									_lRet 		:= .F.
									_cMsg		:= ""
									_cMsgRet	:= ""
									_cCode		:= ""
									_cMessage	:= ""
									_cError 	:= "Falha na geração do título a pagar da despesa "+Alltrim(_cCodDesp)
									_cDetErro	:= _aRetTit[1][2]
									
									_aRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 
									
									Exit
								EndIf
							Else
								//Help(NIL, NIL, "FIWS7FIN", NIL, "Código do fornecedor não informado para a geração do título da despesa "+Alltrim(_cCodDesp)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do participante e tente novamente."})
								_lRet 		:= .F.
								_cMsg		:= ""
								_cMsgRet	:= ""
								_cCode		:= ""
								_cMessage	:= ""
								_cError 	:= "Código do fornecedor não informado para a geração do título do adiantamento "+Alltrim(_cCodDesp)
								_cDetErro	:= "Verifique o adiantamento no Copastur e tente novamente." 
								
								_aRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 
				
								Exit
							EndIf
						EndIf
					Next

					If !_lRet
						//Alert("Disarm")
						//Alert("Disarm")
						DisarmTransaction()
						Break
					EndIf
				End Transaction */
			EndIf			
		Else
			//_cMsgRet	:= "Código da despesa no Copastur não informado. Verifique o parâmetro _cCodDesp da rotina FIWS7FIN"
			//_lRet 		:= .F.
			_aRet 	:= _aRetWs[1]
		EndIf
	Else
	//	_cMsgRet	:= "Código da despesa no Copastur não informado. Verifique o parâmetro _cCodDesp da rotina FIWS7FIN"
	//	_lRet 		:= .F.

		_cMsg		:= ""
		_cMsgRet	:= ""
		_cCode		:= ""
		_cMessage	:= ""
		_cError 	:= "Código da despesa no Copastur não informado."
		_cDetErro	:= "Verifique o parâmetro _cCodDesp da rotina FIWS7FIN"
		
		_aRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 
	EndIf

	//AADD(_aRet, _lRet)
	//AADD(_aRet, _cMsgRet)

	RestArea(_aArea)

Return _aRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} FWS07TIT

Função para a geração do título no contas a pagar

@author  Allan Constantino Bonfim - CM Solutions
@since   25/02/2020
@version P12
@return array, Funções da Rotina
 
/*/
//------------------------------------------------------------------------------
User Function FWS07TIT(_nOpc, _cFornece, _cLoja, _cNumTit, _cNumAlatur,  _nMoeda, _nVlrTit, _nVlrDes, _cHist, _aCC, _cCustoPad)

	Local _aArea		:= GetArea()
	Local _aTit 		:= {}
	Local _lRet			:= .F.
	Local _cRet			:= ""
	Local _aRet			:= {}
	Local _aRetTit		:= {}
	Local _cPrefixo  	:= "" //GetNewPar("MV_RESPREF", "DP") //Define o prefixo dos títulos a pagar dos adiantamentos a participantes, solicitados no Reserve.
	Local _cNaturez		:= "" //GetNewPar("MV_RESNTAD", "5040401")
	Local _dDtVenc		:= dDatabase //dDatabase + 7	
	Local _cTipo		:= "" //GetNewPar("MV_RESTPAD", "DP ") //Define o tipo dos títulos de adiantamentos gerados pelo Sistema.
	Local _nTamPrf		:= TamSx3("E2_PREFIXO")[1]
	//Local _nTamNum		:= TamSx3("E2_NUM")[1]
	Local _nTamHist		:= TamSx3("E2_HIST")[1]
	Local _nTamTipo		:= TamSx3("E2_TIPO")[1]
	Local _nTamNat		:= TamSx3("E2_NATUREZ")[1]
	Local _nTamDesc		:= TamSx3("CTJ_DESC")[1]
	//Local _aAuxSEV		:= {} //Auxiliar para Natureza.
	//Local _aAuxSEZ		:= {} //Auxiliar para Centro de Custo.
	//Local _aRatSEZ		:= {}
	//Local _aRatSEVEZ 	:= {}
	Local _aRateio		:= {}
	Local _aRatTmp		:= {}
	Local _nX			:= 0
	Local _aErroAuto	:= {}
	Local nDiaSoma 		:= 0 
	Local nDiaSem		:= 0
	//Local _nSoma		:= 0
	//Local _nSmVl		:= 0
	Local _cPABco		:= Alltrim(GetNewPar("ZZ_WSALBCO", ""))
	Local _cPAAgencia	:= Alltrim(GetNewPar("ZZ_WSALAGE", ""))
	Local _cPAConta		:= Alltrim(GetNewPar("ZZ_WSALCON", ""))
	Local _cModoPag		:= ""
	Local _cRetObs		:= ""
	Local _nVlrRat		:= 0
	Local _nTotRat		:= 0
	
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	Default _nOpc		:= 0
	Default _cFornece	:= _cFornece
	Default _cLoja		:= _cLoja
	Default _cNumTit	:= ""
	Default _cNumAlatur	:= ""
	Default _nMoeda		:= 1
	Default _nVlrTit	:= 0
	Default _nVlrDes	:= 0
	Default _cHist		:= ""
	Default _aCC		:= {} //{cCC, nValCC, nPorCC, cItem, cClasse} 
	Default _cCustoPad	:= GetNewPar("ZZ_WSALACC", "110401")
   
	If _nOpc > 0
		If !Empty(_cNumAlatur)

			DbSelectArea("SA2")
			SA2->(DbSetOrder(1)) //A2_FILIAL, A2_COD, A2_LOJA
			
			If _nOpc == 1 //Adiantamento
				_cPrefixo  	:= GetNewPar("MV_RESPREF", "ADT") //Define o prefixo dos títulos a pagar dos adiantamentos a participantes, solicitados no Reserve.
				_cNaturez	:= GetNewPar("MV_RESNTAD", "7020202")
				_dDtVenc	:= dDatabase
				_cTipo		:= GetNewPar("MV_RESTPAD", "PA ")

				If Empty(_cHist)
					_cHist := "ADIANTAMENTO COPASTUR No "+ Alltrim(_cNumAlatur)
				EndIf
			ElseIf _nOpc == 2 //Despesas
				//Regra - Pagamentos entregues até terça-feira são pagos na sexta da mesma semana, a partir de quarta-feira já são efetuados na próxima sexta. 
				nDiaSem := Dow(dDatabase)
				
				If nDiaSem > 3 //3=terça-feira
					nDiaSoma := 7
				ENDIF

				nDiaSoma += (6 - nDiaSem)

				_cPrefixo  	:= GetNewPar("MV_RESPFCP", "DP") //Define o prefixo dos títulos a pagar dos adiantamentos a participantes, solicitados no Reserve.
				_cNaturez	:= GetNewPar("MV_RESNTCP", "5040401")
				_dDtVenc	:= dDatabase + nDiaSoma	//MV_RESDIAS
				_cTipo		:= GetNewPar("MV_RESTPPC", "DP ")

				If Empty(_cHist)
					_cHist := "REEMBOLSO DE DESPESAS COPASTUR No "+ Alltrim(_cNumAlatur)
				EndIf
			ENDIF

			DbSelectArea("SE2")
			DbOrderNickName("E2ALATUR") //E2_XALATUR+E2_MOEDA+E2_PREFIXO+E2_TIPO

			If !SE2->(DbSeek(PADR(_cNumAlatur, TamSX3("E2_XALATUR")[1])+PADR(Alltrim(STR(_nMoeda)), TamSX3("E2_MOEDA")[1])+PADR(_cPrefixo, TamSX3("E2_PREFIXO")[1])+PADR(_cTipo, TamSX3("E2_TIPO")[1]))) 
			//If !DbSeek(_cNumAlatur)
			//If !Empty(_cNumTit)
				If !Empty(_cFornece) .AND. !Empty(_cLoja)
					If SA2->(Dbseek(FwxFilial("SA2")+_cFornece+_cLoja))
						If !Empty(SA2->A2_BANCO) .AND. !Empty(SA2->A2_AGENCIA) .AND. !Empty(SA2->A2_NUMCON)
							If !Empty(_nVlrTit)
								If Len(_aCC) > 0
									
									//CM Solutions - Allan Constantino Bonfim - 31/03/2020 - Tratamento para a integração de reembolso educacional
									If Len(_aCC) == 1
										If Alltrim(_aCC[1][1]) $ GetNewPar("ZZ_WSACCRE", "110404")
											_cNaturez 	:= GetNewPar("ZZ_WSANTRE", "5200207")
											_cHist		:= "REEMBOLSO EDUCACIONAL COPASTUR No "+ Alltrim(_cNumAlatur)
										EndIf
									EndIf

									//Gero numero do titulo
									If Empty(_cNumTit)
										_cNumTit := ProxTitulo("SE2", _cPrefixo)
									EndIf
											
									_aTit := {}

									AADD(_aTit , {"E2_NUM"    , _cNumTit /*STRZERO(_cNumTit, _nTamNum, 0)*/	, NIL})
									AADD(_aTit , {"E2_PREFIXO", PADR(_cPrefixo, _nTamPrf)		, NIL})
									AADD(_aTit , {"E2_PARCELA", CRIAVAR("E2_PARCELA")			, NIL})
									AADD(_aTit , {"E2_TIPO"   , PADR(_cTipo, _nTamTipo)			, NIL})
									AADD(_aTit , {"E2_NATUREZ", PADR(_cNaturez, _nTamNat)		, NIL})
									AADD(_aTit , {"E2_FORNECE", _cFornece						, NIL})
									AADD(_aTit , {"E2_LOJA"   , _cLoja							, NIL})
									AADD(_aTit , {"E2_EMISSAO", dDatabase						, NIL})
									AADD(_aTit , {"E2_VENCTO" , _dDtVenc						, NIL})
									AADD(_aTit , {"E2_VENCREA", DataValida(_dDtVenc, .T.)		, NIL})
									AADD(_aTit , {"E2_EMIS1"  , dDatabase						, NIL})
									AADD(_aTit , {"E2_MOEDA"  , _nMoeda							, NIL})               
									AADD(_aTit , {"E2_VALOR"  , _nVlrTit						, NIL})
									AADD(_aTit , {"E2_DESCONT", _nVlrDes						, NIL})
									AADD(_aTit , {"E2_DECRESC", _nVlrDes						, NIL})
									AADD(_aTit , {"E2_VALLIQ" , (_nVlrTit - _nVlrDes)			, NIL})
									AADD(_aTit , {"E2_ORIGEM" , "FINA050"                       , NIL})	
									AADD(_aTit , {"E2_HIST"   , Substr(_cHist, 1, _nTamHist)	, Nil})
									AADD(_aTit , {"E2_XALATUR", _cNumAlatur						, Nil})
									/*
									If SA2->(DbSeek(FwxFilial("SA2")+_cFornece+_cLoja))
										AADD(_aTit , {"E2_FORBCO", SA2->A2_XBANCOR					, Nil})
										AADD(_aTit , {"E2_FORAGE", SA2->A2_XAGENCR					, Nil})
										AADD(_aTit , {"E2_FORCTA", SA2->A2_XCONTAR					, Nil})
									ENDIF
									*/
									If Alltrim(_cTipo) == "PA"
										AADD(_aTit , {"AUTBANCO" 	, _cPABco 		, NIL })
										AADD(_aTit , {"AUTAGENCIA" 	, _cPAAgencia	, NIL })
										AADD(_aTit , {"AUTCONTA" 	, _cPAConta		, NIL })
									EndIf
				
									If Len(_aCC) == 1
										AADD(_aTit , {"E2_RATEIO" 	, "N"			, Nil})
										AADD(_aTit , {"E2_CCUSTO" 	, _aCC[1][1]	, Nil}) //TROCAR
										AADD(_aTit , {"E2_CCD" 		, _aCC[1][1]	, Nil}) //"110501"
										//aAdd(_aTit	, {"E2_ITEMCTA" , _aCC[1][4] , Nil}) 
										//aAdd(_aTit	, {"E2_CLVL"   	, _aCC[1][5] , Nil}) 	
									Else
										//CM Solutions - Allan Constantino Bonfim - 17/11/2020 - CHAMADO 34670 - Ajuste para corrigir erro do rateio por centro de custos que dava diferença de 0,01.
										_nTotRat := _nVlrTit - _nVlrDes

										AADD(_aTit , {"E2_RATEIO" 	, "S"			, Nil})

										For _nX := 1 To Len(_aCC)		   
											//Tratamento para preencher a obrigatoriedade do campo E2_CCD
											If _nX == 1
												AADD(_aTit , {"E2_CCD" 		, _cCustoPad, Nil}) //"110501"
											EndIf
											
											//CM Solutions - Allan Constantino Bonfim - 17/11/2020 - CHAMADO 34670 - Ajuste para corrigir erro do rateio por centro de custos que dava diferença de 0,01.
											_nVlrRat := Round(((_nVlrTit - _nVlrDes) * Val(_aCC[_nX][2]) /100), 2)
											
											If _nX == Len(_aCC)	
												If _nTotRat - _nVlrRat <> 0
													_nVlrRat := _nTotRat
												EndIf
											Else
												_nTotRat -= _nVlrRat
											EndIf

											AADD(_aRatTmp, {"CTJ_CCD" 		, _aCC[_nX][1] , Nil})//centro de custo da natureza "110501"
											//AADD(_aRatTmp, {"CTJ_ZZCCD" 	, _aCC[_nX][1] , Nil}) 
											AADD(_aRatTmp, {"CTJ_PERCEN"   	, VAL(_aCC[_nX][2]) , NIl})
											AADD(_aRatTmp, {"CTJ_VALOR"   	, _nVlrRat , NIl})
											AADD(_aRatTmp, {"CTJ_DESC"		, Substr(_cHist, 1, _nTamDesc) , NIl})
											//aAdd(_aAuxSEZ, {"EZ_VALOR"  	, Round((_nVlrTit / _aCC[_nX][2]), 2) , Nil})//valor do rateio neste centro de custo
											//aAdd(_aAuxSEZ, {"EZ_ITEMCTA"	, _aCC[_nX][4] , Nil})		
											//aAdd(_aAuxSEZ, {"EZ_CLVL"   	, _aCC[_nX][5] , Nil})

											AADD(_aRateio	, aClone(_aRatTmp))
											aSize(_aRatTmp	, 0)

											_aRatTmp := {}
										Next
									EndIf
								
									//Chamada da rotina automatica 3 = inclusao
									MsExecAuto({ |a,b,c| FINA050(a,,b,,,,,c)}, _aTit, 3, _aRateio) 
									If lMsErroAuto
										_aErroAuto := GetAutoGrLog()

										For _nX := 1 To Len(_aErroAuto)
											_cRet += _aErroAuto[_nX]+" "+CHR(10)
										Next

										/*
										If !IsBlind()
											MOSTRAERRO()
										Else
											_aErroAuto 	:= GetAutoGRLog()
											_cRet		:= ""
											
											For _nX := 1 To Len(_aErroAuto)
												_cRet += _aErroAuto[_nX]
											Next
										EndIf

										lMsErroAuto := .F.
										*/
										_lRet 	:= .F.
									Else
										_lRet := .T.

										AADD(_aRetTit, DataValida(_dDtVenc, .T.))
										AADD(_aRetTit, IIF(_nOpc == 1, "A", "R"))
										AADD(_aRetTit, _nMoeda)
										
										If _nOpc == 1
											_cModoPag 	:= GetNewPar("ZZ_WSABCPG", "TRANSFERENCIA") 
											_cRetObs	:= "Pagamento realizado ao participante diretamente no depto. financeiro. Titulo a pagar no Protheus No "+ Alltrim(_cNumTit) + " Prefixo "+ Alltrim(_cPrefixo)+" Tipo "+Alltrim(_cTipo)
										Else
											_cModoPag 	:= GetNewPar("ZZ_WSPBCPG", "TRANSFERENCIA") 
											_cRetObs	:= "Pagamento provisionado para a conta corrente. Banco "+Alltrim(SE2->E2_FORBCO)+" Agencia "+Alltrim(SE2->E2_FORAGE)+" Conta "+Alltrim(SE2->E2_FORCTA)+". Titulo a pagar no Protheus No "+ Alltrim(_cNumTit) + " Prefixo "+ Alltrim(_cPrefixo)+" Tipo "+Alltrim(_cTipo)
										EndIf
									
										AADD(_aRetTit, _cModoPag)

										AADD(_aRetTit, _cRetObs)
									EndIf
								Else
									_lRet 	:= .F.
									_cRet	:= "Centro de custo não informado (_aCC). Verifique o parâmetro da função FWS03TIT."				
								EndIf
							Else
								_lRet 	:= .F.
								_cRet	:= "Valor do título não informado (_nVlrTit). Verifique o parâmetro da função FWS03TIT."			
							EndIf
						Else
							_lRet 	:= .F.
							_cRet	:= "O fornecedor "+Alltrim(SA2->A2_COD)+"/"+Alltrim(SA2->A2_LOJA)+" - "+Alltrim(SA2->A2_NOME)+" não possui dados bancários cadastrado. Verifique o cadastro do fornecedor."			
						EndIf
					Else
						_lRet 	:= .F.
						_cRet	:= "Código do fornecedor vinculado ao participante não foi localizado no cadastro de fornecedores ("+Alltrim(_cFornece)+"/"+Alltrim(_cLoja)+"). Verifique o cadastro do participante."			
					EndIf
				Else
					_lRet 	:= .F.
					_cRet	:= "Código do fornecedor e/ou loja não informado (_cFornece / _cLoja). Verifique o parâmetro da função FWS03TIT."
				EndIf
			Else

				_lRet 	:= .T.

				AADD(_aRetTit, DataValida(_dDtVenc, .T.))
				AADD(_aRetTit, IIF(_nOpc == 1, "A", "R"))
				AADD(_aRetTit, _nMoeda)
				
				If _nOpc == 1
					_cModoPag 	:= GetNewPar("ZZ_WSABCPG", "TRANSFERENCIA") 
					_cRetObs	:= "Pagamento realizado ao participante diretamente no depto. financeiro. Titulo a pagar no Protheus No "+ Alltrim(SE2->E2_NUM) + " - Prefixo "+ Alltrim(SE2->E2_PREFIXO)+" - Tipo "+Alltrim(SE2->E2_TIPO)
				Else
					_cModoPag 	:= GetNewPar("ZZ_WSPBCPG", "TRANSFERENCIA") 
					_cRetObs	:= "Pagamento provisionado para a conta corrente. Banco "+Alltrim(SE2->E2_FORBCO)+" Agencia "+Alltrim(SE2->E2_FORAGE)+" Conta "+Alltrim(SE2->E2_FORCTA)+". Titulo a pagar no Protheus No "+ Alltrim(_cNumTit) + " Prefixo "+ Alltrim(_cPrefixo)+" Tipo "+Alltrim(_cTipo)
				EndIf
			
				AADD(_aRetTit, _cModoPag)

				//_cRetObs := U_FINWSESP(_cHist+" "+" - DADOS DO TITULO (No "+ Alltrim(SE2->E2_NUM) + " - Prefixo "+ Alltrim(SE2->E2_PREFIXO)+" - Tipo "+Alltrim(SE2->E2_TIPO)+") - DADOS DO PAGAMENTO ("+_cBcoPag+")")
				AADD(_aRetTit, _cRetObs)
			EndIf
		EndIf
	EndIf

	AADD(_aRet, {_lRet, _cRet, _aRetTit})

	RestArea(_aArea)

	aSize(_aCC, 0)
//	aSize(_aAuxSEV, 0)		
//	aSize(_aAuxSEZ, 0)		
//	aSize(_aRatSEZ, 0)		
//	aSize(_aRatSEVEZ, 0)

Return _aRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIN7WS05

Copastur - Rotina para a integração das despesas via job

@author CM Solutions - Allan Constantino Bonfim
@since  09/03/2020
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FIN7WS05(_cIntOpcao, _cEmpAtu, _cFilAtu)

	Local _aArea		:= GetArea()
	Local _lRet			:= .T.
	Local _aRet			:= {}
	Local _nX			:= 0
	Local _cATmpDesp

	Default _cIntOpcao	:= "2"
	Default _cEmpAtu	:= FwCodEmp()
	Default _cFilAtu	:= FwCodFIl()


	If Select(_cATmpDesp) > 0
		(_cATmpDesp)->(DbCloseArea())
	EndIf
	
	If _cIntOpcao == "2"
		_cATmpDesp	:= U_FIWS3TMP(2,, {"2", "", "", ""}, "5")
		If Select(_cATmpDesp) > 0 .AND. !(_cATmpDesp)->(EOF())
			(_cATmpDesp)->(DbGotop())
			DbSelectArea((_cATmpDesp)->ZWQ_CALIAS)
			DbSetOrder((_cATmpDesp)->ZWQ_INDICE) //RD0_FILIAL+RD0_CODIGO
			WHile !(_cATmpDesp)->(EOF())
				If RD0->(Dbseek((_cATmpDesp)->ZWQ_FILALI+(_cATmpDesp)->ZWQ_CHAVE))
					FWMsgRun(, {|| _lRet := U_FINWS03P(RD0->RD0_EMPATU, RD0->RD0_FILATU, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO,, "5")}, "Processando Despesas...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
				EndIf
				(_cATmpDesp)->(DbSkip())
			EndDo
		EndIf
	Else
		FWMsgRun(, {|| _aRet := U_FIWS7FAL(_cEmpAtu, _cFilAtu,,, .F., .T.)}, "Aguarde", "Consultando as despesas pendentes no Copastur")
		If Len(_aRet) > 0
			DbSelectArea("RD0")
			DbOrderNickName("RD00000002") //RD0_FILIAL+RD0_XLOGIN
			
			For _nX := 1 to Len(_aRet)
				If RD0->(Dbseek(FwxFilial("RD0")+Upper(Alltrim(_aRet[_nX][2]))))
					FWMsgRun(, {|| _lRet := U_FINWS05I(_cEmpAtu, _cFilAtu, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "1", "5", _aRet[_nX][1],, "1")}, "Integrando Despesas...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
					FWMsgRun(, {|| _lRet := U_FINWS03P(_cEmpAtu, _cFilAtu, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO,, "5")}, "Processando Despesas...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
				EndIf	
			Next
		EndIf 

		If Select(_cATmpDesp) > 0
			(_cATmpDesp)->(DbCloseArea())
		EndIf
		
		_cATmpDesp	:= U_FIWS3TMP(2,, {"2", "", "", ""}, "5")
		If Select(_cATmpDesp) > 0 .AND. !(_cATmpDesp)->(EOF())
			(_cATmpDesp)->(DbGotop())
			DbSelectArea((_cATmpDesp)->ZWQ_CALIAS)
			DbSetOrder((_cATmpDesp)->ZWQ_INDICE) //RD0_FILIAL+RD0_CODIGO
			WHile !(_cATmpDesp)->(EOF())
				If RD0->(Dbseek((_cATmpDesp)->ZWQ_FILALI+(_cATmpDesp)->ZWQ_CHAVE))
					FWMsgRun(, {|| _lRet := U_FINWS03P(RD0->RD0_EMPATU, RD0->RD0_FILATU, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO,, "5")}, "Processando Despesas...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
				EndIf
				(_cATmpDesp)->(DbSkip())
			EndDo
		EndIf
	EndIf

	If Select(_cATmpDesp) > 0
		(_cATmpDesp)->(DbCloseArea())
	EndIf
	
	RestArea(_aArea)

Return _lRet

/*
User Function ALLAN2()

Local _aRet := {}
Local _nX	:= 0
Local _cAla	:= ""

	ALERT("EMPRESA 01")
	_cAla	:= ""
	_aRet := U_FIWS7FAL("01", "01",,, .F., .T.)
	For _nX := 1  to Len(_aRet)
		_cAla += _aRet[_nX][1]+" "
	Next
	ALERT("EMPRESA 01 - "+_cAla)
	ALERT("EMPRESA 02")
	_cAla	:= ""
	_aRet := U_FIWS7FAL("02", "01",,, .F., .T.)
	For _nX := 1  to Len(_aRet)
		_cAla += _aRet[_nX][1]+" "
	Next
	ALERT("EMPRESA 02 - "+_cAla)
	ALERT("EMPRESA 03")
	_cAla	:= ""
	_aRet := U_FIWS7FAL("03", "01",,, .F., .T.)
	For _nX := 1  to Len(_aRet)
		_cAla += _aRet[_nX][1]+" "
	Next
	ALERT("EMPRESA 03 - "+_cAla)
Return
*/
