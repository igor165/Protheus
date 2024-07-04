#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'

Class CenLoadModel

    Data cEntidade
    Data cColuna
    Data cValue
    Data cKey
    Data cDescription
    Data nOperation
    Data lVldData
    Data lActivate
    Data lCommitData
    Data aDadEnv

    Data oHMColumns
    Data oHMTables

    Method New() Constructor

    Method commitData()

    Method setValue(cEntidade,cColuna,cValue)
    Method getValue(cEntidade,cColuna)

    Method setOperation(nOperation)
    Method getOperation()

    Method setDescription(cDescription)
    Method getDescription()

    Method getFielter(cAlias)
    Method validData()
    Method activate()
    Method addFields()
    Method deActivate()
    Method destroy()
    Method VldData()
    Method buscar()
    Method delete()
    Method loadData()
    Method addFielEnv()
    Method setDadEnv(aDadEnv)
    Method getFielEnv(lExiste,lDatAlt,lNotifyAns)

EndClass

Method New() Class CenLoadModel
    self:oHMColumns := THashMap():New()
    self:oHMTables  := THashMap():New()
    Default self:lCommitData := .F.
    self:aDadEnv := {}
Return self

Method setDadEnv(aDadEnv) Class CenLoadModel
    self:aDadEnv := aDadEnv
Return

Method setValue(cEntidade,cColuna,cValue) Class CenLoadModel
    self:oHMTables:set(cEntidade,cEntidade)
    self:cKey := Alltrim(cColuna)
    self:cKey := UPPER(self:cKey)
Return self:oHMColumns:set(self:cKey,cValue)

Method getValue(cEntidade,cColuna) Class CenLoadModel
    self:cKey := Alltrim(cColuna)
    self:cKey := UPPER(self:cKey)
    if !self:oHMColumns:get(self:cKey,self:cValue)
        self:cValue := Nil
    EndIf
Return self:cValue

