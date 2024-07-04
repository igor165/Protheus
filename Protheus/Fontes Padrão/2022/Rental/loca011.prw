#INCLUDE "loca011.ch" 
/*/{PROTHEUS.DOC} LOCA011.PRW
ITUP BUSINESS - TOTVS RENTAL
RETORNO DE LOCAวรO / LOCAวรO DE SERVIวOS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020 
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/


#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

FUNCTION LOCA011( CALIAS , NRECNO , NOPC , __LBLOQ , LROMANEIO ) 
LOCAL _CNOMCLI  := ALLTRIM(FP0->FP0_CLINOM)
LOCAL OOK       := LOADBITMAP( GETRESOURCES(), "LBOK")
LOCAL ONO       := LOADBITMAP( GETRESOURCES(), "LBNO")
LOCAL LRET      := .F.
LOCAL ORETIRA   := NIL
LOCAL OPROCESS  := NIL
LOCAL _CTITLE   := ""
LOCAL LGRRETPRC := EXISTBLOCK("GRRETPRC")

PRIVATE LGERRET := SUPERGETMV("MV_LOCX218",.F.,.T.)		// GERA NF DE RETORNO PELA TELA DE CONTRATO?
PRIVATE _CPROJE := FP0->FP0_PROJET
PRIVATE _CNOTA
PRIVATE OBRZP5
PRIVATE OBRZP6
PRIVATE OLISTP5
PRIVATE OLISTP6
PRIVATE ONUMPED
PRIVATE ONUMRES
PRIVATE ONUMAPV
PRIVATE OSTATUS
PRIVATE ABRZP5  := {}
PRIVATE OPNLSOL
PRIVATE OPNLZP5
PRIVATE ODLG
PRIVATE	LNFREMBE   := SUPERGETMV("MV_LOCX215",.F.,.F.)
PRIVATE LINVGRP    := .F.
PRIVATE _LROMANEIO := .F.
PRIVATE LBLOQ      := __LBLOQ
PRIVATE APERGS     := {}
PRIVATE ARET       := {}
PRIVATE _CTIPOSE   := "L"

PRIVATE CTIPONF   := "E" // FRANK 25/11/2020 PARA USO NA ROTINA DO MATA100B
PRIVATE CTES             // FRANK 25/11/2020 PARA USO NA ROTINA DO MATA100B

PRIVATE CGRPAND		 := SUPERGETMV("MV_LOCX014",.F.,"" )  // FRANK 12/08/20
DEFAULT __LBLOQ    := .F. 
DEFAULT LROMANEIO  := .F.
DEFAULT NOPC := ""
// FRANK 12/08/2020
IF SBM->(FIELDPOS("BM_XACESS")) > 0
	CGRPAND := LOCA00189()
ELSE
	CGRPAND := SUPERGETMV("MV_LOCX014",.F.,"")
ENDIF

if valtype(nOpc) <> "C"
	nOpc := alltrim(str(nOpc))
EndIf

AADD(APERGS , {2 , STR0001 , 1 , {STR0002,STR0003} , 80 , "" , .T.})  //"TIPO"###"LOCAวรO"###"SERVIวO"
IF SUPERGETMV("MV_LOCX023",,.F.) // parametro removido no padrใo
	IF PARAMBOX(APERGS ,STR0004,ARET,,,,,,,,.F.)  //"SELECIONE O TIPO DE SERVIวO"
		IF LEN(ARET) == 0
			RETURN
		ENDIF 
		IF EMPTY(ARET[1])
			MSGALERT(STR0005 , STR0006) //"FALTOU SELECIONAR O TIPO DE SERVIวO."###"Aten็ใo!"
			RETURN
		ENDIF
	ELSE
		MSGALERT(STR0007 , STR0006) //"CANCELADO PELO OPERADOR."###"Aten็ใo!"
		RETURN
    ENDIF
	IF ALLTRIM(ARET[1]) == STR0003 //"SERVIวO"
		_CTIPOSE := "S"
	ENDIF 
ENDIF 

_LROMANEIO := LROMANEIO 
LRET	   := SUPERGETMV("MV_LOCX008",.F.,.F.)			// LROMANEIO 	// --> .T. = GERA NF  / .F. = GERA ROMANEIO. 

If _lRomaneio
	lRet := .T.
EndIf

// --> CHAMA FUNวรO QUE ALIMENTA O LISTBOX. 
ITENS(_CTIPOSE) 

// --> LISTBOX COM OS ITENS DO PROJETO. 
IF _CTIPOSE == "L"
	_CTITLE := STR0008 //"NOTA FISCAL DE RETORNO DE LOCAวรO"
ELSE
	_CTITLE := STR0009 //"LOCAวรO DE SERVIวOS"
ENDIF 

DEFINE MSDIALOG ODLG TITLE _CTITLE FROM 010,005 TO 550,900 PIXEL

	OPNLSOL := TPANEL():NEW(0, 0, "", ODLG, NIL, .T., .F., NIL, NIL, 0,050, .F., .T. )
	OPNLSOL:ALIGN := CONTROL_ALIGN_TOP 
	
	// CRIA OBJETO DE FONTE
	DEFINE FONT OFONT  NAME "MONOAS" SIZE 0, -16 BOLD
	DEFINE FONT OFONT1 NAME "MONOAS" SIZE 0, -18 BOLD
	
	@ 005,005 SAY STR0010 FONT OFONT1                PIXEL OF OPNLSOL //"PROJETO: "
	@ 005,070 SAY _CPROJE     FONT OFONT1 COLOR CLR_BLUE PIXEL OF OPNLSOL
	
	@ 020,005 SAY STR0011 FONT OFONT1                PIXEL OF OPNLSOL //"CLIENTE: "
	@ 020,070 SAY _CNOMCLI    FONT OFONT1 COLOR CLR_BLUE PIXEL OF OPNLSOL
	
	OPNLZP5 := TPANEL():NEW(0, 0, "", ODLG, NIL, .T., .F., NIL, NIL, 0,90, .F., .T. )
	OPNLZP5:ALIGN := CONTROL_ALIGN_ALLCLIENT
	
	IF _CTIPOSE == "L"
		@ 005,005 SAY STR0012   FONT OFONT PIXEL OF OPNLZP5 //"NOTA FISCAL DE REMESSA: "
	ELSE
		@ 005,005 SAY STR0013 FONT OFONT PIXEL OF OPNLZP5 //"SELEวรO DO(S) SERVIวO(S): "
	ENDIF 

	@ 170,001 CHECKBOX OCHKINVGRP VAR LINVGRP PROMPT STR0014 SIZE 100, 10 OF OPNLZP5 PIXEL ;  //"SELECIONA TUDO"
	          ON CLICK (MARCATUDO(ABRZP5,LINVGRP,_CTIPOSE),OLISTP5:REFRESH(),;
	          IIF(VALTYPE(OPROCESS) == "O" , IIF(( ! VERARRAY(ABRZP5)), OPROCESS:DISABLE() , OPROCESS:ENABLE()),),;
	          IIF(VALTYPE(ORETIRA)  == "O" , IIF(( ! VERARRAY(ABRZP5)), ORETIRA:DISABLE()  , ORETIRA:ENABLE()) ,))
                  
IF _CTIPOSE == "L"
	@ 025,001 LISTBOX OLISTP5 VAR CVARGRP FIELDS HEADER " ",STR0015,STR0016,STR0017,STR0018,STR0019,STR0020,STR0021,STR0022,STR0023; //"PRODUTO"###"GRUA"###"FAMอLIA"###"DESCRIวรO GRUA"###"DESCRIวรO CENTRAB"###"NF REMESSA"###"NF RETORNO"###"DESC.PROD."###"QUANTIDADE"
	          SIZE 440,140 ON DBLCLICK (LSVTROCA(OLISTP5:NAT, _CTIPOSE),OLISTP5:REFRESH(),;
	          IIF(VALTYPE(OPROCESS) == "O" , IIF(( ! VERARRAY(ABRZP5)), OPROCESS:DISABLE() , OPROCESS:ENABLE()),),;
	          IIF(VALTYPE(ORETIRA)  == "O" , IIF(( ! VERARRAY(ABRZP5)), ORETIRA:DISABLE()  , ORETIRA:ENABLE()) ,)) ;
	          ON RIGHT CLICK LISTBOXALL(NROW,NCOL,@OLISTP5,OOK,ONO,@ABRZP5) OF OPNLZP5 PIXEL 

	OLISTP5:SETARRAY(ABRZP5)
	OLISTP5:BLINE := {||{IF(ABRZP5[OLISTP5:NAT][01],OOK,ONO),;
							ABRZP5[OLISTP5:NAT][02],;
							ABRZP5[OLISTP5:NAT][03],;
							ABRZP5[OLISTP5:NAT][04],;
							ABRZP5[OLISTP5:NAT][05],;
							ABRZP5[OLISTP5:NAT][06],;
							ABRZP5[OLISTP5:NAT][07],;
							ABRZP5[OLISTP5:NAT][08],;
							ABRZP5[OLISTP5:NAT][17],;
							ABRZP5[OLISTP5:NAT][18]}}
							OLISTP5:BHEADERCLICK := {|A,B| FHEADCLICK(A,B)}
ELSE
	@ 025,001 LISTBOX OLISTP5 VAR CVARGRP FIELDS HEADER " ",STR0015,STR0024,STR0025; //"PRODUTO"###"DESCRIวรO"###"FIM COBRANวA"
	          SIZE 440,140 ON DBLCLICK (LSVTROCA(OLISTP5:NAT, _CTIPOSE),OLISTP5:REFRESH(),;
	          IIF(VALTYPE(OPROCESS) == "O" , IIF(( ! VERARRAY(ABRZP5)), OPROCESS:DISABLE() , OPROCESS:ENABLE()),),;
	          IIF(VALTYPE(ORETIRA)  == "O" , IIF(( ! VERARRAY(ABRZP5)), ORETIRA:DISABLE()  , ORETIRA:ENABLE()),)) ;
	          ON RIGHT CLICK LISTBOXALL(NROW,NCOL,@OLISTP5,OOK,ONO,@ABRZP5) OF OPNLZP5 PIXEL 

	OLISTP5:SETARRAY(ABRZP5)
	OLISTP5:BLINE := {||{IF(ABRZP5[OLISTP5:NAT][01],OOK,ONO),;
							ABRZP5[OLISTP5:NAT][02],;
							ABRZP5[OLISTP5:NAT][05],;
							ABRZP5[OLISTP5:NAT][11]}}
							OLISTP5:BHEADERCLICK := {|A,B| FHEADCLICK(A,B)}
ENDIF 

IF !LGERRET 											// GERA RETORNO PELO CONTRATO
	IF FUNNAME() == "LOCA029"
		IF ! LBLOQ .AND. _CTIPOSE == "L"
			@ 190,60 BUTTON OPROCESS PROMPT STR0026 SIZE 050,012 OF OPNLZP5 PIXEL ACTION( ,; //"PROCESSA"
			         IIF( if(LOCA11VAL(),MSGYESNO(OEMTOANSI(STR0027),STR0028),.f.) ,; //"Deseja gerar NF de Retorno para os itens selecionados?"###"Gera NF Retorno"
			         PROCESSA( {|| NOPC := "1" , ODLG:END() }, STR0029, STR0030, .T.),; //"AGUARDE..."###"PROCESSANDO..."
			         NIL ))
		ENDIF
	ELSE     
		IF _CTIPOSE == "L"
			
			@ 190,005 BUTTON ORETIRA PROMPT STR0031 SIZE 050,012 OF OPNLZP5 PIXEL ACTION( ATUZLG(_CTIPOSE), ITENS(_CTIPOSE), OLISTP5:SETARRAY(ABRZP5),; //"DADOS RETIRADA"
			          OLISTP5:BLINE := {||{IF(ABRZP5[OLISTP5:NAT][01],OOK,ONO),;
			                                  ABRZP5[OLISTP5:NAT][02],;
			                                  ABRZP5[OLISTP5:NAT][03],;
			                                  ABRZP5[OLISTP5:NAT][04],;
			                                  ABRZP5[OLISTP5:NAT][05],;
			                                  ABRZP5[OLISTP5:NAT][06],;
			                                  ABRZP5[OLISTP5:NAT][07],;
			                                  ABRZP5[OLISTP5:NAT][08],;
											  ABRZP5[OLISTP5:NAT][17],;
											  ABRZP5[OLISTP5:NAT][18]}},;
			                                  OLISTP5:BHEADERCLICK := {|A,B| FHEADCLICK(A,B)},;
			                                  IIF(VALTYPE(OPROCESS) == "O" , IIF(( ! VERARRAY(ABRZP5)), OPROCESS:DISABLE() , OPROCESS:ENABLE()),),;
			                                  IIF(VALTYPE(ORETIRA)  == "O" , IIF(( ! VERARRAY(ABRZP5)), ORETIRA:DISABLE() , ORETIRA:ENABLE()),) ,;
			                                  OLISTP5:REFRESH() )
											  
		ELSE
			
			@ 190,005 BUTTON ORETIRA PROMPT STR0031 SIZE 050,012 OF OPNLZP5 PIXEL ACTION( ATUZLG(_CTIPOSE), ITENS(_CTIPOSE), OLISTP5:SETARRAY(ABRZP5),; //"DADOS RETIRADA"
			          OLISTP5:BLINE := {||{IF(ABRZP5[OLISTP5:NAT][01],OOK,ONO),;
			                                  ABRZP5[OLISTP5:NAT][02],;
			                                  ABRZP5[OLISTP5:NAT][05],;
			                                  ABRZP5[OLISTP5:NAT][11]}},;
			                                  OLISTP5:BHEADERCLICK := {|A,B| FHEADCLICK(A,B)},;
			                                  IIF(VALTYPE(OPROCESS) == "O" , IIF(( ! VERARRAY(ABRZP5)), OPROCESS:DISABLE() , OPROCESS:ENABLE()),),;
			                                  IIF(VALTYPE(ORETIRA)  == "O" , IIF(( ! VERARRAY(ABRZP5)), ORETIRA:DISABLE()  , ORETIRA:ENABLE()),) ,;
			                                  OLISTP5:REFRESH() )
											  
		ENDIF 
	ENDIF 
ELSE 
	IF _CTIPOSE == "L"
		
		@ 190,005 BUTTON ORETIRA PROMPT STR0031 SIZE 050,012 OF OPNLZP5 PIXEL ACTION( ATUZLG(_CTIPOSE), ITENS(_CTIPOSE), OLISTP5:SETARRAY(ABRZP5),; //"DADOS RETIRADA"
		          OLISTP5:BLINE := {||{IF(ABRZP5[OLISTP5:NAT][01],OOK,ONO),;
		                                  ABRZP5[OLISTP5:NAT][02],;
		                                  ABRZP5[OLISTP5:NAT][03],;
		                                  ABRZP5[OLISTP5:NAT][04],;
		                                  ABRZP5[OLISTP5:NAT][05],;
		                                  ABRZP5[OLISTP5:NAT][06],;
		                                  ABRZP5[OLISTP5:NAT][07],;
		                                  ABRZP5[OLISTP5:NAT][08],;
										  ABRZP5[OLISTP5:NAT][17],;
										  ABRZP5[OLISTP5:NAT][18]}},;
		                                  OLISTP5:BHEADERCLICK := {|A,B| FHEADCLICK(A,B)},;
		                                  IIF(VALTYPE(OPROCESS) == "O" , IIF(( ! VERARRAY(ABRZP5)), OPROCESS:DISABLE() , OPROCESS:ENABLE()),),;
		                                  IIF(VALTYPE(ORETIRA)  == "O" , IIF(( ! VERARRAY(ABRZP5)), ORETIRA:DISABLE()  , ORETIRA:ENABLE()),) ,;
		                                  OLISTP5:REFRESH() )
										  
	ELSE
		
		@ 190,005 BUTTON ORETIRA PROMPT STR0031 SIZE 050,012 OF OPNLZP5 PIXEL ACTION( ATUZLG(_CTIPOSE), ITENS(_CTIPOSE), OLISTP5:SETARRAY(ABRZP5),; //"DADOS RETIRADA"
		          OLISTP5:BLINE := {||{IF(ABRZP5[OLISTP5:NAT][01],OOK,ONO),;
		                                  ABRZP5[OLISTP5:NAT][02],;
		                                  ABRZP5[OLISTP5:NAT][05],;
		                                  ABRZP5[OLISTP5:NAT][11]}},;
		                                  OLISTP5:BHEADERCLICK := {|A,B| FHEADCLICK(A,B)},;
		                                  IIF(VALTYPE(OPROCESS) == "O" , IIF(( ! VERARRAY(ABRZP5)), OPROCESS:DISABLE() , OPROCESS:ENABLE()),),;
		                                  IIF(VALTYPE(ORETIRA)  == "O" , IIF(( ! VERARRAY(ABRZP5)), ORETIRA:DISABLE()  , ORETIRA:ENABLE()),) ,;
		                                  OLISTP5:REFRESH() )
										  
	ENDIF 
	IF ! LBLOQ .AND. _CTIPOSE == "L"
		@ 190,60 BUTTON OPROCESS PROMPT STR0026 SIZE 050,012 OF OPNLZP5 PIXEL ACTION( , ; //"PROCESSA"
		         IIF( If(LOCA11VAL(),MSGYESNO(OEMTOANSI(STR0027),STR0028),.f.) , ;  //"Deseja gerar NF de Retorno para os itens selecionados?"###"Gera NF Retorno"
		         PROCESSA( {|| NOPC := "1" , ODLG:END() }, STR0029, STR0030, .T.) , ;  //"AGUARDE..."###"PROCESSANDO..."
		         NIL ))
	ENDIF
ENDIF 

IF _CTIPOSE == "L"
	@ 190,115 BUTTON STR0032                  SIZE 50,12 OF OPNLZP5 PIXEL ACTION( ODLG:END() ) //"SAIR"
	@ 190,170 BUTTON OFILTRO PROMPT STR0033 SIZE 50,12 OF OPNLZP5 PIXEL ACTION ( ABRZP5 := LBFILTRO(ABRZP5),; //"FILTRO"
	OLISTP5:SETARRAY(ABRZP5),;
	OLISTP5:BLINE := { || { IF(ABRZP5[OLISTP5:NAT][01],OOK,ONO),;
	                           ABRZP5[OLISTP5:NAT][02],;
	                           ABRZP5[OLISTP5:NAT][03],;
	                           ABRZP5[OLISTP5:NAT][04],;
	                           ABRZP5[OLISTP5:NAT][05],;
	                           ABRZP5[OLISTP5:NAT][06],;
	                           ABRZP5[OLISTP5:NAT][07],;
	                           ABRZP5[OLISTP5:NAT][08],;
							   ABRZP5[OLISTP5:NAT][17],;
							   ABRZP5[OLISTP5:NAT][18]}},;
	                           OLISTP5:REFRESH(),;
	                           IIF(VALTYPE(ORETIRA)  == "O" , ORETIRA:DISABLE()  , NIL) , ; 
	                           IIF(VALTYPE(OPROCESS) == "O" , OPROCESS:DISABLE() , NIL) )

	@ 190,225 BUTTON OFILTRO PROMPT STR0034 SIZE 50,12 OF OPNLZP5 PIXEL ACTION (ITENS(_CTIPOSE),; //"LIMPAR FILTRO"
	OLISTP5:SETARRAY(ABRZP5),;
	OLISTP5:BLINE := { || { IF(ABRZP5[OLISTP5:NAT][01],OOK,ONO),;
	                           ABRZP5[OLISTP5:NAT][02],;
	                           ABRZP5[OLISTP5:NAT][03],;
	                           ABRZP5[OLISTP5:NAT][04],;
	                           ABRZP5[OLISTP5:NAT][05],;
	                           ABRZP5[OLISTP5:NAT][06],;
	                           ABRZP5[OLISTP5:NAT][07],;
	                           ABRZP5[OLISTP5:NAT][08],;
							   ABRZP5[OLISTP5:NAT][17],;
							   ABRZP5[OLISTP5:NAT][18]}},;
	                           OLISTP5:REFRESH(),;
	                           IIF(VALTYPE(ORETIRA)  == "O" , ORETIRA:DISABLE()  , NIL) , ; 
	                           IIF(VALTYPE(OPROCESS) == "O" , OPROCESS:DISABLE() , NIL) )
ELSE
	@ 190,60 BUTTON STR0032 SIZE 050,012 OF OPNLZP5 PIXEL ACTION( ODLG:END() ) //"SAIR"
ENDIF 
IF VALTYPE(ORETIRA) == "O"
	ORETIRA:DISABLE()
ENDIF
IF VALTYPE(OPROCESS) == "O"
	OPROCESS:DISABLE()
ENDIF
ODLG:REFRESH()

ACTIVATE MSDIALOG ODLG CENTERED

IF NOPC == "1"
	IF LGRRETPRC //EXISTBLOCK("GRRETPRC") 									// --> PONTO DE ENTRADA (GPO) ANTES DA ALTERAวรO DE STATUS DO BEM.
		LRET := EXECBLOCK("GRRETPRC",.T.,.T.,{ABRZP5})
	ENDIF 
	IF LRET 
		PROCESSA( {|| LRET := GRVNFE() }, STR0029, STR0030, .T.) //"AGUARDE..."###"PROCESSANDO..."
		IF LRET
			MSGINFO(STR0035+_CNOTA , STR0006) //"Gerado a NF de Retorno No\Serie.: "###"Aten็ใo!"
			// Gravar o n๚mero da nota de entrada no campo FQ2_NFSER
			// Frank em 06/07/21
			FQ2->(RecLock("FQ2",.F.))
			FQ2->FQ2_NFSER := _CNOTA 
			FQ2->(MsUnlock())
		ELSE
			MSGINFO(STR0036 , STR0006) //"NรO FOI POSSอVEL GERAR A NOTA DE RETORNO PARA OS ITENS!"###"Aten็ใo!"
		ENDIF
	ELSE 
		MSGALERT(STR0037 , STR0006)  //"O SISTEMA NรO ESTม HABILITADO PARA GERAR NF DE RETORNO SEM ROMANEIO ! VERIFIQUE PARยMETRO 'MV_LOCX008' !"###"Aten็ใo!"
	ENDIF 
ENDIF 

RETURN NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ LBFILTRO  บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 14/10/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑณDESCRICAO ณ REALIZA FILTRO DOS ITENS A SEREM FATURADOS.                ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION LBFILTRO(AARRAY)

LOCAL NOPC     := ""
LOCAL ODLG
LOCAL OFILTRO
LOCAL OCANBUT
LOCAL AAUX     := {}
LOCAL CFAMI    := SPACE(TAMSX3("T9_CODFAMI")[1])
LOCAL CCENT    := SPACE(TAMSX3("HB_NOME")[1])
LOCAL CDESC    := SPACE(TAMSX3("T9_NOME")[1])
LOCAL CNFREM   := SPACE(TAMSX3("F2_DOC")[1])
LOCAL NZ       := 0 
//LOCAL NLIN     := 000
//LOCAL NCOL     := 000
//LOCAL CFILTRO  := ""
//LOCAL CF3
//LOCAL CPICTURE := ""
//LOCAL AFILTRO  := {"F=FAMILIA", "D=DESCRIวรO BEM", "C=CENTRO DE TRABALHO" } 		// T9_CODFAMI , FPA_DESGRU E HB_NOME

DEFINE MSDIALOG ODLG TITLE STR0038 FROM 0,0 TO 025,050 OF OMAINWND //"FILTRO NF REMESSA"
	@ 007,007 SAY OSAYFAM VAR STR0039 SIZE 250,12 OF ODLG PIXEL //"PREENCHA OS CAMPOS QUE DESEJA PESQUISAR NA TELA DE ITENS ATIVA!"
	
	@ 035,007 SAY   OSAYFAM VAR STR0040           SIZE  80,12 OF ODLG PIXEL  //"FAMILIA: "
	@ 046,007 MSGET CFAMI   F3 "ST6"                  SIZE  50,12 OF ODLG PIXEL 	/*VALID ! VAZIO()              WHEN CONDIวรO PICTURE CPICTURE */
	
	@ 075,007 SAY   OSAYCEN VAR STR0041 SIZE  80,12 OF ODLG PIXEL  //"DESCRIวรO CENTRAB: "
	@ 086,007 MSGET CCENT                             SIZE 120,12 OF ODLG PIXEL 	/* F3 "NG11" VALID ! VAZIO() /*WHEN CONDIวรO PICTURE CPICTURE */
	
	@ 105,007 SAY   OSAYDES VAR STR0042    SIZE  80,12 OF ODLG PIXEL //"DESCRIวรO GRUA: "
	@ 116,007 MSGET CDESC                             SIZE 120,12 OF ODLG PIXEL 	/*F3 CF3     VALID ! VAZIO() /*WHEN CONDIวรO PICTURE CPICTURE */
	
	@ 135,007 SAY   OSAYNFR VAR STR0043        SIZE  80,12 OF ODLG PIXEL  //"NF REMESSA: "
	@ 146,007 MSGET CNFREM                            SIZE 120,12 OF ODLG PIXEL 	/*F3 CF3     VALID ! VAZIO() /*WHEN CONDIวรO PICTURE CPICTURE */
	
	@ 172,062 BUTTON OFILTRO PROMPT STR0044         SIZE  50,12 OF ODLG PIXEL ACTION (NOPC := "1",ODLG:END())  //"FILTRAR"
	@ 172,007 BUTTON OCANBUT PROMPT STR0045        SIZE  50,12 OF ODLG PIXEL ACTION (ODLG:END())  //"CANCELAR"
