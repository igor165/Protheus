#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "CONSIG002.CH"


#DEFINE PAGESIZE_DEF	1000
#DEFINE TAB  			CHR(13) + CHR(10)
#DEFINE MYRHPATH        "/api/myhr/v1/"

Static cEndPoint  := ""
Static cOrder     := ""
Static cBody      := ""
Static nPage 	  := 0
Static nPageSize  := 0
Static aParams    := {}
Static lRet       := .T.


/*/{Protheus.doc} WSRESTFUL PayrollLoan
Serviço REST para consulta de dados no TOTVS Consignado, consumido pelo app MeuRH."
@author  Hugo de Oliveira
@since   23/11/2020
@version 1.0
/*/
WSRESTFUL PayrollLoan DESCRIPTION OemToAnsi(STR0001) // "Serviço para consulta de dados do TOTVS Consignado."
    WSDATA id 	                As STRING
    WSDATA contractId 	        As STRING
	WSDATA installmentId        As STRING
    WSDATA InstallmentQuantity  As INTEGER
    WSDATA InstallmentValue     As INTEGER
    WSDATA status               As INTEGER
    WSDATA type                 As INTEGER
    WSDATA page		            As INTEGER  Optional
	WSDATA pageSize	            As INTEGER  Optional
    WSDATA order	            As STRING   Optional
    WSDATA filter               AS STRING   Optional
    
    WSDATA loanRequestId        As STRING
    WSDATA fileType             As STRING   Optional
    WSDATA documentType         As INTEGER  Optional
    WSDATA documentSide         As INTEGER  Optional
    
    // #### ENTIDADE LOAN REQUEST ####
    WSMETHOD GET getByStatus;
        DESCRIPTION oEmToAnsi(STR0006); // "Método para consulta de status das solicitações de empréstimo."
        WSSYNTAX "rh/payrollLoan/v1/loanRequests/{status}";
        PATH "rh/payrollLoan/v1/loanRequests/{status}";
        PRODUCES APPLICATION_JSON

    WSMETHOD GET getStatusCount;
        DESCRIPTION oEmToAnsi(STR0002); // "Método para consulta da quantidade de solicitações de empréstimos por status."
        WSSYNTAX "rh/payrollLoan/v1/loanRequests/status/count";
        PATH "rh/payrollLoan/v1/loanRequests/status/count";
        PRODUCES APPLICATION_JSON

    WSMETHOD GET getLRDet;
        DESCRIPTION oEmToAnsi(STR0007); // "Método para obter o detalhamento da solicitação de empréstimo."
        WSSYNTAX "rh/payrollLoan/v1/loanRequests/{id}/detail";
        PATH "rh/payrollLoan/v1/loanRequests/{id}/detail";
        PRODUCES APPLICATION_JSON

    WSMETHOD GET getValidPol;
        DESCRIPTION oEmToAnsi(STR0016); // "Método para validar a política da solicitação de empréstimo."
        WSSYNTAX "rh/payrollLoan/v1/loanRequests/policy/validate";
        PATH "rh/payrollLoan/v1/loanRequests/policy/validate";
        PRODUCES APPLICATION_JSON

    WSMETHOD POST postLoanReq;
        DESCRIPTION oEmToAnsi(STR0018); // "Método para enviar a solicitação de empréstimo."
        WSSYNTAX "rh/payrollLoan/v1/loanRequests";
        PATH "rh/payrollLoan/v1/loanRequests";
        PRODUCES APPLICATION_JSON

    WSMETHOD PUT putLRDoc;
        DESCRIPTION oEmToAnsi(STR0025); // "Atualiza o documento da Solicitação de Empréstimo."
        WSSYNTAX "rh/payrollLoan/v1/loanRequests/{id}/documents";
        PATH "rh/payrollLoan/v1/loanRequests/{id}/documents";
        PRODUCES APPLICATION_JSON

    WSMETHOD GET getTerms;
        DESCRIPTION oEmToAnsi(STR0023); // "Método para consultar os termos da solicitação de empréstimo."
        WSSYNTAX "rh/payrollLoan/v1/loanRequests/{id}/terms";
        PATH "rh/payrollLoan/v1/loanRequests/{id}/terms";
        PRODUCES APPLICATION_JSON

    WSMETHOD GET getUrlTerms;
        DESCRIPTION oEmToAnsi(STR0028); // "Método para consultar a lista de termos com suas respectivas URLs assinadas."
        WSSYNTAX "rh/payrollLoan/v1/loanRequests/{id}/getTermsUrlDownload";
        PATH "rh/payrollLoan/v1/loanRequests/{id}/getTermsUrlDownload";
        PRODUCES APPLICATION_JSON
    
    WSMETHOD PUT putTerms;
        DESCRIPTION oEmToAnsi(STR0024); // "Realiza a assinatura do contrato da Solicitação de Empréstimo."
        WSSYNTAX "rh/payrollLoan/v1/loanRequests/{id}/terms/signature";
        PATH "rh/payrollLoan/v1/loanRequests/{id}/terms/signature";
        PRODUCES APPLICATION_JSON

    // #### ENTIDADE PAYROLL LOAN ####
    WSMETHOD GET getPayrollLoans;
		DESCRIPTION oEmToAnsi(STR0008); // "Método para listagem de empréstimos"
		WSSYNTAX "rh/payrollLoan/v1/payrollLoans";
		PATH "rh/payrollLoan/v1/payrollLoans";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET getTotalBorrowed;
		DESCRIPTION oEmToAnsi(STR0009); // "Método para consulta de valor total emprestado."
		WSSYNTAX "rh/payrollLoan/v1/payrollLoans/totalAmountBorrowed/user";
		PATH "rh/payrollLoan/v1/payrollLoans/totalAmountBorrowed/user";
		PRODUCES APPLICATION_JSON

    WSMETHOD GET getStm;
		DESCRIPTION oEmToAnsi("Método para obter o extrato do contrato.");
		WSSYNTAX "rh/payrollLoan/v1/payrollLoans/{contractId}/statement";
		PATH "rh/payrollLoan/v1/payrollLoans/{contractId}/statement";
		PRODUCES APPLICATION_JSON

    WSMETHOD GET getInstallments;
		DESCRIPTION oEmToAnsi(STR0010); // "Método para obter a listagem simples de parcelas do contrato."
		WSSYNTAX "rh/payrollLoan/v1/payrollLoans/{contractId}/installments";
		PATH "rh/payrollLoan/v1/payrollLoans/{contractId}/installments";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET getDetById;
		DESCRIPTION oEmToAnsi(STR0014); // "Método que retorna os detalhes da parcela de empréstimo."
		WSSYNTAX "rh/payrollLoan/v1/payrollLoans/{contractId}/installments/{installmentId}";
		PATH "rh/payrollLoan/v1/payrollLoans/{contractId}/installments/{installmentId}";
		PRODUCES APPLICATION_JSON

    // #### ENTIDADE REGISTRATION ####
     WSMETHOD GET getAuthData;
        DESCRIPTION oEmToAnsi(STR0011); // "Método para consulta da autorização de dados pessoais."
        WSSYNTAX "rh/payrollLoan/v1/registrations/authorizedUsePersonalData";
        PATH "rh/payrollLoan/v1/registrations/authorizedUsePersonalData";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET getRegStat;
        DESCRIPTION oEmToAnsi(STR0013); // "Método para consulta de status da matrícula."
        WSSYNTAX "rh/payrollLoan/v1/registrations/status";
        PATH "rh/payrollLoan/v1/registrations/status";
        PRODUCES APPLICATION_JSON

    WSMETHOD PUT putRvkData;
        DESCRIPTION oEmToAnsi(STR0012); // "Método revogar uso de dados pessoais."
        WSSYNTAX "rh/payrollLoan/v1/registrations/revokeUsePersonalData";
        PATH "rh/payrollLoan/v1/registrations/revokeUsePersonalData";
        PRODUCES APPLICATION_JSON

    WSMETHOD PUT putAuthData;
        DESCRIPTION oEmToAnsi(STR0013); // "Método para autorizar o uso de dados pessoais."
        WSSYNTAX "rh/payrollLoan/v1/registrations/authorizeUsePersonalData";
        PATH "rh/payrollLoan/v1/registrations/authorizeUsePersonalData";
        PRODUCES APPLICATION_JSON

    // #### ENTIDADE SIMULATION ####
     WSMETHOD POST postSimExec;
        DESCRIPTION oEmToAnsi(STR0017); // "Método para executar a simulação."
        WSSYNTAX "rh/payrollLoan/v1/simulation/execute";
        PATH "rh/payrollLoan/v1/simulation/execute";
        PRODUCES APPLICATION_JSON

    // #### ENTIDADE BANK ####
    WSMETHOD GET getBank;
        DESCRIPTION oEmToAnsi(STR0019); // "Método para consulta de bancos."
        WSSYNTAX "rh/payrollLoan/v1/banks";
        PATH "rh/payrollLoan/v1/banks";
        PRODUCES APPLICATION_JSON
    
    // #### ENTIDADE PERSON ####
     WSMETHOD Get GetPersDoc;
        DESCRIPTION oEmToAnsi(STR0020); // "Consulta a existência do tipo de documento da pessoa"
        WSSYNTAX "rh/payrollLoan/v1/person/{type}/documentType";
        PATH "rh/payrollLoan/v1/person/{type}/documentType";
        PRODUCES APPLICATION_JSON

        WSMETHOD Get GetAddress;
            DESCRIPTION oEmToAnsi(STR0026); // "Consulta o endereço da pessoa"
            WSSYNTAX "rh/payrollLoan/v1/person/address";
            PATH "rh/payrollLoan/v1/person/address";
            PRODUCES APPLICATION_JSON

        WSMETHOD PUT putAddress;
            DESCRIPTION oEmToAnsi(STR0027); // "Atualiza o endereço da pessoa"
            WSSYNTAX "rh/payrollLoan/v1/person/address";
            PATH "rh/payrollLoan/v1/person/address";
            PRODUCES APPLICATION_JSON

    // #### ENTIDADE BLOB STORAGE ####
     WSMETHOD Get GetIdentDoc;
        DESCRIPTION oEmToAnsi(STR0021); // "Solicita uma URL assinada pelo MeuRH"
        WSSYNTAX "rh/payrollLoan/v1/blobStorage/signedUrl/identificationDocument";
        PATH "rh/payrollLoan/v1/blobStorage/signedUrl/identificationDocument";
        PRODUCES APPLICATION_JSON

    WSMETHOD Get GetResProof;
        DESCRIPTION oEmToAnsi(STR0022); // "Solicita uma URL assinada pelo MeuRH para o tipo de arquivo"
        WSSYNTAX "rh/payrollLoan/v1/blobStorage/signedUrl/residenceProof";
        PATH "rh/payrollLoan/v1/blobStorage/signedUrl/residenceProof";
        PRODUCES APPLICATION_JSON
