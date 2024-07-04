#INCLUDE "GCPA500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static _lCheckEdt:= .F.
Static _aCheckRec:= {}

/*/{Protheus.doc} GCPA500
	Fornecedores credenciados do Edital
@author philipe.pompeu
@since 20/05/2022
/*/
Function GCPA500()
    Local oBrowse
    Local cFiltro := "CO1_MODALI == 'CR'"

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('CO1')
    oBrowse:SetDescription(STR0001)
    oBrowse:SetFilterDefault( cFiltro )
    oBrowse:Activate()
Return

/*/{Protheus.doc} MenuDef
	Definição das opções de menu
@author philipe.pompeu
@since 20/05/2022
@return aRotina, vetor, lista de opções
/*/
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0002 ACTION "Gcp500Mnt"  OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD OPTION aRotina TITLE STR0010 ACTION "VIEWDEF.GCPA500" 	OPERATION 2 ACCESS 0 //"Visualizar"
Return aRotina

/*/{Protheus.doc} Gcp500Mnt
	Opção de manutenção dos fornecedores credenciados.
@author philipe.pompeu
@since 20/05/2022
@return nRet, numerico, retorno o FwExecView
/*/
Function Gcp500Mnt()
    Local aArea := GetArea()
    Local nRet := 0
    Local aButtons := GetBtnView()

    nRet := FWExecView(STR0002,"GCPA500",MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOK*/, /*bOk*/, /*nPercReducao*/, aButtons)

    FwFreeArray(aButtons)
    
    RestArea(aArea)
    FwFreeArray(aArea)
Return nRet

/*/{Protheus.doc} GetBtnView
	Retorna vetor padrão que desabilite o botão "Salva e criar novo"
@author philipe.pompeu
@since 20/05/2022
@return aButtons, vetor, utilizado p/ desabilitar botão "Salva e criar novo"
/*/
Static Function GetBtnView()
    Local aButtons := Array(15,2)
    aEval(aButtons, {|x|x[1] := .T.})
    aButtons[15,1] := .F. //Desabilita botão "Salva e Criar Novo"
Return aButtons

