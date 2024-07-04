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
    Method VldActivate(oModel, cModelId)                                                    //M�todo que � chamado pelo MVC quando ocorrer as a��es de valida��o do Model. Esse evento ocorre uma vez no contexto do modelo principal.    
    Method ModelDefLoja110(oModel)    
    Method ViewDefLoja110(oView, lActivate)

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
M�todo que � chamado pelo MVC quando ocorrer as a��es de pre valida��o do Model.
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