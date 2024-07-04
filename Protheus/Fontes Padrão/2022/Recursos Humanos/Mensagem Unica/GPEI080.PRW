#INCLUDE "PROTHEUS.CH"   
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "GPEI080.CH"



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Integdef  ºAutor  ³Microsiga           º Data ³  09/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e  º±±
±±º          ³ envio de informações do cadastro de Turno de Trabalho	  º±±
±±º          ³ (SR6) utilizando o conceito de mensagem unica. 		      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA080                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GPEI080( cXML, nTypeTrans, cTypeMessage, cVersao )

Local lRet			:= .T.
Local lSX8			:= .F.

Local cTurnoEx		:= ""           //Codigo externo de Turno
Local cTurno	  	:= ""           //Codigo interno da Turno
Local cRegHora  	:= ""           //Horas mensal de trabalho
Local cRestHora		:= ""           //Horas mensal de DSR
Local cDescr		:= ""			//Descrição do Turno
Local cValExt		:= ""
Local cValInt		:= ""
Local cSR6Key		:= ""

Local cXMLRet	  	:= ""
Local cEvento		:= "upsert"
Local cXmlErro		:= ""
Local cXmlWarn		:= ""
Local cLogErro  	:= "" 

Local aErroAuto		:= {}
Local aTurno		:= {}
Local aArea			:= GetArea()

Local nMinhNot		:= 0
Local nCount		:= 0
Local nOpcx			:= 0

Local oXmlMvInt		:= Nil
Local oXmlBusin		:= Nil

Local cVersoes  	:= "1.000|"
Local lIniPad   	:= !Empty( GetSX3Cache( "R6_TURNO", "X3_RELACAO" ) )

Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.
Private lMsHelpAuto    := .T.


Default cVersao := "1.000"

