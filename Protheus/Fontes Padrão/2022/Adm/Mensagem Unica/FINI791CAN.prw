#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.ch"
#INCLUDE "FINI791CAN.CH"

/*/{Protheus.doc} IntegDef
Fun��o para chamada do adapter ao receber/enviar a mensagem �nica de verifica��o de cancelamento de fatura

@param cXml, XML recebido pelo EAI Protheus
@param nType, Tipo de transa��o ("0" = TRANS_RECEIVE, "1" = TRANS_SEND)
@param cTypeMsg, Tipo da mensagem do EAI ("20" = EAI_MESSAGE_BUSINESS, "21" = EAI_MESSAGE_RESPONSE
"22" = EAI_MESSAGE_RECEIPT, "23" = EAI_MESSAGE_WHOIS)
@param cVersion, Vers�o da Mensagem �nica TOTVS

@author Pedro Alencar
@since 17/01/2017
@version P12.1.16
/*/
Static Function IntegDef( cXml, nType, cTypeMsg, cVersion )

	Local aRet := {}
	aRet := FINI791CAN( cXml, nType, cTypeMsg, cVersion )

Return aRet

/*/{Protheus.doc} FINI791CAN
Adapter de verifica��o de cancelamento de fatura

@param cXml, XML da mensagem
@param nType, Determina se � uma mensagem a ser enviada ou recebida (TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMsg, Tipo de mensagem (EAI_MESSAGE_WHOIS, EAI_MESSAGE_RESPONSE ou EAI_MESSAGE_BUSINESS)
@param cVersion, Vers�o da Mensagem �nica TOTVS

@return lRet, Indica se a mensagem foi processada com sucesso
@return cXmlRet, XML de retorno do adapter

@author Pedro Alencar
@since 17/01/2017
@version P12.1.16
/*/
Function FINI791CAN( cXml, nType, cTypeMessage, cVersion  )
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
		cXmlRet := STR0001 //"Opera��o de envio n�o implementada."
	Endif

	RestArea( aArea )

Return {lRet, cXmlRet, "HOTELINVOICECANCELLATIONALLOWANCE"}

/*/{Protheus.doc} RecBusXML
Fun��o para tratar o XML recebido na mensagem de Business

@param cXml, XML recebido
@param cXMLRet, Vari�vel com a mensagem de resposta. Passada por refer�ncia.
@return lRet, Indica se processou a mensagem recebida com sucesso

@author Pedro Alencar
@since 17/01/2017
@version P12.1.16
/*/
Static Function RecBusXML( cXml, cXMLRet )
	Local lRet := .T.
	Local lCancel := .T.
	Local oXML := Nil
	Local cMarca := ""
	Local cExtFat := ""
	Local aRetFat := {}
	Local cPathBC := "/TOTVSMessage/BusinessMessage/BusinessContent/"
	Local aChaveFat := {}
	Local cErroRet := ""

	oXML := tXMLManager():New()
	lRet := oXML:Parse( cXml )

	If lRet
		cMarca := oXml:XPathGetAtt( "/TOTVSMessage/MessageInformation/Product", "name" )

		cExtFat := oXml:XPathGetNodeValue( cPathBC + "HotelInvoiceInternalId" )
		If ! Empty( cExtFat )
			aRetFat := F791GetInt( cExtFat, cMarca )
			If aRetFat[1] //Se o registro foi encontrado na tabela de de/para
				aChaveFat := aRetFat[2]
			Else
				lRet := .F.
				cXmlRet := STR0002 + cExtFat //"A fatura informada n�o foi encontrada no de/para Protheus: "
			EndIf
		Else
			aAdd( aRetFat, .F. )
			lRet := .F.
			cXmlRet := STR0003 //"� obrigat�rio informar um valor na tag 'HotelInvoiceInternalId'"
		EndIf  

	Else
		cXmlRet := STR0004 //"Houve um erro no tratamento do XML. Verifique se o mesmo est� sendo informado corretamente."
	EndIf
	
	If lRet 
		//Verifica se pode excluir os t�tulos gerados na fatura
		lCancel := F791CTit( aChaveFat, @cErroRet )
		
		If lCancel 
			cXMLRet := "<IsCancellable>true</IsCancellable>"
			cXMLRet += "<Message></Message>"
		Else
			cXMLRet := "<IsCancellable>false</IsCancellable>"
			cXMLRet += "<Message>" + AllTrim( cErroRet ) + "</Message>"
		Endif		
	Endif
	
	aSize ( aRetFat, 0 )
	aRetFat := Nil
	aSize ( aChaveFat, 0 )
	aChaveFat := Nil
		
	oXML := Nil
	DelClassIntF()

Return lRet

