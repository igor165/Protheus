#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integra��o com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC
#Include 'OMSI010.CH'

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
��� Funcao   � OMSI010     � Autor � Danilo Dias       � Data � 04/04/2012  ���
���������������������������������������������������������������������������͹��
��� Desc.    � Funcao para processamento de mensagem unica.                 ���
���������������������������������������������������������������������������͹��
��� Param.   � cXML - Variavel com conteudo xml para envio/recebimento.     ���
���          � nTypeTrans - Tipo de transacao. (Envio/Recebimento)          ���
���          � cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) ���
���������������������������������������������������������������������������͹��
��� Retorno  � aRet - Array contendo o resultado da execucao e a mensagem   ���
���          �        Xml de retorno.                                       ���
���          � aRet[1] - (boolean) Indica o resultado da execu��o da fun��o ���
���          � aRet[2] - (caracter) Mensagem Xml para envio                 ���
���������������������������������������������������������������������������͹��
��� Uso      � OSMA010 (IntegDef())                                         ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} OMSI010
Fun��o para processamento de mensagem �nica da Tabela de pre�os.
Uso: OMSA010

@sample 	OMSI010( cXML, nTypeTrans, cTypeMessage)
@param		cXML - Variavel com conteudo xml para envio/recebimento.
			nTypeTrans - Tipo de transacao. (Envio/Recebimento)
			cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, Request)
@return	aRet - Array contendo o resultado da execu��o e o xml de retorno.
			aRet[1] - (boolean) Indica o resultado da execu��o da fun��o.
			aRet[2] - (caracter) Mensagem Xml para envio.
@author	Danilo Dias
@since		11/04/2012
@version	P11 R6
/*/
//-------------------------------------------------------------------
Function OMSI010( cXML, nTypeTrans, cTypeMessage )

Local lRet 			:= .T.				//Indica o resultado da execu��o da fun��o
Local cXMLRet		:= ''				//Xml que ser� enviado pela fun��o
Local cError		:= ''				//Mensagem de erro do parse no xml recebido como par�metro
Local cWarning		:= ''				//Mensagem de alerta do parse no xml recebido como par�metro
Local oXML 			:= Nil				//Objeto com o conte�do do arquivo Xml
Local cVersao		:=	""				//Indica a versao da mensagem        
Local aRet			:= {.T.,""} 		//Array de retorno da execucao da versao

Default cXml 			:= ""
Default nTypeTrans 		:= 0
Default cTypeMessage 	:= ""

If ( nTypeTrans == TRANS_RECEIVE )

	If ( cTypeMessage == EAI_MESSAGE_BUSINESS ) .Or. ( cTypeMessage == EAI_MESSAGE_RESPONSE )
				
		oXML := XmlParser( cXML, '_', @cError, @cWarning )	
		
		If ( ( oXML <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) )
				
			// Vers�o da mensagem
	        If Type("oXML:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXML:_TOTVSMessage:_MessageInformation:_version:Text)
	        	cVersao := StrTokArr(oXML:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
	           
	            //Faz chamada da vers�o especifica   
	           	If cVersao == "1"
		            aRet := v1000(cXml, nTypeTrans, cTypeMessage, oXML)
		        ElseIf cVersao == "2"
		        	aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXML)
		        Else
		            lRet    := .F.
		            cXmlRet := STR0006 //"A vers�o da mensagem n�o foi informada ou n�o foi implementada!"
		            aRet := { lRet , cXMLRet }
		        EndIf
	           
	        Else
	           lRet := .F.
	           cXmlRet := STR0007 // "Vers�o da mensagem n�o informada!"
	           aRet := { lRet , cXMLRet }
	        EndIf			
		
		Else
			//Tratamento no erro do parse Xml
			lRet := .F.
			cXMLRet := STR0002	//'Erro na manipula��o do Xml recebido. 
			cXMLRet += IIf ( !Empty(cError), cError, cWarning )		
			cXMLRet := EncodeUTF8(cXMLRet)		
			aRet := { lRet , cXMLRet }
		EndIf
	
	//Recebimento da WhoIs 
	ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )		
		cXMLRet := '1.000|2.000|2.001'
		aRet := { lRet , cXMLRet }
	EndIf																		
	
ElseIf ( nTypeTrans == TRANS_SEND )//Trata o envio de mensagem

	cVersao := StrTokArr(RTrim(PmsMsgUVer('PRICELISTHEADERITEM','OMSA010')), ".")[1]
	
    //Faz chamada da vers�o especifica   
   	If cVersao == "1"
        aRet := v1000(cXml, nTypeTrans, cTypeMessage, oXML)
    ElseIf cVersao == "2"
    	aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXML)
    Else
        lRet    := .F.
        cXmlRet := STR0006 //"A vers�o da mensagem n�o foi informada ou n�o foi implementada!"
        aRet := { lRet , cXMLRet }
    EndIf
 
EndIf

Return {aRet[1], aRet[2],"PriceListHeaderItem"}

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
��� Funcao   � UpdateData  � Autor � Danilo Dias       � Data � 11/04/2012  ���
���������������������������������������������������������������������������͹��
��� Desc.    � Funcao para atualizacao do model conforme dados recebidos.   ���
���������������������������������������������������������������������������͹��
��� Param.   � oModel - Modelo de dados                                     ���
���          � aHeader - Dados da Master (DA0)                              ���
���          � aItens - Dados da Detail (DA1)                               ���
���������������������������������������������������������������������������͹��
��� Retorno  � lRet - Indica se execucao foi bem sucedida.                  ���
���������������������������������������������������������������������������͹��
��� Uso      � OSMI010                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateData 
Fun��o para atualiza��o do model conforme dados recebidos via mensagem �nica.
Uso: OSMI010

@sample 	UpdateData( oModel, aHeader, aItens )
@param		oModel - Modelo de dados a ser alterado (Passado por refer�ncia).
			aHeader - Dados da master (DA0).
			aItens - Dados da detail (DA1).
@return	lRet - Inidica se a execu��o foi bem sucedida
@author	Danilo Dias
@since		11/04/2012
@version	P11 R6
/*/
//-------------------------------------------------------------------
Static Function UpdateData( aHeader, aItens )

