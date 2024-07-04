#Include "Protheus.ch" 
#Include "RwMake.ch"
#Include "TopConn.ch"
#Include "FWAdapterEAI.ch"
#Include "MATI410B.CH"

/*/{Protheus.doc} MATI410A(cXML,nTypeTrans,cTypeMessage,cVersion)
	Rastreabilidade de pedidos de compra e venda

	@param	cXML      		Conteudo xml para envio/recebimento
	@param nTypeTrans		Tipo de transacao. (Envio/Recebimento)
	@param	cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)
	@param	cVersion		Versão em uso

	@retorno aRet			Array contendo o resultado da execucao e a mensagem Xml de retorno.
				aRet[1]	(boolean) Indica o resultado da execução da função
				aRet[2]	(caracter) Mensagem Xml para envio

	@author	Rodrigo Machado Pontes
	@version	P11
	@since	17/03/2013
/*/

Function MATI410B(cXML,nTypeTrans,cTypeMessage,cVersion)

Local aArea		 := GetArea()
Local aPedCom	 := {}
Local aNfEntr	 := {}
Local aPedVen	 := {}
Local aNfSaid	 := {}
Local aRetSale	 := {}
Local cError	 := ""
Local cWarning	 := ""
Local cXMLRet	 := ""
Local cMarca	 := ""
Local cTipoRast	 := ""
Local cValExt	 := ""
Local cValInt	 := ""
Local cNumero	 := ""
Local cForn		 := ""
Local cLoja		 := ""
Local cRetSaleId := ""
Local lRast		 := .T.
Local nI		 := 0

Private oXmlOrder	:= Nil

If ( nTypeTrans == TRANS_SEND )
	
	cXMLRet += '<BusinessRequest>'
	cXMLRet += 	'<Operation>MATI410B</Operation>'
	cXMLRet += '</BusinessRequest>'

	If AllTrim(FunName()) == "MATA120" .Or. AllTrim(FunName()) == "MATA121" //Pedido de Compra
		cXMLRet += '<BusinessContent>'
		cXMLRet += 	'<InternalId>' + cEmpAnt + '|' + xFilial("SC7") + '|' + SC7->C7_NUM + '</InternalId>'
		cXMLRet += 	'<CompanyInternalId>' + cEmpAnt + '|' + xFilial("SC7") + '</CompanyInternalId>'
		cXMLRet += 	'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet += 	'<BranchId>' + xFilial("SC7") + '</BranchId>'
		cXMLRet += 	'<Type>000</Type>'
	Else 

		cTipoRast := "001" //Pedido de Venda
		
		//Busca pedido de venda
		aPedVen := A410BPV(SC5->C5_NUM)
		
		If Len(aPedVen) > 0

			//Pedido gerado pelo Loja (C5_ORCRES), pega orçamento que originou Pedido de Venda
			If ExistFunc("LjxjSaleId") .And. !Empty(aPedVen[1][12])
				cRetSaleId := LjxjSaleId(aPedVen[1][11], aPedVen[1][12])
			EndIf

			aNfSaid := A410BNFS(aPedVen)
			
			cXMLRet := '<BusinessEvent>'
			cXMLRet +=     '<Entity>DOCUMENTTRACEABILITYORDER</Entity>'
			cXMLRet +=     '<Event>upsert</Event>'
			cXMLRet +=     '<Identification>'
			cXMLRet +=         '<key name="Number">' + SC5->C5_NUM + '</key>'
			cXMLRet +=     '</Identification>'
			cXMLRet += '</BusinessEvent>'
		
			cXMLRet += '<BusinessContent>'
		Else
			cXMLRet := "PV não encontrada no Protheus"
			lRast := .F.
		Endif
	
		If lRast
		
			For nI	:= 1 To Len(aPedVen)
				aItens		:= aPedVen[nI,7]
				aRatCC		:= aPedVen[nI,8]
				aRatPrj		:= aPedVen[nI,9]
				cForn		:= Separa(aPedVen[nI,4],"|")[1]
				cLoja		:= Separa(aPedVen[nI,4],"|")[2]
				
				cXMLRet += 	'<InternalId>' + IntPdVExt(,,aPedVen[nI,1])[2] + '</InternalId>'
				cXMLRet += 	'<CompanyInternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '</CompanyInternalId>'
				cXMLRet += 	'<CompanyId>' + AllTrim(cEmpAnt) + '</CompanyId>'
				cXMLRet += 	'<BranchId>' + AllTrim(cFilAnt) + '</BranchId>'
				cXMLRet += 	'<Number>' + AllTrim(aPedVen[nI,1]) + '</Number>'
				cXMLRet += 	'<Status>' + AllTrim(aPedVen[nI,6]) + '</Status>'
				cXMLRet += 	'<TraceabilityCode>' + AllTrim(aPedVen[nI,10]) + '</TraceabilityCode>'
				cXMLRet += 	'<RegisterDate>' + AllTrim(Transform(aPedVen[nI,2],"@R 9999-99-99")) + '</RegisterDate>'
				cXMLRet += 	'<DeliveryDate>' + AllTrim(Transform(aPedVen[nI,3],"@R 9999-99-99")) + '</DeliveryDate>'
				cXMLRet += 	'<CustomerVendorInternalId>' + IntCliExt(,,cForn,cLoja)[2] + '</CustomerVendorInternalId>'
				cXMLRet += 	'<Value>' + cValToChar(aPedVen[nI,5]) + '</Value>'
				cXMLRet += 	'<Type>' + cTipoRast + '</Type>'
				cXMLRet += 	'<RetailSalesInternalId>' + cRetSaleId + '</RetailSalesInternalId>'
				cXMLRet += A410BXMLIT(aItens,aRatCC,aRatPrj,"PV",aPedVen[nI,1])
			Next nI
		
			cXMLRet += '<ReturnTraceability>'
	
			cXMLRet += 	'<ListOfTraceability>'
			  		
    		If Len(aNfSaid) > 0
    			For nI := 1 To Len(aNfSaid)
    				aItens		:= aNfSaid[nI,8]
    				aRatCC		:= aNfSaid[nI,9]
    				aRatPrj		:= aNfSaid[nI,10]
    				cForn		:= Separa(aNfSaid[nI,4],"|")[1]
    				cLoja		:= Separa(aNfSaid[nI,4],"|")[2]
    				
    				cXMLRet += 		'<Invoice>'
	      			cXMLRet += 			'<InternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '|' + AllTrim(aNfSaid[nI,1]) + '|' + AllTrim(aNfSaid[nI,2]) + '|' + AllTrim(cForn) + '|' + AllTrim(cLoja) + '</InternalId>'
	      			cXMLRet += 			'<CompanyInternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '</CompanyInternalId>'
	      			cXMLRet += 			'<CompanyId>' + AllTrim(cEmpAnt) + '</CompanyId>'
	      			cXMLRet += 			'<BranchId>' + AllTrim(cFilAnt) + '</BranchId>'
	      			cXMLRet += 			'<Number>' + AllTrim(aNfSaid[nI,1]) + '</Number>'
	      			cXMLRet += 			'<Serie>' + AllTrim(aNfSaid[nI,2]) + '</Serie>'
	      			cXMLRet += 			'<Status>' + AllTrim(aNfSaid[nI,7]) + '</Status>'
	      			cXMLRet += 			'<IssueDate>' + AllTrim(Transform(aNfSaid[nI,3],"@R 9999-99-99")) + '</IssueDate>'
	      			cXMLRet += 			'<VendorInternalId>' + IntCliExt(,,cForn,cLoja)[2] + '</VendorInternalId>'
	      			cXMLRet += 			'<Value>' + AllTrim(cValToChar(aNfSaid[nI,6])) + '</Value>'
	      			cXMLRet += 			'<TypeOfDocument>' + AllTrim(aNfSaid[nI,5]) + '</TypeOfDocument>'
					cXMLRet += 			'<ElectronicAccessKey>' + AllTrim(aNfSaid[nI,12]) + '</ElectronicAccessKey>'
	      			cXMLRet += 			A410BXMLIT(aItens,aRatCC,aRatPrj,"NFS",aNfSaid[nI,1],aNfSaid[nI,2],cForn,cLoja)
	      			cXMLRet += 			'<ListOfParentInternalId>'
	        		cXMLRet += 				'<ParentInternalId>'
	          		cXMLRet += 					'<InternalId>' + IntPdVExt(,,aNfSaid[nI,11])[2] + '</InternalId>'
	          		cXMLRet += 					'<TypeCode>004</TypeCode>'
	        		cXMLRet += 				'</ParentInternalId>'
	      			cXMLRet += 			'</ListOfParentInternalId>'
	      			cXMLRet += 		'</Invoice>'
	      		Next nI
    		Else
    			cXMLRet += 		'<Invoice/>'
    		Endif
			
			cXMLRet += 	'</ListOfTraceability>'
			cXMLRet +=	'</ReturnTraceability>'
		Endif
	EndIf

	cXMLRet += '</BusinessContent>'


