/*/{PROTHEUS.DOC} LOCR012.PRW 
ITUP BUSINESS - TOTVS RENTAL
IMPRESSAO AUTORIZACAO DE SERVICO DE TRANSPORTE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "RWMAKE.CH"                                            
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"                                             

FUNCTION LOCR012(_CNRAS)
LOCAL XALIAS 	 := GETAREA()
LOCAL AITENS	 := {}
LOCAL AAREAZA0   := FP0->(GETAREA())
LOCAL AAREADTQ   := FQ5->(GETAREA())
LOCAL OFONTX     := TFONT():NEW("ARIAL",12,16,,.T.,,,,.T.,.F.)

PRIVATE CCABEC   := ""
PRIVATE CPERG    := "LOCP016" 					// CRIAR PERGUNTA
PRIVATE CLJCLIE  :="" 
PRIVATE CINCR    :=""
PRIVATE COBSG    := ""
PRIVATE OLBXITENS

DEFAULT _CNRAS	 := ""

IF EMPTY(_CNRAS)
	FQ5->(DBSETORDER(8)) 						// --> INDICE 08: FQ5_FILIAL + FQ5_SOT + FQ5_OBRA + FQ5_AS     NICKNAME: ITUPDTQ008 
	FQ5->(DBSEEK(XFILIAL("FQ5")+FP0->FP0_PROJET)) 
	AADD(AITENS , {"TODAS"}) 
	WHILE FQ5->(!EOF()) .AND. FQ5->FQ5_SOT = FP0->FP0_PROJET
		IF FQ5->FQ5_STATUS != "9"
			AADD(AITENS, {FQ5->FQ5_AS})
		ENDIF
		FQ5->(DBSKIP())
	ENDDO 

	LCANCEL := .F.
	ODLG3   := NIL               
	CRET    := ""     
	DEFINE MSDIALOG ODLG3 TITLE "GPO - LOCI024.PRW" FROM 000,000 TO 450,735     OF ODLG3 PIXEL
		@ 010,005 SAY     "AS'S DO PROJETO: "+FP0->FP0_PROJET      FONT OFONTX  OF ODLG3 PIXEL 
		@ 025,005 SAY     "SELECIONE NA AS E APERTE <ENTER> OU <DUPLO CLIQUE> " OF ODLG3 PIXEL 
		@ 040,005 LISTBOX OLBXITENS FIELDS HEADER "SELECIONE A AS" SIZE 360,170 OF ODLG3 PIXEL ON DBLCLICK ((CRET := TELAOBS(),ODLG3:END())) 
		OLBXITENS:SETARRAY(AITENS)
		OLBXITENS:BLINE := {|| {AITENS[OLBXITENS:NAT][01]}}
		OLBXITENS:REFRESH()
		ODLG3:REFRESH()
	ACTIVATE MSDIALOG ODLG3 CENTERED
ELSE
	CRET := _CNRAS
ENDIF

IF EMPTY(CRET)
	RESTAREA(AAREAZA0)
	RESTAREA(AAREADTQ)
	RESTAREA(XALIAS)
	RETURN(NIL)
ENDIF         

// --> PREENCHE COM OS DADOS DA PROPOSTA
CCODCLI  := FP0->FP0_CLI
CLJCLIE  := FP0->FP0_LOJA
CINCR    := FP0->FP0_CLIINS
CGC      := FP0->FP0_CLICGC
CENDERE  := FP0->FP0_CLIEND
CBAIRRO  := FP0->FP0_CLIBAI
CMUNICI  := FP0->FP0_CLIMUN
CESTADO  := FP0->FP0_CLIEST
CCEP     := FP0->FP0_CLICEP
CCONTATO := ALLTRIM(FP0->FP0_CLICON)
CTEL     := "( "+FP0->FP0_CLIDDD+" )" + " "+ FP0->FP0_CLITEL
CENDCOB  := FP0->FP0_CLIEND
CBAICOB  := FP0->FP0_CLIBAI
CMUNCOB  := FP0->FP0_CLIMUN
CESTCOB  := FP0->FP0_CLIEST
CCEPCOB  := FP0->FP0_CLICEP

IF !EMPTY(FP0->FP0_CLI) .AND. !EMPTY(FP0->FP0_LOJA) 
	AAREASA1 := SA1->( GETAREA() )
	DBSELECTAREA("SA1")
	DBSETORDER(1)
	IF MSSEEK(XFILIAL("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA )
		// DADOS CADASTRAIS
		CCODCLI := SA1->A1_COD
		CLJCLIE := SA1->A1_LOJA
		CINCR   := FP0->FP0_CLIINS
		CGC     := FP0->FP0_CLICGC
		CENDERE := FP0->FP0_CLIEND
		CBAIRRO := FP0->FP0_CLIBAI
		CMUNICI := FP0->FP0_CLIMUN
		CESTADO := FP0->FP0_CLIEST
		CCEP    := FP0->FP0_CLICEP
			
		IF !EMPTY(SA1->A1_ENDCOB)
			CENDCOB := SA1->A1_ENDCOB
			CBAICOB := SA1->A1_BAIRROC
			CMUNCOB := SA1->A1_MUNC
			CESTCOB := SA1->A1_ESTC
			CCEPCOB := SA1->A1_CEPC
		ELSE
			CENDCOB := SA1->A1_END
			CBAICOB := SA1->A1_BAIRRO
			CMUNCOB := SA1->A1_MUN
			CESTCOB := SA1->A1_EST
			CCEPCOB := SA1->A1_CEP
		ENDIF
		CTEL     := "( "+SA1->A1_DDD+" )" + " "+ SA1->A1_TEL
             
		CCONTATO := SA1->A1_CONTATO
		IF EMPTY(CCONTATO)
			CCONTATO := ALLTRIM(FP0->FP0_CLICON)       
		ENDIF      
	ENDIF
	RESTAREA(AAREASA1)
ENDIF

DBSELECTAREA("FQ5")
DBSETORDER(8)
DBGOTOP()
DBSEEK(XFILIAL("FQ5")+FP0->FP0_PROJET)

// --> SELECAO DA IMPRESSORA. 
OOBJPRINT:= TMSPRINTER():NEW(CCABEC)
OOBJPRINT:SETSIZE( 210, 297 )
OOBJPRINT:SETUP()

LJMSGRUN("POR FAVOR AGUARDE, AUTORIZAÇÃO DE SERVIÇO...",,{|| IMP_TRAN() })

// --> MOSTRA RELATORIO PARA IMPRIMIR.
OOBJPRINT:SETSIZE( 210, 297 )
OOBJPRINT:PREVIEW()

RESTAREA(AAREAZA0)
RESTAREA(AAREADTQ)
RESTAREA(XALIAS)

RETURN(NIL)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ IMP_TRAN  º AUTOR ³ IT UP BUSINESS     º DATA ³ 02/04/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ IMPRESSAO DA AUTORIZACAO DE TRANSPORTE.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION IMP_TRAN() 

PRIVATE OFONTE01	:= NIL
PRIVATE OFONTE02	:= NIL
PRIVATE OFONTE03	:= NIL
PRIVATE OFONTE04	:= NIL
PRIVATE OFONTE05	:= NIL
PRIVATE OFONTE06	:= NIL
PRIVATE OFONTE07	:= NIL
PRIVATE OFONTE08    := NIL

// --> INICIALIZA OBJETOS DA CLASSE TMSPRINTER.
OFONT1     := TFONT():NEW("ARIAL"     ,11,11,,.F.,,,,,.F.)   // NORMAL
OFONT2     := TFONT():NEW("ARIAL"     ,18,18,,.T.,,,,,.F.)   // NEGRITO
OFONT3     := TFONT():NEW("ARIAL"     ,11,11,,.T.,,,,,.T.)   // NEGRITO / SUBLINHADO
OFONT4     := TFONT():NEW("ARIAL"     ,10,10,,.F.,,,,,.F.)   // NORMAL
OFONT5     := TFONT():NEW("ARIAL"     ,10,10,,.T.,,,,,.F.)   // NEGRITO
OFONT6     := TFONT():NEW("ARIAL"     ,10,10,,.T.,,,,,.T.)   // NEGRITO / SUBLINHADO
OFONT7     := TFONT():NEW("VENDANA"   ,07,07,,.F.,,,,,.F.)   // NORMAL
OFONT8     := TFONT():NEW("VENDANA"   ,07,07,,.F.,,,,,.T.)   // SUBLINHADO
OFONT9     := TFONT():NEW("ARIAL"     ,08,08,,.F.,,,,,.F.)   // NORMAL
OFONT10    := TFONT():NEW("ARIAL"     ,08,08,,.T.,,,,,.F.)   // NEGRITO
OFONT11    := TFONT():NEW("ARIAL"     ,07,07,,.F.,,,,,.F.)   // NORMAL
OFONT12    := TFONT():NEW("ARIAL"     ,07,07,,.T.,,,,,.F.)   // NORMAL

// --> CRIA AS TABELAS TEMPORARIA PARA GERACAO DO RELATORIO. 
AAREAZA0:=FP0->(GETAREA())
AAREAZA1:=FP1->(GETAREA())
AAREASE4:=SE4->(GETAREA())                                       
AAREAZA6:=ZA6->(GETAREA())
AAREAZA7:=ZA7->(GETAREA())
AAREAZA9:=FQ8->(GETAREA())
AAREAZAM:=FPD->(GETAREA())

IMPREL()

RESTAREA(AAREAZA0)
RESTAREA(AAREAZA1)
RESTAREA(AAREASE4)
RESTAREA(AAREAZA6)
RESTAREA(AAREAZA7)
RESTAREA(AAREAZA9)
RESTAREA(AAREAZAM)

RETURN(NIL)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ IMPREL    º AUTOR ³ IT UP BUSINESS     º DATA ³ 02/04/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ IMPRESSAO DA AUTORIZACAO DE TRANSPORTE                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION IMPREL()

LOCAL NLIN := 400   
LOCAL CTIPOSEG := ""
LOCAL CTIPOICM := ""
LOCAL CTIPOCAR := "" 
LOCAL CTIPOCARD:= "" 
LOCAL NVALTUR  := 0
LOCAL NVALINV  := 0
LOCAL NVALICM  := 0 //SEM CAMPO
LOCAL ATRANSP  := {}
LOCAL NLINFIM  := 0
LOCAL NCREDEN := 0
LOCAL NTUV    := 0
LOCAL NVALTAP := 0
LOCAL NPRF    := 0
LOCAL NPRE    := 0
LOCAL NPED    := 0
LOCAL NEXTRA  := 0
LOCAL NALIQ   := 0
LOCAL NSEG    := 0
LOCAL NTRAV   := 0
LOCAL NIPT    := 0
LOCAL NVALAUX := 0
LOCAL NICM    := 0
LOCAL NACOMP  := 0
LOCAL NOUT    := 0
LOCAL NFRETE  := 0
LOCAL NCET    := 0
LOCAL NCONCESS:= 0
LOCAL NSEMAFOR:= 0
LOCAL NVALTVA := 0
LOCAL NVALTEL := 0
LOCAL NVALDIASV := 0
LOCAL NVALDIASC := 0
LOCAL NKMV 		:= 0
LOCAL NKMC 		:= 0
LOCAL NX        := 0 
LOCAL I         := 0 

WHILE FQ5->(!EOF()) .AND. FQ5->FQ5_SOT = FP0->FP0_PROJET

	NCREDEN  := 0
	NTUV     := 0
	NPRF     := 0
	NPRE     := 0
	NPED     := 0
	NEXTRA   := 0
	NALIQ    := 0
	NSEG     := 0
	NTRAV    := 0
	NIPT     := 0
	NVALAUX  := 0
	NICM     := 0
	NACOMP   := 0
	NOUT     := 0
	NFRETE   := 0
	NCET     := 0
	NCONCESS := 0
	NSEMAFOR := 0
	NVALTVA  := 0
	NVALTEL  := 0
	NVALTUR  := 0
	NVALINV  := 0

	NVALDIASV := 0
	NVALDIASC := 0
	NKMV 	  := 0
	NKMC 	  := 0

	NLINFIM := 0
	NLIN    := 400
 
    IF CRET <> "TODAS" .AND. ALLTRIM(CRET)<>ALLTRIM(FQ5->FQ5_AS)
       FQ5->(DBSKIP())
       LOOP
    ENDIF
    
    DBSELECTAREA("FQ5")
    RECLOCK("FQ5",.F.)
    FQ5->FQ5_OBSCOM := COBSG
    MSUNLOCK()
        
    _PRAZEXEC  :=(FQ5->FQ5_DATFIM-FQ5->FQ5_DATINI)      
    
    OOBJPRINT:STARTPAGE()

    DBSELECTAREA("ZA6")                                                            
    DBSETORDER(1)
    MSSEEK(XFILIAL("ZA6") +  FQ5->FQ5_SOT + FQ5->FQ5_OBRA  )

    DBSELECTAREA("ZA7")
    DBSETORDER(1)
    MSSEEK(XFILIAL("ZA7") +  FQ5->FQ5_SOT + FQ5->FQ5_OBRA +  ZA6->ZA6_SEQTRA + FQ5->FQ5_SEQCAR )

    DBSELECTAREA("SE4")                                                                
    DBSETORDER(1)                                                             
    MSSEEK(XFILIAL("SE4") + ZA6->ZA6_CONPAG )

    DBSELECTAREA("FQ8")
    DBSETORDER(2)
    IF MSSEEK(XFILIAL("FQ8") +  FQ5->FQ5_SOT + FQ5->FQ5_OBRA + ZA6->ZA6_SEQTRA+ ZA7->ZA7_SEQCAR )
		NCREDEN  := FQ8->FQ8_VALESC
		NTUV     := FQ8->FQ8_VALTUV
		NPRF     := FQ8->FQ8_VALPRF
		NPRE     := FQ8->FQ8_VALPRE
		NPED     := FQ8->FQ8_VALPED
		NEXTRA   := FQ8->FQ8_VALADI
		NALIQ    := ZA7->ZA7_VALADV
		NSEG     := ROUND(ZA7->ZA7_VRCARG*ZA7->ZA7_VALADV/100,2)
		NTRAV    := FQ8->FQ8_VALTRA
		NIPT     := FQ8->FQ8_VALIPT
		NICM     := ZA7->ZA7_VALICM
		NACOMP   := FQ8->FQ8_VALACO
		NOUT     := FQ8->FQ8_VALOUT
		NFRETE   := FQ8->FQ8_VRFRET
		NCONCESS := FQ8->FQ8_VALCON
		NSEMAFOR := FQ8->FQ8_VALSEM
		NVALTVA  := FQ8->FQ8_VALTVA
		NVALTEL  := FQ8->FQ8_VALTEL
		NVALTUR  := FQ8->FQ8_VALTUR
		NCET     := FQ8->FQ8_VALCET
		NVALAUX  := FQ8->FQ8_VALAUX
		NVALINV  := FQ8->FQ8_VALINV  //BLOQUEIO: BLOQUEIO + ALEMOA
		NVALTAP	 := FQ8->FQ8_VALTAP
	ENDIF	

	NVALICM  := ROUND( ((NFRETE+NSEG)*NICM/100) / ((100-NICM)/100) ,2)
	ATRANSP  := {}
	NPESOBRU := ZA7->ZA7_PESO

    DBSELECTAREA("FP8")
    FP8->(DBSETORDER(1))  //FP8_FILIAL+FP8_PROJET+FP8_OBRA+FP8_SEQTRA+FP8_SEQCAR+FP8_SEQCON
    MSSEEK(XFILIAL("FP8")+FQ5->FQ5_SOT+FQ5->FQ5_OBRA)
    WHILE FP8->(!EOF() .AND. FP8_FILIAL+FP8_PROJET+FP8_OBRA==XFILIAL("FP8")+FQ5->FQ5_SOT+FQ5->FQ5_OBRA)
		IF FP8->(!FP8_SEQCAR==FQ5->FQ5_SEQCAR)
			FP8->(DBSKIP())
			LOOP
		ENDIF
		AADD(ATRANSP,ALLTRIM(FP8->FP8_DESTRA)+" - "+FP8->FP8_TRANSP)
		NPESOBRU  += FP8->FP8_PESO
		NVALDIASV += FP8->FP8_DIASV
	 	NVALDIASC += FP8->FP8_DIASC
		FP8->(DBSKIP())
	ENDDO 

	IF EMPTY(ATRANSP)
		AADD(ATRANSP,SPACE(LEN(FP8->FP8_DESTRA+" - "+FP8->FP8_TRANSP)))
	ENDIF
	
	DBSELECTAREA("FPD")
	DBSETORDER(1)
	DBSEEK(XFILIAL("FPD")+FQ5->FQ5_SOT+FQ5->FQ5_OBRA)
	WHILE FPD->(!EOF() .AND. FPD_FILIAL+FPD_PROJET+FPD_OBRA==XFILIAL("FPD")+FQ5->FQ5_SOT+FQ5->FQ5_OBRA)
		IF FP7->FP7_VAZIO == 'V'
			NKMV += FP7->FP7_DISTAN
	 	ELSEIF FP7->FP7_VAZIO == 'C'
	 		NKMC += FP7->FP7_DISTAN      
	 	ENDIF
		FPD->(DBSKIP())
	ENDDO 

	CTIPOSEG := IIF(ZA7->ZA7_INCADV == "I","INCLUSO",IIF(ZA7->ZA7_INCADV == "N","NÃO INCLUSO","CLIENTE"))
 //	CTIPOICM := IIF(ZA7->ZA7_INCICM == "I","INCLUSO",IIF(ZA7->ZA7_INCICM == "N","NÃO INCLUSO",IIF(ZA7->ZA7_INCICM == "S","SUBS.TRIBUTARIA","CLIENTE")))
 //	CTIPOCAR := IIF(ZA7->ZA7_TIPCAR == "A","ANO(S)" ,IIF(ZA7->ZA7_TIPCAR == "M","MESES",IIF(ZA7->ZA7_TIPCAR == "S","SEMANAS",IIF(ZA7->ZA7_TIPCAR == "D","DIAS",""))))   
    CSEGURO  := IIF(ZA7->ZA7_FORMAS == "1","AD. VALOREM",IIF(ZA7->ZA7_FORMAS == "2","RCTR-C",""))

	DO CASE
    CASE ZA7->ZA7_INCICM == "I" ; CTIPOICM:="INCLUSO"
    CASE ZA7->ZA7_INCICM == "N" ; CTIPOICM:="NÃO INCLUSO"
    CASE ZA7->ZA7_INCICM == "S" ; CTIPOICM:="SUBS.TRIBUTÁRIA"
    CASE ZA7->ZA7_INCICM == "C" ; CTIPOICM:="CLIENTE"
    CASE ZA7->ZA7_INCICM == "X" ; CTIPOICM:="ISENTO"
    OTHERWISE                   ; CTIPOICM:="ISENTO"
    ENDCASE

	DO CASE
	CASE ZA7->ZA7_TIPCAR == "H" ; CTIPOCAR:="HORAS  "
	CASE ZA7->ZA7_TIPCAR == "D" ; CTIPOCAR:="DIAS   "
	CASE ZA7->ZA7_TIPCAR == "S" ; CTIPOCAR:="SEMANAS"
	CASE ZA7->ZA7_TIPCAR == "M" ; CTIPOCAR:="MESES  "
	CASE ZA7->ZA7_TIPCAR == "A" ; CTIPOCAR:="ANOS   "
	OTHERWISE                   ; CTIPOCAR:="       "
    ENDCASE

	DO CASE
	CASE ZA7->ZA7_TPCARD == "H" ; CTIPOCARD:="HORAS  "
	CASE ZA7->ZA7_TPCARD == "D" ; CTIPOCARD:="DIAS   "
	CASE ZA7->ZA7_TPCARD == "S" ; CTIPOCARD:="SEMANAS"
	CASE ZA7->ZA7_TPCARD == "M" ; CTIPOCARD:="MESES  "
	CASE ZA7->ZA7_TPCARD == "A" ; CTIPOCARD:="ANOS   "
	OTHERWISE                   ; CTIPOCARD:="       "
    ENDCASE

	CEMAILCLI:=FP0->FP0_CLIEMA
	CEMAILCON:=FP0->FP0_CLIEMA
    
	IF CEMPANT == "07"
		OOBJPRINT:SAYBITMAP( 0055, 020,"LGJSM.BMP"   , 790, 0380 ) //553 X 224
	ELSE
		OOBJPRINT:SAYBITMAP( 0055, 020,"LOGO.BMP"   , 790, 0380 ) //553 X 224
	ENDIF

	DO CASE
	CASE FP0->FP0_TIPOSE == "T"; _CDESC := "TRANSPORTE"
	CASE FP0->FP0_TIPOSE == "I"; _CDESC := "TRANSPORTE INT."
	CASE FP0->FP0_TIPOSE == "O"; _CDESC := "TRANSPORTE EMP"
	OTHERWISE                  ; _CDESC := FP0->FP0_TIPOSE
	ENDCASE
	
    OOBJPRINT:SAY( 0050 , 0850 , "AUTORIZAÇÃO DE SERVIÇO: " + _CDESC             , OFONT2   , 100 )    
    OOBJPRINT:SAY( 0150 , 0850 ,  "NO. AST :" +TRANSFORM(FQ5->FQ5_AS,"@R XX-XXXXX-XXX-XX-XX")                       , OFONT2   , 100 )    
    
    OOBJPRINT:SAY( 0250 , 0850 ,  "NO. PROJETO: "+ALLTRIM(FQ5->FQ5_SOT)+;
    							  " - REVISÃO: " +ALLTRIM(FP0->FP0_REVISAO)      , OFONT2   , 100 )                                                                                                                                                          
    
    OOBJPRINT:SAY( 0350 , 0850 ,  "NO. OBRA: "   +ALLTRIM(FQ5->FQ5_OBRA)+;
      	                          " - REVISÃO DA AS: "+STRZERO(ZA7->ZA7_REVNAS,2), OFONT2   , 100 )

    OOBJPRINT:BOX( 0030 + NLIN , 0030, 150 + NLIN, 2370)
    OOBJPRINT:SAY( 0050 + NLIN , 0040 ,  "EMITIDA EM: "+DTOC(DDATABASE)+" AS "+TIME(), OFONT10   , 100 )        
  	OOBJPRINT:SAY( 0050 + NLIN , 0600 ,  "NÚMERO SOT: "+ALLTRIM(FP0->FP0_PROJET) + ;
  	                                     " - REVISÃO: "+FP0->FP0_REVISA                 , OFONT10   , 100 )            
	OOBJPRINT:SAY( 0050 + NLIN , 1400 ,  "NÚMERO OBRA: "+FQ5->FQ5_OBRA                  , OFONT10   , 100 )              
    OOBJPRINT:SAY( 0050 + NLIN , 1800 ,  "NÚMERO VIAGEM:"+FQ5->FQ5_VIAGEM               , OFONT10   , 100 )                  
    
    OOBJPRINT:SAY( 0100 + NLIN , 0040 ,  "GESTOR:"                                   , OFONT10   , 100 )            
    OOBJPRINT:SAY( 0100 + NLIN , 0240 ,  FP0->FP0_VENDED+" - "+POSICIONE("SA3",1,XFILIAL("SA3") + FP0->FP0_VENDED , "A3_NOME" )  , OFONT10   , 100 )        
                                                     
    OOBJPRINT:BOX( 0150 + NLIN , 0030, 0210 + NLIN, 2370)
    OOBJPRINT:SAY( 0160 + NLIN , 0950 ,  "INFORMAÇÕES DO CLIENTE"                        , OFONT5   , 100 )        
    OOBJPRINT:BOX( 0210 + NLIN , 0030, 0610 + NLIN, 2370)
    OOBJPRINT:SAY( 0230 + NLIN , 0040 ,  "CLIENTE: "+CCODCLI+"/"+CLJCLIE+" - "+ALLTRIM(FP0->FP0_CLINOM), OFONT10   , 100 ) 
    OOBJPRINT:SAY( 0230 + NLIN , 1200 ,  "I.E: "                                         , OFONT10   , 100 )
    OOBJPRINT:SAY( 0230 + NLIN , 1300 ,  TRANSFORM(CINCR,"@R 999.999.999-999")           , OFONT10   , 100 )
    OOBJPRINT:SAY( 0260 + NLIN , 0040 ,  "C.N.P.J:"                                      , OFONT10   , 100 )            
    OOBJPRINT:SAY( 0260 + NLIN , 0170 ,  TRANSFORM(CGC,"@R 99.999.999/9999-99")          , OFONT10   , 100 )    
    
    OOBJPRINT:SAY( 0290 + NLIN , 0040 ,  "END. COMERCIAL:"                                  , OFONT10   ,100)                
    OOBJPRINT:SAY( 0330 + NLIN , 0040 ,  CENDERE                                            , OFONT10   ,100)
    OOBJPRINT:SAY( 0380 + NLIN , 0040 ,  ALLTRIM(CBAIRRO) +" - "+ALLTRIM(CMUNICI)+" - "+ALLTRIM(CESTADO)+" - "+ALLTRIM(CCEP) , OFONT10   ,100)
                    
    OOBJPRINT:SAY( 0290 + NLIN , 1200 ,  "END. COBRANÇA:"                                   , OFONT10   ,100)                    
    OOBJPRINT:SAY( 0330 + NLIN , 1200 ,  CENDCOB                                            , OFONT10   ,100)
    OOBJPRINT:SAY( 0380 + NLIN , 1200 ,  ALLTRIM(CBAICOB) +" - "+ALLTRIM(CMUNCOB)+" - "+ALLTRIM(CESTCOB)+" - "+ALLTRIM(CCEPCOB) , OFONT10   ,100)
        
    OOBJPRINT:SAY( 0420 + NLIN , 0040 ,  "TELEFONE: "                                       , OFONT10   , 100 )                        
    OOBJPRINT:SAY( 0470 + NLIN , 0040 ,  "CONTATO : "                                       , OFONT10   , 100 )                            

    OOBJPRINT:SAY( 0420 + NLIN , 0170 ,  CTEL                                               , OFONT10   , 100 )                        
    OOBJPRINT:SAY( 0470 + NLIN , 0170 ,  CCONTATO                                           , OFONT10   , 100 )                            

    OOBJPRINT:SAY( 0420 + NLIN , 1200 ,  "TELEFONE: "                                       , OFONT10   , 100 )                        
    OOBJPRINT:SAY( 0470 + NLIN , 1200 ,  "CONTATO : "                                       , OFONT10   , 100 )                            

    OOBJPRINT:SAY( 0420 + NLIN , 1330 ,  CTEL                                               , OFONT10   , 100 )                        
    OOBJPRINT:SAY( 0470 + NLIN , 1330 ,  CCONTATO                                           , OFONT10   , 100 )                            

    OOBJPRINT:SAY( 0520 + NLIN , 0040 ,  "E-MAIL  : "                                       , OFONT10   , 100 )
    OOBJPRINT:SAY( 0520 + NLIN , 1200 ,  "E-MAIL  : "                                       , OFONT10   , 100 )
    OOBJPRINT:SAY( 0520 + NLIN , 0170 ,  CEMAILCLI                                          , OFONT10   , 100 )
    OOBJPRINT:SAY( 0520 + NLIN , 1330 ,  CEMAILCON                                          , OFONT10   , 100 )
    
    OOBJPRINT:BOX( 0610 + NLIN , 0030, 0670 + NLIN, 2370)
    OOBJPRINT:SAY( 0630 + NLIN , 0700 ,  "INFORMAÇÕES DE CARREGAMENTO E DESCARREGAMENTO"   , OFONT5   , 100 )        
    
    OOBJPRINT:BOX( 0670 + NLIN , 0030, 1000 + NLIN, 2370)
    OOBJPRINT:SAY( 0690 + NLIN , 0040 ,  "CARREGAMENTO"                                   , OFONT10   , 100 )                        

    OOBJPRINT:SAY( 0750 + NLIN , 0040 ,  "LOCAL: "                                         , OFONT10   , 100 )                                
    OOBJPRINT:SAY( 0750 + NLIN , 0140 ,  ALLTRIM(ZA6->ZA6_NOMORI)                          , OFONT10   , 100 )                                
        
    OOBJPRINT:SAY( 0750 + NLIN , 1200 ,  "PRAZO EXEC: "                                    , OFONT10   , 100 )                            
    OOBJPRINT:SAY( 0750 + NLIN , 1330 ,  STR(_PRAZEXEC)                                    , OFONT10   , 100 )                            
    
    OOBJPRINT:SAY( 0750 + NLIN , 1800 ,  "DATA: "                                          , OFONT10   , 100 )                                
    OOBJPRINT:SAY( 0750 + NLIN , 1900 ,  DTOC(ZA7->ZA7_DTCAR)                              , OFONT10   , 100 )                                
        
    OOBJPRINT:SAY( 0750 + NLIN , 2050 ,  "HORA: "                                          , OFONT10   , 100 )                                
    OOBJPRINT:SAY( 0750 + NLIN , 2150 ,  TRANSFORM(ZA7->ZA7_HRCAR,"@R 99:99")              , OFONT10   , 100 )                                
        
    OOBJPRINT:SAY( 0800 + NLIN , 0040 ,  "ENDEREÇO: "                                      , OFONT10   , 100 )                                    
    OOBJPRINT:SAY( 0800 + NLIN , 0190 ,  ZA6->ZA6_ENDORI                                   , OFONT10   , 100 )                                    
  
    OOBJPRINT:SAY( 0850 + NLIN , 0040 ,  "BAIRRO: "                                        , OFONT10   , 100 )                                
    OOBJPRINT:SAY( 0850 + NLIN , 0150 ,  ZA6->ZA6_BAIORI                                   , OFONT10   , 100 )                                
        
    OOBJPRINT:SAY( 0850 + NLIN , 0700 ,  "CIDADE: "                                        , OFONT10   , 100 )                                    
    OOBJPRINT:SAY( 0850 + NLIN , 0830 ,  ZA6->ZA6_MUNORI                                   , OFONT10   , 100 )                                    
    
    OOBJPRINT:SAY( 0850 + NLIN , 1200 ,  "ESTADO: "                                        , OFONT10   , 100 )                                        
    OOBJPRINT:SAY( 0850 + NLIN , 1330 ,  ZA6->ZA6_ESTORI                                   , OFONT10   , 100 )                                        
        
    OOBJPRINT:SAY( 0900 + NLIN , 0040 ,  "TELEFONE: "                                      , OFONT10   , 100 )                                            
    OOBJPRINT:SAY( 0900 + NLIN , 0180 ,  ZA6->ZA6_TELORI                                   , OFONT10   , 100 )                                            
        
    OOBJPRINT:SAY( 0900 + NLIN , 0700 ,  "CONTATO: "                                       , OFONT10   , 100 )                                            
    OOBJPRINT:SAY( 0900 + NLIN , 0830 ,  ZA6->ZA6_CONORI                                   , OFONT10   , 100 )                                            
    
    OOBJPRINT:SAY( 0900 + NLIN , 1400 ,  "CARENCIA: "                                      , OFONT10   , 100 )                                            
    OOBJPRINT:SAY( 0900 + NLIN , 1550 ,  ALLTRIM(STR(ZA7->ZA7_CARENC))+" "+CTIPOCAR                 , OFONT10   , 100 ) 
                
    OOBJPRINT:BOX( 1000 + NLIN , 0030, 1330 + NLIN, 2370)
    OOBJPRINT:SAY( 1020 + NLIN , 0040 ,  "DESCARREGAMENTO"                                , OFONT10   , 100 )                        
    
    OOBJPRINT:SAY( 1080 + NLIN , 0040 ,  "LOCAL:"                                         , OFONT10   , 100 )                            
    OOBJPRINT:SAY( 1080 + NLIN , 0140 ,  ALLTRIM(ZA6->ZA6_NOMDES)                          , OFONT10   , 100 )                                
        
    OOBJPRINT:SAY( 1080 + NLIN , 1200 ,  "PRAZO EXECUÇÃO:"                                , OFONT10   , 100 )                            
    OOBJPRINT:SAY( 1080 + NLIN , 1350 ,  STR(_PRAZEXEC)                                    , OFONT10   , 100 )                            
    
    OOBJPRINT:SAY( 1080 + NLIN , 1800 ,  "DATA:"                                          , OFONT10   , 100 )                                
    OOBJPRINT:SAY( 1080 + NLIN , 1900 ,  DTOC(ZA7->ZA7_DTDES)                             , OFONT10   , 100 )                                
        
    OOBJPRINT:SAY( 1080 + NLIN , 2050 ,  "HORA:"                                          , OFONT10   , 100 )                                
   OOBJPRINT:SAY( 1080 + NLIN , 2150 ,  TRANSFORM(ZA7->ZA7_HRDES,"@R 99:99")             , OFONT10   , 100 )                                
        
    OOBJPRINT:SAY( 1130 + NLIN , 0040 ,  "ENDEREÇO:"                                      , OFONT10   , 100 )                                    
    OOBJPRINT:SAY( 1130 + NLIN , 0190 ,  ZA6->ZA6_ENDDES                                  , OFONT10   , 100 )                                    
        
    OOBJPRINT:SAY( 1180 + NLIN , 0040 ,  "BAIRRO:"                                        , OFONT10   , 100 )                                
    OOBJPRINT:SAY( 1180 + NLIN , 0150 ,  ZA6->ZA6_BAIDES                                  , OFONT10   , 100 )                                
        
    OOBJPRINT:SAY( 1180 + NLIN , 0700 ,  "CIDADE:"                                        , OFONT10   , 100 )                                    
    OOBJPRINT:SAY( 1180 + NLIN , 0830 ,  ZA6->ZA6_MUNDES                                  , OFONT10   , 100 )                                    
        
    OOBJPRINT:SAY( 1180 + NLIN , 1200 ,  "ESTADO:"                                        , OFONT10   , 100 )                                        
    OOBJPRINT:SAY( 1180 + NLIN , 1330 ,  ZA6->ZA6_ESTDES                                  , OFONT10   , 100 )                                        
        
    OOBJPRINT:SAY( 1230 + NLIN , 0040 ,  "TELEFONE:"                                      , OFONT10   , 100 )                                            
    OOBJPRINT:SAY( 1230 + NLIN , 0180 ,  ZA6->ZA6_TELDES                                  , OFONT10   , 100 )                                            
        
    OOBJPRINT:SAY( 1230 + NLIN , 0700 ,  "CONTATO:"                                       , OFONT10   , 100 )                                            
    OOBJPRINT:SAY( 1230 + NLIN , 0830 ,  ZA6->ZA6_CONDES                                  , OFONT10   , 100 )                                            
        
    OOBJPRINT:SAY( 1230 + NLIN , 1400 ,  "CARENCIA:"                                      , OFONT10   , 100 )                                            
    OOBJPRINT:SAY( 1230 + NLIN , 1550 ,  ALLTRIM(STR(ZA7->ZA7_CAREND))+" "+CTIPOCARD      , OFONT10   , 100 )                 
    
    OOBJPRINT:BOX( 1330 + NLIN , 0030, 1390 + NLIN, 2370)   	
    OOBJPRINT:SAY( 1350 + NLIN , 1050 ,  "DESCRIÇÃO DA CARGA"                             , OFONT5   , 100 )        
    
    OOBJPRINT:BOX( 1390 + NLIN , 0030, 1600 + NLIN, 2370)
    OOBJPRINT:SAY( 1410 + NLIN , 0040 ,  "DIMENSÕES"                                      , OFONT10   , 100 )                        

    OOBJPRINT:SAY( 1460 + NLIN , 0040 ,  "DESCRIÇÃO:"                                     , OFONT10   , 100 )                            
    OOBJPRINT:SAY( 1460 + NLIN , 0200 ,  ZA7->ZA7_CARGA                                   , OFONT10   , 100 )                                            
        
    OOBJPRINT:SAY( 1460 + NLIN , 1450 ,  "QUANTIDADE:"                                    , OFONT10   , 100 )                                
    OOBJPRINT:SAY( 1460 + NLIN , 1600 ,  TRANSFORM(ZA7->ZA7_QTD,"@E 999,999,999")         , OFONT10   , 100 )                                            
    
    OOBJPRINT:SAY( 1460 + NLIN , 1900 ,  "VALOR SEGURADO:"                                     , OFONT10   , 100 )                                
    OOBJPRINT:SAY( 1460 + NLIN , 2150 ,  TRANSFORM(ZA7->ZA7_VRCARG,"@E 999,999,999.99" )       , OFONT10   , 100 )                                            
    
    OOBJPRINT:SAY( 1510 + NLIN , 0040 ,  "COMPRIMENTO:"                                        , OFONT10   , 100 )                                
    OOBJPRINT:SAY( 1510 + NLIN , 0200 ,  TRANSFORM(ZA7->ZA7_COMP  ,"@E 999,999,999,999" )                                    , OFONT10   , 100 )                                                
    OOBJPRINT:SAY( 1510 + NLIN , 0400 ,  "MT"                                                  , OFONT10   , 100 )                                

    OOBJPRINT:SAY( 1510 + NLIN , 0750 ,  "LARGURA:"                                            , OFONT10   , 100 )                                    
    OOBJPRINT:SAY( 1510 + NLIN , 0900 ,  TRANSFORM(ZA7->ZA7_LARG  ,"@E 999,999,999" )                                    , OFONT10   , 100 )                                                
    OOBJPRINT:SAY( 1510 + NLIN , 1060 ,  "MT"                                                  , OFONT10   , 100 )                                    
        
    OOBJPRINT:SAY( 1510 + NLIN , 1450 ,  "ALTURA:"                                             , OFONT10   , 100 )                                    
    OOBJPRINT:SAY( 1510 + NLIN , 1600 ,  TRANSFORM(ZA7->ZA7_ALTU  ,"@E 999,999,999" )                                    , OFONT10   , 100 )                                                
    OOBJPRINT:SAY( 1510 + NLIN , 1755 ,  "MT"                                                  , OFONT10   , 100 )                                    
        
    OOBJPRINT:SAY( 1510 + NLIN , 1900 ,  "DIAMETRO:"                                           , OFONT10   , 100 )                                    
    OOBJPRINT:SAY( 1510 + NLIN , 2100 ,  TRANSFORM(ZA7->ZA7_DIAM  ,"@E 999,999,999" )                                    , OFONT10   , 100 )                                                
    OOBJPRINT:SAY( 1510 + NLIN , 2235 ,  "MT"                                                  , OFONT10   , 100 )                                    
    
    OOBJPRINT:SAY( 1560 + NLIN , 0040 ,  "PESO UNITARIO:"                                      , OFONT10   , 100 )                                    
    OOBJPRINT:SAY( 1560 + NLIN , 0200 ,  TRANSFORM(ZA7->ZA7_PESO  ,"@E 999,999,999.999" )                                    , OFONT10   , 100 )                                                
    OOBJPRINT:SAY( 1560 + NLIN , 0400 ,  "TON"                                                  , OFONT10   , 100 )                                    

    OOBJPRINT:SAY( 1560 + NLIN , 1900 ,  "PBT:"                                                , OFONT10   , 100 )                                    
    OOBJPRINT:SAY( 1560 + NLIN , 2100 ,  TRANSFORM(NPESOBRU  ,"@E 999,999,999.999" )                                    , OFONT10   , 100 )                                                
    OOBJPRINT:SAY( 1560 + NLIN , 2285 ,  "TON"                                                 , OFONT10   , 100 )                                    
    
    NLINAUX := 1560
    
	DBSELECTAREA("ZA7")
    DBSETORDER(1)
    MSSEEK(XFILIAL("ZA7") +  FQ5->FQ5_SOT + FQ5->FQ5_OBRA +  ZA6->ZA6_SEQTRA )
    
    //USADO PARA IMPRIMIR AS CARGAS COM O CAMPO JUNTO QUE NAO GERARAM AS
    WHILE !ZA7->(EOF()) .AND. ALLTRIM(FQ5->FQ5_SOT+FQ5->FQ5_OBRA+ZA6->ZA6_SEQTRA) == ALLTRIM(ZA7->ZA7_PROJET+ZA7->ZA7_OBRA+ZA7->ZA7_SEQTRA)
    	IF ZA7->ZA7_QUANT = "1"
    		ZA7->(DBSKIP())
    		LOOP
    	ENDIF 
    	
    	IF EMPTY(ZA7->ZA7_JUNTO)
    		ZA7->(DBSKIP())
    		LOOP
    	ENDIF   
    	
    	IF ZA7->ZA7_JUNTO != FQ5->FQ5_SEQCAR
    		ZA7->(DBSKIP())
    		LOOP
    	ENDIF 
    	
    	IF NLINAUX > 2600
    		OOBJPRINT:ENDPAGE()        
           	OOBJPRINT:STARTPAGE()
       	 //	OOBJPRINT:BOX( 0100 , 0050 , 3000 , 2370)    
           	NLINAUX := 0
           	NLIN := 0
    	ENDIF
    	NLINAUX += 40
    
    	OOBJPRINT:BOX( NLINAUX + NLIN , 0030, (NLINAUX+190) + NLIN, 2370)
	    OOBJPRINT:SAY( NLINAUX + NLIN , 0040 ,  "DIMENSÕES"                                      , OFONT10   , 100 )                        
        NLINAUX += 50
	    OOBJPRINT:SAY( NLINAUX + NLIN , 0040 ,  "DESCRIÇÃO:"                                     , OFONT10   , 100 )                            
	    OOBJPRINT:SAY( NLINAUX + NLIN , 0200 ,  ZA7->ZA7_CARGA                                   , OFONT10   , 100 )                                            
	        
	    OOBJPRINT:SAY( NLINAUX + NLIN , 1450 ,  "QUANTIDADE:"                                    , OFONT10   , 100 )                                
	    OOBJPRINT:SAY( NLINAUX + NLIN , 1600 ,  TRANSFORM(ZA7->ZA7_QTD,"@E 999,999,999")         , OFONT10   , 100 )                                            
	    
	    OOBJPRINT:SAY( NLINAUX + NLIN , 1900 ,  "VALOR SEGURADO:"                                     , OFONT10   , 100 )                                
	    OOBJPRINT:SAY( NLINAUX + NLIN , 2150 ,  TRANSFORM(ZA7->ZA7_VRCARG,"@E 999,999,999.99" )       , OFONT10   , 100 )                                            
	    NLINAUX += 50
	    OOBJPRINT:SAY( NLINAUX + NLIN , 0040 ,  "COMPRIMENTO:"                                        , OFONT10   , 100 )                                
	    OOBJPRINT:SAY( NLINAUX + NLIN , 0200 ,  TRANSFORM(ZA7->ZA7_COMP  ,"@E 999,999,999,999" )                                    , OFONT10   , 100 )                                                
	    OOBJPRINT:SAY( NLINAUX + NLIN , 0400 ,  "MT"                                                  , OFONT10   , 100 )                                
	    
	    OOBJPRINT:SAY( NLINAUX + NLIN , 0750 ,  "LARGURA:"                                            , OFONT10   , 100 )                                    
	    OOBJPRINT:SAY( NLINAUX + NLIN , 0900 ,  TRANSFORM(ZA7->ZA7_LARG  ,"@E 999,999,999" )                                    , OFONT10   , 100 )                                                
	    OOBJPRINT:SAY( NLINAUX + NLIN , 1060 ,  "MT"                                                  , OFONT10   , 100 )                                    
	        
	    OOBJPRINT:SAY( NLINAUX + NLIN , 1450 ,  "ALTURA:"                                             , OFONT10   , 100 )                                    
	    OOBJPRINT:SAY( NLINAUX + NLIN , 1600 ,  TRANSFORM(ZA7->ZA7_ALTU  ,"@E 999,999,999" )                                    , OFONT10   , 100 )                                                
	    OOBJPRINT:SAY( NLINAUX + NLIN , 1755 ,  "MT"                                                  , OFONT10   , 100 )                                    
	        
	    OOBJPRINT:SAY( NLINAUX + NLIN , 1900 ,  "DIAMETRO:"                                           , OFONT10   , 100 )                                    
	    OOBJPRINT:SAY( NLINAUX + NLIN , 2100 ,  TRANSFORM(ZA7->ZA7_DIAM  ,"@E 999,999,999" )                                    , OFONT10   , 100 )                                                
	    OOBJPRINT:SAY( NLINAUX + NLIN , 2235 ,  "MT"                                                  , OFONT10   , 100 )                                    
	    NLINAUX += 50
	    OOBJPRINT:SAY( NLINAUX + NLIN , 0040 ,  "PESO UNITARIO:"                                      , OFONT10   , 100 )                                    
	    OOBJPRINT:SAY( NLINAUX + NLIN , 0200 ,  TRANSFORM(ZA7->ZA7_PESO  ,"@E 999,999,999.999" )                                    , OFONT10   , 100 )                                                
	    OOBJPRINT:SAY( NLINAUX + NLIN , 0400 ,  "TON"                                                  , OFONT10   , 100 )                                    
	
	    OOBJPRINT:SAY( NLINAUX + NLIN , 1900 ,  "PBT:"                                                , OFONT10   , 100 )                                    
	    OOBJPRINT:SAY( NLINAUX + NLIN , 2100 ,  TRANSFORM(NPESOBRU  ,"@E 999,999,999.999" )                                    , OFONT10   , 100 )                                                
	    OOBJPRINT:SAY( NLINAUX + NLIN , 2285 ,  "TON"                                                 , OFONT10   , 100 )                                    
    	ZA7->(DBSKIP())
    ENDDO 
    
    DBSELECTAREA("ZA7")
    DBSETORDER(1)
    MSSEEK(XFILIAL("ZA7") +  FQ5->FQ5_SOT + FQ5->FQ5_OBRA +  ZA6->ZA6_SEQTRA + FQ5->FQ5_SEQCAR )                    
    
    IF NLINAUX > 2600
   		OOBJPRINT:ENDPAGE()        
       	OOBJPRINT:STARTPAGE()
     //	OOBJPRINT:BOX( 0100 , 0050 , 3000 , 2370)    
       	NLINAUX := 0
       	NLIN := 0
   	ENDIF
    
   	NLINAUX += 50
    NLINFIM := NLIN + (050 * LEN(ATRANSP))
    OOBJPRINT:BOX( NLINAUX + NLIN , 0030, (NLINAUX + 50) + NLINFIM, 2370)
    NLINAUX += 10
    OOBJPRINT:SAY( NLINAUX + NLIN , 0040 ,  "CONJUNTO TRANSPORTADOR:"                        , OFONT10   , 100 )                                        
    
    NLINAUX += 40
    FOR NX := 1 TO LEN(ATRANSP) 
        OOBJPRINT:SAY( NLINAUX + NLIN , 070 ,  ALLTRIM(ATRANSP[NX])                         , OFONT10   , 100 )
        NLIN:=NLIN+050
    NEXT NX 

	CTIPOPAG:=FTRAZCBOX(ZA6->ZA6_TIPPAG,"ZA6_TIPPAG")  //TRAZ SOMENTE O TEXTO DO X3_CBOX DO CAMPO INFORMADO
    
    NLIN:=NLINFIM
    NLINAUX += 10
    OOBJPRINT:BOX( NLINAUX + NLIN , 0030, (NLINAUX+50) + NLIN, 2370)
    NLINAUX += 10
    OOBJPRINT:SAY( NLINAUX + NLIN , 0040 ,  "CONDIÇÃO DE PAGAMENTO:"                         , OFONT10   , 100 )                                        
    OOBJPRINT:SAY( NLINAUX + NLIN , 0410 ,  ALLTRIM(SE4->E4_DESCRI)+" "+CTIPOPAG             , OFONT10   , 100 )                                                
  
    NLINAUX += 40
    OOBJPRINT:BOX( NLINAUX + NLIN , 0030, (NLINAUX+290) + NLIN, 2370)

 //	OFONT10    := TFONT():NEW("COURIER NEW"     ,08,08,,.T.,,,,,.F.)   // NEGRITO
	NSAY1:=0040
	NSAY2:=0410
	NSAY3:=0770
	NSAY4:=1130
	NSAY5:=1490
	NSAY6:=1950
	
	NGET1:=0210
	NGET2:=0580
	NGET3:=0920
	NGET4:=1280
	NGET5:=1710
	NGET6:=2150

	//1- LINHA-NOVOS CAMPO 
	NLINAUX += 30
    OOBJPRINT:SAY( NLINAUX + NLIN , NSAY1,  "DIAS VAZIO:",OFONT10,100)
    OOBJPRINT:SAY( NLINAUX + NLIN , NGET1,  TRANSFORM(NVALDIASV ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                
                                           
    OOBJPRINT:SAY( NLINAUX + NLIN , NSAY2,  "DIAS CARREGADO:",OFONT10,100)
    OOBJPRINT:SAY( NLINAUX + NLIN , NGET2,  TRANSFORM(NVALDIASC    ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                
        
    OOBJPRINT:SAY( NLINAUX + NLIN , NSAY3,  "KM VAZIO:",OFONT10,100)
    OOBJPRINT:SAY( NLINAUX + NLIN , NGET3,  TRANSFORM(NKMV    ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                
        
    OOBJPRINT:SAY( NLINAUX + NLIN , NSAY4,  "KM CARREGADO:",OFONT10,100)
    OOBJPRINT:SAY( NLINAUX + NLIN , NGET4,  TRANSFORM(NKMC    ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                                                            

	OOBJPRINT:SAY( NLINAUX + NLIN , NSAY5,  "VALOR FRETE:", OFONT10,100)
    OOBJPRINT:SAY( NLINAUX + NLIN , NGET5,  TRANSFORM(NFRETE  ,"@E 999,999,999.99")         , OFONT10   , 100 )
                                                                         
    //1- LINHA
    /*OOBJPRINT:SAY( 1740 + NLIN , NSAY1,  "CREDENCIAL:",OFONT10,100)
    OOBJPRINT:SAY( 1740 + NLIN , NGET1,  TRANSFORM(NCREDEN ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                
                                           
    OOBJPRINT:SAY( 1740 + NLIN , NSAY2,  "TUV:",OFONT10,100)
    OOBJPRINT:SAY( 1740 + NLIN , NGET2,  TRANSFORM(NTUV    ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                
        
    OOBJPRINT:SAY( 1740 + NLIN , NSAY3,  "PRF:",OFONT10,100)
    OOBJPRINT:SAY( 1740 + NLIN , NGET3,  TRANSFORM(NPRF    ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                
        
    OOBJPRINT:SAY( 1740 + NLIN , NSAY4,  "PRE:",OFONT10,100)
    OOBJPRINT:SAY( 1740 + NLIN , NGET4,  TRANSFORM(NPRE    ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                

    OOBJPRINT:SAY( 1740 + NLIN , NSAY5,  "FORMA SEGURO:"                                   , OFONT10   , 100 )                                                    
    OOBJPRINT:SAY( 1740 + NLIN , NGET5,   CTIPOSEG                                         , OFONT10   , 100 )                                                
        
 //	OOBJPRINT:SAY( 1740 + NLIN , NSAY6,  "ICMS:",OFONT10,100)
 //	OOBJPRINT:SAY( 1740 + NLIN , NGET6,   CTIPOICM                                         , OFONT10   , 100 ) */ 
        
    //2-LINHA
 /*	OOBJPRINT:SAY( 1790 + NLIN , NSAY1,  "TAP:",OFONT10,100)
    OOBJPRINT:SAY( 1790 + NLIN , NGET1,  TRANSFORM(NVALTAP ,"@E 999,999,999.99")            , OFONT10   , 100 )                                                

    OOBJPRINT:SAY( 1790 + NLIN , NSAY2,  "PEDAGIO:",OFONT10,100)
    OOBJPRINT:SAY( 1790 + NLIN , NGET2,  TRANSFORM(NPED    ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                
        
    OOBJPRINT:SAY( 1790 + NLIN , NSAY3,  "BLOQUEIO:",OFONT10,100)
    OOBJPRINT:SAY( 1790 + NLIN , NGET3,  TRANSFORM(NVALINV ,"@E 999,999,999.99")         , OFONT10   , 100 )                                                
        
    OOBJPRINT:SAY( 1790 + NLIN , NSAY4,  "EXTRA:",OFONT10,100)
    OOBJPRINT:SAY( 1790 + NLIN , NGET4,  TRANSFORM(NEXTRA  , "@E 999,999,999.99")   , OFONT10   , 100 )                                                

    OOBJPRINT:SAY( 1790 + NLIN , NSAY5,  "ALIQ.SEGURO:"                             , OFONT10   , 100 )                                                        
    OOBJPRINT:SAY( 1790 + NLIN , NGET5,  TRANSFORM(NALIQ   ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                    
    OOBJPRINT:SAY( 1790 + NLIN , 1870,  "%"                                               , OFONT10   , 100 )                                                        
        
    OOBJPRINT:SAY( 1790 + NLIN , NSAY6,  "ALIQ.ICMS:", OFONT10,100)
    OOBJPRINT:SAY( 1790 + NLIN , NGET6,  TRANSFORM(NICM    ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                
    OOBJPRINT:SAY( 1790 + NLIN , 2320 ,  "%"                                               , OFONT10   , 100 )*/                                                    
        
    //3 - LINHA
 /*	OOBJPRINT:SAY( 1840 + NLIN , NSAY1,  "TUR:",OFONT10,100)
    OOBJPRINT:SAY( 1840 + NLIN , NGET1,  TRANSFORM(NVALTUR ,"@E 999,999,999.99")              , OFONT10   , 100 )//NAO EXISTE CAMPO - VERIFICAR

    OOBJPRINT:SAY( 1840 + NLIN , NSAY2,  "TRAVESSIA:",OFONT10,100)
    OOBJPRINT:SAY( 1840 + NLIN , NGET2,  TRANSFORM(NTRAV   ,"@E 999,999,999.99")   , OFONT10   , 100 )                                                
                                                                     
    OOBJPRINT:SAY( 1840 + NLIN , NSAY3,  "LAUDO IPT:",OFONT10,100)
    OOBJPRINT:SAY( 1840 + NLIN , NGET3,  TRANSFORM(NIPT    ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                
    
    OOBJPRINT:SAY( 1840 + NLIN , NSAY4,  "EQUIP.AUX.:",OFONT10,100)
    OOBJPRINT:SAY( 1840 + NLIN , NGET4,  TRANSFORM(NVALAUX ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                

    OOBJPRINT:SAY( 1840 + NLIN , NSAY5,  "VALOR SEGURO:"                            , OFONT10   , 100 )                                                        
    OOBJPRINT:SAY( 1840 + NLIN , NGET5,  TRANSFORM(NSEG    ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                

    OOBJPRINT:SAY( 1840 + NLIN , NSAY6,  "VALOR ICMS:", OFONT10,100)
    OOBJPRINT:SAY( 1840 + NLIN , NGET6,  TRANSFORM(NVALICM ,"@E 999,999,999.99")            , OFONT10   , 100 )                                                        
                                                                        	
    //4 -LINHA
    OOBJPRINT:SAY( 1890 + NLIN , NSAY1,  "CONCESSION:", OFONT10, 100 )                                                        
    OOBJPRINT:SAY( 1890 + NLIN , NGET1 ,  TRANSFORM(NCONCESS,"@E 999,999,999.99")            , OFONT10   , 100 ) //NAO EXISTE CAMPO - VERIFICAR                                            

    OOBJPRINT:SAY( 1890 + NLIN , NSAY2,  "ACOMP.TECN:", OFONT10,100)
    OOBJPRINT:SAY( 1890 + NLIN , NGET2,  TRANSFORM(NACOMP  ,"@E 999,999,999.99")         , OFONT10   , 100 )                                                        

    OOBJPRINT:SAY( 1890 + NLIN , NSAY3,  "CIA.TELEF.:", OFONT10,100)
OOBJPRINT:SAY( 1890 + NLIN , NGET3,  TRANSFORM(NVALTEL ,"@E 999,999,999.99")         , OFONT10   , 100 )                                                        

    OOBJPRINT:SAY( 1890 + NLIN , NSAY4,  "ACOMP.CET:", OFONT10,100)
    OOBJPRINT:SAY( 1890 + NLIN , NGET4,  TRANSFORM(NCET    ,"@E 999,999,999.99")             , OFONT10   , 100 )                                                        

    OOBJPRINT:SAY( 1890 + NLIN , NSAY5,  "TIPO SEGURO:"                                    , OFONT10   , 100 )
    OOBJPRINT:SAY( 1890 + NLIN , NGET5,  CSEGURO                                           , OFONT10   , 100 )  */                                              

    //5 -LINHA
 /*	OOBJPRINT:SAY( 1940 + NLIN , NSAY1,  "OUTROS:", OFONT10,100)
    OOBJPRINT:SAY( 1940 + NLIN , NGET1,  TRANSFORM(NOUT    ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                            

    OOBJPRINT:SAY( 1940 + NLIN , NSAY2,  "SEMAFORICA:", OFONT10,100)
    OOBJPRINT:SAY( 1940 + NLIN , NGET2,  TRANSFORM(NSEMAFOR,"@E 999,999,999.99")    , OFONT10   , 100 )                                                            
                                                                
    OOBJPRINT:SAY( 1940 + NLIN , NSAY3,  "TV A CABO:", OFONT10,100)
    OOBJPRINT:SAY( 1940 + NLIN , NGET3,  TRANSFORM(NVALTVA ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                            

	OOBJPRINT:SAY( 1940 + NLIN , NSAY6,  "VALOR FRETE:", OFONT10,100)
    OOBJPRINT:SAY( 1940 + NLIN , NGET6,  TRANSFORM(NFRETE  ,"@E 999,999,999.99")         , OFONT10   , 100 )  */
                                                                
