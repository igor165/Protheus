#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "FISA212.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA212()

Rotina com objetivo de identificar quais os códigos de créditos
e código da base de cálculo que serão elegíveis para serem estornados
automaticamente, por meio dos registros de ajustes de redução M110 e M510.

Estes estornos se dão em função de benefício da Agro Indústria, que permite
venda não tributada porém para obter este benefício, em contra partida o crédito
dos insumos deverão ser estornados.

E esta rotina irá identificar quais são os créditos que poderão sofre estes
estornos.

@author Erick G Dias
@since 05/02/2019
@version 12.1.17
/*/ 
//-------------------------------------------------------------------
Function FISA212()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F3U")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F3U")
    oBrowse:SetDescription(STR0001)//"Cadastro dos códigos de crédtos de PIS e COFINS passíveis de estorno"                                                                                                                                                                                                                                                                                                                                                                                                                                              
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0)//"Dicionário desatualizado, favor verificar atualização da EFD Contribuições"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA212" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do cadastro das regras de apuração

@author Erick G Dias
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabeçalho da rotina
Local oCabecalho := FWFormStruct(1, "F3U",{|cCampo| COMPSTRU("CAB",cCampo)})
Local oItem      := FWFormStruct(1, "F3U",{|cCampo| COMPSTRU("ITE",cCampo)})

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA212')

//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA212",,oCabecalho)

//Não permite alterar o código do crédito
oCabecalho:SetProperty('F3U_CODCRE' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })

oModel:SetPrimaryKey( {"F3U_FILIAL","F3U_CODCRE" } )

//Adiciona o grid
oModel:AddGrid("FISA212ITEM","FISA212",oItem)

oModel:SetRelation('FISA212ITEM', {{ 'F3U_FILIAL', 'xFilial("F3U")' }, { 'F3U_CODCRE', 'F3U_CODCRE' }}, F3U->( IndexKey(1)))

//Define para não repetir os campos de ano e mês
oModel:GetModel( 'FISA212ITEM' ):SetUniqueLine( { 'F3U_CODBCC' } )

//Adicionando descrição ao modelo
oModel:SetDescription(STR0001)  //"Cadastro dos códigos de crédtos de PIS e COFINS passíveis de estorno"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick G Dias    
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA212" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2,"F3U",{|cCampo| COMPSTRU("CAB",cCampo)})
Local oItem      := FWFormStruct(2,"F3U",{|cCampo| COMPSTRU("ITE",cCampo)})
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA212' )

//Adiciona o grid com os código BCC
oView:AddGrid("VIEW_ITEM",oItem,"FISA212ITEM")

//Separa a tela em duas partes
oView:CreateHorizontalBox("SUPERIOR",20)	
oView:CreateHorizontalBox("INFERIOR",80)

//Definição do cabeçalho e do item na tela
oView:SetOwnerView("VIEW_CABECALHO","SUPERIOR")
oView:SetOwnerView("VIEW_ITEM","INFERIOR")

//Títulos do cabeçalho e do item
oView:EnableTitleView('VIEW_CABECALHO' , STR0003 ) //'Código de Crédito'
oView:EnableTitleView('VIEW_ITEM'      , STR0004 ) //'Código da Base de Cálculo'

oView:SetViewProperty( "*", "GRIDNOORDER" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} COMPSTRU
Função que faz verificação dos campos que deverão ser exibidos
no cabeçalho ou então no item do Grid.

@author Erick G Dias    
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function COMPSTRU(cTipo,cCampo)

Local lRet := .F.

If cTipo == "CAB" .AND. AllTrim(cCampo) $ "F3U_CODCRE/F3U_DCC" //Verifica os campos de cabeçalho
    lRet := .T.
ElseIf cTipo == "ITE" .AND. AllTrim(cCampo) $ "F3U_CODBCC/F3U_DCBCC" //Verifica os campos dos itens
    lRet := .T.
EndIf

Return lRet
