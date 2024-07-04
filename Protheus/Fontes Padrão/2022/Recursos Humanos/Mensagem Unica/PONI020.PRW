#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PONI020.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Integdef  ºAutor  ³Microsiga           º Data ³  09/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e  º±±
±±º          ³ envio de informações do cadastro de Feriados				  º±±
±±º          ³ (SP3) utilizando o conceito de mensagem unica. 		      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PONI020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PONI020( cXML, nTypeTrans, cTypeMessage, cVersao )

Local lRet			:= .T.
Local xData		  	:= ""           //Data interna do Feriado
Local cValExt		:= ""
Local cValInt		:= ""

Local cXMLRet	  	:= ""
Local cEvento		:= "upsert"
Local cXmlErro		:= ""
Local cXmlWarn		:= ""
Local cLogErro  	:= "" 

Local aErroAuto		:= {}
Local aFeriado		:= {}
Local aArea			:= GetArea()

Local nCount		:= 0
Local nOpcx			:= 0

Local oXmlMvInt		:= Nil
Local oXmlBusin		:= Nil

Local cVerTrata 	:= "1.000|1.001"

DEFAULT cVersao 	:= "1.000"

Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

If nTypeTrans == TRANS_RECEIVE
	
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		
		If cVersao $ cVerTrata	
			oXmlMvInt	:= XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
			
			If oXmlMvInt <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
						
				cMarca := oXmlMvInt:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				
				oXmlBusin := oXmlMvInt:_TotvsMessage:_BusinessMessage
				
				If XmlChildEx(oXmlBusin, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent, '_EVENT' ) <> Nil   
				
					cEvento := Upper( oXmlBusin:_BusinessEvent:_Event:Text )
					
					cValExt := If( ( Empty( cValExt ) .And. XmlChildEx( oXmlBusin:_BusinessContent, '_INTERNALID' ) <> Nil ), ;
									 oXmlBusin:_BusinessContent:_InternalId:Text, ;
									 "" )
					
					cValExt := If( ( Empty( cValExt ) .And. XmlChildEx(oXmlBusin:_BusinessEvent, '_IDENTIFICATION') <> Nil .And. ;
									 XmlChildEx(oXmlBusin:_BusinessEvent:_Identification, '_KEY') <> Nil ), ;
									 oXmlBusin:_BusinessEvent:_Identification:_Key:Text, ;
									 cValExt )

					If Empty( cValExt )
					
						If XmlChildEx( oXmlBusin:_BusinessContent, '_DATE' ) <> Nil .And. ;
							 XmlChildEx( oXmlBusin:_BusinessContent, '_COMPANYID' ) <> Nil .And. ;
							 XmlChildEx( oXmlBusin:_BusinessContent, '_BRANCHID' ) <> Nil

							cValExt := 	oXmlBusin:_BusinessContent:_BranchId:Text + ;
										oXmlBusin:_BusinessContent:_CompanyId:Text + ;
										oXmlBusin:_BusinessContent:_Date:Text

						EndIf
					EndIf

					If FindFunction("CFGA070INT")

						cValInt := CFGA070INT( cMarca, 'SP3', 'P3_DATA', cValExt )
						cValInt := PONI020Rcv( cValInt, { "P3_FILIAL", "P3_DATA" } )

						DbSelectArea('SP3')
						SP3->( DbSetOrder( 1 ) ) //P3_FILIAL+DTOS(P3_DATA)

						If !Empty( cValInt ) 
							
							If SP3->( DbSeek( cValInt ) )
						
								If cEvento == "DELETE"
									nOpcx := 5
								Else
									nOpcx := 4
								EndIf
								xData := SP3->P3_DATA
								aAdd( aFeriado, { "P3_DATA", SP3->P3_DATA, Nil } )
							Else
								lRet := .F.
								cXmlRet := STR0001 // "Combinação de chave e operação inválida"
							EndIf						
						ElseIf !Empty( cValExt )
						
							nOpcx := 3
							
							If XmlChildEx(oXmlBusin:_BusinessContent, '_DATE') <> NIL
								
								xData := StoD( StrTran( SubStr( oXmlBusin:_BusinessContent:_Date:Text, 1, 10 ), "-", "" ) )
								aAdd( aFeriado, { "P3_DATA", xData, Nil } )
								
								//--------------------------------------------
								//  Caso não receba a key, nem a InternalId 
								// verifica a existência somente pela filial+data
								If SP3->( DbSeek( xFilial("SP3")+ DtoS( xData ) ) )
									If Upper(cEvento) == "UPSERT"
										nOpcx := 4
									Else
										nOpcx := 5
									EndIf
								EndIf
								
							Else
								lRet := .F.
								cXMLRet := STR0002 // "Registro não cadastrado e sem data de referência para inserção-alteração"
							EndIf
						Else
							lRet := .F.
							cXmlRet := STR0003 // "Chave externa pra gravar de-para não identificada"
						EndIf
						
						If lRet
							If XmlChildEx(oXmlBusin:_BusinessContent, '_DESCRIPTION') <> NIL
								
								Aadd( aFeriado, { "P3_DESC", SubStr( oXmlBusin:_BusinessContent:_Description:Text, 1, TamSX3("P3_DESC")[1]), Nil } )
								
							Else
								lRet := .F.
								cXMLRet := STR0004 + 'Description' // 'Não existe a Tag '
							EndIf								
						EndIf										 
						                   
						If lRet
							If XmlChildEx(oXmlBusin:_BusinessContent, '_FIXEDHOLIDAY') <> NIL
								
								If Upper( oXmlBusin:_BusinessContent:_FixedHoliday:Text ) == "S"
									Aadd( aFeriado, { "P3_FIXO", "S", Nil })
								Else
									Aadd( aFeriado, { "P3_FIXO", "N", Nil })
								EndIf
							Else
								Aadd( aFeriado, { "P3_FIXO", "N", Nil })
							EndIf
						EndIf
	                    
						Aadd( aFeriado, { "P3_TPEXT" , "4", Nil })
						Aadd( aFeriado, { "P3_TPEXTN", "8", Nil })
	
					Else
						lRet   := .F.
						cXMLRet := STR0005 // "Atualize EAI"
					EndIf
				EndIf                 
				
				If lRet
				
					BeginTran()
					
					MSExecAuto( { |x,y| PONA020( x, y ) }, aFeriado, nOpcx )
					
					If lMsErroAuto
					
						DisarmTransaction()
						aErroAuto:= GetAutoGRLog()
						
						For nCount := 1 To Len(aErroAuto)
							cLogErro += StrTran( StrTran( StrTran( aErroAuto[nCount], "/", "" ), "<", "" ), ">", "" ) + (" ")
						Next nCount
						
						lRet	:= .F.
						cXMLRet := cLogErro
		
					Else
						EndTran()
						
						cValInt := PONI020Snd( { cEmpAnt, xFilial("SP3"), xData } )
						
						If nOpcx == 5
							CFGA070Mnt( , "SP3", "P3_DATA", , cValInt, .T. )                   
						Else
							CFGA070Mnt( cMarca, "SP3", "P3_DATA", cValExt, cValInt )
							
							cXMLRet := '<ListOfInternalId>'
							cXMLRet += 	'<InternalId>'
							cXMLRet += 		'<Name>'+ "Holiday" +'</Name>'
							cXMLRet += 		'<Origin>'+ cValExt +'</Origin>'
							cXMLRet += 		'<Destination>'+ cValInt +'</Destination>'
							cXMLRet += 	'</InternalId>'
							cXMLRet += '</ListOfInternalId>'
						EndIf
						
					EndIf
				EndIf
					
			Else
				lRet := .F.
				cXMLRet := 	STR0006 + cXmlErro + "|" + cXmlWarn // "Xml mal formatado "
			EndIf
		Else
		
			lRet := .F.
			cXmlRet := STR0007 // "Versão não tratada da mensagem não suportada"
		
		EndIf
		
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

		//----------------------------------
		//  Trata a response
		TrataResp( @lRet, @cXmlRet, cXml )
		
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := cVerTrata
	EndIf
	