/*/{Protheus.doc} F791CTit
Fun��o que verifica se pode excluir os t�tulos gerados na fatura

@param aChaveFat, Vetor com a chave da fatura cujos t�tulos ser�o verificados
@param cErroRet, Vari�vel com a mensagem de resposta. Passada por refer�ncia.
@return lRet, Indica se pode excluir os t�tulos

@author Pedro Alencar
@since 17/01/2017
@version P12.1.16
/*/
Static Function F791CTit( aChaveFat, cErroRet )
	Local lRet := .T. 
	Local cChaveFat := ""
	Local cChaveTitR := ""
	Local cChaveTitP := ""
	
	FO8->( dbSetOrder( 1 ) ) //FO8_FILIAL + FO8_NUM + FO8_CLI + FO8_LOJA
	FOA->( dbSetOrder( 1 ) ) //FOA_FILIAL + FOA_NUMFAT + FOA_CLIFAT + FOA_LOJFAT + FOA_PREFIX + FOA_NUM + FOA_PARCEL + FOA_TIPO
	FOB->( dbSetOrder( 1 ) ) //FOB_FILIAL+FOB_NUMFAT+FOB_CLIFAT+FOB_LOJFAT+FOB_PREFIX+FOB_NUM+FOB_PARCEL+FOB_TIPO
	
	cChaveFat := aChaveFat[2] + aChaveFat[3] + aChaveFat[4] + aChaveFat[5]
	If FO8->( MsSeek( cChaveFat ) )

		//Titulos a receber
		FOA->( MsSeek( cChaveFat ) )
		While FOA->( ! EOF() ) .AND. FOA->( FOA_FILIAL + FOA_NUMFAT + FOA_CLIFAT + FOA_LOJFAT ) == cChaveFat
			cChaveTitR := SE1->( FWxFilial("SE1") ) + FOA->( FOA_CLIFAT + FOA_LOJFAT + FOA_PREFIX + FOA_NUM + FOA_PARCEL + FOA_TIPO )
			
			//Verifica se o t�tulo a receber pode ser excluido
			lRet := VerifCanCR( cChaveTitR, 2, @cErroRet, .F. )
			
			If !lRet
				Exit
			Endif 
			
			cChaveTitR := ""
			FOA->( dbSkip() )			
		EndDo
		
		If lRet 
			//Titulos a pagar (Comiss�o descontada na fatura)
			FOB->( MsSeek( cChaveFat ) )
			While FOB->( ! EOF() ) .AND. FOB->( FOB_FILIAL + FOB_NUMFAT + FOB_CLIFAT + FOB_LOJFAT ) == cChaveFat
				cChaveTitP := SE2-> ( FWxFilial("SE2") ) + FOB->( FOB_FORCOM + FOB_LOJCOM + FOB_PREFIX + FOB_NUM + FOB_PARCEL + FOB_TIPO )  
				
				//Verifica se o t�tulo a pagar (comiss�o) pode ser excluido (se os impostos j� n�o est�o pagos)
				lRet := VerifCanCP( cChaveTitP, @cErroRet )
				
				If !lRet
					Exit
				Endif
				
				cChaveTitP := ""
				FOB->( dbSkip() )
			EndDo
		Endif
		
	Endif
	
Return lRet

/*/{Protheus.doc} VerifCanCP
Fun��o que verifica se pode excluir um t�tulo financeiro a pagar (comiss�o descontada na fatura)

@param cChaveTit, Chave do t�tulo a pagar a ser verificado
@param cErroRet, Vari�vel com a mensagem de resposta. Passada por refer�ncia.
@return lRet, Indica se pode excluir o t�tulo

@author Pedro Alencar
@since 17/01/2017
@version P12.1.16
/*/
Static Function VerifCanCP( cChaveTitP, cErroRet )
	Local lRet := .T.
	Local aAreaSE2 := SE2->( GetArea() )
	Local aTitImp := {}
	Local nX := 0
	
	Default cChaveTit := ""
	Default cErroRet := ""
	
	SE2->( dbSetOrder( 6 ) ) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	If SE2->( MsSeek( cChaveTit ) )
		
		//Verifica se h� t�tulos de impostos para o t�tulo principal e verifica se os mesmos j� est�o baixados ou em border�
		aTitImp := ImpCtaPg()
		For nX := 1 To Len( aTitImp )
			If !Empty( aTitImp[nX][8] ) .AND. (aTitImp[nX][7] == aTitImp[nX][6] )
				cErroRet := STR0005 + cChaveTit //"Este t�tulo de comiss�o poss�i t�tulos de impostos gerados e os mesmos se encontram em border�: "
				lRet := .F.
				Exit
			EndIf
			
			If lRet .AND. aTitImp[nX][7] <> aTitImp[nX][6]
				cErroRet := STR0006 + cChaveTit //"Este t�tulo de comiss�o poss�i t�tulos de impostos gerados e os mesmos j� foram baixados: "
				lRet := .F.
				Exit				
			EndIf
			
		Next nX
		aSize( aTitImp, 0 )
		aTitImp := {}
		
	EndIf
	
	RestArea( aAreaSE2 )
	aSize( aAreaSE2, 0 )
	aAreaSE2 := {}
Return lRet