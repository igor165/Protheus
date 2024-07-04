#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'   //Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH'       //Include para rotinas com MVC


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPI200(cXML, nTypeTrans, cTypeMessage)
Função de Integração do Edital.

@author alexandre.gimenez
@param cXML - Variavel com conteudo xml para envio/recebimento.
@param nTypeTrans - Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc)
@since 05/11/2013
@return aRet[1] - (boolean) Indica o resultado da execução da função
@return aRet[2] - (caracter) Mensagem Xml para envio 
/*/
//-------------------------------------------------------------------

Function GCPI200( cXML, nTypeTrans, cTypeMessage )
Local cXMLRet	:= "" // Retorno de função
Local cError	:= "" //ParserXML
Local cWarning:= "" //ParserXML
Local cItem   := "000000"
Local cSeekSA2:= ""

Local nX		:= 0
Local nY      := 0
Local nI      := 0

Local lLicit	:= .T.
Local lRet		:= .T.
Local lUsaLote:= .F.

Local aErro	:= {}
Local aArea	:= GetArea()
Local aAreCO1 := CO1->(GetArea())
Local aAreCO2 := CO2->(GetArea())
Local aAreCO3 := CO3->(GetArea())
Local aAreCP3 := CP3->(GetArea()) 
Local aAreSB1 := SB1->(GetArea())
Local aAreSA2 := SA2->(GetArea())

Local aBusca	:= {}
Local aSeekCO1 := {}//{ { "CO2_FILIAL" , ""} , { "CO2_CODEDT" , ""}, { "CO2_NUMPRO" , "" }, { "CO2_ITEM" , "" },  { "CO2_CODPRO " , "" } }
Local aSeekCO2 := {}//{ { "CO2_FILIAL" , ""} , { "CO2_CODEDT" , ""}, { "CO2_NUMPRO" , "" }, { "CO2_ITEM" , "" },  { "CO2_CODPRO " , "" } }
Local aSeekCP3 := {}
Local aSeekCO3 := { { "CO3_FILIAL" ,"" } , { "CO3_CODEDT" , ""}, { "CO3_NUMPRO" , "" }, { "CO3_ITEM" , ""}, { "CO3_CODIGO" , "" } }

 
Local oModel
Local oModelCO1
Local oModelCO2
Local oModelCO3
Local oModelCP3
Local oModelCP6

Private oXml		
Private oBMessage		//BusinessMessage
Private oBContent		//BusinessContent
Private oEdictItem	//Array de itens 		(EdictItem)
Private oEdictBidd	//Array de Propostas (BidderProposal)
Private oEdictLote	//Array de Lotes 		(EdictLot)

//nTypeTrans := TRANS_RECEIVE
//cTypeMessage := EAI_MESSAGE_BUSINESS
//Tratamento do recebimento de mensagens
If nTypeTrans == TRANS_RECEIVE
	//-- Recebimento da WhoIs - Qual é a versãoo da mensagem
	If cTypeMessage == EAI_MESSAGE_WHOIS 
		cXMLRet := '1.000'
	//-- Recebimento da Response Message
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
	                                                              
	//-- Receipt Message (Aviso de receb. em transmissoes assincronas)
	ElseIf ( cTypeMessage == EAI_MESSAGE_RECEIPT )
		cXMLRet := '<TAGX>TESTE DE RECEPCAO RECEIPT MESSAGE</TAGX>'
	
	//Recebimento da mensagem
	ElseIf cTypeMessage == EAI_MESSAGE_BUSINESS  
		
		//oXML := XmlParser(cXml, "_", @cError, @cWarning)
		oXML := XmlParser( cXml , "_", @cError, @cWarning)
		If ( oXml <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) 	
			
			oBMessage  := oXml:_TOTVSMessage:_MessageInformation							// Mapeamento
			oBContent  := oXml:_TOTVSMessage:_BusinessMessage  							// Mapeamento
			
			If AllTrim(oBMessage:_Product:_name:Text) == 'PARADIGMA'
				
				//------------------------------
				// Valida cabeçalho do edital
				//------------------------------
				If I200ValCab( oXml , @aErro)
					DbSelectArea("CO1")
					DbSelectArea("CO2")
					DbSelectArea("CO3")
					DbSelectArea("CP3")
					DbSelectArea("SB1")
					DbSelectArea("SA2")
					
					//---------------------------------
					// Metodo de avaliação: Por item
					//---------------------------------
					aSeekCO1 := Separa (oBContent:_ExternalCode:Text , "|")
					
					If CO1->(DbSeek( Padr( aSeekCO1[2] , TamSX3("CO1_FILIAL")[1] ) + Padr( aSeekCO1[3] , TamSX3("CO1_CODEDT")[1] ) ) )
						If oBContent:_MethodAvaliation:Text == "1"
							oModel   	:= FWLoadModel( 'GCPA200' )								
							oModelCO1	:= oModel:GetModel('CO1MASTER')
							oModelCO2	:= oModel:GetModel('CO2DETAIL')
							oModelCO3	:= oModel:GetModel('CO3DETAIL')
							oModelCP3	:= oModel:GetModel('CP3DETAIL')
							oModel:SetOperation( MODEL_OPERATION_UPDATE )
							oModel:Activate()
							//------------------------------
							// Valida os itens do edital
							//------------------------------							
							If I200ValIte( oXml , @aErro)

								If oBContent:_Steps:Text == "HO"
									
									oEdictItem := oBContent:_ListOfEdictItem:_EdictItem
									
									For nX := 1 To Len(oEdictItem)
										aSeekCO2 := Separa( oEdictItem[nX]:_ExternalItemCode:Text , "|" )	
										AAdd( aBusca, { "CO2_CODPRO", 	aSeekCO2[6]} )
										
										//--------------------------------------------
										// Posiciona no produto (CO2)
										//--------------------------------------------
										If I200SeekLi( oModelCO2 , aBusca) > 0
											oEdictBidd := oEdictItem[nX]:_ListOfBidderProposal:_BidderProposal
											
											//---------------------------------------
											// Limpa cadastro de licitantes (CO3)
											//---------------------------------------
											If oModelCO3:Length() > 0
												For nI := 1 To oModelCO3:Length() 
													oModelCO3:GoLine( nI ) 									 
													If !oModelCO3:IsDeleted()
														oModelCO3:DeleteLine() 
													EndIf 										
												Next nI									
											EndIf
											
											//---------------------------------------------------
											// Grava os licitantes do Portal eletrônic no ERP
											//---------------------------------------------------
											oModelCO3:GoLine( 1 )
											For nY := 1 To Len(oEdictBidd)		
												cSeekSA2 :=	Padr( Separa( oEdictBidd[nY]:_BidderInternalId:Text , "|")[2]	, TamSX3("A2_FILIAL")[1]) + ;
																Padr( Separa( oEdictBidd[nY]:_BidderInternalId:Text , "|")[3]	, TamSX3("A2_COD")[1]) + ;
																Padr( Separa( oEdictBidd[nY]:_BidderInternalId:Text , "|")[4]	, TamSX3 ("A2_LOJA")[1] )
 
												If SA2->(DbSeek( cSeekSA2 )) 
													cItem := soma1(cItem)
													oModelCO3:AddLine()
													oModelCO3:SetValue( "CO3_ITEM" 		, cItem )												
													oModelCO3:SetValue( "CO3_CODIGO" 	, Separa( oEdictBidd[nY]:_BidderInternalId:Text , "|")[3] )
													oModelCO3:SetValue( "CO3_LOJA" 		, Separa( oEdictBidd[nY]:_BidderInternalId:Text , "|")[4] )												
													oModelCO3:SetValue( "CO3_STATUS" 	, oEdictBidd[nY]:_BidderStatus:Text )
													oModelCO3:SetValue( "CO3_TIPO" 		, oEdictBidd[nY]:_BidderType:Text )
													oModelCO3:SetValue( "CO3_VLUNIT" 	, Val( oEdictBidd[nY]:_UnitPrice:Text ) )
													oModelCO3:SetValue( "CO3_REVOGA"   , oEdictBidd[nY]:_Repealed:Text )
													//oModelCO3:SetValue( oEdictBidd[nY]:_DeliveryTime:Text )
												Else
													AAdd( aErro , "O fornecedor informado não existe: (" + cSeekSA2 + ") BidderProposal item : " + Str(nY)  )
													lRet := .F.
												EndIf
											Next nY
											
											cItem := "000000"
											
											If lRet .And. oModel:VldData()
												oModel:CommitData()
												RecLock("CO1",.F.)
													CO1->CO1_STATUS := "1"
													CO1->CO1_ETAPA := oBContent:_Steps:Text
												MsUnlock()
											Else
												I200GetErr(@aErro , oModel)
											EndIf 
										Else
											AAdd( aErro , "O produto informado não existe ou não faz parte deste edital" )
										EndIf
									Next nX
								Else
									AAdd( aErro , "Para essa integração é permitido informar a tag STEPS apenas como HO" )														
								EndIf
							EndIf
							
						//---------------------------------
						// Metodo de avaliação: Por lote
						//---------------------------------					
						ElseIf oBContent:_MethodAvaliation:Text == "2"
							oModel   	:= FWLoadModel( 'GCPA201' )								
							oModelCO1	:= oModel:GetModel('CO1MASTER')
							oModelCO2	:= oModel:GetModel('CO2DETAIL')
							oModelCO3	:= oModel:GetModel('CO3DETAIL')
							oModelCP3	:= oModel:GetModel('CP3DETAIL')
							oModelCP6  := oModel:GetModel('CP6DETAIL')
							oModel:SetOperation( MODEL_OPERATION_UPDATE )
							oModel:Activate()
							
							If I200ValLot( oXml , @aErro)
								If oBContent:_Steps:Text == "HO"
									oModelCO1:SetValue( "CO1_ETAPA" , oBContent:_Steps:Text )
									
									oEdictLote := oBContent:_ListOfEdictLot:_EdictLot
									For nX := 1 To Len(oEdictItem)
																										
										aSeekCP3 := Separa( oEdictLote[nX]:_ExternalLotCod:Text , "|" )	
										AAdd( aBusca, { "CP3_LOTE", 	aSeekCP3[5]} )
										
										//--------------------------------------------
										// Posiciona no lote (CP3)
										//--------------------------------------------									
										If I200SeekLi( oModelCP3 , aBusca) > 0
											oEdictBidd := oEdictLote[nX]:_ListOfBidderProposal:_BidderProposal
											oEdictItem := oEdictLote[nX]:_ListOfEdictItem:_EdictItem
											
											//---------------------------------------
											// Limpa cadastro de licitantes (CO3)
											//---------------------------------------
											If oModelCO3:Length() > 0
												For nI := 1 To oModelCO3:Length() 
													oModelCO3:GoLine( nI ) 									 
													If !oModelCO3:IsDeleted()
														oModelCO3:DeleteLine() 
													EndIf 										
												Next nI									
											EndIf
											
											//---------------------------------------------------------------
											// Grava os licitantes oriundos do Portal eletrônico no ERP (CO3)
											//---------------------------------------------------------------
											oModelCO3:GoLine( 1 )
											For nY := 1 To Len(oEdictBidd)
												cItem := soma1(cItem)
										
												oModelCO3:AddLine()
												
												cSeekSA2 :=	Padr( Separa( oEdictBidd[nY]:_BidderInternalId:Text , "|")[2]	, TamSX3("A2_FILIAL")[1]) + ;
																Padr( Separa( oEdictBidd[nY]:_BidderInternalId:Text , "|")[3]	, TamSX3("A2_COD")[1]) + ;
																Padr( Separa( oEdictBidd[nY]:_BidderInternalId:Text , "|")[4]	, TamSX3 ("A2_LOJA")[1] )
 
												If SA2->(DbSeek( cSeekSA2 )) 
													oModelCO3:SetValue( "CO3_ITEM" 		, cItem )												
													oModelCO3:SetValue( "CO3_CODIGO" 	, Separa( oEdictBidd[nY]:_BidderInternalId:Text , "|")[3] )
													oModelCO3:SetValue( "CO3_LOJA" 		, Separa( oEdictBidd[nY]:_BidderInternalId:Text , "|")[4] )												
													oModelCO3:SetValue( "CO3_STATUS" 	, oEdictBidd[nY]:_BidderStatus:Text )
													oModelCO3:SetValue( "CO3_TIPO" 		, oEdictBidd[nY]:_BidderType:Text )
													oModelCO3:SetValue( "CO3_VLUNIT" 	, Val( oEdictBidd[nY]:_UnitPrice:Text ) )
													oModelCO3:SetValue( "CO3_REVOGA"   , oEdictBidd[nY]:_Repealed:Text )
													//oModelCO3:SetValue( oEdictBidd[nY]:_DeliveryTime:Text )
												Else
													AAdd( aErro , "O fornecedor informado não existe: (" + cSeekSA2 + ") BidderProposal item : " + Str(nY)  )
												EndIf
											Next nY
											
											cItem := "000000"
											
											//-----------------------------------------------------------------------
											// Grava a composição do lote oriunda do Portal eletrônico no ERP (CP6)
											//-----------------------------------------------------------------------
											For nY := 1 To Len(oEdictItem)
												aSeekCO2 := Separa( oEdictItem[nY]:_ExternalItemCode:Text , "|" )	
												AAdd( aBusca, { "CP6_CODPRO", 	aSeekCO2[6]} )
												
												//-------------------------------------------------------------------
												// Posiciona na composição do lote (CP6) para informar os preços unitários
												//------------------------------------------------------------------- 
												If I200SeekLi( oModelCP6 , aBusca) > 0									 
													oModelCP6:SetValue( "CP6_PRCUN"	, Val( oEdictItem[nY]:_UnitPrice:Text ) )													
												Else
													AAdd( aErro , "O produto informado : (" + cSeekSA2 + ") não existe ou faz parte de outro lote do edital")
												EndIf
											Next nY											
											
											
											If oModel:VldData()
												oModel:CommitData()
												RecLock("CO1",.F.)
													CO1->CO1_STATUS := "1"
													CO1->CO1_ETAPA := oBContent:_Steps:Text
												MsUnlock()
											Else
												I200GetErr(@aErro , oModel)
											EndIf 
										Else
											AAdd( aErro , "O lote informado não existe ou não faz parte deste edital" )
										EndIf
									Next nX
								Else
									AAdd( aErro , "Para essa integração é permitido informar a tag STEPS apenas como HO" )														
								EndIf												
							EndIf					
						EndIf
					Else
						AAdd ( aErro , "O edital informado não existe na base de dados" )
					EndIf				
				EndIf
			Else
				AAdd(aErro , "Verifique o atributo name da tag Product")
			EndIf
			
			For nX:=1 to len(aErro)
				cXmlRet+= '<Message type="ERROR" code="c2">'+ AllTrim(aErro[nX]) + '</Message>'
				lRet := .T.
			Next
						
		EndIf	
	EndIf
//Envio do XML                
ElseIf nTypeTrans == TRANS_SEND

	oModel:= FwModelActive()
//------------------------------------
// Valida Origem do Edital (Lote/Item)
//------------------------------------	
	If oModel:GetId() == "GCPA201"
		lUsaLote := .T.
	EndIf
//------------------------------
// Add Cabecaçalho (CO1)
//------------------------------
	cXMLRet += i200AddEdt(oModel)
//------------------------------
// Add Lote (CP3)
//------------------------------
	If lUsaLote
		cXMLRet +='<ListOfEdictLot>'
		cXMLRet +='	<EdictLot>'	
		cXMLRet += i200AddLot(oModel)		
	EndIf	
//------------------------------
// Add Produto / Item (CO2)
//------------------------------
	cXMLRet +='<ListOfEdictItem>'
	cXMLRet +='	<EdictItem>'
	cXMLRet += i200AddPro(oModel)
	//-------------------------------
	// Fecha tag Produto Quando lote
	//-------------------------------
	If lUsaLote
		cXMLRet +='	</EdictItem>'	
		cXMLRet +='</ListOfEdictItem>'			
	EndIf	
//------------------------------
// Add Licitante (CO3)
//------------------------------
	cXMLRet +='	<ListOfBidderProposal>'
	If oModel:GetId() == "GCPA201" .And. oModel:GetModel("CO2DETAIL"):nline # 1
		lLicit := .F.
	EndIf
	If lLicit
		For nX := 1 to oModel:GetModel("CO3DETAIL"):Length()
			oModel:GetModel("CO3DETAIL"):GoLine(nX)
			If oModel:GetModel("CO3DETAIL"):GetValue("CO3_TIPO") == '2' // So Adiona Fornecedores
				cXMLRet += i200AddLic(oModel)
			EndIf	
		Next nX
	EndIf
	cXMLRet +='	</ListOfBidderProposal>'
//-------------------------------
// Fecha tag Lote 
//-------------------------------	
	If lUsaLote
		cXMLRet +='	</EdictLot>'	
		cXMLRet +='<ListOfEdictLot>'
	Else	
//-------------------------------
// Fecha tag Produto Sem lote
//-------------------------------
		cXMLRet +='	</EdictItem>'
		cXMLRet +='</ListOfEdictItem>'	
	EndIf	

EndIf

RestArea( aAreSA2 )
RestArea( aAreSB1 )
RestArea( aAreCP3 )
RestArea( aAreCO3 )
RestArea( aAreCO2 )
RestArea( aAreCO1 )
RestArea( aArea )
Return { lRet, cXMLRet }


//-------------------------------------------------------------------
/*/{Protheus.doc} i200AddEdt(oModel)
Adiciona dados do cabecalho do Edital ao Xml

