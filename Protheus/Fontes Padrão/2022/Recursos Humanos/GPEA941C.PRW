#include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#include 'GPEA941C.CH'
#INCLUDE "FWMBROWSE.CH"

Static lParcial	    := .F.
Static lVerRJ5	    := FindFunction("fVldObraRJ") .And. (fVldObraRJ(@lParcial, .T.) .And. !lParcial)
Static lIntTaf      := SuperGetMv("MV_RHTAF",, .F.) //Integracao com TAF
Static lMiddleware  := If(cPaisLoc == 'BRA' .And. Findfunction("fVerMW"), fVerMW(), .F.)
Static lOk          := (lIntTaf .Or. lMiddleware)

/*/{Protheus.doc} GPEA941C
Cadastro dos Processos da Verba
@author Allyson Mesashi
@since 13/03/2020
@version P12.1.27
@Type     Function
/*/
Function GPEA941C()

Local oBrowse   := FWmBrowse():New()

If !ChkFile("RJM")
    Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0003), 1, 0 )//"Atenção"#"Tabela RJM não encontrada. Execute o UPDDISTR - Atualizador de dicionário e base de dados."
    return .F.
EndIf

If !lOk
	Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0017), 1, 0 )//"Atenção"#"A rotina somente deverá ser utilizada quando a integração do eSocial estiver ativa"
	Return
EndIf

If !lVerRJ5
    If FWModeAccess("RJM", 1)+FWModeAccess("RJM", 2)+FWModeAccess("RJM", 3) != FWModeAccess("CTT", 1)+FWModeAccess("CTT", 2)+FWModeAccess("CTT", 3)
        Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0004), 1, 0 )//"Atenção"#"O modo de acesso da tabela RJM deve ser idêntico ao da tabela CTT"
        Return
    EndIf
Else
    If FWModeAccess("RJM", 1)+FWModeAccess("RJM", 2)+FWModeAccess("RJM", 3) != FWModeAccess("RJ3", 1)+FWModeAccess("RJ3", 2)+FWModeAccess("RJ3", 3)
        Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0005), 1, 0 )//"Atenção"#"O modo de acesso da tabela RJM deve ser idêntico ao da tabela RJ3"
        Return
    EndIf
EndIf

//Monta o Browse
oBrowse:SetAlias( 'RJM' )
oBrowse:SetDescription( OemToAnsi(STR0001) ) //"Processos da Lotação"
oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Definição do MenuDef
@type function
@author Allyson Mesashi
@since 13/03/2020
@version 1.0
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0006) Action 'PesqBrw'            OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0007) Action 'VIEWDEF.GPEA941C'   OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0013) Action 'VIEWDEF.GPEA941C'   OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina Title OemToAnsi(STR0008) Action 'VIEWDEF.GPEA941C'   OPERATION 4 ACCESS 0 // "Manutenção"
ADD OPTION aRotina Title OemToAnsi(STR0009) Action 'VIEWDEF.GPEA941C'   OPERATION 5 ACCESS 0 // "Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Definição e detalhamento do Model
@type function
@author Allyson Mesashi
@since 13/03/2020
@version 1.0
/*/
Static Function ModelDef()

Local oMdl
Local bCpCab   	    := { |cCampo| AllTrim(cCampo) + "|" $ "RJM_FILIAL|RJM_COD|RJM_COMPET|RJM_TERS|" }
Local bCpDet   	    := { |cCampo| AllTrim(cCampo) + "|" $ "RJM_FILIAL|RJM_TERC|RJM_NPROC|RJM_SUSP|" }
Local bGetDet       := { |oModel| fGetRJM(oModel, RJM->RJM_FILIAL, RJM->RJM_TERS, RJM->RJM_COMPET) }
Local oCab          := FWFormStruct(1, 'RJM', bCpCab)
Local oDet          := FWFormStruct(1, 'RJM', bCpDet,)
Local bCommit       := { |oMdlRJM| GP941Commit(oMdl) }
Local bPosValid	    := { |oMdlRJM| GP941Pos(oMdl) }
Local bLinePre 	    := { |oMdlRJM| GP941LPre(oMdl)}

oMdl := MPFormModel():New('GPEA941C', /*bPreValid */, bPosValid, bCommit, /*bCancel*/)

