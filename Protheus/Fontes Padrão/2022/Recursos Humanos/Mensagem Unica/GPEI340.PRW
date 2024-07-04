#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEI340.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIntegDef   บAutor  ณ Emerson Campos     บ Data ณ  12/05/2014 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de integracao com o adapter EAI para recebimento e   บฑฑ
ฑฑบ          ณ envio de informacoes do cadastro de Sindicatos              บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA340                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
                                                        
Function GPEI340(cXML, nTypeTrans, cTypeMessage, cVersion)

Local aArea		:= GetArea()
Local lRet     	:= .T.
Local cXMLRet  	:= ""  
Local oXmlFunc	:= ""
Local oMdl340	:= ""
Local oXmlBus	:= ""
Local cXmlErro	:= ""
Local cXmlWarn	:= ""	
Local cEvento	:= "upsert"
Local cValExt	:= ""
Local cValInt 	:= ""
Local cVersoesOk 	:= "1.000|1.001|"
Local cAux			:= ""
Default cVersion 	:= "1.000"

Private oXml           := ""

If nTypeTrans == TRANS_RECEIVE

	If cTypeMessage == EAI_MESSAGE_BUSINESS

		Inclui := .F.
		Altera := .F.
	
		oXmlFunc := XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
	    oXml := oXmlFunc  
	    If oXmlFunc <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
	    If cVersion $ cVersoesOk
		    	cMarca := oXmlFunc:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		    
		    	oMdl340		:= FwLoadModel("GPEA340")
		    	oXmlBus 		:= oXMlFunc:_TotvsMessage:_BusinessMessage
	        
	        	If XmlChildEx(oXmlBus, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlBus:_BusinessEvent, '_EVENT' ) <> Nil
					
					cEvento := oXmlBus:_BusinessEvent:_Event:Text
					
					cValExt	:= If( ( XmlChildEx(oXmlBus:_BusinessEvent, '_IDENTIFICATION') <> Nil .And. ;
									XmlChildEx( oXmlBus:_BusinessEvent:_Identification, '_KEY') <> Nil ), ; 
									oXmlBus:_BusinessEvent:_Identification:_Key:Text, "" )
					
					cValExt := If( ( Empty( cValExt ) .And. XmlChildEx( oXmlBus:_BusinessContent, "_INTERNALID" ) <> Nil ), ;
									 oXmlBus:_BusinessContent:_InternalId:Text, ;
									 cValExt )
						
					If !Empty(cValExt)
					                        
						DbSelectArea("RCE")
						DbSetOrder(1)
						
						cValInt := CFGA070INT( cMarca, 'RCE', 'RCE_CODIGO', cValExt )
						
						If !Empty( cValInt )
							cValInt  := GPEI340Rcv( cValInt, { "RCE_FILIAL", "RCE_CODIGO" } )
						EndIf
								   					
					    If Empty(cValInt) .And. Upper(cEvento) == "UPSERT"
					    	
					    	Inclui := .T.
					    	oMdl340:SetOperation( MODEL_OPERATION_INSERT)
					    	lRet := oMdl340:Activate()
					    	
					    ElseIf !Empty(cValInt) .And. Upper(cEvento) == "UPSERT" .And. RCE->(DbSeek(cValInt))
					    		
					    	Altera	:= .T.
					    	oMdl340:SetOperation( MODEL_OPERATION_UPDATE)
					    	lRet := oMdl340:Activate()
					    		
					    ElseIf !Empty(cValInt) .And. Upper(cEvento) == "DELETE" .And. RCE->(DbSeek(cValInt))
					    		
					    	oMdl340:SetOperation( MODEL_OPERATION_DELETE)
					    	lRet := oMdl340:Activate()
					    Else
					    
					      lRet := .F.
					      cXMLRet := STR0001 // 'Opera็ใo de inser็ใo, altera็ใo, exclusao e chave interna sใo inexistentes'
					      
					    EndIf
					    
					    If lRet
					    	PEI340( @lRet, @cXmlRet, @oMdl340, oXmlBus, cMarca, cValExt )
					    Else
					    	cXmlRet := ApErroMvc( oMdl340 )
					    EndIf

					Else
						lRet := .F.
						cXMLRet := STR0002 // 'Chave do registro nใo enviada, ้ necessแria para cadastrar o de-para'
					EndIf 						    
					
	    		Else
		        	lRet := .F.
		        	cXMLRet := STR0003 // 'Tag de opera็ใo "Event" inexistente'
		        EndIf
	        
	        Else
	        
	        	lRet := .F.
	        	cXmlRet := STR0004 +" "+ cVersoesOk // "Versใo nใo tratada pelo Adapter, as possํveis sใo:"
	        
	        EndIf
        Else
        	lRet := .F.
        	cXMLRet	:= STR0005 + cXmlErro + "|" + cXmlWarn // "Xml mal formatado"
        EndIf
    
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		
		//-------------------------------------------------------
		//  tratando a recep็ใo da mensagem quando ้ realizado 
		// envio
		TrataResp( @lRet, @cXMLRet, cXml )
		
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
	
		cXmlRet := cVersoesOk
	
	EndIf

