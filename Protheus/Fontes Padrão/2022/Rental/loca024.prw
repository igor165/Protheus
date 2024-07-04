#INCLUDE "loca024.ch" 
/*/{PROTHEUS.DOC} LOCA024.PRW
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"                                                                                                   
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSMGADD.CH"                                                                                                              

FUNCTION LOCA024()
LOCAL AAREA       := GETAREA() 
LOCAL CFILTRO     := "" 
LOCAL CQRYLEG     := 0 
LOCAL CRET00      := ""
LOCAL CRET10      := ""
LOCAL CRET20      := ""
LOCAL CRET30      := ""
LOCAL CRET40      := ""
LOCAL CRET50      := ""
LOCAL CRET60      := ""
LOCAL CRET70      := ""

//PRIVATE NREG	  := ST9->( RECNO() )
PRIVATE CCADASTRO := OEMTOANSI(STR0001) //"GERENCIAMENTO DE BENS"
PRIVATE AROTINA   := {} 
PRIVATE ACORES	  := {}
/*
EXEMPLO
TQY_STATUS	TQY_DESTAT                    	FQ5_STTCTR
----------  ----------------------------    ----------
00        	DISPONIVEL                    	00
DI        	DISPONIVEL (DI)               	00
10        	CONTRATO GERADO               	10
20        	NF DE REMESSA GERADA          	20
30        	EM TRANSITO PARA ENTREGA      	30
40        	ENTREGUE                      	40
50        	RETORNO DE LOCACAO            	50
RL        	RETORNO DE LOCACAO (RL)       	50
60        	NF DE RETORNO GERADA          	60
70        	EM MANUTENÇÃO                 	70
*/

IF SELECT("TMPLEG") > 0 
	TMPLEG->( DBCLOSEAREA() ) 
ENDIF 

CQRYLEG := " SELECT TQY_STATUS , TQY_STTCTR FROM "+ RETSQLNAME("TQY") +" WHERE TQY_STTCTR IN ('00','10','20','30','40','50','60') AND D_E_L_E_T_ = '' "	
TCQUERY CQRYLEG NEW ALIAS "TMPLEG"

WHILE TMPLEG->(!EOF())
	IF     TMPLEG->TQY_STTCTR = "00" 		// --> 00 - DISPONIVEL               - VERDE 
		CRET00 := CRET00 + TMPLEG->TQY_STATUS + "*" 
	ELSEIF TMPLEG->TQY_STTCTR = "10" 		// --> 10 - CONTRATO GERADO          - AMARELO 
		CRET10 := CRET10 + TMPLEG->TQY_STATUS + "*" 
	ELSEIF TMPLEG->TQY_STTCTR = "20" 		// --> 20 - NF DE REMESSA GERADA     - AZUL 
		CRET20 := CRET20 + TMPLEG->TQY_STATUS + "*" 
	ELSEIF TMPLEG->TQY_STTCTR = "30" 		// --> 30 - EM TRANSITO PARA ENTREGA - CINZA 
		CRET30 := CRET30 + TMPLEG->TQY_STATUS + "*" 
	ELSEIF TMPLEG->TQY_STTCTR = "40" 		// --> 40 - ENTREGUE                 - LARANJA 
		CRET40 := CRET40 + TMPLEG->TQY_STATUS + "*" 
	ELSEIF TMPLEG->TQY_STTCTR = "50" 		// --> 50 - RETORNO DE LOCACAO       - PRETO 
		CRET50 := CRET50 + TMPLEG->TQY_STATUS + "*" 
	ELSEIF TMPLEG->TQY_STTCTR = "60" 		// --> 60 - NF DE RETORNO GERADA     - VERMELHO 
		CRET60 := CRET60 + TMPLEG->TQY_STATUS + "*" 
	ELSEIF TMPLEG->TQY_STTCTR = "70" 		// --> 70 - EM MANUTENCAO            - ******** 
		CRET70 := CRET70 + TMPLEG->TQY_STATUS + "*" 
	ENDIF 
	TMPLEG->(DBSKIP()) 
ENDDO