/*/{Protheus.doc} ModelDef
	Definição do modelo do credenciamento do edital
@author philipe.pompeu
@since 20/05/2022
@return oModel, objeto, Instância de MPFormModel
/*/
Static Function ModelDef()
    Local oModel := Nil
    Local oStruCO1 := FWFormStruct( 1,'CO1' )
    Local oStruCOR := FWFormStruct( 1,'COR' )
    Local bTrgStatus := {|oMdlCOR,b,cStatus|CORTrgStat(cStatus,oMdlCOR)}
    Local bWhenCheck := FwBuildFeature(STRUCT_FEATURE_WHEN, "GC500Check() .And. FwFldGet('COR_STATUS') == '2'")
    Local bPreVldCOR := { |oMdlCOR,  nLine,cAction,  cField, xValue, xOldValue| G500PVlCOR(oMdlCOR, nLine, cAction, cField, xValue, xOldValue) }
    Local bVldLoja   := MTBlcVld("COR","COR_LOJFOR"	,"Vazio() .Or. GCP130VFor()",.F.,.F., .T.)
    
    oStruCOR:AddTrigger("COR_STATUS", "COR_DTHABI", {||.T.}, bTrgStatus)
    oStruCOR:SetProperty("COR_DTHABI", MODEL_FIELD_INIT , {|| CToD("//") })
    oStruCOR:SetProperty("COR_LOJFOR", MODEL_FIELD_VALID, bVldLoja)
    oStruCOR:SetProperty("COR_JUSTIF", MODEL_FIELD_WHEN , FwBuildFeature( STRUCT_FEATURE_WHEN, ".T."))

    oStruCOR:AddField(  "Check"		        ,;	// 	[01]  C   Titulo do campo
                        "Check"				,;	// 	[02]  C   ToolTip do campo
                        "COR_CHECK"			,;	// 	[03]  C   Id do Field
                        "L"					,;	// 	[04]  C   Tipo do campo
                        1					,;	// 	[05]  N   Tamanho do campo
                        0					,;	// 	[06]  N   Decimal do campo
                        {||.T.}             ,;	// 	[07]  B   Code-block de validação do campo
                        bWhenCheck	        ,;	// 	[08]  B   Code-block de validação When do campo
                        Nil					,;	//	[09]  A   Lista de valores permitido do campo
                        .F.					,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
                        FwBuildFeature( STRUCT_FEATURE_INIPAD, ".F." )      ,;	//	[11]  B   Code-block de inicializacao do campo
                        Nil					,;	//	[12]  L   Indica se trata-se de um campo chave
                        .F.					,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.					)	// 	[14]  L   Indica se o campo é virtual

    oModel := MPFormModel():New('GCPA500', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
    oModel:AddFields('CO1MASTER',/*cOwner*/, oStruCO1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
    oModel:AddGrid('CORDETAIL', 'CO1MASTER', oStruCOR, bPreVldCOR/*bPreValidacao*/,/*bPosValidacao*/, /*bCarga*/ )

    oModel:SetRelation('CORDETAIL', { {'COR_FILIAL','xFilial("COR")'},{ 'COR_CODEDT', 'CO1_CODEDT' }, { 'COR_NUMPRO', 'CO1_NUMPRO' } }, COR->(IndexKey(2)) )

    oModel:GetModel('CORDETAIL'):SetOptional(.T.)
    oModel:GetModel('CORDETAIL'):SetNoDeleteLine(GC500Check())//Nao permite deletar/inserir se for através do check do Edital    
    oModel:GetModel('CORDETAIL'):SetNoInsertLine(GC500Check())//Nao permite deletar/inserir se for através do check do Edital
    oModel:GetModel('CORDETAIL'):SetUniqueLine({"COR_CODFOR","COR_LOJFOR"})

    oModel:SetDeActivate({|oModel| GP500DeAct(oModel)})
    oModel:SetVldActivate({|oModel| GP500VlAct(oModel)})

    oModel:SetDescription( STR0003 )
    oModel:SetPrimaryKey( {"CO1_FILIAL","CO1_CODEDT","CO1_NUMPRO","CO1_REVISA"} )    
Return oModel

/*/{Protheus.doc} GP500VlAct
	Valida a ativação do modelo de credenciamento
@author philipe.pompeu
@since 20/05/2022
@param oModel, objeto, instância de MPFormModel
@return lCanActive, lógico, se pode ativar
/*/
Function GP500VlAct(oModel)
    Local lCanActive:= .T.
    Local aEtapas   := {}
    Local nIndPQ    := 0
    
    If !(lCanActive := G500VldDic())        
        Help(" ",1,"GCPA500_01",,STR0005, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0006})//Dicionário incompatível com a modalidade Credenciamento. Realize a atualização do sistema.
    EndIf

    If lCanActive .And. CO1->(AllTrim(CO1_MODALI) != "CR")
        Help(" ",1,"GCPA500_02",,STR0008, 1, 0, NIL, NIL, NIL, NIL, NIL, {}) //Edital da modalidade inválida.
        lCanActive := .F.
    EndIf

    If (lCanActive .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. !GC500Check())        
        aEtapas:= CO1->(GCPEtpsEdt(CO1_REGRA, CO1_MODALI))
        nIndPQ := aScan(aEtapas, 'PQ')        
        If (aScan(aEtapas, CO1->CO1_ETAPA) > nIndPQ)
            Help(" ",1,"GCPA500_03",,STR0007, 1, 0, NIL, NIL, NIL, NIL, NIL, {})//Não é possivel inserir novos credenciados em editais nessa etapa.
            lCanActive := .F.
        EndIf
        FwFreeArray(aEtapas)
    EndIf
Return lCanActive

/*/{Protheus.doc} GP500DeAct
	Operação realizada na desativação do modelo
@author philipe.pompeu
@since 20/05/2022
@param oModel, objeto, instância de MPFormModel
/*/
Function GP500DeAct(oModel)
    If GC500Check()
        GC500Check(.T., .F.)//Restaura p/ falso        
    EndIf
Return

/*/{Protheus.doc} ViewDef
	Definição da interface gráfica(view) à ser vinculada ao modelo de credenciamento(GCPA500)
@author philipe.pompeu
@since 20/05/2022
@return oView, objeto, instância de FWFormView
/*/
Static Function ViewDef()
    Local oModel:= FwLoadModel("GCPA500")
    Local oView := FWFormView():New()
    Local cCposCO1 := "CO1_CODEDT|CO1_NUMPRO|CO1_REVISA|CO1_REGRA|"
    Local oStruCO1 := FWFormStruct(2,'CO1', {|x|  AllTrim(x)+'|' $ cCposCO1})
    Local oStruCOR := FWFormStruct(2,'COR', {|x|  !(AllTrim(x)+'|' $ 'COR_CODEDT|COR_NUMPRO|') })

    oStruCO1:SetProperty("*", MVC_VIEW_GROUP_NUMBER, "01")
    aSize(oStruCO1:aFolders, 0)

    oStruCOR:SetProperty('COR_DTHABI', MVC_VIEW_CANCHANGE, .F.)
    oStruCOR:SetProperty('COR_STATUS', MVC_VIEW_CANCHANGE, !(GC500Check()))

    oStruCOR:AddField(  "COR_CHECK"	    ,;	// [01]  C   Nome do Campo
                        "01"			,;	// [02]  C   Ordem
                        "Check" 		,;	// [03]  C   Titulo do campo
                        "Check"			,;	// [04]  C   Descricao do campo
                        {}		        ,;	// [05]  A   Array com Help
                        "L"				,;	// [06]  C   Tipo do campo
                        ""			    ,;	// [07]  C   Picture
                        NIL				,;	// [08]  B   Bloco de Picture Var
                        NIL				,;	// [09]  C   Consulta F3
                        .T.				,;	// [10]  L   Indica se o campo é alteravel
                        NIL				,;	// [11]  C   Pasta do campo
                        NIL				,;	// [12]  C   Agrupamento do campo
                        NIL		        ,;	// [13]  A   Lista de valores permitido do campo (Combo)
                        NIL				,;	// [14]  N   Tamanho maximo da maior opção do combo
                        NIL				,;	// [15]  C   Inicializador de Browse
                        .T.				,;	// [16]  L   Indica se o campo é virtual
                        NIL				,;	// [17]  C   Picture Variavel
                        NIL				)	// [18]  L   Indica pulo de linha após o campo

    oView:SetModel(oModel)
    oView:AddField("VIEW_CO1",oStruCO1,"CO1MASTER")
    oView:SetViewProperty("CO1MASTER", "ONLYVIEW")
    
    oView:CreateHorizontalBox("CABEC",25)    
    oView:SetOwnerView("VIEW_CO1","CABEC")

    oView:AddGrid('VIEW_COR' , oStruCOR,'CORDETAIL')
    oView:CreateHorizontalBox("FORNEC",75)
    oView:SetOwnerView("VIEW_COR","FORNEC")

    oView:showUpdateMsg(!(GC500Check()))
    oView:SetAfterOkButton({|x|GC500AftOk(x)})
Return oView

/*/{Protheus.doc} GC500AftOk
    Operação realizada após confirmação da operação(botão confirmar)
@author philipe.pompeu
@since 20/05/2022
@param oView, objeto, instância de FWFormView
/*/
Function GC500AftOk(oView)
    Local nX := 0
    Local oMdlCOR := NIL

    If GC500Check()    
        aSize(_aCheckRec,0)
        oMdlCOR := oView:GetModel("CORDETAIL")        
        for nX := 1 to oMdlCOR:Length()
            oMdlCOR:GoLine(nX)
            If !(oMdlCOR:IsDeleted()) .And. oMdlCOR:GetValue("COR_CHECK")            
                aAdd(_aCheckRec, oMdlCOR:GetDataId())
            EndIf
        next nX
    EndIf
Return Nil

/*/{Protheus.doc} CORTrgStat
    Gatilho disparado no preenchimento do campo <COR_STATUS> p/ preenchimento do campo <COR_DTHABI>
@author philipe.pompeu
@since 20/05/2022
@param cStatus, caractere, valor sendo atribuido à <COR_STATUS>
@param oMdlCOR, objeto, instância de FwFormModelGrid(CORDETAIL)
@return dDtHabi, data, valor a ser atribuido ao campo <COR_DTHABI>
/*/
Function CORTrgStat(cStatus, oMdlCOR)
    Local dDtHabi := CToD("//")
    
    If (cStatus == "2")
        dDtHabi := Date()
    EndIf
Return dDtHabi

/*/{Protheus.doc} GC500Check
    Encapsula o acesso a variável estática <_lCheckEdt>, responsável por controlar se trata-se de uma operação de importação p/ o edital
@author philipe.pompeu
@since 20/05/2022
@param lSet, lógico, se é uma operação de atribuição
@param lNovoValor, lógico, caso <lSet> atribui <lNovoValor> a variável estática <_lCheckEdt>
@return _lCheckEdt, lógico, se é uma operação de importação
/*/
Function GC500Check(lSet, lNovoValor)
    Default lSet := .F.

    If lSet
        _lCheckEdt := lNovoValor
    EndIf
Return _lCheckEdt

/*/{Protheus.doc} GP500ImpCr
    Método responsável por exibir uma interface de seleção dos credenciados p/ importação pro Edital(GCPA200)
@author philipe.pompeu
@since 20/05/2022
@param oView, objeto, instância de FWFormView do GCPA200
@param oMdlEdital, objeto, instância de MPFormModel do modelo do Edital
/*/
Function GP500ImpCr(oView, oMdlEdital) 
    Local aSaveLines:= FWSaveRows()
    Local aButtons  := {}
    Local nX        := 0
    Local lContinua := .T.
    Local oMdlCO3   := Nil
    Local nVlrUnit  := 0
    Local lView     := .F.
    Local lEdtLote  := .F.
    Local aProp     := {}
    Local aSeek     := {}
    Local nLinha    := 0

    If (lView := (ValType(oView) == "O" .And. oView:IsActive()))
        oMdlEdital := oView:GetModel("CO1MASTER"):GetModel()
    EndIf

    lEdtLote := (oMdlEdital:GetId() == "GCPA201")

    GC500Check(.T., .T.)//Ativa a tela de check

    If lView
        aButtons := GetBtnView()
        lContinua := (FWExecView(STR0004,"GCPA500",MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOK*/, /*bOk*/, 30, aButtons) == 0)
    EndIf

    If lContinua
        nVlrUnit := oMdlEdital:GetValue("CO2DETAIL", "CO2_VLESTI")
        oMdlCO3 := oMdlEdital:GetModel("CO3DETAIL")
        aProp := {GetPropMdl(oMdlCO3), GCTGetWhen(oMdlCO3)}
        CNTA300BlMd(oMdlCO3, .F.)//Libera p/ atualizacao
        oMdlCO3:GetStruct():SetProperty( '*', MODEL_FIELD_WHEN , {||.T.} )

        aSeek      := Array(2,2)
        aSeek[1,1] := "CO3_CODIGO"
        aSeek[2,1] := "CO3_LOJA"

        for nX := 1 to Len(_aCheckRec)
            COR->(DbGoTo(_aCheckRec[nX]))
            aSeek[1,2] := COR->COR_CODFOR
            aSeek[2,2] := COR->COR_LOJFOR
            nLinha := MTFindMVC(oMdlCO3, aSeek)
            if nLinha == 0
                If !(Empty(oMdlCO3:GetValue("CO3_CODIGO")))
                    oMdlCO3:AddLine()
                EndIf
                
                oMdlCO3:SetValue("CO3_CODIGO"   , aSeek[1,2])
                oMdlCO3:SetValue("CO3_LOJA"     , aSeek[2,2])
                oMdlCO3:SetValue("CO3_VLUNIT"   , nVlrUnit)
            endif
        next nX

        RstPropMdl(oMdlCO3, aProp[1])
        GCTRstWhen(oMdlCO3, aProp[2])
        FwFreeArray(aProp)
    EndIf

    FwFreeArray(aButtons)
    FWRestRows(aSaveLines)
    FwFreeArray(aSaveLines)
Return

/*/{Protheus.doc} G500PVlCOR
    Pré-Valid do submodelo CORDETAIL
@author philipe.pompeu
@since 20/05/2022
@param oMldCOR  , objeto, instância de FwFormGrid do submodelo CORDETAIL
@param nLine    , numérico, linha sendo modificada
@param cAction  , caractere, operação sendo realizada
@param cField   , caractere, nome do campo
@param xValue   , indefinido, novo valor do campo
@param xOldValue, indefinido, valor prévio do campo
/*/
Function G500PVlCOR(oMldCOR, nLine, cAction, cField, xValue, xOldValue)
    Local lResult := .T.
    If (cAction == "DELETE")
        If !(lResult := oMldCOR:IsInserted())
            Help(" ",1,"GCPA500_04",,STR0009, 1, 0, NIL, NIL, NIL, NIL, NIL, {}) //Não é possível deletar, desabilite o fornecedor.
        EndIf
    EndIf
Return lResult

/*/{Protheus.doc} G500VldDic
    Realiza validação do dicionário p/ utilização do credenciamento
@author philipe.pompeu
@since 25/05/2022
@return lVldDict, lógico, se o dicionário está válido p/ utilizar o credenciamento
/*/
Function G500VldDic()
    Local cX2Unico  := ""
    Local lVldDict  := .T.

    lVldDict := COR->(ColumnPos('COR_CODEDT') > 0 .And. ColumnPos('COR_NUMPRO') > 0)
    If (lVldDict)
        cX2Unico := AllTrim(FWX2Unico('COR'))+"+"
        lVldDict := ("COR_CODEDT" $ cX2Unico .And. "COR_NUMPRO" $ cX2Unico)
        If lVldDict
            lVldDict := FWSIXUtil():ExistIndex("COR", 2)
        EndIf
    EndIf
Return lVldDict
