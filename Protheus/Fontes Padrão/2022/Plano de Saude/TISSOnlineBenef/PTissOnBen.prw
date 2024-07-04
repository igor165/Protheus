#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.ch"

#DEFINE CRLF chr( 13 ) + chr( 10 )
#DEFINE SCHEMAFOLDER "\tiss\schemas\"


//-----------------------------------------------------------------
/*/{Protheus.doc} PTissOnBen
    Classe para controle de transacoes TISS On de Atendimento/Beneficiarios
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Class PTissOnBen

	Data oXML
	Data cPathTag  as String
	Data aCritARQ  as Array
	Data cNS       as String
	Data cTransWS  as String
	Data cRespWS   as String
	Data lVldLogin as Boolean
	Data cXmlRet   as String
	Data cVerArq   as String
	Data cStrHash  as String
	Data oCritMap
	

	Method New()
	Method procXML(lAuto,cXmlAuto)
	Method validLogin()
	Method readCabec()
	Method geraBody()
	Method addNS(cTag)
	Method gerXmlResp()
	Method VldWSRecS(cSoap,cSchema)
	Method gerCritArq()
	Method gerTag(nSpc,cTag,cVal,lIni,lFin,lPerNul,lRetPto,lEnvTag)
	Method maskDate(cData) 
	Method retTag(cPath)
	Method setCritica(cCod)
	Method critMap()
	Method critEspec()

EndClass


//-----------------------------------------------------------------
/*/{Protheus.doc} New
 Classe Construtora
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method New(cCodOpe) Class PTissOnBen

	self:oXML      := TXmlManager():New()
	self:cPathTag  := ""
	self:aCritARQ  := {.F., "", ""}
	self:cTransWS  := ""
	self:cRespWS   := ""
	self:lVldLogin := .F.
	self:cXmlRet   := ""
	self:cVerArq   := ""
	self:cStrHash  := ""
	self:oCritMap  := HMNew()

	self:critMap() //Carrega criticas do processo

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} procXML
Processa uma requisicao TISS Online

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Method procXML(lAuto,cXmlAuto) Class PTissOnBen

	Local nPos     := 0
	Local cXml     := ""
	Local cSoapXML := ""
	Local cSoapPt1 := ""
	Local cSoapPt2 := ""
	Local aRetObj  := {}
	
	Default lAuto    := .F.
	Default cXmlAuto := ""

	cXml := iif(lAuto,cXmlAuto,HttpOtherContent())

	self:cVerArq := Substr(cXml,At("Padrao>", cXml) + Len("Padrao>"),7)
	HttpCtType( "text/xml; charset="+'UTF-8' )

	if empty(cXml)
    	return ProcOnLine(self:cRespWS)
	endif 

	aRetObj := self:VldWSRecS(cXml,"tissWebServicesV" + StrTran(self:cVerArq, ".", "_") + ".xsd")

	If aRetObj[1]

		cSoapXML := aRetObj[3]		
		if empty(self:cNS)
			// Removo da tag loteGuiasWS os URL's pois estava dando falha no parse.
			nPos := At(">",Upper(cSoapXml))      
			cSoapPt1 := Substr(cSoapXml,1,nPos-1)
			cSoapPt2 := Substr(cSoapXml,nPos,len(cSoapXml))
			cSoapXml := "      <"+ self:cTransWS + cSoapPt2
		endif		
		
		lRet := self:oXML:Parse(cSoapXml)
		if lRet 	
			aNS := self:oXML:XPathGetRootNsList()
			nPos := ascan(aNS,{|x| upper(alltrim(x[1])) == upper(self:cNS) })
			if nPos > 0
				self:oXML:XPathRegisterNs( aNS[nPos,1], aNS[nPos,2] )		
			endIf
		endIf
		
		self:cPathTag := self:addNS("/"+self:cTransWS+"/cabecalho")
		if self:oXml:XPathHasNode(self:cPathTag)
			self:readCabec()  //Leitura do cabecalho			
			self:validLogin() //Valida Login (indicar o atributo lVldLogin na classe filha)
			self:gerXmlResp() //Monta XML de resposta e executa processamento
		endIf

	else
		self:cXmlRet := "Erro ao carregar a mensagem: " + aRetObj[2] 
	endIf

Return self:cXmlRet


