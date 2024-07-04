#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

Function CenFluig (oBrowUp)
    Local oFluig  := CenFluig():New(oBrowUp)
    oFluig:ProcFluig(lAuto)
    oFluig:Destroy()
    FreeObj(oFluig)
    oFluig:=nil

Return

Class CenFluig
    Data oModel
    Data oView
    Data cUserId
    Data aProcess
    Data NSOLICID
    Data cAlias
    Data nI
    Data aRec
    Data oMark
    Data cId
    Data nNextTask
    Data cComments
    Data aAttach
    Data aColleagueIds
    Data lComplete

    Method New(oMark) Constructor
    Method BscRegMark(lAuto)
    Method VldProcFl()
    Method PreenB3F()
    Method ProcFluig(lAuto)
    Method Destroy()
    Method VerProc()

EndClass

Method New(oMark) Class CenFluig
    self:oModel         := nil
    Self:oView          := FWViewActive()
    Self:cUserId        := FWWFColleagueId(GetNewPar("MV_PLUSAFL","000000"))
    Self:aProcess       :={}
    Self:NSOLICID       := 0
    Self:cAlias         := getNextAlias()
    Self:aRec           :={}
    self:oMark          := oMark
    Self:cId            := "CENPROCSIB"
    Self:nNextTask      := 0
    Self:cComments      :="Inicializa Solicitação"
    Self:aAttach        :={}
    Self:aColleagueIds  :={}
    Self:lComplete      :=.F.

return self

Method BscRegMark(lAuto) Class CenFluig
    Local cSql     :=""
    Local cAlias   := getNextAlias()
    Local lProces  :=B3F->(FieldPos("B3F_NFLUIG")) > 0
    Default lAuto  := .F.

    If lProces
        cSql := " SELECT R_E_C_N_O_ RECNO, B3F_NFLUIG "
    Else
        cSql := " SELECT R_E_C_N_O_ RECNO "
    EndIf
    cSql += " FROM " + RetSqlName("B3F") + " B3F "
    cSql += " WHERE B3F_FILIAL = '" + xfilial("B3F") + "' "

    iF !lAuto
        cSql += " AND B3F_OK = '" + Self:oMark:cMark + "' "
    Else
        cSql += " AND R_E_C_N_O_ = 91 "

    EndIf

    cSql += " AND B3F.D_E_L_E_T_ = ' '  "

    cSql := ChangeQuery(cSql)

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

    While !(cAlias)->(eof())
        If !lProces
            AADD(Self:aRec,{(cAlias)->RECNO})
        else
            AADD(Self:aRec,{(cAlias)->RECNO,(cAlias)->B3F_NFLUIG})
        Endif
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(dbclosearea())

return

Method VldProcFl() Class CenFluig
    Local aProcess := {}
    Local lLiberado:= .F.

    aProcess := FWECMPsqProcess(Self:cId)
    lLiberado := Len(aProcess) > 0 .AND. aProcess[1]

return lLiberado

Method PreenB3F() Class CenFluig

    Self:oModel:SetValue("B3FDETAIL","B3F_FILIAL",B3F->B3F_FILIAL)
    Self:oModel:SetValue("B3FDETAIL","B3F_CODOPE",B3F->B3F_CODOPE)
    Self:oModel:SetValue("B3FDETAIL","B3F_CDOBRI",B3F->B3F_CDOBRI)
    Self:oModel:SetValue("B3FDETAIL","B3F_ANO"   ,B3F->B3F_ANO   )
    Self:oModel:SetValue("B3FDETAIL","B3F_CDCOMP",B3F->B3F_CDCOMP)
    Self:oModel:SetValue("B3FDETAIL","B3F_CODCRI",B3F->B3F_CODCRI)
    Self:oModel:SetValue("B3FDETAIL","B3F_DESCRI",ALLTRIM(B3F->B3F_DESCRI))
    Self:oModel:SetValue("B3FDETAIL","B3F_RESOLV",ALLTRIM(B3F->B3F_SOLUCA))
    Self:oModel:SetValue("B3FDETAIL","B3F_ORICRI",B3F->B3F_ORICRI)
    Self:oModel:SetValue("B3FDETAIL","B3F_CHVORI",PADR(Alltrim(Str(B3F->B3F_CHVORI)),tamSX3("B3F_CHVORI")[1]))
    Self:oModel:SetValue("B3FDETAIL","B3F_STATUS",B3F->B3F_STATUS)
    Self:oModel:SetValue("B3FDETAIL","B3F_TIPO"  ,B3F->B3F_TIPO  )
    Self:oModel:SetValue("B3FDETAIL","B3F_CAMPOS",ALLTRIM(B3F->B3F_CAMPOS))
    Self:oModel:SetValue("B3FDETAIL","B3F_CRIANS",IIf(Empty(B3F->B3F_CRIANS),"000",B3F->B3F_CRIANS))
    Self:oModel:SetValue("B3FDETAIL","B3F_IDEORI",ALLTRIM(B3F->B3F_IDEORI))
    Self:oModel:SetValue("B3FDETAIL","B3F_DESORI",ALLTRIM(B3F->B3F_DESORI))

Return

