#INCLUDE "Totvs.CH"
#Include 'RestFul.CH'
#include "PROTHEUS.CH"
#Include 'FINI230O.CH'

Static oTmpTb	As Object
Static _lSubCta	As Logical

//-------------------------------------------------------------------
/*/{Protheus.doc} FINI230O()
Retorno da comunicão bancaria de integração com o TCB via Job 

@author Edson Borges de Melo
@since  24/09/2020
@version 12.1.027
/*/
//-------------------------------------------------------------------
Function FINI230O(aInfo As Array)
    Local lJob          As Logical
	Local cCodEmp       As Char
	Local cCodFil       As Char
	Local oTCB          As Object
	
    lJob    := (Type("cFilAnt") == "U")
	cCodEmp := ""
	cCodFil := ""
	
	If Len(aInfo) > 0
		cCodEmp     := aInfo[1]
		cCodFil     := aInfo[2]
	EndIf
	
	SetFunName("FINI230O")
	
    FwLogMsg("INFO",, "TECHFIN", FunName(), "", "01", FwNoAccent(STR0001), 0, 0, {})  // "Iniciando execução Job TOTVS Connect Bank."
	
    //Se job e parâmetros em branco
    If lJob .And. (Empty(cCodEmp) .Or. Empty(cCodFil))
        FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0002 + STR0003,  0, 0, {})   // "FINI230O: Parâmetros 'cCodEmp' ou 'cCodFil' estão vazios."
        Return
    ElseIf !lJob .And. !(Empty(cCodEmp)) .And. cEmpAnt != cCodEmp //Caso não seja execução via job, parametro empresa tenha sido informado e a empresa seja a mesma
        If IsBlind()
            FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0002 + STR0004, 0, 0, {})  // "FINI230O: Empresa atual difere da empresa informada por parâmetro."
        Else
            Help("", 1, "HELP", "HELP", STR0002 + STR0004 + STR0005, 1,,,,,,, {})   // "FINI230O: Empresa atual difere da empresa informada por parâmetro." + " A rotina será encerrada." 
        EndIf
        Return
    EndIf
	
	//Verifica se a empresa está montada
    If lJob
        RpcSetEnv(cCodEmp, cCodFil, /*cUser*/, /*cPass*/, "FIN", FunName(), {"SA2", "SA6", "SE2", "SEA", "SEE"})
    EndIf
	
	//Efetua a trava para apenas efetuar um processamento por empresa
    If !(LockByName("FINI230JOB" + cEmpAnt))
        FwLogMsg("INFO",, "TECHFIN", FunName(), "", "01", STR0002+STR0006, 0, 0, {})  // "FINI230O: JOB em execução."
        Return
    EndIf
	
	oTCB := TCBConnect():New()
	FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0002 + STR0007,  0, 0, {})  // "FINI230O: Lendo fila de retornos no TCB."
	
	oTCB:BuildTemp()
	oTCB:DownloadPag()
	
    FwLogMsg("INFO",, "TECHFIN", FunName(), "", "01", FwNoAccent(STR0009), 0, 0, {})  // "Encerrando execução Job TOTVS Connect Bank."
	
	oTCB:ClearTemp()
	FreeObj(oTCB)
    UnlockByName("FINI230JOB" + cEmpAnt)
	
    // Desconecta o ambiente
    If lJob
        RpcClearEnv()
    EndIf
Return

/*{Protheus.doc} Classe para tratamento da conexão com o TOTVS CONNECT BANK
@author Edson Melo
@since 11/09/2020
@version version 
@param 
@return 
*/
Class TCBConnect
    
	data cUrl 	  As Char
	data cCnpjFil As Char
    

    // oAuth2
	data cMtdAuth2 		As char
	data lConnected 	As Logical

	//Token
	data cToken 		 As Char
	data cTimeExpiration As Char
    data dDateExpiration As Date

	// Upload
	data cMtdUpload As Char

	// Fila
	data cMtdFila 	As Char
	data aFilaFiles As Array

	// Gestao de processamento
	data cAliasTmp	As Char

	//Tratamento de retorno da API
	data cStatusRet 	As Char
	data cMessageError	As Char
    
    Method New()
    Method GetToken()
	Method ValidConn()
	Method UploadPag()
	Method DownloadPag()
	Method FilaPag()
	Method ExpirationDate()
	Method SetURL()
	Method BuildTemp()
	Method ClearTemp()
	
