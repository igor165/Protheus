#INCLUDE	"STPOS.CH"
#INCLUDE	"FILEIO.CH"
#INCLUDE	"DIRECTRY.CH"
#INCLUDE	"AUTODEF.CH"
#INCLUDE	"STBFISCALMENU.CH"
#INCLUDE	"TOTVS.CH"
#INCLUDE	"XMLXFUN.CH"

Static lHomolPaf	:= STBHomolPaf()
Static lTotvsPdv	:= STFIsPOS()
Static cPathCert	:= PAF_DirCERT //Define do AUTODEF
Static cDefEnt		:= "000001"
Static cDefPrvKey	:= "_cert.pem"
Static cDefKey		:= "_key.pem"
Static PULALINHA	:= CHR(10) + CHR(13)

Static cSttWSAGUA	:= "AGUARDANDO"
Static cSttWSERRO	:= "ERRO"
Static cSttWSSUCE	:= "SUCESSO"
Static cSttWSNGER	:= "NAO GERADO"
Static cSttWSRECN	:= "RECIBO NAO ENCONTRADO"

//-----------------------------------------------------------
/*/
{Protheus.Doc} LPXVlEnvFi
	
Função para validação do envio do arquivo de informações ao fisco
sobre a Redução Z e Estoque

@author  	Varejo
@version 	P11.8
@since   	10/11/2015
@return  	lRet  - função executada com sucesso 
@obs     
@sample	
/*/
//-----------------------------------------------------------
Function LPXVlEnvFi(lPos	, lEnvia	, cTipoArq	, lVldPend,;
					lSemEcf	,lPergEnv	)
Local cPath		:= ""
Local cMensagem	:= ""
Local cXML		:= ""
Local cMsg		:= ""
Local cNomArq	:= ""
Local lRet		:= .T.
Local lSentOK	:= .T.
Local nContRZ	:= 0	//contador de Redução Z pendente de envio (independente de dias) fi_xmlenv = N + fi_xmlenv = E  
Local nContES	:= 0	//contador de arquivo de Estoque pendente de envio (independente de dias) mdz_xmlenv = N +  mdz_xmlenv = E
Local nContRZVC	:= 0	//contador de Redução Z pendente de envio com 20 dias ou mais. fi_xmlenv = N + fi_xmlenv = E.  ATO DIAT Nº 011/2020
Local nContESVC	:= 0	//contador de arquivo de Estoque pendente de envio com 20 dias ou mais.  mdz_xmlenv = N +  mdz_xmlenv = E. ATO DIAT Nº 011/2020
Local nX		:= 0
Local nY		:= 0
Local aFileRZ	:= {}
Local aFileES	:= {}
Local aLista	:= {}	//array com contador de arquivos  de redução Z[1] e [3] e estoque[2] e [4] com erro no envio _xmlenv in(N,E)
Local aRet		:= {}
Local aArea		:= {}
LOcal lPerfilTU := AllTrim(SM0->M0_ESTCOB) $ "TO|DF"
Local lSTBPEnvXML:= STBPEnvXML()
Local lMvLjPdvPa:= LjxBGetPaf()[2]
Local lTodosSim	:= .F.
Local lTodosNao	:= .F.
Local lVirouMes := .F.
Local lReEnvia	:= .F.
Local dDtAntRZ	:= ""
Local dDtObrig	:= CTOD("")

Default lPos	:= .F.
Default lEnvia	:= .F.
Default cTipoArq:= '' //'R' (Reducao Z) ou 'E' (Estoque)
Default lVldPend:= .T.
Default lSemEcf	:= .F.
Default lPergEnv:= .T. //Para perguntar ou não se deseja enviar caso seja chamado pela Redução automatica do sistema

If lSTBPEnvXML
	dDtObrig:= CTOD("01/10/2020")
	cMsg := GetPvProfString("PAF-ECF","BlocoX","", GetClientDir()+"SIGALOJA.INI")
	If !Empty(cMsg) .And. (Len(cMsg) == 8)
		//padrão AAAAMMDD
		dDtObrig := STOD(cMsg)
		LjGrvLog( NIL, "Data da obrigatoriedade configurada no SIGALOJA.INI - Chave Bloco X", cMsg)
	EndIf
Else
	cMensagem := "Envio do XML não obrigatório ou sem URL de transmissão, caso esteja habilitado o uso configure o parâmetro MV_LJPENXM"
	LjGrvLog(Nil, cMensagem)
	
	If IsInCallStack("STBMenFis")
		MsgInfo(cMensagem,"PAF-ECF")
	EndIf
	cMensagem := ""
EndIf

