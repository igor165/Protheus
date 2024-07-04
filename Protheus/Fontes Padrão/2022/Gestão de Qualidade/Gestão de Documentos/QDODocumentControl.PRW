#INCLUDE "TOTVS.CH"
#INCLUDE "MSOLE.CH"
#include "fileio.ch"
#include "QDODOCUMENTCONTROL.CH"

#DEFINE ENTER CHR(13) + CHR(10)
#DEFINE MB_ICONEXCLAMATION 48

/*/{Protheus.doc} QDODocumentControl
Regras de Negocio - Controle de Arquivos do QDO -> Leitura Interna no ERP
@author brunno.costa
@since  29/11/2021
/*/
CLASS QDODocumentControl FROM LongNameClass

    DATA cDirDocLocal                  as Character
    DATA cDirDocServer                 as Character
    DATA lClientLinux                  as Logical
    DATA lExibeBotaoImpressao          as Logical
    DATA lLogConsole                   as Logical
    DATA lPEAlteraRegraPadraoImpressao as Logical
    DATA lServerLinux                  as Logical
    DATA lValidaUsuario                as Logical
    
	METHOD new() CONSTRUCTOR

    //Métodos Públicos
    METHOD abreDocumentoDoServidorNoSmartClient(cArquivo, cDocumento, cRevisao)
    METHOD abreDocumentoDoServidorNoSmartClientSemImpressaoEValidacaoUsuario(cArquivo)
    METHOD abreDocumentoExternoDoServidor(cArquivo, cDocumento, cRevisao)
    METHOD removeSenhaDocumentosServidor()
    METHOD somenteRemoveSenhaDocumentosServidor()
    METHOD retornaSenhaPadrao()
    METHOD validaInconsistenciaImplantacao(lImplantado, lExibeHelp)

    //Métodos Internos
    METHOD abreDocumentoDoServidorNoWebApp(cArquivo, cDocumento, cRevisao)
    METHOD abreDocumentoExternoDoServidorSemImpressaoEValidacaoUsuario(cArquivo)
    METHOD abrePDFDoServidorNoSmartClient(cArquivo, cDocumento, cRevisao)
    METHOD abrePDFDoServidorNoWebApp(cArquivo, cDocumento, cRevisao)
    METHOD apagaArquivo(cArquivo, lServer, lExibeHelp)
    METHOD apagaArquivoLocal(cArquivo, lExibeHelp)
    METHOD apagaArquivoServidor(cArquivo, lExibeHelp)
    METHOD copiaArquivoDoServidor(cArquivoPDF)
    METHOD copiaArquivoDoServidorParaWEBAPP(cArquivoPDF, nErrorAux)
    METHOD copiaArquivoParaServidor(cArquivoLocal, cNovoNome)
    METHOD copiaParaDocNoServidor(cArquivo, cArquivoDOC)
    METHOD criaAliasArquivos(cAlias, nRegistros)
    METHOD criaBatExisteArquivoQDO(cArquivoBat)
    METHOD criaScriptLibreOfficeCMD(cArquivoBat)
    METHOD criaScriptMSOfficePowerShell(cArquivoPS)
    METHOD enviaImpressao(oWebEngine, cDocumento, cRevisao, cUsuario)
    METHOD erroCopiaArquivo(cArquivo, cErro, nOperacao)
    METHOD erroCriacaoAlias(cErro)
    METHOD erroExclusaoArquivo(cArquivo, cErro, lServer, lExibeHelp)
    METHOD erroMontagemTela(cErro)
    METHOD erroRemocaoDeSenha(cErro)
    METHOD erroVerificacaoExistenciaForaDoRootPath(cCaminho, cErro, lExibeHelp)
    METHOD existeArquivo(cArquivo, lServer)
    METHOD existeArquivoForaDoRootPath(cCaminho, lExibeHelp)
    METHOD existeLibreOffice(lExibeHelp)
    METHOD existeMSOffice(lExibeHelp)
    METHOD extraiArquivoDoCaminho(cCaminho)
    METHOD extraiExtensao(cArquivo)
    METHOD geraPDF(cArquivo, cArquivoPDF)
    METHOD geraPDFComLibreOffice(cArquivo, cArquivoPDF)
    METHOD geraPDFComLibreOfficeEmLinux(cArquivo, cArquivoPDF)
    METHOD geraPDFComMSOffice(cArquivo, cArquivoPDF)
    METHOD help(cTitulo, cErro, cSolucao, lSoLog)
    METHOD logMsg(cTitulo, cErro, cSolucao)
    METHOD montaTelaExibicaoPDFNoSmartClient(cArquivoLocal, cDocumento, cRevisao, cUsuario)
    METHOD montaTelaOtherObject(oPanel, cArquivoLocal, cUsuario, oWebEngine)
    METHOD registraRemocaoSenhaArquivosServidorNaSX6()
    METHOD removeSenhaWord(cArquivo, nError, oWord)
    METHOD retornaBuild()
    METHOD retornaDescricaodoStatusdoDocumento(cDocumento, cRevisao)
    METHOD retornaStatusdoDocumento(cDocumento, cRevisao)
    METHOD usuarioValidoParaImpressao(cDocumento, cRevisao, cUsuario)
    METHOD validaDicionario()
    METHOD validaExecucaoViaWebApp()
    METHOD validaExistenciaDosParametrosSX6()
    METHOD validaExtensaoNaoEhDocEDocX(cArquivo)
    METHOD validaExtensaoParaConversaoEmPDF(cArquivo)
    METHOD validaExtensaoPDF(cArquivo)
    METHOD validaImplantacao(lExibeHelp)
    METHOD validaInstalacaoConversores(lExibeHelp)
    METHOD validaParametroQDOUsaSenha()
    METHOD validaParametroSenhasRemovidas()
    METHOD validaUsoNoUsuario(cUsuario)

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author brunno.costa
@since  29/11/2021
@return Self, objeto, instancia da Classe QDODocumentControl
/*/
METHOD new() CLASS QDODocumentControl
    Local aQPath              := QDOPath()
    Self:cDirDocLocal         := Lower(AllTrim(aQPath[3])) //MV_QPATHWT
    Self:cDirDocServer        := Lower(AllTrim(aQPath[1])) //MV_QPATHW
    Self:lExibeBotaoImpressao := .T.
    Self:lLogConsole          := GetSrvProfString("QDODocumentControlLog", "0") == "1"
    Self:lValidaUsuario       := .T.
    Self:lServerLinux         := IsSrvUnix()
    Self:lClientLinux         := (GetRemoteType() == 2)
    If !ExistDir(Self:cDirDocServer)
        MakeDir(Self:cDirDocServer)
    EndIf
Return Self

/*/{Protheus.doc} abreDocumentoDoServidorNoSmartClient
Abre o Arquivo PDF no SmartClient em Tela
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD abreDocumentoDoServidorNoSmartClient(cArquivo, cDocumento, cRevisao) CLASS QDODocumentControl
    Local aArea       := GetArea()
    Local cArquivoDOC := ""
    Local cArquivoPDF := ""
    Local cUsuario    := RetCodUsr()
    Local lCriouDoc   := .F.
    Local lCriouLocal := .F.
    Local lCriouPDF   := .F.
    Local lExibeHelp  := .T.
    Local lSucesso    := .T.

    Default cDocumento := QDH->QDH_DOCTO
    Default cRevisao   := QDH->QDH_RV
    
    If Self:validaExecucaoViaWebApp()
        Return Self:abreDocumentoDoServidorNoWebApp(cArquivo, cDocumento, cRevisao)
    EndIf

    cArquivo := Lower(AllTrim(cArquivo))

    If Self:lValidaUsuario .AND. !Self:validaUsoNoUsuario(cUsuario)
        lSucesso := .F.
    EndIf

    If lSucesso .AND. !Self:validaImplantacao(.T.)
        lSucesso := .F.
    EndIf

    If Self:validaExtensaoNaoEhDocEDocX(cArquivo)
        If lSucesso .AND. !Self:copiaParaDocNoServidor(cArquivo, @cArquivoDOC)
            lSucesso  := .F.
        ElseIf lSucesso
            lCriouDoc := .T.
        EndIf
    Else
        cArquivoDOC := cArquivo
    EndIf

    If lSucesso .AND. !Self:geraPDF(cArquivoDOC, @cArquivoPDF)
        lSucesso := .F.
    ElseIf lSucesso
        lCriouPDF := .T.
    EndIf

    If lCriouDoc
        Self:apagaArquivoServidor(cArquivoDOC, lExibeHelp)
    EndIf

    If lSucesso .AND. !Self:copiaArquivoDoServidor(cArquivoPDF)
        lSucesso := .F.
    ElseIf lSucesso
        lCriouLocal := .T.   
    EndIf

    If lCriouPDF .AND. !Self:apagaArquivoServidor(cArquivoPDF, lExibeHelp)
        lSucesso := .F.
    EndIf

    If lSucesso .AND. !Self:montaTelaExibicaoPDFNoSmartClient(cArquivoPDF, cDocumento, cRevisao, RetCodUsr())
        lSucesso := .F.
    EndIf

    If lCriouLocal .AND. !Self:apagaArquivoLocal(cArquivoPDF, lExibeHelp)
        lSucesso := .F.
    EndIf

    RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} abrePDFDoServidorNoSmartClient
Abre o Arquivo PDF no SmartClient em Tela
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD abrePDFDoServidorNoSmartClient(cArquivoPDF, cDocumento, cRevisao) CLASS QDODocumentControl
    
    Local aArea       := GetArea()
    Local lCriouLocal := .F.
    Local lExibeHelp  := .T.
    Local lSucesso    := .T.

    Default cDocumento := QDH->QDH_DOCTO
    Default cRevisao   := QDH->QDH_RV
    
    If Self:validaExecucaoViaWebApp()
        Return Self:abrePDFDoServidorNoWebApp(cArquivoPDF)
    EndIf

    cArquivoPDF := Lower(AllTrim(cArquivoPDF))

    If Self:lValidaUsuario .AND. !Self:validaUsoNoUsuario(cUsuario)
        lSucesso := .F.
    EndIf

    If lSucesso .AND. !Self:copiaArquivoDoServidor(cArquivoPDF)
        lSucesso := .F.
    ElseIf lSucesso
        lCriouLocal := .T.   
    EndIf

    If lSucesso .AND. !Self:montaTelaExibicaoPDFNoSmartClient(cArquivoPDF, , , RetCodUsr())
        lSucesso := .F.
    EndIf

    If lCriouLocal .AND. !Self:apagaArquivoLocal(cArquivoPDF, lExibeHelp)
        lSucesso := .F.
    EndIf

    RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} abreDocumentoExternoDoServidor
Abre Documento Externo
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD abreDocumentoExternoDoServidor(cArquivo, cDocumento, cRevisao) CLASS QDODocumentControl
    
    Local lSucesso := .T.

    cArquivo := Lower(AllTrim(cArquivo))

    If !Self:validaUsoNoUsuario(cUsuario)
        lSucesso := .F.
    else
        Self:abreDocumentoExternoDoServidorSemImpressaoEValidacaoUsuario(cArquivo)
    EndIf


Return lSucesso

