#Include 'PROTHEUS.CH'
#Include 'TOTVS.CH'
#Include 'GCTSIGN.CH'

/*/{Protheus.doc} GCTSign
	Classe responsável por realizar integração de documentos via TOTVS Sign.
@author juan.felipe
@since 19/04/2021
/*/
Class GCTSign
    Data aHeaderOut  As Array
    Data cDocument   As Character
    Data cLastError  As Character
    Data cSignSts    As Character
    Data cApiURL     As Character
    Data lAPIError   As Logical
    Data nSignId     As Numeric
    Data nDocSuccess As Numeric
    Data nPubSuccess As Numeric
    Data nOperation  As Numeric

    Method New() Constructor
    Method Authenticate()
    Method AuthTotvsSign()
    Method SendDocument()
    Method SaveSignId()
    Method SaveSignSt()
    Method CleanSign()
    Method PublishDoc()
    Method RepublishDoc()
    Method UpdateDoc()
    Method DeleteDoc()
    Method Process()
    Method AddDocSuccess()
    Method AddPubSuccess()
    Method LogMessage()
    Method CleanUp()
    
    Method SetOperation()
    Method SetDocument()
    Method SetSignId()
    Method SetSignSts()

    Method GetURL()
    Method GetHeader()
    Method GetDocPath()
    Method GetDocument()
    Method GetSignId()
    Method GetSignSts()
    Method GetListDest()
    Method GetStatusDoc()
    Method GetMessage()
EndClass

/*/{Protheus.doc} New
	Método construtor
@author juan.felipe
@since 19/04/2021
/*/
Method New() Class GCTSign
    Self:aHeaderOut   := {}
    Self:cDocument    := ''
    Self:cLastError   := ''
    Self:cSignSts     := ''
    Self:cApiURL      := SuperGetMV('MV_CNTSURL', .F., '')
    Self:lAPIError    := .F.
    Self:nSignId      := 0
    Self:nDocSuccess  := 0
    Self:nPubSuccess  := 0
    Self:nOperation   := 0
Return Nil

/*/{Protheus.doc} Authenticate
	Realiza autenticação solicitando usuário e senha em uma dialog.
@author juan.felipe
@since 20/04/2021
@param cUser, character, usuário.
@param cPassword, character, senha.
@return lRet, logical, retorna .T. caso realize a autenticação corretamente.
/*/
Method Authenticate(cUser, cPassword) Class GCTSign
    Local lRet     As Logical
    Local oDlg     As Object
    Local oBut1    As Object
    Local oBut2    As Object
    Local oBitMap  As Object

    Default cUser := ''
    Default cPassword := ''

    If lRet := GetRpoRelease() >= '12.1.027'
        If !IsBlind() .And. !Self:AuthTotvsSign() //-- Exibe dialog apenas se não for possível realizar autenticação
            cUser := Space(50)
            cPassword := Space(50)
            DEFINE MSDIALOG oDlg FROM 50,100 TO 260,430 TITLE OemToAnsi(STR0001) PIXEL //Autenticação TOTVS Sign
            @ 20,02 TO 80,163 LABEL "" OF oDlg PIXEL
            @ 06,20 SAY OemToAnsi(STR0002) SIZE 122,09 Of oDlg PIXEL //Digite o usuário e senha.
            @ 35,08 SAY OemToAnsi(STR0003) SIZE 22,09 Of oDlg PIXEL //Usuário:
            @ 55,08 SAY OemToAnsi(STR0004) SIZE 18,09 Of oDlg PIXEL //"Senha:
            @ 35,43 MSGET cUser SIZE 110,10 Of oDlg PIXEL
            @ 55,43 MSGET cPassword SIZE 110,10 Of oDlg PIXEL PASSWORD
            @ 88,70 BUTTON oBut1 PROMPT (STR0005) SIZE 44,12 Of oDlg PIXEl Action Iif((FWMsgRun(, {|| Self:AuthTotvsSign(cUser, cPassword, @lRet) }, STR0007, STR0008), lRet), (lRet := .T., oDlg:End()), Self:GetMessage(.F.)) //Ok
            @ 88,120 BUTTON oBut2 PROMPT (STR0006) SIZE 44,12 Of oDlg PIXEl Action (lRet := .F., oDlg:End()) //Cancelar
            @ 05,08 BITMAP oBitmap RESOURCE "CADEADO" SIZE 20,18 Of oDlg PIXEL NOBORDER
            ACTIVATE MSDIALOG oDlg

            If lRet
                Self:cLastError := ''
            Else
                Self:cLastError := STR0009 //Não foi realizada autenticação com o TOTVS Sign.
            EndIf
        Else
            lRet := Self:AuthTotvsSign(cUser, cPassword)
        EndIf
    Else
        Self:cLastError := STR0024 //Esta funcionalidade não está disponível para releases inferiores ao 12.1.27.
    EndIf
