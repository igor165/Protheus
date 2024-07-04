#INCLUDE "TOTVS.CH"

#DEFINE SIB_INCLUIR  "1" // Incluir
#DEFINE SIB_RETIFIC  "2" // Retificar
#DEFINE SIB_MUDCONT  "3" // Mud.Contrat
#DEFINE SIB_CANCELA  "4" // Cancelar
#DEFINE SIB_REATIVA  "5" // Reativar

#DEFINE SINGLE  "01"
#DEFINE ALL     "02"
#DEFINE INSERT  "03"
#DEFINE DELETE  "04"
#DEFINE UPDATE  "05"
#DEFINE LOTE    "06"

#DEFINE SQLSERVER  "MSSQL"
#DEFINE ORACLE "ORACLE"
#DEFINE POSTGRES "POSTGRES"

Class DaoCenBenefi from Dao

    Data cMatric
    Data cCodOpe
    Data cCodCco
    Data cNomben
    Data cSexo
    Data dDatnas
    Data cCodpro
    Data cMatant
    Data cPispas
    Data cNommae
    Data cCns
    Data cEndere
    Data cNr_end
    Data cComend
    Data cBairro
    Data cCodmun
    Data cMunici
    Data cCepusr
    Data cResext
    Data cTipdep
    Data cCodtit
    Data cSusep
    Data cScpa
    Data cCobpar
    Data cCnpjco
    Data cCeicon
    Data cCpf
    Data cCpfmae
    Data cCpfpre
    Data cCriMae
    Data cCriNom
    Data cCaepf
    Data cNomeCO

    Data oModel
    Data aMapBuilder
    //Data oStatement
    Data aDadEnv

    Method New() Constructor
    Method setMatric(cMatric)
    Method setCodOpe(cCodOpe)
    Method setCodCco(cCodCco)
    Method setNomben(cNomben)
    Method setSexo(cSexo)
    Method setDatnas(dDatnas)
    Method setCodpro(cCodpro)
    Method setMatant(cMatant)
    Method setPispas(cPispas)
    Method setNommae(cNommae)
    Method setCns(cCns)
    Method setEndere(cEndere)
    Method setNr_end(cNr_end)
    Method setComend(cComend)
    Method setBairro(cBairro)
    Method setCodmun(cCodmun)
    Method setMunici(cMunici)
    Method setCepusr(cCepusr)
    Method setResext(cResext)
    Method setTipdep(cTipdep)
    Method setCodtit(cCodtit)
    Method setSusep(cSusep)
    Method setScpa(cScpa)
    Method setCobpar(cCobpar)
    Method setCnpjco(cCnpjco)
    Method setCeicon(cCeicon)
    Method setCpf(cCpf)
    Method setCpfmae(cCpfmae)
    Method setCpfpre(cCpfpre)
    Method setCriMae(cCriMae)
    Method setCriNom(cCriNom)
    Method setCAEPF(cCaepf)
    Method setNomeCO(cNomeCO)
    Method getFilters()
    Method getFields()
    Method loadOrder()
    Method buscar(nType, lLote)
    Method BscAtuEmp()
    Method getCustWere(cAlias)
    Method commit(oCenBenefi, oRespBody, nType)
    Method commitCancel(oCenBenefi, oRespBody)
    Method commitReact(oCenBenefi, oRespBody)
    Method commitChangContrac(oCenBenefi, oRespBody)
    Method setDadEnv(aDadEnv)
    Method destroy()

EndClass

Method New() Class DaoCenBenefi
    _Super:New()
    self:loadOrder()
    self:aMapBuilder := {}
    self:aDadEnv := {}
    //self:oStatement :=  FWPreparedStatement():New()
Return self

Method destroy() Class DaoCenBenefi
    _Super:destroy()
    if self:oModel != nil
        FreeObj(self:oModel)
        self:oModel := nil
    endif
    self:aMapBuilder := nil
    self:aDadEnv := nil
Return

Method setDadEnv(aDadEnv) Class DaoCenBenefi
    self:aDadEnv := aDadEnv
Return

