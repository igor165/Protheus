#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA763WS.ch'

/*/{Protheus.doc} WsSendPF
Fun��o para envio da Programa��o Financeira ao WS do SIAFI
        
@author Pedro Alencar	
@since 24/03/2015
@version P12.1.5
/*/
Function WsSendPF()
	Local lRet := .T.
	Local aLogin := {}
	Local cUser := ""
	Local cPass := ""
	Local cCA := SuperGetMV( "MV_SIAFICA" )
	Local cCERT := SuperGetMV( "MV_SIAFICE" )
	Local cKEY := SuperGetMV( "MV_SIAFIKE" )
	Local cWsdlURL := SuperGetMV( "MV_URLMPF" )
	
	//Verifica se os par�metros necess�rios est�o preenchidos
	If Empty( cWsdlURL ) 
		lRet := .F.
		Help( "", 1, "WsSendPF1", , STR0001, 1, 0 ) //"URL do WSDL n�o informada no par�metro MV_URLMPF."		
	ElseIf	Empty( cCA ) .OR. Empty( cCERT ) .OR. Empty( cKEY )
		lRet := .F.
		Help( "", 1, "WsSendPF2", , STR0002, 1, 0 ) //"Arquivos de certificado digital n�o informados nos par�metros MV_SIAFICA, MV_SIAFICE e/ou MV_SIAFIKE"
	Endif
	
	If lRet
		//Abre a tela de login do WS
		aLogin := LoginCPR()
		
		//Verifica se o login foi informado corretamente
		If Len( aLogin ) > 0
			cUser := AllTrim( aLogin[1] )
			cPass := Alltrim( aLogin[2] )
			
			//Chama a rotina para envio da PF ao WS
			MsgRun( STR0003, STR0004, {|| EnviaPF( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass ) } ) //"Processando envio ao WebService do SIAFI...", "Inclus�o" 
		Else
			lRet := .F.
			Help( "", 1, "WsSendPF3", , STR0005, 1, 0 ) //"� necess�rio informar um usu�rio e senha para autentica��o no SIAFI."
		Endif
	Endif
		
Return Nil

