#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CTBS014.CH" 



Static lULeiaute 	:= .F.
//Compatibilização de fontes 30/05/2018

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS014
Cadastro de Notas Explicativas J100 / J150 / J210

@author André Brito
@since 05/08/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function CTBS014(cReg, cRevCod, lUltLeiaute )
    Local oBrowse
    Local cOrigem   := FunName()  
        
    Default cReg    := '' 
    Default cRevCod := ''
    Default lUltLeiaute := .T.
    
    lULeiaute := lUltLeiaute  //Ultimo leiaute

    SetFunName('CTBS014') //Necessário para chamar o Menudef, pois a rotina CTBS014 é chamada pelo CTBS001
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CSE")
    oBrowse:SetDescription(STR0001)  // Cadastro de Notas Explicativas J100 / J150 / J210
    
    If lULeiaute //Ultimo leiaute
        oBrowse:AddLegend( "!Empty(CSE_NOTARF)" , "GREEN"  , STR0002)
        oBrowse:AddLegend( "Empty(CSE_NOTARF)"  , "BROWN"  , STR0003)
    Else
        oBrowse:AddLegend( "!Empty(CSE_NOTAEX)" , "GREEN"  , STR0002)
        oBrowse:AddLegend( "Empty(CSE_NOTAEX)"  , "BROWN"  , STR0003)
    EndIf

    If cReg == "J100"
        oBrowse:SetFilterDefault( "CSE_TPDEM == '1' .And. CSE_CODREV == '" + cRevCod + "'" ) 
    ElseIf cReg == "J150"
        oBrowse:SetFilterDefault( "CSE_TPDEM == '2'.And. CSE_CODREV == '" + cRevCod + "'" )
    ElseIf cReg == "J210"
        oBrowse:SetFilterDefault( "CSE_CLASSE == '2' .And.(CSE_TPDEM == '3' .Or. CSE_TPDEM == '4')  .And. CSE_CODREV == '" + cRevCod + "'" )
    EndIf

    oBrowse:Activate()
    SetFunName(cOrigem)

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.CTBS014" OPERATION 2 ACCESS 0  //"Visualizar" 	    	
    ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.CTBS014" OPERATION 4 ACCESS 0  //"Alterar"    	  	
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.CTBS014" OPERATION 8 ACCESS 0  //"Imprimir"  	

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
    Local oStru  := FWFormStruct(1, "CSE", /*bAvalCampo*/,/*lViewUsado*/)
    Local oModel := MPFormModel():New("CTBS014", /*bPre*/,/*bPos*/ )
    
    
    oModel:AddFields("CSEMASTER", /*cOwner*/, oStru)
    oModel:SetDescription(STR0001)  //Cadastros Notas Explicativas
    oModel:GetModel("CSEMASTER"):SetDescription(STR0001)  //Cadastros Notas Explicativas
    oModel:SetPrimarykey({'CSE_FILIAL','CSE_CODREV','CSE_CODVIS','CSE_CODAGL','CSE_TPDEM'})

    oStru:SetProperty("*", MODEL_FIELD_WHEN , {|| .F. } )
    
    // Validação para bloquear o campo CSE_NOTAEX se usar o leiaute 7
    If lULeiaute    	    	
    	oStru:SetProperty("CSE_NOTARF", MODEL_FIELD_WHEN , {|| .T. } )
    Else     	
    	oStru:SetProperty("CSE_NOTAEX", MODEL_FIELD_WHEN , {|| .T. } )
    EndIf

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
    Local oView  
    Local oModel := FWLoadModel("CTBS014")
    Local oStru  := FWFormStruct(2, "CSE")

    oView := FWFormView():New()
    oView:SetCloseOnOk({||.T.})
    oView:SetModel(oModel)

    oView:AddField("VIEW_CSE", oStru, "CSEMASTER")

    oView:CreateHorizontalBox("TELA", 100)
    oView:SetOwnerView("VIEW_CSE", "TELA")
Return oView