#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TBICONN.CH"   
#INCLUDE "LOJNFCE.CH" 
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'AUTODEF.ch'
#INCLUDE "FILEIO.CH"

Static cGetIdEnt	:= Nil 					// Codigo da entidade no TSS
Static oSAT			:= Nil					// Objeto SAT
Static aSATTrib		:= {}					// Tributação produto SAT
Static aSATImp		:= {}					// Lei da Transparencia SAT
Static cFabSat		:= NIl					// Fabricante do SAT
Static lUseSAT 		:= Nil
Static lIsPOS		:= NIL					// TotvsPDV?
Static aTotVenda	:= {0,0}				// [1] - Total da venda Fiscal [2] - Total da venda nao fiscal
Static dDtComSFZ	:= CtoD("  /  /    ")  	// Data da ultima Comunicação com o SEFAZ 
Static aCNS			:= {} 
Static aSATSO		:= nil					// Status Operacional do SAT
Static cCondIni		:= ""					// Tag abertura para texto condensado 
Static cCondFim		:= ""					// Tag fechamento para texto condensado
Static nLarCup		:= 0					// Largura do cupom
Static lShowMsg		:= .T.					// Validação para exibir a mensagem de validação do Layout SAT somente a primeira vez que acessar o sistema
Static aValItCP		:= {}					// Array com valor por item a ser enviado no XML de Complementar de ICMS
Static nValTotCP	:= 0					// Valor total a ser enviado no XML de Complementar de ICMS
Static lMFE			:= .F.
Static cLastSat		:= ""					//Ultimo layout de impressao do SAT executado
Static cSiglaSat	:= LjSiglaSat()			//Retorna sigla do equipamento que esta sendo utilizado
Static lIntegrador	:= .T.
Static nEnvEmail	:= 0					//Indica se irá enviar o comprovante SAT por e-mail

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSATInicia
Inicia o aparelho SAT
@param   	
@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	cRet - Numero sessao
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LJSATInicia(lRecovery)

Local lRet			:= .F.								// Retorno Função
Local aSATConsultar	:= {}								// Retorno consultar SAT
Local cRetorno		:= ""								// Retorno 
Local cMensagem		:= ""  
Local nX			:= 0								// Contador
Local cMVVERSAT		:= SuperGetMv("MV_VERSAT",,'0.07')	// Versão do layout do arquivo de dados do AC(Aplicativo Comercial)
Local nSATVer		:= 0								// Versão do Equipamento SAT
Local dDate			:= CtoD("")							// Date()
Local cVerAtual		:= "0.07"							// Versão corrente do layout SAT
Local dDtVer07		:= "30/06/2017"						// Data vigente para o layout SAT (0.07)
Local cAviso		:= ""
Local lAutomato 	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default lRecovery	:= .F.

If ValType(cMVVERSAT) <> 'C'
	Help(" ", 1, "Help", "Houve um Problema", "Ajuste o tipo do parâmetro MV_VERSAT para o tipo 'caracter'.", 1, 0 )
	LjGrvLog( "SAT", "Tipo do Parametro MV_VERSAT diferente de Caracter." )
	Return .F.	
EndIf

//Limpa arquivos da pasta de processamento Mfe para que 
//não atrapalhe os comandos caso fique alguma "sujeira"
If lMFE
	LjCleanFile()
EndIf	

//Valida versão do binário
If GetBuild() >= "7.00.131227A-20151103"
	If oSAT == Nil .And. !lMFE .Or. (lMFE .And. !lIntegrador)
 		oSAT := LJCSAT():New()
	ElseIf ValType(oSAT) <> "O"
		If !lMFE
			Alert("LJCSAT - Verifique se seu repositório está atualizado para o SAT.")
			Return .F.	
		EndI	
	EndIf	

	If ValType(oSAT) == "O"
		If oSAT:oTotvsAPI:lAtivo
			lRet := .T.
		Else
			lRet := .F.
		EndIf			
	EndIf	
	
	//Valida se existe DLL SAT
	If (lMFE .And. !lIntegrador) .And. !lAutomato//Quando execução via robô não há necessidade de verificar DLL
		lRet := lRet .And. LjSatValDll()
	Else
		lRet := .T.	
	EndIf
	
	If lRet .And. !lRecovery
		//Valida se o SAT esta operando
		If lMFE .And. lIntegrador
			LjVrfMFE()
		EndIf

		aSATConsultar := LJSATComando({"12","ConsultarSAT",LJSATnSessao()}) 
		cRetorno := LJSATTrataRetorno("ConsultarSAT",aSATConsultar)
		
		If cRetorno == "OK" .OR. lAutomato 
			If Upper(cFabSat) == "EMULADOR" .Or. ( lMFE .And. lIntegrador .And. !Empty(SuperGetMV("MV_SATTEST",,"")))
				lRet := .T.
			Else

				lRet := LJSatComunic()		

				If lRet
					nSATVer := Val(LjSatGetSO()[20])
					dDate   := Date()
					
					// Validação do Layout SAT versão (0.07) 
					If nSATVer < Val(cVerAtual)
						If DtoC(dDate) > dDtVer07
							cAviso := "Foi identificado que a versão de layout do equipamento "+cSiglaSat+" está desatualizada." + CHR(10) + CHR(13)
							cAviso += "Versão do Equipamento "+cSiglaSat+"	(" + cValToChar(nSATVer) + ")" + CHR(10)
							cAviso += "Versão do Layout Atual	(" + cVerAtual + ")" + CHR(10) + CHR(13)
							cAviso += "Favor atualizar o equipamento "+cSiglaSat+" caso contrário não será possível realizar vendas." + CHR(10) + CHR(13)
							cAviso += "Para mais informações consulte nossa FAQ "+cSiglaSat+" em: http://tdn.totvs.com/pages/viewpage.action?pageId=212899653"
							lRet := .F.
						ElseIf lShowMsg
							cAviso := "Foi identificado que seu equipamento "+cSiglaSat+" está utilizando a versão de layout (" + cValToChar(nSATVer) + ")." + CHR(10) + CHR(13)
							cAviso += "A partir de 01/07/2017 será obrigatório a utilização do equipamento "+cSiglaSat+" na versão (" + cVerAtual + "), pois em versões anteriores ocorrerá rejeições na SEFAZ." + CHR(10) + CHR(13)
							cAviso += "Caso o equipamento não seja atualizado até " + dDtVer07 + ", não será possível realizar vendas após esta data!" + CHR(10) + CHR(13)
							cAviso += "Para mais informações consulte nossa FAQ SAT em: http://tdn.totvs.com/pages/viewpage.action?pageId=212899653"
							
							lShowMsg := .F.
						EndIf
						
						If !Empty(cAviso)
							STPosMSG( "ATENÇÃO!!" , cAviso, .T., .F., .F.)
						EndIf
												
					ElseIf cMVVERSAT < cVerAtual
						cMensagem := "O parâmetro MV_VERSAT está diferente da versão homologada! Favor alterar para " +cVerAtual+" !"  
						Alert(cMensagem) 
						lRet:= .F. 
					EndIf
					
				EndIf
			EndIf
		Else		
			cMensagem := "Falha no comando de abertura do "+cSiglaSat+"" + CHR(10) + CHR(13)		
								
			If Len(aSATConsultar) > 0
				For nX:= 1 to Len(aSATConsultar)
					If !(AllTrim(aSATConsultar[nx]) $ "Header|Erro")
						cMensagem += aSATConsultar[nx] + CHR(10) + CHR(13)
					EndIf	
				Next
			EndIf
			
			cMensagem +=	" SOLUÇÃO: Verifique se a instalação do equipamento foi feita corretamente";
							+ " e se é possível efetuar os testes de comunicação do equipamento com o PDV e com a SEFAZ pelo software do fabricante." + CHR(10) + CHR(13);
							+ "Verifique nossa FAQ "+cSiglaSat+" em: tdn.totvs.com"
			
			If STFIsPOS()
				MsgInfo(cMensagem)
			Else
				Alert(cMensagem)
			EndIf
			
			lRet := .F.	
		EndIf
	EndIf
Else
	cMensagem := "ATENÇÃO - Para utilização do "+cSiglaSat+" é necessário que atualize a versão do seu binário." + CHR(10) + CHR(13) ;
		+ "Versão atual: " + GetBuild()	 + CHR(10) + CHR(13) ;
		+ "Versão minima: 7.00.131227A-20151202"
	Alert( cMensagem )
	LjGrvLog(Nil,cMensagem)
	lRet := .F.
EndIf

If lRet .And. !lRecovery .AND. !LJSATVlSer()
	If !lAutomato//Quando executado via robo a função LJSATVlSer() retorna falso por conta da falta do equipamento SAT 
		lRet := .F.
	Endif	
EndIf

Return lRet
	
//-------------------------------------------------------------------
/*/{Protheus.doc} LJSATnSessao
Gera número aleatório de 6 dígitos
	
@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	cRet - Numero sessao
/*/
//-------------------------------------------------------------------
Function LJSATnSessao()

Local cRet			:= ""				// Numero de sessao
Local cArqSessao	:= ""
Local cUltSessao 	:= "" 
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local nUltSessao	:= 0

If !lAutomato
	/*------------------------------------------------------------------
		Tag [sequence] criada no arquivo SIGALOJA.INI para controlar
		a sequência das sessões enviadas ao SAT, para que não ocorra
		a repetição das últimas 100 sessões.
	------------------------------------------------------------------*/
	cArqSessao := GetClientDir() + "sessaosat.txt"
	cUltSessao := GetPvProfString("SEQUENCE", "SESSAO", "", cArqSessao)
	nUltSessao := Val(cUltSessao)

	If nUltSessao == 0 .Or. nUltSessao == 999999
		nUltSessao := 000001
	Else
		nUltSessao := nUltSessao + 1
	EndIf

	cRet := StrZero(nUltSessao, 6)

	WritePProString("SEQUENCE", "SESSAO", cRet, cArqSessao)
Else
	/*------------------------------------------------------------------
		Para o robo continua gerando um número de sessão aleatório,
		pois não consegue acessar o arquivo sessãosat.txt que fica
		na pasta do SmartClient.
	------------------------------------------------------------------*/
	cRet := STRZERO(RANDOMIZE(1,999999),6)

	While cRet == cUltSessao
		cRet := STRZERO(RANDOMIZE(1,999999),6)
	EndDo
Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSATProceSessao
Retorna numeração última sessao processada

@param
@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	cSessaoProcessada - Retorna numeração última sessao processada
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LJSATProceSessao()

Local cSessaoProcessada := ""		// Retorno função

If oSAT <> Nil
	cSessaoProcessada := oSAT:cUltimaSessao
EndIf
	
Return cSessaoProcessada

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSATComando
Enviar comando para o SAT

@param   	aParam 			Parâmetros do comando SAT
@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	lRet - Retona se o comando foi executado
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LJSATComando( aParam, lCompICMS )

Local aRet				:= {}						// Retorno função
Local cRetorno			:= ""						// Retono String da classe do SAT
Local oParams			:= Nil						// Objeto parametros
Local nX				:= 0						// Contador
Local lEnviaDadosVenda	:= .F.						// Se o comando é de enviar dados para venda
Local lEnviaDadCnc		:= .F.			
Local lConsulSefaz      := .F.						// Se Consulta Sefaz
Local lBlindagemValid	:= ExistFunc("LjBldValid")	// Verifica se existe a função que faz a blindagem do SAT
Local lRet				:= .T.						// Retorno
Local aRetInfo			:= {}
Local cXMLRet			:= ""
Local cXMLEnv			:= ""
Local cSerie			:= ""
Local cStrTokArr2		:= "StrTokArr2"				// Se existe esta função na Lib
Local aRetMFE			:= {}
Local nTipoNota			:= IIF(lMFE, 2, 1) 			// 1=SAT,2=MFE
Local cTipoNota			:= IIF(nTipoNota == 1, "SAT", "MF-e")
Local lAutomato 		:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local cCfeSat			:= ""
Local aRetDados			:= ""

Default aParam 			:= {}
Default lCompICMS		:= .F.

LjGrvLog("SAT"," LJSATComando - Inicio", , .T. )

If Len(aParam) < 3
	LjGrvLog( "SAT", ">>NC<< Uso indevido da Rotina - LJSATComando - Parametros Recebidos < 3")
ElseIf	Len(aParam) >= 2
	lEnviaDadosVenda	:= aParam[2] == "EnviarDadosVenda" .OR. aParam[2] == "EML_EnviarDadosVenda" //verifica se o comando enviado é de venda
	lEnviaDadCnc		:= aParam[2] == "CancelarUltimaVenda" .OR. aParam[2] == "EML_CancelarUltimaVenda"	
EndIf 

If lEnviaDadosVenda
	If lBlindagemValid .AND. !LjBldValid(nTipoNota,,cTipoNota)		//Blindagem SAT/MF-e
		lRet := .F.
	EndIf
EndIf

If lRet
	If lEnviaDadosVenda
		LjGrvLog( "SAT_VENDA", "ID_INICIO" )
		LjGrvLog( SL1->L1_NUM, "Envio de comando de Venda para o SAT" )
	Else
		LjGrvLog( "SAT", "Envio de comando para o SAT - Inicio" )
	EndIf
	
	If lEnviaDadCnc
		LjGrvLog( "SAT_CNC", "ID_INICIO" )
		LjGrvLog( SL1->L1_NUM, "Envio de comando de cancelamento para o SAT" )	
	EndIf

	If (lEnviaDadCnc .OR. lEnviaDadosVenda) .AND. !LJSATCDataHora()
		lRet := .F.	
	EndIf
 
EndIf

If lRet

	LjGrvLog( "SAT", "Parametros enviados para executar no SAT - aParam: ", aParam ) 

	If Len(aparam) >= 2 .And. ( Upper(aparam[2]) == "CONSULTARSTATUSOPERACIONAL" .Or. Upper(aparam[2]) == "CONSULTARSTATUSOPERACIONALMFE")
		lConsulSefaz := .T.
	EndIf

	If cFabSat = NIL
		If lIsPos = NIL
			lIsPos := STFIsPOS()	
		EndIf
		If lIsPos
			cFabSat := STFGetStation("FABSAT")
		Else
			cFabSat := LjGetStation("FABSAT")
		EndIf
	EndIf

	LjGrvLog( "SAT", "Fabricante equipamento/modelo - cFabSat(LG_FABSAT): ", cFabSat)
	
	If oSAT <> Nil  .Or. lMFE
		LjGrvLog( "SAT", "Objeto SAT da instacia LJCSAT - oSAT foi iniciado")
		//Se for emulador SAT, coloca "EML" no prefixo, pois a tipagem de parâmetros e retorno é diferente
		If !lMFE .And. Upper(cFabSat) == "EMULADOR"
			aParam[2] := "EML_"+aParam[2]
		EndIf		

		If lEnviaDadosVenda .Or. lEnviaDadCnc
			If lEnviaDadosVenda
				LjGrvLog( "SAT", "Efetua gravacao da sessao em caso de recuperar a venda: ", aParam[3])
			Else
				LjGrvLog( "SAT_CNC", "Efetua gravacao da sessao em caso de recuperar o cancelamento: ", aParam[3])
			EndIf
			If !lAutomato
				WritePProString("SAT","SESSAO",aParam[3], GetClientDir() + "sessaosat.txt")
			Endif			
		EndIf
	
		If lMFE .And. lIntegrador
			If lEnviaDadosVenda
				//Comando para o integrador fiscal efetuar a venda quando utilizar MF-e
				LjEnvVenda(aParam[5],aParam[3])
			EndIf
			LjMsgRun("Aguardando retorno do MF-e..." ,,{ || aRetMFE := LjTratMfe(aParam[2]) })
			If Len(aRetMFE) > 0 .And. Len(aRetMFE[1]) > 1
				cRetorno := aRetMFE[1][2]
			EndIf	
		Else
			oSAT:cUltimaSessao := aParam[3]
			oParams := oSAT:PrepParam(aParam)
			
			LjGrvLog("SAT"," LJSATComando - oParams ", oParams )
			
			If lAutomato//Quando robô simula o retorno do xml com a função TestXmlSat
				cRetorno := aParam[3]+STATICCALL(LJ701SATTESTSUITE,TestXmlSat)
			Else			
				cRetorno := oSAT:EnviarCom(oParams)
				LjGrvLog("SAT"," LJSATComando - EnviarCom -> cRetorno ", cRetorno )		
			Endif
		EndIf

		If lConsulSefaz // usada essa função para que se mantenha as posições do Array caso algum seja enviando em branco
			/*
			Protegemos a execução da função StrTokArr2, pois como o robopatch utiliza a primeira versão da build para gerar os pacotes,
			esses pacotes podem não possuir essa função, causando o erro "Invalid Type Function" em tempo de execução.
			Esse procedimento foi recomendado pela equpe de TEC.
			*/
			If ExistFunc(cStrTokArr2)
				aRet := &cStrTokArr2.(cRetorno, "|",.T.)
			Else
				LjGrvLog( "SAT", "Função StrTokArr2 não compilada no RPO. Por favor, atualize a build." )
			EndIf
		Else
			aRet := STRTOKARR(cRetorno, "|")
		EndIf	

		LjGrvLog( "SAT", "Tamanho array de retorno comando para o equipamento aRet:", Len(aRet) )
	
		If Len(aRet) > 0
			For nX:= 1 to Len(aRet)
				If nX <> 5
					LjGrvLog( "SAT", "Varrendo Array de retorno aRet:"+cValToChar(nX), aRet[nX] )
				EndIf	
			Next			
		EndIf

		If lEnviaDadosVenda

			If Len(aRet) >= 4 .And. Len(aParam) > 4

				If Len(aRet) >= 7
					// Grava o DOC da venda no arquivo sessaosat para caso precise recuperar a venda q foi enviada para o SAT
					cCfeSat := SubStr(aRet[7],4,Len(aRet[7]))
					aRetDados := LjSatTrChv(cCfeSat)
					If !lAutomato
						WritePProString("SAT","DOC",aRetDados[6], GetClientDir() + "sessaosat.txt")
					Endif
					LjGrvLog("SAT","Grava DOC no arquivo sessaosat.txt")
				EndIf
				
				LjGrvLog("SAT","Grava registro da venda na MH2")

				cXMLEnv := aParam[5]	//Xml de envio

				//Gravação do log da venda
				//Retorno de venda com sucesso
				If Val(aRet[2]) == 6000

					cXMLRet := Decode64(aRet[5])	//Xml de retorno

					If !Empty(cXMLRet)
						//Pega numero Doc e Serie
						aRetInfo := LJSATRetDoc(cXmlRet,aRet,.T.)

						//Recupera a Serie
						cSerie := If(!Empty(SL1->L1_SERIE),SL1->L1_SERIE,STFGetStation("SERIE",,.F.))

						If Len(aRetInfo) >= 3 
							LjGrvLogSAT(;
											cSerie									,; 	//Serie
											aRetInfo[1]								,;	//Doc
											aRetInfo[3]								,;	//Chave
						 					cXMLEnv									,;	//Xml de envio
					 						cXMLRet									,;	//Xml de retorno
					 						IIf(lCompICMS, "COMPLEMENT", "VENDA")	,;	//Tipo
					 						"SUCESSO"								; 	//Status
										)
						EndIf
					EndIf
	
				//Venda com erro
				Else
					LjGrvLogSAT(;
								/*serie da venda*/,;
								/*numero da venda*/,;
								/*chave da venda*/,;
								cXMLEnv,;
								/*xml retorno*/,;
								IIf(lCompICMS, "COMPLEMENT", "VENDA"),;
								"ERRO",;
								IIf( Len(aRet) > 1 , aRet[2], "Retorno inesperado.") + "-" + ;
								IIf( Len(aRet) > 3 .And. Type(aRet[4])=="C", DecodeUTF8(aRet[4]), "Retorno inesperado."))
				EndIf

			Else
				LjGrvLog( "SAT", "Variavel aRet", aRet)
				LjGrvLog( "SAT", "Variavel aParam", aParam)
			EndIf
		EndIf

	Else
		LjGrvLog( "SAT", "Objeto não iniciado oSAT")
	EndIf
	If lEnviaDadosVenda
		LjGrvLog( "SAT_VENDA", "ID_FIM")
	ElseIf lEnviaDadCnc
		LjGrvLog( "SAT_CNC", "ID_FIM")
	Else
	 	LjGrvLog( "SAT", "Envio de comando para o SAT - Fim" )
	EndIf	
EndIf

LjGrvLog("SAT"," LJSATComando - Fim - Retorno -> aRet", aRet )			

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSatUltimo
Cancelar ultima venda no processo de recovery da venda caso 
não tenha sido registrada todas informações no sistema  
@param   	
@author  	Varejo
@version 	P11.8
@since   	07/03/2016
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LJSatUltimo(lRecovery)

Local aRet		:= {}
Local cPass		:= STFGetStation("CODSAT",,.F.) 			//Retorna o código de ativação do SAT
Local cCOd		:= ""
Local lRet		:= .T.
Local aVal		:= {}
Local cArqSessao:= GetClientDir() + "sessaosat.txt"
Local cXML		:= ""
Local lPOS 		:= STFIsPOS() 								//Pos?
Local lFront	:= IIF(nModulo == 23 .AND. !lPOS,.T.,.F.)  	//Front?
Local lCancel	:= .F. 										//Conseguiu cancelar?
Local cLiMsg	:= "" 										//Alimenta o LI_MSG para enviar o doc de cancelamento para retaguarda quando for processado
Local cNFisCanc	:= "" 										//Doc de cancelamento do sat
Local lLoja		:= nModulo == 12

Default lRecovery := .F.

LjGrvLog( "SAT", "Processo de Recuperacao de Venda - Inicio " )
	
cCOd := GetPvProfString("SAT","SESSAO","",cArqSessao )	
LjGrvLog( "SAT", "Codigo da sessao recuperado do arquivo:"+cArqSessao, cCOd )

aRet := GetConsNS()
If Len(aRet) == 0
	If lMFE .And. lIntegrador
		LjConsSess(cCOd)
	EndIf
	aRet := LJSATComando({"12","ConsultarNumeroSessao",LJSATnSessao(), cPass,cCOd})
EndIf

LjGrvLog( "SAT", "Tamanho do array retornado do comando enviado ao SAT - Len(aRet): ", Len(aRet))
If Len(aRet) > 2 .And. Val(aRet[2]) == 6000 //retorno de sucesso
	LjGrvLog( "SAT", "Venda recuperada do equipamento com sucesso" )
	
	cXML := Decode64(aRet[5]) //xml
	
	If !Empty(cXML)
		//instancia um objeto da classe TXML Manager
		oExtratoSAT := TXMLManager():New()

		//executa o PARSE na string XML
		lRet := oExtratoSAT:Parse( cXML )
		
		LjGrvLog("SAT","Efetuou o Parse do XML retornado do equipamento - lRet", lRet)
		
		If !lRet
			If !Empty( oExtratoSAT:Error() )
				LjGrvLog( "SAT", "ERRO AO EXECUTAR O METODO PARSE: ", oExtratoSAT:Error() )
			ElseIf !Empty( oExtratoSAT:Warning() )
				LjGrvLog( "SAT", "AVISO AO EXECUTAR O METODO PARSE: ", oExtratoSAT:Warning() )
			EndIf
		EndIf 		
	Else
		lRet := .F.
	EndIf

	If lRet .And. oExtratoSAT <> Nil

		LjGrvLog( "SAT", "Efetuou o Parse do cXML retornado" )

		aAdd(aVal,SUBSTR(OEXTRATOSAT:XPathGetAtt( "/CFe/infCFe", "Id" ),4))  //chave da venda

		If OEXTRATOSAT:XPathHasNode( "/CFe/infCFe/dest" )
			If OEXTRATOSAT:XPathHasNode( "/CFe/infCFe/dest/CPF" )
				aAdd(aVal,OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/dest/CPF" ))  //CPF
			ElseIf OEXTRATOSAT:XPathHasNode( "/CFe/infCFe/dest/CNPJ" )
				aAdd(aVal,OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/dest/CNPJ" ))  //CNPJ
			EndIf
		EndIf

		aAdd(aVal,OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/ide/numeroCaixa" ))  //numero do caixa

		If lRecovery
			DbSelectArea("SL2")
			SL2->(DBSetorder(1)) //L2_FILIAL + L2_NUM
			If SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
				While !SL2->(EOF()) .And. SL2->(L2_FILIAL+L2_NUM) == xFilial("SL2")+SL1->L1_NUM
					If SL2->(RecLock("SL2",.F.))				
						SL2->L2_DOC := OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/ide/nCFe" )
						SL2->(MsUnlock())
					EndIf
					SL2->(DbSkip())
				EndDo
		    EndIf

			If SL1->(RecLock("SL1",.F.))
				SL1->L1_DOC 		:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/ide/nCFe" )
				SL1->L1_KEYNFCE 	:= SUBSTR(OEXTRATOSAT:XPathGetAtt( "/CFe/infCFe", "Id" ),4)
				SL1->L1_ESPECIE 	:= "SATCE"
				SL1->L1_SERSAT 	:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/ide/nserieSAT" )
				SL1->(MsUnlock())
			EndIf
		EndIf
		
		LjGrvLog( "SAT", "Chamada da funcao LJSatxCanc para cancelamento da ultima venda" )
		lCancel := LJSatxCanc(.F., @cNFisCanc,aVal, lRecovery)
		
		If lCancel
			LjSaCtrCnc(.F.,.T.,.F.,.F.,"") //Apaga o arquivo sinal de recuperação de cancelamento			
		EndIf
		
		If lCancel .And. lRecovery 
			LjSatAjTab(	lFront	, lLoja 		,	lPOS	,	cNFisCanc,;
						@cLiMsg	, OEXTRATOSAT	)
		Else
			LjGrvLog( "SAT", "Não foi possivel efetuar o cancelamento" )
		EndIf
	Else
		LjGrvLog( "SAT", "Nao conseguiu efetuar o Parse do cXML retornado" )
	EndIf
EndIf
SetConsNS()
WritePProString("SAT","SESSAO","", cArqSessao)

LjGrvLog( "SAT", "Processo de Recuperacao de Venda - Fim" )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSATTrataRetorno
Trata o Retorno do comando SAT

@param   	cComando		Comando enviado ao SAT
@param   	aParam 			Retorno do comando enviado ao SAT
@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	aRet
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LJSATTrataRetorno(cComando,aParam)

Local cRet				:= ""		// Retorno da função

If Len(aParam) > 0
	
	Do Case
	
		Case Upper(cComando) == Upper("AtivarSAT")
		
			If Len(aParam) > 1
				Do Case
				
					Case aParam[2] == "04000"
								
						cRet := "OK"
				
					Case aParam[2] == "04098"			
						
						cRet := "EM_PROCESSAMENTO"
						
					OtherWise
						
						cRet := "ERRO"
						
				EndCase
			Else
				cRet := "ERRO"	
			EndIf	
						
		Case Upper(cComando) == Upper("ComunicarCertificadoICPBRASIL")
		
			If Len(aParam) > 1
				Do Case
				
					Case aParam[2] == "05000"
								
						cRet := "OK"
				
					Case aParam[2] == "05098"			
						
						cRet := "EM_PROCESSAMENTO"
						
					OtherWise
						
						cRet := "ERRO"
						
				EndCase
			Else
				cRet := "ERRO"	
			EndIf				
							
		Case Upper(cComando) == Upper("EnviarDadosVenda")
			
			If Len(aParam) > 1		
				Do Case
				
					Case aParam[2] == "06000"
								
						cRet := "OK"
				
					Case aParam[2] == "06098"			
						
						cRet := "EM_PROCESSAMENTO"
						
					OtherWise
						
						cRet := "ERRO"
						
				EndCase
			Else
				cRet := "ERRO"	
			EndIf				
									
		Case Upper(cComando) == Upper("CancelarUltimaVenda")

			If Len(aParam) > 1			
				Do Case
				
					Case aParam[2] == "07000"
								
						cRet := "OK"
				
					Case aParam[2] == "07098"			
						
						cRet := "EM_PROCESSAMENTO"
						
					OtherWise
						
						cRet := "ERRO"
						
				EndCase
			Else
				cRet := "ERRO"	
			EndIf				
				
		Case Upper(cComando) == Upper("ConsultarSAT")
			
			If Len(aParam) > 1
				Do Case
						
					Case aParam[2] == "08000"
								
						cRet := "OK"
				
					Case aParam[2] == "08098"			
						
						cRet := "EM_PROCESSAMENTO"
						
					OtherWise
						
						cRet := "ERRO"
						
				EndCase
			Else
				cRet := "ERRO"	
			EndIf				
				
		Case Upper(cComando) == Upper("TesteFimAFim")

			If Len(aParam) > 1
				Do Case
						
					Case aParam[2] == "09000"
								
						cRet := "OK"
				
					Case aParam[2] == "09098"			
						
						cRet := "EM_PROCESSAMENTO"
						
					OtherWise
						
						cRet := "ERRO"
						
				EndCase
			Else
				cRet := "ERRO"	
			EndIf				
				
		Case Upper(cComando) == Upper("ConsultarStatusOperacional")
			
			If Len(aParam) > 1			
				Do Case
				
					Case aParam[2] == "10000"
								
						cRet := "OK"
				
					Case aParam[2] == "10098"			
						
						cRet := "EM_PROCESSAMENTO"
						
					OtherWise
						
						cRet := "ERRO"
						
				EndCase
			Else
				cRet := "ERRO"	
			EndIf				
								
		Case Upper(cComando) == Upper("ConsultarNumeroSessao")

			If Len(aParam) > 1
				Do Case
						
					Case aParam[2] == "11000"
								
						cRet := "OK"
				
					Case aParam[2] == "11098"			
						
						cRet := "EM_PROCESSAMENTO"
						
					OtherWise
						
						cRet := "ERRO"
						
				EndCase
			Else
				cRet := "ERRO"	
			EndIf				
				
		Case Upper(cComando) == Upper("ConfigurarInterfaceDeRede")

			If Len(aParam) > 1		
				Do Case
				
					Case aParam[2] == "12000"
								
						cRet := "OK"
				
					Case aParam[2] == "12098"			
						
						cRet := "EM_PROCESSAMENTO"
						
					OtherWise
						
						cRet := "ERRO"
						
				EndCase
			Else
				cRet := "ERRO"	
			EndIf				
				
		Case Upper(cComando) == Upper("AssociarAssinatura")

			If Len(aParam) > 1	
				Do Case
				
					Case aParam[2] == "13000"
								
						cRet := "OK"
				
					Case aParam[2] == "13098"			
						
						cRet := "EM_PROCESSAMENTO"
						
					OtherWise
						
						cRet := "ERRO"
						
				EndCase
			Else
				cRet := "ERRO"	
			EndIf				
				
		Case Upper(cComando) == Upper("AtualizarSoftwareSAT")

			If Len(aParam) > 1	
				Do Case
				
					Case aParam[2] == "14000"
								
						cRet := "OK"
				
					Case aParam[2] == "14098"			
						
						cRet := "EM_PROCESSAMENTO"
						
					OtherWise
						
						cRet := "ERRO"
						
				EndCase
			Else
				cRet := "ERRO"	
			EndIf				
				
		Case Upper(cComando) == Upper("ExtrairLogs")

			If Len(aParam) > 1		
				Do Case
				
					Case aParam[2] == "15000"
								
						cRet := "OK"
				
					Case aParam[2] == "15098"			
						
						cRet := "EM_PROCESSAMENTO"
						
					OtherWise
						
						cRet := "ERRO"
						
				EndCase
			Else
				cRet := "ERRO"	
			EndIf				
				
		Case Upper(cComando) == Upper("BloquearSAT")

			If Len(aParam) > 1		
				Do Case
				
					Case aParam[2] == "16000"
								
						cRet := "OK"
				
					Case aParam[2] == "16098"			
						
						cRet := "EM_PROCESSAMENTO"
						
					OtherWise
						
						cRet := "ERRO"
						
				EndCase
			Else
				cRet := "ERRO"	
			EndIf				
				
		Case Upper(cComando) == Upper("DesbloquearSAT")

			If Len(aParam) > 1		
				Do Case
				
					Case aParam[2] == "17000"
								
						cRet := "OK"
				
					Case aParam[2] == "17098"			
						
						cRet := "EM_PROCESSAMENTO"
						
					OtherWise
						
						cRet := "ERRO"
						
				EndCase
			Else
				cRet := "ERRO"	
			EndIf				
				
		Case Upper(cComando) == Upper("TrocarCodigoDeAtivacao")

			If Len(aParam) > 1	
				Do Case
				
					Case aParam[2] == "18000"
								
						cRet := "OK"
				
					Case aParam[2] == "18098"			
						
						cRet := "EM_PROCESSAMENTO"
						
					OtherWise
						
						cRet := "ERRO"
						
				EndCase
			Else
				cRet := "ERRO"	
			EndIf				
	
	EndCase
	
EndIf

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} LojSATMeioPag
Recebe o codigo e retorna a descrição do pagamento do XML SAT

@param   	
@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	cDescPag - Retorna a descrição do pagamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LojSATMeioPag( cCodPag )

Local cDescPag := ""			// Retorna a descrição do pagamento

Default cCodPag := ""

If !Empty(cCodPag)

	Do Case
		Case Val(cCodPag) == 01
			cDescPag := "Dinheiro"
		Case Val(cCodPag) == 02
			cDescPag := "Cheque"
		Case Val(cCodPag) == 03
			cDescPag := "Cartao de Credito"
		Case Val(cCodPag) == 04
			cDescPag := "Cartao de Debito"
		Case Val(cCodPag) == 05
			cDescPag := "Credito Loja"
		Case Val(cCodPag) == 10
			cDescPag := "Vale Alimentacao"
		Case Val(cCodPag) == 11
			cDescPag := "Vale Refeicao"
		Case Val(cCodPag) == 12
			cDescPag := "Vale Presente"
		Case Val(cCodPag) == 13
			cDescPag := "Vale Combustivel"
		Case Val(cCodPag) == 99
			cDescPag := "Outros"
		Otherwise
			cDescPag := "Nao Relacionado"
	EndCase

EndIf

Return cDescPag


//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATXml
Geração XML venda SAT

@param   	
@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	cXML              - String com parte do XML
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LjSATXml(lCompICMS, aItensSel)

Local cXML			:= ''								// Recebe a estrutura do XML
Local cVerCFe		:= SuperGetMv("MV_VERSAT",,'0.07')	// Versão do layout do arquivo de dados do AC(Aplicativo Comercial)
Local aItensSat		:= {}
Local nVlAcres		:= 0								// Somatória dos valores do campo L2_VALACRS

Default lCompICMS	:= .F.
Default aItensSel	:= {}

If ValType(cVerCFe) <> 'C'
	Help(" ", 1, "Help", "Houve um Problema", "Ajuste o tipo do parâmetro MV_VERSAT para o tipo 'caracter'.", 1, 0 )
	LjGrvLog( "SAT", "Tipo do Parametro MV_VERSAT diferente de Caracter." )
	Return .F.	
EndIf


//Inicia as variaveis nao fiscal
LjZeraNFisc()

LjGrvLog( "SAT", "Geracao do XML venda SAT - Inicio" )

If !lMFE
	cXML	+= "<?xml version='1.0' encoding='UTF-8'?>"
EndIf

cXML	+= "<CFe>" 
cXML	+= "<infCFe versaoDadosEnt=" + "'" + cVerCFe + "'" + ">"

LjGrvLog( "SAT", "Versao do XML configurado para venda - cVerCFe: ", cVerCFe )
cXML	+= LjSATxIde()  								//Grupo das informações de identificação do CF-e
cXML	+= LjSATxEmit() 								//Grupo de identificação do emitente do CF-e
cXML	+= LjSATxDest(lCompICMS) 						//Grupo de identificação do Destinatário do CF-e
//cXML	+= LjSATxEntr() 
cXML	+= LjSATxDet(@aItensSat, lCompICMS, aItensSel, @nVlAcres)	//Grupo do detalhamento de Produtos e Serviços do CF-e
cXML	+= LjSATxPag(@aItensSat, lCompICMS, nVlAcres)  			//Informações do pagamento
//cXML	+= LjSATxTot()

If lCompICMS
	cXML += LjSATxAdic()								//Grupo de Informações Adicionais - Chave de acesso do CF-e original que complementa (Complementar ICMS)
EndIf

cXML	+= "</infCFe>"
cXML	+= "</CFe>"

LjGrvLog( "SAT", "Geracao do XML venda SAT - Fim" )

//Limpa as variaveis nao fiscal
LjZeraNFisc()

Return cXML

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATxIde
Monta XML de Identificacao da SATCF-e

@param   	cChave				Chave
@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	cXML              - String com parte do XML
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function LjSATxIde()

Local cXML			:= ""		//XML Venda
Local nIndexSF4		:= 0	//Posicionamento SF4
Local nIndexSL4		:= 0	//Posicionamento SL4
Local nRecnoSF4		:= 0	//Posicionamento SF4
Local nRecnoSL4		:= 0	//Posicionamento SL4
Local cNumPDV		:= IIF(LJGetStation("PDV",.F.) == Nil,"",LJGetStation("PDV",.F.))				
Local cSatTest		:= SuperGetMV("MV_SATTEST",,"")			

LjGrvLog( "SAT", "Monta tag ide (identificacao) - Inicio" )
nIndexSF4	:= SF4->( indexOrd() )
nRecnoSF4	:= SF4->( recno() )
                                                                 
nIndexSL4	:= SL4->( indexOrd() )
nRecnoSL4	:= SL4->( recnO() )

cXML	+= "<ide>"

cXML	+= LjGetIdeSat(cSatTest)
cXML	+= "<numeroCaixa>" + AllTrim(cNumPDV) + "</numeroCaixa>"

LjGrvLog( "SAT", "Numero do Caixa ", AllTrim(cNumPDV) )
If Len(AllTrim(cNumPDV)) > 3
	LjGrvLog( "SAT", "Numero do Caixa invalido, deve conter apenas 3 caracters numericos", AllTrim(cNumPDV) )
EndIf

cXML	+= "</ide>"
LjGrvLog( "SAT", "Monta tag ide (identificacao) - Fim" )

Return cXML


//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATxEmit
Monta XML dados do Emitente

@param   	
@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	cXML              - String com parte do XML
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function LjSATxEmit()

Local cXML		:= ""
Local cSatTest	:= SuperGetMV("MV_SATTEST",,"")	
Local cIniFile	:= ""
Local lTstSAT	:= .F.
Local cCNPJ		:= ""	//CNPJ do Emitente
Local cIE		:= ""	//Inscrição Estadual do Emitente
Local cIM		:= ""	//Inscrição Municipal do Emitente
Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local cModelo	:= IIF(lIsPOS,STFGetStation("MODSAT"),LjGetStation("MODSAT"))
Local cMVVERSAT	:= SuperGetMv("MV_VERSAT",,'0.07')							//Versão do layout do arquivo de dados do AC(Aplicativo Comercial)

LjGrvLog( "SAT", "Monta tag <emit> (emitente) - Inicio" )
cXML	+= '<emit>'

//Se for de teste as informações fixas são da DIMEP
If !Empty(cSatTest)
	cCNPJ := AllTrim(cSatTest)
	
	If lMFE .And. Upper(AllTrim(cFabSat)) == "INTEGRADOR" .Or. cModelo == "TANCA"
		If !lAutomato	
			cIniFile := GetClientDir() + "sigaloja.ini"
		Else
			cIniFile := "\sigaloja.ini"
		Endif	
		lTstSAT := GetPvProfString("logdll", "SAT", "0" , cIniFile) == "1" 
		If lTstSAT
			cIE := AllTrim(GetPvProfString("SAT", "IE", "" , cIniFile))
			cIM := AllTrim(GetPvProfString("SAT", "IM", "" , cIniFile))
		EndIf
    EndIf
	
    If Empty(cIE) 
		If lMFE .AND. (Upper(AllTrim(cFabSat)) == "ELGIN" .Or. cModelo == "ELGIN")
			cIE	:= '001234567890'
		Else
			If Upper(AllTrim(cFabSat)) == "EPSON"
				cIE	:= '000052619494'
			Else	
				cIE	:= '111111111111'
			EndIf
			cIM	:= '123123' //Inscrição Municipal
		EndIf
	EndIf
Else	
	cCNPJ 	:= AllTrim( SM0->M0_CGC ) 	//CNPJ do Emitente
	cIE 	:= AllTrim( SM0->M0_INSC ) 	//Inscrição Estadual do Emitente
	cIM		:= AllTrim( SM0->M0_INSCM )	//Inscrição Municipal do Emitente
EndIf

LjGrvLog( "SAT", "CNPJ do Emitente: [" + cCNPJ + "]" )
LjGrvLog( "SAT", "Inscricao Estadual do Emitente: [" + cIE + "]" )
LjGrvLog( "SAT", "Inscricao Municipal do Emitente: [" + cIM + "]" )

If lMFE //.And. cMVVERSAT < "0.08"
	cIE := StrZero(Val( cIE ), 12)
Else
	cIE := AllTrim( cIE )
EndIf

cXML	+= '<CNPJ>' + cCNPJ + '</CNPJ>' // CNPJ Emitente
cXML	+= '<IE>' 	+ cIE 	+ '</IE>' 	// Inscrição Estadual
If !Empty(cIM)
	cIM	+= '<IM>'	+ cIM	+ '</IM>' 	// Inscrição Municipal
EndIf

//Regime Especial de Tributação do ISSQN 
//cXML	+= '<cRegTribISSQN>1</cRegTribISSQN>'       
//Indicador de rateio do Desconto sobre subtotal entre itens sujeitos à tributação pelo ISSQN 
cXML	+= '<indRatISSQN>N</indRatISSQN>'

cXML	+= '</emit>'
LjGrvLog( "SAT", "Monta tag <emit> (emitente) - Fim" )

Return cXML


//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATxDest
Monta XML dados do Destinatario

@type 		Static Function   	
@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	cXML , caracter ,String com parte do XML
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function LjSATxDest(lCompICMS)

Local cCliPad		:= SuperGetMv( "MV_CLIPAD",, "" ) 			// Cliente Padrão
Local cLojaPad		:= SuperGetMv( "MV_LOJAPAD",, "" ) 			// Loja Padrão
Local cXML			:= "" 										// Xml da venda
Local lPOS 			:= STFIsPOS() 								// Pos?
Local lFront		:= IIF(nModulo == 23 .AND. !lPOS,.T.,.F.)  	// Front?
Local cCGCCLI		:= ""										// CPF/CNPJ cliente
Local aAreaSL1		:= {}

Default lCompICMS	:= .F.

LjGrvLog( "SAT", "Monta tag dest (destinatario) - Inicio" )

If lPOS .OR. lFront .Or. lCompICMS
	cCGCCLI := AllTrim(SL1->L1_CGCCLI)
Else
	cCGCCLI := AllTrim(M->LQ_CGCCLI)
EndIf

LjGrvLog( "SAT", "CPF/CNPJ Venda - cCGCCLI: ", cCGCCLI )
	
If !Empty(cCGCCLI) .And. LjVldCGC(cCGCCLI)
	aAreaSL1 := SA1->(GetArea())
	SA1->( dbSetOrder( 1 ) )
	If	SA1->(DbSeek(xFilial("SA1") + SL1->L1_CLIENTE + SL1->L1_LOJA)) ;
		.AND. ((AllTrim(SL1->L1_CLIENTE) + AllTrim(SL1->L1_LOJA)) <> (AllTrim(cCliPad) + AllTrim(cLojaPad))) ;
		.AND. !Empty(SA1->A1_CGC) .And. (AllTrim(SA1->A1_CGC) == cCGCCli)
		
		cCGCCLI := AllTrim(SA1->A1_CGC)
		LjGrvLog( "SAT", "CPF/CNPJ Venda Encontrado na SA1 - cCGCCLI: ", cCGCCLI )
	Endif	
	RestArea(aAreaSL1)
	
	cXML	+= '<dest>'
	If LEN( cCGCCLI ) < 14
		cXML	+= '<CPF>' + StrZero(Val(cCGCCLI), 11) + '</CPF>'
	Else
		cXML	+= '<CNPJ>' + cCGCCLI  + '</CNPJ>'
	EndIf
	cXML	+= '</dest>'
Else
	cXML	+= '<dest/>'			
EndIf

LjGrvLog( "SAT", "Monta tag dest (destinatario) - Fim" ) 
Return cXML


//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATxEntr
Monta XML dados do Destinatario	

@param   	
@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	cXML              - String com parte do XML
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function LjSATxEntr()

Local cXml := ""

cXML	+= '<entrega>'
cXML	+= '<xLgr>'  + allTrim( SM0->M0_CGC )    + '</xLgr>'
cXML	+= '<nro>'   + allTrim( SM0->M0_INSC )   + '</nro>'
cXML	+= '<xCpl>'  + allTrim( SM0->M0_CODMUN ) + '</xCpl>'
cXML	+= '<xBairro></xBairro>'
cXML	+= '<xMun></xMun>'
cXML	+= '<UF></UF>'
cXML	+= '</entrega>'

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATxDet
Monta XML dados do detalhe da Venda(Itens)	

@type   	Function
@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	cXML , caracter , String com parte do XML
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function LjSATxDet(aItensSat, lCompICMS, aItensSel, nVlAcres) 

Local cXML			:= ""														//Xml da venda
Local nIndexSF4		:= 0														//Posicionamento SF4
Local nIndexSL2		:= 0														//Posicionamento SL2
Local nRecnoSF4		:= 0														//Posicionamento SF4
Local nRecnoSL2		:= 0														//Posicionamento SL2
Local nX			:= 0														//Contador
Local lPOS 			:= STFIsPOS() 												//Pos?
Local lFront		:= IIF( nModulo == 23 .AND. !lPOS,.T.,.F.) 					//Front?
Local nTotImpNCM 	:= 0														//Total Imposto
Local nTotVLRNCM 	:= 0														//Total do produto
Local nTotFed 		:= 0														//Total Federal
Local nTotEst 		:= 0														//Total Estadual
Local nTotMun 		:= 0														//Total Municipal
Local lImpEntTrb 	:= SuperGetMv("MV_ENTETRB",.F.,.F.) 						//Verifica se esta apto a utilizar a Nova Lei da Transparencia 
Local cCRT 			:= AllTrim( SuperGetMV("MV_CODREG",,"1") )					//Codigo do Regime Tributario			
Local lLj7013		:= ExistBlock("LJ7013")		    							//Indica se existe o ponto de entrada	
Local cCodProd 		:= "" 														//Codigo do produto
Local cDescriProd	:= "" 														//Descrição do produto
Local nQuant 		:= 0  														//Quantidade do produto
Local nVrUnit		:= 0  														//Valor unitario do produto
Local nDesconto		:= 0  														//Valor desconto do produto
Local cSitTrib		:= "" 														//Codigo situação tributaria
Local nVlrItem		:= 0  														//Valor final do item
Local aRetLj7013	:= {} 														//Retorno do ponto de entrada
Local lMvLjCEST		:= SuperGetMv("MV_LJCEST",,0) == 1							//Indica que o CEST sera enviado independente da Situacao Tributaria
Local lItemGE		:= .F.														//Item de garantia estendida
Local cTipoGE		:= PadR(SuperGetMV("MV_LJTPGAR",,"GE"), GetSx3Cache("B1_TIPO","X3_TAMANHO"))	//Tipo do produto Garantia Estendida
Local lContinua		:= .T. 														//Se o item é fiscal ou não
Local cAlias		:= ""														//Alias da tabela de produto (SB1 ou SBI)
Local lItemServ		:= .F.														//Item do tipo serviço
Local nAliqICMS		:= 0														//Valor da aliquota
Local nItem			:= 0														//Posição do item na cesta
Local nPos			:= 0		
Local nValIcms		:= 0														//Informa o valor antes da nova aliquota de ICMS
Local nVOutro		:= 0														//Informa o valor de diferença para a nova aliquota
Local nNewValICM	:= 0														//Valor do ICMS ajustado com a nova alíquota informada
Local nItComp		:= 0
Local lL2CEST 		:= SL2->(ColumnPos("L2_CEST")) > 0							//Campo L2_CEST Existe?
Local cCEST			:= ""														//Valor do CEST
Local cCpoCest		:= ""														//Campo CEST
Local lItCest		:= .F.														//Item tem CEST?
Local cPosIpi		:= ""														//NCM
Local nValIPI		:= 0														//Valor do IPI
Local cMVVERSAT		:= SuperGetMv("MV_VERSAT",,'0.07')							//Versão do layout do arquivo de dados do AC(Aplicativo Comercial)
Local lLJ7099		:= ExistBlock("LJ7099")										// Ponto de entrada para retorno de produto especifico (ANP)
Local cXMLPE		:= ""

Default aItensSat 	:= {}
Default lCompICMS	:= .F.
Default aItensSel	:= {}														//Array contendo os produtos selecionados para emitir o CF-e SAT Complementar
Default nVlAcres 	:= 0 														// Somatória dos valores do campo L2_VALACRS

LjGrvLog( "SAT", "Monta tag det (detalhes da venda - produtos) - Inicio" )
LjGrvLog( "SAT", "Lei da transparencia - lImpEntTrb: ",lImpEntTrb )
LjGrvLog( "SAT", "Ponto de entrada para efetuar alteracao nos produtos enviados ao SAT - lLj7013: ",lLj7013 )
LjGrvLog( "SAT", "Parametro para utilizacao do CEST para produtos sendo ou nao ST (substituicao tributaria)- MV_LJCEST: ",lMvLjCEST)

nIndexSL2	:= SL2->( indexOrd() )
nRecnoSL2	:= SL2->( recno() )

nIndexSF4	:= SF4->( indexOrd() )
nRecnoSF4	:= SF4->( recno() )

If lFront
	aAreaSBx := SBI->( GetArea() )
	cAlias := "SBI"
	SBI->( DbSetOrder(2) ) //BI_FILIAL + BI_TIPO + BI_COD
Else
	aAreaSBx := SB1->( GetArea() )
	cAlias := "SB1"
	SB1->( DbSetOrder(2) ) //B1_FILIAL + B1_TIPO + B1_COD
EndIf

SL2->( dbSetOrder( 1 ) )
SF4->( dbSetOrder( 1 ) )
IF SL2->( DBSEEK( xFilial( "SL2" ) + SL1->L1_NUM ) )
	
	If lCompICMS

		If MaFisFound()
			MaFisEnd()
		EndIf 
		
		MaFisIni(	SL1->L1_CLIENTE	,;	//01 Codigo do cliente
					SL1->L1_LOJA	,;	//02 Loja
					"C"				,;	//03 Cliente ou Fornecedor
					"S"				,;	//04 Tipo da Nota Fiscal
					SL1->L1_TIPOCLI	,;	//05 Tipo de Cliente/Fornecedor
					Nil				,;	//06 Relacao de Impostos que suportados no arquivo
					Nil				,;	//07 Tipo de complemento
					.F.				,;	//08 Permite Incluir Impostos no Rodape .T./.F.
					"SB1"			,;	//09 Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
					"LOJSAT"     	,;	//10 Nome da rotina que esta utilizando a funcao
					Nil				,;	//11
					Nil				,;	//12
					Nil				,;	//13
					Nil				,;	//14
					Nil				,;	//15
					Nil				,;	//16
					Nil				,;	//17
					Nil				,;	//18
					Nil				,;	//19
					Nil				,;	//20
					Nil				,;	//21
					Nil				,;	//22
					Nil				,;	//23
					Nil				,;	//24
					Nil				,;	//25
					SL1->L1_TPFRET	)	//26
		
	EndIf

	LjGrvLog( "SAT", "Efetua varredura nos produtos da SL2 adicionados na venda" )

	DO WHILE !SL2->( EOF() ) .And. SL2->L2_FILIAL == xFilial("SL1") .And. SL2->L2_NUM == SL1->L1_NUM

		nItem++ //Atualiza a posição do item

		LjGrvLog( "SAT", "Processando item: " + SL2->L2_ITEM + " - Contador do item: " + AllTrim(Str(nItem)) )

		lItemGE		:= &(cAlias)->( MsSeek(xFilial(cAlias) + cTipoGE + SL2->L2_PRODUTO) )
		lItemServ	:= IIf(ExistFunc("LjIsTesISS"), LjIsTesISS(SL1->L1_NUM,SL2->L2_TES), SL2->L2_VALISS > 0) .And. SUBSTR( SL2->L2_SITTRIB, 1, 1 ) == "S"
		
		lContinua 	:=	!lItemServ	.And.;											//item do tipo serviço
						!lItemGE	.And. ;		 									//item que não é Garantia Estendida
						((SL2->L2_ENTREGA == '1' .AND. !Empty(SL1->L1_ORCRES) ) ;	//item de orçamento filho de Retira Posterior
						.OR. SL2->L2_ENTREGA == '2' .OR. Empty(SL2->L2_ENTREGA) )	//item de orçamento Retira

		//Soma tota da venda por tipo de item (fiscal e nao fiscal)
		LjSetTotVenda(SL2->L2_VLRITEM + SL2->L2_DESCPRO, lContinua,lItemGE)
		
		//Caso este item não seja fiscal
		If !lContinua
			SL2->(DbSkip())
			loop
		EndIf

		//Lei da Transparencia 
		If lImpEntTrb
			nTotImpNCM 	+= SL2->L2_TOTIMP		
			nTotVLRNCM 	+= SL2->L2_VLRITEM		
			nTotFed 	+= SL2->L2_TOTFED		
			nTotEst 	+= SL2->L2_TOTEST		
			nTotMun 	+= SL2->L2_TOTMUN					
		EndIf
	
		cCodProd	:= SL2->L2_PRODUTO 
		cDescriProd	:= SL2->L2_DESCRI
		
		If lCompICMS
			MaFisAdd( 	SL2->L2_PRODUTO					,;	// Produto
						SL2->L2_TES   					,;	// TES
						SL2->L2_QUANT   				,;	// Quantidade
						SL2->L2_PRCTAB					,;	// Preco unitario
						SL2->L2_VALDESC					,;	// Valor do desconto
						""                     			,;	// Numero da NF original
						""                     			,;	// Serie da NF original
						0                      			,;	// Recno da NF original
						0                      			,;	// Valor do frete do item
						0                      			,;	// Valor da despesa do item
						0                      			,;	// Valor do seguro do item
						0                      			,;	// Valor do frete autonomo
						(SL2->L2_PRCTAB * SL2->L2_QUANT),;	// Valor da mercadoria
						0								)	// Valor da embalagem
			
			nItComp ++

			nPos := aScan(aItensSel, {|x| AllTrim(x[1]) == AllTrim(SL2->L2_ITEM) } )
			If nPos == 0
				SL2->(DbSkip())
				Loop
			EndIf

			// Caso for Complementar de ICMS a quantidade deve ser enviada zerada 
			nQuant	:= 0
			nItem 	:= nItComp

			/*====================================================================================== 
				Compara o valor de ICMS antigo com o Novo para obter o valor da diferença de ICMS
				que será enviado para o Complementar de ICMS SAT 
			======================================================================================*/
			nValIcms 	:= MaFisRet(nItem,'IT_VALICM')
			aAdd(aValItCP, { aItensSel[nPos][1], aItensSel[nPos][5] - MaFisRet(nItem,'IT_ALIQICM')})
			MaFisAlt('IT_ALIQICM',aItensSel[nPos][5],nItem)
			nVOutro 	:= MaFisRet(nItem,'IT_VALICM') - nValIcms
			nNewValICM	:= nValIcms + nVOutro
			nValTotCP 	+= nVOutro
		Else
			nQuant	:= SL2->L2_QUANT
		EndIf
		
		nVrUnit		:= SL2->L2_VLRITEM
		nDesconto	:= SL2->L2_VALDESC
		cSitTrib	:= SL2->L2_SITTRIB	
		nVlAcres 	+= SL2->L2_VALACRS
		nVlrItem	:= SL2->L2_VLRITEM
		nValIPI		:= SL2->L2_VALIPI

		LjGrvLog( "SAT", "Informacoes do produto ", {cCodProd, cDescriProd, AllTrim(Str(nQuant)), AllTrim(Str(nVrUnit)), AllTrim(Str(nDesconto)), cSitTrib, AllTrim(Str(nVlrItem))} )			

		If lLj7013
			
			LjGrvLog("SAT","Antes da Chamada do Ponto de Entrada:LJ7013",{cCodProd, cDescriProd, AllTrim(Str(nQuant)), AllTrim(Str(nVrUnit)), AllTrim(Str(nDesconto)), cSitTrib, AllTrim(Str(nVlrItem))})
			aRetLj7013 := ExecBlock("LJ7013",.F.,.F.,{cCodProd, cDescriProd, AllTrim(Str(nQuant)), AllTrim(Str(nVrUnit)), AllTrim(Str(nDesconto)), cSitTrib, AllTrim(Str(nVlrItem)), nItem})
			LjGrvLog("SAT","Apos a Chamada do Ponto de Entrada:LJ7083 - aRetLj7013", aRetLj7013)
			
			If ValType( aRetLj7013 ) == "A" .AND. Len( aRetLj7013 ) >= 7
				cCodProd	:= aRetLj7013[1] 
				cDescriProd	:= aRetLj7013[2]
				nQuant		:= Val(aRetLj7013[3])
				nDesconto	:= Val(aRetLj7013[5])
				nVlrItem	:= Val(aRetLj7013[7]) 
			EndIf			
		EndIf
		
		nVlrItem := nVlrItem + nDesconto + SL2->L2_DESCPRO - SL2->L2_VALACRS
	
		LjGrvLog( "SAT", "Valor do produto com desconto - nVlrItem", nVlrItem )
		nX++
		
		SF4->( DBSEEK( xFilial( "SF4" ) + SL2->L2_TES ) )
		
		cXML	+= "<det nItem='" + ALLTRIM( STR( nX ) ) + "'>" //Numeração do Item
		
		cXML	+= '<prod>'
		cXML	+= '<cProd>' + ALLTRIM( cCodProd ) + '</cProd>' //Código do Produto

		If ExistFunc("LjRmvChEs")
			cXML	+= '<xProd>' + ALLTRIM( EnCodeUTF8( LjRmvChEs(cDescriProd) ) ) + '</xProd>' //Descrição do Produto
			LjGrvLog( "SAT", "Descricao do produto - cDescriProd: ", ALLTRIM( EnCodeUTF8( LjRmvChEs(cDescriProd) ) ) )
		Else
			cXML	+= '<xProd>' + ALLTRIM( EnCodeUTF8( RmvChrEsp(cDescriProd) ) ) + '</xProd>' //Descrição do Produto
			LjGrvLog( "SAT", "Descricao do produto - cDescriProd: ", ALLTRIM( EnCodeUTF8( RmvChrEsp(cDescriProd) ) ) )
		EndIf

		cPosIpi := AllTrim( SL2->L2_POSIPI )
		If Empty(cPosIpi)
			SB1->( DbSetOrder(1) ) //B1_FILIAL+B1_COD
			SB1->( MsSeek(xFilial("SB1") + SL2->L2_PRODUTO) )
			cPosIpi := AllTrim( SB1->B1_POSIPI )
		EndIf

		cXML += '<NCM>' + cPosIpi + '</NCM>'
		
		cCEST := ""
		lItCest := .F.
		/*================================== FISCO =========================================*/
		If lMvLjCEST .OR. SUBSTR( SL2->L2_SITTRIB, 1, 1 ) == "F"
			cCpoCest := Substr(cAlias,2)+"_CEST"
			If lL2CEST .AND. !Empty(SL2->L2_CEST)
				cCEST := SL2->L2_CEST
				lItCest := .T.				
			ElseIf &(cAlias)->(ColumnPos(cCpoCest)) > 0 
				&(cAlias)->( DbSetOrder(1) ) //B1_FILIAL + B1_COD
				&(cAlias)->( MsSeek(xFilial(cAlias) + SL2->L2_PRODUTO) )	
				If &(cAlias)->(Found()) .AND. !Empty(&(cAlias)->(FieldGet(FieldPos(cCpoCest))))
				//Grupo do campo de uso livre do Fisco
					If (nModulo == 23)
						cCEST := LjFindTriSat(nItem,"IT_CEST")
						If ValType(cCEST) <> "C"
							cCEST := cValToChar(cCEST)
						EndIf
					Else	
						cCEST := MaFisRet(nItem,'IT_CEST')
					EndIf	
					lItCest := .T.	
				Else
					LjGrvLog( "SAT", cCpoCest + "não está preenchido ")	
				EndIf	
				//Volta para a ordem anterior
				&(cAlias)->( DbSetOrder(2) ) //B1_FILIAL + B1_TIPO + B1_COD	
			Else
				LjGrvLog( "SAT", cCpoCest + " não existe " )	
			EndIf
		EndIf
		/*===================================================================================*/
		
		If cMVVERSAT >= "0.08" .And. lItCest
			cXML += '<CEST>' + LjconvType(cCEST, 7, 0) + '</CEST>'
		EndIf
		
		cXML	+= '<CFOP>' + ALLTRIM( SL2->L2_CF ) + '</CFOP>' //Código fiscal
		If Len(ALLTRIM( SL2->L2_CF )) < 4
			LjGrvLog( "SAT", "CFOP Inválido - SL2->L2_CF: ", ALLTRIM( SL2->L2_CF ) )
		EndIf	
		
		cXML	+= '<uCom>' + ALLTRIM( SL2->L2_UM ) + '</uCom>' //Unidade de medida
		cXML	+= '<qCom>' + LjconvType( nQuant, 15, 4 ) + '</qCom>' //Quantidade do produto
		cXML	+= '<vUnCom>' + LjconvType( nVlrItem / nQuant, 21, 2 ) + '</vUnCom>' //Valor da Unidade do produto
		LjGrvLog( "SAT", "Valor unitario produto LjconvType( nVlrItem / nQuant, 21, 2 ) ", LjconvType( nVlrItem / nQuant, 21, 2 ) )
		AADD(aItensSat,{ nVlrItem-nDesconto, nQuant } )
		
		If HasTemplate("PCL")
			cXML	+= '<indRegra>T</indRegra>'
		Else
			cXML	+= '<indRegra>A</indRegra>'
		EndIf
		
		If lCompICMS
			cXML	+= '<vOutro>' + LjconvType( nVOutro, 15, 2 ) + '</vOutro>' //Valor faltante de ICMS para envio do Complementar de ICMS
		EndIf

		If nDesconto > 0
			cXML	+= '<vDesc>'+ LjconvType(nDesconto,8,2) +'</vDesc>'
			LjGrvLog( "SAT", "SAT - Desconto produto ", LjconvType(nDesconto,7,2) )
		EndIf	

		/*-------------------------------------------------------------------------------
			Trecho necessário para resolver o problema de vendas SAT com IPI, onde 
			o arredondamento resultava na diferença de centavos.
		-------------------------------------------------------------------------------*/
		If !Empty(nValIPI)
			cXML	+= '<vOutro>' + LjconvType(nValIPI, 15, 2) + '</vOutro>' 			//Envia o valor do IPI na TAG vOutros
		EndIf
		
		If lItCest
			If cMVVERSAT <= "0.07"
				cXML	+= "<obsFiscoDet xCampoDet='" + "Cod. CEST" + "' >" //Identificação do campo
				cXML	+= "<xTextoDet>" + cCEST + "</xTextoDet>" //Conteúdo do campo
				cXML	+= "</obsFiscoDet>"
			ElseIf lLJ7099
				LjGrvLog("SAT", "Antes da execução do P.E. LJ7099")
				cXMLPE := ExecBlock("LJ7099",.F.,.F.)
				LjGrvLog("SAT", "Depois da execução do P.E. LJ7099", cXMLPE)
				If ValType(cXMLPE) == "C"
					cXML += AllTrim(cXMLPE)
				EndIf
			EndIf
		EndIf
		
		cXML	+= '</prod>'
		
		cXML	+= '<imposto>'
		
		cXML	+= '<vItem12741>' + LjconvType( SL2->L2_TOTIMP, 15, 2) + '</vItem12741>' 
		LjGrvLog( "SAT", "Tributacao produto vItem12741 = LjconvType( SL2->L2_TOTIMP, 15, 2)", LjconvType( SL2->L2_TOTIMP, 15, 2) )
		
		// Em caso de produto, será gerado o imposto de ICMS
		/*====================================================================================*/
		/*================================== I C M S =========================================*/
		/*====================================================================================*/
		
		LjGrvLog( "SAT", "Codigo do Regime Tributario - cCRT: " + cCRT )
		LjGrvLog( "SAT", "CST ICMS - SF4->F4_SITTRIB: " + SF4->F4_SITTRIB )
		LjGrvLog( "SAT", "Orig - SL2->L2_ORIGEM: " + IIF(!Empty(SL2->L2_ORIGEM),SL2->L2_ORIGEM,"0") )
		LjGrvLog( "SAT", "CSOSN - SF4->F4_CSOSN: " + SF4->F4_CSOSN )
		LjGrvLog( "SAT", "SL2 SITTRIB: " + SL2->L2_SITTRIB )

		/*Alíquota de ICMS:
		Aproveitamos o campo L2_SITTRIB que armazenava a legenda do ECF, porém esse campo é do tipo Caracter,
		por isso realizamos a conversão para numérico, assim mantendo o padrão de conversão no momento da montagem do XML */
		
		If AllTrim(cSitTrib) $ "F1|I1|N1"   /* F1-Com ICMS Recolhido anteriormente / I1-Isento do ICMS / N1-Não Tributado */
			nAliqICMS	:= 0
		ElseIf IsDigit( SubStr(cSitTrib, 1,1) )
			nAliqICMS	:= Val( cSitTrib )
		Else
			nAliqICMS	:= Val( SubStr(cSitTrib, 2, 2) + iIf(At(".",cSitTrib)>0,"",".") + SubStr(cSitTrib, 4, 2) )
		EndIf

		If lCompICMS
			//Se for SAT Complementar, então considera na tag pICMS o que foi digitado na interface pelo usuario
			nPos := aScan(aItensSel, {|x| AllTrim(x[1]) == AllTrim(SL2->L2_ITEM) } )
			
			If nPos > 0
				nAliqICMS := aItensSel[nPos][5]
				LjGrvLog( "SAT", "Esta emitindo um SAT Complentar, sera considerado na TAG pICMS o valor " + cValToChar(nAliqICMS) + ". Esse valor foi informado pelo usuario na tela do SAT Complementar.")
			Else
				LjGrvLog( "SAT", "Não foi encontrado o item (L2_ITEM) " + AllTrim(SL2->L2_ITEM) + " no array aItensSel do SAT complementar." )
				SL2->(DbSkip())
				Loop
			EndIf
		EndIf

		If cCRT <> "1"	//1 - Simples Nacional 
		
			DO CASE
				CASE SUBSTR( SL2->L2_SITTRIB, 1, 1 ) $ "TIN"
					cXML		+= '<ICMS>'
					IF ALLTRIM( SF4->F4_SITTRIB ) $ "00|20|90"	
						cXML		+= '<ICMS00>'	
						cXML		+= '<Orig>'  + IIF(!Empty(SL2->L2_ORIGEM),SL2->L2_ORIGEM,"0")  + '</Orig>' // Origem da mercadoria						
						cXML		+= '<CST>'   + SF4->F4_SITTRIB + '</CST>' //Tributação do ICMS
						cXML		+= '<pICMS>' + LjconvType( nAliqICMS, 5, 2 ) + '</pICMS>' //Alíquota efetiva do imposto
						cXML		+= '</ICMS00>'
					ELSEIF ALLTRIM( SF4->F4_SITTRIB ) $ "40|41|50|60"
						cXML		+= '<ICMS40>'			
						cXML		+= '<Orig>' + IIF(!Empty(SL2->L2_ORIGEM),SL2->L2_ORIGEM,"0")  + '</Orig>'	// Origem da mercadoria							
						cXML		+= '<CST>'  + SF4->F4_SITTRIB + '</CST>'//Tributação do ICMS
						cXML		+= '</ICMS40>'
					ENDIF
					
					cXML		+= '</ICMS>'

				// Substituição tributária
				CASE SUBSTR( SL2->L2_SITTRIB, 1, 1 ) == "F"
					cXML		+= '<ICMS>'
					IF ALLTRIM( SF4->F4_SITTRIB ) $ "00|20|90"	
						cXML		+= '<ICMS00>'	
						cXML		+= '<Orig>'  + IIF(!Empty(SL2->L2_ORIGEM),SL2->L2_ORIGEM,"0") + '</Orig>'		// Origem da mercadoria						
						cXML		+= '<CST>'   + SF4->F4_SITTRIB + '</CST>'		//Tributação do ICMS
						cXML		+= '<pICMS>' + LjconvType( nAliqICMS, 5, 2 ) + '</pICMS>' //Alíquota efetiva do imposto
						cXML		+= '</ICMS00>'
					ELSEIF ALLTRIM( SF4->F4_SITTRIB ) $ "40|41|50|60"
						cXML		+= '<ICMS40>'			
						cXML		+= '<Orig>' + IIF(!Empty(SL2->L2_ORIGEM),SL2->L2_ORIGEM,"0")  + '</Orig>'	// Origem da mercadoria								
						cXML		+= '<CST>'  + SF4->F4_SITTRIB + '</CST>'	//Tributação do ICMS
						cXML		+= '</ICMS40>'
					ENDIF
					
					cXML		+= '</ICMS>'
				
			ENDCASE
		
		Else
			
			Do Case
				
				Case AllTrim(SF4->F4_CSOSN) $ "102|300|400|500"
					cXML		+= '<ICMS>'
					cXML		+= "<ICMSSN102>"
					cXML		+= "<Orig>" + IIF(!Empty(SL2->L2_ORIGEM),SL2->L2_ORIGEM,"0") + "</Orig>"		// Origem da mercadoria
					cXML 		+= 	"<CSOSN>" + SF4->F4_CSOSN + "</CSOSN>" 	//Código de Situação da Operação – Simples Nacional
					cXML		+= "</ICMSSN102>" 
					cXML		+= '</ICMS>'
				 
				Case AllTrim(SF4->F4_CSOSN) $ "900"
					cXML		+= '<ICMS>'
					cXML		+= "<ICMSSN900>"
					cXML		+= "<Orig>" + IIF(!Empty(SL2->L2_ORIGEM),SL2->L2_ORIGEM,"0") + "</Orig>"		// Origem da mercadoria
					cXML 		+= 	"<CSOSN>" + SF4->F4_CSOSN + "</CSOSN>" 	//Código de Situação da Operação – Simples Nacional
					cXML		+= '<pICMS>' + LjconvType( nAliqICMS, 5, 2 ) + '</pICMS>' //Alíquota efetiva do imposto
					cXML		+= "</ICMSSN900>"
					cXML		+= '</ICMS>'
				
			EndCase
			
		EndIf
			
		/*====================================================================================*/
		/*================================== P I S ===========================================*/
		/*====================================================================================*/
		
		LjGrvLog( "SAT", "CST PIS - SF4->F4_CSTPIS: ", SF4->F4_CSTPIS )

		DO CASE
			CASE SF4->F4_CSTPIS $ "01|02|05"
				cXML		+= "<PIS>"
				cXML		+= "<PISAliq>"
				cXML		+= "<CST>" 	+ SF4->F4_CSTPIS 	+	"</CST>" //Código de Situação Tributária do PIS
				IF (nModulo == 23)
					cXML		+= "<vBC>" 	+ LjconvType( LjFindTriSat(nItem,"IT_BASEPS2"),15,2 )	+	"</vBC>" //Valor da Base de Cálculo do PIS
					cXML		+= "<pPIS>" 	+ LjconvType( LjFindTriSat(nItem,"IT_ALIQPS2") / 100 ,10,4 )	+	"</pPIS>" //Alíquota do PIS (em percentual)
				Else
					cXML		+= "<vBC>" 	+ LjconvType( MaFisRet(nItem,'IT_BASEPS2'),15,2 )	+	"</vBC>" //Valor da Base de Cálculo do PIS
					cXML		+= "<pPIS>" 	+ LjconvType( MaFisRet(nItem,'IT_ALIQPS2') / 100 ,10,4 )	+	"</pPIS>" //Alíquota do PIS (em percentual)
				EndIf	
				cXML		+= "</PISAliq>"								
				cXML		+= "</PIS>"
								
			CASE SF4->F4_CSTPIS $ "03"
				cXML		+= "<PIS>"
				cXML		+= "<PISQtde>"
				cXML		+= "<CST>" 	+ SF4->F4_CSTPIS 	+	"</CST>" //Código de Situação Tributária do PIS
				cXML		+= "<qBCProd>" 	+ LjconvType( SL2->L2_QUANT, 15, 4 ) 	+	"</qBCProd>" //Quantidade Vendida
				If (nModulo == 23)
					cXML		+= "<vAliqProd>" 	+ LjconvType( LjFindTriSat(nItem,"IT_PAUTPIS"),10,4 )	+	"</vAliqProd>" //Alíquota do PIS (em reais)
				Else	
					cXML		+= "<vAliqProd>" 	+ LjconvType( MaFisRet(nItem,'IT_PAUTPIS'),10,4 )	+	"</vAliqProd>" //Alíquota do PIS (em reais)
				EndIf	
				cXML		+= "</PISQtde>"								
				cXML		+= "</PIS>"					
												
			CASE SF4->F4_CSTPIS $ "04|06|07|08|09"
				cXML		+= "<PIS>"
				cXML		+= "<PISNT>"
				cXML		+= "<CST>" 	+ SF4->F4_CSTPIS 	+	"</CST>" //Código de Situação Tributária do PIS
				cXML		+= "</PISNT>"								
				cXML		+= "</PIS>"			

			CASE SF4->F4_CSTPIS $ "49"
				cXML		+= "<PIS>"
				cXML		+= "<PISSN>"
				cXML		+= "<CST>" 	+ SF4->F4_CSTPIS 	+	"</CST>" //Código de Situação Tributária do PIS
				cXML		+= "</PISSN>"								
				cXML		+= "</PIS>"					

			CASE SF4->F4_CSTPIS $ "99"
				cXML		+= "<PIS>"
				cXML		+= "<PISOutr>"
				cXML		+= "<CST>" 	+ SF4->F4_CSTPIS 	+	"</CST>" //Código de Situação Tributária do PIS
				IF (nModulo == 23)
					cXML		+= "<vBC>" 	+ LjconvType( LjFindTriSat(nItem,"IT_BASEPS2"),15,2 ) 	+	"</vBC>" //Valor da Base de Cálculo do PIS
					cXML		+= "<pPIS>" 	+ LjconvType( LjFindTriSat(nItem,"IT_ALIQPS2") / 100 ,10,4 )	+	"</pPIS>" //Alíquota do PIS (em percentual)
				Else
					cXML		+= "<vBC>" 	+ LjconvType( MaFisRet(nItem,'IT_BASEPS2'),15,2 ) 	+	"</vBC>" //Valor da Base de Cálculo do PIS
					cXML		+= "<pPIS>" 	+ LjconvType( MaFisRet(nItem,'IT_ALIQPS2') / 100 ,10,4 ) 	+	"</pPIS>" //Alíquota do PIS (em percentual)
				EndIf						
				cXML		+= "</PISOutr>"								
				cXML		+= "</PIS>"	
								
		ENDCASE
		
		LjGrvLog( "SAT", "PIS Substituicao Tributaria - SF4->F4_PSCFST:  ", SF4->F4_PSCFST )			
		
		If SF4->F4_PSCFST == "1"
			cXML		+= "<PISST>"
			If (nModulo == 23)
				cXML		+= "<vBC>"+ LjconvType( LjFindTriSat(nItem,"IT_BASEPS2"),15,2 ) 	+	"</vBC>" //Valor da Base de Cálculo do PIS
				cXML		+= "<pPIS>" 	+ LjconvType( LjFindTriSat(nItem,"IT_ALIQPS2") / 100 ,10,4 )	+	"</pPIS>" //Alíquota do PIS (em percentual)
			Else
				cXML		+= "<vBC>"+ LjconvType( MaFisRet(nItem,'IT_BASEPS2'),15,2 )	+	"</vBC>" //Valor da Base de Cálculo do PIS
				cXML		+= "<pPIS>" 	+ LjconvType( MaFisRet(nItem,'IT_ALIQPS2') / 100 ,10,4 )	+	"</pPIS>" //Alíquota do PIS (em percentual)
			EndIf
			cXML		+= "</PISST>"
		EndIf			
		
		/*====================================================================================*/
		/*============================ C O F I N S ===========================================*/
		/*====================================================================================*/
		
		LjGrvLog( "SAT", "COFINS CST - SF4->F4_CSTCOF: ", SF4->F4_CSTCOF )
			
		DO CASE
			CASE SF4->F4_CSTCOF $ "01|02|05"
				cXML		+= "<COFINS>"
				cXML		+= "<COFINSAliq>"
				cXML		+= "<CST>" 		+ SF4->F4_CSTCOF +	"</CST>" //Código de Situação Tributária do COFINS
				If (nModulo == 23)
					cXML		+= "<vBC>" 		+ LjconvType( LjFindTriSat(nItem,"IT_BASECF2"),15,2 )  +	"</vBC>" //Valor da Base de Cálculo do COFINS
					cXML		+= "<pCOFINS>" 	+ LjconvType( LjFindTriSat(nItem,"IT_ALIQCF2") / 100 ,10,4 ) +	"</pCOFINS>" //Alíquota do COFINS (em percentual)
				Else
					cXML		+= "<vBC>" 		+ LjconvType( MaFisRet(nItem,'IT_BASECF2'),15,2 )  +	"</vBC>" //Valor da Base de Cálculo do COFINS
					cXML		+= "<pCOFINS>" 	+ LjconvType( MaFisRet(nItem,'IT_ALIQCF2') / 100 ,10,4 ) +	"</pCOFINS>" //Alíquota do COFINS (em percentual)
				EndIf
				cXML		+= "</COFINSAliq>"
				cXML		+= "</COFINS>"			
					
			CASE SF4->F4_CSTCOF $ "03"
				cXML		+= "<COFINS>"
				cXML		+= "<COFINSQtde>"
				cXML		+= "<CST>" 	+ SF4->F4_CSTCOF 	+	"</CST>" //Código de Situação Tributária do COFINS
				cXML		+= "<qBCProd>" 	+ LjconvType( SL2->L2_QUANT, 15, 4 ) 	+	"</qBCProd>" //Quantidade Vendida
				If (nModulo == 23)
					cXML		+= "<vAliqProd>" 	+ LjconvType( LjFindTriSat(nItem,"IT_PAUTCOF"),10,4 )	+	"</vAliqProd>" //Alíquota do COFINS (em reais)
				Else
					cXML		+= "<vAliqProd>" 	+ LjconvType( MaFisRet(nItem,'IT_PAUTCOF'),10,4 ) 	+	"</vAliqProd>" //Alíquota do COFINS (em reais)
				EndIf	
				cXML		+= "</COFINSQtde>"								
				cXML		+= "</COFINS>"					
					
			CASE SF4->F4_CSTCOF $ "04|06|07|08|09"
				cXML		+= "<COFINS>"
				cXML		+= "<COFINSNT>"
				cXML		+= "<CST>" 		+ SF4->F4_CSTCOF +	"</CST>" //Código de Situação Tributária do COFINS
				cXML		+= "</COFINSNT>"
				cXML		+= "</COFINS>"			

			CASE SF4->F4_CSTCOF $ "49"
				cXML		+= "<COFINS>"
				cXML		+= "<COFINSSN>"
				cXML		+= "<CST>" 	+ SF4->F4_CSTCOF 	+	"</CST>" //Código de Situação Tributária do COFINS
				cXML		+= "</COFINSSN>"								
				cXML		+= "</COFINS>"		
				
			CASE SF4->F4_CSTCOF $ "99"		
				cXML		+= "<COFINS>"
				cXML		+= "<COFINSOutr>"
				cXML		+= "<CST>" 	+ SF4->F4_CSTCOF 	+	"</CST>" //Código de Situação Tributária do COFINS
				If (nModulo == 23)
					cXML		+= "<vBC>" 		+ LjconvType( LjFindTriSat(nItem,"IT_BASECF2"),15,2 )  +	"</vBC>" //Valor da Base de Cálculo do COFINS
					cXML		+= "<pCOFINS>" 	+ LjconvType( LjFindTriSat(nItem,"IT_ALIQCF2") / 100 ,10,4 ) +	"</pCOFINS>" //Alíquota do COFINS (em percentual)
				Else
					cXML		+= "<vBC>" 		+ LjconvType( MaFisRet(nItem,'IT_BASECF2'),15,2 )  +	"</vBC>" //Valor da Base de Cálculo do COFINS
					cXML		+= "<pCOFINS>" 	+ LjconvType( MaFisRet(nItem,'IT_ALIQCF2') / 100 ,10,4 ) +	"</pCOFINS>" //Alíquota do COFINS (em percentual)
				EndIf						
				cXML		+= "</COFINSOutr>"								
				cXML		+= "</COFINS>"							
							
		ENDCASE
		
		LjGrvLog( "SAT", "COFINS Substituicao Tributaria - SF4->F4_PSCFST: ", SF4->F4_PSCFST )

		If SF4->F4_PSCFST == "1"
			cXML		+= "<COFINSST>"
			If (nModulo == 23)
				cXML		+= "<vBC>" 		+ LjconvType( LjFindTriSat(nItem,"IT_BASECF2"),15,2 )  +	"</vBC>" //Valor da Base de Cálculo do COFINS
				cXML		+= "<pCOFINS>" 	+ LjconvType( LjFindTriSat(nItem,"IT_ALIQCF2") / 100 ,10,4 ) +	"</pCOFINS>" //Alíquota do COFINS (em percentual)
			Else
				cXML		+= "<vBC>" 		+ LjconvType( MaFisRet(nItem,'IT_BASECF2'),15,2 )  +	"</vBC>" //Valor da Base de Cálculo do COFINS
				cXML		+= "<pCOFINS>" 	+ LjconvType( MaFisRet(nItem,'IT_ALIQCF2') / 100 ,10,4 ) +	"</pCOFINS>" //Alíquota do COFINS (em percentual)
			EndIf
			cXML		+= "</COFINSST>"
		EndIf
					
		cXML	+= '</imposto>'
		
		cXML	+= '</det>'
		
		SL2->( dbSkip() )
		
	ENDDO
Else
	LjGrvLog( "SAT", "Nao entrou no dbSeek do produto " )
	
ENDIF

If lImpEntTrb
	
	LjGrvLog( SL1->L1_NUM, "SAT - Lei da transparencia por ente tributario - lImpEntTrb = .T." )
	
	aAdd(aSATImp, {"TOTIMPNCM"	, nTotImpNCM} )
	LjGrvLog( "SAT", "TOTIMPNCM - nTotImpNCM: ", nTotImpNCM )
	aAdd(aSATImp, {"TOTVLRNCM"	, nTotVLRNCM} )
	LjGrvLog( "SAT", "TOTVLRNCM - nTotVLRNCM: ", nTotVLRNCM )
	aAdd(aSATImp, {"TOTFED"	, nTotFed} )
	LjGrvLog( "SAT", "TOTFED - nTotFed: ", nTotFed )
	aAdd(aSATImp, {"TOTEST"	, nTotEst} )
	LjGrvLog( "SAT", "TOTEST - nTotEst: ", nTotEst )
	aAdd(aSATImp, {"TOTMUN"	, nTotMun} )
	LjGrvLog( "SAT", "TOTMUN - nTotMun: ", nTotMun )
EndIf

RestArea(aAreaSBx)

SF4->( dbSetOrder( nIndexSF4 ) )
SF4->( dbGoTo( nRecnoSF4 ) )

SL2->( dbSetOrder( nIndexSL2 ) )
SL2->( dbGoTo( nRecnoSL2 ) )

If lCompICMS .And. MaFisFound()
	MaFisEnd()
EndIf

LjGrvLog( "SAT", "Monta tag det (detalhes da venda - produtos) - Fim" )

Return cXML


//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATxTot
Monta XML dados de Totalizacao	

@param   	
@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	cXML              - String com parte do XML
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function LjSATxTot()

Local cXML := "" //XML da venda

    cXML += "<total>"
   // cXML +=     "<ICMSTot>"
    cXML +=         "<BC>" + SL2->L2_BASEICM+ "</BC>"
    cXML +=         "<ICMS>" + LjConvType( aNFCeW02[02], 15, 2) + "</ICMS>"
    //cXML +=         "<ICMSDeson>" + LjConvType( aNFCeW02[03], 15, 2) + "</vICMSDeson>"
    cXML +=         "<BCST>" + LjConvType( aNFCeW02[04], 15, 2) + "</BCST>"
    //cXML +=         "<ST>" + LjConvType( aNFCeW02[05], 15, 2) + "</vST>" não necessário SAT
    cXML +=         "<vProd>" + LjConvType( aNFCeW02[06], 15, 2) + "</vProd>"
    //cXML +=         "<vFrete>0</vFrete>" não necessário SAT
    //cXML +=         "<vSeg>0</vSeg>" não necessário SAT
    //cXML +=         "<vDesc>" + LjConvType( (aNFCeW02[09][1] + aNFCeW02[09][2]), 15, 2) + "</vDesc>"
    //cXML +=         "<vII>0</vII>" não necessário SAT
    cXML +=         "<vIPI>0</vIPI>"
    cXML +=         "<vPIS>" + LjConvType( aNFCeW02[12], 15, 2) + "</vPIS>"
    cXML +=         "<vCOFINS>" + LjConvType( aNFCeW02[13], 15, 2) + "</vCOFINS>"
    //cXML +=         "<vOutro>" + LjConvType( aNFCeW02[14], 15, 2) + "</vOutro>"
    //cXML +=         "<vNF>" + LjConvType( aNFCeW02[15], 15, 2) + "</vNF>"
   // If aNFCeW02[16] > 0
     //   cXML +=     "<vTotTrib>" + LjConvType( aNFCeW02[16], 15, 2) + "</vTotTrib>"
   // EndIf
    cXML +=     "</ICMSTot>"
    cXML += "</total>"

return cXML

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATxPag
Monta XML dados de Pagto	

@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	cXML              - String com parte do XML
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function LjSATxPag(aItensSat, lCompICMS, nVlAcres)                                                                               
	
Local cXML				:= "" 										//Xml da venda
Local nIndexSL4			:= 0  										//Posicionamento SL4
Local nRecnoSL4			:= 0  										//Posicionamento SL4
Local aFormas			:= {{"R$","01"},{"CH","02"},{"CC","03"},{"CD","04"},{"CR","05"},{"VA","10"},{"VR","11"},{"VP","12"},{"VC","13"}} //Formas de pagamento
Local aFormasPag		:= {} 										//Info formas de pagamento
Local nX				:= 0  										//Contador        
Local cFormaCod			:= "" 										//Código da forma de pagamento
Local cSatAdmin			:= "" 										//administradora cartão SAT
Local nDescAcre			:= 0  										// Desconto / Acrescimo 
Local nTotDesc			:= 0 										//total de desconto
Local nNotFiscalFactor	:= 0 										//porcentagem da venda nao fiscal                  
Local nFiscalFactor 	:= 0 										//porcentagem da venda fiscal
Local nTotAcres			:= 0 										//valor total de acressimo
Local lPOS 				:= STFIsPOS() //Pos?
Local lFront			:= IIF( nModulo == 23 .AND. !lPOS,.T.,.F.)  // Front?
Local nVlrForma			:= 0 										// Valor da forma de pagamento
Local lMvLjTroco		:= SuperGetMV("MV_LJTROCO", ,.F.) 			// Verifica se utiliza troco nas diferentes formas de pagamento
Local nMvLjTrDin		:= SuperGetMV("MV_LJTRDIN", , 0 ) 			// Determina se utiliza troco para diferentes formas de pagamento
Local nPayFactor		:= 0										//Fator para pagamento
Local nTotNaoFiscal		:= 0										//Valor total nao fiscal
Local nPropFormas		:= 0										//Valor proporcional (fiscal) das formas 
Local nPropRFormas		:= 0										//Valor proporcional (fiscal) das formas arredondadas
Local nArredCentavo		:= 0										//Valor de centavos a arredondar
Local cVlrForma			:= ""										//Valor da forma de pgto
Local nValIPI			:= 0										//Valor do IPI
Local nPosDin			:= 0  										//Guarda a posição da forma de pagamento em dinheiro
local nFatorNaoFiscal	:= 0										//Fator não fiscal para ajuste de pagamento em dinheiro
Local nFatorFiscal		:= 1 										//Fator fiscal para ajuste de pagamento em dinheiro
Local oTotal			:= Iif(lPOS,STFGetTot(),Nil)				//Objeto com os totais para o TOTVS PDV
Local lFrtDspSeg 		:= .F.										//Existe Frete ou Despesa ou Seguro na Venda 
Local nVlFtSgDes		:= 0										// Valor de Frete + Seguro + Despesa
Local nVlrAcrFin		:= 0										// Valor do Acréscimo Financeiro (Juros)

Default aItensSat		:= {}   									// Variavel para o acumulo de valores dos itens para verificar com o total da SL4
Default	lCompICMS		:= .F.
Default nVlAcres		:= 0										// Somatória dos valores do campo SL2->L2_VALACRS quando MV_LJJURCC = .T. e Totvs PDV

LjGrvLog( "SAT", "Monta total/pgto (dados do pagamento) **INICIO**" )
LjGrvLog( "SAT", "Valor parametro - MV_LJTROCO: ", lMvLjTroco)
LjGrvLog( "SAT", "Valor parametro - MV_LJTRDIN: ", nMvLjTrDin )

//Desconto no Total da venda
If SL1->L1_DESCONT > 0
	nTotDesc := SL1->L1_DESCONT
EndIf	 		 

//Desconto financeiro
If lFront
	If SL1->L1_DESCFIN > 0 
		nTotDesc += SL1->L1_DESCFIN
	EndIf
EndIf

If lPOS
	//Valor do IPI
	nValIPI := oTotal:GetValue("L1_VALIPI")
Else
	//Valor do IPI
	nValIPI := SL1->L1_VALIPI
EndIf

LjGrvLog("SAT", "Valor de IPI embutido:", nValIPI)

//Valor total dos itens da venda fiscal
LjGrvLog( "SAT", "Total Total dos itens da venda fiscal: ", aTotVenda[1]  )

//Valor total dos itens da venda nao fiscal
LjGrvLog( "SAT", "Total Total dos itens da venda nao fiscal: ", aTotVenda[2]  )
//Fator nao fiscal da venda
/*
Obs.: O fato de venda para descobrir a proporção do desconto é:
O valor do (desconto) deve ser multiplciado (*) pelo (valor bruto da venda fiscal) / (valor bruto das soma das vendas mistas).
*/
nTotNaoFiscal		:= aTotVenda[2]
nNotFiscalFactor	:= nTotNaoFiscal / (aTotVenda[1]+aTotVenda[2])
LjGrvLog( "SAT", "Fator nao fiscal da venda - nNotFiscalFactor: ", nNotFiscalFactor )

//Fator fiscal da venda                       
nFiscalFactor := ( 1 - nNotFiscalFactor )
LjGrvLog( "SAT", "Fator fiscal da venda - nFiscalFactor: ", nFiscalFactor )

//Total desconto fiscal
nTotDesc := nTotDesc * nFiscalFactor
LjGrvLog( "SAT", "Total desconto fiscal - nTotDesc : ", nTotDesc  )

//Fator para as formas de pagamento
/*Obs.: O fato de venda para as formas de pagamento é diferente do fator do desconto, ou seja, para este valor de fator de venda o calculo é:
nFatorPgto = (valor liquido da venda fiscal com desconto e sem frete) / (valor liquido da soma das vendas mistas com frete e desconto).
Obs.: So adiciona frete caso nao tenha nenhum item nao fiscal */
If nTotNaoFiscal == 0 
	nVlFtSgDes := SL1->L1_FRETE + SL1->L1_DESPESA + SL1->L1_SEGURO

	LjGrvLog( "SAT", "Total acrescimo - nVlFtSgDes: ", nVlFtSgDes )

	lFrtDspSeg := ( !Empty(SL1->L1_TPFRET) .AND. SL1->L1_TPFRET <> "0" .AND. SL1->L1_TPFRET <> "S");
					.OR. (SL1->L1_DESPESA > 0 ).OR. (SL1->L1_SEGURO > 0 )
	
	If lFrtDspSeg
		nTotAcres += nVlFtSgDes
	EndIf

EndIf

// Acréscimo financeiro em variavel separada pois na mesma venda pode ter acrescimo Financeiro e acrescimo oriundo de Frete + Seguro + Despesa
If nVlAcres > 0
	nVlrAcrFin := nVlAcres
ElseIf SL1->L1_VLRJUR > 0
	nVlrAcrFin := SL1->L1_VLRJUR
EndIf
LjGrvLog( "SAT", "Total de Juros [nVlrAcrFin]", nVlrAcrFin )

//Cálculo do nPayFactor
nPayFactor := (aTotVenda[1] - nTotDesc + nValIPI + nTotAcres) / SL1->L1_VLRLIQ

//Acrescimo financeiro
If nVlrAcrFin > 0
	nTotAcres += nVlrAcrFin
EndIf

//Fator nao pode ser maior que 1
If nPayFactor > 1
	nPayFactor := 1
EndIf

LjGrvLog( "SAT", "Total de Acréscimos: ", nTotAcres )
LjGrvLog( "SAT", "Fator da venda fiscal para formas de pagamento - nPayFactor: ", nPayFactor )

//Se tiver desconto ou frete/seguro/despesas
If nTotDesc > 0 .OR. nTotAcres > 0
	
	cXML	+= '<total>' //Grupo de Valores Totais do CF-e
	cXML	+= '<DescAcrEntr>' //Grupo de valores de entrada de Desconto/Acréscimo sobre Subtotal
	
	//Se existir desconto e acressimo junto
	If nTotDesc > 0 .AND. nTotAcres > 0
		nDescAcre := nTotDesc - nTotAcres
		//Se o desconto for maior que o acressimo entra como desconto
		If nDescAcre > 0
			cXML	+= '<vDescSubtot>' + LjconvType(nDescAcre,15,2) + '</vDescSubtot>' //Valor de Entrada de Desconto sobre Subtotal			  
		Else
			cXML	+= '<vAcresSubtot>' + LjconvType(nDescAcre*-1,15,2) +'</vAcresSubtot>' //Valor de Entrada de Acréscimo sobre Subtotal
		EndIf
		
	ElseIf nTotDesc > 0 //se existir apenas desconto
		cXML	+= '<vDescSubtot>' + LjconvType(nTotDesc,15,2) + '</vDescSubtot>' //Valor de Entrada de Desconto sobre Subtotal
	ElseIf nTotAcres > 0
		// Acrescimo Financeiro não entra na TAG vAcresSubtot pois eh integrado ao valor do item
		cXML	+= '<vAcresSubtot>' + LjconvType(nTotAcres,15,2) +'</vAcresSubtot>' //Valor de Entrada de Acréscimo sobre Subtotal
	EndIf	
	
	cXML	+= '</DescAcrEntr>'
	
	If Len(aSATImp) > 0
		cXML	+= '<vCFeLei12741>' + LjconvType( aSATImp[1][2], 15, 2) + '</vCFeLei12741>'
		LjGrvLog( "SAT", "Total de Impostos - LjconvType( aSATImp[1][2], 15, 2): ", LjconvType( aSATImp[1][2], 15, 2) )
	EndIf
	
	cXML	+= '</total>'
ElseIf Len(aSATImp) > 0
	cXML	+= '<total>' //Grupo de Valores Totais do CF-e (declarações em valor)
	cXML	+= '<vCFeLei12741>' + LjconvType( aSATImp[1][2], 15, 2) + '</vCFeLei12741>'	
	LjGrvLog( "SAT", "Total de Impostos - LjconvType( aSATImp[1][2], 15, 2): ", LjconvType( aSATImp[1][2], 15, 2) )
	cXML	+= '</total>' 
Else
	LjGrvLog( "SAT", "Nao possui valores a serem preenchidos na tag total" )
	cXML	+= '<total/>' //Grupo de Valores Totais do CF-e (declarações em valor)
EndIf

nIndexSL4	:= SL4->( indexOrd() )
nRecnoSL4	:= SL4->( recno() )

//Verifica se houve utilização de NCC (05-Crédito Loja)
If SL1->L1_CREDITO > 0
	LjGrvLog( "SAT", "Utiliza NCC - SL1->L1_CREDITO: ", SL1->L1_CREDITO )
	aAdd( aFormasPag, {"05",SL1->L1_CREDITO, Nil} )
EndIf

//Se houve Retencao de PCC, o valor da venda sera maior que os pagamentos, pois o abatimento somente é feito financeiramente,
// por esse motivo é necessário incluir o valor abatido, pois senao os pagamentos nao baterao com o valor da venda.
If SL1->L1_ABTOPCC > 0
	aAdd( aFormasPag, {"99", SL1->L1_ABTOPCC, Nil} )
EndIf

SL4->( dbSetOrder( 1 ) )
If SL4->( dbSeek( xFilial( "SL4" ) + SL1->L1_NUM ) )
	     
	DO WHILE !SL4->( EOF() ) .and. SL4->L4_NUM == SL1->L1_NUM
		                                                   
		If SL4->L4_VALOR > 0 .AND. Empty( SL4->L4_ORIGEM )
			//Pesquisa codigo da forma de pagto, quando não encontra envia como Outros - 99
			If (nX := aScan(aFormas,{|x| Alltrim(x[1]) == Alltrim(SL4->L4_FORMA) })) > 0 
				cFormaCod := aFormas[nX][2]
			Else             
				cFormaCod := "99"
			EndIf
			
			LjGrvLog( "SAT", "Forma de pagamento - cFormaCod: ", cFormaCod )
			LjGrvLog( "SAT", "Valor da forma de pagamento - SL4->L4_VALOR: ", SL4->L4_VALOR )
			nVlrForma := SL4->L4_VALOR

			If lMvLjTroco .And. (lPOS .Or. lFront) // Tratamento para o troco para TotvsPdv
				nVlrForma := nVlrForma + IIf(nMvLjTrDin == 0,0,SL4->L4_TROCO)
			EndIf

			//Verifica se Forma de Pagto ja foi adicionada no Array e soma
			If (nX := aScan(aFormasPag,{|x| Alltrim(x[1]) == Alltrim(cFormaCod) })) > 0		
				aFormasPag[nX][2] += nVlrForma
			Else
				aAdd( aFormasPag, {cFormaCod, nVlrForma, SL4->L4_ADMINIS} )	
			EndIf
			
			//Tratamento para diferença de centavos
			nPropFormas += nVlrForma * nPayFactor
			nPropRFormas += Round(nVlrForma * nPayFactor,2)
			If Alltrim(SL4->L4_FORMA) == "R$"
				If nX > 0
					nPosDin := nX
				Else
					nPosDin := Len(aFormasPag)
				EndIf
			EndIf
		EndIf
			
		SL4->( dbSkip() )
		
	ENDDO

	// Função para verificar se o total dos itens calculados no SAT eh divergente do valor do Total.	
	LJSATDirv(aItensSat,aFormasPag,nTotDesc,@nPayFactor)	
	
ENDIF

SL4->( dbSetOrder( nIndexSL4 ) )
SL4->( dbGoTo( nRecnoSL4 ) )

cXML	+= '<pgto>' 
LjGrvLog( "SAT", "Quantidade de formas de pagamento - Len(aFormasPag): ", Len(aFormasPag) )

//Se TotvsPDV e Outros, eu desconto o valor do não-fiscal. Exemplo: Multinegociação com Garantia Estendida ou Serviços Financeiros
If lIsPos .AND. (nTotNaoFiscal > 0) .AND. (nX := aScan(aFormasPag,{|x| Alltrim(x[1]) == "99" })) > 0 .AND. nPosDin > 0 //Somente PDV e não-fiscal satisfaz a condição.
	//Rateio para pagamento em dinheiro
	nFatorNaoFiscal 		:= nTotNaoFiscal / (SL1->L1_VLRLIQ + nVlrAcrFin)
	nFatorFiscal 			:= 1 - nFatorNaoFiscal
	aFormasPag[nX][2]		:= Round((aFormasPag[nX][2] + (aFormasPag[nPosDin][2] * nFatorNaoFiscal )) - nTotNaoFiscal,2)
	aFormasPag[nPosDin][2] 	:= Round(aFormasPag[nPosDin][2]  * nFatorFiscal,2)
EndIf

//tratamento para arredondamento da forma de pagamento dinheiro
If Round(nPropFormas,2) <> nPropRFormas	
	If nPosDin > 0
		nArredCentavo := Round(nPropFormas,2) - nPropRFormas 
	Endif
	LjGrvLog( "SAT", "Pagamento com valores diferentes", nArredCentavo )
EndIf

For nX	:= 1 To Len(aFormasPag)
	
	If lCompICMS
		cVlrForma := LjconvType( nValTotCP, 15, 2 )
	Else
		cVlrForma := LjconvType( aFormasPag[nX][2] * nPayFactor, 15, 2 )
	EndIf

	If nPosDin == nX .And. nArredCentavo > 0
		cVlrForma := LjconvType( (aFormasPag[nX][2] * nPayFactor ) + nArredCentavo , 15, 2 )	
	EndIf

	cXML	+= '<MP>'
	cXML	+= '<cMP>' + aFormasPag[nX][1] + '</cMP>' //Código do Meio de Pagamento 
	LjGrvLog( "SAT", "Meio de Pagamento - aFormasPag[nX][1]: ", aFormasPag[nX][1] )
	
	cXML	+= '<vMP>' + cVlrForma + '</vMP>' //Valor do Meio de Pagamento	
	LjGrvLog( "SAT", "Valor do Pagamento - cVlrForma: ", cVlrForma )
	
	If !Empty(aFormasPag[nX][3])
		cSatAdmin := LjGetAESAT(Left(aFormasPag[nX][3], TamSx3("AE_COD")[1]))
		LjGrvLog( "SAT", "Administradora cartao credito/debito - cSatAdmin: ", cSatAdmin )
		If !Empty(cSatAdmin)
			cXML	+= '<cAdmC>'+ cSatAdmin +'</cAdmC>' //aFormasPag[nX][3] //Credenciadora de cartão de débito ou crédito ( Exemplos: 001, 002, 003 )
		EndIf	
	EndIf
	cXML	+= '</MP>'
	
Next nX		

cXML	+= '</pgto>'
LjGrvLog( "SAT", "Monta total/pgto (dados do pagamento) **FIM**" )

Return cXML

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  LjconvType  ºAutor ³Vendas Cliente      º Data ³  16/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Converte Tipo Numerico/Data/String para padrao esperado no º±±
±±º            XML                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpC1 - String com parte do XML                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjconvType( xValor, nTam, nDec )

Local cNovo     := ""
Local lLojxFunB := ExistFunc("LjDataConv")

DEFAULT nDec    := 0

do case
    case valType( xValor ) == "N"
        cNovo   := allTrim( str( xValor, nTam, nDec ) )
    case valType( xValor ) == "D"
        If lLojxFunB
            cNovo := LjDataConv( xValor, "YYYYMMDD" )
        Else
            cNovo := FsDateConv( xValor, "YYYYMMDD" )
        EndIf
        cNovo   := subStr( cNovo, 1, 4 ) + "-" + subStr( cNovo, 5, 2 ) + "-" + subStr( cNovo, 7 )
    case valType( xValor ) == "C"
        if nTam == nil
            xValor  := allTrim( xValor )
        endif
        default nTam    := 60
        cNovo   := allTrim( enCodeUtf8( noAcento( subStr( xValor, 1, nTam ) ) ) )
endcase

Return cNovo

//-------------------------------------------------------------------
/*/{Protheus.doc} LojSATImprimir
Function para impressao Extrato SAT 

@param   	
@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LojSATImprimir( cXML		, cXMLEnv	, cSerie	, cDocSat	,;
						 cSerieSat	, lReimp	, aSATDoc 	) 

Local cTexto 		:= "" 								//Texto
Local oExtratoSAT   := Nil 								//Obj do xml de retorno do sat
Local oExtSATEnv   	:= Nil 								//Obj do xml de envio do sat
Local nTotalBruto 	:= 0								//Valor unitario total dos itens
Local nTotal 		:= 0								//Total geral
Local cCGC			:= ""								//CPF ou CNPJ para ser informado no QRCODE
Local lLj7085		:= ExistBlock("LJ7085")				//Indica se o ponto de entrada está compilado
Local lRet			:= .F.								//Retorno
Local lMVLJCOND		:= SuperGetMV("MV_LJCONDE",,.F.)	//Define se utilizar condensado ou não
Local lPOS			:= STFIsPOS() 						//Pos?
Local lParse		:= .F. 								//Se efetuou o parse do xml de retorno do equipamento SAT
Local nLJEMSAT		:= SuperGetMV("MV_LJEMSAT",,0)		//Parametro para perguntar se envia comprovante SAT por e-mail
Local cRemetente	:= ""								//Remetente do e-mail
Local cPath 		:= "\system\"						//Caminho para gravação do anexo do e-mail
Local cFile			:= "ComprovanteSat.html"			//Arquivo anexo para e-mail

Default cXML 		:= ""
Default cXMLEnv 	:= ""
Default cDocSat 	:= ""
Default cSerieSat	:= ""
Default cSerie		:= ""
Default lReimp		:= .F.
Default aSATDoc		:= {}

nLarCup := IIF(lPOS,STFGetStation("LARGCOL"),LJGetStation("LARGCOL"))	//largura do cupom

LjGrvLog( "SAT", "Rotina de impressao do comprovante SAT - ID_INICIO" )
LjGrvLog( "SAT", "Largura do cupom - nLarCup: ", nLarCup )
LjGrvLog( "SAT", "Parametro - MV_LJCONDE: ", lMVLJCOND )
LjGrvLog( "SAT", "Ponto de Entrada - LJ7085: ", lLj7085 )

//Caso o usuário não informe no cadastro de estação a largura do cupom ou edite pelo APSDU uma largura inválida
If nLarCup <= 0
	nLarCup := 47
EndIf

//tratamento para impressão na condensado
If lMVLJCOND
	cCondIni 	:= TAG_CONDEN_INI
	cCondFim 	:= TAG_CONDEN_FIM
EndIf

If !Empty(cXML)
	oExtratoSAT := TXMLManager():New()
	//executa o PARSE na string XML de retorno
	lRet := oExtratoSAT:Parse( cXML )
	LjGrvLog("SAT","Efetuou o Parse do XML retornado do equipamento - lRet", lRet)
	If !lRet
		LjGrvLog( "SAT", "Objeto oExtratoSAT não alimentado pelo Parse", oExtratoSAT )
		If !Empty( oExtratoSAT:Error() )
			LjGrvLog( "SAT", "ERRO AO EXECUTAR O METODO PARSE: ", oExtratoSAT:Error() )
		ElseIf !Empty( oExtratoSAT:Warning() )
			LjGrvLog( "SAT", "AVISO AO EXECUTAR O METODO PARSE: ", oExtratoSAT:Warning() )
		EndIf
		//executa o PARSE na string XML de envio
		oExtSATEnv := TXMLManager():New()
		lRet := oExtSATEnv:Parse( cXMLEnv )
	Else
		lParse := lRet	
	EndIf 	
EndIf
	
//Validacao se nao houver informacoes suficientes para imprimir mesmo com o xml de envio
If ( !lParse .And. Len(aSATDoc) == 0 ) .And. !lReimp
	LjGrvLog("SAT","Venda nao podera ser impressa pois nao possui todas informacoes necessarias")
	lRet := .F.
EndIf 

If lRet
	If nLJEMSAT == 1 .And. !lReimp
		If MsgYesNo("Deseja enviar o Comprovate SAT por e-mail?", "Atenção")
			cRemetente := LjAskEmail()
			nEnvEmail := 1
		EndIf	
	EndIf

	//Cabeçalho
	cTexto += LjSATHead(oExtratoSAT,oExtSATEnv,lParse,@cCGC,@cDocSat,lReimp)
	//Item
	cTexto += LjSATItem(oExtratoSAT,oExtSATEnv,lParse,@nTotalBruto,@nTotal)
	//Pagamento
	cTexto += LjSATPag(oExtratoSAT,oExtSATEnv,lParse,nTotal)
	//Observações do Contribuinte
	cTexto += LjSATObsCont()
	//Rodapé
	cTexto += LjSATFooter(oExtratoSAT,oExtSATEnv,lParse,cCGC,nTotal,aSATDoc,@cSerieSat, lReimp)
	//Impressão
	If nEnvEmail == 0
		LjSATEnvImp(cTexto,nTotalBruto,lReimp)
	ElseIf nEnvEmail == 1
		LjWriteHtm(cTexto, cPath+cFile)
		LjCpEmail(AllTrim(cRemetente))
		FErase(cPath+cFile)
	EndIf
EndIf	

LjGrvLog( "SAT", "Rotina de impressao do comprovante SAT - ID_FIM" )
Return        

//-------------------------------------------------------------------
/*/{Protheus.doc} LJCancelCupSat
Envia comando de Cancelamento da ultima venda SAT

@param      
@author     Varejo
@version    P11.8
@since      13/04/2015
@return     
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LJCancelCupSat(cChave, cXML, cSerie, lRollBack, cNFisCanc) 

Local cPass 		:= "" // código de ativação do SAT
Local cSitua		:= ""
Local lRet  		:= .F.
Local lPOS			:= STFIsPOS() //Pos? 
Local aRet			:= {} //Retorno Sat
Local lLjRmvChEs	:= ExistFunc("LjRmvChEs") //Retira os caracteres especiais pois a função DecodeUTF8 nao suporta e da erro.
Local lReimp		:= .F.
Local lShowMsg		:= .T.
Local aRetSitC		:= {}
Local lL1_DOCCCF	:= SL1->(ColumnPos("L1_DOCCCF")) > 0	//Contem o DOC de cancelamento

Default cXML 		:= "" // XML de cancelamento
Default cChave 		:= "" // Chave SAT
Default cSerie 		:= "" // Chave SAT
Default lRollBack 	:= .F. 
Default cNFisCanc 	:= "" 

aRetSitC:= LjSaTraCtr(LjSaCtrCnc(.F.,.F.,.T.,.F.,""))
cSitua := aRetSitC[1]
//Confere se é igual pra prosseguir com o cancelamento, caso nova venda e arquivo ainda exista
If cSitua $ "C2|C3|C4" .And. (aRetSitC[2]+aRetSitC[3]+aRetSitC[4] == SL1->(L1_FILIAL + L1_PDV + L1_DOC))
 	If cSitua $ "C4"
 		lReimp := .T.
 	EndIf
 	lShowMsg:= .F.
	aRet	:= GetConsNS()
	LjGrvLog("SAT" , "Restaura o cancelamento de venda", aRet)	
Else
	LjSaCtrCnc(.F.,.T.,.F.,.F.,"") //Apaga o arquivo de sinal de cancelamento caso exista
	LjSaCtrCnc(.T.,.T.,,.T.,"C1") //Inicio do processo de cancelamento do SAT

	If lPOS
		cPass	:= STFGetStation("CODSAT",,.F.) 
	Else
		cPass	:= IIF(LJGetStation("CODSAT",.F.) == Nil,"",LJGetStation("CODSAT",.F.))
	Endif
	
	LjGrvLog( "SAT", "Envia comando de cancelamento para o equipamento" )
	If lMFE .And. lIntegrador
		LjEnvCanc(cChave,cXML)
	EndIf	
	aRet := LJSATComando({"12","CancelarUltimaVenda",LJSATnSessao(),cPass, cChave, cXML})
EndIf

//Caso o retorno do SAT seja OK
If Len(aRet) > 2 .And. Val(aRet[2]) == 7000 .OR. Val(aRet[2]) == 7007 // 7000 - Doc cancelamdo | 7007 - Doc ja cancelado anteriormente no aparelho
	LjSaCtrCnc(.F.,.F.,,.T.,"C2") //SAT Cancelado no equipamento
	
	If lShowMsg
		If (Type("lExcAuto") <> "L" .OR. !lExcAuto) .And. !lRollBack 
			
			If lPOS
				STFMessage("SAT", "STOP", cSiglaSat + " - Cancelado com sucesso" )
	   			STFShowMessage( "SAT")			
			Else
				MsgAlert(cSiglaSat + " - Cancelado com sucesso" ) //"SAT - Cancelado com sucesso"
			EndIf	
			
		Else	
			Conout(cSiglaSat + " - Cancelado com sucesso" ) //"SAT - Cancelado com sucesso"
		EndIf
	EndIf
	
	LjGrvLog( "SAT", "SAT Cancelado com sucesso" )

	LjSaCtrCnc(.F.,.F.,,.T.,"C3") //Inicio impressão do comprovante de cancelamento
	
	// Se conseguiu cancelar o SAT efetua a impressão do comprovante
	If Len(aRet) > 4 .And. Len(aRet[5]) > 100 
		LJImpCanSat(Decode64(aRet[5]), cXML, cSerie, @cNFisCanc,lReimp) // Imprime extrato de cancelamento
	Else
		LJImpCanSat(Decode64(aRet[4]), cXML, cSerie, @cNFisCanc,lReimp) // Imprime extrato de cancelamento
	EndIf	
	lRet := .T.
	If lL1_DOCCCF .And. !Empty(cNFisCanc) .And. Empty(SL1->L1_DOCCCF)
		//Grava o numero do cupom de cancelamento SAT
		SL1->(RecLock("SL1", .F.))
		SL1->L1_DOCCCF := cNFisCanc
		SL1->(MsUnLock())
	EndIf
Else

	If Len(aRet) == 1
 
		If lLjRmvChEs
			aRet[1] := LjRmvChEs(aRet[1])
		EndIf

		LjGrvLogSAT(;
			cSerie,;
			/*numero da venda*/,;
			/*chave da venda*/,;
		 	cXML,;
		 	/*xml retorno*/,;
		 	"CANCEL",;
		 	"ERRO",;
		 	DecodeUTF8(aRet[1]);
		)
	ElseIf Len(aRet) > 3
		
		If lLjRmvChEs
			aRet[4] := LjRmvChEs(aRet[4])
		EndIf

		//Log SAT
		LjGrvLogSAT(;
			cSerie,;
			/*numero da venda*/,;
			/*chave da venda*/,;
		 	cXML,;
		 	/*xml retorno*/,;
		 	"CANCEL",;
		 	"ERRO",;
		 	aRet[2] + "-" + aRet[3] + "-"+ DecodeUTF8(aRet[4]);
		)
		
		LjGrvLog( "SAT", "Erro no cancelamento SAT" )
	    /*
	    	aRet[2] - Codigo do erro
	    	aRet[4] - Descrição
	    */
	   If lPOS
			STFMessage("SAT", "POPUP", "Erro no cancelamento "+cSiglaSat+": " + aRet[2] + "-" + aRet[3] + "-" + DecodeUTF8(aRet[4]) )
			STFShowMessage( "SAT")
	   Else
	   		If lRollBack
	    		Conout("Erro no cancelamento "+cSiglaSat+": " + aRet[2] + "-" + aRet[3] + "-" + DecodeUTF8(aRet[4]))
	    	Else	
	    		MsgAlert("Erro no cancelamento "+cSiglaSat+": " + aRet[2] + "-" + aRet[3] + "-" + DecodeUTF8(aRet[4]))
	    	EndIf	
		EndIf
	EndIf	
	     
	LjSaCtrCnc(.F.,.T.,.F.,.F.,"") //Apaga o arquivo de sinal de cancelamento caso exista	
	     
   lRet := .F.
   
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSatxCanc
Gera o XML de cancelamento da ultima venda

@param      
@author     Varejo
@version    P11.8
@since      13/04/2015
@return     
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LJSatxCanc(lRollBack,cNFisCanc,aInfo, lRecovery)

Local cChave	:= ""   // Chave 
Local cXML      := ""   // Xml
Local lRet      := .F. 	// retorno do cancelamento
Local cCGC		:= ""
Local cSerie  	:= ""
Local lPOS 		:= STFIsPOS() //Pos?
Local cCaixa	:= "" // numero do caixa
Local cMVVerSat	:= SuperGetMv("MV_VERSAT",,'0.07') //Versão do layout do arquivo de dados do AC(Aplicativo Comercial)
Local cSatTest	:= SuperGetMV("MV_SATTEST",,"")	

Default lRollBack	:= .F.
Default cNFisCanc	:= ""
Default aInfo		:= {}
Default lRecovery	:= .F. //Se for recuperação de venda

LjGrvLog( "SAT", "Rotina de Cancelamento do comprovante SAT **INICIO**" )

cChave  := "CFe" + SL1->L1_KEYNFCE
cCGC	:= SL1->L1_CGCCLI
cSerie	:= SL1->L1_SERIE

//recovery totvs pdv
If Len(aInfo) > 0
	cChave := "CFe" + aInfo[1]
	If Len(aInfo) > 2
		cCGC	:= aInfo[2]
		cCaixa	:= aInfo[3]
	Else	
		cCaixa	:= aInfo[2]
	EndIf
	If lPOS .And. !lRecovery
		cSerie	:= STDLastSat("L1_SERIE")
	EndIf
EndIf

If !lMFE
	cXML  += "<?xml version='1.0' encoding='UTF-8'?>"
EndIf

cXML  += '<CFeCanc>'
cXML  += "<infCFe chCanc='" + AllTrim(cChave) + "'>"
cXML  += '<ide>'

cXML += LjGetIdeSat(cSatTest)



If Empty(AllTrim(SL1->L1_PDV))
	cCaixa := AllTrim(LJGetStation("PDV"))
Else
	cCaixa := AllTrim(SL1->L1_PDV)
EndIf

cXML  += '<numeroCaixa>'+ cCaixa +'</numeroCaixa>'

cXML  += '</ide>'
cXML  += '<emit></emit>'

//----------------------------------------------------------------------------------
// Tratamento para não enviar o CPF no Cancelamento a partir da versão 0.07. Pois 
// a partir desta versão a responsabilidade do preencimento do CPF é do aparelho 
// SAT, caso for enviado o CPF no cancelamento ocorrerá Rejeição.
//----------------------------------------------------------------------------------
If cMVVerSat < '0.07' .And. !Empty(SL1->L1_CGCCLI) .And. LjVldCGC(AllTrim(SL1->L1_CGCCLI))
	If Len(AllTrim(SL1->L1_CGCCLI)) < 14
		cXML  += '<dest><CPF>'+ AllTrim(SL1->L1_CGCCLI) +'</CPF></dest>'
	Else	
		cXML  += '<dest><CNPJ>'+ AllTrim(SL1->L1_CGCCLI) +'</CNPJ></dest>'
	EndIf	
Else
	cXML  += '<dest></dest>'
EndIf	
cXML  += '<total />'
cXML  += '</infCFe>'
cXML  += '</CFeCanc>'

// Proteção efetuada para evitar problema com o objeto oSAT em cancelamentos
If oSAT == Nil 
	// Instancia objeto oSAT
	oSAT := LJCSAT():New()
EndIf	

lRet := LJCancelCupSat(cChave, cXML, cSerie, lRollBack, @cNFisCanc) // Envia comando de cancelamento para o equipamento SAT.

LjGrvLog( "SAT", "Rotina de Cancelamento do comprovante SAT **FIM**" )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LJImpCanSat
Imprime o Extrato de Cancelamento do SAT

@param      
@author     Varejo
@version    P11.8
@since      14/04/2015
@return     Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LJImpCanSat(cXML, cXMLEnv, cSerie, cNFisCanc, lReimp)

Local cHora 	:= ""
Local cData 	:= "" 															//data
Local oCanSAT 	:= Nil															//Objeto do cancelamento do SAT
Local cTexto  	:= "" 															// Aramzena o texto que será impresso
Local cLinha  	:= "" 															// Linha
Local lPOS 		:= STFIsPOS() 						//Pos?
Local cCGC		:= "" 															// CPF / CNPJ
Local nLarCup	:= IIF(lPOS,STFGetStation("LARGCOL"),LjGetStation("LARGCOL"))	//largura do cupom
Local cCondIni	:= ""															//tag abertura para texto condensado 
Local cCondFim	:= ""															//tag fechamento para texto condensado
Local cModelo	:= IIF(lPOS,STFGetStation("IMPFISC"),LjGetStation("IMPFISC"))
Local lMVLJCOND	:= SuperGetMV("MV_LJCONDE",,.F.)								//Define se utilizar condensado ou não
Local lRet		:= .F.
Local nRetImp	:= -1
Local cMsgApp	:= LjSatMgApp()													// Mensagem com o nome do aplicativo leitor do documento fiscal para SP
Local cQuebraLn	:= If("DARUMA" $ cModelo, CHR(10), "")

Default cXML 		:= "" // XML do cancelamento
Default cXMLEnv 	:= "" // XML enviado para o cancelamento
Default cSerie 		:= "" // Serie
Default cNFisCanc	:= "" // nota de cancelamento sat
Default lReimp		:= .F.// reimpressao

LjGrvLog( "SAT", "Rotina de impressao do cancelamento do SAT **INICIO**" )

//tratamento para impressão condensado
If lMVLJCOND
	cCondIni 	:= TAG_CONDEN_INI
	cCondFim 	:= TAG_CONDEN_FIM
EndIf

cLinha := Replicate("-",nLarCup) + Chr(10)

If !Empty(cXML)
	//instancia um objeto da classe TXML Manager
	oCanSAT := TXMLManager():New()
	
	//executa o PARSE na string XML
	lRet := oCanSAT:Parse( cXML )
	LjGrvLog( "SAT", "Efetua o Parse no XML retornado do equipamento - lRet: ", lRet )
	
	If !lRet
		If !Empty( oCanSAT:Error() )
			LjGrvLog( "SAT", "ERRO AO EXECUTAR O METODO PARSE: ", oCanSAT:Error() )
		ElseIf !Empty( oCanSAT:Warning() )
			LjGrvLog( "SAT", "AVISO AO EXECUTAR O METODO PARSE: ", oCanSAT:Warning() )
		EndIf
	EndIf 	
	
EndIf

If lRet .And. oCanSAT <> Nil

	LjGrvLog("SAT","Inicio da montagem de estrutura do comprovante para impressao")
	
	cHora := SUBSTR(OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/ide/hEmi" ),1,2) + ":" +  SUBSTR(OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/ide/hEmi" ), 3, 2)
	cData := SUBSTR(OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/ide/dEmi" ), 7, 8) +"/"+ SUBSTR(OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/ide/dEmi" ), 5,2) + "/" + SUBSTR(OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/ide/dEmi" ), 3,2)
	
	If !lReimp
		LjGrvLog("SAT","Grava na MH2")
		//Log SAT
		LjGrvLogSAT(;
						cSerie,;
						OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/ide/nCFe" ),;
						SUBSTR(OCANSAT:XPathGetAtt( "/CFeCanc/infCFe", "Id" ),4),;
					 	cXMLEnv,;
					 	cXML,;
					 	"CANCEL",;
					 	"SUCESSO";
					)
		LjSaCtrCnc(.F.,.F.,,.T.,"C4")
	EndIf
	
	//Cabeçalho
	cTexto += cCondIni + PADC(OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/emit/xNome" ), nLarCup) + cCondFim + Chr(10) //Nome do estabelecimento
	
	//Endereço
	cTexto += cCondIni + PADC(OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/emit/enderEmit/xLgr" ) + ", "; 			//Logradouro 
			+ OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/emit/enderEmit/nro" ) + " - "	;							//Número 
			+ OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/emit/enderEmit/xBairro" ), nLarCup) + cCondFim + Chr(10) 	//Municipio 	
			
	//Município,UF,CEP
	cTexto += cCondIni + PADC(OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/emit/enderEmit/xMun" ) + " - "	; //Municipio 
			+ SM0->M0_ESTCOB + " - "	;	//UF 
			+ "CEP:" + OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/emit/enderEmit/CEP" ), nLarCup) + cCondFim + Chr(10)	//CEP			

	//CNPJ, IE e IM do estabelecimento
	cTexto += cCondIni + PADC("CNPJ:" + OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/emit/CNPJ" ) + Space(1);
			+ "IE:" + OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/emit/IE" ) + Space(1);
			+ "IM:" + OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/emit/IM" ), nLarCup) + cCondFim + Chr(10)	
	
	cTexto += cCondIni + cLinha + cCondFim
	
	//Corpo
	cTexto += cCondIni + TAG_NEGRITO_INI + PADC("Extrato No." + OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/ide/nCFe" ), nLarCup) + TAG_NEGRITO_FIM + cCondFim + Chr(10) //Número da venda
	cNFisCanc := OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/ide/nCFe" )
	
	cTexto += cCondIni + TAG_NEGRITO_INI + PADC("CUPOM FISCAL ELETRONICO - SAT", nLarCup) + TAG_NEGRITO_FIM + cCondFim + Chr(10) //mensagem obrigatória
	cTexto += cCondIni + TAG_NEGRITO_INI + PADC("CANCELAMENTO", nLarCup) + TAG_NEGRITO_FIM + cCondFim + Chr(10) //mensagem obrigatória
	
	cTexto += cCondIni + cLinha + cCondFim
	 
	cTexto += cCondIni + TAG_NEGRITO_INI + PADR("DADOS DO CUPOM FISCAL ELETRONICO CANCELADO", nLarCup) + TAG_NEGRITO_FIM + cCondFim + Chr(10) //mensagem obrigatoria
	
	//Valida se foi informado o CPF ou CNPJ para venda
	If OCANSAT:XPathHasNode( "/CFeCanc/infCFe/dest" )
	 	//CPF
		If OCANSAT:XPathHasNode( "/CFeCanc/infCFe/dest/CPF" )
			cTexto += cCondIni + PADR("CPF/CNPJ do Consumidor: " + OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/dest/CPF" ), nLarCup) + cCondFim +  Chr(10) 
			cCGC := OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/dest/CPF" )
		//CNPJ	
		ElseIf OCANSAT:XPathHasNode( "/CFeCanc/infCFe/dest/CNPJ" )
			cTexto += cCondIni + PADR("CPF/CNPJ do Consumidor: " + OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/dest/CNPJ" ), nLarCup) + cCondFim +  Chr(10)
			cCGC := OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/dest/CNPJ" )
		Else
		//Default
			cTexto += cCondIni + PADR("CPF/CNPJ do Consumidor: Nao identificado", nLarCup) + cCondFim +  Chr(10)
		EndIf
	EndIf	
	
	cTexto += cCondIni + TAG_NEGRITO_INI + PADR("TOTAL:" + OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/total/vCFe" ), nLarCup) + TAG_NEGRITO_FIM + cCondFim + Chr(10) + Chr(10)  //total
	
	cTexto += cCondIni + PADC("SAT No. " + OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/ide/nserieSAT" ), nLarCup) + cCondFim + Chr(10) //numero de serie do SAT
	
	cTexto += cCondIni + PADC(cData + "  -  "  + cHora, nLarCup) + cCondFim + Chr(10) //Data venda 
	
	//Codigo de Barras
	cTexto += cCondIni + TAG_NEGRITO_INI + PADC(SUBSTR(OCANSAT:XPathGetAtt( "/CFeCanc/infCFe", "Id" ),4), nLarCup) + TAG_NEGRITO_FIM + cCondFim + CHR(10) //ID venda
	cTexto += TAG_CENTER_INI + TAG_COD128_INI + ALLTRIM(SUBSTR(OCANSAT:XPathGetAtt( "/CFeCanc/infCFe", "Id" ),4,22)) + TAG_COD128_FIM + TAG_CENTER_FIM + Chr(10) 
	cTexto += TAG_CENTER_INI + TAG_COD128_INI + ALLTRIM(SUBSTR(OCANSAT:XPathGetAtt( "/CFeCanc/infCFe", "Id" ),26,44)) + TAG_COD128_FIM + TAG_CENTER_FIM + Chr(10)	
	 
	//QrCode
	//chaveConsulta|timeStamp|valorTotal|CPFCNPJValue|assinaturaQRCODE
	cKeyQrCode := SUBSTR(OCANSAT:XPathGetAtt( "/CFeCanc/infCFe", "Id" ),4) + "|" // Chave Consulta
	cKeyQrCode += OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/ide/dEmi" ) + OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/ide/hEmi" ) + "|" // Data e Hora
	cKeyQrCode += OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/total/vCFe" ) + "|" // Valor Total do CFe-SAT
	cKeyQrCode += IIF(!Empty(cCGC),cCGC,"") + "|" // CNPJ adquirente (se existir) (sem pontuações)
	cKeyQrCode += OCANSAT:XPathGetNodeValue( "/CFeCanc/infCFe/ide/assinaturaQRCODE" ) // AssinaturaQRCODE	
	
	cTexto += cQuebraLn
	cTexto += TAG_CENTER_INI + TAG_QRCODE_INI + cKeyQrCode
	If ExistFunc("INFTamQrCd") //Ajuste do Tamanho do QrCode
		cTexto += INFTamQrCd(cModelo,"SAT")
	Else
		If 'DARUMA' $ cModelo
			cTexto += TAG_LMODULO_INI+"4"+TAG_LMODULO_FIM
		EndIf
	EndIf
	cTexto += TAG_QRCODE_FIM + TAG_CENTER_FIM + CHR(10) //Fim de QRCODE
	cTexto += cQuebraLn + TAG_CENTER_INI + cCondIni + TAG_NEGRITO_INI + cMsgApp + TAG_NEGRITO_FIM + cCondFim + TAG_CENTER_FIM
	cTexto += replicate(cQuebraLn,2)
		
	//Imprime 
	LjGrvLog("SAT","Envia comando para impressora imprimir comprovante de cancelamento")
	If lPos
		STWPrintTextNotFiscal(cTexto)
		cTexto := TAG_GUIL_INI+TAG_GUIL_FIM
		STWPrintTextNotFiscal(cTexto)
	Else
		If ExistFunc("LjAskSat")
			//Tratamento paliativo para impressora Bematech, ate a solucao de problema de comunicacao por parte da BEMATECH
			nRetImp := 999
			While nRetImp <> 0 .And. LjAskSat(nRetImp)
				nRetImp := INFTexto(cTexto)  //Envia comando para a Impressora
			End
		Else
			INFTexto(cTexto)  //Envia comando para a Impressora
		EndIf
		If nRetImp == 0
			cTexto := TAG_GUIL_INI+TAG_GUIL_FIM
			INFTexto(cTexto)
		EndIf
	EndIf
	
	LjSaCtrCnc(.F.,.F.,,.T.,"C5")
Else
	LjGrvLog( "SAT", "Objeto oCanSAT não alimentado", oCanSAT )
EndIf	
LjGrvLog( "SAT", "Rotina de impressao do cancelamdo SAT **FIM**" )
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSatReImp
Imprime a venda novamente

@param      
@author     Varejo
@version    P11.8
@since      06/07/2015
@return     
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LJSatReImp(cDoc , cSerie)

Local cChave	:= ""
Local lReimp	:= .T.
Local lPOS 		:= STFIsPOS() //Pos?
Local nFatorP	:= 1 // Fator de reserva para venda do tipo pedido
Local aRetImp	:= {}
Local aArea		:= {}			// Armazena Area corrente

Default cDoc 		:= ""
Default cSerie 	:= ""

LjGrvLog( "SAT", "Rotina de Reimpressao **INICIO**" )

aArea := SL1->(GetArea())

DbSelectArea("MH2")

If ValType(cDoc) == "C" .And. ValType(cSerie) == "C" .And. !Empty(cDoc) .And. !Empty(cSerie)
	cChave := cSerie + cDoc 
	MH2->( DbSetOrder(3) ) 
	//Força posicionamento na SL1
	SL1->(DbSetOrder(2)) //"L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV"
	SL1->( DbSeek(xFilial("SL1") + cChave) )	
Else
	cChave := SL1->L1_KEYNFCE
	
	If lPOS
		cChave := STDCSLastSale("L1_KEYNFCE")
	EndIf	
	MH2->( DbSetOrder(2) )
EndIf

If !Empty(SL1->L1_KEYNFCE) .And. MH2->( DbSeek(xFilial("MH2") + cChave) )
	
	If AllTrim(MH2->MH2_TIPO) == "VENDA"
		LojSATImprimir(MH2->MH2_XMLRET, MH2->MH2_XMLENV, , , ,lReimp)
	Else	
		LJImpCanSat(MH2->MH2_XMLRET, MH2->MH2_XMLENV, , , lReimp)
	EndIf	
	
	If lPOS
		STFMessage(ProcName(),"STOP", cSiglaSat + " - Reimpressão executada com sucesso!" ) //"SAT - Transmitido com sucesso"
		STFShowMessage(ProcName())	
	Else
		MsgAlert("Reimpressão executada com sucesso!")
	EndIf
	
	LjGrvLog( "SAT", "Reimpressao executada com sucesso" )

ElseIf !Empty(SL1->L1_DOCPED)
	// Reimpressão do cupom não fiscal (Pedido)
	/* Foi adicionado na reimpressão do cupom SAT a reimpressão do cupom SCRPED em caso de venda Mista.
	Necessário pois caso haja perda de comunicação com a impressora será necessário imprimir os comprovantes.*/
	aRetImp := Lj7ImpCNF(,nFatorP,,,,,,,,,,,,,,lReimp)
	If aRetImp[1]
		MsgAlert("Reimpressão do pedido executada com sucesso!")
		LjGrvLog( "SAT", "Reimpressao do SCRPED executada com sucesso" )
	Else
		MsgAlert("Problemas na reimpressão do pedido. Verifique!")
		LjGrvLog( "SAT", "Problemas na reimpressão do SCRPED" )
	EndIf
Else
	If lPOS
		STFMessage(ProcName(),"STOP", cSiglaSat + " - Não foi possível realizar a reimpressão!" ) //"SAT - Transmitido com sucesso"
		STFShowMessage(ProcName())	
	Else
		MsgAlert("Não foi possível realizar a reimpressão. Verifique se a venda é uma venda referente ao "+cSiglaSat+".")
	EndIf
	
	LjGrvLog( "SAT", "Nao foi possivel realizar a reimpressao" )
EndIf

RestArea(aArea)

LjGrvLog( "SAT", "Rotina de Reimpressao **FIM**" )

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LjUseSat
Valida se esta usando o SAT 

@author  	Varejo
@version 	P11.8
@since   	17/02/2014
@return  	lUseSAT		
@sample
/*/
//-------------------------------------------------------------------
Function LjUseSat()
Local lJob		:= IsBlind()
Local cEstCob 	:= SM0->M0_ESTCOB	
Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local lIsMDI 	:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),oApp:lMDI) //Verifica se acessou via SIGAMDI

/*---------------------------------------------------------------  
	Verifico se estou em Job pois existem casos que temos
	NFC-e e SAT na mesma retaguarda e no processo do gravabatch
	a estação não é setada todas as vezes, tratando todas as vendas
	igualmente. 
---------------------------------------------------------------*/
If nModulo == 5  //Venda direta não emite SAT
	lUseSAT := .F.
ElseIf !lIsMDI .Or. Select("SLG") > 0
	If lAutomato
		lUseSAT := LjGetStation("LG_USESAT")
	ElseIf lUseSAT == Nil
		If lJob
			//Quando é JOB (ExecAuto), verifica se está posicionado no SL1 da filial correta em execução, 
			//senão estaria fazendo a verificação incorreta considerando o campo L1_SERSAT do registro de outra filial.
			If xFilial("SL1") <> SL1->L1_FILIAL
				//Posiciona no primeiro registro da filial correta em execução
				SL1->(DbSeek(xFilial("SL1")))
			EndIf
			lUseSAT := !Empty(AllTrim(SL1->L1_SERSAT))
		Else
			If LjAnalisaLeg(70)[1]
				If lIsPOS
					lUseSAT	:= STFGetStation("USESAT")
				Else
					lUseSAT := IIF(LJGetStation("USESAT") == Nil .OR. !LJGetStation("USESAT"),.F.,.T.)
				EndIf
			Else
				lUseSAT := .F.	
			Endif
		EndIf
	
		lMFE := lUseSAT .And. cEstCob $ "CE"
		cFabSat := IIF(lIsPOS,STFGetStation("FABSAT"),LjGetStation("FABSAT"))
		lIntegrador := IIF(Upper(cFabSat) == "COMUNICACAO DIRETA", .F., .T.)
	Endif
EndIf
		
Return lUseSAT

//-------------------------------------------------------------------
/*/{Protheus.doc} LjGetAESAT
Retorna administradora referente ao SAT

@param   	
@author  	Varejo
@version 	P11.8
@since   	01/07/2015
@return  	lUseSAT		
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LjGetAESAT(cCOD)
	
Local cRetorno	:= "" //Codigo administradora SAT
Default cCOD		:= ""

DbSelectArea("SAE")
DbSetOrder(1)
	
If DbSeek(xFilial("SAE") + cCOD)
	If !Empty(AllTrim(SAE->AE_SAT))
		cRetorno := SAE->AE_SAT
	EndIf		
EndIf
	
Return cRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} LjGrvLogSAT
Grava Log SAT

@param   	
@author  	Varejo
@version 	P11.8
@since   	03/07/2015
@return  			
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LjGrvLogSAT(cSerie, cVenda, cKey, cXMLEnv, cXMLRet, cTipo, cStatus, cMsgErro)

Local cNumLog	:= 0

Default cSerie 	:= "" 
Default cVenda 	:= "" 
Default cKey 		:= "" 
Default cXMLEnv 	:= "" 
Default cXMLRet 	:= "" 
Default cTipo 	:= "" 
Default cStatus 	:= "" 
Default cMsgErro 	:= "" 

DbSelectArea("MH2")
MH2->(DbSetOrder(1))

If !MH2->(DbSeek(xFilial("MH2")))
	cNumLog	:= StrZero(1, TamSx3("MH2_NUM")[1])
Else
	cNumLog := GetSX8Num("MH2","MH2_NUM")
EndIf

Reclock("MH2",.T.)

MH2->MH2_FILIAL := xFilial("MH2")
MH2->MH2_NUM	:= cNumLog
MH2->MH2_SERIE	:= cSerie
MH2->MH2_DOC	:= cVenda
MH2->MH2_DOCCHV	:= cKey
MH2->MH2_XMLENV	:= cXMLEnv
MH2->MH2_XMLRET	:= cXMLRet 
MH2->MH2_TIPO	:= cTipo
MH2->MH2_STATUS	:= cStatus
MH2->MH2_MSGERR	:= cMsgErro
MH2->MH2_TIME	:= FWTimeStamp( 1, Date(), Time() )
MH2->MH2_SITUA	:= "00"

MH2->(ConfirmSX8())
MH2->(MsUnlock())	

//Grava o arquivo XML da Venda ou Cancelamento
If AllTrim(cStatus) <> "ERRO"
	LjGerAqXml(cXMLRet, cTipo, cKey)
EndIf

Return 



//-------------------------------------------------------------------
/*/{Protheus.doc} LjAssinaInfo
Assina texto informado

@param   	cSignInfo	- Conteúdo a ser assinado
@param   	nTpCrypt - Tipo de algortimo
			Tipo do algortimo digest que poderá ser utilizado:
				1 - MD5
				2 - RIPEMD160
				3 - SHA1
				4 - SHA224
				5 - SHA256
				6 - SHA384
				7 - SHA512 
@author  	Varejo
@version 	P11.8
@since   	01/07/2015
@return  	cHash		
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LjAssinaInfo(cSignInfo, nTpCrypt)
	
Local cCert		:= '\certs\000001_key.pem'	//Chave Primária 
Local cMacro		:= "" 							//Execução da macro
Local cError		:= "" 							//Erro
Local cSignature	:= "" 							//Conteúdo assinado
Local cHash		:= "" 							//Hash do conteúdo assinado
Local cPass		:= "SENHA CERTIFICADO"		//Senha chave privada

Default cSignInfo	:= "" 							
Default nTpCrypt	:= 5  //Tipo de algortimo necessário para o SAT (SHA256)

cMacro   := "EVPPrivSign" //Assina determinado conteúdo usando uma chave privada.

cSignature := &cMacro.(cCert , cSignInfo , nTpCrypt , cPass , @cError) //Assinando

cHash := Encode64(cSignature) 	
	
Return cHash


//-------------------------------------------------------------------
/*/{Protheus.doc} LjGetSig
Retorna chave de ativação SAT

@param   				
@author  	Varejo
@version 	P11.8
@since   	01/07/2015
@return  	cChSat		
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LjGetSig()

LOCAL cPath 	:= GETCLIENTDIR() //diretorio raiz smartclient	
LOCAL cArquivo	:= "sat-" + ALLTRIM(SM0->M0_CGC) + ".txt" //Nome do Arquivo: sat-CNPJ.txt
LOCAL nHandle	:= 0
LOCAL nTamanho	:= 0	//tamanho do arquivo
LOCAL cChSat	:= ""	//chave de ativação do sat
LOCAL cMsgErr	:= ""	//mensagem de erro
LOCAL lAchouArq := File(cPath + cArquivo)

LjGrvLog("SAT","LjGetSig - Inicio:", , .T.)

If lAchouArq
	nHandle	:= FOPEN(cPath + cArquivo)
EndIf

IF !lAchouArq .Or. FERROR() <> 0
	LjGrvLog( "SAT","Não foi possivel abrir o arquivo ou não foi localizado - cPath + cArquivo", cPath + cArquivo )
	cMsgErr := STR0088 //"SAT - Atenção. Código de Vinculação não encontrado ou com erro." 
	cMsgErr += CRLF+CRLF
	cMsgErr += STR0089 + cPath + cArquivo + STR0090 //"Não foi possível abrir o arquivo " + cPath + cArquivo + " ou não foi localizado."
	cMsgErr += CRLF 
	cMsgErr += STR0091 + " tdn.totvs.com" //"Este código é obtido via abertura de chamado para o CST. Para mais informações acesse o item 3 da FAQ do SAT em nosso portal:"
ELSE
	nTamanho := FSEEK(nHandle,0,2) 
	FSeek( nHandle, 0 )
	cChSat := Space( nTamanho )
	FRead( nHandle, @cChSat, nTamanho )
	FCLOSE(nHandle)
	
	cChSat := Replace(cChSat,Chr(10),"")
	LjGrvLog("SAT"," LjGetSig - Obtendo Assinatura a partir do arquivo txt - cChSat:", cChSat)
	
	If Empty(AllTrim(cChSat))
		LjGrvLog( "SAT","Arquivo em branco. - cPath + cArquivo", cPath + cArquivo )
		cMsgErr := STR0088 //"SAT - Atenção. Código de Vinculação não encontrado ou com erro." 
		cMsgErr += CRLF+CRLF		
		cMsgErr += STR0092 //"Arquivo em branco. Verifique o conteúdo e tente acessar o sistema novamente."
		cMsgErr += CRLF
		cMsgErr += STR0091 + " tdn.totvs.com"//"Este código é obtido via abertura de chamado para o CST. Para mais informações acesse o item 3 da FAQ do SAT em nosso portal:"		
	EndIf
	
ENDIF  

LjGrvLog("SAT"," LjGetSig - Fim - cChSat:", cChSat ) 
 
Return {cChSat,cMsgErr}


//-------------------------------------------------------------------
/*/{Protheus.doc} LjGetNextSat
Retorna proximo numero de documento do SAT de acordo com a Serie 

@param   	cSerie numero de serie da estação			
@author  	Varejo
@version 	P11.8
@since   	16/07/2015
@return  	cRetNexSat		
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LjGetNextSat(cSerie)
	Local cRetNexSat 	:= ""
	
	DbSelectArea("MH2")
	DbSetOrder(3) //FILIAL + SERIE + DOC 
	
	If DbSeek(xFilial("MH2")+cSerie, .T.)
		cRetNexSat := StrZero(Val(MH2->MH2_DOC) + 1, Len(MH2->MH2_DOC))
		
		//Caso seja o ultimo documento de acordo com a numeração do SAT ele retorna para o primeiro número
		If cRetNexSat == "999999"
			cRetNexSat := "000001"
		EndIf
		
	Else
		cRetNexSat := "000001" //Verificar para quando o SAT já foi utilizado não pode pegar o primeiro numero pois não é o ultimo 
	EndIf
	
Return cRetNexSat

//-------------------------------------------------------------------
/*/{Protheus.doc} LjGetTriSat
Retorna array com a tributação dos produtos

@param   			
@author  	Varejo
@version 	P11.8
@since   	16/09/2015
@return  	aSATTrib		
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LjGetTriSat()
Return aSATTrib

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSetTriSat
Define valores das tributações dos produtos 

@param   	aArr		array das tributações		
@author  	Varejo
@version 	P11.8
@since   	16/09/2015
@return  	aSATTrib		
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LjSetTriSat(aArr)

Default aArr := {}

aSATTrib := aArr

Return aSATTrib

//-------------------------------------------------------------------
/*/{Protheus.doc} LjFindTriSat
Recupera valores das tributações dos produtos 

@param   	nItem		posiçao do item 
@param   	cCampo		tributo a ser pesquisado 
@author  	Varejo
@version 	P11.8
@since   	16/09/2015
@return  	nValor		
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LjFindTriSat(nItem, cCampo)

Local nValor 		:= 0
Local nPos			:= 0
Local lPOS			:= STFIsPOS() //Pos?

Default nItem 		:= 0
Default cCampo 	:= ""

/*	Exemplo:
	aSATTrib[x][1] Numero do item 
	aSATTrib[x][2] Campo a ser pesquisado
	aSATTrib[x][3] Valor do campo
	aSATTrib[x][4] Numero do item SEM CONTAR OS DELETADOS, após novo filtro antes do envio XML SAT (Somente TOTVS PDV)
*/

If Len(aSATTrib) > 0 .And. nItem > 0 .And. !Empty(cCampo)
	If nModulo == 23 .AND. lPOS .AND. Len(aSatTrib[1]) >= 4			//TOTVS PDV, já tem seu quarto elemento identificado
		nPos := aScan(aSATTrib, {|x| x[4] == nItem .And. x[2] == cCampo } )
	Else															//Front Loja
		nPos := aScan(aSATTrib, {|x| x[1] == nItem .And. x[2] == cCampo } )
	EndIf
	//Caso encontre o numero do item e o campo desejado, recupera o valor
	If nPos > 0
		nValor	:= aSATTrib[nPos][3]
	EndIf
EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} LjFindImpSat
Recupera valores dos impostos dos produtos 

@param   	cCampo		imposto a ser pesquisado 
@author  	Varejo
@version 	P11.8
@since   	16/09/2015
@return  	nValor		
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LjFindImpSat(cCampo)

Local nValor 		:= 0
Local nPos			:= 0

Default cCampo 	:= ""

If Len(aSATImp) > 0 .And. !Empty(cCampo)
	nPos := aScan(aSATImp, {|x| x[1] == cCampo } )
	//Caso encontre o numero do item e o campo desejado, recupera o valor
	If nPos > 0
		nValor	:= aSATImp[nPos][2]
	EndIf
EndIf

Return nValor


//-------------------------------------------------------------------
/*/{Protheus.doc} LjCreaImpSat
Recupera valores dos impostos dos produtos da venda selecionada 

@param   	cCampo		imposto a ser pesquisado 
@author  	Varejo
@version 	P11.8
@since   	16/09/2015
@return  	nValor		
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LjCreaImpSat()

Local nTotImpNCM 	:= 0		//Total Imposto
Local nTotVLRNCM 	:= 0		//Total do produto
Local nTotFed 		:= 0		//Total Federal
Local nTotEst 		:= 0		//Total Estadual
Local nTotMun 		:= 0		//Total Municipal

DbSelectArea("SL2")
DbSetOrder(1)	
	
If SL2->( DbSeek( xFilial( "SL2" ) + SL1->L1_NUM ) )

	Do While !SL2->( EOF() ) .And. SL2->L2_FILIAL == xFilial("SL1") .And. SL2->L2_NUM == SL1->L1_NUM
		nTotImpNCM 	+= SL2->L2_TOTIMP		
		nTotVLRNCM 	+= SL2->L2_VLRITEM		
		nTotFed 		+= SL2->L2_TOTFED		
		nTotEst 		+= SL2->L2_TOTEST		
		nTotMun 		+= SL2->L2_TOTMUN	
		
		SL2->( dbSkip() )
	EndDo
	
	aAdd(aSATImp, {"TOTIMPNCM"	, nTotImpNCM} )
	aAdd(aSATImp, {"TOTVLRNCM"	, nTotVLRNCM} )
	aAdd(aSATImp, {"TOTFED"	, nTotFed} )
	aAdd(aSATImp, {"TOTEST"	, nTotEst} )
	aAdd(aSATImp, {"TOTMUN"	, nTotMun} )
	
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LjGerArqXml
Gera arquivo XML do retorno do SAT 
Como existem clientes que nao estao com a rotina atualizada e com isso
nao esta criando os arquivos, a funcao ficou generica, ou seja, se o 
cliente criar uma User Function chamando a funcao LjGerAqXml sem passar
nenhum parametro, eh criado os arquivos XML de toda a MH2.

@param   	 
@author  	Varejo
@version 	P11.8
@since   	01/12/2015
@return  			
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LjGerAqXml(cXmlSat, cTipo, cChave)

Local aArea := GetArea() //Guarda a area
Local cName := "" //Nome do arquivo XML
Local nHandle := 0 //Arquivo
Local cPathXml := SuperGetMV("MV_SATXML",,"") //Pega o caminho do diretorio onde sera gravado o XML
Local aDire := {} //Estrutura de diretorios

Default cXmlSat := ""
Default cTipo   := ""
Default cChave  := ""

//Cria o diretorio onde sera gravado o arquivo XML
If Empty(cPathXml)
	MakeDir("\AUTOCOM")
	MakeDir("\AUTOCOM\SATXML\")
	cPathXml := "\AUTOCOM\SATXML\"
Else
	cPathXml := AllTrim(cPathXml)
	cPathXml := IIF(SubStr(cPathXml, Len(cPathXml), 1) == "\", SubStr(cPathXml,1,Len(cPathXml)-1), cPathXml)
	aDire := Directory(cPathXml,"D")
	If Len(aDire) == 0	
		LjGrvLog( SL1->L1_NUM, "SAT - Nao foi possivel gerar o XML porque o diretorio nao existe!", cPathXml )
		Return .F.
	EndIf	
	cPathXml := cPathXml + "\"
EndIf

If Empty(cXmlSat)
	dbSelectArea("MH2")
	MH2->(dbGoTop())
	While MH2->(!Eof())
	
		If AllTrim(MH2->MH2_TIPO) == 'VENDA'
			cName := cPathXml + "AD" + AllTrim(MH2->MH2_DOCCHV) + ".XML"
		Else
			cName := cPathXml + "ADC" + AllTrim(MH2->MH2_DOCCHV) + ".XML"
		EndIf
			
		cXmlSat := AllTrim(MH2->MH2_XMLRET)
		
		If !Empty(cXmlSat) .AND. !File( cName )
				
			nHandle := FCreate( cName )
			FClose( nHandle )
			
			nHandle := FOpen( cName, 2 )
			FSeek ( nHandle, 0, 2 )
			FWrite( nHandle, cXmlSat + CRLF, Len(cXmlSat) + 2 )
			FClose( nHandle )
			
			//Renomeia o arquivo para deixar as letras em maiusculo
			FRenameEx( cName, Upper(cName) )
			
		EndIf
		
		MH2->(DbSkip())
				
	End
Else

	If AllTrim(cTipo) == 'VENDA'
		cName := cPathXml + "AD" + AllTrim(cChave) + ".XML"
	Else
		cName := cPathXml + "ADC" + AllTrim(cChave) + ".XML"
	EndIf

	If !Empty(cXmlSat) .AND. !File( cName )
			
		nHandle := FCreate( cName )
		FClose( nHandle )
		
		nHandle := FOpen( cName, 2 )
		FSeek ( nHandle, 0, 2 )
		FWrite( nHandle, cXmlSat + CRLF, Len(cXmlSat) + 2 )
		FClose( nHandle )
		
		//Renomeia o arquivo para deixar as letras em maiusculo
		FRenameEx( cName, Upper(cName) )
		
	EndIf
	
EndIf

RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSATDirv
Caso exista uma diferenca de valores adicionamos a diferenca em uma forma de pagamento.

@param   	 
@author  	Varejo
@version 	P11.8
@since   	23/09/2016
@return  			
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function LJSATDirv(aItensSat,aFormasPag,nTotDesc, nPayFactor)
Local nX 			:= 0
Local nTotFormas 	:= 0
Local nDif 			:= 0
Local nPosF 		:= 0    // posicção do numero da forma de pagamento
Local nValTotIt 	:= 0	// somatória de itens COM calculo de arredondamento.
Local nValTotIt1 	:= 0	// somatória de itens SEM calculo de arredondamento.

Default aItensSat 	:= {}
Default aFormasPag 	:= {}
Default nTotDesc   	:= 0
Default nPayFactor 	:= 1

LjGrvLog( "SAT", "Validacao caso exista uma diferenca de valores adicionamos a diferenca em uma forma de pagamento.  - **INICIO** " )

If Len(aItensSat) > 0 .And.  Len(aFormasPag) > 0

	For nX := 1 to Len(aFormasPag)
		nTotFormas += aFormasPag[nX][2] 	
	Next nX
	
	LjGrvLog( "SAT", "Total das formas de pagamento - nTotFormas: ", nTotFormas )
	
	For nX := 1 to Len(aItensSat) // Essa Divisao e multiplicação se faz necessaria para verificar se existe diferenca no arredondamento
		nValTotIt  += Round(Round(aItensSat[nX][1] / aItensSat[nX][2], 2 ) * aItensSat[nX][2], 2 )	
		nValTotIt1 += aItensSat[nX][1] // somatória de itens sem ROUND
	Next nX
	
	LjGrvLog( "SAT", "Total dos itens - nValTotIt: ", nValTotIt)
	
	// Se total de formas de pagto e total dos itens coincidem não precisa de ajuste.
	If (nValTotIt1  - nTotDesc) > nTotFormas .AND. (nValTotIt - nTotDesc) > nTotFormas
	
		LjGrvLog( "SAT", "Valor dos itens maior que os da forma de pagamento")
		
		nDif := (nValTotIt - nTotDesc) - nTotFormas
		// Se a diferenca for maior que 0.02 centavos o problema j nao eh arrendodamento.
		If nDif <= 0.02
			LjGrvLog( "SAT", "Valor da diferenca - nDif: ", nDif)
			// Adiciono a Diferenca na forma de pagamento outros para envio no SAT.
			// Adiciono a Diferenca na forma de pagamento Dinheiro caso nao tenha adiciono outros com a diferenca.
			nPosF := aScan(aFormasPag,{|x| Alltrim(x[1]) == "01" })
			If nPosF > 0 
				aFormasPag[nPosF][2] := aFormasPag[nPosF][2] +  nDif	
			Else
				nPosF := aScan(aFormasPag,{|x| Alltrim(x[1]) == "99" })
				If nPosF > 0 
					aFormasPag[nPosF][2] := aFormasPag[nPosF][2] +  nDif
				Else		 
					AAdd(aFormasPag, {"99", nDif ,Replicate(" ",20)  } )
				EndIf	  
			EndIf
			
			//Caso seja reaizado o acerto do valor aceto o fator para que não crie diferenca e cause rejeição.
			If nPayFactor <> 1 
				nPayFactor := 1 
			EndIf
			
			LjGrvLog( "SAT", "Foi adicionado o Valor de 0.01 centavo por consequencia de Arredondamento dos itens. " )
		Else
			LjGrvLog( "SAT", "Valor da diferenca maior que 0.02 - nDif: ", nDif)				
		EndIf
	EndIf
	
EndIf

LjGrvLog( "SAT", "Validacao caso exista uma diferenca de valores adicionamos a diferenca em uma forma de pagamento.  - **FIM** " )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjZeraNFisc
Responsável por limpar os valores da venda.

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	14/10/2016
@return	Nil  			
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function LjZeraNFisc()
	aTotVenda	:= {0,0}
	nValTotCP	:= 0
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSatTotVenda
Soma no array aTotVenda na posição referente ao tipo do tipo:
[1] - Valor total dos itens fiscais
[2] - Valor total dos itens não fiscais.

Este valor deve ser o valor bruto, ou seja, o valor original do item (sem desconto e sem frete)

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	14/10/2016
@return	Nil  			
@obs		Este valor deve ser o valor bruto, ou seja, o valor original do item (sem desconto e sem frete)     
@sample
/*/
//-------------------------------------------------------------------
Static Function LjSetTotVenda(nValor,lFiscal,lItemGE)
Local cVlrItem 		:= ""		
Local nTmVlrItem	:= GetSX3Cache("L2_VLRITEM", "X3_TAMANHO")

Default nValor	:= 0
Default lFiscal	:= .T.
Default lItemGE := .F.

If Type("nDecimais") == "U"
	nDecimais := MsDecimais(1)
EndIf

If lFiscal
	aTotVenda[1] += nValor 
Else
	aTotVenda[2] += nValor
EndIf

If ExistFunc("LjNFCeGE") .AND. (lItemGE .OR. !Empty(SL2->L2_GARANT))
	cVlrItem := Str( a410Arred(SL2->L2_VRUNIT * SL2->L2_QUANT, "L2_VLRITEM"), nTmVlrItem,nDecimais )
	LjNFCeGE( IIF(lFiscal, 1, 2), {SL2->L2_PRODUTO, SL2->L2_DESCRI, cVlrItem, SL2->L2_NSERIE, IIF(lFiscal,SL2->L2_GARANT,Nil)} )
Endif 

LjGrvLog( "SAT", "Item " + Iif(!lFiscal,"NÃO ", "" )  + "fiscal - Valor: ", SL2->L2_VLRITEM + SL2->L2_DESCPRO )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSATRetDoc
Retorna a numeração do doc e serie da venda do SAT.

@param		cXML - Xml de retorno do SAT
@author  	Varejo
@version 	P11.8
@since   	21/10/2016
@return	aRet - [1] - numero do doc do sat / [2] - serie do sat / [3] - chave do sat
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LJSATRetDoc(cXML, aInfoSat, lShowMsg)
Local cDoc			:= ""
Local cSerie		:= ""
Local cChave		:= ""
Local oExtratoSAT	:= Nil
Local lPOS 			:= STFIsPOS() //Pos?
Local cAssQRCODE	:= "" //Assinatura qrcode da venda
Local lRet			:= .F.

Default cXML			:= "" 
Default aInfoSat		:= {}
Default lShowMsg		:= .F.

If !Empty(cXML)
	oExtratoSAT := TXMLManager():New()
	//executa o PARSE na string XML de retorno
	lRet := oExtratoSAT:Parse( cXML )
	
	LjGrvLog("SAT","Efetuou o Parse do XML retornado do equipamento - lRet", lRet)
	
	If !lRet 
		If Len(aInfoSat) > 4
			LjGrvLog( "SAT", "XML ANTES DO DECODE - cXMLEncode", aInfoSat[5] )
		EndIf	
		If !Empty( oExtratoSAT:Error() )
			LjGrvLog( "SAT", "ERRO AO EXECUTAR O METODO PARSE: ", oExtratoSAT:Error() )
		ElseIf !Empty( oExtratoSAT:Warning() )
			LjGrvLog( "SAT", "AVISO AO EXECUTAR O METODO PARSE: ", oExtratoSAT:Warning() )
		EndIf
	EndIf 		
	
	If lRet .And. oExtratoSAT <> Nil  
		cDoc 	:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/ide/nCFe" )
		cSerie	:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/ide/nserieSAT" )
		cChave	:= 	SUBSTR(OEXTRATOSAT:XPathGetAtt( "/CFe/infCFe", "Id" ),4)
		cAssQRCODE := OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/ide/assinaturaQRCODE" )
	ElseIf Len(aInfoSat) > 8
		LjGrvLog("SAT","A venda sera finalizada sem as informacoes do XML de retorno, com base nos outros campos de retorno do equipamento.")
		cChave	:= SUBSTR(aInfoSat[7],4)
		cDoc 	:= SUBSTR(cChave,32,6)
		cSerie	:= SUBSTR(cChave,23,9)
		cAssQRCODE	 := aInfoSat[9]
	ElseIf lShowMsg		
    	If lPOS
    		STFMessage("STWFINISHSALE","POPUP", "SAT - Não conformidade encontrada com o dados de retorno do EQUIPAMENTO SAT, por esse motivo não é possível imprimir o comprovante.")
			STFShowMessage("STWFINISHSALE")
		Else
			MsgAlert("SAT - Não conformidade encontrada com o dados de retorno do EQUIPAMENTO SAT, por esse motivo não é possível imprimir o comprovante.")
		EndIf
	EndIf
EndIf	

Return {cDoc, cSerie, cChave, cAssQRCODE}

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSatCSEFAZ
Realiza a Consulta no SEFAZ, no retorno estamos buscando a data da ultima comunicação com o SEFAZ. 

@param		cXML - Xml de retorno do SAT
@author  	Varejo
@version 	P11.8
@since   	21/10/2016
@return	aRet - [1] - numero do doc do sat / [2] - serie do sat	
/*/
//-------------------------------------------------------------------
Static Function LJSATCSEFAZ()
Local aSATConsultar := {}
Local cRet          := ""

If LjSatGetSO() == nil
	LjSatSetSO()
EndIf

aSatConsultar := LjSatGetSO()

If Len(aSATConsultar) > 24
	LjGrvLog( "SAT - 03. LJSATCSEFAZ", "Verificação do Comando " + Time()+ " aSATConsultar[2]: ", aSATConsultar[2]  )
	If aSATConsultar[2] == '10000' // Busco a data do ultima Comunicação com o SEFAZ 
		cRet := DtoC(StoD(subStr(aSATConsultar[25],1,8)))
	EndIf
EndIf

LjGrvLog( "SAT - 03. LJSATCSEFAZ", "Fim da Rotina " + Time(), )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSatComunic
Essa funcção tem o objetivo não permitir a venda com o Sat caso esse fique um periodo
sem comunicação com o SEFAZ pois caso essa perda de comunicação com o SEFAZ ultrapasse
mais de 10 dias as vendas repesadas serão invalidadas. mesmo o cliente tendo o 
comprovante impresso.

@param		-
@author  	Varejo
@version 	P11.8
@since   	21/10/2016
@return	aRet - [1] - numero do doc do sat / [2] - serie do sat	
/*/
//-------------------------------------------------------------------
Function LJSatComunic()
Local lRet		  := .T.
Local cData		  := ""
Local nDiasDif    := 0
Local nDiasTRv    := 0
Local nDiasMens   := 0
Local nPosAux	  := 0
Local cMV_SATTRDT := AllTrim(SuperGetMv("MV_SATTRDT",,"3;5"))
Local aSATTRDT    := Array(2)
Local cMensagem   := ""

If !Empty(cMV_SATTRDT)
	nPosAux := At(";",cMV_SATTRDT)
	If nPosAux == 0 .Or. (Len(cMV_SATTRDT) < 3)
		cMensagem := " A configuração do parametro MV_SATTRDT está incorreta, por favor " +;
					" corrija a configuração conforme link do TDN: http://tdn.totvs.com/display/PROT/DT_MV_SATTRDT " + CHR(13) +;
					" Ajuste o separador para ponto-e-vírgula(;), por exemplo: 3;5 "
		STPosMSG( "Inconsistência na Configuração de Parâmetro" , cMensagem, .T., .F., .F.)
		LjGrvLog(Nil,cMensagem)
		Conout(cMensagem)
		cMV_SATTRDT := "3;5"
	EndIf

	aSATTRDT := Separa(cMV_SATTRDT,";")
EndIf

nDiasMens := If(Val(aSATTRDT[1]) == 0 , 3 , If(Val(aSATTRDT[1]) > 05 , 3 , Val(aSATTRDT[1])))
nDiasTRv  := If(Val(aSATTRDT[2]) == 0 , 5 , Val(aSATTRDT[2])  )
LjGrvLog( "SAT - 00. LJSatComunic", "Inicio da função " + Time(), )
LjGrvLog( "SAT - 01. LJSatComunic", "Conteudo do Parametro cMV_SATTRDT = " + cMV_SATTRDT + "  - "  + Time(), )

If !Empty(cMV_SATTRDT) .and. Empty(dDtComSFZ) 
	cData := LJSatCSEFAZ()
	cData := IIf(Empty(cData),CtoD("  /  /    "), If(cData == '00/00/0000',CtoD("  /  /    "),CtoD(cData))  )
    dDtComSFZ := cData	         
EndIf

If nDiasTRv >= 10
	cMensagem := STR0068 + chr(13) + chr(10) //"Conteúdo do Parâmetro MV_SATTRDT está acima do valor aceito pelo SEFAZ para a transmissão das vendas."
	cMensagem := cMensagem + STR0069   //"Entre em contato com o Administrador do Sistema"
	MsgStop(cMensagem) 
EndIf

LjGrvLog( "SAT - 02. LJSatComunic", "Verificação " + Time()+ " Data do SEFAZ :" , cData)
nDiasDif := dDataBase -  dDtComSFZ 	         

LjGrvLog( "SAT - 03. LJSatComunic","Hora : " + Time() + "Diferenças de dias ",nDiasDif )
LjGrvLog( "SAT - 04. LJSatComunic","Hora : " + Time() + "Dias para Verificação ",nDiasTRv )
If nDiasDif >= nDiasTRv
	lRet := .F.
	MsgStop(STR0070 + AllTrim(Str(nDiasDif)) + STR0071 +chr(13) +chr(10) + STR0072 )    //"Este Equipamento SAT esta a com " /  " dias sem Comunicação com o Site do SEFAZ." / "Não será permitido realizar vendas."		
	If nModulo == 23		
		Final(STR0073 + chr(13) + chr(10) + STR0074)   // "Favor Entrar em contato com o responsável pelo sistema" / "Sistema será Finalizado"
	EndIf	
ElseIf nDiasDif >= nDiasMens
	MsgAlert(STR0070 + AllTrim(Str(nDiasDif)) + STR0071 +chr(13) +chr(10) + STR0072 )	// "Este Equipamento SAT esta a com " / " dias sem Comunicação." / "Entre em contato com o Suporte"
EndIf    	            

LjGrvLog( "SAT - 05. LJSatComunic","Hora : " + Time() + "Fim da Rotina ", )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SATValidCanc
Essa funcção tem o objetivo validar se o cancelamento a ser realizado no equipamento
SAT refere-se a uma venda que não esta no sistema, utilizado na recuperação de venda
onde não se sabe se o SAT recebeu a venda que por algum motivo nao foi finalziada no sistema
devido a queda ou erro.

@param
@author  	Varejo
@version 	P11.8
@since   	24/11/2016
@return	lRet -> .T. -> Pode cancelar a venda que esta so no SAT/
			lRet -> .F. -> Não pode cancelar pois a venda esta no sistema e no SAT
/*/
//-------------------------------------------------------------------
Function SATValidCanc() 
Local lRet			:= .F.
Local cArqSessao	:= GetClientDir() + "sessaosat.txt"
Local cPass			:= STFGetStation("CODSAT",,.F.)
Local cCOd			:= GetPvProfString("SAT","SESSAO","",cArqSessao )
Local aUC	 		:= {}
Local aCso			:= {}
Local cDoc			:= ""
Local cSerie		:= ""
Local oExtratoSAT	:= Nil
Local aSL1Area		:= SL1->(GetArea())
Local aSL2Area		:= SL2->(GetArea())
Local aSL4Area		:= SL4->(GetArea())
Local lLoja			:= nModulo == 12
Local nTamSerie		:= TamSx3("LG_SERIE")[1]

LjGrvLog("SAT"," SATValidCanc - Inicio", , .T. )

If lMFE .And. lIntegrador
	LjConsSess(cCOd)
EndIf

aUC := LJSATComando({"12","ConsultarNumeroSessao",LJSATnSessao(), cPass,cCOd}) //Ultimo comando

SetConsNS(aUC)

If lMFE .And. lIntegrador
	LjStatusOP()
EndIf

aCso := LJSATComando({"12","ConsultarStatusOperacional",LJSATnSessao(),cPass }) //retorna CSO

If Len(aUC) > 6 .And. Len(aCso) > 20
	cUCChave	:= AllTrim(SubStr(aUC[7],4))
	cCsoChave	:= AllTrim(aCso[21])

	lRet := cUCChave == cCsoChave

	LjGrvLog("SAT"," SATValidCanc - LJSATComando -> cUCChave == cCsoChave  ", lRet )

	If lRet
		//Verifica se é referente a ultima venda finalizada com sucesso
		oExtratoSAT := TXMLManager():New()

		//executa o PARSE na string XML
		lRet := oExtratoSAT:Parse(Decode64(aUC[5]) )
		
		LjGrvLog("SAT","Efetuou o Parse do XML retornado do equipamento - lRet", lRet)
		
		If !lRet
			If !Empty( oExtratoSAT:Error() )
				LjGrvLog( "SAT", "ERRO AO EXECUTAR O METODO PARSE: ", oExtratoSAT:Error() )
			ElseIf !Empty( oExtratoSAT:Warning() )
				LjGrvLog( "SAT", "AVISO AO EXECUTAR O METODO PARSE: ", oExtratoSAT:Warning() )
			EndIf
		EndIf		
		
		If lRet .And. oExtratoSAT <> Nil
			cSerie	:= PadR(STFGetStation("SERIE",,.F.), nTamSerie, " ") 
			cDoc	:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/ide/nCFe" )
			SL1->(DBSetOrder(2)) //L1_FILIAL + L1_SERIE + L1_DOC
			If SL1->(DBSeek(xFilial("SL1")+cSerie+cDoc))
				If lLoja
					lRet := (AllTrim(SL1->L1_SITUA) $ "T1|T2|T3") 
				Else
					lRet := .F.
				EndIf
			Else
				lRet := .T.
			EndIf
		EndIf
	Endif

EndIf

RestArea(aSL4Area)
RestArea(aSL2Area)
RestArea(aSL1Area)

LjGrvLog("SAT"," SATValidCanc - Fim", )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetConsNS

@param		
@author  	Varejo
@version 	P11.8
@since   	24/11/2016
@return	aCNS - Array com a consulta para o equipamento "ConsultarNumeroSessao"
/*/
//-------------------------------------------------------------------
Static Function GetConsNS()
Return aCNS

//-------------------------------------------------------------------
/*/{Protheus.doc} SetConsNS


@param		aConsNS - 
@author  	Varejo
@version 	P11.8
@since   	24/11/2016
@return	lRet -> .T. -> Pode cancelar a venda que esta so no SAT/
			lRet -> .F. -> Não pode cancelar pois a venda esta no sistema e no SAT
/*/
//-------------------------------------------------------------------
Static Function SetConsNS(aConsNS)
Default aConsNS := {}
aCNS := aConsNS
Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} LjAskSat
Pergunta se deseja tentar imprimir novamente caso ocorra algum erro durante a impressao.

@type function

@author  Varejo
@version P11.8
@since   11/11/2016

@param	nRetImp Retorno anterior da impresora	 
@return lRet - Retorna .T. se deve tentar imprimir novamente.
/*/
//----------------------------------------------------------
Function LjAskSat(nRetImp, lMsgAlert)
Local lRet 			:= .T.
Local lTenta 		:= .T.
Local nHdlECF		:= -1
Local cImpressora	:= LjGetStation("IMPFISC")
Local nContPerg		:= 1
Local nTSleep		:= 7
Local lAutomato 	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX) //Variavel referente a automacao de testes

Default lMsgAlert 	:= .T.

If nRetImp <> 0 .And. nRetImp <> 999
	
	If lMsgAlert
		//Fecha a comunicacao com a impressora para tentar nova comunicação
		cPorta	:= LjGetStation("PORTIF")
		INFFechar()		
		
		MsgInfo("Ocorreu algum problema durante a impressão." + " " + " Será realizado nova tentativa de comunicação!"; // "Ocorreu algum problema durante a impressão. Será realizado nova tentativa de comunicação!"
		+ Chr(10)+Chr(13) + STR0053, STR0003) //"Verifique se a impressora esta LIGADA." ### "Atenção"
		
		//Abre a comunicacao com a impressora.
		If !lAutomato//Quando executado via robô não deve tentar comunicação com os perifericos
			LjMsgRun( STR0050,, { || nHdlECF := INFAbrir( cImpressora, cPorta ) } ) //"Aguarde. Comunicando com a Impressora Não Fiscal..."
		Endif
		If nHdlECF == -1 // Verifica se a impressora voltou a responder apos a msg acima	
			While lTenta .And. nContPerg <= 3
			
				// Mesmo com parametro MV_NFCEIMP configurado para o Front ele nao foi implementado
				If nContPerg == 3
					MsgInfo(cSiglaSat+" TRANSMITIDO COM SUCESSO!", STR0003) //"SAT TRANSMITIDO COM SUCESSO!" ### Atenção

					MsgInfo(STR0056+ Chr(10)+Chr(13) +; // "******************************************"
				 			 STR0057+ Chr(10)+Chr(13) +; // "ATENÇÃO: DESLIGUE E LIGUE A IMPRESSORA!"
				 	        STR0056) 						 // "******************************************"				
				EndIf
				If nContPerg > 1	
					//Fecha a comunicacao com a impressora.
					INFFechar()
					cPorta	:= LjGetStation("PORTIF")
					// Espera a impressora se recomunicar (Necessário após uma perda de comunicação)
					Processa({||LJSleep(nTSleep)},"Preparando impressão!") //"Preparando impressão!"
					
					//Abre a comunicacao com a impressora.
					LjMsgRun( STR0050,, { || nHdlECF := INFAbrir( cImpressora, cPorta ) } ) //"Aguarde. Comunicando com a Impressora Não Fiscal..."
				EndIf				
				If nHdlECF == -1
					If nContPerg <= 2
						MsgInfo(STR0051 + cImpressora; // "Não foi possível estabelecer comunicação com a Impressora:"
						+ Chr(10)+Chr(13) + STR0054, STR0003) // "SERÁ REALIZADO NOVA TENTATIVA DE COMUNICAÇÃO." ### Atenção
					EndIf
					lTenta := .T.
					lRet 	:= .F.
				Else
					lTenta := .F.
					lRet 	:= .T.
				EndIf
				
				// Atualiza contador
				nContPerg := nContPerg + 1
			End
		EndIf		
	EndIf	
	/*Se após várias tentativas não for possível a impressão do cupom (SAT)
	orientamos o operador a reiniciar o PDV. */ 
	If !lRet .And. nHdlECF == -1
		MsgInfo("******************************************"+ Chr(10)+Chr(13) +;
				 "REINICIE O PDV. APÓS, SERÁ NECESSÁRIO"+ Chr(10)+Chr(13) +;
				 "UTILIZAR A ROTINA DE REIMPRIMIR SAT F12+34."+ Chr(10)+Chr(13) +;
				 "******************************************", STR0003)
	EndIf	
EndIf

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} LjSleep
Aguarda x segundos para iniciar o processamento

@type function

@author  Varejo
@version P11.8
@since   21/11/2016

@param	nTempSleep: Tempo de sleep	 
@return 
/*/
//---------------------------------------------------------
Function LjSleep(nTempSleep)

Local i := 0
Default nTempSleep := 1

ProcRegua(nTempSleep)

For i:= nTempSleep to 1 step -1
	IncProc("Aguarde... "+cValToChar(i)) //"Aguarde..."
	Sleep(1000)
Next

Return

//----------------------------------------------------------
/*/{Protheus.doc} LjSatErrCan
Mensagem de erro da tentativa de cancelamento do SAT no Protheus apos 
recuoperação de venda.

@type		Function
@author		Varejo
@version	P11.8
@since		14/12/2016
@return	Nil 
/*/
//----------------------------------------------------------
Function LjSatErrCan()
Local cMvInutCli := SuperGetMV("MV_INUTCLI", .F., "")
Local cMvInutPro := SuperGetMV("MV_INUTPRO", .F., "")
Local cMvInutTES := SuperGetMV("MV_INUTTES", .F., "")
Local cMsg			:= ""

If Empty(cMvInutCli) .Or. Empty(cMvInutPro) .Or. Empty(cMvInutTES)
	cMsg := STR0076 + CHR(10) + CHR(13) +; //'Para a recuperação de venda SAT, os parametros "MV_INUTCLI" , "MV_INUTPRO" e "MV_INUTTES" devem estar configurados corretamente.'
			 STR0077 //'Favor configura-los, caso contrário após a recuperação da venda SAT, os livros fiscais ficarão inconsistentes com os cancelamentos presente no equipamento SAT.'

	LjGrvLog( "SAT", cMsg )
	MsgAlert(cMsg,STR0003) //##"Atenção"
EndIf

Return Nil  

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSatCDataHora
Realiza a Consulta no SEFAZ, no retorno estamos buscando a data da ultima comunicação com o SEFAZ. 

@param		-
@author  	Varejo
@version 	P11.8
@since   	13/12/2016
@return	lRet	
/*/
//-------------------------------------------------------------------
Static Function LJSATCDataHora()
Local aSATConsultar := {}				//Array para trazer informações do aparelho SAT.
Local lRet			:= .T.				//Variável de retorno
Local cTempoSat		:= ""				//Conteúdo do aSATConsultar[18] - data/hora configurada no SAT
Local dDataSat		:= cTod("")			//Data SAT
Local cHoraSat		:= ""				//Hora SAT
Local cMsg			:= ""				//Mensagem
Local dDate			:= cTod("")			//Date()
Local cTime			:= ""				//Time()

If LjSatGetSO() == nil
	LjSatSetSO()
EndIf

aSatConsultar := LjSatGetSO() 

If Len(aSATConsultar) > 24
	cTempoSat 	:= aSATConsultar[18]	
	dDataSat	:= StoD(Substr(cTempoSat,1,8))
	cHoraSat	:= Transform(Substr(cTempoSat,9,6),"@R 99:99:99")
	dDate		:= Date()
	cTime		:= Time()
	
	If DTOC(dDataSat) <> DTOC(dDate)
		//"As datas estão diferentes entre o CAIXA e o equipamento SAT:" "Data do SAT: " "Data do CAIXA: "
		cMsg := STR0085 + CHR(10) + STR0086 + DTOC(dDataSat) + CHR(10) + STR0087 + DTOC(dDate) + CHR(10) + CHR(13) +;
		STR0193 + CHR(10) +; // "Não é possivel finalizar vendas ou cancelamentos com datas divergentes entre o aparelho SAT e o sistema operacional."
		STR0192 // "Ajuste as datas e refaça o processo."
		LjGrvLog( "SAT - LJSATCDataHora - 01", cMsg )
		lRet := .F. 
	ElseIf DTOC(dDataSat) <> DTOC(dDataBase) // Data Base do Protheus
		//"As datas estão diferentes entre o CAIXA e o equipamento SAT:" "Data do SAT: " "Data base da Estação: "
		cMsg := STR0085 + CHR(10) + STR0086 + DTOC(dDataSat) + CHR(10) + STR0190 + DTOC(dDataBase) + CHR(10) + CHR(13) +;
		STR0191 + CHR(10) +; // "Não é possivel finalizar vendas ou cancelamentos com datas divergentes entre o aparelho SAT e a estação."
		STR0192 // "Ajuste as datas e refaça o processo."
		LjGrvLog( "SAT - LJSATCDataHora - 02", cMsg )
		lRet := .F. 	
	EndIf
EndIf

If !Empty(AllTrim(cMsg))
	MsgStop(cMsg)
EndIf

Return lRet
 
//-------------------------------------------------------------------
/*/{Protheus.doc} LJSatGetSO
Busco as informações armazenadas no equipamento SAT sem uma nova requisição. 

@param		-
@author  	Varejo
@version 	P11.8
@since   	13/12/2016
@return	aSatSO	
/*/
//-------------------------------------------------------------------
Static Function LjSatGetSO()
LjVldSATSO()
Return aSatSO

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSatSetSO
Obtenho os dados armazenados no equipamento SAT. 

@param		-
@author  	Varejo
@version 	P11.8
@since   	13/12/2016
@return	aSATSO	
/*/
//-------------------------------------------------------------------
Static Function LjSatSetSO()
Local lPOS	:= STFIsPOS() //Pos?
Local cPass	:= "" // código de ativação do SAT

If lPOS
	cPass	:= STFGetStation("CODSAT",,.F.) 
Else
	cPass	:= IIF(LJGetStation("CODSAT",.F.) == Nil,"",LJGetStation("CODSAT",.F.))
Endif

LjGrvLog( "SAT - 01. LJSATSetSO", "Antes de executar o LJSATComando. " + Time(),  )
If LjAnalisaLeg(77)[1]
	If lIntegrador
		LjStatusOP()
	EndIf	
	aSATSO	:= LJSATComando({"12","ConsultarStatusOperacionalMFE",LJSATnSessao(),cPass})
Else
	aSATSO := LJSATComando({"12","ConsultarStatusOperacional",LJSATnSessao(),cPass })
EndIf
LjGrvLog( "SAT - 02. LJSATSetSO", "Apos de executar o LJSATComando. " + Time()+ " tamanho aSATSO: ", Len(aSATSO)  )

LjVldSATSO()

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LjVldSATSO
Validação do array aSATSO 

@param		-
@author  	julio.nery
@version 	P12
@since   	21/3/2017
@return		nil
/*/
//-------------------------------------------------------------------
Static Function LjVldSATSO()
Local cMsg	:= ""

If ValType(aSATSO) == "A"
	If !(Len(aSATSO) > 1)
		If Len(aSATSO) > 0 .And. ValType(aSATSO[1]) == "C"
			cMsg := aSATSO[1]
		EndIf
		
		If !Empty(cMsg)
			cMsg := "Retorno "+cSiglaSat+": " + CHR(13) + cMsg + Replicate(CHR(13),2)
		EndIf
		
		cMsg += "Acesso Negado ao ambiente, verifique as configurações/equipamento."
		STPosMSG( "ATENÇÃO!!" , cMsg, .T., .F., .F.)
		LjGrvLog("Finalização Sistema",cMsg)
		Final("Acesso Negado devido inconsistências do "+cSiglaSat+"")
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LjVldCGC
Validação de CNPJ / CPF válido 

@param		-
@author  	Varejo
@version 	P11.8
@since   	06/01/2017
@return	lRet	
/*/
//-------------------------------------------------------------------
Function LjVldCGC(cCgc)

Local lRet := .F.

// Se repetir todos os numeros informados o retorno sera invalido
If !( Repl(Substr(cCgc,1,1), If(Len(cCgc) == 11, 11, 14)) == cCgc )
	lRet := CGC(cCgc)	   
Endif

If !lRet
	LjGrvLog( "SAT", "CPF ou CNPJ informado inválido - cCgc", cCgc )
EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATHead
Retorna conteúdo do cabeçalho do comprovante SAT

@param		-
@author  	Varejo
@version 	P11.8
@since   	13/01/2017
@return	lRet	
/*/
//-------------------------------------------------------------------
Static Function LjSATHead(oExtratoSAT,oExtSATEnv,lParse,cCGC,cDocSat,lReimp)

Local cConteudo		:= ""										//conteudo a ser retornado
Local cLinha 		:= Replicate( "-" , nLarCup )				//linha
Local lPOS			:= STFIsPOS()								//Pos?
Local cNome			:= "" 										//Nome do estabelecimento
Local cLogradouro	:= "" 										//Logradouro
Local cNumero		:= "SN"										//Número
Local cBairro		:= "" 										//Bairro
Local cMunicipio	:= "" 										//Municipio
Local cUF			:= "" 										//UF
Local cCEP			:= "" 										//CEP
Local cCNPJ			:= "" 										//CNPJ do estabeleciomento
Local cIE			:= "" 										//Inscricao Estatual
Local cIM			:= "" 										//Inscricao Municipal
Local cTpAmb		:= "1"										//Tipo de Ambiente Produção (1) / Homologação (2) 
Local cNCFe			:= ""										//Numero do doc da venda 
Local cCpfCnpj		:= ""										//Cpf ou Cnpj informado na venda ]
Local lEndFis   	:= .F. 										//Se estiver como F refere-se ao endereço de Cobrança se estiver T  ao  endereço de Entrega.
Local aEndCob		:= {}										//Array com Logradouro[C], Numero[N], Numero[C] e Complemento[C] de Cobrança
Local aEndEnt		:= {}										//Array com Logradouro[C], Numero[N], Numero[C] e Complemento[C] de Entrega
Local aAreaSA1		:= {}
Local cRazaoSoc		:= ""										//Razão Social/Nome
Local cVerFirm		:= ""										//Versão do Firmware da Impressora Não Fiscal
Local lMVLJCOND		:= SuperGetMV("MV_LJCONDE",,.F.)			//Define se utilizar condensado ou não

Default oExtratoSAT	:= Nil										//Objeto do XML de retorno SAT
Default oExtSATEnv	:= Nil										//Objeto do XML de envio SAT
Default lParse		:= .F.										//Se conseguiu executar o parse no oExtratoSAT
Default cCGC		:= ""										//CPF ou CNPJ para ser informado no QRCODE
Default cDocSat		:= ""										//Doc SAT
Default lReimp		:= .F.										//Se Reimpressao

cUF := SM0->M0_ESTCOB
 																		 		
If !lPos
	cVerFirm := LjGetFrmw()
EndIf

If lParse .And. oExtratoSAT <> Nil
	cNome		:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/emit/xNome" )
	cLogradouro	:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/emit/enderEmit/xLgr" )
	cNumero		:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/emit/enderEmit/nro" )
	cBairro		:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/emit/enderEmit/xBairro" )
	cMunicipio	:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/emit/enderEmit/xMun" )
	cCEP		:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/emit/enderEmit/CEP" )
	cCNPJ		:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/emit/CNPJ" )
	cIE			:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/emit/IE" )
	cIM			:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/emit/IM" )
	cTpAmb		:= AllTrim(OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/ide/tpAmb" ))
	cNCFe		:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/ide/nCFe" )
	
	//Valida se foi informado o CPF ou CNPJ para venda
	If OEXTRATOSAT:XPathHasNode( "/CFe/infCFe/dest" )
	 	//CPF
		If OEXTRATOSAT:XPathHasNode( "/CFe/infCFe/dest/CPF" )
			cCpfCnpj := OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/dest/CPF" )
		//CNPJ	
		ElseIf OEXTRATOSAT:XPathHasNode( "/CFe/infCFe/dest/CNPJ" )
			cCpfCnpj := OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/dest/CNPJ" )
		EndIf
				
		aAreaSA1 := SA1->(GetArea())
		If AllTrim(cCpfCnpj) != AllTrim(SA1->A1_CGC)
			DbSelectArea("SA1")
			SA1->(DbSetOrder(3))	// A1_FILIAL+A1_CGC
			SA1->(DbSeek(xFilial("SA1") + cCpfCnpj))
		EndIf
		
		cRazaoSoc := AllTrim(SA1->A1_NOME)
		RestArea(aAreaSA1)
	EndIf
Else

	If ExistFunc("LjFiGetEnd")
		aEndEnt := LjFiGetEnd( SM0->M0_ENDENT, SM0->M0_ESTENT, .T. )
		aEndCob := LjFiGetEnd( SM0->M0_ENDCOB, SM0->M0_ESTCOB, .T. )
	Else
		aEndEnt := FisGetEnd( SM0->M0_ENDENT, SM0->M0_ESTENT )
		aEndCob := FisGetEnd( SM0->M0_ENDCOB, SM0->M0_ESTCOB )
	EndIf
	
	lEndFis 	:= SuperGetMV("MV_SPEDEND",.F.)
	cNome		:= AllTrim(SM0->M0_NOMECOM)
	cLogradouro	:= Left( AllTrim( IIF(!lEndFis,aEndCob[1],aEndEnt[1]) ), 60 )
	
	//tratamento para o Numero
	If lEndFis .AND. aEndEnt[2] <> 0
		cNumero := AllTrim( aEndEnt[3] )
	ElseIf aEndCob[2] <> 0
		cNumero := AllTrim( aEndCob[3] )
	EndIf 
	
	cBairro		:= AllTrim( IIF(!lEndFis,SM0->M0_BAIRCOB,SM0->M0_BAIRENT) )
	cMunicipio	:= AllTrim( IIF(!lEndFis,SM0->M0_CIDCOB,SM0->M0_CIDENT) )
	cCEP		:= AllTrim( IIF(!lEndFis,SM0->M0_CEPCOB,SM0->M0_CEPENT) )
	cCNPJ		:= AllTrim( SM0->M0_CGC )
	cIE			:= AllTrim( SM0->M0_INSC )
	cIM			:= AllTrim( SM0->M0_INSCM )
	
	If lPos .And. !lReimp
		cNCFe		:= AllTrim( STDGPBasket("SL1","L1_DOC") )
		cCpfCnpj	:= AllTrim( STDGPBasket("SL1","L1_CGCCLI") )
	Else
		cNCFe		:= AllTrim( SL1->L1_DOC )
		cCpfCnpj	:= AllTrim( SL1->L1_CGCCLI )
	EndIf	
EndIf

cDocSat := cNCFe


If nEnvEmail == 0

	cConteudo += cCondIni + PADC(cNome, nLarCup) + cCondFim + Chr(10)	//Nome do estabelecimento
	cConteudo += cCondIni + PADC(cLogradouro + ", " + cNumero + " - "	+ cBairro, nLarCup) + cCondFim + Chr(10)	//Logradouro, Número, Bairro
	cConteudo += cCondIni + PADC(cMunicipio + " - "	+ cUF + " - "	+ "CEP:" + cCEP, nLarCup) + cCondFim + Chr(10)	//Município, UF, CEP
	cConteudo += cCondIni + PADC("CNPJ:" + cCNPJ + Space(1)	+ "IE:" + cIE + Space(1)	+ "IM:" + cIM, nLarCup) + cCondFim + Chr(10)	//CNPJ, IE e IM do estabelecimento
	cConteudo += cCondIni + cLinha + cCondFim + Chr(10)

	If cTpAmb == "2"
		cConteudo += cCondIni + Replicate("*",nLarCup) + cCondFim + Chr(10)
		cConteudo += cCondIni + "IMPRESSO EM AMBIENTE DE TESTE" + cCondFim + Chr(10) 
		cConteudo += cCondIni + Replicate("*",nLarCup) + cCondFim + Chr(10)
	EndIf		

	If lMVLJCOND .And. cVerFirm >= "03.20.04"
		cConteudo += cCondIni + TAG_NEGRITO_INI + PADC("Extrato No." + cNCFe + " DO CUPOM FISCAL ELETRONICO - SAT", nLarCup) + TAG_NEGRITO_FIM + cCondFim + Chr(10)  //Número da venda
	Else
		cConteudo += cCondIni + TAG_NEGRITO_INI + PADC("Extrato No." + cNCFe, nLarCup) + TAG_NEGRITO_FIM + cCondFim + Chr(10) //Número da venda
		cConteudo += cCondIni + TAG_NEGRITO_INI + PADC("CUPOM FISCAL ELETRONICO - SAT", nLarCup) + TAG_NEGRITO_FIM + cCondFim + Chr(10) //mensagem obrigatória
	EndIf
	cConteudo += cCondIni + cLinha + cCondFim +  Chr(10)

	If !Empty(cCpfCnpj)
		cConteudo += cCondIni + PADC("CPF/CNPJ do Consumidor: " + cCpfCnpj, nLarCup) + cCondFim + Chr(10)
		cConteudo += cCondIni + PADC("Razão Social/Nome: " + cRazaoSoc, nLarCup) + cCondFim +  Chr(10)
		cCGC := cCpfCnpj
	Else
		cConteudo += cCondIni + PADC("CPF/CNPJ do Consumidor: Nao identificado", nLarCup) + cCondFim + Chr(10)	
		cConteudo += cCondIni + PADC("Razão Social/Nome: Nao identificado", nLarCup) + cCondFim +  Chr(10)
	EndIf	

ElseIf nEnvEmail == 1

	cConteudo := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
	cConteudo += '<html xmlns="http://www.w3.org/1999/xhtml">'
	cConteudo += '<head>'
	cConteudo += '<meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">'
	cConteudo += "<link href='https://fonts.googleapis.com/css?family=Libre Barcode 128' rel='stylesheet'>"
	cConteudo += '<style>'
	cConteudo += "code128 { font-family: 'Libre Barcode 128';font-size: 50px; }"
	cConteudo += '</style>'
	cConteudo += '<title>' + "Comprovante SAT - " + cDocSat + '</title>'
	cConteudo += '<meta name="viewport" content="width=device-width, initial-scale=1.0"/>'
	cConteudo += '</head>'
	cConteudo += '<body>'
	cConteudo += '<table align="center" style="background-color: #ffff99">'
	cConteudo += '<caption align="center" style="background-color: #ffff99">'
	cConteudo += cNome + '</br>'
	cConteudo += cLogradouro + ", " + cNumero + " - "	+ cBairro + '</br>'      
	cConteudo += cMunicipio + " - "	+ cUF + " - " + "CEP:" + cCEP + '</br>'
	cConteudo += "CNPJ:" + cCNPJ + Space(1)	+ "IE:" + cIE + Space(1) + "IM:" + cIM	
	cConteudo += '<hr/>'
	cConteudo += '</caption>'

EndIf

Return cConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATItem
Retorna conteúdo dos itens da venda do comprovante SAT

@param		-
@author  	Varejo
@version 	P11.8
@since   	13/01/2017
@return	lRet	
/*/
//-------------------------------------------------------------------
Static Function LjSATItem(oExtratoSAT,oExtSATEnv,lParse,nTotalBruto,nTotal)

Local cConteudo 	:= ""															//conteudo a ser retornado
Local cLinha 		:= Replicate( "-" , nLarCup )									//linha
Local cXPath		:= ""															//caminho para validacao do produto
Local cTxtDescIt	:= "desconto sobre item"										//descricao quando houver desconto no item
Local nElemento		:= 0 															//contador
Local aPrintItem	:= {}															//impressão dos itens
Local lLjPrintIt	:= lIsPOS <> NIL .AND. lIsPOS .AND. ExistFunc("LjPrintIt")					//define se utilizar condensado ou não (somente Venda Assistida, nao foi homolocado para TotvsPDV pois não utiliza o fonte LOJA701D)
Local aColunasIt	:= IIF(lLjPrintIt .AND. ExistFunc("LjDefColun"),LjDefColun( nLarCup ),{})	//Definicao das colunas para impressao dos itens da venda
Local cAcresSub		:= ""															//Acressimo no Subtotal
Local cDescSub		:= ""															//Desconto no Subtotal
Local cTotal		:= ""															//Total
Local aItem			:= ""															//Array dos produtos
Local aPrintDesc	:= {}															//Array dos descontos dos produtos
Local nI			:= 0															//Contador
Local cVlrProd		:= ""															//Valor total do produto
Local nDescont		:= 0															//Desconto no produto
Local cDescrPro		:= "" 															//Descrição do produto
Local cLinhaItem	:= ""
Local nPosDesc		:= 0

Default oExtratoSAT	:= Nil															//objeto do XML de retorno SAT
Default oExtSATEnv	:= Nil															//objeto do XML de envio SAT
Default lParse		:= .F.															//se conseguiu executar o parse no oExtratoSAT
Default nTotalBruto	:= 0															//somatorio do total da venda
Default nTotal		:= 0															//Somatória Total

If !lParse 
	oExtratoSAT := oExtSATEnv
EndIf

If oExtratoSAT <> Nil
	//Produtos
	While .T.
		nElemento ++
		
		cXPath := "/CFe/infCFe/det[" + cValToChar(nElemento) + "]"
		
		If OEXTRATOSAT:XPathHasNode( cXPath )
			
			If lParse //quando ocorre erro de parse, valor total da venda nao existe no XML de envio
				cVlrProd := OEXTRATOSAT:XPathGetNodeValue( cXPath + "/prod/vProd" )
			Else
				cVlrProd := Str(Val(OEXTRATOSAT:XPathGetNodeValue( cXPath + "/prod/vUnCom" )) * Val(OEXTRATOSAT:XPathGetNodeValue( cXPath + "/prod/qCom" )))
			EndIf
			
			nTotal += Val(cVlrProd)
			
			aItem := {;
							STRZERO(nElemento,3,0)														,;
							OEXTRATOSAT:XPathGetNodeValue( cXPath + "/prod/cProd" )						,;
							OEXTRATOSAT:XPathGetNodeValue( cXPath + "/prod/xProd" ) 					,;
							AllTrim(Str(Val(OEXTRATOSAT:XPathGetNodeValue( cXPath + "/prod/qCom" ))))	,;
							OEXTRATOSAT:XPathGetNodeValue( cXPath + "/prod/uCom" )						,;
							"x"																			,;
							OEXTRATOSAT:XPathGetNodeValue( cXPath + "/prod/vUnCom" )					,;
							cVlrProd																	;
					  }
			aAdd(aPrintItem,aItem)
			
			If OEXTRATOSAT:XPathHasNode( cXPath + "/prod/vDesc" )
				aAdd(aPrintDesc,{OEXTRATOSAT:XPathGetNodeValue( cXPath + "/prod/vDesc" )})
				nTotal := nTotal - Val(OEXTRATOSAT:XPathGetNodeValue( cXPath + "/prod/vDesc" ))
			Else
				aAdd(aPrintDesc,{"0"})	 
			EndIf
		Else
			nElemento := 0
			Exit	
		EndIf
	EndDo
	
	If OEXTRATOSAT:XPathHasNode( "/CFe/infCFe/total/DescAcrEntr" )
		If OEXTRATOSAT:XPathHasNode( "/CFe/infCFe/total/DescAcrEntr/vAcresSubtot" )
			cAcresSub	:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/total/DescAcrEntr/vAcresSubtot" )
			nTotal := nTotal + Val(cAcresSub)
		EndIf
		
		If OEXTRATOSAT:XPathHasNode( "/CFe/infCFe/total/DescAcrEntr/vDescSubtot" )
			cDescSub	:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/total/DescAcrEntr/vDescSubtot" )
			nTotal := nTotal - Val(cDescSub)
		EndIf
	EndIf
	
	If lParse	//quando ocorre erro de parse, valor do troco nao existe no XML de envio															
		cTotal := OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/total/vCFe" )
	Else
		cTotal := Str(nTotal)
	EndIf	
EndIf

If nEnvEmail == 0

	cConteudo += cCondIni + cLinha + cCondFim + Chr(10)
	cConteudo += cCondIni + TAG_NEGRITO_INI + "#| COD | DESC" + PADL(" | QTD | UN | VL UN R$ |VL ITEM R$", nLarCup - Len("#| COD | DESC")) + TAG_NEGRITO_FIM + cCondFim + Chr(10)  //cabeçalho informaçoes dos produtos a serem vendidos
	cConteudo += cCondIni + cLinha + cCondFim + Chr(10)

	For nI := 1 to Len( aPrintItem )
		nDescont := 0
		If Len(aColunasIt) > 0 .And. lLjPrintIt	//modelo não homologado/utilizado para Totvs PDV pois não possui o fonte LOJA701D 
			cConteudo += LjPrintIt( aColunasIt[1], aColunasIt[2], aColunasIt[3], aPrintItem[nI], nLarCup, cCondIni, cCondFim )
		Else
			cLinhaItem := PADR(aPrintItem[nI][1],3)  + SPACE(1) + ;			// Sequencia
						PADR(aPrintItem[nI][2],15) + SPACE(1)				// Descricao

			nPosDesc	:= nLarCup-Len(cLinhaItem)
			cDescrPro	:= aPrintItem[nI][3]	
			cLinhaItem 	+= Substr(cDescrPro,1,nPosDesc)
			cLinhaItem 	:= cCondIni + cLinhaItem + cCondFim
			cDescrPro 	:= Substr(cDescrPro,nPosDesc+1,Len(cDescrPro))
			
			While !Empty(cDescrPro)  //verifica capacidade para a descrição do item e caso não comporte, utiliza demais linhas para manter a integridade da descrição
				cLinhaItem 	+= cCondIni + Chr(10) + Substr(cDescrPro,1,nLarCup) + cCondFim
				cDescrPro 	:= Substr(cDescrPro,nLarCup+1,Len(cDescrPro))	
			EndDo		
			
			cConteudo += cLinhaItem + Chr(10) 
			cConteudo += cCondIni + PADR(PADL(VAL(aPrintItem[nI][4]),5) + ;						// Quantidade
						PADL(aPrintItem[nI][5],3) + SPACE(1) + aPrintItem[nI][6] + SPACE(1) +;	// Unidade
						PADR(aPrintItem[nI][7],7) + SPACE(6) + ;								// Valor unitário            
						PADL(aPrintItem[nI][8],nLarCup-24),nLarCup) + cCondFim 					// Valor Item		
			cConteudo += Chr(10)
		EndIf
		//Desconto no item
		If Val(aPrintDesc[nI][1]) > 0
			cConteudo += cCondIni + cTxtDescIt + PADL("-" + aPrintDesc[nI][1],nLarCup - Len(cTxtDescIt)) + cCondFim + Chr(10)
			nDescont := Val(aPrintDesc[nI][1])
		EndIf	
		nTotalBruto += (VAL(aPrintItem[nI][7]) * VAL(aPrintItem[nI][4])) - nDescont//acumulador
	Next

	cConteudo += Chr(10)

	If !Empty(cAcresSub) .Or. !Empty(cDescSub)
		//SubTotal 
		cConteudo += cCondIni + "SUBTOTAL" + PADL(Transform(nTotalBruto,'@E 999,999.99'),nLarCup - Len("SUBTOTAL")) + cCondFim + Chr(10)
		//Acréscimo
		If !Empty(cAcresSub)
			cConteudo += cCondIni + "ACRESCIMO" + PADL(Transform(Val(cAcresSub),'@E 999,999.99'),nLarCup - Len("ACRESCIMO")) + cCondFim + Chr(10)
		EndIf
		//Desconto
		If !Empty(cDescSub)
			cConteudo += cCondIni + "DESCONTO" + PADL(Transform(Val(cDescSub),'@E 999,999.99'),nLarCup - Len("DESCONTO")) + cCondFim + Chr(10)
		EndIf
	EndIf
	//TOTAL
	cConteudo += cCondIni + "TOTAL R$" + PADL(Transform(Val(cTotal),'@E 999,999.99'),nLarCup - Len("TOTAL R$")) + cCondFim + Chr(10)

ElseIf nEnvEmail == 1

	//Cabeçalho
	cConteudo += '<tr>'
	cConteudo += '	<td><b>Codigo</b></td>'
	cConteudo += '	<td><b>Descricao</b></td>'
	cConteudo += '	<td><b>Qtd</b></td>'
	cConteudo += '	<td><b>UN</b></td>'
	cConteudo += '	<td><b>VlUnit</b></td>'
	cConteudo += '	<td><b>VlTotal</b></td>'
	cConteudo += '</tr>'
	
	//Itens da Venda
	For nI := 1 to Len( aPrintItem )
		nDescont := 0

		cConteudo += '<tr>' + '<td>' + aPrintItem[nI][1] + '</td>'					// Codigo
		cConteudo += '<td>' + aPrintItem[nI][2] + '</td>'							// Decricao
		cConteudo += '<td align="center">' + aPrintItem[nI][4] + '</td>'			// Quantidade
		cConteudo += '<td align="center">' + aPrintItem[nI][5] + '</td>'			// Unidade
		cConteudo += '<td align="center">' + aPrintItem[nI][7] + '</td>'			// Valor unitário
		cConteudo += '<td align="right">' + aPrintItem[nI][8] + '</td>' + '</tr>'	// Valor Item
	
		//Desconto no item
		If Val(aPrintDesc[nI][1]) > 0
			cConteudo += '<tr>' + '<td>' + cTxtDescIt + '</td>'
			cConteudo += '<td></td>' + '<td></td>'
			cConteudo += '<td></td>' + '<td></td>'
			cConteudo += '<td align="right">' + "-" + aPrintDesc[nI][1] + '</td>'
			nDescont := Val(aPrintDesc[nI][1])
		EndIf	
		nTotalBruto += (VAL(aPrintItem[nI][7]) * VAL(aPrintItem[nI][4])) - nDescont	// Acumulador
	Next

	If !Empty(cAcresSub) .Or. !Empty(cDescSub)
		//SubTotal 
		cConteudo += '<tr>' + '<td align="left" colspan=”4">SUBTOTAL</td>'
		cConteudo += '<td></td>' + '<td></td>'
		cConteudo += '<td></td>' + '<td></td>'
		cConteudo += '<td align="right">' + Transform(nTotalBruto,'@E 999,999.99') + '</td>'
		cConteudo += '</tr>'

		//Acréscimo
		If !Empty(cAcresSub)
			cConteudo += '<tr>' + '<td align="left" colspan=”4">ACRESCIMO</td>'
			cConteudo += '<td></td>' + '<td></td>'
			cConteudo += '<td></td>' + '<td></td>'
			cConteudo += '<td align="right">' + Transform(Val(cAcresSub),'@E 999,999.99') + '</td>'
			cConteudo += '</tr>'
		EndIf

		//Desconto
		If !Empty(cDescSub)
			cConteudo += '<tr>' + '<td align="left" colspan=”4">DESCONTO</td>'
			cConteudo += '<td></td>' + '<td></td>'
			cConteudo += '<td></td>' + '<td></td>'
			cConteudo += '<td align="right">' + Transform(Val(cDescSub),'@E 999,999.99') + '</td>'
			cConteudo += '</tr>'
		EndIf
	EndIf
	
	//TOTAL
	cConteudo += '<tr>' + '<td align="left" colspan=”4? >TOTAL R$</td>'
	cConteudo += '<td></td>' + '<td></td>'
	cConteudo += '<td></td>' + '<td></td>'
	cConteudo += '<td align="right">' + Transform(Val(cTotal),'@E 999,999.99') + '</td>'
	cConteudo += '</tr>'
EndIf

Return cConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATPag
Retorna conteúdo do pagamento do comprovante SAT

@param		-
@author  	Varejo
@version 	P11.8
@since   	13/01/2017
@return	lRet	
/*/
//-------------------------------------------------------------------
Static Function LjSATPag(oExtratoSAT,oExtSATEnv,lParse,nTotal)

Local cConteudo		:= ""										//conteudo a ser retornado
Local cMeioPag		:= ""										//descrição meio de pagamento
Local cXPath		:= ""										//caminho para validacao do produto
Local nFormPgto		:= 0										//contador
Local nTotPgto		:= 0										//Somatória dos pagamentos
Local nTroco		:= 0										//Troco

Default oExtratoSAT	:= Nil										//objeto do XML de retorno SAT
Default oExtSATEnv	:= Nil										//objeto do XML de envio SAT
Default lParse		:= .F.										//se conseguiu executar o parse no oExtratoSAT
Default nTotal		:= 0										//Somatória Total

If !lParse
	oExtratoSAT := oExtSATEnv
EndIf

If oExtratoSAT <> Nil

	//FORMA PAGAMENTO
	While .T.
		nFormPgto ++
		
		cXPath := "/CFe/infCFe/pgto/MP[" + cValToChar(nFormPgto) + "]"
		
		If OEXTRATOSAT:XPathHasNode( cXPath )
			cMeioPag := UPPER(LojSATMeioPag( OEXTRATOSAT:XPathGetNodeValue( cXPath + "/cMP" )))
			If nEnvEmail == 0
				cConteudo += cCondIni + cMeioPag + PADL(Transform(Val(OEXTRATOSAT:XPathGetNodeValue( cXPath + "/vMP" )),'@E 999,999.99'),nLarCup - Len(cMeioPag)) + cCondFim + Chr(10)
			ElseIf nEnvEmail == 1
				cConteudo += '<tr>'
				cConteudo += '<td>' + cMeioPag + '</td>'
				cConteudo += '<td></td>' + '<td></td>'
				cConteudo += '<td></td>' + '<td></td>'
				cConteudo += '<td align="right">' + Transform(Val(OEXTRATOSAT:XPathGetNodeValue( cXPath + "/vMP" )),'@E 999,999.99') + '</td>'
				cConteudo += '</tr>'
			EndIf
			nTotPgto += Val(OEXTRATOSAT:XPathGetNodeValue( cXPath + "/vMP" ))
		Else
			nFormPgto := 0
			Exit
		EndIf
	EndDo
	
	//TROCO 
	If OEXTRATOSAT:XPathHasNode( "/CFe/infCFe/pgto/vTroco" )
		nTroco := Val(OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/pgto/vTroco" ))
	Else
		nTroco := nTotPgto - nTotal
	EndIf
	
	If nEnvEmail == 0
		cConteudo += cCondIni + "TROCO R$" + PADL(Transform(nTroco,'@E 999,999.99'),nLarCup - Len("TROCO R$")) + cCondFim + Chr(10)		
	ElseIf nEnvEmail == 1
		cConteudo += '<tr>'
		cConteudo += '<td>TROCO R$</td>'
		cConteudo += '<td></td>' + '<td></td>'
		cConteudo += '<td></td>' + '<td></td>'
		cConteudo += '<td align="right">' + Transform(nTroco,'@E 999,999.99') + '</td>'
		cConteudo += '</tr>'
		cConteudo += '<tr>' + '<td colspan="6"><hr/></td>' + '</tr>'
	EndIf
EndIf
	
Return cConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATObsCont
Retorna conteúdo da observação do contribuinte do comprovante SAT

@param		-
@author  	Varejo
@version 	P11.8
@since   	13/01/2017
@return	lRet	
/*/
//-------------------------------------------------------------------
Static Function LjSATObsCont()

Local cConteudo		:= ""												//conteudo a ser retornado
Local cLinha 		:= Replicate( "-" , nLarCup ) 
Local lLjSimpNac 	:= SuperGetMV("MV_LJSIMPN",,.F.) 				//verifica se a empresa e optante do Simples Nacional
Local lImpEntTrb 	:= SuperGetMv("MV_ENTETRB",.F.,.F.) 			//verifica se esta apto a utilizar a Nova Lei da Transparencia 
Local lPOS 			:= STFIsPOS()		//Pos?
Local lLj7085		:= ExistBlock("LJ7085")          				//indica se o ponto de entrada está compilado
Local cMensagem		:= SuperGetMV("MV_LJFISMS",, "") 				//Mensagem personalizada 
Local aInfAdic		:= {}												//Informações adicionais do contribuinte
Local nGrupos		:= 0												//Quantiade de grupos de informações adicionais
Local nTamVar		:= 0												//Tamanho da variavel de retorno
Local n1			:= 0												//Contador

If nEnvEmail == 0
	//Simples Nacional
	If lLjSimpNac
		LjGrvLog("SAT","Utiliza Simples Nacional")
		cConteudo += Chr(10)
		cConteudo += cCondIni + PADR("ICMS a ser recolhido conforme LC 123/2006 ", nLarCup ) + cCondFim + Chr(10)
		cConteudo += cCondIni + PADR("Simples Nacional", nLarCup ) + cCondFim + Chr(10)
	EndIf	

	cConteudo += cCondIni + cLinha + cCondFim + Chr(10)

	cConteudo += cCondIni + PADR("OBSERVACOES DO CONTRIBUINTE", nLarCup) + cCondFim + Chr(10)

	If lPos
		cConteudo += cCondIni + PADR("CX: " + ALLTRIM(SLI->LI_ESTACAO) + "  OP: " + ALLTRIM(SLI->LI_USUARIO), nLarCup) + cCondFim + Chr(10)
	Else
		cConteudo += cCondIni + PADR("CX: " + ALLTRIM(xNumCaixa()) + "  OP: " + ALLTRIM(cUserName), nLarCup) + cCondFim + Chr(10)
	EndIf
ElseIf nEnvEmail == 1
	//Simples Nacional
	If lLjSimpNac
		LjGrvLog("SAT","Utiliza Simples Nacional")
		cConteudo += '<tr>' + '<td colspan="6">' + "ICMS a ser recolhido conforme LC 123/2006" + '</td>' + '</tr>'
		cConteudo += '<tr>' + '<td colspan="6">' + "Simples Nacional" + '</td>' + '</tr>'
	EndIf
	
	cConteudo += '<tr>' + '<td colspan="6">' + "OBSERVACOES DO CONTRIBUINTE" + '</td>' + '</tr>'

	If lPos
		cConteudo += '<tr>' + '<td colspan="6">' + "CX: " + ALLTRIM(SLI->LI_ESTACAO) + "  OP: " + ALLTRIM(SLI->LI_USUARIO) + '</td>' + '</tr>'
	Else
		cConteudo += '<tr>' + '<td colspan="6">' + "CX: " + ALLTRIM(xNumCaixa()) + "  OP: " + ALLTRIM(cUserName) + '</td>' + '</tr>'
	EndIf
EndIF

//Informação adicional nas Observações do Contribuinte
If lLj7085
	LjGrvLog("SAT","Adiciona mensagem de acordo com o ponto de entrada LJ7085")
	LjGrvLog("SAT","Antes da Chamada do Ponto de Entrada:LJ7085",aInfAdic)
	aInfAdic := ExecBlock( "LJ7085", .F., .F. )
	LjGrvLog("SAT","Apos a Chamada do Ponto de Entrada:LJ7085", aInfAdic)
	If ValType(aInfAdic) <> "A"
		aInfAdic := {}
	EndIf
Else
	//macro-executa o parametro MV_LJFISMS
	If Substr(cMensagem,1,1)=="&"
		LjGrvLog("SAT","Adiciona mensagem de acordo com o parametro MV_LJFISMS")
		cMensagem := &( Substr(cMensagem,2,Len(cMensagem)) )
	EndIf
	cMensagem := AllTrim(cMensagem)

	//se o parametro tiver vazio, verifica a mensagem do campo LG_MSGCUP do Cadastro de Estacao
	If Empty(cMensagem)
		LjGrvLog("SAT","Adiciona mensagem de acordo com o campo do cadastro de estacao LG_MSGCUP")
		cMensagem := LJGetStation("LG_MSGCUP",.F.)
	EndIf

	If !Empty(cMensagem)
		aInfAdic := { {Nil, cMensagem} }
	EndIf
	
EndIf

//os grupos são: infAdic / obsCont / obsFisco / procRef
nGrupos := Len(aInfAdic)
If nGrupos > 0 .AND. nGrupos <= 4
	For n1 := 1 to nGrupos
		If n1 == 1
			If ValType(aInfAdic[1][2]) == "C"
				nTamVar := Len( aInfAdic[1][2] )
				//tamanho maximo para a tag infCpl
				If nTamVar > 1 .AND. nTamVar <= 5000
					cMensagem :=	aInfAdic[1][2]
				EndIf
			Else
				Loop
			EndIf
		EndIf
	Next			
EndIf	

If nEnvEmail == 0

	If !Empty(cMensagem)
		cConteudo += cCondIni + cMensagem + cCondFim +  Chr(10)
	EndIf

	/*
		Lei da transparencia
	*/
	If lImpEntTrb .AND. ExistFunc("Lj950ImpNC")
		cConteudo += Chr(10)  
		
		If Len(aSATImp) == 0
			LjCreaImpSat()
		EndIf	
		
		cConteudo += cCondIni + Lj950ImpNC(LjFindImpSat("TOTVLRNCM"),LjFindImpSat("TOTIMPNCM"),2,/*NFC-E*/,LjFindImpSat("TOTFED"),LjFindImpSat("TOTEST"),LjFindImpSat("TOTMUN")) + cCondFim + Chr(10)
		
	EndIf	

	cConteudo += cCondIni + cLinha + cCondFim + Chr(10) 

ElseIf nEnvEmail == 1
	
	If !Empty(cMensagem)
		cConteudo += '<tr>' + '<td colspan="6">' + cMensagem + '</td>' + '</tr>'
	EndIf

	// Lei da transparencia
	If lImpEntTrb .AND. ExistFunc("Lj950ImpNC")
		If Len(aSATImp) == 0
			LjCreaImpSat()
		EndIf	
		
		cConteudo += '<tr>' + '<td colspan="6">' + Lj950ImpNC(LjFindImpSat("TOTVLRNCM"),LjFindImpSat("TOTIMPNCM"),2,/*NFC-E*/,LjFindImpSat("TOTFED"),LjFindImpSat("TOTEST"),LjFindImpSat("TOTMUN")) + '</td>' + '</tr>'
	EndIf	

	cConteudo += '<tr>' + '<td colspan="6"><hr/></td>' + '</tr>'
EndIf

Return cConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATFooter
Retorna conteúdo da rodapé do comprovante SAT

@param		-
@author  	Varejo
@version 	P11.8
@since   	13/01/2017
@return	lRet	
/*/
//-------------------------------------------------------------------
Static Function LjSATFooter(oExtratoSAT	, oExtSATEnv	, lParse	, cCGC		,;
							nTotal		, aSATDoc		, cSerieSat	, lReimp	)

Local cConteudo		:= ""															//Conteudo a ser retornado
Local cSerieEqp		:= ""															//Serie do equipamento sat
Local cHora			:= ""															//Hora da venda
Local cData			:= ""															//Data da venda
Local lPOS 			:= STFIsPOS()													//Pos?
Local cModelo		:= IIF(lPOS,STFGetStation("IMPFISC"),LjGetStation("IMPFISC"))	//Modelo da impressora configurada
Local cKeyQrCode	:= ""															//QrCode do SAT
Local cChvDoc		:= ""															//Chave da venda do SAT
Local cTotal		:= ""															//Total
Local cAssQRCODE	:= ""															//Assinatura QRCODE
Local cDataEmi		:= ""															//Data de Emissão
Local cHoraEmi		:= ""															//Hora de Emissão
Local cMsgApp		:= LjSatMgApp()
Local cQuebraLn		:= IIf('DARUMA' $ cModelo , CHR(10), "")
Local cVerFirm		:= ""															//Versão do Firmware da Impressora Não Fiscal
Local lMVLJCOND		:= SuperGetMV("MV_LJCONDE",,.F.)								//Define se utilizar condensado ou não
Local lReduzido		:= .F.															//Define se utiliza o novo cupom reduzido

Default oExtratoSAT	:= Nil		//objeto do XML de retorno SAT
Default oExtSATEnv	:= Nil		//objeto do XML de envio SAT
Default lParse		:= .F.		//se conseguiu executar o parse no oExtratoSAT
Default cCGC		:= ""		//CPF ou CNPJ para ser informado no QRCODE
Default nTotal		:= 0		//Somatória Total
Default aSATDoc		:= {}		//Retorno das informaçoes do equipamento
Default cSerieSat	:= ""		//Serie Equipamento
Default lReimp		:= .F.		//Se Reimpressão

If !lPos
	cVerFirm := LjGetFrmw()
EndIf

If lMVLJCOND .And. cVerFirm >= "03.20.04"
	lReduzido := .T.
Else
	lReduzido := .F.
EndIf

If lParse .And. oExtratoSAT <> Nil
	cSerieEqp	:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/ide/nserieSAT" )
	cDataEmi	:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/ide/dEmi" )
	cHoraEmi	:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/ide/hEmi" )
	cChvDoc		:= SubStr(OEXTRATOSAT:XPathGetAtt( "/CFe/infCFe", "Id" ),4)
	cTotal		:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/total/vCFe" )
	cAssQRCODE	:= OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/ide/assinaturaQRCODE" )
Else
	If lPos .And. !lReimp
		cSerieEqp	:= STDGPBasket("SL1","L1_SERSAT")
		cDataEmi	:= DToS(STDGPBasket("SL1","L1_EMISSAO"))
		cHoraEmi	:= StrTran( STDGPBasket("SL1","L1_HORA"), ":", "" ) 
		cChvDoc		:= STDGPBasket("SL1","L1_KEYNFCE")
	Else
		cSerieEqp	:= SL1->L1_SERSAT		 
		cDataEmi	:= DToS(SL1->L1_EMISSAO)
		cHoraEmi	:= StrTran( SL1->L1_HORA, ":", "" )		
		cChvDoc		:= SL1->L1_KEYNFCE
	EndIf
	cTotal		:= AllTrim(Str(nTotal))
	cAssQRCODE	:= IIF( Len(aSATDoc) > 3,aSATDoc[4],"" )
EndIF

cSerieSat := cSerieEqp 

cHora 	:= SUBSTR(cHoraEmi,1,2) + ":" +  SUBSTR(cHoraEmi, 3, 2)
cData 	:= SUBSTR(cDataEmi, 7, 8) +"/"+ SUBSTR(cDataEmi, 5,2) + "/" + SUBSTR(cDataEmi, 3,2)

If nEnvEmail == 0

	If !lReduzido
		cConteudo += cCondIni + PADC("SAT No. " + cSerieEqp, nLarCup) + cCondFim + Chr(10) 		//Número de série
		cConteudo += cCondIni + PADC(cData + "  -  "  + cHora, nLarCup) + cCondFim + Chr(10) 	//Data venda
	EndIf

	cConteudo += cCondIni
	cConteudo += TAG_NEGRITO_INI

	//Id Venda
	If !Empty(cCondIni)
		cConteudo += PADC(Transform(cChvDoc, "@R 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"), nLarCup)
	Else
		cConteudo += PADC(cChvDoc, nLarCup)
	EndIf
	cConteudo += TAG_NEGRITO_FIM
	cConteudo += cCondFim + CHR(10)

	//Codigo de Barras
	If lReduzido
		cConteudo += TAG_CENTER_INI + TAG_COD128_INI + ALLTRIM(SUBSTR(cChvDoc,1,44)) + TAG_COD128_FIM + TAG_CENTER_FIM + Chr(10) 
	Else
		cConteudo += TAG_CENTER_INI + TAG_COD128_INI + ALLTRIM(SUBSTR(cChvDoc,1,22)) + TAG_COD128_FIM + TAG_CENTER_FIM + Chr(10) 
		cConteudo += TAG_CENTER_INI + TAG_COD128_INI + ALLTRIM(SUBSTR(cChvDoc,23,44)) + TAG_COD128_FIM + TAG_CENTER_FIM + Chr(10)
	EndIf

	//QrCode
	cKeyQrCode := cChvDoc + "|" 					// Chave Consulta
	cKeyQrCode += cDataEmi + cHoraEmi + "|" 		// Data e Hora
	cKeyQrCode += cTotal + "|" 						// Valor Total do CFe-SAT
	cKeyQrCode += IIF(!Empty(cCGC),cCGC,"") + "|" 	// CNPJ adquirente (se existir) (sem ponuações)
	cKeyQrCode += cAssQRCODE 						// Assinatura QRCODE	

	//Cupom não reduzido deve centraliza o QrCode
	If !lReduzido
		cConteudo += TAG_CENTER_INI
	EndIf

	cConteudo += TAG_QRCODE_INI + cKeyQrCode

	//Ajuste do Tamanho do QrCode
	If ExistFunc("INFTamQrCd")
		cConteudo += INFTamQrCd(cModelo,"SAT")
	Else
		If 'DARUMA' $ cModelo 
			cConteudo += TAG_LMODULO_INI + "4" + TAG_LMODULO_FIM
		EndIf
	EndIf

	If lReduzido
		cConteudo += "<txtl>"
		cConteudo += "<l></l>" + cCondIni + PADC("SAT No. " + cSerieEqp, 22) + cCondFim					//Número de série
		cConteudo += "<l></l>" + cCondIni + PADC(cData + "  -  "  + cHora, 22) + cCondFim + "<l></l>"	//Data venda
		cConteudo += "<l></l>" + cCondIni + cMsgApp + cCondFim
		cConteudo += "</txtl>"
		cConteudo += TAG_QRCODE_FIM + CHR(10)
	Else
		cConteudo += TAG_QRCODE_FIM + TAG_CENTER_FIM + CHR(10)
		cConteudo += TAG_CENTER_INI + cCondIni + TAG_NEGRITO_INI + cMsgApp + TAG_NEGRITO_FIM + cCondFim + TAG_CENTER_FIM + cQuebraLn
	EndIf

	If 'DARUMA' $ cModelo
		cConteudo += "<sl>2</sl>" 
	EndIf

ElseIf nEnvEmail == 1
	
	cConteudo += '<tr>' + '<td colspan="6" align="center">' + "SAT No. " + cSerieEqp + '</td>' + '</tr>'	//Número de série
	cConteudo += '<tr>' + '<td colspan="6" align="center">' + cData + "  -  "  + cHora + '</td>' + '</tr>'	//Data venda

	//Id Venda
	cConteudo += '<tr>' + '<td colspan="6" align="center">' + Transform(cChvDoc, "@R 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999") + '</td>' + '</tr>'

	//Codigo de Barras
	cConteudo += '<tr>' + '<td colspan="6" align="center">' + '<code128>' + SUBSTR(cChvDoc,1,22) + '</code128>' + '</td>' + '</tr>'
	cConteudo += '<tr>' + '<td colspan="6" align="center">' + '<code128>' + SUBSTR(cChvDoc,23,44) + '</code128>' + '</td>' + '</tr>'

	//QrCode
	cKeyQrCode := cChvDoc + "|" 					// Chave Consulta
	cKeyQrCode += cDataEmi + cHoraEmi + "|" 		// Data e Hora
	cKeyQrCode += cTotal + "|" 						// Valor Total do CFe-SAT
	cKeyQrCode += IIF(!Empty(cCGC),cCGC,"") + "|" 	// CNPJ adquirente (se existir) (sem ponuações)
	cKeyQrCode += cAssQRCODE 						// Assinatura QRCODE	

	cKeyQrCode := "https://chart.apis.google.com/chart?cht=qr&chld=L|0&chl=" + cKeyQrCode + "&chs=250x250"

	cConteudo += '<tr>' + '<td colspan="6" align="center">' + '<img src=' + cKeyQrCode + '>' + '</td>' + '</tr>'
	cConteudo += '<tr>' + '<td colspan="6" align="center">' + '<b>' + cMsgApp + '</b>' + '</td>' + '</tr>'

	cConteudo += '</table>' + '</body>' + '</html>'
EndIf

aSATImp  := {} //Zerar variavel	lei dos impostos por item

Return cConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATEnvImp
Responsável pela impressão do comprovante SAT

@param		-
@author  	Varejo
@version 	P11.8
@since   	13/01/2017
@return	lRet	
/*/
//-------------------------------------------------------------------
Static Function LjSATEnvImp(cTexto,nTotalBruto,lReimp)

Local nRetImp 	:= -1												//retorno da impressora
Local nTSleep	:= 6												// Tempo do Sleep
Local nTotnFis	:= 0												// Fator não fiscal
Local nDesc   	:= 0												// Desconto calculado com fator fiscal
Local nFatorP 	:= 0												// Fator para impressão do pedido (SRCPED)
Local nFatNFis	:= 0 												// Fator não fiscal
Local aRetImp	:= {}
Local lPOS 		:= STFIsPOS()		//Pos?
Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Default cTexto		:= ""
Default nTotalBruto	:= 0
Default lReimp		:= .F.

If lMFE
	cLastSat := cTexto
EndIf

LjGrvLog("SAT","Envia para impressora imprimir o comprovante SAT")   
If !lAutomato//Quando executado via robô não deve haver interação com periféricos
	If lPos
		STWPrintTextNotFiscal(cTexto)
		cTexto := TAG_GUIL_INI+TAG_GUIL_FIM
		STWPrintTextNotFiscal(cTexto)
	Else
		nTotNFis := (SL1->L1_VLRLIQ - SL1->L1_FRETE + SL1->L1_DESCONT - nTotalBruto)
		If ExistFunc("LjAskSat")
			//Tratamento paleativo para impressora Bematech, ate a solucao de problema de comunicacao por parte da BEMATECH
			nRetImp := 999
			While nRetImp <> 0 .And. LjAskSat(nRetImp)
				If lReimp
					// Espera a impressora se recomunicar (Necessário após uma perda de comunicação)
					Processa({||LJSleep(nTSleep)},"Preparando impressão!") //"Aguarde. Preparando impressão!"
					nRetImp := INFTexto(cTexto,.T.)  //Envia comando para a Impressora
				Else
					nRetImp := INFTexto(cTexto)  //Envia comando para a Impressora
				EndIf
			End
		Else
			INFTexto(cTexto)  //Envia comando para a Impressora
		EndIf

		If nRetImp == 0
			cTexto := TAG_GUIL_INI+TAG_GUIL_FIM
			INFTexto(cTexto)
			//se houver Garantia Estendida na venda, realiza a impressão do termo
			If ExistFunc("LjNFCeGE") .AND. nTotNFis > 0
				LjGrvLog(SL1->L1_NUM,"Realiza a impressão do termo referente a Garantia Estendida")
				LjNFCeGE(3)
				
				//resetamos as variaveis estaticas do fonte LOJXFUNG.PRW apos a impressão do termo
				LjxSetRGer()
				LjxSetRGar()
			EndIf
		EndIf
		
		// Reimpressão do cupom não fiscal (Venda-Mista)
		/* Foi adicionado na reimpressão do cupom SAT e reimpressão do cupom SCRPED em caso de venda Mista.
		Necessário pois caso haja perda de comunicação com a impressora será necessário imprimir os comprovantes.*/
		If lReimp .And. !Empty(SL1->L1_DOCPED)			
			nFatNFis := nTotNFis /(nTotNFis + nTotalBruto)
			nDesc   := SL1->L1_DESCONT * nFatNFis
			nFatorP := (nTotNFis - nDesc + SL1->L1_FRETE)/SL1->L1_VLRLIQ
			// Imprime cupom não fiscal
			aRetImp := Lj7ImpCNF(,nFatorP,,,,,,,,,,,,,,lReimp)
			If aRetImp[1]
				LjGrvLog( "SAT", "Reimpressao do SCRPED executada com sucesso" )
			Else
				LjGrvLog( "SAT", "Problemas na reimpressão do SCRPED" )
			EndIf
		EndIf
	EndIf
Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSATVlSer
Responsável pela validação do número de série do SAT

@param		
@author  	Varejo
@version 	P11.8
@since   	03/02/2017
@return		lRet	
/*/
//-------------------------------------------------------------------
Static Function LJSATVlSer()

Local lRet          := .F.
Local aSATConsultar := {}		// Retorno consultar SAT
Local cSerSatok     := SLG->LG_SERSAT
Local cMensagem		:= ""
Local lPOS          := STFIsPOS() //Pos?
Local cNumSerie		:= ""		//Numero de serie retornado do Status Operacional do Equipamento SAT / MFe
Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

If LjSatGetSO() = nil
	LjSatSetSO()
EndIf
aSatConsultar := LjSatGetSO()   //posicao 6 do array contém a série do equipamento

If Len(aSatConsultar) > 5
	cNumSerie := aSatConsultar[6]
EndIf

//Esse trecho tem o objetivo de atualizar a SLG uma única vez para manter o legado e evitar que ocorra impedimento de uso por ter SERSAT já cadastrada incorreta.
If Alltrim(SLG->LG_PAFMD5) <> 'LJSATVlSer'
	SLG->(RecLock("SLG",.F.))
	SLG->LG_SERSAT := If(!lAutomato,cNumSerie,SLG->LG_SERSAT)
	SLG->LG_PAFMD5 := If(!lAutomato,'LJSATVlSer',SLG->LG_PAFMD5)
	SLG->(MsUnlock())
EndIf

If AllTrim(cSerSatok) == AllTrim(cNumSerie)
	lRet := .T.
Else

	cMensagem := StrTran(STR0093," SAT ", " "+cSiglaSat+" ") + CHR(10) + CHR(13) ;  					//"O número de série do equipamento SAT é diferente da série configurada na estação."   
				+ StrTran(STR0094," SAT "," "+cSiglaSat+" ") + cNumSerie + CHR(10) + CHR(13) ;			//"Serie do equipamento SAT conectado: "
				+ STR0095 + SLG->LG_SERSAT + CHR(10) + CHR(13) ;										//"Serie do equipamento configurada na estação (LG_SERSAT): "
				+ STR0096 + CHR(10) + CHR(13) ; 														//"Possível causa: troca de equipamento"
				+ StrTran(STR0097, " SAT"," "+cSiglaSat+" ") + CHR(10) + CHR(13) ;						//"Solução: Acessar o cadastro de estação (aba SAT) e atualizar a série do equipamento (LG_SERSAT)." 
				+ StrTran(STR0098, " SAT"," "+cSiglaSat+" ")   	
	
	If lPOS
	    STFMessage("SAT", "POPUP", cMensagem )
	    STFShowMessage("SAT")           
	Else
	    MsgAlert( cMensagem, STR0003 ) // Atenção!
	EndIf  		
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LjSatValDll
Valida DLL do SAT
@type function
@author  	rafael.pessoa
@since   	07/02/2017
@version 	P12
@param 		
@return	lRet - Retorna se a DLL do SAT é valida
/*/
//--------------------------------------------------------
Static Function LjSatValDll()

Local cPath 		:= GETCLIENTDIR() //diretorio raiz smartclient	
Local cMsg			:= ""	
Local nStatus		:= 0 //Variavel auxiliar para rename de arquivo
Local lRet			:= .F.	

//Busca DLL no Diretório smartclient 
If File( cPath + "dllsat.dll" )
	lRet	:= .T.
Else
	If File( cPath + "bemasat.dll" ) //Valida se exite Dll Bematech para renomear para dllsat.dll
		nStatus := fRename(cPath + "bemasat.dll" , cPath + "dllsat.dll" )
		If nStatus == 0
			lRet := .T. //Arquivo renomeado com sucesso
		EndIf
	EndIf
	
	If !lRet
		cMsg := "ATENÇÃO, Não foi encontrada a dllsat.dll em " + cPath + "dllsat.dll" + CRLF + ;
				"A DLL do fabricante deverá ser renomeada para dllsat.dll e copiada para pasta SmartClient " + CRLF + ;
				"Exemplo: Bematech renomeie a BemaSat.dll para dllsat.dll"  + CRLF + ;
				"Para mais informações acesse o item Check List da FAQ do SAT em nosso portal: " + " tdn.totvs.com"
		Alert( cMsg )
		LjGrvLog( "SAT", cMsg )
	EndIf		
EndIf
 
Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LjSatMgApp
Retorna a mensagem com o nome do aplicativo leitor específico de cada Unidade Federada
@type 		function
@author 	eduardo.sales
@since  	21/02/2017
@version 	P12.1.14
@param 		
@return		cRet - Retorna mensagem com o nome do aplicativo para consulta
/*/
//--------------------------------------------------------
Static Function LjSatMgApp()

Local cRet 		:= ""
Local cEst 		:= ""  
Local lEndFis  	:= GetNewPar("MV_SPEDEND",.F.)								//Se estiver como .F. refere-se ao Endereço de Cobrança se estiver .T. ao Endereço de Entrega
Local cQrbLinha := "<l></l>"
Local lPOS 		:= STFIsPOS()												//Pos?
Local cVerFirm	:= ""														//Versão do Firmware da Impressora Não Fiscal
Local lMVLJCOND	:= SuperGetMV("MV_LJCONDE",,.F.)							//Define se utilizar condensado ou não

cEst := IIf(lEndFis, SM0->M0_ESTENT, SM0->M0_ESTCOB)

If !lPos
	cVerFirm := LjGetFrmw()
EndIf

// Mensagem com o nome do aplicativo leitor do documento fiscal para SP 
If Upper(cEst) == "SP" 
	If lMVLJCOND .And. cVerFirm >= "03.20.04"
		cRet := PADC('Consulte o QR Code'	, 22) + cQrbLinha
		cRet += PADC('pelo aplicativo'		, 22) + cQrbLinha
		cRet += PADC('"De olho na nota",'	, 22) + cQrbLinha
		cRet += PADC('disponível na'		, 22) + cQrbLinha
		cRet += PADC('AppStore (Apple) e'	, 22) + cQrbLinha
		cRet += PADC('PlayStore (Android)'	, 22)
	Else
		cRet := 'Consulte o QR Code pelo aplicativo "De olho na nota", disponível na AppStore (Apple) e PlayStore (Android)' 
	EndIf
EndIf

Return cRet

//--------------------------------------------------------
/*/{Protheus.doc} LjSatVerSX5
Ajusta o SX5 para a venda SAT
@type 		function
@author 	julio.nery
@since  	15/03/2017
@version 	P11.8
@return		lRet - Sucesso ?
/*/
//--------------------------------------------------------
Function LjSatVerSX5()
Local nTam := Len(SX5->X5_TABELA)
Local lRet := .T.

SX5->(DBSetOrder(1)) //X5_FILIAL + X5_TABELA + X5_CHAVE

//Faz a inclusao da natureza do SAT na tabela SX5
If !SX5->(DbSeek(xFilial("SX5")+Padr("42",nTam)+"SATCE"))
	If SX5->(RecLock("SX5",.T.))
		SX5->X5_FILIAL	:= xFilial("SX5")
		SX5->X5_TABELA	:= "42"
		SX5->X5_CHAVE	:= "SATCE"
		SX5->X5_DESCRI	:= "Venda SAT"
		SX5->(MSUnlock())
		LjGrvLog(Nil,"Inclusao da Natureza do SAT no SX5")
	EndIf
EndIf

//Faz a inclusao da serie do SAT na tabela SX5 para evitar erro na finalização da venda
If !SX5->(DbSeek(xFilial("SX5")+Padr("01",nTam)+AllTrim(LjGetStation("SERIE"))))
	
	nTam := TamSX3("L1_DOC")[1] //Captura o tamnanho para preencher com uma numeração
	If SX5->(RecLock("SX5",.T.))
		SX5->X5_FILIAL	:= xFilial("SX5")
		SX5->X5_TABELA	:= "01"
		SX5->X5_CHAVE	:= AllTrim(LjGetStation("SERIE"))
		SX5->X5_DESCRI	:= StrZero(1, nTam )
		SX5->(MSUnlock())
		LjGrvLog(Nil,"Inclusao da série (configurado no LG_SERIE) do SAT no SX5")
		Conout("Inclusao da série (configurado no LG_SERIE) do SAT no SX5")
	EndIf
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LjSatVldSX
Validação da aplicação dos campos necessários no SAT
@type 		function
@author 	julio.nery
@since  	21/03/2017
@version 	P2
@return		lRet - prossegue ?
/*/
//--------------------------------------------------------
Function LjSatVldSX()
Local lRet	:= .T.
Local cMsg	:= ""

DbSelectArea("SFT")
DbSelectArea("SF3")

If !(SFT->(ColumnPos("FT_NFISCAN")) > 0 .And. SF3->(ColumnPos("F3_NFISCAN")) > 0)
	cMsg := " O(s) campo(s) F3_NFISCAN e/ou FT_NFISCAN não existe(m) na base de dados." + CHR(13) +;
			" Por favor, atualize seu dicionário de dados efetuando as alterações" +;
			" necessários para a criação do(s) campo(s), aplique o UPDDISTR ou " +;
			" acesse o link http://tdn.totvs.com/display/PROT/TTZKUZ_DT_CANCELAMENTO_SAT para criação manual dos campos" + CHR(13) +;
			" Cancelamento não será efetuado! "

	If IsBlind()
		Conout(cMsg)
	Else
		STPosMSG( "Atualização de Dicionário" , cMsg, .T., .F., .F.)
	EndIf

	LjGrvLog(Nil,cMsg)
	lRet := .F.
EndIf

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} LjSefazSat
Consulta as vendas SAT que foram enviadas para SEFAZ
@type	Function
@param	cNserieSat	- Numero de Serie do Equipamento SAT (Ex: 999999999)
@param	cDtIni		- Data Inicial da Pesquisa (Ex: DDMMAAAA = 01122016)
@param	cDtFim		- Data Final da Pesquisa (Ex: DDMMAAAA = 01122016)
@param	cChave		- Código gerado na retaguarda da SEFAZ para utilizar no WebService
@param	cUF			- Código do Estado (Ex: SP = "35")
@param	cVerLayout	- Versão do Layout do Cupom (Ex: "0.06")
@author bruno.inoue
@since  21/02/2017
@return	aCfeInfo - [1] - Venda
				   [2] - Cancelamento
					   [1][1] > Tipo da Venda (Ex: "Movimento" ou "Cancelamento")
					   [1][2] > Chave da Venda (CFe35160611111111111111591234567890001049048855) 
					   [1][3] > Doc (000104) 
					   [1][4] >	Situação (Processado com Sucesso)				
/*/
//----------------------------------------------------------
Function LjSefazSat(cNserieSat,cDtIni,cDtFim,cChave,cUF,cVerLayout)

Local oNfe			:= Nil	//Objeto do WebService SEFAZ
Local cCfeDadosMsg	:= ""	//XML de envio para consulta na SEFAZ
Local lConsult		:= .F.	//Retorno da consulta no WebService
Local cXml			:= ""	//XML de retorno da consulta da SEFAZ
Local oExtrato		:= Nil	//Objeto para Parse do XML de retorno
Local lRet			:= .T.	//Validacao de dados para prosseguir
Local cXPath		:= ""	//Caminho do Lote
Local cXPath2		:= ""	//Caminho do Cfe
Local nLote			:= 0	//Contador Lote
Local nCfe			:= 0	//Contador Cfe
Local aCfeInfo		:= {}	//Array de Retorno da consulta da SEFAZ
Local bOldError		:= Nil	//Bloco de erro caso ocorre algum problema
Local aInfoVenda	:= {}	//Todas vendas
Local aInfoCanc		:= {}	//Todos cancelamentos

Default cNserieSat	:= ""	//Numero de serie do equipamento
Default cDtIni		:= ""	//Data inicio da consulta
Default cDtFim		:= ""	//Data final da consulta 
Default cChave		:= ""	//Token de acesso as informações das vendas
Default cUF			:= "35"	//Codigo do UF do Estado para a consulta
Default cVerLayout	:= ""	//Versao do Layout

bOldError := ErrorBlock( {|x| LjVerIfErro(x) } ) // Code-Block de erro
BEGIN SEQUENCE
	If Empty(cNserieSat) .Or. Empty(cDtIni) .Or. Empty(cDtFim) .Or. Empty(cChave);
	   .Or. Empty(cUF) .Or. Empty(cVerLayout)
	   lRet := .F.
	EndIf
	
	If lRet
		If AllTrim(cUF) <> "35"
			lRet := .F.
		EndIf 
	EndIf
	
	If lRet
		cDtIni := cDtIni + "000000" 
		cDtFim := cDtFim + "235959"
		oNfe := WSCfeConsultaLotes():New()
		
		cCfeDadosMsg := "<![CDATA["
		cCfeDadosMsg += '<consLote xmlns="http://www.fazenda.sp.gov.br/sat" versao="'+cVerLayout+'">'
		cCfeDadosMsg += "<nserieSAT>"  		+ cNserieSat + "</nserieSAT>" 		//NUMERO DE SERIE DO SAT  SEM O DIGITO VERIFICADOR
		cCfeDadosMsg += "<dhInicial>"  		+ cDtIni	 + "</dhInicial>" 		//DATA INICIAL DA CONSULTA FORMATO DDMMAAAAHHMMSS
		cCfeDadosMsg += "<dhFinal>"    		+ cDtFim   	 + "</dhFinal>"   		//DATA FINAL   DA CONSULTA FORMATO DDMMAAAAHHMMSS
		cCfeDadosMsg += "<chaveSeguranca>" 	+ cChave 	 + "</chaveSeguranca>"  //CHAVE DE SEGURANÇA PARA A CONSULTA NO SEFAZ 36 DIGITOS ALFANUMERICO
		cCfeDadosMsg += "</consLote>"                                           //OBS. A CHAVE TEM QUE SER IGUAL A GERADA PELO SEFAZ COM OS IFENS
		cCfeDadosMsg += "]]>"
		
		lConsult := oNfe:ConsultarLotesEnviados(cCfeDadosMsg,cUF,cVerLayout) //ENVIA OS DADOS PARA O SEFAZ
		If lConsult
			cXml := EncodeUtf8( oNfe:CCFECONSULTARLOTESRESULT )
			LjGrvLog("LOTE_SEFAZ", "Tamanho do retorno do XML: ", Len(cXml))
			oExtrato := TXMLManager():New()
			lRet := oExtrato:Parse( cXML )
			If lRet
				While .T.
					nLote++
					cXPath := "/resLote/Lote[" + cValToChar(nLote) + "]"
					If OEXTRATO:XPathHasNode( cXPath )
						While .T.
							nCfe++
							cXPath2 := "/resLote/Lote[" + cValToChar(nLote) + "]/InfCfe/Cfe[" + cValToChar(nCfe) + "]"
							If OEXTRATO:XPathHasNode( cXPath2 )
								If OEXTRATO:XPathGetNodeValue( cXPath  + "/TipoLote" ) <> "Cancelamento"
									aAdd(aInfoVenda, ;
											{OEXTRATO:XPathGetNodeValue( cXPath  + "/TipoLote" 	),;	
											 OEXTRATO:XPathGetNodeValue( cXPath2 + "/Chave" 	),;	
											 OEXTRATO:XPathGetNodeValue( cXPath2 + "/nCupom" 	),;	
											 OEXTRATO:XPathGetNodeValue( cXPath2 + "/Situacao" 	)};
										)
								Else	
									aAdd(aInfoCanc, ;
											{OEXTRATO:XPathGetNodeValue( cXPath  + "/TipoLote" 	),;	
											 OEXTRATO:XPathGetNodeValue( cXPath2 + "/Chave" 	),;	
											 OEXTRATO:XPathGetNodeValue( cXPath2 + "/nCupom" 	),;	
											 OEXTRATO:XPathGetNodeValue( cXPath2 + "/Situacao" 	)};
										)
								EndIf
							Else
								nCfe := 0
								Exit		
							EndIf		
						EndDo
					Else
						nLote := 0
						Exit
					EndIf
				EndDo
				aAdd(aCfeInfo,aInfoVenda)	//Vendas
				aAdd(aCfeInfo,aInfoCanc)	//Cancelamento
			EndIf
		Else
			MsgAlert(STR0099) //"Não foi possível se conectar no servidor da SEFAZ. Tente novamente."
		EndIf
	EndIf	
END SEQUENCE
ErrorBlock( bOldError )

Return aCfeInfo

//----------------------------------------------------------
/*/{Protheus.doc} LjVerifErro
Efetua tratamento caso ocorra erro no BEGIN SEQUENCE
@type 	Function
@author bruno.inoue
@since  21/02/2017
@return lRet 		
/*/
//----------------------------------------------------------
Static Function LjVerifErro( e )
Local lRet := .F.	// Retorno da funcao 

If e:gencode > 0  
	Conout( "Ocorreu o erro: " + e:DESCRIPTION ) 
	Conout( "Pilha de chamada: " + e:ERRORSTACK ) 
	MsgAlert(STR0100) //"Ocorreu uma inconsistência com a tratativa das informações ao recuperar os dados dos Lotes da SEFAZ."
    lRet := .T.
    Break
Endif  

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LjSatFinCnc
Usada para finalizar um cancelamento que foi interrompido
@type 		function
@author 	julio.nery
@since  	10/04/2017
@version 	P11.8
@return		lRet - prossegue ?
/*/
//--------------------------------------------------------
Function LjSatFinCnc(lClearSessao)
Local aRet		:= {}
Local cPass		:= STFGetStation("CODSAT",,.F.) 		//Retorna o código de ativação do SAT
Local cCOd		:= ""
Local lRet		:= .F.
Local cArqSessao:= GetClientDir() + "sessaosat.txt"

Default lClearSessao := .F.

If !lClearSessao
	LjGrvLog( "SAT", "Processo de Recuperacao do Cancelamento da Venda - Inicio " )
	cCOd := GetPvProfString("SAT","SESSAO","",cArqSessao )
	LjGrvLog( "SAT", "Codigo da sessao recuperado do arquivo:"+cArqSessao, cCOd )
	
	aRet := GetConsNS()
	If Len(aRet) == 0
		If lMFE .And. lIntegrador
			LjConsSess(cCOd)
		EndIf	
		aRet := LJSATComando({"12","ConsultarNumeroSessao",LJSATnSessao(), cPass,cCOd})
		SetConsNS(aRet)
	EndIf
	
	LjGrvLog( "SAT", "Tamanho do array retornado do comando enviado ao SAT - aRetorno : ", Len(aRet))
	
	If Len(aRet) > 2 .And. Val(aRet[2]) == 7000
		LjGrvLog( "SAT", "Cancelamento recuperado do equipamento com sucesso" )
		lRet := .T.
	EndIf
EndIf

If lClearSessao .Or. !lRet
	SetConsNS()
	WritePProString("SAT","SESSAO","", cArqSessao)
	LjGrvLog( "SAT", "Processo de Recuperacao do Cancelamento de Venda - Fim" )
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LjSaCtrCnc
Usada para fazer o controle de cancelamento, para 
evitar problemas de queda de energia no cancelamento
- Criado em arquivo pois no meio do processo existe um 
controle de transação e ao derrubar o server volta 
qualquer alteração do BD

@type 		function
@author 	julio.nery
@since  	10/04/2017
@version 	P11.8
@return		lRet - prossegue ?
/*/
//--------------------------------------------------------
Function LjSaCtrCnc(lCria,	lDeleta, lRead , lWrite,;
					cStatus)
Local cPath	:= GetClientDir()
Local cNome := "LjSaCtrCnc.pac"
Local nHndTXT:= 0
Local nTamanho:= 0
Local cRet	:= ""
Local cSeek	:= ""

Default lCria	:= .F.
Default lDeleta := .F.
Default lRead	:= .F.
Default lWrite	:= .F.
Default cStatus	:= ""

LjGrvLog("SAT_CTRL_DLT","Inicia Controle de Arquivo de Cancelamento SAT")

If lCria .Or. lDeleta
	If File(cPath + cNome)
		LjGrvLog("SAT_CTRL_DLT","Deleta arquivo de controle de cancelamento [" + cPath + cNome + "] ")
		If FErase(cPath + cNome) <> -1
			LjGrvLog("SAT_CTRL_DLT","Deleta arquivo de controle de cancelamento [" + cPath + cNome + "] ")
		Else
			LjGrvLog("SAT_CTRL_DLT","Arquivo de controle de cancelamento NÃO DELETADO [" + cPath + cNome + "] ")
		EndIf
	EndIf
	
	If lCria
		nHndTXT := FCREATE(cPath + cNome)
		If nHndTXT > 0							    
			LjGrvLog("SAT_CTRL_DLT","Arquivo de log de cancelamento criado : [" + cPath + cNome + "]")
			FCLOSE( nHndTXT )
		Else
			LjGrvLog("SAT_CTRL_DLT","Erro na criação do arquivo de log de cancelamento - arquivo : [" + cPath + cNome + "]")
		EndIf
	EndIf
EndIf

If (lRead .Or. lWrite) .And. (File(cPath + cNome))
	nHndTXT := FOpen(Upper(cPath + cNome),FO_READWRITE)
	
	If nHndTXT > 0
		If lRead
			nTamanho := FSeek(nHndTXT,0,FS_END)
			FSeek(nHndTXT,0,FS_SET)
			cRet := FReadStr(nHndTXT,nTamanho)
			LjGrvLog("SAT_CTRL_DLT","Arquivo " + cNome + " lido - Retorno [" + cRet + "]")

		ElseIf lWrite .And. ! Empty(cStatus)			
			//Necessário para o Seek após a leitura do arquivo
			cSeek := "|" + SL1->L1_FILIAL + "|" + SL1->L1_PDV + "|" + SL1->L1_DOC
			fWrite(nHndTXT,cStatus + cSeek)
			LjGrvLog("SAT_CTRL_DLT","Arquivo " + cNome + " escrito - Conteúdo [" + cSeek + "]")
		EndIf
		
		FCLOSE( nHndTXT )
	EndIf
EndIf

LjGrvLog("SAT_CTRL_DLT","Fim Controle de Arquivo de Cancelamento SAT")

Return cRet

//--------------------------------------------------------
/*/{Protheus.doc} LjSaTraCtr
Faz o tratamento do conteudo do arquivo LjSaCtrCnc.pac
@type 		function
@author 	julio.nery
@since  	10/04/2017
@version 	P11.8
@return		lRet - prossegue ?
/*/
//--------------------------------------------------------
Function LjSaTraCtr(cStatus)
Local aRet	:= {"","","",""} //1 - Status / 2 - Filial / 3 - PDV /4 - Documento (L1_DOC)
Local cSep	:= "|"

If ! Empty(cStatus) 
	aRet	:= StrToKArr(cStatus,cSep)
	aRet[1]	:= Alltrim(aRet[1])
EndIf

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} LjSatAjTab
Faz a gravação dos dados da venda cancelada
@type 		function
@author 	julio.nery
@since  	13/04/2017
@version 	P11.8
@return		lRet - prossegue ?
/*/
//--------------------------------------------------------
Function LjSatAjTab(lFront	,	lLoja		,	lPos	,	cNFisCanc,;
					cLiMsg	,	OEXTRATOSAT	)
Local cDocVenda		:= ""

Default lFront		:= nModulo == 23 .And. !(ExistFunc("STFIsPOS") .AND. STFIsPOS())
Default lLoja		:= nModulo == 12
Default lPos		:= ExistFunc("STFIsPOS") .AND. STFIsPOS()
Default cNFisCanc	:= ""
Default cLiMsg		:= ""
Default OEXTRATOSAT := NIL

If lFront 
	If SL1->(RecLock("SL1",.F.))
		SL1->L1_SITUA := "00"
		SL1->L1_STORC := "A"
		SL1->(MsUnlock())
		
		If OEXTRATOSAT <> NIL
			cDocVenda := OEXTRATOSAT:XPathGetNodeValue( "/CFe/infCFe/ide/nCFe" )
		Else
			cDocVenda := SL1->L1_DOC
		EndIf
		
		cLiMsg := SL1->L1_NUMORIG+"|"+ cDocVenda +"|"+SL1->L1_PDV+"|"+cNfisCanc 	// Monta mensagem para cancelamento na Retaguarda via SLI
	Else
		LjGrvLog("SAT","Sem lock na SL1")
	EndIf

	If !Empty(cLiMsg)
		FR271BGerSLI("    ", "CAN", cLiMsg, "NOVO")
	EndIf
	FR271BCancela()
ElseIf lLoja
	//chamar o cancelamento do livro fiscal
	If LJCancSAT(SL1->L1_DOC, SL1->L1_SERIE,cNFisCanc)
		If SL1->(RecLock("SL1",.F.))
			SL1->L1_DOC		:= ""
			SL1->L1_SERIE		:= ""
			SL1->L1_ESPECIE	:= ""
			SL1->L1_SERSAT	:= ""
			SL1->L1_KEYNFCE	:= ""
			SL1->L1_SITUA		:= ""
			SL1->(MsUnlock())
		EndIf
	Else
		If SL1->(RecLock("SL1",.F.))
			SL1->L1_SITUA	:= "ER"
			SL1->(MsUnlock())
		EndIf
	EndIf
	
ElseIf lPOS
	If SL1->(RecLock("SL1",.F.))
		SL1->L1_SITUA := "00"
		SL1->L1_STORC := "C"
		SL1->(MsUnlock())
	EndIf
	STDCSRequestCancel( SL1->L1_NUM , Nil, cNFisCanc )					
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATComp
Função que chama a tela para escolhados produtos que enviarão a complementar 
e gerar os livros fiscais

@param   	
@author  	eduardo.sales
@version 	P12
@since   	21/08/2017
@return  	
/*/
//-------------------------------------------------------------------
Function LjSATComp()

Local aItensSel		:= {}
Local lContinua		:= .T.
Local cLjSATCp		:= SuperGetMv("MV_LJSATCP",,"")	// TES para criar Complementar de ICMS
Local lCompICMS 	:= .T.							// Variável controlar se o envio é Complementar de ICMS ou não

If LjTESVal(cLjSATCp)
	If !Empty(L1_DOC) .AND. !Empty(L1_SERIE) .AND. L1_STORC <> "A" .AND. !(L1_SITUA $ "X0|X1|X2|X3|RX|ER|DU") .AND. !(L1_STATUS $ "D|F") .AND. (FieldPos("L1_STATUES") = 0 .OR. Empty(L1_STATUES))
		lContinua := LjSelProd(@aItensSel)

		If lContinua
			BEGIN TRANSACTION
				
				LjMsgRun("Aguarde. Emitindo Complementar ICMS..." ,,{ || LjProcComp(aItensSel, lCompICMS) })	// "Aguarde. Emitindo Complementar ICMS..."

			END TRANSACTION
		EndIf
	Else
		MsgAlert("Não é permitido emitir CF-e SAT Complementar de ICMS para uma venda não finalizada.")
	EndIf
EndIf

aValItCP := {}

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSelProd
Tela para seleção dos produtos que terão a CF-e SAT complementar de ICMS

@param   	
@author  	eduardo.sales
@version 	P12
@since   	21/08/2017
@return  	lRet - Retorna se confirmou ou fechou a tela de seleção
/*/
//-------------------------------------------------------------------
Function LjSelProd(aItensSel)

Local lRet			:= .T.
Local oGet			:= Nil
Local aCampos  		:= {"ALIQNOVA"} 							// Variável contendo o campo editável no Grid
Local aHeaderPrd  	:= {}         								// Variavel que montará o aHeader do grid

Private aColsPrd 	:= {}         								// Variável que receberá os dados

// Gera o cabeçalho do Getdados
LjHeader(@aHeaderPrd)
LjACols(aHeaderPrd, @aColsPrd)

DEFINE MSDIALOG oDlg TITLE "CF-e SAT Complementar de ICMS" FROM 000, 000  TO 300, 700  PIXEL

oGet := MsNewGetDados():New( 053, 078, 415, 775, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aCampos, 0, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderPrd, aColsPrd)

//Seta o array do aCols do Objeto.
oGet:SetArray(aColsPrd,.T.)

//Atualiza as informações no grid
oGet:Refresh()

//Alinha o grid para ocupar todo o formulário
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
 
//Ao abrir a janela o cursor está posicionado no objeto
oGet:oBrowse:SetFocus()

aColsPrd := oGet:aCols

EnchoiceBar(oDlg, {|| LjAliqVal(@oDlg, aColsPrd, aItensSel) }, {|| lRet := .F., oDlg:End() },,,,,,,.F.)

ACTIVATE MSDIALOG oDlg CENTERED

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjHeader
Função para preecher o aHeader que é mostrado no grid de seleção de produtos
para o Complementar de ICMS

@param   	
@author  	eduardo.sales
@version 	P12
@since   	21/08/2017
@return  	
/*/
//-------------------------------------------------------------------
Static Function LjHeader(aHeaderPrd)

SX3->(dbSetOrder(2))
If SX3->(dbSeek("L2_ITEM"))
	Aadd(aHeaderPrd, {	SX3->X3_TITULO	,; // X3_TITULO
						SX3->X3_CAMPO	,; // X3_CAMPO
						SX3->X3_PICTURE	,; // X3_PICTURE
						SX3->X3_TAMANHO	,; // X3_TAMANHO
						SX3->X3_DECIMAL	,; // X3_DECIMAL
						SX3->X3_VALID	,; // X3_VALID
						SX3->X3_USADO	,; // X3_USADO
						SX3->X3_TIPO	,; // X3_TIPO
						SX3->X3_F3		,; // X3_F3
						SX3->X3_CONTEXT	,; // X3_CONTEXT
						SX3->X3_CBOX	,; // X3_CBOX
						SX3->X3_RELACAO	,; // X3_RELACAO
						SX3->X3_WHEN	}) // X3_WHEN
EndIf

If SX3->(dbSeek("L2_PRODUTO"))
	Aadd(aHeaderPrd, {	SX3->X3_TITULO	,; // X3_TITULO
						SX3->X3_CAMPO	,; // X3_CAMPO
						SX3->X3_PICTURE	,; // X3_PICTURE
						SX3->X3_TAMANHO	,; // X3_TAMANHO
						SX3->X3_DECIMAL	,; // X3_DECIMAL
						SX3->X3_VALID	,; // X3_VALID
						SX3->X3_USADO	,; // X3_USADO
						SX3->X3_TIPO	,; // X3_TIPO
						SX3->X3_F3		,; // X3_F3
						SX3->X3_CONTEXT	,; // X3_CONTEXT
						SX3->X3_CBOX	,; // X3_CBOX
						SX3->X3_RELACAO	,; // X3_RELACAO
						SX3->X3_WHEN	}) // X3_WHEN
EndIf

If SX3->(dbSeek("L2_DESCRI"))
	Aadd(aHeaderPrd, {	SX3->X3_TITULO	,; // X3_TITULO
						SX3->X3_CAMPO	,; // X3_CAMPO
						SX3->X3_PICTURE	,; // X3_PICTURE
						SX3->X3_TAMANHO	,; // X3_TAMANHO
						SX3->X3_DECIMAL	,; // X3_DECIMAL
						SX3->X3_VALID	,; // X3_VALID
						SX3->X3_USADO	,; // X3_USADO
						SX3->X3_TIPO	,; // X3_TIPO
						SX3->X3_F3		,; // X3_F3
						SX3->X3_CONTEXT	,; // X3_CONTEXT
						SX3->X3_CBOX	,; // X3_CBOX
						SX3->X3_RELACAO	,; // X3_RELACAO
						SX3->X3_WHEN	}) // X3_WHEN
EndIf				  

Aadd(aHeaderPrd, {"Aliquota"	,; // X3_TITULO
                  "ALIQUOTA"	,; // X3_CAMPO
                  "99.99"		,; // X3_PICTURE
                  5				,; // X3_TAMANHO
                  2				,; // X3_DECIMAL
                  ""			,; // X3_VALID
                  ""			,; // X3_USADO
                  "N"			,; // X3_TIPO
                  ""			,; // X3_F3
                  "R"			,; // X3_CONTEXT
                  ""			,; // X3_CBOX
                  ""			,; // X3_RELACAO
                  ""			}) // X3_WHEN

Aadd(aHeaderPrd, {"Aliq. Nova"	,; // X3_TITULO
                  "ALIQNOVA"	,; // X3_CAMPO
                  "99.99"		,; // X3_PICTURE
                  5				,; // X3_TAMANHO
                  2				,; // X3_DECIMAL
                  ""			,; // X3_VALID
                  ""			,; // X3_USADO
                  "N"			,; // X3_TIPO
                  ""			,; // X3_F3
                  "R"			,; // X3_CONTEXT
                  ""			,; // X3_CBOX
                  ""			,; // X3_RELACAO
                  ""			}) // X3_WHEN

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjACols
Função para preecher o aCols que é mostrado no grid de seleção de produtos
para o Complementar de ICMS

@param   	
@author  	eduardo.sales
@version 	P12
@since   	21/08/2017
@return  	
/*/
//-------------------------------------------------------------------
Static Function LjACols(aHeaderPrd, aColsPrd)

Local nX		:= 0
Local cCampo	:= ""

SD2->(DbSetOrder(3)) //D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA
If SD2->(DbSeek(xFilial("SD2") + SL1->L1_DOC + SL1->L1_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA) )

	Do WHILE !SD2->(EOF()) .And. ;
		xFilial("SD2") + SL1->L1_DOC + SL1->L1_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA == SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA
		
		aAdd( aColsPrd, Array(Len(aHeaderPrd) + 1))
		aColsPrd[Len(aColsPrd)][Len(aHeaderPrd) + 1] := .F.
		
		For	nX := 1 to Len(aHeaderPrd)

			cCampo := AllTrim(aHeaderPrd[nX][2])

			If cCampo == "L2_ITEM"
				aColsPrd[Len(aColsPrd)][nX] := SD2->D2_ITEM
			ElseIf cCampo == "L2_PRODUTO"
				aColsPrd[Len(aColsPrd)][nX] := SD2->D2_COD
			ElseIf cCampo == "L2_DESCRI"
				aColsPrd[Len(aColsPrd)][nX] := Posicione("SB1", 1, xFilial("SB1")+SD2->D2_COD, "B1_DESC")
			ElseIf cCampo == "ALIQUOTA"
				aColsPrd[Len(aColsPrd)][nX] := SD2->D2_PICM
			ElseIf cCampo == "ALIQNOVA"
				aColsPrd[Len(aColsPrd)][nX] := 0
			EndIf
		Next nX

		SD2->(DbSkip())
	EndDo
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSATxAdic
Monta XML dados de Grupo de Informações Adicionais

@param   	
@author  	eduardo.sales
@version 	P12
@since   	21/08/2017
@return  	cXML - String com parte do XML
/*/
//-------------------------------------------------------------------
Static Function LjSATxAdic()

Local cXML := ""

MH2->(DbSetOrder(3))
If MH2->(DbSeek(xFilial("MH2")+SL1->L1_SERIE+SL1->L1_DOC))
	cXML	+= '<infAdic>'
	cXML	+= "<infCpl>" + AllTrim(MH2->MH2_DOCCHV) + "</infCpl>"
	cXML	+= '</infAdic>'
EndIf

Return cXML

//-------------------------------------------------------------------
/*/{Protheus.doc} LjGerLivro
Gera as tabelas do Livros Fiscais para controle do SPED

@param   	
@author  	eduardo.sales
@version 	P12
@since   	21/08/2017
@return  	
/*/
//-------------------------------------------------------------------
Static Function LjGerLivro(aItensSel, aRetSAT, cLjSATCp)

Local aSF2Struct 	:= {}	// Estrutura da tabela SF2
Local aSD2Struct 	:= {}	// Estrutura da tabela SD2
Local xValor	 	:= Nil	// Valor do campo
Local aSF2		 	:= {}	// Array com o cabecalho da nota fiscal
Local aSD2		 	:= {}	// Array com os itens da nota fiscal
Local aSD2Aux	 	:= {}	// Array com os itens da nota fiscal
Local nX			:= 0
Local nI			:= 0
Local cDocComp		:= 0
Local nPos			:= 0

Private lMsErroAuto	:= .F.

MH2->(DbSetOrder(2))	// MH2_FILIAL + MH2_DOCCHV
If MH2->(DbSeek(xFilial("MH2")+SubStr(aRetSAT[7], 4, Len(aRetSAT[7]))))
	cDocComp := MH2->MH2_DOC
EndIf

aSF2Struct := SF2->(DbStruct())
aSD2Struct := SD2->(DbStruct())

SF2->(DbSetOrder(1))	// F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA
SD2->(DbSetOrder(3))	// D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA

If	SF2->(DbSeek(xFilial("SF2") + SL1->L1_DOC + SL1->L1_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA))
	
	/*===================================================
		SF2 - carrega o cabecalho do documento original
	===================================================*/
	For nX := 1 to Len(aSF2Struct)
		If aSF2Struct[nX][1] == "F2_TIPO"
			xValor := "I"
		ElseIf aSF2Struct[nX][1] == "F2_DOC"
			xValor := cDocComp
		ElseIf aSF2Struct[nX][1] == "F2_CHVNFE"
			xValor := SubStr(aRetSAT[7], 4, Len(aRetSAT[7]))
		ElseIf aSF2Struct[nX][1] == "F2_EMISSAO"
			xValor := Date()
		Else
			// nome do campo | valor do campo | nulo
			xValor := &("SF2->" + aSF2Struct[nX][1])
		EndIf

		Aadd(aSF2, {aSF2Struct[nX][1], xValor, Nil})
	Next nX

	If SD2->(DbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))

		While !SD2->(EOF()) .And. SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA

			// Caso o produto posicionado não for selecionado pelo usuário, pula esse registro na SD2
			nPos := aScan(aItensSel, {|x| AllTrim(x[1]) == AllTrim(SD2->D2_ITEM) } )
			If nPos == 0
				SD2->(DbSkip())
				Loop
			EndIf
			
			nPosAliq := aScan(aValItCP, {|x| AllTrim(x[1]) == AllTrim(SD2->D2_ITEM) } )

			// Alimenta o array da linha com os dados da linha
			For nI := 1 to Len( aSD2Struct )
				If aSD2Struct[nI][1] == "D2_TES"
					xValor := cLjSATCp
				ElseIf aSD2Struct[nI][1] == "D2_TIPO"
					xValor := "I"
				ElseIf aSD2Struct[nI][1] == "D2_DOC"
					xValor := cDocComp
				ElseIf aSD2Struct[nI][1] == "D2_QUANT"
					Loop
				ElseIf aSD2Struct[nI][1] == "D2_SEGUM"
					Loop
				ElseIf aSD2Struct[nI][1] == "D2_DTVALID"
					Loop
				ElseIf aSD2Struct[nI][1] == "D2_NUMLOTE"
					Loop
				ElseIf aSD2Struct[nI][1] == "D2_NFORI"
					xValor := SD2->D2_DOC
				ElseIf aSD2Struct[nI][1] == "D2_PICM"
					xValor := aValItCP[nPosAliq][2]
				ElseIf aSD2Struct[nI][1] == "D2_SERIORI"
					xValor := SD2->D2_SERIE
				ElseIf aSD2Struct[nI][1] == "D2_ITEMORI"
					xValor := SD2->D2_ITEM
				Else
					xValor := &("SD2->" + aSD2Struct[nI][1])
				EndIf
				
				Aadd(aSD2Aux, {aSD2Struct[nI][1], xValor, Nil})
			Next nI

			Aadd(aSD2, Aclone(aSD2Aux))
			SD2->(DbSkip())
		EndDo
	Else
		MsgStop("Itens da Venda (SD2) original não encontrados.")
	EndIf
EndIf

// Inclusão da Nota de Complemento de ICMS
MsExecAuto( {|x,y,z| MATA920(x,y,z)}, aSF2, aSD2, 3 )

If lMsErroAuto
	DisarmTransaction()	
	MostraErro()
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LjTESVal
Valida se a TES para criar o Complementar de ICMS está correto

@param   	
@author  	eduardo.sales
@version 	P12
@since   	21/08/2017
@return  	lRet
/*/
//-------------------------------------------------------------------
Static Function LjTESVal(cLjSATCp)

Local lRet 			:= .T.			// Retorno da funcao
Local aMsg130Erro	:= {}			// Mensagens de erro na configuracao de TES
Local cMsgErro		:= ""			// Mensagem de erro
Local nX			:= 0			// Variavel de for.
Local oFont							// Objeto para apresentacao da tela
Local oDlg							// Objeto para apresentacao da tela
Local oMemo							// Objeto para apresentacao da tela
Local aArea 		:= GetArea()	// Guarda a area	

lRet := .F.

If !Empty(cLjSATCp)
	DbSelectArea("SF4")
	DbSetOrder(1)	// F4_FILIAL + F4_CODIGO
	If DbSeek(xFilial("SF4") + cLjSATCp)	
		If SF4->F4_CREDICM <> "N"
			Aadd(aMsg130Erro, "Campo 'Cred. ICM' deve estar preenchido como N - Não.")	
		EndIf

		If SF4->F4_DUPLIC <> "N"
			Aadd(aMsg130Erro, "Campo 'Gera Duplic. ICMS' deve estar preenchido como N - Não.")	
		EndIf

		If SF4->F4_AGREG <> "N"
			Aadd(aMsg130Erro, "Campo 'Agrega Valor' deve estar preenchido como N - Não.")	
		EndIf

		If SF4->F4_ESTOQUE <> "N"
			Aadd(aMsg130Erro, "Campo 'Atualiza Estoque' deve estar preenchido como N - Não.")	
		EndIf

		If SF4->F4_PODER3 <> "N"
			Aadd(aMsg130Erro, "Campo 'Poder de Terceiros' deve estar preenchido como N - Não.")	
		EndIf

		If SF4->F4_ICM <> "S"
			Aadd(aMsg130Erro, "Campo 'Calcula ICMS' deve estar preenchido como S - Sim.")	
		EndIf
		
		If Len(aMsg130Erro) == 0
			lRet := .T.
		EndIf
	Else
		Aadd(aMsg130Erro, "TES " + Alltrim(cLjSATCp) + ", informado no parâmetro MV_LJSATCP, não está cadastrada na tabela de Tipos de Entrada e Saídas.")
	EndIf
Else
	Aadd(aMsg130Erro, "O parâmetro MV_LJSATCP não esta preenchido corretamente.")
EndIf

If !lRet
	cMsgErro := "A configuracao da TES para emitir o CF-e SAT Complementar de ICMS não esta correta. Verificar:" + Chr(10)
	
	For nX := 1 To Len(aMsg130Erro)
		cMsgErro += Chr(10) + "- " +  aMsg130Erro[nX] + Chr(10)
	Next nX
    
	cMsgErro +=	Chr(10) + "Por favor, regularize as situações acima para prosseguir na emissão do Complementar de ICMS."

	/*==========================================================
		Monta tela com as informacoes do erro de configuracao
	==========================================================*/
	DEFINE FONT oFont NAME "ARIAL" SIZE 6,16
	//"Emissão de Nota sobre Cupom - Livro Fiscal OnLine"
	DEFINE MSDIALOG oDlg TITLE "CF-e SAT Complementar de ICMS" From 3,0 to 340,417 PIXEL
		@ 5,5 GET oMemo  VAR cMsgErro MEMO SIZE 200,145 OF oDlg PIXEL
		oMemo:oFont:=oFont
	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
	ACTIVATE MSDIALOG oDlg CENTER
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjProcComp
Função responsável por realizar os processamentos para a emissão
do SAT Complementar de ICMS.

@param   	
@author  	eduardo.sales
@version 	P12
@since   	21/08/2017
@return  	lRet
/*/
//-------------------------------------------------------------------
Static Function LjProcComp(aItensSel, lCompICMS)

Local cXML 			:= ""
Local cPass			:= ""
Local aRetSAT		:= {}
Local cLjSATCp		:= SuperGetMv("MV_LJSATCP",,"")	// TES para criar Complementar de ICMS

cXML 	:= LjSATXml(lCompICMS, aItensSel)
cPass	:= IIF(LJGetStation("CODSAT", .F.) == Nil, "", LJGetStation("CODSAT", .F.))
aRetSAT := LJSATComando({"12", "EnviarDadosVenda", LJSATnSessao(), cPass, cXML}, lCompICMS)

If Len(aRetSAT) > 4
	/*==========================================
		Realiza a gravação do Livros Fiscais
	==========================================*/
	LjGerLivro(aItensSel, aRetSAT, cLjSATCp)
Else
	cMsgComp := "Ocorreu um erro ao tentar enviar o ICMS Complementar:" + CRLF + CRLF
	cMsgComp += aRetSat[2] + "-" + aRetSat[4] + CRLF + CRLF
	cMsgComp += "Favor verificar a conexão do aparelho SAT e tentar novamente."
	
	MsgAlert(cMsgComp)
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LjAliqVal
Realiza a validação da tela de digitação da nova aliquota para o
SAT Complementar de ICMS.

@param   	
@author  	eduardo.sales
@version 	P12
@since   	21/08/2017
@return  	lRet
/*/
//-------------------------------------------------------------------
Static Function LjAliqVal(oDlg, aColsPrd, aItensSel)

Local lRet	:= .T.
Local nX 	:= 0

For nX := 1 To Len(aColsPrd)
	If aColsPrd[nX][5] > 0
		If aColsPrd[nX][4] >= aColsPrd[nX][5]
			MsgAlert("Percentual da Nova Aliquota deve ser maior que a Aliquota atual.")
			lRet := .F.
			Exit
		Else
			aAdd(aItensSel, aColsPrd[nX])
		EndIf
	EndIf
Next nX

If lRet 
	If Len(aItensSel) <= 0
		MsgAlert("Para emitir o CF-e SAT Complementar de ICMS, deve ser informado a nova aliquota.")
		lRet := .F.
	Else
		oDlg:End()
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCmdMFE
	Comandos para o MF-e e o Validador Fiscal VFP-e
	@type  Function
	@author bruno.inoue
	@since 11/07/2017
	@version 11.8
	@param 
	@return
/*/
//-------------------------------------------------------------------
Function LjCmdMFE(nTipo,cMetodo,aParam)

Local cXML			:= ""							//XML do comando a ser enviado para o Integrador
Local cComponente	:= ""							//Em qual componente será executado o comando no Integrador "MF-e" ou "VFP-e"
Local cPath			:= SuperGetMV("MV_MFEPUT",,"")  //"C:\Integrador\Input\"	//Local onde será gravado o XML a ser processado
Local cFileName		:= ""							//Nome do arquivo
Local cFileReName	:= ""							//Nome do arquivo que será renomeado
Local cFileNameEx	:= ""							//Nome do arquivo com extensão
Local nHandle 		:= 0							//Retorno dos comandos de criação, abertura e renomear o arquivo
Local nX			:= 0							//Contador
Local cErro			:= ""							//Mensagem de erro
Local cChvVld		:= STFGetStation("CHVVLD",,.F.) //Chave do Validador

Default nTipo		:= 0
Default cMetodo		:= ""
Default aParam		:= {}

// Tratamento para caso o caminho cPath esteja sem "\" no final 
If SubStr(cPath, Len(cPath), 1) <> "\"
   	cPath += "\"
EndIf 

Ljgrvlog("MFE_COMANDO","INICIO DO COMANDO "+cMetodo+"")

cFileName	:= cMetodo + dToS(DATE()) 
cFileNameEx	:= cFileName + ".tmp"
cFileReName	:= cFileName + ".xml"

Do Case
    Case nTipo == 1
		cComponente := "MF-e"
    Case nTipo == 2
		cComponente := "VFP-e"
EndCase

If Len(aParam) > 0 .And. !Empty(cPath)
	cXML += '<?xml version="1.0" encoding="utf-8" ?>'
	cXML += '<Integrador>'
	cXML += 	'<Identificador>'
	cXML += 		'<Valor>10</Valor>' //Número do Caixa
	cXML += 	'</Identificador>'
	cXML += 	'<Componente Nome="'+cComponente+'">'
	cXML += 		'<Metodo Nome="'+AllTrim(cMetodo)+'">'
	If nTipo == 2
		cXML += 			'<Construtor>'
		cXML += 				'<Parametros>'
		cXML += 					'<Parametro>'
		cXML += 						'<Nome>chaveAcessoValidador</Nome>'
		cXML += 						'<Valor>'+cChvVld+'</Valor>'
		cXML += 					'</Parametro>'
		cXML += 				'</Parametros>'
		cXML += 			'</Construtor>'
	EndIf
	cXML += 			'<Parametros>'
	For nX = 1 To Len(aParam)
		cXML += 				'<Parametro>'
		cXML += 					'<Nome>'+AllTRim(aParam[nX][1])+'</Nome>'
		If !Empty(aParam[nX][2])
			cXML += 					'<Valor>'+aParam[nX][2]+'</Valor>'
		Else
			cXML += 					'<Valor/>'
		EndIf
		cXML += 				'</Parametro>'
	Next nX
	cXML += 			'</Parametros>'
	cXML += 		'</Metodo>'
	cXML += 	'</Componente>'
	cXML += '</Integrador>'
EndIf	

If !Empty(cXML)
	/** Criação do arquivo e abertura dentro da pasta INPUT do Integrador */
	Ljgrvlog("MFE_COMANDO","CRIACAO DO ARQUIVO: " + cPath+cFileNameEx )
	nHandle := FCreate( cPath+cFileNameEx )
	If nHandle <> -1
		FWrite( nHandle, cXML, Len(cXML) )
		FClose( nHandle )
	
		/** Renomeando arquivo para que seja processado pelo integrador */
		Ljgrvlog("MFE_COMANDO","RENOMEANDO O ARQUIVO PARA: " + cPath+cFileReName )
		nHandle := FRename(cPath+cFileNameEx,cPath+cFileReName)
		IF nHandle == -1
			cErro := 'Não foi possível renomear o arquivo para '+cPath+cFileReName+''+STR(FERROR(),4)
		Endif
	Else
		cErro := "Não foi possível criar o arquivo no diretório '"+cPath+"': " + STR(FERROR())
	EndIf
EndIf

If !IsBlind() .And. !Empty(cErro)
	Ljgrvlog("MFE_COMANDO","ERRO NO COMANDO "+cMetodo+": "+cErro+"")
	MsgAlert(cErro)
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LjTratMfe
	Tratamento do retorno do MFe
	@type  Function
	@author bruno.inoue
	@since 12/07/2017
	@version 11.8
	@param 
	@return 
/*/
//-------------------------------------------------------------------
Function LjTratMfe(cMetodo)
Local aFiles		:= {}							//Arquivos da pasta output do integrador
Local nX			:= 0							//contador
Local nHandle		:= 0							
Local cArquivo		:= ""							//nome do arquivo
Local cContArq		:= ""							//conteudo do arquivo
LOCAL nTamanho		:= 0							//tamanho do arquivo
Local oXML   		:= Nil							//ojeto convertido a partir do conteudo do arquivo
Local lRet			:= .F.							//validador
Local cPath			:= SuperGetMV("MV_MFEOUT",,"")  // Default "C:\Integrador\Output\"
Local aRet			:= {}							//Retorno
Local nTentativa	:= 0							//contador
Local cErro			:= ""							//mensagem de erro
Default cMetodo		:= ""

// Tratamento para caso o caminho cPathOut esteja sem "\" no final 
If SubStr(cPath, Len(cPath), 1) <> "\"
   	cPath += "\"
EndIf 

Ljgrvlog("MFE","INICIO TRATAMENTO RETORNO MFE")

If !Empty(cMetodo) .And. !Empty(cPath)
	/** Recupera todos os arquivos processados pelo Integrador */
	For nTentativa := 1 To 6
		aFiles := Directory(cPath+"*.xml")
		If Len(aFiles) > 0
			Ljgrvlog("MFE","Achou os arquivos na tentativa: "  + cValToChar(nTentativa))
			Exit
		Else
			Ljgrvlog("MFE","Tentativa numero: " + cValToChar(nTentativa))
			Sleep( 2000 )
		EndIf
	Next nTentativa	

	If Len(aFiles) > 0
		For nX = 1 To Len(aFiles)
			cArquivo := aFiles[nX,1]
			If File( cPath+cArquivo ) 
				nHandle := FOpen( cPath+cArquivo ) 
				If nHandle < 0 //Erro na abertura do arquivo
					cErro := "Erro ao tentar ler o arquivo: " + cArquivo + Chr(13) + Chr(13) + Str(Ferror(),4) 
				Else
					cContArq := "" //Armazena o conteudo do arquivo nesta variavel
					nTamanho := FSEEK(nHandle,0,2) 
					FSeek( nHandle, 0 )
					FRead( nHandle, @cContArq, nTamanho )
					FClose( nHandle )

					If !Empty(cContArq)
						oXML := TXMLManager():New()
						lRet := oXML:Parse( cContArq )
						If !lRet
							If !Empty( oXML:Error() )
								LjGrvLog( "MFE", "ERRO AO EXECUTAR O METODO PARSE: ", oXML:Error() )
							ElseIf !Empty( oXML:Warning() )
								LjGrvLog( "MFE", "AVISO AO EXECUTAR O METODO PARSE: ", oXML:Warning() )
							EndIf
						Else
							//Retornos
							Do Case
								Case cMetodo == "EnviarPagamento"
									aAdd(aRet,{"IdPagamento",oXML:XPathGetNodeValue( "/Integrador/Resposta/IdPagamento" )})
									aAdd(aRet,{"Mensagem",oXML:XPathGetNodeValue( "/Integrador/Resposta/Mensagem" )})
									aAdd(aRet,{"StatusPagamento",oXML:XPathGetNodeValue( "/Integrador/Resposta/StatusPagamento" )})
								
								Case cMetodo == "VerificarStatusValidador"
									aAdd(aRet,{"CodigoAutorizacao",oXML:XPathGetNodeValue( "/Integrador/Resposta/CodigoAutorizacao" )})
									aAdd(aRet,{"Bin",oXML:XPathGetNodeValue( "/Integrador/Resposta/Bin" )})
									aAdd(aRet,{"DonoCartao",oXML:XPathGetNodeValue( "/Integrador/Resposta/DonoCartao" )})
									aAdd(aRet,{"DataExpiracao",oXML:XPathGetNodeValue( "/Integrador/Resposta/DataExpiracao" )})
									aAdd(aRet,{"InstituicaoFinanceira",oXML:XPathGetNodeValue( "/Integrador/Resposta/InstituicaoFinanceira" )})
									aAdd(aRet,{"Parcelas",oXML:XPathGetNodeValue( "/Integrador/Resposta/Parcelas" )})
									aAdd(aRet,{"UltimosQuatroDigitos",oXML:XPathGetNodeValue( "/Integrador/Resposta/UltimosQuatroDigitos" )})
									aAdd(aRet,{"CodigoPagamento",oXML:XPathGetNodeValue( "/Integrador/Resposta/CodigoPagamento" )})
									aAdd(aRet,{"ValorPagamento",oXML:XPathGetNodeValue( "/Integrador/Resposta/ValorPagamento" )})
									aAdd(aRet,{"IdFila",oXML:XPathGetNodeValue( "/Integrador/Resposta/IdFila" )})
									aAdd(aRet,{"Tipo",oXML:XPathGetNodeValue( "/Integrador/Resposta/Tipo" )})
								
								Case cMetodo $ "EnviarDadosVenda|EnviarStatusPagamento|RespostaFiscal|CancelarUltimaVenda|ConsultarSAT|ConsultarStatusOperacionalMFE|ConsultarNumeroSessao"
									If oXML:XPathHasNode( "/Integrador/Resposta/retorno" )
										If oXML:XPathGetNodeValue( "/Integrador/IntegradorResposta/Codigo" ) == "AP" .Or. nX == Len(aFiles)
											aAdd(aRet,{"retorno",oXML:XPathGetNodeValue( "/Integrador/Resposta/retorno" )})
										EndIf 	
									EndIf 	
							EndCase

						EndIf
					EndIf

				EndIf 
			EndIf
			FERASE(cPath+cArquivo)	
		Next nX	
	Else
		cErro := "Não foi possível obter retorno do Integrador Fiscal. Verifique se está em execução ou reinicie o aplicativo."
	EndIf
EndIf	

If !IsBlind() .And. !Empty(cErro)
	Ljgrvlog("MFE","ERRO NO TRATAMENTO DO RETORNO MFE: " + cErro)
	MsgAlert(cErro)
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjEnvPgto
	Envio de pagamento para o validador fiscal
	Utilizado para TEF e POS
	@type  Function
	@author bruno.inoue
	@since 12/07/2017
	@version 11.8
	@param 
	@return 
/*/
//-------------------------------------------------------------------
Function LjEnvPgto(cValor,lTef,cPOS)
Local aParam	:= {}					//Parametros
Local cMetodo	:= "EnviarPagamento"	//Comando
Local nTipo		:= 2					//VFP-e
Local aRetPgto	:= {}
Local aRet		:= {}
Local cChvReq	:= STFGetStation("CHVREQ",,.F.) 
Local cPDV		:= STFGetStation("PDV",,.F.) 	
Local cSeriePOS	:= "0"
Local aAreaSL2	:= Nil
Local nBaseICM	:= 0
Local lPOS 		:= FindFunction("STFIsPOS") .AND. STFIsPOS() //Pos?
Local lFront	:= IIF(nModulo == 23 .AND. !lPOS,.T.,.F.)  // Front?
Default cValor	:= ""	
Default lTef	:= .F.	

If !lTef
	cSeriePOS := cPOS
EndIf

If lFront
	//Tratamento necessário para caso seja excluido um produto ou adicionado outro e ficar recalculando
	//as informações da nota
	aAreaSL2 := SL2->(GetArea())
	SL2->( DbSetOrder( 1 ))
	SL2->( DbSeek( xFilial("SL2") + SL1->L1_NUM) )
	While SL2->( !Eof() ) .AND. SL2->(xFilial("SL2") + SL1->L1_NUM == SL2->L2_FILIAL+SL2->L2_NUM )
		nBaseICM += SL2->L2_BASEICM
		SL2->( dbSkip() )
	EndDo
	RestArea(aAreaSL2)
Else
	nBaseICM := MaFisRet(Nil,"NF_BASEICM")
EndIf	

aAdd(aParam,{"ChaveRequisicao"				,cChvReq										})   
aAdd(aParam,{"Estabelecimento"				,SubStr(SM0->M0_CGC,0,8)						})
aAdd(aParam,{"SerialPos"					,cSeriePOS										})	
aAdd(aParam,{"Cnpj"							,AllTrim( SM0->M0_CGC )							})
aAdd(aParam,{"IcmsBase"						,cValToChar(nBaseICM)							})
aAdd(aParam,{"ValorTotalVenda"				,Replace(AllTrim(cValor),".",",")				})
aAdd(aParam,{"HabilitarMultiplosPagamentos"	,"true"											})
aAdd(aParam,{"HabilitarControleAntiFraude"	,"false"										})
aAdd(aParam,{"CodigoMoeda"					,"BRL"											})
aAdd(aParam,{"OrigemPagamento"				,"PDV " + AllTrim(cPDV)							})
aAdd(aParam,{"EmitirCupomNFCE"				,"false"										})

LjCmdMFE(nTipo,cMetodo,aParam)
aRetPgto := LjTratMfe(cMetodo)
If Len(aRetPgto) > 0 
	If !Empty(aRetPgto[1][2])
		aAdd(aRet,aRetPgto[1][2])
	EndIf
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjVldPgto
	Validação do pagamento enviado ao MFE - Utilizado para POS
	@type  Function
	@author bruno.inoue
	@since 12/07/2017
	@version 11.8
	@param 
	@return 
/*/
//-------------------------------------------------------------------
Function LjVldPgto(cIdPgtoMfe)
Local aParam	:= {}							//Parametros
Local cMetodo	:= "VerificarStatusValidador"	//Comando
Local nTipo		:= 2							//VFP-e
Local aRet		:= ""

aAdd(aParam,{"idFila"	, cIdPgtoMfe				}) /*pegar retorno do TEF ou POS "1671922" */
aAdd(aParam,{"Cnpj"		, AllTrim( SM0->M0_CGC )	})

LjCmdMFE(nTipo,cMetodo,aParam)
aRet := LjTratMfe(cMetodo)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjEnvVenda
	Comando para finalização da venda no MFe
	@type  Function
	@author bruno.inoue
	@since 12/07/2017
	@version 11.8
	@param 
	@return 
/*/
//-------------------------------------------------------------------
Function LjEnvVenda(cXml,cSessao)
Local aParam	:= {}								//Parametros
Local cMetodo	:= "EnviarDadosVenda"				//Comando
Local nTipo		:= 1								//MF-e
Local cPass		:= STFGetStation("CODSAT",,.F.) 	//Retorna o código de ativação do SAT

cSessao	:= LJSATnSessao()

aAdd(aParam,{"numeroSessao"			,cSessao					})
aAdd(aParam,{"codigoDeAtivacao"		,cPass						})
aAdd(aParam,{"dadosVenda"			,"<![CDATA[" +cXml+ "]]>"	})

LjCmdMFE(nTipo,cMetodo,aParam)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LjEnvStPgto
	Comando para enviar status do pagamento realizado no TEF para o MFE
	@type  Function
	@author bruno.inoue
	@since 12/07/2017
	@version 11.8
	@param 
	@return 
/*/
//-------------------------------------------------------------------
Function LjEnvStPgto(aRetCartao)
Local aParam		:= {}						//Parametros
Local cMetodo		:= "EnviarStatusPagamento"	//Comando
Local nTipo			:= 2						//VFP-e
Local nX			:= 0
Default	aRetCartao	:= {}

For nx := 1 to Len(aRetCartao)

	aAdd(aParam,{"CodigoAutorizacao"				,oTef:aRetCartao[nX]:cAutoriza				})
	aAdd(aParam,{"Bin"								,oTef:aRetCartao[nX]:cPosCart				})
	aAdd(aParam,{"DonoCartao"						,oTEF:aRetCartao[nX]:cTitular				}) 
	aAdd(aParam,{"DataExpiracao"					,oTef:aRetCartao[nX]:cVencCartao			})
	aAdd(aParam,{"InstituicaoFinanceira"			,oTef:aRetCartao[nX]:cDescRede				})
	aAdd(aParam,{"Parcelas"							,cValToChar(oTef:aRetCartao[nX]:nParcelas)	})
	aAdd(aParam,{"CodigoPagamento"					,oTef:aRetCartao[nX]:cNsuSitef				})
	aAdd(aParam,{"ValorPagamento"					,cValToChar(oTef:aRetCartao[nX]:nVlrTrans)	})
	aAdd(aParam,{"IdFila"							,"12334"									})
	aAdd(aParam,{"Tipo"								,oTef:aRetCartao[nX]:cDescAdm				})
	aAdd(aParam,{"UltimosQuatroDigitos"				,oTEF:aRetCartao[nX]:cPosFinCar				})

	LjCmdMFE(nTipo,cMetodo,aParam)
	LjTratMfe(cMetodo)
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjRspFisc
	Comando de resposta fiscal enviado ao integrador fiscal para confirmar que
	a venda foi realizada após o pagamento do TEF ou POS
	@type  Function
	@author bruno.inoue
	@since 15/07/2017
	@version 11.8
	@param 
	@return 
/*/
//------------------------------------------------------------------- 
Function LjRspFisc(aRetCartao,lVendPOS,aIdPgtoMfe)
Local aParam		:= {}						//Parametros
Local cMetodo		:= "RespostaFiscal"			//Comando
Local nTipo			:= 2						//VFP-e
Local nX			:= 0						//Contador
Local aRespFisc		:= {}						//Retorno do envio da Resposta Fiscal
Local cNsuSitef		:= ""						//Nsu do SITEF
Local lPOS 			:= FindFunction("STFIsPOS") .AND. STFIsPOS() //Pos?
Local cIdFila		:= ""						//Id da fila do processamendo no MFe
Local cChaveAcesso	:= ""						//Chave de acesso do MFe
Local cNsu			:= ""						//Nsu gerado pelo validador fiscal
Local cNumAprov		:= ""						//Numero de aprovação do sitef
Local cBandeira		:= ""						//bandeira do cartão
Local cAdquirente	:= ""						//Cliente
Local cCnpj			:= ""						//CNPJ do estabelecimento
Local cImpFiscal	:= ""						//texto de impressão do cupom fiscal 
Local cNumDoc		:= ""						//numero do doc Sitef
Local nTrans		:= 0						//Numero de transações

Default lVendPOS	:= .F.
Default aRetCartao	:= ""
Default aIdPgtoMfe	:= {}

If lPos
	nTrans := Len(aRetCartao:oConfig:oCCCD:oTrans:aColecao)
Else	
	nTrans := Len(aRetCartao)
EndIf

For nX := 1 to nTrans
	If lVendPOS
		cIdFila 		:= aRetCartao[nX][5][aScan(aRetCartao[1][5],{|x| UPPER(x[1]) == UPPER("idFila") })][2]
		cNsu 			:= aRetCartao[nX][5][aScan(aRetCartao[1][5],{|x| UPPER(x[1]) == UPPER("idFila") })][2]
		cNumAprov 		:= aRetCartao[nX][5][aScan(aRetCartao[1][5],{|x| UPPER(x[1]) == UPPER("CodigoAutorizacao") })][2]
		cBandeira 		:= aRetCartao[nX][5][aScan(aRetCartao[1][5],{|x| UPPER(x[1]) == UPPER("Tipo") })][2]	
		cAdquirente 	:= aRetCartao[nX][5][aScan(aRetCartao[1][5],{|x| UPPER(x[1]) == UPPER("DonoCartao") })][2]
		cNsuSitef 		:= aRetCartao[nX][5][aScan(aRetCartao[1][5],{|x| UPPER(x[1]) == UPPER("CodigoPagamento") })][2]
		cNumDoc 		:= cNsuSitef
	Else
		If Len(aIdPgtoMfe)	> 0 
			cIdFila 		:= aIdPgtoMfe[nX][1]
			cNsu 			:= aIdPgtoMfe[nX][1]
		EndIf 
		cNumDoc 		:= cNsuSitef
		cAdquirente 	:= Posicione("SA1",1,xFilial("SA1") + SL1->L1_CLIENTE,"SA1->A1_NOME")
		If lPOS
			cNumAprov 		:= AllTrim(Posicione("SL4",3,xFilial("SL4") + dToS(Date()) + aRetCartao:oConfig:oCCCD:oTrans:aColecao[nX][1],"SL4->L4_AUTORIZ"))
			cBandeira 		:= AllTrim(Posicione("SL4",3,xFilial("SL4") + dToS(Date()) + aRetCartao:oConfig:oCCCD:oTrans:aColecao[nX][1],"SL4->L4_INSTITU"))
			cNsuSitef 		:= aRetCartao:oConfig:oCCCD:oTrans:aColecao[nX][1]
		Else	
			cNumAprov 		:= aRetCartao[nX]:cAutoriza
			cBandeira 		:= aRetCartao[nX]:cDescAdm
			cNsuSitef 		:= aRetCartao[nX]:cNsuSitef
		EndIf	
	EndIf	

	cChaveAcesso 	:= "00001"
	cCnpj 			:= AllTrim( SM0->M0_CGC )
	cImpFiscal 		:= "<![CDATA[" +LjRmvChEs(cLastSat)+ "]]>"

	aAdd(aParam,{"idFila"				, cIdFila				})
	aAdd(aParam,{"ChaveAcesso"			, cChaveAcesso			})
	aAdd(aParam,{"Nsu"					, cNsu					}) 
	aAdd(aParam,{"NumerodeAprovacao"	, cNumAprov				})
	aAdd(aParam,{"Bandeira"				, cBandeira				})
	aAdd(aParam,{"Adquirente"			, cAdquirente			})
	aAdd(aParam,{"Cnpj"					, cCnpj					})
	aAdd(aParam,{"ImpressaoFiscal"		, cImpFiscal			})
	aAdd(aParam,{"NumeroDocumento"		, LjRmvChEs(cNumDoc)	})		

	LjCmdMFE(nTipo,cMetodo,aParam)
	aRespFisc := LjTratMfe(cMetodo)
	aParam := {}

	If Len(aRespFisc) > 0 
		//Atualiza SL4 com a resposta fiscal		
		SL4->(DbSetOrder(1))
		If SL4->(ColumnPos("L4_IDRSPFI")) > 0 .And. SL4->(DbSeek(xFilial("SL4") + SL1->L1_NUM)) 
			While !( SL4->( EOF() ) ) .And. SL4->L4_NUM == SL1->L1_NUM
				If AllTrim(SL4->L4_FORMA) $ "CC|CD" .And. AllTrim(SL4->L4_NSUTEF) == cNsuSitef
					RECLOCK("SL4", .F.)
					SL4->L4_IDRSPFI := aRespFisc[1][2]
					MSUNLOCK()
					Exit
				Endif
				SL4->( DbSkip() )
			End			
		EndIf
	EndIf	

Next nX

cLastSat := ""

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LjEnvCanc
	Comando de cancelamento de venda no MFe
	@type  Function
	@author bruno.inoue
	@since 16/07/2017
	@version 11.8
	@param 
	@return 
/*/
//-------------------------------------------------------------------
Function LjEnvCanc(cChave,cXML)
Local aParam	:= {}								//Parametros
Local cMetodo	:= "CancelarUltimaVenda"			//Comando
Local nTipo		:= 1								//MF-e
Local cPass		:= STFGetStation("CODSAT",,.F.) 	//Retorna o código de ativação do SAT

aAdd(aParam,{"numeroSessao"			,LJSATnSessao()				})
aAdd(aParam,{"codigoDeAtivacao"		,cPass						})
aAdd(aParam,{"chave"				,cChave						})
aAdd(aParam,{"dadosCancelamento"	,"<![CDATA[" +cXml+ "]]>"	})

LjCmdMFE(nTipo,cMetodo,aParam)
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LjVrfMFE
	Comando consulta Sessao MFE
	@type  Function
	@author bruno.inoue
	@since 19/07/2017
	@version 11.8
	@param 
	@return
/*/
//-------------------------------------------------------------------
Function LjVrfMFE()
Local aParam	:= {}								//Parametros
Local cMetodo	:= "ConsultarMFe"					//Comando
Local nTipo		:= 1								//MF-e

aAdd(aParam,{"numeroSessao"			,LJSATnSessao()				})

LjCmdMFE(nTipo,cMetodo,aParam)
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LjStatusOP
	Comando Status Operacional para o MFe
	@type  Function
	@author bruno.inoue
	@since 20/07/2017
	@version 11.8
	@param 
	@return 
/*/
//-------------------------------------------------------------------
Function LjStatusOP()
Local aParam	:= {}								//Parametros
Local cMetodo	:= "ConsultarStatusOperacional"		//Comando
Local nTipo		:= 1								//MF-e
Local cPass		:= STFGetStation("CODSAT",,.F.) 	//Retorna o código de ativação do SAT

aAdd(aParam,{"numeroSessao"			,LJSATnSessao()		})
aAdd(aParam,{"codigoDeAtivacao"		,cPass				})

LjCmdMFE(nTipo,cMetodo,aParam)
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LjConsSess
	Comando de consulta sessao para o MFe
	@type  Function
	@author bruno.inoue
	@since 20/07/2017
	@version 11.8
	@param 
	@return 
/*/
//-------------------------------------------------------------------
Function LjConsSess(cCod)
Local aParam	:= {}								//Parametros
Local cMetodo	:= "ConsultarNumeroSessao"			//Comando
Local nTipo		:= 1								//MF-e
Local cPass		:= STFGetStation("CODSAT",,.F.) 	//Retorna o código de ativação do SAT

aAdd(aParam,{"numeroSessao"			,LJSATnSessao()		})
aAdd(aParam,{"codigoDeAtivacao"		,cPass				})
aAdd(aParam,{"cNumeroDeSessao"		,cCod				})

LjCmdMFE(nTipo,cMetodo,aParam)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjUsaMfe
	Retorna se utiliza MF-e
	@type  Function
	@author bruno.inoue
	@since 21/07/2017
	@version 11.8
/*/
//-------------------------------------------------------------------
Function LjUsaMfe()
Return lMFE

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCleanFile
	Limpa os aruqivos da pasta de utilização do Integrador fiscal para que não ocorra erros 
	na leitura dos arquivos
	@type  Function
	@author bruno.inoue
	@since 27/07/2017
	@version 11.8
	@param 
	@return
/*/
//-------------------------------------------------------------------
Function LjCleanFile()
Local cPathIn	:= SuperGetMV("MV_MFEPUT",,"")		//Caminho da pasta Input do Integrador Fiscal
Local cPathOut	:= SuperGetMV("MV_MFEOUT",,"")		//Caminho da pasta Output do Integrador Fiscal
Local aFiles	:= {}								//Arquivos encontrados na pasta
Local cArquivo	:= ""								//Nome do arquivo
Local nX		:= 0								//Contador

// Tratamento para caso o caminho cPathIn esteja sem "\" no final 
If SubStr(cPathIn, Len(cPathIn), 1) <> "\"
   	cPathIn += "\"
EndIf 

//Input
If !Empty(cPathIn)
	aFiles := Directory(cPathIn+"*.*")
	If Len(aFiles) > 0
		For nX := 1 To Len(aFiles)
			cArquivo := aFiles[nX,1]		
			If File( cPathIn+cArquivo ) 
				FERASE(cPathIn+cArquivo)
			EndIf
		Next nX
	EndIf
EndIf

// Tratamento para caso o caminho cPathOut esteja sem "\" no final 
If SubStr(cPathOut, Len(cPathOut), 1) <> "\"
   	cPathOut += "\"
EndIf 

//Output
If !Empty(cPathOut)
	aFiles := Directory(cPathOut+"*.*")
	If Len(aFiles) > 0
		For nX := 1 To Len(aFiles)
			cArquivo := aFiles[nX,1]		
			If File( cPathOut+cArquivo ) 
				FERASE(cPathOut+cArquivo)
			EndIf
		Next nX
	EndIf
EndIf	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSiglaSat
	Retorna a sigla do equipamento que esta sendo utilizado 
	@type  Function
	@author bruno.inoue	
	@since 11/08/2017
	@version 11.80
	@param 
	@return cRet
/*/
//-------------------------------------------------------------------
Function LjSiglaSat()
Local cRet		:= ""
Local cEstCob	:= AllTrim(SM0->M0_ESTCOB)

Do Case
	Case cEstCob == "CE"
		cRet := "MFe"
	Otherwise
		cRet := "SAT"
EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjGetIdeSat
	Retorna a String de identificação do SAT
	@type  Function
	@author fabiana.silva
	@since 02/01/2017
	@version 12.1.17
	@param cSatTest - Variável MV_SATTEST
	@return cXML - XML de Identificação do SAT
/*/
//-------------------------------------------------------------------
Static Function LjGetIdeSat(cSatTest)
Local cXML			:= ""
Local lTstSAT		:= .F.
Local cCNPJ_SW		:= ""
Local cSign_AC		:= ""
Local aIniSession	:= {}
Local cIniFile		:= ""
Local lAutomato		:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local cChaveSat		:= ""

LjGrvLog("SAT"," LjGetIdeSat - Assinatura SAT - Inicio - cSatTest ", cSatTest, .T.)

//Se for de teste as informações fixas são da DIMEP
If !Empty(cSatTest)

	If !lAutomato
		cIniFile := GetClientDir() + "sigaloja.ini"
	Else
		cIniFile := "\sigaloja.ini"
	Endif
		
    lTstSAT := GetPvProfString("logdll", "SAT", "0" , cIniFile) == "1" 
    aIniSession := GetINISessions(  cIniFile )
    If lTstSAT .AND. Len(aIniSession) .AND.  aScan(aIniSession, { |k| k == "SAT"}) > 0
    	cCNPJ_SW := GetPvProfString("SAT", "IDE_CNPJ", "" , cIniFile)		
    	cSign_AC := LjGetIniKey("IDE_SIGNAC", "", cIniFile)//IDE_signAC 
		LjGrvLog("SAT"," Assinatura SAT", cSign_AC)
    EndIf
	LjGrvLog( "SAT", "Utiliza o SAT de testes - MV_SATTEST: ", cSatTest )
	If cFabSat = NIL
		If lIsPos = NIL
			lIsPos := STFIsPOS()
		EndIf
		If !lIsPos
			cFabSat := LjGetStation("FABSAT")
		Else	
			cFabSat := STFGetStation("FABSAT")
		EndIf
	EndIf

	Do Case
		Case !Empty(cCNPJ_SW) .AND. !Empty(cSign_AC)
			LjGrvLog("SAT"," Emulador 01 - <signAC>:", cSign_AC)
			cXML	+= "<CNPJ>"+cCNPJ_SW+"</CNPJ>" 		//CNPJ Software House
			cXML	+= "<signAC>"+cSign_AC +"</signAC>" //Assinatura de (CNPJ Software House + CNPJ Emitente) que gerou o CF-e	
			
		Case Upper(cFabSat) == "EMULADOR"
			LjGrvLog("SAT"," Emulador 02 - <signAC>:", Replicate("1", 344))
			cXML	+= "<CNPJ>11111111111111</CNPJ>" //CNPJ Software House
			cXML	+= "<signAC>"+Replicate("1", 344) +"</signAC>" //Assinatura de (CNPJ Software House + CNPJ Emitente) que gerou o CF-e	
		Case lMFE .AND. Upper(AllTrim(cFabSat)) == "ELGIN"
			cXML	+= "<CNPJ>08490295000133</CNPJ>" //CNPJ Software House
			cXML	+= "<signAC>MD2Nof/O0tQMPKiYeeAydSjYt7YV9kU0nWKZGXHVdYIzR2W9Z6tgXni/Y5bnjmUAk8MkqlBJIiOOIskKCjJ086k7vAP0EU5cBRYj/nzHU"+;
						"iRdu9AVD7WRfVs00BDyb5fsnnKg7gAXXH6SBgCxG9yjAkxJ0l2E2idsWBAJ5peQEBZqtHytRUC+FLaSfd3+66QNxIBlDwQIRzUGPaU6fvErVDSfMU"+;
						"f8WpkwnPz36fCQnyLypqe/5mbox9pt3RCbbXcYqnR/4poYGr9M9Kymj4/PyX9xGeiXwbgzOOHNIU5M/aAs0rulXz948bZla0eXABgEcp6mDkTzweLPZTbmOhX+eA==</signAC>" //Assinatura de (CNPJ Software House + CNPJ Emitente) que gerou o CF-e	*/
						
		OtherWise
			cXML	+= "<CNPJ>16716114000172</CNPJ>" //CNPJ Software House
			cXML	+= "<signAC>SGR-SAT SISTEMA DE GESTAO E RETAGUARDA DO SAT</signAC>" //Assinatura de (CNPJ Software House + CNPJ Emitente) que gerou o CF-e
	EndCase
Else
	LjGrvLog( "SAT", "Utiliza o SAT padrao " )
	cXML	+= "<CNPJ>53113791000122</CNPJ>" //CNPJ Software House
	
	If ExistFunc("LjGetChSat")		

		cChaveSat := LjGetChSat()

		LjGrvLog("SAT"," Assinatura 01 - <signAC>:", cChaveSat )

		If Empty(cChaveSat)
			LjGrvLog("SAT"," LjGetChSat retornou vazio", )
			aRetChvSAT :=  LjGetSig()
			cChaveSat := aRetChvSAT[1]
			LjGrvLog("SAT"," Buscando a chave via aRetChSat", cChaveSat)
		EndIf

		cXML	+= "<signAC>" + cChaveSat + "</signAC>" //Assinatura de (CNPJ Softwcxare House + CNPJ Emitente) que gerou o CF-e
		LjGrvLog( "SAT", "Assinatura ", cChaveSat )
	Else
		LjGrvLog("SAT"," Assinatura 02 - <signAC>: Vazio", )
		cXML	+= "<signAC></signAC>" //Assinatura de (CNPJ Software House + CNPJ Emitente) que gerou o CF-e
		LjGrvLog( "SAT", "Tag signAC em branco ", )	
	EndIf
	
EndIf

LjGrvLog("SAT","LjGetIdeSat - Fim", )

Return cXML

//-------------------------------------------------------------------
/*/{Protheus.doc} LjGetIniKey
	Retorna o valor da String da chave do arquivo Arquivo INI
	Importante - Essa função não valida a seção, ou seja, caso existam duas chaves em 
	seções distintas, a primeira encontrada será retornada
	@type  Function
	@author fabiana.silva
	@since 02/01/2017
	@version 12.1.17
	@param cKey - Chave
			cDefValue - Valor Default
			cFile - Arquivo INI
	@return cDefValue - Valor Default
/*/
//-------------------------------------------------------------------
Static Function LjGetIniKey(cKey, cDefValue, cFile)
Local cLine := ""
Local nPos := 0
  
	FT_FUSE( cFile )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Avanco para a primeira linha.                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FT_FGOTOP()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrego todos os registros do TXT para o aCols.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do While !FT_FEOF()

		cLine := FT_FREADLN() //Leitura da linha
		If At(Upper(cKey), Upper(cLine)) > 0
			cLine := Substr(cLine, Len(cKey)+1)
			If (nPos := At("=", cLine) ) > 0
				cLine :=  Substr(cLine, nPos+1)
				Do While Len(cLine) > 0 .AND. Left(cLine, 1) == space(1)
					cLine :=  Substr(cLine, 2)
				Enddo
				cDefValue := cLine
			EndIf
			
			Exit
		EndIf		
		FT_FSKIP()
	EndDo
	FT_FUSE()

Return cDefValue

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSatNumSale
Retorna os dados da última venda SAT
@param   	
@author  	Varejo
@version 	P11.8
@since   	07/03/2016
@return  	Array com os dados da ultima venda  {cDoc, cSerieSAT, cChave}
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function LJSatNumSale()

Local aRet		:= {} 							//Retorno do SAT
Local cPass		:= STFGetStation("CODSAT",,.F.)	//Retorna o código de ativação do SAT
Local aRetDoc	:= {"", "", ""} 				//Retorno
Local cDoc	 	:= "" 							//Doc 
Local cSerie 	:= "" 							//Serie
Local cKeySAT 	:= "" 							//Chave do SAT]

LjGrvLog( "SAT", "Processo de Numero da venda - Inicio " )
		
If lMFE .And. lIntegrador
	aRet := LjStatusOP()
Else
	aRet := LJSATComando({"12","ConsultarStatusOperacional",LJSATnSessao(), cPass})
EndIf

LjGrvLog( "SAT", "Tamanho do array retornado do comando enviado ao SAT - Len(aRet): ", Len(aRet))

If Len(aRet) > 20  //retorno de sucesso
	
	cKeySAT := aRet[21] //xml

	If !Empty(cKeySAT)
		//instancia um objeto da classe TXML Manager
		aRetDoc := LjSatTrChv(cKeySAT)
		cDoc :=  aRetDoc[06]
		cSerie := aRetDoc[05]
		aRetDoc := { cDoc, cSerie, cKeySAT}
		
	Else
		LjGrvLog("SAT","Sem retorno valido para dados da ultima venda")
	EndIf

EndIf

aRetDoc := { cDoc, cSerie, cKeySAT}

Return aRetDoc

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSatTrChv
Retorna um array com os dados do SAT
@param   	cKeySAT - Chave do SAT
@author  	Varejo
@version 	P11.8
@since   	07/03/2016
@return  	Array com os dados da chave
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function LjSatTrChv(cKeySAT)
Local aCampos 		:= {2, 4, 14, 2, 9, 6, 6, 1} //Array com os campos da Chave
Local nI 			:= 0 //Contador
Local nTamCampos 	:= Len(aCampos) //Tamanho dos campos da chave
Local aChv 			:= {} //Dados da Chave
Local cValor 		:= "" //Valor subtraído

Default cKeySAT := ""

/* Chave do SAT
cUF - 2 dígitos 1 ;
AAMM – 4 dígitos 2; 6
CNPJ – 14 dígitos 3; 20
mod – 2 dígitos 4; 22
nserieSAT – 9 dígitos 5; 31
nCF – 6 dígitos 6 ; 37
cNF – 6 dígitos 7 ; 43
cDV – 1 dígito 8 ; 44
*/
aChv := Array(nTamCampos)
aFill(aChv, "")

If !Empty(cKeySAT)
	For nI := 1 to nTamCampos
		cValor := Left(cKeySat, aCampos[nI])
		cKeySAT := Substr(cKeySAT, aCampos[nI]+1)
		aChv[nI] := cValor
	Next
EndIf

Return aChv

//-------------------------------------------------------------------
/*/{Protheus.doc} LjUsaIntgr
Retorna se utiliza Integrador Fiscal MFe

@param   	
@author  	eduardo.sales
@version 	P12
@since   	14/08/2019
@return		lIntegrador - Se utiliza o integrador fiscal Mfe
/*/
//-------------------------------------------------------------------
Function LjUsaIntgr()
Return lIntegrador

//-------------------------------------------------------------------
/*/{Protheus.doc} LjAskEmail
Função para perguntar o e-mail remetente do comrpovante SAT

@author  	eduardo.sales
@version 	P12
@since   	22/05/2020
@return		cRemetente - E-mail cadastrado na SA1 ou preenchido na tela
/*/
//-------------------------------------------------------------------
Static Function LjAskEmail()

Local cRemetente	:= ""			// Remetente do e-mail
Local lPos			:= STFIsPOS()	// Pos?
Local cCliente 		:= ""			// Cliente
Local cLoja 		:= ""			// Loja
Local aAreaSA1 		:= Nil
Local oDlg 			:= Nil
Local oRemetente	:= Nil
Local oExecute		:= Nil			

If lPos
	cCliente := STDGPBasket("SL1","L1_CGCCLI")
	cLoja := STDGPBasket("SL1","L1_LOJA")
Else
	cCliente := SL1->L1_CLIENTE
	cLoja := SL1->L1_LOJA
EndIf	

aAreaSA1 := SA1->(GetArea())

DbSelectArea("SA1")
SA1->(DbSetOrder(1))	// A1_FILIAL + A1_COD + A1_LOJA
SA1->(DbSeek(xFilial("SA1") + cCliente + cLoja))

cRemetente := AllTrim(SA1->A1_EMAIL)
If Empty(cRemetente)
	cRemetente := Space(TamSx3("A1_EMAIL")[1])
EndIf

RestArea(aAreaSA1)

DEFINE MSDIALOG oDlg TITLE "E-mail Remetente" FROM 000, 000  TO 90, 350 PIXEL

@ 05, 05 TO 28, 170 LABEL "Remetente" OF oDlg  PIXEL
@ 12, 10 MSGET oRemetente VAR cRemetente SIZE 155, 10 OF oDlg RIGHT PIXEL	
@ 30, 135 BUTTON oExecute PROMPT "Confirmar" SIZE 036, 012 OF oDlg PIXEL ACTION (cRemetente := oRemetente:cText, oDlg:End()) // "Executar"

oDlg:lEscClose := .F.

ACTIVATE MSDIALOG oDlg CENTERED

Return cRemetente

//-------------------------------------------------------------------
/*/{Protheus.doc} LjWriteHtm
Função para gravar o anexo do e-mail.

@author  	eduardo.sales
@version 	P12
@since   	22/05/2020
@return		
/*/
//-------------------------------------------------------------------
Static Function LjWriteHtm(cBuffer, cCaminho)

Local nHandle	:= 1

nHandle := FCreate(cCaminho)
If nHandle > 0
	FWrite(nHandle, cBuffer)
	FClose(nHandle)

	LjGrvLog( "SAT", "Arquivo html gerado com sucesso." )
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCpEmail
Função responsável pelo envio do Comprovante SAT por e-mail.

@param   	cTexto - HTML com as informações do cupom virtual
@param   	cRemetente - Remetente do e-mail
@author  	eduardo.sales
@version 	P12
@since   	22/05/2020
@return		lResult - Retorno se o e-mail foi enviado com sucesso
/*/
//-------------------------------------------------------------------
Static Function LjCpEmail(cRemetente)

Local aArea     := GetArea()
Local cEmailTo  := ""									// E-mail de destino
Local lResult   := .F.									// Se a conexao com o SMPT esta ok
Local cError    := ""									// String de erro
Local lRet	    := .F.									// Se tem autorizacao para o envio de e-mail
Local cServer   := AllTrim(SuperGetMv("MV_RELSERV"))	// Nome do servidor de envio de e-mail - Ex.: smtp.ig.com.br ou 200.181.100.51
Local cConta    := AllTrim(SuperGetMv("MV_RELACNT"))	// Conta a ser utilizada no envio de e-mail - Ex.: fuladetal@fulano.com.br
Local cPsw      := AllTrim(SuperGetMv("MV_RELPSW"))		// Senha da conta de e-mail;
Local lRelauth  := SuperGetMv("MV_RELAUTH",, .F.)		// Determina se o servidor exige autentica?o
Local cCtaAut   := AllTrim(SuperGetMv("MV_RELAUSR")) 	// Usu?io para autentica?o no servidor de e-mail (caso servidor assim exigir);
Local cApsw     := AllTrim(SuperGetMv("MV_RELAPSW"))	// Senha para autentica?o no servidor de e-mail (caso servidor assim exigir).
Local cFrom	    := AllTrim(SuperGetMv("MV_RELFROM"))	// E-mail utilizado no campo FROM no envio do e-mail;

cEmailTo := cRemetente
cAssunto := "Comprovante SAT"
cMensagem := "Comprovante SAT em anexo. Faça o Download para melhor visualização."
cAttach := "\system\ComprovanteSat.html"

CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cPsw RESULT lResult

// Se a conexao com o SMPT esta ok
If lResult
	
	// Se existe autenticacao para envio valida pela funcao MAILAUTH
	If lRelauth
		lRet := Mailauth( cCtaAut, cApsw )
	Else
		lRet := .T.
	Endif
	
	If lRet
		SEND MAIL; 
		FROM 		cFrom;
		TO      	cEmailTo;
		SUBJECT 	cAssunto;
		BODY    	cMensagem;
		ATTACHMENT  cAttach;
		RESULT 		lResult
		
		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			If !IsBlind()
				Help( " ", 1, "01 - " + "ATENCAO", , cError + " " + cEmailTo, 4, 5 )
			Else
				ApMsgInfo( "01 - " + "ATENCAO" + " " + cError + " " + cEmailTo )
			EndIf
		Endif
		
	Else
		GET MAIL ERROR cError
		If !IsBlind()
			Help( " ", 1, "02 - " + "Autenticação", , cError, 4, 5 ) // "Autenticacao"
		Else
			ApMsgInfo("02 - " + "Erro de Autenticação" + " " + "Verifique a conta e a senha para envio de e-mail.")
		EndIf
	Endif
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	If !IsBlind()
		Help( " ", 1, "03 - " + "ATENCAO", , cError, 4, 5 )
	Else
		ApMsgInfo( "03 - " + "ATENCAO" + " " + cError )
	EndIf
Endif
 
RestArea( aArea )

Return lResult


//-------------------------------------------------------------------
/*/{Protheus.doc} LjRstSat
Reinicializa todas as variáveis Static deste fonte

@type	function
@param   	nil
@author  	marisa.cruz
@version 	P12
@since   	05/06/2020
@return		nil
/*/
//-------------------------------------------------------------------
Function LjRstSat()

//Variáveis Static
cGetIdEnt	:= Nil 					// Codigo da entidade no TSS
oSAT		:= Nil					// Objeto SAT
aSATTrib	:= {}					// Tributação produto SAT
aSATImp		:= {}					// Lei da Transparencia SAT
cFabSat		:= NIl					// Fabricante do SAT
lUseSAT 	:= Nil
lIsPOS		:= NIL					// TotvsPDV?
aTotVenda	:= {0,0}				// [1] - Total da venda Fiscal [2] - Total da venda nao fiscal
dDtComSFZ	:= CtoD("  /  /    ")  	// Data da ultima Comunicação com o SEFAZ 
aCNS		:= {} 
aSATSO		:= nil					// Status Operacional do SAT
cCondIni	:= ""					// Tag abertura para texto condensado 
cCondFim	:= ""					// Tag fechamento para texto condensado
nLarCup		:= 0					// Largura do cupom
lShowMsg	:= .T.					// Validação para exibir a mensagem de validação do Layout SAT somente a primeira vez que acessar o sistema
aValItCP	:= {}					// Array com valor por item a ser enviado no XML de Complementar de ICMS
nValTotCP	:= 0					// Valor total a ser enviado no XML de Complementar de ICMS
lMFE		:= .F.
cLastSat	:= ""					//Ultimo layout de impressao do SAT executado
cSiglaSat	:= LjSiglaSat()			//Retorna sigla do equipamento que esta sendo utilizado
lIntegrador	:= .T.
nEnvEmail	:= 0					//Indica se irá enviar o comprovante SAT por e-mail

Return nil
