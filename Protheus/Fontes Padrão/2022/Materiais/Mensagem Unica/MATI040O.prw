#include "MATI040.CH"  
#Include "PROTHEUS.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE "FWADAPTEREAI.CH"
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATI040O   ºAutor  ³Totvs Cascavel     º Data ³  10/05/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e  º±±
±±º          ³ envio de informações do cadastro de Vendedor (SE3)         º±±
±±º          ³ utilizando o conceito de mensagem unica JSON.        	  º±±
±±º          ³ 						                                      º±±
±±º          ³ Versao convertida 2.003                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATI040O                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATI040O( oEAIObEt, nTypeTrans, cTypeMessage)

	Local aAux			:= {} 
	Local aRetMsg		:= {}
	Local aDadosSA3		:= {}	
	Local aFornec 		:= {}
    Local aRetExec		:= {}
	Local cValInt		:= ""
	Local cEvent		:= "upsert"
	Local cValExt		:= ""
	Local cAliasEnt		:= "SA3"
	Local cCampo		:= "A3_COD"
	Local cMarca		:= ""
	Local cCode			:= ""
	Local lIniPad 		:= ( !Empty( GetSX3Cache( "A3_COD", "X3_RELACAO" ) ) )
    Local cExtFornec 	:= ""
	Local cFornec 		:= ""
	Local cLoja 		:= ""
	Local cComissao 	:= "" 
	Local lHotel 		:= SuperGetMV( "MV_INTHTL", , .F. )
	Local cVendActiv	:= ""
	Local cTipoVend		:= ""
	Local cMsgUnica  	:= "SELLER"
	Local lRet			:= .T.
	Local lManut		:= .T.
    Local nOpcx			:= 0
	Local ofwEAIObj	    := FWEAIobj():New()
	
	//--------------------------------------
	//envio mensagem
	//--------------------------------------
	If nTypeTrans == TRANS_SEND
		
		cValInt := IntVenExt(cEmpAnt,/*cFilAnt*/,SA3->A3_COD)[2]
		
		If ( !INCLUI .AND. !ALTERA )
			cEvent := "delete"
			CFGA070Mnt(  Nil, cAliasEnt, cCampo,	Nil, cValInt, .T. ) // remove do de/para
		EndIf
		
		//Montagem da mensagem Vendedor
		ofwEAIObj:Activate()
		ofwEAIObj:setEvent(cEvent)	
		
		ofwEAIObj:setprop("CompanyId", cEmpAnt)
		ofwEAIObj:setprop("BranchId", cFilAnt)
		ofwEAIObj:setprop("CompanyInternalId", cEmpAnt + '|' + cFilAnt)
		ofwEAIObj:setprop("Code", AllTrim(SA3->A3_COD))
		ofwEAIObj:setprop("InternalId", cValInt)
		ofwEAIObj:setprop("Name", AllTrim(SA3->A3_NOME))
		ofwEAIObj:setprop("ShortName", AllTrim(SA3->A3_NREDUZ))
		ofwEAIObj:setprop("Active", IIf(SA3->A3_MSBLQL=="2","0","1"))
		ofwEAIObj:setprop("Login", SA3->A3_CODUSR)
		ofwEAIObj:setprop("SellerPassword", SA3->A3_SENHA)
		ofwEAIObj:setprop("RepresentativeType", SA3->A3_TIPO)
		ofwEAIObj:setprop("PersonalIdentification", SA3->A3_CGC)
		
		ofwEAIObj:setprop("SalesChargeInformation")
		If !Empty(SA3->A3_FORNECE) .And. !Empty(SA3->A3_LOJA)
			ofwEAIObj:getPropValue("SalesChargeInformation"):setprop("CustomerVendorInternalId", IntForExt(,,SA3->A3_FORNECE ,SA3->A3_LOJA)[2] )
			ofwEAIObj:getPropValue("SalesChargeInformation"):setprop("SalesChargeInterface", SA3->A3_GERASE2 )
		Else
			ofwEAIObj:getPropValue("SalesChargeInformation"):setprop("CustomerVendorInternalId", "" )
			ofwEAIObj:getPropValue("SalesChargeInformation"):setprop("SalesChargeInterface", "" )
		EndIf
		
		ofwEAIObj:setprop("Address")
		ofwEAIObj:getPropValue("Address"):setprop("Address", AllTrim( SA3->A3_END ) )
		ofwEAIObj:getPropValue("Address"):setprop("District", AllTrim( SA3->A3_BAIRRO ) )
		ofwEAIObj:getPropValue("Address"):setprop("City")
		ofwEAIObj:getPropValue("Address"):getPropValue("City"):setprop("Description", AllTrim( SA3->A3_MUN ) )
		ofwEAIObj:getPropValue("Address"):setprop("State")
		ofwEAIObj:getPropValue("Address"):getPropValue("State"):setprop("StateCode", AllTrim( SA3->A3_EST ) )
		ofwEAIObj:getPropValue("Address"):getPropValue("State"):setprop("StateInternalId", AllTrim( SA3->A3_EST ) )
		ofwEAIObj:getPropValue("Address"):getPropValue("State"):setprop("StateDescription", Rtrim(Posicione("SX5",1, xFilial("SX5") + "12" + SA3->A3_EST, "X5DESCRI()" )) )
	
		ofwEAIObj:setprop("CommunicationInformation")
		ofwEAIObj:getPropValue("CommunicationInformation"):setprop("PhoneDDD", SA3->A3_DDDTEL )
		ofwEAIObj:getPropValue("CommunicationInformation"):setprop("PhoneNumber", AllTrim(SA3->A3_TEL) )
		ofwEAIObj:getPropValue("CommunicationInformation"):setprop("FaxDDD", "" )
		ofwEAIObj:getPropValue("CommunicationInformation"):setprop("FaxNumber", AllTrim(SA3->A3_FAX) )
		ofwEAIObj:getPropValue("CommunicationInformation"):setprop("FaxNumberExtension", "" )
		ofwEAIObj:getPropValue("CommunicationInformation"):setprop("HomePage", AllTrim(SA3->A3_HPAGE) )
		ofwEAIObj:getPropValue("CommunicationInformation"):setprop("Email", AllTrim(SA3->A3_EMAIL) )

		If ExistBlock("M040OENV")
			cJson := ExecBlock("M040OENV",.F.,.F.,{cEvent, ofwEAIObj:getJSON()})
			If ValType( cJson ) == "C" .And. !( Empty( cJson ) )
				ofwEAIObj:loadJson(cJson)
			Endif
		EndIf	
   	//--------------------------------------
	//recebimento mensagem
	//--------------------------------------
	ElseIf nTypeTrans == TRANS_RECEIVE .And. ValType( oEAIObEt ) == 'O' 
		
		Do Case
			//--------------------------------------
			//resposta da mensagem Unica TOTVS
			//--------------------------------------
			Case ( cTypeMessage == EAI_MESSAGE_RESPONSE )
				
				// Verifica se a marca foi informada
	      		If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") ) 
	      			cMarca := oEAIObEt:getHeaderValue("ProductName")
	      			
					// Verifica se o código interno foi informado
	      			If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin") != nil
						cValInt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin")
					Endif		
								
				 	// Verifica se o código externo foi informado
				  	If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination") != nil
				   		cValExt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination")
				  	Endif				
					
					If !Empty(cValInt) .And. !Empty(cValExt)
						// Se não houve erros no parse
					 	If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == 'DELETE'
					  		// Exclui o registro na tabela XXF (de/para)
					      	CFGA070Mnt(cMarca, cAliasEnt, cCampo, cValExt, cValInt,.T.)
						Else
					        // Insere / Atualiza o registro na tabela XXF (de/para)
					      	CFGA070Mnt(cMarca, cAliasEnt, cCampo, cValExt, cValInt)
					    EndIf					
					Else
				     	lRet    := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0007 //"Não enviado conteúdo de retorno para cadastro de de-para"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
					Endif
	      		Endif

			//--------------------------------------
			//chegada de mensagem de negocios
			//--------------------------------------
			Case ( cTypeMessage == EAI_MESSAGE_BUSINESS ) 
				
				SA3->(DbSetOrder(1))
				
				cEvent := AllTrim(oEAIObEt:getEvent())
				
				If !Empty( cEvent )
				
					If oEAIObEt:getPropValue("Code") != nil
						cCode := oEAIObEt:getPropValue("Code")
					Endif
					
					If oEAIObEt:getHeaderValue("ProductName") !=  nil  
	      				cMarca := oEAIObEt:getHeaderValue("ProductName")
	      			Endif
					
				  	If oEAIObEt:getPropValue("InternalId") != nil 
				   		cValExt := AllTrim( oEAIObEt:getPropValue("InternalId") )
				  	Endif						
					
					If !Empty( cValExt )
						
						cValInt := CFGA070Int( cMarca, cAliasEnt, cCampo, cValExt )
						
						//Verifica qual a acao (Inclusao/Alteracao ou Exclusao)
						If ( Upper(cEvent) == "UPSERT" ) .Or. ( Upper(cEvent) == "REQUEST" )
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
							If !Empty( cCode )				
								//Valida tamanho do codigo enviado
								If TamSx3("A3_COD")[1] >= Len(cCode) 
									aAdd( aDadosSA3, { "A3_COD", cCode , Nil } )
								Else
									lRet := .F.
									cLogErro := ""	
									ofwEAIObj:Activate()
									ofwEAIObj:setProp("ReturnContent")
									cLogErro := STR0017 + " " + cCode + " " + STR0018 + Chr(10) //#"O Codigo do Vendedor" ##"possui tamanho maior que o permitido."
									cLogErro += STR0019 + cValToChar( TamSx3("A3_COD")[1] ) + Chr(10) //#"Maximo:"
									cLogErro += STR0020 + cValToChar( Len( AllTrim( cCode ) ) ) //#"Enviado:" 
									ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
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
						If oEAIObEt:getPropValue("Name") != nil
							aAdd( aDadosSA3, { "A3_NOME",oEAIObEt:getPropValue("Name"), Nil } )
						Endif
						
						//Nome reduzido do vendedor
						If oEAIObEt:getPropValue("ShortName") != nil
							aAdd( aDadosSA3, { "A3_NREDUZ", oEAIObEt:getPropValue("ShortName"), Nil } )
						Endif
						
						//CPF/CNPJ
						If oEAIObEt:getPropValue("PersonalIdentification") != nil
							aAdd( aDadosSA3, { "A3_CGC", oEAIObEt:getPropValue("PersonalIdentification"), Nil } )
						Endif
						
						//Declarar
						If oEAIObEt:getPropValue("Login") != nil
							cLogin := oEAIObEt:getPropValue("Login")
						Endif
				
						If !Empty(cLogin)
							//Verifica se o usuario passado esta cadastrado no sistema para gravar o codigo
							PswOrder(2)	//Ordena por nome de usuario
							PswSeek( cLogin , .T. )
							
							If ( PswId() <> "" )
								aAdd( aDadosSA3, { "A3_CODUSR", PswId(), Nil } )
							EndIf
						EndIf 
						
						//Tipo do Vendedor
						If oEAIObEt:getPropValue("RepresentativeType") != nil 
							cTipoVend := oEAIObEt:getPropValue("RepresentativeType")
							aAdd( aDadosSA3, { "A3_TIPO", cTipoVend, Nil } )
						EndIf 
						
						//Endereco
						If oEAIObEt:getpropvalue("Address") != nil
							//Endereco do vendedor
							If oEAIObEt:getPropValue("Address"):getPropValue("Address") != nil 
								aAdd( aDadosSA3, { "A3_END", AllTrim(oEAIObEt:getPropValue("Address"):getPropValue("Address")), Nil } )
							Endif
							
							//Bairro do vendedor
							If oEAIObEt:getPropValue("Address"):getPropValue("District") != nil 
								aAdd( aDadosSA3, { "A3_BAIRRO", AllTrim(oEAIObEt:getPropValue("Address"):getPropValue("District")), Nil } )
							Endif
							
							//Cidade do vendedor
							If oEAIObEt:getPropValue("Address"):getPropValue("City") != nil
								If oEAIObEt:getPropValue("Address"):getPropValue("City"):getPropValue("Description") != nil
									aAdd( aDadosSA3, { "A3_MUN", AllTrim(oEAIObEt:getPropValue("Address"):getPropValue("City"):getPropValue("Description")), Nil } )
								Endif
							Endif
						
							//Estado do vendedor
							If oEAIObEt:getPropValue("Address"):getPropValue("State") != nil
								If oEAIObEt:getPropValue("Address"):getPropValue("State"):getPropValue("StateInternalId") != nil
									aAdd( aDadosSA3, { "A3_EST", AllTrim(oEAIObEt:getPropValue("Address"):getPropValue("State"):getPropValue("StateInternalId")), Nil } )
								Endif
							Endif
						Endif
						
						//Cep do Vendedor						
						If oEAIObEt:getPropValue("ZipCode") != nil 
							aAdd( aDadosSA3, { "A3_CEP", AllTrim(oEAIObEt:getPropValue("ZipCode")), Nil } )
						EndIf
						
						//Dados comunicacao
						If oEAIObEt:getpropvalue("CommunicationInformation") != nil
							
							//Telefone do vendedor
							If oEAIObEt:getpropvalue("CommunicationInformation"):getpropvalue("PhoneDDD") != nil
								aAdd( aDadosSA3, { "A3_DDDTEL", AllTrim(oEAIObEt:getpropvalue("CommunicationInformation"):getpropvalue("PhoneDDD")), Nil } )
							Endif
							
							//Telefone do vendedor
							If oEAIObEt:getpropvalue("CommunicationInformation"):getpropvalue("PhoneNumber") != nil
								aAdd( aDadosSA3, { "A3_TEL", AllTrim(oEAIObEt:getpropvalue("CommunicationInformation"):getpropvalue("PhoneNumber")), Nil } )
							Endif
							
							//Email do vendedor
							If oEAIObEt:getpropvalue("CommunicationInformation"):getpropvalue("Email") != nil
								aAdd( aDadosSA3, { "A3_EMAIL", AllTrim(oEAIObEt:getpropvalue("CommunicationInformation"):getpropvalue("Email")), Nil } )
							Endif
						Endif
						
						//Dados comissao
						If oEAIObEt:getpropvalue("SalesChargeInformation") != nil 
							//Código de fornecedor para comissão	
							If oEAIObEt:getpropvalue("SalesChargeInformation"):getpropvalue("CustomerVendorInternalId") != nil				
								cExtFornec := AllTrim( oEAIObEt:getpropvalue("SalesChargeInformation"):getpropvalue("CustomerVendorInternalId") )
							Endif
							
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
										cLogErro := ""	
										ofwEAIObj:Activate()
										ofwEAIObj:setProp("ReturnContent")
										cLogErro := STR0010 //"Fornecedor não encontrado no Protheus."
										ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)	
									Endif
								Endif		
								aSize( aFornec, 0 )
							Else
								//Se for integração com hotelaria, obriga a informar o fornecedor
								If lHotel
									lRet := .F.  
									cLogErro := ""	
									ofwEAIObj:Activate()
									ofwEAIObj:setProp("ReturnContent")
									cLogErro := STR0011 //"Fornecedor não informado."
									ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)	
								Endif		
							EndIf
							
							//Interface de comissão
							If oEAIObEt:getpropvalue("SalesChargeInformation"):getpropvalue("SalesChargeInterface") != nil
								cComissao := AllTrim( oEAIObEt:getpropvalue("SalesChargeInformation"):getpropvalue("SalesChargeInterface") )
							Endif
							
							If ! Empty ( cComissao )						
								If lHotel .AND. cComissao <> "S"
									lRet := .F. 
									cLogErro := ""	
									ofwEAIObj:Activate()
									ofwEAIObj:setProp("ReturnContent")
									cLogErro := STR0012 //"Para a integração com hotelaria, a interface de comissão deve ser 'S' - Contas a Pagar."
									ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)	
								Else
									If ! Empty( cComissao )
										aAdd( aDadosSa3, { "A3_GERASE2", cComissao, Nil } )
									Endif
								Endif
							Else
								//Se for integração com hotelaria, obriga a informar o tipo de comissão
								If lHotel
									lRet := .F. 
									cLogErro := ""	
									ofwEAIObj:Activate()
									ofwEAIObj:setProp("ReturnContent")
									cLogErro := STR0013 //"Interface de comissão não informada."
									ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)	
								Endif
							Endif
						Endif
						
						//Ativo
						If oEAIObEt:getpropvalue("Active") != nil 
							cVendActiv := AllTrim(oEAIObEt:getpropvalue("Active"))
						Endif
		            	If (cVendActiv == '0' .Or. Upper(cVendActiv) == 'TRUE') .And. (nOpcx != 5) // Ativo
							aAdd( aDadosSA3, { "A3_MSBLQL", '2', Nil } )
						ElseIf (cVendActiv == '1' .Or. Upper(cVendActiv) == 'FALSE') .And. (nOpcx != 5) // Inativo 
							aAdd( aDadosSA3, { "A3_MSBLQL", '1', Nil } )
						EndIf

						If lRet .And. ExistBlock("M040OEAI",,.T.)
							aDadosSA3 := ExecBlock("M040OEAI",.F.,.F.,{aDadosSA3, nOpcx, oEAIObEt:getJSON()})
							nPosCod := aScan(aDadosSA3,{|x| AllTrim(x[1])=="A3_COD"})
							If nPosCod == 0 .Or. cCode <> aDadosSA3[nPosCod][2]
								lRet := .F.
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								//cLogErro := STR0022 //'Código do vendedor não deve ser alterado em meio ao processo, pois fere a integridade de dados.'
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
							EndIf
						EndIf
						
						If lRet									
							lManut :=  (nOpcx == 5  .OR. nOpcx == 4) .AND. !Empty( cValInt )
							
							If lManut .OR. nOpcx == 3
								//Verifica se processou com sucesso
								aRetExec := MATI40PVend(aDadosSA3, nOpcx, cValInt, cValExt, cMarca )
								If aRetExec[1]
									//Monta o JSON de retorno
									ofwEAIObj:Activate()
																							
									ofwEAIObj:setProp("ReturnContent")
													
									ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
									ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Name",cMsgUnica,,.T.)
									ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Origin",cValExt,,.T.)
									ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Destination",AllTrim(aRetExec[2]),,.T.)							
								Else
									ofwEAIObj:Activate()
									ofwEAIObj:setProp("ReturnContent")
								  	ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", aRetExec[2])
								Endif
							Else
								lRet := .F. 
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0001 //'O registro não foi encontrado na base de destino.'
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)	
							EndIf
						EndIf
					Else
						lRet := .F. 
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0002 //'Chave do registro não enviada, é necessária para cadastrar o de-para'
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)	
					Endif			 				
				Else
					lRet    := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0003 //"Tag de operação STR0004 inexistente."//'Event'//"Tag de operação 'Event' inexistente."
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
				Endif
		EndCase
	EndIf

    aSize(aAux,0)
    aAux := {}

    aSize(aRetMsg,0)
	aRetMsg := {}

    aSize(aDadosSA3,0)
	aDadosSA3 := {}

    aSize(aFornec,0)
	aFornec:= {}

    aSize(aRetExec,0)
    aRetExec := {}

