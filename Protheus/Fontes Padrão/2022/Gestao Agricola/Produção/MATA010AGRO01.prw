#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA010AGRO01.CH"

//---------------------------------------------------------
/*/{Protheus.doc} MATA010AGRO01
Classe utilizada na rotina Mata010 - Cadastro de Produtos
Ira incluir o SubModelo de Dados Adicionais do Produto Agronegocio - NCR|NCM

@author  Agroindustria
@since   18/08/2020
@version 1.0
/*/
//---------------------------------------------------------
Class MATA010AGRO01 From FwModelEvent

    Data cModelMaster   as Character

    Method New(cModelMaster) Constructor
    Method VldActivate(oModel, cModelId)                                                    //Método que é chamado pelo MVC quando ocorrer as ações de validação do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method ModelDefAGRO(oModel)
    Method ViewDefAGRO(oView, lActivate)
    Method FieldPreVld()  
    Method FieldPosVld()   

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
/*/{Protheus.doc} New
Metodo construtor

@author  Agroindustria
@since   18/08/2020
@version 1.0
/*/
//---------------------------------------------------------
Method New(cModelMaster) Class MATA010AGRO01

    Self:cModelMaster   := cModelMaster

Return Nil

//---------------------------------------------------------
/*/{Protheus.doc} VldActivate
Método que é chamado pelo MVC quando ocorrer as ações de pre validação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@author  Agroindustria
@since   18/08/2020
@version 1.0
/*/
//---------------------------------------------------------
Method VldActivate(oModel, cModelId) Class MATA010AGRO01

    Self:ModelDefAGRO(oModel)

Return .T.

