#Include "EEC.CH"
#include "FWMVCDEF.CH"
#include "EECDN400.CH"
#Define SEPARADOR Repl("_", 60) + Chr(13) + Chr(10)

/*
Função    : EECDN400()
Objetivo  : Manutenção de despesas nacionais da fase de embarque de exportação. Possibilita efetuar manutenção da mesma despesa entre vários embarques.
            As despesas dos embarques são agrupadas por "Filial", "Código da Despesa", "Empresa" (Fornecedor), "Data" e "Documento".
Autor     : Rodrigo Mendes Diaz
Data      : 24/02/20
*/
Function EECDN400()
Local aLegendas := {}
Private oBrwDespNac, aRotina := MenuDef(), aSoftLock := {}
Private cCadastro := STR0001//"Despesas Nacionais"

    //Fecha os arquivos temporários da rotina de emabarque para não conflitar na integração via Execauto
    If IsInCallStack("EECAE100")
        AP104TrataWorks(.T., OC_EM)
    EndIf

    oBrwDespNac := FWmBrowse():New()
    oBrwDespNac:SetDescription(STR0001) //"Despesas Nacionais"
    oBrwDespNac:SetAlias("EET")
    oBrwDespNac:DisableDetails()
    //oBrwDespNac:SetOnlyFields(GetDefs("EET_CAPA_CAMPOS_MBROWSE"))
    oBrwDespNac:ForceQuitButton()
    oBrwDespNac:SetFilterDefault("EET_OCORRE == 'Q'")

    //Habilita Legenda
    If IsIntEnable("001") .And. !EasyGParam('MV_EEC0043',,.F.) .And. !AvFLags("EEC_LOGIX")
        aAdd(aRotina, {STR0002,"FA040Legenda",0,4}) //"Legenda"
        aLegendas := FA040Legenda("SE2")
        aEval(aLegendas, {|x| x[1] := "Posicione('SE2', 1, xFilial('SE2')+'EEC'+EET->EET_FINNUM, '" + x[1] + "')" })
        aEval(aLegendas, {|x| oBrwDespNac:AddLegend(x[1], x[2]) })
    EndIf
    //Habilita a exibição de visões e gráficos
    oBrwDespNac:SetMenuDef("EECDN400")
    oBrwDespNac:SetAttach( .T. )
    oBrwDespNac:SetViewsDefault(GetVisions())
    oBrwDespNac:CIDVIEWDEFAULT := '1' //View Despesa como Default
    oBrwDespNac:Activate()

    //Restaura os arquivos temporários da rotina de Embarque
    If IsInCallStack("EECAE100")
        AP104TrataWorks(.F., OC_EM)
    EndIf

Return Nil

/*
Função    : Menudef()
Objetivo  : Define as opções do Browse principal e permite incluir opções customizadas
*/
Static Function MenuDef()
Local aRotina := {}, aRotAdic

    ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.EECDN400' OPERATION 2 ACCESS 0 //'Visualizar'
    ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.EECDN400' OPERATION 3 ACCESS 0 //'Incluir'
    ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.EECDN400' OPERATION 4 ACCESS 0 //'Alterar'
    ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.EECDN400' OPERATION 5 ACCESS 0 //'Excluir'
    ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.EECDN400' OPERATION 9 ACCESS 0 //'Copiar'
    
    If EasyEntryPoint("DN400MNU")
        aRotAdic := ExecBlock("DN400MNU",.f.,.f.)
        If ValType(aRotAdic) == "A"
            aEval(aRotAdic,{|x| aAdd(aRotina,x) })
        EndIf
    EndIf

Return aRotina


/*
Função    : ModelDef()
Objetivo  : Define o modelo de dados MVC
*/
Static Function ModelDef()
Local oModel := MPFormModel():New("EECDN400",,{|oModel| Valida("ANTES_GRAVA", oModel) },{|oModel| CommitData(oModel) })
/* Estrutura de dados da tabela EET para a capa da despesa. Reúne as informações gerais da despesa que serão replicadas entre todos os embarques, 
   ou seja, todas as informações disponíveis exceto o número do embarque, valor e título/pedido de compras.
*/
Local oStruEET    := SetFormStruct("MODEL", "EET","CAPA")
//Dados da tabela EEB relacionadas ao Fornecedor da despesa, replicado entre todos os embarques onde a despesa for aplicada.
Local oStruEEB    := SetFormStruct("MODEL", "EEB")
/* Dados da tabela EET específicos da cada replicação da despesa entre os embarques (Embarque, valor, título/pedido de compras e Recno. */
Local oStruEETEmb := SetFormStruct("MODEL", "EET","EMB")
Local aRelEEBEET, aRelEMBEET
/* A estrutura principal do modelo será a tabela EET referente aos dados gerais, que será carregado de acordo com o registro da tabela EET posicionado 
   no Browse. */
oModel:AddFields("EET",, oStruEET)
oModel:SetPrimaryKey( {"EET_FILIAL", "EET_PEDIDO", "EET_OCORRE", "EET_CODAGE", "EET_TIPOAG", "EET_DESPES"})
//Configura os campos que não são replicados na cópia de despesa
oModel:GetModel("EET"):SetFldNoCopy({"EET_PEDIDO", "EET_DOCTO"})
// A estrutura da tabela EEB será carregada de acordo com o registro da tabela EET posicionado no Browse.
oModel:AddFields("EEB", "EET", oStruEEB,,,{|oModel, lCopy| GetEmpresa(oModel, lCopy) })
aRelEEBEET := {{"EEB_FILIAL","EET_FILIAL"},;
               {"EEB_PEDIDO","EET_PEDIDO"},;
               {"EEB_OCORRE","EET_OCORRE"},;
               {"EEB_CODAGE","EET_CODAGE"},;
               {"EEB_TIPOAG","EET_TIPOAG"}}
oModel:SetRelation("EEB",aRelEEBEET,EEB->(IndexKey()))

/* A estrutura da tabela EET referente aos embarques será carregada com todas as depesas que forem identificadas com as mesmas características da despesa
   principal selecionada no browse.*/
oModel:AddGrid("EMB", "EET", oStruEETEmb,,,,,{|oModel, lCopy| GetEmbarques(oModel, lCopy) })
oModel:GetModel("EMB"):SetUniqueLine({"EET_PEDIDO"})
oModel:SetPrimaryKey( {"EET_FILIAL", "EET_PEDIDO"})

