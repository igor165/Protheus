#INCLUDE "PROTHEUS.CH"   
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEI370.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IntegDef   ºAutor  ³Microsiga           º Data ³  18/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e   º±±
±±º          ³ envio de informacoes do cadastro de Cargos                  º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA370                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static cVerSend         := "1.000|1.001"  // versões disponíveis
                                                        
Function GPEI370(cXML, nTypeTrans, cTypeMessage, cVersion)

Local aArea		:= GetArea()
Local lRet     	:= .T.
Local cXMLRet  	:= ""  
Local oXmlFunc	:= Nil
Local oMdl370	:= Nil
Local oXmlBus	:= Nil
Local cXmlErro	:= ""
Local cXmlWarn	:= ""	
Local cEvento	:= "upsert"
Local cValExt	:= ""
Local cValInt 	:= ""
Local cVersoesOk := "1.000|1.001"

Default cVersion := "1.000"

If nTypeTrans == TRANS_RECEIVE

	If cTypeMessage == EAI_MESSAGE_BUSINESS

		Inclui := .F.
		Altera := .F.
	
		oXmlFunc := XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
	      
	    If oXmlFunc <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
	    
	    	If cVersion $ cVersoesOk
		    	cMarca := oXmlFunc:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		    
		    	oMdl370		:= FwLoadModel("GPEA370")
		    	oXmlBus 	:= oXMlFunc:_TotvsMessage:_BusinessMessage
	        
	        	If XmlChildEx(oXmlBus, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlBus:_BusinessEvent, '_EVENT' ) <> Nil
					
					cEvento := oXmlBus:_BusinessEvent:_Event:Text
					
					cValExt	:= If( ( XmlChildEx(oXmlBus:_BusinessEvent, '_IDENTIFICATION') <> Nil .And. ;
									XmlChildEx( oXmlBus:_BusinessEvent:_Identification, '_KEY') <> Nil ), ; 
									oXmlBus:_BusinessEvent:_Identification:_Key:Text, "" )
					
					cValExt := If( ( Empty( cValExt ) .And. XmlChildEx( oXmlBus:_BusinessContent, "_INTERNALID" ) <> Nil ), ;
									 oXmlBus:_BusinessContent:_InternalId:Text, ;
									 cValExt )
						
					If !Empty(cValExt)
					                        
						DbSelectArea("SQ3")
						DbSetOrder(1)
						
						cValInt := CFGA070INT( cMarca, 'SQ3', 'Q3_CARGO', cValExt )
						
						If !Empty( cValInt )
							cValInt  := GPEI370Rcv( cValInt, { "Q3_FILIAL", "Q3_CARGO" } )
						EndIf
								   					
					    If Empty(cValInt) .And. Upper(cEvento) == "UPSERT"
					    	
					    	Inclui := .T.
					    	oMdl370:SetOperation( MODEL_OPERATION_INSERT)
					    	lRet := oMdl370:Activate()
					    	
					    ElseIf !Empty(cValInt) .And. Upper(cEvento) == "UPSERT" .And. SQ3->(DbSeek(cValInt))
					    		
					    	Altera	:= .T.
					    	oMdl370:SetOperation( MODEL_OPERATION_UPDATE)
					    	lRet := oMdl370:Activate()
					    		
					    ElseIf !Empty(cValInt) .And. Upper(cEvento) == "DELETE" .And. SQ3->(DbSeek(cValInt))
					    		
					    	oMdl370:SetOperation( MODEL_OPERATION_DELETE)
					    	lRet := oMdl370:Activate()
					    Else
					    
					      lRet := .F.
					      cXMLRet := STR0001 // 'Operação de inserção, alteraçã, exclusao e chave interna são inexistentes'
					      
					    EndIf
					    
					    If lRet
					    	PEI370( @lRet, @cXmlRet, @oMdl370, oXmlBus, cMarca, cValExt )
					    Else
					    	cXmlRet := ApErroMvc( oMdl370 )
					    EndIf

					Else
						lRet := .F.
						cXMLRet := STR0002 // 'Chave do registro não enviada, é necessária para cadastrar o de-para'
					EndIf 						    
					
	    		Else
		        	lRet := .F.
		        	cXMLRet := STR0003 // 'Tag de operação "Event" inexistente'
		        EndIf
	        
	        Else
	        
	        	lRet := .F.
	        	cXmlRet := STR0004 + cVersoesOk // "Versão não tratada pelo Adapter, as possíveis são: "
	        
	        EndIf
        Else
        	lRet := .F.
        	cXMLRet	:= STR0005 + cXmlErro + "|" + cXmlWarn // "Xml mal formatado"
        EndIf
    
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		
		//-------------------------------------------------------
		//  tratando a recepção da mensagem quando é realizado 
		// envio
		TrataResp( @lRet, @cXMLRet, cXml )
		
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
	
		cXmlRet := cVersoesOk
	
	EndIf