If nTypeTrans == TRANS_RECEIVE
	
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		
		Private Altera		:= .F.
		Private Inclui		:= .F.
		
		If cVersao $ cVersoes
			oXmlMvInt	:= XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
			
			If oXmlMvInt <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
						
				cMarca := oXmlMvInt:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				
				oXmlBusin := oXmlMvInt:_TotvsMessage:_BusinessMessage
				
				If XmlChildEx(oXmlBusin, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent, '_EVENT' ) <> Nil   
				
					cEvento := oXmlBusin:_BusinessEvent:_Event:Text
					
					If XmlChildEx(oXmlBusin:_BusinessEvent, '_IDENTIFICATION') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent:_Identification, '_KEY') <> Nil
						
						cValExt := oXmlBusin:_BusinessEvent:_Identification:_Key:Text
						
					EndIf				
					
					If FindFunction("CFGA070INT")
						              
						If XmlChildEx(oXmlBusin:_BusinessContent, '_INTERNALID') <> NIL
							
							cTurnoEx	:= oXmlBusin:_BusinessContent:_InternalId:Text
							
							If Empty( cValExt ) 
								cValExt := cTurnoEx
							EndIf
							
							cTurno 	:= CFGA070INT( cMarca, 'SR6', 'R6_TURNO', cTurnoEx )
							cTurno 	:= GPEI080Rcv( cTurno, { "R6_FILIAL", "R6_TURNO" } )
							
							DbSelectArea('SR6')
							SR6->( DbSetOrder( 1 ) )
							
							If !Empty(cTurno) .AND. SR6->( DbSeek( cTurno ) )
							
								If ( Upper( cEvento ) == "UPSERT" )
									nOpcx	:= 4 
									Altera	:= .T.
								
								ElseIf ( Upper( cEvento ) == "DELETE" ) .AND.;
										!Empty(cTurno) .AND. SR6->( DbSeek( cTurno ) )
									nOpcx := 5
								
								Else
									lExecAuto	:= .F.
								EndIf
								
								cTurno := SR6->R6_TURNO 
								Aadd( aTurno, {"R6_TURNO", cTurno, Nil })
								
							ElseIf Empty(cTurno) .And. Upper( cEvento ) == "UPSERT"
								
								nOpcx	:= 3
								Inclui	:= .T.
								
								If !lIniPad
									While .T.
										cTurno := GETSX8NUM("SR6","R6_TURNO")
										If SR6->( DbSeek( xFilial("SR6")+cTurno ) )
											ConfirmSX8()
										Else
											Exit
										EndIf
									End
									
									aAdd( aTurno, {"R6_TURNO", cTurno, Nil })
									lSX8 := .T.
								EndIf
								
							Else
								lRet := .F.
								cXMLRet := STR0001 // 'Não encontrado o Codigo de Turno de Trabalho'
							EndIf
						Else
						
							lRet := .F.
							cXmlRet := STR0002 + " InternalId." // "Código não enviada na tag "
						
						EndIf
						
						If lRet
							If XmlChildEx(oXmlBusin:_BusinessContent, '_DESCRIPTION') <> NIL
	
								Aadd( aTurno, { "R6_DESC", oXmlBusin:_BusinessContent:_Description:Text, Nil })
								
							Else
								lRet := .F.
								cXMLRet := STR0003 + 'Description' // 'Não existe a Tag ' ####
							EndIf								
						EndIf										 
						
						If lRet
							If XmlChildEx(oXmlBusin:_BusinessContent, '_REGULARHOUR') <> NIL
								cRegHora :=  Val( oXmlBusin:_BusinessContent:_RegularHour:Text)
								Aadd( aTurno, { "R6_HRNORMA", cRegHora, Nil })
							Else
								cXMLRet := STR0003 + 'RegularHour' // 'Não existe a Tag ' ####
							EndIf
						EndIf 
	                    
						If lRet
							If XmlChildEx(oXmlBusin:_BusinessContent, '_RESTHOUR') <> NIL
								cRestHora := Val( oXmlBusin:_BusinessContent:_RestHour:Text)
								Aadd( aTurno, { "R6_HRDESC", cRestHora, Nil })
							Else
								cXMLRet := STR0003 + 'RestHour' // 'Não existe a Tag ' ####
							EndIf
						EndIf
						
						If lRet
							nMinhNot := SuperGetMv("MV_MINHNOT")
							Aadd( aTurno, { "R6_MINHNOT", nMinhNot, Nil })
						EndIf
						
					Else
						lRet   := .F.
						cXMLRet := STR0004 // "Atualize EAI"
					EndIf
				EndIf
				
				If lRet
					BeginTran()
					
					MsExecAuto({|x,y| GPEA080(x,y)},aTurno,nOpcx)
					
					If lMsErroAuto
						
						DisarmTransaction()
						
						RollBackSX8()
						aErroAuto:= GetAutoGRLog()
						
						For nCount := 1 To Len(aErroAuto)
							cLogErro += StrTran( StrTran( StrTran( aErroAuto[nCount], "/", "" ), "<", "" ), ">", "" ) + ("|")
						Next nCount
						
						lRet	 := .F.
						cXMLRet := EncodeUTF8( cLogErro )
		
					Else
						EndTran()
						
						ConfirmSX8()
						cValInt := GPEI080Snd( { cEmpAnt, xFilial("SR6"), SR6->R6_TURNO } )
						
						If nOpcx == 5
						
							CFGA070Mnt( , "SR6", "R6_TURNO", , cValInt, .T. )
							
						Else
						
							CFGA070Mnt( cMarca, "SR6", "R6_TURNO", cValExt, cValInt )
							
							//----------------------------------------------------------------
							//  Dados ok para gravação
							//----------------------------------------------------------------
							cXMLRet := '<ListOfInternalId>'
							cXMLRet += 	'<InternalId>'
							cXMLRet += 		'<Name>'+ "ShiftWork" +'</Name>'
							cXMLRet += 		'<Origin>'+ cValExt +'</Origin>'
							cXMLRet += 		'<Destination>'+ cValInt +'</Destination>'
							cXMLRet += 	'</InternalId>'
							cXMLRet += '</ListOfInternalId>'
						 
						EndIf
						
					EndIf
					
				EndIf
					
			Else
				lRet := .F.
				cXMLRet := STR0005 + cXmlErro + '|' + cXmlWarn // 'Xml mal formatado '
			EndIf
		Else
			
			lRet := .F.
			cXmlRet := STR0006 + cVersoes // "Versão não tratada pelo adapter, as possíveis são: "
			
		EndIf
		
	ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
		
		//-------------------------------------------------------
		//  tratando a recepção da mensagem quando é realizado 
		// envio
		TrataResp( @lRet, @cXMLRet, cXml )
		
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := cVersoes
	EndIf
	