ACORES := { {'ST9->T9_STATUS $ "'+CRET00+'"' , "BR_VERDE"   },;
		    {'ST9->T9_STATUS $ "'+CRET10+'"' , "BR_AMARELO" },;
		    {'ST9->T9_STATUS $ "'+CRET20+'"' , "BR_AZUL"    },;
		    {'ST9->T9_STATUS $ "'+CRET50+'"' , "BR_PRETO"   },;
		    {'ST9->T9_STATUS $ "'+CRET60+'"' , "BR_VERMELHO"}}
  		    // {'ST9->T9_STATUS $ "'+CRET30+'"' , "BR_CINZA"   },;  // Removido por Frank a pedido do Lui em 06/07/21
		    // {'ST9->T9_STATUS $ "'+CRET40+'"' , "BR_LARANJA" },;  // Removido por Frank a pedido do Lui em 06/07/21
			//{'ST9->T9_STATUS $ "'+CRET70+'"' , "BR_PINK"    } }  // Removido por Frank a pedido do Lui em 06/07/21

BEGIN SEQUENCE
	/*
	IF PERGPARAM() 
		CFILTRO += " T9_CODBEM IN ( SELECT ST9.T9_CODBEM " 
		CFILTRO += "                FROM "+RETSQLNAME("ST9")+" ST9 (NOLOCK) "
		CFILTRO += "                       LEFT JOIN "+RETSQLNAME("FQ4")+" ZZZ (NOLOCK) ON ZZZ.D_E_L_E_T_ = ''  AND  ZZZ.FQ4_CODBEM = ST9.T9_CODBEM  "
		CFILTRO += "                       LEFT JOIN "+RETSQLNAME("SHB")+" SHB (NOLOCK) ON SHB.D_E_L_E_T_ = ''  AND  SHB.HB_COD     = ST9.T9_CENTRAB " 
		CFILTRO += "                WHERE  ST9.D_E_L_E_T_ = '' " 
		CFILTRO += "                  AND  ST9.T9_CENTRAB BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " 
		CFILTRO += "                  AND  ST9.T9_CODBEM  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " 
		CFILTRO += "                  AND  ST9.T9_CODFAMI BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " 
		CFILTRO += "                  AND  ST9.T9_TIPMOD  BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " 
		CFILTRO += "                  AND  ST9.T9_STATUS  BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " 
		CFILTRO += "                  AND  SHB.HB_COD_MUN BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' "
		CFILTRO += "              ) " 
	 //	CFILTRO += " AND ST9.T9_TIPOSE IN ('E') ) " 
	ENDIF 
	*/	
	AADD( AROTINA , {STR0002	 , "AXPESQUI"	 , 0 , , 1 , NIL} )  //"Pesquisar"
	AADD( AROTINA , {STR0003	     , "LOCA02402"	 , 0 , , 6 , NIL} )  //"Consulta"
	AADD( AROTINA , {STR0004		 , "LOCA02401()"  , 0 , , 7 , NIL} )  //"Legenda"
	AADD( AROTINA , {STR0005 , "LOCR009()" , 0 , , 7 , NIL} )  //"Quadro resumo"

	IF EXISTBLOCK("LC024ROT") 						// --> PONTO DE ENTRADA PARA ALTERAÇÃO DE CORES DA LEGENDA
		aRotina := EXECBLOCK("LC024ROT" , .T. , .T. , {AROTINA}) 
	ENDIF
	
 //	MBROWSE( <NLINHA1>, <NCOLUNA1>, <NLINHA2>, <NCOLUNA2>, <CALIAS>, <AFIXE>, <CCPO>, <NPAR>, <CCORFUN>, <NCLICKDEF>, <ACOLORS>, <CTOPFUN>, <CBOTFUN>, <NPAR14>, <BINITBLOC>, <LNOMNUFILTER>, <LSEEALL>, <LCHGALL>, <CEXPRFILTOP>, <NINTERVAL>, <UPAR22>, <UPAR23> )
	MBROWSE( , , , , "ST9" , , , , , 02 , ACORES , , , , , , , , CFILTRO ) 
	
END SEQUENCE

RESTAREA( AAREA )

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUNÇÃO	 ³ LEG009    º AUTOR ³ IT UP BUSINESS     º DATA ³ 07/09/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ LEGENDA.                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LOCA02401()

LOCAL _ALEGENDA := {}

