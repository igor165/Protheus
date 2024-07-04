#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJI140.CH"
#INCLUDE "FWADAPTEREAI.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOJI140

Rotina para processar o envio/recebimento de Cancelamento de Cupom via integracao Mensagem Unica.
XSD da Mensagem = RetailSalesCancellation

@param   cXml           Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans    Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Vendas Cliente      
@version P12
@since   05/02/2016
@return  lRet - (boolean)  Indica o resultado da execução da função
         cXmlRet - (caracter) Mensagem XML para envio         
/*/
//-------------------------------------------------------------------------------------------------

Function LOJI140(cXml, nTypeTrans, cTypeMsg,lJSon)

Local cError 	:= ""  //Erros no XML
Local cWarning 	:= ""  //Avisos no XML
Local cVersao	:= ""  //Versao da Mensagem
Local cXmlRet	:= ""  //Mensagem de retorno da integracao
Local cMarca	:= ""  //Armazena a Marca que enviou o XML
Local cValExt	:= "" //Codigo externo utilizada no De/Para de codigos - Tabela XXF
Local cValInt	:= "" //Codigo interno utilizada no De/Para de codigos - Tabela XXF
Local cAlias    := "SLX" //Tabela De-Para
Local cCampo    := "LX_CUPOM" //Campo De-Para
Local nCount	:= 0 //Contador
Local lRet		:= .T. //Retorno da integracao
Local oXmlL140	:= Nil //Objeto XML

Default lJSon := .F.

If lJSon
	//Desvio Objeto EAI
	Return LOJI140O(cXml, nTypeTrans, cTypeMsg)
EndIf

//Verifica tipo da mensagem
If cTypeMsg == EAI_MESSAGE_BUSINESS
	If nTypeTrans == TRANS_RECEIVE //Mensagem de Recebimento
		oXmlL140	:= xmlParser(cXml, "_", @cError, @cWarning) //Objeto XML

		//Validacoes iniciais do XML
		If oXmlL140 <> Nil .And. Empty(cError) .And. Empty(cWarning)				
			If !Empty(LjiVldTag(oXmlL140:_TOTVSMessage:_MessageInformation, "_VERSION"))															
				cVersao := oXmlL140:_TOTVSMessage:_MessageInformation:_version:Text							                 	               	
	
				//Valida versao do XML          
				If StrTokArr(cVersao, ".")[1] == "1"
					v1000(oXmlL140, nTypeTrans, @lRet, @cXmlRet)							
				Else 																																		
					lRet := .F.
					cXmlRet := STR0003 //#"A versao da mensagem informada nao foi implementada!"														   						   		   			  																					   		   		     							   														
				EndIf
			Else
				lRet := .F.
				cXmlRet := STR0002 //#"Versao da mensagem nao informada!"
			EndIf
		Else
			lRet := .F.
			cXmlRet := STR0001 //#"Erro no parser!" 
		EndIf
	ElseIf nTypeTrans == TRANS_SEND //Mensagem de Envio
		v1000(oXmlL140, nTypeTrans, @lRet, @cXmlRet)
	EndIf
ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
	//Gravacao do De/Para Codigo Interno X Codigo Externo  	
	oXmlL140 := xmlParser(cXml, "_", @cError, @cWarning) //Objeto XML

	//Validacoes de erro no XML
	If oXmlL140 <> Nil .And. Empty(cError) .And. Empty(cWarning)		
		If Upper(oXmlL140:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
			If oXmlL140:_TotvsMessage:_MessageInformation:_Product:_Name:Text <> Nil .And.; 
				!Empty(oXmlL140:_TotvsMessage:_MessageInformation:_Product:_Name:Text)			 					
				
				cMarca := oXmlL140:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			EndIf
						   	
			If oXmlL140:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text <> Nil .And.; 
				!Empty(oXmlL140:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text <> Nil)	
				
				cValInt := oXmlL140:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
			EndIf
			   	
			If oXmlL140:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text <> Nil .And.; 
				!Empty(oXmlL140:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text <> Nil)	
				
				cValExt := oXmlL140:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
			EndIf 
		   	  
			If !Empty(cValExt) .And. !Empty(cValInt)  
				If CFGA070Mnt(cMarca, cAlias, cCampo, cValExt, cValInt) 
					lRet := .T.										
				EndIf
	      	Else
	       	lRet := .F.	       		       	
	       EndIf	       
		Else //Erro
	   		If oXmlL140:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message <> Nil 	   		
       		//Se não for array
       		If ValType(oXmlL140:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) <> "A"
              	//Transforma em array
              	XmlNode2Arr(oXmlL140:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
            	EndIf
	
	          	//Percorre o array para obter os erros gerados
	          	For nCount := 1 To Len(oXmlL140:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
	          		cError := oXmlL140:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + CRLF
	          	Next nCount
	
	          	lRet 	 := .F.
	          	cXmlRet := cError	          		          	          		         	
			EndIf
	   	EndIf
	EndIf	
ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
	cXmlRet := "1.000|1.001|1.002"
EndIf

Return {lRet, cXmlRet, "RETAILSALESCANCELLATION"}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v1000

Rotina para processar a mensagem tipo RECEIVE e BUSINESS, efetua a gravacao do Cancelamento do Cupom 
no Protheus-SLX

@param   oXmlL140  	Objeto contendo a mensagem (XML)
@param   nTypeTrans 	Tipo de transação. (Envio/Recebimento)
@param   lRet  		Indica o resultado da execução da função
@param   cXmlRet  		Mensagem Xml para envio

@author  Vendas Cliente      
@version P12
@since   05/02/2016
@return  Nil
                  
/*/
//-------------------------------------------------------------------------------------------------
Static Function v1000(oXmlL140, nTypeTrans, lRet, cXmlRet)

