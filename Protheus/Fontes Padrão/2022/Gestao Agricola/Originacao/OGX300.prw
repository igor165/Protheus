#Include�'tbiconn.ch'
#Include 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#include "OGX300.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} OGX300
Fun��o para execu��o somente via Schedule.
Integra��o com a M2M para atualiz��o de Moeda e Indices de Mercado

@author thiago.rover
@since 28/06/2017
@version P12
@type OGX300()
/*/    
//-------------------------------------------------------------------

Function OGX300(aParam)

	Local c_EmpAGro := aParam[1] //empresa
	Local c_FilAgro := aParam[2] //filial
	Local cMsg1		:= STR0001
	Local cMsg2		:= STR0002

	FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg1 , 0, 0, {}) //"Iniciando Schedule - Integra��o M2M"

	RpcSetType(3)//Nao consome licensas
	RpcSetEnv(c_empAGRO,c_filAGRO,,,"AGR",GetEnvServer(),{ }) //Abertura do ambiente em rotinas autom�ticas
	
	OGX300A()
	
	RpcClearEnv()   //Libera o Ambiente

	FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg2 , 0, 0, {}) //"Fim Schedule - Integra��o M2M"

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} OGX300A
Fun��o de Integra��o com a M2M para atualiz��o de Moeda e 
Indices de Mercado.

@author thiago.rover
@since 28/06/2017
@version P12
@type OGX300()
@uso OGX300,OGA420
@return Bolean, Retona .T. se conseguiu atualizar algum indice sen�o retona .F.
/*/   
//-------------------------------------------------------------------
Function OGX300A(cIndiceM, cData, cTipAtu) 	
	Local lRet			:= .F.
	Local cArqLog		:= "OGX300" + IIf (IsBlind()," - Schedule","") + ".log"

	Private _cToken := "" 
	Private _AGRResult := AGRViewProc():New()

	Default cIndiceM 	:= ""
	Default cData 		:= ""
	Default cTipAtu 	:= ""
	
	_AGRResult:EnableLog(cArqLog, STR0025 ,"2",.F.) //###"Integra��o API externa - Atualiza��o da cota��o de moedas e indices de Mercado"
	_AGRResult:Add(STR0003) //"Atualiza��o de moedas e �ndices de mercado iniciando..." 
	
	If OGX300AUT() //Autentica e gera o token na API M2M

		If cTipAtu == "MOEDA" .or. Empty(cTipAtu)
			lRet := OGX300B(cIndiceM) //atualiza as cota��es de moeda
		EndIf

		If cTipAtu == "INDICE" .or. Empty(cTipAtu)
			If ExistFunc("OGX300DUIB") 
				//se usa indice de bolsa de referencia
				lRet := OGX300D('',cIndiceM) //atualiza as cota��es de indices de bolsa de referencia(N8C/N8U)
			EndIF
				
			lRet := OGX300C(cIndiceM) //atualiza��o indices conforme tabela NK0
		EndIf
	Else
		//If .not. IsBlind()		
			//MsgInfo(STR0008,STR0007)
		//EndIf
		lRet := .F.
	EndIf
	
	_AGRResult:Add( STR0010 ) //###Atualiza��o de moedas e �ndices finalizado...
	
	_AGRResult:AGRLog:Save()
	_AGRResult:AGRLog:EndLog()
	If .not. IsBlind()		
		_AGRResult:Show() //mostra log na tela		
	EndIf

Return lRet