AADD(_ALEGENDA , {"BR_VERDE"    , STR0006	   })  //"Disponível"
AADD(_ALEGENDA , {"BR_AMARELO"  , STR0007})  //"Contrato gerado"
AADD(_ALEGENDA , {"BR_AZUL"     , STR0008 })  //"Remessa gerada"
//AADD(_ALEGENDA , {"BR_CINZA"    , "Em trânsito"	   }) // Removido por Frank a pedido do Lui em 06/07/21
//AADD(_ALEGENDA , {"BR_LARANJA"  , "Entregue"	   }) // Removido por Frank a pedido do Lui em 06/07/21 
AADD(_ALEGENDA , {"BR_PRETO"    , STR0009})  //"Retorno locação"
AADD(_ALEGENDA , {"BR_VERMELHO" , STR0010 })  //"Retorno gerado"
//AADD(_ALEGENDA , {"BR_PINK"     , "Em manutenção"  })  // Removido por Frank a pedido do Lui em 06/07/21

BRWLEGENDA("STATUS" , STR0004 , _ALEGENDA)  //"LEGENDA"

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUNÇÃO    ³ LOC009A   º AUTOR ³ IT UP BUSINESS     º DATA ³ 07/09/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ "CONSULTA"                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//FUNCTION LOCA02402(CALIAS , NREG , NOPC)
FUNCTION LOCA02402(CALIAS , NREG )
LOCAL NOPC		:= 2
LOCAL NUSADO 	:= 0
LOCAL ABUTTONS 	:= {}
LOCAL AFIELD	:= {}
LOCAL APOS 		:= {000,000,080,400}
LOCAL LMEMORIA 	:= .T.
LOCAL LCREATE	:= .T.
LOCAL NSUPERIOR := 081
LOCAL NESQUERDA := 000
LOCAL NINFERIOR := 250
LOCAL NDIREITA 	:= 400
LOCAL CLINOK 	:= "ALLWAYSTRUE"
LOCAL CTUDOOK 	:= "ALLWAYSTRUE"
LOCAL CINICPOS 	:= "FQ4_CODBEM"
LOCAL NFREEZE 	:= 000
LOCAL NMAX 		:= 999
LOCAL CFIELDOK 	:= "ALLWAYSTRUE"
LOCAL CSUPERDEL := ""
LOCAL CDELOK 	:= "ALLWAYSFALSE"
LOCAL AHEADER 	:= {}
LOCAL ACOLS 	:= {}
LOCAL AALTERGDA := {}
LOCAL NX 		:= 0
LOCAL OSIZE
LOCAL NRECNOZZZ := 0
LOCAL CCABEC    := "FQ4_DESTAT#FQ4_STATUS#FQ4_CODBEM#FQ4_CODFAMI#FQ4_TIPMOD#FQ4_FABRIC#FQ4_NOME#FQ4_SUBLOC#FQ4_POSCON#FQ4_CENTRAB#FQ4_NOMTRA#FQ4_OS#FQ4_TPSERV"
//LOCAL NMODELO    := 3
//LOCAL LPROPERTY  := .F.
//LOCAL LCOLUMN    := .F.
//LOCAL LNOFOLDER  := .F. 
//LOCAL ACPOENCH   := {} 
//LOCAL AALTERENCH := {} 
//LOCAL ACPOGDA    := {} 
//LOCAL LF3        := .F. 

PRIVATE CATELA 	:= ""
PRIVATE ODLG
PRIVATE OGETD
PRIVATE OENCH
PRIVATE ATELA[0][0]
PRIVATE AGETS[0]

CALIAS 	:= "FQ4"

