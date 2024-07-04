#INCLUDE "PROTHEUS.CH"                               
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "GPEI040.CH" 
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณ IntegDef    บ Autor ณ 				   บ Data ณ 25/03/2012  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Desc.    ณ Funcao de integracao com o adapter EAI para recebimento e    บฑฑ
ฑฑบ          ณ envio de informa็๕es do cadastro de Verbas (SRV)			    บฑฑ
ฑฑบ          ณ utilizando o conceito de mensagem unica.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Param.   ณ cXML - Variavel com conteudo xml para envio/recebimento.     บฑฑ
ฑฑบ          ณ nTypeTrans - Tipo de transacao. (Envio/Recebimento)          บฑฑ
ฑฑบ          ณ cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno  ณ aRet - Array contendo o resultado da execucao e a mensagem   บฑฑ
ฑฑบ          ณ        Xml de retorno.                                       บฑฑ
ฑฑบ          ณ aRet[1] - (boolean) Indica o resultado da execu็ใo da fun็ใo บฑฑ
ฑฑบ          ณ aRet[2] - (caracter) Mensagem Xml para envio                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso      ณ GPEA040                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/    

Function GPEI040( cXML, nTypeTrans, cTypeMessage, cVersao )

Local lRet     			:= .T.			//Status de retorno da IntegDef()
Local cXMLRet  			:= ""			//Xml de retorno da IntegDef()
Local cError			:= ""			//Mensagem de Erro no Parse do Xml recebido
Local cWarning	 		:= ""			//Mensagem de Warning no Parse do Xml recebido
Local nCount        	:= 0			//Variavel numerica para uso em contadores
Local aCab				:= {}			//Array com os campos e os dados que serใo gravados na MsExecAuto
Local nOpcx	 			:= 0			//Operacao realizado pelo usuario ( 3-Inclusao | 4-Alteracao | 5-Exclusao )
Local cLogErro 			:= ""			//Descricao do erro na MsExecAuto
Local aErroAuto			:= {}			//Array com erro da MsExecAuto
Local cEvent      		:= "upsert"		//Evento da mensagem (upsert ou delete)
Local oXmlBusMsg				   		//Objeto com o conteudo apenas da BusinessMessage do Xml recebido
Local oModel
//-- Variaveis utilizadas no De/Para de c๓digos

Local cValInt			:= "" 	   		//-- Codigo interno utilizado no De/Para de codigos - Tabela XXF
Local cValExt			:= ""       	//-- Codigo externo utilizada no De/Para de codigos - Tabela XXF
Local cMarca			:= "" 	  		//-- Armazena a Marca (LOGIX,PROTHEUS,RM...) que enviou o XML
Local cAlias			:= "SRV"   	 	//-- Alias usado como refer๊ncia no De/Para
Local cCampo			:= "RV_COD" 	//-- Campo usado como refer๊ncia no De/Para

Local cVersoesOk 		:= "1.000|"
Local cTipo    			:= ""

Private oXmlG040  		:= Nil 			//Objeto que recebe o parse do Xml recebido
Private nCountG040	  	:= 0
Private lMsErroAuto		:= .F.			//Armazena o status da execucao da MsExecAuto
Private lAutoErrNoFile	:= .T.	