@author alexandre.gimenez
@param oModel 
@since 05/11/2013
@return cRet 
/*/
//-------------------------------------------------------------------
Static Function i200AddEdt(oModel)
Local oModEdt := oModel:GetModel("CO1MASTER")
Local cRet		:= ""
Local dData	:= ctod("")

//---------------------
// Data Limite edital
//---------------------
GCPChkData("","","PB",oModEdt:GetValue("CO1_DTABER"),oModEdt:GetValue("CO1_TPPRAZ"),oModEdt:GetValue("CO1_PRAZO"),@dData,.F.)

cRet+='<CompanyId>'+ cEmpAnt +'</CompanyId>'
cRet+='<BranchId>'+ RTrim(xFilial("CO1")) +'</BranchId>'
cRet+='<CompanyInternalId>'+ cEmpAnt + "|" + RTrim( oModEdt:GetValue("CO1_FILIAL")) +'</CompanyInternalId>'
cRet+='<InternalId>'+ cEmpAnt + "|" + RTrim( xFilial("CO1") ) + "|"+ RTrim(oModEdt:GetValue("CO1_CODEDT")) + '|' + RTrim(oModEdt:GetValue("CO1_NUMPRO")) +'</InternalId>'
cRet+='<Code>'+ RTrim(oModEdt:GetValue("CO1_CODEDT")) +'</Code>'
cRet+='<Process>'+ RTrim(oModEdt:GetValue("CO1_NUMPRO")) +'</Process>'
cRet+='<MethodAvaliation>'+ RTrim(oModEdt:GetValue("CO1_AVAL")) +'</MethodAvaliation>'
cRet+='<Object>'+ RTrim(SubStr(oModEdt:GetValue("CO1_OBJETO"),1,1000)) +'</Object>'
cRet+='<StartDateEdict>'+ SubStr(dtos(oModEdt:GetValue("CO1_DTABER")),1,4) + '-' + SubStr(dtos(oModEdt:GetValue("CO1_DTABER")),5,2) +'-'+ SubStr(dtos(oModEdt:GetValue("CO1_DTABER")),7,2) +'T'+  Transform(oModEdt:GetValue("CO1_HRABER"),"@R 99:99:00") +'</StartDateEdict>'
cRet+='<EndDateEdict>'+ SubStr(Dtos(dData),1,4) +'-'+ SubStr(Dtos(dData),5,2) +'-'+ SubStr(Dtos(dData),7,2) +'</EndDateEdict>'
cRet+='<DateReceveidProposal>'+ SubStr(dtos(oModEdt:GetValue("CO1_DATARP")),1,4) +'-'+ SubStr(dtos(oModEdt:GetValue("CO1_DATARP")),5,2) +'-'+ SubStr(dtos(oModEdt:GetValue("CO1_DATARP")),7,2)+'T'+ Transform(oModEdt:GetValue("CO1_HORARP"),"@R 99:99:00") +'</DateReceveidProposal>'
cRet+='<PublishEdict>'+ SubStr(dtos(oModEdt:GetValue("CO1_DTPUBL")),1,4) +'-'+ SubStr(dtos(oModEdt:GetValue("CO1_DTPUBL")),5,2) +'-'+ SubStr(dtos(oModEdt:GetValue("CO1_DTPUBL")),7,2) +'</PublishEdict>'
cRet+='<AdjudicationEdict>'+ SubStr(dtos(oModEdt:GetValue("CO1_DTADJU")),1,4) +'-'+ SubStr(dtos(oModEdt:GetValue("CO1_DTADJU")),5,2)+'-'+ SubStr(dtos(oModEdt:GetValue("CO1_DTADJU")),7,2) + 'T'+ Transform(oModEdt:GetValue("CO1_HRADJU"),"@R 99:99:00") +'</AdjudicationEdict>'
cRet+='<SpecieEdict>'+ RTrim(oModEdt:GetValue("CO1_ESPECI")) +'</SpecieEdict>'
cRet+='<SRP>'+ RTrim(oModEdt:GetValue("CO1_SRP")) +'</SRP>'
cRet+='<Steps>'+ RTrim(oModEdt:GetValue("CO1_ETAPA")) +'</Steps>'
cRet+='<Version>'+ RTrim(oModEdt:GetValue("CO1_VERSAO")) +'</Version>'
cRet+='<Duration>'+ RTrim(str(oModEdt:GetValue("CO1_PRAZO"))) +'</Duration>'
cRet+='<Modality>'+ RTrim(oModEdt:GetValue("CO1_MODALI")) +'</Modality>'
cRet+='<ModalityType>'+ RTrim(oModEdt:GetValue("CO1_TIPO")) +'</ModalityType>'
cRet+='<Rules>'+ RTrim(oModEdt:GetValue("CO1_REGRA")) +'</Rules>' 

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} i200AddLot(oModel)
Adiciona dados do Lote ao Xml

@author alexandre.gimenez
@param oModel 
@since 05/11/2013
@return cRet 
/*/
//-------------------------------------------------------------------
Static Function i200AddLot(oModel)
Local oModLot := oModel:GetModel("CP3DETAIL")
Local cRet		:= ""