ElseIf nTypeTrans == TRANS_SEND
	
	cValInt := PONI020Snd( { cEmpAnt, xFilial("SP3"), SP3->P3_DATA } )

	If !Inclui .AND. !Altera
		cEvento	:=	"Delete"
		
		CFGA070Mnt( , "SP3", "P3_DATA", , cValInt, .T. )
	EndIf
	
	//Monta XML de envio de mensagem unica
	cXMLRet := ' <BusinessEvent>'
	cXMLRet +=     '<Entity>Holiday</Entity>'
	cXMLRet +=     '<Event>' + cEvento + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="Code">' + cValInt + '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += ' </BusinessEvent>'

	cXMLRet += '<BusinessContent>'
	cXMLRet += 		'<CompanyId>'+ cEmpAnt +'</CompanyId>'
	cXMLRet += 		'<CompanyInternalId></CompanyInternalId>'
	//cXMLRet += 		'<BranchId>'+ SP3->P3_FILIAL +'</BranchId>'
	cXMLRet += 		'<BranchId>'+ cFilAnt +'</BranchId>'
	cXMLRet += 		'<InternalId>'+ cValInt +'</InternalId>'
	cXMLRet += 		'<Date>'+ Transform( DtoS(SP3->P3_DATA), "@R 9999-99-99") +'</Date>'
	cXMLRet += 		'<Description>'+ SP3->P3_DESC +'</Description>'
	cXMLRet += 		'<RegularOvertimeType></RegularOvertimeType>'
	cXMLRet += 		'<FixedHoliday>'+ SP3->P3_FIXO +'</FixedHoliday>'
	cXMLRet += 		'<NightOvertimeType></NightOvertimeType>'
	cXMLRet += '</BusinessContent>'
	