ElseIf nTypeTrans == TRANS_SEND
	lRet := .T.
	cValInt := GPEI340Snd( { cEmpAnt, xFilial("RCE"), RCE->RCE_CODIGO } )

    If !Inclui .And. !Altera
		cEvento := "delete"
		
		CFGA070Mnt(    Nil, 'RCE', 'RCE_CODIGO',		  Nil, cValInt, .T. ) // remove do de/para
    EndIf

	cXMLRet +='<BusinessEvent>'
	cXMLRet +=     '<Entity>LaborUnion</Entity>'
   	cXMLRet +=     '<Event>'+ cEvento +'</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="Code">'+ cValInt +'</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet +='</BusinessEvent>'
	cXMLRet +='<BusinessContent>'
	cXMLRet +=  '<CompanyId>'+ cEmpAnt +'</CompanyId>'
	//cXMLRet +=  '<BranchId>'+ xFilial("RCE") +'</BranchId>'
	cXMLRet +=  '<BranchId>'+ cFilAnt +'</BranchId>'
	cXMLRet +=  '<CompanyInternalId>'+ cEmpAnt+"|"+xFilial("RCE") +'</CompanyInternalId>'
	cXMLRet +=  '<InternalId>'+ cEmpAnt+"|"+RCE->RCE_FILIAL+"|"+RCE->RCE_CODIGO +'</InternalId>'
	cXMLRet +=  '<Code>'+ RCE->RCE_CODIGO +'</Code>'
	cXMLRet +=  '<UnionName>'+ HtmlNoTags(Alltrim(RCE->RCE_DESCRI)) +'</UnionName>'
	/*cXMLRet +=  '<RuralInformation>'
	cXMLRet +=    '<ItineraryInformation>'
	cXMLRet +=      '<RuralItineraryType></RuralItineraryType>'
	cXMLRet +=      '<RuralItineraryPercentage></RuralItineraryPercentage>'
	cXMLRet +=      '<RuralItineraryServiceCode></RuralItineraryServiceCode>'
	cXMLRet +=     '<ListOfRanges>'
	cXMLRet +=        '<Range>'
	cXMLRet +=          '<InitialDisplacementTime></InitialDisplacementTime>'
	cXMLRet +=          '<FinalDisplacementTime></FinalDisplacementTime>'
	cXMLRet +=          '<InitialDisplacementDistance></InitialDisplacementDistance>'
	cXMLRet +=          '<FinalDisplacementDistance></FinalDisplacementDistance>'
	cXMLRet +=          '<RuralItineraryValue></RuralItineraryValue>'
	cXMLRet +=          '<RuralItineraryHours></RuralItineraryHours>'
	cXMLRet +=        '</Range>'
	cXMLRet +=      '</ListOfRanges>'
	cXMLRet +=    '</ItineraryInformation>'
	cXMLRet +=  '</RuralInformation>
	cXMLRet +=  '<NightScheduleInformation>'
	cXMLRet +=    '<BeginNightSchedule></BeginNightSchedule>'
	cXMLRet +=    '<EndNightSchedule></EndNightSchedule>'
	cXMLRet +=  '</NightScheduleInformation>'
	*/
	cXMLRet +=  '<Address>'
	cXMLRet +=    '<Address>'+ HtmlNoTags(Alltrim(RCE->RCE_ENDER)) +'</Address>'
	cXMLRet +=    '<Number>'+ RCE->RCE_NUMER +'</Number>'
	cXMLRet +=    '<Complement>'+ HtmlNoTags(Alltrim(RCE->RCE_COMPLE)) +'</Complement>'
	cXMLRet +=    '<City>'
	cXMLRet +=      '<CityCode></CityCode>'
	cXMLRet +=      '<CityInternalId></CityInternalId>'
	cXMLRet +=      '<CityDescription>'+ HtmlNoTags(Alltrim(RCE->RCE_MUNIC)) +'</CityDescription>'
	cXMLRet +=    '</City>'
	cXMLRet +=    '<District>'+ HtmlNoTags(Alltrim(RCE->RCE_BAIRRO)) +'</District>'
	cXMLRet +=    '<State>'
	cXMLRet +=      '<StateCode>'+ RCE->RCE_UF +'</StateCode>'
	cXMLRet +=      '<StateInternalId></StateInternalId>'
	cAux := ""
	If !Empty(RCE->RCE_UF)
		cAux := Posicione("SX5",1,XFILIAL('SX5')+"12"+RCE->RCE_UF,"X5DESCRI()")
	EndIf
	cXMLRet +=      '<StateDescription>'+HtmlNoTags(Alltrim(cAux))+'</StateDescription>'
	cXMLRet +=    '</State>'
	cXMLRet +=    '<Country>'
	cXMLRet +=      '<CountryCode></CountryCode>'
	cXMLRet +=      '<CountryInternalId></CountryInternalId>'
	cXMLRet +=      '<CountryDescription></CountryDescription>'
	cXMLRet +=    '</Country>'
	cXMLRet +=    '<ZIPCode>'+ RCE->RCE_CEP +'</ZIPCode>'
	cXMLRet +=    '<Region></Region>'
	cXMLRet +=    '<POBox></POBox>'
	cXMLRet +=  '</Address>'
	
	cXMLRet +='</BusinessContent>'