Return lRet

/*/{Protheus.doc} AuthTotvsSign
	Realiza autenticação e guarda o token na propriedade aHeaderOut.
@author juan.felipe
@since 20/04/2021
@param cUser, character, usuário.
@param cPassword, character, senha.
@param lAuth, character, retorna por referência se foi realizada autenticação.
@return lAuth, logical, retorna .T. caso realize a autenticação corretamente.
/*/
Method AuthTotvsSign(cUser, cPassword, lAuth) Class GCTSign
    Local aHeader   As Array
    Local cBody     As Character
    Local cURL      As Character
    Local cResource As Character
    Local cTextJson As Character
    Local cToken    As Character
    Local cUser    As Character
    Local cPassword As Character
    Local oJsonResp As Object
    Local oRest     As Object
    Local oVault   As Object

    Default cUser := ''
    Default cPassword := ''
    Default lAuth := .F.

    aHeader   := {}
    cURL      := Self:GetURL()
    cResource := '/identity/api/auth/login'

    aAdd(aHeader, 'Content-Type: application/json')
    aAdd(aHeader, 'Accept-Charset: UTF-8')

    oJsonBody := JsonObject():New()
    oJsonBody['userName'] := ''
    oJsonBody['password'] := ''
    oJsonBody['userType'] := 1

    oVault := FwSafeVault():New()

    cUser := AllTrim(cUser)
    cPassword := AllTrim(cPassword)

    If !Empty(cUser) .And. !Empty(cPassword) //Salva no cofre apenas se houver usuário e senha preenchidos
        oVault:Put('user', cUser)
        oVault:Put('password', cPassword)
    EndIf

    cUser := oVault:Get('user') //Obtém informações guardadas no cofre
    cPassword := oVault:Get('password')

    oJsonBody['userName'] := cUser
    oJsonBody['password'] := cPassword

    cBody := FwJsonSerialize(oJsonBody)

    //Realiza o post de acordo com o cURL e cResource
    oRest := FwRest():New(cURL)
    oRest:SetPath(cResource)
    oRest:SetPostParams(cBody)
    oJsonResp := JsonObject():New()

    If lAuth := oRest:Post(aHeader)
        cTextJson := oRest:GetResult()
        oJsonResp:FromJson(cTextJson)

        cToken := oJsonResp['data']['token']

        //Monta header com token
        aAdd(Self:aHeaderOut, 'Authorization: Bearer ' + cToken)
        aAdd(Self:aHeaderOut, 'Accept-Charset: UTF-8')
        aAdd(Self:aHeaderOut, 'Content-Type: multipart/form-data')
        aAdd(Self:aHeaderOut, 'Content-Type: application/json')

        Self:LogMessage(cTextJson)
    Else
        cTextJson := oRest:GetResult()
        If oJsonResp:FromJson(cTextJson) == Nil
            Self:cLastError := DecodeUTF8(oJsonResp['description'])
        Else
            Self:cLastError := oRest:GetLastError()
            Self:lAPIError := .T.
        EndIf

        Self:LogMessage(cTextJson, oRest:GetLastError())
    EndIf

    //-- Limpa objetos da memória
    FreeObj(oJsonBody)
    FreeObj(oJsonResp)
    FreeObj(oRest)
    FreeObj(oVault)
Return lAuth