//Variaveis de Prote��o
Local aSaveLine	:= FWSaveRows()	//Salva contexto do model ativo

//Vari�veis da fun��o
Local lRet		:= .T.		//Retorno da fun��o
Local nI		:= 0		//Contador de uso geral
Local nL		:= 0		//Contador de uso geral
Local nCodPro	:= 0		//Posi��o do C�digo de Produto no array de itens
Local aBusca	:= {}		//Array para busca do item no Model
Local cEvent	:= ''		//Evento do Item (upsert/delete)
Local lExiste	:= .F.		//Indica se existe o item no Model

//Atualiza Master (DA0)
For nI := 1 To Len(aHeader)
	oModelDA0:SetValue( aHeader[nI][1], aHeader[nI][2] )
Next nI
	
//Atualiza Detail (DA1)
For nI := 1 To Len(aItens)
   
	nCodPro 	:= aScan( aItens[nI], { |nLinha| nLinha[1] == 'DA1_CODPRO' } )	//Posicao do Cod. Produto no array
	cEvent		:= Upper(aItens[nI][Len(aItens[nI])][2])	//Operacao realizada no item
	
	//Monta array para busca do item no Model
	aBusca := {}
	aAdd( aBusca, { 'DA1_CODPRO', aItens[nI][nCodPro][2] } )	
	
	//Busca a linha na Detail de acordo com os dados do array aBusca	
	lExiste := oModelDA1:SeekLine( aBusca )
		
	//Verifica a opera��o sobre o item	
	If ( cEvent == 'DELETE' )
		If ( lExiste )
			//Se o item foi excluido na origem e existe no destino, exclui do model
			oModelDA1:DeleteLine()
		EndIf
	Else
		//Se n�o existir o registro na detail adiciona linha
		If ( !lExiste )
			//Verifica se j� existe linha em branco na detail antes de incluir
			If ( !oModelDA1:IsEmpty() )
				nAux := oModelDA1:Length()
				If ( !oModelDA1:AddLine() == nAux + 1 )
				     Loop
				EndIf
			EndIf
		EndIf
		
		//Atualiza itens do model com os dados recebidos
		For nL := 1 To Len(aItens[nI])-1
			oModelDA1:SetValue( aItens[nI][nL][1], aItens[nI][nL][2] )
		Next nL			
	EndIf				
Next nI

FWRestRows( aSaveLine )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} V1000
Funcao de integracao com o adapter EAI para envio e recebimento da
tabela de pre�os utilizando o conceito de mensagem unica.
@type function
@param Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param Num�rico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)
@param Objeto, oXml, Objeto xml com a mensagem recebida.

@author rafael.pessoa
@version P12
@since 19/02/2018
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
		aRet[1] - (boolean) Indica o resultado da execu��o da fun��o
		aRet[2] - (caracter) Mensagem Xml para envio
