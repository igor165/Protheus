#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA161.CH"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TECA161

@description TECA161 - Base Operacional
@author Vitor kwon
@since  17/12/2021
/*/
//--------------------------------------------------------------------------------

Function TECA161()

Local oBrowse
 
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AA0')
oBrowse:SetDescription(STR0001) //"Base Operacional"
oBrowse:DisableDetails()
oBrowse:Activate()

Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef

@description Menudef
@author Vitor kwon
@since  17/12/2021
/*/
//--------------------------------------------------------------------------------

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002  ACTION 'VIEWDEF.TECA161' OPERATION 1 ACCESS 0 // Pesquisar
ADD OPTION aRotina TITLE STR0003  ACTION 'At161Menu'       OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0004  ACTION 'VIEWDEF.TECA161' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0005  ACTION 'At161Menu'       OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0006  ACTION 'At161Menu'       OPERATION 5 ACCESS 0 // Excluir

Return (aRotina)


//--------------------------------------------------------------------------------
/*/{Protheus.doc} At161Menu

@description Menu conforme parametro e tabela de integracao RH
@author Flavio Vicco
@since  15/06/2022
@return Nenhum
/*/
//--------------------------------------------------------------------------------
Function At161Menu(cAlias, nReg, nOpc)
Local cRotina := Iif(SuperGetMv("MV_TECXRH",,.F.).And.TableInDic("REI"),'TECA161A','TECA161')

If nOpc == 2
	FWExecView('',cRotina, MODEL_OPERATION_VIEW, , /*{ || .T. }*/, , ,/*aButtons*/ )
ElseIf nOpc == 4
	FWExecView('',cRotina, MODEL_OPERATION_UPDATE, , /*{ || .T. }*/, , ,/*aButtons*/ )
ElseIf nOpc == 5
	FWExecView('',cRotina, MODEL_OPERATION_DELETE, , /*{ || .T. }*/, , ,/*aButtons*/ )
EndIf
Return Nil


//--------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@description ModelDef
@author Vitor kwon
@since  17/12/2021
/*/
//--------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel    :=  Nil
Local oStruAA0  :=  FWFormStruct(1,'AA0')
Local aAux      :=  {}

aAux := FwStruTrigger("AA0_LOCPAD","AA0_DESCLO","AT161LOCA()",.F.,Nil,Nil,Nil)
oStruAA0:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

oModel := MPFormModel():New('TECA161',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)

oModel:AddFields('AA0MASTER',/*cOwner*/,oStruAA0,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/,/*bFieldAbp*/)

oModel:SetPrimaryKey({"AA0_FILIAL","AA0_CODIGO"})
oModel:SetDescription(STR0001) //Base Operacional

Return(oModel)


//--------------------------------------------------------------------------------
/*/{Protheus.doc} Viewdef

@description Viewdef
@author Vitor kwon
@since  17/12/2021
/*/
//--------------------------------------------------------------------------------

Static Function ViewDef()

Local oView     := NIL
Local oModel    := ModelDef()
Local oStruAA0  := FWFormStruct(2,'AA0')

oView:= FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_CAB',oStruAA0,'AA0MASTER')

oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_CAB','TELA')

Return(oView)


//--------------------------------------------------------------------------------
/*/{Protheus.doc} AT161LOCA

@description Gatilho do Armazem campo AA0_LOCPAD X AA0_DESCLO
@author Vitor kwon
@since  17/12/2021
@retorno - Descrição do armazem
/*/
//--------------------------------------------------------------------------------
Function AT161LOCA()

Local cArmazem  := ""
Local aArea	    := GetArea()

cArmazem  := Alltrim(Posicione("NNR",1,xFilial("NNR")+FwFldGet("AA0_LOCPAD"),"NNR_DESCRI"))  

RestArea(aArea)

Return cArmazem 
