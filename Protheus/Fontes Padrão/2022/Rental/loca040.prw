#INCLUDE "loca040.ch" 
/*/{PROTHEUS.DOC} LOCA040.PRW
ITUP BUSINESS - TOTVS RENTAL
CANCELAMENTO DE AS (AUTORIZAÇÃO DE SERVIÇO)
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

FUNCTION LOCA040()
LOCAL AAREA    := GETAREA()
LOCAL AAREAZA0 := FP0->(GETAREA())
LOCAL AAREADTQ := FQ5->(GETAREA())
LOCAL AITENS   := {}
LOCAL OOK      := LOADBITMAP( GETRESOURCES(), "LBOK")
LOCAL ONO      := LOADBITMAP( GETRESOURCES(), "LBNO")
LOCAL _CQUERY  := ""
LOCAL _CWHERE  := ""

PRIVATE ODLG , OLBXITENS

IF SELECT("FP0") == 0 .OR. FP0->(EOF() .OR. EMPTY(FP0->FP0_PROJET))
	MSGSTOP(IIF(SELECT("FP0")==0 , STR0001 , STR0002) , STR0003) //"OPERAÇÃO CANCELADA: O ARQUIVO ZA0 NÃO ESTÁ ABERTO!"###"OPERAÇÃO CANCELADA: SELECIONE UM PROJETO ANTES DE ACESSAR ESTA ROTINA"###"GPO - LOCF145.PRW"
	RETURN NIL
ENDIF

IF SELECT("TRBFQ5") > 0
	TRBFQ5->(DBCLOSEAREA())
ENDIF
_CQUERY     := " SELECT DTQ.R_E_C_N_O_ FQ5RECNO " + CRLF
_CQUERY     += " FROM " + RETSQLNAME("FQ5") + " DTQ" + CRLF

_CWHERE     := " WHERE  FQ5_FILIAL = '" + XFILIAL("FQ5") + "'" + CRLF
_CWHERE     += "   AND  FQ5_FILORI = '" + FP0->FP0_FILIAL + "'" + CRLF // DOUGLAS TELLES
_CWHERE     += "   AND  FQ5_SOT    = '" + FP0->FP0_PROJET + "'" + CRLF
_CWHERE     += "   AND  FQ5_AS    <> ''" + CRLF
_CWHERE     += "   AND  FQ5_STATUS NOT IN ('9')" + CRLF
_CWHERE     += "   AND  NOT EXISTS(SELECT *" + CRLF
_CWHERE     += " 				   FROM " + RETSQLNAME("FPA") + " ZAG " + CRLF
_CWHERE     += " 				   WHERE  ZAG.FPA_FILIAL =  FQ5_FILORI" + CRLF
_CWHERE     += " 				     AND  ZAG.FPA_PROJET =  FQ5_SOT "   + CRLF
_CWHERE     += " 					 AND  ZAG.FPA_AS     =  FQ5_AS "    + CRLF
_CWHERE     += " 					 AND  ZAG.FPA_AS     <> '' "        + CRLF
_CWHERE     += " 					 AND  ZAG.FPA_NFREM  <> '' "        + CRLF
_CWHERE     += " 					 AND  ZAG.D_E_L_E_T_ =  '') "       + CRLF
_CWHERE     += "    AND DTQ.D_E_L_E_T_ = ''" + CRLF
IF EXISTBLOCK("LC145QRY")								// PONTO DE ENTRADA PARA INCLUSAO DE CONDICOES NA QUERY COM ITENS QUE PODERAO SOFRER CANCELAMENTO DE AS.
	_CWHERE := EXECBLOCK("LC145QRY",.T.,.T.,{_CWHERE})
ENDIF
_CQUERY     += _CWHERE
_CQUERY     += " ORDER BY FQ5_FILIAL , FQ5_FILORI , FQ5_SOT , FQ5_AS "
TCQUERY _CQUERY NEW ALIAS "TRBFQ5"

WHILE TRBFQ5->(!EOF())
	FQ5->(DBSETORDER(RETORDEM("FQ5","FQ5_FILIAL+FQ5_SOT+FQ5_OBRA+FQ5_VIAGEM")))
	FQ5->(DBGOTO(TRBFQ5->FQ5RECNO))
	AADD(AITENS, {.F., FQ5->FQ5_AS, FQ5->FQ5_GUINDA,FSTATUS(), FQ5->(RECNO())} )
	TRBFQ5->(DBSKIP())
ENDDO
TRBFQ5->(DBCLOSEAREA())
/*
FQ5->(DBSETORDER(RETORDEM("FQ5","FQ5_FILIAL+FQ5_SOT+FQ5_OBRA+FQ5_VIAGEM")))
FQ5->(DBSEEK(XFILIAL("FQ5")+FP0->FP0_PROJET))
WHILE ! FQ5->(EOF()) .AND. FQ5->FQ5_FILORI + FQ5->FQ5_SOT == FP0->FP0_FILIAL + FP0->FP0_PROJET
 //	AADD(AITENS, {.F., FQ5->FQ5_AS, FSTATUS(), FQ5->(RECNO())} ) - CAUÊ EM 20/12/2016
	AADD(AITENS, {.F., FQ5->FQ5_AS, FQ5->FQ5_GUINDA,FSTATUS(), FQ5->(RECNO())} )
	FQ5->(DBSKIP())
ENDDO
*/
IF LEN(AITENS) > 0
	DEFINE MSDIALOG ODLG TITLE STR0004+FP0->FP0_PROJET FROM 000,000 TO 500,735 PIXEL //"AS DO PROJETO: "
		@ 005,005 SAY STR0005 OF ODLG PIXEL //"SELECIONE AS AUTORIZAÇÕES DE SERVIÇO PARA CANCELAMENTO:"
		@ 015,005 LISTBOX OLBXITENS FIELDS HEADER "SEL","AS",STR0006,STR0007 SIZE 360,210 OF ODLG PIXEL ON DBLCLICK ( FSELECIONA(AITENS, OLBXITENS:NAT, .F.) )  //"EQUIPAMENTO"###"OBSERVAÇÕES"
		OLBXITENS:SETARRAY(AITENS)
		OLBXITENS:BLINE := {|| {IF(AITENS[OLBXITENS:NAT][1],OOK,ONO),AITENS[OLBXITENS:NAT][2],AITENS[OLBXITENS:NAT][3],AITENS[OLBXITENS:NAT][4]} }
		
		@ 230,030 BUTTON STR0008	  SIZE 50,15 PIXEL OF ODLG ACTION FMARCATUDO(.T., AITENS) //"MARCA TODOS"
		@ 230,090 BUTTON STR0009 SIZE 50,15 PIXEL OF ODLG ACTION FMARCATUDO(.F., AITENS) //"DESMARCA TODOS"
		@ 230,200 BUTTON STR0010	  SIZE 50,15 PIXEL OF ODLG ACTION (FCANCELAR(AITENS), ODLG:END()) //"CANCELAR AS"
		@ 230,300 BUTTON STR0011			  SIZE 50,15 PIXEL OF ODLG ACTION ODLG:END() //"SAIR"
	ACTIVATE MSDIALOG ODLG CENTERED