//--Valida configuração apenas, por isso mando "X"
//--Valida a data de obrigatoriedade do envio
If lSTBPEnvXML .And. STBPafCSef("X") .And. ( Date() >= dDtObrig )
	STBFMGerPath( @cPath )
	cPath += PAF_DirXML + '\'
	
	//Estava dando erro quando tinha duas barras e não gerava o arquivo
	//portanto coloco aqui um ajuste para substituir 
	cPath := StrTran(cPath,"\\","\")
	
	If Empty(cTipoArq) .Or. cTipoArq == "R"
		aFileRZ := STRedXML("Q") //FI_XMLENV = 'N'
		If Len(aFileRZ) > 0
			nContRZ += Len(aFileRZ) 
			aEval( aFileRZ, {|x| If( x[2] <= Date()-20, nContRZVC++, nil ) } )
		EndIf
	EndIf
	
	If Empty(cTipoArq) .Or. cTipoArq == "E"
		
		If cTipoArq == "E" //Só deixa perguntar quando vem do Menu Fiscal
			If MsgYesNo("Gostaria de selecionar um periodo para geração do XML de Estoque?","PAF-ECF")
				SFMProcXEs( .T. , lPos )
			EndIf
		EndIf
		
		aFileES := STEstqXML(lMvLjPdvPa,"Q",,,,,,,dDtObrig) //MDZ_XMLENV = 'N'
		If Len(aFileES) > 0
			For nX := 1 to Len(aFileES)
				nContES += aFileES[nX][1]
				If aFileES[nX][1] > 0 .And. Empty(aFileES[nX,5])
					MsgInfo("Sera gerado na retaguarda o XML de Estoque para a data [" + aFileES[nX,3] + "] - " +;
						"pode haver uma demora dependendo da quantidade de produtos na base","PAF-ECF")
					Aadd(aLista,STEstqXML(lMvLjPdvPa,"T",aFileES[nX,4],,StoD(aFileES[nX,3])+1,/*lHomol*/,/*cNumCreden*/))
				EndIf
			Next nX

			If nContES > 0 
				aEval(aFileES, {|x| If( x[6] <= Date()-20, nContESVC++, nil ) } )
			Endif 

		EndIf	
	EndIf
	
	If lEnvia
		If nContRZ > 0 .And. (!lPergEnv .Or. ( lPergEnv .And. (lReEnvia := MsgYesNo("Existem Reduções Z pendentes!" +;
		 									PULALINHA + "Gostaria de solicitar o re-envio?","XML PAF-ECF")))) 
			DbSelectArea("SFI")
			aArea := SFI->(GetArea())
			SFI->(DbGoTop())
			While !SFI->(Eof())
				
				If SFI->FI_DTMOVTO < dDtObrig
					STFUpFIXML({{"FI_XMLENV","X"},{"FI_SITUA","00"},{"FI_XMLRPAF",""}, {"FI_XMLEPAF",""}},,SFI->(RecNo()))
					SFI->(DbSkip())
					Loop
				EndIf
				
				cXML := ""
				dDtAntRZ:= SFI->FI_DTMOVTO
				cNomArq := StrTran(DTOC(SFI->FI_DTMOVTO),"/") //Requisito LVIII - Item 4.2.1 - Mensagem com o nome do arquivo pendente de envio - 'Reducao Z DDMMAAAA'
				
				//Valido o X pois o cliente caso altere para não ir, o arquivo deve ser enviado mesmo assim
				If SFI->FI_XMLENV $ " |N" .Or. (!(SFI->FI_XMLENV $ " |N") .And. !(AllTrim(SFI->FI_PAFMD5) == STxPafMd5("SFI")))
					cXML := AllTrim(SFI->FI_XMLEPAF)
										
					//Caso tenha ocorrido algum problema não gerou os dados do XML
					If Empty(cXML)
						aRet := LPXFiscoRedZ(lTotvsPDV,SFI->(FI_FILIAL + DTOS(FI_DTMOVTO) + FI_PDV),SFI->FI_DTMOVTO)
						If aRet[1][1]
							cXML := aRet[1][2]
						EndIf
					EndIf
				EndIf
				
				If !Empty(cXML)
					
					//ER 02.06 - Bloco XII - Requisito LXI - Item 7.b
					If !lVirouMes
						lVirouMes := month(dDtAntRZ) <> month(dDatabase)
					EndIf
					
					nX		:= 0
					lSentOK := .F.
					
					If lTodosSim .Or. !lPergEnv
						nX := 1
					ElseIf lTodosNao
						nX := 2
					Else						
						nX := Aviso( "XML PAF-ECF", "Deseja gerar novamente o(s) arquivo(s) XML('s) e reenvia-lo(s) ? " ,;
						 			{ "Sim", "Não", "Sim p/ todos", "Não p/ todos" }, 3, "Arquivo de XML" )
						
						If nX == 3
							lTodosSim := .T.
							nX := 1
						EndIf
						
						lTodosNao := (nX == 4)
					EndIf
					
					If nX == 1
						
						//Deixo efetuar o envio somente se não selecionou todos os arquivos
						If !lTodosSim
							//Faz o processo de envio, programa da SEFAZ
							lSentOK := LPXAjXML("R",@cXML,SFI->FI_PDV)[1]
						EndIf
						
						If !lSentOK
						  	If (Empty(cXML) .Or. nX == 1)
						  		//Caso tenha o XML esteja errado, re-gero e re-envio
								aRet := LPXFiscoRedZ(lTotvsPDV,SFI->(FI_FILIAL + DTOS(FI_DTMOVTO) + FI_PDV),SFI->FI_DTMOVTO)
								If aRet[1][1]
									cXML := aRet[1][2]
									lSentOK := LPXAjXML("R",@cXML,SFI->FI_PDV)[1]
								EndIf
							EndIf
						EndIf
					EndIf
					
					If lSentOK
						nContRZ -= 1
						LjGrvLog( NIL," Redução Z - Numero (FI_NUMREDZ) [" + cValToChar(SFI->FI_NUMREDZ)  + "] - enviada")
					Else
						cMsg += " Redução Z - Numero (FI_NUMREDZ) [" + cValToChar(SFI->FI_NUMREDZ)  + "]" + PULALINHA
					EndIf
				EndIf
				SFI->(DbSkip())
			End
			
			If !Empty(cMsg)
				cMsg := " A(s) seguinte(s) Redução(ões) Z não foram enviadas" +; 
						PULALINHA + cMsg
				LjGrvLog( NIL,cMsg)
				STPosMSG( "Envio de Redução Z" , cMsg, .T., .F., .F.)
				cMsg := ""
			EndIf
			
			RestArea(aArea)
		Else
			lReEnvia := !lReEnvia .And. (nContRZ > 0)
			
			If nContRZ == 0 .Or. ((Empty(cTipoArq) .Or. cTipoArq == "R") .And. !lReEnvia)
				cMsg := "Não existem arquivos de Redução Z para envio via XML"
				If lHomolPaf
					MsgInfo(cMsg,"PAF-ECF")
				EndIf
				LjGrvLog( NIL, cMsg)
				Conout(cMsg)
			EndIf
		EndIf
		
		If Len(aLista) > 0 .And. (!lPergEnv .Or. ( lPergEnv .And. (lReEnvia := MsgYesNo("Existem XML de Estoque pendentes!" +;
		 													PULALINHA + "Gostaria de solicitar o re-envio?","XML PAF-ECF"))))
			For nX := 1 to Len(aLista)
				For nY := 1 to Len(aLista[nX])  
					cXML := AllTrim(aLista[nX][nY][1])
					
					//Faz o processo de envio, programa da SEFAZ
					lSentOK := LPXAjXML("E",@cXML)[1]
					
					If !lSentOK .And. !Empty(AllTrim(cXML))
						lSentOK := LPXReenEst(cXML)
					EndIf
					
					If lSentOK
						nContES -= 1
						LjGrvLog(Nil,"Estoque [ Recno - MDZ :" + cValToChar(aLista[nX][nY][2])  + "] enviado ")
					Else
						cMsg := "Estoque [ Recno - MDZ :" + cValToChar(aLista[nX][nY][2])  + "] não foi enviado"
						STPosMSG( "Envio de Estoque" , cMsg, .T., .F., .F.)
						LjGrvLog( Nil,cMsg)
						cMsg := ""
					EndIf
				Next nY
			Next nX
		Else
			lReEnvia := !lReEnvia .And. (Len(aLista) > 0)
			
			If (Len(aLista) == 0) .Or. ((Empty(cTipoArq) .Or. cTipoArq == "E") .And. !lReEnvia)
				cMsg := "Não existem arquivos de Estoque para envio via XML"
				If lHomolPaf
					MsgInfo(cMsg,"PAF-ECF")
				EndIf
				LjGrvLog( NIL, cMsg)
				Conout(cMsg)
				cMsg := ""
			EndIf
		EndIf
	EndIf
	
	LPXSMsgErr("",.T.) //Emite mensagens de erro acumuladas no processo
	
	//***** Efetuo o processo de validação dos XML's conforme o retorno da SEFAZ - Aguardando *****//
	LjGrvLog( NIL,"Antes da Execução de LPXXMLAgua - Validação do Status do XML na SEFAZ - Aguardando")
	LPXXMLAgua("")
	LjGrvLog( NIL,"Depois da Execução de LPXXMLAgua - Validação do Status do XML na SEFAZ - Aguardando")
	
	//***** Efetuo o processo de validação dos XML's conforme o retorno da SEFAZ *****// 
	//***** e acrescento para indicar o uso do monitor de ajuste de XML do PAF	*****//
	LjGrvLog( NIL,"Antes da Execução de LPXXMLErr - Validação do Status do XML na SEFAZ - Erro")
	aSize(aLista,0)
	aLista := {0, 0, 0, 0} //_XMLENV='E'. 1º qtde red pendentes, 2º qtde est pendentes, 3º red pend 20 dias, 3º EST pend 20 dias (ATO DIAT 11/2020), 4º est pend 20 dias (ATO DIAT 11/2020)  
	LPXXMLErr("",@aLista[1],@aLista[2],@aLista[3],@aLista[4])
	LjGrvLog( NIL,"Depois da Execução de LPXXMLErr - Validação do Status do XML na SEFAZ - Erro", aLista)
	
	If aLista[1] + aLista[2] > 0
		cMsg := Upper("Há Pendências de arquivos XML com Erro") + Replicate(PULALINHA,2)
		cMsg += "Acesse a rotina Monitor de XML do PAF-ECF (LJMONITPAF) para "
		cMsg += "resolver essas pendências" + Replicate(PULALINHA,2)
		cMsg += "- Redução Z: " + cValToChar(aLista[1]) + " XML pendente(s)" + PULALINHA
		cMsg += "- Estoque: " + cValToChar(aLista[2]) + " XML pendente(s)"+ PULALINHA
		STPosMSG( "XML PAF-ECF [PENDÊNCIAS]" , cMsg, .T., .F., .F.)
		cMsg := ""
	EndIf
	
	//_XMLENV = 'N'+ _XMLENV = 'E'
	nContRZ += aLista[1] 
	nContES += aLista[2]
	nContRZVC += aLista[3] 
	nContESVC += aLista[4] 
	
	If lVldPend
		If nContRZ > 0
			/*
			Ato ER 02.06 - existe um tratamento especifico para Tocantins
			lPerfilTU == .T.
			Para esses estados dos Perfis T e U (TO e DF), não bloqueia a Redução Z			
			*/
			cMensagem := "HÁ " + AllTrim(cValToChar(nContRZ)) + " (" + Extenso(nContRZ,.T.,2,1) +")" +;
						" ARQUIVOS COM INFORMAÇÕES DA REDUÇÃO Z DO PAF-ECF " +;
						"PENDENTES DE TRANSMISSÃO AO FISCO. O CONTRIBUINTE PODE TRANSMITIR OS ARQUIVOS PELO MENU " +;
						"FISCAL POR MEIO DO COMANDO 'TRANSMITIR ARQUIVOS " + ;
						IIf(lPerfilTU,"REQUISITO XXVI'", " COM INFORMAÇÕES DA REDUÇÃO Z " + cNomArq + ".'")

			
			If lPerfilTU 
				If lVirouMes
					//ER 02.06 - Bloco XII - Requisito LXI - Item 7.b
					cMensagem := "HÁ " + AllTrim(cValToChar(nContRZ)) + " (" + Extenso(nContRZ,.T.,2,1) +")" +;
							" ARQUIVOS REQUISITO XXVI PENDENTES DE TRANSMISSÃO " +;
							"AO FISCO. O CONTRIBUINTE PODE GERAR A REMESSA ATRAVÉS DO MENU FISCAL POR MEIO DO COMANDO " +;
							" 'TRANSMITIR ARQUIVOS REQUISITO XXVI' "
				EndIf
			Else
				cMensagem += PULALINHA + "VERIFIQUE COM O FORNECEDOR DO PROGRAMA A SOLUÇÃO DA PENDÊNCIA."
			EndIf
			Alert(cMensagem)
		EndIf

		If nContES > 0
			cMensagem := "HÁ " + AllTrim(cValToChar(nContES)) + " (" + Extenso(nContES,.T.,2,1) +")" +;
					" ARQUIVOS COM INFORMAÇÕES DO ESTOQUE MENSAL DO " +;
					"ESTABELECIMENTO PENDENTES DE TRANSMISSÃO AO FISCO. O CONTRIBUINTE PODE TRANSMITIR OS ARQUIVOS PELO MENU " +;
					"FISCAL POR MEIO DO COMANDO 'TRANSMITIR ARQUIVOS COM INFORMAÇÕES DO ESTOQUE MENSAL "+ cNomArq +"' "
			cMensagem += PULALINHA + "VERIFIQUE COM O FORNECEDOR DO PROGRAMA A SOLUÇÃO DA PENDÊNCIA."
			Alert(cMensagem)
		EndIf



		If nContRZVC + nContESVC > 0
			cMsg := Upper("ATENÇÃO, há arquivos XML pendentes de envio por 20 dias ou mais!") + Replicate(PULALINHA,2)
			cMsg += "Acesse a rotina Monitor de XML do PAF-ECF (LJMONITPAF) para "
			cMsg += "resolver essas pendências" + Replicate(PULALINHA,2)
			cMsg += "- Redução Z: " + cValToChar(nContRZVC) + " XML pendente(s)" + PULALINHA
			cMsg += "- Estoque: " + cValToChar(nContESVC) + " XML pendente(s)"+ PULALINHA
			STPosMSG( "XML PAF-ECF [PENDÊNCIAS]" , cMsg, .T., .F., .F.)
			cMsg := ""
		EndIf

		
		If lRet
			If nHdlECF == -1
				LjOpenDevices()
			EndIf
		Else
			cMensagem := "Atenção! Conforme requisito XIX do Ato Cotepe, o ECF será desabilitado "
			cMensagem += "até que haja o envio dos arquivos pendentes " + PULALINHA
			cMensagem += "Verifique sua conexão com a SEFAZ ou Logs do Protheus(busca de inconsistências)" + PULALINHA
			cMensagem += "Verifique o Monitor de XML do PAF (LJMONITPAF) para efetuar o envio dos arquivos pendentes"
			
			Alert(cMensagem)
			LJRPLogProc(cMensagem)
			If	lHomolPaf .Or. ;
				!(AllTrim(GetPvProfString("paf-ecf", "pendentes", "", GetClientDir() + "sigaloja.ini")) == "0")			
				
				LjCloseDevices() //Fecha toda a comunicação com equipamento
			EndIf
		EndIf
	EndIf

ElseIf !(Date() >= dDtObrig)
	cMensagem := "Caso deseja configurar a Data da obrigatoriedade " +;
					" do envio do Bloco X configure o arquivo SIGALOJA.INI " +;
					" Sessão [PAF-ECF], Chave Bloco X, preenchendo com a data" +;
					" da obrigatoriedade no padrão AAAAMMDD. " + PULALINHA +;
					"Onde A = Ano , M = Mes , D = Dia"
	LjGrvLog( NIL, cMensagem )
	COnout(cMensagem)
EndIf

Return lRet

//-----------------------------------------------------------
/*/
{Protheus.Doc}LPXFiscoRedZ()
	
Função para criação do arquivo de informações ao fisco
sobre a Redução Z

@param1 lPos		: Logico, É TotvsPdv?
@param2 cKeySFI		: Caracter, chave da SFI
@author  	Varejo
@version 	P12
@since   	12/05/2017
@return  	aRet  : Array , execução ok ?
/*/
//-----------------------------------------------------------
Function LPXFiscoRedZ(lPos,cKeySFI,dData)
Local cFile		:= ''
Local cLocalPath:= ''
Local cMsgErro	:= ''
Local aRet		:= {}
Local aConteudo	:= {}
Local nHandle	:= 0
Local lGeraArquivo:= .F.
Local lMsgErro	:= .F.

Default lPos	:= lTotvsPdv
Default cKeySFI	:= ""
Default dData	:= Date()

LjGrvLog("GER_XML_PAF","Inicio do Arquivo do Fisco da Redução Z")

LWSPGerWSD( .T. , .T. )

If ! Empty(cKeySFI)
	STBFMGerPath( @cLocalPath )
	cLocalPath += PAF_DirXML + '\'
	
	//Estava dando erro quando tinha duas barras e não gerava o arquivo
	//portanto coloco aqui um ajuste para substituir 
	cLocalPath := StrTran(cLocalPath,"\\","\")
	
	//Padrão nomenclatura conforme Ato ER 02.06 - Reducao Z DDMMAAAA
	cFile	:= cLocalPath + "Reducao Z " + StrTran( DTOC(dData),"/" ) + ".XML"
	LjGrvLog("GER_XML_PAF","Gerar Arquivo do Fisco da Redução Z")
	If File(cFile)
		FErase(cFile)
	EndIf
	
	nHandle := FCreate(cFile,FC_NORMAL)
		
	If nHandle > 0
		lGeraArquivo := .T.
		LjGrvLog("GER_XML_PAF","Arquivo de XML - Redução Z - Gerado na pasta")
	Else
		aRet := {}
		Aadd(aRet,{.F.,""})
		LjGrvLog("GER_XML_PAF","Arquivo de XML - Redução Z - Não Foi gerado")
	EndIf
EndIf

If lGeraArquivo
	LjGrvLog("GER_XML_PAF","Criação do Arquivo de Fisco da Redução Z")
	
	STFMessage("LPXFiscoRedZ1", "RUN", "Gerando arquivo de Reducao Z" ,{|| aConteudo := LPXPafXML("R",cKeySFI)  })
	STFShowMessage("LPXFiscoRedZ1")
	
	If aConteudo[1]
		FWRITE( nHandle, aConteudo[2], LEN( EncodeUTF8(aConteudo[2]) ) )
		FCLOSE( nHandle )
		
		LjGrvLog("GER_XML_PAF","Retorno da Criação do Arquivo de Fisco da Redução Z")
	
		If File(cFile)
			LjGrvLog("GER_XML_PAF","Arquivo de Fisco da Redução Z em [" + cFile + "]")
			If lPos
				STFMessage("LPXFiscoRedZ2", "ALERT", "Arquivo [" + cFile + "] Gerado com Sucesso!")
				STFShowMessage("STWFiscoRed2")
			Else
				If lHomolPaf
					MsgInfo("Arquivo [" + cFile + "] Gerado com Sucesso!","PAF-ECF")
				Else					
					LJRPLogProc("Arquivo [" + cFile + "] Gerado com Sucesso!","GER_XML_PAF")
				EndIf
			EndIf
			aRet := {}
			Aadd(aRet , {.T.,aConteudo[2]} )
			LjGrvLog("GER_XML_PAF","Arquivo Gerado com Sucesso",cFile)
		Else
			lMsgErro := .T.
			cMsgErro := STR0026 + cFile //"Não foi possível gerar o arquivo:"
		EndIf
	Else
		lMsgErro := .T.
		cMsgErro := "Arquivo de Redução Z não foi gerado. Não existem dados de SFI para essa estação (SLG)"
	EndIf
	
	If lMsgErro
		If lPos
			STFMessage("LPXFiscoRedZ3", "STOPPOPUP", cMsgErro)	 
			STFShowMessage("LPXFiscoRedZ3")
		Else
			MsgAlert(cMsgErro)
		EndIf
	
		LjGrvLog("GER_XML_PAF",cMsgErro)
		aRet := {}
		Aadd(aRet , {.F.,""} )
	EndIf
Else
	aRet := {}
	Aadd(aRet,{.F.,""})
EndIf

LWSPGerWSD( .T. , .T. )
LjGrvLog(Nil,"Final da função", aRet)

Return aRet

//-----------------------------------------------------------
/*/
{Protheus.doc} LPXFiscoEstMen()
	
Função para criação do arquivo de informações ao fisco
sobre o Estoque Mensal

@author  	Varejo
@version 	P11.8
@since   	10/11/2015
@return  	lRet  - função executada com sucesso
/*/
//-----------------------------------------------------------
Function LPXFiscoEstMen(lGeraArquivo , lPos		, dDataFinal , lHomol,;
						dDtRef		 , aVndProd , cFilSB1	 , lDelFile,;
						cNumCreden	)
Local cFile		:= ''
Local cNomeRET	:= ''
Local cNomeComp := ''
Local cPath		:= ''
Local cLocalPath:= ''
Local cXML		:= ''
Local cMsg		:= ''
Local cProcName := ProcName()
Local aConteudo	:= {}
Local aRet		:= {}
Local aProd		:= {}
Local nHandle	:= 0
Local lMsgErro	:= .F.
Local lArqCriado:= .F.
Local lArqEmUso := .F.
Local lMvLjPdvPa:= LjxBGetPaf()[2]

Default	lGeraArquivo:= .F.
Default lPos		:= .F.
Default dDataFinal	:= LastDay( Date() , 0)
Default lHomol		:= NIL
Default dDtRef		:= dDatabase
Default aVndProd	:= {} //Array de produtos vendidos no PDV - para diminuir o XML
Default cFilSB1		:= ""
Default lDelFile	:= .F.
Default cNumCreden	:= ""

LJRPLogProc("Inicio da Função de Arquivo ao Fisco de Estoque")

cNomeRET := AllTrim(cFilSB1) + "_Estoque Mensal " + ;
			StrZero( Month(dDtRef) ,2) + cValToChar(Year(dDtRef)) + ".XML" //Requisito LIX - Item 1 - ER 02.06
			
cFile := "Estoque Mensal " + StrZero( Month(dDtRef) ,2) +;
 			cValToChar(Year(dDtRef)) + ".XML" //Requisito LIX - Item 1 - ER 02.06

If lGeraArquivo .Or. !lMvLjPdvPa
	cMsg := "Geração do arquivo de Estoque"
	LJRPLogProc(cMsg)
	
	LJRPLogProc("Validação dos produtos que foram vendidos no mes")
	If ValType(aVndProd) <> "A" .Or. Len(aVndProd) == 0
		aVndProd := LJPItemEst(dDataFinal)
	EndIf
	LJRPLogProc("Retorno da validação dos produtos que foram vendidos no mes",,aVndProd)
	
	If ValType(lHomol) == "L"
		lHomolPaf := lHomol
		cMsg := " Setado variavel de homologação - [" + IIf(lHomolPaf,"S","N") + "]"
		LJRPLogProc(cMsg)
	EndIf
	
	If !lMvLjPdvPa .And. !IsBlind()
		STBFMGerPath( @cLocalPath )
		cLocalPath += PAF_DirXML + "\"
		//Estava dando erro quando tinha duas barras e não gerava o arquivo
		//portanto coloco aqui um ajuste para substituir 
		cLocalPath := StrTran(cLocalPath,"\\","\")
		cNomeComp	:= cLocalPath + cNomeRET
		lArqCriado	:= File(cNomeComp)
		If lArqCriado
			lArqEmUso	:= FT_FUSE(cNomeComp) == -1
			IIf(lArqEmUso, FT_FUse(), NIL)
		EndIf 
		If lArqCriado .And. lArqEmUso 
			cMsg	:= "Arquivo esta sendo gerado para essa filial. Não gerará deste PDV por ser da mesma filial"
			LJRPLogProc(cMsg)
			nHandle := -1			 
		Else
			If lArqCriado // Se o arquivo existir e não estiver em uso, permito um novo
				FErase(cNomeComp)
				LJRPLogProc("Arquivo [" + cNomeComp + "] não estava em uso - apagado e permitido criar um novo")
			EndIf
			nHandle := FCreate(cNomeComp)
		EndIf
	Else
		cNomeComp := LjxGetPath()[1] + cNomeRET
		lArqCriado	:= File(cNomeComp)		
		If lArqCriado
			lArqEmUso	:= FT_FUSE(cNomeComp) == -1
			IIf(lArqEmUso, FT_FUse(), NIL)
		EndIf
		If lArqCriado .And. lArqEmUso
			cMsg	:= "Arquivo esta sendo gerado para essa filial. Não gerará deste PDV por ser da mesma filial"
			LJRPLogProc(cMsg)
			nHandle := -1
		Else
			If lArqCriado // Se o arquivo existir e não estiver em uso, permito um novo		
				FT_FUse()		
				FErase(cNomeComp)
				LJRPLogProc("Arquivo [" + cNomeComp + "] não estava em uso - apagado e permitido criar um novo")
			EndIf
			nHandle := StbFunNme(@cNomeRET)
			cNomeComp := cNomeRET
		EndIf
	EndIf
	
	//É possível regerar o XML
	If nHandle > 0
		cMsg := "XML de Estoque a ser gerado [" + cNomeRET + "] com o Handle [" + cValToChar(nHandle) + "]"
		LJRPLogProc(cMsg)
		
		aConteudo := LPXPafXML("E","",cFilSB1,dDataFinal,aVndProd,cNumCreden)
		If aConteudo[1]
			FWRITE( nHandle, aConteudo[2], LEN( aConteudo[2] ) )
			FCLOSE( nHandle )
			Aadd(aRet,{.T.,aConteudo[2]})
			LJRPLogProc("Finalização da gravação do arquivo [" + cNomeRET + "]",cProcName,aRet)
			
			//Quando gera o arquivo via rotina STEstqXML, deve deletar para que 
			//caso de erro no PDV não interfira outros processos
			If lDelFile
				FErase(cNomeComp)
				LJRPLogProc("Arquivo [" + cNomeComp + "] - apagado com sucesso ",cProcName)
			EndIf
		Else
			lMsgErro := .T.			
		EndIf
	Else
		lMsgErro := .T.
	EndIf
	
	If lMsgErro
		If Empty(cMsg)
			LJRPLogProc("Arquivo não gerado",cProcName)
		Else
			LJRPLogProc(cMsg,cProcName)
		EndIf
		AAdd(aRet,{.F.,""})
	EndIf
EndIf

If !lGeraArquivo

	If lMvLjPdvPa
		
		LWSPGerWSD( .T. , .T. )
	
		LJRPLogProc("Arquivo de Estoque Mensal - busca das informações",cProcName)
		
		cFilSB1		:= FwxFilial("SB1")
		cNumCreden	:= AllTrim(SubStr(SuperGetMV("MV_LJCRPAF",,""),1,15)) 
		
		If lPos
			STFMessage(cProcName + "1", "RUN", "Gerando arquivo de Estoque",;
					{|| STBRemoteExecute("LPXFiscoEstMen",;
					{ .T.,lPos,dDataFinal,lHomolPaf,dDtRef,aProd,cFilSB1,,cNumCreden}, Nil,.F.,@aRet) } )
			STFShowMessage(cProcName +"1")
		Else
			LjMsgRun("Gerando arquivo de Estoque",,{ || ;
					aRet := FR271CMyCall( "LPXFiscoEstMen",{"SB1","SB0","SB2","SA1"},.T.,;
							lPos,dDataFinal,lHomolPaf,dDtRef,aProd,cFilSB1,,cNumCreden)})
		EndIf

		STFMessage(cProcName +"2", "RUN", "Efetuando consulta na retaguarda", {|| cPath := STBFMPathSrv(lPos) } )
		STFShowMessage(cProcName +"2")
		STBFMGerPath( @cLocalPath )
		cLocalPath += PAF_DirXML + "\"
		
		//Estava dando erro quando tinha duas barras e não gerava o arquivo
		//portanto coloco aqui um ajuste para substituir 
		cLocalPath := StrTran(cLocalPath,"\\","\")
		
		cNomeRET := AllTrim(cFilSB1) + "_Estoque Mensal " + ;
					StrZero( Month(dDtRef) ,2) + cValToChar(Year(dDtRef)) + ".XML" //Requisito LIX - Item 1 - ER 02.06
		
		If ValType(aRet) == "A" .And. Len(aRet) > 0 .And. ValType(aRet[1]) == "A"  .And. aRet[1][1]
			STFMessage(cProcName +"3", "RUN", "Importando arquivo...", ;
						{|| STBFMGetFile( cPath, cNomeRET , cLocalPath , cFile , .T. ,lPos) } )
			STFShowMessage(cProcName +"3")
			
			If File(cLocalPath + cFile)
				cMsg := "Arquivo de Estoque em [" + cLocalPath + cFile + "] - Gerado com sucesso! "
				LJRPLogProc(cMsg)
				MsgInfo(cMsg,"XML Estoque")
				
				cXML := aRet[1][2]
				aRet := {}
				Aadd(aRet , {.T.,cXML} )
			Else
				lMsgErro := .T.
			EndIf
		Else
			lMsgErro := .T.
		EndIf
	EndIf
EndIf

If lMsgErro 
	aRet := {}
	Aadd(aRet , { .F. , "" } )
	LJRPLogProc(STR0026 + cLocalPath + cFile,cProcName)
	
	If !IsBlind()
		If lPos
			STFMessage(cProcName +"5", "STOPPOPUP", STR0026 + cLocalPath + cFile)	 //"Não foi possível gerar o arquivo:"
			STFShowMessage(cProcName +"5")
		Else
			MsgStop(STR0026 + cLocalPath + cFile)
		EndIf
	EndIf
EndIf

LWSPGerWSD( .T. , .T. )
LJRPLogProc("Final da função LPXFiscoEstMen",,aRet)
Return aRet

//----------------------------------------------------
/*/
{Protheus.doc}LPXFAjXML
Ajusta e envia o XML via WSDL

@Param1 cFile - nome do arquivo
@author  	Varejo
@version 	P11.8
@since   	15/05/2017
@return  	aRet, array, 3 posições : {lógico,string,string} -> 
				{ função executada com sucesso?, XML Envio , XML Retorno }  
@obs     
@sample
/*/
//--------------------------------------------------
Function LPXAjXML(cTpEnvio,cXML,cFI_PDV)
Local aRet 		:= { .F. , Nil , ""}
Local aXML		:= {}
Local aGrvRet	:= {}
Local oWsRecepcao:= NIL
Local lConWSDL	:= .T.
Local lRet		:= .T.		// indica se XMLParser foi executado com sucesso
Local lMvLjPdvPa:= LjxBGetPaf()[2]
Local cAux		:= ""
Local cPath		:= ""
Local cArqPath	:= ""
Local cDataSFI	:= ""
Local cDtArquivo:= ""
Local cRetXML	:= ""
Local cNmArqRsp := ""
Local cWarning	:= ""
Local XMLEnv	:= ""
Local XMLSem64	:= ""
Local cZip		:= ""
Local cPDVSFI	:= ""
Local cFileName := ""
Local cLogID	:= "ENVIO_XML_PAF"
Local cSttsXML	:= ""
Local nHdlXMLRet:= 0
Local nArqZIP	:= 0
Local nX		:= 0

Static lStatClXml := NIL

Default cFI_PDV	:= ""

LjGrvLog(cLogID,"Inicio Envio - pela função LPXAjXML")

lRet := LPXRetDatX(@cPath , @cXML , @cTpEnvio , @cDtArquivo , @cDataSFI)

//Valido o conteudo do XML, caso necessário recriar da maneira correta
If lRet
	If cTpEnvio == "R"
		cFileName:= cPath + PAF_DirXML + "\" + "Reducao Z " + cDtArquivo + ".XML"
	ElseIf cTpEnvio == "E"
		cDtArquivo	:= Substr(cDtArquivo,3,Len(cDtArquivo)) //formato: MMAAAA conforme Ato Cotepe ER 02.06
		cFileName	:= cPath + PAF_DirXML + "\" + "Estoque Mensal " + cDtArquivo + ".XML"
	EndIf
	
	cArqPath := cPath + PAF_DirXML + "\"
	
	//Estava dando erro quando tinha duas barras e não gerava o arquivo
	//portanto coloco aqui um ajuste para substituir 
	cFileName := StrTran(cFileName,"\\","\")
	cArqPath := StrTran(cArqPath,"\\","\")
		
	nX := FCreate(cFileName)
	If nX > 0
		FWrite(nX,cXML)
		FClose(nX)

		XMLEnv	:= Substr(cFileName,1,Len(cFileName)-4) + ".zip"
		cZip	:= XMLEnv
		LjGrvLog(cLogID,"Arquivo a ser enviado [" + XMLEnv + "]")
		
		lConWSDL := .T.
		oWsRecepcao := LWSPGerWSD(.F.,lConWSDL)
		lRet := LWSPCnsStt(@oWsRecepcao,lConWSDL)
		If !lRet
			lConWSDL:= .F.
			lRet := LWSPCnsStt(@oWsRecepcao,lConWSDL)
		EndIf
		
		If !lRet
			LWSPErrWSD(oWsRecepcao,lConWSDL)
		EndIf
	Else
		lRet := .F.
	EndIf
EndIf

If lRet
	//If GetBuild() < "7.00.170117A-20190212"
		FZip(XMLEnv,{ cFileName }, cArqPath)
		
		If File(XMLEnv)
			nHdlXMLRet := FOpen(XMLEnv,2)
			If nHdlXMLRet > 0
				nArqZIP	:= FSeek(nHdlXMLRet,0,2)//Final de Arquivo
				XMLEnv	:= Space(nArqZIP)
				FSeek(nHdlXMLRet,0,0) //Começo de arquivo
				FRead(nHdlXMLRet,@XMLEnv,nArqZIP)
				FClose(nHdlXMLRet)
				XMLSem64 := XMLEnv
				XMLEnv := Encode64(XMLEnv)
				LJRPLogProc("Arquivo .ZIP Encodado",cLogID)
			Else
				LJRPLogProc("Arquivo zipado não pode ser lido",cLogID)
				lRet := .F.
			EndIf
		Else
			cAux := 'Arquivo [' + cFileName +'] não zipado. Verifique!'
			MsgAlert(cAux,"PAF-ECF")
			LJRPLogProc(cAux,cLogID)
			lRet := .F.
		EndIf
	
	//metodo comentado pois o arquivo ZIP retornado é diferente 
	//e da erro no WebService: "Arquivo .ZIP Invalido"
	/*Else
		If File(cFileName)
			XMLEnv := Encode64(,cFileName,.T.,.F.)
			LjGrvLog( NIL, "Arquivo XML", XMLEnv)
		Else
			cAux := 'Arquivo [' + cFileName +'] não zipado. Verifique!'
			Alert(cAux)
			LjGrvLog( Nil, cAux)
			lRet := .F.
		EndIf
	EndIf*/
EndIf

If lRet
	LJRPLogProc("Antes do envio do XML")
	LJRPLogProc("Tentativa 1 de envio do XML")
	lRet	:= LJPXTranXM(@XMLEnv,@oWsRecepcao,@lConWSDL,cTpEnvio)
	cRetXML := LPXRtTrArq(@lConWSDL, @oWsRecepcao)
	aXML	:= LPXLeReXML(cRetXML)
	LJRPLogProc("Retorno do envio do XML",,cRetXML)
	
	//Se retornar como Zip Invalido, tento enviar sem efetuar encode64
	If	AllTrim(LjRmvChEs(aXML[3])) == Upper("Arquivo ZIP invalido") .Or.;
		AllTrim(LjRmvChEs(aXML[4])) == Upper("Arquivo ZIP invalido")
		
		LJRPLogProc("O WS Retornou erro de Arquivo ZIP Invalido portanto " +;
					"sera efetuado envio do arquivo diretamente .ZIP")
		
		LJRPLogProc("Tentativa 2 de envio do XML")
		lRet	:= LJPXTranXM(@cZip,@oWsRecepcao,@lConWSDL,cTpEnvio)
		cRetXML := LPXRtTrArq(@lConWSDL, @oWsRecepcao)
		aXML	:= LPXLeReXML(cRetXML)
		LJRPLogProc("Retorno do envio do arquivo diretamente .ZIP", ,cRetXML)
		
		//Se retornar como Zip Invalido, tento enviar sem efetuar encode64
		If	AllTrim(LjRmvChEs(aXML[3])) == Upper("Arquivo ZIP invalido") .Or.;
			AllTrim(LjRmvChEs(aXML[4])) == Upper("Arquivo ZIP invalido")
				
			LJRPLogProc("O WS Retornou erro de Arquivo ZIP Invalido portanto " +;
						"sera efetuado envio do arquivo sem encodar")
			
			LJRPLogProc("Tentativa 3 de envio do XML")
			lRet	:= LJPXTranXM(@XMLSem64,@oWsRecepcao,@lConWSDL,cTpEnvio)
			cRetXML := LPXRtTrArq(@lConWSDL, @oWsRecepcao)
			aXML	:= LPXLeReXML(cRetXML)
			LJRPLogProc("Retorno do envio do arquivo sem encodar", ,cRetXML)
		EndIf
	EndIf
EndIf

//Independente do retorno , mando deletar tudo o ZIP e o XML
If FErase(cZip) <> -1
	LjGrvLog( cLogID,"Zip deletado com sucesso - [" + cZip + "]")
	If !isBlind()
	 	If ValType(lStatClXml) <> "L"
	 		lStatClXml := (GetPvProfString("PAF-ECF","cleanxml","0",cPath+"SIGALOJA.INI") == "1")
	 		LjGrvLog( cLogID, "Setado a limpeza do XML do PAF ?", lStatClXml)
	 	EndIf
	 	
	 	If lStatClXml
	 		FErase(cFileName)
	 	EndIf
	EndIf
ElseIf File(cZip)
	LjGrvLog( cLogID, "Erro ao tentar eliminar o arquivo - ["+ cZip +"] - nº " + AllTrim(STR(FERROR())))
	Alert("Erro ao tentar eliminar o arquivo - ["+ cZip +"] ")
EndIf

If lRet
	//Geração do arquivo na pasta de retorno
	If ! Empty(cRetXML)

		If cTpEnvio == "R"
			cPath	 += PAF_DirRedZ + '\'
			cNmArqRsp:= "RespRedZ" + cDtArquivo + ".XML"
		ElseIf cTpEnvio == "E"
			cPath += PAF_DirStck + '\'
			cNmArqRsp:= "RespStck" + cDtArquivo + ".XML"
		EndIf
		
		//Estava dando erro quando tinha duas barras e não gerava o arquivo
		//portanto coloco aqui um ajuste para substituir 
		cPath := StrTran(cPath,"\\","\")
		
		If File(cPath + cNmArqRsp)
			FErase(cPath + cNmArqRsp)
		EndIf

		nHdlXMLRet := FCreate(cPath + cNmArqRsp)
		If nHdlXMLRet > 0
			FWrite(nHdlXMLRet,cRetXML)
			FCLOSE( nHdlXMLRet )
			LjGrvLog( cLogID , "Arquivo de retorno do XML gerado em [" + cNmArqRsp + "]")
					
			/*Usado a função XMLParser pois o TXMLManager não retorna a parte do XML que precisa ser lida*/
			aXML := LPXLeReXML(cRetXML,NIL)
			LjGrvLog( cLogID, "Retorno do XML enviado a SEFAZ - aXML", aXML)
			
			cSttsXML := "N"
			If	("NÃO GERADO" $ Upper(aXML[1])) .Or. ;
				(cSttWSNGER $ Upper(LjRmvChEs(aXML[2]))) .Or.;
				(cSttWSNGER $ Upper(LjRmvChEs(aXML[3]))) .Or.;
				(cSttWSNGER $ Upper(LjRmvChEs(aXML[4]))) .Or.;
				(cSttWSRECN $ Upper(aXML[1])) .Or. ;
				(cSttWSRECN $ Upper(LjRmvChEs(aXML[2]))) .Or.;
				(cSttWSRECN $ Upper(LjRmvChEs(aXML[3]))) .Or.;
				(cSttWSRECN $ Upper(LjRmvChEs(aXML[4])))
				
				cSttsXML := "N" //Erro na geração deve tentar novamente
				lRet := .F.
				
			ElseIf (cSttWSAGUA $ Upper(LjRmvChEs(aXML[2]))) .Or. ;
					(cSttWSAGUA $ Upper(LjRmvChEs(aXML[3]))) .Or. ;
					(cSttWSAGUA $ Upper(LjRmvChEs(aXML[4])))
				
				cSttsXML := "A" //Aguardando validação do WS
			
			ElseIf (cSttWSSUCE $ Upper(LjRmvChEs(aXML[2]))) .Or. ;
					(cSttWSSUCE $ Upper(LjRmvChEs(aXML[3]))) .Or.;
					(cSttWSSUCE $ Upper(LjRmvChEs(aXML[4])))
				
				cSttsXML := "S" //Arquivo recebido com sucesso
			
			ElseIf  (cSttWSERRO $ Upper(LjRmvChEs(aXML[2]))) .Or. ;
					(cSttWSERRO $ Upper(LjRmvChEs(aXML[3]))) .Or. ;
					(cSttWSERRO $ Upper(LjRmvChEs(aXML[4])))
				
				cSttsXML := "E"	
			EndIf
			
			If lRet
				//Grava OK somente se o retorno do WebService estiver correto
				If cTpEnvio == "R"
					IF cSttsXML == "S"
						cWarning := "Arquivo com Informações da Redução Z do PAF-ECF " + ;
							 		"transmitido com sucesso para a SEFAZ." + PULALINHA + "Recibo - [" + aXML[1] + "]"
					ElseIf cSttsXML == "A"
						cWarning := "Arquivo com Informações da Redução Z do PAF-ECF " + ;
							 		"transmitido e em aguardo na SEFAZ." + PULALINHA + "Recibo - [" + aXML[1] + "]"
					Else
						cWarning := "Retorno do Web Service" + PULALINHA
						cWarning += "Mensagem Genérica: " + aXML[4] + PULALINHA
						cWarning += "Mensagem Completa: " + aXML[3]
					EndIf
					
					If !Empty(cFI_PDV) //Pois pode ser um outro PDV na SFI não só o do PDV em questão
						cPDVSFI := cFI_PDV
						
					ElseIf lMvLjPdvPa
						cPDVSFI := PadR(AllTrim(IIF(lTotvsPdv,STFGetStat("PDV"),LJGetStation("PDV"))),TamSX3("LG_PDV")[1])
					Else
						cPDVSFI := SFI->FI_PDV
					EndIf
					
					STRedXML("R",xFilial("SFI") + cDataSFI + cPDVSFI,{cSttsXML,cRetXML})
				Else
					IF cSttsXML == "S"
						cWarning := "Arquivo com Informações do Estoque Mensal do" +;
							 	 " Estabelecimento transmitido com sucesso para a SEFAZ." + PULALINHA + "Recibo - [" + aXML[1] + "]"
					ElseIf cSttsXML == "A"
						cWarning := "Arquivo com Informações do Estoque Mensal do" +;
							 	 " Estabelecimento transmitido e em aguardo na SEFAZ." + PULALINHA + "Recibo - [" + aXML[1] + "]"
					Else
						cWarning := "Retorno do Web Service" + PULALINHA
						cWarning += "Mensagem Genérica: " + aXML[4] + PULALINHA
						cWarning += "Mensagem Completa: " + aXML[3]
					EndIf
					
					//Aqui a data que vem refere-se ao Data de referencia mais 1
					//portanto deve-se subtrair pois o estoque de referencia é diferente
					//da data do nome do arquivo
					//Ex.: Nome do Arquivo: 032020 (MMAAAA) / Data de Referencia: Mes do arquivo - 1 => 01032020 -1 = 29022020
					//E a data do arquivo que esta na MDZ é a data de referencia: 29022020 
					STEstqXML(lMvLjPdvPa,"R",,{cSttsXML,cRetXML},StoD(cDataSFI)-1)
				EndIf
				
				MsgInfo(cWarning,"PAF-ECF")
				LJRPLogProc(cWarning,cLogID)
				
				If lMvLjPdvPa
					If lTotvsPdv
						STFMessage(cLogID +"1", "RUN", "Gerando Informações na Retaguarda", ;
										{ || STBRemoteExecute("STBS2RPAF", { cRetXML,cNmArqRsp },Nil,.F.,@aGrvRet) } )
					Else
						STFMessage(cLogID +"1", "RUN", "Gerando Informações na Retaguarda", ;
										{ || aGrvRet := FR271CMyCall( "STBS2RPAF",Nil,cRetXML,cNmArqRsp)} )
					EndIf
					
					STFShowMessage(cLogID +"1")
					
					If ValType(aGrvRet) == "A" .And. Len(aGrvRet) > 0 .And. ValType(aGrvRet[1]) == "A" .And. aGrvRet[1][1]
						cWarning := "Arquivo gravado com sucesso na retaguarda - XML" 
					Else
						cWarning := "Erro na criação do XML na retaguarda"
					EndIf
					
					LJRPLogProc(cWarning,cLogID)
					
				EndIf
			EndIf
		Else
			cWarning := "Não Foi Possível Gerar Arquivo de retorno do envio do XML à SEFAZ. Verifique!"
			LjGrvLog( cLogID , cWarning)
			Alert(cWarning)
		EndIf
	EndIf
EndIf

LWSPGerWSD(.T.,lConWSDL)
aRet[1] := lRet
aRet[2] := cXML
aRet[3] := cRetXML

LjGrvLog(cLogID,"Final do Envio", aRet)

Return aRet

//----------------------------------------------------
/*/
{Protheus.doc}LWSPErrWSD
Gera mensagens de erro do WSDL

@Param		nenhum
@author  	julio.nery
@version 	P12
@since   	23/05/2019
@return  	NIL 
/*/
//--------------------------------------------------
Function LWSPErrWSD(oWsdl,lConWSDL)
Local cMSG := ""

If lConWSDL
	cMSG := "Erro: " + oWsdl:cError 
Else
	cMSG := AllTrim(GetWscError(3))
	If Empty( cMSG )
		cMSG := AllTrim(GetWscError(1))
	EndIf
EndIf

If !Empty(cMSG)
	LPXSMsgErr(cMSG)
EndIf

Return NIL

//---------------------------------------------------
/*/
{Protheus.doc}LPXSMsgErr
Emite todas as mensagens de erro do processo

@Param		cMsg, caracter, conteudo da mensagem
@Param		lEmite, logico, se emite uma caixa 
					contendo as msgs de erros carregadas 
@author  	julio.nery
@version 	P12
@since   	31/05/2019
@return  	NIL 
/*/
//--------------------------------------------------
Function LPXSMsgErr(cMsg,lEmite)

Default lEmite	:= .F.

Static cLpxMSGErr := ""

If !Empty(cMsg)
	cLpxMSGErr += cMsg + PULALINHA
	LjGrvLog( "LPXSMsgErr" , cMSG)
EndIf

If lEmite .And. !Empty(cLpxMSGErr)
	STPosMSG( "Erros Processo XML PAF-ECF",cLpxMSGErr, .T., .F., .F.)
	cLpxMSGErr := ""
EndIf

Return cLpxMSGErr

//----------------------------------------------------
/*/
{Protheus.doc}LWSPExcWSD
Envia os comandos WSDL

@Param		nenhum
@author  	julio.nery
@version 	P12
@since   	23/05/2019
@return  	NIL 
/*/
//--------------------------------------------------
Function LWSPExcWSD(oWsdl,lConWSDL)
Local lRet := .F.

If lConWSDL
	LjGrvLog( "LWSPExcWSD", oWsdl:GetSoapMsg() ) //Loga o comando q será enviado
	lRet := oWsdl:SendSoapMsg() // Envia a mensagem SOAP ao servidor
			
	If lRet
		LjGrvLog( "LWSPExcWSD", oWsdl:GetSoapResponse() ) // Pega a mensagem de resposta
	Else
		LWSPErrWSD(oWsdl,lConWSDL)
	EndIf
Else
	lRet := .T. //Quando via client não tem comando de execução
EndIf

Return lRet

//----------------------------------------------------
/*/
{Protheus.doc}LWSPGerWSD
Geração do objeto oWSDL

@Param		lSetOwsdl, logico, zera o objeto WSDL
@author  	julio.nery
@version 	P12
@since   	23/05/2019
@return  	oWSDL , objeto , objeto contendo o metodos do WSDL 
/*/
//--------------------------------------------------
Function LWSPGerWSD(lSetOwsdl,lConWSDL)
Local aOps	:= {}
Local cPAFWs:= ""
Local lRet	:= .F.

Default lSetOwsdl := .F.

Static oMstrWSdl := NIL

If oMstrWSdl == NIL

	cPAFWs:= SuperGetMV("MV_LJPAFWS",,"")
	
	If lConWSDL
		oMstrWSdl := TWsdlManager():New()
		oMstrWSdl:nTimeout := 120
		oMstrWSdl:bNoCheckPeerCert := .T. // Desabilita o check de CAs
		lRet  := oMstrWSdl:ParseURL( cPAFWs )
		
		If lRet
			aOps := oMstrWSdl:ListOperations()
			LjGrvLog( "LWSPGerWSD", " Lista de Operações do WS do PAF [" + cPAFWs + "]", aOps)
			If Len( aOps ) == 0
			    lRet := .F.
			EndIf
		EndIf
	Else
		oMstrWSdl := WSBlocoX():New()
		oMstrWSdl:_URL := cPAFWs
		lRet := .T.
	EndIf
	
	If !lRet //Valida todos os retornos
		LWSPErrWSD(oMstrWSdl,lConWSDL)
		lSetOwsdl := .T.
	EndIf
EndIf

If lSetOwsdl
	oMstrWSdl := NIL
EndIf

Return oMstrWSdl

//----------------------------------------------------
/*/
{Protheus.doc}LWSPEnvWSD
Ajusta e envia o XML via WSDL

@Param
@author  	Varejo
@version 	P12
@since   	01/07/2019
@return  	lRet, lógico, executada com sucesso? 
@obs     
@sample
/*/
//--------------------------------------------------
Function LWSPEnvWSD( XMLEnv	, oWsRecepcao , lConWSDL)
Local cMetodo	:= "TransmitirArquivo"
Local cMSG		:= ""
Local cAux		:= ""
Local lRet		:= .T.

If oWsRecepcao == NIL
	oWsRecepcao := LWSPGerWSD(.F.,lConWSDL)
EndIf

If lRet .And. (oWsRecepcao <> NIL)
	If lConWSDL
		lRet := oWsRecepcao:SetOperation( cMetodo )
	EndIf
	
	If lRet
		If lConWSDL
			//Setando os parametros
			cAux := _NoTags(XMLEnv) //Orientação da TEC para ajustar o xml
			lRet := oWsRecepcao:SetValue( 0, cAux )
			cMSG := 'Método ' + cMetodo + ' - Retorno [' + IIf(lRet,"S","N") + ']'
		Else
			lRet := oWsRecepcao:TransmitirArquivo(XMLEnv)
			If ValType(lRet) <> "L"
				lRet := .F.
				cMSG := " Erro de WebService na execução do metodo " + cMetodo + " - WebService SEFAZ"
			EndIf
		EndIf
		
		If !Empty(AllTrim(cMSG))			
			LJRPLogProc(cMSG,"LWSPEnvWSD")
		EndIf
		
		If lRet
			lRet := LWSPExcWSD(@oWsRecepcao,lConWSDL)
		Else
			LWSPErrWSD(@oWsRecepcao,lConWSDL)
		EndIf
	Else
		LWSPErrWSD(@oWsRecepcao,lConWSDL)
	EndIf
Else
	lRet := .F.
EndIf
  
Return lRet

//----------------------------------------------------
/*/
{Protheus.doc} LWSPConRec
Consultar Recibo

@Param		oWsdl, objeto, contem o Servico WSDL
@param		cRecibo, caracter, numero do recibo 
@param		lConWSDL, lógico, é conexão WSDL ?
@author  	julio.nery
@version 	P12
@since   	27/05/2019
@return  	lRet , lógico , validação ok ? 
/*/
//--------------------------------------------------
Function LWSPConRec(oWsdl,cRecibo,lConWSDL)
Local lRet		:= .T.
Local lMvLjPdvPa:= LjxBGetPaf()[2]
Local cMetodo	:= "ConsultarProcessamentoArquivo"
Local cMSG		:= ""
Local cAux		:= ""
Local cXML		:= ""
Local aXMLRet	:= {}

Default oWsdl	:= NIL

If ValType(lConWSDL) <> "L"
	lConWSDL := .T.
	oWsdl := LWSPGerWSD(.F.,lConWSDL)
	lRet := LWSPCnsStt(@oWsdl,lConWSDL)
	If !lRet
		lConWSDL:= .F.
		oWsdl:= NIL
		LWSPGerWSD(.T.,lConWSDL)
		lRet := LWSPCnsStt(@oWsdl,lConWSDL)
	EndIf 
EndIf

cXML := '<?xml version="1.0" encoding="utf-8"?>'
cXML += '<Manutencao Versao="1.0">'
cXML += '<Mensagem>'
cXML += '<Recibo>' + EncodeUTF8(Lower(cRecibo)) + '</Recibo>' //Recibo deve ser minusculo
cXML += '</Mensagem>'
aXMLRet := LPXXmlAss(!lMvLjPdvPa, lTotvsPdv ,'</Manutencao>',cXML,cEmpAnt,cFilAnt)
lRet := aXMLRet[1][1] 

If lRet
	cXML += aXMLRet[1][2]
	cXML += '</Manutencao>'
EndIf

If lRet .And. oWsdl == NIL
	oWsdl :=  LWSPGerWSD(.F.,lConWSDL)
EndIf

If lRet .And. oWsdl <> NIL
	If lConWSDL
		lRet := oWsdl:SetOperation( cMetodo )
	EndIf
	
	If lRet
		
		If lConWSDL
			cAux := _NoTags(cXML) //Orientação da TEC para ajustar o xml
			oWsdl:SetValue(0,cAux)
			lRet := LWSPExcWSD(oWsdl,lConWSDL)
			cMSG := 'Metodo ' + cMetodo + ' - Recibo [' + cRecibo +']  - Retorno [' + IIf(lRet,"S","N") + ']'
		Else
			lRet := oWsdl:ConsultarProcessamentoArquivo(cXML)
			If ValType(lRet) <> "L"
				lRet := .F.
				cMSG := " Erro de WebService na execução do metodo "+ cMetodo +" - WebService SEFAZ"
			EndIf
		EndIf
		
		If !Empty(cMSG)
			LJRPLogProc(cMSG)
		EndIf
	EndIf

	If !lRet
		oWsdl := LWSPGerWSD(.T.,lConWSDL)
	EndIf
EndIf

Return lRet

//----------------------------------------------------
/*/
{Protheus.doc} LWSPConPAF
Consultar Situacao do PAF-ECF na SEFAZ

@Param		nenhum
@author  	julio.nery
@version 	P12
@since   	27/05/2019
@return  	lRet , lógico , validação ok ? 
/*/
//--------------------------------------------------
Function LWSPConPAF(oWsdl,cXML,lConWSDL)
Local lRet		:= .T.
Local cMetodo	:= "ConsultarPendenciasDesenvolvedorPafEcf"
Local cMSG		:= ""
Local cAux		:= ""

Default oWsdl	:= NIL

If oWsdl == NIL
	oWsdl :=  LWSPGerWSD(.F.,lConWSDL)
EndIf

If lRet .And. (oWsdl <> NIL)
	If lConWSDL
		lRet := oWsdl:SetOperation( cMetodo )
	EndIf
	
	If lRet		
		If lConWSDL
			cAux := _NoTags(cXML) //Orientação da TEC para ajustar o xml
			oWsdl:SetValue(0,cAux)
			lRet := LWSPExcWSD(oWsdl,lConWSDL)
			cMSG := 'Retorno do envio de XML com _NoTags - Retorno [' + IIf(lRet,"S","N") + ']'
		Else
			lRet := oWsdl:ConsultarPendenciasDesenvolvedorPafEcf(cXML)
			If ValType(lRet) <> "L"
				lRet := .F.
				cMSG := " Erro de WebService na execução do metodo "+ cMetodo +" - WebService SEFAZ"
			EndIf
		EndIf
		
		If !Empty(cMSG)
			LJRPLogProc(cMSG)
		EndIf
	EndIf

	If !lRet
		oWsdl := LWSPGerWSD(.T.,lConWSDL)
	EndIf
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}LPXRepXML
Efetua o reprocessamento do XML

@param	 	cTipo : String, pode ser (R)edução Z ou (E)stoque
@author  	Varejo
@version 	P11-P12
@since   	20/09/2017
@return  	lRet  - função executada com sucesso 
/*/
//--------------------------------------------------------
Function LPXRepXML(	oXML	, oWsRecepcao	, cTipoEnv	, lConWSDL,;
 					nTry	, lPergunta)
Local lRet		:= .T.
Local aRetXML	:= {}
Local nVezes	:= 1
Local dDtFinal	:= CTOD("")
Local dDtRef	:= CTOD("")
Local lMvLjPdvPa:= LjxBGetPaf()[2]
Local cPDV		:= ""

Default nTry	:= 3
Default lPergunta := .T.

If (oXML <> NIL) .And. ;
	( !lPergunta .Or. (lPergunta .And. MsgYesNo("XML gerado possui inconsistências, deseja gerar novamente?","XML PAF-ECF")))
	
	LPXRetDatX( NIL , "" , cTipoEnv , NIL , NIL , @dDtFinal , oXML)

	If lConWSDL
		oWsRecepcao := LWSPGerWSD(.T.,lConWSDL)
		oWsRecepcao := LWSPGerWSD(.F.,lConWSDL)
	Else
		oWsRecepcao:Reset()
	EndIf
	
	//Tento recriar e validar por 3 vezes o xml
	While nVezes <= nTry
		LjGrvLog(NIL,"XML com Erro - será gerado novamente - Tentativa numero [" + cValToChar(nVezes) + "]")
		
		If cTipoEnv == "R"
			 
			If lMvLjPdvPa
				cPDV := IIF(lTotvsPDV,STFGetStat("PDV"),LJGetStation("PDV"))
			Else
				cPDV := SFI->FI_PDV
			EndIf
			
			aRetXML := LPXFiscoRedZ(lTotvsPDV,xFilial("SFI") + DTOS(dDtFinal) + cPDV , dDtFinal)
			
		ElseIf cTipoEnv == "E"
			dDtRef	:= dDtFinal //A data de referencia se trata do mes do estoque mais 1
			//precisa voltar um dia pois sera regerado o XML e a data que retorna é para o 
			//nome do arquivo que tem que ser referir ao proximo mes da data de pesquisa
			dDtFinal:= (dDtFinal-1)
			aRetXML	:= LPXFiscoEstMen(	.F.		,lTotvsPDV		,dDtFinal			,/*lHomolPaf*/,;
										dDtRef	,/*ArrayProd*/	,FwxFilial("SB1")	, /*lDelFile*/,;
										/*cNumCreden*/)
		EndIf
		
		lRet := aRetXML[1][1]
		If lRet
			LJRPLogProc("XML recriado com sucesso",,aRetXML[1][2])
			Exit
		Else
			nVezes++
		EndIf
	End
Else
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}LPXPafXML 
Geração do XML do PAF

@param1 	cTipo : String, pode ser (R)edução Z ou (E)stoque
@param2		cKeyRedz: String, chave da SFI do PDV
@param3		cKeyStck: String, chave para busca dos produtos o xFilial("SB1")
@param4		dData: Data, data do estoque atual
@author  	Varejo
@version 	P12
@since   	10/05/2017
@return  	lRet  - função executada com sucesso 
/*/
//--------------------------------------------------------
Function LPXPafXML(	cTipo	, cKeyRedz	, cKeyStck	, dData	,;
					aVndProd, cNumCreden)
Local cUTFXml	:= '<?xml version="1.0" encoding="utf-8"?>'
Local cXML		:= ""
Local cTagTipo	:= ""
Local cAux		:= ""
Local lXmlOK	:= .F.
Local aRet		:= {.F.,""}
Local aXMLRet	:= {}
Local nRecnoSFI	:= 0
Local lMvLjPdvPa:= LjxBGetPaf()[2]

Default aVndProd	:= {}
Default cNumCreden	:= ""

LJRPLogProc("Inicio da função LPXPafXML")

cXML := cUTFXml
If cTipo == "R"
	cTagTipo := "ReducaoZ"
ElseIf cTipo == "E"
	cTagTipo := "Estoque"
EndIf

cXML += '<' + cTagTipo + ' Versao="1.0">'
cXML += "<Mensagem>"
cXML += LJXXmlCab(cNumCreden)

If cTipo == "R"
	cAux := LJXXmlCRZ(cKeyRedz, @nRecnoSFI)
	If !Empty(cAux)
		cXML	+= cAux
		lXmlOK	:= .T.
	EndIf
	cTagTipo := "</ReducaoZ>"
ElseIf cTipo == "E"
	LJRPLogProc("Novo modo de geração do Estoque")
	cAux += LJXXml2CSt(dData,cKeyStck,aVndProd)
	
	If !Empty(cAux)
		cXML	+= cAux
		lXmlOK	:= .T.
	EndIf
	cTagTipo := "</Estoque>"
EndIf

cXML += "</Mensagem>"
aXMLRet := LPXXmlAss(!lMvLjPdvPa, lTotvsPdv ,cTagTipo,cXML,cEmpAnt,cFilAnt) 
If aXMLRet[1][1]
	cXML += aXMLRet[1][2]
Else
	LJRPLogProc("Problemas na assinatura do arquivo XML - Arquivo XML será gerado sem assinatura")
EndIf
cXML += cTagTipo

aRet[1] := lXmlOK
aRet[2] := cXML

//Gravação do campo de controle na Redução Z (SFI) ou Estoque(MDZ)
If lXmlOK
	If cTipo == "R" .And. nRecnoSFi > 0
		STRedXML("E",cKeyRedz,{"N",cXML},dData)
	EndIf
	
	If cTipo == "E" //Aqui está na retaguarda
		STEstqXML(.F.,"E",,{"N",cXML},dData)
	EndIf
EndIf

LJRPLogProc("Final da função LPXPafXML")

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc}LPXXmlAss
Assinatura do XML conforme especificação do PAF 

@author  	Varejo
@version 	P12
@since   	10/05/2017
@return  	cRet , String, assinatura 
/*/
//--------------------------------------------------------
Function LPXXmlAss(lRetaguarda	,	lTotvsPDV	,	cTagFinal	,	cConteudo	,;
					cEmpPdv		,	cFilPdv		)
Local aRet		:= {}
Local cCertIdent:= ""
Local lGerado 	:= .F.
Local cAssign	:= ""
Local cMsg		:= ""

Default lRetaguarda	:= .F.
Default cEmpPdv		:= ""
Default cFilPdv		:= ""

LJRPLogProc("Inicio de LPXXmlAss")

If lRetaguarda
	LjPreparaWs(cEmpPdv,cFilPdv)
	cCertIdent := ""
	lGerado := STBPRetEnt(@cCertIdent,.T.)
		
	If lGerado
		aRet	:= LPXRtAssXML(cTagFinal,cConteudo,cCertIdent)
		lGerado := aRet[1][1]
		cAssign := aRet[1][2]
		
		If !lGerado
			cMsg := aRet[1][3]
		EndIf
	Else
		cMsg := "Arquivo XML sera gerado sem assinatura pois houve problema no acesso às chaves."+;
				" Verifique os arquivos .PEM da pasta 'Certs' dentro da 'Protheus Data' deste ambiente"
		LJRPLogProc(cMsg)
	EndIf
Else
	LJRPLogProc("LPXXmlAss - eh PDV")

	//Antes de tentar acessar a retaguarda, tento trazer os arquivos para o
	//PDV e impedir que toda hora seja feita a comunicação com a retaguarda
	cCertIdent	:= ""
	
	LJRPLogProc("LPXXmlAss - Antes de STBPRetEnt")
	lGerado	:= STBPRetEnt(@cCertIdent)
	LJRPLogProc("LPXXmlAss - Depois de STBPRetEnt")
	 
	If lGerado
		LJRPLogProc("LPXXmlAss - Antes de LPXRtAssXML")
		aRet := LPXRtAssXML(cTagFinal,cConteudo,cCertIdent)
		LJRPLogProc("LPXXmlAss - Depois de LPXRtAssXML")
	EndIf
		
	If !lGerado
		LJRPLogProc("LPXXmlAss - Antes de Remote Execute LPXXmlAss")
		
		If lTotvsPDV
			STFMessage(ProcName() + "1", "RUN", "Validando Assinatura XML",;
						{|| STBRemoteExecute("LPXXmlAss",{ .T.,.F.,cTagFinal,cConteudo,cEmpAnt,cFilAnt},Nil,.F.,@aRet) } )
			STFShowMessage(ProcName() + "1")
		Else
			LjMsgRun("Validando Assinatura XML",,;
					 {|| aRet := FR271CMyCall( "LPXXmlAss",{"SM0"},.T.,.F.,cTagFinal,cConteudo,cEmpAnt,cFilAnt)})
		EndIf
		
		LJRPLogProc("LPXXmlAss - Depois de Remote Execute LPXXmlAss")
		lGerado := .F.
	EndIf

	If ValType(aRet) == "A" .And. Len(aRet) > 0 .And. ValType(aRet[1]) == "A"  
		If aRet[1][1]
			cAssign := aRet[1][2]
			lGerado := .T.
		Else
			cMsg := aRet[1][3]
		EndIf
	Else
		cMsg := "Erro na assinatura do arquivo XML. Efetue a configuração do Certificado no ambiente da retaguarda"
	EndIf
	
	IF !Empty(cMsg)
		LJRPLogProc(cMsg,,aRet)
	EndIf
EndIf

aRet := {}
Aadd(aRet ,{lGerado,cAssign,cMsg})

LJRPLogProc("Fim de LPXXmlAss",,aRet)

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc}LPXRtAssXML
Geração da assinatura do XML

@author  	Varejo
@version 	P12
@since   	05/2019
@return  	aRet, array,  
/*/
//--------------------------------------------------------
Function LPXRtAssXML(cTagFinal,cConteudo,cCertIdent)
Local aRet		:= {}
Local cAssign 	:= ""
Local cArqPrvKey:= cDefPrvKey
Local cArqKey	:= cDefKey
Local cDigest	:= cConteudo
Local cError	:= ""
Local cWarning	:= ""
Local cSignInfo	:= ""
Local cEnvelope := ""
Local cMacro	:= ""
Local cCertDir	:= IIf(IsSrvUnix(),PAF_DirCERT+"/", PAF_DirCERT+"\")
Local cMsg		:= ""

cMacro	:= "EVPDigest"
cDigest := XmlC14N(cConteudo+cTagFinal, "", @cError, @cWarning)
IIF(! Empty(cError), LjGrvLog(Nil,"XmlC14N - Erro na função", cError),NIL)
IIF(! Empty(cWarning), LjGrvLog(Nil,"XmlC14N - Aviso na função", cWarning),NIL)
cDigest := Encode64(&cMacro.(cDigest,3))

cSignInfo += '<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">'
cSignInfo += '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></CanonicalizationMethod>'
cSignInfo += '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></SignatureMethod>'
cSignInfo += '<Reference URI="">'
cSignInfo += '<Transforms>'
cSignInfo += '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></Transform>'
cSignInfo += '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></Transform>'
cSignInfo += '</Transforms>'
cSignInfo += '<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></DigestMethod>'
cSignInfo += '<DigestValue>' + cDigest + '</DigestValue>'
cSignInfo += '</Reference>'
cSignInfo += '</SignedInfo>'

//Envelopamento da Assinatura
cMacro	:= "EVPPrivSign"
cError	:= ""
cDigest	:= XmlC14N( cSignInfo ,"",@cError,@cWarning)
IIF(! Empty(cError), LjGrvLog(Nil,"XmlC14N - Erro na função", cError),NIL)
cError	:= ""

cArqKey := cCertDir + cCertIdent + cArqKey
cEnvelope := &cMacro.(cArqKey , cDigest , 3 , ""/*cCertPass*/ , @cError)
IIF(! Empty(cError), LjGrvLog(Nil,"XmlC14N - Erro na função", cError),NIL)
cEnvelope := Encode64(cEnvelope)

//Retorno do XML assinado
cSignInfo := StrTran(cSignInfo,'xmlns="http://www.w3.org/2000/09/xmldsig#"',"")
cAssign := '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">'
cAssign += cSignInfo
cAssign += '<SignatureValue>'+cEnvelope+'</SignatureValue>'

cArqPrvKey := cCertDir + cCertIdent + cArqPrvKey
cAssign += '<KeyInfo>'
cAssign += '<X509Data>'
cAssign += '<X509Certificate>'+LPXGetCert(cArqPrvKey)+'</X509Certificate>'
cAssign += '</X509Data>'
cAssign += '</KeyInfo>'
cAssign += '</Signature>'

If !Empty(AllTrim(cError))
	cMsg := cError
EndIf

Aadd(aRet ,{ .T. ,cAssign ,cMsg})

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc}StFMPfxCvt - LPXPfxCvt
Conversor do arquivo .PFX para os arquivos .PEM

@param1 	cFile : String, caminho e nome do arquivo ".pem"
@author  	Varejo
@version 	P12
@since   	10/05/2017
@return  	cRet  :String, certificado 
/*/
//--------------------------------------------------------
Function LPXPfxCvt(cCertDir,cEntidade,cArqKey,cArqPrvKey,;
					cSenha, lWizard)
Local nX		:= 0
Local aDirFiles	:= {}
Local lRet		:= .F.
Local cError	:= ""
Local cArqCA	:= "_ca.pem"
Local cBarr		:= IIf(IsSrvUnix(),"/","\")

Default cEntidade	:= cDefEnt
Default cCertDir	:= cPathCert + cBarr
Default cArqPrvKey	:= cDefPrvKey
Default cArqKey		:= cDefKey
Default cSenha		:= ""
Default lWizard		:= .F.

If ! ( File(cCertDir+cEntidade+cArqPrvKey) .And. File(cCertDir+cEntidade+cArqKey) )
	
	aDirFiles := Directory(cCertDir + "*.PFX")
	
	IF lWizard .And. !(Len(aDirFiles) > 0) //Caso não tenha encontrado, pesquiso com o caminho completo
		aDirFiles := Directory(GetSrvProfString("RootPath","") + cCertDir + "*.PFX")
	EndIf
	
	If Len(aDirFiles) > 0
		For nX:= 1 To Len(aDirFiles)
			If ".PFX" $ Upper(aDirFiles[nX][F_NAME]) //Pega o arquivo que possui a serie, arquivo criado pelo ECF nao possui o mesmo nome.
				LJRPLogProc("Conversão do arquivo .PFX")
				
				lRet := PFXCA2PEM( cCertDir + aDirFiles[nX][F_NAME], cCertDir+cEntidade+cArqCA, @cError, cSenha ) //http://tdn.totvs.com/display/tec/PFXKey2PEM
				If !lRet .Or. !Empty(cError)
					LJRPLogProc(" Encontrado erro na função PFXCA2PEM - cErro: " + cError)
				EndIF
				
				cError := ""
				lRet := PFXKey2PEM( cCertDir + aDirFiles[nX][F_NAME], cCertDir+cEntidade+cArqKey, @cError, cSenha ) //http://tdn.totvs.com/display/tec/PFXKey2PEM
				If !lRet .Or. !Empty(cError)
					LJRPLogProc(" Encontrado erro na função PFXKey2PEM - cErro: " + cError)
				EndIF
				
				cError := ""
				lRet := PFXCert2PEM( cCertDir + aDirFiles[nX][F_NAME], cCertDir+cEntidade+cArqPrvKey, @cError, cSenha )// http://tdn.totvs.com/display/tec/PFXCert2PEM
				If !lRet .Or. !Empty(cError)
					LJRPLogProc(" Encontrado erro na função PFXCert2PEM - cErro: " + cError)
				EndIF
				
				LJRPLogProc("Fim da Conversão do arquivo .PFX")
				
				If lRet .And. File(cCertDir+cEntidade+cArqPrvKey) .And. File(cCertDir+cEntidade+cArqKey)
					lRet := .T.
					LJRPLogProc( "Busca pela certificados padrão com a entidade [" + cEntidade + "]")
				EndIf
			EndIf
		Next nX
	Else
		MsgAlert("Arquivo .PFX não encontrado na pasta \certs\")
		LJRPLogProc("Arquivo .PFX não encontrado na pasta \certs\")
	EndIf
EndIf

If lWizard .And. lRet
	Aviso("Certificado","Arquivos de Certificado Gerados com Sucesso na pasta " + cCertDir, {"OK"},2)
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}LPXGetCert
Captura do certificado para o XML

@param1 	cFile : String, caminho e nome do arquivo ".pem"
@author  	Varejo
@version 	P12
@since   	10/05/2017
@return  	cRet  :String, certificado 
/*/
//--------------------------------------------------------
Function LPXGetCert(cFile)
Local cCertificado	:= cFile
Local cMsg		:= "" 
Local nAt		:= 0
Local nRat		:= 0
Local nHandle	:= 0
Local nBuffer	:= 0

If File(cFile)
	cMsg := "Encontrado arquivo de Certificado em [" + cFile + "]"
	LJRPLogProc(cMsg)
    lDirCert  := .T.
    nHandle      := FOpen( cFile, 0 )
    nBuffer      := FSEEK(nHandle,0,FS_END)

    FSeek( nHandle, 0 )
    FRead( nHandle , cCertificado , nBuffer ) 
    FClose( nHandle ) 
    
    nAt := AT("BEGIN CERTIFICATE", cCertificado)
    If (nAt > 0)
        nAt := nAt + 22
        cCertificado := substr(cCertificado, nAt)
    EndIf
    nRat := AT("END CERTIFICATE", cCertificado)
    If (nRat > 0)
        nRat := nRat - 6
        cCertificado := substr(cCertificado, 1, nRat)
    EndIf
    cCertificado := StrTran(cCertificado, Chr(13),"")
    cCertificado := StrTran(cCertificado, Chr(10),"")
    cCertificado := StrTran(cCertificado, Chr(13)+Chr(10),"")
    
    cMsg := "Fim da leitura do certificado"
	LJRPLogProc(cMsg)
Else
    lDirCert  := .F.
    cMsg := "Certificado não encontrado."
    MsgAlert(cMsg)
    LJRPLogProc(cMsg)
EndIf
             
Return cCertificado

//--------------------------------------------------------
/*/{Protheus.doc}LJXXmlCab
Cabeçalho XML do PAF

@author  	Varejo
@version 	P12
@since   	10/05/2017
@return  	cRet  : String, cabeçalho 
/*/
//--------------------------------------------------------
Function LJXXmlCab(cNumCreden)
Local cCabec := ""
Local cIe	 := AllTrim(StrTran(StrTran(FWSM0Util():GetSM0Data(,,{"M0_INSC"})[1][2],"."),"-"))
Local cCRPAF := AllTrim(SubStr(SuperGetMV("MV_LJCRPAF",,""),1,15))

Default cNumCreden := ""

If lHomolPaf //Cliente liberado no SC para uso e usado para teste de homologação
	cIe := "258691565" //Insc. Est. para teste - cliente liberado
	cCRPAF := "1706900009918"// Num Cred em SC
EndIf

//Informações da Empresa
cCabec := "<Estabelecimento>"
cCabec += "<Ie>" + cIe + "</Ie>"
cCabec += "</Estabelecimento>"

//Informações do PAF-ECF
cCabec += "<PafEcf>"

If !Empty(AllTrim(cNumCreden))
	cCRPAF := cNumCreden //Pega o numero do PDV, no caso de gerar Estoque
	LJRPLogProc("Numero do Credenciamento proveniente do PDV",,cCRPAF)
EndIf

cCabec += "<NumeroCredenciamento>" + cCRPAF + "</NumeroCredenciamento>"

cCabec += "</PafEcf>" 

Return cCabec

//--------------------------------------------------------
/*/{Protheus.doc}LJXXmlCRZ
Corpo do XML de Redução Z

@param2		cKeySFI: String, chave da SFI do PDV
@author  	Varejo
@version 	P12
@since   	10/05/2017
@return  	lRet  - função executada com sucesso
@obs		Verifique que os dados referentes a venda de NFCe com 
			PAF não aparecerão aqui, isso está correto ( uma vez que
			a venda NFC-e eh impressa como Rel Gerencial no ECF). 
/*/
//--------------------------------------------------------
Function LJXXmlCRZ(cKeySFI,nRecnoSFI)
Local cCorpo	:= ""
Local cNumFabEcf:= ''
Local cMFAdic	:= ''
Local cTipoEcf	:= ''
Local cModelEcf	:= ''			
Local cMarcaEcf	:= ''
Local cVerSB	:= ''
Local cDtInsSB	:= ''
Local cHrInsSB	:= ''
Local cCodECF	:= ''
Local cIEECF	:= ''
Local cCnpjECF	:= ''
Local cUsuEcf	:= ''
Local cIndex	:= ''
Local cChave	:= ''
Local cTpSFI	:= ""
Local cCampo	:= ""
Local cContAlq	:= ""
Local cAux	 	:= ""
Local cCredECF	:= ""
Local cTabela	:= "SB1"
Local cVendBruta:= ""
Local cSitTrib	:= ""
Local cFI_SERPDV:= ""
Local cArqSFI	:= "ArqSFI.arq"
Local lProduto	:= .F.
Local lServico	:= .F.
Local lServIsen	:= .F.
Local lIssIsen	:= .F.
Local lIssNTrib	:= .F.
Local lIssSubTr	:= .F.
Local lIsento	:= .F.
Local lSubTrib	:= .F.
Local lNTribut	:= .F.
Local lIsSerProd:= .F.
Local lAchou	:= .F.
Local lTemDado	:= .F.
Local lItemDel	:= .F.
Local lItemNVend:= .F.
Local lMvLjPdvPa:= LjxBGetPaf()[2]
Local lLX_SITTRI:= .F.
Local lSFMSlxSl2:= ExistFunc("SFMSlxSl2")
Local aArea		:= {}
Local aProdutos	:= {}
Local aSemProd	:= {}
Local nX		:= 0
Local nIndex	:= 0
Local nTamProd	:= 7
Local nVlrItem	:= 0
Local nValItDel	:= 0
Local nValItDesc:= 0
Local nQtdDecVUnit := TamSX3("L2_VRUNIT")[2]
Local nQtdeDec	:= TamSX3("L2_QUANT")[2]
Local nTamBxCod	:= 0
Local nTotCancDia:= 0
Local nTotCanIss:= 0
Local nTotSFI	:= 0
Local nHdlArqSFI:= 0
Local bPrefixo	:= {||}
Local cFieldSFI	:= ""

LjGrvLog(Nil,"Inicio do Arquivo do Fisco da Redução Z")

DbSelectArea('SLX')
DbSelectArea('SFI')
DbSelectArea('SL2')
DbSelectArea('SB1')
DbSelectArea('SLG')
DbSelectArea("SBI")
DbSelectArea('SA1')
aArea := {}
aAdd(aArea,SFI->(GetArea()))
aAdd(aArea,SL2->(GetArea()))
aAdd(aArea,SX3->(GetArea()))
aAdd(aArea,SB1->(GetArea()))
aAdd(aArea,SLG->(GetArea()))
aAdd(aArea,SBI->(GetArea()))
aAdd(aArea,SA1->(GetArea()))
aAdd(aArea,SLX->(GetArea()))

SFI->(DbSetOrder(1)) //FI_FILIAL + FI_DTMOVTO + FI_PDV + FI_NUMREDZ
SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD
SA1->(DbSeek( xFilial("SA1") + PadR(SuperGetMV("MV_CLIPAD"),TamSX3("A1_COD")[1]) + SuperGetMV("MV_LOJAPAD") ) ) //A1_FILIAL + A1_COD + A1_LOJA

lAchou := SFI->(DbSeek(cKeySFI))
lLX_SITTRI := SLX->(ColumnPos("LX_SITTRIB")) > 0

If lAchou

	nRecnoSFi := SFI->(Recno())
	
	If lMvLjPdvPa//no PDV já está posicionado
		cAux	:= AllTrim(SLG->LG_ECFINFO)
		cCredECF:= IIf(SLG->(ColumnPos("LG_CRECFPA")) > 0 , AllTrim(SLG->LG_CRECFPA), "")
		
		If !lTotvsPdv .And. nModulo == 23
			cTabela := "SBI"
		EndIf 
	Else
		/*
			Tem que posicionar pois se estiver na retaguarda, 
			posso ter várias SFI de vários PDV's para enviar à SEFAZ 
		*/
		SLG->(DbSetOrder(1)) //LG_FILIAL + LG_CODIGO
		cAux	:= LjPesqPdv( AllTrim(SFI->FI_SERPDV) , "" , "LG_ECFINFO", "LG_SERPDV")
		cCredECF:= IIf(SLG->(ColumnPos("LG_CRECFPA")) > 0 , LjPesqPdv( AllTrim(SFI->FI_SERPDV) , "" , "LG_CRECFPA", "LG_SERPDV") , "")
	EndIf

	//Ajusta a tabela de pesquisa das informações do item
	bPrefixo := { |x| &(cTabela + "->" + SubStr(cTabela,2,2) + x ) }
	nTamBxCod := TamSX3(SubStr(cTabela,2,2) + "_COD")[1]
	
	STDBusDEst(	AllTrim(cAux)	,@cTipoEcf		,@cModelEcf	,@cVerSB	,;
				@cDtInsSB		,@cHrInsSB		,@cIEECF	,@cCnpjECF	,;
				@cMarcaEcf		,@cNumFabEcf	,@cUsuEcf	,@cCodECF	,;
				@cMFAdic		)
				 
	//Informações do ECF
	cCorpo += "<Ecf>"
	
	cFI_SERPDV := AllTrim(SFI->FI_SERPDV)
	If lHomolPaf //ECF liberado no SC para uso e usado para teste de homologação
		cFI_SERPDV := "BE111810101110031761"
	EndIf
	cCorpo += "<NumeroFabricacao>" + cFI_SERPDV + "</NumeroFabricacao>"
	
	cCorpo += "<DadosReducaoZ>"
	cCorpo += "<DataReferencia>" + cValToChar(Year(SFI->FI_DTMOVTO)) + "-" + ;
				StrZero(Month(SFI->FI_DTMOVTO),2) + "-" + StrZero(Day(SFI->FI_DTMOVTO),2) + "</DataReferencia>" //no formato AAAA-MM-dd
	
	//no Formato -> aaaa-MM-ddThh:mm:ss
	cAux := SFI->FI_HRREDZ
	cAux := Stuff(cAux,3,0,":")
	cAux := Stuff(cAux,6,0,":")
	cCorpo += "<DataHoraEmissao>" + FWTimeStamp(3,SFI->FI_DTREDZ,cAux) + "</DataHoraEmissao>"
	
	cCorpo += "<CRZ>" + StrZero(Val(SFI->FI_NUMREDZ),4)  + "</CRZ>"
	cCorpo += "<COO>" + StrZero(Val(SFI->FI_COO), TamSX3("FI_COO")[1]) + "</COO>" // 6 ou 9, dependendo do ECF utilizado
	cCorpo += "<CRO>" + StrZero(Val(SFI->FI_CRO),3) + "</CRO>"
	
	nTotSFI	   := SFI->(FI_VALCON+FI_DESC+FI_CANCEL+FI_ISS+FI_DESISS+FI_CANISS+FI_ISSISEN)
	cVendBruta := StrZero(nTotSFI,15,2)
	cVendBruta := StrTran(cVendBruta,".")
	cVendBruta := StrTran(cVendBruta,",")
	cCorpo += "<VendaBrutaDiaria>" + cVendBruta + "</VendaBrutaDiaria>"
	cCorpo += "<GT>" + StrTran(StrZero(SFI->FI_GTFINAL,19,2),".") + "</GT>"	

	nTotCancDia := SFI->FI_CANCEL
	nTotCanIss	:= SFI->FI_CANISS
	
	SX3->(DbSetOrder(1))
	SX3->(DbSeek("SFI"))
	
	DbSelectArea("SLX")
	SLX->(DbSetOrder(2)) //LX_FILIAL, LX_DTMOVTO, LX_PDV, R_E_C_N_O_, D_E_L_E_T_
	
	DbSelectArea("SL2")
	cIndex	:= CriaTrab(Nil,.F.)
	cChave	:= "L2_FILIAL+DTOS(L2_EMISSAO)+L2_SITTRIB"
	IndRegua("SL2",cIndex,cChave,,,)
	DbSelectArea("SL2")
	nIndex  := RetIndex("SL2")

	#IFNDEF TOP
		SL2->(DbSetIndex( cIndex + OrdBagExt() ))
	#ENDIF
	SL2->(DbSetOrder( nIndex + 1 ))
	
	If (nQtdDecVUnit + nTamProd) > 13
		nTamProd	:= 11
		nQtdDecVUnit:= 2
	EndIf
	
	cCorpo += "<TotalizadoresParciais>"
	
	If File(cArqSFI)
		FErase(cArqSFI)
	EndIf
	
	nHdlArqSFI := FCreate(cArqSFI,0)
	FWrite(nHdlArqSFI,cCorpo,Len(cCorpo))
	cCorpo := ""
		
	While !SX3->(Eof()) .And. (AllTrim(SX3->X3_ARQUIVO) == "SFI")
		cFieldSFI	:= AllTrim(SX3->X3_CAMPO)
		cTpSFI		:= Substr(cFieldSFI,1,6)
		cCampo		:= ""
		cCorpo		:= ""
		
		lServico	:= .F.
		lServIsen	:= .F.
		lProduto	:= .F.
		lIsento		:= .F.
		lSubTrib	:= .F.
		lNTribut	:= .F.
		lIsSerProd	:= .F.
		lIssIsen	:= .F.
		lIssNTrib	:= .F.
		lIssSubTr	:= .F.

		If cTpSFI == "FI_COD"
			lProduto:= .T.
			cCampo	:= 'FI_BAS'
			 
		ElseIF cTpSFI == "FI_ICO"
			cAux := Substr(cFieldSFI,8,2)
			If cAux $ "FS|NS|IS"
				lServIsen := .T.
				
				If cAux == "FS"
					cCampo := "FI_ISSFTRI"
					lIssSubTr := .T.
				ElseIf cAux == "NS"
					cCampo := "FI_ISSNTRI"
					lIssNTrib := .T.
				ElseIf cAux == "IS"
					cCampo := "FI_ISSISEN"
					lIssIsen := .T.
				EndIf
				
				cAux := ""
			Else		
				cCampo	:= 'FI_BI'
				lServico:= .T.
			EndIf
			
		ElseIf cTpSFI == "FI_ISE"
			lIsento	:= .T.
			cCampo := "FI_ISENTO"
			
		ElseIf cTpSFI == "FI_SUB"
			lSubTrib := .T.
			cCampo := "FI_SUBTRIB"
			
		ElseIf cTpSFI == "FI_NTR"
			lNTribut := .T.
			cCampo := "FI_NTRIB"
		EndIf
		
		If !Empty(cCampo)
			aProdutos	:= {}
			cContAlq	:= ""
			lTemDado	:= .T.
			
			If lProduto
				cCampo	:= cCampo + Substr(AllTrim(SX3->X3_CAMPO),7,Len(SX3->X3_CAMPO))
				If SFI->(ColumnPos(cCampo)) > 0
					cContAlq:= "<Valor>" + StrTran(AllTrim(Str(SFI->(&(cCampo)),11,2)),".",",") + "</Valor>"
				Else
					lTemDado:= .F.
				EndIf

			ElseIf lServico
				/*
					Formação do campo de ISS
					X3_CAMPO == FI_ICODX
					Conteudo do FI_ICODX == SXX00
					cCampo == "FI_BI"
					o campo correspondente na SFI == FI_BISXX00
				*/
				cCampo	:= cCampo + SFI->(&(AllTrim(SX3->X3_CAMPO)))
				If SFI->(ColumnPos(cCampo)) > 0
					cContAlq:= "<Valor>" + StrTran(AllTrim(Str(SFI->(&(cCampo)),11,2)),".",",") + "</Valor>"
				Else
					lTemDado:= .F.
				EndIf
			ElseIf lIsento .Or. lNTribut .Or. lSubTrib .Or. lServIsen
				cContAlq:= "<Valor>" + StrTran(AllTrim(Str(SFI->(&(cCampo)),11,2)),".",",") + "</Valor>"			
			EndIf
			
			If lTemDado .And. (lIsento .Or. lSubTrib .Or. lNTribut .Or. lServIsen .Or. ! Empty( SFI->(&(AllTrim(SX3->X3_CAMPO))) ) )
				cCorpo	+= "<TotalizadorParcial>"
				
				If lServIsen
				
					If lIssSubTr
						cCorpo	+= "<Nome>" + "FS1" + "</Nome>"
					ElseIf lIssNTrib
						cCorpo	+= "<Nome>" + "NS1" + "</Nome>"
					ElseIf lIssIsen
						cCorpo	+= "<Nome>" + "IS1" + "</Nome>"
					EndIf

				ElseIf lIsento 
					cCorpo	+= "<Nome>" + "I1" + "</Nome>"
				ElseIf lSubTrib
					cCorpo	+= "<Nome>" + "F1" + "</Nome>"
				ElseIf lNTribut
					cCorpo	+= "<Nome>" + "N1" + "</Nome>"
				Else
					cCorpo	+=	"<Nome>" + STBBuscaTotECF( SFI->(&(AllTrim(SX3->X3_CAMPO))), lTotvsPdv ) + "</Nome>"
				EndIf

				cCorpo	+= cContAlq
				cCorpo	+= "<ProdutosServicos>"
				
				FWrite(nHdlArqSFI, cCorpo, Len(cCorpo))
				cCorpo := ""
				
				/*
					Nos casos de aliquota de Isento, Nao Tributado e Substituicao Tributaria faço uma pesquisa generica
					pois no ECF posso ter varios indices porem no Protheus grava tudo em um campo somente
				*/
				cContAlq := ""
				lIsSerProd := .F.
				
				If lIssIsen
					cContAlq := "IS"
				ElseIf lIssNTrib
					cContAlq := "NS"
				ElseIf lIssSubTr
					cContAlq := "FS"
				ElseIf lIsento
					cContAlq := "I" //"I1"
				ElseIf lSubTrib
					cContAlq := "F" //"F1"
				ElseIf lNTribut
					cContAlq := "N" //"N1"					
				Else
					cContAlq := SFI->(&(AllTrim(SX3->X3_CAMPO)))
					lIsSerProd := .T.
				EndIf
		
				/*
				Para TOTVSPDV - o L1_STORC fica com C quando o cupom fiscal esta
				 cancelado com isso avalio se o cupom foi cancelado e o SLX traz os dados
				
				Para SIGALOJA - o registro de cupom fiscal ficam todos os registros 
				como deletado (SL1/SL2/SL4), com isso a condição L1_STORC = "C" não afeta 
				*/
				
				If	!Empty(AllTrim(cContAlq))

				 	If SL2->(DbSeek(xFilial("SL2") + DTOS(SFI->FI_DTMOVTO) + cContAlq))
					 
						While !SL2->(Eof()) .And. ( SL2->L2_EMISSAO == SFI->FI_DTMOVTO )

							SL1->(DbSetOrder(1)) //L1_FILIAL+L1_NUM
							If SL1->(DbSeek(xFilial("SL2")+SL2->L2_NUM))
								IF !(SL1->L1_STORC == "C"); 
									.And. VldSitTri(AllTrim(SL2->L2_SITTRIB), lServIsen, cContAlq, lIsSerProd); 			
									.And. !Empty(AllTrim(SL2->L2_PAFMD5)) .And. !Empty(AllTrim(SL2->L2_DOC)) ;
									.And. LJPXPrdRes() //Valida se é item de reserva
									
									nX	:= aScan(aProdutos, { |x| AllTrim(x[1]) == AllTrim(SL2->L2_PRODUTO)})
									lItemDel := .F.
									lItemNVend:= AllTrim(SL2->L2_VENDIDO) == "N"
									
									/*
									1  - Codigo do Produto
									2  - Unidade de Medida
									3  - Descricao do Produto
									4  - Quantidade
									5  - Valor do Item
									6  - Valor do Desconto
									7  - Valor do Acrescimo
									8  - Valor do Cancelamento
									9  - Codigo GTIN
									10 - CEST
									11 - POSIPI (CodigoNCMSH)
									*/
									nValItDel := 0
									nValItDesc:= 0
									nVlrItem := SL2->L2_VLRITEM
									If lItemDel
										nVlrItem  := 0
										nValItDel := SL2->L2_VLRITEM
										//Quando tenho um item com desconto cancelado a impressora cancela o valor do item + desconto
										nValItDesc:= SL2->(L2_VALDESC+L2_DESCPRO)
									EndIf
																
									If !lItemNVend .And. lItemDel									
										cAux := "Item não sera acumulado na SL2 - [SL2->L2_NUM+L2_ITEM] - "+;
												"(" + SL2->(L2_NUM+L2_ITEM) + ") - Acumulado pela SLX"
										LJRPLogProc(cAux)
									Else
										If nX == 0
											aAdd(aProdutos,{SL2->L2_PRODUTO								,;
															SL2->L2_NUM									,;
															SL2->L2_DESCRI								,;
															SL2->L2_QUANT								,;
															nVlrItem+ SL2->L2_DESPESA					,;
															IIf(lItemDel,0,SL2->(L2_VALDESC+L2_DESCPRO)),;
															SL2->(L2_VALACRS+L2_DESPESA)				,;
															nValItDel+nValItDesc						,;
															""/*SB1->B1_CODGTIN*/						,;
															AllTrim(SL2->L2_CEST)						,;
															AllTrim(SL2->L2_POSIPI)			 			})
										Else
											aProdutos[nX][4] += SL2->L2_QUANT
											aProdutos[nX][5] += nVlrItem + SL2->L2_DESPESA
											aProdutos[nX][6] += IIf(lItemDel,0,SL2->(L2_VALDESC+L2_DESCPRO))
											aProdutos[nX][7] += SL2->(L2_VALACRS+L2_DESPESA)
											aProdutos[nX][8] += nValItDel + nValItDesc
										EndIf
									EndIf
								EndIf
							EndIf
							SL2->(DbSkip())
						End
					EndIf
					
					//Captura os valores dos produtos cancelado e que não estão na SL2
					//Vendas Canceladas e Pré-Vendas canceladas no inicio ou fim do dia ( Redução Z )
					SLX->(DbSetOrder(2)) //LX_FILIAL, LX_DTMOVTO, LX_PDV, R_E_C_N_O_, D_E_L_E_T_
					If SLX->(DbSeek(xFilial("SLX") + DTOS(SFI->FI_DTMOVTO))) //LX_FILIAL, LX_DTMOVTO, LX_PDV, R_E_C_N_O_, D_E_L_E_T_
						
						//*** Ao somar o valor do item não usar o LX_DESCON
						//*** porque o valor do desconto já somado no campo LX_VALOR
						//*** tanto no TOTVSPDV quanto SIGALOJA
						
						While !SLX->(Eof()) .And. ( DTOS(SLX->LX_DTMOVTO) == DTOS(SFI->FI_DTMOVTO) )
							If	!( "D" $ AllTrim(SLX->LX_TPCANC) ) .And. ;
							 	!Empty(AllTrim(SLX->LX_CUPOM)) .And. !Empty(AllTrim(SLX->LX_PRODUTO));
								
								nX	:= aScan(aProdutos, { |x| AllTrim(x[1]) == AllTrim(SLX->LX_PRODUTO)})
								If nX == 0
									cSitTrib := ""
									
									If lLX_SITTRI .And. !Empty(AllTrim(SLX->LX_SITTRIB))
										cSitTrib := AllTrim(SLX->LX_SITTRIB)
										//Caso futuramente remova a existencia do campo deve manter para validar o preenchimento
										//e na função SFMSlxSl2 preencher o campo com a tributação 
										lLX_SITTRI := .T. 
									EndIf
									
									If Empty(cSitTrib)
									
										If SLX->LX_ALIQICM > 0
											cSitTrib := StrTran(StrTran("T" + AllTrim( StrZero( SLX->LX_ALIQICM , 5, 2 ) ) , "."),",")
											LjGrvLog( NIL, "Valor de LX_ALIQICM preenchido - portanto considerado valor de ICMS" +;
														" - {Valor de ICMS, Recno, cSitTrib}", {SLX->LX_ALIQICM,SLX->(Recno()),cSitTrib})
										EndIf
										 
										If lSFMSlxSl2
											LjGrvLog( NIL, "Antes da chamada de SFMSlxSl2")
											cSitTrib := SFMSlxSl2(PadR(AllTrim(SLX->LX_PRODUTO),nTamBxCod),SFI->FI_DTMOVTO,lLX_SITTRI)
											LjGrvLog( NIL, "Depois da chamada de SFMSlxSl2 - cSitTrib", cSitTrib)
										EndIf
										
										If Empty(cSitTrib)
											LjGrvLog( NIL, "Antes da chamada de STBFMSitTrib")
											cSitTrib := STBFMSitTrib(PadR(AllTrim(SLX->LX_PRODUTO),nTamBxCod),"",cTabela,.F.)
											cSitTrib := StrTran(cSitTrib,",")
											cSitTrib := StrTran(cSitTrib,".")
											LjGrvLog( NIL, "Depois da chamada de STBFMSitTrib - cSitTrib", cSitTrib)
										EndIf
										
										If Empty(cSitTrib)
											cAux := " Produto [" + SLX->LX_PRODUTO + "] - não encontrado alíquota - portando não sera considerado" + PULALINHA +;
													"Recno da SLX - " + cValToChar(SLX->(Recno()))
											LJRPLogProc(cAux)
										EndIf
									EndIf
									
									// Precisa posicionar no item para capturar as informações
									// fiscais do produto para preencher o XML
									If &(cTabela)->(DbSeek( FwxFilial(cTabela) + PadR(AllTrim(SLX->LX_PRODUTO),nTamBxCod)))
										If VldSitTri(AllTrim(cSitTrib), lServIsen,cContAlq, lIsSerProd) 	
									 											
											aAdd(aProdutos,{SLX->LX_PRODUTO, ;
															AllTrim(Eval(bPrefixo, "_UM")),;
															AllTrim(Eval(bPrefixo, "_DESC")),;
															SLX->LX_QTDE,;
															0,;
															0,;
															0,;
															SLX->LX_VALOR,;
															AllTrim(Eval(bPrefixo, "_CODGTIN")),;
															AllTrim(Eval(bPrefixo, "_CEST")),;
															AllTrim(Eval(bPrefixo, "_POSIPI"))})
										
										EndIf
									Else
										nX := aScan(aSemProd, AllTrim(Upper(SLX->LX_PRODUTO)))
										If nX == 0
											aadd(aSemProd,AllTrim(Upper(SLX->LX_PRODUTO)))
											
											cAux := "Produto de Código [" + AllTrim(SLX->LX_PRODUTO) + "] não encontrado na tabela " + cTabela +;
											 		". " + PULALINHA + "Necessário atualizar a tabela de Produtos para gerar o XML corretamente!"
											LJRPLogProc(cAux)
											
											If !IsBlind()
												MsgAlert(cAux)
											EndIf
										EndIf
									EndIf
								Else
									aProdutos[nX][4] += SLX->LX_QTDE
									aProdutos[nX][5] += 0
									aProdutos[nX][6] += 0
									aProdutos[nX][7] += 0
									aProdutos[nX][8] += SLX->LX_VALOR
								EndIf
							EndIf
							
							SLX->(DbSkip())
						End
					EndIf
				EndIf
				
				cCorpo := ""
				//Escreve o corpo com os valores de alíquotas e produtos
				For nX:= 1 to Len(aProdutos)
					If lServico .Or. lServIsen
						cCorpo += "<Servico>"
					Else
						cCorpo += "<Produto>"
					EndIf
					
					&(cTabela)->(DbSeek( xFilial(cTabela) + PadR(AllTrim(aProdutos[nX][1]),nTamBxCod)))
					
					If Empty(AllTrim(aProdutos[nX][3]))
						aProdutos[nX][3] := AllTrim(Eval(bPrefixo, "_DESC"))
					EndIf
	
					cCorpo += "<Descricao>" + EnCodeUTF8( LPXRmChrXM(LjRmvChEs(aProdutos[nX][3])) ) + "</Descricao>"
					
					If !lServico .And. !lServIsen
						//BLOCO DO GTIN
						If Empty(AllTrim(Eval(bPrefixo, "_CODGTIN"))) .AND. !Empty(AllTrim(Eval(bPrefixo, "_CODBAR")))  
							aProdutos[nX][9] := AllTrim(Eval(bPrefixo, "_CODBAR"))
						Elseif !AllTrim(Eval(bPrefixo, "_CODGTIN"))=='00000000000000' .AND. !AllTrim(Eval(bPrefixo, "_CODGTIN"))=='000000000000000'
							aProdutos[nX][9] := AllTrim(Eval(bPrefixo, "_CODGTIN")) //Insere o GTIN
						Else
							aProdutos[nX][9] := ""
						EndIf
						
						cCorpo += "<CodigoGTIN>" + aProdutos[nX][9] + "</CodigoGTIN>"
						
						//BLOCO DO CEST
						If Empty(aProdutos[nX][10])
							aProdutos[nX][10] := AllTrim(Eval(bPrefixo, "_CEST"))
						EndIf 
						
						If Empty(aProdutos[nX][10])
							cCorpo += "<CodigoCEST></CodigoCEST>"
						Else
							cCorpo += "<CodigoCEST>" + aProdutos[nX][10] + "</CodigoCEST>"
						EndIf
						
						//BLOCO DO POSIPI
						If Empty(aProdutos[nX][11])
							aProdutos[nX][11] := AllTrim(Eval(bPrefixo, "_POSIPI"))
						EndIf
						 
						If Empty(aProdutos[nX][11]) //Conforme manual deve conter um valor diferente de vazio
							cCorpo += "<CodigoNCMSH>" + "0" + "</CodigoNCMSH>"
						Else
							cCorpo += "<CodigoNCMSH>" + AllTrim(aProdutos[nX][11]) + "</CodigoNCMSH>"
						EndIf
					EndIf
					cCorpo += "<CodigoProprio>" + AllTrim(aProdutos[nX][1]) + "</CodigoProprio>"
					
					cAux := Str(aProdutos[nX][4],7,nQtdeDec)
					If "*" $ cAux //Excedeu o tamanho do campo
						LjGrvLog( "LJXXmlCRZ", "Excedeu o tamanho do campo, portanto sera colocado uma quantidade padrão - [999]", {aProdutos[nX][4],cAux} )
						cAux := Str(999,7,nQtdeDec)
					EndIf
					cCorpo += "<Quantidade>" + StrTran(AllTrim(cAux),".",",") + "</Quantidade>"
					cAux := ""
					
					If Empty(AllTrim(aProdutos[nX][2]))
						aProdutos[nX][2] := AllTrim(Eval(bPrefixo, "_UM"))
					EndIf
					cCorpo += "<Unidade>" + aProdutos[nX][2] + "</Unidade>"
					
					cCorpo += "<ValorDesconto>" + StrTran(AllTrim(Str(aProdutos[nX][6],20,2)),".",",") + "</ValorDesconto>"
					cCorpo += "<ValorAcrescimo>" + StrTran(AllTrim(Str(aProdutos[nX][7],20,2)),".",",") + "</ValorAcrescimo>"
					cCorpo += "<ValorCancelamento>" + StrTran(AllTrim(Str(aProdutos[nX][8],20,2)),".",",") + "</ValorCancelamento>"
					cCorpo += "<ValorTotalLiquido>" + StrTran(AllTrim(Str(aProdutos[nX][5],20,2)),".",",") + "</ValorTotalLiquido>"
	
					If lServico .Or. lServIsen
						cCorpo += "</Servico>"
					Else
						cCorpo += "</Produto>"
					EndIf
					
					FWrite(nHdlArqSFI, cCorpo, Len(cCorpo))
					LJRPLogProc("Gravando XML da SFI...")
					cCorpo := ""
				Next nX
							
				cCorpo := "</ProdutosServicos>"
				cCorpo += "</TotalizadorParcial>"
				FWrite(nHdlArqSFI, cCorpo, Len(cCorpo))
				LJRPLogProc("Gravando XML da SFI...")
				cCorpo := ""
				
				ASize(aProdutos,0)
				aProdutos	:= {}
			EndIf
		EndIf
		
		SX3->(DbSkip())
		If Len(cCorpo) > 0
			FWrite(nHdlArqSFI, cCorpo, Len(cCorpo))
			LJRPLogProc("Gravando XML da SFI...")
			cCorpo := ""
		Endif
	End
		
	#IFNDEF TOP
		FErase(cIndex+OrdBagExt())
	#ENDIF
	
	SL2->(DbCloseArea())
	DbSelectArea("SL2")
	
	cCorpo := "</TotalizadoresParciais>"
	cCorpo += "</DadosReducaoZ>"
	cCorpo += "</Ecf>"
	
	FWrite(nHdlArqSFI,cCorpo,Len(cCorpo))
	
	LJRPLogProc("Leitura do Arquivo para a Memória - SFI")
	nX := FSeek(nHdlArqSFI,0,2)
	cCorpo := Space(nX)
	FSeek(nHdlArqSFI,0)
	FRead( nHdlArqSFI, @cCorpo, nX )
	fClose(nHdlArqSFI)
	FErase(cArqSFI)
	LJRPLogProc("Final da Leitura do Arquivo para a Memória - SFI")
EndIf

For nX := 1 to Len(aArea)
	RestArea(aArea[nX])
Next nX

Return cCorpo

//--------------------------------------------------------
/*/{Protheus.doc}LJXXml2CSt
Conteudo do corpo do XML de Stock -
Faz a consulta utilizando Query para agilizar o 
processo de escrita devido a lentidão 

@param		dData, Data, data do estoque atual
@param	 	cFilSB1 , String, filial da SB1
@param		aVndProd, array, contem os produtos vendidos no PDV
@author  	julio.nery
@version 	P12
@since   	24/03/2020
@return  	lRet  - função executada com sucesso 
@Obs		O Layout de geração do XML de estoque foi montado com base no Manual de Bloco X do PAF-ECF disponível em: 
			https://docs.google.com/document/d/1yez14gry9Mi4rTpwDRDf--bR-SLzijD81OPeJzh9FqE/edit
/*/
//--------------------------------------------------------
Function LJXXml2CSt(dData,cFilSB1,aVndProd)
Local cCorpo 		:= ""
Local cDtIni 		:= ""
Local cDtFim 		:= ""
Local cDtXML 		:= ""
Local cAux	 		:= ""
Local cAux2	 		:= ""
Local cAlias 		:= GetNextAlias()
Local cQuery 		:= ""
Local cFldMesB3 	:= ""
Local cMV_ARREFAT	:= ""
Local cB1Desc		:= ""
Local cArqProd		:= "ArqProd.arq"
Local dLastDt		:= Ctod("")
Local nX	 		:= 0
Local nRecCnt		:= 0
Local nHdlArqEst	:= -1
Local lVndProd 		:= .F.
Local cTipoNota		:= "N" 	//Considera só Tipo de Doc N=Normal, para desconsiderar Devolução, Nota de Complemento, etc.
Local cGTIN 		:= ''	//Variável para validação do GTIN
Local cNCest		:= AllTrim( SuperGetMV("MV_LJNCEST",,"") ) // Indica os NCMs que não devem ser enviados no XML de estoque (B1_CEST)
Local cSGBD		 	:= Alltrim(Upper(TCGetDB())) //Banco de dados que esta sendo utilizado

Default aVndProd 	:= {}

dLastDt:= LastDay(dData,0)
cDtXML := cValToChar(Year(dLastDt)) + "-" + StrZero(Month(dLastDt),2) + "-" +  cValToChar(Day(dLastDt))
cDtIni := cValToChar(Year(dLastDt)) + StrZero(Month(dLastDt),2) + "01"
cDtFim := DtoS(dLastDt)
cMV_ARREFAT := AllTrim(SuperGetMV("MV_ARREFAT"))

If Len(aVndProd) > 0
	lVndProd := .T.
	LJRPLogProc("o arquivo de estoque será gerado somente com os produtos que tiveram venda no mês")
Else
	LJRPLogProc("o arquivo de estoque será gerado com todos os produtos, pois não houve venda ")
EndIf	

cFldMesB3 := StrZero(Month(dLastDt),2)
	
cAux := "LJXXml2CSt - Inicio da Pesquisa via Query"
LJRPLogProc(cAux)

cQuery	:= " SELECT DISTINCT "
cQuery	+= " SB1.B1_COD , SB1.B1_DESC , SB1.B1_CEST , SB1.B1_POSIPI, SB1.B1_UM , " 
cQuery	+= " SB1.B1_IAT , SB1.B1_IPPT , SB1.B1_CODGTIN,SB1.B1_CODBAR,"
cQuery	+= " SB3.B3_Q" + cFldMesB3 + " B3QTDE , "
cQuery	+= " SUM(SD1.D1_QUANT) D1_QUANT, "
cQuery	+= " ( SELECT SD1SUB1.D1_VUNIT "
cQuery	+= "	 FROM " + RetSqlName("SD1") + " SD1SUB1 "
cQuery	+= "    WHERE SD1SUB1.R_E_C_N_O_ = ( SELECT MAX(SD1SUB2.R_E_C_N_O_) "
cQuery	+= "							  	   FROM " + RetSqlName("SD1") + " SD1SUB2 "
cQuery	+= "							 	  WHERE SD1SUB2.D1_FILIAL = '" + FwxFilial("SD1") + "' "
cQuery	+= "							   	  	AND SD1SUB2.D1_COD = SB1.B1_COD "
cQuery	+= "							   	  	AND SD1SUB2.D1_TIPO = '" + cTipoNota + "' "
cQuery	+= "							   	  	AND SD1SUB2.D1_EMISSAO BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' "
cQuery	+= "							   	  	AND SD1SUB2.D_E_L_E_T_ = ' ') "
cQuery	+= " ) D1_VUNIT, "
cQuery	+= " SUM(SD1.D1_TOTAL) D1_TOTAL, SUM(SD1.D1_VALICM) D1_VALICM, SUM(SD1.D1_BASEICM) D1_BASEICM, SUM(SD1.D1_VLSLXML) D1_VLSLXML "

cQuery	+= " FROM " + RetSqlName("SB1") + " SB1 "

cQuery	+= " LEFT JOIN " + RetSqlName("SB3") + " SB3 ON SB3.B3_FILIAL='"+ ;
			FwxFilial("SB3")+"' AND SB3.B3_COD = SB1.B1_COD AND SB3.D_E_L_E_T_ = ' ' "
			
cQuery	+= " LEFT JOIN " + RetSqlName("SB0") + " SB0 ON SB0.B0_FILIAL='"+ ;
			FwxFilial("SB0")+"' AND SB0.B0_COD = SB1.B1_COD AND SB0.D_E_L_E_T_ = ' ' "
			
cQuery	+= " LEFT JOIN "+ RetSqlName("SD1") + " SD1 ON SD1.D1_FILIAL='"+ ;
			FwxFilial("SD1")+"' AND SD1.D1_COD = SB1.B1_COD AND SD1.D1_TIPO = '" + cTipoNota + "'"+ ; 
			" AND SD1.D1_EMISSAO BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' AND SD1.D_E_L_E_T_ = ' ' "

cQuery	+= " WHERE "
cQuery	+= " SB1.B1_FILIAL = '" + PadR(cFilSB1,Len(FwxFilial("SB1"))) + "'"
cQuery	+= " AND SB1.B1_MSBLQL <> '1' AND SB1.D_E_L_E_T_= ' ' "

cQuery	+= " AND EXISTS (SELECT TAB.COD CODIGO FROM "
cQuery	+= " (SELECT L2_PRODUTO COD FROM " + RetSqlName("SL2") + " WHERE D_E_L_E_T_ = ' ' "
cQuery	+= " AND L2_FILIAL = '" + FwxFilial("SL2") + "' AND " + IIf (cSGBD $ "ORACLE","SUBSTR(L2_EMISSAO,1,6) = '", "LEFT(L2_EMISSAO,6) = '") + SubStr(cDtIni, 1, 6) + "' UNION ALL "
cQuery	+= " SELECT LX_PRODUTO COD FROM " + RetSqlName("SLX") + " WHERE D_E_L_E_T_ = ' ' AND LX_FILIAL = '" + FwxFilial("SLX") + "' AND " + IIf (cSGBD $ "ORACLE","SUBSTR(LX_DTMOVTO,1,6) = '", " LEFT(LX_DTMOVTO,6) = '") + SubStr(cDtIni, 1, 6) + "') TAB "
cQuery	+= " WHERE TAB.COD = SB1.B1_COD GROUP BY TAB.COD) "

cQuery += " GROUP BY SB1.B1_COD,SB1.B1_DESC,SB1.B1_CEST,SB1.B1_POSIPI,SB1.B1_UM,SB1.B1_IAT,SB1.B1_IPPT,SB1.B1_CODGTIN,SB1.B1_CODBAR,SB3.B3_Q" + cFldMesB3
cQuery += " ORDER BY SB1.B1_COD "
cQuery := ChangeQuery( cQuery )

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)