EndIf  

RestArea(aArea)
cXmlRet:=FWNoAccent(cXmlRet)
cXmlRet:=EncodeUTF8(cXmlRet)
//cXmlRet := Encodeutf8(cXMLRet)

Return { lRet, cXMLRet }      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณIntegDef  บAutor  ณ 					   บ Data ณ  14/05/2014        	     	  บฑฑ 
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออออออออออออนฑฑ
ฑฑบDescricao ณ Mensagem Unica											          	            บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGPEA340		                                            	      	         บฑฑ 
ฑฑบ		     ณ@params	lStatus    - indica็ใo do status do processamento 	      	     	  บฑฑ
ฑฑบ		     ณ@params	cXmlStatus - conte๚do de retorno					      	     		  บฑฑ
ฑฑบ		     ณ@params	oMdlOper   - modelo de dados para rotina automแtica      	     	  บฑฑ
ฑฑบ		     ณ@params	oXmlOper   - conte๚do para processamento      	     			 	  บฑฑ
ฑฑบ		     ณ@params	cMarca     - sistema com o qual a integra็ใo estแ sendo realizada	  บฑฑ
ฑฑบ		     ณ@params	cValExtern - chave do registro na aplica็ใo de origem da mensagem	  บฑฑ
ฑฑบ		     ณ@return	Posicao 1  - LOGICAL - indica o status do processamento			 	  บฑฑ
ฑฑบ		     ณ@return	Posicao 2  - CHAR    - Xml/Conte๚do de retorno do processamento  	  บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PEI340( lStatus, cXmlStatus, oMdlOper, oXmlOper, cMarca, cValExtern ) 

Local oMdlFc := oMdlOper:GetModel("GPEA340_RCE")
Local cVlInt := ""
Local lDel	 := oMdlOper:GetOperation() == MODEL_OPERATION_DELETE
Local lIniPad := ( !Empty( GetSX3Cache( "RCE_CODIGO", "X3_RELACAO" ) ) )
 
If Inclui
	If !lIniPad
	   cVlInt := GETSX8NUM("RCE","RCE_CODIGO")
		While .T.
			If RCE->(DbSeek(xFilial("RCE")+cVlInt))
				ConfirmSX8()
				cVlInt:= GetSXeNum("RCE","RCE_CODIGO")
			Else
				Exit
			Endif
		Enddo
	EndIf
Else
   cVlInt := CFGA070INT( cMarca, 'RCE', 'RCE_CODIGO', cValExtern )
   cVlInt := GPEI340Rcv( cVlInt, { "RCE_FILIAL", "RCE_CODIGO" } )
EndIf

If !lDel 

	If XmlChildEx(oXmlOper, '_BUSINESSEVENT') <> Nil 
		If lStatus .And. !lIniPad .And. Inclui
		   	lStatus := oMdlFc:SetValue('RCE_CODIGO', cVlInt)
		EndIf                                              
				//descricao
		lStatus := GetField(@oMdlFc,oXml,"oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UNIONNAME:Text","RCE_DESCRI",lStatus,'SubStr( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnionName:Text, 1, TamSX3("RCE_DESCRI")[1] )')
							
		//Endereco
		lStatus := GetField(@oMdlFc,oXml,"oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Address:Text","RCE_ENDER",lStatus)

		//Numero
		GetField(@oMdlFc,oXml,"oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Number:Text","RCE_NUMER",lStatus)
		
		//Complemento
		GetField(@oMdlFc,oXml,"oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Complement:Text","RCE_COMPLE",lStatus)

		//Cidade
		GetField(@oMdlFc,oXml,"oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_CityDescription:Text","RCE_MUNIC",lStatus)

		//Bairro
		GetField(@oMdlFc,oXml,"oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_District:Text","RCE_BAIRRO",lStatus)

		//UF
		GetField(@oMdlFc,oXml,"oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_State:_StateCode:Text","RCE_UF",lStatus)
		
		//Cep
		GetField(@oMdlFc,oXml,"oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_ZIPCode:Text","RCE_CEP",lStatus)
	Else
		lStatus := .F.
		cXmlStatus := STR0006 + " BusinessContent" // 'Nใo existe a tag:'
	EndIf
	
