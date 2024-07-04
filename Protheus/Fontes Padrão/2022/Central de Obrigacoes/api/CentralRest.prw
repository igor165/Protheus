#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE CCOS   "CCOS"
#DEFINE BUSCA  "07"


WSRESTFUL HealthCare DESCRIPTION "Serviços REST da Central de Obrigações"

    // Atributos padrao utilizados em todas ou em mais de uma solicitacao
    WSDATA apiVersion as STRING  OPTIONAL
    WSDATA page as STRING  OPTIONAL
    WSDATA pageSize as STRING  OPTIONAL
    WSDATA tokenId as STRING  OPTIONAL
    WSDATA action as STRING  OPTIONAL
    WSDATA fields as STRING  OPTIONAL
    WSDATA search as STRING  OPTIONAL
    WSDATA filter as STRING  OPTIONAL
    WSDATA expand as STRING  OPTIONAL
    WSDATA order as STRING  OPTIONAL
    WSDATA version as STRING  OPTIONAL
    WSDATA uniqueKey as STRING  OPTIONAL

    WSDATA description as STRING  OPTIONAL
    WSDATA addressComplement as STRING  OPTIONAL
    WSDATA district as STRING  OPTIONAL

    WSDATA healthInsurerCode     as STRING  OPTIONAL
    WSDATA healthInsuranceCode   as STRING  OPTIONAL
    WSDATA codeCco               as STRING  OPTIONAL
    WSDATA subscriberId          as STRING  OPTIONAL
    WSDATA yearMonthRefer        as STRING  OPTIONAL
    WSDATA fileName              as STRING  OPTIONAL

    WSDATA code                   as STRING  OPTIONAL
    WSDATA wayofhiring            as STRING  OPTIONAL
    WSDATA marketsegmentation     as STRING  OPTIONAL
    WSDATA coveragearea           as STRING  OPTIONAL
    WSDATA name                   as STRING  OPTIONAL
    WSDATA gender                 as STRING  OPTIONAL
    WSDATA birthdate              as STRING  OPTIONAL
    WSDATA oldSubscriberId        as STRING  OPTIONAL
    WSDATA pisPasep               as STRING  OPTIONAL
    WSDATA mothersName            as STRING  OPTIONAL
    WSDATA nationalHealthCard     as STRING  OPTIONAL
    WSDATA address                as STRING  OPTIONAL
    WSDATA houseNumbering         as STRING  OPTIONAL
    WSDATA cityCode               as STRING  OPTIONAL
    WSDATA cityCodeResidence      as STRING  OPTIONAL
    WSDATA ZIPCode                as STRING  OPTIONAL
    WSDATA residentAbroad         as STRING  OPTIONAL
    WSDATA holderRelationship     as STRING  OPTIONAL
    WSDATA holderSubscriberId     as STRING  OPTIONAL
    WSDATA codeSusep              as STRING  OPTIONAL
    WSDATA codeSCPA               as STRING  OPTIONAL
    WSDATA partialCoverage        as STRING  OPTIONAL
    WSDATA guarantorCNPJ          as STRING  OPTIONAL
    WSDATA guarantorCEI           as STRING  OPTIONAL
    WSDATA holderCPF              as STRING  OPTIONAL
    WSDATA motherCPF              as STRING  OPTIONAL
    WSDATA sponsorCPF             as STRING  OPTIONAL
    WSDATA skipRuleName           as STRING  OPTIONAL
    WSDATA skipRuleMothersName    as STRING  OPTIONAL
    WSDATA caepf                  as STRING  OPTIONAL
    WSDATA effectiveDate          as STRING  OPTIONAL
    WSDATA blockDate              as STRING  OPTIONAL
    WSDATA guarantorName          as STRING  OPTIONAL
    WSDATA portabilityPlanCode    as STRING  OPTIONAL
    WSDATA statusAns              as STRING  OPTIONAL
    WSDATA blockingReason         as STRING  OPTIONAL
    WSDATA excludedItems          as STRING  OPTIONAL
    WSDATA typeOfAddress          as STRING  OPTIONAL
    WSDATA declarationOfLiveBirth as STRING  OPTIONAL
    WSDATA unblockDate            as STRING  OPTIONAL
    WSDATA stateAbbreviation      as STRING  OPTIONAL

    // Propriedades da entidade B36T10 - Coresponsibility Granted

    WSDATA ansEventCode as STRING  OPTIONAL

    // Propriedades da entidade B37T10 - Pecuniary Consideration

    WSDATA counterpartCoveragePeri as STRING  OPTIONAL
    WSDATA planType as STRING  OPTIONAL
    WSDATA valueToExpire as STRING  OPTIONAL
    WSDATA receivedValue as STRING  OPTIONAL
    WSDATA dueValueInArrears as STRING  OPTIONAL
    WSDATA netIssuedValue as STRING  OPTIONAL

    // Propriedades da entidade B3AT10 - Obligations

    WSDATA obligationCode as STRING  OPTIONAL
    WSDATA providerRegister as STRING  OPTIONAL
    WSDATA obligationDescription as STRING  OPTIONAL
    WSDATA seasonality as STRING  OPTIONAL
    WSDATA obligationType as STRING  OPTIONAL
    WSDATA activeInactive as STRING  OPTIONAL
    WSDATA dueDateNotification as STRING  OPTIONAL

    // Propriedades da entidade B3DT10 - Commitment

    WSDATA commitmentCode as STRING  OPTIONAL
    WSDATA referenceYear as STRING  OPTIONAL
    WSDATA commitmentDueDate as STRING  OPTIONAL
    WSDATA trimester as STRING  OPTIONAL
    WSDATA synthetizesBenefit as STRING  OPTIONAL
    WSDATA status as STRING  OPTIONAL

    // Propriedades da entidade B6RT10 - Common Funds

    WSDATA cnpjOrFundAnsRec as STRING  OPTIONAL
    WSDATA fundType as STRING  OPTIONAL
    WSDATA fundName as STRING  OPTIONAL
    WSDATA creditBalanceOfFund as STRING  OPTIONAL
    WSDATA debitorBalanceOfFund as STRING  OPTIONAL

    // Propriedades da entidade B82T10 - Capital Standard Model

    WSDATA tempRemidNumber as STRING  OPTIONAL
    WSDATA vitRemidNumber as STRING  OPTIONAL
    WSDATA tempExpSom as STRING  OPTIONAL
    WSDATA vitExpSom as STRING  OPTIONAL
    WSDATA tempRemisSom as STRING  OPTIONAL
    WSDATA vitRemisSom as STRING  OPTIONAL

    // Propriedades da entidade B89T10 - Liability Adequation Test

    WSDATA contractCancelRate as STRING  OPTIONAL
    WSDATA biomTabAdjustment as STRING  OPTIONAL
    WSDATA cashFlowAdjEstimation as STRING  OPTIONAL
    WSDATA utiOfRangesRn632003 as STRING  OPTIONAL
    WSDATA estimatedMedicalInflati as STRING  OPTIONAL
    WSDATA ettjInterMethod as STRING  OPTIONAL
    WSDATA averageAdjustmentPerVa as STRING  OPTIONAL
    WSDATA estimatedMaximumAdjustm as STRING  OPTIONAL

    // Propriedades da entidade B8AT10 - Trimester Balance Sheet

    WSDATA commitmentYear as STRING  OPTIONAL
    WSDATA accountCode as STRING  OPTIONAL
    WSDATA credits as STRING  OPTIONAL
    WSDATA debits as STRING  OPTIONAL
    WSDATA previousBalance as STRING  OPTIONAL
    WSDATA finalBalance as STRING  OPTIONAL

    // Propriedades da entidade B8BT10 - Ans Account Plan

    WSDATA validityEndDate as STRING  OPTIONAL
    WSDATA validityStartDate as STRING  OPTIONAL
    WSDATA accountDescription as STRING  OPTIONAL

    // Propriedades da entidade B8CT10 - Real Est Gar Asset

    WSDATA realEstateGeneralRegis as STRING  OPTIONAL
    WSDATA assitance as STRING  OPTIONAL
    WSDATA ownNetwork as STRING  OPTIONAL
    WSDATA accountingValue as STRING  OPTIONAL

    // Propriedades da entidade B8FT10 - Active Balance Age

    WSDATA financialDueDate as STRING  OPTIONAL
    WSDATA debWPortfAcquis as STRING  OPTIONAL
    WSDATA mktOnOperations as STRING  OPTIONAL
    WSDATA debitsWithOperators as STRING  OPTIONAL
    WSDATA benefDepContrapIns as STRING  OPTIONAL
    WSDATA eventClaimNetPres as STRING  OPTIONAL
    WSDATA eventClaimNetSus as STRING  OPTIONAL
    WSDATA otherDebOprWPlan as STRING  OPTIONAL
    WSDATA otherDebitsToPay as STRING  OPTIONAL
    WSDATA hthCareServProv as STRING  OPTIONAL
    WSDATA billsChargesCollect as STRING  OPTIONAL

    // Propriedades da entidade B8GT10 - Liability Balance Age

    WSDATA collectiveFloating as STRING  OPTIONAL
    WSDATA collectiveFixed as STRING  OPTIONAL
    WSDATA beneficiariesOperationC as STRING  OPTIONAL
    WSDATA postPaymentOperCredit as STRING  OPTIONAL
    WSDATA individualFloating as STRING  OPTIONAL
    WSDATA individualFixed as STRING  OPTIONAL
    WSDATA prePaymentOperatorsCre as STRING  OPTIONAL
    WSDATA otherCreditsWithPlan as STRING  OPTIONAL
    WSDATA otherCredNotRelatPlan as STRING  OPTIONAL
    WSDATA partBenefInEveClaim as STRING  OPTIONAL

    // Propriedades da entidade B8HT10 - Cash Flow

    WSDATA cashFlowCode as STRING  OPTIONAL
    WSDATA value as STRING  OPTIONAL

    // Propriedades da entidade B8IT10 - Assistance Coverage

    WSDATA typeOfPlan as STRING  OPTIONAL
    WSDATA paymentOrigin as STRING  OPTIONAL
    WSDATA otherPayments as STRING  OPTIONAL
    WSDATA therapies as STRING  OPTIONAL
    WSDATA medicalAppointment as STRING  OPTIONAL
    WSDATA otherExpenses as STRING  OPTIONAL
    WSDATA examinations as STRING  OPTIONAL
    WSDATA hospitalizations as STRING  OPTIONAL

    // Propriedades da entidade B8JT10 - Prov Net Sin Ev Pesl

    WSDATA evCorrAssumMajorPer as STRING  OPTIONAL
    WSDATA lastDaysAssumCorrEv as STRING  OPTIONAL
    WSDATA greaterDangerLossEvent as STRING  OPTIONAL
    WSDATA latestDaysEvents as STRING  OPTIONAL
    WSDATA noOfBeneficiaries as STRING  OPTIONAL

    // Propriedades da entidade B8KT10 - Contract Consolidation

    WSDATA riskPool as STRING  OPTIONAL
    WSDATA pceCorresponGranted as STRING  OPTIONAL
    WSDATA pceIssuedCounterprov as STRING  OPTIONAL
    WSDATA eveClaimsKnownPce as STRING  OPTIONAL
    WSDATA plaCorresponGranted as STRING  OPTIONAL
    WSDATA issuedConsiderationsPla as STRING  OPTIONAL
    WSDATA plaKnowlLossEvents as STRING  OPTIONAL

    // Propriedades da entidade B8LT10 - Indemnifiable Events

    WSDATA eventCodeAns as STRING  OPTIONAL
    WSDATA quarterMthFirstValue as STRING  OPTIONAL
    WSDATA quarterMthSecValue as STRING  OPTIONAL
    WSDATA quarterMthThirdValue as STRING  OPTIONAL

    // Propriedades da entidade B8MT10 - Operators

    WSDATA operatorCnpj as STRING  OPTIONAL
    WSDATA operatorMode as STRING  OPTIONAL
    WSDATA legalNature as STRING  OPTIONAL
    WSDATA tradeName as STRING  OPTIONAL
    WSDATA corporateName as STRING  OPTIONAL
    WSDATA operatorSegmentation as STRING  OPTIONAL

    // Propriedades da entidade B8NT10 - Representatives

    WSDATA registrationOfIndividua as STRING  OPTIONAL
    WSDATA representativeSPosition as STRING  OPTIONAL
    WSDATA ibgeCityCode as STRING  OPTIONAL
    WSDATA postAddrCode as STRING  OPTIONAL
    WSDATA nationalCallingCd as STRING  OPTIONAL
    WSDATA internationalCallinfCd as STRING  OPTIONAL
    WSDATA idIssueDate as STRING  OPTIONAL
    WSDATA addressName as STRING  OPTIONAL
    WSDATA representativeSName as STRING  OPTIONAL
    WSDATA idNumber as STRING  OPTIONAL
    WSDATA addressNumber as STRING  OPTIONAL
    WSDATA idIssuingBody as STRING  OPTIONAL
    WSDATA country as STRING  OPTIONAL
    WSDATA extension as STRING  OPTIONAL
    WSDATA stateAcronym as STRING  OPTIONAL
    WSDATA telephoneNumber as STRING  OPTIONAL

    // Propriedades da entidade B8ST10 - Shareholders

    WSDATA shareholderSCpfCnpj as STRING  OPTIONAL
    WSDATA numberOfShares as STRING  OPTIONAL
    WSDATA shareholderType as STRING  OPTIONAL

    // Propriedades da entidade B8TT10 - Controlled Affiliates

    WSDATA legalEntityNatRegister as STRING  OPTIONAL
    WSDATA quantityOfActions as STRING  OPTIONAL
    WSDATA companyName as STRING  OPTIONAL
    WSDATA totalOfActionsOrQuota as STRING  OPTIONAL
    WSDATA typeOfShare as STRING  OPTIONAL
    WSDATA companyClassification as STRING  OPTIONAL

    // Propriedades da entidade B8XT10 - Charts

    WSDATA diopsChart as STRING  OPTIONAL
    WSDATA chartReceived as STRING  OPTIONAL
    WSDATA validateChart as STRING  OPTIONAL

    // Propriedades da entidade B8YT10 - Persons Responsible

    WSDATA cpfCnpj as STRING  OPTIONAL
    WSDATA responsibleLeOrIndivid as STRING  OPTIONAL
    WSDATA responsibilityType as STRING  OPTIONAL
    WSDATA nameCorporateName as STRING  OPTIONAL
    WSDATA recordNumber as STRING  OPTIONAL

    // Propriedades da entidade B8ZT10 - Premises

    WSDATA longDistanceCode as STRING  OPTIONAL
    WSDATA eMail as STRING  OPTIONAL
    WSDATA extensionLine as STRING  OPTIONAL
    WSDATA dependenceType as STRING  OPTIONAL

    // Propriedades da entidade BUPT10 - Stipulated Contracts

    WSDATA operatorRecordInAns as STRING  OPTIONAL
    WSDATA billingValue as STRING  OPTIONAL

    // Propriedades da entidade BUWT10 - Cooper Check Accnt

    WSDATA taxName as STRING  OPTIONAL
    WSDATA periodDate as STRING  OPTIONAL
    WSDATA taxType as STRING  OPTIONAL
    WSDATA monetaryUpdate as STRING  OPTIONAL
    WSDATA amtPaidTrimester as STRING  OPTIONAL
    WSDATA totalAmtFinanced as STRING  OPTIONAL
    WSDATA totalAmtPaid as STRING  OPTIONAL
    WSDATA dateAdhesionToRefis as STRING  OPTIONAL
    WSDATA numberOfInstallments as STRING  OPTIONAL
    WSDATA numbDueInstallments as STRING  OPTIONAL
    WSDATA numbOfPaidInstallm as STRING  OPTIONAL
    WSDATA trimesterFinalBalance as STRING  OPTIONAL
    WSDATA trimesterInitialBalance as STRING  OPTIONAL

    // Propriedades da entidade BUYT10 - Liability Tax Accnt

    WSDATA competenceDate as STRING  OPTIONAL
    WSDATA balanceAtTheEndOfThe as STRING  OPTIONAL
    WSDATA initialValue as STRING  OPTIONAL
    WSDATA valuePaid as STRING  OPTIONAL

    // Propriedades da entidade BVST10 - Trans Contr Amt Segr

    WSDATA benefitAdmOperCode as STRING  OPTIONAL
    WSDATA amt1StMthTrimester as STRING  OPTIONAL
    WSDATA amt2NdMthTrimester as STRING  OPTIONAL
    WSDATA amt3RdMthTrimester as STRING  OPTIONAL

    WSDATA identReceipt as STRING  OPTIONAL
    WSDATA totalValueEntered as STRING  OPTIONAL
    WSDATA totalDisallowValue as STRING  OPTIONAL
    WSDATA totalValuePaid as STRING  OPTIONAL
    WSDATA deletionId as STRING  OPTIONAL

    // Propriedades da entidade monitPresetValue - monitPresetValue

    WSDATA periodCover as STRING  OPTIONAL
    WSDATA providerIdentifier as STRING  OPTIONAL
    WSDATA cityOfProvider as STRING  OPTIONAL
    WSDATA presetValue as STRING  OPTIONAL

    // Propriedades da entidade Batches - Batches

    WSDATA operatorRecord as STRING  OPTIONAL
    WSDATA batchCode as STRING  OPTIONAL
    WSDATA requirementCode as STRING  OPTIONAL
    WSDATA remunerationType as STRING  OPTIONAL
    WSDATA file as STRING  OPTIONAL
    WSDATA processingDate as STRING  OPTIONAL
    WSDATA processingTime as STRING  OPTIONAL
    // WSDATA noEnglishName as STRING  OPTIONAL

    // Propriedades da entidade monitFormCertificates - monitFormCertificates

    WSDATA certificateNumber as STRING  OPTIONAL

    // Propriedades da entidade monitForm - monitForm

    WSDATA formSequential as STRING  OPTIONAL
    WSDATA processed as STRING  OPTIONAL
    WSDATA tissProviderVersion as STRING  OPTIONAL
    WSDATA submissionMethod as STRING  OPTIONAL
    WSDATA cnes as STRING  OPTIONAL
    WSDATA executerId as STRING  OPTIONAL
    WSDATA providerCpfCnpj as STRING  OPTIONAL
    WSDATA executingCityCode as STRING  OPTIONAL
    WSDATA ansRecordNumber as STRING  OPTIONAL
    WSDATA registration as STRING  OPTIONAL
    WSDATA aEventType as STRING  OPTIONAL
    WSDATA eventOrigin as STRING  OPTIONAL
    WSDATA providerFormNumber as STRING  OPTIONAL
    WSDATA operatorFormNumber as STRING  OPTIONAL
    WSDATA refundId as STRING  OPTIONAL
    WSDATA presetValueIdent as STRING  OPTIONAL
    WSDATA hospitalizationRequest as STRING  OPTIONAL
    WSDATA requestDate as STRING  OPTIONAL
    WSDATA mainFormNumb as STRING  OPTIONAL
    WSDATA authorizationDate as STRING  OPTIONAL
    WSDATA executionDate as STRING  OPTIONAL
    WSDATA invoicingStartDate as STRING  OPTIONAL
    WSDATA invoicingEndDate as STRING  OPTIONAL
    WSDATA collectionProtocolDate as STRING  OPTIONAL
    WSDATA paymentDt as STRING  OPTIONAL
    WSDATA formProcDt as STRING  OPTIONAL
    WSDATA appointmentType as STRING  OPTIONAL
    WSDATA cboSCode as STRING  OPTIONAL
    WSDATA newborn as STRING  OPTIONAL
    WSDATA indicAccident as STRING  OPTIONAL
    WSDATA admissionType as STRING  OPTIONAL
    WSDATA hospTp as STRING  OPTIONAL
    WSDATA hospRegime as STRING  OPTIONAL
    WSDATA serviceType as STRING  OPTIONAL
    WSDATA invoicingTp as STRING  OPTIONAL
    WSDATA escortDailyRates as STRING  OPTIONAL
    WSDATA icuDailyRates as STRING  OPTIONAL
    WSDATA outflowType as STRING  OPTIONAL
    WSDATA icdDiagnosis1 as STRING  OPTIONAL
    WSDATA icdDiagnosis2 as STRING  OPTIONAL
    WSDATA icdDiagnosis3 as STRING  OPTIONAL
    WSDATA icdDiagnosis4 as STRING  OPTIONAL
    WSDATA inclusionDate as STRING  OPTIONAL
    WSDATA inclusionTime as STRING  OPTIONAL
    WSDATA dateOfDeletion as STRING  OPTIONAL
    WSDATA roboId as STRING  OPTIONAL
    WSDATA procStartTime as STRING  OPTIONAL
    WSDATA exclusionID as STRING  OPTIONAL

    // Propriedades da entidade monitFormEvents - monitFormEvents

    WSDATA sequence as STRING  OPTIONAL
    WSDATA tableCode as STRING  OPTIONAL
    WSDATA procedureGroup as STRING  OPTIONAL
    WSDATA procedureCode as STRING  OPTIONAL
    WSDATA toothCode as STRING  OPTIONAL
    WSDATA regionCode as STRING  OPTIONAL
    WSDATA toothFaceCode as STRING  OPTIONAL
    WSDATA enteredQuantity as STRING  OPTIONAL
    WSDATA valueEntered as STRING  OPTIONAL
    WSDATA quantityPaid as STRING  OPTIONAL
    WSDATA procedureValuePaid as STRING  OPTIONAL
    WSDATA valuePaidSupplier as STRING  OPTIONAL
    WSDATA supplierCnpj as STRING  OPTIONAL
    WSDATA coPaymentValue as STRING  OPTIONAL
    WSDATA disallVl as STRING  OPTIONAL
    WSDATA package as STRING  OPTIONAL

    // Propriedades da entidade monitFormPackages - monitFormPackages

    WSDATA sequentialItem as STRING  OPTIONAL
    WSDATA itemTableCode as STRING  OPTIONAL
    WSDATA itemProCode as STRING  OPTIONAL
    WSDATA packageQuantity as STRING  OPTIONAL

    // Propriedades da entidade monitDirectSupply - monitDirectSupply

    WSDATA deletionDate as STRING  OPTIONAL

    // Propriedades da entidade B2Y - analyticDmedExpenses - Analytic Dmed Expenses
    WSDATA ssnHolder as STRING  OPTIONAL
    WSDATA titleHolderEnrollment as STRING  OPTIONAL
    WSDATA holderName as STRING  OPTIONAL
    WSDATA dependentSsn as STRING  OPTIONAL
    WSDATA dependentEnrollment as STRING  OPTIONAL
    WSDATA dependentName as STRING  OPTIONAL
    WSDATA dependentBirthDate as STRING  OPTIONAL
    WSDATA dependenceRelationships as STRING  OPTIONAL
    WSDATA expenseKey as STRING  OPTIONAL
    WSDATA expenseAmount as STRING  OPTIONAL
    WSDATA refundAmount as STRING  OPTIONAL
    WSDATA previousYearRefundAmt as STRING  OPTIONAL
    WSDATA period as STRING  OPTIONAL
    WSDATA providerSsnEin as STRING  OPTIONAL
    WSDATA providerName as STRING  OPTIONAL
    WSDATA inicialDate as STRING  OPTIONAL
    WSDATA finalDate as STRING  OPTIONAL

    // Propriedades da entidade Persons In Charge - Persons In Charge

    WSDATA ssn as STRING  OPTIONAL
    WSDATA areaCode as STRING  OPTIONAL
    WSDATA phoneNumber as STRING  OPTIONAL
    WSDATA fax as STRING  OPTIONAL
    WSDATA active as STRING  OPTIONAL

    // Propriedades da entidade Operators Diops - Operators Diops
    WSDATA registerNumber as STRING  OPTIONAL

    // Propriedades da entidade BI0 - Indicadores IDSS

    WSDATA numeratorTissRatio as STRING  OPTIONAL
    WSDATA denominatorTissRatio as STRING  OPTIONAL
    WSDATA partialTissRatio as STRING  OPTIONAL
    WSDATA totalTissRatio as STRING  OPTIONAL

    // Metodos do Produto
    WSMETHOD GET prodTodos DESCRIPTION "" ;
        WSsyntax "{version}/products" ;
        PATH "{version}/products" PRODUCES APPLICATION_JSON

    WSMETHOD GET produto DESCRIPTION "" ;
        WSsyntax "{version}/products/{healthInsuranceCode}" ;
        PATH "{version}/products/{healthInsuranceCode}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT alteraProduto DESCRIPTION "" ;
        WSsyntax "{version}/products/{healthInsuranceCode}" ;
        PATH "{version}/products/{healthInsuranceCode}" PRODUCES APPLICATION_JSON

    WSMETHOD POST insereProduto DESCRIPTION "" ;
        WSsyntax "{version}/products" ;
        PATH "{version}/products" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE deleteProduto DESCRIPTION "" ;
        WSsyntax "{version}/products/{healthInsuranceCode}" ;
        PATH "{version}/products/{healthInsuranceCode}" PRODUCES APPLICATION_JSON

    // Metodos do Beneficiario
    WSMETHOD GET B3KCollection  DESCRIPTION "" ;
        WSsyntax "{version}/beneficiaries" ;
        PATH "{version}/beneficiaries" PRODUCES APPLICATION_JSON

    WSMETHOD GET B3KSingle  DESCRIPTION "" ;
        WSsyntax "{version}/beneficiaries/{uniqueKey}" ;
        PATH "{version}/beneficiaries/{uniqueKey}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT altBeneficiario DESCRIPTION "" ;
        WSsyntax "{version}/beneficiaries/{subscriberId}" ;
        PATH "{version}/beneficiaries/{subscriberId}" PRODUCES APPLICATION_JSON

    WSMETHOD POST cancelBeneficiario DESCRIPTION "" ;
        WSsyntax "{version}/beneficiaries/{subscriberId}/block" ;
        PATH "{version}/beneficiaries/{subscriberId}/block" PRODUCES APPLICATION_JSON

    WSMETHOD POST reactBeneficiario DESCRIPTION "" ;
        WSsyntax "{version}/beneficiaries/{subscriberId}/unblock" ;
        PATH "{version}/beneficiaries/{subscriberId}/unblock" PRODUCES APPLICATION_JSON

    WSMETHOD POST changerContractBene DESCRIPTION "" ;
        WSsyntax "{version}/beneficiaries/{subscriberId}/changerContract" ;
        PATH "{version}/beneficiaries/{subscriberId}/changerContract" PRODUCES APPLICATION_JSON

    WSMETHOD POST insBeneficiario DESCRIPTION "" ;
        WSsyntax "{version}/beneficiaries" ;
        PATH "{version}/beneficiaries" PRODUCES APPLICATION_JSON

    WSMETHOD POST insLoteBeneficiario DESCRIPTION "" ;
        WSsyntax "{version}/beneficiaries/batch/" ;
        PATH "{version}/beneficiaries/batch/" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE beneDelete DESCRIPTION "";
        WSsyntax "{version}/beneficiaries/{subscriberId}";
        PATH "{version}/beneficiaries/{subscriberId}" PRODUCES APPLICATION_JSON

    //Arquivos Sip
    WSMETHOD GET allFiles DESCRIPTION "";
        WSsyntax "{version}/files/{yearMonthRefer}";
        PATH "{version}/files/{yearMonthRefer}" PRODUCES APPLICATION_JSON

    WSMETHOD GET ccosFromFiles DESCRIPTION "";
        WSsyntax "{version}/files/ccos/{fileName}";
        PATH "{version}/files/ccos/{fileName}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B36T10 - Coresponsibility Granted
    WSMETHOD GET CrcdCollection DESCRIPTION "Coresponsibility Granted - Get Collection" ;
        WSsyntax "{version}/coresponsibilityGranted" ;
        PATH "{version}/coresponsibilityGranted" PRODUCES APPLICATION_JSON

    WSMETHOD GET CrcdSingle DESCRIPTION "Coresponsibility Granted - Get Single" ;
        WSsyntax "{version}/coresponsibilityGranted/{ansEventCode}" ;
        PATH "{version}/coresponsibilityGranted/{ansEventCode}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT CrcdUpdate DESCRIPTION "Coresponsibility Granted - PUT" ;
        WSsyntax "{version}/coresponsibilityGranted/{ansEventCode}" ;
        PATH "{version}/coresponsibilityGranted/{ansEventCode}" PRODUCES APPLICATION_JSON

    WSMETHOD POST CrcdInsert DESCRIPTION "Coresponsibility Granted - Post" ;
        WSsyntax "{version}/coresponsibilityGranted" ;
        PATH "{version}/coresponsibilityGranted" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE CrcdDelete DESCRIPTION "Coresponsibility Granted - Delete" ;
        WSsyntax "{version}/coresponsibilityGranted/{ansEventCode}" ;
        PATH "{version}/coresponsibilityGranted/{ansEventCode}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B37T10 - Pecuniary Consideration
    WSMETHOD GET PectCollection DESCRIPTION "Pecuniary Consideration - Get Collection" ;
        WSsyntax "{version}/pecuniaryConsideration" ;
        PATH "{version}/pecuniaryConsideration" PRODUCES APPLICATION_JSON

    WSMETHOD GET PectSingle DESCRIPTION "Pecuniary Consideration - Get Single" ;
        WSsyntax "{version}/pecuniaryConsideration/{counterpartCoveragePeri}" ;
        PATH "{version}/pecuniaryConsideration/{counterpartCoveragePeri}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT PectUpdate DESCRIPTION "Pecuniary Consideration - PUT" ;
        WSsyntax "{version}/pecuniaryConsideration/{counterpartCoveragePeri}" ;
        PATH "{version}/pecuniaryConsideration/{counterpartCoveragePeri}" PRODUCES APPLICATION_JSON

    WSMETHOD POST PectInsert DESCRIPTION "Pecuniary Consideration - Post" ;
        WSsyntax "{version}/pecuniaryConsideration" ;
        PATH "{version}/pecuniaryConsideration" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE PectDelete DESCRIPTION "Pecuniary Consideration - Delete" ;
        WSsyntax "{version}/pecuniaryConsideration/{counterpartCoveragePeri}" ;
        PATH "{version}/pecuniaryConsideration/{counterpartCoveragePeri}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B3AT10 - Obligations
    WSMETHOD GET ObriCollection DESCRIPTION "Obligations - Get Collection" ;
        WSsyntax "{version}/obligations" ;
        PATH "{version}/obligations" PRODUCES APPLICATION_JSON

    WSMETHOD GET ObriSingle DESCRIPTION "Obligations - Get Single" ;
        WSsyntax "{version}/obligations/{obligationCode}" ;
        PATH "{version}/obligations/{obligationCode}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT ObriUpdate DESCRIPTION "Obligations - PUT" ;
        WSsyntax "{version}/obligations/{obligationCode}" ;
        PATH "{version}/obligations/{obligationCode}" PRODUCES APPLICATION_JSON

    WSMETHOD POST ObriInsert DESCRIPTION "Obligations - Post" ;
        WSsyntax "{version}/obligations" ;
        PATH "{version}/obligations" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE ObriDelete DESCRIPTION "Obligations - Delete" ;
        WSsyntax "{version}/obligations/{obligationCode}" ;
        PATH "{version}/obligations/{obligationCode}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B3DT10 - Commitment
    WSMETHOD GET CompCollection DESCRIPTION "Commitment - Get Collection" ;
        WSsyntax "{version}/commitment" ;
        PATH "{version}/commitment" PRODUCES APPLICATION_JSON

    WSMETHOD GET CompSingle DESCRIPTION "Commitment - Get Single" ;
        WSsyntax "{version}/commitment/{commitmentCode}" ;
        PATH "{version}/commitment/{commitmentCode}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT CompUpdate DESCRIPTION "Commitment - PUT" ;
        WSsyntax "{version}/commitment/{commitmentCode}" ;
        PATH "{version}/commitment/{commitmentCode}" PRODUCES APPLICATION_JSON

    WSMETHOD POST CompInsert DESCRIPTION "Commitment - Post" ;
        WSsyntax "{version}/commitment" ;
        PATH "{version}/commitment" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE CompDelete DESCRIPTION "Commitment - Delete" ;
        WSsyntax "{version}/commitment/{commitmentCode}" ;
        PATH "{version}/commitment/{commitmentCode}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B6RT10 - Common Funds
    WSMETHOD GET FucoCollection DESCRIPTION "Common Funds - Get Collection" ;
        WSsyntax "{version}/commonFunds" ;
        PATH "{version}/commonFunds" PRODUCES APPLICATION_JSON

    WSMETHOD GET FucoSingle DESCRIPTION "Common Funds - Get Single" ;
        WSsyntax "{version}/commonFunds/{fundType}" ;
        PATH "{version}/commonFunds/{fundType}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT FucoUpdate DESCRIPTION "Common Funds - PUT" ;
        WSsyntax "{version}/commonFunds/{fundType}" ;
        PATH "{version}/commonFunds/{fundType}" PRODUCES APPLICATION_JSON

    WSMETHOD POST FucoInsert DESCRIPTION "Common Funds - Post" ;
        WSsyntax "{version}/commonFunds" ;
        PATH "{version}/commonFunds" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE FucoDelete DESCRIPTION "Common Funds - Delete" ;
        WSsyntax "{version}/commonFunds/{fundType}" ;
        PATH "{version}/commonFunds/{fundType}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B82T10 - Capital Standard Model
    WSMETHOD GET MdpcCollection DESCRIPTION "Capital Standard Model - Get Collection" ;
        WSsyntax "{version}/capitalStandardModel" ;
        PATH "{version}/capitalStandardModel" PRODUCES APPLICATION_JSON

    WSMETHOD GET MdpcSingle DESCRIPTION "Capital Standard Model - Get Single" ;
        WSsyntax "{version}/capitalStandardModel/{commitmentCode}" ;
        PATH "{version}/capitalStandardModel/{commitmentCode}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT MdpcUpdate DESCRIPTION "Capital Standard Model - PUT" ;
        WSsyntax "{version}/capitalStandardModel/{commitmentCode}" ;
        PATH "{version}/capitalStandardModel/{commitmentCode}" PRODUCES APPLICATION_JSON

    WSMETHOD POST MdpcInsert DESCRIPTION "Capital Standard Model - Post" ;
        WSsyntax "{version}/capitalStandardModel" ;
        PATH "{version}/capitalStandardModel" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE MdpcDelete DESCRIPTION "Capital Standard Model - Delete" ;
        WSsyntax "{version}/capitalStandardModel/{commitmentCode}" ;
        PATH "{version}/capitalStandardModel/{commitmentCode}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B89T10 - Liability Adequation Test
    WSMETHOD GET TeapCollection DESCRIPTION "Liability Adequation Test - Get Collection" ;
        WSsyntax "{version}/liabilityAdequationTest" ;
        PATH "{version}/liabilityAdequationTest" PRODUCES APPLICATION_JSON

    WSMETHOD GET TeapSingle DESCRIPTION "Liability Adequation Test - Get Single" ;
        WSsyntax "{version}/liabilityAdequationTest/{planType}" ;
        PATH "{version}/liabilityAdequationTest/{planType}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT TeapUpdate DESCRIPTION "Liability Adequation Test - PUT" ;
        WSsyntax "{version}/liabilityAdequationTest/{planType}" ;
        PATH "{version}/liabilityAdequationTest/{planType}" PRODUCES APPLICATION_JSON

    WSMETHOD POST TeapInsert DESCRIPTION "Liability Adequation Test - Post" ;
        WSsyntax "{version}/liabilityAdequationTest" ;
        PATH "{version}/liabilityAdequationTest" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE TeapDelete DESCRIPTION "Liability Adequation Test - Delete" ;
        WSsyntax "{version}/liabilityAdequationTest/{planType}" ;
        PATH "{version}/liabilityAdequationTest/{planType}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8AT10 - Trimester Balance Sheet
    WSMETHOD GET BlctCollection DESCRIPTION "Trimester Balance Sheet - Get Collection" ;
        WSsyntax "{version}/trimesterBalanceSheet" ;
        PATH "{version}/trimesterBalanceSheet" PRODUCES APPLICATION_JSON

    WSMETHOD GET BlctSingle DESCRIPTION "Trimester Balance Sheet - Get Single" ;
        WSsyntax "{version}/trimesterBalanceSheet/{accountCode}" ;
        PATH "{version}/trimesterBalanceSheet/{accountCode}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT BlctUpdate DESCRIPTION "Trimester Balance Sheet - PUT" ;
        WSsyntax "{version}/trimesterBalanceSheet/{accountCode}" ;
        PATH "{version}/trimesterBalanceSheet/{accountCode}" PRODUCES APPLICATION_JSON

    WSMETHOD POST BlctInsert DESCRIPTION "Trimester Balance Sheet - Post" ;
        WSsyntax "{version}/trimesterBalanceSheet" ;
        PATH "{version}/trimesterBalanceSheet" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE BlctDelete DESCRIPTION "Trimester Balance Sheet - Delete" ;
        WSsyntax "{version}/trimesterBalanceSheet/{accountCode}" ;
        PATH "{version}/trimesterBalanceSheet/{accountCode}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8BT10 - Ans Account Plan
    WSMETHOD GET PlacCollection DESCRIPTION "Ans Account Plan - Get Collection" ;
        WSsyntax "{version}/ansAccountPlan" ;
        PATH "{version}/ansAccountPlan" PRODUCES APPLICATION_JSON

    WSMETHOD GET PlacSingle DESCRIPTION "Ans Account Plan - Get Single" ;
        WSsyntax "{version}/ansAccountPlan/{accountCode}" ;
        PATH "{version}/ansAccountPlan/{accountCode}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT PlacUpdate DESCRIPTION "Ans Account Plan - PUT" ;
        WSsyntax "{version}/ansAccountPlan/{accountCode}" ;
        PATH "{version}/ansAccountPlan/{accountCode}" PRODUCES APPLICATION_JSON

    WSMETHOD POST PlacInsert DESCRIPTION "Ans Account Plan - Post" ;
        WSsyntax "{version}/ansAccountPlan" ;
        PATH "{version}/ansAccountPlan" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE PlacDelete DESCRIPTION "Ans Account Plan - Delete" ;
        WSsyntax "{version}/ansAccountPlan/{accountCode}" ;
        PATH "{version}/ansAccountPlan/{accountCode}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8CT10 - Real Est Gar Asset
    WSMETHOD GET AgimCollection DESCRIPTION "Real Est Gar Asset - Get Collection" ;
        WSsyntax "{version}/realEstGarAsset" ;
        PATH "{version}/realEstGarAsset" PRODUCES APPLICATION_JSON

    WSMETHOD GET AgimSingle DESCRIPTION "Real Est Gar Asset - Get Single" ;
        WSsyntax "{version}/realEstGarAsset/{providerRegister}" ;
        PATH "{version}/realEstGarAsset/{providerRegister}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT AgimUpdate DESCRIPTION "Real Est Gar Asset - PUT" ;
        WSsyntax "{version}/realEstGarAsset/{providerRegister}" ;
        PATH "{version}/realEstGarAsset/{providerRegister}" PRODUCES APPLICATION_JSON

    WSMETHOD POST AgimInsert DESCRIPTION "Real Est Gar Asset - Post" ;
        WSsyntax "{version}/realEstGarAsset" ;
        PATH "{version}/realEstGarAsset" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE AgimDelete DESCRIPTION "Real Est Gar Asset - Delete" ;
        WSsyntax "{version}/realEstGarAsset/{providerRegister}" ;
        PATH "{version}/realEstGarAsset/{providerRegister}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8ET10 - Profits And Losses
    WSMETHOD GET LcprCollection DESCRIPTION "Profits And Losses - Get Collection" ;
        WSsyntax "{version}/profitsAndLosses" ;
        PATH "{version}/profitsAndLosses" PRODUCES APPLICATION_JSON

    WSMETHOD GET LcprSingle DESCRIPTION "Profits And Losses - Get Single" ;
        WSsyntax "{version}/profitsAndLosses/{accountCode}" ;
        PATH "{version}/profitsAndLosses/{accountCode}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT LcprUpdate DESCRIPTION "Profits And Losses - PUT" ;
        WSsyntax "{version}/profitsAndLosses/{accountCode}" ;
        PATH "{version}/profitsAndLosses/{accountCode}" PRODUCES APPLICATION_JSON

    WSMETHOD POST LcprInsert DESCRIPTION "Profits And Losses - Post" ;
        WSsyntax "{version}/profitsAndLosses" ;
        PATH "{version}/profitsAndLosses" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE LcprDelete DESCRIPTION "Profits And Losses - Delete" ;
        WSsyntax "{version}/profitsAndLosses/{accountCode}" ;
        PATH "{version}/profitsAndLosses/{accountCode}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8FT10 - Active Balance Age
    WSMETHOD GET SaidCollection DESCRIPTION "Active Balance Age - Get Collection" ;
        WSsyntax "{version}/activeBalanceAge" ;
        PATH "{version}/activeBalanceAge" PRODUCES APPLICATION_JSON

    WSMETHOD GET SaidSingle DESCRIPTION "Active Balance Age - Get Single" ;
        WSsyntax "{version}/activeBalanceAge/{financialDueDate}" ;
        PATH "{version}/activeBalanceAge/{financialDueDate}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT SaidUpdate DESCRIPTION "Active Balance Age - PUT" ;
        WSsyntax "{version}/activeBalanceAge/{financialDueDate}" ;
        PATH "{version}/activeBalanceAge/{financialDueDate}" PRODUCES APPLICATION_JSON

    WSMETHOD POST SaidInsert DESCRIPTION "Active Balance Age - Post" ;
        WSsyntax "{version}/activeBalanceAge" ;
        PATH "{version}/activeBalanceAge" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE SaidDelete DESCRIPTION "Active Balance Age - Delete" ;
        WSsyntax "{version}/activeBalanceAge/{financialDueDate}" ;
        PATH "{version}/activeBalanceAge/{financialDueDate}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8GT10 - Liability Balance Age
    WSMETHOD GET SpidCollection DESCRIPTION "Liability Balance Age - Get Collection" ;
        WSsyntax "{version}/liabilityBalanceAge" ;
        PATH "{version}/liabilityBalanceAge" PRODUCES APPLICATION_JSON

    WSMETHOD GET SpidSingle DESCRIPTION "Liability Balance Age - Get Single" ;
        WSsyntax "{version}/liabilityBalanceAge/{financialDueDate}" ;
        PATH "{version}/liabilityBalanceAge/{financialDueDate}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT SpidUpdate DESCRIPTION "Liability Balance Age - PUT" ;
        WSsyntax "{version}/liabilityBalanceAge/{financialDueDate}" ;
        PATH "{version}/liabilityBalanceAge/{financialDueDate}" PRODUCES APPLICATION_JSON

    WSMETHOD POST SpidInsert DESCRIPTION "Liability Balance Age - Post" ;
        WSsyntax "{version}/liabilityBalanceAge" ;
        PATH "{version}/liabilityBalanceAge" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE SpidDelete DESCRIPTION "Liability Balance Age - Delete" ;
        WSsyntax "{version}/liabilityBalanceAge/{financialDueDate}" ;
        PATH "{version}/liabilityBalanceAge/{financialDueDate}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8HT10 - Cash Flow
    WSMETHOD GET FlcxCollection DESCRIPTION "Cash Flow - Get Collection" ;
        WSsyntax "{version}/cashFlow" ;
        PATH "{version}/cashFlow" PRODUCES APPLICATION_JSON

    WSMETHOD GET FlcxSingle DESCRIPTION "Cash Flow - Get Single" ;
        WSsyntax "{version}/cashFlow/{cashFlowCode}" ;
        PATH "{version}/cashFlow/{cashFlowCode}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT FlcxUpdate DESCRIPTION "Cash Flow - PUT" ;
        WSsyntax "{version}/cashFlow/{cashFlowCode}" ;
        PATH "{version}/cashFlow/{cashFlowCode}" PRODUCES APPLICATION_JSON

    WSMETHOD POST FlcxInsert DESCRIPTION "Cash Flow - Post" ;
        WSsyntax "{version}/cashFlow" ;
        PATH "{version}/cashFlow" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE FlcxDelete DESCRIPTION "Cash Flow - Delete" ;
        WSsyntax "{version}/cashFlow/{cashFlowCode}" ;
        PATH "{version}/cashFlow/{cashFlowCode}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8IT10 - Assistance Coverage
    WSMETHOD GET CoasCollection DESCRIPTION "Assistance Coverage - Get Collection" ;
        WSsyntax "{version}/assistanceCoverage" ;
        PATH "{version}/assistanceCoverage" PRODUCES APPLICATION_JSON

    WSMETHOD GET CoasSingle DESCRIPTION "Assistance Coverage - Get Single" ;
        WSsyntax "{version}/assistanceCoverage/{typeOfPlan}" ;
        PATH "{version}/assistanceCoverage/{typeOfPlan}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT CoasUpdate DESCRIPTION "Assistance Coverage - PUT" ;
        WSsyntax "{version}/assistanceCoverage/{typeOfPlan}" ;
        PATH "{version}/assistanceCoverage/{typeOfPlan}" PRODUCES APPLICATION_JSON

    WSMETHOD POST CoasInsert DESCRIPTION "Assistance Coverage - Post" ;
        WSsyntax "{version}/assistanceCoverage" ;
        PATH "{version}/assistanceCoverage" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE CoasDelete DESCRIPTION "Assistance Coverage - Delete" ;
        WSsyntax "{version}/assistanceCoverage/{typeOfPlan}" ;
        PATH "{version}/assistanceCoverage/{typeOfPlan}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8JT10 - Prov Net Sin Ev Pesl
    WSMETHOD GET PeslCollection DESCRIPTION "Prov Net Sin Ev Pesl - Get Collection" ;
        WSsyntax "{version}/provNetSinEvPesl" ;
        PATH "{version}/provNetSinEvPesl" PRODUCES APPLICATION_JSON

    WSMETHOD GET PeslSingle DESCRIPTION "Prov Net Sin Ev Pesl - Get Single" ;
        WSsyntax "{version}/provNetSinEvPesl/{commitmentYear}" ;
        PATH "{version}/provNetSinEvPesl/{commitmentYear}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT PeslUpdate DESCRIPTION "Prov Net Sin Ev Pesl - PUT" ;
        WSsyntax "{version}/provNetSinEvPesl/{commitmentYear}" ;
        PATH "{version}/provNetSinEvPesl/{commitmentYear}" PRODUCES APPLICATION_JSON

    WSMETHOD POST PeslInsert DESCRIPTION "Prov Net Sin Ev Pesl - Post" ;
        WSsyntax "{version}/provNetSinEvPesl" ;
        PATH "{version}/provNetSinEvPesl" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE PeslDelete DESCRIPTION "Prov Net Sin Ev Pesl - Delete" ;
        WSsyntax "{version}/provNetSinEvPesl/{commitmentYear}" ;
        PATH "{version}/provNetSinEvPesl/{commitmentYear}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8KT10 - Contract Consolidation
    WSMETHOD GET AgcnCollection DESCRIPTION "Contract Consolidation - Get Collection" ;
        WSsyntax "{version}/contractConsolidation" ;
        PATH "{version}/contractConsolidation" PRODUCES APPLICATION_JSON

    WSMETHOD GET AgcnSingle DESCRIPTION "Contract Consolidation - Get Single" ;
        WSsyntax "{version}/contractConsolidation/{riskPool}" ;
        PATH "{version}/contractConsolidation/{riskPool}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT AgcnUpdate DESCRIPTION "Contract Consolidation - PUT" ;
        WSsyntax "{version}/contractConsolidation/{riskPool}" ;
        PATH "{version}/contractConsolidation/{riskPool}" PRODUCES APPLICATION_JSON

    WSMETHOD POST AgcnInsert DESCRIPTION "Contract Consolidation - Post" ;
        WSsyntax "{version}/contractConsolidation" ;
        PATH "{version}/contractConsolidation" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE AgcnDelete DESCRIPTION "Contract Consolidation - Delete" ;
        WSsyntax "{version}/contractConsolidation/{riskPool}" ;
        PATH "{version}/contractConsolidation/{riskPool}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8LT10 - Indemnifiable Events
    WSMETHOD GET EvinCollection DESCRIPTION "Indemnifiable Events - Get Collection" ;
        WSsyntax "{version}/indemnifiableEvents" ;
        PATH "{version}/indemnifiableEvents" PRODUCES APPLICATION_JSON

    WSMETHOD GET EvinSingle DESCRIPTION "Indemnifiable Events - Get Single" ;
        WSsyntax "{version}/indemnifiableEvents/{eventCodeAns}" ;
        PATH "{version}/indemnifiableEvents/{eventCodeAns}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT EvinUpdate DESCRIPTION "Indemnifiable Events - PUT" ;
        WSsyntax "{version}/indemnifiableEvents/{eventCodeAns}" ;
        PATH "{version}/indemnifiableEvents/{eventCodeAns}" PRODUCES APPLICATION_JSON

    WSMETHOD POST EvinInsert DESCRIPTION "Indemnifiable Events - Post" ;
        WSsyntax "{version}/indemnifiableEvents" ;
        PATH "{version}/indemnifiableEvents" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE EvinDelete DESCRIPTION "Indemnifiable Events - Delete" ;
        WSsyntax "{version}/indemnifiableEvents/{eventCodeAns}" ;
        PATH "{version}/indemnifiableEvents/{eventCodeAns}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8MT10 - Operators
    WSMETHOD GET OperCollection DESCRIPTION "Operators - Get Collection" ;
        WSsyntax "{version}/operators" ;
        PATH "{version}/operators" PRODUCES APPLICATION_JSON

    WSMETHOD GET OperSingle DESCRIPTION "Operators - Get Single" ;
        WSsyntax "{version}/operators/{operatorCnpj}" ;
        PATH "{version}/operators/{operatorCnpj}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT OperUpdate DESCRIPTION "Operators - PUT" ;
        WSsyntax "{version}/operators/{operatorCnpj}" ;
        PATH "{version}/operators/{operatorCnpj}" PRODUCES APPLICATION_JSON

    WSMETHOD POST OperInsert DESCRIPTION "Operators - Post" ;
        WSsyntax "{version}/operators" ;
        PATH "{version}/operators" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE OperDelete DESCRIPTION "Operators - Delete" ;
        WSsyntax "{version}/operators/{operatorCnpj}" ;
        PATH "{version}/operators/{operatorCnpj}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8NT10 - Representatives
    WSMETHOD GET ReprCollection DESCRIPTION "Representatives - Get Collection" ;
        WSsyntax "{version}/representatives" ;
        PATH "{version}/representatives" PRODUCES APPLICATION_JSON

    WSMETHOD GET ReprSingle DESCRIPTION "Representatives - Get Single" ;
        WSsyntax "{version}/representatives/{registrationOfIndividua}" ;
        PATH "{version}/representatives/{registrationOfIndividua}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT ReprUpdate DESCRIPTION "Representatives - PUT" ;
        WSsyntax "{version}/representatives/{registrationOfIndividua}" ;
        PATH "{version}/representatives/{registrationOfIndividua}" PRODUCES APPLICATION_JSON

    WSMETHOD POST ReprInsert DESCRIPTION "Representatives - Post" ;
        WSsyntax "{version}/representatives" ;
        PATH "{version}/representatives" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE ReprDelete DESCRIPTION "Representatives - Delete" ;
        WSsyntax "{version}/representatives/{registrationOfIndividua}" ;
        PATH "{version}/representatives/{registrationOfIndividua}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8ST10 - Shareholders
    WSMETHOD GET AcioCollection DESCRIPTION "Shareholders - Get Collection" ;
        WSsyntax "{version}/shareholders" ;
        PATH "{version}/shareholders" PRODUCES APPLICATION_JSON

    WSMETHOD GET AcioSingle DESCRIPTION "Shareholders - Get Single" ;
        WSsyntax "{version}/shareholders/{shareholderSCpfCnpj}" ;
        PATH "{version}/shareholders/{shareholderSCpfCnpj}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT AcioUpdate DESCRIPTION "Shareholders - PUT" ;
        WSsyntax "{version}/shareholders/{shareholderSCpfCnpj}" ;
        PATH "{version}/shareholders/{shareholderSCpfCnpj}" PRODUCES APPLICATION_JSON

    WSMETHOD POST AcioInsert DESCRIPTION "Shareholders - Post" ;
        WSsyntax "{version}/shareholders" ;
        PATH "{version}/shareholders" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE AcioDelete DESCRIPTION "Shareholders - Delete" ;
        WSsyntax "{version}/shareholders/{shareholderSCpfCnpj}" ;
        PATH "{version}/shareholders/{shareholderSCpfCnpj}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8TT10 - Controlled Affiliates
    WSMETHOD GET ColiCollection DESCRIPTION "Controlled Affiliates - Get Collection" ;
        WSsyntax "{version}/controlledAffiliates" ;
        PATH "{version}/controlledAffiliates" PRODUCES APPLICATION_JSON

    WSMETHOD GET ColiSingle DESCRIPTION "Controlled Affiliates - Get Single" ;
        WSsyntax "{version}/controlledAffiliates/{legalEntityNatRegister}" ;
        PATH "{version}/controlledAffiliates/{legalEntityNatRegister}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT ColiUpdate DESCRIPTION "Controlled Affiliates - PUT" ;
        WSsyntax "{version}/controlledAffiliates/{legalEntityNatRegister}" ;
        PATH "{version}/controlledAffiliates/{legalEntityNatRegister}" PRODUCES APPLICATION_JSON

    WSMETHOD POST ColiInsert DESCRIPTION "Controlled Affiliates - Post" ;
        WSsyntax "{version}/controlledAffiliates" ;
        PATH "{version}/controlledAffiliates" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE ColiDelete DESCRIPTION "Controlled Affiliates - Delete" ;
        WSsyntax "{version}/controlledAffiliates/{legalEntityNatRegister}" ;
        PATH "{version}/controlledAffiliates/{legalEntityNatRegister}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8WT10 - List Of Cities
    WSMETHOD GET MuniCollection DESCRIPTION "List Of Cities - Get Collection" ;
        WSsyntax "{version}/listOfCities" ;
        PATH "{version}/listOfCities" PRODUCES APPLICATION_JSON

    WSMETHOD GET MuniSingle DESCRIPTION "List Of Cities - Get Single" ;
        WSsyntax "{version}/listOfCities/{stateAcronym}" ;
        PATH "{version}/listOfCities/{stateAcronym}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT MuniUpdate DESCRIPTION "List Of Cities - PUT" ;
        WSsyntax "{version}/listOfCities/{stateAcronym}" ;
        PATH "{version}/listOfCities/{stateAcronym}" PRODUCES APPLICATION_JSON

    WSMETHOD POST MuniInsert DESCRIPTION "List Of Cities - Post" ;
        WSsyntax "{version}/listOfCities" ;
        PATH "{version}/listOfCities" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE MuniDelete DESCRIPTION "List Of Cities - Delete" ;
        WSsyntax "{version}/listOfCities/{stateAcronym}" ;
        PATH "{version}/listOfCities/{stateAcronym}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8XT10 - Charts
    WSMETHOD GET QdrsCollection DESCRIPTION "Charts - Get Collection" ;
        WSsyntax "{version}/charts" ;
        PATH "{version}/charts" PRODUCES APPLICATION_JSON

    WSMETHOD GET QdrsSingle DESCRIPTION "Charts - Get Single" ;
        WSsyntax "{version}/charts/{diopsChart}" ;
        PATH "{version}/charts/{diopsChart}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT QdrsUpdate DESCRIPTION "Charts - PUT" ;
        WSsyntax "{version}/charts/{diopsChart}" ;
        PATH "{version}/charts/{diopsChart}" PRODUCES APPLICATION_JSON

    WSMETHOD POST QdrsInsert DESCRIPTION "Charts - Post" ;
        WSsyntax "{version}/charts" ;
        PATH "{version}/charts" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE QdrsDelete DESCRIPTION "Charts - Delete" ;
        WSsyntax "{version}/charts/{diopsChart}" ;
        PATH "{version}/charts/{diopsChart}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8YT10 - Persons Responsible
    WSMETHOD GET RespCollection DESCRIPTION "Persons Responsible - Get Collection" ;
        WSsyntax "{version}/personsResponsible" ;
        PATH "{version}/personsResponsible" PRODUCES APPLICATION_JSON

    WSMETHOD GET RespSingle DESCRIPTION "Persons Responsible - Get Single" ;
        WSsyntax "{version}/personsResponsible/{responsibilityType}" ;
        PATH "{version}/personsResponsible/{responsibilityType}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT RespUpdate DESCRIPTION "Persons Responsible - PUT" ;
        WSsyntax "{version}/personsResponsible/{responsibilityType}" ;
        PATH "{version}/personsResponsible/{responsibilityType}" PRODUCES APPLICATION_JSON

    WSMETHOD POST RespInsert DESCRIPTION "Persons Responsible - Post" ;
        WSsyntax "{version}/personsResponsible" ;
        PATH "{version}/personsResponsible" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE RespDelete DESCRIPTION "Persons Responsible - Delete" ;
        WSsyntax "{version}/personsResponsible/{responsibilityType}" ;
        PATH "{version}/personsResponsible/{responsibilityType}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8ZT10 - Premises
    WSMETHOD GET DepnCollection DESCRIPTION "Premises - Get Collection" ;
        WSsyntax "{version}/premises" ;
        PATH "{version}/premises" PRODUCES APPLICATION_JSON

    WSMETHOD GET DepnSingle DESCRIPTION "Premises - Get Single" ;
        WSsyntax "{version}/premises/{legalEntityNatRegister}" ;
        PATH "{version}/premises/{legalEntityNatRegister}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT DepnUpdate DESCRIPTION "Premises - PUT" ;
        WSsyntax "{version}/premises/{legalEntityNatRegister}" ;
        PATH "{version}/premises/{legalEntityNatRegister}" PRODUCES APPLICATION_JSON

    WSMETHOD POST DepnInsert DESCRIPTION "Premises - Post" ;
        WSsyntax "{version}/premises" ;
        PATH "{version}/premises" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE DepnDelete DESCRIPTION "Premises - Delete" ;
        WSsyntax "{version}/premises/{legalEntityNatRegister}" ;
        PATH "{version}/premises/{legalEntityNatRegister}" PRODUCES APPLICATION_JSON

    // Metodos da entidade BUPT10 - Stipulated Contracts
    WSMETHOD GET CoesCollection DESCRIPTION "Stipulated Contracts - Get Collection" ;
        WSsyntax "{version}/stipulatedContracts" ;
        PATH "{version}/stipulatedContracts" PRODUCES APPLICATION_JSON

    WSMETHOD GET CoesSingle DESCRIPTION "Stipulated Contracts - Get Single" ;
        WSsyntax "{version}/stipulatedContracts/{operatorRecordInAns}" ;
        PATH "{version}/stipulatedContracts/{operatorRecordInAns}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT CoesUpdate DESCRIPTION "Stipulated Contracts - PUT" ;
        WSsyntax "{version}/stipulatedContracts/{operatorRecordInAns}" ;
        PATH "{version}/stipulatedContracts/{operatorRecordInAns}" PRODUCES APPLICATION_JSON

    WSMETHOD POST CoesInsert DESCRIPTION "Stipulated Contracts - Post" ;
        WSsyntax "{version}/stipulatedContracts" ;
        PATH "{version}/stipulatedContracts" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE CoesDelete DESCRIPTION "Stipulated Contracts - Delete" ;
        WSsyntax "{version}/stipulatedContracts/{operatorRecordInAns}" ;
        PATH "{version}/stipulatedContracts/{operatorRecordInAns}" PRODUCES APPLICATION_JSON

    // Metodos da entidade BUWT10 - Cooper Check Accnt
    WSMETHOD GET CcopCollection DESCRIPTION "Cooper Check Accnt - Get Collection" ;
        WSsyntax "{version}/cooperCheckAccnt" ;
        PATH "{version}/cooperCheckAccnt" PRODUCES APPLICATION_JSON

    WSMETHOD GET CcopSingle DESCRIPTION "Cooper Check Accnt - Get Single" ;
        WSsyntax "{version}/cooperCheckAccnt/{taxType}" ;
        PATH "{version}/cooperCheckAccnt/{taxType}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT CcopUpdate DESCRIPTION "Cooper Check Accnt - PUT" ;
        WSsyntax "{version}/cooperCheckAccnt/{taxType}" ;
        PATH "{version}/cooperCheckAccnt/{taxType}" PRODUCES APPLICATION_JSON

    WSMETHOD POST CcopInsert DESCRIPTION "Cooper Check Accnt - Post" ;
        WSsyntax "{version}/cooperCheckAccnt" ;
        PATH "{version}/cooperCheckAccnt" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE CcopDelete DESCRIPTION "Cooper Check Accnt - Delete" ;
        WSsyntax "{version}/cooperCheckAccnt/{taxType}" ;
        PATH "{version}/cooperCheckAccnt/{taxType}" PRODUCES APPLICATION_JSON

    // Metodos da entidade BUYT10 - Liability Tax Accnt
    WSMETHOD GET PactCollection DESCRIPTION "Liability Tax Accnt - Get Collection" ;
        WSsyntax "{version}/liabilityTaxAccnt" ;
        PATH "{version}/liabilityTaxAccnt" PRODUCES APPLICATION_JSON

    WSMETHOD GET PactSingle DESCRIPTION "Liability Tax Accnt - Get Single" ;
        WSsyntax "{version}/liabilityTaxAccnt/{accountCode}" ;
        PATH "{version}/liabilityTaxAccnt/{accountCode}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT PactUpdate DESCRIPTION "Liability Tax Accnt - PUT" ;
        WSsyntax "{version}/liabilityTaxAccnt/{accountCode}" ;
        PATH "{version}/liabilityTaxAccnt/{accountCode}" PRODUCES APPLICATION_JSON

    WSMETHOD POST PactInsert DESCRIPTION "Liability Tax Accnt - Post" ;
        WSsyntax "{version}/liabilityTaxAccnt" ;
        PATH "{version}/liabilityTaxAccnt" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE PactDelete DESCRIPTION "Liability Tax Accnt - Delete" ;
        WSsyntax "{version}/liabilityTaxAccnt/{accountCode}" ;
        PATH "{version}/liabilityTaxAccnt/{accountCode}" PRODUCES APPLICATION_JSON

    // Metodos da entidade BVST10 - Trans Contr Amt Segr
    WSMETHOD GET SmcrCollection DESCRIPTION "Trans Contr Amt Segr - Get Collection" ;
        WSsyntax "{version}/transContrAmtSegr" ;
        PATH "{version}/transContrAmtSegr" PRODUCES APPLICATION_JSON

    WSMETHOD GET SmcrSingle DESCRIPTION "Trans Contr Amt Segr - Get Single" ;
        WSsyntax "{version}/transContrAmtSegr/{benefitAdmOperCode}" ;
        PATH "{version}/transContrAmtSegr/{benefitAdmOperCode}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT SmcrUpdate DESCRIPTION "Trans Contr Amt Segr - PUT" ;
        WSsyntax "{version}/transContrAmtSegr/{benefitAdmOperCode}" ;
        PATH "{version}/transContrAmtSegr/{benefitAdmOperCode}" PRODUCES APPLICATION_JSON

    WSMETHOD POST SmcrInsert DESCRIPTION "Trans Contr Amt Segr - Post" ;
        WSsyntax "{version}/transContrAmtSegr" ;
        PATH "{version}/transContrAmtSegr" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE SmcrDelete DESCRIPTION "Trans Contr Amt Segr - Delete" ;
        WSsyntax "{version}/transContrAmtSegr/{benefitAdmOperCode}" ;
        PATH "{version}/transContrAmtSegr/{benefitAdmOperCode}" PRODUCES APPLICATION_JSON

    WSMETHOD POST B2VInsert DESCRIPTION "monitOtherRemuneration - Post" ;
        WSsyntax "{version}/monitOtherRemuneration" ;
        PATH "{version}/monitOtherRemuneration" PRODUCES APPLICATION_JSON

    WSMETHOD POST B2XInsert DESCRIPTION "monitPresetValue - Post" ;
        WSsyntax "{version}/monitPresetValue" ;
        PATH "{version}/monitPresetValue" PRODUCES APPLICATION_JSON

    WSMETHOD POST BraInsert DESCRIPTION "monitForm - Post" ;
        WSsyntax "{version}/monitForm" ;
        PATH "{version}/monitForm" PRODUCES APPLICATION_JSON

    WSMETHOD POST Bw8Insert DESCRIPTION "monitDirectSupply - Post" ;
        WSsyntax "{version}/monitDirectSupply" ;
        PATH "{version}/monitDirectSupply" PRODUCES APPLICATION_JSON

    // Metodos da entidade B2YT10 - Analytic Dmed Expenses
    WSMETHOD GET B2YCollection DESCRIPTION "Analytic Dmed Expenses - Get Collection" ;
        WSsyntax "{version}/analyticDmedExpenses" ;
        PATH "{version}/analyticDmedExpenses" PRODUCES APPLICATION_JSON

    WSMETHOD GET B2YSingle DESCRIPTION "Analytic Dmed Expenses - Get Single" ;
        WSsyntax "{version}/analyticDmedExpenses/{expenseKey}" ;
        PATH "{version}/analyticDmedExpenses/{expenseKey}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT B2YUpdate DESCRIPTION "Analytic Dmed Expenses - PUT" ;
        WSsyntax "{version}/analyticDmedExpenses/{expenseKey}" ;
        PATH "{version}/analyticDmedExpenses/{expenseKey}" PRODUCES APPLICATION_JSON

    WSMETHOD POST B2YInsert DESCRIPTION "Analytic Dmed Expenses - Post" ;
        WSsyntax "{version}/analyticDmedExpenses" ;
        PATH "{version}/analyticDmedExpenses" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE B2YDelete DESCRIPTION "Analytic Dmed Expenses - Delete" ;
        WSsyntax "{version}/analyticDmedExpenses/{expenseKey}" ;
        PATH "{version}/analyticDmedExpenses/{expenseKey}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B6N - Persons In Charge
    WSMETHOD GET B6NCollection DESCRIPTION "Persons In Charge - Get Collection" ;
        WSsyntax "{version}/personsInCharge" ;
        PATH "{version}/personsInCharge" PRODUCES APPLICATION_JSON

    WSMETHOD GET B6NSingle DESCRIPTION "Persons In Charge - Get Single" ;
        WSsyntax "{version}/personsInCharge/{uniqueKey}" ;
        PATH "{version}/personsInCharge/{uniqueKey}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT B6NUpdate DESCRIPTION "Persons In Charge - PUT" ;
        WSsyntax "{version}/personsInCharge/{uniqueKey}" ;
        PATH "{version}/personsInCharge/{uniqueKey}" PRODUCES APPLICATION_JSON

    WSMETHOD POST B6NInsert DESCRIPTION "Persons In Charge - Post" ;
        WSsyntax "{version}/personsInCharge" ;
        PATH "{version}/personsInCharge" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE B6NDelete DESCRIPTION "Persons In Charge - Delete" ;
        WSsyntax "{version}/personsInCharge/{uniqueKey}" ;
        PATH "{version}/personsInCharge/{uniqueKey}" PRODUCES APPLICATION_JSON

    // Metodos da entidade B8M - Operators Diops
    WSMETHOD GET B8MCollection DESCRIPTION "Operators Diops - Get Collection" ;
        WSsyntax "{version}/operatorsDiops" ;
        PATH "{version}/operatorsDiops" PRODUCES APPLICATION_JSON

    WSMETHOD GET B8MSingle DESCRIPTION "Operators Diops - Get Single" ;
        WSsyntax "{version}/operatorsDiops/{uniqueKey}" ;
        PATH "{version}/operatorsDiops/{uniqueKey}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT B8MUpdate DESCRIPTION "Operators Diops - PUT" ;
        WSsyntax "{version}/operatorsDiops/{uniqueKey}" ;
        PATH "{version}/operatorsDiops/{uniqueKey}" PRODUCES APPLICATION_JSON

    WSMETHOD POST B8MInsert DESCRIPTION "Operators Diops - Post" ;
        WSsyntax "{version}/operatorsDiops" ;
        PATH "{version}/operatorsDiops" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE B8MDelete DESCRIPTION "Operators Diops - Delete" ;
        WSsyntax "{version}/operatorsDiops/{uniqueKey}" ;
        PATH "{version}/operatorsDiops/{uniqueKey}" PRODUCES APPLICATION_JSON

    // Metodos da entidade BI0 - Idss Indicators
    WSMETHOD GET Bi0Collection DESCRIPTION "Idss Indicators - Get Collection" ;
        WSsyntax "{version}/idssIndicators" ;
        PATH "{version}/idssIndicators" PRODUCES APPLICATION_JSON

    WSMETHOD GET Bi0Single DESCRIPTION "Idss Indicators - Get Single" ;
        WSsyntax "{version}/idssIndicators/{uniqueKey}" ;
        PATH "{version}/idssIndicators/{uniqueKey}" PRODUCES APPLICATION_JSON

    WSMETHOD PUT Bi0Update DESCRIPTION "Idss Indicators - PUT" ;
        WSsyntax "{version}/idssIndicators/{uniqueKey}" ;
        PATH "{version}/idssIndicators/{uniqueKey}" PRODUCES APPLICATION_JSON

    WSMETHOD POST Bi0Insert DESCRIPTION "Idss Indicators - Post" ;
        WSsyntax "{version}/idssIndicators" ;
        PATH "{version}/idssIndicators" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE Bi0Delete DESCRIPTION "Idss Indicators - Delete" ;
        WSsyntax "{version}/idssIndicators/{uniqueKey}" ;
        PATH "{version}/idssIndicators/{uniqueKey}" PRODUCES APPLICATION_JSON