/*/
//-------------------------------------------------------------------
Static Function v1000(cXml, nTypeTrans, cTypeMessage, oXml)


Local aArea			:= GetArea()		//Salva contexto do alias atual  
Local aAreaDA0		:= DA0->(GetArea())	//Salva contexto do alias DA0
Local aSaveLine		:= FWSaveRows()		//Salva contexto do model ativo
Local lRet 			:= .T.				//Indica o resultado da execu��o da fun��o
Local cXMLRet		:= ''				//Xml que ser� enviado pela fun��o
Local cError		:= ''				//Mensagem de erro do parse no xml recebido como par�metro
Local cWarning		:= ''				//Mensagem de alerta do parse no xml recebido como par�metro
Local cEvent		:= 'upsert'			//Opera��o realizada na master e na detail ( upsert ou delete )
Local cDataDe		:= ''				//Data inicial da tabela de pre�os
Local cDataAte		:= ''				//Data final da tabela de pre�os
Local cDataVig		:= ''				//Data de vig�ncia do item na tabela de pre�os
Local nI			:= 0				//Contador de uso geral
Local nLen			:= 0				//Quantidade de itens da Tabela de Pre�o
Local nControl		:= 0				//Contador
Local cCodTab		:= ''				//Codigo da tabela de pre�os
Local aHeader		:= {}				//Dados da Master
Local aItens		:= {}				//Dados da Detail
Local aMsgErro		:= {}				//Mensagem de erro na grava��o do Model				
Local cLogErro		:= ''				//Log de erro da execu��o da rotina
Local oXMLEvent		:= Nil				//Objeto com o conte�do da BusinessEvent apenas
Local oXMLContent	:= Nil				//Objeto com o conte�do da BusinessContent apenas
Local cMarca		:=	""				//Indica a marca integrada
Local lCargaIni		:= .F.				//Controla chamada de carga inicial

Private oModel 		:= Nil 				//Objeto com o model da tabela de pre�os
Private oModelDA0	:= Nil				//Objeto com o model da master apenas
Private oModelDA1	:= Nil				//Objeto com o model da detail apenas           

Default cXml 			:= ""
Default nTypeTrans 		:= 0
Default cTypeMessage 	:= ""
Default oXml 			:= ""

// Trata o recebimento de mensagem 
If ( nTypeTrans == TRANS_RECEIVE )
	
	// Recebimento da Business Message
	If ( cTypeMessage == EAI_MESSAGE_BUSINESS )
	
		oXMLEvent 		:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent
		oXMLContent 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent
		
		//Guarda o c�digo da tabela recebido na mensagem.
		//Para utiliza��o com De/Para, altere o c�digo aqui para pegar o codigo da tabela XX5
		If ( XmlChildEx( oXMLContent, '_CODE' ) != Nil )
			cCodTab := oXMLContent:_Code:Text
		EndIf
	
		//Carrega model com estrutura da Tabela de Pre�os
		oModel := FwLoadModel( 'OMSA010' )		
		
		//Posiciona tabela DA0
		dbSelectArea('DA0')
		DA0->( dbSetOrder(1) )	//Filial + Codigo da Tabela | DB0_FILIAL + DB0_CODTAB
		lRet := DA0->( dbSeek( xFilial('DA0') + cCodTab ) )
				
		//Verifica a opera��o realizada
		If ( Upper( oXMLEvent:_Event:Text ) == 'UPSERT' )
			
			If ( lRet )
				//Altera��o
				oModel:SetOperation( MODEL_OPERATION_UPDATE )
			Else
				//Inclus�o
				oModel:SetOperation( MODEL_OPERATION_INSERT )
			EndIf
			
		Else
			//Exclus�o
			oModel:SetOperation( MODEL_OPERATION_DELETE )
			If ( !lRet )
				cXMLRet := EncodeUTF8(STR0001)	//'Registro n�o encontrado!'
			EndIf
		EndIf
				
		oModel:Activate()			
		oModelDA0 := oModel:GetModel('DA0MASTER')	//Model parcial Master (DA0)
		oModelDA1 := oModel:GetModel('DA1DETAIL')	//Model parcial Detail (DA1)
		
		If ( oModel:nOperation != MODEL_OPERATION_DELETE )
		
			//Monta array com dados da tabela Master
			aAdd( aHeader, {'DA0_CODTAB', cCodTab, Nil } )			
			aAdd( aHeader, {'DA0_DESCRI', oXmlContent:_Name:Text, Nil } )			
			aAdd( aHeader, {'DA0_DATDE', CToD( oXmlContent:_InitialDate:Text ), Nil } )			
			aAdd( aHeader, {'DA0_DATATE', CToD( oXmlContent:_FinalDate:Text ), Nil } )			
			aAdd( aHeader, {'DA0_HORADE', SubStr( oXmlContent:_InitialHour:Text, 1, 5 ), Nil } )			
			aAdd( aHeader, {'DA0_HORATE', SubStr( oXmlContent:_FinalHour:Text, 1, 5 ), Nil } )
			
			If ( ValType( oXmlContent:_ItensTablePrice:_Item  ) != 'A' )
				XmlNode2Arr( oXmlContent:_ItensTablePrice:_Item, '_ITEM' )
			EndIf
			
			nLen	:= Len( oXmlContent:_ItensTablePrice:_Item )
			aItens 	:= {}
			
			//Monta array com dados da tabela detail
			For nI := 1 To nLen
			
				aAdd( aItens, {} )	
				
				aAdd( aItens[nI], { 'DA1_CODPRO', oXmlContent:_ItensTablePrice:_Item[nI]:_ItemCode:Text, Nil } )
				aAdd( aItens[nI], { 'DA1_PRCVEN', Val( oXmlContent:_ItensTablePrice:_Item[nI]:_MinimumSalesPrice:Text ), Nil  } )
				aAdd( aItens[nI], { 'DA1_VLRDES', Val( oXmlContent:_ItensTablePrice:_Item[nI]:_DiscountValue:Text ), Nil} )
				aAdd( aItens[nI], { 'DA1_PERDES', Val( oXmlContent:_ItensTablePrice:_Item[nI]:_DiscountFactor:Text ), Nil } )
				aAdd( aItens[nI], { 'DA1_DATVIG', CToD( oXmlContent:_ItensTablePrice:_Item[nI]:_ItemValidity:Text ), Nil } )
				
				//Essa linha indica a opera��o do item e deve ser sempre a ultima
				aAdd( aItens[nI], { 'Event', oXmlContent:_ItensTablePrice:_Item[nI]:_Event:Text, Nil } )
							
			Next nI
		    
		    //Atualiza model com dados recebidos 
			lRet := UpdateData( aHeader, aItens )
			
		EndIf			
		
		If ( lRet )
		
			If oModel:VldData()
				//Grava o model
				oModel:CommitData()
			Else
				//Trata erro de grava��o do model
				lRet := .F.
			    aMsgErro := oModel:GetErrorMessage()
			    cLogErro := ''
			    
			    For nI := 1 To Len(aMsgErro)
			    
			    	If ( ValType( aMsgErro[nI] ) == 'C' )
						cLogErro += aMsgErro[nI] + '|'
					EndIf 
					
				Next nI
				
				// Monta XML de Erro de execu��o da rotina automatica.
				cXMLRet := EncodeUTF8( cLogErro )
			EndIf
					
		EndIf

	//Recebimento da Response Message 
	ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )
		
		cXMLRet := '<Code>' + DA0->DA0_CODTAB + '</Code>'
		
		cMarca  := oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		oXML 	:= oXML:_TotvsMessage
		                                                   
		// Identifica se o processamento pelo parceiro ocorreu com sucesso.
		If XmlChildEx( oXML:_ResponseMessage:_ProcessingInformation, '_STATUS' ) <> Nil .And. ;
			Upper(oXML:_ResponseMessage:_ProcessingInformation:_Status:Text)=='OK'

			If XmlChildEx( oXML:_ResponseMessage:_ReturnContent, '_LISTOFINTERNALID' ) <> Nil .And. ;
				XmlChildEx( oXML:_ResponseMessage:_ReturnContent:_ListOfInternalId, '_INTERNALID') <> Nil

				If XmlChildEx( oXML:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, '_ORIGIN') <> Nil .And. ;
					XmlChildEx( oXML:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, '_DESTINATION') <> Nil .And. ;
					XmlChildEx( oXML:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, '_NAME') <> Nil .And. ;
					Upper(oXML:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_NAME:Text) == "PRICELISTHEADERITEMINTERNALID"
					 
					CFGA070Mnt( cMarca, 'DA0', 'DA0_CODTAB', ;
							oXML:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text, ;
							oXML:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text ) 
				Else
					lRet    := .F.
					cXmlRet := STR0003 //"De-Para n�o pode ser gravado a integra��o poder� ter falhas" 
				EndIf
			Else
				lRet    := .F.
				cXmlRet := STR0003 //"De-Para n�o pode ser gravado a integra��o poder� ter falhas"
			EndIf
		Else
			lRet    := .F.
			cXmlRet := STR0004 //"Processamento pela outra aplica��o n�o teve sucesso"
			
			//  Transforma estrutura das mensagens de erro em array
			// para concatenar com a mensagem de retorno
			If XmlChildEx( oXML:_ResponseMessage:_ProcessingInformation, '_LISTOFMESSAGES' ) <> Nil .And. ;
				XmlChildEx( oXML:_ResponseMessage:_ProcessingInformation:_ListOfMessages, '_MESSAGE' ) <> Nil
				
			    If ValType(XmlChildEx( oXML:_ResponseMessage:_ProcessingInformation:_ListOfMessages, '_MESSAGE' )) <> "A"
               		// Transforma em array
               		XmlNode2Arr(oXML:_ResponseMessage:_ProcessingInformation:_ListOfMessages, "_MESSAGE")
				EndIf
				
				If ValType(XmlChildEx( oXML:_ResponseMessage:_ProcessingInformation:_ListOfMessages, '_MESSAGE' )) == "A"
	            	For nI := 1 To Len(oXML:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
						cXmlRet += ' | ' + oXML:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text + Chr(10)
	            	Next nI
	            EndIf	
				
			EndIf
			
		EndIf

	EndIf


// Trata o envio de mensagem             
ElseIf ( nTypeTrans == TRANS_SEND )

	oModel 	:= FWModelActive()						//Instancia objeto com o model completo da tabela de pre�os
	oModelDA0	:= oModel:GetModel( 'DA0MASTER' )	//Instancia objeto com model da master apenas
	oModelDA1	:= oModel:GetModel( 'DA1DETAIL' )	//Instancia objeto com model da detail apenas

	//Verifica se a tabela est� sendo exclu�da
	If ( oModel:nOperation == 5 )
		cEvent := 'delete'
	EndIf
	
	//Carrega os campos data, deixando em branco se n�o tiverem sido preenchidos
	cDataDe	:= IIf( !Empty( oModelDA0:GetValue('DA0_DATDE') ), cValToChar( oModelDA0:GetValue('DA0_DATDE') ), '' )
	cDataAte	:= IIf( !Empty( oModelDA0:GetValue('DA0_DATATE') ), cValToChar( oModelDA0:GetValue('DA0_DATATE') ), '' )
	
	lCargaIni := ( IsInCallStack( 'OMSM010' ) .Or. IsInCallStack( 'CFG020ASINC' ))
	
	//Monta Business Event
	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>PriceListHeaderItem</Entity>'
	cXMLRet +=     '<Event>' + cEvent + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="InternalID">' + cEmpAnt + "|" + RTrim(xFilial("DA0")) + "|" + oModelDA0:GetValue('DA0_CODTAB') + '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'
	
	//Monta o cabe�alho da tabela de pre�os (DA0)
	cXMLRet += '<BusinessContent>'
	cXMLRet += 	'<Code>' + oModelDA0:GetValue('DA0_CODTAB') + '</Code>'
	cXMLRet += 	'<Name>' + oModelDA0:GetValue('DA0_DESCRI') + '</Name>'
	cXMLRet += 	'<InitialDate>' + cDataDe + '</InitialDate>'
	cXMLRet += 	'<FinalDate>' + cDataAte + '</FinalDate>'
	cXMLRet += 	'<InitialHour>' + oModelDA0:GetValue('DA0_HORADE') + ':00' + '</InitialHour>'
	cXMLRet += 	'<FinalHour>' + oModelDA0:GetValue('DA0_HORATE') + ':00'  +'</FinalHour>'
	cXMLRet += 	'<ItensTablePrice>'
	
	//Monta os itens da tabela de pre�os (DA1)
	For nI := 1 To oModelDA1:Length()
	
		nControl += 1
		oModelDA1:GoLine(nI)
		
		//Carrega o campo data, deixando em branco se n�o tiver sido preenchido
		cDataVig := IIf( !Empty( oModelDA1:GetValue('DA1_DATVIG') ), cValToChar( oModelDA1:GetValue('DA1_DATVIG') ), '' )
		
		//Somente adiciona o item na mensagem se ele sofreu alguma modifica��o
		//Se o item foi inserido e deletado n�o envia
		//No caso de exclus�o da tabela de pre�os, os itens n�o ser�o enviados, pois n�o sofreram altera��es
		//Se a rotina foi acionada pela carga inicial envia tudo
		If 	( oModelDA1:IsDeleted() .And. !oModelDA1:IsInserted() ) .Or.;
			( oModelDA1:IsUpdated() .And. !oModelDA1:IsDeleted() ) .Or.	lCargaIni
		
			cXMLRet += 		'<Item>'
			cXMLRet += 			'<ItemCode>' + oModelDA1:GetValue('DA1_CODPRO') + '</ItemCode>'
			cXMLRet += 			'<MinimumSalesPrice>' + cValToChar( oModelDA1:GetValue('DA1_PRCVEN') ) + '</MinimumSalesPrice>'
			cXMLRet += 			'<DiscountValue>' + cValToChar( oModelDA1:GetValue('DA1_VLRDES') ) + '</DiscountValue>'
			cXMLRet += 			'<DiscountFactor>' + cValToChar( oModelDA1:GetValue('DA1_PERDES') ) + '</DiscountFactor>'
			cXMLRet += 			'<ItemValidity>' + cDataVig + '</ItemValidity>'
			
			//Define a opera��o no item
			If ( oModelDA1:IsDeleted() )
				cXmlRet +=				'<Event>delete</Event>'
			Else
				cXmlRet +=				'<Event>upsert</Event>'
			EndIf
			
			cXMLRet += 		'</Item>'
			
		EndIf
	
		//Verifica se o Xml atingiu o tamanho maximo
		If ( ( Len(cXmlRet) / 1024 ) > MAX_FILE_LENGTH )
			Exit
		EndIf
		
	Next nI
	
	cXMLRet += 	'</ItensTablePrice>'
	cXMLRet += '</BusinessContent>'	
	
	If ( nControl > oModelDA1:Length() )
		nControl := -1
	EndIf
	
EndIf

//Restaura ambiente
FWRestRows( aSaveLine )     
RestArea(aAreaDA0)
RestArea(aArea)

Return {lRet, cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} V2000
Funcao de integracao com o adapter EAI para envio e recebimento da
tabela de pre�os utilizando o conceito de mensagem unica.
@type function
@param Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param Num�rico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)
@param Objeto, oXml, Objeto xml com a mensagem recebida.

@author rafael.pessoa
@version P12
@since 21/02/2018
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
		aRet[1] - (boolean) Indica o resultado da execu��o da fun��o
		aRet[2] - (caracter) Mensagem Xml para envio
/*/
//-------------------------------------------------------------------
Static Function v2000(cXml, nTypeTrans, cTypeMessage, oXml)


