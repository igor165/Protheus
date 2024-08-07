#INCLUDE "locr030.ch" 
/*/{PROTHEUS.DOC} LOCR030.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATORIO PARTE DE MINUTA
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"

FUNCTION LOCR030()
LOCAL   LADJUSTTOLEGACY := .F.
LOCAL   LDISABLESETUP   := .F.
LOCAL   CARQUIVO        := "PARTDIARIA_" + STRTRAN(TIME(),":","") + ".PDF"
LOCAL   CLOCAL          := "C:\PARTDIARIA\"
LOCAL   NRET 

PRIVATE OPRINTER
PRIVATE CMO             := ""
PRIVATE I               := 0
PRIVATE NLIN            := 10
PRIVATE CLOGO			:= ""
PRIVATE OFONT1
PRIVATE OFONT2
PRIVATE OFONT3
PRIVATE AEQUIPA			:= {}
PRIVATE CMINUTA         := CEMPANT + FPF->FPF_FILIAL + FPF->FPF_MINUTA

NRET := MAKEDIR("C:\PARTDIARIA") 

FQ5->( DBSETORDER(9) )
IF ! FQ5->( DBSEEK( XFILIAL("FQ5") + FPF->FPF_AS, .T. ) )
	MSGALERT( STR0001+ALLTRIM(FPF->FPF_AS)+STR0002, STR0003+FPF->FPF_MINUTA ) //"AS: "###" NAO ENCONTRADA, VERIFIQUE!"###"MINUTA: "
	RETURN NIL
ENDIF

FP0->( DBSETORDER(1) )
IF ! FP0->( DBSEEK( XFILIAL("FP0") + FQ5->FQ5_SOT ) )
	MSGALERT( STR0004+ALLTRIM(FQ5->FQ5_SOT)+STR0005, STR0003+FPF->FPF_MINUTA ) //"PROJETO: "###" NAO ENCONTRADO, VERIFIQUE!"###"MINUTA: "
	RETURN NIL
ENDIF

FP1->( DBSETORDER(1) )
FP1->( DBSEEK( XFILIAL("FP1") + FP0->FP0_PROJET + FQ5->FQ5_OBRA ) )

CTEL := "("+ALLTRIM(FP0->FP0_CLIDDD)+") " + ALLTRIM(FP0->FP0_CLITEL) + " " + ALLTRIM(FP0->FP0_CLIFAX)

_CFROTA := FPF->FPF_FROTA
IF EMPTY( _CFROTA )
	FP4->( DBSETORDER(3) )
	IF FP4->( DBSEEK( FPF->FPF_FILIAL + FPF->FPF_AS, .T. ) )
		AADD(AEQUIPA, {FP4->FP4_DESPRO, FP4->FP4_PRODUT } )
	ELSE
		AADD(AEQUIPA, {"", ""} )
	ENDIF
ELSE
	ST9->( DBSETORDER(1) )
	IF ST9->( DBSEEK( XFILIAL("ST9")+ _CFROTA ) )
		SB1->( DBSETORDER(1) )
		IF SB1->( DBSEEK( XFILIAL("SB1")+ ST9->T9_CODESTO ) )
			AADD(AEQUIPA, {SB1->B1_DESC, _CFROTA} )
       	ELSE
			AADD(AEQUIPA, {ST9->T9_NOME, _CFROTA} )
       	ENDIF
	ELSE
		AADD(AEQUIPA, {"", _CFROTA} )
	ENDIF
ENDIF

// CARREGANDO OS OPERADORES/MOTORISTAS
SRA->( DBSETORDER(1) )
FPQ->( DBSETORDER(3) )
FPQ->( DBSEEK( XFILIAL("FPQ") + FPF->FPF_PROJET + FPF->FPF_OBRA ) )

WHILE ! FPQ->( EOF() ) .AND. FPQ->( FPQ_FILIAL + FPQ_PROJET + FPQ_OBRA ) == XFILIAL("FPQ") + FPF->FPF_PROJET + FPF->FPF_OBRA
	IF FPQ->FPQ_AS == FPF->FPF_AS .AND. FPQ->FPQ_DATA == FPF->FPF_DATA .AND. SRA->( DBSEEK( XFILIAL("SRA") + FPQ->FPQ_MAT ) )
		CMO += IIF( EMPTY(CMO), "", "; " ) + ALLTRIM( SRA->RA_NOME )
	ENDIF
	FPQ->( DBSKIP() )
ENDDO

OPRINTER := FWMSPRINTER():NEW(CARQUIVO, 6, LADJUSTTOLEGACY,, LDISABLESETUP, , , , , , .F., )
OPRINTER:CPATHPDF := CLOCAL
OPRINTER:SETPORTRAIT()
OPRINTER:SETPAPERSIZE(9)
OPRINTER:SETVIEWPDF( .T. )

OFONT1    := TFONTEX():NEW(OPRINTER,"TIMES NEW ROMAN",08,08,.T.,.T.,.F.)// 1
OFONT2    := TFONTEX():NEW(OPRINTER,"TIMES NEW ROMAN",08,08,.F.,.F.,.F.)// 1
OFONT3    := TFONTEX():NEW(OPRINTER,"TIMES NEW ROMAN",14,14,.T.,.T.,.F.)// 1

// LOGO
IF CFILANT $ "0101|0102|0201|0401"
	CLOGO := GETSRVPROFSTRING("STARTPATH","") + SUPERGETMV("MV_LOCX016",,"\system\") // parametro removido do padr�o
ELSE
	CLOGO := GETSRVPROFSTRING("STARTPATH","") + SUPERGETMV("MV_LOCX017",,"\system\")  // parametro removido do padr�o
ENDIF

OPRINTER:STARTPAGE()

FCORPO( STR0006 ) //"1A VIA"
NLIN +=20//160 

FCORPO( STR0007 ) //"2A VIA - CLIENTE"

IF FP0->FP0_TIPOSE == "G" .AND. FPF->FPF_TIPOSE == "T"		// LOCA��O DE EQUIPAMENTO, SENDO QUE S�O ITENS DE TRANSPORTE.
	IF LEFT( FPF->FPF_AS, 2 ) == "02" 						// "11"		// TESTE P/ VER SE FUNCIONA S� PARA LOCA��O DE EQUIPAMENTO
		LOCR027( 3 )									// 1 ABRE DIALOGO DE IMPRESSAO
	ENDIF
ENDIF

OPRINTER:ENDPAGE()

CFILEPRINT := CLOCAL+CARQUIVO
FILE2PRINTER( CFILEPRINT, "PDF" )
OPRINTER:SETVIEWPDF( .T. )
OPRINTER:PREVIEW()
FREEOBJ(OPRINTER)
OPRINTER := NIL

RETURN NIL

	

// ======================================================================= \\
STATIC FUNCTION FQUEBRA( OFONT, CMO, NTAM1, NTAM2 )
// ======================================================================= \\

LOCAL ALINHAS   := {}
LOCAL OFONTSIZE	:= FWFONTSIZE():NEW()
LOCAL CTOTAL    := ALLTRIM( CMO )
LOCAL NTAM
LOCAL NPOSBR
LOCAL NI
LOCAL NAJUST    := 3

WHILE ! EMPTY( CTOTAL )
	NTAM := OFONTSIZE:GETTEXTWIDTH( CTOTAL, OFONT:NAME, OFONT:NWIDTH, OFONT:BOLD, OFONT:ITALIC ) * NAJUST

	IF NTAM <= IIF( LEN(ALINHAS)==0, NTAM1, NTAM2 )
		AADD( ALINHAS, CTOTAL )
		CTOTAL := ""
	ELSE
		NPOSBR := 0
		FOR NI := 1 TO LEN( CTOTAL )
			IF SUBSTR(CTOTAL,NI,1) == " "
				NPOSBR := NI
			ENDIF
			NTAM := OFONTSIZE:GETTEXTWIDTH( LEFT(CTOTAL, NI)  , OFONT:NAME, OFONT:NWIDTH, OFONT:BOLD, OFONT:ITALIC ) * NAJUST
			IF NTAM > IIF( LEN(ALINHAS)==0, NTAM1, NTAM2 )
				IF NPOSBR == 0
					NPOSBR := NI - 1
				ENDIF
				AADD( ALINHAS, LEFT( CTOTAL, NPOSBR ) )
				CTOTAL := SUBSTR( CTOTAL, NPOSBR+1 )
				EXIT
			ENDIF
		NEXT NI 
	ENDIF

ENDDO

RETURN ACLONE( ALINHAS )



// ======================================================================= \\
STATIC FUNCTION FCORPO( CVIA )
// ======================================================================= \\

LOCAL NI
LOCAL NLINORI
LOCAL ALINHAS := {}

OPRINTER:BOX(NLIN,10, NLIN+55,0590)
NLIN += 10
OPRINTER:SAYBITMAP(NLIN,515,CLOGO,0065,0030 )
NLIN += 2
OPRINTER:SAY(NLIN,020,STR0008,OFONT3:OFONT) //"COMPROVANTE DE LOCA��O DE EQUIPAMENTO"
OPRINTER:SAY(NLIN,300,STR0009 + FP0->FP0_PROJET,OFONT3:OFONT) //"SERIE  A   N�   "
NLIN += 15
OPRINTER:SAY(NLIN,300,STR0010+ DTOC(FPF->FPF_DATA) ,OFONT3:OFONT) //"DATA: "
OPRINTER:SAY(NLIN,020,STR0003+ CMINUTA, OFONT3:OFONT) //"MINUTA: "
NLIN += 15
OPRINTER:SAY(NLIN,020,CVIA,OFONT3:OFONT)
NLIN += 5

OPRINTER:BOX(NLIN,0010,NLIN+80,0590)
NLIN += 10

OPRINTER:SAY(NLIN,0020,STR0011,OFONT1:OFONT) //"CLIENTE:"
OPRINTER:SAY(NLIN,0360,STR0012,OFONT1:OFONT) //"CNPJ:"
OPRINTER:SAY(NLIN,0080, FQ5->FQ5_NOMCLI,OFONT1:OFONT)
OPRINTER:SAY(NLIN,0400, TRANSFORM(FP0->FP0_CLICGC, "@R 99.999.999/9999-99"),OFONT1:OFONT)
NLIN += 10

OPRINTER:SAY(NLIN,0020,STR0013,OFONT1:OFONT) //"LOCAL:"
OPRINTER:SAY(NLIN,0080, ALLTRIM(FP1->FP1_MUNORI)+" / "+FP1->FP1_ESTORI,OFONT1:OFONT)
NLIN += 10

OPRINTER:SAY(NLIN,0020,STR0014,OFONT1:OFONT) //"CONTATO:"
OPRINTER:SAY(NLIN,0360,STR0015,OFONT1:OFONT) //"TEL./RAMAL:"
OPRINTER:SAY(NLIN,0080, FP0->FP0_NOMECO,OFONT1:OFONT)
OPRINTER:SAY(NLIN,0400, CTEL,OFONT1:OFONT)
NLIN += 10

OPRINTER:SAY(NLIN,0020,STR0016,OFONT1:OFONT) //"EQUIPAMENTO:"
OPRINTER:SAY(NLIN,0360,STR0017,OFONT1:OFONT) //"C�DIGO:"

OPRINTER:SAY(NLIN,0080, AEQUIPA[1,1],OFONT1:OFONT)
OPRINTER:SAY(NLIN,0400, AEQUIPA[1,2],OFONT1:OFONT)

NLIN += 10

OPRINTER:LINE(NLIN,0010,NLIN,0590)
NLIN += 13
NLINORI := NLIN

OPRINTER:SAY(NLIN+5,0020,STR0018,OFONT1:OFONT) //"OPERADOR/MOTORISTA:"

ALINHAS := FQUEBRA( OFONT1:OFONT, CMO, (2300-0100) , (2300-0020) )
FOR NI := 1 TO LEN( ALINHAS )
	OPRINTER:SAY(NLIN, IIF(NI==1, 0100, 0020), ALINHAS[NI], OFONT1:OFONT)
	NLIN += 10
NEXT

IF NLIN == NLINORI
	NLIN += 25 
ELSE
	NLIN+=25	
ENDIF
                                           
OPRINTER:SAY(NLIN,0020,STR0019,OFONT2:OFONT) //"M�NIMO DE HORAS POR DIA: 10"
NLIN += 30
OPRINTER:SAY(NLIN,0020,STR0020,OFONT2:OFONT) //"IN�CIO ________:________H  TERMINO ________:________H          TOTAL DE HORAS _________"
NLIN += 30
OPRINTER:SAY(NLIN,0020,STR0021,OFONT2:OFONT) //"ALMO�O DAS _________ �S _________"
OPRINTER:SAY(NLIN,0150,STR0022,OFONT2:OFONT) //"JANTAR DAS _________ �S _________.   PARALISA��ES MEC�NICAS OU EL�TRICAS DAS  _________ �S _________"
NLIN += 5

OPRINTER:LINE(NLIN,0010,NLIN,0590)
OPRINTER:LINE(NLINORI,0010,NLIN,0010)
OPRINTER:LINE(NLINORI,0590,NLIN,0590)

NLINORI := NLIN
NLIN += 10

OPRINTER:SAY(NLIN,0020,STR0023,OFONT2:OFONT) //"APONTAMENTO DAS HORAS A PARTIR DE:"
NLIN += 10

FP4->( DBSETORDER(3) )
IF FP4->( DBSEEK( XFILIAL("FP4") + FPF->FPF_AS, .T. ) ) .AND. ! EMPTY(FP4->FP4_APOHRS)
	_CDESCRI := POSICIONE("SX5",1,XFILIAL("SX5")+"ZD"+FP4->FP4_APOHRS,"X5_DESCRI")
	OPRINTER:SAY(NLIN,0020, _CDESCRI,OFONT1:OFONT)
ENDIF
NLIN += 10

NLIN += 10

OPRINTER:SAY(NLIN,0320,"_____________________________________________________________________",OFONT1:OFONT)
NLIN += 10

OPRINTER:SAY(NLIN,0430,STR0024,OFONT1:OFONT) //"CLIENTE OU PREPOSTO"
NLIN += 20

OPRINTER:SAY(NLIN,0320,STR0025,OFONT1:OFONT) //"NOME:  ________________________________________________________________"
NLIN += 20

OPRINTER:SAY(NLIN,0320,STR0026,OFONT1:OFONT) //"RG:     ________________________________________________________________"
NLIN += 20
 
OPRINTER:LINE(NLINORI,0010,NLIN,0010)
OPRINTER:LINE(NLINORI,0590,NLIN,0590)
NLINORI := NLIN
NLIN += 10

OPRINTER:SAY(NLIN,0180,STR0027,OFONT1:OFONT) //"A PRESENTE N�O SER� ACEITA COM RASURAS OU RESSALVAS"
NLIN += 10

OPRINTER:SAY(NLIN,0215,STR0028,OFONT1:OFONT) //"FRA��O DE HORA SER� COBRADA COMO HORA COMPLETA"
NLIN += 10

OPRINTER:LINE(NLINORI,0010,NLINORI,0590)
OPRINTER:LINE(NLIN,0010,NLIN,0590)
OPRINTER:LINE(NLINORI,0010,NLIN,0010)
OPRINTER:LINE(NLINORI,0590,NLIN,0590)

RETURN NIL