ACTIVATE MSDIALOG ODLG CENTERED

IF NOPC == "1"
	IF ! EMPTY(CFAMI)
		FOR NZ := 1 TO LEN(AARRAY)
			IF UPPER(ALLTRIM(CFAMI)) $ UPPER(ALLTRIM(AARRAY[NZ,4]))
				AADD(AAUX, AARRAY[NZ])
			ENDIF
		NEXT NZ 
	ENDIF
	IF ! EMPTY(CCENT)
		FOR NZ := 1 TO LEN(AARRAY)
			IF UPPER(ALLTRIM(CCENT)) $ UPPER(ALLTRIM(AARRAY[NZ,6]))
				IF ASCAN(AAUX, {|X| X[9] == AARRAY[NZ,9] }) = 0
					AADD(AAUX, AARRAY[NZ])
				ENDIF
			ENDIF
		NEXT NZ 
	ENDIF
	IF ! EMPTY(CDESC)
		FOR NZ := 1 TO LEN(AARRAY)
			IF UPPER(ALLTRIM(CDESC)) $ UPPER(ALLTRIM(AARRAY[NZ,5]))
				IF ASCAN(AAUX, {|X| X[9] == AARRAY[NZ,9] }) = 0
					AADD(AAUX, AARRAY[NZ])
				ENDIF
			ENDIF
		NEXT NZ 
	ENDIF
	IF ! EMPTY(CNFREM)
	//	CAUX += IIF( ! EMPTY(CAUX),  " .AND. ('"+ALLTRIM(CDESC)+"') $ ALLTRIM(AARRAY[NZ,6])" , "('"+ALLTRIM(CDESC)+"') $ ALLTRIM(AARRAY[NZ,6])" )
		FOR NZ := 1 TO LEN(AARRAY)
			IF UPPER(ALLTRIM(CNFREM)) $ UPPER(ALLTRIM(AARRAY[NZ,7]))
				IF ASCAN(AAUX, {|X| X[11] == AARRAY[NZ,9] }) = 0
					AADD(AAUX, AARRAY[NZ])
				ENDIF
			ENDIF
		NEXT NZ 
	ENDIF
	IF LEN(AAUX) > 0
		AARRAY := AAUX
	ENDIF
ENDIF

RETURN AARRAY



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ VERARRAY  บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 14/10/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑณDESCRICAO ณ VERIFICA SE O ARRAY POSSUI ALGUM REGISTRO MARCADO COMO .T. ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION VERARRAY(_AARRAY)

LOCAL _LRET := .F. 
LOCAL NX 

FOR NX := 1 TO LEN(_AARRAY) 
	IF _AARRAY[NX][1] 
		_LRET := .T. 
		EXIT 
	ENDIF 
NEXT 

RETURN _LRET



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ MARCATUDO บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 14/10/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑณDESCRICAO ณ MARCA E DESMARCA TODOS OS ITENS.                           ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION MARCATUDO(_AARRAY , LMARCATUDO , _CTIPOSE) 
       
DEFAULT _CTIPOSE := "L"

IF LEN(_AARRAY) > 0
	IF _CTIPOSE == "L"
		AEVAL(_AARRAY , {|_AARRAY| IIF( ! EMPTY(ALLTRIM(_AARRAY[8])) .OR. EMPTY(ALLTRIM(_AARRAY[7])) , _AARRAY[1] := .F. , _AARRAY[1] := LMARCATUDO) })
	ELSE
		AEVAL(_AARRAY , {|_AARRAY| IIF( .F. , _AARRAY[1] := .F. , _AARRAY[1] := LMARCATUDO) })
	ENDIF
	LMARCATUDO := !LMARCATUDO
ENDIF

RETURN // _AARRAY



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ LSVTROCA  บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 14/10/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑณDESCRICAO ณ MARCA E DESMARCA UM ฺNICO ITEM.                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION LSVTROCA(NIT , _CTIPOSE)

DEFAULT _CTIPOSE := "L"

// --> CASO Jม TENHA NOTA DE RETORNO.
IF _CTIPOSE == "L"

	IF GETMV("MV_LOCX067",,.T.) // controle do retorno desde que tenha uma nota de remessa
		IF EMPTY(ALLTRIM(ABRZP5[NIT][7])) .OR. ! EMPTY(ABRZP5[NIT][8]) 
			ABRZP5[NIT][1] := .F.
		ELSEIF ! EMPTY(ALLTRIM(ABRZP5[NIT][7]))  .AND.  EMPTY(ABRZP5[NIT][8]) 
			ABRZP5[NIT][1] := ! ABRZP5[NIT][1] 
		ENDIF 
	Else
		IF ! EMPTY(ABRZP5[NIT][8]) 
			ABRZP5[NIT][1] := .F.
		ELSEIF EMPTY(ABRZP5[NIT][8]) 
			ABRZP5[NIT][1] := ! ABRZP5[NIT][1] 
		ENDIF 
	EndIF
ELSE                 
	IF ABRZP5[NIT][1]
		ABRZP5[NIT][1] := .F.
	ELSE
		ABRZP5[NIT][1] := .T.
	ENDIF 

ENDIF  

RETURN NIL             



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ FHEADCLICKบ AUTOR ณ IT UP BUSINESS     บ DATA ณ 18/10/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ ORDENA O ARRAY DO LIST BOX                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION FHEADCLICK( OOBJ , NCOLUNA ) 

LOCAL   NPOS	:= 2 					// POSICAO DA DESCRICAO NO ARRAY
LOCAL   ADEPARA	:= {1,2,3,4,5,6,7,8}
LOCAL   NCOL

DEFAULT NCOLUNA	:= OLISTP5:NCOLPOS

NCOL := ADEPARA[ NCOLUNA ]

ASORT(ABRZP5,,,{|X,Y| TRFDADO( X[NCOL] ) + X[NPOS] < TRFDADO( Y[NCOL] ) + Y[NPOS] })

OLISTP5:REFRESH()

