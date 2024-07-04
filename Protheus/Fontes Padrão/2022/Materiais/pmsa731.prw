#include "protheus.ch"

#define PMS_NULL 0

/* ----------------------------------------------------------------------------

PmsTask

---------------------------------------------------------------------------- */
Class PmsTask Inherit PmsNode

	// metadados
	Data IsWbs As Boolean	
	Data Revision As String
  
	// códigos para uso no Protheus
	// serão inutilizados no futuro	
	// com o mais uso de OOP 
	Data TaskCode As String
	Data ProjectCode As String
	Data CalendarCode As String
	
	// custo
	Data Cost As Float
	Method GetCost()
	Method SetCost(Value)
	
	Data TotalCost As Float
	Method GetTotalCost()
	Method SetTotalCost(Value)
	
	Data UnitCost As Float
	Method GetUnitCost()
	Method SetUnitCost(Value)

	// markup
	Data Markup As Float
	Method GetMarkup()
	Method SetMarkup(Value)
	 
	Data MarkupValue As Float
	Method GetMarkupValue()
	Method SetMarkupValue(Value)
	
	Data MarkupPercent As Float
	Method GetMarkupPercent()
	Method SetMarkupPercent()

	Data UnitBdi As Float
	Method GetUnitBdi()
	Method SetUnitBdi()
	
	Data DefaultBdi As Float
	Method GetDefaultBdi()
	Method SetDefaultBdi()
	
	Data ConsiderBdi As Boolean
	Method GetConsiderBdi()
	Method SetConsiderBdi()
	
	// data de início prevista
	Data ExpectedStartDate As Date
	Data ExpectedStartTime As String
	
	// data início executada
	Data ExecutedStartDate As Date
	Data ExecutedStartTime As String

	// data de fim prevista
	Data ExpectedFinishDate As Date
	Data ExpectedFinishTime As String
	
	// data de fim executada
	Data ExecutedFinishDate As Date
	Data ExecutedFinishTime As String
	
	// duração
	Data Duration As Float
	Method GetDuration()
	Method SetDuration()
	
	Data ActualDuration As Float	
	Method GetActualDuration()
	Method SetActualDuration()

	// quantity	
	Data Quantity As Float
	Method GetQuantity()
	Method SetQuantity()
	
	// método de medição
	Data MeasurementMethod As String
	Method GetMeasurementMethod()
	Method SetMeasurementMethod()	

	//
	// TODO: "normalizar" as moedas abaixo,
	// criando um objeto
	//
	Data CurrencyRates As Float
	Method GetCurrencyRate()
	Method SetCurrencyRate()
	
	// descrição	
	Data Text As String
	Method GetText()
	Method SetText()
	
	Method New() Constructor	
EndClass

/* ----------------------------------------------------------------------------

PmsTask:New()

---------------------------------------------------------------------------- */
Method New() Class PmsTask
  
	// Node
	Self:Dirty := .F.
	Self:Id := PMS_NULL
	Self:ParentNode := Nil

	// metadados  
	Self:IsWbs := .F.
	Self:Revision := ""

	// códigos	
	Self:CalendarCode := ""
	Self:TaskCode := ""
	Self:ProjectCode := ""

	// custo	  
	Self:Cost := 0.0
	Self:TotalCost := 0.0
	Self:UnitCost := 0.0

	// markup
	Self:Markup := 0.0
	Self:MarkupValue  := 0.0
	Self:MarkupPercent := 0.0
	
	Self:UnitBdi := 0.0
	Self:DefaultBdi := 0.0
	
	Self:ConsiderBdi := .T.

	// data início prevista
	//Self:ExpectedStartDate := dDataBase
	Self:ExpectedStartTime := "00:00"
	
	// data início executada
	//Self:ExecutedStartDate := dDataBase
	Self:ExecutedStartTime := "00:00"

	// data de fim prevista
	//Self:ExpectedFinishDate := dDataBase
	Self:ExpectedFinishTime := "00:00"
	
	// data de fim executada
	//Self:ExecutedFinishDate := dDataBase
	Self:ExecutedFinishTime := "00:00"

	// duração
	Self:Duration := 0.0
	Self:ActualDuration := 0.0

	// quantidade		
	Self:Quantity := 0.0

	// método de medição
	Self:MeasurementMethod := "1"

	Self:CurrencyRates := {1, 0, 0, 0, 0}

	// descrição	
	Self:Text := ""
Return Self

Method GetCost() Class PmsTask
Return Self:Cost

Method SetCost(Value) Class PmsTask
	Self:Cost := Value
Return .T.
	
Method GetTotalCost() Class PmsTask
Return Self:TotalCost

Method SetTotalCost(Value) Class PmsTask
	Self:TotalCost := Value
Return .T.
	
Method GetUnitCost() Class PmsTask
Return Self:UnitCost

Method SetUnitCost(Value) Class PmsTask
	Self:UnitCost := Value
Return .T.

Method GetMarkup() Class PmsTask
Return Self:GetMarkup

Method SetMarkup(Value) Class PmsTask
	Self:Markup := Value
Return .T.
	 
Method GetMarkupValue() Class PmsTask
Return Selft:MarkupValue

Method SetMarkupValue(Value) Class PmsTask
	Self:MarkupValue := Value
Return .T.
	
Method GetMarkupPercent() Class PmsTask
Return MarkupPercent

Method SetMarkupPercent(Value) Class PmsTask
	Self:MarkupPercent := Value
Return .T.

Method GetDuration() Class PmsTask
Return Self:Duration

Method SetDuration(Value) Class PmsTask
	Self:Duration := Value
Return .T.
	
Method GetActualDuration() Class PmsTask
Return Self:ActualDuration

Method SetActualDuration(Value) Class PmsTask
	Self:ActualDuration := Value
Return .T.

Method GetQuantity() Class PmsTask
Return Self:Quantity

Method SetQuantity() Class PmsTask
	Self:Quantity := Value
Return .T.
	
Method GetMeasurementMethod() Class PmsTask
Return Self:GetMeasurementMethod
	
Method SetMeasurementMethod(Value) Class PmsTask
	Self:MeasurementMethod := Value
Return .T.

Method GetText() Class PmsTask
Return Self:Text

Method SetText(Value) Class PmsTask
	Self:Text := Value
Return .T.


/* ----------------------------------------------------------------------------

Task:GetCurrencyRate()

---------------------------------------------------------------------------- */
Method GetCurrencyRate(Index) Class PmsTask
	Default Index := 1
	
	If Index <= Len(Self:CurrencyRates)
		Return Self:CurrencyRates[Index]
	EndIf
Return 0.0

/* ----------------------------------------------------------------------------

Task:SetCurrencyRate()

---------------------------------------------------------------------------- */
Method SetCurrencyRate(Index, Value) Class PmsTask
  Default	Index := 1
  Default Value := 0.0

	If Index <= Len(Self:CurrencyRates)
		Self:CurrencyRates[Index] := Value
	EndIf
Return .T.

/* ----------------------------------------------------------------------------

_asfxzv()

Função dummy para permitir a geração de patch deste arquivo fonte.

---------------------------------------------------------------------------- */
Function _asfxzv()
Return Nil