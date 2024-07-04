#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "GPEGRIDWZ.CH"
/*
@author Leandro Drumond
@since 13/08/2022
@info Wizard para configuração de ambientes com GRID
*/
Main Function GPEGRIDWZ()	

Public dDataBase := Date()
Public cModulo	:= 'GPE'
Public nModulo	:= 07
Public __LPYME	:= .F.	
Public oMainWnd := Nil

DEFINE WINDOW oMainWnd FROM 0,0 TO 0,0 TITLE STR0001 COLOR CLR_BLACK,CLR_WHITE //"Configuração de GRID"
oMainWnd:ReadClientCoors()

/*Configura ambiente inicial.Inicializa variáveis necessarias
para o processamento.*/
RHGetEnv()

//Monta tela de gerenciamento das integrações	
ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT ( oMainWnd:Hide(), MontaTela(), oMainWnd:End())
    
RpcClearEnv()

Return(Nil)

/*
{Protheus.doc} RHGetEnv
	Configura o ambiente inicial
@author Leandro Drumond
@since 13/08/2022
*/
Static Function RHGetEnv()	

RpcSetType(3)
OpenSm0()
SM0->(DbGoTop())

PREPARE ENVIRONMENT EMPRESA (SM0->M0_CODIGO) FILIAL (SM0->M0_CODFIL) MODULO cModulo

__cInternet := Nil

SetSkinDefault()

Return Nil

/*
{Protheus.doc} MontaTela
	Monta a Tela do Wizard
@author Leandro Drumond
@since 13/08/2022
*/
Static Function MontaTela()
        
Private oWizard
Private aIPAgent    := {}
Private aPortaAG    := {}
Private cAmbGrid    := GetEnvServer()
Private cIPGrid     := Padr(GetServerIP(),30)
Private cPortaGrid  := Padr(GetPvProfileInt("TCP", "PORT", 0, GetAdv97()),5)
Private nQtdAgents  := 4
Private nLimConex   := 5
    
/*Painel 1 - Tela inicial do Wizard*/
oWizard := APWizard():New(	OemToAnsi(STR0002),;  // "Configuração de ambiente para utilização de GRID"
                            OemToAnsi(STR0003),;  // "Essa ferramenta irá realizar as alterações necessárias no INI do appserver para possibilitar a utilização de GRID de acordo com a parametrização desejada."
                            OemtoAnsi(STR0004),;  // "Wizard para configuração de GRID"
                            OemToAnsi(STR0005),;  // "Nas próximas telas você deverá parametrizar os itens necessários para criação do ambiente com GRID."
                            {||.T.} 		  ,;
                            {||.T.}			  ,;
                            .F.				  ,;
                            Nil				  ,;
                            {||.T.}			  ,;
                            Nil				  ,;
                            {00,00,600,800})

/*Painel 2 - Parametrização*/
oWizard:NewPanel(	OemToAnsi(STR0006)      ,; //"Parametrização"
                    OemToAnsi(STR0007)      ,; //"Informe os dados para criação do coordinator"
                    {||.T.}					,; //<bBack>
                    {||.T.} 				,; //<bNext>
                    {||.F.}					,; //<bFinish>
                    .T.						,; //<.lPanel.>
                    {|| GetAmbGrid()} )		   //<bExecute>

/*Painel 3 - IP e porta dos agents*/
oWizard:NewPanel(	OemToAnsi(STR0008)      ,; //"Agents do GRID"
                    OemToAnsi(STR0009)      ,; //"Informe o IP e porta dos agents do GRID"
                    {||.T.}					,; //<bBack>
                    {||.T.}					,; //<bNext>
                    {||.F.}					,; //<bFinish>
                    .T. 					,; //<.lPanel.>
                    {|lEnd| GpAmbAgent() })	   //<bExecute>


/*Painel 4 - Geração dos INI's*/
oWizard:NewPanel(	OemToAnsi(STR0010)			,; //"Efetuando configurações"
                    OemToAnsi(STR0011)			,; //"Aguarde o Final do Processamento"
                    {||.F.}						,; //<bBack>
                    {||.F.} 					,; //<bNext>
                    {||.T.}				  		,; //<bFinish>
                    .T. 		  				,; //<.lPanel.>
                    {| lEnd| GpGridExec()})        //<bExecute>


oWizard:Activate( .T.,{||.T.},{||.T.},	{||.T.})

Return Nil

