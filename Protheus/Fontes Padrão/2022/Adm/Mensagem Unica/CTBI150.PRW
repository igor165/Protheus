#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"  
#INCLUDE "CTBI150.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBI150
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de cotação de moedas utilizando o conceito de mensagem unica.

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Leandro Luiz da Cruz
@version P11
@since   27/12/2012
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     Caso a versão da mensagem utilizada (XX4_SNDVER) seja 1.000 será chamada a
         função v1000 caso seja 2.000 será chamada a função v2000.
/*/
//------------------------------------------------------------------------------------
Function CTBI150(cXML, nTypeTrans, cTypeMessage, cVersion)
   Local cError   := ""
   Local cWarning := ""
   Local cVersao  := ""
   Local lRet     := .T.
   Local cXmlRet  := ""
   Local aRet     := {}
   
   Private oXML     := Nil

   If cTypeMessage == EAI_MESSAGE_BUSINESS .Or. cTypeMessage == EAI_MESSAGE_RESPONSE
      If nTypeTrans == TRANS_RECEIVE
         oXml := xmlParser(cXml, "_", @cError, @cWarning)
            
         If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
            If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
               cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
            Else
               lRet    := .F.
               cXmlRet := STR0002 //"Versão da mensagem não informada!"               
            EndIf
         Else
            lRet    := .F.
            cXmlRet := STR0003 //"Erro no parser!"            
         EndIf

         If lRet
            If cVersao == "1"
               aRet    := v1000(cXml, nTypeTrans, cTypeMessage, cVersion)            
               lRet    := aRet[1]
               cXmlRet := aRet[2]
            ElseIf cVersao == "2"
               aRet    := v2000(cXml, nTypeTrans, cTypeMessage, oXml, cVersion)            
               lRet    := aRet[1]
               cXmlRet := aRet[2]
            Else
               lRet    := .F.
               cXmlRet := STR0004 //"A versão da mensagem informada não foi implementada!"            
            EndIf
         EndIf
      ElseIf nTypeTrans == TRANS_SEND
         If !Empty(cVersion)
            cVersao := SubStr(cVersion, 1, 1)          
         Else
            lRet := .F.
            cXmlRet := STR0006 //"Adapter não encontrado!"	         
         EndIf

         If lRet
            If cVersao == "1"
               aRet    := v1000(cXml, nTypeTrans, cTypeMessage, cVersion)
               lRet    := aRet[1]
               cXmlRet := aRet[2]
            ElseIf cVersao == "2"
               aRet    := v2000(cXml, nTypeTrans, cTypeMessage, oXml, cVersion)
               lRet    := aRet[1]
               cXmlRet := aRet[2]
            Else
               lRet    := .F.
               cXmlRet := STR0004 //"A versão da mensagem informada não foi implementada!"	        
            EndIf
         EndIf
      EndIf      
   ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
      cXmlRet := "1.000|2.000|2.001"
   EndIf

Return {lRet, cXmlRet, "CURRENCYQUOTATION"}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IntegDef  ºAutor  ³ Marcelo C. Coutinho  º Data ³  09/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mensagem Única												º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Mensagem Única                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function v1000( cXML, nTypeTrans, cTypeMessage, cVersion )

Local lRet     	:= .T.
Local cData     	:= ""
Local cDia     	:= ""
Local cMes     	:= ""
Local cAno     	:= ""
Local nTaxa    	:= ""
Local cXMLRet  	:= ""
Local cError		:= ""
Local cWarning 	:= "" 
Local cLogErro 	:= "" 
Local cEvent      := "upsert"
Local nCount      := 0 
Local nX          := 0
Local nCotacao    := 0  
Local nOpcx			:= 0
Local aCab			:= {}
Local aErroAuto	:= {}  
Local aAreaCTO 	:= {}
Local aAreaCTP 	:= {}
Local aAreaSM2 	:= {}
Local aArea 		:=GetArea()
Private aRotina        := {}
Private oXmlCTBI150	  := Nil
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

dbSelectArea("CTO")
aAreaCTO:=CTO->(GetArea())
dbSelectArea("SM2")
aAreaSM2:=SM2->(GetArea())
dbSelectArea("CTP")
aAreaCTP:=CTP->(GetArea())

If nTypeTrans == TRANS_RECEIVE 

	If cTypeMessage == EAI_MESSAGE_BUSINESS
		oXmlCTBI150 := XmlParser(cXml, "_", @cError, @cWarning)
		
		If oXmlCTBI150 <> Nil .And. Empty(cError) .And. Empty(cWarning)
			CTP->(dbSetOrder(2))
			If Type("oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text") <> "U"
				If Upper(oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
					nOpcx := 5 
				EndIf
			EndIf

			If Type("oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text") <> "U"
				cMoeda := StrZero( Val( oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text ), TamSX3('CTP_MOEDA')[1]) 				
			EndIf
			If Type("oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Period:_Month:Text") <> "U"
				cMes   := oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Period:_Month:Text
			EndIf
			If Type("oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Period:_Year:Text") <> "U"
				cAno   := oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Period:_Year:Text
			EndIf

			If valType( oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation ) <> 'A'
				nCotacao := 1
			Else
				nCotacao := Len( oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation )
			EndIf

			For nX := 1 To nCotacao

				If XmlChildEx( oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation, "_Quotation" ) != Nil .And. ;
                              XmlChildEx( oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation, "_Quotation" ) !=  'A'
					If XmlChildEx(oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation, "_Day") != Nil .And. ;
                                    XmlChildEx(oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation, "_Day") != 'U'
						cDia  :=      oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation:_Day:Text
					EndIf
					If XmlChildEx(oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation, "_Value") != Nil .And. ;
                                    XmlChildEx(oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation, "_Value") != "U"
						nTaxa := Val( oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation:_Value:Text ) 
					EndIf
				Else
					If XmlChildEx(oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation[nX], "_Day") != Nil .And. ;
                                    XmlChildEx(oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation[nX], "_Day") != "U"
						cDia  := oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation[nX]:_Day:Text
					EndIf

					If XmlChildEx(oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation[nX], "_Value") != Nil .And. ;
                                    XmlChildEx(oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation[nX], "_Value") != "U"
						nTaxa := Val( oXmlCTBI150:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation[nX]:_Value:Text )
					EndIf
   				EndIf

				aCab  := {}
				cData := ( StrZero( Val( cDia ), 2 ) + '/' + cMes + '/' + cAno )

				Aadd( aCab, { "CTP_MOEDA", cMoeda       , Nil })
				Aadd( aCab, { "CTP_TAXA" , nTaxa        , Nil })

				If CTP->( dbSeek( xFilial('CTP') + cMoeda + Dtos( Ctod( cData ))))
					nOpcx := Iif( nOpcx <> 5, 4, nOpcx )
				Else
					nOpcx := Iif( nOpcx <> 5, 3, nOpcx )
				EndIf       
				
				//-- CTO_FILIAL + CTO_MOEDA
				CTO->( dbSetOrder(1) )
				If CTO->( dbSeek( xFilial("CTO") + cMoeda ) )  
				
					MSExecAuto({|x,y,w,u,z| Ctb150Cal(x,y,w,u,z)},'CTP', CTP->( Recno() ), nOpcx, aCab, Ctod(cData)) 

					If lMsErroAuto
						aErroAuto := GetAutoGRLog()
						For nCount := 1 To Len(aErroAuto)
							cLogErro += StrTran(StrTran(aErroAuto[nCount],"<",""),"-","") + (" ")
						Next nCount
						// Monta XML de Erro de execução da rotina automatica.
						lRet := .F.
						cXMLRet := cLogErro
					Else
						// Monta xml com status do processamento da rotina autmotica OK.
						cXMLRet := "<OrderId>"+Dtos(CTP->CTP_DATA)+"</OrderId>"
					EndIf 
				Else
					lRet	 := .F.
					cXMLRet:= STR0001 + " : " + cMoeda //-- Não existe moeda relacionada a este código : ' cMoeda '
					ConOutR(cXMLRet)
				EndIf
			Next
		Else
			// "Falha ao gerar o objeto XML"
			lRet := .F.
			cXMLRet := "Falha ao manipular o XML"
		EndIf

	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		cXMLRet := '<TAGX>TESTE DE RECEPCAO RESPONSE MESSAGE</TAGX>'	
 	EndIf
	
ElseIf nTypeTrans == TRANS_SEND

   If !Inclui .And. !Altera
		cEvent := 'delete'
	EndIf

	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>CurrencyQuotation</Entity>'
	cXMLRet +=     '<Event>' + cEvent + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="InternalId">' + RTrim(CTP->CTP_MOEDA) +"|"+ DTOS(CTP->CTP_DATA) + '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'  
	
	cXMLRet += '<BusinessContent>'
	cXMLRet += 		'<CurrencyCode>'  + RTrim(CTP->CTP_MOEDA)    		   + '</CurrencyCode>'
	cXMLRet += 		'<Period>'
	cXMLRet += 			'<Year>'  + Str(Year(CTP->CTP_DATA),4)  + '</Year>'
	cXMLRet += 			'<Month>' + Str(Month(CTP->CTP_DATA),2) + '</Month>'
	cXMLRet += 		'</Period>'

	cXMLRet += 		'<ListOfQuotation>'
	cXMLRet +=   		'<Quotation>'
	cXMLRet +=   			'<Day>'   + Str( Day(CTP->CTP_DATA),2)              						  + '</Day>'
	cXMLRet +=      		'<Value>' + Str(CTP->CTP_TAXA, TamSX3('CTP_TAXA')[1], TamSX3('CTP_TAXA')[2]) + '</Value>'
	cXMLRet +=   		'</Quotation>'
	cXMLRet += 		'</ListOfQuotation>'

	cXMLRet += '</BusinessContent>'
EndIf

RestArea(aAreaCTO) 
RestArea(aAreaCTP) 
RestArea(aAreaSM2)
RestArea(aArea)

Return { lRet, cXMLRet }

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v2000
Funcao de integracao com o adapter EAI para recebimento do cadastro de
Cotação de Moeda (CTP) utilizando o conceito de mensagem unica.

@param   cXml         Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans   Tipo de transação (Envio/Recebimento).
@param   cTypeMessage Tipo de mensagem (Business Type, WhoIs, etc).
@author  Leandro Luiz da Cruz
@version P11
@since   27/12/2012
@return  aRet    - (array)    Contém o resultado da execução e a mensagem XML de retorno.
         aRet[1] - (boolean)  Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem XML para envio
       
@obs O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
     o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo TOTVSBusinessRequest
     caso a mensagem seja do tipo TOTVSBusinessRequest. O tipo da classe pode
     ser definido com a função EAI_BUSINESS_REQUEST. 
/*/
//-------------------------------------------------------------------------------------------------

