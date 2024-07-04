#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'   //Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH'       //Include para rotinas com MVC
#Include 'MATI360.CH'
#Include 'PMSXSOLUM.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATI360O   ºAutor  ³Totvs Cascavel     º Data ³  07/05/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e  º±±
±±º          ³ envio de informações do cadastro de Condicoes de Pagamento º±±
±±º          ³ (SE4) utilizando o conceito de mensagem unica JSON.        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATI360O                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao de integracao com o adapter EAI para envio e recebimento do  cadastro de
Condicao de pagamento (SE4) utilizando o conceito de mensagem padronizada.
@param   oEAIObEt 	   Objeto para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)
@author  Totvs Cascavel
@version P12
@since   07/05/2018
@return  aRet - Array contendo o resultado da execucao e a mensagem de retorno.
         aRet[1] - (boolean) 	Indica o resultado da execução da função
         aRet[2] - (objeto) 	Mensagem para envio
		 aRet[3] - (caracter) 	Codigo da mensagem
/*/
//-------------------------------------------------------------------
Function MATI360O( oEAIObEt, nTypeTrans, cTypeMessage, cVersion, cTransaction )
	
	Local aArea         := GetArea()                 // Salva contexto atual
	Local aAux          := {}                        // Array de uso geral   	
	Local aCondPgto     := {}                        // Array com os valores recebidos
	Local aMsgErro      := {}                        // Array com erro na validação do Model
	Local aParcelas     := {}                        // Array com regras do campo E4_COND
	Local aRet     		:= {}
   	Local cAlias        := "SE4"                     // Alias da tabela no Protheus
   	Local cIntervalo    := ""                        // Intervalo entre cada parcela
   	Local cCondicao     := ""                        // Guarda o campo E4_COND
   	Local cCode         := ""                        // Codigo da condição de pagamento
	Local cDias         := ""                        // Dias para o vencimento da primeira parcela
	Local cDiaSemana    := ""                        // Dia da semana para o vencimento das parcelas
   	Local cDiaMes       := ""                        // Dia do mês para o vencimento das parcelas
   	Local cDiasDesc     := ""                        // Dias para desconto da parcela
	Local cEvent        := "upsert"                  // Evento da transacao (Upsert/Delete)
	Local cField        := "E4_CODIGO"               // Campo identificador no Protheus
	Local cLogErro      := ""                        // Log de erro
	Local cMsgUnica  	:= 'PAYMENTCONDITION'   	
	Local cParcelas     := ""                        // Quantidade de parcelas
   	Local cProduct      := ""                        // Marca, Referência (RM, PROTHEUS, DATASUL etc)
   	Local cValInt       := ""                        // Valor interno no Protheus
   	Local cValExt       := ""                        // Valor externo
   	Local cTemp         := ""                        // Utilizada para montagem da condição do tipo 8
	Local lInc          := .F.
   	Local lMktPlace     := SuperGetMv("MV_MKPLACE",.F.,.F.)
	Local lRet          := .T.                       // Retorna se a execucao foi bem sucedida ou nao
	Local nI            := 1                         // Contadores de uso geral
	Local nMult         := 0                         // Multiplicador para o tipo 2
	Local nOpcx         := 0                         // Operação realizada   	
   	Local oModel        := Nil                       // Model completo do MATA360
   	Local oModelSE4     := Nil                       // Model com a master apenas
	Local ofwEAIObj		:= FwEAIObj():New()
   	Local cCodSE4       := ''
   	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.
   	
   	//--------------------------------------
	//recebimento mensagem
	//--------------------------------------
	If nTypeTrans == TRANS_RECEIVE .And. ValType( oEAIObEt ) == 'O'
		//--------------------------------------
		//chegada de mensagem de negocios
		//--------------------------------------		
		If cTypeMessage == EAI_MESSAGE_BUSINESS
		
			cEvent := Upper( AllTrim( IIf( oEAIObEt:getHeaderValue("Event") == Nil , oEAIObEt:GetEvent() , oEAIObEt:getHeaderValue("Event") ) ) )
		
			// Verifica se o InternalId foi informado
			If oEAIObEt:getPropValue("InternalId") != nil 
				cValExt := Upper(oEAIObEt:getPropValue("InternalId"))
	        Else
				lRet := .F.
				
				cLogErro := ""	
		  		ofwEAIObj:Activate()
		 		ofwEAIObj:setProp("ReturnContent")
		   		cLogErro := STR0011 // "O código do InternalId é obrigatório!"
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
				
			EndIf		
			
			// Verifica se a marca foi informada
			If oEAIObEt:getHeaderValue("ProductName") !=  nil
				cProduct := oEAIObEt:getHeaderValue("ProductName")
			Else
				lRet := .F.
				
				cLogErro := ""	
		  		ofwEAIObj:Activate()
		 		ofwEAIObj:setProp("ReturnContent")
		   		cLogErro := STR0012 // "O Produto é obrigatório!"
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
				
			EndIf
			
			// Verifica se a filial atual é a mesma filial de inclusão do cadastro
			aAux := IntChcEmp(oEAIObEt, cAlias, cProduct)
			If !aAux[1]
				lRet := aAux[1]

				cLogErro := ""	
		  		ofwEAIObj:Activate()
		 		ofwEAIObj:setProp("ReturnContent")
		   		cLogErro := aAux[2] 
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
				
			EndIf
         
			// Verifica se o código da Condição de Pagamento foi informado
			If oEAIObEt:getPropValue("Code") != nil .And. !Empty( oEAIObEt:getPropValue("Code") )
				cCode := oEAIObEt:getPropValue("Code")
			Else
				lRet := .F.
				
				cLogErro := ""	
		  		ofwEAIObj:Activate()
		 		ofwEAIObj:setProp("ReturnContent")
		   		cLogErro := STR0013 // "O Código da Condição de Pagamento é obrigatório!"
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
				
			EndIf
			
			// Obtém o valor interno da tabela XXF (de/para)
			aAux := IntConInt(cValExt, cProduct)

			// Se o evento é UPSERT
			If Upper(cEvent) == 'UPSERT' .Or. Upper(cEvent) == 'REQUEST'
            	If !aAux[1]
               		// Inclusão
               		nOpcx := 3
            	Else
					// Alteração
					nOpcx := 4
				EndIf
			ElseIf Upper(cEvent) == 'DELETE'
				If aAux[1]
					// Exclusão
					nOpcx := 5
				Else
					lRet := .F.
					
					cLogErro := ""	
			  		ofwEAIObj:Activate()
			 		ofwEAIObj:setProp("ReturnContent")
			   		cLogErro := (STR0003 + " -> " + cValExt) // Registro não encontrado!
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
					
				EndIf
			Else
				lRet := .F.
				
				cLogErro := ""	
			  	ofwEAIObj:Activate()
			 	ofwEAIObj:setProp("ReturnContent")
			   	cLogErro := STR0014 // "O evento informado é inválido"
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
					
			EndIf
			
			If lRet
				dbSelectArea("SE4")
				SE4->(DbSetOrder(1)) // Filial + Condição (E4_FILIAL + E4_CODIGO)
				If nOpcx <> 3 
					SE4->(dbSeek(xFilial("SE4") + PadR(aAux[2,3],TamSx3("E4_CODIGO")[1])))
					cCodSE4 := IIf( SE4->(Found() ), SE4->E4_CODIGO, cCode )
				Endif
			
				// Carrega model com estrutura da Cond. de Pagamento
				oModel := FwLoadModel("MATA360")
				If nOpcx == 3
					oModel:SetOperation(MODEL_OPERATION_INSERT)
				Elseif nOpcx == 4
					oModel:SetOperation(MODEL_OPERATION_UPDATE)
				Elseif nOpcx == 5
					oModel:SetOperation(MODEL_OPERATION_DELETE)
				Endif
				
				If oModel:nOperation != MODEL_OPERATION_DELETE
					// Recebimento dos dados
					lInc := oModel:nOperation == MODEL_OPERATION_INSERT
					
					//Verifica se utiliza inicialização padrão 
					If lInc
						cCodSE4 := I360GetCod( cCode )
						If !( Empty( cCodSE4 ) )
							aAdd(aCondPgto, {"E4_CODIGO", cCodSE4, Nil})
						EndIf
					Else
						aAdd(aCondPgto, {"E4_CODIGO", cCodSE4, Nil})
					Endif
					
					If !Empty(oEAIObEt:getPropValue("Description")) 
						If Len(oEAIObEt:getPropValue("Description")) > TamSX3("E4_DESCRI")[1]
							lRet := .F.
							
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0015 + AllTrim(cValToChar(TamSX3("E4_DESCRI")[1])) + STR0016 // "A descrição da condição de pagamento no Protheus suporta no máximo [x] caracteres!"
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
								
						EndIf
						aAdd(aCondPgto, {"E4_DESCRI", oEAIObEt:getPropValue("Description"), Nil})
					Else
						lRet := .F.
						
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0017 // "A descrição da condição de pagamento é obrigatória!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)	
						
					EndIf
					
					// Trata as parcelas recebidas
					If oEAIObEt:getpropvalue('Plots') != nil
						
						oDue := oEAIObEt:getpropvalue('Plots'):getpropvalue('Due')
						
						For nI := 1 To Len( oDue )
							
							cCondicao += AllTrim( odue[nI]:getpropvalue('DueDay') )
							cTemp += AllTrim( odue[nI]:getpropvalue('Percentage') )
								
							If nI < Len( oDue )
								cCondicao += ','
								cTemp += ','
							EndIf
		
							If Len(cCondicao) + 5 > TamSX3("E4_COND")[1]
								lRet := .F.
								
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0018 + AllTrim(Str(TamSX3("E4_COND")[1])) + STR0019 // "A Condição de Pagamento para o Tipo 8 no Protheus não pode ultrapassar [x] caracteres."
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
									
							EndIf
							
						Next nI

						cCondicao := "[" + cCondicao + "],[" + cTemp + "]"

						aAdd(aCondPgto, {"E4_TIPO", "8", Nil}) // Grava apenas tipo 8
							
					Else
						//Tratamento para parcelas informadas de forma padronizada
						// Quantidade de parcelas
						If oEAIObEt:getPropValue("QuantityPlots") != nil .And. !Empty( oEAIObEt:getPropValue("QuantityPlots") )
							cParcelas := oEAIObEt:getPropValue("QuantityPlots")
						Else
							lRet    := .F.
							
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0020 // "Quantidade de parcelas não informada!"
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
									
						EndIf
					
						// Quantidade de parcelas
						If oEAIObEt:getPropValue("RangePlots") != nil .And. !Empty( oEAIObEt:getPropValue("RangePlots") ) 
							cIntervalo += oEAIObEt:getPropValue("RangePlots")
						Else
							lRet := .F.
							
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0021 // "Intervalo de dias não informado!"
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
									
						EndIf
					
						// Dias de carência para a primeira parcela
						If oEAIObEt:getPropValue("DaysFirstDue") != nil .And. !Empty( oEAIObEt:getPropValue("DaysFirstDue") )  
							cDias += oEAIObEt:getPropValue("DaysFirstDue")
						Else
							cDias += "0"
						EndIf
		
						// Dia da semana
						If oEAIObEt:getPropValue("WeekDayFixed") != nil .And. !Empty( oEAIObEt:getPropValue("WeekDayFixed") )  
							cDiaSemana += oEAIObEt:getPropValue("WeekDayFixed")
						EndIf
		
						If Empty(cDiaSemana)
							aAdd(aCondPgto, {"E4_TIPO", "5", Nil})
							cCondicao := cDias + "," + cParcelas + "," + cIntervalo
						Else
							aAdd(aCondPgto, {"E4_TIPO", "6", Nil})
							cCondicao := cParcelas + "," + cDias + "," + cDiaSemana + ',' + cIntervalo
						EndIf
					EndIf
					
					aAdd(aCondPgto, {"E4_COND", cCondicao, Nil})

					If oEAIObEt:getPropValue("FinancialDiscountDays") != nil .And. !Empty( oEAIObEt:getPropValue("FinancialDiscountDays") ) 
						aAdd(aCondPgto, {"E4_DIADESC", Val(oEAIObEt:getPropValue("FinancialDiscountDays")), Nil})
					EndIf

					If oEAIObEt:getPropValue("PercentageDiscountDays") != nil .And. !Empty( oEAIObEt:getPropValue("PercentageDiscountDays") )  
						aAdd(aCondPgto, {"E4_DESCFIN", Val(oEAIObEt:getPropValue("PercentageDiscountDays")), Nil})
					EndIf
				
					If oEAIObEt:getPropValue("PercentageIncrease") != nil .And. !Empty( oEAIObEt:getPropValue("PercentageIncrease") )   
						aAdd(aCondPgto, {"E4_ACRSFIN", Val(oEAIObEt:getPropValue("PercentageIncrease")), Nil})
					EndIf

					If oEAIObEt:getPropValue("RegisterSituation") != nil .And. !Empty( oEAIObEt:getPropValue("RegisterSituation") )   
						aAdd(aCondPgto, {"E4_MSBLQL", oEAIObEt:getPropValue("RegisterSituation"), Nil})
					EndIf

					// Dias da Condição
					If oEAIObEt:getPropValue("DaysCondition") != nil .And. !Empty( oEAIObEt:getPropValue("DaysCondition") )   
						cDaysCondition := BuscaDC(oEAIObEt:getPropValue("DaysCondition"))
		
						If !Empty(cDaysCondition)
							aAdd(aCondPgto, {"E4_DDD", cDaysCondition, Nil})
						Else
							lRet    := .F.
							
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0022 + Chr(10) + STR0023 // "Dias da condição inválido! [quebra linha] Os valores aceitos pelo Protheus são: 0=Data do Dia; 1=Fora o Dia; 7=Fora Semana;  10=Fora Dezena; 15=Fora quinzena; 30=Fora Mes"
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
									
						EndIf
					EndIf
					
				Else
					If aAux[1]
						aAdd(aCondPgto, {"E4_CODIGO", aAux[2,3], Nil})
					Endif
				EndIf
				
				oModel:Activate()
				oModelSE4 := oModel:GetModel("SE4MASTER") // Model parcial da Master (SE4)

				// Obtém a estrutura de dados
				aAux := oModelSE4:GetStruct():GetFields()

				For nI := 1 To Len(aCondPgto)
					// Verifica se os campos passados existem na estrutura do modelo
					If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aCondPgto[nI][1])}) > 0
						// É feita a atribuição do dado ao campo do Model
						If oModel:nOperation <> MODEL_OPERATION_DELETE
							If !oModel:SetValue('SE4MASTER', aCondPgto[nI][1], aCondPgto[nI][2]) .And. (aCondPgto[nI][1] != "E4_CODIGO" .Or. oModel:nOperation != MODEL_OPERATION_UPDATE)
								lRet := .F.

								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0034 + AllToChar(aCondPgto[nI][2]) + STR0035 + aCondPgto[nI][1] + "." //"Não foi possível atribuir o valor " " ao campo "
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								
							EndIf
						Endif
					EndIf
				Next nI

				// Se os dados não são válidos
				If !oModel:VldData()

					// Obtém o log de erros
					aMsgErro := oModel:GetErrorMessage()
					cLogErro := ""

					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")

					cLogErro := STR0036 + AllToChar(aMsgErro[6]) + CRLF //"Mensagem do erro: "
					cLogErro += STR0037 + AllToChar(aMsgErro[7]) + CRLF //"Mensagem da solução: "
					cLogErro += STR0038 + AllToChar(aMsgErro[8]) + CRLF //"Valor atribuído: "
					cLogErro += STR0039 + AllToChar(aMsgErro[9]) + CRLF //"Valor anterior: "
					cLogErro += STR0040 + AllToChar(aMsgErro[1]) + CRLF //"Id do formulário de origem: "
					cLogErro += STR0041 + AllToChar(aMsgErro[2]) + CRLF //"Id do campo de origem: "
					cLogErro += STR0042 + AllToChar(aMsgErro[3]) + CRLF //"Id do formulário de erro: "
					cLogErro += STR0043 + AllToChar(aMsgErro[4]) + CRLF //"Id do campo de erro: "
					cLogErro += STR0044 + AllToChar(aMsgErro[5]) //"Id do erro: "

					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)

					lRet := .F.
				Else
					// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
					oModel:CommitData()

					// Obtém o InternalId
					cValInt := IntConExt(/*Empresa*/, /*Filial*/, SE4->E4_CODIGO)[2]
				EndIf
				
				If lRet
					// Se o evento é diferente de delete
					If oModel:nOperation != MODEL_OPERATION_DELETE
						// Grava o registro na tabela XXF (de/para)
						CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F.)
					Else
						// Exclui o registro na tabela XXF (de/para)
						CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T.)
					EndIf
					
					If oEAIObEt:getHeaderValue("Transaction") !=  nil
						cName := oEAIObEt:getHeaderValue("Transaction")
					Endif
					
					// Monta o JSON de retorno
					ofwEAIObj:Activate()
																			
					ofwEAIObj:setProp("ReturnContent")
										
					ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Name",cName,,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Origin",cValExt,,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Destination",cValInt,,.T.)					         
				Endif
			Endif
		
		//--------------------------------------
	  	//whois
	  	//--------------------------------------	      
      	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS 
        	ofwEAIObj := "2.000|3.000"
        	
	 	//--------------------------------------
		//resposta da mensagem Unica TOTVS
		//--------------------------------------
	  	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE 
	  	
	     	// Verifica se a marca foi informada
	      	If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )  
	       		cProduct := oEAIObEt:getHeaderValue("ProductName")
	     	Else
	     		lRet    := .F.
	          	
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := STR0024 // "Erro no retorno. O Product é obrigatório!"
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)		          	
	          	
	    	EndIf
	            
	      	If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin") != nil
				cValInt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin")
			Endif
		            
		  	// Verifica se o código interno foi informado
		 	If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin") != nil
		   		cValInt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin")
		  	Else
		     	lRet    := .F.
		               	
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := STR0025 // "Erro no retorno. O OriginalInternalId é obrigatório!"
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
								
			EndIf
		
		 	// Verifica se o código externo foi informado
		  	If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination") != nil
		   		cValExt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination")
		  	Else
		    	lRet    := .F.
		               	
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := STR0026 // "Erro no retorno. O DestinationInternalId é obrigatório"
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
								
			EndIf
		
			// Se não houve erros no parse
		 	If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == 'DELETE'
		  		// Exclui o registro na tabela XXF (de/para)
		      	CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T.)
			Else
		        // Insere / Atualiza o registro na tabela XXF (de/para)
		      	CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F.)
		    EndIf
		               

	  	Endif
	
	//--------------------------------------
   	//envio mensagem
 	//--------------------------------------	     
	ElseIf nTypeTrans == TRANS_SEND
		//Carrega Model do cadastro de Condição de Pagamento
		oModel    := FWModelActive()
		If oModel == nil
			oModel   := FWLoadModel( 'MATA360' )
			oModel:Activate()
		EndIf
		oModelSE4 := oModel:GetModel('SE4MASTER')
		
	  	//Verifica operação realizada
	   	Do Case
	    	Case oModel:nOperation == MODEL_OPERATION_INSERT
	      		cEvent := 'upsert' //Inclusão
	     	Case oModel:nOperation == MODEL_OPERATION_UPDATE
	            cEvent := 'upsert' //Alteração
	      	Case oModel:nOperation == MODEL_OPERATION_DELETE
	            cEvent := 'delete' //Exclusão
	            CFGA070Mnt(,"SE4","E4_CODIGO",,IntConExt(,,oModelSE4:GetValue('E4_CODIGO'),)[2],.T.)
	 	EndCase
	 	
	  	//Verifica a operação realizada
	  	If oModel:nOperation != MODEL_OPERATION_DELETE
	    	//Carrega os dados da condição de acordo com o tipo para montar o JSON
	       	Do Case
	       		Case oModelSE4:GetValue('E4_TIPO') == '1'
	           		cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
	               	aParcelas  := MontaVencimentos(MntParcela(cCondicao), 1)
	               	cParcelas  := cValToChar(Len(aParcelas))
	               	cDias      := DiasDaCond(oModelSE4:GetValue('E4_DDD'))
	
	            Case oModelSE4:GetValue('E4_TIPO') == '2'
	               	nMult      := Val(RTrim(oModelSE4:GetValue('E4_COND')))
	               	cCondicao  := oModelSE4:GetValue('E4_CODIGO')
	               	cDias      := SubStr(cCondicao, 1, 1)
	               	cDias      := cValToChar(Val(cDias) * nMult)
	               	cParcelas  := SubStr(cCondicao, 2, 1)
	               	cIntervalo := SubStr(cCondicao, 3, 1)
	               	cIntervalo := cValToChar(Val(cIntervalo) * nMult)
	               	aParcelas  := {}
	
	            Case oModelSE4:GetValue('E4_TIPO') == '3'
	            	cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))        
	               	cDias      := StrTokArr(cCondicao, ',')[2]                                                
	               	cParcelas  := StrTokArr(cCondicao, ',')[1]                                                
	              	cCondicao  := oModelSE4:GetValue('E4_CODIGO')                                                                                                                                  
	               	aParcelas  := Condicao(100,cCondicao,0,dDataBase,0)                                                                     
	               	aParcelas  := aEval(aParcelas,{|x| x[1] := AllTrim(Str(x[1]-dDataBase))}) 	//-- Altera o campo de data para string
	              	aParcelas  := aEval(aParcelas,{|x| x[2] := AllTrim(Str(x[2]))}) 
	
	            Case oModelSE4:GetValue('E4_TIPO') == '4'
	               	cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
	               	aParcelas  := MntParcela(cCondicao)
	               	cParcelas  := aParcelas[1][1]
	               	cIntervalo := aParcelas[2][1]
	               	cDiaSemana := aParcelas[3][1]
	               	cDias      := DiasDaCond(oModelSE4:GetValue('E4_DDD'))
	               	aParcelas  := {}
	
	            Case oModelSE4:GetValue('E4_TIPO') == '5'
	              	cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
	               	aParcelas  := MntParcela(cCondicao)
	               	cDias      := aParcelas[1][1]
	               	cParcelas  := aParcelas[2][1]
	               	cIntervalo := aParcelas[3][1]
	               	aParcelas  := {}
	
	            Case oModelSE4:GetValue('E4_TIPO') == '6'
	               	cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
	               	aParcelas  := MntParcela(cCondicao)
	               	cParcelas  := aParcelas[1][1]
	               	cDias      := aParcelas[2][1]
	               	cDiaSemana := aParcelas[3][1]
	               	cIntervalo := aParcelas[4][1]
	               	aParcelas  := {}
	
	            Case oModelSE4:GetValue('E4_TIPO') == '7'
	            	If lMktPlace
						cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
						cDias      := StrTokArr(cCondicao, ',')[2]                                                
						cParcelas  := StrTokArr(cCondicao, ',')[1]
						cCondicao  := oModelSE4:GetValue('E4_CODIGO')                                                                                                                                   
						aParcelas  := Condicao(100,cCondicao,0,dDataBase,0)                                                                     
						aParcelas  := aEval(aParcelas,{|x| x[1] := AllTrim(Str(x[1]-dDataBase))}) 	//-- Altera o campo de data para string
						aParcelas  := aEval(aParcelas,{|x| x[2] := AllTrim(Str(x[2]))})                                                 
					Endif
	            Case oModelSE4:GetValue('E4_TIPO') == '8'
	              	cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
	               	aParcelas  := MntParcela(cCondicao, 8)
	               	cParcelas  := cValToChar(Len(aParcelas))
	               	cDias      := DiasDaCond(oModelSE4:GetValue('E4_DDD'))
	
	            Case oModelSE4:GetValue('E4_TIPO') == '9'
	
	            Case oModelSE4:GetValue('E4_TIPO') == 'A'
	
	            Case oModelSE4:GetValue('E4_TIPO') == 'B'
	    	EndCase
	   	EndIf
	   	
      
      	//Montagem da mensagem de Condições de Pagamento
		ofwEAIObj:Activate()
		ofwEAIObj:setEvent(cEvent)	
			
		ofwEAIObj:setprop("CompanyId",            cEmpAnt)
		ofwEAIObj:setprop("BranchId",             xFilial('SE4'))
		ofwEAIObj:setprop("CompanyInternalId",    cEmpAnt + '|' + xFilial("SE4"))
		ofwEAIObj:setprop("Code",                 RTrim(oModelSE4:GetValue('E4_CODIGO')))
		ofwEAIObj:setprop("InternalId",           IntConExt(/*Empresa*/, /*Filial*/, oModelSE4:GetValue('E4_CODIGO'))[2] )
		ofwEAIObj:setprop("Description",          AllTrim(oModelSE4:GetValue('E4_DESCRI')) )
	 	ofwEAIObj:setprop("TypePaymentCondition", AllTrim(oModelSE4:GetValue('E4_TIPO')) )

	 	If !Empty(cDias)
	   		ofwEAIObj:setprop("DaysFirstDue", cDias ) //Dias para primeira parcela
	  	EndIf
	 	If !Empty(cParcelas)
	      	ofwEAIObj:setprop("QuantityPlots", cParcelas ) //Quantidade de parcelas
	 	EndIf
	   	If !Empty(cIntervalo)
	         ofwEAIObj:setprop("RangePlots", cIntervalo ) //Intervalo entre as parcelas
	  	EndIf
		If !Empty(cDiaSemana)
       		ofwEAIObj:setprop("WeekDayFixed", cDiaSemana ) //Dia da semana, quando este for fixo
      	EndIf
	  	If !Empty(cDiaMes)
	      	ofwEAIObj:setprop("DayMonthFixed", cDiaMes ) //Dia do mês, quando este for fixo
	  	EndIf
	  	If !Empty(cDiasDesc)
	      	ofwEAIObj:setprop("DaysCondition", cDiasDesc ) //Contagem dos dias para as parcelas
	   	EndIf
	   	If !Empty(oModelSE4:GetValue('E4_DIADESC'))
	 		ofwEAIObj:setprop("FinancialDiscountDays", cValToChar(oModelSE4:GetValue('E4_DIADESC')) ) //Dias para desconto financeiro
	 	EndIf
      	If !Empty(oModelSE4:GetValue('E4_DESCFIN'))
      		ofwEAIObj:setprop("PercentageDiscountDays", cValToChar(oModelSE4:GetValue('E4_DESCFIN')) ) //Percentual de desconto financeiro
      	EndIf
      	If !Empty(oModelSE4:GetValue('E4_ACRSFIN'))
      		ofwEAIObj:setprop("PercentageIncrease", cValToChar(oModelSE4:GetValue('E4_ACRSFIN')) ) //Percentual de acréscimo
      	EndIf
		If !Empty(oModelSE4:GetValue('E4_MSBLQL'))
      		ofwEAIObj:setprop("RegisterSituation", oModelSE4:GetValue('E4_MSBLQL') ) //Status do registro
      	EndIf
      	
      	If Len(aParcelas) > 0
      		ofwEAIObj:setProp("Plots")
         	For nI := 1 To Len(aParcelas)
         		ofwEAIObj:getPropValue("Plots"):setProp("Due",{})
         		
         		ofwEAIObj:getPropValue("Plots"):getPropValue("Due")[nI]:setProp("DueDay", aParcelas[nI][1]	)
         		ofwEAIObj:getPropValue("Plots"):getPropValue("Due")[nI]:setProp("Percentage", aParcelas[nI][2]	)
         	Next nI
      	EndIf
      
   	EndIf

   	RestArea(aArea)

	aSize(aArea,0)
	aArea := {}

	aSize(aAux,0)
	aAux := {}

	aSize(aCondPgto,0)
	aCondPgto := {}

	aSize(aMsgErro,0)
	aMsgErro := {}

	aSize(aParcelas,0)
	aParcelas := {}

	aSize(aRet,0)
	aRet := {}

