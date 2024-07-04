#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#include "PLSA960BLO.ch"

/*//-------------------------------------------------------------------
{Protheus.doc} ModelDef.
ModelDef.
@since    10/2020.
//-------------------------------------------------------------------*/
Static function ModelDef()
local oModel    := nil     
local oStrB17   := FWFormStruct(1,'B17')

oModel := MPFormModel():New('PLSA960BLO', , { || PLS960BVLD(oModel, !Empty(BB0->BB0_CODBLO)) })
oModel:addFields('MASTERB17', , oStrB17) 

oStrB17:SetProperty( 'B17_CODPFS' , MODEL_FIELD_INIT, { || BB0->BB0_CODIGO } )
oStrB17:SetProperty( 'B17_NOMPFS' , MODEL_FIELD_INIT, { || BB0->BB0_NOME } )
oStrB17:SetProperty( 'B17_TIPO'   , MODEL_FIELD_INIT, { || iif( !Empty(BB0->BB0_CODBLO), "1", "0") } )

oModel:GetModel('MASTERB17'):SetDescription(STR0001) //Bloqueio de Profissional
oModel:SetPrimaryKey( { "B17_FILIAL", "B17_CODPFS", "DTOS(B17_DATA)" + "B17_HORA"} )

return oModel


/*//-------------------------------------------------------------------
{Protheus.doc} ViewDef
ViewDef
@since    10/2020
//-------------------------------------------------------------------*/
Static function ViewDef()
local oView     := nil
local oModel  	:= FWLoadModel('PLSA960BLO')
local oStrB17   := FWFormStruct(2, 'B17')

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('ViewB17', oStrB17, 'MASTERB17')

oView:CreateHorizontalBox( 'SUPERIOR', 50 )
oView:CreateHorizontalBox( 'INFERIOR', 50 )
oView:AddOtherObject('PANCAM',{|oPanel| HistBloProf(oPanel, oModel, oView, .f.)})

oView:SetOwnerView('ViewB17', 'SUPERIOR')
oView:SetOwnerView('PANCAM','INFERIOR')

oView:SetCloseOnOK( { || .t. } )

oView:EnableTitleView('ViewB17', STR0001) //"Bloqueio de Profissional"

return oView


static function HistBloProf(oPanel, oModel, oView, lAutoma )
local cFiltro   := "@(B17_FILIAL = '" + xFilial("B17") + "') AND B17_CODPFS = '" + BB0->BB0_CODIGO + "' "
local oBrowse	:= nil
default lAutoma := .f.

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B17')
oBrowse:SetFilterDefault(cFiltro)
oBrowse:setMenuDef('')
oBrowse:disableDetails()  
oBrowse:disableReport() 
oBrowse:SetDescription(STR0002) //'Histórico de Bloqueio do Profissional'
oBrowse:setOwner(oPanel)
iif(!lAutoma, oBrowse:activate(), '')
return


/*//-------------------------------------------------------------------
{Protheus.doc} PLS960BVLD
Valida campo de CRM e outras validações, na hora de gravar/alterar o registro.
@since    10/2020
//-------------------------------------------------------------------*/
Function PLS960BVLD(oModel, lBloqueado)
local lRet			:= .t.
local aArea			:= GetArea()
local cErro         := ""
local oObjB17		:= oModel:getModel("MASTERB17")
local oObjBB0       := FWLoadModel("PLSA960") 

oObjBB0:SetOperation(4)
oObjBB0:Activate()

if !lBloqueado
    oObjBB0:GetModel('MASTERBB0'):setValue("BB0_CODBLO", oObjB17:GetValue('B17_MOTBLO'))
    oObjBB0:GetModel('MASTERBB0'):setValue("BB0_DATBLO", oObjB17:GetValue('B17_DATA'))
else
    oObjBB0:GetModel('MASTERBB0'):setValue("BB0_CODBLO", "")
    oObjBB0:GetModel('MASTERBB0'):setValue("BB0_DATBLO", ctod(""))
endif 
	
if (oObjBB0:VldData())
    oObjBB0:commitData()
else
    lRet := .f.
    //"* Erro de Validação MVC: " / " Campo e Valor: "
    cErro := STR0007 + oObjBB0:getErrorMessage()[6] + " - " + STR0008 + oObjBB0:getErrorMessage()[4] + " - "
    cErro += iif( !empty(oObjBB0:getErrorMessage()[8]), oObjBB0:getErrorMessage()[8], '')  + CRLF
    Help(nil, nil , STR0006, nil, cErro, 1, 0, nil, nil, nil, nil, nil, {} )
endif	

oObjBB0:deActivate()
oObjBB0:destroy()
freeObj( oObjBB0 )	
RestArea(aArea)
return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} A960CHKDAT
Checa data de (des)bloqueio	
@since    13.09.06
//-------------------------------------------------------------------*/
Function A960CHKDAT()
local lRet := .t.                                                                                                                                                               
if FwFldGet("B17_DATA") < BB0->BB0_DATBLO 
    Help(nil, nil , STR0006, nil, STR0005, 1, 0, nil, nil, nil, nil, nil, {} )  //"Data de (Des)bloqueio INVALIDA!"
    lRet := .F.
EndIf 	  

Return(lRet)