RETURN NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ TRFDADO   บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 18/10/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ VERIFICA O TIPO DE DADOS PARA A FUNวรO QUE ORDENA O ARRAY  บฑฑ
ฑฑบ          ณ DO LISTBOX                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION TRFDADO(XDADO) 

PRIVATE CRET := XDADO

IF VALTYPE(CRET) == "D"
	CRET := DTOS( CRET )
ENDIF

IF VALTYPE(CRET) == "L"
	CRET := IIF( CRET , "1" , "0" ) 
ENDIF

IF VALTYPE(CRET) == "N"
	CRET := STR( CRET )
ENDIF

RETURN CRET



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ ITENS     บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 18/10/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ QUERY QUE TRAZ OS ITENS DO PROJETO.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION ITENS(_CTIPOSE)
LOCAL CCODFAMI  // FRANK 12/08/20
LOCAL CNOME		// FRANK 12/08/20
LOCAL NREG      // FRANK 12/08/20
LOCAL CHBNOME   // FRANK 12/08/20
LOCAL _NRET     // FRANK 16/10/20
LOCAL _CITEM    // FRANK 19/10/20

DEFAULT _CTIPOSE := "L"

ASIZE(ABRZP5 , 0)

IF _LROMANEIO
   CQRYZP5  := " SELECT DISTINCT FPA_NFREM, FPA_DNFREM, FPA_REBOQI, FPA_PLACAI, FPA_GRUA, FPA_PROJET," + CRLF
ELSE
   CQRYZP5  := " SELECT FPA_NFREM, FPA_DNFREM, FPA_REBOQI, FPA_PLACAI, FPA_GRUA,     " + CRLF
ENDIF
CQRYZP5     += " FPA_AS, FPA_DTPREN, FPA_MOTENT, FPA_DTPRRT, FPA_MOTRET, FPA_DTSCRT, " + CRLF
CQRYZP5     += " FPA_NFRET, FPA_SERRET, FPA_GUIDES, FPA_DTINI, FPA_TIPOSE,           " + CRLF
CQRYZP5     += " FPA_PRODUT, FPA_SERREM, FPA_ITEREM, FPA_FILREM, FPA_DNFRET, FPA_QUANT,         " + CRLF
CQRYZP5     += " FPA_OBRA, "

IF _CTIPOSE == "L"
	//CQRYZP5 += " ISNULL(DA4_NOME, '') DA4_NOME, T9_NOME, T9_CODFAMI, HB_NOME,        " + CRLF
	//CQRYZP5 += " ST9.R_E_C_N_O_ RECNOST9, ZAG.R_E_C_N_O_ RECNOZAG                    " + CRLF FRANK 12/08/2020
	//CQRYZP5 += " ISNULL(DA4_NOME, '') DA4_NOME, HB_NOME,        " + CRLF
	CQRYZP5 += " COALESCE(DA4_NOME,'') DA4_NOME,         " + CRLF
	
	CQRYZP5 += " ZAG.R_E_C_N_O_ RECNOZAG
ELSE
	CQRYZP5 += " ZAG.R_E_C_N_O_ RECNOZAG "
ENDIF 

CQRYZP5     += " FROM " + RETSQLNAME("FPA") + " ZAG (NOLOCK)                         " + CRLF

IF _LROMANEIO .AND. _CTIPOSE == "L"
	CQRYZP5 += " INNER JOIN "+RETSQLNAME("FQ3")+" SZ1 			" + CRLF
	CQRYZP5 += " ON SZ1.FQ3_FILIAL	= ZAG.FPA_FILIAL    		" + CRLF
	CQRYZP5 += " AND SZ1.FQ3_PROJET	= ZAG.FPA_PROJET   			" + CRLF
	CQRYZP5 += " AND SZ1.FQ3_VIAGEM	= ZAG.FPA_VIAGEM   			" + CRLF
	CQRYZP5 += " AND SZ1.FQ3_OBRA	= ZAG.FPA_OBRA       		" + CRLF
	CQRYZP5 += " AND SZ1.FQ3_AS		= ZAG.FPA_AS           		" + CRLF
	CQRYZP5 += " AND SZ1.D_E_L_E_T_	= ''                		" + CRLF
	CQRYZP5 += " AND SZ1.FQ3_FILIAL	=	'"+FQ2->FQ2_FILIAL+"'" + CRLF
	CQRYZP5 += " AND SZ1.FQ3_NUM		=	'"+FQ2->FQ2_NUM+"'	" + CRLF
	CQRYZP5 += " INNER JOIN "+RETSQLNAME("FQ2")+" SZ0 			" + CRLF
	CQRYZP5 += " ON  SZ1.FQ3_FILIAL	= SZ0.FQ2_FILIAL    			" + CRLF
	CQRYZP5 += " AND SZ1.FQ3_NUM		= SZ0.FQ2_NUM          		" + CRLF
	CQRYZP5 += " AND SZ1.FQ3_ASF		= SZ0.FQ2_ASF          		" + CRLF
	CQRYZP5 += " AND SZ0.D_E_L_E_T_=''                			" + CRLF
ENDIF                  

IF _CTIPOSE == "L"
	// REMOVIDO POR FRANK 12/08/20
	/*
	CQRYZP5 += " JOIN " + RETSQLNAME("ST9") + " ST9 (NOLOCK)                         " + CRLF
	CQRYZP5 += " ON ST9.T9_FILIAL = '" + XFILIAL("ST9") + "'                         " + CRLF
	CQRYZP5 += " AND ST9.T9_CODBEM = ZAG.FPA_GRUA                                    " + CRLF
	CQRYZP5 += " AND ST9.D_E_L_E_T_=''                                               " + CRLF
	*/

	/*
	CQRYZP5 += " LEFT JOIN "+RETSQLNAME("SHB")+" SHB                                 " + CRLF
	CQRYZP5 += "  ON SHB.HB_FILIAL='" + XFILIAL("SHB") + "'                          " + CRLF
	CQRYZP5 += " AND SHB.HB_COD=ST9.T9_CENTRAB                                       " + CRLF
	CQRYZP5 += " AND SHB.D_E_L_E_T_=''                                               " + CRLF
	*/

	CQRYZP5 += " LEFT JOIN " + RETSQLNAME("DA4") + " DA4 (NOLOCK)                    " + CRLF
	CQRYZP5 += " ON DA4.DA4_FILIAL = '"+XFILIAL('DA4')+"'                            " + CRLF
	CQRYZP5 += " AND DA4.DA4_COD = ZAG.FPA_MOTRET                                    " + CRLF
	CQRYZP5 += " AND DA4.D_E_L_E_T_=''                                               " + CRLF

	CQRYZP5 += " WHERE ZAG.FPA_FILIAL = '"+XFILIAL("FPA")+"'                         " + CRLF
	CQRYZP5 += " AND ZAG.FPA_PROJET = '"+_CPROJE+"'                                  " + CRLF
	CQRYZP5 += " AND ZAG.D_E_L_E_T_ = ''                                             " + CRLF
	//CQRYZP5 += " ORDER BY T9_NOME, FPA_DNFREM, FPA_DTSCRT, FPA_AS                    " FRANK 12/08/20
	CQRYZP5 += " ORDER BY FPA_DNFREM, FPA_DTSCRT, FPA_AS                    "
ELSE
	CQRYZP5 += " WHERE ZAG.FPA_FILIAL = '"+XFILIAL("FPA")+"'                         " + CRLF
	CQRYZP5 += " AND ZAG.FPA_PROJET = '"+_CPROJE+"'                                  " + CRLF
	CQRYZP5 += " AND ZAG.D_E_L_E_T_ = '' AND FPA_TIPOSE = 'M'                        " + CRLF
    
	CQRYZP5 += " ORDER BY FPA_AS, FPA_DTSCRT      "
ENDIF 
IF SELECT("TMPFPY") > 0
	TMPFPY->( DBCLOSEAREA() )
ENDIF
CQRYZP5 := CHANGEQUERY(CQRYZP5) 
TCQUERY CQRYZP5 NEW ALIAS "TMPFPY"

IF TMPFPY->( EOF() )
	AADD(ABRZP5,{ .F.,"","","","","","","","","","","","","","","","","",0 })
ELSE
	TMPFPY->( DBGOTOP() )
	WHILE TMPFPY->( !EOF() )
		IF _CTIPOSE == "L"

			SB1->(DBSETORDER(1))
			SB1->(DBSEEK(XFILIAL("SB1")+TMPFPY->FPA_PRODUT))
			IF ! ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CGRPAND)
				ST9->(DBSETORDER(1))		
				ST9->(DBSEEK(XFILIAL("ST9")+TMPFPY->FPA_GRUA))
				CCODFAMI 	:= ST9->T9_CODFAMI
				CNOME		:= ST9->T9_NOME
				NREG		:= ST9->(RECNO())

				SHB->(DBSETORDER(1))
				SHB->(DBSEEK(XFILIAL("SHB")+ST9->T9_CENTRAB))
				CHBNOME := SHB->HB_NOME

			ELSE
				IF !EMPTY(TMPFPY->FPA_GRUA)
					ST9->(DBSETORDER(1))		
					ST9->(DBSEEK(XFILIAL("ST9")+TMPFPY->FPA_GRUA))
					CCODFAMI 	:= ST9->T9_CODFAMI
					CNOME		:= ST9->T9_NOME
					NREG		:= ST9->(RECNO())
					SHB->(DBSETORDER(1))
					SHB->(DBSEEK(XFILIAL("SHB")+ST9->T9_CENTRAB))
					CHBNOME := SHB->HB_NOME
				ELSE
					CCODFAMI 	:= ""
					CNOME		:= ""
					NREG		:= 0
					CHBNOME		:= ""
				ENDIF
			ENDIF

			If TMPFPY->FPA_TIPOSE == "Z"
				TMPFPY->(dbskip())
				Loop
			EndIf

			AADD(ABRZP5 , { .F.                      , ; 	// 01
				            TMPFPY->FPA_PRODUT       , ; 	// 02
				            TMPFPY->FPA_GRUA         , ; 	// 03
				            CCODFAMI			     , ; 	// 04
				            CNOME                    , ; 	// 05
				            CHBNOME			         , ; 	// 06
				            TMPFPY->FPA_NFREM        , ; 	// 07
				            TMPFPY->FPA_NFRET        , ; 	// 08
				            TMPFPY->RECNOZAG         , ; 	// 09
				            NREG		             , ; 	// 10
				            TMPFPY->FPA_DTSCRT       , ; 	// 11 - DATA DE SOLICITAวรO DE RETIRADA
				            TMPFPY->FPA_AS           , ; 	// 12
				            TMPFPY->FPA_DTPRRT       , ; 	// 13 - DATA DE PREVISรO DE RETIRADA
				            TMPFPY->FPA_MOTRET       , ; 	// 14 - CIDIGO MOTORISTA
				            TMPFPY->DA4_NOME         , ; 	// 15 - NOME MOTORISTA
				            TMPFPY->FPA_GUIDES       , ;    // 16 - VALOR FRETE
							SB1->B1_DESC			 , ;    // 17 - DESCRICAO DO PRODUTO FRANK Z FUGA 13/08/20 
							TMPFPY->FPA_QUANT		 } )    // 18 - QUANTIDAE FRANK Z FUGA 13/08/20		

			// FRANK EM 16/10/20 - BUSCAR A QUANTIDADE DO TOTAL LIBERADO NA SZ1 - ROMANEIO
			IF _LROMANEIO
				// PASSO 1 - LOCALIZAR A ZUC
				// FQ7_VIAORI == FPA_VIAGEM
				// FQ7_PROJET == FPA_PROJET
				// FQ7_OBRA   == FPA_OBRA
				// FQ7_TPROMA == "1" RETORNO

				// PASSO 2 - LOCALIZAR A DTQ
				// FQ5_SOT    == FPA_PROJET
				// FQ5_OBRA   == FPA_OBRA
				// FQ5_VIAGEM == FQ7_VIAGEM

				// PASSO 3 - LOCAL A SZ1
				// FQ3_ASF == FQ5_AS
				// FQ3_PROJET = FQ5_SOT
				// FQ3_VIAGEM = FPA_VIAGEM

				_NRET := 0
				_CQUERY := " SELECT FQ3_QTD, FQ3_ITEM "
				_CQUERY += " FROM " + RETSQLNAME("FQ3") + " SZ1" 
				_CQUERY += " WHERE "
				_CQUERY += "       SZ1.FQ3_FILIAL = '"+XFILIAL("FQ3")+"' AND "
				_CQUERY += "       SZ1.FQ3_AS = '"+FPA->FPA_AS+"' AND "
				_CQUERY += "       SZ1.FQ3_VIAGEM = '"+FPA->FPA_VIAGEM+"' AND "
				//_CQUERY += "       SZ1.FQ3_NUM = '"+SF1->F1_IT_ROMA+"' AND "
				_CQUERY += "       SZ1.FQ3_NUM = '"+FQ2->FQ2_NUM+"' AND "
				_CQUERY += "       SZ1.FQ3_NFRET = '' AND "
				_CQUERY += "       SZ1.D_E_L_E_T_ = '' "
				IF SELECT("TRBFQ3") > 0
					TRBFQ3->(DBCLOSEAREA())
				ENDIF
				TCQUERY _CQUERY NEW ALIAS "TRBFQ3" 
				_CITEM := ""
				WHILE !TRBFQ3->(EOF())
					IF TRBFQ3->FQ3_ITEM > _CITEM
						_NRET := TRBFQ3->FQ3_QTD
						_CITEM := TRBFQ3->FQ3_ITEM
					ENDIF
					TRBFQ3->(DBSKIP())
				ENDDO
				//_NRET := TRBFQ3->FQ3_QTD
				TRBFQ3->(DBCLOSEAREA())
				ABRZP5[LEN(ABRZP5)][18] := _NRET

			
			ENDIF


		ELSE
			AADD(ABRZP5 , { .F.                      , ; 	// 01
				            TMPFPY->FPA_PRODUT       , ; 	// 02
				            ""                       , ; 	// 03
				            ""                       , ; 	// 04
				            POSICIONE('SB1',1,XFILIAL('SB1')+TMPFPY->FPA_PRODUT,'B1_DESC')	,; // 05
				            ""                       , ; 	// 06
				            ""                       , ; 	// 07
				            ""                       , ; 	// 08
				            TMPFPY->RECNOZAG         , ; 	// 09
				            0                        , ; 	// 10
				            STOD(TMPFPY->FPA_DTSCRT) , ; 	// 11 - DATA DE SOLICITAวรO DE RETIRADA
				            TMPFPY->FPA_AS           , ; 	// 12
				            CTOD("")                 , ; 	// 13 - DATA DE PREVISรO DE RETIRADA
				            ""                       , ; 	// 14 - CIDIGO MOTORISTA
				            ""                       , ; 	// 15 - NOME MOTORISTA
				            0 						 , ;    // 16 - VALOR FRETE 
							SB1->B1_DESC             , ;    // 17 - DESCRICAO DO PRODUTO FRANK Z FUGA 13/08/20
							TMPFPY->FPA_QUANT  		 } ) 	// 18 - QUANTIDADE FRANK Z FUGA 13/08/20						


		ENDIF 
		TMPFPY->( DBSKIP() )
	ENDDO
ENDIF

TMPFPY->( DBCLOSEAREA() )

If len(ABRZP5) == 0
	AADD(ABRZP5,{ .F.,"","","","","","","","","","","","","","","","","",0 })
EndIF

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ GRVNFE    บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 09/08/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ GERA NOTA DE RETORNO DE LOCAวรO PARA O PROJETO POSICIONADO บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION GRVNFE()