Method ProcFluig(lAuto) Class CenFluig
    Local nI       := 0
    Local nSolicId := 0
    Local lPodeSeg := .T.
    Local lProces  := B3F->(FieldPos("B3F_NFLUIG")) > 0
    Local cNomOpe  := ""
    Default lAuto  := .F.

    self:BscRegMark(lAuto)

    If Len(Self:aRec) == 0 .And. !lAuto
        Alert("Selecione uma crítica para ser enviada para o Fluig.")
    else

        If self:VerProc()  .And. !lAuto //verifico se há registros já enviados. Caso exista pergunto se quer sobrepor
            lPodeSeg:= .f.
            MsgInfo( " Entre os registros marcados, há movimentações que já foram enviadas ao Fluig. Desmarque as movimentações e envie novamente!", "Central de Obrigações" )
        Endif

        If (self:VldProcFl() .And. lPodeSeg) .Or. lAuto

            B3F->(DBSetOrder(1))
            Self:oModel := FWLoadModel("CENMVCFLU")
            Self:oView  := FWLoadView("CENMVCFLU")

            Self:oModel:SetOperation(3)

            If Self:oModel:Activate()

                Self:oView:SetModel( Self:oModel )

                B8M->(DBSetOrder(1))

                cNomOpe:=ALLTRIM(Posicione('B8M',1,xFilial('B8M')+B3D->B3D_CODOPE,'B8M_NOMFAN'))

                If !Empty(cNomOpe)
                    Self:oModel:SetValue("B3DMASTER","B3D_DESOPE",cNomOpe)
                Endif

                Self:oModel:SetValue("B3DMASTER","B3D_CODOPE",B3D->B3D_CODOPE)
                Self:oModel:SetValue("B3DMASTER","B3D_CDOBRI",B3D->B3D_CDOBRI)
                Self:oModel:SetValue("B3DMASTER","B3D_ANO"   ,B3D->B3D_ANO)
                Self:oModel:SetValue("B3DMASTER","B3D_CODIGO",B3D->B3D_CODIGO)
                Self:oModel:SetValue("B3DMASTER","B3D_REFERE",B3D->B3D_REFERE)
                Self:oModel:SetValue("B3DMASTER","B3D_TIPOBR",B3D->B3D_TIPOBR)
                Self:oModel:SetValue("B3DMASTER","B3D_STATUS",B3D->B3D_STATUS)
                Self:oModel:SetValue("B3DMASTER","B3D_AVVCTO",B3D->B3D_AVVCTO)
                Self:oModel:SetValue("B3DMASTER","B3D_VCTO",B3D->B3D_VCTO)

                For nI:=1 To Len(Self:aRec)
                    B3F->(DbGoTo(Self:aRec[nI,1]))

                    Self:oModel:getModel("B3FDETAIL"):GoLine(nI)

                    Self:PreenB3F()
                    iF nI < Len(Self:aRec)
                        Self:oModel:getModel("B3FDETAIL"):addLine()
                    Endif
                    Self:oModel:getModel("B3FDETAIL"):GoLine(nI)
                next

                aDados   := FWViewCardData(Self:oView)

                If(nPos := ascan(aDados,{|x| Trim(x[1]) == "B3D_VCTO"}))>0
                    aDados[nPos,2]:=DTOC(B3D->B3D_VCTO)
                Endif

                aAdd(aDados,{'ecm-validate','0'})
                nSolicId := FWECMStartProcess(Self:cId,Self:nNextTask,Self:cComments,aDados,Self:aAttach,Self:cUserId,Self:aColleagueIds,Self:lComplete)

                If nSolicId <> 0 .And. lProces  .And. !lAuto
                    For nI:=1 to Len(Self:aRec)
                        B3F->(DbGoTo(Self:aRec[nI,1]))
                        RecLock( "B3F" , .F. )
                        B3F->B3F_NFLUIG	:= AllTrim(Str(nSolicId,Len(B3F->B3F_NFLUIG)))
                        MsUnLock()
                    Next
                EndIf

                B3F->(DBCloseArea())
                B8M->(DBCloseArea())

            EndIf

            If lAuto
                nSolicId:=1
            EndIf

            If  !lAuto
                iF nSolicId > 0
                    MsgInfo("Processo inicializado com sucesso!")
                else
                    MsgInfo("Não foi possível inicializar o Processo!")
                EndIf
            Endif
        Else
            If lPodeSeg
                MsgInfo("Processo CENPROCSIB não encontrado ou não Liberado.")
            EndIF
        Endif
    Endif

Return nSolicId > 0

Method VerProc() Class CenFluig
    Local lAchPrc:= .F.
    Local nI     := 0

    If Len(self:aRec)>0
        For nI:=1 to Len(Self:aRec)
            If Len(Self:aRec[nI])>1
                If !Empty(self:aRec[nI,2])
                    lAchPrc:=.T.
                EndIf
            EndIf
        Next
    Endif

Return lAchPrc

Method Destroy() Class CenFluig
    if self:oView != nil
        FreeObj(self:oView)
        self:oView:= nil
    EndIf
    if self:oModel != nil
        FreeObj(self:oModel)
        self:oModel:= nil
    EndIf
Return