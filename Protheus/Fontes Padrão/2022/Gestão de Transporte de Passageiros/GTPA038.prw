#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA038.CH"

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPA038
Rotina responsavel pelo Log de Processamento
@type Function
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
/*/
//------------------------------------------------------------------------------
Function GTPA038()
	
Local oBrowse   :=  FWMBrowse():New()

oBrowse:SetAlias('GZI')
oBrowse:SetDescription(STR0001)//"Log de Processamentos"
oBrowse:Activate()
oBrowse:Destroy()

GtpDestroy(oBrowse)

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Fun��o responsavel pela defini��o do menu
@type Static Function
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
@return aRotina, retorna as op��es do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

    ADD OPTION aRotina TITLE STR0004	ACTION 'VIEWDEF.GTPA038' OPERATION 2 ACCESS 0//'Visualizar'
    ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.GTPA038' OPERATION 8 ACCESS 0//'Imprimir'

Return aRotina
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Fun��o responsavel pela defini��o do modelo
@type Static Function
@author 
@since 23/01/2020
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := Nil
Local oStruGZI  := FWFormStruct(1,'GZI')
Local bPosVld   := {|oMdl| ModelPosVld(oMdl)}

SetModelStruct(oStruGZI)

oModel := MPFormModel():New('GTPA038',/*bPreValid*/, bPosVld , /*bCommit*/)

oModel:AddFields('GZIMASTER',/*cOwner*/,oStruGZI)

oModel:SetPrimaryKey({ 'GZI_FILIAL', 'GZI_CODIGO'})

oModel:SetDescription(STR0001)//"Log de Processamentos"
oModel:GetModel('GZIMASTER'):SetDescription(STR0001)//"Log de Processamentos"

Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetModelStruct
Fun��o responsavel pela defini��o da estrutura do modelo
@type Static Function
@author jacomo.fernandes
@since 23/01/2020
@version 1.0
@param oStruGZI, object, (Descri��o do par�metro)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStruGZI)
Local bInit     := {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}

If ValType(oStruGZI) == "O"
    oStruGZI:SetProperty('GZI_CODIGO'   , MODEL_FIELD_INIT, bInit)
    oStruGZI:SetProperty('GZI_USUARI'   , MODEL_FIELD_INIT, bInit)
    oStruGZI:SetProperty('GZI_DTINI'    , MODEL_FIELD_INIT, bInit)
    oStruGZI:SetProperty('GZI_HRINI'    , MODEL_FIELD_INIT, bInit)
    oStruGZI:SetProperty('GZI_ROTINA'   , MODEL_FIELD_INIT, bInit)
Endif

Return 
//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldInit
Fun��o responsavel pela defini��o de inicializadores padr�es
@type Static Function
@author jacomo.fernandes
@since 23/01/2020
@version 1.0
@param oMdl, Object, (Descri��o do par�metro)
@param cField, character, (Descri��o do par�metro)
@param uVal, undefined, (Descri��o do par�metro)
@param nLine, numeric, (Descri��o do par�metro)
@param uOldValue, undefined,(Descri��o do par�metro)
@return uRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Local uRet  := uVal

Do Case
    Case cField == 'GZI_CODIGO'
        uRet := GtpXeNum('GZI','GZI_CODIGO')

    Case cField == 'GZI_USUARI'
        uRet := AllTrim(LogUserName())+"|"+AllTrim(UsrRetName(RetCodUsr()))

    Case cField == 'GZI_DTINI' 
        uRet := dDataBase

    Case cField == 'GZI_HRINI' 
        uRet := Time()

    Case cField == 'GZI_ROTINA'
        uRet := FunName()

EndCase

Return uRet
//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelPosVld(oMdl)
Fun��o responsavel pela valida��o do modelo por completo
@type Static Function
@author jacomo.fernandes
@since 23/01/2020
@version 1.0
@param oMdl, object, (Descri��o do par�metro)
@return lRet, Retorno l�gico
/*/
//------------------------------------------------------------------------------
Static Function ModelPosVld(oModel)
Local lRet      := .T.
Local oMdlGZI   := oModel:GetModel('GZIMASTER')

oMdlGZI:SetValue('GZI_DTFIM',dDataBase)
oMdlGZI:SetValue('GZI_HRFIM',Time())

If oModel:HasErrorMessage()
    lRet := .F.
Endif

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o responsavel pela defini��o da view
@type Static Function
@author jacomo.fernandes
@since 23/01/2020
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA038')
Local oStruGZI	:= FWFormStruct(2, 'GZI')

oView:SetModel(oModel)

oView:AddField('VIEW_GZI' ,oStruGZI,'GZIMASTER')

oView:SetDescription(STR0001)//"Log de Processamentos"

oView:AddUserButton( "Salvar Log", "", {|oView| SaveMemo(oView)} )

Return oView

//------------------------------------------------------------------------------
/* /{Protheus.doc} SaveMemo
Fun��o responsavel para salvar o memo do campo GZI_PARAME
@type Static Function
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
@param oView, object, (Descri��o do par�metro)
/*/
//------------------------------------------------------------------------------
Static Function SaveMemo(oView)
Local cMask	:= "Arquivos Texto (*.TXT) |*.txt|"
Local cFile	:= cGetFile(cMask,OemToAnsi("Salvar Como..."))
Local cMemo	:= oView:GetModel('GZIMASTER'):GetValue('GZI_PARAME')

If !Empty(cFile)
	If At('.TXT',Upper(cFile)) == 0
		cFile+= ".txt"
	Endif
	MemoWrite(cFile,cMemo)
Endif

Return