Method getFields() Class DaoCenBenefi


    If empty(self:cFields)

        self:cFields := "  B3K_CODOPE, B3K_CODCCO,  B3K_MATRIC,   B3K_NOMBEN,   B3K_SEXO,   "
        self:cFields += "  B3K_DATNAS, B3K_DATINC,  B3K_DATBLO,   B3K_UF,       B3K_CODPRO, "
        self:cFields += "  B3K_MATANT, B3K_DATREA,  B3K_PISPAS,   B3K_NOMMAE,   B3K_DN, B3K_CNS, "
        self:cFields += "  B3K_ENDERE, B3K_NR_END,  B3K_COMEND,   B3K_BAIRRO,   B3K_CODMUN, "
        self:cFields += "  B3K_MUNICI, B3K_CEPUSR,  B3K_TIPEND,   B3K_RESEXT,   B3K_TIPDEP, "
        self:cFields += "  B3K_CODTIT, B3K_SUSEP,   B3K_SCPA,     B3K_COBPAR,   B3K_CNPJCO, "
        self:cFields += "  B3K_CEICON, B3K_CPF,     B3K_CPFMAE,   B3K_CPFPRE,   B3K_ITEEXC, "
        self:cFields += "  B3K_OPESIB, B3K_MOTBLO,  B3K_SITANS,   B3K_PLAORI,   "

        If B3K->(FieldPos("B3K_CRINOM")) > 0
            self:cFields += " B3K_CRINOM, "
        EndIf

        If B3K->(FieldPos("B3K_CRIMAE")) > 0
            self:cFields += " B3K_CRIMAE, "
        EndIf

        If B3K->(FieldPos("B3K_CAEPF")) > 0
            self:cFields += " B3K_CAEPF, "
        EndIf

        If B3K->(FieldPos("B3K_NOMECO")) > 0
            self:cFields += " B3K_NOMECO, "
        EndIf

        self:cFields += " B3K.R_E_C_N_O_ RECNO "
    Endif

Return self:cFields

Method buscar(nType, lLote) Class DaoCenBenefi

    Local cQuery := ""
    Local lFound := .F.
    Local cAlias := "B3K"
    Default self:cfieldOrder := " B3K_CODOPE, B3K_CODCCO,  B3K_MATRIC "

    cQuery += self:getRowControl(self:cfieldOrder, cAlias)
    cQuery += self:getFields()
    cQuery += " FROM " + RetSqlName("B3K") + " B3K WHERE "
    cQuery += " B3K_FILIAL = '" + xFilial("B3K") + "' AND "
    cQuery += " B3K_CODOPE =  ? "
    aAdd(self:aMapBuilder, self:cCodOpe)

    cQuery += "AND B3K.D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    cQuery += self:getFilters()
    cQuery += self:getWhereRow(cAlias)
    cQuery := self:queryBuilder(cQuery)

    self:setQuery(cQuery)
    lFound := self:executaQuery()

    If lFound  /* .AND. (nType != ALL .OR. nType != INSERT)*/
        B3K->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

Return lFound