/*/{Protheus.doc} OGX300AUT
Realiza a autentica��o e gera��o do token na API M2M
@see Necessario que a fun��o chamadora declare variavel Private _cToken
@author thiago.rover/claudineia.reinert
@since 05/06/2018
@version P12 
@type function
@return Bolean, Retorna .T. se conseguiu realizar a autenti��o e gera��o do token na M2M, sen�o retona .F.
/*/
Function OGX300AUT()
	Local lRet := .F.
	Local cUrlAut 		:= SuperGetMv("MV_AGRO200")
	Local cEmail  		:= SuperGetMv("MV_AGRO201")
	Local cPasswd  		:= SuperGetMv("MV_AGRO202")
	Local oObjJSON := JsonObject():New() 
	Local cJson := ""
	Local aHeadOut := {}
	Local cHeadRet := ""
	Local sPostRet := ""
	Local nTimeOut := 5 //segundos 
	Local oObjJSONTK := Nil
	Local lValidToken := .F.
	Local nTent     := 0
	Local cToken    := ""
	Local cChars    := "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,0,1,2,3,4,5,6,7,8,9"
	Local nCh       := 0

	oObjJSON["email"]    := cEmail
	oObjJSON["password"] := cPasswd
	cJson := FWJsonSerialize(oObjJSON) //converte para uma string JSON

	AAdd( aHeadOut, "Accept: application/json" ) //necessario para lib superior abril/2018
	AAdd( aHeadOut, "Content-Type: application/json" )   
	
	_AGRResult:Add( STR0026 ) //###"Estabelecendo conex�o com a API externa"
	
	While !(lValidToken) .AND. (nTent < 10)
		sPostRet := HttpPost( cUrlAut,"",cJson,nTimeOut,aHeadOut,@cHeadRet )

		//FWJsonDeserialize - realiza o parse de uma string no formato Json para um objeto.
	    nTent := nTent + 1
		If !FWJsonDeserialize(sPostRet, @oObjJSONTK)
			lRet := .F.
			_AGRResult:Add( STR0008 , ,.T.) //.T. = adicionar AddErro() 
			//###"Erro Conex�o: N�o foi possivel realizar a conex�o com a API. Verifique os parametros de integra��o(MV_AGRO200,MV_AGRO201,MV_AGRO202) ou a conex�o com a internet."
		Else
			If oObjJSONTK:status == "Success" .and. !Empty(oObjJSONTK:response:token)
				lValidToken := .T.
				cToken := Upper(oObjJSONTK:response:token)//gerou token
				For nCh := 1 to len(cToken)
					If !(SubStr(cToken, nCh, 1) $ cChars)
						lValidToken := .F.
						Exit
					EndIf
				Next nCh

				If lValidToken
					_cToken :=  oObjJSONTK:response:token
					lRet := .T.
					_AGRResult:Add( STR0018 )//###"Autentica��o e gera��o do token na API realizado com sucesso."
					_AGRResult:Add( "" )
				EndIf
			Else
				lRet := .F.
				_AGRResult:Add( STR0019 + oObjJSONTK:status + ' - ' + oObjJSONTK:ERRORMESSAGE:MESSAGE  , ,.T.) //.T. = adicionar AddErro() 
				//###"ERRO AUT�NTICA��O: "
			EndIf
		EndIf
	EndDo
	
Return lRet

