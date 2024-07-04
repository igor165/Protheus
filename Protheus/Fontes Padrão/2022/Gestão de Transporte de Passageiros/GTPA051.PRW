#Include "GTPA051.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA051
Função responsavel pela browse de Motivos de Cancelamento
@type Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Function GTPA051()
Local oBrowse

If GTPxVldDic('GYC')
    oBrowse       := FWLoadBrw('GTPA051')

    oBrowse:Activate()
    oBrowse:Destroy()

    GTPDestroy(oBrowse)
Else
    FwAlertHelp(STR0002, STR0001) //"Dicionário desatualizado." //"Atenção"
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Função responsavel pela definição do browse de Motivos de Cancelamento
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
If GTPxVldDic('GYC')
	oBrowse:SetAlias('GYC')

	oBrowse:SetMenuDef('GTPA051')

	oBrowse:SetDescription(STR0003)//STR0003 //'Motivos de Cancelamento - Bilhetes'

	oBrowse:AddLegend("GYC_MSBLQL == '1'"   ,"RED"      ,STR0004  )//"Validar"     //"Inativo"
	oBrowse:AddLegend("GYC_MSBLQL == '2'"   ,"GREEN"    ,STR0005    )//"Não Validar" //"Ativo"
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

    ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.GTPA051' OPERATION OP_VISUALIZAR	ACCESS 0 // Visualizar 
    ADD OPTION aRotina TITLE STR0010	ACTION 'VIEWDEF.GTPA051' OPERATION OP_INCLUIR   	ACCESS 0 // Incluir 
    ADD OPTION aRotina TITLE STR0011    ACTION 'VIEWDEF.GTPA051' OPERATION OP_ALTERAR   	ACCESS 0 // Alterar 
    ADD OPTION aRotina TITLE STR0012	ACTION 'VIEWDEF.GTPA051' OPERATION OP_EXCLUIR   	ACCESS 0 // Excluir 

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
Local oModel	
Local oStruGYC	
If GTPxVldDic('GYC')
	oModel	:= nil
	oStruGYC	:= FWFormStruct(1,'GYC')
	SetModelStruct(oStruGYC)

	oModel := MPFormModel():New('GTPA051', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields('GYCMASTER',/*cOwner*/,oStruGYC,/*bPre*/,/*bPos*/,/*bLoad*/)

	oModel:SetDescription(STR0007) //'Motivos de Cancelamento'

	oModel:GetModel('GYCMASTER'):SetDescription(STR0007)	//STR0007  //'Motivos de Cancelamento'

	oModel:SetPrimaryKey({'GYC_FILIAL','GYC_CODIGO'})
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
@param oStruGYC, character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStruGYC)
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }

If ValType(oStruGYC) == "O"
    
    oStruGYC:SetProperty("GYC_MSBLQL"   ,MODEL_FIELD_INIT   ,{||'2'} )

    oStruGYC:SetProperty("GYC_CODIGO"   ,MODEL_FIELD_VALID  ,bFldVld )

    oStruGYC:SetProperty("GYC_MSBLQL"   ,MODEL_FIELD_VALUES ,RetFldCbox('GYC_MSBLQL') )

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
    
    Case cField == "GYC_CODIGO"
        If !VldChave(uNewValue,oMdl:GetDataId())
            lRet     := .F.
            cMsgErro := STR0008 //"Código informado já existe em outro registro"
            cMsgSol  := STR0009 //"Verifique o valor informado ou altere para um novo número"
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
    Case cField == "GYC_MSBLQL"
        aAdd(aCbox,"1="+STR0004   )//STR0004 //"Inativo"
        aAdd(aCbox,"2="+STR0005     )//STR0005 //"Ativo"
        
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
    Select Count(GYC_CODIGO) as QTD
    From %Table:GYC% GYC
    Where
        GYC.GYC_FILIAL = %xFilial:GYC%
        AND GYC.GYC_CODIGO = %Exp:cCodigo%
        and GYC.R_E_C_N_O_ <> %Exp:nRecno% 
        AND GYC.%NotDel%
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
Local oStruGYC	
If GTPxVldDic('GYC')

	oView		:= FWFormView():New()
	oModel	:= FwLoadModel('GTPA051')
	oStruGYC	:= FWFormStruct(2, 'GYC')
	SetViewStruct(oStruGYC)

	oView:SetModel(oModel)

	oView:AddField('VIEW_GYC' ,oStruGYC,'GYCMASTER')

	oView:SetDescription(STR0007) //STR0007 //'Motivos de Cancelamento'
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
@param oStruGYC, character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStruGYC)

If ValType(oStruGYC) == "O"

    oStruGYC:SetProperty("GYC_MSBLQL"   ,MVC_VIEW_COMBOBOX ,RetFldCbox('GYC_MSBLQL') )

Endif

Return 