Method commit(oCenBenefi, oRest, nType) Class DaoCenBenefi

    Local lRet       := .T.
    Local lExiste    := nil
    Local nOperation := nil

    If nType == LOTE
        lExiste := oRest:buscar(nType, .T.)
    Else
        lExiste := oRest:buscar(nType)
    EndIf

    lRet := oRest:lSuccess
    nOperation := self:getTypeOpe(lExiste, nType)

    self:oModel	:= CenLoadModel():New()

    If oRest:lSuccess

        self:oModel:SetOperation(nOperation)
        self:oModel:Activate()

        If nType == INSERT .OR. nType == LOTE
            self:oModel:SetValue( "B3KMASTER", 'B3K_CODOPE', oCenBenefi:getCodOpe())
        EndIf

        If nType != DELETE

            If nType == UPDATE
                self:oModel:setDadEnv(self:aDadEnv)
            EndIf

            self:oModel:SetValue( "B3KMASTER", 'B3K_FILIAL', xFilial("B3K"))
            self:oModel:SetValue( "B3KMASTER", 'B3K_STASIB', '1')

            If oCenBenefi:getCodCco() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_CODCCO', oCenBenefi:getCodCco())
            EndIf

            If oCenBenefi:getMatric() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_MATRIC', oCenBenefi:getMatric())
            EndIf

            if oCenBenefi:getNomBen() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_NOMBEN', oCenBenefi:getNomBen())
            EndIf

            if oCenBenefi:getSexo() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_SEXO', oCenBenefi:getSexo())
            EndIf

            if oCenBenefi:getDatNas() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_DATNAS', oCenBenefi:getDatNas())
            EndIf

            if oCenBenefi:getDatInc() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_DATINC', oCenBenefi:getDatInc())
            EndIf

            if oCenBenefi:getDatBlo() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_DATBLO', oCenBenefi:getDatBlo())
            ElseIf nType != UPDATE
                self:oModel:SetValue( "B3KMASTER", 'B3K_DATBLO', STOD(""))
            EndIf

            if oCenBenefi:getUf() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_UF', oCenBenefi:getUf())
            EndIf

            if oCenBenefi:getCodPro() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_CODPRO', oCenBenefi:getCodPro())
            EndIf

            if oCenBenefi:getMatAnt() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_MATANT', oCenBenefi:getMatAnt())
            EndIf

            if oCenBenefi:getDatRea() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_DATREA', oCenBenefi:getDatRea())
            Else
                self:oModel:SetValue( "B3KMASTER", 'B3K_DATREA', STOD(""))
            EndIf

            if oCenBenefi:getPisPas() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_PISPAS', oCenBenefi:getPisPas())
            EndIf

            if oCenBenefi:getNomMae() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_NOMMAE', oCenBenefi:getNomMae())
            EndIf

            if oCenBenefi:getDn() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_DN', oCenBenefi:getDn())
            EndIf

            if oCenBenefi:getCns() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_CNS', oCenBenefi:getCns())
            EndIf

            if oCenBenefi:getEndere() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_ENDERE', oCenBenefi:getEndere())
            EndIf

            if oCenBenefi:getNr_end() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_NR_END', oCenBenefi:getNr_end())
            EndIf

            if oCenBenefi:getComEnd() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_COMEND', oCenBenefi:getComEnd())
            EndIf

            if oCenBenefi:getBairro() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_BAIRRO', oCenBenefi:getBairro())
            EndIf

            if oCenBenefi:getCodMun() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_CODMUN', oCenBenefi:getCodMun())
            EndIf

            if oCenBenefi:getMunIci() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_MUNICI', oCenBenefi:getMunIci())
            EndIf

            if oCenBenefi:getCepUsr() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_CEPUSR', oCenBenefi:getCepUsr())
            EndIf

            if oCenBenefi:getTipEnd() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_TIPEND', oCenBenefi:getTipEnd())
            EndIf

            if oCenBenefi:getResExt() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_RESEXT', oCenBenefi:getResExt())
            EndIf

            if oCenBenefi:getTipDep() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_TIPDEP', oCenBenefi:getTipDep())
            EndIf

            if oCenBenefi:getCodTit() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_CODTIT', oCenBenefi:getCodTit())
            EndIf

            if oCenBenefi:getSusep() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_SUSEP' , oCenBenefi:getSusep())
            EndIf

            if oCenBenefi:getScpa() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_SCPA', oCenBenefi:getScpa())
            EndIf

            if oCenBenefi:getCobPar() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_COBPAR', oCenBenefi:getCobPar())
            EndIf

            if oCenBenefi:getCnpJco() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_CNPJCO', oCenBenefi:getCnpJco())
            EndIf

            if oCenBenefi:getCeiCon() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_CEICON', oCenBenefi:getCeiCon())
            EndIf

            if oCenBenefi:getCpf() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_CPF', oCenBenefi:getCpf())
            EndIf

            if oCenBenefi:getCpfMae() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_CPFMAE', oCenBenefi:getCpfMae())
            EndIf

            if oCenBenefi:getCpfPre() != nil
                self:oModel:SetValue( "B3KMASTER", 'B3K_CPFPRE', oCenBenefi:getCpfPre())
            EndIf

            if oCenBenefi:getIteExc() != nil
                self:oModel:setValue( "B3KMASTER", 'B3K_ITEEXC', oCenBenefi:getIteExc())
            EndIf

            if oCenBenefi:getOpeSib() != nil
                self:oModel:setValue( "B3KMASTER", 'B3K_OPESIB', oCenBenefi:getOpeSib())
            EndIf

            if oCenBenefi:getSitAns() != nil
                self:oModel:setValue( "B3KMASTER", 'B3K_SITANS', oCenBenefi:getSitAns())
            EndIf

            if oCenBenefi:getCriNom() != nil
                If B3K->(FieldPos("B3K_CRINOM")) > 0
                    self:oModel:setValue( "B3KMASTER", 'B3K_CRINOM', oCenBenefi:getCriNom())
                EndIf
            EndIf

            if oCenBenefi:getCriMae() != nil
                If B3K->(FieldPos("B3K_CRINOM")) > 0
                    self:oModel:setValue( "B3KMASTER", 'B3K_CRIMAE', oCenBenefi:getCriMae())
                EndIf
            EndIf

            if oCenBenefi:getCaepf() != nil
                If B3K->(FieldPos("B3K_CAEPF")) > 0
                    self:oModel:setValue( "B3KMASTER", 'B3K_CAEPF', oCenBenefi:getCaepf())
                EndIf
            EndIf

            if oCenBenefi:getMotBlo() != nil
                self:oModel:setValue( "B3KMASTER", 'B3K_MOTBLO', oCenBenefi:getMotBlo())
            EndIf

            If oCenBenefi:getPlaOri() != nil
                self:oModel:setValue("B3KMASTER", "B3K_PLAORI", oCenBenefi:getPlaOri())
            EndIf

            If oCenBenefi:getNomeCO() != nil
                self:oModel:setValue("B3KMASTER", "B3K_NOMECO", oCenBenefi:getNomeCO())
            EndIf

        EndIf

        self:oModel:commitData(oCenBenefi:getNotifyANS(),oCenBenefi:getChange())

    EndIf

    If nType == LOTE
        self:fechaQuery()
    EndIf

    self:oModel:Destroy()
    FreeObj(self:oModel)
    self:oModel := Nil