/*
{Protheus.doc} GetAmbGrid
	Dados do ambiente do GRID
@author Leandro Drumond
@since 13/08/2022
*/
Static Function GetAmbGrid()

Local cHelp     := ""
Local bHelp     := {|| cHelp }
Local oPanel	:= oWizard:oMPanel[oWizard:nPanel]
Local oPanelTab := TPanelCss():New(01,04,nil,oPanel,nil,nil,nil,nil,nil,391,210,nil,nil)
Local oPanelRod := TPanelCss():New(212,04,nil,oPanel,nil,nil,nil,nil,nil,391,22,nil,nil)
Local oGet1, oGet2, oGet3, oGet4, oGet5

/*Painel Esquerda*/
TSay():New( 005 ,010,{||STR0012},oPanelTab,,,,,,.T.,,,100,10) //"Environment"
oGet1 := TGet():New( 015, 010,{ | u | If( PCount() == 0, cAmbGrid, cAmbGrid := u ) },oPanelTab, 300,10, "!@",, 0, 16777215,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F.,,"cAmbGrid",,,,.T.  )

TSay():New( 035 ,010,{||STR0013},oPanelTab,,,,,,.T.,,,100,10) //"IP do coordinator"
oGet2 := TGet():New( 045, 010,{ | u | If( PCount() == 0, cIPGrid, cIPGrid := u ) },oPanelTab, 300,10, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cIPGrid",,,,.T.  )

TSay():New( 065 ,010,{||STR0014},oPanelTab,,,,,,.T.,,,100,10) //"Porta do coordinator"
oGet3 := TGet():New( 075, 010,{ | u | If( PCount() == 0, cPortaGrid, cPortaGrid := u ) },oPanelTab, 300,10, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cPortaGrid",,,,.T.  )

TSay():New( 095 ,010,{||STR0015},oPanelTab,,,,,,.T.,,,100,10) //"Quantidade de GridAgents"
oGet4 := TGet():New( 105, 010, { | u | If( PCount() == 0, nQtdAgents, nQtdAgents := u ) },oPanelTab,060, 010, "@E 99",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nQtdAgents",,,,.T.)

TSay():New( 125 ,010,{||STR0016},oPanelTab,,,,,,.T.,,,100,10) //"Máximo conexões por GridAgent"
oGet5 := TGet():New( 135, 010, { | u | If( PCount() == 0, nLimConex, nLimConex := u ) },oPanelTab,060, 010, "@E 99",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nLimConex",,,,.T.)

oGet2:bGotFocus := {|| UpdRod(@cHelp, 2)}
oGet3:bGotFocus := {|| UpdRod(@cHelp, 3)}
oGet4:bGotFocus := {|| UpdRod(@cHelp, 4)}
oGet5:bGotFocus := {|| UpdRod(@cHelp, 5)}

oGet2:bLostFocus := {|| UpdRod(@cHelp, 1)}
oGet3:bLostFocus := {|| UpdRod(@cHelp, 1)}
oGet4:bLostFocus := {|| UpdRod(@cHelp, 1)}
oGet5:bLostFocus := {|| UpdRod(@cHelp, 1)}

/*RODAPE*/
cHelp := STR0017 //"Aqui devem ser inseridas as informações para configuração do coordinator, que é o servidor principal do GRID, responsável por fazer a distribuição dos processos entre os GridAgents."
TSay():New(006 ,010,bHelp,oPanelRod,,,,,,.T.,,,350,300)

Return

/*
{Protheus.doc} UpdRod
	Atualiza mensagem no rodapé
@author Leandro Drumond
@since 13/08/2022
*/
Static Function UpdRod(cHelp, nTipo)

If nTipo == 1
    cHelp := STR0017 //"Aqui devem ser inseridas as informações para configuração do coordinator, que é o servidor principal do GRID, responsável por fazer a distribuição dos processos entre os GridAgents."
ElseIf nTipo == 2
    cHelp := STR0018 //"IP do coordinator - O sistema busca automaticamente o IP do Application Server que esta sendo executado, ele poderá ser alterado para uma nova implantação."
ElseIf nTipo == 3
    cHelp := STR0019 //"Porta do Coordinator - O sistema busca automaticamente a porta do Application Server que esta sendo executado, como o IP, poderá ser alterado para uma nova implantação."
ElseIf nTipo == 4
    cHelp := STR0020 //"Informe a quantidade de GridAgents que serão utilizados. Tenha em mente que a quantidade de GridAgents deve ser proporcional ao potencial de hardware do ambiente."
ElseIf nTipo == 5 
    cHelp := STR0021 //"Informe o limite de conexões por GridAgent, essa informação, da mesma forma que a anterior, deve levar em consideração o potencial de hardware do ambiente."
EndIf

Return Nil

/*
{Protheus.doc} GpAmbAgent
	Dados dos agents do GRID
@author Leandro Drumond
@since 13/08/2022
*/
Static Function GpAmbAgent()

Local oPanel	:= oWizard:oMPanel[oWizard:nPanel]
Local oPanelTab := TPanelCss():New(01,04,nil,oPanel,nil,nil,nil,nil,nil,391,210,nil,nil)
Local oPanelRod := TPanelCss():New(212,04,nil,oPanel,nil,nil,nil,nil,nil,391,22,nil,nil)
Local oFont     := TFont():New('Arial',,-18,,.T.)
Local cBlkGet   := ""
Local nX        := 0
Local nLin1     := 5
Local nLin2     := 15

// Cria objeto Scroll
oScroll := TScrollBox():New(oPanel,10,10,200,380,.T.,.T.,.F.)

aIPAgent := {}
aPortaAG := {}

For nX := 1 to nQtdAgents
    aAdd(aIPAgent, Padr(cIPGrid,30))
    aAdd(aPortaAG, PadR(cValToChar(Val(cPortaGrid)+nX),5))

    cBlkGet := "{||'GridAgent " + AllTrim(cValToChar(nX)) + "'}"
    TSay():New( nLin1 ,010,&cBlkGet,oScroll,,oFont,,,,.T.,,,100,10)

    cBlkGet   := "{ | u | If( PCount() == 0, aIPAgent["+cValToChar(nX)+"],aIPAgent["+cValToChar(nX)+"]:= u ) }"
    TSay():New( nLin2,010,{||STR0022},oScroll,,,,,,.T.,,,100,10,,,,,,,0,2) //"IP:"
    TGet():New( nLin2,020,&cBlkGet,oScroll, 40,10, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"aIPAgent["+cValToChar(nX)+"]",,,,.T.  )

    cBlkGet   := "{ | u | If( PCount() == 0, aPortaAG["+cValToChar(nX)+"],aPortaAG["+cValToChar(nX)+"]:= u ) }"
    TSay():New( nLin2,065,{||STR0023},oScroll,,,,,,.T.,,,100,10,,,,,,,0,2) //"Porta:"
    TGet():New( nLin2,080,&cBlkGet,oScroll, 20,10, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"aPortaAG["+cValToChar(nX)+"]",,,,.T.  )

    nLin1 += 30
    nLin2 += 30

Next nX

/*RODAPE*/
TSay():New(006 ,010,{||STR0024},oPanelRod,,,,,,.T.,,,350,300) //"Informe o IP e porta de cada GridAgent. O sistema preenche o IP com o conteúdo definido no coordinator, mas o ideal é que cada GridAgent seja configurado em uma máquina diferente."

Return

/*
{Protheus.doc} GpGridExec
	Criação dos INI's
@author Leandro Drumond
@since 13/08/2022
*/
Static Function GpGridExec()
Local cArqAux   := GetAdv97()
Local cKeyAux   := "TOPCONNECT"
Local cPath     := ""
Local aEnv      := GetIniKeys(cArqAux, cAmbGrid)
Local aTop      := GetIniKeys(cArqAux, "TOPCONNECT")
Local aDrv      := GetIniKeys(cArqAux, "DRIVERS")
Local aGen      := GetIniKeys(cArqAux, "GENERAL")
Local aLicS     := GetIniKeys(cArqAux, "LICENSESERVER")
Local aLicC     := GetIniKeys(cArqAux, "LICENSECLIENT")
Local aMail     := GetIniKeys(cArqAux, "MAIL")
Local aTDS      := GetIniKeys(cArqAux, "TDS")
Local aArquivo  := {}
Local nX        := 1
Local lRet      := .T.

//Obtem o caminho do executável do appserver
getAppPath(@cPath)

//Cria trecho de definição do ambiente
aAdd(aArquivo, "[" + cAmbGrid + "]")

For nX := 1 to Len(aEnv)
    aAdd(aArquivo, aEnv[nX] + "=" + GetPvProfString(cAmbGrid, aEnv[nX], "", cArqAux))
Next nX

//Seção TOPCONNECT
If Empty(aTop)
    aTop := GetIniKeys(cArqAux, "DBACCESS")
    cKeyAux   := "DBACCESS"
EndIf
If Len(aTop) > 0
    aAdd(aArquivo, " ")
    aAdd(aArquivo, "[DBACCESS]")

    For nX := 1 to Len(aTop)
        aAdd(aArquivo, aTop[nX] + "=" + GetPvProfString(cKeyAux, aTop[nX], "", cArqAux))
    Next nX
EndIf

//Seção DRIVERS
If Len(aDrv) > 0
    aAdd(aArquivo, " ")
    aAdd(aArquivo, "[DRIVERS]")

    For nX := 1 to Len(aDrv)
        aAdd(aArquivo, aDrv[nX] + "=" + GetPvProfString("DRIVERS", aDrv[nX], "", cArqAux))
    Next nX
EndIf

//Seção GENERAL
If Len(aGen) > 0
    aAdd(aArquivo, " ")
    aAdd(aArquivo, "[GENERAL]")

    For nX := 1 to Len(aGen)
        aAdd(aArquivo, aGen[nX] + "=" + GetPvProfString("GENERAL", aGen[nX], "", cArqAux))
    Next nX
EndIf

//Seção LICENSESERVER
If Len(aLicS) > 0
    aAdd(aArquivo, " ")
    aAdd(aArquivo, "[LICENSESERVER]")

    For nX := 1 to Len(aLicS)
        aAdd(aArquivo, aLicS[nX] + "=" + GetPvProfString("LICENSESERVER", aLicS[nX], "", cArqAux))
    Next nX
EndIf

//Seção LICENSECLIENT
If Len(aLicC) > 0
    aAdd(aArquivo, " ")
    aAdd(aArquivo, "[LICENSECLIENT]")

    For nX := 1 to Len(aLicC)
        aAdd(aArquivo, aLicC[nX] + "=" + GetPvProfString("LICENSECLIENT", aLicC[nX], "", cArqAux))
    Next nX
EndIf

//Seção MAIL
If Len(aMail) > 0
    aAdd(aArquivo, " ")
    aAdd(aArquivo, "[MAIL]")

    For nX := 1 to Len(aMail)
        aAdd(aArquivo, aMail[nX] + "=" + GetPvProfString("MAIL", aMail[nX], "", cArqAux))
    Next nX
EndIf

//Seção TDS
If Len(aTDS) > 0
    aAdd(aArquivo, " ")
    aAdd(aArquivo, "[TDS]")

    For nX := 1 to Len(aTDS)
        aAdd(aArquivo, aTDS[nX] + "=" + GetPvProfString("TDS", aTDS[nX], "", cArqAux))
    Next nX
EndIf

Processa({|| lRet := fGeraCoordinator(aArquivo,cPath),STR0025}) //"Gerando INI do Coordinator"

If lRet
    Processa({|| fGeraAgent(aArquivo,cPath),STR0026}) //"Gerando INI dos GridAgents"

    MsgInfo(STR0027 + CRLF + STR0028) //"Processo finalizado." ### "Verifique os dados gerados na pasta GRIDSERVER dentro da pasta appserver."
Else 
    MsgAlert(STR0029) //"Falha na criação dos arquivos"
EndIf

Return Nil

/*
{Protheus.doc} fGeraCoordinator
	Gera o appserver.ini do coordinator
@author Leandro Drumond
@since 13/08/2022
*/
Static Function fGeraCoordinator(aArquivo,cPath)
Local aFiles        := {}
Local cArquivo      := cPath + "\GRIDSERVER\"
Local cServers      := ""
Local cArqAux       := ""
Local nHandle		:= fCreate(cArquivo)
Local nX            := 0
Local nY            := 0
Local lRet          := .T.
Local lExisteApp    := .F.

//Verifica se a pasta appserver esta dentor da pasta GRIDSERVER para copia-la
If ExistDir(cArquivo + "\appserver\")
    aFiles := Directory(cArquivo + "\appserver\*.*")
    lExisteApp := !Empty(aFiles)
EndIf 

If ExistDir(cArquivo) .Or. MakeDir(cArquivo) == 0

    If lExisteApp
        cArqAux := cPath + "\GRIDSERVER\COORDINATOR\"
    EndIf

    If lExisteApp .and. ( ExistDir(cArqAux) .or. MakeDir(cArqAux) == 0 )
        For nY := 1 To Len(aFiles)
            If AllTrim(UPPER(aFiles[nY,1])) <> "APPSERVER.INI"
		        __CopyFile(cArquivo + "\appserver\" + aFiles[nY,1], cArqAux + aFiles[nY,1] )
            EndIf
	    Next
        nHandle		:= fCreate(cArqAux + "appserver.ini")
    Else
        nHandle		:= fCreate(cArquivo + "appserver_coordinator.ini")
    EndIf

    If nHandle < 0
        Alert(STR0030) //"Falha na criação do arquivo INI"
        lRet := .F.
    Else 

        For nX := 1 to nQtdAgents
            If !Empty(cServers)
                cServers += ","
            EndIf
            cServers += "GRIDAGENT" + StrZero(nX,2)
        Next nX 

        For nX := 1 to Len(aArquivo)
            FWrite(nHandle,aArquivo[nX]+CRLF)
        Next nX

        FWrite(nHandle,CRLF)

        FWrite(nHandle,"[TCP]" +CRLF)
        FWrite(nHandle,"TYPE=TCPIP" +CRLF)
        FWrite(nHandle,"PORT=" + cPortaGrid +CRLF)

        FWrite(nHandle,CRLF)

        FWrite(nHandle,";Configuração de GRID criada pelo Wizard GPEGRIDWZ" +CRLF)

        FWrite(nHandle,"[SERVERNETWORK]" +CRLF)
        FWrite(nHandle,"MasterConnection=0" +CRLF)
        FWrite(nHandle,"Servers=" + cServers +CRLF)

        For nX := 1 to Len(aIPAgent)
            FWrite(nHandle,CRLF)
            FWrite(nHandle,"[GRIDAGENT" + StrZero(nX,2) + "]" +CRLF)
            FWrite(nHandle,"Type=TCPIP" +CRLF)
            FWrite(nHandle,"Server=" + aIPAgent[nX] + CRLF)
            FWrite(nHandle,"Port=" + aPortaAG[nX] + CRLF)
            FWrite(nHandle,"Connections=" + cValToChar(nLimConex) + CRLF)
        Next nX

        FWrite(nHandle,CRLF)

        FWrite(nHandle,"[ONSTART]" + CRLF)
        FWrite(nHandle,"Jobs=GridServer" + CRLF)
        FWrite(nHandle,"RefreshRate=60" + CRLF)
        FWrite(nHandle,"JobDelay=1" + CRLF)

        FWrite(nHandle,CRLF)

        FWrite(nHandle,"[GridServer]" + CRLF)
        FWrite(nHandle,"Main=GridServer" + CRLF)
        FWrite(nHandle,"Environment=" + cAmbGrid + CRLF)

        FClose(nHandle)
    EndIf
EndIf

Return lRet

/*
{Protheus.doc} RHGetEnv
	Gera o appserver.ini do GridAgent
@author Leandro Drumond
@since 13/08/2022
*/
Static Function fGeraAgent(aArquivo,cPath)
Local aFiles        := {}
Local cAgent        := ""
Local cArquivo      := cPath + "\GRIDSERVER\"
Local cArqAux       := cPath + "\GRIDSERVER\"
Local nX            := 0
Local nY            := 0
Local nHandle
Local lExisteApp    := .F.
Local lCriouAmb     := .F.

//Verifica se a pasta appserver esta dentor da pasta GRIDSERVER para copia-la
If ExistDir(cArquivo + "\appserver\")
    aFiles := Directory(cArquivo + "\appserver\*.*")
    lExisteApp := !Empty(aFiles)
EndIf 

For nX := 1 to nQtdAgents
    cAgent      := StrZero(nX,2)

    If lExisteApp
        cArqAux := cPath + "\GRIDSERVER\" + "GRIDAGENT" + cAgent + "\"
    EndIf

    If lExisteApp .and. ( ExistDir(cArqAux) .or. MakeDir(cArqAux) == 0 )
        For nY := 1 To Len(aFiles)
            If AllTrim(UPPER(aFiles[nY,1])) <> "APPSERVER.INI"
		        __CopyFile(cArquivo + "\appserver\" + aFiles[nY,1], cArqAux + aFiles[nY,1] )
            EndIf
	    Next
        lCriouAmb   := .T.
        nHandle		:= fCreate(cArqAux + "appserver.ini")
    Else
        nHandle		:= fCreate(cArquivo + "appserver_GRIDAGENT" + cAgent + ".ini")
    EndIf
    
    If nHandle > 0

        For nY := 1 to Len(aArquivo)
            FWrite(nHandle,aArquivo[nY]+CRLF)
        Next nY

        FWrite(nHandle,CRLF)

        FWrite(nHandle,"[TCP]" +CRLF)
        FWrite(nHandle,"TYPE=TCPIP" +CRLF)
        FWrite(nHandle,"PORT=" + aPortaAG[nX] +CRLF)

        FWrite(nHandle,CRLF)

        FWrite(nHandle,";Configuração de GRID criada pelo Wizard GPEGRIDWZ" +CRLF)

        FWrite(nHandle,"[ONSTART]" + CRLF)
        FWrite(nHandle,"Jobs=GridAgent" + CRLF)
        FWrite(nHandle,"RefreshRate=15" + CRLF)

        FWrite(nHandle,CRLF)

        FWrite(nHandle,"[GridAgent]" + CRLF)
        FWrite(nHandle,"Main=GridAgent" + CRLF)
        FWrite(nHandle,"Environment=" + cAmbGrid + CRLF)
        FWrite(nHandle,"Instances=" + cValToChar(nLimConex) + CRLF)
        FWrite(nHandle,"AgentIp=" + aIPAgent[nX] + CRLF)
        FWrite(nHandle,"CoordServer=" + AllTrim(cIPGrid) + CRLF)
        FWrite(nHandle,"CoordPort=" + AllTrim(cPortaGrid) + CRLF)

        FClose(nHandle)

    EndIf
Next nX

nHandle		:= fCreate(cArquivo + "LEIA-ME.txt")
    
If nHandle > 0
    FWrite(nHandle,STR0031 +CRLF) //"ORIENTAÇÕES PARA USO DO GRID."
    FWrite(nHandle,"=============================" +CRLF)

    FWrite(nHandle,CRLF)
    FWrite(nHandle,CRLF)

    If !lCriouAmb
        FWrite(nHandle,STR0032 + CRLF) //"1 - Crie uma cópia da pasta appserver com o nome COORDINATOR"
        FWrite(nHandle,STR0033 + CRLF) //"2 - Exclua o arquivo appserver.ini da nova pasta"
        FWrite(nHandle,STR0034 + CRLF) //"3 - Mova o arquivo appserver_coordinator.ini para a pasta COORDINATOR e renomeie-o para appserver.ini"
        FWrite(nHandle,STR0035 + CRLF) //"4 - Crie uma cópia da pasta appserver para cada GridAgent e nomeie-a com GRIDAGENTnn, onde nn é o número do GridAgent"
        FWrite(nHandle,STR0036 + CRLF) //"5 - Exclua o arquivo appserver.ini de todas as pastas criadas para o GridAgent"
        FWrite(nHandle,STR0037 + CRLF) //"6 - Mova o arquivo appserver_gridagentNN.ini para a pasta GRIDAGENTnn, onde nn é o número do GridAgent e renomeie-o para appserver.ini"
    Else 
        FWrite(nHandle,STR0038 + CRLF) //"1 - As pastas COORDINATOR e GRIDAGENTnn contém uma cópia da pasta appserver deixada como modelo e estão configuradas para o coordinator e os gridagents"
        FWrite(nHandle,STR0039 + CRLF) //"2 - Elimine a pasta appserver original e utilize as outras para montagem do ambiente."
    EndIf

    FWrite(nHandle,CRLF)
    FWrite(nHandle,CRLF)

    FWrite(nHandle,STR0040 + CRLF) //"IMPORTANTE:"
    FWrite(nHandle,STR0041 + CRLF) //"O Coordinator e os GridAgents devem ser copiados para suas respectivas máquinas, no caso de ter um IP para cada um."
    FWrite(nHandle,STR0042 + CRLF) //"Segue a lista dos IP's informados na parametrização e número dos GridAgents"

    FWrite(nHandle,CRLF)

    FWrite(nHandle,STR0043 + AllTrim(cIPGrid) + STR0044 + AllTrim(cPortaGrid) + CRLF) //"Coordinator => IP: " ### " - Porta: "

    For nX := 1 to nQtdAgents
        FWrite(nHandle,CRLF)
        FWrite(nHandle,STR0045 +  StrZero(nX,2) + STR0046 + AllTrim(aIPAgent[nX]) + STR0044 + AllTrim(aPortaAG[nX]) + CRLF) //"GridAgent" ### " => IP: " ### " - Porta: "
    Next nX

    FClose(nHandle)
EndIf

Return NIL



