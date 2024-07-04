#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.ch"
#INCLUDE "JURA202G.ch"

Static __lFullHD     := .F.
Static __lOpcAll     := .F.
Static __cHist       := ""
//------------------------------------------------------------------------------
/* /{Protheus.doc} JURA202G
Realiza a abertura do cadastro de registro de cobran�a da pr� fatura.
@type oMarkUp - Object - Interface da JURA202
@since 02/02/2022
/*/
//------------------------------------------------------------------------------
Function JURA202G( oMarkUp )
Local aArea       := GetArea()
Local aAreaNX0    := NX0->(GetArea())
Local lHasNX0Mark := JA202VMark(oMarkUp)
Local nI          := 0
Local cMark       := oMarkUp:Mark()
Local cQuery      := ""
Local cAliasNX0   := ""
Local lFirst      := .T.
Local aNX0Erro    := {}
Local aPreFatEmit := {}
Local bCloseOnOk  := {|| RepHistPFat(aPreFatEmit, lFirst)}
Local aButtons    := {;
                        {.F.,Nil},{.F.,Nil},{.F.,Nil},;
                        {.F.,Nil},{.F.,Nil},{.F.,Nil},;
                        {.T., STR0002 }              ,; //Bot�o Confirmar
                        {.T., STR0003 }              ,; //Bot�o Fechar
                        {.F.,Nil},{.F.,Nil},{.F.,Nil},;
                        {.F.,Nil},{.F.,Nil},{.F.,Nil};
                     }

    __lFullHD     := FWGetDialogSize(oMainWnd)[4] > 1900
    __lOpcAll   := .F.
    __cHist       := ""

    If (lHasNX0Mark)
        cQuery := "SELECT NX0_OK, NX0_FILIAL, NX0_COD, NX0_SITUAC "
        cQuery += "FROM " + RetSqlName("NX0") + " "
        cQuery += "WHERE D_E_L_E_T_ = ' ' "
        cQuery +=   "AND NX0_OK = '" + cMark + "' "
        cQuery += "ORDER BY R_E_C_N_O_ "

        cAliasNX0 := GetNextAlias()
        DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasNX0, .F., .F. )

        While ((cAliasNX0)->(!Eof()))

            If ((cAliasNX0)->NX0_SITUAC == "6") 
                aAdd(aPreFatEmit, {(cAliasNX0)->NX0_FILIAL, (cAliasNX0)->NX0_COD, (cAliasNX0)->NX0_SITUAC})
            Else
                aAdd(aNX0Erro, (cAliasNX0)->NX0_COD)
            EndIf
            (cAliasNX0)->( dbSkip() )
        End
        ( cAliasNX0 )->( dbCloseArea() )

        For nI := 1 to Len(aPreFatEmit)
            lFirst := (nI == 1)
            DbSelectArea("NX0")
            NX0->( DbSetOrder(1) ) //NX0_FILIAL+NX0_COD+NX0_SITUAC
            If (NX0->( DbSeek(aPreFatEmit[nI][1]+ ;
                            aPreFatEmit[nI][2] + ;
                            aPreFatEmit[nI][3]) ))
                FWExecView(STR0001,"JURA202G",3,,{||.T.},bCloseOnOk,if(__lFullHD,80,70), aButtons) //"Registro de cobran�a"

            EndIf
            NX0->( dbCloseArea() )

            If (__lOpcAll)
                Exit
            EndIf
        Next nI

        If Len(aNX0Erro) > 0
            JurMsgErro(I18n(STR0005, {AToC(aNX0Erro)})) // "A(s) pr�-fatura(s) a seguir n�o podem utilizar tela de registro de cobran�a por n�o estarem em Minuta Emitida: #1"
        EndIf
    Else
        JurMsgErro(STR0006) // "N�o h� pr�-faturas selecionadas. Verifique!"
    EndIf
    oMarkUp:Refresh(.T.)
	RestArea( aAreaNX0 )
	RestArea( aArea )
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Fun��o responsavel pela defini��o do modelo
@since 02/02/2022
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel  := nil
Local oStrNX4 := FWFormStruct(1,'NX4')

    oStrNX4:SetProperty('NX4_CPREFT',MODEL_FIELD_INIT,{||NX0->NX0_COD})
    oStrNX4:SetProperty('NX4_AUTO'  ,MODEL_FIELD_INIT,{||'2'})

    oModel := MPFormModel():New('JURA202G', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

    oModel:AddFields('NX4MASTER',/*cOwner*/,oStrNX4,/*bPre*/,/*bPos*/,/*bLoad*/)

    oModel:SetDescription(STR0001)//"Registro de cobran�a"

    oModel:GetModel('NX4MASTER'):SetDescription(STR0001) //"Registro de cobran�a"

    oModel:lModify := .T.

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o responsavel pela defini��o da view
@since 02/02/2022
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView   := FWFormView():New()
Local oModel  := FwLoadModel('JURA202G')
Local oStrNX4 := FWFormStruct(2, 'NX4',{|cCpo| AllTrim(cCpo)+"|" $ "NX4_DTINC|NX4_HRINC|NX4_CPREFT|" })

    oView:SetModel(oModel)

    oView:AddField('VIEW_NX4' ,oStrNX4,'NX4MASTER')
    oView:AddOtherObject("VIEW_MEMO", {|oPanel| ShowMemoPanel(oPanel,oView)})

    oView:CreateHorizontalBox('SUPERIOR', 30)
    oView:CreateHorizontalBox('INFERIOR', 70)

    oView:SetOwnerView('VIEW_NX4','SUPERIOR')
    oView:SetOwnerView('VIEW_MEMO','INFERIOR')

    oView:EnableTitleView('VIEW_MEMO',STR0004)//"Hist�rico"

    oView:SetDescription(STR0001)//"Registro de cobran�a"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} ShowMemoPanel
monta painel no MVC para apresentar o memo de hist�rico
@since 01/02/2019
@version 1.0
@param oPanel, object, Objeto de do painel
@param oView, object, Objeto da view
/*/
//------------------------------------------------------------------------------
Static Function ShowMemoPanel(oPanel,oView)
Local oMdlNX4		:= oView:GetModel('NX4MASTER')
Local aClientRect	:= oPanel:GetClientRect()
Local nRow			:= aClientRect[1]+14
Local nCol			:= aClientRect[2]+2
Local nWidth		:= Round(aClientRect[3]*0.493,0)
Local nHeight		:= Round(aClientRect[4]*if(__lFullHD,0.415,0.385),0)
Local bSetGet		:=  { | U |If(ValType(oMdlNX4)=="O" .and. oMdlNX4:IsActive(),IF( PCOUNT() == 0, oMdlNX4:GetValue('NX4_HIST'),  (oMdlNX4:SetValue('NX4_HIST', U ), __cHist := U )),U  )  }
Local oMemo			:= TMultiGet():Create( oPanel, bSetGet, nRow,  nCol, nWidth, nHeight, /*oFont*/,,,,, .T. )

