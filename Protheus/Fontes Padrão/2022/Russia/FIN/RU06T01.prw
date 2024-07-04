#INCLUDE 'RU06T01.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'XMLXFUN.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RU06T01

Main programa
Download exchange rates from Central Bank of the Russian Federation

@param		None
@return		None
@author 	Fabio Cazarini
@since 		27/12/2016
@version 	1.0
@project	MA3
/*/
Function RU06T01()
	
Local cTitle AS CHAR
Local cDescricao AS CHAR

Private cPerg AS CHAR
Private cCadastro AS CHAR
Private aMV_ERDIS AS ARRAY

cTitle		:= STR0003 // "Download da taxa de cambio" 
cDescricao	:= STR0001 + STR0002//"O objetivo desta rotina e executar o download da taxa de cambio do dia e atualizar a "//"tabela SM2 - Cadastro de Moedas"
cPerg		:= PADR("RU06T01R", LEN(SX1->X1_GRUPO) )
cCadastro 	:= STR0003//"Download da taxa de cambio"
aMV_ERDIS	:= {}

//-----------------------------------------------------------------------
// Add itens array with iso 4217 codes from MV_ERDISnn   
//-----------------------------------------------------------------------
aMV_ERDIS := CurrencPar()

If Len(aMV_ERDIS) == 0
	MsgInfo(STR0004)//"Parametro MV_ERDISnn nao foi configurado corretamente"
	Return
Endif

Pergunte(cPerg,.f.)
If isBlind()
	RU06T01A()
Else
	tNewProcess():New( "RU06T01", cTitle, {|oSelf| RU06T01A( oSelf ) }, cDescricao, cPerg,,,,,, .T. )
EndIf

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06T01A()

Main program
Download Exchange Rates - Process

@param		Nenhum
@return		Nenhum
@author 	Fabio Cazarini
@since 		28/12/2016
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function RU06T01A( oSelf AS OBJECT )

Local cMV_ERDURL AS CHAR
Local aMV_ERDURL AS ARRAY
Local aDataReq AS ARRAY
Local nV AS NUMERIC
Local nW AS NUMERIC
Local nTamVar AS NUMERIC
Local aCurrency AS ARRAY
Local cCurrency AS CHAR
Local dDataIni AS DATE
Local dDataFin AS DATE
Local cStrCurr AS CHAR
Local nCntCur AS NUMERIC
Local lSchedule AS LOGICAL
Local aRates AS ARRAY
Local lOcurErr AS LOGICAL
Local lSaveOne AS LOGICAL
Local nTamaRates AS NUMERIC

aCurrency	:= {}
aDataReq	:= {}
cError		:= ""
cWarning	:= ""
nCntCur		:= 0
lSchedule	:= IsBlind()
aRates		:= {}

If !lSchedule
	oSelf:SetRegua1(3)
	oSelf:IncRegua1()
EndIf
	
//-----------------------------------------------------------------------
// Grupo - RU06T01
//-----------------------------------------------------------------------
// MV_PAR01 - 	Source / selection of the central bank code (new 
//				table from the 2.3.8 Changes in the existed tables and 
//				screens). Mandatory field.
// MV_PAR02 - 	Current rate / selection of values Yes/No 
// MV_PAR03 - 	Date from / selection of date. The field is active 
//				if value in the field Current rate is No. In this case it 
//				should be also mandatory.
// MV_PAR04 - 	Date to / selection of date. The field is active 
//				if value in the field Current rate is No. In this case it 
//				should be also mandatory and greater than Date from.
// MV_PAR05 - 	Currency ISO 4217 alphabetic currency code 
//				(specified in SX6 table)
//-----------------------------------------------------------------------
dDataIni 	:= MV_PAR03
dDataFin	:= MV_PAR04

//-----------------------------------------------------------------------
// Cen.Bank Russia|http://www.cbr.ru/scripts/XML_daily.asp?date_req=
//-----------------------------------------------------------------------
cMV_ERDURL 	:= GetMV("MV_ERDURL") 
If Empty(cMV_ERDURL)
	If !lSchedule
		oSelf:SaveLog(STR0005) //"Parametro MV_ERDURL nao configurado"
		MsgInfo(STR0005) // "Parametro MV_ERDURL nao configurado"
	Endif	
	Return
Endif

aMV_ERDURL	:= Separa(cMV_ERDURL, "|")
If Len(aMV_ERDURL) <> 2 
	If !lSchedule
		oSelf:SaveLog(STR0006) //"Parametro MV_ERDURL nao configurado corretamente"
		MsgInfo(STR0006) //"Parametro MV_ERDURL nao configurado corretamente"
	Endif	
	Return
EndIf

//-----------------------------------------------------------------------
// Validate parameters   
//-----------------------------------------------------------------------
If !(lSchedule .or. MV_PAR02 == 1) // Current rate
	If Empty(dDataIni)
		MsgInfo(STR0007)//"Informe a data inicial (de)"
		Return
	Endif

	If Empty(dDataFin)
		MsgInfo(STR0008)//"Informe da data final (para)"
		Return
	Endif

	If dDataFin < dDataIni
		MsgInfo(STR0009)//"Periodo de datas incorreto"
		Return
	Endif
Endif

If lSchedule // if execution by schedule
	cStrCurr := ""
Else
	cStrCurr := UPPER(ALLTRIM(MV_PAR05)) // string with currencies to be downloaded
	//cStrCurr := "BRL,USD,EUR,GBP,ARS"
Endif	

//-----------------------------------------------------------------------
// add itens array with currencies to be downloaded   
//-----------------------------------------------------------------------
For nW := 1 to Len(aMV_ERDIS)
	cCurrency := aMV_ERDIS[nW]
	If !Empty(cCurrency)
		If Empty(cStrCurr) .or. cCurrency $ cStrCurr // check if the currency has to be downloaded
			AADD( aCurrency, {cCurrency, nW} )
		Endif	
	Endif
Next nW

If Len(aCurrency) == 0
	If !lSchedule
		oSelf:SaveLog(STR0010) //"Moeda requisitada nao cadastrada"
		MsgInfo(STR0010)//"Moeda requisitada nao cadastrada"
	Endif	
	Return
Endif

//-----------------------------------------------------------------------
// add itens with resquested dates   
//-----------------------------------------------------------------------
If lSchedule .or. MV_PAR02 == 1 // Current rate
	aAdd( aDataReq, dDataBase )
Else
	If !Empty(dDataIni) .AND. !Empty(dDataFin)
		If dDataFin >= dDataIni
			Do while .T. 
				If dDataIni > dDataFin
					Exit
				Endif
				
				aAdd( aDataReq, dDataIni )
				dDataIni++	
			Enddo
		Endif
	Endif
Endif	 

//-----------------------------------------------------------------------
// Get XML with exchange rates for each date - Russian localization   
//-----------------------------------------------------------------------
aRates := RUGetData(oSelf, aMV_ERDURL, aDataReq, aCurrency)

//-----------------------------------------------------------------------
// Save array to SM2   
//-----------------------------------------------------------------------
If !lSchedule
	oSelf:IncRegua1()
EndIf

nTamaRates := Len(aRates)
If nTamaRates > 0
	If !lSchedule
		oSelf:SaveLog(STR0011)//"Salvando dados na tabela SM2"
	EndIf
	
	lOcurErr := .F.
	lSaveOne := .F.
	For nV := 1 to nTamaRates
		If !GravaSM2(aRates[nV])
			If !lSchedule
				oSelf:SaveLog(STR0012 + aRates[nV][2])//"Erro na gravacao da moeda na tabela SM2 "
			EndIf
			lOcurErr := .T.
		Else
			lSaveOne := .T.
		Endif
	Next nV

	If !lSchedule
		oSelf:IncRegua1()
	EndIf
	
	If lOcurErr
		If lSaveOne
			If !lSchedule
				oSelf:SaveLog(STR0013) //"Processo parcialmente completado"
				MsgInfo(STR0013)//"Processo parcialmente completado"
			Endif	
		Else
			If !lSchedule
				oSelf:SaveLog(STR0014) //"Processo nao concluido"
				MsgInfo(STR0014)//"Processo nao concluido"
			Endif	
		Endif
	Else
		If !lSchedule
			oSelf:SaveLog(STR0015) //"Processo completado com sucesso"
			MsgInfo(STR0015)//"Processo completado com sucesso"
		Endif	
	Endif
Else
	If !lSchedule
		oSelf:SaveLog(STR0014) //"Processo nao concluido"
		MsgInfo(STR0014) // "Processo nao concluido"
	Endif	
Endif

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} RUGetData()

Get XML with exchange rates for each date - Russian localization

@param		oSelf = tNewProcess objetc
			aMV_ERDURL = Central bank name and URL
			aDataReq = Dates array do download
			aCurrency = Currencies array to download
@return		aRates = Array with donloaded rates
@author 	Fabio Cazarini
@since 		09/01/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function RUGetData(oSelf AS OBJECT, aMV_ERDURL AS ARRAY, aDataReq AS ARRAY, aCurrency AS ARRAY)
Local aRates AS ARRAY
Local cNomBank AS CHAR
Local cURL AS CHAR
Local cDataReq AS CHAR
Local cXML AS CHAR
Local nY AS NUMERIC
Local nZ AS NUMERIC
Local oXML AS OBJECT
Local cError AS CHAR
Local cWarning AS CHAR
Local nCntCur AS NUMERIC
Local cCharCode AS CHAR
Local nValue AS NUMERIC
Local nNominal AS NUMERIC
Local nPosCurrency AS NUMERIC
Local lSchedule AS LOGICAL

lSchedule	:= isBlind()
aRates		:= {}

If !lSchedule
	oSelf:SaveLog(STR0016)//"Buscando XML com a taxa de cambio para cada data requisitada"
EndIf

cNomBank	:= ALLTRIM(aMV_ERDURL[1])

FOR nY := 1 to Len(aDataReq)
	cDataReq	:= STRZERO(DAY(aDataReq[nY]),2) + "." + STRZERO(MONTH(aDataReq[nY]),2) + "." + STRZERO(YEAR(aDataReq[nY]),4) // request date
	cURL 		:= ALLTRIM(aMV_ERDURL[2]) + cDataReq // URL to recover XML data
	If !Empty(cURL)
		cXML	:= HttpGet(cUrl)
		If !Empty(cXML)
			cError		:= ""
			cWarning	:= ""
			oXML 		:= XmlParser( cXML, "_", @cError, @cWarning )
			
			IF Empty(cError)
				IF "VALUTE" $ UPPER(cXML)				
					nCntCur := LEN(oXML:_ValCurs:_valute)
					FOR nZ := 1 to nCntCur
						cCharCode 	:= Padr(oXML:_ValCurs:_valute[nZ]:_charcode:text, 3) // ISO 4217 alpha code
						If !Empty(cCharCode)
							nValue 		:= VAL(STRTRAN(oXML:_ValCurs:_valute[nZ]:_value:text,",",".")) // exchange rate
							nNominal	:= VAL(STRTRAN(oXML:_ValCurs:_valute[nZ]:_nominal:text,",",".")) // exchange rate 
							If nNominal == 0
								nNominal := 1
							Endif
							nPosCurrency := Ascan(aCurrency, {|x| x[1] == cCharCode}) // locate position in array 
							If nPosCurrency > 0 .and. nValue > 0
								aAdd( aRates, {aDataReq[nY], cCharCode, nValue, nNominal, aCurrency[nPosCurrency]} )
							Endif
						Endif
					Next nZ
				Endif
			Endif
		Endif
	Endif	
Next nY

Return aRates


//-----------------------------------------------------------------------
/*/{Protheus.doc} GravaSM2()

