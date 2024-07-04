#include "TOTVS.ch"
#include "protheus.ch"

STATIC __dbName := UPPER(TCGetDB())

function PLHATWZD()
    local oPlsHatWizard := PlsHatWizard():new()
    local nTable := 1
    local nLenTables := 0
    private aTables := {}

    initTables()
    nLenTables := len(aTables)
    while nTable <= nLenTables
        _SetOwnerPrvt("lCheck" + StrZero(nTable,2),.F.)
        nTable++
    enddo

    oPlsHatWizard:create()
    oPlsHatWizard:stepOne()
    oPlsHatWizard:stepTwo()
    oPlsHatWizard:stepThree()
    oPlsHatWizard:activate()

return

static function initTables()
    aAdd(aTables,{"B05","B05 - Itens de Sistemas Dentários "})
    aAdd(aTables,{"BA0","BA0 - Operadoras de Saúde "})
    aAdd(aTables,{"BA1","BA1 - Usuários"})
    aAdd(aTables,{"BA3","BA3 - Famílias Usuários "})
    aAdd(aTables,{"BA6","BA6 - Subcont x Prod x Classe Car "})
    aAdd(aTables,{"BAN","BAN - Produtos da Classe Carência "})
    aAdd(aTables,{"BAQ","BAQ - Especialidades"})
    aAdd(aTables,{"BAU","BAU - Redes de Atendimento"})
    aAdd(aTables,{"BAW","BAW - Operadoras da Rede Atendimento"})
    aAdd(aTables,{"BAX","BAX - Especialidades do Local "})
    aAdd(aTables,{"BB0","BB0 - Profissionais de Saúde"})
    aAdd(aTables,{"BB2","BB2 - Benefícios dos Produtos "})
    aAdd(aTables,{"BB6","BB6 - Redes de Atendimento Planos "})
    aAdd(aTables,{"BB8","BB8 - Locais de Rede Atendimento"})
    aAdd(aTables,{"BBF","BBF - Especialidades Atendimentos "})
    aAdd(aTables,{"BBI","BBI - Planos Autorizados"})
    aAdd(aTables,{"BBK","BBK - Redes Referenciada Atendimento"})
    aAdd(aTables,{"BBM","BBM - Padrão de Saúde "})
    aAdd(aTables,{"BBN","BBN - Procedimentos Não Autorizados "})
    aAdd(aTables,{"BC0","BC0 - Procedimentos Rede Atendimento"})
    aAdd(aTables,{"BC1","BC1 - Corpo Clinico da Rede "})
    aAdd(aTables,{"BDL","BDL - Classe de Carência"})
    aAdd(aTables,{"BE2","BE2 - Autorização e Procedimentos "})
    aAdd(aTables,{"BE4","BE4 - Internações "})
    aAdd(aTables,{"BE6","BE6 - Corpo Clínico Valor Especial"})
    aAdd(aTables,{"BE9","BE9 - Procedimentos por Produtos"})
    aAdd(aTables,{"BEA","BEA - Complementos Movimentações"})
    aAdd(aTables,{"BEG","BEG - Autorizações Eventos Críticos "})
    aAdd(aTables,{"BEJ","BEJ - Itens Autorização Internação"})
    aAdd(aTables,{"BEL","BEL - Críticas da Autorização "})
    aAdd(aTables,{"BFC","BFC - Grupos de Cobertura Famílias"})
    aAdd(aTables,{"BFD","BFD - Procedimentos das Famílias"})
    aAdd(aTables,{"BFE","BFE - Grupos de Cobertura Usuários"})
    aAdd(aTables,{"BFG","BFG - Procedimentos dos Usuários"})
    aAdd(aTables,{"BFJ","BFJ - Classes Carências da Família"})
    aAdd(aTables,{"BFO","BFO - Classe de Carência do Usuário "})
    aAdd(aTables,{"BG7","BG7 - Cabeçalhos Grupos de Cobertura"})
    aAdd(aTables,{"BG8","BG8 - Itens dos Grupos de Coberturas"})
    aAdd(aTables,{"BG9","BG9 - Grupos Empresas "})
    aAdd(aTables,{"BIA","BIA - Vínculo Entre Operadoras"})
    aAdd(aTables,{"BJE","BJE - Classes de Procedimentos"})
    aAdd(aTables,{"BLD","BLD - Cabecalho de Pacotes"})
    aAdd(aTables,{"BLE","BLE - Itens dos Pacotes "})
    aAdd(aTables,{"BQC","BQC - Subcontrato "})
    aAdd(aTables,{"BR4","BR4 - Tipo de Tabela Padrão "})
    aAdd(aTables,{"BR8","BR8 - Tabela Padrao "})
    aAdd(aTables,{"BRV","BRV - Planos e Grupos de Cobertura"})
    aAdd(aTables,{"BT4","BT4 - Planos Rede de Atendimentos "})
    aAdd(aTables,{"BT5","BT5 - Grupo de Empresa Contrato "})
    aAdd(aTables,{"BT6","BT6 - Empresa Contrato Produto"})
    aAdd(aTables,{"BT7","BT7 - Empresa Grupo de Cobertura"})
    aAdd(aTables,{"BT8","BT8 - Empresa Cobertura "})
    aAdd(aTables,{"BTS","BTS - Vidas "})
    aAdd(aTables,{"BVI","BVI - Usr x Grp Cob x Classe Car"})
    aAdd(aTables,{"BYL","BYL - SistDent x Período/Qtd"})
    aAdd(aTables,{"SE1","SE1 - Contas a Receber"})
    aAdd(aTables,{"BF1","BF1 - Folder Opcionais"})
    aAdd(aTables,{"BI3","BI3 - Produtos de Saúde"})
    aAdd(aTables,{"BI6","BI6 - Segmentação"})
    aAdd(aTables,{"B1R","B1R - Protocolo de transação"})
    aAdd(aTables,{"BXX","BXX - Importação XML"})
    aAdd(aTables,{"BCI","BCI - Pegs"})
    aAdd(aTables,{"B06","B06 - Grupo Periodicidade"})
    aAdd(aTables,{"B08","B08 - Procedimentos Incomp. X Dente"})
    aAdd(aTables,{"B0N","B0N - Pre-requisitos"})
    aAdd(aTables,{"BA9","BA9 - Doenças CIDS"})
    aAdd(aTables,{"BCT","BCT - Motivos de Glosas"})
    aAdd(aTables,{"BFP","BFP - Sub-Especialidade Procedimento"})
    aAdd(aTables,{"BJ4","BJ4 - Procedimentos Incompatíveis"})
    aAdd(aTables,{"BW3","BW3 - Itens do Grupo de Quantidade"})
    aAdd(aTables,{"BAA","BAA - Tabela de Doenças Padrão"})
    aAdd(aTables,{"B26","B26 - Itens Proc Incompat. X RDA"})
    aAdd(aTables,{"BTQ","BTQ - Detalhe das Terminologias TISS"})
    aAdd(aTables,{"BTU","BTU - Relacao TISSxProtheus(De/Para)"})
    aAdd(aTables,{"BDT","BDT - Calendário de Pagamentos"})    
    aAdd(aTables,{"B2J","B2J - Calendario Envio/Entrega Fat"})
    aAdd(aTables,{"B2K","B2K - Calendario Envio/Entrega Fat Item"}) 
