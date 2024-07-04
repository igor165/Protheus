#INCLUDE "PROTHEUS.CH"
#INCLUDE "GCPAXNET.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPHSMInit
Funcao do Compras Publicas responsavel por inicializar o TOKEN HSM
do ComprasNET

@author Cesar Bianchi	
@return lRet - Retorno com status da operacao
@since 15/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCPHSMInit(cTokenPsw,cCertOri,cKeyOri)
	Local lRet 		:= .F.
	Local nSSL2 		:= 0
	Local nSSL3 		:= 0
	Local nTLS1 		:= 1
	Local nHSM  		:= 1
	Local lIsClient 	:= .T.
	Local nInitHSM 	:= 0
	Local cDLL 		:= GetHsmDLL()
	Local aDevices	:= {}
	Local aObjs		:= {}
	Private aDescDev	:= {}
	Private nSlot		:= 0
	Private cCert 	:= ""
	Private cKey  	:= ""
	Private cCACert 	:= GCPGetCert('cahomolog.pem',GetTempPath(.T.))
	
	//Valida os requisitos minimos antes de iniciar o token
	If GCPHSMPrem() .And. !Empty(cCACert) 
	
		//1* Define os parametos de SSLConfigure no Client
		HTTPSSLClient( nSSL2, nSSL3, nTLS1, cTokenPsw, "DUMMY", "DUMMY",  nHSM, lIsClient, 1, Nil, Nil, cCACert )
		
		//2* Inicializo o HSM (Token)
		If !Empty(cDLL)
			nInitHSM := HSMInitialize(cDLL,lIsClient)
			If nInitHSM > 0
				//3* Busca a lista de HSMs Plugados no Client
				aDevices := HSMSlotList(lIsClient)
				//VarInfo('aDevices',aDevices)
				If Len(aDevices) > 0 .and. GCPValidDevice(aDevices)
					
					//4* Exibe uma dialog ao usuario, para escolha do TOKEN, Chave Publica e Certificado a serem utilizados
					If GcpSetHsmSlot(cTokenPsw)
					
						//5* - Identifico qual o Certificado + KEY a ser usada
						If nSlot > -1 
							aObjs := HSMObjList(nSlot,cTokenPsw,lIsClient)
							//VarInfo('aObjs',aObjs)
							If  ValType(aObjs) == 'A' .And. len(aObjs) > 0 .and. GCPValidObjs(aObjs)
								
								//6* Por fim, executo novamente a funcao de HTTPSSLClient, agora com certificado e chaves validos
								HTTPSSLClient( nSSL2, nSSL3, nTLS1, cTokenPsw, cCert, cKey,  nHSM, lIsClient, 1, Nil, Nil, cCACert )
								lRet := .T.
								
								cCertOri := cCert
								cKeyOri := cKey
								Conout('[GCP][INT][INFO] HSM ENABLED!')
							Else
								Aviso(STR0001,STR0002,{STR0003}) //"Atenção" ## 'Erro indeterminado: Não há um slot valido a ser utilizado no TOKEN escolhido'
								lRet := .F.
							EndIf
						Else
							Aviso(STR0001,STR0002,{STR0003}) //"Atenção" ## 'Erro indeterminado: Não há um slot valido a ser utilizado no TOKEN escolhido'
							lRet := .F.
						EndIf
					Else
						MsgStop(STR0004)
						lRet := .F.
					EndIf
				Else
					Aviso(STR0001, STR0005,{STR0006}) //"Atenção" ## 'Nenhum dispositivo de hardware do tipo HSM (Token SSL) foi detectado nesta estação de trabalho. Por favor, conecte um dispositivo válido na porta USB da estação e tente novamente.' 
					lRet := .F.
				EndIf
			Else
				MsgStop(STR0007 + cDLL)//'Não foi possivel inicializar o Token utilizando a DLL '
				lRet := .F.
			Endif
		Else
			MsgStop(STR0008) //'Não foi estabelecer comunicação com uma DLL válida. Contate o administrador do sistema'
			lRet := .F.	
		EndIf
	Else
		//Nao faz nada mesmo, pois nao atende os requisitos minimos obrigatorios
		lRet := .F.
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPHSMPrem
Funcao do Compras Publicas responsavel realizar as validações minimas
necessarias a funcionalidade do ComprasNET