Static Function v2000(cXml, nTypeTrans, cTypeMessage, oXml, cVersion)
   Local lRet             := .T.
   Local cData            := ""
   Local cDia             := ""
   Local cMes             := ""
   Local cAno             := ""
   Local nTaxa            := ""
   Local cXmlRet          := ""
   Local cError           := ""
   Local cWarning         := ""   
   Local cProduct         := ""
   Local cValExt          := ""
   Local cValInt          := ""
   Local cCode            := ""
   Local cAlias           := "CTP"
   Local cField           := "CTP_DATA"
   Local cEntity          := "CurrencyQuotation"
   Local cEvent           := "upsert"
   Local nCount           := 0 
   Local nX               := 0
   Local nI               := 0
   Local nOpcx            := 0
   Local aCab             := {}
   Local aErroAuto        := {}
   Local aAux             := {}   
   Local cVerMoeda        := RTrim(PmsMsgUVer('CURRENCY', 'CTBA140')) //Versão da mensagem Moeda 
   Local aIntIds          := {}

   Private aRotina        := {}
   Private lMsErroAuto    := .F.
   Private lAutoErrNoFile := .T.
   Private lMsHelpAuto    := .T.

   AdpLogEAI(1, "CTBI150", nTypeTrans, cTypeMessage, cXML) //"Atualize o UPDINT01.prw para utilizar o log"

   If nTypeTrans == TRANS_RECEIVE 
      If cTypeMessage == EAI_MESSAGE_BUSINESS
         // Obtém a marca
         If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
            cProduct := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
         Else
            lRet := .F.
            cXmlRet := STR0009 //"A marca é obrigatória"
            AdpLogEAI(5, "CTBI150", cXMLRet, lRet)
            Return {lRet, cXmlRet}
         EndIf
         
         // Obtém o InternalId da cotação         
         If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
            cValExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
         Else
            lRet := .F.
            cXmlRet := STR0014 //"O InternalId é obrigatório!"
            AdpLogEAI(5, "CTBI150", cXMLRet, lRet)
            Return {lRet, cXmlRet}
         EndIf
                   
         // Obtém o código da moeda da cotação (Primeiramente pelo InternalID depois pelo código)
         If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalId:Text)
            aAux := IntMoeInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalId:Text, cProduct, cVerMoeda)

            If aAux[1]
               cCode := aAux[2][3]
            Else
               lRet := .F.
               cXmlRet := aAux[2]
               AdpLogEAI(5, "CTBI150", cXMLRet, lRet)
               Return {lRet, cXmlRet}
            EndIf
         ElseIf Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text)
            cCode := StrZero(Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text), TamSX3('CTP_MOEDA')[1])
         Else
            lRet := .F.
            cXmlRet := STR0010 //"O código da moeda é obrigatório!"
            AdpLogEAI(5, "CTBI150", cXMLRet, lRet)
            Return {lRet, cXmlRet}
         EndIf                 

         // Obtém o mês da cotação
         If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Period:_Month:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Period:_Month:Text)
            cMes := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Period:_Month:Text
         Else
            lRet := .F.
            cXmlRet := STR0011 //"O mês é obrigatório"
            AdpLogEAI(5, "CTBI150", cXMLRet, lRet)
            Return {lRet, cXmlRet}
         EndIf

         // Obtém o ano da cotação
         If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Period:_Year:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Period:_Year:Text)
            cAno := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Period:_Year:Text
         Else
            lRet := .F.
            cXmlRet := STR0012 //"O ano é obrigatório"
            AdpLogEAI(5, "CTBI150", cXMLRet, lRet)
            Return {lRet, cXmlRet}
         EndIf

         // Se não for array
         If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation") != "A"
            // Transforma em array
            XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation, "_Quotation")
         EndIf

         // Verifica se a moeda da cotação existe na base
         CTO->(dbSetOrder(1))
         If !CTO->(dbSeek(xFilial("CTO") + cCode))
            lRet := .F.
            cXmlRet := STR0013 + cCode //"Não existe moeda relacionada ao código: "
            AdpLogEAI(5, "CTBI150", cXMLRet, lRet)
            Return {lRet, cXmlRet}
         EndIf

         Begin Transaction

            For nX := 1 To Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation)
               aCab := {}

               // Obtém o InternalId da cotação             
               If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation[nX], "_INTERNALID") != Nil .And. ;
                  !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation[nX]:_InternalId:Text)
                  cValExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation[nX]:_InternalId:Text
               Else
                  lRet := .F.
                  cXmlRet := STR0014 //"O InternalId é obrigatório!"
                  AdpLogEAI(5, "CTBI150", cXMLRet, lRet)                  
               EndIf
               
               If lRet
                  // Obtém o dia da cotação
                  If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation[nX], "_DAY") != Nil .And. ;
                        !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation[nX]:_Day:Text)
                     cDia := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation[nX]:_Day:Text
                  Else
                     lRet := .F.
                     cXmlRet := STR0015 //"O dia é obrigatório!"
                     AdpLogEAI(5, "CTBI150", cXMLRet, lRet)                     
                  EndIf
               EndIf

               If lRet
                  // Obtém a taxa da cotação
                  If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation[nX], "_VALUE") != Nil .And. ;
                        !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation[nX]:_Value:Text)
                     nTaxa := Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfQuotation:_Quotation[nX]:_Value:Text)
                  Else
                     lRet := .F.
                     cXmlRet := STR0016 //"A taxa é obrigatória!"
                     AdpLogEAI(5, "CTBI150", cXMLRet, lRet)                     
                  EndIf
               EndIf

               If lRet
                  // Monta a data
                  cData := (cAno + cMes + StrZero(Val(cDia), 2))

                  Aadd(aCab, {"CTP_MOEDA", cCode, Nil})
                  Aadd(aCab, {"CTP_TAXA",  nTaxa, Nil})

                  // Obtém a chave interna da cotação
                  aAux := IntCotInt(cValExt, cProduct,cVersion)

                  // Se o evento é UPSERT
                  If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
                     // Se o registro foi encontrado no de/para
                     If aAux[1]
                        // Update
                        nOpcx := 4
                     Else
                        // Insert
                        nOpcx := 3   
                     EndIf
                  ElseIf Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
                     // Se o registro foi encontrado no de/para
                     If aAux[1]
                        nOpcx := 5
                     Else
                        lRet := .F.
                        cXmlRet := STR0017 //"O registro a ser excluído não existe na base Protheus."
                        AdpLogEAI(5, "CTBI150", cXMLRet, lRet)                        
                     EndIf
                  Else
                     lRet := .F.
                     cXmlRet := STR0018 //"O evento informado é inválido!"
                     AdpLogEAI(5, "CTBI150", cXMLRet, lRet)                     
                  EndIf
               EndIf
               
               If lRet
                  cValInt := IntCotExt(/*Empresa*/, /*Filial*/, cCode, cData, cVersion)[2]

                  AdpLogEAI(3, "cValInt: ", cValInt)
                  AdpLogEAI(3, "cValExt: ", cValExt)
                  AdpLogEAI(3, "cCode: ", cCode)
                  AdpLogEAI(4, nOpcx)

                  MSExecAuto({|x,y,w,u,z| Ctb150Cal(x,y,w,u,z)},'CTP', CTP->(Recno()), nOpcx, aCab, StoD(cData))

                  // Se a Rotina Automática retornou erro
                  If lMsErroAuto
                     // Obtém o log de erros
                     aErroAuto := GetAutoGRLog()

                     // Varre o array obtendo os erros em UTF-8 e quebrando a linha
                     cXMLRet := '<![CDATA['
                     For nCount := 1 to Len(aErroAuto)
                        cXmlRet += aErroAuto[nCount] + Chr(10)
                     Next nCount
                     cXMLRet += ']]>'

                     lRet := .F.
                  Else
                     // Se o evento é diferente de DELETE
                     If nOpcx != 5
                        // Grava o registro na tabela XXF (de/para)
                        CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F.)                                                                               
                     Else
                        // Exclui o registro na tabela XXF (de/para)
                        CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T.)
                     EndIf
                     
                     //Adiciona ExternalIds e InternalIds para retorno
                     aAdd(aIntIds, {cValExt, cValInt})     
                  EndIf 
               EndIf
            Next
         End Transaction

         //Se nao houveram erros, envia lista de integracoes
         If lRet
            // Monta o XML de Retorno
            cXmlRet := "<ListOfInternalId>"
            
            For nI := 1 To Len(aIntIds)                             
               cXmlRet +=    "<InternalId>"
               cXmlRet +=       "<Name>" + cEntity + "</Name>"
               cXmlRet +=       "<Origin>" + aIntIds[nI][1] + "</Origin>"
               cXmlRet +=       "<Destination>" + aIntIds[nI][2] + "</Destination>"
               cXmlRet +=    "</InternalId>"               
            Next nI

            cXmlRet += "</ListOfInternalId>"
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
         // Se não houve erros na resposta
         If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
         	If Upper(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_Event:Text) == "UPSERT"	            
         
	            // Verifica se a marca foi informada
	            If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
	               cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0019 //"Erro no retorno. O Product é obrigatório!"
	               AdpLogEAI(5, "CTBI150", cXMLRet, lRet)
	               Return {lRet, cXmlRet}
	            EndIf
	
	            // Se não for array
	            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") != "A"
	               // Transforma em array
	               XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")
	            EndIf
	
	            // Verifica se o código interno foi informado
	            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text)
	               cValInt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0020 //"Erro no retorno. O OriginalInternalId é obrigatório!"
	               AdpLogEAI(5, "CTBI150", cXMLRet, lRet)
	               Return {lRet, cXmlRet}
	            EndIf
	
	            // Verifica se o código externo foi informado
	            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text)
	               cValExt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0021 //"Erro no retorno. O DestinationInternalId é obrigatório."
	               AdpLogEAI(5, "CTBI150", cXMLRet, lRet)
	               Return {lRet, cXmlRet}
	            EndIf
	
	            // Obtém a mensagem original enviada
	            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
	               cXML := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0022 //"Conteúdo do MessageContent vazio!"
	               AdpLogEAI(5, "CTBI150", cXMLRet, lRet)
	               Return {lRet, cXmlRet}
	            EndIf
	            
	           AdpLogEAI(3, "cValInt: ", cValInt)
	           AdpLogEAI(3, "cValExt: ", cValExt)
	
	            // Faz o parse do XML em um objeto
	            oXML := XmlParser(cXML, "_", @cError, @cWarning)
	
	            // Se não houve erros no parse
	            If oXML != Nil .And. Empty(cError) .And. Empty(cWarning)
	               If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
	                  // Insere / Atualiza o registro na tabela XXF (de/para)
	                  CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F., 1)
	               ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
	                  // Exclui o registro na tabela XXF (de/para)
	                  CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T., 1)
	               Else
	                  lRet := .F.
	                  cXmlRet := STR0023 //"Evento do retorno inválido!"
	                  AdpLogEAI(5, "CTBI150", cXMLRet, lRet)
	               EndIf
	            Else
	               lRet := .F.
	               cXmlRet := STR0024 //"Erro no parser do retorno!"
	               AdpLogEAI(5, "CTBI150", cXMLRet, lRet)
	               Return {lRet, cXmlRet}
	            EndIf
			   EndIf
         Else
            // Se não for array
            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
               // Transforma em array
               XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
            EndIf

            // Percorre o array para obter os erros gerados
            For nCount := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
               cError := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + Chr(10)
            Next nCount

            lRet := .F.
            cXmlRet := cError
         EndIf      
      EndIf
   ElseIf nTypeTrans == TRANS_SEND
      aAux := IntCotExt(/*Empresa*/, /*Filial*/, CTP->CTP_MOEDA, DToS(CTP->CTP_DATA), cVersion)
      
      If aAux[1]
         cValInt := 	aAux[2]
      
         If !Inclui .And. !Altera
            cEvent := 'delete'
            
            CFGA070Mnt(, cAlias, cField,, cValInt, .T.) // excluindo da XXF
         EndIf

         cXMLRet := '<BusinessEvent>'
         cXMLRet +=    '<Entity>CurrencyQuotation</Entity>'
         cXMLRet +=    '<Event>' + cEvent + '</Event>'
         cXMLRet +=    '<Identification>'
         cXMLRet +=       '<key name="InternalId">' + cValInt + '</key>'
         cXMLRet +=    '</Identification>'
         cXMLRet += '</BusinessEvent>'
         cXMLRet += '<BusinessContent>'
         cXMLRet +=    '<InternalId>' + cValInt + '</InternalId>'      
         cXMLRet +=    '<CurrencyCode>'  + RTrim(CTP->CTP_MOEDA) + '</CurrencyCode>'      
         cXMLRet +=    '<CurrencyInternalId>' + IntMoeExt(/*Empresa*/, /*Filial*/, CTP->CTP_MOEDA)[2] + '</CurrencyInternalId>'      
         cXMLRet +=    '<Period>'
         cXMLRet +=       '<Year>' + Str(Year(CTP->CTP_DATA), 4) + '</Year>'
         cXMLRet +=       '<Month>' + PadL(AllTrim(Str(Month(CTP->CTP_DATA))), 2, '0')  + '</Month>'
         cXMLRet +=    '</Period>'
         cXMLRet +=    '<ListOfQuotation>'      
         cXMLRet +=       '<Quotation>'      
         cXMLRet +=          '<InternalId>' + cValInt + '</InternalId>'      
         cXMLRet +=          '<Day>' + PadL(AllTrim(Str(Day(CTP->CTP_DATA))), 2, '0') + '</Day>'
         cXMLRet +=          '<Value>' + AllTrim(Str(CTP->CTP_TAXA, TamSX3('CTP_TAXA')[1], TamSX3('CTP_TAXA')[2])) + '</Value>'
         cXMLRet +=       '</Quotation>'            
         cXMLRet +=    '</ListOfQuotation>'
         cXMLRet += '</BusinessContent>'
      Else
         lRet := .F.
         cXmlRet := aAux[2]      
      EndIf
   EndIf

   AdpLogEAI(5, "CTBI150", cXMLRet, lRet)