oMdl:AddFields('RJMMASTER', /*cOwner*/, oCab, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)
oMdl:AddGrid( 'RJMDETAIL', 'RJMMASTER', oDet, bLinePre, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, bGetDet )

oMdl:SetRelation('RJMDETAIL', {{'RJM_FILIAL', 'RJM_FILIAL'}, {'RJM_COD', 'RJM_COD'}, {'RJM_COMPET', 'RJM_COMPET'}}, RJM->(IndexKey(1)))

oMdl:GetModel('RJMDETAIL'):SetUniqueLine({'RJM_NPROC', 'RJM_SUSP'})

//Permite grid sem dados
oMdl:GetModel("RJMDETAIL"):SetDescription( OemToAnsi("Lotação") )//Lotação
oMdl:GetModel("RJMDETAIL"):SetOptional( .T. )
oMdl:GetModel("RJMDETAIL"):SetMaxLine(99)

// Adiciona a descricao do Componente do Modelo de Dados
oMdl:GetModel('RJMMASTER'):SetDescription(OemToAnsi("Lotação")) // "Lotação"

// VALIDA AS VERSÕES DO ESOCIAL.
oMdl:SetVldActivate({|oModel| Iif(FindFunction("fVldDifVer"), fVldDifVer(oMdl, @lIntTAF), .T.)})

oMdl:SetPrimaryKey( {} )

Return oMdl

/*/{Protheus.doc} ViewDef
Definição da viewdef
@type method
@author Allyson Mesashi
@since 13/03/2020
@version 1.0
/*/
Static Function ViewDef()

Local oView
Local oModel        := FWLoadModel('GPEA941C')
Local bCpCab   	    := { |cCampo| AllTrim(cCampo) + "|" $ "RJM_FILIAL|RJM_COD|RJM_COMPET|RJM_TERS|" }
Local bCpDet   	    := { |cCampo| AllTrim(cCampo) + "|" $ "RJM_FILIAL|RJM_TERC|RJM_NPROC|RJM_SUSP|" }
Local oCab          := FWFormStruct(2, 'RJM', bCpCab)
Local oDet          := FWFormStruct(2, 'RJM', bCpDet)

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_RJM1', oCab, 'RJMMASTER')
oView:AddGrid('VIEW_RJM2', oDet, 'RJMDETAIL')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 15)
oView:CreateHorizontalBox('INFERIOR', 85)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_RJM1', 'SUPERIOR')
oView:SetOwnerView('VIEW_RJM2', 'INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_RJM1', OemToAnsi(STR0010)) // "Lotação"
oView:EnableTitleView('VIEW_RJM2', OemToAnsi(STR0011)) // "Processos"

oView:SetCloseOnOk({ || .T. })	//Desabilita botão "Salvar e Criar Novo"

Return oView

/*/{Protheus.doc} fGetRJM
Carrega todos os processos para o terceiro
@type static function
@author Allyson Mesashi
@since 13/03/2020
@version 1.0
/*/
Static Function fGetRJM(oMdl, cFilRJM, cTerS, cCompet)

Local aRet       := {}
Local cTmpTrab   := GetNextAlias()

BeginSql alias cTmpTrab
    SELECT RJM_FILIAL,RJM_COMPET,RJM_TERS,RJM_TERC,RJM_NPROC,RJM_SUSP
    FROM %table:RJM% RJM
    WHERE RJM.RJM_FILIAL = %exp:cFilRJM%
        AND RJM.RJM_TERS = %exp:cTerS%
        AND RJM.RJM_COMPET = %exp:cCompet%
        AND RJM.%NotDel%
    GROUP BY RJM_FILIAL,RJM_COMPET,RJM_TERS,RJM_TERC,RJM_NPROC,RJM_SUSP