END WSRESTFUL

WSMETHOD GET getStatusCount WSREST PayrollLoan
	cEndPoint := "loan-requests/status/count"
    lRet      := fCallAPI(Self, cEndPoint)
Return lRet

WSMETHOD GET getLRDet WSREST PayrollLoan
	cEndPoint := "loan-requests/" + ALLTRIM(Self:id) + "/detail"
    lRet      := fCallAPI(Self, cEndPoint)
Return lRet

WSMETHOD GET getValidPol QUERYPARAM InstallmentQuantity, InstallmentValue WSREST PayrollLoan
    DEFAULT Self:InstallmentQuantity := 1
    DEFAULT Self:InstallmentValue    := 1
    
    aParams   := {}
    cEndPoint := "loan-requests/policy/validate"

    aadd(aParams, {"InstallmentQuantity", "InstallmentValue"})
    aadd(aParams, {self:InstallmentQuantity, self:InstallmentValue})

    lRet := fCallAPI(Self, cEndPoint, 1, aParams)
Return lRet

WSMETHOD POST postLoanReq WSREST PayrollLoan
	cEndPoint := "loan-requests"
    cBody     := Self:GetContent()
    lRet      := fCallAPI(Self, cEndPoint, 3, ,cBody)
Return lRet

WSMETHOD PUT putLRDoc WSREST PayrollLoan
	aParams   := {}
    cEndPoint := "loan-requests/" + ALLTRIM(Self:id) + "/documents"
    cBody     := Self:GetContent()
    lRet      := fCallAPI(Self, cEndPoint, 2, aParams, cBody)
