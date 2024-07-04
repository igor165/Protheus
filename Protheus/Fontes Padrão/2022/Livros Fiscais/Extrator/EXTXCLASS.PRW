#INCLUDE "EXTXDEF.CH"
//#INCLUDE "TAFXClass.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} _ExtXClass
	
	@param: <void>

    @return: .T.

	@author Rodrigo dos Santos  
	
	@since 23/12/2013
	@version 1.0

/*/
//-------------------------------------------------------------------
//dummy function (utilizada para a geracao de Patch)
Function _ExtXClass() 
Return(.T.)
//-------------------------------------------------------------------
/*/{Protheus.doc} xExtProgress

	Retorna String para uso durante rotina de Processamento
	
	@param: <void>
	
	@author Rodrigo dos Santos  
	
	@since 27/12/2013
	@version 1.0
/*/
//-------------------------------------------------------------------
Class xExtProgress From LongNameClass
	
	DATA aProgress	AS ARRAY INIT Array(0) HIDDEN
	
	DATA nMax		AS NUMERIC INIT 0      HIDDEN
	DATA nProgress	AS NUMERIC INIT 0      HIDDEN
	
	DATA lShuttle   AS LOGICAL INIT .F.    HIDDEN

	Method New(cProgress,cToken)  CONSTRUCTOR

	Method ClassName()

	Method SetProgress(cProgress,cToken)

	Method Eval(cMethod,cAlign)
	Method Progress()
	Method Increment(cAlign)
	Method Decrement(cAlign)
	Method Shuttle(cAlign)
	Method Junction(cAlign)
	Method Dispersion(cAlign)
	Method Disjunction(cAlign)
	Method Union(cAlign)
	Method Occult(cAlign)
	
	Method GetnMax()
	Method GetnProgress()

EndClass

Method New(cProgress,cToken) Class xExtProgress
	self:SetProgress(@cProgress,@cToken)
Return(self)

Method ClassName() Class xExtProgress
Return("xExtPROGRESS")

Method SetProgress(cProgress,cToken) Class xExtProgress
	Local lMacro
	DEFAULT cProgress	:= "-;\;|;/"
	DEFAULT cToken		:= ";"	
	lMacro := (SubStr(cProgress,1,1)=="&")
	IF (lMacro)
		cProgress		:= SubStr(cProgress,2)
		cProgress		:= &(cProgress)
	EndIF
	//Débitos Técnicos TAF-Fiscal - NoFuncW
	//self:aProgress	:= xExtStrToKArr(@cProgress,@cToken)
	self:nMax			:= Len(self:aProgress)
	self:nProgress		:= 0
Return(self)

Method Eval(cMethod,cAlign) Class xExtProgress
	Local cEval
	DEFAULT cMethod := "PROGRESS"
	cMethod := Upper(AllTrim(cMethod))
	DO CASE
	CASE (cMethod=="PROGRESS")
		cEval := self:Progress()
	CASE (cMethod=="INCREMENT")
		cEval := self:Increment(@cAlign)
	CASE (cMethod=="DECREMENT")
		cEval := self:Decrement(@cAlign)
	CASE (cMethod=="SHUTTLE")	
		cEval := self:Shuttle(@cAlign)
	CASE (cMethod=="JUNCTION")	
		cEval := self:Junction(@cAlign)
	CASE (cMethod=="DISPERSION")
		cEval := self:Dispersion(@cAlign)	
	CASE (cMethod=="DISJUNCTION")
		cEval := self:Disjunction(@cAlign)	
	CASE (cMethod=="UNION")
		cEval := self:Union(@cAlign)	
	CASE (cMethod=="OCCULT")
		cEval := self:Occult(@cAlign)	
	OTHERWISE
		cEval := self:Progress()	
	ENDCASE
Return(cEval)

Method Progress() Class xExtProgress
Return(self:aProgress[IF(++self:nProgress>self:nMax,self:nProgress:=1,self:nProgress)])

Method Increment(cAlign) Class xExtProgress
	Local cPADFunc  	:= "PAD"
	Local cProgress 	:= ""
	Local nProgress
	Local nsProgress
	DEFAULT cAlign  	:= "R" //L,C,R
	IF Empty(cAlign)
		cAlign := "R"
	EndIF
	IF (++self:nProgress>self:nMax)
		self:nProgress := 1
	EndIF
	nsProgress := self:nProgress
	IF (cAlign=="C")
		++nsProgress
		IF (nsProgress>self:nMax)
			nsProgress := 1
		EndIF
	EndIF
	For nProgress := 1 To nsProgress
		cProgress += self:aProgress[nProgress]
	Next nProgress
	cPADFunc += cAlign
Return(&cPADFunc.(cProgress,self:nMax))

Method Decrement(cAlign) Class xExtProgress
	Local cPADFunc  := "PAD"
	Local cProgress := ""
	Local nProgress 
	Local nsProgress
	DEFAULT cAlign  := "L" //L,C,R
	IF Empty(cAlign)
		cAlign := "L"
	EndIF
	IF (++self:nProgress>self:nMax)
		self:nProgress := 1
	EndIF
	nsProgress := Max((self:nMax-self:nProgress),1)
	IF (cAlign=="C")
		--nsProgress
		IF (nsProgress<=0)
			nsProgress := self:nMax
		EndIF
	EndIF
	For nProgress := self:nMax To nsProgress STEP (-1)
		cProgress += self:aProgress[(self:nMax-nProgress)+1]
	Next nProgress
	cPADFunc += cAlign
Return(&cPADFunc.(cProgress,self:nMax))

Method Shuttle(cAlign) Class xExtProgress
	Local cEval
	IF (.NOT.(self:lShuttle).and.(self:nProgress>=self:nMax))
		self:lShuttle := .T.
	ElseIF (self:lShuttle.and.(self:nProgress>=self:nMax))
		self:lShuttle := .F.
	EndIF
	IF (self:lShuttle)
		cEval  := "DECREMENT" 
		cAlign := "L"
	Else
		cEval  := "INCREMENT"
		cAlign := "R"
	EndIF
Return(self:Eval(cEval,@cAlign))

Method Junction(cAlign) Class xExtProgress
	Local cLToR		:= ""
	Local cRToL		:= ""	
	Local cProgress	:= ""
	Local cPADFunc  := "PAD"
	Local nProgress
	DEFAULT cAlign  := "R" //L,C,R
	IF Empty(cAlign)
		cAlign := "R"
	EndIF
	IF (++self:nProgress>self:nMax)
		self:nProgress := 1
	EndIF
	For nProgress := 1 To self:nProgress 
		cLToR += self:aProgress[nProgress]
	Next nProgress
	For nProgress := self:nMax To Min(((self:nMax-self:nProgress)+1),self:nMax) STEP (-1)
		cRToL += self:aProgress[nProgress]
	Next nProgress
	self:nProgress += Len(cRToL)
	self:nProgress := Min(self:nProgress,self:nMax)
	cProgress += cLToR
	cProgress += Space(self:nMax-self:nProgress)
	cProgress += cRToL
	cPADFunc  += cAlign
Return(&cPADFunc.(cProgress,self:nMax))

Method Dispersion(cAlign) Class xExtProgress
	Local cEval
	DEFAULT cAlign  := "R" //L,C,R
	IF Empty(cAlign)
		cAlign := "R"
	EndIF
	IF (cAlign=="R")
		cEval := "INCREMENT"
	Else
		cEval := "DECREMENT"
	EndIF	
Return(self:Eval(cEval,"C"))

Method Disjunction(cAlign) Class xExtProgress
	Local cPADFunc  := "PAD"
	Local cProgress	:= ""
	Local nAT
	DEFAULT cAlign  := "C" //L,C,R
	IF Empty(cAlign)
		cAlign := "C"
	EndIF
	IF (++self:nProgress>self:nMax)
		self:nProgress := 1
	EndIF
	aEval(self:aProgress,{|p|cProgress+=p})
	IF (self:nProgress>1)
		nAT       := Int(self:nMax/self:nProgress)
		cProgress := SubStr(cProgress,1,nAT)
		cProgress += Space(self:nProgress-1)+cProgress
	EndIF
	cPADFunc += cAlign
Return(&cPADFunc.(cProgress,self:nMax))

Method Union(cAlign) Class xExtProgress
	Local cPADFunc  := "PAD"
	Local cProgress	:= ""
	Local nAT
	Local nQT
	DEFAULT cAlign  := "C" //L,C,R
	IF Empty(cAlign)
		cAlign := "C"
	EndIF
	IF (++self:nProgress>self:nMax)
		self:nProgress := 1
	EndIF
	aEval(self:aProgress,{|p|cProgress+=p})
	IF (self:nProgress>1)
		nAT := Round(self:nMax/self:nProgress,0)
		IF (Mod(self:nMax,2)==0)
			nQT := ((self:nProgress-1)*2)
		Else
			nQT := ((self:nProgress-1)*3)
		EndIF
		cProgress := Stuff(cProgress,nAT,nQT,"")
	EndIF
	cPADFunc  += cAlign
Return(&cPADFunc.(cProgress,self:nMax))

Method Occult(cAlign) Class xExtProgress
	Local cPADFunc  := "PAD"
	Local cProgress := ""
	Local nProgress 
	Local nsProgress
	DEFAULT cAlign  := "L" //L,C,R
	IF Empty(cAlign)
		cAlign := "L"
	EndIF
	IF (++self:nProgress>self:nMax)
		self:nProgress := 1
	EndIF
	nsProgress := self:nProgress
	IF (cAlign=="C")
		++nsProgress
		IF (nsProgress>self:nMax)
			nsProgress := 1
		EndIF
	EndIF
	For nProgress := self:nMax To nsProgress STEP (-1)
		cProgress += self:aProgress[(self:nMax-nProgress)+1]
	Next nProgress
	cPADFunc += cAlign
Return(&cPADFunc.(cProgress,self:nMax))

Method GetnMax() Class xExtProgress
Return(self:nMax)

Method GetnProgress() Class xExtProgress
Return(self:nProgress)

//-------------------------------------------------------------------
/*/{Protheus.doc} xExtTimeCalc

	Time Calc
	
	@param: <void>
	
	@author Rodrigo dos Santos  
	
	@since 31/12/2013
	@version 1.0
