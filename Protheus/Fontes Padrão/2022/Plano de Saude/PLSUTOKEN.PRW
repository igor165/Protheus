#include "protheus.ch"

/*/{Protheus.doc} PLSTKSEEDG
	Função que cria seed para um usuário e grava-o na BA1. Esse seed é utilizado como input, tanto
		pelo PLS quanto pelo Aplicativo, para geração do Token.
		O seed gerado por esta função deve ser gravado no registro do usuário e compartilhado com o
		aplicativo responsável pelo armazenamento da carteirinha e geração do Token para atendimento.
    @author Thiago Paris
    @since 30/09/2020
    @version 1.0
    @params cMatric, string, matrícula do usuário, obrigatório
        lAtualiza, boolean, gera novo seed caso existir? , obrigatório
    @return aRet, array, array contendo status da requisição e seed gerado
        aRet[1] = Status de retorno (.T. = Sucesso, .F. = Falhou)
		aRet[2] = Seed Gerado
    /*/
Function PLSTKSEEDG(cMatric, lAtualiza)
Local lRet     := .T.
Local cSeed    := ""
Local nT       := 0
Local cT       := ""
Local nRet     := 0
Local cRet     := ""
Local nSHAx    := 7 // Algoritmo utilizado pela função HMAC na geração do Seed: 3=SHA1;5=SHA256;7=SHA512
Local nRetTp   := 1 // Tipo de retorno da função HMAC na geração do Seed: 1=Raw;2=Hex
Local nCType   := 3 // Tipo do input utilizado na função HMAC para geração do Seed: 1=Text;2=Base64;3=Hex
Local nKType   := 1 // Tipo da chave utilizada na função HMAC para geração do Seed: 1=Text;2=Base64;3=Hex
Local nSeedTam := 32 // Tamanho do Seed gerado (depende do tipo a seguir)
Local nSeedTp  := GetNewPar("MV_PLSTKST", 1) // Tipo do Seed gerado 1=Text;2=Base64;3=Hex
Local nSHAxTk  := GetNewPar("MV_PLSTKSH", 5) // Algoritmo a ser utilizado na geração do Token: 3=SHA1;5=SHA256;7=SHA512

Local aAreaBA1 := {}

aAreaBA1 := BA1->(GetArea())

// nT = Divisão inteira do epoch atual pelo step a ser considerado (30min)
// para a geração do Token
nT := int(val(FWTimeStamp(4)))
cT := __DECTOHEX(nT)
While Len(cT) < 16
	cT := "0" + cT
EndDo

// O tamanho do seed depende do algoritmo de hash utilizado.
If nSHAxTk == 3
	nSeedTam := 20
Elseif nSHAxTk == 5
	nSeedTam := 32
Else
	nSeedTam := 64
EndIf

// Trata o seed dependendo de como ele será utilizado na geração do token
If nSeedTp == 1 .Or. nSeedTp == 2 //Text ou Base64
	nRetTp := 1 //Raw
Else //Hex
	nRetTp := 2 //Hex
EndIf

BA1->(DbSetOrder(2))
If BA1->(MsSeek(xFilial("BA1")+cMatric))
	cSeed := AllTrim(BA1->BA1_TKSEED)
	If Empty(cSeed) .Or. lAtualiza
		//Gera Token (BA1->(ba1_codint+ba1_codemp+ba1_matric+ba1_tipreg+ba1_digito+AllTrim(ba1_nomusr)+dtos(ba1_datnas)))
		//Usa essa chave até ficar maior q 64 caracteres (64Bytes), pega substring de 64Bytes e
		// usa de entrada para HMAC(k, t, sha-512) com t igual a hora do sistema.
		//Grava Token (resultado da operação acima) na BA1
		While Len(cSeed) < nSeedTam
			cSeed := cSeed + BA1->(ba1_digito+ba1_tipreg+ba1_matric+ba1_codemp+ba1_codint+dtos(ba1_datnas)+AllTrim(ba1_nomusr))
		EndDo
		cSeed := SubStr(cSeed,1,nSeedTam)

		If nSeedTp == 3 //Hex
			nSeedTam := 2 * nSeedTam
		EndIf

		// Gera o Seed
		cSeed := HMAC(cT, cSeed, nSHAxTk, nRetTp, nCType, nKType)

		// Trata o seed dependendo de como ele será utilizado na geração do token
		If nSeedTp == 1 // Text
			cSeed := Encode64(cSeed)
			cSeed := SubStr(cSeed,1,nSeedTam)
		ElseIf nSeedTp == 2 // Base64
			cSeed := Encode64(cSeed)
			nSeedTam := Len(cSeed)
		ElseIf nSeedTp == 3 //Hex
			cSeed := SubStr(cSeed,1,nSeedTam)
		EndIf
	EndIf