Return lRet

WSMETHOD GET getTerms WSREST PayrollLoan
	cEndPoint := "loan-requests/" + ALLTRIM(Self:id) + "/terms"
    lRet      := fCallAPI(Self, cEndPoint)
Return lRet

WSMETHOD GET getUrlTerms WSREST PayrollLoan
	cEndPoint := "loan-requests/" + ALLTRIM(Self:id) + "/terms-url-download"
    lRet      := fCallAPI(Self, cEndPoint)
Return lRet

WSMETHOD PUT putTerms WSREST PayrollLoan
	aParams   := {}
    cEndPoint := "loan-requests/" + ALLTRIM(Self:id) + "/terms/signature"
    cBody     := fTermsBody(Self)
    lRet      := fCallAPI(Self, cEndPoint, 2, aParams, cBody)
Return lRet

WSMETHOD GET getByStatus QUERYPARAM page, pagesize, order WSRESTFUL PayrollLoan
    Local nStatus := 0

    DEFAULT Self:page 	  := 1
	DEFAULT Self:pageSize := PAGESIZE_DEF
    DEFAULT Self:order 	  := ""
    DEFAULT	Self:status	  := 0

    nStatus   := Self:status
    nPage 	  := Self:page
    nPageSize := Self:pageSize
    cOrder    := Self:order

    // Set nPageSize
    IF (nPageSize < 1) .OR. (nPageSize > PAGESIZE_DEF)
        nPageSize := PAGESIZE_DEF
    EndIf

    // Set nPage
    If nPage < 1
        nPage := 1
    EndIf

    aParams := {}
    aadd(aParams, {"page", "pageSize", "order"})
    aadd(aParams, {nPage, nPageSize, cOrder})

    cEndPoint := "loan-requests/" + ALLTRIM(STR(nStatus))
    lRet      := fCallAPI(Self, cEndPoint, 1, aParams)