Method setOperation(nOperation) Class CenLoadModel
    If nOperation != MODEL_OPERATION_INSERT
        self:setValue('B3KMASTER','B3K_FILIAL',B3K->B3K_FILIAL)
        self:setValue('B3KMASTER','B3K_CODOPE',B3K->B3K_CODOPE)
        self:setValue('B3KMASTER','B3K_CODCCO',B3K->B3K_CODCCO)
        self:setValue('B3KMASTER','B3K_MATRIC',B3K->B3K_MATRIC)
        self:setValue('B3KMASTER','B3K_DATNAS',B3K->B3K_DATNAS)
        self:setValue('B3KMASTER','B3K_DATINC',B3K->B3K_DATINC)
        self:setValue('B3KMASTER','B3K_UF',B3K->B3K_UF)
        self:setValue('B3KMASTER','B3K_CODPRO',B3K->B3K_CODPRO)
        self:setValue('B3KMASTER','B3K_ATUCAR',B3K->B3K_ATUCAR)
        self:setValue('B3KMASTER','B3K_STATUS',B3K->B3K_STATUS)
        self:setValue('B3KMASTER','B3K_STASIB',B3K->B3K_STASIB)
        self:setValue('B3KMASTER','B3K_STAESP',B3K->B3K_STAESP)
        self:setValue('B3KMASTER','B3K_SEXO',B3K->B3K_SEXO)
        self:setValue('B3KMASTER','B3K_NOMBEN',B3K->B3K_NOMBEN)
        self:setValue('B3KMASTER','B3K_MATANT',B3K->B3K_MATANT)
        self:setValue('B3KMASTER','B3K_PISPAS',B3K->B3K_PISPAS)
        self:setValue('B3KMASTER','B3K_NOMMAE',B3K->B3K_NOMMAE)
        self:setValue('B3KMASTER','B3K_DN',B3K->B3K_DN)
        self:setValue('B3KMASTER','B3K_CNS',B3K->B3K_CNS)
        self:setValue('B3KMASTER','B3K_ENDERE',B3K->B3K_ENDERE)
        self:setValue('B3KMASTER','B3K_NR_END',B3K->B3K_NR_END)
        self:setValue('B3KMASTER','B3K_COMEND',B3K->B3K_COMEND)
        self:setValue('B3KMASTER','B3K_BAIRRO',B3K->B3K_BAIRRO)
        self:setValue('B3KMASTER','B3K_CODMUN',B3K->B3K_CODMUN)
        self:setValue('B3KMASTER','B3K_MUNICI',B3K->B3K_MUNICI)
        self:setValue('B3KMASTER','B3K_CEPUSR',B3K->B3K_CEPUSR)
        self:setValue('B3KMASTER','B3K_TIPEND',B3K->B3K_TIPEND)
        self:setValue('B3KMASTER','B3K_RESEXT',B3K->B3K_RESEXT)
        self:setValue('B3KMASTER','B3K_TIPDEP',B3K->B3K_TIPDEP)
        self:setValue('B3KMASTER','B3K_CODTIT',B3K->B3K_CODTIT)
        self:setValue('B3KMASTER','B3K_SUSEP',B3K->B3K_SUSEP)
        self:setValue('B3KMASTER','B3K_SCPA',B3K->B3K_SCPA)
        self:setValue('B3KMASTER','B3K_PLAORI',B3K->B3K_PLAORI)
        self:setValue('B3KMASTER','B3K_COBPAR',B3K->B3K_COBPAR)
        self:setValue('B3KMASTER','B3K_ITEEXC',B3K->B3K_ITEEXC)
        self:setValue('B3KMASTER','B3K_CNPJCO',B3K->B3K_CNPJCO)
        self:setValue('B3KMASTER','B3K_CEICON',B3K->B3K_CEICON)
        self:setValue('B3KMASTER','B3K_TRAORI',B3K->B3K_TRAORI)
        self:setValue('B3KMASTER','B3K_TRADES',B3K->B3K_TRADES)
        self:setValue('B3KMASTER','B3K_CPF',B3K->B3K_CPF)
        self:setValue('B3KMASTER','B3K_CPFMAE',B3K->B3K_CPFMAE)
        self:setValue('B3KMASTER','B3K_CPFPRE',B3K->B3K_CPFPRE)
        self:setValue('B3KMASTER','B3K_SITANS',B3K->B3K_SITANS)
        self:setValue('B3KMASTER','B3K_MOTBLO',B3K->B3K_MOTBLO)
        self:setValue('B3KMASTER','B3K_DATBLO',B3K->B3K_DATBLO)
        If B3K->(FieldPos("B3K_CRINOM")) > 0
            self:setValue('B3KMASTER','B3K_CRINOM',B3K->B3K_CRINOM)
        EndIf
        If B3K->(FieldPos("B3K_CRIMAE")) > 0
            self:setValue('B3KMASTER','B3K_CRIMAE',B3K->B3K_CRIMAE)
        EndIf
        If B3K->(FieldPos("B3K_CAEPF")) > 0
            self:setValue('B3KMASTER','B3K_CAEPF',B3K->B3K_CAEPF)
        EndIf
        If B3K->(FieldPos("B3K_NOMECO")) > 0
            self:setValue('B3KMASTER','B3K_NOMECO',B3K->B3K_NOMECO)
        EndIf
        self:setValue('B3KMASTER','B3K_DATREA',B3K->B3K_DATREA)
        self:setValue('B3KMASTER','B3K_SITANS',B3K->B3K_SITANS)
    EndIf
    self:nOperation := nOperation
Return

Method getOperation() Class CenLoadModel
Return self:nOperation

Method setDescription(cDescription) Class CenLoadModel
    self:cDescription := cDescription
Return .T.

Method getDescription(cDescription) Class CenLoadModel
Return self:cDescription

Method destroy() Class CenLoadModel

    If self:oHMColumns <> Nil
        FreeObj(self:oHMColumns)
        self:oHMColumns := Nil
    EndIf
    If self:oHMTables <> Nil
        FreeObj(self:oHMTables)
        self:oHMTables := Nil
    EndIf

    self:aDadEnv := Nil

    DelClassIntf()

Return .T.

Method VldData() Class CenLoadModel
Return .T.

Method validData() Class CenLoadModel
Return .T.

Method activate() Class CenLoadModel
    self:lActivate := .T.
Return self:lActivate

Method addFields() Class CenLoadModel
Return .T.

