#include "protheus.ch"

Static __aWsMethod := {}
Static __aWsWsdl   := {}

Static _cIsCplDeg  := Nil
Static _cCplDbgDir := Nil
Static _cCplEmpDef := Nil
Static _lHasEmpFil := Nil

/*/{Protheus.doc} OMSXStart
	Fun��o necess�ria para iniciar o webservice de integra��o entre o OMS e a Neolog
@author Jackson Patrick Werka
@since  17/07/2018
/*/
Function OMSXStart()
Local lRet := .T.
Return lRet

/*/{Protheus.doc} OMSXConnect
	Fun��o respons�vel pelo recebimento de requisi��es via WS da neolog que
	dispara cada requisi��o para seus respectivos metodos, onde estes
	interpretam e processam os dados integrando os mesmos ao ERP.
@author Jackson Patrick Werka
@since  17/07/2018
/*/
Function OMSXConnect()
Local lOmCPL001 := Existblock("OMCPL001")
Local cHtml    := ""
Local cContent := HttpOtherContent()
Local cError   := ""
Local cWarning := ""
Local oXmlSoap := Nil
Local nX       := 0
Local cMethod  := ""
Local cFault   := ""
Local cConteudo := ""
Local bError   := Errorblock({|e|})
Local lGravaResp := .F.
Local oXmlProc := Nil
Private XMLREC

	PutGlbValue( "GLB_OMSLOG",GetSrvProfString("LOGCPLOMS", ".F.") )
	PutGlbValue( "GLB_OMSTIP",GetSrvProfString("LOGTIPOMS", "CONSOLE") )

	//Valida��o para grava��o da Data do fonte no LOGOMSCPL
	OsLogCpl("-----------------------------------------------------------------------------------------","DATA")
	OsLogCPL("Inspetor de Objetos CPL OMSXConnect","DATA")
	OsLogCpl("-----------------------------------------------------------------------------------------","DATA")
	OmCPLIns()
	OsLogCpl("-----------------------------------------------------------------------------------------","DATA")

	OsLogCPL("OMSXWS -> OMSXConnect -> "+Replicate("-", 100),"INFO")
	If !Empty(cContent)
		OsLogCpl("OMSXWS -> OMSXConnect -> Iniciando Requisito Via WS. Conteudo de cContent: "+ cValToChar(cContent)+".","INFO" )
	Else
		OsLogCpl("OMSXWS -> OMSXConnect -> Iniciando Requisito Via WS. O xml esta vazio!","INFO" )
	EndIf

	//Ponto de entrada que permite manipular o XML Rebido pela intega��o CPL
	If lOmCPL001
		OsLogCpl("OMSXWS -> OMSXConnect -> Encontrou o ponto de entrada OMCPL001","INFO" )
		cContent := Execblock("OMCPL001",.F.,.F.,{cContent})
		IF !ValType(cContent)=="C"
			OsLogCpl("OMSXWS -> OMSXConnect -> Variavel cContent foi anulada no PE OMCPL001.","INFO" )
			Return cHtml
		ElseIf !Empty(cContent)
			OsLogCpl("OMSXWS -> OMSXConnect -> Retorno variavel cContent"+ cValToChar(cContent)+".","INFO" )
		Else
			OsLogCpl("OMSXWS -> OMSXConnect -> Retorno variavel cContent no Ponto de Entrada OMCPL001 vazio!","INFO" )
		EndIF
	EndIf

	// Inicializa o objeto de falha, para desconsiderar falhas de chamadas anteriores
	SetFaultTMS("","","")
	HttpHeadOut->CONTENT_TYPE := "application/xml"
	If "WSDL" $ UPPER(HttpHeadIn->aHeaders[1]) .And. Empty(cContent)
		//Requisi��o de WSDL
		cMethod := "WSDL" + HttpHeadIn->MAIN
		nX := aScan(__aWsWsdl, {|x| x == cMethod})

		If nX == 0
			If FindFunction(cMethod)
				aAdd(__aWsWsdl,cMethod)
				nX := Len(__aWsWsdl)
			Else
				OsLogCpl("OMSXWS -> OMSXConnect -> Falha ambiente M�todo: " + cValTochar(cMethod) + " n�o encontrado.","ERROR" )
				SetFaultTMS("Falha ambiente","Metodo " + cMethod + " n�o encontrado.")
			EndIf
		EndIf

		If nX != 0
			cHtml := &cMethod.()
		EndIf

	Else
		cMethod := HttpHeadIn->MAIN
		nX := aScan(__aWsMethod, {|x| x == cMethod})

		OsLogCpl("OMSXWS -> OMSXConnect -> M�todo recebido : " + cValToChar(cMethod),"INFO" )

		If nX == 0
			OsLogCpl("OMSXWS -> OMSXConnect -> Entrou na condi��o nX == 0 ","INFO" )

			If FindFunction(cMethod)
				aAdd(__aWsMethod,cMethod)
				nX := Len(__aWsMethod)
				OsLogCpl("OMSXWS -> OMSXConnect -> M�todo encontrado: " + cValtoChar(cMethod) + ".","INFO" )

			Else
				OsLogCpl("OMSXWS -> OMSXConnect -> Falha ambiente M�todo: " + cValTochar(cMethod) + " n�o encontrado.","ERROR" )
				SetFaultTMS("Falha ambiente","Metodo " + cMethod + " n�o encontrado.")

			EndIf
		EndIf

		If nX != 0

			OsLogCpl("OMSXWS -> OMSXConnect -> Entrou na condi��o nX = " + cValtoChar(nX) + ".","INFO" )

			//Validador de XML com base em XSD
			If !Empty(cContent)
				cError := OMSValXSD(cContent, cMethod) 
			Else
				cError := "O xml de entrada est� vazio!
				OsLogCpl("OMSXWS -> OMSXConnect -> Xml de entrada vazio.","ERROR" )
				SetFaultTMS(cError,"Verifique o xml enviado.","ERROR")
			EndIf

			If Empty(cError)		
				cError := ""
				cWarning := ""
				oXmlSoap := XmlParser(cContent, "NS1", @cError,  @cWarning )

				OsLogCpl("OMSXWS -> OMSXConnect -> Conte�do de cErro: " + cValTochar(cError),"INFO" )
				OsLogCpl("OMSXWS -> OMSXConnect -> Conte�do de cWarning: " + cValTochar(cWarning),"INFO" )
			EndIf
			If !Empty(cWarning)
				OsLogCpl("OMSXWS -> OMSXConnect -> Conte�do de cWarning: " + cValTochar(cWarning),"INFO" )
				TmsLogMsg("WARN",'[Thread ' + cValToChar(ThreadId()) + '] ' + cWarning)
			EndIf

			If Empty(cError)

				Private nModulo := 39
				XMLREC := oXmlSoap
				oXmlProc := TMSXGetItens("Envelope:Body","O", ,cContent)
 				cHtml := &cMethod.(oXmlProc,@cContent)

				OsLogCpl("OMSXWS -> OMSXConnect -> inicializado ambiente OMS ","INFO" )
				OsLogCpl("OMSXWS -> OMSXConnect -> Cont�udo de cHtml: " + cValToChar(cHtml),"INFO" )

 			Else
			 	OsLogCpl("OMSXWS -> OMSXConnect -> Conte�do de cError: " + cValTochar(cError),"ERROR" )
				TmsLogMsg("WARN",'Erro gerado no servidor Protheus [Thread ' + cValToChar(ThreadId()) + '] ' + cError)

				//Retorna F para a Neolog referente a liberacao da viagem por causa da incapacidade de utilizar o xml recebido
				cHtml := OMSCplXmlF(cMethod, cError)
				If Empty(cHtml)
					OsLogCpl("OMSXWS -> OMSXConnect -> N�o foi poss�vel identificar a fun��o do XML.","ERROR" )
					SetFaultTMS("Erro ao interpretar o xml recebido no Protheus. Verifique o xml de envio!",cError,"ERRO")
				Else
					OsLogCpl("OMSXWS -> OMSXConnect -> Erro ao interpretar o xml recebido no Protheus: " + cValTochar(cError),"ERROR")
				EndIf

				If !Empty(cContent)
 					Begin Sequence
					// Grava o conte�do do XML na pasta de Log - Caso ativado
						OMSXGRVXML("OMSXConnect",cContent,"DK0")
					End Sequence
				ErrorBlock(bError)
					If !Empty(cContent)
						OsLogCpl("OMSXWS -> OMSXConnect -> Variavel cConteudo apos gravar xml na pasta do servidor Protheus: " + cValTochar(cConteudo),"ERROR" )
					EndIf
				EndIf

			EndIf

			//Quando for recebido um XML de Cancelamento de Monitoramento, esta Flag deve ficar FALSA, pois n�o � necess�rio chamar grava��o de XML de resposta.
			If cMethod == "FINISHING"
				lGravaResp := .F.
			Else
				lGravaResp := .T.
			EndIf
		EndIf
	EndIf

	cFault := GetFaultTMS()
	If !Empty(cFault) .And. Empty(cHtml)
		cHtml := cFault
	EndIf

	If lGravaResp
		OMSXGRVXML(cMethod,cHtml,"DK0","resp")
	EndIf

	OsLogCpl("OMSXWS -> OMSXConnect -> Fim do processamento" ,"INFO" )