aRelEMBEET := {{"EET_FILIAL","EET_FILIAL"},;
               {"EET_PEDIDO","EET_PEDIDO"}}
oModel:SetRelation("EMB",aRelEMBEET,EET->(IndexKey()))

oModel:SetDescription(STR0008) //"Despesa Nacional"

Return oModel

/*
Função    : GetEmpresa()
Objetivo  : Carrega o modelo de dados da despesa com a empresa da tabela EEB associada ao registro da tabela EET selecionado.
*/
Static Function GetEmpresa(oModel, lCopy)
Local aEmpresa := {}, i, oStruEEB
Local cPedido

    //Na cópia o modelo não carrega os campos chave, então considera o posicionado na tabela
    If !lCopy
        cPedido := oModel:GetModel():GetModel("EET"):GetValue("EET_PEDIDO")
    Else
        cPedido := EET->EET_PEDIDO
    EndIf

    EEB->(DbSetOrder(1))
    IF EEB->(DbSeek(xFilial()+cPedido+oModel:GetModel():GetModel("EET"):GetValue("EET_OCORRE")+oModel:GetModel():GetModel("EET"):GetValue("EET_CODAGE")+oModel:GetModel():GetModel("EET"):GetValue("EET_TIPOAG")))
        oStruEEB := oModel:GetModel():GetModel("EEB"):GetStruct("EEB")
        aEmpresa := {{}, If(lCopy, 0, EEB->(Recno())) }
        For i := 1 To Len(oStruEEB:aFields)
            aAdd(aEmpresa[1], EEB->&(oStruEEB:aFields[i][3]))
        Next
    EndIf

Return aEmpresa

/*
Função    : GetEmbarques()
Objetivo  : Carrega o modelo de dados das despesas por embarque (EMB) com todas as despesas que possuam as mesmas 
            características da despesa principal.
*/
Static Function GetEmbarques(oModel, lCopy)
Local oModelEET := oModel:GetModel():GetModel("EET")
Local oStruEETEmb := oModel:GetModel():GetModel("EMB"):GetStruct("EMB"), i
Local oView := FwViewActive()
Local oStruVEETEmb := oView:GetViewStruct("VIEW_EMB")
Local aEmbarques := {}
Local cQry := ""
Local cDocto

    //Na cópia o modelo não carrega os campos chave, então considera o posicionado na tabela
    If !lCopy
        cPedido := oModel:GetModel():GetModel("EET"):GetValue("EET_PEDIDO")
        cDocto := oModel:GetModel():GetModel("EET"):GetValue("EET_DOCTO")
    Else
        cPedido := EET->EET_PEDIDO
        cDocto := EET->EET_DOCTO
    EndIf

    /* Busca as despesas que possuírem as características abaixo iguais às da despesa carregada nos modelos principais (EET e EEB):
        Filial;
        Código da Despesa;
        Empresa (Fornecedor);
        Data;
        Documento.
    */
    //cQry += "Select EET_FILIAL, EET_PEDIDO, EET_VALORR, EET_SEQ, EET_FINNUM, EET_PREFIX, EET_PEDCOM, R_E_C_N_O_ EETREC From " + RetSqlName("EET") + " EET" - RMD - 24/09/21 - Retorna somente o Recno para posicionar o registro diretamente no EET
    cQry += "Select EET_FILIAL, EET_PEDIDO, EET_VALORR, EET_SEQ, EET_FINNUM, EET_PREFIX, EET_PEDCOM, R_E_C_N_O_ EETREC From " + RetSqlName("EET") + " EET"
    cQry += " Where EET.D_E_L_E_T_ = '' And EET.EET_FILIAL = '" + xFilial("EET") + "'"
    cQry += " AND EET.EET_DESPES = '" + oModelEET:GetValue("EET_DESPES") + "'"
    cQry += " AND EET.EET_OCORRE = 'Q'"
    //Se o documento da despesa principal estiver em branco, carrega somente ela (não considera outras despesas com o campo documento em branco).
    If !Empty(cDocto)
        cQry += " AND EET.EET_DOCTO = '" + cDocto + "'"
    Else
        cQry += " AND EET.EET_PEDIDO = '" + cPedido + "'"
        cQry += " AND EET.EET_SEQ = '" + oModelEET:GetValue("EET_SEQ") + "'"
    EndIf
    cQry += " AND EET.EET_CODAGE = '" + oModelEET:GetValue("EET_CODAGE") + "'"
    cQry += " AND EET.EET_DESADI = '" + DToS(oModelEET:GetValue("EET_DESADI")) + "'"
    DBUseArea(.T., "TopConn", TCGenQry(,, ChangeQuery(cQry)), "QRY", .T., .T.)

    While QRY->(!Eof())
        EET->(DbGoTo(QRY->EETREC))
        aAdd(aEmbarques, {If(lCopy, 0, QRY->EETREC), {}})
        For i := 1 To Len(oStruEETEmb:aFields)
            //RMD - 29/09/21 - Caso seja algum dos campos exibidos no grid inferior (dados por embarque) ou os campos chave, exceto os campos de título financeiro na cópia de lote, puxa os dados do registro correspondente no EET.
            If (oStruEETEmb:aFields[i][3] $ "EET_FILIAL, EET_PEDIDO, EET_VALORR") .Or. (!lCopy .And. oStruEETEmb:aFields[i][3] $ "EET_SEQ, EET_FINNUM, EET_PREFIX, EET_PEDCOM") .Or. (aScan(oStruVEETEmb:GetFields(), {|x| x[1] == oStruEETEmb:aFields[i][3] }) > 0 .And. !(oStruEETEmb:aFields[i][3] $ "EET_SEQ, EET_FINNUM, EET_PREFIX, EET_PEDCOM"))
                //aAdd(aEmbarques[Len(aEmbarques)][2], QRY->&(oStruEETEmb:aFields[i][3])) - RMD - 29/09/21 - Passa a buscar a informação diretamente da base
                aAdd(aEmbarques[Len(aEmbarques)][2], EET->&(oStruEETEmb:aFields[i][3]))
            //Na cópia, inicializa os campos de título com conteúdo em branco
            ElseIf lCopy .And. oStruEETEmb:aFields[i][3] $ "EET_SEQ, EET_FINNUM, EET_PREFIX, EET_PEDCOM"
                aAdd(aEmbarques[Len(aEmbarques)][2], Space(Avsx3(oStruEETEmb:aFields[i][3], AV_TAMANHO)))
            //Para os demais campos, puxa os dados do formulário (informações compartilhadas)
            Else
                aAdd(aEmbarques[Len(aEmbarques)][2], oModelEET:GetValue(oStruEETEmb:aFields[i][3]))
            EndIf
        Next
        QRY->(DbSkip())
    EndDo
    QRY->(DbCloseArea())

