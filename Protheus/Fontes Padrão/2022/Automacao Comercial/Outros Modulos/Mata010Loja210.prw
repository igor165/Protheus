#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------
/*/{Protheus.doc} Mata010Loja210
Classe utilizada na rotina Mata010 - Cadastro de Produtos
Ira incluir o SubModelo de C�digo de Barras - SLK

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
    Method VldActivate(oModel, cModelId)                                                    //M�todo que � chamado pelo MVC quando ocorrer as a��es de valida��o do Model. Esse evento ocorre uma vez no contexto do modelo principal.    
    Method ModelDefLoja210(oModel)    
    Method ViewDefLoja210(oView)

    Method VldCodBar()

    /*
    Method After(oSubModel, cModelId, cAlias, lNewRecord)                                   //M�todo que � chamado pelo MVC quando ocorrer as a��es do commit depois da grava��o de cada submodelo (field ou cada linha de uma grid)
    Method Before(oSubModel, cModelId, cAlias, lNewRecord)                                  //M�todo que � chamado pelo MVC quando ocorrer as a��es do commit antes da grava��o de cada submodelo (field ou cada linha de uma grid)
    Method AfterTTS(oModel, cModelId)                                                       //M�todo que � chamado pelo MVC quando ocorrer as a��es do  ap�s a transa��o. Esse evento ocorre uma vez no contexto do modelo principal.
    Method BeforeTTS(oModel, cModelId)                                                      //M�todo que � chamado pelo MVC quando ocorrer as a��es do commit antes da transa��o. Esse evento ocorre uma vez no contexto do modelo principal.
    Method InTTS(oModel, cModelId)                                                          //M�todo que � chamado pelo MVC quando ocorrer as a��es do commit Ap�s as grava��es por�m antes do final da transa��o. Esse evento ocorre uma vez no contexto do modelo principal.
    Method Activate(oModel, lCopy)                                                          //M�todo que � chamado pelo MVC quando ocorrer a ativa��o do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method DeActivate(oModel)                                                               //M�todo que � chamado pelo MVC quando ocorrer a desativa��o do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method ModelPreVld(oModel, cModelId)                                                    //M�todo que � chamado pelo MVC quando ocorrer as a��es de pre valida��o do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method ModelPosVld(oModel, cModelId)                                                    //M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method GridPosVld(oSubModel, cModelID)                                                  //M�todo que � chamado pelo MVC quando ocorrer as a��es de p�s valida��o do Grid.
    Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)  //M�todo que � chamado pelo MVC quando ocorrer as a��es de pre valida��o da linha do Grid.
    Method GridLinePosVld(oSubModel, cModelID, nLine)                                       //M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o da linha do Grid.
    Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue)                           //M�todo que � chamado pelo MVC quando ocorrer a a��o de pr� valida��o do Field.
    Method FieldPosVld(oSubModel, cModelID)                                                 //M�todo que � chamado pelo MVC quando ocorrer a a��o de p�s valida��o do Field.
    Method GetEvent(cIdEvent)                                                               //M�todo que retorna um evento superior da cadeia de eventos. Atrav�s do m�todo InstallEvent, � poss�vel encadear dois eventos que est�o relacionados, como por exemplo um evento de neg�cio padr�o e um evento localizado que complementa essa regra de neg�cio. Caso o evento localizado, necessite de atributos da classe superior, ele ir� utilizar esse m�todo para recuper�-lo.
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
M�todo que � chamado pelo MVC quando ocorrer as a��es de pre valida��o do Model.
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
Adiciona o sub-modelo de C�digo de Barras ao modelo de Produtos

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
Adiciona o view do C�digo de Barras ao modelo de Produtos

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
Valida��o do campo LK_CODBAR, sobrep�em a valida��o do X3_VALID
A valida��o do X3_VALID funciona para field e n�o para grid como neste caso.

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
        oMata010M:SetErrorMessage(Self:cSubModel, "LK_CODBAR", Self:cSubModel, "LK_CODBAR", "VldCodBar", "C�digo de barras j� existe para outro produto.")
    EndIf

    RestArea(aAreaSLK)
    RestArea(aArea)

Return lRetorno