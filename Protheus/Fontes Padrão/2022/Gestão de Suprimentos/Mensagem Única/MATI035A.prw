#Include "PROTHEUS.CH"  
#Include "FWADAPTEREAI.CH"
#Include "FWMVCDEF.CH"
#Include "MATI035A.CH"
#include "TopConn.ch"
#include "RwMake.ch"
#Include "Tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATI035A  ºAutor  ³Microsiga           º Data ³  11/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e  º±±
±±º          ³ envio de informações do cadastro de grupo de produtos (SBM)º±±
±±º          ³ utilizando o conceito de mensagem unica.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA035                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MATI035A( cXML, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )
Local aArea		:= GetArea()
Local lRet			:= .T.
Local cXmlRet		:= ""
Local oXmlGrp		:= Nil
Local cXmlErro	:= ""
Local cXmlWarn	:= ""
Local cVersao		:= ""
Local aRet			:= {}

Default cXML			:= ""
Default nTypeTrans		:= "3"
Default cTypeMessage	:= ""
Default cVersion		:= ""
Default cTransac		:= ""
Default lEAIObj			:= .F.

If lEAIObj
	Return MATI035Json( cXML, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )
EndIf

If nTypeTrans == TRANS_RECEIVE

	If cTypeMessage == EAI_MESSAGE_BUSINESS .Or. cTypeMessage == EAI_MESSAGE_RESPONSE

		oXmlGrp := XmlParser( cXml, '_', @cXmlErro, @cXmlWarn)
		If oXmlGrp <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
			// Versão da mensagem
			If ValType("oXmlGrp:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXmlGrp:_TOTVSMessage:_MessageInformation:_version:Text)
				cVersao := StrTokArr(oXmlGrp:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
			Else
				lRet    := .F.
				cXmlRet := STR0001 //"Versão da mensagem não informada!"
				Return {lRet, cXmlRet}
			EndIf
		Else
			lRet    := .F.
			cXmlRet := STR0002 //"Erro no parser!"
			Return {lRet, cXmlRet}
		EndIf

		If cVersao == "1"
			aRet := v1000( cXML, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj, oXmlGrp )
		Else
			lRet    := .F.
			cXmlRet := STR0003 //"A versão da mensagem informada não foi implementada!"
			Return {lRet, cXmlRet}
		EndIf

	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
		aRet := v1000( cXML, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj, oXmlGrp )
	Endif

ElseIf nTypeTrans == TRANS_SEND //Tratamento do envio de mensagens
	If Empty( cVersion )
		lRet    := .F.
		cXmlRet := STR0004 //"Versão não informada no cadastro do adapter."
		Return {lRet, cXmlRet}
	Else
		cVersao := StrTokArr( cVersion , ".")[1]
	EndIf

	If cVersao == "1"
		aRet := v1000( cXML, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj, oXmlGrp )
	Else
		lRet    := .F.
		cXmlRet := STR0003 //"A versão da mensagem informada não foi implementada!"
		Return {lRet, cXmlRet}
	EndIf

EndIf

RestArea(aArea)

If Len(aRet) > 0
	lRet    := aRet[1]
	cXMLRet := aRet[2]
Endif

Return { lRet, cXMLRet }

Static Function v1000( cXML, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj, oXmlGrp )

Local lRet 		:= .T.
Local cXMLRet		:= ""
Local cEvento		:= "upsert"
Local cXmlErro	:= ""
Local cXmlWarn	:= "" 
Local oXmlBusin	:= NIL
Local cValExt		:= "" //Codigo externo utilizada no De/Para de codigos - Tabela XXF
Local cValInt		:= "" //Codigo interno utilizado no De/Para de codigos - Tabela XXF
Local cAlias		:= "SBM"
Local cCampo		:= 'BM_GRUPO'
Local cMarca		:= ""
Local cError		:= ""
Local nCount		:= 0
Local aRet			:= {}

If ( Type("Inclui") == "U" )
	Private Inclui := .F.
EndIf
If ( Type("Altera") == "U" )
	Private Altera := .F.
EndIf

DbSelectArea("SBM")
SBM->(DbSetOrder(1))

If ( nTypeTrans == TRANS_RECEIVE ) //Tratamento do recebimento de mensagens

	If ( cTypeMessage == EAI_MESSAGE_BUSINESS ) //Business Message
		// Verifica se a marca foi informada
		If ValType("oXmlGrp:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. !Empty(oXmlGrp:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
			cMarca := oXmlGrp:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		Else
			lRet    := .F.
			cXmlRet := STR0006 //"Erro no retorno. O Product é obrigatório!"
			Return {lRet, cXmlRet}
		EndIf
		
    	oModel 	:= FwLoadModel('MATA035')
		oXmlBusin	:= oXMlGrp:_TotvsMessage:_BusinessMessage
	 	
	 	If XmlChildEx(oXmlBusin, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent, '_EVENT' ) <> Nil
	 		cEvento := oXmlBusin:_BusinessEvent:_Event:Text		
		 	
		 	// InternalId
			If ValType("oXmlGrp:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_INTERNALID:Text") == "C" .And. !Empty(oXmlGrp:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
				cValExt := oXmlGrp:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
       		
	   			aRet := IntStockInt(cValExt, cMarca, "1.000")
	   			
	   			If !aRet[1] .And. Upper(cEvento) == "UPSERT"
	   				Inclui := .T.
       	    	Altera := .F.
       	    	oModel:SetOperation( MODEL_OPERATION_INSERT )
       	    Elseif aRet[1] .And.	Upper(cEvento) == "UPSERT" .AND. SBM->(MsSeek(xFilial("SBM") + PadR(aRet[2,3],TamSx3("BM_GRUPO")[1])))
       	    	Altera := .T.
					Inclui := .F.
					oModel:SetOperation( MODEL_OPERATION_UPDATE )
				Elseif aRet[1] .AND. Upper(cEvento) == "DELETE" .AND. SBM->(MsSeek(xFilial("SBM") + PadR(aRet[2,3],TamSx3("BM_GRUPO")[1])))
       	   		Inclui := .F.
					Altera := .F.
					oModel:SetOperation( MODEL_OPERATION_DELETE )
			   Elseif !aRet[1]
					lRet := .F.
					cXMLRet := aRet[2]
       	   Endif
       	   
       	   If lRet
       	   		lRet := oModel:Activate()
					If lRet
						I035Oper( @lRet, @cXmlRet, @oModel, oXmlBusin, cMarca, cValExt, "1.000")
					Else
						cXmlRet := ApErroMvc( oModel )
					EndIf
				Endif
										
	 		Else
	 			lRet := .F.
				cXMLRet := STR0007 //"O código do InternalId é obrigatório!"	
	 		EndIf
	 	Else
        	lRet := .F.
			cXmlRet := STR0008 //"Tag de operação 'Event' inexistente"		 	
	 	EndIf
	
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE //Response Message
		oXML	:= XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
		
		If oXML <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
			// Se não houve erros na resposta
			If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
				
				// Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
					cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet    := .F.
					cXmlRet := STR0006 //"Erro no retorno. O Product é obrigatório!"
					Return {lRet, cXmlRet}
				EndIf
				
				If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") != "U" 
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
						cXmlRet := STR0009 //"Erro no retorno. O OriginalInternalId é obrigatório!"
						Return {lRet, cXmlRet}
					EndIf
					
					// Verifica se o código externo foi informado
					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text)
						cValExt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text
					Else
						lRet    := .F.
						cXmlRet := STR0010 //"Erro no retorno. O DestinationInternalId é obrigatório!"
						Return {lRet, cXmlRet}
					EndIf
					
					// Obtém a mensagem original enviada
	            	If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
	              	cXML := Alltrim(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
	            	Else
	              	lRet    := .F.
	               	cXmlRet := STR0011 //"Conteúdo do MessageContent vazio!"
	               	Return {lRet, cXmlRet}
	            	EndIf
					
					oXML := XmlParser( cXML, '_', @cXmlErro, @cXmlWarn) // Faz o parse do XML em um objeto
					
					If oXML != Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn) // Se não houve erros no parse
						
						If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
							CFGA070Mnt(cProduct, cAlias, cCampo, cValExt, cValInt, .F.)// Insere / Atualiza o registro na tabela XXF (de/para)
						ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
							CFGA070Mnt(cProduct, cAlias, cCampo, cValExt, cValInt, .T.)// Exclui o registro na tabela XXF (de/para)
						Else
							lRet := .F.
							cXmlRet := STR0012 //"Evento do retorno inválido!"
						EndIf
					Else
						lRet := .F.
						cXmlRet := STR0013 //"Erro no parser do retorno!"
						Return {lRet, cXmlRet}
					EndIf
				Endif
			Else
				// Se não for array
				If ValType("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
					// Transforma em array
					XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
				EndIf
            	// Percorre o array para obter os erros gerados
				For nCount := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)	
					cError += oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + Chr(10)
				Next nCount
				lRet := .F.
				cXmlRet := cError
			EndIf
		EndIf
	
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS //WhoIs Message
		cXMLRet := '1.000'
	EndIf

ElseIf nTypeTrans == TRANS_SEND //Tratamento do envio de mensagens	
	
	//Verifica se é uma exclusão
	If !Inclui .And. !Altera
		cEvento := 'delete'
		
		//Exclui de/para
		CFGA070Mnt(,"SBM","BM_GRUPO",,IntStockExt(,,RTrim(SBM->BM_GRUPO),"1.000")[2],.T.)
	EndIf
	
	//Monta XML de envio de mensagem unica
	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>StockGroup</Entity>'
	cXMLRet +=     '<Event>' + cEvento + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="Code">' + RTrim(SBM->BM_GRUPO) + '</key>'
	cXMLRet +=     '</Identification>'	
	cXMLRet += '</BusinessEvent>'
	
	cXMLRet += '<BusinessContent>'
	cXMLRet += 	'<CompanyId>' + cEmpAnt + '</CompanyId>'
	cXMLRet += 	'<BranchId>' + RTrim(xFilial("SBM")) + '</BranchId>'       
	cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + RTrim(cFilAnt) + '</CompanyInternalId>'                
	cXMLRet +=    '<Code>' + RTrim(SBM->BM_GRUPO) + '</Code>'
	cXMLRet +=    '<InternalId>' + IntStockExt(,,RTrim(SBM->BM_GRUPO),"1.000")[2] + '</InternalId>'
	cXMLRet +=    '<Description>' + _NoTags(AllTrim(SBM->BM_DESC)) + '</Description>'
	cXMLRet +=    '<FamilyType>' + RTrim(SBM->BM_TIPGRU) + '</FamilyType>'
	cXMLRet +=    '<FamilyClassificationCode>' + RTrim(SBM->BM_CLASGRU) + '</FamilyClassificationCode>'
	cXMLRet += '</BusinessContent>'

EndIf

Return { lRet, cXMLRet }


//-------------------------------------------------------------------
/*/{Protheus.doc} I035Oper
Rotina para integração por EAI 

@since 05/11/2012
@version P11
@params	lStatus    - indicação do status do processamento [Referencia]
@params	cXmlStatus - conteúdo de retorno [Referencia]
@params	oMdlOper   - modelo de dados para rotina automática [Referencia]
@params	oXmlOper   - conteúdo para processamento
@params	cMarca     - sistema com o qual a integração está sendo realizada
@params	cValExtern - chave do registro na aplicação de origem da mensagem
@return	Posicao 1  - LOGICAL - indica o status do processamento
@return	Posicao 2  - CHAR    - Xml/Conteúdo de retorno do processamento
/*/
//-------------------------------------------------------------------
Static Function I035Oper( lStatus, cXmlStatus, oMdlOper, oXmlOper, cMarca, cValExtern, cVersao ) 

Local oMdlCab   := oMdlOper:GetModel('MATA035_SBM')
Local lDeleta   := oMdlOper:GetOperation()==MODEL_OPERATION_DELETE
Local cIntVal   := ""
Local aRet		  := {}

Default cVersao := "1.000"
                     
If Inclui
	SBM->(dbSetOrder(1))

	If XmlChildEx(oXmlOper,'_BUSINESSCONTENT') <> NIL .And. XmlChildEx(oXmlOper:_BusinessContent,"_CODE") <> NIL
		cIntVal := PadR(oXmlOper:_BusinessContent:_Code:Text,Len(SBM->BM_GRUPO))
	Else
		lStatus := .F.
		cXmlStatus := "Tag Code não informada."
		
		Return { lStatus, cXmlStatus}
	EndIf
	
	If Empty(cIntVal) .Or. SBM->(dbSeek(xFilial("SBM")+cIntVal))
		If Empty(cIntVal := CriaVar("BM_GRUPO",.T.))
			cIntVal := NextNumero("SBM",1,"BM_GRUPO",.T.)
		EndIf
	EndIf
Else
	If cVersao == "1.000"
		cIntVal := IntStockInt(cValExtern, cMarca, "1.000")[2,3]
	Endif
EndIf

If !lDeleta

	If XmlChildEx(oXmlOper, '_BUSINESSCONTENT') <> Nil
	    
		If lStatus 
			lStatus := oMdlCab:SetValue('BM_LENREL', 1)
		EndIf

		If lStatus .And. !Empty(cIntVal) .And. !Empty(cValExtern) .And. Inclui
			lStatus := oMdlCab:SetValue('BM_GRUPO', cIntVal )   
		EndIf
		
		If lStatus .And. XmlChildEx(oXmlOper:_BusinessContent, '_DESCRIPTION') <> Nil 
			lStatus := oMdlCab:SetValue('BM_DESC', oXmlOper:_BusinessContent:_Description:Text)
		EndIf
		
		If lStatus .And. XmlChildEx(oXmlOper:_BusinessContent, '_FAMILYCLASSIFICATIONCODE') <> Nil
			lStatus := oMdlCab:SetValue('BM_TIPGRU', oXmlOper:_BusinessContent:_FamilyClassificationCode:Text)
		EndIf
		
	Else
		lStatus := .F.
		cXmlStatus := STR0014 //"Estrutura invalida, tag 'BusinessContent' não existe"
	EndIf

EndIf

lStatus := lStatus .And. oMdlOper:VldData()

If cVersao == "1.000"
	aRet := IntStockExt(,,cIntVal,"1.000")
Endif

If aRet[1]
	cIntVal := aRet[2]
Else
	lStatus := .F.
Endif		

If lStatus

	oMdlOper:CommitData()                         
		
	cXmlStatus := '<ListOfInternalId>'
	cXmlStatus += 	'<InternalId>'
	cXmlStatus += 		'<Name>StockGroup</Name>'
	cXmlStatus += 		'<Origin>'+ cValExtern +'</Origin>'
	cXmlStatus += 		'<Destination>'+ cIntVal +'</Destination>'
	cXmlStatus += 	'</InternalId>'
	cXmlStatus += '</ListOfInternalId>'
	
	//De/Para
	If lDeleta
		CFGA070Mnt(cMarca, 'SBM', 'BM_GRUPO', cValExtern, cIntVal, .T.)
	ElseIf Inclui
		CFGA070Mnt(cMarca, 'SBM', 'BM_GRUPO', cValExtern, cIntVal, .F.)
	EndIf
	
Else
	If !aRet[1]
		cXmlStatus := aRet[2]
	Else
		//  Identificar erro do modelo para retorno
		cXmlStatus := ApErroMvc( oMdlOper )
	Endif
EndIf

Return { lStatus, cXmlStatus}

/*/{Protheus.doc} IntStockExt
Monta o internalId do StockGroup

@since 03/11/14
@version P11

@params	cEmpresa	- Empresa utilizado na integração
@params	cFil		- Filial utilizada na integração
@params	cFamily	- Código do grupo de produto
@params	cVersao	- Versão da mensagem utilizada

@return	Posicao 1  - LOGICAL - indica o status do processamento
@return	Posicao 2  - CHAR    - Xml/Conteúdo de retorno do processamento
/*/

Function IntStockExt(cEmpresa,cFil,cStockGroup,cVersao)

Local   aResult  := {}

Default cEmpresa := cEmpAnt
Default cFil     := xFilial('SBM')
Default cVersao  := '1.000'

If cVersao == '1.000'
	aAdd(aResult, .T.)
	aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cStockGroup))
Else
	aAdd(aResult, .F.)
	aAdd(aResult, STR0015 + Chr(10) + STR0016 + " 1.000") //"Versão do grupo de produto não suportada."--"As versões suportadas são:"  
EndIf
Return aResult

/*/{Protheus.doc} IntStockInt
Busca o internalId do StockGroup

@since 03/11/14
@version P11

@params	cInternalId	- InternalId a ser pesquisado
@params	cRefer			- Marca
@params	cVersao		- Versão da mensagem utilizada

@return	Posicao 1  - LOGICAL - indica o status do processamento
@return	Posicao 2  - CHAR    - Xml/Conteúdo de retorno do processamento
/*/

Function IntStockInt(cInternalID, cRefer, cVersao)

Local   aResult  := {}
Local   aTemp    := {}
Local   cTemp    := ''
Local   cAlias   := 'SBM'
Local   cField   := 'BM_GRUPO'

Default cVersao  := '1.000'

cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
   
If Empty(cTemp)
	aAdd(aResult, .F.)
	aAdd(aResult, STR0017) //"Grupo de produto não encontrado no de/para!"
Else
	If cVersao == '1.000'
		aAdd(aResult, .T.)
		aTemp := Separa(cTemp, '|')
		aAdd(aResult,aTemp)
	Else
		aAdd(aResult,.F.)
		aAdd(aResult, STR0015 + Chr(10) + STR0016 + " 1.000") //"Versão do grupo de produto não suportada." --- "As versões suportadas são:" 
	EndIf
EndIf

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} ApErroMvc
Apura o erro do mvc retornando uma string 

@since 06/11/2012
@version P11
@params	oModel     - modelo de dados para rotina automática
@return	cErro      - erro apurado no modelo
/*/
//-------------------------------------------------------------------
Static Function ApErroMvc( oModel )

Local cErro  := ' '
Local aErros := oModel:GetErrorMessage()
Local nX     := 0 

For nX := 1 To Len(aErros)
	If Valtype(aErros[nX])=='C'
		cErro += StrTran(StrTran(StrTran(StrTran(aErros[nX],"<",""),"-",""),">",""),"/", "") + ("|")
	EndIf
Next nX

Return cErro