//	OFONT10    := TFONT():NEW("ARIAL"     ,08,08,,.T.,,,,,.F.)   // NEGRITO

	IF NLINAUX > 2500
   		OOBJPRINT:ENDPAGE()        
      	OOBJPRINT:STARTPAGE()
	 //	OOBJPRINT:BOX( 0100 , 0050 , 3000 , 2370)    
      	NLINAUX := 0
      	NLIN := 0
   	ENDIF

	NLINAUX += 60
    OOBJPRINT:BOX( NLINAUX + NLIN , 0030, (NLINAUX+800) + NLIN, 2370)    
    NLINAUX += 60
    OOBJPRINT:SAY( NLINAUX + NLIN , 1050 ,  "OBSERVAÇÕES"                                     , OFONT5   , 100 )        
    NLINAUX += 60
    OOBJPRINT:BOX( NLINAUX + NLIN , 0030, (NLINAUX+600) + NLIN, 2370)    

    XT := MLCOUNT(ZA7->ZA7_OBS,130)   
    NLINOBS := 2450//2800 
    
    IF !EMPTY(ZA7->ZA7_OBS)
	    OBJPRINT:SAY( NLINOBS , 0060 ,  "OBSERVAÇÃO CARGA "       , OFONT10   , 100 )
		NLINOBS := NLINOBS + 50
	    FOR I:=1 TO XT
		    OOBJPRINT:SAY( NLINOBS , 0060 ,  MEMOLINE(ZA7->ZA7_OBS ,130, I )                   , OFONT10   , 100 ) 
	        IF NLINOBS > 3350
	           OOBJPRINT:ENDPAGE()        
	           OOBJPRINT:STARTPAGE()
	           OOBJPRINT:BOX( 0100 , 0050 , 3000 , 2370)    
	           NLINOBS := 150
	        ENDIF
	        NLINOBS := NLINOBS + 50
	    NEXT I 
    ENDIF 
    
	FP5->(DBCLOSEAREA())
	DBSELECTAREA("FP5")
	FP5->(DBCLEARFILTER())
	FP5->(DBSETFILTER({|| ALLTRIM(FP5->FP5_PROJET) == ALLTRIM(ZA7->ZA7_PROJET) .AND. ALLTRIM(FP5->FP5_OBRA) == ALLTRIM(ZA7->ZA7_OBRA)},"ALLTRIM(FP5->FP5_PROJET) == ALLTRIM(ZA7->ZA7_PROJET) .AND. ALLTRIM(FP5->FP5_OBRA) == ALLTRIM(ZA7->ZA7_OBRA)"))
	FP5->(DBGOTOP())
			
	IF !EMPTY(FP5->FP5_OBSACE)			
		XT := MLCOUNT(FP5->FP5_OBSACE,130)
		NLINOBS += 50
		OOBJPRINT:SAY( NLINOBS , 0060 ,  "OBSERVAÇÃO IÇAMENTO"       , OFONT10   , 100 )
		NLINOBS := NLINOBS + 50
		FOR I:=1 TO XT
			OOBJPRINT:SAY( NLINOBS , 0060 ,  MEMOLINE(FP5->FP5_OBSACE ,130, I )       , OFONT10   , 100 )
			IF NLINOBS > 3200
				OOBJPRINT:ENDPAGE()
				OOBJPRINT:STARTPAGE()
				OOBJPRINT:BOX( 0100 , 0050 , 3350 , 2370)
				NLINOBS := 150
			ENDIF
			NLINOBS := NLINOBS + 50
		NEXT I 
	ENDIF
			 
	IF !EMPTY(FP5->FP5_OBS)			
		XT := MLCOUNT(FP5->FP5_OBS,130)
		NLINOBS += 50
		OOBJPRINT:SAY( NLINOBS , 0060 ,  "OBSERVAÇÃO"        , OFONT10   , 100 )
		NLINOBS := NLINOBS + 50
		FOR I:=1 TO XT
			OOBJPRINT:SAY( NLINOBS , 0060 ,  MEMOLINE(FP5->FP5_OBS ,130, I )       , OFONT10   , 100 )
			IF NLINOBS > 3200
				OOBJPRINT:ENDPAGE()
				OOBJPRINT:STARTPAGE()
				OOBJPRINT:BOX( 0100 , 0050 , 3350 , 2370)
				NLINOBS := 150
			ENDIF
			NLINOBS := NLINOBS + 50
		NEXT I 
	ENDIF		
	OOBJPRINT:SAY( NLINOBS , 0060 ,  COBSG , OFONT10   , 100 ) 
    
    OOBJPRINT:ENDPAGE()
    
    /*DBSELECTAREA("ZA7")
    DBSETORDER(1)
    MSSEEK(XFILIAL("ZA7") +  FQ5->FQ5_SOT + FQ5->FQ5_OBRA +  ZA6->ZA6_SEQTRA )
    
    //USADO PARA IMPRIMIR AS CARGAS COM O CAMPO JUNTO QUE NAO GERARAM AS
    WHILE !ZA7->(EOF()) .AND. ALLTRIM(FQ5->FQ5_SOT+FQ5->FQ5_OBRA+ZA6->ZA6_SEQTRA) == ALLTRIM(ZA7->ZA7_PROJET+ZA7->ZA7_OBRA+ZA7->ZA7_SEQTRA)
    	IF ZA7->ZA7_QUANT = "1"
    		ZA7->(DBSKIP())
    		LOOP
    	ENDIF 
    	
    	IF EMPTY(ZA7->ZA7_JUNTO)
    		ZA7->(DBSKIP())
    		LOOP
    	ENDIF
    	
    	DBSELECTAREA("SE4")                                                                
	    DBSETORDER(1)                                                             
	    MSSEEK(XFILIAL("SE4") + ZA6->ZA6_CONPAG )
	
	    DBSELECTAREA("FQ8")
	    DBSETORDER(2)
	    IF MSSEEK(XFILIAL("FQ8") +  FQ5->FQ5_SOT + FQ5->FQ5_OBRA + ZA6->ZA6_SEQTRA+ ZA7->ZA7_SEQCAR )
		    NCREDEN := FQ8->FQ8_VALESC
		    NTUV    := FQ8->FQ8_VALTUV
		    NPRF    := FQ8->FQ8_VALPRF
		    NPRE    := FQ8->FQ8_VALPRE
		    NPED    := FQ8->FQ8_VALPED
		    NEXTRA  := FQ8->FQ8_VALADI
		    NALIQ   := ZA7->ZA7_VALADV
		    NSEG    := ROUND(ZA7->ZA7_VRCARG*ZA7->ZA7_VALADV/100,2)
		    NTRAV   := FQ8->FQ8_VALTRA
		    NIPT    := FQ8->FQ8_VALIPT
		    NICM    := ZA7->ZA7_VALICM
		    NACOMP  := FQ8->FQ8_VALACO
		    NOUT    := FQ8->FQ8_VALOUT
		    NFRETE  := FQ8->FQ8_VRFRET
		    NCONCESS:= FQ8->FQ8_VALCON
		    NSEMAFOR:= FQ8->FQ8_VALSEM
		    NVALTVA := FQ8->FQ8_VALTVA
		    NVALTEL := FQ8->FQ8_VALTEL
		    NVALTUR := FQ8->FQ8_VALTUR
		    NCET    := FQ8->FQ8_VALCET
		    NVALAUX := FQ8->FQ8_VALAUX
		    NVALINV := FQ8->FQ8_VALINV  //BLOQUEIO: BLOQUEIO + ALEMOA
		    NVALTAP	:= FQ8->FQ8_VALTAP
		ENDIF	
	
		NVALICM  := ROUND( ((NFRETE+NSEG)*NICM/100) / ((100-NICM)/100) ,2)
	    ATRANSP  := {}
		NPESOBRU := ZA7->ZA7_PESO
	
	    DBSELECTAREA("FP8")
	    FP8->(DBSETORDER(1))  //FP8_FILIAL+FP8_PROJET+FP8_OBRA+FP8_SEQTRA+FP8_SEQCAR+FP8_SEQCON
	    MSSEEK(XFILIAL("FP8")+FQ5->FQ5_SOT+FQ5->FQ5_OBRA)
	    WHILE FP8->(!EOF() .AND. FP8_FILIAL+FP8_PROJET+FP8_OBRA==XFILIAL("FP8")+FQ5->FQ5_SOT+FQ5->FQ5_OBRA)
			IF FP8->(!FP8_SEQCAR==ZA7->ZA7_SEQCAR)
				FP8->(DBSKIP())
				LOOP
			ENDIF
			AADD(ATRANSP,FP8->FP8_DESTRA)
			NPESOBRU  += FP8->FP8_PESO
			NVALDIASV += FP8->FP8_DIASV
		 	NVALDIASC += FP8->FP8_DIASC
			FP8->(DBSKIP())
		ENDDO 
	
		IF EMPTY(ATRANSP)
			AADD(ATRANSP,SPACE(LEN(FP8->FP8_DESTRA)))
		ENDIF
		
		DBSELECTAREA("FPD")
		DBSETORDER(1)
		DBSEEK(XFILIAL("FPD")+FQ5->FQ5_SOT+FQ5->FQ5_OBRA)
		WHILE FPD->(!EOF() .AND. FPD_FILIAL+FPD_PROJET+FPD_OBRA==XFILIAL("FPD")+FQ5->FQ5_SOT+FQ5->FQ5_OBRA)
			IF FP7->FP7_VAZIO == 'V'
				NKMV += FP7->FP7_DISTAN
		 	ELSEIF FP7->FP7_VAZIO == 'C'
		 		NKMC += FP7->FP7_DISTAN      
		 	ENDIF
			FPD->(DBSKIP())
		ENDDO 
	
	    CTIPOSEG := IIF(ZA7->ZA7_INCADV == "I","INCLUSO",IIF(ZA7->ZA7_INCADV == "N","NÃO INCLUSO","CLIENTE"))
	//  CTIPOICM := IIF(ZA7->ZA7_INCICM == "I","INCLUSO",IIF(ZA7->ZA7_INCICM == "N","NÃO INCLUSO",IIF(ZA7->ZA7_INCICM == "S","SUBS.TRIBUTARIA","CLIENTE")))
	//  CTIPOCAR := IIF(ZA7->ZA7_TIPCAR == "A","ANO(S)" ,IIF(ZA7->ZA7_TIPCAR == "M","MESES",IIF(ZA7->ZA7_TIPCAR == "S","SEMANAS",IIF(ZA7->ZA7_TIPCAR == "D","DIAS",""))))   
	    CSEGURO  := IIF(ZA7->ZA7_FORMAS == "1","AD. VALOREM",IIF(ZA7->ZA7_FORMAS == "2","RCTR-C",""))
	
		DO CASE
	    CASE ZA7->ZA7_INCICM == "I" ; CTIPOICM:="INCLUSO"
	    CASE ZA7->ZA7_INCICM == "N" ; CTIPOICM:="NÃO INCLUSO"
	    CASE ZA7->ZA7_INCICM == "S" ; CTIPOICM:="SUBS.TRIBUTÁRIA"
	    CASE ZA7->ZA7_INCICM == "C" ; CTIPOICM:="CLIENTE"
	    CASE ZA7->ZA7_INCICM == "X" ; CTIPOICM:="ISENTO"
	    OTHERWISE                   ; CTIPOICM:="ISENTO"
	    ENDCASE
	
		DO CASE
		CASE ZA7->ZA7_TIPCAR == "H" ; CTIPOCAR:="HORAS  "
		CASE ZA7->ZA7_TIPCAR == "D" ; CTIPOCAR:="DIAS   "
		CASE ZA7->ZA7_TIPCAR == "S" ; CTIPOCAR:="SEMANAS"
		CASE ZA7->ZA7_TIPCAR == "M" ; CTIPOCAR:="MESES  "
		CASE ZA7->ZA7_TIPCAR == "A" ; CTIPOCAR:="ANOS   "
		OTHERWISE                   ; CTIPOCAR:="       "
	    ENDCASE
	
		DO CASE
		CASE ZA7->ZA7_TPCARD == "H" ; CTIPOCARD:="HORAS  "
		CASE ZA7->ZA7_TPCARD == "D" ; CTIPOCARD:="DIAS   "
		CASE ZA7->ZA7_TPCARD == "S" ; CTIPOCARD:="SEMANAS"
		CASE ZA7->ZA7_TPCARD == "M" ; CTIPOCARD:="MESES  "
		CASE ZA7->ZA7_TPCARD == "A" ; CTIPOCARD:="ANOS   "
		OTHERWISE                   ; CTIPOCARD:="       "
	    ENDCASE
	
		CEMAILCLI:=FP0->FP0_CLIEMA
		CEMAILCON:=FP0->FP0_CLIEMA
	    
		IF CEMPANT == "07"
	    	OOBJPRINT:SAYBITMAP( 0055, 020,"LGJSM.BMP"   , 790, 0380 ) //553 X 224
	 	ELSE
	 		OOBJPRINT:SAYBITMAP( 0055, 020,"LOGO.BMP"   , 790, 0380 ) //553 X 224
	 	ENDIF
	
		DO CASE
		CASE FP0->FP0_TIPOSE == "T"; _CDESC := "TRANSPORTE"
		CASE FP0->FP0_TIPOSE == "I"; _CDESC := "TRANSPORTE INT."
		CASE FP0->FP0_TIPOSE == "O"; _CDESC := "TRANSPORTE EMP"
		OTHERWISE                  ; _CDESC := FP0->FP0_TIPOSE
		ENDCASE
		
	    OOBJPRINT:SAY( 0050 , 0850 , "AUTORIZAÇÃO DE SERVIÇO: " + _CDESC             , OFONT2   , 100 )    
	    OOBJPRINT:SAY( 0150 , 0850 ,  "NO. AST :" +TRANSFORM(SUBSTR(FQ5->FQ5_AS,1,10)+SUBSTR(ZA7->ZA7_SEQCAR,2,2)+SUBSTR(FQ5->FQ5_AS,13,2),"@R XX-XXXXX-XXX-XX-XX")                       , OFONT2   , 100 )    
	    
	    OOBJPRINT:SAY( 0250 , 0850 ,  "NO. PROJETO: "+ALLTRIM(FQ5->FQ5_SOT)+;
	    							  " - REVISÃO: " +ALLTRIM(FP0->FP0_REVISAO)      , OFONT2   , 100 )                                                                                                                                                          
	    
	    OOBJPRINT:SAY( 0350 , 0850 ,  "NO. OBRA: "   +ALLTRIM(FQ5->FQ5_OBRA)+;
	      	                          " - REVISÃO DA AS: "+STRZERO(ZA7->ZA7_REVNAS,2), OFONT2   , 100 )
	
	    OOBJPRINT:BOX( 0030 + NLIN , 0030, 150 + NLIN, 2370)
	    OOBJPRINT:SAY( 0050 + NLIN , 0040 ,  "EMITIDA EM: "+DTOC(DDATABASE)+" AS "+TIME(), OFONT10   , 100 )        
	  	OOBJPRINT:SAY( 0050 + NLIN , 0600 ,  "NÚMERO SOT: "+ALLTRIM(FP0->FP0_PROJET) + ;
	  	                                     " - REVISÃO: "+FP0->FP0_REVISA                 , OFONT10   , 100 )            
		OOBJPRINT:SAY( 0050 + NLIN , 1400 ,  "NÚMERO OBRA: "+FQ5->FQ5_OBRA                  , OFONT10   , 100 )              
	    OOBJPRINT:SAY( 0050 + NLIN , 1800 ,  "NÚMERO VIAGEM:"+FQ5->FQ5_VIAGEM               , OFONT10   , 100 )                  
	    
	    OOBJPRINT:SAY( 0100 + NLIN , 0040 ,  "GESTOR:"                                   , OFONT10   , 100 )            
	    OOBJPRINT:SAY( 0100 + NLIN , 0240 ,  FP0->FP0_VENDED+" - "+POSICIONE("SA3",1,XFILIAL("SA3") + FP0->FP0_VENDED , "A3_NOME" )  , OFONT10   , 100 )        
	                                                                                     
	    OOBJPRINT:BOX( 0150 + NLIN , 0030, 0210 + NLIN, 2370)
	    OOBJPRINT:SAY( 0160 + NLIN , 0950 ,  "INFORMAÇÕES DO CLIENTE"                        , OFONT5   , 100 )        
	    OOBJPRINT:BOX( 0210 + NLIN , 0030, 0610 + NLIN, 2370)
	    OOBJPRINT:SAY( 0230 + NLIN , 0040 ,  "CLIENTE: "+CCODCLI+"/"+CLJCLIE+" - "+ALLTRIM(FP0->FP0_CLINOM), OFONT10   , 100 ) 
	    OOBJPRINT:SAY( 0230 + NLIN , 1200 ,  "I.E: "                                         , OFONT10   , 100 )
	    OOBJPRINT:SAY( 0230 + NLIN , 1300 ,  TRANSFORM(CINCR,"@R 999.999.999-999")           , OFONT10   , 100 )
	    OOBJPRINT:SAY( 0260 + NLIN , 0040 ,  "C.N.P.J:"                                      , OFONT10   , 100 )            
	    OOBJPRINT:SAY( 0260 + NLIN , 0170 ,  TRANSFORM(CGC,"@R 99.999.999/9999-99")          , OFONT10   , 100 )    
	    
	    OOBJPRINT:SAY( 0290 + NLIN , 0040 ,  "END. COMERCIAL:"                                  , OFONT10   ,100)                
	    OOBJPRINT:SAY( 0330 + NLIN , 0040 ,  CENDERE                                            , OFONT10   ,100)
	    OOBJPRINT:SAY( 0380 + NLIN , 0040 ,  ALLTRIM(CBAIRRO) +" - "+ALLTRIM(CMUNICI)+" - "+ALLTRIM(CESTADO)+" - "+ALLTRIM(CCEP) , OFONT10   ,100)
	                    
	    OOBJPRINT:SAY( 0290 + NLIN , 1200 ,  "END. COBRANÇA:"                                   , OFONT10   ,100)                    
	    OOBJPRINT:SAY( 0330 + NLIN , 1200 ,  CENDCOB                                            , OFONT10   ,100)
	    OOBJPRINT:SAY( 0380 + NLIN , 1200 ,  ALLTRIM(CBAICOB) +" - "+ALLTRIM(CMUNCOB)+" - "+ALLTRIM(CESTCOB)+" - "+ALLTRIM(CCEPCOB) , OFONT10   ,100)
	        
	    OOBJPRINT:SAY( 0420 + NLIN , 0040 ,  "TELEFONE: "                                       , OFONT10   , 100 )                        
	    OOBJPRINT:SAY( 0470 + NLIN , 0040 ,  "CONTATO : "                                       , OFONT10   , 100 )                            
	
	    OOBJPRINT:SAY( 0420 + NLIN , 0170 ,  CTEL                                               , OFONT10   , 100 )                        
	    OOBJPRINT:SAY( 0470 + NLIN , 0170 ,  CCONTATO                                           , OFONT10   , 100 )                            
	
	    OOBJPRINT:SAY( 0420 + NLIN , 1200 ,  "TELEFONE: "                                       , OFONT10   , 100 )                        
	    OOBJPRINT:SAY( 0470 + NLIN , 1200 ,  "CONTATO : "                                       , OFONT10   , 100 )                            
	
	    OOBJPRINT:SAY( 0420 + NLIN , 1330 ,  CTEL                                               , OFONT10   , 100 )                        
	    OOBJPRINT:SAY( 0470 + NLIN , 1330 ,  CCONTATO                                           , OFONT10   , 100 )                            
	
	    OOBJPRINT:SAY( 0520 + NLIN , 0040 ,  "E-MAIL  : "                                       , OFONT10   , 100 )
	    OOBJPRINT:SAY( 0520 + NLIN , 1200 ,  "E-MAIL  : "                                       , OFONT10   , 100 )
	    OOBJPRINT:SAY( 0520 + NLIN , 0170 ,  CEMAILCLI                                          , OFONT10   , 100 )
	    OOBJPRINT:SAY( 0520 + NLIN , 1330 ,  CEMAILCON                                          , OFONT10   , 100 )
	    
	    
	    OOBJPRINT:BOX( 0610 + NLIN , 0030, 0670 + NLIN, 2370)
	    OOBJPRINT:SAY( 0630 + NLIN , 0700 ,  "INFORMAÇÕES DE CARREGAMENTO E DESCARREGAMENTO"   , OFONT5   , 100 )        
	    
	    OOBJPRINT:BOX( 0670 + NLIN , 0030, 1000 + NLIN, 2370)
	    OOBJPRINT:SAY( 0690 + NLIN , 0040 ,  "CARREGAMENTO"                                   , OFONT10   , 100 )                        
	
	    OOBJPRINT:SAY( 0750 + NLIN , 0040 ,  "LOCAL: "                                         , OFONT10   , 100 )                                
	    OOBJPRINT:SAY( 0750 + NLIN , 0140 ,  ALLTRIM(ZA6->ZA6_NOMORI)                          , OFONT10   , 100 )                                
	        
	    OOBJPRINT:SAY( 0750 + NLIN , 1200 ,  "PRAZO EXEC: "                                    , OFONT10   , 100 )                            
	    OOBJPRINT:SAY( 0750 + NLIN , 1330 ,  STR(_PRAZEXEC)                                    , OFONT10   , 100 )                            
	    
	    OOBJPRINT:SAY( 0750 + NLIN , 1800 ,  "DATA: "                                          , OFONT10   , 100 )                                
	    OOBJPRINT:SAY( 0750 + NLIN , 1900 ,  DTOC(ZA7->ZA7_DTCAR)                              , OFONT10   , 100 )                                
	        
	    OOBJPRINT:SAY( 0750 + NLIN , 2050 ,  "HORA: "                                          , OFONT10   , 100 )                                
	    OOBJPRINT:SAY( 0750 + NLIN , 2150 ,  TRANSFORM(ZA7->ZA7_HRCAR,"@R 99:99")              , OFONT10   , 100 )                                
	        
	    OOBJPRINT:SAY( 0800 + NLIN , 0040 ,  "ENDEREÇO: "                                      , OFONT10   , 100 )                                    
	    OOBJPRINT:SAY( 0800 + NLIN , 0190 ,  ZA6->ZA6_ENDORI                                   , OFONT10   , 100 )                                    
	        
	    OOBJPRINT:SAY( 0850 + NLIN , 0040 ,  "BAIRRO: "                                        , OFONT10   , 100 )                                
	    OOBJPRINT:SAY( 0850 + NLIN , 0150 ,  ZA6->ZA6_BAIORI                                   , OFONT10   , 100 )                                
	        
	    OOBJPRINT:SAY( 0850 + NLIN , 0700 ,  "CIDADE: "                                        , OFONT10   , 100 )                                    
	    OOBJPRINT:SAY( 0850 + NLIN , 0830 ,  ZA6->ZA6_MUNORI                                   , OFONT10   , 100 )                                    
	    
	    OOBJPRINT:SAY( 0850 + NLIN , 1200 ,  "ESTADO: "                                        , OFONT10   , 100 )                                        
	    OOBJPRINT:SAY( 0850 + NLIN , 1330 ,  ZA6->ZA6_ESTORI                                   , OFONT10   , 100 )                                        
	        
	    OOBJPRINT:SAY( 0900 + NLIN , 0040 ,  "TELEFONE: "                                      , OFONT10   , 100 )                                            
	    OOBJPRINT:SAY( 0900 + NLIN , 0180 ,  ZA6->ZA6_TELORI                                   , OFONT10   , 100 )                                            
	        
	    OOBJPRINT:SAY( 0900 + NLIN , 0700 ,  "CONTATO: "                                       , OFONT10   , 100 )                                            
	    OOBJPRINT:SAY( 0900 + NLIN , 0830 ,  ZA6->ZA6_CONORI                                   , OFONT10   , 100 )                                            
	    
	    OOBJPRINT:SAY( 0900 + NLIN , 1400 ,  "CARENCIA: "                                      , OFONT10   , 100 )                                            
	    OOBJPRINT:SAY( 0900 + NLIN , 1550 ,  ALLTRIM(STR(ZA7->ZA7_CARENC))+" "+CTIPOCAR                 , OFONT10   , 100 ) 
	                
	    OOBJPRINT:BOX( 1000 + NLIN , 0030, 1330 + NLIN, 2370)
	    OOBJPRINT:SAY( 1020 + NLIN , 0040 ,  "DESCARREGAMENTO"                                , OFONT10   , 100 )                        
	    
	    OOBJPRINT:SAY( 1080 + NLIN , 0040 ,  "LOCAL:"                                         , OFONT10   , 100 )                            
	    OOBJPRINT:SAY( 1080 + NLIN , 0140 ,  ALLTRIM(ZA6->ZA6_NOMDES)                          , OFONT10   , 100 )                                
	        
	    OOBJPRINT:SAY( 1080 + NLIN , 1200 ,  "PRAZO EXECUÇÃO:"                                , OFONT10   , 100 )                            
	    OOBJPRINT:SAY( 1080 + NLIN , 1350 ,  STR(_PRAZEXEC)                                    , OFONT10   , 100 )                            
	    
	    OOBJPRINT:SAY( 1080 + NLIN , 1800 ,  "DATA:"                                          , OFONT10   , 100 )                                
	    OOBJPRINT:SAY( 1080 + NLIN , 1900 ,  DTOC(ZA7->ZA7_DTDES)                             , OFONT10   , 100 )                                
	        
	    OOBJPRINT:SAY( 1080 + NLIN , 2050 ,  "HORA:"                                          , OFONT10   , 100 )                                
	    OOBJPRINT:SAY( 1080 + NLIN , 2150 ,  TRANSFORM(ZA7->ZA7_HRDES,"@R 99:99")             , OFONT10   , 100 )                                
	        
	    OOBJPRINT:SAY( 1130 + NLIN , 0040 ,  "ENDEREÇO:"                                      , OFONT10   , 100 )                                    
	    OOBJPRINT:SAY( 1130 + NLIN , 0190 ,  ZA6->ZA6_ENDDES                                  , OFONT10   , 100 )                                    
	        
	    OOBJPRINT:SAY( 1180 + NLIN , 0040 ,  "BAIRRO:"                                        , OFONT10   , 100 )                                
	    OOBJPRINT:SAY( 1180 + NLIN , 0150 ,  ZA6->ZA6_BAIDES                                  , OFONT10   , 100 )                                
	        
	    OOBJPRINT:SAY( 1180 + NLIN , 0700 ,  "CIDADE:"                                        , OFONT10   , 100 )                                    
	    OOBJPRINT:SAY( 1180 + NLIN , 0830 ,  ZA6->ZA6_MUNDES                                  , OFONT10   , 100 )                                    
	        
	    OOBJPRINT:SAY( 1180 + NLIN , 1200 ,  "ESTADO:"                                        , OFONT10   , 100 )                                        
	    OOBJPRINT:SAY( 1180 + NLIN , 1330 ,  ZA6->ZA6_ESTDES                                  , OFONT10   , 100 )                                        
	        
	    OOBJPRINT:SAY( 1230 + NLIN , 0040 ,  "TELEFONE:"                                      , OFONT10   , 100 )                                            
	    OOBJPRINT:SAY( 1230 + NLIN , 0180 ,  ZA6->ZA6_TELDES                                  , OFONT10   , 100 )                                            
	        
	    OOBJPRINT:SAY( 1230 + NLIN , 0700 ,  "CONTATO:"                                       , OFONT10   , 100 )                                            
	    OOBJPRINT:SAY( 1230 + NLIN , 0830 ,  ZA6->ZA6_CONDES                                  , OFONT10   , 100 )                                            
	        
	    OOBJPRINT:SAY( 1230 + NLIN , 1400 ,  "CARENCIA:"                                      , OFONT10   , 100 )                                            
	    OOBJPRINT:SAY( 1230 + NLIN , 1550 ,  ALLTRIM(STR(ZA7->ZA7_CAREND))+" "+CTIPOCARD      , OFONT10   , 100 )                 
	    
	    OOBJPRINT:BOX( 1330 + NLIN , 0030, 1390 + NLIN, 2370)   	
	    OOBJPRINT:SAY( 1350 + NLIN , 1050 ,  "DESCRIÇÃO DA CARGA"                             , OFONT5   , 100 )        
	    
	    OOBJPRINT:BOX( 1390 + NLIN , 0030, 1600 + NLIN, 2370)
	    OOBJPRINT:SAY( 1410 + NLIN , 0040 ,  "DIMENSÕES"                                      , OFONT10   , 100 )                        
	
	    OOBJPRINT:SAY( 1460 + NLIN , 0040 ,  "DESCRIÇÃO:"                                     , OFONT10   , 100 )                            
	    OOBJPRINT:SAY( 1460 + NLIN , 0200 ,  ZA7->ZA7_CARGA                                   , OFONT10   , 100 )                                            
	        
	    OOBJPRINT:SAY( 1460 + NLIN , 1450 ,  "QUANTIDADE: 001 "                                    , OFONT10   , 100 )                                
	    //OOBJPRINT:SAY( 1460 + NLIN , 1600 ,  TRANSFORM(ZA7->ZA7_QUANT,"@E 999,999,999")       , OFONT10   , 100 )                                            
	    
	    OOBJPRINT:SAY( 1460 + NLIN , 1900 ,  "VALOR SEGURADO:"                                     , OFONT10   , 100 )                                
	    OOBJPRINT:SAY( 1460 + NLIN , 2150 ,  TRANSFORM(ZA7->ZA7_VRCARG,"@E 999,999,999.99" )       , OFONT10   , 100 )                                            
	    
	    OOBJPRINT:SAY( 1510 + NLIN , 0040 ,  "COMPRIMENTO:"                                        , OFONT10   , 100 )                                
	    OOBJPRINT:SAY( 1510 + NLIN , 0200 ,  TRANSFORM(ZA7->ZA7_COMP  ,"@E 999,999,999,999" )                                    , OFONT10   , 100 )                                                
	    OOBJPRINT:SAY( 1510 + NLIN , 0400 ,  "MM"                                                  , OFONT10   , 100 )                                
	    
	    OOBJPRINT:SAY( 1510 + NLIN , 0750 ,  "LARGURA:"                                            , OFONT10   , 100 )                                    
	    OOBJPRINT:SAY( 1510 + NLIN , 0900 ,  TRANSFORM(ZA7->ZA7_LARG  ,"@E 999,999,999" )                                    , OFONT10   , 100 )                                                
	    OOBJPRINT:SAY( 1510 + NLIN , 1060 ,  "MM"                                                  , OFONT10   , 100 )                                    
	        
	    OOBJPRINT:SAY( 1510 + NLIN , 1450 ,  "ALTURA:"                                             , OFONT10   , 100 )                                    
	    OOBJPRINT:SAY( 1510 + NLIN , 1600 ,  TRANSFORM(ZA7->ZA7_ALTU  ,"@E 999,999,999" )                                    , OFONT10   , 100 )                                                
	    OOBJPRINT:SAY( 1510 + NLIN , 1755 ,  "MM"                                                  , OFONT10   , 100 )                                    
	        
	    OOBJPRINT:SAY( 1510 + NLIN , 1900 ,  "DIAMETRO:"                                           , OFONT10   , 100 )                                    
	    OOBJPRINT:SAY( 1510 + NLIN , 2100 ,  TRANSFORM(ZA7->ZA7_DIAM  ,"@E 999,999,999" )                                    , OFONT10   , 100 )                                                
	    OOBJPRINT:SAY( 1510 + NLIN , 2235 ,  "MM"                                                  , OFONT10   , 100 )                                    
	    
	    OOBJPRINT:SAY( 1560 + NLIN , 0040 ,  "PESO UNITARIO:"                                      , OFONT10   , 100 )                                    
	    OOBJPRINT:SAY( 1560 + NLIN , 0200 ,  TRANSFORM(ZA7->ZA7_PESO  ,"@E 999,999,999.999" )                                    , OFONT10   , 100 )                                                
	    OOBJPRINT:SAY( 1560 + NLIN , 0400 ,  "TON"                                                  , OFONT10   , 100 )                                    
	
	    OOBJPRINT:SAY( 1560 + NLIN , 1900 ,  "PBT:"                                                , OFONT10   , 100 )                                    
	    OOBJPRINT:SAY( 1560 + NLIN , 2100 ,  TRANSFORM(NPESOBRU  ,"@E 999,999,999.999" )                                    , OFONT10   , 100 )                                                
	    OOBJPRINT:SAY( 1560 + NLIN , 2285 ,  "TON"                                                 , OFONT10   , 100 )                                    
	
	    NLINFIM := NLIN + (050 * LEN(ATRANSP))
	    OOBJPRINT:BOX( 1600 + NLIN , 0030, 1660 + NLINFIM, 2370)
	    OOBJPRINT:SAY( 1610 + NLIN , 0040 ,  "CONJUNTO TRANSPORTADOR:"                        , OFONT10   , 100 )                                        
	        
	    FOR NX := 1 TO LEN(ATRANSP) 
	        OOBJPRINT:SAY( 1650 + NLIN , 070 ,  ALLTRIM(ATRANSP[NX])                         , OFONT10   , 100 )
	        NLIN:=NLIN+050
	    NEXT
	
		CTIPOPAG:=FTRAZCBOX(ZA6->ZA6_TIPPAG,"ZA6_TIPPAG")  //TRAZ SOMENTE O TEXTO DO X3_CBOX DO CAMPO INFORMADO
	    
	    NLIN:=NLINFIM
	    OOBJPRINT:BOX( 1660 + NLIN , 0030, 1710 + NLIN, 2370)
	    OOBJPRINT:SAY( 1670 + NLIN , 0040 ,  "CONDIÇÃO DE PAGAMENTO:"                         , OFONT10   , 100 )                                        
	    OOBJPRINT:SAY( 1670 + NLIN , 0410 ,  ALLTRIM(SE4->E4_DESCRI)+" "+CTIPOPAG             , OFONT10   , 100 )                                                
	  
	    OOBJPRINT:BOX( 1710 + NLIN , 0030, 2000 + NLIN, 2370)
	
	 //	OFONT10    := TFONT():NEW("COURIER NEW"     ,08,08,,.T.,,,,,.F.)   // NEGRITO
		NSAY1:=0040
		NSAY2:=0410
		NSAY3:=0770
		NSAY4:=1130
		NSAY5:=1490
		NSAY6:=1950
		
		NGET1:=0210
		NGET2:=0580
		NGET3:=0920
		NGET4:=1280
		NGET5:=1710
		NGET6:=2150
		//  
	
		//1- LINHA-NOVOS CAMPO 26/08/13
	    OOBJPRINT:SAY( 1740 + NLIN , NSAY1,  "DIAS VAZIO:",OFONT10,100)
	    OOBJPRINT:SAY( 1740 + NLIN , NGET1,  TRANSFORM(NVALDIASV ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                
	                                           
	    OOBJPRINT:SAY( 1740 + NLIN , NSAY2,  "DIAS CARREGADO:",OFONT10,100)
	    OOBJPRINT:SAY( 1740 + NLIN , NGET2,  TRANSFORM(NVALDIASC    ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                
	        
	    OOBJPRINT:SAY( 1740 + NLIN , NSAY3,  "KM VAZIO:",OFONT10,100)
	    OOBJPRINT:SAY( 1740 + NLIN , NGET3,  TRANSFORM(NKMV    ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                
	        
	    OOBJPRINT:SAY( 1740 + NLIN , NSAY4,  "KM CARREGADO:",OFONT10,100)
	    OOBJPRINT:SAY( 1740 + NLIN , NGET4,  TRANSFORM(NKMC    ,"@E 999,999,999.99")    , OFONT10   , 100 )                                                                                            
	
		OOBJPRINT:SAY( 1740 + NLIN , NSAY5,  "VALOR FRETE:", OFONT10,100)
	    OOBJPRINT:SAY( 1740 + NLIN , NGET5,  TRANSFORM(NFRETE  ,"@E 999,999,999.99")         , OFONT10   , 100 )
	
	    OOBJPRINT:BOX( 2100 + NLIN , 0030, 2900 + NLIN, 2370)    
	    OOBJPRINT:SAY( 2160 + NLIN , 1050 ,  "OBSERVAÇÕES"                                     , OFONT5   , 100 )        
	    
	    OOBJPRINT:BOX( 2200 + NLIN , 0030, 2800 + NLIN, 2370)    
	
	    XT := MLCOUNT(ZA7->ZA7_OBS,130)   
	    
	    NLINOBS := 2800
	    FOR I:=1 TO XT
		    OOBJPRINT:SAY( NLINOBS , 0060 ,  MEMOLINE(ZA7->ZA7_OBS ,130, I )                   , OFONT10   , 100 ) 
	        IF NLINOBS > 3350
	           OOBJPRINT:ENDPAGE()        
	           OOBJPRINT:STARTPAGE()
	           OOBJPRINT:BOX( 0100 , 0050 , 3000 , 2370)    
	           NLINOBS := 150
	        ENDIF
	        NLINOBS := NLINOBS + 50
	    NEXT

		OOBJPRINT:SAY( NLINOBS , 0060 ,  COBSG , OFONT10   , 100 )     
    	
    	ZA7->(DBSKIP())
    	OOBJPRINT:ENDPAGE()
    ENDDO*/
    
	FQ5->(DBSKIP())
 //	FPRNASTDET(OOBJPRINT)	//   CHAMA EMISSÃO DA ÚLTIMA PÁGINA COM OS DADOS DA BASE DE CÁLCULO
