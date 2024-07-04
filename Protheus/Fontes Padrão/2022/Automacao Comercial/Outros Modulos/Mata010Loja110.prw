#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------
/*/{Protheus.doc} Mata010Loja110
Classe utilizada na rotina Mata010 - Cadastro de Produtos
Ira incluir o SubModelo de Dados Adicionais do Loja - SB0

@author  Rafael Tenorio da Costa
@since   21/05/2019
@version 1.0
/*/
//---------------------------------------------------------
Class Mata010Loja110 From FwModelEvent

    Data cModelMaster   as Character
    Data cTabela        as Character
    Data cSubModel      as Character
    Data cForm          as Character
    Data cBox           as Character
    Data lSubModelAtivo as Logical

    Method New(cModelMaster) Constructor
    Method VldActivate(oModel, cModelId)                                                    //Método que é chamado pelo MVC quando ocorrer as ações de validação do Model. Esse evento ocorre uma vez no contexto do modelo principal.    
    Method ModelDefLoja110(oModel)    
    Method ViewDefLoja110(oView, lActivate)

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
/*/{Protheus.doc} Mata010Loja110
Metodo construtor

@author  Rafael Tenorio da Costa
@since   21/05/2019
@version 1.0
/*/
//---------------------------------------------------------
Method New(cModelMaster) Class Mata010Loja110

	Self:cModelMaster   := cModelMaster
    Self:cTabela        := "SB0"
    Self:cSubModel      := "SB0DETAIL"
    Self:cForm          := "FORMSB0"
    Self:cBox           := "BOXFORMSB0"
	Self:lSubModelAtivo := Self:cTabela $ SuperGetMv("MV_CADPROD", , "|SBZ|SB5|SGI|D3E")

Return Nil

//---------------------------------------------------------
/*/{Protheus.doc} VldActivate
Método que é chamado pelo MVC quando ocorrer as ações de pre validação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@author  Rafael Tenorio da Costa
@since   21/05/2019
@version 1.0
/*/
//---------------------------------------------------------
Method VldActivate(oModel, cModelId) Class Mata010Loja110

	Self:ModelDefLoja110(oModel)

Return .T.

//---------------------------------------------------------
/*/{Protheus.doc} ModelDefLoja110
Adiciona o sub-modelo de Dados Adicionais do Loja ao modelo de Produtos

@author  Rafael Tenorio da Costa
@since   21/05/2019
@version 1.0
/*/
//---------------------------------------------------------
Method ModelDefLoja110(oModel) Class Mata010Loja110

    Local oStructSB0 := Nil
    Local nPos       := Ascan( oModel:aAllSubModels, {|x| x:cId == Self:cSubModel} )
        
    //Dados Adicionais do Loja
    If Self:lSubModelAtivo .And. nPos == 0
        oStructSB0 := FWFormStruct(1, Self:cTabela)
        oStructSB0:SetProperty("B0_COD"    , MODEL_FIELD_OBRIGAT, .F.)      //Campo preenchido pelo SetRelation
        oStructSB0:SetProperty("B0_DTHRALT", MODEL_FIELD_INIT   , {|| FWTimeStamp(3)})
                
        oModel:AddFields(Self:cSubModel, Self:cModelMaster, oStructSB0)
        oModel:SetRelation(Self:cSubModel, { {"B0_FILIAL", "xFilial('SB0')"}, {"B0_COD", "B1_COD"} }, (Self:cTabela)->(IndexKey(1)) )
        
        oModel:GetModel(Self:cSubModel):SetOptional(.T.)
    EndIf

Return Nil

//---------------------------------------------------------
/*/{Protheus.doc} ViewDefLoja110
Adiciona o view do Dados Adicionais do Loja ao modelo de Produtos

@author  Rafael Tenorio da Costa
@since   21/05/2019
@version 1.0
/*/
//---------------------------------------------------------
Method ViewDefLoja110(oView, lActivate) Class Mata010Loja110

    Local oStructSB0 := Nil
    
    If Self:lSubModelAtivo

        If lActivate
            oStructSB0 := FWFormStruct(2, Self:cTabela, {|x| !(Alltrim(x) $ "B0_COD|B0_DTHRALT")})

            oView:AddField(Self:cForm, oStructSB0, Self:cSubModel)
        Else

            oView:CreateHorizontalBox(Self:cBox, 10)
            oView:SetOwnerView(Self:cForm, Self:cBox)
            oView:EnableTitleView(Self:cForm, FwX2Nome(Self:cTabela))
        EndIf

    EndIf

Return Nil