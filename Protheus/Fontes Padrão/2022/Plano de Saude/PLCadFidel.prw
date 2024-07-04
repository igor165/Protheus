#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include 'FWMVCDEF.CH'
#Include 'PLCadFidel.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc}) PLCadFidel
Cadastro de Fidelidades

@author  Cesar Almeida
@version P12
@since   24.08.22
/*/
//-------------------------------------------------------------------

Function PLCadFidel()

    Local aArea := GetArea()
    Local oBrowse := Nil

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("BWH")
    oBrowse:SetDescription("Cadastro de Fidelidade") 
  
    oBrowse:Activate()

    RestArea(aArea)
     
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}) MenuDef
Atualizacao do menu funcional 

@author  Cesar Almeida
@version P12
@since   24.08.22
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina := {} 

    ADD OPTION aRotina Title STR0001  Action 'VIEWDEF.PLCadFidel' OPERATION MODEL_OPERATION_VIEW ACCESS 0 //"Visualizar"
    ADD OPTION aRotina Title STR0002   Action 'VIEWDEF.PLCadFidel' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //"Incluir"
    ADD OPTION aRotina Title STR0003   Action 'VIEWDEF.PLCadFidel' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //"Alterar"
    ADD OPTION aRotina Title STR0004   Action 'VIEWDEF.PLCadFidel' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //"Excluir"
    
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}) ModelDef
Modelo de Dados para o Cadastro de Fidelidade

@author  Cesar Almeida
@version P12
@since   24.08.22
/*/
//------------------------------------------------------------------- 
Static Function ModelDef()

    Local oModel := Nil
    Local oStruBWH := FWFormStruct(1, 'BWH')
  
    oModel := MPFormModel():New('PLCadFidel')
    oModel:AddFields('FORMBWH',/*cOwner*/,oStruBWH)

    oModel:SetPrimaryKey({'BWH_FILIAL','BWH_CODOP','BWH_COD'})

    oModel:SetDescription("Cadastro de Fidelidade")

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela de Cadastro de Fidelidade

@author  Cesar Almeida
@version P12
@since   24.08.22
/*/
//------------------------------------------------------------------- 
Static Function ViewDef()

    Local oView := Nil
    Local oModel := FWLoadModel('PLCadFidel')
    Local oStruBWH := FWFormStruct(2, 'BWH')
         
    oView := FWFormView():New()     
    oView:SetModel(oModel)     
    oView:AddField('VIEW_BWH',oStruBWH,'FORMBWH') 

    oView:CreateHorizontalBox('TELA' , 100)  
    oView:SetOwnerView('VIEW_BWH', 'TELA')

  Return oView