/*/{Protheus.doc} EnviaPF
Fun��o para envio da inclus�o do DH ao WS

@param cCA, Caminho do Certificado de Autoriza��o do SIAFI
@param cCERT, Caminho do Certificado de Cliente do SIAFI
@param cKEY,  Caminho da Chave Privada do Certificado do SIAFI
@param cWsdlURL, URL do WSDL do servi�o ManterProgramacaoFinanceira do SIAFI
@param cUser, Usu�rio para autentica��o no SIAFI
@param cPass, Senha para autentica��o no SIAFI
 
@author Pedro Alencar	
@since 24/03/2015
@version P12.1.5
/*/
Static Function EnviaPF( cCA, cCERT, cKEY, cWsdlURL, cUser, cPass )
	Local lRet := .F.
	Local oWsdl := TWsdlManager():New()
	Local cXmlRet := ""
	Local cIdCV8 := ""
	
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
		lRet := oWsdl:SetOperation( "pfCadastrarPF" )
		If lRet
			//Monta o XML de comunica��o com o WS do SIAFI
			MontaWsPF( @oWsdl, cUser, cPass )

			//Se houver mensagem definida, envia a mensagem. Do contr�rio, mostra o erro do objeto.
			oWsdl:lVerbose := .T. //#DEL
			If !Empty( oWsdl:GetSoapMsg() )
				//Envia a mensagem SOAP ao servidor
				oWsdl:lProcResp := .F. //N�o processa o retorno automaticamente no objeto (ser� tratado atrav�s do m�todo GetSoapResponse)
				lRet := oWsdl:SendSoapMsg()
				If lRet
					//Trata a resposta do WebService
					cXmlRet := oWsdl:GetSoapResponse()
					If ! Empty( cXmlRet )
						TrataRetPF( cXmlRet, cUser )
					Else
						ProcLogIni( {}, "PF" + FX0->FX0_CODIGO, "PF" + FX0->FX0_CODIGO, @cIdCV8 )
						ProcLogAtu( "MENSAGEM", STR0006, STR0007 + CRLF + STR0008 + cUser, , .T. ) //"Envio da Programa��o Financeira: ", "N�o foi poss�vel tratar a resposta do WebService. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI.", "Usu�rio SIAFI: " 
						
						Help( "", 1, "WSDLXML1", , STR0007, 1, 0 ) //"N�o foi poss�vel tratar a resposta do WebService. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI."		
					Endif
				Else
					Help( "", 1, "WSDLXML2", , STR0009 + CRLF + oWsdl:cError, 1, 0 ) //"Ocorreu um problema ao enviar a requisi��o para o SIAFI: "
				Endif
			Else
				Help( "", 1, "WSDLXML3", , STR0010 + CRLF + oWsdl:cError, 1, 0 ) //"H� um problema com os dados da Programa��o Financeira: "
			Endif
			
		Else //Se n�o conseguiu definir a opera��o
			Help( "", 1, "WSDLXML4", , STR0011 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao definir a opera��o para envio ao SIAFI: "
		Endif
	Else //Se n�o conseguiu acessar o endere�o do WSDL corretamente 
		Help( "", 1, "WSDLXML5", , STR0012 + CRLF + oWsdl:cError, 1, 0 ) //"Houve um problema ao acessar o WSDL do servi�o do SIAFI: "
	Endif 	

	oWsdl := Nil 
Return Nil

/*/{Protheus.doc} MontaWsPF
Fun��o para montagem da estrutura da PF para envio ao WS

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param cUser, Usu�rio para autentica��o no SIAFI
@param cPass, Senha para autentica��o no SIAFI
 
@author Pedro Alencar	
@since 24/03/2015	
@version P12.1.5
/*/
Static Function MontaWsPF( oWsdl, cUser, cPass )	
	Local oModelPF
	Local oCabecPF
	Local aSimple := {}
	Local oPFIt
	Local nQtdPFIt := 0
	
	//Ativa o Model principal da rotina
	oModelPF := FWLoadModel( "FINA763" )
	oModelPF:SetOperation( MODEL_OPERATION_VIEW ) //Visualiza��o
	oModelPF:Activate()
	
	//Model do Cabe�alho da Programa��o Financeira
	oCabecPF := oModelPF:GetModel( "CABPF" )

	//Model dos Itens da Programa��o Financeira
	oPFIt := oModelPF:GetModel( "ITENSPF" )
	nQtdPFIt := Iif( !oPFIt:IsEmpty(), oPFIt:Length(), 0 )
	
	//Define as ocorr�ncias dos tipos complexos
	DefComplexPF( @oWsdl, nQtdPFIt )
	
	//Pega os elementos simples, ap�s defini��o das ocorr�ncias dos tipos complexos
	aSimple := oWsdl:SimpleInput()
	
	//Monta o cabe�alho da mensagem
	DefCabec( @oWsdl, aSimple, cUser, cPass, oCabecPF:GetValue( "FX0_UGEMIT" ) )
		
	//Monta os dados da aba Dados B�sicos
	DefPF( @oWsdl, aSimple, nQtdPFIt, oCabecPF, oPFIt )
	
	//Limpa os objetos MVC da mem�ria
	oModelPF:Deactivate()
	oModelPF:Destroy()
	oModelPF := Nil
	oCabecPF := Nil
	oPFIt := Nil
Return Nil

/*/{Protheus.doc} DefComplexPF
Fun��o que define as ocorr�ncias dos tipos complexos
que ser�o utilizados na Programa��o Financeira

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param nQtdPFIt, Quantidade de ocorr�ncias de itens da PF

@author Pedro Alencar	
@since 24/03/2015	
@version P12.1.5
/*/
Static Function DefComplexPF( oWsdl, nQtdPFIt )
	Local aComplex := {}
	Local nOccurs := 0
	Local cParent := "pFCadastrarPF#1.pfDTO#1"
	Default nQtdPFIt := 0
	
	aComplex := oWsdl:NextComplex()
	While ValType( aComplex ) == "A"    
		If aComplex[2] == "bilhetador" .AND. aComplex[5] == "cabecalhoSIAFI#1"
			nOccurs := 1
		Elseif aComplex[2] == "listaItemPFDTO" .AND. aComplex[5] == cParent
			nOccurs := nQtdPFIt     						
		Else
			nOccurs := 0
		Endif
		
		//Se for zero ocorr�ncias e o m�nimo de ocorr�ncias do tipo for 1, ent�o define como 1 para n�o dar erro na defini��o dos complexos
		If nOccurs == 0 .AND. aComplex[3] == 1
			nOccurs := 1
			Help( "", 1, "DefComplexPF1", , STR0013 + aComplex[2], 1, 0 ) //"Elemento obrigat�rio n�o encontrado: "
		Endif
		
    	If ! oWsdl:SetComplexOccurs( aComplex[1], nOccurs )
			Help( "", 1, "DefComplexPF2", , STR0014 + aComplex[2] + ", ID " + cValToChar( aComplex[1] ) + ", " + STR0015 + cValToChar( nOccurs ) + STR0016, 1, 0 ) //"Erro ao definir elemento ", "com ", " ocorrencias"  
		Endif

		aComplex := oWsdl:NextComplex()
	EndDo
	
Return Nil

/*/{Protheus.doc} DefPF
Fun��o que define no XML os dados da PF

@param oWsdl, Objeto com as informa��es do wsdl do SIAFI
@param aSimple, Vetor com a lista de elementos simples do wsdl
@param nQtdPFIt, Quantidade de Itens da PF
@param oCabecPF, Model de cabe�alho do cadastro da PF
@param oPFIt, Model de itens da PF

@author Pedro Alencar	
@since 24/03/2015	
@version P12.1.5
/*/
Static Function DefPF( oWsdl, aSimple, nQtdPFIt, oCabecPF, oPFIt )
	Local nPos := 0
	Local nX := 0
	Local cParent := ""
	
	//Cabe�alho da PF
	cParent := "pFCadastrarPF#1.pfDTO#1"
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "tipoPF" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], "TRF" )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgEmit" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oCabecPF:GetValue( "FX0_UGEMIT" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgFavorecida" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oCabecPF:GetValue( "FX0_UGFAVO" ) )
	Endif
	
	If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "observacao" .AND. aVet[5] == cParent } ) ) > 0
		oWsdl:SetValue( aSimple[nPos][1], oCabecPF:GetValue( "FX0_OBS" ) )
	Endif
	
	//itens da PF
	For nX := 1 To nQtdPFIt	
		oPFIt:GoLine( nX )
		cParent += ".listaItemPFDTO#" + cValToChar( nX )	  		
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], cValToChar( oPFIt:GetValue( "FX1_VALOR" ) ) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codVinc" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], oPFIt:GetValue( "FX1_VINCPA" ) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codFontRecur" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], oPFIt:GetValue( "FX1_FONREC" ) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codCtgoGasto" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], oPFIt:GetValue( "FX1_CATGAS" ) )
		Endif
		
		If ( nPos := aScan( aSimple, {|aVet| aVet[2] == "codSit" .AND. aVet[5] == cParent } ) ) > 0
			oWsdl:SetValue( aSimple[nPos][1], oPFIt:GetValue( "FX1_SITUAC" ) )
		Endif
	Next nX
