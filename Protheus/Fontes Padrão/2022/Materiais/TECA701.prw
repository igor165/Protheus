#Include "TECA701.ch"
#INCLUDE "Protheus.CH"	
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA701

Cadastro de Tarefas - TX2
@author Mateus Boiani
@since 17/05/2018

/*/
//----------------------------------------------------------------------------------------------------------------------
Function TECA701()
Local oBrowse

Private aRotina	:= MenuDef() 
Private cCadastro	:= STR0001 //"Cadastro de Tarefas"

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('TX2')
oBrowse:SetDescription(STR0001) //"Cadastro de Tarefas"
oBrowse:Activate()

Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definição do MenuDef
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpO:aRotina
/*/
//--------------------------------------------------------------------------------------------------------------------
Static function MenuDef()
Local aRotina :={}

ADD OPTION aRotina TITLE STR0002 			ACTION 'PesqBrw' 				OPERATION 1 ACCESS 0 //STR0002 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003		 	ACTION 'VIEWDEF.TECA701' 	OPERATION 2 ACCESS 0 //STR0003 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 			ACTION 'VIEWDEF.TECA701' 	OPERATION 3 ACCESS 0 //STR0004 //"Incluir"
ADD OPTION aRotina TITLE STR0005				ACTION 'VIEWDEF.TECA701' 	OPERATION 4 ACCESS 0 //STR0005 //"Alterar"
ADD OPTION aRotina TITLE STR0006 			ACTION 'VIEWDEF.TECA701' 	OPERATION 5 ACCESS 0 //STR0006 //"Excluir"


Return(aRotina)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definição do Model 
@author Mateus Boiani
@since 17/05/2018

@return ExpO:oModel
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStruTX2			:= FWFormStruct(1,'TX2')

oModel := MPFormModel():New('TECA701',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('TX2MASTER',/*cOwner*/,oStruTX2,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/,/*bFieldAbp*/)

oModel:SetPrimaryKey({"TX2_FILIAL","TX2_CODIGO"})

Return(oModel)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definição da View 
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpO:oView
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel   	:= FWLoadModel('TECA701')
Local oStruTX2 	:= FWFormStruct(2,'TX2')

oView:= FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_CAB',oStruTX2,'TX2MASTER')
oView:CreateHorizontalBox('SUPERIOR',100)
oView:SetOwnerView( 'VIEW_CAB','SUPERIOR' )

Return(oView)