Local aArea		    := GetArea()
Local cMarca		:= "" //Armazena a Marca que enviou o XML
Local cValInt		:= "" //Codigo interno utilizada no De/Para de codigos - Tabela XXF
Local cIdExt		:= "" //Identificacao externa do registro
Local cOperador	    := "" //Codigo do Operador
Local cDocExt		:= "" //Codigo da Venda Integrada
Local cDateCanc 	:= "" //Data do cancelamento 
Local cTimeCanc 	:= "" //Hora do cancelamento
Local cTimeAux	    := "" //Hora auxiliar
Local cEvent   	    := "" //Evento
Local cProtoNfce 	:= "" //Protocolo de cancelamento NFCe
Local cMunEst		:= "" //Municipio NFSe
Local nI			:= 0  //Contador
Local nOpcX		    := 5  //Opcao de Inclusao
Local nHoras		:= 0  //Horas NFe
Local nTamDoc		:= TamSx3("L1_DOC")[1]              //Tamanho do campo do Documento
Local nTamSer		:= TamSx3("L1_SERIE")[1]            //Tamanho da Serie do Cupom Fiscal
Local nTamPdv		:= TamSx3("L1_PDV")[1]              //Tamanho do PDV
Local nSpedExc 	    := SuperGetMV("MV_SPEDEXC", , 72)   //Indica a quantidade de horas q a NFe pode ser cancelada 
Local nExcNfs 	    := SuperGetMv("MV_EXCNFS" , , 180)
Local nTpPrz   	    := SuperGetMv("MV_TIPOPRZ", , 1)    //Tipo de Prazo para exclusão das NF de serviço
Local nControle	    := 0
Local nPosMunic	    := 0            //Municipios RPS
Local dDataR		:= dDataBase    //Data para validacao RPS
Local aAreas		:= {}           //Array com areas das tabelas
Local aDadosCup	    := {}           //Array contendo Cupons para geracao da NF
Local aErroAuto	    := {}           //Logs de erro do ExecAuto
Local aInternal	    := {}           //Array Auxiliar para armazenas InternalId gerado no Protheus
Local aAux			:= {}           //Array Auxiliar para armazenar Internald
Local aIntVenda	    := {}           //Array com informacoes da Venda
Local aMunic		:= {}           //Municipios NFSe
Local oXmlContent	:= Nil          //Objeto Xml com o conteudo da BusinessContent apenas
Local lIntegHtl	    := SuperGetMv("MV_INTHTL",, .F.)    //Integracao Hotelaria
Local aCaixa		:= {}                               //Array com as inforações do De/Para do Protheus.
Local cNumOrc		:= ""
Local cNumCancDoc   := ""                               //Numero do documento de cancelamento

Private lMsHelpAuto 		:= .T.  //Variavel de controle interno do ExecAuto
Private lMsErroAuto 		:= .F.  //Variavel que informa a ocorrência de erros no ExecAuto
Private lAutoErrNoFile 	:= .T.      //Força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 

//Armazena areas das Tabelas
aAdd(aAreas, SL1->(GetArea()))
aAdd(aAreas, SLX->(GetArea()))
aAdd(aAreas, SLG->(GetArea()))

LjGrvLog("LOJI140","ID_INICIO")
LjGrvLog("LOJI140","UUID: " + AllTrim(oXmlL140:_TotvsMessage:_MessageInformation:_Uuid:Text))