/*/
//-------------------------------------------------------------------
Class xExtTimeCalc From LongNameClass
	Method New() CONSTRUCTOR
	Method ClassName()	
	Method HMSToTime(nHours,nMinuts,nSeconds)
	Method SecsToHMS(nSecsToHMS,nHours,nMinuts,nSeconds,cRet)
	Method SecsToTime(nSecs)
	Method TimeToSecs(cTime)
	Method SecsToHrs(nSeconds)
	Method HrsToSecs(nHours)
	Method SecsToMin(nSeconds)
	Method MinToSecs(nMinuts)
	Method IncTime(cTime,nIncHours,nIncMinuts,nIncSeconds)
	Method DecTime(cTime,nDecHours,nDecMinuts,nDecSeconds)
	Method Time2NextDay(cTime,dDate)
	Method ExtractTime(cTime,nHours,nMinutes,nSeconds,cRet)
	Method MediumTime(cTime,nDividendo,lMiliSecs)
EndClass

Method New() Class xExtTimeCalc
Return(self)

Method ClassName() Class xExtTimeCalc
Return("xExtTIMECALC")

Method HMSToTime(nHours,nMinuts,nSeconds) Class xExtTimeCalc

	Local cTime
	
	DEFAULT nHours		:= 0
	DEFAULT nMinuts		:= 0
	DEFAULT nSeconds	:= 0
	
	cTime := AllTrim(Str(nHours))
	cTime := StrZero(Val(cTime),Max(Len(cTime),2))
	cTime += ":"
	cTime += StrZero(Val(AllTrim(Str(nMinuts))),2)
	cTime += ":"
	cTime += StrZero(Val(AllTrim(Str(nSeconds))),2)

Return(cTime)

Method SecsToHMS(nSecsToHMS,nHours,nMinuts,nSeconds,cRet) Class xExtTimeCalc

	Local nRet	:= 0
	
	DEFAULT nSecsToHMS	:= 0
	DEFAULT cRet		:= "H"
	
	nHours		:= self:SecsToHrs(nSecsToHMS)
	nMinuts		:= self:SecsToMin(nSecsToHMS)
	nSeconds	:= (self:HrsToSecs(nHours)+self:MinToSecs(nMinuts))
	nSeconds	:= (nSecsToHMS-nSeconds)
	nSeconds	:= Int(nSeconds)
	nSeconds	:= Mod(nSeconds,60)
	
	IF (cRet$"Hh")
		nRet := nHours
	ElseIF (cRet$"Mm")
		nRet := nMinuts
	ElseIF (cRet$"Ss")
		nRet := nSeconds
	EndIF

Return(nRet)

Method SecsToTime(nSecs) Class xExtTimeCalc
	Local nHours
	Local nMinuts
	Local nSeconds
	self:SecsToHMS(nSecs,@nHours,@nMinuts,@nSeconds)
Return(self:HMSToTime(nHours,nMinuts,nSeconds))

Method TimeToSecs(cTime) Class xExtTimeCalc

	Local nHours
	Local nMinuts
	Local nSeconds
	
	DEFAULT cTime	:= "00:00:00"
	
	self:ExtractTime(cTime,@nHours,@nMinuts,@nSeconds)
	
	nMinuts		+= __Hrs2Min(nHours)
	nSeconds	+= (nMinuts*60)

Return(nSeconds)

Method SecsToHrs(nSeconds) Class xExtTimeCalc
	Local nHours
	nHours	:= (nSeconds/3600)
	nHours	:= Int(nHours)
Return(nHours)

Method HrsToSecs(nHours) Class xExtTimeCalc
Return((nHours*3600))

Method SecsToMin(nSeconds) Class xExtTimeCalc
	Local nMinuts
	nMinuts		:= (nSeconds/60)
	nMinuts		:= Int(nMinuts)
	nMinuts		:= Mod(nMinuts,60)
Return(nMinuts)

Method MinToSecs(nMinuts) Class xExtTimeCalc
Return((nMinuts*60))

Method IncTime(cTime,nIncHours,nIncMinuts,nIncSeconds) Class xExtTimeCalc

	Local nSeconds
	Local nMinuts
	Local nHours
	
	DEFAULT nIncHours	:= 0
	DEFAULT nIncMinuts	:= 0
	DEFAULT nIncSeconds	:= 0
	
	self:ExtractTime(cTime,@nHours,@nMinuts,@nSeconds)
	
	nHours		+= nIncHours
	nMinuts		+= nIncMinuts
	nSeconds	+= nIncSeconds
	nSeconds	:= (self:HrsToSecs(nHours)+self:MinToSecs(nMinuts)+nSeconds)
	
Return(self:SecsToTime(nSeconds))

Method DecTime(cTime,nDecHours,nDecMinuts,nDecSeconds) Class xExtTimeCalc

	Local nSeconds
	Local nMinuts
	Local nHours
	
	DEFAULT nDecHours	:= 0
	DEFAULT nDecMinuts	:= 0
	DEFAULT nDecSeconds	:= 0
	
	self:ExtractTime(cTime,@nHours,@nMinuts,@nSeconds)
	
	nHours		-= nDecHours
	nMinuts		-= nDecMinuts
	nSeconds	-= nDecSeconds
	nSeconds	:= (self:HrsToSecs(nHours)+self:MinToSecs(nMinuts)+nSeconds)
	
Return(self:SecsToTime(nSeconds))

Method Time2NextDay(cTime,dDate) Class xExtTimeCalc
	While (Val(cTime)>=24)
		cTime := self:DecTime(cTime,24)
		++dDate
	End While
Return({cTime,dDate})

Method ExtractTime(cTime,nHours,nMinutes,nSeconds,cRet) Class xExtTimeCalc

	Local nRet		:= 0
	
	Local nAT
	
	DEFAULT cTime	:= "00:00:00"
	DEFAULT cRet	:= "H"
	
	nAT	:= AT(":",cTime)
	
	IF (nAT == 0)
		nHours	:= Val(cTime)
		nMinutes:= 0
		nSeconds:= 0
	Else
		nHours	:= Val(SubStr(cTime,1,nAT-1))
		cTime	:= SubStr(cTime,nAT+1)
		nAT		:= (At(":",cTime))
		IF (nAT == 0)
			nMinutes := Val(cTime)
			nSeconds := 0
		Else
			nMinutes := Val(SubStr(cTime,1,nAT-1))
			nSeconds := Val(SubStr(cTime,nAT+1))
		EndIF
	EndIF
	
	IF (cRet$"Hh")
		nRet := nHours
	ElseIF (cRet$"Mm")
		nRet := nMinutes
	ElseIF (cRet$"Ss")
		nRet := nSeconds
	EndIF

Return(nRet)

Method MediumTime(cTime,nDividendo,lMiliSecs) Class xExtTimeCalc

	Local cMediumTime	:= "00:00:00:000"
	
	Local nSeconds
	Local nMediumTime
	Local nMiliSecs
	
	DEFAULT nDividendo := 0
	
	IF (nDividendo>0)
	
		nSeconds	:= self:TimeToSecs(cTime)
		nSeconds	:= (nSeconds/nDividendo)
		nMediumTime	:= Int(nSeconds)
	
		nMiliSecs	:= (nSeconds-nMediumTime)
		nMiliSecs	*= 1000
		nMiliSecs	:= Int(nMiliSecs)
	
		cMediumTime	:= self:SecsToTime(nMediumTime)

	EndIF
	
	DEFAULT lMiliSecs		:= .T.
	IF (lMiliSecs)
		DEFAULT nMiliSecs	:= 0
 		cMediumTime += (":"+StrZero(nMiliSecs,IF(nMiliSecs>999,4,3)))
	EndIF

Return(cMediumTime)

//-------------------------------------------------------------------
/*/{Protheus.doc} xExtRemaining

	Remaining Time	
	
	@param: <void>
	
	@author Rodrigo dos Santos  
	
	@since 31/12/2013
	@version 1.0
