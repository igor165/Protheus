#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PONI160.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPONI160    บAutor  ณ Flavio Correa      บ Data ณ  28/05/2014 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de integracao com o adapter EAI para recebimento e   บฑฑ
ฑฑบ          ณ envio de informacoes de Troca de Turno		               บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PONA160                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
                                                        
Function PONI160(cXML, nTypeTrans, cTypeMessage, cVersion)

Local aArea		:= GetArea()
Local lRet     	:= .T.
Local cXMLRet  	:= ""  
Local oXmlFunc	:= ""
Local cXmlErro	:= ""
Local cXmlWarn	:= ""	
Local cEvento	:= "upsert"
Local cValExt	:= ""
Local cValInt 	:= ""
Local cVersoesOk 	:= "1.000|"
Local cAux			:= ""
Local nOpcx			:= 3
Local nI			:= 1
Local nPosData	:= 0
Local nPosTnoPa	:= 0
Local nPosSeqPa	:= 0
Local nDelete	:= 0
Local nTamCols	:= 0
Local cXml1		:= ""
Local cXml2		:= ""
Local cXml3		:= ""
Default cVersion 	:= "1.000"

Private oXml           := ""
If ( Type("Inclui") == "U" )
	Private Inclui := .F.
EndIf

If ( Type("Altera") == "U" )
	Private Altera := .F.
EndIf

If nTypeTrans == TRANS_RECEIVE

	If cTypeMessage == EAI_MESSAGE_BUSINESS
/*
		Inclui := .F.
		Altera := .F.
	
		oXmlFunc := XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
	    oXml := oXmlFunc  
	    If oXmlFunc <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
	    If cVersion $ cVersoesOk
		    	cMarca := oXmlFunc:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		    
		    	
	        	If XmlChildEx(oXmlBus, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlBus:_BusinessEvent, '_EVENT' ) <> Nil
					
					cEvento := oXmlBus:_BusinessEvent:_Event:Text
					
					cValExt	:= If( ( XmlChildEx(oXmlBus:_BusinessEvent, '_IDENTIFICATION') <> Nil .And. ;
									XmlChildEx( oXmlBus:_BusinessEvent:_Identification, '_KEY') <> Nil ), ; 
									oXmlBus:_BusinessEvent:_Identification:_Key:Text, "" )
					
					cValExt := If( ( Empty( cValExt ) .And. XmlChildEx( oXmlBus:_BusinessContent, "_INTERNALID" ) <> Nil ), ;
									 oXmlBus:_BusinessContent:_InternalId:Text, ;
									 cValExt )
						
					If !Empty(cValExt)
					                        
						DbSelectArea("SPF")
						SPF->(DbSetOrder(1))
						
						cValInt := CFGA070INT( cMarca, 'SPF', 'PF_CODIGO', cValExt )
						
						If !Empty( cValInt )
							cValInt  := PONI160Rcv( cValInt, { "PF_FILIAL", "PF_MAT","PF_DATA" } )
						EndIf
								   					
					    If Empty(cValInt) .And. Upper(cEvento) == "UPSERT"
					    	nOpcx := 3
					    	Inclui := .T.
					    	
					    ElseIf !Empty(cValInt) .And. Upper(cEvento) == "UPSERT" .And. SPF->(DbSeek(cValInt))
					    	nOpcx := 4
					    	Altera	:= .T.
					    		
					    ElseIf !Empty(cValInt) .And. Upper(cEvento) == "DELETE" .And. SPF->(DbSeek(cValInt))
					    	nOpcx := 5
					    Else
					    
					      lRet := .F.
					      cXMLRet := STR0001 // 'Opera็ใo de inser็ใo, altera็ใo, exclusao e chave interna sใo inexistentes'
					      
					    EndIf
					    
					    If lRet
					    	PEI160( @lRet, @cXmlRet, oXmlBus, cMarca, cValExt )
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
 */
 		//
      	lRet := .F.
       	cXMLRet	:= STR0012 //"Adapter nใo preperado para recep็ใo de mensagens"
      
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		
		//-------------------------------------------------------
		//  tratando a recep็ใo da mensagem quando ้ realizado 
		// envio
		lRet := .T.
		TrataResp( @lRet, @cXMLRet, cXml )
		If lRet
			lErroInt := .F.
		Else
			lErroInt := .T.
		EndIf
		
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
	
		cXmlRet := cVersoesOk
	
	EndIf