END WSRESTFUL


WSMETHOD GET produto PATHPARAM healthInsuranceCode QUERYPARAM healthInsurerCode, fields WSSERVICE HealthCare

    Default self:healthInsurerCode   := ""
    Default self:healthInsuranceCode := ""
    Default self:fields              := ""
    Default self:page                := "1"
    Default self:pageSize            := "1"

    oRequest := RestCenProd():New(self, "product-get_product")

    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:applyFilter(SINGLE)
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:buscar(BUSCA)
        oRequest:procCenProd(SINGLE)
    endif

    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.

WSMETHOD GET prodTodos QUERYPARAM healthInsurerCode, page, pageSize, fields, order, expand,;
    healthInsurerCode,;
    code,;
    wayofhiring,;
    marketsegmentation,;
    coveragearea,;
    description ,;
    description;
    WSSERVICE HealthCare

Default self:page := "1"
Default self:pageSize := "20"
Default self:fields := ""
Default self:order := ""
Default self:code := ""
Default self:healthInsurerCode := ""
Default self:wayofhiring := ""
Default self:marketsegmentation := ""
Default self:coveragearea := ""
Default self:description := ""

oRequest := RestCenProd():New(self, "product-get_product")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyExpand()
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procCenProd(ALL)
endif
oRequest:endRequest()
oRequest:destroy()