cRet+='	<InternalLotCod>'+ cEmpAnt + "|" + RTrim( xFilial("CP3")) + "|"+ RTrim( oModLot:GetValue("CP3_CODEDT") ) + "|" + RTrim( oModLot:GetValue("CP3_NUMPRO") ) + "|" + RTrim( oModLot:GetValue("CP3_LOTE")) +'</InternalLotCod>'
cRet+='	<LotCode>'+ RTrim(oModLot:GetValue("CP3_LOTE")) +'</LotCode>'
cRet+='	<StatusLot>'+ RTrim(oModLot:GetValue("CP3_STATUS")) +'</StatusLot>'
cRet+='	<TotalPrice>'+ str(oModLot:GetValue("CP3_VLRTOT"),14,2) +'</TotalPrice>'
cRet+='	<AdjustedPrice>'+ str(oModLot:GetValue("CP3_VLRRJ"),14,2) +'</AdjustedPrice>'

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} i200AddPro(oModel)
Adiciona dados do produto ao Xml

@author alexandre.gimenez
@param oModel 
@since 05/11/2013
@return cRet 
/*/
//-------------------------------------------------------------------
Static Function i200AddPro(oModel)
Local oModPro := oModel:GetModel("CO2DETAIL")
Local cRet := ""

cRet+='	<InternalItemCod>'+ cEmpAnt + "|" + RTrim( xFilial("CO2")) + "|"+ RTrim ( oModPro:GetValue("CO2_CODEDT") ) + "|" + RTrim( oModPro:GetValue("CO2_NUMPRO") ) + "|" + RTrim( oModPro:GetValue("CO2_ITEM"))+"|"+ RTrim( oModPro:GetValue("CO2_CODPRO")) +'</InternalItemCod>'
cRet+='	<ItemCode>'+ cEmpAnt + "|" + xFilial("SB1") +"|"+  oModPro:GetValue("CO2_CODPRO") +'</ItemCode>'
cRet+='	<Quantity>'+ str(oModPro:GetValue("CO2_QUANT"),14,2) +'</Quantity>'
cRet+='	<EstimatedPrice>'+ str(oModPro:GetValue("CO2_VLESTI"),14,2) +'</EstimatedPrice>'

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} i200AddLic(oModel)
Adiciona dados do Licitante ao Xml

@author alexandre.gimenez
@param oModel 
@since 05/11/2013
@return cRet 
/*/
//-------------------------------------------------------------------
Static Function i200AddLic(oModel)
Local oModLic := oModel:GetModel("CO3DETAIL")
Local cRet := ""