Return { lRet, ofwEAIObj, cMsgUnica }

//-------------------------------------------------------------------
/*/{Protheus.doc} MntParcela
Monta array com os prazos das parcelas do campo E4_COND.

@param Caracter, cCondicao, Conteudo do campo E4_COND
@param Numérico, nTipo, Tipo da condição de pagamento (E4_TIPO)

@author Mateus Gustavo de Freitas e Silva
@version P12
@since 25/06/2012

@return Array, Array com os valores da condição.

@obs
Alterado para contemplar o tipo 8
Mateus Gustavo de Freitas e Silva 19/07/2012
/*/
//-------------------------------------------------------------------
Static Function MntParcela(cCondicao, nTipo)

   Local nI           := 1  //Controla a posicao do ponteiro que varre os prazos em cCondicao
   Local nInicio      := 1  //Indica a posicao inicial para o SubStr separar o prazo
   Local nQtde        := 1  //Indica a quantidade de caracteres que o SubStr deve pegar
   Local aParcelas    := {} //Array com os prazos da condicao
   local aVencimentos := {} //Array com as datas de vencimento
   Local aPercentuais := {} //Array com os percentuais das parcelas

   If Empty(nTipo) //Parâmetro não informado
      //Varre o conteudo de cCondicao com conteudo do E4_COND
      For nI := 1 To Len(cCondicao)
         //Se caracter atual for uma vírgula, não faz nada
         If (SubStr(cCondicao, nI, 1) != ',')
            If (SubStr(cCondicao, nI + 1, 1) == ',') .Or. ((nI + 1) > Len(cCondicao))
               //Adiciona no array o prazo de vencimento de acordo com nInicio e nQtde
               aAdd(aParcelas, {SubStr(cCondicao, nInicio, nQtde), ''})
               nInicio := nI + 2   //Atualiza nInicio com a posicao inicial do proximo prazo
               nQtde := 0          //Zera nQtde para contar quantos digitos tem o proximo prazo
            EndIf

            nQtde += 1             //Incrementa a quantidade de digitos para o SubStr
         EndIf
      Next nI
   ElseIf nTipo = 8
      For nI := 1 To Len(AllTrim(cCondicao))
         If (SubStr(cCondicao, nI, 1) != '[')
            If (SubStr(cCondicao, nI + 1, 1) == ']') .Or. ((nI + 1) > Len(cCondicao))
               If Empty(aVencimentos)
                  aVencimentos := StrTokArr(SubStr(cCondicao, nInicio, nQtde), ',')
               Else
                  aPercentuais := StrTokArr(SubStr(cCondicao, nInicio, nQtde - 2), ',')
                  Exit
               EndIf

               nQtde := 0
            EndIf

            nQtde += 1
         Else
            nInicio := nI + 1
         EndIf
      Next nI

      For nI := 1 To Len(aVencimentos)
         aAdd(aParcelas, {aVencimentos[nI], aPercentuais[nI]})
      Next nI
   EndIf

