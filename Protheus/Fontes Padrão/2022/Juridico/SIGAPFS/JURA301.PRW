#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA301.CH"

//------------------------------------------------------------------------------
/* /{Protheus.doc} JURA301
Cadastros de occorências
@since 09/09/2022
/*/
//------------------------------------------------------------------------------
Function JURA301()
Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias('OI2')

oBrowse:SetMenuDef('JURA301')
oBrowse:SetDescription(STR0001)//Cadastro de Ocorrências

oBrowse:Activate()
oBrowse:Destroy()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@since 09/09/2022
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.JURA301' OPERATION OP_VISUALIZAR ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.JURA301' OPERATION OP_INCLUIR    ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.JURA301' OPERATION OP_ALTERAR    ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.JURA301' OPERATION OP_EXCLUIR    ACCESS 0 // Excluir

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@since 09/09/2022
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel  := nil
Local oStrOI2 := FWFormStruct(1,'OI2')
Local oStrOI3 := FWFormStruct(1,'OI3')
Local bPosVld := {|oModel| ModelPosValid(oModel)}


oStrOI3:SetProperty("OI3_CONTEU", MODEL_FIELD_WHEN, {|oMdl| oMdl:GetValue("OI3_TIPO")=="2" })

oModel := MPFormModel():New('JURA301', /*bPreValidacao*/,bPosVld /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('OI2MASTER',/*cOwner*/,oStrOI2,/*bPre*/,/*bPos*/,/*bLoad*/)

oModel:AddGrid('OI3DETAIL','OI2MASTER',oStrOI3,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*bLoad*/)
oModel:SetRelation('OI3DETAIL',{{ 'OI3_FILIAL','OI2_FILIAL'},{'OI3_COD','OI2_COD' }},OI3->(IndexKey(1)))

oModel:GetModel( 'OI3DETAIL' ):SetUniqueLine( { 'OI3_CAMPO' } )

oModel:SetDescription(STR0001) //'Cadastros de Ocorrências'
oModel:GetModel('OI2MASTER'):SetDescription(STR0006) //'Ocorrência'
oModel:GetModel('OI3DETAIL'):SetDescription(STR0007) //"Condições da ocorrências"

oModel:SetPrimaryKey({'OI2_FILIAL','OI2_COD'})

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@author jacomo.fernandes
@since 09/09/2022
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('JURA301')
Local oStrOI2	:= FWFormStruct(2, 'OI2')
Local oStrOI3	:= FWFormStruct(2, 'OI3')

oView:SetModel(oModel)

oView:AddField('VIEW_OI2' ,oStrOI2,'OI2MASTER')
oView:AddGrid('VIEW_OI3'  ,oStrOI3,'OI3DETAIL')

oView:addIncrementField('VIEW_OI3'  ,'OI3_SEQ')

oView:CreateHorizontalBox('UPPER', 30)
oView:CreateHorizontalBox('BOTTOM', 70)

oView:SetOwnerView('VIEW_OI2','UPPER')
oView:SetOwnerView('VIEW_OI3','BOTTOM')

oView:SetDescription(STR0001) //'Cadastro de Ocorrências'
oView:EnableTitleView('VIEW_OI3',STR0007)//"Condições da ocorrências"

Return oView

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelPosValid
Realiza as validações no confirmar do modelo
@since 12/09/2022
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return lRet, Booleano informando se está certo ou não
/*/
//------------------------------------------------------------------------------
Static Function ModelPosValid(oModel)
Local lRet := .T.
Local oMdlOI3 := oModel:GetModel('OI3DETAIL')

If oMdlOI3:SeekLine({{'OI3_TIPO','2'},{'OI3_CONTEU',Space(TamSx3('OI3_CONTEU')[1])}})
	lRet := .F.
	JurMsgErro(STR0008)//"Existe(m) filtro(s) informado(s) do tipo valor fixo onde não possuem conteudo informado"
Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} J301ENTCBX
Função responsável pelo retorno do combobox da entidade
@since 12/09/2022
@return Conteudo do combobox da entidade da ocorrência.
/*/
//------------------------------------------------------------------------------
Function J301ENTCBX()
Return STR0009 //"1=Processo;2=Ato Processual"
