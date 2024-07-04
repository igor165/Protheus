#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA761.CH'

#Define DH_TRANS_INCLUSAO			1
#Define DH_TRANS_CANCELAMENTO		2
#Define DH_TRANS_REALIZACAO			3
#Define DH_TRANS_ESTORNO			4
#Define DH_TRANS_CONS_REALIZACAO	5
#Define DH_TRANS_CONS_ESTORNO		6
#Define DH_TRANS_REAL_LOTE			7

/*/{Protheus.doc} WsSendDH
Fun��o para envio das opera��es do DH ao WS do SIAFI

@param nTransac, N�mero da transa��o que ser� realizada 
        1 = Inclus�o;
        2 = Cancelamento;
        3 = Realiza��o;
        4 = Estorno;
        5 = Consulta de Compromissos para Realiza��o;
        6 = Consulta de Compromissos para Estorno;
        7 = Realiza��o em Lote;
        
@author Pedro Alencar	
@since 10/02/2015	
@version P12.1.5
/*/
Function WsSendDH( nTransac, lLote, cArqTrb, cMarca )
	Local lRet		:= .T.	
	Local aLogin		:= {}
	Local cUser		:= ""
	Local cPass		:= ""
	Local cCA		:= SuperGetMV( "MV_SIAFICA" )
	Local cCERT		:= SuperGetMV( "MV_SIAFICE" )
	Local cKEY		:= SuperGetMV( "MV_SIAFIKE" )
	Local cWsdlURL	:= SuperGetMV( "MV_URLMCPR" )
	
	DEFAULT lLote		:= .F.
	DEFAULT cArqTrb	:= ""
	
	//Verifica se os par�metros necess�rios est�o preenchidos
	If Empty( cWsdlURL ) 
		lRet := .F.
		Help( "", 1, "WsSendDH1", , STR0162, 1, 0 ) //"URL do WSDL n�o informada no par�metro MV_URLMCPR." //#DEL STR		
	ElseIf	Empty( cCA ) .OR. Empty( cCERT ) .OR. Empty( cKEY )
		lRet := .F.
		Help( "", 1, "WsSendDH2", , STR0163, 1, 0 ) //"Arquivos de certificado digital n�o informados nos par�metros MV_SIAFICA, MV_SIAFICE e/ou MV_SIAFIKE" //#DEL STR
	Endif
	
	If lRet
		//Abre a tela de login do WS
		aLogin := LoginCPR()
		
		//Verifica se o login foi informado corretamente
		If Len( aLogin ) > 0
			cUser := AllTrim( aLogin[1] )
			cPass := Alltrim( aLogin[2] )
			
			If nTransac == DH_TRANS_INCLUSAO //Inclus�o do DH
				//Chama a rotina para envio do DH ao WS
				MsgRun( STR0164, STR0165, {|| EnviaDH( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass ) } ) //"Processando envio ao WebService do SIAFI..." //"Inclus�o"
			ElseIf nTransac == DH_TRANS_CANCELAMENTO //Cancelamento do DH
				//Chama a rotina para envio do Cancelamento do DH ao WS
				MsgRun( STR0166, STR0167, {|| CancelaDH( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass ) } ) //"Processando envio do cancelamento ao WebService do SIAFI..."//"Cancelamento"
			ElseIf nTransac == DH_TRANS_REALIZACAO .OR. nTransac == DH_TRANS_REAL_LOTE //Realiza��o do DH Individual ou em Lote
				//Chama a rotina para envio da realiza��o do DH ao WS
				MsgRun( STR0168, STR0169, {|| RealizaDH( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass, lLote, cArqTrb, cMarca  ) } ) //"Processando envio da realiza��o do DH ao WebService do SIAFI..."//"Realiza��o"
			ElseIf nTransac == DH_TRANS_ESTORNO //Estorno do DH
				//Chama a rotina para envio do Estorno do DH ao WS
				MsgRun( STR0170 , STR0171, {|| EstornaDH( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass ) } ) //"Processando envio do estorno do DH ao WebService do SIAFI..."//"Estorno"
			Endif
		Else
			lRet := .F.
			Help( "", 1, "WsSendDH3", , STR0172, 1, 0 ) //"� necess�rio informar um usu�rio e senha para autentica��o no SIAFI."
		Endif
	Endif
		
Return Nil

