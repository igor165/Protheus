#INCLUDE "loca056.ch" 
/*/{PROTHEUS.DOC} LOCA056.PRW
ITUP BUSINESS - TOTVS RENTAL
CADASTRO DE APROVADORES DE PROJETOS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "PROTHEUS.CH"                                                                                                                     
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

FUNCTION LOCA056()
//IF UPPER(ALLTRIM(CUSERNAME)) == "ADMINISTRADOR" 
	DBSELECTAREA("FPR")
	AXCADASTRO("FPR",STR0001)  //"CADASTRO DE APROVADORES DE PROJETOS"
//ELSE
//	MSGALERT("ATEN��O: SOMENTE O USU�RIO ADMINISTRADOR PODE EFETUAR ESSE CADASTRO.","GPO - LOCT066.PRW")
//ENDIF

RETURN .T.
