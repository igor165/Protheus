#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------
/*/{Protheus.doc} Mata010Loja210
Classe utilizada na rotina Mata010 - Cadastro de Produtos
Ira incluir o SubModelo de Código de Barras - SLK

@author  Rafael Tenorio da Costa
@since   24/04/2019
@version 1.0
/*/
//---------------------------------------------------------
Class Mata010Loja210 From FwModelEvent

    Data cModelMaster   as Character
    Data cTabela        as Character
    Data cSubModel      as Character
    Data cForm          as Character
    Data cBox           as Character
    Data lSubModelAtivo as Logical

    Method New(cModelMaster) Constructor
    Method VldActivate(oModel, cModelId)                                                    //Método que é chamado pelo MVC quando ocorrer as ações de validação do Model. Esse evento ocorre uma vez no contexto do modelo principal.    
    Method ModelDefLoja210(oModel)    
    Method ViewDefLoja210(oView)

    Method VldCodBar()

    /*
    Method After(oSubModel, cModelId, cAlias, lNewRecord)                                   //Método que é chamado pelo MVC quando ocorrer as ações do commit depois da gravação de cada submodelo (field ou cada linha de uma grid)
    Method Before(oSubModel, cModelId, cAlias, lNewRecord)                                  //Método que é chamado pelo MVC quando ocorrer as ações do commit antes da gravação de cada submodelo (field ou cada linha de uma grid)
    Method AfterTTS(oModel, cModelId)                                                       //Método que é chamado pelo MVC quando ocorrer as ações do  após a transação. Esse evento ocorre uma vez no contexto do modelo principal.
    Method BeforeTTS(oModel, cModelId)                                                      //Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação. Esse evento ocorre uma vez no contexto do modelo principal.
    Method InTTS(oModel, cModelId)                                                          //Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém antes do final da transação. Esse evento ocorre uma vez no contexto do modelo principal.
    Method Activate(oModel, lCopy)                                                          //Método que é chamado pelo MVC quando ocorrer a ativação do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method DeActivate(oModel)                                                               //Método que é chamado pelo MVC quando ocorrer a desativação do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method ModelPreVld(oModel, cModelId)                                                    //Método que é chamado pelo MVC quando ocorrer as ações de pre validação do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method ModelPosVld(oModel, cModelId)                                                    //Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method GridPosVld(oSubModel, cModelID)                                                  //Método que é chamado pelo MVC quando ocorrer as ações de pós validação do Grid.
    Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)  //Método que é chamado pelo MVC quando ocorrer as ações de pre validação da linha do Grid.
    Method GridLinePosVld(oSubModel, cModelID, nLine)                                       //Método que é chamado pelo MVC quando ocorrer as ações de pos validação da linha do Grid.
    Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue)                           //Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field.
    Method FieldPosVld(oSubModel, cModelID)                                                 //Método que é chamado pelo MVC quando ocorrer a ação de pós validação do Field.
    Method GetEvent(cIdEvent)                                                               //Método que retorna um evento superior da cadeia de eventos. Através do método InstallEvent, é possível encadear dois eventos que estão relacionados, como por exemplo um evento de negócio padrão e um evento localizado que complementa essa regra de negócio. Caso o evento localizado, necessite de atributos da classe superior, ele irá utilizar esse método para recuperá-lo.
    */

EndClass

//---------------------------------------------------------
/*/{Protheus.doc} Mata010Loja210
Metodo construtor

@author  Rafael Tenorio da Costa
@since   24/04/2019
@version 1.0
/*/
//---------------------------------------------------------
Method New(cModelMaster) Class Mata010Loja210

	Self:cModelMaster   := cModelMaster
    Self:cTabela        := "SLK"
    Self:cSubModel      := "SLKDETAIL"
    Self:cForm          := "FORMSLK"
    Self:cBox           := "BOXFORMSLK"
	Self:lSubModelAtivo := Self:cTabela $ SuperGetMv("MV_CADPROD", , "|SBZ|SB5|SGI|D3E")

Return Nil