Return aEmbarques

/*
Função    : ViewDef()
Objetivo  : Define o modelo da View MVC
*/
Static Function ViewDef()
Local oStruEET    := SetFormStruct("VIEW", "EET","CAPA")
Local oStruEEB    := SetFormStruct("VIEW", "EEB")
Local oStruEETEmb := SetFormStruct("VIEW", "EET","EMB")

Local oView    := FWFormView():New()

    oView:SetModel(FWLoadModel("EECDN400"))

    //Exibe no cabeçalho os dados do Fornecedor
    oView:AddField("VIEW_EEB", oStruEEB, "EEB")
    //Exibe no meio os dados gerais da despesa
    oView:AddField("VIEW_EET", oStruEET, "EET")
    //Exibe no rodapé o grid dos dados das despesas por Embarque
    oView:AddGrid("VIEW_EMB", oStruEETEmb, "EMB")
    //Inclui o título somente no grid dos dados das despesas por Embarque. Nos demais, os títulos serão os informados nos agrupadores dos campos.
    oView:EnableTitleView('VIEW_EMB',STR0009) //'Embarques Associados'

    oView:CreateHorizontalBox("BOX_UP", 20)
    oView:CreateHorizontalBox("BOX_MIDDLE", 40)
    oView:CreateHorizontalBox("BOX_DOWN", 40)
    oView:SetOwnerView("VIEW_EEB", "BOX_UP")
    oView:SetOwnerView("VIEW_EET", "BOX_MIDDLE")
    oView:SetOwnerView("VIEW_EMB", "BOX_DOWN")

Return oView

/*
Função    : SetFormStruct()
Objetivo  : Cria as estruturas de dados dos Modelos e Views e carrega as características conforme as definições indicadas na função GetDefs.
Parâmetros: cTipo - MODEL/VIEW
            cAlias - Alias base da estrutura
            cKey - Chave para ser concatenada ao Alias nas chamadas da GetDefs
*/
Static Function SetFormStruct(cTipo, cAlias, cKey)
Local bSX3, aSX3, oStru
Default cKey := ""

    cKey := cAlias + If(!Empty(cKey), "_" + cKey, "")

    Do Case
        Case cTipo == "MODEL"
            If Len(aSX3 := GetDefs(cKey+"_CAMPOS_MODEL")) > 0
                bSX3 := {|x| If(aScan(aSX3, AllTrim(x)) > 0, .T., .F.) }
            EndIf
            oStru := FWFormStruct(1, cAlias, bSX3)
            aEval(GetDefs(cKey+"_REMOVER_MODEL"), {|x| If(oStru:HasField(x), oStru:RemoveField(x),) })
            aEval(GetDefs(cKey+"_METADADOS_MODEL"), {|x| oStru:SetProperty(x[1], x[2], x[3]) })
            aEval(GetDefs(cKey+"_ADICIONAR_MODEL"), {|x| oStru:AddField(GetSx3Cache(x, "X3_TITULO"), GetSx3Cache(x, "X3_DESCRIC"), x, GetSx3Cache(x, "X3_TIPO"), GetSx3Cache(x, "X3_TAMANHO"), GetSx3Cache(x, "X3_DECIMAL"),,,,.F.) })

        Case cTipo == "VIEW"
            If Len(aSX3 := GetDefs(cKey+"_CAMPOS_VIEW")) > 0
                bSX3 := {|x| If(aScan(aSX3, AllTrim(x)) > 0, .T., .F.) }
            EndIf
            oStru := FWFormStruct(2, cAlias, bSX3)
            aEval(GetDefs(cKey+"_REMOVER_VIEW"), {|x| If(oStru:HasField(x), oStru:RemoveField(x),) })
            aEval(GetDefs(cKey+"_METADADOS_VIEW"), {|x| If(oStru:HasField(x[1]), oStru:SetProperty(x[1], x[2], x[3]),) })
            aEval(GetDefs(cKey+"_ADICIONAR_GRUPOS"), {|x| oStru:AddGroup(x[1], x[2], x[3], x[4]) })
            aEval(GetDefs(cKey+"_REMOVE_FOLDERS"), {|x| If(x == "S", oStru:aFolders := {},) })
    EndCase

Return oStru