LOCAL   AAREA       := GETAREA()
LOCAL   NITEM       := ""
LOCAL	CNOTA		:= SPACE(TAMSX3("D1_DOC")[1])
LOCAL	CSERIE		:= SPACE(TAMSX3("D1_SERIE")[1])
LOCAL   ACAB        := {}
LOCAL   ALINHA      := {}
LOCAL   AITENS      := {}
LOCAL	AZAG		:= {}
LOCAL   LRET        := .F.
LOCAL   CMENNOTA    := "CONTRATO: "+ALLTRIM(FP0->FP0_PROJET) + CRLF
LOCAL   CFILBKP     := ""
LOCAL   _NI         := 0 
Local	lFormPropr	:= .F.
Local	CFORM		:= "N"
//LOCAL	NOPC		:= "0"
//LOCAL LNFZAG		:= .F.
//LOCAL _ANFCON     := {}
Local	cObsCTit	:= ""
Local	cObsCCon	:= ""
Local	cObsFTit	:= ""
Local	cObsFCon	:= ""

Local _MV_LOC025 := SUPERGETMV("MV_LOCX025",,"004")
Local _MV_LOC201 := SUPERGETMV("MV_LOCX201",.F.,"001")
Local _NFRTITEM := EXISTBLOCK("NFRTITEM")

PRIVATE LMSERROAUTO	:= .F.
PRIVATE _CPARVOLTA  := ""

_CTES := SUPERGETMV("MV_LOCX254",.F.,"002") 			// GETMV("MV_XRETCON")

IF VALTYPE(_LROMANEIO) <> "L"
	_LROMANEIO := .F.
ENDIF

FP1->( DBSETORDER(1) )
IF FP1->( DBSEEK( XFILIAL("FP1") + FP0->FP0_PROJET, .T. ) )
	CMENNOTA += "END.: " + ALLTRIM(FP1->FP1_ENDORI) + CRLF
	CMENNOTA += "MUN.: " + ALLTRIM(FP1->FP1_MUNORI) + CRLF
	CMENNOTA += "BAI.: " + ALLTRIM(FP1->FP1_BAIORI) + CRLF
	CMENNOTA += "UF.: "  + ALLTRIM(FP1->FP1_ESTORI) + CRLF
	CMENNOTA += "CEP.: " + TRANSFORM(FP1->FP1_CEPORI,"@R 99999-999") + CRLF
ENDIF