/*/{Protheus.doc} SendDocument
	Realiza o envio do documento.
@author juan.felipe
@since 19/04/2021
@return lRet, logical, retorna .T. caso o envio seja realizado corretamente.
/*/
Method SendDocument() Class GCTSign
    Local cBody     As Character
    Local cResource As Character
    Local cPathFile As Character
    Local cTextJson As Character
    Local cURL      As Character
    Local lRet      As Logical
    Local oJsonResp As Object
    Local oRest     As Object

    cPathFile := Self:GetDocPath() //-- Diretório do arquivo

    If lRet := !Empty(cPathFile) 
        cURL := Self:GetURL()
        cResource := '/storage/api/storage?idDocument=0'

        cBody := 'Content-Disposition: form-data; name="file"; filename="' + cPathFile + '"' + CRLF //-- Envio de Arquivo especificando o Content-Type
        cBody += 'Content-Type: application/pdf'

        //Realiza o post de acordo com o cURL e cResource
        oRest := FwRest():New(cURL)
        oRest:SetPath(cResource)
        oRest:SetPostParams(cBody)
        oJsonResp := JsonObject():New()
        
        If lRet := oRest:Post(Self:GetHeader(.T.))
            cTextJson := oRest:GetResult()

            oJsonResp:FromJson(cTextJson)

            Self:SetSignId(oJsonResp['data'])
            Self:AddDocSuccess()
            
            Self:LogMessage(cTextJson)
        Else
            cTextJson := oRest:GetResult()
            
            If oJsonResp:FromJson(cTextJson) == Nil
                Self:cLastError := DecodeUTF8(oJsonResp['description'])
            Else
                Self:cLastError := oRest:GetLastError()
                Self:lAPIError := .T.
            EndIf

            Self:LogMessage(cTextJson, oRest:GetLastError())
        EndIf

        FreeObj(oJsonResp)
        FreeObj(oRest)
    EndIf
Return lRet

/*/{Protheus.doc} SaveSignId
	Salva id da assinatura gerada pelo envio do documento no campo CNK_SIGNID.
@author juan.felipe
@since 22/04/2021
@return Nil, Nulo
/*/
Method SaveSignId() Class GCTSign
    Local aAreas As Array

    If CNK->(FieldPos('CNK_SIGNID')) > 0
        aAreas := {CNK->(GetArea()), GetArea()}

        CNK->(dbSetOrder(1)) //-- CNK_FILIAL+CNK_CODIGO
        
        If CNK->(MsSeek(xFilial('CNK') + Self:GetDocument()))
            RecLock('CNK',.F.)
            CNK->CNK_SIGNID := PadR(cValToChar(Self:GetSignId()), Len(CNK->CNK_SIGNID))
            MsUnlock()
        EndIf
    EndIf

    aEval(aAreas, {|x| RestArea(x), FwFreeArray(x) })
Return Nil

/*/{Protheus.doc} SaveSignSt
	Salva situação do documento no campo CNK_SIGNST.
@author juan.felipe
@since 22/04/2021
@return Nil, Nulo
/*/
Method SaveSignSt() Class GCTSign
    Local aAreas As Array

    If CNK->(FieldPos('CNK_SIGNST')) > 0
        aAreas := {CNK->(GetArea()), GetArea()}

        CNK->(dbSetOrder(1)) //-- CNK_FILIAL+CNK_CODIGO
        
        If CNK->(MsSeek(xFilial('CNK') + Self:GetDocument()))
            RecLock('CNK',.F.)
            CNK->CNK_SIGNST := Self:GetSignSts()
            MsUnlock()
        EndIf
    EndIf

    aEval(aAreas, {|x| RestArea(x), FwFreeArray(x) })
Return Nil

/*/{Protheus.doc} CleanSign
	Limpa id da assinatura e situação dos campos CNK_SIGNID e CNK_SIGNST.
@author juan.felipe
@since 22/04/2021
@return Nil, Nulo
/*/
Method CleanSign() Class GCTSign
    Local aAreas As Array

    If CNK->(FieldPos('CNK_SIGNID')) > 0
        aAreas := {CNK->(GetArea()), GetArea()}

        CNK->(dbSetOrder(1)) //-- CNK_FILIAL+CNK_CODIGO
        
        If CNK->(MsSeek(xFilial('CNK') + Self:GetDocument()))
            RecLock('CNK',.F.)
            CNK->CNK_SIGNID := CriaVar('CNK_SIGNID', .T.)
            CNK->CNK_SIGNST := CriaVar('CNK_SIGNST', .T.)
            MsUnlock()
        EndIf
    EndIf

    aEval(aAreas, {|x| RestArea(x), FwFreeArray(x) })
Return Nil

