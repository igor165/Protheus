#include "protheus.ch"
#include "quicksearch.ch" 
#include "PONQ200.ch"

QSSTRUCT PONA200 DESCRIPTION STR0001 MODULE 16  // Banco de Horas

QSMETHOD INIT QSSTRUCT PONA200 

	Local _cUserEmp 	:= ""
	Local _cUserFil 	:= ""
	Local _cUserMat 	:= ""
	Local _cUserDpto	:= ""
	Local _cLikeRec 	:= ""   
	Local _cUserCPF		:= ""
	Local cMultVinc 	 := ""	
	Local cExp1	   		:= ""
	Local cExp2			:= ""   
	Local cExp3			:= ""
	Local cExp4			:= ""  
	Local cExp5			:= ""
	Local dIniPonMes	:= Ctod("//")
	Local dFimPonMes	:= Ctod("//") 
	Local cDtIni		:= ""
	Local cDtFim		:= ""
	
	RhGetFuncInfo(@_cUserEmp,@_cUserFil,@_cUserMat,@_cUserDpto,@_cLikeRec,@_cUserCPF)
	
	GetPonMesDat( @dIniPonMes , @dFimPonMes , _cUserFil )   
	cDtIni	:= DtoS(dIniPonMes)
	cDtFim	:= Dtos(dFimPonMes)  
	
   	QSTABLE "SRA" JOIN "SPI" 
	QSTABLE "SRA" LEFT JOIN "SQB"
	
   	QSPARENTFIELD "RA_NOME"  	INDEX ORDER 3
   	QSPARENTFIELD "RA_MAT" 		INDEX ORDER 1 	 
   	QSPARENTFIELD "RA_DEPTO" 	INDEX ORDER 21 	SET RELATION TO "QB_DEPTO" 
   	QSPARENTFIELD "QB_DESCRIC" 	INDEX ORDER 2 	SET RELATION TO "RA_DEPTO" 	WITH "QB_DEPTO" LABEL STR0002 	  
	
	//Remove essas tabelas do primary key , senão os campos delas aparecem no group by e interferem no resultado da query
	::RemovePrimaryKey({'SQB','SPI'})
	
	// DO PERIODO CORRENTE
	// Codigo de Eventos - Provento, Base Provento
	cExp1	:= "( IsNull( ( SELECT SUM(PI_QUANTV) 		FROM " + RetSqlName("SPI")+ " SPIAUX INNER JOIN " + RetSqlName("SP9") + " SP9AUX ON SPIAUX.PI_PD = SP9AUX.P9_CODIGO WHERE SPIAUX.PI_MAT = SRA.RA_MAT AND SP9AUX.P9_TIPOCOD IN ('1','3') AND ( SPIAUX.PI_DATA >= '" + cDtIni +  "' AND SPIAUX.PI_DATA <= '" + cDtFim +  "' )) , 0) )"
	// Codigo de Eventos - Desconto, Base Desconto
	cExp2	:= "( IsNull( ( SELECT SUM(PI_QUANTV) * -1  FROM " + RetSqlName("SPI")+ " SPIAUX INNER JOIN " + RetSqlName("SP9") + " SP9AUX ON SPIAUX.PI_PD = SP9AUX.P9_CODIGO WHERE SPIAUX.PI_MAT = SRA.RA_MAT AND SP9AUX.P9_TIPOCOD IN ('2','4') AND ( SPIAUX.PI_DATA >= '" + cDtIni +  "' AND SPIAUX.PI_DATA <= '" + cDtFim +  "' )) , 0) )"
     
	// DO PERIODO ANTERIOR
	PonDecDate( @dIniPonMes , @dFimPonMes  )
	cDtIni	:= DtoS(dIniPonMes)
	cDtFim	:= Dtos(dFimPonMes)  
	
	// Codigo de Eventos - Provento, Base Provento
	cExp3	:= "( IsNull( ( SELECT SUM(PI_QUANTV) 		FROM " + RetSqlName("SPI")+ " SPIAUX INNER JOIN " + RetSqlName("SP9") + " SP9AUX ON SPIAUX.PI_PD = SP9AUX.P9_CODIGO WHERE SPIAUX.PI_MAT = SRA.RA_MAT AND SP9AUX.P9_TIPOCOD IN ('1','3') AND ( SPIAUX.PI_DATA >= '" + cDtIni +  "' AND SPIAUX.PI_DATA <= '" + cDtFim +  "' ) AND SPIAUX.PI_STATUS <> 'B'), 0) )"
	// Codigo de Eventos - Desconto, Base Desconto
	cExp4	:= "( IsNull( ( SELECT SUM(PI_QUANTV) * -1  FROM " + RetSqlName("SPI")+ " SPIAUX INNER JOIN " + RetSqlName("SP9") + " SP9AUX ON SPIAUX.PI_PD = SP9AUX.P9_CODIGO WHERE SPIAUX.PI_MAT = SRA.RA_MAT AND SP9AUX.P9_TIPOCOD IN ('2','4') AND ( SPIAUX.PI_DATA >= '" + cDtIni +  "' AND SPIAUX.PI_DATA <= '" + cDtFim +  "' ) AND SPIAUX.PI_STATUS <> 'B'), 0) )"
    
    cExp5 	:= "( " + cExp3 + " + " + cExp4  + " ) + ( " + cExp1 + " + " + cExp2 + " )"
		
	QSFIELD "RA_NOME"
	QSFIELD "RA_MAT"	   