ELSE
	MSGSTOP(STR0012 , STR0003) //"OPERAÇÃO CANCELADA: NÃO FOI ENCONTRADA NENHUM AS PARA ESTE PROJETO"###"GPO - LOCF145.PRW"
ENDIF

RESTAREA(AAREA)
FP0->(RESTAREA(AAREAZA0))
FQ5->(RESTAREA(AAREADTQ))

RETURN NIL 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ FSTATUS   º AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ RETORNA SE A AS TEM CTRC E/OU CTRB                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION FSTATUS()

LOCAL _RET := ""

IF FQ5->FQ5_STATUS == "9"
	_RET += STR0013 //"AS CANCELADA"
ENDIF

IF !EMPTY(FQ5->FQ5_NUMCTR) .AND. FQ5->FQ5_NUMCTR != "-"
	IF !EMPTY(_RET)
		_RET += STR0014 //" E "
	ENDIF
	_RET += STR0015 //"TEM CTRC"
ENDIF

IF !EMPTY(FQ5->FQ5_NUMCTC) .AND. FQ5->FQ5_IMPCTB == "S"
	IF !EMPTY(_RET)
		_RET := STRTRAN(_RET,STR0014,", ") //" E "
		_RET += STR0014 //" E "
	ENDIF
	_RET += STR0016 //"TEM CTRB"
ENDIF

IF !EMPTY(FQ5->FQ5_NUMCTC) .AND. FQ5->FQ5_IMPCTB == "A"
	IF !EMPTY(_RET)
		_RET := STRTRAN(_RET," E ",", ")
		_RET += " E "
	ENDIF
	_RET += STR0017 //"VIAGEM C/ ADIANTAMENTO"
