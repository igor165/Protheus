#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} TMKI070O

Funcao de integracao com o adapter EAI para recebimento e envio de informações
cadastro contatos (Contact) utilizando o conceito de mensagem unica JSON

@sample		TMKI070O( oEAIObEt, nTypeTrans, cTypeMessage ) 

@param		oEAIObEt 
@param		nTypeTrans 
@param		cTypeMessage

@return		lRet 
@return		ofwEAIObj
@return		cMsgUnica

@author		Totvs Cascavel
@since		29/08/2018
@version	12
/*/
//------------------------------------------------------------------------------
Function TMKI070O( oEAIObEt, nTypeTrans, cTypeMessage ) 

	Local aErroAuto := {}
	Local aContato	:= {}	
	Local cAlias    := "SU5"
	Local cCampo    := "U5_CODCONT"
	Local cCodeInt  := ""	
	Local cEvento   := "upsert"
	Local cExtID    := ""
	Local cIntID    := ""
	Local cLogErro	:= ""
	Local cMarca    := "PROTHEUS"
	Local cMsgUnica := "Contact"
	Local lRet      := .T. 
	Local lDelete	:= .F.
	Local lMsblql	:= AllTrim(GetSx3Cache("U5_MSBLQL", "X3_CAMPO")) == "U5_MSBLQL"
	Local nLisOfCm	:= 0
	Local nOpc    	:= 0
	Local nX		:= 0
	Local ofwEAIObj	:= FwEAIobj():New()
	Local oModel    := NIL
	
	Default	oEAIObEt := Nil
	
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	
	Do Case
		//--------------------------------------
		//envio mensagem
		//--------------------------------------
		Case nTypeTrans == TRANS_SEND
			oModel := FwModelActive()
			
			If lDelete := !ALTERA .AND. !INCLUI
				cEvento := 'delete'
			EndIf		
			
			cIntID	:= cEmpAnt + '|' + xFilial("SU5") + '|' + SU5->U5_CODCONT

			//Montagem da mensagem
			ofwEAIObj:Activate()
			ofwEAIObj:setEvent(cEvento)	
			
			ofwEAIObj:setprop("CompanyId", cEmpAnt)
			ofwEAIObj:setprop("BranchId", cFilAnt)
			ofwEAIObj:setprop("CompanyInternalId", cEmpAnt + '|' + cFilAnt)
			ofwEAIObj:setprop("Code", ALLTRIM(SU5->U5_CODCONT))
			ofwEAIObj:setprop("InternalId", ALLTRIM(cIntID))
			ofwEAIObj:setprop("Name", ALLTRIM(SU5->U5_CONTAT))
			
			If !Empty(SU5->U5_CPF)
				ofwEAIObj:setprop('GovernmentalInformation',{},'Tax',,.T.)
       			ofwEAIObj:get("GovernmentalInformation")[1]:setprop("Name"   	, "CPF",,.T.)
	        	ofwEAIObj:get("GovernmentalInformation")[1]:setprop("Scope"     , "Federal",,.T.)
	        	ofwEAIObj:get("GovernmentalInformation")[1]:setprop("Id"       	, Alltrim(SU5->U5_CPF),,.T.)			
			Endif
			
			oAddress := ofwEAIObj:setprop("Address")
			oAddress:setprop("Address", ALLTRIM(SU5->U5_END) )
			oAddress:setprop("City")
			oAddress:getPropValue("City"):setprop("CityCode", ALLTRIM(SU5->U5_MUN) )
			oAddress:getPropValue("City"):setprop("CityInternalId", ALLTRIM(SU5->U5_MUN) )
			oAddress:getPropValue("City"):setprop("CityDescription", ALLTRIM(SU5->U5_MUN) )
			oAddress:setprop("District", ALLTRIM(SU5->U5_BAIRRO) )
			oAddress:setprop("State")
			oAddress:getPropValue("State"):setprop("stateId", ALLTRIM(SU5->U5_EST) )
			oAddress:getPropValue("State"):setprop("StateInternalId", ALLTRIM(SU5->U5_EST) )
			oAddress:getPropValue("State"):setprop("StateDescription", Alltrim(POSICIONE("SX5",1,xFilial("SX5")+"12"+SU5->U5_EST,"X5_DESCRI")) )
			oAddress:setprop("Country")
			oAddress:getPropValue("Country"):setprop("CountryCode", ALLTRIM(SU5->U5_PAIS) )
			oAddress:getPropValue("Country"):setprop("CountryInternalId", ALLTRIM(SU5->U5_PAIS) )
			oAddress:setprop("ZIPCode", ALLTRIM(SU5->U5_CEP) )
			
			nLisOfCm++
			ofwEAIObj:setprop('ListOfCommunicationInformation',{},'CommunicationInformation',,.T.)
			ofwEAIObj:get("ListOfCommunicationInformation")[nLisOfCm]:setprop("PhoneNumber", Alltrim(SU5->U5_FONE),,.T.)
			ofwEAIObj:get("ListOfCommunicationInformation")[nLisOfCm]:setprop("FaxNumber", Alltrim(SU5->U5_FAX),,.T.)
			ofwEAIObj:get("ListOfCommunicationInformation")[nLisOfCm]:setprop("DiallingCode", Alltrim(SU5->U5_DDD),,.T.)
			ofwEAIObj:get("ListOfCommunicationInformation")[nLisOfCm]:setprop("InternationalDiallingCode", Alltrim(SU5->U5_CODPAIS),,.T.)
			ofwEAIObj:get("ListOfCommunicationInformation")[nLisOfCm]:setprop("HomePage", Alltrim(SU5->U5_URL),,.T.)
			ofwEAIObj:get("ListOfCommunicationInformation")[nLisOfCm]:setprop("Email", Alltrim(SU5->U5_EMAIL),,.T.)
			
			ofwEAIObj:setprop("Treatment", ALLTRIM(SU5->U5_TRATA))
			ofwEAIObj:setprop("Gender", ALLTRIM(SU5->U5_SEXO))
			ofwEAIObj:setprop("Birthday", TKI070DtStamp(SU5->U5_NIVER))
			ofwEAIObj:setprop("Requester", ALLTRIM(SU5->U5_SOLICTE))
			If lMsblql
				ofwEAIObj:setprop("Situation", ALLTRIM(SU5->U5_MSBLQL))
			Endif
			
			//Exclui o De/Para 
			If lDelete
				CFGA070MNT(NIL, cAlias, cCampo, NIL, cIntID, lDelete)
			Endif
		
		//--------------------------------------
		//recebimento mensagem
		//--------------------------------------	
		Case nTypeTrans == TRANS_RECEIVE .And. Type("oEAIObEt") != Nil
			Do Case
			
				//--------------------------------------
	  			//whois
	  			//--------------------------------------
				Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
					cWhois := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cWhois := "1.000"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Whois", cWhois)
				
				//--------------------------------------
				//resposta da mensagem Unica TOTVS
				//--------------------------------------
				Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
					//Verifica tipo do evento Inclusao/Alteracao/Exclusao
					If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == 'DELETE'
						lDelete := .T.					
					Endif	
					
					If oEAIObEt:getHeaderValue("ProductName") !=  nil
						cMarca := oEAIObEt:getHeaderValue("ProductName")
					Endif
					
					If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin") != nil
						cIntID := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin")	
					Endif				
					
					If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination") != nil
						cExtID := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination")
					Endif	
					
					If !Empty(cIntID) .And. !Empty(cExtID) 
						CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID, lDelete)
					Endif				
				
				//--------------------------------------
				//chegada de mensagem de negocios
				//--------------------------------------
				Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
					cEvento  := Upper(AllTrim(oEAIObEt:getEvent()))
					cMarca   := oEAIObEt:getHeaderValue("ProductName")
					
					cExtID   := oEAIObEt:getPropValue("InternalId") 
					cIntId	 := ""
					cCodeInt := AllTrim(CFGA070INT(cMarca, cAlias, cCampo, cExtID))

					If !Empty(cCodeInt)
						cCodeInt := Separa(cCodeInt,"|")[3]
					Endif

					If cEvento == 'UPSERT' .Or. cEvento == 'REQUEST'
						If !Empty(cCodeInt) .And. SU5->(DbSeek(xFilial('SU5') + cCodeInt))
							cIntId := CFGA070INT(cMarca, cAlias, cCampo, cExtID)
							nOpc := 4
						Else
							nOpc := 3

							If Type(oEAIObEt:getPropValue("Code")) != "U" .And. !Empty(oEAIObEt:getPropValue("Code"))
								cCodeInt := Alltrim(oEAIObEt:getPropValue("Code"))
							Endif 
							
							cCodeInt := TMK070RetCd(cCodeInt)							
							cIntID	 := cEmpAnt + '|' + xFilial("SU5") + '|' + cCodeInt
						Endif
					ElseIf cEvento == 'DELETE'
						If SU5->(DbSeek(xFilial('SU5') + cCodeInt))
							nOpc := 5
							cIntId := CFGA070INT(cMarca, cAlias, cCampo, cExtID)
							lDelete := .T.
						Else
							lRet := .F.
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0001  // "Registro não encontrado no Protheus."
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)	
						Endif
					EndIf
					
					If lRet						
						aAdd(aContato,{"U5_FILIAL"	,xFilial('SU5')	,nil})
						aAdd(aContato,{"U5_CODCONT"	,cCodeInt ,nil})
						If oEAIObEt:getPropValue("Name") != nil
							aAdd(aContato,{"U5_CONTAT"	,AllTrim(oEAIObEt:getPropValue("Name")) ,nil})
						Endif
						//CPF
						If oEAIObEt:getPropValue("GovernmentalInformation") != nil
							oTaxes := oEAIObEt:getPropValue("GovernmentalInformation")
							For nX := 1 To Len( oTaxes )
								If oTaxes[nX]:getPropValue("Name") != nil
									If RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "CPF"
										aAdd(aContato,{"U5_CPF"	,oTaxes[nX]:getPropValue("Id") ,nil})
									Endif
								Endif
							Next nX						
						Endif
						//Endereco
						If oEAIObEt:getPropValue("Address") != nil  
							If oEAIObEt:getPropValue("Address"):getPropValue("Address") != nil
								aAdd(aContato,{"U5_END"	,AllTrim(oEAIObEt:getPropValue("Address"):getPropValue("Address")) ,nil})
							Endif 
							If oEAIObEt:getPropValue("Address"):getPropValue("District") != nil
								aAdd(aContato,{"U5_BAIRRO"	,AllTrim(oEAIObEt:getPropValue("Address"):getPropValue("District")) ,nil})	
							Endif
							If oEAIObEt:getPropValue("Address"):getPropValue("ZIPCode") != nil
								aAdd(aContato,{"U5_CEP"	,AllTrim(oEAIObEt:getPropValue("Address"):getPropValue("ZIPCode")) ,nil})	
							Endif
							If oEAIObEt:getPropValue("Address"):getPropValue("City"):getPropValue("CityDescription") != nil
								aAdd(aContato,{"U5_MUN"	,oEAIObEt:getPropValue("Address"):getPropValue("City"):getPropValue("CityDescription") ,nil})
							Endif 						
							If oEAIObEt:getPropValue("Address"):getPropValue("State"):getPropValue("stateId") != nil
								aAdd(aContato,{"U5_EST"	,oEAIObEt:getPropValue("Address"):getPropValue("State"):getPropValue("stateId") ,nil})
							Endif 	
							If oEAIObEt:getPropValue("Address"):getPropValue("Country"):getPropValue("CountryCode") != nil
								aAdd(aContato,{"U5_PAIS" ,oEAIObEt:getPropValue("Address"):getPropValue("Country"):getPropValue("CountryCode") ,nil})
							Endif						
						Endif
						//Dados de comunicacao
						If oEAIObEt:getPropValue("ListOfCommunicationInformation") != nil 
							oLtOfCom := oEAIObEt:getPropValue("ListOfCommunicationInformation")
						
							For nX := 1 To Len(oLtOfCom)
								If oLtOfCom[nX]:getpropvalue('PhoneNumber') != nil  
									aAdd(aContato,{"U5_FONE"	,upper(AllTrim(oLtOfCom[nX]:getpropvalue('PhoneNumber'))) ,nil})
								Endif
								
								If oLtOfCom[nX]:getpropvalue('FaxNumber') != nil  
									aAdd(aContato,{"U5_FAX"	,upper(AllTrim(oLtOfCom[nX]:getpropvalue('FaxNumber'))) ,nil})
								Endif
								
								If oLtOfCom[nX]:getpropvalue('DiallingCode') != nil  
									aAdd(aContato,{"U5_DDD"	,upper(AllTrim(oLtOfCom[nX]:getpropvalue('DiallingCode'))) ,nil})
								Endif

								If oLtOfCom[nX]:getpropvalue('InternationalDiallingCode') != nil  
									aAdd(aContato,{"U5_CODPAIS"	,upper(AllTrim(oLtOfCom[nX]:getpropvalue('InternationalDiallingCode'))) ,nil})
								Endif
																
								If oLtOfCom[nX]:getpropvalue('Email') != nil  
									aAdd(aContato,{"U5_EMAIL"	,AllTrim(oLtOfCom[nX]:getpropvalue('Email')) ,nil})
								Endif
								 
								If oLtOfCom[nX]:getpropvalue('HomePage') != nil
									aAdd(aContato,{"U5_URL"	,AllTrim(oLtOfCom[nX]:getpropvalue('HomePage'))	,nil})
								Endif									
							Next
						Endif
						
						aAdd(aContato,{"U5_TRATA"	,AllTrim(oEAIObEt:getPropValue("Treatment"))       	,nil})
						aAdd(aContato,{"U5_SEXO"	,AllTrim(oEAIObEt:getPropValue("Gender"))          	,nil})
						aAdd(aContato,{"U5_NIVER"	,TKI070DtStamp(oEAIObEt:getPropValue("Birthday"),.F.),nil})
						aAdd(aContato,{"U5_SOLICTE"	,AllTrim(oEAIObEt:getPropValue("Requester"))       	,nil})
						If lMsblql
							aAdd(aContato,{"U5_MSBLQL"	,AllTrim(oEAIObEt:getPropValue("Situation"))    ,nil})
						Endif
						
						aContato := FWVetByDic(aContato,"SU5",.F.)
						MSExecAuto({|x,y,z|TMKA070(x,y,,,z)},aContato,nOpc,.T.)
						
						If lMsErroAuto
			         		aErroAuto := GetAutoGRLog()
			             	cLogErro := ""
				
							nContErro := Len(aErroAuto)
			               	For nX := 1 To nContErro
			                  	cLogErro += aErroAuto[nX] + Chr(10)
			               	Next nX
				               	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
				         	ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
							DisarmTransaction()
				      		lRet := .F.		           
						Endif			
						If lRet
							// Monta o JSON de retorno
							ofwEAIObj:Activate()
																							
							ofwEAIObj:setProp("ReturnContent")
														
							ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
							ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Name",cMsgUnica,,.T.)
							ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Origin",cExtID,,.T.)
							ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Destination",cIntID,,.T.)				
							If nOpc <> 5
								CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID,.F.)
							Else
								CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID,.T.)
							Endif
						Endif
					EndIf
			EndCase
	EndCase

	aSize(aContato,0)
	aContato := {}

	aSize(aErroAuto, 0)
	aErroAuto := {}

Return { lRet, ofwEAIObj, cMsgUnica }

//------------------------------------------------------------------
/*/{Protheus.doc} TMK070RetCd()
Retorna o proximo numero do contato