/*/{Protheus.doc} abreDocumentoExternoDoServidorSemImpressaoEValidacaoUsuario
Abre Documento Externo Sem Habilitar Impressão ou Validar o Tipo de Exibição do Usuário
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD abreDocumentoExternoDoServidorSemImpressaoEValidacaoUsuario(cArquivo) CLASS QDODocumentControl

    Local lExibiu  := .F.

    Default cArquivo:= ""

    If Self:validaExtensaoPDF(cArquivo)
        lExibiu := Self:abrePDFDoServidorNoSmartClient(cArquivo)
    ElseIf  Self:validaExtensaoParaConversaoEmPDF(cArquivo)
        lExibiu := Self:abreDocumentoDoServidorNoSmartClientSemImpressaoEValidacaoUsuario(cArquivo)
    EndIf

    If !lExibiu
        QA_OPENARQ(Self:cDirDocLocal+cArquivo)
    Endif

Return 

/*/{Protheus.doc} validaExtensaoNaoEhDocEDocX
Valida se o arquivo possui extensão não é DOC nem DOCX
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@return lSucesso, lógico, indica se a extensão é diferente de DOC e DOCX
/*/
METHOD validaExtensaoNaoEhDocEDocX(cArquivo) CLASS QDODocumentControl
Return UPPER(Self:extraiExtensao(cArquivo)) != "DOC" .AND. UPPER(Self:extraiExtensao(cArquivo)) != "DOCX"

/*/{Protheus.doc} validaExtensaoPDF
Valida se o arquivo possui extensão PDF
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@return lSucesso, lógico, indica se a extensão é PDF
/*/
METHOD validaExtensaoPDF(cArquivo) CLASS QDODocumentControl
Return UPPER(Self:extraiExtensao(cArquivo)) == "PDF"

/*/{Protheus.doc} validaExtensaoParaConversaoEmPDF
Valida se o arquivo possui extensão válida para conversão em PDF via MS Office/LibreOffice
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD validaExtensaoParaConversaoEmPDF(cArquivo) CLASS QDODocumentControl
Return UPPER(Self:extraiExtensao(cArquivo)) $ "|DOC|DOCX|DOT|DOTX|"

/*/{Protheus.doc} extraiExtensao
Extrai a Extensão do Arquivo
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD extraiExtensao(cCaminho) CLASS QDODocumentControl
    Local aTrechos  := Nil
    Local cArquivo  := Self:extraiArquivoDoCaminho(cCaminho)
    Local cExtensao := ""
    If At( ".", cArquivo ) > 0
        aTrechos   := StrTokArr( cArquivo, "." )
        cExtensao  := aTrechos[Len(aTrechos)]
    EndIf
Return cExtensao

/*/{Protheus.doc} abreDocumentoDoServidorNoSmartClientSemImpressaoEValidacaoUsuario
Abre o Arquivo PDF no SmartClient em Tela - Sem Impressão e Validação de Usuário
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD abreDocumentoDoServidorNoSmartClientSemImpressaoEValidacaoUsuario(cArquivo) CLASS QDODocumentControl
    Self:lValidaUsuario       := .F.
    Self:lExibeBotaoImpressao := .F.
Return Self:abreDocumentoDoServidorNoSmartClient(cArquivo)

/*/{Protheus.doc} abreDocumentoDoServidorNoWebApp
Abre o Arquivo PDF no SmartClient em Tela via WEBAPP
@author brunno.costa
@since  10/05/2022
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD abreDocumentoDoServidorNoWebApp(cArquivo, cDocumento, cRevisao) CLASS QDODocumentControl
    Local aArea       := GetArea()
    Local cArquivoDOC := ""
    Local cArquivoPDF := ""
    Local cUsuario    := RetCodUsr()
    Local lCriouDoc   := .F.
    Local lCriouPDF   := .F.
    Local lExibeHelp  := .T.
    Local lSucesso    := .T.

    Default cDocumento := QDH->QDH_DOCTO
    Default cRevisao   := QDH->QDH_RV

    cArquivo := Lower(AllTrim(cArquivo))

    If Self:lValidaUsuario .AND. !Self:validaUsoNoUsuario(cUsuario)
        lSucesso := .F.
    EndIf

    If lSucesso .AND. !Self:validaImplantacao(.T.)
        lSucesso := .F.
    EndIf

    If lSucesso .AND. !Self:copiaParaDocNoServidor(cArquivo, @cArquivoDOC)
        lSucesso  := .F.
    ElseIf lSucesso
        lCriouDoc := .T.
    EndIf

    If lSucesso .AND. !Self:geraPDF(cArquivoDOC, @cArquivoPDF)
        lSucesso := .F.
    ElseIf lSucesso
        lCriouPDF := .T.
    EndIf

    If lCriouDoc
        Self:apagaArquivoServidor(cArquivoDOC, lExibeHelp)
    EndIf

    If lSucesso .AND. !Self:copiaArquivoDoServidorParaWEBAPP(cArquivoPDF)
        lSucesso := .F.
    EndIf

    If lCriouPDF .AND. !Self:apagaArquivoServidor(cArquivoPDF, lExibeHelp)
        lSucesso := .F.
    EndIf

    If lSucesso .AND. !Self:montaTelaExibicaoPDFNoSmartClient(cArquivoPDF, cDocumento, cRevisao, RetCodUsr())
        lSucesso := .F.
    EndIf

    RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} abrePDFDoServidorNoWebApp
Abre o Arquivo PDF no WebApp em Tela
@author brunno.costa
@since  10/05/2022
@param 01 - cArquivoPDF, caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@param 02 - cDocumento , caracter, código do documento relacionado
@param 03 - cRevisao   , caracter, código da revisão do documento relacionada
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD abrePDFDoServidorNoWebApp(cArquivoPDF, cDocumento, cRevisao) CLASS QDODocumentControl
    Local aArea       := GetArea()
    Local cUsuario    := RetCodUsr()

    Local lSucesso    := .T.

    Default cDocumento := QDH->QDH_DOCTO
    Default cRevisao   := QDH->QDH_RV

    cArquivo := Lower(AllTrim(cArquivo))

    If Self:lValidaUsuario .AND. !Self:validaUsoNoUsuario(cUsuario)
        lSucesso := .F.
    EndIf

    If lSucesso .AND. !Self:validaImplantacao(.T.)
        lSucesso := .F.
    EndIf

    If lSucesso .AND. !Self:copiaArquivoDoServidorParaWEBAPP(cArquivoPDF)
        lSucesso := .F.  
    EndIf

    If lSucesso .AND. !Self:montaTelaExibicaoPDFNoSmartClient(cArquivoPDF, cDocumento, cRevisao, RetCodUsr())
        lSucesso := .F.
    EndIf

    RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} removeSenhaDocumentosServidor
Processa Implantação - Remove Senha de Todos os Arquivos do QDO
@author brunno.costa
@since  29/11/2021
@return lSucesso, lógico, indica se conseguiu realizar a remoção de senha dos arquivos do servidor
/*/
METHOD removeSenhaDocumentosServidor() CLASS QDODocumentControl
    Local aArea      := GetArea()
    Local cAlias     := ""
    Local cErro      := ""
    Local lSucesso   := .T.
    Local nAtual     := 0
    Local nError     := 0
    Local nRegistros := 0
    Local oWord      := Nil

    If !Self:validaExistenciaDosParametrosSX6()
        lSucesso := .F.
        //STR0001 - "Falha na preparação do ambiente para uso da visualização de Documentos 'Internos no ERP'."
        //STR0002 - "Execute o UPDDISTR para release mais recente ou crie os parâmetros no configurador conforme a documentação: MV_QDOMSOD, MV_QDOLOD e MV_QDOCPDF."
        Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0001, STR0002)
    EndIf

    If !Self:validaDicionario()
        lSucesso := .F.
        //STR0003 - "Falha na preparação do dicionário de dados do ambiente para uso da visualização de Documentos 'Internos no ERP'."
        //STR0004 - "Inclua a opção '4=Interna no ERP' no combobox do campo 'QAA_TPWORD' e renomeio o título do campo para 'Tipo Exib.'."
        Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0003, STR0004)
    EndIf

    If lSucesso .AND. Self:validaParametroQDOUsaSenha()
        If lSucesso .AND. !Self:criaAliasArquivos(@cAlias, @nRegistros)
            lSucesso := .F.
        EndIf
        PutGlbValue( "QDODocumentControl_nRegistros_"+cEmpAnt+cFilAnt, Str(nRegistros) )

        While lSucesso .AND. !(cAlias)->(Eof())
            
            nAtual++
            PutGlbValue( "QDODocumentControl_nAtual_"+cEmpAnt+cFilAnt, Str(nAtual) )
            PutGlbValue( "QDODocumentControl_cArquivo_"+cEmpAnt+cFilAnt, AllTrim(Lower((cAlias)->QDH_NOMDOC)) )

            nError   := 0
            If !Empty((cAlias)->QDH_NOMDOC)
                lSucesso := Self:removeSenhaWord(AllTrim(Lower((cAlias)->QDH_NOMDOC)), @nError, @oWord)
            EndIf
            
            If !lSucesso
                cAuxVar := ""
                cErro   := Iif(nError == 2, " [" + STR0046 + "]", "["+Str(nError)+"]") //"Não encontrado no Servidor"
                VarBeginT("QDODocumentControl", "aArquivosErros")
                VarSetXD("QDODocumentControl", AllTrim(Lower((cAlias)->QDH_NOMDOC)), cErro)
                VarEndT("QDODocumentControl", "aArquivosErros")

                //STR0005 - "Ocorreu falha na remoção de senha do arquivo"
                //STR0006 - "deseja continuar o processo de remoção para os demais arquivos?"
                //STR0007 - "Deseja continuar?"
                If ApMsgYesNo(STR0005 - " '" + AllTrim(Lower((cAlias)->QDH_NOMDOC)) + "'" + cErro + ", " + STR0006, STR0007)
                    lSucesso := .T.
                EndIf
            EndIf

            (cAlias)->(DbSkip())
        EndDo
        If oWord != Nil
            OLE_CloseLink( oWord, .T. )
        EndIf
        (cAlias)->(DbCloseArea())
    EndIf

    If lSucesso
        Self:registraRemocaoSenhaArquivosServidorNaSX6()
    EndIf

    RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} somenteRemoveSenhaDocumentosServidor
Processa Implantação - Remove Senha de Todos os Arquivos do QDO
@author brunno.costa
@since  29/11/2021
@return lSucesso, lógico, indica se conseguiu realizar a remoção de senha dos arquivos do servidor
/*/
METHOD somenteRemoveSenhaDocumentosServidor() CLASS QDODocumentControl
    Local aArea      := GetArea()
    Local cAlias     := ""
    Local cErro      := ""
    Local lCriou     := Nil
    Local lSucesso   := .T.
    Local nAtual     := 0
    Local nError     := 0
    Local nRegistros := 0
    Local oWord      := Nil

    If lSucesso .AND. !(lCriou := Self:criaAliasArquivos(@cAlias, @nRegistros))
        lSucesso := .F.
    EndIf
    PutGlbValue( "QDODocumentControl_nRegistros_"+cEmpAnt+cFilAnt, Str(nRegistros) )

    While lSucesso .AND. !(cAlias)->(Eof())
        
        nAtual++
        PutGlbValue( "QDODocumentControl_nAtual_"+cEmpAnt+cFilAnt, Str(nAtual) )
        PutGlbValue( "QDODocumentControl_cArquivo_"+cEmpAnt+cFilAnt, AllTrim(Lower((cAlias)->QDH_NOMDOC)) )

        nError   := 0
        If !Empty((cAlias)->QDH_NOMDOC)
            lSucesso := Self:removeSenhaWord(AllTrim(Lower((cAlias)->QDH_NOMDOC)), @nError, @oWord)
        EndIf
        
        If !lSucesso
            cAuxVar := ""
            cErro   := Iif(nError == 2, " [" + STR0046 + "]", "["+Str(nError)+"]") //"Não encontrado no Servidor"
            VarBeginT("QDODocumentControl", "aArquivosErros")
            VarSetXD("QDODocumentControl", AllTrim(Lower((cAlias)->QDH_NOMDOC)), cErro)
            VarEndT("QDODocumentControl", "aArquivosErros")

            //STR0005 - "Ocorreu falha na remoção de senha do arquivo"
            //STR0006 - "deseja continuar o processo de remoção para os demais arquivos?"
            //STR0007 - "Deseja continuar?"
            If ApMsgYesNo(STR0005 - " '" + AllTrim(Lower((cAlias)->QDH_NOMDOC)) + "'" + cErro + ", " + STR0006, STR0007)
                lSucesso := .T.
            EndIf
        EndIf

        (cAlias)->(DbSkip())
    EndDo
    If oWord != Nil
        OLE_CloseLink( oWord, .T. )
    EndIf
    If lCriou
        (cAlias)->(DbCloseArea())
    EndIf

    RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} retornaSenhaPadrao
Retorna Senha Padrão Para Abrir e Salvar Documentos
@author brunno.costa
@since  29/11/2021
@return cSenha, caracter, senha padrão para leitura, edição e gravação de arquivos do QDO
/*/
METHOD retornaSenhaPadrao() CLASS QDODocumentControl
    Local aArea    := GetArea()
    Local cSenha   := IIf( Self:validaParametroQDOUsaSenha() .AND. !Self:validaImplantacao(.F.), "CELEWIN400", "" )
    RestArea(aArea)
