#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINWS005

Copastur - Webservice UserService - Cadastro de usuários

@author CM Solutions - Allan Constantino Bonfim
@since  08/10/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FINWS005(_cWSMetodo, _cWSRequest, _aWSRequest, _cEmpXML, _cFilXML, _lExclusiv)

	Local _aArea		:= GetArea()
	Local _cURL    		:= GETNEWPAR("ZZ_FWS5URL", "https://altjtb0065.alatur.com/UserService.svc?wsdl")
	Local _cUserWS		:= ""
	Local _cPassWS		:= ""
	Local _cMsg      	:= ""
	Local _cMsgRet   	:= ""
	Local _cError    	:= ""
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
			//_cLockName	:= _cRotina+_cEmpXML+_cFilXML
	
			//If LockByName(_cLockName, .T., .F.)
			//_aAreaSM0 	:= SM0->(GetArea())				
			
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
					_oWsdl:lRemEmptyTags 	:= .T.
		

					//Tenta fazer o Parse da URL		
					If _oWsdl:ParseURL(_cURL)		
						//Tenta definir a operação
						If _oWsdl:SetOperation(_cWSMetodo)
							
							If Alltrim(_cWSMetodo) $ "get/disable"
								//_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.root">'
								_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">'
							//ElseIf Alltrim(_cWSMetodo) $ "update"
							//	_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.root" xmlns:req="http://request.webservice.models.root">'							
							Else
								_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:int="http://schemas.datacontract.org/2004/07/IntegracaoBRF.Model">'
								//_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.root" xmlns:web="http://webservice.models.root">'								
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
								_cMsgRet 	:= _oWsdl:GetSoapResponse()
								_cError	:= ""
								_cWarning	:= ""
													
								//Transforma a resposta em um objeto
								_oXmlRet := XmlParser(_cMsgRet, "_", @_cError, @_cWarning)
									
								If Empty(_cError)
									_cUrlRet := "_oXmlRet:_S_ENVELOPE:_S_BODY:_"+Upper(Alltrim(_cWSMetodo))+"RESPONSE:_"+Upper(Alltrim(_cWSMetodo))+"RESULT"
									
									If Alltrim(_cWSMetodo) $ "list"
										_cUrlRet += ":_A_USERS_LIST"
									EndIf
																	
									_oWSRet := &(_cUrlRet)
	
									If AttIsMemberOf(_oWSRet, "_A_MESSAGE") .AND. AttIsMemberOf(_oWSRet, "_A_CODE")
										_cCode		:= _oWSRet:_A_CODE:TEXT
										_cMessage	:= _oWSRet:_A_MESSAGE:TEXT
										_cError	:= ""
										_cDetErro	:= ""
										
										If _cMessage == "OK"	.OR. _cCode == "OK"																																			
											_aWSRet 	:= {"0", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro}
										Else
											_cError	:= _oWSRet:_A_MESSAGE:TEXT
											_cDetErro	:= "Erro no consumo do webservice"
										
											_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro}
										EndIf
									Else
										_cCode		:= ""									
										_cError	:= "Atributo _A_MESSAGE e/ou _A_CODE não encontrado no retorno do webservice."
										
										_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 												
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

							
					//UnLockByName(_cLockName, .T., .F.)			
					//Else			
						//lRet := .F.
						//Help(NIL, NIL, _cRotina, NIL, "A função está em execução por outro usuário.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Aguarde a finalização e tente novamente."})
						//U_XXMLGLOG(@_aLog, .F., "A função está em execução por outro usuário. Aguarde a finalização e tente novamente.")		
					//EndIf
								
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
/*/{Protheus.doc} FINWS05A

Copastur - Webservice UserService - Cadastro de usuários

@author CM Solutions - Allan Constantino Bonfim
@since  08/10/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FINWS05A(_nOpcA, _cEmpOri, _cFilOri, _nRD0Indice, _cRD0FilChv, _cRD0Chave, _aDadosReq, _cStatus, _lReset)

	Local _aArea		:= GetArea()
	Local _aRetPrc		:= ARRAY(7) 
	Local _aRequest 	:= {}
	Local _cPassDef 	:= ""
	Local _cNomeEmp 	:= ""	
	Local _lContinua 	:= .T.
	Local _cEmail		:= ""
	Local _cLogin		:= ""
	Local _cAdiSApr		:= ""
	Local _cVISApr		:= ""
	Local _cVNSApr		:= ""
	Local _cSolSApr		:= ""
	Local _cSolTerc		:= ""
	Local _cUsrSApr		:= ""
	Local _cUsrVip		:= ""
	Local _cUsrTipo		:= ""
	Local _cNome		:= ""
	Local _cCCusto		:= ""
	Local _cMunicip		:= ""
	Local _cCep			:= ""
	Local _cEstado		:= ""
	Local _cEndereco	:= ""
	Local _cDtNasci		:= ""
	Local _cCpf			:= ""
	Local _cRg			:= ""
	Local _cEmail2		:= ""
	Local _cSexo		:= ""
	Local _cDDICel		:= ""
	Local _cCelular		:= ""
	Local _cFax			:= ""
	Local _cTelefone	:= ""
	Local _cActive		:= ""
	Local _cDataCad		:= ""
	Local _cDepart		:= ""
	Local _cCargo		:= ""
	Local _cMatricu		:= ""
	Local _cCodeEmp		:= ""
	Local _cMsgVld		:= ""
	Local _cPrefReq		:= "int" //"req"
	Local _cPrefWs		:= "tem"//"ws:"

	Default _nOpcA		:= 0
	Default _cEmpOri	:= FwCodEmp()
	Default _cFilOri	:= FwCodFil()
	Default _nRD0Indice	:= 1 
	Default _cRD0FilChv	:= ""
	Default _cRD0Chave	:= ""
	Default _aDadosReq	:= {}
	Default _cStatus	:= "1"
	Default _lReset		:= .F.

	
	If Len(_aDadosReq) > 0
		_lContinua := .T.
	ElseIf !Empty(_cRD0Chave)
		_lContinua := .T.

		DbSelectArea("FL2") //Cadastro empresas Copastur
		DbSetOrder(1) //FL2_FILIAL, FL2_BKOEMP, FL2_LICENC

		DbSelectArea("RD0") //Cadastro Participantes
		DbSetOrder(_nRD0Indice) //RD0_FILIAL+RD0_CODIGO
		
		If RD0->(DbSeek(_cRD0FilChv+_cRD0Chave))		
			If !FL2->(DbSeek(FwxFilial("FL2")+_cEmpOri+_cFilOri))
				_lContinua := .F.
				_aRetPrc 	:= {"1", "", "", "", "", "Empresa do participante não cadastrada no Copastur.", "Empresa ("+_cEmpOri+") / Filial ("+_cFilOri+") não localizada no cadastro de empresas Copastur. Verifique o cadastro da empresa (FL2)."}
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
		_cEmail		:= ALLTRIM(RD0->RD0_EMAIL)
		_cLogin		:= ALLTRIM(RD0->RD0_XLOGIN)	
		_cAdiSApr	:= IIF (RD0->RD0_XADNAP == "S", "1", "0")
		_cVISApr	:= IIF (RD0->RD0_XVINAP == "S", "1", "0")
		_cVNSApr	:= IIF (RD0->RD0_XVNNAP == "S", "1", "0")
		_cSolSApr	:= IIF (RD0->RD0_XRNAPR == "S", "1", "0")	
		_cSolTerc	:= IIF (RD0->RD0_XSPTER == "S", "1", "0")
		_cUsrSApr	:= IIF (RD0->RD0_XNAPRO == "S", "1", "0")
		_cUsrVip	:= IIF (RD0->RD0_XVIP == "S", "1", "0")
		_cUsrTipo	:= IIF (RD0->RD0_TIPO == "2", "1", "0") //1=Interno - 2=Externo
		_cNome		:= ALLTRIM(RD0->RD0_NOME)
		
		If _nOpcA == 3
			_lReset := .T.
		EndIf

		If _lReset //.OR. _nOpcA == 3
			_cPassDef 	:= ALLTRIM(GETNEWPAR("ZZ_FWSPDEF", "@ALATUR0099#")) //Somente na inclusão
		EndIf
		
		//Campos Opicionais
		_cNomeEmp	:= ALLTRIM(FL2->FL2_GRPEMP)
		_cCCusto	:= ALLTRIM(RD0->RD0_CC)	
		_cMunicip	:= ALLTRIM(RD0->RD0_MUN)         
		_cCep		:= RD0->RD0_CEP
		_cEstado	:= RD0->RD0_UF
		_cEndereco	:= U_FINWSESP(ALLTRIM(RD0->RD0_END)+ IIF (!EMPTY(RD0->RD0_NUMEND), ", "+ALLTRIM(RD0->RD0_NUMEND), "") + IIF (!EMPTY(RD0->RD0_CMPEND), " - "+ALLTRIM(RD0->RD0_CMPEND), ""))
		_cDtNasci	:= Year2Str(RD0->RD0_DTNASC)+"-"+Month2Str(RD0->RD0_DTNASC)+"-"+Day2Str(RD0->RD0_DTNASC)	
		_cCpf		:= ALLTRIM(RD0->RD0_CIC)
		_cRg		:= ALLTRIM(RD0->RD0_XRG)
		//_cEmail2	:= ALLTRIM(RD0->RD0_EMAIL) //Utilizado para outros e-mails ja cadastrados no Copastur
		_cSexo		:= IIF(RD0->RD0_SEXO = "M", "1", "0")
		_cDDICel	:= ALLTRIM(RD0->RD0_DDI)
		_cCelular	:= ALLTRIM(RD0->RD0_DDD)+ALLTRIM(RD0->RD0_NUMCEL)
		_cFax		:= ALLTRIM(RD0->RD0_FAX)
		_cTelefone	:= ALLTRIM(RD0->RD0_DDD)+ALLTRIM(RD0->RD0_FONE)
		_cActive	:= IIF (RD0->RD0_MSBLQL == "1", "0", "1") //IIF (_lBloqueio, "0", "1")		
		//_cActive	:= IIF (_lBloqueio, "0", "1")		
		_cDataCad	:= ""
		_cDepart	:= ALLTRIM(RD0->RD0_XDEPTO) //ALLTRIM(SRA->RA_CODFUNC)
		_cCargo		:= ALLTRIM(RD0->RD0_XCARGO) //GetAdvFVal("SQ3", "Q3_DESCSUM", xFilial("SQ3")+SRA->RA_CARGO, 1, "")	
		_cMatricu	:= ALLTRIM(RD0->RD0_CODIGO) //ALLTRIM(SRA->RA_FILIAL)+ALLTRIM(SRA->RA_MAT)			

		//Validação campos obrigatórios
		If Empty(_cEmail)
			_cMsgVld := "Campo e-mail em branco (RD0_EMAIL). Verifique o cadastro de participantes."
		Else
			If !IsEmail(_cEmail)
				_cMsgVld := "Campo e-mail com conteúdo inválido (RD0_EMAIL). Verifique o cadastro de participantes."
			EndIf
		EndIf
		
		If Empty(_cLogin)
			_cMsgVld := "Campo login em branco (RD0_XLOGIN). Verifique o cadastro de participantes."
		EndIf
			
		If Empty(_cNome)
			_cMsgVld := "Campo nome em branco (RD0_NOME). Verifique o cadastro de participantes."
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
				AADD(_aRequest, {_cPrefReq+":company_name", _cNomeEmp}) //Nome da empresa - varchar - 64 - Não
				AADD(_aRequest, {_cPrefReq+":company_code", _cCodeEmp}) //Nome da empresa - varchar - 64 - Não
				AADD(_aRequest, {_cPrefReq+":user_date_add", _cDataCad}) //Data do cadastro, método retornará todos usuários que foram inseridos a partir dessa data. Formato DDMMAAAA - date - 10 - Não
				AADD(_aRequest, {_cPrefReq+":user_flag_active", _cActive}) //Status(0:inativo,1:ativo) - numeric - 1 - Sim
			EndIf
			
			_aRetPrc := U_FINWS005("list", "filters", _aRequest, _cEmpOri, _cFilOri)	
		
		ElseIf _nOpcA == 2 //GET

			If Len(_aDadosReq) > 0			
				_aRequest := aClone(_aDadosReq)
			Else								
				_aRequest := {}
			
				//CAMPO - nome - conteúdo - descrição - tipo - tamanho - obrigatoriedade
				//AADD(_aRequest, {_cPrefWs+':'+user_email_primary", _cEmail}) //E-mail do viajante - varchar - 128 - Sim
				AADD(_aRequest, {_cPrefWs+":user_login", _cLogin})  //Login do usuário - varchar - 30 - Sim		
			EndIf
			
			_aRetPrc := U_FINWS005("get", "", _aRequest, _cEmpOri, _cFilOri)	
		
		ElseIf _nOpcA == 3 //NEW

			If Len(_aDadosReq) > 0			
				_aRequest := aClone(_aDadosReq)
			Else				
				_aRequest := {}				
				
				//CAMPO - nome - conteúdo - descrição - tipo - tamanho - obrigatoriedade	
				AADD(_aRequest, {_cPrefReq+":account_code", _cCCusto}) //Código do centro de custo - varchar - 32 - Não
				AADD(_aRequest, {_cPrefReq+":account_company_name", "" /*_cNomeEmp*/}) //Nome da empresa do centro de custo - varchar - 64 - Não
				AADD(_aRequest, {_cPrefReq+":company_code", _cCodeEmp}) //Código de referência - varchar - 30 - Não
				AADD(_aRequest, {_cPrefReq+":company_name", _cNomeEmp}) //Nome da empresa - varchar - 64 - Não 
				AADD(_aRequest, {_cPrefReq+":user_address_city", _cMunicip}) //Cidade - varchar - 50 - Não
				AADD(_aRequest, {_cPrefReq+":user_address_postal_code", _cCep}) //Código de Endereçamento Postal - varchar - 8 - Não
				AADD(_aRequest, {_cPrefReq+":user_address_state", _cEstado}) //Estado - varchar - 2 - Não
				AADD(_aRequest, {_cPrefReq+":user_address_text", _cEndereco}) //Logradouro e número - varchar - 50 - Não
				AADD(_aRequest, {_cPrefReq+":user_date_birth", _cDtNasci}) //Data de nascimento (formato AAAA-MM-DD) - date - 10 - Não
				AADD(_aRequest, {_cPrefReq+":user_document_cpf", _cCpf}) //Número do Cadastro de Pessoa Física - varchar - 12 - Não
				AADD(_aRequest, {_cPrefReq+":user_document_rg", _cRg}) //Número do Registro Geral - varchar - 12 - Não
				AADD(_aRequest, {_cPrefReq+":user_email_primary", _cEmail}) //E-mail do viajante - varchar - 128 - Sim
				AADD(_aRequest, {_cPrefReq+":user_email_secondary", _cEmail2}) //Endereço de e-mail alternativo - varchar - 128 - Não 
				AADD(_aRequest, {_cPrefReq+":user_employment_department", _cDepart}) //Departamento - varchar - 50 - Não
				AADD(_aRequest, {_cPrefReq+":user_employment_occupation", _cCargo}) //Cargo - varchar - 50 - Não
				AADD(_aRequest, {_cPrefReq+":user_employment_registration", _cMatricu}) //Matrícula - varchar - 20 - Não
				AADD(_aRequest, {_cPrefReq+":user_fax_number", _cFax}) //Número de fax - varchar - 30 - Não
				AADD(_aRequest, {_cPrefReq+":user_flag_advance_master", _cAdiSApr}) //Solicitações de adiantamento deste usuário não precisam de aprovação? (0:não,1:sim) - numeric - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_flag_international_master", _cVISApr}) //Solicitações de viagens internacionais para este usuário não precisam de aprovação? (0:não,1:sim) - numeric - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_flag_national_master", _cVNSApr}) //Solicitações de viagens nacionais para este usuário não precisam de aprovação? (0:não,1:sim) - numeric - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_flag_refund_master", _cSolSApr}) //Solicitações de reembolso deste usuário não precisam de aprovação? (0:não,1:sim) - numeric - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_flag_requester", _cSolTerc}) //Usuário pode fazer solicitações em nome de outros? (0:não,1:sim) - numeric - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_flag_requester_master", _cUsrSApr}) //Solicitações do usuário não precisam de aprovação? (0:não,1:sim) - numeric - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_flag_thirdparty", _cUsrTipo}) //Usuário é tercerizado? (0:não,1:sim) - numeric - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_flag_vip", _cUsrVip}) //Usuário é viajante VIP? (0:não,1:sim) - numeric - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_gender", _cSexo}) //Sexo (0:feminino,1:masculino) - numeric - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_level", ""}) //Nível - varchar - 32 - Não //NAO SE APLICA
				AADD(_aRequest, {_cPrefReq+":user_login", _cLogin}) //Login para acessar o ARB - varchar - 64 - Sim				
				AADD(_aRequest, {_cPrefReq+":user_ddi_mobile", _cDDICel}) //Telefone celular do usuário - varchar - 30 - Não
				AADD(_aRequest, {_cPrefReq+":user_mobile_number", _cCelular}) //Telefone celular do usuário - varchar - 30 - Não
				AADD(_aRequest, {_cPrefReq+":user_name_full", _cNome}) //Nome completo - varchar - 128 - Sim
				AADD(_aRequest, {_cPrefReq+":user_password", _cPassDef})  //Senha de acesso ao ARB - varchar - 64 - Sim
				AADD(_aRequest, {_cPrefReq+":user_phone_number", _cTelefone}) //Número de telefone - varchar - 30 - Não
			EndIf
				
			_aRetPrc := U_FINWS005("new", "user", _aRequest, _cEmpOri, _cFilOri)
			
		ElseIf _nOpcA == 4 //UPDATE

			If Len(_aDadosReq) > 0			
				_aRequest := aClone(_aDadosReq)
			Else						
				_aRequest := {}
				
				//CAMPO - nome - conteúdo - descrição - tipo - tamanho - obrigatoriedade
				AADD(_aRequest, {_cPrefReq+":account_code", _cCCusto}) //Código do centro de custo - varchar - 32 - Não
				AADD(_aRequest, {_cPrefReq+":account_company_name", ""/*_cNomeEmp*/}) //Nome da empresa do centro de custo - varchar - 64 - Não
				AADD(_aRequest, {_cPrefReq+":company_code", _cCodeEmp}) //Código de referência - varchar - 30 - Não
				AADD(_aRequest, {_cPrefReq+":company_name", _cNomeEmp}) //Nome da empresa - varchar - 64 - Não
				AADD(_aRequest, {_cPrefReq+":user_address_city", _cMunicip}) //Cidade - varchar - 50 - Não
				AADD(_aRequest, {_cPrefReq+":user_address_postal_code", _cCep}) //Código de Endereçamento Postal - varchar - 8 - Não
				AADD(_aRequest, {_cPrefReq+":user_address_state", _cEstado}) //Estado - varchar - 2 - Não
				AADD(_aRequest, {_cPrefReq+":user_address_text", _cEndereco}) //Logradouro e número - varchar - 50 - Não
				AADD(_aRequest, {_cPrefReq+":user_date_birth", _cDtNasci}) //Data de nascimento (Formato AAAA-MM-DD) - date - 8 - Não
				AADD(_aRequest, {_cPrefReq+":user_document_cpf", _cCpf}) //Número do Cadastro de Pessoa Física - varchar - 12 - Não
				AADD(_aRequest, {_cPrefReq+":user_document_rg", _cRg}) //Número do Registro Geral - varchar - 12 - Não
				AADD(_aRequest, {_cPrefReq+":user_email_primary", _cEmail}) //E-mail do viajante - varchar - 128 - Sim
				AADD(_aRequest, {_cPrefReq+":user_email_secondary", _cEmail2}) //Endereço de e-mail alternativo - varchar - 128 - Não
				AADD(_aRequest, {_cPrefReq+":user_employment_department", _cDepart}) //Departamento - varchar - 50 - Não
				AADD(_aRequest, {_cPrefReq+":user_employment_occupation", _cCargo}) //Cargo - varchar - 50 - Não
				AADD(_aRequest, {_cPrefReq+":user_employment_registration", _cMatricu}) //Matrícula - varchar - 20 - Não
				AADD(_aRequest, {_cPrefReq+":user_fax_number", _cFax}) //Número de fax - varchar - 30 - Não
				AADD(_aRequest, {_cPrefReq+":user_flag_active", _cActive}) //Status (0:inativo,1:ativo) - Numeric - 7 - Sim
				AADD(_aRequest, {_cPrefReq+":user_flag_advance_master", _cAdiSApr}) //Solicitações de adiantamento deste usuário não precisam de aprovação? (0:não,1:sim) - varchar - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_flag_international_master", _cVISApr}) //Solicitações de viagens internacionais para este usuário não precisam de aprovação? (0:não,1:sim) - varchar - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_flag_national_master", _cVNSApr}) //Solicitações de viagens nacionais para este usuário não precisam de aprovação? (0:não,1:sim) - varchar - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_flag_refund_master", _cSolSApr}) //Solicitações de reembolso deste usuário não precisam de aprovação? (0:não,1:sim) - varchar - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_flag_requester", _cSolTerc}) //Usuário pode fazer solicitações em nome de outros? (0:não,1:sim) - varchar - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_flag_requester_master", _cUsrSApr}) //Solicitações do usuário não precisam de aprovação? (0:não,1:sim) - varchar - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_flag_thirdparty", _cUsrTipo}) //Usuário é terceirizado? (0:não,1:sim) - varchar - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_flag_vip", _cUsrVip}) //Usuário é viajante VIP? (0:não,1:sim) - varchar - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_gender", _cSexo}) //Sexo (0:feminino,1:masculino) - numeric - 1 - Sim
				AADD(_aRequest, {_cPrefReq+":user_level", ""}) //Nível - varchar - 32 - Não
				AADD(_aRequest, {_cPrefReq+":user_login", _cLogin}) //Login para acessar o ARB - varchar - 64 - Sim
				AADD(_aRequest, {_cPrefReq+":user_ddi_mobile", _cDDICel}) //Telefone celular do usuário - varchar - 30 - Não
				AADD(_aRequest, {_cPrefReq+":user_mobile_number", _cCelular}) //Telefone celular do usuário - varchar - 30 - Não				
				AADD(_aRequest, {_cPrefReq+":user_name_full",_cNome}) //Nome completo - varchar - 128 - Sim						
				AADD(_aRequest, {_cPrefReq+":user_password", _cPassDef})  //Senha de acesso ao ARB - varchar - 64 - Sim	
				AADD(_aRequest, {_cPrefReq+":user_phone_number",  _cTelefone}) //Número de telefone - varchar - 30 - Não
			EndIf
			
			_aRetPrc := U_FINWS005("update", "user", _aRequest, _cEmpOri, _cFilOri)	
		
		ElseIf _nOpcA == 5 //DISABLE	

			If Len(_aDadosReq) > 0			
				_aRequest := aClone(_aDadosReq)
			Else										
				_aRequest := {}	
				//CAMPO - nome - conteúdo - descrição - tipo - tamanho - obrigatoriedade
				AADD(_aRequest, {_cPrefWs+":user_email_primary", _cEmail}) //E-mail do viajante - varchar  - 128 - Sim
			EndIf
			
			_aRetPrc := U_FINWS005("disable", , _aRequest, _cEmpOri, _cFilOri)			
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
USER FUNCTION FINWS05I(cEmpOri, cFilOri, cFilPart, cCodPart, cTpInteg, cTpProc, cAlatur, nValAla, cTpIncl) //1=Inclusao 2=Alteracao 3=Exclusao 4=Consulta

	Local aArea			:= GetArea()
	Local cQDados		:= ""
	Local cTmpInt		:= GetNextAlias()
	Local lRet			:= .T.
	Local lIntegra		:= .T.

	Default cEmpOri		:= FwCodEmp()
	Default cFilOri		:= FwCodFil()
	Default cTpInteg	:= "2"
	Default cFilPart	:= FwxFilial("RD0")
	Default cCodPart	:= ""
	Default cTpProc		:= "1"
	Default cAlatur		:= ""
	Default nValAla		:= 0
	Default cTpIncl		:= "2"


	If !Empty(cCodPart)

		DbSelectArea("RD0") //Cadastro Participantes
		DbSetOrder(1) //RD0_FILIAL, RD0_CODIGO
		If RD0->(DbSeek(cFilPart+cCodPart))		

			If !Empty(RD0->RD0_EMPATU)	.AND. !Empty(RD0->RD0_FILATU)					
				cEmpOri	:= RD0->RD0_EMPATU
				cFilOri := RD0->RD0_FILATU
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

			If !Empty(cAlatur)
				cQDados += "AND NOT EXISTS(SELECT ZWQ_CODIGO FROM " +RetSqlName("ZWQ")+ " ZWQ (NOLOCK) WHERE ZWQ.D_E_L_E_T_ = ' ' AND ZWQ_FILIAL = '"+FwxFilial("ZWQ")+"' AND ZWQ_CALIAS = 'RD0' AND ZWQ_FILALI = RD0_FILIAL AND ZWQ_CHAVE = RD0_CODIGO AND ZWQ_TINTEG = '"+cTpInteg+"' AND ZWQ_TPPROC = '"+cTpProc+"' AND ZWQ_CODALA = '"+cAlatur+"' AND ZWQ_STATUS <> '05') "+CHR(13)+CHR(10)			
			Else
				cQDados += "AND NOT EXISTS(SELECT ZWQ_CODIGO FROM " +RetSqlName("ZWQ")+ " ZWQ (NOLOCK) WHERE ZWQ.D_E_L_E_T_ = ' ' AND ZWQ_FILIAL = '"+FwxFilial("ZWQ")+"' AND ZWQ_CALIAS = 'RD0' AND ZWQ_FILALI = RD0_FILIAL AND ZWQ_CHAVE = RD0_CODIGO AND ZWQ_TINTEG = '"+cTpInteg+"' AND ZWQ_TPPROC = '"+cTpProc+"' AND ZWQ_STATUS <> '05') "+CHR(13)+CHR(10)			
			ENDIF

			cQDados += "ORDER BY RD0_FILIAL, RD0_CODIGO "+CHR(13)+CHR(10)

			cQDados := ChangeQuery(cQDados)	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados), cTmpInt)	
			
			While !(cTmpInt)->(EOF())
				If cTpProc $ "4/5"
					If !(FwCodEmp() == cEmpOri .AND. FwCodFil() == cFilOri)
						lIntegra := .F.
					EndIf
				EndIf

				If lIntegra
					lRet := U_FINWS2GR(3,,, cEmpOri, cFilOri, "RD0", 1, (cTmpInt)->RD0_FILIAL, (cTmpInt)->RD0_CODIGO, (cTmpInt)->RD0REC, "01", cTpIncl, cTpInteg, cTpProc,,,,, ALLTRIM((cTmpInt)->RD0_XLOGIN), ALLTRIM((cTmpInt)->RD0_EMAIL), cAlatur, nValAla)
				EndIf
				(cTmpInt)->(DbSkip())
			ENDDo

		ENDIF
	EndIf

	If Select(cTmpInt) > 0
		(cTmpInt)->(DbCloseArea())
	EndIf

	RestArea(aArea)
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIN5WS01