Return Nil

/*/{Protheus.doc} TrataRetPF
Fun��o que trata a resposta do WebService

@param cXmlRet, String com as informa��es do XML de resposta do SIAFI
@param cUser, usu�rio utilizado para autentica��o no SIAFI  

@author Pedro Alencar	
@since 24/03/2015	
@version P12.1.5
/*/
Static Function TrataRetPF( cXmlRet, cUser )
	Local cResultado := ""
	Local cErro := ""
	Local cIdCV8 := ""
	Local cCodSIAFI := ""
	
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
			cErro := GetMGS( cXmlRet )
		Endif
		
		//Inclu� a mensagem de erro no log de Transa��es 
		ProcLogIni( {}, "PF" + FX0->FX0_CODIGO, "PF" + FX0->FX0_CODIGO, @cIdCV8 )
		ProcLogAtu( "ERRO", STR0017, cResultado + CRLF + STR0008 + cUser + CRLF + cErro, , .T. ) //"Erro no envio da Programa��o Financeira: ", "Usu�rio SIAFI: "		
												
		Help( "", 1, "XMLRET1", , STR0018, 1, 0 ) //"N�o foi poss�vel incluir a Programa��o Financeira no SIAFI. Verifique o LOG de Transa��es para mais detalhes."
	ElseIf cResultado == "SUCESSO"				
		cCodSIAFI += GetSimples( cXmlRet, "<ano>", "</ano>" )
		cCodSIAFI += PADL( GetSimples( cXmlRet, "<numeroDocumento>", "</numeroDocumento>" ), TamSX3("FX0_CODIGO")[1], "0" )
				
		ProcLogIni( {}, "PF" + FX0->FX0_CODIGO, "PF" + FX0->FX0_CODIGO, @cIdCV8 )
		ProcLogAtu( "MENSAGEM", STR0019, cResultado + CRLF + STR0008 + cUser + CRLF + STR0022 + cCodSIAFI, , .T. ) //"Envio da programa��o Financeira: ", "Usu�rio SIAFI: ",  "C�digo PF: "
		
		RecLock( "FX0" )
		FX0->FX0_STATUS := "2"
		FX0->FX0_DTINCL := dDataBase
		FX0->FX0_CODSIA := cCodSIAFI
		FX0->( MsUnlock() )
		
		MsgInfo( STR0020 ) //"Programa��o Financeira inclu�da com sucesso no SIAFI."
			
	ElseIf cResultado == "INDEFINIDO"		
		ProcLogIni( {}, "PF" + FX0->FX0_CODIGO, "PF" + FX0->FX0_CODIGO, @cIdCV8 )
		ProcLogAtu( "MENSAGEM", STR0019, cResultado + CRLF + STR0008 + cUser, , .T. ) //"Envio da Programa��o Financeira: ", "Usu�rio SIAFI: "
		
		Help( "", 1, "XMLRET2", , STR0021, 1, 0 ) //"O retorno da inclus�o da Programa��o Financeira no SIAFI foi INDEFINIDO. A requisi��o pode ou n�o ter tido sucesso. Verifique no sistema SIAFI."
	Endif

Return Nil
