#INCLUDE "JURA232.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA232
Contatos (SU5) para integração com o LegalDesk.

@author Cristina Cintra
@since 22/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA232()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Contatos - Integração LegalDesk"
oBrowse:SetAlias( "SU5" )
oBrowse:SetLocate()
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Cristina Cintra
@since 22/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA232", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados dos Contatos para integração com o LegalDesk.

@author Cristina Cintra
@since 22/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructSU5 := FWFormStruct(1, "SU5")
Local oStructAGA := FWFormStruct(1, "AGA")
Local oStructAGB := FWFormStruct(1, "AGB")

oModel:= MPFormModel():New( "JURA232", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields("SU5MASTER", /*cOwner*/, oStructSU5,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Load*/) 
oModel:AddGrid( "AGADETAIL", "SU5MASTER", oStructAGA,/*bLinePre*/,/*bLinePost*/,,/*bPosVal*/,/*bLoad*/)
oModel:AddGrid( "AGBDETAIL", "SU5MASTER", oStructAGB,/*bLinePre*/,/*bLinePost*/,,/*bPosVal*/,/*bLoad*/)


oModel:GetModel( "AGADETAIL" ):SetDelAllLine(.T.)
oModel:GetModel( "AGADETAIL" ):SetUniqueLine( { "AGA_CODIGO","AGA_ENTIDA","AGA_CODENT" } )
oModel:SetRelation( "AGADETAIL", { { "AGA_FILIAL", "U5_FILIAL" }, ;
                                   { "AGA_ENTIDA", "Upper('SU5')" }, ;
                                   { "AGA_CODENT", "U5_CODCONT" }}, AGA->( IndexKey( 1 ) ) )

oModel:GetModel( "AGBDETAIL" ):SetDelAllLine(.T.)
oModel:GetModel( "AGBDETAIL" ):SetUniqueLine( { "AGB_CODIGO","AGB_ENTIDA","AGB_CODENT" } )
oModel:SetRelation( "AGBDETAIL", { { "AGB_FILIAL", "U5_FILIAL" }, ;
                                   { "AGB_ENTIDA", "Upper('SU5')" }, ;
								   { "AGB_CODENT", "U5_CODCONT" }}, AGB->( IndexKey( 1 ) ) )
																 
oModel:GetModel("SU5MASTER"):SetDescription( STR0001 ) //"Contatos - Integração LegalDesk"
oModel:GetModel("AGADETAIL"):SetDescription( STR0004 ) //"Endereços do Contato - Integração LegalDesk"
oModel:GetModel("AGBDETAIL"):SetDescription( STR0005 ) //"Telefones do Contato - Integração LegalDesk"

oModel:SetOptional("AGADETAIL", .T.)
oModel:SetOptional("AGBDETAIL", .T.)

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author 
@since 18/11/2021
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('JURA232')
Local oStrSU5	:= FWFormStruct(2, "SU5")
Local oStrAGA	:= FWFormStruct(2, "AGA")
Local oStrAGB	:= FWFormStruct(2, "AGB")

oView:SetModel(oModel)

oView:AddField('VIEW_SU5' ,oStrSU5,'SU5MASTER')
oView:AddGrid('VIEW_AGA'  ,oStrAGA,'AGADETAIL')
oView:AddGrid('VIEW_AGB'  ,oStrAGB,'AGBDETAIL')

oView:CreateHorizontalBox('UPPER', 70)
oView:CreateHorizontalBox('BOTTOM', 30)

oView:CreateVerticalBox('LEFT',50,'BOTTOM')
oView:CreateVerticalBox('RIGHT',50,'BOTTOM')

oView:SetOwnerView('VIEW_SU5','UPPER')
oView:SetOwnerView('VIEW_AGA','LEFT')
oView:SetOwnerView('VIEW_AGB','RIGHT')

oView:SetDescription(STR0001) //"Contatos - Integração LegalDesk"

Return oView

