#INCLUDE "TOTVS.CH"
#INCLUDE "FwSchedule.ch"
#Include "QDOWIZREMS.CH"

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
#DEFINE oFont13B   TFont():New("Arial", , -13, , .T.) //Cabeçalho página de processamento
#DEFINE oFont14    TFont():New("Arial", , -14, , .F.) //Textos diversos explicações

//Bitmaps do Markbox
#DEFINE oBmpLBNO   LoadBitmap(GetResources(), "LBNO")
#DEFINE oBmpLBTIK  LoadBitmap(GetResources(), "LBTIK")

//Legendas da grid de processamento
#DEFINE oBmpLegAM  LoadBitmap(GetResources(), 'BR_AMARELO' )
#DEFINE oBmpLegAtu LoadBitmap(GetResources(), 'REFRESH' )
#DEFINE oBmpLegNO  LoadBitmap(GetResources(), 'BR_VERMELHO' )
#DEFINE oBmpLegOK  LoadBitmap(GetResources(), 'BR_VERDE' )

//Controla início e fim da execução em TTimer
Static slIniciou  := .F.
Static slConcluiu := .F.


/*/{Protheus.doc} QDOWizRemS
Wizard de  Remoção de Senha do módulo SIGAQDO
@type  Function
@author celio.pereira
@since 05/07/2022
@version P12.1.33
/*/
Main Function QDOWizRemS()
    Local  oMainClass := QDOWizRemSDialogClass():New()
    oMainClass:MontaMainWnd()
Return

/*/{Protheus.doc} QDOWizRemSClass
Regras de Negocio - Wizard de remoção de senha de documentos no módulo SIGAQDO
@Type Class
@author celio.pereira
@since 08/07/2022
/*/
CLASS QDOWizRemSClass FROM LongNameClass

    DATA aEmpresas                     as ARRAY
    DATA aProcesso                     as ARRAY
    DATA cSenha                        as STRING
    DATA cUsuario                      as STRING
    DATA nEmpresaMarcada               as NUMERIC
    DATA oQDODocumentControl           as OBJECT
    DATA oTimerExecucao                as OBJECT
    DATA oTimerStatus                  as OBJECT
    
    DATA nPosicaoArquivoAtual          as NUMERIC
    DATA nPosicaoIdentificandoArquivos as NUMERIC
    DATA nPosicaoProcessando           as NUMERIC
	
    METHOD new(cUsuario, cSenha, aEmpresas, nEmpresaMarcada) CONSTRUCTOR

    //METODOS MONTAGEM DO WIZARD
    METHOD MontaWizard(oDlg)
    METHOD Etapa1(oPanel)           //Tela de Boas Vindas
    METHOD Etapa2(oPanel, aSM0)     //Tela de Login x Filial
    METHOD Etapa3(oPanel, oStepWiz) //Grid com Status de Processamento
    METHOD AtualizaStatusProcessamento(oBrwWiz, cChave)

    //METODO EXECUCAO IMPLANTACAO
    METHOD ExecutaImplantacao(nMilissegundos, oBrwWiz, oPanel)

    //DEMAIS METODOS AUXILIARES
    METHOD AbreAmbiente(cCompany, cBranch)
    METHOD CarregaEmpresas(aSM0)
    METHOD ChecaAcessoUsuarioAsEmpresasMarcadas()
    METHOD MarcaFilial(oList)
    METHOD ValidaFechamento()
    METHOD ValidaSelecaoEmpresa()
    METHOD ValidaUsuario()

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author celio.pereira
@since 08/07/2022