//---------------------------------------------------------
/*/{Protheus.doc} ModelDefAGRO
Adiciona o sub-modelo de Dados Adicionais do Produto Agronegocio ao modelo de Produtos

@author  Agroindustria
@since   18/08/2020
@version 1.0
/*/
//---------------------------------------------------------
Method ModelDefAGRO(oModel) Class MATA010AGRO01

    Local oStruct := Nil

    //Dados Adicionais do Loja
    // ----------------------------------------------
    //   Modelo NCR (produto agronegócio).
    // ----------------------------------------------
    // Adiciona ao modelo um componente de grid.
    oStruct := FWFormStruct(1, 'NCR')
    oModel:AddFields('FORMNCR', Self:cModelMaster, oStruct)
    oModel:SetRelation('FORMNCR', {{'NCR_FILIAL', 'xFilial("NCR")'}, {'NCR_PROD', 'B1_COD'}}, ('NCR')->(IndexKey(1)) )
    oModel:GetModel('FORMNCR'):SetDescription(FwX2Nome('NCR'))
    oModel:GetModel('FORMNCR'):SetOptional(.T.)

    // ----------------------------------------------
    //   Modelo NC7 (mantenedor).
    // ----------------------------------------------
    // Adiciona ao modelo um componente de grid.
    oStruct := FWFormStruct(1, 'NCM')
    oStruct:SetProperty('NCM_CODREG', MODEL_FIELD_VALID ,  {||, Vazio() .or. ExistCpo("NC7",, 1)} ) //7=MODEL_FIELD_VALID
    oStruct:SetProperty('NCM_DESCRI', MODEL_FIELD_INIT , {||, Posicione("NC7", 1, NCM->(NCM_FILREG + NCM_CODREG), "NC7_DESCRI")}) 
    oStruct:AddTrigger("NCM_CODREG", "NCM_DESCRI",, {|oModel| Posicione("NC7", 1, xFilial("NC7") + oModel:GetValue("NCM_CODREG"), "NC7_DESCRI")})

    oModel:AddGrid('FORMNC7', Self:cModelMaster, oStruct)
    oModel:SetRelation('FORMNC7', {{'NCM_FILIAL', 'xFilial("NCM")'}, {'NCM_PROD', 'B1_COD'}, {'NCM_ALIAS', '"NC7"'}, {'NCM_FILREG', 'xFilial("NC7")'}}, NCM->(IndexKey(1)))
    oModel:GetModel('FORMNC7'):SetDescription(FwX2Nome("NC7"))
    oModel:GetModel('FORMNC7'):SetOptional(.T.)  // Deixa a grid não obrigatória.
    oModel:GetModel('FORMNC7'):SetUniqueLine({"NCM_CODREG"})

    // ----------------------------------------------
    //   Modelo NCD (alvos / fitossanidade).
    // ----------------------------------------------
    // Adiciona ao modelo um componente de grid.
    oStruct := FWFormStruct(1, 'NCM')
    oStruct:SetProperty('NCM_CODREG', MODEL_FIELD_VALID ,  {||, Vazio() .or. ExistCpo("NCD",, 1)})
    oStruct:SetProperty('NCM_DESCRI', MODEL_FIELD_INIT, {||, Posicione("NCD", 1, NCM->(NCM_FILREG + NCM_CODREG), "NCD_DESCRI")})
    oStruct:AddTrigger("NCM_CODREG", "NCM_DESCRI",, {|oModel| Posicione("NCD", 1, xFilial("NCD") + oModel:GetValue("NCM_CODREG"), "NCD_DESCRI")})
    oStruct:SetProperty('NCM_CULDES', MODEL_FIELD_INIT, {||, Posicione("NP3", 1, xFilial("NP3") + NCM->NCM_CULTUR, "NP3_DESCRI")})
    oStruct:AddTrigger("NCM_CULTUR", "NCM_CULDES",, {|oModel| Posicione("NP3", 1, xFilial("NP3") + oModel:GetValue("NCM_CULTUR"), "NP3_DESCRI")})

    oModel:AddGrid('FORMNCD', Self:cModelMaster, oStruct)
    oModel:SetRelation('FORMNCD', {{'NCM_FILIAL', 'xFilial("NCM")'}, {'NCM_PROD', 'B1_COD'}, {'NCM_ALIAS', '"NCD"'}, {'NCM_FILREG', 'xFilial("NCD")'}}, NCM->(IndexKey(1)))
    oModel:GetModel('FORMNCD'):SetDescription(FwX2Nome("NCD"))
    oModel:GetModel('FORMNCD'):SetOptional(.T.)  // Deixa a grid não obrigatória.
    oModel:GetModel('FORMNCD'):SetUniqueLine({"NCM_CODREG"})

    // ----------------------------------------------
    //   Modelo NCK (grupos químicos).
    // ----------------------------------------------
    // Adiciona ao modelo um componente de grid.
    oStruct := FWFormStruct(1, 'NCM')
    oStruct:SetProperty('NCM_CODREG', MODEL_FIELD_VALID ,  {||, Vazio() .or. ExistCpo("NCK",, 1) } )
    oStruct:SetProperty('NCM_DESCRI', MODEL_FIELD_INIT , {||, Posicione("NCK", 1, NCM->(NCM_FILREG + NCM_CODREG), "NCK_DESCRI")} )
    oStruct:AddTrigger("NCM_CODREG", "NCM_DESCRI",, {|oModel| Posicione("NCK", 1, xFilial("NCK") + oModel:GetValue("NCM_CODREG"), "NCK_DESCRI")})

    oModel:AddGrid('FORMNCK', Self:cModelMaster, oStruct)
    oModel:SetRelation('FORMNCK', {{'NCM_FILIAL', 'xFilial("NCM")'}, {'NCM_PROD', 'B1_COD'}, {'NCM_ALIAS', '"NCK"'}, {'NCM_FILREG', 'xFilial("NCK")'}}, NCM->(IndexKey(1)))
    oModel:GetModel('FORMNCK'):SetDescription(FwX2Nome("NCK"))
    oModel:GetModel('FORMNCK'):SetOptional(.T.)  // Deixa a grid não obrigatória.
    oModel:GetModel('FORMNCK'):SetUniqueLine({"NCM_CODREG"})

    // ----------------------------------------------
    //   Modelo NCE (princípio ativo).
    // ----------------------------------------------
    // Adiciona ao modelo um componente de grid.
    oStruct := FWFormStruct(1, 'NCM')
    oStruct:SetProperty('NCM_CODREG', MODEL_FIELD_VALID ,  {||, Vazio() .or. ExistCpo("NCE",, 1) } )
    oStruct:SetProperty('NCM_DESCRI', MODEL_FIELD_INIT , {||, Posicione("NCE", 1, NCM->(NCM_FILREG + NCM_CODREG), "NCE_DESCRI") } )
    oStruct:AddTrigger("NCM_CODREG", "NCM_DESCRI",, {|oModel| Posicione("NCE", 1, xFilial("NCE") + oModel:GetValue("NCM_CODREG"), "NCE_DESCRI")})

    oModel:AddGrid('FORMNCE', Self:cModelMaster, oStruct)
    oModel:SetRelation('FORMNCE', {{'NCM_FILIAL', 'xFilial("NCM")'}, {'NCM_PROD', 'B1_COD'}, {'NCM_ALIAS', '"NCE"'}, {'NCM_FILREG', 'xFilial("NCE")'}}, NCM->(IndexKey(1)))
    oModel:GetModel('FORMNCE'):SetDescription(FwX2Nome("NCE"))
    oModel:GetModel('FORMNCE'):SetOptional(.T.)  // Deixa a grid não obrigatória.
    oModel:GetModel('FORMNCE'):SetUniqueLine({"NCM_CODREG"})

    // ----------------------------------------------
    //   Modelo NP3 (cultura).
    // ----------------------------------------------
    // Adiciona ao modelo um componente de grid.
    oStruct := FWFormStruct(1, 'NCM')
    oStruct:SetProperty('NCM_CODREG', MODEL_FIELD_VALID ,  {||, Vazio() .or. ExistCpo("NP3",, 1) } )
    oStruct:SetProperty('NCM_DESCRI', MODEL_FIELD_INIT , {||, Posicione("NP3", 1, NCM->(NCM_FILREG + NCM_CODREG), "NP3_DESCRI") } )
    oStruct:AddTrigger("NCM_CODREG", "NCM_DESCRI",, {|oModel| Posicione("NP3", 1, xFilial("NP3") + oModel:GetValue("NCM_CODREG"), "NP3_DESCRI") } )

    oModel:AddGrid('FORMNP3', Self:cModelMaster, oStruct)
    oModel:SetRelation('FORMNP3', {{'NCM_FILIAL', 'xFilial("NCM")'}, {'NCM_PROD', 'B1_COD'}, {'NCM_ALIAS', '"NP3"'}, {'NCM_FILREG', 'xFilial("NP3")'}}, NCM->(IndexKey(1)))
    oModel:GetModel('FORMNP3'):SetDescription(FwX2Nome("NP3"))
    oModel:GetModel('FORMNP3'):SetOptional(.T.)  // Deixa a grid não obrigatória.
    oModel:GetModel('FORMNP3'):SetUniqueLine({"NCM_CODREG"})

    // ----------------------------------------------
    //   Modelo NCC (tecnologia da aplicação).
    // ----------------------------------------------
    // Adiciona ao modelo um componente de grid.
    oStruct := FWFormStruct(1, 'NCM')
    oStruct:SetProperty('NCM_CODREG', MODEL_FIELD_VALID ,  {||, Vazio() .or. ExistCpo("NCC",, 1) } )
    oStruct:SetProperty('NCM_DESCRI', MODEL_FIELD_INIT , {||, Posicione("NCC", 1, NCM->(NCM_FILREG + NCM_CODREG), "NCC_DESCRI") } )
    oStruct:AddTrigger("NCM_CODREG", "NCM_DESCRI",, {|oModel| Posicione("NCC", 1, xFilial("NCC") + oModel:GetValue("NCM_CODREG"), "NCC_DESCRI")})

    oModel:AddGrid('FORMNCC', Self:cModelMaster, oStruct)
    oModel:SetRelation('FORMNCC', {{'NCM_FILIAL', 'xFilial("NCM")'}, {'NCM_PROD', 'B1_COD'}, {'NCM_ALIAS', '"NCC"'}, {'NCM_FILREG', 'xFilial("NCC")'}}, NCM->(IndexKey(1)))
    oModel:GetModel('FORMNCC'):SetDescription(FwX2Nome("NCC"))
    oModel:GetModel('FORMNCC'):SetOptional(.T.)  // Deixa a grid não obrigatória.
    oModel:GetModel('FORMNCC'):SetUniqueLine({"NCM_CODREG"})

    // ----------------------------------------------
    //   Modelo NCP (EPI).
    // ----------------------------------------------
    // Adiciona ao modelo um componente de grid.
    oStruct := FWFormStruct(1, 'NCM')
    oStruct:SetProperty('NCM_CODREG', MODEL_FIELD_VALID ,  {||, Vazio() .or. ExistCpo("NCP",, 1)} )
    oStruct:SetProperty('NCM_DESCRI', MODEL_FIELD_INIT , {||, Posicione("NCP", 1, NCM->(NCM_FILREG + NCM_CODREG), "NCP_DESCRI")} )
    oStruct:AddTrigger("NCM_CODREG", "NCM_DESCRI",, {|oModel| Posicione("NCP", 1, xFilial("NCP") + oModel:GetValue("NCM_CODREG"), "NCP_DESCRI")})

    oModel:AddGrid('FORMNCP', Self:cModelMaster, oStruct)
    oModel:SetRelation('FORMNCP', {{'NCM_FILIAL', 'xFilial("NCM")'}, {'NCM_PROD', 'B1_COD'}, {'NCM_ALIAS', '"NCP"'}, {'NCM_FILREG', 'xFilial("NCP")'}}, NCM->(IndexKey(1)))
    oModel:GetModel('FORMNCP'):SetDescription(FwX2Nome("NCP"))
    oModel:GetModel('FORMNCP'):SetOptional(.T.)  // Deixa a grid não obrigatória.
    oModel:GetModel('FORMNCP'):SetUniqueLine({"NCM_CODREG"})

    // ----------------------------------------------
    //   Modelo NCJ (evento genético).
    // ----------------------------------------------
    // Adiciona ao modelo um componente de grid.
    oStruct := FWFormStruct(1, 'NCM')
    oStruct:SetProperty('NCM_CODREG', MODEL_FIELD_VALID ,  {||, Vazio() .or. ExistCpo("NCJ",, 1)} )
    oStruct:SetProperty('NCM_DESCRI', MODEL_FIELD_INIT , {||, Posicione("NCJ", 1, NCM->(NCM_FILREG + NCM_CODREG), "NCJ_DESCRI")} )
    oStruct:AddTrigger("NCM_CODREG", "NCM_DESCRI",, {|oModel| Posicione("NCJ", 1, xFilial("NCJ") + oModel:GetValue("NCM_CODREG"), "NCJ_DESCRI")})

    oModel:AddGrid('FORMNCJ', Self:cModelMaster, oStruct)
    oModel:SetRelation('FORMNCJ', {{'NCM_FILIAL', 'xFilial("NCM")'}, {'NCM_PROD', 'B1_COD'}, {'NCM_ALIAS', '"NCJ"'}, {'NCM_FILREG', 'xFilial("NCJ")'}}, NCM->(IndexKey(1)))
    oModel:GetModel('FORMNCJ'):SetDescription(FwX2Nome("NCJ"))
    oModel:GetModel('FORMNCJ'):SetOptional(.T.)  // Deixa a grid não obrigatória.
    oModel:GetModel('FORMNCJ'):SetUniqueLine({"NCM_CODREG"})

    // ----------------------------------------------
    //   Modelo NCA (tecnologia da variedade).
    // ----------------------------------------------
    // Adiciona ao modelo um componente de grid.
    oStruct := FWFormStruct(1, 'NCM')
    oStruct:SetProperty('NCM_CODREG', MODEL_FIELD_VALID ,  {||, Vazio() .or. ExistCpo("NCA",, 1)} )
    oStruct:SetProperty('NCM_DESCRI', MODEL_FIELD_INIT , {||, Posicione("NCA", 1, NCM->(NCM_FILREG + NCM_CODREG), "NCA_DESCRI")} )
    oStruct:AddTrigger("NCM_CODREG", "NCM_DESCRI",, {|oModel| Posicione("NCA", 1, xFilial("NCA") + oModel:GetValue("NCM_CODREG"), "NCA_DESCRI")})

    oModel:AddGrid('FORMNCA', Self:cModelMaster, oStruct)
    oModel:SetRelation('FORMNCA', {{'NCM_FILIAL', 'xFilial("NCM")'}, {'NCM_PROD', 'B1_COD'}, {'NCM_ALIAS', '"NCA"'}, {'NCM_FILREG', 'xFilial("NCA")'}}, NCM->(IndexKey(1)))
    oModel:GetModel('FORMNCA'):SetDescription(FwX2Nome("NCA"))
    oModel:GetModel('FORMNCA'):SetOptional(.T.)  // Deixa a grid não obrigatória.
    oModel:GetModel('FORMNCA'):SetUniqueLine({"NCM_CODREG"})

    // ----------------------------------------------
    //   Modelo NCO (sistema de aplicação).
    // ----------------------------------------------
    // Adiciona ao modelo um componente de grid.
    oStruct := FWFormStruct(1, 'NCM')
    oStruct:SetProperty('NCM_CODREG', MODEL_FIELD_VALID ,  {||, Vazio() .or. ExistCpo("NCO",, 1)} )
    oStruct:SetProperty('NCM_DESCRI', MODEL_FIELD_INIT , {||, Posicione("NCO", 1, NCM->(NCM_FILREG + NCM_CODREG), "NCO_DESCRI")} )
    oStruct:AddTrigger("NCM_CODREG", "NCM_DESCRI",, {|oModel| Posicione("NCO", 1, xFilial("NCO") + oModel:GetValue("NCM_CODREG"), "NCO_DESCRI")})

    oModel:AddGrid('FORMNCO', Self:cModelMaster, oStruct)
    oModel:SetRelation('FORMNCO', {{'NCM_FILIAL', 'xFilial("NCM")'}, {'NCM_PROD', 'B1_COD'}, {'NCM_ALIAS', '"NCO"'}, {'NCM_FILREG', 'xFilial("NCO")'}}, NCM->(IndexKey(1)))
    oModel:GetModel('FORMNCO'):SetDescription(FwX2Nome("NCO"))
    oModel:GetModel('FORMNCO'):SetOptional(.T.)  // Deixa a grid não obrigatória.
    oModel:GetModel('FORMNCO'):SetUniqueLine({"NCM_CODREG"})