EndSql

aRet := FwLoadByAlias( oMdl, cTmpTrab )
(cTmpTrab)->(DbCloseArea())

Return aRet

/*/{Protheus.doc} GP941Pos
PosValid da rotina GPEA941C
@type      	Static Function
@author Allyson Mesashi
@since 13/03/2020
@version	1.0
@return		lEdit,		logic
/*/
Static Function GP941Pos(oModel)

Local cFilRJM       := ""
Local cCodRJM       := ""
Local cCompRJM      := ""
Local cAliasRJM     := "RJM"
Local cMsgErro      := ""
Local dBkpDtBa      := dDatabase
Local lIncluiu      := .F.
Local lRet          := .T.
Local nCont         := 0
Local nOper         := oModel:GetOperation()
Local oCab          := oModel:GetModel("RJMMASTER")
Local oGrid         := oModel:GetModel("RJMDETAIL")

DbSelectArea(cAliasRJM)
(cAliasRJM)->( DbSetOrder(1) ) //RJM_FILIAL+RJM_COD+RJM_COMPET+RJM_TERS+RJM_TERC+RJM_NPROC+RJM_SUSP                                                                                              

cFilRJM     :=  xFilial("RJM")
cCodRJM     :=  oCab:GetValue("RJM_COD")
cCompRJM    :=  oCab:GetValue("RJM_COMPET")

// Valida Inclusão
If nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_UPDATE
    If (cAliasRJM)->( DbSeek(cFilRJM + cCodRJM + cCompRJM) ) .And. (nOper == MODEL_OPERATION_INSERT .Or. cFilRJM + cCodRJM + cCompRJM != RJM->RJM_FILIAL+RJM->RJM_COD+RJM->RJM_COMPET)
        Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0012), 1, 0 )//"Atenção", "Não é possível realizar a inclusão pois já existe um registro para esta lotação."
        lRet := .F.
    EndIf
EndIf

If lRet
    Begin Sequence
        If nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_UPDATE
            For nCont := 1 To oGrid:Length()
                If !oGrid:IsDeleted(nCont) 
                    If (Empty(oGrid:GetValue("RJM_NPROC", nCont)) .Or. Empty(oGrid:GetValue("RJM_SUSP", nCont)))
                        Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0014), 1, 0 )//"Atenção", "Não foi efetuado o cadastro do(s) processo(s)."
                        lRet := .F.
                        Break
                    Else
                        lIncluiu := .T.
                    EndIf
                EndIf
            Next nCont
        EndIf
    End Sequence
EndIf

If nOper != MODEL_OPERATION_DELETE .And. lRet .And. !lIncluiu
    Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0014), 1, 0 )//"Atenção", "Não foi efetuado o cadastro do(s) processo(s)."
    lRet := .F.
EndIf

If lRet
    If !lVerRJ5
        If CTT->( dbSeek( xFilial("CTT")+cCodRJM ) )
            RegToMemory("CTT", .F., .F., .F., "GPEA941C")
            dDatabase   := sToD(cCompRJM+"01")
            lRet        := Ctb030eSoc(Iif(nOper != MODEL_OPERATION_DELETE, nOper, 4), .T., @cMsgErro, oModel)
            If !lRet
                Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0019 + CRLF + cMsgErro), 1, 0 )//"Atenção"##"Há inconsistências(s) no cadastro da lotação que impede(m) a integração do evento S-1020:"
            ElseIf !Empty(cMsgErro)
                MsgInfo(STR0019 + CRLF + cMsgErro, OemToAnsi(STR0002))//"Atenção"##"Há inconsistências(s) no cadastro da lotação que impede(m) a integração do evento S-1020:"
            EndIf
            dDatabase   := dBkpDtBa
        Else
            Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0018), 1, 0 )//"Atenção", "Não existe registro relacionado a este código de lotação."
            lRet := .F.
        EndIf
    Else
        RJ3->( dbSetOrder(2) )
        If RJ3->( dbSeek( xFilial("RJ3")+cCodRJM+cCompRJM ) )
            RegToMemory("RJ3", .F., .F., .F., "GPEA941C")
            lRet        := fVldRJ3(Iif(nOper != MODEL_OPERATION_DELETE, nOper, 4), .T., @cMsgErro, oModel)
            If !lRet
                Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0019 + CRLF + cMsgErro), 1, 0 )//"Atenção"##"Há inconsistências(s) no cadastro da lotação que impede(m) a integração do evento S-1020:"
            ElseIf !Empty(cMsgErro)
                MsgInfo(STR0019 + CRLF + cMsgErro, OemToAnsi(STR0002))//"Atenção"##"Há inconsistências(s) no cadastro da lotação que impede(m) a integração do evento S-1020:"
            EndIf
        Else
            Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0018), 1, 0 )//"Atenção", "Não existe registro relacionado a este código de lotação."
            lRet := .F.
        EndIf
    EndIf
