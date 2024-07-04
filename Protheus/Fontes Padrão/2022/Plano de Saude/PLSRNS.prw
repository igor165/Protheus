#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRN368
Estatistica de partos

@author  PLS TEAM
@version P11
@since   17.10.15
/*/
//-------------------------------------------------------------------
function PLSRN368(cCodOpe, cCodRdaHC, cCodRdaM)
local nI	  := 0
local aDados  := {}
local aCpo01  := {}
local aCpo02  := {}
local aCpo03  := {}
local cAno	  := cValToChar(iif(month(dDataBase) > 3,(year(dDataBase)-1),(year(dDataBase)-2)))//maior que marco pega o ano anterior menor dois anos
local cQuery  := ''
local cCodPro := ''
local cCodProP:= ''
local cCodProC:= ''
local cRegPre := ''
local cCodTPA := '00'
local nTotOpeP:= 0
local nTotOpeC:= 0
local nTotHosP:= 0
local nTotHosC:= 0
local nTotMedP:= 0
local nTotMedC:= 0
local lField  := BR8->(fieldPos("BR8_PARTNC"))>0

if !lField
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'Campo [BR8_PARTNC] não existe no dicionario de dados!' , 0, 0, {})
	return aDados
endIf

cQuery := " SELECT BR8_CODPSA,BR8_PARTNC "
cQuery += " FROM " + retSqlName("BR8")
cQuery += " WHERE BR8_FILIAL = '" + xFilial('BR8') + "' " 
cQuery += "   AND BR8_PARTNC <> '' "
cQuery += "   AND D_E_L_E_T_ <> '*' "

dbUseArea(.T., "TOPCONN", TCGenQry( , , changeQuery(cQuery)), "RN368", .F., .T.)

 while !RN368->(eof())
 	
 	if RN368->BR8_PARTNC == '0'
		cCodProP += "'" + allTrim(RN368->BR8_CODPSA) + "',"
	else
		cCodProC += "'" + allTrim(RN368->BR8_CODPSA) + "',"
 	endIf	
 
 RN368->(dbSkip())
 endDo

RN368->(dbCloseArea())

//se nao exister nenhuma parametrizacao de evento na br8 retorna
if empty(cCodProP) .and. empty(cCodProC)
	return aDados
endIf

//1 = parto, 2 = cesaria
for nI := 1 to 2

	//parto
	if nI == 1
		cCodPro := left(cCodProP,len(cCodProP)-1) 
	//cesaria
	else
		cCodPro := left(cCodProC,len(cCodProC)-1)
	endIf

	if empty(cCodPro)
		return aDados
	endIf
	
	cQuery := " SELECT COUNT(DISTINCT BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG ) AS COUNT "
	cQuery += " FROM " + retSqlName("BD6")
	cQuery += " WHERE BD6_FILIAL = '" + xFilial('BD6') + "' " 
	cQuery += "   AND BD6_FASE 	= '4' "
	cQuery += "   AND BD6_ANOPAG = '" + cAno +  "' "
	
	if at(',',cCodPro) > 0
		cQuery += "  AND BD6_CODPRO in(" + cCodPro + ") "
	else
		cQuery += "  AND BD6_CODPRO = " + cCodPro
	endIf	
	cQuery += "  AND D_E_L_E_T_ <> '*' "
	cQuery += "  AND BD6_CODOPE = '" + cCodOpe + "' "
	
	dbUseArea(.T., "TOPCONN", TCGenQry( , , changeQuery(cQuery)), "RN368", .F., .T.)
	
	if !RN368->(eof()) .and. RN368->COUNT > 0
		if nI == 1
			nTotOpeP := RN368->COUNT
		else
			nTotOpeC := RN368->COUNT
		endIf	
		RN368->(dbCloseArea())
	
		//hospital
		if !empty(cCodRdaHC) 
			cQuery += "  AND BD6_CODRDA = '" + cCodRdaHC + "' "
			
			dbUseArea(.T., "TOPCONN", TCGenQry( , , changeQuery(cQuery)), "RN368", .F., .T.)
		
			if !RN368->(eof())
				if nI == 1
					nTotHosP := RN368->COUNT
				else
					nTotHosC := RN368->COUNT
				endIf	
			endIf
			RN368->(dbCloseArea())
		endIf
		
		//medico olho no BD7
		if !empty(cCodRdaM) 
			
			cRegPre := allTrim(posicione("BAU",1,xFilial("BAU")+cCodRdaM,"BAU_CONREG"))
			
			cQuery := " SELECT COUNT(DISTINCT BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG ) AS COUNT "
			cQuery += " FROM " + retSqlName("BD7")
			cQuery += " WHERE BD7_FILIAL = '" + xFilial('BD7') + "' " 
			cQuery += "   AND BD7_FASE 	= '4' "
			cQuery += "   AND BD7_ANOPAG = '" + cAno +  "' "
			
			if at(',',cCodPro) > 0
				cQuery += "  AND BD7_CODPRO in(" + cCodPro + ") "
			else
				cQuery += "  AND BD7_CODPRO = " + cCodPro
			endIf	
			
			cQuery += "  AND D_E_L_E_T_ <> '*' "
			cQuery += "  AND BD7_CODOPE = '" + cCodOpe + "' "
			cQuery += "  AND BD7_CODRDA = '" + cCodRdaM + "' "
			cQuery += "  AND BD7_CODTPA = '" + cCodTPA 	+ "' "
	
			dbUseArea(.T., "TOPCONN", TCGenQry( , , changeQuery(cQuery)), "RN368", .F., .T.)
		
			if !RN368->(eof())
				if nI == 1
					nTotMedP := RN368->COUNT
				else
					nTotMedC := RN368->COUNT
				endIf	
			endIf
			RN368->(dbCloseArea())
		endIf
	else
		RN368->(dbCloseArea())	
	endIf
next	

if nTotOpeP > 0 .or. nTotOpeC > 0
	aAdd(aDados, strZero(randomize( 0, 10000000 ),8) )
	aAdd(aDados, dtoc(date()) + ' às ' + time())
	aAdd(aDados, cAno)
	
	aAdd(aCpo01, posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_NOMINT"))
	aAdd(aCpo01, (nTotOpeP/(nTotOpeP+nTotOpeC))*100 )
	aAdd(aCpo01, (nTotOpeC/(nTotOpeC+nTotOpeP))*100 )
	
	aAdd(aCpo02, iif( empty(cCodRdaHC),replicate('*',20),posicione("BAU",1,xFilial("BAU")+cCodRdaHC,"BAU_NOME") ) )
	aAdd(aCpo02,(nTotHosP/(nTotHosP+nTotHosC))*100)
	aAdd(aCpo02, (nTotHosC/(nTotHosC+nTotHosP))*100 )
	
	aAdd(aCpo03, iif( empty(cCodRdaM),replicate('*',20),posicione("BAU",1,xFilial("BAU")+cCodRdaM,"BAU_NOME") ) )
	aAdd(aCpo03, (nTotMedP/(nTotMedP+nTotMedC))*100 )
	aAdd(aCpo03, (nTotMedC/(nTotMedC+nTotMedP))*100 )
	
	aAdd(aDados,aCpo01) 	
	aAdd(aDados,aCpo02) 	
	aAdd(aDados,aCpo03)
endIf	


return aDados