// [inicio] Jos้ Eulแlio - 03/06/2022 - SIGALOC94-346 - #27421 - NF de Retorno Apresentar o formulแrio quando for Formulแrio Pr๓prio = Sim.
lFormPropr := MSGYESNO("RETORNO DA NF SERม VIA FORMULมRIO PRำPRIO?" , STR0006)  //"RETORNO DA NF SERม VIA FORMULมRIO PRำPRIO?"###"ATENCรO!"
// [final] Jos้ Eulแlio - 03/06/2022 - SIGALOC94-346 - #27421 - NF de Retorno Apresentar o formulแrio quando for Formulแrio Pr๓prio = Sim.
FOR _NI := 1 TO LEN(ABRZP5)
	IF ABRZP5[_NI][1]
	// --> SE NรO TIVER DATA DE SOLICITAวรO DE RETIRADA A ROTINA AVISA E PULA O ITEM. 
		IF EMPTY(ABRZP5[_NI][11])
			//MSGALERT("PRECISA INFORMAR DATA DE SOLICITACAO DE RETIRADA PARA O BEM "+ALLTRIM(ABRZP5[_NI][3])+" E A AS: "+ALLTRIM(ABRZP5[_NI][12])+"!" , "GPO - GERNFRET.PRW") 
			//LOOP
		ENDIF

		// --> CASO Jม TENHA NOTA GRAVADA NO 15 DO ARRAY AVISA QUE O ITEM Jม FOI PROCESSADO E GRAVA OS DADOS PARA ATUALIZAR A ZAG COM OS DADOS DA NF DE RETORNO.
		IF ! EMPTY(ABRZP5[_NI][8])
			MSGALERT(STR0061+ALLTRIM(ABRZP5[_NI][3])+STR0062 , STR0006) //"O BEM "###" Jม FOI PROCESSADO"###"Aten็ใo!"
			LOOP
		ENDIF

		// --> SELECIONA OS DADOS DA NOTA DE ACORDO COM A ZAG.
		DADOREM(_NI)

		// --> TIPO DA NOTA SERม DE ACORDO COM A SAอDA. 
		IF TMPSD2->( !EOF() ) 
			IF     TMPSD2->D2_TIPO == "N"
				CTIPONF := "D"
			ELSEIF TMPSD2->D2_TIPO == "B"
				CTIPONF := "B"
			ELSE
				CTIPONF := "N"
			ENDIF

			// --> A TES DE RETORNO SERม A TES CADASTRADA PARA DEVOLUวรO NA TES DE REMESSA.
			//SF4->(DBSETORDER(1))
			//SF4->(DBSEEK(XFILIAL("SF4")+TMPSD2->D2_TES ))
			//IF ! EMPTY(SF4->F4_TESDV)
			//	_CTES := SF4->F4_TESDV
			//ELSE
		//		MSGSTOP("A TES: "+TMPSD2->D2_TES+" DEVE TER UMA TES DE DEVOLUวรO DEFINIDA NO CAMPO 'TES DEVOL.'" , "GPO - GERNFRET.PRW") 
			//	RETURN .F.
			//ENDIF

			// FRANK 12/11/20
			//IF SF4->F4_PODER3 == "D"
            //    CTIPONF := "B"
			//ENDIF

			// FRANK 25/11/2020
			// ANTES VINHA DA NOTA DE REMESSA
			_CTES  := _MV_LOC025 //SUPERGETMV("MV_LOCX025",,"004")
			CTES   := _CTES

			SF4->(DBSETORDER(1))
			SF4->(DBSEEK(XFILIAL("SF4")+_CTES))
			CTIPONF := "D"
			IF SF4->F4_PODER3 == "D"
                CTIPONF := "B"
			ENDIF

			// --> CASO NรO SEJA PREENCHIDO O CAMPO DE NOTA NA ATUALIZAวรO GERA FORMULมRIO PRำPRIO.
			// [inicio] Jos้ Eulแlio - 03/06/2022 - SIGALOC94-346 - #27421 - NF de Retorno Apresentar o formulแrio quando for Formulแrio Pr๓prio = Sim.
			If lFormPropr
				CSERIE	:= _MV_LOC201
				CNOTA   := NXTSX5NOTA(CSERIE, NIL, "1")
			Else
			IF (EMPTY(ABRZP5[_NI,08]) .AND. (LEN(ACAB) == 0))
				CFORM	:= "S"
				CSERIE	:= _MV_LOC201 //SUPERGETMV("MV_LOCX201",.F.,"001")
				IF CFILANT <> TMPSD2->D2_FILIAL
				   CFILBKP := CFILANT
				   CFILANT := TMPSD2->D2_FILIAL
				   CNOTA   := NXTSX5NOTA(CSERIE, NIL, "1")
				   CFILANT := CFILBKP
				ELSE
				   CNOTA   := NXTSX5NOTA(CSERIE, NIL, "1")
				ENDIF
			ENDIF
			EndIf

			// --> GERA CABEวALHO E ITENS.
			IF LEN(ACAB) == 0
				AADD(ACAB,{"F1_FILIAL"  , TMPSD2->D2_FILIAL })
				AADD(ACAB,{"F1_SERIE"   , CSERIE			})
				AADD(ACAB,{"F1_DOC"     , CNOTA				})
				AADD(ACAB,{"F1_TIPO"    , CTIPONF           })
				AADD(ACAB,{"F1_FORNECE" , TMPSD2->D2_CLIENTE})
				AADD(ACAB,{"F1_LOJA"    , TMPSD2->D2_LOJA   })
				AADD(ACAB,{"F1_FORMUL"  , CFORM 			})
				AADD(ACAB,{"F1_EMISSAO" , DDATABASE         })
				AADD(ACAB,{"F1_ESPECIE" , "SPED"            })
				AADD(ACAB,{"F1_COND"    , "001"             })
				AADD(ACAB,{"F1_XPROJET" , FP0->FP0_PROJET   })
				AADD(ACAB,{"F1_MENNOTA" , CMENNOTA          })
				IF _LROMANEIO
					AADD(ACAB,{"F1_IT_ROMA" , FQ2->FQ2_NUM   })
				ENDIF
			ENDIF

			NITEM := STRZERO( LEN(AITENS)+1,TAMSX3("D1_ITEM")[1],0) //SOMA1(NITEM)
			/*
			ALINHA := {	{"D1_FILIAL"  , TMPSD2->D2_FILIAL , NIL} , ;
						{"D1_ITEM"    , NITEM             , NIL} , ;
						{"D1_COD"     , TMPSD2->D2_COD    , NIL} , ;
						{"D1_UM"      , TMPSD2->D2_UM     , NIL} , ;
						{"D1_QUANT"   , TMPSD2->D2_QUANT  , NIL} , ;
						{"D1_VUNIT"   , TMPSD2->D2_PRCVEN , NIL} , ; 
						{"D1_TOTAL"   , TMPSD2->D2_TOTAL  , NIL} , ; 
						{"D1_LOCAL"   , TMPSD2->D2_LOCAL  , NIL} , ; 
						{"D1_TES"     , _CTES             , NIL} , ; 
						{"D1_DOC"     , CNOTA             , NIL} , ;
						{"D1_SERIE"   , CSERIE            , NIL} , ;
						{"D1_NFORI"   , TMPSD2->D2_DOC    , NIL} , ;
						{"D1_SERIORI" , TMPSD2->D2_SERIE  , NIL} , ;
						{"D1_ITEMORI" , TMPSD2->D2_ITEM   , NIL} }
			*/
			// FRANK 16/10/2020
			FPA->(DBSETORDER(3))
			FPA->(DBSEEK(XFILIAL("FPA")+ABRZP5[_NI][12]))
			
			_CQUERY := " SELECT FQ3_NUM "
			_CQUERY += " FROM " + RETSQLNAME("FQ3") + " FQ3" 
			_CQUERY += " WHERE "
			_CQUERY += "       FQ3.FQ3_FILIAL = '"+XFILIAL("FQ3")+"' AND "
			_CQUERY += "       FQ3.FQ3_AS = '"+FPA->FPA_AS+"' AND "
			_CQUERY += "       FQ3.FQ3_VIAGEM = '"+FPA->FPA_VIAGEM+"' AND "
			_CQUERY += "       FQ3.FQ3_NUM = '"+FQ2->FQ2_NUM+"' AND "
			_CQUERY += "       FQ3.FQ3_NFRET = '' AND "
			_CQUERY += "       FQ3.D_E_L_E_T_ = '' "
			IF SELECT("TRBSZ1") > 0
				TRBSZ1->(DBCLOSEAREA())
			ENDIF
			TCQUERY _CQUERY NEW ALIAS "TRBSZ1" 
			_CSZ1NUM := TRBSZ1->FQ3_NUM
			TRBSZ1->(DBCLOSEAREA())

			If _lRomaneio
				_NRET := 0
				_CQUERY := " SELECT FQ3_QTD, FQ3_ITEM "
				// [inicio] Jos้ Eulแlio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
				If FQ3->(ColumnPos("FQ3_OBSCCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSCON")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFIS")) > 0
					_CQUERY += " , FQ3_OBSCCM, FQ3_OBSCON, FQ3_OBSFCM,  FQ3_OBSFIS"
				EndIf
				// [final] Jos้ Eulแlio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
				_CQUERY += " FROM " + RETSQLNAME("FQ3") + " FQ3" 
				_CQUERY += " WHERE "
				_CQUERY += "       FQ3.FQ3_FILIAL = '"+XFILIAL("FQ3")+"' AND "
				_CQUERY += "       FQ3.FQ3_NUM = '"+_CSZ1NUM+"' AND "
				_CQUERY += "       FQ3.FQ3_AS = '"+FPA->FPA_AS+"' AND "
				//_CQUERY += "       SZ1.Z1_NFRET = '' AND "
				_CQUERY += "       FQ3.D_E_L_E_T_ = '' "
				IF SELECT("TRBSZ1") > 0
					TRBSZ1->(DBCLOSEAREA())
				ENDIF
				TCQUERY _CQUERY NEW ALIAS "TRBSZ1" 

				_CITEM := ""
				WHILE !TRBSZ1->(EOF())
					IF TRBSZ1->FQ3_ITEM > _CITEM
						_NRET := TRBSZ1->FQ3_QTD
						_CITEM := TRBSZ1->FQ3_ITEM
						// [inicio] Jos้ Eulแlio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
						If FQ3->(ColumnPos("FQ3_OBSCCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSCON")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFIS")) > 0
							cObsCTit	:= TRBSZ1->FQ3_OBSCCM
							cObsCCon	:= TRBSZ1->FQ3_OBSCON
							cObsFTit	:= TRBSZ1->FQ3_OBSFCM
							cObsFCon	:= TRBSZ1->FQ3_OBSFIS
						EndIf
						// [final] Jos้ Eulแlio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
					ENDIF
					TRBSZ1->(DBSKIP())
				ENDDO
				TRBSZ1->(DBCLOSEAREA())
			Else
				// Quando nใo for retorno de romaneio, pegar a quantidade retornada da nota fiscal de saida associada
				// Frank 25/02/2021
				_nRet := TMPSD2->D2_QUANT 
			EndIf
			// [inicio] Jos้ Eulแlio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
			If _lRomaneio .And. FQ3->(ColumnPos("FQ3_OBSCCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSCON")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFIS")) > 0
				ALINHA := {	{"D1_FILIAL"  , TMPSD2->D2_FILIAL , NIL} , ;
						{"D1_ITEM"    , NITEM             , NIL} , ;
						{"D1_COD"     , TMPSD2->D2_COD    , NIL} , ;
						{"D1_UM"      , TMPSD2->D2_UM     , NIL} , ;
						{"D1_QUANT"   , _nret  , NIL} , ;
						{"D1_VUNIT"   , TMPSD2->D2_PRCVEN , NIL} , ; 
						{"D1_TOTAL"   , _nret * TMPSD2->D2_PRCVEN   , NIL} , ; 
						{"D1_LOCAL"   , TMPSD2->D2_LOCAL  , NIL} , ; 
						{"D1_TES"     , _CTES             , NIL} , ; 
						{"D1_DOC"     , CNOTA             , NIL} , ;
						{"D1_SERIE"   , CSERIE            , NIL} , ;
						{"D1_NFORI"   , TMPSD2->D2_DOC    , NIL} , ;
						{"D1_SERIORI" , TMPSD2->D2_SERIE  , NIL} , ;
						{"D1_IDENTB6" , TMPSD2->D2_IDENTB6, NIL} , ;
						{"D1_ITEMORI" , TMPSD2->D2_ITEM   , NIL} , ;
						{"D1_OBSCTIT" , cObsCTit  			, NIL} , ;
						{"D1_OBSCONT" , cObsCCon 			, NIL} , ;
						{"D1_OBSFTIT" , cObsFTit  			, NIL} , ;
						{"D1_OBSFISC" , cObsFCon   			, NIL} }
			Else
				ALINHA := {	{"D1_FILIAL"  , TMPSD2->D2_FILIAL , NIL} , ;
						{"D1_ITEM"    , NITEM             , NIL} , ;
						{"D1_COD"     , TMPSD2->D2_COD    , NIL} , ;
						{"D1_UM"      , TMPSD2->D2_UM     , NIL} , ;
						{"D1_QUANT"   , _nret  , NIL} , ;
						{"D1_VUNIT"   , TMPSD2->D2_PRCVEN , NIL} , ; 
						{"D1_TOTAL"   , _nret * TMPSD2->D2_PRCVEN   , NIL} , ; 
						{"D1_LOCAL"   , TMPSD2->D2_LOCAL  , NIL} , ; 
						{"D1_TES"     , _CTES             , NIL} , ; 
						{"D1_DOC"     , CNOTA             , NIL} , ;
						{"D1_SERIE"   , CSERIE            , NIL} , ;
						{"D1_NFORI"   , TMPSD2->D2_DOC    , NIL} , ;
						{"D1_SERIORI" , TMPSD2->D2_SERIE  , NIL} , ;
						{"D1_IDENTB6" , TMPSD2->D2_IDENTB6  , NIL} , ;
						{"D1_ITEMORI" , TMPSD2->D2_ITEM   , NIL} }
			EndIf
			// [final] Jos้ Eulแlio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
			IF _NFRTITEM //EXISTBLOCK("NFRTITEM") 							// --> PONTO DE ENTRADA (GPO) PARA ALTERAวรO DOS ITENS DA NOTA FISCAL DE RETORNO.
				ALINHA := EXECBLOCK("NFRTITEM",.T.,.T.,{ALINHA})
			ENDIF

			AADD( AITENS, ALINHA )
			AADD(AZAG, {.T. , ABRZP5[_NI,09] , CNOTA , CSERIE , DDATABASE , TMPSD2->D2_FILIAL , NITEM , ABRZP5[_NI,10] })
		ENDIF
	ENDIF
NEXT _NI

// --> GERA A NOTA DE ENTRADA E CASO SUCESSO GRAVA OS DADOS NA ZAG.
IF LEN(ACAB) > 0 .AND. LEN(AITENS) > 0
	IF EXECDE(ACAB,AITENS) 
		_CNOTA := CNOTA +"\"+ CSERIE
		IF _LROMANEIO
			SF1->(RECLOCK("SF1",.F.))
			SF1->F1_IT_ROMA := FQ2->FQ2_NUM
			SF1->(MSUNLOCK())
		ENDIF
		LRET := .T.
		GRVZAG(AZAG) 
	ENDIF 
ENDIF 

IF SELECT("TMPSD2")>0
	TMPSD2->(DBCLOSEAREA()) 
ENDIF

RESTAREA(AAREA)

RETURN LRET



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ EXECDE    บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 09/08/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ GERA NOTA DE RETORNO DE LOCAวรO PARA O PROJETO POSICIONADO บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION EXECDE(ACAB,AITENS)

LOCAL LRETI    := .F. 
LOCAL CFILBCK  := CFILANT 
LOCAL _CMODULE := NMODULO 
LOCAL LNFSEMRO := SUPERGETMV("MV_LOCX008",.F.,.F.)		// --> .T. = GERA NF  / .F. = GERA ROMANEIO. 
LOCAL lFORCA   := .F.
LOCAL lLOCA11A := EXISTBLOCK("LOCA11A")

Private _lErroNf := .F. // variavel que sofre alteracao no fonte MT103FIM
IF LEN(ACAB) > 0 .AND. LEN(AITENS) > 0
	CFILANT := ACAB[1,2]
	NMODULO := 2
	BEGIN TRANSACTION
	// [inicio] Jos้ Eulแlio - 03/06/2022 - SIGALOC94-346 - #27421 - NF de Retorno Apresentar o formulแrio quando for Formulแrio Pr๓prio = Sim.
	//MSEXECAUTO({|X,Y| MATA103(X,Y)},ACAB,AITENS,3,.T.)

	IF lLOCA11A
		lFORCA := EXECBLOCK("LOCA11A",.T.,.T.,{})
	ENDIF
	If cFilAnt <> SF2->F2_FILIAL .or. lForca
		cFilAux := cFilAnt  
		nRecSM0 := SM0->(RECNO())
		cFilAnt := cFilAnt 							// SF2->F2_FILIAL 
		Mata103( aCab, AITENS , 3 , .T.)
		cFilAnt := cFilAux 
		SM0->(dbGoTo(nRecSM0))
	Else   
		Mata103( aCab, AITENS , 3 , .T.)
		_lMostra := .T.
	EndIf

	If _lErroNF
		DISARMTRANSACTION()
	Else
		/*IF LMSERROAUTO
			MOSTRAERRO()
			DISARMTRANSACTION()
			BREAK
		ELSE*/
			IF .NOT. LNFSEMRO 
				RECLOCK("SF1",.F.) 
					SF1->F1_IT_ROMA := FQ2->FQ2_NUM 
				SF1->(MSUNLOCK()) 
				// Gravar o n๚mero da nota de retorno no campo FQ2_NFSER
				// Frank em 06/07/21
				FQ2->(RecLock("FQ2",.F.))
				FQ2->FQ2_NFSER := SF1->F1_DOC +"/"+ SF1->F1_SERIE
				FQ2->(MsUnlock())
			ENDIF 
			MSGINFO(STR0060+SF1->F1_DOC+"]" , STR0006) //"PROCESSO FINALIZADO - NF ENTRADA RETORNO DO CLIENTE NO: ["###"Aten็ใo!"
			LRETI := .T. 
			IF ODLG <> NIL
				ODLG:END() 
			ENDIF
		//ENDIF
	EndIF
	// [final] Jos้ Eulแlio - 03/06/2022 - SIGALOC94-346 - #27421 - NF de Retorno Apresentar o formulแrio quando for Formulแrio Pr๓prio = Sim.
	END TRANSACTION
ENDIF
CFILANT := CFILBCK 
NMODULO := _CMODULE 

RETURN LRETI



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ GRVZAG    บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 09/08/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ GRAVA OS DADOS NA ZAG.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION GRVZAG(AZAG)

LOCAL AAREA		:= GETAREA()
LOCAL AAREAZAG	:= FPA->(GETAREA())
LOCAL AAREAST9	:= ST9->(GETAREA())
LOCAL _CQUERY   := ""
LOCAL _CNEWSTS  := SUPERGETMV("MV_LOCX219",.F.,"")
LOCAL _NW       := 0
LOCAL _NENV
LOCAL _NRET
Local _MV_LOC010 := GETMV('MV_LOCX010',,"")
Local _lPassa    := .F.

IF TYPE("_NZUC")== "N"
	_lPassa := .T.
EndIf

IF EMPTY(_CNEWSTS)
	IF SELECT("TRBTQY") > 0
		TRBTQY->(DBCLOSEAREA())
	ENDIF
	_CQUERY := " SELECT TOP 1 TQY_STATUS"                         + CRLF
	_CQUERY += " FROM " + RETSQLNAME("TQY") + " TQY (NOLOCK)"     + CRLF
	_CQUERY += " WHERE  TQY.TQY_STTCTR >= '60' "                  + CRLF	// MANUTENวรO
	_CQUERY += "   AND  TQY.D_E_L_E_T_  = '' "                    + CRLF
	_CQUERY += " ORDER BY TQY_STTCTR"
	TCQUERY _CQUERY NEW ALIAS "TRBTQY"

	IF TRBTQY->(EOF())
		IF SELECT("TRBSTS") > 0
			TRBSTS->(DBCLOSEAREA())
		ENDIF
		_CQUERY := " SELECT TOP 1 TQY_STATUS"                     + CRLF
		_CQUERY += " FROM " + RETSQLNAME("TQY") + " TQY (NOLOCK)" + CRLF
		_CQUERY += " WHERE  TQY.TQY_STTCTR IN ('00','40','60')"   + CRLF
		_CQUERY += "   AND  TQY.D_E_L_E_T_ = ''"                  + CRLF
		_CQUERY += " ORDER BY TQY_STTCTR DESC"
		TCQUERY _CQUERY NEW ALIAS "TRBSTS"

		IF TRBSTS->(!EOF())
			_CNEWSTS := TRBSTS->TQY_STATUS
		ENDIF

		TRBSTS->(DBCLOSEAREA())
	ELSE
		_CNEWSTS := TRBTQY->TQY_STATUS
	ENDIF

	TRBTQY->(DBCLOSEAREA())
ENDIF

FOR _NW := 1 TO LEN( AZAG )
	IF AZAG[_NW][1]
		BEGIN TRANSACTION
			FPA->( DBGOTO( AZAG[_NW][02] ) )
			IF AZAG[_NW][02] == FPA->( RECNO())
/*	// --> P.E. DESCONTINUADO !!! 
				IF EXISTBLOCK("LOCC001_")						// --> PONTO DE ENTRADA (GPO) COM TRATATIVA GRAVAวAO LOG: ZA0, ZA1 E ZAG 
					U_LOCC001_("GRV_PROJETO", {FPA->FPA_FILIAL, FPA->FPA_PROJET} ) 
				ENDIF 
*/	// --> P.E. DESCONTINUADO !!! 
				/* FRANK 19/10/20 NOVO TRATAMENTO PARA GRAVACAO DA NOTA PARCIAL
				IF FPA->(RECLOCK("FPA",.F.)) 
					FPA->FPA_NFRET	:= AZAG[_NW][03]
					FPA->FPA_SERRET	:= AZAG[_NW][04]
					FPA->FPA_DNFRET	:= AZAG[_NW][05]
					FPA->(MSUNLOCK())
				ENDIF 
				*/

// Sำ ARMAZENAR A NOTA SE FOR A ULTIMA ENTRADA, OU SEJA, SE AS QUANTIDADES FOREM IGUAIS.
				// FRANK 19/10/20
				FP0->(DBSETORDER(1))
				FP0->(DBSEEK(XFILIAL("FP0")+FPA->FPA_PROJET))

				IF _lPassa //TYPE("_NZUC")== "N" // VARIAVEL CRIADA NA ROTINA LOC05102.PRW - FRANK 02/11/20
					IF _NZUC > 0
						_LTEMZUC := .T.
					ELSE
						_LTEMZUC := .F.
					ENDIF
				ELSE
					_LTEMZUC := .F.
				ENDIF

				/*
				FQ7->(DBSETORDER(1))
				FQ7->(DBSEEK(XFILIAL("FQ7")+FPA->FPA_PROJET))
				WHILE !FQ7->(EOF()) .AND. FQ7->FQ7_PROJET == FPA->FPA_PROJET
					IF FQ7->FQ7_VIAORI == FPA->FPA_VIAGEM .AND. FQ7->FQ7_OBRA == FPA->FPA_OBRA .AND. FQ7->FQ7_TPROMA == "1"
						_LTEMZUC := .T.
					ENDIF
					FQ7->(DBSKIP())
				ENDDO
				*/

				IF FP0->FP0_TIPOSE == "L" .AND. _LTEMZUC
					_NENV := 0
					IF !EMPTY(FPA->FPA_NFREM)
						SC6->(DBSETORDER(4))
						SC6->(DBSEEK(FPA->FPA_FILREM+FPA->FPA_NFREM+FPA->FPA_SERREM))
						WHILE !SC6->(EOF()) .AND. SC6->(C6_FILIAL+C6_NOTA+C6_SERIE) == FPA->FPA_FILREM+FPA->FPA_NFREM+FPA->FPA_SERREM
							IF ALLTRIM(SC6->C6_ITEM) == ALLTRIM(FPA->FPA_ITEREM)
								_NENV := SC6->C6_QTDVEN
								EXIT
							ENDIF
							SC6->(DBSKIP())
						ENDDO
					ENDIF
					_NRET := 0
					_CQUERY := " SELECT SUM(FQ3_QTD) AS TOT "
					_CQUERY += " FROM " + RETSQLNAME("FQ3") + " SZ1" 
					_CQUERY += " WHERE "
					_CQUERY += "       SZ1.FQ3_FILIAL = '"+XFILIAL("FQ3")+"' AND "
					_CQUERY += "       SZ1.FQ3_AS = '"+FPA->FPA_AS+"' AND "
					_CQUERY += "       SZ1.FQ3_VIAGEM = '"+FPA->FPA_VIAGEM+"' AND "
					_CQUERY += "       SZ1.FQ3_NUM = '"+SF1->F1_IT_ROMA+"' AND "
					_CQUERY += "       SZ1.D_E_L_E_T_ = '' "
					IF SELECT("TRBFQ3") > 0
						TRBFQ3->(DBCLOSEAREA())
					ENDIF
					TCQUERY _CQUERY NEW ALIAS "TRBFQ3" 
					_NRET := TRBFQ3->TOT
					TRBFQ3->(DBCLOSEAREA())
					//IF _NRET >= _NENV
					//	IF FPA->(RECLOCK("FPA",.F.)) 
					//		FPA->FPA_NFRET	:= AZAG[_NW][03]
					//		FPA->FPA_SERRET	:= AZAG[_NW][04]
					//		FPA->FPA_DNFRET	:= AZAG[_NW][05]
					//		FPA->(MSUNLOCK())
					//	ENDIF
					//ENDIF				
				ELSE
					IF FPA->(RECLOCK("FPA",.F.)) 
						FPA->FPA_NFRET	:= AZAG[_NW][03]
						FPA->FPA_SERRET	:= AZAG[_NW][04]
						FPA->FPA_DNFRET	:= AZAG[_NW][05]
						FPA->(MSUNLOCK())
					ENDIF
				ENDIF
				
			ENDIF

			SB1->(DBSETORDER(1))
			SB1->(DBSEEK(XFILIAL("SB1")+FPA->FPA_PRODUT))
			IF ! ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CGRPAND) .OR. AZAG[_NW][08] > 0
				
				ST9->( DBGOTO( AZAG[_NW][08] ) )
				IF ST9->(RECNO()) == AZAG[_NW][08]
					IF .F. // ST6->( FIELDPOS("T6_XGRUPO") ) > 0				// --> EXCLUSIVO TECNOGERA - O PADRรO UTILIZA OS PARยMETROS MV_LOCX009, 02, 03, 04 E 05.
						IF ALLTRIM(POSICIONE("ST6",1,XFILIAL("ST6") + ST9->T9_CODFAMI,"T6_XGRUPO")) == "2"
							// --> DISPONIBILIZA O BEM
							IF SELECT("TRBTQY") > 0
								TRBTQY->(DBCLOSEAREA())
							ENDIF
							_CQUERY := " SELECT TQY_STATUS "                  + CRLF
							_CQUERY += " FROM " + RETSQLNAME("TQY") + " TQY " + CRLF
							_CQUERY += " WHERE  TQY.TQY_STTCTR = '00' "       + CRLF
							_CQUERY += "   AND  TQY.D_E_L_E_T_ = '' "         + CRLF
							TCQUERY _CQUERY NEW ALIAS "TRBTQY"
					
							IF TRBTQY->(!EOF())				 
								_CNEWSTS := TRBTQY->TQY_STATUS 			// --> DISPONIVEL
							ELSE
								_CNEWSTS := "01" 
							ENDIF   
						ELSE
							// --> BEM ENTRA EM MANUTENวรO
							IF SELECT("TRBTQY") > 0
								TRBTQY->(DBCLOSEAREA())
							ENDIF
							_CQUERY := " SELECT TQY_STATUS "                  + CRLF
							_CQUERY += " FROM " + RETSQLNAME("TQY") + " TQY " + CRLF
							_CQUERY += " WHERE  TQY.TQY_STTCTR = '70' "       + CRLF
							_CQUERY += "   AND  TQY.D_E_L_E_T_ = '' "         + CRLF
							TCQUERY _CQUERY NEW ALIAS "TRBTQY"
							IF TRBTQY->(!EOF())				 
								_CNEWSTS := TRBTQY->TQY_STATUS 			// --> DISPONIVEL
							ELSE
								_CNEWSTS := "50" 						// "07"
							ENDIF
						ENDIF
					ELSE
						IF ALLTRIM(ST9->T9_CODFAMI) $ ALLTRIM(_MV_LOC010)
							// --> DISPONIBILIZA O BEM
							IF SELECT("TRBTQY") > 0
								TRBTQY->(DBCLOSEAREA())
							ENDIF
							_CQUERY := " SELECT TQY_STATUS "                  + CRLF
							_CQUERY += " FROM " + RETSQLNAME("TQY") + " TQY " + CRLF
							_CQUERY += " WHERE  TQY.TQY_STTCTR = '00' "       + CRLF
							_CQUERY += "   AND  TQY.D_E_L_E_T_ = '' "         + CRLF
							TCQUERY _CQUERY NEW ALIAS "TRBTQY"
							IF TRBTQY->(!EOF())				 
								_CNEWSTS := TRBTQY->TQY_STATUS 			// --> DISPONIVEL
							ELSE
								_CNEWSTS := "01" 
							ENDIF
						ELSE
							// --> BEM ENTRA EM MANUTENวรO.
							IF SELECT("TRBTQY") > 0
								TRBTQY->(DBCLOSEAREA())
							ENDIF
							_CQUERY := " SELECT TQY_STATUS "                  + CRLF
							_CQUERY += " FROM " + RETSQLNAME("TQY") + " TQY " + CRLF
							_CQUERY += " WHERE  TQY.TQY_STTCTR = '70' "       + CRLF
							_CQUERY += "   AND  TQY.D_E_L_E_T_ = '' "         + CRLF
							TCQUERY _CQUERY NEW ALIAS "TRBTQY"
							IF TRBTQY->(!EOF())				 
								_CNEWSTS := TRBTQY->TQY_STATUS 			// --> DISPONIVEL
							ELSE
								_CNEWSTS := "60" // "50"						// "07" 
								TQY->(dbSetOrder(1))
								TQY->(dbGotop())
								While !TQY->(Eof())
									If TQY->TQY_STTCTR == "60"
										_CNEWSTS := TQY->TQY_STATUS
									EndIF
									TQY->(dbSkip())
								EndDo

							ENDIF
						ENDIF
					ENDIF
					//IF EXISTBLOCK("T9STSALT") 							// --> PONTO DE ENTRADA (GPO) ANTES DA ALTERAวรO DE STATUS DO BEM.
					//	EXECBLOCK("T9STSALT",.T.,.T.,{ST9->T9_STATUS,_CNEWSTS,FPA->FPA_PROJET,FPA->FPA_NFRET,FPA->FPA_SERRET})
					//ENDIF
					// em 22/10/21 removi pois isto jแ ้ tratado no ponto de entrada mt103fim
					//LOCXITU21(ST9->T9_STATUS,_CNEWSTS,FPA->FPA_PROJET,FPA->FPA_NFRET,FPA->FPA_SERRET)
					//IF ST9->(RECLOCK("ST9",.F.))
					//	ST9->T9_STATUS := _CNEWSTS
					//	ST9->(MSUNLOCK())
					//ENDIF
				ENDIF
			ENDIF
		END TRANSACTION
	ENDIF
NEXT _NW

RESTAREA(AAREA)
RESTAREA(AAREAST9)
RESTAREA(AAREAZAG)

RETURN NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ DADOREM   บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 09/08/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ CARREGA OS ITENS PARA GERAR O CABEC E ITENS DA DEVOLUวรO   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION DADOREM(_NI)

LOCAL _CQRYSD2 := ""

_CQRYSD2 := " SELECT C6_NOTA NOTA , C6_SERIE SERIE , C6_CLI CLI , C6_LOJA LOJA , C6_NUM NUM , C6_ITEM ITEM , * " + CRLF 
_CQRYSD2 += " FROM "+RETSQLNAME("SC6")+" SC6 "                                                  + CRLF 
_CQRYSD2 +=        " INNER JOIN "+RETSQLNAME("SD2")+" SD2 ON  SD2.D2_FILIAL  = SC6.C6_FILIAL  " + CRLF
_CQRYSD2 +=                                             " AND SD2.D2_DOC     = SC6.C6_NOTA    " + CRLF
_CQRYSD2 +=                                             " AND SD2.D2_SERIE   = SC6.C6_SERIE   " + CRLF
_CQRYSD2 +=                                             " AND SD2.D2_CLIENTE = SC6.C6_CLI     " + CRLF
_CQRYSD2 +=                                             " AND SD2.D2_LOJA    = SC6.C6_LOJA    " + CRLF
_CQRYSD2 +=                                             " AND SD2.D2_COD     = SC6.C6_PRODUTO " + CRLF
_CQRYSD2 +=                                             " AND SD2.D2_ITEMPV  = SC6.C6_ITEM    " + CRLF
_CQRYSD2 +=        " INNER JOIN "+RETSQLNAME("FPA")+" ZAG ON  ZAG.FPA_AS     = SC6.C6_XAS     " + CRLF 
_CQRYSD2 +=                                             " AND ZAG.FPA_NFREM  = SD2.D2_DOC     " + CRLF
_CQRYSD2 +=                                             " AND ZAG.FPA_SERREM = SD2.D2_SERIE   " + CRLF
_CQRYSD2 +=                                             " AND SD2.D_E_L_E_T_ = ''             " + CRLF
_CQRYSD2 += " WHERE  C6_XAS	= '"+ABRZP5[_NI,12]+"' "                                            + CRLF 
_CQRYSD2 += "   AND  SC6.D_E_L_E_T_ = '' "                                                      + CRLF 
IF SELECT("TMPSD2")>0
	TMPSD2->( DBCLOSEAREA() )
ENDIF
TCQUERY _CQRYSD2 NEW ALIAS "TMPSD2"
TMPSD2->( DBGOTOP() )

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ ATUZLG    บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 19/10/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ EXIBE E GRAVA OS DADOS PARA A RETIRADA DO BEM              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION ATUZLG(_CTIPOSE)

LOCAL NOPC
LOCAL ODTRETIRA
LOCAL OMTRETIRA
LOCAL ODTSOLRET
LOCAL OFRETERET , OAS , OBEM
LOCAL NI    := 0 
LOCAL NTEMP := 0
LOCAL CBEM , CAS
LOCAL LRET  := .F.

PRIVATE _DDTRETIRA := CTOD("  /  /  ") 
PRIVATE _DDTSOLRET := CTOD("  /  /  ") 
PRIVATE _CMTRETIRA := TAMSX3("DA4_COD")[1]
PRIVATE _CNOMEMOTO := TAMSX3("DA4_NOME")[1]
PRIVATE _NFRETERET := 0
PRIVATE _CAS_X     := "" 
PRIVATE ODLGZLG , ONOMEMOTO     

DEFAULT _CTIPOSE := "L"

FOR NI := 1 TO LEN(  ABRZP5 )
	IF ABRZP5[NI][1]
		NTEMP := NI
		EXIT
	ENDIF
NEXT NI 

IF NTEMP == 0
	MSGALERT(STR0063 , STR0006) //"PARA GRAVAR SELECIONE ALGUM ITEM"###"Aten็ใo!"
	RETURN NIL
ENDIF
                       
IF _CTIPOSE == "L"                    
	_DDTRETIRA := STOD(ABRZP5[NTEMP][13]) 	// DATA DE PREVISรO RETIRADA
	_DDTSOLRET := STOD(ABRZP5[NTEMP][11]) 	// DATA DE SOLICITAวรO RETIRADA
	_CMTRETIRA := ABRZP5[NTEMP][14] 		// CODIGO MOTORISTA
	_CNOMEMOTO := ABRZP5[NTEMP][15] 		// NOME MOTORISTA
	_NFRETERET := ABRZP5[NTEMP][16] 		// VALOR FRETE
	CAS        := ABRZP5[NTEMP][12] 		// AS
	CBEM       := ABRZP5[NTEMP][03] 		// BEM
ELSE
	_DDTSOLRET := ABRZP5[NTEMP][11] 		// DATA DE SOLICITAวรO RETIRADA 
	CAS        := ABRZP5[NTEMP][12] 		// AS 
ENDIF

_CAS_X := CAS 

DEFINE MSDIALOG ODLGZLG TITLE STR0031 FROM 000,000 TO 220,510 PIXEL //"DADOS RETIRADA"
                                   
IF _CTIPOSE == "L"
	@ 005,005 SAY 	STR0046                                                          PIXEL OF ODLGZLG //"BEM: "
	@ 015,005 MSGET OBEM      VAR CBEM WHEN .F.                          SIZE  50,10 PIXEL OF ODLGZLG

	@ 005,070 SAY 	STR0047                                                           PIXEL OF ODLGZLG //"AS: "
	@ 015,070 MSGET OAS	      VAR CAS  WHEN .F.                          SIZE  70,10 PIXEL OF ODLGZLG

	@ 035,005 SAY 	STR0048                                      PIXEL OF ODLGZLG //"SOLICITAวรO DE RETIRADA: "
	@ 045,005 MSGET ODTSOLRET VAR _DDTSOLRET VALID XVLDSOLRET(1)         SIZE  60,10 PIXEL OF ODLGZLG

	@ 035,080 SAY 	STR0049                                         PIXEL OF ODLGZLG //"PREVISรO DE RETIRADA: "
	@ 045,080 MSGET ODTRETIRA VAR _DDTRETIRA VALID XVLDSOLRET(2)         SIZE  60,10 PIXEL OF ODLGZLG

	@ 035,160 SAY 	STR0050                                                PIXEL OF ODLGZLG //"FRETE RETORNO: "
	@ 045,160 MSGET OFRETERET VAR _NFRETERET VALID LOCA04818(ABRZP5[NTEMP][16])    PICTURE "@E 999,999,999.99" SIZE  60,10 PIXEL OF ODLGZLG

	@ 065,005 SAY 	STR0051                                             PIXEL OF ODLGZLG //"MOTORISTA RETIRA: "
	@ 075,005 MSGET OMTRETIRA VAR _CMTRETIRA F3 "DA4" VALID VALMOTO()    SIZE  60,10 PIXEL OF ODLGZLG
	@ 075,068 MSGET ONOMEMOTO VAR _CNOMEMOTO WHEN .F.                    SIZE 175,10 PIXEL OF ODLGZLG
ELSE
	@ 005,005 SAY 	STR0047                                                           PIXEL OF ODLGZLG //"AS: "
	@ 015,005 MSGET OAS	      VAR CAS        WHEN .F.                    SIZE  70,10 PIXEL OF ODLGZLG

	@ 035,005 SAY 	STR0052                                              PIXEL OF ODLGZLG //"DT.FIM COBRANวA: "
	@ 045,005 MSGET ODTSOLRET VAR _DDTSOLRET VALID XVLDSOLRET(1)         SIZE  60,10 PIXEL OF ODLGZLG
ENDIF 

@ 090,138 BUTTON STR0053 SIZE 050,012 OF ODLGZLG PIXEL ; 
                             ACTION( IIF( MSGYESNO(OEMTOANSI(STR0054),STR0006) , NOPC := "1" , NIL ), ODLGZLG:END() ) //"ATUALIZAR"###"CONFIRMA A ATUALIZAวรO DOS DADOS PARA RETIRADA?"###"Aten็ใo!"
@ 090,193 BUTTON STR0055   SIZE 050,012 OF ODLGZLG PIXEL ; 
                             ACTION( ODLGZLG:END() ) //"CANCELA"

ACTIVATE MSDIALOG ODLGZLG CENTERED

IF NOPC == "1"
	PROCESSA( {|| LRET := GRVDADOS(_CTIPOSE) }, STR0056, STR0057, .T.) //"AGUARDE..."###"PROCESSANDO..."
	IF LRET
		MSGINFO(STR0058 , STR0006) //"OS DADOS DE RETIRADA FORAM ATUALIZADOS COM SUCESSO!"###"Aten็ใo!"
	ELSE
		MSGINFO(STR0059 , STR0006) //"NรO FOI POSSอVEL GRAVAR OS DADOS DE RETIRADA!"###"Aten็ใo!"
	ENDIF
ENDIF

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ VALMOTO   บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 19/10/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ VALIDA E GATILHA O NOME DO MOTORISTA                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION VALMOTO()

LOCAL LRET
LOCAL LVLDMOT := SUPERGETMV("MV_LOCX221",,.T.)

IF LVLDMOT
	DA4->( DBSETORDER(1) )
	IF DA4->( DBSEEK( XFILIAL("DA4") + _CMTRETIRA ) )
		_CNOMEMOTO := DA4->DA4_NOME
		LRET       := .T.
	ELSE
		MSGALERT(STR0064 , STR0006) //"MOTORISTA NรO ENCONTRADO!"###"Aten็ใo!"
		_CNOMEMOTO := ""
		LRET       := .F.
	ENDIF
ELSE
	_CNOMEMOTO := "" 
	LRET       := .T. 
ENDIF

ONOMEMOTO:REFRESH()

RETURN LRET



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ GRVDADOS  บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 19/10/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ ATUALIZA OS DADOS DA RETIRADA DO BEM                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION GRVDADOS(_CTIPOSE)

LOCAL AAREAST9 := ST9->(GETAREA())
LOCAL AAREAZAG := FPA->(GETAREA())
LOCAL LRET	   := .F.
LOCAL CAVISO   := ""
LOCAL _NI      := 0 
LOCAL _cProjX  := ""

DEFAULT _CTIPOSE := "L"

BEGIN TRANSACTION
FOR _NI := 1 TO LEN( ABRZP5 )
	IF ABRZP5[_NI][1]
		FPA->( DBGOTO( ABRZP5[_NI,9] ) )
		_cProjX := FPA->FPA_PROJET
		IF FPA->( RECNO() ) == ABRZP5[_NI,9]
/*	// --> P.E. DESCONTINUADO !!! 
			IF EXISTBLOCK("LOCC001_")							// --> PONTO DE ENTRADA (GPO) COM TRATATIVA GRAVAวAO LOG: ZA0, ZA1 E ZAG 
				U_LOCC001_("GRV_PROJETO", {FPA->FPA_FILIAL, FPA->FPA_PROJET} ) 
			ENDIF
*/	// --> P.E. DESCONTINUADO !!! 
			IF _CTIPOSE == "L"
				IF RECLOCK("FPA",.F.)
					IIF( ! EMPTY(_DDTRETIRA) , FPA->FPA_DTPRRT := _DDTRETIRA   , FPA->FPA_DTPRRT := CTOD("") )
					IIF( ! EMPTY(_DDTSOLRET) , FPA->FPA_DTSCRT := _DDTSOLRET   , FPA->FPA_DTSCRT := CTOD("") )
					IIF( ! EMPTY(_CMTRETIRA) , FPA->FPA_MOTRET := _CMTRETIRA   , FPA->FPA_MOTRET := ""       )
					IIF( ! EMPTY(_NFRETERET) , FPA->FPA_GUIDES := _NFRETERET   , FPA->FPA_GUIDES := 0        )
					FPA->( MSUNLOCK() )
					LRET := .T.
				ENDIF 
			ELSE
				RECLOCK("FPA",.F.)
					FPA->FPA_DTSCRT := _DDTSOLRET 
				FPA->(MSUNLOCK()) 
				LRET := .T.
			ENDIF
		ENDIF 

		IF _CTIPOSE == "L"
			SB1->(DBSETORDER(1))
			SB1->(DBSEEK(XFILIAL("SB1")+FPA->FPA_PRODUT))
			IF ! ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CGRPAND) .OR. !EMPTY(FPA->FPA_GRUA)
				
				ST9->(DBSETORDER(1))
				IF ST9->(DBSEEK(XFILIAL("ST9")+FPA->FPA_GRUA))
					TQY->(dbSetOrder(1))
					IF TQY->(DBSEEK(XFILIAL("TQY")+ST9->T9_STATUS))
						IF ! EMPTY(_DDTSOLRET)
							CAUX := "50"
						ELSE
							CAUX := "40"
						ENDIF
						IF ALLTRIM(TQY->TQY_STTCTR) $ "40#50"
							IF SELECT("TRBTQY") > 0
								TRBTQY->(DBCLOSEAREA())
							ENDIF
							_CQUERY := " SELECT TQY_STATUS "
							_CQUERY += " FROM " + RETSQLNAME("TQY") + " TQY "
							_CQUERY += " WHERE  TQY_STTCTR = '"+CAUX+"' AND TQY.D_E_L_E_T_ = ''" + CRLF
							TCQUERY _CQUERY NEW ALIAS "TRBTQY"
							IF TRBTQY->(!EOF())
								//IF EXISTBLOCK("T9STSALT") 			// --> PONTO DE ENTRADA (GPO) ANTES DA ALTERAวรO DE STATUS DO BEM.
								//	EXECBLOCK("T9STSALT",.T.,.T.,{ST9->T9_STATUS,TRBTQY->TQY_STATUS,FPA->FPA_PROJET,"",""})
								//ENDIF
								// em 22/10/21 removi pois isto jแ ้ tratado no ponto de entrada mt103fim
								//LOCXITU21(ST9->T9_STATUS,TRBTQY->TQY_STATUS,FPA->FPA_PROJET,""     ,"")
								//IF RECLOCK("ST9",.F.)
								//	ST9->T9_STATUS := TRBTQY->TQY_STATUS 
								//	ST9->(MSUNLOCK()) 
								//ENDIF
							ENDIF
							TRBTQY->(DBCLOSEAREA())
						ELSE
							CAVISO += "O STATUS ATUAL '"+ALLTRIM(TQY->TQY_DESTAT)+"' DO BEM NรO ESTม CORRETO PARA PROSSEGUIR COM O RETORNO." +CRLF + "O STATUS DEVERIA ESTAR COMO '05 - ENTREGUE' "
						ENDIF 
					ENDIF 
				ENDIF 
			ENDIF
		ENDIF 
	ENDIF 
NEXT _NI 

// Rotina para extornar, ou gerar novamente os tํtulos provis๓rios.
// Se o campo da data de retirada estiver em branco manter, ou recuperar os provis๓rios
// Se o campo da data de retirada estiver preenchido deletar os provis๓rios
// Levar em considera็ใo o parโmetro MV_LOCX067
// Nใo obriga a exist๊ncia da nota de retorno
IF !GETMV("MV_LOCX067",,.T.) .and. !empty(_cProjX)
	If !empty(_DDTRETIRA) .and. !empty(_DDTSOLRET)
		// Deletar os provis๓rios
		// Frank em 26/20/2021
		If getmv("MV_LOCX278",,.F.) // se trabalha com titulos provis๓rios
			FQB->(dbSetOrder(1))
			//FQB->(dbSeek(xFilial("FQB")+FPA->FPA_PROJET+FPA->FPA_AS))
			FQB->(dbSeek(xFilial("FQB")+_cProjX))
			//If !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == FPA->FPA_PROJET+FPA->FPA_AS
			If !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET) == _cProjX
				SE1->(dbSetOrder(1))
				SE1->(dbSeek(xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR)) 
				While !SE1->(Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR
					SE1->(RecLock("SE1",.F.))
					SE1->(dbDelete())
					SE1->(MsUnlock())
					SE1->(dbSkip())
				EndDo
				//While !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == FPA->FPA_PROJET+FPA->FPA_AS
				While !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET) == _cProjX
					FQB->(RecLock("FQB",.F.))
					FQB->(dbDelete())
					FQB->(MsUnlock())
					FQB->(dbSkip())
				EndDo
			EndIf
		EndIF
	Else
		// Retornar com os provis๓rios no caso destes nใo existir
		If getmv("MV_LOCX278",,.F.) // se trabalha com titulos provis๓rios
			FQB->(dbSetOrder(1))
			If !FQB->(dbSeek(xFilial("FQB")+_cProjX))
				FP0->(dbSetOrder(1))
				FP0->(dbSeek(xFilial("FP0")+_cProjX))
				_nRegX := FPA->(Recno())
				loca01318() // criacao do titulo provisorio 
				FPA->(dbGoto(_nRegX))
			EndIF
		EndIf
	EndIF