/*/
//-------------------------------------------------------------------
Class xExtRemaining From xExtTimeCalc
	
	DATA cMediumTime	AS CHARACTER INIT "00:00:00:000" HIDDEN
	DATA cEndTime  		AS CHARACTER INIT "00:00:00"     HIDDEN
	DATA cStartTime  	AS CHARACTER INIT "00:00:00"     HIDDEN
	DATA cTimeDiff  	AS CHARACTER INIT "00:00:00"     HIDDEN
	DATA cTRemaining  	AS CHARACTER INIT "00:00:00"     HIDDEN
	DATA dEndTime		AS DATE      INIT Ctod("//")     HIDDEN
	DATA dStartTime		AS DATE      INIT Ctod("//")     HIDDEN
	DATA nProgress		AS NUMERIC   INIT 0			     HIDDEN	
	DATA nSRemaining	AS NUMERIC   INIT 0			     HIDDEN
	DATA nTotal			AS NUMERIC   INIT 0			     HIDDEN

	//-------------------------------------------------------------------
	// EXPORTED: Instancia um novo objeto
	Method New(nTotal) CONSTRUCTOR

	//-------------------------------------------------------------------
	// EXPORTED: Retorna o Nome da Classe
	Method ClassName()

	//-------------------------------------------------------------------
	// EXPORTED: Seta novo Total para Calcule()
	Method SetRemaining(nTotal)

	//-------------------------------------------------------------------
	// EXPORTED: Para Obter os Tempos utilize o Metodo Calcule
	Method Calcule(lProgress)

	//-------------------------------------------------------------------
	// EXPORTED: Retorna os Valores das Propriedades
	Method GetcMediumTime()
	Method GetcEndTime()
	Method GetcStartTime()
	Method GetcTimeDiff()
	Method GetcTRemaining()
	Method GetdEndTime()
	Method GetdStartTime()
	Method GetnProgress()
	Method GetnSRemaining()
	Method GetnTotal()
	
EndClass

Method New(nTotal) Class xExtRemaining
	_Super:New()
	self:SetRemaining(@nTotal)
Return(self)

Method ClassName() Class xExtRemaining
Return("xExtREMAINING'")

Method SetRemaining(nTotal) Class xExtRemaining
	DEFAULT nTotal 		:= 1
	self:cMediumTime	:= "00:00:00:000"
	self:cEndTime		:= "00:00:00"
	self:cStartTime		:= Time()
	self:cTimeDiff		:= "00:00:00"
	self:cTRemaining	:= "00:00:00"
	self:dEndTime		:= CToD("//")
	self:dStartTime		:= Date()
	self:nProgress		:= 0
	self:nSRemaining	:= 0
	self:nTotal			:= nTotal
Return(self)

Method Calcule(lProgress) Class xExtRemaining
	
	Local aEndTime

	Local cTime		:= Time()
	Local dDate		:= Date()

	Local nIncTime	:= 0
	
	Local nTime
	Local nTimeEnd
	Local nTimeDiff
	Local nStartTime

	IF .NOT.(dDate==Self:dStartTime)
		nIncTime	:= abs(dDate-self:dStartTime)
		nIncTime	*= 24
	EndIF	

	nTime				:= (self:TimeToSecs(cTime)+IF(nIncTime>0,self:HrsToSecs(nIncTime),0))
	nStartTime			:= self:TimeToSecs(self:cStartTime)	

	nTimeDiff			:= abs(nTime-nStartTime)
	self:cTimeDiff		:= self:SecsToTime(nTimeDiff)
	self:cTRemaining	:= self:SecsToTime(abs(nTimeDiff-nStartTime))
	self:nSRemaining	:= nTimeDiff

	DEFAULT lProgress	:= .T.
	IF (lProgress)
		++self:nProgress
	EndIF

	self:cMediumTime		:= self:MediumTime(self:cTimeDiff,self:nProgress,.T.)

	IF self:nTotal<self:nProgress
		nTimeEnd       := self:nTotal
		self:nTotal    := self:nProgress
		self:nProgress := nTimeEnd
	EndIF
	nTimeEnd := (((self:nTotal-self:nProgress)*self:nSRemaining)/self:nProgress)
	self:cEndTime			:= self:SecsToTime(nTimeEnd)
	self:cEndTime			:= self:IncTime(cTime,NIL,NIL,self:TimeToSecs(self:cEndTime))
	aEndTime				:= self:Time2NextDay(self:cEndTime,dDate)
	self:cEndTime			:= aEndTime[1]
	self:dEndTime			:= aEndTime[2]

Return(self)

Method GetcMediumTime() Class xExtRemaining
Return(self:cMediumTime)

Method GetcEndTime() Class xExtRemaining
Return(self:cEndTime)

Method GetcStartTime() Class xExtRemaining
Return(self:cStartTime)

Method GetcTimeDiff() Class xExtRemaining
Return(self:cTimeDiff)

Method GetcTRemaining() Class xExtRemaining
Return(self:cTRemaining)

Method GetdEndTime() Class xExtRemaining
Return(self:dEndTime)

Method GetdStartTime() Class xExtRemaining
Return(self:dStartTime)

Method GetnProgress() Class xExtRemaining
Return(self:nProgress)

Method GetnSRemaining() Class xExtRemaining
Return(self:nSRemaining)

Method GetnTotal() Class xExtRemaining
Return(self:nTotal)