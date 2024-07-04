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
Função para envio das operações do DH ao WS do SIAFI

@param nTransac, Número da transação que será realizada 
        1 = Inclusão;
        2 = Cancelamento;
        3 = Realização;
        4 = Estorno;
        5 = Consulta de Compromissos para Realização;
        6 = Consulta de Compromissos para Estorno;
        7 = Realização em Lote;
        
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
	
	//Verifica se os parâmetros necessários estão preenchidos
	If Empty( cWsdlURL ) 
		lRet := .F.
		Help( "", 1, "WsSendDH1", , STR0162, 1, 0 ) //"URL do WSDL não informada no parâmetro MV_URLMCPR." //#DEL STR		
	ElseIf	Empty( cCA ) .OR. Empty( cCERT ) .OR. Empty( cKEY )
		lRet := .F.
		Help( "", 1, "WsSendDH2", , STR0163, 1, 0 ) //"Arquivos de certificado digital não informados nos parâmetros MV_SIAFICA, MV_SIAFICE e/ou MV_SIAFIKE" //#DEL STR
	Endif
	
	If lRet
		//Abre a tela de login do WS
		aLogin := LoginCPR()
		
		//Verifica se o login foi informado corretamente
		If Len( aLogin ) > 0
			cUser := AllTrim( aLogin[1] )
			cPass := Alltrim( aLogin[2] )
			
			If nTransac == DH_TRANS_INCLUSAO //Inclusão do DH
				//Chama a rotina para envio do DH ao WS
				MsgRun( STR0164, STR0165, {|| EnviaDH( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass ) } ) //"Processando envio ao WebService do SIAFI..." //"Inclusão"
			ElseIf nTransac == DH_TRANS_CANCELAMENTO //Cancelamento do DH
				//Chama a rotina para envio do Cancelamento do DH ao WS
				MsgRun( STR0166, STR0167, {|| CancelaDH( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass ) } ) //"Processando envio do cancelamento ao WebService do SIAFI..."//"Cancelamento"
			ElseIf nTransac == DH_TRANS_REALIZACAO .OR. nTransac == DH_TRANS_REAL_LOTE //Realização do DH Individual ou em Lote
				//Chama a rotina para envio da realização do DH ao WS
				MsgRun( STR0168, STR0169, {|| RealizaDH( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass, lLote, cArqTrb, cMarca  ) } ) //"Processando envio da realização do DH ao WebService do SIAFI..."//"Realização"
			ElseIf nTransac == DH_TRANS_ESTORNO //Estorno do DH
				//Chama a rotina para envio do Estorno do DH ao WS
				MsgRun( STR0170 , STR0171, {|| EstornaDH( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass ) } ) //"Processando envio do estorno do DH ao WebService do SIAFI..."//"Estorno"
			Endif
		Else
			lRet := .F.
			Help( "", 1, "WsSendDH3", , STR0172, 1, 0 ) //"É necessário informar um usuário e senha para autenticação no SIAFI."
		Endif
	Endif
		
Return Nil

/*/{Protheus.doc} EnviaDH
Função para envio da inclusão do DH ao WS

@param cCA, Caminho do Certificado de Autorização do SIAFI
@param cCERT, Caminho do Certificado de Cliente do SIAFI
@param cKEY,  Caminho da Chave Privada do Certificado do SIAFI
@param cWsdlURL, URL do WSDL do serviço ManterContasPagarReceber do SIAFI
@param cUser, Usuário para autenticação no SIAFI
@param cPass, Senha para autenticação no SIAFI
 
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
	
	//Define as propriedades para tratar os prefixos NS das tags do XML e para remover as tags vazias, pois o WS do SIAFI não aceita as mesmas
	oWsdl:lUseNSPrefix := .T.
	oWsdl:lRemEmptyTags := .T.
	oWsdl:bNoCheckPeerCert := .T.							  
	
	//Informa os arquivos da quebra do certificado digital
	oWsdl:cSSLCACertFile := cCA
	oWsdl:cSSLCertFile := cCERT
	oWsdl:cSSLKeyFile := cKEY

	//"Parseia" o WSDL do SIAFI, para manipular o mesmo através do objeto da classe TWsdlManager  
	lRet := oWsdl:ParseURL( cWsdlURL )	
	If lRet
		//#DEL aOps := oWsdl:ListOperations()

		//Define a operação com a qual será trabalhada no Documento Hábil em questão
		lRet := oWsdl:SetOperation( "cprDHCadastrarDocumentoHabil" )
		If lRet
			//Monta o XML de comunicação com o WS do SIAFI
			MontaWsDH( @oWsdl, cUser, cPass )

			//Se houver mensagem definida, envia a mensagem. Do contrário, mostra o erro do objeto.
			oWsdl:lVerbose := .T. //#DEL
			//:TODO:
			AutoGrLog(oWsdl:GetSoapMsg())
			cFileLog := NomeAutoLog()
			cPath := ''
			If cFileLog <> ""
			   // A função MostraErro() apaga o arquivo que leu, por isso salve-o.
				MostraErro(cPath,cFileLog)
			Endif
					//:TODO			
			If !Empty( oWsdl:GetSoapMsg() )
				//Envia a mensagem SOAP ao servidor
				oWsdl:lProcResp := .F. //Não processa o retorno automaticamente no objeto (será tratado através do método GetSoapResponse)
				lRet := oWsdl:SendSoapMsg()
				If lRet
					//"Parseia" o XML de retorno do WS para ser tratado através da classe 
					//#DEL lRet := oXmlRet:Parse( oWsdl:GetSoapResponse() )
					//#DEL If lRet
					cXmlRet := oWsdl:GetSoapResponse()
					If ! Empty( cXmlRet )
						//#DEL TrataRet( oXmlRet )
						TrataRet( cXmlRet, cUser, DH_TRANS_INCLUSAO )
					Else
						ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
						ProcLogAtu( "MENSAGEM", STR0174 , STR0175 + CRLF + STR0176 + cUser, , .T. ) //'Envio do Documento Hábil: ' //"Não foi possível tratar a resposta do WebService. A requisição pode ou não ter tido sucesso. Verifique no sistema SIAFI." // "Usuário SIAFI: "
		
						Help( "", 1, "WSDLXML1", , STR0175, 1, 0 ) //"Não foi possível tratar a resposta do WebService. A requisição pode ou não ter tido sucesso. Verifique no sistema SIAFI."		
					Endif
				Else
					Help( "", 1, "WSDLXML2", , STR0177 + CRLF + oWsdl:cError, 1, 0 ) //"Ocorreu um problema ao enviar a requisição para o SIAFI: "
				Endif
			Else
				Help( "", 1, "WSDLXML3", , STR0178 + CRLF + oWsdl:cError, 1, 0 ) //"Há um problema com os dados do Documento Hábil: "
			Endif
			
		Else //Se não conseguiu definir a operação
			Help( "", 1, "WSDLXML4", , STR0179 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao definir a operação para envio ao SIAFI: "
		Endif
	Else //Se não conseguiu acessar o endereço do WSDL corretamente 
		Help( "", 1, "WSDLXML5", , STR0180 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao acessar o WSDL do serviço do SIAFI: "
	Endif 	

	oWsdl := Nil 
	//#DEL oXmlRet := Nil
Return Nil

/*/{Protheus.doc} MontaWsDH
Função para montagem da estrutura do DH para envio ao WS

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param cUser, Usuário para autenticação no SIAFI
@param cPass, Senha para autenticação no SIAFI
 
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
	
	DbSelectArea("CPA") // Órgãos Públicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + Código Órgão
	
	//Ativa o Model principal da rotina
	oModelDH := FWLoadModel( "FINA761" )
	oModelDH:SetOperation( MODEL_OPERATION_VIEW ) //Visualização
	oModelDH:Activate()
	
	//Model de Predoc
	oPreDoc := oModelDH:GetModel( "DETFV7" )
	
	//Model do Cabeçalho do DH
	oCabecDH := oModelDH:GetModel( "CABDI" )
	cUgPaga := oCabecDH:GetValue( "FV0_UGPAGA" )
	cTpDH := AllTrim( oCabecDH:GetValue( "FV0_TIPODC" ) )
	
	lOrgao := CPA->(DbSeek(FWxFilial("CPA") + oCabecDH:GetValue( "FV0_FORNEC" ) ))
	
	//Model dos Documentos de Origem
	oDocOrig := oModelDH:GetModel( "DOCORI" )
	nQtdDocOri := Iif( !oDocOrig:IsEmpty(), oDocOrig:Length(), 0 )
	
	//Model de Principal Com Orçamento
	oPCO := oModelDH:GetModel( "PCOSITUACA" )
	nQtdPCO := Iif( !oPCO:IsEmpty(), oPCO:Length(), 0 )
	
	//Define quantos itens cada registro de PCO possuí
	If nQtdPCO > 0
		//Model de Notas de Empenho (Item PCO)
		oPCOIt := oModelDH:GetModel( "PCOEMPENHO" )
		aSize( aQtdItPCO, nQtdPCO )
				
		For nX := 1 to nQtdPCO
			oPCO:GoLine( nX )
			aQtdItPCO[nX] := Iif( !oPCOIt:IsEmpty(), oPCOIt:Length(), 0 )
		Next nX
	Endif
	
	//Model de Principal Sem Orçamento
	oPSO := oModelDH:GetModel( "DETFV8" )
	nQtdPSO := Iif( !oPSO:IsEmpty(), oPSO:Length(), 0 )
	
	//Define quantos itens cada registro de PSO possuí
	If nQtdPSO > 0
		//Model de Itens PSO
		oPSOIt := oModelDH:GetModel( "DETFV9" )
		aSize( aQtdItPSO, nQtdPSO )
				
		For nX := 1 to nQtdPSO
			oPSO:GoLine( nX )
			aQtdItPSO[nX] := Iif( !oPSOIt:IsEmpty(), oPSOIt:Length(), 0 )
		Next nX
	Endif
	
	//Model de Outros Lançamentos
	oOUT := oModelDH:GetModel( "DETFVA" )
	nQtdOUT := Iif( !oOUT:IsEmpty(), oOUT:Length(), 0 )
	
	//Model de Deduções
	oDED := oModelDH:GetModel( "DETFVD" )
	nQtdDED := Iif( !oDED:IsEmpty(), oDED:Length(), 0 )
	
	//Define quantos itens cada registro de DEDUÇÃO possuí
	If nQtdDED > 0
		//Model de Recolhedores da Dedução
		oDEDRc := oModelDH:GetModel( "DETFVE" )
		aSize( aQtdRcDED, nQtdDED )
		
		//Model de Acrescimos da Dedução
		oDEDAc := oModelDH:GetModel( "DETFVF" )
		aSize( aQtdAcDED, nQtdDED )
		
		//Vetor que guarda se a linha de dudução possuí ou não Predoc		
		aSize( aQtdPdDED, nQtdDED )
				
		For nX := 1 to nQtdDED
			oDED:GoLine( nX )
			aQtdRcDED[nX] := Iif( !oDEDRc:IsEmpty(), oDEDRc:Length(), 0 )
			aQtdAcDED[nX] := Iif( !oDEDAc:IsEmpty(), oDEDAc:Length(), 0 )
			
			//Verifica se tem Predoc pra essa linha de Dedução
			If oPreDoc:SeekLine( { {"FV7_IDTAB", "3"}, {"FV7_ITEDOC", oDED:GetValue( "FVD_ITEM" )} } ) //IDTAB 3 = Dedução
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
	
	//Define quantos itens cada registro de ENCARGOS possuí
	If nQtdENC > 0
		//Model de Recolhedores do Encargo
		oENCRc := oModelDH:GetModel( "DETFVEEN" )
		aSize( aQtdRcENC, nQtdENC )
		
		//Model de Acrescimos do Encargo
		oENCAc := oModelDH:GetModel( "DETFVFEN" )
		aSize( aQtdAcENC, nQtdENC )
		
		//Vetor que guarda se a linha de Encargo possuí ou não Predoc		
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
	
	//Define quantos itens cada registro de Despesa a Anular possuí
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
	
	//Verifica se o pré-doc será por linha de situação ou por linha de favorecido na aba de Dados de Pagamento
	lPdPGT := VerifPdPGT( cTpDH, nQtdPSO, oPSO, nQtdPCO, oPCO )
						
	//Se é Pré-Doc por linha de favorecido na aba de Dados de Pagamento
	If lPdPGT
		//Vetor que guarda se a linha de favorecido, dos Dados de Pagamento, possuí ou não Predoc		
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
	Else //Se for pré-doc por linha de situação
		//Verifica se tem pré-docs definidos nas situações de PSO
		If nQtdPSO > 0				
			//Vetor que guarda se a linha de favorecido, dos Dados de Pagamento, possuí ou não Predoc		
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
		
		//Verifica se tem pré-docs definidos nas situações de PCO
		If nQtdPCO > 0
			//Vetor que guarda se a linha de favorecido, dos Dados de Pagamento, possuí ou não Predoc		
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
		
		//Verifica se tem pré-docs definidos nas situações de Deduções
		If nQtdDED > 0
			//Vetor que guarda se a linha de favorecido, dos Dados de Pagamento, possuí ou não Predoc		
			aSize( aQtdPdPGT, nQtdDED )
			
			For nX := 1 to nQtdDED
				oDED:GoLine( nX )
				//Verifica se tem Predoc pra essa linha de Dedução
				If oPreDoc:SeekLine( { {"FV7_IDTAB", "3"}, {"FV7_ITEDOC", oDED:GetValue( "FVD_ITEM" )} } ) //IDTAB 3 = Deduções
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
		
		//Verifica se tem pré-docs definidos nas situações de Deduções
		If nQtdENC > 0
			//Vetor que guarda se a linha de favorecido, dos Dados de Pagamento, possuí ou não Predoc		
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
	
	//Define as ocorrências dos tipos complexos
	DefComplex( @oWsdl, DH_TRANS_INCLUSAO, nQtdDocOri, nQtdPCO, aQtdItPCO, nQtdPSO, aQtdItPSO, nQtdOUT, nQtdDED, aQtdRcDED, aQtdAcDED, aQtdPdDED, nQtdENC, aQtdRcENC, aQtdAcENC, aQtdPdENC, nQtdDSP, aQtdItDSP,/*nQtdCOM*/,/*aQtdItCOM*/,/*aQtdItVinc*/,nQtdRcPGT, aQtdPdPGT )
	
	//Pega os elementos simples, após definição das ocorrências dos tipos complexos
	aSimple := oWsdl:SimpleInput()
	
	//Monta o cabeçalho da mensagem
	DefCabec( @oWsdl, aSimple, cUser, cPass, oCabecDH:GetValue( "FV0_UGEMIT" ) )
	
	//Monta os dados da aba Dados Básicos
	DefBasicos( @oWsdl, aSimple, nQtdDocOri, oCabecDH, oDocOrig )
	
	//Monta os dados da aba Principal com Orçamento
	DefPCO( @oWsdl, aSimple, nQtdPCO, aQtdItPCO, oPCO, oPCOIt )
	
	//Monta os dados da aba Principal sem Orçamento
	DefPSO( @oWsdl, aSimple, nQtdPSO, aQtdItPSO, oPSO, oPSOIt )
	
	//Monta os dados da aba Outros Lançamentos
	DefOUT( @oWsdl, aSimple, nQtdOUT, oOUT )
	
	//Monta os dados da aba Deduções
	DefDED( @oWsdl, aSimple, nQtdDED, aQtdRcDED, aQtdAcDED, aQtdPdDED, oDED, oDEDRc, oDEDAc, oPreDoc, cUgPaga )
	
	//Monta os dados da aba Encargos
	DefENC( @oWsdl, aSimple, nQtdENC, aQtdRcENC, aQtdAcENC, aQtdPdENC, oENC, oENCRc, oENCAc, oPreDoc, cUgPaga )
	
	//Monta os dados da aba Despesa a Anular
	DefDSP( @oWsdl, aSimple, nQtdDSP, aQtdItDSP, oDSP, oDSPIt )
	
	//Monta os dados da aba Dados de Pagamento
	DefDadPgto( @oWsdl, aSimple, nQtdRcPGT, aQtdPdPGT, oPGTRc, oPreDoc )
	
	//Limpa os objetos MVC da memória
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
Função que define as ocorrências dos tipos complexos
que serão utilizados no Documento Hábil

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param nTransac, Número da transação que será realizada 
        1 = Inclusão; 2 = Cancelamento; 3 = Realização; 4 = Estorno;
        5 = Consulta de Compromissos para Realização;