EndIf
END TRANSACTION

RESTAREA(AAREAST9) 
RESTAREA(AAREAZAG) 

RETURN LRET



// ======================================================================= \\
STATIC FUNCTION XVLDSOLRET(NXOP) 
// ======================================================================= \\

LOCAL AAREAX   := GETAREA() 
LOCAL AAREAXAG := FPA->(GETAREA())  
LOCAL LRETX    := .T. 

DBSELECTAREA("FPA") 
FPA->( DBSETORDER(3) ) 				// --> INDICE 3: FPA_FILIAL + FPA_AS + FPA_VIAGEM 
FPA->( DBSEEK(XFILIAL("FPA") + _CAS_X ) ) 
IF FPA->(!EOF()) .AND. FPA->FPA_AS = _CAS_X
	IF NXOP = 1 					// _DDTSOLRET 
		IF _DDTSOLRET < FPA->FPA_ULTFAT  .AND.  !EMPTY(_DDTSOLRET) 
			LRETX := .F. 
		ENDIF 
	ENDIF 
	IF NXOP = 2 					// _DDTRETIRA 
		IF _DDTRETIRA < FPA->FPA_ULTFAT  .AND.  !EMPTY(_DDTRETIRA) 
			LRETX := .F. 
		ENDIF 
	ENDIF 
	IF !LRETX 
		MSGALERT(STR0065+DTOC(FPA->FPA_ULTFAT)+STR0066 , STR0006) //"AVISO: DATA INVALIDA! ESTม INFERIOR ภ DATA ["###"] DO ULTIMO FATURAMENTO NA AS !"###"Aten็ใo!"
	ENDIF 
