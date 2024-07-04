#INCLUDE "TOTVS.CH"
#INCLUDE "FwSchedule.ch"
#INCLUDE "QDOWizPDF.CH"

#DEFINE ENTER CHR(13) + CHR(10)

#DEFINE MB_ICONEXCLAMATION 48
#DEFINE nMV_QDOMSOD        1
#DEFINE nMV_QDOLOD         2

//Colunas Grid de Filiais
#DEFINE nMarcado           1
#DEFINE nGrupoDeEmpresa    2
#DEFINE nFilialComposta    3
#DEFINE nDescricaoFilial   4

//Colunas Grid de Processamento
#DEFINE nColunaLegenda     1
#DEFINE nColunaProcesso    2
#DEFINE nColunaStatus      3

//Controle de Fontes dos Textos
#DEFINE oFont11    TFont():New("Arial", , -11, , .F.) //Cabeçalho página de processamento
#DEFINE oFont12    TFont():New("Arial", , -12, , .F.) //Objetos GET
#DEFINE oFont12B   TFont():New("Arial", , -12, , .T.) //Títulos objetos GET
#DEFINE oFont13    TFont():New("Arial", , -13, , .F.) //Cabeçalho página de processamento
#DEFINE oFont13B   TFont():New("Arial", , -13, , .T.) //Cabeçalho página de processamento
#DEFINE oFont14    TFont():New("Arial", , -14, , .F.) //Textos diversos explicações

//Bitmaps do Markbox
#DEFINE oBmpLBNO   LoadBitmap(GetResources(), "LBNO")
#DEFINE oBmpLBTIK  LoadBitmap(GetResources(), "LBTIK")

//Legendas da grid de processamento
#DEFINE oBmpLegAM  LoadBitmap(GetResources(), 'BR_AMARELO' )
#DEFINE oBmpLegAtu LoadBitmap(GetResources(), 'REFRESH' )
#DEFINE oBmpLegLA  LoadBitmap(GetResources(), 'BR_LARANJA' )
#DEFINE oBmpLegNO  LoadBitmap(GetResources(), 'BR_VERMELHO' )
#DEFINE oBmpLegOK  LoadBitmap(GetResources(), 'BR_VERDE' )

//Controla início e fim da execução em TTimer
Static slIniciou  := .F.
Static slConcluiu := .F.

/*/{Protheus.doc} QDOWizPDF
Wizard de Diagnóstico e Implantação Leitura em PDF no SIGAQDO
@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33
/*/
Main Function QDOWizPDF()
    Local  oMainClass := QDOWizPDFDialogClass():New()
    oMainClass:MontaMainWnd()
Return

/*/{Protheus.doc} QDOWizPDFClass
Regras de Negocio - Wizard de Implantação Leitura PDF no SmartClient
@Type Class
@author brunno.costa
@since 31/03/2022
/*/
CLASS QDOWizPDFClass FROM LongNameClass

    DATA aDiretorios                   as ARRAY
    DATA aEmpresas                     as ARRAY
    DATA aProcesso                     as ARRAY
    DATA cSenha                        as STRING
    DATA cUsuario                      as STRING
    DATA nEmpresaMarcada               as NUMERIC
    DATA oQDODocumentControl           as OBJECT
    DATA oTimerExecucao                as OBJECT
    DATA oTimerStatus                  as OBJECT
    
    DATA nPosicaoArquivoAtual          as NUMERIC
    DATA nPosicaoDicionario            as NUMERIC
    DATA nPosicaoIdentificandoArquivos as NUMERIC
    DATA nPosicaoMensagens             as NUMERIC
    DATA nPosicaoProcessando           as NUMERIC
    DATA nPosicaoServerLibreOffice     as NUMERIC
    DATA nPosicaoServerMSOffice        as NUMERIC
    DATA nPosicaoSX6                   as NUMERIC
    DATA nPosicaoUpdateQAA             as NUMERIC
	
    METHOD new(cUsuario, cSenha, aEmpresas, nEmpresaMarcada) CONSTRUCTOR

    //METODOS MONTAGEM DO WIZARD
    METHOD MontaWizard(oDlg)
    METHOD Etapa1(oPanel)           //Tela de Boas Vindas
    METHOD Etapa2(oPanel, aSM0)     //Tela de Login x Filial
    METHOD Etapa3(oPanel)           //Tela de Parâmetros
    METHOD Etapa4(oPanel, oStepWiz) //Grid com Status de Processamento
    METHOD AtualizaStatusProcessamento(oBrwWiz, cChave)

    //METODO EXECUCAO IMPLANTACAO
    METHOD ExecutaImplantacao()

    //DEMAIS METODOS AUXILIARES
    METHOD AbreAmbiente(cCompany, cBranch)
    METHOD CarregaEmpresas(aSM0)
    METHOD ChecaAcessoUsuarioAsEmpresasMarcadas()
    METHOD MarcaFilial(oList)
    METHOD RetornaDiretoriosDeAcesso()
    METHOD SalvaDiretoriosConversores()
    METHOD SalvaX6(aSX6)
    METHOD UpdateTipoExibicaoUsuarios()
    METHOD ValidaFechamento()
    METHOD ValidaSelecaoEmpresa()
    METHOD ValidaUsuario()

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author brunno.costa
@since 31/03/2022

@param 01 - cUsuario        , caracter, usuário digitado pelo usuário na Etapa2
@param 02 - cSenha          , caracter, senha digitada pelo usuário na Etapa2
@param 03 - aEmpresas       , array   , array Self:aEmpresas gerado anteriormente no Self:CarregaEmpresas()
@param 04 - nEmpresaMarcada , número  , número identificador da empresa selecionada para implantação
@return Self, objeto, instancia da Classe QDOWizPDFClass
/*/
METHOD new(cUsuario, cSenha, aEmpresas, nEmpresaMarcada) CLASS QDOWizPDFClass
    Default cUsuario          := Space(35)
    Default cSenha            := Space(35)
    Default aEmpresas         := {}
    Default nEmpresaMarcada   := 0

    Self:aDiretorios          := Array(2)
    Self:aEmpresas            := aEmpresas
    Self:aProcesso            := {}
    Self:cSenha               := cSenha
    Self:cUsuario             := cUsuario
    Self:nEmpresaMarcada      := nEmpresaMarcada

Return Self

/*/{Protheus.doc} MontaWizard
Monta Estrutura do Wizard de Implantação

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33
@param 01 - oDlg, objeto, dialog para montagem da FwWizardControl
/*/
METHOD MontaWizard(oDlg) CLASS QDOWizPDFClass
    Local aSM0        := {}
    Local lRet        := .T.
    Local oNewPag     := Nil
    Static oStepWiz   := Nil

    oStepWiz:= FWWizardControl():New(oDlg, { 530, 720 })
    oStepWiz:ActiveUISteps()
    
    // Pagina 1 - Boas Vindas
    oNewPag := oStepWiz:AddStep()
    oNewPag:SetStepDescription(STR0002) //"Boas Vindas"
    oNewPag:SetConstruction({ |oPanel| Self:Etapa1(oPanel) })
    oNewPag:SetNextAction({|| .T.})
    
     // Pagina 2 - Autenticação e Seleção de Filiais
    oNewPag := oStepWiz:AddStep()
    oNewPag:SetStepDescription(STR0003) //"Autenticação"
    oNewPag:SetConstruction({|oPanel| Self:Etapa2(oPanel, @aSM0) })
    oNewPag:SetNextAction({|| FWMsgRun(/*oComponent*/,{ || lRet := Self:ValidaUsuario() }, Nil, STR0004), lRet }) //"Validando os acessos do administrador"

    // Pagina 3 - Diretórios Conversores
    oNewPag := oStepWiz:AddStep()
    oNewPag:SetStepDescription(STR0005) //"Diretórios Conversores"
    oNewPag:SetConstruction({|oPanel| oPanelAux := oPanel, FWMsgRun(/*oComponent*/,{ || Self:Etapa3(oPanelAux) }, Nil, STR0006) }) //"Carregando parâmetros de configuração dos conversores"
    oNewPag:SetNextAction({|| Self:SalvaDiretoriosConversores()})
    
    // Pagina 4 - Implantação
    oNewPag := oStepWiz:AddStep()
    oNewPag:SetStepDescription(STR0007) //"Implantação"
    oNewPag:SetConstruction({|oPanel| Self:Etapa4(oPanel, @oStepWiz) })
    oNewPag:SetCancelWhen({|| .F. })
    oNewPag:SetNextAction({|| Self:validaFechamento() })
    oStepWiz:Activate()