/*/{Protheus.doc} EnviaDH
Fun��o para envio da inclus�o do DH ao WS

@param cCA, Caminho do Certificado de Autoriza��o do SIAFI
@param cCERT, Caminho do Certificado de Cliente do SIAFI
@param cKEY,  Caminho da Chave Privada do Certificado do SIAFI
@param cWsdlURL, URL do WSDL do servi�o ManterContasPagarReceber do SIAFI
@param cUser, Usu�rio para autentica��o no SIAFI
@param cPass, Senha para autentica��o no SIAFI
 
@author Pedro Alencar	
@since 10/02/2015	
@version P12.1.4
/*/
Static Function EnviaDH( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass )
	Local lRet := .F.
	Local oWsdl := TWsdlManager():New()
	//#DEL Local oXmlRet := TXmlManager():New()
	Local cXmlRet := ""
	Local cIdCV8 := ""
	
	//Define as propriedades para tratar os prefixos NS das tags do XML e para remover as tags vazias, pois o WS do SIAFI n�o aceita as mesmas
	oWsdl:lUseNSPrefix := .T.
	oWsdl:lRemEmptyTags := .T.
	oWsdl:bNoCheckPeerCert := .T.							  
	
	//Informa os arquivos da quebra do certificado digital
	oWsdl:cSSLCACertFile := cCA
	oWsdl:cSSLCertFile := cCERT
	oWsdl:cSSLKeyFile := cKEY

	//"Parseia" o WSDL do SIAFI, para manipular o mesmo atrav�s do objeto da classe TWsdlManager  
	lRet := oWsdl:ParseURL( cWsdlURL )	
	If lRet
		//#DEL aOps := oWsdl:ListOperations()

		//Define a opera��o com a qual ser� trabalhada no Documento H�bil em quest�o
		lRet := oWsdl:SetOperation( "cprDHCadastrarDocumentoHabil" )
		If lRet
			//Monta o XML de comunica��o com o WS do SIAFI
			MontaWsDH( @oWsdl, cUser, cPass )

			//Se houver mensagem definida, envia a mensagem. Do contr�rio, mostra o erro do objeto.
			oWsdl:lVerbose := .T. //#DEL
			//:TODO:
			AutoGrLog(oWsdl:GetSoapMsg())
			cFileLog := NomeAutoLog()
			cPath := ''
			If cFileLog <> ""
			   // A fun��o MostraErro() apaga o arquivo que leu, por isso salve-o.
				MostraErro(cPath,cFileLog)
			Endif
					//:TODO			
			If !Empty( oWsdl:GetSoapMsg() )
				//Envia a mensagem SOAP ao servidor
				oWsdl:lProcResp := .F. //N�o processa o retorno automaticamente no objeto (ser� tratado atrav�s do m�todo GetSoapResponse)
				lRet := oWsdl:SendSoapMsg()
				If lRet
					//"Parseia" o XML de retorno do WS para ser tratado atrav�s da classe 
					//#DEL lRet := oXmlRet:Parse( oWsdl:GetSoapResponse() )
					//#DEL If lRet
					cXmlRet := oWsdl:GetSoapResponse()
					If ! Empty( cXmlRet )
						//#DEL TrataRet( oXmlRet )
						TrataRet( cXmlRet, cUser, DH_TRANS_INCLUSAO )
					Else
						ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
						ProcLogAtu( "MENSAGEM", STR0174 , STR0175 + CRLF + STR0176 + cUser, , .T. ) //'Envio do Documento H�bil: ' //"N�o foi poss�vel tratar a resposta do WebService. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI." // "Usu�rio SIAFI: "
		
						Help( "", 1, "WSDLXML1", , STR0175, 1, 0 ) //"N�o foi poss�vel tratar a resposta do WebService. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI."		
					Endif
				Else
					Help( "", 1, "WSDLXML2", , STR0177 + CRLF + oWsdl:cError, 1, 0 ) //"Ocorreu um problema ao enviar a requisi��o para o SIAFI: "
				Endif
			Else
				Help( "", 1, "WSDLXML3", , STR0178 + CRLF + oWsdl:cError, 1, 0 ) //"H� um problema com os dados do Documento H�bil: "
			Endif
			
		Else //Se n�o conseguiu definir a opera��o
			Help( "", 1, "WSDLXML4", , STR0179 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao definir a opera��o para envio ao SIAFI: "
		Endif
	Else //Se n�o conseguiu acessar o endere�o do WSDL corretamente 
		Help( "", 1, "WSDLXML5", , STR0180 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao acessar o WSDL do servi�o do SIAFI: "
	Endif 	

	oWsdl := Nil 
	//#DEL oXmlRet := Nil
Return Nil

/*/{Protheus.doc} MontaWsDH
Fun��o para montagem da estrutura do DH para envio ao WS

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param cUser, Usu�rio para autentica��o no SIAFI
@param cPass, Senha para autentica��o no SIAFI
 
@author Pedro Alencar	
@since 12/01/2015	
@version P12.1.4
/*/
Static Function MontaWsDH( oWsdl, cUser, cPass )	
	Local oModelDH
	Local oCabecDH
	Local oDocOrig
	Local oPCO
	Local oPCOIt
	Local oPSO
	Local oPSOIt
	Local oOUT
	Local oDED
	Local oDEDRc
	Local oDEDAc
	Local oENC
	Local oENCRc
	Local oENCAc
	Local oPreDoc
	Local oDSP
	Local oDSPIt
	Local oPGTRc
	Local oPGTAcPCO
	Local oPGTAcPSO
	Local aSimple := {}
	Local nQtdDocOri := 0
	Local nQtdPCO := 0
	Local aQtdItPCO := {}		
	Local nQtdPSO := 0
	Local aQtdItPSO := {}	
	Local nQtdOUT := 0
	Local nQtdDED := 0
	Local aQtdRcDED := {}
	Local aQtdAcDED := {}
	Local aQtdPdDED := {}
	Local nQtdENC := 0
	Local aQtdRcENC := {}
	Local aQtdAcENC := {}
	Local aQtdPdENC := {}
	Local nQtdDSP := 0
	Local aQtdItDSP := {}
	Local nQtdRcPGT := 0
	Local nQtdAcPGT := 0
	Local aQtdPdPGT := {}
	Local nX := 0
	Local cTipoPD := ""
	Local cUgPaga := ""	
	Local lPdPGT := .F.
	Local cTpDH := ""
	Local lOrgao	:= .F.
	Local aCPAArea	:= {}
	
	DbSelectArea("CPA") // �rg�os P�blicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + C�digo �rg�o
	
	//Ativa o Model principal da rotina
	oModelDH := FWLoadModel( "FINA761" )
	oModelDH:SetOperation( MODEL_OPERATION_VIEW ) //Visualiza��o
	oModelDH:Activate()
	
	//Model de Predoc
	oPreDoc := oModelDH:GetModel( "DETFV7" )
	
	//Model do Cabe�alho do DH
	oCabecDH := oModelDH:GetModel( "CABDI" )
	cUgPaga := oCabecDH:GetValue( "FV0_UGPAGA" )
	cTpDH := AllTrim( oCabecDH:GetValue( "FV0_TIPODC" ) )
	
	lOrgao := CPA->(DbSeek(FWxFilial("CPA") + oCabecDH:GetValue( "FV0_FORNEC" ) ))
	
	//Model dos Documentos de Origem
	oDocOrig := oModelDH:GetModel( "DOCORI" )
	nQtdDocOri := Iif( !oDocOrig:IsEmpty(), oDocOrig:Length(), 0 )
	
	//Model de Principal Com Or�amento
	oPCO := oModelDH:GetModel( "PCOSITUACA" )
	nQtdPCO := Iif( !oPCO:IsEmpty(), oPCO:Length(), 0 )
	
	//Define quantos itens cada registro de PCO possu�
	If nQtdPCO > 0
		//Model de Notas de Empenho (Item PCO)
		oPCOIt := oModelDH:GetModel( "PCOEMPENHO" )
		aSize( aQtdItPCO, nQtdPCO )
				
		For nX := 1 to nQtdPCO
			oPCO:GoLine( nX )
			aQtdItPCO[nX] := Iif( !oPCOIt:IsEmpty(), oPCOIt:Length(), 0 )
		Next nX
	Endif
	
	//Model de Principal Sem Or�amento
	oPSO := oModelDH:GetModel( "DETFV8" )
	nQtdPSO := Iif( !oPSO:IsEmpty(), oPSO:Length(), 0 )
	
	//Define quantos itens cada registro de PSO possu�
	If nQtdPSO > 0
		//Model de Itens PSO
		oPSOIt := oModelDH:GetModel( "DETFV9" )
		aSize( aQtdItPSO, nQtdPSO )
				
		For nX := 1 to nQtdPSO
			oPSO:GoLine( nX )
			aQtdItPSO[nX] := Iif( !oPSOIt:IsEmpty(), oPSOIt:Length(), 0 )
		Next nX
	Endif
	
	//Model de Outros Lan�amentos
	oOUT := oModelDH:GetModel( "DETFVA" )
	nQtdOUT := Iif( !oOUT:IsEmpty(), oOUT:Length(), 0 )
	
	//Model de Dedu��es
	oDED := oModelDH:GetModel( "DETFVD" )
	nQtdDED := Iif( !oDED:IsEmpty(), oDED:Length(), 0 )
	
	//Define quantos itens cada registro de DEDU��O possu�
	If nQtdDED > 0
		//Model de Recolhedores da Dedu��o
		oDEDRc := oModelDH:GetModel( "DETFVE" )
		aSize( aQtdRcDED, nQtdDED )
		
		//Model de Acrescimos da Dedu��o
		oDEDAc := oModelDH:GetModel( "DETFVF" )
		aSize( aQtdAcDED, nQtdDED )
		
		//Vetor que guarda se a linha de dudu��o possu� ou n�o Predoc		
		aSize( aQtdPdDED, nQtdDED )
				
		For nX := 1 to nQtdDED
			oDED:GoLine( nX )
			aQtdRcDED[nX] := Iif( !oDEDRc:IsEmpty(), oDEDRc:Length(), 0 )
			aQtdAcDED[nX] := Iif( !oDEDAc:IsEmpty(), oDEDAc:Length(), 0 )
			
			//Verifica se tem Predoc pra essa linha de Dedu��o
			If oPreDoc:SeekLine( { {"FV7_IDTAB", "3"}, {"FV7_ITEDOC", oDED:GetValue( "FVD_ITEM" )} } ) //IDTAB 3 = Dedu��o
				cTipoPD := TrataTpPD( oPreDoc:GetValue( "FV7_PREDOC" ) )
				If lOrgao .AND. cTipoPD == "GRU"
					aQtdPdDED[nX] := { 1, cTipoPD, oPreDoc:GetValue( "FV7_IDTAB" ), oDED:GetValue( "FVD_ITEM" ) }
				ElseIf !lOrgao .AND. cTipoPD == "GRU"
					aQtdPdPGT[nX] := { 0, "" , "", ""}
				Else
					aQtdPdDED[nX] := { 1, cTipoPD, oPreDoc:GetValue( "FV7_IDTAB" ), oDED:GetValue( "FVD_ITEM" ) }
				EndIf
			Else
				aQtdPdPGT[nX] := { 0, "" , "", ""}
			Endif
		Next nX
	Endif
	
	//Model de Encargos
	oENC := oModelDH:GetModel( "DETFVB" )
	nQtdENC := Iif( !oENC:IsEmpty(), oENC:Length(), 0 )
	
	//Define quantos itens cada registro de ENCARGOS possu�
	If nQtdENC > 0
		//Model de Recolhedores do Encargo
		oENCRc := oModelDH:GetModel( "DETFVEEN" )
		aSize( aQtdRcENC, nQtdENC )
		
		//Model de Acrescimos do Encargo
		oENCAc := oModelDH:GetModel( "DETFVFEN" )
		aSize( aQtdAcENC, nQtdENC )
		
		//Vetor que guarda se a linha de Encargo possu� ou n�o Predoc		
		aSize( aQtdPdENC, nQtdENC )
				
		For nX := 1 to nQtdENC
			oENC:GoLine( nX )
			aQtdRcENC[nX] := Iif( !oENCRc:IsEmpty(), oENCRc:Length(), 0 )
			aQtdAcENC[nX] := Iif( !oENCAc:IsEmpty(), oENCAc:Length(), 0 )
			
			//Verifica se tem Predoc pra essa linha de Encargo
			If oPreDoc:SeekLine( { {"FV7_IDTAB", "1"}, {"FV7_ITEDOC", oENC:GetValue( "FVB_ITEM" )} } ) //IDTAB 1 = Encargos
				cTipoPD := TrataTpPD( oPreDoc:GetValue( "FV7_PREDOC" ) )
				aQtdPdENC[nX] := { 1, cTipoPD, oPreDoc:GetValue( "FV7_IDTAB" ), oENC:GetValue( "FVB_ITEM" ) }
			Else
				aQtdPdPGT[nX] := { 0, "" , "", ""}
			Endif
		Next nX
	Endif
	
	//Model de Despesa a Anular
	oDSP := oModelDH:GetModel( "DETFVL" )
	nQtdDSP := Iif( !oDSP:IsEmpty(), oDSP:Length(), 0 )
	
	//Define quantos itens cada registro de Despesa a Anular possu�
	If nQtdDSP > 0
		//Model de Itens de Despesa a Anular
		oDSPIt := oModelDH:GetModel( "DETFVM" )
		aSize( aQtdItDSP, nQtdDSP )
				
		For nX := 1 to nQtdDSP
			oDSP:GoLine( nX )
			aQtdItDSP[nX] := Iif( !oDSPIt:IsEmpty(), oDSPIt:Length(), 0 )
		Next nX
	Endif
	
	//Model de Favorecidos da aba Dados de Pagamento 
	oPGTRc := oModelDH:GetModel( "DADOPAGFAV" )
	nQtdRcPGT := Iif(!oPGTRc:IsEmpty(),oPGTRc:Length(),0)
	
	//Model de Acrescimos do Dados de Pagamento (localizado na aba PCO)
	oPGTAcPCO := oModelDH:GetModel( "DETFVFPCO" )
	nQtdAcPGT += Iif( !oPGTAcPCO:IsEmpty(), oPGTAcPCO:Length(), 0 )
	
	//Model de Acrescimos do Dados de Pagamento (localizado na aba PSO)
	oPGTAcPSO := oModelDH:GetModel( "DETFVFPSO" )
	nQtdAcPGT += Iif( !oPGTAcPSO:IsEmpty(), oPGTAcPSO:Length(), 0 )
	
	//Verifica se o pr�-doc ser� por linha de situa��o ou por linha de favorecido na aba de Dados de Pagamento
	lPdPGT := VerifPdPGT( cTpDH, nQtdPSO, oPSO, nQtdPCO, oPCO )
						
	//Se � Pr�-Doc por linha de favorecido na aba de Dados de Pagamento
	If lPdPGT
		//Vetor que guarda se a linha de favorecido, dos Dados de Pagamento, possu� ou n�o Predoc		
		aSize( aQtdPdPGT, nQtdRcPGT )
			
		For nX := 1 to nQtdRcPGT
			oPGTRc:GoLine( nX )
			//Verifica se tem Predoc pra essa linha de Favorecido
			If oPreDoc:SeekLine( { {"FV7_IDTAB", "2"}, {"FV7_ITEDOC", oPGTRc:GetValue( "FV6_ITEM" )} } ) //IDTAB 2 = Dados de Pagamento
				cTipoPD := TrataTpPD( oPreDoc:GetValue( "FV7_PREDOC" ) )
				If lOrgao .AND. cTipoPD == "GRU"
					aQtdPdPGT[nX] := { 1, cTipoPD, oPreDoc:GetValue( "FV7_IDTAB" ), oPGTRc:GetValue( "FV6_ITEM" ) }
				ElseIf !lOrgao .AND. cTipoPD == "GRU"
					aQtdPdPGT[nX] := { 0, "" , "", ""}
				Else
					aQtdPdPGT[nX] := { 1, cTipoPD, oPreDoc:GetValue( "FV7_IDTAB" ), oPGTRc:GetValue( "FV6_ITEM" ) }
				EndIf
			Else
				aQtdPdPGT[nX] := { 0, "" , "", ""}
			Endif
		Next nX		
	Else //Se for pr�-doc por linha de situa��o
		//Verifica se tem pr�-docs definidos nas situa��es de PSO
		If nQtdPSO > 0				
			//Vetor que guarda se a linha de favorecido, dos Dados de Pagamento, possu� ou n�o Predoc		
			aSize( aQtdPdPGT, nQtdPSO )
			
			For nX := 1 to nQtdPSO
				oPSO:GoLine( nX )
				//Verifica se tem Predoc pra essa linha de PSO
				If oPreDoc:SeekLine( { {"FV7_IDTAB", "5"}, {"FV7_SITUAC", oPSO:GetValue( "FV8_SITUAC" )} } ) //IDTAB 5 = PSO
					cTipoPD := TrataTpPD( oPreDoc:GetValue( "FV7_PREDOC" ) )
					If lOrgao .AND. cTipoPD == "GRU"
						aQtdPdPGT[nX] := { 1, cTipoPD, oPreDoc:GetValue( "FV7_IDTAB" ), oPSO:GetValue( "FV8_SITUAC" ) }
					ElseIf !lOrgao .AND. cTipoPD == "GRU"
						aQtdPdPGT[nX] := { 0, "" , "", ""}
					Else
						aQtdPdPGT[nX] := { 1, cTipoPD, oPreDoc:GetValue( "FV7_IDTAB" ), oPSO:GetValue( "FV8_SITUAC" ) }
					EndIf
				Else
					aQtdPdPGT[nX] := { 0, "" , "", ""}
				Endif
			Next nX		
		Endif
		
		//Verifica se tem pr�-docs definidos nas situa��es de PCO
		If nQtdPCO > 0
			//Vetor que guarda se a linha de favorecido, dos Dados de Pagamento, possu� ou n�o Predoc		
			aSize( aQtdPdPGT, nQtdPCO )
			
			For nX := 1 to nQtdPCO
				oPCO:GoLine( nX )
				//Verifica se tem Predoc pra essa linha de PCO
				If oPreDoc:SeekLine( { {"FV7_IDTAB", "4"}, {"FV7_ITEDOC", oPCO:GetValue( "FV2_ITEM" )} } ) //IDTAB 4 = PCO
					cTipoPD := TrataTpPD( oPreDoc:GetValue( "FV7_PREDOC" ) )
					If lOrgao .AND. cTipoPD == "GRU"
						aQtdPdPGT[nX] := { 1, cTipoPD, oPreDoc:GetValue( "FV7_IDTAB" ), oPCO:GetValue( "FV2_ITEM" ) }
					ElseIf !lOrgao .AND. cTipoPD == "GRU"
						aQtdPdPGT[nX] := { 0, "" , "", ""}
					Else
						aQtdPdPGT[nX] := { 1, cTipoPD, oPreDoc:GetValue( "FV7_IDTAB" ), oPCO:GetValue( "FV2_ITEM" ) }
					EndIf
				Else
					aQtdPdPGT[nX] := { 0, "" , "", ""}
				Endif
			Next nX
		Endif
		
		//Verifica se tem pr�-docs definidos nas situa��es de Dedu��es
		If nQtdDED > 0
			//Vetor que guarda se a linha de favorecido, dos Dados de Pagamento, possu� ou n�o Predoc		
			aSize( aQtdPdPGT, nQtdDED )
			
			For nX := 1 to nQtdDED
				oDED:GoLine( nX )
				//Verifica se tem Predoc pra essa linha de Dedu��o
				If oPreDoc:SeekLine( { {"FV7_IDTAB", "3"}, {"FV7_ITEDOC", oDED:GetValue( "FVD_ITEM" )} } ) //IDTAB 3 = Dedu��es
					cTipoPD := TrataTpPD( oPreDoc:GetValue( "FV7_PREDOC" ) )
					If lOrgao .AND. cTipoPD == "GRU"
						aQtdPdPGT[nX] := { 1, cTipoPD, oPreDoc:GetValue( "FV7_IDTAB" ), oDED:GetValue( "FVD_ITEM")}
					ElseIf !lOrgao .AND. cTipoPD == "GRU"
						aQtdPdPGT[nX] := { 0, "" , "", ""}
					Else
						aQtdPdPGT[nX] := { 1, cTipoPD, oPreDoc:GetValue( "FV7_IDTAB" ), oDED:GetValue( "FVD_ITEM")}
					EndIf
				Else
					aQtdPdPGT[nX] := { 0, "" , "", ""}
				Endif
			Next nX
		EndIf
		
		//Verifica se tem pr�-docs definidos nas situa��es de Dedu��es
		If nQtdENC > 0
			//Vetor que guarda se a linha de favorecido, dos Dados de Pagamento, possu� ou n�o Predoc		
			aSize( aQtdPdPGT, nQtdENC )
			
			For nX := 1 to nQtdENC
				oENC:GoLine( nX )
				//Verifica se tem Predoc pra essa linha de Encargos
				If oPreDoc:SeekLine( { {"FV7_IDTAB", "1"}, {"FV7_ITEDOC", oENC:GetValue( "FVB_ITEM" )} } ) //IDTAB 1 = Encargos
					cTipoPD := TrataTpPD( oPreDoc:GetValue( "FV7_PREDOC" ) )
					If lOrgao .AND. cTipoPD == "GRU"
						aQtdPdPGT[nX] := { 1, cTipoPD, oPreDoc:GetValue( "FV7_IDTAB" ), oENC:GetValue( "FVB_ITEM" ) }
					ElseIf !lOrgao .AND. cTipoPD == "GRU"
						aQtdPdPGT[nX] := { 0, "" , "", ""}
					Else
						aQtdPdPGT[nX] := { 1, cTipoPD, oPreDoc:GetValue( "FV7_IDTAB" ), oENC:GetValue( "FVB_ITEM" ) }
					EndIf
				Else
					aQtdPdPGT[nX] := { 0, "" , "", ""}
				Endif
			Next nX
		EndIf
		
		aEval( aQtdPdPGT, { |x| Iif(x[1] > 0, nQtdRcPGT := nQtdRcPGT + 1, 0)} )
	Endif
	
	If Len(aQtdPdPGT) == 0
		aSize(aQtdPdPGT, 1)
		aQtdPdPGT[1] := { 0, "" , "", ""}
	EndIf
	
	//Define as ocorr�ncias dos tipos complexos
	DefComplex( @oWsdl, DH_TRANS_INCLUSAO, nQtdDocOri, nQtdPCO, aQtdItPCO, nQtdPSO, aQtdItPSO, nQtdOUT, nQtdDED, aQtdRcDED, aQtdAcDED, aQtdPdDED, nQtdENC, aQtdRcENC, aQtdAcENC, aQtdPdENC, nQtdDSP, aQtdItDSP,/*nQtdCOM*/,/*aQtdItCOM*/,/*aQtdItVinc*/,nQtdRcPGT, aQtdPdPGT )
	
	//Pega os elementos simples, ap�s defini��o das ocorr�ncias dos tipos complexos
	aSimple := oWsdl:SimpleInput()
	
	//Monta o cabe�alho da mensagem
	DefCabec( @oWsdl, aSimple, cUser, cPass, oCabecDH:GetValue( "FV0_UGEMIT" ) )
	
	//Monta os dados da aba Dados B�sicos
	DefBasicos( @oWsdl, aSimple, nQtdDocOri, oCabecDH, oDocOrig )
	
	//Monta os dados da aba Principal com Or�amento
	DefPCO( @oWsdl, aSimple, nQtdPCO, aQtdItPCO, oPCO, oPCOIt )
	
	//Monta os dados da aba Principal sem Or�amento
	DefPSO( @oWsdl, aSimple, nQtdPSO, aQtdItPSO, oPSO, oPSOIt )
	
	//Monta os dados da aba Outros Lan�amentos
	DefOUT( @oWsdl, aSimple, nQtdOUT, oOUT )
	
	//Monta os dados da aba Dedu��es
	DefDED( @oWsdl, aSimple, nQtdDED, aQtdRcDED, aQtdAcDED, aQtdPdDED, oDED, oDEDRc, oDEDAc, oPreDoc, cUgPaga )
	
	//Monta os dados da aba Encargos
	DefENC( @oWsdl, aSimple, nQtdENC, aQtdRcENC, aQtdAcENC, aQtdPdENC, oENC, oENCRc, oENCAc, oPreDoc, cUgPaga )
	
	//Monta os dados da aba Despesa a Anular
	DefDSP( @oWsdl, aSimple, nQtdDSP, aQtdItDSP, oDSP, oDSPIt )
	
	//Monta os dados da aba Dados de Pagamento
	DefDadPgto( @oWsdl, aSimple, nQtdRcPGT, aQtdPdPGT, oPGTRc, oPreDoc )
	
	//Limpa os objetos MVC da mem�ria
	oModelDH:Deactivate()
	oModelDH:Destroy()
	oModelDH := Nil
	oCabecDH := Nil
	oDocOrig := Nil
	oPCO := Nil
	oPCOIt := Nil
	oPSO := Nil
	oPSOIt := Nil
	oOUT := Nil
	oDED := Nil
	oDEDRc := Nil
	oDEDAc := Nil
	oENC := Nil
	oENCRc := Nil
	oENCAc := Nil
	oPreDoc := Nil
	oDSP := Nil
	oDSPIt := Nil
	oPGTRc := Nil
	oPGTAcPCO := Nil
	oPGTAcPSO := Nil
	
	RestArea(aCPAArea)
Return Nil

/*/{Protheus.doc} DefComplex
Fun��o que define as ocorr�ncias dos tipos complexos
que ser�o utilizados no Documento H�bil

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param nTransac, N�mero da transa��o que ser� realizada 
        1 = Inclus�o; 2 = Cancelamento; 3 = Realiza��o; 4 = Estorno;
        5 = Consulta de Compromissos para Realiza��o;
@param nQtdDocOri, Quantidade de Documentos de Origem
@param nQtdPCO, Quantidade de ocorr�ncias na aba PCO
@param aQtdItPCO, Quantidade de itens por ocorr�ncia PCO
@param nQtdPSO, Quantidade de ocorr�ncias na aba PSO
@param aQtdItPSO, Quantidade de itens por ocorr�ncia PSO
@param nQtdOUT, Quantidade de ocorr�ncias na aba Outros Lan�amentos
@param nQtdDED, Quantidade de ocorr�ncias na aba Dedu��es
@param aQtdRcDED, Quantidade de itens de Recolhedores por ocorr�ncia de Dedu��o
@param aQtdAcDED, Quantidade de itens de Acr�scimo por ocorr�ncia de Dedu��o
@param aQtdPdDED, Quantidade de itens de predoc por ocorr�ncia de Dedu��o
@param nQtdENC, Quantidade de ocorr�ncias na aba Encargos
@param aQtdRcENC, Quantidade de itens de Recolhedores por ocorr�ncia de Encargo
@param aQtdAcENC, Quantidade de itens de Acr�scimo por ocorr�ncia de Encargo
@param aQtdPdENC, Quantidade de itens de predoc por ocorr�ncia de Encargo
@param nQtdDSP, Quantidade de ocorr�ncias na aba Despesa a Anular
@param aQtdItDSP, Quantidade de itens por ocorr�ncia de Despesa a Anular
@param nQtdCOM, Quantidade de ocorr�ncias de Compromissos para Realiza��o
@param nQtdCOM, Quantidade de ocorr�ncias de Compromissos para Realiza��o
@param aQtdItCOM, Quantidade de itens por ocorr�ncia de Compromissos para Realiza��o ou Estorno
@param aQtdItVinc, Quantidade de itens por ocorr�ncia de Compromissos para Realiza��o ou Estorno
@param nQtdRcPGT, Quantidade de Favorecidos da Aba de Dados de Pagamento para um Documento H�bil
@param aQtdPdPGT, Quantidade de Pr�-docs por Favorecido da Aba Dados de Pagamento para um Documento H�bil

@author Pedro Alencar	
@since 12/01/2015	
@version P12.1.4
/*/
Static Function DefComplex( oWsdl, nTransac, nQtdDocOri, nQtdPCO, aQtdItPCO, nQtdPSO, aQtdItPSO, nQtdOUT, nQtdDED, aQtdRcDED, aQtdAcDED, aQtdPdDED, nQtdENC, aQtdRcENC, aQtdAcENC, aQtdPdENC, nQtdDSP, aQtdItDSP, nQtdCOM, aQtdItCOM, aQtdItVinc, nQtdRcPGT, aQtdPdPGT )
	Local aComplex	:= {}
	Local nOccurs		:= 0
	Local cParent		:= "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1"
	Default nQtdDocOri:= 0
	Default nQtdPCO	:= 0
	Default aQtdItPCO	:= {}
	Default nQtdPSO	:= 0
	Default aQtdItPSO	:= {}
	Default nQtdOUT	:= 0
	Default nQtdDED	:= 0
	Default aQtdRcDED	:= {}
	Default aQtdAcDED	:= {}
	Default aQtdPdDED	:= {}
	Default nQtdENC	:= 0
	Default aQtdRcENC	:= {}
	Default aQtdAcENC	:= {}
	Default aQtdPdENC	:= {}
	Default nQtdDSP	:= 0
	Default aQtdItDSP	:= {}
	Default nQtdCOM	:= 0
	Default aQtdItCOM	:= {}
	Default aQtdItVinc:= {}
	DEFAULT nQtdRcPGT	:= 0
	DEFAULT aQtdPdPGT	:= {}
	
	aComplex := oWsdl:NextComplex()
	While ValType( aComplex ) == "A" 
		If aComplex[2] == "bilhetador" .AND. aComplex[5] == "cabecalhoSIAFI#1"
			nOccurs := 1
		Elseif aComplex[2] == "docOrigem" .AND. aComplex[5] == cParent + ".dadosBasicos#1"
			nOccurs := nQtdDocOri
		Elseif aComplex[2] == "pco" .AND. aComplex[5] == cParent
			nOccurs := nQtdPCO
		Elseif aComplex[2] == "pcoItem"
			nOccurs := DefQtdIt( aComplex[5], aQtdItPCO )     
		Elseif aComplex[2] == "pso" .AND. aComplex[5] == cParent
			nOccurs := nQtdPSO
		Elseif aComplex[2] == "psoItem"
			nOccurs := DefQtdIt( aComplex[5], aQtdItPSO )
		Elseif aComplex[2] == "outrosLanc" .AND. aComplex[5] == cParent
			nOccurs := nQtdOUT
		Elseif aComplex[2] == "deducao" .AND. aComplex[5] == cParent
			nOccurs := nQtdDED
		Elseif aComplex[2] == "dadosPgto" .AND. aComplex[5] == cParent
			nOccurs := nQtdRcPGT
		Elseif aComplex[2] == "itemRecolhimento"
			//Verifico se o item de recolhimento � da aba Dedu��o ou Encargos
			If At( ".deducao#", aComplex[5] ) > 0 
				nOccurs := DefQtdIt( aComplex[5], aQtdRcDED )
			ElseIf At( ".encargo#", aComplex[5] ) > 0 
				nOccurs := DefQtdIt( aComplex[5], aQtdRcENC )
			Elseif At( ".dadosPgto#", aComplex[5] ) > 0
				nOccurs := 0
			Endif
		Elseif aComplex[2] == "acrescimo"
			//Verifico se o item de acrescimo � da aba Dedu��o ou Encargos
			If At( ".deducao#", aComplex[5] ) > 0
				nOccurs := DefQtdIt( aComplex[5], aQtdAcDED )
			ElseIf At( ".encargo#", aComplex[5] ) > 0
				nOccurs := DefQtdIt( aComplex[5], aQtdAcENC )
			Endif
		Elseif aComplex[2] == "predoc"
			//Verifico se o predoc � da aba Dedu��o, Encargos ou Dados do Pagamento
			If At( ".deducao#", aComplex[5] ) > 0
				nOccurs := DefQtdIt( aComplex[5], aQtdPdDED )
			ElseIf At( ".encargo#", aComplex[5] ) > 0
				nOccurs := DefQtdIt( aComplex[5], aQtdPdENC )
			Elseif At( ".dadosPgto#", aComplex[5] ) > 0
				nOccurs := DefQtdIt( aComplex[5], aQtdPdPGT )
			Endif
		Elseif aComplex[2] == "predocOB"
			//Verifico se a Ordem Banc�ria � da aba Dedu��o, Encargos ou Dados do Pagamento
			If At( ".deducao#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdDED, "OB" )
			ElseIf At( ".encargo#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdENC, "OB" )
			Elseif At( ".dadosPgto#", aComplex[5] ) > 0 .AND. At( ".predoc#", aComplex[5] )
				nOccurs := DefPdIt( aComplex[5], aQtdPdPGT, "OB" )
			Endif
		Elseif aComplex[2] == "predocDARF"
			//Verifico se a DARF � da aba Dedu��o, Encargos ou Dados do Pagamento
			If At( ".deducao#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdDED, "DARF" )
			ElseIf At( ".encargo#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdENC, "DARF" )
			Elseif At( ".dadosPgto#", aComplex[5] ) > 0 .AND. At( ".predoc#", aComplex[5] )
				nOccurs := DefPdIt( aComplex[5], aQtdPdPGT, "DARF" )
			Endif
		Elseif aComplex[2] == "predocDAR"
			//Verifico se a DAR � da aba Dedu��o, Encargos ou Dados do Pagamento
			If At( ".deducao#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdDED, "DAR" )
			ElseIf At( ".encargo#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdENC, "DAR" )
			Elseif At( ".dadosPgto#", aComplex[5] ) > 0 .AND. At( ".predoc#", aComplex[5] )
				nOccurs := DefPdIt( aComplex[5], aQtdPdPGT, "DAR" )
			Endif
		Elseif aComplex[2] == "predocGRU"
			//Verifico se a GRU � da aba Dedu��o, Encargos ou Dados do Pagamento
			If At( ".deducao#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdDED, "GRU" )
			ElseIf At( ".encargo#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdENC, "GRU" )
			Elseif At( ".dadosPgto#", aComplex[5] ) > 0 .AND. At( ".predoc#", aComplex[5] )
				nOccurs := DefPdIt( aComplex[5], aQtdPdPGT, "GRU" )
			Endif
		Elseif aComplex[2] == "predocGPS"
			//Verifico se a GPS � da aba Dedu��o, Encargos ou Dados do Pagamento
			If At( ".deducao#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdDED, "GPS" )
			ElseIf At( ".encargo#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdENC, "GPS" )
			Elseif At( ".dadosPgto#", aComplex[5] ) > 0 .AND. At( ".predoc#", aComplex[5] )
				nOccurs := DefPdIt( aComplex[5], aQtdPdPGT, "GPS" )
			Endif
		Elseif aComplex[2] == "encargo" .AND. aComplex[5] == cParent
			nOccurs := nQtdENC
		Elseif aComplex[2] == "despesaAnular" .AND. aComplex[5] == cParent
			nOccurs := nQtdDSP
		Elseif aComplex[2] == "despesaAnularItem"
			nOccurs := DefQtdIt( aComplex[5], aQtdItDSP )
		Elseif aComplex[2] == "documentoHabil" .AND. ( nTransac == DH_TRANS_CONS_REALIZACAO .OR. nTransac == DH_TRANS_CONS_ESTORNO ) 
			//Define uma ocorr�ncia de chave de DH para a consulta de compromissos para realiza��o
			nOccurs := 1
		Elseif aComplex[2] == "listaCompromissos" .AND. ( nTransac == DH_TRANS_REALIZACAO .OR. nTransac == DH_TRANS_ESTORNO )
			nOccurs := nQtdCOM
		Elseif aComplex[2] == "itensCompromisso" .AND. nTransac == DH_TRANS_REALIZACAO
			nOccurs := DefQtdIt( aComplex[5], aQtdItCOM )
		Elseif aComplex[2] == "vinculacoes" .AND. nTransac == DH_TRANS_REALIZACAO
			nOccurs := DefQtdIt( aComplex[5], aQtdItVinc )
		Else
			nOccurs := 0
		Endif
		
		//Se for zero ocorr�ncias e o m�nimo de ocorr�ncias do tipo for 1, ent�o define como 1 para n�o dar erro na defini��o dos complexos
		If nOccurs == 0 .AND. aComplex[3] == 1
			nOccurs := 1
			Help( "", 1, "DefComplex1", STR0193,  + aComplex[2], 1, 0 ) //"Elemento obrigat�rio n�o encontrado: "
		Endif
		
    	If ! oWsdl:SetComplexOccurs( aComplex[1], nOccurs )
			Help( "", 1, "DefComplex2", , "Erro ao definir elemento " + aComplex[2] + ", ID " + cValToChar( aComplex[1] ) + ", com " + cValToChar( nOccurs ) + " ocorr�ncias", 1, 0 ) //#DEL STR
		Endif

		aComplex := oWsdl:NextComplex()
	EndDo

Return Nil

/*/{Protheus.doc} DefQtdIt
Fun��o que define a quantidade de elementos complexos dentro de 
um outro elemento complexo

@param cParents, String com todos os n�s superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param aQtdItem, Vetor com a quantidade definida de itens de elementos complexos
        O tamanho do vetor indica quantos elementos complexos h� e o valor de cada
        posi��o indica quantos elementos filhos haver�o para o elemento em quest�o. 
        
@author Pedro Alencar	
@since 12/01/2015	
@version P12.1.4
/*/
Static Function DefQtdIt( cParents, aQtdItem )
	Local nRet := 0
	Local nX := 0
	Local cAux := ""
	Local aAux := {}
	Local nOccur := 0
	
	aAux := StrToKarr( cParents, "#" )
	If Len( aAux ) > 1 
		cAux := AllTrim( aAux[Len(aAux)-1] )
		
		//#DEL If Right( cAux, 3 ) == "pco" .OR. Right( cAux, 3 ) == "pso" .OR. Right( cAux, 7 ) == "deducao" .OR. Right( cAux, 13 ) == "despesaAnular" .OR. Right( cAux, 7 ) == "encargo"
		nOccur := Val( aAux[Len(aAux)] )

		For nX := 1 To Len( aQtdItem )
			If nOccur == nX 
				If ValType( aQtdItem[nX] ) == "A"
					nRet := aQtdItem[nX][1]
				Else		
					nRet := aQtdItem[nX]
				Endif
				Exit
			Endif
		Next nX
		//#DEL Endif
		
	Endif
Return nRet

/*/{Protheus.doc} DefCabec
Fun��o que define o cabe�alho do XML a ser enviado
para o SIAFI

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param cUser, Nome do usu�rio que ser� autenticado no WS do SIAFI
@param cPass, Senha do usu�rio que ser� autenticado no WS do SIAFI
@param cUG, C�digo da UG que realizar� o processo

@author Pedro Alencar	
@since 12/01/2015	
@version P12.1.4
/*/
Function DefCabec( oWsdl, aSimple, cUser, cPass, cUG )
	Local nPos := 0
	
	//Cabe�alhoSIAFI
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "ug" .AND. aVet[5] == "cabecalhoSIAFI#1" } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], cUG )
	Endif
	
	//Bilhetador do cabe�alho SIAFI
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "nonce" .AND. aVet[5] == "cabecalhoSIAFI#1.bilhetador#1" } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], Dtos( dDataBase ) + Left( StrTran( Time(), ":", "" ), 6 ) ) 	//#DEL Revisar o NONCE
	Endif
	
	//Security
	oWsdl:SetWssHeader( SecureTag( cUser, cPass ) )
Return Nil

/*/{Protheus.doc} SecureTag
Fun��o que define o WS-Security do cabe�alho do XML a ser enviado
para o SIAFI

@param cUser, Usu�rio de autentica��o no SIAFI
@param cPsw, Senha de autentica��o no SIAFI

@author Pedro Alencar	
@since 12/01/2015	
@version P12.1.4
/*/
Function SecureTag( cUser, cPsw )
	Local cRet := ""
	
	cRet := '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
	cRet += '<wsse:UsernameToken xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" wsu:Id="UsernameToken-1">'
	cRet += 		"<wsse:Username>" + AllTrim( cUser ) + "</wsse:Username>"
	cRet += 		'<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'
	cRet += 		 AllTrim( cPsw )
	cRet += 		'</wsse:Password>'
	cRet += 	'</wsse:UsernameToken>'
	cRet += '</wsse:Security>'
	
Return cRet

/*/{Protheus.doc} DefBasicos
Fun��o que define no XML os dados da se��o Dados B�sicos

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdDocOri, Quantidade de Documentos de Origem
@param oCabecDH, Model de cabe�alho do cadastro do DH
@param oDocOrig, Model de Documentos de Origem do cadastro do DH

@author Pedro Alencar	
@since 12/01/2015	
@version P12.1.4
/*/
Static Function DefBasicos( oWsdl, aSimple, nQtdDocOri, oCabecDH, oDocOrig )
	Local nPos		:= 0
	Local nX			:= 0
	Local cParent		:= ""
	Local cFornec		:= ""
	Local nValorDH	:= 0
	Local cProcesso	:= ""
	Local aArea		:= GetArea()
	Local aCPAArea	:= {}
	Local aSA2Area	:= {}
	
	DbSelectArea("CPA") // �rg�os P�blicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + C�digo �rg�o
	
	DbSelectArea("SA2")
	aSA2Area := SA2->(GetArea())
	SA2->(DbSetOrder(1)) // Filial + C�digo + Loja
	
	//Cabe�alho do DH
	cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1"
	
	cFornec := AllTrim( oCabecDH:GetValue( "FV0_FORNEC" ) )
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgEmit" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oCabecDH:GetValue( "FV0_UGEMIT" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "anoDH" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], cValToChar( Year( dDataBase ) ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codTipoDH" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], AllTrim( oCabecDH:GetValue( "FV0_TIPODC" ) ) )
	Endif
	
	//Aba dados b�sicos
	cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1"
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "dtEmis" .AND. aVet[5] == cParent } ) ) > 0		
		oWsdl:SetValue( aSimple[nPos][1], TrataData( oCabecDH:GetValue( "FV0_DTEMIS" ) ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "dtVenc" .AND. aVet[5] == cParent } ) ) > 0 
		oWsdl:SetValue( aSimple[nPos][1], TrataData( oCabecDH:GetValue( "FV0_DTVENC" ) ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "dtPgtoReceb" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], TrataData( oCabecDH:GetValue( "FV0_DATPAG" ) ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "dtAteste" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], TrataData( dDataBase ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0
		nValorDH := oCabecDH:GetValue( "FV0_VLRDOC" )
		If nValorDH > 0 
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( nValorDH ) )
		Endif
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgPgto" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oCabecDH:GetValue( "FV0_UGPAGA" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codCredorDevedor" .AND. aVet[5] == cParent } ) ) > 0
		If CPA->(DbSeek(FWxFilial("CPA") + PADR(cFornec, TamSX3('CPA_CODORG')[1] )))
			oWsdl:SetValue( aSimple[nPos][1], cFornec )
		ElseIf SA2->(DbSeek(FWxFilial("SA2") + PADR(cFornec,TamSX3('A2_COD')[1]) + oCabecDH:GetValue( "FV0_LOJA" ) ) )
			oWsdl:SetValue( aSimple[nPos][1], SA2->A2_CGC )	
		EndIf
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrTaxaCambio" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], cValToChar( oCabecDH:GetValue( "FV0_TAXACA" ) ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "txtProcesso" .AND. aVet[5] == cParent } ) ) > 0
		cProcesso := AllTrim( oCabecDH:GetValue( "FV0_PROCES" ) )
		If ! Empty ( cProcesso )
			oWsdl:SetValue( aSimple[nPos][1], cProcesso )
		Endif
	Endif
	
	IF ( nPos := aScan( aSimple, {|aVet| aVet[2] == "txtObser" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], DecodeUTF8(EncodeUTF8(oCabecDH:GetValue( "FV0_OBS" ))) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "txtInfoAdic" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oCabecDH:GetValue( "FV0_ADICIO" ) )
	Endif
	
	//Dados B�sicos - Documentos de Origem 	
	For nX := 1 To nQtdDocOri	
		oDocOrig:GoLine( nX )
		cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1.docOrigem#" + cValToChar( nX )	  		
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codIdentEmit" .AND. aVet[5] == cParent } ) ) > 0
			If CPA->(DbSeek(FWxFilial("CPA") + PADR(cFornec, TamSX3('CPA_CODORG')[1] )))
				oWsdl:SetValue( aSimple[nPos][1], cFornec )
			ElseIf SA2->(DbSeek(FWxFilial("SA2") + PADR(cFornec,TamSX3('A2_COD')[1]) + oCabecDH:GetValue( "FV0_LOJA" ) ) )
				oWsdl:SetValue( aSimple[nPos][1], SA2->A2_CGC )	
			EndIf
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "dtEmis" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], TrataData( oDocOrig:GetValue( "FV1_EMISSA" ) ) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numDocOrigem" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], AllTrim(oDocOrig:GetValue( "FV1_DOCORI" )) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( oDocOrig:GetValue( "FV1_VALOR" ) ) )
		Endif
	Next nX
	
	RestArea(aArea)
	RestArea(aCPAArea)
	RestArea(aSA2Area)