ElseIf nTypeTrans == TRANS_SEND

	cValInt := GPEI370Snd( { cEmpAnt, xFilial("SQ3"), M->Q3_CARGO } )

    If !Inclui .And. !Altera
		cEvento := "delete"
		
		CFGA070Mnt(    Nil, 'SQ3', 'Q3_CARGO',		  Nil, cValInt, .T. ) // remove do de/para
    EndIf


	cXMLRet += '<BusinessEvent>'
	cXMLRet +=     '<Entity>EmployeePosition</Entity>'
    cXMLRet +=     '<Event>'+ cEvento + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="Code">' + cValInt + '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'
	cXMLRet += '<BusinessContent>'
    cXMLRet += 		'<CompanyId>' + cEmpAnt + '</CompanyId>'
	//cXMLRet += 		'<BranchId>' + xFilial("SQ3") + '</BranchId>'
	cXMLRet += 		'<BranchId>' + cFilAnt + '</BranchId>'
	cXMLRet +=  	'<CompanyInternal>'+ cEmpAnt+"|"+xFilial("SQ3") +'</CompanyInternal>'
	cXMLRet += 		'<InternalId>' + cValInt + '</InternalId>'
	cXMLRet += 		'<PositionCode>'    + M->Q3_CARGO + '</PositionCode>'
	cXMLRet += 		'<Description>' + HtmlNoTags(Alltrim(M->Q3_DESCSUM)) + '</Description>'
	If cVersion == "1.001"
		cXMLRet += 		'<PositionLevel>' + "" + '</PositionLevel>'
		cXMLRet += 		'<Active>true</Active>'
	EndIf
	cXMLRet += '</BusinessContent>'
EndIf  

RestArea(aArea)

cXmlRet:=FWNoAccent(cXmlRet)
cXmlRet:=EncodeUTF8(cXmlRet)

Return { lRet, cXMLRet }      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IntegDef  ºAutor  ³ 					   º Data ³  18/02/13         	     º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mensagem Unica											          	     º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEA370		                                            	      	     º±± 
±±º		     ³@params	lStatus    - indicação do status do processamento 	      	     º±±
±±º		     ³@params	cXmlStatus - conteúdo de retorno					      	     º±±
±±º		     ³@params	oMdlOper   - modelo de dados para rotina automática      	     º±±
±±º		     ³@params	oXmlOper   - conteúdo para processamento      	     			 º±±
±±º		     ³@params	cMarca     - sistema com o qual a integração está sendo realizadaº±±
±±º		     ³@params	cValExtern - chave do registro na aplicação de origem da mensagemº±±
±±º		     ³@return	Posicao 1  - LOGICAL - indica o status do processamento			 º±±
±±º		     ³@return	Posicao 2  - CHAR    - Xml/Conteúdo de retorno do processamento  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
 

Static Function PEI370( lStatus, cXmlStatus, oMdlOper, oXmlOper, cMarca, cValExtern ) 

Local oMdlFc := oMdlOper:GetModel("MODELGPEA370")
Local cVlInt := ""
Local lDel	 := oMdlOper:GetOperation() == MODEL_OPERATION_DELETE
Local lIniPad := ( !Empty( GetSX3Cache( "Q3_CARGO", "X3_RELACAO" ) ) )

If Inclui
	If !lIniPad
	   cVlInt := GETSX8NUM("SQ3","Q3_CARGO")
		While .T.
			If SQ3->(DbSeek(xFilial("SQ3")+cVlInt))
				ConfirmSX8()
				cVlInt:= GetSXeNum("SQ3","Q3_CARGO")
			Else
				Exit
			Endif
		Enddo
	EndIf
Else
   cVlInt := CFGA070INT( cMarca, 'SQ3', 'Q3_CARGO', cValExtern )
   cVlInt := GPEI370Rcv( cVlInt, { "Q3_FILIAL", "Q3_CARGO" } )
EndIf

If !lDel 

	If XmlChildEx(oXmlOper, '_BUSINESSEVENT') <> Nil 
		If lStatus .And. !lIniPad .And. Inclui
		   	lStatus := oMdlFc:SetValue('Q3_CARGO', cVlInt)
		EndIf                                              
		
		If lStatus .And. XmlChildEx(oXmlOper:_BusinessContent, '_DESCRIPTION') <> Nil
			lStatus := oMdlFc:SetValue('Q3_DESCSUM', SubStr( oXmlOper:_BusinessContent:_Description:Text, 1, TamSX3("Q3_DESCSUM")[1] ) )
		EndIf
	Else
		lStatus := .F.
		cXmlStatus := STR0005 + "BusinessContent" // 'Não existe a tag '
	EndIf
	
EndIf

lStatus := lStatus .And. oMdlOper:VldData() .And. oMdlOper:CommitData()