Return

/*/{Protheus.doc} Etapa1
Monta Etapa 1 do Wizard - Boas Vindas

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33

@param 01 - oPanel, objeto, painel para exibição da etapa
/*/
METHOD Etapa1(oPanel) CLASS QDOWizPDFClass

    Local cWelcome1 := STR0008 //"Bem vindo(a)!"
    Local cWelcome2 := STR0009 //"Este é o wizard de diagnóstico e implantação TOTVS para leitura de documentos do SIGAQDO em PDF no SmartClient."
    
    //STR0010 - "Ao executar o processo a seguir, será registrada a remoção de senha para os arquivos do SIGAQDO na filial selecionada durante a Etapa 2 através do parametro MV_QDOCPDF."
	//STR0011 - "Na Etapa 3 serão atualizados os parâmetros utilizados no processo: MV_QDOMSOD e MV_QDOLOD."                                                                                                                                                                                                                                                                                                                                                                                                                        
    Local cWelcome3 := STR0010 + " " + STR0011
    Local cWelcome4 := STR0082 //"Ao concluir a atualização, o campo Tipo Exibição (QAA_TPWORD) será atualizado em todos os usuários para '4=Interna no ERP'."
    Local cWelcome5 := STR0012 //"Será realizada validação dos locais de instalação do MS Office¹ ou LibreOffice¹ no servidor de Aplicação do ERP conforme parametrização da Etapa 3. (MS Office¹ ou LibreOffice¹: conversores .CEL em .PDF)"
    Local cWelcome6 := STR0013 //"O sistema também realizará a remoção de senha de todos os documentos armazenados com senha no diretório correspondente do SIGAQDO no servidor de Aplicação do ERP como requisito do processo de conversão para PDF."
    Local cWelcome7 := STR0014 //"Para continuar pressione o botão 'Avançar' ou 'Cancelar' para abortar o processo."

    TSay():New(10 , 15, {|| cWelcome1 }, oPanel, , oFont14, , , , .T., , , 330, 20)
    TSay():New(25 , 15, {|| cWelcome2 }, oPanel, , oFont14, , , , .T., , , 330, 20)
    TSay():New(45 , 15, {|| cWelcome3 }, oPanel, , oFont14, , , , .T., , , 330, 30)
    TSay():New(75 , 15, {|| cWelcome4 }, oPanel, , oFont14, , , , .T., , , 330, 20)
    TSay():New(95 , 15, {|| cWelcome5 }, oPanel, , oFont14, , , , .T., , , 330, 20)
    TSay():New(115, 15, {|| cWelcome6 }, oPanel, , oFont14, , , , .T., , , 330, 25)
    TSay():New(145, 15, {|| cWelcome7 }, oPanel, , oFont14, , , , .T., , , 330, 20)
   
 Return

/*/{Protheus.doc} Etapa2
Monta Etapa 2 do Wizard - Validando de Acesso e Seleção de Filiais

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33

@param 01 - oPanel  , objeto  , painel para exibição da etapa
@param 02 - aSM0    , array   , retorna por referência array da FWLoadSM0() - https://tdn.totvs.com/display/framework/FWLoadSM0
/*/
METHOD Etapa2(oPanel, aSM0) CLASS QDOWizPDFClass

    Local oList   := Nil
    Local oTGet1  := Nil
    Local oTGet2  := Nil

    Self:CarregaEmpresas(@aSM0)

    @ 5, 5 GROUP TO 40, 195 PROMPT STR0015 OF oPanel PIXEL //"Validação de Acesso"

        @ 14, 10 SAY  STR0016 OF oPanel PIXEL FONT oFont12B //"Usuário Administrador:"
        @ 24, 10 MSGET oTGet1 VAR Self:cUsuario SIZE 80, 10 OF oPanel Font oFont12 PIXEL 

        @ 14, 100 SAY STR0017 OF oPanel PIXEL FONT oFont12B //"Senha:"
        @ 24, 100 MSGET oTGet2 VAR Self:cSenha SIZE 80, 10 OF oPanel Font oFont12 PIXEL PASSWORD

    // Monta a lista de empresas. 
    @ 40, 5 GROUP TO 170, 195 PROMPT STR0018 OF oPanel PIXEL //"Filiais para Implantação"
        @ 50, 10 LISTBOX oList;
            FIELDS HEADER "", STR0019, STR0020, STR0021 SIZE 180, 115 OF oPanel PIXEL; //"Grupo Emp", "Filial", "Descrição"
            ON DBLCLICK Self:MarcaFilial(oList)
            oList:SetArray(Self:aEmpresas)
            oList:bLine := {|| { ;
                If(Self:aEmpresas[oList:nAt, nMarcado], oBmpLBTIK, oBmpLBNO),;
                   Self:aEmpresas[oList:nAt, nGrupoDeEmpresa],;
                   Self:aEmpresas[oList:nAt, nFilialComposta],;
                   Self:aEmpresas[oList:nAt, nDescricaoFilial] }}
            oList:Refresh()

    // Montando Explicação Filiais
    @ 5, 200 GROUP TO 170, 360 PROMPT STR0022 COLOR CLR_RED OF oPanel PIXEL //"ATENÇÃO"
        @ 15, 205 SAY STR0023 + ENTER + ENTER; //"Selecione a filial que iniciará uso da solução a partir de agora. As demais filiais devem ser configuradas somente no momento em que a solução passar a ser utilizada."
                    + STR0024 + ENTER + ENTER; //"IMPORTANTE: o processo de implantação deve ser executado em computador com o MS Office Instalado localmente para que o Protheus consiga utilizar a integração nativa com o MS Office para a remoção de senhas dos arquivos armazenados no Servidor de Aplicação."
                      SIZE 150, 205 OF oPanel PIXEL FONT oFont14

    oTGet1:SetFocus()
   
Return

