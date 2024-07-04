#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CNTA170.ch"
#INCLUDE "GCTXDEF.CH"

//-- Declaração de Variáveis Estáticas
Static _nOpSign := 0

/*/{Protheus.doc} CNTA171
	Rotina responsável pela gravação dos documentos(CNK)
@author philipe.pompeu
@since 14/04/2021
@return Nil, Nulo
/*/
Function CNTA171()
    Local oBrowse  

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CNK")                                          
    oBrowse:SetDescription(STR0001)  //Cadastro de Documentos
    oBrowse:Activate()
Return Nil

/*/{Protheus.doc} MenuDef
	Operações do menu
@author philipe.pompeu
@since 14/04/2021
@return aRotina, vetor, contêm as operações do menu
/*/
Static Function MenuDef()
    Local aRotSign := {} //Sub-menu assinatura eletrônica
    Private aRotina := {} //Array utilizado para controlar opcao selecionada

    ADD OPTION aRotSign TITLE STR0022 ACTION "CN171IncSg" OPERATION 4 ACCESS 0 //"Integrar Assinatura"
    ADD OPTION aRotSign TITLE STR0023 ACTION "CN171RepSg" OPERATION 4 ACCESS 0 //"Republicar Assinatura"
    ADD OPTION aRotSign TITLE STR0024 ACTION "CN171StsSg" OPERATION 4 ACCESS 0 //"Atualizar Status"

    ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"			OPERATION 1 ACCESS 0 //"Pesquisar"
    ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.CNTA171" 	OPERATION 2 ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.CNTA171"	OPERATION 3 ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.CNTA171"  	OPERATION 4 ACCESS 0 //"Alterar"
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.CNTA171"	OPERATION 5 ACCESS 0 //"Excluir"
    ADD OPTION aRotina TITLE STR0007 ACTION "CN170BcoDoc"	    OPERATION 8 ACCESS 0 //"Conhecimento"
    ADD OPTION aRotina TITLE STR0025 ACTION aRotSign            OPERATION 4 ACCESS 0 //"Assinatura Eletrônica"

    If ExistBlock("CTA170MNU")
        /*variável <aRotina> precisa ser Private p/ manter compatibilidade com o P.E CTA170MNU*/
        ExecBlock("CTA170MNU",.F.,.F.)
    EndIf
Return aRotina

/*/{Protheus.doc} ModelDef
	Definição do modelo de dados dos documentos(CNK)
@author philipe.pompeu
@since 14/04/2021
@return oModel, objeto, instância de MPFormModel
/*/
Static Function ModelDef()
    Local oStruCab  := FWFormStruct(1,"CNK")
    Local oStruCXR  := Nil
    Local oModel    := Nil
    Local bCommit   := {|x| CN171Grv(x) }
    Local bPosCXR   := {|x| PosVldCXR(x) }
    Local bPosCNK   := {|x| PosVldCNK(x) }
    Local aRelation := {}
    Local cVldContra:= AllTrim(GetSx3Cache("CNK_CONTRA", "X3_VALID")) + "|" + AllTrim(GetSx3Cache("CNK_TPDOC", "X3_VALID"))
    
    oModel:= MPFormModel():New("CNTA171", /*Pre-Validacao*/, bPosCNK, bCommit,/*Cancel*/)

    If ("CN170ValidDoc" $ cVldContra)//Remover qnd os releases inferiores a 12.1.27 forem descontinuados.
        oStruCab:SetProperty("CNK_CONTRA"   ,MODEL_FIELD_VALID,MTBlcVld("CNK","CNK_CONTRA"	,'ExistCpo("CN9")',.F.,.F.) )
        oStruCab:SetProperty("CNK_TPDOC"    ,MODEL_FIELD_VALID,MTBlcVld("CNK","CNK_TPDOC"	,'ExistCpo("CN5")',.F.,.F.) )
    EndIf

    oModel:AddFields("CNKMASTER",/*cOwner*/,oStruCab)
    oModel:SetPrimaryKey( {"CNK_FILIAL","CNK_CODIGO"} )

    If AliasInDic('CXR')
	    oStruCXR := FWFormStruct(1,'CXR')
        oModel:AddGrid('CXRDETAIL','CNKMASTER', oStruCXR,/*preVld*/, bPosCXR)

        aRelation := {{'CXR_FILIAL','xFilial("CXR")'},{'CXR_CODIGO','CNK_CODIGO'}}

        oModel:SetRelation('CXRDETAIL', aRelation, CXR->(IndexKey(1)))

        oModel:GetModel('CXRDETAIL'):SetUniqueLine({"CXR_EMAIL"})
        oModel:GetModel('CXRDETAIL'):SetOptional(.T.)
        oModel:GetModel('CXRDETAIL'):SetDescription( STR0016 )//Destinatários

        If _nOpSign > 0
            oModel:GetModel("CNKMASTER"):GetStruct():SetProperty('*', MODEL_FIELD_WHEN, {||.F.})
        EndIf
    EndIf
    
    oModel:SetVldActivate({|x| CN171VldAc(x)}) //Validacao na ativacao do Model
    oModel:SetActivate({|x| CN171Act(x)} )