@author Cesar Bianchi	
@return lRet - Retorno com status da operacao
@since 15/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCPHSMPrem()
	Local lRet := .F.
	Local cBuild := alltrim(GetBuild())
	
	//1* Valida se o binario é a referencia minima de 20160315
	If STOD(Substr(cBuild,14,8)) >= STOD("20160314")  
		
		//2* - Valida se o SmartClient é do tipo DESTOP + WINDOWS
		If GetRemoteType() == 1
			lRet := .T.
		Else
			MsgStop(STR0009) //'Recurso disponivel para uso apenas em SmartClient Destop Windows' 
			lRet := .F.
		EndIf
			
	Else
		MsgStop(STR0010)//'Recurso não disponivel em ambientes com o binario inferior a Março/2016.'
		lRet := .F.
	EndIf 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetHSMDLL
Funcao do Compras Publicas responsavel por retornar o PATH ABSOLUTO 
NO CLIENT da DLL de comunicacao com o Token HSM. Caso o parametro nao
esteja armazenado no smartclient.ini, exibe uma dialog para o usuario indicar
o caminho e em seguida cria o conteudo no arquivo ini para efeitos de cache. Desta
forma, nas proximas execuções o usuario nao precisa indicar o arquivo ini.

@author Cesar Bianchi	
@return cPath - Path absoluta da DLL de comunicacao
@since 15/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetHsmDLL()
	Local cPath				:= ""
	Local cClientIni 		:= GetRemoteIniName()
	Local cSecao 			:= "GCPConf"
	Local cChave			:= "HSMLib"
	Local cDefault			:= "UNKNOW"

	//1* - Verifico se possui o caminho da DDL armazenado no smartclient.ini em formato de cache
	cPath := GetPvProfString(cSecao, cChave, cDefault, cClientIni)
	If alltrim(upper((cPath))) == "UNKNOW"
	
		cPath := cGetFile("Arquivos DLL (*.DLL) |*.dll|","Selecione o arquivo DLL do fabricante do TOKEN",,,,GETF_LOCALHARD)
		
		//4* Gravo o caminho da DLL no smartclient.ini para usar nos proximos testes
		If !Empty(cPath)
			SetHsmDll(cSecao,cChave,cClientIni,cPath)
		Endif
	Else
		//Se possui o caminho do arquivo, valido se ele existe.
		If !(File(cPath))
		
			//Se não existe, entao pergunto para o usuario indicar aonde esta!
		 	cPath := cGetFile(STR0011,STR0012,,,,GETF_LOCALHARD) //"Arquivos DLL (*.DLL) |*.dll|" ## "Selecione o arquivo DLL do fabricante do TOKEN"
			
			//4* Gravo o caminho da DLL no smartclient.ini para usar nos proximos testes
			If !Empty(cPath)
				SetHsmDll(cSecao,cChave,cClientIni,cPath)
			Endif
		EndIf
	EndIf
		
Return cPath