Return Nil

//---------------------------------------------------------
/*/{Protheus.doc} ViewDefAGRO
Adiciona o view do Dados Adicionais do Produto Agronegocio ao modelo de Produtos

@author  Agroindustria
@since   18/08/2020
@version 1.0
/*/
//---------------------------------------------------------
Method ViewDefAGRO(oView) Class MATA010AGRO01

    Local oStruct := Nil
    // ----------------------------------------------
    //   Visão NCR (produto agronegócio).
    // ----------------------------------------------
    // Cria field e amarra à aba criada.
    oStruct := FWFormStruct(2, 'NCR')
    oView:AddField('VIEW_NCR', oStruct, 'FORMNCR')
    oView:GetViewObj("VIEW_NCR")[3]:lCanChange := .T.
    oView:CreateHorizontalBox('FOLDER_NCR', 10)
    oView:SetOwnerView('VIEW_NCR', 'FOLDER_NCR')
    oView:EnableTitleView('VIEW_NCR', FwX2Nome('NCR'))

    // ----------------------------------------------
    //   Cria objeto folder.
    // ----------------------------------------------
    oView:CreateHorizontalBox('BOX_AGRO', 10)
    oView:CreateFolder('FOLDER_AGRO', 'BOX_AGRO')
 
    // ----------------------------------------------
    //   Visão NC7 (mantenedor).
    // ----------------------------------------------
    // Cria aba.
    oView:AddSheet('FOLDER_AGRO', 'ABA_NC7', FwX2Nome('NC7'))
    oView:CreateHorizontalBox('FOLDER_NC7', 100,,, 'FOLDER_AGRO', 'ABA_NC7')
    // Cria grid e amarra à aba criada.
    oStruct := FWFormStruct(2, 'NCM',{|cCampo| ALLTRIM(cCampo) $ "NCM_CODREG|NCM_DESCRI|NCM_OBS"})
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_TITULO  , RetTitle('NC7_CODIGO')) //3=MVC_VIEW_TITULO
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_LOOKUP , 'NC7') //9=MVC_VIEW_LOOKUP
    oView:AddGrid('VIEW_NC7', oStruct, 'FORMNC7')
    oView:SetOwnerView('VIEW_NC7', 'FOLDER_NC7')

    // ----------------------------------------------
    //   Visão NCD (alvo / fitossanidade).
    // ----------------------------------------------
    // Cria aba.
    oView:AddSheet('FOLDER_AGRO', 'ABA_NCD', FwX2Nome('NCD'))
    oView:CreateHorizontalBox('FOLDER_NCD', 100,,, 'FOLDER_AGRO', 'ABA_NCD')
    // Cria grid e amarra à aba criada.
    oStruct := FWFormStruct(2, 'NCM',{|cCampo| ALLTRIM(cCampo) $ "NCM_CODREG|NCM_DESCRI|NCM_OBS|NCM_CULTUR|NCM_CULDES|NCM_DOSMIN|NCM_DOSMAX|NCM_DOSREC"})
    //ViewField(oStruct, {'NCM_CULTUR', 'NCM_CULDES', 'NCM_DOSMIN', 'NCM_DOSMAX', 'NCM_DOSREC'})
    oStruct:SetProperty('NCM_CODREG',MVC_VIEW_TITULO, RetTitle('NCD_CODIGO'))
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_LOOKUP , 'NCD')
    oView:AddGrid('VIEW_NCD', oStruct, 'FORMNCD')
    oView:SetOwnerView('VIEW_NCD', 'FOLDER_NCD')

    // ----------------------------------------------
    //   Visão NCK (grupos químicos).
    // ----------------------------------------------
    // Cria aba.
    oView:AddSheet('FOLDER_AGRO', 'ABA_NCK', FwX2Nome('NCK'))
    oView:CreateHorizontalBox('FOLDER_NCK', 100,,, 'FOLDER_AGRO', 'ABA_NCK')
    // Cria grid e amarra à aba criada.
    oStruct := FWFormStruct(2, 'NCM',{|cCampo| ALLTRIM(cCampo) $ "NCM_CODREG|NCM_DESCRI|NCM_OBS"})
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_TITULO , RetTitle('NCK_CODIGO'))
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_LOOKUP , 'NCK')
    oView:AddGrid('VIEW_NCK', oStruct, 'FORMNCK')
    oView:SetOwnerView('VIEW_NCK', 'FOLDER_NCK')

    // ----------------------------------------------
    //   Visão NCE (princípio ativo).
    // ----------------------------------------------
    // Cria aba.
    oView:AddSheet('FOLDER_AGRO', 'ABA_NCE', FwX2Nome('NCE'))
    oView:CreateHorizontalBox('FOLDER_NCE', 100,,, 'FOLDER_AGRO', 'ABA_NCE')
    // Cria grid e amarra à aba criada.
    oStruct := FWFormStruct(2, 'NCM',{|cCampo| ALLTRIM(cCampo) $ "NCM_CODREG|NCM_DESCRI|NCM_OBS|NCM_PERCON|NCM_QTDCON|NCM_UM|NCM_UMBASE"})
    //ViewField(oStruct, {'NCM_PERCON', 'NCM_QTDCON', 'NCM_UM', 'NCM_UMBASE'})
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_TITULO , RetTitle('NCE_CODIGO'))
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_LOOKUP , 'NCE')
    oView:AddGrid('VIEW_NCE', oStruct, 'FORMNCE')
    oView:SetOwnerView('VIEW_NCE', 'FOLDER_NCE')

    // ----------------------------------------------
    //   Visão NP3 (cultura).
    // ----------------------------------------------
    // Cria aba.
    oView:AddSheet('FOLDER_AGRO', 'ABA_NP3', FwX2Nome('NP3'))
    oView:CreateHorizontalBox('FOLDER_NP3', 100,,, 'FOLDER_AGRO', 'ABA_NP3')
    // Cria grid e amarra à aba criada.
    oStruct := FWFormStruct(2, 'NCM',{|cCampo| ALLTRIM(cCampo) $ "NCM_CODREG|NCM_DESCRI|NCM_OBS|NCM_CARCOL|NCM_CARREE"})
    //ViewField(oStruct, {'NCM_CARCOL', 'NCM_CARREE'})
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_TITULO , RetTitle('NP3_CODIGO'))
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_LOOKUP , 'NP3')
    oView:AddGrid('VIEW_NP3', oStruct, 'FORMNP3')
    oView:SetOwnerView('VIEW_NP3', 'FOLDER_NP3')

    // ----------------------------------------------
    //   Visão NCC (tecnologia da aplicação).
    // ----------------------------------------------
    // Cria aba.
    oView:AddSheet('FOLDER_AGRO', 'ABA_NCC', FwX2Nome('NCC'))
    oView:CreateHorizontalBox('FOLDER_NCC', 100,,, 'FOLDER_AGRO', 'ABA_NCC')
    // Cria grid e amarra à aba criada.
    oStruct := FWFormStruct(2, 'NCM',{|cCampo| ALLTRIM(cCampo) $ "NCM_CODREG|NCM_DESCRI|NCM_OBS"})
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_TITULO , RetTitle('NCC_CODIGO'))
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_LOOKUP , 'NCC')
    oView:AddGrid('VIEW_NCC', oStruct, 'FORMNCC')
    oView:SetOwnerView('VIEW_NCC', 'FOLDER_NCC')

    // ----------------------------------------------
    //   Visão NCP (EPI).
    // ----------------------------------------------
    // Cria aba.
    oView:AddSheet('FOLDER_AGRO', 'ABA_NCP', FwX2Nome('NCP'))
    oView:CreateHorizontalBox('FOLDER_NCP', 100,,, 'FOLDER_AGRO', 'ABA_NCP')
    // Cria grid e amarra à aba criada.
    oStruct := FWFormStruct(2, 'NCM',{|cCampo| ALLTRIM(cCampo) $ "NCM_CODREG|NCM_DESCRI|NCM_OBS"})
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_TITULO , RetTitle('NCP_CODIGO'))
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_LOOKUP , 'NCPEPI')
    oView:AddGrid('VIEW_NCP', oStruct, 'FORMNCP')
    oView:SetOwnerView('VIEW_NCP', 'FOLDER_NCP')

    // ----------------------------------------------
    //   Visão NCJ (evento genético).
    // ----------------------------------------------
    // Cria aba.
    oView:AddSheet('FOLDER_AGRO', 'ABA_NCJ', FwX2Nome('NCJ'))
    oView:CreateHorizontalBox('FOLDER_NCJ', 100,,, 'FOLDER_AGRO', 'ABA_NCJ')
    // Cria grid e amarra à aba criada.
    oStruct := FWFormStruct(2, 'NCM',{|cCampo| ALLTRIM(cCampo) $ "NCM_CODREG|NCM_DESCRI|NCM_OBS"})
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_TITULO , RetTitle('NCJ_CODIGO'))
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_LOOKUP , 'NCJ')
    oView:AddGrid('VIEW_NCJ', oStruct, 'FORMNCJ')
    oView:SetOwnerView('VIEW_NCJ', 'FOLDER_NCJ')

    // ----------------------------------------------
    //   Visão NCA (tecnologia da variedade).
    // ----------------------------------------------
    // Cria aba.
    oView:AddSheet('FOLDER_AGRO', 'ABA_NCA', FwX2Nome('NCA'))
    oView:CreateHorizontalBox('FOLDER_NCA', 100,,, 'FOLDER_AGRO', 'ABA_NCA')
    // Cria grid e amarra à aba criada.
    oStruct := FWFormStruct(2, 'NCM',{|cCampo| ALLTRIM(cCampo) $ "NCM_CODREG|NCM_DESCRI|NCM_OBS"})
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_TITULO , RetTitle('NCA_CODIGO'))
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_LOOKUP , 'NCA')
    oView:AddGrid('VIEW_NCA', oStruct, 'FORMNCA')
    oView:SetOwnerView('VIEW_NCA', 'FOLDER_NCA')

    // ----------------------------------------------
    //   Visão NCO (sistema de aplicação).
    // ----------------------------------------------
    // Cria aba.
    oView:AddSheet('FOLDER_AGRO', 'ABA_NCO', FwX2Nome('NCO'))
    oView:CreateHorizontalBox('FOLDER_NCO', 100,,, 'FOLDER_AGRO', 'ABA_NCO')
    // Cria grid e amarra à aba criada.
    oStruct := FWFormStruct(2, 'NCM',{|cCampo| ALLTRIM(cCampo) $ "NCM_CODREG|NCM_DESCRI|NCM_OBS"})
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_TITULO , RetTitle('NCO_CODIGO'))
    oStruct:SetProperty('NCM_CODREG', MVC_VIEW_LOOKUP , 'NCO')
    oView:AddGrid('VIEW_NCO', oStruct, 'FORMNCO')
    oView:SetOwnerView('VIEW_NCO', 'FOLDER_NCO')