ENDIF

IF !EMPTY(FQ5->FQ5_NUMSLD) .AND. FQ5->FQ5_IMPCTB == "S"
	IF !EMPTY(_RET)
		_RET := STRTRAN(_RET," E ",", ")
		_RET += " E "
	ENDIF
	_RET += STR0018 //"VIAGEM C/ SALDO"
ENDIF

RETURN _RET



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³FSELECIONA º AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ SELECIONA O ITEM (AS)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPARÂMETROS³ AITENS - ARRAY DOS DADOS PREENCHIDOS                       º±±
±±º          ³ NAT    - POSIÇÃO DO ELEMENTO NO ARRAY                      º±±
±±º          ³ LQUIET - EM CASO DE NÃO SELEÇÃO POR EXISTÊNCIA DE CTRC     º±±
±±º          ³          E/OU CTRB, SE NÃO EXIBE MENSAGEM DE ALERTA        º±±
±±º          ³ LACAO  - MARCA .T. OU DESMARCA .F.                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION FSELECIONA(AITENS , NAT , LQUIET , LACAO)

IF EXISTBLOCK("LC145SEL") 		// PONTO DE ENTRADA NA SELEÇÃO DAS AS A SEREM CANCELADAS.
	AITENS := EXECBLOCK("LC145SEL",.T.,.T.,{AITENS, NAT, LQUIET, LACAO})
ELSE
	IF EMPTY(AITENS[NAT,4])
		IF VALTYPE(LACAO) == "L"
			AITENS[NAT,1] := LACAO
		ELSE
			AITENS[NAT,1] := ! AITENS[NAT,1]
		ENDIF
	ELSE
		IF ! LQUIET
			MSGSTOP(STR0019 , STR0003) //"NÃO É POSSÍVEL MARCAR ESTA AS, VEJA COLUNA OBSERVAÇÕES"###"GPO - LOCF145.PRW"
		ENDIF
	ENDIF
ENDIF

OLBXITENS:REFRESH()

RETURN NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³FMARCATUDO º AUTOR ³ IT UP BUSINESS     º DATA ³ 13/04/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ MARCA OU DESMARCA TODOS OS ITENS (AS)                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPARÂMETROS³ LACAO  - SE .T. MARCA SENÃO DESMARCA                       º±±
±±º          ³ AITENS - ARRAY DOS ELEMENTOS (AS)                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION FMARCATUDO(LACAO , AITENS)

LOCAL NI

FOR NI := 1 TO LEN(AITENS)
	FSELECIONA(AITENS, NI, .T., LACAO)
NEXT NI

RETURN NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ FCANCELAR º AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ REALIZA O CANCELAMENTO DAS AS MARCADAS                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION FCANCELAR(AITENS)

LOCAL _AAREAOLD := GETAREA()
LOCAL _AAREADTQ := FQ5->(GETAREA())
LOCAL _AAREAZLG := FPO->(GETAREA())
LOCAL _AAREAZAG := FPA->(GETAREA())
LOCAL _AAREAZA5 := FP4->(GETAREA())
LOCAL _AAREAST9 := ST9->(GETAREA())
LOCAL _CQUERY   := ""
LOCAL _CNFREM   := ""
LOCAL NI
LOCAL NCOUNT    := 0
LOCAL LVERZBX   := SUPERGETMV("MV_LOCX097",,.F.)  // HABILITA CONTROLE DE MINUTA
LOCAL _LEXCZAG  := SUPERGETMV("MV_LOCX274",,.F.)  // EXCLUÍ ZAG NO CANCELAMENTO DA AS
Local _LC145ACE := EXISTBLOCK("LC145ACE")


BEGIN TRANSACTION