Return Nil

/*/{Protheus.doc} DefPCO
Fun��o que define no XML os dados da se��o Principal com Or�amento

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdPCO, Quantidade de ocorr�ncias na aba PCO
@param aQtdItPCO, Quantidade de itens por ocorr�ncia PCO
@param oPCO, Model de Principal Com Or�amento do cadastro do DH
@param oPCOIt, Model de itens do PCO do cadastro do DH

@author Pedro Alencar	
@since 23/01/2015	
@version P12.1.4
/*/
Static Function DefPCO( oWsdl, aSimple, nQtdPCO, aQtdItPCO, oPCO, oPCOIt )
	Local nPos := 0
	Local nX := 0
	Local nI := 0
	Local cParent := ""
	Local cItemPai := ""
	Local cSituac := ""
	Local cItemFilho := ""	
	Local cCodPro := oPCO:GetValue( "FV2_CODPRO" )
	
	//Principal com Or�amento 	
	For nX := 1 To nQtdPCO
		oPCO:GoLine( nX )
		cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#" + cValToChar( nX )
		
		cItemPai := oPCO:GetValue( "FV2_ITEM" )
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cItemPai )
		Endif
		
		cSituac := oPCO:GetValue( "FV2_SITUAC" )
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codSit" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cSituac )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgEmpe" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], oPCO:GetValue( "FV2_UGEMPE" ) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "indrTemContrato" .AND. aVet[5] == cParent } ) ) > 0 
			oWsdl:SetValue( aSimple[nPos][1], Iif( oPCO:GetValue( "FV2_CONTRA" ) == "2", "0", "1" ) )
		Endif
		
		//Verifica se tem campos vari�veis pra situ��o de PCO 
		DefCpoVar( @oWsdl, aSimple, cCodPro, "FV2", cItemPai, cSituac, cParent )		
		
		//Itens do Principal Com Or�amento
		For nI := 1 To aQtdItPCO[nX]
			oPCOIt:GoLine( nI )
			cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#" + cValToChar( nX ) + ".pcoItem#" + cValToChar( nI )
			
			cItemFilho := oPCOIt:GetValue( "FV5_ITEM" )
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cItemFilho )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numEmpe" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], oPCOIt:GetValue( "FV5_NEMPE" ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codSubItemEmpe" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], oPCOIt:GetValue( "FV5_SUBEMP" ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "indrLiquidado" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], Iif( oPCOIt:GetValue( "FV5_RPLIQU" ) == "2", "0", "1" ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cValToChar( oPCOIt:GetValue( "FV5_EVALOR" ) ) )
			Endif
			
			//Verifica se tem campos vari�veis por item da situ��o de PCO 
			DefCpoVar( @oWsdl, aSimple, cCodPro, "FV5", cItemFilho, cSituac, cParent, .T., "FV2", cItemPai )
		Next nI
	Next nX
	
Return Nil

/*/{Protheus.doc} DefPSO
Fun��o que define no XML os dados da se��o Principal Sem Or�amento

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdPSO, Quantidade de ocorr�ncias na aba PSO
@param aQtdItPSO, Quantidade de itens por ocorr�ncia PSO
@param oPSO, Model de Principal Sem Or�amento do cadastro do DH
@param oPSOIt, Model de itens do PSO do cadastro do DH

@author Pedro Alencar	
@since 23/01/2015	
@version P12.1.4
/*/
Static Function DefPSO( oWsdl, aSimple, nQtdPSO, aQtdItPSO, oPSO, oPSOIt )
	Local nPos := 0
	Local nX := 0
	Local nI := 0
	Local cParent := ""
	Local cItemPai := ""
	Local cSituac := ""
	Local cItemFilho := ""	
	Local cCodPro := oPSO:GetValue( "FV8_CODPRO" )
	
	//Principal sem or�amento
	For nX := 1 To nQtdPSO
		oPSO:GoLine( nX )
		cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pso#" + cValToChar( nX )
		
		cItemPai := oPSO:GetValue( "FV8_ITEM" )
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cItemPai )
		Endif
		
		cSituac := oPSO:GetValue( "FV8_SITUAC" )
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codSit" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cSituac )
		Endif
		
		//Verifica se tem campos vari�veis pra situ��o de PSO 
		DefCpoVar( @oWsdl, aSimple, cCodPro, "FV8", cItemPai, cSituac, cParent )
		
		//Itens do Principal Sem or�amento
		For nI := 1 To aQtdItPSO[nX]
			oPSOIt:GoLine( nI )
			cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pso#" + cValToChar( nX ) + ".psoItem#" + cValToChar( nI )
			
			cItemFilho := oPSOIt:GetValue( "FV9_ITEM" )
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cItemFilho )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "indrLiquidado" .AND. aVet[5] == cParent } ) ) > 0 
				//Campo n�o visualizado no SIAFI para as situa��es utilizadas no Protheus, portanto, n�o h� nenhum campo correspondente no Protheus. Por n�o ter seu valor informado, esse campo � gravado como Verdadeiro no SIAFI.
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cValToChar( oPSOIt:GetValue( "FV9_VALOR" ) ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codFontRecur" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], oPSOIt:GetValue( "FV9_FONREC" ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codCtgoGasto" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], oPSOIt:GetValue( "FV9_CATGAS" ) )
			Endif
			
			//Verifica se tem campos vari�veis por item da situ��o de PSO 
			DefCpoVar( @oWsdl, aSimple, cCodPro, "FV9", cItemFilho, cSituac, cParent, .T., "FV8", cItemPai )
		Next nI
	Next nX
	
Return Nil

/*/{Protheus.doc} DefOUT
Fun��o que define no XML os dados da se��o Outros Lan�amentos

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdOUT, Quantidade de ocorr�ncias na aba Outros Lan�amentos
@param oOUT, Model de Outros Lan�amentos do cadastro do DH

@author Pedro Alencar	
@since 23/01/2015	
@version P12.1.4
/*/
Static Function DefOUT( oWsdl, aSimple, nQtdOUT, oOUT )
	Local nPos := 0
	Local nX := 0
	Local cParent := ""
	Local cItemPai := ""
	Local cSituac := ""
	Local cCodPro := oOUT:GetValue( "FVA_CODPRO" )
	
	//Outros Lan�amentos
	For nX := 1 To nQtdOUT
		oOUT:GoLine( nX )
		cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.outrosLanc#" + cValToChar( nX )
		
		cItemPai := oOUT:GetValue( "FVA_ITEM" )
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cItemPai )
		Endif
		
		cSituac := oOUT:GetValue( "FVA_SITUAC" )
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codSit" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cSituac )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "indrLiquidado" .AND. aVet[5] == cParent } ) ) > 0 
			//Campo n�o visualizado no SIAFI para as situa��es utilizadas no Protheus, portanto, n�o h� nenhum campo correspondente no Protheus. Por n�o ter seu valor informado, esse campo � gravado como Verdadeiro no SIAFI.
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( oOUT:GetValue( "FVA_VALOR" ) ) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "indrTemContrato" .AND. aVet[5] == cParent } ) ) > 0
			//Campo n�o visualizado no SIAFI para as situa��es utilizadas no Protheus, portanto, n�o h� nenhum campo correspondente no Protheus.
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "TpNormalEstorno" .AND. aVet[5] == cParent } ) ) > 0 
			//Campo n�o visualizado no SIAFI para as situa��es utilizadas no Protheus, portanto, n�o h� nenhum campo correspondente no Protheus.
		Endif
		
		//Verifica se tem campos vari�veis pra situ��o de Outros Lan�amentos
		DefCpoVar( @oWsdl, aSimple, cCodPro, "FVA", cItemPai, cSituac, cParent )
		
	Next nX
	
Return Nil

/*/{Protheus.doc} DefDED
Fun��o que define no XML os dados da se��o Dedu��es

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdDED, Quantidade de ocorr�ncias na aba Dedu��es
@param aQtdRcDED, Quantidade de itens de Recolhedores por ocorr�ncia de Dedu��o
@param aQtdAcDED, Quantidade de itens de Acr�scimo por ocorr�ncia de Dedu��o
@param aQtdPdDED, Quantidade de itens de predoc por ocorr�ncia de Dedu��o
@param oDED, Model de Dedu��es do cadastro do DH
@param oDEDRc, Model de Recolhedores de Dedu��es do cadastro do DH
@param oDEDAc, Model de Acr�scimos de Dedu��es do cadastro do DH
@param oPreDoc, Model de Pr�Doc do cadastro do DH
@param cUgPaga, C�digo da UG de pagamento

@author Pedro Alencar	
@since 26/01/2015	
@version P12.1.4
/*/
Static Function DefDED( oWsdl, aSimple, nQtdDED, aQtdRcDED, aQtdAcDED, aQtdPdDED, oDED, oDEDRc, oDEDAc, oPreDoc, cUgPaga )
	Local nPos := 0
	Local nX := 0
	Local nI := 0
	Local cParent := ""
	Local cItemPai := ""
	Local cSituac := ""
	Local cItemFilho := ""	
	Local cCodPro := oDED:GetValue( "FVD_CODPRO" )
	Local aArea		:= GetArea()
	Local aCPAArea	:= {}
	Local aSA2Area	:= {}
	Local cOrgao		:= ""
	Local oDH		:= oPreDoc:GetModel()
	Local oCabecDH	:= oDH:GetModel( "CABDI" )
	
	DbSelectArea("CPA") // �rg�os P�blicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + C�digo �rg�o
	
	DbSelectArea("SA2")
	aSA2Area := SA2->(GetArea())
	SA2->(DbSetOrder(1)) // Filial + C�digo + Loja
	
	//Dedu��es
	For nX := 1 To nQtdDED
		oDED:GoLine( nX )
		cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.deducao#" + cValToChar( nX )
		
		cItemPai := oDED:GetValue( "FVD_ITEM" )
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cItemPai )
		Endif
		
		cSituac := oDED:GetValue( "FVD_SITUAC" )
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codSit" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cSituac )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "dtVenc" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], TrataData( oDED:GetValue( "FVD_DTVENC" ) ) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "dtPgtoReceb" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], TrataData( oDED:GetValue( "FVD_DTPAGA" ) ) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgPgto" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cUgPaga )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( oDED:GetValue( "FVD_VALOR" ) ) )
		Endif
		
		//Verifica se tem campos vari�veis pra situ��o de Dedu��o
		DefCpoVar( @oWsdl, aSimple, cCodPro, "FVD", cItemPai, cSituac, cParent )
		
		//Itens de Recolhimento
		For nI := 1 To aQtdRcDED[nX]
			oDEDRc:GoLine( nX )
			cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.deducao#" + cValToChar( nX ) + ".itemRecolhimento#" + cValToChar( nI )
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], oDEDRc:GetValue( "FVE_ITEM" ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codRecolhedor" .AND. aVet[5] == cParent } ) ) > 0
				cOrgao := oDEDRc:GetValue( "FVE_FORNEC" )
				If CPA->(DbSeek(FWxFilial("CPA") + PADR(cOrgao,TamSX3('CPA_CODORG')[1])))
					oWsdl:SetValue( aSimple[nPos][1], cOrgao )
				ElseIf SA2->(DbSeek(FWxFilial("SA2") + PADR(cOrgao,TamSX3('A2_COD')[1]) + oCabecDH:GetValue( "FV0_LOJA" ) ) )
					oWsdl:SetValue( aSimple[nPos][1], SA2->A2_CGC )	
				EndIf 
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cValToChar( oDEDRc:GetValue( "FVE_VLRINS" ) ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrBaseCalculo" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cValToChar( oDEDRc:GetValue( "FVE_BSCALC" ) ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrMulta" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cValToChar( oDEDRc:GetValue( "FVE_VLRMUL" ) ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrJuros" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cValToChar( oDEDRc:GetValue( "FVE_VLRJUR" ) ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrOutrasEnt" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1],cValToChar(  oDEDRc:GetValue( "FVE_VLROEN" ) ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrAtmMultaJuros" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cValToChar( oDEDRc:GetValue( "FVE_VLRACR" ) ) )
			Endif			
		Next nI
		
		//Itens de Acr�scimo
		For nI := 1 To aQtdAcDED[nX]
			oDEDAc:GoLine( nX )
			cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.deducao#" + cValToChar( nX ) + ".acrescimo#" + cValToChar( nI )
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "tpAcrescimo" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], TrataTpAc( oDEDAc:GetValue( "FVF_TIPO" ) ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1],  cValToChar( oDEDAc:GetValue( "FVF_VALOR" ) ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numEmpe" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], oDEDAc:GetValue( "FVF_NEMPE" ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codSubItemEmpe" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], oDEDAc:GetValue( "FVF_SUBEMP" ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "indrLiquidado" .AND. aVet[5] == cParent } ) ) > 0 //#DEL n�o econtrado no WS
				oWsdl:SetValue( aSimple[nPos][1], Iif( oDEDAc:GetValue( "FVF_RPLIQU" ) == "2", "0", "1" ) ) 
			Endif
			
			//Verifica se tem campos vari�veis por acr�scimo da situ��o de Dedu��o
			cItemFilho := oDEDAc:GetValue( "FVF_ITEM" )			 
			DefCpoVar( @oWsdl, aSimple, cCodPro, "FVF", cItemFilho, cSituac, cParent, .T., "FVD", cItemPai )
		Next nI
		
		//Predoc
		If aQtdPdDED[nX][1] == 1
			If oPreDoc:SeekLine( { {"FV7_IDTAB", "3"}, {"FV7_ITEDOC", oDED:GetValue( "FVD_ITEM" )} } ) //IDTAB 3 = Dedu��o
				cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.deducao#" + cValToChar( nX ) + ".predoc#1"
				
				If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "txtObser" .AND. aVet[5] == cParent } ) ) > 0 
					oWsdl:SetValue( aSimple[nPos][1], DecodeUTF8(EncodeUTF8(oPreDoc:GetValue( "FV7_OBS" ))) ) 
				Endif
				
				If aQtdPdDED[nX][2] == "OB"
					cParent += ".predocOB#1"
					DefPdOB( @oWsdl, aSimple, cParent, oPreDoc )
				ElseIf aQtdPdDED[nX][2] == "DAR"
					cParent += ".predocDAR#1"
					DefPdDAR( @oWsdl, aSimple, cParent, oPreDoc )
				ElseIf aQtdPdDED[nX][2] == "DARF"
					cParent += ".predocDARF#1"
					DefPdDARF( @oWsdl, aSimple, cParent, oPreDoc )
				ElseIf aQtdPdDED[nX][2] == "GRU"
					cParent += ".predocGRU#1"
					DefPdGRU( @oWsdl, aSimple, cParent, oPreDoc )
				ElseIf aQtdPdDED[nX][2] == "GPS"
					cParent += ".predocGPS#1"
					DefPdGPS( @oWsdl, aSimple, cParent, oPreDoc )
				Endif			
			Endif
		Endif
		
	Next nX
	
	RestArea(aArea)
	RestArea(aCPAArea)
	RestArea(aSA2Area)
Return Nil

/*/{Protheus.doc} DefENC
Fun��o que define no XML os dados da se��o Encargos

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdENC, Quantidade de ocorr�ncias na aba Encargos
@param aQtdRcENC, Quantidade de itens de Recolhedores por ocorr�ncia de Encargo
@param aQtdAcENC, Quantidade de itens de Acr�scimo por ocorr�ncia de Encargo
@param aQtdPdENC, Quantidade de itens de predoc por ocorr�ncia de Encargo
@param oENC, Model de Encargos do cadastro do DH
@param oENCRc, Model de Recolhedores de Encargos do cadastro do DH
@param oENCAc, Model de Acr�scimos de Encargos do cadastro do DH
@param oPreDoc, Model de Pr�Doc do cadastro do DH
@param cUgPaga, C�digo da UG de pagamento

@author Pedro Alencar	
@since 03/02/2015	
@version P12.1.4
/*/
Static Function DefENC( oWsdl, aSimple, nQtdENC, aQtdRcENC, aQtdAcENC, aQtdPdENC, oENC, oENCRc, oENCAc, oPreDoc, cUgPaga )
	Local nPos := 0
	Local nX := 0
	Local nI := 0
	Local cParent := ""
	Local cItemPai := ""
	Local cSituac := ""
	Local cItemFilho := ""	
	Local cCodPro := oENC:GetValue( "FVB_CODPRO" )
	Local aArea		:= GetArea()
	Local aCPAArea	:= {}
	Local aSA2Area	:= {}
	Local cOrgao		:= ""
	Local oDH		:= oPreDoc:GetModel()
	Local oCabecDH	:= oDH:GetModel( "CABDI" )
	
	DbSelectArea("CPA") // �rg�os P�blicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + C�digo �rg�o
	
	DbSelectArea("SA2")
	aSA2Area := SA2->(GetArea())
	SA2->(DbSetOrder(1)) // Filial + C�digo + Loja
	
	//Encargos
	For nX := 1 To nQtdENC
		oENC:GoLine( nX )
		cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.encargo#" + cValToChar( nX )
		
		cItemPai := oENC:GetValue( "FVB_ITEM" )
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cItemPai )
		Endif
		
		cSituac := oENC:GetValue( "FVB_SITUAC" )
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codSit" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cSituac )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "indrLiquidado" .AND. aVet[5] == cParent } ) ) > 0 
			oWsdl:SetValue( aSimple[nPos][1], Iif( oENC:GetValue( "FVB_RPLIQU" ) == "2", "0", "1" ) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "dtVenc" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], TrataData( oENC:GetValue( "FVB_DTVENC" ) ) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "dtPgtoReceb" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], TrataData( oENC:GetValue( "FVB_DTPAGA" ) ) )
		Endif
						
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgPgto" .AND. aVet[5] == cParent } ) ) > 0 
			oWsdl:SetValue( aSimple[nPos][1], cUgPaga )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0 
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( oENC:GetValue( "FVB_VALOR" ) ) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgEmpe" .AND. aVet[5] == cParent } ) ) > 0 
			oWsdl:SetValue( aSimple[nPos][1], oENC:GetValue( "FVB_UGEMPE" ) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numEmpe" .AND. aVet[5] == cParent } ) ) > 0 
			oWsdl:SetValue( aSimple[nPos][1], oENC:GetValue( "FVB_NEMPE" ) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codSubItemEmpe" .AND. aVet[5] == cParent } ) ) > 0 
			oWsdl:SetValue( aSimple[nPos][1], oENC:GetValue( "FVB_SUBEMP" ) )
		Endif
		
		//Verifica se tem campos vari�veis pra situ��o de Encargo
		DefCpoVar( @oWsdl, aSimple, cCodPro, "FVB", cItemPai, cSituac, cParent )
		
		//Itens de Recolhimento
		For nI := 1 To aQtdRcENC[nX]
			oENCRc:GoLine( nX )
			cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.encargo#" + cValToChar( nX ) + ".itemRecolhimento#" + cValToChar( nI )
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], oENCRc:GetValue( "FVE_ITEM" ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codRecolhedor" .AND. aVet[5] == cParent } ) ) > 0
				cOrgao := oENCRc:GetValue( "FVE_FORNEC" )
				If CPA->(DbSeek(FWxFilial("CPA") + PADR(cOrgao,TamSX3('CPA_CODORG')[1])))
					oWsdl:SetValue( aSimple[nPos][1], cOrgao )
				ElseIf SA2->(DbSeek(FWxFilial("SA2") + PADR(cOrgao,TamSX3('A2_COD')[1]) + oCabecDH:GetValue( "FV0_LOJA" ) ) )
					oWsdl:SetValue( aSimple[nPos][1], SA2->A2_CGC )	
				EndIf 
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cValToChar( oENCRc:GetValue( "FVE_VLRINS" ) ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrBaseCalculo" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cValToChar( oENCRc:GetValue( "FVE_BSCALC" ) ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrMulta" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cValToChar( oENCRc:GetValue( "FVE_VLRMUL" ) ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrJuros" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cValToChar( oENCRc:GetValue( "FVE_VLRJUR" ) ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrOutrasEnt" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cValToChar( oENCRc:GetValue( "FVE_VLROEN" ) ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrAtmMultaJuros" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cValToChar( oENCRc:GetValue( "FVE_VLRACR" ) ) )
			Endif			
		Next nI
		
		//Itens de Acr�scimo
		For nI := 1 To aQtdAcENC[nX]
			oENCAc:GoLine( nX )
			cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.encargo#" + cValToChar( nX ) + ".acrescimo#" + cValToChar( nI )
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "tpAcrescimo" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], TrataTpAc( oENCAc:GetValue( "FVF_TIPO" ) ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1],  cValToChar( oENCAc:GetValue( "FVF_VALOR" ) ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numEmpe" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], oENCAc:GetValue( "FVF_NEMPE" ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codSubItemEmpe" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], oENCAc:GetValue( "FVF_SUBEMP" ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "indrLiquidado" .AND. aVet[5] == cParent } ) ) > 0  //#DEL n�o econtrado no WS
				oWsdl:SetValue( aSimple[nPos][1], Iif( oENCAc:GetValue( "FVF_RPLIQU" ) == "2", "0", "1" ) ) 
			Endif
			
			//Verifica se tem campos vari�veis por acr�scimo da situ��o de Encargo
			cItemFilho := oENCAc:GetValue( "FVF_ITEM" )			 
			DefCpoVar( @oWsdl, aSimple, cCodPro, "FVF", cItemFilho, cSituac, cParent, .T., "FVB", cItemPai )	
		Next nI
		
		//Predoc
		If aQtdPdENC[nX][1] == 1
			If oPreDoc:SeekLine( { {"FV7_IDTAB", "1"}, {"FV7_ITEDOC", oENC:GetValue( "FVB_ITEM" )} } ) //IDTAB 1 = Encargo
				cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.encargo#" + cValToChar( nX ) + ".predoc#1"
				
				If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "txtObser" .AND. aVet[5] == cParent } ) ) > 0 
					oWsdl:SetValue( aSimple[nPos][1], DecodeUTF8(EncodeUTF8(oPreDoc:GetValue( "FV7_OBS" ))) ) 
				Endif
				
				If aQtdPdENC[nX][2] == "OB"
					cParent += ".predocOB#1"
					DefPdOB( @oWsdl, aSimple, cParent, oPreDoc )
				ElseIf aQtdPdENC[nX][2] == "DAR"
					cParent += ".predocDAR#1"
					DefPdDAR( @oWsdl, aSimple, cParent, oPreDoc )
				ElseIf aQtdPdENC[nX][2] == "DARF"
					cParent += ".predocDARF#1"
					DefPdDARF( @oWsdl, aSimple, cParent, oPreDoc )
				ElseIf aQtdPdENC[nX][2] == "GRU"
					cParent += ".predocGRU#1"
					DefPdGRU( @oWsdl, aSimple, cParent, oPreDoc )
				ElseIf aQtdPdENC[nX][2] == "GPS"
					cParent += ".predocGPS#1"
					DefPdGPS( @oWsdl, aSimple, cParent, oPreDoc )
				Endif			
			Endif
		Endif
		
	Next nX
	
	RestArea(aArea)
	RestArea(aCPAArea)
	RestArea(aSA2Area)
	
