#INCLUDE "loca020.ch" 
/*/{PROTHEUS.DOC} LOCA020.PRW 
ITUP BUSINESS - TOTVS RENTAL
CALEND�RIO FINANCEIRO PARA CONTROLE DE PER�ODOS DE LAN�AMENTOS DAS MEDI��ES
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "PROTHEUS.CH"

FUNCTION LOCA020()
PRIVATE CCADASTRO := STR0001 //"CALEND�RIO FINANCEIRO - MEDI��ES"
PRIVATE CDELFUNC  := ".T."
PRIVATE CSTRING   := "FQ0"

DBSELECTAREA(CSTRING)

PRIVATE AROTINA   := {{STR0002 ,"AXPESQUI"  ,0,1},; //"PESQUISAR"
                      {STR0003,"AXVISUAL"  ,0,2},; //"VISUALIZAR"
                      {STR0004   ,"LOCA02001" ,0,3},; //"INCLUIR"
                      {STR0005   ,"LOCA02001" ,0,4},; //"ALTERAR"
                      {STR0006   ,"AXDELETA"  ,0,5},; //"EXCLUIR"
                      {STR0007   ,"LOCA02001" ,0,6}} //"LEGENDA"

PRIVATE ACORES    := {{ "FQ0_STATUS=='A'", "BR_VERDE" },;
                      { "FQ0_STATUS=='B'", "BR_PRETO" }}

MBROWSE( 6,1,22,75,CSTRING,,,,,,ACORES)

RETURN NIL



// ======================================================================= \\
FUNCTION LOCA02001(CALIAS, NREG, NOPC )
// ======================================================================= \\
// --> ROTINA DE INCLUS�O, ALTERA��O E LEGENDA DO CALEND�RIO FINANCEIRO.
DO CASE
CASE NOPC == 3
	AXINCLUI(CALIAS, NREG, NOPC,,,,"LOCA02002(NREG, NOPC)")
CASE NOPC == 4
	AXALTERA(CALIAS, NREG, NOPC,,,,,"LOCA02002(NREG, NOPC)")
OTHERWISE
	BRWLEGENDA(STR0007 , CCADASTRO , {{ "BR_VERDE" , STR0008   },; //"LEGENDA"###"PER�ODO ABERTO"
										{ "BR_PRETO" , STR0009}}) //"PER�ODO BLOQUEADO"
ENDCASE

RETURN NIL



// ======================================================================= \\
FUNCTION LOCA02002(NREG, NOPC)
// ======================================================================= \\
// --> VALIDA��ES DE INCLUS�O E ALTERA��O DO CALEND�RIO FINANCEIRO
LOCAL LRET      := .T.
LOCAL CALIASTMP := GETNEXTALIAS()

IF M->FQ0_DTINI > M->FQ0_DTFIM
	MSGALERT(STR0010 , STR0011)  //"DATA INV�LIDA - A DATA DE T�RMINO DEVE SER MAIOR QUE A DATA INICIAL"###"GPO - LCCALFIN.PRW"
	RETURN .F.
ENDIF

CQUERY     := " SELECT * FROM " + RETSQLNAME("FQ0") + " ZZF"
CQUERY     += " WHERE  FQ0_FILIAL='"+XFILIAL("FQ0")+"'"
CQUERY     +=   " AND  ('"+DTOS(M->FQ0_DTINI)+"' BETWEEN FQ0_DTINI AND FQ0_DTFIM  "
CQUERY     +=     " OR  '"+DTOS(M->FQ0_DTFIM)+"' BETWEEN FQ0_DTINI AND FQ0_DTFIM) "
IF NOPC == 4
	CQUERY +=   " AND  ZZF.R_E_C_N_O_ != " + STR( NREG )
ENDIF
CQUERY     +=   " AND  ZZF.D_E_L_E_T_ = ''"
DBUSEAREA(.T.,"TOPCONN",TCGENQRY(,,CQUERY),CALIASTMP,.T.,.T.)
TCSETFIELD(CALIASTMP, "FQ0_DTINI", "D",8,0)
TCSETFIELD(CALIASTMP, "FQ0_DTFIM", "D",8,0)

IF ! EOF()
	MSGALERT(STR0012+DTOC((CALIASTMP)->FQ0_DTINI)+" A "+DTOC((CALIASTMP)->FQ0_DTFIM) , STR0011)  //"ESTE PER�ODO CONFLITA COM O PER�ODO "###"GPO - LCCALFIN.PRW"
	LRET := .F.
ENDIF
DBCLOSEAREA()

DBSELECTAREA("FQ0")

RETURN LRET



// ======================================================================= \\
FUNCTION LOCA02003(DMEDICAO)
// ======================================================================= \\
// --> ROTINA DE VERIFICA��O DA MEDI��O COM O CALEND�RIO FINANCEIRO
LOCAL LRET      := .T. 
LOCAL AAREA     := GETAREA() 
LOCAL CALIASTMP := GETNEXTALIAS() 

CQUERY := " SELECT FQ0_STATUS " 
CQUERY += " FROM " + RETSQLNAME("FQ0") + " ZZF "
CQUERY += " WHERE  FQ0_FILIAL='"+XFILIAL("FQ0")+"' "
CQUERY +=   " AND  '"+DTOS(DMEDICAO)+"' BETWEEN FQ0_DTINI AND FQ0_DTFIM "
CQUERY +=   " AND  ZZF.D_E_L_E_T_ = '' "
DBUSEAREA(.T.,"TOPCONN",TCGENQRY(,,CQUERY),CALIASTMP,.T.,.T.)
TCSETFIELD(CALIASTMP , "FQ0_DTINI" , "D" , 8 , 0) 
TCSETFIELD(CALIASTMP , "FQ0_DTFIM" , "D" , 8 , 0) 

IF EOF()
	MSGALERT(STR0013 , STR0011)  //"MEDI��O FORA DO PER�ODO FINANCEIRO - PER�ODO N�O EXISTE!"###"GPO - LCCALFIN.PRW"
	LRET := .F.
ELSE
	IF (CALIASTMP)->FQ0_STATUS == "B"
		MSGALERT(STR0014 , STR0011) //"ESTE PER�ODO EST� BLOQUEADO NO FINANCEIRO!"###"GPO - LCCALFIN.PRW"
		LRET := .F.
	ENDIF
ENDIF
DBCLOSEAREA()

RESTAREA(AAREA)

RETURN LRET