/*/{Protheus.doc} PublishDoc
	Realiza publicação do documento.
@author juan.felipe
@since 23/04/2021
@return lRet, Logical, retorna .T. caso a publicação seja realizada corretamente.
/*/
Method PublishDoc() Class GCTSign
    Local aListDest As Array
    Local cBody     As Character
    Local cResource As Character
    Local cTextJson As Character
    Local cURL      As Character
    Local lRet      As Logical
    Local oJsonBody As Object
    Local oRest     As Object

    cURL := Self:GetURL()
    cResource := '/signintegration/v2/Publicacoes'

    oJsonBody := JsonObject():New()
    oJsonBody['idDocumento'] := Self:GetSignId()

    aListDest := Self:GetListDest()

    If lRet := Len(aListDest) > 0
        oJsonBody['destinatarios'] := aListDest
        oJsonBody['utilizaWorkflow'] := .F.
        oJsonBody['responsavelAssinaDocumento'] := .F.
        oJsonBody['assinaturaResponsavel'] := JsonObject():New()
        oJsonBody['assinaturaResponsavel']['id'] := 0
        oJsonBody['assinaturaResponsavel']['tipoDeAssinatura'] := 0

        cBody := FwJsonSerialize( oJsonBody )

        //Realiza o post de acordo com o cURL e cResource
        oRest := FwRest():New(cURL)
        oRest:SetPath(cResource)
        oRest:SetPostParams(cBody)
        
        If lRet := oRest:Post(Self:GetHeader(.F.))
            cTextJson := oRest:GetResult()

            Self:SetSignSts('0')
            Self:AddPubSuccess()

            Self:LogMessage(cTextJson)
        Else
            cTextJson := oRest:GetResult()

            oJsonResp := JsonObject():New()

            If oJsonResp:FromJson(cTextJson) == Nil
                Self:cLastError := DecodeUTF8(oJsonResp['message'])
            Else
                Self:cLastError := oRest:GetLastError()
                Self:lAPIError := .T.
            EndIf

            Self:LogMessage(cTextJson, oRest:GetLastError())
        EndIf

        FreeObj(oRest)
    EndIf

    FreeObj(oJsonBody)
    FwFreeArray(aListDest)
Return lRet

/*/{Protheus.doc} RepublishDoc
	Realiza republicação de documentos em rascunho.
@author juan.felipe
@since 23/04/2021
@return lRet, Logical, retorna .T. caso a republicação seja realizada corretamente.
/*/
Method RepublishDoc() Class GCTSign
    Local lIsDraft As Logical
    Local lRet     As Logical

    lIsDraft := Self:GetStatusDoc()[3] == 5 //-- Documento em rascunho
    lRet := .F.

    If lIsDraft
        lRet := Self:PublishDoc()
    EndIf
Return lRet

/*/{Protheus.doc} UpdateDoc
	Realiza atualização da situação da assinatura.
@author juan.felipe
@since 26/04/2021
@return lRet, Logical, retorna .T. caso a atualização seja realizada corretamente.
/*/
Method UpdateDoc() Class GCTSign
    Local aAreas As Array
    Local lRet As Logical

    lRet := .F.

    If CNK->(FieldPos('CNK_SIGNID')) > 0
        aAreas := {CNK->(GetArea()), GetArea()}

        CNK->(dbSetOrder(1)) //-- CNK_FILIAL+CNK_CODIGO
        
        If CNK->(MsSeek(xFilial('CNK') + Self:GetDocument()))
            Self:GetStatusDoc() //-- Pega situação do documento

            lRet := CNK->CNK_SIGNST != Self:GetSignSts() .And. !Self:lAPIError //-- Atualiza apenas se não tiver erro de API
            
            If lRet
                Self:AddDocSuccess()
            EndIf
        EndIf
    EndIf

    aEval(aAreas, {|x| RestArea(x), FwFreeArray(x) })

Return lRet

/*/{Protheus.doc} DeleteDoc
	Realiza deleção do documento.
@author juan.felipe
@since 26/04/2021
@return lRet, Logical, retorna .T. caso a deleção seja realizada corretamente.
/*/
Method DeleteDoc() Class GCTSign
    Local cResource As Character
    Local cTextJson As Character
    Local cURL      As Character
    Local oJsonBody As Object
    Local oJsonResp As Object
    Local oRest     As Object

    cURL := Self:GetURL()
    cResource := '/signintegration/v2/Publicacoes
    
    oJsonBody := JsonObject():New()
    oJsonBody['idDocumento'] := Self:GetSignId()
    cBody := FwJsonSerialize( oJsonBody )
    
    oJsonResp := JsonObject():New()

    oRest := FwRest():New(cURL)
    oRest:SetPath(cResource)

    If oRest:Delete(Self:GetHeader(.F.), cBody)
        cTextJson := oRest:GetResult()
        oJsonResp:FromJson(cTextJson)

        Self:AddDocSuccess()

        Self:LogMessage(cTextJson)
    Else
        cTextJson := oRest:GetResult()
        
        If oJsonResp:FromJson(cTextJson) == Nil
            Self:cLastError := DecodeUTF8(oJsonResp['message'])
        Else
            Self:cLastError := oRest:GetLastError()
            Self:lAPIError := .T.
        EndIf

        Self:LogMessage(cTextJson, oRest:GetLastError())
    EndIf

    FreeObj(oJsonResp)
    FreeObj(oRest)