/*/{Protheus.doc} Etapa3
Monta Etapa 3 do Wizard - Seleção de Parâmetros de Acesso a Plataforma

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33

@param 01 - oPanel   , objeto  , painel para exibição da etapa
/*/
METHOD Etapa3(oPanel) CLASS QDOWizPDFClass

    Local oDirMSOffi := Nil
    Local oDirLibreO := Nil

    Self:aDiretorios := Self:RetornaDiretoriosDeAcesso()
    
    @ 5, 5 GROUP TO 170, 360 PROMPT STR0025 OF oPanel PIXEL //"Diretórios de Instalação dos Conversores no Servidor de Aplicação do Protheus: "

        @ 25, 15 SAY STR0026 + ENTER + ENTER; //"Informe o diretório de instalação de pelo menos um dos conversores disponibilizados no Servidor de Aplicação do ERP:"
            SIZE 340, 20 OF oPanel PIXEL FONT oFont12

        If IsSrvUnix()
            @ 45, 15 SAY STR0084 OF oPanel PIXEL FONT oFont12B //"Conversor¹ LibreOffice (/usr/lib64/libreoffice/program/swriter):"
            @ 55, 15 MSGET oDirLibreO VAR Self:aDiretorios[nMV_QDOLOD] SIZE 180, 10 OF oPanel Font oFont12 PIXEL
        Else
            @ 45, 15 SAY STR0027 OF oPanel PIXEL FONT oFont12B //"Conversor¹ MS Office (...\winword.exe):"
            @ 55, 15 MSGET oDirMSOffi VAR Self:aDiretorios[nMV_QDOMSOD] SIZE 180, 10 OF oPanel Font oFont12 PIXEL

            @ 80, 15 SAY STR0028 OF oPanel PIXEL FONT oFont12B //"Conversor¹ LibreOffice (...\swriter.exe):"
            @ 90, 15 MSGET oDirLibreO VAR Self:aDiretorios[nMV_QDOLOD] SIZE 180, 10 OF oPanel Font oFont12 PIXEL
        EndIf

        @ 110, 15 SAY STR0029 + ENTER + ENTER; //"Conversor¹: software utilizado no Servidor de Aplicação pelo ERP para conversão dos arquivos .CEL em .PDF e posterior disponibilização para leitura dos documentos no SmartClient em estações de trabalho."
            SIZE 340, 20 OF oPanel PIXEL FONT oFont12 
 Return

/*/{Protheus.doc} Etapa4
Monta Etapa 4 do Wizard - Acompanhamento e Execução

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33

@param 01 - oPanel  , objeto, painel para exibição da etapa
@param 02 - oStepWiz, objeto, instancia da FwWizardControl utilizada no processo
/*/

METHOD Etapa4(oPanel, oStepWiz) CLASS QDOWizPDFClass
    
    Local cChave         := cEmpAnt + cFilAnt
	Local nLinha         := 0
	Local nMilissegundos := 100
	Local oBrwWiz        := Nil
    Local oDesc          := Nil
    Local oNumTicket     := Nil
    Local oTitulo        := Nil

    //Desabilita tecla ESC
	oPanel:oWnd:lEscClose := .F.

    //Oculta o botão "Voltar" da tela de processamento
	oStepWiz:oUiStepWizard:SetPrevVisibility(.F.)

    //Texto do cabeçalho
    oTitulo    := TSay():New(05,  10, {|| STR0030 }, oPanel, , oFont13B, , , , .T., , , 290, 20) //"Executando diagnóstico e implantação... aguarde."
    oDesc      := TSay():New(15,  10, {|| STR0031 }, oPanel, , oFont11 , , , , .T., , , 290, 20) //"Acompanhe o status de cada uma das etapas da execução:"
    oNumTicket := TSay():New(05, 250, {|| STR0032 }, oPanel, , oFont13 , , , , .T., , , 100, 20) //"Leitura em PDF no SmartClient Gestão de Documentos"
    oNumTicket:SetTextAlign(1, 0)
    
    nLinha++
    Self:nPosicaoDicionario            := nLinha
    aAdd(Self:aProcesso, {oBmpLegAtu, STR0033, STR0042}) //"Validando Dicionário Campo QAA_TPWORD" - "Pendente"

    nLinha++
    Self:nPosicaoSX6                   := nLinha
    aAdd(Self:aProcesso, {oBmpLegAtu, STR0034, STR0042}) //"Validando Dicionário Parâmetros" - "Pendente"

    nLinha++
    Self:nPosicaoServerMSOffice        := nLinha
    aAdd(Self:aProcesso, {oBmpLegAM   , STR0035, STR0042}) //"Validando Instalação Conversor MS Office" - "Pendente"

    nLinha++
    Self:nPosicaoServerLibreOffice     := nLinha
    aAdd(Self:aProcesso, {oBmpLegAM   , STR0036, STR0042}) //"Validando Instalação Conversor LibreOffice" - "Pendente"

    nLinha++
    Self:nPosicaoIdentificandoArquivos := nLinha
    aAdd(Self:aProcesso, {oBmpLegAtu, STR0037, STR0042}) //"Identificando Arquivos" - "Pendente"

    nLinha++
    Self:nPosicaoUpdateQAA := nLinha
    aAdd(Self:aProcesso, {oBmpLegAM, STR0083, STR0042}) //"Atualização Tipo Exibição (QAA_TPWORD) de Usuários para '4=Interna no ERP'"

    nLinha++
    Self:nPosicaoProcessando           := nLinha
    aAdd(Self:aProcesso, {oBmpLegAM   , STR0038, STR0042}) //"Processando a Remoção de Senha" - "Pendente"

    nLinha++
    Self:nPosicaoArquivoAtual          := nLinha
    aAdd(Self:aProcesso, {oBmpLegAM   , "-> " + STR0039 + ":", STR0042}) //"Arquivo Atual" - "Pendente"

    oBrwWiz := TSBrowse():New(30, 10, 344, 140, oPanel, , 16, , 1)
    oBrwWiz:AddColumn( TCColumn():New(''     ,,,{|| },{|| },,20 , .T.) )
    oBrwWiz:AddColumn( TCColumn():New(STR0040,,,{|| },{|| },,200, .F.) ) //"Processo"
    oBrwWiz:AddColumn( TCColumn():New(STR0041,,,{|| },{|| },,50 , .F.) ) //"Status"
    oBrwWiz:SetArray(Self:aProcesso)

    //Limpa variáveis de controle globais
    PutGlbValue( "QDODocumentControl_nPosicaoDicionario"       + cChave, "" )
    PutGlbValue( "QDODocumentControl_nPosicaoSX6"              + cChave, "" )
    PutGlbValue( "QDODocumentControl_nPosicaoServerMSOffice"   + cChave, "" )
    PutGlbValue( "QDODocumentControl_nPosicaoServerLibreOffice"+ cChave, "" )
    PutGlbValue( "QDODocumentControl_nPosicaoProcessando"      + cChave, "" )
    PutGlbValue( "QDODocumentControl_nRegistros_"              + cChave, "" )
    PutGlbValue( "QDODocumentControl_nAtual_"                  + cChave, "" )
    PutGlbValue( "QDODocumentControl_cAtual_"                  + cChave, "" )
    
    //Cria Thread no SmartClient via Timer para atualização de Status Fora do Fluxo de Construção Inicial da Tela
    Self:oTimerStatus := TTimer():New(nMilissegundos, {|| Self:AtualizaStatusProcessamento(oBrwWiz, cChave) }, oPanel:oWnd )
    Self:oTimerStatus:Activate()

    //Cria Thread no SmartClient via Timer Execução do processamento Fora do Fluxo de Construção Inicial da Tela
    Self:oTimerExecucao := TTimer():New(nMilissegundos, {|| Iif(!slIniciou, (slIniciou := .T., Self:ExecutaImplantacao()), ) }, oPanel:oWnd )
    Self:oTimerExecucao:Activate()

 Return