Save array to SM2

@param		aRate[1] = Charcode, aRate[2] = Rate value
@return		Nenhum
@author 	Fabio Cazarini
@since 		09/01/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function GravaSM2(aRate AS ARRAY)
Local lRet AS LOGICAL
Local aSaveArea AS ARRAY
Local oModel AS OBJECT
Local dDataReq AS DATE
Local cCharCode AS CHAR
Local nValue AS NUMERIC
Local nNominal AS NUMERIC
Local nValMoeda AS NUMERIC
Local nIdMoeda AS NUMERIC
Local oAux AS OBJECT
Local oStruct AS OBJECT 
Local aAux AS ARRAY
Local nI AS NUMERIC
Local nX AS NUMERIC
Local nPos AS NUMERIC
Local aCpoMaster AS ARRAY
Local cCampo AS CHAR
Local cConteudo AS CHAR
Local nTamDec AS NUMERIC
Local lSchedule AS LOGICAL
Local lAux AS LOGICAL

lSchedule	:= IsBlind()
aSaveArea 	:= GetArea()
lRet		:= .T.
nTamDec		:= TAMSX3("M2_MOEDA1")[2]
aCpoMaster 	:= {}

dDataReq	:= aRate[1]
cCharCode	:= aRate[2]
nValue		:= aRate[3]
nNominal	:= aRate[4]
nIdMoeda	:= aRate[5][2]