@param 01 - cUsuario        , caracter, usuário digitado pelo usuário na Etapa2
@param 02 - cSenha          , caracter, senha digitada pelo usuário na Etapa2
@param 03 - aEmpresas       , array   , array Self:aEmpresas gerado anteriormente no Self:CarregaEmpresas()
@param 04 - nEmpresaMarcada , número  , número identificador da empresa selecionada para implantação
@return Self, objeto, instancia da Classe QDOWizRemSClass
/*/
METHOD new(cUsuario, cSenha, aEmpresas, nEmpresaMarcada) CLASS QDOWizRemSClass
    Default cUsuario          := Space(35)
    Default cSenha            := Space(35)
    Default aEmpresas         := {}
    Default nEmpresaMarcada   := 0

    Self:aEmpresas            := aEmpresas
    Self:aProcesso            := {}
    Self:cSenha               := cSenha
    Self:cUsuario             := cUsuario
    Self:nEmpresaMarcada      := nEmpresaMarcada

Return Self

/*/{Protheus.doc} MontaWizard
Monta Estrutura do Wizard de Implantação

@type  Function
@author celio.pereira
@since 08/07/2022
@version P12.1.33
@param 01 - oDlg, objeto, dialog para montagem da FwWizardControl
/*/
METHOD MontaWizard(oDlg) CLASS QDOWizRemSClass
    Local aSM0        := {}
    Local lRet        := .T.
    Local oNewPag     := Nil
    Static oStepWiz   := Nil

    oStepWiz:= FWWizardControl():New(oDlg, { 530, 720 })
    oStepWiz:ActiveUISteps()
    
    // Pagina 1 - Boas Vindas
    oNewPag := oStepWiz:AddStep()
    oNewPag:SetStepDescription(STR0062) //"Boas Vindas"
    oNewPag:SetConstruction({ |oPanel| Self:Etapa1(oPanel) })
    oNewPag:SetNextAction({|| .T.})
    
    // Pagina 2 - Autenticação e Seleção de Filiais
    oNewPag := oStepWiz:AddStep()
    oNewPag:SetStepDescription(STR0063) //"Autenticação"
    oNewPag:SetConstruction({|oPanel| Self:Etapa2(oPanel, @aSM0) })    
    oNewPag:SetNextAction({|| FWMsgRun(/*oComponent*/,{ || lRet := Self:ValidaUsuario() }, Nil,STR0065), lRet }) //"Validando os acessos do administrador"
    

     // Pagina 3 - Remoção
    oNewPag := oStepWiz:AddStep()
    oNewPag:SetStepDescription(STR0064) //"Remoção"
    oNewPag:SetConstruction({|oPanel| oPanelAux := oPanel, FWMsgRun(/*oComponent*/,{ || Self:Etapa3(oPanelAux, oStepWiz) }, Nil, STR0066) }) //"Carregando"
    oNewPag:SetCancelWhen({|| .F. })
    oNewPag:SetNextAction({|| Self:validaFechamento() })
    oStepWiz:Activate()

Return

/*/{Protheus.doc} Etapa1
Monta Etapa 1 do Wizard - Boas Vindas
@type  Function
@author celio.pereira
@since 08/07/2022
@version P12.1.33

@param 01 - oPanel, objeto, painel para exibição da etapa
/*/
METHOD Etapa1(oPanel) CLASS QDOWizRemSClass

    Local cWelcome1 := STR0001 //"Bem vindo(a)!"
    Local cWelcome2 := STR0002 // "Este é o Wizard de remoção de senha de todos os arquivos internos do SIGAQDO"

    Local cWelcome3 := STR0003 //"Ao executar o processo a seguir, será registrada a remoção de senha para todos os arquivos do módulo SIGAQDO e o parametro MV_QSAVPSW será alterado para 0"
    Local cWelcome6 := STR0005 //"O sistema realizará a remoção de senha de todos os documentos armazenados com senha no diretório correspondente do SIGAQDO no servidor de Aplicação do ERP."
    Local cWelcome7 := STR0006 //"Para continuar pressione o botão 'Avançar' ou 'Cancelar' para abortar o processo."

    TSay():New(10 , 15, {|| cWelcome1 }, oPanel, , oFont14, , , , .T., , , 330, 20)
    TSay():New(25 , 15, {|| cWelcome2 }, oPanel, , oFont14, , , , .T., , , 330, 20)
    TSay():New(40 , 15, {|| cWelcome6 }, oPanel, , oFont14, , , , .T., , , 330, 30)
    TSay():New(60 , 15, {|| cWelcome3 }, oPanel, , oFont14, , , , .T., , , 330, 20)
    TSay():New(145, 15, {|| cWelcome7 }, oPanel, , oFont14, , , , .T., , , 330, 20)
   
 Return

