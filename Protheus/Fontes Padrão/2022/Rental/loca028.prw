#INCLUDE "loca028.ch" 
/*/{PROTHEUS.DOC} LOCA028.PRW
ITUP BUSINESS - TOTVS RENTAL
TELA PARA VINCULAR UM EQUIPAMENTOS AO FRETE, NA ROTINA DE ROMANEIO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

FUNCTION LOCA028(_CASF , LMSROTAUTO) 
LOCAL _AAREAOLD  := GETAREA()
LOCAL _AAREADTQ  := FQ5->(GETAREA())
LOCAL _AAREASZ0  := FQ2->(GETAREA())
LOCAL _AAREASZ1  := FQ3->(GETAREA())
LOCAL _AAREAZUC  := FQ7->(GETAREA())
LOCAL _AAREAST9  := ST9->(GETAREA())
LOCAL _CERRO	 := ""
LOCAL _CQUERY	 := ""
LOCAL _CNUMROM   := ""
LOCAL CMV_LOCX014 := ""
LOCAL OLISTBOX
LOCAL LUMAOPCAO  := .F.
LOCAL LMARCAITEM := .T.
LOCAL OOK        := LOADBITMAP(GETRESOURCES(),"LBOK")
LOCAL ONO        := LOADBITMAP(GETRESOURCES(),"LBNO")
LOCAL BACAO      := NIL
LOCAL OVINCZAG
LOCAL OCANC
LOCAL _NOPC      := 0
LOCAL NINICIAL   := 0 

PRIVATE _AARRAY  := {}

DEFAULT _CASF 		:= FQ5->FQ5_AS
DEFAULT	LMSROTAUTO 	:= .F.

IF SBM->(FIELDPOS("BM_XACESS")) > 0
	CMV_LOCX014 := LOCA00189()
ELSE
	CMV_LOCX014 := SUPERGETMV("MV_LOCX014",.F.,"")
ENDIF

DBSELECTAREA("FQ5")
FQ5->(DBSETORDER(9))
IF FQ5->(DBSEEK(XFILIAL("FQ5") + _CASF))
	IF FQ5->FQ5_STATUS <> "6" .OR. FQ5->FQ5_TPAS <> "F"
		_CERRO := STR0001 //"ASF NÃO ESTÁ ACEITA OU NÃO É DO TIPO FRETE!"
	ENDIF

	DBSELECTAREA("FQ2")
	FQ2->(DBSETORDER(3))			// FQ2_FILIAL + FQ2_ASF + FQ2_NUM
	IF !FQ2->(DBSEEK(XFILIAL("FQ2") + _CASF)) .AND. EMPTY(_CERRO)
		_CERRO := STR0002 //"ROMANEIO NÃO ENCONTRADO!"

		DBSELECTAREA("FQ7")
		FQ7->(DBSETORDER(3))
		IF FQ7->(DBSEEK(XFILIAL("FQ7") + FQ5->FQ5_VIAGEM))

			FQ2->(DBSETORDER(1))	// FQ2_FILIAL + FQ2_NUM
			_CNUMROM	:= GETSXENUM("FQ2","FQ2_NUM")
			WHILE .T.
				IF FQ2->( DBSEEK(XFILIAL("FQ2") + _CNUMROM) )
					CONFIRMSX8()
					_CNUMROM := GETSXENUM("FQ2","FQ2_NUM")
					LOOP
				ELSE
					EXIT
				ENDIF
			ENDDO

			ROLLBACKSXE()

			FQ2->(DBSETORDER(3))	// FQ2_FILIAL + FQ2_ASF + FQ2_NUM

			IF RECLOCK("FQ2",.T.)
				FQ2->FQ2_FILIAL  := XFILIAL("FQ2")
				FQ2->FQ2_NUM	    := _CNUMROM
				FQ2->FQ2_PROJET  := FQ5->FQ5_SOT
				FQ2->FQ2_OBRA    := FQ5->FQ5_OBRA
				FQ2->FQ2_ASF     := _CASF
				FQ2->FQ2_VIAGEM  := FQ5->FQ5_VIAGEM
				FQ2->FQ2_TPROMA := FQ7->FQ7_TPROMA
				FQ2->FQ2_CLIENT := FQ5->FQ5_CODCLI
				FQ2->FQ2_LOJA    := FQ5->FQ5_LOJA
				FQ2->FQ2_NOMCLI  := ALLTRIM(POSICIONE("SA1",1,XFILIAL("SA1") + FQ5->FQ5_CODCLI + FQ5->FQ5_LOJA,"A1_NOME"))
				FQ2->(MSUNLOCK())
				_CERRO := ""

				//GUARDAR NUMERO DO ROMANEIO NO NOVO CAMPO
				FQ5->(RECLOCK("FQ5", .F.))
				FQ5->FQ5_XROMAN := FQ2->FQ2_NUM
				FQ5->(MSUNLOCK())
			ENDIF
		ENDIF
	ENDIF

ELSE
	_CERRO := "ASF " + ALLTRIM(_CASF) + STR0003 //" NÃO ENCONTRADA!"
ENDIF

IF EMPTY(_CERRO)
	/*
		PROCEDIMENTO PARA SEPARAÇÃO DO QUE É REMESSA E RETORNO DE LOCAÇÃO.
		ESSE PROCEDIMENTO FOI NECESSÁRIO CRIAR POIS A SELEÇÃO DOS ITENS DE RETORNO SERÁ FEITO PELO PEDIDO COMERCIAL.
	*/
	IF .T.	// FQ2->FQ2_TPROMA == "0" 				// --> PROCESSA SOMENTE REMESSA     ( FQ2_TPROMA = 0=EXPEDICAO ; 1=RETORNO ) 
		_CQUERY     += "  SELECT  FPA_PROJET PROJETO , FPA_GRUA CODBEM , ISNULL(T9_NOME,FPA_DESGRU) BEM , "                    + CRLF
		_CQUERY     += "          ISNULL(T6_NOME,FPA_DESGRU) FAMILIA , FPA_SEQGRU , FPA_AS , FPA_PRODUT "                      + CRLF
		_CQUERY     += "  FROM " + RETSQLNAME("FPA")+" ZAG (NOLOCK)"                                                           + CRLF
		_CQUERY     += "  	      INNER JOIN " + RETSQLNAME("FQ5") + " DTQ (NOLOCK) ON  DTQ.FQ5_AS     = ZAG.FPA_AS "          + CRLF
		_CQUERY     += "                                                            AND DTQ.FQ5_STATUS = '6' "                 + CRLF
		_CQUERY     += "                                                            AND DTQ.D_E_L_E_T_ = '' "                  + CRLF
		_CQUERY     += "  	      LEFT  JOIN " + RETSQLNAME("ST9") + " ST9 (NOLOCK) ON  ST9.T9_CODBEM  = ZAG.FPA_GRUA "        + CRLF
		_CQUERY     += "  	                                                        AND ST9.D_E_L_E_T_ = '' "                  + CRLF
		_CQUERY     += "  	      LEFT  JOIN " + RETSQLNAME("ST6") + " ST6 (NOLOCK) ON  ST6.T6_CODFAMI = ST9.T9_CODFAMI "      + CRLF
		_CQUERY     += "  	                                                        AND ST6.D_E_L_E_T_ = '' "                  + CRLF
		_CQUERY     += " WHERE    ZAG.FPA_FILIAL =  '" + FQ5->FQ5_FILORI + "'"                                                 + CRLF
		_CQUERY     += "   AND    ZAG.FPA_PROJET =  '" + FQ5->FQ5_SOT    + "'"                                                 + CRLF
		_CQUERY     += "   AND    ZAG.FPA_OBRA   =  '" + FQ5->FQ5_OBRA   + "'"                                                 + CRLF
		_CQUERY     += "   AND    ZAG.FPA_AS     <> '' "                                                                       + CRLF
		_CQUERY     += "   AND    ZAG.FPA_TIPOSE =  'L' "                                                                      + CRLF
		_CQUERY     += "   AND    ZAG.D_E_L_E_T_ =  '' "                                                                       + CRLF
		IF     (FQ2->FQ2_TPROMA == "0")				// --> REMESSA
			_CQUERY += "   AND    ZAG.FPA_NFREM  =  '' "                                                                       + CRLF
		ELSEIF (FQ2->FQ2_TPROMA == "1")				// --> RETORNO
			_CQUERY += "   AND    ZAG.FPA_NFREM  <> '' "                                                                       + CRLF
			_CQUERY += "   AND    ZAG.FPA_DTPRRT <> '' "                                                                       + CRLF
			_CQUERY += "   AND    ZAG.FPA_NFRET  =  '' "                                                                       + CRLF
		ELSE
			RETURN
		ENDIF
		_CQUERY     += "   AND    NOT EXISTS( SELECT * "                                                                       + CRLF
		_CQUERY     += "                      FROM " + RETSQLNAME("FQ2") + " SZ0 "                                             + CRLF
		_CQUERY     += "                             INNER JOIN " + RETSQLNAME("FQ3") + " SZ1 ON  SZ1.FQ3_FILIAL  = FQ2_FILIAL " + CRLF 
		_CQUERY     += " 		                                                              AND SZ1.FQ3_NUM     = FQ2_NUM "    + CRLF
		_CQUERY     += " 		                                                              AND SZ1.FQ3_ASF     = FQ2_ASF "    + CRLF
		_CQUERY     += " 		                                                              AND SZ1.FQ3_PROJET  = FQ2_PROJET " + CRLF
		_CQUERY     += " 		                                                              AND SZ1.FQ3_OBRA    = FQ2_OBRA "   + CRLF
		_CQUERY     += " 		                                                              AND SZ1.FQ3_AS      = FPA_AS "    + CRLF
		_CQUERY     += " 		                                                              AND SZ1.D_E_L_E_T_ = '' "        + CRLF
		_CQUERY     += "                      WHERE  SZ0.FQ2_FILIAL  = FPA_FILIAL "                                             + CRLF
		_CQUERY     += "                        AND  SZ0.FQ2_ASF     LIKE '%" + SUBSTR(_CASF,1,10) + "%' "                      + CRLF
		_CQUERY     += " 		                AND  SZ0.FQ2_TPROMA = '"+FQ2->FQ2_TPROMA+"' "                                  + CRLF
		_CQUERY     += " 		                AND  SZ0.D_E_L_E_T_ = '') "                                                    + CRLF
	ELSEIF FQ2->FQ2_TPROMA == "1"					// --> PROCESSA SOMENTE RETORNO     ( FQ2_TPROMA = 0=EXPEDICAO ; 1=RETORNO ) 
		_CQUERY     := " SELECT   FPA_PROJET PROJETO , FPA_GRUA CODBEM , ISNULL(FPA_DESGRU,'') BEM , "                         + CRLF
		_CQUERY     += "          ISNULL(FPA_DESGRU,'') FAMILIA , FPA_SEQGRU , FPA_AS , FPA_PRODUT "                           + CRLF
		_CQUERY     += " FROM " + RETSQLNAME("FPA")+" ZAG "                                                                    + CRLF
		_CQUERY     += " WHERE    ZAG.FPA_FILIAL =  '" + FQ5->FQ5_FILORI + "'"                                                 + CRLF
		_CQUERY     += "   AND    ZAG.FPA_PROJET =  '" + FQ5->FQ5_SOT    + "'"                                                 + CRLF
		_CQUERY     += "   AND    ZAG.FPA_OBRA   =  '" + FQ5->FQ5_OBRA   + "'"                                                 + CRLF
		_CQUERY     += "   AND    ZAG.FPA_AS     <> '' "                                                                       + CRLF
		_CQUERY     += "   AND    ZAG.FPA_NFREM  <> '' "                                                                       + CRLF
		_CQUERY     += "   AND    ZAG.FPA_DTPRRT <> '' "                                                                       + CRLF
		_CQUERY     += "   AND    ZAG.D_E_L_E_T_ =  '' "                                                                       + CRLF
	ENDIF

	IF SELECT("TRBZAG") > 0
		TRBFPA->(DBCLOSEAREA())
	ENDIF

	//CONOUT("##LOC05101.PRW - " + _CQUERY)

	TCQUERY _CQUERY NEW ALIAS "TRBZAG"

	IF TRBFPA->(EOF())
		AADD(_AARRAY,{.F. , "" , "" , "" , "" , ""})
	ELSE
		WHILE TRBFPA->(!EOF())
			IF EMPTY(TRBFPA->CODBEM) .AND. ALLTRIM(GETADVFVAL("SB1", "B1_GRUPO",XFILIAL("SB1")+TRBFPA->FPA_PRODUT,1,"")) $ ALLTRIM(CMV_LOCX014)
				AADD(_AARRAY,{.F. , TRBFPA->FAMILIA , TRBFPA->CODBEM , ALLTRIM(GETADVFVAL("SB1", "B1_DESC",XFILIAL("SB1")+TRBFPA->FPA_PRODUT,1,"")) , TRBFPA->FPA_SEQGRU , TRBFPA->FPA_AS}) 
			ELSE
				AADD(_AARRAY,{.F. , TRBFPA->FAMILIA , TRBFPA->CODBEM , TRBFPA->BEM                                                                  , TRBFPA->FPA_SEQGRU , TRBFPA->FPA_AS}) 
			ENDIF

			TRBFPA->(DBSKIP())
		ENDDO
	ENDIF

	TRBFPA->(DBCLOSEAREA())

	IF !LMSROTAUTO
		DEFINE MSDIALOG ODLG1 TITLE STR0004 FROM 0,0 TO 25,86 OF OMAINWND //"VINCULO FRETE X EQUIPAMENTO"
			@ 1.5 , .7 LISTBOX OLISTBOX FIELDS ;
			           HEADER  " " , STR0005 , STR0006 , STR0007 , STR0008 , STR0009 SIZE 330,147 ;  //"FAMÍLIA"###"CÓD. BEM"###"BEM"###"SEQUÊNCIA"###"AS"
			           ON DBLCLICK (_AARRAY := MARCAITEM(OLISTBOX:NAT,_AARRAY,LUMAOPCAO,LMARCAITEM) , IIF((EMPTY(_AARRAY[OLISTBOX:NAT][4]) .OR. !VERARRAY(_AARRAY)),OVINCZAG:DISABLE(),OVINCZAG:ENABLE()),;
			           IIF(BACAO==NIL,,EVAL(BACAO)),OLISTBOX:REFRESH()) 
	
			OLISTBOX:SETARRAY(_AARRAY) 
			OLISTBOX:BLINE := { || { IIF(_AARRAY[OLISTBOX:NAT][1],OOK,ONO) , ; 
			                             _AARRAY[OLISTBOX:NAT][2]          , ; 
			                             _AARRAY[OLISTBOX:NAT][3]          , ; 
			                             _AARRAY[OLISTBOX:NAT][4]          , ; 
									     _AARRAY[OLISTBOX:NAT][5]          , ; 
									     _AARRAY[OLISTBOX:NAT][6]          } } 
	
			@ 172, 7 BUTTON OVINCZAG PROMPT STR0010  SIZE 45,12 OF ODLG1 PIXEL ACTION (_NOPC := 1,ODLG1:END()) //"VINCULAR"
			OVINCZAG:DISABLE()
			@ 172,57 BUTTON OCANC    PROMPT STR0011  SIZE 45,12 OF ODLG1 PIXEL ACTION (_NOPC := 0,ODLG1:END()) //"CANCELAR"
		ACTIVATE MSDIALOG ODLG1 CENTERED
	ELSE
		FOR NINICIAL := 1 TO LEN(_AARRAY)
			_AARRAY[NINICIAL][1]:= .T.	// SE FOR ROTINA AUTOMATICA TODOS OS ITENS SERÃO VINCULADOS
		NEXT NINICIAL 
		_NOPC := 1
	ENDIF
	IF _NOPC == 1
		PROCESSA({|| GERASZ1(_CASF) } , STR0012 , STR0013 , .T.)  //"GRAVANDO NO ROMANEIO..."###"AGUARDE..."
	ENDIF

