#include 'protheus.ch'
#include 'parmtype.ch'
#include "FWADAPTEREAI.CH" 

#DEFINE DOCUMENTTYPE		1
#DEFINE DOCUMENTPREFIX		2
#DEFINE DOCUMENTNUMBER		3
#DEFINE DOCUMENTPARCEL		4
#DEFINE GROSSVALUE			5
#DEFINE NETVALUE			6

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A250FinPrt()
					Verifica se o contrato pode ser excluído com base nos títulos fo financeiro do
					Protheus
@Parametros			ExpC1 - Prefixo do tíutulo que foi gerado pelo Contrato de Carreteiro
					Expc2 - Alias da query com o contarato a ser excluído 
 				    ExpC3 - Rotina que originou o contrato de carreiro(Viagem "TMS" ou Carga"OMS")                          
@author leandro.paulino
@since 12/09/2016
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Static Function IntegDef( cXml, nType, cTypeMsg, cVersion )  
Local aRet := {}
//TransportDocumentStatus
aRet:= TMSI250BX( cXml, nType, cTypeMsg, cVersion )

Return aRet

/*/{Protheus.doc} TMSI250BX 
	Baixa de Contratos
//TODO 
@author caio.y
@since 29/11/2016
@version 1.0
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function

/*/
Function TMSI250BX( cXML, nTypeTrans, cTypeMessage)
Local cXMLRet  		:= ""
Local cError		:= ""
Local cWarning 		:= ""
Local cLogErro 		:= ""
Local lRet     		:= .T. 
Local cNumCTC		:= ""
Local cEvent		:= ""
Local cTypeDoc		:= ""
Local nCount		:= 1
Local aTitulos		:= {}  
Local aCab			:= {}
Local aErroAuto		:= {}  
Local aArea			:= GetArea()
Local cDocType		:= ""
Local cDocPref		:= ""
Local cDocNum		:= ""
Local cDocID		:= ""
Local cDocPar		:= ""
Local cMarca		:= ""
Local cValExt		:= ""
Local cValInt		:= ""
Local nValBrut		:= 0
Local nValLiq		:= 0
Local aRet			:= {} 
Local nPosAt 		:= 0
Local lTMI250Bx		:= ExistBlock('TMI250BX')

Private oXml250		  	:= Nil
Private oXMLList		:= Nil
Private nCountO10	  	:= 0
Private lMsErroAuto    	:= .F.
Private lAutoErrNoFile 	:= .T.   

If Type("Altera") == "U"
	Altera := .T.
EndIf