Return lRet

Method commitCancel(oCenBenefi, oRest)  Class DaoCenBenefi

    Local lRet := .T.
    Local nOperation := nil
    Local lNotifyANS := .T.

    self:oModel	:= CenLoadModel():New()

    lExiste := oRest:buscar(UPDATE)
    nOperation := self:getTypeOpe(lExiste, UPDATE)
    lRet := oRest:lSuccess

    If oRest:lSuccess

        self:oModel:SetOperation(nOperation)
        self:oModel:Activate()

        if oCenBenefi:getDatBlo() != nil
            self:oModel:setValue( "B3KMASTER", 'B3K_DATBLO', oCenBenefi:getDatBlo())
        EndIf

        if oCenBenefi:getMotBlo() != nil
            self:oModel:setValue( "B3KMASTER", 'B3K_MOTBLO', oCenBenefi:getMotBlo())
        EndIf

        self:oModel:setValue( "B3KMASTER", 'B3K_SITANS', 'I')

        self:oModel:setValue( "B3KMASTER", 'B3K_OPESIB', SIB_CANCELA)
        self:oModel:commitData(lNotifyANS)

    EndIf

    self:oModel:Destroy()
    FreeObj(self:oModel)
    self:oModel := Nil

Return lRet

Method commitReact(oCenBenefi, oRest)  Class DaoCenBenefi

    Local lRet := .T.
    Local nOperation := nil
    Local lNotifyANS := .T.

    self:oModel	:= CenLoadModel():New()

    lExiste := oRest:buscar(UPDATE)
    nOperation := self:getTypeOpe(lExiste, UPDATE)
    lRet := oRest:lSuccess

    If oRest:lSuccess

        self:oModel:SetOperation(nOperation)
        self:oModel:Activate()

        if oCenBenefi:getDatRea() != nil
            self:oModel:setValue( "B3KMASTER", 'B3K_DATREA', oCenBenefi:getDatRea())
        EndIf

        self:oModel:SetValue( "B3KMASTER", 'B3K_DATBLO', STOD(""))

        self:oModel:setValue( "B3KMASTER", 'B3K_SITANS', 'A')

        self:oModel:setValue( "B3KMASTER", 'B3K_OPESIB', SIB_REATIVA)
        self:oModel:commitData(lNotifyANS)

    EndIf

    self:oModel:Destroy()
    FreeObj(self:oModel)
    self:oModel := Nil

Return lRet