@param nQtdDocOri, Quantidade de Documentos de Origem
@param nQtdPCO, Quantidade de ocorrências na aba PCO
@param aQtdItPCO, Quantidade de itens por ocorrência PCO
@param nQtdPSO, Quantidade de ocorrências na aba PSO
@param aQtdItPSO, Quantidade de itens por ocorrência PSO
@param nQtdOUT, Quantidade de ocorrências na aba Outros Lançamentos
@param nQtdDED, Quantidade de ocorrências na aba Deduções
@param aQtdRcDED, Quantidade de itens de Recolhedores por ocorrência de Dedução
@param aQtdAcDED, Quantidade de itens de Acréscimo por ocorrência de Dedução
@param aQtdPdDED, Quantidade de itens de predoc por ocorrência de Dedução
@param nQtdENC, Quantidade de ocorrências na aba Encargos
@param aQtdRcENC, Quantidade de itens de Recolhedores por ocorrência de Encargo
@param aQtdAcENC, Quantidade de itens de Acréscimo por ocorrência de Encargo
@param aQtdPdENC, Quantidade de itens de predoc por ocorrência de Encargo
@param nQtdDSP, Quantidade de ocorrências na aba Despesa a Anular
@param aQtdItDSP, Quantidade de itens por ocorrência de Despesa a Anular
@param nQtdCOM, Quantidade de ocorrências de Compromissos para Realização
@param nQtdCOM, Quantidade de ocorrências de Compromissos para Realização
@param aQtdItCOM, Quantidade de itens por ocorrência de Compromissos para Realização ou Estorno
@param aQtdItVinc, Quantidade de itens por ocorrência de Compromissos para Realização ou Estorno
@param nQtdRcPGT, Quantidade de Favorecidos da Aba de Dados de Pagamento para um Documento Hábil
@param aQtdPdPGT, Quantidade de Pré-docs por Favorecido da Aba Dados de Pagamento para um Documento Hábil

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
			//Verifico se o item de recolhimento é da aba Dedução ou Encargos
			If At( ".deducao#", aComplex[5] ) > 0 
				nOccurs := DefQtdIt( aComplex[5], aQtdRcDED )
			ElseIf At( ".encargo#", aComplex[5] ) > 0 
				nOccurs := DefQtdIt( aComplex[5], aQtdRcENC )
			Elseif At( ".dadosPgto#", aComplex[5] ) > 0
				nOccurs := 0
			Endif
		Elseif aComplex[2] == "acrescimo"
			//Verifico se o item de acrescimo é da aba Dedução ou Encargos
			If At( ".deducao#", aComplex[5] ) > 0
				nOccurs := DefQtdIt( aComplex[5], aQtdAcDED )
			ElseIf At( ".encargo#", aComplex[5] ) > 0
				nOccurs := DefQtdIt( aComplex[5], aQtdAcENC )
			Endif
		Elseif aComplex[2] == "predoc"
			//Verifico se o predoc é da aba Dedução, Encargos ou Dados do Pagamento
			If At( ".deducao#", aComplex[5] ) > 0
				nOccurs := DefQtdIt( aComplex[5], aQtdPdDED )
			ElseIf At( ".encargo#", aComplex[5] ) > 0
				nOccurs := DefQtdIt( aComplex[5], aQtdPdENC )
			Elseif At( ".dadosPgto#", aComplex[5] ) > 0
				nOccurs := DefQtdIt( aComplex[5], aQtdPdPGT )
			Endif
		Elseif aComplex[2] == "predocOB"
			//Verifico se a Ordem Bancária é da aba Dedução, Encargos ou Dados do Pagamento
			If At( ".deducao#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdDED, "OB" )
			ElseIf At( ".encargo#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdENC, "OB" )
			Elseif At( ".dadosPgto#", aComplex[5] ) > 0 .AND. At( ".predoc#", aComplex[5] )
				nOccurs := DefPdIt( aComplex[5], aQtdPdPGT, "OB" )
			Endif
		Elseif aComplex[2] == "predocDARF"
			//Verifico se a DARF é da aba Dedução, Encargos ou Dados do Pagamento
			If At( ".deducao#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdDED, "DARF" )
			ElseIf At( ".encargo#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdENC, "DARF" )
			Elseif At( ".dadosPgto#", aComplex[5] ) > 0 .AND. At( ".predoc#", aComplex[5] )
				nOccurs := DefPdIt( aComplex[5], aQtdPdPGT, "DARF" )
			Endif
		Elseif aComplex[2] == "predocDAR"
			//Verifico se a DAR é da aba Dedução, Encargos ou Dados do Pagamento
			If At( ".deducao#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdDED, "DAR" )
			ElseIf At( ".encargo#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdENC, "DAR" )
			Elseif At( ".dadosPgto#", aComplex[5] ) > 0 .AND. At( ".predoc#", aComplex[5] )
				nOccurs := DefPdIt( aComplex[5], aQtdPdPGT, "DAR" )
			Endif
		Elseif aComplex[2] == "predocGRU"
			//Verifico se a GRU é da aba Dedução, Encargos ou Dados do Pagamento
			If At( ".deducao#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdDED, "GRU" )
			ElseIf At( ".encargo#", aComplex[5] ) > 0
				nOccurs := DefPdIt( aComplex[5], aQtdPdENC, "GRU" )
			Elseif At( ".dadosPgto#", aComplex[5] ) > 0 .AND. At( ".predoc#", aComplex[5] )
				nOccurs := DefPdIt( aComplex[5], aQtdPdPGT, "GRU" )
			Endif
		Elseif aComplex[2] == "predocGPS"
			//Verifico se a GPS é da aba Dedução, Encargos ou Dados do Pagamento
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
			//Define uma ocorrência de chave de DH para a consulta de compromissos para realização
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
		
		//Se for zero ocorrências e o mínimo de ocorrências do tipo for 1, então define como 1 para não dar erro na definição dos complexos
		If nOccurs == 0 .AND. aComplex[3] == 1
			nOccurs := 1
			Help( "", 1, "DefComplex1", STR0193,  + aComplex[2], 1, 0 ) //"Elemento obrigatório não encontrado: "
		Endif
		
    	If ! oWsdl:SetComplexOccurs( aComplex[1], nOccurs )
			Help( "", 1, "DefComplex2", , "Erro ao definir elemento " + aComplex[2] + ", ID " + cValToChar( aComplex[1] ) + ", com " + cValToChar( nOccurs ) + " ocorrências", 1, 0 ) //#DEL STR
		Endif

		aComplex := oWsdl:NextComplex()
	EndDo

Return Nil

/*/{Protheus.doc} DefQtdIt
Função que define a quantidade de elementos complexos dentro de 
um outro elemento complexo

@param cParents, String com todos os nós superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param aQtdItem, Vetor com a quantidade definida de itens de elementos complexos
        O tamanho do vetor indica quantos elementos complexos há e o valor de cada
        posição indica quantos elementos filhos haverão para o elemento em questão. 
        
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
Função que define o cabeçalho do XML a ser enviado
para o SIAFI

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param cUser, Nome do usuário que será autenticado no WS do SIAFI
@param cPass, Senha do usuário que será autenticado no WS do SIAFI
@param cUG, Código da UG que realizará o processo

@author Pedro Alencar	
@since 12/01/2015	
@version P12.1.4
/*/
Function DefCabec( oWsdl, aSimple, cUser, cPass, cUG )
	Local nPos := 0
	
	//CabeçalhoSIAFI
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "ug" .AND. aVet[5] == "cabecalhoSIAFI#1" } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], cUG )
	Endif
	
	//Bilhetador do cabeçalho SIAFI
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "nonce" .AND. aVet[5] == "cabecalhoSIAFI#1.bilhetador#1" } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], Dtos( dDataBase ) + Left( StrTran( Time(), ":", "" ), 6 ) ) 	//#DEL Revisar o NONCE
	Endif
	
	//Security
	oWsdl:SetWssHeader( SecureTag( cUser, cPass ) )
Return Nil

/*/{Protheus.doc} SecureTag
Função que define o WS-Security do cabeçalho do XML a ser enviado
para o SIAFI

@param cUser, Usuário de autenticação no SIAFI
@param cPsw, Senha de autenticação no SIAFI

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
Função que define no XML os dados da seção Dados Básicos

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdDocOri, Quantidade de Documentos de Origem
@param oCabecDH, Model de cabeçalho do cadastro do DH
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
	
	DbSelectArea("CPA") // Órgãos Públicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + Código Órgão
	
	DbSelectArea("SA2")
	aSA2Area := SA2->(GetArea())
	SA2->(DbSetOrder(1)) // Filial + Código + Loja
	
	//Cabeçalho do DH
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
	
	//Aba dados básicos
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
	
	//Dados Básicos - Documentos de Origem 	
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
Função que define no XML os dados da seção Principal com Orçamento

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdPCO, Quantidade de ocorrências na aba PCO
@param aQtdItPCO, Quantidade de itens por ocorrência PCO
@param oPCO, Model de Principal Com Orçamento do cadastro do DH
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
	
	//Principal com Orçamento 	
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
		
		//Verifica se tem campos variáveis pra situção de PCO 
		DefCpoVar( @oWsdl, aSimple, cCodPro, "FV2", cItemPai, cSituac, cParent )		
		
		//Itens do Principal Com Orçamento
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
			
			//Verifica se tem campos variáveis por item da situção de PCO 
			DefCpoVar( @oWsdl, aSimple, cCodPro, "FV5", cItemFilho, cSituac, cParent, .T., "FV2", cItemPai )
		Next nI
	Next nX
	
Return Nil

/*/{Protheus.doc} DefPSO
Função que define no XML os dados da seção Principal Sem Orçamento

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdPSO, Quantidade de ocorrências na aba PSO
@param aQtdItPSO, Quantidade de itens por ocorrência PSO
@param oPSO, Model de Principal Sem Orçamento do cadastro do DH
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
	
	//Principal sem orçamento
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
		
		//Verifica se tem campos variáveis pra situção de PSO 
		DefCpoVar( @oWsdl, aSimple, cCodPro, "FV8", cItemPai, cSituac, cParent )
		
		//Itens do Principal Sem orçamento
		For nI := 1 To aQtdItPSO[nX]
			oPSOIt:GoLine( nI )
			cParent := "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pso#" + cValToChar( nX ) + ".psoItem#" + cValToChar( nI )
			
			cItemFilho := oPSOIt:GetValue( "FV9_ITEM" )
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == cParent } ) ) > 0 
				oWsdl:SetValue( aSimple[nPos][1], cItemFilho )
			Endif
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "indrLiquidado" .AND. aVet[5] == cParent } ) ) > 0 
				//Campo não visualizado no SIAFI para as situações utilizadas no Protheus, portanto, não há nenhum campo correspondente no Protheus. Por não ter seu valor informado, esse campo é gravado como Verdadeiro no SIAFI.
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
			
			//Verifica se tem campos variáveis por item da situção de PSO 
			DefCpoVar( @oWsdl, aSimple, cCodPro, "FV9", cItemFilho, cSituac, cParent, .T., "FV8", cItemPai )
		Next nI
	Next nX
	
