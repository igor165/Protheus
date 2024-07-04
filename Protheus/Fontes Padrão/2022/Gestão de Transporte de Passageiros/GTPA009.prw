#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH" 
#Include "GTPA009.ch"

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA009
Cadastro de Feriados por Setor
 
@sample		GTPA009()
@return		Objeto oBrowse  
@author		Lucas.Brustolin
@since			15/10/2014
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GTPA009()

Local oBrowse := Nil

//-- Instanciamento da Classe de Browse
oBrowse:= FWMBrowse():New()

//-- Define a tabela  
oBrowse:SetAlias("GYL")
oBrowse:SetDescription(STR0001) //-- 'Feriados por Setor'

// Ativação da Classe
oBrowse:Activate()


Return (oBrowse)


//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Cadastro de Feriados por Setor

@Return 	aRotina - Vetor com os menus
@author 	Lucas.Brustolin
@since 		15/10/2014
@version	P12
/*/
//----------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION "AxPesqui" 			OPERATION 1	ACCESS 0 	// STR0002//"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.GTPA009"	OPERATION 2 ACCESS 0 	// STR0003//"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.GTPA009" 	OPERATION 3	ACCESS 0 	// STR0004//"Incluir"
ADD OPTION aRotina TITLE STR0005	ACTION "VIEWDEF.GTPA009"	OPERATION 4	ACCESS 0 	// STR0005//"Alterar"
ADD OPTION aRotina TITLE STR0006	ACTION "VIEWDEF.GTPA009"	OPERATION 5	ACCESS 0 	// STR0006//"Excluir"

Return(aRotina)


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel - Objeto do Model
 
@author 	Lucas.Brustolin
@since 		15/10/2014
@version	P12
/*/ 
//--------------------------------------------------------------------------------------------------------

Static Function ModelDef()

// Cria as estruturas a serem usadas no Modelo de Dados
Local oCabec	:= FWFormStruct( 1, 'GYL', { |cCampo| Alltrim(cCampo) $ "GYL_CODGYT#GYL_DESSET" } )
Local oItem	:= FWFormStruct( 1, 'GYL')
// Cria objeto Model
Local oModel := MPFormModel():New('GTPA009'/*BPRE*/,/*bPosValid*/,/*bCommit*/ )

oCabec:SetProperty("GYL_CODGYT", MODEL_FIELD_WHEN, {|| INCLUI } )

//Retira a obrigatoriedade do código na grid 
oItem:SetProperty("GYL_CODGYT", MODEL_FIELD_OBRIGAT, .F.)

// ----------------------------------------+
// Adiciona componentes no Modelo de Dados |
// ----------------------------------------+
oModel:AddFields('GYLMASTER', /*cOwner*/, oCabec ) //-- Cabelho
oModel:AddGrid('GYLDETAIL', 'GYLMASTER', oItem )   //-- Item

oModel:SetRelation( 'GYLDETAIL', {{ 'GYL_FILIAL', 'xFilial( "GYL" )'}, { 'GYL_CODGYT', 'GYL_CODGYT' } },GYL->( IndexKey(1) ))

// ----------------------------------------+
//  Adiciona descrição do Modelo de Dados  |
// ----------------------------------------+
oModel:SetDescription( STR0001 ) //-- 'Feriados por Setor'

// ----------------------------------------+
//  Não permite linhas duplicadas          |
// ----------------------------------------+
oModel:GetModel( 'GYLDETAIL' ):SetUniqueLine({"GYL_IDCAL"})

// ----------------------------------------+
//  Define a Chave Primaria do Modelo      |
// ----------------------------------------+
oModel:SetPrimaryKey({"GYL_FILIAL","GYL_CODGYT","GYL_IDCAL"})

Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da  View Interface 

@sample  	ViewDef()

@return  	oView - Objeto do View

@author 	Lucas.Brustolin
@since 		15/10/2014
@version	P12
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

// Cria as estruturas a serem usadas na visualização
Local oCabec	:= FWFormStruct( 2, 'GYL', { |cCampo| Alltrim(cCampo) $ "GYL_CODGYT#GYL_DESSET" } )
Local oItem	:= FWFormStruct( 2, 'GYL', { |cCampo| Alltrim(cCampo) $ "GYL_IDCAL#GYL_DSCAL" } )
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel( 'GTPA009' )
//-- Cria objeto View
Local oView	:= FWFormView():New()

// -----------------------------------------------------+
// Define qual Modelo de dados será utilizado				|
// -----------------------------------------------------+
oView:SetModel( oModel )

// -----------------------------------------------------+
// Adiciona componentes a serem visualiados na tela     |
// -----------------------------------------------------+
oView:AddField('VIEW_CABEC', oCabec,'GYLMASTER') //-- Cabelho
oView:AddGrid('VIEW_ITEM' , oItem,'GYLDETAIL')   //-- Item

// -----------------------------------------------------+
// Define a divisão da tela para inserir os componentes |
// -----------------------------------------------------+
oView:CreateHorizontalBox('SUPERIOR', 20)
oView:CreateHorizontalBox('INFERIOR', 80)

oView:SetOwnerView('VIEW_CABEC','SUPERIOR')
oView:SetOwnerView('VIEW_ITEM' ,'INFERIOR')

Return(oView)


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Retorna descrição da localidade referente ao setor.
@sample  	TP009X7Desc()
@return  	cDescSetor Descrição da localidade setor.
@author 	Lucas.Brustolin
@since 		04/08/2017
@version	P12
/*/
//-------------------------------------------------------------------
Function TP009X7Desc()                                                                                       
Local oModel        :=  FwModelActive() 
Local cCodSetor     := ""
Local cLocalidade   := "" 
Local cDescSetor    := ""

If oModel <> Nil 
    cCodSetor := FwFldGet("GYL_CODGYT")
Else 
    cCodSetor := GYL->GYL_CODGYT
EndIf   

cLocalidade := Posicione("GYT", 1, xFilial("GYT")+ cCodSetor,"GYT_LOCALI") 
cDescSetor  := Posicione("GI1", 1, xFilial("GI1")+ cLocalidade,"GI1_DESCRI")

Return(cDescSetor)