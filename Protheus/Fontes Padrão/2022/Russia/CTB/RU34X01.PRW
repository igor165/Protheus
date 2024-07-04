#INCLUDE "PROTHEUS.CH"

/* 
currency exchage rate for initialization
@Return cRet char -- exchage rate
@Author Victor Guberniev
@Since 19/01/2018
@Release: 12.1.17 (Janeiro/2018)
@changed Eduardo.Flima
*/
Function Ct102RatM2()
	Local nRate 	as Numeric
	Local cMoeda 	as char
	Local cCur 		as char
	Local aAreaCTx 	as Array
	Local lExistTmp	AS LOGICAL

	lExistTmp	:= ! Empty(Select("TMP"))

	nRate		:= 1
	cMoeda		:= "" 
	cCur		:= ""
	aAreaCTx	:= {}

	aAreaCTx	:= getArea()
	cCur		:= IIf(lExistTmp, TMP->CT2_ORGCUR, CT2->CT2_ORGCUR)

	If cCur!=nil .and. !Empty (cCur)
		cMoeda := SUBSTR( cCur, 2, 1)
		dbSelectArea("SM2")
		SM2->(dbsetOrder(1))
		If SM2->(dbSeek(DDATALANC,.T.))
			nRate := Iif((&("SM2->M2_MOEDA"+cMoeda)==0),1,&("SM2->M2_MOEDA"+cMoeda)) // If there is no rates, set rate = 1 (as for own national currency)
			If lExistTmp .And. Empty(ReadVar())
				TMP->CT2_EXRATE:=nRate 
				TMP->CT2_VCONVE:=TMP->CT2_VORIGI*nRate 
			Endif 
		Endif 
	Endif
	RestARea(aAreaCTx)	
Return nRate 




/*
@Param cCur char(2) - currency code
@Return cConver char -- conversation string
@Author Victor Guberniev
@Since 28/12/2017
@Release: 12.1.17 (Janeiro/2018)
@changed Eduardo.Flima
*/

FUNCTION Ct102CnvM2 ()

	Local cConver 	as char
	Local cCur 		as char
	Local aAreaCTO	as Array
	Local nMoedas	as Numeric           
	Local lExistTmp	AS LOGICAL

	lExistTmp	:= ! Empty(Select("TMP"))

	cConver		:= '1'
	cCur		:= IIf(lExistTmp, TMP->CT2_ORGCUR, CT2->CT2_ORGCUR)
	aAreaCTO	:= {}
	nMoedas		:= 0                   
	aAreaCTO	:= getArea()
	
	dbSelectArea("CTO")
	dbSetOrder(1)
	For nMoedas	:= 2 to __nQuantas            
		dbSeek(xFilial("CTO")+StrZero(nMoedas,2))
		If (CTO->CTO_MOEDA == cCur) .and. (CTO->CTO_MOEDA <> '01')
			cConver := cConver + '4'
		Elseif (CTO->CTO_MOEDA <> '01')
			cConver := cConver + '5'  
		Endif
	Next	
	RestARea(aAreaCTO)	
Return cConver


/*
name of currency
@Param cCur char(2) - currency code
@Return nRate char -- name of currency
@Author Victor Guberniev
@Since 02/02/2018
@Release: 12.1.17 (Janeiro/2018)
@changed Eduardo.Flima
*/

Function Ct102CuNam()
	Local cRet 		as char
	Local cMoeda 	as char
	Local aAreaCTO 	as Array
	Local lExistTmp	AS LOGICAL

	lExistTmp	:= ! Empty(Select("TMP"))

	cRet:= ""
	cMoeda:= "" 
	aAreaCTO		:= {}
	
	aAreaCTO := getArea()	
	dbSelectArea("CTO")
	dbSetOrder(1)
	If lExistTmp .And. dbSeek(xFilial("CTO")+TMP->CT2_ORGCUR)
		TMP->CT2_CURNAM := CTO->CTO_DESC
		TMP->CT2_CURDES := CTO->CTO_DESC
		cRet := CTO->CTO_DESC		
	EndIf
	RestARea(aAreaCTO)	
Return cRet


/*
value in original currency for initialization
@Return cRet char -- value in original currency
@Author Victor Guberniev
@Since 01/02/2018
@Release: 12.1.17 (Janeiro/2018)
@changed Eduardo.Flima
*/

Function Ct102OrgVl()
	Local nVal 		as Numeric
	Local cCur 		as char
	Local aAreaCTx 	as Array
	Local lExistTmp	AS LOGICAL

	lExistTmp	:= ! Empty(Select("TMP"))

	nVal:= 0
	cCur:= ""
	aAreaCTx		:= {}
	
	aAreaCTx := getArea()
	If lExistTmp .And. (TMP->CT2_ORGCUR == "01" .or. Empty(TMP->CT2_ORGCUR))
		nVal := TMP->CT2_VALOR
	ElseIf lExistTmp
		nVal:= &("TMP->CT2_VALR"+TMP->CT2_ORGCUR)
	Endif
	If lExistTmp .And. ReadVar() == "M->CT2_VORIGI"
		TMP->CT2_VORIGI := 	&(ReadVar())
	ElseIf lExistTmp
		TMP->CT2_VORIGI :=nVal
	Endif 
	RestARea(aAreaCTx)

Return nVal

/*
Refreshs the totalizers at the bottom of the grid
@Return CTB102Exibe Logical -- result if the refresh was successful
@Author Eduardo.Flima
@Since 10/02/2018
@Release: 12.1.17 (Janeiro/2018)
*/

Function  Ct102TotVl()
	Local aAreaSm2	as Array
	Local cCur as char
	Local cMoeda as char	
	Local nRate as Numeric
	Local nValor as Numeric
	Local nValorAnt as Numeric
	Local lExistTmp	AS LOGICAL

	lExistTmp	:= ! Empty(Select("TMP"))

	aAreaSm2		:= {}
	cCur :=""
	cMoeda := ""
	nRate := 0
	nValor :=0
	nValorAnt :=0 


	aAreaSm2 := getArea()
	If lExistTmp .And. ReadVar() == "M->CT2_ORGCUR"
		cCur:= &(ReadVar())
		If cCur!=nil .and. !Empty (cCur)
			cMoeda := SUBSTR( cCur, 2, 1)
			dbSelectArea("SM2")
			SM2->(dbsetOrder(1))
			If SM2->(dbSeek(DDATALANC,.T.))
				nRate := Iif((&("SM2->M2_MOEDA"+cMoeda)==0),1,&("SM2->M2_MOEDA"+cMoeda)) // If there is no rates, set rate = 1 (as for own national currency)
			Endif
			nValor:= TMP->CT2_VORIGI * nRate
			nValorAnt :=TMP->CT2_VALOR  			
		Endif
	ElseIf lExistTmp
		nValor := M->CT2_VORIGI* iif (TMP->CT2_EXRATE == 0 , 1 , TMP->CT2_EXRATE)
		nValorAnt := TMP->CT2_VORIGI * iif (TMP->CT2_EXRATE == 0 , 1 , TMP->CT2_EXRATE)
	Endif
	RestARea(aAreaSm2)
Return   CTB102Exibe(nValor, nValorAnt, IIf(lExistTmp, TMP->CT2_DC, CT2->CT2_DC), IIf(lExistTmp, TMP->CT2_DC, CT2->CT2_DC), GetMv("MV_SOMA"))  