cRet+='		<BidderProposal>'
cRet+='			<InternalItemCod>'+ cEmpAnt + "|" + RTrim( xFilial("CO3") )	 + "|"+ RTrim( oModLic:GetValue("CO3_CODEDT") ) + "|" + RTrim( oModLic:GetValue("CO3_NUMPRO") ) + "|" + RTrim ( oModLic:GetValue("CO3_ITEM") ) + RTrim(xFilial("CO3")) +'|'+ RTrim(oModLic:GetValue("CO3_CODIGO")) +'</InternalItemCod>'
cRet+='			<BidderInternalId>'+ cEmpAnt +'|'+ RTrim(xFilial("CO3")) +'|'+ RTrim(oModLic:GetValue("CO3_CODIGO")) +'|'+ RTrim(oModLic:GetValue("CO3_LOJA")) +'</BidderInternalId>'
cRet+='			<BidderStatus>'+ RTrim(oModLic:GetValue("CO3_STATUS")) +'</BidderStatus>'
cRet+='			<BidderType>'+ RTrim(oModLic:GetValue("CO3_TIPO")) +'</BidderType>'
/*cRet+='		<FreightType>'+  oModLic:GetValue("")+'</FreightType>' */                     
cRet+='			<UnitPrice>'+ str(oModLic:GetValue("CO3_VLUNIT"),14,2) +'</UnitPrice>'
cRet+='			<Observation>'+ RTrim(SubStr(oModLic:GetValue("CO3_OBS"),1,1000)) +'</Observation>'
cRet+='			<Repealed>'+ RTrim(oModLic:GetValue("CO3_REVOGA")) +'</Repealed>'
cRet+='			<DeliveryTime>'+ SubStr(dtos(oModLic:GetValue("CO3_PRZENT")),1,4) +'-'+ SubStr(dtos(oModLic:GetValue("CO3_PRZENT")),5,2) +'-'+ SubStr(dtos(oModLic:GetValue("CO3_PRZENT")),7,2) +'</DeliveryTime>' 
cRet +='		</BidderProposal>'
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} I200ValCab
Valida o cabeçalho do XML no recebimento