//Informações do Estoque
cCorpo := "<DadosEstoque>"
cCorpo += "<DataReferencia>" + cDtXML + "</DataReferencia>"
cCorpo += "<Produtos>"

If File(cArqProd)
	FErase(cArqProd)
EndIf
nHdlArqEst := FCreate(cArqProd,0)
FWrite(nHdlArqEst,cCorpo,Len(cCorpo))

If (cAlias)->(Eof())
	cAux := "LJXXml2CSt - Retorno da Query - Tem Dados ? Não"
	LJRPLogProc(cAux)
Else	
	cAux := "LJXXml2CSt - Retorno da Query - Tem Dados ? Sim"
	LJRPLogProc(cAux)
	
	While !(cAlias)->(Eof())
		
		nRecCnt++
		cCorpo := ""
		cCorpo := "<Produto>"
		
		cB1Desc := LjRmvChEs((cAlias)->B1_DESC)
		cB1Desc := LPXRmChrXM(cB1Desc)
		cB1Desc := EnCodeUTF8(cB1Desc)
		cCorpo += "<Descricao>" + cB1Desc + "</Descricao>"
		
		//BLOCO DO GTIN
		cGTIN:=""
		If Empty(AllTrim((cAlias)->B1_CODGTIN))  .AND. !Empty(AllTrim((cAlias)->B1_CODBAR))
			cGTIN := AllTrim((cAlias)->B1_CODBAR)
		Elseif AllTrim((cAlias)->B1_CODGTIN)=='00000000000000' .OR. AllTrim((cAlias)->B1_CODGTIN)=='000000000000000'
			cGTIN:=""
		Elseif !AllTrim((cAlias)->B1_CODGTIN)=='00000000000000' .AND. !AllTrim((cAlias)->B1_CODGTIN)=='000000000000000'
			cGTIN := AllTrim((cAlias)->B1_CODGTIN)
		EndIf

		cCorpo += "<CodigoGTIN>" + cGTIN + "</CodigoGTIN>"
		
		If !Empty((cAlias)->B1_POSIPI) .AND. AllTrim((cAlias)->B1_POSIPI) $ cNCest
			cB1Cest := ""
		Else
			cB1Cest := AllTrim((cAlias)->B1_CEST)	
		EndIf

		cCorpo += "<CodigoCEST>" + cB1Cest + "</CodigoCEST>"

		If Empty((cAlias)->B1_POSIPI)
			cCorpo += "<CodigoNCMSH>" + '0' + "</CodigoNCMSH>"
		Else
			cCorpo += "<CodigoNCMSH>" + AllTrim((cAlias)->B1_POSIPI) + "</CodigoNCMSH>"
		EndIf

		cCorpo += "<CodigoProprio>" + AllTrim((cAlias)->B1_COD) + "</CodigoProprio>"
		
		cCorpo += "<Quantidade>" + StrTran(AllTrim(Str(Abs((cAlias)->B3QTDE),20,3)),".",",") + "</Quantidade>"
		cCorpo += "<QuantidadeTotalAquisicao>" + StrTran(AllTrim(Str((cAlias)->D1_QUANT,20,3)),".",",") + "</QuantidadeTotalAquisicao>"
		cCorpo += "<Unidade>" + AllTrim((cAlias)->B1_UM) + "</Unidade>"
		cCorpo += "<ValorUnitario>" + StrTran(AllTrim(Str((cAlias)->D1_VUNIT, 20, 3)),".",",") + "</ValorUnitario>"
		cCorpo += "<ValorTotalAquisicao>" + StrTran(AllTrim(Str((cAlias)->D1_TOTAL, 20, 2)),".",",") + "</ValorTotalAquisicao>"
		cCorpo += "<ValorTotalICMSDebitoFornecedor>" + StrTran(AllTrim(Str((cAlias)->D1_VLSLXML, 20, 2)),".",",") + "</ValorTotalICMSDebitoFornecedor>"
		cCorpo += "<ValorBaseCalculoICMSST>" + StrTran(AllTrim(Str((cAlias)->D1_BASEICM, 20, 2)),".",",") + "</ValorBaseCalculoICMSST>"
		cCorpo += "<ValorTotalICMSST>" + StrTran(AllTrim(Str((cAlias)->D1_VALICM, 20, 2)),".",",") + "</ValorTotalICMSST>"
		
		cAux := AllTrim(STBFMSitTrib((cAlias)->B1_COD,"","SB1"))
		
		cAux2 := SubStr(cAux,1,2)
		If ("IS" $ cAux2) .Or. ("FS" $ cAux2) .Or. ("NS" $ cAux2)
			If cAux2 == "IS"
				cAux2 := "Isento"
			ElseIf cAux2 == "FS"
				cAux2 := "Substituicao tributaria"
			ElseIf cAux2 == "NS"
				cAux2 := "Nao Tributado"
			EndIf
		Else
			cAux2:= SubStr(cAux,1,1)
			If cAux2 == "I"
				cAux2 := "Isento"
			ElseIf cAux2 == "S"
				cAux2 := "Tributado pelo ISSQN"
			ElseIf cAux2 == "F"
				cAux2 := "Substituicao tributaria"
			ElseIf cAux2 == "N"
				cAux2 := "Nao tributado"
			ElseIf cAux2 == "T"
				cAux2 := "Tributado pelo ICMS"
			EndIf
		EndIf
		cCorpo += "<SituacaoTributaria>" + cAux2 + "</SituacaoTributaria>"
		 
		If Substr(cAux,1,1) == "T" .Or. Substr(cAux,1,1) == "S"
			nX := Val(Substr(cAux,2,Len(cAux)))
			cAux := IIf( nX > 0 , StrZero(nX,5,2) , "0")
			cCorpo += "<Aliquota>" + StrTran(cAux,".",",") + "</Aliquota>"
		Else
			cCorpo += "<Aliquota></Aliquota>"
		EndIf
		
		If AllTrim((cAlias)->B1_IAT) == "T"
			cCorpo += "<IsArredondado>" + "false" + "</IsArredondado>"
		ElseIf AllTrim((cAlias)->B1_IAT) == "A"
			cCorpo += "<IsArredondado>" + "true" + "</IsArredondado>"
		Else
			If cMV_ARREFAT == "S"
				cCorpo += "<IsArredondado>" + "true" + "</IsArredondado>"
			Else
				cCorpo += "<IsArredondado>" + "false" + "</IsArredondado>"
			EndIf
		EndIf
		
		If AllTrim((cAlias)->B1_IPPT) == "P"
			cCorpo += "<Ippt>" + "Proprio" + "</Ippt>"
		ElseIf AllTrim((cAlias)->B1_IPPT) == "T"
			cCorpo += "<Ippt>" + "Terceiros" + "</Ippt>"
		Else
			cCorpo += "<Ippt>" + "Proprio" + "</Ippt>"
		EndIf
		
		cAux2 := IIf( (cAlias)->B3QTDE >= 0,"Positivo","Negativo" )
		cCorpo += "<SituacaoEstoque>" + cAux2 + "</SituacaoEstoque>"
		cCorpo += "</Produto>"
		
		(cAlias)->(DbSkip())
		
		If nRecCnt > 50
			cAux2 := " Coletando dados da SB1! Possui mais dados ? " + IIf( (cAlias)->(Eof()), "Não", "Sim..." )
			LJRPLogProc(cAux2)
			cAux2	:= ""
			nRecCnt	:= 0
		EndIf
		
		FWrite(nHdlArqEst, cCorpo, Len(cCorpo))
	End