Return lRet

// #### EMPRÉSTIMOS ####
WSMETHOD GET getPayrollLoans WSRESTFUL PayrollLoan
	cEndPoint := "payroll-loans"
    lRet      := fCallAPI(Self, cEndPoint)
Return lRet

WSMETHOD GET getTotalBorrowed WSRESTFUL PayrollLoan
	cEndPoint := "payroll-loans/total-amount-borrowed/user"
	lRet      := fCallAPI(Self, cEndPoint)
Return lRet

WSMETHOD GET getDetById WSRESTFUL PayrollLoan
    Local cContrId  := ALLTRIM(Self:contractId)
    Local cInstId   := ALLTRIM(Self:installmentId)
	
    cEndPoint := "payroll-loans/" + cContrId + "/installments/" + cInstId
	lRet      := fCallAPI(Self, cEndPoint)
Return lRet

WSMETHOD GET getInstallments QUERYPARAM page, pagesize, order WSRESTFUL PayrollLoan
    DEFAULT Self:page 		:= 1
	DEFAULT Self:pageSize 	:= PAGESIZE_DEF
    DEFAULT Self:order 		:= ""
    
    nPage 	  := Self:page
    nPageSize := Self:pageSize
    cOrder    := Self:order

    // Set nPageSize
    IF (nPageSize < 1) .OR. (nPageSize > PAGESIZE_DEF)
        nPageSize := PAGESIZE_DEF
    EndIf

    // Set nPage
    If nPage < 1
        nPage := 1
    EndIf

    aParams := {}
    aadd(aParams, {"page", "pageSize", "order"})
    aadd(aParams, {nPage, nPageSize, cOrder})
    
    cEndPoint := "payroll-loans/" + ALLTRIM(Self:contractId) + "/installments"
    lRet      := fCallAPI(Self, cEndPoint, 1, aParams)
