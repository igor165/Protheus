#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe abstrata de um CenValidator
    @type  Class
    @author lima.everton
    @since 20190402
/*/
Class CenValidator
    Data cMsg
    
    Method New() Constructor
    Method destroy()
    Method validate()
    Method getErrMsg()
    Method valOpe(cCodOpe)
    Method valPer(oEntity)
    Method ValIdent(oEntity)
    Method valDatF(oEntity)
    Method valFormDt(oEntity)
    
EndClass

Method New() Class CenValidator
    self:cMsg := ""
Return self

Method destroy() Class CenValidator
Return

Method validate(oEntity) Class CenValidator
Return .T.

Method getErrMsg() Class CenValidator
Return self:cMsg

Method valOpe(cCodOpe) Class CenValidator

    Local oDaoCenOpe := DaoCenOpe():New()
    Default cCodOpe := ""

    oDaoCenOpe:cNumPage    := '1'
    oDaoCenOpe:cPageSize   := '1'

    oDaoCenOpe:setCodOpe(cCodOpe)
    lExiste := oDaoCenOpe:buscar("01")

    oDaoCenOpe:destroy()
    FreeObj(oDaoCenOpe)
    oDaoCenOpe := nil

Return lExiste

Method valPer(oEntity) Class CenValidator

    Local cPeriod := oEntity:getValue("periodCover")
    Local aRet    := {.T.,''}
    Local nI      := 0

    For nI := 1 to len(cPeriod)
        If IsDigit(Substr(cPeriod,nI,1))
            loop
        EndIf
        aRet := {.F., "1323 - Data Preenchida Incorretamente. Utilize o formato AAAAMM"}
        Return aRet
    Next nI

    If aRet[1] .AND. (Substr(cPeriod,1,2) <> '20';
    .OR. !(Substr(cPeriod,5,1) $ '0-1');
    .OR. ((Substr(cPeriod,5,1) == '1') .AND. !(Substr(cPeriod,6,1) $ '0-1-2'));
    .OR. len(cPeriod) != 6)
        aRet := {.F., "1323 - Data Preenchida Incorretamente. Utilize o formato AAAAMM"}
        Return aRet
    EndIf

Return aRet

Method valIdent(oEntity) Class CenValidator

    Local cIdent := oEntity:getValue("presetValueIdent") //202004
    Local aRet    := {.T.,''}

    If len(Alltrim(cIdent)) == 0 .OR. len(AllTrim(FWCutOff(cIdent))) == 0
        aRet := {.F., "5029 - Indicador inválido. "}
        Return aRet
    EndIf

Return aRet

Method valDatF(oEntity) Class CenValidator

    Local cIdent := oEntity:getValue("formProcDt") 
    
Return !Empty(cIdent)

Method valFormDt(oEntity) Class CenValidator
    local aRet     := {.T.,''}
    Local nLenDt   := 0
    local nI       := 0
    local nDatas   := 0
    local FieldPos := 0
    local aDates   := {}
    local aFormats := {}

    aAdd(aDates,{"collectionProtocolDate",oEntity:getValue("collectionProtocolDate")})
    aAdd(aDates,{"requestDate",oEntity:getValue("requestDate")})
    aAdd(aDates,{"paymentDt",oEntity:getValue("paymentDt")})
    aAdd(aDates,{"formProcDt",oEntity:getValue("formProcDt")})
    aAdd(aDates,{"invoicingEndDate",oEntity:getValue("invoicingEndDate")})
    aAdd(aDates,{"executionDate",oEntity:getValue("executionDate")})
    aAdd(aDates,{"authorizationDate",oEntity:getValue("authorizationDate")})
    aAdd(aDates,{"invoicingStartDate",oEntity:getValue("invoicingStartDate")})

    For nLenDt := 1 to len(aDates)
        if !empty(aDates[nLenDt][2])
            aAdd(aFormats,aDates[nLenDt])
        EndIf
    Next nLenDt

    For nDatas := 1 to len(aFormats)
        For nI := 1 to len(aFormats[nDatas][2])
            If IsDigit(Substr(aFormats[nDatas][2],nI,1))
                loop
            EndIf
            aRet[1] := .F.
            aRet[2] += 'Campo ' + aFormats[nDatas][1] + ' preenchido incorretamente utilize o formato AAAMMDD. '
        Next nI
        
        If (Substr(aDates[nDatas][2],1,2) <> '20';
        .OR. !(Substr(aDates[nDatas][2],5,1) $ '0-1');
        .OR. ((Substr(aDates[nDatas][2],5,1) == '1') .AND. !(Substr(aDates[nDatas][2],6,1) $ '0-1-2'));
        .OR. !(Substr(aDates[nDatas][2],7,1) $ '0-1-2-3');
        .OR. (Substr(aDates[nDatas][2],7,1) == '3') .AND. !(Substr(aDates[nDatas][2],8,1) $ '0-1');
        .OR. len(aDates[nDatas][2]) != 8)
            aRet[1] := .F.
            aRet[2] += 'Campo ' + aFormats[nDatas][1] + ' preenchido incorretamente utilize o formato AAAMMDD. '
        EndIf 
    Next nDatas

    aDates := nil
    aFormats := nil

return aRet