Local aArea			:= GetArea()		//Salva contexto do alias atual  
Local aAreaDA0		:= DA0->(GetArea())	//Salva contexto do alias DA0
Local aSaveLine		:= FWSaveRows()		//Salva contexto do model ativo
Local aHeader		:= {}				//Dados da Master
Local aItens		:= {}				//Dados da Detail
Local aMsgErro		:= {}				//Mensagem de erro na grava��o do Model				
Local aXmlItens		:= {}

Local cXMLRet		:= ''				//Xml que ser� enviado pela fun��o
Local cError		:= ''				//Mensagem de erro do parse no xml recebido como par�metro
Local cWarning		:= ''				//Mensagem de alerta do parse no xml recebido como par�metro
Local cEvent		:= 'upsert'			//Opera��o realizada na master e na detail ( upsert ou delete )
Local cDataDe		:= ''				//Data inicial da tabela de pre�os
Local cDataAte		:= ''				//Data final da tabela de pre�os
Local cDataVig		:= ''				//Data de vig�ncia do item na tabela de pre�os
Local cCodTab		:= ''				//Codigo da tabela de pre�os
Local cTabPrcItm	:= ''				//item da tabela de pre�o
Local cLogErro		:= ''				//Log de erro da execu��o da rotina
Local cMarca		:=	""				//Indica a marca integrada
Local cMaxItem		:= StrZero( 0, TamSx3('DA1_ITEM')[1] )
Local cFilDA0		:= xFilial('DA0')	// Filial Header
Local cFilDA1		:= xFilial('DA1')	// filial Itens