FOR NI:=1 TO LEN(AITENS)
	
	IF AITENS[NI,1]
		FQ5->(DBGOTO(AITENS[NI,LEN(AITENS[NI])]))
		
		IF FQ5->FQ5_TPAS $ "E#G"
			
			DBSELECTAREA("FP4")
			FP4->(DBSETORDER(3))
			IF FP4->(DBSEEK(XFILIAL("FP4") + FQ5->FQ5_AS))
				IF FQ5->FQ5_STATUS $ "1#6#7"	// ABERTO / ACEITA / REJEITADA
					
					IF LOCA00519( FQ5->FQ5_AS )
						
						IF FP4->FP4_TIPOSE == "E"
							DBSELECTAREA("FPO")
							FPO->(DBSETORDER(5))
							IF FPO->(DBSEEK(XFILIAL("FPO") + FQ5->FQ5_AS))
								WHILE FPO->(!EOF()) .AND. FPO->FPO_FILIAL == XFILIAL("FPO") .AND. FPO->FPO_NRAS == FQ5->FQ5_AS
									IF RECLOCK("FPO",.F.)
										FPO->(DBDELETE())
										FPO->(MSUNLOCK())
									ENDIF
									FPO->(DBSKIP())
								ENDDO
							ENDIF
							
						ELSEIF FP4->FP4_TIPOSE == "M"
							IF SELECT("TRBZLO") > 0
								TRBFPQ->(DBCLOSEAREA())
							ENDIF
							CQRYZLO := " SELECT R_E_C_N_O_ RECZLO "
							CQRYZLO += " FROM " + RETSQLNAME("FPQ") + " ZLO "
							CQRYZLO += " WHERE  ZLO.FPQ_AS = '" + FQ5->FQ5_AS + "' "
							CQRYZLO += "   AND  ZLO.D_E_L_E_T_ = '' "
							TCQUERY CQRYZLO NEW ALIAS "TRBZLO"
							WHILE TRBFPQ->(!EOF())
								DBSELECTAREA("FPQ")
								FPQ->(DBGOTO(TRBFPQ->RECZLO))
								FPQ->(RECLOCK("FPQ",.F.))
								FPQ->(DBDELETE())
								FPQ->(MSUNLOCK())
								TRBFPQ->(DBSKIP())
							ENDDO
							TRBFPQ->(DBCLOSEAREA())
						ENDIF
						
						IF _LEXCZAG
							IF RECLOCK("FP4",.F.)
								FP4->FP4_AS     := ""
								FP4->FP4_VIAGEM := ""
								FP4->(DBDELETE())
								FP4->(MSUNLOCK())
							ENDIF
						ELSE
							IF RECLOCK("FP4",.F.)
								FP4->FP4_AS     := ""
								FP4->FP4_VIAGEM := ""
								FP4->(MSUNLOCK())
							ENDIF
						ENDIF
						
						IF FQ5->(RECLOCK("FQ5",.F.))
							FQ5->FQ5_STATUS := "9"
							FQ5->(MSUNLOCK())
						ENDIF
						
						DBSELECTAREA("ST9")
						ST9->(DBSETORDER(1))
						IF ST9->(DBSEEK(XFILIAL("ST9") + FQ5->FQ5_GUINDA)) .AND. !EMPTY(ALLTRIM(FQ5->FQ5_GUINDA))
							IF GETADVFVAL("TQY", "TQY_STTCTR",XFILIAL("TQY")+ST9->T9_STATUS,1,"") == "10"
								IF SELECT("TRBTQY") > 0
									TRBTQY->(DBCLOSEAREA())
								ENDIF
								_CQUERY := " SELECT TQY_STATUS"                   + CRLF
								_CQUERY += " FROM " + RETSQLNAME("TQY") + " TQY " + CRLF
								_CQUERY += " WHERE  TQY.TQY_STTCTR = '00' "       + CRLF
								_CQUERY += "   AND  TQY.D_E_L_E_T_ = '' "         + CRLF
								TCQUERY _CQUERY NEW ALIAS "TRBTQY"
								IF TRBTQY->(!EOF())
									//IF EXISTBLOCK("T9STSALT") //PONTO DE ENTRADA ANTES DA ALTERAÇÃO DE STATUS DO BEM.
										//EXECBLOCK("T9STSALT",.T.,.T.,{ST9->T9_STATUS,TRBTQY->TQY_STATUS,FP4->FP4_PROJET,"","",.T.})
										LOCXITU21(ST9->T9_STATUS,TRBTQY->TQY_STATUS,FP4->FP4_PROJET,"","",.T.)
									//ENDIF
									IF RECLOCK("ST9",.F.)
										ST9->T9_STATUS := TRBTQY->TQY_STATUS
										ST9->(MSUNLOCK())
									ENDIF
								ENDIF
								TRBTQY->(DBCLOSEAREA())
							ENDIF
						ENDIF
						
						IF _LC145ACE //EXISTBLOCK("LC145ACE") //PONTO DE ENTRADA PARA CANCELAMENTO DE AS DE ACESSÓRIO.
							EXECBLOCK("LC145ACE",.T.,.T.,{LVERZBX,_LEXCZAG,FP4->FP4_PROJET,FQ5->FQ5_AS,FQ5->FQ5_VIAGEM,FP4->FP4_OBRA, FP4->FP4_SEQGUI})
						ENDIF
						NCOUNT++
					ELSE
						MSGALERT(STR0020 + ALLTRIM(FQ5->FQ5_AS) + STR0021) //"CANCELAMENTO DA AS "###" NÃO EXECUTADO, POIS EXISTEM MINUTAS COM STATUS DIFERENTES DE 'PREVISTA'."
					ENDIF
				ENDIF
			ENDIF
			
		ELSE			// IF FQ5->FQ5_TPAS $ "E#G"
			
			DBSELECTAREA("FPA")
			FPA->(DBSETORDER(3))
			IF FPA->(DBSEEK(XFILIAL("FPA") + FQ5->FQ5_AS))
				IF EMPTY(ALLTRIM(FPA->FPA_NFREM))
					
					DBSELECTAREA("ST9")
					ST9->(DBSETORDER(1))
					IF ST9->(DBSEEK(XFILIAL("ST9") + FQ5->FQ5_GUINDA)) .AND. !EMPTY(ALLTRIM(FQ5->FQ5_GUINDA))
						IF GETADVFVAL("TQY", "TQY_STTCTR",XFILIAL("TQY")+ST9->T9_STATUS,1,"") == "10"
							IF LVERZBX		// TEM MINUTA? SE TIVER CHAMA ROTINA P/ EXCLUIR PROGRAMACAO E CANCELAR MINUTA
								LOCA00519( FQ5->FQ5_AS )
							ENDIF
							
							DBSELECTAREA("FPO")
							FPO->(DBSETORDER(5))
							IF FPO->(DBSEEK(XFILIAL("FPO") + FQ5->FQ5_AS))
								WHILE FPO->(!EOF()) .AND. FPO->FPO_FILIAL == XFILIAL("FPO") .AND. FPO->FPO_NRAS == FQ5->FQ5_AS
									IF RECLOCK("FPO",.F.)
										FPO->(DBDELETE())
										FPO->(MSUNLOCK())
									ENDIF
									FPO->(DBSKIP())
								ENDDO
							ENDIF
							
							IF _LEXCZAG
								IF RECLOCK("FPA",.F.)
									FPA->FPA_AS     := ""
									FPA->FPA_VIAGEM := ""
									FPA->(DBDELETE())
									FPA->(MSUNLOCK())
								ENDIF
							ELSE
								IF RECLOCK("FPA",.F.)
									FPA->FPA_AS     := ""
									FPA->FPA_VIAGEM := ""
									FPA->(MSUNLOCK())
								ENDIF
							ENDIF
							
							IF SELECT("TRBTQY") > 0
								TRBTQY->(DBCLOSEAREA())
							ENDIF
							_CQUERY := " SELECT TQY_STATUS" + CRLF
							_CQUERY += " FROM " + RETSQLNAME("TQY") + " TQY" + CRLF
							_CQUERY += " WHERE  TQY_STTCTR = '00'" + CRLF
							_CQUERY += "   AND  TQY.D_E_L_E_T_ = ''" + CRLF
							TCQUERY _CQUERY NEW ALIAS "TRBTQY"
							IF TRBTQY->(!EOF())
								//IF EXISTBLOCK("T9STSALT") 		// --> PONTO DE ENTRADA ANTES DA ALTERAÇÃO DE STATUS DO BEM.
									//EXECBLOCK("T9STSALT",.T.,.T.,{ST9->T9_STATUS,TRBTQY->TQY_STATUS,FPA->FPA_PROJET,"","",.T.})
									LOCXITU21(ST9->T9_STATUS,TRBTQY->TQY_STATUS,FPA->FPA_PROJET,"","",.T.)
								//ENDIF
								IF RECLOCK("ST9",.F.)
									ST9->T9_STATUS := TRBTQY->TQY_STATUS
									ST9->(MSUNLOCK())
								ENDIF
							ENDIF
							
							TRBTQY->(DBCLOSEAREA())
						ENDIF
					ENDIF
					
					IF FQ5->(RECLOCK("FQ5",.F.))
						FQ5->FQ5_STATUS := "9"
						FQ5->(MSUNLOCK())
					ENDIF
					
					IF _LC145ACE //EXISTBLOCK("LC145ACE") //PONTO DE ENTRADA PARA CANCELAMENTO DE AS DE ACESSÓRIO.
						EXECBLOCK("LC145ACE",.T.,.T.,{LVERZBX,_LEXCZAG,FPA->FPA_PROJET,FQ5->FQ5_AS,FQ5->FQ5_VIAGEM})
					ENDIF
					NCOUNT++
				ELSE
					IF EMPTY(_CNFREM)
						_CNFREM := ALLTRIM(FQ5->FQ5_AS)
					ELSE
						_CNFREM += CRLF + ALLTRIM(FQ5->FQ5_AS)
					ENDIF
					LOOP
				ENDIF
			ENDIF
			
		ENDIF				// IF FQ5->FQ5_TPAS $ "E#G"
		
		//NCOUNT++
	ENDIF