/*/{Protheus.doc} AtualizaStatusProcessamento
Atualiza Status do Processamento (Dados da GRID - Etapa 4)

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33

@param 01 - oBrwWiz , objeto  , instancia da grid utilizada para exibição dos dados de processamento
@param 02 - cChave  , caracter, cEmpAnt+cFilAnt
/*/
METHOD AtualizaStatusProcessamento(oBrwWiz, cChave) CLASS QDOWizPDFClass

    Local aRetAux     := {}
    Local cArquivo    := ""
    Local cAtual      := ""
    Local cEmExecucao := ""
    Local cPercentual := ""
    Local cRegistros  := ""
    Local cRetAux     := ""
    Local lEncerra    := .T.
    Local lForcaSaida := .F.
    Local nInd        := 0
    Local nTotal      := 0

    cRetAux := GetGlbValue( "QDODocumentControl_nPosicaoProcessando"+cChave)
    If cRetAux != Nil .AND. !Empty(cRetAux)
        Self:aProcesso[Self:nPosicaoProcessando][nColunaStatus]            := cRetAux
        If AllTrim(cRetAux) == AllTrim(STR0047)                                       //"Iniciado"
            Self:aProcesso[Self:nPosicaoProcessando][nColunaLegenda]       := oBmpLegAtu
        ElseIf AllTrim(cRetAux) == AllTrim(STR0044)                                   //"Concluído"
            lForcaSaida := .T.
            Self:aProcesso[Self:nPosicaoUpdateQAA][nColunaLegenda]         := oBmpLegOK
            Self:aProcesso[Self:nPosicaoUpdateQAA][nColunaStatus]          := STR0044 //"Concluído"
            Self:aProcesso[Self:nPosicaoProcessando][nColunaLegenda]       := oBmpLegOK
            Self:aProcesso[Self:nPosicaoProcessando][nColunaStatus]        := STR0044 //"Concluído"
            Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaLegenda]      := oBmpLegOK
            Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaProcesso]     := STR0045 //"Processamento Finalizado"
            Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaStatus]       := STR0044 //"Concluído"
        ElseIf AllTrim(cRetAux) == AllTrim(STR0048)                                   //"Erro"
            lForcaSaida := .T.
            Self:aProcesso[Self:nPosicaoProcessando][nColunaLegenda]       := oBmpLegNO
            Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaLegenda]      := oBmpLegNO
            Self:aProcesso[Self:nPosicaoUpdateQAA][nColunaLegenda]         := oBmpLegNO
            Self:aProcesso[Self:nPosicaoUpdateQAA][nColunaStatus]          := STR0048 //"Erro"
            Self:aProcesso[Self:nPosicaoProcessando][nColunaStatus]        := STR0048 //"Erro"
            Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaStatus]       := STR0048 //"Erro"
            Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaProcesso]     := STR0066 //"Processamento Finalizado com Erro"
        ElseIf AllTrim(cRetAux) == AllTrim(STR0049)                                   //"Cancelado"
            lForcaSaida := .T.
            Self:aProcesso[Self:nPosicaoServerMSOffice][nColunaLegenda]    := oBmpLegNO
            Self:aProcesso[Self:nPosicaoServerLibreOffice][nColunaLegenda] := oBmpLegNO
            Self:aProcesso[Self:nPosicaoProcessando][nColunaLegenda]       := oBmpLegNO
            Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaLegenda]      := oBmpLegNO
            Self:aProcesso[Self:nPosicaoUpdateQAA][nColunaLegenda]         := oBmpLegNO
            Self:aProcesso[Self:nPosicaoUpdateQAA][nColunaStatus]          := STR0049 //"Cancelado"
            Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaStatus]       := STR0049 //"Cancelado"
            Self:aProcesso[Self:nPosicaoProcessando][nColunaStatus]        := STR0049 //"Cancelado"
            Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaProcesso]     := STR0067 //"Processamento Cancelado"
        EndIf
    Else
        lEncerra := .F.
    EndIf
    
    cRegistros := GetGlbValue( "QDODocumentControl_nRegistros_"+cChave )
    If !Empty(cRegistros) .AND. AllTrim(cRegistros) != ""
        If At(":", Self:aProcesso[Self:nPosicaoIdentificandoArquivos][nColunaProcesso]) <= 0
            //STR0037 - "Identificando Arquivos"
            //STR0043 - "documentos"
            Self:aProcesso[Self:nPosicaoIdentificandoArquivos][nColunaProcesso] := STR0037 + ": " + AllTrim(cRegistros) + " " + STR0043
            Self:aProcesso[Self:nPosicaoIdentificandoArquivos][nColunaStatus]   := STR0044 //"Concluído"
            Self:aProcesso[Self:nPosicaoIdentificandoArquivos][nColunaLegenda]  := oBmpLegOK
        ElseIf !lForcaSaida
            lEncerra := .F.
        EndIf
        
        cAtual := GetGlbValue( "QDODocumentControl_nAtual_"+cChave )
        If !Empty(cAtual) .AND. AllTrim(cAtual) != ""
            cPercentual := AlLTrim(Str(Round(Val(cAtual) / Val(cRegistros) * 100, 2))) + '%'
            Self:aProcesso[Self:nPosicaoProcessando][nColunaStatus]  := cPercentual
            Self:aProcesso[Self:nPosicaoProcessando][nColunaLegenda] := IIf(Val(cAtual) == Val(cRegistros), oBmpLegOK, Self:aProcesso[Self:nPosicaoProcessando][nColunaLegenda])
        ElseIf !lForcaSaida
            lEncerra := .F.
        EndIf   

        If !lForcaSaida
            cArquivo := GetGlbValue( "QDODocumentControl_cArquivo_"+cChave )
            If !Empty(cArquivo) .AND. Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaStatus] != STR0044 //"Concluído"
                Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaProcesso] := "-> " + STR0039 + ": " + AllTrim(cArquivo) //"Arquivo Atual"
                Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaStatus]   := STR0046 //"Processando"
            ElseIf !lForcaSaida
                lEncerra := .F.
            EndIf
        EndIf
    ElseIf lForcaSaida
        Self:aProcesso[Self:nPosicaoIdentificandoArquivos][nColunaStatus]   := STR0049 //"Cancelado"
        Self:aProcesso[Self:nPosicaoIdentificandoArquivos][nColunaLegenda]  := oBmpLegNO
        Self:aProcesso[Self:nPosicaoProcessando][nColunaStatus]             := STR0049 //"Cancelado"
        Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaStatus]            := STR0049 //"Cancelado"
    ElseIf !lForcaSaida
        lEncerra := .F.
    EndIf

    cRetAux := GetGlbValue( "QDODocumentControl_nPosicaoServerLibreOffice"+cChave)
    If cRetAux != Nil .AND. !Empty(cRetAux)
        Self:aProcesso[Self:nPosicaoServerLibreOffice][nColunaStatus]  := cRetAux
        If IsSrvUnix()
            Self:aProcesso[Self:nPosicaoServerLibreOffice][nColunaLegenda] := oBmpLegAM
        ElseIf AllTrim(cRetAux) == AllTrim(STR0050)                                       //"Encontrado"
            Self:aProcesso[Self:nPosicaoServerLibreOffice][nColunaLegenda] := oBmpLegOK
        Else
            Self:aProcesso[Self:nPosicaoServerLibreOffice][nColunaLegenda] := oBmpLegAM
        EndIf
    ElseIf !lForcaSaida
        lEncerra := .F.
    EndIf

    cRetAux := GetGlbValue( "QDODocumentControl_nPosicaoServerMSOffice"+cChave)
    If cRetAux != Nil .AND. !Empty(cRetAux)
        Self:aProcesso[Self:nPosicaoServerMSOffice][nColunaStatus]  := cRetAux
        If AllTrim(cRetAux) == AllTrim(STR0050)                                       //"Encontrado"
            Self:aProcesso[Self:nPosicaoServerMSOffice][nColunaLegenda] := oBmpLegOK
        Else
            Self:aProcesso[Self:nPosicaoServerMSOffice][nColunaLegenda] := oBmpLegAM
        EndIf
    ElseIf !lForcaSaida
        lEncerra := .F.
    EndIf

    cRetAux := GetGlbValue( "QDODocumentControl_nPosicaoSX6"+cChave)
    If cRetAux != Nil .AND. !Empty(cRetAux)
        Self:aProcesso[Self:nPosicaoSX6][nColunaStatus]  := cRetAux
        If AllTrim(cRetAux) == AllTrim(STR0051)                                       //"Válido"
            Self:aProcesso[Self:nPosicaoSX6][nColunaLegenda] := oBmpLegOK
        Else
            Self:aProcesso[Self:nPosicaoSX6][nColunaLegenda] := oBmpLegNO
        EndIf
    ElseIf !lForcaSaida
        lEncerra := .F.
    EndIf

    cRetAux := GetGlbValue( "QDODocumentControl_nPosicaoDicionario"+cChave)
    If cRetAux != Nil .AND. !Empty(cRetAux)
        Self:aProcesso[Self:nPosicaoDicionario][nColunaStatus]  := cRetAux
        If AllTrim(cRetAux) == AllTrim(STR0051)                                       //"Válido"
            Self:aProcesso[Self:nPosicaoDicionario][nColunaLegenda] := oBmpLegOK
        Else
            Self:aProcesso[Self:nPosicaoDicionario][nColunaLegenda] := oBmpLegNO
            aAdd(Self:aProcesso, {oBmpLegAM, "-> " + STR0073, STR0022 }) //"Inclua a opção '4=Interna no ERP' no combobox do campo 'QAA_TPWORD'." - "ATENÇÃO"
            aAdd(Self:aProcesso, {oBmpLegAM, "-> " + STR0074, STR0022 }) //"Renomeio o título do campo 'QAA_TPWORD' para 'Tipo Exib.'." - "ATENÇÃO"
        EndIf
    ElseIf !lForcaSaida
        lEncerra := .F.
    EndIf

    //STR0053 - Não Encontrado
    If       STR0053 == Self:aProcesso[Self:nPosicaoServerLibreOffice][nColunaStatus];
       .AND. STR0053 == Self:aProcesso[Self:nPosicaoServerMSOffice   ][nColunaStatus];
       .AND. !IsSrvUnix()
        aAdd(Self:aProcesso, {oBmpLegAM, "-> " + STR0077, STR0022 }) //"Instale no servidor e configure o diretório de ao menos um conversor." - "ATENÇÃO"
    EndIf

    VarBeginT("QDODocumentControl", "aArquivosErros")
        If VarGetXA("QDODocumentControl", @aRetAux)
            nTotal := Len(aRetAux)
            For nInd := 1 to nTotal
                If "cEmExecucao" == AllTrim(aRetAux[nInd][1])
                    cEmExecucao := aRetAux[nInd][2]
                ElseIf ValType(aRetAux[nInd]) == "A" .AND. !Empty(aRetAux[nInd][1])
                    aAdd(Self:aProcesso, {oBmpLegAM, "-> " + STR0065 +": " + aRetAux[nInd][1] + aRetAux[nInd][2], STR0022 }) //"Falha na Conversão do Arquivo" - "ATENÇÃO"
                EndIf
            Next nInd
            If nTotal > 1
                VarCleanX("QDODocumentControl")
                VarSetX("QDODocumentControl", "cEmExecucao", cEmExecucao)
            EndIf
        EndIf
    VarEndT("QDODocumentControl", "aArquivosErros")

    oBrwWiz:SetArray(Self:aProcesso)
    oBrwWiz:Refresh()

    If !lForcaSaida .AND. Empty(cAtual) .OR. AllTrim(cAtual) != AllTrim(cRegistros)
        lEncerra := .F.
    EndIf

    If lEncerra
        Self:oTimerStatus:DeActivate()
        Self:oTimerExecucao:DeActivate()
        slConcluiu := .T.
    ElseIf lForcaSaida
        slConcluiu := .T.
    EndIf