Return oModel

/*/{Protheus.doc} ViewDef
	Definição da tela de visualização do modelo de documentos(CNK)
@author philipe.pompeu
@since 14/04/2021
@return oView, objeto, instância de FWFormView
/*/
Static Function ViewDef()
    Local oModel   	:= FWLoadModel("CNTA171")
    Local oStruCab 	:= FWFormStruct(2,"CNK")
    Local oStruCXR  := Nil
    Local oView	  	:= FWFormView():New()

    oView:SetModel(oModel)  //-- Define qual o modelo de dados será utilizado

    oView:AddField("VIEW_CNK",oStruCab,"CNKMASTER")
    oView:CreateHorizontalBox("CABEC",50)
    oView:SetOwnerView("VIEW_CNK","CABEC")
    oView:SetProgressBar(.T.)

    If AliasInDic('CXR')
	    oStruCXR := FWFormStruct(2,'CXR', {|x| !(AllTrim(x)+'|' $ 'CXR_CODIGO|') })
        oView:AddGrid('VIEW_CXR', oStruCXR, 'CXRDETAIL')

        oView:CreateHorizontalBox("GRDCXR",50)
        oView:SetOwnerView("VIEW_CXR","GRDCXR")     
        oView:EnableTitleView("VIEW_CXR")
        oView:AddIncrementField('VIEW_CXR','CXR_ITEM')

        If _nOpSign > 0 //Define a view como modificada.
            oView:lModify := .T.
        EndIf
    EndIf
Return oView

/*/{Protheus.doc} CN171Grv
	Bloco de commit do modelo da CNK
@author philipe.pompeu
@since 14/04/2021
@return lCommit, lógico, se a gravação ocorreu com sucesso
/*/
Static Function CN171Grv(oModel)
    Local lCommit := .F.
    
    Begin Transaction
        
        If (oModel:GetOperation() == MODEL_OPERATION_DELETE)            
            MsDocument("CNK", CNK->(Recno()),2,,3)//Exclui a amarracao com os conhecimentos
        EndIf

        lCommit := FWFormCommit(oModel)

    End Transaction

    If ExistBlock("CN170GRD")
        ExecBlock("CN170GRD",.F.,.F.,{oModel:GetOperation()})
    EndIf
Return lCommit

/*/{Protheus.doc} CN171VldAc
	Valida a ativação do modelo de dados
@author philipe.pompeu
@since 16/04/2021
@return lResult, lógico, se permite a ativação do modelo
/*/
Static Function CN171VldAc(oModel as Object) as Logical
    Local lResult   := .T.
    Local lCposSign := CN5->(FieldPos('CN5_ASSINA') > 0) .And. CNK->(FieldPos('CNK_SIGNID') > 0) .And. CNK->(FieldPos('CNK_SIGNST') > 0)
    Local cTranCod  := ""

    If (oModel:GetOperation() == MODEL_OPERATION_DELETE)
        cTranCod:= DEF_DOC_EXC //Exclusao de Documentos

        If lCposSign .And. !Empty(CNK->CNK_SIGNID) .And. CNK->CNK_SIGNST == '2'
            Help(" ",1,"CN171SIGNDEL",,STR0015, 1, 0, NIL, NIL, NIL, NIL, NIL, {''}) //Não é permitido excluir um documento integrado via TOTVS Sign que teve a assinatura finalizada. 
            lResult := .F.
        EndIf
    ElseIf(oModel:GetOperation() == MODEL_OPERATION_VIEW)
        cTranCod:= DEF_DOC_VIS //Visualizacao de Documentos
    ElseIf(oModel:GetOperation() == MODEL_OPERATION_UPDATE)
        cTranCod:= DEF_DOC_EDT //Edição de Documentos

        If lCposSign .And. _nOpSign > 0
            
            If Empty(CNK->CNK_SIGNID)
                CN5->(DbSetOrder(1))//CN5_FILIAL+CN5_CODIGO  

                If CN5->(DbSeek(xFilial("CN5") + CNK->CNK_TPDOC))       
                    If !(CN5->CN5_ASSINA)
                        Help(" ",1,"CN171SIGNTIP",,STR0027, 1, 0, NIL, NIL, NIL, NIL, NIL, {''}) //O tipo do documento não permite integração via TOTVS Sign.
                        lResult := .F.
                    EndIf
                EndIf

                If lResult .And. (_nOpSign == 2 .Or. _nOpSign == 3) .And. CN5->CN5_ASSINA .And. CNK->CNK_SIGNST == 'N'
                    Help(" ",1,"CN171SIGNASN",,STR0028, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0029}) //A assinatura do documento ainda não foi integrada.
                    lResult := .F.
                EndIf
            ElseIf _nOpSign == 1
                Help(" ",1,"CN171SIGNINT",,STR0030, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0031}) //Este documento já foi integrado.
                lResult := .F.
            ElseIf _nOpSign == 2 .And. CNK->CNK_SIGNST != '5'
                Help(" ",1,"CN171SIGNSTS",,STR0032, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0031}) //Este documento já está publicado.
                lResult := .F.
            EndIf
        EndIf
    EndIf

    If lResult .And. !(Empty(cTranCod)) //Deve-se validar a permissão do usuário
        lResult := CN240VldUsr(CNK->CNK_CONTRA,cTranCod,.T.)
    EndIf