Else
	lRet := .F.
EndIf

// Verifica se foi gerador corretamente
If Len(cSeed) <> nSeedTam
	lRet := .F.
EndIf

// PE para geração do Seed do Token
If Existblock("PTKSEEDG")
	cSeed := Execblock("PTKSEEDG", .F., .F., {cMatric})
	lRet := .T.
Endif

// Gravo Seed na BA1, e envio no retorno da função.
If lRet == .T. .And. lAtualiza
	BA1->(RecLock("BA1", .F.))
		BA1->BA1_TKSEED := cSeed
	BA1->(MsUnlock())
EndIf

RestArea(aAreaBA1)
Return {lRet, cSeed}


/*/{Protheus.doc} PLSHOTPGEN
	Função que, baseada da função HMAC, recebe um seed (chave) e um conteúdo específico e retorna
		um número, de 6 a 8 díditos, gerado baseado no resultado da encriptação desse conteúdo
		por meio de uma função hash.
		Esta função implementa o algoritmo HOTP, definido na rfc 4226 (https://tools.ietf.org/html/rfc4226)
		A execução desta função é um dos passos para geração do Token.
    @author Thiago Paris
    @since 30/09/2020
    @version 1.0
    @params cK, string, Seed (chave) de criptografia, obrigatório
        cC, string, conteúdo a ser criptografado , obrigatório
		nSHAx, integer, função hash a ser utilizada (3=SHA-1; 5=SHA-256; 7=SHA-512), obrigatório
		nContentType, integer, tipo do conteúdo sendo criptografado (1=Text; 2=Base64; 3=Hex), obrigatório
		nKeyType, integer, tipo da chave utilizada (1=Text; 2=Base64; 3=Hex), obrigatório
		nDigits, integer, número de dígitos do resultado gerado (6 a 8), obrigatório
    @return nRet, integer, numero gerado
    /*/
Function PLSHOTPGEN(cK, cC, nSHAx, nContentType, nKeyType, nDigits)
Local nRetType := 2 //Hex
Local cOutHex := ""
Local nOffset := 0
Local cDBC1 := ""
Local cMSB  := "0"
Local nMSB  := 0
Local cDBC2 := ""
Local nRet := 0

cOutHex := HMAC(cC, cK, nSHAx, nRetType, nContentType, nKeyType)
nOffset := __hextodec(SubStr(cOutHex, Len(cOutHex),1)) + 1
cDBC1 := SubStr(cOutHex, 2*nOffset-1, 2*4)
cMSB := SubStr(cDBC1, 1, 1)
nMSB := __hextodec(cMSB)
nMSB := Mod(nMSB, 8)
cMSB := Str(nMSB, 1, 0)
cDBC2 := cMSB + SubStr(cDBC1, 2, 7)
nRet := Mod(__hextodec(cDBC2), 10^nDigits)

Return nRet

/*/{Protheus.doc} PLSTOTPGEN
	Utiliza a função PLSHOTPGEN para gerar, para um seed específico, um Token numérico único para um determinado intervalo de tempo.
		Esta função implementa o algoritmo TOTP, definido na rfc 6238 (https://tools.ietf.org/html/rfc6238)
    @author Thiago Paris
    @since 30/09/2020
    @version 1.0
    @params cK, string, Seed (chave) de criptografia, obrigatório
    	nX, integer, tamanho do intervalo de tempo (timeStep) , obrigatório
		hashType, integer, função hash a ser utilizada (3=SHA-1; 5=SHA-256; 7=SHA-512), obrigatório
		nKType, integer, tipo da chave utilizada (1=Text; 2=Base64; 3=Hex), obrigatório
		nXType, integer, tipo do valor que representará o timestemp (1=Text; 2=Base64; 3=Hex), obrigatório
		nDigits, integer, número de dígitos do resultado gerado (6 a 8), obrigatório
		cTTest, string, string que pode representar um timestemp específico para testes, opcional
    @return cRet, string, Token numérico gerado de acordo com parâmetros
    /*/