Return cSenha

/*/{Protheus.doc} validaParametroQDOUsaSenha
Indica se os documentos elaborados pelo Modulo Controle de Documentos foram configurados paragravação com senha (MV_QSAVPSW - Descontinuado após QDODocumentControl)
@author brunno.costa
@since  29/11/2021
@return lReturn, lógico, indica se os documentos elaborados pelo Modulo Controle de Documentos foram configurados paragravação com senha (MV_QSAVPSW)
/*/
METHOD validaParametroQDOUsaSenha() CLASS QDODocumentControl
    Local aArea    := GetArea()
    Local lReturn  := AllTrim(SuperGetMV("MV_QSAVPSW",.F.,"1")) == "1" //1=Sim
    RestArea(aArea)
Return lReturn

/*/{Protheus.doc} validaParametroSenhasRemovidas
Indica se Já foi Realizada a Remoção de Senha dos Arquivos do SIGAQDO
@author brunno.costa
@since  29/11/2021
@return lReturn, lógico, Indica se Já foi Realizada a Remoção de Senha dos Arquivos do SIGAQDO
/*/
METHOD validaParametroSenhasRemovidas() CLASS QDODocumentControl
    Local aArea    := GetArea()
    Local lReturn  := SuperGetMV("MV_QDOCPDF",.F.,.F.)
    RestArea(aArea)
Return lReturn

/*/{Protheus.doc} validaInconsistenciaImplantacao
Valida Inconsistência de Implantação e Exibe Help
@author brunno.costa
@since  29/11/2021
@param 01 - lImplantado, lógico, retorna por referência se a exibição de documentos em tela foi implantada
@param 02 - lExibeHelp , lógico, indica se realizará a exibição de helps de erros em tela para os usuários
@return lInconsistente, lógico, indica se a base está inconsistente
/*/
METHOD validaInconsistenciaImplantacao(lImplantado, lExibeHelp) CLASS QDODocumentControl
    Local aArea          := GetArea()
    Local lInconsistente := .F.
    
    Default lImplantado  := .F.
    Default lExibeHelp   := .T.

    If self:validaParametroSenhasRemovidas()
        lImplantado := .T.
        If !Self:validaInstalacaoConversores(lExibeHelp)
            lInconsistente := .T.
            lImplantado    := .F.
        EndIf

        If !Self:validaExistenciaDosParametrosSX6()
            lInconsistente := .T.
            lImplantado    := .F.
            If (lExibeHelp)
                //STR0001 - "Falha na preparação do ambiente para uso da visualização de Documentos 'Internos no ERP'."
                //STR0002 - "Execute o UPDDISTR para release mais recente ou crie os parâmetros no configurador conforme a documentação: MV_QDOMSOD, MV_QDOLOD e MV_QDOCPDF."
                Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0001, STR0002)
            EndIf
        EndIf

        If !("4="$GetSx3Cache("QAA_TPWORD","X3_CBOX"))
            lInconsistente := .T.
            lImplantado    := .F.
            If (lExibeHelp)
                //STR0001 - "Falha na preparação do ambiente para uso da visualização de Documentos 'Internos no ERP'."
                //STR0004 - "Inclua a opção '4=Interna no ERP' no combobox do campo 'QAA_TPWORD' e renomeio o título do campo para 'Tipo Exib.'."
                Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0001, STR0004)
            EndIf
        EndIf
    EndIf
    RestArea(aArea)
Return lInconsistente

/*/{Protheus.doc} validaImplantacao
Valida Execução da Implantação para Exibição de Documentos "Interna no ERP" - Wizard: 'QDOWizPDF'
@author brunno.costa
@since  29/11/2021
@param 01 - lExibeHelp, lógico, indica se deve realizar a exibição dos Helps de Falhas
@return lImplantado, lógico, indica se a exibição de documentos 'Interna no ERP' foi implantada com sucesso
/*/
METHOD validaImplantacao(lExibeHelp) CLASS QDODocumentControl
    Local lImplantado := .F.

    Self:validaInconsistenciaImplantacao(@lImplantado, lExibeHelp)
    If !lImplantado .AND. lExibeHelp
        //STR0008 - "Implantação não executada."
        //STR0009 - "Execute o implantador 'QDOWizPDF' a partir de um computador com o MS Office instalado para remover a senha de todos os documentos do SIGAQDO."
        Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0008, STR0009)
    EndIf
Return lImplantado

/*/{Protheus.doc} validaInstalacaoConversores
Valida Instalação dos Conversores
@author brunno.costa
@since  29/11/2021
@param 01 - lExibeHelp, lógico, indica se deve realizar a exibição dos Helps de Falhas
@return lInstalado, lógico, indica se existe pelo menos um conversor em PDF instalado (MS Office ou LibreOffice)
/*/
METHOD validaInstalacaoConversores(lExibeHelp) CLASS QDODocumentControl
    Local lInstalado := .T.
    If !Self:lServerLinux .AND. !Self:existeLibreOffice(.F.) .AND. !Self:existeMSOffice(.F.)
        lInstalado := .F.
        If lExibeHelp
            //STR0010 - "Falha na Conversão! O conversor de documento em PDF não está instalado no servidor."
            //STR0011 - "Solicite apoio do departamento de TI: é necessário seguir a documentação para instalação de um dos conversores de arquuivos .doc para .pdf no servidor de Aplicação do Protheus (MS Office ou LibreOffice)."
            Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0010, STR0011)
        EndIf
    EndIf
Return lInstalado

/*/{Protheus.doc} apagaArquivo
Apaga Arquivo do servidor ou estação de trabalho
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo para exclusão
@param 02 - lServer   , lógico  , indica se o arquivo está no servidor de aplicação do Protheus (.T.) ou no computador local (.F.)
@param 03 - lExibeHelp, lógico  , indica se deve realizar a exibição dos Helps de Falhas
@return lExcluido, lógico, indica se o arquivo foi excluido com sucesso
/*/
METHOD apagaArquivo(cArquivo, lServer, lExibeHelp) CLASS QDODocumentControl

    Local cCaminho    := ""
    Local lExcluido   := .F.
    Local nErase      := 0
    Local bErrorBlock := ErrorBlock({|oError| QDODocumentControl():erroExclusaoArquivo(cArquivo, oError:Description, lServer, lExibeHelp), Break(oError) })

    Begin Sequence

        If lServer
            cCaminho  := Self:cDirDocServer + Lower(AllTrim(cArquivo))
        Else
            cCaminho  := Self:cDirDocLocal + Lower(AllTrim(cArquivo))
        EndIf

        If File(cCaminho)
            nErase := FErase(cCaminho)
            If nErase != -1
                lExcluido := .T.
            EndIf
        Else
            lExcluido := .T.
        EndIf
	
	Recover
        lExcluido := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

Return lExcluido

/*/{Protheus.doc} apagaArquivoLocal
Apaga Arquivo no Computador Local
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo para exclusão
@param 02 - lExibeHelp, lógico  , indica se deve realizar a exibição dos Helps de Falhas
@return lExcluido, lógico, indica se o arquivo foi excluido com sucesso
/*/
METHOD apagaArquivoLocal(cArquivo, lExibeHelp) CLASS QDODocumentControl
    Default lExibeHelp := .T.
Return Self:apagaArquivo(cArquivo, .F., lExibeHelp)

/*/{Protheus.doc} apagaArquivoServidor
Apaga Arquivo no Servidor
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo para exclusão
@param 02 - lExibeHelp, lógico  , indica se deve realizar a exibição dos Helps de Falhas
@return lExcluido, lógico, indica se o arquivo foi excluido com sucesso
/*/
METHOD apagaArquivoServidor(cArquivo, lExibeHelp) CLASS QDODocumentControl
    Default lExibeHelp := .T.
Return Self:apagaArquivo(cArquivo, .T., lExibeHelp)

/*/{Protheus.doc} erroExclusaoArquivo
Tratamento de Erro Durante Exclusão do Arquivo
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo para exclusão
@param 02 - cErro     , caracter, erro durante a exclusão do arquivo
@param 03 - lServer   , lógico  , indica se o arquivo está no servidor de aplicação do Protheus (.T.) ou no computador local (.F.)
@param 04 - lExibeHelp, lógico  , indica se deve realizar a exibição dos Helps de Falhas
/*/
METHOD erroExclusaoArquivo(cArquivo, cErro, lServer, lExibeHelp) CLASS QDODocumentControl
    Default lExibeHelp := .T.
    If lExibeHelp
        //STR0013 - "Solicite apoio do departamento de TI informando este erro."
        If lServer
            //STR0012 - "Falha na exclusão de arquivo do servidor"
            Self:help(ProcName(2) + '-' + cValToChar(procLine(2)), STR0012 + " '" + cArquivo + "': " + AllTrim(cErro) + ".", STR0013)
        Else
            //STR0014 - "Falha na exclusão de arquivo do computador local"
            Self:help(ProcName(2) + '-' + cValToChar(procLine(2)), STR0014 + " '" + cArquivo + "': " + AllTrim(cErro) + ".", STR0013)
        EndIf
    EndIf
Return

/*/{Protheus.doc} validaExecucaoViaWebApp
Valida se a execução é via WEBAPP
@author brunno.costa
@since  10/05/2022
@Return lReturn, lógico, indica se a execução é via WEBAPP
/*/
METHOD validaExecucaoViaWebApp() CLASS QDODocumentControl
Return (GetRemoteType() == 5)

/*/{Protheus.doc} copiaArquivoDoServidor
Copia Arquivo do Servidor para o Computador Local
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivoPDF, caracter, nome do Arquivo PDF do Servidor
@Return lCopiou, lógico, indica se conseguiu realizar a cópia do arquivo
/*/
METHOD copiaArquivoDoServidor(cArquivoPDF) CLASS QDODocumentControl
    Local lCopiou := .F.
    Local bErrorBlock := ErrorBlock({|oError| QDODocumentControl():erroCopiaArquivo(cArquivoPDF, oError:Description, 0), Break(oError) })

    Begin Sequence

        If __CopyFile(Self:cDirDocServer + cArquivoPDF, Self:cDirDocLocal + cArquivoPDF)
            lCopiou := .T.
        Else
            //STR0015 - "Falha na cópia de arquivo do servidor"
            //STR0013 - "Solicite apoio do departamento de TI informando este erro."
            Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0015 + " '" + cArquivoPDF + "'.", STR0013)
        Endif
	
	Recover
        lCopiou := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

Return lCopiou