Return lResult

/*/{Protheus.doc} CN171Act
	Chamada na ativação do modelo de dados
@author philipe.pompeu
@since 16/04/2021
@return Nil, nulo
/*/
Static Function CN171Act(oModel as Object)
    Local oMdlCXR := Nil
    Local lNoUpdCXR := .T.

    If (AliasInDic('CXR') .And. CNK->(FieldPos('CNK_SIGNID') > 0))
        oMdlCXR := oModel:GetModel('CXRDETAIL')
        
        If (oModel:GetOperation() == MODEL_OPERATION_INSERT)
            lNoUpdCXR := .F.
        ElseIf (oModel:GetOperation() == MODEL_OPERATION_UPDATE)
            lNoUpdCXR := !Empty(CNK->CNK_SIGNID) .Or. _nOpSign > 0

            If _nOpSign > 0 //Define o modelo como modificado.
                oModel:lModify := .T.
                oModel:lValid := .F.
            EndIf
        EndIf
        
        oMdlCXR:SetNoDeleteLine(lNoUpdCXR)
        oMdlCXR:SetNoUpdateLine(lNoUpdCXR)
        oMdlCXR:SetNoInsertLine(lNoUpdCXR)
    EndIf
Return Nil

/*/{Protheus.doc} PosVldCXR
	Pos-valid da tabela CXR
@author philipe.pompeu
@since 16/04/2021
@return lResult, lógico, registro válido
/*/
Static Function PosVldCXR(oSubModel as Object) as Logical
    Local lResult := .T.
    Local cEmail := AllTrim(oSubModel:GetValue('CXR_EMAIL'))

    If ( Empty(cEmail) .Or. !IsEmail(cEmail) )
        Help(" ",1,"CN171EMAIL",,STR0018, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0019})//Informe um e-mail válido.
        lResult := .F.
    EndIf
Return lResult

/*/{Protheus.doc} PosVldCNK
	Pos-valid do modelo total
@author philipe.pompeu
@since 16/04/2021
@return lResult, lógico, registro válido
/*/
Static Function PosVldCNK(oModel as Object) as Logical
    Local lResult  := .T.
    Local oMdlCXR  := Nil  
    Local lCXRVld  := .T.
    Local cTranCod := ""

    If (oModel:GetOperation() != MODEL_OPERATION_DELETE) //Se não for exclusão.
        
        If (oModel:GetOperation() == MODEL_OPERATION_UPDATE)
            cTranCod := DEF_DOC_EDT //Edicao de Documentos
        ElseIf(oModel:GetOperation() == MODEL_OPERATION_INSERT)
            cTranCod := DEF_DOC_INC //Exclusao de Documentos
        EndIf

        If (AliasInDic('CXR') .And. CN5->(FieldPos('CN5_ASSINA') > 0))
            oMdlCXR := oModel:GetModel('CXRDETAIL')
            oMdlCXR:GoLine(1)
            lCXRVld := (oMdlCXR:Length(.T.) > 1 .Or. (oMdlCXR:Length(.T.) == 1 .And. !Empty(oMdlCXR:GetValue("CXR_EMAIL"))))            

            If !lCXRVld
                CN5->(DbSetOrder(1))//CN5_FILIAL+CN5_CODIGO        
                If CN5->(DbSeek(xFilial("CN5") + oModel:GetValue("CNKMASTER", "CNK_TPDOC")))            
                    If (CN5->CN5_ASSINA)
                        Help(" ",1,"CN171SIGNCN5",,STR0020, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0021})//Informe ao menos um destinatário para prosseguir.
                        lResult := .F.
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf

    If lResult .And. !(Empty(cTranCod)) //Deve-se validar a permissão do usuário        
        lResult := CN240VldUsr(oModel:GetValue("CNKMASTER", "CNK_CONTRA"), cTranCod,.T.)
    EndIf

    lResult := lResult .And. EnvAssDoc(oModel) //Realiza envio de assinatura
    