NEXT

END TRANSACTION
//DENNIS
CQUERY := " SELECT 1" + CRLF
IF FP0->FP0_TIPOSE $ "E#G"
	CQUERY += "  FROM " + RETSQLNAME("FP4") + " ZA5" + CRLF
	CQUERY += " WHERE FP4_PROJET = '" + FP0->FP0_PROJET + "'" + CRLF
	CQUERY += "   AND FP4_AS <> ''" + CRLF
	CQUERY += "   AND ZA5.D_E_L_E_T_ = ''"
ELSE
	CQUERY += "  FROM " + RETSQLNAME("FPA") + " ZAG" + CRLF
	CQUERY += " WHERE FPA_PROJET = '" + FP0->FP0_PROJET + "'" + CRLF
	CQUERY += "   AND FPA_AS <> ''" + CRLF
	CQUERY += "   AND ZAG.D_E_L_E_T_ = ''"
ENDIF

IF SELECT("TRBFPA") > 0
	TRBFPA->(DBCLOSEAREA())
ENDIF

TCQUERY CQUERY NEW ALIAS "TRBFPA"

IF TRBFPA->(EOF())
	IF RECLOCK("FP0", .F.)
		FP0->FP0_DATAS  := CTOD("  /  /    ")		// GRAVO A DATA DA GERAÇÃO DA AS
		
		FP0->(MSUNLOCK())
	ENDIF
