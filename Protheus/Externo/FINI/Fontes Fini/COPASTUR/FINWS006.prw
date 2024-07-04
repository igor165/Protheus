#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINWS006

Copastur - Webservice ApprovalService - Aprovação

@author CM Solutions - Allan Constantino Bonfim
@since  18/12/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FINWS006(_cWSMetodo, _cWSRequest, _aWSRequest, _cEmpXML, _cFilXML, _lExclusiv)

	Local _aArea		:= GetArea()
	Local _cURL    		:= GETNEWPAR("ZZ_FWS6URL", "https://altjtb0065.alatur.com/ApprovalService.svc?wsdl")
	Local _cUserWS		:= ""
	Local _cPassWS		:= ""
	Local _cMsg     	:= ""
	Local _cMsgRet  	:= ""
	Local _cError   	:= ""
	Local _cDetErro		:= ""
	Local _cWarning  	:= ""
	Local _oWsdl     	:= NIL
	Local _oXmlRet		:= NIL
	Local _nX			:= 0
	Local _aWSRet		:= ARRAY(8)
	Local _cUrlRet		:= ""
	Local _cCode		:= ""
	Local _cMessage		:= ""
	Local _oWSRet		:= NIL
	Local _aRetList		:= {}
	Local _cPrefWs		:= "tem"//"ws:"
	Local _cPrefReq		:= "int" //"web:"

	Default _cWSMetodo	:= ""
	Default _cWSRequest	:= ""
	Default _aWSRequest	:= {}												
	Default _cEmpXML	:= FwCodEmp()
	Default _cFilXML	:= FwFilEmp()
	Default _lExclusiv	:= .F.
	
	
	If !Empty(_cWSMetodo) .AND. !Empty(_aWSRequest)
		If !Empty(_cEmpXML) .AND. !Empty(_cFilXML)
			If _lExclusiv
				RPCSetType(3)
				RpcSetEnv(_cEmpXML, _cFilXML,,,, GetEnvServer(), {})				
			EndIf		
		
			_aArea		:= GetArea()
		//_cLockName	:= _cRotina+_cEmpXML+_cFilXML
	
		//If LockByName(_cLockName, .T., .F.)		
			
			If GETNEWPAR("ZZ_WSALATU", .F.)
				DbSelectArea("FL2") //Cadastro empresas Copastur
				DbSetOrder(1) //FL2_FILIAL, FL2_BKOEMP, FL2_LICENC	
				If FL2->(DbSeek(FwxFilial("FL2")+_cEmpXML+_cFilXML))				
					_cUserWS		:= ALLTRIM(FL2->FL2_USER)
					_cPassWS		:= ALLTRIM(FL2->FL2_PSWRES)
							
					//Instância a classe, setando as parâmetrizações necessárias
					_oWsdl := TWsdlManager():New()
					
					//Se houver mensagem definida, envia a mensagem. Do contrário, mostra o erro do objeto.
					_oWsdl:lVerbose := .T.
					_oWsdl:SetAuthentication(_cUserWS, _cPassWS)
					_oWsdl:lSSLInsecure 	:= .T.
					_oWsdl:nSSLVersion		:= 0		
					_oWsdl:nTimeout			:= 120
					_oWsdl:lProcResp		:= .F. //Não processa o retorno automaticamente no objeto (será tratado através do método GetSoapResponse)
					_oWsdl:lRemEmptyTags	:= .T.
						
					//Tenta fazer o Parse da URL		
					If _oWsdl:ParseURL(_cURL)		
						//Tenta definir a operação
						If _oWsdl:SetOperation(_cWSMetodo)
							If Alltrim(_cWSMetodo) $ "get"
								_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">'
							ElseIf Alltrim(_cWSMetodo) $ "list/disable"
								//_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.root" xmlns:web="http://webservice.models.root">'										
								_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:int="http://schemas.datacontract.org/2004/07/IntegracaoBRF.Model.Request">'
							Else
								_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:int="http://schemas.datacontract.org/2004/07/IntegracaoBRF.Model">'
							EndIf

							_cMsg += '<soapenv:Header/>'
							_cMsg += '<soapenv:Body>'
							_cMsg += '<'+_cPrefWs+':'+_cWSMetodo+'>'
							_cMsg += '<'+_cPrefWs+':client_name>'+_cUserWS+'</'+_cPrefWs+':client_name>'
							_cMsg += '<'+_cPrefWs+':client_password>'+_cPassWS+'</'+_cPrefWs+':client_password>'
							
							If !Empty(_cWSRequest)
								_cMsg += '<'+_cPrefWs+':'+_cWSRequest+'>'
							EndIf										
		
							For _nX := 1 to Len(_aWSRequest)
								If _nX < 13
									_cMsg += '<'+ALLTRIM(_aWSRequest[_nX][1])+'>'+_aWSRequest[_nX][2]+'</'+ALLTRIM(_aWSRequest[_nX][1])+'>'
								else
									If _nX == 13
										_cMsg += '<'+_cPrefReq+':approvers>'
										_cMsg += '<'+_cPrefReq+':Approver>'
									EndIf

									_cMsg += '<'+ALLTRIM(_aWSRequest[_nX][1])+'>'+_aWSRequest[_nX][2]+'</'+ALLTRIM(_aWSRequest[_nX][1])+'>'

									If _nX == 17
										_cMsg += '</'+_cPrefReq+':Approver>'
										_cMsg += '</'+_cPrefReq+':approvers>'
									EndIf
								EndIF
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
								_cMsgRet 	:= _oWsdl:GetSoapResponse()
								_cError	:= ""
								_cWarning	:= ""
													
								//Transforma a resposta em um objeto
								_oXmlRet := XmlParser(_cMsgRet, "_", @_cError, @_cWarning)
									
								If Empty(_cError)
									_cUrlRet := "_oXmlRet:_S_ENVELOPE:_S_BODY:_"+Upper(Alltrim(_cWSMetodo))+"RESPONSE:_"+Upper(Alltrim(_cWSMetodo))+"RESULT"
				
									If Alltrim(_cWSMetodo) $ "list"
										If AttIsMemberOf(&_cUrlRet, "_A_APPROVALS_LIST")
											_cUrlRet += ":_A_APPROVALS_LIST"
											If !Valtype(&_cUrlRet) = "A"
												XmlNode2Arr(&_cUrlRet, "_A_APPROVALS_LIST")
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
												
												If _cMessage == "OK"	.OR. _cCode == "OK"																																			
													If AttIsMemberOf(_oWSRet[_nX], "_A_APPROVAL_ID") 
														AADD(_aRetList, _oWSRet[_nX]:_A_APPROVAL_ID:TEXT) 
													EndIf
												ElseIf Alltrim(_cWSMetodo) $ "list" .AND. (Empty(_cMessage) .OR. Empty(_cCode))
													If AttIsMemberOf(_oWSRet[_nX], "_A_APPROVAL_ID") 
														AADD(_aRetList, _oWSRet[_nX]:_A_APPROVAL_ID:TEXT) 
													EndIf
												Else
													_cError		:= _oWSRet[_nX]:_A_MESSAGE:TEXT
													_cDetErro	:= "Erro no consumo do webservice"	
												EndIf
											ElseIf Alltrim(_cWSMetodo) $ "list" .AND. (Empty(_cMessage) .OR. Empty(_cCode))
												If AttIsMemberOf(_oWSRet[_nX], "_A_APPROVAL_ID") 
													AADD(_aRetList, _oWSRet[_nX]:_A_APPROVAL_ID:TEXT) 
												EndIf	
											Else
												_cCode		:= ""									
												_cError		:= "Atributo _A_MESSAGE e/ou _A_CODE não encontrado no retorno do webservice." 												
											EndIf
										Next

										If _cMessage == "OK" .OR. _cCode == "OK"																																			
											_aWSRet := {"0", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList}
										ElseIf Alltrim(_cWSMetodo) $ "list" .AND. (Empty(_cMessage) .OR. Empty(_cCode))
											_aWSRet := {"0", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList}
										Else
											_aWSRet := {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList}
										EndIf

									Else

										If AttIsMemberOf(_oWSRet, "_A_MESSAGE") .AND. AttIsMemberOf(_oWSRet, "_A_CODE")
											_cCode		:= _oWSRet:_A_CODE:TEXT
											_cMessage	:= _oWSRet:_A_MESSAGE:TEXT
											_cError		:= ""
											_cDetErro	:= ""
											
											If _cMessage == "OK"	.OR. _cCode == "OK"																																			
												_aWSRet := {"0", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList}
											ElseIf Alltrim(_cWSMetodo) $ "list" .AND. (Empty(_cMessage) .OR. Empty(_cCode))
												If AttIsMemberOf(_oWSRet, "_A_APPROVAL_ID") 
													AADD(_aRetList, _oWSRet:_A_APPROVAL_ID:TEXT) 
												EndIf

												_aWSRet := {"0", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList}																								
											Else
												_cError		:= _oWSRet:_A_MESSAGE:TEXT
												_cDetErro	:= "Erro no consumo do webservice"
											
												_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList}
											EndIf
										ElseIf Alltrim(_cWSMetodo) $ "list" .AND. (Empty(_cMessage) .OR. Empty(_cCode))
											If AttIsMemberOf(_oWSRet, "_A_APPROVAL_ID") 
												AADD(_aRetList, _oWSRet:_A_APPROVAL_ID:TEXT) 
											EndIf	
											_aWSRet := {"0", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro, _aRetList}																																														
										Else
											_aRetList	:= {}
											_cCode		:= ""									
											_cError		:= "Atributo _A_MESSAGE e/ou _A_CODE não encontrado no retorno do webservice."
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
									_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 											
								EndIf	
							Else
								_cMsgRet	:= ""
								_cCode		:= ""
								_cError 	:= "Erro no SendSoapMsg do webservice."
								_cDetErro	:= _oWsdl:cError + " Erro SendSoapMsg FaultCode: " + _oWsdl:cFaultCode
								
								_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 																																				
							EndIf
						Else	
							_cMsg		:= ""
							_cMsgRet	:= ""
							_cCode		:= ""
							_cError 	:= "Erro na consulta do webservice SetOperation ("+_cWSMetodo+")."
							_cDetErro	:= _oWsdl:cError
							
							_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 															
						EndIf			
					Else
						_cMsg		:= ""
						_cMsgRet	:= ""
						_cCode		:= ""
						_cError 	:= "Erro na consulta do webservice ParseURL ("+_cURL+")."
						_cDetErro	:= _oWsdl:cError
						
						_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 					 								
					EndIf		
				Else
					_cMsg		:= ""
					_cMsgRet	:= ""
					_cCode		:= ""
					_cError 	:= "Empresa("+_cEmpXML+") / Filial ("+_cFilXML+") não localizada no cadastro de empresas Copastur."
					_cDetErro	:= ""
					
					_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 					
				EndIf
			Else
				_cMsg		:= ""
				_cMsgRet	:= ""
				_cCode		:= ""
				_cError 	:= "Integração com o Copastur desativada."
				_cDetErro	:= ""
				
				_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage,  _cError, _cDetErro} 				
			EndIf	
		Else
			_cMsg		:= ""
			_cMsgRet	:= ""
			_cCode		:= ""
			_cError 	:= "Empresa / Filial não informada."
			_cDetErro	:= ""
			
			_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage,  _cError, _cDetErro} 
		EndIf
	Else
		_cMsg		:= ""
		_cMsgRet	:= ""
		
		_cCode		:= ""
		_cError 	:= "Parâmetros método e request para a pesquisa no webservice não informados."
		_cDetErro	:= ""
		
		_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro}	
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
/*/{Protheus.doc} FINWS06A

Copastur - Webservice ApprovalService - Aprovação

@author CM Solutions - Allan Constantino Bonfim
@since  18/12/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FINWS06A(_nOpcA, _cEmpOri, _cFilOri, _nRD0Indice, _cRD0FilChv, _cRD0Chave, _nTpAprov, _cIdAprov, _aDadosReq)
	
	Local _aArea		:= GetArea()
	Local _aRetPrc		:= ARRAY(7) 
	Local _aRequest 	:= {}
	Local _cNomeEmp 	:= ""	
	Local _lContinua 	:= .T.
	Local _cEmail		:= ""
	Local _cEmailPart	:= ""
	Local _cMsgVld		:= ""
	Local _cPartChave	:= ""
	Local _cEmailUsr	:= ""
	Local _cCodeEmp		:= ""
	Local _cActive		:= "1"
	Local _cViagInter	:= ""
	Local _cViagNacio	:= ""
	Local _cAprovId		:= ""
	Local _cPrefReq		:= "int" //"web:"

	Default _nOpcA		:= 0
	Default _cEmpOri	:= FwCodEmp()
	Default _cFilOri	:= FwCodFil()
	Default _nRD0Indice	:= 1 
	Default _cRD0FilChv	:= ""
	Default _cRD0Chave	:= ""
	Default _nTpAprov	:= 1
	Default _cIdAprov	:= ""
	Default _aDadosReq	:= {}
	

	If Len(_aDadosReq) > 0
		_lContinua := .T.
	ElseIf !Empty(_cRD0Chave)
		_lContinua := .T.

		DbSelectArea("FL2") //Cadastro empresas Copastur
		DbSetOrder(1) //FL2_FILIAL, FL2_BKOEMP, FL2_LICENC

		DbSelectArea("RD0") //Cadastro Participantes
		DbSetOrder(_nRD0Indice) //RD0_FILIAL+RD0_CODIGO
		
		If RD0->(DbSeek(_cRD0FilChv+_cRD0Chave))	
			If RD0->RD0_MSBLQL == "1"	
				_lContinua := .F.
				_aRetPrc 	:= {"1", "", "", "", "", "Participante bloqueado.", "Participante ("+_cRD0Chave+") bloqueado no cadastro de participantes (RD0)."}
			ElseIf Empty(RD0->RD0_EMAIL)
				_lContinua := .F.
				_aRetPrc 	:= {"1", "", "", "", "", "Participante com cadastro inválido.", "Participante ("+_cRD0Chave+") sem e-mail (RD0_EMAIL) no cadastro de participantes (RD0)."}
			ElseIf Empty(RD0->RD0_XLOGIN)
				_lContinua := .F.
				_aRetPrc 	:= {"1", "", "", "", "", "Participante com cadastro inválido.", "Participante ("+_cRD0Chave+") sem login (RD0_XLOGIN) no cadastro de participantes (RD0)."}
			Else
				If !FL2->(DbSeek(FwxFilial("FL2")+_cEmpOri+_cFilOri))
					_lContinua := .F.
					_aRetPrc 	:= {"1", "", "", "", "", "Empresa do participante não cadastrada no Copastur.", "Empresa ("+_cEmpOri+") / Filial ("+_cFilOri+") não localizada no cadastro de empresas Copastur. Verifique o cadastro da empresa (FL2)."}
				Else			
					If !Empty(RD0->RD0_APROPC)
						_cEmailUsr	:= RD0->RD0_EMAIL
						_cPartChave	:= _cRD0FilChv+_cRD0Chave
						//_cRD0Chave 	:= RD0->RD0_APROPC
						
						If RD0->(DbSeek(_cRD0FilChv+RD0->RD0_APROPC))
							If RD0->RD0_MSBLQL == "1"	
								_lContinua := .F.
								_aRetPrc 	:= {"1", "", "", "", "", "Aprovador bloqueado.", "Aprovador ("+RD0->RD0_APROPC+") bloqueado no cadastro de participantes (RD0)."}
							Else
								If !FL2->(DbSeek(FwxFilial("FL2")+_cEmpOri+_cFilOri))
									_lContinua := .F.
									_aRetPrc 	:= {"1", "", "", "", "", "Empresa do aprovador não cadastrada no Copastur.", "Empresa ("+_cEmpOri+") / Filial ("+_cFilOri+") não localizada no cadastro de empresas Copastur. Verifique o cadastro da empresa (FL2)."}
								EndIf			
							EndIf
						Else
							_lContinua := .F.
							_aRetPrc 	:= {"1", "", "", "", "", "Aprovador não localizado.", "Aprovador ("+RD0->RD0_APROPC+") não localizada no cadastro de participantes (RD0)."}
						EndIf
					Else
						_lContinua := .F.
						_aRetPrc 	:= {"1", "", "", "", "", "Aprovador do participante não localizado.", "Participante ("+_cRD0Chave+") não contém um aprovador válido no cadastro de participantes (RD0)."}
					EndIf
				EndIf
			EndIf
		Else
			_lContinua := .F.
			_aRetPrc 	:= {"1", "", "", "", "", "Participante não localizado.", "Participante ("+_cRD0Chave+") não localizada no cadastro de participantes (RD0)."}
		EndIf
	Else 
		_lContinua := .F.
		_aRetPrc 	:= {"1", "", "", "", "", "Parâmetros do participante não localizado.", "Necessário o envio da chave / dados da requisição para processamento."}
	EndIf

	If _lContinua	
		//Campos Obrigatórios
		If _nTpAprov == 1  //Aprovadores de Adiantamento
			_cAprAdian	:= IIF (RD0->RD0_XAPADT == "S", "1", "0")
			_cAprConfe	:= "0"
			_cAprViInt	:= "0"
			_cAprViNac	:= "0"
			_cAprReemb	:= "0"
			_cAprovId	:= _cIdAprov
		Else //Aprovadores de Viagem Nacional, Internacional, Conferência e Reembolso
			_cAprAdian	:= "0"
			_cAprConfe	:= IIF (RD0->RD0_XAPCNF == "S", "1", "0")
			_cAprViInt	:= IIF (RD0->RD0_XAPINT == "S", "1", "0")
			_cAprViNac	:= IIF (RD0->RD0_XAPNAC == "S", "1", "0")
			_cAprReemb	:= IIF (RD0->RD0_XAPREE == "S", "1", "0")
		EndIf

		_cAprMerit	:= "0" //IIF (RD0->RD0_XAPMER == "S", "0", "1")
		_cAprNivel	:= "0" //IIF (RD0->RD0_XAPNIV == "S", "0", "1")
		_cAprParal	:= "0" //IIF (RD0->RD0_XAPPAR == "S", "0", "1")
		_cAprPagto	:= "0" //IIF (RD0->RD0_XAPPAG == "S", "0", "1")
		_cAprSeque	:= "0" //IIF (RD0->RD0_XAPSEQ == "S", "0", "1")
		_cAprUnica	:= "1" //IIF (RD0->RD0_XAPUNI == "S", "0", "1")
		_cAprSegNi	:= "0" //IIF (RD0->RD0_XAPSEG == "S", "0", "1")
		_cAprOrdem	:= "1" //IIF (RD0->RD0_XAPORD == "S", "0", "1")
		_cEmail		:= ALLTRIM(RD0->RD0_EMAIL) 

		//Campos Opicionais
		_cCCusto	:= "" //ALLTRIM(RD0->RD0_CC)	
		_cAprLista	:= "0" //IIF (RD0->RD0_XAPLST == "S", "0", "1")
		_cValLimit	:= "0" //RD0->RD0_XAPLIM		
		_cNomeEmp	:= ""//ALLTRIM(FL2->FL2_GRPEMP)
		_cCodeEmp	:= ""
		_cEmailPart	:= ALLTRIM(_cEmailUsr)
		_cOvewrite	:= "1" //overwrite
		_cActive	:= "1"
		_cViagInter	:= ""
		_cViagNacio	:= ""

		//Validação campos obrigatórios
		If _nOpcA == 1
			If Empty(_cEmail)
				_cMsgVld := "Campo e-mail do aprovador em branco (RD0_EMAIL). Verifique o cadastro de participantes."
			EndIf
		ElseIf _nOpcA == 3
			If Empty(_cEmail)
				_cMsgVld := "Campo e-mail do aprovador em branco (RD0_EMAIL). Verifique o cadastro de participantes."
			Else
				If !IsEmail(_cEmail)
					_cMsgVld := "Campo e-mail do aprovador com conteúdo inválido (RD0_EMAIL). Verifique o cadastro de participantes."
				EndIf
			EndIf
			
			If Empty(_cAprAdian)
				_cMsgVld := "Campo aprovação adiantamento em branco (RD0_XAPADT). Verifique o cadastro de participantes."
			EndIf

			If Empty(_cAprConfe)
				_cMsgVld := "Campo aprovação de conferência em branco (RD0_XAPCNF). Verifique o cadastro de participantes."
			EndIf

			If Empty(_cAprViInt)
				_cMsgVld := "Campo aprovação de viagem internacional em branco (RD0_XAPINT). Verifique o cadastro de participantes."
			EndIf

			If Empty(_cAprViNac)
				_cMsgVld := "Campo aprovação de viagem nacional em branco (RD0_XAPNAC). Verifique o cadastro de participantes."
			EndIf

			If Empty(_cAprPagto)
				_cMsgVld := "Campo aprovação de pagamento (expense) em branco (RD0_XAPPAG). Verifique o cadastro de participantes."
			EndIf

			If Empty(_cAprReemb)
				_cMsgVld := "Campo aprovação de reembolso (expense) em branco (RD0_XAPREE). Verifique o cadastro de participantes."
			EndIf

			If Empty(_cAprSegNi)
				_cMsgVld := "Campo aprovação de segundo nível em branco (RD0_XAPSEG). Verifique o cadastro de participantes."
			EndIf
		
		ElseIf _nOpcA == 5
		
			If Empty(_cAprovId)
				_cMsgVld := "Parâmetro Id da aprovação em branco (_cAprovId). Verifique os parâmetros da função FINWS06A."
			EndIf

		EndIf

		If !Empty(_cMsgVld)		
			_lContinua	:= .F.			
			_aRetPrc 	:= {"1", "", "", "", "", "Erro nos campos obrigatórios para o envio do webservice.", _cMsgVld}			
		EndIf
	EndIf

	If _lContinua
		If _nOpcA == 1 //LIST
			
			If Len(_aDadosReq) > 0			
				_aRequest := aClone(_aDadosReq)
			Else								
				_aRequest := {}
				//CAMPO - nome - conteúdo - descrição - tipo - tamanho - obrigatoriedade
				AADD(_aRequest, {_cPrefReq+":account_code", _cNomeEmp}) //Código do Centro de custo - varchar - 64 - Não
				AADD(_aRequest, {_cPrefReq+":approval_flag_active", _cActive}) //Consulta estruturas ativas (0:inativo,1:ativo) - numeric - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":company_name", _cCodeEmp}) //Nome da empresa ao centro de custo - varchar - 64 - Não
				AADD(_aRequest, {_cPrefReq+":user_email_primary", _cEmailPart}) //E-mail do viajante - varchar - 128 - Não				
			EndIf
			
			_aRetPrc := U_FINWS006("list", "filters", _aRequest, _cEmpOri, _cFilOri)	
			
		ElseIf _nOpcA == 2 //GET
	
		ElseIf _nOpcA == 3 //NEW

			If Len(_aDadosReq) > 0			
				_aRequest := aClone(_aDadosReq)
			Else				
				_aRequest := {}				
				//CAMPO - nome - conteúdo - descrição - tipo - tamanho - obrigatoriedade	
				AADD(_aRequest, {_cPrefReq+":account_code", _cCCusto}) //Código do centro de custo - varchar - 32 - Não
				AADD(_aRequest, {_cPrefReq+":approval_flag_advance", _cAprAdian}) //Aprovação para adiantamento (0=Sim / 1=Não) - numérico - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":approval_flag_conference", _cAprConfe}) //Aprovação de conferência (expense) (0=Sim / 1=Não) - numérico - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":approval_flag_international", _cAprViInt}) //Aprovação de viagem internacional (0=Sim / 1=Não) - numérico - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":approval_flag_merit", _cAprMerit}) //Aprovação de mérito (0=Sim / 1=Não) - numérico - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":approval_flag_national", _cAprViNac}) //Aprovação de viagem nacional (0=Sim / 1=Não) - numérico - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":approval_flag_nivel", _cAprNivel}) //Aprovação por nível hierárquico (0=Sim / 1=Não) - numérico - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":approval_flag_paralel", _cAprParal}) //Aprovação Paralela (0=Sim / 1=Não) - numérico - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":approval_flag_payment", _cAprPagto}) //Aprovação de pagamento (expense) (0=Sim / 1=Não) - numérico - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":approval_flag_reimbursement", _cAprReemb}) //Aprovação de reembolso (expense) (0=Sim / 1=Não) - numérico - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":approval_flag_sequential", _cAprSeque}) //Aprovação sequencial (0=Sim / 1=Não) - numérico - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":approval_flag_unique", _cAprUnica}) //Aprovação Única (0=Sim / 1=Não) - numérico - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":approval_flag_second_level", _cAprSegNi}) //Aprovação de segundo nível (0=Sim / 1=Não) - numérico - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":approval_list", _cAprLista}) //Aprovação por lista (0=Sim / 1=Não) - numérico - 1 - Não
				AADD(_aRequest, {_cPrefReq+":approval_order", _cAprOrdem}) //Ordem da aprovação (1°= 1, 2°= 2, 3°= 3...) - numérico - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":approver_email_primary", _cEmail}) //E-mail do aprovador - varchar - 128 - Sim
				AADD(_aRequest, {_cPrefReq+":approver_limit_value", _cValLimit}) //Valor da alçada de aprovação - numérico - 10 - Não
				AADD(_aRequest, {_cPrefReq+":company_name", _cNomeEmp}) //Nome da empresa - varchar - 64 - Não
				AADD(_aRequest, {_cPrefReq+":overwrite", _cOvewrite}) //Subscreve a aprovação cadastrada - numérico - 1 - Não
				AADD(_aRequest, {_cPrefReq+":user_email_primary", _cEmailPart}) //E-mail do viajante - varchar - 128 - Não
			EndIf
				
			_aRetPrc := U_FINWS006("new", "approval", _aRequest, _cEmpOri, _cFilOri)
			
		ElseIf _nOpcA == 4 //UPDATE
	
		ElseIf _nOpcA == 5 //DISABLE	
			
			If Len(_aDadosReq) > 0			
				_aRequest := aClone(_aDadosReq)
			Else										
				_aRequest := {}	
				//CAMPO - nome - conteúdo - descrição - tipo - tamanho - obrigatoriedade
				AADD(_aRequest, {_cPrefReq+":account_code", _cNomeEmp}) //Centro de Custo (se aplicável à politica da empresa) - varchar - 32 - Não
				
				If !Empty(_cViagInter)
					AADD(_aRequest, {_cPrefReq+":approval_flag_international", _cViagInter}) //Aprovação internacional - numeric - 1 - Nao
				EndIf
				
				If !Empty(_cViagNacio)
					AADD(_aRequest, {_cPrefReq+":approval_flag_national", _cViagNacio}) //Aprovação Nacional - numeric - 1 - Nao
				EndIf

				AADD(_aRequest, {_cPrefReq+":approval_id", _cAprovId}) //ID aprovação – informado no retorno do método new - varchar - 64 - Sim
				AADD(_aRequest, {_cPrefReq+":company_name", _cCodeEmp}) //Nome da Empresa, se o fluxo for por centro de custo - varchar - 64 - Não
				AADD(_aRequest, {_cPrefReq+":user_email_primary", _cEmailPart}) //E-mail usuário que possui a estrutura de aprovação - varchar  - 128 - Não
			EndIf
			
			_aRetPrc := U_FINWS006("disable", "approval", _aRequest, _cEmpOri, _cFilOri)
		
		EndIf
	
		If !Empty(_cPartChave)
			RD0->(DbSeek(_cPartChave))
		EndIf

	EndIf	
	
	RestArea(_aArea)

Return _aRetPrc


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINWS06I

Copastur - Geração da tabela integradora

@author CM Solutions - Allan Constantino Bonfim
@since  26/11/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FINWS06I(cEmpOri, cFilOri, cFilPart, cCodPart, cTpInteg, cTpProc, cTpIncl) //1=Inclusao 2=Alteracao 3=Exclusao 4=Consulta

	Local aArea			:= GetArea()
	Local aAreaRD0		:= RD0->(GetArea())
	Local cQDados		:= ""
	Local cTmpInt		:= GetNextAlias()
	Local lRet			:= .T.

	Default cEmpOri		:= FwCodEmp()
	Default cFilOri		:= FwCodFil()
	Default cTpInteg	:= "1"
	Default cFilPart	:= FwxFilial("RD0")
	Default cCodPart	:= ""
	Default cTpProc		:= "2" //1=Participante;2=Aprovador;3=Centro Custo;4=Adiantamento;5=Despesas
	Default cTpIncl		:= "2"


	If !Empty(cCodPart)

		DbSelectArea("RD0") //Cadastro Participantes
		DbSetOrder(1) //RD0_FILIAL, RD0_CODIGO
		If RD0->(DbSeek(cFilPart+cCodPart))		

			If !Empty(RD0->RD0_EMPATU)	.and. !Empty(RD0->RD0_FILATU)						
				cEmpOri	:= RD0->RD0_EMPATU
				cFilOri	:= RD0->RD0_FILATU
			ENDIF

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
			cQDados += "AND NOT EXISTS(SELECT ZWQ_CODIGO FROM " +RetSqlName("ZWQ")+ " ZWQ (NOLOCK) WHERE ZWQ.D_E_L_E_T_ = ' ' AND ZWQ_FILIAL = '"+FwxFilial("ZWQ")+"' AND ZWQ_CALIAS = 'RD0' AND ZWQ_FILALI = RD0_FILIAL AND ZWQ_CHAVE = RD0_CODIGO AND ZWQ_TINTEG = '"+cTpInteg+"' AND ZWQ_TPPROC = '"+cTpProc+"' AND ZWQ_STATUS <> '05') "+CHR(13)+CHR(10)			
			cQDados += "ORDER BY RD0_FILIAL, RD0_CODIGO "+CHR(13)+CHR(10)

			cQDados := ChangeQuery(cQDados)	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados), cTmpInt)	
			
			While !(cTmpInt)->(EOF())
				lRet := U_FINWS2GR(3,,, cEmpOri, cFilOri, "RD0", 1, (cTmpInt)->RD0_FILIAL, (cTmpInt)->RD0_CODIGO, (cTmpInt)->RD0REC, "01", cTpIncl, cTpInteg, cTpProc,,,,, ALLTRIM((cTmpInt)->RD0_XLOGIN), ALLTRIM((cTmpInt)->RD0_EMAIL))

				(cTmpInt)->(DbSkip())
			ENDDo

		ENDIF
	EndIf

	If Select(cTmpInt) > 0
		(cTmpInt)->(DbCloseArea())
	EndIf

	RestArea(aAreaRD0)
	RestArea(aArea)
	
Return lRet