Return

/*/{Protheus.doc} ExecutaImplantacao
Executa os Procedimentos de Implantação

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33
/*/
METHOD ExecutaImplantacao() CLASS QDOWizPDFClass
    
    Local cChave       := ""
    Local lLibreOffice := .F.
    Local lMSOffice    := .F.
    Local lProcValid   := .T.
    Local lServerLinux := IsSrvUnix()

    Self:AbreAmbiente(Self:aEmpresas[Self:nEmpresaMarcada][nGrupoDeEmpresa], Self:aEmpresas[Self:nEmpresaMarcada][nFilialComposta])
    cChave := cEmpAnt+cFilAnt
    
    Self:oQDODocumentControl := QDODocumentControl():New()
    If Self:oQDODocumentControl:validaDicionario()
        PutGlbValue( "QDODocumentControl_nPosicaoDicionario"        + cChave, STR0051 ) //"Válido"
    Else
        PutGlbValue( "QDODocumentControl_nPosicaoDicionario"        + cChave, STR0052 ) //"Inválido"
        lProcValid := .F.
    EndIf

    If Self:oQDODocumentControl:validaExistenciaDosParametrosSX6()
        PutGlbValue( "QDODocumentControl_nPosicaoSX6"               + cChave, STR0051 ) //"Válido"
    Else
        lProcValid := .F.
        PutGlbValue( "QDODocumentControl_nPosicaoSX6"               + cChave, STR0052 ) //"Inválido"
    EndIf

    If lServerLinux
        lLibreOffice := .T.
        PutGlbValue( "QDODocumentControl_nPosicaoServerMSOffice"    + cChave, STR0085 ) //"Não avaliado em Server Linux"
    ElseIf Self:oQDODocumentControl:existeMSOffice(.F.)
        lMSOffice := .T.
        PutGlbValue( "QDODocumentControl_nPosicaoServerMSOffice"    + cChave, STR0050 ) //"Encontrado"
    Else
        lMSOffice := .F.
        PutGlbValue( "QDODocumentControl_nPosicaoServerMSOffice"    + cChave, STR0053 ) //"Não Encontrado"
    EndIf

    If lServerLinux
        lLibreOffice := .T.
        PutGlbValue( "QDODocumentControl_nPosicaoServerLibreOffice" + cChave, STR0085 ) //"Não avaliado em Server Linux"
    ElseIf Self:oQDODocumentControl:existeLibreOffice(.F.)
        lLibreOffice := .T.
        PutGlbValue( "QDODocumentControl_nPosicaoServerLibreOffice" + cChave, STR0050 ) //"Encontrado"
    Else
        lLibreOffice := .F.
        PutGlbValue( "QDODocumentControl_nPosicaoServerLibreOffice" + cChave, STR0053 ) //"Não Encontrado"
    EndIf

    If lProcValid
        lProcValid := lMSOffice .OR. lLibreOffice
    EndIf

    If lProcValid
        PutGlbValue( "QDODocumentControl_nPosicaoProcessando"       + cChave, STR0047 ) //"Iniciado"
        If Self:oQDODocumentControl:removeSenhaDocumentosServidor()
            If Self:UpdateTipoExibicaoUsuarios()
                PutGlbValue( "QDODocumentControl_nPosicaoProcessando"   + cChave, STR0044 ) //"Concluído"
            Else
                PutGlbValue( "QDODocumentControl_nPosicaoProcessando"       + cChave, STR0048 ) //"Erro"
            EndIf
        Else
            PutGlbValue( "QDODocumentControl_nPosicaoProcessando"   + cChave, STR0049 ) //"Cancelado"
        EndIf
    Else
        PutGlbValue( "QDODocumentControl_nPosicaoProcessando"       + cChave, STR0048 ) //"Erro"
    EndIf

    //Finaliza Thread de Execução Ao Término da Primeira Chamada
    Self:oTimerExecucao:DeActivate()