Return Nil

/*/{Protheus.doc} DefOUT
Função que define no XML os dados da seção Outros Lançamentos

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdOUT, Quantidade de ocorrências na aba Outros Lançamentos
@param oOUT, Model de Outros Lançamentos do cadastro do DH

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
	
	//Outros Lançamentos
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
			//Campo não visualizado no SIAFI para as situações utilizadas no Protheus, portanto, não há nenhum campo correspondente no Protheus. Por não ter seu valor informado, esse campo é gravado como Verdadeiro no SIAFI.
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( oOUT:GetValue( "FVA_VALOR" ) ) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "indrTemContrato" .AND. aVet[5] == cParent } ) ) > 0
			//Campo não visualizado no SIAFI para as situações utilizadas no Protheus, portanto, não há nenhum campo correspondente no Protheus.
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "TpNormalEstorno" .AND. aVet[5] == cParent } ) ) > 0 
			//Campo não visualizado no SIAFI para as situações utilizadas no Protheus, portanto, não há nenhum campo correspondente no Protheus.
		Endif
		
		//Verifica se tem campos variáveis pra situção de Outros Lançamentos
		DefCpoVar( @oWsdl, aSimple, cCodPro, "FVA", cItemPai, cSituac, cParent )
		
	Next nX
	
Return Nil

/*/{Protheus.doc} DefDED
Função que define no XML os dados da seção Deduções

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdDED, Quantidade de ocorrências na aba Deduções
@param aQtdRcDED, Quantidade de itens de Recolhedores por ocorrência de Dedução
@param aQtdAcDED, Quantidade de itens de Acréscimo por ocorrência de Dedução
@param aQtdPdDED, Quantidade de itens de predoc por ocorrência de Dedução
@param oDED, Model de Deduções do cadastro do DH
@param oDEDRc, Model de Recolhedores de Deduções do cadastro do DH
@param oDEDAc, Model de Acréscimos de Deduções do cadastro do DH
@param oPreDoc, Model de PréDoc do cadastro do DH
@param cUgPaga, Código da UG de pagamento

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
	
	DbSelectArea("CPA") // Órgãos Públicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + Código Órgão
	
	DbSelectArea("SA2")
	aSA2Area := SA2->(GetArea())
	SA2->(DbSetOrder(1)) // Filial + Código + Loja
	
	//Deduções
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
		
		//Verifica se tem campos variáveis pra situção de Dedução
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
		
		//Itens de Acréscimo
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
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "indrLiquidado" .AND. aVet[5] == cParent } ) ) > 0 //#DEL não econtrado no WS
				oWsdl:SetValue( aSimple[nPos][1], Iif( oDEDAc:GetValue( "FVF_RPLIQU" ) == "2", "0", "1" ) ) 
			Endif
			
			//Verifica se tem campos variáveis por acréscimo da situção de Dedução
			cItemFilho := oDEDAc:GetValue( "FVF_ITEM" )			 
			DefCpoVar( @oWsdl, aSimple, cCodPro, "FVF", cItemFilho, cSituac, cParent, .T., "FVD", cItemPai )
		Next nI
		
		//Predoc
		If aQtdPdDED[nX][1] == 1
			If oPreDoc:SeekLine( { {"FV7_IDTAB", "3"}, {"FV7_ITEDOC", oDED:GetValue( "FVD_ITEM" )} } ) //IDTAB 3 = Dedução
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
Função que define no XML os dados da seção Encargos

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdENC, Quantidade de ocorrências na aba Encargos
@param aQtdRcENC, Quantidade de itens de Recolhedores por ocorrência de Encargo
@param aQtdAcENC, Quantidade de itens de Acréscimo por ocorrência de Encargo
@param aQtdPdENC, Quantidade de itens de predoc por ocorrência de Encargo
@param oENC, Model de Encargos do cadastro do DH
@param oENCRc, Model de Recolhedores de Encargos do cadastro do DH
@param oENCAc, Model de Acréscimos de Encargos do cadastro do DH
@param oPreDoc, Model de PréDoc do cadastro do DH
@param cUgPaga, Código da UG de pagamento

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
	
	DbSelectArea("CPA") // Órgãos Públicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + Código Órgão
	
	DbSelectArea("SA2")
	aSA2Area := SA2->(GetArea())
	SA2->(DbSetOrder(1)) // Filial + Código + Loja
	
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
		
		//Verifica se tem campos variáveis pra situção de Encargo
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
		
		//Itens de Acréscimo
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
			
			If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "indrLiquidado" .AND. aVet[5] == cParent } ) ) > 0  //#DEL não econtrado no WS
				oWsdl:SetValue( aSimple[nPos][1], Iif( oENCAc:GetValue( "FVF_RPLIQU" ) == "2", "0", "1" ) ) 
			Endif
			
			//Verifica se tem campos variáveis por acréscimo da situção de Encargo
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
Função que define no XML os dados da seção Despesa a Anular

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdDSP, Quantidade de ocorrências na aba Despesa a Anular
@param aQtdItDSP, Quantidade de itens por ocorrência de Despesa a Anular
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
		
		//Verifica se tem campos variáveis pra situção de Despesa a Anular
		DefCpoVar( @oWsdl, aSimple, cCodPro, "FVL", cItemPai, cSituac, cParent )
		
		//Itens do Principal Sem orçamento
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
			
			//Verifica se tem campos variáveis por item de Despesa a Anular
			DefCpoVar( @oWsdl, aSimple, cCodPro, "FVM", cItemFilho, cSituac, cParent, .T., "FVL", cItemPai )
		Next nI
	Next nX
	
Return Nil