EndClass

/*{Protheus.doc} Metodo construtor da classe para buscar o token do TCB 
@author Edson Melo
@since 11/09/2020
@version version 
@param 
@return 
*/
Method new() class TCBConnect	
	Local cEndUrl  As Char
	Local nPosCGC  As Numeric
	Local nPosNam  As Numeric
	Local aSM0Data As Array    
	
	Self:cToken     := ""
	Self:cUrl       := "https://prd-tcb.tfs.totvs.com"
	Self:cMtdAuth2  := "/tcbseguranca/oauth/token"
	Self:cMtdUpload := "/tcbapi/erp/v1/remessas/upload"
	Self:cMtdFila	:= "/tcbapi/erp/v1/remessas/retornos/download"
	Self:cCnpjFil   := ""
	Self:cStatusRet := ""
	Self:cMessageError := ""
	
	//Inicializa variáveis.
	cEndUrl  := ""
	aSM0Data := FWSM0Util():GetSM0Data(cEmpAnt , cFilAnt , {"M0_CGC", "M0_NOME"}) 
	nPosCGC  := AScan(aSM0Data, {|x| x[1] == "M0_CGC"})
	nPosNam  := AScan(aSM0Data, {|x| x[1] == "M0_NOME"})
	
	If nPosCGC > 0
		Self:cCnpjFil := aSM0Data[nPosCGC, 2]
	EndIf
	
	If nPosNam
		cNomeCli := Rtrim(aSM0Data[nPosNam, 2])
	EndIf
	
	If cEmpAnt == "T1" .and. cNomeCli == "Grupo TOTVS 1"
		Self:cCnpjFil := "53113791000122"
	EndIf
	
	//Carrega inicalizador padrão das variáveis do TCB
	oConfig := FWTFConfig()
	If ValType(oConfig["fin_url_TCB"]) <> "U"
		Self:cUrl := Alltrim(oConfig["fin_url_TCB"])
		cEndUrl   := Alltrim(Self:cUrl) 
		
		If Rat("/", cEndUrl) == Len(cEndUrl)
			Self:cUrl := Substring(cEndUrl, 1, (Len(cEndUrl)-1))
		EndIf
	EndIf
	
	FwFreeArray(aSM0Data)	
Return()