EndIf

(cAlias)->(DbCloseArea())

cCorpo := "</Produtos>"
cCorpo += "</DadosEstoque>"
FWrite(nHdlArqEst,cCorpo,Len(cCorpo))

LJRPLogProc("Leitura do Arquivo para a Memória")
nX := FSeek(nHdlArqEst,0,2)
cCorpo := Space(nX)
FSeek(nHdlArqEst,0)
FRead( nHdlArqEst, @cCorpo, nX )
fClose(nHdlArqEst)
FErase(cArqProd)
LJRPLogProc("Final da Leitura do Arquivo para a Memória")

LJRPLogProc("LJXXml2CSt - Final da Rotina -> Retornou o Conteudo ?" + IIf(Len(cCorpo) > 0, "Sim", "Não"))
Return cCorpo

//--------------------------------------------------------
/*/{Protheus.doc}LPXXMLErr
Busca todos os XML's que retornaram com erro da SEFAZ
para mostrar e solicitar o ajuste via monitor

@param1 	cTipoArq 	,String , tipo de envio (E)stoque ou (R)edz
@param2 	nQtdeRZ 	,Number , quantidade de arquivo de ReduçãoZ pendente de envio 
@param3 	nQtdeStck 	,Number , quantidade de arquivo de Estoque pendente de envio 
@param4 	nRedPend20 	,Number,  quantidade de arquivos de ReduçãoZ pendentes de envio com 20 dias ou mais(ATO DIAT Nº 011/2020)
@param5 	nEstPend20 	,Number,  quantidade arquivos de Estoque pendentes de envio com 20 dias ou mais (ATO DIAT Nº 011/2020)
@author  	Varejo
@version 	P12
@since   	26/06/2019
@return  	NIL 
/*/
//--------------------------------------------------------
Function LPXXMLErr(cTipoArq , nQtdeRZ , nQtdeStck, nRedPend20, nEstPend20 )
Local lMvLjPdvPa:= LjxBGetPaf()[2]
Local aFileRZ := {}
Local aFileES := {}
Local dDtObrig:=""

