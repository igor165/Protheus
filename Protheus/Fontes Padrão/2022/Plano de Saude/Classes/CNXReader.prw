#Include 'protheus.ch'
#Include 'fileio.ch'
#Define lLinux IsSrvUnix()
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
	#define barra "\"
#ELSE
	#define CRLF Chr(10)
	#define barra "/"
#ENDIF
#DEFINE ARQ_LOG_CNX		"importacao_cnx.log"
#DEFINE PROP	1
#DEFINE VALOR	2

Class CNXReader
	Data cErro
	Data cFile
	Data cRegANS
	Data oXml
	Data hMap
	Data nCount

	Method new(cFile)
	Method destroy()
	Method getError()
	Method setError(cErro)
	Method readFile()
	Method existFile()
	Method existDest()
	Method copyToSrv()
	Method tryExec(lSuccess, cError, oExecutor)
	Method getFirst()
	Method initEntity()
	Method getCount()
	Method map(oEntity)
	Method hasNext()
	Method getNext()
EndClass

Method new(cFile) Class CNXReader
	self:cErro 		:= ""
	self:cFile 		:= cFile
	self:cRegANS 	:= ""
	self:oXml 		:= tXmlManager():new()
	self:hMap 		:= THashMap():New()
	self:nCount 	:= 0
Return self

Method destroy() Class CNXReader
	if !Empty(self:oXml)
		// self:oXml:destroy()
		FreeObj(self:oXml)
		self:oXml := nil
	EndIf
	if !empty(self:hMap)
		self:hMap:clean()
		FreeObj(self:hMap)
		self:hMap := nil
	endif
Return

Method getError() Class CNXReader
Return self:cErro

Method setError(cErro) Class CNXReader
	self:cErro := cErro
Return

Method readFile() Class CNXReader
	Local lSuccess := .T.
	Local cMsg := ""

	lSuccess := self:existFile()
	if lSuccess
		lSuccess := self:oXml:readFile(self:cFile,,self:oXml:Parse_noblanks)
		if !lSuccess
			cMsg := "Nao foi possivel realizar a leitura do arquivo de conferência." + CRLF + "Aviso: " + AllTrim(self:oXml:Warning()) + CRLF + "Erro: " + AllTrim(self:oXml:Error())
			self:setError(cMsg)
		EndIf
	EndIf
Return lSuccess

Method existFile() Class CNXReader
	Local lSuccess := self:existDest()
	If lSuccess
		lSuccess := self:copyToSrv()
		If lSuccess
			lSuccess := self:tryExec(File(self:cFile),"Arquivo não encontrado: " + self:cFile)
		EndIf
	EndIf
Return lSuccess

Method existDest() Class CNXReader
	Local lSuccess := .T.
	Local aDir := Directory(barra + "SIB","D")
	Local cMsg := "Não foi possível criar o diretório \sib no servidor"

	If Len(aDir) == 0
		lSuccess := self:tryExec(MakeDir(GetPvProfString(GetEnvServer(), "RootPath", "", GetADV97()) + barra + "SIB") <> 0, cMsg)
	EndIf
Return lSuccess

Method copyToSrv() Class CNXReader
	Local lSuccess := .T.
	Local cDrive 	:= ""
	Local cDir 		:= ""
	Local cNome 	:= ""
	Local cExt 		:= ""
	Local cMsg := "Não foi copiar o arquivo para o diretório \sib no servidor"

	SplitPath(self:cFile, @cDrive, @cDir, @cNome, @cExt)
	If !Empty(cDrive)
		If !isBlind()
			lSuccess := self:tryExec(CpyT2S(alltrim(self:cFile), barra + "SIB",.F.), cMsg)
		EndIf
		If lSuccess
			self:cFile := barra + "SIB" + barra + cNome + cExt
		EndIf
	EndIf
Return lSuccess

Method tryExec(lSuccess, cError, oExecutor) Class CNXReader
	if !lSuccess
		self:setError( IIf(Empty(cError),oExecutor:getError(),cError) )
	EndIf
Return lSuccess

Method getFirst() Class CNXReader
	Local cPathTag := "//mensagemSIB/cabecalho/destino"
	Local aTmp := {}
	Local oEntity := nil
	If self:oXml:XPathHasNode(cPathTag)
		aTmp := self:oXml:XPathGetChildArray(cPathTag)
		self:cRegANS := aTmp[PROP][3] //registroANS
	EndIf

	aTmp := {}
	/* Informacoes da mensagem */
	cPathTag := "//mensagemSIB/mensagem/ansParaOperadora/conferencia"
	lSuccess := self:tryExec(self:oXml:XPathHasNode(cPathTag),"Não encontrou a tag " + cPathTag)
	If lSuccess
		//Navego até a tag mensagem
		self:oXml:DOMChildNode() //Cabecalho
		self:oXml:DOMNextNode() //mensagem
		self:oXml:DOMChildNode() //ansParaOperadora
		self:oXml:DOMChildNode() //conferencia
		self:nCount := self:oXML:DOMChildCount()
		If self:oXml:DOMChildNode() //Entro no primeiro beneficiário
			oEntity := self:getNext()
		EndIf
	EndIf
Return oEntity

Method initEntity() Class CNXReader
Return CenEntity():new()

Method getCount() Class CNXReader
Return self:nCount

Method map(oEntity) Class CNXReader
	Local aBen := {} //dados temporario do usuario no arquivo
	Local nBen := 0  //contador para FOR...NEXT
	If self:oXML:cName == "beneficiario"
		//Atributos de beneficiario
		oEntity:setValue("registroANS",self:cRegANS)
		aBen := self:oXml:DomGetAttArray()
		For nBen := 1 To Len(aBen)
			If	aBen[nBen,1] <> "dataAtualizacao"
				oEntity:setValue(aBen[nBen][PROP],aBen[nBen][VALOR])
			Endif
		Next nBen

		If self:oXml:DOMChildNode()
			If self:oXml:DOMHasChildNode() .And. self:oXML:cName == "identificacao"
				aBen := self:oXml:DomGetChildArray()
				For nBen := 1 To Len(aBen)
					oEntity:setValue(aBen[nBen][PROP],aBen[nBen][VALOR])
				Next nBen
				self:oXml:DOMNextNode()
			EndIf
			If self:oXml:DOMHasChildNode() .And. self:oXML:cName == "endereco"
				aBen := self:oXml:DomGetChildArray()
				For nBen := 1 To Len(aBen)
					oEntity:setValue(aBen[nBen][PROP],aBen[nBen][VALOR])
				Next nBen
				self:oXml:DOMNextNode()
			EndIf
			If self:oXml:DOMHasChildNode() .And. self:oXML:cName == "vinculo"
				aBen := self:oXml:DomGetChildArray()
				For nBen := 1 To Len(aBen)
					oEntity:setValue(aBen[nBen][PROP],aBen[nBen][VALOR])
				Next nBen
				self:oXml:DOMNextNode()
			EndIf
			self:oXml:DOMParentNode()
		EndIf
	EndIf
Return

Method hasNext() Class CNXReader
Return self:oXml:DOMNextNode()

Method getNext() Class CNXReader
	Local oEntity := self:initEntity()
	self:map(oEntity)
Return oEntity