FreeObj(oRequest)
oRequest := Nil

DelClassIntf()

Return .T.

WSMETHOD PUT alteraProduto PATHPARAM healthInsuranceCode QUERYPARAM healthInsurerCode WSSERVICE HealthCare

    Local oRequest                   := nil
    Default self:healthInsurerCode   := ""
    Default self:healthInsuranceCode := ""
    Default self:page                := "1"
    Default self:pageSize            := "1"

    oRequest := RestCenProd():New(self, "product-put_altProduct")

    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyPageSize()
        oRequest:procAltCenProd()
    endif
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.


WSMETHOD POST insereProduto WSSERVICE HealthCare

    Local oRequest := nil
    Default self:healthInsurerCode   := ""
    Default self:healthInsuranceCode := ""
    Default self:page                := "1"
    Default self:pageSize            := "1"

    oRequest := RestCenProd():New(self, "product-post_product")

    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyPageSize()
        oRequest:procInsCenProd()
    endif
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.

WSMETHOD DELETE deleteProduto PATHPARAM healthInsuranceCode QUERYPARAM healthInsurerCode WSSERVICE HealthCare

    Local oRequest                   := nil
    Default self:healthInsurerCode   := ""
    Default self:healthInsuranceCode := ""
    Default self:page                := "1"
    Default self:pageSize            := "1"

    oRequest := RestCenProd():New(self, "product-delete_product")

    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:applyPageSize()
        oRequest:procDelCenProd()
    endif

    oRequest:endRequest()
    oRequest:destroy()

    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.