ENDIF 

RESTAREA(AAREAXAG) 
RESTAREA(AAREAX) 

RETURN LRETX 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ VALIDZAG  บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 08/08/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ VALIDA SE O PRODUTO JA TEVE O RETORNO                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO - DESCONTINUADA - NรO EXISTE CHAMADA!       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
STATIC FUNCTION VALIDZAG(CAS , CPROJET , CPRODUT) 

LOCAL _CQRYSC6 := ""
LOCAL LRETC6 := .F.

_CQRYSC6 := " SELECT  SD1.* FROM "+RETSQLNAME("SC6")+" SC6  " +CRLF
_CQRYSC6 += "                                               " +CRLF
_CQRYSC6 += " INNER JOIN "+RETSQLNAME("FPA")+" ZAG          " +CRLF
_CQRYSC6 += " ON	SC6.C6_XAS		=	ZAG.FPA_AS          " +CRLF
_CQRYSC6 += " AND	SC6.C6_PRODUTO	=	ZAG.FPA_PRODUT      " +CRLF
_CQRYSC6 += "                                               " +CRLF
_CQRYSC6 += " LEFT JOIN "+RETSQLNAME("SD2")+" SD2           " +CRLF
_CQRYSC6 += " ON	SD2.D2_DOC		=SC6.C6_NOTA            " +CRLF
_CQRYSC6 += " AND	SD2.D2_SERIE	=SC6.C6_SERIE           " +CRLF
_CQRYSC6 += " AND	SD2.D2_ITEMPV	=SC6.C6_ITEM            " +CRLF
_CQRYSC6 += " AND	SD2.D2_COD		=SC6.C6_PRODUTO         " +CRLF
_CQRYSC6 += " AND	SD2.D_E_L_E_T_	= ''                    " +CRLF
_CQRYSC6 += "                                               " +CRLF
_CQRYSC6 += " LEFT JOIN "+RETSQLNAME("SD1")+" SD1           " +CRLF
_CQRYSC6 += " ON	SD1.D1_NFORI	= SD2.D2_DOC            " +CRLF
_CQRYSC6 += " AND	SD1.D1_SERIORI	= SD2.D2_SERIE          " +CRLF
_CQRYSC6 += " AND	SD1.D1_ITEMORI	= SD2.D2_ITEM           " +CRLF
_CQRYSC6 += " AND	SD1.D1_COD		= SD2.D2_COD            " +CRLF
_CQRYSC6 += " AND	SD1.D_E_L_E_T_= ''                      " +CRLF
_CQRYSC6 += "                                               " +CRLF
_CQRYSC6 += " WHERE SC6.C6_XAS = '"+CAS+"'                  " +CRLF
_CQRYSC6 += " AND ZAG.FPA_PROJET = '"+CPROJET+"'            " +CRLF
_CQRYSC6 += " AND SC6.C6_PRODUTO = '"+CPRODUT+"'            " +CRLF
_CQRYSC6 += "                                               " +CRLF
_CQRYSC6 += " AND SC6.C6_NOTA<>''                           " +CRLF
_CQRYSC6 += " AND SC6.D_E_L_E_T_= ''                        " +CRLF
_CQRYSC6 += " AND ZAG.D_E_L_E_T_= ''                        " +CRLF
_CQRYSC6 += " AND SD1.D_E_L_E_T_= ''                        " +CRLF

IF SELECT("TMPSC6")>0
	TMPSC6->(DBCLOSEAREA()) 
ENDIF

TCQUERY _CQRYSC6 NEW ALIAS "TMPSC6"
TMPSC6->( DBGOTOP() )

IF TMPSC6->(! EOF() )
	LRETC6 := .T.
ENDIF

RETURN LRETC6
*/
// Valida็ใo do valor do frete
// Frank Z Fuga
Function LOCA04818(_nAtual)
Local _lRet := .T.
If _nAtual == 0
	_lRet := .T.
Else
	If _nAtual <> &(readvar())
		_lRet := .F.
		MsgAlert(STR0067,STR0006) //"O valor nใo pode ser alterado."###"Aten็ใo!"
	EndIF
EndIF
Return _lRet


// Validacao se existe nota de remessa gerada
// Frank Zwarg Fuga em 21/10/21
Static Function LOCA11VAL()
Local _lRet := .T.
if Empty(ABRZP5[OLISTP5:NAT][07])
	MsgAlert(STR0068,STR0006) //"Falta o preenchimento da nota de remessa."###"Aten็ใo!"
	_lRet := .F.
EndIF
Return _lRet
/*
Consultoria   : IT UP Business 
Desenvolvedor : IT UP Business 
Descricao     : Rotina que realiza a entrada de documento do cliente conforme romaneio de retorno.
                ษ o mesmo nome da fun็ใo - "Retornar" - padrใo da TOTVS
                --> Programa de Consulta de Historicos da Revisao. 
                --> Contida no fonte: MATA103.prw 
*/                                    	
// ======================================================================= \\
Function LOCA01101(cAlias , nReg , nOpcX , cNumRom , lFormPropr )	
// ======================================================================= \\

Local _cProjI     := Space(TamSx3("FQ2_NUM")[1])
Local aPergs      := {}
Local aRet        := {}
Local nInicial    := 0  
Local _cFam       := AllTrim(GetMV("MV_LOCX010")) 
Local _nEnv
Local _nRet
Local _cItem
Local lLOCX304	:= SuperGetMV("MV_LOCX304",.F.,.F.) // Utiliza o cliente destino informado na aba conjunto transportador serแ o utilizado como cliente da nota fiscal de remessa,
Local _MV_LOC025 := SUPERGETMV("MV_LOCX025",,"004")
LOCAL lForca := .F.
LOCAL lLOCA11B := EXISTBLOCK("LOCA11B")
LOCAL lLOCA11C := EXISTBLOCK("LOCA11C")
LOCAL lLOCA11D := EXISTBLOCK("LOCA11D")
LOCAL lLOCA11E := EXISTBLOCK("LOCA11E")
LOCAL lLOCA11F := EXISTBLOCK("LOCA11F")

Default lFormPropr	:= .F. //Jos้ Eulแlio - 03/06/2022 - SIGALOC94-346 - #27421 - NF de Retorno Apresentar o formulแrio quando for Formulแrio Pr๓prio = Sim.

Private aItensped := {}
Private aItensAux := {}
Private aItens    := {}
Private cTesDv

Private cTipoNf   := "E" // Frank 25/11/2020 para uso na rotina do mata100b
Private cTEs             // Frank 25/11/2020 para uso na rotina do mata100b

aAdd( aPergs , {01,STR0069 , _cProjI , GetSx3Cache("Z0_NUM","X3_PICTURE"),".T.","Z0R"  ,".T.", 50,.F.}) //"Numero do Romaneio: "
If !Empty(cNumRom)
	aAdd(aRet,cNumRom)
