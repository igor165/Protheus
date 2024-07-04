#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWADAPTEREAI.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IntegDef  ºAutor  ³ Leandro Paulino  º Data ³  01/02/12       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Funcao de integracao com o adapter EAI para recebimento e    º±±
±±º          ³ envio de informações do inventário   (SB7)                   º±±
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
±±º Uso      ³ MATA270                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATI270( cXML, nTypeTrans, cTypeMessage )

Local lRet     	:= .T.
Local cXMLRet  	:= ""
Local cError	:= ""
Local cWarning 	:= "" 
Local aRet		:= {}             
Local cVersao   := "" //Versao da mensagem

Private oXmlA270	 	:= Nil
Private lMsErroAuto   	:= .F.
Private lAutoErrNoFile	:= .T.

If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		oXmlA270 := XmlParser(cXml, "_", @cError, @cWarning)
		
		If oXmlA270 <> Nil .And. Empty(cError) .And. Empty(cWarning)
			
			// Versão da mensagem
            If Type("oXmlA270:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXmlA270:_TOTVSMessage:_MessageInformation:_version:Text)
               cVersao := StrTokArr(oXmlA270:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
               
               	If cVersao == "1"
		            aRet := v1000(cXml, nTypeTrans, cTypeMessage, oXmlA270)
		        ElseIf cVersao == "2"
		        	aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXmlA270)    
		        ElseIf cVersao == "3"
		        	aRet := v3000(cXml, nTypeTrans, cTypeMessage, oXmlA270)
		        Else
		            lRet    := .F.
		            cXmlRet := "A versão da mensagem informada não foi implementada!"
		            aRet := { lRet , cXMLRet }
		        EndIf
               
            Else
               lRet := .F.
               cXmlRet := "Versão da mensagem não informada!"
               aRet := { lRet , cXMLRet }
            EndIf
			
		Else
			// "Falha ao gerar o objeto XML"
			lRet := .F.
			cXMLRet := "Falha ao manipular o XML"
			aRet := { lRet , cXMLRet }
		EndIf

	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		cXMLRet := '<TAGX>TESTE DE RECEPCAO RESPONSE MESSAGE</TAGX>'
		aRet := { lRet , cXMLRet }
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := '1.000|2.000|2.001|3.000'
		aRet := { lRet , cXMLRet, "INVENTORY" }
	EndIf

ElseIf ( nTypeTrans == TRANS_SEND )//Trata o envio de mensagem

	cVersao := StrTokArr(RTrim(PmsMsgUVer('INVENTORY','MATA270')), ".")[1]
	
    //Faz chamada da versão especifica   
   	If cVersao == "1"
        aRet := v1000(cXml, nTypeTrans, cTypeMessage, oXmlA270)
    ElseIf cVersao == "2"
    	aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXmlA270)
    ElseIf cVersao == "3"
    	aRet := v3000(cXml, nTypeTrans, cTypeMessage, oXmlA270)    	
    Else
        lRet    := .F.
        cXmlRet := "A versão da mensagem não foi informada ou não foi implementada!" //"A versão da mensagem não foi informada ou não foi implementada!"
        aRet := { lRet , cXMLRet }
    EndIf
	
EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} V1000
Funcao de integracao com o adapter EAI para envio e recebimento da
digitação de inventário utilizando o conceito de mensagem unica.
@type function
@param Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)
@param Objeto, oXml, Objeto xml com a mensagem recebida.

@author rafael.pessoa
@version P12
@since 13/12/2017
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
		aRet[1] - (boolean) Indica o resultado da execução da função
		aRet[2] - (caracter) Mensagem Xml para envio
