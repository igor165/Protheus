#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "XMLXFUN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LOJA2512  ºAutor  ³Microsiga          º Data ³  15/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para identificacao do fonte no repositorio que tem  º±±
±±º          ³a rotina para Integração com o CAP do Financial Service     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Function LOJA2512(); Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    |IntegDef         ºAutor  ³Vendas Clientes      º Data ³  15/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função que gera/recebe o XML da fila EAI, conforme adapter config   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±  
±±ºParametros³ ExpC1 = CXML                                                       º±±
±±º          ³ ExpN2 = Tipo                                                       º±±
±±º          ³ ExpC2 = Tipo da Mensagem                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja/SigaFRT                                             		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function IntegDef(cXml,nType,cTypeMsg)  



	Local lRet    := .T.  	//Retorno da função
	Local cXmlRet := ""  	//XML de Retorno
	Local oXmlEAI := NIL  	//Objeto do XML EAI, para montagem do XML de envio
	Local cPai := ""      	//Nome da tag pai       
	Local cPict14_5 := "@R 999999999.99999"
	Local cPict20_5 := "@R 99999999999999.99999" 

	conout ( '>->-> Execucao da INTEGDEF - ' + FunName() + cValtoChar( Time() ) )     

	// verificação do tipo de transacao recepção ou envio
	Do Case 
	// trata o envio
		Case ( nType == TRANS_SEND )
		//conout ( '>---------- inicio TRANS_SEND' + cValtoChar( Time() ) )       

		//Inicio Tags
		oXMLEAI := LjClXMLEai():New("BusinessRequest", , , , "BaixaTituloCAP", "BusinessContent")  
		
		oXMLEAI:AddTag("ReceiveReopenExternalCollection", "", 0,, , 1, "1","")  
		cPai := "ReceiveReopenExternalCollection"  
			oXMLEAI:AddTag("User", cPai,1,,,1,"1",			{ || SuperGetMv('MV_LJUSRFS',,'')}, "C", 15, )
			oXMLEAI:AddTag("Password", cPai,2,,,1, "1",	{ || SuperGetMv('MV_LJPSWFS',,'')},"C",15, )
			oXMLEAI:AddTag("ReceiptReopeningData", cPai,3,,,1,"1",,,,)
			
			cPai := "ReceiptReopeningData"
				oXMLEAI:AddTag("Corporation", cPai,4,,, 1, "1",	{ || SuperGetMv('MV_LJIFSCO',,'')},"C",2,)
				oXMLEAI:AddTag("Regional", cPai,5,,, 1, "1",		{ || SuperGetMv('MV_LJIFSRE',,'')},"C", 2,)
				oXMLEAI:AddTag("Company", cPai,6,,, 1, "1",		{ || SM0->M0_CODIGO},"C", 2,)
				oXMLEAI:AddTag("Product", cPai,7,,, 1, "1",,"C", 20,)
				oXMLEAI:AddTag("Contract", cPai,8,,, 1, "1",		{ || QryTitBaixa->((E1_PREFIXO+E1_NUM+E1_TIPO)+IIF(E1_TIPO = "FI","0",E1_PARCELA)) },"C", 20)
				oXMLEAI:AddTag("ContractDate",cPai,9,,,1,"1",		{ || QryTitBaixa->E1_EMISSAO}, "D",8)
				oXMLEAI:AddTag("Installment",cPai,10,,,1,"1",		{ || LjNumParc(QryTitBaixa->E1_PARCELA)}, "N",3,"@R 999")
				oXMLEAI:AddTag("EventDate",cPai,11,,,1,"1",		{ || QryTitBaixa->E5_DATA}, "D",8)
				oXMLEAI:AddTag("ReceiptDate",cPai,12,,,1,"1",		{ || QryTitBaixa->E5_DATA}, "D",8)
				oXMLEAI:AddTag("PrincipalValue",cPai,13,,,1,"1",	{ || QryTitBaixa->( (E5_VALOR+E5_VLDESCO)- (E5_VLMULTA + E5_VLJUROS))  }, "N",15,cPict14_5) //alterado
				oXMLEAI:AddTag("Sequential",cPai,18,,,1, "1",		{ || Val(QryTitBaixa->E5_SEQ) }, "N",22)
				oXMLEAI:AddTag("CreditDate",cPai,19,,,1,"1",		{ || QryTitBaixa->E5_DATA}, "D",8)
				oXMLEAI:AddTag("PermanenceValue",cPai,20,,,1,"1",	{ || QryTitBaixa->E5_VLJUROS }, "N",21,cPict20_5)
				oXMLEAI:AddTag("ReceivingBank",cPai,21,,,1, "1",, "C",02,)
				oXMLEAI:AddTag("FineValue",cPai,22,,,1,"1",		{ || QryTitBaixa->E5_VLMULTA }, "N",21,cPict20_5)
				oXMLEAI:AddTag("DifferenceReceivableValue",cPai,23,,,1, "1",, "N",22.14,)
				oXMLEAI:AddTag("DiscountValue",cPai,24,,,1,"1",	{ || QryTitBaixa->E5_VLDESCO }, "N",21,cPict20_5)
				oXMLEAI:AddTag("ReceivingType",cPai,25,,,1,"1",	{ || IIF( QryTitBaixa->( ( (E5_VALOR+E5_VLDESCO)- (E5_VLMULTA + E5_VLJUROS))  ==  E1_VALOR), 1, 2) }, "N",1,"@R 9") //26/06/12 - Fabiana
				oXMLEAI:AddTag("Operation",cPai,26,,,1,"1",		{ || IIF(QryTitBaixa->E5_TIPODOC <> "ES", 1, 2) }, "N",1,"@R 9")
				oXMLEAI:AddTag("ProcessIdNumber",cPai,27,,,1,"1",	{ || "1" },"C", 1 )
				oXMLEAI:AddTag("AmountPaid",cPai,28,,,1,"1",		{ ||QryTitBaixa->E5_VALOR }, "N",15,cPict14_5)
				oXMLEAI:AddTag("SaleOrigin",cPai,29,,,1, "1",, "C",20,)
				oXMLEAI:AddTag("OriginSystem",cPai,30,,,1,"1",		{ || "PRT"  }, "C",3)
				oXMLEAI:AddTag("CodEvent",cPai,31,,,1,"1",			{ || "02"  }, "C",2)
		//Fim tags			
					 
	cXMLRet := oXMLEAI:GerarXML()	 
	

	conout ( 'fim TRANS_SEND' + cValtoChar( Time() ) )
	// integdef criada somente para o envio dos títulos, o retorno está sendo desprezado
	Case ( nType == TRANS_RECEIVE )
		Do Case 
			Case ( cTypeMsg == EAI_MESSAGE_WHOIS ) 
				cXmlRet := '1.000'		// versão do XML para o cabeçalho a inserir pelo EAI

			Case ( cTypeMsg == EAI_MESSAGE_RESPONSE )

			Case ( cTypeMsg == EAI_MESSAGE_RECEIPT )

		End Case	

	End Case

	If oXMLEAI <> NIL
		FreeObj(oXMLEAI)
		oXMLEAI := NIL
	EndIf

	conout ( '>->-> Fim da INTEGDEF' + cValtoChar( Time() ) )

Return { lRet, cXmlRet }          

