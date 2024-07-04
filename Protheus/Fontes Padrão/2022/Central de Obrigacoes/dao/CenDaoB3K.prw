#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoB3K from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    Method applySearch(cSearch)
    
EndClass

Method New(aFields) Class CenDaoB3K
	_Super:New(aFields)
    self:cAlias := "B3K"
    self:cfieldOrder := "B3K_CODOPE,B3K_CODCCO,B3K_MATRIC"
Return self

Method buscar() Class CenDaoB3K
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B3K->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoB3K
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoB3K

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B3K') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B3K_FILIAL = '" + xFilial("B3K") + "' "

    cQuery += " AND B3K_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B3K_CODCCO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operationalControlCode")))
    cQuery += " AND B3K_MATRIC = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("benefIdentCode")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method applySearch(cSearch) Class CenDaoB3K

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B3K') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B3K_FILIAL = '" + xFilial("B3K") + "' "

    cQuery += " AND ( 1=2 "
    cQuery += " OR B3K_CODOPE LIKE '%" + cSearch + "%'"
    cQuery += " OR B3K_CODCCO LIKE '%" + cSearch + "%'"
    cQuery += " OR B3K_MATRIC LIKE '%" + cSearch + "%'"

    cQuery += " ) "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoB3K
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoB3K

    Default lInclui := .F.

	If B3K->(RecLock("B3K",lInclui))
		
        B3K->B3K_FILIAL := xFilial("B3K")
        If lInclui
        
            B3K->B3K_CODOPE := _Super:normalizeType(B3K->B3K_CODOPE,self:getValue("providerRegister")) 
            B3K->B3K_CODCCO := _Super:normalizeType(B3K->B3K_CODCCO,self:getValue("operationalControlCode")) 
            B3K->B3K_MATRIC := _Super:normalizeType(B3K->B3K_MATRIC,self:getValue("benefIdentCode")) 

        EndIf

        B3K->B3K_NOMBEN := _Super:normalizeType(B3K->B3K_NOMBEN,self:getValue("name")) 
        B3K->B3K_SEXO := _Super:normalizeType(B3K->B3K_SEXO,self:getValue("gender")) 
        B3K->B3K_DATNAS := _Super:normalizeType(B3K->B3K_DATNAS,self:getValue("dateOfBirth")) 
        B3K->B3K_DATINC := _Super:normalizeType(B3K->B3K_DATINC,self:getValue("contractingDate")) 
        B3K->B3K_DATBLO := _Super:normalizeType(B3K->B3K_DATBLO,self:getValue("cancellationDate")) 
        B3K->B3K_UF := _Super:normalizeType(B3K->B3K_UF,self:getValue("beneficiaryState")) 
        B3K->B3K_CODPRO := _Super:normalizeType(B3K->B3K_CODPRO,self:getValue("productCode")) 
        B3K->B3K_DIACOB := _Super:normalizeType(B3K->B3K_DIACOB,self:getValue("coverageDays")) 
        B3K->B3K_STATUS := _Super:normalizeType(B3K->B3K_STATUS,self:getValue("sipBenefStatus")) 
        B3K->B3K_ATUCAR := _Super:normalizeType(B3K->B3K_ATUCAR,self:getValue("updateGracePeriod")) 
        B3K->B3K_DTINVL := _Super:normalizeType(B3K->B3K_DTINVL,self:getValue("validationStartDate")) 
        B3K->B3K_HRINVL := _Super:normalizeType(B3K->B3K_HRINVL,self:getValue("validationStartTime")) 
        B3K->B3K_DTTEVL := _Super:normalizeType(B3K->B3K_DTTEVL,self:getValue("validationEndDate")) 
        B3K->B3K_HRTEVL := _Super:normalizeType(B3K->B3K_HRTEVL,self:getValue("validationEndTime")) 
        B3K->B3K_DTINSI := _Super:normalizeType(B3K->B3K_DTINSI,self:getValue("synthesisStartDate")) 
        B3K->B3K_HRINSI := _Super:normalizeType(B3K->B3K_HRINSI,self:getValue("synthesisStartTime")) 
        B3K->B3K_DTTESI := _Super:normalizeType(B3K->B3K_DTTESI,self:getValue("synthesisEndDate")) 
        B3K->B3K_HRTESI := _Super:normalizeType(B3K->B3K_HRTESI,self:getValue("synthesisEndTime")) 
        B3K->B3K_DATREA := _Super:normalizeType(B3K->B3K_DATREA,self:getValue("reactivationDate")) 
        B3K->B3K_SITANS := _Super:normalizeType(B3K->B3K_SITANS,self:getValue("statusAns")) 
        B3K->B3K_PISPAS := _Super:normalizeType(B3K->B3K_PISPAS,self:getValue("pisPasep")) 
        B3K->B3K_NOMMAE := _Super:normalizeType(B3K->B3K_NOMMAE,self:getValue("motherName")) 
        B3K->B3K_DN := _Super:normalizeType(B3K->B3K_DN,self:getValue("liveBirth")) 
        B3K->B3K_CNS := _Super:normalizeType(B3K->B3K_CNS,self:getValue("cns")) 
        B3K->B3K_ENDERE := _Super:normalizeType(B3K->B3K_ENDERE,self:getValue("address")) 
        B3K->B3K_NR_END := _Super:normalizeType(B3K->B3K_NR_END,self:getValue("addressNumber")) 
        B3K->B3K_COMEND := _Super:normalizeType(B3K->B3K_COMEND,self:getValue("addressComplement")) 
        B3K->B3K_BAIRRO := _Super:normalizeType(B3K->B3K_BAIRRO,self:getValue("district")) 
        B3K->B3K_CODMUN := _Super:normalizeType(B3K->B3K_CODMUN,self:getValue("codeCityResidIbge")) 
        B3K->B3K_MUNICI := _Super:normalizeType(B3K->B3K_MUNICI,self:getValue("cityCode")) 
        B3K->B3K_CEPUSR := _Super:normalizeType(B3K->B3K_CEPUSR,self:getValue("zipCod")) 
        B3K->B3K_TIPEND := _Super:normalizeType(B3K->B3K_TIPEND,self:getValue("addressIndicationCode")) 
        B3K->B3K_RESEXT := _Super:normalizeType(B3K->B3K_RESEXT,self:getValue("residIndicCodeNatFor")) 
        B3K->B3K_TIPDEP := _Super:normalizeType(B3K->B3K_TIPDEP,self:getValue("dependenceRelationship")) 
        B3K->B3K_CODTIT := _Super:normalizeType(B3K->B3K_CODTIT,self:getValue("holderBenefIdentCode")) 
        B3K->B3K_SUSEP := _Super:normalizeType(B3K->B3K_SUSEP,self:getValue("planNumberRps")) 
        B3K->B3K_SCPA := _Super:normalizeType(B3K->B3K_SCPA,self:getValue("planCodeScpa")) 
        B3K->B3K_MATANT := _Super:normalizeType(B3K->B3K_MATANT,self:getValue("formerRegistration")) 
        B3K->B3K_PLAORI := _Super:normalizeType(B3K->B3K_PLAORI,self:getValue("oriRpsPlanNoPortab")) 
        B3K->B3K_COBPAR := _Super:normalizeType(B3K->B3K_COBPAR,self:getValue("tempPartCoverageCode")) 
        B3K->B3K_CNPJCO := _Super:normalizeType(B3K->B3K_CNPJCO,self:getValue("einContractingCompany")) 
        B3K->B3K_CEICON := _Super:normalizeType(B3K->B3K_CEICON,self:getValue("ceiContractingCompany")) 
        B3K->B3K_TRAORI := _Super:normalizeType(B3K->B3K_TRAORI,self:getValue("originRegistration")) 
        B3K->B3K_TRADES := _Super:normalizeType(B3K->B3K_TRADES,self:getValue("destinationRegistration")) 
        B3K->B3K_OPESIB := _Super:normalizeType(B3K->B3K_OPESIB,self:getValue("sibOperation")) 
        B3K->B3K_CPF := _Super:normalizeType(B3K->B3K_CPF,self:getValue("cpf")) 
        B3K->B3K_CPFMAE := _Super:normalizeType(B3K->B3K_CPFMAE,self:getValue("cpfMother")) 
        B3K->B3K_CPFPRE := _Super:normalizeType(B3K->B3K_CPFPRE,self:getValue("cpfAgent")) 
        B3K->B3K_ITEEXC := _Super:normalizeType(B3K->B3K_ITEEXC,self:getValue("coverageDeletedItems")) 
        B3K->B3K_MOTBLO := _Super:normalizeType(B3K->B3K_MOTBLO,self:getValue("blockedReason")) 
        B3K->B3K_STASIB := _Super:normalizeType(B3K->B3K_STASIB,self:getValue("sibBenefStatus")) 
        B3K->B3K_STAESP := _Super:normalizeType(B3K->B3K_STAESP,self:getValue("esepelhoBenefStatus")) 
        B3K->B3K_CRIMAE := _Super:normalizeType(B3K->B3K_CRIMAE,self:getValue("reviewMotherSName")) 
        B3K->B3K_CRINOM := _Super:normalizeType(B3K->B3K_CRINOM,self:getValue("critBenefName")) 
        B3K->B3K_CAEPF := _Super:normalizeType(B3K->B3K_CAEPF,self:getValue("caepfContractingCompany")) 
        If B3K->(FieldPos("B3K_NOMECO")) > 0
            B3K->B3K_NOMECO := _Super:normalizeType(B3K->B3K_NOMECO,self:getValue("contractingCompanyName")) 
            B3K->B3K_DTUPEM := _Super:normalizeType(B3K->B3K_DTUPEM,self:getValue("companyUpdatingDate"))             
        EndIf
        B3K->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
