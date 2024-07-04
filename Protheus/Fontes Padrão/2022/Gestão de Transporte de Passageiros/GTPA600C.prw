#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA600C.CH'

/*{Protheus.doc} GTPA600C
Ajuste de kilometragem para viagens especiais
author flavio.martins
@since 11/01/2022
@version 1.0
*/
Function GTPA600C()
Local lRet      := .T.
Local oModel    := FwLoadModel('GTPA600C')

    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    
    oModel:Activate()

    lRet := VldContrato(oModel)

    If lRet
        FwExecView(STR0001, "VIEWDEF.GTPA600C", MODEL_OPERATION_UPDATE,  /*oDlgKco*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , oModel) // "Orçamento de Contrato"
    Endif

Return

/*{Protheus.doc} ModelDef
Definição do modelo de Dados

@return oModel. Objeto. objeto da classe MPFormModel
@sample oModel := ModelDef()
@author flavio.martins
@since 11/01/2022
@version 1.0
*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruG6R	:= FwFormStruct(1, "G6R") 
Local oStruGYN  := FwFormStruct(1, "GYN") 
Local bCommit   := {|oModel| G600CCommit(oModel)}
Local bPosValid	:= {|oModel| G600CPosVld(oModel)}
Local bFldValid	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

oModel := MPFormModel():New("GTPA600C",, bPosValid, /*bCommit*/)

oModel:AddFields("G6RMASTER", /*cOwner*/, oStruG6R)
oModel:AddGrid("GYNDETAIL", "G6RMASTER", oStruGYN, /*bPreLin*/)

oModel:SetRelation("GYNDETAIL",{{"GYN_FILIAL", "xFilial('GYN')"},;
                                {"GYN_OPORTU", "G6R_NROPOR"}},;
                                GYN->(IndexKey(1))) 

oModel:GetModel('G6RMASTER'):SetOnlyView(.T.)

oModel:SetOptional("GYNDETAIL", .T. )

oStruGYN:SetProperty("GYN_KMREAL", MODEL_FIELD_VALID, bFldValid)
oStruGYN:AddTrigger("GYN_KMREAL", "GYN_KMREAL", {||.T.}, bFldTrig)	 