Default nRedPend20 := 0
DEfault nEstPend20 := 0

dDtObrig := STDtIniBlX()

If Empty(cTipoArq) .Or. cTipoArq == "R"
	aFileRZ := STRedXML("AE")
	If Len(aFileRZ) > 0 .And. (aFileRZ[1][1] > 0)
		nQtdeRZ := Len(aFileRZ)
		aEval( aFileRZ, {|x| If( x[6] <= Date()-20, nRedPend20++, nil ) } )
	EndIf
EndIf

If Empty(cTipoArq) .Or. cTipoArq == "E"
	aFileES := STEstqXML(lMvLjPdvPa,"AE",,,,,,,dDtObrig)
	If Len(aFileES) > 0 .And. (aFileES[1][1] > 0)
		nQtdeStck := Len(aFileES)
		aEval(aFileES, {|x| If( x[6] <= Date()-20, nEstPend20++, nil ) } )
	EndIf
EndIf

Return NIL

//--------------------------------------------------------
/*/{Protheus.doc}LPXRetDatX
Retorno data do XML 
@param1		
@author  	Varejo
@version 	P12
@since   	26/06/2019
@return  	NIL 
/*/
//--------------------------------------------------------
Function LPXRetDatX(cPath 	, cXML 		, cTpEnvio , cDtArq ,;
 					cDataSFI, dDtFinal	, oRetXml)