Return aParcelas

//-------------------------------------------------------------------
/*/{Protheus.doc} DiasDaCond
Funcao que retorna o número de dias de prazo para o início da primeira
parcela da condição conforme o campo E4_DDD.

@param Caracter, CCond, Valor do campo E4_DDD.

@author Mateus Gustavo de Freitas e Silva
@version P11
@since 25/06/2012

@return Caracter, Quantidade de dias de prazo.
/*/
//-------------------------------------------------------------------
Static Function DiasDaCond(cCond)

   Local cDias := ''

   Do Case
      Case cCond == 'D'
         cDias := '0'
      Case cCond == 'L'
         cDias := '1'
      Case cCond == 'S'
         cDias := '7'
      Case cCond == 'Q'
         cDias := '15'
      Case cCond == 'F'
         cDias := '30'
      Case cCond == 'Z'
         cDias := '10'
   EndCase

Return cDias

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaVencimentos
Monta array com os prazos das parcelas do campo E4_COND.

@param Caracter, cCondicao, Conteudo do campo E4_COND
@param Numérico, nTipo, Tipo da condição de pagamento (E4_TIPO)

@author Mateus Gustavo de Freitas e Silva
@version P11
@since 26/06/2012

@return Array, Array com os valores da condição.
/*/
//-------------------------------------------------------------------
Static Function MontaVencimentos(aParcelas, nTipo)
   Local nI            := 1
   Local nParcelas     := Len(aParcelas)
   Local nTotal        := 0
   Local nValorParcela := Round(100 / nParcelas, 2)

   Do Case
      Case nTipo == 1 .Or. nTipo == 7
         For nI := 1 To nParcelas -1
            aParcelas[nI][2] := cValToChar(nValorParcela)
            nTotal += nValorParcela
         Next nI

         aParcelas[nParcelas][2] := cValToChar(100 - nTotal)
   EndCase
Return aParcelas

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaDC
De/para para preenchimento do campo E4_DDD

@param Caracter, cTipo, Tipo recebido na mensagem

@author Leandro Luiz da Cruz
@version P11
@since 25/10/2012

@return Caracter, Valor transformado
/*/
//-------------------------------------------------------------------
Static Function BuscaDC(cTipo)
   Local cResult := ''

   Do Case
      Case cTipo == '1'
         cResult := 'D' // Data do Dia
      Case cTipo == '2'
         cResult := 'L' // Fora o Dia
      Case cTipo == '3'
         cResult := 'S' // Fora Semana
      Case cTipo == '4'
         cResult := 'Q' // Fora Quinzena
      Case cTipo == '5'
         cResult := 'F' // Fora Mês
      Case cTipo == '6'
         cResult := 'Z' // Fora Dezena
   EndCase
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntConExt
Monta o InternalID da Condição de Pagamento de acordo com o código
passado no parâmetro.