/*/{Protheus.doc} copiaArquivoDoServidorParaWEBAPP
Copia Arquivo do Servidor para o Computador Local para WEBAPP
@author brunno.costa
@since  10/05/2022
@param 01 - cArquivoPDF, caracter, nome do Arquivo PDF do Servidor
@param 02 - nErrorAux  , número  , alternativa para cobertura de trecho de erro
@Return lCopiou, lógico, indica se conseguiu realizar a cópia do arquivo
/*/
METHOD copiaArquivoDoServidorParaWEBAPP(cArquivoPDF, nErrorAux) CLASS QDODocumentControl
    
    Local lCopiou     := .F.

    Default nErrorAux := CpyS2TW(Self:cDirDocServer + cArquivoPDF, .F.)

    If nErrorAux == 0
        lCopiou := .T.
    Else
        //STR0015 - "Falha na cópia de arquivo do servidor"
        //STR0013 - "Solicite apoio do departamento de TI informando este erro."
        Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0015 + " '" + cArquivoPDF + "'.", STR0013)
    Endif

Return lCopiou

/*/{Protheus.doc} copiaArquivoParaServidor
Copia Arquivo do Computador Local para o Servidor
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivoLocal, caracter, nome do Arquivo Local para Copiar
@param 02 - cNovoNome    , caracter, nome do Arquivo Destino no Servidor
@Return lCopiou, lógico, indica se conseguiu realizar a cópia do arquivo
/*/
METHOD copiaArquivoParaServidor(cArquivoLocal, cNovoNome) CLASS QDODocumentControl
    Local lCopiou := .F.
    Local bErrorBlock := ErrorBlock({|oError| QDODocumentControl():erroCopiaArquivo(cArquivoPDF, oError:Description, 1), Break(oError) })

    Default cNovoNome := cArquivoLocal

    Begin Sequence

        If __CopyFile(Self:cDirDocLocal + cArquivoLocal, Self:cDirDocServer + cNovoNome)
            lCopiou := .T.
        Else
            //STR0016 - "Falha na cópia de arquivo para o servidor"
            //STR0013 - "Solicite apoio do departamento de TI informando este erro."
            Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0016 + " '" + cArquivoLocal + "'.", STR0013)
        Endif
	
	Recover
        lCopiou := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

Return lCopiou

/*/{Protheus.doc} copiaParaDocNoServidor
Copia Arquivo .CEL para .DOC ou .DOCX No Servidor
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo   , caracter, arquivo original .cel para cópia
@param 02 - cArquivoDOC, caracter, retorna por referência o nome do arquivo destino .doc que será criado
@Return lCopiou, lógico, indica se conseguiu realizar a cópia do arquivo
/*/
METHOD copiaParaDocNoServidor(cArquivo, cArquivoDOC) CLASS QDODocumentControl
    Local lCopiou := .F.
    Local bErrorBlock := ErrorBlock({|oError| QDODocumentControl():erroCopiaArquivo(cArquivoPDF, oError:Description, 2), Break(oError) })

    Begin Sequence

        cArquivoDOC := StrTran(cArquivo, ".cel", "_Random_TMP_" + cValToChar(Randomize( 10000, 11000 )) + ".doc")
        If __CopyFile(Self:cDirDocServer + cArquivo, Self:cDirDocServer + cArquivoDOC)
            lCopiou := .T.
        Else
            //STR0017 - "Falha na cópia de arquivo .doc"
            //STR0018 - "para"
            //STR0019 - "no servidor."
            //STR0013 - "Solicite apoio do departamento de TI informando este erro."
            Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0017 + " '" + cArquivo + "' " + STR0018 + " '" + cArquivoDOC + "' " + STR0019, STR0013)
        Endif
	
	Recover
        lCopiou := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

Return lCopiou

/*/{Protheus.doc} erroCopiaArquivo
Tratamento de Erro Durante Cópia do Arquivo
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo   , caracter, arquivo original .cel para cópia
@param 02 - cErro      , caracter, erro durante a cópia do arquivo
@param 03 - nOperacao  , número  , indica a operação onde ocorreu o erro: 
                        nOperacao == 0 -> Falha na cópia de arquivo do servidor
                        nOperacao == 1 -> Falha na cópia de arquivo para o servidor
                        nOperacao == 2 -> Falha na cópia de arquivo entre diretórios do servidor
/*/
METHOD erroCopiaArquivo(cArquivo, cErro, nOperacao) CLASS QDODocumentControl
    Default nOperacao = 0
    //STR0013 - "Solicite apoio do departamento de TI informando este erro."
    If nOperacao == 2
        //STR0020 = "Falha na cópia de arquivo entre diretórios do servidor"
        Self:help(ProcName(2) + '-' + cValToChar(procLine(2)), STR0020 + " '" + cArquivo + "': " + AllTrim(cErro) + ".", STR0013)
    ElseIf nOperacao == 1
        //STR0016 - "Falha na cópia de arquivo para o servidor"
        Self:help(ProcName(2) + '-' + cValToChar(procLine(2)), STR0016 + " '" + cArquivo + "': " + AllTrim(cErro) + ".", STR0013)
    ElseIf nOperacao == 0
        //STR0015 - "Falha na cópia de arquivo do servidor"
        Self:help(ProcName(2) + '-' + cValToChar(procLine(2)), STR0015 + " '" + cArquivo + "': " + AllTrim(cErro) + ".", STR0013)
    EndIf
Return

/*/{Protheus.doc} criaAliasArquivos
Cria Alias dos Arquivos para Remoção de Senhas
@author brunno.costa
@since  29/11/2021
@param 01 - cAlias    , caracter, retorna por referência o Alias Criado
@param 02 - nRegistros, número  , retorna por referência a quantidade de registros
@return lSucesso, lógico, indica se conseguiu realizar a criação do Alias
/*/
METHOD criaAliasArquivos(cAlias, nRegistros) CLASS QDODocumentControl
    Local aArea        := GetArea()
    Local bErrorBlock  := ErrorBlock({|oError| QDODocumentControl():erroCriacaoAlias(oError:Description), Break(oError)})
    Local lSucesso     := .T.
    Default nRegistros := 0

    cAlias            := GetNextAlias()

    Begin Sequence

        BeginSql Alias cAlias
            SELECT COUNT(QDH_NOMDOC) QUANTIDADE
            FROM (SELECT DISTINCT QDH_NOMDOC 
                    FROM %Table:QDH% 
                   WHERE QDH_DTOIE ='I' 	  
                     AND QDH_FILIAL = %xFilial:QDH%
                     AND %NotDel%) CONTAGEM
        EndSql

        nRegistros := (cAlias)->QUANTIDADE

        (cAlias)->(DbCloseArea())

        BeginSql Alias cAlias
            SELECT DISTINCT QDH_NOMDOC 
              FROM %Table:QDH% 
             WHERE QDH_DTOIE ='I'
               AND QDH_FILIAL = %xFilial:QDH%
               AND %NotDel%
            ORDER BY QDH_NOMDOC
        EndSql

    Recover
        lSucesso := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

    RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} erroCriacaoAlias