Elseif ( nTypeTrans == TRANS_RECEIVE )

	If	( cTypeMessage == EAI_MESSAGE_WHOIS )

		cXMLRet := '1.000|1.001'

	//-- Recebimento da Business Message
	ElseIf ( cTypeMessage == EAI_MESSAGE_BUSINESS )

		oXmlOrder := XmlParser( cXml, "_", @cError, @cWarning )

		//Valida se houve erro no parser
		If ( oXmlOrder <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) )

			If Type("oXmlOrder:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U"
				cMarca :=  oXmlOrder:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			Endif

			If Type("oXmlOrder:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") <> "U"
				cValExt := oXmlOrder:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
			Endif

			If Type("oXmlOrder:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text") <> "U"
				cTipoRast	:= AllTrim(oXmlOrder:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)
			Endif

			If cTipoRast == "000" //Pedido de Compra
				//Busca valor interno
				cValInt:= CFGA070Int(cMarca,"SC7","C7_NUM",cValExt)
				
				If !Empty(cValInt)
					cNumero	:= AllTrim(Separa(cValInt,"|")[3])
					
					//Busca pedido de compra
					aPedCom := A110BPC(cNumero,3)
					
					If Len(aPedCom) > 0
						aNfEntr := A110BNFE(aPedCom)
					Else
						cXMLRet := "PC não encontrada no Protheus"
						lRast := .F.
					Endif
				Else
					cXMLRet := "PC não encontrada no de/para"
					lRast := .F.
				Endif
				
			Elseif cTipoRast == "001" //Pedido de Venda
				//Busca valor interno
				cValInt:= CFGA070Int(cMarca,"SC5","C5_NUM",cValExt)
				
				If !Empty(cValInt)
					cNumero	:= AllTrim(Separa(cValInt,"|")[3])
					
					//Busca pedido de compra
					aPedVen := A410BPV(cNumero)
					
					If Len(aPedVen) > 0

						//Pedido gerado pelo Loja (C5_ORCRES), pega orçamento que originou Pedido de Venda
						If ExistFunc("LjxjSaleId") .And. !Empty(aPedVen[1][12])
							cRetSaleId := LjxjSaleId(aPedVen[1][11], aPedVen[1][12])
						EndIf	

						aNfSaid := A410BNFS(aPedVen)
					Else
						cXMLRet := "PV não encontrada no Protheus"
						lRast := .F.
					Endif
				Else
					cXMLRet := "PV não encontrada no de/para"
					lRast := .F.
				Endif
			Endif
			
			If lRast
				cXMLRet += '<ReturnTraceability>'
					
				If cTipoRast == "000" //PC
					For nI	:= 1 To Len(aPedCom)
						aItens		:= aPedCom[nI,7]
	    				aRatCC		:= aPedCom[nI,8]
	    				aRatPrj	:= aPedCom[nI,9]
	    				cForn		:= Separa(aPedCom[nI,4],"|")[1]
	    				cLoja		:= Separa(aPedCom[nI,4],"|")[2]
	    				
	    				cXMLRet += 	'<InternalId>' + IntPdCExt(,,aPedCom[nI,1])[2] + '</InternalId>'
						cXMLRet += 	'<CompanyInternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '</CompanyInternalId>'
						cXMLRet += 	'<CompanyId>' + AllTrim(cEmpAnt) + '</CompanyId>'
						cXMLRet += 	'<BranchId>' + AllTrim(cFilAnt) + '</BranchId>'
						cXMLRet += 	'<Number>' + AllTrim(aPedCom[nI,1]) + '</Number>'
						cXMLRet += 	'<Status>' + AllTrim(aPedCom[nI,6]) + '</Status>'
						cXMLRet += 	'<RegisterDate>' + AllTrim(Transform(aPedCom[nI,2],"@R 9999-99-99")) + '</RegisterDate>'
						cXMLRet += 	'<DeliveryDate>' + AllTrim(Transform(aPedCom[nI,3],"@R 9999-99-99")) + '</DeliveryDate>'
						cXMLRet += 	'<CustomerVendorInternalId>' + IntForExt(,,cForn,cLoja)[2] + '</CustomerVendorInternalId>'
						cXMLRet += 	'<Value>' + cValToChar(aPedCom[nI,5]) + '</Value>'
						cXMLRet += 	'<Type>' + cTipoRast + '</Type>'
						cXMLRet += A110BXMLIT(aItens,aRatCC,aRatPrj,"PC",aPedCom[nI,1])
					Next nI
					
				Elseif cTipoRast == "001" //PV
					For nI	:= 1 To Len(aPedVen)
						aItens		:= aPedVen[nI,7]
	    				aRatCC		:= aPedVen[nI,8]
	    				aRatPrj	:= aPedVen[nI,9]
	    				cForn		:= Separa(aPedVen[nI,4],"|")[1]
	    				cLoja		:= Separa(aPedVen[nI,4],"|")[2]
	    				
	    				cXMLRet += 	'<InternalId>' + IntPdVExt(,,aPedVen[nI,1])[2] + '</InternalId>'
						cXMLRet += 	'<CompanyInternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '</CompanyInternalId>'
						cXMLRet += 	'<CompanyId>' + AllTrim(cEmpAnt) + '</CompanyId>'
						cXMLRet += 	'<BranchId>' + AllTrim(cFilAnt) + '</BranchId>'
						cXMLRet += 	'<Number>' + AllTrim(aPedVen[nI,1]) + '</Number>'
						cXMLRet += 	'<Status>' + AllTrim(aPedVen[nI,6]) + '</Status>'
						cXMLRet += 	'<TraceabilityCode>' + AllTrim(aPedVen[nI,10]) + '</TraceabilityCode>'
						cXMLRet += 	'<RegisterDate>' + AllTrim(Transform(aPedVen[nI,2],"@R 9999-99-99")) + '</RegisterDate>'
						cXMLRet += 	'<DeliveryDate>' + AllTrim(Transform(aPedVen[nI,3],"@R 9999-99-99")) + '</DeliveryDate>'
						cXMLRet += 	'<CustomerVendorInternalId>' + IntCliExt(,,cForn,cLoja)[2] + '</CustomerVendorInternalId>'
						cXMLRet += 	'<Value>' + cValToChar(aPedVen[nI,5]) + '</Value>'
						cXMLRet += 	'<Type>' + cTipoRast + '</Type>'
						cXMLRet += 	'<RetailSalesInternalId>' + cRetSaleId + '</RetailSalesInternalId>'
						cXMLRet += A410BXMLIT(aItens,aRatCC,aRatPrj,"PV",aPedVen[nI,1])
					Next nI
				Endif
				
				cXMLRet += 	'<ListOfTraceability>'
				
				If cTipoRast == "000" .And. Len(aNfEntr) > 0
	    			For nI := 1 To Len(aNfEntr)
	    				aItens		:= aNfEntr[nI,8]
	    				aRatCC		:= aNfEntr[nI,9]
	    				aRatPrj	:= aNfEntr[nI,10]
	    				cForn		:= Separa(aNfEntr[nI,4],"|")[1]
	    				cLoja		:= Separa(aNfEntr[nI,4],"|")[2]
	    				
	    				cXMLRet += 		'<Invoice>'
		      			cXMLRet += 			'<InternalId>' + IntInvExt(,,aNfEntr[nI,1],aNfEntr[nI,2],cForn,cLoja)[2] + '</InternalId>'
		      			cXMLRet += 			'<CompanyInternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '</CompanyInternalId>'
		      			cXMLRet += 			'<CompanyId>' + AllTrim(cEmpAnt) + '</CompanyId>'
		      			cXMLRet += 			'<BranchId>' + AllTrim(cFilAnt) + '</BranchId>'
		      			cXMLRet += 			'<Number>' + AllTrim(aNfEntr[nI,1]) + '</Number>'
		      			cXMLRet += 			'<Serie>' + AllTrim(aNfEntr[nI,2]) + '</Serie>'
		      			cXMLRet += 			'<Status>' + AllTrim(aNfEntr[nI,7]) + '</Status>'
		      			cXMLRet += 			'<IssueDate>' + AllTrim(Transform(aNfEntr[nI,3],"@R 9999-99-99")) + '</IssueDate>'
		      			cXMLRet += 			'<VendorInternalId>' + IntForExt(,,cForn,cLoja)[2] + '</VendorInternalId>'
		      			cXMLRet += 			'<Value>' + AllTrim(cValToChar(aNfEntr[nI,6])) + '</Value>'
		      			cXMLRet += 			'<TypeOfDocument>' + AllTrim(aNfEntr[nI,5]) + '</TypeOfDocument>'
						cXMLRet += 			'<ElectronicAccessKey>' + AllTrim(aNfEntr[nI,12]) + '</ElectronicAccessKey>'						  
		      			cXMLRet += A110BXMLIT(aItens,aRatCC,aRatPrj,"NFE",aNfEntr[nI,1],aNfEntr[nI,2],cForn,cLoja)
		      			cXMLRet += 			'<ListOfParentInternalId>'
		        		cXMLRet += 				'<ParentInternalId>'
		          		cXMLRet += 					'<InternalId>' + IntPdCExt(,,aNfEntr[nI,11])[2] + '</InternalId>'
		          		cXMLRet += 					'<TypeCode>000</TypeCode>'
		        		cXMLRet += 				'</ParentInternalId>'
		      			cXMLRet += 			'</ListOfParentInternalId>'
		      			cXMLRet += 		'</Invoice>'
		      		Next nI
	    		Else
	    			cXMLRet += 		'<Invoice/>'
	    		Endif
	    		
	    		If cTipoRast == "001" .And. Len(aNfSaid) > 0
	    			For nI := 1 To Len(aNfSaid)
	    				aItens		:= aNfSaid[nI,8]
	    				aRatCC		:= aNfSaid[nI,9]
	    				aRatPrj	:= aNfSaid[nI,10]
	    				cForn		:= Separa(aNfSaid[nI,4],"|")[1]
	    				cLoja		:= Separa(aNfSaid[nI,4],"|")[2]
	    				
	    				cXMLRet += 		'<Invoice>'
		      			cXMLRet += 			'<InternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '|' + AllTrim(aNfSaid[nI,1]) + '|' + AllTrim(aNfSaid[nI,2]) + '|' + AllTrim(cForn) + '|' + AllTrim(cLoja) + '</InternalId>'
		      			cXMLRet += 			'<CompanyInternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '</CompanyInternalId>'
		      			cXMLRet += 			'<CompanyId>' + AllTrim(cEmpAnt) + '</CompanyId>'
		      			cXMLRet += 			'<BranchId>' + AllTrim(cFilAnt) + '</BranchId>'
		      			cXMLRet += 			'<Number>' + AllTrim(aNfSaid[nI,1]) + '</Number>'
		      			cXMLRet += 			'<Serie>' + AllTrim(aNfSaid[nI,2]) + '</Serie>'
		      			cXMLRet += 			'<Status>' + AllTrim(aNfSaid[nI,7]) + '</Status>'
		      			cXMLRet += 			'<IssueDate>' + AllTrim(Transform(aNfSaid[nI,3],"@R 9999-99-99")) + '</IssueDate>'
		      			cXMLRet += 			'<VendorInternalId>' + IntCliExt(,,cForn,cLoja)[2] + '</VendorInternalId>'
		      			cXMLRet += 			'<Value>' + AllTrim(cValToChar(aNfSaid[nI,6])) + '</Value>'
		      			cXMLRet += 			'<TypeOfDocument>' + AllTrim(aNfSaid[nI,5]) + '</TypeOfDocument>'
						cXMLRet += 			'<ElectronicAccessKey>' + AllTrim(aNfSaid[nI,12]) + '</ElectronicAccessKey>'
		      			cXMLRet += A410BXMLIT(aItens,aRatCC,aRatPrj,"NFS",aNfSaid[nI,1],aNfSaid[nI,2],cForn,cLoja)
		      			cXMLRet += 			'<ListOfParentInternalId>'
		        		cXMLRet += 				'<ParentInternalId>'
		          		cXMLRet += 					'<InternalId>' + IntPdVExt(,,aNfSaid[nI,11])[2] + '</InternalId>'
		          		cXMLRet += 					'<TypeCode>004</TypeCode>'
		        		cXMLRet += 				'</ParentInternalId>'
		      			cXMLRet += 			'</ListOfParentInternalId>'
		      			cXMLRet += 		'</Invoice>'
		      		Next nI
	    		Else
	    			cXMLRet += 		'<Invoice/>'
	    		Endif
				
				cXMLRet += 	'</ListOfTraceability>'
				cXMLRet +=	'</ReturnTraceability>'
			Endif
			
		Endif
	Endif
Endif

RestArea(aArea)

Return {lRast,cXMLRet,"DOCUMENTTRACEABILITYORDER"}

/*/{Protheus.doc} A410BPV()
Busca PV + Itens + Rateio Projeto + Rateio Centro Custo

@param	cNumero	Numero da PC

@author Rodrigo M. Pontes
@since 29/08/2016
@version 11
/*/

Function A410BPV(cNumero)

Local aAreaSC5	:= SC5->(GetArea())
Local aAreaSC6	:= SC6->(GetArea())
Local aAreaAGG	:= AGG->(GetArea())
Local aRet			:= {}
Local aItens		:= {}
Local aRatCC		:= {}
Local aRatPrj		:= {}
Local nI			:= 0
Local nTotal		:= 0
Local cQry			:= ""
Local cSituacao	:= ""
Local cFilialC5	:= xFilial("SC5")
Local cFilialC6	:= xFilial("SC6")
Local cFilialAGG	:= xFilial("AGG")
Local lTabSC5Exc	:= A410BTABEXC("SC5")
Local lTabSC6Exc	:= A410BTABEXC("SC6")
Local lTabAGGExc	:= A410BTABEXC("AGG")

//Cabeçalho
cQry := " SELECT  C5_NUM,"
cQry += 		" C5_EMISSAO,"
cQry += 		" C6_ENTREG,"
cQry += 		" C5_CLIENTE,"
cQry += 		" C5_LOJACLI,"
cQry += 		" C5_RASTR,"
cQry += 		" C5_FILIAL,"
cQry += 		" C5_ORCRES"

cQry += " FROM " + RetSqlName("SC5") + " C5"
cQry += "       JOIN " + RetSqlName("SC6") + " C6 ON C6.D_E_L_E_T_ = ''"
cQry += "           AND C5.C5_NUM = C6.C6_NUM"
cQry += "           AND C6.D_E_L_E_T_ = ''"

If lTabSC6Exc
	cQry += "    AND C6.C6_FILIAL = '" + cFilialC6 + "'"
Endif
	
cQry += " WHERE  C5.D_E_L_E_T_ = ''"
cQry += "        AND C5.C5_NUM = '" + cNumero + "'"

If lTabSC5Exc
	cQry += "    AND C5.C5_FILIAL = '" + cFilialC5 + "'"
Endif

cQry += " GROUP BY C5_NUM,"
cQry += 		 " C5_EMISSAO,"
cQry += 		 " C6_ENTREG,"
cQry += 		 " C5_CLIENTE,"
cQry += 		 " C5_LOJACLI,"
cQry += 		 " C5_RASTR,"
cQry += 		 " C5_FILIAL,"
cQry += 		 " C5_ORCRES"

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"CABEC",.T.,.T.)