/*
Função    : GetDefs()
Objetivo  : Agrupa as características gerais das estruturas do Browse, Modelo e View. Chamada dinamicamente na função SetFormStruct
            Formato dos IDs: ALIAS + "_" + KEY + "_" + OPCAO
*/
Static Function GetDefs(cID)
Local lExclusiva:= FWModeAccess("EET") == "E"
Private aDefs     := {}

    Do Case
        Case cID == "EET_CAPA_CAMPOS_MBROWSE"
            aDefs := {"EET_PEDIDO", "EET_DESPES", "EET_DESCDE", "EET_DESADI", "EET_CODAGE", "EET_NOMAGE", "EET_DOCTO"}
            If AvFlags("EEC_LOGIX")
                aAdd(aDefs, "EET_DTVENC")
                aAdd(aDefs, "EET_PREFIX")
                aAdd(aDefs, "EET_FINNUM")
            ElseIf IsIntEnable("001")
                If EasyGParam('MV_EEC0043',,.F.) 
                    aAdd(aDefs, "EET_PEDCOM")
                Else
                    aAdd(aDefs, "EET_DTVENC")
                    aAdd(aDefs, "EET_FINNUM")
                    aAdd(aDefs, "EET_BAIXA")
                EndIf
            EndIf

        Case cID == "EET_CAPA_CAMPOS_MBROWSE_DESP"
            If lExclusiva
                aDefs := {"EET_FILIAL","EET_PEDIDO", "EET_DESPES", "EET_DESCDE", "EET_DESADI", "EET_CODAGE", "EET_NOMAGE", "EET_DOCTO"}
            ELse
                aDefs := {"EET_PEDIDO", "EET_DESPES", "EET_DESCDE", "EET_DESADI", "EET_CODAGE", "EET_NOMAGE", "EET_DOCTO"}
            EndIf
            If AvFlags("EEC_LOGIX")
                aAdd(aDefs, "EET_DTVENC")
                aAdd(aDefs, "EET_PREFIX")
                aAdd(aDefs, "EET_FINNUM")
            ElseIf IsIntEnable("001")
                If EasyGParam('MV_EEC0043',,.F.) 
                    aAdd(aDefs, "EET_PEDCOM")
                Else
                    aAdd(aDefs, "EET_DTVENC")
                    aAdd(aDefs, "EET_FINNUM")
                EndIf
            EndIf
            aDefs := AddCpoUser(aDefs,"EET",'1')
            
        Case cID == "EET_CAPA_CAMPOS_MBROWSE_FIN"
            If lExclusiva
                aDefs := {"EET_FILIAL","EET_PEDIDO", "EET_DESPES", "EET_DESCDE", "EET_DESADI", "EET_CODAGE", "EET_NOMAGE", "EET_DOCTO","EET_DTVENC","EET_FINNUM","EET_BAIXA"}
            Else
                aDefs := {"EET_PEDIDO", "EET_DESPES", "EET_DESCDE", "EET_DESADI", "EET_CODAGE", "EET_NOMAGE", "EET_DOCTO","EET_DTVENC","EET_FINNUM","EET_BAIXA"}
            EndIf
            aDefs := AddCpoUser(aDefs,"EET",'1')

        Case cID == "EET_CAPA_REMOVER_VIEW"
            aDefs := {"EET_TIPOAG", "EET_PEDIDO", "EET_VALORR", "EET_EVENT", "EET_NR_CON", "EET_DTDEMB", "EET_FORNEC", "EET_LOJAF", "EET_NOMAGE", "EET_PREFIX", "EET_TIPOAG", "EET_CODAGE", "EET_NOMAGE", "EET_FINNUM", "EET_PEDCOM","EET_BAIXA"}
            If AvFlags("EEC_LOGIX")
                aAdd(aDefs, "EET_NATURE")
                aAdd(aDefs, "EET_DTVENC")
            EndIf

        Case cID == "EET_CAPA_ADICIONAR_MODEL"
            aAdd(aDefs, "EET_SEQ")

        Case cID == "EET_CAPA_METADADOS_MODEL"
            aAdd(aDefs, {"EET_NOMAGE", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "")})
            aAdd(aDefs, {"EET_TIPOAG", MODEL_FIELD_OBRIGAT, .F.})
            aAdd(aDefs, {"EET_DESPES", MODEL_FIELD_OBRIGAT, .F.})
            aAdd(aDefs, {"EET_DESADI", MODEL_FIELD_OBRIGAT, .F.})
            aAdd(aDefs, {"EET_VALORR", MODEL_FIELD_OBRIGAT, .F.})
            aAdd(aDefs, {"EET_DESPES", MODEL_FIELD_OBRIGAT, .T.})
            aAdd(aDefs, {"EET_DESADI", MODEL_FIELD_OBRIGAT, .T.})
            aAdd(aDefs, {"EET_DOCTO" , MODEL_FIELD_OBRIGAT, .T.})
            aAdd(aDefs, {"EET_VALORR", MODEL_FIELD_OBRIGAT, .F.})
            aAdd(aDefs, {"EET_DESPES", MODEL_FIELD_WHEN,  {|| INCLUI }})
            aAdd(aDefs, {"EET_DESPES", MODEL_FIELD_VALID, {|a,b,c,d| FWInitCpo(a,b,c),lRet:=Valida("EET_DESPES"),FWCloseCpo(a,b,c,lRet),lRet  }})
            aAdd(aDefs, {"EET_DESADI", MODEL_FIELD_VALID, {|a,b,c,d| FWInitCpo(a,b,c),lRet:=Valida("EET_DESADI"),FWCloseCpo(a,b,c,lRet),lRet  }})
            aAdd(aDefs, {"EET_DOCTO", MODEL_FIELD_VALID,  {|a,b,c,d| FWInitCpo(a,b,c),lRet:=Valida("EET_DOCTO"),FWCloseCpo(a,b,c,lRet),lRet  }})
            aAdd(aDefs, {"EET_NATURE", MODEL_FIELD_VALID,  {|a,b,c,d| FWInitCpo(a,b,c),lRet:=Valida("EET_NATURE"),FWCloseCpo(a,b,c,lRet),lRet  }})
             
        Case cID == "EET_CAPA_METADADOS_VIEW"
            aAdd(aDefs, {"EET_DESPES", MVC_VIEW_GROUP_NUMBER, "01"})
            aAdd(aDefs, {"EET_DESCDE", MVC_VIEW_GROUP_NUMBER, "01"})
            aAdd(aDefs, {"EET_DESADI", MVC_VIEW_GROUP_NUMBER, "01"})
            aAdd(aDefs, {"EET_DOCTO" , MVC_VIEW_GROUP_NUMBER, "01"})
            aAdd(aDefs, {"EET_DTVENC" , MVC_VIEW_GROUP_NUMBER, "01"})
            aAdd(aDefs, {"EET_BASEAD" , MVC_VIEW_GROUP_NUMBER, "02"})
            aAdd(aDefs, {"EET_PAGOPO" , MVC_VIEW_GROUP_NUMBER, "02"})
            aAdd(aDefs, {"EET_RECEBE" , MVC_VIEW_GROUP_NUMBER, "02"})
            aAdd(aDefs, {"EET_REFREC" , MVC_VIEW_GROUP_NUMBER, "02"})
            aAdd(aDefs, {"EET_BASEAD" , MVC_VIEW_GROUP_NUMBER, "02"})
            aAdd(aDefs, {"EET_DESPES" , MVC_VIEW_ORDEM, "01"})
            aAdd(aDefs, {"EET_DESCDE" , MVC_VIEW_ORDEM, "02"})
            aAdd(aDefs, {"EET_NATURE" , MVC_VIEW_GROUP_NUMBER, "02"})

        Case cID == "EET_CAPA_ADICIONAR_GRUPOS"
            aAdd(aDefs, {"01", STR0010, "01", 2}) //"Dados da Despesa"
            aAdd(aDefs, {"02", STR0011, "01", 2}) //"Dados do Pagamento"

        Case cID == "EET_CAPA_REMOVE_FOLDERS"
            aAdd(aDefs, "S")

        Case cID == "EEB_REMOVER_MODEL"
            aDefs := {"EEB_PEDIDO", "EEB_TXCOMI", "EEB_TIPCOM", "EEB_TIPCVL", "EEB_VALCOM", "EEB_REFAGE", "EEB_TOTCOM", "EEB_FORNEC", "EEB_LOJAF", "EEB_CONTR"}

        Case cID == "EEB_REMOVER_VIEW"
            aDefs := GetDefs("EEB_REMOVER_MODEL")

        Case cID == "EEB_METADADOS_MODEL"
            aAdd(aDefs, {"EEB_OCORRE", MODEL_FIELD_OBRIGAT, .F.})
            aAdd(aDefs, {"EEB_CODAGE", MODEL_FIELD_WHEN, {|| INCLUI }})
            aAdd(aDefs, {"EEB_CODAGE", MODEL_FIELD_VALID, {|a,b,c,d| FWInitCpo(a,b,c),lRet:=Valida("EEB_CODAGE"),FWCloseCpo(a,b,c,lRet),lRet  }})

        Case cID == "EEB_METADADOS_VIEW"
            aAdd(aDefs, {"EEB_CODAGE", MVC_VIEW_GROUP_NUMBER, "01"})
            aAdd(aDefs, {"EEB_TIPOAG", MVC_VIEW_GROUP_NUMBER, "01"})
            aAdd(aDefs, {"EEB_NOME", MVC_VIEW_GROUP_NUMBER, "01"})
            aAdd(aDefs, {"EEB_TIPOAG", MVC_VIEW_CANCHANGE, .F.})
            aAdd(aDefs, {"EEB_NOME", MVC_VIEW_CANCHANGE, .F.})

        Case cID == "EEB_ADICIONAR_GRUPOS"
            aAdd(aDefs, {"01", STR0012, "01", 2}) //"Dados da Empresa"

        Case cID == "EET_EMB_ADICIONAR_MODEL"
            aAdd(aDefs, "EET_SEQ")

        Case cID == "EET_EMB_CAMPOS_VIEW"
            aDefs := {"EET_FILIAL", "EET_PEDIDO", "EET_VALORR", "EET_SEQ"}
            If AvFlags("EEC_LOGIX")
                aAdd(aDefs, "EET_PREFIX")
                aAdd(aDefs, "EET_FINNUM")
            ElseIf IsIntEnable("001")
                If EasyGParam('MV_EEC0043',,.F.) 
                    aAdd(aDefs, "EET_PEDCOM")
                Else
                    aAdd(aDefs, "EET_FINNUM")
                EndIf
            EndIf

        Case cID == "EET_EMB_METADADOS_MODEL"
            aAdd(aDefs, {"EET_NOMAGE", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "")})
            aAdd(aDefs, {"*", MODEL_FIELD_OBRIGAT, .F.})
            aAdd(aDefs, {"EET_PEDIDO", MODEL_FIELD_OBRIGAT, .T.})
            aAdd(aDefs, {"EET_VALORR", MODEL_FIELD_OBRIGAT, .T.})
            aAdd(aDefs, {"EET_PEDIDO", MODEL_FIELD_VALID, {|a,b,c,d| FWInitCpo(a,b,c),lRet:=Valida("EET_PEDIDO"),FWCloseCpo(a,b,c,lRet),lRet  }})
            aAdd(aDefs, {"EET_VALORR", MODEL_FIELD_VALID, {|a,b,c,d| FWInitCpo(a,b,c),lRet:=Valida("EET_VALORR"),FWCloseCpo(a,b,c,lRet),lRet  }})
            aAdd(aDefs, {"EET_PEDIDO", MODEL_FIELD_WHEN, {|oModel| Valida("WHEN_EET_PEDIDO", oModel) }})

        Case cID == "EET_EMB_METADADOS_VIEW"
            aAdd(aDefs, {"EET_PEDIDO", MVC_VIEW_CANCHANGE, .T.})
            If AvFlags("EEC_LOGIX")
                aAdd(aDefs, {"EET_PREFIX" , MVC_VIEW_GROUP_NUMBER, "02"})
                aAdd(aDefs, {"EET_FINNUM" , MVC_VIEW_GROUP_NUMBER, "02"})
                aAdd(aDefs, {"EET_PREFIX" , MVC_VIEW_CANCHANGE, .F.})
                aAdd(aDefs, {"EET_FINNUM" , MVC_VIEW_CANCHANGE, .F.})
            ElseIf IsIntEnable("001")
                If EasyGParam('MV_EEC0043',,.F.) 
                    aAdd(aDefs, {"EET_PEDCOM" , MVC_VIEW_GROUP_NUMBER, "02"})
                    aAdd(aDefs, {"EET_PEDCOM" , MVC_VIEW_CANCHANGE, .F.})
                Else
                    aAdd(aDefs, {"EET_FINNUM" , MVC_VIEW_GROUP_NUMBER, "02"})
                    aAdd(aDefs, {"EET_FINNUM" , MVC_VIEW_CANCHANGE, .F.})
                EndIf
            EndIf

    EndCase

    //RMD - 29/09/21 - Possibilita alterar definições da rotina via ponto de entrada (alterando o conteúdo da variável aDefs)
    If EasyEntryPoint("DN400DEFS")
        ExecBlock("DN400DEFS", .F., .F., cID)
    EndIf