Tratamento de Erro durante criação de Alias
@author brunno.costa
@since  29/11/2021
@param 01 - cErro, caracter, erro durante a criação do alias
/*/
METHOD erroCriacaoAlias(cErro) CLASS QDODocumentControl
    //STR0021 - "Falha durante identificação dos arquivos para remoção de senha"
    //STR0013 - "Solicite apoio do departamento de TI informando este erro."
    Self:help(ProcName(2) + '-' + cValToChar(procLine(2)), STR0021 + ": " + AllTrim(cErro) + ".", STR0013)
Return

/*/{Protheus.doc} existeArquivo
Valida Existência do Arquivo
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo para exclusão
@param 02 - lServer   , lógico  , indica se o arquivo está no servidor de aplicação do Protheus (.T.) ou no computador local (.F.)
@return lExiste, lógico, indica se existe o cArquivo de acordo com lServer
/*/
METHOD existeArquivo(cArquivo, lServer) CLASS QDODocumentControl
    Local lExiste := .F.
    If lServer
        lExiste := File(Self:cDirDocServer + cArquivo)
    Else
        lExiste := File(Self:cDirDocLocal + cArquivo)
    EndIf
Return lExiste

/*/{Protheus.doc} existeArquivoForaDoRootPath
Identifica Se Existe Arquivo Fora do RootPath
@author brunno.costa
@since  29/11/2021
@param 01 - cCaminho  , caracter, caminho do arquivo fora do RootPath para validação
@param 02 - lExibeHelp, lógico  , indica se deve realizar a exibição do Help em caso de Erro
@return lExiste, lógico, existe o cCaminho no servidor de aplicação do ERP
/*/
METHOD existeArquivoForaDoRootPath(cCaminho, lExibeHelp) CLASS QDODocumentControl

    Local bErrorBlock := ErrorBlock({|oError| QDODocumentControl():erroVerificacaoExistenciaForaDoRootPath(cCaminho, oError:Description, lExibeHelp), Break(oError)})
    Local cArquivoBat := "qdo_existe_arquivo.bat"
    Local cArquivoNao := "qdo_nao_tem_arquivo.tmp"
    Local cArquivoTem := "qdo_tem_arquivo.tmp"
    Local cSufixo     := ""
    Local lExiste     := .F.
    Local cDiretorio

    Begin Sequence

        cSufixo     := StrTran(Self:extraiArquivoDoCaminho(cCaminho), ".", "_") +  "_" + cValToChar(Randomize( 10000, 11000 )) 
        cArquivoBat := StrTran( cArquivoBat, ".bat", "_" + cSufixo + ".bat" )
        cArquivoNao := StrTran( cArquivoNao, ".tmp", "_" + cSufixo + ".tmp" )
        cArquivoTem := StrTran( cArquivoTem, ".tmp", "_" + cSufixo + ".tmp" )
        cDiretorio  := StrTran(GetSrvProfString( "RootPath", "\"), "/", "\") + Self:cDirDocServer

        If Self:criaBatExisteArquivoQDO(cArquivoBat)
            If WaitRunSrv(cDiretorio + cArquivoBat;
                            + ' "' + cCaminho   + '"';
                            + ' "' + cDiretorio + cArquivoTem + '" ';
                            + ' "' + cDiretorio + cArquivoNao + '" ', .T., Left(cDiretorio, 3))
                Self:apagaArquivoServidor(cArquivoBat, .F.)
                If Self:existeArquivo(cArquivoTem, .T.) .AND. !Self:existeArquivo(cArquivoNao, .T.)
                    lExiste := .T.
                ElseIf lExibeHelp
                    If Self:existeArquivo(cArquivoTem, .T.) .AND. Self:existeArquivo(cArquivoNao, .T.)
                        //STR0022 - "Não conseguimos confirmar a existência do arquivo no servidor de aplicação do TOTVS Protheus"
                        //STR0023 - "Solicite apoio do departamento de TI informando este erro. Revise travamento nos arquivos do RootPath: qdo_tem_arquivo*.tmp e qdo_nao_tem_arquivo*.tmp."
                        Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0022 + ": '" + cCaminho + "'.", STR0023)
                    Else
                        //STR0022 - "Não conseguimos confirmar a existência do arquivo no servidor de aplicação do TOTVS Protheus"
                        //STR0024 - "Solicite apoio do departamento de TI informando este erro. Revise os direitos de acesso do usuário que executa o AppServer.exe."
                        Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0022 + ": '" + cCaminho + "'.", STR0024)
                    EndIf
                EndIf
                Self:apagaArquivoServidor(cArquivoTem, .F.)
                Self:apagaArquivoServidor(cArquivoNao, .F.)
            Else
                //STR0022 - "Não conseguimos confirmar a existência do arquivo no servidor de aplicação do TOTVS Protheus"
                //STR0024 - "Solicite apoio do departamento de TI informando este erro. Revise os direitos de acesso do usuário que executa o AppServer.exe."
                Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0022 + ": '" + cCaminho + "'.", STR0024)
            EndIf
        ElseIf lExibeHelp
            //STR0025 - "Falha na validação da implantação da leitura de documentos 'Internos no ERP'."
            //STR0026 - "Solicite apoio do departamento de TI informando este erro. Revise a permissão de acesso do usuário que executa o AppServere.exe ao diretório"
            Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0025, STR0026 + " '" + cDiretorio + "'.")
        EndIf
	
	Recover
        lExiste := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

Return lExiste

/*/{Protheus.doc} extraiArquivoDoCaminho
Extrai o Nome do Arquivo do Caminho
@author brunno.costa
@since  29/11/2021
@param 01 - cCaminho, caracter, caminho do arquivo
@return cArquivo, caracter, nome do arquivo
/*/
METHOD extraiArquivoDoCaminho(cCaminho) CLASS QDODocumentControl
    Local cArquivo  := cCaminho
    Local aCaminhos
    If At( "\", cCaminho ) > 0
        aCaminhos := StrTokArr( cCaminho, "\" )
        cArquivo  := aCaminhos[Len(aCaminhos)]
    ElseIf At( "/", cCaminho ) > 0
        aCaminhos := StrTokArr( cCaminho, "/" )
        cArquivo  := aCaminhos[Len(aCaminhos)]
    EndIf
Return cArquivo

/*/{Protheus.doc} erroVerificacaoExistenciaForaDoRootPath
Tratamento de Erro Durante Verificação da Existência de Arquivo no Servidor Fora do RootPath
@author brunno.costa
@since  29/11/2021
@param 01 - cCaminho  , caracter, caminho do arquivo
@param 02 - cErro     , caracter, erro durante a verificação de existência do arquivo fora do rootpath
@param 03 - lExibeHelp, lógico  , indica se deve realizar a exibição do Help em caso de Erro
/*/
METHOD erroVerificacaoExistenciaForaDoRootPath(cCaminho, cErro, lExibeHelp) CLASS QDODocumentControl
    Default lExibeHelp := .T.
    If lExibeHelp
        //STR0022 - "Não conseguimos confirmar a existência do arquivo no servidor de aplicação do TOTVS Protheus"
        //STR0024 - "Solicite apoio do departamento de TI informando este erro. Revise os direitos de acesso do usuário que executa o AppServer.exe."
        Self:help(ProcName(2) + '-' + cValToChar(procLine(2)), STR0022 + " '" + cCaminho + "' : " + AllTrim(cErro) + ".", STR0024)
    EndIf
Return

/*/{Protheus.doc} existeLibreOffice
Valida Existência do LibreOffice no Server do Protheus
@author brunno.costa
@since  29/11/2021
@param 01 - lExibeHelp, lógico, indica se deve realizar a exibição do Help em caso de Erro
@return lExiste, lógico, existe o LibreOffice instalado no diretório do MV_QDOLOD
/*/
METHOD existeLibreOffice(lExibeHelp) CLASS QDODocumentControl
    Local cCaminho := Lower(AllTrim(SuperGetMV("MV_QDOLOD",.F.,"C:\Program Files\LibreOffice\program\swriter.exe")))
    Local lExiste  := Self:existeArquivoForaDoRootPath(cCaminho, lExibeHelp)
Return lExiste


/*/{Protheus.doc} existeMSOffice
Valida Existência do Microsoft Office
@author brunno.costa
@since  29/11/2021
@param 01 - lExibeHelp, lógico, indica se deve realizar a exibição do Help em caso de Erro
@return lExiste, lógico, existe o MS Office instalado no diretório do MV_QDOMSOD
/*/
METHOD existeMSOffice(lExibeHelp) CLASS QDODocumentControl
    Local cCaminho := ""
    Local lExiste  := .F.

    cCaminho := Lower(AllTrim(SuperGetMV("MV_QDOMSOD",.F.,"C:\Program Files\Microsoft Office\Office15\WINWORD.EXE")))
    If Self:existeArquivoForaDoRootPath(cCaminho, lExibeHelp)
        lExiste := .T.
    EndIf

Return lExiste

/*/{Protheus.doc} criaBatExisteArquivoQDO
Cria Arquivo .bat Que Validará a Existência de Arquivos Fora do RootPath
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivoBat, caracter, nome do arquivo para criação do .bat de verificação de existência de arquivos
@return lCriado, lógico, identifica se o arquivo está criado após a execução
/*/
METHOD criaBatExisteArquivoQDO(cArquivoBat) CLASS QDODocumentControl
    Local cTexto  := ""
    Local lCriado := .F.
    Default cArquivoBat := 'qdo_existe_arquivo' + "_" + cValToChar(Randomize( 10000, 11000 )) + '.bat' 
    If Self:existeArquivo(cArquivoBat, .T.)
        lCriado := .T.
    Else
        //cTexto += ENTER + ' :: Desliga o echo dos comandos '
        cTexto += ENTER + ' @echo off '
        
        cTexto += ENTER + ' setlocal '
        
        //cTexto += ENTER + ' :: Recebe o nome do arquivo como primeiro parametro de entrada. Ex:   teste.cmd "arquivo.tmp" '
        cTexto += ENTER + ' set FILE=%1 '
        
        //cTexto += ENTER + ' :: Definicao dos arquivos de reposta. Estes arquivos devem estar no "rootpath" para facilitar a sua leitura '
        //cTexto += ENTER + ' :: Recebe o nome do arquivo como segundo parametro de entrada. '
        cTexto += ENTER + ' set RESP_OK=%2 '
        //cTexto += ENTER + ' :: Recebe o nome do arquivo como terceiro parametro de entrada. '
        cTexto += ENTER + ' set RESP_NOK=%3 '
        
        //cTexto += ENTER + ' :: Remove respostas anteriores '
        cTexto += ENTER + ' del /F %RESP_OK% 2> NUL '
        cTexto += ENTER + ' del /F %RESP_NOK% 2> NUL '
        
        //cTexto += ENTER + ' :: VerIFica se o arquivo resposta existe '
        cTexto += ENTER + ' IF EXIST %RESP_OK% ( '
        cTexto += ENTER + '   echo Nao deveria existir OK: %RESP_OK% '
        cTexto += ENTER + '   GOTO END_ERR '
        cTexto += ENTER + ' ) '
        
        //cTexto += ENTER + ' :: Verifica se o arquivo resposta existe '
        cTexto += ENTER + ' IF EXIST %RESP_NOK% ( '
        cTexto += ENTER + '   echo Nao deveria existir NOK: %RESP_NOK% '
        cTexto += ENTER + '   GOTO END_ERR '
        cTexto += ENTER + ' ) '
        
        //cTexto += ENTER + ' :: Verifica se o arquivo existe '
        cTexto += ENTER + ' IF EXIST %FILE% ( '
        cTexto += ENTER + '   echo [QDODocumentControl] ['+cArquivoBat+']Encontrou o arquivo %FILE% '
        cTexto += ENTER + '   echo %FILE% >> %RESP_OK% '
        cTexto += ENTER + ' ) ELSE ( '
        cTexto += ENTER + '   echo [QDODocumentControl] ['+cArquivoBat+']Nao encontrou o arquivo %FILE% '
        cTexto += ENTER + '   echo %FILE% >> %RESP_NOK% '
        cTexto += ENTER + ' ) '
        
        //cTexto += ENTER + ' :: Verifica se o arquivo resposta existe '
        cTexto += ENTER + ' IF EXIST %RESP_OK% ( '
        cTexto += ENTER + '   echo [QDODocumentControl] ['+cArquivoBat+']Criou o arquivo %RESP_OK% '
        cTexto += ENTER + ' ) ELSE ( '

        //cTexto += ENTER + '   :: Verifica se o arquivo resposta existe '
        cTexto += ENTER + '   IF EXIST %RESP_NOK% ( '
        cTexto += ENTER + '     echo [QDODocumentControl] ['+cArquivoBat+']Criou o arquivo %RESP_NOK% '
        cTexto += ENTER + '   ) ELSE ( '
        cTexto += ENTER + '     echo [QDODocumentControl] ['+cArquivoBat+']Nao criou resposta para o arquivo: %FILE% '
        cTexto += ENTER + '     GOTO END_ERR '
        cTexto += ENTER + '   ) '
        cTexto += ENTER + ' ) '
        
        cTexto += ENTER + ' GOTO END_OK '
        
        //cTexto += ENTER + ' :: Final de execucao ERR '
        cTexto += ENTER + ' :END_ERR '
        cTexto += ENTER + ' echo [QDODocumentControl] ['+cArquivoBat+'] Saindo com ERRO '
        cTexto += ENTER + ' endlocal '
        cTexto += ENTER + ' exit /B 1 '
        cTexto += ENTER + ' GOTO END '
        
        //cTexto += ENTER + ' :: Final de execucao OK '
        cTexto += ENTER + ' :END_OK '
        
        cTexto += ENTER + ' :END '
        
        cTexto += ENTER + ' endlocal '
        cTexto += ENTER + ' exit /B 0  '

        If !Self:lLogConsole
            cTexto := StrTran(cTexto, " echo ", " REM ")
            cTexto := StrTran(cTexto, " REM %FILE% ", " echo %FILE% ")
        EndIf

        If MemoWrite( Self:cDirDocServer + cArquivoBat, cTexto )
            lCriado := .T.
        EndIf
    EndIf
Return lCriado

/*/{Protheus.doc} criaScriptLibreOfficeCMD
Cria Arquivo .bat Que Converterá o .Cel em PDF via LibreOffice
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivoBat, caracter, nome do arquivo para criação do .bat de conversão de arquivos via LibreOffice
@return lCriado, lógico, identifica se o arquivo está criado após a execução
/*/
METHOD criaScriptLibreOfficeCMD(cArquivoBat) CLASS QDODocumentControl
    Local cTexto  := ""
    Local lCriado := .F.
    Default cArquivoBat := 'qdo_libreoffice_to_pdf' + "_" + cValToChar(Randomize( 10000, 11000 )) + '.bat' 
    If Self:existeArquivo(cArquivoBat, .T.)
        lCriado := .T.
    Else
        cTexto += ENTER + ' @echo off '
        cTexto += ENTER + ' setlocal '
        cTexto += ENTER + ' set INPUT=%1 '
        cTexto += ENTER + ' set OUTPUT=%2 '

        cTexto += ENTER + ' del /F %OUTPUT% 2> NUL '

        cTexto += ENTER + ' cd "' + StrTran(GetSrvProfString( "RootPath", "\"), "/", "\") + Self:cDirDocServer + '"'

        cTexto += ENTER + '"' + Lower(AllTrim(SuperGetMV("MV_QDOLOD",.F.,"C:\Program Files\LibreOffice\program\swriter.exe"))) + '" --headless --convert-to pdf %INPUT% '

        cTexto += ENTER + ' IF EXIST %OUTPUT% ( '
        cTexto += ENTER + '   echo [QDODocumentControl] ['+cArquivoBat+'] Criou o arquivo %OUTPUT% '
        cTexto += ENTER + ' ) ELSE ( '
        cTexto += ENTER + '   echo [QDODocumentControl] ['+cArquivoBat+'] Nao criou o arquivo %OUTPUT% '
        cTexto += ENTER + '   GOTO END_ERR '
        cTexto += ENTER + ' ) '
        
        cTexto += ENTER + ' GOTO END_OK '
        cTexto += ENTER + ' :END_ERR '
        cTexto += ENTER + ' echo [QDODocumentControl] ['+cArquivoBat+'] Saindo com ERRO '
        cTexto += ENTER + ' endlocal '
        cTexto += ENTER + ' exit /B 1 '
        cTexto += ENTER + ' GOTO END '
        cTexto += ENTER + ' :END_OK '
        cTexto += ENTER + ' :END '
        cTexto += ENTER + ' endlocal '
        cTexto += ENTER + ' exit /B 0  '

        If !Self:lLogConsole
            cTexto := StrTran(cTexto, " echo ", " REM ")
            cTexto := StrTran(cTexto, " REM %FILE% ", " echo %FILE% ")
        EndIf

        If MemoWrite( Self:cDirDocServer + cArquivoBat, cTexto )
            lCriado := .T.
        EndIf
    EndIf
Return lCriado

/*/{Protheus.doc} criaScriptMSOfficePowerShell
Cria Arquivo .ps1 Que Converterá o .Cel em PDF via MS Office / PowerShell
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivoPS, caracter, nome do arquivo para criação do .ps1 de conversão de arquivos via MS Office
@return lCriado, lógico, identifica se o arquivo está criado após a execução
/*/
METHOD criaScriptMSOfficePowerShell(cArquivoPS) CLASS QDODocumentControl
    Local cTexto  := ""
    Local lCriado := .F.
    Default cArquivoPS := 'qdo_msoffice_to_pdf' + "_" + cValToChar(Randomize( 10000, 11000 )) + '.ps1' 

    If Self:existeArquivo(cArquivoPS, .T.)
        lCriado := .T.
    Else

        cTexto += ENTER + ' param($INPUTAUX, $OUTPUT) '
        cTexto += ENTER + ' $word = New-Object -ComObject Word.Application '
        cTexto += ENTER + ' $word.Visible = $false '
        cTexto += ENTER + ' $doc = $word.Documents.Open("$INPUTAUX") '
        cTexto += ENTER + ' #Creates the PDF file '
        cTexto += ENTER + ' $name = $OUTPUT '
        cTexto += ENTER + ' $doc.SaveAs($name, 17) '
        cTexto += ENTER + ' $doc.Close() '
        cTexto += ENTER + ' $word.Quit() '

        If MemoWrite( Self:cDirDocServer + cArquivoPS, cTexto )
            lCriado := .T.
        EndIf
    EndIf
Return lCriado

/*/{Protheus.doc} geraPDF
Gera Arquivo PDF a Partir do Arquivo .cel (.doc / .docx) Sem Senha
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo   , caracter, nome do arquivo do servidor no diretório padrão de documentos do QDO para geração de PDF
@param 02 - cArquivoPDF, caracter, retorna por referência o nome do arquivo PDF criado
@return lGerou, lógico, indica se conseguiu gerar o arquivo PDF
/*/
METHOD geraPDF(cArquivo, cArquivoPDF) CLASS QDODocumentControl
    Local lGerou     := .F.

    If Self:validaImplantacao(.T.) .AND. Self:existeArquivo(cArquivo, .T.)
        cArquivoPDF := StrTran(cArquivo   , '.docx', ".pdf") 
        cArquivoPDF := StrTran(cArquivoPDF, '.doc' , ".pdf")
        If Self:lServerLinux
            lGerou := Self:geraPDFComLibreOfficeEmLinux(Lower(cArquivo), Lower(cArquivoPDF))
        Else
            If Self:existeMSOffice(.F.)
                lGerou := Self:geraPDFComMSOffice(cArquivo, cArquivoPDF)
            EndIf

            If !lGerou .AND. Self:existeLibreOffice(.F.)
                lGerou := Self:geraPDFComLibreOffice(cArquivo, cArquivoPDF)
            EndIf
        Endif
    EndIf

Return lGerou

/*/{Protheus.doc} geraPDFComLibreOffice
Gera Arquivo PDF a Partir do Arquivo .cel (.doc / .docx) Sem Senha - LibreOffice
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo   , caracter, nome do arquivo do servidor no diretório padrão de documentos do QDO para geração de PDF
@param 02 - cArquivoPDF, caracter, retorna por referência o nome do arquivo PDF criado
@return lGerou, lógico, indica se conseguiu gerar o arquivo PDF
/*/
METHOD geraPDFComLibreOffice(cArquivo, cArquivoPDF) CLASS QDODocumentControl
    Local cArquivoBat := 'qdo_libreoffice_to_pdf_' + AllTrim(StrTran(cArquivo, ".", "_")) + '.bat'
    Local cDiretorio  := StrTran(GetSrvProfString( "RootPath", "\"), "/", "\") + Self:cDirDocServer
    Local cInput      := cArquivo
    Local cOutput     := cArquivoPDF
    Local lGerou      := .F.
    Local lLock       := .F.
    Local nMaxTentat  := 10
    Local nTentativa  := 0
    Local nTentLock   := 0

    If Self:criaScriptLibreOfficeCMD(cArquivoBat)
        //Tenta novamente devido possibilidade de em ambiente CLOUD ocorrer conversão simultânea em mais de um AppServer.EXE
        //O LibreOffice não é consistente neste cenário, ocorrem casos de conversões serem perdidas
        While !(lLock:=LockByName("QDODocumentControl_geraPDFComLibreOffice", .F., .F., .T.)) .AND. nTentLock<(10*nMaxTentat)
            nTentLock++
            Sleep(500)
        EndDo 
        If lLock
            For nTentativa := 1 to nMaxTentat 
                If WaitRunSrv(cDiretorio + cArquivoBat;
                    + ' "' + cDiretorio + cInput  + '"';
                    + ' "' + cDiretorio + cOutput + '" ', .T., Left(cDiretorio, 3))
                    If Self:existeArquivo(cArquivoPDF, .T.)
                        lGerou := .T.
                    Else
                        //STR0027 - "Arquivo PDF inexistente após tentativa de conversão para exibição em tela via LibreOffice."
                        //STR0028 - "Solicite apoio do departamento de TI informando este erro. Revise o parâmetro 'MV_QDOLOD' e os direitos de acesso do usuário que executa o AppServer.exe."
                        Self:logMsg("QDODocumentControl-" + cValToChar(ProcLine()), STR0027, STR0028)
                    EndIf
                Else
                    //STR0029 - "Falha durante tentativa de conversão do arquivo em PDF via LibreOffice."
                    //STR0028 - "Solicite apoio do departamento de TI informando este erro. Revise o parâmetro 'MV_QDOLOD' e os direitos de acesso do usuário que executa o AppServer.exe."
                    Self:logMsg("QDODocumentControl-" + cValToChar(ProcLine()), STR0029, STR0028)
                EndIf
                If lGerou
                    Exit
                Else
                    Sleep(500)
                EndIf
            Next
            UnLockByName("QDODocumentControl_geraPDFComLibreOffice", .F., .F., .T.)
        EndIf
        Self:apagaArquivoServidor(cArquivoBat, .F.)
    Else
        //STR0030 - "Falha durante criação do script de conversão do arquivo em PDF via LibreOffice."
        //STR0024 - "Solicite apoio do departamento de TI informando este erro. Revise os direitos de acesso do usuário que executa o AppServer.exe."
        Self:logMsg("QDODocumentControl-" + cValToChar(ProcLine()), STR0030, STR0024)
    EndIf

Return lGerou

/*/{Protheus.doc} geraPDFComLibreOfficeEmLinux
Gera Arquivo PDF a Partir do Arquivo .cel (.doc / .docx) Sem Senha - LibreOffice
@author brunno.costa
@since  20/09/2022
@param 01 - cArquivo   , caracter, nome do arquivo do servidor no diretório padrão de documentos do QDO para geração de PDF
@param 02 - cArquivoPDF, caracter, retorna por referência o nome do arquivo PDF criado
@return lGerou, lógico, indica se conseguiu gerar o arquivo PDF
/*/
METHOD geraPDFComLibreOfficeEmLinux(cArquivo, cArquivoPDF) CLASS QDODocumentControl
    Local cDiretorio := StrTran(GetSrvProfString( "RootPath", "/"), "\", "/") + Self:cDirDocServer
    Local cInput     := cArquivo
    Local csWriter   := Lower(AllTrim(SuperGetMV("MV_QDOLOD",.F.,"/usr/lib64/libreoffice/program/swriter")))
    Local lGerou     := .F.
    Local lLock      := .F.
    Local nMaxTentat := 10
    Local nTentativa := 0
    Local nTentLock  := 0

    //Tenta novamente devido possibilidade de em ambiente CLOUD ocorrer conversão simultânea em mais de um AppServer.EXE
    //O LibreOffice não é consistente neste cenário, ocorrem casos de conversões serem perdidas
    While !(lLock:=LockByName("QDODocumentControl_geraPDFComLibreOfficeEmLinux", .F., .F., .T.)) .AND. nTentLock<(10*nMaxTentat)
        nTentLock++
        Sleep(500)
    EndDo 
    If lLock
        For nTentativa := 1 to nMaxTentat 
            If WaitRunSrv(lower(csWriter + ' --headless --convert-to pdf "' + cDiretorio + cInput  + '"'), .T., cDiretorio)
                If Self:existeArquivo(cArquivoPDF, .T.)
                    lGerou := .T.
                Else
                    //STR0027 - "Arquivo PDF inexistente após tentativa de conversão para exibição em tela via LibreOffice."
                    //STR0028 - "Solicite apoio do departamento de TI informando este erro. Revise o parâmetro 'MV_QDOLOD' e os direitos de acesso do usuário que executa o AppServer.exe."
                    Self:logMsg("QDODocumentControl-" + cValToChar(ProcLine()), STR0027, STR0028)
                EndIf
            Else
                //STR0029 - "Falha durante tentativa de conversão do arquivo em PDF via LibreOffice."
                //STR0028 - "Solicite apoio do departamento de TI informando este erro. Revise o parâmetro 'MV_QDOLOD' e os direitos de acesso do usuário que executa o AppServer.exe."
                Self:logMsg("QDODocumentControl-" + cValToChar(ProcLine()), STR0029, STR0028)
            EndIf
            If lGerou
                Exit
            Else
                Sleep(500)
            EndIf
        Next
        UnLockByName("QDODocumentControl_geraPDFComLibreOfficeEmLinux", .F., .F., .T.)
    EndIf

Return lGerou

/*/{Protheus.doc} geraPDFComMSOffice
Gera Arquivo PDF a Partir do Arquivo .cel (.doc / .docx) Sem Senha - Microsoft Office
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo   , caracter, nome do arquivo do servidor no diretório padrão de documentos do QDO para geração de PDF
@param 02 - cArquivoPDF, caracter, retorna por referência o nome do arquivo PDF criado
@return lGerou, lógico, indica se conseguiu gerar o arquivo PDF
/*/
METHOD geraPDFComMSOffice(cArquivo, cArquivoPDF) CLASS QDODocumentControl
    Local cArquivoPS := 'qdo_msoffice_to_pdf_' + AllTrim(StrTran(cArquivo, ".", "_")) + '.ps1'
    Local cDiretorio  := StrTran(GetSrvProfString( "RootPath", "\"), "/", "\") + Self:cDirDocServer
    Local cInput      := cArquivo
    Local cOutput     := cArquivoPDF
    Local lGerou      := .F.

    If Self:criaScriptMSOfficePowerShell(cArquivoPS)
        If WaitRunSrv("PowerShell -NonInteractive -File ";
            + cDiretorio + cArquivoPS;
            + " -INPUTAUX "  + '"' + cDiretorio + cInput + '"';
            + " -OUTPUT " + '"' + cDiretorio + cOutput + '"', .T., Left(cDiretorio, 3))
            Self:apagaArquivoServidor(cArquivoPS, .F.)
            If Self:existeArquivo(cArquivoPDF, .T.)
                lGerou := .T.
            Else
                //STR0031 - "Arquivo PDF inexistente após tentativa de conversão para exibição em tela via MS Office."
                //STR0032 - "Solicite apoio do departamento de TI informando este erro. Revise o parâmetro 'MV_QDOMSOD' e os direitos de acesso do usuário que executa o AppServer.exe."
                Self:logMsg("QDODocumentControl-" + cValToChar(ProcLine()), STR0031, STR0032)
            EndIf
        Else
            //STR0033 - "Falha durante tentativa de conversão do arquivo em PDF via MS Office."
            //STR0032 - "Solicite apoio do departamento de TI informando este erro. Revise o parâmetro 'MV_QDOMSOD' e os direitos de acesso do usuário que executa o AppServer.exe."
            Self:logMsg("QDODocumentControl-" + cValToChar(ProcLine()), STR0033, STR0032)
        EndIf
    Else
        //STR0034 - "Falha durante criação do script de conversão do arquivo em PDF via MS Office."
        //STR0024 - "Solicite apoio do departamento de TI informando este erro. Revise os direitos de acesso do usuário que executa o AppServer.exe."
        Self:logMsg("QDODocumentControl-" + cValToChar(ProcLine()), STR0034, STR0024)
    EndIf

Return lGerou

/*/{Protheus.doc} removeSenhaWord
Remove Senha do Arquivo do Word
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo, caracter, nome do arquivo do servidor para remoção de senha
@param 02 - nError  , número  , retorna por referência o erro ocorrido
    1 - Arquivo não foi salvo pelo OLE_SaveAsFile
    2 - Arquivo não foi encontrado no servidor
    3 - Error.log no processo de remoção de senhas
