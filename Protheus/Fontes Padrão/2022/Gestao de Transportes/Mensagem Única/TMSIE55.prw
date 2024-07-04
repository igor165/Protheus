#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWADAPTEREAI.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ TMSIE55     º Autor ³ Leandro Paulino    º Data ³ 09/12/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Funcao de integracao com o adapter EAI para recebimento de   º±±
±±º          ³ e envio de dados do EDI - Notas Fiscais (DE5)                º±±
±±º          ³ utilizando o conceito de mensagem unica.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Param.   ³ cXML - Variavel com conteudo xml para envio/recebimento.     º±±
±±º          ³ nTypeTrans - Tipo de transacao. (Envio/Recebimento)          º±±
±±º          ³ cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno  ³ aRet - Array contendo o resultado da execucao e a mensagem   º±±
±±º          ³        Xml de retorno.                                       º±±
±±º          ³ aRet[1] - (boolean) Indica o resultado da execução da função º±±
±±º          ³ aRet[2] - (caracter) Mensagem Xml para envio                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ TMSAE55                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Function TMSIE55( cXML, nTypeTrans, cTypeMessage )

Local lRet     		:= .T.
Local cXMLRet  		:= ""
Local cError		:= ""
Local cWarning 		:= ""
Local cEvent    	:= "upsert"
Local cLogErro 		:= ""
Local cDoc			:= ""
Local cSerie		:= ""
Local cCGCRem		:= "" 
Local cMarca		:= ""
Local cCodPro		:= ""
Local nCount    	:= 0
Local nOpcx			:= 0
Local aCab			:= {}
Local aItens		:= {}
Local aErroAuto		:= {}
Local aAreaDE5	  	:= DE5->( GetArea() )

Private oXmlAE55	 	:= Nil
Private nCountAE55	  	:= 0
Private lMsErroAuto   	:= .F.
Private lAutoErrNoFile	:= .T.