Return lRet

WSMETHOD GET getStm WSRESTFUL PayrollLoan
	cEndPoint := "payroll-loans/" + ALLTRIM(Self:contractId) + "/statement"
	lRet      := fCallAPI(Self, cEndPoint)
Return lRet

// #### REGISTRATION ####
WSMETHOD GET getAuthData WSRESTFUL PayrollLoan
	cEndPoint  := "registrations/authorized-use-personal-data"
    lRet       := fCallAPI(Self, cEndPoint)
Return lRet

WSMETHOD GET getRegStat WSRESTFUL PayrollLoan
    Local cJson      := ""
    Local oConfig    := FWTFConfig() // Retorna as configurações da integração TechFin/Carol.
    Local oRet       := JsonObject():New()
    Local oResonse   := JsonObject():New()
    Local cToken     := ""
	Local cMatSRA	 := ""
    Local aHeader    := {}
    Local cBranch	 := ""
	Local aDataLogin := {}
    Local nStatCode  := 401

	If Empty(oConfig["platform-clientId"])
		oResonse["code"]        := 4
		oResonse["description"] := STR0015 // "Aviso: O módulo Totvs Consignado ainda não foi configurado pela sua empresa."
		cJson := EncodeUTF8(fCompress(oResonse))
		::SetResponse(cJson)
	Else
        Self:SetHeader('Access-Control-Allow-Credentials' , "true")
        cToken      := Self:GetHeader('Authorization')
        aDataLogin  := fAuthMyRH(cToken)
        
        If Empty(aDataLogin)
            SetRestFault(401, EncodeUTF8(STR0003)) // "Permissão negada ao serviço solicitado."
            lRet := .F.
        Else
            cMatSRA := aDataLogin[1]
            cBranch := aDataLogin[5]

            If !Empty(cMatSRA) .And. !Empty(cBranch)
 
                cEndPoint  := "registrations/status"
                aHeader    := fMakeHeader(cBranch, cMatSRA)
                oRet       := fGetURL(MYRHPATH + cEndPoint, aHeader)
                
                // Tratamento do Retorno
                If !Empty(oRet:ORESPONSEH:CSTATUSCODE)
                    nStatCode := VAL(oRet:ORESPONSEH:CSTATUSCODE)
                EndIf

                If nStatCode != 200 .AND. nStatCode != 201
                    lRet := .F.
                EndIf

                If !Empty(oRet)
                    If lRet
                        ::SetResponse(oRet:CRESULT)
                    Else
                        If !Empty(oRet:CRESULT)
                            cJson := oRet:CRESULT
                        ElseIf !Empty(oRet:CINTERNALERROR)
                            cJson := oRet:CINTERNALERROR
                        Else
                            cJson := oRet:GetLastError()
                        EndIf
                        SetRestFault(nStatCode, cJson, .T.)
                    EndIf
                EndIf
            EndIF
        EndIf
	EndIf
	
	FreeObj(oRet)
	FreeObj(oResonse)
Return lRet

WSMETHOD PUT putRvkData WSRESTFUL PayrollLoan
	cEndPoint := "registrations/revoke-use-personal-data"
    lRet      := fCallAPI(Self, cEndPoint, 2)
Return lRet

WSMETHOD PUT putAuthData WSRESTFUL PayrollLoan
	cEndPoint  := "registrations/authorize-use-personal-data"
    lRet       := fCallAPI(Self, cEndPoint, 2)
Return lRet

WSMETHOD POST postSimExec WSRESTFUL PayrollLoan
	cEndPoint  := "simulation/execute"
    cBody      := Self:GetContent()
    lRet       := fCallAPI(Self, cEndPoint, 3, ,cBody)
Return lRet

// #### BANK ####
WSMETHOD GET getBank QUERYPARAM filter WSRESTFUL PayrollLoan
    DEFAULT Self:filter	:= ""
    
    aParams := {}
    aadd(aParams, {"filter"})
    
    // Valor não pode ir vazio caso o filtro não seja informado.
    If !Empty(Self:filter)
        aadd(aParams, Self:filter)
    EndIf

    cEndPoint := "banks"
    lRet      := fCallAPI(Self, cEndPoint, 1, aParams)
