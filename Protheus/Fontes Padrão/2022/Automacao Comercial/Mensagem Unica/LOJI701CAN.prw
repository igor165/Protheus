#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.ch"
#INCLUDE "LOJI701CAN.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Função para chamada do adapter ao receber/enviar a mensagem única de verificação de cancelamento de venda

@param cXml, XML recebido pelo EAI Protheus
@param nType, Tipo de transação ("0" = TRANS_RECEIVE, "1" = TRANS_SEND)
@param cTypeMsg, Tipo da mensagem do EAI ("20" = EAI_MESSAGE_BUSINESS, "21" = EAI_MESSAGE_RESPONSE
"22" = EAI_MESSAGE_RECEIPT, "23" = EAI_MESSAGE_WHOIS)
@param cVersion, Versão da Mensagem Única TOTVS

@author Pedro Alencar
@since 17/01/2017
@version P12.1.16
/*/
//-------------------------------------------------------------------------------------------------

Static Function IntegDef( cXml, nType, cTypeMsg, cVersion )

	Local aRet := {}
	aRet := LOJI701CAN( cXml, nType, cTypeMsg, cVersion )

Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINI791CAN
Adapter de verificação de cancelamento de venda

@param cXml, XML da mensagem
@param nType, Determina se é uma mensagem a ser enviada ou recebida (TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMsg, Tipo de mensagem (EAI_MESSAGE_WHOIS, EAI_MESSAGE_RESPONSE ou EAI_MESSAGE_BUSINESS)
@param cVersion, Versão da Mensagem Única TOTVS

@return lRet, Indica se a mensagem foi processada com sucesso
@return cXmlRet, XML de retorno do adapter

@author Pedro Alencar
@since 17/01/2017
@version P12.1.16
/*/
//-------------------------------------------------------------------------------------------------

Function LOJI701CAN( cXml, nType, cTypeMessage, cVersion  )
	Local aArea := GetArea()
	Local lRet := .T.
	Local cXMLRet := ""

	If ( nType == TRANS_RECEIVE )

		If ( cTypeMessage == EAI_MESSAGE_WHOIS )

			cXmlRet := "1.000"

		ElseIf ( cTypeMessage == EAI_MESSAGE_BUSINESS )

			lRet := RecBusXML( cXml, @cXMLRet )

		EndIf
	ElseIF nType == TRANS_SEND
		lRet := .F.
		cXmlRet := STR0001 //"Operação de envio não implementada."
	Endif

	RestArea( aArea )

Return {lRet, cXmlRet, "RETAILSALESCANCELLATIONALLOWANCE"}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RecBusXML
Função para tratar o XML recebido na mensagem de Business

@param cXml, XML recebido
@param cXMLRet, Variável com a mensagem de resposta. Passada por referência.
@return lRet, Indica se processou a mensagem recebida com sucesso