DbSelectArea("CABEC")
If CABEC->(!EOF())
	cSituacao := A410BSITUACA("PV",cNumero)
	
	//Itens da NF Saida
	cQry := " SELECT C6_ITEM,"
	cQry += "        C6_PRODUTO,"
	cQry += "        C6_UM,"
	cQry += "        C6_QTDVEN,"
	cQry += "        Round(C6_PRCVEN, "+ AllToChar( TamSx3("C6_PRCVEN")[ 2 ] ) +" ) AS C6_PRCVEN, "
	cQry += "        Round(C6_VALOR , "+ AllToChar( TamSx3("C6_VALOR")[ 2 ] )  +" ) AS C6_VALOR,"
	cQry += "        C6_LOCAL,"
	cQry += "        C6_PROJPMS,"
	cQry += "        C6_TASKPMS"
	cQry += " FROM " + RetSqlName("SC6") + " C6"
	cQry += " WHERE  C6.D_E_L_E_T_ = ''"
	cQry += "        AND C6.C6_NUM = '" + cNumero + "'"
	
	If lTabSC6Exc
		cQry += "    AND C6.C6_FILIAL = '" + cFilialC6 + "'"
	Endif

	cQry := ChangeQuery(cQry)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"ITENS",.T.,.T.)

	DbSelectArea("ITENS")
	While ITENS->(!EOF())
		aAdd(aItens,{ITENS->C6_ITEM,ITENS->C6_PRODUTO,ITENS->C6_UM,ITENS->C6_QTDVEN,ITENS->C6_PRCVEN,ITENS->C6_VALOR,ITENS->C6_LOCAL})
		
		nTotal+=ITENS->C6_VALOR
		
		//Verifica se possui projeto e tarefa
		If !Empty(ITENS->C6_PROJPMS) .And. !Empty(ITENS->C6_TASKPMS)
			aAdd(aRatPrj,{ITENS->C6_PROJPMS,ITENS->C6_TASKPMS,ITENS->C6_QTDVEN,ITENS->C6_PRODUTO,"0001"})
		Endif
		ITENS->(DbSkip())
	Enddo

	ITENS->(DbCloseArea())

	//Rateio Centro de Custo
	cQry := " SELECT AGG_ITEMPD,"
	cQry += "        AGG_CC,"
	cQry += "        Sum(AGG_PERC) AS PERC"
	cQry += " FROM " + RetSqlName("AGG") + " AGG"
	cQry += " WHERE  AGG.D_E_L_E_T_ = ''"
	cQry += "        AND AGG.AGG_PEDIDO = '" + cNumero + "'"
	
	If lTabAGGExc
		cQry += "    AND AGG.AGG_FILIAL = '" + cFilialAGG + "'"
	Endif
	
	cQry += " GROUP  BY AGG.AGG_ITEMPD,"
	cQry += "           AGG.AGG_CC"

	cQry := ChangeQuery(cQry)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"RATCC",.T.,.T.)

	DbSelectArea("RATCC")
	While RATCC->(!EOF())
		aAdd(aRatCC,{RATCC->AGG_CC,RATCC->PERC,RATCC->AGG_ITEMPD})
		RATCC->(DbSkip())
	Enddo

	RATCC->(DbCloseArea())

	aAdd(aRet, {cNumero,;
				CABEC->C5_EMISSAO,;
				CABEC->C6_ENTREG,;
				CABEC->C5_CLIENTE+"|"+CABEC->C5_LOJACLI,;
				nTotal,;
				cSituacao,;
				aItens,;
				aRatCC,;
				aRatPrj,;
				CABEC->C5_RASTR,;
				CABEC->C5_FILIAL,;				
				CABEC->C5_ORCRES } )

	aItens	:= {}
	aRatCC	:= {}
	aRatPrj	:= {}