Local nI			:= 0				//Contador de uso geral
Local nLen			:= 0				//Quantidade de itens da Tabela de Pre�o
Local nControl		:= 0				//Contador
Local nR 			:= 0				//Contador erro
Local nErrSize		:= 0				//Len do array de erros
Local nLength		:= 0				//Grid de Itens
Local nOpcx 		:= 3				//Tipo de opera��o

Local lCargaIni		:= .F.				//Controla chamada de carga inicial
Local lNewItem		:= .T.				//Indica se � a primeira linha de DA1 nova durante altera��o
Local lRet 			:= .T.				//Indica o resultado da execu��o da fun��o
Local lFound		:= .F.				//Indica se encontrou o registro				
Local lTippre		:= DA1->(ColumnPos("DA1_TIPPRE") > 0)

Local oXMLEvent		:= Nil				//Objeto com o conte�do da BusinessEvent apenas
Local oXMLContent	:= Nil				//Objeto com o conte�do da BusinessContent apenas
Local oHashXML		:= Nil 				//Hash com a carga dos itens usado durante a Altera��o para determinar se o item � novo

Local oModel 		:= Nil 				//Objeto com o model da tabela de pre�os
Local oModelDA0	:= Nil				//Objeto com o model da master apenas
Local oModelDA1	:= Nil				//Objeto com o model da detail apenas           
Private lMsErroAuto	:= .F.

Default cXml 			:= ""
Default cTypeMessage 	:= ""
Default nTypeTrans 		:= 0
Default oXml 			:= ""