Return

/*/{Protheus.doc} ValidaUsuario
Controla Validação de Usuário e Mensagens

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33

@return lValid, lógico, indica se o usuário é válido para todas as empresas marcadas
/*/
METHOD ValidaUsuario() CLASS QDOWizPDFClass
    Local aReturn      := {}
    Local bErrorBlock  := Nil
    Local cExecCompany := ""
    Local cMsg         := ""
    Local cNoCompany   := ""
    Local lValid       := .F.
    Local nVldLogin    := Nil

    If Empty(Self:cUsuario)
        cMsg := STR0054 //"Informe o usuário"
    ElseIf !Self:ValidaSelecaoEmpresa()
        cMsg := STR0055 //"Selecione ao menos uma empresa"
    Else 
        nVldLogin := PswAdmin(Alltrim(Self:cUsuario), Alltrim(Self:cSenha))
        If nVldLogin == 0
            //STR0078 - "Problema"
            //STR0079 - "Solução"
            //STR0080 - "Falha na abertura do ambiente"
            //STR0081 - "Revise as Configurações do License Server do AppServer e DbAccess"
            bErrorBlock := ErrorBlock({|| lValid := .F., cMsg   := STR0078 + ": " + STR0080 + "." + ENTER + STR0079 + ": " + STR0081 + "." })
            Begin Sequence
                aReturn               := StartJob("QDOWizPDFE", GetEnvServer(), .T., Self:aEmpresas, Self:cUsuario, Self:cSenha, Self:nEmpresaMarcada)
                lValid                := aReturn[1]
                Self:nEmpresaMarcada  := aReturn[2]
                cNoCompany            := aReturn[3]
                cExecCompany          := aReturn[4]

                If Empty(cMsg)
                    If Empty(cNoCompany) 
                        If !lValid 
                            cMsg := STR0056 + SubStr(cExecCompany, 1, Len(cExecCompany) - 1) //"Implantação já realizada anteriormente para a empresa: "
                        EndIf
                    Else
                        cMsg      := STR0057 + SubStr(cNoCompany, 1, Len(cNoCompany) - 1) //"Usuário não possui acesso na empresa: "
                        lValid    := .F.
                    EndIf
                EndIf
            Recover
            End Sequence
            ErrorBlock(bErrorBlock)

        Else
            If nVldLogin == 1
                cMsg := STR0058 //"O usuário informado não é administrador do sistema."
            ElseIf nVldLogin == 2
                cMsg := STR0059 //"Dados para login incorretos."
            EndIf
        EndIf
    EndIf

    If !lValid
        MessageBox( cMsg, STR0060, MB_ICONEXCLAMATION ) //"Falha na Validação de Acesso"
    EndIf

Return lValid

/*/{Protheus.doc} ChecaAcessoUsuarioAsEmpresasMarcadas
Checa Acesso do Usuário as Empresas Marcadas

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33

@return aReturn := 
    {lValid: resultado geral de Validação nas empresas,
    nEmpresaMarcada,
    cNoCompany: empresas que o usuário não tem acesso,
    cExecCompany: empresas com necessidade de ajuste do dicionário}
/*/
METHOD ChecaAcessoUsuarioAsEmpresasMarcadas() CLASS QDOWizPDFClass
    Local aReturn         := {}
    Local cExecCompany    := ""
    Local cNoCompany      := ""
    Local lValid          := .F.
    Local nEmpresa        := 0
    Local nEmpresaMarcada := 0

    For nEmpresa := 1 To Len(Self:aEmpresas)
        If Self:aEmpresas[nEmpresa][nMarcado]
            If Self:AbreAmbiente(Self:aEmpresas[nEmpresa][nGrupoDeEmpresa], Self:aEmpresas[nEmpresa][nFilialComposta])
                If nEmpresaMarcada == 0
                    nEmpresaMarcada := nEmpresa
                EndIf
                If !SuperGetMV("MV_QDOCPDF", .F., .F., Self:aEmpresas[nEmpresa][nFilialComposta])
                    lValid := .T. 
                Else
                    cExecCompany += Self:aEmpresas[nEmpresa][nGrupoDeEmpresa] + "/" + Self:aEmpresas[nEmpresa][nFilialComposta] + ","
                    lValid   := .F.
                EndIf
            Else 
                cNoCompany += Self:aEmpresas[nEmpresa][nGrupoDeEmpresa] + "/" + Self:aEmpresas[nEmpresa][nFilialComposta] + "," 
            EndIf
            RpcClearEnv()
        EndIf
    Next nEmpresa 
    aReturn := {lValid, nEmpresaMarcada, cNoCompany, cExecCompany}
Return aReturn

/*/{Protheus.doc} MarcaFilial
Marca a Filial da Linha

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33

@param 01 - oList, objeto, listbox utilizado para marcação de filial
@return lMark, lógico, resultado da marcação
/*/
METHOD MarcaFilial(oList) CLASS QDOWizPDFClass
	Local lMark := .T.
    If Self:ValidaSelecaoEmpresa() .and. !Self:aEmpresas[oList:nAt, nMarcado]
        lMark := .F.
    Else
        Self:aEmpresas[oList:nAt, nMarcado] := !Self:aEmpresas[oList:nAt, nMarcado]
        oList:Refresh(.F.)
    EndIf
Return lMark