Return Nil

/*/{Protheus.doc} Process
	Realiza deleção do documento.
@author juan.felipe
@since 26/04/2021
@param lModel, logical, informa se o processamento deve ser realizado com base no modelo da rotina de documentos (CNTA171).
@param oModel, object, modelo de dados.
@return lRet, logical, retorna .T. caso o processamento seja realizado corretamente.
/*/
Method Process(lModel, oModel) Class GCTSign
    Local lRet As Logical
    Local oModelCNK As Object
    Default lModel := .F.
    Default oModel := Nil

    lRet := .T.

    If lModel .And. oModel <> Nil //-- Processamento a partir do modelo de dados
        oModelCNK := oModel:GetModel('CNKMASTER')

        If Self:nOperation == 1 .And. Self:SendDocument() //-- Envia documento
            oModelCNK:LoadValue('CNK_SIGNID', cValToChar(Self:GetSignId()))

            If Self:PublishDoc() //-- Publica documento
                oModelCNK:LoadValue('CNK_SIGNST', '0') //-- Assinatura Pendente
            Else
                oModelCNK:LoadValue('CNK_SIGNST', '5') //-- Documento em rascunho
            EndIf

        ElseIf Self:nOperation == 2 .And. Self:RepublishDoc() //-- Republica documento
            oModelCNK:LoadValue('CNK_SIGNST', '0') //-- Assinatura Pendente

        ElseIf Self:nOperation == 3 .And. Self:UpdateDoc() //-- Se tiver atualização muda a situação
            If !Empty(oModelCNK:GetValue('CNK_SIGNID')) .And. Self:GetSignId() == 0
                oModelCNK:LoadValue('CNK_SIGNID', CriaVar('CNK_SIGNID', .T.))
            EndIf
            oModelCNK:LoadValue('CNK_SIGNST', Self:GetSignSts())

        ElseIf Self:nOperation == 4 //-- Deleta documento
            If !Empty(oModelCNK:GetValue('CNK_SIGNID'))
                Self:DeleteDoc()
            EndIf

        Else
            lRet := .F.
        EndIf
    Else
        If Self:nOperation == 1 .And. Self:GetSignId() == 0 .And. Self:SendDocument() //-- Envia documento
            Self:SaveSignId() //-- Salva CNK_SIGNID

            If Self:PublishDoc() //-- Publica documento
                Self:SaveSignSt() //-- Salva CNK_SIGNST
            EndIf

        ElseIf Self:nOperation == 2 .And. Self:GetSignId() > 0 .And. Self:RepublishDoc() //-- Republica documento
            Self:SaveSignSt() //-- Salva CNK_SIGNST

        ElseIf Self:nOperation == 3 .And. Self:GetSignId() > 0 .And. Self:UpdateDoc() //-- Se tiver atualização muda a situação
            If Self:GetSignId() > 0
                Self:SaveSignSt() //-- Salva CNK_SIGNST
            Else
                Self:CleanSign() //-- Limpa CNK_SIGNST
            EndIf

        Else
            lRet := .F.
        EndIf
    EndIf
Return lRet

/*/{Protheus.doc} AddDocSuccess
	Incrementa documentos integrados com sucesso.
@author juan.felipe
@since 26/04/2021
@return Nil, nulo.
/*/
Method AddDocSuccess() Class GCTSign
    Self:nDocSuccess++
Return Nil

/*/{Protheus.doc} AddPubSuccess
	Incrementa documentos publicados com sucesso.
@author juan.felipe
@since 26/04/2021
@return Nil, nulo.
/*/
Method AddPubSuccess() Class GCTSign
    Self:nPubSuccess++
Return Nil