ENDDO 

RETURN



// ======================================================================= \\
STATIC FUNCTION FTRAZCBOX(CCOD,CCAMPO)  
// ======================================================================= \\
// --> TRAZ SOMENTE O TEXTO DO X3_CBOX DO CAMPO INFORMADO 
LOCAL NPOS,CCOMBO,CRET

CRET   := CCOD
CCOMBO := ALLTRIM(GETSX3CACHE(CCAMPO,"X3_CBOX"))
NPOS   := AT(CRET+"=",CCOMBO)

IF NPOS>0
	CRET := SUBSTR(CCOMBO,NPOS+2,LEN(CCOMBO))
	NPOS := AT(";",CRET)
	IF NPOS>0
		CRET := SUBSTR(CRET,1,NPOS-1) 
	ENDIF
ENDIF

RETURN(CRET)



// ======================================================================= \\
STATIC FUNCTION TELAOBS()
// ======================================================================= \\

LOCAL ODLG := NIL
LOCAL CRET := OLBXITENS:AARRAY[OLBXITENS:NAT,01]

IF CRET <> "TODAS" 

DBSELECTAREA("FQ5")
DBSETORDER(9)
MSSEEK(XFILIAL("FQ5") + CRET )   ; COBSG := FQ5->FQ5_OBSCOM

