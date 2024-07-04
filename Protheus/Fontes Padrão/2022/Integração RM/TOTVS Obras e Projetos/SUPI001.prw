#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TopConn.ch"
#Include "FWAdapterEAI.ch"  
#INCLUDE "COLORS.CH"                                                                                                     
#INCLUDE "TBICONN.CH"
#INCLUDE "COMMON.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "fileio.ch"
#INCLUDE "SUPI001.ch" 

#DEFINE  TAB  CHR ( 13 ) + CHR ( 10 )

//0=Não se aplica; 1=Apropriado Nota Fiscal; 2=Apropriado Medição; 3=Não apropriado                                               

/*
{Protheus.doc} SUPI001(cXML,nTypeTrans,cTypeMessage,cVersion)
	Processo de Apropriação de Despesas de Movimentos 
		
	@param	cXML      		Conteudo xml para envio/recebimento
	@param nTypeTrans		Tipo de transacao. (Envio/Recebimento)              
	@param	cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)
	@param	cVersion		Versão em uso
	
	@retorno aRet	Array contendo o resultado da execucao e a mensagem Xml de retorno.
			aRet[1]	(boolean) Indica o resultado da execução da função
			aRet[2]	(caracter) Mensagem Xml para envio  
				
	@author	Wesley Alves Pereira - TOTVS @version	P12				                           
	@since	01/08/2017
*/

Function SUPI001( cXML, nTypeTrans, cTypeMessage, cVersion)

Local aArea		:= GetArea()
Local aPc			:= {}
Local aGrvC7		:= {}
Local cDesPed		:= ""
Local cCodPed		:= ""
Local cFilPed		:= ""
Local cXMLRet		:= ""
Local cMarca		:= ""
Local cError		:= ""
Local cWarning	:= "" 
Local cFile		:= ""
Local nTamNod		:= 0
Local nXi			:= 0
Local lRet			:= .T.

Private oXmlOrder	:= Nil 
Private oXmlChild	:= Nil
Private aRecPed	:= {}
Private aErrPed	:= {}
Private aPrcPed	:= {}
Private aRetPed	:= {}

If ( nTypeTrans == TRANS_SEND )

	cXMLRet += '<BusinessRequest>'
	cXMLRet += 	'<Operation>SUPI001</Operation>'						
	cXMLRet += '</BusinessRequest>'
	
	cXMLRet += '<BusinessContent>'	
	cXMLRet += 	'<InternalId>' + cEmpAnt + '|' + xFilial("SC7") + '|' + SC7->C7_NUM + '</InternalId>'
	cXMLRet += 	'<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
	cXMLRet += 	'<CompanyId>' + cEmpAnt + '</CompanyId>'
	cXMLRet += 	'<BranchId>' + cFilAnt + '</BranchId>'
	cXMLRet += '</BusinessContent>'	