@author Raphael Augustos Ferreira
@param oXML - Objeto do XML
@param @aErro - Retorna vetor com todos os erros do XML
@since 06/11/2013 
@return aRet - Retorna verdadeiro caso o XML esteja válido e falso se o XML possui alguma inconsistência  
/*/
//-------------------------------------------------------------------
Main Function I200ValCab ( oXML , aErro)
Local aErro     := {}	//Retorna os erros do XML

Local nX	//For
Local nY	//For

Local lRet      := .T. // Retorno da função
Local lRetIt    := .T. // Utilizado para validar os arrays de itens, propostas e lotes.

oBMessage  := oXml:_TOTVSMessage:_MessageInformation							// Mapeamento
oBContent  := oXml:_TOTVSMessage:_BusinessMessage  							// Mapeamento

//-----------------------------------------------------
// Validação da MessageInformation e BusinessMessage 
//-----------------------------------------------------
If Type("oBMessage:_CompanyId") == "U" .Or. Empty(oBContent:_CompanyId:Text)
	AAdd(aErro , "É obrigatório informar a tag CompanyId na MessageInformation")
	lRet := .F.
EndIf

If Type("oBMessage:_BranchId") == "U" .Or. Empty(oBContent:_BranchId:Text)
	AAdd(aErro , "É obrigatório informar a tag BranchId na MessageInformation")
	lRet := .F.
EndIf

If Type("oBContent:_ExternalCode") == "U" .Or. Empty(oBContent:_ExternalCode:Text)
	AAdd(aErro , "É obrigatório informar a tag ExternalCode na BusinessMessage")
	lRet := .F.
EndIf

//HOTFIX - Validar modalidades
If Type("oBContent:_Modality") == "U" .Or. Empty(oBContent:_Modality:Text)
	AAdd(aErro , "É obrigatório informar a tag Modality na BusinessMessage")
	lRet := .F.
EndIf
//HOTFIX - Tipos de modalidades
If Type("oBContent:_ModalityType") == "U" .Or. Empty(oBContent:_ModalityType:Text)
	AAdd(aErro , "É obrigatório informar a tag ModalityType na BusinessMessage")
	lRet := .F.
EndIf
//HOTFIX - Validar metodos de avaliação
If Type("oBContent:_MethodAvaliation") == "U" .Or. Empty(oBContent:_MethodAvaliation:Text)
	AAdd(aErro , "É obrigatório informar a tag MethodAvaliation na BusinessMessage")
	lRet := .F.
EndIf

If lRet .And. !oBContent:_MethodAvaliation:Text  $ "12"
	AAdd(aErro , "Valor informado na tag MethodAvaliation inválido")
	lRet := .F.	
EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} I200VaLIte
Valida os itens do XML no recebimento quando o metodo de avaliação é Por Item

@author Raphael Augustos Ferreira
@param oXML - Objeto do XML
@param @aErro - Retorna vetor com todos os erros do XML
@since 06/11/2013 
@return aRet - Retorna verdadeiro caso o XML esteja válido e falso se o XML possui alguma inconsistência  
/*/
//-------------------------------------------------------------------
Main Function I200VaLIte ( oXML , aErro)
Local aErro     := {}	//Retorna os erros do XML