Endif

CABEC->(DbCloseArea())

RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aAreaAGG)

Return aRet

/*/{Protheus.doc} A110BNFS(aPVs)
Busca NFs + Itens + Rateio Projeto + Rateio Centro Custo

@param	cNumero	Numero da SA

@author Rodrigo M. Pontes
@since 29/08/2016
@version 11
/*/

Function A410BNFS(aPVs)

Local aAreaSF2	:= SF2->(GetArea())
Local aAreaSD2	:= SD2->(GetArea())
Local aAreaAGH	:= AGH->(GetArea())
Local aAreaAFS	:= AFS->(GetArea())
Local aRet			:= {}
Local aItens		:= {}
Local aRatCC		:= {}
Local aRatPrj		:= {}
Local aPVInfo		:= {}
Local nI			:= 0
Local cQry			:= ""
Local cSituacao	:= ""
Local cFilialF2	:= xFilial("SF2")
Local cFilialD2	:= xFilial("SD2")
Local cFilialAGH	:= xFilial("AGH")
Local cFilialAFS	:= xFilial("AFS")
Local lTabSF2Exc	:= A410BTABEXC("SF2")
Local lTabSD2Exc	:= A410BTABEXC("SD2")
Local lTabAGHExc	:= A410BTABEXC("AGH")
Local lTabAFSExc	:= A410BTABEXC("AFS")
Local lExistFornec  := SD2->(ColumnPos("D2_FORNECE")) > 0 .AND. AGH->(ColumnPos("AGH_FORNEC")) > 0 