Method deActivate() Class CenLoadModel
Return .T.

Method getFielEnv(lExiste,lDatAlt,lNotifyAns) Class CenLoadModel

    Local aRetDatAlt := {}
    /*/
        Se a tag notifyANS é .T. e é uma alteração, e nenhum campo foi alterado
        Seleciona os campos que foram enviados para gerar uma Retificação
    /*/
    If lNotifyAns .and. lExiste .and. !lDatAlt
        aRetDatAlt := self:aDadEnv
    EndIf

Return aRetDatAlt

Method commitData(lNotifyAns,lChange) Class CenLoadModel

    Local lSuccess := .F.
    Local lExiste := Nil
    Local cAlias := "B3K"
    Local nOpe := self:getOperation()
    Local cCampos    := ""
    Local aDadosAlt  := {}
    Local lDatAlt    := .F.

    Default lNotifyAns := .T.
    Default lChange    := .F.

    if !self:lCommitData

        If nOpe == MODEL_OPERATION_UPDATE .OR. nOpe == MODEL_OPERATION_INSERT

            lExiste := (nOpe == MODEL_OPERATION_UPDATE)

            /*/
                Para retornar campos alterados e gerar retificação, o fato de utilizar a mesma função para validar,
                gravar e gerar movimentação infere na nessessidade de, ter os campos que serão aletrados em caso de retificação ntes de salvar
            /*/
            if lExiste
                lDatAlt := RetDadosAlt(self,aDadosAlt,@cCampos)
            EndIf

            B3K->(RecLock("B3K",!lExiste))

            If self:getValue('','B3K_FILIAL' ) != nil
                B3K->B3K_FILIAL := self:getValue('','B3K_FILIAL' )
            EndIf
            If self:getValue('','B3K_CODOPE' ) != nil
                B3K->B3K_CODOPE := self:getValue('','B3K_CODOPE' )
            EndIf
            If self:getValue('','B3K_CODCCO' ) != nil
                B3K->B3K_CODCCO := self:getValue('','B3K_CODCCO' )
            EndIf
            If self:getValue('','B3K_MATRIC' ) != nil
                B3K->B3K_MATRIC := self:getValue('','B3K_MATRIC' )
            EndIf
            If self:getValue('','B3K_DATNAS' ) != nil
                B3K->B3K_DATNAS := self:getValue('','B3K_DATNAS' )
            EndIf
            If self:getValue('','B3K_DATINC' ) != nil
                B3K->B3K_DATINC := self:getValue('','B3K_DATINC' )
            EndIf
            If self:getValue('','B3K_UF' ) != nil
                B3K->B3K_UF := self:getValue('','B3K_UF' )
            EndIf
            If self:getValue('','B3K_CODPRO' ) != nil
                B3K->B3K_CODPRO := self:getValue('','B3K_CODPRO' )
            EndIf
            If self:getValue('','B3K_ATUCAR' ) != nil
                B3K->B3K_ATUCAR := self:getValue('','B3K_ATUCAR' )
            EndIf
            If self:getValue('','B3K_STATUS' ) != nil
                B3K->B3K_STATUS := self:getValue('','B3K_STATUS' )
            EndIf
            If self:getValue('','B3K_STASIB' ) != nil
                B3K->B3K_STASIB := self:getValue('','B3K_STASIB' )
            EndIf
            If self:getValue('','B3K_STAESP' ) != nil
                B3K->B3K_STAESP := self:getValue('','B3K_STAESP' )
            EndIf
            If self:getValue('','B3K_SEXO' ) != nil
                B3K->B3K_SEXO := self:getValue('','B3K_SEXO' )
            EndIf
            If self:getValue('','B3K_NOMBEN' ) != nil
                B3K->B3K_NOMBEN := self:getValue('','B3K_NOMBEN' )
            EndIf
            If self:getValue('','B3K_MATANT' ) != nil
                B3K->B3K_MATANT := self:getValue('','B3K_MATANT' )
            EndIf
            If self:getValue('','B3K_PISPAS' ) != nil
                B3K->B3K_PISPAS := self:getValue('','B3K_PISPAS' )
            EndIf
            If self:getValue('','B3K_NOMMAE' ) != nil
                B3K->B3K_NOMMAE := self:getValue('','B3K_NOMMAE' )
            EndIf
            If self:getValue('','B3K_DN' ) != nil
                B3K->B3K_DN := self:getValue('','B3K_DN' )
            EndIf
            If self:getValue('','B3K_CNS' ) != nil
                B3K->B3K_CNS := self:getValue('','B3K_CNS' )
            EndIf
            If self:getValue('','B3K_ENDERE' ) != nil
                B3K->B3K_ENDERE := self:getValue('','B3K_ENDERE' )
            EndIf
            If self:getValue('','B3K_NR_END' ) != nil
                B3K->B3K_NR_END := self:getValue('','B3K_NR_END' )
            EndIf
            If self:getValue('','B3K_COMEND' ) != nil
                B3K->B3K_COMEND := self:getValue('','B3K_COMEND' )
            EndIf
            If self:getValue('','B3K_BAIRRO' ) != nil
                B3K->B3K_BAIRRO := self:getValue('','B3K_BAIRRO' )
            EndIf
            If self:getValue('','B3K_CODMUN' ) != nil
                B3K->B3K_CODMUN := self:getValue('','B3K_CODMUN' )
            EndIf
            If self:getValue('','B3K_MUNICI' ) != nil
                B3K->B3K_MUNICI := self:getValue('','B3K_MUNICI' )
            EndIf
            If self:getValue('','B3K_CEPUSR' ) != nil
                B3K->B3K_CEPUSR := self:getValue('','B3K_CEPUSR' )
            EndIf
            If self:getValue('','B3K_TIPEND' ) != nil
                B3K->B3K_TIPEND := self:getValue('','B3K_TIPEND' )
            EndIf
            If self:getValue('','B3K_RESEXT' ) != nil
                B3K->B3K_RESEXT := self:getValue('','B3K_RESEXT' )
            EndIf
            If self:getValue('','B3K_TIPDEP' ) != nil
                B3K->B3K_TIPDEP := self:getValue('','B3K_TIPDEP' )
            EndIf
            If self:getValue('','B3K_CODTIT' ) != nil
                B3K->B3K_CODTIT := self:getValue('','B3K_CODTIT' )
            EndIf
            If self:getValue('','B3K_SUSEP' ) != nil
                B3K->B3K_SUSEP := self:getValue('','B3K_SUSEP' )
            EndIf
            If self:getValue('','B3K_SCPA' ) != nil
                B3K->B3K_SCPA := self:getValue('','B3K_SCPA' )
            EndIf
            If self:getValue('','B3K_PLAORI' ) != nil
                B3K->B3K_PLAORI := self:getValue('','B3K_PLAORI' )
            EndIf
            If self:getValue('','B3K_COBPAR' ) != nil
                B3K->B3K_COBPAR := self:getValue('','B3K_COBPAR' )
            EndIf
            If self:getValue('','B3K_ITEEXC' ) != nil
                B3K->B3K_ITEEXC := self:getValue('','B3K_ITEEXC' )
            EndIf
            If self:getValue('','B3K_CNPJCO' ) != nil
                B3K->B3K_CNPJCO := self:getValue('','B3K_CNPJCO' )
            EndIf
            If self:getValue('','B3K_CEICON' ) != nil
                B3K->B3K_CEICON := self:getValue('','B3K_CEICON' )
            EndIf
            If self:getValue('','B3K_TRAORI' ) != nil
                B3K->B3K_TRAORI := self:getValue('','B3K_TRAORI' )
            EndIf
            If self:getValue('','B3K_TRADES' ) != nil
                B3K->B3K_TRADES := self:getValue('','B3K_TRADES' )
            EndIf
            If self:getValue('','B3K_CPF' ) != nil
                B3K->B3K_CPF := self:getValue('','B3K_CPF' )
            EndIf
            If self:getValue('','B3K_CPFMAE' ) != nil
                B3K->B3K_CPFMAE := self:getValue('','B3K_CPFMAE' )
            EndIf
            If self:getValue('','B3K_CPFPRE' ) != nil
                B3K->B3K_CPFPRE := self:getValue('','B3K_CPFPRE' )
            EndIf
            If self:getValue('','B3K_SITANS' ) != nil
                B3K->B3K_SITANS := self:getValue('','B3K_SITANS' )
            EndIf
            If self:getValue('','B3K_MOTBLO' ) != nil
                B3K->B3K_MOTBLO := self:getValue('','B3K_MOTBLO' )
            EndIf
            If self:getValue('','B3K_DATBLO' ) != nil
                B3K->B3K_DATBLO := self:getValue('','B3K_DATBLO' )
            EndIf

            If B3K->(FieldPos("B3K_CRINOM")) > 0
                If self:getValue('','B3K_CRINOM' ) != nil
                    B3K->B3K_CRINOM := self:getValue('','B3K_CRINOM' )
                EndIf
            EndIf
            If B3K->(FieldPos("B3K_CRIMAE")) > 0
                If self:getValue('','B3K_CRIMAE' ) != nil
                    B3K->B3K_CRIMAE := self:getValue('','B3K_CRIMAE' )
                EndIf
            EndIf
            If B3K->(FieldPos("B3K_CAEPF")) > 0
                If self:getValue('','B3K_CAEPF' ) != nil
                    B3K->B3K_CAEPF := self:getValue('','B3K_CAEPF' )
                EndIf
            EndIf
            If B3K->(FieldPos("B3K_NOMECO")) > 0
                If self:getValue('','B3K_NOMECO' ) != nil
                    B3K->B3K_NOMECO := self:getValue('','B3K_NOMECO' )
                EndIf
            EndIf
            If self:getValue('','B3K_DATREA' ) != nil
                B3K->B3K_DATREA := self:getValue('','B3K_DATREA' )
            EndIf
            If self:getValue('','B3K_SITANS' ) != nil
                B3K->B3K_SITANS := self:getValue('','B3K_SITANS' )
            EndIf

            If self:getValue('','B3K_OPESIB' ) != nil
                B3K->B3K_OPESIB := self:getValue('','B3K_OPESIB' )
            EndIf

            lSuccess := .T.

            B3K->(msUnlock())

        Else
            lSuccess := self:delete()
        EndIf

        self:lCommitData := .T.

        PLCenGrvBen(self,,,lNotifyAns,,,,,,,,,aDadosAlt,lDatAlt, self:getFielEnv(lExiste,lDatAlt,lNotifyAns),lChange)

    Else
        lSuccess := .T.
    EndIf

    aDadosAlt := nil