/*/{Protheus.doc} LogMessage
	Registra mensagem de log.
@author juan.felipe
@since 05/05/2021
@param cJson, character, json em formato texto.
@param cMessage, character, mensagem.
@return Nil, nulo.
/*/
Method LogMessage(cJson, cMessage) Class GCTSign
    Default cJson := ''
    Default cMessage := ''

    FWLogMsg('WARN',, 'GCTSIGN', FunName(), '', '01', 'JSON: ' + cJson + ' MSG: ' + cMessage, 0, 0, {})
Return Nil

/*/{Protheus.doc} CleanUp
	Limpa arrays/objetos da classe.
@author juan.felipe
@since 20/04/2021
@return Nil, nulo.
/*/
Method CleanUp() Class GCTSign
    FwFreeArray(Self:aHeaderOut)
Return Nil

/*/{Protheus.doc} SetOperation
	Seta operação 1-Integrar documento; 2- Republicar documento; 3-Atualizar assinatura, 4- Deletar documento.
@author juan.felipe
@since 27/04/2021
@param nOper, numeric, operação a ser realizada.
@return Nil, nulo.
/*/
Method SetOperation(nOper) Class GCTSign
    Self:nOperation := nOper
Return Nil

/*/{Protheus.doc} SetDocument
	Atribui código do documento (CNK_CODIGO)
@author juan.felipe
@since 19/04/2021
@param cDocument, character, código do documento.
@return Nil, Nulo
/*/
Method SetDocument(cDocument) Class GCTSign
    Self:cDocument := cDocument
Return Nil

/*/{Protheus.doc} SetSignId
	Atribui id da assinatura (CNK_SIGNID)
@author juan.felipe
@since 19/04/2021
@param nSignId, numeric, id da assinatura.
@return Nil, Nulo
/*/
Method SetSignId(nSignId) Class GCTSign
    Self:nSignId := nSignId
Return Nil

/*/{Protheus.doc} SetSignSts
	Atribui código do documento (CNK_CODIGO)
@author juan.felipe
@since 19/04/2021
@param cSignSts, character, status da assinatura.
@return Nil, Nulo
/*/
Method SetSignSts(cSignSts) Class GCTSign
    Self:cSignSts := cSignSts
Return Nil

/*/{Protheus.doc} GetURL
	Obtém URL da API informada no parâmetro MV_CNTSURL.
@author juan.felipe
@since 05/05/2021
@return Self:cApiURL, character, URL da API.
/*/
Method GetURL() Class GCTSign
Return Self:cApiURL

/*/{Protheus.doc} GetHeader
	Obtém header para realização de requisições.
@author juan.felipe
@since 19/04/2021
@param lSendDoc, logical, informa se deve a requisição é de envio de arquivo.
@return Self:cDocument, character, código do documento.
/*/
Method GetHeader(lSendDoc) Class GCTSign
    Local aHeader As Array
    Default lSendDoc := .F.

    aHeader := {}
    If lSendDoc
        aAdd(aHeader, Self:aHeaderOut[1])
        aAdd(aHeader, Self:aHeaderOut[2])
        aAdd(aHeader, Self:aHeaderOut[3])
    Else
        aAdd(aHeader, Self:aHeaderOut[1])
        aAdd(aHeader, Self:aHeaderOut[2])
        aAdd(aHeader, Self:aHeaderOut[4])
    EndIf
Return aHeader

/*/{Protheus.doc} GetDocPath
	Obtém diretório do documento na base de conhecimento.
@author juan.felipe
@since 19/04/2021
@return cRet, character, diretório do documento.
/*/
Method GetDocPath() Class GCTSign
    Local aAreas     As Array
	Local cDirDocs	 As Character
    Local cFile 	 As Character
    Local cRet       As Character
	Local lMsMultDir As Logical

    aAreas := {AC9->(GetArea()), ACB->(GetArea()), GetArea()}
    cRet := ''

    AC9->(dbSetOrder(2)) //-- AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ

    If AC9->(MsSeek(xFilial('AC9') + 'CNK' + xFilial('CNK') + Self:GetDocument()))
        ACB->(dbSetOrder(1)) //-- ACB_FILIAL+ACB_CODOBJ

        If ACB->(MsSeek(xFilial('ACB') + AC9->AC9_CODOBJ))
            cFile := Alltrim(ACB->ACB_OBJETO)
            lMsMultDir := MsMultDir()

            If !lMsMultDir
                cDirDocs := MsDocPath()
            Else
                cDirDocs := MsRetPath(cFile)
            EndIf

            cDirDocs := MsDocRmvBar(cDirDocs)
            cRet := cDirDocs + '\' + cFile
        EndIf
    EndIf

    If !AC9->(Found()) .Or. !ACB->(Found())
        Self:cLastError := STR0010 //Não foi localizado banco de conhecimento para o documento
    EndIf

    aEval(aAreas, {|x| RestArea(x), FwFreeArray(x) })