If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		oXml250 := XmlParser(cXml, "_", @cError, @cWarning)
		
		If oXml250 <> Nil .And. Empty(cError) .And. Empty(cWarning)			
			
			If Type("oXml250:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text") <> "U"
				cEvent	:= oXml250:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text
			EndIf
			
			If Type("oXml250:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U" 					
				cMarca :=  AllTrim(oXml250:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
			EndIf
			
			If Type("oXml250:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentId:Text") <> "U"
				cValExt		:= oXml250:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
				cValInt    	:= CFGA070INT( cMarca ,  "DTY" ,"DTY_NUMCTC", cValExt )
				If lTMI250Bx
					cNumCTC := ExecBlock('TMI250BX',.F.,.F.,{CVALINT,1})			     	
				Else
					cNumCTC    	:= SUBSTR(CVALINT,FwSizeFilial()+2,TamSX3('DTY_NUMCTC')[1])
				EndIf
				nPosAt 		:=  at('|',cnumctc) 
				If nPosAt > 0 
					cNumCTC := SUBSTR(cNumCTC,1,nPosAt-1)
				EndIf
			EndIf 
					
			If Type("oXml250:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentType:Text") <> "U"			
				/*------------------------------------------
				//DocumentType
				1=Viagem
				2=Contrato Carreteiro
				3=Ocorrência
				4=Seguro
				5=Custo de Transporte
				6=Contrato Complementar
				7=Pedágio
				-------------------------------------------*/
				cTypeDoc	:= oXml250:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentType:Text
			EndIf 
			
			If XmlChildEx( oXml250:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_LISTOFACCOUNTPAYABLEDOCUMENT') <> Nil	
				oXMLList := oXml250:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAccountPayableDocument
							
				If XmlChildEx( oXMLList, "_ACCOUNTPAYABLEDOCUMENT" ) <> Nil
					
					If Valtype( oXMLList:_AccountPayableDocument ) <> "A"
						XmlNode2Arr( oXMLList:_AccountPayableDocument, "_AccountPayableDocument" )
					EndIf
					
					For nCount := 1 To Len( oXMLList:_AccountPayableDocument )
						If Type("oXMLList:_AccountPayableDocument[" + Str(nCount) + "  ]:_DocumentTypeCode:Text" ) <> "U"
							cDocType	:= oXMLList:_AccountPayableDocument[nCount]:_DocumentTypeCode:Text
						EndIf	
						
						If Type("oXMLList:_AccountPayableDocument[" + Str(nCount) + "  ]:_DocumentPrefix:Text" ) <> "U"
							cDocPref	:= oXMLList:_AccountPayableDocument[nCount]:_DocumentPrefix:Text
						EndIf	
						
						If Type("oXMLList:_AccountPayableDocument[" + Str(nCount) + "  ]:_DocumentNumber:Text" ) <> "U"
							cDocNum		:= oXMLList:_AccountPayableDocument[nCount]:_DocumentNumber:Text
						EndIf				
						
						If Type("oXMLList:_AccountPayableDocument[" + Str(nCount) + "  ]:_DocumentParcel:Text" ) <> "U"
							cDocPar		:= oXMLList:_AccountPayableDocument[nCount]:_DocumentParcel:Text
						EndIf						
						
						If Type("oXMLList:_AccountPayableDocument[" + Str(nCount) + "  ]:_DocumentInternalId:Text" ) <> "U"
							cDocID		:= oXMLList:_AccountPayableDocument[nCount]:_DocumentInternalId:Text
						EndIf						
						
						If Type("oXMLList:_AccountPayableDocument[" + Str(nCount) + "  ]:_GrossValue:Text" ) <> "U"
							nValBrut	:= Val( oXMLList:_AccountPayableDocument[nCount]:_GrossValue:Text ) 
						EndIf						
						
						If Type("oXMLList:_AccountPayableDocument[" + Str(nCount) + "  ]:_NetValue:Text" ) <> "U"
							nValLiq		:= Val( oXMLList:_AccountPayableDocument[nCount]:_NetValue:Text )
						EndIf						
						
						Aadd( aTitulos , { cDocType, cDocNum , cDocPar , cDocID , nValBrut , nValLiq }  )
						
					Next nCount
				EndIf
			EndIf
			
			If cTypeDoc	== "2" //-- Contrato de Carreteiro

				If lTMI250Bx
					cNumCTC := ExecBlock('TMI250BX',.F.,.F.,{cNumCTC,2})     	
				EndIf
	
				aRet	:= AtuContrato("1", cNUmCTC, aTitulos )
				lRet	:= aRet[1]
					
				If !lRet
					
					cXMLRet := EncodeUTF8(aRet[2])
				Else
												
			       //-- Monta o XML de Retorno
	               cXmlRet := "<ListOfInternalId>"
	               cXmlRet +=    "<InternalId>"
	               cXmlRet +=       "<Name>TransportDocumentStatus</Name>"
	               cXmlRet +=       "<Origin>" 		+ cValInt + "</Origin>"
	               cXmlRet +=       "<Destination>"	+ cValExt + "</Destination>"
	               cXmlRet +=    "</InternalId>"
	               cXmlRet += "</ListOfInternalId>"
	                
				EndIf 
			Else
			
				cXmlRet := "<ListOfInternalId>"
				cXmlRet +=    "<InternalId>"
				cXmlRet +=       "<Name>TransportDocumentStatus</Name>"
				cXmlRet +=       "<Origin>" 	+ cValInt + "</Origin>"
	            cXmlRet +=       "<Destination>"+ cValExt + "</Destination>"
				cXmlRet +=    "</InternalId>"
				cXmlRet += "</ListOfInternalId>"
				
			EndIf
						
		Else
			
			// "Falha ao gerar o objeto XML"
			lRet := .F.
			cXMLRet := "Falha ao manipular o XML"
			
		EndIf

	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		cXMLRet := '<TAGX>TESTE DE RECEPCAO RESPONSE MESSAGE</TAGX>'
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := "1.000|2.000"				   
	EndIf
	
ElseIf nTypeTrans == TRANS_SEND

	    
EndIf

RestArea( aArea )
Return { lRet, cXMLRet }   

/*/{Protheus.doc} AtuContrato
//TODO Descrição auto-gerada.
@author caio.y
@since 30/11/2016
@version undefined
@param cTipo, characters, descricao
@param cNumCTC, characters, descricao
@param aTitulos, array, descricao
@type function
/*/
Static Function AtuContrato( cTipo , cNumCTC , aTitulos )
Local lRet		:= .T. 
Local aArea		:= GetArea()
Local aAreaDTY	:= DTY->(GetArea())
Local cErro		:= ""
Local nCount	:= 1
Local nValBrut	:= 0 
Local nSaldo	:= 0
Local cStatus	:= ""
Local lLibCTC 	:= SuperGetMV( 'MV_LIBCTC' ,,.F.)

Default cTipo		:= ""
Default cNumCtc		:= ""
Default aTitulos	:= {}

If cTipo == "1" //-- Status do Contrato
	
	/*-----------------------------------------------------------
	DTY_STATUS:
	1=Em Aberto;
	2=Aguard. Lib. p/ Pagto;
	3=Lib. p/ Pagto;
	4=Contr. Quit. com Ped. Compras;
	5=Contr. Quitado/Pagto. Realiz;
	6=Tit. Fatura
	------------------------------------------------------------*/

	DTY->(dBSetOrder(1))
	If DTY->(MsSeek(xFilial("DTY") + cNumCTC ))

		For nCount := 1 To Len(aTitulos)
			nValBrut	+= aTitulos[nCount][GROSSVALUE]
			nSaldo		+= aTitulos[nCount][NETVALUE]
		Next nCount
		
		If nSaldo <= 0 
			cStatus	:= "5" //-- Quitado			
		ElseIf nSaldo <> nValBrut
			cStatus	:= "A" //-- Pagto Parcial
		ElseIf nSaldo == nValBrut .And. DTY->DTY_CODOPE== '01' .And. DTY->DTY_LOCQUI != '1' // Se quita em filial, aguarda aviso de pagamento
            cStatus := "8" //-- Contrato Pago Pela Operadora. Aguardando Baixa financeira.
		ElseIf 	nSaldo == nValBrut
			If lLibCTC
				cStatus	:= "2" //-- Aguardando liberação para pagamento
			Else
				cStatus := "3" //-- Liberado para pagamento
			EndIf
		EndIf
		
		RecLock("DTY",.F.)
		DTY->DTY_STATUS	:= cStatus		
		MsUnlock()
	Else
		lRet	:= .F. 
		cErro	:= "Contrato não encontrado!"
	EndIf
	
EndIf

RestArea(aAreaDTY)
RestArea(aArea)

Return { lRet , cErro } 