Return Nil

/*/{Protheus.doc} DefDSP
Fun��o que define no XML os dados da se��o Despesa a Anular

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdDSP, Quantidade de ocorr�ncias na aba Despesa a Anular
@param aQtdItDSP, Quantidade de itens por ocorr�ncia de Despesa a Anular
@param oDSP, Model de Despesa a Anular do cadastro do DH
@param oDSPIt, Model de itens de Despesa a Anular do cadastro do DH

@author Pedro Alencar	
@since 04/02/2015	
@version P12.1.4
/*/
Static Function DefDSP( oWsdl, aSimple, nQtdDSP, aQtdItDSP, oDSP, oDSPIt )
	Local nPos := 0
	Local nX := 0
	Local nI := 0
	Local cParent := ""
	Local cItemPai := ""
	Local cSituac := ""
	Local cItemFilho := ""	
	Local cCodPro := oDSP:GetValue( "FVL_CODPRO" )
	
	//Despesa a Anular 	
	For nX := 1 To nQtdDSP
		oDSP:GoLine( nX )
		cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.despesaAnular#" + cValToChar( nX )
		
		cItemPai := oDSP:GetValue( "FVL_ITEM" )
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cItemPai )
		Endif
		
		cSituac := oDSP:GetValue( "FVL_SITUAC" )
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codSit" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cSituac )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgEmpe" .AND. aVet[5] == cParent } ) ) > 0 
			oWsdl:SetValue( aSimple[nPos][1], oDSP:GetValue( "FVL_UGEMPE" ) )
		Endif
		
		//Verifica se tem campos vari�veis pra situ��o de Despesa a Anular
		DefCpoVar( @oWsdl, aSimple, cCodPro, "FVL", cItemPai, cSituac, cParent )
		
		//Itens do Principal Sem or�amento
		For nI := 1 To aQtdItDSP[nX]
			oDSPIt:GoLine( nI )
			cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.despesaAnular#" + cValToChar( nX ) + ".despesaAnularItem#" + cValToChar( nI )
			
			cItemFilho := oDSPIt:GetValue( "FVM_ITEM" )
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cItemFilho )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numEmpe" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], oDSPIt:GetValue( "FVM_NEMPE" ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codSubItemEmpe" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], oDSPIt:GetValue( "FVM_SUBEMP" ) )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cValToChar( oDSPIt:GetValue( "FVM_VALOR" ) ) )
			Endif
			
			//Verifica se tem campos vari�veis por item de Despesa a Anular
			DefCpoVar( @oWsdl, aSimple, cCodPro, "FVM", cItemFilho, cSituac, cParent, .T., "FVL", cItemPai )
		Next nI
	Next nX
	
Return Nil

/*/{Protheus.doc} DefPdIt
Fun��o que define a quantidade de elementos complexos dentro do Predoc

@param cParents, String com todos os n�s superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param aQtdItem, Vetor com a quantidade definida de itens de elementos complexos
        O tamanho do vetor indica quantos elementos complexos h�, o valor da primeira
        posi��o indica quantos elementos filhos haver�o para o elemento em quest�o e 
        a terceira posi��o indica o tipo de predoc que ser� usado em cada elemento filho
@param cTipo, Tipo de predoc a ser comparado no vetor do segundo parametro 
        
@author Pedro Alencar	
@since 26/01/2015	
@version P12.1.4
/*/
Static Function DefPdIt( cParents, aQtdItem, cTipo )
	Local nRet := 0
	Local nX := 0
	Local cAux := ""
	Local aAux := {}
	Local nOccur := 0
	
	aAux := StrToKarr( cParents, "#" )
	If Len( aAux ) > 3
		cAux := AllTrim( aAux[Len(aAux)-2] )
		
		If Right( cAux, 7 ) == "deducao" .OR. Right( cAux, 7 ) == "encargo" .OR. Right( cAux, 9 ) == "dadosPgto"
			nOccur := Val( Left( aAux[Len(aAux)-1], 1 )  )
	
			For nX := 1 To Len( aQtdItem )
				If nOccur == nX 
					If cTipo == aQtdItem[nX][2]
						nRet := 1
					Endif								
					Exit
				Endif
			Next nX
		Endif
		
	Endif
Return nRet

/*/{Protheus.doc} DefPdOB
Fun��o que define no XML os dados do Predoc do tipo Ordem Banc�ria

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param cParents, String com todos os n�s superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param oPreDoc, Model de Pr�Doc do cadastro do DH (j� posicionado no predoc correto)

@author Pedro Alencar	
@since 26/01/2015	
@version P12.1.4
/*/ 
Static Function DefPdOB( oWsdl, aSimple, cParent, oPreDoc )
	Local nPos		:= 0
	Local cProcesso	:= ""
	Local nValorTX	:= 0
	Local aArea		:= GetArea()
	Local aCPAArea	:= {}
	Local aSA2Area	:= {}
	Local cOrgao		:= ""
	Local oDH		:= oPreDoc:GetModel()
	Local oCabecDH	:= oDH:GetModel( "CABDI" )
	
	DbSelectArea("CPA") // �rg�os P�blicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + C�digo �rg�o
	
	DbSelectArea("SA2")
	aSA2Area := SA2->(GetArea())
	SA2->(DbSetOrder(1)) // Filial + C�digo + Loja
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codTipoOB" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], AllTrim(oPreDoc:GetValue( "FV7_TIPOOB" )) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codCredorDevedor" .AND. aVet[5] == cParent } ) ) > 0
		cOrgao := oPreDoc:GetValue( "FV7_FAVORE" )
		If CPA->(DbSeek(FWxFilial("CPA") + PADR(cOrgao,TamSX3('CPA_CODORG')[1])))
			oWsdl:SetValue( aSimple[nPos][1], cOrgao )
		ElseIf SA2->(DbSeek(FWxFilial("SA2") + PADR(cOrgao,TamSX3('A2_COD')[1]) + oCabecDH:GetValue( "FV0_LOJA" ) ) )
			oWsdl:SetValue( aSimple[nPos][1], SA2->A2_CGC )	
		EndIf
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codNumLista" .AND. aVet[5] == cParent } ) ) > 0
		If !EMPTY(oPreDoc:GetValue( "FV7_LISTA" ))
			oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_LISTA" ) )
		EndIf
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "txtCit" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_CIT" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codRecoGru" .AND. aVet[5] == cParent } ) ) > 0
		//Campo n�o visualizado no SIAFI para as situa��es utilizadas no Protheus, portanto, n�o h� nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgRaGru" .AND. aVet[5] == cParent } ) ) > 0
		//Campo n�o visualizado no SIAFI para as situa��es utilizadas no Protheus, portanto, n�o h� nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numRaGru" .AND. aVet[5] == cParent } ) ) > 0
		//Campo n�o visualizado no SIAFI para as situa��es utilizadas no Protheus, portanto, n�o h� nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codRecDarf" .AND. aVet[5] == cParent } ) ) > 0
		//Campo n�o visualizado no SIAFI para as situa��es utilizadas no Protheus, portanto, n�o h� nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numRefDarf" .AND. aVet[5] == cParent } ) ) > 0
		//Campo n�o visualizado no SIAFI para as situa��es utilizadas no Protheus, portanto, n�o h� nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codContRepas" .AND. aVet[5] == cParent } ) ) > 0
		//Campo n�o visualizado no SIAFI para as situa��es utilizadas no Protheus, portanto, n�o h� nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codEvntBacen" .AND. aVet[5] == cParent } ) ) > 0
		//Campo n�o visualizado no SIAFI para as situa��es utilizadas no Protheus, portanto, n�o h� nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codFinalidade" .AND. aVet[5] == cParent } ) ) > 0
		//Campo n�o visualizado no SIAFI para as situa��es utilizadas no Protheus, portanto, n�o h� nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "txtCtrlOriginal" .AND. aVet[5] == cParent } ) ) > 0
		//Campo n�o visualizado no SIAFI para as situa��es utilizadas no Protheus, portanto, n�o h� nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrTaxaCambio" .AND. aVet[5] == cParent } ) ) > 0
		nValorTX := oPreDoc:GetValue( "FV7_TXCAMB" )
		If nValorTX > 0 
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( nValorTX ) )
		else
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( 1 ) )
		Endif
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "txtProcesso" .AND. aVet[5] == cParent } ) ) > 0
		cProcesso := AllTrim( oPreDoc:GetValue( "FV7_PROCES" ) )
		If ! Empty ( cProcesso )
			oWsdl:SetValue( aSimple[nPos][1], cProcesso )
		Endif
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codDevolucaoSPB" .AND. aVet[5] == cParent } ) ) > 0
		//Campo n�o visualizado no SIAFI para as situa��es utilizadas no Protheus, portanto, n�o h� nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "banco" .AND. aVet[5] == cParent + ".numDomiBancFavo#1" } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], AllTrim(oPreDoc:GetValue( "FV7_BCOFAV" )) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "agencia" .AND. aVet[5] == cParent + ".numDomiBancFavo#1" } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1],  AllTrim(oPreDoc:GetValue( "FV7_AGEFAV" )) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "conta" .AND. aVet[5] == cParent + ".numDomiBancFavo#1" } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1],  AllTrim(oPreDoc:GetValue( "FV7_CTAFAV" )) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "banco" .AND. aVet[5] == cParent + ".numDomiBancPgto#1" } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1],  AllTrim(oPreDoc:GetValue( "FV7_BCOUG" )) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "agencia" .AND. aVet[5] == cParent + ".numDomiBancPgto#1" } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1],  AllTrim(oPreDoc:GetValue( "FV7_AGEUG" )) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "conta" .AND. aVet[5] == cParent + ".numDomiBancPgto#1" } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1],  AllTrim(oPreDoc:GetValue( "FV7_CTAUG" )) )
	Endif
	
	RestArea(aArea)
	RestArea(aCPAArea)
	RestArea(aSA2Area)
Return Nil

/*/{Protheus.doc} DefPdDAR
Fun��o que define no XML os dados do Predoc do tipo DAR

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param cParents, String com todos os n�s superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param oPreDoc, Model de Pr�Doc do cadastro do DH (j� posicionado no predoc correto)

@author Pedro Alencar	
@since 27/01/2015	
@version P12.1.4
/*/
Static Function DefPdDAR( oWsdl, aSimple, cParent, oPreDoc )
	Local nPos := 0
	Local nValorNF := 0
	Local nValorAliq := 0
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codRecurso" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_RECURS" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "mesReferencia" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_MESCOM" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "anoReferencia" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_ANOCOM" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgTmdrServ" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_UGTMSV" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numNf" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_NUMNF" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "txtSerieNf" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_SERINF" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numSubSerieNf" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_SBSRNF" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codMuniNf" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_MUNICI" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "dtEmisNf" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], TrataData( oPreDoc:GetValue( "FV7_DTEMNF" ) ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrNf" .AND. aVet[5] == cParent } ) ) > 0
		nValorNF := oPreDoc:GetValue( "FV7_VALNF" )
		If nValorNF > 0 
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( nValorNF ) )
		Endif
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numAliqNf" .AND. aVet[5] == cParent } ) ) > 0
		nValorAliq := oPreDoc:GetValue( "FV7_ALIQNF" )
		If nValorAliq > 0 
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( nValorAliq ) )
		Endif
	Endif
Return Nil

/*/{Protheus.doc} DefPdDARF
Fun��o que define no XML os dados do Predoc do tipo DAR

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param cParents, String com todos os n�s superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param oPreDoc, Model de Pr�Doc do cadastro do DH (j� posicionado no predoc correto)

@author Pedro Alencar	
@since 27/01/2015	
@version P12.1.4
/*/
Static Function DefPdDARF( oWsdl, aSimple, cParent, oPreDoc )
	Local nPos := 0
	Local cProcesso := ""
	Local nValorRBA := 0
	local nValorPer := 0
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codRecurso" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_RECURS" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "dtPrdoApuracao" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], TrataData( oPreDoc:GetValue( "FV7_PERAPU" ) ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numRef" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_REFERE" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "txtProcesso" .AND. aVet[5] == cParent } ) ) > 0
		cProcesso := AllTrim( oPreDoc:GetValue( "FV7_PROCES" ) )
		If ! Empty ( cProcesso )
			oWsdl:SetValue( aSimple[nPos][1], cProcesso )		
		Endif
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrRctaBrutaAcum" .AND. aVet[5] == cParent } ) ) > 0
		nValorRBA := oPreDoc:GetValue( "FV7_RDBTAC" )
		If nValorRBA > 0
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( nValorRBA ) )
		Endif
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrPercentual" .AND. aVet[5] == cParent } ) ) > 0
		nValorPer := oPreDoc:GetValue( "FV7_PERCEN" )
		If nValorPer > 0
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( nValorPer ) )
		Endif
	Endif
Return Nil

/*/{Protheus.doc} DefPdGRU
Fun��o que define no XML os dados do Predoc do tipo GRU

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param cParents, String com todos os n�s superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param oPreDoc, Model de Pr�Doc do cadastro do DH (j� posicionado no predoc correto)

@author Pedro Alencar	
@since 27/01/2015	
@version P12.1.4
/*/
Static Function DefPdGRU( oWsdl, aSimple, cParent, oPreDoc )
	Local nPos := 0
	Local cProcesso := ""
	Local nValorDoc := 0
	Local nValorDes := 0
	Local nValorDed := 0
	Local aArea		:= GetArea()
	Local aCPAArea	:= {}
	Local aSA2Area	:= {}
	Local cOrgao		:= ""
	Local oDH		:= oPreDoc:GetModel()
	Local oCabecDH	:= oDH:GetModel( "CABDI" )
	
	DbSelectArea("CPA") // �rg�os P�blicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + C�digo �rg�o
	
	DbSelectArea("SA2")
	aSA2Area := SA2->(GetArea())
	SA2->(DbSetOrder(1)) // Filial + C�digo + Loja
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codRecurso" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_RECURS" ) )
	Endif
	
	//Campo n�o utilizado no Protheus.
	//If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numCodBarras" .AND. aVet[5] == cParent } ) ) > 0		 
	//Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgFavorecida" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_UGFAVO" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codRecolhedor" .AND. aVet[5] == cParent } ) ) > 0
		cOrgao := oPreDoc:GetValue( "FV7_FAVORE" )
		If CPA->(DbSeek(FWxFilial("CPA") + PADR(cOrgao,TamSX3('CPA_CODORG')[1])))
			oWsdl:SetValue( aSimple[nPos][1], cOrgao )
		ElseIf SA2->(DbSeek(FWxFilial("SA2") + PADR(cOrgao,TamSX3('A2_COD')[1]) + oCabecDH:GetValue( "FV0_LOJA" ) ) )
			oWsdl:SetValue( aSimple[nPos][1], SA2->A2_CGC )	
		EndIf 
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numReferencia" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_NNUMER" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "mesCompet" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_MESCOM" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "anoCompet" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_ANOCOM" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "txtProcesso" .AND. aVet[5] == cParent } ) ) > 0
		cProcesso := AllTrim( oPreDoc:GetValue( "FV7_PROCES" ) )
		If ! Empty ( cProcesso )
			oWsdl:SetValue( aSimple[nPos][1], cProcesso )
		Endif
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrDocumento" .AND. aVet[5] == cParent } ) ) > 0
		nValorDoc := oPreDoc:GetValue( "FV7_VLRDOC" )
		If nValorDoc > 0
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( nValorDoc ) )
		Endif
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrDesconto" .AND. aVet[5] == cParent } ) ) > 0
		nValorDes := oPreDoc:GetValue( "FV7_VLRABA" )
		If nValorDes > 0
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( nValorDes ) )
		Endif
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlrOutrDeduc" .AND. aVet[5] == cParent } ) ) > 0
		nValorDed := oPreDoc:GetValue( "FV7_VLRDED" )
		If nValorDed > 0
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( nValorDed ) )
		Endif
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codRecolhimento" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], "" ) //#DEL Ver esse campo no Protheus
	Endif
	
	RestArea(aArea)
	RestArea(aCPAArea)
	RestArea(aSA2Area)
Return Nil

/*/{Protheus.doc} DefPdGPS
Fun��o que define no XML os dados do Predoc do tipo GPS

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param cParents, String com todos os n�s superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param oPreDoc, Model de Pr�Doc do cadastro do DH (j� posicionado no predoc correto)

@author Pedro Alencar	
@since 27/01/2015	
@version P12.1.4
/*/
Static Function DefPdGPS( oWsdl, aSimple, cParent, oPreDoc )
	Local nPos := 0
	Local cProcesso := ""
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codRecurso" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_RECURS" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "txtProcesso" .AND. aVet[5] == cParent } ) ) > 0
		cProcesso := AllTrim( oPreDoc:GetValue( "FV7_PROCES" ) )
		If ! Empty ( cProcesso )
			oWsdl:SetValue( aSimple[nPos][1], cProcesso )
		Endif
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "mesCompet" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_MESCOM" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "anoCompet" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_ANOCOM" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "indrAdiant13" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], Iif( oPreDoc:GetValue( "FV7_ADT" ), "1", "0" ) )
	Endif
Return Nil

/*/{Protheus.doc} TrataData
Fun��o para formatar a data no seguinte padr�o para envio ao WS: aaaa-mm-dd

@param dData, Data a ser tratada para o envio ao webservice do SIAFI
@return cRet, String com a data tratada 

@author Pedro Alencar	
@since 29/01/2015	
@version P12.1.4
/*/
Static Function TrataData( dData )
	Local cRet := ""
	Local cDia := ""
	Local cMes := ""
	Local cAno := ""
	Default dData := StoD("")
	
	cDia := StrZero( Day( dData ), 2 )
	cMes := StrZero( Month( dData ), 2 )
	cAno := cValToChar( Year( dData ) )
	
	cRet := cAno + "-" + cMes + "-" + cDia
	
Return cRet

/*/{Protheus.doc} TrataTpPD
Fun��o para retornar a descri��o do tipo de predoc com base em seu c�digo

@param cTipoPD, C�digo que ter� a descri��o retornada
@return cRet, String com a descri��o do tipo de Predoc 

@author Pedro Alencar	
@since 03/02/2015	
@version P12.1.4
/*/
Static Function TrataTpPD( cTipoPD )
	Local cRet := ""
	Default cTipoPD := ""
	
	If cTipoPD == "1"
		cRet := "OB"
	ElseIf cTipoPD == "2"
		cRet := "NS"
	ElseIf cTipoPD == "3"
		cRet := "GRU"
	ElseIf cTipoPD == "4"
		cRet := "GPS"
	ElseIf cTipoPD == "5"
		cRet := "GFIP"
	ElseIf cTipoPD == "6"
		cRet := "DAR"
	ElseIf cTipoPD == "7"
		cRet := "DARF"
	Endif
	
Return cRet

/*/{Protheus.doc} DefCpoVar
Fun��o que define no XML os dados dos campos vari�veis das abas

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param cCodPro, C�digo do DH no Protheus
@param cTab, Tabela referente local do campo vari�vel que ser� definido no XML
@param cItem, Linha da situa��o na qual o campo vari�vel foi informado
@param cSituac, Situa��o na qual o campo vari�vel foi informado
@param cParents, String com todos os n�s superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param lFilho, Indica se s�o campos vari�veis do sub-item da situa��o
@param cTabPai, Tabela referente a aba do campo vari�vel que ser� definido no XML
@param cItemPai, Linha da situa��o pai na qual o campo vari�vel foi informado

@author Pedro Alencar	
@since 09/02/2015	
@version P12.1.4
/*/
Static Function DefCpoVar( oWsdl, aSimple, cCodPro, cTab, cItem, cSituac, cParent, lFilho, cTabPai, cItemPai )
	Local aAreaFVN := FVN->( GetArea() )
	Local aAreaFV4 := {}
	Local cTag := ""
	Local nPos := 0
	Local cChave := ""
	Local lLoop := .T.
	Default lFilho := .F.
	Default cTabPai := ""
	Default cItemPai := ""
	
	If lFilho
		FVN->( dbSetOrder( 2 ) ) //FVN_FILIAL + FVN_CODPRO + FVN_TABELA + FVN_ITETAB + FVN_TABPAI + FVN_ITEPAI + FVN_CAMPO
		cChave := FWxFilial("FVN") + cCodPro + cTab + cItem + cTabPai + cItemPai							
	Else
		FVN->( dbSetOrder( 1 ) ) //FVN_FILIAL + FVN_CODPRO + FVN_TABELA + FVN_ITETAB + FVN_CAMPO
		cChave := FWxFilial("FVN") + cCodPro + cTab + cItem
	Endif
	
	If FVN->( msSeek( cChave ) ) 
		aAreaFV4 := FV4->( GetArea() )
		FV4->( dbSetOrder( 1 ) )	//FV4_FILIAL + FV4_SITUAC + FV4_IDCAMP
		
		While lLoop
			//Pega a tag de XML do campo vari�vel 										
			cTag := ""
			If FV4->( msSeek( FWxFilial("FV4") + cSituac + FVN->FVN_CAMPO ) )
				cTag := AllTrim( FV4->FV4_TAGXML )
			Endif
						
			If ! Empty( cTag)
				//Procura o elemento com a tag do campo var�vel para defini��o do valor no XML
				If ( nPos := aScan( aSimple, {|aVet| aVet[2] == cTag .AND. aVet[5] == cParent } ) ) > 0 
					oWsdl:SetValue( aSimple[nPos][1], AllTrim( FVN->FVN_VALOR ) )
				Endif
			Endif
			
			FVN->( DbSkip() )
			
			//Define se vai continuar no loop
			If lFilho
				lLoop := FVN->( ! EOF() ) .AND. FVN->FVN_FILIAL == FWxFilial("FVN") .AND. FVN->FVN_CODPRO == cCodPro .AND. FVN->FVN_TABELA == cTab .AND. FVN->FVN_ITETAB == cItem .AND. FVN->FVN_TABPAI == cTabPai .AND. FVN->FVN_ITEPAI == cItemPai .AND. FV4->FV4_STATUS == '1' .AND. FV4->FV4_LOCAL == Iif(lFilho,'2','1')							
			Else
				lLoop := FVN->( ! EOF() ) .AND. FVN->FVN_FILIAL == FWxFilial("FVN") .AND. FVN->FVN_CODPRO == cCodPro .AND. FVN->FVN_TABELA == cTab .AND. FVN->FVN_ITETAB == cItem .AND. FV4->FV4_STATUS == '1' .AND. FV4->FV4_LOCAL == Iif(lFilho,'2','1')
			Endif			
		EndDo
		
		FV4->( RestArea( aAreaFV4 ) )		
	Endif
	
	FVN->( RestArea( aAreaFVN ) )