Method commitChangContrac(oCenBenefi, oRest) Class DaoCenBenefi

    Local lRet := .T.
    Local nOperation := nil
    Local lNotifyANS := .T.

    self:oModel	:= CenLoadModel():New()

    nOperation := self:getTypeOpe(.T., UPDATE)
    lRet := oRest:lSuccess

    If oRest:lSuccess

        self:oModel:SetOperation(nOperation)
        self:oModel:Activate()

        If oCenBenefi:getPlaOri() != nil
            self:oModel:setValue("B3KMASTER", "B3K_PLAORI", oCenBenefi:getPlaOri())
        EndIf

        If oCenBenefi:getCnpJco() != nil
            self:oModel:setValue("B3KMASTER", "B3K_CNPJCO", oCenBenefi:getCnpJco())
        EndIf

        If oCenBenefi:getIteExc() != nil
            self:oModel:setValue("B3KMASTER", "B3K_ITEEXC", oCenBenefi:getIteExc())
        EndIf

        If oCenBenefi:getCobPar() != nil
            self:oModel:setValue("B3KMASTER", "B3K_COBPAR", oCenBenefi:getCobPar())
        EndIf

        If oCenBenefi:getTipDep() != nil
            self:oModel:setValue("B3KMASTER", "B3K_TIPDEP", oCenBenefi:getTipDep())
        EndIf

        If oCenBenefi:getCodTit() != nil
            self:oModel:setValue("B3KMASTER", "B3K_CODTIT", oCenBenefi:getCodTit())
        EndIf

        If oCenBenefi:getCodPro() != nil
            self:oModel:setValue("B3KMASTER", "B3K_CODPRO", oCenBenefi:getCodPro())
        EndIf

        If oCenBenefi:getDatInc() != nil
            self:oModel:setValue("B3KMASTER", "B3K_DATINC", oCenBenefi:getDatInc())
        EndIf

        If oCenBenefi:getProAns() != nil
            self:oModel:setValue("B3KMASTER", "B3K_PROANS", oCenBenefi:getProAns())
        EndIf

        if oCenBenefi:getCnpJco() != nil
            self:oModel:SetValue( "B3KMASTER", 'B3K_CNPJCO', oCenBenefi:getCnpJco())
        EndIf

        if oCenBenefi:getCeiCon() != nil
            self:oModel:SetValue( "B3KMASTER", 'B3K_CEICON', oCenBenefi:getCeiCon())
        EndIf

        if oCenBenefi:getScpa() != nil
            self:oModel:SetValue( "B3KMASTER", 'B3K_SCPA', oCenBenefi:getScpa())
        EndIf

        if oCenBenefi:getSusep() != nil
            self:oModel:SetValue( "B3KMASTER", 'B3K_SUSEP', oCenBenefi:getSusep())
        EndIf

        if oCenBenefi:getCriMae() != nil
            If B3K->(FieldPos("B3K_CRIMAE")) > 0
                self:oModel:SetValue( "B3KMASTER", 'B3K_CRIMAE', oCenBenefi:getCriMae())
            EndIf
        EndIf

        if oCenBenefi:getCriNom() != nil
            If B3K->(FieldPos("B3K_CRINOM")) > 0
                self:oModel:SetValue( "B3KMASTER", 'B3K_CRINOM', oCenBenefi:getCriNom())
            EndIf
        EndIf

        if oCenBenefi:getCaepf() != nil
            If B3K->(FieldPos("B3K_CAEPF")) > 0
                self:oModel:SetValue( "B3KMASTER", 'B3K_CAEPF', oCenBenefi:getCaepf())
            EndIf
        EndIf

        if oCenBenefi:getMotBlo() != nil
            self:oModel:SetValue( "B3KMASTER", 'B3K_MOTBLO', oCenBenefi:getMotBlo())
        EndIf

        self:oModel:setValue( "B3KMASTER", 'B3K_OPESIB', SIB_MUDCONT)
        self:oModel:commitData(lNotifyANS)

    EndIf

    self:oModel:Destroy()
    FreeObj(self:oModel)
    self:oModel := Nil

Return lRet