ElseIf ( nTypeTrans == TRANS_RECEIVE )

	If	( cTypeMessage == EAI_MESSAGE_WHOIS )
		
		cXMLRet := '1.000'
	
	//-- Recebimento da Business Message
	ElseIf ( cTypeMessage == EAI_MESSAGE_BUSINESS )   
	
		oXmlOrder := XmlParser( cXml, "_", @cError, @cWarning )
		
 		//Valida se houve erro no parser
		If ( oXmlOrder <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) )
			If Type("oXmlOrder:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U"
				cMarca := oXmlOrder:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			EndIf
			
			If Empty(cMarca)
				cXMLRet := STR0001 //"Produto de Integração não encontrado!"
				lRet := .F.	
				Return {lRet,cXMLRet}
			EndIf
			
			If SC7->(FieldPos("C7_APROPRM")) == 0
				cXMLRet := STR0002 //"Campo C7_APROPRM não existe no dicionário de dados!"
				lRet := .F.
				Return {lRet,cXMLRet}
			EndIf
			
			aRecPed := {}
			aErrPed := {}
			aPrcPed := {}
			aRetPed := {}			
						
			nTamNod := 0
			
			//Recebe a Listagem de Pedidos que serão alterados
			If Type("oXmlOrder:_TOTVSMESSAGE:_BusinessMessage:_BUSINESSCONTENT:_ListOfOrderInformation:_OrderInformation") <> "U" 					  
				If Type("oXmlOrder:_TOTVSMESSAGE:_BusinessMessage:_BUSINESSCONTENT:_ListOfOrderInformation:_OrderInformation[1]") <> "U"  
					nTamNod := Len(oXmlOrder:_TOTVSMESSAGE:_BusinessMessage:_BUSINESSCONTENT:_ListOfOrderInformation:_OrderInformation)
					
					//Percorre a Listagem de Periodos que serão enviados
					For nXi := 1 To nTamNod 
						oXmlChild := oXmlOrder:_TOTVSMESSAGE:_BusinessMessage:_BUSINESSCONTENT:_ListOfOrderInformation:_OrderInformation[nXi]
						
						If Type("oXmlChild:_OrderInternalId:TEXT")	<> "U"	.AND. Type("oXmlChild:_AssignmentType:TEXT")  <> "U"				 					
							aAdd(aRecPed,{oXmlChild:_OrderInternalId:TEXT,oXmlChild:_AssignmentType:TEXT,})
						Endif     					
					Next nXi 
				Else
					oXmlChild := oXmlOrder:_TOTVSMESSAGE:_BusinessMessage:_BUSINESSCONTENT:_ListOfOrderInformation:_OrderInformation
					If Type("oXmlChild:_OrderInternalId:TEXT") <> "U"	.AND. Type("oXmlChild:_AssignmentType:TEXT") <> "U"				 					
						aAdd(aRecPed,{oXmlChild:_OrderInternalId:TEXT,oXmlChild:_AssignmentType:TEXT,})
					Endif     					 					
	        	EndIf
			EndIf

			If Len(aRecPed) == 0
				cXMLRet := STR0003 //"Relação de Pedidos de Compras nao Informada!"
				lRet := .F.	
				Return {lRet,cXMLRet}
			EndIf			
				
			For nXi := 1 To Len (aRecPed)
				cDesPed := ""
				cCodPed := ""
				cFilPed := ""
				
				aPc := IntPdCInt(aRecPed[nXi][1],cMarca)
				
				If aPc[1]
					cCodPed	:= Padr(aPc[2][3],TamSX3("C7_NUM")[1])
					cFilPed	:= Padr(aPc[2][2],TamSX3("C7_FILIAL")[1])
					
					aAdd(aPrcPed,{cFilPed, cCodPed, aRecPed[nXi][2], Alltrim(Str(Val(aRecPed[nXi][2]))),aRecPed[nXi][1]})
				Else
					aAdd(aErrPed,{1,aRecPed[nXi][1],'', STR0004}) //"Warning! Não foi possível encontrar De/Para!"
					cXMLRet := cXMLRet + CHR(13)+CHR(10) + aPc[2] + CHR(13)+CHR(10)
					lRet := .F.
				Endif
			Next nXi
	       
	    	If lRet		
				aGrvC7 := SUPIGRVC7()
				If !aGrvC7[1]
					lRet := .F.
					cXmlRet := aGrvC7[2]
					Return {lRet,cXMLRet}
				Endif
			EndIf
		EndIf		
	EndIf	
EndIf

RestArea(aArea)
	
Return {lRet,cXMLRet}
 
/*
{Protheus.doc}
	Altera o campo de Apropriação (C7_APROPRM), informando o tipo de apropriação que o pedido terá
	@retorno Array de Processamentos
	@author	Wesley Alves Pereira - TOTVS @version	P12
	@since	27/06/2017
*/
Static Function SUPIGRVC7()

Local nXi	:= 1
Local aRet	:= {}

BEGIN TRANSACTION
	
	DBSelectArea("SC7")
	SC7->(DBSetOrder(1))

	For nXi := 1 To Len (aPrcPed)
		If SC7->(DBSeek(aPrcPed[nXi][1] + aPrcPed[nXi][2]))
			While SC7->(!EOF()) .and. SC7->C7_FILIAL == aPrcPed[nXi][1] .and. SC7->C7_NUM == aPrcPed[nXi][2]  
				If RecLock("SC7",.F.)		
					SC7->C7_APROPRM := aPrcPed[nXi][4]
					SC7->(MsUnLock())
				Else
					aAdd(aRet,.F.)
					aAdd(aRet,STR0005 + SC7->C7_NUM) //"Warning! Não foi possível Alterar o Pedido. Registro em Uso! - PC: "
				EndIf
				SC7->(DBSkip())
			EndDo
		Else
			aAdd(aRet,.F.)
			aAdd(aRet,STR0006 + SC7->C7_NUM) //"Warning! Não foi possível encontrar o código do Pedido. - PC: "
		EndIf
	Next nXi

END TRANSACTION

If Len(aRet) == 0
	aAdd(aRet,.T.)
	aAdd(aRet,"")
Endif

Return aRet