Return Nil

/*/{Protheus.doc} TrataRet
Fun��o que trata a resposta do WebService

@param cXmlRet, String com as informa��es do XML de resposta do SIAFI
@param cUser, usu�rio utilizado para autentica��o no SIAFI 
@param nTransac, N�mero da transa��o que ser� realizada 
        1 = Inclus�o; 2 = Cancelamento; 3 = Realiza��o; 4 = Estorno.
@param aRetCons, Vetor passado por refer�ncia para receber a lista de 
        compromissos caso a transa��o seja Contulta para Realiza��o 

@author Pedro Alencar	
@since 10/02/2015	
@version P12.1.4
/*/
Static Function TrataRet( cXmlRet, cUser, nTransac, aRetCons )
Local cResultado	:= ""  
Local cErro			:= ""
Local cIdCV8		:= ""
Local cMsgLog		:= ""
Local cMsgHelp		:= "" 
Local cResults		:= ""
Local nResults		:= 0
Local cCodSIAFI		:= ""
Local cCodigoOB		:= ""	
Local cUgEmitente	:= ""	
Local nValorDoc		:= 0	
Local dDtEmissao	:= dDataBase	
	
Default aRetCons	:= {}

//Trata a string de retorno e acerta as acentua��es
cXmlRet := DecodeUTF8( cXmlRet )

//Pega o resultado da requisi��o. Pode ser "FALHA", "SUCESSO" ou "INDEFINIDO"
cResultado := GetSimples( cXmlRet, "<resultado>", "</resultado>" )