Return aDefs

/*
Função    : Valida()
Objetivo  : Validações gerais do Modelo
*/
Static Function Valida(cCampo, oModel)
Local lRet := .T., i, oModelEMB, oModelEET, oModelEEB, cQry := ""
Default oModel := FwModelActive()

    oModelEMB := oModel:GetModel():GetModel("EMB")
    oModelEET := oModel:GetModel():GetModel("EET")
    oModelEEB := oModel:GetModel():GetModel("EEB")

    Do Case
        Case cCampo == "EEB_CODAGE"
            lRet := ExistCpo("SY5", oModelEEB:GetValue("EEB_CODAGE")) .And. Valida("EET_DOCTO")

        Case cCampo == "EET_DESPES"
            lRet := ExistCpo("SYB", oModelEET:GetValue("EET_DESPES")) .And. Valida("EET_DOCTO")

        Case cCampo == "EET_DESADI"
            lRet := Valida("EET_DOCTO")

        Case cCampo == "EET_PEDIDO"
            If (lRet := ExistCpo("EEC", oModelEmb:GetValue("EET_PEDIDO", oModelEmb:GetLine())))
                For i := 1 To oModelEmb:GetQtdLine()
                    If i <> oModelEmb:GetLine() .And. oModelEmb:GetValue("EET_PEDIDO", i) == oModelEmb:GetValue("EET_PEDIDO", oModelEmb:GetLine())
                        EasyHelp(STR0014, STR0013) //"Embarque já informado."###"Aviso"
                        lRet := .F.
                    EndIf
                Next
            EndIf

        Case cCampo == "EET_DOCTO"
            If !Empty(oModelEET:GetValue("EET_DOCTO")) .And. !Empty(oModelEET:GetValue("EET_DESADI")) .And. !Empty(oModelEET:GetValue("EET_DESPES")) .And. !Empty(oModelEEB:GetValue("EEB_CODAGE"))
                cQry += "Select R_E_C_N_O_ EETREC From " + RetSqlName("EET") + " EET"
                cQry += " Where EET.D_E_L_E_T_ = '' And EET.EET_FILIAL = '" + xFilial("EET") + "'"
                cQry += " AND EET.EET_OCORRE = 'Q'"
                cQry += " AND EET.EET_DESPES = '" + oModelEET:GetValue("EET_DESPES") + "'"
                cQry += " AND EET.EET_CODAGE = '" + oModelEEB:GetValue("EEB_CODAGE") + "'"
                cQry += " AND EET.EET_DESADI = '" + DToS(oModelEET:GetValue("EET_DESADI")) + "'"
                cQry += " AND EET.EET_DOCTO = '" + oModelEET:GetValue("EET_DOCTO") + "'"
                For i := 1 To oModelEMB:GetQtdLine()
                    If oModelEMB:GetDataID(i) > 0
                        cQry += " AND (EET.EET_PEDIDO <> '" + oModelEmb:GetValue("EET_PEDIDO", i) + "'"
                        cQry += " OR EET.EET_SEQ <> '" + oModelEmb:GetValue("EET_SEQ", i) + "')"
                    EndIf
                Next
                DBUseArea(.T., "TopConn", TCGenQry(,, ChangeQuery(cQry)), "QRY", .T., .T.)
                If !QRY->(Bof() .And. Eof())
                    EasyHelp(STR0015, STR0013) //"Já existem despesas cadastradas para a mesma Empresa, Código de Despesa, Data e Número de Documento."###"Aviso"
                    lRet := .F.
                EndIf
                QRY->(DbCloseArea())
            EndIf

        Case cCampo == "EET_VALORR"
            lRet := Positivo()
        
        Case cCampo == "ANTES_GRAVA"
            lRet := Valida("EET_DOCTO") .And. ReservaRegistros(oModel)

        Case cCampo == "WHEN_EET_PEDIDO"
            If oModel:GetOperation() <> INCLUIR .And. oModelEmb:GetDataID() > 0//Não permite editar o número do embarque após a inclusão
                lRet := .F.
            EndIf
        
        Case cCampo == "EET_NATURE"
            lRet := Vazio() .Or. ExistCpo("SED", oModelEET:GetValue("EET_NATURE"))
        
    EndCase