ElseIf nTypeTrans == TRANS_SEND
	lRet := .T.
	nPosData	:= GdFieldPos( "PF_DATA" )
	nPosTnoPa	:= GdFieldPos( "PF_TURNOPA" )
	nPosSeqPa	:= GdFieldPos( "PF_SEQUEPA" )
	nDelete	:= GdFieldPos( "GDDELETED" )
	//If nTamCols > 0 
		cEvento	:= "upsert"
		
		cValInt := PONI160Snd( {  cEmpAnt, xFilial("SPF"), SRA->RA_MAT } ) 
	
	    If aColsInt[nDelete] .Or. lExc160 
			cEvento := "delete"
			
			CFGA070Mnt(    Nil, 'SPF', 'PF_CODIGO',		  Nil, cValInt, .T. ) // remove do de/para
	    EndIf

		cXML1 +='<BusinessEvent>'
		cXML1 +=     '<Entity>EmployeeHistoryWorkShift</Entity>'
	   	cXML1 +=     '<Event>'+ cEvento +'</Event>'
		cXML1 +=     '<Identification>'
		cXML1 +=         '<key name="Code">'+ cValInt +'</key>'
		cXML1 +=     '</Identification>'
		cXML1 +='</BusinessEvent>'
		cXML1 +='<BusinessContent>'
		cXML1 +=  '<CompanyId>'+ cEmpAnt +'</CompanyId>'
		//cXML1 +=  '<BranchId>'+ xFilial("SPF") +'</BranchId>'
		cXML1 +=  '<BranchId>'+ cFilAnt +'</BranchId>'
		cXML1 +=  '<CompanyInternalId>'+ cEmpAnt+"|"+xFilial("SPF") +'</CompanyInternalId>'
		cXML1 +=  '<EmployeeCode>'+SRA->RA_MAT+'</EmployeeCode>'
		cXML1 +=  '<EmployeeInternalId>'+IntFunExt( cEmpAnt, xFilial("SPF"), SRA->RA_MAT, "2.000" )[2]+'</EmployeeInternalId>'
		cXML1 +=  '<WorkShiftList>

		cXML2 +=  '	<WorkShiftId>
		cXML2 +=  '		<ChangedDate>'+Transform(DTOS(aColsInt[nPosData]), "@R 9999-99-99")+'</ChangedDate>'
		cXML2 +=  '		<WorkShiftCode>'+aColsInt[nPosTnoPa]+'</WorkShiftCode>'
		cXML2 +=  '		<WorkShiftInternalId>'+GPEI080Snd( { cEmpAnt, xFilial("SPF"), aColsInt[nPosTnoPa]} )+'</WorkShiftInternalId>'
		cXML2 +=  '		<WorkShiftSequence>'+aColsInt[nPosSeqPa]+'</WorkShiftSequence>'
		cXML2 +=  '	</WorkShiftId>

		cXML3 +=  '</WorkShiftList>
		cXML3 +='</BusinessContent>'
	//EndIf
	If !Empty(cXML2)
		cXMLRet := cXML1 + cXML2 + cXML3
	Else
		lRet := .F.
		cXMLRet := STR0013 //"Sem dados para envio."
	EndIf
EndIf  

RestArea(aArea)

cXmlRet := Encodeutf8(cXMLRet)

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
Static Function PEI160( lStatus, cXmlStatus, oXmlOper, cMarca, cValExtern ) 
Local cVlInt := ""
Local lDel	 := !Inclui .And. !Altera
Local aTroca := {}
Local cValExt := ""
Local aCodFunc	:= {}
Local cTurno	:= ""
 
If !Inclui
   cVlInt := CFGA070INT( cMarca, 'SPF', 'PF_CODIGO', cValExtern )
   cVlInt := PONI160Rcv( cVlInt, { "PF_FILIAL", "PF_MAT","PF_DATA" } )
EndIf