Return cRet

/*/{Protheus.doc} GetDocument
	Obtém código do documento (CNK_CODIGO).
@author juan.felipe
@since 19/04/2021
@return Self:cDocument, character, código do documento.
/*/
Method GetDocument() Class GCTSign
Return Self:cDocument

/*/{Protheus.doc} GetSignId
	Obtém id da assinatura (CNK_SIGNID).
@author juan.felipe
@since 19/04/2021
@return Self:nSignId, numeric, id da assinatura.
/*/
Method GetSignId() Class GCTSign
Return Self:nSignId

/*/{Protheus.doc} GetSignSts
	Obtém status da assinatura (CNK_SIGNST).
@author juan.felipe
@since 19/04/2021
@return Self:cSignSts, character, status da assinatura.
/*/
Method GetSignSts() Class GCTSign
Return Self:cSignSts

/*/{Protheus.doc} GetListDest
	Obtém lista de destinatários.
@author juan.felipe
@since 21/04/2021
@return aListDest, array, lista de destinatários.
/*/
Method GetListDest() Class GCTSign
    Local aAreas     As Array
    Local aListDest  As Array
    Local cKey       As Character
    Local nX         As Numeric

    aListDest := {}

    If AliasInDic('CXR')
        aAreas := {CXR->(GetArea()), GetArea()}
        nX := 1

        CXR->(dbSetOrder(1)) //-- CXR_FILIAL+CXR_CODIGO+CXR_ITEM
        
        cKey := xFilial('CXR') + Self:GetDocument()
        If CXR->(MsSeek(cKey))
            While CXR->(!Eof()) .And. CXR->(CXR_FILIAL + CXR_CODIGO) == cKey
                aAdd(aListDest, JsonObject():New())

                aListDest[nX]['email']    := AllTrim(CXR->CXR_EMAIL)
                aListDest[nX]['acao']     := Val(CXR->CXR_TIPO)
                aListDest[nX]['workflow'] := 0

                nX ++
                CXR->(dbSkip())
            EndDo
        Else
            Self:cLastError := STR0011 //Não foram localizados destinatários para o documento
        EndIf
    EndIf

    aEval(aAreas, {|x| RestArea(x), FwFreeArray(x) })
Return aListDest

/*/{Protheus.doc} GetStatusDoc
	Obtém situação da assinatura do documento.
@author juan.felipe
@since 23/04/2021
@return {lEnd, cStatus, nStatus}, array
    [1] retorna .T. caso a assinatura esteja finalizada;
    [2] retorna situação em forma de texto;
    [3] retorna situação em numérico;
/*/
Method GetStatusDoc() Class GCTSign
    Local cResource As Character
    Local cTextJson As Character
    Local cStatus   As Character
    Local cURL      As Character
    Local lEnd      As Logical
    Local nStatus   As Numeric
    Local nSignId   As Numeric
    Local oJsonResp As Object
    Local oRest     As Object

    lEnd      := .F.
    cURL      := Self:GetURL()
    cResource := '/signintegration/v2/Publicacoes/' + cValToChar(Self:GetSignId())
    cStatus   := 'Não possui assinatura'
    nStatus   := -1
    
    oJsonResp := JsonObject():New()
    oRest := FwRest():New(cURL)
    oRest:SetPath(cResource)
    
    If oRest:Get(Self:GetHeader(.F.))
        cTextJson := oRest:GetResult()
        oJsonResp:FromJson(cTextJson)

        nStatus := oJsonResp['data']['status']
        nSignId := oJsonResp['data']['pendentes'][1]['idArquivos']

        Self:SetSignSts(cValToChar(nStatus))
        Self:SetSignId(nSignId)

        If nStatus == 0
            cStatus := 'Pendente'
        ElseIf nStatus == 2
            cStatus := 'Finalizada'
            lEnd := .T.
        ElseIf nStatus == 4
            cStatus := 'Rejeitada'
        ElseIf nStatus == 5
            cStatus := 'Em Rascunho'
        EndIf

        Self:LogMessage(cTextJson)
    Else
        cTextJson := oRest:GetResult()

        If oJsonResp:FromJson(cTextJson) == Nil
            Self:cLastError := DecodeUTF8(oJsonResp['message'])
            Self:SetSignSts('N')
            Self:SetSignId(0)
        Else
            Self:cLastError := oRest:GetLastError()
            Self:lAPIError := .T.
        EndIf

        Self:LogMessage(cTextJson, oRest:GetLastError())
    EndIf

    FreeObj(oJsonResp)
    FreeObj(oRest)