nValMoeda	:= NoRound(nValue / nNominal, nTamDec)

//-----------------------------------------------------------------------
// data model 
//-----------------------------------------------------------------------
oModel := FWLoadModel( 'MATA090' )

dbSelectArea( "SM2" )
dbSetOrder( 1 ) // DTOS(M2_DATA)
If SM2 ->( dbSeek(dDataReq) )
	//-----------------------------------------------------------------------
	// If exist, update exchange rate
	//-----------------------------------------------------------------------
	oModel:SetOperation( MODEL_OPERATION_UPDATE )
	
	For nX := 1 to 99
		If nX == nIdMoeda
			aAdd( aCpoMaster, { "M2_MOEDA" + ALLTRIM(STR(nIdMoeda)) , nValMoeda } )
		Else
			cCampo 		:= "M2_MOEDA" + ALLTRIM(STR(nX))
			cConteudo	:= "SM2->" + cCampo
			If SM2->( FIELDPOS(cCampo) ) > 0
				aAdd( aCpoMaster, { cCampo , &cConteudo } )
			Else
				Exit
			Endif
		Endif
	Next nX
Else
	//-----------------------------------------------------------------------
	// If not exists, insert exchange rate
	//-----------------------------------------------------------------------
	oModel:SetOperation( MODEL_OPERATION_INSERT )
	
	aAdd( aCpoMaster, { 'M2_DATA' , dDataReq } )
	aAdd( aCpoMaster, { "M2_MOEDA" + ALLTRIM(STR(nIdMoeda)) , nValMoeda } )
