/*/{PROTHEUS.DOC} LOCA041.PRW 
ITUP BUSINESS - TOTVS RENTAL
ROTINA DE CALCULO DE PRE�O DE GUINDASTE UTILIZADOS EM DIVERSOS RELAT�RIOS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"   

FUNCTION LOCA041(CTPCA , NVAL , NTPH , NTPD , NMINMES , NQTDIA , NQTMES)  
LOCAL NRET := 0

IF NQTMES==0 .AND. NQTDIA==0
	DO CASE
	CASE CTPCA=="H" ; NRET := NTPH*NVAL		// * NMINDIA
	CASE CTPCA=="D" ; NRET := NTPH*NVAL		// * NMINDIA
	CASE CTPCA=="M" ; NRET := NTPH*NVAL		// * NMINMES
	CASE CTPCA=="F" ; NRET := NVAL
	OTHERWISE       ; NRET := 0
	ENDCASE
ELSE
	DO CASE
	CASE CTPCA=="H" ; NRET := (NQTMES*NMINMES*NVAL)+(NQTDIA*NTPD*NVAL)
	CASE CTPCA=="D" ; NRET := (NQTMES*NMINMES*NVAL)+(NQTDIA*NTPD*NVAL) 
	CASE CTPCA=="M" ; NRET := (NQTMES*NMINMES*NVAL)+(NQTDIA*NTPD*NVAL)
	CASE CTPCA=="F" ; NRET := NVAL
	OTHERWISE       ; NRET := 0
	ENDCASE
ENDIF

RETURN(NRET)