Return Nil

/*/{Protheus.doc} FieldPreVld
Método chamado pelo MVC quando ocorrer a ação de pré validação do campo
@author claudineia.reinert
@since 25/02/2021
@version 1.0
@return lRet
/*/
METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS MATA010AGRO01

    Local lRet       := .T.
    Local cCpValid  := ""    

    If cModelID == "FORMNCR" .AND. cAction == "SETVALUE"
        cCpValid  += "|NCR_VL_COT|" //aba produto
        cCpValid  += "|NCR_VL_N|NCR_VL_P|NCR_VL_K|NCR_VL_C|NCR_VL_O|NCR_VL_H|NCR_VL_S|NCR_VL_CA|NCR_VL_MG|NCR_VL_OMA|" //aba macronutrientes
        cCpValid  += "|NCR_VL_FE|NCR_VL_MN|NCR_VL_B|NCR_VL_ZN|NCR_VL_CU|NCR_VL_MO|NCR_VL_CL|NCR_VL_OMI|" //aba micronitruentes
        cCpValid  += "|NCR_VL_NA|NCR_VL_CO|NCR_VL_SI|NCR_VL_NI|" //aba nutrientes beneficos
        If cId $ cCpValid .AND. (xValue < 0 .or. xValue > 100)
            lRet := .F.
            AGRHELP(STR0001,STR0002,STR0003)
        EndIf
    EndIf