/*/{Protheus.doc} ValidaSelecaoEmpresa
Valida Seleção de Ao Menos Uma Empresa

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33
@return retorna .T. se houver pelo menos uma empresa marcada
/*/
METHOD ValidaSelecaoEmpresa() CLASS QDOWizPDFClass
Return (aScan(Self:aEmpresas, {|x| x[1] == .T. }) > 0)

/*/{Protheus.doc} CarregaEmpresas
Cria Array Self:aEmpresas Carregando as Empresas

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33

@param 01 - aSM0    , array   , retorna por referência array da FWLoadSM0() - https://tdn.totvs.com/display/framework/FWLoadSM0
/*/
METHOD CarregaEmpresas(aSM0) CLASS QDOWizPDFClass
    Local aGrupo    := {}
    Local cGrpFil   := ""
    Local cLayout   := ""
    Local nEmpresa  := Nil
    Local nLayout   := Nil
    Local nSM0      := Nil
    Local oTamanhos := JsonObject():New()

	SET DELET ON

    OpenSM0()
    aGrupo := FWAllGrpCompany()
    For nEmpresa := 1 To Len(aGrupo)
        cLayout := FWSM0Layout(aGrupo[nEmpresa])
        oTamanhos[aGrupo[nEmpresa]] := JsonObject():New()
        oTamanhos[aGrupo[nEmpresa]]['nTamEmp']  := 0
        oTamanhos[aGrupo[nEmpresa]]['nTamUnid'] := 0
        oTamanhos[aGrupo[nEmpresa]]['nTamFil']  := 0
        For nLayout := 1 To Len(cLayout)
            If SubStr(cLayout,nLayout,1) == "E"
                oTamanhos[aGrupo[nEmpresa]]['nTamEmp']  += 1
            ElseIf SubStr(cLayout,nLayout,1) == "U"
                oTamanhos[aGrupo[nEmpresa]]['nTamUnid'] += 1
            ElseIf SubStr(cLayout,nLayout,1) == "F"
                oTamanhos[aGrupo[nEmpresa]]['nTamFil']  += 1
            EndIf
        Next nLayout
    Next aGrupo

    aSM0 := FWLoadSM0()
    For nSM0 := 1 To Len(aSM0)
        cGrpFil := PadR(aSM0[nSM0][3], oTamanhos[aSM0[nSM0][1]]['nTamEmp'])  +; 
                   PadR(aSM0[nSM0][4], oTamanhos[aSM0[nSM0][1]]['nTamUnid']) +;
                   PadR(aSM0[nSM0][5], oTamanhos[aSM0[nSM0][1]]['nTamFil'])

        AADD(Self:aEmpresas, { .F., AllTrim(aSM0[nSM0][1]), cGrpFil, AllTrim(aSM0[nSM0][7])})
    Next nSM0

    For nEmpresa := 1 To Len(aGrupo)
        FreeObj(oTamanhos[aGrupo[nEmpresa]])
        oTamanhos[aGrupo[nEmpresa]] := Nil
    Next aGrupo

    FreeObj(oTamanhos)
    oTamanhos := Nil

    FwFreeArray(aGrupo)

Return


/*/{Protheus.doc} SalvaDiretoriosConversores
Salva Diretórios de Instalação dos Conversores

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33
/*/
METHOD SalvaDiretoriosConversores() CLASS QDOWizPDFClass
    Local aSX6     := {}
    Local nTamSX6  := GetSX3Cache("A1_FILIAL", "X3_TAMANHO")

    Self:aDiretorios[nMV_QDOMSOD] := StrTran(Self:aDiretorios[nMV_QDOMSOD], '"', '')
    Self:aDiretorios[nMV_QDOMSOD] := StrTran(Self:aDiretorios[nMV_QDOMSOD], "'", "")
    Aadd(aSX6, { Space(nTamSX6), 'MV_QDOMSOD', 'C', STR0061, STR0062, '',; //"Caminho da Instalação do MS Office Word no Servido", "r de Aplicação do Protheus"
        Self:aDiretorios[nMV_QDOMSOD], Self:aDiretorios[nMV_QDOMSOD], Self:aDiretorios[nMV_QDOMSOD], 'S', 'S'})

    Self:aDiretorios[nMV_QDOLOD] := StrTran(Self:aDiretorios[nMV_QDOLOD], '"', '')
    Self:aDiretorios[nMV_QDOLOD] := StrTran(Self:aDiretorios[nMV_QDOLOD], "'", "")
    Aadd(aSX6, { Space(nTamSX6), 'MV_QDOLOD' , 'C', STR0063, STR0064, '', ; //"Caminho Instalação do LibreOffice Writer no Servid", "or de Aplicação do Protheus"
        Self:aDiretorios[nMV_QDOLOD], Self:aDiretorios[nMV_QDOLOD], Self:aDiretorios[nMV_QDOLOD], 'S', 'S'})

    Aadd(aSX6, { Self:aEmpresas[Self:nEmpresaMarcada][nFilialComposta], 'MV_QDOCPDF' , 'L', STR0071, STR0072, '', ; //"Status da remoção de senha dos arquivos .CEL ", "do servidor do ERP para conversão e leitura em PDF"
        ".F.", ".F.", ".F.", 'S', 'S'})

    Self:SalvaX6(aSX6)
Return .T.