oModel:GetModel("GYNDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("GYNDETAIL"):SetNoDeleteLine(.T.)

oStruGYN:AddField("VLRTOTKM","","VLRTOTKM"	,"N",14,2,,,,.F.,,,,.T.)

oModel:AddCalc('CALC', 'G6RMASTER', 'GYNDETAIL' , 'VLRTOTKM', 'CALC_VALOR', 'SUM', { | | .T.},, STR0025) // "Vlr. Total"

oModel:SetCommit(bCommit)

Return oModel

/*{Protheus.doc} ViewDef
Definição do interface
@return oView. Objeto. objeto da classe FWFormView
@sample oView := ViewDef()
@author flavio.martins
@since 11/01/2022
@version 1.0
*/
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel('GTPA600C')
Local cFldsG6R  := 'G6R_CODIGO|G6R_NROPOR|G6R_PRODUT|G6R_DESPRO|G6R_SA1COD|G6R_SA1LOJ|G6R_NMCLNT|G6R_SUSCOD|G6R_SUSLOJ|G6R_KMCONT|G6R_KMEXCE'
Local cFldsGYN  := 'GYN_CODIGO|GYN_PROPOS|GYN_OPORTU|GYN_DTINI|GYN_DTFIM|GYN_KMPROV|GYN_KMREAL'
Local oStruG6R	:= FwFormStruct(2, "G6R", { |x| AllTrim(x) $ cFldsG6R})
Local oStruGYN	
Local oStruCalc := FWCalcStruct( oModel:GetModel('CALC') )
Local aFldsG6R  := StrToKarr(cFldsG6R, "|")
Local aFldsGYN  := {}
Local nX        := 0

cFldsGYN += '|VLRTOTKM'

If GYN->(FieldPos('GYN_CODPED')) > 0
    cFldsGYN += '|GYN_CODPED'
Endif

aFldsGYN := StrToKarr(cFldsGYN, "|")

oStruGYN := FwFormStruct(2, "GYN", { |x| AllTrim(x) $ cFldsGYN})

oView := FwFormView():New()

oView:SetModel(oModel)

oView:SetDescription(STR0002) // "Ajuste de Kilometragem"

oView:AddField("VIEW_G6R", oStruG6R, 'G6RMASTER')
oView:AddGrid("GRID_GYN", oStruGYN, 'GYNDETAIL')
oView:AddField('VIEW_CALC', oStruCalc, 'CALC')

oStruGYN:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
oStruGYN:SetProperty('GYN_KMREAL', MVC_VIEW_CANCHANGE, .T.)

oView:CreateHorizontalBox("HEADER",45)
oView:CreateHorizontalBox("GRID",40)
oView:CreateHorizontalBox("CALC",15)

oView:SetOwnerView("VIEW_G6R", "HEADER")
oView:SetOwnerView("GRID_GYN", "GRID")
oView:SetOwnerView('VIEW_CALC', 'CALC')

oView:EnableTitleView("VIEW_G6R", STR0003)  // "Dados do Contrato"
oView:EnableTitleView("GRID_GYN", STR0004)  // "Viagens"
oView:EnableTitleView("VIEW_CALC", STR0026) //"Valor Total Km Excedidos"

oView:AddUserButton(STR0005, "", {|oView| ProcessPV(oView, .F.)},,VK_F5 )  //"Gerar Pedido"
oView:AddUserButton(STR0006, "", {|oView| ProcessPV(oView, .T.)},,VK_F6 )  //"Estornar Pedido"

oStruGYN:AddField("VLRTOTKM", "12", STR0027, "",{},"C","@E 99,999,999,999.99",,,.F.) //"Vlr. Total Km"

oView:SetAfterViewActivate( { |oView| AfterActiv(oView)})

For nX := 1 To Len(aFldsG6R)
    oStruG6R:SetProperty(aFldsG6R[nX], MVC_VIEW_ORDEM , StrZero(nX,2))
Next

For nX := 1 To Len(aFldsGYN)
    oStruGYN:SetProperty(aFldsGYN[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
Next

Return oView

/*{Protheus.doc} AfterActiv(oView)
Validação após ativação da View
@sample oView := ViewDef()
@author flavio.martins
@since 11/01/2022
@version 1.0
*/
Static Function AfterActiv(oView)
Local oModel    := oView:GetModel()
Local nX        := 0
Local nQtdKm    := 0
Local nVlrKm    := 0
Local nVlrTot   := 0

If oModel:GetValue('G6RMASTER', 'G6R_KMEXCE') > 0 

    nVlrKm := oModel:GetValue('G6RMASTER', 'G6R_KMEXCE')

    For nX := 1 To oModel:GetModel('GYNDETAIL'):Length()

        oModel:GetModel('GYNDETAIL'):GoLine(nX)

        nQtdKm := oModel:GetValue('GYNDETAIL', 'GYN_KMREAL') - oModel:GetValue('G6RMASTER', 'G6R_KMCONT')

        If nQtdKm > 0

            nVlrTot := (nQtdKm * nVlrKm)

            oModel:GetModel('GYNDETAIL'):SetValue('VLRTOTKM', nVlrTot)

        Endif 

    Next

Endif

oView:Refresh()
oView:lModify := .F.

Return

/*/{Protheus.doc} VldContrato()
Validação
@type function
@author flavio.martins
@since 12/01/2022
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
/*/
Static Function VldContrato(oModel)
Local lRet := .T.

    If oModel:GetValue('G6RMASTER', 'G6R_STATUS') <> '2'
        lRet	:= .F.
        FwAlertHelp(STR0007) //"Operação não permitida para o status atual do contrato"
    Endif

    If lRet .And. oModel:GetValue('GYNDETAIL', 'GYN_FINAL') <> '1'
        lRet	:= .F.
        FwAlertHelp(STR0008) //"Operação permitida apenas para viagens finalizadas"
    Endif

    If lRet .And. GYN->(FieldPos('GYN_CODPED')) == 0
        lRet	:= .F.
        FwAlertHelp(STR0024) //"Necessário atualizar o dicionário de dados para utilização desta funcionalidade")
    Endif

Return lRet

/*{Protheus.doc} FieldValid(oMdl,cField,uNewValue,uOldValue) 
Valid de campos
@sample oView := ViewDef()
@author flavio.martins
@since 11/01/2022
@version 1.0
*/
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

If cField == 'GYN_KMREAL' 

    If GYN->(FieldPos('GYN_CODPED')) > 0 .And. !Empty(oModel:GetValue('GYNDETAIL', 'GYN_CODPED'))
        lRet := .F.
        cMsgErro := STR0009 //"Alteração não permitida, o pedido já foi gerado para esta viagem" 
        cMsgSol  := STR0010 //"Estorne o pedido antes de alterar a kilometragem"
        oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
    Endif

Endif

Return lRet

/*{Protheus.doc} FieldTrigger(oMdl,cField,uVal)
gatilho de campos
@sample oView := ViewDef()
@author flavio.martins
@since 11/01/2022
@version 1.0
*/
Static Function FieldTrigger(oMdl,cField,uVal)
Local oModel    := oMdl:GetModel()
Local nQtdKm    := 0
Local nVlrKm    := 0
Local nVlrTot   := 0

If cField == 'GYN_KMREAL'

    oModel:GetModel('GYNDETAIL'):SetValue('VLRTOTKM', 0)

    If oModel:GetValue('G6RMASTER', 'G6R_KMEXCE') > 0 

        nVlrKm := oModel:GetValue('G6RMASTER', 'G6R_KMEXCE')
        nQtdKm := (oModel:GetValue('GYNDETAIL', 'GYN_KMREAL') - oModel:GetValue('G6RMASTER', 'G6R_KMCONT'))

        If nQtdKm > 0
            nVlrTot := nQtdKm * nVlrKm
            oModel:GetModel('GYNDETAIL'):SetValue('VLRTOTKM', nVlrTot)
        Endif

    Endif

Endif 

Return uVal

/*/{Protheus.doc} G600CPosVld(oModel)
PosValid do Modelo
@type function
@author flavio.martins
@since 12/01/2022
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
/*/
Static Function G600CPosVld(oModel)
Local lRet := .T.

    If oModel:GetValue('GYNDETAIL', 'GYN_KMREAL') <= 0
        lRet := .F.
        oModel:SetErrorMessage("",,oModel:GetId(),"","G600CPosVld", STR0011) //"Kilometragem real informada inválida"
    Endif

Return lRet

/*/{Protheus.doc} G600CCommit(oModel)
Commit do modelo de dados
@type function
@author flavio.martins
@since 12/01/2022
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
/*/
Static Function G600CCommit(oModel)
Local lRet := .T.

    If !(FwIsInCallStack('ProcessPV')) .And. oModel:GetValue('GYNDETAIL', 'GYN_KMREAL') > oModel:GetValue('G6RMASTER', 'G6R_KMCONT') .And.;
        oModel:GetValue('G6RMASTER', 'G6R_KMEXCE') > 0 .And. Empty(oModel:GetValue('GYNDETAIL', 'GYN_CODPED'))

        If FwAlertYesNo(STR0012 +Chr(13)+Chr(10)+STR0013, STR0014) //"Este contrato prevê a cobrança da kilometragem excedida", "Deseja gerar o pedido de venda agora ?", "Atenção"
           
            FwMsgRun(, {|| lRet := GerPedido(oModel) }, ,STR0019) //"Gerando o pedido de venda..."           

            If lRet
                FwAlertSuccess(STR0020) //"Pedido de Venda gerado com sucesso"
            Endif

        Endif

    Endif

    FwFormCommit(oModel)    

Return lRet 

/*/{Protheus.doc} ProcessPV(oView, lEstorno)
Validação da geração e estorno do pedido
@type function
@author flavio.martins
@since 12/01/2022
@version 1.0
@param oView, lEstorno
@return ${return}, ${return_description}
@example
/*/
Static Function ProcessPV(oView, lEstorno)
Local lRet   := .T.
Local oModel := oView:GetModel()

Default lEstorno := .F.

If !(lEstorno)

    If GYN->(FieldPos('GYN_CODPED')) > 0 .And. !Empty(oModel:GetValue('GYNDETAIL', 'GYN_CODPED'))
        FwAlertHelp(STR0015) //"Pedido de venda já gerado para esta viagem"
        Return
    Endif

    If oModel:GetValue('GYNDETAIL', 'GYN_KMREAL') <= 0
        FwAlertHelp(STR0016) //"Kilometragem real informada inválida"
        Return
    Endif

    If oModel:GetValue('G6RMASTER', 'G6R_KMEXCE') == 0
        FwAlertHelp(STR0017) //"Este contrato não prevê a cobrança de kilometragem excedente"
        Return
    Endif

    If oModel:GetValue('GYNDETAIL', 'GYN_KMREAL') <= oModel:GetValue('G6RMASTER', 'G6R_KMCONT') 
        FwAlertHelp(STR0018) //"Kilometragem realizada não ultrapassou a kilometragem contratada"
        Return
    Endif

    FwMsgRun(, {|| lRet := GerPedido(oModel) }, ,STR0019) //"Gerando o pedido de venda..."    

    If lRet
        FwAlertSuccess(STR0020) //"Pedido de Venda gerado com sucesso"
    Endif

Else

    If GYN->(FieldPos('GYN_CODPED')) > 0 .And. Empty(oModel:GetValue('GYNDETAIL', 'GYN_CODPED'))
        FwAlertHelp(STR0021) //"Pedido de venda não gerado para esta viagem"
        Return
    Endif

    FwMsgRun(, {|| lRet := EstPedido(oModel) }, , STR0022) // "Estornando o pedido de venda..."   

    If lRet
        FwAlertSuccess(STR0023) //"Pedido de Venda estornado com sucesso"
    Endif

Endif

Return lRet

/*/{Protheus.doc} GerPedido(oModel)
Função que gera o pedido de venda
@type function
@author flavio.martins
@since 12/01/2022
@version 1.0
@param oModel
@return ${return}, ${return_description}
@example
/*/
Static Function GerPedido(oModel)
Local lRet      := .T.
Local aSC5      := {}
Local aSC6      := {}
Local aItem     := {}
Local nVlrPV    := 0
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local oView		:= FwViewActive()

Private lMsErroAuto := .F.

    nVlrPV := (oModel:GetValue('GYNDETAIL', 'GYN_KMREAL') - oModel:GetValue('G6RMASTER', 'G6R_KMCONT'));
                * oModel:GetValue('G6RMASTER', 'G6R_KMEXCE')

    aAdd(aSC5,{"C5_TIPO","N", Nil})  //Tipo do Pedido = Normal
    aAdd(aSC5,{"C5_CLIENTE", oModel:GetValue('G6RMASTER', 'G6R_SA1COD'), Nil})
    aAdd(aSC5,{"C5_LOJA", oModel:GetValue('G6RMASTER', 'G6R_SA1LOJ'), Nil})
    aAdd(aSC5,{"C5_TIPOCLI","F", Nil})   //Tipo de Cliente = Consumidor final
    aAdd(aSC5,{"C5_CONDPAG", oModel:GetValue('G6RMASTER', 'G6R_CONDPG'), Nil})
    aAdd(aSC5,{"C5_ORIGEM","GTPA600C", Nil})

    //Itens do Pedido de Venda
    aAdd(aItem,{"C6_ITEM", StrZero(1,TamSx3("C6_ITEM")[1]),Nil})
    aAdd(aItem,{"C6_PRODUTO", oModel:GetValue('G6RMASTER', 'G6R_PRODUT'),Nil})
    aAdd(aItem,{"C6_QTDVEN", 1, Nil})
    aAdd(aItem,{"C6_PRCVEN", nVlrPV, Nil})
    aAdd(aItem,{"C6_QTDLIB", 1, Nil})
    aAdd(aItem,{"C6_TES", oModel:GetValue('G6RMASTER', 'G6R_TES'),Nil})
    aAdd(aItem,{"AUTDELETA","N",Nil})

    aAdd(aSC6,aClone(aItem))
    aItem := {}

    MsExecAuto({|x,y,z| MATA410(x,y,z)},aSC5,aSC6,3)

    If lMsErroAuto
        lRet := .F.
        MostraErro()
    Else
    
        If GYN->(FieldPos("GYN_CODPED")) > 0 
            oModel:GetModel('GYNDETAIL'):SetValue('GYN_CODPED', SC5->C5_NUM)
            oView:showUpdateMsg(.F.)
            oView:Refresh()
            FwFormCommit(oModel)
            oView:lModify := .F.
            oView:oModel:lModify := .F.
            oView:Refresh()
        Endif

    Endif
     
    RestArea(aAreaSC5)
    RestArea(aAreaSC6)

Return lRet

/*/{Protheus.doc} EstPedido(oModel)
Função que gera o pedido de venda
@type function
@author flavio.martins
@since 12/01/2022
@version 1.0
@param oModel
@return ${return}, ${return_description}
@example
/*/
Static Function EstPedido(oModel)
Local lRet      := .T.
Local aSC5      := {}
Local aSC6      := {}
Local aItem     := {}
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local oView		:= FwViewActive()

Private lMsErroAuto := .F.

    SC5->(dbSetOrder(1))
    SC6->(dbSetOrder(1))

    If GYN->(FieldPos("GYN_CODPED")) > 0  .And. (SC5->(dbSeek(xFilial("SC5")+oModel:GetValue('GYNDETAIL', 'GYN_CODPED'))) )
        
        aAdd(aSC5,{"C5_NUM", SC5->C5_NUM, Nil})

        If (SC6->(dbSeek(xFilial("SC6")+oModel:GetValue('GYNDETAIL', 'GYN_CODPED'))) )

            aAdd(aItem,{"C6_NUM"    , SC6->C6_NUM,Nil})    
            aAdd(aItem,{"C6_ITEM"   , SC6->C6_ITEM,Nil})
            aAdd(aItem,{"C6_PRODUTO", SC6->C6_PRODUTO,Nil})
            aAdd(aItem,{"C6_QTDVEN" , SC6->C6_QTDVEN,Nil})
            aAdd(aItem,{"C6_PRCVEN" , SC6->C6_PRCVEN,Nil})
            aAdd(aItem,{"C6_VALOR"  , SC6->C6_VALOR,Nil})
            aAdd(aItem,{"C6_QTDLIB" , 0,Nil})
            aAdd(aItem,{"C6_TES"    , SC6->C6_TES,Nil})
            aAdd(aItem,{"AUTDELETA" , "N",Nil})

            aAdd(aSC6,aClone(aItem))

            MsExecAuto({|x,y,z| MATA410(x,y,z)}, aSC5, aSC6, 4)  //Altera, para deixar o pedido não liberado
            
            If lMsErroAuto

                lRet := .T.
                MostraErro()

            Else    

                MsExecAuto({|x,y,z| MATA410(x,y,z)}, aSC5, aSC6, 5) //Exclusão do Pedido de Vendas
                
                If lMsErroAuto 
                    lRet := .F.
                    MostraErro()
                Endif

                RestArea(aAreaSC5)
                RestArea(aAreaSC6)

            EndIf    

        EndIf

    Endif

    If lRet .And. GYN->(FieldPos("GYN_CODPED")) > 0 
        oModel:GetModel('GYNDETAIL'):ClearField('GYN_CODPED')
        oView:showUpdateMsg(.F.)
        oView:Refresh()
        FwFormCommit(oModel)
        oView:lModify := .F.
        oView:oModel:lModify := .F.
        oView:Refresh()
    Endif

Return lRet