//Se for FALHA, pega as mensagens de erro
If cResultado == "FALHA"		
	//Verifica se deu erro no WS (erro de SOAP) 
	cErro := GetSimples( cXmlRet, "<faultstring>", "</faultstring>" )		
	If ! Empty( cErro )
		cErro := CRLF + cErro
	Else
		//Pega todas as mensagens de erro retornadas pelo WS (caso o WS tenha recebido com sucesso e tenha respondido com os erros de neg�cio)
		If nTransac == DH_TRANS_REALIZACAO .OR. nTransac == DH_TRANS_ESTORNO 
			cErro := GetCompMGS( cXmlRet )
		Else
			cErro := GetMGS( cXmlRet )
		Endif
	Endif
	
	If nTransac == DH_TRANS_INCLUSAO
		cMsgLog	:= STR0181 //"Erro no envio do Documento H�bil: "
		cMsgHelp	:= STR0182 //"N�o foi poss�vel incluir o Documento H�bil no SIAFI. Verifique o LOG de Transa��es para mais detalhes."
	ElseIf nTransac == DH_TRANS_CANCELAMENTO
		cMsgLog	:= STR0183 //"Erro no cancelamento do Documento H�bil: "
		cMsgHelp := STR0184 //"N�o foi poss�vel cancelar o Documento H�bil no SIAFI. Verifique o LOG de Transa��es para mais detalhes."
	ElseIf nTransac == DH_TRANS_CONS_REALIZACAO
		cMsgLog	:= STR0185 //"Erro na consulta de compromissos para realiza��o do Documento H�bil: "
		cMsgHelp := STR0186 //"N�o foi poss�vel consultar os compromissos para realizar o Documento H�bil no SIAFI. Verifique o LOG de Transa��es para mais detalhes."
	ElseIf nTransac == DH_TRANS_REALIZACAO
		cMsgLog	:= STR0187 //"Erro na realiza��o do Documento H�bil: "
		cMsgHelp := STR0188 //"N�o foi poss�vel realizar o Documento H�bil no SIAFI. Verifique o LOG de Transa��es para mais detalhes."
	ElseIf nTransac == DH_TRANS_CONS_ESTORNO
		cMsgLog	:= STR0189 //"Erro na consulta de compromissos para estorno do Documento H�bil: "
		cMsgHelp := STR0190 //"N�o foi poss�vel consultar os compromissos para estornar o Documento H�bil no SIAFI. Verifique o LOG de Transa��es para mais detalhes."
	ElseIf nTransac == DH_TRANS_ESTORNO
		cMsgLog	:= STR0191 //"Erro no estorno do Documento H�bil: "
		cMsgHelp	:= STR0192 //"N�o foi poss�vel estornar o Documento H�bil no SIAFI. Verifique o LOG de Transa��es para mais detalhes."
	Endif
	
	//Inclu� a mensagem de erro no log de Transa��es 
	ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
	ProcLogAtu( "ERRO", cMsgLog, cResultado + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99") + CRLF + cErro, , .T. ) //"Usu�rio SIAFI: "
									
	Help( "", 1, "XMLRET1", , cMsgHelp, 1, 0 )
ElseIf cResultado == "SUCESSO"
	//#DEL Pegar as informa��es que devem ser gravadas no Protheus (dt Ateste, Cod DH)
	
	//Pega o resultado da Consulta
	If nTransac == DH_TRANS_CONS_REALIZACAO .OR. nTransac == DH_TRANS_CONS_ESTORNO
		cResults := GetSimples( cXmlRet, "<numeroResultados>", "</numeroResultados>" )
		nResults := Iif( Empty( cResults ), 0, Val( cResults )  )
		
		//Se houve sucesso e teve algum registro retornado na consulta, ent�o pega os registros encontrados
		If nResults > 0
			 //Pega todos os compromissos retornados no XML de resposta da consulta no WS
			 aRetCons := aClone( GetCOMP( cXmlRet ) )
		Else //Se teve sucesso na consulta mas n�o foi encontrado nenhum registro com os par�metros informados
			//Pega todas as mensagens de erro retornadas pelo WS (caso o WS tenha recebido com sucesso e tenha respondido com os erros de neg�cio)
			cErro := GetMGS( cXmlRet )
			
			If nTransac == DH_TRANS_CONS_REALIZACAO
				cMsgLog	:= STR0187 //"Erro na realiza��o do Documento H�bil: "
				cMsgHelp := STR0186 //"N�o foi poss�vel realizar o Documento H�bil no SIAFI. Verifique o LOG de Transa��es para mais detalhes."
			ElseIf nTransac == DH_TRANS_CONS_ESTORNO
				cMsgLog	:= STR0191 //"Erro no estorno do Documento H�bil: "
				cMsgHelp := STR0192 //"N�o foi poss�vel estornar o Documento H�bil no SIAFI. Verifique o LOG de Transa��es para mais detalhes."
			Endif
			
			//Inclu� a mensagem de erro no log de Transa��es 
			ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
			ProcLogAtu( "ERRO", cMsgLog, "FALHA" + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99") + CRLF + cErro, , .T. ) //"Usu�rio SIAFI: "
			
			Help( "", 1, "XMLRET3", , cMsgHelp, 1, 0 )
		Endif
	Else
		ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
		If nTransac == DH_TRANS_INCLUSAO
			cMsgLog	:= STR0174 //"Envio do Documento H�bil: "
			cMsgHelp	:= STR0194 //"Documento H�bil inclu�do com sucesso no SIAFI."
			cCodSIAFI += GetSimples( cXmlRet, "<anoDH>", "</anoDH>" )
			cCodSIAFI += GetSimples( cXmlRet, "<codTipoDH>", "</codTipoDH>" )
			cCodSIAFI += PADL(GetSimples( cXmlRet, "<numDH>", "</numDH>" ),TamSX3("FV0_CODIGO")[1],"0")
			
			FV0->(RecLock("FV0",.F.))
			FV0->FV0_CODSIA	:= cCodSIAFI
			FV0->FV0_STATUS	:= "2" // Aguardando Realiza��o
			FV0->FV0_ATESTE	:= DDATABASE
			FV0->(MsUnLock())
			
			ProcLogAtu( "MENSAGEM", cMsgLog, cResultado + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99") + CRLF + STR0208 + cCodSIAFI, , .T. ) //"Usu�rio SIAFI: "
		ElseIf nTransac == DH_TRANS_CANCELAMENTO
			cMsgLog	:= STR0195 //"Cancelamento do Documento H�bil: "
			cMsgHelp	:= STR0196 //"Documento H�bil cancelado com sucesso no SIAFI."
			ProcLogAtu( "MENSAGEM", cMsgLog, cResultado + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99"), , .T. ) //"Usu�rio SIAFI: "
			
			F761LibTit(FV0->FV0_CODIGO)
			
			FV0->(RecLock("FV0",.F.))
			FV0->FV0_STATUS := "4" // Cancelado
			FV0->(MsUnLock())
		ElseIf nTransac == DH_TRANS_REALIZACAO
			cMsgLog	:= STR0197 //"Realiza��o do Documento H�bil: "
			cMsgHelp	:= STR0198 //"Documento H�bil realizado com sucesso no SIAFI."
			ProcLogAtu( "MENSAGEM", cMsgLog, cResultado + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99"), , .T. ) //"Usu�rio SIAFI: "
			
			FV0->(RecLock("FV0",.F.))
			FV0->FV0_STATUS := "3" // Realizado
			FV0->(MsUnLock())

			//Verifico se foram enviados dados de Ordem Banc�ria no XML
			cCodigoOB	:= GetSimples( cXmlRet, "<numeroDocumento>", "</numeroDocumento>" )
			cUgEmitente	:= GetSimples( cXmlRet, "<ugEmitenteDocumento>", "</ugEmitenteDocumento>" )
			nValorDoc	:= Val( GetSimples( cXmlRet, "<valorDocumento>", "</valorDocumento>" ) )
			dDtEmissao	:= GetSimples( cXmlRet, "<dataEmissaoDocumento>", "</dataEmissaoDocumento>" )  

			dDtEmissao	:= StoD( StrTran( SubStr( dDtEmissao, 1, 10 ), '-', '' ) ) 

			//Efetuo a grava��o da tabela FVQ com a Ordem Banc�ria do pagamento do Documento H�bil
			If !Empty( cCodigoOB ) //Somente gravo se o c�digo da Ordem Banc�ria foi enviado 
				FVQ->( dbSetOrder(1) )
				If !FVQ->( DbSeek( xFilial('FVQ') + FV0->FV0_CODIGO + cCodigoOB ) ) //Garanto que o mesmo c�digo n�o seja gravado, gerando chave duplicada
					RecLock('FVQ',.T.)
						FVQ->FVQ_FILIAL := xFilial('FVQ')
						FVQ->FVQ_CODPRO := FV0->FV0_CODIGO
						FVQ->FVQ_CODOBR := cCodigoOB
						FVQ->FVQ_UGEMIT := cUgEmitente
						FVQ->FVQ_VLRDOC := nValorDoc
						FVQ->FVQ_DTEMIS := dDtEmissao
					FVQ->( MsUnLock() )
				EndIf
			EndIf

		ElseIf nTransac == DH_TRANS_ESTORNO
			cMsgLog	:= STR0199 //"Estorno do Documento H�bil: "
			cMsgHelp	:= STR0200 //"Documento H�bil estornado com sucesso no SIAFI."
			ProcLogAtu( "MENSAGEM", cMsgLog, cResultado + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99"), , .T. ) //"Usu�rio SIAFI: "
			
			F761LibTit(FV0->FV0_CODIGO)
			
			FV0->(RecLock("FV0",.F.))
			FV0->FV0_STATUS := "5" // Cancelado
			FV0->(MsUnLock())			
		Endif
		
		MsgInfo( cMsgHelp )	
	Endif
			
ElseIf cResultado == "INDEFINIDO"
	If nTransac == DH_TRANS_INCLUSAO
		cMsgLog	:= STR0174 //"Envio do Documento H�bil: "
		cMsgHelp := STR0201 //"O retorno da inclus�o do Documento H�bil no SIAFI foi INDEFINIDO. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI."
	ElseIf nTransac == DH_TRANS_CANCELAMENTO
		cMsgLog	:= STR0195 //"Cancelamento do Documento H�bil: "
		cMsgHelp := STR0202 //"O retorno do cancelamento do Documento H�bil no SIAFI foi INDEFINIDO. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI."
	ElseIf nTransac == DH_TRANS_CONS_REALIZACAO
		cMsgLog	:= STR0203 //"Consulta de compromissos para realiza��o do Documento H�bil: "
		cMsgHelp := STR0204 //"O retorno da consulta do Documento H�bil no SIAFI foi INDEFINIDO. A requisi��o de realiza��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI."
	ElseIf nTransac == DH_TRANS_REALIZACAO
		cMsgLog	:= STR0197 //"Realiza��o do Documento H�bil: "
		cMsgHelp := STR0201 //"O retorno da realiza��o do Documento H�bil no SIAFI foi INDEFINIDO. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI."
	ElseIf nTransac == DH_TRANS_CONS_ESTORNO
		cMsgLog	:= STR0206 //"Consulta de compromissos para estorno do Documento H�bil: "
		cMsgHelp := STR0207 //"O retorno da consulta do Documento H�bil no SIAFI foi INDEFINIDO. A requisi��o de estorno pode ou n�o ter tido sucesso. Verifique no sistema SIAFI."
	ElseIf nTransac == DH_TRANS_ESTORNO
		cMsgLog	:= STR0199 //"Estorno do Documento H�bil: "
		cMsgHelp	:= STR0201 //"O retorno da realiza��o do Documento H�bil no SIAFI foi INDEFINIDO. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI."		
	Endif
	
	ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
	ProcLogAtu( "MENSAGEM", cMsgLog, cResultado + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99"), , .T. ) //"Usu�rio SIAFI: "
	
	Help( "", 1, "XMLRET2", , cMsgHelp, 1, 0 )
Endif

Return Nil

/*/{Protheus.doc} CancelaDH
Fun��o para envio do cancelamento do DH ao WS

@param cCA, Caminho do Certificado de Autoriza��o do SIAFI
@param cCERT, Caminho do Certificado de Cliente do SIAFI
@param cKEY,  Caminho da Chave Privada do Certificado do SIAFI
@param cWsdlURL, URL do WSDL do servi�o ManterContasPagarReceber do SIAFI
@param cUser, Usu�rio para autentica��o no SIAFI
@param cPass, Senha para autentica��o no SIAFI
 
@author Pedro Alencar	
@since 12/02/2015	
@version P12.1.4
/*/
Static Function CancelaDH( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass )
	Local lRet := .F.
	Local oWsdl := TWsdlManager():New()
	Local cXmlRet := ""
	Local cIdCV8 := ""
	Local aRetMot	:= {}
	
	//Define as propriedades para tratar os prefixos NS das tags do XML e para remover as tags vazias, pois o WS do SIAFI n�o aceita as mesmas
	oWsdl:lUseNSPrefix := .T.
	oWsdl:lRemEmptyTags := .T.
	oWsdl:bNoCheckPeerCert := .T. // Desabilita o check de CAs					   
	
	//Informa os arquivos da quebra do certificado digital
	oWsdl:cSSLCACertFile := cCA
	oWsdl:cSSLCertFile := cCERT
	oWsdl:cSSLKeyFile := cKEY

	//"Parseia" o WSDL do SIAFI, para manipular o mesmo atrav�s do objeto da classe TWsdlManager  
	lRet := oWsdl:ParseURL( cWsdlURL )	
	If lRet
		//Define a opera��o com a qual ser� trabalhada no Documento H�bil em quest�o
		lRet := oWsdl:SetOperation( "cprDHCancelarDH" )
		
		aRetMot := MotCancCPR()
		
		If lRet .AND. aRetMot[1]
			//Monta o XML de comunica��o com o WS do SIAFI
			MontaCanc( @oWsdl, cUser, cPass, aRetMot[2] )

			//Se houver mensagem definida, envia a mensagem. Do contr�rio, mostra o erro do objeto.
			oWsdl:lVerbose := .T. //#DEL
			If !Empty( oWsdl:GetSoapMsg() )
				//Envia a mensagem SOAP ao servidor
				oWsdl:lProcResp := .F. //N�o processa o retorno automaticamente no objeto (ser� tratado atrav�s do m�todo GetSoapResponse)
				lRet := oWsdl:SendSoapMsg()
				If lRet
					//Pega a resposta para os devidos tratamentos
					cXmlRet := oWsdl:GetSoapResponse()
					If ! Empty( cXmlRet )
						TrataRet( cXmlRet, cUser, DH_TRANS_CANCELAMENTO )
					Else
						ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
						ProcLogAtu( "MENSAGEM", STR0195, STR0175 + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99"), , .T. ) //'Cancelamento do Documento H�bil: '//"N�o foi poss�vel tratar a resposta do WebService. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI."//"Usu�rio SIAFI: "
		
						Help( "", 1, "WSDLXMLCAN1", , STR0175, 1, 0 ) //"N�o foi poss�vel tratar a resposta do WebService. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI."		
					Endif
				Else
					Help( "", 1, "WSDLXMLCAN2", , STR0177 + CRLF + oWsdl:cError, 1, 0 ) //"Ocorreu um problema ao enviar a requisi��o para o SIAFI: "
				Endif
			Else
				Help( "", 1, "WSDLXMLCAN3", , STR0178 + CRLF + oWsdl:cError, 1, 0 ) //"H� um problema com os dados do Documento H�bil: "
			Endif
			
		Else //Se n�o conseguiu definir a opera��o
			Help( "", 1, "WSDLXMLCAN4", , STR0179 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao definir a opera��o para envio ao SIAFI: "
		Endif
	Else //Se n�o conseguiu acessar o endere�o do WSDL corretamente 
		Help( "", 1, "WSDLXMLCAN5", , STR0180 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao acessar o WSDL do servi�o do SIAFI: "
	Endif 	

	oWsdl := Nil 
Return Nil

/*/{Protheus.doc} MontaCanc
Fun��o para montagem da estrutura do do XML de cancelamento do DH para envio ao WS

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param cUser, Usu�rio para autentica��o no SIAFI
@param cPass, Senha para autentica��o no SIAFI
 
@author Pedro Alencar	
@since 12/01/2015	
@version P12.1.4
/*/
Static Function MontaCanc( oWsdl, cUser, cPass , cJustif)
	Local oModelDH
	Local oCabecDH
	Local aSimple := {}
	
	//Ativa o Model principal da rotina
	oModelDH := FWLoadModel( "FINA761" )
	oModelDH:SetOperation( MODEL_OPERATION_VIEW ) //Visualiza��o
	oModelDH:Activate()
	
	//Model do Cabe�alho do DH
	oCabecDH := oModelDH:GetModel( "CABDI" )
	
	//Define as ocorr�ncias dos tipos complexos
	DefComplex( @oWsdl, DH_TRANS_CANCELAMENTO )
	
	//Pega os elementos simples, ap�s defini��o das ocorr�ncias dos tipos complexos
	aSimple := oWsdl:SimpleInput()
	
	//Monta o cabe�alho da mensagem
	DefCabec( @oWsdl, aSimple, cUser, cPass, oCabecDH:GetValue( "FV0_UGEMIT" ) )
	
	//Monta os dados de cancelamento do DH
	DefCanc( @oWsdl, aSimple, oCabecDH, cJustif )
	
	//Limpa os objetos MVC da mem�ria
	oModelDH:Deactivate()
	oModelDH:Destroy()
	oModelDH := Nil
	oCabecDH := Nil
Return Nil

/*/{Protheus.doc} DefCanc
Fun��o que define no XML os dados do cancelamento do DH

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param oCabecDH, Model de cabe�alho do cadastro do DH

@author Pedro Alencar	
@since 12/01/2015	
@version P12.1.4
/*/
Static Function DefCanc( oWsdl, aSimple, oCabecDH, cJustif)
	Local nPos := 0
	Local cParent := ""
	Local cAnoDH := ""
	
	//Cabe�alho do DH
	cParent := "cprDHCancelarDH#1.cprDHCancelarEntrada#1"
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgEmit" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oCabecDH:GetValue( "FV0_UGEMIT" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "anoDH" .AND. aVet[5] == cParent } ) ) > 0
		cAnoDH := cValToChar( Year( oCabecDH:GetValue( "FV0_DTEMIS" ) ) )
		oWsdl:SetValue( aSimple[nPos][1], cAnoDH )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codTipoDH" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], AllTrim( oCabecDH:GetValue( "FV0_TIPODC" ) ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numDH" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], SUBSTR( oCabecDH:GetValue( "FV0_CODSIA" ),7 ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "txtMotivoCancel" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], cJustif ) //#DEL ver esse campo no Protheus
	Endif
Return Nil

/*/{Protheus.doc} TrataTpAc
Fun��o para converter o valor do tipo de acr�scimo no protheus para o valor do WebService

@param cTpAc, Tipo de acr�scimo do Protheus
@return cRet, Caractere com o tipo de Acr�scimo, de acordo com o valor esperado no WS  

@author Pedro Alencar	
@since 19/02/2015	
@version P12.1.4
/*/
Static Function TrataTpAc( cTpAc )
	Local cRet := ""
	Default cTpAc := ""
	
	If cTpAc == "1" //Multa
		cRet := "M"
	ElseIf cTpAc == "2" //Juros de mora
		cRet := "J"
	ElseIf cTpAc == "3" //Encargos
		cRet := "E"
	ElseIf cTpAc == "4" //Outros Acr�scimos
		cRet := "O"
	Endif
	
Return cRet

/*/{Protheus.doc} VerifPdPGT
Fun��o para verificar se o pr�-doc de Dados de pagamento ser� por linha de situa��o 
ou por linha de favorecido

@param cTpDH, Tipo de Documento
@param nQtdPSO, Quantidade de ocorr�ncias na aba PSO
@param oPSO, Model de Principal Sem Or�amento do cadastro do DH
@param nQtdPCO, Quantidade de ocorr�ncias na aba PCO
@param oPCO, Model de Principal Com Or�amento do cadastro do DH
@return lRet, Se True: Por linha de favorecido. Se False: Por linha de situa��o   

@author Pedro Alencar	
@since 20/02/2015	
@version P12.1.4
/*/ 
Static Function VerifPdPGT( cTpDH, nQtdPSO, oPSO, nQtdPCO, oPCO )
	Local lRet := .T.
	
	//Verifica se o DH � do tipo DT e se tem dados na aba PSO para defini��o dos Pr�-Docs de Dados de Pagamento
	If cTpDH == "DT" 
		If nQtdPSO > 0
			//Se encontrar a situa��o PSO002 na aba PSO, ent�o o Pr�-Doc � por linha de favorecido na aba de Dados de Pagamento
			If oPSO:SeekLine( { {"FV8_SITUAC", "PSO002"} } )
				lRet := .T.
			Else
				lRet := .F.
			Endif
		Else
			lRet := .T.
		Endif
	ElseIf cTpDH == "FL" .OR. cTpDH == "PC" //Se for DH do tipo FL ou PC, ent�o o Pr�-Doc � por linha de favorecido na aba de Dados de Pagamento
		lRet := .T.
	ElseIf cTpDH == "RB" //Verifica se o DH � do tipo RB e se tem dados na aba PCO para defini��o dos Pr�-Docs de Dados de Pagamento
		If nQtdPCO > 0
			//Se encontrar a situa��o DSP901 na aba PCO, ent�o o Pr�-Doc � por linha de favorecido na aba de Dados de Pagamento
			If oPCO:SeekLine( { {"FV2_SITUAC", "DSP901"} } )
				lRet := .T.
			Else
				lRet := .F.
			Endif
		Else
			lRet := .T.
		Endif
	ElseIf cTpDH == "RP" .OR. cTpDH == "NP" //Verifica se o DH � do tipo RP ou NP e se tem dados na aba PCO para defini��o dos Pr�-Docs de Dados de Pagamento
		lRet := .T.
	Endif
Return lRet

/*/{Protheus.doc} RealizaDH
Fun��o para envio da realiza��o do DH ao WS

@param cCA, Caminho do Certificado de Autoriza��o do SIAFI
@param cCERT, Caminho do Certificado de Cliente do SIAFI
@param cKEY,  Caminho da Chave Privada do Certificado do SIAFI
@param cWsdlURL, URL do WSDL do servi�o ManterContasPagarReceber do SIAFI
@param cUser, Usu�rio para autentica��o no SIAFI
@param cPass, Senha para autentica��o no SIAFI
 
@author Pedro Alencar	
@since 23/02/2015	
@version P12.1.4
/*/
Static Function RealizaDH( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass, lLote, cArqTrb, cMarca )
	Local lRet		:= .F.
	Local oWsdl		:= TWsdlManager():New()
	Local cXmlRet		:= ""
	Local cIdCV8		:= ""
	Local aComp		:= {}
	Local aConfirm 	:= {}
	Local nQtdReal	:= 1
	Local nRealiza	:= 1
	
	oWsdl:bNoCheckPeerCert := .T. // Desabilita o check de CAs
	//Se retornou algum compromisso, ent�o realiza o DH
	//#DEL CHAMAR UMA TELA E LISTAR OS COMPROMISSO PRA DIGITAR A VINCULA��O
	If lLote
		aConfirm := ExibeDHCOM(cArqTrb, cMarca, cCA, cCERT, cKEY, cWsdlURL, cUser, cPass)
		nQtdReal := Len(aConfirm)
	Else
		//Pega a lista de compromissos para realiza��o no SIAFI, referentes ao DH em quest�o
		aComp := aClone( ConsComp( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass ) )
		If Len(aComp) > 0
			aConfirm := {ExibeCOM( aComp )}
		Else
			nQtdReal := 0
			lRet := .F.
		EndIf
	EndIf
	
	If nQtdReal > 0
		For nRealiza := 1 To nQtdReal
			If aConfirm[nRealiza][1]
				//Define as propriedades para tratar os prefixos NS das tags do XML e para remover as tags vazias, pois o WS do SIAFI n�o aceita as mesmas
				oWsdl:lUseNSPrefix	:= .T.
				oWsdl:lRemEmptyTags	:= .T.
				
				//Informa os arquivos da quebra do certificado digital
				oWsdl:cSSLCACertFile	:= cCA
				oWsdl:cSSLCertFile	:= cCERT
				oWsdl:cSSLKeyFile		:= cKEY
				
				//"Parseia" o WSDL do SIAFI, para manipular o mesmo atrav�s do objeto da classe TWsdlManager  
				lRet := oWsdl:ParseURL( cWsdlURL ) //#DEL tentar n�o usar o Parse 2 vezes pro mesmos processo (ta sendo chamado na consulta e na realiza��o) - Melhorar por conta de perfomance
				If lRet
					//Define a opera��o com a qual ser� trabalhada no Documento H�bil em quest�o
					lRet := oWsdl:SetOperation( "cprCPRealizarTotalCompromissos" )
					If lRet
						//Monta o XML de comunica��o com o WS do SIAFI
						MontaReal( @oWsdl, cUser, cPass, aConfirm[nRealiza][2], aConfirm[nRealiza][2] )
			
						//Se houver mensagem definida, envia a mensagem. Do contr�rio, mostra o erro do objeto.
						oWsdl:lVerbose := .T. //#DEL
						If !Empty( oWsdl:GetSoapMsg() )
							//Envia a mensagem SOAP ao servidor
							oWsdl:lProcResp := .F. //N�o processa o retorno automaticamente no objeto (ser� tratado atrav�s do m�todo GetSoapResponse)
							lRet := oWsdl:SendSoapMsg()
							If lRet
								//Pega a resposta para os devidos tratamentos
								cXmlRet := oWsdl:GetSoapResponse()
								If ! Empty( cXmlRet )
									TrataRet( cXmlRet, cUser, DH_TRANS_REALIZACAO )
								Else
									ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
									ProcLogAtu( "MENSAGEM", STR0197, STR0175 + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99"), , .T. ) //'Realiza��o do Documento H�bil: '//"N�o foi poss�vel tratar a resposta do WebService. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI."//"Usu�rio SIAFI: "
					
									Help( "", 1, "WSDLXMLREA1", , STR0175 , 1, 0 ) //"N�o foi poss�vel tratar a resposta do WebService. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI."		
								Endif
							Else
								Help( "", 1, "WSDLXMLREA2", , STR0177 + CRLF + oWsdl:cError, 1, 0 ) //"Ocorreu um problema ao enviar a requisi��o para o SIAFI: "
							Endif
						Else
							Help( "", 1, "WSDLXMLREA3", , STR0178 + CRLF + oWsdl:cError, 1, 0 ) //"H� um problema com os dados do Documento H�bil: "
						Endif
						
					Else //Se n�o conseguiu definir a opera��o
						Help( "", 1, "WSDLXMLREA4", , STR0179 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao definir a opera��o para envio ao SIAFI: "
					Endif
				Else //Se n�o conseguiu acessar o endere�o do WSDL corretamente 
					Help( "", 1, "WSDLXMLREA5", , STR0180 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao acessar o WSDL do servi�o do SIAFI: "
				Endif 	
			Endif
		Next nRealiza
	EndIf
	oWsdl := Nil 
Return Nil

/*/{Protheus.doc} ConsComp
Fun��o para consulta de compromissos para realiza��o do DH no WS

@param cCA, Caminho do Certificado de Autoriza��o do SIAFI
@param cCERT, Caminho do Certificado de Cliente do SIAFI
@param cKEY,  Caminho da Chave Privada do Certificado do SIAFI
@param cWsdlURL, URL do WSDL do servi�o ManterContasPagarReceber do SIAFI
@param cUser, Usu�rio para autentica��o no SIAFI
@param cPass, Senha para autentica��o no SIAFI
@param lEstorno, Indica se � consulta de compromissos para estorno 
@return aRetCons, Vetor com a lista de compromissos para Realiza��o
        
@author Pedro Alencar	
@since 25/02/2015	
@version P12.1.4
/*/
Static Function ConsComp( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass, lEstorno )
	Local lRet := .F.
	Local oWsdl := TWsdlManager():New()
	Local cXmlRet := ""
	Local cIdCV8 := ""
	Local aRetCons := {}
	Local cOperation := ""
	Local cLogTit := ""
	Default lEstorno := .F. 
	
	//Define as propriedades para tratar os prefixos NS das tags do XML e para remover as tags vazias, pois o WS do SIAFI n�o aceita as mesmas
	oWsdl:lUseNSPrefix := .T.
	oWsdl:lRemEmptyTags := .T.														   
	oWsdl:bNoCheckPeerCert := .T. // Desabilita o check de CAs
	//Informa os arquivos da quebra do certificado digital
	oWsdl:cSSLCACertFile := cCA
	oWsdl:cSSLCertFile := cCERT
	oWsdl:cSSLKeyFile := cKEY

	//"Parseia" o WSDL do SIAFI, para manipular o mesmo atrav�s do objeto da classe TWsdlManager  
	lRet := oWsdl:ParseURL( cWsdlURL )	
	If lRet
		//Define a opera��o com a qual ser� trabalhada no Documento H�bil em quest�o
		If lEstorno
			cOperation := "cprCPConsultarCompromissosParaEstorno"
		Else
			cOperation := "cprCPConsultarCompromissosParaRealizacao"
		Endif				
		lRet := oWsdl:SetOperation( cOperation )
		If lRet
			//Monta o XML de comunica��o com o WS do SIAFI
			MontaCons( @oWsdl, cUser, cPass, lEstorno )

			//Se houver mensagem definida, envia a mensagem. Do contr�rio, mostra o erro do objeto.
			oWsdl:lVerbose := .T. //#DEL
			If !Empty( oWsdl:GetSoapMsg() )
				//Envia a mensagem SOAP ao servidor
				oWsdl:lProcResp := .F. //N�o processa o retorno automaticamente no objeto (ser� tratado atrav�s do m�todo GetSoapResponse)
				lRet := oWsdl:SendSoapMsg()
				If lRet
					//Pega a resposta para os devidos tratamentos
					cXmlRet := oWsdl:GetSoapResponse()
					If ! Empty( cXmlRet )
						If lEstorno
							TrataRet( cXmlRet, cUser, DH_TRANS_CONS_ESTORNO, @aRetCons )
						Else
							TrataRet( cXmlRet, cUser, DH_TRANS_CONS_REALIZACAO, @aRetCons )
						Endif
					Else
						If lEstorno
							cLogTit := STR0209 //'Estorno do Documento H�bil (Consulta): '
						Else
							cLogTit := STR0210 //'Realiza��o do Documento H�bil (Consulta): '
						Endif						
						ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
						ProcLogAtu( "MENSAGEM", cLogTit, STR0175 + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99"), , .T. ) //"N�o foi poss�vel tratar a resposta do WebService. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI."//"Usu�rio SIAFI: "
		
						Help( "", 1, "WSDLXMLCON1", , STR0175, 1, 0 ) //"N�o foi poss�vel tratar a resposta do WebService. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI."		
					Endif
				Else
					Help( "", 1, "WSDLXMLCON2", , STR0177 + CRLF + oWsdl:cError, 1, 0 ) //"Ocorreu um problema ao enviar a requisi��o para o SIAFI: "
				Endif
			Else
				Help( "", 1, "WSDLXMLCON3", , STR0178 + CRLF + oWsdl:cError, 1, 0 ) //"H� um problema com os dados do Documento H�bil: "
			Endif
			
		Else //Se n�o conseguiu definir a opera��o
			Help( "", 1, "WSDLXMLCON4", , STR0179 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao definir a opera��o para envio ao SIAFI: "
		Endif
	Else //Se n�o conseguiu acessar o endere�o do WSDL corretamente 
		Help( "", 1, "WSDLXMLCON5", , STR0180 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao acessar o WSDL do servi�o do SIAFI: "
	Endif 	

	oWsdl := Nil 
Return aRetCons

/*/{Protheus.doc} MontaCons
Fun��o para montagem da estrutura do do XML de Consulta de Compromissos do DH 
para realiza��o

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param cUser, Usu�rio para autentica��o no SIAFI
@param cPass, Senha para autentica��o no SIAFI
@param lEstorno, Indica se � consulta de compromissos para estorno

@author Pedro Alencar	
@since 23/02/2015	
@version P12.1.4
/*/
Static Function MontaCons( oWsdl, cUser, cPass, lEstorno )
	Local oModelDH
	Local oCabecDH
	Local aSimple := {}
	Default lEstorno := .F.
	
	//Ativa o Model principal da rotina
	oModelDH := FWLoadModel( "FINA761" )
	oModelDH:SetOperation( MODEL_OPERATION_VIEW ) //Visualiza��o
	oModelDH:Activate()
	
	//Model do Cabe�alho do DH
	oCabecDH := oModelDH:GetModel( "CABDI" )
	
	//Define as ocorr�ncias dos tipos complexos
	If lEstorno
		DefComplex( @oWsdl, DH_TRANS_CONS_ESTORNO )
	Else
		DefComplex( @oWsdl, DH_TRANS_CONS_REALIZACAO )
	Endif
	
	//Pega os elementos simples, ap�s defini��o das ocorr�ncias dos tipos complexos
	aSimple := oWsdl:SimpleInput()
	
	//Monta o cabe�alho da mensagem
	DefCabec( @oWsdl, aSimple, cUser, cPass, oCabecDH:GetValue( "FV0_UGEMIT" ) )
	
	//Monta os dados da consulta do DH para pegar os compromissos pra realizar
	DefCons( @oWsdl, aSimple, oCabecDH, lEstorno )
	
	//Limpa os objetos MVC da mem�ria
	oModelDH:Deactivate()
	oModelDH:Destroy()
	oModelDH := Nil
	oCabecDH := Nil
Return Nil

/*/{Protheus.doc} DefCons
Fun��o que define no XML os dados da consulta dos compromissos
do DH para realiza��o

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param oCabecDH, Model de cabe�alho do cadastro do DH
@param lEstorno, Indica se � consulta de compromissos para estorno

@author Pedro Alencar	
@since 23/02/2015	
@version P12.1.4
/*/
Static Function DefCons( oWsdl, aSimple, oCabecDH, lEstorno )
	Local nPos		:= 0
	Local cParent		:= ""
	Local cAnoDH		:= ""
	Local aArea		:= GetArea()
	Local aCPAArea	:= {}
	Local aSA2Area	:= {}
	Local cOrgao		:= ""
	Local cCodSIAFI	:= ""
	Default lEstorno	:= .F.
	
	DbSelectArea("CPA") // �rg�os P�blicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + C�digo �rg�o
	
	DbSelectArea("SA2")
	aSA2Area := SA2->(GetArea())
	SA2->(DbSetOrder(1)) // Filial + C�digo + Loja
	
	//Par�metros da Consulta
	If lEstorno
		cParent := "cprCPConsultarCompromissosParaEstorno#1.parametrosConsulta#1"
		
		// #Verificar tag #DEL
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "tipoCompromisso" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], "LIQUIDO" )		
		Endif
	Else
		cParent := "cprCPConsultarCompromissosParaRealizacao#1.parametrosConsulta#1"
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "ugPagadoraRecebedora" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oCabecDH:GetValue( "FV0_UGPAGA" ) )		
	Endif
	
	If AllTrim(oCabecDH:GetValue( "FV0_TIPODC" )) # "FL"
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "favorecidoRecolhedor" .AND. aVet[5] == cParent } ) ) > 0
			cOrgao := oCabecDH:GetValue( "FV0_FORNEC" )
			If CPA->(DbSeek(FWxFilial("CPA") + PADR(cOrgao,TamSX3('CPA_CODORG')[1])))
				oWsdl:SetValue( aSimple[nPos][1], CVALTOCHAR(cOrgao) )
			ElseIf SA2->(DbSeek(FWxFilial("SA2") + PADR(cOrgao,TamSX3('A2_COD')[1]) + oCabecDH:GetValue( "FV0_LOJA" ) ) )
				oWsdl:SetValue( aSimple[nPos][1], SA2->A2_CGC )	
			EndIf
		EndIf
	EndIf
	
	//Informa��es do DH para realizar a consulta
	cParent += ".documentoHabil#1""
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "ugEmitente" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oCabecDH:GetValue( "FV0_UGEMIT" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "ano" .AND. aVet[5] == cParent } ) ) > 0
		cAnoDH := cValToChar( Year( oCabecDH:GetValue( "FV0_DTEMIS" ) ) )
		oWsdl:SetValue( aSimple[nPos][1], cAnoDH )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numero" .AND. aVet[5] == cParent } ) ) > 0
		cCodSIAFI := CVALTOCHAR(VAL(SUBSTR(oCabecDH:GetValue( "FV0_CODSIA" ),7)))
		oWsdl:SetValue( aSimple[nPos][1], cCodSIAFI  )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "tipo" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], AllTrim(oCabecDH:GetValue( "FV0_TIPODC" )) )
	Endif
	
	RestArea(aArea)
	RestArea(aCPAArea)
	RestArea(aSA2Area)
Return Nil

/*/{Protheus.doc} GetSimples
Fun��o para pegar um valor simples contido entre uma
tag inicial e uma tag final

@param cXmlRet, XML de resposta do WebService
@param cTagIni, Tag inicial para pegar o valor
@param cTagFim, Tag final para pegar o valor
@return cRet, Valor contido entre a tag inicial e a tag final

@author Pedro Alencar	
@since 23/02/2015	
@version P12.1.4
/*/
Function GetSimples( cXmlRet, cTagIni, cTagFim )
	Local cRet := ""
	Local nAtIni := 0
	Local nAtFim := 0
	Local nTamTag := 0
	
	//Localiza��o das tags na string do XML
	nAtIni := At( cTagIni, cXmlRet )
	nAtFim := At( cTagFim, cXmlRet )
	
	//Pega o valor entre a tag inicial e final
	If nAtIni > 0 .AND. nAtFim > 0 
		nTamTag := Len( cTagIni )
		cRet := SubStr( cXmlRet, nAtIni + nTamTag, nAtFim - nAtIni - nTamTag )
	Endif
Return cRet

/*/{Protheus.doc} GetMGS
Fun��o para pegar a lista de mensagens de erro de neg�cio
retornadas pelo WS

@param cXmlRet, XML de resposta do WebService
@return cRet, Strings de erros retornados, separados por CRLF

@author Pedro Alencar	
@since 23/02/2015	
@version P12.1.4
/*/
Function GetMGS( cXmlRet )
	Local cRet := ""
	Local cTagIni := "<mensagem>"
	Local cTagFim := "</mensagem>"
	Local nAtIni := 0
	Local nAtFim := 0
	Local nTamTag := 0
	Local cErros := ""
	Local aErros := {}
	Local nX := 0
	
	//Range de tags de erro na string do XML
	nAtIni := At( cTagIni, cXmlRet )
	nAtFim := rAt( cTagFim, cXmlRet )
	
	//Se houver as tags de erro, ent�o pega o range e quebra em um vetor
	If nAtIni > 0 .AND. nAtFim > 0
		nTamTag := Len( cTagIni )
		cErros := SubStr( cXmlRet, nAtIni + nTamTag, nAtFim - nAtIni - nTamTag )
		cErros := StrTran( cErros, "<txtMsg>", "||||" )
	
		aErros := StrToKarr( cErros, "||||" )
		If Len( aErros ) > 0
			//Adiciona todos os erros na string que ser� gravada no log de Transa��es
			For nX := 1 To Len( aErros ) 
				nAtFim := At( "</txtMsg>", aErros[nX] )
				If nAtFim > 0
					cRet += CRLF + Left( aErros[nX], At( "</txtMsg>", aErros[nX] ) - 1 )
				Endif
			Next nX
		Endif
	Endif
	
Return cRet

/*/{Protheus.doc} GetCOMP
Fun��o para pegar a lista de compromissos retornadas pela consulta
no WS do SIAFI

@param cXmlRet, XML de resposta do WebService
@return aRet, Vetor com os compromissos

@author Pedro Alencar	
@since 23/02/2015	
@version P12.1.4
/*/
Static Function GetCOMP( cXmlRet )
	Local aRet := {}
	Local cTagIni := "<listaCompromissos>"
	Local cTagFim := "</listaCompromissos>"
	Local nAtIni := 0
	Local nAtFim := 0
	Local nTamTag := 0
	Local cComp := ""
	Local aComp := {}
	Local nX := 0
	Local nQtdeCom := 0
	Local cCodCom := ""
	Local aItensCom := {}
	
	//Range de tags de lista de compromissos na string do XML
	nAtIni := At( cTagIni, cXmlRet )
	nAtFim := rAt( cTagFim, cXmlRet )
	
	//Se houver as tags de compromissos, ent�o pega o range e quebra em um vetor
	If nAtIni > 0 .AND. nAtFim > 0
		nTamTag := Len( cTagIni )
		cComp := SubStr( cXmlRet, nAtIni + nTamTag, nAtFim - nAtIni - nTamTag )
		cComp := StrTran( cComp, cTagIni, "||||" )
	
		aComp := StrToKarr( cComp, "||||" )
		nQtdeCom := Len( aComp )
		
		If nQtdeCom > 0
			//Adiciona todos os compromissos no vetor que ser� utilizado para fazer a realiza��o
			For nX := 1 To nQtdeCom
				//Pega o c�digo do compromisso
				cCodCom := GetSimples( aComp[nX], "<codigoCompromisso>", "</codigoCompromisso>" )
				
				//Pega todos os compromissos retornados no XML de resposta da consulta no WS
				aItensCom := aClone( GetItCOMP( aComp[nX] ) )
				
				aAdd(aRet, { cCodCom, aItensCom } )
				Aadd(aRet[1],GetSimples( aComp[nX], "<tipoDocumentoRealizacao>", "</tipoDocumentoRealizacao>" ))
				Aadd(aRet[1],GetSimples( aComp[nX], "<tipoCompromisso>", "</tipoCompromisso>" ))
				
			Next nX
		Endif
	Endif
	
Return aRet

/*/{Protheus.doc} GetItCOMP
Fun��o para pegar a lista de itens de compromissos retornadas pela consulta
no WS do SIAFI

@param cXmlCom, XML do compromisso retornado
@return aRet, Vetor com os itens do compromisso

@author Pedro Alencar	
@since 23/02/2015	
@version P12.1.4
/*/
Static Function GetItCOMP( cXmlCom )
	Local aRet := {}
	Local cTagIni := "<itensCompromisso>"
	Local cTagFim := "</itensCompromisso>"
	Local nAtIni := 0
	Local nAtFim := 0
	Local nTamTag := 0	
	Local cItComp := ""
	Local aItComp := {}
	Local nX := 0
	Local nQtdeItCom := 0
	
	//Range de tags de lista de itens de compromissos na string do XML
	nAtIni := At( cTagIni, cXmlCom )
	nAtFim := rAt( cTagFim, cXmlCom )
	
	//Se houver as tags de itens de compromissos, ent�o pega o range e quebra em um vetor
	If nAtIni > 0 .AND. nAtFim > 0
		nTamTag := Len( cTagIni )
		cItComp := SubStr( cXmlCom, nAtIni + nTamTag, nAtFim - nAtIni - nTamTag )
		cItComp := StrTran( cItComp, cTagIni, "||||" )
	
		aItComp := StrToKarr( cItComp, "||||" )
		nQtdeItCom := Len( aItComp )
		
		If nQtdeItCom > 0
			//aAdd(aRet, {})
			//Adiciona todos os itens de compromissos no vetor que ser� retornado
			For nX := 1 To nQtdeItCom 
				//Pega o c�digo do item do compromisso
				Aadd(aRet,GetSimples( aItComp[nX], "<codigoItemCompromisso>", "</codigoItemCompromisso>" ))			
				Aadd(aRet,GetSimples( aItComp[nX], "<valorRealizavel>", "</valorRealizavel>" ))
			Next nX
		Endif
	Endif
	
Return aRet

/*/{Protheus.doc} MontaReal
Fun��o para montagem da estrutura do XML de realiza��o do DH 

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param cUser, Usu�rio para autentica��o no SIAFI
@param cPass, Senha para autentica��o no SIAFI
@param aComp, Vetor com a lista de Compromissos para Realiza��o

@author Pedro Alencar	
@since 25/02/2015	
@version P12.1.4
/*/
Static Function MontaReal( oWsdl, cUser, cPass, aComp, aVinc )
	Local oModelDH
	Local oCabecDH
	Local aSimple := {}
	Local nX := 0
	Local nI
	
	Local nQtdCOM := 0
	Local aQtdItCOM := {}
	Local nQtdVinc := 0
	Local aQtdItVinc := {}
	
	//Ativa o Model principal da rotina
	oModelDH := FWLoadModel( "FINA761" )
	oModelDH:SetOperation( MODEL_OPERATION_VIEW ) //Visualiza��o
	oModelDH:Activate()
	
	//Model do Cabe�alho do DH
	oCabecDH := oModelDH:GetModel( "CABDI" )
	
	//Define a quantidade de ocorr�ncias de Compromisso
	nQtdCOM := Len( aComp[2] )
	aSize( aQtdItCOM, nQtdCOM )
	//Define a quantidade de itens por ocorr�ncia de Compromisso
	For nX := 1 To nQtdCOM
		aQtdItCOM[nX]	:= Len( aComp[2] )
		nQtdVinc 	+= Len(aComp[3])
		Aadd(aQtdItVinc,nQtdVinc)
	Next nX
	
	//#DEL tratar a quantidade de complexos do tipo Vincula��o
	//Define as ocorr�ncias dos tipos complexos
	DefComplex( @oWsdl, DH_TRANS_REALIZACAO,/*nQtdDocOri*/,/*nQtdPCO*/,/*aQtdItPCO*/,/*nQtdPSO*/,/*aQtdItPSO*/,/*nQtdOUT*/,/*nQtdDED*/,/*aQtdRcDED*/,/*aQtdAcDED*/,/*aQtdPdDED*/,/*nQtdENC*/,/*aQtdRcENC*/,/*aQtdAcENC*/,/*aQtdPdENC*/,/*nQtdDSP*/	,/*aQtdItDSP*/,nQtdCOM,aQtdItCOM,aQtdItVinc,/*nQtdRcPGT*/,/*aQtdPdPGT*/)

	//Pega os elementos simples, ap�s defini��o das ocorr�ncias dos tipos complexos
	aSimple := oWsdl:SimpleInput()
	
	//Monta o cabe�alho da mensagem
	DefCabec( @oWsdl, aSimple, cUser, cPass, oCabecDH:GetValue( "FV0_UGEMIT" ) )
	
	//Monta os dados da consulta do DH para pegar os compromissos pra realizar
	DefReal( @oWsdl, aSimple, oCabecDH, nQtdCOM, aQtdItCOM, aComp, nQtdVinc, aQtdItVinc, aVinc )
	
	//Limpa os objetos MVC da mem�ria
	oModelDH:Deactivate()
	oModelDH:Destroy()
	oModelDH := Nil
	oCabecDH := Nil
Return Nil

/*/{Protheus.doc} DefReal
Fun��o que define no XML os dados da Realiza��o do DH

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param oCabecDH, Model de cabe�alho do cadastro do DH
@param nQtdCOM, Quantidade de ocorr�ncias de compromissos
@param aQtdItCOM, Quantidade de itens por ocorr�ncia de compromisso
@param aComp, Vetor com a lista de Compromissos para Realiza��o

@author Pedro Alencar	
@since 23/02/2015	
@version P12.1.4
/*/
Static Function DefReal( oWsdl, aSimple, oCabecDH, nQtdCOM, aQtdItCOM, aComp, nQtdVinc, aQtdItVinc, aVinc )
	Local nPos := 0
	Local cParent := ""
	Local nX := 0
	Local nI := 0
	Local nZ	:= 0
	
	//Compromissos	
	For nX := 1 To nQtdCOM
		cParent := "cprCPRealizarTotalCompromissos#1.compromissosARealizar#1.listaCompromissos#" + cValToChar( nX )
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codigoCompromisso" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], aComp[2][nX] )
		Endif
	
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "novaDataDataEmissao" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], Transform(DTOS(aComp[1]),"@R 9999-99-99") ) //#DEL pegar esse valor da tela de realiza��o
		Endif
	
		//Itens do Compromisso
		For nI := 1 To aQtdItCOM[nX]
			cParent := "cprCPRealizarTotalCompromissos#1.compromissosARealizar#1.listaCompromissos#" + cValToChar( nX ) + ".itensCompromisso#" + cValToChar( nI )
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codigoItemCompromisso" .AND. aVet[5] == cParent } ) ) > 0
				oWsdl:SetValue( aSimple[nPos][1], aComp[4][nX])
			Endif
			
			If aQtdItVinc[nX] > 0
				For nZ := 1 To aQtdItVinc[nX]
					cParent := "cprCPRealizarTotalCompromissos#1.compromissosARealizar#1.listaCompromissos#" + cValToChar( nX ) + ".itensCompromisso#" + cValToChar( nI ) + ".vinculacoes#" + cValToChar( nZ )
					
					If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codigoVinculacao" .AND. aVet[5] == cParent } ) ) > 0
						oWsdl:SetValue( aSimple[nPos][1], CVALTOCHAR(aComp[3][nX][nZ][1]) )
					Endif
					
					If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "valor" .AND. aVet[5] == cParent } ) ) > 0
						oWsdl:SetValue( aSimple[nPos][1], CVALTOCHAR(aComp[3][nX][nZ][2]) )
					Endif
				Next nZ
			EndIf	
			//#DEL Definir aqui os valores das vincula��es
		Next nI
	Next nX
	