/*/{Protheus.doc} SalvaX6
Salva Parâmetros na SX6

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33

@param 01 - aSX6, array, array com os dados para gravar os registros dos parâmetros na SX6

************************ IMPORTANTE ************************************************************************************************
CHECAR SE O FRAME JÁ DISPONIBILIZOU FUNÇÃO SIMILAR A PUTMV() QUE INCLUI NOVO REGISTRO PARA SUBSTITUIÇÃO, POR HORA, NECESSÁRIO MANTER COMO ABAIXO
************************ IMPORTANTE ************************************************************************************************
/*/
METHOD SalvaX6(aSX6) CLASS QDOWizPDFClass
    Local aStruct  := { "X6_FIL", "X6_VAR", "X6_TIPO", "X6_DESCRIC", "X6_DESC1", "X6_DESC2", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PROPRI", "X6_PYME" }
    Local aSvAlias := GetArea()
    Local lFind    := .F.
    Local nParams  := 0
    Local nFields  := 0

    Default aSX6   := {}

    dbSelectArea("SX6")
    dbSetOrder(1)
    For nParams := 1 To Len(aSX6)
        If !Empty(aSX6[ nParams ][2])
            If !dbSeek(aSX6[ nParams, 1] + aSX6[ nParams, 2])
                lFind := .F.
            Else
                lFind := .T.
            EndIf

            RecLock("SX6", !lFind)
                For nFields := 1 To Len(aSX6[ nParams ])
                    If !Empty(FieldName(FieldPos(aStruct[ nFields ])))
                        If !lFind .Or. "X6_CONT" $ aStruct[ nFields ]
                            FieldPut(FieldPos(aStruct[ nFields ]), aSX6[ nParams, nFields])
                        EndIf
                    EndIf
                Next 
            MsUnLock()
        EndIf
    Next

    RestArea(aSvAlias)
    FwFreeArray(aSvAlias)
    FWFreeArray(aSX6)
Return

/*/{Protheus.doc} AbreAmbiente
Abre Ambiente do Protheus

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33

@param 01 - cCompany, caracter, grupo de empresa para abertura do ambiente
@param 02 - cBranch , caracter, filial para abertura do ambiente

@return lRet, lógico, indnca se conseguiu preparar o ambiente
/*/
METHOD AbreAmbiente(cCompany, cBranch) CLASS QDOWizPDFClass
    Local lRet      := .T.  
    RPCSetType(3)
    If !Empty(Self:cUsuario)
        lRet := RpcSetEnv(cCompany, cBranch, Self:cUsuario, Self:cSenha)
    //Else
    //lRet := RpcSetEnv(cCompany, cBranch)
    EndIf
Return lRet

/*/{Protheus.doc} RetornaDiretoriosDeAcesso
Retorna Parâmetros de Acesso da Primeira Filial Selecionada

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33
@return Self:aDiretorios
/*/
METHOD RetornaDiretoriosDeAcesso() CLASS QDOWizPDFClass
    Local nTamSX6  := Nil
    Self:AbreAmbiente(Self:aEmpresas[Self:nEmpresaMarcada][nGrupoDeEmpresa], Self:aEmpresas[Self:nEmpresaMarcada][nFilialComposta])
    nTamSX6  := GetSX3Cache("A1_FILIAL", "X3_TAMANHO")
    Self:aDiretorios[nMV_QDOMSOD] := PadR(SuperGetMV("MV_QDOMSOD", .F., "C:\Program Files\Microsoft Office\Office15\WINWORD.EXE", Space(nTamSX6)), 255)
    Self:aDiretorios[nMV_QDOLOD]  := PadR(SuperGetMV("MV_QDOLOD" , .F., "C:\Program Files\LibreOffice\program\swriter.exe"      , Space(nTamSX6)), 255)
Return Self:aDiretorios

/*/{Protheus.doc} ValidaFechamento
Valida fechamento da tela de processamento

@type  Function
@author brunno.costa
@since 28/04/2022
@version P12.1.33
@return slConcluiu
/*/
METHOD ValidaFechamento() CLASS QDOWizPDFClass
    If !slConcluiu
        Self:oQDODocumentControl := QDODocumentControl():New()
        //STR0068 - "Aguarde!"
        //STR0069 - "Execução em andamento."
        //STR0070 - "Aguarde o término da execução para sair."
        Self:oQDODocumentControl:help(STR0068, STR0069, STR0070, .F.)
    EndIf
Return slConcluiu

/*/{Protheus.doc} UpdateTipoExibicaoUsuarios
Update Tipo de Execução dos Usuários (QAA_TPWORD)

@type  Function
@author brunno.costa
@since 11/05/2022
@version P12.1.33
/*/
METHOD UpdateTipoExibicaoUsuarios() CLASS QDOWizPDFClass
    Local cUpdate := " UPDATE " + RetSqlName("QAA") + " SET QAA_TPWORD = '4' WHERE D_E_L_E_T_= ' ' AND QAA_FILIAL='" + xFilial("QAA") + "'"
Return TcSqlExec(cUpdate) == 0

/*/{Protheus.doc} QDOWizPDFE
Função Executada por JOB para Checar Acesso do Usuário a Empresa
(Abre Ambiente Fora da Thread Principal para não OCULTAR os HELP em TELA)

@type  Function
@author brunno.costa
@since 31/03/2022
@version P12.1.33

@param 01 - aEmpresas , array, array Self:aEmpresas gerado anteriormente
@param 02 - cUsuario , caracter, usuário digitado pelo usuário na Etapa2
@param 03 - cSenha   , caracter, senha digitada pelo usuário na Etapa2

@return aReturn := 
    {lValid: resultado geral de Validação nas empresas,
    nEmpresaMarcada,
    cNoCompany: empresas que o usuário não tem acesso,
    cExecCompany: empresas com necessidade de ajuste do dicionário}

/*/
Function QDOWizPDFE(aEmpresas, cUsuario, cSenha, nEmpresaMarcada)
    Local oImplantador := QDOWizPDFClass():New(cUsuario, cSenha, aEmpresas, nEmpresaMarcada)
    Local aReturn      := oImplantador:ChecaAcessoUsuarioAsEmpresasMarcadas()
Return aReturn



/*/{Protheus.doc} QDOWizPDFDialogClass
Montagem de Telas de Requisito para Chamada das Funções OLE sem SIGAADV
@Type Class
@author brunno.costa
@since 31/03/2022
/*/
CLASS QDOWizPDFDialogClass FROM LongClassName
    METHOD new() CONSTRUCTOR
    METHOD ChamaMontagemWizard(oDlg)
    METHOD MontaDialog(oMainWnd)
    METHOD MontaMainWnd()
ENDCLASS

METHOD new() CLASS QDOWizPDFDialogClass
Return Self

/*/{Protheus.doc} MontaMainWnd
Monta Main Window Requisito para Utilização das funções OLE/*/
METHOD MontaMainWnd() CLASS QDOWizPDFDialogClass
    Local bWindowInit := Nil
    Local cEmExecucao := Nil
    Private oMainWnd  := Nil

    If !VarIsUID("QDODocumentControl")
        VarSetUID("QDODocumentControl", .T.)
    EndIF

    VarGetX("QDODocumentControl", "cEmExecucao", @cEmExecucao)
    If Empty(cEmExecucao)
        VarBeginT("QDODocumentControl", "lSerializaExecucaoPorAppServer")
        VarSetX("QDODocumentControl", "cEmExecucao", DtoC(Date()) + ' ' + Time() + ' - ' + LogUserName() + '(' + GetComputerName() + ')')
        DEFINE WINDOW oMainWnd FROM 001,001 TO 400,500 TITLE OemToAnsi( STR0001 ) //"Wizard de Diagnóstico e Implantação de Leitura em PDF no SIGAQDO"
        bWindowInit := { || self:MontaDialog(), oMainWnd:End() }
        ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT Eval( bWindowInit ) 
        VarSetX("QDODocumentControl", "cEmExecucao", "")
        VarEndT("QDODocumentControl", "lSerializaExecucaoPorAppServer")
    Else
        MessageBox( STR0075 + ": " + cEmExecucao, STR0076, MB_ICONEXCLAMATION ) //"Implantação em execução" "Tente novamente mais tarde."
    EndIf

    VarClean("QDODocumentControl")
Return

/*/{Protheus.doc} MontaDialog
Monta Dialog Requisito para Utilização das funções OLE
@param 01 - oMainWnd, objeto, main window para criação da DIALOG/*/
METHOD MontaDialog(oMainWnd) CLASS QDOWizPDFDialogClass

    Local bInitDlg     := Nil
    Private oDlg       := Nil
    Private cAcesso    := ""

    DEFINE DIALOG oDlg TITLE "" FROM 0,0 TO 530,720 OF GetWndDefault() PIXEL 
    bInitDlg := { || self:ChamaMontagemWizard(oDlg) }
    ACTIVATE DIALOG oDlg CENTERED ON INIT Eval( bInitDlg ) 
    
Return

/*/{Protheus.doc} ChamaMontagemWizard
Chama Método de Montagem da Classe Responsável por Controle do Wizard de Implantação
@param 01 - oDlg, objeto, Dialog para criação da FWWizardControl/*/
METHOD ChamaMontagemWizard(oDlg) CLASS QDOWizPDFDialogClass
    Local oImplantador := QDOWizPDFClass():New()
    oImplantador:MontaWizard(oDlg)
RETURN