ENDIF

IF !EMPTY(_CNFREM)
	AVISO(STR0022,STR0023+; //"CANCELAMENTO DE AS"###"AS AS'S ABAIXO NÃO FORAM CANCELADAS POR POSSUÍREM NOTAS FISCAIS DE REMESSA OU FATURAMENTO AUTOMÁTICO: "
	CRLF + CRLF + _CNFREM,{"OK"})
ENDIF

IF NCOUNT > 0
	AVISO(STR0022,STR0024+ALLTRIM(STR(NCOUNT))+" AS!",{"OK"}) //"CANCELAMENTO DE AS"###"FORAM CANCELADAS "
ENDIF

RESTAREA( _AAREAST9 )
RESTAREA( _AAREADTQ )
RESTAREA( _AAREAZA5 )
RESTAREA( _AAREAZAG )
RESTAREA( _AAREAZLG )
RESTAREA( _AAREAOLD )

RETURN NIL



// ======================================================================= \\
FUNCTION LOCA04001(CNUMAS)
// ======================================================================= \\
// VERIFICAR SE TEM ALGUM PEDIDO DE VENDA GERADO PARA A AS ANTES DE CANCELAR.

LOCAL _LRET   := .T.
LOCAL _CQUERY := ""

_CQUERY := " SELECT 1 "
_CQUERY += " FROM "+RETSQLNAME("SC6")+" SC6 "
_CQUERY += " WHERE  SC6.D_E_L_E_T_ = '' "
_CQUERY += "   AND  SC6.C6_XAS     = '"+ALLTRIM(CNUMAS)+"' "
IF SELECT("TRBSC6") > 0
	TRBSC6->(DBCLOSEAREA())
ENDIF
TCQUERY _CQUERY NEW ALIAS "TRBSC6"

IF TRBSC6->(!EOF())
	_LRET := .F.
ENDIF

TRBSC6->(DBCLOSEAREA())

RETURN _LRET