//Mensagem de Recebimento
If nTypeTrans == TRANS_RECEIVE	
	//------------------------------------------------------------
	//Tratamento utilizando a tabela XXF com um De/Para de codigos
	//------------------------------------------------------------                   		   		                                                           		
	If FindFunction("CFGA070INT")
																
		//Marca
		If oXmlL140:_TotvsMessage:_MessageInformation:_Product:_Name:Text <> Nil .And. !Empty(oXmlL140:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
			cMarca := oXmlL140:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		Else					
			lRet 	 := .F.
			cXmlRet := STR0004 //#"Marca nao integrada ao Protheus, verificar a marca da integracao"					
		EndIf																					
		
		If lRet	
			//Efetua a carga do objeto de cancelamento     	
			oXmlContent := oXmlL140:_TOTVSMessage:_BusinessMessage:_BusinessContent
			
			//Armazena chave externa
			cIdExt := LjiVldTag(oXmlContent, "_INTERNALID")
																																																										                  		   		                                                           						   		 										
			//Numero do Cupom	
			cDocExt := LjiVldTag(oXmlContent, "_RETAILSALESINTERNALID") 
									
			//Verifica se o InternalId do Cupom foi informado
			If Empty(cDocExt)
				lRet 	 := .F.	
				cXmlRet := STR0005 //#"InternalId vazio, informacao obrigatoria, verifique a tag RetailSalesInternalId." 				
			Else										
				aIntVenda := IntVendInt(cDocExt, cMarca)
			EndIf	
		EndIf 																							 																																																																																									
		
		If lRet	
			If 	ValType(aIntVenda) == "A" .And. Len(aIntVenda) > 0 .And. aIntVenda[1]																																																							
				//Verifica se a venda existe no Protheus
				SL1->(dbSetOrder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
				
				If SL1->(dbSeek(xFilial("SL1") + Padr(aIntVenda[2][3], nTamSer) + Padr(aIntVenda[2][4], nTamDoc) + Padr(aIntVenda[2][5], nTamPdv)))															
					cNumOrc := SL1->L1_NUM
				Else //Valida venda entrega
					SL1->(dbSetOrder(11)) //L1_FILIAL+L1_SERPED+L1_DOCPED
					
					If SL1->(dbSeek(xFilial("SL1") + Padr(aIntVenda[2][3], nTamSer) + Padr(aIntVenda[2][4], nTamDoc)))
						cNumOrc := SL1->L1_NUM
					Else
						lRet	 := .F.				
						cXmlRet := STR0026 + " " + AllTrim(cDocExt) + " " + STR0027 //#"Venda: ##"nao integrada ao Protheus, verificar integracao de Vendas"
					EndIf
				EndIf
				
				If lRet	
					If AllTrim(SL1->L1_SITUA) <> "OK"
						nControle := 1 //Controle para saida do While
						
						//Aguarda Execucao do GravaBatch no maximo 5 tentativas	
						While AllTrim(SL1->L1_SITUA) <> "OK" .And. nControle <= 5 
							Sleep(10000) //Se venda ainda nao foi gerada, aguarda 10 segundos para GravaBatch executar
							
							//Posiciona novamente pois GravaBatch pode ter disposicionado
							SL1->(dbSetOrder(1)) //L1_FILIAL+L1_NUM 
							SL1->(dbSeek(xFilial("SL1") + cNumOrc))
							nControle ++
						EndDo
																																					
						//Se apos 3 tentativas a venda nao foi gerada, recusa para verificar job do GravaBatch
						If AllTrim(SL1->L1_SITUA) <> "OK"
							lRet	 := .F.				
							cXmlRet := STR0026 + " " + AllTrim(cDocExt) + " " + STR0031 //#"Venda: ##"nao gerada no Protheus, verificar o job LJGrvBatch"
						EndIf
					EndIf																																												
				EndIf				
			Else
				lRet    := .F.
				cXmlRet := STR0026 + " " + AllTrim(cDocExt) + " " + STR0027 //#"Venda: ##"nao integrada ao Protheus, verificar integracao de Vendas"				
			EndIf
		EndIf
		
		If lRet	
			//Verifica se cancelamento ja existe	
			aAux := IntCancInt(cIdExt, cMarca)
									
	      	If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
	       	    lRet    := .F.
				cXmlRet := STR0022 + " " + AllTrim(cIdExt) + " " + STR0013 //#"Cancelamento:" ##" ja integrado ao Protheus"
	     	EndIf
	     	
	     	If lRet																					
				//Armazena Operador		
				cOperador := LjiVldTag(oXmlContent, "_OPERATORCODE")	
				//Valida Operador	
				If Empty(cOperador)				
					lRet 	 := .F.	
					cXmlRet := STR0015 //#"Operador nao informado na integracao, verifique a Tag OperatorCode"													
				EndIf
				
				//------------------------------------------------------------
				//Tratamento utilizando a tabela XXF com um De/Para de codigos
				//Necessário enquanto não for concluído o Adapter para Msg
				//Unica para cadastro dos caixas. 
				//------------------------------------------------------------ 			
				aCaixa := Separa(CFGA070Int(cMarca, "SLF", "LF_COD", cOperador),"|")
			
				If lRet .and. Len(aCaixa) >= 3
					
					cOperador := aCaixa[3]
																					
					//Posiciona no Operador do Protheus
					SLF->(dbSetOrder(1))
					If Empty(cOperador) .Or. !SLF->(dbSeek(xFilial("SLF") + cOperador))											
						lRet 	 := .F.	
						cXmlRet := STR0016 + " " + cOperador + " " + STR0017 //"#Operador:" ##"nao integrado ao Protheus, verificar o cadastro de operador."																								
					EndIf
				Else
					lRet 	 := .F.
					cXmlRet := STR0016 + " " + cOperador + STR0023 + CFGA070Int(cMarca, "SLF", "LF_COD", cOperador) + ". " + "verificar se o operador esta cadastrado na filial destino correta"  //#"Operador:" ##"nao encontrado no De/Para " " verificar se o operador esta cadastrado na filial destino correta.     
				EndIf
			EndIf
		EndIf						
		
		If lRet	
			//Verifica campos obrigatorios
			If Empty(cIdExt)
				lRet	 := .F.
				cXmlRet := STR0018 //#"Campo obrigatorio nao informado: Id Interno, verifique a tag: InternalId."				
			ElseIf XmlChildEx(oXmlContent, "_CANCELDATE") == Nil .Or. Empty(oXmlContent:_CancelDate:Text)
				lRet	 := .F.
				cXmlRet := STR0019 //#"Campo obrigatorio nao informado: Data do Cancelamento, verifique a tag: CancelDate."				
			EndIf
			
			cProtoNfce := LjiVldTag(oXmlContent, "_NFCECANCELPROTOCOL") 
			cDateCanc  := LjiVldTag(oXmlContent, "_CANCELDATE", "D") 
			cTimeCanc  := LjiVldTag(oXmlContent, "_CANCELDATE", "T")
			
			cNumCancDoc	:= LjiVldTag(oXmlContent, "_CANCELLATIONDOCUMENT") //Numero do documento de cancelamento SAT
			
			//Validacao para evitar registro duplicado quando existem cancelamentos de itens
			//na venda que esta sendo cancelada
			If !Empty(cTimeCanc)
				SLX->(dbSetOrder(1))
				
				If SLX->(dbSeek(xFilial("SLX") + SL1->L1_PDV + SL1->L1_DOC + SL1->L1_SERIE))
					While SLX->(!EOF()) .And. SLX->LX_FILIAL == xFilial("SLX") .And. SLX->LX_PDV == SL1->L1_PDV .And.; 
						SLX->LX_CUPOM == SL1->L1_DOC .And. SLX->LX_SERIE == SL1->L1_SERIE
						
						If SLX->LX_HORA == Subs(cTimeCanc, 1, 5)
							//Incrementa 1 minuto na hora de cancelamento para evitar duplicidade
							cTimeAux  := cTimeCanc 
							cTimeCanc := Subs(cTimeAux, 1, 2)
							cTimeCanc += ":"
							
							//Se minutos inferior a 59, incrementa minuto
							If Val(Subs(cTimeAux, 4, 2)) < 59
								cTimeCanc += PadL(CValToChar(Val(Subs(cTimeAux, 4, 2)) + 1), 2, "0")
							Else //Se minutos igual a 59, decrementa minuto
								cTimeCanc += PadL(CValToChar(Val(Subs(cTimeAux, 4, 2)) - 1), 2, "0")
							EndIf
							
							Exit
						EndIf
					
						SLX->(dbSkip())
					EndDo
				EndIf
			EndIf
																
			//Verifica se eh uma notafiscal eletronica , pois neste caso deve respeitar o 	
			//parametro MV_SPEDEXC que indica o numero de horas que a Nfe pode ser excluidas 				
			SF2->(dbSetOrder(1))
			
			If SF2->(dbSeek(xFilial("SF2") + SL1->L1_DOC + SL1->L1_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA))
				//Verifica se eh uma notafiscal eletronica , pois neste caso deve respeitar o 	
				//parametro MV_SPEDEXC que indica o numero de horas que a Nfe pode ser excluidas
				If AllTrim(SF2->F2_ESPECIE) == "SPED" .And. SF2->F2_FIMP $ "TS" //verificacao apenas da especie como SPED e notas que foram transmitidas ou impressao DANFE
					If !Empty(SF2->F2_CODNFE) .Or. !Empty(SF2->F2_CHVNFE)				 
						nHoras := SubtHoras(SF2->F2_EMISSAO, SF2->F2_HORA, dDataBase, SubStr(Time(), 1, 2) + ":" + SubStr(Time(), 4, 2))
						
						If nHoras > nSpedExc					
							lRet	 := .F.
							cXmlRet := STR0024 + " " + CValToChar(nSpedExc) + " " + STR0025 //#"Nao foi possivel excluir a nota, pois o prazo para o cancelamento da NF-e e de:" ##"horas"						
						EndIf								
					ElseIf Month(SF2->F2_EMISSAO) <> Month(dDataBase) .OR. Year(SF2->F2_EMISSAO) <> Year(dDataBase)
						lRet	 := .F.
						cXmlRet := STR0030 //"Nao se pode excluir uma nota fiscal quando o mes ou ano de sua emissao for diferente da database do sistema."
					EndIf
				ElseIf AllTrim(SF2->F2_ESPECIE) == "RPS" //Validacoes RPS - Regras assimiladas do fonte Mata521 - MaCanDelF2()
					aAdd(aMunic,{"SP","São Bernardo do Campo","3548708"})
					aAdd(aMunic,{"AL","Maceió","2704302"})
					aAdd(aMunic,{"CE","Fortaleza","2304400"})
					aAdd(aMunic,{"RN","Natal","2408102"})
					aAdd(aMunic,{"SP","São Paulo","3550308"})
					aAdd(aMunic,{"BA","Salvador","2927408"})
					aAdd(aMunic,{"PR","Londrina","4113700"})
					aAdd(aMunic,{"GO","Goiânia","5208707"})
					aAdd(aMunic,{"PE","Recife","2611606"})
					aAdd(aMunic,{"PI","Teresina","2211001"})
					aAdd(aMunic,{"RS","Porto Alegre","4314902"})
					aAdd(aMunic,{"PA","Parauapebas","1505536"})
					aAdd(aMunic,{"MG","Belo Horizonte","3106200"})
					aAdd(aMunic,{"SP","Guarulhos","3518800"})
					aAdd(aMunic,{"MS","Campo Grande","5002704"})
					aAdd(aMunic,{"DF","Brasília","5300108"})
					aAdd(aMunic,{"RJ","Rio de Janeiro","3304557"})
					aAdd(aMunic,{"AL","Rio Largo","2707701"})
					aAdd(aMunic,{"RO","Porto Velho","1100205"})
					aAdd(aMunic,{"SE","Aracaju","2800308"})
					
					//Valida os parametros pois eles nao sao utilizados para Salvador
					If AllTrim(SM0->M0_CODMUN) == aMunic[aScan(aMunic, {|x| Alltrim(x[2]) == "Salvador"}), 3]
						//Informa os valores padroes
						nExcNfs := 180
						nTpPrz	 := 1						
					EndIf
					
					//Municipios que possuem validacao
					nPosMunic := aScan(aMunic, {|x| Alltrim(x[3]) == AllTrim(SM0->M0_CODMUN)})										
					
					If nPosMunic > 0
						cMunEst := aMunic[nPosMunic, 2] + " - " + aMunic[nPosMunic, 1]
						
						If nTpPrz == 1 //Ate dia XX do mes subsequente
							dDataR := CTOD("01/" + StrZero(Month(SF2->F2_EMISSAO), 2) + Str(Year(SF2->F2_EMISSAO)), "DD/MM/YYYY")
							dDataR := UltDia(StrZero(Month(dDataR), 2), StrZero(Year(dDataR), 4)) + nExcNfs
							
							//Valida data RPS
							If dDataBase > dDataR
								lRet	 := .F.
								cXmlRet := STR0033 + " " + cMunEst + " " + STR0034 + " " + CValToChar(nExcNfs) //"O prazo para exclusao de NF de servico para o municipio de" #"é de até"   														 
								cXmlRet += " " + STR0035 + "," + STR0036 + ":" + DtOC(dDataR) //"do mes subsequente da emissao" #"data limite" 
							EndIf														
						ElseIf nTpPrz == 2 //XX dias apos emissao
							dDataR := SF2->F2_EMISSAO + nExcNfs
							
							//Valida data RPS
							If dDataBase > dDataR
								lRet	 := .F.
								cXmlRet := STR0033 + " " + cMunEst + " " + STR0034 + " " + CValToChar(nExcNfs) //"O prazo para exclusao de NF de servico para o municipio de" #"é de até"  								
								cXmlRet += " " + STR0037 + "," + STR0036 + ":" + DtOC(dDataR)  //"dias a partir da sua emissao" #"data limite"
							EndIf													
						EndIf												
					EndIf
				EndIf
			EndIf
		EndIf
		
		If lRet

            //Armazena informacoes do pedido
            If SL1->L1_SITUA == "FR"
                aAdd(aDadosCup, SL1->L1_SERPED)
                aAdd(aDadosCup, SL1->L1_DOCPED)
                aAdd(aDadosCup, SL1->L1_SERPED)

            //Armazena informacoes do cupom
            Else
                aAdd(aDadosCup, SL1->L1_SERIE)
                aAdd(aDadosCup, SL1->L1_DOC  )
                aAdd(aDadosCup, SL1->L1_PDV  )
            EndIf

            aAdd(aDadosCup, SL1->L1_NUM     )
            aAdd(aDadosCup, cOperador       )
            aAdd(aDadosCup, cTimeCanc       )
            aAdd(aDadosCup, SToD(cDateCanc) )
							
			//Efetua a integracao de Cancelamento
    		Begin Transaction

                //Exclui Venda
                aAux := Lji140ExVe(cIdExt, cNumCancDoc, cProtoNfce, aDadosCup)

                If aAux[1]

                    //Gera InternalId do Protheus
                    aInternal := IntCancExt(/*Empresa*/, /*Filial*/, SLX->LX_SERIE, SLX->LX_CUPOM, SLX->LX_PDV)
                
                    //Gera InternalId do Protheus
                    If aInternal[1]
                        cValInt := aInternal[2]
                    EndIf
                
                    //Adiciona item no De/Para - XXF								
                    If CFGA070Mnt(cMarca, "SLX", "LX_CUPOM", cIdExt, cValInt)

                        //Monta o XML de Retorno
                        cXmlRet:="<ListOfInternalId>"
                        cXmlRet+=    "<InternalId>"
                        cXmlRet+=       "<Name>RetailSalesCancellationInternalId</Name>"
                        cXmlRet+=       "<Origin>" + cIdExt + "</Origin>"
                        cXmlRet+=       "<Destination>" + cValInt + "</Destination>"
                        cXmlRet+=    "</InternalId>"
                        cXmlRet+="</ListOfInternalId>" 
                                                
                        //Identificacao Interna da Venda
                        cDocInt := IntVendExt(/*Empresa*/, /*Filial*/, SLX->LX_SERIE, SLX->LX_CUPOM, SLX->LX_PDV, /*Versao*/)[2]
                        
                        //Remove a venda do De/Para - XXF
                        CFGA070Mnt(cMarca, "SL1", "L1_DOC", cDocExt, cDocInt, .T.)                              	
                    EndIf

                Else

                    DisarmTransaction()

                    lRet    := .F.
                    cXmlRet += aAux[2]
                EndIf
    
			End Transaction
            
		EndIf																																																					 					
	Else
		lRet     := .F.
		cXmlRet  := STR0014 //#"Atualize EAI"                                                        
	EndIf																							
ElseIf nTypeTrans == TRANS_SEND //Envio						 
	cEvent := "upsert" //Evento
	
	//InternalId do cancelamento de venda
	aAux := IntCancExt(/*Empresa*/, /*Filial*/, SLX->LX_SERIE, SLX->LX_CUPOM, SLX->LX_PDV, /*Versão*/)	
	 	
	If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]	
		cValInt := aAux[2]	
	Else
		cValInt := ""
	EndIf
	
	//InternalId da venda
	aAux := IntVendExt(/*Empresa*/, /*Filial*/, SLX->LX_SERIE, SLX->LX_CUPOM, SLX->LX_PDV, /*Versão*/) 
	
	If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]	
		cDocInt := aAux[2]	
	Else
		cDocInt := ""
	EndIf		
		
	//Data de Emissao
	If !Empty(SLX->LX_DTMOVTO)
		cDateCanc := SubStr(DToS(SLX->LX_DTMOVTO), 1, 4) + '-' + SubStr(DToS(SLX->LX_DTMOVTO), 5, 2) + '-' + SubStr(DToS(SLX->LX_DTMOVTO), 7, 2)
	
		//Hora de Emissao	
		cDateCanc += "T"
		cDateCanc += RTrim(SLX->LX_HORA)
	EndIf						
																	 				
	cXmlRet := '<BusinessEvent>'
	cXmlRet +=     '<Entity>RETAILSALESCANCELLATION</Entity>'
	cXmlRet +=     '<Event>' + cEvent + '</Event>'
	cXmlRet +=     '<Identification>'
	cXmlRet +=         '<key name="InternalId">' + cValInt + '</key>'
	cXmlRet +=     '</Identification>'
	cXmlRet += '</BusinessEvent>'
		
	cXmlRet += '<BusinessContent>'

	cXmlRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
	cXmlRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
	cXmlRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
	cXmlRet +=    '<InternalId>' + cValInt + '</InternalId>'
	cXmlRet +=    '<RetailSalesInternalId>' + cDocInt + '</RetailSalesInternalId>'
	cXmlRet +=    '<OperatorCode>' + RTrim(SLX->LX_OPERADO) + '</OperatorCode>'
	cXmlRet +=    '<CancelDate>' + cDateCanc + '</CancelDate>'
		
	cXmlRet += '</BusinessContent>'																 																																							