@param		cCodSU5	 , Char, Numero do contato
@author 	Squad CRM
@since 		25/02/2018
@version 	P12
@return 	cReturno , Char,  Numero do contato
/*/
//-------------------------------------------------------------------

Static Function TMK070RetCd(cCodSU5)

	Local aAreaSU5	:= SU5->(GetArea())
	Local cFilSU5	:= xFilial("SU5")
	Local lRet		:= .T.
	Local nStack	:= 0

	SU5->(DbSetOrder(1))
	If Empty(cCodSU5) .Or. SU5->(DbSeek(cFilSU5 + cCodSU5))
		cCodSU5 := GetSXENum('SU5','U5_CODCONT')
		nStack	:= GetSX8Len()
		While lRet
			lRet := SU5->(DbSeek(cFilSU5 + cCodSU5))
			If lRet
				While GetSX8Len() > nStack 
					ConfirmSX8()
				EndDo
				cCodSU5 := GetSXENum('SU5','U5_CODCONT')
			Endif
		Enddo
	Endif

	RestArea(aAreaSU5)
	aSize(aAreaSU5,0)

Return cCodSU5

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TXDTSTAMP

Função que retorna o respectivo valor de campos utilizados como LÓGICO / BOOLEANO

@sample 	TxDtStamp(xInfo, lTipo, lOnlyDate)
@param		xInfo		- Variável que pode ser String/Lógica/Inteiro com valor a ser comparado
			lTipo		- Se .T. xRet := Formato "AAAA-MM-DDt00:00:00-03:00", Se .F. xRet := "DD/MM/AAAA"
			lOnlyDate	- Define se o retorno será só com Data ou Junto com o Horario (Apenas para lTipo = .T.)
@return   	xRet		- Se lTipo = .T. xRet := Formato "AAAA-MM-DDt00:00:00-03:00", Se .F. xRet := "DD/MM/AAAA"
@author	Jacomo Lisa
@since		11/11/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TKI070DtStamp(xInfo, lTipo, lOnlyDate)

Local xRet  := ""
Local nType := 3
Local cTime := Time()

Default lTipo     := .T.
Default xInfo     := Date()
Default lOnlyDate := .T.

//Tipo = .T. -> Funcionalidade normal do TimeStampo. Retorno no formato "AAAA-MM-DDt00:00:00-03:00"
If !Empty(xInfo)
	If lTipo
	   
	   If ValType(xInfo) == "C"
	       xInfo := cToD(xInfo)
	   EndIf
	
	   xRet := FWTimeStamp( nType, xInfo, cTime )
	   
	   If lOnlyDate // Tratamento para retornar somente "AAAA-MM-DD"
	      xRet := SubStr(xRet , 1, At("T", xRet)-1 )
	   EndIf
	
	//Tipo = .F. -> Inverte o formato de TimeStamp para data Normal. Retorna uma data   
	Else
	   
	   //Pegando a data:
	   If At("T", xInfo) > 0
	      xInfo := SubStr(xInfo , 1, At("T", xInfo)-1 ) //"2011-12-20T00:00:00-03:00" -> "2011-12-20"
	   EndIf
	   
	   //Retirando os '-':
	   xInfo := StrTransf(xInfo,"-","") //"2011-12-20" -> "20111220"
	   
	   //Formatando a data
	   xRet := SToD(xInfo) //"20111220" -> "20/12/2011"
	   
	EndIf
Else
	xRet := If(!lTipo,SToD(xInfo),"")
EndIf

Return xRet