Return { lRet, ofwEAIObj, cMsgUnica }

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI40PVend

Rotina para gravar dados originados de uma Business mensagem

@sample	MATI40PVend( aDadosSA3, nOpcx, cVlInt, cVlExt, cMarca )

@param	 aDadosSA3 - Array contendo os dados
nOpcx  -  Tipo de operação
cVlInt - Valor da Chave Interno
cVlExt - Valor da chave esterno
cMarca - Marca que está enviando a mensagem

@return	 Array ->  lRet  retorno lógico

@author  Victor Bitencourt
@since	  23/02/2015
@version 12.1.17

/*/
//---------------------------------------------------------------------------------------------------------------
Static Function MATI40PVend( aDadosSA3, nOpcx, cValInt, cValExt, cMarca )

	Local lRet 		:= .T.
	Local cLogErro	:= ""
	Local aErroAuto	:= {}
	Local aRetMsg	:= {}
	Local nCount	:= 0
	Local cAliasEnt	:= "SA3"
	Local cCampo	:= "A3_COD"

	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile 	:= .T.

	Default aDadosSa3 := {}
	Default nOpcx     := 0
	Default cValInt   := ""
	Default cValExt   := ""
	Default cMarca    := ""

	Begin Transaction

	//Aciona rotina automatica para gravacao/exclusão/alteração do vendedor
	MSExecAuto( { |x, y| MATA040( x, y ) }, aDadosSA3, nOpcx )

	//Tratamento em caso de erro na execucao da rotina automatica
	If ( lMsErroAuto )
		
		lRet := .F.
		aErroAuto := GetAutoGRLog()
			
		For nCount := 1 To Len(aErroAuto)
			cLogErro += StrTran( StrTran( aErroAuto[nCount], "<", "" ), "-", "" ) + (" ")
		Next nCount

		DisarmTransaction()

		aAdd( aRetMsg, lRet )
		aAdd( aRetMsg, cLogErro )
		
	Else
		
		If nOpcx == 5 // Deletar
			CFGA070Mnt( cMarca  , cAliasEnt, cCampo, Nil, cValInt, .T. ) // remove do de/para
		ElseIf nOpcx == 3 // Incluir
			cValInt := IntVenExt(cEmpAnt,/*cFilAnt*/,SA3->A3_COD)[2]
			CFGA070Mnt( cMarca, cAliasEnt, cCampo , cValExt, cValInt )
		EndIf
		
		aAdd( aRetMsg, lRet )
		aAdd( aRetMsg, cValInt )
		
	EndIf

	End Transaction

	aSize(aErroAuto,0)
	aErroAuto := {}

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

    Local aArea     := GetArea()
	Local cProxNum  := ""
	
	cProxNum := GETSX8NUM("SA3","A3_COD")
	While .T.
		If SA3->( DbSeek( xFilial("SA3")+cProxNum ) )
			ConfirmSX8()
			cProxNum := GetSXeNum("SA3","A3_COD")
		Else
			Exit
		Endif
	Enddo

    RestArea(aArea)

