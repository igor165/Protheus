#INCLUDE "loca012.ch" 
/*/{PROTHEUS.DOC} LOCA012.PRW
ITUP BUSINESS - TOTVS RENTAL
Valida��o para gera��o do or�amento
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

FUNCTION LOCA012()
LOCAL LRET := .T.

IF FP0->FP0_STATUS <> "5" 
    MSGSTOP(STR0001 , STR0002)  //"S� � POSSIVEL GERAR CONTRATO COM O STATUS FECHADO!"###"GPO - GERREMVLD.PRW"
	LRET := .F.
ELSE
	IF POSICIONE("SA1", 1, XFILIAL("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA, "A1_RISCO") == "E" 
		MSGSTOP(STR0003 + FP0->FP0_CLI + "/" + FP0->FP0_LOJA + "]" + STR0004 , STR0002)  //"CLIENTE/LOJA ["###" RISCO E! "###"GPO - GERREMVLD.PRW"
		LRET := .F.
	ENDIF
ENDIF

RETURN LRET