ElseIf nTypeTrans == TRANS_SEND
	
	cValInt := GPEI080Snd( {cEmpAnt, xFilial("SR6"), SR6->R6_TURNO } )
	
	If !Inclui .AND. !Altera
		cEvento	:=	"Delete"
		
		CFGA070Mnt( , "SR6", "R6_TURNO", , cValInt, .T. )
	EndIf
	
	//Monta XML de envio de mensagem unica
	cXMLRet := ' <BusinessEvent>'
	cXMLRet +=     '<Entity>ShiftWork</Entity>'
	cXMLRet +=     '<Event>' + cEvento + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="Code">' + cValInt + '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += ' </BusinessEvent>'

	cXMLRet += '     <BusinessContent>'
	cXMLRet += '       <CompanyId>'+ cEmpAnt +'</CompanyId>'
	//cXMLRet += '       <BranchId>'+ xFilial("SR6") +'</BranchId>'
	cXMLRet += '       <BranchId>'+ cFilAnt +'</BranchId>'
	cXMLRet += '       <Code>'+ SR6->R6_TURNO +'</Code>'
	cXMLRet += '       <InternalId>' + cValInt + '</InternalId>'
	cXMLRet += '       <Description>'+ SR6->R6_DESC +'</Description>'
	cXMLRet += '       <RegularHour>'+ CValToChar(SR6->R6_HRNORMA) +'</RegularHour>'
	cXMLRet += '       <RestHour>'+ CValToChar(SR6->R6_HRDESC) +'</RestHour>'
	cXMLRet += '     </BusinessContent>'
	
EndIf

RestArea(aArea)

cXMLRet := Encodeutf8(cXMLRet)

Return { lRet, cXMLRet }   

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEI080Snd
Rotina para integração por EAI 

@since 26/06/2013
@version P11
@params	aTempDados - valor para realizar o tratamento, inserindo pipes 
	na string de retorno
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function GPEI080Snd( aTempDados )

Local nZ       := 1
Local cTempKey := ""

Default aTempDados := {}

For nZ := 1 To Len( aTempDados )

	cTempKey += RTrim( aTempDados[nZ] ) + "|"

Next nZ

cTempKey := SubStr( cTempKey, 1, Len( cTempKey ) -1 )
	
Return cTempKey

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEI080Rcv
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
Function GPEI080Rcv( cTmpKeyInt, aCposChave )

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
						Upper( oObjXml:_InternalId[nZ]:_Name:Text ) == "SHIFTWORK" .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_ORIGIN" ) <> Nil .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_DESTINATION" ) <> Nil
					
						CFGA070Mnt( cMarca, 'SR6', 'R6_TURNO', ;
							oObjXml:_InternalId[nZ]:_Destination:Text, ;
							oObjXml:_InternalId[nZ]:_Origin:Text )
						
						Exit
					EndIf
				Next nZ
			
			Else
			
				lProcOk := .F.
				cMsgRet := STR0007 // "Não enviado conteúdo de retorno para cadastro de de-para"
			
			EndIf
			
		Else
			
			lProcOk := .F.
			cMsgRet := STR0008 // "Não é possível gravar de-para por causa de erro na leitura do retorno"
		
		EndIf
		
	Else
	
		lProcOk 	:= .F.
		cMsgRet 	:= STR0009 + "|" // "Erro no processamento pela outra aplicação"
		
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
				cMsgRet := STR0010 // "Erro no processamento, mas sem detalhes do erro pela outra aplicação"
				
			EndIf
			
		EndIf
		
	EndIf

Else
	lProcOk 	:= .F.
	cMsgRet 	:= STR0011 + "|" + cXmlErro + "|" + cXmlWarn // "Falha na leitura da resposta, de-para não será gravado"
EndIf

oObjXml := Nil
DelClassIntF()

Return