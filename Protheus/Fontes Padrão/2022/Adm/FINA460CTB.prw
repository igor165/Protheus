#Include 'Protheus.ch'

/*/{Protheus.doc} FINA460CTB
Funções especificas para contabilização da FINA460 (online / offline).
@author Luis Felipe Geraldo
@since  11/06/2019
@version 12
/*/	

Static __oSt1PosFO2 	as object
Static __oSt2PosFO2 	as object
Static __oStAbFO1		as object


//-------------------------------------------------------------------
/*/{Protheus.doc} F460PosFO2()
Retorna o recno do registro referente ao titulo na FO2

@author Luis Felipe Geraldo
@version P12.1.17
@since	07/02/2019	
/*/
//-------------------------------------------------------------------
Function F460PosFO2(nSE1Rec As Numeric , cCodLiq As Character) As Numeric

//Declaração das variaveis tipadas
Local aAreaAtu As Array
Local aAreaSE1 As Array
Local nRet     As Numeric
Local cQuery   As Character
Local cProcFO0 As Character
Local cNewAls1 As Character
Local cNewAls2 As Character

//Atribuição das variaveis
aAreaAtu := GetArea()
aAreaSE1 := SE1->(GetArea())
nRet     := 0
cQuery   := ""
cNewAls1 := GetNextAlias()
cNewAls2 := GetNextAlias()

dbSelectArea("SE1")
SE1->(dbGoTo(nSE1Rec))

If __oSt1PosFO2 == Nil
	cQuery := " SELECT FO0.FO0_PROCES "
	cQuery += " FROM " + RetSqlName("FO0") + " FO0 "
	cQuery += " WHERE FO0_FILIAL    = ? " 
	cQuery += " AND FO0_STATUS      = '4' "
	cQuery += " AND FO0.FO0_NUMLIQ  = ? "
	cQuery += " AND FO0.D_E_L_E_T_  = ' ' "
	cQuery += " AND FO0_PROCES IN ( "
	cQuery += " SELECT FO2_PROCES FROM " + RetSqlName("FO2") + " FO2 "
	cQuery += " WHERE FO2_FILIAL = ? "
	cQuery += " AND FO2_PREFIX   = ? "
	cQuery += " AND FO2_NUM      = ? "
	cQuery += " AND FO2_PARCEL   = ? "
	cQuery += " AND FO2_TIPO     = ? "
	cQuery += " AND FO2.D_E_L_E_T_ = ' ' ) "
	__oSt1PosFO2 := FWPreparedStatement():New(cQuery)
EndIf

__oSt1PosFO2:SetString(1, SE1->E1_FILORIG ) 
__oSt1PosFO2:SetString(2, cCodLiq ) 
__oSt1PosFO2:SetString(3, SE1->E1_FILORIG ) 
__oSt1PosFO2:SetString(4, SE1->E1_PREFIXO ) 
__oSt1PosFO2:SetString(5, SE1->E1_NUM ) 
__oSt1PosFO2:SetString(6, SE1->E1_PARCELA ) 
__oSt1PosFO2:SetString(7, SE1->E1_TIPO ) 
cQuery := __oSt1PosFO2:getFixQuery()
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cNewAls1, .F., .T.)

dbSelectArea(cNewAls1)
(cNewAls1)->(dbGoTop())
If (cNewAls1)->(!Bof()) .AND. (cNewAls1)->(!Eof())
	cProcFO0 := (cNewAls1)->FO0_PROCES
	If __oSt2PosFO2 == Nil
		cQuery := " SELECT FO2.R_E_C_N_O_ RECFO2 FROM " + RetSqlName("FO2") + " FO2 "
		cQuery += " WHERE FO2_FILIAL = ? "
		cQuery += " AND FO2_PROCES   = ? "	
		cQuery += " AND FO2_PREFIX   = ? "
		cQuery += " AND FO2_NUM      = ? "
		cQuery += " AND FO2_PARCEL   = ? "
		cQuery += " AND FO2_TIPO     = ? "
		cQuery += " AND FO2.D_E_L_E_T_ = ' ' "
		__oSt2PosFO2 := FWPreparedStatement():New(cQuery)
	endIf
	__oSt2PosFO2:SetString(1, SE1->E1_FILORIG ) 
	__oSt2PosFO2:SetString(2, cProcFO0 ) 
	__oSt2PosFO2:SetString(3, SE1->E1_PREFIXO ) 
	__oSt2PosFO2:SetString(4, SE1->E1_NUM ) 
	__oSt2PosFO2:SetString(5, SE1->E1_PARCELA ) 
	__oSt2PosFO2:SetString(6, SE1->E1_TIPO ) 
	cQuery := __oSt2PosFO2:getFixQuery()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cNewAls2, .F., .T.)	
	
	dbSelectArea(cNewAls2)
	(cNewAls2)->(dbGoTop())
	If (cNewAls2)->(!Bof()) .AND. (cNewAls2)->(!Eof())
		nRet := (cNewAls2)->RECFO2
	EndIf

EndIf

If Select(cNewAls1) > 0
	(cNewAls1)->(dbCloseArea())
EndIf

If Select(cNewAls2) > 0
	(cNewAls2)->(dbCloseArea())
EndIf

RestArea(aAreaSE1)
RestArea(aAreaAtu)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F460AbFO1()
Retorna dados da liquidação gravados na FO1

@author Luis Felipe Geraldo
@version P12.1.17
@since	21/02/2019	
/*/
//-------------------------------------------------------------------
Function F460AbFO1(cProFO0 As Character, cVerFO0 As Character, cIdOriE5 As Character) As Array

//Declaração das variaveis tipadas
Local aAreaAtu  As Array
Local aDadosFO1 As Array
Local cIdDoc    As Character
Local cQuery    As Character
Local cNewAls   As Character

//Atribuição das variaveis
aAreaAtu  := GetArea()
aDadosFO1 := {}
cIdDoc    := ""
cQuery    := ""
cNewAls   := GetNextAlias()

if __oStAbFO1 == NIL
	cQuery := " SELECT FK1_IDDOC IDDOC "
	cQuery += " FROM " + RetSqlName("FK1") + " FK1 "
	cQuery += " WHERE FK1_FILIAL = ? "
	cQuery += " AND   FK1_IDFK1  = ? "
	cQuery += " AND   D_E_L_E_T_ = ' ' "
	__oStAbFO1 := FWPreparedStatement():New(cQuery)
endIf
__oStAbFO1:SetString(1, xFilial("FK1") ) 
__oStAbFO1:SetString(2, cIdOriE5 ) 
cQuery := __oStAbFO1:getFixQuery()
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cNewAls, .F., .T.)

dbSelectArea(cNewAls)
(cNewAls)->(dbGoTop())
If (cNewAls)->(!Bof()) .AND. (cNewAls)->(!Eof())
	cIdDoc := (cNewAls)->IDDOC
	dbSelectArea("FO1")
	dbSetOrder(1)
	If dbSeek(xFilial("FO1") + cProFO0 + cVerFO0 + cIdDoc )
		lCpoFO1Ad := FO1->(ColumnPos("FO1_VLADIC")) > 0
		Aadd( aDadosFO1 , { FO1->FO1_VLABT , IIf(lCpoFO1Ad,FO1->FO1_VLADIC,0) }) 
	EndIf
EndIf

If Select(cNewAls) > 0
	(cNewAls)->(dbCloseArea())
EndIf

RestArea(aAreaAtu)

Return aDadosFO1