Return lRet

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model
//-------------------------------------------------------------------
/*/{Protheus.doc} FieldPosVld
Método chamado pelo MVC quando ocorrer as ações de pos validação do Model, quando salva o registro
@author claudineia.reinert
@since 25/02/2021
@version 1.0
@return lRet
/*/
METHOD FieldPosVld(oModel, cModelId) CLASS MATA010AGRO01
    Local lRet      := .T.
    
    If oModel:GetOperation() == MODEL_OPERATION_UPDATE .AND. oModel:GetId() == "FORMNCR" .AND. !ValPercAba(oModel) 
        lRet := .F.
    EndIf

Return lRet

/*/{Protheus.doc} ValPercAba
    Valida a soma dos valores dos campos da aba não permitindo que a soma seja maior que 100 nas abas de macronutrientes, micronutrientes e nutrientes beneficos.
    @type  Function
    @author claudineia.reinert
    @since 25/02/2021
    @version 1.0
    @param oModel, objeto, modelo de dados dos campos
    @return lRet, boleano, .T. verdadeiro ou .F. falso
    /*/
Static Function ValPercAba(oModel)
    Local lRet := .T.
    Local aCpMacro  := {}
    Local aCpMicro  := {}
    Local aCpNutriB := {}
     
    aCpMacro  := {"NCR_VL_N","NCR_VL_P","NCR_VL_K","NCR_VL_C","NCR_VL_O","NCR_VL_H","NCR_VL_S","NCR_VL_CA","NCR_VL_MG","NCR_VL_OMA"} //aba macronutrientes
    aCpMicro  := {"NCR_VL_FE","NCR_VL_MN","NCR_VL_B","NCR_VL_ZN","NCR_VL_CU","NCR_VL_MO","NCR_VL_CL","NCR_VL_OMI"} //aba micronitruentes
    aCpNutriB := {"NCR_VL_NA","NCR_VL_CO","NCR_VL_SI","NCR_VL_NI"} //aba nutrientes beneficos
        
    If SomaCampos(oModel,aCpMacro) > 100
        lRet := .F.
        AGRHELP(STR0001,STR0004 + STR0006,STR0005 + STR0006)
    ElseIf SomaCampos(oModel,aCpMicro) > 100
        lRet := .F.
        AGRHELP(STR0001,STR0004 + STR0007,STR0005 + STR0007)
    ElseIf SomaCampos(oModel,aCpNutriB) > 100
        lRet := .F.
        AGRHELP(STR0001,STR0004 + STR0008,STR0005 + STR0008)
    EndIF

Return lRet 

/*/{Protheus.doc} SomaCampos
    Soma os valores dos campos do modelo
    @type  Function
    @author claudineia.reinert
    @since 25/02/2021
    @version 1.0
    @param oStrModel, obejto, modelo de dados dos campos
    @param aCampos, array, array de string com o nome dos campos
    @return nSoma, numerico, valor da soma dos campos
    /*/
Static Function SomaCampos(oStrModel,aCampos)
    Local nSoma     := 0
    Local nx        := 0   

    For nx := 1 To Len(aCampos)
		nSoma += oStrModel:GetValue(aCampos[nx])
	Next nx  

Return nSoma 