For nI := 1 To Len(aPVs)
	aAdd(aPVInfo,aPVs[nI,1])
Next nI

For nI := 1 To Len(aPVInfo)
	//Cabeçalho da NF Saida
	cQry := " SELECT F2_DOC,"
	cQry += "        F2_SERIE,"
	cQry += "        F2_EMISSAO,"
	cQry += "        F2_CLIENTE,"
	cQry += "        F2_LOJA,"
	cQry += "        F2_TIPO,"
	cQry += "        Round(F2_VALBRUT, "+ AllToChar( TamSx3("F2_VALBRUT")[ 2 ] ) +" ) AS F2_VALBRUT,"
	cQry += "        F2_CHVNFE"	
	cQry += " FROM " + RetSqlName("SF2" ) + " F2"
	cQry += "      JOIN " + RetSqlName("SD2") + " D2 ON D2.D_E_L_E_T_ = ''
	cQry += "           AND F2.F2_DOC = D2.D2_DOC"
	cQry += "           AND F2.F2_SERIE = D2.D2_SERIE"
	cQry += "           AND F2.F2_CLIENTE = D2.D2_CLIENTE"
	cQry += "           AND F2.F2_LOJA = D2.D2_LOJA"
	cQry += "           AND D2.D2_PEDIDO = '" + aPVInfo[nI] + "'"
	
	If lTabSD2Exc
		cQry += "    AND D2.D2_FILIAL = '" + cFilialD2 + "'"
	Endif
	
	cQry += " WHERE  F2.D_E_L_E_T_ = ''"
	
	If lTabSF2Exc
		cQry += "    AND F2.F2_FILIAL = '" + cFilialF2 + "'"
	Endif
	
	cQry += " GROUP  BY F2.F2_DOC,"
	cQry += "           F2.F2_SERIE,"
	cQry += "           F2.F2_EMISSAO,"
	cQry += "           F2.F2_CLIENTE,"
	cQry += "           F2.F2_LOJA,"
	cQry += "           F2.F2_TIPO,"
	cQry += "           F2.F2_VALBRUT,"
	cQry += "           F2.F2_CHVNFE"
	
	cQry := ChangeQuery(cQry)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"CABEC",.T.,.T.)
	
	DbSelectArea("CABEC")
	While CABEC->(!EOF())
		cSituacao := A410BSITUACA("NFS",CABEC->F2_DOC,CABEC->F2_SERIE,CABEC->F2_CLIENTE,CABEC->F2_LOJA)
		
		//Itens da NF Saida
		cQry := " SELECT D2_ITEM,"
		cQry += "        D2_COD,"
		cQry += "        D2_UM,"
		cQry += "        D2_QUANT,"
		cQry += "        D2_PRCVEN,"
		cQry += "        D2_TOTAL,"
		cQry += "        D2_LOCAL"
		cQry += " FROM " + RetSqlName("SD2") + " D2"
		cQry += " WHERE  D2.D_E_L_E_T_ = ''"
		cQry += "        AND D2.D2_DOC = '" + CABEC->F2_DOC + "'"
		cQry += "        AND D2.D2_SERIE = '" + CABEC->F2_SERIE + "'"
		If lExistFornec
			cQry += "        AND D2.D2_FORNECE = '" + CABEC->F2_FORNECE + "'"
		EndIf			
		cQry += "        AND D2.D2_LOJA = '" + CABEC->F2_LOJA + "'"
		
		If lTabSD2Exc
			cQry += "    AND D2.D2_FILIAL = '" + cFilialD2 + "'"
		Endif
		
		cQry := ChangeQuery(cQry)
		IIf( Select( "ITENS" ) > 0, ITENS->( dbCloseArea() ), Nil  )
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"ITENS",.T.,.T.)
	
		DbSelectArea("ITENS")
		While ITENS->(!EOF())
			aAdd(aItens,{ITENS->D2_ITEM,ITENS->D2_COD,ITENS->D2_UM,ITENS->D2_QUANT,ITENS->D2_PRCVEN,ITENS->D2_TOTAL,ITENS->D2_LOCAL})
			ITENS->(DbSkip())
		Enddo
	
		ITENS->(DbCloseArea())
	
		//Rateio Centro de Custo
		cQry := " SELECT AGH_ITEMPD,"
		cQry += "        AGH_CC,"
		cQry += "        Sum(AGH_PERC) AS PERC"
		cQry += " FROM " + RetSqlName("AGH") + " AGH"
		cQry += " WHERE  AGH.D_E_L_E_T_ = ''"
		cQry += "        AND AGH.AGH_NUM = '" + CABEC->F2_DOC + "'"
		cQry += "        AND AGH.AGH_SERIE = '" + CABEC->F2_SERIE + "'"
		If lExistFornec
			cQry += "        AND AGH.AGH_FORNEC = '" + CABEC->F2_FORNECE + "'"
		EndIf	
		cQry += "        AND AGH.AGH_LOJA = '" + CABEC->F2_LOJA + "'"
		
		If lTabAGHExc
			cQry += "    AND AGH.AGH_FILIAL = '" + cFilialAGH + "'"
		Endif
		
		cQry += " GROUP  BY AGH.AGH_ITEMPD,"
		cQry += "           AGH.AGH_CC"
	
		cQry := ChangeQuery(cQry)
		IIf( Select( "RATCC" ) > 0, RATCC->( dbCloseArea() ), Nil  )	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"RATCC",.T.,.T.)
	
		DbSelectArea("RATCC")
		While RATCC->(!EOF())
			aAdd(aRatCC,{RATCC->AGH_CC,RATCC->PERC,RATCC->AGH_ITEMPD})
			RATCC->(DbSkip())
		Enddo
	
		RATCC->(DbCloseArea())
	
		//Rateio Projeto
		cQry := " SELECT AFS_COD," 
		cQry += "        AFS_PROJET,"
		cQry += "        AFS_TAREFA,"
		cQry += "        AFS_QUANT,"
		cQry += "        AFS_REVISA"
		cQry += " FROM " + RetSqlName("AFS") + " AFS"
		cQry += " WHERE  AFS.D_E_L_E_T_ = ''"
		cQry += "        AND AFS.AFS_DOC = '" + CABEC->F2_DOC + "'"
		cQry += "        AND AFS.AFS_SERIE = '" + CABEC->F2_SERIE + "'"
		
		If lTabAFSExc
			cQry += "    AND AFS.AFS_FILIAL = '" + cFilialAFS + "'"
		Endif
		
		cQry += " GROUP BY AFS_COD,"
		cQry += "        AFS_PROJET,"
		cQry += "        AFS_TAREFA,"
		cQry += "        AFS_QUANT,"
		cQry += "        AFS_REVISA"
	
		cQry := ChangeQuery(cQry)
		IIf( Select( "RATPRJ" ) > 0, RATPRJ->( dbCloseArea() ), Nil  )	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"RATPRJ",.T.,.T.)
	
		DbSelectArea("RATPRJ")
		While RATPRJ->(!EOF())
			aAdd(aRatPrj,{RATPRJ->AFS_PROJET,RATPRJ->AFS_TAREFA,RATPRJ->AFS_QUANT,RATPRJ->AFS_COD,RATPRJ->AFS_REVISA})
			RATPRJ->(DbSkip())
		Enddo
	
		RATPRJ->(DbCloseArea())
	
		aAdd(aRet, {CABEC->F2_DOC,;
					CABEC->F2_SERIE,;
					CABEC->F2_EMISSAO,;
					CABEC->F2_CLIENTE+"|"+CABEC->F2_LOJA,;
					CABEC->F2_TIPO,;
					CABEC->F2_VALBRUT,;
					cSituacao,;
					aItens,;
					aRatCC,;
					aRatPrj,;
					aPVInfo[nI],;
					CABEC->F2_CHVNFE})
	
		aItens		:= {}
		aRatCC		:= {}
		aRatPrj	:= {}

		CABEC->( dbSkip() )
	EndDo
	
	CABEC->(DbCloseArea())