return

class PlsHatWizard
    data oWizard
    data oHashStamp
    data aStampList
    data oDlg
    data oPanel
    data oStepper
    data oFont

    method new() constructor
    method create()
    method activate()
    method stepOne()
    method stepTwo()
    method stepThree()


endclass

method new() class PlsHatWizard
    self:oFont := TFont():New('Roboto Condensed Light',,16,.T.)
return self

method create() class PlsHatWizard

    DEFINE DIALOG self:oDlg TITLE 'Wizard de Configuração HAT' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )

    self:oDlg:nWidth := 1024
    self:oDlg:nHeight := 600
    self:oPanel:= tPanel():New(0,0,"",self:oDlg,,,,,,300,300)
    self:oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    self:oStepper:= FWWizardControl():New(self:oPanel)
    self:oStepper:ActiveUISteps()

return

method activate() class PlsHatWizard
    self:oStepper:Activate()
    ACTIVATE DIALOG self:oDlg CENTER
return

method stepOne() class PlsHatWizard
    local oNewPag := nil

    oNewPag := self:oStepper:AddStep("1")
    oNewPag:SetStepDescription("Informaçães")
    oNewPag:SetConstruction({|Panel|buildStep1(Panel,self:oFont)})
    oNewPag:SetCancelAction({||self:oDlg:end()})