Local oXML		:= NIL
Local cError	:= ""
Local cWarning	:= ""
Local dDtGerXML := CTOD("")
Local lRet		:= .T.

Default cPath	:= ""
Default cXML	:= ""
Default cDtArq	:= ""
Default cDataSFI:= ""
Default dDtFinal:= CTOD("")
Default oRetXml	:= NIL

STBFMGerPath( @cPath )

If oRetXml <> NIL
	oXML := oRetXml
Else
	oXML := XmlParser(EncodeUTF8(cXML),"_", @cError, @cWarning)
EndIf

If oXML <> NIL
	If cTpEnvio == "E"
		dDtFinal	:= StoD(StrTran(oXML:_ESTOQUE:_MENSAGEM:_DADOSESTOQUE:_DATAREFERENCIA:Text,'-')) //MES anterior
		dDtFinal	:= dDtFinal+1
	ElseIf cTpEnvio == "R"
		dDtFinal	:= StoD(StrTran(oXML:_REDUCAOZ:_MENSAGEM:_ECF:_DADOSREDUCAOZ:_DATAREFERENCIA:Text,'-'))
	EndIf
	dDtGerXML:= dDtFinal
	cDataSFI := DtoS(dDtFinal) //AAAAMMDD
	cDtArq	 := StrZero( Day(dDtGerXML),2) + StrZero( Month(dDtGerXML),2) + cValToChar( Year(dDtGerXML) ) //formato: DDMMAAAA conforme Ato Cotepe ER 02.06
Else
	LjGrvLog( Nil, "Problema no conteúdo XML - Verifique se o XML gravado na Tabela " + IIf(cTpEnvio == "R","SFI","MDZ") + " está correto.",cXML)
	IIf(!Empty(cError), LjGrvLog( Nil, "Erro : ", cError), NIL)
	IIf(!Empty(cWarning), LjGrvLog( Nil, "Aviso : ", cWarning), NIL)
	cXML := "" //Apaga para que seja gerado corretamente
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}LPXTrPrXML
Trata o retorno - vindo da Resposta do XML
@param1 	cTipoArq ,String, tipo de envio (E)stoque ou (R)edz
@author  	Varejo
@version 	P12
@since   	26/06/2019
@return  	aRet, array, contendo {cRet,cXML} - cRet que pode variar (N,A,S,E) e cXML com o XML de Retorno
/*/
//--------------------------------------------------------
Function LPXTrPrXML(cTpEnvio	,cEnvXML	,cRetXML	,lConWSDL	,;
					lForceCon	)
Local aRet		:= {.F.,""}
Local aXML		:= {}
Local lRet		:= .T.
Local lApaga	:= .F.
Local cRet		:= ""
Local cPath		:= ""
Local cWarning	:= ""
Local cNmArqRsp := ""
Local cXMLTratR := ""
Local cDtArquivo:= ""
Local cProcID	:= "LPXTrPrXML"
Local cMotivo	:= ""
Local nHdlXMLRet:= 0
Local nX		:= 0
Local oWSDL		:= NIL
Local oXML		:= NIL

Default lConWSDL	:= NIL
Default lForceCon	:= .F.

If ValType(lConWSDL) <> "L"
	lConWSDL := .T.
	oWSDL:= LWSPGerWSD(.F.,lConWSDL)
	lRet := LWSPCnsStt(@oWSDL,lConWSDL)
	If !lRet
		lConWSDL := .F.
		oWSDL := NIL
		LWSPGerWSD(.T.,lConWSDL)
		lRet  := LWSPCnsStt(@oWSDL,lConWSDL)
	EndIf 
EndIf

lRet := LPXRetDatX(@cPath,@cEnvXML,@cTpEnvio,@cDtArquivo)

If lRet
	If cTpEnvio == "E"
		cDtArquivo	:= Substr(cDtArquivo,3,Len(cDtArquivo)) //formato: MMAAAA conforme Ato Cotepe ER 02.06
	EndIf
	
	If cTpEnvio == "R"
		cPath	 += PAF_DirRedZ + '\'
		cNmArqRsp:= "RespRedZ" + cDtArquivo + ".XML"
	ElseIf cTpEnvio == "E"
		cPath += PAF_DirStck + '\'
		cNmArqRsp:= "RespStck" + cDtArquivo + ".XML"
	EndIf
	
	//Estava dando erro quando tinha duas barras e não gerava o arquivo
	//portanto coloco aqui um ajuste para substituir 
	cPath := StrTran(cPath,"\\","\")
	
	//Geração do arquivo na pasta de retorno
	If Empty(AllTrim(cRetXML))
		lRet := .F.
	Else		
		If File(cPath + cNmArqRsp)
			nX := 0
			While !lApaga .And. nX < 5
				lApaga := (FErase(cPath + cNmArqRsp) > -1)
				If lApaga
					nX := 5
					lRet := .T.
				Else
					cWarning := "Arquivo [" + cNmArqRsp + "] não foi deletado - feche todos os programas que estão usando o arquivo"
					LjGrvLog( cProcID , cWarning, FError() )
					COnout(cWarning)
					If !IsBlind()
						Alert(cWarning)
					EndIf
					Sleep(1500)
					nX++
					lRet := .F.
				EndIf
			End
		EndIf
		
		If lRet
			nHdlXMLRet := FCreate(cPath + cNmArqRsp)
		EndIf

		If lRet .And. nHdlXMLRet > 0
			FCLOSE( nHdlXMLRet )
			LjGrvLog( cProcID , "Arquivo de retorno do XML gerado em [" + cNmArqRsp + "]")
			
			oXML := NIL
			/*Usado a função XMLParser pois o TXMLManager não retorna a parte do XML que precisa ser lida*/
			aXML := LPXLeReXML(cRetXML,@oXML)
			
			If Len(aXML) > 0
				
				If Empty(aXML[1]) .And. Empty(aXML[2]) .And. Empty(aXML[3])
					LjGrvLog( cProcID, "XML de Retorno não esperado", cRetXML)
					cXMLTratR := cRetXML
					cRet := "E"
					aXML := {"-","","Erro no tratamento do XML de retorno"}
				EndIf
				
				If aXML[3] == cSttWSAGUA .Or. lForceCon
				
					lRet := LWSPConRec(@oWSDL,aXML[1],lConWSDL)
					
					If lRet .And. oWSDL <> NIL
						If lConWSDL
							cXMLTratR := AllTrim(oWSDL:GetParsedResponse())
							nX := At(Upper("ConsultarProcessamentoArquivoResult:"),Upper(cXMLTratR))
							IF nX > 0
								nX += Len("ConsultarProcessamentoArquivoResult:")
								cXMLTratR := AllTrim(SubStr(cXMLTratR,nX,Len(cXMLTratR)))
								cXMLTratR := DecodeUTF8(cXMLTratR)
							Else 
								cXMLTratR := ""
							EndIf
						Else
							cXMLTratR := AllTrim(oWSDL:cConsultarProcessamentoArquivoResult) //somente para manter o entendimento que já é retornado um XML 
						EndIf
						
						/*Usado a função XMLParser pois o TXMLManager não retorna a parte do XML que precisa ser lida*/
						aXML := LPXLeReXML(cXMLTratR,@oXML)
						
						If oXML == NIL
							cMotivo := "Erro na leitura do retorno do método ConsultarProcessamentoArquivo" + PULALINHA
							cMotivo += aXML[1]  + PULALINHA
							cMotivo += aXML[2]
							cXMLTratR := ""
						Else
							If Empty(aXML[1]) .And. Empty(aXML[2]) .And. Empty(aXML[3])
								LjGrvLog( cProcID, "XML de Retorno não esperado", cXMLTratR)
								cXMLTratR := cRetXML
								cRet := "E"
								aXML := {"-","","Erro no tratamento do XML de retorno"}
							EndIf
							
							cMotivo := Upper("Método ConsultarProcessamentoArquivo") + Replicate(PULALINHA,2)
							cMotivo += Upper("Recibo: ") + aXML[1] + PULALINHA
							cMotivo += Upper("Situação Processamento: ") + PULALINHA 
							cMotivo += aXML[3]
						EndIf
						
						If cSttWSERRO $ Upper(aXML[3])
							cRet := "E" //Erro, deve ser tratado no monitor do PAF
						ElseIf cSttWSSUCE $ Upper(aXML[3])
							cRet := "S" //Sucesso, arquivo enviado e validado OK pela SEFAZ
						ElseIf cSttWSAGUA $ Upper(aXML[3])
							cRet := "A" //Aguardando, arquivo enviado e pendente na SEFAZ
						ElseIf cSttWSRECN $ LjRmvChEs(Upper(aXML[3]))
							cRet := "N"
						Else
							cRet := "E"
						EndIf
					EndIf
				
				ElseIf aXML[3] == cSttWSSUCE
					cRet := "S"
					cXMLTratR := cRetXML
				ElseIf aXML[3] == cSttWSERRO .Or. aXML[3] == cSttWSNGER   
					cRet := "E"
					cXMLTratR := cRetXML
				ElseIf cSttWSRECN $ LjRmvChEs(Upper(aXML[3]))
					cRet := "N"
				EndIf
				
				If !Empty(cMotivo)
					STPosMSG( "XML PAF-ECF - [RETORNO]" , cMotivo, .T., .F., .F.)
					LjGrvLog( cProcID, "XML PAF-ECF - [RETORNO]" , cMotivo)
				EndIf
				
				If Empty(cXMLTratR)
					cRet := "E" //Erro, deve ser tratado no monitor do PAF
				Else
					LjGrvLog( cProcID,"Retorno da SEFAZ",cXMLTratR)
					nHdlXMLRet := FOpen(cPath + cNmArqRsp,2)
					FWrite(nHdlXMLRet,cXMLTratR,Len(cXMLTratR))
					FCLOSE( nHdlXMLRet )
				EndIf
			EndIf
		Else
			cWarning := "Não Foi Possível Gerar Arquivo de retorno do envio do XML à SEFAZ. Verifique!"
			LjGrvLog( cProcID , cWarning , oWSDL)
			Alert(cWarning)
			cRet := "N" //Coloca não enviado para tentar revalidar o XML
			cXMLTratR := ""
		EndIf
	EndIf
