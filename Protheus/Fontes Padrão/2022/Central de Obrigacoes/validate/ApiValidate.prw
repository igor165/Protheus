#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05" 

Class ApiValidate

    Data oRest
    Data lIsValid

    Method New() Constructor
   
    Method valOpe(oCenProd)
    Method valSegmen(oCenProd)
    Method valAbrang(cAbrang)
    Method valForCon(cForCon)
    Method valSitAns(cSitAns)
    Method valExisProd(cCodigo, cCodOpe)
    Method valCco(cCodCco)
    Method valBlock(oCenBenefi) 
    Method valTipDep(cTipDep)
    Method valCodTit(cTipDep, cCodTit)
    Method valMatric(cMatric)

EndClass

Method New(oRest) Class ApiValidate
    self:oRest := oRest
    self:lIsValid := .T.
Return self

Method valOpe(cCodOpe) Class ApiValidate

    Local oCenVld := CenValidator():New()

    //Valida se existe a operadora do produto
    lExiste := oCenVld:valOpe(cCodOpe)
    
    if !lExiste
        self:lIsValid := .F.
        self:oRest:lSuccess     := .F.
        self:oRest:nFault       := 400
        self:oRest:nStatus      := 400
        self:oRest:cFaultDesc   := 'Operação não pode ser realizada.'
        self:oRest:cFaultDetail := 'Operadora '+ cValTochar(cCodOpe) +' não existe.'
        self:oRest:cResponse    := ''
    EndIf

    oCenVld:destroy()
    FreeObj(oCenVld)
    oCenVld := nil

Return

Method valSegmen(cSegmen) Class ApiValidate

    Local lExiste := .F.
    Local aSegmen := {"1", "2", "3", "4"}
    Local nX := 1
    Default cSegmen := ""
    
    For nX:= 1 to Len(aSegmen)
        If cSegmen == aSegmen[nX]
            lExiste := .T.
            nX := Len(aSegmen)
        EndIf
    Next

    //Valida se existe a segmentação
    If !lExiste
        self:lIsValid := .F.
        self:oRest:lSuccess     := .F.
        self:oRest:nFault       := 400
        self:oRest:nStatus      := 400
        self:oRest:cFaultDesc   := 'Operação não pode ser realizada.'
        self:oRest:cFaultDetail := 'Segmentação '+ cSegmen +' inválida. Opções válidas: 1 - Ambulatorial; 2 - Hospitalar; 3 - Hospitalar obstétrico; 4 - Odontológico" '
        self:oRest:cResponse    := ''        
    EndIf
   
    aSegmen := nil

Return

Method valAbrang(cAbrang) Class ApiValidate

    //Valida se abrangencia
    Local lExiste := .F.
    Local aAbrang := {"01", "02", "03", "04", "04", "05"}
    Local nX := 1
    Default cAbrang := ""
    
    For nX:= 1 to Len(aAbrang)
        If cAbrang == aAbrang[nX]
            lExiste := .T.
            nX := Len(aAbrang)
        EndIf
    Next
    
    if !lExiste
        self:lIsValid := .F.
        self:oRest:lSuccess     := .F.
        self:oRest:nFault       := 400
        self:oRest:nStatus      := 400
        self:oRest:cFaultDesc   := 'Operação não pode ser realizada.'
        self:oRest:cFaultDetail := 'Abrangência '+ cAbrang +' inválida. Opções válidas: 01 - Nacional; 02 - Estadual; 03 - Regional Grupo de Estados; 04 - Municipal; 05 - Regional Grupo de Municipios'
        self:oRest:cResponse    := ''
    EndIf

    aAbrang := nil

Return

Method valForCon(cForCon) Class ApiValidate

    //Valida se forma de contratação.
    Local lExiste := .F.
    Local aForCon := {"1", "2", "3"}
    Local nX := 1
    Default cForCon := ""

    For nX:= 1 to Len(aForCon)
        If cForCon == aForCon[nX]
            lExiste := .T.
            nX := Len(aForCon)
        EndIf
    Next
    
    if !lExiste
        self:lIsValid := .F.
        self:oRest:lSuccess     := .F.
        self:oRest:nFault       := 400
        self:oRest:nStatus      := 400
        self:oRest:cFaultDesc   := 'Operação não pode ser realizada.'
        self:oRest:cFaultDetail := 'Abrangência '+ cForCon +' inválida. Opções válidas: 1 - Individual/Familiar; 2 - Coletivo Empresarial; 3 - Coletivo por Adesão'
        self:oRest:cResponse    := ''
    EndIf

    aForCon := nil

Return

