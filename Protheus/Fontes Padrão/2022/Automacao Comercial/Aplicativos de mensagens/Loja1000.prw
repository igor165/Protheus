#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"
#include "loja1000.ch"

/*/{Protheus.doc} SendMessage
    Metodo responsavel pelo envio de mensagem para o telegram
    @author Lucas Novais (lnovais)
    @since 29/06/2020
    @version 1.0
/*/

Function Loja1000()
    Local oBrowse := FwLoadBrw("Loja1000")
    oBrowse:Activate()
Return (NIL)

/*/{Protheus.doc} BrowseDef
    Função estatica responsavel pelas informações pertinentes ao Browse
    @author Lucas Novais (lnovais)
    @since 29/06/2020
    @version 1.0
/*/

Static Function BrowseDef()
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("MHT")
    oBrowse:SetDescription("Funcionalidades")
    oBrowse:SetMenuDef("Loja1000")
Return (oBrowse)

/*/{Protheus.doc} BrowseDef
    Função estatica responsavel pelas informações pertinentes Menu
    @author Lucas Novais (lnovais)
    @since 29/06/2020
    @version 1.0
/*/

Static Function MenuDef()
Return FWMVCMenu("Loja1000")

/*/{Protheus.doc} BrowseDef
    Função estatica responsavel pelas informações pertinentes modelo de dados (regra de negocio)
    @author Lucas Novais (lnovais)
    @since 29/06/2020
    @version 1.0
/*/

Static Function ModelDef()
    Local bPost    := {|oGridModel|LjBValid(oGridModel)}           // -- Bloco utilizado na validação do modelo
    Local oModel   := MPFormModel():New("Loja1000_Model",,bPost)   // -- Criação do modelo
    // -- Sub's Modulos e modulo principal
    Local oStruMHT := FwFormStruct(1, "MHT")
    Local oStruMHU := FwFormStruct(1, "MHU")
    Local oStruMHV := FwFormStruct(1, "MHV")

    // -- Altero todos os campos da estrutura oStruMHV para não obrigatorios
    oStruMHV:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

    // -- Definição dos tipos de submodelos, sendo eles Fiels ou grids
    oModel:AddFields("MHTMASTER", NIL         , oStruMHT)
    oModel:AddGrid("MHUDETAIL"  , "MHTMASTER" , oStruMHU)
    oModel:AddGrid("MHVDETAIL"  , "MHUDETAIL" , oStruMHV)

    // -- Define a relação entre os modelos  
    oModel:SetRelation("MHUDETAIL", {{"MHU_FILIAL", "FwXFilial('MHT')"},{"MHU_IDFUNC","MHT_IDFUNC"}}, MHU->(IndexKey(1)))
    oModel:SetRelation("MHVDETAIL", {{"MHV_FILIAL", "FwXFilial('MHU')"},{"MHV_IDGRP","MHU_IDGRP"}},   MHV->(IndexKey(1)))

    // -- Indica que o modelo MHVDETAIL é opcional
    oModel:GetModel( 'MHVDETAIL' ):SetOptional(.T.)
    
    // -- Descrição dos modelos e submodelos
    oModel:SetDescription(STR0001)                          // -- "Aplicativo de mensagens"
    oModel:GetModel("MHTMASTER"):SetDescription(STR0002)    // -- "Funcionalidades"
    oModel:GetModel("MHUDETAIL"):SetDescription(STR0003)    // -- "Grupos"
    oModel:GetModel("MHVDETAIL"):SetDescription(STR0004)    // -- "Usuarios"

Return (oModel)

/*/{Protheus.doc} BrowseDef
    Função estatica responsavel pelas informações pertinentes View, contendo s informações visuais utilizando o modelo de dados (ModelDef)
    @author Lucas Novais (lnovais)
    @since 29/06/2020
    @version 1.0
/*/

Static Function ViewDef()
    Local oView    := FwFormView():New()
    Local oStruMHT := FwFormStruct(2, "MHT")
    Local oStruMHU := FwFormStruct(2, "MHU")
    Local oStruMHV := FwFormStruct(2, "MHV")
    Local oModel   := FwLoadModel("Loja1000") // -- Modelo de dados

    // -- Removo so campos abaixo da exibição
    oStruMHU:RemoveField("MHU_IDFUNC")
    oStruMHU:RemoveField("MHU_IDGRP")
    oStruMHV:RemoveField("MHV_IDFUNC")
    oStruMHV:RemoveField("MHV_IDGRP")
    oStruMHV:RemoveField("MHV_ID")

    // -- Alteração de algumas propiedades apenas para visualização
    oStruMHT:SetProperty("MHT_IDFUNC", MVC_VIEW_CANCHANGE , .F.)
    oStruMHT:SetProperty("MHT_FUNC", MVC_VIEW_TITULO , STR0005) // -- "Funcionalidade"

    // -- Modelo da viwe
    oView:SetModel(oModel)

    // -- Criação da estrutura visual dos campos 
    oView:AddField("VIEW_MHT", oStruMHT, "MHTMASTER")

    // -- Criação das estrutas vizuais dos grids
    oView:AddGrid("VIEW_MHU", oStruMHU, "MHUDETAIL")
    oView:AddGrid("VIEW_MHV", oStruMHV, "MHVDETAIL")

    // -- Crio e dimenciono as "caixa" aonde os Grids e field serão exibidos
    oView:CreateHorizontalBox("EMCIMA"  , 20)
    oView:CreateHorizontalBox("MEIO"    , 40)
    oView:CreateHorizontalBox("EMBAIXO" , 40)

    // -- Relaciono os box com as estruturas vizuais
    oView:SetOwnerView("VIEW_MHT", "EMCIMA")
    oView:SetOwnerView("VIEW_MHU", "MEIO")
    oView:SetOwnerView("VIEW_MHV", "EMBAIXO")

    // -- Define os titulos das subviwers
    oView:EnableTitleView("VIEW_MHT", STR0006)      // -- "Funcionalidade"
    oView:EnableTitleView("VIEW_MHU", STR0007 , 0)  // -- "Grupos de mensagem"
    oView:EnableTitleView("VIEW_MHV", STR0008 , 0)  // -- "Usuarios X Grupo"
Return (oView)

/*/{Protheus.doc} BrowseDef
    Função estatica responsavel pelas validação do modelo, utilizo para realizar a gravação de um campo não relacionado nos demias modulos
    @author Lucas Novais (lnovais)
    @since 29/06/2020
    @version 1.0
    @param oGridModel, Object, Objeto contendo modelo
/*/

Static Function LjBValid(oModel)
    Local oModelMHT  := oModel:GetModel("MHTMASTER")
    Local oModelMHU  := oModel:GetModel("MHUDETAIL")
    Local oModelMHV  := oModel:GetModel("MHVDETAIL")
    Local nOperation := oModel:GetOperation()
    Local nX         := 0
    Local nY         := 0

    If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
        For nX := 1 To oModelMHU:Length()
            oModelMHU:GoLine(nX)
            oModelMHU:Setvalue("MHU_IDFUNC",oModelMHT:GetValue("MHT_IDFUNC"))

            For nY := 1 To oModelMHV:Length()
                oModelMHV:GoLine(nY)
                oModelMHV:Setvalue("MHV_IDFUNC",oModelMHT:GetValue("MHT_IDFUNC"))
            Next
        Next
    EndIf 

Return .T.