EndIf		

cXmlRet := EncodeUTF8(cXmlRet) 

//Restaura areas
For nI := 1 To Len(aAreas)
	RestArea(aAreas[nI])
Next nI

RestArea(aArea)
LjGrvLog("LOJI140","ID_FIM")
Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntCancExt
Monta o InternalID do Cliente de acordo com código passado

@param cEmpresa, Código da empresa (Default cEmpAnt)
@param cFil, Código da Filial (Default cFilAnt)
@param cDocumento, Código do Documento (Cupom Fiscal)
@param cSerie, Serie do Documento (Serie Fiscal)		
@param cPdv, Código do Pdv
@param cVersao, Versao da Mensagem
@return aResult, Array contendo no primeiro parâmetro uma variável logica
		indicando se o registro foi encontrado.
		No segundo parâmetro uma variável string com o InternalID montado.

@author alessandrosantos
@since 03/07/2016
@version P12.1.17				
/*/		
//-------------------------------------------------------------------------------------------------

Function IntCancExt(cEmpresa, cFil, cSerie, cDocumento, cPdv, cVersao)
   
Local aResult  := {}

Default cEmpresa 		:= cEmpAnt
Default cFil     		:= xFilial("SLX")
Default cDocumento  	:= SLX->LX_CUPOM
Default cSerie		    := SLX->LX_SERIE
Default cPdv			:= SLX->LX_PDV
Default cVersao		    := "1.000"

If cVersao $ "1.000|1.001"
	aAdd(aResult, .T.)
	aAdd(aResult, cEmpresa + "|" + RTrim(cFil) + "|" + RTrim(cSerie) + "|" +;
					RTrim(cDocumento) + "|" + RTrim(cPdv))
Else
	aAdd(aResult, .F.)
	aAdd(aResult, STR0020 + Chr(10) + STR0021 + "1.000|1.001") //#"Versao nao suportada." ##"As versoes suportadas sao:"
EndIf
   
Return aResult

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntCancInt
Recebe um InternalID e retorna o código do Cancelamento.

@param cInternalID, InternalID recebido na mensagem
@param cRefer, Produto que enviou a mensagem	
@param cVersao, Versão da mensagem única (Default 1.000)
@return aResult, Array contendo no primeiro parâmetro uma variável logica
		indicando se o registro foi encontrado no de/para.
		No segundo parâmetro uma variável array com o empresa,
		filial, documento serie e pdv do cancelamento.

@author alessandrosantos
@since 03/07/2016
@version P12.1.17				
/*/
//-------------------------------------------------------------------------------------------------