/*/{Protheus.doc} Etapa2
Monta Etapa 2 do Wizard - Validando de Acesso e Seleção de Filiais

@type  Function
@author celio.pereira
@since 08/07/2022
@version P12.1.33

@param 01 - oPanel  , objeto  , painel para exibição da etapa
@param 02 - aSM0    , array   , retorna por referência array da FWLoadSM0() - https://tdn.totvs.com/display/framework/FWLoadSM0
/*/
METHOD Etapa2(oPanel, aSM0) CLASS QDOWizRemSClass

    Local oList   := Nil
    Local oTGet1  := Nil
    Local oTGet2  := Nil

    Self:CarregaEmpresas(@aSM0)

    @ 5, 5 GROUP TO 40, 195 PROMPT STR0007 OF oPanel PIXEL //"Validação de Acesso"

        @ 14, 10 SAY  STR0008 OF oPanel PIXEL FONT oFont12B //"Usuário Administrador:"
        @ 24, 10 MSGET oTGet1 VAR Self:cUsuario SIZE 80, 10 OF oPanel Font oFont12 PIXEL 

        @ 14, 100 SAY STR0009 OF oPanel PIXEL FONT oFont12B //"Senha:"
        @ 24, 100 MSGET oTGet2 VAR Self:cSenha SIZE 80, 10 OF oPanel Font oFont12 PIXEL PASSWORD
    // Monta a lista de empresas. 
    @ 40, 5 GROUP TO 170, 195 PROMPT STR0010 OF oPanel PIXEL //"Filiais"
        @ 50, 10 LISTBOX oList;
            FIELDS HEADER "", STR0011, STR0012, STR0013 SIZE 180, 115 OF oPanel PIXEL; //"Grupo Emp", "Filial", "Descrição"
            ON DBLCLICK Self:MarcaFilial(oList)
            oList:SetArray(Self:aEmpresas)
            oList:bLine := {|| { ;
                If(Self:aEmpresas[oList:nAt, nMarcado], oBmpLBTIK, oBmpLBNO),;
                   Self:aEmpresas[oList:nAt, nGrupoDeEmpresa],;
                   Self:aEmpresas[oList:nAt, nFilialComposta],;
                   Self:aEmpresas[oList:nAt, nDescricaoFilial] }}
            oList:Refresh()

    // Montando Explicação Filiais
    @ 5, 200 GROUP TO 170, 360 PROMPT STR0014 COLOR CLR_RED OF oPanel PIXEL //"ATENÇÃO"
        @ 15, 205 SAY STR0015 + ENTER + ENTER; //"Selecione a filial que deseja remover o controle de senha do módulo SIGAQDO. Somente é permitido a execução de uma filial por vez, para execuções futuras as demais filiais deverão ser marcadas."
                    + STR0016 + ENTER + ENTER; //"IMPORTANTE: o processo de remoção de senhas deve ser executado em computador com o MS Office Instalado localmente para que o Protheus consiga utilizar a integração nativa com o MS Office para a remoção de senhas dos arquivos armazenados no Servidor de Aplicação."
                      SIZE 150, 205 OF oPanel PIXEL FONT oFont14
    oTGet1:SetFocus()
   
Return

/*/{Protheus.doc} Etapa3
Monta Etapa 3 do Wizard - Remoção

@type  Function
@author celio.pereira
@since 08/07/2022
@version P12.1.33

@param 01 - oPanel  , objeto, painel para exibição da etapa
@param 02 - oStepWiz, objeto, instancia da FwWizardControl utilizada no processo
/*/