oMemo:EnableVSCroll(.T.)

Return


//------------------------------------------------------------------------------
/* /{Protheus.doc} RepHistPFat(aPreFats, lFirst)
Valida se replica o hist�rico para as demais pr�-faturas selecionadas

@param aPreFats - array - X2_UNICO das pr�-faturas que ir�o gerar o Registro de cobran�a
@param lFirst - boolean - Indica se � o primeiro registro posicionado. 
                          Somente mostramos a mensagem quando � o primeiro

@since 18/02/2022
@version 1.0
@param lRet , boolean , Indica se o processamento foi feito corretamente
/*/
//------------------------------------------------------------------------------
Static Function RepHistPFat(aPreFats, lFirst)
Local lRet    := .T.
Local nI      := 0
Local oMdlAux := FwLoadModel('JURA202G')

Default lFirst := .T.

    If (Len(aPreFats) > 1 .And. lFirst .And. ;
        ApMsgYesNo(STR0007)) //'Deseja replicar o hist�rico para as demais pr�-faturas selecionadas?'
        aDel(aPreFats, 1) // Remove a primeira da lista pois ser� salvo 
        aSize(aPreFats, Len(aPreFats)-1)
        RemMarkOk() // Desmarca o NX0_OK do registro salvo

        DbSelectArea("NX0")
        NX0->( DbSetOrder(1) ) //NX0_FILIAL+NX0_COD+NX0_SITUAC
        For nI := 1 To Len(aPreFats)

            If (NX0->( DbSeek(aPreFats[nI][1]+ ;
                            aPreFats[nI][2] + ;
                            aPreFats[nI][3]) ))

                oMdlAux := FwLoadModel('JURA202G')
                oMdlAux:SetOperation(MODEL_OPERATION_INSERT)
                oMdlAux:Activate()

                oMdlAux:SetValue('NX4MASTER','NX4_HIST',__cHist)
                If oMdlAux:VldData()
                    If oMdlAux:CommitData()
                        RemMarkOk() // Desmarca o NX0_OK dos demais registros
                    EndIf
                EndIf

                oMdlAux:Deactivate()
                oMdlAux:Destroy()
            EndIf
        Next nI
        __lOpcAll := .T.
    else
        RemMarkOk()
    Endif
Return lRet


//------------------------------------------------------------------------------
/* /{Protheus.doc} RemMarkOk
Remove a marca��o da NX0

@since 18/02/2022
@version 1.0
@param lRet , boolean , Indica se o processamento foi feito corretamente
/*/
//------------------------------------------------------------------------------
Static Function RemMarkOk()
Local lRet    := .T.

    RecLock("NX0", .F.)
    NX0->NX0_OK     := Space(TamSX3("NX0_OK")[1])
    NX0->(MsUnlock())
    NX0->(DbCommit())
Return lRet