//-------------------------------------------------------------------
/*/{Protheus.doc} gerXmlResp
Geracao do Soap de resposta

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Method gerXmlResp() Class PTissOnBen
	
	self:cXmlRet += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas">' +Chr(10)
	self:cXmlRet +=   '<soap:Body>' +Chr(10)
	self:cXmlRet +=      '<ans:'+self:cRespWS+' xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas">' +Chr(10)
	
	//Gera corpo do arquivo
	self:geraBody()
	
	self:cXmlRet +=      '</ans:'+self:cRespWS+'>' +Chr(10)
	self:cXmlRet +=   '</soap:Body>' +Chr(10)
	self:cXmlRet += '</soap:Envelope>'

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} readCabec
Chamada de cabecalho padrao - Crie esse metodo na classe filha

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Method readCabec() Class PTissOnBen
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} geraBody
Geracao de body - Crie esse metodo na classe filha

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Method geraBody() Class PTissOnBen
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} validLogin
Verifica se o login de prestador foi informado corretamente

Criticas:
	3100 PARA LIBERAR ESTE ACESSO, ENTRE EM CONTATO COM A OPERADORA E SOLICITE O CADASTRAMENTO DO SEU CÓDIGO DE ORIGEM
	3111 CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Method validLogin() Class PTissOnBen

	Local cPathLogin := ''
	Local cLogin     := self:oXML:XPathGetNodeValue( cPathLogin + self:addNS("/loginPrestador" ))
	Local cSenha     := self:oXML:XPathGetNodeValue( cPathLogin + self:addNS("/senhaPrestador" ))	

	if self:lVldLogin .And. GetNewPar("MV_PLLGSN", .F.)

		cPathLogin := self:cPathTag + self:addNS("/loginSenhaPrestador" )
		if self:oXML:XPathHasNode(cPathLogin)
			cLogin	:= self:oXML:XPathGetNodeValue( cPathLogin + self:addNS("/loginPrestador" ))
			cSenha	:= self:oXML:XPathGetNodeValue( cPathLogin + self:addNS("/senhaPrestador" ))
			BSW->(dbSetOrder(1))
			if BSW->(MsSeek(xfilial("BSW") + Upper(cLogin) + Space( tamsx3("BSW_LOGUSR")[1] - Len(cLogin) ) ))
				If Alltrim(cSenha) <> Alltrim(BSW->BSW_SENHA)
					//Senha inválida
					self:setCritica("3111") //"CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO"
				endIF
			else
				//Login não existe -> login inválido
				self:setCritica("3111") //"CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO"
			endIf
		else
			//Não foi enviada a tag
			self:setCritica("3100") //"PARA LIBERAR ESTE ACESSO, ENTRE EM CONTATO COM A OPERADORA E SOLICITE O CADASTRAMENTO DO SEU CÓDIGO DE ORIGEM"
		endIf
	endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} VldWSRecS
Faz ajustes basicos no XML recebido

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Method VldWSRecS(cSoap,cSchema) Class PTissOnBen

	Local cSoapAux   := ""   
	Local cMsg       := ""
	Local cErro      := ""
	Local cAviso     := ""
	Local cNameSpace := ""
	Local nPos       := 0
	Local nX         := 0
	Local lRet       := .T. 
	Local nPos2		 := 0
	Local cXmlns	 := ""
	Local nPos1		 := 0

	nPos := At("BODY",Upper(cSoap))
	cSoapAux := Substr(cSoap,nPos+4,len(cSoap))    
	nPos := At(">",Upper(cSoapAux))
	cSoapAux := Substr(cSoapAux,nPos+1,len(cSoapAux))  

	nPos := At("BODY",Upper(cSoapAux)) 
	for nX := 1 to nPos 
		if Substr(cSoapAux,nPos-nX,1) == "<"
			cSoapAux := Substr(cSoapAux,1,nPos-(nX+1))
			Exit
		endif   
	next

	nPos1 := At("XMLNS",Upper(cSoap))
	If nPos1 > 0
		nPos2 := At(">",Upper(cSoap),nPos1) 
		cXmlns := subString(cSoap, nPos1, nPos2 - nPos1)
		nPos1 := At(">",Upper(cSoapAux))
		cSoapPt1 := Substr(cSoapAux,1,nPos1-1)
		cSoapPt2 := Substr(cSoapAux,nPos1,len(cSoapAux))
		cSoapAux := cSoapPt1 + " " + cXmlns + cSoapPt2
	endIf

	if nPos == 0 .Or. empty(cSoap)
		cErro := "Erro com o pacote Soap recebido" 
	endif

	// Se houve erro fatal finaliza 
	if !empty(cErro)
		return {.F.,cErro}
	endif

	nPos := At(Upper(self:cTransWS),Upper(cSoapAux))
	If Substr(cSoapAux,nPos-1,1) == ":"
		nPosNamSpc := nPos-2
		For nX := 1 to nPosNamSpc
			If Substr(cSoapAux,nPosNamSpc-nX,1) == "<"     
				cNameSpace := Substr(cSoapAux,nPosNamSpc - nX +1,nPosNamSpc - (nPosNamSpc - nX))
				self:cNS := cNameSpace
				Exit
			EndIf   
		next
	EndIf

	// Monta texto para montagem do arquivo para validacao
	cSoapXml := EncodeUTF8(cSoapAux)

	// Faz a validacao do XML com o XSD
	if !XmlSVldSch( cSoapXml, SCHEMAFOLDER + cSchema, @cErro,@cAviso)
		cMsg := Iif( !empty(cErro),"Erro: " +cErro,"") 
		cMsg += Iif( !empty(cAviso),"Aviso: "+cAviso,"") 
		lRet := .F.
	endif

return {lRet,cMsg,cSoapXml,cNameSpace}


//-------------------------------------------------------------------
/*/{Protheus.doc} addNS

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Method addNS(cTag) Class PTissOnBen

	if !empty(self:cNS)
		cTag := strtran(cTag, "/", "/" + self:cNS + ":")
	endif

