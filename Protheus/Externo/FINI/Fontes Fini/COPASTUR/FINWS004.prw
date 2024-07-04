#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINWS004

Copastur - Webservice AccountService - Cadastro de centro de custos

@author CM Solutions - Allan Constantino Bonfim
@since  08/11/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FINWS004(_cWSMetodo, _cWSRequest, _aWSRequest, _cEmpXML, _cFilXML, _lExclusiv)

	Local _aArea			:= GetArea()
	Local _cURL    			:= GETNEWPAR("ZZ_FWS4URL", "https://altjtb0065.alatur.com/AccountService.svc?wsdl")
	Local _cUserWS			:= ""
	Local _cPassWS			:= ""
	Local _cMsg      		:= ""
	Local _cMsgRet   		:= ""
	Local _cError    		:= ""
	Local _cDetErro			:= ""
	Local _cWarning  		:= ""
	Local _oWsdl     		:= NIL
	Local _oXmlRet			:= NIL
	Local _nX				:= 0
	Local _aWSRet			:= ARRAY(8)
	Local _oWSRet			:= NIL
	Local _cUrlRet			:= ""
	Local _cCode			:= ""
	Local _cMessage			:= ""
	Local _cPrefWs			:= "tem"//"ws:"

	Default _cWSMetodo		:= ""
	Default _cWSRequest		:= ""
	Default _aWSRequest		:= {}												
	Default _cEmpXML		:= FwCodEmp()
	Default _cFilXML		:= FwCodFil()
	Default _lExclusiv		:= .F.


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
					_oWsdl:lVerbose 		:= .T.
					_oWsdl:SetAuthentication(_cUserWS, _cPassWS)
					_oWsdl:lSSLInsecure		:= .T.
					_oWsdl:nSSLVersion		:= 0		
					_oWsdl:nTimeout			:= 120
					_oWsdl:lProcResp		:= .F. //Não processa o retorno automaticamente no objeto (será tratado através do método GetSoapResponse)
					_oWsdl:lRemEmptyTags	:= .T.
									
					//Tenta fazer o Parse da URL		
					If _oWsdl:ParseURL(_cURL)		
						//Tenta definir a operação
						If _oWsdl:SetOperation(_cWSMetodo)											
							_cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:int="http://schemas.datacontract.org/2004/07/IntegracaoBRF.Model.Request">'
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

							_cMsg := EncodeUtf8(_cMsg)

							//Envia uma mensagem SOAP personalizada ao servidor					
							If _oWsdl:SendSoapMsg(_cMsg) 	
								//Pega a resposta do SOAP
								_cMsgRet 	:= _oWsdl:GetSoapResponse()
								_cError	:= ""
								_cWarning	:= ""
													
								//Transforma a resposta em um objeto
								_oXmlRet := XmlParser(_cMsgRet, "_", @_cError, @_cWarning)
								
								If Empty(_cError)
									If !"RESPONSE" $ UPPER(_cMsgRet)
										_cError	:= "Verificar possíveis caracteres especiais na mensagem de envio." 
									EndIf
								EndIf
																
								If Empty(_cError)
									
									_cUrlRet := "_oXmlRet:_S_ENVELOPE:_S_BODY:_"+Upper(Alltrim(_cWSMetodo))+"RESPONSE:_"+Upper(Alltrim(_cWSMetodo))+"RESULT"
									
									If Alltrim(_cWSMetodo) $ "list"
										_cUrlRet += ":_A_ACCOUNTS_LIST"
									EndIf
																	
									_oWSRet := &(_cUrlRet)
									//TRATAR ARRAY If LEN(_oWSRet) > 0
	
									If AttIsMemberOf(_oWSRet, "_A_MESSAGE") .AND. AttIsMemberOf(_oWSRet, "_A_CODE")
										_cCode		:= _oWSRet:_A_CODE:TEXT
										_cMessage	:= _oWSRet:_A_MESSAGE:TEXT
										_cError	:= ""
										_cDetErro	:= ""
										
										If _cMessage == "OK"																																				
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
					_cError 	:= "Empresa("+_cEmpXML+") / Filial ("+_cFilXML+") não localizada."
					_cDetErro	:= ""
					
					_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 			
				EndIf
				/*Else	
					_cMsg		:= ""
					_cMsgRet	:= ""			
					_cCode		:= ""
					_cError 	:= "Parâmetros método e request para a pesquisa no webservice não informados."
					_cDetErro	:= ""
					
					_aWSRet 	:= {"1", _cMsg, _cMsgRet, _cCode, _cMessage, _cError, _cDetErro} 
				EndIf*/
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
/*/{Protheus.doc} FINWS04A

Copastur - Webservice AccountService - Cadastro de centro de custos

@author CM Solutions - Allan Constantino Bonfim
@since  08/11/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FINWS04A(_nOpcA, _cEmpOri, _cFilOri, _nCTTIndice, _cCTTFilChv, _cCTTChave, _aDadosReq, _cStatus)

	Local _aRetPrc		:= ARRAY(3) 
	Local _aRequest 	:= {}
	Local _cNomeEmp 	:= ""
	Local _lContinua	:= .T.
	Local _cMsgVld		:= ""
	Local _cCusto		:= ""
	Local _cDscCusto	:= ""
	Local _cSupCusto	:= ""
	Local _cDateInc		:= "2019-01-01"
	Local _cPrefReq		:= "int" //"req"

	Default _nOpcA		:= 0
	Default _cEmpOri	:= FwCodEmp()
	Default _cFilOri	:= FwCodFil()
	Default _nCTTIndice	:= 1 
	Default _cCTTFilChv	:= ""
	Default _cCTTChave	:= ""
	Default _aDadosReq	:= {}
	Default _cStatus	:= "1"


	DbSelectArea("FL2") //Cadastro empresas Copastur
	DbSetOrder(1) //FL2_FILIAL, FL2_BKOEMP, FL2_LICENC

	If FL2->(DbSeek(FwxFilial("FL2")+_cEmpOri+_cFilOri))
		If Len(_aDadosReq) > 0
			_lContinua := .T.
		ElseIf !Empty(_cCTTChave)
			_lContinua := .T.

			DbSelectArea("CTT") //Cadastro Participantes
			DbSetOrder(_nCTTIndice) //CTT_FILIAL+CTT_CUSTO
			
			If !CTT->(DbSeek(_cCTTFilChv+_cCTTChave))		
				_lContinua := .F.
				_aRetPrc 	:= {"1", "", "", "", "", "Centro de custos não localizado.", "Centro de custos ("+_cChave+") não localizada no cadastro de centro de custos (CTT)."}
			EndIf
		Else 
			_lContinua := .F.
			_aRetPrc 	:= {"1", "", "", "", "", "Parâmetros do centro de custos não localizado.", "Necessário o envio da chave / dados da requisição para processamento."}
		EndIf
	Else 
		_lContinua := .F.
		_aRetPrc 	:= {"1", "", "", "", "", "Empresa / Filial do centro de custos não cadastrada no Copastur.",  "Parâmetros empresa ("+_cEmpOri+") / filial ("+_cFilOri+") não localizada no cadastro de empresas Copastur. Verifique o cadastro da empresa (FL2)."}
	EndIf

	If _lContinua
		//Campos Obrigatórios
		_cCusto		:= ALLTRIM(CTT->CTT_CUSTO)
		_cDscCusto	:= U_FINWSESP(CTT->CTT_DESC01)
		_cNomeEmp	:= ALLTRIM(FL2->FL2_GRPEMP)

		//Campos Opicionais
		_cSupCusto	:= "" //ALLTRIM(CTT->CTT_CCSUP)

		//Validação campos obrigatórios
		If Empty(_cCusto)
			_cMsgVld := "Campo código centro de custos em branco (CTT_CUSTO). Verifique o cadastro de centro de custos."
		EndIf

		If Empty(_cDscCusto)
			_cMsgVld := "Campo descrição de centro de custos em branco (CTT_DESC01). Verifique o cadastro de centro de custos."
		EndIf

		If Empty(_cNomeEmp)
			_cMsgVld := "Empresa Copastur em branco (FL2_GRPEMP). Verifique o cadastro de empresas Copastur."
		EndIf		
	EndIf

			
	If _lContinua		
		If _nOpcA == 1 //LIST
			
			If Len(_aDadosReq) > 0			
				_aRequest := aClone(_aDadosReq)
			Else								
				_aRequest := {}
				
				//Argumento, Conteudo, Descrição, Tipo, Tamanho, Obrigatório
				AADD(_aRequest, {_cPrefReq+":account_date_add", _cDateInc}) //Data que o Centro de custo foi adicionado ao sistema via integração - Formato: AAAA-MM-DD, date, 10, Sim
				AADD(_aRequest, {_cPrefReq+":account_flag_active", _cStatus}) //Informar se deseja listar custos ativos ou inativos - Status (0:inativo,1:ativo), numeric, 1, Sim
				AADD(_aRequest, {_cPrefReq+":company_name", _cNomeEmp}) //Nome da empresa (previamente cadastrada no OBT), varchar, 64, Sim
			EndIf
			
			_aRetPrc := U_FINWS004("list", "filters", _aRequest, _cEmpOri, _cFilOri)	
		
		ElseIf _nOpcA == 2 //GET

			If Len(_aDadosReq) > 0			
				_aRequest := aClone(_aDadosReq)
			Else								
				_aRequest := {}
			
				//Argumento, Conteudo, Descrição, Tipo, Tamanho, Obrigatório
				AADD(_aRequest, {_cPrefReq+":account_code", _cCusto}) //Código do centro de custo, varchar, 64, Sim
				AADD(_aRequest, {_cPrefReq+":account_flag_active", _cStatus}) //Informar se deseja listar custos ativos ou inativos - Status (0:inativo,1:ativo), numeric, 1, Sim
				AADD(_aRequest, {_cPrefReq+":company_name", _cNomeEmp}) //Nome da empresa (previamente cadastrada no OBT), varchar, 64, Sim
			EndIf
			
			_aRetPrc := U_FINWS004("get", "account", _aRequest, _cEmpOri, _cFilOri)	
		
		ElseIf _nOpcA == 3 //NEW

			If Len(_aDadosReq) > 0			
				_aRequest := aClone(_aDadosReq)
			Else				
				_aRequest := {}	
				//Argumento, Conteudo, Descrição, Tipo, Tamanho, Obrigatório
				//AADD(_aRequest, {_cPrefReq+":account_alias", ""}) //Sigla do Centro de Custo - varchar - 64 - Não 
				AADD(_aRequest, {_cPrefReq+":account_code", _cCusto}) //Código do centro de custo - varchar - 64 - Sim
				AADD(_aRequest, {_cPrefReq+":account_name", _cDscCusto}) //Nome do centro de custo - varchar - 64 - Sim
				AADD(_aRequest, {_cPrefReq+":account_parent_code", _cSupCusto})  //Centro de custo Pai - varchar - 64 - Não
				AADD(_aRequest, {_cPrefReq+":account_type_name", "CENTRO DE CUSTO"}) //Tipo do account Projeto Centro de Custo - varchar - 32 - Não
				AADD(_aRequest, {_cPrefReq+":company_name", _cNomeEmp}) //Nome da empresa - varchar - 64 - Sim
			EndIf
				
			_aRetPrc := U_FINWS004("new", "account", _aRequest, _cEmpOri, _cFilOri)
			
		ElseIf _nOpcA == 4 //UPDATE

			If Len(_aDadosReq) > 0			
				_aRequest := aClone(_aDadosReq)
			Else				
				_aRequest := {}	
				//Argumento, Conteudo, Descrição, Tipo, Tamanho, Obrigatório
				AADD(_aRequest, {_cPrefReq+":account_alias", ""}) //Sigla do Centro de Custo - varchar - 64 - Não 
				AADD(_aRequest, {_cPrefReq+":account_code", _cCusto})  //Código do centro de custo - varchar - 64 - Sim
				AADD(_aRequest, {_cPrefReq+":account_name", _cDscCusto}) //Nome do centro de custo - varchar - 64 - Sim
				AADD(_aRequest, {_cPrefReq+":account_parent_code", _cSupCusto})  //Centro de custo superior - varchar - 64 - Não
				AADD(_aRequest, {_cPrefReq+":account_type_name", "CENTRO DE CUSTO"})  //Tipo do account Projeto Centro de Custo - varchar - 32 - Não
				AADD(_aRequest, {_cPrefReq+":company_name", _cNomeEmp}) //Nome da empresa - varchar - 64 - Sim
			EndIf
			
			_aRetPrc := U_FINWS004("update", "account", _aRequest, _cEmpOri, _cFilOri)	
		
		ElseIf _nOpcA == 5 //DISABLE	

			If Len(_aDadosReq) > 0			
				_aRequest := aClone(_aDadosReq)
			Else				
				_aRequest := {}	
				AADD(_aRequest, {_cPrefReq+":account_alias", ""})  //Sigla do Centro de Custo - varchar - 64 - Não 
				AADD(_aRequest, {_cPrefReq+":account_code", _cCusto}) //Código do centro de custo
				AADD(_aRequest, {_cPrefReq+":account_type_name", "CENTRO DE CUSTO"}) //Tipo do account Projeto Centro de Custo
				AADD(_aRequest, {_cPrefReq+":company_name", _cNomeEmp}) //Nome da empresa
			EndIf
			
			_aRetPrc := U_FINWS004("disable", "account", _aRequest, _cEmpOri, _cFilOri)			
		EndIf
	EndIf		
		
Return _aRetPrc	


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINWS04P

Copastur - Integração Protheus -> Copastur

@author CM Solutions - Allan Constantino Bonfim
@since  08/11/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FINWS04P()

	Local cQDados		:= ""
	Local cTmpInt		:= GetNextAlias()
	Local _aRetWs		:= {}
 	Local _nTamChave	:= 0
 	Local _cChave		:= ""
 	Local aCTTDados		:= {}
	
	//If !EMPTY(cPedido) .AND. !EMPTY(cIntCod)
	
		cQDados := "SELECT ZWQ_FILIAL, ZWQ_CODIGO, ZWQ_FILORI, ZWQ_CALIAS, ZWQ_CHAVE, ZWQ_RECORI, ZWQ_TINTEG, ZWQ.R_E_C_N_O_ AS ZWQREC "+CHR(13)+CHR(10) 
		cQDados += "FROM " +RetSqlName("ZWQ")+ " ZWQ (NOLOCK) "+CHR(13)+CHR(10) 
		cQDados += "WHERE ZWQ.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10) 
		cQDados += "AND ZWQ_FILIAL = '"+FwxFilial("ZWQ")+"' "+CHR(13)+CHR(10)  
		cQDados += "AND ZWQ_FILORI = '"+FwxFilial("CTT")+"' "+CHR(13)+CHR(10) 
		cQDados += "AND ZWQ_STATUS = '01' "+CHR(13)+CHR(10) 
		cQDados += "ORDER BY ZWQ.R_E_C_N_O_ "+CHR(13)+CHR(10)
	
		cQDados := ChangeQuery(cQDados)	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados), cTmpInt)	
		
		While !(cTmpInt)->(EOF())
			_aRetWs		:= {}
			_nTamChave	:= TAMSX3("CTT_FILIAL")[1]+TAMSX3("CTT_CUSTO")[1]
			_cChave		:= PADR((cTmpInt)->ZWQ_CHAVE, _nTamChave)
			//_cChave		:= RTRIM((cTmpInt)->ZWQ_CHAVE)
			
			If (cTmpInt)->ZWQ_TINTEG == "1" //Inclusão	
				_aRetWs := U_FINWS04A(2, _cChave)
				
				If _aRetWs[1] == "0" 
					_aRetWs := U_FINWS04A(5, _cChave)
				EndIf
								
				_aRetWs := U_FINWS04A(3, _cChave)
			ElseIf (cTmpInt)->ZWQ_TINTEG == "2" //Alteração
				_aRetWs := U_FINWS04A(2, _cChave)
				
				If _aRetWs[1] == "0" 
					_aRetWs := U_FINWS04A(4, _cChave)
				EndIf
			ElseIf (cTmpInt)->ZWQ_TINTEG == "3" //Exclusão
				_aRetWs := U_FINWS04A(2, _cChave)
			
				If _aRetWs[1] == "0"
					_aRetWs := U_FINWS04A(5, _cChave)
				EndIf
			ElseIf (cTmpInt)->ZWQ_TINTEG == "4" //Consulta				
				_aRetWs := U_FINWS04A(2, _cChave)
			EndIf
			
						
			If _aRetWs[1] == "0"

				aCTTDados	:= {}
					
				AADD(aCTTDados, {"ZWQ_FILIAL"	, FwxFilial("ZWQ"), Nil})
				AADD(aCTTDados, {"ZWQ_CODIGO"	, (cTmpInt)->ZWQ_CODIGO, Nil})
				AADD(aCTTDados, {"ZWQ_FILORI"	, (cTmpInt)->ZWQ_FILORI, Nil})
				AADD(aCTTDados, {"ZWQ_CALIAS"	, (cTmpInt)->ZWQ_CALIAS, Nil})
				AADD(aCTTDados, {"ZWQ_STATUS"	, "05", Nil})
				AADD(aCTTDados, {"ZWQ_DTINTE"	, dDatabase, Nil})
				AADD(aCTTDados, {"ZWQ_USINTE"	, cUserName, Nil})				
				AADD(aCTTDados, {"ZWQ_HRINTE"	, Substr(Time(),1,5), Nil})
				AADD(aCTTDados, {"ZWQ_WSREQ"	, _aRetWs[2], Nil})
				AADD(aCTTDados, {"ZWQ_WSRET"	, _aRetWs[3], Nil})
				AADD(aCTTDados, {"ZWQ_OBSERV"	, "CODIGO :"+_aRetWs[4]+CHR(13)+CHR(10)+"MESSAGEM: "+_aRetWs[5], Nil})
				AADD(aCTTDados, {"ZWQ_ERRO"		, "", Nil})
								
				lRet := U_FINWS2GR(4, aCTTDados)
			
			Else	

				aCTTDados	:= {}
					
				AADD(aCTTDados, {"ZWQ_FILIAL"	, FwxFilial("ZWQ"), Nil})
				AADD(aCTTDados, {"ZWQ_CODIGO"	, (cTmpInt)->ZWQ_CODIGO, Nil})
				AADD(aCTTDados, {"ZWQ_FILORI"	, (cTmpInt)->ZWQ_FILORI, Nil})
				AADD(aCTTDados, {"ZWQ_CALIAS"	, (cTmpInt)->ZWQ_CALIAS, Nil})
				AADD(aCTTDados, {"ZWQ_STATUS"	, "02", Nil})
				AADD(aCTTDados, {"ZWQ_DTINTE"	, dDatabase, Nil})
				AADD(aCTTDados, {"ZWQ_HRINTE"	, Substr(Time(),1,5), Nil})
				AADD(aCTTDados, {"ZWQ_USINTE"	, cUserName, Nil})
				AADD(aCTTDados, {"ZWQ_WSREQ"	, _aRetWs[2], Nil})
				AADD(aCTTDados, {"ZWQ_WSRET"	, _aRetWs[3][3], Nil})
				AADD(aCTTDados, {"ZWQ_OBSERV"	, "CODIGO :"+_aRetWs[4]+CHR(13)+CHR(10)+"MESSAGEM: "+_aRetWs[5]+CHR(13)+CHR(10)+"ERRO: "+_aRetWs[7]+CHR(13)+CHR(10)+"DET ERRO: "+_aRetWs[6], Nil})
				AADD(aCTTDados, {"ZWQ_ERRO"		, _aRetWs[7], Nil})				
				
				lRet := U_FINWS2GR(4, aCTTDados)			
			EndIf
					
			(cTmpInt)->(DbSkip())
		EndDo
	//EndIf
	
	If Select(cTmpInt) > 0
		(cTmpInt)->(DbCloseArea())
	EndIf

Return


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINWS04I

Copastur - Geração da tabela integradora

@author CM Solutions - Allan Constantino Bonfim
@since  26/11/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FINWS04I(cEmpOri, cFilOri, cFilCTT, cCodCTT, cTpInteg, cTpProc, cTpIncl) //1=Inclusao 2=Alteracao 3=Exclusao 4=Consulta

	Local aArea			:= GetArea()
	Local cQDados		:= ""
	Local cTmpInt		:= GetNextAlias()
	Local aCTTDados		:= {}
	Local lRet			:= .T.
	
	Default cEmpOri		:= FwCodEmp()
	Default cFilOri		:= FwCodFil()
	Default cTpInteg	:= "2"
	Default cFilCTT		:= FwxFilial("CTT")
	Default cCodCTT		:= ""
	Default cTpProc		:= "3"
	Default cTpIncl		:= "2"
	
/*
	DbSelectArea("FL2") //Cadastro empresas Copastur
	DbSetOrder(1) //FL2_FILIAL, FL2_BKOEMP, FL2_LICENC	
	If !FL2->(DbSeek(FwxFilial("FL2")+cEmpOri+cFilOri))	
		cEmpOri		:= GETNEWPAR("ZZ_WSALAEP", "02")
		cFilOri		:= GETNEWPAR("ZZ_WSALAFP", "01")
	EndIf
*/
	cQDados := "SELECT CTT_FILIAL, CTT_CUSTO, CTT_DESC01, CTT_CCSUP, CTT_BLOQ, R_E_C_N_O_ AS CTTREC "+CHR(13)+CHR(10) 
	cQDados += "FROM " +RetSqlName("CTT")+ " CTT (NOLOCK) "+CHR(13)+CHR(10) 
	cQDados += "WHERE CTT.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10) 
	cQDados += "AND CTT_CLASSE = '2' "+CHR(13)+CHR(10) 

	If !Empty(cFilCTT)
		cQDados += "AND CTT_FILIAL = '"+cFilCTT+"' "+CHR(13)+CHR(10)
	EndIf
	
	If !Empty(cCodCTT)
		cQDados += "AND CTT_CUSTO = '"+cCodCTT+"' "+CHR(13)+CHR(10)
	EndIf
	  
	cQDados += "AND CTT_XALATU = 'S' "+CHR(13)+CHR(10)
	cQDados += "AND NOT EXISTS(SELECT ZWQ_CODIGO FROM " +RetSqlName("ZWQ")+ " ZWQ (NOLOCK) WHERE ZWQ.D_E_L_E_T_ = ' ' AND ZWQ_FILIAL = '"+FwxFilial("ZWQ")+"' AND ZWQ_CALIAS = 'CTT' AND ZWQ_FILALI = CTT_FILIAL AND ZWQ_CHAVE = CTT_CUSTO AND ZWQ_TINTEG = '"+cTpInteg+"' AND ZWQ_TPPROC = '"+cTpProc+"' AND ZWQ_STATUS <> '05') "+CHR(13)+CHR(10)			
	
	cQDados += "ORDER BY CTT_FILIAL, CTT_CUSTO "+CHR(13)+CHR(10)

	cQDados := ChangeQuery(cQDados)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados), cTmpInt)	
	
	While !(cTmpInt)->(EOF())
				 
		aCTTDados	:= {}
			
		AADD(aCTTDados, {"ZWQ_FILIAL"	, FwxFilial("ZWQ"), Nil})
		AADD(aCTTDados, {"ZWQ_FILORI"	, (cTmpInt)->CTT_FILIAL, Nil})
		AADD(aCTTDados, {"ZWQ_CALIAS"	, "CTT", Nil})
		AADD(aCTTDados, {"ZWQ_INDICE"	, 1, Nil})
		AADD(aCTTDados, {"ZWQ_CHAVE"	, (cTmpInt)->CTT_CUSTO, Nil})
		AADD(aCTTDados, {"ZWQ_RECORI"	, (cTmpInt)->CTTREC, Nil})
		AADD(aCTTDados, {"ZWQ_EMPORI"	, cEmpOri, Nil})
		AADD(aCTTDados, {"ZWQ_FILORI"	, cFilOri, Nil})
		AADD(aCTTDados, {"ZWQ_TPINCL"	, cTpIncl, Nil}) //1=Automatica 2=Manual
		AADD(aCTTDados, {"ZWQ_TINTEG"	, cTpInteg, Nil}) //1=Inclusao;2=Alteracao;3=Exclusao;4=Consulta
		AADD(aCTTDados, {"ZWQ_TPPROC"	, cTpProc, Nil}) //1=Envio 2=Retorno
		AADD(aCTTDados, {"ZWQ_DATA"		, dDatabase, Nil})
		AADD(aCTTDados, {"ZWQ_HORA"		, TIME(), Nil})
		AADD(aCTTDados, {"ZWQ_USUARI"	, cUserName, Nil})
		AADD(aCTTDados, {"ZWQ_STATUS"	, "01", Nil})
		
		lRet := U_FINWS2GR(3, aCTTDados)

		(cTmpInt)->(DbSkip())
	EndDo
	
	
	If Select(cTmpInt) > 0
		(cTmpInt)->(DbCloseArea())
	EndIf

	RestArea(aArea)
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINWS4CC