//Tratamento do recebimento de mensagens
If ( nTypeTrans == TRANS_RECEIVE )
	
	//Recebimento da mensagem de negocios
	If ( cTypeMessage == EAI_MESSAGE_BUSINESS )
		
		If cVersao $ cVersoesOk
			//Cria objeto com os dados do Xml
			oXmlG040 := XmlParser( cXml, "_", @cError, @cWarning )
			
			If ( oXmlG040 <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) )
				oModel		:= FwLoadModel("GPEA040")
				oXmlBusMsg := oXmlG040:_TOTVSMessage:_BusinessMessage
				
				cMarca := oXmlG040:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			
				//Codigo da transportadora
				If ( XmlChildEx( oXmlBusMsg:_BusinessContent, "_INTERNALID" ) <> Nil )
					
					cValExt := oXmlG040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
					//--------------------------------------------------------------------------------------
					//-- Tratamento utilizando a tabela XXF com um De/Para de codigos   
					//--------------------------------------------------------------------------------------
					If ( FindFunction("CFGA070INT") )	
					   
						cValInt := CFGA070INT( cMarca , cAlias , cCampo, cValExt )
						cValInt := GPEI040Rcv( cValInt, { "RV_FILIAL", "RV_COD" } )
						
			  			DbSelectArea("SRV")
			  			SRV->(DbSetOrder(1))	//RV_FILIAL + RV_COD
						
						If Empty(cValInt) .And. Upper( oXmlBusMsg:_BusinessEvent:_Event:Text ) == "UPSERT"
							
							If Empty(Posicione("SX3",2,Padr("RV_COD" ,10),"X3_RELACAO") )
								
								While .T.
									cValInt := GetSxeNum( "SRV", "RV_COD" )
									If SRV->( DbSeek( xFilial("SRV") + cValInt ) )
										ConfirmSX8()
									Else
										Exit
									EndIf
								End
								
								aAdd( aCab, { "RV_COD" , cValInt , Nil } )
								nOpcx := 3
					 		EndIf
					 	ElseIf !Empty( cValInt ) .And. SRV->( DbSeek( cValInt ) )
					 		
					 		If Upper( oXmlBusMsg:_BusinessEvent:_Event:Text ) == "UPSERT"
					 			nOpcx := 4
					 		Else
					 			nOpcx := 5
					 		EndIf
				  			
				  			aAdd( aCab, { "RV_COD", SRV->RV_COD, Nil } )
					 	Else
							lRet := .F.
							cXmlRet := STR0001 // "Opera็ใo da mensagem e chave do registro nใo sใo vแlidos"
						EndIf
					
					Else
					
						lRet := .F.
						cXmlRet := STR0002 // "Alguns recursos nใo estใo disponํveis no EAI, atualize-o"
						
					EndIF
					
				EndIf			
						
				If ( XmlChildEx( oXmlBusMsg, "_BUSINESSCONTENT" ) <> Nil )
							
					//Descri็ใo
					If ( XmlChildEx( oXmlBusMsg:_BusinessContent, "_DESCRIPTION" ) <> Nil )		
						aAdd( aCab, { "RV_DESC", SubStr( oXmlBusMsg:_BusinessContent:_Description:Text, 1, TamSX3("RV_DESC")[1] ), Nil } )
					EndIf
					
					//Tipo
					If ( XmlChildEx( oXmlBusMsg:_BusinessContent, "_FUNDINGAMOUNTTYPE" ) <> Nil )
						cTipo:= oXmlBusMsg:_BusinessContent:_FundingAmountType:Text
						If cTipo == '1'
							aAdd( aCab, { "RV_TIPO",  "H", Nil } )
						ElseIf cTipo == '2'
							aAdd( aCab, { "RV_TIPO",  "D", Nil } )
						ElseIf cTipo == '3'
							aAdd( aCab, { "RV_TIPO",  "V", Nil } )
						ElseIf cTipo == '4'
							aAdd( aCab, { "RV_TIPO",  "V", Nil } )
						EndIf
					EndIf
					
					//Tipo do codigo
					If ( XmlChildEx( oXmlBusMsg:_BusinessContent, "_FUNDCODETYPE" ) <> Nil )
						aAdd( aCab, { "RV_TIPOCOD",  oXmlBusMsg:_BusinessContent:_FundCodeType:Text, Nil } )
					EndIf 
					
				EndIf       	        	
				
				If lRet

					BeginTran()				
		 			FWMVCRotAuto(oModel,'SRV',nOpcx,{{'SRVMASTER',aCab}},.F.,.T.)
		 			//MSExecAuto({|x,y|GPEA040(x,y)},aCab,nOpcx) 
			   
					If ( lMsErroAuto )
						DisarmTransaction()
					
						aErroAuto := GetAutoGRLog()
						
						For nCount := 1 To Len(aErroAuto)
							cLogErro += StrTran( StrTran( StrTran( aErroAuto[nCount], "/", "" ), "<", "" ), ">", "" ) + ("|") 
						Next nCount
						
						//Monta XML de Erro de execu็ใo da rotina automatica.
						lRet := .F.
						cXMLRet := EncodeUTF8( FWNoAccent(cLogErro) )
						
					Else
						EndTran()
						
						cValInt := GPEI040Snd( { cEmpAnt, xFilial("SRV"), oModel:GetModel('SRVMASTER'):getvalue("RV_COD") } )	
						
						If nOpcx == 5
							
							CFGA070Mnt( cMarca, cAlias, cCampo, , cValInt, .T. )
							
						Else	
						
							CFGA070Mnt( cMarca, cAlias, cCampo, cValExt, cValInt )
							 				
							cXmlRet += "<ListOfInternalId>"
							cXmlRet += 	"<InternalId>"
							cXMLRet += 		"<Name>" + "PayrollAmount" + "</Name>"
							cXMLRet += 		"<Origin>" + cValExt + "</Origin>" 
							cXMLRet += 		"<Destination>" + cValInt + "</Destination>"
							cXmlRet += 	"</InternalId>"
							cXmlRet += "</ListOfInternalId>"   								

						EndIf
										
					EndIf
				EndIf
			Else
				
				lRet := .F.
				cXMLRet := STR0003 // "Falha ao manipular o XML"
			EndIf
			
		Else
		
			lRet := .F.
			cXmlRet := STR0004 // "Versใo nใo tratada pelo Adapter"
		
		EndIf
	
		cXmlRet := EncodeUTF8( cXmlRet )
	
	//Message Response
	ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )

		//--------------------------------------------------
		// Executa a recep็ใo da Response para gravar o De/Para
		TrataResp( @lRet, @cXmlRet, cXml )
		
	//WhoIs
	ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )
		cXMLRet := cVersoesOk
		
	EndIf