METHOD Etapa3(oPanel, oStepWiz) CLASS QDOWizRemSClass
    Local nLinha         := 0
	Local nMilissegundos := 100
	Local oBrwWiz        := Nil
    Local oDesc          := Nil
    Local oTitulo        := Nil

    Self:AbreAmbiente(Self:aEmpresas[Self:nEmpresaMarcada][nGrupoDeEmpresa], Self:aEmpresas[Self:nEmpresaMarcada][nFilialComposta])

    //Desabilita tecla ESC
	oPanel:oWnd:lEscClose := .F.

    //Oculta o botão "Voltar" da tela de processamento
	oStepWiz:oUiStepWizard:SetPrevVisibility(.F.)

    //Texto do cabeçalho
    oTitulo    := TSay():New(05,  10, {|| STR0017 }, oPanel, , oFont13B, , , , .T., , , 290, 20) //"Executando diagnóstico e remoção... aguarde."
    oDesc      := TSay():New(15,  10, {|| STR0018 }, oPanel, , oFont11 , , , , .T., , , 290, 20) //"Acompanhe o status de cada uma das etapas da execução:"

    nLinha++
    Self:nPosicaoIdentificandoArquivos := nLinha
    aAdd(Self:aProcesso, {oBmpLegAtu, STR0019, STR0020}) //"Identificando Arquivos" - "Pendente"

    nLinha++
    Self:nPosicaoProcessando           := nLinha
    aAdd(Self:aProcesso, {oBmpLegAM   , STR0021, STR0020}) //"Processando a Remoção de Senha" - "Pendente"

    nLinha++
    Self:nPosicaoArquivoAtual          := nLinha
    aAdd(Self:aProcesso, {oBmpLegAM   , "-> " + STR0022 + ":", STR0020}) //"Arquivo Atual" - "Pendente"

    oBrwWiz := TSBrowse():New(30, 10, 344, 140, oPanel, , 16, , 1)
    oBrwWiz:AddColumn( TCColumn():New(''     ,,,{|| },{|| },,20 , .T.) )
    oBrwWiz:AddColumn( TCColumn():New(STR0023,,,{|| },{|| },,200, .F.) ) //"Processo"
    oBrwWiz:AddColumn( TCColumn():New(STR0024,,,{|| },{|| },,50 , .F.) ) //"Status"
    oBrwWiz:SetArray(Self:aProcesso)

    //Cria Thread no SmartClient via Timer Execução do processamento Fora do Fluxo de Construção Inicial da Tela
    Self:oTimerExecucao := TTimer():New(nMilissegundos, {|| Iif(!slIniciou, (slIniciou := .T., Self:ExecutaImplantacao(nMilissegundos, oBrwWiz, oPanel)), ) }, oPanel:oWnd )
    Self:oTimerExecucao:Activate()

 Return