Return cTag


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} gerTag
Formata a TAG XML a ser escrita no arquivo

@author    Jonatas Almeida
@version   1.xx
@since     02/09/2016

@param nSpc    = quantidade de tabulacao para identar o arquivo
@param cTag    = nome da tab
@param cVal    = valor da tag
@param lIni    = abertura de tag
@param lFin    = fechamento de tag
@param lPerNul = permitido nulo na tag
@param lRetPto = retira caracteres especiais
@param lEnvTag = retorna o conteudo da tag

@return cRetTag= tag ou vazio
/*/
//------------------------------------------------------------------------------------------
Method gerTag(nSpc,cTag,cVal,lIni,lFin,lPerNul,lRetPto,lEnvTag) Class PTissOnBen
	
	Local	cRetTag := "" // Tag a ser gravada no arquivo texto
	
	Default lRetPto	:= .T.
	Default lEnvTag	:= .T.

	if !empty(cVal) .Or. lPerNul
		if lIni // Inicializa a tag ?
			cRetTag += '<' + cTag + '>'
			cRetTag += allTrim( iif( lRetPto,plretponto( cVal ),cVal ) )
		endIf

		if lFin // Finaliza a tag ?
			cRetTag += '</' + cTag + '>'
		EndIf
		
		if lEnvTag // Escreve conteudo da tag no temporario pra calculo do hash
			self:cStrHash += AllTrim(Iif(lRetPto,plretponto(cVal),cVal))
		endIf
	
		cRetTag := replicate( "	", nSpc ) + cRetTag + CRLF // Identa o arquivo
	endIf

	self:cXmlRet += iif(lEnvTag,cRetTag,"" )

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} gerCritArq
Critica padrao do arquivo

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Method gerCritArq() Class PTissOnBen

	self:gerTag( 2,"ans:mensagemErro"	,''						      ,.T.,.F.,.T., .F. )
	self:gerTag( 3,"ans:codigoGlosa"	, self:aCritARQ[2] 			  ,.T.,.T.,.T., .F. )
	self:gerTag( 3,"ans:descricaoGlosa"	, EncodeUTF8(self:aCritARQ[3]),.T.,.T.,.T., .F. )
	self:gerTag( 1,"ans:mensagemErro"	,''				   		      ,.F.,.T.,.T., .F. )

Return	

//-------------------------------------------------------------------
/*/{Protheus.doc} maskDate
Monta a mascara para data

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Method maskDate(cData) Class PTissOnBen
Return substr(cData,1,4) + "-" + substr(cData,5,2) + "-" + substr(cData,7,2)


//-------------------------------------------------------------------
/*/{Protheus.doc} retTag
Retorna o valor de uma tag

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Method retTag(cPath,cTipo) Class PTissOnBen

	Local cTag := self:addNS(cPath)
	Local xRet	
    Default cTipo := "C"

	if self:oXml:XPathHasNode(cTag)
    	xRet := self:oXml:XPathGetNodeValue(cTag)
	endIf

	if Upper(cTipo) == "D"
		xRet := Stod(StrTran(xRet,"-",""))
	endIf

Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc} setCritica
Alimenta array de criticas

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Method setCritica(cCod) Class PTissOnBen

	Local oVal := nil

	self:aCritARQ[1] := .T.
	self:aCritARQ[2] := cCod
	if HMGet(self:oCritMap,cCod,oVal)
		self:aCritARQ[3] := oVal
	endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} critMap
Monta HashMap de criticas

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Method critMap() Class PTissOnBen

	HMSet(self:oCritMap, "3111", "CAMPO CONDICIONADO NAO PREENCHIDO OU INCORRETO")
	HMSet(self:oCritMap, "3100", "PARA LIBERAR ESTE ACESSO, ENTRE EM CONTATO COM A OPERADORA E SOLICITE O CADASTRAMENTO DO SEU CODIGO DE ORIGEM")

	self:critEspec() //Carrega criticas especificas

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} critEspec
Carrega criticas especificas - Nao cadastrar nada aqui, somente na classe filha

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Method critEspec() Class PTissOnBen
Return