return

static function buildStep1(oPanel, oFont)
    local cTextHtml := ""

    cTextHtml += '<h1>Informaçães</h1>'
    cTextHtml += '<hr size="1">'
    cTextHtml += '<p>Seja bem vindo ao Wizard de configuração de integração do PLS x HAT.<br>'
    cTextHtml += 'Nos próximos passos, será possível configurar os processos que garantem a'
    cTextHtml += ' integração entre as tabelas do <b>PLS</b> e do <b>HAT</b></p>'
    cTextHtml += '<p>Configuraçães:'
    cTextHtml += '<ul><li>Criação das colunas S_T_A_M_P_</li></ul>'
    cTextHtml += '</p>'

    // Cria o TSay permitindo texto no formato HMTL
    lHtml := .T.
    oSay := TSay():New(10,10,{||cTextHtml},oPanel,,oFont,,,,.T.,,,400,600,,,,,,lHtml)

return

method stepTwo() class PlsHatWizard
    local oNewPag := nil

    oNewPag := self:oStepper:AddStep("2")
    oNewPag:SetStepDescription("Criação das colunas S_T_A_M_P_")
    oNewPag:SetConstruction({|Panel|buildStep2(Panel,self:oFont)})
    oNewPag:SetNextAction({||createStamp()})
    oNewPag:SetCancelAction({||self:oDlg:end()})

return

static function buildStep2(oPanel, oFont)
    local cTextHtml := ""
    local lHtml := .T.
    local oScroll := nil
    local nLenTables := 0
    local nTable := 1
    local nCheckLine := 20
    local nCheckCol := 10
    local nCountLine := 1

    cTextHtml += '<h1>Criação das colunas S_T_A_M_P_</h1>'
    cTextHtml += '<hr size="1">'
    cTextHtml += '<p>A criação das colunas S_T_A_M_P_ é necessária para que as views de'
    cTextHtml += ' extração configuradas pelo <b>HAT Setup</b> funcionem corretamente</p>'
    cTextHtml += '<p>Requisitos para que as colunas sejam criadas: LIB do Framework esteja atualizada;'
    cTextHtml += ' versão do DBAccess seja a partir de 19/11/2019 Build 19.2.1.0; banco de dados '
    cTextHtml += ' ORACLE/MSSQL</p>'
    cTextHtml += '<p>Selecione abaixo as tabelas para criação da coluna:</p>'

    oSay := TSay():New(10,10,{||cTextHtml},oPanel,,oFont,,,,.T.,,,400,600,,,,,,lHtml)
    oScroll := TScrollBox():New(oPanel,80,10,115,400,.T.,.F.,.T.)
    TButton():New(10, 10, "Inverter Seleção",oScroll,{||invert()}, 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )   

    nLenTables := len(aTables)
    while nTable <= nLenTables

        if nCountLine <= 30
            nCheckLine += 15
        else
            nCountLine := 1
            nCheckLine := 35
            nCheckCol += 120
        endif

        oCheckBox := TCheckBox():New(nCheckLine,nCheckCol,aTables[nTable][2],,oScroll,100,210,,,,,,,,.T.)
        oCheckBox:bSetGet := &("{||lCheck" + StrZero(nTable,2) + "}")
        oCheckBox:bLClicked := &("{||lCheck" + StrZero(nTable,2) + " := !lCheck" + StrZero(nTable,2) + "}")

        nTable++
        nCountLine++

    enddo

    nTable := 1


return