Return Nil

/*/{Protheus.doc} GetCompMGS
Fun��o para pegar a lista de mensagens de erro de neg�cio
retornadas pelo WS para a opera��o de Realiza��o ou Estorno

@param cXmlRet, XML de resposta do WebService
@return cRet, Strings de erros retornados, separados por CRLF

@author Pedro Alencar	
@since 23/02/2015	
@version P12.1.4
/*/
Static Function GetCompMGS( cXmlRet )
	Local cRet := ""
	Local cTagIni := "<resultadoExecucao>"
	Local cTagFim := "</resultadoExecucao>"
	Local nAtIni := 0
	Local nAtFim := 0
	Local nTamTag := 0
	Local cResults := ""
	Local aResults := {}
	Local nX := 0
	Local cComp := ""
	Local cProcRet := ""
	Local cErro := ""
	
	//Range de tags de erro na string do XML
	nAtIni := At( cTagIni, cXmlRet )
	nAtFim := rAt( cTagFim, cXmlRet )
	
	//Se houver as tags de erro, ent�o pega o range e quebra em um vetor
	If nAtIni > 0 .AND. nAtFim > 0
		nTamTag := Len( cTagIni )
		cResults := SubStr( cXmlRet, nAtIni + nTamTag, nAtFim - nAtIni - nTamTag )
		cResults := StrTran( cResults, cTagIni, "||||" )
	
		aResults := StrToKarr( cResults, "||||" )
		If Len( aResults ) > 0
			//Adiciona todos os erros na string que ser� gravada no log de Transa��es
			For nX := 1 To Len( aResults ) 
				cComp := GetSimples( aResults[nX], "<codigoCompromisso>", "</codigoCompromisso>" )
				cProcRet := GetSimples( aResults[nX], "<tipoProcessamento>", "</tipoProcessamento>" )
				cErro := GetMGS( aResults[nX] )
				
				cRet += CRLF + STR0211 + cComp + STR0212 + cProcRet //"Compromisso: "//" Resultado do Processamento: "
				cRet += CRLF + STR0213 + cErro + CRLF //"Mensagens: "
			Next nX
		Endif
	Endif
	
Return cRet

/*/{Protheus.doc} ExibeCOM
Fun��o para exibir uma nova tela com os compromissos consultados
para informar as vincula��es de pagamento e realizar o DH

@param aComp, Vetor com a lista de Compromissos para Realiza��o
@return lRet, Informa se a tela foi confirmada e validada ou se foi cancelada

@author Pedro Alencar	
@since 23/02/2015	
@version P12.1.4
/*/
Static __aDadosVin := {}
Static Function ExibeCOM( aComp )
	Local lRet 		:= .F.
	Local oModel		:= ModelComp(aComp)
	Local oView		:= ViewComp(oModel)
	Local oExecView
	Local nOpc		:= 0
	
	DEFAULT aComp		:= {}
	
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oView:setAfterOkButton({|oV| DefVinc(oV)})
	
	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0214) //"Compromissos"
	oExecView:setView(oView)
	oExecView:setModel(oModel)
	oExecView:setModal(.T.)
	oExecView:SetOperation(oModel:GetOperation())
	oExecView:SetCloseOnOk({|| .t.})
	oExecView:openView()

	If (nOpc := oExecView:getButtonPress()) == VIEW_BUTTON_OK
		lRet := .T.
	Endif
	
Return {lRet,__aDadosVin}

/*/{Protheus.doc} DefVinc
Armazenamento das informa��es digitadas da realiza��o do documento h�bil em mem�ria para atribui��o ao WebService.

@param oView View onde foram digitadas as informa��es da realiza��o do documento h�bil.

@author Marylly Ara�jo Silva
@since 06/03/2015	
@version P12.1.4
/*/
Function DefVinc(oView)
Local oModel	:= oView:GetModel()
Local nX		:= 0
Local nPos	:= 0

Aadd(__aDadosVin,oModel:GetModel("CABEC"):GetValue("DATA"))
Aadd(__aDadosVin,{})
Aadd(__aDadosVin,{})
Aadd(__aDadosVin,{})

For nX := 1 To oModel:GetModel("COMPROMISS"):Length()
	nPos == aScan(__aDadosVin[2],{|x| x == oModel:GetModel("COMPROMISS"):GetValue("COMP",nX)})
	If nPos == 0 
		Aadd(__aDadosVin[2],oModel:GetModel("COMPROMISS"):GetValue("COMP",nX))
		Aadd(__aDadosVin[3],{{;
					oModel:GetModel("COMPROMISS"):GetValue("VINCULA",nX),;
					oModel:GetModel("COMPROMISS"):GetValue("VALOR",nX);
					}})
		Aadd(__aDadosVin[4],oModel:GetModel("COMPROMISS"):GetValue("ITCOMP",nX))
	Else
		Aadd(__aDadosVin[3][nPos],{;
					oModel:GetModel("COMPROMISS"):GetValue("VINCULA",nX),;
					oModel:GetModel("COMPROMISS"):GetValue("VALOR",nX);
					})
	EndIf
Next nX

Return

/*/{Protheus.doc} ModelComp
Modelo de dados da tela de preenchimento das vincula��es de pagamento da realiza��o do documento h�bil.

@param aComp Lista de compromissos que foi retornada do WebService para realiza��o do documento h�bil.
@return oModel Objeto do tipo FWFormModel para constitui��o dos campos necess�rios da tela de realiza��o do documento h�bil.

@author Marylly Ara�jo Silva
@since 06/03/2015	
@version P12.1.4
/*/
Static Function ModelComp(aComp)

Local oModel		:= FWFormModel():New('MODELCOMP',/*bPre*/,/*bPos*/,{|| .T.}/*bCommit*/,{|| .T. }/*bCancel*/)
Local oStruCab	:= FWFormModelStruct():New()
Local oStruComp	:= EstrComp()

oStruCab:AddField(			  ;
"DATA"						, ;	// [01] Titulo do campo
"DATA"						, ;	// [02] ToolTip do campo
"DATA"						, ;	// [03] Id do Field
"D"							, ;	// [04] Tipo do campo
8							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de valida��o do campo
{ || .T. }					, ;	// [08] Code-block de valida��o When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
							)	// [11] Inicializador Padr�o do campo 
							
oModel:SetDescription(STR0215) //"Rotina de Manuten��o de Compromissos de Pagamento."
oModel:AddFields("CABEC",/*cOwner*/,oStruCab ,/*bPre*/,/*bPost*/,/*bLoad*/ {|| })
oModel:GetModel("CABEC"):SetDescription("Teste comp")
oModel:AddGrid("COMPROMISS","CABEC",oStruComp,/* bLinePre */ , /* bLinePost */, /* bPre */,/* bLinePost */, {|| LoadComp(aComp) }/* bLoad */)
oModel:GetModel("COMPROMISS"):SetDescription("Teste comp")
oModel:SetprimaryKey({})
Return oModel

Static Function EstrComp()
Local oStruComp	:= FWFormModelStruct():New()

oStruComp:AddField(			  ;
STR0216						, ;	// [01] Titulo do campo	//"Compromisso"
STR0216						, ;	// [02] ToolTip do campo 	//"Compromisso"
"COMP"						, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
12							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de valida��o do campo
{ || .F. }					, ;	// [08] Code-block de valida��o When do campo
							, ;	// [09] Lista de valores permitido do campo
.F.							, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
							)	// [11] Inicializador Padr�o do campo
oStruComp:AddField(			  ;
STR0217			 			, ;	// [01] Titulo do campo	//"Vincula��o"
STR0217						, ;	// [02] ToolTip do campo	//"Vincula��o"
"VINCULA"					, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
3							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de valida��o do campo
{ || .T. }					, ;	// [08] Code-block de valida��o When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
							)	// [11] Inicializador Padr�o do campo

oStruComp:AddField(			  ;
"Tipo Documento"	 			, ;	// [01] Titulo do campo	//"Tipo Documento"
"Tipo Documento"				, ;	// [02] ToolTip do campo	//"Tipo Documento"
"TIPODOC"					, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
5							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de valida��o do campo
{ || .F. }					, ;	// [08] Code-block de valida��o When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
							)	// [11] Inicializador Padr�o do campo
							
oStruComp:AddField(			  ;
STR0217			 			, ;	// [01] Titulo do campo	//"Vincula��o"
STR0217						, ;	// [02] ToolTip do campo	//"Vincula��o"
"TIPOCOMP"					, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
20							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de valida��o do campo
{ || .F. }					, ;	// [08] Code-block de valida��o When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
							)	// [11] Inicializador Padr�o do campo								
oStruComp:AddField(			  ;
STR0218			 			, ;	// [01] Titulo do campo	//"Valor"
STR0218						, ;	// [02] ToolTip do campo	//"Valor"
"VALOR"						, ;	// [03] Id do Field
"N"							, ;	// [04] Tipo do campo
12							, ;	// [05] Tamanho do campo
2							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de valida��o do campo
{ || .F. }					, ;	// [08] Code-block de valida��o When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
							)	// [11] Inicializador Padr�o do campo


oStruComp:AddField(			  ;
"Item Compromisso"			, ;	// [01] Titulo do campo	//"Item Compromisso"
"Item Compromisso"			, ;	// [02] ToolTip do campo 	//"Item Compromisso"
"ITCOMP"						, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
4							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de valida��o do campo
{ || .F. }					, ;	// [08] Code-block de valida��o When do campo
							, ;	// [09] Lista de valores permitido do campo
.F.							, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
							)	// [11] Inicializador Padr�o do campo

Return oStruComp

/*/{Protheus.doc} LoadComp
Load dos compromissos de pagamento do documento h�bil no modelo de dados da tela de preenchimento das 
vincula��es de pagamento da realiza��o do documento h�bil.

@param aComp Lista de compromissos que foi retornada do WebService para realiza��o do documento h�bil.
@return aRetGrid Array com os dados que ser�o exibidos no grid de vincula��es dos compromissos de pagamento.

@author Marylly Ara�jo Silva
@since 06/03/2015	
@version P12.1.4
/*/
Static Function LoadComp(aComp)
Local aRetGrid	:= {}
Local nComp		:= 0

For nComp := 1 To Len(aComp)
	Aadd(aRetGrid,{0, {aComp[nComp][1],"   ",aComp[nComp][3],aComp[nComp][4],Val(aComp[nComp][2][2]),aComp[nComp][2][1],FV0->FV0_CODIGO,.F.}})
Next nComp

Return aRetGrid
Static Function VEstrComp()

Local oStruComp	:= FWFormViewStruct():New()

oStruComp:AddField(			;
"COMP"						, ;	// [01] Id do Field
"01"							, ;	// [02] Ordem
STR0216						, ;	// [03] Titulo do campo	//"Compromisso"
STR0216						, ;	// [04] ToolTip do campo	//"Compromisso"
							, ;	// [05] Help
"G"							, ;	// [06] Tipo do campo
"@!"							, ;	// [07] Picture
							, ;	// [08] PictVar
							)	// [09] F3

oStruComp:AddField(	 		;
"VINCULA"					, ;	// [01] Id do Field
"02"							, ;	// [02] Ordem
STR0217						, ;	// [03] Titulo do campo	//"Vincula��o"
STR0217						, ;	// [04] ToolTip do campo	//"Vincula��o"
							, ;	// [05] Help
"G"							, ;	// [06] Tipo do campo
"@!"							, ;	// [07] Picture
							, ;	// [08] PictVar
''	            				)	// [09] F3

oStruComp:AddField(	 		;
"TIPODOC"					, ;	// [01] Id do Field
"03"							, ;	// [02] Ordem
"Tipo Documento"				, ;	// [03] Titulo do campo	//"Tipo Documento"
"Tipo Documento"				, ;	// [04] ToolTip do campo	//"Tipo Documento"
							, ;	// [05] Help
"G"							, ;	// [06] Tipo do campo
"@!"							, ;	// [07] Picture
							, ;	// [08] PictVar
''	            				)	// [09] F3

oStruComp:AddField(	 		;
"TIPOCOMP"					, ;	// [01] Id do Field
"04"							, ;	// [02] Ordem
"Tipo Compromisso"			, ;	// [03] Titulo do campo	//"Tipo Compromisso"
"Tipo Compromisso"			, ;	// [04] ToolTip do campo	//"Tipo Compromisso"
							, ;	// [05] Help
"G"							, ;	// [06] Tipo do campo
"@!"							, ;	// [07] Picture
							, ;	// [08] PictVar
''	            				)	// [09] F3

oStruComp:AddField(	 		;
"VALOR"						, ;	// [01] Id do Field
"05"							, ;	// [02] Ordem
STR0218						, ;	// [03] Titulo do campo	//"Valor"
STR0218						, ;	// [04] ToolTip do campo	//"Valor"
							, ;	// [05] Help
"G"							, ;	// [06] Tipo do campo
"@E 99,999,999.999.99"			, ;	// [07] Picture
							, ;	// [08] PictVar
''	            				)	// [09] F3

Return oStruComp

/*/{Protheus.doc} ViewComp
View da tela de preenchimento das vincula��es de pagamento da realiza��o do documento h�bil.

@param oModel Objeto do tipo FWFormModel para constitui��o dos campos necess�rios da tela de realiza��o do documento h�bil.
@return oView View onde foram digitadas as informa��es da realiza��o do documento h�bil.

@author Marylly Ara�jo Silva
@since 06/03/2015	
@version P12.1.4
/*/
Static Function ViewComp(oModel)

/*
 * Cria a estrutura de dados que ser� utilizada na View
 */
Local oStruCab	:= FWFormViewStruct():New()
Local oStruComp	:= VEstrComp()()
Local oView		:= FWFormView():New()

oStruCab:AddField(			;
"DATA"						, ;	// [01] Id do Field
"01"							, ;	// [02] Ordem
STR0219						, ;	// [03] Titulo do campo	//"Nova Data Emiss�o"
STR0219						, ;	// [04] ToolTip do campo	//"Nova Data Emiss�o"
							, ;	// [05] Help
"G"							, ;	// [06] Tipo do campo
""							, ;	// [07] Picture
							, ;	// [08] PictVar
							)	// [09] F3
					

oView:SetModel(oModel)
oView:AddField("VCABEC",oStruCab,"CABEC")
oView:AddGrid("VCOMP",oStruComp,"COMPROMISS")

oView:CreateHorizontalBox( 'CABEC'	,30)
oView:CreateHorizontalBox( 'GRID'	,70)
oView:SetOwnerView("VCABEC"	,'CABEC')
oView:SetOwnerView("VCOMP"		,'GRID')

Return oView

/*/{Protheus.doc} EstornaDH
Fun��o para envio do Estorno do DH ao WS

@param cCA, Caminho do Certificado de Autoriza��o do SIAFI
@param cCERT, Caminho do Certificado de Cliente do SIAFI
@param cKEY,  Caminho da Chave Privada do Certificado do SIAFI
@param cWsdlURL, URL do WSDL do servi�o ManterContasPagarReceber do SIAFI
@param cUser, Usu�rio para autentica��o no SIAFI
@param cPass, Senha para autentica��o no SIAFI
 
@author Pedro Alencar	
@since 26/02/2015
@version P12.1.4
/*/
Static Function EstornaDH( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass )
	Local lRet := .F.
	Local oWsdl := TWsdlManager():New()
	Local cXmlRet := ""
	Local cIdCV8 := ""
	Local aComp := {}
	Local lConfirm := .F. 
	
	//Pega a lista de compromissos para estorno no SIAFI, referentes ao DH em quest�o
	aComp := aClone( ConsComp( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass, .T. ) )
	oWsdl:bNoCheckPeerCert := .T. // Desabilita o check de CAs														   
	
	//Se retornou algum compromisso, ent�o estorna o DH
	If Len( aComp ) > 0
		//#DEL CHAMAR UMA TELA E LISTAR OS COMPROMISSO PRA DIGITAR A NOVA DATA DE EMISS�O E OBSERVA��O
		lConfirm := ExibeCOM( aComp )
		
		If lConfirm
			//Define as propriedades para tratar os prefixos NS das tags do XML e para remover as tags vazias, pois o WS do SIAFI n�o aceita as mesmas
			oWsdl:lUseNSPrefix := .T.
			oWsdl:lRemEmptyTags := .T.
			
			//Informa os arquivos da quebra do certificado digital
			oWsdl:cSSLCACertFile := cCA
			oWsdl:cSSLCertFile := cCERT
			oWsdl:cSSLKeyFile := cKEY
			
			//"Parseia" o WSDL do SIAFI, para manipular o mesmo atrav�s do objeto da classe TWsdlManager  
			lRet := oWsdl:ParseURL( cWsdlURL ) //#DEL tentar n�o usar o Parse 2 vezes pro mesmos processo (ta sendo chamado na consulta e na realiza��o) - Melhorar por conta de perfomance
			If lRet
				//Define a opera��o com a qual ser� trabalhada no Documento H�bil em quest�o
				lRet := oWsdl:SetOperation( "cprCPEstornarCompromisso" )
				If lRet
					//Monta o XML de comunica��o com o WS do SIAFI
					MontaEST( @oWsdl, cUser, cPass, aComp )
		
					//Se houver mensagem definida, envia a mensagem. Do contr�rio, mostra o erro do objeto.
					oWsdl:lVerbose := .T. //#DEL

					If !Empty( oWsdl:GetSoapMsg() )
						//Envia a mensagem SOAP ao servidor
						oWsdl:lProcResp := .F. //N�o processa o retorno automaticamente no objeto (ser� tratado atrav�s do m�todo GetSoapResponse)
						lRet := oWsdl:SendSoapMsg()
						If lRet
							//Pega a resposta para os devidos tratamentos
							cXmlRet := oWsdl:GetSoapResponse()
							If ! Empty( cXmlRet )
								TrataRet( cXmlRet, cUser, DH_TRANS_ESTORNO )
							Else
								ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
								ProcLogAtu( "MENSAGEM", STR0199, "N�o foi poss�vel tratar a resposta do WebService. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI." + CRLF + "Usu�rio SIAFI: " + Transform(cUser,"@R 999.999.999-99"), , .T. ) //'Estorno do Documento H�bil: '
				
								Help( "", 1, "WSDLXMLEST1", , "N�o foi poss�vel tratar a resposta do WebService. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI.", 1, 0 ) //#DEL STR		
							Endif
						Else
							Help( "", 1, "WSDLXMLEST2", , "Ocorreu um problema ao enviar a requisi��o para o SIAFI: " + CRLF + oWsdl:cError, 1, 0 ) //#DEL STR
						Endif
					Else
						Help( "", 1, "WSDLXMLEST3", , "H� um problema com os dados do Documento H�bil: " + CRLF + oWsdl:cError, 1, 0 ) //#DEL STR
					Endif
					
				Else //Se n�o conseguiu definir a opera��o
					Help( "", 1, "WSDLXMLEST4", , "Houve um problema ao definir a opera��o para envio ao SIAFI: " + CRLF + oWsdl:cError, 1, 0 ) //#DEL STR
				Endif
			Else //Se n�o conseguiu acessar o endere�o do WSDL corretamente 
				Help( "", 1, "WSDLXMLEST5", , "Houve um problema ao acessar o WSDL do servi�o do SIAFI: " + CRLF + oWsdl:cError, 1, 0 ) //#DEL STR
			Endif 	
		Endif
	Endif
	
	oWsdl := Nil 
Return Nil