Return lResult

/*/{Protheus.doc} SignView
	Abre a view para realizar operações do TOTVS Sign.
@author juan.felipe
@since 26/04/2021
@param nOpc, numeric, operação que será realizada no TOTVS Sign 1-Integrar; 2- Republicar; 3-Atualizar.
@param cTitulo, numeric, título exibido na abertura da rotina.
@return Nil, nulo
/*/
Static Function SignView(nOpc, cTitulo)
    Default nOpc := 0
    Default cTitulo := ''

    _nOpSign := nOpc
    FWExecView(cTitulo ,'CNTA171',MODEL_OPERATION_UPDATE,,{|| .T.},,,,,"A")
    _nOpSign := 0
Return Nil

/*/{Protheus.doc} CN171IncSg
	Seta operação de Integração com o TOTVS Sign.
@author juan.felipe
@since 26/04/2021
@return Nil, nulo
/*/
Function CN171IncSg()
    SignView(1, STR0022) //Integrar Assinatura
Return Nil

/*/{Protheus.doc} CN171RepSg
	Seta operação de Republicação com o TOTVS Sign.
@author juan.felipe
@since 26/04/2021
@return Nil, nulo
/*/
Function CN171RepSg()
    SignView(2, STR0023) //Republicar Assinatura
Return Nil

/*/{Protheus.doc} CN171StsSg
	Seta operação de Atualização com o TOTVS Sign.
@author juan.felipe
@since 26/04/2021
@return Nil, nulo
/*/
Function CN171StsSg()
    SignView(3, STR0024) //Atualizar Status
Return Nil

/*/{Protheus.doc} CN171SOpSg
	Seta operação de com o TOTVS Sign, função utilizada em ExecAuto.
@author juan.felipe
@since 26/04/2021
@return Nil, nulo
/*/
Function CN171SOpSg(nOpc)
    Default nOpc := 0
    _nOpSign := nOpc
Return Nil

/*/{Protheus.doc} CN171CbSt
	Opções exibidas no campo Situação da Assinatura (CNK_SIGNST)
@author juan.felipe
@since 26/04/2021
@return Nil, nulo
/*/
Function CN171CbSt()
    Local cRet := ''
    cRet += '0=' + STR0034 + ';' //Pendente
    cRet += '2=' + STR0035 + ';' //Finalizada
    cRet += '4=' + STR0036 + ';' //Rejeitada
    cRet += '5=' + STR0037 + ';' //Em Rascunho
    cRet += 'N=' + STR0038       //Não possui assinatura
Return cRet

/*/{Protheus.doc} EnvAssDoc
	Opções exibidas no campo Situação da Assinatura (CNK_SIGNST)
@author juan.felipe
@since 27/04/2021
@return Nil, nulo
/*/
Static Function EnvAssDoc(oModel)
    Local lRet := .T.
    Local oGCTSign := Nil
    Local oModelCNK := Nil

    If CNK->(FieldPos('CNK_SIGNID') > 0) .And. CNK->(FieldPos('CNK_SIGNST') > 0)
        If (oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. _nOpSign > 0) .Or. (oModel:GetOperation() == MODEL_OPERATION_DELETE .And. !Empty(CNK->CNK_SIGNID))
            oModelCNK := oModel:GetModel('CNKMASTER')

            oGCTSign := GCTSign():New()
            If oModel:GetOperation() == MODEL_OPERATION_UPDATE
                oGCTSign:SetOperation(_nOpSign) //-- Seta operação 1- Envia/publica documento; 2- Republica documento; 3- Atualiza situação da assinatura
            Else
                oGCTSign:SetOperation(4) //-- Seta operação 4- Deleção
            EndIf

            If oGCTSign:Authenticate() //-- Realiza autenticação
                oGCTSign:SetDocument(CNK->CNK_CODIGO)
                oGCTSign:SetSignId(Val(CNK->CNK_SIGNID))

                oGCTSign:Process(.T., oModel) //-- Processa documento a partir do modelo
            EndIf

            lRet := oGCTSign:GetMessage(.T.)[1] //-- Exibe help caso houver erro
            
            oGCTSign:CleanUp()
            FreeObj(oGCTSign)
        EndIf
    EndIf
Return lRet