If lStatus

	cVlInt := GPEI370Snd( { cEmpAnt, xFilial("SQ3"), M->Q3_CARGO } )
	ConfirmSX8()
	
	If lDel
		CFGA070Mnt(    Nil, 'SQ3', 'Q3_CARGO',		  Nil, cVlInt, .T. ) // remove do de/para
	Else

		CFGA070Mnt( cMarca, 'SQ3', 'Q3_CARGO', cValExtern, cVlInt )

		//---------//
		// De/Para //
		//---------//
		cXmlStatus := '<ListOfInternalId>'
		cXmlStatus += 	'<InternalId>'
		cXmlStatus += 		'<Name>'+ "EmployeePosition" +'</Name>'
		cXmlStatus += 		'<Origin>'+ cValExtern +'</Origin>'
		cXmlStatus += 		'<Destination>'+ cVlInt +'</Destination>'
		cXmlStatus += 	'</InternalId>'
		cXmlStatus += '</ListOfInternalId>'
		
	EndIf
	
Else
	//------------------------------------------//
	//  Identificar erro do modelo para retorno //
	//------------------------------------------//
	RollBackSX8()
	cXmlStatus := ApErroMvc( oMdlOper )
EndIf

Return{ lStatus, cXmlStatus } 

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEI370Snd
Rotina para integração por EAI 

@since 26/06/2013
@version P11
@params	aTempDados - valor para realizar o tratamento, inserindo pipes 
	na string de retorno
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function GPEI370Snd( aTempDados )

Local nZ       := 1
Local cTempKey := ""

Default aTempDados := {}

For nZ := 1 To Len( aTempDados )

	cTempKey += RTrim( aTempDados[nZ] ) + "|"

Next nZ

cTempKey := SubStr( cTempKey, 1, Len( cTempKey ) -1 )
	
Return cTempKey

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEI370Rcv
Rotina para realizar a separação da chave da tabela do conteúdo gravado 
no de/para, removendo os pipes e identificando o tamanho dos campos 

@since 26/06/2013
@version P11
@params	cTmpKeyInt - valor para realizar o tratamento, array para inserir pipes e string
	para remover pipes
@params aCposChave - array contendo os campos para ajuste de tamanho
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function GPEI370Rcv( cTmpKeyInt, aCposChave )

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
/*/{Protheus.doc} ApErroMvc
	Apura o erro do mvc retornando uma string 

@since 26/06/2013
@version P11
@params	oModel     - modelo de dados para rotina automática
@return	cErro      - erro apurado no modelo

/*/
//-------------------------------------------------------------------
Static Function ApErroMvc( oModel )

Local cErro  := ' '
Local aErros := aClone( oModel:GetErrorMessage() )
Local nX     := 0 

For nX := 1 To Len(aErros)
	If Valtype(aErros[nX])=='C'
		cErro += StrTran(StrTran(StrTran(StrTran(aErros[nX],"<",""),"\",""),">",""),"/", "") + ("|")
	ElseIf Valtype(aErros[nX])<>'U'
		cErro += Alltrim( Str( aErros[nX] ) ) + "|"
	EndIf
Next nX

aErros := aSize( aErros, 0 )

Return cErro

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataResp
	Trata a resposta da aplicação destino para gravação do De/Para 

@since 26/06/2013
@version P11
@params 	lProcOk 	Status do processamento (referência)
@params 	cMsgRet 	Mensagem de retorno do processamento (referência)
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
						Upper( oObjXml:_InternalId[nZ]:_Name:Text ) == "EMPLOYEEPOSITION" .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_ORIGIN" ) <> Nil .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_DESTINATION" ) <> Nil
					
						CFGA070Mnt( cMarca, 'SQ3', 'Q3_CARGO', ;
							oObjXml:_InternalId[nZ]:_Destination:Text, ;
							oObjXml:_InternalId[nZ]:_Origin:Text )
						
						Exit
					EndIf
				Next nZ
			
			Else
			
				lProcOk := .F.
				cMsgRet := STR0006 // "Não enviado conteúdo de retorno para cadastro de de-para"
			
			EndIf
			
		Else
			
			lProcOk := .F.
			cMsgRet := STR0007 // "Não é possível gravar de-para por causa de erro na leitura do retorno"
		
		EndIf
		
	Else
	
		lProcOk 	:= .F.
		cMsgRet 	:= STR0008 + "|" // "Erro no processamento pela outra aplicação"
		
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
				cMsgRet := STR0009 // "Erro no processamento, mas sem detalhes do erro pela outra aplicação"
				
			EndIf
			
		EndIf
		
	EndIf

Else
	lProcOk 	:= .F.
	cMsgRet 	:= STR0010 + "|" + cXmlErro + "|" + cXmlWarn // "Falha na leitura da resposta, de-para não será gravado"
EndIf

oObjXml := Nil
DelClassIntF()

Return