Return {lRet, cXMLRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} IntCotExt
Monta o InternalID da Cotação de Moedas de acordo com o código passado
no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default cFilAnt)
@cMoeda  cMoeda     Código da Moeda
@cData   cData      Data da Cotação
@param   cLocalEst  Código da Cotação de Moedas
@param   cVersao    Versão da mensagem única (Default 2.000)

@author  Leandro Luiz da Cruz
@version P11
@since   21/02/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  IntCotExt('01',,'01','20130221') irá retornar {.T.,'01|01|01|20130130'}
/*/
//-------------------------------------------------------------------
Function IntCotExt(cEmpresa, cFil, cMoeda, cData, cVersao)
   Local aResult    := {}
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('CTP')
   Default cVersao  := '2.000'

   If AllTrim(cVersao) == '1.000'
      aAdd(aResult, .T.)
      aAdd(aResult, PadR(cMoeda, TamSX3('CTP_MOEDA')[1]) + '|' + DToS(cData))
   ElseIf AllTrim(cVersao) == '2.000' .Or. AllTrim(cVersao) == '2.001'
      aAdd(aResult, .T.)
      aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cMoeda) + '|' + RTrim(cData))
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, STR0025 + Chr(10) + STR0026) //"Versão da cotação de moeda não suportada." "As versões suportadas são: 1.000 e 2.000."
   EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntCotInt
Recebe um InternalID e retorna o código da Cotação de Moedas

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Versão da mensagem única (Default 1.000)

@author  Leandro Luiz da Cruz 
@version P11
@since   21/02/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado no de/para.
         No segundo parâmetro uma variável array com a empresa,
         filial e o Código da Cotação de Moedas.

@sample  IntLocInt('01|01|01|20130130','RM') irá retornar {.T., {'01', '01', '01', '20130130'}}
/*/
//-------------------------------------------------------------------
Function IntCotInt(cInternalID, cRefer, cVersao)
   Local   aResult  := {}
   Local   aTemp    := {}
   Local   cTemp    := ''
   Local   cAlias   := 'CTP'
   Local   cField   := 'CTP_DATA'
   Default cVersao  := '2.000'

   cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
   
   If Empty(cTemp)
      aAdd(aResult, .F.)
      aAdd(aResult, STR0027 + AllTrim(cInternalID) + STR0028) //"Cotação " " não encontrado no de/para!"
   Else
      If AllTrim(cVersao) == '1.000'
         aAdd(aResult, .T.)
         aAdd(aTemp, SubStr(cTemp, 1, TamSX3('CTP_MOEDA')[1]))
         aAdd(aTemp, SubStr(cTemp, 1 + TamSX3('CTP_MOEDA')[1], 8))
         aAdd(aResult, aTemp)
      ElseIf AllTrim(cVersao) == '2.000' .Or. AllTrim(cVersao) == '2.001'
         aAdd(aResult, .T.)
         aTemp := Separa(cTemp, '|')
         aAdd(aResult, aTemp)
      Else
         aAdd(aResult, .F.)
         aAdd(aResult, STR0025 + Chr(10) + STR0026) //"Versão da cotação de moeda não suportada." "As versões suportadas são: 1.000 e 2.000."
      EndIf
   EndIf
Return aResult