DEFINE MSDIALOG ODLG TITLE "OBSERVAÇÃO COMPLEMENTAR" FROM 000,000 TO 025,055 OF OMAINWND 
	@ 008,010 SAY OEMTOANSI("OBSERVAÇÃO COMPLEMENTAR") OF ODLG PIXEL 
	@ 014,010 GET OOBSG VAR COBSG  SIZE 200,130 OF ODLG PIXEL MEMO
    @ 160,010 BUTTON OBUTOBS PROMPT "IMPRIMIR" SIZE 80,20 ACTION ODLG:END() OF ODLG PIXEL   	
ACTIVATE DIALOG ODLG CENTERED 

ENDIF

RETURN CRET



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³FPRNASTDET º AUTOR ³ IT UP BUSINESS     º DATA ³ 28/04/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ IMPRIME FOLHA ANEXA COM OS DETALHES DA BASE DE CÁLCULO     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ EMISSÃO DE AST                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// --> NÃO EXISTE CHAMADA DESTA FUNÇÃO !
/*
STATIC FUNCTION FPRNASTDET(OPRINT)

LOCAL NI
LOCAL NLIN     := 200
LOCAL NCOL     := 50
LOCAL NDESPTOT := 0
LOCAL OFONT10  := TFONT():NEW("LUCIDA CONSOLE",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
LOCAL OFONT10N := TFONT():NEW("LUCIDA CONSOLE",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
LOCAL OFONT12  := TFONT():NEW("LUCIDA CONSOLE",9,12,.T.,.T.,5,.T.,5,.T.,.F.)	// NEGRITO
LOCAL ACPO
LOCAL APICTURE := {"@E 99,999,999,999.99","@E 9,999,999,999,999"}

IF ! FQ8->(DBSEEK(XFILIAL("FQ8") + FP0->FP0_PROJET, .T.))
	MSGALERT("EMISSÃO BASE DE CÁLCULO: PROJETO NÃO ENCONTRADO!","GPO - LOCI024.PRW") 
	RETURN NIL
ENDIF

ACPO :=       {{"LSR"                   , FQ8->FQ8_VALLSR, 1},;
               {"EQUIP. AUXILIARES"     , FQ8->FQ8_VALAUX, 1},;
               {"PRE"                   , FQ8->FQ8_VALPRE, 1},;
               {"PRF"                   , FQ8->FQ8_VALPRF, 1},;
               {"TAP"                   , FQ8->FQ8_VALTAP, 1},;
               {"TUV"                   , FQ8->FQ8_VALTUV, 1},;
               {"BATEDOR CREDENC."      , FQ8->FQ8_VALESC, 1},;
               {"PEDÁGIO"               , FQ8->FQ8_VALPED, 1},;
               {"BLOQUEIO / INVERSÃO"   , FQ8->FQ8_VALINV, 1},;
               {"LAUDO IPT"             , FQ8->FQ8_VALIPT, 1},;
               {"ACOMP. TÉCNICO"        , FQ8->FQ8_VALACO, 1},;
               {"ACOMP. CET"            , FQ8->FQ8_VALCET, 1},;
               {"SEMAFÓRICA"            , FQ8->FQ8_VALSEM, 1},;
               {"TV A CABO"             , FQ8->FQ8_VALTVA, 1},;
               {"CIA. TELEFÔNICA"       , FQ8->FQ8_VALTEL, 1},;
               {"INSTRUMENTAÇÃO"        , FQ8->FQ8_INSTRU, 1},;
               {"BALSA"                 , FQ8->FQ8_BALSA , 1},;
               {"DESPACHANTE DTA"       , FQ8->FQ8_DESDTA, 1},;
               {"MONTAGEM / DESMONTAGEM", FQ8->FQ8_MONDES, 1},;
               {"MOB. ENCARRETADO"      , FQ8->FQ8_MODENC, 1},;
               {"DESMOB. ENCARRETADO"   , FQ8->FQ8_DMOENC, 1},;
               {"CAVALO EXTRA"          , FQ8->FQ8_VALCON, 1},;
               {"GRATIFICAÇÃO"          , FQ8->FQ8_VALADI, 1},;
               {""                      , 0                 },;
               {""                      , 0                 },;
               {"DESPESAS TOTAIS"       , 0              , 1},;
               {"DIAS CARREGADO"        , 0              , 2},;
               {"DIAS VAZIO"            , 0              , 2} }

AEVAL(ACPO, {|X|, NDESPTOT += X[2]})				// SOMA VALORES P/ DESPESAS TOTAIS EM VARIÁVEL
ACPO[ASCAN(ACPO,{|X|X[1]=="DESPESAS TOTAIS"}), 2] := NDESPTOT	// ATUALIZA MATRIZ COM DESPESAS TOTAIS

FP8->(DBSETORDER(1))  								// FP8_FILIAL+FP8_PROJET+FP8_OBRA+FP8_SEQTRA+FP8_SEQCAR+FP8_SEQCON
FP8->(DBSEEK(XFILIAL("FP8")+FP0->FP0_PROJET, .T.))
WHILE ! FP8->(EOF()) .AND. FP8->FP8_FILIAL+FP8->FP8_PROJET == XFILIAL("FP8")+FP0->FP0_PROJET
	ACPO[ASCAN(ACPO,{|X|X[1]=="DIAS CARREGADO"}), 2] += FP8->FP8_DIASV	// ATUALIZA MATRIZ COM DIAS CARREGADO
	ACPO[ASCAN(ACPO,{|X|X[1]=="DIAS VAZIO"})    , 2] += FP8->FP8_DIASC	// ATUALIZA MATRIZ COM DIAS VAZIO
	FP8->(DBSKIP())
ENDDO 

 //	OPRINT:=TMSPRINTER():NEW( "PLANILHA BASE DE CÁLCULO - " + FQ8->FQ8_PROJET  )
 //	OPRINT:SETPORTRAIT() 							// OU SETLANDSCAPE()
OPRINT:STARTPAGE()   								// INICIA UMA NOVA PÁGINA

OPRINT:LINE(NLIN, NCOL, NLIN, 2200)					// LINHA SUPERIOR PÁGINA
NLIN += 5

OPRINT:SAYBITMAP(NLIN, NCOL+10, "LOGO.BMP", 459, 154)

OPRINT:SAY(NLIN+70,NCOL+700,"PLANILHA BASE DE CÁLCULO - " + FQ8->FQ8_PROJET,OFONT12)
NLIN += 154 + 10

OPRINT:LINE(NLIN, NCOL, NLIN, 2200)					// LINHA INFERIOR CABEÇALHO
NLIN += 20

OPRINT:SAY(NLIN, NCOL+  10,"DESCRIÇÃO",OFONT10N)
OPRINT:SAY(NLIN, NCOL+1380,"VALOR"    ,OFONT10N)
NLIN += 50

OPRINT:LINE(NLIN, NCOL, NLIN, 2200)					// LINHA INFERIOR CABEÇALHO
NLIN += 30

FOR NI:=1 TO LEN(ACPO)
	OPRINT:SAY(NLIN, NCOL+10, ACPO[NI,1], OFONT10)
	IF !EMPTY(ACPO[NI,1])
		OPRINT:SAY(NLIN, NCOL+1150, TRANSFORM(ACPO[NI,2], APICTURE[ ACPO[NI,3] ] ), OFONT10)
	ENDIF
	NLIN += 40
	OPRINT:LINE(NLIN, NCOL, NLIN, 2200)				// LINHA HORIZONTAL
	NLIN += 10
NEXT NI 

NLIN += 40

OPRINT:LINE(200, NCOL, NLIN, NCOL)				// LINHA VERTICAL ESQ
OPRINT:LINE(200, NCOL+2150, NLIN, NCOL+2150)	// LINHA VERTICAL DIR
OPRINT:LINE(NLIN, NCOL, NLIN, NCOL+2150)		// LINHA INFERIOR PÁGINA

OPRINT:ENDPAGE()     								// FINALIZA A PÁGINA
//	OPRINT:SETUP()       							// ABRE OPCOES PARA O USUARIO
//	OPRINT:PREVIEW()     							// VISUALIZA ANTES DE IMPRIMIR

RETURN NIL
*/