@param Caracter, cEmpresa, Código da empresa (Default cEmpAnt)
@param Caracter, cFil, Código da Filial (Default cFilAnt)
@param Caracter, cCondPgto, Código da Condição de Pagamento
@param Caracter, cVersao, Versão da mensagem única (Default 2.000)

@author Totvs Cascavel
@version P12
@since 08/05/2018
@return  Array, Array contendo no primeiro parâmetro uma variável
lógica indicando se o registro foi encontrado.
No segundo parâmetro uma variável string com o InternalID
montado.

@sample
IntConExt(, , '001') irá retornar {.T., '01|01|001'}
/*/
//-------------------------------------------------------------------
Static Function IntConExt(cEmpresa, cFil, cCondPgto, cVersao)
   	Local   aResult  := {}
   	Default cEmpresa := cEmpAnt
   	Default cFil     := xFilial('SE4')

	aAdd(aResult, .T.)
 	aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cCondPgto))

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntConInt
Recebe um InternalID e retorna o código da Condição de Pagamento.

@param Caracter, cInternalID, InternalID recebido na mensagem.
@param Caracter, cRefer, Produto que enviou a mensagem

@author Leandro Luiz da Cruz
@version P11
@since 08/02/2013
@return Array, Array contendo no primeiro parâmetro uma variável
lógica indicando se o registro foi encontrado no de/para.
No segundo parâmetro uma variável array com a empresa,
filial e o Código da Condição de Pagamento.

@sample
IntConInt('01|01|001') irá retornar {.T., {'01', '01', '001'}}
/*/
//-------------------------------------------------------------------
Static Function IntConInt(cInternalID, cRefer, cVersao)
   	Local   aResult  := {}
   	Local   aTemp    := {}
   	Local   cTemp    := ''
  	Local   cAlias   := 'SE4'
   	Local   cField   := 'E4_CODIGO'

   	cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
   
   	If Empty(cTemp)
      	aAdd(aResult, .F.)
      	aAdd(aResult, STR0047 + " -> " + cInternalID) //"Registro não encontrado no de/para!"
  	Else
  		aAdd(aResult, .T.)
      	aTemp := Separa(cTemp, '|')
       	aAdd(aResult, aTemp)
   	EndIf

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntChcEmp
Função que retorna a filial do registro recebido.
O RM permite estar logado em uma filial no contexto e manipular registros
de outras filiais. Neste caso o EAI utiliza a filial do Messageinformation
(contexto) para logar no Protheus e esta função altera a filial corrente
para a filial do registro.
No execauto dos formulários MVC não informamos o código da filial. Ele
utiliza a filial logada.