@param 03 - oWord   , objeto  , objeto com link para MS Office.
@return lRemoveu, lógico, indica se conseguiu remover a senha do arquivo
/*/

METHOD removeSenhaWord(cArquivo, nError, oWord) CLASS QDODocumentControl
    Local lRemoveu    := .F.
    Local cEditor     := "TMsOleWord97"
    Local lReadOnly   := .F.
    Local cPassword   := IIf( GetMV("MV_QSAVPSW",.F.,"1") == "1","CELEWIN400","" )
    Local cArquivoTMP := ""
    Local nError      := 0

    Local bErrorBlock := ErrorBlock({|oError| QDODocumentControl():erroRemocaoDeSenha(oError:Description), Break(oError) })

    Begin Sequence

        cArquivoTMP := StrTran(cArquivo   , ".doc", ".tmp")
        cArquivoTMP := StrTran(cArquivoTMP, ".cel", ".tmp")

        If Self:existeArquivo(cArquivo, .T.)
            Self:copiaArquivoDoServidor(cArquivo)
            oWord := Iif(oWord==Nil, OLE_CreateLink( cEditor ), oWord)
            OLE_OpenFile( oWord, Self:cDirDocLocal + cArquivo, lReadOnly, cPassword, cPassword )
            OLE_SaveAsFile( oWord, Self:cDirDocLocal + cArquivoTMP, "", "", .F.)
            OLE_CloseFile( oWord )

            If Self:existeArquivo(cArquivoTMP, .F.)
                Self:apagaArquivoServidor(cArquivo, .T.)
                Self:copiaArquivoParaServidor(cArquivoTMP, cArquivo)
                Self:apagaArquivoLocal(cArquivo, .T.)
                Self:apagaArquivoLocal(cArquivoTMP, .T.)
                lRemoveu := .T.
            Else
                nError := 1
            EndIf
        Else
            nError := 2
        EndIf
        
	Recover
        lRemoveu := .F.
        nError   := 3

	End Sequence
    ErrorBlock(bErrorBlock)

Return lRemoveu

/*/{Protheus.doc} erroRemocaoDeSenha
Erro no Processo de Remoção de Senha
@author brunno.costa
@since  29/11/2021
@param 01 - cErro, caracter, erro durante a montagem do arquivo em tela
/*/
METHOD erroRemocaoDeSenha(cErro) CLASS QDODocumentControl
    //STR0035 - "Falha no processo de remoção de senha"
    //STR0036 - "É necessário instalar o MS Office no computador local."
    Self:help(ProcName(2) + '-' + cValToChar(procLine(2)), STR0035 + ": " + AllTrim(cErro) + ".", STR0036)
Return 

/*/{Protheus.doc} retornaBuild
Retorna Build do Ambiente
@author brunno.costa
@since  29/11/2021
@return nRet, número, número identificador da Build do sistema
/*/

METHOD retornaBuild() CLASS QDODocumentControl
	Local cBuild := GetBuild()
	Local nEnd
    Local nRet   := 0
		
	While ( At( ".", cBuild ) > 0 )
		nEnd   := At( ".", cBuild ) + 1
		cBuild := SubStr( cBuild, nEnd )		
	EndDo
	
	cBuild := SubStr( cBuild, 1, 2 )
	nRet   := Val( cBuild )
Return nRet

/*/{Protheus.doc} registraRemocaoSenhaArquivosServidorNaSX6
Registra a Implantação em Parâmetro da SX6
@author brunno.costa
@since  29/11/2021
/*/

METHOD registraRemocaoSenhaArquivosServidorNaSX6() CLASS QDODocumentControl
    Local aArea    := GetArea()
    If FWSX6Util():ExistsParam( "MV_QDOCPDF" )
	    PutMV("MV_QDOCPDF", .T.)
    EndIf
    RestArea(aArea)
Return

/*/{Protheus.doc} validaExistenciaDosParametrosSX6
Verifica a Existência de Parâmetros na SX6
@author brunno.costa
@since  29/11/2021
@return lExistem, lógico, indica se existem todos os parâmetros do processo na SX6
/*/

METHOD validaExistenciaDosParametrosSX6() CLASS QDODocumentControl
    Local aArea       := GetArea()
    Local aParametros := {"MV_QDOMSOD","MV_QDOLOD","MV_QDOCPDF"}
    Local lExistem    := .T.
    Local nParametro  := 0
    Local nTotal      := Len(aParametros)
    For nParametro := 1 to nTotal
        If !FWSX6Util():ExistsParam( aParametros[nParametro] )
            lExistem := .F.
            Exit
        EndIf
    Next
    RestArea(aArea)
Return lExistem

/*/{Protheus.doc} validaDicionario
Verifica o Tratamento de Dicionário no Campo QAA_TPWORD, retornando true quando existe a opção 4 = Leitura Interna no ERP...
@author brunno.costa
@since  29/11/2021
@return lExistem, lógico, indica se o dicionário de dados está compatibilizado
/*/

METHOD validaDicionario() CLASS QDODocumentControl
Return ("4="$GetSx3Cache("QAA_TPWORD","X3_CBOX"))

/*/{Protheus.doc} help
Exibe Help em Tela ou Log no Console.Log
@author brunno.costa
@since  29/11/2021
@param 01 - cTitulo , caracter, título do Help/Log pra exibição
@param 02 - cErro   , caracter, mensagem de problema
@param 03 - cSolucao, caracter, mensagem de solução
@param 04 - lSoLog  , lógico  , indica se deve ser exibido só o LogMsg ou o Help
/*/
METHOD help(cTitulo, cErro, cSolucao, lSoLog) CLASS QDODocumentControl
    Default lSoLog := .F.
    If GetRemoteType() != -1 .AND. !IsBlind() .and. !lSoLog
        cErro    := OemToAnsi(cErro)
        cSolucao := OemToAnsi(cSolucao)
        Help( " ", 1, cTitulo,,cErro,1, 1, NIL, NIL, NIL, NIL, NIL, {cSolucao})
    ElseIf !lSoLog
        If !Empty(cSolucao)
            MessageBox( STR0037 + ": " + cErro + ENTER + STR0038 + ": " + cSolucao, cTitulo, MB_ICONEXCLAMATION)
        Else
            MessageBox( STR0037 + ": " + cErro, cTitulo, MB_ICONEXCLAMATION )
        EndIf
    Else
        Self:logMsg(cTitulo, cErro, cSolucao)
    EndIf
Return

/*/{Protheus.doc} logMsg
Exibe LOG no Console.log
@author brunno.costa
@since  29/11/2021
@param 01 - cTitulo , caracter, título do Help/Log pra exibição
@param 02 - cErro   , caracter, mensagem de problema
@param 03 - cSolucao, caracter, mensagem de solução
/*/
METHOD logMsg(cTitulo, cErro, cSolucao) CLASS QDODocumentControl
    cErro    := OemToAnsi(cErro)
    cSolucao := OemToAnsi(cSolucao)
    If GetSrvProfString("QDODocumentControlLog", "0") == "1"
        LogMsg(cTitulo, 0, 0, 1, '', '', "[" + cTitulo + "] " + STR0037 + ": " + cErro) //Problema
        If !Empty(cSolucao)
            LogMsg(cTitulo, 0, 0, 1, '', '', "[" + cTitulo + "] " + STR0038 + ": " + cSolucao) //Solucao
        EndIf
    EndIf
Return 

/*/{Protheus.doc} usuarioValidoParaImpressao
Indica se O Usuário é Válido para Impressão no Documento, são válidos:
-> Demais usuários que fazem parte do processo de digitação à distribuição podem imprimir, 
desde que o documento esteja na sua etapa de responsabilidade.