Return(cProxNum)

//-------------------------------------------------------------------
/*/{Protheus.doc} IntInpInt
Recebe um InternalID e retorna o código do Vendedor.


@author 	Anderson Silva
@version	P12.1.7
@since		11/05/2018
@return	aResult Array contendo no primeiro parâmetro uma variável
			lógica indicando se o registro foi encontrado no de/para.
			No segundo parâmetro uma variável array com a empresa,
			filial ,InternalId
/*/
//-------------------------------------------------------------------
Static Function IntVenExt(cEmp,cFil,cInternalId)

	Local aResult  		:= {}
	
	Default cEmp		:= cEmpAnt
	Default cFil		:= xFilial("SA3") 
	Default cInternalID	:= ""

	aAdd(aResult, .T.)
	aAdd(aResult, cEmp + '|' + RTrim(cFil) + '|' + RTrim(cInternalId) )

Return(aResult)

//-------------------------------------------------------------------
/*/{Protheus.doc} IntForInt
Recebe um InternalID e retorna o código do Fornecedor.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem

@author  Totvs Cascavel
@version P12
@since   14/05/2018
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado no de/para.
         No segundo parâmetro uma variável array com a empresa,admin
         filial, o código do fornecedor e a loja do fornecedor.
/*/
//-------------------------------------------------------------------
Static Function IntForInt(cInternalID, cRefer)

	Local   aResult  := {}
	Local   aTemp    := {}
	Local   cTemp    := ''
	Local   cAlias   := 'SA3'
	Local   cField   := 'A3_COD'

	cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
	
	If !Empty( cTemp )
		aAdd(aResult, .T.)
		aTemp := Separa(cTemp, '|')
		aAdd(aResult, aTemp)
	EndIf
	
Return aResult