/*/{Protheus.doc} DefPdIt
Função que define a quantidade de elementos complexos dentro do Predoc

@param cParents, String com todos os nós superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param aQtdItem, Vetor com a quantidade definida de itens de elementos complexos
        O tamanho do vetor indica quantos elementos complexos há, o valor da primeira
        posição indica quantos elementos filhos haverão para o elemento em questão e 
        a terceira posição indica o tipo de predoc que será usado em cada elemento filho
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
Função que define no XML os dados do Predoc do tipo Ordem Bancária

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param cParents, String com todos os nós superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param oPreDoc, Model de PréDoc do cadastro do DH (já posicionado no predoc correto)

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
	
	DbSelectArea("CPA") // Órgãos Públicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + Código Órgão
	
	DbSelectArea("SA2")
	aSA2Area := SA2->(GetArea())
	SA2->(DbSetOrder(1)) // Filial + Código + Loja
	
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
		//Campo não visualizado no SIAFI para as situações utilizadas no Protheus, portanto, não há nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgRaGru" .AND. aVet[5] == cParent } ) ) > 0
		//Campo não visualizado no SIAFI para as situações utilizadas no Protheus, portanto, não há nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numRaGru" .AND. aVet[5] == cParent } ) ) > 0
		//Campo não visualizado no SIAFI para as situações utilizadas no Protheus, portanto, não há nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codRecDarf" .AND. aVet[5] == cParent } ) ) > 0
		//Campo não visualizado no SIAFI para as situações utilizadas no Protheus, portanto, não há nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "numRefDarf" .AND. aVet[5] == cParent } ) ) > 0
		//Campo não visualizado no SIAFI para as situações utilizadas no Protheus, portanto, não há nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codContRepas" .AND. aVet[5] == cParent } ) ) > 0
		//Campo não visualizado no SIAFI para as situações utilizadas no Protheus, portanto, não há nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codEvntBacen" .AND. aVet[5] == cParent } ) ) > 0
		//Campo não visualizado no SIAFI para as situações utilizadas no Protheus, portanto, não há nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codFinalidade" .AND. aVet[5] == cParent } ) ) > 0
		//Campo não visualizado no SIAFI para as situações utilizadas no Protheus, portanto, não há nenhum campo correspondente no Protheus.
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "txtCtrlOriginal" .AND. aVet[5] == cParent } ) ) > 0
		//Campo não visualizado no SIAFI para as situações utilizadas no Protheus, portanto, não há nenhum campo correspondente no Protheus.
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
		//Campo não visualizado no SIAFI para as situações utilizadas no Protheus, portanto, não há nenhum campo correspondente no Protheus.
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
Função que define no XML os dados do Predoc do tipo DAR

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param cParents, String com todos os nós superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param oPreDoc, Model de PréDoc do cadastro do DH (já posicionado no predoc correto)

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
Função que define no XML os dados do Predoc do tipo DAR

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param cParents, String com todos os nós superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param oPreDoc, Model de PréDoc do cadastro do DH (já posicionado no predoc correto)

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
Função que define no XML os dados do Predoc do tipo GRU

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param cParents, String com todos os nós superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param oPreDoc, Model de PréDoc do cadastro do DH (já posicionado no predoc correto)

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
	
	DbSelectArea("CPA") // Órgãos Públicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + Código Órgão
	
	DbSelectArea("SA2")
	aSA2Area := SA2->(GetArea())
	SA2->(DbSetOrder(1)) // Filial + Código + Loja
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codRecurso" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oPreDoc:GetValue( "FV7_RECURS" ) )
	Endif
	
	//Campo não utilizado no Protheus.
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
Função que define no XML os dados do Predoc do tipo GPS

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param cParents, String com todos os nós superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param oPreDoc, Model de PréDoc do cadastro do DH (já posicionado no predoc correto)

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
Função para formatar a data no seguinte padrão para envio ao WS: aaaa-mm-dd

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
Função para retornar a descrição do tipo de predoc com base em seu código

@param cTipoPD, Código que terá a descrição retornada
@return cRet, String com a descrição do tipo de Predoc 

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
Função que define no XML os dados dos campos variáveis das abas

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param cCodPro, Código do DH no Protheus
@param cTab, Tabela referente local do campo variável que será definido no XML
@param cItem, Linha da situação na qual o campo variável foi informado
@param cSituac, Situação na qual o campo variável foi informado
@param cParents, String com todos os nós superiores ao do elemento a ser manipulado
		Exemplo: "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1
@param lFilho, Indica se são campos variáveis do sub-item da situação
@param cTabPai, Tabela referente a aba do campo variável que será definido no XML
@param cItemPai, Linha da situação pai na qual o campo variável foi informado

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
			//Pega a tag de XML do campo variável 										
			cTag := ""
			If FV4->( msSeek( FWxFilial("FV4") + cSituac + FVN->FVN_CAMPO ) )
				cTag := AllTrim( FV4->FV4_TAGXML )
			Endif
						
			If ! Empty( cTag)
				//Procura o elemento com a tag do campo varável para definição do valor no XML
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
Função que trata a resposta do WebService

@param cXmlRet, String com as informações do XML de resposta do SIAFI
@param cUser, usuário utilizado para autenticação no SIAFI 
@param nTransac, Número da transação que será realizada 
        1 = Inclusão; 2 = Cancelamento; 3 = Realização; 4 = Estorno.
@param aRetCons, Vetor passado por referência para receber a lista de 
        compromissos caso a transação seja Contulta para Realização 

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

//Trata a string de retorno e acerta as acentuações
cXmlRet := DecodeUTF8( cXmlRet )

//Pega o resultado da requisição. Pode ser "FALHA", "SUCESSO" ou "INDEFINIDO"
cResultado := GetSimples( cXmlRet, "<resultado>", "</resultado>" )

//Se for FALHA, pega as mensagens de erro
If cResultado == "FALHA"		
	//Verifica se deu erro no WS (erro de SOAP) 
	cErro := GetSimples( cXmlRet, "<faultstring>", "</faultstring>" )		
	If ! Empty( cErro )
		cErro := CRLF + cErro
	Else
		//Pega todas as mensagens de erro retornadas pelo WS (caso o WS tenha recebido com sucesso e tenha respondido com os erros de negócio)
		If nTransac == DH_TRANS_REALIZACAO .OR. nTransac == DH_TRANS_ESTORNO 
			cErro := GetCompMGS( cXmlRet )
		Else
			cErro := GetMGS( cXmlRet )
		Endif
	Endif
	
	If nTransac == DH_TRANS_INCLUSAO
		cMsgLog	:= STR0181 //"Erro no envio do Documento Hábil: "
		cMsgHelp	:= STR0182 //"Não foi possível incluir o Documento Hábil no SIAFI. Verifique o LOG de Transações para mais detalhes."
	ElseIf nTransac == DH_TRANS_CANCELAMENTO
		cMsgLog	:= STR0183 //"Erro no cancelamento do Documento Hábil: "
		cMsgHelp := STR0184 //"Não foi possível cancelar o Documento Hábil no SIAFI. Verifique o LOG de Transações para mais detalhes."
	ElseIf nTransac == DH_TRANS_CONS_REALIZACAO
		cMsgLog	:= STR0185 //"Erro na consulta de compromissos para realização do Documento Hábil: "
		cMsgHelp := STR0186 //"Não foi possível consultar os compromissos para realizar o Documento Hábil no SIAFI. Verifique o LOG de Transações para mais detalhes."
	ElseIf nTransac == DH_TRANS_REALIZACAO
		cMsgLog	:= STR0187 //"Erro na realização do Documento Hábil: "
		cMsgHelp := STR0188 //"Não foi possível realizar o Documento Hábil no SIAFI. Verifique o LOG de Transações para mais detalhes."
	ElseIf nTransac == DH_TRANS_CONS_ESTORNO
		cMsgLog	:= STR0189 //"Erro na consulta de compromissos para estorno do Documento Hábil: "
		cMsgHelp := STR0190 //"Não foi possível consultar os compromissos para estornar o Documento Hábil no SIAFI. Verifique o LOG de Transações para mais detalhes."
	ElseIf nTransac == DH_TRANS_ESTORNO
		cMsgLog	:= STR0191 //"Erro no estorno do Documento Hábil: "
		cMsgHelp	:= STR0192 //"Não foi possível estornar o Documento Hábil no SIAFI. Verifique o LOG de Transações para mais detalhes."
	Endif
	
	//Incluí a mensagem de erro no log de Transações 
	ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
	ProcLogAtu( "ERRO", cMsgLog, cResultado + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99") + CRLF + cErro, , .T. ) //"Usuário SIAFI: "
									
	Help( "", 1, "XMLRET1", , cMsgHelp, 1, 0 )
ElseIf cResultado == "SUCESSO"
	//#DEL Pegar as informações que devem ser gravadas no Protheus (dt Ateste, Cod DH)
	
	//Pega o resultado da Consulta
	If nTransac == DH_TRANS_CONS_REALIZACAO .OR. nTransac == DH_TRANS_CONS_ESTORNO
		cResults := GetSimples( cXmlRet, "<numeroResultados>", "</numeroResultados>" )
		nResults := Iif( Empty( cResults ), 0, Val( cResults )  )
		
		//Se houve sucesso e teve algum registro retornado na consulta, então pega os registros encontrados
		If nResults > 0
			 //Pega todos os compromissos retornados no XML de resposta da consulta no WS
			 aRetCons := aClone( GetCOMP( cXmlRet ) )
		Else //Se teve sucesso na consulta mas não foi encontrado nenhum registro com os parâmetros informados
			//Pega todas as mensagens de erro retornadas pelo WS (caso o WS tenha recebido com sucesso e tenha respondido com os erros de negócio)
			cErro := GetMGS( cXmlRet )
			
			If nTransac == DH_TRANS_CONS_REALIZACAO
				cMsgLog	:= STR0187 //"Erro na realização do Documento Hábil: "
				cMsgHelp := STR0186 //"Não foi possível realizar o Documento Hábil no SIAFI. Verifique o LOG de Transações para mais detalhes."
			ElseIf nTransac == DH_TRANS_CONS_ESTORNO
				cMsgLog	:= STR0191 //"Erro no estorno do Documento Hábil: "
				cMsgHelp := STR0192 //"Não foi possível estornar o Documento Hábil no SIAFI. Verifique o LOG de Transações para mais detalhes."
			Endif
			
			//Incluí a mensagem de erro no log de Transações 
			ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
			ProcLogAtu( "ERRO", cMsgLog, "FALHA" + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99") + CRLF + cErro, , .T. ) //"Usuário SIAFI: "
			
			Help( "", 1, "XMLRET3", , cMsgHelp, 1, 0 )
		Endif
	Else
		ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
		If nTransac == DH_TRANS_INCLUSAO
			cMsgLog	:= STR0174 //"Envio do Documento Hábil: "
			cMsgHelp	:= STR0194 //"Documento Hábil incluído com sucesso no SIAFI."
			cCodSIAFI += GetSimples( cXmlRet, "<anoDH>", "</anoDH>" )
			cCodSIAFI += GetSimples( cXmlRet, "<codTipoDH>", "</codTipoDH>" )
			cCodSIAFI += PADL(GetSimples( cXmlRet, "<numDH>", "</numDH>" ),TamSX3("FV0_CODIGO")[1],"0")
			
			FV0->(RecLock("FV0",.F.))
			FV0->FV0_CODSIA	:= cCodSIAFI
			FV0->FV0_STATUS	:= "2" // Aguardando Realização
			FV0->FV0_ATESTE	:= DDATABASE
			FV0->(MsUnLock())
			
			ProcLogAtu( "MENSAGEM", cMsgLog, cResultado + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99") + CRLF + STR0208 + cCodSIAFI, , .T. ) //"Usuário SIAFI: "
		ElseIf nTransac == DH_TRANS_CANCELAMENTO
			cMsgLog	:= STR0195 //"Cancelamento do Documento Hábil: "
			cMsgHelp	:= STR0196 //"Documento Hábil cancelado com sucesso no SIAFI."
			ProcLogAtu( "MENSAGEM", cMsgLog, cResultado + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99"), , .T. ) //"Usuário SIAFI: "
			
			F761LibTit(FV0->FV0_CODIGO)
			
			FV0->(RecLock("FV0",.F.))
			FV0->FV0_STATUS := "4" // Cancelado
			FV0->(MsUnLock())
		ElseIf nTransac == DH_TRANS_REALIZACAO
			cMsgLog	:= STR0197 //"Realização do Documento Hábil: "
			cMsgHelp	:= STR0198 //"Documento Hábil realizado com sucesso no SIAFI."
			ProcLogAtu( "MENSAGEM", cMsgLog, cResultado + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99"), , .T. ) //"Usuário SIAFI: "
			
			FV0->(RecLock("FV0",.F.))
			FV0->FV0_STATUS := "3" // Realizado
			FV0->(MsUnLock())

			//Verifico se foram enviados dados de Ordem Bancária no XML
			cCodigoOB	:= GetSimples( cXmlRet, "<numeroDocumento>", "</numeroDocumento>" )
			cUgEmitente	:= GetSimples( cXmlRet, "<ugEmitenteDocumento>", "</ugEmitenteDocumento>" )
			nValorDoc	:= Val( GetSimples( cXmlRet, "<valorDocumento>", "</valorDocumento>" ) )
			dDtEmissao	:= GetSimples( cXmlRet, "<dataEmissaoDocumento>", "</dataEmissaoDocumento>" )  

			dDtEmissao	:= StoD( StrTran( SubStr( dDtEmissao, 1, 10 ), '-', '' ) ) 

			//Efetuo a gravação da tabela FVQ com a Ordem Bancária do pagamento do Documento Hábil
			If !Empty( cCodigoOB ) //Somente gravo se o código da Ordem Bancária foi enviado 
				FVQ->( dbSetOrder(1) )
				If !FVQ->( DbSeek( xFilial('FVQ') + FV0->FV0_CODIGO + cCodigoOB ) ) //Garanto que o mesmo código não seja gravado, gerando chave duplicada
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
			cMsgLog	:= STR0199 //"Estorno do Documento Hábil: "
			cMsgHelp	:= STR0200 //"Documento Hábil estornado com sucesso no SIAFI."
			ProcLogAtu( "MENSAGEM", cMsgLog, cResultado + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99"), , .T. ) //"Usuário SIAFI: "
			
			F761LibTit(FV0->FV0_CODIGO)
			
			FV0->(RecLock("FV0",.F.))
			FV0->FV0_STATUS := "5" // Cancelado
			FV0->(MsUnLock())			
		Endif
		
		MsgInfo( cMsgHelp )	
	Endif
			
ElseIf cResultado == "INDEFINIDO"
	If nTransac == DH_TRANS_INCLUSAO
		cMsgLog	:= STR0174 //"Envio do Documento Hábil: "
		cMsgHelp := STR0201 //"O retorno da inclusão do Documento Hábil no SIAFI foi INDEFINIDO. A requisição pode ou não ter tido sucesso. Verifique no sistema SIAFI."
	ElseIf nTransac == DH_TRANS_CANCELAMENTO
		cMsgLog	:= STR0195 //"Cancelamento do Documento Hábil: "
		cMsgHelp := STR0202 //"O retorno do cancelamento do Documento Hábil no SIAFI foi INDEFINIDO. A requisição pode ou não ter tido sucesso. Verifique no sistema SIAFI."
	ElseIf nTransac == DH_TRANS_CONS_REALIZACAO
		cMsgLog	:= STR0203 //"Consulta de compromissos para realização do Documento Hábil: "
		cMsgHelp := STR0204 //"O retorno da consulta do Documento Hábil no SIAFI foi INDEFINIDO. A requisição de realização pode ou não ter tido sucesso. Verifique no sistema SIAFI."
	ElseIf nTransac == DH_TRANS_REALIZACAO
		cMsgLog	:= STR0197 //"Realização do Documento Hábil: "
		cMsgHelp := STR0201 //"O retorno da realização do Documento Hábil no SIAFI foi INDEFINIDO. A requisição pode ou não ter tido sucesso. Verifique no sistema SIAFI."
	ElseIf nTransac == DH_TRANS_CONS_ESTORNO
		cMsgLog	:= STR0206 //"Consulta de compromissos para estorno do Documento Hábil: "
		cMsgHelp := STR0207 //"O retorno da consulta do Documento Hábil no SIAFI foi INDEFINIDO. A requisição de estorno pode ou não ter tido sucesso. Verifique no sistema SIAFI."
	ElseIf nTransac == DH_TRANS_ESTORNO
		cMsgLog	:= STR0199 //"Estorno do Documento Hábil: "
		cMsgHelp	:= STR0201 //"O retorno da realização do Documento Hábil no SIAFI foi INDEFINIDO. A requisição pode ou não ter tido sucesso. Verifique no sistema SIAFI."		
	Endif
	
	ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
	ProcLogAtu( "MENSAGEM", cMsgLog, cResultado + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99"), , .T. ) //"Usuário SIAFI: "
	
	Help( "", 1, "XMLRET2", , cMsgHelp, 1, 0 )
Endif

Return Nil

/*/{Protheus.doc} CancelaDH
Função para envio do cancelamento do DH ao WS