Next nI

RestArea(aAreaSF2)
RestArea(aAreaSD2)
RestArea(aAreaAGH)
RestArea(aAreaAFS)

Return aRet

/*/{Protheus.doc} A410BTABEXC(cTab)
	Dados do pedido de compra ou venda

	@param	cTab		Alias da tabela

	@retorno lRet		.T. - Se for exclusiva, .F. - compartilhado

	@author	Rodrigo Machado Pontes
	@version	P11
	@since	19/03/2013
/*/

Static Function A410BTABEXC(cTab)
	Local lRet	:= .F.

 	lRet := ( (FWModeAccess(cTab,1) == 'E') .Or. (FWModeAccess(cTab,2) == 'E') .Or. (FWModeAccess(cTab,3) == 'E') ) 

Return lRet

/*/{Protheus.doc} A410BXMLIT(aItens,aRatCC,aRatPrj,cFilRast)
	Dados da solicitação de armazem (ou baixa) ou compra

	@param	aItens		Itens a serem informados
	@param aRatCC   	Rateio por centro de custo a ser informado
	@param	aRatPrj   	Rateio por projeto a ser informado
	@param	cFilRast  	Filial para rastrear

	@retorno cRet		XML formatado

	@author	Rodrigo Machado Pontes
	@version	P11
	@since	24/03/2013
/*/