Return lSuccess

Method delete() Class CenLoadModel

    Local lSuccess := .F.
    Local cSql := ''
    Local cAlias := "B3K"

    If self:buscar(cAlias)
        cSql += " DELETE FROM " + RetSqlName(cAlias)
        cSql += " WHERE 1=1 "
        cSql += self:getFielter(cAlias)

        lSuccess := TcSqlExec(cSql) >= 0
        If lSuccess .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
            lSuccess := TCSQLEXEC("COMMIT") >= 0
        Endif
    EndIf

Return lSuccess

Method buscar(cAlias) Class CenLoadModel

    Local lFound := .F.
    Local cSql := ''
    Default cAlias := "B3K"

    cSql += " SELECT * FROM " + RetSqlName(cAlias)
    cSql += " WHERE 1=1 "
    cSql += self:getFielter(cAlias)

    If Select("TRBMODEL") > 0
        dbSelectArea("TRBMODEL")
        TRBMODEL->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRBMODEL",.T.,.F.)
    lFound := TRBMODEL->(!Eof())

    If lFound
        B3K->(DbGoto(TRBMODEL->R_E_C_N_O_))
    EndIf

Return lFound

Method getFielter(cAlias) Class CenLoadModel
    Local cSql := ''
    Default cAlias := "B3K"

    If cAlias == "B3K"
        cSql += " AND B3K_FILIAL = '" + xFilial("B3K")  + "'"
        cSql += " AND B3K_CODOPE = '" + self:getValue('','B3K_CODOPE') + "' "
        cSql += " AND B3K_MATRIC = '" + self:getValue('','B3K_MATRIC') + "' "
        cSql += " AND B3K_CODCCO = '" + self:getValue('','B3K_CODCCO') + "' "
        cSql += " AND D_E_L_E_T_ = ' ' "
    EndIf

Return cSql