Copastur - Geração da tabela integradora do cadastro de Centro de Custos

@author CM Solutions - Allan Constantino Bonfim
@since  26/11/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FINWS4CC()
	
	Local aArea 	:= GetArea()
	Local lRet		:= .T.
		
	FWMsgRun(, {|| lRet := U_FINWS04I()}, "Integração Copastur", "Integradora de Centro de Custos...", 1, 60)

	If lRet
		MsgInfo("Geração dos centro de custos na tabela integradora finalizado com sucesso.", "FINWS004")
	Else
		MsgStop("Falha na geração dos centro de custos na tabela integradora.", "FINWS004")
	EndIf
	
	RestArea(aArea)

Return


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIWS4REP

Copastur - Reprocessamento da tabela integradora do cadastro de Centro de Custos

@author CM Solutions - Allan Constantino Bonfim
@since  26/11/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FIWS4REP(cFilZWQ, cCodZWQ, cStatZWQ)
	
	Local aArea 		:= GetArea()
	Local aAreaZWQ		:= ZWQ->(GetArea())
	Local lRet			:= .T.
	
	Default cFilZWQ		:= ZWQ->ZWQ_FILIAL
	Default cCodZWQ		:= ZWQ->ZWQ_CODIGO
	Default cStatZWQ	:= "01"
	
	DbSelectArea("ZWQ")
	DbSetOrder(1)
	
	If !Empty(cFilZWQ) .AND. !Empty(cCodZWQ)	
		If DbSeek(cFilZWQ+cCodZWQ)
			If MsgYesNo("Deseja reprocessar a integração do centro de custos", "FINWS004")
				aCTTDados	:= {}
					
				AADD(aCTTDados, {"ZWQ_FILIAL"	, cFilZWQ, Nil})
				AADD(aCTTDados, {"ZWQ_CODIGO"	, cCodZWQ, Nil})
				AADD(aCTTDados, {"ZWQ_STATUS"	, cStatZWQ, Nil})
				AADD(aCTTDados, {"ZWQ_DTINTE"	, CRIAVAR("ZWQ_DTINTE"), Nil})
				AADD(aCTTDados, {"ZWQ_USINTE"	, CRIAVAR("ZWQ_USINTE"), Nil})				
				AADD(aCTTDados, {"ZWQ_HRINTE"	, CRIAVAR("ZWQ_HRINTE"), Nil})
				AADD(aCTTDados, {"ZWQ_WSREQ"	, CRIAVAR("ZWQ_WSREQ"), Nil})
				AADD(aCTTDados, {"ZWQ_WSRET"	, CRIAVAR("ZWQ_WSRET"), Nil})
				AADD(aCTTDados, {"ZWQ_OBSERV"	, CRIAVAR("ZWQ_OBSERV"), Nil})
				AADD(aCTTDados, {"ZWQ_ERRO"		, CRIAVAR("ZWQ_ERRO"), Nil})
				AADD(aCTTDados, {"ZWQ_DTREPR"	, dDatabase, Nil})
				AADD(aCTTDados, {"ZWQ_HRREPR"	, Substr(Time(),1,5), Nil})
				AADD(aCTTDados, {"ZWQ_USREPR"	, cUserName, Nil})
												
				lRet := U_FINWS2GR(4, aCTTDados)
		
				If lRet
					MsgInfo("Integração "+ALLTRIM(ZWQ->ZWQ_CODIGO)+" enviada para reprocessamento com sucesso.", "FINWS004")
				Else
					MsgStop("Falha no reprocessamento da tabela integradora "+ALLTRIM(ZWQ->ZWQ_CODIGO)+".", "FINWS004")
				EndIf
			EndIf
		Else
			MsgStop("Integração "+ALLTRIM(cCodZWQ)+" não localizada na filial "+ALLTRIM(cFilZWQ)+".", "FINWS004")
			lRet := .F.
		EndIf
	Else
		MsgStop("Integração "+ALLTRIM(cCodZWQ)+" não localizada na filial "+ALLTRIM(cFilZWQ)+".", "FINWS004")
		lRet := .F.
	EndIf
		
	RestArea(aAreaZWQ)
	RestArea(aArea)