/*/{Protheus.doc} AtualizaStatusProcessamento
Atualiza Status do Processamento (Dados da GRID - Etapa 4)

@type  Function
@author celio.pereira
@since 08/07/2022
@version P12.1.33

@param 01 - oBrwWiz , objeto  , instancia da grid utilizada para exibição dos dados de processamento
@param 02 - cChave  , caracter, cEmpAnt+cFilAnt
/*/
METHOD AtualizaStatusProcessamento(oBrwWiz, cChave) CLASS QDOWizRemSClass

    Local aRetAux     := {}
    Local cArquivo    := ""
    Local cAtual      := ""
    Local cEmExecucao := ""
    Local cPercentual := ""
    Local cRegistros  := ""
    Local cRetAux     := ""
    Local cStatusNv   := ""
    Local cTextoNv    := ""
    Local lEncerra    := .T.
    Local lForcaSaida := .F.
    Local nInd        := 0
    Local nTotal      := 0

    cRetAux := GetGlbValue( "QDODocumentControl_nPosicaoProcessando"+cChave)
    If cRetAux != Nil .AND. !Empty(cRetAux)
        Self:aProcesso[Self:nPosicaoProcessando][nColunaStatus]            := cRetAux
        If AllTrim(cRetAux) == AllTrim(STR0025)                                       //"Iniciado"
            Self:aProcesso[Self:nPosicaoProcessando][nColunaLegenda]       := oBmpLegAtu
        ElseIf AllTrim(cRetAux) == AllTrim(STR0026)                                   //"Concluído"
            lForcaSaida := .T.
            Self:aProcesso[Self:nPosicaoProcessando][nColunaLegenda]       := oBmpLegOK
            Self:aProcesso[Self:nPosicaoProcessando][nColunaStatus]        := STR0026 //"Concluído"
            Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaLegenda]      := oBmpLegOK
            Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaProcesso]     := STR0027 //"Processamento Finalizado"
            Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaStatus]       := STR0026 //"Concluído"
        ElseIf AllTrim(cRetAux) == AllTrim(STR0028);                                  //"Erro"
            .OR. AllTrim(cRetAux) == AllTrim(STR0030)                                 //"Cancelado"
            cStatusNv := Iif(AllTrim(cRetAux) == AllTrim(STR0028), STR0028, STR0030)  //"Erro" ou "Cancelado"
            cTextoNv  := Iif(AllTrim(cRetAux) == AllTrim(STR0028), STR0029, STR0031)  //"Processamento Finalizado com Erro" ou "Processamento Cancelado"
            lForcaSaida := .T.
            Self:aProcesso[Self:nPosicaoProcessando][nColunaLegenda]           := oBmpLegNO
            Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaLegenda]          := oBmpLegNO
            Self:aProcesso[Self:nPosicaoIdentificandoArquivos][nColunaLegenda] := oBmpLegNO
            Self:aProcesso[Self:nPosicaoProcessando][nColunaStatus]            := cStatusNv
            Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaStatus]           := cStatusNv
            Self:aProcesso[Self:nPosicaoIdentificandoArquivos][nColunaStatus]  := cStatusNv
            Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaProcesso]         := cTextoNv
        EndIf
    EndIf
    
    cRegistros := GetGlbValue( "QDODocumentControl_nRegistros_"+cChave )
    If !Empty(cRegistros) .AND. AllTrim(cRegistros) != ""
        If At(":", Self:aProcesso[Self:nPosicaoIdentificandoArquivos][nColunaProcesso]) <= 0
            //STR0032 - "Identificando Arquivos"
            //STR0033 - "documentos"
            Self:aProcesso[Self:nPosicaoIdentificandoArquivos][nColunaProcesso] := STR0032 + ": " + AllTrim(cRegistros) + " " + STR0033
            Self:aProcesso[Self:nPosicaoIdentificandoArquivos][nColunaStatus]   := STR0026 //"Concluído"
            Self:aProcesso[Self:nPosicaoIdentificandoArquivos][nColunaLegenda]  := oBmpLegOK
        EndIf
        
        cAtual := GetGlbValue( "QDODocumentControl_nAtual_"+cChave )
        If !Empty(cAtual) .AND. AllTrim(cAtual) != ""
            cPercentual := AlLTrim(Str(Round(Val(cAtual) / Val(cRegistros) * 100, 2))) + '%'
            Self:aProcesso[Self:nPosicaoProcessando][nColunaStatus]  := cPercentual
            Self:aProcesso[Self:nPosicaoProcessando][nColunaLegenda] := IIf(Val(cAtual) == Val(cRegistros), oBmpLegOK, Self:aProcesso[Self:nPosicaoProcessando][nColunaLegenda])
        EndIf   

        If !lForcaSaida
            cArquivo := GetGlbValue( "QDODocumentControl_cArquivo_"+cChave )
            If !Empty(cArquivo) .AND. Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaStatus] != STR0026 //"Concluído"
                Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaProcesso] := "-> " + STR0035 + ": " + AllTrim(cArquivo) //"Arquivo Atual"
                Self:aProcesso[Self:nPosicaoArquivoAtual][nColunaStatus]   := STR0034 //"Processando"
            EndIf
        EndIf
    EndIf

    VarBeginT("QDODocumentControl", "aArquivosErros")
        If VarGetXA("QDODocumentControl", @aRetAux)
            nTotal := Len(aRetAux)
            For nInd := 1 to nTotal
                If "cEmExecucao" == AllTrim(aRetAux[nInd][1])
                    cEmExecucao := aRetAux[nInd][2]
                ElseIf ValType(aRetAux[nInd]) == "A" .AND. !Empty(aRetAux[nInd][1])
                    aAdd(Self:aProcesso, {oBmpLegAM, "-> " + STR0042 +": " + aRetAux[nInd][1] + aRetAux[nInd][2], STR0014 }) //"Falha na Conversão do Arquivo" - "ATENÇÃO"
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
Executa os Procedimentos de remoção