//Tratamento do envio de mensagem	
ElseIf ( nTypeTrans == TRANS_SEND )

	cValInt := GPEI040Snd( { cEmpAnt, xFilial("SRV"), SRV->RV_COD } )

	//Verifica se ้ uma exclusใo
	If ( !Inclui ) .And. ( !Altera )
		cEvent := 'delete'
		
		CFGA070Mnt( cMarca, cAlias, cCampo, , cValInt, .T. )
	EndIf
	
	If SRV->RV_TIPO == "R"
		cTipo := '4'
	ElseIf SRV->RV_TIPO == "V"
		cTipo := '3'
	ElseIf SRV->RV_TIPO == "D"
		cTipo := '2'
	Else
		cTipo := '1'
	EndIf
	
	
	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>PayrollAmount</Entity>'
	cXMLRet +=     '<Event>'+ cEvent +'</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="Code">' + cValInt + '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'

	cXMLRet +='<BusinessContent>'
	cXMLRet +=     '<CompanyId>'+ cEmpAnt +'</CompanyId>'
	//cXMLRet +=     '<BranchId> '+ xFilial("SRV") +  '</BranchId>'
	cXMLRet +=     '<BranchId> '+ cFilAnt + '</BranchId>'
	cXMLRet +=     '<CompanyInternalId></CompanyInternalId>'
	cXMLRet +=     '<FundCode>' + SRV->RV_COD + '</FundCode>'
	cXMLRet +=     '<InternalId>' + cValInt + '</InternalId>'
	cXMLRet +=     '<Description>' + HtmlNoTags(Alltrim(SRV->RV_DESC)) + '</Description>'
	cXMLRet +=     '<FundingAmountType>' + cTipo + '</FundingAmountType>'
	cXMLRet +=     '<FundCodeType>' + SRV->RV_TIPOCOD + '</FundCodeType>'
	cXMLRet += '</BusinessContent>'	

EndIf

cXmlRet := EncodeUTF8(cXmlRet)
Return { lRet, cXMLRet  }  

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEI040Snd
Rotina para integra็ใo por EAI 

@since 26/06/2013
@version P11
@params	aTempDados - valor para realizar o tratamento, inserindo pipes 
	na string de retorno
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function GPEI040Snd( aTempDados )

Local nZ       := 1
Local cTempKey := ""

Default aTempDados := { cEmpAnt, RV_FILIAL, RV_COD }

For nZ := 1 To Len( aTempDados )

	cTempKey += RTrim( aTempDados[nZ] ) + "|"

Next nZ

cTempKey := SubStr( cTempKey, 1, Len( cTempKey ) -1 )
	
Return cTempKey

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEI040Rcv
Rotina para realizar a separa็ใo da chave da tabela do conte๚do gravado 
no de/para, removendo os pipes e identificando o tamanho dos campos 

@since 26/06/2013
@version P11
@params	cTmpKeyInt - valor para realizar o tratamento, array para inserir pipes e string
	para remover pipes
@params aCposChave - array contendo os campos para ajuste de tamanho
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function GPEI040Rcv( cTmpKeyInt, aCposChave )