//---------------------------------------------------------
/*/{Protheus.doc} VldActivate
Método que é chamado pelo MVC quando ocorrer as ações de pre validação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@author  Rafael Tenorio da Costa
@since   24/04/2019
@version 1.0
/*/
//---------------------------------------------------------
Method VldActivate(oModel, cModelId) Class Mata010Loja210

	Self:ModelDefLoja210(oModel)

Return .T.

//---------------------------------------------------------
/*/{Protheus.doc} ModelDefLoja210
Adiciona o sub-modelo de Código de Barras ao modelo de Produtos

@author  Rafael Tenorio da Costa
@since   24/04/2019
@version 1.0
/*/
//---------------------------------------------------------
Method ModelDefLoja210(oModel) Class Mata010Loja210
    
    Local oStructSLK := Nil
    Local nPos       := Ascan( oModel:aAllSubModels, {|x| x:cId == Self:cSubModel} )
        
    //Dados Adicionais do Loja
    If Self:lSubModelAtivo .And. nPos == 0
        oStructSLK := FWFormStruct(1, Self:cTabela)

        oStructSLK:SetProperty("LK_CODBAR" , MODEL_FIELD_OBRIGAT, .T.)
        oStructSLK:SetProperty("LK_CODIGO" , MODEL_FIELD_OBRIGAT, .F.)      //Campo preenchido pelo SetRelation

        oStructSLK:SetProperty("LK_DTHRALT", MODEL_FIELD_INIT   , {|| FWTimeStamp(3)})

        oStructSLK:SetProperty("LK_CODBAR" , MODEL_FIELD_VALID  , {|| Self:VldCodBar()} )
                
        oModel:AddGrid(Self:cSubModel, Self:cModelMaster, oStructSLK)
        oModel:SetRelation(Self:cSubModel, { {"LK_FILIAL", "xFilial('SLK')"}, {"LK_CODIGO", "B1_COD"} }, (Self:cTabela)->(IndexKey(1)) )
        
        oModel:GetModel(Self:cSubModel):SetUniqueLine({"LK_CODBAR"})
        oModel:GetModel(Self:cSubModel):SetOptional(.T.)        
    EndIf

Return Nil

//---------------------------------------------------------
/*/{Protheus.doc} ViewDefLoja210
Adiciona o view do Código de Barras ao modelo de Produtos

@author  Rafael Tenorio da Costa
@since   24/04/2019
@version 1.0
/*/
//---------------------------------------------------------
Method ViewDefLoja210(oView) Class Mata010Loja210

    Local oStructSLK := Nil
    Local nPos       := aScan( oView:aViews, {|x| x[VIEWS_VIEW_ID] == Self:cForm} )

	If oView:GetModel():GetModel(Self:cSubModel) <> NIL .and. nPos == 0	
		oStructSLK := FWFormStruct(2, Self:cTabela, {|x| !(Alltrim(x) $ "LK_CODIGO|LK_DTHRALT")})

		oView:AddGrid(Self:cForm, oStructSLK, Self:cSubModel)

		oView:CreateHorizontalBox(Self:cBox, 10)
		oView:SetOwnerView(Self:cForm, Self:cBox)
		oView:EnableTitleView(Self:cForm, FwX2Nome(Self:cTabela) )
	EndIf

Return Nil

//---------------------------------------------------------
/*/{Protheus.doc} VldCodBar
Validação do campo LK_CODBAR, sobrepõem a validação do X3_VALID
A validação do X3_VALID funciona para field e não para grid como neste caso.

@author  Rafael Tenorio da Costa
@since   21/05/2019
@version 1.0
/*/
//---------------------------------------------------------
Method VldCodBar(oView) Class Mata010Loja210

    Local aArea     := GetArea()
    Local aAreaSLK  := SLK->( GetArea() )
    Local lRetorno  := .T.
    Local oMata010M := FWModelActive()

    If SLK->( DbSeek(xFilial("SLK") + FwFldGet("LK_CODBAR")) ) .And. FwFldGet("B1_COD") <> SLK->LK_CODIGO
        lRetorno := .F.
        oMata010M:SetErrorMessage(Self:cSubModel, "LK_CODBAR", Self:cSubModel, "LK_CODBAR", "VldCodBar", "Código de barras já existe para outro produto.")
    EndIf

    RestArea(aAreaSLK)
    RestArea(aArea)

Return lRetorno