Return {lEnd, cStatus, nStatus}

/*/{Protheus.doc} GetMessage
	Obtém mensagens de sucesso ou erro ao fim da execução.
@author juan.felipe
@since 24/04/2021
@param lHelp, logical, se deve exibir Help em caso existir erro.
@return {lIsValid, cTitle, cMessage}, array
    [1] retorna .T. caso não houver erro; 
    [2] retorna título da mensagem;
    [3] retorna mensagem de sucesso/erro.
/*/
Method GetMessage(lHelp) Class GCTSign
    Local cMessage  As Character
    Local cTitle    As Character
    Local lIsValid  As Logical
    Local nDocs     As Numeric
    Local nPubs     As Numeric

    Default lHelp := .F.

    lIsValid := .T.
    nDocs := Self:nDocSuccess
    nPubs := Self:nPubSuccess

    If Self:nOperation <= 2 .And. (nDocs > 0 .Or. nPubs > 0 .Or. Empty(Self:cLastError))
        If nDocs > 0 .And. nPubs > 0 .And. nDocs == nPubs
            cTitle := 'GCTSIGNPUBOK'
            cMessage := STR0012+ cValToChar(nDocs) + STR0013 //Foram integrados e publicados X documentos.
        ElseIf nDocs == 0 .And. nPubs > 0
            cTitle := 'GCTSIGNREPUBOK'
            cMessage := STR0014 + cValToChar(nPubs) + STR0013 //Foram republicados X documentos.
        ElseIf nDocs != nPubs
            cTitle := 'GCTSIGNDRAFT'
            cMessage := STR0015 + cValToChar(nDocs) + STR0016 + cValToChar(nPubs) + STR0017 //Foram integrados X documentos e publicados X. Utilize a opção republicar para publicar os documentos em rascunho.
        Else
            cTitle := 'GCTSIGNNODOC'
            cMessage := STR0018 //Nenhum documento foi integrado.
        EndIf
    ElseIf Self:nOperation == 3 .And. (nDocs > 0 .Or. Empty(Self:cLastError))
        If nDocs > 0
            cTitle := 'GCTSIGNUPDOC'
            cMessage := STR0019 + cValToChar(nDocs) + STR0013 //Foram atualizados X documentos.
        Else
            cTitle := 'GCTSIGNNOUPDOC'
            cMessage := STR0020 //Nenhum documento foi atualizado.
        EndIf
    ElseIf Self:nOperation == 4 .And. (nDocs > 0 .Or. Empty(Self:cLastError))
        If nDocs > 0
            cTitle := 'GCTSIGNDEL'
            cMessage := STR0021 + cValToChar(nDocs) + STR0013 //'Foram excluídos X documentos.
        Else
            cTitle := 'GCTSIGNNODEL'
            cMessage := STR0022 //Nenhum documento foi excluído.
        EndIf
    Else
        cTitle := 'GCTSIGNERROR'
        cMessage := STR0023 + CRLF + CRLF + Self:cLastError //Não foi possível realizar integração com o TOTVS Sign devido o seguinte erro: xxx
        
        If !Empty(Self:GetDocument())
            cMessage += CRLF + CRLF + STR0025 + Self:GetDocument() //Código do Documento: XXX
        EndIf
        
        lIsValid := .F.
    EndIf

    If !IsBlind() .And. !lHelp
        If lIsValid
            MsgInfo(cMessage, 'TOTVS Sign')
        Else
            MsgStop(cMessage, 'TOTVS Sign')
        EndIf
    Else
        Help(" ",1,cTitle,,cMessage, 1, 0, NIL, NIL, NIL, NIL, NIL, {''})
    EndIf

Return {lIsValid, cTitle, cMessage}
