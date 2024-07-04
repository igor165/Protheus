#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "WSPCFACTORY.CH"

/* ===============================================================================
WSDL Location    http://104.41.45.71:43210/PcfIntegService?wsdl
Gerado em        08/21/15 11:02:56
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _IVCGBNR ; Return  // "dummy" function - Internal Use  

/* -------------------------------------------------------------------------------
WSDL Service WSPCFactory
------------------------------------------------------------------------------- */

WSCLIENT WSPCFactory

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD getLinks
	WSMETHOD receiveMessage

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cpXmlDocument             AS string
	WSDATA   creceiveMessageResult     AS string
	
	//Caminho completo do WS. EX: http://104.41.45.71:43210/PcfIntegService?wsdl
	WSDATA   cCaminho                  AS string

	//Link utilizado na tag receiveMessage. Ex: http://tempuri.org/
	WSDATA   cLinkRM                   AS string

	//Link SOAP passado por parâmetro para a função SvcSoapCall
	WSDATA   cLinkSoap                 AS string

	//Link NameSpace passado por parâmetro para a função SvcSoapCall
	WSDATA   cNameSpace                AS string

	//Link do WS passado por parâmetro para a função SvcSoapCall
	WSDATA   cPostUrl                  AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSPCFactory
::Init()
If !FindFunction("XMLCHILDEX")
	UserException(STR0001) //"O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20150602] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual."
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSPCFactory
Return

WSMETHOD getLinks WSSEND cLink WSCLIENT WSPCFactory
	Local aSource
	Local aQuebra := {}
	Local lRet    := .T.
	Local cMsg    := ""
	Local cTexto  := ""
	Local nI      := 0
	Local nJ      := 0
	Local nPos    := 0
	Local cMethod := ""
	Local cFunction  := "StrTokArr2"
   
	Default cLink := ""

	BEGIN WSMETHOD

	//Busca o caminho do WS que está cadastrado na SOD
	dbSelectArea("SOD")
	SOD->(dbSetOrder(1))
	If !Empty(cLink) .Or. SOD->(dbSeek(xFilial("SOD")+"1"))
		If !Empty(cLink)
			::cCaminho := AllTrim(cLink)
		Else
			::cCaminho := AllTrim(SOD->OD_CAMINHO)	
		EndIf 

		//Gera o fonte Client do WS.
		aSource := getClient(::cCaminho)
		//aSource := WSDLSource(::cCaminho)
		If aSource != Nil
			If aSource[1]

				//Retira as quebras de linha.
				aSource[2] := StrTran(aSource[2],CHR(9)," ")
				aSource[2] := StrTran(aSource[2],CHR(10)," ")
				aSource[2] := StrTran(aSource[2],CHR(13)," ")
				aSource[2] := StrTran(aSource[2],";"," ")
				
				nPos := AT('WSMETHOD RECEIVEMESSAGE', Upper(aSource[2]))
				
				If nPos > 0
					//Pega a definição do método ReceiveMessage, para fazer a quebra do fonte.
					cMethod := SubStr(aSource[2],nPos,23)
					If FindFunction(cFunction)
						aQuebra := &cFunction.(aSource[2],cMethod)
					Else
						Return {.F., STR0002} //"Integração não disponibilizada nesta versão de build. Favor atualizar para Build 7.00.131227A com data de geração superior a 08/09/2014"
					EndIf
					//Quebra o fonte, buscando pelo método receiveMessage.
					//aQuebra := StrTokArr2(aSource[2],'WSMETHOD receiveMessage')

					//O método receiveMessage será a ultima posição do array.
					cTexto := aQuebra[Len(aQuebra)]
					//Busca a primeira URL. "cSoap += '<receiveMessage xmlns="http://tempuri.org/">'"
					For nI := 1 To Len(cTexto)

						If Upper(SubStr(cTexto,nI,32)) == "CSOAP += '<RECEIVEMESSAGE XMLNS="

							//Encontrou a abertura da tag. Encontra a posição em que a tag é fechada para recuperar o link.
							For nJ := nI To Len(cTexto)
								If SubStr(cTexto,nJ,2) == ">'"
									//Encontrou o link. 
									::cLinkRM := SubStr(cTexto,nI+33,(nJ-1)-(nI+33))
									Exit
								EndIf
							Next nJ

							Exit
						EndIf

					Next nI

					//Busca os links que são passados por parâmetro para a função SvcSoapCall.
					//aQuebra := StrTokArr2(aSource[2],':= SvcSoapCall')
					If FindFunction(cFunction)
						aQuebra := &cFunction.(aSource[2],':= SvcSoapCall')
					Else
						Return {.F., STR0002} //"Integração não disponibilizada nesta versão de build. Favor atualizar para Build 7.00.131227A com data de geração superior a 08/09/2014"
					EndIf
					cTexto  := aQuebra[Len(aQuebra)]
					
					//Busca o local do fim da passagem de parâmetros.
					For nI := 1 To Len(cTexto)

						If SubStr(cTexto,nI,1) == ")"
							cTexto := SubStr(cTexto,1,nI-1)
							//Quebra pela passagem dos parâmetros.
							//aQuebra      := StrTokArr2(cTexto,',')
							If FindFunction(cFunction)
								aQuebra := &cFunction.(cTexto,',')
							Else
								Return {.F., STR0002} //"Integração não disponibilizada nesta versão de build. Favor atualizar para Build 7.00.131227A com data de geração superior a 08/09/2014"
							EndIf
							::cLinkSoap  := AllTrim(StrTran(aQuebra[3],'"'," "))
							::cNameSpace := AllTrim(StrTran(aQuebra[5],'"'," "))
							::cPostUrl   := AllTrim(StrTran(aQuebra[Len(aQuebra)],'"'," "))
							Exit
						EndIf

					Next nI

				Else
					lRet := .F.
					cMsg := STR0003 //"O link é um wsdl válido. Porém não contém os métodos utilizados para integração com o TOTVS MES. Favor verificar as configurações de conexão."				
				EndIf
			Else
				lRet := .F.
				cMsg := STR0004 //"Não foi possível realizar a conexão com o WebService do TOTVS MES. Favor verificar as configurações de conexão."
			EndIf
		Else
			lRet := .F.
			cMsg := STR0004 //"Não foi possível realizar a conexão com o WebService do TOTVS MES. Favor verificar as configurações de conexão."
		EndIf
	Else
		lRet := .F.
		cMsg := STR0005 //"Não existe caminho de WebService cadastrado. Verifique os parâmetros da integração."
	EndIf

	END WSMETHOD