WSMETHOD GET B3KCollection QUERYPARAM page, pageSize, search, fields, order, expand,;
    healthInsurerCode,;
    codeCco,;
    subscriberId,;
    name,;
    gender,;
    birthdate,;
    effectiveDate,;
    blockDate,;
    stateAbbreviation,;
    healthInsuranceCode,;
    unblockDate,;
    pisPasep,;
    mothersName,;
    declarationOfLiveBirth,;
    nationalHealthCard,;
    address,;
    houseNumbering,;
    addressComplement,;
    district,;
    cityCode,;
    cityCodeResidence,;
    ZIPCode,;
    typeOfAddress,;
    residentAbroad,;
    holderRelationship,;
    holderSubscriberId,;
    codeSusep,;
    codeSCPA,;
    partialCoverage,;
    guarantorCNPJ,;
    guarantorCEI,;
    holderCPF,;
    motherCPF,;
    sponsorCPF,;
    excludedItems,;
    skipRuleName,;
    skipRuleMothersName,;
    blockingReason,;
    statusAns,;
    caepf,;
    portabilityPlanCode,;
    guarantorName;
    WSSERVICE healthcare

Local oRequest := CenReqB3K():New(self, "b3k-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:search   := ""
Default self:fields   := ""
Default self:order    := ""
Default self:uniqueKey := ""

Default self:healthInsurerCode := ""
Default self:codeCco := ""
Default self:subscriberId := ""
Default self:name := ""
Default self:gender := ""
Default self:birthdate := ""
Default self:effectiveDate := ""
Default self:blockDate := ""
Default self:stateAbbreviation := ""
Default self:healthInsuranceCode := ""
Default self:unblockDate := ""
Default self:pisPasep := ""
Default self:mothersName := ""
Default self:declarationOfLiveBirth := ""
Default self:nationalHealthCard := ""
Default self:address := ""
Default self:houseNumbering := ""
Default self:addressComplement := ""
Default self:district := ""
Default self:cityCode := ""
Default self:cityCodeResidence := ""
Default self:ZIPCode := ""
Default self:typeOfAddress := ""
Default self:residentAbroad := ""
Default self:holderRelationship := ""
Default self:holderSubscriberId := ""
Default self:codeSusep := ""
Default self:codeSCPA := ""
Default self:partialCoverage := ""
Default self:guarantorCNPJ := ""
Default self:guarantorCEI := ""
Default self:holderCPF := ""
Default self:motherCPF := ""
Default self:sponsorCPF := ""
Default self:excludedItems := ""
Default self:skipRuleName := ""
Default self:skipRuleMothersName := ""
Default self:blockingReason := ""
Default self:statusAns := ""
Default self:caepf := ""
Default self:portabilityPlanCode := ""
Default self:guarantorName := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyExpand(self:expand)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:applySearch(self:search)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET B3KSingle PATHPARAM;
    uniqueKey;
    QUERYPARAM;
    expand,;
    fields,;
    healthInsurerCode,;
    codeCco;
    WSSERVICE healthcare

Local oRequest := CenReqB3K():New(self, "b3k-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyExpand(self:expand)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT altBeneficiario PATHPARAM subscriberId QUERYPARAM healthInsurerCode, codeCCO WSSERVICE HealthCare

    Local oRequest                 := nil
    Default self:healthInsurerCode := ""
    Default self:subscriberId      := ""
    Default self:codeCco           := ""
    Default self:page              := "1"
    Default self:pageSize          := "1"

    oRequest := RestCenBenefi():New(self, "beneficiary-put_altbeneficiary")

    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyPageSize()
        oRequest:altBenefi()
    endif
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.

WSMETHOD POST cancelBeneficiario QUERYPARAM subscriberId WSSERVICE HealthCare

    Local oRequest                 := nil
    Default self:healthInsurerCode := ""
    Default self:subscriberId      := ""
    Default self:codeCco           := ""
    Default self:page              := "1"
    Default self:pageSize          := "1"

    oRequest := RestCenBenefi():New(self, "beneficiary-put_cancelbeneficiary")

    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyPageSize()
        oRequest:cancelBenefi()
    endif
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.

WSMETHOD POST reactBeneficiario PATHPARAM subscriberId WSSERVICE HealthCare

    Local oRequest                 := nil
    Default self:healthInsurerCode := ""
    Default self:subscriberId      := ""
    Default self:codeCco           := ""
    Default self:page              := "1"
    Default self:pageSize          := "1"

    oRequest := RestCenBenefi():New(self, "beneficiary-put_reactbeneficiary")

    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyPageSize()
        oRequest:reactBenefi()
    endif
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.

WSMETHOD POST changerContractBene PATHPARAM subscriberId WSSERVICE HealthCare

    Local oRequest                 := nil
    Default self:healthInsurerCode := ""
    Default self:subscriberId      := ""
    Default self:codeCco           := ""
    Default self:page              := "1"
    Default self:pageSize          := "1"

    oRequest := RestCenBenefi():New(self, "beneficiary-put_errorbeneficiary")

    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyPageSize()
        oRequest:changContrBene()
    endif
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.



WSMETHOD POST insBeneficiario WSSERVICE HealthCare

    Local oRequest                 := nil
    Default self:fields            := ""
    Default self:healthInsurerCode := ""
    Default self:subscriberId      := ""
    Default self:codeCco           := ""

    Default self:name := ""
    Default self:codeCco := ""
    Default self:healthInsurerCode := ""
    Default self:name := ""
    Default self:gender := ""
    Default self:birthdate := ""
    Default self:healthInsuranceCode := ""
    Default self:pisPasep := ""
    Default self:mothersName := ""
    Default self:address := ""
    Default self:houseNumbering := ""
    Default self:addressComplement := ""
    Default self:district := ""
    Default self:cityCode := ""
    Default self:cityCodeResidence := ""
    Default self:ZIPCode := ""
    Default self:holderRelationship := ""
    Default self:holderSubscriberId := ""
    Default self:codeSusep := ""
    Default self:codeSCPA := ""
    Default self:holderCPF := ""
    Default self:motherCPF := ""
    Default self:sponsorCPF := ""
    Default self:skipRuleName := ""
    Default self:skipRuleMothersName := ""
    Default self:caepf := ""
    Default self:page := "1"
    Default self:pageSize := "1"

    oRequest := RestCenBenefi():New(self, "beneficiary-post_beneficiary")

    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:insCenBenefi()
    endif
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.


WSMETHOD POST insLoteBeneficiario WSSERVICE HealthCare

    Local oRequest        := nil
    Default self:page     := "1"
    Default self:pageSize := "1"

    oRequest := RestCenBenefi():New(self, "beneficiary-post_beneficiary_lote")

    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyPageSize()
        oRequest:insLoteCenBenefi()
    endif

    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.

WSMETHOD DELETE beneDelete PATHPARAM subscriberId QUERYPARAM healthInsurerCode, codeCco WSSERVICE HealthCare

    Local oRequest                 := nil
    Default self:healthInsurerCode := ""
    Default self:subscriberId      := ""
    Default self:codeCco           := ""
    Default self:page              := "1"
    Default self:pageSize          := "1"

    oRequest := RestCenBenefi():New(self, "beneficiary-put_delbeneficiary")

    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:applyFilter(SINGLE)
        oRequest:applyPageSize()
        oRequest:delBenefi()
    endif
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.

WSMETHOD GET allFiles PATHPARAM yearMonthRefer QUERYPARAM healthInsurerCode, page, pageSize, fields, order WSSERVICE HealthCare

    Local oRequest                 := nil
    Default self:page              := "1"
    Default self:pageSize          := "20"
    Default fields                 := ""
    Default self:healthInsurerCode := ""
    Default self:yearMonthRefer    := ""
    Default self:order             := ""
    Default self:page              := "1"
    Default self:pageSize          := "20"

    oRequest := RestCenArqSib():New(self, "files-get_files")

    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:applyFilter(ALL)
        oRequest:applyFields(self:fields)
        oRequest:applyOrder(self:order)
        oRequest:applyExpand()
        oRequest:applyPageSize()
        oRequest:buscar(BUSCA)
        oRequest:procCenArqSib(ALL)
    endif
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.

WSMETHOD GET ccosFromFiles PATHPARAM fileName QUERYPARAM page, pageSize, fields, order, expand,;
    name,;
    subscriberid,;
    codecco;
    WSSERVICE HealthCare

Local oRequest              := nil
Default self:page           := "1"
Default self:pageSize       := "20"
Default self:fields         := ""
Default self:fileName       := ""
Default self:order          := ""
Default self:name           := ""
Default self:subscriberid   := ""
Default self:codecco        := ""

oRequest := RestCenArqSib():New(self, "files-get_files")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(CCOS)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyExpand()
    oRequest:applyPageSize()
    oRequest:buscar(CCOS)  //Busca especifica de ccos
    oRequest:ccosArqSib()
endif
oRequest:endRequest()
oRequest:destroy()

FreeObj(oRequest)
oRequest := Nil

DelClassIntf()

Return .T.


WSMETHOD GET CrcdCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentYear,;
    commitmentCode,;
    ansEventCode,;
    obligationCode,;
    providerRegister,;
    trimester,;
    status,;
    amt1StMthTrimester,;
    amt2NdMthTrimester,;
    amt3RdMthTrimester;
    WSSERVICE healthcare

Local oRequest := CenReqCrcd():New(self, "crcd-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:ansEventCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""

Default self:trimester := ""
Default self:status := ""
Default self:amt1StMthTrimester := ""
Default self:amt2NdMthTrimester := ""
Default self:amt3RdMthTrimester := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET CrcdSingle PATHPARAM;
    ansEventCode;
    QUERYPARAM;
    fields,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqCrcd():New(self, "crcd-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT CrcdUpdate PATHPARAM;
    ansEventCode;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqCrcd():New(self, "crcd-put_update")

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:ansEventCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST CrcdInsert WSSERVICE healthcare

    Local oRequest := CenReqCrcd():New(self, "crcd-post_insert")

    Default self:commitmentYear := ""
    Default self:commitmentCode := ""
    Default self:ansEventCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""

    Default self:trimester := ""
    Default self:status := ""
    Default self:amt1StMthTrimester := ""
    Default self:amt2NdMthTrimester := ""
    Default self:amt3RdMthTrimester := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE CrcdDelete PATHPARAM;
    ansEventCode;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqCrcd():New(self, "crcd-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET PectCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    counterpartCoveragePeri,;
    planType,;
    commitmentYear,;
    valueToExpire,;
    receivedValue,;
    trimester,;
    status,;
    dueValueInArrears,;
    netIssuedValue;
    WSSERVICE healthcare

Local oRequest := CenReqPect():New(self, "pect-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:counterpartCoveragePeri := ""
Default self:planType := ""
Default self:commitmentYear := ""

Default self:valueToExpire := ""
Default self:receivedValue := ""
Default self:trimester := ""
Default self:status := ""
Default self:dueValueInArrears := ""
Default self:netIssuedValue := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET PectSingle PATHPARAM;
    counterpartCoveragePeri;
    QUERYPARAM;
    fields,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    planType,;
    commitmentYear;
    WSSERVICE healthcare

Local oRequest := CenReqPect():New(self, "pect-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT PectUpdate PATHPARAM;
    counterpartCoveragePeri;
    QUERYPARAM;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    planType,;
    commitmentYear;
    WSSERVICE healthcare

Local oRequest := CenReqPect():New(self, "pect-put_update")

Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:counterpartCoveragePeri := ""
Default self:planType := ""
Default self:commitmentYear := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST PectInsert WSSERVICE healthcare

    Local oRequest := CenReqPect():New(self, "pect-post_insert")

    Default self:commitmentCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:counterpartCoveragePeri := ""
    Default self:planType := ""
    Default self:commitmentYear := ""

    Default self:valueToExpire := ""
    Default self:receivedValue := ""
    Default self:trimester := ""
    Default self:status := ""
    Default self:dueValueInArrears := ""
    Default self:netIssuedValue := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE PectDelete PATHPARAM;
    counterpartCoveragePeri;
    QUERYPARAM;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    planType,;
    commitmentYear;
    WSSERVICE healthcare

Local oRequest := CenReqPect():New(self, "pect-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET ObriCollection QUERYPARAM page, pageSize, fields, order, expand,;
    obligationCode,;
    providerRegister,;
    obligationDescription,;
    seasonality,;
    obligationType,;
    activeInactive,;
    dueDateNotification;
    WSSERVICE healthcare

Local oRequest := CenReqObri():New(self, "obri-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:obligationCode := ""
Default self:providerRegister := ""

Default self:obligationDescription := ""
Default self:seasonality := ""
Default self:obligationType := ""
Default self:activeInactive := ""
Default self:dueDateNotification := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET ObriSingle PATHPARAM;
    obligationCode;
    QUERYPARAM;
    fields,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqObri():New(self, "obri-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT ObriUpdate PATHPARAM;
    obligationCode;
    QUERYPARAM;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqObri():New(self, "obri-put_update")

Default self:obligationCode := ""
Default self:providerRegister := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST ObriInsert WSSERVICE healthcare

    Local oRequest := CenReqObri():New(self, "obri-post_insert")

    Default self:obligationCode := ""
    Default self:providerRegister := ""

    Default self:obligationDescription := ""
    Default self:seasonality := ""
    Default self:obligationType := ""
    Default self:activeInactive := ""
    Default self:dueDateNotification := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE ObriDelete PATHPARAM;
    obligationCode;
    QUERYPARAM;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqObri():New(self, "obri-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET CompCollection QUERYPARAM page, pageSize, fields, order, expand,;
    obligationCode,;
    commitmentCode,;
    providerRegister,;
    referenceYear,;
    obligationType,;
    commitmentDueDate,;
    dueDateNotification,;
    trimester,;
    synthetizesBenefit,;
    status;
    WSSERVICE healthcare

Local oRequest := CenReqComp():New(self, "comp-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:obligationCode := ""
Default self:commitmentCode := ""
Default self:providerRegister := ""
Default self:referenceYear := ""
Default self:obligationType := ""

Default self:commitmentDueDate := ""
Default self:dueDateNotification := ""
Default self:trimester := ""
Default self:synthetizesBenefit := ""
Default self:status := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET CompSingle PATHPARAM;
    commitmentCode;
    QUERYPARAM;
    fields,;
    obligationCode,;
    providerRegister,;
    referenceYear,;
    obligationType;
    WSSERVICE healthcare

Local oRequest := CenReqComp():New(self, "comp-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT CompUpdate PATHPARAM;
    commitmentCode;
    QUERYPARAM;
    obligationCode,;
    providerRegister,;
    referenceYear,;
    obligationType;
    WSSERVICE healthcare

Local oRequest := CenReqComp():New(self, "comp-put_update")

Default self:obligationCode := ""
Default self:commitmentCode := ""
Default self:providerRegister := ""
Default self:referenceYear := ""
Default self:obligationType := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST CompInsert WSSERVICE healthcare

    Local oRequest := CenReqComp():New(self, "comp-post_insert")

    Default self:obligationCode := ""
    Default self:commitmentCode := ""
    Default self:providerRegister := ""
    Default self:referenceYear := ""
    Default self:obligationType := ""

    Default self:commitmentDueDate := ""
    Default self:dueDateNotification := ""
    Default self:trimester := ""
    Default self:synthetizesBenefit := ""
    Default self:status := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE CompDelete PATHPARAM;
    commitmentCode;
    QUERYPARAM;
    obligationCode,;
    providerRegister,;
    referenceYear,;
    obligationType;
    WSSERVICE healthcare

Local oRequest := CenReqComp():New(self, "comp-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET FucoCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentYear,;
    commitmentCode,;
    cnpjOrFundAnsRec,;
    obligationCode,;
    providerRegister,;
    fundType,;
    fundName,;
    trimester,;
    creditBalanceOfFund,;
    debitorBalanceOfFund,;
    status;
    WSSERVICE healthcare

Local oRequest := CenReqFuco():New(self, "fuco-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:cnpjOrFundAnsRec := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:fundType := ""

Default self:fundName := ""
Default self:trimester := ""
Default self:creditBalanceOfFund := ""
Default self:debitorBalanceOfFund := ""
Default self:status := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET FucoSingle PATHPARAM;
    fundType;
    QUERYPARAM;
    fields,;
    commitmentYear,;
    commitmentCode,;
    cnpjOrFundAnsRec,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqFuco():New(self, "fuco-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT FucoUpdate PATHPARAM;
    fundType;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    cnpjOrFundAnsRec,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqFuco():New(self, "fuco-put_update")

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:cnpjOrFundAnsRec := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:fundType := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST FucoInsert WSSERVICE healthcare

    Local oRequest := CenReqFuco():New(self, "fuco-post_insert")

    Default self:commitmentYear := ""
    Default self:commitmentCode := ""
    Default self:cnpjOrFundAnsRec := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:fundType := ""

    Default self:fundName := ""
    Default self:trimester := ""
    Default self:creditBalanceOfFund := ""
    Default self:debitorBalanceOfFund := ""
    Default self:status := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE FucoDelete PATHPARAM;
    fundType;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    cnpjOrFundAnsRec,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqFuco():New(self, "fuco-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET MdpcCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    tempRemidNumber,;
    vitRemidNumber,;
    trimester,;
    tempExpSom,;
    vitExpSom,;
    tempRemisSom,;
    vitRemisSom,;
    status;
    WSSERVICE healthcare

Local oRequest := CenReqMdpc():New(self, "mdpc-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""

Default self:tempRemidNumber := ""
Default self:vitRemidNumber := ""
Default self:trimester := ""
Default self:tempExpSom := ""
Default self:vitExpSom := ""
Default self:tempRemisSom := ""
Default self:vitRemisSom := ""
Default self:status := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET MdpcSingle PATHPARAM;
    commitmentCode;
    QUERYPARAM;
    fields,;
    commitmentYear,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqMdpc():New(self, "mdpc-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT MdpcUpdate PATHPARAM;
    commitmentCode;
    QUERYPARAM;
    commitmentYear,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqMdpc():New(self, "mdpc-put_update")

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST MdpcInsert WSSERVICE healthcare

    Local oRequest := CenReqMdpc():New(self, "mdpc-post_insert")

    Default self:commitmentYear := ""
    Default self:commitmentCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""

    Default self:tempRemidNumber := ""
    Default self:vitRemidNumber := ""
    Default self:trimester := ""
    Default self:tempExpSom := ""
    Default self:vitExpSom := ""
    Default self:tempRemisSom := ""
    Default self:vitRemisSom := ""
    Default self:status := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE MdpcDelete PATHPARAM;
    commitmentCode;
    QUERYPARAM;
    commitmentYear,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqMdpc():New(self, "mdpc-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET TeapCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    planType,;
    contractCancelRate,;
    biomTabAdjustment,;
    cashFlowAdjEstimation,;
    utiOfRangesRn632003,;
    estimatedMedicalInflati,;
    ettjInterMethod,;
    averageAdjustmentPerVa,;
    estimatedMaximumAdjustm,;
    trimester,;
    status;
    WSSERVICE healthcare

Local oRequest := CenReqTeap():New(self, "teap-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:planType := ""

Default self:contractCancelRate := ""
Default self:biomTabAdjustment := ""
Default self:cashFlowAdjEstimation := ""
Default self:utiOfRangesRn632003 := ""
Default self:estimatedMedicalInflati := ""
Default self:ettjInterMethod := ""
Default self:averageAdjustmentPerVa := ""
Default self:estimatedMaximumAdjustm := ""
Default self:trimester := ""
Default self:status := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET TeapSingle PATHPARAM;
    planType;
    QUERYPARAM;
    fields,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqTeap():New(self, "teap-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT TeapUpdate PATHPARAM;
    planType;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqTeap():New(self, "teap-put_update")

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:planType := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST TeapInsert WSSERVICE healthcare

    Local oRequest := CenReqTeap():New(self, "teap-post_insert")

    Default self:commitmentYear := ""
    Default self:commitmentCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:planType := ""

    Default self:contractCancelRate := ""
    Default self:biomTabAdjustment := ""
    Default self:cashFlowAdjEstimation := ""
    Default self:utiOfRangesRn632003 := ""
    Default self:estimatedMedicalInflati := ""
    Default self:ettjInterMethod := ""
    Default self:averageAdjustmentPerVa := ""
    Default self:estimatedMaximumAdjustm := ""
    Default self:trimester := ""
    Default self:status := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE TeapDelete PATHPARAM;
    planType;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqTeap():New(self, "teap-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET BlctCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    accountCode,;
    credits,;
    debits,;
    trimester,;
    previousBalance,;
    finalBalance,;
    status;
    WSSERVICE healthcare

Local oRequest := CenReqBlct():New(self, "blct-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:accountCode := ""

Default self:credits := ""
Default self:debits := ""
Default self:trimester := ""
Default self:previousBalance := ""
Default self:finalBalance := ""
Default self:status := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET BlctSingle PATHPARAM;
    accountCode;
    QUERYPARAM;
    fields,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqBlct():New(self, "blct-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT BlctUpdate PATHPARAM;
    accountCode;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqBlct():New(self, "blct-put_update")

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:accountCode := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST BlctInsert WSSERVICE healthcare

    Local oRequest := CenReqBlct():New(self, "blct-post_insert")

    Default self:commitmentYear := ""
    Default self:commitmentCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:accountCode := ""

    Default self:credits := ""
    Default self:debits := ""
    Default self:trimester := ""
    Default self:previousBalance := ""
    Default self:finalBalance := ""
    Default self:status := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE BlctDelete PATHPARAM;
    accountCode;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqBlct():New(self, "blct-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET PlacCollection QUERYPARAM page, pageSize, fields, order, expand,;
    providerRegister,;
    accountCode,;
    validityEndDate,;
    validityStartDate,;
    accountDescription;
    WSSERVICE healthcare

Local oRequest := CenReqPlac():New(self, "plac-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:providerRegister := ""
Default self:accountCode := ""
Default self:validityEndDate := ""
Default self:validityStartDate := ""

Default self:accountDescription := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET PlacSingle PATHPARAM;
    accountCode;
    QUERYPARAM;
    fields,;
    providerRegister,;
    validityEndDate,;
    validityStartDate;
    WSSERVICE healthcare

Local oRequest := CenReqPlac():New(self, "plac-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT PlacUpdate PATHPARAM;
    accountCode;
    QUERYPARAM;
    providerRegister,;
    validityEndDate,;
    validityStartDate;
    WSSERVICE healthcare

Local oRequest := CenReqPlac():New(self, "plac-put_update")

Default self:providerRegister := ""
Default self:accountCode := ""
Default self:validityEndDate := ""
Default self:validityStartDate := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST PlacInsert WSSERVICE healthcare

    Local oRequest := CenReqPlac():New(self, "plac-post_insert")

    Default self:providerRegister := ""
    Default self:accountCode := ""
    Default self:validityEndDate := ""
    Default self:validityStartDate := ""

    Default self:accountDescription := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE PlacDelete PATHPARAM;
    accountCode;
    QUERYPARAM;
    providerRegister,;
    validityEndDate,;
    validityStartDate;
    WSSERVICE healthcare

Local oRequest := CenReqPlac():New(self, "plac-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET AgimCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    realEstateGeneralRegis,;
    commitmentYear,;
    assitance,;
    ownNetwork,;
    trimester,;
    status,;
    validityEndDate,;
    validityStartDate,;
    accountingValue;
    WSSERVICE healthcare

Local oRequest := CenReqAgim():New(self, "agim-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:realEstateGeneralRegis := ""
Default self:commitmentYear := ""

Default self:assitance := ""
Default self:ownNetwork := ""
Default self:trimester := ""
Default self:status := ""
Default self:validityEndDate := ""
Default self:validityStartDate := ""
Default self:accountingValue := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET AgimSingle PATHPARAM;
    providerRegister;
    QUERYPARAM;
    fields,;
    commitmentCode,;
    obligationCode,;
    realEstateGeneralRegis,;
    commitmentYear;
    WSSERVICE healthcare

Local oRequest := CenReqAgim():New(self, "agim-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT AgimUpdate PATHPARAM;
    providerRegister;
    QUERYPARAM;
    commitmentCode,;
    obligationCode,;
    realEstateGeneralRegis,;
    commitmentYear;
    WSSERVICE healthcare

Local oRequest := CenReqAgim():New(self, "agim-put_update")

Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:realEstateGeneralRegis := ""
Default self:commitmentYear := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST AgimInsert WSSERVICE healthcare

    Local oRequest := CenReqAgim():New(self, "agim-post_insert")

    Default self:commitmentCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:realEstateGeneralRegis := ""
    Default self:commitmentYear := ""

    Default self:assitance := ""
    Default self:ownNetwork := ""
    Default self:trimester := ""
    Default self:status := ""
    Default self:validityEndDate := ""
    Default self:validityStartDate := ""
    Default self:accountingValue := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE AgimDelete PATHPARAM;
    providerRegister;
    QUERYPARAM;
    commitmentCode,;
    obligationCode,;
    realEstateGeneralRegis,;
    commitmentYear;
    WSSERVICE healthcare

Local oRequest := CenReqAgim():New(self, "agim-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET LcprCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    accountCode,;
    description,;
    trimester,;
    status,;
    accountingValue;
    WSSERVICE healthcare

Local oRequest := CenReqLcpr():New(self, "lcpr-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:accountCode := ""

Default self:description := ""
Default self:trimester := ""
Default self:status := ""
Default self:accountingValue := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET LcprSingle PATHPARAM;
    accountCode;
    QUERYPARAM;
    fields,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqLcpr():New(self, "lcpr-get_single")

Default self:fields := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT LcprUpdate PATHPARAM;
    accountCode;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqLcpr():New(self, "lcpr-put_update")

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:accountCode := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST LcprInsert WSSERVICE healthcare

    Local oRequest := CenReqLcpr():New(self, "lcpr-post_insert")

    Default self:commitmentYear := ""
    Default self:commitmentCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:accountCode := ""

    Default self:description := ""
    Default self:trimester := ""
    Default self:status := ""
    Default self:accountingValue := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE LcprDelete PATHPARAM;
    accountCode;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqLcpr():New(self, "lcpr-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET SaidCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    commitmentYear,;
    financialDueDate,;
    debWPortfAcquis,;
    mktOnOperations,;
    debitsWithOperators,;
    benefDepContrapIns,;
    eventClaimNetPres,;
    eventClaimNetSus,;
    otherDebOprWPlan,;
    otherDebitsToPay,;
    trimester,;
    hthCareServProv,;
    status,;
    billsChargesCollect;
    WSSERVICE healthcare

Local oRequest := CenReqSaid():New(self, "said-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:commitmentYear := ""
Default self:financialDueDate := ""

Default self:debWPortfAcquis := ""
Default self:mktOnOperations := ""
Default self:debitsWithOperators := ""
Default self:benefDepContrapIns := ""
Default self:eventClaimNetPres := ""
Default self:eventClaimNetSus := ""
Default self:otherDebOprWPlan := ""
Default self:otherDebitsToPay := ""
Default self:trimester := ""
Default self:hthCareServProv := ""
Default self:status := ""
Default self:billsChargesCollect := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET SaidSingle PATHPARAM;
    financialDueDate;
    QUERYPARAM;
    fields,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    commitmentYear;
    WSSERVICE healthcare

Local oRequest := CenReqSaid():New(self, "said-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT SaidUpdate PATHPARAM;
    financialDueDate;
    QUERYPARAM;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    commitmentYear;
    WSSERVICE healthcare

Local oRequest := CenReqSaid():New(self, "said-put_update")

Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:commitmentYear := ""
Default self:financialDueDate := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST SaidInsert WSSERVICE healthcare

    Local oRequest := CenReqSaid():New(self, "said-post_insert")

    Default self:commitmentCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:commitmentYear := ""
    Default self:financialDueDate := ""

    Default self:debWPortfAcquis := ""
    Default self:mktOnOperations := ""
    Default self:debitsWithOperators := ""
    Default self:benefDepContrapIns := ""
    Default self:eventClaimNetPres := ""
    Default self:eventClaimNetSus := ""
    Default self:otherDebOprWPlan := ""
    Default self:otherDebitsToPay := ""
    Default self:trimester := ""
    Default self:hthCareServProv := ""
    Default self:status := ""
    Default self:billsChargesCollect := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE SaidDelete PATHPARAM;
    financialDueDate;
    QUERYPARAM;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    commitmentYear;
    WSSERVICE healthcare

Local oRequest := CenReqSaid():New(self, "said-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET SpidCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    financialDueDate,;
    collectiveFloating,;
    collectiveFixed,;
    beneficiariesOperationC,;
    postPaymentOperCredit,;
    individualFloating,;
    individualFixed,;
    prePaymentOperatorsCre,;
    otherCreditsWithPlan,;
    otherCredNotRelatPlan,;
    partBenefInEveClaim,;
    trimester,;
    status;
    WSSERVICE healthcare

Local oRequest := CenReqSpid():New(self, "spid-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:financialDueDate := ""

Default self:collectiveFloating := ""
Default self:collectiveFixed := ""
Default self:beneficiariesOperationC := ""
Default self:postPaymentOperCredit := ""
Default self:individualFloating := ""
Default self:individualFixed := ""
Default self:prePaymentOperatorsCre := ""
Default self:otherCreditsWithPlan := ""
Default self:otherCredNotRelatPlan := ""
Default self:partBenefInEveClaim := ""
Default self:trimester := ""
Default self:status := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET SpidSingle PATHPARAM;
    financialDueDate;
    QUERYPARAM;
    fields,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqSpid():New(self, "spid-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT SpidUpdate PATHPARAM;
    financialDueDate;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqSpid():New(self, "spid-put_update")

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:financialDueDate := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST SpidInsert WSSERVICE healthcare

    Local oRequest := CenReqSpid():New(self, "spid-post_insert")

    Default self:commitmentYear := ""
    Default self:commitmentCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:financialDueDate := ""

    Default self:collectiveFloating := ""
    Default self:collectiveFixed := ""
    Default self:beneficiariesOperationC := ""
    Default self:postPaymentOperCredit := ""
    Default self:individualFloating := ""
    Default self:individualFixed := ""
    Default self:prePaymentOperatorsCre := ""
    Default self:otherCreditsWithPlan := ""
    Default self:otherCredNotRelatPlan := ""
    Default self:partBenefInEveClaim := ""
    Default self:trimester := ""
    Default self:status := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE SpidDelete PATHPARAM;
    financialDueDate;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqSpid():New(self, "spid-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET FlcxCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentYear,;
    commitmentCode,;
    cashFlowCode,;
    obligationCode,;
    providerRegister,;
    status,;
    value,;
    trimester;
    WSSERVICE healthcare

Local oRequest := CenReqFlcx():New(self, "flcx-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:cashFlowCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:status := ""

Default self:value := ""
Default self:trimester := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET FlcxSingle PATHPARAM;
    cashFlowCode;
    QUERYPARAM;
    fields,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    status;
    WSSERVICE healthcare

Local oRequest := CenReqFlcx():New(self, "flcx-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT FlcxUpdate PATHPARAM;
    cashFlowCode;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    status;
    WSSERVICE healthcare

Local oRequest := CenReqFlcx():New(self, "flcx-put_update")

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:cashFlowCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:status := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST FlcxInsert WSSERVICE healthcare

    Local oRequest := CenReqFlcx():New(self, "flcx-post_insert")

    Default self:commitmentYear := ""
    Default self:commitmentCode := ""
    Default self:cashFlowCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:status := ""

    Default self:value := ""
    Default self:trimester := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE FlcxDelete PATHPARAM;
    cashFlowCode;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    status;
    WSSERVICE healthcare

Local oRequest := CenReqFlcx():New(self, "flcx-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET CoasCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    typeOfPlan,;
    paymentOrigin,;
    otherPayments,;
    trimester,;
    status,;
    therapies,;
    medicalAppointment,;
    otherExpenses,;
    examinations,;
    hospitalizations;
    WSSERVICE healthcare

Local oRequest := CenReqCoas():New(self, "coas-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:typeOfPlan := ""
Default self:paymentOrigin := ""

Default self:otherPayments := ""
Default self:trimester := ""
Default self:status := ""
Default self:therapies := ""
Default self:medicalAppointment := ""
Default self:otherExpenses := ""
Default self:examinations := ""
Default self:hospitalizations := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET CoasSingle PATHPARAM;
    typeOfPlan;
    QUERYPARAM;
    fields,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    paymentOrigin;
    WSSERVICE healthcare

Local oRequest := CenReqCoas():New(self, "coas-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT CoasUpdate PATHPARAM;
    typeOfPlan;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    paymentOrigin;
    WSSERVICE healthcare

Local oRequest := CenReqCoas():New(self, "coas-put_update")

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:typeOfPlan := ""
Default self:paymentOrigin := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST CoasInsert WSSERVICE healthcare

    Local oRequest := CenReqCoas():New(self, "coas-post_insert")

    Default self:commitmentYear := ""
    Default self:commitmentCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:typeOfPlan := ""
    Default self:paymentOrigin := ""

    Default self:otherPayments := ""
    Default self:trimester := ""
    Default self:status := ""
    Default self:therapies := ""
    Default self:medicalAppointment := ""
    Default self:otherExpenses := ""
    Default self:examinations := ""
    Default self:hospitalizations := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE CoasDelete PATHPARAM;
    typeOfPlan;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    paymentOrigin;
    WSSERVICE healthcare

Local oRequest := CenReqCoas():New(self, "coas-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET PeslCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    commitmentYear,;
    evCorrAssumMajorPer,;
    lastDaysAssumCorrEv,;
    greaterDangerLossEvent,;
    latestDaysEvents,;
    noOfBeneficiaries,;
    trimester,;
    status;
    WSSERVICE healthcare

Local oRequest := CenReqPesl():New(self, "pesl-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:commitmentYear := ""

Default self:evCorrAssumMajorPer := ""
Default self:lastDaysAssumCorrEv := ""
Default self:greaterDangerLossEvent := ""
Default self:latestDaysEvents := ""
Default self:noOfBeneficiaries := ""
Default self:trimester := ""
Default self:status := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET PeslSingle PATHPARAM;
    commitmentYear;
    QUERYPARAM;
    fields,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqPesl():New(self, "pesl-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT PeslUpdate PATHPARAM;
    commitmentYear;
    QUERYPARAM;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqPesl():New(self, "pesl-put_update")

Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:commitmentYear := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST PeslInsert WSSERVICE healthcare

    Local oRequest := CenReqPesl():New(self, "pesl-post_insert")

    Default self:commitmentCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:commitmentYear := ""

    Default self:evCorrAssumMajorPer := ""
    Default self:lastDaysAssumCorrEv := ""
    Default self:greaterDangerLossEvent := ""
    Default self:latestDaysEvents := ""
    Default self:noOfBeneficiaries := ""
    Default self:trimester := ""
    Default self:status := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE PeslDelete PATHPARAM;
    commitmentYear;
    QUERYPARAM;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqPesl():New(self, "pesl-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET AgcnCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    riskPool,;
    pceCorresponGranted,;
    pceIssuedCounterprov,;
    eveClaimsKnownPce,;
    plaCorresponGranted,;
    issuedConsiderationsPla,;
    plaKnowlLossEvents,;
    trimester,;
    status;
    WSSERVICE healthcare

Local oRequest := CenReqAgcn():New(self, "agcn-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:riskPool := ""

Default self:pceCorresponGranted := ""
Default self:pceIssuedCounterprov := ""
Default self:eveClaimsKnownPce := ""
Default self:plaCorresponGranted := ""
Default self:issuedConsiderationsPla := ""
Default self:plaKnowlLossEvents := ""
Default self:trimester := ""
Default self:status := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET AgcnSingle PATHPARAM;
    riskPool;
    QUERYPARAM;
    fields,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqAgcn():New(self, "agcn-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT AgcnUpdate PATHPARAM;
    riskPool;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqAgcn():New(self, "agcn-put_update")

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:riskPool := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST AgcnInsert WSSERVICE healthcare

    Local oRequest := CenReqAgcn():New(self, "agcn-post_insert")

    Default self:commitmentYear := ""
    Default self:commitmentCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:riskPool := ""

    Default self:pceCorresponGranted := ""
    Default self:pceIssuedCounterprov := ""
    Default self:eveClaimsKnownPce := ""
    Default self:plaCorresponGranted := ""
    Default self:issuedConsiderationsPla := ""
    Default self:plaKnowlLossEvents := ""
    Default self:trimester := ""
    Default self:status := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE AgcnDelete PATHPARAM;
    riskPool;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqAgcn():New(self, "agcn-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET EvinCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentYear,;
    commitmentCode,;
    eventCodeAns,;
    obligationCode,;
    providerRegister,;
    trimester,;
    status,;
    quarterMthFirstValue,;
    quarterMthSecValue,;
    quarterMthThirdValue;
    WSSERVICE healthcare

Local oRequest := CenReqEvin():New(self, "evin-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:eventCodeAns := ""
Default self:obligationCode := ""
Default self:providerRegister := ""

Default self:trimester := ""
Default self:status := ""
Default self:quarterMthFirstValue := ""
Default self:quarterMthSecValue := ""
Default self:quarterMthThirdValue := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET EvinSingle PATHPARAM;
    eventCodeAns;
    QUERYPARAM;
    fields,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqEvin():New(self, "evin-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT EvinUpdate PATHPARAM;
    eventCodeAns;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqEvin():New(self, "evin-put_update")

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:eventCodeAns := ""
Default self:obligationCode := ""
Default self:providerRegister := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST EvinInsert WSSERVICE healthcare

    Local oRequest := CenReqEvin():New(self, "evin-post_insert")

    Default self:commitmentYear := ""
    Default self:commitmentCode := ""
    Default self:eventCodeAns := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""

    Default self:trimester := ""
    Default self:status := ""
    Default self:quarterMthFirstValue := ""
    Default self:quarterMthSecValue := ""
    Default self:quarterMthThirdValue := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE EvinDelete PATHPARAM;
    eventCodeAns;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqEvin():New(self, "evin-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET OperCollection QUERYPARAM page, pageSize, fields, order, expand,;
    operatorCnpj,;
    providerRegister,;
    operatorMode,;
    legalNature,;
    tradeName,;
    corporateName,;
    operatorSegmentation;
    WSSERVICE healthcare

Local oRequest := CenReqOper():New(self, "oper-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:operatorCnpj := ""
Default self:providerRegister := ""

Default self:operatorMode := ""
Default self:legalNature := ""
Default self:tradeName := ""
Default self:corporateName := ""
Default self:operatorSegmentation := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET OperSingle PATHPARAM;
    operatorCnpj;
    QUERYPARAM;
    fields,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqOper():New(self, "oper-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT OperUpdate PATHPARAM;
    operatorCnpj;
    QUERYPARAM;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqOper():New(self, "oper-put_update")

Default self:operatorCnpj := ""
Default self:providerRegister := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST OperInsert WSSERVICE healthcare

    Local oRequest := CenReqOper():New(self, "oper-post_insert")

    Default self:operatorCnpj := ""
    Default self:providerRegister := ""

    Default self:operatorMode := ""
    Default self:legalNature := ""
    Default self:tradeName := ""
    Default self:corporateName := ""
    Default self:operatorSegmentation := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE OperDelete PATHPARAM;
    operatorCnpj;
    QUERYPARAM;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqOper():New(self, "oper-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET ReprCollection QUERYPARAM page, pageSize, fields, order, expand,;
    registrationOfIndividua,;
    providerRegister,;
    addressComplement,;
    district,;
    representativeSPosition,;
    ibgeCityCode,;
    postAddrCode,;
    nationalCallingCd,;
    internationalCallinfCd,;
    idIssueDate,;
    addressName,;
    representativeSName,;
    idNumber,;
    addressNumber,;
    idIssuingBody,;
    country,;
    extension,;
    stateAcronym,;
    telephoneNumber;
    WSSERVICE healthcare

Local oRequest := CenReqRepr():New(self, "repr-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:registrationOfIndividua := ""
Default self:providerRegister := ""

Default self:addressComplement := ""
Default self:district := ""
Default self:representativeSPosition := ""
Default self:ibgeCityCode := ""
Default self:postAddrCode := ""
Default self:nationalCallingCd := ""
Default self:internationalCallinfCd := ""
Default self:idIssueDate := ""
Default self:addressName := ""
Default self:representativeSName := ""
Default self:idNumber := ""
Default self:addressNumber := ""
Default self:idIssuingBody := ""
Default self:country := ""
Default self:extension := ""
Default self:stateAcronym := ""
Default self:telephoneNumber := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET ReprSingle PATHPARAM;
    registrationOfIndividua;
    QUERYPARAM;
    fields,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqRepr():New(self, "repr-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT ReprUpdate PATHPARAM;
    registrationOfIndividua;
    QUERYPARAM;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqRepr():New(self, "repr-put_update")

Default self:registrationOfIndividua := ""
Default self:providerRegister := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST ReprInsert WSSERVICE healthcare

    Local oRequest := CenReqRepr():New(self, "repr-post_insert")

    Default self:registrationOfIndividua := ""
    Default self:providerRegister := ""

    Default self:addressComplement := ""
    Default self:district := ""
    Default self:representativeSPosition := ""
    Default self:ibgeCityCode := ""
    Default self:postAddrCode := ""
    Default self:nationalCallingCd := ""
    Default self:internationalCallinfCd := ""
    Default self:idIssueDate := ""
    Default self:addressName := ""
    Default self:representativeSName := ""
    Default self:idNumber := ""
    Default self:addressNumber := ""
    Default self:idIssuingBody := ""
    Default self:country := ""
    Default self:extension := ""
    Default self:stateAcronym := ""
    Default self:telephoneNumber := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE ReprDelete PATHPARAM;
    registrationOfIndividua;
    QUERYPARAM;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqRepr():New(self, "repr-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET AcioCollection QUERYPARAM page, pageSize, fields, order, expand,;
    providerRegister,;
    shareholderSCpfCnpj,;
    corporateName,;
    numberOfShares,;
    shareholderType;
    WSSERVICE healthcare

Local oRequest := CenReqAcio():New(self, "acio-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:providerRegister := ""
Default self:shareholderSCpfCnpj := ""

Default self:corporateName := ""
Default self:numberOfShares := ""
Default self:shareholderType := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET AcioSingle PATHPARAM;
    shareholderSCpfCnpj;
    QUERYPARAM;
    fields,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqAcio():New(self, "acio-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT AcioUpdate PATHPARAM;
    shareholderSCpfCnpj;
    QUERYPARAM;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqAcio():New(self, "acio-put_update")

Default self:providerRegister := ""
Default self:shareholderSCpfCnpj := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST AcioInsert WSSERVICE healthcare

    Local oRequest := CenReqAcio():New(self, "acio-post_insert")

    Default self:providerRegister := ""
    Default self:shareholderSCpfCnpj := ""

    Default self:corporateName := ""
    Default self:numberOfShares := ""
    Default self:shareholderType := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE AcioDelete PATHPARAM;
    shareholderSCpfCnpj;
    QUERYPARAM;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqAcio():New(self, "acio-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET ColiCollection QUERYPARAM page, pageSize, fields, order, expand,;
    legalEntityNatRegister,;
    providerRegister,;
    quantityOfActions,;
    companyName,;
    totalOfActionsOrQuota,;
    typeOfShare,;
    companyClassification;
    WSSERVICE healthcare

Local oRequest := CenReqColi():New(self, "coli-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:legalEntityNatRegister := ""
Default self:providerRegister := ""

Default self:quantityOfActions := ""
Default self:companyName := ""
Default self:totalOfActionsOrQuota := ""
Default self:typeOfShare := ""
Default self:companyClassification := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET ColiSingle PATHPARAM;
    legalEntityNatRegister;
    QUERYPARAM;
    fields,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqColi():New(self, "coli-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT ColiUpdate PATHPARAM;
    legalEntityNatRegister;
    QUERYPARAM;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqColi():New(self, "coli-put_update")

Default self:legalEntityNatRegister := ""
Default self:providerRegister := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST ColiInsert WSSERVICE healthcare

    Local oRequest := CenReqColi():New(self, "coli-post_insert")

    Default self:legalEntityNatRegister := ""
    Default self:providerRegister := ""

    Default self:quantityOfActions := ""
    Default self:companyName := ""
    Default self:totalOfActionsOrQuota := ""
    Default self:typeOfShare := ""
    Default self:companyClassification := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE ColiDelete PATHPARAM;
    legalEntityNatRegister;
    QUERYPARAM;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqColi():New(self, "coli-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET MuniCollection QUERYPARAM page, pageSize, fields, order, expand,;
    ibgeCityCode,;
    providerRegister,;
    stateAcronym;
    ;
    WSSERVICE healthcare

Local oRequest := CenReqMuni():New(self, "muni-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:ibgeCityCode := ""
Default self:providerRegister := ""
Default self:stateAcronym := ""



oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET MuniSingle PATHPARAM;
    stateAcronym;
    QUERYPARAM;
    fields,;
    ibgeCityCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqMuni():New(self, "muni-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT MuniUpdate PATHPARAM;
    stateAcronym;
    QUERYPARAM;
    ibgeCityCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqMuni():New(self, "muni-put_update")

Default self:ibgeCityCode := ""
Default self:providerRegister := ""
Default self:stateAcronym := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST MuniInsert WSSERVICE healthcare

    Local oRequest := CenReqMuni():New(self, "muni-post_insert")

    Default self:ibgeCityCode := ""
    Default self:providerRegister := ""
    Default self:stateAcronym := ""



    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE MuniDelete PATHPARAM;
    stateAcronym;
    QUERYPARAM;
    ibgeCityCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqMuni():New(self, "muni-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET QdrsCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    diopsChart,;
    chartReceived,;
    validateChart;
    WSSERVICE healthcare

Local oRequest := CenReqQdrs():New(self, "qdrs-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:diopsChart := ""

Default self:chartReceived := ""
Default self:validateChart := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET QdrsSingle PATHPARAM;
    diopsChart;
    QUERYPARAM;
    fields,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqQdrs():New(self, "qdrs-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT QdrsUpdate PATHPARAM;
    diopsChart;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqQdrs():New(self, "qdrs-put_update")

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:diopsChart := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST QdrsInsert WSSERVICE healthcare

    Local oRequest := CenReqQdrs():New(self, "qdrs-post_insert")

    Default self:commitmentYear := ""
    Default self:commitmentCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:diopsChart := ""

    Default self:chartReceived := ""
    Default self:validateChart := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE QdrsDelete PATHPARAM;
    diopsChart;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqQdrs():New(self, "qdrs-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET RespCollection QUERYPARAM page, pageSize, fields, order, expand,;
    providerRegister,;
    cpfCnpj,;
    responsibleLeOrIndivid,;
    responsibilityType,;
    nameCorporateName,;
    recordNumber;
    WSSERVICE healthcare

Local oRequest := CenReqResp():New(self, "resp-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:providerRegister := ""
Default self:cpfCnpj := ""
Default self:responsibleLeOrIndivid := ""
Default self:responsibilityType := ""

Default self:nameCorporateName := ""
Default self:recordNumber := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET RespSingle PATHPARAM;
    responsibilityType;
    QUERYPARAM;
    fields,;
    providerRegister,;
    cpfCnpj,;
    responsibleLeOrIndivid;
    WSSERVICE healthcare

Local oRequest := CenReqResp():New(self, "resp-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT RespUpdate PATHPARAM;
    responsibilityType;
    QUERYPARAM;
    providerRegister,;
    cpfCnpj,;
    responsibleLeOrIndivid;
    WSSERVICE healthcare

Local oRequest := CenReqResp():New(self, "resp-put_update")

Default self:providerRegister := ""
Default self:cpfCnpj := ""
Default self:responsibleLeOrIndivid := ""
Default self:responsibilityType := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST RespInsert WSSERVICE healthcare

    Local oRequest := CenReqResp():New(self, "resp-post_insert")

    Default self:providerRegister := ""
    Default self:cpfCnpj := ""
    Default self:responsibleLeOrIndivid := ""
    Default self:responsibilityType := ""

    Default self:nameCorporateName := ""
    Default self:recordNumber := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE RespDelete PATHPARAM;
    responsibilityType;
    QUERYPARAM;
    providerRegister,;
    cpfCnpj,;
    responsibleLeOrIndivid;
    WSSERVICE healthcare

Local oRequest := CenReqResp():New(self, "resp-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET DepnCollection QUERYPARAM page, pageSize, fields, order, expand,;
    providerRegister,;
    legalEntityNatRegister,;
    postAddrCode,;
    longDistanceCode,;
    internationalCallinfCd,;
    district,;
    ibgeCityCode,;
    addressComplement,;
    eMail,;
    addressName,;
    corporateName,;
    addressNumber,;
    extensionLine,;
    stateAcronym,;
    telephoneNumber,;
    dependenceType;
    WSSERVICE healthcare

Local oRequest := CenReqDepn():New(self, "depn-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:providerRegister := ""
Default self:legalEntityNatRegister := ""

Default self:postAddrCode := ""
Default self:longDistanceCode := ""
Default self:internationalCallinfCd := ""
Default self:district := ""
Default self:ibgeCityCode := ""
Default self:addressComplement := ""
Default self:eMail := ""
Default self:addressName := ""
Default self:corporateName := ""
Default self:addressNumber := ""
Default self:extensionLine := ""
Default self:stateAcronym := ""
Default self:telephoneNumber := ""
Default self:dependenceType := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET DepnSingle PATHPARAM;
    legalEntityNatRegister;
    QUERYPARAM;
    fields,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqDepn():New(self, "depn-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT DepnUpdate PATHPARAM;
    legalEntityNatRegister;
    QUERYPARAM;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqDepn():New(self, "depn-put_update")

Default self:providerRegister := ""
Default self:legalEntityNatRegister := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST DepnInsert WSSERVICE healthcare

    Local oRequest := CenReqDepn():New(self, "depn-post_insert")

    Default self:providerRegister := ""
    Default self:legalEntityNatRegister := ""

    Default self:postAddrCode := ""
    Default self:longDistanceCode := ""
    Default self:internationalCallinfCd := ""
    Default self:district := ""
    Default self:ibgeCityCode := ""
    Default self:addressComplement := ""
    Default self:eMail := ""
    Default self:addressName := ""
    Default self:corporateName := ""
    Default self:addressNumber := ""
    Default self:extensionLine := ""
    Default self:stateAcronym := ""
    Default self:telephoneNumber := ""
    Default self:dependenceType := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE DepnDelete PATHPARAM;
    legalEntityNatRegister;
    QUERYPARAM;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqDepn():New(self, "depn-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET CoesCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    operatorRecordInAns,;
    trimester,;
    status,;
    billingValue;
    WSSERVICE healthcare

Local oRequest := CenReqCoes():New(self, "coes-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:operatorRecordInAns := ""
Default self:trimester := ""

Default self:status := ""
Default self:billingValue := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET CoesSingle PATHPARAM;
    operatorRecordInAns;
    QUERYPARAM;
    fields,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    trimester;
    WSSERVICE healthcare

Local oRequest := CenReqCoes():New(self, "coes-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT CoesUpdate PATHPARAM;
    operatorRecordInAns;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    trimester;
    WSSERVICE healthcare

Local oRequest := CenReqCoes():New(self, "coes-put_update")

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:operatorRecordInAns := ""
Default self:trimester := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST CoesInsert WSSERVICE healthcare

    Local oRequest := CenReqCoes():New(self, "coes-post_insert")

    Default self:commitmentYear := ""
    Default self:commitmentCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:operatorRecordInAns := ""
    Default self:trimester := ""

    Default self:status := ""
    Default self:billingValue := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE CoesDelete PATHPARAM;
    operatorRecordInAns;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    trimester;
    WSSERVICE healthcare

Local oRequest := CenReqCoes():New(self, "coes-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET CcopCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    taxName,;
    periodDate,;
    taxType,;
    commitmentYear,;
    monetaryUpdate,;
    amtPaidTrimester,;
    totalAmtFinanced,;
    totalAmtPaid,;
    dateAdhesionToRefis,;
    numberOfInstallments,;
    numbDueInstallments,;
    numbOfPaidInstallm,;
    trimester,;
    trimesterFinalBalance,;
    trimesterInitialBalance,;
    status;
    WSSERVICE healthcare

Local oRequest := CenReqCcop():New(self, "ccop-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:taxName := ""
Default self:periodDate := ""
Default self:taxType := ""
Default self:commitmentYear := ""

Default self:monetaryUpdate := ""
Default self:amtPaidTrimester := ""
Default self:totalAmtFinanced := ""
Default self:totalAmtPaid := ""
Default self:dateAdhesionToRefis := ""
Default self:numberOfInstallments := ""
Default self:numbDueInstallments := ""
Default self:numbOfPaidInstallm := ""
Default self:trimester := ""
Default self:trimesterFinalBalance := ""
Default self:trimesterInitialBalance := ""
Default self:status := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET CcopSingle PATHPARAM;
    taxType;
    QUERYPARAM;
    fields,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    taxName,;
    periodDate,;
    commitmentYear;
    WSSERVICE healthcare

Local oRequest := CenReqCcop():New(self, "ccop-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT CcopUpdate PATHPARAM;
    taxType;
    QUERYPARAM;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    taxName,;
    periodDate,;
    commitmentYear;
    WSSERVICE healthcare

Local oRequest := CenReqCcop():New(self, "ccop-put_update")

Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:taxName := ""
Default self:periodDate := ""
Default self:taxType := ""
Default self:commitmentYear := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST CcopInsert WSSERVICE healthcare

    Local oRequest := CenReqCcop():New(self, "ccop-post_insert")

    Default self:commitmentCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:taxName := ""
    Default self:periodDate := ""
    Default self:taxType := ""
    Default self:commitmentYear := ""

    Default self:monetaryUpdate := ""
    Default self:amtPaidTrimester := ""
    Default self:totalAmtFinanced := ""
    Default self:totalAmtPaid := ""
    Default self:dateAdhesionToRefis := ""
    Default self:numberOfInstallments := ""
    Default self:numbDueInstallments := ""
    Default self:numbOfPaidInstallm := ""
    Default self:trimester := ""
    Default self:trimesterFinalBalance := ""
    Default self:trimesterInitialBalance := ""
    Default self:status := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE CcopDelete PATHPARAM;
    taxType;
    QUERYPARAM;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    taxName,;
    periodDate,;
    commitmentYear;
    WSSERVICE healthcare

Local oRequest := CenReqCcop():New(self, "ccop-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET PactCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    accountCode,;
    commitmentYear,;
    monetaryUpdate,;
    competenceDate,;
    trimester,;
    balanceAtTheEndOfThe,;
    status,;
    initialValue,;
    valuePaid;
    WSSERVICE healthcare

Local oRequest := CenReqPact():New(self, "pact-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:accountCode := ""
Default self:commitmentYear := ""

Default self:monetaryUpdate := ""
Default self:competenceDate := ""
Default self:trimester := ""
Default self:balanceAtTheEndOfThe := ""
Default self:status := ""
Default self:initialValue := ""
Default self:valuePaid := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET PactSingle PATHPARAM;
    accountCode;
    QUERYPARAM;
    fields,;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    commitmentYear;
    WSSERVICE healthcare

Local oRequest := CenReqPact():New(self, "pact-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT PactUpdate PATHPARAM;
    accountCode;
    QUERYPARAM;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    commitmentYear;
    WSSERVICE healthcare

Local oRequest := CenReqPact():New(self, "pact-put_update")

Default self:commitmentCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""
Default self:accountCode := ""
Default self:commitmentYear := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST PactInsert WSSERVICE healthcare

    Local oRequest := CenReqPact():New(self, "pact-post_insert")

    Default self:commitmentCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""
    Default self:accountCode := ""
    Default self:commitmentYear := ""

    Default self:monetaryUpdate := ""
    Default self:competenceDate := ""
    Default self:trimester := ""
    Default self:balanceAtTheEndOfThe := ""
    Default self:status := ""
    Default self:initialValue := ""
    Default self:valuePaid := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE PactDelete PATHPARAM;
    accountCode;
    QUERYPARAM;
    commitmentCode,;
    obligationCode,;
    providerRegister,;
    commitmentYear;
    WSSERVICE healthcare

Local oRequest := CenReqPact():New(self, "pact-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET SmcrCollection QUERYPARAM page, pageSize, fields, order, expand,;
    commitmentYear,;
    commitmentCode,;
    benefitAdmOperCode,;
    obligationCode,;
    providerRegister,;
    trimester,;
    status,;
    amt1StMthTrimester,;
    amt2NdMthTrimester,;
    amt3RdMthTrimester;
    WSSERVICE healthcare

Local oRequest := CenReqSmcr():New(self, "smcr-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:benefitAdmOperCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""

Default self:trimester := ""
Default self:status := ""
Default self:amt1StMthTrimester := ""
Default self:amt2NdMthTrimester := ""
Default self:amt3RdMthTrimester := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET SmcrSingle PATHPARAM;
    benefitAdmOperCode;
    QUERYPARAM;
    fields,;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqSmcr():New(self, "smcr-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT SmcrUpdate PATHPARAM;
    benefitAdmOperCode;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqSmcr():New(self, "smcr-put_update")

Default self:commitmentYear := ""
Default self:commitmentCode := ""
Default self:benefitAdmOperCode := ""
Default self:obligationCode := ""
Default self:providerRegister := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST SmcrInsert WSSERVICE healthcare

    Local oRequest := CenReqSmcr():New(self, "smcr-post_insert")

    Default self:commitmentYear := ""
    Default self:commitmentCode := ""
    Default self:benefitAdmOperCode := ""
    Default self:obligationCode := ""
    Default self:providerRegister := ""

    Default self:trimester := ""
    Default self:status := ""
    Default self:amt1StMthTrimester := ""
    Default self:amt2NdMthTrimester := ""
    Default self:amt3RdMthTrimester := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE SmcrDelete PATHPARAM;
    benefitAdmOperCode;
    QUERYPARAM;
    commitmentYear,;
    commitmentCode,;
    obligationCode,;
    providerRegister;
    WSSERVICE healthcare

Local oRequest := CenReqSmcr():New(self, "smcr-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST B2VInsert WSSERVICE healthcare

    Local oRequest := CenReqB2V():New(self, "b2v-post_insert")

    Default self:formSequential := ""
    Default self:operatorRecord := ""

    Default self:providerCpfCnpj := ""
    Default self:formProcDt := ""
    Default self:identReceipt := ""
    Default self:totalValueEntered := ""
    Default self:totalDisallowValue := ""
    Default self:totalValuePaid := ""
    Default self:deletionId := ""
    Default self:processed := ""
    Default self:inclusionDate := ""
    Default self:inclusionTime := ""
    Default self:roboId := ""
    Default self:procStartTime := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.


WSMETHOD POST B2XInsert WSSERVICE healthcare

    Local oRequest := CenReqB2X():New(self, "b2x-post_insert")

    Default self:formSequential := ""
    Default self:operatorRecord := ""

    Default self:periodCover := ""
    Default self:providerCpfCnpj := ""
    Default self:providerIdentifier := ""
    Default self:cityOfProvider := ""
    Default self:ansRecordNumber := ""
    Default self:presetValueIdent := ""
    Default self:presetValue := ""
    Default self:inclusionDate := ""
    Default self:inclusionTime := ""
    Default self:deletionDate := ""
    Default self:processed := ""
    Default self:roboId := ""
    Default self:procStartTime := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.


WSMETHOD POST BraInsert WSSERVICE healthcare

    Local oRequest := CenReqBra():New(self, "bra-post_insert")

    Default self:operatorRecord := ""
    Default self:formSequential := ""

    Default self:processed := ""
    Default self:tissProviderVersion := ""
    Default self:submissionMethod := ""
    Default self:cnes := ""
    Default self:executerId := ""
    Default self:providerCpfCnpj := ""
    Default self:executingCityCode := ""
    Default self:ansRecordNumber := ""
    Default self:registration := ""
    Default self:aEventType := ""
    Default self:eventOrigin := ""
    Default self:providerFormNumber := ""
    Default self:operatorFormNumber := ""
    Default self:refundId := ""
    Default self:presetValueIdent := ""
    Default self:hospitalizationRequest := ""
    Default self:requestDate := ""
    Default self:mainFormNumb := ""
    Default self:authorizationDate := ""
    Default self:executionDate := ""
    Default self:invoicingStartDate := ""
    Default self:invoicingEndDate := ""
    Default self:collectionProtocolDate := ""
    Default self:paymentDt := ""
    Default self:formProcDt := ""
    Default self:appointmentType := ""
    Default self:cboSCode := ""
    Default self:newborn := ""
    Default self:indicAccident := ""
    Default self:admissionType := ""
    Default self:hospTp := ""
    Default self:hospRegime := ""
    Default self:serviceType := ""
    Default self:invoicingTp := ""
    Default self:escortDailyRates := ""
    Default self:icuDailyRates := ""
    Default self:outflowType := ""
    Default self:icdDiagnosis1 := ""
    Default self:icdDiagnosis2 := ""
    Default self:icdDiagnosis3 := ""
    Default self:icdDiagnosis4 := ""
    Default self:inclusionDate := ""
    Default self:inclusionTime := ""
    Default self:dateOfDeletion := ""
    Default self:roboId := ""
    Default self:procStartTime := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.


WSMETHOD POST Bw8Insert WSSERVICE healthcare

    Local oRequest := CenReqBw8():New(self, "bw8-post_insert")

    Default self:operatorRecord := ""
    Default self:formSequential := ""

    Default self:registration := ""
    Default self:providerFormNumber := ""
    Default self:formProcDt := ""
    Default self:inclusionDate := ""
    Default self:inclusionTime := ""
    Default self:deletionDate := ""
    Default self:processed := ""
    Default self:roboId := ""
    Default self:procStartTime := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.


WSMETHOD GET B2YCollection QUERYPARAM page, pageSize, fields, order, expand,;
    healthInsurerCode,;
    ssnHolder,;
    titleHolderEnrollment,;
    dependentSsn,;
    dependentEnrollment,;
    expenseKey,;
    period,;
    holderName,;
    dependentName,;
    dependentBirthDate,;
    dependenceRelationships,;
    expenseAmount,;
    refundAmount,;
    previousYearRefundAmt,;
    providerSsnEin,;
    providerName,;
    status,;
    inicialDate,;
    finalDate;
    WSSERVICE healthcare

Local oRequest := CenReqB2Y():New(self, "b2y-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:fields   := ""
Default self:order    := ""

Default self:healthInsurerCode := ""
Default self:ssnHolder := ""
Default self:titleHolderEnrollment := ""
Default self:dependentSsn := ""
Default self:dependentEnrollment := ""
Default self:expenseKey := ""
Default self:period := ""

Default self:holderName := ""
Default self:dependentName := ""
Default self:dependentBirthDate := ""
Default self:dependenceRelationships := ""
Default self:expenseAmount := ""
Default self:refundAmount := ""
Default self:previousYearRefundAmt := ""
Default self:providerSsnEin := ""
Default self:providerName   := ""
Default self:status := ""
Default self:inicialDate := ""
Default self:finalDate := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyExpand(self:expand)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:searcher(BUSCA)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET B2YSingle PATHPARAM;
    expenseKey;
    QUERYPARAM;
    expand,;
    fields,;
    healthInsurerCode,;
    titleHolderEnrollment,;
    dependentSsn,;
    dependentEnrollment,;
    ssnHolder,;
    period;
    WSSERVICE healthcare

Local oRequest := CenReqB2Y():New(self, "b2y-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyExpand(self:expand)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT B2YUpdate PATHPARAM;
    expenseKey;
    QUERYPARAM;
    healthInsurerCode,;
    titleHolderEnrollment,;
    dependentSsn,;
    dependentEnrollment,;
    ssnHolder,;
    period;
    WSSERVICE healthcare

Local oRequest := CenReqB2Y():New(self, "b2y-put_update")

Default self:healthInsurerCode := ""
Default self:ssnHolder := ""
Default self:titleHolderEnrollment := ""
Default self:dependentSsn := ""
Default self:dependentEnrollment := ""
Default self:expenseKey := ""
Default self:period := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST B2YInsert WSSERVICE healthcare

    Local oRequest := CenReqB2Y():New(self, "b2y-post_insert")

    Default self:healthInsurerCode := ""
    Default self:ssnHolder := ""
    Default self:titleHolderEnrollment := ""
    Default self:dependentSsn := ""
    Default self:dependentEnrollment := ""
    Default self:expenseKey := ""
    Default self:period := ""

    Default self:holderName := ""
    Default self:dependentName := ""
    Default self:dependentBirthDate := ""
    Default self:dependenceRelationships := ""
    Default self:expenseAmount := ""
    Default self:refundAmount := ""
    Default self:previousYearRefundAmt := ""
    Default self:providerSsnEin := ""
    Default self:providerName := ""
    Default self:status := ""
    Default self:processed := ""
    Default self:roboId := ""
    Default self:inclusionTime:=""
    Default self:exclusionId:=""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE B2YDelete PATHPARAM;
    expenseKey;
    QUERYPARAM;
    healthInsurerCode,;
    titleHolderEnrollment,;
    dependentSsn,;
    dependentEnrollment,;
    expenseKey,;
    period;
    WSSERVICE healthcare

Local oRequest := CenReqB2Y():New(self, "b2y-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD GET B6NCollection QUERYPARAM page, pageSize, search, fields, order, expand,;
    healthInsurerCode,;
    ssn,;
    name,;
    areaCode,;
    phoneNumber,;
    extensionLine,;
    fax,;
    eMail,;
    active;
    WSSERVICE healthcare

Local oRequest := CenReqB6N():New(self, "b6n-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:search   := ""
Default self:fields   := ""
Default self:order    := ""
Default self:uniqueKey := ""

Default self:healthInsurerCode := ""
Default self:ssn := ""

Default self:name := ""
Default self:areaCode := ""
Default self:phoneNumber := ""
Default self:extensionLine := ""
Default self:fax := ""
Default self:eMail := ""
Default self:active := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyExpand(self:expand)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:applySearch(self:search)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET B6NSingle PATHPARAM;
    uniqueKey;
    QUERYPARAM;
    expand,;
    fields,;
    healthInsurerCode,;
    ssn;
    WSSERVICE healthcare

Local oRequest := CenReqB6N():New(self, "b6n-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyExpand(self:expand)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT B6NUpdate PATHPARAM;
    uniqueKey;
    QUERYPARAM;
    healthInsurerCode,;
    ssn;
    WSSERVICE healthcare

Local oRequest := CenReqB6N():New(self, "b6n-put_update")

Default self:healthInsurerCode := ""
Default self:ssn := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST B6NInsert WSSERVICE healthcare

    Local oRequest := CenReqB6N():New(self, "b6n-post_insert")

    Default self:healthInsurerCode := ""
    Default self:ssn := ""

    Default self:name := ""
    Default self:areaCode := ""
    Default self:phoneNumber := ""
    Default self:extensionLine := ""
    Default self:fax := ""
    Default self:eMail := ""
    Default self:active := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE B6NDelete PATHPARAM;
    uniqueKey;
    QUERYPARAM;
    healthInsurerCode,;
    ssn;
    WSSERVICE healthcare

Local oRequest := CenReqB6N():New(self, "b6n-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET B8MCollection QUERYPARAM filter, page, pageSize, search, fields, order, expand,;
    registerNumber,;
    operatorCnpj,;
    corporateName,;
    tradeName,;
    legalNature,;
    operatorMode,;
    operatorSegmentation;
    WSSERVICE healthcare

Local oRequest := CenReqB8M():New(self, "b8m-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:search   := ""
Default self:filter   := ""
Default self:fields   := ""
Default self:order    := ""
Default self:uniqueKey := ""

Default self:registerNumber := ""
Default self:operatorCnpj := ""

Default self:corporateName := ""
Default self:tradeName := ""
Default self:legalNature := ""
Default self:operatorMode := ""
Default self:operatorSegmentation := ""

if !Empty(self:filter) .And. Empty(self:search)
    self:search := self:filter
endif

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyExpand(self:expand)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:applySearch(self:search)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET B8MSingle PATHPARAM;
    uniqueKey;
    QUERYPARAM;
    expand,;
    fields,;
    registerNumber,;
    operatorCnpj;
    WSSERVICE healthcare

Local oRequest := CenReqB8M():New(self, "b8m-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyExpand(self:expand)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT B8MUpdate PATHPARAM;
    uniqueKey;
    QUERYPARAM;
    registerNumber,;
    operatorCnpj;
    WSSERVICE healthcare

Local oRequest := CenReqB8M():New(self, "b8m-put_update")

Default self:registerNumber := ""
Default self:operatorCnpj := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST B8MInsert WSSERVICE healthcare

    Local oRequest := CenReqB8M():New(self, "b8m-post_insert")

    Default self:registerNumber := ""
    Default self:operatorCnpj := ""

    Default self:corporateName := ""
    Default self:tradeName := ""
    Default self:legalNature := ""
    Default self:operatorMode := ""
    Default self:operatorSegmentation := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE B8MDelete PATHPARAM;
    uniqueKey;
    QUERYPARAM;
    registerNumber,;
    operatorCnpj;
    WSSERVICE healthcare

Local oRequest := CenReqB8M():New(self, "b8m-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.


WSMETHOD GET Bi0Collection QUERYPARAM page, pageSize, search, fields, order, expand,;
    healthInsurerCode,;
    referenceYear,;
    numeratorTissRatio,;
    denominatorTissRatio,;
    partialTissRatio,;
    totalTissRatio;
    WSSERVICE healthcare

Local oRequest := CenReqBi0():New(self, "bi0-get_collection")

Default self:page     := "1"
Default self:pageSize := "20"
Default self:search   := ""
Default self:fields   := ""
Default self:order    := ""
Default self:uniqueKey := ""

Default self:healthInsurerCode := ""
Default self:referenceYear := ""

Default self:numeratorTissRatio := ""
Default self:denominatorTissRatio := ""
Default self:partialTissRatio := ""
Default self:totalTissRatio := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(ALL)
    oRequest:applyFields(self:fields)
    oRequest:applyExpand(self:expand)
    oRequest:applyOrder(self:order)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:applySearch(self:search)
    oRequest:procGet(ALL)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD GET Bi0Single PATHPARAM;
    uniqueKey;
    QUERYPARAM;
    expand,;
    fields,;
    healthInsurerCode,;
    referenceYear;
    WSSERVICE healthcare

Local oRequest := CenReqBi0():New(self, "bi0-get_single")

Default self:fields   := ""

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyFields(self:fields)
    oRequest:applyExpand(self:expand)
    oRequest:applyPageSize()
    oRequest:buscar(BUSCA)
    oRequest:procGet(SINGLE)
endif
oRequest:endRequest()
oRequest:destroy()
oRequest := nil
DelClassIntf()

Return .T.

WSMETHOD PUT Bi0Update PATHPARAM;
    uniqueKey;
    QUERYPARAM;
    healthInsurerCode,;
    referenceYear;
    WSSERVICE healthcare

Local oRequest := CenReqBi0():New(self, "bi0-put_update")

Default self:healthInsurerCode := ""
Default self:referenceYear := ""


oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:checkBody()
    oRequest:applyPageSize()
    oRequest:procPut()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.

WSMETHOD POST Bi0Insert WSSERVICE healthcare

    Local oRequest := CenReqBi0():New(self, "bi0-post_insert")

    Default self:healthInsurerCode := ""
    Default self:referenceYear := ""

    Default self:numeratorTissRatio := ""
    Default self:denominatorTissRatio := ""
    Default self:partialTissRatio := ""
    Default self:totalTissRatio := ""


    oRequest:initRequest()

    if oRequest:checkAuth()
        oRequest:checkBody()
        oRequest:applyFields(self:fields)
        oRequest:applyPageSize()
        oRequest:procPost()
    endif
    oRequest:endRequest()
    oRequest:destroy()
    DelClassIntf()

Return .T.

WSMETHOD DELETE Bi0Delete PATHPARAM;
    uniqueKey;
    QUERYPARAM;
    healthInsurerCode,;
    referenceYear;
    WSSERVICE healthcare

Local oRequest := CenReqBi0():New(self, "bi0-delete")

oRequest:initRequest()
if oRequest:checkAuth()
    oRequest:applyFilter(SINGLE)
    oRequest:applyPageSize()
    oRequest:buscar(SINGLE)
    oRequest:procDelete()
endif

oRequest:endRequest()
oRequest:destroy()
DelClassIntf()

Return .T.