EndIf
If !Empty(aRet[1]) .or. ParamBox(aPergs ,STR0070,aRet, /*4*/, /*5*/, /*6*/, /*7*/, /*8*/, /*9*/, /*10*/, .F.) //"Parametros "
	If ValType(aRet[01]) == "C"
		If .T.			// U_ITGERNF(aRet[1],"Retorno") 				// Validacao de Anexo 
			// --> Inicia o Posicionamento das Tabelas
			FQ2->(dbSetOrder(1))      
			For nInicial := 1 To Len(aRet)
				If FQ2->(dbSeek(xFilial("FQ2")+aRet[nInicial])) 		// Realiza a Busca do Romaneio.
					FQ3->(dbSetOrder(1))     

					lFORCA := .F.
					IF lLOCA11F
						lFORCA := EXECBLOCK("LOCA11F",.T.,.T.,{})
					ENDIF

					If FQ3->(dbSeek(xFilial("FQ3")+aRet[nInicial])) .and. !lForca 	// Realiza a Busca do Romaneio.  
						While FQ3->(!Eof()) .And. (FQ3->FQ3_FILIAL == xFilial("FQ3") .And. FQ3->FQ3_NUM == aRet[nInicial])

							lForca := .F.
							IF lLOCA11B
								lFORCA := EXECBLOCK("LOCA11B",.T.,.T.,{})
							ENDIF

							If FQ3->FQ3_FAMBEM $ _cFam .or. lForca
								FQ3->(dbSkip())
							EndIf 
							FPA->(dbSetOrder(3))   
							If FPA->(dbSeek(xFilial("FPA")+FQ3->FQ3_AS+FQ3->FQ3_VIAGEM))//Realiza a Busca do Romaneio.
								If Empty(FPA->FPA_NFREM) .Or. Empty(FPA->FPA_SERREM)
									Aviso(STR0072,STR0071) // "Equipamento sem nota de remessa emitido, verifique no romaneio os itens vinculados."###"Aten็ใo!"
									Return
								EndIf
	                            // --> Realiza a busca da nota fiscal de remessa
								IF(SELECT("QRY") > 0,QRY->(DBCLOSEAREA()),lForca:=.F.)

								cQry:= " SELECT D2_CLIENTE , D2_IDENTB6, D2_LOJA , D2_PRCVEN , D2_TOTAL , D2_TES , D2_VALFRE , D2_SEGURO , D2_DESPESA , D2_IPI , "
								cQry+=        " D2_LOCAL , D2_COD , D2_QUANT , D2_UM , D2_ICMSRET , R_E_C_N_O_ "
								cQry+= " FROM "+RetSqlName("SD2")+" SD2 " 
								cQry+= " WHERE  SD2.D_E_L_E_T_ = '' "
								cQry+=   " AND  D2_FILIAL = '"+FPA->FPA_FILREM +"' "
								cQry+=   " AND  D2_DOC    = '"+FPA->FPA_NFREM  +"' "
								cQry+=   " AND  D2_SERIE  = '"+FPA->FPA_SERREM +"' "
								cQry+=   " AND  D2_COD    = '"+FPA->FPA_PRODUTO+"' "
								cQry+=   " AND  D2_ITEM   = '"+FPA->FPA_ITEREM +"' "
								TcQuery cQry New Alias "QRY"
								
								While QRY->(!Eof())
									cTesDv:= Posicione("SF4",1,xFilial("SF4")+QRY->D2_TES,"F4_TESDV")
									lForca := .F.
									IF lLOCA11C
										lFORCA := EXECBLOCK("LOCA11C",.T.,.T.,{})
									ENDIF
								    If Empty(cTesDv) .or. lFORCA
								    	MsgAlert(STR0073+QRY->D2_TES+STR0074 ,STR0071) //"TES de Saํda "###" sem Tipo de Devolu็ใo Cadastrada, Cadastrar TES de Devolu็ใo."###"Aten็ใo!"
								    	Return 
								    EndIf
								    cNFORI		:= FPA->FPA_NFREM
								    cSERIORI	:= FPA->FPA_SERREM
								    cITEMORI	:= AllTrim(FPA->FPA_ITEREM)

									lForca := .F.
									IF lLOCA11D
										lFORCA := EXECBLOCK("LOCA11D",.T.,.T.,{})
									ENDIF

									If lLOCX304 .and. !lFORCA
										//posiciono no romaneio
										FQ7->(DbSetOrder(2)) //FQ7_FILIAL+FQ7_PROJET+FQ7_OBRA+FQ7_SEQGUI+FQ7_ITEM
										If FQ7->(DbSeek(xFilial("FQ7") + FPA->(FPA_PROJET + FPA_OBRA + FPA_SEQGRU )))
											//rodo at้ localizar a viagem origem
											While !FQ7->(EoF()) .And. FQ7->(FQ7_FILIAL+FQ7_PROJET+FQ7_OBRA+FQ7_SEQGUI) == xFilial("FQ7") + FPA->(FPA_PROJET + FPA_OBRA + FPA_SEQGRU )
												If FQ7->FQ7_TPROMA == "1" .And. Empty(FQ7->FQ7_NFRET) .And. FPA->FPA_VIAGEM == FQ7->FQ7_VIAORI
													cCliente	:= FQ7->FQ7_LCCORI
													cLoja		:= FQ7->FQ7_LCLORI
													Exit
												EndIf
												FQ7->(DbSkip())
											EndDo
										EndIf
									Else
										cCliente	:= QRY->D2_CLIENTE
										cLoja		:= QRY->D2_LOJA
									EndIf

									_nRet := QRY->D2_QUANT 
									// Controle do retorno parcial - Frank 19/10/20
									// Verificar a quantidade que foi enviado x a quantidade retornada.
									// S๓ armazenar a nota se for a ultima entrada, ou seja, se as quantidades forem iguais.
									// Frank 19/10/20
									FP0->(dbSetOrder(1))
									FP0->(dbSeek(xfilial("FP0")+FPA->FPA_PROJET))

									IF lLOCA11E
										_nZuc := EXECBLOCK("LOCA11E",.T.,.T.,{})
									ENDIF
									If type("_nZuc")== "N" // Variavel criada na rotina LOC05102.prw - frank 02/11/20
										If _nZuc > 0 
											_lTemZUC := .T.
										Else
											_lTemZUC := .F.
										EndIf
									Else
										_lTemZUC := .F.
									EndIf

									If FP0->FP0_TIPOSE == "L" .and. _lTemZUC
										_nEnv := 0
										If !empty(FPA->FPA_NFREM)
											SC6->(dbSetOrder(4))
											SC6->(dbSeek(FPA->FPA_FILREM+FPA->FPA_NFREM+FPA->FPA_SERREM))
											While !SC6->(Eof()) .and. SC6->(C6_FILIAL+C6_NOTA+C6_SERIE) == FPA->FPA_FILREM+FPA->FPA_NFREM+FPA->FPA_SERREM
												If alltrim(SC6->C6_ITEM) == alltrim(FPA->FPA_ITEREM)
													_nEnv := SC6->C6_QTDVEN
													Exit
												EndIF
												SC6->(dbSkip())
											EndDo
										EndIf

										IF(SELECT("TRBFQ3") > 0,TRBFQ3->(DBCLOSEAREA()),lForca:=.F.)

										_nRet := 0
										_cQuery := " SELECT FQ3_QTD, FQ3_ITEM "
										_cQuery += " FROM " + RetSqlName("FQ3") + " FQ3" 
										_cQuery += " WHERE "
										_cQuery += "       FQ3.FQ3_FILIAL = '"+xFilial("FQ3")+"' and "
										_cQuery += "       FQ3.FQ3_NUM = '"+FQ3->FQ3_NUM+"' and "
										_cQuery += "       FQ3.FQ3_AS = '"+FPA->FPA_AS+"' and "
										//_cQuery += "       FQ3.FQ3_NFRET = '' and "
										_cQuery += "       FQ3.D_E_L_E_T_ = '' "
										If(Select("TRBFQ3") > 0,TRBFQ3->(dbCloseArea()),lForca:=.F.)
										TcQuery _cQuery New Alias "TRBFQ3" 

										_cItem := ""
										While !TRBFQ3->(Eof())
											If TRBFQ3->FQ3_ITEM > _cItem
												_nRet := TRBFQ3->FQ3_QTD
												_cItem := TRBFQ3->FQ3_ITEM
											EndIf
											TRBFQ3->(dbSkip())
										EndDo
										
										TRBFQ3->(dbCloseArea())
									EndIf	

									// Frank 25/11/2020
									// antes vinha da nota de remessa
									cTesDv := _MV_LOC025 //SuperGetMV("MV_LOCX025",,"004")
									cTEs   := cTesDv

									// --> Realiza a Montagem de todos os itens
									aItens := {}
				  					aAdd( aItens, { "D1_COD"     , QRY->D2_COD     , Nil } )
									aAdd( aItens, { "D1_QUANT"   , _nRet           , Nil } )										
									aAdd( aItens, { "D1_VUNIT"   , QRY->D2_PRCVEN  , Nil } )
								 	aAdd( aItens, { "D1_TOTAL"   , _nRet * QRY->D2_PRCVEN   , Nil } ) 	 //	aAdd( aItens, { "D1_VALDESC" , SD2->D2_TOTAL , Nil } ) 
								 //	aAdd( aItens, { "D1_VALFRE"	 , QRY->D2_VALFRE  , Nil } )  
								 //	aAdd( aItens, { "D1_SEGURO"	 , QRY->D2_SEGURO  , Nil } )  
								 //	aAdd( aItens, { "D1_DESPESA" , QRY->D2_DESPESA , Nil } )
								 //	aAdd( aItens, { "D1_IPI"     , QRY->D2_IPI     , Nil } )	
							     //	aAdd( aItens, { "D1_LOCAL"   , QRY->D2_LOCAL   , Nil } )
									aAdd( aItens, { "D1_TES" 	 , cTesDv		   , Nil } )	 //	aAdd( aLinha, { "D1_CF"	     , cCfop         , Nil } ) 
								   	aAdd( aItens, { "D1_NFORI"   , cNFORI          , Nil } )
									aAdd( aItens, { "D1_SERIORI" , cSERIORI        , Nil } )
									aAdd( aItens, { "D1_ITEMORI" , cITEMORI        , Nil } )
									aAdd( aItens, { "D1_IDENTB6" , QRY->D2_IDENTB6 , Nil } )
									//aAdd( aItens, { "D1_CF"      , '112'           , Nil } )
								 //	aAdd( aItens, { "D1_ICMSRET" , QRY->D2_ICMSRET , Nil } )	
								 //	aAdd( aItens, { "D1RECNO"    , QRY->(RECNO())  , Nil } )
								 	// [inicio] Jos้ Eulแlio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
									If FQ3->(ColumnPos("FQ3_OBSCCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSCON")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFIS")) > 0
										aAdd( aItens, { "D1_OBSCTIT" , FQ3->FQ3_OBSCCM , Nil } )
										aAdd( aItens, { "D1_OBSCONT" , FQ3->FQ3_OBSCON , Nil } )
										aAdd( aItens, { "D1_OBSFTIT" , FQ3->FQ3_OBSFCM , Nil } )
										aAdd( aItens, { "D1_OBSFISC" , FQ3->FQ3_OBSFIS , Nil } )
									EndIf
									// [final] Jos้ Eulแlio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
									nPos := aScan(aItensAux,{|x| x[1] == cNFORI .And. x[2] == cSERIORI .And. x[3] == cITEMORI })
									If nPos == 0
									   aAdd(aItensAux,{cNFORI,cSERIORI,cITEMORI})
									   aAdd(aItensped,aItens)
									EndIf 
									QRY->(dbSkip())
								Enddo
								QRY->(DbCloseArea())
							EndIf 
							FQ3->(dbSkip()) 
						EndDo 
						If Len(aItensped) > 0
							LOCA01102(cAlias,nReg,nOpcx,,cCliente,cLoja,,aRet[nInicial],lFormPropr)
						EndIf
					Else
						Aviso(STR0075+aRet[nInicial]+STR0076,STR0071) //"Romaneio "###" sem Itens Vinculados"###"Aten็ใo!"
						Return 
					EndIf 
				EndIf 
			Next 
		EndIf
	EndIf
EndIf 

Return



// ======================================================================= \\
Function LOCA01102(cAlias,nReg,nOpcx,lCliente,cCliente,cLoja,cDocSF2,cNumRom,lFormPropr)
// ======================================================================= \\
// --> Rotina Auxiliar que realizar a inclusao do Documento de Entrada

Local aArea      := GetArea()
Local aAreaSF2   := SF2->(GetArea())
Local aCab       := {}
Local cTipoNF    := ""
Local cFormProp  := "N"
Local lPoder3    := .T.
Local lFlagDev	 := SF2->(FieldPos("F2_FLAGDEV")) > 0  .And. GetNewPar("MV_FLAGDEV",.F.)
Local lRestDev	 := .T.
Local aLinha	 := {} // Frank Z Fuga em 08/09/2020 para funcionamento da fun็ใo M103FILDV
Local _lMostra	 := .F.
Local lLOCA11G   := EXISTBLOCK("LOCA11G") 
Local lLOCA11H   := EXISTBLOCK("LOCA11H") 

Private _lErroNf := .F. // variavel que sofre alteracao no fonte MT103FIM

Default lCliente := .F.
Default cCliente := SF2->F2_CLIENTE
Default cLoja    := SF2->F2_LOJA
Default cDocSF2  := ""                                

If Type("cTipo") == "U"
	Private cTipo := "" 
EndIf

cRomaX := cNumRom // uso do cRomaX no ponto de entrada MT103FIM, a variavel foi criada como private no loc05102.prw Frank 29/10/20

If !SF2->(Eof())
    //cDoc := GetSxeNum("SF1","F1_DOC")
	//ConfirmSx8()
	// [inicio] Jos้ Eulแlio - 03/06/2022 - SIGALOC94-346 - #27421 - NF de Retorno Apresentar o formulแrio quando for Formulแrio Pr๓prio = Sim.

	lForca := .F.
	IF lLOCA11G
		lFORCA := EXECBLOCK("LOCA11G",.T.,.T.,{})
	ENDIF

	If lFormPropr .and. !lForca
		cDoc 		:= Space(TamSx3("F1_DOC")[1])
		cFormProp	:= "S"
	Else
		cDoc := strzero(0,TamSx3("F1_DOC")[1])
		SF1->(dbSetOrder(1))
		While .T.
			If SF1->(dbSeek(xFilial("SF1")+cDoc))
				cDoc := soma1(cDoc)
			Else
				Exit
			EndIf
		EndDo
	EndIf
	// [final] Jos้ Eulแlio - 03/06/2022 - SIGALOC94-346 - #27421 - NF de Retorno Apresentar o formulแrio quando for Formulแrio Pr๓prio = Sim.
	
	// Frank 12/11/20
	// a tes esta posicionada pela montagem dos itens
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+cTesDv))
	_cTipo := "D"
	If SF4->F4_PODER3 == "D"
        _cTipo := "B"
	EndIF
	//_cTipo := "B"

	// --> Montagem do Cabecalho da Nota fiscal de Devolucao/Retorno.
	aAdd( aCab , {"F1_DOC"      , cDoc/*CriaVar("F1_DOC",.F.)*/ , Nil} ) 	// Numero da NF      : Obrigatorio
	aAdd( aCab , {"F1_SERIE"    , CriaVar("F1_SERIE",.F.)       , Nil} ) 	// Serie da NF       : Obrigatorio
	aAdd( aCab , {"F1_TIPO"     , _cTipo                        , Nil} ) 	// Tipo da NF        : Obrigatorio
	aAdd( aCab , {"F1_FORNECE"  , cCliente                      , Nil} ) 	// Codigo Fornecedor : Obrigatorio
	aAdd( aCab , {"F1_LOJA"     , cLoja                         , Nil} ) 	// Loja Fornecedor   : Obrigatorio
	aAdd( aCab , {"F1_EMISSAO"  , dDataBase                     , Nil} ) 	// Emissao da NF     : Obrigatorio
	// [inicio] Jos้ Eulแlio - 03/06/2022 - SIGALOC94-346 - #27421 - NF de Retorno Apresentar o formulแrio quando for Formulแrio Pr๓prio = Sim.
	//aAdd( aCab , {"F1_FORMUL"   , "N"                           , Nil} ) 	// Formulario
	aAdd( aCab , {"F1_FORMUL"   , cFormProp                     , Nil} ) 	// Formulario
	// [final] Jos้ Eulแlio - 03/06/2022 - SIGALOC94-346 - #27421 - NF de Retorno Apresentar o formulแrio quando for Formulแrio Pr๓prio = Sim.
	aAdd( aCab , {"F1_ESPECIE"  , Iif(Empty(CriaVar("F1_ESPECIE",.T.)),;
								 PadR("NF",Len(SF1->F1_ESPECIE)),CriaVar("F1_ESPECIE",.T.)), Nil } )  // Especie
	aAdd( aCab , { "F1_FRETE"   , 0                             , Nil} ) 
	aAdd( aCab , { "F1_SEGURO"  , 0                             , Nil} ) 
	aAdd( aCab , { "F1_DESPESA" , 0                             , Nil} ) 
	aAdd( aCab , { "F1_IT_ROMA" , cNumRom                       , Nil} ) 
	//aAdd( aCab , { "F1_COD"     , "001"                         , Nil} ) 
	
	lForca := .F.
	IF lLOCA11H
		lFORCA := EXECBLOCK("LOCA11H",.T.,.T.,{})
	ENDIF

	If cFilAnt <> SF2->F2_FILIAL .or. lForca
		cFilAux := cFilAnt  
		nRecSM0 := SM0->(RECNO())
		cFilAnt := cFilAnt 							// SF2->F2_FILIAL 
		Mata103( aCab, aItensped , 3 , .T.)
		cFilAnt := cFilAux 
		SM0->(dbGoTo(nRecSM0))
	Else   
		Mata103( aCab, aItensped , 3 , .T.)
		_lMostra := .T.
	EndIf

	If _lErroNF
		MsgAlert(STR0077,STR0071) //"A nota de entrada nใo foi gerada."###"Aten็ใo!"
	EndIF

	If !Empty(FPA->FPA_NFREM) .and. !_lErroNf
		RecLock("SF1",.F.)
		SF1->F1_IT_ROMA := cNumRom
		SF1->(MsUnLock())

		// Gravar o n๚mero da nota de retorno no campo FQ2_NFSER
		// Frank em 06/07/21
		FQ2->(RecLock("FQ2",.F.))
		FQ2->FQ2_NFSER := SF1->F1_DOC +"/"+ SF1->F1_SERIE
		FQ2->(MsUnlock())
		
		If _lMostra
			MsgAlert(STR0078+alltrim(SF1->F1_DOC)+"-"+alltrim(SF1->F1_SERIE),STR0071) //"Nota de entrada gerada: "###"Aten็ใo!"
		EndIf
		cDoc := SF1->F1_DOC
	EndIf

	// --> Verifica se nao ha mais saldo para devolucao.
	If lFlagDev
		//lRestDev := M103FilDv(@aLinha,@aItensped,cDocSF2,cCliente,cLoja,lCliente,@cTipoNF,@lPoder3,.F.)	
		// Frank Z Fuga em 08/09/2020 a fun็ใo M103FILDV agora ้ static.
		lRestDev := LOCXITU22("","",@aLinha,@aItensped,cDocSF2,cCliente,cLoja,lCliente,@cTipoNF,@lPoder3,.F.)	
		If !lRestDev
			RecLock("SF2",.F.)
			SF2->F2_FLAGDEV := "1"
			MsUnLock()
		EndIf 
	EndIf 

	MsUnLockAll()

Endif
	
// --> Restaura a entrada da rotina.
RestArea(aAreaSF2)
RestArea(aArea)

Return(.T.)