Return lRet

/*
Função    : ReservaRegistros()
Objetivo  : Efetua o Softlock dos processos de embarque que serão atualizados. Caso o processo esteja travado, exibe mensagem informando 
            quais são os processos e perguntando se deseja aguardar ou cancelar.
*/
Static Function ReservaRegistros(oModel)
Local aOrd := SaveOrd({"EEC"})
Local aSoftLock := {}, aErroTrava := {}
Local lAborta := .F.
Local cMensagem
Local oEEB := oModel:GetModel():GetModel("EEB")
Local oEET := oModel:GetModel():GetModel("EET")
Local oEMB := oModel:GetModel():GetModel("EMB")
Local lAll := .F., i

    If oModel:GetOperation() == EXCLUIR .Or. oModel:GetOperation() == INCLUIR .Or. (oModel:GetOperation() == ALTERAR .And. (oEEB:IsModified() .Or. oEET:IsModified()))
        lAll := .T.
    EndIf

    EEC->(DbSetOrder(1))
    For i := 1 To oEMB:GetQtdLine()
        //Verifica para todas as linhas se o Embarque irá sofrer atualização
        If lAll .Or. oEMB:IsUpdated(i) .Or. oEMB:IsInserted(i) .Or. oEMB:IsDeleted(i)
            If oEMB:IsDeleted(i) .And. (oModel:GetOperation() == EXCLUIR .Or. oEmb:GetDataId(i) == 0)
                Loop
            EndIf
            //Caso positivo, tenta o Softlock
            If EEC->(DbSeek(xFilial()+oEMB:GetValue("EET_PEDIDO", i)))
                If !EEC->(SimpleLock() .And. SoftLock("EEC"))
                    aAdd(aErroTrava, {"EEC", EEC->(Recno()), STR0016 + AllTrim(EEC->EEC_FILIAL) + STR0017 + AllTrim(EEC->EEC_PREEMB)}) // "Filial: " // " Embarque: "
                Else
                    aAdd(aSoftLock, {"EEC", EEC->(Recno())})
                EndIf
            EndIf
        EndIf
    Next

    While !lAborta .And. Len(aErroTrava) > 0
        cMensagem := STR0018 + ENTER //"O seguintes processos de embarque estão bloqueados por outro acesso ou usuário:"
        aEval(aErroTrava, {|x| cMensagem += x[3] + ENTER })
        cMensagem += STR0019 //"Deseja tentar novamente? Caso contrário a operação será cancelada."
        If !(lAborta := !EECView(cMensagem, STR0013 )) //"Aviso"
                i := 1
                While i <= Len(aErroTrava)
                    EEC->(DbGoTo(aErroTrava[i][2]))
                    If EEC->(SimpleLock() .And. SoftLock("EEC"))
                            aAdd(aSoftLock, {"EEC", EEC->(Recno())})
                            aDel(aErroTrava, i)
                            aSize(aErroTrava, Len(aErroTrava)-1)
                            i -= 1
                    EndIf
                    i++
                EndDo
        EndIf
    EndDo

    If lAborta
        //Se o usuário abortar a execução, destrava os embarques que haviam sido travados.
        For i := 1 To Len(aSoftLock)
            EEC->(DbGoTo(aSoftLock[i][2]))
            If EEC->(IsLocked())
                EEC->(MsUnlock())
            EndIf
        Next
        aSoftLock := {}
        EasyHelp(STR0020, STR0013) //"Gravação cancelada pelo usuário."###"Aviso"
    EndIf