EndIf

lStatus := lStatus .And. oMdlOper:VldData() .And. oMdlOper:CommitData()

If lStatus

	cVlInt := GPEI340Snd( { cEmpAnt, xFilial("RCE"), RCE->RCE_CODIGO } )
	ConfirmSX8()
	
	If lDel
		CFGA070Mnt(    Nil, 'RCE', 'RCE_CODIGO',		  Nil, cVlInt, .T. ) // remove do de/para
	Else

		CFGA070Mnt( cMarca, 'RCE', 'RCE_CODIGO', cValExtern, cVlInt )

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
/*/{Protheus.doc} GPEI340Snd
Rotina para integra็ใo por EAI 

@since 14/05/2014
@version P11
@params	aTempDados - valor para realizar o tratamento, inserindo pipes 
	na string de retorno
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function GPEI340Snd( aTempDados )

Local nZ       := 1
Local cTempKey := ""

Default aTempDados := {}

For nZ := 1 To Len( aTempDados )

	cTempKey += RTrim( aTempDados[nZ] ) + "|"

Next nZ

cTempKey := SubStr( cTempKey, 1, Len( cTempKey ) -1 )
	
Return cTempKey

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEI340Rcv
Rotina para realizar a separa็ใo da chave da tabela do conte๚do gravado 
no de/para, removendo os pipes e identificando o tamanho dos campos 

@since 14/05/2014
@version P11
@params	cTmpKeyInt - valor para realizar o tratamento, array para inserir pipes e string
	para remover pipes
@params aCposChave - array contendo os campos para ajuste de tamanho
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function GPEI340Rcv( cTmpKeyInt, aCposChave )

Local cTempKey  := ""
Local xAuxKey   := {}
Local nZ        := 0

Default cTmpKeyInt := ""
Default aCposChave := {}

xAuxKey := StrToKarr( cTmpKeyInt, "|" )

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

@since 14/05/2014
@version P11
@params	oModel     - modelo de dados para rotina automแtica
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
	Trata a resposta da aplica็ใo destino para grava็ใo do De/Para 

@since 14/05/2014
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
						Upper( oObjXml:_InternalId[nZ]:_Name:Text ) == "LABORUNION" .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_ORIGIN" ) <> Nil .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_DESTINATION" ) <> Nil
					
						CFGA070Mnt( cMarca, 'RCE', 'RCE_CODIGO', ;
							oObjXml:_InternalId[nZ]:_Destination:Text, ;
							oObjXml:_InternalId[nZ]:_Origin:Text )
						
						Exit
					EndIf
				Next nZ
			
			Else
			
				lProcOk := .F.
				cMsgRet := STR0007 // 'Nใo enviado conte๚do de retorno para cadastro de de-para'
			
			EndIf
			
		Else
			
			lProcOk := .F.
			cMsgRet := STR0008 // 'Nใo ้ possํvel gravar de-para por causa de erro na leitura do retorno'
		
		EndIf
		
	Else
	
		lProcOk 	:= .F.
		cMsgRet 	:= STR0009 + "|" // 'Erro no processamento pela outra aplica็ใo'
		
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
				cMsgRet := STR0010 // 'Erro no processamento, mas sem detalhes do erro pela outra aplica็ใo'
				
			EndIf
			
		EndIf
		
	EndIf

Else
	lProcOk 	:= .F.
	cMsgRet 	:= STR0011 + "|" + cXmlErro + "|" + cXmlWarn // 'Falha na leitura da resposta, de-para nใo serแ gravado'
EndIf

oObjXml := Nil
DelClassIntF()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetField
	Pegar Conteudo de um campo no XML e salvar no array

@param   aFuncionario,oXML,cTag,cCampo,lRet,cConteudo
@version P11
@since   20/05/2014
@return  lRet

@sample  GetField(@aFuncionario,oXML,"oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Gender:Text","RA_SEXO",lRet)

/*/
//-------------------------------------------------------------------	
Static Function GetField(oMdlFc,oXml,cTag,cCampo,lRet,cConteudo)
Default cConteudo := cTag

If lRet 
	If Type(cTag) <> "U" .AND. !Empty(&(cTag))
		lRet := oMdlFc:SetValue(cCampo, &(cConteudo) )
	Else
		lRet := .F.
	Endif
EndIf

Return lRet	