// Trata o recebimento de mensagem 
If ( nTypeTrans == TRANS_RECEIVE )
	
	// Recebimento da Business Message
	If ( cTypeMessage == EAI_MESSAGE_BUSINESS )
	
		oXMLEvent 		:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent
		oXMLContent 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent
		
		//Guarda o c�digo da tabela recebido na mensagem.
		//Para utiliza��o com De/Para, altere o c�digo aqui para pegar o codigo da tabela XX5
		If ( XmlChildEx( oXMLContent, '_CODE' ) != Nil )
			cCodTab := oXMLContent:_Code:Text
		EndIf		
		
		//Posiciona tabela DA0
		DbSelectArea('DA0')
		DA0->( dbSetOrder(1) )	//Filial + Codigo da Tabela | DB0_FILIAL + DB0_CODTAB
		lFound := DA0->( MSSeek( cFilDA0 + cCodTab ) )
				
		//Verifica a opera��o realizada
		If ( Upper( oXMLEvent:_Event:Text ) == 'UPSERT' )
			
			If ( lFound )
				nOpcx := 4
				
				//Em caso de altera��o, grava os itens j� gravados para uso posterior
				oModel 		:= FwLoadModel( 'OMSA010')
				oModelDA1 	:= oModel:GetModel('DA1DETAIL')
				oModel:Activate()
				nLength 	:= oModelDA1:Length()
				oModelDA1:SeekLine( {{'DA1_CODTAB', cCodTab}} )
				
				//Hash com a lista de itens da DA1 que j� existem na base
				oHashXML := THashMap():New() 

				For nI := 1 To nLength
					oModelDA1:GoLine(nI)
					oHashXML:Set( Alltrim(oModelDA1:GetValue('DA1_CODPRO')) + DtoC(oModelDA1:GetValue('DA1_DATVIG') ), { oModelDA1:GetValue('DA1_ITEM') }  )
					If nI == nLength
						cMaxItem := oModelDA1:GetValue('DA1_ITEM')
					EndIf
					
				Next nI
			EndIf
			
		Else
			//Exclus�o
			If ( !lFound )
				cXMLRet := EncodeUTF8(STR0001)	//'Registro n�o encontrado!'
				lRet := .F.
			Else
				nOpcx := 5
			EndIf
		EndIf
		
		If lRet 
			//Monta array com dados da tabela Master
			aAdd( aHeader, {'DA0_CODTAB', cCodTab, Nil } )			
			aAdd( aHeader, {'DA0_DESCRI', oXmlContent:_Name:Text, Nil } )			
			aAdd( aHeader, {'DA0_DATDE', CToD( oXmlContent:_InitialDate:Text ), Nil } )			
			aAdd( aHeader, {'DA0_DATATE', CToD( oXmlContent:_FinalDate:Text ), Nil } )			
			aAdd( aHeader, {'DA0_HORADE', SubStr( oXmlContent:_InitialHour:Text, 1, 5 ), Nil } )			
			aAdd( aHeader, {'DA0_HORATE', SubStr( oXmlContent:_FinalHour:Text, 1, 5 ), Nil } )
			
			If ( XmlChildEx( oXmlContent, '_ACTIVETABLEPRICE' ) != Nil)
				aAdd( aHeader, {'DA0_ATIVO',  oXmlContent:_ActiveTablePrice:Text, Nil } )
			EndIf
			
			If ( XmlChildEx( oXmlContent, '_ITENSTABLEPRICE' ) != Nil .And. XmlChildEx( oXmlContent:_ItensTablePrice, '_ITEM' ) != Nil )
				If ( ValType( oXmlContent:_ItensTablePrice:_Item  ) != 'A' )
					XmlNode2Arr( oXmlContent:_ItensTablePrice:_Item, '_ITEM' )
				EndIf
				nLen := IIf( ValType( oXmlContent:_ItensTablePrice:_Item  ) == 'A' , Len( oXmlContent:_ItensTablePrice:_Item ), 0 ) 
			Else
				nLen := 0
			EndIf
			
			aItens 	:= {}
			
			//Monta array com dados da tabela detail
			For nI := 1 To nLen
				If ( XmlChildEx( oXmlContent:_ItensTablePrice:_Item[nI], '_ITEMCODE' ) == Nil )
					Exit
				EndIf

				aAdd( aItens, {} )	
				aAdd( aItens[nI], { 'DA1_FILIAL', cFilDA1 , Nil } )

				aAdd( aItens[nI], { 'DA1_CODPRO', oXmlContent:_ItensTablePrice:_Item[nI]:_ItemCode:Text, Nil } )
				aAdd( aItens[nI], { 'DA1_PRCVEN', Val( oXmlContent:_ItensTablePrice:_Item[nI]:_MinimumSalesPrice:Text ), Nil  } )
				aAdd( aItens[nI], { 'DA1_VLRDES', Val( oXmlContent:_ItensTablePrice:_Item[nI]:_DiscountValue:Text ), Nil} )
				aAdd( aItens[nI], { 'DA1_PERDES', Val( oXmlContent:_ItensTablePrice:_Item[nI]:_DiscountFactor:Text ), Nil } )
				aAdd( aItens[nI], { 'DA1_DATVIG', CToD( oXmlContent:_ItensTablePrice:_Item[nI]:_ItemValidity:Text ), Nil } )
				
				If ( XmlChildEx( oXmlContent:_ItensTablePrice:_Item[nI], '_ACTIVEITEMPRICE' ) != Nil)
					aAdd( aItens[nI], { 'DA1_ATIVO', oXmlContent:_ItensTablePrice:_Item[nI]:_ActiveItemPrice:Text, Nil } )  
				EndIf                                 
				
				If nOpcx == 4 .And. oHashXML:Get( Alltrim(aItens[nI][2][2] ) + DtoC(aItens[nI][6][2]), @aXmlItens )// Ligar integra��o loja.AND. aXmlItens[1,3] == aItens[nI][1] 
					aAdd( aItens[nI], { 'LINPOS','DA1_ITEM', aXmlItens[1] } )
				
				ElseIf nOpcx <> 5
					If lNewItem
						cTabPrcItm := Soma1( cMaxItem )
						lNewItem := .F.
					Else
						cTabPrcItm := Soma1(cTabPrcItm)
					EndIf

					aAdd( aItens[nI], { 'DA1_ITEM', cTabPrcItm, Nil } )
				EndIf
				
				If ( XmlChildEx( oXmlContent:_ItensTablePrice:_Item[nI], '_TYPEPRICE' ) != Nil)
					If lTippre
						aAdd( aItens[nI], { 'DA1_TIPPRE', oXmlContent:_ItensTablePrice:_Item[nI]:_TypePrice:Text, Nil } )
					EndIf
				EndIf
				
				//Durante Update, permite deletar Linhas marcadas como <Item><Event>delete</Event></Item>
				If nOpcx == 4 .And. Upper(oXmlContent:_ItensTablePrice:_Item[nI]:_Event:Text) == 'DELETE'
					aAdd( aItens[nI], { 'AUTDELETA', 'S', Nil } )
				EndIf

			Next nI

			If nOpcx == 4
				oModel:DeActivate()
				oModel:Destroy()
				oHashXML:Clean()
			EndIf
			
			//Atualiza model com dados recebidos 
			MSExecAuto({|x, y, z| OMSA010(x, y, z)}, aHeader, aItens, nOpcx)
			
			If lMsErroAuto
				aMsgErro := GetAutoGRLog()
				nErrSize := Len(aMsgErro)
				lRet := .F.
				
				For nR := 1 To nErrSize
					cLogErro += StrTran( StrTran( aMsgErro[nR], "<", "" ), "-", "" ) + (" ") 
				Next nCount

				cXMLRet := EncodeUTF8( cLogErro )		
				//Monta XML de Erro de execu��o da rotina automatica.
				DisarmTransaction()
				MsUnlockAll()
			
			Else
				cXMLRet := STR0008 //'opera��o realizado com sucesso!'
			EndIf
		EndIf		
	//Recebimento da Response Message 
	ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )
				
		cXMLRet := '<Code>' + DA0->DA0_CODTAB + '</Code>'
		
		cMarca  := oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		oXML 	:= oXML:_TotvsMessage
		                                                   
		// Identifica se o processamento pelo parceiro ocorreu com sucesso.
		If XmlChildEx( oXML:_ResponseMessage:_ProcessingInformation, '_STATUS' ) <> Nil .And. ;
			Upper(oXML:_ResponseMessage:_ProcessingInformation:_Status:Text)=='OK'

			If XmlChildEx( oXML:_ResponseMessage:_ReturnContent, '_LISTOFINTERNALID' ) <> Nil .And. ;
				XmlChildEx( oXML:_ResponseMessage:_ReturnContent:_ListOfInternalId, '_INTERNALID') <> Nil

				If XmlChildEx( oXML:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, '_ORIGIN') <> Nil .And. ;
					XmlChildEx( oXML:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, '_DESTINATION') <> Nil .And. ;
					XmlChildEx( oXML:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, '_NAME') <> Nil .And. ;
					Upper(oXML:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_NAME:Text) == "PRICELISTHEADERITEMINTERNALID"
					 
					CFGA070Mnt( cMarca, 'DA0', 'DA0_CODTAB', ;
							oXML:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text, ;
							oXML:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text ) 
				Else
					lRet    := .F.
					cXmlRet := STR0003 //"De-Para n�o pode ser gravado a integra��o poder� ter falhas" 
				EndIf
			Else
				lRet    := .F.
				cXmlRet := STR0003 //"De-Para n�o pode ser gravado a integra��o poder� ter falhas"
			EndIf
		Else
			lRet    := .F.
			cXmlRet := STR0004 //"Processamento pela outra aplica��o n�o teve sucesso"
			
			//  Transforma estrutura das mensagens de erro em array
			// para concatenar com a mensagem de retorno
			If XmlChildEx( oXML:_ResponseMessage:_ProcessingInformation, '_LISTOFMESSAGES' ) <> Nil .And. ;
				XmlChildEx( oXML:_ResponseMessage:_ProcessingInformation:_ListOfMessages, '_MESSAGE' ) <> Nil
				
			    If ValType(XmlChildEx( oXML:_ResponseMessage:_ProcessingInformation:_ListOfMessages, '_MESSAGE' )) <> "A"
               		// Transforma em array
               		XmlNode2Arr(oXML:_ResponseMessage:_ProcessingInformation:_ListOfMessages, "_MESSAGE")
				EndIf
				
				If ValType(XmlChildEx( oXML:_ResponseMessage:_ProcessingInformation:_ListOfMessages, '_MESSAGE' )) == "A"
	            	For nI := 1 To Len(oXML:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
						cXmlRet += ' | ' + oXML:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text + Chr(10)
	            	Next nI
	            EndIf	
				
			EndIf
			
		EndIf

	EndIf


// Trata o envio de mensagem             
ElseIf ( nTypeTrans == TRANS_SEND )

	oModel 	:= FWModelActive()						//Instancia objeto com o model completo da tabela de pre�os
	oModelDA0	:= oModel:GetModel( 'DA0MASTER' )	//Instancia objeto com model da master apenas
	oModelDA1	:= oModel:GetModel( 'DA1DETAIL' )	//Instancia objeto com model da detail apenas

	//Verifica se a tabela est� sendo exclu�da
	If ( oModel:nOperation == 5 )
		cEvent := 'delete'
	EndIf
	
	//Carrega os campos data, deixando em branco se n�o tiverem sido preenchidos
	cDataDe	:= IIf( !Empty( oModelDA0:GetValue('DA0_DATDE') ), cValToChar( oModelDA0:GetValue('DA0_DATDE') ), '' )
	cDataAte	:= IIf( !Empty( oModelDA0:GetValue('DA0_DATATE') ), cValToChar( oModelDA0:GetValue('DA0_DATATE') ), '' )
	
	lCargaIni := ( IsInCallStack( 'OMSM010' ) .Or. IsInCallStack( 'CFG020ASINC' ) .Or. IsInCallStack( 'OMS010CPY' ) )
	
	//Monta Business Event
	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>PriceListHeaderItem</Entity>'
	cXMLRet +=     '<Event>' + cEvent + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="InternalID">' + cEmpAnt + "|" + RTrim(xFilial("DA0")) + "|" + oModelDA0:GetValue('DA0_CODTAB') + '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'
	
	//Monta o cabe�alho da tabela de pre�os (DA0)
	cXMLRet += '<BusinessContent>'
	cXMLRet += 	'<InternalId>' 		+ cEmpAnt + "|" + RTrim(xFilial("DA0")) + "|" + oModelDA0:GetValue('DA0_CODTAB') + '</InternalId>'
	cXMLRet += 	'<Code>' 			+ oModelDA0:GetValue('DA0_CODTAB') 	+ '</Code>'
	cXMLRet += 	'<Name>' 			+ oModelDA0:GetValue('DA0_DESCRI') 	+ '</Name>'
	cXMLRet += 	'<InitialDate>' 	+ cDataDe 							+ '</InitialDate>'
	cXMLRet += 	'<FinalDate>' 		+ cDataAte 							+ '</FinalDate>'
	cXMLRet += 	'<InitialHour>' 	+ oModelDA0:GetValue('DA0_HORADE') 	+ ':00' + '</InitialHour>'
	cXMLRet += 	'<FinalHour>' 		+ oModelDA0:GetValue('DA0_HORATE') 	+ ':00'  +'</FinalHour>'
	
	cXMLRet += 	'<ActiveTablePrice>' + oModelDA0:GetValue('DA0_ATIVO') 	+'</ActiveTablePrice>'
	
	cXMLRet += 	'<ItensTablePrice>'
	
	//Monta os itens da tabela de pre�os (DA1)
	For nI := 1 To oModelDA1:Length()
	
		nControl += 1
		oModelDA1:GoLine(nI)
		
		//Carrega o campo data, deixando em branco se n�o tiver sido preenchido
		cDataVig := IIf( !Empty( oModelDA1:GetValue('DA1_DATVIG') ), cValToChar( oModelDA1:GetValue('DA1_DATVIG') ), '' )
		
		//Somente adiciona o item na mensagem se ele sofreu alguma modifica��o
		//Se o item foi inserido e deletado n�o envia
		//No caso de exclus�o da tabela de pre�os, os itens n�o ser�o enviados, pois n�o sofreram altera��es
		//Se a rotina foi acionada pela carga inicial envia tudo
		If 	( oModelDA1:IsDeleted() .And. !oModelDA1:IsInserted() ) .Or.;
			( oModelDA1:IsUpdated() .And. !oModelDA1:IsDeleted() ) .Or.	lCargaIni
		
			cXMLRet += 		'<Item>'
			cXMLRet += 			'<ItemCode>' 			+ oModelDA1:GetValue('DA1_CODPRO') 													+ '</ItemCode>'
			cXMLRet += 			'<ItemInternalId>' 		+ cEmpAnt + "|" + RTrim(xFilial("SB1")) + "|" + oModelDA1:GetValue('DA1_CODPRO') 	+ '</ItemInternalId>'
			cXMLRet += 			'<MinimumSalesPrice>' 	+ cValToChar( oModelDA1:GetValue('DA1_PRCVEN') ) + '</MinimumSalesPrice>'
			cXMLRet += 			'<DiscountValue>' 		+ cValToChar( oModelDA1:GetValue('DA1_VLRDES') ) + '</DiscountValue>'
			cXMLRet += 			'<DiscountFactor>' 		+ cValToChar( oModelDA1:GetValue('DA1_PERDES') ) + '</DiscountFactor>'
			cXMLRet += 			'<ItemValidity>' 		+ cDataVig + '</ItemValidity>'
			cXMLRet += 			'<ActiveItemPrice>'		+ oModelDA1:GetValue('DA1_ATIVO ') 					+ '</ActiveItemPrice>'
			
			If lTippre
				cXMLRet += 			'<TypePrice>' + cValToChar( oModelDA1:GetValue('DA1_TIPPRE') )+ '</TypePrice>'
			EndIf

			//Define a opera��o no item
			If ( oModelDA1:IsDeleted() )
				cXmlRet +=				'<Event>delete</Event>'
			Else
				cXmlRet +=				'<Event>upsert</Event>'
			EndIf
			
			cXMLRet += 		'</Item>'
			
		EndIf
	
		//Verifica se o Xml atingiu o tamanho maximo
		If ( ( Len(cXmlRet) / 1024 ) > MAX_FILE_LENGTH )
			Exit
		EndIf
		
	Next nI
	
	cXMLRet += 	'</ItensTablePrice>'
	cXMLRet += '</BusinessContent>'	
	
	If ( nControl > oModelDA1:Length() )
		nControl := -1
	EndIf
	
EndIf

//Restaura ambiente
FWRestRows( aSaveLine )     
RestArea(aAreaDA0)
RestArea(aArea)

Return {lRet, cXmlRet}