/*/
//-------------------------------------------------------------------
Static Function v1000(cXml, nTypeTrans, cTypeMessage, oXmlA270)

Local lRet     	:= .T.
Local lAtuSaldo	:= .F.
Local cXMLRet  	:= ""
Local cLogErro 	:= ""  
Local cNumDoc	:= "" 
Local cValInt 	:= "" 
Local cEvent   	:= "upsert" 
Local nCount   	:= 0
Local nOpcx		:= 3
Local aErroAuto	:= {} 
Local aAuto		:= {}
Local dData 	:= Ctod( "" )
Local cPrdVer	:= RTrim(PmsMsgUVer('ITEM','MATA010')) //Versão do Produto
Local aAux		:= {}             

Default cXml 			:= ""
Default nTypeTrans 		:= 0
Default cTypeMessage 	:= ""
Default oXmlA270 		:= ""

If nTypeTrans == TRANS_RECEIVE

	If cTypeMessage == EAI_MESSAGE_BUSINESS

		If Type("oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text") <> "U"
			cNumDoc	:= oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text
		Else
			cNumDoc	:= ''	
		EndIf	  
		
		If Upper(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
			nOpcx := 5
		EndIf
		
		If Type("oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text") <> "U"                      
		   // De Para de códigos - Tabela XXF
			cValInt :=  CFGA070INT( oXmlA270:_TotvsMessage:_MessageInformation:_Product:_Name:Text     ,;
                                "SB1", "B1_COD"                                                        ,; 
                                oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text )				
			
			//Tratamento versao produto
			If cPrdVer > "1.001" 
				If !Empty(cValInt) 					
					aAux := Separa(cValInt, "|")
				
					If ValType(aAux) == "A" .And. Len(aAux) > 2 
						cValInt := PadR(aAux[3], TamSX3("B1_COD")[1])
					EndIf																						
				Else //Busca codigo do produto Protheus caso seja enviado diretamente
					SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
					
					If SB1->(dbSeek(xFilial("SB1") + PadR(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text, TamSX3("B1_COD")[1])))
						cValInt := SB1->B1_COD	
					EndIf
				EndIf											
			EndIf
			
			If Empty(cValInt)
				lRet 		:= .F.
				cXMLRet := "Produto Inválido ou não encontrado no de/para!"	//"Produto Inválido ou não encontrado no de/para!"
			Else				
				Aadd(aAuto,{"B7_COD", PadR( cValInt ,TamSx3("B7_COD")[1]), Nil })
			EndIf	
		EndIf	
		
		If Type("oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text") <> "U"
			cValInt := ""
		    // De Para de códigos - Tabela XXF
			cValInt :=  CFGA070INT( oXmlA270:_TotvsMessage:_MessageInformation:_Product:_Name:Text     ,;
                                "NNR", "NNR_CODIGO"                                                        ,; 
                                    oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text )				
 
				If !Empty(cValInt) 					
					aAux := Separa(cValInt, "|")
			
				If ValType(aAux) == "A" .And. Len(aAux) > 2 
					cValInt := PadR(aAux[3], TamSX3("NNR_CODIGO")[1])
				EndIf																						
			Else 
				NNR->(dbSetOrder(1)) //NNR_FILIAL+NNR_CODIGO
				
				If NNR->(dbSeek(xFilial("NNR") + PadR(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text, TamSX3("NNR_CODIGO")[1])))
					cValInt := NNR->NNR_CODIGO	
				EndIf
			EndIf											

			
			If Empty(cValInt)
				lRet 		:= .F.
				cXMLRet := "Armazém Inválido ou não encontrado no de/para!"	//"Armazém Inválido ou não encontrado no de/para!"
			Else				
				Aadd(aAuto,{"B7_LOCAL", Padr(cValInt, TamSX3("B7_LOCAL")[1] )  , Nil })
			EndIf	
			
		EndIf	
											
		Aadd(aAuto,{"B7_DOC", IIf(!Empty(cNumDoc),cNumDoc,cNumDoc:=NextNumero('SB7',3,'B7_DOC',.T.)), Nil })							
		If Type("oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Quantity:Text") <> "U"
			Aadd(aAuto,{"B7_QUANT", VAl(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Quantity:Text), Nil })
		EndIf
		If Type("oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Quantity2UnitMeasure:Text") <> "U"
			Aadd(aAuto,{"B7_QTSEGUM", Val(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Quantity2UnitMeasure:Text), Nil })
		EndIf
		If Type("oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DateInventory:Text") <> "U"
			dData := Ctod( SubStr( oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DateInventory:Text, 9, 2 ) + '/' + ;
			               SubStr( oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DateInventory:Text, 6, 2 ) + '/' + ;
			               SubStr( oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DateInventory:Text, 1, 4 ) )
			
			Aadd(aAuto,{"B7_DATA", dData , Nil })
		EndIf
		If Type("oXmlA270:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U" .And. SB7->(FieldPos("B7_ORIGEM")) <> 0
          Aadd(aAuto,{"B7_ORIGEM", oXmlA270:_TotvsMessage:_MessageInformation:_Product:_Name:Text, Nil })
    	EndIf
		
		If nOpcx == 5
			lMsErroAuto := .F. 
			lAtuSaldo	:= .F.
		ElseIf lRet
			MSExecAuto({|x,y| mata270(x,y)},aAuto,.T.)
			lAtuSaldo := .T.
		EndIf	
						
		If lMsErroAuto
			aErroAuto := GetAutoGRLog()
			For nCount := 1 To Len(aErroAuto)
				cLogErro += StrTran(StrTran(aErroAuto[nCount],"<",""),"-","") + (" ")
			Next nCount
			// Monta XML de Erro de execução da rotina automatica.
			lRet 		:= .F.
			cXMLRet 	:= cLogErro
		ElseIf lAtuSaldo
			//--Chamar rotina de atualização estoque
			MATA340(.T.,cNumDoc,.T.)
			// Monta xml com status do processamento da rotina autmotica OK.
			cXMLRet := "<OrderId>"+dTos(SB7->B7_DATA)+SB7->(B7_COD+B7_LOCAL)+"</OrderId>"
		ElseIf lRet	
			// Monta xml com status do processamento da rotina autmotica OK.
			cXMLRet := "<OrderId>"+dTos(SB7->B7_DATA)+SB7->(B7_COD+B7_LOCAL)+"</OrderId>"
		EndIf
	
	EndIf
	
ElseIf nTypeTrans == TRANS_SEND

	If !Inclui .And. !Altera
		cEvent := 'delete'		
	EndIf

	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>INVENTORY</Entity>'
	cXMLRet +=     '<Event>' + cEvent + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="DateInventory">'  	+ DTos(SB7->B7_DATA)	+ '</key>'
	cXMLRet +=         '<key name="ItemCode">' 			+ SB7->B7_COD			+ '</key>'
	cXMLRet +=         '<key name="WareHouseCode">'		+ SB7->B7_LOCAL 		+ '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'
	
	cXMLRet += '<BusinessContent>'
	cXMLRet +=	  '<ItemCode>'  			+ AllTrim(SB7->B7_COD)						+ '</ItemCode>'
	cXMLRet +=	  '<WarehouseCode>' 		+ AllTrim(SB7->B7_LOCAL)						+ '</WarehouseCode>'
	cXMLRet +=    '<DocumentNumber>'		+ AllTrim(SB7->B7_DOC)						+ '</DocumentNumber>'
	cXMLRet +=    '<Quantity>' 				+ AllTrim(STR(SB7->B7_QUANT,14,2))			+ '</Quantity>'
	cXMLRet +=    '<Quantity2UnitMeasure>'	+ AllTrim(STR(SB7->B7_QTSEGUM,14,2))			+ '</Quantity2UnitMeasure>'
	cXMLRet +=    '<DateInventory>' 		+ FWTimeStamp( 3, SB7->B7_DATA, "00:00:00" )	+ '</DateInventory>'

	cXMLRet += '</BusinessContent>'				                     	
	
EndIf


Return {lRet, cXmlRet}


//-------------------------------------------------------------------
/*/{Protheus.doc} V2000
Funcao de integracao com o adapter EAI para envio e recebimento da
digitação de inventário utilizando o conceito de mensagem unica.
@type function
@param Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)
@param Objeto, oXml, Objeto xml com a mensagem recebida.