EndIf

RestArea(aArea)

cXMLRet := Encodeutf8(cXMLRet)

Return { lRet, cXMLRet }   

//-------------------------------------------------------------------
/*/{Protheus.doc} PONI020Snd
Rotina para integração por EAI 

@since 26/06/2013
@version P11
@params	aTempDados - valor para realizar o tratamento, inserindo pipes 
	na string de retorno
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function PONI020Snd( aTempDados )

Local nZ       := 1
Local cTempKey := ""

Default aTempDados := {}

For nZ := 1 To Len( aTempDados )

	If ValType(aTempDados[nZ])=="D"
		cTempKey += DtoS( aTempDados[nZ] ) + "|"
	Else
		cTempKey += RTrim( aTempDados[nZ] ) + "|"
	EndIf

Next nZ

cTempKey := SubStr( cTempKey, 1, Len( cTempKey )-1 )
	
Return cTempKey

//-------------------------------------------------------------------
/*/{Protheus.doc} PONI020Rcv
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
Function PONI020Rcv( cTmpKeyInt, aCposChave )

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
						Upper( oObjXml:_InternalId[nZ]:_Name:Text ) == "HOLIDAY" .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_ORIGIN" ) <> Nil .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_DESTINATION" ) <> Nil
					
						CFGA070Mnt( cMarca, 'SP3', 'P3_DATA', ;
							oObjXml:_InternalId[nZ]:_Destination:Text, ;
							oObjXml:_InternalId[nZ]:_Origin:Text )
						
						Exit
					EndIf
				Next nZ
			
			Else
			
				lProcOk := .F.
				cMsgRet := STR0008 // "Não enviado conteúdo de retorno para cadastro de de-para"
			
			EndIf
			
		Else
			
			lProcOk := .F.
			cMsgRet := STR0009 // "Não é possível gravar de-para por causa de erro na leitura do retorno"
		
		EndIf
		
	Else
	
		lProcOk 	:= .F.
		cMsgRet 	:= STR0010 + "|" // "Erro no processamento pela outra aplicação"
		
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
				cMsgRet := STR0011 // "Erro no processamento, mas sem detalhes do erro pela outra aplicação"
				
			EndIf
			
		EndIf
		
	EndIf

Else
	lProcOk 	:= .F.
	cMsgRet 	:= STR0012 + "|" + cXmlErro + "|" + cXmlWarn // "Falha na leitura da resposta, de-para não será gravado"
EndIf

oObjXml := Nil
DelClassIntF()

Return