Endif

//-----------------------------------------------------------------------
// Activate the model before assign values
//-----------------------------------------------------------------------
lRet := oModel:Activate()
If lRet
	oAux    := oModel:GetModel( 'SM2MASTER' )
	oStruct := oAux:GetStruct()
	aAux	:= oStruct:GetFields()
	
	If lRet
		//-----------------------------------------------------------------------
		// Assign data to model
		//-----------------------------------------------------------------------
		For nI := 1 To Len( aCpoMaster )
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoMaster[nI][1] ) } ) ) > 0
				If !( lAux := oModel:SetValue( 'SM2MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )
					lRet    := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf
	
	If lRet
		//-----------------------------------------------------------------------
		// Validating data - commit
		//-----------------------------------------------------------------------
		If ( lRet := oModel:VldData() )
			lRet := oModel:CommitData()
		Endif	
	EndIf
Endif

If !lRet
	//-----------------------------------------------------------------------
	// Invalid data
	//-----------------------------------------------------------------------
	aErro   := oModel:GetErrorMessage()

	AutoGrLog( STR0017 + " [" + AllToChar( aErro[1]  ) + "]" ) //"Id do submodelo de origem: "
	AutoGrLog( STR0018 + " [" + AllToChar( aErro[2]  ) + "]" ) //"Id do campo de origem:     "
	AutoGrLog( STR0019 + " [" + AllToChar( aErro[3]  ) + "]" ) //"Id do submodelo de erro:   "
	AutoGrLog( STR0020 + " [" + AllToChar( aErro[4]  ) + "]" ) //"Id do campo de erro:       "
	AutoGrLog( STR0021 + " [" + AllToChar( aErro[5]  ) + "]" ) //"Id do erro:                "
	AutoGrLog( STR0022 + " [" + AllToChar( aErro[6]  ) + "]" ) //"Mensagem do erro:          "
	AutoGrLog( STR0023 + " [" + AllToChar( aErro[7]  ) + "]" ) //"Mensagem da solucao:       "
	AutoGrLog( STR0024 + " [" + AllToChar( aErro[8]  ) + "]" ) //"Valor atribuido:           "
	AutoGrLog( STR0025 + " [" + AllToChar( aErro[9]  ) + "]" )//"Valor anterior:            "

	If !lSchedule
		MostraErro()
	Endif	
EndIf

//-----------------------------------------------------------------------
// DeActivate model
//-----------------------------------------------------------------------
oModel:DeActivate()

RestArea(aSaveArea)

Return lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} CurrencPar()

Add itens array with iso 4217 codes from MV_ERDISnn

@param		Nenhum
@return		aRet
@author 	Fabio Cazarini
@since 		10/01/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function CurrencPar()
Local aRet AS ARRAY
Local nX AS NUMERIC
Local cMV_ERDIS AS CHAR
Local cCurrency AS CHAR
Local nTamVar AS NUMERIC

aRet 	:= {}
nTamVar	:= Len( SX6->X6_VAR )

dbSelectArea( "SX6" )
dbSetOrder( 1 )
nX := 0
Do While .T.
	nX++
	cMV_ERDIS := "MV_ERDIS" + StrZero(nX,2)
	If SX6->( dbSeek( xFilial("SX6") + PadR( cMV_ERDIS, nTamVar ) ) )
		//-----------------------------------------------------------------------
		// Check if SX5 is up to dated 
		//-----------------------------------------------------------------------
		If !SX5->( dbSeek( xFilial("SX5") + "RU" + StrZero(nX,2) ) )
			//aRet 	:= {} // to return error to user
			//Exit
			Loop
		Endif
		
		cCurrency := Padr(GetMv( cMV_ERDIS ), 3)
		AADD(aRet, cCurrency)
	Else
		If nX > 1
			EXIT
		Else
			AADD(aRet, Space(03))
		Endif	
	EndIf
Enddo

Return aRet


Static Function SchedDef()

Local aParam := {}

aParam := {	"P"			,;
				"RU06T01"	,;	
				Nil			,;
				Nil			,;	
				Nil			}	

Return aParam