Return lRet			


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIN4WS03

Copastur - Rotina para a integração dos centros de custos via job

@author CM Solutions - Allan Constantino Bonfim
@since  09/03/2020
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FIN4WS03(_cIntOpcao, _cEmpAtu, _cFilAtu)

	Local _aArea		:= GetArea()
	Local _lRet			:= .T.
	Local _cATmpCcusto

	Default _cIntOpcao	:= "2"
	Default _cEmpAtu	:= FwCodEmp()
	Default _cFilAtu	:= FwCodFIl()


	If Select(_cATmpCcusto) > 0
		(_cATmpCcusto)->(DbCloseArea())
	EndIf	

	If _cIntOpcao == "2"
		_cATmpCcusto := U_FIWS3TMP(2,, {"2", "", "", ""}, "3")
		If Select(_cATmpCcusto) > 0 .AND. !(_cATmpCcusto)->(EOF())
			(_cATmpCcusto)->(DbGotop())
			DbSelectArea((_cATmpCcusto)->ZWQ_CALIAS)
			DbSetOrder((_cATmpCcusto)->ZWQ_INDICE) //CTT_FILIAL+CTT_CUSTO
			WHile !(_cATmpCcusto)->(EOF())
				If CTT->(Dbseek((_cATmpCcusto)->ZWQ_FILALI+(_cATmpCcusto)->ZWQ_CHAVE))
					FWMsgRun(, {|| _lRet := U_FINWS03P(_cEmpAtu, _cFilAtu, "CTT", CTT->CTT_FILIAL, CTT->CTT_CUSTO,, "3")}, "Processando Cadastro...", "Centro de Custo " + ALLTRIM(CTT->CTT_CUSTO) + " - " + ALLTRIM(CTT->CTT_DESC01))
					(_cATmpCcusto)->(DbSkip())
				EndIf
			EndDo
		EndIf									
	Else
		If Select(_cATmpCcusto) > 0
			(_cATmpCcusto)->(DbCloseArea())
		EndIf
		_cATmpCcusto := U_FIWS3TMP(4)
		If Select(_cATmpCcusto) > 0 .AND. !(_cATmpCcusto)->(EOF())
			(_cATmpCcusto)->(DbGotop())
			WHile !(_cATmpCcusto)->(EOF())
				FWMsgRun(, {|| _lRet := U_FINWS04I(_cEmpAtu, _cFilAtu, (_cATmpCcusto)->CTT_FILIAL, (_cATmpCcusto)->CTT_CUSTO, "2", "3", "1")}, "Integrando Cadastro...", "Centro de Custo " + ALLTRIM((_cATmpCcusto)->CTT_CUSTO) + " - " + ALLTRIM((_cATmpCcusto)->CTT_DESC01))
				FWMsgRun(, {|| _lRet := U_FINWS03P(_cEmpAtu, _cFilAtu, "CTT", (_cATmpCcusto)->CTT_FILIAL, (_cATmpCcusto)->CTT_CUSTO,, "3")}, "Processando Cadastro...", "Centro de Custo " + ALLTRIM((_cATmpCcusto)->CTT_CUSTO) + " - " + ALLTRIM((_cATmpCcusto)->CTT_DESC01))
				(_cATmpCcusto)->(DbSkip())
			EndDo
		EndIf

		If Select(_cATmpCcusto) > 0
			(_cATmpCcusto)->(DbCloseArea())
		EndIf	

		_cATmpCcusto := U_FIWS3TMP(2,, {"2", "", "", ""}, "3")
		If Select(_cATmpCcusto) > 0 .AND. !(_cATmpCcusto)->(EOF())
			(_cATmpCcusto)->(DbGotop())
			DbSelectArea((_cATmpCcusto)->ZWQ_CALIAS)
			DbSetOrder((_cATmpCcusto)->ZWQ_INDICE) //CTT_FILIAL+CTT_CUSTO
			WHile !(_cATmpCcusto)->(EOF())
				If CTT->(Dbseek((_cATmpCcusto)->ZWQ_FILALI+(_cATmpCcusto)->ZWQ_CHAVE))
					FWMsgRun(, {|| _lRet := U_FINWS03P(_cEmpAtu, _cFilAtu, "CTT", CTT->CTT_FILIAL, CTT->CTT_CUSTO,, "3")}, "Processando Cadastro...", "Centro de Custo " + ALLTRIM(CTT->CTT_CUSTO) + " - " + ALLTRIM(CTT->CTT_DESC01))
					(_cATmpCcusto)->(DbSkip())
				EndIf
			EndDo
		EndIf	
	EndIf

	If Select(_cATmpCcusto) > 0
		(_cATmpCcusto)->(DbCloseArea())
	EndIf	
	
	RestArea(_aArea)
	
Return _lRet