@author rafael.pessoa
@version P12
@since 13/12/2017
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
		aRet[1] - (boolean) Indica o resultado da execução da função
		aRet[2] - (caracter) Mensagem Xml para envio
/*/
//-------------------------------------------------------------------
Static Function v2000(cXml, nTypeTrans, cTypeMessage, oXmlA270)

Local lRet     	:= .T.
Local lAtuSaldo	:= .F.
Local cXMLRet  	:= ""
Local cLogErro 	:= ""  
Local cNumDoc	:= "" 
Local cValInt 	:= "" 
Local cEvent   	:= "upsert" 
Local nCount   	:= 0
Local nOpcx		:= 3
Local aErroAuto	:= {} 
Local aAuto		:= {}
Local dData 	:= Ctod( "" )
Local cPrdVer	:= RTrim(PmsMsgUVer('ITEM','MATA010')) //Versão do Produto
Local aAux		:= {}             

Default cXml 			:= ""
Default nTypeTrans 		:= 0
Default cTypeMessage 	:= ""
Default oXmlA270 		:= ""

If nTypeTrans == TRANS_RECEIVE

	If cTypeMessage == EAI_MESSAGE_BUSINESS

		If Type("oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text") <> "U"
			cNumDoc	:= oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text
		Else
			cNumDoc	:= ''	
		EndIf	  
		
		If Upper(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
			nOpcx := 5
		EndIf
		
		If Type("oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text") <> "U"                      
		   // De Para de códigos - Tabela XXF
			cValInt :=  CFGA070INT( oXmlA270:_TotvsMessage:_MessageInformation:_Product:_Name:Text     ,;
                                "SB1", "B1_COD"                                                        ,; 
                                oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text )				
			
			//Tratamento versao produto
			If cPrdVer > "1.001" 
				If !Empty(cValInt) 					
					aAux := Separa(cValInt, "|")
				
					If ValType(aAux) == "A" .And. Len(aAux) > 2 
						cValInt := PadR(aAux[3], TamSX3("B1_COD")[1])
					EndIf																						
				Else //Busca codigo do produto Protheus caso seja enviado diretamente
					SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
					
					If SB1->(dbSeek(xFilial("SB1") + PadR(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text, TamSX3("B1_COD")[1])))
						cValInt := SB1->B1_COD	
					EndIf
				EndIf											
			EndIf
			
			If Empty(cValInt)
				lRet 		:= .F.
				cXMLRet := "Produto Inválido ou não encontrado no de/para!"	//"Produto Inválido ou não encontrado no de/para!"
			Else				
				Aadd(aAuto,{"B7_COD", PadR( cValInt ,TamSx3("B7_COD")[1]), Nil })
			EndIf	
		EndIf	
		
		If Type("oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text") <> "U"
			cValInt := ""
		    // De Para de códigos - Tabela XXF
			cValInt :=  CFGA070INT( oXmlA270:_TotvsMessage:_MessageInformation:_Product:_Name:Text     ,;
                                "NNR", "NNR_CODIGO"                                                        ,; 
                                    oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text )				
 
				If !Empty(cValInt) 					
					aAux := Separa(cValInt, "|")
			
				If ValType(aAux) == "A" .And. Len(aAux) > 2 
					cValInt := PadR(aAux[3], TamSX3("NNR_CODIGO")[1])
				EndIf																						
			Else 
				NNR->(dbSetOrder(1)) //NNR_FILIAL+NNR_CODIGO
				
				If NNR->(dbSeek(xFilial("NNR") + PadR(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text, TamSX3("NNR_CODIGO")[1])))
					cValInt := NNR->NNR_CODIGO	
				EndIf
			EndIf											

			
			If Empty(cValInt)
				lRet 		:= .F.
				cXMLRet := "Armazém Inválido ou não encontrado no de/para!"	//"Armazém Inválido ou não encontrado no de/para!"
			Else				
				Aadd(aAuto,{"B7_LOCAL", Padr(cValInt, TamSX3("B7_LOCAL")[1] )  , Nil })
			EndIf	
			
		EndIf	
											
		Aadd(aAuto,{"B7_DOC", IIf(!Empty(cNumDoc),cNumDoc,cNumDoc:=NextNumero('SB7',3,'B7_DOC',.T.)), Nil })							
		If Type("oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Quantity:Text") <> "U"
			Aadd(aAuto,{"B7_QUANT", VAl(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Quantity:Text), Nil })
		EndIf
		If Type("oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Quantity2UnitMeasure:Text") <> "U"
			Aadd(aAuto,{"B7_QTSEGUM", Val(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Quantity2UnitMeasure:Text), Nil })
		EndIf
		If Type("oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DateInventory:Text") <> "U"
			dData := Ctod( SubStr( oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DateInventory:Text, 9, 2 ) + '/' + ;
			               SubStr( oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DateInventory:Text, 6, 2 ) + '/' + ;
			               SubStr( oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DateInventory:Text, 1, 4 ) )
			
			Aadd(aAuto,{"B7_DATA", dData , Nil })
		EndIf
		If Type("oXmlA270:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U" .And. SB7->(FieldPos("B7_ORIGEM")) <> 0
          Aadd(aAuto,{"B7_ORIGEM", oXmlA270:_TotvsMessage:_MessageInformation:_Product:_Name:Text, Nil })
    	EndIf
		
		If nOpcx == 5
			lMsErroAuto := .F. 
			lAtuSaldo	:= .F.
		ElseIf lRet
			MSExecAuto({|x,y| mata270(x,y)},aAuto,.T.)
			lAtuSaldo := .T.
		EndIf	
						
		If lMsErroAuto
			aErroAuto := GetAutoGRLog()
			For nCount := 1 To Len(aErroAuto)
				cLogErro += StrTran(StrTran(aErroAuto[nCount],"<",""),"-","") + (" ")
			Next nCount
			// Monta XML de Erro de execução da rotina automatica.
			lRet 		:= .F.
			cXMLRet 	:= cLogErro
		ElseIf lAtuSaldo
			//--Chamar rotina de atualização estoque
			MATA340(.T.,cNumDoc,.T.)
			// Monta xml com status do processamento da rotina autmotica OK.
			cXMLRet := "<OrderId>"+dTos(SB7->B7_DATA)+SB7->(B7_COD+B7_LOCAL)+"</OrderId>"
		ElseIf lRet	
			// Monta xml com status do processamento da rotina autmotica OK.
			cXMLRet := "<OrderId>"+dTos(SB7->B7_DATA)+SB7->(B7_COD+B7_LOCAL)+"</OrderId>"
		EndIf
	
	EndIf
	
ElseIf nTypeTrans == TRANS_SEND

	If !Inclui .And. !Altera
		cEvent := 'delete'		
	EndIf

	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>INVENTORY</Entity>'
	cXMLRet +=     '<Event>' + cEvent + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="DateInventory">'  	+ DTos(SB7->B7_DATA)	+ '</key>'
	cXMLRet +=         '<key name="ItemCode">' 			+ SB7->B7_COD			+ '</key>'
	cXMLRet +=         '<key name="WareHouseCode">'		+ SB7->B7_LOCAL 		+ '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'
	
	cXMLRet += '<BusinessContent>'
	cXMLRet +=	  '<ItemCode>'  			+ AllTrim(SB7->B7_COD)						+ '</ItemCode>'
	cXMLRet +=	  '<WarehouseCode>' 		+ AllTrim(SB7->B7_LOCAL)						+ '</WarehouseCode>'
	cXMLRet +=    '<DocumentNumber>'		+ AllTrim(SB7->B7_DOC)						+ '</DocumentNumber>'
	cXMLRet +=    '<Quantity>' 				+ AllTrim(STR(SB7->B7_QUANT,14,2))			+ '</Quantity>'
	cXMLRet +=    '<Quantity2UnitMeasure>'	+ AllTrim(STR(SB7->B7_QTSEGUM,14,2))			+ '</Quantity2UnitMeasure>'
	cXMLRet +=    '<DateInventory>' 		+ FWTimeStamp( 3, SB7->B7_DATA, "00:00:00" )	+ '</DateInventory>'

	cXMLRet += '</BusinessContent>'				                     	
	
EndIf


Return {lRet, cXmlRet}


//-------------------------------------------------------------------
/*/{Protheus.doc} V3000
Funcao de integracao com o adapter EAI para envio e recebimento da
digitação de inventário utilizando o conceito de mensagem unica.
@type function
@param Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)
@param Objeto, oXml, Objeto xml com a mensagem recebida.