static function invert()
    local nLenTables := 0
    local nTable := 1

    nLenTables := len(aTables)
    while nTable <= nLenTables
        &("lCheck" + StrZero(nTable,2) + " := !lCheck" + StrZero(nTable,2))
        nTable++
    enddo
return

static function createStamp()
    local aProcessa := {}
    local nLenTables := 0
    local nTable := 1
    local lSuccess := .T.

    nLenTables := len(aTables)
    while nTable <= nLenTables
        if &("lCheck" + StrZero(nTable,2))
            aAdd(aProcessa,aTables[nTable])
        endif
        nTable++
    enddo

    lSuccess := IsCompatible()

    if lSuccess
        Processa({||ProcStamp(aProcessa)}, "Processando", "Iniciando criação das colunas", .F.)
    else
        MsgAlert(   "Para dar continuidade na criação das colunas, " +;
                    "é necessário que o sistema atenda aos requisitos informados.")
    endif

return lSuccess

static function IsCompatible()
    local cConfig := TCConfig( 'ALL_CONFIG_OPTIONS' )
    local aConfig := StrTokArr( cConfig, ';' )
    local lIsCompatible := .T.

    // Verifica DbAccess
    if  !(aScan(aConfig,"SETUSEROWSTAMP=ON|OFF") > 0 .and.;
        aScan(aConfig,"SETAUTOSTAMP=ON|OFF") > 0)
        lIsCompatible := .F.
        ConOut(Time() + " - PLHATWZD - DbAccess nao compativel")
    endif

    // // Verifica funcao Frame
    // if !(FindFunction("FwEnableStamp"))
    //     lIsCompatible := .F.
    //     ConOut(Time() + " - PLHATWZD - LibFrame nao compativel")
    // endif

    // Verifica SGBD
    ConOut( __dbName )
    if !(__dbName $ "ORACLE/MSSQL/POSTGRES")
        lIsCompatible := .F.
        ConOut(Time() + " - PLHATWZD - SGBD nao compativel")
    endif

return lIsCompatible

static function ProcStamp(aProcessa)
    local nLenProc := 0
    local nProc := 1

    nLenProc := len(aProcessa)
    ProcRegua(nLenProc)
    while nProc <= nLenProc
        IncProc("Tabela " + aProcessa[nProc][2])
        ConOut(Time() + " - PLHATWZD - Inicio da atualizacao da tabela " + aProcessa[nProc][1])
        if FindFunction("FwEnableStamp")
            FwEnableStamp(aProcessa[nProc][1])
        else
            HatEnableStamp(aProcessa[nProc][1])
        endif
        ConOut(Time() + " - PLHATWZD - Final da atualizacao da tabela " + aProcessa[nProc][1])
        AlterTrigger(aProcessa[nProc][1])
        nProc++
    enddo

return .T.

method stepThree() class PlsHatWizard
    local oNewPag := nil

    oNewPag := self:oStepper:AddStep("3")
    oNewPag:SetStepDescription("Concluído")
    oNewPag:SetConstruction({|Panel|buildStep3(Panel,self:oFont)})
    oNewPag:SetNextAction({||self:oDlg:end()})
    oNewPag:SetCancelAction({||self:oDlg:end()})
return

static function buildStep3(oPanel, oFont)
    local cTextHtml := ""
    local lHtml := .T.

    cTextHtml += '<h1>Concluído</h1>'
    cTextHtml += '<hr size="1">'
    cTextHtml += '<p>A configuração da integração <b>PLS x HAT</b> foi concluída com sucesso!<p>'
    cTextHtml += '<p>Você pode retornar a esse wizard a qualquer momento caso haja necessidade de alterar alguma configuração.<p>'

    oSay := TSay():New(10,10,{||cTextHtml},oPanel,,oFont,,,,.T.,,,400,600,,,,,,lHtml)

return

