#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "FISA212.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA212()

Rotina com objetivo de identificar quais os c�digos de cr�ditos
e c�digo da base de c�lculo que ser�o eleg�veis para serem estornados
automaticamente, por meio dos registros de ajustes de redu��o M110 e M510.

Estes estornos se d�o em fun��o de benef�cio da Agro Ind�stria, que permite
venda n�o tributada por�m para obter este benef�cio, em contra partida o cr�dito
dos insumos dever�o ser estornados.

E esta rotina ir� identificar quais s�o os cr�ditos que poder�o sofre estes
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
    oBrowse:SetDescription(STR0001)//"Cadastro dos c�digos de cr�dtos de PIS e COFINS pass�veis de estorno"                                                                                                                                                                                                                                                                                                                                                                                                                                              
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0)//"Dicion�rio desatualizado, favor verificar atualiza��o da EFD Contribui��es"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Erick G Dias
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA212" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do cadastro das regras de apura��o

@author Erick G Dias
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabe�alho da rotina
Local oCabecalho := FWFormStruct(1, "F3U",{|cCampo| COMPSTRU("CAB",cCampo)})
Local oItem      := FWFormStruct(1, "F3U",{|cCampo| COMPSTRU("ITE",cCampo)})

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA212')

//Atribuindo cabe�alho para o modelo
oModel:AddFields("FISA212",,oCabecalho)

//N�o permite alterar o c�digo do cr�dito
oCabecalho:SetProperty('F3U_CODCRE' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })

oModel:SetPrimaryKey( {"F3U_FILIAL","F3U_CODCRE" } )

//Adiciona o grid
oModel:AddGrid("FISA212ITEM","FISA212",oItem)

oModel:SetRelation('FISA212ITEM', {{ 'F3U_FILIAL', 'xFilial("F3U")' }, { 'F3U_CODCRE', 'F3U_CODCRE' }}, F3U->( IndexKey(1)))

//Define para n�o repetir os campos de ano e m�s
oModel:GetModel( 'FISA212ITEM' ):SetUniqueLine( { 'F3U_CODBCC' } )

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0001)  //"Cadastro dos c�digos de cr�dtos de PIS e COFINS pass�veis de estorno"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Erick G Dias    
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA212" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2,"F3U",{|cCampo| COMPSTRU("CAB",cCampo)})
Local oItem      := FWFormStruct(2,"F3U",{|cCampo| COMPSTRU("ITE",cCampo)})
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA212' )

//Adiciona o grid com os c�digo BCC
oView:AddGrid("VIEW_ITEM",oItem,"FISA212ITEM")

//Separa a tela em duas partes
oView:CreateHorizontalBox("SUPERIOR",20)	
oView:CreateHorizontalBox("INFERIOR",80)

//Defini��o do cabe�alho e do item na tela
oView:SetOwnerView("VIEW_CABECALHO","SUPERIOR")
oView:SetOwnerView("VIEW_ITEM","INFERIOR")

//T�tulos do cabe�alho e do item
oView:EnableTitleView('VIEW_CABECALHO' , STR0003 ) //'C�digo de Cr�dito'
oView:EnableTitleView('VIEW_ITEM'      , STR0004 ) //'C�digo da Base de C�lculo'

oView:SetViewProperty( "*", "GRIDNOORDER" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} COMPSTRU
Fun��o que faz verifica��o dos campos que dever�o ser exibidos
no cabe�alho ou ent�o no item do Grid.

@author Erick G Dias    
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function COMPSTRU(cTipo,cCampo)

Local lRet := .F.

If cTipo == "CAB" .AND. AllTrim(cCampo) $ "F3U_CODCRE/F3U_DCC" //Verifica os campos de cabe�alho
    lRet := .T.
ElseIf cTipo == "ITE" .AND. AllTrim(cCampo) $ "F3U_CODBCC/F3U_DCBCC" //Verifica os campos dos itens
    lRet := .T.
EndIf

Return lRet