//-------------------------------------------------------------------
/*/{Protheus.doc} SetHsmDll
Funcao do Compras Publicas responsavel por gravar o PATH ABSOLUTO 
DLL de comunicacao com o Token HSM no smartclient.ini para efeitos de cache. Desta
forma, nas proximas execuções o usuario nao precisa indicar o arquivo ini.

@author Cesar Bianchi	
@return cPath - Path absoluta da DLL de comunicacao
@since 15/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetHsmDll(cSecao,cChave,cClientIni,cPath)
	Local lRet := .F.
	Default cSecao := ""
	Default cChave := ""
	Default cClientIni := ""
	Default cPath := ""
		
	If !Empty(cSecao) .and. !Empty(cChave) .and. !Empty(cClientIni) .and. !Empty(cPath)
		WritePProString(cSecao,cChave,cPath,cClientIni)
		lRet := .T.
	Else
		lRet := .F. 
	EndIf

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPValidDevice
Funcao do Compras Publicas responsavel validar a lista de slots com tokens
ativos e disponiveis para uso.

@author Cesar Bianchi	
@return lRet - Indica se encontrou algum device ativo
@since 15/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GCPValidDevice(aDevices)
	Local nI 			:= 1
	Local nPosOk 		:= 4
	Local nPosDesc		:= 3
	Local lRet			:= .F.
	Default aDevices	:= {}
	
	aDescDev := {}
	For nI := 1 to len(aDevices)
		If len(aDevices[nI]) >= nPosOk .and. aDevices[nI,nPosOk]
			//Localizado device ativo.
			aAdd(aDescDev,alltrim(str(nI - 1)) + " - " + aDevices[nI,nPosDesc])
			lRet := .T.
		EndIf		
	Next nI
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GcpSetHsmSlot
Funcao do Compras Publicas responsavel exibir uma interface grafica para escolha 
do token HSM a ser utilizado na comunicação SSL da integração com o ComprasNET

@author Cesar Bianchi	
@return lRet - indica se o token foi selecionado
@since 15/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GcpSetHsmSlot(cTokenPsw)
	Local lRet 			:= .T.
	Local oDlgTk 		:= Nil
	Local oSayTkInf 	:= Nil
	Local cOption		:= ""
	Local aHard			:= aClone(aDescDev)

	Default cTokenPsw 	:= ""
	
	If !Empty(cTokenPsw)
		
		//Monta a Dialog
		oDlgTk:= MSDIALOG():Create()
		oDlgTk:cName     := STR0013 //"oDlgTk"
		oDlgTk:cCaption  := STR0014 //"Selecione o dispositivo HSM / Token SSL"
		oDlgTk:nLeft     := 0
		oDlgTk:nTop      := 0
		oDlgTk:nWidth    := 400
		oDlgTk:nHeight   := 250
		oDlgTk:lShowHint := .F.
		oDlgTk:lCentered := .T.
		oDlgTk:bInit 	:= {|| EnchoiceBar(oDlgTk, {||( lRet := .T., oDlgTk:End() )} , {||( lRet := .F. , oDlgTk:End() )} ,, {}) }
		
		//Monta o Say com informações ao usuario sobre o Token a ser selecionado
		oSayTkInf:= TSAY():Create(oDlgTk)
		oSayTkInf:cName				:= STR0015 //"oSayTkInf"
		oSayTkInf:cCaption 			:= STR0016 //"Selecione abaixo o modelo do Hardware HSM (TOKEN) a ser utilizado na comunicação com o ambiente do ComprasNET."
		oSayTkInf:nLeft 				:= 20
		oSayTkInf:nTop 				:= 100
		oSayTkInf:nWidth 	   			:= 300
		oSayTkInf:nHeight 			:= 30
		oSayTkInf:lShowHint 			:= .F.
		oSayTkInf:lReadOnly 			:= .F.
		oSayTkInf:Align 				:= 0
		oSayTkInf:lVisibleControl	:= .T.
		oSayTkInf:lWordWrap 	  		:= .T.
		oSayTkInf:lTransparent 		:= .F.
		
		//Monta a lista da esquerda com todos os dispositivos de Hard listados na funcao HsmSlotList()
		oCombo1 := TComboBox():New(70,10.5,{|u|if(PCount()>0,cOption:=u,cOption)},aHard,150,20,oDlgTk,,{||Alert('Mudou item da combo')},,,,.T.,,,,,,,,,'cOption')
		
		//Exibe a Dialog
		oDlgTk:Activate()
		
		//Defino o numero do Slot escolhido
		nSlot := val(alltrim(substr(cOption,1,2)))	
		
		//Define o label do certificado e da chave
		cCert := "slot_" + alltrim(str(nSlot)) + "-label_"	
		cKey := cCert
		
	Endif
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPValidObjs
Funcao do Compras Publicas responsavel validar a lista de objetos presentes
dentro de um determinado SLOT de um HSM, alem de finalizar a montagem do LABEL

@author Cesar Bianchi	
@since 15/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GCPValidObjs(aObjs)
	Local lRet		:= .T.
	Local nI		:= 1
	Local nPosOk	:= 2
	Local nPosID	:= 4
	Local cCertID	:= ""
	Default aObjs := {}
	
	For nI := 1 to len(aObjs)
		If len(aObjs[nI]) >= nPosID .and. aObjs[nI,nPosOk]
			//Localizei uma chave valida
			cCertID := aObjs[nI,nPosID]
			
			//Completo a formacao do Label do certificado. Agora os labels de certificado e de chave estao prontos para uso
			cCert := cCert += cCertID
			
			//Finaliza a busca
			lRet := .T.
			exit
		EndIf
	Next nI
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPMakeXML
Funcao do Compras Publicas responsavel gerar um arquivo XML com o conteudo
de uma tentativa de Post no ambiente do ComprasNET

@author Cesar Bianchi
@since 16/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCPMakeXML(cURL,cCert,cKey,cXml)
	Local cFile := 'GCP_XML_' + DTOS(Date()) + "_" + Replace(Time(),":","") + "_" + alltrim(str(Randomize(10000,99000))) + ".txt"
	Local cPath := GetTempPath(.T.)
	Local cFullName := cPath + cFile
	Local cMensagem := ""
	Local cPulaLin := chr(13) + chr(10)
	Local nHdl := 0
	Local nI := 0
	Local cAux := ""
	
	//Monta o conteudo do arquivo
	cMensagem := "XML Log File - Make by TOTVS_GCP_Team " + cPulaLin
	cMensagem += "URL: " + alltrim(cURL) + cPulaLin
	cMensagem += "Certificado: " + cCert  + cPulaLin
	cMensagem += "Key: " + cKey  + cPulaLin 
	cMensagem += cPulaLin
	cMensagem += cXML
	
	//Cria o arquivo
	nHdl := FCreate(cFullName)
	If nHdl > -1
		For nI := 1 to len(cMensagem)
			cAux := substr(cMensagem,nI,nI+1024)
			FWrite(nHdl,cAux)
			nI := nI + 1024
			Sleep(2000)
		Next nI
		
		//Fecha o arquivo
		While .T.
			If FClose(nHdl)
				Sleep(300)
				exit
			Else
				Sleep(1000) 
			EndIf
		EndDo
	EndIf

	//Exibe o arquivo em video
	shellExecute("Open",cFullName, " /k dir", "C:\", 1 )	 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPGetCert
Função responsável por retornar o caminho do Certificado e/ou criar
o arquivo 

@author Matheus Lando Raimundo	
@since 13/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCPGetCert(cCert,cDestino)
Local cFile := cDestino + cCert 
Local lMemoWrite := .F.  

If !File(cFile)	
	If Len(GetResArray(cCert)) > 0
		cString := GetApoRes(cCert)
		If !Empty(cString) 
			lMemoWrite := MemoWrit( cFile, cString )
			Sleep(500)
			If !lMemoWrite
				MsgStop( STR0017 + AllTrim( cFile ) + STR0018 ) // "Não foi possível gravar o arquivo de certificado com o conteúdo do repositório: " ## ". Para detalhes do conteúdo, verificar o console."
				Conout( "[GCP][INT][WARN] " + STR0019 + cFile + CRLF + cResConteudo ) //"Não foi possível gravar o conteúdo do certificado "
				cFile := ""
			EndIf
		Else
			MsgStop( STR0020 + AllTrim( cFile ) ) //"Não foi possível ler o conteúdo do certificado no repositório: "
			cFile := ""
		EndIf
	Else		
		MsgStop( STR0021 + AllTrim( cFile ) ) //"Não foi possível encontrar o certificado: "
		cFile := ""		   
	EndIf
EndIf

Return cFile