Function PLSTOTPGEN(cK, nX, hashType, nKType, nXType, nDigits, cTTest)
Local   nT        := 0
Local   cT        := ""
Local   nRet      := 0
Local   cRet      := ""

// nT = Divisão inteira do epoch atual pelo step a ser considerado (30min)
// para a geração do Token
If cTTest <> Nil
	cT := cTTest
Else
	nT := int(val(FWTimeStamp(4))/nX)
	cT := __DECTOHEX(nT)
	While Len(cT) < 16
		cT := "0" + cT
	EndDo
EndIf

nRet := PLSHOTPGEN(cK, cT, hashType, nXType, nKType, nDigits)
cRet := StrTran(Str(nRet, nDigits, 0), " ", "0")
Return cRet

/*/{Protheus.doc} PLSTOKGENE
	Gera um Token específico, baseado no algoritmo TOTP, para um beneficiário específico de acordo com a hora atual do servidor.
    @author Thiago Paris
    @since 30/09/2020
    @version 1.0
    @params cMatric, string, Matrícula do Beneficiário, obrigatório
    @return aRet, array, array contendo status da requisição e seed gerado
        aRet[1] = Status de retorno (.T. = Sucesso, .F. = Falhou)
		aRet[2] = Token gerado
    /*/
Function PLSTOKGENE(cMatric)
Local lRet    := .T.
Local cSeed   := ""
Local cTokOk  := ""
Local nX      := GetNewPar("MV_PLSTOKT", 30*60)  //Token Time Step
Local nSHAxTk := GetNewPar("MV_PLSTKSH", 5)      //Token SHA Function 3=SHA-1; 5=SHA-256; 7=SHA-512
Local nDigits := GetNewPar("MV_PLSTKDG", 6)      //Token Number of Digits
Local nKType  := GetNewPar("MV_PLSTKST", 1)      //Token Seed Type 1=Text; 2=Base64; 3=Hex
Local nCType  := 3 //1=Text;2=Base64;3=Hex
Local nSeedTam := 32
Local aSeed := {}

Local aAreaBA1 := {}

aAreaBA1 := BA1->(GetArea())

BA1->(DbSetOrder(2))
If BA1->(MsSeek(xFilial("BA1")+cMatric))
	cSeed := AllTrim(BA1->BA1_TKSEED)
EndIf

If Empty(cSeed)
	aSeed := PLSTKSEEDG(cMatric)
	If aSeed[1]
		cSeed := aSeed[2]
	Else
		cSeed := ""
		nKType := 1 //Texto
		If nSHAxTk == 3
			nSeedTam := 20
		Elseif nSHAxTk == 5
			nSeedTam := 32
		Else
			nSeedTam := 64
		EndIf
		While Len(cSeed) < nSeedTam
			cSeed := cSeed + BA1->(ba1_digito+ba1_tipreg+ba1_matric+ba1_codemp+ba1_codint+dtos(ba1_datnas)+AllTrim(ba1_nomusr))
		EndDo
		cSeed := SubStr(cSeed,1,nSeedTam)
	EndIf
EndIf

cToken := PLSTOTPGEN(cSeed, nX, nSHAxTk, nKType, nCType, nDigits, nil)

// PE para cálculo do Token
If Existblock("PTKTOKGE")
	cToken := Execblock("PTKTOKGE", .F., .F., {cMatric})
	lRet := .T.
Endif

RestArea(aAreaBA1)

Return {lRet, cToken}

/*/{Protheus.doc} PLSTOKGENE
	Valida se um Token está correto para um Beneficiário específico em um intervalo de tempo específico.
		Esta função deve ser utilizada nos processos de validação do Token.
    @author Thiago Paris
    @since 30/09/2020
    @version 1.0
    @params cMatric, string, Matrícula do Beneficiário, obrigatório
		cToken, string, Token sendo validado, obrigatório
    @return aRet, array, array contendo status da requisição e seed gerado
        aRet[1] = Status de retorno (.T. = Token válido, .F. = Token inválido)
		aRet[2] = Token correto
    /*/
Function PLSUTOKVLD(cMatric, cToken)
Local lRet    := .F.
Local aRetTok := {}
Local cTokOk  := ""
If Empty(AllTrim(cToken))
	lRet := .T.
Else
	aRetTok := PLSTOKGENE(cMatric)
	cTokOk := aRetTok[2]
	If AllTrim(cTokOk) == AllTrim(cToken)
		lRet := .T.
	EndIf
EndIf
Return {lRet, cTokOk}