Copastur - Rotina para a integração dos participanntes via job

@author CM Solutions - Allan Constantino Bonfim
@since  09/03/2020
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FIN5WS01(_cIntOpcao)

	Local _aArea		:= GetArea()
	Local _lRet			:= .T.
	Local _cATmpPart

	Default _cIntOpcao	:= "2"


	If Select(_cATmpPart) > 0
		(_cATmpPart)->(DbCloseArea())
	EndIf
	
	If _cIntOpcao == "2"
		_cATmpPart	:= U_FIWS3TMP(2,, {"2", "", "", ""}, "1")
		If Select(_cATmpPart) > 0 .AND. !(_cATmpPart)->(EOF())
			(_cATmpPart)->(DbGotop())
			DbSelectArea((_cATmpPart)->ZWQ_CALIAS)
			DbSetOrder((_cATmpPart)->ZWQ_INDICE) //RD0_FILIAL+RD0_CODIGO
			WHile !(_cATmpPart)->(EOF())
				If RD0->(Dbseek((_cATmpPart)->ZWQ_FILALI+(_cATmpPart)->ZWQ_CHAVE))
					FWMsgRun(, {|| _lRet := U_FINWS03P(RD0->RD0_EMPATU, RD0->RD0_FILATU, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO,, "1")}, "Processando Cadastro...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
					(_cATmpPart)->(DbSkip())
				EndIf
			EndDo
		EndIf
	Else
		If Select(_cATmpPart) > 0
			(_cATmpPart)->(DbCloseArea())
		EndIf
		_cATmpPart	:= U_FIWS3TMP(1)
		If Select(_cATmpPart) > 0 .AND. !(_cATmpPart)->(EOF())
			(_cATmpPart)->(DbGotop())
			WHile !(_cATmpPart)->(EOF())
				FWMsgRun(, {|| _lRet := U_FINWS05I((_cATmpPart)->RD0_EMPATU, (_cATmpPart)->RD0_FILATU, (_cATmpPart)->RD0_FILIAL, (_cATmpPart)->RD0_CODIGO, "2", "1",,, "1")}, "Integrando Cadastro...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
				FWMsgRun(, {|| _lRet := U_FINWS03P((_cATmpPart)->RD0_EMPATU, (_cATmpPart)->RD0_FILATU, "RD0", (_cATmpPart)->RD0_FILIAL, (_cATmpPart)->RD0_CODIGO,, "1")}, "Processando Cadastro...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
				(_cATmpPart)->(DbSkip())
			EndDo
		EndIf

		If Select(_cATmpPart) > 0
			(_cATmpPart)->(DbCloseArea())
		EndIf
		_cATmpPart	:= U_FIWS3TMP(2,, {"2", "", "", ""}, "1")
		If Select(_cATmpPart) > 0 .AND. !(_cATmpPart)->(EOF())
			(_cATmpPart)->(DbGotop())
			DbSelectArea((_cATmpPart)->ZWQ_CALIAS)
			DbSetOrder((_cATmpPart)->ZWQ_INDICE) //RD0_FILIAL+RD0_CODIGO
			WHile !(_cATmpPart)->(EOF())
				If RD0->(Dbseek((_cATmpPart)->ZWQ_FILALI+(_cATmpPart)->ZWQ_CHAVE))
					FWMsgRun(, {|| _lRet := U_FINWS03P(RD0->RD0_EMPATU, RD0->RD0_FILATU, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO,, "1")}, "Processando Cadastro...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
					(_cATmpPart)->(DbSkip())
				EndIf
			EndDo
		EndIf
	EndIf

	If Select(_cATmpPart) > 0
		(_cATmpPart)->(DbCloseArea())
	EndIf
	
	RestArea(_aArea)

Return _lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIN5WS02

Copastur - Rotina para a integração dos aprovadores via job

@author CM Solutions - Allan Constantino Bonfim
@since  09/03/2020
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FIN5WS02(_cIntOpcao)

	Local _aArea		:= GetArea()
	Local _lRet			:= .T.
	Local _cATmpPart
	Local _cATmpAprov

	Default _cIntOpcao	:= "2"


	If Select(_cATmpPart) > 0
		(_cATmpPart)->(DbCloseArea())
	EndIf

	If Select(_cATmpAprov) > 0
		(_cATmpAprov)->(DbCloseArea())
	EndIf
	
	If _cIntOpcao == "2"
		_cATmpPart	:= U_FIWS3TMP(2,, {"2", "", "", ""}, "2")
		If Select(_cATmpPart) > 0 .AND. !(_cATmpPart)->(EOF())
			(_cATmpPart)->(DbGotop())
			DbSelectArea((_cATmpPart)->ZWQ_CALIAS)
			DbSetOrder((_cATmpPart)->ZWQ_INDICE) //RD0_FILIAL+RD0_CODIGO
			WHile !(_cATmpPart)->(EOF())
				If RD0->(Dbseek((_cATmpPart)->ZWQ_FILALI+(_cATmpPart)->ZWQ_CHAVE))
					FWMsgRun(, {|| _lRet := U_FINWS03P(RD0->RD0_EMPATU, RD0->RD0_FILATU, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO,, "2")}, "Processando Cadastro...", "Aprovador do participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
					(_cATmpPart)->(DbSkip())
				EndIf
			EndDo
		EndIf
	Else
		If Select(_cATmpAprov) > 0
			(_cATmpAprov)->(DbCloseArea())
		EndIf
		_cATmpAprov	:= U_FIWS3TMP(7)

		If Select(_cATmpAprov) > 0 .AND. !(_cATmpAprov)->(EOF())
			(_cATmpAprov)->(DbGotop())
			WHile !(_cATmpAprov)->(EOF())
				If Select(_cATmpPart) > 0
					(_cATmpPart)->(DbCloseArea())
				EndIf
				_cATmpPart	:= U_FIWS3TMP(1,, {,,,(_cATmpAprov)->RD0_CODIGO})
				(_cATmpPart)->(DbGotop())
				WHile !(_cATmpPart)->(EOF())
					FWMsgRun(, {|| _lRet := U_FINWS06I((_cATmpPart)->RD0_EMPATU, (_cATmpPart)->RD0_FILATU, (_cATmpPart)->RD0_FILIAL, (_cATmpPart)->RD0_CODIGO, "2", "2", "1")}, "Integrando Cadastro...", "Aprovador do participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
					FWMsgRun(, {|| _lRet := U_FINWS03P((_cATmpPart)->RD0_EMPATU, (_cATmpPart)->RD0_FILATU, "RD0", (_cATmpPart)->RD0_FILIAL, (_cATmpPart)->RD0_CODIGO,, "2")}, "Processando Cadastro...", "Aprovador do participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
					(_cATmpPart)->(DbSkip())
				EndDo
				(_cATmpAprov)->(DbSkip())
			EndDo
		EndIf

		If Select(_cATmpPart) > 0
			(_cATmpPart)->(DbCloseArea())
		EndIf
		
		_cATmpPart	:= U_FIWS3TMP(2,, {"2", "", "", ""}, "2")
		If Select(_cATmpPart) > 0 .AND. !(_cATmpPart)->(EOF())
			(_cATmpPart)->(DbGotop())
			DbSelectArea((_cATmpPart)->ZWQ_CALIAS)
			DbSetOrder((_cATmpPart)->ZWQ_INDICE) //RD0_FILIAL+RD0_CODIGO
			WHile !(_cATmpPart)->(EOF())
				If RD0->(Dbseek((_cATmpPart)->ZWQ_FILALI+(_cATmpPart)->ZWQ_CHAVE))
					FWMsgRun(, {|| _lRet := U_FINWS03P(RD0->RD0_EMPATU, RD0->RD0_FILATU, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO,, "2")}, "Processando Cadastro...", "Aprovador do participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
					(_cATmpPart)->(DbSkip())
				EndIf
			EndDo
		EndIf
	EndIf

	If Select(_cATmpAprov) > 0
		(_cATmpAprov)->(DbCloseArea())
	EndIf
	
	If Select(_cATmpPart) > 0
		(_cATmpPart)->(DbCloseArea())
	EndIf
	
	RestArea(_aArea)

Return _lRet