If !lDel 

	If XmlChildEx(oXmlOper, '_BUSINESSEVENT') <> Nil 

		If XmlChildEx( oXmlOper:_BusinessContent, "_EMPLOYEEINTERNALID"  ) <> Nil .And. ;
			!Empty( oXmlOper:_BusinessContent:_EmployeeInternalId:Text ) .And. ;
			XmlChildEx( oXmlOper, "_BUSINESSEVENT" ) <> Nil .And. ;
			XmlChildEx( oXmlOper:_BusinessEvent, "_EVENT" ) <> Nil
	
			cValExt := oXmlOper:_BusinessContent:_EmployeeInternalId:Text
			//dados do funcionario emp/filial/matricula
			aCodFunc := IntFunInt( cValExt, cMarca, "2.003")
		Endif				

		If XmlChildEx( oXmlOper:_BusinessContent, "_WORKSHIFTINTERNALID"  ) <> Nil .And. ;
			!Empty( oXmlOper:_BusinessContent:WorkShiftInternalId:Text ) .And. ;
			XmlChildEx( oXmlOper, "_BUSINESSEVENT" ) <> Nil .And. ;
			XmlChildEx( oXmlOper:_BusinessEvent, "_EVENT" ) <> Nil
	
			cValExtT := oXmlOper:_BusinessContent:WorkShiftInternalId:Text
			
			cTurno 	:= CFGA070INT( cMarca, 'SR6', 'R6_TURNO', cValExtT )
			cTurno 	:= GPEI080Rcv( cTurno, { "PF_FILIAL", "PF_TURNOPA" } )
			
			DbSelectArea('SR6')
			SR6->( DbSetOrder( 1 ) )
			If !Empty(cTurno) .Or. !SR6->( DbSeek( cTurno ) )
				lStatus := .F.
				cXmlStatus := "Turno nใo cadastrado"
			EndIf				
		Endif				

		//data altera็ใo
		lStatus := GetField(@aTroca,oXml,"oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ChangedDate:Text","PF_DATA",lStatus,'STOD( StrTran( SubStr( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ChangedDate:Text, 1, 10 ), "-", "") )')

		//Sequencia
		lStatus := GetField(@oMdlFc,oXml,"oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_WorkShiftSequence:Text","PF_SEQUEPA",lStatus)

		
	Else
		lStatus := .F.
		cXmlStatus := STR0006 + " BusinessContent" // 'Nใo existe a tag:'
	EndIf
	
EndIf

//gravar na tabela SPF

If lStatus

	cVlInt := PONI160Snd( { cEmpAnt, xFilial("SPF"), SPF->PF_MAT ,DTOS(SPF->PF_DATA) } )
	
	If lDel
		CFGA070Mnt(    Nil, 'SPF', 'PF_CODIGO',		  Nil, cVlInt, .T. ) // remove do de/para
	Else

		CFGA070Mnt( cMarca, 'SPF', 'PF_CODIGO', cValExtern, cVlInt )

		//---------//
		// De/Para //
		//---------//
		cXmlStatus := '<ListOfInternalId>'
		cXmlStatus += 	'<InternalId>'
		cXmlStatus += 		'<Name>'+ "EmployeeHistoryWorkShift" +'</Name>'
		cXmlStatus += 		'<Origin>'+ cValExtern +'</Origin>'
		cXmlStatus += 		'<Destination>'+ cVlInt +'</Destination>'
		cXmlStatus += 	'</InternalId>'
		cXmlStatus += '</ListOfInternalId>'
		
	EndIf
	
Else
	//------------------------------------------//
	//  Identificar erro do modelo para retorno //
	//------------------------------------------//
	cXmlStatus := ApErroMvc( oMdlOper )

EndIf

Return{ lStatus, cXmlStatus } 

//-------------------------------------------------------------------
/*/{Protheus.doc} PONI160Snd
Rotina para integra็ใo por EAI 

@since 14/05/2014
@version P11
@params	aTempDados - valor para realizar o tratamento, inserindo pipes 
	na string de retorno
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function PONI160Snd( aTempDados )

Local nZ       := 1
Local cTempKey := ""

Default aTempDados := {}

For nZ := 1 To Len( aTempDados )

	cTempKey += RTrim( aTempDados[nZ] ) + "|"

Next nZ

cTempKey := SubStr( cTempKey, 1, Len( cTempKey ) -1 )
	
Return cTempKey

//-------------------------------------------------------------------
/*/{Protheus.doc} PONI160Rcv
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
Function PONI160Rcv( cTmpKeyInt, aCposChave )

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
						Upper( oObjXml:_InternalId[nZ]:_Name:Text ) == "EMPLOYEEHISTORYWORKSHIFT" .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_ORIGIN" ) <> Nil .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_DESTINATION" ) <> Nil
					
						CFGA070Mnt( cMarca, 'SPF', 'PF_CODIGO', ;
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
Static Function GetField(aTroca,oXML,cTag,cCampo,lRet,cConteudo)
Default cConteudo := cTag

If lRet 
	If Type(cTag) <> "U" .AND. !Empty(&(cTag))
		aAdd(aTroca, {cCampo, &(cConteudo), Nil})
	Else
		lRet := .F.
	Endif
EndIf

Return lRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} ApErroMvc
	Apura o erro do mvc retornando uma string 

@since 26/06/2013
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