Return {lRet, cMsg}

WSMETHOD RESET WSCLIENT WSPCFactory
	::cpXmlDocument      := NIL 
	::creceiveMessageResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSPCFactory
Local oClone := WSPCFactory():New()
	oClone:_URL                  := ::_URL 
	oClone:cpXmlDocument         := ::cpXmlDocument
	oClone:creceiveMessageResult := ::creceiveMessageResult
	oClone:cCaminho              := ::cCaminho
	oClone:cLinkRM               := ::cLinkRM
	oClone:cLinkSoap             := ::cLinkSoap
	oClone:cNameSpace            := ::cNameSpace
	oClone:cPostUrl              := ::cPostUrl
Return oClone

// WSDL Method receiveMessage of Service WSPCFactory

WSMETHOD receiveMessage WSSEND cpXmlDocument WSRECEIVE creceiveMessageResult WSCLIENT WSPCFactory
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<receiveMessage xmlns="' + ::cLinkRM + '">'
cSoap += WSSoapValue("pXmlDocument", ::cpXmlDocument, cpXmlDocument , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</receiveMessage>"

SOE->(dbSetOrder(1))
If SOE->(dbSeek(xFilial("SOE")+"SEGURANCA")) .And. SOE->(ColumnPos("OE_CHAR1"))
	If !Empty(SOE->OE_CHAR1) .And. !Empty(SOE->OE_MEMO1)
		If Self:_HEADOUT == Nil
			Self:_HEADOUT := {}
		EndIf
		Aadd(Self:_HEADOUT,"Authorization: Basic "+Encode64(AllTrim(SOE->OE_CHAR1)+":"+AllTrim(SOE->OE_MEMO1)))
	EndIf
EndIf
oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cLinkSoap,; 
	"DOCUMENT",::cNameSpace,,,; 
	::cPostUrl)

::Init()
::creceiveMessageResult :=  WSAdvValue( oXmlRet,"_RECEIVEMESSAGERESPONSE:_RECEIVEMESSAGERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/*
Executa a função para retornar o client ADVPL em outra thread, pois a função
WSDLSource utiliza variáveis estáticas que ficam com o valor incorreto quando a função
é chamada mais de uma vez.
*/
Static Function getClient(cCaminho)
   Local aSource := {}
   //Executa a nova Thread
   StartJob("WSPPIGetWS",GetEnvServer(),.T.,cCaminho)
   //Recupera o valor de retorno da função WSDLSource
   GetGlbVars("ASOURCEPPI",@aSource)
Return aSource

Function WSPPIGetWS(cCaminho)
   Local aSource := {}
   //Nova thread. Recupera os novo fonte client.
   aSource := WSDLSource(cCaminho)
   //Seta os valores para recuperar na thread que está executando o programa.
   PutGlbVars("ASOURCEPPI",aSource)
Return