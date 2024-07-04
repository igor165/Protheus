#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "PONN010.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Integdef  ºAutor  ³Microsiga           º Data ³  09/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e  º±±
±±º          ³ envio de informações do cadastro de Exceções				  º±±
±±º          ³ (SP8) utilizando o conceito de mensagem unica. 		      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PONM010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PONN010( cXML, nTypeTrans, cTypeMessage, cVersaoMU )

Local lRet			:= .T.

Local cCodFunEx		:= ""           //Codigo externo de Funcionario
Local cCodFun	  	:= ""           //Codigo interno da Matricula do funcionário
Local cData		  	:= ""           //Data da marcação
Local nHora			:= ""           //Hora da marcação
Local cValExt		:= ""
Local cValInt		:= ""

Local cXMLRet	  	:= ""
Local cEvento		:= "upsert"
Local cXmlErro		:= ""
Local cXmlWarn		:= ""

Local aItens		:= {}
Local aCabAuto		:= {}
Local aInteg		:= {}
Local cVerDispMU 	:= "1.000|"
Local nCount		:= 0
Local nOpcx			:= 0

Local oXmlMvInt		:= Nil
Local oXmlBusin		:= Nil

Private lMsErroAuto := .F.


If nTypeTrans == TRANS_RECEIVE
	
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		
		If cVersaoMU $ cVerDispMU
			oXmlMvInt	:= XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
			
			If oXmlMvInt <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
						
				cMarca := oXmlMvInt:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				
				oXmlBusin := oXmlMvInt:_TotvsMessage:_BusinessMessage
				
				If XmlChildEx(oXmlBusin, '_BUSINESSEVENT') <> Nil .And. ;
					 XmlChildEx(oXmlBusin:_BusinessEvent, '_EVENT' ) <> Nil   
				
					cEvento := Upper( oXmlBusin:_BusinessEvent:_Event:Text )
					
					DbSelectArea('SRA')
					SRA->( DbSetOrder( 1 ) ) // RA_FILIAL + RA_MAT
					
					DbSelectArea("SP8")
					SP8->( DbSetOrder( 2 ) ) // P8_FILIAL + P8_MAT + P8_DATA + STR( P8_HORA, 5, 2)
					
					If Empty( cValExt ) .And. XmlChildEx(oXmlBusin, "_BUSINESSCONTENT" ) <> Nil .And. ;
						XmlChildEx(oXmlBusin:_BusinessContent, '_INTERNALID') <> Nil
							
						cValExt	:= oXmlBusin:_BusinessContent:_InternalId:Text
					
					ElseIf XmlChildEx(oXmlBusin:_BusinessEvent, '_IDENTIFICATION') <> Nil .And. ;
						 XmlChildEx(oXmlBusin:_BusinessEvent:_Identification, '_KEY') <> Nil
						
						cValExt := oXmlBusin:_BusinessEvent:_Identification:_Key:Text
					EndIf
					
					If XmlChildEx(oXmlBusin, "_BUSINESSCONTENT" ) <> Nil .And. ;
						XmlChildEx(oXmlBusin:_BusinessContent, '_EMPLOYEECODE') <> Nil
							
						cCodFunEx	:= oXmlBusin:_BusinessContent:_EmployeeCode:Text
					EndIf
					
					If Empty( cValExt ) .Or. Empty( cCodFunEx )
					
						lRet := .F.
						cXmlRet := STR0001 + ; // "Não identificada chave do registro ou funcionário para inclusão da marcação. Verifique as tags "
								"Identification-Key | InternalId"

					Else
					
						cValInt := CFGA070INT( cMarca, "SP8", "P8_MAT", cValExt )
						cValInt := PONN010Rcv( cValInt, { "P8_FILIAL", "P8_MAT", "P8_DATA", "P8_HORA" } )
						
						If !Empty( cValInt ) .And. SP8->( DbSeek( cValInt ) ) .And. SRA->( DbSeek( xFilial("SRA")+SP8->P8_MAT ) )
						
							If cEvento=="DELETE"
								nOpcx := 5
								
								cCodFun := SP8->P8_MAT 
								Aadd( aCabAuto,{"RA_FILIAL", SRA->RA_FILIAL, Nil })
								Aadd( aCabAuto,{"RA_MAT"   , cCodFun       , Nil })
								
								Aadd( aInteg,  {"P8_FILIAL", SP8->P8_FILIAL, Nil })
								Aadd( aInteg,  {"P8_MAT"   , cCodFun       , Nil })
							Else
								lRet := .F.
								cXmlRet := STR0002 // "Não é permitida a alteração da marcação, exclua e inclua novamente"
							EndIf
						Else
							xAux := IntFunInt( cCodFunEx, cMarca, "2.003")
							
							If xAux[1]
								
								cCodFun := xAux[2][2]+xAux[2][3]
		
								If !Empty(cCodFun) .AND. SRA->( DbSeek( cCodFun ) )
									
									If cEvento == "UPSERT"
										nOpcx := 3
										
										cCodFun := SRA->RA_MAT 
										Aadd( aCabAuto,{"RA_FILIAL", SRA->RA_FILIAL, Nil })
										Aadd( aCabAuto,{"RA_MAT"   , cCodFun       , Nil })
										
										Aadd( aInteg,  {"P8_FILIAL", xFilial("SP8"), Nil })
										Aadd( aInteg,  {"P8_MAT"   , cCodFun       , Nil })
									Else
										lRet := .F.
										cXmlRet := STR0003 // "Não é possível realizar a exclusão de um registro sem de-para."
									EndIf
									
								Else
									lRet := .F.
									cXMLRet := STR0004 // 'Não encontrado o Codigo de Matricula de Funcionário'
								EndIf
							Else
								lRet := .F.
								cXmlRet := xAux[2]
							EndIf
						EndIf
					EndIf
										
					If lRet
						If XmlChildEx(oXmlBusin:_BusinessContent, '_DATE') <> NIL
							
							cData := SToD( StrTran( SubStr( oXmlBusin:_BusinessContent:_Date:Text, 1, 10), "-", "" ) )
							Aadd( aInteg, { "P8_DATA", cData, Nil } )
							
						Else
							lRet := .F.
							cXMLRet := STR0005 + '"Date"' // 'Não existe a Tag '
						EndIf								
					EndIf										 
					
					If lRet
						If XmlChildEx(oXmlBusin:_BusinessContent, '_TIME') <> NIL
							nHora :=  Val( oXmlBusin:_BusinessContent:_Time:Text)
							Aadd( aInteg, { "P8_HORA", nHora, Nil } )
						Else
							cXMLRet := STR0005 + '"Time"' // 'Não existe a Tag '
						EndIf
					EndIf 
                    
					If lRet .And. XmlChildEx(oXmlBusin:_BusinessContent, '_REGISTERCHANGEREASON') <> NIL
						Aadd( aInteg, { "P8_MOTIVRG", SubStr( oXmlBusin:_BusinessContent:_RegisterChangeReason:Text, 1, TamSX3("P8_MOTIVRG")[1]), Nil } )
					EndIf
				
				EndIf
				
				If lRet
				
					BeginTran()
					
					aAdd( aItens, aClone( aInteg ) )
					
					aSize( aInteg, 0 )
					aInteg := Nil
					
					aInteg := Ponm010(		.F.				,;	//01 -> Se o "Start" foi via WorkFlow
											.F. 			,;	//02 -> Se deve considerar as configuracoes dos parametros do usuario
											.T.				,;	//03 -> Se deve limitar a Data Final de Apontamento a Data Base
											xFilial("SP8")	,;	//04 -> Filial a Ser Processada
											.F.				,;	//05 -> Processo por Filial
											.F.				,;	//06 -> Apontar quando nao Leu as Marcacoes para a Filial
											.F.				,;	//07 -> Se deve Forcar o Reapontamento
											aCabAuto		,;	//08 -> cabeçalho da marcação
											aItens			,;	//09 -> dia e horário para apontamento
											nOpcx    		,; 	//10 -> inclusão ou exclusão do apontamento
											)
					
					If Len(aInteg) > 0 .And. !(aInteg[1])
						
						DisarmTransaction()
						
						lRet := .F.	
						cXmlRet := ""
					
						For nCount := 1 to Len(aInteg[2])
							cXmlRet += aInteg[2,nCount] + "|"
						Next nCount
					
					ElseIf aInteg[1]
	
						cValInt := PONN010Snd( { cEmpAnt, xFilial("SP8"), cCodFun, DTOS( cData ), STR( nHora, 5, 2) } )
						
						If nOpcx <> 5
						
							CFGA070Mnt( cMarca, "SP8", "P8_MAT", cValExt, cValInt )
							
							//----------------------------------------------------------------
							//  Dados ok para gravação
							//----------------------------------------------------------------
							cXMLRet := '<ListOfInternalId>'
							cXMLRet += 	'<InternalId>'
							cXMLRet += 		'<Name>'+ "MARKINGPOINT" +'</Name>'
							cXMLRet += 		'<Origin>'+ cValExt +'</Origin>'
							cXMLRet += 		'<Destination>'+ cValInt +'</Destination>'
							cXMLRet += 	'</InternalId>'
							cXMLRet += '</ListOfInternalId>'
							
						Else
							CFGA070Mnt( , "SP8", "P8_MAT", , cValInt, .T. )
						EndIf
						
						EndTran()
						
					Else
						DisarmTransaction()
						lRet := .F.
						cXmlRet := STR0006 // "Erro no processamento"
					EndIf
				
				EndIf
				
			Else
				lRet := .F.
				cXMLRet := STR0007 + cXmlErro + ' | ' + cXmlWarn // 'Xml mal formatado '
			EndIf
		Else
			lRet := .F.
			cXmlRet := STR0008 // "Versão não tratada pelo Adapter"
		EndIf
		
	ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
		
		//----------------------------------------
		//  Trata a resposta do envio
		TrataResp( @lRet, @cXmlRet, cXml )
				
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		
		cXMLRet := cVerDispMU
		
	EndIf
	