Function A410BXMLIT(aItens,aRatCC,aRatPrj,cTipo,cNum,cSer,cCli,cLoj)

Local cRet		:= ""
Local nK		:= 0
Local nY		:= 0

If Len(aItens) > 0
	cRet += 	'<ListOfItem>'
	For nK	:= 1 To Len(aItens)
    	cRet += 		'<Item>'
    	
    	If cTipo == "PV"
    		cRet += 			'<InternalId>' + IntPdVExt(,,cNum,aItens[nK,1])[2] + '</InternalId>'
    	Elseif cTipo == "NFS"
    		cRet += 			'<InternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '|' + AllTrim(cNum) + '|' + AllTrim(cSer) + '|' + AllTrim(cCli) + '|' + AllTrim(cLoj) + '|' + AllTrim(aItens[nK,1]) + '</InternalId>'
    	Endif
    	
    	cRet += 			'<Number>' + AllTrim(aItens[nK,1]) + '</Number>'
    	cRet += 			'<ItemInternalId>' + IntProExt(,,aItens[nK,2])[2] + '</ItemInternalId>'
    	cRet += 			'<UnitofMeasureInternalId>' + IntUndExt(,,aItens[nK,3])[2] + '</UnitofMeasureInternalId>'
    	cRet += 			'<Quantity>' + AllTrim(cValToChar(aItens[nK,4])) + '</Quantity>'
    	cRet += 			'<UnitPrice>' + AllTrim(cValToChar(aItens[nK,5])) + '</UnitPrice>'
    	cRet += 			'<TotalPrice>' + AllTrim(cValToChar(aItens[nK,6])) + '</TotalPrice>'
    	cRet += 			'<WarehouseInternalId>' + IntLocExt(,,aItens[nK,7])[2] + '</WarehouseInternalId>'
    	
    	If Len(aRatCC) > 0
    		cRet += 			'<ListOfApportionCost>'
    		For nY := 1 to Len(aRatCC)
    			If AllTrim(aItens[nK,1]) == AllTrim(aRatCC[nY,3])
    				cRet += 			'<ApportionCost>'
    				
    				If cTipo == "PV"
			    		cRet += 			'<InternalId>' + IntPdVExt(,,cNum,aRatCC[nY,3])[2] + '</InternalId>'
			    	Elseif cTipo == "NFS"
			    		cRet += 			'<InternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '|' + AllTrim(cNum) + '|' + AllTrim(cSer) + '|' + AllTrim(cCli) + '|' + AllTrim(cLoj) + '|' + AllTrim(aRatCC[nY,3]) + '</InternalId>'
			    	Endif
      				cRet += 				'<CostCenterInternalId>' + IntCusExt(,,aRatCC[nY,1])[2] + '</CostCenterInternalId>'
      				cRet += 				'<Percentual>' + AllTrim(cValToChar(aRatCC[nY,2])) + '</Percentual>'
      				cRet += 			'</ApportionCost>'
      			Endif
      		Next nY
      		cRet += 			'</ListOfApportionCost>'
      	Else
      		cRet += 			'<ListOfApportionCost/>'
      	Endif
      	
      	If Len(aRatPrj) > 0
      		cRet += 			'<ListOfApportionTask>'
      		For nY := 1 to Len(aRatPrj)
      			If AllTrim(aItens[nK,2]) == AllTrim(aRatPrj[nY,4])
      				cRet += 			'<ApportionTask>'
      				cRet += 				'<InternalId>' + IntProExt(,,aRatPrj[nY,4])[2] + '</InternalId>'
      				cRet += 				'<ProjectInternalId>' + IntPrjExt(,,aRatPrj[nY,1])[2] + '</ProjectInternalId>'
      				cRet += 				'<SubProjectInternalId></SubProjectInternalId>'
      				cRet += 				'<TaskInternalId>' + IntTrfExt(,,aRatPrj[nY,1],aRatPrj[nY,5],aRatPrj[nY,2])[2] + '</TaskInternalId>'
      				cRet += 				'<Quantity>' + AllTrim(cValToChar(aRatPrj[nY,3])) + '</Quantity>'
      				cRet += 			'</ApportionTask>'
      			Endif
      		Next nY
      		cRet += 			'</ListOfApportionTask>'
   		Else
   			cRet += 			'<ListOfApportionTask/>'
   		Endif
		cRet += 		'</Item>'
    Next nK
  	cRet += 	'</ListOfItem>'
Else
	cRet += 	'<ListOfItem/>'
Endif

Return cRet

/*/{Protheus.doc} A410BSITUACA()
Busca situação da PV/NFS

@param	cTipo		Tipo do documento
@param	cNumero	Numero da PV/NFS 

@author Rodrigo M. Pontes
@since 29/08/2016
@version 11
/*/

Static Function A410BSITUACA(cTipo,cNumero,cSerie,cCliente,cLoja)

Local cSituacao			:= ""
Local lExistFornec  	:= SF2->(ColumnPos("F2_FORNECE")) > 0 
Local lA410BSITU        := ExistBlock("A410BSIT")
Local cAuxSitua         := ""