@param cCA, Caminho do Certificado de Autorização do SIAFI
@param cCERT, Caminho do Certificado de Cliente do SIAFI
@param cKEY,  Caminho da Chave Privada do Certificado do SIAFI
@param cWsdlURL, URL do WSDL do serviço ManterContasPagarReceber do SIAFI
@param cUser, Usuário para autenticação no SIAFI
@param cPass, Senha para autenticação no SIAFI
 
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
	
	//Define as propriedades para tratar os prefixos NS das tags do XML e para remover as tags vazias, pois o WS do SIAFI não aceita as mesmas
	oWsdl:lUseNSPrefix := .T.
	oWsdl:lRemEmptyTags := .T.
	oWsdl:bNoCheckPeerCert := .T. // Desabilita o check de CAs					   
	
	//Informa os arquivos da quebra do certificado digital
	oWsdl:cSSLCACertFile := cCA
	oWsdl:cSSLCertFile := cCERT
	oWsdl:cSSLKeyFile := cKEY

	//"Parseia" o WSDL do SIAFI, para manipular o mesmo através do objeto da classe TWsdlManager  
	lRet := oWsdl:ParseURL( cWsdlURL )	
	If lRet
		//Define a operação com a qual será trabalhada no Documento Hábil em questão
		lRet := oWsdl:SetOperation( "cprDHCancelarDH" )
		
		aRetMot := MotCancCPR()
		
		If lRet .AND. aRetMot[1]
			//Monta o XML de comunicação com o WS do SIAFI
			MontaCanc( @oWsdl, cUser, cPass, aRetMot[2] )

			//Se houver mensagem definida, envia a mensagem. Do contrário, mostra o erro do objeto.
			oWsdl:lVerbose := .T. //#DEL
			If !Empty( oWsdl:GetSoapMsg() )
				//Envia a mensagem SOAP ao servidor
				oWsdl:lProcResp := .F. //Não processa o retorno automaticamente no objeto (será tratado através do método GetSoapResponse)
				lRet := oWsdl:SendSoapMsg()
				If lRet
					//Pega a resposta para os devidos tratamentos
					cXmlRet := oWsdl:GetSoapResponse()
					If ! Empty( cXmlRet )
						TrataRet( cXmlRet, cUser, DH_TRANS_CANCELAMENTO )
					Else
						ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
						ProcLogAtu( "MENSAGEM", STR0195, STR0175 + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99"), , .T. ) //'Cancelamento do Documento Hábil: '//"Não foi possível tratar a resposta do WebService. A requisição pode ou não ter tido sucesso. Verifique no sistema SIAFI."//"Usuário SIAFI: "
		
						Help( "", 1, "WSDLXMLCAN1", , STR0175, 1, 0 ) //"Não foi possível tratar a resposta do WebService. A requisição pode ou não ter tido sucesso. Verifique no sistema SIAFI."		
					Endif
				Else
					Help( "", 1, "WSDLXMLCAN2", , STR0177 + CRLF + oWsdl:cError, 1, 0 ) //"Ocorreu um problema ao enviar a requisição para o SIAFI: "
				Endif
			Else
				Help( "", 1, "WSDLXMLCAN3", , STR0178 + CRLF + oWsdl:cError, 1, 0 ) //"Há um problema com os dados do Documento Hábil: "
			Endif
			
		Else //Se não conseguiu definir a operação
			Help( "", 1, "WSDLXMLCAN4", , STR0179 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao definir a operação para envio ao SIAFI: "
		Endif
	Else //Se não conseguiu acessar o endereço do WSDL corretamente 
		Help( "", 1, "WSDLXMLCAN5", , STR0180 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao acessar o WSDL do serviço do SIAFI: "
	Endif 	

	oWsdl := Nil 
Return Nil

/*/{Protheus.doc} MontaCanc
Função para montagem da estrutura do do XML de cancelamento do DH para envio ao WS

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param cUser, Usuário para autenticação no SIAFI
@param cPass, Senha para autenticação no SIAFI
 
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
	oModelDH:SetOperation( MODEL_OPERATION_VIEW ) //Visualização
	oModelDH:Activate()
	
	//Model do Cabeçalho do DH
	oCabecDH := oModelDH:GetModel( "CABDI" )
	
	//Define as ocorrências dos tipos complexos
	DefComplex( @oWsdl, DH_TRANS_CANCELAMENTO )
	
	//Pega os elementos simples, após definição das ocorrências dos tipos complexos
	aSimple := oWsdl:SimpleInput()
	
	//Monta o cabeçalho da mensagem
	DefCabec( @oWsdl, aSimple, cUser, cPass, oCabecDH:GetValue( "FV0_UGEMIT" ) )
	
	//Monta os dados de cancelamento do DH
	DefCanc( @oWsdl, aSimple, oCabecDH, cJustif )
	
	//Limpa os objetos MVC da memória
	oModelDH:Deactivate()
	oModelDH:Destroy()
	oModelDH := Nil
	oCabecDH := Nil
Return Nil

/*/{Protheus.doc} DefCanc
Função que define no XML os dados do cancelamento do DH

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param oCabecDH, Model de cabeçalho do cadastro do DH

@author Pedro Alencar	
@since 12/01/2015	
@version P12.1.4
/*/
Static Function DefCanc( oWsdl, aSimple, oCabecDH, cJustif)
	Local nPos := 0
	Local cParent := ""
	Local cAnoDH := ""
	
	//Cabeçalho do DH
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
Função para converter o valor do tipo de acréscimo no protheus para o valor do WebService

@param cTpAc, Tipo de acréscimo do Protheus
@return cRet, Caractere com o tipo de Acréscimo, de acordo com o valor esperado no WS  

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
	ElseIf cTpAc == "4" //Outros Acréscimos
		cRet := "O"
	Endif
	
Return cRet

/*/{Protheus.doc} VerifPdPGT
Função para verificar se o pré-doc de Dados de pagamento será por linha de situação 
ou por linha de favorecido

@param cTpDH, Tipo de Documento
@param nQtdPSO, Quantidade de ocorrências na aba PSO
@param oPSO, Model de Principal Sem Orçamento do cadastro do DH
@param nQtdPCO, Quantidade de ocorrências na aba PCO
@param oPCO, Model de Principal Com Orçamento do cadastro do DH
@return lRet, Se True: Por linha de favorecido. Se False: Por linha de situação   

@author Pedro Alencar	
@since 20/02/2015	
@version P12.1.4
/*/ 
Static Function VerifPdPGT( cTpDH, nQtdPSO, oPSO, nQtdPCO, oPCO )
	Local lRet := .T.
	
	//Verifica se o DH é do tipo DT e se tem dados na aba PSO para definição dos Pré-Docs de Dados de Pagamento
	If cTpDH == "DT" 
		If nQtdPSO > 0
			//Se encontrar a situação PSO002 na aba PSO, então o Pré-Doc é por linha de favorecido na aba de Dados de Pagamento
			If oPSO:SeekLine( { {"FV8_SITUAC", "PSO002"} } )
				lRet := .T.
			Else
				lRet := .F.
			Endif
		Else
			lRet := .T.
		Endif
	ElseIf cTpDH == "FL" .OR. cTpDH == "PC" //Se for DH do tipo FL ou PC, então o Pré-Doc é por linha de favorecido na aba de Dados de Pagamento
		lRet := .T.
	ElseIf cTpDH == "RB" //Verifica se o DH é do tipo RB e se tem dados na aba PCO para definição dos Pré-Docs de Dados de Pagamento
		If nQtdPCO > 0
			//Se encontrar a situação DSP901 na aba PCO, então o Pré-Doc é por linha de favorecido na aba de Dados de Pagamento
			If oPCO:SeekLine( { {"FV2_SITUAC", "DSP901"} } )
				lRet := .T.
			Else
				lRet := .F.
			Endif
		Else
			lRet := .T.
		Endif
	ElseIf cTpDH == "RP" .OR. cTpDH == "NP" //Verifica se o DH é do tipo RP ou NP e se tem dados na aba PCO para definição dos Pré-Docs de Dados de Pagamento
		lRet := .T.
	Endif
Return lRet

/*/{Protheus.doc} RealizaDH
Função para envio da realização do DH ao WS

@param cCA, Caminho do Certificado de Autorização do SIAFI
@param cCERT, Caminho do Certificado de Cliente do SIAFI
@param cKEY,  Caminho da Chave Privada do Certificado do SIAFI
@param cWsdlURL, URL do WSDL do serviço ManterContasPagarReceber do SIAFI
@param cUser, Usuário para autenticação no SIAFI
@param cPass, Senha para autenticação no SIAFI
 
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
	//Se retornou algum compromisso, então realiza o DH
	//#DEL CHAMAR UMA TELA E LISTAR OS COMPROMISSO PRA DIGITAR A VINCULAÇÂO
	If lLote
		aConfirm := ExibeDHCOM(cArqTrb, cMarca, cCA, cCERT, cKEY, cWsdlURL, cUser, cPass)
		nQtdReal := Len(aConfirm)
	Else
		//Pega a lista de compromissos para realização no SIAFI, referentes ao DH em questão
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
				//Define as propriedades para tratar os prefixos NS das tags do XML e para remover as tags vazias, pois o WS do SIAFI não aceita as mesmas
				oWsdl:lUseNSPrefix	:= .T.
				oWsdl:lRemEmptyTags	:= .T.
				
				//Informa os arquivos da quebra do certificado digital
				oWsdl:cSSLCACertFile	:= cCA
				oWsdl:cSSLCertFile	:= cCERT
				oWsdl:cSSLKeyFile		:= cKEY
				
				//"Parseia" o WSDL do SIAFI, para manipular o mesmo através do objeto da classe TWsdlManager  
				lRet := oWsdl:ParseURL( cWsdlURL ) //#DEL tentar não usar o Parse 2 vezes pro mesmos processo (ta sendo chamado na consulta e na realização) - Melhorar por conta de perfomance
				If lRet
					//Define a operação com a qual será trabalhada no Documento Hábil em questão
					lRet := oWsdl:SetOperation( "cprCPRealizarTotalCompromissos" )
					If lRet
						//Monta o XML de comunicação com o WS do SIAFI
						MontaReal( @oWsdl, cUser, cPass, aConfirm[nRealiza][2], aConfirm[nRealiza][2] )
			
						//Se houver mensagem definida, envia a mensagem. Do contrário, mostra o erro do objeto.
						oWsdl:lVerbose := .T. //#DEL
						If !Empty( oWsdl:GetSoapMsg() )
							//Envia a mensagem SOAP ao servidor
							oWsdl:lProcResp := .F. //Não processa o retorno automaticamente no objeto (será tratado através do método GetSoapResponse)
							lRet := oWsdl:SendSoapMsg()
							If lRet
								//Pega a resposta para os devidos tratamentos
								cXmlRet := oWsdl:GetSoapResponse()
								If ! Empty( cXmlRet )
									TrataRet( cXmlRet, cUser, DH_TRANS_REALIZACAO )
								Else
									ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
									ProcLogAtu( "MENSAGEM", STR0197, STR0175 + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99"), , .T. ) //'Realização do Documento Hábil: '//"Não foi possível tratar a resposta do WebService. A requisição pode ou não ter tido sucesso. Verifique no sistema SIAFI."//"Usuário SIAFI: "
					
									Help( "", 1, "WSDLXMLREA1", , STR0175 , 1, 0 ) //"Não foi possível tratar a resposta do WebService. A requisição pode ou não ter tido sucesso. Verifique no sistema SIAFI."		
								Endif
							Else
								Help( "", 1, "WSDLXMLREA2", , STR0177 + CRLF + oWsdl:cError, 1, 0 ) //"Ocorreu um problema ao enviar a requisição para o SIAFI: "
							Endif
						Else
							Help( "", 1, "WSDLXMLREA3", , STR0178 + CRLF + oWsdl:cError, 1, 0 ) //"Há um problema com os dados do Documento Hábil: "
						Endif
						
					Else //Se não conseguiu definir a operação
						Help( "", 1, "WSDLXMLREA4", , STR0179 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao definir a operação para envio ao SIAFI: "
					Endif
				Else //Se não conseguiu acessar o endereço do WSDL corretamente 
					Help( "", 1, "WSDLXMLREA5", , STR0180 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao acessar o WSDL do serviço do SIAFI: "
				Endif 	
			Endif
		Next nRealiza
	EndIf
	oWsdl := Nil 
Return Nil

/*/{Protheus.doc} ConsComp
Função para consulta de compromissos para realização do DH no WS

@param cCA, Caminho do Certificado de Autorização do SIAFI
@param cCERT, Caminho do Certificado de Cliente do SIAFI
@param cKEY,  Caminho da Chave Privada do Certificado do SIAFI
@param cWsdlURL, URL do WSDL do serviço ManterContasPagarReceber do SIAFI
@param cUser, Usuário para autenticação no SIAFI
@param cPass, Senha para autenticação no SIAFI
@param lEstorno, Indica se é consulta de compromissos para estorno 
@return aRetCons, Vetor com a lista de compromissos para Realização
        
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
	
	//Define as propriedades para tratar os prefixos NS das tags do XML e para remover as tags vazias, pois o WS do SIAFI não aceita as mesmas
	oWsdl:lUseNSPrefix := .T.
	oWsdl:lRemEmptyTags := .T.														   
	oWsdl:bNoCheckPeerCert := .T. // Desabilita o check de CAs
	//Informa os arquivos da quebra do certificado digital
	oWsdl:cSSLCACertFile := cCA
	oWsdl:cSSLCertFile := cCERT
	oWsdl:cSSLKeyFile := cKEY

	//"Parseia" o WSDL do SIAFI, para manipular o mesmo através do objeto da classe TWsdlManager  
	lRet := oWsdl:ParseURL( cWsdlURL )	
	If lRet
		//Define a operação com a qual será trabalhada no Documento Hábil em questão
		If lEstorno
			cOperation := "cprCPConsultarCompromissosParaEstorno"
		Else
			cOperation := "cprCPConsultarCompromissosParaRealizacao"
		Endif				
		lRet := oWsdl:SetOperation( cOperation )
		If lRet
			//Monta o XML de comunicação com o WS do SIAFI
			MontaCons( @oWsdl, cUser, cPass, lEstorno )

			//Se houver mensagem definida, envia a mensagem. Do contrário, mostra o erro do objeto.
			oWsdl:lVerbose := .T. //#DEL
			If !Empty( oWsdl:GetSoapMsg() )
				//Envia a mensagem SOAP ao servidor
				oWsdl:lProcResp := .F. //Não processa o retorno automaticamente no objeto (será tratado através do método GetSoapResponse)
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
							cLogTit := STR0209 //'Estorno do Documento Hábil (Consulta): '
						Else
							cLogTit := STR0210 //'Realização do Documento Hábil (Consulta): '
						Endif						
						ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
						ProcLogAtu( "MENSAGEM", cLogTit, STR0175 + CRLF + STR0176 + Transform(cUser,"@R 999.999.999-99"), , .T. ) //"Não foi possível tratar a resposta do WebService. A requisição pode ou não ter tido sucesso. Verifique no sistema SIAFI."//"Usuário SIAFI: "
		
						Help( "", 1, "WSDLXMLCON1", , STR0175, 1, 0 ) //"Não foi possível tratar a resposta do WebService. A requisição pode ou não ter tido sucesso. Verifique no sistema SIAFI."		
					Endif
				Else
					Help( "", 1, "WSDLXMLCON2", , STR0177 + CRLF + oWsdl:cError, 1, 0 ) //"Ocorreu um problema ao enviar a requisição para o SIAFI: "
				Endif
			Else
				Help( "", 1, "WSDLXMLCON3", , STR0178 + CRLF + oWsdl:cError, 1, 0 ) //"Há um problema com os dados do Documento Hábil: "
			Endif
			
		Else //Se não conseguiu definir a operação
			Help( "", 1, "WSDLXMLCON4", , STR0179 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao definir a operação para envio ao SIAFI: "
		Endif
	Else //Se não conseguiu acessar o endereço do WSDL corretamente 
		Help( "", 1, "WSDLXMLCON5", , STR0180 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao acessar o WSDL do serviço do SIAFI: "
	Endif 	

	oWsdl := Nil 
Return aRetCons

/*/{Protheus.doc} MontaCons
Função para montagem da estrutura do do XML de Consulta de Compromissos do DH 
para realização

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param cUser, Usuário para autenticação no SIAFI
@param cPass, Senha para autenticação no SIAFI
@param lEstorno, Indica se é consulta de compromissos para estorno

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
	oModelDH:SetOperation( MODEL_OPERATION_VIEW ) //Visualização
	oModelDH:Activate()
	
	//Model do Cabeçalho do DH
	oCabecDH := oModelDH:GetModel( "CABDI" )
	
	//Define as ocorrências dos tipos complexos
	If lEstorno
		DefComplex( @oWsdl, DH_TRANS_CONS_ESTORNO )
	Else
		DefComplex( @oWsdl, DH_TRANS_CONS_REALIZACAO )
	Endif
	
	//Pega os elementos simples, após definição das ocorrências dos tipos complexos
	aSimple := oWsdl:SimpleInput()
	
	//Monta o cabeçalho da mensagem
	DefCabec( @oWsdl, aSimple, cUser, cPass, oCabecDH:GetValue( "FV0_UGEMIT" ) )
	
	//Monta os dados da consulta do DH para pegar os compromissos pra realizar
	DefCons( @oWsdl, aSimple, oCabecDH, lEstorno )
	
	//Limpa os objetos MVC da memória
	oModelDH:Deactivate()
	oModelDH:Destroy()
	oModelDH := Nil
	oCabecDH := Nil
Return Nil

/*/{Protheus.doc} DefCons
Função que define no XML os dados da consulta dos compromissos
do DH para realização

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param oCabecDH, Model de cabeçalho do cadastro do DH
@param lEstorno, Indica se é consulta de compromissos para estorno

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
	
	DbSelectArea("CPA") // Órgãos Públicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + Código Órgão
	
	DbSelectArea("SA2")
	aSA2Area := SA2->(GetArea())
	SA2->(DbSetOrder(1)) // Filial + Código + Loja
	
	//Parâmetros da Consulta
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
	
	//Informações do DH para realizar a consulta
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
Função para pegar um valor simples contido entre uma
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
	
	//Localização das tags na string do XML
	nAtIni := At( cTagIni, cXmlRet )
	nAtFim := At( cTagFim, cXmlRet )
	
	//Pega o valor entre a tag inicial e final
	If nAtIni > 0 .AND. nAtFim > 0 
		nTamTag := Len( cTagIni )
		cRet := SubStr( cXmlRet, nAtIni + nTamTag, nAtFim - nAtIni - nTamTag )
	Endif
Return cRet

/*/{Protheus.doc} GetMGS
Função para pegar a lista de mensagens de erro de negócio
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
	
	//Se houver as tags de erro, então pega o range e quebra em um vetor
	If nAtIni > 0 .AND. nAtFim > 0
		nTamTag := Len( cTagIni )
		cErros := SubStr( cXmlRet, nAtIni + nTamTag, nAtFim - nAtIni - nTamTag )
		cErros := StrTran( cErros, "<txtMsg>", "||||" )
	
		aErros := StrToKarr( cErros, "||||" )
		If Len( aErros ) > 0
			//Adiciona todos os erros na string que será gravada no log de Transações
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
Função para pegar a lista de compromissos retornadas pela consulta
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
	
	//Se houver as tags de compromissos, então pega o range e quebra em um vetor
	If nAtIni > 0 .AND. nAtFim > 0
		nTamTag := Len( cTagIni )
		cComp := SubStr( cXmlRet, nAtIni + nTamTag, nAtFim - nAtIni - nTamTag )
		cComp := StrTran( cComp, cTagIni, "||||" )
	
		aComp := StrToKarr( cComp, "||||" )
		nQtdeCom := Len( aComp )
		
		If nQtdeCom > 0
			//Adiciona todos os compromissos no vetor que será utilizado para fazer a realização
			For nX := 1 To nQtdeCom
				//Pega o código do compromisso
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
Função para pegar a lista de itens de compromissos retornadas pela consulta
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
	
	//Se houver as tags de itens de compromissos, então pega o range e quebra em um vetor
	If nAtIni > 0 .AND. nAtFim > 0
		nTamTag := Len( cTagIni )
		cItComp := SubStr( cXmlCom, nAtIni + nTamTag, nAtFim - nAtIni - nTamTag )
		cItComp := StrTran( cItComp, cTagIni, "||||" )
	
		aItComp := StrToKarr( cItComp, "||||" )
		nQtdeItCom := Len( aItComp )
		
		If nQtdeItCom > 0
			//aAdd(aRet, {})
			//Adiciona todos os itens de compromissos no vetor que será retornado
			For nX := 1 To nQtdeItCom 
				//Pega o código do item do compromisso
				Aadd(aRet,GetSimples( aItComp[nX], "<codigoItemCompromisso>", "</codigoItemCompromisso>" ))			
				Aadd(aRet,GetSimples( aItComp[nX], "<valorRealizavel>", "</valorRealizavel>" ))
			Next nX
		Endif
	Endif
	
Return aRet

/*/{Protheus.doc} MontaReal
Função para montagem da estrutura do XML de realização do DH 

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param cUser, Usuário para autenticação no SIAFI
@param cPass, Senha para autenticação no SIAFI
@param aComp, Vetor com a lista de Compromissos para Realização

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
	oModelDH:SetOperation( MODEL_OPERATION_VIEW ) //Visualização
	oModelDH:Activate()
	
	//Model do Cabeçalho do DH
	oCabecDH := oModelDH:GetModel( "CABDI" )
	
	//Define a quantidade de ocorrências de Compromisso
	nQtdCOM := Len( aComp[2] )
	aSize( aQtdItCOM, nQtdCOM )
	//Define a quantidade de itens por ocorrência de Compromisso
	For nX := 1 To nQtdCOM
		aQtdItCOM[nX]	:= Len( aComp[2] )
		nQtdVinc 	+= Len(aComp[3])
		Aadd(aQtdItVinc,nQtdVinc)
	Next nX
	
	//#DEL tratar a quantidade de complexos do tipo Vinculação
	//Define as ocorrências dos tipos complexos
	DefComplex( @oWsdl, DH_TRANS_REALIZACAO,/*nQtdDocOri*/,/*nQtdPCO*/,/*aQtdItPCO*/,/*nQtdPSO*/,/*aQtdItPSO*/,/*nQtdOUT*/,/*nQtdDED*/,/*aQtdRcDED*/,/*aQtdAcDED*/,/*aQtdPdDED*/,/*nQtdENC*/,/*aQtdRcENC*/,/*aQtdAcENC*/,/*aQtdPdENC*/,/*nQtdDSP*/	,/*aQtdItDSP*/,nQtdCOM,aQtdItCOM,aQtdItVinc,/*nQtdRcPGT*/,/*aQtdPdPGT*/)

	//Pega os elementos simples, após definição das ocorrências dos tipos complexos
	aSimple := oWsdl:SimpleInput()
	
	//Monta o cabeçalho da mensagem
	DefCabec( @oWsdl, aSimple, cUser, cPass, oCabecDH:GetValue( "FV0_UGEMIT" ) )
	
	//Monta os dados da consulta do DH para pegar os compromissos pra realizar
	DefReal( @oWsdl, aSimple, oCabecDH, nQtdCOM, aQtdItCOM, aComp, nQtdVinc, aQtdItVinc, aVinc )
	
	//Limpa os objetos MVC da memória
	oModelDH:Deactivate()
	oModelDH:Destroy()
	oModelDH := Nil
	oCabecDH := Nil
Return Nil

/*/{Protheus.doc} DefReal
Função que define no XML os dados da Realização do DH

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param oCabecDH, Model de cabeçalho do cadastro do DH
@param nQtdCOM, Quantidade de ocorrências de compromissos
@param aQtdItCOM, Quantidade de itens por ocorrência de compromisso
@param aComp, Vetor com a lista de Compromissos para Realização

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
			oWsdl:SetValue( aSimple[nPos][1], Transform(DTOS(aComp[1]),"@R 9999-99-99") ) //#DEL pegar esse valor da tela de realização
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
			//#DEL Definir aqui os valores das vinculações
		Next nI
	Next nX
	
Return Nil

/*/{Protheus.doc} GetCompMGS
Função para pegar a lista de mensagens de erro de negócio
retornadas pelo WS para a operação de Realização ou Estorno

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
	
	//Se houver as tags de erro, então pega o range e quebra em um vetor
	If nAtIni > 0 .AND. nAtFim > 0
		nTamTag := Len( cTagIni )
		cResults := SubStr( cXmlRet, nAtIni + nTamTag, nAtFim - nAtIni - nTamTag )
		cResults := StrTran( cResults, cTagIni, "||||" )
	
		aResults := StrToKarr( cResults, "||||" )
		If Len( aResults ) > 0
			//Adiciona todos os erros na string que será gravada no log de Transações
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
Função para exibir uma nova tela com os compromissos consultados
para informar as vinculações de pagamento e realizar o DH

@param aComp, Vetor com a lista de Compromissos para Realização
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
Armazenamento das informações digitadas da realização do documento hábil em memória para atribuição ao WebService.

@param oView View onde foram digitadas as informações da realização do documento hábil.

@author Marylly Araújo Silva
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
Modelo de dados da tela de preenchimento das vinculações de pagamento da realização do documento hábil.

@param aComp Lista de compromissos que foi retornada do WebService para realização do documento hábil.
@return oModel Objeto do tipo FWFormModel para constituição dos campos necessários da tela de realização do documento hábil.

@author Marylly Araújo Silva
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
{ || .T. }					, ;	// [07] Code-block de validação do campo
{ || .T. }					, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ;	// [10] Indica se o campo tem preenchimento obrigatório
							)	// [11] Inicializador Padrão do campo 
							
oModel:SetDescription(STR0215) //"Rotina de Manutenção de Compromissos de Pagamento."
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
{ || .T. }					, ;	// [07] Code-block de validação do campo
{ || .F. }					, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
.F.							, ;	// [10] Indica se o campo tem preenchimento obrigatório
							)	// [11] Inicializador Padrão do campo
oStruComp:AddField(			  ;
STR0217			 			, ;	// [01] Titulo do campo	//"Vinculação"
STR0217						, ;	// [02] ToolTip do campo	//"Vinculação"
"VINCULA"					, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
3							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de validação do campo
{ || .T. }					, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ;	// [10] Indica se o campo tem preenchimento obrigatório
							)	// [11] Inicializador Padrão do campo

oStruComp:AddField(			  ;
"Tipo Documento"	 			, ;	// [01] Titulo do campo	//"Tipo Documento"
"Tipo Documento"				, ;	// [02] ToolTip do campo	//"Tipo Documento"
"TIPODOC"					, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
5							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de validação do campo
{ || .F. }					, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ;	// [10] Indica se o campo tem preenchimento obrigatório
							)	// [11] Inicializador Padrão do campo
							
oStruComp:AddField(			  ;
STR0217			 			, ;	// [01] Titulo do campo	//"Vinculação"
STR0217						, ;	// [02] ToolTip do campo	//"Vinculação"
"TIPOCOMP"					, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
20							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de validação do campo
{ || .F. }					, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ;	// [10] Indica se o campo tem preenchimento obrigatório
							)	// [11] Inicializador Padrão do campo								
oStruComp:AddField(			  ;
STR0218			 			, ;	// [01] Titulo do campo	//"Valor"
STR0218						, ;	// [02] ToolTip do campo	//"Valor"
"VALOR"						, ;	// [03] Id do Field
"N"							, ;	// [04] Tipo do campo
12							, ;	// [05] Tamanho do campo
2							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de validação do campo
{ || .F. }					, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ;	// [10] Indica se o campo tem preenchimento obrigatório
							)	// [11] Inicializador Padrão do campo


oStruComp:AddField(			  ;
"Item Compromisso"			, ;	// [01] Titulo do campo	//"Item Compromisso"
"Item Compromisso"			, ;	// [02] ToolTip do campo 	//"Item Compromisso"
"ITCOMP"						, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
4							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de validação do campo
{ || .F. }					, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
.F.							, ;	// [10] Indica se o campo tem preenchimento obrigatório
							)	// [11] Inicializador Padrão do campo

Return oStruComp

/*/{Protheus.doc} LoadComp
Load dos compromissos de pagamento do documento hábil no modelo de dados da tela de preenchimento das 
vinculações de pagamento da realização do documento hábil.

@param aComp Lista de compromissos que foi retornada do WebService para realização do documento hábil.
@return aRetGrid Array com os dados que serão exibidos no grid de vinculações dos compromissos de pagamento.

@author Marylly Araújo Silva
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
STR0217						, ;	// [03] Titulo do campo	//"Vinculação"
STR0217						, ;	// [04] ToolTip do campo	//"Vinculação"
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
View da tela de preenchimento das vinculações de pagamento da realização do documento hábil.

@param oModel Objeto do tipo FWFormModel para constituição dos campos necessários da tela de realização do documento hábil.
@return oView View onde foram digitadas as informações da realização do documento hábil.

@author Marylly Araújo Silva
@since 06/03/2015	
@version P12.1.4
/*/
Static Function ViewComp(oModel)

/*
 * Cria a estrutura de dados que será utilizada na View
 */
Local oStruCab	:= FWFormViewStruct():New()
Local oStruComp	:= VEstrComp()()
Local oView		:= FWFormView():New()

oStruCab:AddField(			;
"DATA"						, ;	// [01] Id do Field
"01"							, ;	// [02] Ordem
STR0219						, ;	// [03] Titulo do campo	//"Nova Data Emissão"
STR0219						, ;	// [04] ToolTip do campo	//"Nova Data Emissão"
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
Função para envio do Estorno do DH ao WS

@param cCA, Caminho do Certificado de Autorização do SIAFI
@param cCERT, Caminho do Certificado de Cliente do SIAFI
@param cKEY,  Caminho da Chave Privada do Certificado do SIAFI
@param cWsdlURL, URL do WSDL do serviço ManterContasPagarReceber do SIAFI
@param cUser, Usuário para autenticação no SIAFI
@param cPass, Senha para autenticação no SIAFI
 
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
	
	//Pega a lista de compromissos para estorno no SIAFI, referentes ao DH em questão
	aComp := aClone( ConsComp( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass, .T. ) )
	oWsdl:bNoCheckPeerCert := .T. // Desabilita o check de CAs														   
	
	//Se retornou algum compromisso, então estorna o DH
	If Len( aComp ) > 0
		//#DEL CHAMAR UMA TELA E LISTAR OS COMPROMISSO PRA DIGITAR A NOVA DATA DE EMISSÂO E OBSERVAÇÂO
		lConfirm := ExibeCOM( aComp )
		
		If lConfirm
			//Define as propriedades para tratar os prefixos NS das tags do XML e para remover as tags vazias, pois o WS do SIAFI não aceita as mesmas
			oWsdl:lUseNSPrefix := .T.
			oWsdl:lRemEmptyTags := .T.
			
			//Informa os arquivos da quebra do certificado digital
			oWsdl:cSSLCACertFile := cCA
			oWsdl:cSSLCertFile := cCERT
			oWsdl:cSSLKeyFile := cKEY
			
			//"Parseia" o WSDL do SIAFI, para manipular o mesmo através do objeto da classe TWsdlManager  
			lRet := oWsdl:ParseURL( cWsdlURL ) //#DEL tentar não usar o Parse 2 vezes pro mesmos processo (ta sendo chamado na consulta e na realização) - Melhorar por conta de perfomance
			If lRet
				//Define a operação com a qual será trabalhada no Documento Hábil em questão
				lRet := oWsdl:SetOperation( "cprCPEstornarCompromisso" )
				If lRet
					//Monta o XML de comunicação com o WS do SIAFI
					MontaEST( @oWsdl, cUser, cPass, aComp )
		
					//Se houver mensagem definida, envia a mensagem. Do contrário, mostra o erro do objeto.
					oWsdl:lVerbose := .T. //#DEL

					If !Empty( oWsdl:GetSoapMsg() )
						//Envia a mensagem SOAP ao servidor
						oWsdl:lProcResp := .F. //Não processa o retorno automaticamente no objeto (será tratado através do método GetSoapResponse)
						lRet := oWsdl:SendSoapMsg()
						If lRet
							//Pega a resposta para os devidos tratamentos
							cXmlRet := oWsdl:GetSoapResponse()
							If ! Empty( cXmlRet )
								TrataRet( cXmlRet, cUser, DH_TRANS_ESTORNO )
							Else
								ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
								ProcLogAtu( "MENSAGEM", STR0199, "Não foi possível tratar a resposta do WebService. A requisição pode ou não ter tido sucesso. Verifique no sistema SIAFI." + CRLF + "Usuário SIAFI: " + Transform(cUser,"@R 999.999.999-99"), , .T. ) //'Estorno do Documento Hábil: '
				
								Help( "", 1, "WSDLXMLEST1", , "Não foi possível tratar a resposta do WebService. A requisição pode ou não ter tido sucesso. Verifique no sistema SIAFI.", 1, 0 ) //#DEL STR		
							Endif
						Else
							Help( "", 1, "WSDLXMLEST2", , "Ocorreu um problema ao enviar a requisição para o SIAFI: " + CRLF + oWsdl:cError, 1, 0 ) //#DEL STR
						Endif
					Else
						Help( "", 1, "WSDLXMLEST3", , "Há um problema com os dados do Documento Hábil: " + CRLF + oWsdl:cError, 1, 0 ) //#DEL STR
					Endif
					
				Else //Se não conseguiu definir a operação
					Help( "", 1, "WSDLXMLEST4", , "Houve um problema ao definir a operação para envio ao SIAFI: " + CRLF + oWsdl:cError, 1, 0 ) //#DEL STR
				Endif
			Else //Se não conseguiu acessar o endereço do WSDL corretamente 
				Help( "", 1, "WSDLXMLEST5", , "Houve um problema ao acessar o WSDL do serviço do SIAFI: " + CRLF + oWsdl:cError, 1, 0 ) //#DEL STR
			Endif 	
		Endif
	Endif
	
	oWsdl := Nil 
Return Nil

/*/{Protheus.doc} MontaEST
Função para montagem da estrutura do XML de estorno do DH 

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param cUser, Usuário para autenticação no SIAFI
@param cPass, Senha para autenticação no SIAFI
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
	oModelDH:SetOperation( MODEL_OPERATION_VIEW ) //Visualização
	oModelDH:Activate()
	
	//Model do Cabeçalho do DH
	oCabecDH := oModelDH:GetModel( "CABDI" )
	
	//Define a quantidade de ocorrências de Compromisso
	nQtdCOM := Len( aComp )
	aSize( aQtdItCOM, nQtdCOM )
	//Define a quantidade de itens por ocorrência de Compromisso
	For nX := 1 To nQtdCOM
		aQtdItCOM[nX] := Len( aComp[nX][2] )
	Next nX
	
	//Define as ocorrências dos tipos complexos
	DefComplex( @oWsdl, DH_TRANS_ESTORNO, , , , , , , , , , , , , , , , , nQtdCOM, aQtdItCOM )
	
	//Pega os elementos simples, após definição das ocorrências dos tipos complexos
	aSimple := oWsdl:SimpleInput()
	
	//Monta o cabeçalho da mensagem
	DefCabec( @oWsdl, aSimple, cUser, cPass, oCabecDH:GetValue( "FV0_UGEMIT" ) )
	
	//Monta os dados da consulta do DH para pegar os compromissos pra realizar
	DefEST( @oWsdl, aSimple, oCabecDH, nQtdCOM, aQtdItCOM, aComp )
	
	//Limpa os objetos MVC da memória
	oModelDH:Deactivate()
	oModelDH:Destroy()
	oModelDH := Nil
	oCabecDH := Nil
Return Nil

/*/{Protheus.doc} DefEST
Função que define no XML os dados do Estorno do DH

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param oCabecDH, Model de cabeçalho do cadastro do DH
@param nQtdCOM, Quantidade de ocorrências de compromissos
@param aQtdItCOM, Quantidade de itens por ocorrência de compromisso
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
STR0220						, ;	// [01] Titulo do campo	//"Código DH"
STR0220						, ;	// [02] ToolTip do campo 	//"Código DH"
"CODIGO"						, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
6							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de validação do campo
{ || .F. }					, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
.F.							, ;	// [10] Indica se o campo tem preenchimento obrigatório
							)	// [11] Inicializador Padrão do campo

oStruDoc:AddField(			  ;
STR0221		 				, ;	// [01] Titulo do campo	//"Código SIAFI"
STR0221						, ;	// [02] ToolTip do campo	//"Código SIAFI"
"CODSIA"						, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
12							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de validação do campo
{ || .T. }					, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ; // [10] Indica se o campo tem preenchimento obrigatório
								)// [11] Inicializador Padrão do campo
								
oStruDoc:AddField(			  ;
STR0218			 			, ;	// [01] Titulo do campo	//"Valor"
STR0218						, ;	// [02] ToolTip do campo	//"Valor"
"VALOR"						, ;	// [03] Id do Field
"N"							, ;	// [04] Tipo do campo
12							, ;	// [05] Tamanho do campo
2							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de validação do campo
{ || .T. }					, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ;	// [10] Indica se o campo tem preenchimento obrigatório
							)	// [11] Inicializador Padrão do campo

Return oStruDoc

/*/{Protheus.doc} MdlRealLot
Modelo de dados da tela de preenchimento das vinculações de pagamento da realização do documento hábil.

@param aComp Lista de compromissos que foi retornada do WebService para realização do documento hábil.
@return oModel Objeto do tipo FWFormModel para constituição dos campos necessários da tela de realização do documento hábil.

@author Marylly Araújo Silva
@since 06/03/2015	
@version P12.1.4
/*/
Static Function MdlRealLot(cArqTrb, cMarca, cCA, cCERT, cKEY, cWsdlURL, cUser, cPass)

Local oModel		:= FWFormModel():New('MODELCOMP',/*bPre*/,/*bPos*/,{|| .T.}/*bCommit*/,{|| .T. }/*bCancel*/)
Local oStruCab	:= FWFormModelStruct():New()
Local oStruComp	:= EstrComp()
Local oStruDoc	:= EstrDocum()

oStruComp:AddField(			  ;
STR0220						, ;	// [01] Titulo do campo	//"Código DH"
STR0220						, ;	// [02] ToolTip do campo	//"Código DH"
"CODDH"						, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
6							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de validação do campo
{ || .T. }					, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
.F.							, ;	// [10] Indica se o campo tem preenchimento obrigatório
							)	// [11] Inicializador Padrão do campo
														
oStruCab:AddField(			  ;
STR0222						, ;	// [01] Titulo do campo //"Data"
STR0222						, ;	// [02] ToolTip do campo //"Data"
"DATA"						, ;	// [03] Id do Field
"D"							, ;	// [04] Tipo do campo
8							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de validação do campo
{ || .T. }					, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
.T.							, ;	// [10] Indica se o campo tem preenchimento obrigatório
							)	// [11] Inicializador Padrão do campo 
							
oModel:SetDescription(STR0223) //"Rotina de Manutenção de Compromissos de Pagamento em Lote."
oModel:AddFields("CABEC",/*cOwner*/,oStruCab ,/*bPre*/,/*bPost*/,/*bLoad*/ {|| })
oModel:GetModel("CABEC"):SetDescription(STR0227) //"Cabeçalho de Data de Emissão para a Realização de Compromissos."
oModel:AddGrid("DOCUMENTO","CABEC",oStruDoc,/* bLinePre */ , /* bLinePost */, /* bPre */,/* bLinePost */, {|oModel| LoadReaLot(oModel,cArqTrb, 1, cMarca, cCA, cCERT, cKEY, cWsdlURL, cUser, cPass) }/* bLoad */)
oModel:GetModel("DOCUMENTO"):SetDescription(STR0228) //"Grid de Documentos Habéis para Realização em Lote"
oModel:AddGrid("COMPROMISS","DOCUMENTO",oStruComp,/* bLinePre */ , /* bLinePost */, /* bPre */,/* bLinePost */, {|oModel| LoadReaLot(oModel,cArqTrb,2, cMarca, cCA, cCERT, cKEY, cWsdlURL, cUser, cPass) }/* bLoad */)
oModel:GetModel("COMPROMISS"):SetDescription(STR0229) //"Grid de Compromissos dos Documentos Habéis para Realização em Lote"
oModel:GetModel("COMPROMISS"):SetNoInsertLine(.F.)
oModel:GetModel("COMPROMISS"):CanDeleteLine(.F.)
oModel:SetprimaryKey({})

Return oModel

Static Function VEstrDocum()

Local oStruDocs	:= FWFormViewStruct():New()

oStruDocs:AddField(			;
"CODIGO"						, ;	// [01] Id do Field
"01"							, ;	// [02] Ordem
STR0220						, ;	// [03] Titulo do campo	//"Código DH"
STR0220						, ;	// [04] ToolTip do campo	//"Código DH"
							, ;	// [05] Help
"G"							, ;	// [06] Tipo do campo
"@!"							, ;	// [07] Picture
							, ;	// [08] PictVar
							)	// [09] F3

oStruDocs:AddField(	 		;
"CODSIA"						, ;	// [01] Id do Field
"02"							, ;	// [02] Ordem
STR0221						, ;	// [03] Titulo do campo	//"Código SIAFI"
STR0221						, ;	// [04] ToolTip do campo	//"Código SIAFI"
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
View da tela de preenchimento das vinculações de pagamento da realização do documento hábil.

@param oModel Objeto do tipo FWFormModel para constituição dos campos necessários da tela de realização do documento hábil.
@return oView View onde foram digitadas as informações da realização do documento hábil.

@author Marylly Araújo Silva
@since 06/03/2015	
@version P12.1.4
/*/
Static Function ViewDocs(oModel)

/*
 * Cria a estrutura de dados que será utilizada na View
 */
Local oStruCab	:= FWFormViewStruct():New()
Local oStruComp	:= VEstrComp()
Local oStruDocs	:= VEstrDocum()
Local oView		:= FWFormView():New()

oStruCab:AddField(			;
"DATA"						, ;	// [01] Id do Field
"01"							, ;	// [02] Ordem
STR0219						, ;	// [03] Titulo do campo	//"Nova Data Emissão"	
STR0219						, ;	// [04] ToolTip do campo	//"Nova Data Emissão"
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
	oExecView:setTitle(STR0223) //"Rotina de Manutenção de Compromissos de Pagamento em Lote."
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
Função que carrega os dados de compromissos para a realização de documento hábil em Lote

@param cArqTrab, Nome do Arquivo de Trabalho de Seleção de documentos habéis para realização
@param nOption, Qual Grid da tela de realização de documento hábil será carregada 1=Documentos Habéis;2=Compromissos;
@param nQtdRcPGT, Quantidade de ocorrências de Favorecidos na aba Dados de Pagamento
@param aQtdPdPGT, Quantidade de itens de pré-doc por ocorrência de Dados de Pagamento
@param oPGTRc, Model de Favorecidos da aba de Dados de Pagamento
@param oPreDoc, Model de Pré-docs de Favorecidos da aba de Dados de Pagamento

@author Marylly Araújo Silva
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
FV0->(DbSetOrder(1)) // Filial + Código DH

dbSelectArea(cArqTrab)
(cArqTrab)->(DbGoTop())

While !(cArqTrab)->(Eof())
	
	If (cArqTrab)->FV0_OK == cMarca
		//Pega a lista de compromissos para realização no SIAFI, referentes ao DH em questão
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
Armazenamento das informações digitadas da realização em lote do documento hábil em memória para atribuição ao WebService.

@param oView View onde foram digitadas as informações da realização do documento hábil.

@author Marylly Araújo Silva
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
Função que define no XML os dados da seção Dados de Pagamento

@param oWsdl, Objeto com as informações do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdRcPGT, Quantidade de ocorrências de Favorecidos na aba Dados de Pagamento
@param aQtdPdPGT, Quantidade de itens de pré-doc por ocorrência de Dados de Pagamento
@param oPGTRc, Model de Favorecidos da aba de Dados de Pagamento
@param oPreDoc, Model de Pré-docs de Favorecidos da aba de Dados de Pagamento

@author Marylly Araújo Silva
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
	
	DbSelectArea("CPA") // Órgãos Públicos
	aCPAArea := CPA->(GetArea())
	CPA->(DbSetOrder(1)) // Filial + Código Órgão
	
	DbSelectArea("SA2")
	aSA2Area := SA2->(GetArea())
	SA2->(DbSetOrder(1)) // Filial + Código + Loja
	
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
Função para montar a tela de justificativa do cancelamento do documento hábil

@return aReturn[1], Indica se a justificativa foi preenchida e o cancelamento liberado. 
@return aReturn[2], Justificativa do cancelamento do documento hábil

@author Marylly Araújo Silva
@since 18/03/2015
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
	
	//Criação de classe para definição da proporção da interface
	oSize := FWDefSize():New(.T.,.T., WS_POPUP )
	oSize:aMargins:= {0,0,0,0}
	oSize:Process()
	
	nSuperior := 0
	nEsquerda := 0
	nInferior := 265
	nDireita  := 440
	
	DEFINE MSDIALOG oDlgTela TITLE STR0224 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //"Cancelamento de Documento Hábil"
	
	TSay():New(35,10,{|| STR0226 },oDlgTela,,,,,,.T.,CLR_RED,CLR_BLACK,200,20) //'Justificativa de Cancelamento:' 
	oMultiGet	:= TMultiget():new( 45, 10, {| u | if( pCount() > 0, cJustif := u, cJustif ) }, oDlgTela,200, 80, , , , , , .T. )
	
	ACTIVATE MSDIALOG oDlgTela CENTERED ON INIT EnchoiceBar(oDlgTela,{|| nOpcG:=1,oDlgTela:End()},{||nOpcG:=0,oDlgTela:End()})
	
	If nOpcG == 1 .AND. !EMPTY(cJustif)
		Aadd(aReturn,.T.)
		Aadd(aReturn,cJustif)
	ElseIf nOpcG == 1 .AND. EMPTY(cJustif)	
		Help( "", 1, "SIAFLOGIN", , STR0225, 1, 0 ) //"Informe uma justificativa para o cancelamento do documento hábil"
		Aadd(aReturn,.F.)
		Aadd(aReturn,"")
	Else
		Aadd(aReturn,.F.)
		Aadd(aReturn,"")
	EndIf

Return aReturn