ElseIf nTypeTrans == TRANS_SEND
	
	cValInt := PONN010Snd( { cEmpAnt, xFilial("SP8"), SP8->P8_MAT, DTOS( SP8->P8_DATA ), STR( SP8->P8_HORA, 5, 2 ) } )
	
	If !Inclui .AND. !Altera
		cEvento	:=	"delete"
		
		CFGA070MNT( , "SP8", "P8_MAT", , cValInt, .T. )
		
	EndIf

	cData := Transform( DToS( SP8->P8_DATA ), "@R 9999-99-99" )

	//Monta XML de envio de mensagem unica
	cXMLRet := ' <BusinessEvent>'
	cXMLRet +=     '<Entity>MarkingPoint</Entity>'
	cXMLRet +=     '<Event>' + cEvento + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="Code">' + cValInt + '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += ' </BusinessEvent>'
    
	cXMLRet += '<BusinessContent>'
	cXMLRet += 		'<CompanyId>'+ cEmpAnt +'</CompanyId>'
	//cXMLRet += 		'<BranchId>'+ xFilial("SP8") +'</BranchId>'
	cXMLRet += 		'<BranchId>'+ cFilAnt +'</BranchId>'
	cXMLRet += 		'<CompanyInternalId></CompanyInternalId>'
	cXMLRet += 		'<EmployeeCode>'+ IntFunExt( , , RTrim( SP8->P8_MAT ), "2.003" )[2] +'</EmployeeCode>'
	cXMLRet += 		'<InternalId>'+ cValInt +'</InternalId>'
	cXMLRet += 		'<Date>'+ cData +'</Date>'
	cXMLRet += 		'<Time>'+ cValToChar( SP8->P8_HORA ) +'</Time>'
	
	If Empty( SP8->P8_MOTIVRG  )
		cXMLRet += 		'<RegisterChangeReason>'+ "Marcacao ponto dia - " + cData +'</RegisterChangeReason>'
	Else
		cXMLRet += 		'<RegisterChangeReason>'+ Alltrim( SP8->P8_MOTIVRG ) +'</RegisterChangeReason>'
	EndIf
	cXMLRet += '</BusinessContent>'