/*/{Protheus.doc} OGX300RPOST
Realiza a integra��o via requisi��o POST e busca pelo indice/ticker na API M2M 
@see Necessario que a fun��o chamadora declare variavel Private _cToken e preferencialmente tenha um token valido para API  
@author thiago.rover/claudineia.reinert
@since 05/06/2018
@version P12
@type function
@return Object, Retorna um objeto Json
/*/
Function OGX300RPOST(cUrl,cJson)
	Local aHeadOut 	:= {}
	Local cHeadRet 	:= ""
	Local sPostRet 	:= ""
	Local nTimeOut 	:= 5 //segundos  
	Local oJsonAPI	:= ""
	Local nTent		:= 2 //controle para while 

	AAdd( aHeadOut, "Accept: application/json" ) //necessario para lib superior abril/2018
	AAdd( aHeadOut, "Content-Type: application/json" )   

	While nTent > 0

		nTent -= 1 

		sPostRet := HttpPost( cUrl+Escape(_cToken),"",cJson,nTimeOut,aHeadOut,@cHeadRet ) //faz a requisi��o

		//FWJsonDeserialize - realiza o parse de uma string no formato Json para um objeto.
		If !FWJsonDeserialize(sPostRet, @oJsonAPI)
			_AGRResult:Add( STR0020 , ,.T.) //.T. = adicionar AddErro() 
			//###"Erro: N�o foi possivel realizar a conex�o com a API M2M. Verifique os parametros de URL de integra��o ou a conex�o com a internet."
			Exit //sai do while
		Else
			If UPPER(oJsonAPI:status) == "SUCCESS"  //se retornou sucesso
				Exit //sai do while
			Else
				//se houve algum erro
				If AT("TOKEN", UPPER(oJsonAPI:errormessage:message))  //procura na mensagem por token
					If .not. OGX300AUT() //tenta gerar novamente o token
						//n�o conseguiu gerar o token
						_AGRResult:Add( STR0021 + oJsonAPI:status + ' - ' + oJsonAPI:errormessage:message , ,.T.) //.T. = adicionar AddErro() 
						oJsonAPI := nil
						Exit //sai do while
					EndIf	
					//caso consiga gerar outro token vai pro while e tenta novamente buscar os dados
				Else 
					//outros erros
					_AGRResult:Add(STR0021 + oJsonAPI:status + ' - ' + oJsonAPI:errormessage:message , ,.T.) //.T. = adicionar AddErro() 
					oJsonAPI := nil
					Exit //sai do while
				EndIf
			EndIf
		EndIf	
	EndDo

Return oJsonAPI

/*/{Protheus.doc} OGX300RGET
Realiza a integra��o via requisi��o GET e busca pelo indice/ticker na API M2M 
@see Necessario que a fun��o chamadora declare variavel Private _cToken e preferencialmente tenha um token valido para API  
@author thiago.rover/claudineia.reinert
@since 05/06/2018
@version P12
@type function
@return Object, Retorna um objeto Json
/*/
Function OGX300RGET(cUrl,cJson)
	Local aHeadOut 	:= {}
	Local cHeadRet 	:= ""
	Local nTimeOut 	:= 5 //segundos 
	Local oJsonAPI	:= ""
	Local nTent		:= 2 //controle para while 
	
	AAdd( aHeadOut, "Accept: application/json" ) //necessario para lib superior abril/2018
	AAdd( aHeadOut, "Content-Type: application/json" )   

	While nTent > 0

		nTent -= 1 

		sGetRet := HttpGet( cUrl,"",nTimeOut,aHeadOut,@cHeadRet ) //faz a requisi��o

		//FWJsonDeserialize - realiza o parse de uma string no formato Json para um objeto.
		If !FWJsonDeserialize(sGetRet, @oJsonAPI)
			_AGRResult:Add( STR0020  , ,.T.) //.T. = adicionar AddErro() 
			//###"Erro Conex�o: N�o foi possivel realizar a conex�o com a API M2M. Verifique os parametros de URL de integra��o ou a conex�o com a internet."
			Exit //sai do while
		Else
			If UPPER(oJsonAPI:status) == "SUCCESS"  //se retornou sucesso
				Exit //sai do while
			Else
				//se houve algum erro
				If AT("TOKEN", UPPER(oJsonAPI:errormessage:message))  //procura na mensagem por token
					If .not. OGX300AUT() //tenta gerar novamente o token
						//n�o conseguiu gerar o token
						_AGRResult:Add( STR0021 , ,.T.) //.T. = adicionar AddErro() 
						oJsonAPI := nil
						Exit //sai do while
					EndIf	
					//caso consiga gerar outro token vai pro while e tenta novamente buscar os dados
				Else 
					//outros erros
					_AGRResult:Add( STR0021 + oJsonAPI:status + ' - ' + oJsonAPI:errormessage:message , ,.T.) //.T. = adicionar AddErro() 
					oJsonAPI := nil
					Exit //sai do while
				EndIf
			EndIf
		EndIf	
	EndDo

Return oJsonAPI