Method valSitAns(cSitAns) Class ApiValidate
    
    //Valida se forma de Situação ANS.
    Local lExiste := .F.
    Local aSitAns := {"A", "I"}
    Local nX := 1
    Default cSitAns := ""

    For nX:= 1 to Len(aSitAns)
        If cSitAns == aSitAns[nX]
            lExiste := .T.
            nX := Len(aSitAns)
        EndIf
    Next
    
    if !lExiste
        self:lIsValid := .F.
        self:oRest:lSuccess     := .F.
        self:oRest:nFault       := 400
        self:oRest:nStatus      := 400
        self:oRest:cFaultDesc   := 'Operação não pode ser realizada.'
        self:oRest:cFaultDetail := 'Situação ANS '+ cSitAns +' inválida. Opções válidas: A - Ativo; I - Inativo'
        self:oRest:cResponse    := ''
    EndIf

    aSitAns := nil

Return

Method valExisProd(cCodigo, cCodOpe) Class ApiValidate

    Local oDaoCenProd := DaoCenProd():New()
    Default cCodigo := ""
    Default cCodOpe := ""

    oDaoCenProd:setCodOpe(cCodOpe)
    oDaoCenProd:setCodigo(cCodigo)

    oDaoCenProd:cNumPage  := '1'
    oDaoCenProd:cPageSize := '1'

    //Valida se existe o produto
    lExiste := oDaoCenProd:buscar(SINGLE)
        
    if !lExiste
        self:lIsValid := .F.
        self:oRest:lSuccess     := .F.
        self:oRest:nFault       := 400
        self:oRest:nStatus      := 400
        self:oRest:cFaultDesc   := 'Operação não pode ser realizada.'
        self:oRest:cFaultDetail := 'Produto '+ cCodigo +' não existe.'
        self:oRest:cResponse    := ''
    EndIf

    oDaoCenProd:Destroy()
    FreeObj(oDaoCenProd)
    oDaoCenProd := nil

Return

Method valCco(cCodCco) Class ApiValidate

    Local   lIsVoid := .F.
    Default cCodCco := ""
    
    //Valida se existe o CCO é valido
    If Empty(cCodCco)
        lIsVoid := .T.
    EndIf
    
    if lIsVoid
        self:lIsValid := .F.
        self:oRest:lSuccess     := .F.
        self:oRest:nFault       := 400
        self:oRest:nStatus      := 400
        self:oRest:cFaultDesc   := 'Operação não pode ser realizada.'
        self:oRest:cFaultDetail := 'Codigo CCO invalido, CCO não pode ser vazio.'
        self:oRest:cResponse    := ''
    EndIf

Return

Method valBlock(oCenBenefi) Class ApiValidate

    Local lIsBlock := .F.
    If UPPER(oCenBenefi:getSitAns()) == "I" .AND. DTOS(oCenBenefi:getDatBlo()) <= DTOS(oCenBenefi:getDatInc())
        lIsBlock := .T.
    EndIf
    
    if lIsBlock
        self:lIsValid := .F.
        self:oRest:lSuccess     := .F.
        self:oRest:nFault       := 400
        self:oRest:nStatus      := 400
        self:oRest:cFaultDesc   := 'Operação não pode ser realizada.'
        self:oRest:cFaultDetail := 'Beneficiário '+ cValTochar(oCenBenefi:getMatric()) +' está bloqueado.'
        self:oRest:cResponse    := ''
    EndIf

Return

Method valTipDep(cTipDep) Class ApiValidate

    //Valida se forma de Situação ANS.
    Local lExiste := .F.
    Local aTipDep := {"01","03","04","06","08","10"}
    Local nX := 1
    Default cTipDep := ""

    For nX:= 1 to Len(aTipDep)
        If cTipDep == aTipDep[nX]
            lExiste := .T.
            nX := Len(aTipDep)
        EndIf
    Next
    
    if !lExiste
        self:lIsValid := .F.
        self:oRest:lSuccess     := .F.
        self:oRest:nFault       := 400
        self:oRest:nStatus      := 400
        self:oRest:cFaultDesc   := 'Operação não pode ser realizada.'
        self:oRest:cFaultDetail := 'Tipo de relacionamento com o titular '+ cValTochar(cTipDep) +' inválido. Opções válidas: 01 - Titular; 03 - Conjuge; 04 - Filho(a); 06 - Enteado(a); 08 - Pai/Mae; 10 - Outros.'
        self:oRest:cResponse    := ''
    EndIf

    aTipDep := nil

Return 

Method valMatric(cMatric)  Class ApiValidate

    Local   lIsVoid := .F.
    Default cMatric := ""
    
    //Valida se a Matricula é válida
    If Empty(cMatric)
        lIsVoid := .T.
    EndIf
    
    if lIsVoid
        self:lIsValid := .F.
        self:oRest:lSuccess     := .F.
        self:oRest:nFault       := 400
        self:oRest:nStatus      := 400
        self:oRest:cFaultDesc   := 'Operação não pode ser realizada.'
        self:oRest:cFaultDetail := 'subscriberId - Quando informado a matricula, valor não pode ser vazio.'
        self:oRest:cResponse    := ''
    EndIf

Return 