Local nX	//For
Local nY	//For

Local lRet      := .T. // Retorno da função
Local lRetIt    := .T. // Utilizado para validar os arrays de itens, propostas e lotes.

oBMessage  := oXml:_TOTVSMessage:_MessageInformation							// Mapeamento
oBContent  := oXml:_TOTVSMessage:_BusinessMessage  							// Mapeamento
//------------------
// Por item
//------------------
If oBContent:_MethodAvaliation:Text == "1"

	If Type("oBContent:_ListOfEdictItem") == "U"
		AAdd(aErro , "É obrigatório informar a tag ListOfEdictItem quando o MethodAvaliation é 1")
		lRet := .F.
		lRetIt := .F.
	EndIf
	
	If Type("oBContent:_ListOfEdictItem:_EdictItem") == "U"
		AAdd(aErro , "É obrigatório informar a tag ListOfEdictItem quando o MethodAvaliation é 1")
		lRet := .F.
		lRetIt := .F.
	EndIf
		
	If lRetIt .And. Type("oBContent:_ListOfEdictItem:_EdictItem") != "A"
		XmlNode2Arr( oBContent:_ListOfEdictItem:_EdictItem , "_EdictItem" )
	EndIf 		
	
	//--------------------------------------------------
	// Valida os itens (EdictItem) do XML
	//--------------------------------------------------
	oEdictItem := oBContent:_ListOfEdictItem:_EdictItem

	If lRetIt
		For nX := 1 To Len(oEdictItem)
			
			If Type("oEdictItem["+ AllTrim(Str(nX)) +"]:_ExternalItemCode") == "U" .Or. Empty(oEdictItem[nX]:_ExternalItemCode:Text)
				AAdd(aErro , "É obrigatório informar a tag ExternalItemCode da EdictItem. Item : " + Alltrim(Str(nX)) )
				lRet := .F.
			EndIf

			//------------------------------------------------------------------
			// Valida as Propostas (ListOfBidderProposal) do item (EdictItem)
			//------------------------------------------------------------------	
			If Type("oEdictItem["+AllTrim(Str(nX))+"]:_ListOfBidderProposal") == "U"
				AAdd(aErro , "É obrigatório informar a tag ListOfBidderProposal da EdictItem. Item : " + Alltrim(Str(nX)) )
				lRet := .F.
				lRetIt := .F.
			EndIf

			If lRetIt .And. Type("oEdictItem["+AllTrim(Str(nX))+"]:_ListOfBidderProposal:_BidderProposal") == "U"
				AAdd(aErro , "É obrigatório informar a tag BidderProposal dentro da ListOfBidderProposal do EdictItem. Item : " + Alltrim(Str(nX)) )
				lRet := .F.
				lRetIt := .F.
			EndIf

			If lRetIt .And. Type("oEdictItem["+AllTrim(Str(nX))+"]:_ListOfBidderProposal:_BidderProposal") != "A"
				XmlNode2Arr( oEdictItem[nX]:_ListOfBidderProposal:_BidderProposal , "_BidderProposal" )				
			EndIf 						

			oEdictBidd := oEdictItem[nX]:_ListOfBidderProposal:_BidderProposal

			If lRetIt
				//------------------------------------------------------------------
				// Valida os itens da proposta (BidderProposal).
				//------------------------------------------------------------------					
				For nY := 1 To Len(oEdictBidd)
					If Type("oEdictBidd["+AllTrim(Str(nY))+"]:_ExternalItemCode") == "U" .Or. Empty(oEdictBidd[nY]:_ExternalItemCode:Text)
						AAdd(aErro , "É obrigatório informar a tag ExternalItemCode da BidderProposal. Item|Proposta : " + Alltrim(Str(nX)) + "|" + Alltrim(Str(nY)) )
						lRet := .F.
					EndIf

					If Type("oEdictBidd["+AllTrim(Str(nY))+"]:_BidderInternalId") == "U" .Or. Empty(oEdictBidd[nY]:_BidderInternalId:Text)
						AAdd(aErro , "É obrigatório informar a tag BidderInternalId da BidderProposal. Item|Proposta : " + Alltrim(Str(nX)) + "|" + Alltrim(Str(nY)) )
						lRet := .F.
					EndIf
					//HOTFIX - Validar tipos de status.
					If Type("oEdictBidd["+AllTrim(Str(nY))+"]:_BidderStatus") == "U" .Or. Empty(oEdictBidd[nY]:_BidderStatus:Text)
						AAdd(aErro , "É obrigatório informar a tag BidderStatus da BidderProposal. Item|Proposta : " + Alltrim(Str(nX)) + "|" + Alltrim(Str(nY)) )
						lRet := .F.
					EndIf
					//HOTFIX - Validar tipos de solicitantes.
					If Type("oEdictBidd["+AllTrim(Str(nY))+"]:_BidderType") == "U" .Or. Empty(oEdictBidd[nY]:_BidderType:Text)
						AAdd(aErro , "É obrigatório informar a tag BidderType da BidderProposal. Item |Proposta: " + Alltrim(Str(nX)) + "|" + Alltrim(Str(nY)) )
						lRet := .F.
					EndIf

					If Type("oEdictBidd["+AllTrim(Str(nY))+"]:_UnitPrice") == "U" .Or. Empty(oEdictBidd[nY]:_UnitPrice:Text)
						AAdd(aErro , "É obrigatório informar a tag UnitPrice da BidderProposal. Item|Proposta : " + Alltrim(Str(nX)) + "|" + Alltrim(Str(nY)) )
						lRet := .F.
					EndIf
					//HOTFIX - Validar tipos de revogação.
					If Type("oEdictBidd["+AllTrim(Str(nY))+"]:_Repealed") == "U" .Or. Empty(oEdictBidd[nY]:_Repealed:Text)
						AAdd(aErro , "É obrigatório informar a tag Repealed da BidderProposal. Item|Proposta : " + Alltrim(Str(nX)) + "|" + Alltrim(Str(nY)) )
						lRet := .F.
					EndIf

					If Type("oEdictBidd["+AllTrim(Str(nY))+"]:_DeliveryTime") == "U" .Or. Empty(oEdictBidd[nY]:_DeliveryTime:Text)
						AAdd(aErro , "É obrigatório informar a tag DeliveryTime da BidderProposal. Item|Proposta : " + Alltrim(Str(nX)) + "|" + Alltrim(Str(nY)) )
						lRet := .F.
					EndIf		
				Next nY
			EndIf			
		Next nX
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} I200ValLot
Valida os itens do XML no recebimento quando o metodo de avaliação é por lote