/*{Protheus.doc} GetToken Metodo que solicita o token ao WS em REST do TCB
@since 26/03/2020 
@version Edson Melo
@return l_Ret, bool, ;.T. se conseguiu obter o token de acesso 
*/ 
Method GetToken() class TCBConnect    
	Local cPostParms   As Char 
    Local aHeadStr     As Array
    Local cResult      As Char 
    Local nTokenExpire As Numeric
    Local oRestClient  As Object
    Local oJson        As Object
	Local dData        As Date
	Local nTempo       As Numeric
	Local cClientId    As Char
	Local cCliSecret   As Char
	Local cChave       As Char
	Local oConfig      As Object

	cPostParms   := ""
    aHeadStr     := {}
    cResult      := ""
    nTokenExpire := 0
    oRestClient  := FWRest():New(Self:cUrl)
    oJson        := JsonObject():new()

	cChave := Strtran(cEmpAnt," ","_") + "|" + Strtran(cFilAnt," ","_")
	cClientId := ""
	cCliSecret := ""

	oConfig := FWTFConfig()
	if ValType(oConfig[ "fin_cpfTCB_" + cChave ]) <> "U"
		cClientId  := "ext::"+alltrim(Self:cCnpjFil)+"::"+alltrim(oConfig[ "fin_cpfTCB_" + cChave ])
	Endif
	if ValType(oConfig[ "fin_pwdTCB_" + cChave  ]) <> "U"
    	cCliSecret := alltrim(oConfig[ "fin_pwdTCB_" + cChave  ])
	EndIf
	
	aadd(aHeadStr,'Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryFbmu0bODj7UvfQEV')
	aadd(aHeadStr, 'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
    AAdd(aHeadStr, "charset: UTF-8")
	AAdd(aHeadStr, "Authorization: Basic " + "Y2xpZW50U2VndXJhbmNhQXBpVENCOjknKCk2dndwJDNMe2c3J2gmdUFXfVBdcC0=" )

	cPostParms := '------WebKitFormBoundaryFbmu0bODj7UvfQEV'
	cPostParms += CRLF
	cPostParms += 'Content-Disposition: form-data; name="username"'
	cPostParms += CRLF
	cPostParms += CRLF
	cPostParms += cClientId
	cPostParms += CRLF
	cPostParms += '------WebKitFormBoundaryFbmu0bODj7UvfQEV'
	cPostParms += CRLF
	cPostParms += 'Content-Disposition: form-data; name="password"'
	cPostParms += CRLF
	cPostParms += CRLF
	cPostParms += cCliSecret
	cPostParms += CRLF
	cPostParms += '------WebKitFormBoundaryFbmu0bODj7UvfQEV'
	cPostParms += CRLF
	cPostParms += 'Content-Disposition: form-data; name="grant_type"'
	cPostParms += CRLF
	cPostParms += CRLF
	cPostParms += "password"
	cPostParms += CRLF
	cPostParms += '------WebKitFormBoundaryFbmu0bODj7UvfQEV--'

	oRestClient:setPath(Self:cMtdAuth2)
	oRestClient:SetPostParams(cPostParms)
	
	If oRestClient:Post(aHeadStr)
		cResult := oJson:FromJson(oRestClient:GetResult())
		
		If ValType(cResult) == "U"                        // -- Nil indica que conseguiu popular o objeto com o Json
			dData           := Date()
    		nTempo          := Seconds()
			Self:cToken     := oJson["access_token"]      // -- Chave de acesso
			nTokenExpire    := oJson["expires_in"] / 60   // -- Expiração do token em minutos
			Self:ExpirationDate(dData, nTempo, nTokenExpire)
			
			Self:cMessageError := ""
		Else
			Self:cMessageError := cResult
		EndIf
		
		Return(.T.)
	Else
		If ValType(oRestClient:GetResult()) != "C"
			Self:cMessageError := STR0014 + oRestClient:cHost + CRLF + STR0015
		Else
			Self:cMessageError := oRestClient:GetResult()
		EndIf
	EndIf
	
Return(.F.)

//-------------------------------------------------------------------------------------
/*{Protheus.doc} Método faz a validação da conexão
@since 26/03/2020 
@version Edson Melo
@param cFile, char, informa o caminho do arquivo de pagamento gerado
@return l_Ret, bool, ;.T. se conseguiu obter o token de acesso 
*/
//-------------------------------------------------------------------------------------
Method ValidConn() class TCBConnect
	Self:lConnected := Self:GetToken()
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FilaPag - Descontinuado
Metodo responsavel converter dias em horas

(método inativo, pois criamos uma fila customizada na temporaria)

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27
@param nTokenExpire, Numerico, tempo para conversão
@param cTipo, Caracter, tipo da conversão
@return Nil, nulo
/*/
//-------------------------------------------------------------------------------------
Method FilaPag() Class TCBConnect

	Local aHeadStr   As Array
	Local aDataJson  As Array
	Local cRetAPI    As Char
	
	aHeadStr  := {}
	aDataJson := {}


	self:GetToken()
	aadd(aHeadStr, 'Authorization: Bearer ' + Self:cToken )

	oObjREST := FWRest():New( Self:cUrl )
	oObjREST:setPath( Self:cMtdFila )

	If oObjREST:Get( aHeadStr )
		oJSON := JSONObject():New()
		cRetAPI := oJson:FromJson(oObjREST:GetResult())
		If ValType(cRetAPI) == "U"
			cRetAPI := oObjREST:GetResult()
			FwJSONDeserialize(cRetAPI, @aDataJson)

			Self:aFilaFiles := aClone(aDataJson:data:retornos)

			Self:cStatusRet := oObjREST:oResponseH:cStatusCode

		EndIf
	Else
		cRetAPI := oObjREST:GetResult()
		If ValType(oObjREST:oResponseH:cStatusCode) == "U"
			Self:cStatusRet := "---"
		ELse
			Self:cStatusRet := oObjREST:oResponseH:cStatusCode
		EndIf
	EndIf

Return

//-------------------------------------------------------------------------------------
/*{Protheus.doc} Método faz o download do arquivo de retorno de pagamento do o TCB
Download ocorre após o processamento do arquivo pelo banco ou caso o arquivo não
tenha passado pelo validador do TCB

@since 26/03/2020 
@version Edson Melo
@return l_Ret, bool, ;.T. se conseguiu obter o token de acesso 
*/
//-------------------------------------------------------------------------------------
Method DownloadPag( ) class TCBConnect	
	Local cDir       As Char
	Local cNomeFile  As Char
	Local cDados     As Char
	Local cRetAPI    As Char
	Local cIdArq	 As Char
	Local cPath		 As Char
	Local cErrorMsg	 As Char
	Local nI         As Numeric
	Local aHeadStr   As Array
	Local aArea		 As Array
	
	//Inicializa variáveis
	cDir       := ""
	cNomeFile  := ""
	cDados     := ""
	cRetAPI    := ""
	nI         := 0
	aHeadStr   := {}

	If (Self:cAliasTmp)->(!EoF())

		aArea := GetArea()
		dbSelectArea("SEE")
		dbSetOrder(1)

		self:GetToken()
		AAdd(aHeadStr, "Authorization: Bearer " + Self:cToken )
		AAdd(aHeadStr, "Accept: application/json, text/plain, */*" )
		
		oObjREST := FWRest():New( Self:cUrl )

		While (Self:cAliasTmp)->(!EoF())

			cIdArq	  := AllTrim((Self:cAliasTmp)->FWO_IDTCB)
			cNomeFile := cIdArq + ".ret"

			cPath 	  := (Self:cMtdFila + "?codigoArquivo=" + Soma1(cIdArq))	// Queryparam com o ID de retorno
			
			oObjREST:setPath( cPath )
			If oObjREST:Get( aHeadStr )
				oJSON := JSONObject():New()
				cRetAPI := oJson:FromJson(oObjREST:GetResult())
				
				If ValType(cRetAPI) == "U"
					If Empty(cDir := ValidDir(Self:cAliasTmp,cIdArq))
						(Self:cAliasTmp)->(dbSkip())
						Loop
					EndIf
					cDados := oObjREST:GetResult()
					If MemoWrite( (cDir + cNomeFile), cDados )
						FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0002 + STR0011 + cDir + cNomeFile,  0, 0, {})	// "FINI230O: Recebendo arquivo "
						Self:cStatusRet := oObjREST:oResponseH:cStatusCode
					Else
						//STR18 - Erro ao criar arquivo no diretório.
						FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", (cValToChar(FError())+" - "+STR0018), 0, 0, {})
					EndIf
				EndIf
			Else
				cRetAPI := oObjREST:GetResult()
				If ValType(oObjREST:oResponseH:cStatusCode) == "U"
					Self:cStatusRet := "---"
				ELse
					Self:cStatusRet := oObjREST:oResponseH:cStatusCode
				EndIf
				
				//Imprimir no console o erro
				cErrorMsg := STR0002 + STR0012 + cNomeFile + STR0013
				If ValType(cRetAPI) == "C" .and. cRetAPI <> Nil
					cErrorMsg += cRetAPI
				EndIf
				FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", cErrorMsg,  0, 0, {})
			EndIf

			(Self:cAliasTmp)->(dbSkip())
		EndDo

		RestArea(aArea)
	Else
		FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0002 + STR0008,  0, 0, {})  // "FINI230O: Não há retornos disponíveis."
	EndIf

