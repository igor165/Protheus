#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA580F.CH" 

STATIC cCobertura  := ""

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de dados para a seleção da cobertura do efetivo
	
@sample 	ModelDef()
@since		18/06/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStr1TGX := FWFormStruct( 1, "TGX", { |cCpo| Alltrim(cCpo)$"TGX_FILIAL+TGX_COD" } )
Local oStr2TGX := FWFormStruct( 1, "TGX" )

cKeyTFI := ""

oModel := MPFormModel():New("TECA580F", Nil, {|oMdl| At580FVld(oMdl)}, {|oMdl| At580FSave(oMdl)} )
oModel:SetDescription(STR0001)  // "Cobertura"

oModel:AddFields( "CAB", /*cOwner*/, oStr1TGX, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oStr1TGX:SetProperty( "*", MODEL_FIELD_OBRIGAT, Nil )
oStr2TGX:SetProperty( "*", MODEL_FIELD_OBRIGAT, Nil )

oStr1TGX:SetProperty( "TGX_COD", MODEL_FIELD_INIT, Nil )
oStr2TGX:SetProperty( "TGX_COD", MODEL_FIELD_INIT, Nil )

oModel:AddGrid( "ITENS","CAB", oStr2TGX, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/)

oModel:getModel("CAB"):SetDescription(STR0001) // "Cobertura" 
oModel:getModel("ITENS"):SetDescription(STR0001)  // "Cobertura"

oModel:SetActivate( {|oModel|InitDados(oModel)} )

Return oModel


//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface para a seleção da cobertura do efetivo
	
@sample 	ViewDef()
@since		18/06/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView    
Local oModel   := FWLoadModel("TECA580F")
Local oStr1TGX := FWFormStruct( 2, "TGX", { |cCpo| AllTrim(cCpo) $ "TGX_ITEM#TGX_TIPO" } )

oView := FWFormView():New()
oView:SetModel(oModel)

oStr1TGX:SetProperty( "*", MVC_VIEW_CANCHANGE, .F. )

oStr1TGX:SetProperty( "TGX_ITEM", MVC_VIEW_ORDEM, "01" )
oStr1TGX:SetProperty( "TGX_TIPO", MVC_VIEW_ORDEM, "03" )

oView:AddGrid( "VIEW_ITENS", oStr1TGX, "ITENS" )

oView:CreateHorizontalBox( "TELA", 100 )
oView:SetOwnerView( "VIEW_ITENS", "TELA" )

oView:SetCloseOnOK( {|| .T. } )

Return(oView)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580FSave
	Salva a cobertura selecionada
	
@sample 	At580FSave()
@since		18/06/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At580FSave(oMdl)

Local oMdlItens := oMdl:GetModel("ITENS")

cCobertura := oMdlItens:GetValue("TGX_ITEM")

Return(.T.)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580FVld
	Salva a cobertura selecionada
	
@sample 	At580FVld()
@since		25/06/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At580FVld(oMdl)

Local lRet      := .F.
Local oMdlItens := oMdl:GetModel("ITENS")
Local oMdlGer   := At580GetMdl()
Local oMdlTGW   := oMdlGer:GetModel("TGWDETAIL")

If oMdlTGW:GetValue("TGW_STATUS") == "2" // Folga
	lRet := (oMdlItens:GetValue("TGX_TIPO") == "1" .Or. oMdlItens:GetValue("TGX_TIPO") == "4")
ElseIf oMdlTGW:GetValue("TGW_STATUS") == "3" // Intervalo
	lRet := (oMdlItens:GetValue("TGX_TIPO") == "2" .Or. oMdlItens:GetValue("TGX_TIPO") == "3")
EndIf 

If !lRet
	Help( " ", 1, STR0002, Nil, STR0003, 1 )  //"Atenção"#"Tipo de cobertura invalida para a configuração do efetivo!"
EndIf	

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580FGetCob
	Devolve o codigo da cobertura selecionada 
	
@sample 	At580FGetCob()
@since		18/06/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Function At580FGetCob()
Return(cCobertura)


//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados
	Inicializa as informações para a lista de coberturas

@sample 	InitDados()
@since		25/06/2014
@version	P12

@param  	oModel, Objeto, objeto geral do model que será alterado

/*/
//------------------------------------------------------------------------------
Static Function InitDados(oModel)

Local oMdlGer := At580GetMdl()
Local oMdlTGX := oMdlGer:GetModel("TGXDETAIL")
Local oMdlITE := oModel:GetModel("ITENS")

Local nI

oModel:getModel("ITENS"):SetNoInsertLine(.F.)
oModel:getModel("ITENS"):SetNoDeleteLine(.F.)

For nI:=1 To oMdlTGX:Length()

	oMdlTGX:GoLine(nI)
	
	If nI > 1
		oMdlITE:AddLine()
	EndIf
	
	oMdlITE:SetValue( "TGX_ITEM", oMdlTGX:GetValue("TGX_ITEM") )
	oMdlITE:SetValue( "TGX_TIPO", oMdlTGX:GetValue("TGX_TIPO") )

Next nI

oModel:getModel("ITENS"):SetNoInsertLine(.T.)
oModel:getModel("ITENS"):SetNoDeleteLine(.T.)

Return(Nil)