/*/{Protheus.doc} MontaEST
Fun��o para montagem da estrutura do XML de estorno do DH 

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param cUser, Usu�rio para autentica��o no SIAFI
@param cPass, Senha para autentica��o no SIAFI
@param aComp, Vetor com a lista de Compromissos para Estorno

@author Pedro Alencar	
@since 26/02/2015	
@version P12.1.4
/*/
Static Function MontaEST( oWsdl, cUser, cPass, aComp )
	Local oModelDH
	Local oCabecDH
	Local aSimple := {}
	Local nX := 0
	Local nQtdCOM := 0
	Local aQtdItCOM := {}
	
	//Ativa o Model principal da rotina
	oModelDH := FWLoadModel( "FINA761" )
	oModelDH:SetOperation( MODEL_OPERATION_VIEW ) //Visualiza��o
	oModelDH:Activate()
	
	//Model do Cabe�alho do DH
	oCabecDH := oModelDH:GetModel( "CABDI" )
	
	//Define a quantidade de ocorr�ncias de Compromisso
	nQtdCOM := Len( aComp )
	aSize( aQtdItCOM, nQtdCOM )
	//Define a quantidade de itens por ocorr�ncia de Compromisso
	For nX := 1 To nQtdCOM
		aQtdItCOM[nX] := Len( aComp[nX][2] )
	Next nX
	
	//Define as ocorr�ncias dos tipos complexos
	DefComplex( @oWsdl, DH_TRANS_ESTORNO, , , , , , , , , , , , , , , , , nQtdCOM, aQtdItCOM )
	
	//Pega os elementos simples, ap�s defini��o das ocorr�ncias dos tipos complexos
	aSimple := oWsdl:SimpleInput()
	
	//Monta o cabe�alho da mensagem
	DefCabec( @oWsdl, aSimple, cUser, cPass, oCabecDH:GetValue( "FV0_UGEMIT" ) )
	
	//Monta os dados da consulta do DH para pegar os compromissos pra realizar
	DefEST( @oWsdl, aSimple, oCabecDH, nQtdCOM, aQtdItCOM, aComp )
	
	//Limpa os objetos MVC da mem�ria
	oModelDH:Deactivate()
	oModelDH:Destroy()
	oModelDH := Nil
	oCabecDH := Nil
Return Nil

/*/{Protheus.doc} DefEST
Fun��o que define no XML os dados do Estorno do DH

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param oCabecDH, Model de cabe�alho do cadastro do DH
@param nQtdCOM, Quantidade de ocorr�ncias de compromissos
@param aQtdItCOM, Quantidade de itens por ocorr�ncia de compromisso
@param aComp, Vetor com a lista de Compromissos para Estorno

@author Pedro Alencar	
@since 23/02/2015	
@version P12.1.4
/*/
Static Function DefEST( oWsdl, aSimple, oCabecDH, nQtdCOM, aQtdItCOM, aComp )
	Local nPos := 0
	Local cParent := ""
	Local nX := 0
	
	//Compromissos
	For nX := 1 To nQtdCOM
		cParent := "cprCPEstornarCompromisso#1.compromissosAEstornar#1.listaCompromissos#" + cValToChar( nX )
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codigoCompromisso" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], aComp[nX][1] )
		Endif
	
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "novaDataEmissao" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], "2015-02-26" ) //#DEL Pegar valor da tela de Estorno
		Endif

		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "observacao" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], "Estorno Teste" ) //#DEL Pegar valor da tela de Estorno
		Endif
	Next nX
	
Return N

Static Function EstrDocum()
Local oStruDoc	:= FWFormModelStruct():New()

oStruDoc:AddField(			  ;
STR0220						, ;	// [01] Titulo do campo	//"C�digo DH"
STR0220						, ;	// [02] ToolTip do campo 	//"C�digo DH"
"CODIGO"						, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
6							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de valida��o do campo
{ || .F. }					, ;	// [08] Code-block de valida��o When do campo
							, ;	// [09] Lista de valores permitido do campo
.F.							, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
							)	// [11] Inicializador Padr�o do campo

oStruDoc:AddField(			  ;
STR0221		 				, ;	// [01] Titulo do campo	//"C�digo SIAFI"
STR0221						, ;	// [02] ToolTip do campo	//"C�digo SIAFI"
"CODSIA"						, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
12							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de valida��o do campo
{ || .T. }					, ;	// [08] Code-block de valida��o When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ; // [10] Indica se o campo tem preenchimento obrigat�rio
								)// [11] Inicializador Padr�o do campo
								
oStruDoc:AddField(			  ;
STR0218			 			, ;	// [01] Titulo do campo	//"Valor"
STR0218						, ;	// [02] ToolTip do campo	//"Valor"
"VALOR"						, ;	// [03] Id do Field
"N"							, ;	// [04] Tipo do campo
12							, ;	// [05] Tamanho do campo
2							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de valida��o do campo
{ || .T. }					, ;	// [08] Code-block de valida��o When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
							)	// [11] Inicializador Padr�o do campo

Return oStruDoc

/*/{Protheus.doc} MdlRealLot
Modelo de dados da tela de preenchimento das vincula��es de pagamento da realiza��o do documento h�bil.

@param aComp Lista de compromissos que foi retornada do WebService para realiza��o do documento h�bil.
@return oModel Objeto do tipo FWFormModel para constitui��o dos campos necess�rios da tela de realiza��o do documento h�bil.

@author Marylly Ara�jo Silva
@since 06/03/2015	
@version P12.1.4
/*/
Static Function MdlRealLot(cArqTrb, cMarca, cCA, cCERT, cKEY, cWsdlURL, cUser, cPass)

Local oModel		:= FWFormModel():New('MODELCOMP',/*bPre*/,/*bPos*/,{|| .T.}/*bCommit*/,{|| .T. }/*bCancel*/)
Local oStruCab	:= FWFormModelStruct():New()
Local oStruComp	:= EstrComp()
Local oStruDoc	:= EstrDocum()

oStruComp:AddField(			  ;
STR0220						, ;	// [01] Titulo do campo	//"C�digo DH"
STR0220						, ;	// [02] ToolTip do campo	//"C�digo DH"
"CODDH"						, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
6							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de valida��o do campo
{ || .T. }					, ;	// [08] Code-block de valida��o When do campo
							, ;	// [09] Lista de valores permitido do campo
.F.							, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
							)	// [11] Inicializador Padr�o do campo
														
oStruCab:AddField(			  ;
STR0222						, ;	// [01] Titulo do campo //"Data"
STR0222						, ;	// [02] ToolTip do campo //"Data"
"DATA"						, ;	// [03] Id do Field
"D"							, ;	// [04] Tipo do campo
8							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de valida��o do campo
{ || .T. }					, ;	// [08] Code-block de valida��o When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
							)	// [11] Inicializador Padr�o do campo 
							
oModel:SetDescription(STR0223) //"Rotina de Manuten��o de Compromissos de Pagamento em Lote."
oModel:AddFields("CABEC",/*cOwner*/,oStruCab ,/*bPre*/,/*bPost*/,/*bLoad*/ {|| })
oModel:GetModel("CABEC"):SetDescription(STR0227) //"Cabe�alho de Data de Emiss�o para a Realiza��o de Compromissos."
oModel:AddGrid("DOCUMENTO","CABEC",oStruDoc,/* bLinePre */ , /* bLinePost */, /* bPre */,/* bLinePost */, {|oModel| LoadReaLot(oModel,cArqTrb, 1, cMarca, cCA, cCERT, cKEY, cWsdlURL, cUser, cPass) }/* bLoad */)
oModel:GetModel("DOCUMENTO"):SetDescription(STR0228) //"Grid de Documentos Hab�is para Realiza��o em Lote"
oModel:AddGrid("COMPROMISS","DOCUMENTO",oStruComp,/* bLinePre */ , /* bLinePost */, /* bPre */,/* bLinePost */, {|oModel| LoadReaLot(oModel,cArqTrb,2, cMarca, cCA, cCERT, cKEY, cWsdlURL, cUser, cPass) }/* bLoad */)
oModel:GetModel("COMPROMISS"):SetDescription(STR0229) //"Grid de Compromissos dos Documentos Hab�is para Realiza��o em Lote"
oModel:GetModel("COMPROMISS"):SetNoInsertLine(.F.)
oModel:GetModel("COMPROMISS"):CanDeleteLine(.F.)
oModel:SetprimaryKey({})

Return oModel

Static Function VEstrDocum()

Local oStruDocs	:= FWFormViewStruct():New()

oStruDocs:AddField(			;
"CODIGO"						, ;	// [01] Id do Field
"01"							, ;	// [02] Ordem
STR0220						, ;	// [03] Titulo do campo	//"C�digo DH"
STR0220						, ;	// [04] ToolTip do campo	//"C�digo DH"
							, ;	// [05] Help
"G"							, ;	// [06] Tipo do campo
"@!"							, ;	// [07] Picture
							, ;	// [08] PictVar
							)	// [09] F3

oStruDocs:AddField(	 		;
"CODSIA"						, ;	// [01] Id do Field
"02"							, ;	// [02] Ordem
STR0221						, ;	// [03] Titulo do campo	//"C�digo SIAFI"
STR0221						, ;	// [04] ToolTip do campo	//"C�digo SIAFI"
							, ;	// [05] Help
"G"							, ;	// [06] Tipo do campo
"@!"							, ;	// [07] Picture
							, ;	// [08] PictVar
''	            				)	// [09] F3

oStruDocs:AddField(	 		;
"VALOR"						, ;	// [01] Id do Field
"03"							, ;	// [02] Ordem
STR0218						, ;	// [03] Titulo do campo	//"Valor"
STR0218						, ;	// [04] ToolTip do campo	//"Valor"
							, ;	// [05] Help
"G"							, ;	// [06] Tipo do campo
"@E 99,999,999.999.99"			, ;	// [07] Picture
							, ;	// [08] PictVar
''	            				)	// [09] F3

Return oStruDocs

/*/{Protheus.doc} ViewDocs
View da tela de preenchimento das vincula��es de pagamento da realiza��o do documento h�bil.

@param oModel Objeto do tipo FWFormModel para constitui��o dos campos necess�rios da tela de realiza��o do documento h�bil.
@return oView View onde foram digitadas as informa��es da realiza��o do documento h�bil.

@author Marylly Ara�jo Silva
@since 06/03/2015	
@version P12.1.4
/*/
Static Function ViewDocs(oModel)

/*
 * Cria a estrutura de dados que ser� utilizada na View
 */
Local oStruCab	:= FWFormViewStruct():New()
Local oStruComp	:= VEstrComp()
Local oStruDocs	:= VEstrDocum()
Local oView		:= FWFormView():New()

oStruCab:AddField(			;
"DATA"						, ;	// [01] Id do Field
"01"							, ;	// [02] Ordem
STR0219						, ;	// [03] Titulo do campo	//"Nova Data Emiss�o"	
STR0219						, ;	// [04] ToolTip do campo	//"Nova Data Emiss�o"
							, ;	// [05] Help
"G"							, ;	// [06] Tipo do campo
""							, ;	// [07] Picture
							, ;	// [08] PictVar
							)	// [09] F3
					

oView:SetModel(oModel)
oView:AddField("VCABEC",oStruCab,"CABEC")
oView:AddGrid("VDOCS",oStruDocs,"DOCUMENTO")
oView:AddGrid("VCOMP",oStruComp,"COMPROMISS")

oView:CreateHorizontalBox( 'CABEC'	,20)
oView:CreateHorizontalBox( 'GRID1'	,30)
oView:CreateHorizontalBox( 'GRID2'	,50)
oView:SetOwnerView("VCABEC"	,'CABEC')
oView:SetOwnerView("VDOCS"		,'GRID1')
oView:SetOwnerView("VCOMP"		,'GRID2')

Return oView

Static Function ExibeDHCOM( cArqTrb, cMarca, cCA, cCERT, cKEY, cWsdlURL, cUser, cPass )
	Local lRet 		:= .F.
	Local oModel		:= MdlRealLot(cArqTrb, cMarca, cCA, cCERT, cKEY, cWsdlURL, cUser, cPass)
	Local oView		:= ViewDocs(oModel)
	Local oExecView
	Local nOpc		:= 0
	
	DEFAULT aComp		:= {}
	
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oView:setAfterOkButton({|oV| DefLotVinc(oV)})
	
	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0223) //"Rotina de Manuten��o de Compromissos de Pagamento em Lote."
	oExecView:setView(oView)
	oExecView:setModel(oModel)
	oExecView:setModal(.T.)
	oExecView:SetOperation(oModel:GetOperation())
	oExecView:SetCloseOnOk({|| .T.})
	oExecView:openView()

	If (nOpc := oExecView:getButtonPress()) == VIEW_BUTTON_OK
		lRet := .T.
	Endif
	
Return __aDadosVin

/*/{Protheus.doc} LoadReaLot
Fun��o que carrega os dados de compromissos para a realiza��o de documento h�bil em Lote

@param cArqTrab, Nome do Arquivo de Trabalho de Sele��o de documentos hab�is para realiza��o
@param nOption, Qual Grid da tela de realiza��o de documento h�bil ser� carregada 1=Documentos Hab�is;2=Compromissos;
@param nQtdRcPGT, Quantidade de ocorr�ncias de Favorecidos na aba Dados de Pagamento
@param aQtdPdPGT, Quantidade de itens de pr�-doc por ocorr�ncia de Dados de Pagamento
@param oPGTRc, Model de Favorecidos da aba de Dados de Pagamento
@param oPreDoc, Model de Pr�-docs de Favorecidos da aba de Dados de Pagamento

@author Marylly Ara�jo Silva
@since 10/02/2015	
@version P12.1.4
/*/

Static Function LoadReaLot(oModel,cArqTrab,nOption,cMarca, cCA, cCERT, cKEY, cWsdlURL, cUser, cPass)
Local aRetDados	:= {}
Local nComp		:= 1
Local aComp		:= {}
Local aArea		:= GetArea()
Local aFV0Area	:= {}
Local cFV0Fil		:= FWxFilial("FV0")

oModel := oModel:GetModel()

DbSelectArea("FV0")
aFV0Area	:= FV0->(GetArea())
FV0->(DbSetOrder(1)) // Filial + C�digo DH

dbSelectArea(cArqTrab)
(cArqTrab)->(DbGoTop())

While !(cArqTrab)->(Eof())
	
	If (cArqTrab)->FV0_OK == cMarca
		//Pega a lista de compromissos para realiza��o no SIAFI, referentes ao DH em quest�o
		If FV0->(DbSeek(cFV0Fil + (cArqTrab)->FV0_CODIGO))
			aComp := aClone( ConsComp( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass ) )
			If Len(aComp) > 0
				For nComp := 1 To Len(aComp)
					If nOption == 1
						Aadd(aRetDados,{0, {(cArqTrab)->FV0_CODIGO,(cArqTrab)->FV0_CODSIA,(cArqTrab)->FV0_VLRDOC,.F.}})
					ElseIf nOption == 2
 						If oModel:GetModel("DOCUMENTO"):GetValue("CODIGO") == (cArqTrab)->FV0_CODIGO
							Aadd(aRetDados,{0, {aComp[nComp][1],"   ",aComp[nComp][3],aComp[nComp][4],aComp[nComp][2][2],aComp[nComp][2][1],(cArqTrab)->FV0_CODIGO,.F.}})
						EndIf
					EndIf
				Next nComp
			EndIf
		EndIf
	EndIf
	
	(cArqTrab)->(DbSkip())	
EndDo

RestArea(aArea)
RestArea(aFV0Area)

Return aRetDados

/*/{Protheus.doc} DefLotVinc
Armazenamento das informa��es digitadas da realiza��o em lote do documento h�bil em mem�ria para atribui��o ao WebService.

@param oView View onde foram digitadas as informa��es da realiza��o do documento h�bil.

@author Marylly Ara�jo Silva
@since 09/03/2015	
@version P12.1.4
/*/
Function DefLotVinc(oView)
Local oModel	:= oView:GetModel()
Local nX		:= 0
Local nI		:= 0
Local nComp	:= 1
Local nPos	:= 0

__aDadosVin := {}

For nI := 1 To oModel:GetModel("DOCUMENTO"):Length()
	Aadd(__aDadosVin,{})
	AAdd(__aDadosVin[nI],.T.)
	Aadd(__aDadosVin[nI],{})
	Aadd(__aDadosVin[nI][2],oModel:GetModel("CABEC"):GetValue("DATA"))
	Aadd(__aDadosVin[nI][2],{})
	For nX := 1 To oModel:GetModel("COMPROMISS"):Length()
		nPos := aScan(__aDadosVin[nI][2][2],{|x| x == oModel:GetModel("COMPROMISS"):GetValue("COMP",nX)})
		If nPos == 0 
			Aadd(__aDadosVin[nI][2][2],oModel:GetModel("COMPROMISS"):GetValue("COMP",nX))
			If nX == 1
				Aadd(__aDadosVin[nI][2],{})
			EndIf
			Aadd(__aDadosVin[nI][2],{})
			Aadd(__aDadosVin[nI][2][4],oModel:GetModel("COMPROMISS"):GetValue("ITCOMP",nX))
		EndIf
		Aadd(__aDadosVin[nI][2][3],{{;
					oModel:GetModel("COMPROMISS"):GetValue("VINCULA",nX),;
					oModel:GetModel("COMPROMISS"):GetValue("VALOR",nX);
					}})
	Next nX
Next nI

Return

/*/{Protheus.doc} DefDadPgto
Fun��o que define no XML os dados da se��o Dados de Pagamento

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdRcPGT, Quantidade de ocorr�ncias de Favorecidos na aba Dados de Pagamento
@param aQtdPdPGT, Quantidade de itens de pr�-doc por ocorr�ncia de Dados de Pagamento
@param oPGTRc, Model de Favorecidos da aba de Dados de Pagamento
@param oPreDoc, Model de Pr�-docs de Favorecidos da aba de Dados de Pagamento

@author Marylly Ara�jo Silva
@since 10/02/2015	
@version P12.1.4
/*/
Static Function DefDadPgto( oWsdl, aSimple, nQtdRcPGT, aQtdPdPGT, oPGTRc, oPreDoc )
	Local nPos		:= 0
	Local nX			:= 0
	Local nI			:= 0
	Local cParent		:= ""
	Local cItemPai	:= ""
	Local cSituac		:= ""
	Local cItemFilho	:= ""
	Local aArea		:= GetArea()
	Local aCPAArea	:= {}
	Local aSA2Area	:= {}
	Local cOrgao		:= ""
	Local oDH		:= oPreDoc:GetModel()
	Local oCabecDH	:= oDH:GetModel( "CABDI" )
	Local lOrgao		:= .F.
	
	DbSelectArea("CPA") // �rg�os P�blicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + C�digo �rg�o
	
	DbSelectArea("SA2")
	aSA2Area := SA2->(GetArea())
	SA2->(DbSetOrder(1)) // Filial + C�digo + Loja
	
	For nX := 1 To nQtdRcPGT
		//Dados de Pagamento
		cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosPgto#" + CVALTOCHAR(nX)
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codCredorDevedor" .AND. aVet[5] == cParent } ) ) > 0
			If !oPGTRc:IsEmpty()
				cOrgao := oPGTRc:GetValue( "FV6_FAVORE" )
			Else
				cOrgao := AllTrim( oCabecDH:GetValue( "FV0_FORNEC" ) )
			EndIf
			
			oWsdl:SetValue( aSimple[nPos][1], oPGTRc:GetValue( "FV6_CGC" ) )	
			
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0
			If !oPGTRc:IsEmpty()
				oWsdl:SetValue( aSimple[nPos][1], CVALTOCHAR(oPGTRc:GetValue( "FV6_VALOR" )) )
			Else
				oWsdl:SetValue( aSimple[nPos][1], CVALTOCHAR(oDH:GetModel("TOTDBA"):GetValue("TOT_DBA") + oDH:GetModel("TOTPSO"):GetValue("TOT_PSO")) )
			Endif
		EndIf
	
		//Predoc
		If Len(aQtdPdPGT) >= nX .AND. aQtdPdPGT[nX][1] == 1
			If oPreDoc:SeekLine( { {"FV7_IDTAB", aQtdPdPGT[nX][3]}, {Iif(aQtdPdPGT[nX][3] == "5","FV7_SITUAC","FV7_ITEDOC"), aQtdPdPGT[nX][4]} } )
				cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosPgto#" + cValToChar( nX ) + ".predoc#1"
							
				If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "txtObser" .AND. aVet[5] == cParent } ) ) > 0 
					oWsdl:SetValue( aSimple[nPos][1], DecodeUTF8(EncodeUTF8(oPreDoc:GetValue( "FV7_OBS" ))) ) 
				Endif
				
				If aQtdPdPGT[nX][2] == "OB"
					cParent += ".predocOB#1"
					DefPdOB( @oWsdl, aSimple, cParent, oPreDoc )
				ElseIf aQtdPdPGT[nX][2] == "DAR"
					cParent += ".predocDAR#1"
					DefPdDAR( @oWsdl, aSimple, cParent, oPreDoc )
				ElseIf aQtdPdPGT[nX][2] == "DARF"
					cParent += ".predocDARF#1"
					DefPdDARF( @oWsdl, aSimple, cParent, oPreDoc )
				ElseIf aQtdPdPGT[nX][2] == "GRU" .AND. lOrgao
					cParent += ".predocGRU#1"
					DefPdGRU( @oWsdl, aSimple, cParent, oPreDoc )
				ElseIf aQtdPdPGT[nX][2] == "GPS"
					cParent += ".predocGPS#1"
					DefPdGPS( @oWsdl, aSimple, cParent, oPreDoc )
				Endif			
			Endif
		Endif
		
	Next nX
	
	/*
	cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosPgto#1.itemRecolhimento#1"
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], "0001" )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codRecolhedor" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], "06981180000116" )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], "1" )
	Endif
	
	
   	cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosPgto#2.itemRecolhimento#1"
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], "0001" )
	Endif
		
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codRecolhedor" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], "00000000000191" )
	Endif */
	
	RestArea(aArea)
	RestArea(aCPAArea)
	RestArea(aSA2Area)
Return Nil


/*/{Protheus.doc} MotCancCPR()
Fun��o para montar a tela de justificativa do cancelamento do documento h�bil

@return aReturn[1], Indica se a justificativa foi preenchida e o cancelamento liberado. 
@return aReturn[2], Justificativa do cancelamento do documento h�bil

@author Marylly Ara�jo Silva
@since�18/03/2015
@version P12.1.4
/*/
Function MotCancCPR()
	Local aReturn		:= {}
	Local oMultiGet	:= Nil
	Local cJustif		:= ""
	Local nOpcG		:= 0
	Local oSize		:= Nil
	Local nSuperior	:= 0
	Local nEsquerda	:= 0
	Local nInferior	:= 0
	Local nDireita	:= 0
	Local oDlgTela	:= Nil
	
	//Cria��o de classe para defini��o da propor��o da interface
	oSize := FWDefSize():New(.T.,.T., WS_POPUP )
	oSize:aMargins:= {0,0,0,0}
	oSize:Process()
	
	nSuperior := 0
	nEsquerda := 0
	nInferior := 265
	nDireita  := 440
	
	DEFINE MSDIALOG oDlgTela TITLE STR0224 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //"Cancelamento de Documento H�bil"
	
	TSay():New(35,10,{|| STR0226 },oDlgTela,,,,,,.T.,CLR_RED,CLR_BLACK,200,20) //'Justificativa de Cancelamento:' 
	oMultiGet	:= TMultiget():new( 45, 10, {| u | if( pCount() > 0, cJustif := u, cJustif ) }, oDlgTela,200, 80, , , , , , .T. )
	
	ACTIVATE MSDIALOG oDlgTela CENTERED ON INIT EnchoiceBar(oDlgTela,{|| nOpcG:=1,oDlgTela:End()},{||nOpcG:=0,oDlgTela:End()})
	
	If nOpcG == 1 .AND. !EMPTY(cJustif)
		Aadd(aReturn,.T.)
		Aadd(aReturn,cJustif)
	ElseIf nOpcG == 1 .AND. EMPTY(cJustif)	
		Help( "", 1, "SIAFLOGIN", , STR0225, 1, 0 ) //"Informe uma justificativa para o cancelamento do documento h�bil"
		Aadd(aReturn,.F.)
		Aadd(aReturn,"")
	Else
		Aadd(aReturn,.F.)
		Aadd(aReturn,"")
	EndIf

Return aReturn