@author Pedro Alencar
@since 17/01/2017
@version P12.1.16
/*/
//-------------------------------------------------------------------------------------------------

Static Function RecBusXML( cXml, cXMLRet )
	Local lRet := .T.
	Local lCancel := .T.
	Local oXML := Nil
	Local cMarca := ""
	Local cExtVenda := ""
	Local aRetVenda := {}
	Local cPathBC := "/TOTVSMessage/BusinessMessage/BusinessContent/"
	Local aChaveVend := {}
	Local cErroRet := ""
	
	oXML := tXMLManager():New()
	lRet := oXML:Parse( cXml )

	If lRet
		cMarca := oXml:XPathGetAtt( "/TOTVSMessage/MessageInformation/Product", "name" )

		//Verifica se existe o Registro no XXF para saber se é Inclusão ou Alteração
		cExtVenda := oXml:XPathGetNodeValue( cPathBC + "RetailSalesInternalId" )
		If ! Empty( cExtVenda )
			aRetVenda := IntVendInt( cExtVenda, cMarca )
			If aRetVenda[1] //Se o registro foi encontrado na tabela de de/para
				aChaveVend := aRetVenda[2]
			Else
				lRet := .F.
				cXmlRet := STR0002 + cExtVenda //"A venda informada não foi encontrada no de/para Protheus: "
			EndIf
		Else
			aAdd( aRetVenda, .F. )
			lRet := .F.
			cXmlRet := STR0003 //"É obrigatório informar um valor na tag 'RetailSalesInternalId'"
		EndIf  

	Else
		cXmlRet := STR0004 //"Houve um erro no tratamento do XML. Verifique se o mesmo está sendo informado corretamente."
	EndIf
	
	If lRet 
		//Verifica se pode excluir os títulos gerados na venda
		lCancel := LJ701CTit( aChaveVend, @cErroRet )
		
		If lCancel 
			cXMLRet := "<IsCancellable>true</IsCancellable>"
			cXMLRet += "<Message></Message>"
		Else
			cXMLRet := "<IsCancellable>false</IsCancellable>"
			cXMLRet += "<Message>" + AllTrim( cErroRet ) + "</Message>"
		Endif		
	Endif
	
	aSize ( aRetVenda, 0 )
	aRetVenda := Nil
	aSize ( aChaveVend, 0 )
	aChaveVend := Nil
		
	oXML := Nil
	DelClassIntF()

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LJ701CTit
Função que verifica se pode excluir os títulos gerados na venda

@param aChaveVend, Vetor com a chave da venda cujos títulos serão verificados
@param cErroRet, Variável com a mensagem de resposta. Passada por referência.
@return lRet, Indica se pode excluir os títulos

@author Pedro Alencar
@since 17/01/2017
@version P12.1.16
/*/
//-------------------------------------------------------------------------------------------------

Static Function LJ701CTit( aChaveVend, cErroRet )
	Local lRet := .T. 
	Local cChaveVend := ""
	Local cSeekTit := ""
	Local cChaveTitR := ""
	Local aAreaSL1 := SL1->( GetArea() )
	Local aAreaSE1 := SE1->( GetArea() )
	
	SL1->( dbSetOrder( 2 ) ) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
	SE1->( dbSetOrder( 1 ) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	
	cChaveVend := FWxFilial("SL1") + Padr( aChaveVend[3], TamSx3("L1_SERIE")[1] ) + Padr( aChaveVend[4], TamSx3("L1_DOC")[1] ) + Padr( aChaveVend[5], TamSx3("L1_PDV")[1] )
	If SL1->( MsSeek( cChaveVend ) )

		//Titulos a receber
		cSeekTit := FWxFilial("SE1") + Padr( aChaveVend[3], TamSx3("E1_PREFIXO")[1] ) + Padr( aChaveVend[4], TamSx3("E1_NUM")[1] )
		If SE1->( MsSeek( cSeekTit ) )
			
			While SE1->( ! EOF() ) .AND. SE1->( E1_FILIAL + E1_PREFIXO + E1_NUM ) == cSeekTit 
				cChaveTitR := cSeekTit + SE1->E1_PARCELA + SE1->E1_TIPO
				
				//Verifica se o título a receber pode ser excluido
				lRet := VerifCanCR( cChaveTitR, 1, @cErroRet, .T. )
				
				If !lRet
					Exit
				Endif 
				
				cChaveTitR := ""
				SE1->( dbSkip() )
			EndDo
		
		Else
	
			lRet := .F. 
			cErroRet := STR0005 + cSeekTit //"Este título a receber não foi encontrado no Protheus: "
				
		Endif
	Else
	
		lRet := .F.
		cErroRet := STR0006 + cChaveVend //"Esta venda não foi encontrada no Protheus: "
		
	Endif
	
	RestArea( aAreaSL1 )
	aSize( aAreaSL1, 0 )
	aAreaSL1 := {}
	RestArea( aAreaSE1 )
	aSize( aAreaSE1, 0 )
	aAreaSE1 := {}
Return lRet