/*
    QSFIELD "SLDANT" 	EXPRESSION "( " + cExp3 + " + " + cExp4 + ")" LABEL STR0009 FIELDS "RA_FILIAL","RA_NOME","RA_MAT","PI_FILIAL","PI_MAT","RA_DEPTO","QB_DESCRIC" GROUP BY TYPE 'C' SIZE 8 DECIMAL 2 PICTURE "@E 99,999.99"	// Saldo Anterior
    QSFIELD "SLDPER" 	EXPRESSION "( " + cExp1 + " + " + cExp2 + ")" LABEL STR0006 FIELDS "RA_FILIAL","RA_NOME","RA_MAT","PI_FILIAL","PI_MAT","RA_DEPTO","QB_DESCRIC" GROUP BY TYPE 'C' SIZE 8 DECIMAL 2 PICTURE "@E 99,999.99"	// Saldo Periodo
    QSFIELD "SLDATU"    EXPRESSION cExp5 LABEL STR0008 FIELDS "RA_FILIAL","RA_NOME","RA_MAT","PI_FILIAL","PI_MAT","RA_DEPTO","QB_DESCRIC" GROUP BY TYPE 'C' SIZE 8 DECIMAL 2 PICTURE "@E 99,999.99"	// Saldo Atual   
*/
    QSFIELD "SLDANT" 	EXPRESSION "( " + cExp3 + " + " + cExp4 + ")" LABEL STR0009  TYPE 'C' SIZE 8 DECIMAL 2 PICTURE "@E 99,999.99"	// Saldo Anterior
    QSFIELD "SLDPER" 	EXPRESSION "( " + cExp1 + " + " + cExp2 + ")" LABEL STR0006 TYPE 'C' SIZE 8 DECIMAL 2 PICTURE "@E 99,999.99"	// Saldo Periodo
    QSFIELD "SLDATU"    EXPRESSION cExp5 LABEL STR0008 FIELDS "RA_NOME","RA_MAT"  GROUP BY  TYPE 'C' SIZE 8 DECIMAL 2 PICTURE "@E 99,999.99"	// Saldo Atual   
 	
 	//QSFIELD "RA_DEPTO"  
  	//QSFIELD "QB_DESCRIC" LABEL STR0002

	QSACTION MENUDEF "PONA200" OPERATION 2 LABEL STR0003   // Detalhes Banco de Horas
	
	cMultVinc:= "RA_CIC = '" + _cUserCpf + "'"
	
	If Empty(_cLikeRec)	
		cWhereAux := "(( QB_FILRESP = '" + _cUserFil + "' AND QB_MATRESP = '" + _cUserMat + "' AND QB_DEPTO = '" + _cUserDpto + "') OR ( RA_CIC = '" + _cUserCpf + "') OR ( QB_DEPSUP <> '' AND QB_DEPSUP = '" + _cUserDpto + "' AND (SELECT QB_MATRESP FROM " + RetSqlName("SQB") + " SQB2 WHERE SQB2.QB_DEPTO = SQB.QB_DEPSUP AND SQB2.QB_FILRESP = '" + _cUserFil + "') = '" + _cUserMat + "'))"
		
		QSFILTER STR0004 WHERE "RA_MAT = '' OR (" + cWhereAux + " AND RA_DEMISSA = '')" // Ativos
		QSFILTER STR0005 WHERE "RA_MAT = '' OR (" + cWhereAux + " AND RA_DEMISSA = '' AND RA_SITFOLH <> '')" // Afastados
	Else
		QSFILTER STR0004 WHERE "RA_MAT = '' OR ( ( SRA.R_E_C_N_O_ IN (" + _cLikeRec + ") OR " + cMultVinc + ") AND RA_DEMISSA = '') " //"Ativos"
		QSFILTER STR0005 WHERE "RA_MAT = '' OR ( ( SRA.R_E_C_N_O_ IN (" + _cLikeRec + ") OR " + cMultVinc + ") AND RA_DEMISSA = '' AND RA_SITFOLH <> '')" //"Afastados"
	EndIf

Return