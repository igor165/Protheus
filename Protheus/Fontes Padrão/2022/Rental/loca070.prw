#INCLUDE "loca070.ch"  
/*/{PROTHEUS.DOC} LOCA070.PRW
ITUP BUSINESS - TOTVS RENTAL
VALIDAÇÃO DO CAMPO T9_STATUS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "TOTVS.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

FUNCTION LOCA070()
LOCAL LRET := .T.

TQY->(DBSETORDER(1))
IF TQY->(DBSEEK(XFILIAL("TQY") + ST9->T9_STATUS))
	CSTSATU := TQY->TQY_STTCTR
	IF CSTSATU == "70" .OR. CSTSATU == "00" .OR. EMPTY(CSTSATU)
		IF TQY->(DBSEEK(XFILIAL("TQY") + M->T9_STATUS))
			CSTSNEW := TQY->TQY_STTCTR
			IF CSTSNEW <> "00" .AND. !EMPTY(CSTSNEW)
				MSGALERT(STR0001 + ALLTRIM(TQY->TQY_STATUS) + " - " + ALLTRIM(TQY->TQY_DESTAT) , STR0002)  //"NÃO É POSSÍVEL ALTERAR PARA O STATUS "###"GPO - VALSTST9.PRW"
				LRET := .F.
			ENDIF
		ENDIF
	ENDIF
ENDIF

RETURN LRET



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ WHNSTST9  º AUTOR ³ IT UP BUSINESS     º DATA ³ 20/06/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ WHEN DO CAMPO T9_STATUS                                    º±±
±±º          ³ CHAMADA: WHEN - CAMPO T9_STATUS                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LOCA07001() 

LOCAL LRET := .T.

TQY->(DBSETORDER(1))
IF TQY->(DBSEEK(XFILIAL("TQY") + ST9->T9_STATUS))
	CSTSATU := TQY->TQY_STTCTR
	IF CSTSATU <> "70" .AND. CSTSATU <> "00" .AND. !EMPTY(CSTSATU)
		LRET := .F.
	ENDIF
ENDIF

RETURN LRET