Method loadOrder() Class DaoCenBenefi
    self:oHashOrder:set("CODECCO", "B3K_CODCCO")
    self:oHashOrder:set("HEALTHINSURERCODE", "B3K_CODOPE")
    self:oHashOrder:set("NAME", "B3K_NOMBEN")
    self:oHashOrder:set("GENDER", "B3K_SEXO")
    self:oHashOrder:set("BIRTHDATE", "B3K_DATNAS")
    self:oHashOrder:set("EFFECTIVEDATE", "B3K_DATINC")
    self:oHashOrder:set("BLOCKDATE", "B3K_DATBLO")
    self:oHashOrder:set("STATEABBREVIATION", "B3K_UF")
    self:oHashOrder:set("HEALTHINSURANCECODE", "B3K_CODPRO")
    self:oHashOrder:set("OLDSUBSCRIBERID", "B3K_MATANT")
    self:oHashOrder:set("UNBLOCKDATE", "B3K_DATREA")
    self:oHashOrder:set("PISPASEP", "B3K_PISPAS")
    self:oHashOrder:set("MOTHERSNAME", "B3K_NOMMAE")
    self:oHashOrder:set("DECLARATIONOFLIVEBIRTH", "B3K_DN")
    self:oHashOrder:set("NATIONALHEALTHCARD", "B3K_CNS")
    self:oHashOrder:set("ADDRESS", "B3K_ENDERE")
    self:oHashOrder:set("HOUSENUMBERING", "B3K_NR_END")
    self:oHashOrder:set("ADDRESSCOMPLEMENT", "B3K_COMEND")
    self:oHashOrder:set("DISTRICT", "B3K_BAIRRO")
    self:oHashOrder:set("CITYCODE", "B3K_CODMUN")
    self:oHashOrder:set("CITYCODERESIDENCE", "B3K_MUNICI")
    self:oHashOrder:set("ZIPCODE", "B3K_CEPUSR")
    self:oHashOrder:set("TYPEOFADDRESS", "B3K_TIPEND")
    self:oHashOrder:set("RESIDENTABROAD", "B3K_RESEXT")
    self:oHashOrder:set("HOLDERRELATIONSHIP", "B3K_TIPDEP")
    self:oHashOrder:set("HOLDERSUBSCRIBERID", "B3K_CODTIT")
    self:oHashOrder:set("CODESUSEP", "B3K_SUSEP")
    self:oHashOrder:set("CODESCPA", "B3K_SCPA")
    self:oHashOrder:set("PARTIALCOVERAGE", "B3K_COBPAR")
    self:oHashOrder:set("GUARANTORCNPJ", "B3K_CNPJCO")
    self:oHashOrder:set("GUARANTORCEI", "B3K_CEICON")
    self:oHashOrder:set("GUARANTORNAME", "B3K_NOMECO")
    self:oHashOrder:set("HOLDERCPF", "B3K_CPF")
    self:oHashOrder:set("MOTHERCPF", "B3K_CPFMAE")
    self:oHashOrder:set("SPONSORCPF", "B3K_CPFPRE")
    self:oHashOrder:set("CAEPF", "B3K_CAEPF")
Return