@author brunno.costa
@since  29/11/2021
@param 01 - cDocumento, caracter, código do documento para consulta
@param 02 - cRevisao  , caracter, código da revisão para consulta
@param 03 - cUsuario  , caracter, código do usuário para consulta
@return lValido, lógico, indica se o usuário é válido para impressão no documento 
/*/
METHOD usuarioValidoParaImpressao(cDocumento, cRevisao, cUsuario) CLASS QDODocumentControl
    Local cAlias     := GetNextAlias()
    Local cLogin     := Nil
    Local cQDHStatus := Self:retornaStatusdoDocumento(cDocumento, cRevisao)
    Local lValido    := .F.

    Default cUsuario := RetCodUsr()

    cLogin  := Upper(AllTrim(UsrRetName(cUsuario)))

    BeginSql Alias cAlias
        SELECT COUNT(*) QTD
          FROM (SELECT QD1_SIT, QD1_DOCTO, QD1_RV, QD1_FILMAT, QD1_MAT, QD1_TPPEND
                  FROM %Table:QD1%
                 WHERE %NotDel%
                   AND QD1_SIT   <> 'I'
                   AND QD1_DOCTO  = %Exp:cDocumento%
                   AND QD1_RV     = %Exp:cRevisao%
                   AND QD1_FILMAT = %xfilial:QAA%) RESPONSAVEIS
    INNER JOIN (SELECT QDH_DOCTO, QDH_RV, QDH_STATUS
                  FROM %Table:QDH%
                 WHERE %NotDel%
                   AND QDH_DOCTO  = %Exp:cDocumento%
                   AND QDH_RV     = %Exp:cRevisao%
                   AND QDH_STATUS LIKE '%' + %Exp:cQDHStatus% + '%'
                   AND QDH_FILMAT = %xfilial:QAA%) DOCUMENTO 
            ON RESPONSAVEIS.QD1_DOCTO = DOCUMENTO.QDH_DOCTO
           AND RESPONSAVEIS.QD1_RV    = DOCUMENTO.QDH_RV
           AND (DOCUMENTO.QDH_STATUS LIKE '%' + RESPONSAVEIS.QD1_TPPEND + '%')
    INNER JOIN (SELECT QAA_FILIAL, QAA_LOGIN, QAA_MAT, QAA_DISTSN
                  FROM %Table:QAA%
                 WHERE %NotDel%
                   AND LTRIM(RTRIM(UPPER(QAA_LOGIN))) = %Exp:cLogin%) USUARIOS 
            ON RESPONSAVEIS.QD1_FILMAT = USUARIOS.QAA_FILIAL
           AND RESPONSAVEIS.QD1_MAT    = USUARIOS.QAA_MAT
         WHERE (DOCUMENTO.QDH_STATUS LIKE '%' + RESPONSAVEIS.QD1_TPPEND + '%')
    EndSql

    If !(cAlias)->(Eof()) .AND. (cAlias)->QTD > 0
        lValido := .T.
    EndIf 

    (cAlias)->(DbCloseArea())

Return lValido

/*/{Protheus.doc} validaUsoNoUsuario
Indica se o usuário está cadastrado para uso da exibição do documento dentro do Protheus
@author brunno.costa
@since  29/11/2021
@param 01 - cUsuario, caracter, código do usuário para consulta
@return lUsado, lógico, indica se deve realizar a impressão em tela para o usuário
/*/
METHOD validaUsoNoUsuario(cUsuario) CLASS QDODocumentControl
    Local cAlias := GetNextAlias()
    Local cLogin
    Local lUsado := .F.

    Default cUsuario := RetCodUsr()

    cLogin  := Upper(AllTrim(UsrRetName(cUsuario)))

    BeginSql Alias cAlias
        SELECT COUNT(*) AS QTD
		FROM %Table:QAA% 
		WHERE %NotDel%
            AND QAA_FILIAL             = %xfilial:QAA%
            AND QAA_TPWORD             = '4'
            AND LTRIM(RTRIM(UPPER(QAA_LOGIN))) = %Exp:cLogin%
    EndSql

    If !(cAlias)->(Eof()) .AND. (cAlias)->QTD > 0
        lUsado := .T.
    EndIf 

    (cAlias)->(DbCloseArea())

Return lUsado

/*/{Protheus.doc} enviaImpressao
Envia Impressão para o Sistema Operacional OU Exibe Help de problema caso o Usuário não tenha permissão
@author brunno.costa
@since  29/11/2021
@param 01 - oWebEngine, objeto, objeto da TWebEngine que exibe o documento
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
@param 04 - cUsuario  , caracter, código do usuário do sistema relacionado
/*/
METHOD enviaImpressao(oWebEngine, cDocumento, cRevisao, cUsuario) CLASS QDODocumentControl
    Local cLogin   := Nil
    Local lImprime := .F.
    Local lLeitura := "L" $ Self:retornaStatusdoDocumento(cDocumento, cRevisao) //Leitura
    Local lRetAux  := Nil

    Default cUsuario := RetCodUsr()

    cLogin  := Upper(AllTrim(UsrRetName(cUsuario)))

    Self:lPEAlteraRegraPadraoImpressao := Iif(Self:lPEAlteraRegraPadraoImpressao == Nil, ExistBlock("QDOLPDFIMP"), Self:lPEAlteraRegraPadraoImpressao)

    If !Self:lPEAlteraRegraPadraoImpressao .AND. !lLeitura .AND. Self:usuarioValidoParaImpressao(cDocumento, cRevisao, cUsuario)
        lImprime := .T.
    ElseIf !Self:lPEAlteraRegraPadraoImpressao
        If lLeitura
            //STR0048 - "Impressão não habilitada na etapa de leitura do documento."
            //STR0040 - "Solicite apoio dos responsáveis."
            Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0048, STR0040)
        Else
            //STR0039 - "Somente os usuários responsáveis pela etapa de "
            //STR0040 - "Solicite apoio dos responsáveis."
            //STR0047 - " podem realizar a impressão deste documento."
            Self:help("QDODocumentControl-" + cValToChar(ProcLine()), STR0039 + Self:retornaDescricaodoStatusdoDocumento(cDocumento, cRevisao) + STR0047, STR0040)
        EndIf
    Else
        lRetAux := ExecBlock( "QDOLPDFIMP", .F., .F., {cDocumento, cRevisao, cUsuario, cLogin, lImprime})
		If ValType(lRetAux) == "L"
			lImprime := lRetAux
		EndIf
    EndIf

    If lImprime
        oWebEngine:Print()
    EndIf

Return


/*/{Protheus.doc} montaTelaExibicaoPDFNoSmartClient
Monta Tela Para Exibição do PDF Embedded no SmartClient
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivoLocal, caracter, nome do arquivo PDF local para exibição em tela
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
@param 04 - cUsuario  , caracter, código do usuário do sistema relacionado
@return lMontou, lógico, indica se conseguiu montar a tela
/*/

METHOD montaTelaExibicaoPDFNoSmartClient(cArquivoLocal, cDocumento, cRevisao, cUsuario) CLASS QDODocumentControl
    Local bErrorBlock := ErrorBlock({|oError| QDODocumentControl():erroMontagemTela(oError:Description), Break(oError)})
    Local cLogin
    Local lMontou     := .T.
    Local nBuild

    Default cDocumento := QDH->QDH_DOCTO
    Default cRevisao   := QDH->QDH_RV
    Default cUsuario   := RetCodUsr()

    cLogin  := Upper(AllTrim(UsrRetName(cUsuario)))

    Begin Sequence

        nBuild  := Self:retornaBuild()

        oViewExec := FWViewExec():New()
        oViewExec:SetView(ViewDef(Self, cArquivoLocal, cDocumento, cRevisao, cUsuario))
        oViewExec:SetTitle(STR0041) //"Visualização de Documento"
        oViewExec:SetButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0042},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}) //"Fechar"
        oViewExec:SetCloseOnOk({|oViewPai| .T. })
        oViewExec:SetModal(.F.)
        oViewExec:OpenView(.F.)

	Recover
        lMontou := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

Return lMontou

/*/{Protheus.doc} ViewDef
Definição do View Para Criação de Tela MVC
@author brunno.costa
@since 07/12/2021
@param 01 - oSelf        , objeto  , instancia da classe QDODocumentControl
@param 02 - cArquivoLocal, caracter, nome do arquivo PDF local para exibição em tela
@param 03 - cDocumento, caracter, código do documento relacionado
@param 04 - cRevisao  , caracter, código da revisão do documento relacionada
@param 05 - cUsuario  , caracter, código do usuário do sistema relacionado
@return oView - View da Tela MVC
/*/
Static Function ViewDef(oSelf, cArquivoLocal, cDocumento, cRevisao, cUsuario)
	Local oModel := FWLoadModel("QDODocumentControl")
	Local oView  := FWFormView():New()
    Local oWebEngine

    //Seta modelo padrão na view
	oView:SetModel(oModel)

	//Adiciona a Other Object para Montagem da TWebEngine
	oView:AddOtherObject("VIEW_PDF", {|oPanel| oSelf:montaTelaOtherObject(oPanel, cArquivoLocal, cUsuario, @oWebEngine) })

	//Cria o BOX Tela Cheia e Vincula a Dialog de PDF ao Box
	oView:CreateHorizontalBox("BOX_TOTAL",100)
    oView:SetOwnerView("VIEW_PDF","BOX_TOTAL")

    If oSelf:lExibeBotaoImpressao
        oView:AddUserButton(STR0043, "", {|oView| oSelf:enviaImpressao(oWebEngine, cDocumento, cRevisao, cUsuario) } , , , , .T.) //"Imprimir"
    EndIf

Return oView

/*/{Protheus.doc} montaTelaOtherObject
Monta Tela MVC Referente Trecho Other Object - ADVPL Livre para usar TWebEngine
@author brunno.costa
@since  29/11/2021
@param 01 - oPanel       , objeto  , painel do OtherObject na View MVC
@param 02 - cArquivoLocal, caracter, nome do arquivo PDF local para exibição em tela
@param 03 - cUsuario     , caracter, código do usuário do sistema relacionado
@param 04 - oWebEngine   , objeto  , retorna por referência o objeto TWebEngine para permitir impressão no botão MVC
@return lMontou, lógico, indica se conseguiu montar a tela
/*/

METHOD montaTelaOtherObject(oPanel, cArquivoLocal, cUsuario, oWebEngine) CLASS QDODocumentControl
    Local bErrorBlock := ErrorBlock({|oError| QDODocumentControl():erroMontagemTela(oError:Description), Break(oError)})
    Local cLogin
    Local lMontou     := .T.
    Local nBuild
    Local oTIBrowser
    Local oWebChannel

    Default cUsuario   := RetCodUsr()

    cLogin  := Upper(AllTrim(UsrRetName(cUsuario)))

    Begin Sequence

        nBuild  := Self:retornaBuild()

        If ( nBuild >= 17 )
            oWebChannel := TWebChannel():New()
            nPort := oWebChannel::connect()
        
            oWebEngine := TWebEngine():New( oPanel, 0, 0, 395, 265,, nPort )
             If (Self:validaExecucaoViaWebApp())
                oWebEngine:navigate( GetTempPath(.T.) + cArquivoLocal + "#toolbar=0" ) //#toolbar=0 para remover toolbar com opção de impressão e download do browser
            Else
                oWebEngine:navigate( Self:cDirDocLocal + cArquivoLocal )
            EndIf

            oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

        Else
            oTIBrowser := TIBrowser():New( 0, 3, 615, 260, Self:cDirDocLocal + cArquivoLocal, oPanel )
            oTIBrowser:Align := CONTROL_ALIGN_ALLCLIENT
        EndIf
	
	Recover
        lMontou := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

Return lMontou

/*/{Protheus.doc} ModelDef
Definição do modelo da QDH Para Criação de Tela MVC (fake - não é usado - necessário para instanciar ViewDef)
@author brunno.costa
@since 07/12/2021
@return oModel - Modelo de dados da tabela QDH
/*/
Static Function ModelDef()
	Local oModel
	Local oStruct := FWFormStruct(1,"QDH",{|cCampo| "|"+AllTrim(cCampo)+"|" $ "|QDH_DOCTO|QDH_RV|"})
	oModel := MPFormModel():New("QDODocumentControl")
	oModel:AddFields("MASTER", , oStruct)
Return oModel

/*/{Protheus.doc} erroMontagemTela
Erro na Montagem de Tela
@author brunno.costa
@since  29/11/2021
@param 01 - cErro, caracter, erro durante a montagem do arquivo em tela
/*/
METHOD erroMontagemTela(cErro) CLASS QDODocumentControl
    //STR0044 - "Falha na exibição do documento"
    //STR0045 - "Entre em contato com o suporte da TOTVS informando este erro."
    Self:help(ProcName(2) + '-' + cValToChar(procLine(2)), STR0044 + ": " + AllTrim(cErro) + ".", STR0045)
Return 

/*/{Protheus.doc} retornaDescricaodoStatusdoDocumento
Retorna a descrição do status do documento.
@author rafael.kleestadt
@since 13/09/2022
@version 1.0
@param cDocumento, caracter, código do documento
@param cRevisao, caracter, revisão do documento
@return cDescricao, caracter, descrição do status do documento.
/*/
METHOD retornaDescricaodoStatusdoDocumento(cDocumento, cRevisao) CLASS QDODocumentControl
    Local cDescricao := ""

    Default cDocumento := QDH->QDH_DOCTO
    Default cRevisao   := QDH->QDH_RV
    
    cDescricao := SX5Desc('Q7', Self:retornaStatusdoDocumento(cDocumento, cRevisao))

Return cDescricao

/*/{Protheus.doc} retornaStatusdoDocumento
Retorna o status do documento.
@author rafael.kleestadt
@since 20/09/2022
@version 1.0
@param cDocumento, caracter, código do documento
@param cRevisao, caracter, revisão do documento
@return cStatus, caracter, status do documento.
/*/
METHOD retornaStatusdoDocumento(cDocumento, cRevisao) CLASS QDODocumentControl
    Local aAreaQDH := QDH->(GetArea())
    Local cStatus  := ""

    Default cDocumento := QDH->QDH_DOCTO
    Default cRevisao   := QDH->QDH_RV
    
    cStatus  := Posicione("QDH", 1, xFilial("QDH")+cDocumento+cRevisao, "QDH_STATUS")

    RestArea(aAreaQDH)

Return cStatus