@author Raphael Augustos Ferreira
@param oXML - Objeto do XML
@param @aErro - Retorna vetor com todos os erros do XML
@since 06/11/2013 
@return aRet - Retorna verdadeiro caso o XML esteja válido e falso se o XML possui alguma inconsistência  
/*/
//-------------------------------------------------------------------
Main Function I200ValLot ( oXML , aErro)
Local aErro     := {}	//Retorna os erros do XML

Local nX	//For
Local nY	//For

Local lRet      := .T. // Retorno da função
Local lRetIt    := .T. // Utilizado para validar os arrays de itens, propostas e lotes.

oBMessage  := oXml:_TOTVSMessage:_MessageInformation							// Mapeamento
oBContent  := oXml:_TOTVSMessage:_BusinessMessage  							// Mapeamento

//------------------
// Por item
//------------------
If oBContent:_MethodAvaliation:Text == "2"

	If Type("oBContent:_ListOfEdictLot") == "U"
		AAdd(aErro , "É obrigatório informar a tag ListOfEdictLot quando o MethodAvaliation é 2")
		lRet := .F.	
		lRetIt := .F.	
	EndIf

	If Type("oBContent:_ListOfEdictLot:_EdictLot") == "U"
		AAdd(aErro , "É obrigatório informar a tag EdictLot quando o MethodAvaliation é 2")
		lRet := .F.
		lRetIt := .F.
	EndIf

	If Type("oBContent:_ListOfEdictLot:_EdictLot") != "A"
		XmlNode2Arr(oBContent:_ListOfEdictLot:_EdictLot , "_EdictLot")
	EndIf 	

	//-----------------------------------
	// Valida o lote (EdictLot) do XML
	//-----------------------------------
	oEdictLote := oBContent:_ListOfEdictLot:_EdictLot
	If lRetIt
		For nX := 1 To Len(oEdictLote)			
			If Type("oEdictLote[" + AllTrim(Str(nX)) + "]:_ExternalLotCod") == "U" .And. Empty(oEdictLote[nX]:_ExternalLotCod:Text)
				AAdd(aErro , "É obrigatório informar a tag ExternalItemCode da EdictLote. Item : " + Alltrim(Str(nX)) )
				lRet := .F.
			EndIf
			
			//----------------------------------------------------------------
			// Valida o conjunto de itens (ListOfEdictItem) do lote (EdictLot)
			//----------------------------------------------------------------
						
			If Type("oEdictLote[" + AllTrim(Str(nX)) + "]:_ListOfEdictItem") == "U"
				AAdd(aErro , "É obrigatório informar a tag ListOfEdictItem na tag EdictLot")
				lRet := .F.	
				lRetIt := .F.	
			EndIf
			
			If Type("oEdictLote[" + AllTrim(Str(nX)) + "]:_ListOfEdictItem:_EdictItem") == "U"
				AAdd(aErro , "É obrigatório informar a tag EdictItem no conjunto ListOfEdictItem")
				lRet := .F.
				lRetIt := .F.
			EndIf
			
			If Type("oEdictLote[" + AllTrim(Str(nX)) + "]:_ListOfEdictItem:_EdictItem") != "A"
				XmlNode2Arr( oEdictLote[nX]:_ListOfEdictItem:_EdictItem , "_EdictItem")
			EndIf 			
			
			
			//-------------------------------------------------------------------------
			// Valida os itens  (EdictItem) do conjunto de itens (ListOfEdictItem)
			//-------------------------------------------------------------------------
			
			oEdictItem := oEdictLote[nX]:_ListOfEdictItem:_EdictItem
			For nY := 1 To Len(oEdictItem)		
				If Type("oEdictItem["+ AllTrim(Str(nX)) +"]:_ExternalItemCode") == "U" .Or. Empty(oEdictItem[nX]:_ExternalItemCode:Text)
					AAdd(aErro , "É obrigatório informar a tag ExternalItemCode da EdictItem. Item : " + Alltrim(Str(nX)) )
					lRet := .F.
				EndIf
			Next
			
			//------------------------------------------------------------------------------
			// Valida o conjunto de propostas (ListOfBidderProposal) do lote (EdictLot)
			//------------------------------------------------------------------------------		

			If Type("oEdictLote[" + AllTrim(Str(nX)) + "]:_ListOfBidderProposal") == "U"
				AAdd(aErro , "É obrigatório informar a tag ListOfBidderProposal na tag EdictLot")
				lRet := .F.	
				lRetIt := .F.	
			EndIf

			If Type("oEdictLote[" + AllTrim(Str(nX)) + "]:_ListOfBidderProposal:_BidderProposal") == "U"
				AAdd(aErro , "É obrigatório informar a tag BidderProposal no conjunto ListOfBidderProposal")
				lRet := .F.
				lRetIt := .F.
			EndIf

			If Type("oEdictLote[" + AllTrim(Str(nX)) + "]:_ListOfBidderProposal:_BidderProposal") != "A"
				XmlNode2Arr( oEdictLote[nX]:_ListOfBidderProposal:_BidderProposal , "_BidderProposal")
			EndIf 				

			//----------------------------------------------------------------------------------------
			// Valida as propostas (BidderProposal) do conjunto de propostas (ListOfBidderProposal)
			//----------------------------------------------------------------------------------------
			oEdictBidd := oEdictLote[nX]:_ListOfBidderProposal:_BidderProposal

			For nY := 1 To Len(oEdictBidd)		
				If Type("oEdictBidd["+ AllTrim(Str(nY)) +"]:_ExternalItemCode") == "U" .Or. Empty(oEdictBidd[nY]:_ExternalItemCode:Text)
					AAdd(aErro , "É obrigatório informar a tag ExternalItemCode da BidderProposal. Item : " + Alltrim(Str(nY)) )
					lRet := .F.
				EndIf

				If Type("oEdictBidd["+ AllTrim(Str(nY)) +"]:_BidderInternalId") == "U" .Or. Empty(oEdictBidd[nY]:_BidderInternalId:Text)
					AAdd(aErro , "É obrigatório informar a tag BidderInternalId da BidderProposal. Item : " + Alltrim(Str(nY)) )
					lRet := .F.
				EndIf
				//HOTFIX - Validar tipos de status.
				If Type("oEdictBidd["+ AllTrim(Str(nY)) +"]:_BidderStatus") == "U" .Or. Empty(oEdictBidd[nY]:_BidderStatus:Text)
					AAdd(aErro , "É obrigatório informar a tag BidderStatus da BidderProposal. Item : " + Alltrim(Str(nY)) )
					lRet := .F.
				EndIf
				//HOTFIX - Validar tipos de solicitantes.
				If Type("oEdictBidd[" + AllTrim(Str(nY)) + "]:_BidderType") == "U" .Or. Empty(oEdictBidd[nY]:_BidderType:Text)
					AAdd(aErro , "É obrigatório informar a tag BidderType da BidderProposal. Item : " + Alltrim(Str(nY)) )
					lRet := .F.
				EndIf

				If Type("oEdictBidd[" + AllTrim(Str(nY)) + "]:_UnitPrice") == "U" .Or. Empty(oEdictBidd[nY]:_UnitPrice:Text)
					AAdd(aErro , "É obrigatório informar a tag UnitPrice da BidderProposal. Item : " + Alltrim(Str(nY)) )
					lRet := .F.
				EndIf
				//HOTFIX - Validar tipos de revogação.
				If Type("oEdictBidd[" + AllTrim(Str(nY)) + "]:_Repealed") == "U" .Or. Empty(oEdictBidd[nY]:_Repealed:Text)
					AAdd(aErro , "É obrigatório informar a tag Repealed da BidderProposal. Item : " + Alltrim(Str(nY)) )
					lRet := .F.
				EndIf

				If Type("oEdictBidd[" + AllTrim(Str(nY)) +"]:_DeliveryTime") == "U" .Or. Empty(oEdictBidd[nY]:_DeliveryTime:Text)
					AAdd(aErro , "É obrigatório informar a tag DeliveryTime da BidderProposal. Item : " + Alltrim(Str(nY)) )
					lRet := .F.
				EndIf		
			Next nY		
		Next nX
	EndIf
EndIf

Return lRet

Function I200SeekLi( oModel , aBusca )
Local nX        := 0
Local nRet      := 0

For nX := 1 To oModel:Length()  
	oModel:GoLine(nX)
	If oModel:SeekLine( aBusca )
		nRet := nX
		Exit
	EndIf
Next nX

Return nRet

Function I200GetErr( aErro , oModel)
Local cRet :=  ""
Local aRetorno
DEFAULT aErro := {}

aRetorno := oModel:GetErrorMessage()	
cRet := "Id do formulário de origem:" + ' [' + AllToChar( aRetorno[1] ) + ']' + CRLF
cRet += "Id do campo de origem: " + ' [' + AllToChar( aRetorno[2] ) + ']'  + CRLF
cRet += "Id do formulário de erro: " + ' [' + AllToChar( aRetorno[3] ) + ']'  + CRLF
cRet += "Id do campo de erro: " + ' [' + AllToChar( aRetorno[4] ) + ']'  + CRLF
cRet += "Id do erro: " + ' [' + AllToChar( aRetorno[5] ) + ']'  + CRLF
cRet += "Mensagem do erro: " + ' [' + AllToChar( aRetorno[6] ) + ']'  + CRLF
cRet += "Mensagem da solução: " + ' [' + AllToChar( aRetorno[7] ) + ']'  + CRLF
cRet += "Valor atribuído: " + ' [' + AllToChar( aRetorno[8] ) + ']'  + CRLF
cRet += "Valor anterior: " + ' [' + AllToChar( aRetorno[9] ) + ']'  + CRLF

AAdd(aErro , cRet )

Return cRet