Method getFilters() Class DaoCenBenefi

    Local filter := ""

    If !empty(self:cCodCco)
        filter += " AND B3K_CODCCO = ? "
        aAdd(self:aMapBuilder, self:cCodCco)
    EndIf

    If !empty(self:cMatric)
        filter += " AND B3K_MATRIC = ? "
        aAdd(self:aMapBuilder, self:cMatric)
    EndIf

    If !empty(self:cNomben)
        filter += " AND B3K_NOMBEN = ? "
        aAdd(self:aMapBuilder, self:cNomben)
    Endif

    If !empty(self:cSexo)
        filter += " AND B3K_SEXO = ? "
        aAdd(self:aMapBuilder, self:cSexo)
    Endif

    If !empty(self:dDatnas)
        filter += " AND B3K_DATNAS = ? "
        aAdd(self:aMapBuilder, self:dDatnas)
    Endif

    If !empty(self:cCodpro)
        filter += " AND B3K_CODPRO = ? "
        aAdd(self:aMapBuilder, self:cCodpro)
    Endif

    If !empty(self:cMatant)
        filter += " AND B3K_MATANT = ? "
        aAdd(self:aMapBuilder, self:cMatant)
    Endif

    If !empty(self:cPispas)
        filter += " AND B3K_PISPAS = ? "
        aAdd(self:aMapBuilder, self:cPispas)
    Endif

    If !empty(self:cNommae)
        filter += " AND B3K_NOMMAE = ? "
        aAdd(self:aMapBuilder, self:cNommae)
    Endif

    If !empty(self:cCns)
        filter += " AND B3K_CNS = ? "
        aAdd(self:aMapBuilder, self:cCns)
    Endif

    If !empty(self:cEndere)
        filter += " AND B3K_ENDERE = ? "
        aAdd(self:aMapBuilder, self:cEndere)
    Endif

    If !empty(self:cNr_end)
        filter += " AND B3K_NR_END = ? "
        aAdd(self:aMapBuilder, self:cNr_end)
    Endif

    If !empty(self:cComend)
        filter += " AND B3K_COMEND = ? "
        aAdd(self:aMapBuilder, self:cComend)
    Endif

    If !empty(self:cBairro)
        filter += " AND B3K_BAIRRO = ? "
        aAdd(self:aMapBuilder, self:cBairro)
    Endif

    If !empty(self:cCodmun)
        filter += " AND B3K_CODMUN = ? "
        aAdd(self:aMapBuilder, self:cCodmun)
    Endif

    If !empty(self:cMunici)
        filter += " AND B3K_MUNICI = ? "
        aAdd(self:aMapBuilder, self:cMunici)
    Endif

    If !empty(self:cCepusr)
        filter += " AND B3K_CEPUSR = ? "
        aAdd(self:aMapBuilder, self:cCepusr)
    Endif

    If !empty(self:cResext)
        filter += " AND B3K_RESEXT = ? "
        aAdd(self:aMapBuilder, self:cResext)
    Endif

    If !empty(self:cTipdep)
        filter += " AND B3K_TIPDEP = ? "
        aAdd(self:aMapBuilder, self:cTipdep)
    Endif

    If !empty(self:cCodtit)
        filter += " AND B3K_CODTIT = ? "
        aAdd(self:aMapBuilder, self:cCodtit)
    Endif

    If !empty(self:cSusep)
        filter += " AND B3K_SUSEP = ? "
        aAdd(self:aMapBuilder, self:cSusep)
    Endif

    If !empty(self:cScpa)
        filter += " AND B3K_SCPA = ? "
        aAdd(self:aMapBuilder, self:cScpa)
    Endif

    If !empty(self:cCobpar)
        filter += " AND B3K_COBPAR = ? "
        aAdd(self:aMapBuilder, self:cCobpar)
    Endif

    If !empty(self:cCnpjco)
        filter += " AND B3K_CNPJCO = ? "
        aAdd(self:aMapBuilder, self:cCnpjco)
    Endif

    If !empty(self:cCeicon)
        filter += " AND B3K_CEICON = ? "
        aAdd(self:aMapBuilder, self:cCeicon)
    Endif

    If !empty(self:cCpf)
        filter += " AND B3K_CPF = ? "
        aAdd(self:aMapBuilder, self:cCpf)
    Endif

    If !empty(self:cCpfmae)
        filter += " AND B3K_CPFMAE = ? "
        aAdd(self:aMapBuilder, self:cCpfmae)
    Endif

    If !empty(self:cCpfpre)
        filter += " AND B3K_CPFPRE = ? "
        aAdd(self:aMapBuilder, self:cCpfpre)
    Endif

Return filter

/*/{Protheus.doc} applySearch
Efetua busca de tres dados para atualização de nome da empresa
@author  lima.everton
@since   20201112
/*/
Method BscAtuEmp() Class DaoCenBenefi
    Local cQuery := ""
    Local lFound := .F.
    Local cAlias := "B3K"
    Default self:cfieldOrder := " B3K_CODOPE, B3K_CODCCO,  B3K_MATRIC "

    self:cDB := TcGetDB()
    self:cNumPage := "1"
    self:cPageSize := "1"

    cQuery += self:getRowControl(self:cfieldOrder, cAlias)
    cQuery += self:getFields()
    cQuery += " FROM " + RetSqlName("B3K") + " B3K WHERE "
    cQuery += " B3K_FILIAL = '" + xFilial("B3K") + "' AND "
    cQuery += " B3K_CNPJCO <>  ? "
    aAdd(self:aMapBuilder, " ")

    cQuery += " AND B3K_NOMECO = ? "
    aAdd(self:aMapBuilder, " ")

    cQuery += " AND B3K_DTUPEM = ? "
    aAdd(self:aMapBuilder, " ")

    cQuery += "AND B3K.D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    cQuery += self:getFilters()
    cQuery += self:getCustWere(cAlias)
    cQuery := self:queryBuilder(cQuery)

    self:setQuery(cQuery)
    lFound := self:executaQuery()

    If lFound
        B3K->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return .T.