Return lRet

// #### PERSON ####
WSMETHOD GET GetPersDoc WSRESTFUL PayrollLoan
    cEndPoint := "person/" + ALLTRIM(STR(Self:type)) + "/document-type"
    lRet      := fCallAPI(Self, cEndPoint, 1)
Return lRet

WSMETHOD GET GetAddress WSRESTFUL PayrollLoan
    cEndPoint := "person/address"
    lRet      := fCallAPI(Self, cEndPoint, 1)
Return lRet

WSMETHOD PUT putAddress WSRESTFUL PayrollLoan
	cEndPoint  := "person/address"    
    cBody     := Self:GetContent()
    lRet      := fCallAPI(Self, cEndPoint, 2,,cBody)
Return lRet

// #### BlobStorage ####
WSMETHOD GET GetIdentDoc QUERYPARAM loanRequestId, fileType, documentType, documentSide WSRESTFUL PayrollLoan
    DEFAULT Self:loanRequestId := ""
    DEFAULT Self:fileType      := ""
    DEFAULT Self:documentType  := 0
    DEFAULT Self:documentSide  := 0

    aParams := {}

    If !Empty(Self:loanRequestId)
        aadd(aParams, {"loanRequestId"})
        aadd(aParams, {Self:loanRequestId})
    EndIf

    If !Empty(Self:fileType)
        IIf(!Empty(aParams[1]), aadd(aParams[1], "fileType"), aadd(aParams, {"fileType"}))
        IIf(!Empty(aParams[2]), aadd(aParams[2], Self:fileType), aadd(aParams, {Self:fileType}))
    EndIf

    If Self:documentType > 0
        IIf(!Empty(aParams[1]), aadd(aParams[1], "documentType"), aadd(aParams, {"documentType"}))
        IIf(!Empty(aParams[2]), aadd(aParams[2], Self:documentType), aadd(aParams, {Self:documentType}))
    EndIf

     If Self:documentSide > 0
        IIf(!Empty(aParams[1]), aadd(aParams[1], "documentSide"), aadd(aParams, {"documentSide"}))
        IIf(!Empty(aParams[2]), aadd(aParams[2], Self:documentSide), aadd(aParams, {Self:documentSide}))
    EndIf

    cEndPoint := "blob-storage/signed-url/identification-document"
    lRet      := fCallAPI(Self, cEndPoint, 1, aParams)
Return lRet

WSMETHOD GET GetResProof QUERYPARAM loanRequestId, fileType WSRESTFUL PayrollLoan
    DEFAULT Self:loanRequestId := ""
    DEFAULT Self:fileType      := ""

    aParams := {}
    If !Empty(Self:loanRequestId)
        aadd(aParams, {"loanRequestId"})
        aadd(aParams, {Self:loanRequestId})
    EndIf

    If !Empty(Self:fileType)
        IIf(!Empty(aParams[1]), aadd(aParams[1], "fileType"), aadd(aParams, {"fileType"}))
        IIf(!Empty(aParams[2]), aadd(aParams[2], Self:fileType), aadd(aParams, {Self:fileType}))
    EndIf

    cEndPoint := "blob-storage/signed-url/residence-proof"
    lRet      := fCallAPI(Self, cEndPoint, 1, aParams)
Return lRet


/*/{Protheus.doc} function fTermsBody
Função que realiza a montagem do body da assinatura de contrato da solicitação de empréstimo.
@author  Hugo de Oliveira
@since   08/02/2021
@version 1.0
/*/
Static function fTermsBody(oSelf)
    Local oInput := JsonObject():New()
    Local oRet   := JsonObject():new()
    Local cRet   := ""
    Local cBody  := ""

    DEFAULT oSelf := JsonObject():New()

    If !Empty(oSelf)
        oRet["userAgent"] := ALLTRIM(SUBSTR(oSelf:GetHeader('User-Agent'), AT("M", oSelf:GetHeader('User-Agent')), LEN(oSelf:GetHeader('User-Agent'))))

        cBody := oSelf:GetContent()
        oInput:FromJson(cBody)
    EndIf

    oRet["termsSentToEmail"] := oInput["termsSentToEmail"]
    oRet["ip"]	             := getServerIP()
    cRet                     := fCompress(oRet)
    FreeObj(oRet)
    FreeObj(oInput)
