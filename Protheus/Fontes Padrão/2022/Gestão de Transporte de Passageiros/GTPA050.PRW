#Include "GTPA050.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA050
Função responsavel pela browse de tipos de Vendas
@type Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Function GTPA050()
Local oBrowse

If GTPxVldDic('GYB')
    oBrowse       := FWLoadBrw('GTPA050')

    oBrowse:Activate()
    oBrowse:Destroy()

    GTPDestroy(oBrowse)
Else
    FwAlertHelp(STR0002, STR0001) //"Dicionário desatualizado." //"Atenção"
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Função responsavel pela definição do browse de tipos de Vendas
@type Static Function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return oBrowse, retorna o objeto de browse
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse       := FWMBrowse():New()
If GTPxVldDic('GYB')
	oBrowse:SetAlias('GYB')

	oBrowse:SetMenuDef('GTPA050')

	oBrowse:SetDescription(STR0003)//STR0003 //'Tipos de Vendas - Bilhetes'

	oBrowse:AddLegend("GYB_MSBLQL == '1'"   ,"RED"      ,STR0004  )//"Validar"     //"Inativo"
	oBrowse:AddLegend("GYB_MSBLQL == '2'"   ,"GREEN"    ,"Ativo"    )//"Não Validar"
Else
    FwAlertHelp(STR0002, STR0001) //"Atenção" //"Dicionário desatualizado."
EndIf

Return oBrowse

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author jacomo.fernandes
@since 11/02/2020
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

    ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.GTPA050' OPERATION OP_VISUALIZAR	ACCESS 0 // Visualizar //'Visualizar'

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author jacomo.fernandes
@since 11/02/2020
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStruGYB  := nil
If GTPxVldDic('GYB')
	oStruGYB	:= FWFormStruct(1,'GYB')

	SetModelStruct(oStruGYB)

	oModel := MPFormModel():New('GTPA050', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields('GYBMASTER',/*cOwner*/,oStruGYB,/*bPre*/,/*bPos*/,/*bLoad*/)

	oModel:SetDescription(STR0006) //'Tipos de Vendas'

	oModel:GetModel('GYBMASTER'):SetDescription(STR0006)	//STR0006  //'Tipos de Vendas'

	oModel:SetPrimaryKey({'GYB_FILIAL','GYB_CODIGO'})
Else
    FwAlertHelp(STR0002, STR0001) //"Atenção" //"Dicionário desatualizado."
EndIf
Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetModelStruct

@type Static Function
@author jacomo.fernandes
@since 11/02/2020
@version 1.0
@param oStruGYB, character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStruGYB)
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }

If ValType(oStruGYB) == "O"
    
    oStruGYB:SetProperty("GYB_CODIGO"   ,MODEL_FIELD_INIT   ,{||GtpXeNum('GYB','GYB_CODIGO')} )
    oStruGYB:SetProperty("GYB_MSBLQL"   ,MODEL_FIELD_INIT   ,{||'2'} )

    oStruGYB:SetProperty("GYB_CODIGO"   ,MODEL_FIELD_VALID  ,bFldVld )

    oStruGYB:SetProperty("GYB_MSBLQL"   ,MODEL_FIELD_VALUES ,RetFldCbox('GYB_MSBLQL') )

Endif

Return 


//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid
Função responsavel pela validação dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param oMdl, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uNewValue, character, (Descrição do parâmetro)
@param uOldValue, character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
	Case Empty(uNewValue)
		lRet := .T.
    
    Case cField == "GYB_CODIGO"
        If !VldChave(uNewValue,oMdl:GetDataId())
            lRet     := .F.
            cMsgErro := STR0007 //"Código informado já existe em outro registro"
            cMsgSol  := STR0008 //"Verifique o valor informado ou altere para um novo número"
        Endif
EndCase


If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet


//------------------------------------------------------------------------------
/* /{Protheus.doc} RetFldCbox

@type Static Function
@author jacomo.fernandes
@since 11/02/2020
@version 1.0
@param cField, character, (Descrição do parâmetro)
@return aCbox, return_description
/*/
//------------------------------------------------------------------------------
Static Function RetFldCbox(cField)
Local aCbox     := {}
Do Case
    Case cField == "GYB_MSBLQL"
        aAdd(aCbox,"1="+STR0004   )//STR0004 //"Inativo"
        aAdd(aCbox,"2="+STR0009     )//STR0009 //"Ativo"
        
EndCase

Return aCbox


//------------------------------------------------------------------------------
/* /{Protheus.doc} VldChave

@type Static Function
@author jacomo.fernandes
@since 11/02/2020
@version 1.0
@param cCodigo, character, (Descrição do parâmetro)
@return lRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function VldChave(cCodigo,nRecno)
Local lRet      := .T.
Local cAliasTmp := GetNextAlias()

BeginSql Alias cAliasTmp
    Select Count(GYB_CODIGO) as QTD
    From %Table:GYB% GYB
    Where
        GYB.GYB_FILIAL = %xFilial:GYB%
        AND GYB.GYB_CODIGO = %Exp:cCodigo%
        and GYB.R_E_C_N_O_ <> %Exp:nRecno% 
        AND GYB.%NotDel%
EndSql

lRet := (cAliasTmp)->QTD == 0

(cAliasTmp)->(DbCloseArea())

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author jacomo.fernandes
@since 11/02/2020
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		
Local oModel	
Local oStruGYB	
If GTPxVldDic('GYB')
	oView	 := FWFormView():New()
	oModel	 := FwLoadModel('GTPA050')
	oStruGYB := FWFormStruct(2, 'GYB')

	SetViewStruct(oStruGYB)

	oView:SetModel(oModel)

	oView:AddField('VIEW_GYB' ,oStruGYB,'GYBMASTER')

	oView:SetDescription(STR0006) //STR0006 //'Tipos de Vendas'
Else
    FwAlertHelp(STR0002, STR0001) //"Dicionário desatualizado." //"Atenção"
EndIf
Return oView


//------------------------------------------------------------------------------
/* /{Protheus.doc} SetViewStruct

@type Static Function
@author jacomo.fernandes
@since 11/02/2020
@version 1.0
@param oStruGYB, character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStruGYB)

If ValType(oStruGYB) == "O"

    oStruGYB:SetProperty("GYB_MSBLQL"   ,MVC_VIEW_COMBOBOX ,RetFldCbox('GYB_MSBLQL') )

Endif

Return 