Method getCustWere(cAlias) Class DaoCenBenefi

    Local cQuery := ""
    Local cNumIni := alltrim(str((val(self:cNumPage ) - 1) * val(self:cPageSize)))
    Local cNumFim := alltrim(str(((val(self:cNumPage )) * val(self:cPageSize)) + 1))

    // Para fazer o controle da paginação em SQL, usado dessa maneira porque OFFSET e FETCH não funciona em versões sql menor que 2012
    If SQLSERVER $ self:cDB
        cQuery += " ) SELECT  * FROM " + cAlias +" WHERE ROW# > " + cNumIni +" AND ROW# < " +  cNumFim
    ElseIf ORACLE $ self:cDB
        cQuery += self:getCustQryPage(cNumIni,cNumFim)
    ElseIf POSTGRES $ self:cDB
        cQuery += " ) SELECT  * FROM " + cAlias +" WHERE ROW > " + cNumIni +" AND ROW < " +  cNumFim
    EndIf

Return cQuery

Method setCodOpe(cCodOpe) Class DaoCenBenefi
    self:cCodOpe := cCodOpe
Return

Method setCodCco(cCodCco) Class DaoCenBenefi
    self:cCodCco := cCodCco
Return

Method setMatric(cMatric) Class DaoCenBenefi
    self:cMatric := cMatric
Return

Method setNomben(cNomben) Class DaoCenBenefi
    self:cNomben := cNomben
Return

Method setSexo(cSexo) Class DaoCenBenefi
    self:cSexo := cSexo
Return

Method setDatnas(dDatnas) Class DaoCenBenefi
    self:dDatnas := dDatnas
Return

Method setCodpro(cCodpro) Class DaoCenBenefi
    self:cCodpro := cCodpro
Return

Method setMatant(cMatant) Class DaoCenBenefi
    self:cMatant := cMatant
Return

Method setPispas(cPispas) Class DaoCenBenefi
    self:cPispas := cPispas
Return

Method setNommae(cNommae) Class DaoCenBenefi
    self:cNommae := cNommae
Return

Method setCns(cCns) Class DaoCenBenefi
    self:cCns := cCns
Return

Method setEndere(cEndere) Class DaoCenBenefi
    self:cEndere := cEndere
Return

Method setNr_end(cNr_end) Class DaoCenBenefi
    self:cNr_end := cNr_end
Return

Method setComend(cComend) Class DaoCenBenefi
    self:cComend := cComend
Return

Method setBairro(cBairro) Class DaoCenBenefi
    self:cBairro := cBairro
Return

Method setCodmun(cCodmun) Class DaoCenBenefi
    self:cCodmun := cCodmun
Return

Method setMunici(cMunici) Class DaoCenBenefi
    self:cMunici := cMunici
Return

Method setCepusr(cCepusr) Class DaoCenBenefi
    self:cCepusr := cCepusr
Return

Method setResext(cResext) Class DaoCenBenefi
    self:cResext := cResext
Return

Method setTipdep(cTipdep) Class DaoCenBenefi
    self:cTipdep := cTipdep
Return

Method setCodtit(cCodtit) Class DaoCenBenefi
    self:cCodtit := cCodtit
Return

Method setSusep(cSusep) Class DaoCenBenefi
    self:cSusep := cSusep
Return

Method setScpa(cScpa) Class DaoCenBenefi
    self:cScpa := cScpa
Return

Method setCobpar(cCobpar) Class DaoCenBenefi
    self:cCobpar := cCobpar
Return

Method setCnpjco(cCnpjco) Class DaoCenBenefi
    self:cCnpjco := cCnpjco
Return

Method setCeicon(cCeicon) Class DaoCenBenefi
    self:cCeicon := cCeicon
Return

Method setCpf(cCpf) Class DaoCenBenefi
    self:cCpf := cCpf
Return

Method setCpfmae(cCpfmae) Class DaoCenBenefi
    self:cCpfmae := cCpfmae
Return

Method setCpfpre(cCpfpre) Class DaoCenBenefi
    self:cCpfpre := cCpfpre
Return

Method setCriMae(cCriMae) Class DaoCenBenefi
    self:cCriMae := cCriMae
Return

Method setCriNom(cCriNom) Class DaoCenBenefi
    self:cCriNom := cCriNom
Return

Method setCAEPF(cCaepf) Class DaoCenBenefi
    self:cCaepf := cCaepf
Return

Method setNomeCO(cNomeCO) Class DaoCenBenefi
    self:cNomeCO := cNomeCO
Return