Return cHtml

/*/{Protheus.doc} OsIsCplDbg
	Retorna se a configura��o do INI para Debug com a NEOLOG est� ativa.
	Estando ativa os arquivos xml trocados com a neolog ser�o salvos na configura��o indicada em: DebugPath
	Caso n�o exista a configura��o no INI retornar� true por padr�o.
@author Jackson Patrick Werka
@since  17/07/2018
/*/
Function OsIsCplDbg()
	If _cIsCplDeg == Nil
		_cIsCplDeg := (AllTrim(GetPvProfString("NEOLOG" , "Debug" , "1" , GetSrvIniName())) == "1")
	EndIf
Return _cIsCplDeg

/*/{Protheus.doc} OsCplDbgDir
	Retorna a configura��o do INI para o caminho do Debug com a NEOLOG.
	Neste diret�rio ser�o gravados todos os arquivos xml trocados com a neolog, caso a configura��o de Debug esteja ativa.
	Caso n�o exista a configura��o no INI retornar� "system/neolog" por padr�o.
@author Jackson Patrick Werka
@since  17/07/2018
/*/
Function OsCplDbgDir()
	If _cCplDbgDir == Nil
		_cCplDbgDir := AllTrim(GetPvProfString("NEOLOG" , "DebugPath" , "system/neolog" , GetSrvIniName()))
		If IsSrvUnix()
			// Se for linux troca as barras do windows
			_cCplDbgDir := StrTran(_cCplDbgDir,"\","/")
			// Se possuir uma barra no fim, retira a mesma
			If Right(_cCplDbgDir,1) == "/"
				_cCplDbgDir := SubStr(_cCplDbgDir,1,Len(_cCplDbgDir)-1)
			EndIf
		Else
			// Se for windows troca as barras do linux
			_cCplDbgDir := StrTran(_cCplDbgDir,"/","\")
			// Se possuir uma barra no fim, retira a mesma
			If Right(_cCplDbgDir,1) == "\"
				_cCplDbgDir := SubStr(_cCplDbgDir,1,Len(_cCplDbgDir)-1)
			EndIf
		EndIf
	EndIf
Return _cCplDbgDir

/*/{Protheus.doc} OsCplEmpDef
	Retorna a configura��o do INI para a empres�o padr�o de integra��o com a NEOLOG.
	Quando parametrizada uma empresa padr�o, n�o ser� concatenada a empresa no envio das mensagens a NEOLOG.
	Caso n�o exista a configura��o no INI retornar� uma string vazia por padr�o.
@author Jackson Patrick Werka
@since  17/07/2018
/*/
Function OsCplEmpDef()
	If _cCplEmpDef == Nil
		_cCplEmpDef := AllTrim(GetPvProfString("NEOLOG" , "DefaultCompany" , "" , GetSrvIniName()))
	EndIf
Return _cCplEmpDef

/*/{Protheus.doc} OsHasEmpFil
	Retorna se o layout de configura��o da tabela SM0 cont�m a m�scara de empresa.
	Quando n�o contiver a m�scara de empresa e n�o possuir um empresa padr�o configurada no INI
	ao enviar as mensagens para a NEOLOG ser� concatenada a empresa com a filial para os relacionamentos.
@author Jackson Patrick Werka
@since  17/07/2018
/*/
Function OsHasEmpFil()
	// http://tdn.totvs.com/x/kf1n
	If _lHasEmpFil == Nil
		_lHasEmpFil := ('E' $ FWSM0Layout()) // Se contem a empresa no layout
	EndIf
Return _lHasEmpFil


/*/{Protheus.doc} OMSCplXmlF
	S� faz tratamento para PUBLISHRELEASEDTRIP porque as outras duas mensagens REPROGRAMSERVICE e CANCELSERVICE n�o tem xml de insucesso
@author Equipe OMS
@since  17/01/2022
/*/
Static Function OMSCplXmlF(cMetodo, cError)
	Local cStrCab := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body>'
	Local cEndRdp := '</soapenv:Body></soapenv:Envelope>'
	Local cXmlVerEnc := '<?xml version="1.0" encoding="UTF-8"?>'
	Local cRetXmlF := ""

	If Upper(AllTrim(cMetodo)) = "PUBLISHRELEASEDTRIP"
		cRetXmlF += cXmlVerEnc
		cRetXmlF += cStrCab
		cRetXmlF += '<ns1:publishReleasedTripResponse xmlns:ns1="urn:neolog:cockpit:TripReleaseRequestPublishingService">N</ns1:publishReleasedTripResponse>'
		cRetXmlF += cEndRdp
		OsLogCpl("OMSXWS -> OMSCplXmlF -> Retorno para o Neolog (falha):" + cValToChar(cRetXmlF),"INFO")
	EndIf

Return cRetXmlF


/*/{Protheus.doc} OMSValXSD
	Validacao de xml baseado em xsd
@author Equipe OMS
@param cXML Xml em formato de string para validacao
@param cXSD Caminho no xsd a ser usado como referencia
@since  17/01/2022
/*/
Static Function OMSValXSD(cXML, cMetodo)
	Local cRetorno  := ""
	Local cError 	:= ""
	Local cWarning 	:= ""
	Local cDirXsd 	:= ""
	Local cArqXsd 	:= ""

	Do Case
		Case Upper(AllTrim(cMetodo)) = "PUBLISHRELEASEDTRIP"
			cArqXsd := "\publishReleasedTripService.xsd"
			cDirXsd := GetSrvProfString("StartPath","") + "xsd"
		Case Upper(AllTrim(cMetodo)) = "REPROGRAMSERVICE"
			cArqXsd := "\publishReprogrammingService.xsd"
			cDirXsd := GetSrvProfString("StartPath","") + "xsd"
		Case Upper(AllTrim(cMetodo)) = "CANCELSERVICE"
			cArqXsd := "\publishCancelService.xsd"
			cDirXsd := GetSrvProfString("StartPath","") + "xsd"
	EndCase
	OsLogCpl("OMSXWS -> OMSValXSD -> Verificando as configura��es de validacao de xml baseada em schema xsd.")
	If !Empty(cDirXsd) .And. ExistDir(cDirXsd)
		XmlSVldSch( cXML, cDirXsd + cArqXsd, @cError, @cWarning)
		If !Empty(cError) .or. !Empty(cWarning)
			cRetorno := "A integracao nao sera processada! Resultado da validacao do XML de entrada com o xsd "+cArqXsd+": " + cError + cWarning
			cRetorno := StrTran( cRetorno, "<" ,"&lt;" )
			cRetorno := StrTran( cRetorno, ">" ,"&gt;" )
		EndIf
	Else
		OsLogCPL("OMSXWS -> OMSValXSD -> Validacao do xml de entrada atraves de xsd nao executada por nao existir o diretorio " + cDirXsd + " com os xsds no servidor.","INFO")
	EndIf
	OsLogCpl("OMSXWS -> OMSValXSD -> An�lise das configura��es de validacao de baseada em schema xsd concluida.")
Return cRetorno