If cTipo == "PV" //Pedido Venda

	cQry := " SELECT C5_LIBEROK,"
	cQry += "        C5_NOTA,"
	cQry += "        C5_BLQ,"
	cQry += "        C5_STATUS,"
	cQry += "        C5_ORCRES"
	cQry += " FROM " + RetSqlName("SC5") + " C5"
	cQry += " WHERE  C5.D_E_L_E_T_ = ' '"
	cQry += "        AND C5.C5_NUM = '" + cNumero + "'"
	
	If A410BTABEXC("SC5")
		cQry += "    AND C5.C5_FILIAL = '" + xFilial("SC5") + "'"
	Endif
	
	cQry += " GROUP BY C5.C5_LIBEROK,"
	cQry += 		 " C5.C5_NOTA,"
	cQry += 		 " C5.C5_BLQ," 
	cQry += 		 " C5.C5_STATUS,"
	cQry += 		 " C5.C5_ORCRES"
	
	cQry := ChangeQuery(cQry)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SIT",.T.,.T.)
	
	DbSelectArea("SIT")
	If SIT->(!EOF())
		If Empty(SIT->C5_LIBEROK) .And. Empty(SIT->C5_NOTA) .And. Empty(SIT->C5_BLQ)
			cSituacao := STR0002 //"Pedido em aberto"
		Elseif !Empty(SIT->C5_NOTA) .Or. SIT->C5_LIBEROK == "E" .And. Empty(SIT->C5_BLQ)
			cSituacao := STR0003 //"Pedido encerrado"
		Elseif !Empty(SIT->C5_LIBEROK) .And. Empty(SIT->C5_NOTA) .And. Empty(SIT->C5_BLQ)
			cSituacao := STR0004 //"Pedido liberado"
		Elseif SIT->C5_BLQ == "1"
			cSituacao := STR0005 //"Pedido bloqueado por regra"
		Elseif SIT->C5_BLQ == "2"
			cSituacao := STR0006 //"Pedido bloqueado por verba"
		Endif
		//Caso seja um pedido do Loja pega o status do campo C5_STATUS
		If ExistFunc("LjxjStaPed") .And. !Empty(SIT->C5_ORCRES) .And. !Empty(SIT->C5_STATUS)
			cSituacao := LjxjStaPed(SIT->C5_STATUS)
		EndIf
	Endif
	SIT->(DbCloseArea())

ElseIf cTipo == "NFS" //Nota fiscal saida
	cQry := " SELECT F2_CHVNFE"
	cQry += " FROM " + RetSqlName("SF2") + " F2"
	cQry += " WHERE  F2.D_E_L_E_T_ = ' '"
	cQry += "        AND F2.F2_DOC = '" + cNumero + "'"
	cQry += "        AND F2.F2_SERIE = '" + cSerie + "'"
	If lExistFornec
		cQry += "        AND F2.F2_FORNECE = '" + cCliente + "'"
	Else	
		cQry += "        AND F2.F2_CLIENT = '" + cCliente + "'"
	EndIf
	cQry += "        AND F2.F2_LOJA = '" + cLoja + "'"
	
	If A410BTABEXC("SF2")
		cQry += "    AND F2.F2_FILIAL = '" + xFilial("SF2") + "'"
	Endif
	
	cQry := ChangeQuery(cQry)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SIT",.T.,.T.)
	
	DbSelectArea("SIT")
	If SIT->(!EOF())
		If Empty(SIT->F2_CHVNFE)
			cSituacao := STR0007 //"Não Transmitida"
		Elseif !Empty(SIT->F2_CHVNFE)
			cSituacao := STR0008 //"Transmitida"
		Endif
	Endif
	SIT->(DbCloseArea())
Endif

If lA410BSITU
	cAuxSitua := ExecBlock("A410BSIT",.F.,.F.,{cFilant,cNumero,cSituacao})
	If Valtype (cAuxSitua)	== "C" .and. !Empty(cAuxSitua) 
		cSituacao := cAuxSitua
	Endif
EndIf

Return cSituacao

/*/{Protheus.doc} A410BRETAIL(cNumOrc)
Busca Venda Varejo que gerou o Pedido de Venda

@param	cNumPed	Numero do Orcamento Varejo

@author alessandrosantos@totvs.com.br
@since 21/03/2018
@version 12
/*/

Function A410BRETAIL(cNumOrc, cFilorc)

Local cWhere 	:= ""
Local cAliasTmp := GetNextAlias() //Alias temporario
Local aRet   	:= {"","","",""}
Local aArea		:= GetArea()
Local aAreaSL1	:= SL1->(GetArea())

Default cNumOrc:= ""
Default cFilorc:= "" 

LjGrvLog("A410BRETAIL" , "Chamada QUERY")

//Busca informações do cumpom pai
//Condicional para a query		
cWhere := "%"
cWhere += " L1_FILIAL = '"  + cFilorc + "'"
cWhere += " AND L1_NUM = '" + cNumOrc + "'"
cWhere += " AND D_E_L_E_T_ = ''"
cWhere += "%"

//Executa a query
BeginSql alias cAliasTmp
	SELECT
	L1_FILRES, L1_ORCRES
	FROM %table:SL1%
	WHERE %exp:cWhere%
EndSql
		
(cAliasTmp)->(dbGoTop())
		
//Busca informacoes da Venda Varejo
If (cAliasTmp)->(!EOF())

	LjGrvLog("A410BRETAIL" , "L1_FILRES:= " + (cAliasTmp)->L1_FILRES )
	LjGrvLog("A410BRETAIL" , "L1_ORCRES:= " + (cAliasTmp)->L1_ORCRES )
	
	SL1->(dbSetOrder(1)) //L1_FILIAL+L1_NUM
	If SL1->(dbSeek((cAliasTmp)->L1_FILRES + (cAliasTmp)->L1_ORCRES))
		aRet[1] := SL1->L1_FILIAL
		aRet[2] := SL1->L1_SERPED
		aRet[3] := SL1->L1_DOCPED
		
		LjGrvLog("A410BRETAIL" , "aRet[1]:= " + SL1->L1_FILIAL )
		LjGrvLog("A410BRETAIL" , "aRet[2]:= " + SL1->L1_SERPED )
		LjGrvLog("A410BRETAIL" , "aRet[3]:= " + SL1->L1_DOCPED )
		                                			
		//Busca informacoes do pdv, pois ao criar o orçamento filho
		//o número do pdv é apagado no orçamento pai.
		DbSelectArea("SL1")
		SL1->(DbSetOrder(1))
		If(SL1->(DbSeek(xFilial("SC5")+cNumOrc)))
			aRet[4] := SL1->L1_PDV
			LjGrvLog("A410BRETAIL" , "cNumOrc:= " + cNumOrc )
			LjGrvLog("A410BRETAIL" , "aRet[4]:= " + SL1->L1_PDV )
		Endif
	Endif		
EndIf

If Select(cAliasTmp) > 0
	(cAliasTmp)->(dbCloseArea())
EndIf


RestArea(aAreaSL1)
RestArea(aArea)
	
Return aRet