@author rafael.pessoa
@version P12
@since 13/12/2017
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
		aRet[1] - (boolean) Indica o resultado da execução da função
		aRet[2] - (caracter) Mensagem Xml para envio
/*/
//-------------------------------------------------------------------
Static Function v3000(cXml, nTypeTrans, cTypeMessage, oXmlA270)

Local lRet     	:= .T.
Local cXMLRet  	:= ""
Local cLogErro 	:= ""  
Local cNumDoc	:= "" 
Local cValInt 	:= "" 
Local cEvent   	:= "upsert" 
Local nCount   	:= 0
Local nI   		:= 0
Local nOpcx		:= 3
Local aErroAuto	:= {} 
Local aAuto		:= {}
Local aItens	:= {}
Local dData 	:= Ctod( "" )
Local cPrdVer	:= RTrim(PmsMsgUVer('ITEM','MATA010')) //Versão do Produto
Local aAux		:= {}         
Local lFinishInventory := .T.    
Local cOrigem 	:= "" 

Default cXml 			:= ""
Default nTypeTrans 		:= 0
Default cTypeMessage 	:= ""
Default oXmlA270 		:= ""

If nTypeTrans == TRANS_RECEIVE

	If cTypeMessage == EAI_MESSAGE_BUSINESS

		If Type("oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text") <> "U"
			cNumDoc	:= oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text
		EndIf			  

		IIf(!Empty(cNumDoc),cNumDoc,cNumDoc:=NextNumero('SB7',3,'B7_DOC',.T.))
				
		If Upper(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
			nOpcx := 5
		EndIf
		
		If Type("oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DateInventory:Text") <> "U"
			dData := Ctod( SubStr( oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DateInventory:Text, 9, 2 ) + '/' + ;
			               SubStr( oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DateInventory:Text, 6, 2 ) + '/' + ;
			               SubStr( oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DateInventory:Text, 1, 4 ) )
		EndIf
		
		If Type("oXmlA270:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U" .And. SB7->(FieldPos("B7_ORIGEM")) <> 0
         	cOrigem := oXmlA270:_TotvsMessage:_MessageInformation:_Product:_Name:Text
    	EndIf

		If Type("oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinishInventory:Text") <> "U"
        	lFinishInventory :=  oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinishInventory:Text == "S"
    	EndIf		

		//Preenchimento da lista de itens
		If XmlChildEx(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_LISTOFITENS") <> Nil .And. XmlChildEx(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS, "_ITEM") <> Nil
		
			//Monta Array com itens	            					
			If ValType(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM) <> "A"
				XmlNode2Arr(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM, "_ITEM")
			EndIf		
		
			If  Len(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM) > 0 
			
				For nI :=1 To Len(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM)
				
					aItens := {}
					//Informacoes cabeçalho
					Aadd(aItens,{"B7_DOC"	, cNumDoc	, Nil })
					Aadd(aItens,{"B7_DATA"	, dData 	, Nil })
					Aadd(aItens,{"B7_ORIGEM", cOrigem	, Nil })
					
					If XmlChildEx(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI], "_ITEMINTERNALID") <> Nil .And.;         	
	         			!Empty(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_ITEMINTERNALID:Text)	
                     
					   // De Para de códigos - Tabela XXF
						cValInt :=  CFGA070INT( oXmlA270:_TotvsMessage:_MessageInformation:_Product:_Name:Text     ,;
			                                "SB1", "B1_COD"                                                        ,; 
			                                oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_ITEMINTERNALID:Text )				
						
						//Tratamento versao produto
						If cPrdVer > "1.001" 
							If !Empty(cValInt) 					
								aAux := Separa(cValInt, "|")
							
								If ValType(aAux) == "A" .And. Len(aAux) > 2 
									cValInt := PadR(aAux[3], TamSX3("B1_COD")[1])
								EndIf																						
							EndIf											
						EndIf
						
						If Empty(cValInt)
							lRet 		:= .F.
							cXMLRet += "Produto Inválido ou não encontrado no de/para!"	+ " Item: " + AllTrim(STR(nI)) + " Código: " + ; 
										oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_ITEMINTERNALID:Text + CHR(10) //"Produto Inválido ou não encontrado no de/para!"
						Else				
							Aadd(aItens,{"B7_COD", PadR( cValInt ,TamSx3("B7_COD")[1]), Nil })
						EndIf
					
					ElseIf XmlChildEx(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI], "_ITEMCODE") <> Nil .And.;         	
	         			!Empty(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_ITEMCODE:Text)
	         			
	         			SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
								
						If SB1->(dbSeek(xFilial("SB1") + PadR(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_ITEMCODE:Text, TamSX3("B1_COD")[1])))
							cValInt := SB1->B1_COD
							Aadd(aItens,{"B7_COD", PadR( cValInt ,TamSx3("B7_COD")[1]), Nil })
						Else
							lRet 		:= .F.
							cXMLRet += "Produto Inválido ou não encontrado." 	+ " Item: " + AllTrim(STR(nI)) + " Código: " + ;
										oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_ITEMCODE:Text + CHR(10) //"Produto não encontrado no de/para!"		
						EndIf
	         			
	         		Else	
						lRet 	:= .F.
						cXMLRet += "Produto não foi informado. " + "Item: " + AllTrim(STR(nI)) + CHR(10)		
					EndIf	
					
					If XmlChildEx(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI], "_WAREHOUSEINTERNALID") <> Nil .And.;         	
	         			!Empty(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_WAREHOUSEINTERNALID:Text)	
					
						cValInt := ""
					    // De Para de códigos - Tabela XXF
						cValInt :=  CFGA070INT( oXmlA270:_TotvsMessage:_MessageInformation:_Product:_Name:Text     ,;
			                                "NNR", "NNR_CODIGO"                                                        ,; 
			                                    oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_WAREHOUSEINTERNALID:Text )				
			 
						If !Empty(cValInt) 					
							aAux := Separa(cValInt, "|")
						
							If ValType(aAux) == "A" .And. Len(aAux) > 2 
								cValInt := PadR(aAux[3], TamSX3("NNR_CODIGO")[1])
							EndIf																						
						EndIf											
			
						
						If Empty(cValInt)
							lRet 		:= .F.
							cXMLRet += "Armazém não encontrado no de/para!" + " Item: " + AllTrim(STR(nI)) + " Código: " + ;
										oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_WAREHOUSEINTERNALID:Text + CHR(10)	//"Armazém não encontrado no de/para!"
						Else				
							Aadd(aItens,{"B7_LOCAL", Padr(cValInt, TamSX3("B7_LOCAL")[1] )  , Nil })
						EndIf	
					
					ElseIf XmlChildEx(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI], "_WAREHOUSECODE") <> Nil .And.;         	
	         			!Empty(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_WAREHOUSECODE:Text)
	         			
	         			NNR->(dbSetOrder(1)) //NNR_FILIAL+NNR_CODIGO
							
						If NNR->(dbSeek(xFilial("NNR") + PadR(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_WAREHOUSECODE:Text, TamSX3("NNR_CODIGO")[1])))
							cValInt := NNR->NNR_CODIGO
							Aadd(aItens,{"B7_LOCAL", Padr(cValInt, TamSX3("B7_LOCAL")[1] )  , Nil })	
						Else
							lRet 		:= .F.
							cXMLRet += "Armazém Inválido ou não encontrado." + " Item: " + AllTrim(STR(nI)) + " Código: " + ;
										oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_WAREHOUSECODE:Text + CHR(10)	//"Armazém Inválido ou não encontrado no de/para!"
						EndIf
	         				
	         		Else	
						lRet 		:= .F.
						cXMLRet 	+= "Local/Armazem não foi informado. " + "Item: " + AllTrim(STR(nI)) + CHR(10) 		
					EndIf	

					If XmlChildEx(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI], "_QUANTITY") <> Nil .And.;         	
	         			!Empty(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_QUANTITY:Text)
						Aadd(aItens,{"B7_QUANT", VAl(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_QUANTITY:Text), Nil })
					Else
						lRet 		:= .F.
						cXMLRet += "Quantidade não foi informada. " + "Item: " + AllTrim(STR(nI)) + CHR(10)	
					EndIf

					If XmlChildEx(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI], "_QUANTITY2UNITMEASURE") <> Nil .And.;         	
	         			!Empty(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_QUANTITY2UNITMEASURE:Text)
	         			Aadd(aItens,{"B7_QTSEGUM", Val(oXmlA270:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LISTOFITENS:_ITEM[nI]:_QUANTITY2UNITMEASURE:Text), Nil })
	         		EndIf		
					
					If lRet
						Aadd(aAuto, aItens)
					EndIf	
					
				Next nI
				
			Else
				lRet	 := .F.
				cXmlRet := "Lista de Itens não informada."
			EndIf
		Else
			lRet	 := .F.
			cXmlRet := "Lista de Itens não informada."
		EndIf 
		
		If nOpcx == 5
			lMsErroAuto := .F.	
			lFinishInventory := .F.		
		EndIf
		
		If lRet

			Begin Transaction		
				For nI := 1 To Len(aAuto)

					MSExecAuto({|x,y| mata270(x,y)},aAuto[nI],.T.)
					
					If lMsErroAuto
						aErroAuto := GetAutoGRLog()
						For nCount := 1 To Len(aErroAuto)
						
							cLogErro += StrTran(StrTran(aErroAuto[nCount],"<",""),"-","") + (" ")
						Next nCount
						// Monta XML de Erro de execução da rotina automatica.
						lRet 		:= .F.
						cXMLRet 	:= cLogErro
						Conout(cLogErro)
						DisarmTransaction()
						Exit
					EndIf
					
				Next nI	
			End Transaction				
			
		EndIf	

		If lRet				
			If lFinishInventory 
				//Chamar rotina de atualização estoque para o Documento total
				MATA340(.T.,cNumDoc,.F.)
			EndIf						
			// Monta xml com status do processamento da rotina autmotica OK.
			cXMLRet := "<OrderId>"+dTos(SB7->B7_DATA)+SB7->(B7_COD+B7_LOCAL)+"</OrderId>"
		EndIf
		
	EndIf
	
ElseIf nTypeTrans == TRANS_SEND	

	If !Inclui .And. !Altera
		cEvent := 'delete'		
	EndIf

	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>INVENTORY</Entity>'
	cXMLRet +=     '<Event>' + cEvent + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="DateInventory">'  	+ DTos(SB7->B7_DATA)	+ '</key>'
	cXMLRet +=         '<key name="ItemCode">' 			+ SB7->B7_COD			+ '</key>'
	cXMLRet +=         '<key name="WareHouseCode">'		+ SB7->B7_LOCAL 		+ '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'
	
	cXMLRet += '<BusinessContent>'
	cXMLRet +=    '<DocumentNumber>'		+ AllTrim(SB7->B7_DOC)												+ '</DocumentNumber>'
	cXMLRet +=    '<DateInventory>' 		+ FWTimeStamp( 3, SB7->B7_DATA, "00:00:00" )							+ '</DateInventory>'
	cXMLRet +=	  '<ListOfItens>'    
	cXMLRet +=    	'<Item>'
	cXMLRet += 	  		'<ItemInternalId>'      + cEmpAnt + '|' + RTrim(xFilial("SB1"))+ "|" + RTrim(SB7->B7_COD) 	+ '</ItemInternalId>'
	cXMLRet +=	  		'<ItemCode>'  			+ AllTrim(SB7->B7_COD)												+ '</ItemCode>'
	cXMLRet +=	  		'<WarehouseInternalId>'	+ cEmpAnt + '|' + RTrim(xFilial("NNR"))+ "|" + RTrim(SB7->B7_LOCAL) 	+ '</WarehouseInternalId>'	
	cXMLRet +=	  		'<WarehouseCode>' 		+ AllTrim(SB7->B7_LOCAL)												+ '</WarehouseCode>'	
	cXMLRet +=    		'<Quantity>' 			+ AllTrim(STR(SB7->B7_QUANT,14,2))									+ '</Quantity>'
	cXMLRet +=    		'<Quantity2UnitMeasure>'+ AllTrim(STR(SB7->B7_QTSEGUM,14,2))									+ '</Quantity2UnitMeasure>'
	cXMLRet +=    	'</Item>'
	cXMLRet +=	  '</ListOfItens>'    
		
	
	cXMLRet += '</BusinessContent>'			
	
EndIf

Return {lRet, cXmlRet}