RestOrd(aOrd, .T.)
Return !lAborta

/*
Função    : CommitData()
Objetivo  : Efetua a gravação dos dados das despesas por meio de MsExecAuto na rotina de Emabarque.
*/
Static Function CommitData(oModel)
Local lRet := .T.
Local oProgress := EasyProgress():New()
Local oEEB := oModel:GetModel():GetModel("EEB")
Local oEET := oModel:GetModel():GetModel("EET")
Local oEMB := oModel:GetModel():GetModel("EMB")
Local lAll := .F., i
Local aEmbarques := {}
Local aOrd := SaveOrd("EET")
Local cMsgErro := ""
Private aEEC

    /* Se for uma exclusão, inclusão ou alteração dos dados gerais (Empresa ou dados gerais da Despesa), atualiza todas as depesas de todos os
       embarques associados. Caso negativo, atualiza somente as despesas dos embarques que sofreram alteração.
    */
    If oModel:GetOperation() == EXCLUIR .Or. oModel:GetOperation() == INCLUIR .Or. (oModel:GetOperation() == ALTERAR .And. (oEEB:IsModified() .Or. oEET:IsModified()))
        lAll := .T.
    EndIf

    For i := 1 To oEMB:GetQtdLine()
        If lAll .Or. oEMB:IsUpdated(i) .Or. oEMB:IsInserted(i) .Or. oEMB:IsDeleted(i)
            //Se a linha foi deletada e ela ainda não existia na base ou é uma exclusão do modelo, despreza o registro.
            If oEMB:IsDeleted(i) .And. (oModel:GetOperation() == EXCLUIR .Or. oEmb:GetDataId(i) == 0)
                Loop
            EndIf
            
            //Prepara os dados para atualizar a despesa na rotina de embarque via MsExecAuto
            aEEC := {}
            //Dados da Chave do Embarque
            aAdd(aEEC, {"EEC", {{"EEC_FILIAL", xFilial("EEC"), Nil}, {"EEC_PREEMB", oEMB:GetValue("EET_PEDIDO", i), Nil}}})
            //Dados da Despesa
            aAdd(aEEC, {"EET", {{}}})
            aAdd(aEEC[Len(aEEC)][2][1], {"EET_CODAGE", oEEB:GetValue("EEB_CODAGE"), Nil})//Carrega a empresa do modelo de dados do EEB
            aAdd(aEEC[Len(aEEC)][2][1], {"EET_DESPES", oEET:GetValue("EET_DESPES"), Nil})//Carrega os dados gerais do modelo do EET geral (CAPA)
            aAdd(aEEC[Len(aEEC)][2][1], {"EET_DESCDE", oEET:GetValue("EET_DESCDE"), Nil})
            aAdd(aEEC[Len(aEEC)][2][1], {"EET_DESADI", oEET:GetValue("EET_DESADI"), Nil})
            aAdd(aEEC[Len(aEEC)][2][1], {"EET_BASEAD", oEET:GetValue("EET_BASEAD"), Nil})
            aAdd(aEEC[Len(aEEC)][2][1], {"EET_DTVENC", oEET:GetValue("EET_DTVENC"), Nil})
            aAdd(aEEC[Len(aEEC)][2][1], {"EET_DOCTO" , oEET:GetValue("EET_DOCTO"), Nil})
            aAdd(aEEC[Len(aEEC)][2][1], {"EET_PAGOPO", oEET:GetValue("EET_PAGOPO"), Nil})
            aAdd(aEEC[Len(aEEC)][2][1], {"EET_RECEBE", oEET:GetValue("EET_RECEBE"), Nil})
            aAdd(aEEC[Len(aEEC)][2][1], {"EET_REFREC", oEET:GetValue("EET_REFREC"), Nil})
            aAdd(aEEC[Len(aEEC)][2][1], {"EET_NATURE", oEET:GetValue("EET_NATURE"), Nil})
            aAdd(aEEC[Len(aEEC)][2][1], {"EET_VALORR", oEMB:GetValue("EET_VALORR", i), Nil})//Carrega o valor do modelo de dados do Grid das despesas por embarque (EMB)
            If oModel:GetOperation() <> INCLUIR .And. !oEMB:IsInserted(i)//Se for alteração, deve enviar o campo EET_SEQ que é a chave única da despesa no Embarque
                aAdd(aEEC[Len(aEEC)][2][1], {"EET_SEQ", oEMB:GetValue("EET_SEQ", i), Nil})
                If oModel:GetOperation() == EXCLUIR .Or. oEMB:IsDeleted(i)//Se for exclusão da despesa ou da linha, indica para exclusão no Embarque
                    aAdd(aEEC[Len(aEEC)][2][1], {"AUTDELETA", "S", Nil})
                EndIf
            EndIf
            //RMD - 29/09/21 - Possibilita a customização dos valores a serem integrados para cada embarque, por meio da edição da variável aEMB
            If EasyEntryPoint("DN400INTEMB")
                ExecBlock("DN400INTEMB", .F., .F., {oEEB, oEET, oEMB, i})
            EndIf
            aAdd(aEmbarques, aEEC)
        EndIf
    Next

    If Len(aEmbarques) > 0
        If Len(aEmbarques) > 1
            //Se houver mais de um emabarque, exibe barra de progresso da execução do MsExecAuto.
            oProgress:SetProcess({|| lRet := GravaEmbarques(aEmbarques, oProgress,@cMsgErro) }, STR0021 ) //"Executando atualização em lote dos processos de Embarque."
            oProgress:Init()
        Else
            //Se for somente um Embarque, executa sem barra de progresso e utiliza as mensagem da própria rotina de Embarque no MsAguarde.
            MsAguarde({|| lRet := GravaEmbarques(aEmbarques,,@cMsgErro) }, STR0022 ) //"Atualizando processo de Embarque."
        EndIf
    EndIf

    oModel:SetErrorMessage("EET",,,,STR0013,cMsgErro,"") //"Aviso"
    RestOrd(aOrd, .T.)
    If EET->(Deleted())
        EET->(DbSkip(-1))
    EndIf