@type  Function
@author celio.pereira
@since 08/07/2022
@version P12.1.33
/*/
METHOD ExecutaImplantacao(nMilissegundos, oBrwWiz, oPanel) CLASS QDOWizRemSClass
   
    Local cChave      := Nil

    Self:AbreAmbiente(Self:aEmpresas[Self:nEmpresaMarcada][nGrupoDeEmpresa], Self:aEmpresas[Self:nEmpresaMarcada][nFilialComposta])
    cChave := cEmpAnt+cFilAnt
    
    //Limpa variáveis de controle globais
    PutGlbValue( "QDODocumentControl_nPosicaoProcessando"      + cChave, "" )
    PutGlbValue( "QDODocumentControl_nRegistros_"              + cChave, "" )
    PutGlbValue( "QDODocumentControl_nAtual_"                  + cChave, "" )
    PutGlbValue( "QDODocumentControl_cAtual_"                  + cChave, "" )
    
    //Cria Thread no SmartClient via Timer para atualização de Status Fora do Fluxo de Construção Inicial da Tela
    Self:oTimerStatus := TTimer():New(nMilissegundos, {|| Self:AtualizaStatusProcessamento(oBrwWiz, cChave) }, oPanel:oWnd )
    Self:oTimerStatus:Activate()

    Self:oQDODocumentControl := QDODocumentControl():New()

    PutGlbValue( "QDODocumentControl_nPosicaoProcessando"       + cChave, STR0025 ) //"Iniciado"
    PutMV("MV_QSAVPSW", "1")
    If Self:oQDODocumentControl:somenteRemoveSenhaDocumentosServidor(.F.)
        PutMV("MV_QSAVPSW", "0")
        PutGlbValue( "QDODocumentControl_nPosicaoProcessando"   + cChave, STR0026 ) //"Concluído"
    Else
        PutGlbValue( "QDODocumentControl_nPosicaoProcessando"   + cChave, STR0030 ) //"Cancelado"
    EndIf

    //Finaliza Thread de Execução Ao Término da Primeira Chamada
    Self:oTimerExecucao:DeActivate()
Return

/*/{Protheus.doc} ValidaUsuario
Controla Validação de Usuário e Mensagens

@type  Function
@author celio.pereira
@since 08/07/2022
@version P12.1.33

