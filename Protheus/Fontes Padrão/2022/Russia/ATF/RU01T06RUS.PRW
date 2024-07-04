#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU01T06.CH'

#DEFINE RU01T06_SN3_FIELDS "N3_FILIAL|N3_CBASE|N3_ITEM|N3_TIPO|N3_VORIG1|N3_AMPLIA1|N3_PERDEPR"

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T06_R1MonthModernization

Deprecated, check RU01T03_S4MonthModernization()

@param		None
@return		ARRAY aRet
@author 	victor.rezende
@since 		15/11/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T06_R1MonthModernization()
Local aRet		AS ARRAY
aRet		:= RU01T03_S4MonthModernization()
Return aRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T06_R2PreviousValues

Return array with accumulated values for FA

@param		DATE dMaxDate
@return		ARRAY aRet
@author 	victor.rezende
@since 		15/11/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T06_R2PreviousValues(dMaxDate AS DATE)
Local nX		AS NUMERIC
Local cQuery	AS CHARACTER
Local cAliasTrb	AS CHARACTER
Local aCurren	AS ARRAY
Local aArea		AS ARRAY
Local aRet		AS ARRAY

Default dMaxDate	:= dDataBase

aArea	:= GetArea()
aCurren	:= AtfMultMoe(,,{|x| 0})

cQuery	:= " SELECT COUNT(DISTINCT(SUBSTRING(N4_DATA, 1, 6))) AS NDEPR "
For nX := 1 To Len(aCurren)
	cQuery	+= "        ,COALESCE(SUM(N4_VLROC"+AllTrim(Str(nX))+"), 0) AS N4_VLROC"+AllTrim(Str(nX))+" "
Next nX
cQuery	+= "   FROM "+RetSqlName("SN4")+" SN4 "
cQuery	+= "  WHERE SN4.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND N4_FILIAL = '"+SN3->N3_FILIAL+"' "
cQuery	+= "    AND N4_CBASE = '"+SN3->N3_CBASE+"' "
cQuery	+= "    AND N4_ITEM = '"+SN3->N3_ITEM+"' "
cQuery	+= "    AND N4_TIPO = '"+SN3->N3_TIPO+"' "
cQuery	+= "    AND N4_SEQ = '"+SN3->N3_SEQ+"' "
cQuery	+= "    AND N4_TPSALDO = '"+SN3->N3_TPSALDO+"' "
cQuery	+= "    AND N4_TIPOCNT = '3' "
cQuery	+= "    AND N4_DATA < '"+DToS(LastDay(dMaxDate) + 1)+"' "
cQuery	+= "    AND N4_OCORR IN ('06','07','08','10','11','12','17','18','20') "

cQuery	:= ChangeQuery(cQuery)

cAliasTrb	:= CriaTrab(Nil, .F.)
DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasTrb )
aRet	:= {(cAliasTrb)->NDEPR, {}}
For nX := 1 To Len(aCurren)
	aAdd(aRet[2], &("('"+cAliasTrb+"')->N4_VLROC"+AllTrim(Str(nX))))
Next nX
(cAliasTrb)->(dbCloseArea())

RestArea(aArea)

Return aRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T06_R3LastModernization

Return accumulated depreciation until most recent modernization

@param		None
@return		ARRAY aRet
@author 	victor.rezende
@since 		15/11/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T06_R3LastModernization()
Local cQuery	AS CHARACTER
Local cAliasTrb	AS CHARACTER
Local dLastMod	AS DATE
Local aArea		AS ARRAY
Local aRet		AS ARRAY

aArea	:= GetArea()

cQuery	:= " SELECT COALESCE(MAX(N4_DATA), '        ') AS N4_DATA "
cQuery	+= "   FROM "+RetSqlName("SN4")+" SN4 "
cQuery	+= "  WHERE SN4.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND N4_FILIAL = '"+xFilial("SN4")+"' "
cQuery	+= "    AND N4_CBASE = '"+SN3->N3_CBASE+"' "
cQuery	+= "    AND N4_ITEM = '"+SN3->N3_ITEM+"' "
cQuery	+= "    AND N4_TIPO = '"+SN3->N3_TIPO+"' "
cQuery	+= "    AND N4_SEQ = '"+SN3->N3_SEQ+"' "
cQuery	+= "    AND N4_TPSALDO = '"+SN3->N3_TPSALDO+"' "
cQuery	+= "    AND N4_DATA < '"+DToS(FirstDay(dDataBase) - 1)+"' "
cQuery	+= "    AND N4_OCORR = '09' "

cQuery	:= ChangeQuery(cQuery)

cAliasTrb	:= CriaTrab(Nil, .F.)
DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasTrb )
dLastMod	:= SToD((cAliasTrb)->(N4_DATA))
(cAliasTrb)->(dbCloseArea())

If ! Empty(dLastMod)
	aRet	:= RU01T06_R2PreviousValues(dLastMod)[2]
Else
	aRet	:= AtfMultMoe(,,{|x| 0})
EndIf

RestArea(aArea)

Return aRet

// Russia_R5