Return lRet

/*
Função    : GravaEmbarques()
Objetivo  : Atualiza as despesas nos seus respectivos processos de embarque via MsExecAuto
*/
Static Function GravaEmbarques(aEmbarques, oProgress,cMsgErro)
Local i, nPos1, nPos2
Local cErros := "", cMensagem := "", cEmbarque := ""
Local lRet
Local nErroCount := 0
Local nTotProc
Local nTotErro
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.//Indica que todas as mensagens de help devem ser direcionadas para o arquivo de log
Private lELinkBlind := .T.//Desliga a janela do EasyLink
Private lELinkAuto := .T.//Indica para o EasyLink que o mesmo está sendo executado em uma rotina automática e que os erros devem ser retornados por EasyHelp


    If oProgress <> Nil
        oProgress:SetRegua(Len(aEmbarques))
    EndIf
    nTotProc := Len(aEmbarques)
    For i := 1 To nTotProc
        lMsErroAuto := .F.
        lProcErro := .F.
        If (nPos1 := aScan(aEmbarques[i], {|x| x[1] == "EEC" })) > 0 .And. (nPos2 := aScan(aEmbarques[i][nPos1][2], {|x| x[1] == "EEC_PREEMB" })) > 0
            cEmbarque := AllTrim(aEmbarques[i][nPos1][2][nPos2][2])
        EndIf
        MsExecAuto({|x,y| EECAE100(,x,y)}, ALTERAR, aEmbarques[i])
        If lMsErroAuto
            nTotErro++
            EEC->(DbSetOrder(1))
            If EEC->(DbSeek(xFilial()+cEmbarque))//Retira o Softlock
                EEC->(MsUnlock())
            EndIf
            nErroCount++
            //Caso tenha ocorrido erro informa o embarque onde ocorreu o erro e as mensagens retornadas
            If nErroCount > 1
                cErros += SEPARADOR
            EndIf
            cErros += StrTran( STR0023 , "XXX", AllTrim(Str(nErroCount))) + ENTER //"Erro XXX:"
            //Recupera os erros da rotina automática (caso existam)
            cErros += StrTran(STR0024, "XXX", cEmbarque) + ENTER //"Não foi possível atualizar a despesa no Embarque 'XXX': "
            If ValType(NomeAutoLog()) == "C"
                cErros += MemoRead(NomeAutoLog())
                //Apaga o arquivo de log para que não seja concatenado no próximo erro
                FErase(NomeAutoLog())
            Else
                cErros += STR0025 + ENTER //"A rotina não retornou uma mensagem de erro específica."
            EndIf
        EndIf
        //Incrementa a regua de processamento
        If oProgress <> Nil
            oProgress:IncRegua()
        EndIf
    Next
    lRet := Len(aEmbarques) <> nErroCount
    If nErroCount > 0
        cMensagem := STR0026 + ENTER + ENTER //"Atenção: Ocorreram erros na operação."
        If nErroCount > 1
                cMensagem += StrTran(STR0027 , "XXX", AllTrim(Str(nErroCount)) + " de " + AllTrim(Str(Len(aEmbarques)))) + ENTER + ENTER //"Das despesas relacionadas XXX não puderam ser atualizadas devido aos erros abaixo: "
        Else
                cMensagem += STR0028 + ENTER + ENTER //"Não foi possível atualizar a despesa devido ao erro abaixo:"
        EndIf
        cMsgErro := STR0029 + Alltrim(Str(nTotProc)) +ENTER + ENTER //"Total de Processos: "
        cMsgErro += STR0030 + Alltrim(Str(nTotProc-nErroCount)) + ENTER //"Integrados:     "
        cMsgErro += STR0031 + Alltrim(Str(nErroCount)) //"Não Integrados: "
        EECView(cMensagem + cErros, STR0032) //"Atenção"
    EndIf
    If !lRet
        EasyHelp(STR0033,STR0013) //"Gravação cancelada."### "Aviso"
    EndIf

Return lRet


/*
Função     : GetVisions()
Objetivo   : Retorna as visões definidas para o Browse
*/
Static Function GetVisions()
Local oDSView
Local aVisions := {}
Local aColunas := {}
Local aContextos := {{STR0034,"_DESP"}} //"Despesa"
Local i

If IsIntEnable("001") .And. !EasyGParam('MV_EEC0043',,.F.) .And. !AvFLags("EEC_LOGIX")
    aAdd(aContextos,{STR0035,"_FIN"}) //"Financeiro"
EndIf

For i := 1 To Len(aContextos)

    aColunas := GetDefs("EET_CAPA_CAMPOS_MBROWSE"+aContextos[i][2])

    oDSView := FWDSView():New()
    oDSView:SetName(AllTrim(Str(i)) + "-" + aContextos[i][1])
    oDSView:SetPublic(.T.)
    oDSView:SetCollumns(aColunas)
    oDSView:SetOrder(1)
    oDSView:SetID(AllTrim(Str(i)))
    If aContextos[i][1] == STR0035 //"Financeiro"
        oDsView:SetLegend(.T.)
    Else
        oDsView:SetLegend(.F.)
    EndIf
    aAdd(aVisions, oDSView)
Next

Return aVisions

/*
Função     : DN400INIBRW()
Objetivo   : Utilizada no inicializador padrão do browse para o campo EET_BAIXA
*/
Function DN400INIBRW()
Local dRet := cToD("")

If !Empty(EET->EET_FINNUM)
    dRet := Posicione("SE2",1,xFilial("SE2") + AvKey("EEC","E2_PREFIXO") + AvKey(EET->EET_FINNUM,"E2_NUM") + AvKey("","E2_PARCELA"),"E2_BAIXA")
EndIf

Return dRet