@param   oEAIObEt Objeto JSON
@param   cAlias   Alias da tabela do cadastro
@param   cProduto Produto da integração
@author  Totvs Cascavel
@version P11
@since   08/05/2018

@return aEmpresas Valor booleano indicando se o de/para de empresa
         foi informado corretamente e a filial a ser utilizada no cadastro.
         
         Realizado ajuste para trabalhar com objeto JSON
/*/
//-------------------------------------------------------------------
Static Function IntChcEmp(oEAIObEt, cAlias, cProduto)

   Local aFilialP := {}
   Local cEmp     := ""
   Local cFil     := ""
   Local cEmpProt := ""
   Local cFilProt := ""
   Local lLog     := FindFunction("AdpLogEAI")

   If oEAIObEt:getPropValue("CompanyId") != nil .And. !Empty( oEAIObEt:getPropValue("CompanyId") )
      cEmp := oEAIObEt:getPropValue("CompanyId")
   EndIf

   If oEAIObEt:getPropValue("BranchId") != nil .And. !Empty( oEAIObEt:getPropValue("BranchId") )
      cFil := oEAIObEt:getPropValue("BranchId")
   EndIf

   // Se o cadastro é compartilhado a nível de filial ou a nível de empresa no RM
   // As tags CompanyID e BranchId podem vir vazias
   If Empty(cEmp)
      If lLog
         AdpLogEAI(2, STR0129 + Chr(10) + STR0130) //"Empresa compartilhada." "Tag CompanyId do BusinessContent veio vazia."
      EndIf
   EndIf

   If Empty(cFil)
      If lLog
         AdpLogEAI(2, STR0131 + Chr(10) + STR0132) //"Filial compartilhada." "Tag BranchId do BusinessContent veio vazia."
      EndIf
   EndIf

   If Empty(cEmp) .Or. Empty(cFil)
      aAdd(aFilialP, .T.)
      aAdd(aFilialP, cFilProt)

      Return aFilialP
   EndIf
   
   aFilialP := FWEAIEMPFIL(cEmp, cFil, UPPER(cProduto))

   If Empty(aFilialP)
      If lLog
         AdpLogEAI(2, STR0133 + cEmp + "/" + cFil + STR0134 + cProduto + ".") //"Empresa/Filial " " recebida no BusinessContent não esta cadastrada no de/para para o produto "
      EndIf

      cEmpProt := cEmpAnt
      cFilProt := cFilAnt
   Else
      cEmpProt := aFilialP[1]
      cFilProt := aFilialP[2]
   EndIf

   If cEmpProt != cEmpAnt
      If lLog
         AdpLogEAI(2, STR0104 + " " + cEmpProt + STR0134 + cEmpAnt + STR0135) //"Empresa" " recebida no BusinessContent é diferente da empresa " " enviada no MessageInformation."
      EndIf

      cEmpProt := cEmpAnt
      cFilProt := cFilAnt
   EndIf

   aFilialP := {}

   If cFilAnt != cFilProt
      If lLog
         AdpLogEAI(2, "Alteração de filial.") //"Alteração de filial."
         AdpLogEAI(2, "Filial Anterior: " + cFilAnt) //"Filial Anterior: "
      EndIf

      cFilAnt := cFilProt

      If lLog
         AdpLogEAI(2, "Nova Filial: " + cFilAnt) //"Nova Filial: "
      EndIf
   EndIf

   aAdd(aFilialP, .T.)
   aAdd(aFilialP, cFilProt)

Return aFilialP