static function HatEnableStamp(cAlias)
    local cSqlInstruction := ""
    local cSqlAlias := RetSqlName(cAlias)

    // Cria a coluna
    TCConfig("SETUSEROWSTAMP=ON")
    TCConfig("SETAUTOSTAMP=ON")

    DBSelectArea(cAlias)
    (cAlias)->(DbCloseArea())
    TCRefresh(cSqlAlias)
    DBSelectArea(cAlias)
    
    TCConfig("SETUSEROWSTAMP=OFF") 
    TCConfig("SETAUTOSTAMP=OFF")

    // Cria o indice
    if __dbName $ "ORACLE/MSSQL/POSTGRES"
        cSqlInstruction := ' CREATE INDEX ' + cSqlAlias + '_STAMP ON ' + cSqlAlias + ' (S_T_A_M_P_, R_E_C_N_O_, D_E_L_E_T_)'
    endif
    ConOut(Time() + " - PLHATWZD - Criando indice da tabela " + cAlias)
    TCSqlExec(cSqlInstruction)

return

static function AlterTrigger(cAlias)
    local cSqlInstruction   := ""
    local cSqlAlias         := RetSqlName(cAlias)
    local nStatus           := 0

    // Dropa a view criada
    if __dbName $ "POSTGRES"
        cSqlInstruction := 'DROP TRIGGER ' + cSqlAlias + '_STAMP ON ' + cSqlAlias + ';'
    else
        cSqlInstruction := 'DROP TRIGGER ' + cSqlAlias + '_STAMP'
    endif
    
    ConOut(Time() + " - PLHATWZD - Dropando trigger da tabela " + cAlias)
    nStatus := TCSqlExec(cSqlInstruction)
    if (nStatus < 0)
        conout("TCSQLError() " + TCSQLError())
    endif

    // Cria a mesma trigger adicionando o INSERT
    if __dbName $ "ORACLE"
        cSqlInstruction := ' CREATE TRIGGER ' + cSqlAlias + '_STAMP'
        cSqlInstruction += ' BEFORE INSERT OR UPDATE ON ' + cSqlAlias
        cSqlInstruction += ' FOR EACH ROW'
        cSqlInstruction += ' BEGIN'
        cSqlInstruction += '    SELECT SYS_EXTRACT_UTC(SYSTIMESTAMP) '
        cSqlInstruction += '    INTO :NEW.S_T_A_M_P_'
        cSqlInstruction += '    FROM DUAL;'
        cSqlInstruction += ' END;'
    elseif __dbName $ "MSSQL"
        cSqlInstruction := ' CREATE TRIGGER ' + cSqlAlias + '_STAMP'
        cSqlInstruction += '  ON ' + cSqlAlias + ' FOR UPDATE, INSERT AS '
        cSqlInstruction += ' BEGIN'
        cSqlInstruction += '   SET NOCOUNT ON;'
        cSqlInstruction += '   UPDATE ' + cSqlAlias + ' SET S_T_A_M_P_ = GETUTCDATE()  WHERE R_E_C_N_O_ IN ( SELECT R_E_C_N_O_ FROM INSERTED );'
        cSqlInstruction += ' END;'
    elseif __dbName $ "POSTGRES"
        cSqlInstruction := ' CREATE OR REPLACE FUNCTION ' + cSqlAlias + '_STAMP()'
        cSqlInstruction += '    RETURNS trigger'
        cSqlInstruction += '    LANGUAGE plpgsql'
        cSqlInstruction += '    AS $function$'
        cSqlInstruction += ' BEGIN'
        cSqlInstruction += ' new.s_t_a_m_p_ = timezone("utc", now());    return new;'
        cSqlInstruction += ' end;'
        cSqlInstruction += ' $function$;'
        cSqlInstruction += ' CREATE TRIGGER ' + cSqlAlias + '_STAMP'
        cSqlInstruction += ' BEFORE INSERT OR UPDATE ON ' + cSqlAlias
        cSqlInstruction += ' FOR EACH ROW execute function ' +  cSqlAlias + '_STAMP();'
    endif
    ConOut(Time() + " - PLHATWZD - Recriando trigger da tabela " + cAlias)
    nStatus := TCSqlExec(cSqlInstruction)
    if (nStatus < 0)
        conout("TCSQLError() " + TCSQLError())
    endif

return
