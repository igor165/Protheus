#include "protheus.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Browse Termo de Consentimento de Dados Pessoais

@author V.Alves
@version Protheus 12
@since 26/04/2021
/*/
//-------------------------------------------------------------------
Function PLSA260B6V()

    Local oBrowse := Nil

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('B6V')
    oBrowse:SetDescription('Termo de Consentimento de Dados Pessoais')    
    oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Ações do MenuDef
@author V.Alves
@version Protheus 12
@since 26/04/2021
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.PLSA260B6V' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.PLSA260B6V' OPERATION 8 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Estrutura das tabelas e relacionamento do termo de consentimento
@author V.Alves
@version Protheus 12
@since 26/04/2021
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oModel := Nil
    Local oStruB6V := FWFormStruct(1,"B6V")
    Local oStruB6W := FWFormStruct(1,"B6W")
    Local cProtocolo := ""

	oModel := MPFormModel():New("PLSA260B6V")
	
    oStruB6W:AddField( AllTrim(''),;  // [01] C Titulo do campo
                       AllTrim(''),;  // [02] C ToolTip do campo
                       'B6W_LEGEND',; // [03] C identificador (ID) do Field
                       'C',;          // [04] C Tipo do campo
                       50,;           // [05] N Tamanho do campo
                       0,;            // [06] N Decimal do campo
                       NIL,;          // [07] B Code-block de validação do campo
                       NIL,;          // [08] B Code-block de validação When do campo
                       NIL,;          // [09] A Lista de valores permitido do campo
                       NIL,;          // [10] L Indica se o campo tem preenchimento obrigatório
                       { || Iif(B6W->B6W_ACEITE == "0", "BR_VERMELHO","BR_VERDE") },; // [11] B Code-block de inicializacao do campo
                       NIL,;          // [12] L Indica se trata de um campo chave
                       NIL,;          // [13] L Indica se o campo pode receber valor em uma operação de update.
                       .T.)  

	oModel:addFields('MASTERB6V',,oStruB6V)
    oModel:addGrid('DETAILB6W','MASTERB6V',oStruB6W)
    
    oModel:SetRelation( 'DETAILB6W', { { 'B6W_FILIAL', 'xFilial( "B6W" )'},;
		                               { 'B6W_CODINT', 'B6V_CODINT'},;
		                               { 'B6W_CODEMP', 'B6V_CODEMP'},;
		                               { 'B6W_MATRIC', 'B6V_MATRIC'}},;
		                               B6W->( IndexKey(  ) ) )

	oModel:GetModel("MASTERB6V"):SetDescription("Termo de Consentimento de Dados Pessoais")
	oModel:GetModel("DETAILB6W"):SetDescription("Histórico de Aceitação para Tratamento dos Dados Pessoais")

    // Analise de Beneficiário filtra por Protocolo o Termo
    If IsInCallStack("PLSA977AB")
        If !Empty(BBA->BBA_NROPRO)
            cProtocolo := BBA->BBA_NROPRO
            oModel:GetModel("DETAILB6W"):SetLoadFilter({{"B6W_PROTOC", "'"+cProtocolo+"'", MVC_LOADFILTER_EQUAL}})
        EndIf
    EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Visualzação da tela de Termo de Consentimento de Dados Pessoais"
@author V.Alves
@version Protheus 12
@since 26/04/2021
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    Local oModel := FWLoadModel("PLSA260B6V")
    Local oStruB6V := FWFormStruct(2,"B6V")
    Local oStruB6W := FWFormStruct(2,"B6W")
    Local oView := Nil         

    oStruB6W:RemoveField("B6W_CODINT")
    oStruB6W:RemoveField("B6W_CODEMP")
    oStruB6W:RemoveField("B6W_MATRIC")

    oStruB6W:AddField( 'B6W_LEGEND',; // [01]  C   Nome do Campo
	                   "00",;         // [02]  C   Ordem
                       AllTrim(''),;  // [03]  C   Titulo do campo
                       AllTrim(''),;  // [04]  C   Descricao do campo
                       {'Legenda'},;  // [05]  A   Array com Help
                       'C',;          // [06]  C   Tipo do campo
                       '@BMP',;       // [07]  C   Picture
                       NIL,;          // [08]  B   Bloco de Picture Var
                       '',;           // [09]  C   Consulta F3
                       .T.,;          // [10]  L   Indica se o campo é alteravel
                       NIL,;          // [11]  C   Pasta do campo
                       NIL,;          // [12]  C   Agrupamento do campo
                       NIL,;          // [13]  A   Lista de valores permitido do campo (Combo)
                       NIL,;          // [14]  N   Tamanho maximo da maior opção do combo
                       NIL,;          // [15]  C   Inicializador de Browse
                       .T.,;          // [16]  L   Indica se o campo é virtual
                       NIL,;          // [17]  C   Picture Variavel
                       NIL)           // [18]  L   Indica pulo de linha após o campo
    
    oView := FWFormView():New()
    
    oView:SetModel(oModel)

    oView:AddField( 'VIEW_B6V' , oStruB6V, 'MASTERB6V' )
    oView:AddGrid(  'VIEW_B6W' , oStruB6W, 'DETAILB6W' )
    
    oView:CreateHorizontalBox( 'BOX_SUPERIOR', 15)  
	oView:CreateHorizontalBox( 'BOX_INFERIOR', 85)  

    oView:SetOwnerView('VIEW_B6V','BOX_SUPERIOR')
    oView:SetOwnerView('VIEW_B6W','BOX_INFERIOR')

    oView:SetViewProperty("VIEW_B6W", "GRIDFILTER", {.T.})
    oView:SetViewProperty("VIEW_B6W", "GRIDSEEK", {.T.})

    oView:EnableTitleView('VIEW_B6V','Beneficiário')
    oView:EnableTitleView('VIEW_B6W','Histórico do Beneficiário para Tratamento dos Dados Pessoais')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLTermConsBenef
Função que verifica se existe algum registro na tabela BV6 de acordo
com os dados digitados
@author V.Alves
@version Protheus 12
@since 26/04/2021
/*/
//-------------------------------------------------------------------
Function PLTermConsBenef(cOperadora, cEmpresa, cMatricula)

    Local lRetorno := .F.
    
    Default cOperadora := ""
    Default cEmpresa := ""
    Default cMatricula := ""
         
    B6V->(DBSetOrder(1))
    If B6V->(MsSeek(xFilial("B6V")+cOperadora+cEmpresa+cMatricula))
        FwMsgRun( , {|| FWExecView('Visualizar', 'PLSA260B6V', MODEL_OPERATION_VIEW,, {|| .T.})}, ,'Carregando as informações...') 
        lRetorno := .T.       
    Else
        Help(,, "Não Encontrado",, "Beneficiário não possui dados inseridos no Termo de Consentimento.", 1, 0)
    EndIf

Return lRetorno