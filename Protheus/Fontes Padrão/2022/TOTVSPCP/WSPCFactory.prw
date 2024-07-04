#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "WSPCFACTORY.CH"

/* ===============================================================================
WSDL Location    http://104.41.45.71:43210/PcfIntegService?wsdl
Gerado em        08/21/15 11:02:56
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
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

	//Link SOAP passado por par�metro para a fun��o SvcSoapCall
	WSDATA   cLinkSoap                 AS string

	//Link NameSpace passado por par�metro para a fun��o SvcSoapCall
	WSDATA   cNameSpace                AS string

	//Link do WS passado por par�metro para a fun��o SvcSoapCall
	WSDATA   cPostUrl                  AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSPCFactory
::Init()
If !FindFunction("XMLCHILDEX")
	UserException(STR0001) //"O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.131227A-20150602] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual."
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

	//Busca o caminho do WS que est� cadastrado na SOD
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
					//Pega a defini��o do m�todo ReceiveMessage, para fazer a quebra do fonte.
					cMethod := SubStr(aSource[2],nPos,23)
					If FindFunction(cFunction)
						aQuebra := &cFunction.(aSource[2],cMethod)
					Else
						Return {.F., STR0002} //"Integra��o n�o disponibilizada nesta vers�o de build. Favor atualizar para Build 7.00.131227A com data de gera��o superior a 08/09/2014"
					EndIf
					//Quebra o fonte, buscando pelo m�todo receiveMessage.
					//aQuebra := StrTokArr2(aSource[2],'WSMETHOD receiveMessage')

					//O m�todo receiveMessage ser� a ultima posi��o do array.
					cTexto := aQuebra[Len(aQuebra)]
					//Busca a primeira URL. "cSoap += '<receiveMessage xmlns="http://tempuri.org/">'"
					For nI := 1 To Len(cTexto)

						If Upper(SubStr(cTexto,nI,32)) == "CSOAP += '<RECEIVEMESSAGE XMLNS="

							//Encontrou a abertura da tag. Encontra a posi��o em que a tag � fechada para recuperar o link.
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

					//Busca os links que s�o passados por par�metro para a fun��o SvcSoapCall.
					//aQuebra := StrTokArr2(aSource[2],':= SvcSoapCall')
					If FindFunction(cFunction)
						aQuebra := &cFunction.(aSource[2],':= SvcSoapCall')
					Else
						Return {.F., STR0002} //"Integra��o n�o disponibilizada nesta vers�o de build. Favor atualizar para Build 7.00.131227A com data de gera��o superior a 08/09/2014"
					EndIf
					cTexto  := aQuebra[Len(aQuebra)]
					
					//Busca o local do fim da passagem de par�metros.
					For nI := 1 To Len(cTexto)

						If SubStr(cTexto,nI,1) == ")"
							cTexto := SubStr(cTexto,1,nI-1)
							//Quebra pela passagem dos par�metros.
							//aQuebra      := StrTokArr2(cTexto,',')
							If FindFunction(cFunction)
								aQuebra := &cFunction.(cTexto,',')
							Else
								Return {.F., STR0002} //"Integra��o n�o disponibilizada nesta vers�o de build. Favor atualizar para Build 7.00.131227A com data de gera��o superior a 08/09/2014"
							EndIf
							::cLinkSoap  := AllTrim(StrTran(aQuebra[3],'"'," "))
							::cNameSpace := AllTrim(StrTran(aQuebra[5],'"'," "))
							::cPostUrl   := AllTrim(StrTran(aQuebra[Len(aQuebra)],'"'," "))
							Exit
						EndIf

					Next nI

				Else
					lRet := .F.
					cMsg := STR0003 //"O link � um wsdl v�lido. Por�m n�o cont�m os m�todos utilizados para integra��o com o TOTVS MES. Favor verificar as configura��es de conex�o."				
				EndIf
			Else
				lRet := .F.
				cMsg := STR0004 //"N�o foi poss�vel realizar a conex�o com o WebService do TOTVS MES. Favor verificar as configura��es de conex�o."
			EndIf
		Else
			lRet := .F.
			cMsg := STR0004 //"N�o foi poss�vel realizar a conex�o com o WebService do TOTVS MES. Favor verificar as configura��es de conex�o."
		EndIf
	Else
		lRet := .F.
		cMsg := STR0005 //"N�o existe caminho de WebService cadastrado. Verifique os par�metros da integra��o."
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
Executa a fun��o para retornar o client ADVPL em outra thread, pois a fun��o
WSDLSource utiliza vari�veis est�ticas que ficam com o valor incorreto quando a fun��o
� chamada mais de uma vez.
*/
Static Function getClient(cCaminho)
   Local aSource := {}
   //Executa a nova Thread
   StartJob("WSPPIGetWS",GetEnvServer(),.T.,cCaminho)
   //Recupera o valor de retorno da fun��o WSDLSource
   GetGlbVars("ASOURCEPPI",@aSource)
Return aSource

Function WSPPIGetWS(cCaminho)
   Local aSource := {}
   //Nova thread. Recupera os novo fonte client.
   aSource := WSDLSource(cCaminho)
   //Seta os valores para recuperar na thread que est� executando o programa.
   PutGlbVars("ASOURCEPPI",aSource)
Return