EndIf

LWSPGerWSD(.T.,lConWSDL)
aRet[1] := cRet
aRet[2] := cXMLTratR

LjGrvLog( cProcID ,"Final do Envio", aRet)

Return aRet

//----------------------------------------------------
/*/
{Protheus.doc} LWSPCnsStt
COnsulta Status dos Metodos do Bloco X

@Param		nenhum
@author  	julio.nery
@version 	P12
@since   	04/02/2020
@return  	lRet , lógico , validação ok ? 
/*/
//--------------------------------------------------
Function LWSPCnsStt(oWsdl, lConWSDL)
Local lRet		:= .T.
Local cMetodo	:= "ConsultarStatusMetodosBlocoX"
Local cMSG		:= ""

Default oWsdl	:= NIL

If oWsdl == NIL
	oWsdl :=  LWSPGerWSD(.F.,lConWSDL)
EndIf

If oWsdl <> NIL
	
	If lConWSDL
		lRet := oWsdl:SetOperation( cMetodo )
	EndIf
	
	If lRet
		If lConWSDL
			lRet := LWSPExcWSD(oWsdl,lConWSDL)
		Else
			lRet := oWsdl:ConsultarStatusMetodosBlocoX()
			
			If ValType(lRet) <> "L"
				lRet := .F.
				cMSG := " Erro de WebService na execução do metodo " +;
						"'Consulta Status dos Metodos do Bloco X' - WebService SEFAZ"
			EndIf
		EndIf
		
		If !Empty(cMSG)
			LJRPLogProc(cMSG)
		EndIf
	EndIf
	
	If !lRet
		oWsdl := LWSPGerWSD(.T.,lConWSDL)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LPXEnvCnRe

Envia o cancelamento ou reprocessamento de arquivo
@author  Varejo
@version P12
@since   04/02/2020
@return  lRet
/*/
//-------------------------------------------------------------------
Function LPXEnvCnRe(lCancela, cXML , oWsdl , lConWSDL)
Local lRet		:= .F.
Local cMsg		:= ""
Local cMetodoCNC:= "CancelarArquivo"
Local cMetodoREP:= "ReprocessarArquivo"

Default oWsdl := NIL

If oWsdl == NIL
	oWsdl := LWSPGerWSD(.F.,lConWSDL)
EndIf

If oWsdl <> NIL

	lRet := .T.
	If lConWSDL
		lRet := oWsdl:SetOperation(IIf(lCancela,cMetodoCNC,cMetodoREP))
	EndIf
	
	If lRet		
		If lConWSDL
			cXML := _NoTags(cXML)
			lRet := oWsdl:SetValue(0,cXML)
		Else
			If lCancela
				lRet := oWsdl:CancelarArquivo(cXML)
			Else
				lRet := oWsdl:ReprocessarArquivo(cXML)
			EndIf
			
			If ValType(lRet) <> "L"
				lRet := .F.
				cMSG := " Erro de WebService na execução do metodo " +;
						 IIf(lCancela,cMetodoCNC,cMetodoREP)
			EndIf
		EndIf
		
		If !Empty(cMsg)
			LJRPLogProc(cMsg)
		EndIf
		
		If lRet
			lRet := LWSPExcWSD(@oWsdl,lConWSDL)
		Else
			LWSPErrWSD(@oWsdl,lConWSDL)
		EndIf
	Else
		LWSPErrWSD(@oWsdl,lConWSDL)
	EndIf
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}LPXCncRepX

Efetua o cancelamento ou reprocessamento de arquivo enviado

@param1		lCancela, lógico, Cancela ou Reprocessa XML ?
@param2 	cRecibo , String, Numero do Recibo do PAF
@param3 	cMotivo , String, Motivo do Reprocessamento
@param4		lConWSDL, lógico, tipo de conexao ativa
@author  	Julio.Nery
@version 	P12
@since   	05/02/2020
@return  	lRet, lógico, arquivo cancelado ou reprocessado ?
/*/
//--------------------------------------------------------
Function LPXCncRepX(lCancela,cRecibo,cMotivo,lConWSDL)
Local aRet	:= {}
Local lRet	:= .F.
Local lMvLjPdvPa:= LjxBGetPaf()[2]
Local aXMLRet := {}
Local cXML	:= ""
Local cMsg	:= ""
Local cMsgDesc:= ""
Local cMsgReci:= ""
Local cMsgOpe := ""
Local nMsgCod := -1
Local nX	:= 0	
Local oXML	:= NIL
Local oWsdl := NIL

If ValType(lConWSDL) <> "L"
	lConWSDL := .T.
	oWsdl:= LWSPGerWSD(.F.,lConWSDL)
	lRet := LWSPCnsStt(@oWsdl,lConWSDL)
	If !lRet
		lConWSDL:= .F.
		oWsdl:= NIL
		LWSPGerWSD(.T.)
		lRet := LWSPCnsStt(@oWsdl,lConWSDL)
	EndIf 
EndIf

If lRet
	cXML := '<?xml version="1.0" encoding="utf-8"?>'
	cXML += '<Manutencao Versao="1.0">'
	cXML += '<Mensagem>'
	cXML += '<Recibo>' + EncodeUTF8(Lower(cRecibo)) + '</Recibo>'
	cXML += '<Motivo>' + EnCodeUTF8(LjRmvChEs(cMotivo)) + '</Motivo>'
	cXML += '</Mensagem>'
	aXMLRet := LPXXmlAss(!lMvLjPdvPa, lTotvsPdv ,'</Manutencao>',cXML,cEmpAnt,cFilAnt)
	lRet := aXMLRet[1][1]
EndIf

If lRet
	cXML += aXMLRet[1][2]
	cXML += '</Manutencao>'
	
	// *** Envio do Dado para a SEFAZ *** //
	oWsdl:= LWSPGerWSD(.F.,lConWSDL)
	lRet := LPXEnvCnRe(lCancela, cXML , @oWsdl , lConWSDL)	
	
	If lRet
		If lConWSDL
			cXML := AllTrim(oWsdl:GetParsedResponse())
			If lCancela
				nX:= At(Upper("CancelarArquivoResult:"),Upper(cXML))
			Else
				nX:= At(Upper("ReprocessarArquivoResult:"),Upper(cXML))
			EndIf
			
			IF nX > 0
				If lCancela
					nX += Len("CancelarArquivoResult:")
				Else
					nX += Len("ReprocessarArquivoResult:")
				EndIf
				cXML := SubStr(cXML,nX,Len(cXML))
				cXML := DecodeUtf8(cXML)
			Else
				cXML := ""
			EndIf
		Else
			//somente para manter o entendimento que já é retornado um XML
			If lCancela
				cXML := AllTrim(oWsdl:cCancelarArquivoResult)
			Else
				cXML := AllTrim(oWsdl:cReprocessarArquivoResult)
			EndIf
		EndIf
	
		// *** Processamento do Retorno *** //
		If !Empty(cXML)
			oXML := TXMLManager():New()
			lRet := oXML:Parse(EncodeUTF8(cXML))
		EndIf
		
		If lRet .And. oXML <> NIL
			aXMLRet := oXML:DOMGetChildArray()
			For nX := 1 to Len(aXMLRet)
				If Upper(aXMLRet[nX][1]) == "RECIBO"
					cMsgReci := AllTrim(aXMLRet[nX][2])
					
				ElseIf Upper(aXMLRet[nX][1]) == Upper("SituacaoProcessamentoDescricao")
					cMsgDesc := AllTrim(Upper(aXMLRet[nX][2]))
					
				ElseIf Upper(aXMLRet[nX][1]) == Upper("SituacaoProcessamentoCodigo") .Or.;
					Upper(aXMLRet[nX][1]) == Upper("SituacaoOperacaoCodigo")
					nMsgCod := Val(AllTrim(aXMLRet[nX][2]))
				
				ElseIf Upper(aXMLRet[nX][1]) == Upper("SituacaoOperacaoDescricao")
					cMsgOpe := AllTrim(Upper(aXMLRet[nX][2]))
				EndIf
			Next nX
			
			If nMsgCod == -1
				lRet := .F.
			Else
				lRet := .T.
				cMsg := IIf(lCancela,"Cancelamento","Reprocessamento") + "- Retorno :" + cMsgDesc
				
				If !Empty(cMsg)
					LjGrvLog( Nil, cMsg)
				EndIf
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
Else
	LjGrvLog( Nil, "Problemas na assinatura do arquivo XML -" +;
				"Arquivo de " + IIf(lCancela,"Cancelamento","Reprocessamento") + " XML foi gerado sem assinatura" +;
				PULALINHA +;
				"Portanto não será possível prosseguir")
EndIf

aRet := {lRet,cXML,cMsgReci,cMsgDesc,nMsgCod,cMsgOpe}

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc}LPXXMLAgua
Busca todos os XML's que retornaram com aguardando da SEFAZ
para dar continuidade nas vaidações

@param1 	cTipoArq ,String, tipo de envio (E)stoque ou (R)edz
@author  	Julio.Nery
@version 	P12
@since   	12/02/2020
@return  	NIL 
/*/
//--------------------------------------------------------
Function LPXXMLAgua(cTipoArq)
Local lMvLjPdvPa:= LjxBGetPaf()[2]
Local lConWSDL:= .T.
Local lRet    := .T.
Local aFileRZ := {}
Local aFileES := {}
Local aRet	  := {}
Local nX	  := 0
Local dDtObrig:=""

dDtObrig := STDtIniBlX()

lRet := LWSPCnsStt( NIL , lConWSDL )
If !lRet
	lConWSDL:= .F.
	lRet := LWSPCnsStt( NIL , lConWSDL )
EndIf

If lRet .And. (Empty(cTipoArq) .Or. cTipoArq == "R")
	aFileRZ := STRedXML("V")
	If Len(aFileRZ) > 0 .And. (aFileRZ[1][1] > 0)
		For nX := 1 to Len(aFileRZ)
			aRet := LPXTrPrXML("R",aFileRZ[nX][2],aFileRZ[nX][3],lConWSDL)
			STRedXML("R",aFileRZ[nX][5],{aRet[1],aRet[2]}, NIL)
		Next nX
	EndIf
EndIf

If lRet .And. (Empty(cTipoArq) .Or. cTipoArq == "E")
	aFileES := STEstqXML(lMvLjPdvPa,"V",,,,,,,dDtObrig)
	If Len(aFileES) > 0 .And. (aFileES[1][1] > 0)
		For nX := 1 to Len(aFileES)
			aRet  := LPXTrPrXML("E",aFileES[nX][2],aFileES[nX][3],lConWSDL)			 
			STEstqXML(lMvLjPdvPa,"R",aFileES[nX][5],{aRet[1],aRet[2]},NIL)
		Next nX
	EndIf
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} LPXConCont

Comando de Consulta pendencias contribuinte no WS da SEFAZ
@param	 cXML, string, XML
@param	 oWSDL, objeto, conteudo do WSDL
@param	 lConsWSDL, lógico, é via WSDL ?
@author  Julio.Nery
@version P12
@since   12/02/2020
@return  lRet
/*/
//-------------------------------------------------------------------
Function LPXConCont(cXML , oWsdl , lConWSDL)
Local lRet		:= .F.

Local cMsg		:= ""
Local cMetodo	:= "ConsultarPendenciasContribuinte"

Default oWsdl := NIL

If oWsdl == NIL
	oWsdl := LWSPGerWSD(.F.,lConWSDL)
EndIf

If oWsdl <> NIL

	lRet := .T.
	If lConWSDL
		lRet := oWsdl:SetOperation(cMetodo)
	EndIf
	
	If lRet		
		If lConWSDL
			cXML := _NoTags(cXML)
			lRet := oWsdl:SetValue(0,cXML)
		Else
			lRet := oWsdl:ConsultarPendenciasContribuinte(cXML)
			
			If ValType(lRet) <> "L"
				lRet := .F.
				cMSG := " Erro de WebService na execução do metodo " + cMetodo
			EndIf
		EndIf
		
		If !Empty(cMSG)
			LJRPLogProc(cMSG)
		EndIf
		
		If lRet
			lRet := LWSPExcWSD(@oWsdl,lConWSDL)
		Else
			LWSPErrWSD(@oWsdl,lConWSDL)
		EndIf
	Else
		LWSPErrWSD(@oWsdl,lConWSDL)
	EndIf
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}LPXCnPeCon

Solicita e Trata retorno da Consulta Pendencia do Contribuinte

@param		lConWSDL, lógico, tipo de conexao ativa
@author  	Julio.Nery
@version 	P12
@since   	05/02/2020
@return  	lRet, lógico, arquivo cancelado ou reprocessado ?
/*/
//--------------------------------------------------------
Function LPXCnPeCon(lConWSDL)
Local aRet	:= {}
Local lRet	:= .F.
Local lLeXML:= .F.
Local lMvLjPdvPa:= LjxBGetPaf()[2]
Local aXMLRet := {}
Local oAux	:= {}
Local cXML	:= ""
Local cMsg	:= ""
Local cIE	:= ""
Local nX	:= 0	
Local oXML	:= NIL
Local oWsdl := NIL

If ValType(lConWSDL) <> "L"
	lConWSDL := .T.
	oWsdl := LWSPGerWSD(.F.,lConWSDL)
	lRet := LWSPCnsStt(@oWsdl,lConWSDL)
	If !lRet
		lConWSDL:= .F.
		oWsdl := NIL
		LWSPGerWSD(.T.)
		lRet := LWSPCnsStt(@oWsdl,lConWSDL)
	EndIf 
EndIf

If lRet
	cIE	 := StrTran(SM0->M0_INSC,"-")
	cIE	 := StrTran(cIe,".")
	cIE	 := Alltrim(cIe)
	cXML := '<?xml version="1.0" encoding="utf-8"?>'
	cXML += '<ConsultarPendenciasContribuinte Versao="1.0">'
	cXML += '<Mensagem>'
	cXML += '<IE>' + cIE + '</IE>'
	cXML += '</Mensagem>'
	aXMLRet := LPXXmlAss(!lMvLjPdvPa, lTotvsPdv ,'</ConsultarPendenciasContribuinte>',cXML,cEmpAnt,cFilAnt)
	lRet := aXMLRet[1][1]
EndIf

If lRet
	cXML += aXMLRet[1][2]
	cXML += '</ConsultarPendenciasContribuinte>'
	
	// *** Envio do Dado para a SEFAZ *** //
	oWsdl:= LWSPGerWSD(.F.,lConWSDL)
	lRet := LPXConCont(cXML , @oWsdl , lConWSDL)
	
	If lRet
		If lConWSDL
			cXML := AllTrim(oWsdl:GetParsedResponse())
			nX:= At(Upper("ConsultarPendenciasContribuinteResult:"),Upper(cXML))

			IF nX > 0
				nX += Len("ConsultarPendenciasContribuinteResult:")
				cXML := SubStr(cXML,nX,Len(cXML))
				cXML := DecodeUtf8(cXML)
			Else
				cXML := ""
			EndIf
		Else
			//somente para manter o entendimento que já é retornado um XML
			cXML := AllTrim(oWsdl:cConsultarPendenciasContribuinteResult)
		EndIf
	
		// *** Processamento do Retorno *** //
		If ! Empty(cXML)
			aXMLRet := {"",""}
			oXML := XmlParser( EncodeUTF8(cXML), "_" ,@aXMLRet[1],@aXMLRet[2])
			lRet := oXML <> NIL
		EndIf
		 
		If lRet
			ASize(aXMLRet,0)
			aXMLRet := {}
			//---- Devido o XML ser muito grande e ter vários nós diferente
			//---- efetuo o bloqueio da captura via array de suas posições
			//---- e somente retorno o XML para poder ser lido 
			If lLeXML				
				AAdd(aXMLRet,{"SituacaoOperacaoCodigo",oXML:_RespostaConsultarPendenciasContribuinte:_SituacaoOperacaoCodigo:Text})
				AAdd(aXMLRet,{"SituacaoOperacaoDescricao",oXML:_RespostaConsultarPendenciasContribuinte:_SituacaoOperacaoDescricao:Text})
				AAdd(aXMLRet,{"IE",oXML:_RespostaConsultarPendenciasContribuinte:_IE:Text})
				AAdd(aXMLRet,{"DataInicioObrigacao",oXML:_RespostaConsultarPendenciasContribuinte:_DataInicioObrigacao:Text})
				AAdd(aXMLRet,{"TransmiteEstoque",oXML:_RespostaConsultarPendenciasContribuinte:_TransmiteEstoque:Text})
				
				oAux := XmlChildEx(oXML:_RespostaConsultarPendenciasContribuinte, Upper("_ReducoesZ"))
				If oAux <> NIL .And. (XmlChildEx(oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ, "_ECF") <> NIL)
					If ValType(oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf) == "A"
						
						For nX := 1 to Len(oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf)
							AAdd(aXMLRet,{"RedZ_NumeroFabricacaoEcf_" + cValToChar(nX),oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_NumeroFabricacaoEcf:Text})
							AAdd(aXMLRet,{"RedZ_SituacaoPafEcfCodigo_" + cValToChar(nX),oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_SituacaoPafEcfCodigo:Text})
							AAdd(aXMLRet,{"RedZ_SituacaoPafEcfDescricao_" + cValToChar(nX),oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_SituacaoPafEcfDescricao:Text})
							
							//**** Reducao Z ****//
							AAdd(aXMLRet,{"RedZ_QuantidadePendencias_" + cValToChar(nX),oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_QuantidadePendencias:Text})
							If Val(oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_QuantidadePendencias:Text) > 0
								AAdd(aXMLRet,{"RedZ_PendCodigo_" + cValToChar(nX),oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_Pendencias:_Pendencia:_Codigo:Text})
								AAdd(aXMLRet,{"RedZ_PendDescricao_" + cValToChar(nX),oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_Pendencias:_Pendencia:_Descricao:Text})					
								AAdd(aXMLRet,{"RedZ_PendQtde_" + cValToChar(nX),oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_Pendencias:_Pendencia:_Quantidade:Text})
								
								If Val(oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_Pendencias:_Pendencia:_Quantidade:Text) > 0
									//Programar posteriormente para fazer um for aqui e colocar no nome o indice do recibo
									oAux := XMlChildEx(oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_Pendencias,"_Pendencia")
									If oAux <> NIL .And. XMlChildEx(oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_Pendencias:_Pendencia,"_Recibos")
										AAdd(aXMLRet,{"RedZ_PendRecibo_" + cValToChar(nX),;
											oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_Pendencias:_Pendencia:_Recibos:_Recibo:Text})
									EndIf
								EndIf
							EndIf
							
							AAdd(aXMLRet,{"RedZ_QuantidadeAvisos_" + cValToChar(nX),oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_QuantidadeAvisos:Text})
							If Val(oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_QuantidadeAvisos:Text) > 0
								AAdd(aXMLRet,{"RedZ_AvisoCodigo_" + cValToChar(nX),oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_Avisos:_Aviso:_Codigo:Text})
								AAdd(aXMLRet,{"RedZ_AvisoDescricao_" + cValToChar(nX),oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf[nX]:_Avisos:_Aviso:_Descricao:Text})
							EndIf
						
						Next nX
					Else
						AAdd(aXMLRet,{"RedZ_NumeroFabricacaoEcf",oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf:_NumeroFabricacaoEcf:Text})
						AAdd(aXMLRet,{"RedZ_SituacaoPafEcfCodigo",oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf:_SituacaoPafEcfCodigo:Text})
						AAdd(aXMLRet,{"RedZ_SituacaoPafEcfDescricao",oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf:_SituacaoPafEcfDescricao:Text})
						
						//**** Reducao Z ****//
						AAdd(aXMLRet,{"RedZ_QuantidadePendencias",oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf:_QuantidadePendencias:Text})
						If Val(oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf:_QuantidadePendencias:Text) > 0
							AAdd(aXMLRet,{"RedZ_PendCodigo",oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf:_Pendencias:_Pendencia:_Codigo:Text})
							AAdd(aXMLRet,{"RedZ_PendDescricao",oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf:_Pendencias:_Pendencia:_Descricao:Text})					
							AAdd(aXMLRet,{"RedZ_PendQtde",oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf:_Pendencias:_Pendencia:_Quantidade:Text})
							
							If Val(oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf:_Pendencias:_Pendencia:_Quantidade:Text) > 0
								//Programar posteriormente para fazer um for aqui e colocar no nome o indice do recibo  
								AAdd(aXMLRet,{"RedZ_PendRecibo",oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf:_Pendencias:_Pendencia:_Recibos:_Recibo:Text})
							EndIf
						EndIf
						
						AAdd(aXMLRet,{"RedZ_QuantidadeAvisos",oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf:_QuantidadeAvisos:Text})
						If Val(oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf:_QuantidadeAvisos:Text) > 0
							AAdd(aXMLRet,{"RedZ_AvisoCodigo",oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf:_Avisos:_Aviso:_Codigo:Text})
							AAdd(aXMLRet,{"RedZ_AvisoDescricao",oXML:_RespostaConsultarPendenciasContribuinte:_ReducoesZ:_Ecf:_Avisos:_Aviso:_Descricao:Text})
						EndIf
					EndIf
				EndIf
				
				//**** Estoque ****//
				oAux := XmlChildEx(oXML:_RespostaConsultarPendenciasContribuinte, "_ESTOQUES")
				If oAux <> NIL 
					AAdd(aXMLRet,{"Est_QuantidadePendencias",oXML:_RespostaConsultarPendenciasContribuinte:_Estoques:_QuantidadePendencias:Text})
					AAdd(aXMLRet,{"Est_QuantidadeAvisos",oXML:_RespostaConsultarPendenciasContribuinte:_Estoques:_QuantidadeAvisos:Text})
					
					oAux := NIL
					oAux := XmlChildEx(oXML:_RespostaConsultarPendenciasContribuinte:_Estoques, "_ESTOQUE")
					If oAux <> NIL
						AAdd(aXMLRet,{"Est_DataRef",oXML:_RespostaConsultarPendenciasContribuinte:_Estoques:_Estoque:_DataReferencia:Text})
						
						If Val(oXML:_RespostaConsultarPendenciasContribuinte:_Estoques:_QuantidadePendencias:Text) > 0
							AAdd(aXMLRet,{"Est_PendCodigo",oXML:_RespostaConsultarPendenciasContribuinte:_Estoques:_Estoque:_Pendencias:_Pendencia:_Codigo:Text})
							AAdd(aXMLRet,{"Est_PendDescricao",oXML:_RespostaConsultarPendenciasContribuinte:_Estoques:_Estoque:_Pendencias:_Pendencia:_Descricao:Text})
							AAdd(aXMLRet,{"Est_PendQtde",oXML:_RespostaConsultarPendenciasContribuinte:_Estoques:_Estoque:_Pendencias:_Pendencia:_Quantidade:Text})
							
							If Val(oXML:_RespostaConsultarPendenciasContribuinte:_Estoques:_Estoque:_Pendencias:_Pendencia:_Quantidade:Text) > 0
								//Programar para fazer um for aqui e colocar no nome o indice do recibo  
								AAdd(aXMLRet,{"Est_PendRecibo",oXML:_RespostaConsultarPendenciasContribuinte:_Estoques:_Estoque:_Pendencias:_Pendencia:_Recibos:_Recibo:Text})
							EndIf
						EndIf
						
						If Val(oXML:_RespostaConsultarPendenciasContribuinte:_Estoques:_QuantidadeAvisos:Text) > 0
							AAdd(aXMLRet,{"Est_AvisoCodigo",oXML:_RespostaConsultarPendenciasContribuinte:_Estoques:_Estoque:_Avisos:_Aviso:_Codigo:Text})
							AAdd(aXMLRet,{"Est_AvisoDescricao",oXML:_RespostaConsultarPendenciasContribuinte:_Estoques:_Estoque:_Avisos:_Aviso:_Descricao:Text})
						EndIf
					EndIf
				EndIf
				
				cMsg := "Consulta de Pendencias do Contribunte - Retorno" 
				LjGrvLog( Nil , cMsg , aXMLRet)
			Else
				cMsg := "Consulta de Pendencias do Contribunte - XML de Retorno" 
				LjGrvLog( Nil , cMsg , cXML)
			EndIf
		Else
			lRet := .F.
		EndIf
	Else
		cXML := ""
	EndIf