Function IntCancInt(cInternalID, cRefer, cVersao)
   
Local aResult  := {}
Local aTemp    := {}
Local cTemp    := ""
Local cAlias   := "SLX"
Local cField   := "LX_CUPOM"

Default cVersao  := "1.000"

cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
   
If Empty(cTemp)
	aAdd(aResult, .F.)
	aAdd(aResult, STR0022 + " " + AllTrim(cInternalID) + " " + STR0023) //#"Cancelamento:" ##"nao encontrado no de/para!" 
Else
	If cVersao $ "1.000|1.001"
		aAdd(aResult, .T.)
       aTemp := Separa(cTemp, "|")
       aAdd(aResult, aTemp)	      
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, STR0020 + Chr(10) + STR0021 + "1.000|1.001") //#"Versao nao suportada." ##"As versoes suportadas sao:"       
   EndIf
EndIf

Return aResult

//----------------------------------------------------------------------
/*/{Protheus.doc} Lji140ExVe
Função responsavel por efetuar a exclusão da venda a partir do LOJA140.
Uso LOJI140, LOJI140O

@since   30/05/2019
@return  Array - lRet - Registro excluído
                 cMsgRet - Mensagem de erro
/*/
//----------------------------------------------------------------------
Function Lji140ExVe(cInternalId, cNumCancDoc, cProtoNfce, aDadosCup)

    Local aArea     := GetArea()
    Local aAreaSL1  := SL1->( GetArea() )
    Local lRet      := .T.
    Local nRet      := 0
    Local cMsgRet   := ""    
    Local aErroAuto := {} //Logs de erro do ExecAuto    
    Local nOpcX     := 5  //Opcao de Inclusao
    Local nI        := 0
    Local lIntegHtl := SuperGetMv("MV_INTHTL",, .F.) //Integracao Hotelaria
    Local cFilBkp   := cFilAnt
    Local nModBkp   := nModulo
    Local dDataBkp  := dDataBase
    Local cOrcRes   := SL1->L1_ORCRES

    Default cProtoNfce := ""

    Private lMsErroAuto    := .F. //Variavel que informa a ocorrência de erros no ExecAuto
    Private lMsHelpAuto    := .T. //Variavel de controle interno do ExecAuto
    Private lAutoErrNoFile := .T. //Força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário

    //Atualiza variaveis publicas
    cFilAnt   := SL1->L1_FILIAL
    nModulo   := 12
    dDataBase := aDadosCup[7]

    //Gera Log de Cancelamento - SLX
    If LjLogCanc(,,,, aDadosCup)

        //Efetua o Cancelamento do Cupom
        MsExecAuto( { |a,b,c,d,e,f,g,h,i,j,l| nRet := Lj140Exc(a,b,c,d,e,f,g,h,i,j,l) }, "SL1"         , /*nReg*/    , nOpcX      , /*aReserv*/ , .T.       ,;
                                                                                         xFilial("SL1"), aDadosCup[4], cNumCancDoc, /*lFinCanc*/, cProtoNfce,;
                                                                                         .T.)

        //Verifica se encontrou erros no cancelamento de cupom
        If lMsErroAuto .Or. ValType(nRet) <> "N" .Or. ( ValType(nRet) == "N" .And. nRet <> 1 )

            lRet      := .F.
            aErroAuto := GetAutoGrLog()

            //Armazena mensagens de erro
            For nI := 1 To Len(aErroAuto)
                cMsgRet += aErroAuto[nI] + Chr(10)
            Next nI

            //Se ExecAuto nao retornou erro, grava mensagem padrao
            If Len(aErroAuto) == 0
                cMsgRet += STR0007 + " " + AllTrim(cInternalId) + I18n(STR0039, {"Lj140Exc"})    //"Erro no cancelamento do cupom:"     //" (#1) - Para mais detalhes, verifique o Log."
            EndIf
        EndIf

        //Exclui o orçamento da reserva
        If lRet .And. !Empty(cOrcRes)
            SL1->( DbSetOrder(1) )
            If SL1->( DbSeek(xFilial("SL1") + cOrcRes) )
                lRet := Lj140ExcOrc(/*cFilRes*/, /*aChaveCHRe*/, /*cProtoNfce*/, /*lAtStEC*/, @cMsgRet)
            EndIf
        EndIf

        //Exclui registros referentes a Integracao Hotelaria
        If lRet .And. lIntegHtl
            //Exclui registro de informações de Reserva, se houver
            MH3->( dbSetOrder(1) )
            If MH3->( msSeek( FWxFilial("MH3") + aDadosCup[1] + aDadosCup[2] ) )
                RecLock( "MH3", .F. )
                MH3->( dbDelete() )
                MH3->( MsUnlock() )
            Endif

            //Exclui registro de informações dos itens de Reserva
            MH4->( dbSetOrder(1) )
            If MH4->( msSeek( FWxFilial("MH4") + aDadosCup[1] + aDadosCup[2] ) )
                While MH4->MH4_FILIAL + MH4->MH4_SERRPS + MH4->MH4_DOCRPS == xFilial("MH4") + aDadosCup[1] + aDadosCup[2]
                    RecLock( "MH4", .F. )
                    MH4->( dbDelete() )
                    MH4->( MsUnlock() )
                    MH4->(dbSkip())
                EndDo
            EndIf
        EndIf

    Else

        lRet    := .F.
        cMsgRet := STR0007 + " " + AllTrim(cInternalId) + I18n(STR0039, {"LjLogCanc"})    //"Erro no cancelamento do cupom:"      //" (#1) - Para mais detalhes, verifique o Log."
    EndIf

    //Volta valores das variaveis publicas
    cFilAnt   := cFilBkp
    nModulo   := nModBkp
    dDataBase := dDataBkp

    RestArea(aAreaSL1)
    RestArea(aArea)

Return {lRet, cMsgRet}