ELSE
	MSGALERT(_CERRO , STR0014)  //"GPO - LOC05101.PRW"
ENDIF

RESTAREA( _AAREAST9 )
RESTAREA( _AAREAZUC )
RESTAREA( _AAREASZ1 )
RESTAREA( _AAREASZ0 )
RESTAREA( _AAREADTQ )
RESTAREA( _AAREAOLD )

RETURN IIF(EMPTY(_CERRO),.T.,.F.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ GERASZ1   º AUTOR ³ IT UP BUSINESS     º DATA ³ 09/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRI‡AO ³ TELA PARA VINCULAR UM EQUIPAMENTOS AO FRETE, NA ROTINA DE  º±±
±±º          ³ ROMANEIO.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION GERASZ1(_CASF)

LOCAL _CQUERY := ""
LOCAL _CMSG   := ""
LOCAL _NX	  := 1
LOCAL _NITEM  := 1
LOCAL _NGRAVA := 0
LOCAL _NRECEB := 0

_CQUERY := " SELECT MAX(FQ3_ITEM) ITEM" + CRLF
_CQUERY += " FROM " + RETSQLNAME("FQ3") + " SZ1" + CRLF
_CQUERY += " WHERE  FQ3_FILIAL = '" + XFILIAL("FQ2") + "'" + CRLF
_CQUERY += "   AND  FQ3_NUM    = '" + FQ2->FQ2_NUM + "'" + CRLF
_CQUERY += "   AND  FQ3_ASF    = '" + _CASF + "'" + CRLF
_CQUERY += "   AND  SZ1.D_E_L_E_T_ = ''"

IF SELECT("TRBMAX") > 0
	TRBMAX->(DBCLOSEAREA())
ENDIF

TCQUERY _CQUERY NEW ALIAS "TRBMAX"

IF TRBMAX->(!EOF())
	_NITEM := VAL(TRBMAX->ITEM)+1
ENDIF

TRBMAX->(DBCLOSEAREA())

FOR _NX := 1 TO LEN(_AARRAY)
	IF !_AARRAY[_NX][1] .OR. EMPTY(_AARRAY[_NX][4])
		LOOP
	ENDIF

	_NRECEB++

	DBSELECTAREA("FQ3")
	FQ3->(DBSETORDER(1))
	IF RECLOCK("FQ3",.T.)
		FQ3->FQ3_FILIAL  := XFILIAL("FQ3")
		FQ3->FQ3_NUM     := FQ2->FQ2_NUM
		FQ3->FQ3_PROJET  := FQ2->FQ2_PROJET
		FQ3->FQ3_OBRA    := FQ2->FQ2_OBRA
		FQ3->FQ3_ASF     := _CASF
		FQ3->FQ3_AS      := _AARRAY[_NX][6]
		FQ3->FQ3_ITEM    := STRZERO(_NITEM,TAMSX3("FQ3_ITEM")[1])
		FQ3->FQ3_VIAGEM  := POSICIONE("FPA",3,XFILIAL("FPA") + _AARRAY[_NX][6],"FPA_VIAGEM")

		DBSELECTAREA("ST9")
		ST9->(DBSETORDER(1))
		IF ST9->(DBSEEK(XFILIAL("ST9") + _AARRAY[_NX][3]))
				FQ3->FQ3_CODBEM  := ST9->T9_CODBEM
				FQ3->FQ3_NOMBEM  := ST9->T9_NOME
				FQ3->FQ3_FAMBEM  := ST9->T9_CODFAMI
				FQ3->FQ3_FAMILIA := ALLTRIM(POSICIONE("ST6",1,XFILIAL("ST6") + ST9->T9_CODFAMI,"T6_NOME"))
				FQ3->FQ3_HORBEM  := ST9->T9_POSCONT
		ENDIF

		FQ3->(MSUNLOCK())
		_NITEM++
		_NGRAVA++
	ENDIF
NEXT

_CMSG := CVALTOCHAR(_NGRAVA) + STR0015 + CVALTOCHAR(_NRECEB) + STR0016 //" DE "###" ITENS FORAM GRAVADOS NO ROMANEIO."

IF _NGRAVA < _NRECEB
	_CMSG += CRLF + CRLF + STR0017 //"VERIFIQUE SE O EQUIPAMENTO DO PROJETO ESTÁ OK NO CADASTRO DE BENS!"
	MSGALERT(_CMSG , STR0014) //"GPO - LOC05101.PRW"
ELSE
	MSGINFO(_CMSG , STR0014)  //"GPO - LOC05101.PRW"
ENDIF

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ VERARRAY  º AUTOR ³ IT UP BUSINESS     º DATA ³ 10/01/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRI‡…O ³ VERIFICA SE O ARRAY POSSUI ALGUM REGISTRO MARCADO COMO .T. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION VERARRAY(_AARRAY) 

LOCAL _NCNT		:= 1
LOCAL _LRETORNO := .F.

WHILE _NCNT <= LEN(_AARRAY)
	IF _AARRAY[_NCNT,1]
		_LRETORNO := .T.
		EXIT
	ENDIF
	_NCNT++
ENDDO

RETURN _LRETORNO



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ MARCAITEM º AUTOR ³ IT UP BUSINESS     º DATA ³ 27/01/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRI‡…O ³ MARCA E DESMARCA UM ÚNICO ITEM.                  		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION MARCAITEM(NAT,_AARRAY,LUMAOPCAO,LMARCAITEM)

IF TYPE("LUMAOPCAO") == "L" .AND. LUMAOPCAO
	LMARCAITEM := .F.
ENDIF

_AARRAY[NAT][1] := !_AARRAY[NAT][1]

RETURN _AARRAY