EndIf

cXMLRet := Encodeutf8(cXMLRet)

Return { lRet, cXMLRet }

//-------------------------------------------------------------------
/*/{Protheus.doc} PONN010Snd
Rotina para integração por EAI 

@since 26/06/2013
@version P11
@params	aTempDados - valor para realizar o tratamento, inserindo pipes 
	na string de retorno
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function PONN010Snd( aTempDados )

Local nZ       := 1
Local cTempKey := ""

Default aTempDados := { cEmpAnt, P8_FILIAL, P8_MAT, DTOS( P8_DATA ), STR( P8_HORA, 5, 2 ) }

For nZ := 1 To Len( aTempDados )

	cTempKey += RTrim( aTempDados[nZ] ) + "|"

Next nZ

cTempKey := SubStr( cTempKey, 1, Len( cTempKey ) -1 )
	
Return cTempKey

//-------------------------------------------------------------------
/*/{Protheus.doc} PONN010Rcv
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
Function PONN010Rcv( cTmpKeyInt, aCposChave )

Local cTempKey  := ""
Local xAuxKey   := {}
Local nZ        := 0

Default cTmpKeyInt := ""
Default aCposChave := { "P8_FILIAL", "P8_MAT", "P8_DATA", "P8_HORA" }

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
						Upper( oObjXml:_InternalId[nZ]:_Name:Text ) == "MARKINGPOINT" .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_ORIGIN" ) <> Nil .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_DESTINATION" ) <> Nil
					
						CFGA070Mnt( cMarca, 'SP8', 'P8_MAT', ;
							oObjXml:_InternalId[nZ]:_Destination:Text, ;
							oObjXml:_InternalId[nZ]:_Origin:Text )
						
						Exit
					EndIf
				Next nZ
			
			Else
			
				lProcOk := .F.
				cMsgRet := STR0009 // "Não conteúdo de retorno para cadastro de de-para"
			
			EndIf
			
		Else
			
			lProcOk := .F.
			cMsgRet := STR0010 // "Não é possível gravar de-para por causa de erro na leitura do retorno"
		
		EndIf
		
	Else
	
		lProcOk 	:= .F.
		cMsgRet 	:= STR0011 + "|" // "Erro no processamento pela outra aplicação"
		
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
				cMsgRet := STR0012 // "Erro no processamento, mas sem detalhes do erro pela outra aplicação"
				
			EndIf
			
		EndIf
		
	EndIf

Else
	lProcOk 	:= .F.
	cMsgRet 	:= STR0013 + "|" + cXmlErro + "|" + cXmlWarn // "Falha na leitura da resposta, de-para não será gravado"
EndIf

oObjXml := Nil
DelClassIntF()

Return