@return lValid, lógico, indica se o usuário é válido para todas as empresas marcadas
/*/
METHOD ValidaUsuario() CLASS QDOWizRemSClass
    Local aReturn      := {}
    Local bErrorBlock  := Nil
    Local cExecCompany := ""
    Local cMsg         := ""
    Local cNoCompany   := ""
    Local lValid       := .F.
    Local nVldLogin    := Nil

    If Empty(Self:cUsuario)
        cMsg := STR0045 //"Informe o usuário"
    ElseIf !Self:ValidaSelecaoEmpresa()
        cMsg := STR0046 //"Selecione ao menos uma empresa"
    Else 
        nVldLogin := PswAdmin(Alltrim(Self:cUsuario), Alltrim(Self:cSenha))
        If nVldLogin == 0
            //STR0047 - "Problema"
            //STR0048 - "Solução"
            //STR0049 - "Falha na abertura do ambiente"
            //STR0050 - "Revise as Configurações do License Server do AppServer e DbAccess"
            bErrorBlock := ErrorBlock({|| lValid := .F., cMsg   := STR0047 + ": " + STR0049 + "." + ENTER + STR0048 + ": " + STR0050 + "." })
            Begin Sequence
                aReturn               := StartJob("QDOWizRemE", GetEnvServer(), .T., Self:aEmpresas, Self:cUsuario, Self:cSenha, Self:nEmpresaMarcada)
                lValid                := aReturn[1]
                Self:nEmpresaMarcada  := aReturn[2]
                cNoCompany            := aReturn[3]
                cExecCompany          := aReturn[4]

                If Empty(cMsg)
                    If Empty(cNoCompany) 
                        If !lValid 
                            cMsg := STR0051 + SubStr(cExecCompany, 1, Len(cExecCompany) - 1) //"Remoção já realizada anteriormente para a empresa: "
                        EndIf
                    Else
                        cMsg      := STR0052 + SubStr(cNoCompany, 1, Len(cNoCompany) - 1) //"Usuário não possui acesso na empresa: "
                        lValid    := .F.
                    EndIf
                EndIf
            Recover
            End Sequence
            ErrorBlock(bErrorBlock)

        Else
            If nVldLogin == 1
                cMsg := STR0053 //"O usuário informado não é administrador do sistema."
            ElseIf nVldLogin == 2
                cMsg := STR0054 //"Dados para login incorretos."
            EndIf
        EndIf
    EndIf

    If !lValid
        MessageBox( cMsg, STR0055, MB_ICONEXCLAMATION ) //"Falha na Validação de Acesso"
    EndIf

Return lValid

/*/{Protheus.doc} ChecaAcessoUsuarioAsEmpresasMarcadas
Checa Acesso do Usuário as Empresas Marcadas

@type  Function
@author celio.pereira
@since 08/07/2022
@version P12.1.33

@return aReturn := 
    {lValid: resultado geral de Validação nas empresas,
    nEmpresaMarcada,
    cNoCompany: empresas que o usuário não tem acesso,
    cExecCompany: empresas com necessidade de ajuste do dicionário}
/*/
METHOD ChecaAcessoUsuarioAsEmpresasMarcadas() CLASS QDOWizRemSClass
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
@author celio.pereira
@since 08/07/2022
@version P12.1.33

@param 01 - oList, objeto, listbox utilizado para marcação de filial
@return lMark, lógico, resultado da marcação
/*/
METHOD MarcaFilial(oList) CLASS QDOWizRemSClass
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
@author celio.pereira
@since 08/07/2022
@version P12.1.33
@return retorna .T. se houver pelo menos uma empresa marcada
/*/
METHOD ValidaSelecaoEmpresa() CLASS QDOWizRemSClass
Return (aScan(Self:aEmpresas, {|x| x[1] == .T. }) > 0)

/*/{Protheus.doc} CarregaEmpresas
Cria Array Self:aEmpresas Carregando as Empresas

@type  Function
@author celio.pereira
@since 08/07/2022
@version P12.1.33

@param 01 - aSM0    , array   , retorna por referência array da FWLoadSM0() - https://tdn.totvs.com/display/framework/FWLoadSM0
/*/
METHOD CarregaEmpresas(aSM0) CLASS QDOWizRemSClass
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
            oTamanhos[aGrupo[nEmpresa]]['nTamEmp']  += Iif(SubStr(cLayout,nLayout,1) == "E", 1, 0)
            oTamanhos[aGrupo[nEmpresa]]['nTamUnid'] += Iif(SubStr(cLayout,nLayout,1) == "U", 1, 0)
            oTamanhos[aGrupo[nEmpresa]]['nTamFil']  += Iif(SubStr(cLayout,nLayout,1) == "F", 1, 0)
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

/*/{Protheus.doc} AbreAmbiente
Abre Ambiente do Protheus

