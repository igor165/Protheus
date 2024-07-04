#include 'PROTHEUS.CH'

//-------------------------------------------------------------------
Function __JurBase() // Function Dummy
ApMsgInfo( 'JurBase -> Utilizar Classe ao inves da funcao' )
Return NIL 

CLASS JurBase from FWSERIALIZE

	Data ClassName
	Data lError
	Data cError
	Data lLog
	Data Timer

	Method New() CONSTRUCTOR
	Method SetClassName()
	Method ClassName()
	Method SetError()
	Method GetError()
	Method HasError()
	Method ShowError()
	Method SetLog()
	Method GetLog()
	Method GetMethods()
	Method SetPtInternal()
	Method SetTimer()
	Method GetTimer()

ENDCLASS

//------------------------------------------------------------------
METHOD New(lLog) CLASS JurBase

Default lLog := .F.

	Self:SetTimer()

	Self:ClassName := "JurBase"
	Self:lError    := .F.
	Self:cError    := ""
	Self:lLog      := lLog

Return Self

Method SetClassName(cClassName) Class JurBase

Default cClassName := "Class from JurBase"

	If ValType(cClassName) == "C"
		Self:ClassName := cClassName
	EndIf

Return Self:ClassName == cClassName

Method ClassName() Class JurBase
Return Self:ClassName

Method SetError(cError, aItens) Class JurBase
Default cError := ""
Default aItens := {}
	If ValType(cError) == "C"
		Self:cError := cError
		Self:lError := .T.
		If Self:GetLog()
			JurLogMsg(I18n(Self:ClassName+": "+ Self:cError, aItens))
		EndIf
	EndIf
Return Self:cError == cError

Method GetError() Class JurBase
Local cRet := ""
	If Self:lError
		cRet := Self:cError
	EndIf
Return cRet

Method HasError() Class JurBase
Return Self:lError

Method ShowError(lConsole) Class JurBase
Default lConsole := .T.

	If lConsole
		JurLogMsg(Self:GetError())
	Else
		Alert(Self:GetError())
	EndIf

Return Nil

Method SetLog(lLog) Class JurBase
Default lLog := .F.

	If ValType(lLog) == "L"
		Self:lLog := lLog
	EndIf

Return Self:lLog == lLog

Method GetLog() Class JurBase
Return Self:lLog

Method GetMethods(lConout, oClass, cName) Class JurBase
Local aMethods    := {}
Local cClassName  := ""

Default lConout := .F.
Default oClass  := Self
Default cName   := GetClassName(oClass)

	//aProperties := ClassDataArr(oConn)
	//aMethods    := ClassMethArr(oConn)
	//aClass      := __ClsArr()
	//aFuns       := __FunArr()
	//GetUserInfoArray()

	If oClass <> Nil
		aMethods    := ClassMethArr(oClass)
		cClassName := "of "+cName
		If lConout
			aEval(aMethods, {|aMethod| JurLogMsg(I18N("Method #1: #2", {cClassName, aMethod[1]})) })
		EndIf
	EndIf

Return aMethods

Method SetPtInternal(cText) Class JurBase

Default cText := "JurBase"

	If ValType(cText) == "C"
		PtInternal(1, cText)
	EndIf

Return Nil

Method SetTimer() Class JurBase
Return Self:Timer := Seconds()

Method GetTimer() Class JurBase
Return AllTrim(Str(Seconds() - Self:Timer,12,4))