NUSADO  := 0
AHEADER := {}
(LOCXCONV(1))->( DBSETORDER(1) )
(LOCXCONV(1))->( DBSEEK(CALIAS) )
WHILE !(LOCXCONV(1))->(EOF()).AND.(GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") == CALIAS)
	IF X3USO( &(LOCXCONV(3)) ) .AND. CNIVEL >= GetSx3Cache(&(LOCXCONV(2)),"X3_NIVEL")
		NUSADO++
		AADD(AHEADER , { ALLTRIM(GetSx3Cache(&(LOCXCONV(2)),"X3_TITULO")) ,;      
		 				 GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO") ,;    
						 GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE") , ; 
						 GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO") ,;  
						 GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL") ,; 
						 "ALLWAYSTRUE()" , ;
						 GetSx3Cache(&(LOCXCONV(2)),"X3_USADO")   ,;   
						 GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO")    ,;    
						 GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") ,;   
						 GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") } )  
	//	AADD(ACPOENCH, SX3->X3_CAMPO )
		IF ALLTRIM(&(LOCXCONV(2))) $ CCABEC 
			AADD( AFIELD , { X3TITULO()      , ; 
						     GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")   , ;  
						     GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO")    , ; 
						     GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO") , ;  
						     GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL") , ;   
						     GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE") , ;  
						     GetSx3Cache(&(LOCXCONV(2)),"X3_VALID")   , ; 
						     .F.             , ; 
						     GetSx3Cache(&(LOCXCONV(2)),"X3_NIVEL")   , ; 
						     GetSx3Cache(&(LOCXCONV(2)),"X3_RELACAO") , ; 
						     GetSx3Cache(&(LOCXCONV(2)),"X3_F3")      , ;  
						     GetSx3Cache(&(LOCXCONV(2)),"X3_WHEN")    , ;  
						     .F.             , ;
						     .F.             , ;
						     GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX")    , ; 
						     IIF(! EMPTY(GetSx3Cache(&(LOCXCONV(2)),"X3_FOLDER")) , VAL(GetSx3Cache(&(LOCXCONV(2)),"X3_FOLDER")), GetSx3Cache(&(LOCXCONV(2)),"X3_FOLDER")),;  
						     .F.             , ; 
						     GetSx3Cache(&(LOCXCONV(2)),"X3_PICTVAR") , ; 
						     GetSx3Cache(&(LOCXCONV(2)),"X3_TRIGGER") } ) 
		ENDIF
	ENDIF	
	(LOCXCONV(1))->( DBSKIP() )
ENDDO
	
IF NOPC==2 										// INCLUIR	
	ACOLS  := {} 
	ST9->( DBGOTO(NREG) )

	IF SELECT("TMPFQ4") > 0
		TMPFQ4->( DBCLOSEAREA() )
	ENDIF 
	CQUERY := " SELECT R_E_C_N_O_ RECNOZZZ, * FROM "+ RETSQLNAME(CALIAS) +" WHERE FQ4_CODBEM = '" + ST9->T9_CODBEM + "' AND D_E_L_E_T_ = '' "	
	TCQUERY CQUERY NEW ALIAS "TMPFQ4"
	
	WHILE TMPFQ4->( ! EOF() )
		IIF( NRECNOZZZ < TMPFQ4->RECNOZZZ , NRECNOZZZ := TMPFQ4->RECNOZZZ , NRECNOZZZ ) 
		AADD(ACOLS,ARRAY(NUSADO+1))
		FOR NX:=1 TO NUSADO
			ACOLS[LEN(ACOLS),NX] := FIELDGET(FIELDPOS( (AHEADER[NX,2]) )) //FIELDGET(FIELDPOS(( "TMPFQ4->" + (AHEADER[1,2])) ))
			//04/10/2022 - Jose Eulalio - SIGALOC94-524 - Formato de data no grid da consulta de gerenciamento de bens
			//converte em Data quando necessário
			If TamSx3((AHEADER[NX,2]))[3] == "D"
				ACOLS[LEN(ACOLS),NX] := StoD(ACOLS[LEN(ACOLS),NX])
			EndIf
		NEXT NX 
		ACOLS[LEN(ACOLS),NUSADO+1] := .F.
		TMPFQ4->( DBSKIP() )
	ENDDO
	TMPFQ4->( DBCLOSEAREA() )
ENDIF 

OSIZE := FWDEFSIZE():NEW( .T.)
OSIZE:ADDOBJECT("CENCH" , 100 , 25 , .T. , .T.) // ENCHOICE
OSIZE:ADDOBJECT("CGETD" , 100 , 75 , .T. , .T.) // ENCHOICE
OSIZE:LPROP := .T.
OSIZE:PROCESS() 								// DISPARA OS CALCULOS 

(CALIAS)->(DBGOTO(NRECNOZZZ))
REGTOMEMORY(CALIAS, .F.)

ODLG := MSDIALOG():NEW(OSIZE:AWINDSIZE[1],OSIZE:AWINDSIZE[2],OSIZE:AWINDSIZE[3],OSIZE:AWINDSIZE[4], CCADASTRO,,,,,,,,,.T.)
	NPOS      := ASCAN( OSIZE:APOSOBJ, { |X| ALLTRIM(X[7]) == "CENCH" } )
	APOS      := { OSIZE:APOSOBJ[NPOS][1],OSIZE:APOSOBJ[NPOS][2],OSIZE:APOSOBJ[NPOS][3],OSIZE:APOSOBJ[NPOS][4], }
	OENCH     := MSMGET():NEW(,,NOPC,/*ACRA*/,/*CLETRAS*/,/*CTEXTO*/,/*ACPOENCH*/,APOS,/*AALTERENCH*/,/*NMODELO*/,/*NCOLMENS*/,/*CMENSAGEM*/, /*CTUDOOK*/,ODLG,/*LF3*/,LMEMORIA,/*LCOLUMN*/,/*CATELA*/,/*LNOFOLDER*/,/*LPROPERTY*/,AFIELD,/*AFOLDER*/,LCREATE,/*LNOMDISTRETCH*/,/*CTELA*/)
	    
	NPOS      := ASCAN( OSIZE:APOSOBJ, { |X| ALLTRIM(X[7]) == "CGETD"} )
	NSUPERIOR := OSIZE:APOSOBJ[NPOS][1]
	NESQUERDA := OSIZE:APOSOBJ[NPOS][2]
	NINFERIOR := OSIZE:APOSOBJ[NPOS][3]
	NDIREITA  := OSIZE:APOSOBJ[NPOS][4]
	OGETD     := MSNEWGETDADOS():NEW(NSUPERIOR, NESQUERDA , NINFERIOR , NDIREITA , NOPC , CLINOK  , CTUDOOK ,  CINICPOS   , AALTERGDA , NFREEZE , ; 
							         NMAX     , CFIELDOK  , CSUPERDEL , CDELOK   , ODLG , AHEADER , ACOLS   , /*UCHANGE*/ , /*CTELA*/ )
	ODLG:BINIT := {|| ENCHOICEBAR(ODLG , {||ODLG:END()} , {||ODLG:END()},,@ABUTTONS,,,,,.F.)} 
	ODLG:LCENTERED := .T.
ODLG:ACTIVATE()

RETURN 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ PERGPARAM º AUTOR ³ IT UP BUSINESS     º DATA ³ 09/02/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ PERGUNTA DO RELATÓRIO.                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
STATIC FUNCTION PERGPARAM()

LOCAL APERGS    := {}
LOCAL ARET      := {}
LOCAL LRET      := .F.
LOCAL ACOMBO    := {"1-SINTETICO","2-ANALITICO"}
LOCAL NX        := 0 

LOCAL CCENTRABI := IIF(FIELDPOS("T9_CENTRAB"	)>0,	SPACE(		GETSX3CACHE("T9_CENTRAB","X3_TAMANHO")),SPACE(10))
LOCAL CCENTRABF := IIF(FIELDPOS("T9_CENTRAB"	)>0,REPLICATE("Z",	GETSX3CACHE("T9_CENTRAB","X3_TAMANHO")),REPLICATE("Z",10))
LOCAL CCODBEMI  := IIF(FIELDPOS("T9_CODBEM"		)>0,	SPACE(		GETSX3CACHE("T9_CODBEM"	,"X3_TAMANHO")),SPACE(10))
LOCAL CCODBEMF  := IIF(FIELDPOS("T9_CODBEM"		)>0,REPLICATE("Z",	GETSX3CACHE("T9_CODBEM"	,"X3_TAMANHO")),REPLICATE("Z",10))
LOCAL CCODFAMI  := IIF(FIELDPOS("T9_CODFAMI"	)>0,	SPACE(		GETSX3CACHE("T9_CODFAMI","X3_TAMANHO")),SPACE(10))
LOCAL CCODFAMF  := IIF(FIELDPOS("T9_CODFAMI"	)>0,REPLICATE("Z",	GETSX3CACHE("T9_CODFAMI","X3_TAMANHO")),REPLICATE("Z",10))
LOCAL CTIPMODI  := IIF(FIELDPOS("T9_TIPMOD"		)>0,	SPACE(		GETSX3CACHE("T9_TIPMOD"	,"X3_TAMANHO")),SPACE(10))
LOCAL CTIPMODF  := IIF(FIELDPOS("T9_TIPMOD"		)>0,REPLICATE("Z",	GETSX3CACHE("T9_TIPMOD"	,"X3_TAMANHO")),REPLICATE("Z",10))
LOCAL CSTATUSI  := IIF(FIELDPOS("T9_STATUS"		)>0,	SPACE(		GETSX3CACHE("T9_STATUS"	,"X3_TAMANHO")),SPACE(10))
LOCAL CSTATUSF  := IIF(FIELDPOS("T9_STATUS"		)>0,REPLICATE("Z",	GETSX3CACHE("T9_STATUS"	,"X3_TAMANHO")),REPLICATE("Z",10))
LOCAL CCOD_MUNI := IIF(FIELDPOS("HB_COD_MUN"	)>0,	SPACE(		GETSX3CACHE("HB_COD_MUN","X3_TAMANHO")),SPACE(10))
LOCAL CCOD_MUNF := IIF(FIELDPOS("HB_COD_MUN"	)>0,REPLICATE("Z",	GETSX3CACHE("HB_COD_MUN","X3_TAMANHO")),REPLICATE("Z",10))

AADD( APERGS , {1,RETTITLE("T9_CENTRAB"),CCENTRABI , PESQPICT("ST9","T9_CENTRAB"),".T.","SHB",".T.", 50 ,.F.})
AADD( APERGS , {1,RETTITLE("T9_CENTRAB"),CCENTRABF , PESQPICT("ST9","T9_CENTRAB"),".T.","SHB",".T.", 50 ,.T.})
AADD( APERGS , {1,RETTITLE("T9_CODBEM" ),CCODBEMI  , PESQPICT("ST9","T9_CODBEM"	),".T.","ST9",".T.", 50 ,.F.})
AADD( APERGS , {1,RETTITLE("T9_CODBEM" ),CCODBEMF  , PESQPICT("ST9","T9_CODBEM"	),".T.","ST9",".T.", 50 ,.T.})
AADD( APERGS , {1,RETTITLE("T9_CODFAMI"),CCODFAMI  , PESQPICT("ST9","T9_CODFAMI"),".T.","ST6",".T.", 50 ,.F.})
AADD( APERGS , {1,RETTITLE("T9_CODFAMI"),CCODFAMF  , PESQPICT("ST9","T9_CODFAMI"),".T.","ST6",".T.", 50 ,.T.})
AADD( APERGS , {1,RETTITLE("T9_TIPMOD" ),CTIPMODI  , PESQPICT("ST9","T9_TIPMOD"	),".T.","TQR",".T.", 50 ,.F.})
AADD( APERGS , {1,RETTITLE("T9_TIPMOD" ),CTIPMODF  , PESQPICT("ST9","T9_TIPMOD"	),".T.","TQR",".T.", 50 ,.T.})
AADD( APERGS , {1,RETTITLE("T9_STATUS" ),CSTATUSI  , PESQPICT("ST9","T9_STATUS"	),".T.","TQY",".T.", 50 ,.F.})
AADD( APERGS , {1,RETTITLE("T9_STATUS" ),CSTATUSF  , PESQPICT("ST9","T9_STATUS"	),".T.","TQY",".T.", 50 ,.T.})
AADD( APERGS , {1,RETTITLE("HB_COD_MUN"),CCOD_MUNI , PESQPICT("ST9","HB_COD_MUN"),".T.","CC2",".T.", 50 ,.F.})
AADD( APERGS , {1,RETTITLE("HB_COD_MUN"),CCOD_MUNF , PESQPICT("ST9","HB_COD_MUN"),".T.","CC2",".T.", 50 ,.T.})
AADD( APERGS , {2 , "TIPO RELATORIO: " , 1 , ACOMBO , 70 , ".T." , .T. }) 	// COMBO

IF PARAMBOX(APERGS , "PARAMETROS " , ARET ,  ,  , .T. ,  ,  ,  ,  , .T. , .T.) 
	FOR NX := 1 TO LEN(ARET)
		&("MV_PAR"+STRZERO(NX,2)) := ARET[NX]
	NEXT NX 
	LRET := .T.
	IF VALTYPE( MV_PAR13 ) == "C"
		IF     "1" $  ALLTRIM(MV_PAR13) 
			MV_PAR13 := 1
		ELSEIF "2" $ ALLTRIM(MV_PAR13) 
			MV_PAR13 := 2
		ENDIF
	ENDIF 
ENDIF

RETURN (LRET)
*/

