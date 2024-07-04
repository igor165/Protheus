#INCLUDE "AGRA608.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"

/** -----------------------------------------------------------
{Protheus.doc} ModelDef
Tipos de Classificação

@param: Nil
@author: Aecio Ferreira Gomes
@since: 26/03/2013
@Uso: AGRA608
----------------------------------------------------------- **/
Function AGRA608()
Local aArea    	:= GetArea()
Local oBrowser 	:= Nil

//-------------------------
//Instancia o objeto Browse
//-------------------------
oBrowser := FWMBrowse():New()
oBrowser:SetAlias('DXA')
oBrowser:SetDescription(STR0001) //"Tipos de Classificação"

//-------------------------
//Ativa o Browse
//-------------------------
oBrowser:Activate()
           
RestArea(aArea)
Return

/** -----------------------------------------------------------
{Protheus.doc} ModelDef
Retorna o modelo de Dados da rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 26/03/2013
@Uso: AGRA608
----------------------------------------------------------- **/
Static Function ModelDef()
Local oModel   	:= Nil
Local oStruDXA 	:= FwFormStruct( 1, 'DXA' )	// Tipos de classificação

//-----------------------------
// Instancia o Modelo de dados
//-----------------------------
oModel := MpFormModel():New( 'AGRA608')
oModel:SetDescription( STR0002 ) //"Modelo de dados Tipos de classificação"

//--------------------------------
// Adiciona a estrutura de dados
//--------------------------------
oModel:AddFields( 'MdFieldDXA', , oStruDXA )
oModel:GetModel( 'MdFieldDXA' ):SetDescription( STR0001 ) //"Tipos de Classificação"

Return oModel

/** -----------------------------------------------------------
{Protheus.doc} ViewDef
Retorna o modelo de visualização da rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 26/03/2013
@Uso: AGRA608
----------------------------------------------------------- **/
Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= FwLoadModel( 'AGRA608' )
Local oStruDXA 	:= FwFormStruct( 2, 'DXA' ) //Tipos de classificação

//--------------------------------
// Instancia a View
//--------------------------------
oView := FwFormView():New()

//--------------------------------
// Seta o Modelo de dados
//--------------------------------
oView:SetModel( oModel )

//------------------------------------------
// Adiciona a estrutura de dados no modelo
//------------------------------------------
oView:AddField( 'VIEW_DXA', oStruDXA, 'MdFieldDXA' )

//--------------------------------
// Cria Box
//--------------------------------
oView:CreateHorizontalBox( 'TOTAL', 100 )

//--------------------------------
// Seta Owner
//--------------------------------
oView:SetOwnerView( 'VIEW_DXA', 'TOTAL' )

Return oView

/** -----------------------------------------------------------
{Protheus.doc} ViewDef
Menu padrão da rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 26/03/2013
@Uso: AGRA608
----------------------------------------------------------- **/
Static Function MenuDef()
Local aRotina := {}
 
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.AGRA608' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.AGRA608' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.AGRA608' OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.AGRA608' OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.AGRA608' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.AGRA608' OPERATION 9 ACCESS 0 //"Copiar"

Return aRotina