Return

//-------------------------------------------------------------------------------------
/*{Protheus.doc} Método faz o upload do arquivo borderô para o TCB e obtem o ID de integração
@since 26/03/2020 
@version Edson Melo
@param cFile, char, informa o nome do arquivo
@param cNumBor, char, Número do borderô referente ao arquivo cFile
@param cBanco, char, Banco do borderô cNumBor
@param cAgencia, char, Agência do borderô cNumBor
@param cConta, char, Conta do borderô cNumBor
*/
//-------------------------------------------------------------------------------------
Method UploadPag( cFile, cNumBor, cBanco, cAgencia, cConta ) class TCBConnect
	Local aHeadStr   As Array
	Local aDataJson  As Array
	Local cFileName  As Char
	Local cFileCont  As Char
	Local cRetAPI    As Char
	Local nIdRet     As Numeric
	Local aSM0Data	As Array
	Local nPosNam	As Numeric
	Local cNomeCli	As Char

	aHeadStr  := {}
	aDataJson := {}
	nIdRet    := 0
    self:GetToken()
	
	cFileCont := MemoRead( cFile )
	cFileName := SubStr( cFile, rat("\",cFile) + 1, Len(cFile) )
	aSM0Data  := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_CGC", "M0_NOME"} ) 
	nPosNam   := aScan(aSM0Data, {|x| x[1] == "M0_NOME"})
	
	If nPosNam > 0
		cNomeCli := rtrim(aSM0Data[nPosNam,2])
	EndIf
	
	// TODO - Colocar LAUTOMATO
	If cEmpAnt == "T1" .and. cNomeCli == "Grupo TOTVS 1"
		cFileCont := Strtran(cFileCont, "53485215000106", "53113791000122")
	EndIf
	
	oObjREST := FWRest():New( Self:cUrl )
	oObjREST:setPath( Self:cMtdUpload )
	
	aadd(aHeadStr,'Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryFbmu0bODj7UvfQEV')
	aadd(aHeadStr, 'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
    AAdd(aHeadStr, "charset: UTF-8")
	AAdd(aHeadStr, "Authorization: Bearer " + Self:cToken )
	
	cPostParms := '------WebKitFormBoundaryFbmu0bODj7UvfQEV'
	cPostParms += CRLF
	cPostParms += 'Content-Disposition: form-data; name="nrCnpj"'
	cPostParms += CRLF
	cPostParms += CRLF
	cPostParms += Self:cCnpjFil
	cPostParms += CRLF

	cPostParms += '------WebKitFormBoundaryFbmu0bODj7UvfQEV'
	cPostParms += CRLF
	cPostParms += 'Content-Disposition: form-data; name="codigoBanco"'
	cPostParms += CRLF
	cPostParms += CRLF
	cPostParms += cBanco
	cPostParms += CRLF

	cPostParms += '------WebKitFormBoundaryFbmu0bODj7UvfQEV'
	cPostParms += CRLF
	cPostParms += 'Content-Disposition: form-data; name="codigoAgencia"'
	cPostParms += CRLF
	cPostParms += CRLF
	cPostParms += cAgencia
	cPostParms += CRLF

	cPostParms += '------WebKitFormBoundaryFbmu0bODj7UvfQEV'
	cPostParms += CRLF
	cPostParms += 'Content-Disposition: form-data; name="codigoContaCorrente"'
	cPostParms += CRLF
	cPostParms += CRLF
	cPostParms += cConta
	cPostParms += CRLF

	cPostParms += '------WebKitFormBoundaryFbmu0bODj7UvfQEV'
	cPostParms += CRLF
	cPostParms += 'Content-Disposition: form-data; name="duplicada"'
	cPostParms += CRLF
	cPostParms += CRLF
	cPostParms += 'S'  //Informa se pode enviar arquivo duplicado
	cPostParms += CRLF

	cPostParms += '------WebKitFormBoundaryFbmu0bODj7UvfQEV'
	cPostParms += CRLF
	cPostParms += 'Content-Disposition: form-data; name="files"; filename="'+cFileName+'"'
	cPostParms += CRLF
	cPostParms += 'Content-Type: text/plain'
	cPostParms += CRLF
	cPostParms += CRLF
	cPostParms += cFileCont
	cPostParms += CRLF
	cPostParms += '------WebKitFormBoundaryFbmu0bODj7UvfQEV--'
	
	oObjREST:setPostParams( cPostParms )

	If oObjREST:Post( aHeadStr )
		oJSON := JSONObject():New()
		cRetAPI := oJson:FromJson(oObjREST:GetResult())
		If ValType(cRetAPI) == "U"
			cRetAPI := oObjREST:GetResult()
			FwJSONDeserialize(cRetAPI, @aDataJson)
			nIdRet := aDataJson[1]:data:id
			Self:cStatusRet := oObjREST:oResponseH:cStatusCode 
		EndIf
	Else
		cRetAPI := oObjREST:GetResult()
		If ValType(oObjREST:oResponseH:cStatusCode) == "U"
			Self:cStatusRet := "---"
		ELse
			Self:cStatusRet := oObjREST:oResponseH:cStatusCode
		EndIf
	EndIf
    
	F230GRAVA(cNumBor, cFileName, __cUserID, nIdRet, Self:cStatusRet, cRetAPI)	
    FwFreeArray(aSM0Data)
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ExpirationDate
Metodo responsavel converter dias em horas

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@param nTokenExpire, Numerico, tempo para conversão
@param cTipo, Caracter, tipo da conversão

@return Nil, nulo
/*/
//-------------------------------------------------------------------------------------
Method ExpirationDate(dData, nTempo, nTokenExpire, cTipo) Class TCBConnect
    Local cTime As Char
    Local nHora As Numeric
    Local nDias As Numeric
	Default cTipo     := "M" 

	cTime       := ""
	nHora       := 0
	nDias       := 0

    If Upper(cTipo) = "H"
        nTokenExpire := nTokenExpire * 60
    ElseIf Upper(cTipo) = "S"
        nTokenExpire := nTokenExpire / 60
    EndIf 

    cTime := IncTime(time(),,nTokenExpire)
    nHora := Val(SubStr(cTime,1,2))

    While  nHora > 24
        nHora := nHora - 24
        nDias ++
    EndDo
	
    Self:cTimeExpiration := STRZero(nHora,2) + SubStr(cTime,3,Len(cTime))
    Self:dDateExpiration := Date() + nDias
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetURL
Configura a URL de acesso ao TCB (usado para testes no amb. de homolog.)
https://demonstra-tcb.tfs.totvs.com/

@author     Igor Nascimento
@since      01/09/2021
@version    12.1.33
@param cNewURL, URL que sera considerada na conexao com o TCB
/*/
//-------------------------------------------------------------------------------------
Method SetURL(cNewURL) class TCBConnect

	Default cNewURL := Self:cUrl

	Self:cUrl := cNewURL

Return

/*/{Protheus.doc} BuildTemp
Cria tabela temporaria para embasar o processamento
	dos downloads

@author     Igor Nascimento
@since      25/10/2021
@version    12.1.33
/*/
Method BuildTemp() class TCBConnect

	Local aFields	 As Array
	Local aStructAux As Array
	Local cFields	 As Char
	Local cQuery	 As Char
	Local cInsert	 As Char
	Local cAlias	 As Char
	Local cSGBD		 As Char
	Local nLenFields As Numeric
	Local nI 		 As Numeric
	Local nTcSql	 As Numeric

	aFields    := {}
	_lSubCta   := If(_lSubCta == Nil, SEA->(FieldPos("EA_SUBCTA")) > 0, _lSubCta)
	cFields    := "FWO_FILIAL,FWO_IDTCB,FWO_NUMBOR,EA_FILIAL,EA_PORTADO,EA_AGEDEP,EA_NUMCON"
	If _lSubCta
		cFields += ",EA_SUBCTA"
	EndIf
	aStructAux := StrToKarr2(cFields,",")
	cSGBD	   := AllTrim(TcGetDb())

	cQuery := "SELECT " + cFields + " "
	cQuery += "FROM " + RetSqlName("FWO") + " FWO "
	cQuery += 	"INNER JOIN " + RetSqlName("SEA") + " SEA "
	cQuery += 	"ON SEA.EA_FILIAL = '" +xFilial("SEA")+ "' AND SEA.EA_NUMBOR = FWO.FWO_NUMBOR "
	cQuery += "WHERE FWO.FWO_CODRET = '200' "
	cQuery += 	"AND FWO.FWO_STATUS = '0' "
	cQuery += 	"AND FWO.D_E_L_E_T_ = ' ' "
	cQuery += 	"AND SEA.EA_CART = 'P' "
	cQuery += 	"AND SEA.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY FWO_FILIAL, FWO_IDTCB, FWO_NUMBOR"
	cQuery := ChangeQuery(cQuery)

	cAlias := GetNextAlias()

	oTmpTb := FwTemporaryTable():New(cAlias)

	nLenFields := Len(aStructAux)
	For nI := 1 To nLenFields
		Aadd(aFields, {;
			aStructAux[nI],;
			GetSx3Cache(aStructAux[nI],"X3_TIPO"),;
			GetSx3Cache(aStructAux[nI],"X3_TAMANHO"),;
			GetSx3Cache(aStructAux[nI],"X3_DECIMAL");
		})
	Next nI

	oTmpTb:SetFields(aFields)
	oTmpTb:AddIndex("1",{"FWO_FILIAL","FWO_IDTCB","FWO_NUMBOR"})
	oTmpTb:Create()

	cInsert := " INSERT "

	If cSGBD == "ORACLE"
		cInsert += " /*+ APPEND */ "
	EndIf

	If cSGBD == "DB2"
		cQuery := StrTran(cQuery, "FOR READ ONLY", "")
	EndIf

	cInsert += " INTO " + oTmpTb:GetRealName() + " (" + cFields + " ) " + cQuery

	nTcSql := TcSQLExec(cInsert)

	If nTcSql == 0
		dbSelectArea(cAlias)
		(cAlias)->(dbGoTop())
		Self:cAliasTmp := cAlias
	EndIf

Return

/*/{Protheus.doc} ClearTemp
Exclui tabela temporaria criada no inicio do processo

@author     Igor Nascimento
@since      25/10/2021
@version    12.1.33
/*/
Method ClearTemp() class TCBConnect

	If Self:cAliasTmp <> Nil
		(Self:cAliasTmp)->(dbCloseArea())
	EndIf
	If oTmpTb <> Nil
		oTmpTb:Delete()
		FreeObj(oTmpTb)
	EndIf

Return

/*/{Protheus.doc} ValidDir
Valida se o diretorio foi configurado na SEE

@param cTmp - Alias temporario da classe
@param cIdArq - ID do arquivo (ID TCB)
@return cDir - Diretorio a ser usado no download
@author     Igor Nascimento
@since      26/10/2021
@version    12.1.33
/*/
Static Function ValidDir(cTmp As Char, cIdArq As Char) As Char

	Local cCodErro   As Char
	Local cMensagem  As Char
	Local cDir       As Char
	Local cChaveSEE  As Char
	Local lRet       As Logical
	Local lDiretorio As Logical
	Local nRet       As Numeric

	Default cIdArq	:= ""

	cCodErro   := ""
	cMensagem  := ""
	cDir       := ""
	lRet       := .T.
	lDiretorio := .F.
	nRet       := 0

	// Selecao do diretorio para download
	If (cTmp)->(dbSeek( xFilial("FWO")+cIdArq ) )
		
		cChaveSEE := xFilial("SEE")+(cTmp)->(EA_PORTADO+EA_AGEDEP+EA_NUMCON)
		If _lSubCta
			cChaveSEE += AllTrim((cTmp)->EA_SUBCTA)
		EndIf

		If SEE->(dbSeek(cChaveSEE, .T. ) )
			If !Empty(cDir := Alltrim(SEE->EE_DIRPAG))
				If !ExistDir(cDir)
					If (nRet := (MAKEDIR(cDir))) != 0
						lRet := .F.
						If !Empty(cCodErro)
							cCodErro := cCodErro + CRLF
						EndIf
						cCodErro := cDir + CRLF + STR0017 + cValToChar(FError())
					Else
						lDiretorio := .T.
					EndIf
				Else
					lDiretorio := .T.
				EndIf
			EndIf
		EndIf
	EndIf

	If (!lDiretorio .Or. !lRet)
		If !lDiretorio 
			cMensagem :=  STR0010 //Não encontrado registro na tabela SEE para verificação da pasta de gravação dos arquivos de retorno.
		Else
			cMensagem := (STR0016 + CRLF + cCodErro) //Não foi possível criar o (s) diretório (s):
		EndIf
		
		FwLogMsg("ERROR", Nil, "TECHFIN", FunName(), "", "01", FwNoAccent(cMensagem), 0, 0, {})
	EndIf

Return cDir