EndIf

Return lRet

/*/{Protheus.doc} GP941LPre
Linha Ok
@type      	Static Function
@author Allyson Mesashi
@since 13/03/2020
@version	1.0
@param		oMdlRJM, 	object, 	Objeto da Grid a ser validada
@return		lRet,		logic
/*/
Static Function GP941LPre(oMdlRJM)

Local cCod      := oMdlRJM:GetModel("RJMMASTER"):GetValue("RJM_COD")
Local cCompet   := oMdlRJM:GetModel("RJMMASTER"):GetValue("RJM_COMPET")
Local cTerS     := oMdlRJM:GetModel("RJMMASTER"):GetValue("RJM_TERS")
Local lRet 	    := .T.

If Empty(cCod) .Or. Empty(cCompet) .Or. Empty(cTerS)
    lRet := .F.
    Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0015), 1, 0 )//"Atenção", "Preencha os campos obrigatórios"
EndIf

Return lRet

/*/{Protheus.doc} GP941Commit
Commit da rotina GPEA941C
@type      	Static Function
@author Allyson Mesashi
@since 13/03/2020
@version	1.0
@return		lEdit,		logic
/*/
Static Function GP941Commit( oModel )

Local aCodLot   := {}
Local aCodProc  := {}
Local cCodComp  := ""
Local cCodLot   := ""
Local cCodTerS  := ""
Local nContLot  := 0
Local nContPrc  := 0
Local lRet      := .T.
Local nCont     := 0
Local nOper     := oModel:GetOperation()
Local oCab      := oModel:GetModel("RJMMASTER")
Local oGrid     := oModel:GetModel("RJMDETAIL")