Else
	aSize(aXMLRet,0)
	aXMLRet := {}
	cXML := ""
	LjGrvLog( Nil, "Problemas na assinatura do arquivo XML - Verifique os certificados/path do certificados")
EndIf

aRet := {lRet,aXMLRet,cXML}

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc}LPXLeReXML

Efetua a leitura do XML de retorno e retorna
conforme ele vier do WS da SEFAZ

@param		cXML, string, conteudo XML
@param		oBjXML, objeto, objeto XML que pode ser enviado
@author  	Julio.Nery
@version 	P12
@since   	19/02/2020
@return  	aXML, array, {Recibo,Codigo Process,Descricao Process}
/*/
//--------------------------------------------------------
Function LPXLeReXML(cXML,oObjXML)
Local aXML	:= {"","","",""}
Local oXML	:= NIL

Default oObjXML := NIL

oXML := XmlParser( EncodeUTF8(cXML), "_" ,@aXML[1],@aXML[2] )
aXML := {"","","",""}

If	XmlChildEx(oXML, Upper("_RespostaManutencao")) <> NIL
	
	//Recibo
	If XmlChildEx(oXML:_RespostaManutencao, Upper("_Arquivo")) <> NIL .And.;
		XmlChildEx(oXML:_RespostaManutencao:_Arquivo, Upper("_Recibo")) <> NIL
		
		aXML[1] := oXML:_RespostaManutencao:_Arquivo:_Recibo:Text
		
	ElseIf XmlChildEx(oXML:_RespostaManutencao, Upper("_Recibo")) <> NIL
		aXML[1] := oXML:_RespostaManutencao:_Recibo:Text
	EndIf
	
	//Codigo do Processamento
	If	XmlChildEx(oXML:_RespostaManutencao, Upper("_Arquivo")) <> NIL .And.;
		XmlChildEx(oXML:_RespostaManutencao:_Arquivo, Upper("_SituacaoProcessamentoCodigo")) <> NIL
		
		aXML[2] := oXML:_RespostaManutencao:_Arquivo:_SituacaoProcessamentoCodigo:Text
	
	ElseIf XmlChildEx(oXML:_RespostaManutencao, Upper("_SituacaoProcessamentoCodigo")) <> NIL
		
		aXML[2] := oXML:_RespostaManutencao:_SituacaoProcessamentoCodigo:Text

	ElseIf XmlChildEx(oXML:_RespostaManutencao, Upper("_SituacaoOperacaoCodigo")) <> NIL
		aXML[2] := oXML:_RespostaManutencao:_SituacaoOperacaoCodigo:Text

	EndIf
	
	//Descricao do Processamento
	If	XmlChildEx(oXML:_RespostaManutencao, Upper("_Arquivo")) <> NIL .And.;
		XmlChildEx(oXML:_RespostaManutencao:_Arquivo, Upper("_SituacaoProcessamentoDescricao")) <> NIL
		
		aXML[3] := Upper(oXML:_RespostaManutencao:_Arquivo:_SituacaoProcessamentoDescricao:Text)
	
	ElseIf XmlChildEx(oXML:_RespostaManutencao, Upper("_SituacaoProcessamentoDescricao")) <> NIL
		
		aXML[3] := Upper(oXML:_RespostaManutencao:_SituacaoProcessamentoDescricao:Text)
		
	ElseIf XmlChildEx(oXML:_RespostaManutencao, Upper("_SituacaoOperacaoDescricao")) <> NIL
		aXML[3] := Upper(oXML:_RespostaManutencao:_SituacaoOperacaoDescricao:Text)

	EndIf
				
ElseIf XmlChildEx(oXML, Upper("_Resposta")) <> NIL
	
	If	XmlChildEx(oXML:_Resposta, Upper("_Arquivo")) <> NIL .And.;
		XmlChildEx(oXML:_Resposta:_Arquivo, Upper("_Recibo")) <> NIL
		
		aXML[1] := oXML:_Resposta:_Arquivo:_Recibo:Text
		
	ElseIf XmlChildEx(oXML:_Resposta, Upper("_Recibo")) <> NIL
		aXML[1] := oXML:_Resposta:_Recibo:Text
	EndIf
	
	//Codigo do Processamento
	If	XmlChildEx(oXML:_Resposta, Upper("_Arquivo")) <> NIL .And.;
		XmlChildEx(oXML:_Resposta:_Arquivo, Upper("_SituacaoProcessamentoCodigo")) <> NIL
		
		aXML[2] := oXML:_Resposta:_Arquivo:_SituacaoProcessamentoCodigo:Text
	
	ElseIf XmlChildEx(oXML:_Resposta, Upper("_SituacaoProcessamentoCodigo")) <> NIL
		
		aXML[2] := oXML:_Resposta:_SituacaoProcessamentoCodigo:Text

	ElseIf XmlChildEx(oXML:_Resposta, Upper("_SituacaoOperacaoCodigo")) <> NIL
		aXML[2] := oXML:_Resposta:_SituacaoOperacaoCodigo:Text

	EndIf
	
	//Descricao do Processamento
	If	XmlChildEx(oXML:_Resposta, Upper("_Arquivo")) <> NIL .And.;
		XmlChildEx(oXML:_Resposta:_Arquivo, Upper("_SituacaoProcessamentoDescricao")) <> NIL
		
		aXML[3] := Upper(oXML:_Resposta:_Arquivo:_SituacaoProcessamentoDescricao:Text)
	
	ElseIf XmlChildEx(oXML:_Resposta, Upper("_SituacaoProcessamentoDescricao")) <> NIL
		
		aXML[3] := Upper(oXML:_Resposta:_SituacaoProcessamentoDescricao:Text)
		
	ElseIf XmlChildEx(oXML:_Resposta, Upper("_SituacaoOperacaoDescricao")) <> NIL
		aXML[3] := Upper(oXML:_Resposta:_SituacaoOperacaoDescricao:Text)

	EndIf
	
	If	XmlChildEx(oXML:_Resposta, Upper("_Mensagem")) <> NIL
		aXML[4] := Upper(oXML:_Resposta:_Mensagem:Text)
	EndIf
	
EndIf

//Devolve o objeto preenchido para a função que o chamou
oObjXML := oXML

Return aXML

//--------------------------------------------------------
/*/{Protheus.doc}LPXVldObri

Conforme a Legislação, a vigencia do envio foi a partir de uma 
determinada data e com isso as reduções Z anteriores não serão 
validadas para o envio, evitando também problemas nos clientes 

@param		dDtObrig, data, data da Obrigação
@param		lForceEnv, lógico, força o envio ?
@author  	julio.nery
@version 	P12
@since   	20/02/2020
@return  	lObriga, lógico, Obrigatorio o envio?
/*/
//--------------------------------------------------------
Function LPXVldObri(dDtObrig,lForceEnv)
Local aRet	:= {}
Local cMsg  := ""
Local lObriga := .T.

aRet	:= LPXCnPeCon()
If Len(aRet) > 1 .And. ValType(aRet[2]) == "A"
	LjGrvLog( NIL, "Retorno de LPXCnPeCon", aRet[2])
	If Ascan(aRet[2], {|x| Upper(x[1]) == Upper("DataInicioObrigacao")}) > 0
		//Retorna a data no formato YYYY-MM-DD
		cMsg := AllTrim(StrTran(aRet[2][Ascan(aRet[2], {|x| x[1] == "DataInicioObrigacao"})][2],"-"))
		LjGrvLog( NIL, "Data da Obrigatoriedade retornada da SEFAZ -" +;
					" portanto não sera enviado dado com informa", cMsg)
		dDtObrig := STOD( cMsg )
		
		If Date() >= dDtObrig
			lObriga := .T.
		EndIf
	EndIf
EndIf

Return lObriga

//--------------------------------------------------------
/*/{Protheus.doc}LPXReWriXM

Altera XML que por ventura precisa ser ajustado para 
mostrar os dados certos no monitor de XML

@param		cErro, string, erro no XML
@author  	julio.nery
@version 	P12
@since   	26/02/2020
@return  	aRet, array, [1]Status [2]XML de Envio [3]XML de Retorno
/*/
//--------------------------------------------------------
Function LPXReWriXM(cErro,cXMLEnv,cXMLRet)
Local aRet		:= {"","",""}
Local aXML		:= {}
Local lRet		:= .F.
Local lConWSDL	:= NIL
Local cRecibo	:= ""
Local cXMLTratR := ""
Local nPos 		:= 0
Local oWSDL		:= NIL

Default cXMLRet := ""

LjGrvLog( NIL, "Inicio de LPXReWriXM")
If Upper("Erro 3001") $ cErro
	
	nPos := At(Upper("processada com sucesso e "),Upper( LjRmvChEs(cErro) ))
	If nPos > 0
		cRecibo := AllTrim(Substr(cErro,nPos + Len("processada com sucesso e "),Len(cErro))) //Captura do Recibo que esta como sucesso
		
		If !Empty(cRecibo)
			LjGrvLog( NIL, "Recibo encontrado como envio em Status 'Sucesso' - [" + cRecibo + "]")
			lRet := LWSPConRec(@oWSDL,cRecibo,@lConWSDL)
			LjGrvLog( NIL, "Retorno de LWSPConRec", lRet)
		EndIf
					
		If lRet .And. oWSDL <> NIL
			If lConWSDL
				cXMLTratR := AllTrim(oWSDL:GetParsedResponse())
				nX := At(Upper("ConsultarProcessamentoArquivoResult:"),Upper(cXMLTratR))
				IF nX > 0
					nX += Len("ConsultarProcessamentoArquivoResult:")
					cXMLTratR := AllTrim(SubStr(cXMLTratR,nX,Len(cXMLTratR)))
					cXMLTratR := DecodeUTF8(cXMLTratR)
				Else 
					cXMLTratR := ""
				EndIf
			Else
				cXMLTratR := AllTrim(oWSDL:cConsultarProcessamentoArquivoResult) //somente para manter o entendimento que já é retornado um XML 
			EndIf

			/*Usado a função XMLParser pois o TXMLManager não retorna a parte do XML que precisa ser lida*/
			aXML := LPXLeReXML(cXMLTratR)
			LjGrvLog( NIL, "Retorno de LPXLeReXML apos retorno da consulta do Recibo", aXML)
			LjGrvLog( NIL, "XML de Retorno apos a consulta do Recibo", cXMLTratR)
			
			IF Val(aXML[2]) == 1 //Sucesso
				aRet[1] := aXML[3]
				aRet[2] := ""
				aRet[3] := cXMLTratR
			Else
				aRet := {"","",""}
			EndIf
		EndIf
	EndIf
EndIf

LjGrvLog( NIL, "Final de LPXReWriXM", aRet)
Return aRet

//--------------------------------------------------------
/*/{Protheus.doc}LJPXPrdRes

Valida se o item de reserva ou não pode ser acumulado no XML

Obs: SL2 deve estar posicionado no registro a ser avaliado

@param		nenhum
@author  	julio.nery
@version 	P12
@since   	04/03/2020
@return  	lRet, lógico, pode acumular ?
/*/
//--------------------------------------------------------
Static Function LJPXPrdRes()
Local lRet := .F.

If !(AllTrim(SL2->L2_ENTREGA) == "3")
	lRet := .T.
EndIf

//Devido a um erro no TotvsPDV itens de
//retira foram gravados como entrega 
//quando estão no mesmo cupom
If AllTrim(SL2->L2_ENTREGA) == "3" .And.;
	Empty(AllTrim(SL2->L2_RESERVA)) .And.;
	Empty(AllTrim(SL2->L2_LOJARES))
	
	lRet := .T.
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}LJPXTranXM

Efetua o envio do XML

@param		XMLEnv, string,conteudo a ser enviado
@param		owsRecepcao, objeto, objeto contendo o WS
@param		lConWsDL, lógico, conexão WSDL?
@author  	julio.nery
@version 	P12
@since   	06/03/2020
@return  	lRet, lógico, enviado ?
/*/
//--------------------------------------------------------
Function LJPXTranXM(XMLEnv,oWsRecepcao,lConWSDL,cTpEnvio)
Local lRet := .F.

/* Por algum motivo, que eu não sei, o envio do XML só funciona via metodo WSDL 
(oWSDL:Enviar) portanto terei que resetar o metodo antigo, caso esteja, enviando o modo novo */
LWSPGerWSD(.T.)
lConWSDL := .T.
oWsRecepcao := LWSPGerWSD(.F.,lConWSDL) 
lRet := LWSPEnvWSD(XMLEnv,@oWsRecepcao,lConWSDL)

If !lRet
	LjGrvLog( NIL, "Envio do XML com lConWSDL (true) - deu falha sera enviado via Client WebService")
	lConWSDL := .F.
	LWSPGerWSD(.T.)
	oWsRecepcao := LWSPGerWSD(.F.,lConWSDL)
	lRet := LWSPEnvWSD(XMLEnv,@oWsRecepcao,lConWSDL)
EndIf

LjGrvLog(NIL,"Retorno do Metodo " + IIf(cTpEnvio == "E" , 'EnviarEstoque', "EnviarReducaoZ") , lRet)

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}LPXRtTrArq

tratamento do retorno da Transmissão de Arquivo

@param		lConWSDL, lógico, conexão WSDL ?
@param		oWsRecepcao, objeto, objeto que contem o retorno do WS
@author  	julio.nery
@version 	P12
@since   	06/03/2020
@return  	cRetXML, caracter, retorno do XML de Transmissão de Arquivo
/*/
//--------------------------------------------------------
Function LPXRtTrArq(lConWSDL, oWsRecepcao)
Local cRetXML:= ""
Local nX	 := 0

If lConWSDL
	cRetXML := AllTrim(oWsRecepcao:GetParsedResponse())
	nX		:= At(Upper("TransmitirArquivoResult:"),Upper(cRetXML))
	IF nX > 0
		nX += Len("TransmitirArquivoResult:")
		cRetXML := SubStr(cRetXML,nX,Len(cRetXML))
		cRetXML := DecodeUtf8(cRetXML)
	Else
		LJRPLogProc("Retorno da leitura de TransmitirArquivoResult não contem nada")
		cRetXML := ""
	EndIf
Else
	//somente para manter o entendimento que já é retornado um XML
	cRetXML := AllTrim(oWsRecepcao:cTransmitirArquivoResult)
EndIf

Return cRetXML

//--------------------------------------------------------
/*/{Protheus.doc}LJPItemEst

Retorna os itens vendidos no mes do estoque para 
montar o XML somente com aquilo que foi vendido 

@param		dDtFinal, data, data final do estoque
@author  	julio.nery
@version 	P12
@since   	11/03/2020
@return  	aProd, array, contem os produtos vendidos
/*/
//--------------------------------------------------------
Static Function LJPItemEst(dDtFinal)
Local aProd := {}
Local aArea := {}
Local nX	:= 0
Local dDtIni:= CtoD("01/" + StrZero(Month(dDtFinal),2) + '/' + cValToChar(Year(dDtFinal)))
Local cFilSL2 := ""

DbSelectArea("SL2")
Aadd(aArea,SL2->(GetArea()))
cFilSL2 := FwxFilial("SL2")

SL2->(DbSetOrder(2)) //L2_FILIAL, L2_PRODUTO, L2_EMISSAO
While !SL2->(Eof()) .And. SL2->L2_FILIAL == cFilSL2 
		
	If SL2->L2_EMISSAO >= dDtIni .And. SL2->L2_EMISSAO <= dDtFinal .And.;
		!Empty(AllTrim(SL2->L2_DOC)) .And. ;
		aScan( aProd, AllTrim(Upper(SL2->L2_PRODUTO)) ) == 0
	
		Aadd(aProd,AllTrim(Upper(SL2->L2_PRODUTO)))
	EndIf
	
	SL2->(DbSkip())
End

For nX := 1 to Len(aArea)
	RestArea(aArea[nX])
Next nX

Return aProd

//--------------------------------------------------------
/*/{Protheus.doc}LPXReenEst
Efetua o reenvio do XML de Estoque

@param	 	cXML, String, XML para ser processado
@author  	julio.nery
@version 	P12
@since   	12/03/2020
@return  	lRet  - função executada com sucesso 
/*/
//--------------------------------------------------------
Function LPXReenEst(cXML)
Local aRet	 := {"",""}
Local lSentOK := .F.
Local lConWSDL:= .T.
Local oXML	:= NIL
Local oWsdl := NIL

oWsdl := LWSPGerWSD(.F.,lConWSDL)
If !LWSPCnsStt(@oWsdl,lConWSDL)
	lConWSDL:= .F.
	LWSPCnsStt(@oWsdl,lConWSDL)
EndIf

oXML  := XmlParser(EncodeUTF8(cXML),"_", @aRet[1], @aRet[2])
If LPXRepXML( @oXML , @oWsdl , "E" , lConWSDL , 1 , .F.)
	lSentOK := LPXAjXML("E",@cXML)[1]
EndIf

Return lSentOK

//--------------------------------------------------------
/*/{Protheus.doc}LPXRmChrXM
Remove caracteres que podem dar problema no XML

@param	 	cDado, String, conteúdo a ser tratado
@author  	julio.nery
@version 	P12
@since   	17/04/2020
@return  	cRet, caracter, retorno 
/*/
//--------------------------------------------------------
Static Function LPXRmChrXM(cDado)
Local cRet := ""

cRet := cDado
cRet := StrTran(cRet,"<","")
cRet := StrTran(cRet,">","")
cRet := StrTran(cRet,"[","")
cRet := StrTran(cRet,"]","")
cRet := StrTran(cRet,"{","")
cRet := StrTran(cRet,"}","")
cRet := StrTran(cRet,"'","")

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} VldSitTri
Valida se a situação tributária do produto em questão(SLX ou SL2) corresponde
com a situação tributária em questão do SFI
@author  caio okamoto
@since   22/02/2022
@version p12
/*/
//-------------------------------------------------------------------
Static Function VldSitTri(cSitTrib, lServIsen,cContAlq, lIsSerProd ) 
Local lRet := .F. 

lRet := (lServIsen .AND. (SubStr(cSitTrib,1,2) == cContAlq)) .OR.;
			((!lIsSerProd) .AND. (SubStr(cSitTrib,1,1) == cContAlq) .AND.;
			 !SubStr(cSitTrib,1,2)$"IS|FS|NS" ) .OR.; 
			(lIsSerProd .AND. (cSitTrib == cContAlq)) 


Return lRet
