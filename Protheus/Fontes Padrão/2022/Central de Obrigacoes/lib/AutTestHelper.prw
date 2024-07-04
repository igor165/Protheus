#Include 'Protheus.ch'

Class AutTestHelper FROM FWTestHelper
	
    Data aParam

    Method New() Constructor
    Method UTSetParam(cParam, xValue)
    Method UTRestParam(aParam)
    Method UTQueryDB(cTable,cField,cFilter,xValue,cFil,lAssert)
    Method toString(xValue)

EndClass

Method New() Class AutTestHelper
    self:aParam := {}
    _Super:New()
Return self

Method UTSetParam(cParam, xValue,lChange) Class AutTestHelper
    Local oCfgSvr := getCfgSvr()
    
    If oCfgSvr:usaDic()
        _Super:UTSetParam(cParam, xValue,lChange)
    Else
        oCfgSvr:setParam(cParam, xValue)
    EndIf
Return

Method UTRestParam(aParam) Class AutTestHelper
    Local oCfgSvr := getCfgSvr()
    if oCfgSvr:usaDic()
        _Super:UTRestParam(aParam)
    Else
        oCfgSvr:clearParam()
    EndIf
Return

Method UTQueryDB(cTable,cField,cFilter,xValue,cFil,lAssert) Class AutTestHelper
    Local oCfgSvr := getCfgSvr()
    Local oDaoTest := nil
    Local cValue := ""
    Local lOk := .T.
    if oCfgSvr:usaDic()
        _Super:UTQueryDB(cTable,cField,cFilter,xValue,cFil,lAssert)
    Else
        cValue := self:toString(xValue)
        oDaoTest := DaoTestHelper():New()

        oDaoTest:setTable(cTable)
        oDaoTest:setFilter(cFilter)
        oDaoTest:setField(cField)
        oDaoTest:setValue(cValue)
        lOk := oDaoTest:buscar()
        self:AssertTrue(lOk,"Não encotrou o valor esperado [" + cValue + "]" )

        oDaoTest:destroy()
        FreeObj(oDaoTest)
        oDaoTest := nil

    EndIf

    self:lOk := lOk

Return lOk

Method toString(xValue) Class AutTestHelper
	Local cValue := ""

	If xValue == Nil
		cValue := ""
	ElseIf ValType( xValue ) == "N"
		cValue := AllTrim(Str(xValue))
	ElseIf ValType( xValue ) == "C"
		cValue := xValue
	ElseIf ValType( xValue ) == "D"
		cValue := DTOS(xValue)
	EndIf

Return cValue