Begin Transaction
    cCodComp  := oCab:GetValue("RJM_COMPET")
    cCodLot   := oCab:GetValue("RJM_COD")
    cCodTerS  := oCab:GetValue("RJM_TERS")
    IF nOper == MODEL_OPERATION_INSERT        
        For nCont := 1 To oGrid:Length()
            If !oGrid:IsDeleted(nCont) .And. RecLock("RJM", .T.)
                RJM->RJM_FILIAL := xFilial("RJM")
                RJM->RJM_COD    := cCodLot
                RJM->RJM_COMPET := cCodComp
                RJM->RJM_TERS   := cCodTerS
                RJM->RJM_TERC   := oGrid:GetValue("RJM_TERC", nCont)
                RJM->RJM_NPROC  := oGrid:GetValue("RJM_NPROC", nCont)
                RJM->RJM_SUSP   := oGrid:GetValue("RJM_SUSP", nCont)
                RJM->(MsUnLock())
                aAdd( aCodProc, { RJM->RJM_TERC, RJM->RJM_NPROC, RJM->RJM_SUSP } )
            EndIf
        Next nCont
        RJM->( DbSetOrder(2) ) //RJM_FILIAL+RJM_TERS+RJM_COMPET+RJM_COD
        If RJM->( DbSeek( xFilial("RJM")+cCodTerS+cCodComp ) )
            While !RJM->( Eof() ) .And. RJM->RJM_FILIAL+RJM->RJM_TERS+RJM->RJM_COMPET == xFilial("RJM")+cCodTerS+cCodComp
                If RJM->RJM_COD != cCodLot .And. RecLock("RJM", .F.)
                    If aScan( aCodLot, { |x| x == RJM->RJM_COD } ) == 0
                        aAdd( aCodLot, RJM->RJM_COD )
                    EndIf
                    RJM->( dbDelete() )
                    RJM->( MsUnlock() )                    
                EndIf
                RJM->( dbSkip() )
            EndDo
            For nContLot := 1 To Len(aCodLot)
                For nContPrc := 1 To Len(aCodProc)
                    If RecLock("RJM", .T.)
                        RJM->RJM_FILIAL := xFilial("RJM")
                        RJM->RJM_COD    := aCodLot[nContLot]
                        RJM->RJM_COMPET := cCodComp
                        RJM->RJM_TERS   := cCodTerS
                        RJM->RJM_TERC   := aCodProc[nContPrc, 1]
                        RJM->RJM_NPROC  := aCodProc[nContPrc, 2]
                        RJM->RJM_SUSP   := aCodProc[nContPrc, 3]
                        RJM->(MsUnLock())
                    EndIf                   
                Next nContPrc              
            Next nContLot
        EndIf
    ElseIf nOper == MODEL_OPERATION_UPDATE
        For nCont := 1 To oGrid:Length()
            If !oGrid:IsDeleted(nCont)
                aAdd( aCodProc, { oGrid:GetValue("RJM_TERC", nCont), oGrid:GetValue("RJM_NPROC", nCont), oGrid:GetValue("RJM_SUSP", nCont) } )
            EndIf
        Next nCont
        RJM->( DbSetOrder(2) ) //RJM_FILIAL+RJM_TERS+RJM_COMPET+RJM_COD
        If RJM->( DbSeek( xFilial("RJM")+cCodTerS+cCodComp ) )
            While !RJM->( Eof() ) .And. RJM->RJM_FILIAL+RJM->RJM_TERS+RJM->RJM_COMPET == xFilial("RJM")+cCodTerS+cCodComp
                If RecLock("RJM", .F.)
                    If aScan( aCodLot, { |x| x == RJM->RJM_COD } ) == 0
                        aAdd( aCodLot, RJM->RJM_COD )
                    EndIf
                    RJM->( dbDelete() )
                    RJM->( MsUnlock() )                    
                EndIf
                RJM->( dbSkip() )
            EndDo
        EndIf
        For nContLot := 1 To Len(aCodLot)
            For nContPrc := 1 To Len(aCodProc)
                If RecLock("RJM", .T.)
                    RJM->RJM_FILIAL := xFilial("RJM")
                    RJM->RJM_COD    := aCodLot[nContLot]
                    RJM->RJM_COMPET := cCodComp
                    RJM->RJM_TERS   := cCodTerS
                    RJM->RJM_TERC   := aCodProc[nContPrc, 1]
                    RJM->RJM_NPROC  := aCodProc[nContPrc, 2]
                    RJM->RJM_SUSP   := aCodProc[nContPrc, 3]
                    RJM->(MsUnLock())
                EndIf                   
            Next nContPrc              
        Next nContLot
    ElseIf nOper == MODEL_OPERATION_DELETE
        RJM->( DbSetOrder(1) ) //RJM_FILIAL+RJM_COD+RJM_COMPET+RJM_TERS+RJM_TERC+RJM_NPROC+RJM_SUSP
        If RJM->( DbSeek( xFilial("RJM")+cCodLot+cCodComp ) )
            While !RJM->( Eof() ) .And. RJM->RJM_FILIAL+RJM->RJM_COD+RJM->RJM_COMPET == xFilial("RJM")+cCodLot+cCodComp
                If RecLock("RJM", .F.)
                    RJM->( dbDelete() )
                    RJM->( MsUnlock() )
                EndIf
                RJM->( dbSkip() )
            EndDo
        EndIf
    EndIf