@type  Function
@author celio.pereira
@since 08/07/2022
@version P12.1.33

@param 01 - cCompany, caracter, grupo de empresa para abertura do ambiente
@param 02 - cBranch , caracter, filial para abertura do ambiente

@return lRet, lógico, indnca se conseguiu preparar o ambiente
/*/
METHOD AbreAmbiente(cCompany, cBranch) CLASS QDOWizRemSClass
    Local lRet      := .T.  
    RPCSetType(3)
    If !Empty(Self:cUsuario)
        lRet := RpcSetEnv(cCompany, cBranch, Self:cUsuario, Self:cSenha)
    EndIf
Return lRet

/*/{Protheus.doc} ValidaFechamento
Valida fechamento da tela de processamento

@type  Function
@author celio.pereira
@since 28/04/2022
@version P12.1.33
@return slConcluiu
/*/
METHOD ValidaFechamento() CLASS QDOWizRemSClass
    If !slConcluiu
        Self:oQDODocumentControl := QDODocumentControl():New()
        //STR0056 - "Aguarde!"
        //STR0057 - "Execução em andamento."
        //STR0070 - "Aguarde o término da execução para sair."
        Self:oQDODocumentControl:help(STR0056, STR0057, STR0058, .F.)
    EndIf
Return slConcluiu

/*/{Protheus.doc} QDOWizRemSE
Função Executada por JOB para Checar Acesso do Usuário a Empresa
(Abre Ambiente Fora da Thread Principal para não OCULTAR os HELP em TELA)

@type  Function
@author celio.pereira
@since 08/07/2022
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
Function QDOWizRemE(aEmpresas, cUsuario, cSenha, nEmpresaMarcada)
    Local oImplantador := QDOWizRemSClass():New(cUsuario, cSenha, aEmpresas, nEmpresaMarcada)
    Local aReturn      := oImplantador:ChecaAcessoUsuarioAsEmpresasMarcadas()
Return aReturn


/*/{Protheus.doc} QDOWizRemSDialogClass
Montagem de Telas de Requisito para Chamada das Funções OLE sem SIGAADV
@Type Class
@author celio.pereira
@since 08/07/2022
/*/
CLASS QDOWizRemSDialogClass FROM LongClassName
    METHOD new() CONSTRUCTOR
    METHOD ChamaMontagemWizard(oDlg)
    METHOD MontaDialog(oMainWnd)
    METHOD MontaMainWnd()
ENDCLASS

METHOD new() CLASS QDOWizRemSDialogClass
Return Self

/*/{Protheus.doc} MontaMainWnd
Monta Main Window Requisito para Utilização das funções OLE/*/
METHOD MontaMainWnd() CLASS QDOWizRemSDialogClass
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
        DEFINE WINDOW oMainWnd FROM 001,001 TO 400,500 TITLE OemToAnsi( STR0059 )//"Wizard de remoções de senha do módulo SIGAQDO"
        bWindowInit := { || self:MontaDialog(), oMainWnd:End() }
        ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT Eval( bWindowInit ) 
        VarSetX("QDODocumentControl", "cEmExecucao", "")
        VarEndT("QDODocumentControl", "lSerializaExecucaoPorAppServer")
    Else
        MessageBox( STR0060 + ": " + cEmExecucao, STR0061, MB_ICONEXCLAMATION ) //"remoção em execução" "Tente novamente mais tarde."
    EndIf

    VarClean("QDODocumentControl")
Return

/*/{Protheus.doc} MontaDialog
Monta Dialog Requisito para Utilização das funções OLE
@param 01 - oMainWnd, objeto, main window para criação da DIALOG/*/
METHOD MontaDialog(oMainWnd) CLASS QDOWizRemSDialogClass

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
METHOD ChamaMontagemWizard(oDlg) CLASS QDOWizRemSDialogClass
    Local oImplantador := QDOWizRemSClass():New()
    oImplantador:MontaWizard(oDlg)
RETURN