Return cRet


/*/{Protheus.doc} function fCallAPI
Valida autenticação e consulta endpoint solicitado.
@author  Hugo de Oliveira
@since   23/11/2020
@version 12.1.25
nType = 1 - GET
nType = 2 - PUT
nType = 3 - POST
/*/
Static function fCallAPI(oSelf, cEndPoint, nType, aParams, cBody)
    Local cJson
    Local nStatusCode := 200
    Local cToken      := ""
	Local cMatSRA	  := ""
    Local cBranch	  := ""
    Local cCodeGroup  := ""
    Local aHeader     := {}
	Local aDataLogin  := {}
    Local lRet        := .T.
    Local oRet		  := JsonObject():New()

	DEFAULT cEndPoint   := ""
	DEFAULT nType 		:= 1
	DEFAULT aParams 	:= {}
    DEFAULT oSelf       := JsonObject():New()

	If !Empty(cEndPoint)
		oSelf:SetHeader('Access-Control-Allow-Credentials' , "true")
		cToken      := oSelf:GetHeader('Authorization')
		aDataLogin  := fAuthMyRH(cToken)
        
		If Empty(aDataLogin)
			SetRestFault(401, EncodeUTF8(STR0003)) // "Permissão negada ao serviço solicitado."
			lRet := .F.
		Else
			cMatSRA := aDataLogin[1]
			cBranch := aDataLogin[5]

			If !Empty(cMatSRA) .And. !Empty(cBranch)
                aHeader := fMakeHeader(cBranch, cMatSRA)
				oRet := fGetURL(MYRHPATH + cEndPoint, aHeader, aParams, nType, cBody)

                If lRet := !Empty(oRet)                
                    cCodeGroup := SUBSTR(oRet:ORESPONSEH:CSTATUSCODE, 0, 1)

                    If cCodeGroup == "2"
                        cJson := oRet:CRESULT
                        oSelf:SetResponse(cJson)
                    Else
                        // Adicionado temporariamente pois o genericService do Front-End não consegue esconder a estrutura da notificação quando ela está vazia. Não remover.
                        If cCodeGroup == "4" .AND. cEndPoint == "person/address"
                            Return .T.

                        ElseIf cCodeGroup == "4"
                            cJson := fSetResp(oRet)
                        Else
                            If !Empty(oRet:CRESULT)
                                cJson := oRet:CRESULT
                            ElseIf !Empty(oRet:CINTERNALERROR)
                                cJson := oRet:CINTERNALERROR
                            Else
                                cJson := oRet:GetLastError()
                            EndIf
                        EndIf
                        lRet := .F.
                        nStatusCode := VAL(oRet:ORESPONSEH:CSTATUSCODE)
                        SetRestFault(nStatusCode, cJson, .T.)
                    EndIf
                EndIf
			EndIF
		EndIf
	EndIf

    FreeObj(oRet)
Return lRet

/*/{Protheus.doc} function fMakeHeader
Cria o array aHeader para a chamada das API's
@author  Alberto Ortiz
@since   21/07/2021
@version 12.1.25
/*/
Static function fMakeHeader(cBranch, cMatSRA)
    Local aHeader   := {}
    Local cCPF      := ""
    Local cSM0      := {}
    Local cCNPJ     := ""
    Local cIP       := ""

    DEFAULT cBranch := ""
    DEFAULT cMatSRA := ""

    cCPF  := fConsFunc(cBranch, cMatSRA, "RA_CIC")
    cSM0  := FWArrFilAtu(cEmpAnt , cBranch)
    cCNPJ := cSM0[18]
    cIP   := getServerIP()

    aadd(aHeader, {"registration", "cpf", "cnpj", "ip"})
    aadd(aHeader, {cMatSRA, cCPF, cCNPJ, cIP})

Return aHeader