Local cTempKey  := ""
Local xAuxKey   := {}
Local nZ        := 0

Default cTmpKeyInt := ""
Default aCposChave := {}

xAuxKey := Separa( cTmpKeyInt, "|" )

If ( Len( xAuxKey ) - 1) == Len( aCposChave )
	
	For nZ := 2 To Len( xAuxKey )
	
		cTempKey += PadR( xAuxKey[nZ], TamSX3( aCposChave[nZ-1] )[1] )
	
	Next nZ
EndIf

xAuxKey := aSize( xAuxKey, 0 )

Return cTempKey 

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataResp
	Trata a resposta da aplica็ใo destino para grava็ใo do De/Para 

@since 26/06/2013
@version P11
@params 	lProcOk 	Status do processamento (refer๊ncia)
@params 	cMsgRet 	Mensagem de retorno do processamento (refer๊ncia)
@params 	cXml    	Mensagem da response para tratamento

/*/
//-------------------------------------------------------------------
Static Function TrataResp( lProcOk, cMsgRet, cXml )

Local oObjXml 	:= Nil
Local cXmlErro 	:= ""
Local cXmlWarn 	:= ""
Local nZ 		:= 0
Local cMarca 	:= ""

oObjXml := XmlParser( cXml, "_", @cXmlErro, @cXmlWarn )

If oObjXml <> Nil .And. Empty( cXmlErro ) .And. Empty( cXmlWarn )

	cMarca := oObjXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text

	If XmlChildEx( oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation, "_STATUS" ) <> Nil .And. ;
		Upper( oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation:_Status:Text ) == "OK"
	
		oObjXml := XmlChildEx( oObjXml:_TotvsMessage:_ResponseMessage:_ReturnContent, "_LISTOFINTERNALID" )  
		
		If oObjXml <> Nil
			
			If XmlChildEx( oObjXml, "_INTERNALID" ) <> Nil
				
				If Valtype( oObjXml:_InternalId ) <> "A"
					XmlNode2Arr( oObjXml:_InternalId, "_InternalId" )
				EndIf
				
				For nZ := 1 To Len( oObjXml:_InternalId )
				
					If XmlChildEx( oObjXml:_InternalId[nZ], "_NAME" ) <> Nil .And. ;
						Upper( oObjXml:_InternalId[nZ]:_Name:Text ) == "PAYROLLAMOUNT" .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_ORIGIN" ) <> Nil .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_DESTINATION" ) <> Nil
					
						CFGA070Mnt( cMarca, 'SRV', 'RV_COD', ;
							oObjXml:_InternalId[nZ]:_Destination:Text, ;
							oObjXml:_InternalId[nZ]:_Origin:Text )
						
						Exit
					EndIf
				Next nZ
			
			Else
			
				lProcOk := .F.
				cMsgRet := STR0005 // "Nใo conte๚do de retorno para cadastro de de-para"
			
			EndIf
			
		Else
			
			lProcOk := .F.
			cMsgRet := STR0006 // "Nใo ้ possํvel gravar de-para por causa de erro na leitura do retorno"
		
		EndIf
		
	Else
	
		lProcOk 	:= .F.
		cMsgRet 	:= STR0007 + "|" // "Erro no processamento pela outra aplica็ใo"
		
		If XmlChildEx( oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation, "_LISTOFMESSAGES" ) <> Nil
			oObjXml := oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages
			
			If XmlChildEx( oObjXml, "_MESSAGE" ) <> Nil 
				
				If Valtype( oObjXml:_Message ) <> "A"
					XmlNode2Arr( oObjXml:_Message, "_Message" )
				EndIf
				
				For nZ := 1 To Len( oObjXml:_Message )
				
					cMsgRet += Alltrim( oObjXml:_Message[nZ]:Text ) + "|"
				
				Next nZ
			Else
				
				lProcOk := .F.
				cMsgRet := STR0008 // "Erro no processamento, mas sem detalhes do erro pela outra aplica็ใo"
				
			EndIf
			
		EndIf
		
	EndIf

Else
	lProcOk 	:= .F.
	cMsgRet 	:= STR0009 + "|" + cXmlErro + "|" + cXmlWarn // "Falha na leitura da resposta, de-para nใo serแ gravado"
EndIf

oObjXml := Nil
DelClassIntF()

Return