End Transaction

Return lRet

/*/
{Protheus.doc} fConsPrcLot
Função que abre consulta padrão da CTT ou RJ3
@type      	Static Function
@author Allyson Mesashi
@since 13/03/2020
@version 1.0
@return		lRet,		logic
/*/
Function fConsPrcLot()

Local lRet		:= .F.

If !lVerRJ5
	lRet := ConPad1(,,,"CTT")
Else
	lRet := ConPad1(,,,"RJ3")
EndIf

If lRet
	VAR_IXB := {aCpoRet[1]}
EndIf

Return lRet

/*/
{Protheus.doc} fRetPrcLot
Função que efetua o retorno da consulta padrão da CTT ou RJ3
@type      	Static Function
@author Allyson Mesashi
@since 13/03/2020
@version 1.0
@return		cRet,		charecter
/*/
Function fRetPrcLot()

Local cRet		:= ""

If !lVerRJ5
	cRet := CTT->CTT_CUSTO
Else
	cRet := RJ3->RJ3_COD
EndIf

Return cRet

/*/
{Protheus.doc} fVldRJMCod
Função que efetua o retorno da consulta padrão da CTT ou RJ3
@type      	Static Function
@author Allyson Mesashi
@since 13/03/2020
@version 1.0
@return		lRet,		logical
/*/
Function fVldRJMCod()

Local cCodLot   := &(ReadVar())
Local lRet      := .F.

If !lVerRJ5
    lRet := ExistCpo("CTT", cCodLot)
    CTT->( dbSeek( xFilial("CTT", cFilAnt)+cCodLot ) )
    If lRet .And. CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. !Empty(CTT->CTT_CEI2) 
        Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0016), 1, 0 )//"Atenção", "Não é possível selecionar essa lotação pois está cadastrada como uma Obra Própria"
        lRet := .F.
    EndIf
Else
    lRet := ExistCpo("RJ3", cCodLot, 2)
EndIf

Return lRet

/*/
{Protheus.doc} f971CGrid
Função que executa refresh na Grid
@type      	Static Function
@author Allyson Mesashi
@since 13/03/2020
@version 1.0
@return		lRet,		logical
/*/
Function f971CGrid()

Local oModel    := FWModelActive()
Local oCab      := oModel:GetModel("RJMMASTER")
Local oGrid     := oModel:GetModel("RJMDETAIL")
Local cCod      := oCab:GetValue("RJM_COD")
Local cCodLot   := ""
Local cCompet   := oCab:GetValue("RJM_COMPET")
Local cTerS     := oCab:GetValue("RJM_TERS")
Local nOper     := oModel:GetOperation()

If nOper == MODEL_OPERATION_INSERT .And. !Empty(cCod) .And. !Empty(cCompet) .And. !Empty(cTerS)
    oGrid:DelAllLine()
    RJM->( dbSetOrder(2) )//RJM_FILIAL+RJM_TERS+RJM_COMPET+RJM_COD
    If RJM->( dbSeek( xFilial("RJM")+cTerS+cCompet ) )
        cCodLot := RJM->RJM_COD
        While RJM->( !EoF() ) .And. RJM->RJM_FILIAL+RJM->RJM_TERS+RJM->RJM_COMPET+RJM->RJM_COD == xFilial("RJM")+cTerS+cCompet+cCodLot
            If oGrid:IsDeleted()
                oGrid:UnDeleteLine()
            EndIf
            oGrid:SetValue("RJM_TERC", RJM->RJM_TERC)
            oGrid:SetValue("RJM_NPROC", RJM->RJM_NPROC)
            oGrid:SetValue("RJM_SUSP", RJM->RJM_SUSP)
            RJM->( dbSkip() )
            If RJM->( !EoF() .And. RJM->RJM_COD == cCodLot )
                oGrid:AddLine()
            EndIf
        EndDo
    EndIf
    oGrid:GoLine(1)
EndIf

Return .T.