If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		oXmlAE55 := XmlParser(cXml, "_", @cError, @cWarning)
		
		If oXmlAE55 <> Nil .And. Empty(cError) .And. Empty(cWarning)
			oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SenderCode:Text		:= PADR(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SenderCode:Text    ,TamSX3("DE5_CGCREM")[1])
			oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text := PADR(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text,TamSX3("DE5_DOC")[1]   )
			oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentSeries:Text := PADR(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentSeries:Text,TAMSX3("DE5_SERIE")[1] )
		
			DE5->( dbSetOrder( 1 ) ) 
			If Upper(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
				If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SenderCode:Text" 	) 	 	<> "U" .And. ;
				   Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text"	) 	<> "U" .And. ;
				   Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentSeries:Text"	) 	<> "U"      									
						
					If DE5->( MsSeek( xFilial('DE5')+;
						oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SenderCode:Text +;
		                    	oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text +;
			                    		oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentSeries:Text))
						nOpcx:= 4
						
					Else
						nOpcx:= 3                     
					
					EndIf
				Else
					nOpcx:= 3
				EndIf
			ElseIf Upper(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
				nOpcx := 5
			EndIf
			
			If Type("oXmlAE55:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U"
				cMarca := oXmlAE55:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			EndIf 					
			If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SenderCode:Text") <> "U"
				Aadd( aCab, { "DE5_CGCREM", oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SenderCode:Text, Nil })
			EndIf					
			If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BoardingDate:Text") <> "U"
				Aadd( aCab, { "DE5_DTAEMB", STOD(StrTran(Substr(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BoardingDate:Text,1,10),"-","")), Nil })
			EndIf										
			If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AddresseeCode:Text") <> "U"
				Aadd( aCab, { "DE5_CGCDES", oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AddresseeCode:Text, Nil })
			EndIf
			If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text") <> "U"
				Aadd( aCab, { "DE5_DOC"		, oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text, Nil })
			EndIf
			If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentSeries:Text") <> "U"
				Aadd( aCab, { "DE5_SERIE"	, oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentSeries:Text, Nil })
			EndIf
			If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceIssueDate:Text") <> "U"
				Aadd( aCab, { "DE5_EMINFC"	, STOD(StrTran(Substr(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceIssueDate:Text,1,10),"-","")), Nil })
			EndIf				
			If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperationFiscalCode:Text") <> "U"
				Aadd( aCab, { "DE5_CFOPNF"	, oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperationFiscalCode:Text, Nil })
			EndIf
			If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SEFAZNFeKey:Text") <> "U"
				Aadd( aCab, { "DE5_NFEID"	, oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SEFAZNFeKey:Text, Nil })
			EndIf
			If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text") <> "U"
				Aadd( aCab, { "DE5_TIPFRE"	, oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text, Nil })
			EndIf
			If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TransportationType:Text")  <> "U" .And.;
			   Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TransportationModal:Text") <> "U"
				If oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TransportationModal:Text == '1'
					Aadd( aCab, { "DE5_TIPTRA"	, oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TransportationType:Text, Nil })
				Else
					Aadd( aCab, { "DE5_TIPTRA"	, "4" , Nil })
				EndIf                                            
			EndIf      
			If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item")  <> "U"  
			
			  	If ValType(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item) <> "A"
  	        	 XmlNode2Arr(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item, "_Item")
     	   	EndIf 
     	   	
     	      For nCount := 1 To Len(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item )			  
					Aadd(aItens, {})
					
					If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item["+Str(nCount)+"]:_ItemCode:Text") <> "U"
						cCodPro := CFGA070INT( cMarca ,  "SB1" ,"B1_COD", oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item[nCount]:_ItemCode:Text )
						Aadd( aItens[nCount], { "DE5_CODPRO"	, PadR(cCodPro,TamSX3("DE5_CODPRO")[1]) , Nil })
					EndIf 			
					If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item["+Str(nCount)+"]:_PackageCode:Text") <> "U"
						Aadd( aItens[nCount], { "DE5_CODEMB"	, oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item[nCount]:_PackageCode:Text, Nil })
					EndIf 		
					If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item["+Str(nCount)+"]:_VolumeQuantity:Text") <> "U"
						Aadd( aItens[nCount], { "DE5_QTDVOL"	, Val(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item[nCount]:_VolumeQuantity:Text), Nil })
					EndIf   		
					If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item["+Str(nCount)+"]:_Value:Text") <> "U"
						Aadd( aItens[nCount], { "DE5_VALOR"	, Val(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item[nCount]:_Value:Text), Nil })
					EndIf  			
					If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item["+Str(nCount)+"]:_Weight:Text") <> "U"
						Aadd( aItens[nCount], { "DE5_PESO"	, Val(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item[nCount]:_Weight:Text), Nil })
					EndIf 			
					//Peso cubado 
					If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item["+Str(nCount)+"]:_CubicWeight:Text") <> "U"
						Aadd( aItens[nCount], { "DE5_PESOM3"	, Val(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item[nCount]:_CubicWeight:Text), Nil })
					EndIf  			
					//Metro cubico
					If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item["+Str(nCount)+"]:_CubicMeters:Text") <> "U"
						Aadd( aItens[nCount], { "DE5_METRO3"	, Val(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item[nCount]:_CubicMeters:Text), Nil })
					EndIf			
					If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item["+Str(nCount)+"]:_CalculationBasisICMS:Text") <> "U"
						Aadd( aItens[nCount], { "DE5_BASEIC"	, Val(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item[nCount]:_CalculationBasisICMS:Text), Nil })
					EndIf 		
					If Type("oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item["+Str(nCount)+"]:_ICMSValue:Text") <> "U"
						Aadd( aItens[nCount], { "DE5_VALICM"	, Val(oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfItems:_Item[nCount]:_ICMSValue:Text), Nil })
					EndIf  
				
		  		Next nCount      	   	
     	   
     	   EndIf		

			If nOpcx == 5 .And. !DE5->( DbSeek( xFilial('DE5')+;
											oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SenderCode:Text +;
							                    	oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text+;
								                    		oXmlAE55:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentSeries:Text))

				lMsErroAuto := .F.
			Else
				MSExecAuto({|x,y,z| TMSAE55(x,y,z)},aCab,nOpcx,aItens)																		
			EndIf	
							
			If lMsErroAuto
				aErroAuto := GetAutoGRLog()
				For nCount := 1 To Len(aErroAuto)
					cLogErro += StrTran(StrTran(aErroAuto[nCount],"<",""),"-","") + (" ") 
					TMSLogMsg("ERROR", aErroAuto[nCount] )
				Next nCount
				// Monta XML de Erro de execução da rotina automatica.
				lRet := .F.
				cXMLRet := EncodeUTF8( cLogErro )
			Else
				// Monta xml com status do processamento da rotina autmotica OK.
				cXMLRet := "<OrderId>"+DE5->DE5_CGCREM+DE5->DE5_DOC+DE5->DE5_SERIE+"</OrderId>"
			EndIf
			
		Else
			// "Falha ao gerar o objeto XML"
			lRet := .F.
			cXMLRet := "Falha ao manipular o XML"
		EndIf

	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		cXMLRet := '<TAGX>TESTE DE RECEPCAO RESPONSE MESSAGE</TAGX>'
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := ' <Version>1.0 </Version>'
	EndIf
	
ElseIf nTypeTrans == TRANS_SEND

	If !Inclui .And. !Altera
		cEvent := 'delete'		
	EndIf

	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>EDIDOCUMENTFORTRANSPORTATION</Entity>'
	cXMLRet +=     '<Event>' + cEvent + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="SenderCode">'  		+ 	DE5->DE5_CGCREM 	+ '</key>'
	cXMLRet +=         '<key name="AddresseeCode">' 	+ 	DE5->DE5_CGCDES	+ '</key>'
	cXMLRet +=         '<key name="DocumentNumber">' 	+  DE5->DE5_DOC 		+ '</key>'
	cXMLRet +=         '<key name="DocumentSeries">' 	+ 	DE5->DE5_SERIE  	+ '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'
	
	cXMLRet += '<BusinessContent>'
	cXMLRet +=	  '<SenderCode>'  			+ AllTrim(cCGCRem := DE5->DE5_CGCREM)					+ '</SenderCode>'
	cXMLRet +=	  '<BoardingDate>' 			+ FWTimeStamp( 3, DE5->DE5_DTAEMB, "00:00:00"  ) 	+ '</BoardingDate>'
	cXMLRet +=	  '<AddresseeCode>'  		+ AllTrim(DE5->DE5_CGCDES)								+ '</AddresseeCode>'
	cXMLRet +=    '<DocumentNumber>'			+ AllTrim(cDoc 	:= DE5->DE5_DOC)						+ '</DocumentNumber>'
	cXMLRet +=    '<DocumentSeries>' 		+ AllTrim(cSerie 	:= DE5->DE5_SERIE)					+ '</DocumentSeries>'
	cXMLRet +=    '<InvoiceIssueDate>' 		+ FWTimeStamp( 3, M->DE5_EMINFC, "00:00:00"  ) 	+ '</InvoiceIssueDate>'  
	cXMLRet +=    '<OperationFiscalCode>'	+ AllTrim(DE5->DE5_CFOPNF)								+ '</OperationFiscalCode>'
	cXMLRet +=    '<SEFAZNFeKey>'				+ AllTrim(DE5->DE5_NFEID)									+ '</SEFAZNFeKey>'
	cXMLRet +=    '<FreightType>'				+ AllTrim(DE5->DE5_TIPFRE)			      			+ '</FreightType>'

	If M->DE5_TIPTRA $ '1,2,3'  

		cXMLRet += '<TransportationType>'	+ AllTrim(DE5->DE5_TIPTRA)		    	            + '</TransportationType>'
		cXMLRet += '<TransportationModal>'  + "1"		                                    	+ '</TransportationModal>'

	Else

		cXMLRet += '<TransportationType>'	+ "1"                             	            + '</TransportationType>'
		cXMLRet += '<TransportationModal>'  + "2"		                                    	+ '</TransportationModal>'

	EndIf 
	DE5->( dbGoTop() )
	DE5->( dbSetOrder(1) ) 
	If DE5->( dbSeek( xFilial("DE5") + cCGCRem + cDoc + cSerie  ) ) 
	
		cXMLRet += 	  '<ListOfItems>' 
		   While DE5->( !Eof() ) .And. DE5->( DE5_FILIAL + DE5_CGCREM + DE5_DOC + DE5_SERIE ) == xFilial("DE5") + cCGCRem + cDoc + cSerie  
				cXMLRet += 			'<Item>'		
				cXMLRet +=    	  		'<ItemCode>' 				+ AllTrim(DE5->DE5_CODPRO)									+ '</ItemCode>'
				cXMLRet +=    			'<PackageCode>'			+ AllTrim(DE5->DE5_CODEMB)									+ '</PackageCode>'
				cXMLRet +=    			'<VolumeQuantity>' 		+ AllTrim(STR(DE5->DE5_QTDVOL,5))						+ '</VolumeQuantity>'
				cXMLRet +=    			'<Value>' 					+ AllTrim(STR(DE5->DE5_VALOR,14,2))						+ '</Value>'
				cXMLRet +=    			'<Weight>' 					+ AllTrim(STR(DE5->DE5_PESO,11,4))						+ '</Weight>' 
				cXMLRet +=    			'<CubicWeight>' 			+ AllTrim(STR(DE5->DE5_PESOM3,11,4))					+ '</CubicWeight>' 
				cXMLRet +=    			'<CubicMeters>' 			+ AllTrim(STR(DE5->DE5_METRO3,11,4))  			 		+ '</CubicMeters>' 	
				cXMLRet +=    			'<CalculationBasisICMS>'+ AllTrim(STR(DE5->DE5_BASEIC,14,2))					+ '</CalculationBasisICMS>'
				cXMLRet +=    			'<ICMSValue>'				+ AllTrim(STR(DE5->DE5_VALICM,14,2))					+ '</ICMSValue>' 	
				cXMLRet +=			'</Item>'
				DE5->( dbSkip() )
			EndDo
		cXMLRet += 		'</ListOfItems>'
		
	EndIf   

	cXMLRet += '</BusinessContent>'			
	
EndIf

RestArea(aAreaDE5)
Return { lRet, cXMLRet }