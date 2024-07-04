#include "protheus.ch"
#include "quicksearch.ch" 
#include "PONQ040.ch"

QSSTRUCT PONA040 DESCRIPTION STR0001 MODULE 16    // Cartao do Ponto

QSMETHOD INIT QSSTRUCT PONA040

  	Local _cUserEmp := ""
	Local _cUserFil := "" 
	Local _cUserMat := ""
	Local _cUserDpto:= ""
	Local _cLikeRec := ""   
	Local cMultVinc := ""
	Local _cUserCPF := ""
	
	RhGetFuncInfo(@_cUserEmp,@_cUserFil,@_cUserMat,@_cUserDpto,@_cLikeRec,@_cUserCPF)       
	
	QSTABLE "SP8" JOIN "SRA" 
	
 	QSPARENTFIELD "P8_DATA" INDEX ORDER 4 LABEL "Data"
 	QSPARENTFIELD "RA_NOME" INDEX ORDER 3 SET RELATION TO "P8_MAT" WITH "RA_MAT"
	QSPARENTFIELD "P8_MAT" 	INDEX ORDER 1 SET RELATION TO "RA_MAT"		

	QSFIELD "P8_DATA"		LABEL STR0005
    QSFIELD "P8_TURNO"  
   	QSFIELD "P8_TPMARCA" 
 	QSFIELD "P8_HORA"		LABEL STR0006
  	QSFIELD "P8_FILIAL"  
  	QSFIELD "P8_MAT"    
  	QSFIELD "RA_NOME"
  	
  	cMultVinc:= "RA_CIC = '" + _cUserCpf + "'"
 	
    // Todos os lancamentos - Ambos
    QSFILTER STR0002 WHERE "(RA_MAT = '" + _cUserMat + "' OR " + cMultVinc +") "
   
   	// Lancamentos Pares
   	QSFILTER STR0003 WHERE "(RA_MAT = '" + _cUserMat + "' OR " + cMultVinc + ") AND (SELECT COUNT(*) FROM "+ RetSqlName("SP8") + " SP82 WHERE SP82.P8_FILIAL = SP8.P8_FILIAL AND SP82.P8_MAT = SP8.P8_MAT AND SP82.P8_DATA = SP8.P8_DATA AND D_E_L_E_T_ = '') IN (2,4,6,8,10,12,14,16)" 
	
	//Lancamentos Impares
   	QSFILTER STR0004 WHERE "(RA_MAT = '" + _cUserMat + "' OR " + cMultVinc + ") AND (SELECT COUNT(*) FROM "+ RetSqlName("SP8") + " SP82 WHERE SP82.P8_FILIAL = SP8.P8_FILIAL AND SP82.P8_MAT = SP8.P8_MAT AND SP82.P8_DATA = SP8.P8_DATA AND D_E_L_E_T_ = '') IN (1,3,5,7,9,11,13,15)"
  

Return