#INCLUDE "loca029.ch" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "PROTHEUS.CH"

/*{PROTHEUS.DOC} LOCA029.PRW
ITUP BUSINESS - TOTVS RENTAL
TELA DE MANUTENÇÃO DO ROMANEIO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
*/

FUNCTION LOCA029(_CASF)
LOCAL _CUSER	  := RETCODUSR(SUBS(CUSUARIO,7,15))  //RETORNA O CÓDIGO DO USUÁRIO
LOCAL _LC029COR   := EXISTBLOCK("LC029COR")

PRIVATE CCADASTRO := STR0001 //"ROMANEIO"
PRIVATE AROTINA   := {}
PRIVATE AENTIDADE := {}

PRIVATE CROMAX	  := "" // CÓDIGO DO ROMANEIO PARA USO NO PONDO DE ENTRADA MT103FIM - FRANK 29/10/20
PRIVATE _NZUC     := 0  // RECNO DA ZUC (CONJUNTO TRANSPORTADOR) USADO NO PONTO DE ENTRADA MT103FIM, GERNFRET E A103DEVOL - FRANK 02/11/20

AADD( AENTIDADE, { "FQ2", { "FQ2_NUM" }, { || FQ2->FQ2_NUM } } )

AADD( AROTINA , { STR0002              , "AXPESQUI"  		, 0, 1, 0, NIL } ) //"Pesquisar"
AADD( AROTINA , { STR0003             , "AXALTERA"  		, 0, 4, 0, NIL } ) //"Manutenção"
AADD( AROTINA , { STR0004             , "AXVISUAL"  		, 0, 2, 0, NIL } ) //"Visualizar"
AADD( AROTINA , { STR0005	       , "LOCA02901"			, 0, 4, 0, NIL } ) //"Equip/Insumos"
AADD( AROTINA , { STR0006       	       , "LOCR004"		, 0, 2, 0, NIL } ) //"Imprimir"
AADD( AROTINA , { STR0007    , "MSDOCUMENT"		, 0, 4, 0, NIL } ) //NECESSÁRIO USAR O PE FTMSREL  //"Banco de informação"
AADD( AROTINA , { STR0008 , "LOCA026"		, 0, 4, 0, .F. } ) //"Protocolo entrega Fis."
AADD( AROTINA , { STR0009              , "LOCA025"		, 0, 4, 0, .F. } ) //"Avaliação"
AADD( AROTINA , { STR0010             , "LOCA02903"		, 0, 2, 0, NIL } ) //"Emissão NF"
AADD( AROTINA , { STR0011                , "LOCA02907"		, 0, 2, 0, NIL } ) //"Legenda"

/* Removido por Frank em 05/07/2022
IF GETMV("MV_LOCX029")	
	FQ1->(DBSELECTAREA("FQ1"))
	FQ1->(DBSETORDER(1))

	If FQ1->(dbSeek(xFilial("FQ1")+_cUser+"VINCOS"))
		AADD( AROTINA,{STR0012,"LOCA02904",0,2,0,NIL}) //"Emissão NF Insumos"
	EndIF

ENDIF
*/


ACORES := { {"LOCA02908() == 1", "BR_VERDE"   },; 
		    {"LOCA02908() == 2", "BR_AMARELO" },;
		    {"LOCA02908() == 3", "BR_AZUL"    },;
		    {"LOCA02908() == 4", "BR_VERMELHO" }}

// DJALMA  - TRATAR NO CARD 350 - SPRINT 3.4 - ORGUEL - Legenda no romaneio (chamado 29564)
// CRIAR UM EXECBLOCK PARA UM NOVO TRATAMENTO DO ACORES
 
IF _LC029COR 												// --> PONTO DE ENTRADA PARA ALTERAÇÃO/INCLUSÃO DE CORES NO BROWSER.
	ACORES := EXECBLOCK("LC029COR",.T.,.T.,{ACORES})
ENDIF  

DBSELECTAREA("FQ2")
DBSETORDER(1)
DBGOTOP()
MBROWSE(6,1,22,75,"FQ2",,,,,, ACORES)

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ EQPROM    º AUTOR ³ IT UP BUSINESS     º DATA ³ 10/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRI‡…O ³ EQUIPAMENTOS DO ROMANEIO.                                  º±±
±±º          ³ CHAMADA: MENU - "EQUIP/INSUMOS"                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LOCA02901()

LOCAL   OSZ1

PRIVATE AROTINA := {}
                     
// INSTACIAMENTO
OSZ1 := FWMBROWSE():NEW()       

// TABELA QUE SERÁ UTILIZADAR
OSZ1:SETALIAS( "FQ3" )

// TITULO
OSZ1:SETDESCRIPTION( STR0013 + ALLTRIM(FQ2->FQ2_NUM) ) //"EQUIPAMENTOS DO ROMANEIO - "

// LEGENDA
IF ST6->( FIELDPOS("T6_XGRUPO") ) > 0								// --> EXCLUSIVO TECNOGERA - O PADRÃO UTILIZA OS PARÂMETROS MV_LOCX009, 02, 03, 04 E 05.
	OSZ1:ADDLEGEND("ALLTRIM(POSICIONE('ST6',1,XFILIAL('ST6') + FQ3_FAMBEM,'T6_XGRUPO')) == '1'", "GREEN"  , STR0015		) //"GERADOR"
	OSZ1:ADDLEGEND("ALLTRIM(POSICIONE('ST6',1,XFILIAL('ST6') + FQ3_FAMBEM,'T6_XGRUPO')) == '2'", "BLUE"   , STR0017   		) //"CABO"
	OSZ1:ADDLEGEND("ALLTRIM(POSICIONE('ST6',1,XFILIAL('ST6') + FQ3_FAMBEM,'T6_XGRUPO')) == '3'", "VIOLET" , STR0019		) //"QTA/QTM"
	OSZ1:ADDLEGEND("ALLTRIM(POSICIONE('ST6',1,XFILIAL('ST6') + FQ3_FAMBEM,'T6_XGRUPO')) == '4'", "ORANGE" , STR0021	) //"TRANSFORMADOR"
	OSZ1:ADDLEGEND("ALLTRIM(POSICIONE('ST6',1,XFILIAL('ST6') + FQ3_FAMBEM,'T6_XGRUPO')) == '5'", "GRAY"   , STR0023		) //"ACESSÓRIO"
	OSZ1:ADDLEGEND("!EMPTY(FQ3_ORDEM)"                                                         , "RED"    , STR0025         ) //"INSUMO"
ELSE
	//OSZ1:ADDLEGEND("ALLTRIM(FQ3_FAMBEM) $ ALLTRIM(GETMV('MV_LOCX009'))", "GREEN" , DESMFAM(GETMV("MV_LOCX009")))
	//OSZ1:ADDLEGEND("ALLTRIM(FQ3_FAMBEM) $ ALLTRIM(GETMV('MV_LOCX010'))", "BLUE"  , DESMFAM(GETMV("MV_LOCX010")))
	//OSZ1:ADDLEGEND("ALLTRIM(FQ3_FAMBEM) $ ALLTRIM(GETMV('MV_LOCX011'))", "VIOLET", DESMFAM(GETMV("MV_LOCX011")))
	//OSZ1:ADDLEGEND("ALLTRIM(FQ3_FAMBEM) $ ALLTRIM(GETMV('MV_LOCX012'))", "ORANGE", DESMFAM(GETMV("MV_LOCX012")))
	//OSZ1:ADDLEGEND("ALLTRIM(FQ3_FAMBEM) $ ALLTRIM(GETMV('MV_LOCX013'))", "GRAY"  , DESMFAM(GETMV("MV_LOCX013")))
	//OSZ1:ADDLEGEND("!EMPTY(FQ3_ORDEM)"                                , "RED"   , "INSUMO"                   )
ENDIF

// FILTRO SOMENTE REGISTROS DO ROMANEIO POSICIONADO
OSZ1:SETFILTERDEFAULT( "FQ3_FILIAL = FQ2->FQ2_FILIAL .AND. FQ3_NUM = FQ2->FQ2_NUM .AND. FQ3_ASF = FQ2->FQ2_ASF " )

OSZ1:DISABLEDETAILS()
 
  AADD( AROTINA, { STR0002  , "AXPESQUI"  , 0 , 1 , 0 , NIL } ) //"PESQUISAR"
  AADD( AROTINA, { STR0003 , "AXALTERA"  , 0 , 4 , 0 , NIL } ) //"MANUTENÇÃO"
  AADD( AROTINA, { STR0004 , "AXVISUAL"  , 0 , 2 , 0 , NIL } ) //"VISUALIZAR"
//AADD( AROTINA, { "EXCLUIR"    , "AXDELETA"  , 0 , 5 , 0 , NIL } )
  AADD( AROTINA, { STR0026    , "LOCA02905"  , 0 , 5 , 0 , NIL } ) //"EXCLUIR"
  AADD( AROTINA, { STR0011    , "LOCA02902" , 0 , 7 , 0 , .F. } ) //"LEGENDA"
//AADD( AROTINA, { "LEGENDA"    , "LOCA026" , 0 , 4 , 0 , .F. } )

// ATIVA
OSZ1:ACTIVATE()

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ LEQPROM   º AUTOR ³ IT UP BUSINESS     º DATA ³ 10/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ EQUIPAMENTOS DO ROMANEIO.                                  º±±
±±º          ³ CHAMADA: MENU - "LEGENDA"                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LOCA02902()

LOCAL _ALEGENDA := {}

IF ST6->( FIELDPOS("T6_XGRUPO") ) > 0								// --> EXCLUSIVO TECNOGERA - O PADRÃO UTILIZA OS PARÂMETROS MV_LOCX009, 02, 03, 04 E 05.
	AADD(_ALEGENDA, {"BR_VERDE"  , DESMFAM("1")}) 					// GERADOR
	AADD(_ALEGENDA, {"BR_AZUL"   , DESMFAM("2")}) 					// CABO
	AADD(_ALEGENDA, {"BR_VIOLETA", DESMFAM("3")}) 					// QTA/QTM
	AADD(_ALEGENDA, {"BR_LARANJA", DESMFAM("4")}) 					// TRANSFORMADOR
	AADD(_ALEGENDA, {"BR_CINZA"  , DESMFAM("5")}) 					// ACESSÓRIO
ELSE
	//AADD(_ALEGENDA, {"BR_VERDE"  , DESMFAM(GETMV("MV_LOCX009"))}) 	// GERADOR
	//AADD(_ALEGENDA, {"BR_AZUL"   , DESMFAM(GETMV("MV_LOCX010"))}) 	// CABO
	//AADD(_ALEGENDA, {"BR_VIOLETA", DESMFAM(GETMV("MV_LOCX011"))}) 	// QTA/QTM
	//AADD(_ALEGENDA, {"BR_LARANJA", DESMFAM(GETMV("MV_LOCX012"))}) 	// TRANSFORMADOR
	//AADD(_ALEGENDA, {"BR_CINZA"  , DESMFAM(GETMV("MV_LOCX013"))}) 	// ACESSÓRIO
ENDIF
	
BRWLEGENDA( STR0027, STR0011, _ALEGENDA) //"STATUS"###"LEGENDA"

RETURN NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ DESMFAM   º AUTOR ³ IT UP BUSINESS     º DATA ³ 11/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ DESMEMBRA O CONTEÚDO SEPARADO POR PONTO E VIRGULA EM ARRAY.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION DESMFAM(_CFAMILIA)

LOCAL   _CRET     := ""
LOCAL   _CQUERY   := ""
LOCAL   _AFAMILIA := {}
LOCAL   _NX

DEFAULT _CFAMILIA := ""

IF ST6->( FIELDPOS("T6_XGRUPO") ) > 0								// --> EXCLUSIVO TECNOGERA - O PADRÃO UTILIZA OS PARÂMETROS MV_LOCX009, 02, 03, 04 E 05.
	_CQUERY := " SELECT T6_CODFAMI , T6_NOME" + CRLF 
	_CQUERY += " FROM " + RETSQLNAME("ST6") + " ST6" + CRLF
	_CQUERY += " WHERE  T6_FILIAL  = '" + XFILIAL("ST6") + "'" + CRLF
	_CQUERY += "   AND  T6_XGRUPO  = '" + _CFAMILIA + "'" + CRLF
	_CQUERY += "   AND  ST6.D_E_L_E_T_ = ''" + CRLF
	_CQUERY += " ORDER BY T6_CODFAMI "
	IF SELECT("TRBST6") > 0
		TRBST6->(DBCLOSEAREA())
	ENDIF
	TCQUERY _CQUERY NEW ALIAS "TRBST6"
	WHILE TRBST6->(!EOF())
		IF EMPTY(_CRET)
			_CRET := ALLTRIM(TRBST6->T6_NOME)
		ELSE
			_CRET += "/" + ALLTRIM(TRBST6->T6_NOME)
		ENDIF
		TRBST6->(DBSKIP())
	ENDDO
	TRBST6->(DBCLOSEAREA())
ELSE
	_AFAMILIA := STRTOKARR(ALLTRIM(_CFAMILIA),";")
	
	FOR _NX := 1 TO LEN(_AFAMILIA)
		IF EMPTY(_CRET)
			_CRET := ALLTRIM(POSICIONE("ST6",1,XFILIAL("ST6") + _AFAMILIA[_NX],"T6_NOME"))
		ELSE
			_CRET += "/" + ALLTRIM(POSICIONE("ST6",1,XFILIAL("ST6") + _AFAMILIA[_NX],"T6_NOME"))
		ENDIF
	NEXT
ENDIF

RETURN _CRET



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ LOC051A   º AUTOR ³ IT UP BUSINESS     º DATA ³ 07/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ EMISSÃO NF PARA CHAMAR AS ROTINA DE REMESSA E RETORNO.     º±±
±±º          ³ CHAMADA: MENU - "EMISSÃO NF"                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LOCA02903(CALIAS,NREG,NOPC)

LOCAL AAREAZA0 := FP0->(GETAREA())
LOCAL LRET     := .T.
LOCAL LSZ1     := .F.
Local lFormPropr	:= .F. //José Eulálio - 03/06/2022 - SIGALOC94-346 - #27421 - NF de Retorno Apresentar o formulário quando for Formulário Próprio = Sim.

//15/08/2022 - Jose Eulalio - SIGALOC94-473 - Inativar LOCA064
// --> PONTO DE ENTRADA PLOC05102 COM ID L0501_GNFE EXECUTA ANTES DE GERAR A NF DE REMESSA OU RETORNO.
/*IF EXISTBLOCK("LOCA064") 									// PONTO DE ENTRADA DO FONTE LOC05102
	LRET := EXECBLOCK("LOCA064" , .T. , .T. , {"L0501_GNFE"}) 
ENDIF */
				
IF LRET
	IF FP0->(MSSEEK( XFILIAL("FP0")+FQ2->FQ2_PROJET ) )
		IF FQ2->FQ2_TPROMA == "0" 							// ROMANEIO DE REMESSA
			IF LOCA02906(FQ2->FQ2_NUM,FQ2->FQ2_TPROMA) 	// VALIDA SE O ROMANEIO TEVE NF VINCULADA
				//15/08/2022 - Jose Eulalio - SIGALOC94-473 - Inativar LOCA064
				// -->  PONTO DE ENTRADA PLOC05102 COM ID L0501_VAL_ANT_NFREM PARA EXECUTAR ALGUM PROCESSAMENTO ANTERIOR A NOTA DE REMESSA
				/*IF EXISTBLOCK("LOCA064") 					// PONTO DE ENTRADA DO FONTE LOC05102
					LRET := EXECBLOCK("LOCA064",.T.,.T.,{"L0501_VAL_ANT_NFREM"})
				ENDIF*/
				IF LRET
					LOCA010(.T.)
				ENDIF
			ENDIF
		ELSEIF FQ2->FQ2_TPROMA == "1" 						// ROMANEIO DE RETORNO
			IF LOCA02906(FQ2->FQ2_NUM,FQ2->FQ2_TPROMA) 	// VALIDA SE O ROMANEIO TEVE NF VINCULADA
				//15/08/2022 - Jose Eulalio - SIGALOC94-473 - Inativar LOCA064
				// --> PONTO DE ENTRADA PLOC05102 COM ID L0501_VAL_ANT_NFRET PARA EXECUTAR ALGUM PROCESSAMENTO ANTERIOR A NOTA DE RETORNO
				/*IF EXISTBLOCK("LOCA064") 					// PONTO DE ENTRADA DO FONTE LOC05102
					LRET := EXECBLOCK("LOCA064",.T.,.T.,{"L0501_VAL_ANT_NFRET"})
				ENDIF*/

				IF LRET

					// VERIFICAR SE EXISTE Z1 SEM NOTA EMITIDA
					LSZ1 := .F.
					FQ3->(DBSETORDER(1))
					FQ3->(DBSEEK(XFILIAL("FQ3")+FQ2->FQ2_NUM))
					WHILE !FQ3->(EOF()) .AND. FQ3->FQ3_FILIAL == XFILIAL("FQ3") .AND. FQ3->FQ3_NUM == FQ2->FQ2_NUM
						IF EMPTY(FQ3->FQ3_NFRET)
							LSZ1 := .T.
							EXIT
						ENDIF
						FQ3->(DBSKIP())
					ENDDO
					IF !LSZ1
						MSGALERT(STR0028,STR0029) //"TODOS OS ROMANEIOS JÁ FORAM PROCESSADOS."###"ATENÇÃO!"
						RESTAREA(AAREAZA0)
						RETURN
					ENDIF

					// Tratamento para a integracao do RM
					//If empty(GETMV("MV_LOCX299",,""))
						// FRANK 02/11/2020
						// IDENTIFICAÇÃO DE QUAL CONJUNTO TRANSPORTADOR SERÁ USADO.
						_NZUC := LOCA02909()
						IF _NZUC > 0
							If empty(GetMV("MV_LOCX299",,"")) // indica se existe integracao com o RM - Frank 04/10/22
								//IF MSGYESNO(STR0030 , STR0031)  //"RETORNO DA NF SERÁ VIA FORMULÁRIO PRÓPRIO?"###"GPO - LOC05102.PRW"
								//	LOCA011(NIL,NIL,NIL,.F.,.T.)
								//ELSE
								//	U_A103DEVOL(CALIAS,NREG,NOPC,FQ2->FQ2_NUM)
								//ENDIF
								lFormPropr := MSGYESNO(STR0030 , STR0031)  //"RETORNO DA NF SERÁ VIA FORMULÁRIO PRÓPRIO?"###"GPO - LOC05102.PRW"
								LOCA01101(CALIAS,NREG,NOPC,FQ2->FQ2_NUM,lFormPropr)
							Else
								LOCA76R()
							EndIf
						ENDIF
					//Else
						// Integracao com o RM
						//LOCA0743(FQ2->FQ2_NUM)
					//ENDIF
					//15/08/2022 - Jose Eulalio - SIGALOC94-473 - Inativar LOCA064
					// --> PONTO DE ENTRADA PLOC05102 COM ID L0501_VAL_POS_NFRET PARA EXECUTAR ALGUM PROCESSAMENTO POSTERIOR A NOTA DE RETORNO
					/*IF EXISTBLOCK("LOCA064") 					// PONTO DE ENTRADA DO FONTE LOC05102 
						LRET := EXECBLOCK("LOCA064",.T.,.T.,{"L0501_VAL_POS_NFRET"})
					ENDIF*/
				EndIF
			ENDIF
		ENDIF
	ENDIF
ENDIF

RESTAREA(AAREAZA0)

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ LOC051B   º AUTOR ³ IT UP BUSINESS     º DATA ³ 11/04/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ EMISSÃO NF DE INSUMOS                                      º±±
±±º          ³ CHAMADA: MENU - "EMISSÃO NF INSUMOS"                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/* Removido por Frank em 05/07/2022
FUNCTION LOCA02904()

LOCAL AAREAZA0  := FP0->(GETAREA())

PRIVATE CAVISO  := ""
PRIVATE CPROJET := ""

IF FP0->(MSSEEK(XFILIAL("FP0")+FQ2->FQ2_PROJET)) 
	CPROJET := FP0->FP0_PROJET
	IF EXISTBLOCK("CLIBLOQ")
		//IF U_CLIBLOQ( FP0->FP0_CLI , FP0->FP0_LOJA , .T. ) 
		If EXECBLOCK("CLIBLOQ" , .T. , .T. , {FP0->FP0_CLI, FP0->FP0_LOJA, .T.}) 
			RESTAREA(AAREAZA0) 
			RETURN NIL 
		ENDIF 
	ENDIF 
	IF MSGYESNO(OEMTOANSI(STR0032) , STR0031)  //"DESEJA EMITIR A NF REMESSA DE INSUMOS ?"###"GPO - LOC05102.PRW"
		PROCESSA({|| GERNFINSU() }, STR0033, STR0034, .T.) //"PROCESSANDO..."###"AGUARDE..."
		MSGALERT(CAVISO , STR0031)  //"GPO - LOC05102.PRW"
	ENDIF 
ENDIF 

RESTAREA(AAREAZA0)

RETURN                      
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ GERNFINSU º AUTOR ³ IT UP BUSINESS     º DATA ³ 11/04/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ PROGRAMA QUE GERA PEDIDO E FATURA DE INSUMOS               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
STATIC FUNCTION GERNFINSU()

LOCAL   AAREASC5	:= SC5->(GETAREA())
LOCAL   AAREASC6	:= SC6->(GETAREA())
LOCAL   AAREADA3	:= DA3->(GETAREA())
LOCAL   AAREASA1	:= SA1->(GETAREA())
LOCAL   ACAMPOSSC5  := {}
LOCAL   ACAMPOSSC6  := {}
LOCAL	CTESRF		:= SUPERGETMV("MV_LOCX084",.F.,"509")
LOCAL	CTESLF		:= SUPERGETMV("MV_LOCX083",.F.,"503")
LOCAL	CSERIE		:= SUPERGETMV("MV_LOCX201",.F.,"001")
LOCAL	CNATUREZ	:= SUPERGETMV("MV_LOCX066",.F.,"300000")
LOCAL	CGRPAND		:= ""
LOCAL 	_CDESCRI	:= ""
LOCAL	NPOS		:= 0
LOCAL	CFILAUX		:= ""
LOCAL   AITENS      := {}
LOCAL   _CQUERY     := ""
LOCAL   CITEM		:= "0"
LOCAL   OOK         := LOADBITMAP(GETRESOURCES(),"LBOK")
LOCAL   ONO         := LOADBITMAP(GETRESOURCES(),"LBNO") 
LOCAL   NJANELAA    := 385 
LOCAL   NJANELAL    := 1103
LOCAL   NLBTAML	    := 540	
LOCAL   NLBTAMA	    := 145	
LOCAL   LMARK       := .F.
LOCAL   NI          := 0 
LOCAL   NV          := 0
LOCAL   NZ          := 0 
LOCAL   NX          := 0 
Local   _GERREMTES := EXISTBLOCK("GERREMTES")
LOCAL   aPeso       := {0,0} 
Local 	cCmpUsr		:= SuperGetMv("MV_CMPUSR",.F.,"")

PRIVATE _CPEDIDO	:= ""
PRIVATE _CNOTA		:= ""
PRIVATE	LNFREMBE	:= SUPERGETMV("MV_LOCX215",.F.,.F.)
PRIVATE	_CDESTIN 	:= SUPERGETMV("MV_LOCX059",.F.,"")		// LISTA DOS E-MAILS QUE RECEBERÃO A SOLICITAÇÃO DE TRANSMISSÃO DA DANFE
PRIVATE	LMSERROAUTO := .F.
PRIVATE CPROJETO	:= SUPERGETMV("MV_LOCX248",.F.,STR0035) //"PROJETO"
PRIVATE LCLIOBRA	:= SUPERGETMV("MV_LOCX204",.F.,.T.)
PRIVATE ADADOSNF	:= {}
PRIVATE CNUMSC5     := ""
PRIVATE OFILOS       
PRIVATE ODLGFIL             
PRIVATE LTODOS      := .F.               
PRIVATE _ASZ1       := {}

IF SBM->(FIELDPOS("BM_XACESS")) > 0
	CGRPAND := LOCA00189()
ELSE
	CGRPAND := SUPERGETMV("MV_LOCX014",.F.,"")
ENDIF

// --> SÓ GERA QUANDO O TIPO DE SERVIÇO É LOCAÇÃO.
IF FP0->FP0_TIPOSE != "L"
	CAVISO := STR0036 + CPROJETO + STR0037  //"ESTA ROTINA É PARA GERAR REMESSA DE "###" DE LOCAÇÃO !"
	RETURN
ENDIF

// --> VALIDA SE EXISTE MESMO O CLIENTE PADRÃO DO PROJETO.
SA1->(DBSETORDER(1))
IF SA1->( DBSEEK( XFILIAL("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA  ) )
	IF SA1->A1_RISCO == "E"
		CAVISO := STR0038 + CRLF + CRLF + STR0039 //"CLIENTE COM RISCO E."###"FAVOR ENTRAR EM CONTATO COM SETOR DE CADASTROS/CRÉDITO!"
		RETURN
	ENDIF
ELSE
	CAVISO := STR0040+ FP0->FP0_CLI + "/" + FP0->FP0_LOJA+STR0041  //"ATENÇÃO: CLIENTE: "###" NÃO ENCONTRADO !!!"
	RETURN
ENDIF

// --> FUNÇÃO PARA SELEÇÃO DO ITENS DO PROJETO SELECIONADO.
_CQUERY += " SELECT SZ1.FQ3_FILIAL, SZ1.FQ3_NUM, SZ1.FQ3_ASF, SZ1.FQ3_ORDEM, SZ1.FQ3_PROD, SZ1.FQ3_DESPRO, SZ1.FQ3_QTD, SZ1.R_E_C_N_O_ SZ1REC "
_CQUERY +=      " , ZAG.FPA_PROJET, ZAG.FPA_OBRA,  ZAG.R_E_C_N_O_ ZAGREC "
_CQUERY +=      " , SB1.B1_UM, SB1.B1_PRV1, SB1.B1_LOCPAD, SB1.R_E_C_N_O_ SB1REC, ZAG.FPA_CUSTO, ZAG.FPA_CONPAG "
// [inicio] José Eulálio - 01/06/2022 - SIGALOC94-156 - Campo de volume e peso na C6.
_CQUERY +=      " , SB1.B1_PESO, SB1.B1_PESBRU "
// [final] José Eulálio - 01/06/2022 - SIGALOC94-156 - Campo de volume e peso na C6.
// [inicio] José Eulálio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
If FQ3->(ColumnPos("FQ3_OBSCCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSCON")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFIS")) > 0
	_CQUERY +=      " , SZ1.FQ3_OBSCCM, SZ1.FQ3_OBSCON, SZ1.FQ3_OBSFCM, SZ1.FQ3_OBSFIS "
EndIf
// [final] José Eulálio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
_CQUERY += " FROM "+RETSQLNAME("FQ3")+" SZ1 "        
_CQUERY +=        " INNER JOIN "+RETSQLNAME("FQ5")+" DTQ ON SZ1.FQ3_ASF     = DTQ.FQ5_AS     AND DTQ.D_E_L_E_T_ = '' "
_CQUERY +=        " INNER JOIN "+RETSQLNAME("FQ7")+" ZUC ON DTQ.FQ5_VIAGEM = ZUC.FQ7_VIAGEM AND ZUC.D_E_L_E_T_ = '' "
_CQUERY +=        " INNER JOIN "+RETSQLNAME("FPA")+" ZAG ON ZAG.FPA_VIAGEM = ZUC.FQ7_VIAORI AND ZAG.D_E_L_E_T_ = '' " 
_CQUERY +=        " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON SZ1.FQ3_PROD    = SB1.B1_COD     AND SB1.D_E_L_E_T_ = '' " 
_CQUERY += " WHERE  SZ1.D_E_L_E_T_ =  '' "
_CQUERY += "   AND  SZ1.FQ3_ORDEM   <> '' "
_CQUERY += "   AND  SZ1.FQ3_ASF     =  '"+ALLTRIM(FQ2->FQ2_ASF)+"' "
_CQUERY += "   AND  SZ1.FQ3_NFREM   =  '' "
_CQUERY += "   AND  SZ1.FQ3_SERREM  =  '' "
IF SELECT("TRBFQ3") > 0
	TRBFQ3->(DBCLOSEAREA())
ENDIF
TCQUERY _CQUERY NEW ALIAS "TRBFQ3"

TRBFQ3->(DBGOTOP())

IF TRBFQ3->(EOF())
	CAVISO := STR0042  //"ATENÇÃO: NÃO EXISTEM INSUMOS A SEREM ENVIADOS !"
	TRBFQ3->(DBCLOSEAREA())
	RETURN
ELSE
    WHILE TRBFQ3->(!EOF())
        NPOS := ASCAN(_ASZ1,{ |X| ALLTRIM(X[6])==ALLTRIM(TRBFQ3->FQ3_PROD)})
        IF NPOS = 0
			// [inicio] José Eulálio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
			If FQ3->(ColumnPos("FQ3_OBSCCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSCON")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFIS")) > 0
				AADD(_ASZ1, {.F. ,TRBFQ3->FQ3_FILIAL, TRBFQ3->FQ3_NUM   , TRBFQ3->FQ3_ASF    , TRBFQ3->FQ3_ORDEM , TRBFQ3->FQ3_PROD, TRBFQ3->FQ3_DESPROD,; 
	                          TRBFQ3->FQ3_QTD   , TRBFQ3->FQ3REC   , TRBFQ3->FPA_PROJET, TRBFQ3->FPA_OBRA , TRBFQ3->ZAGREC , TRBFQ3->B1_UM     ,; 
	                          TRBFQ3->B1_PRV1  , TRBFQ3->B1_LOCPAD, TRBFQ3->SB1REC    , TRBFQ3->FPA_CUSTO, TRBFQ3->FPA_CONPAG, TRBFQ3->B1_PESO ,;
							  TRBFQ3->FQ3_OBSCCM, TRBFQ3->FQ3_OBSCON   , TRBFQ3->FQ3_OBSFCM    , TRBFQ3->FQ3_OBSFIS, TRBFQ3->B1_PESBRU})
			// [final] José Eulálio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
			Else
				AADD(_ASZ1, {.F. ,TRBFQ3->FQ3_FILIAL, TRBFQ3->FQ3_NUM   , TRBFQ3->FQ3_ASF    , TRBFQ3->FQ3_ORDEM , TRBFQ3->FQ3_PROD, TRBFQ3->FQ3_DESPROD,; 
	                          TRBFQ3->FQ3_QTD   , TRBFQ3->FQ3REC   , TRBFQ3->FPA_PROJET, TRBFQ3->FPA_OBRA , TRBFQ3->ZAGREC , TRBFQ3->B1_UM     ,; 
	                          TRBFQ3->B1_PRV1  , TRBFQ3->B1_LOCPAD, TRBFQ3->SB1REC    , TRBFQ3->FPA_CUSTO, TRBFQ3->FPA_CONPAG, TRBFQ3->B1_PESO ,;
							  "", ""  , ""    , "", TRBFQ3->B1_PESBRU})
			EndIf
        ELSE
            _ASZ1[NPOS][8] += TRBFQ3->FQ3_QTD
        ENDIF
        TRBFQ3->(DBSKIP())
    ENDDO
      
    TRBFQ3->(DBCLOSEAREA())
      
    DEFINE MSDIALOG ODLGFIL TITLE STR0043 FROM 010,005 TO NJANELAA,NJANELAL PIXEL//OF OMAINWND //"ITENS NF REMESSA INSUMO"
	    @ 0.5,0.7 LISTBOX OFILOS FIELDS HEADER  " ",STR0044,STR0045,STR0046,STR0047,STR0048, STR0049, STR0050 SIZE NLBTAML,NLBTAMA ON DBLCLICK (MARCARREGI(.F.)) //"FILIAL"###"NUM ROMANEIO"###"ASF"###"ORDEM DE SERVIÇO"###"PRODUTO"###"DESC. PRODUTO"###"QUANTIDADE"
	    OFILOS:SETARRAY(_ASZ1)
	    OFILOS:BLINE := {|| { IF( _ASZ1[OFILOS:NAT,1],OOK,ONO),;   // CHECKBOX
								  _ASZ1[OFILOS:NAT,2],;   	 	   // FILIAL
								  _ASZ1[OFILOS:NAT,3],;            // ROMANEIO	
								  _ASZ1[OFILOS:NAT,4],;            // ASF	
								  _ASZ1[OFILOS:NAT,5],;            // ORDEM DE SERVICO	
								  _ASZ1[OFILOS:NAT,6],;            // PRODUTO	
								  _ASZ1[OFILOS:NAT,7],;            // DESC. PRODUTO	
								  _ASZ1[OFILOS:NAT,8]}}            // QUANTIDADE
		
		@ 172,007 BUTTON OFILBUT PROMPT STR0051 SIZE 55,12 OF ODLGFIL PIXEL ;  //"GERA NF REMESSA"
		                 ACTION ( IIF(MSGYESNO(OEMTOANSI(STR0052) , STR0031) , ;  //"DESEJA MESMO GERAR NF REMESSA DE INSUMO PARA OS ITENS SELECIONADOS?"###"GPO - LOC05102.PRW"
		                              NOPC := "1"  , ; 
		                              NOPC := "0") , ; 
		                         ODLGFIL:END() ) 
	    @ 172,062 BUTTON   OCANBUT PROMPT STR0053             SIZE 55,12 OF ODLGFIL PIXEL ACTION (NOPC := "0", ODLGFIL:END()) //"CANCELAR"
	   	@ 172,117 CHECKBOX LTODOS  PROMPT STR0054 SIZE 70,10 OF ODLGFIL PIXEL ON CLICK MARCARREGI(.T.) //"MARCA/DESMARCA TODOS"
    ACTIVATE MSDIALOG ODLGFIL CENTERED
    
    IF NOPC == "0"
       CAVISO := STR0055 + CRLF //"EMISSÃO DA NF REMESSA INSUMO CANCELADA PELO USUÁRIO !"
	   RESTAREA(AAREASC5)
	   RESTAREA(AAREASC6)
	   RESTAREA(AAREADA3)
	   RESTAREA(AAREASA1)       
       RETURN .F.
    ENDIF    
    
    IF NOPC == "1"
		// --> CRIA OS ARRAYS PARA O EXECAUTO.
		DBSELECTAREA("FP1")
		FOR NI := 1 TO LEN(_ASZ1)
		    IF _ASZ1[NI][1]                                                                                    
		        LMARK := .T.
				// --> POSICIONA E VALIDA O CADASTRO CLIENTE ATRAVÉS DO CLIENTE. 
				FP1->(DBSETORDER(1))
				IF FP1->(MSSEEK( XFILIAL("FP1") + _ASZ1[NI][10] + _ASZ1[NI][11])) 					// VALIDA SE TEM CLIENTE NA OBRA ATRAVÉS DA ZAG
					IF EMPTY(FP1->FP1_CLIORI) .OR. EMPTY(FP1->FP1_LOJORI) 
						IF LCLIOBRA 			// PARAMETRO QUE VERIFICA SE FATURA PELO ZA1 OU PELO ZA0
							CAVISO := STR0056+ ALLTRIM(_ASZ1[NI][10]) + STR0057 + _ASZ1[NI][11] //"ATENÇÃO: O PROJETO "###" ESTÁ SEM CLIENTE PARA A OBRA: "
							RETURN
						ELSE
							IF ! SA1->(MSSEEK( XFILIAL("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA))
								CAVISO := STR0040+ FP0->FP0_CLI + "/" + FP0->FP0_LOJA+STR0058  //"ATENÇÃO: CLIENTE: "###" NÃO ENCONTRADO ! "
								RETURN 
							ENDIF 
						ENDIF 
					ELSE 
						IF ! SA1->(MSSEEK( XFILIAL("SA1") + FP1->FP1_CLIORI + FP1->FP1_LOJORI)) 	// VALIDA SE O CLIENTE DA OBRA EXISTE
							IF LCLIOBRA 		// PARAMETRO QUE VERIFICA SE FATURA PELO ZA1 OU PELO ZA0
								CAVISO := STR0040+ FP1->FP1_CLIORI + "/" + FP1->FP1_LOJORI + STR0059  //"ATENÇÃO: CLIENTE: "###" NÃO ENCONTRADO !"
								RETURN
							ELSE
								IF ! SA1->(MSSEEK( XFILIAL("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA))
									CAVISO := STR0040+ FP0->FP0_CLI + "/" + FP0->FP0_LOJA+STR0059 //"ATENÇÃO: CLIENTE: "###" NÃO ENCONTRADO !"
									RETURN
								ENDIF
							ENDIF
						ENDIF
					ENDIF	
				ELSE
					CAVISO := STR0060 + ALLTRIM(_ASZ1[NI][11]) //"ATENÇÃO: NÃO ENCONTRADA OBRA: "
					RETURN
				ENDIF
			
				// --> CRIA ARRAY PARA O CABEÇALHO. 
				IF LEN(ACAMPOSSC5) == 0 		// .OR. (CFILAUX <> ZAGTMP->FILTRAB .AND. LNFREMBE)
					_CTXT := STR0061      + ALLTRIM(FP1->FP1_NOMORI) + CRLF //"OBRA: "
					_CTXT += STR0062  + ALLTRIM(FP1->FP1_ENDORI) + CRLF //"ENDERECO: "
					_CTXT += STR0063    + ALLTRIM(FP1->FP1_BAIORI) + CRLF //"BAIRRO: "
					_CTXT += STR0064 + ALLTRIM(FP1->FP1_MUNORI) + CRLF //"MUNICIPIO: "
					_CTXT += STR0065    + ALLTRIM(FP1->FP1_ESTORI) + CRLF //"ESTADO: "
			
					IF ! EMPTY(FP1->FP1_CEIORI)
						_CTXT += STR0066   + ALLTRIM(FP1->FP1_CEIORI) + CRLF //"CEI: "
					ENDIF
			
					ACAMPOSSC5 := {} 
					AADD(ACAMPOSSC5     , {"C5_FILIAL"  , _ASZ1[NI][2]  , XA1ORDEM("C5_FILIAL" ) } ) 
					AADD(ACAMPOSSC5     , {"C5_NUM"     , CNUMSC5       , XA1ORDEM("C5_NUM"    ) } ) 
					AADD(ACAMPOSSC5     , {"C5_TIPO"	, "N"           , XA1ORDEM("C5_TIPO"   ) } )
					IF LCLIOBRA
						AADD(ACAMPOSSC5 , {"C5_CLIENTE"	, SA1->A1_COD   , XA1ORDEM("C5_CLIENTE") } )
						AADD(ACAMPOSSC5 , {"C5_LOJACLI"	, SA1->A1_LOJA  , XA1ORDEM("C5_LOJACLI") } )
					ELSE
						AADD(ACAMPOSSC5 , {"C5_CLIENTE" , FP0->FP0_CLI  , XA1ORDEM("C5_CLIENTE") } )
						AADD(ACAMPOSSC5 , {"C5_LOJACLI" , FP0->FP0_LOJA , XA1ORDEM("C5_LOJACLI") } )
					ENDIF
					AADD(ACAMPOSSC5     , {"C5_CLIENT"  , SA1->A1_COD   , XA1ORDEM("C5_CLIENT" ) } )
					AADD(ACAMPOSSC5     , {"C5_LOJAENT" , SA1->A1_LOJA  , XA1ORDEM("C5_LOJAENT") } )
					AADD(ACAMPOSSC5     , {"C5_TIPOCLI" , SA1->A1_TIPO  , XA1ORDEM("C5_TIPOCLI") } )
					AADD(ACAMPOSSC5     , {"C5_DESC1"   , 0			    , XA1ORDEM("C5_DESC1"  ) } )
					AADD(ACAMPOSSC5     , {"C5_DESC2"   , 0			    , XA1ORDEM("C5_DESC2"  ) } )
					AADD(ACAMPOSSC5     , {"C5_DESC3"   , 0			    , XA1ORDEM("C5_DESC3"  ) } )
					AADD(ACAMPOSSC5     , {"C5_DESC4"	, 0			    , XA1ORDEM("C5_DESC4"  ) } )
					AADD(ACAMPOSSC5     , {"C5_TPCARGA"	, "1"		    , XA1ORDEM("C5_TPCARGA") } )
					AADD(ACAMPOSSC5     , {"C5_CONDPAG"	, _ASZ1[NI][18] , XA1ORDEM("C5_CONDPAG") } )
					AADD(ACAMPOSSC5     , {"C5_TPFRETE"	, "F"   	    , XA1ORDEM("C5_TPFRETE") } )
					AADD(ACAMPOSSC5     , {"C5_VOLUME1"	, 1     	    , XA1ORDEM("C5_VOLUME1") } )
					AADD(ACAMPOSSC5     , {"C5_ESPECI1"	, "MAQUINA"     , XA1ORDEM("C5_ESPECI1") } )
					AADD(ACAMPOSSC5     , {"C5_NATUREZ" , CNATUREZ      , XA1ORDEM("C5_NATUREZ") } )
					// [inicio] José Eulálio - 01/06/2022 - SIGALOC94-156 - Campo de volume e peso na C6.
					//AADD(ACAMPOSSC5     , {"C5_PESOL"	, 0 		    , XA1ORDEM("C5_PESOL"  ) } )
					//AADD(ACAMPOSSC5     , {"C5_PBRUTO"	, 0 		    , XA1ORDEM("C5_PBRUTO" ) } )
					aPeso := LOCA02910(_ASZ1)
					AADD(ACAMPOSSC5     , {"C5_PESOL"	, aPeso[1]		    , XA1ORDEM("C5_PESOL"  ) } )
					AADD(ACAMPOSSC5     , {"C5_PBRUTO"	, aPeso[2]		    , XA1ORDEM("C5_PBRUTO" ) } )
					If FQ2->(ColumnPos("FQ2_VOLUM1")) > 0
						AADD(ACAMPOSSC5     , {"C5_VOLUME1"	, FQ2->FQ2_VOLUM1	    , XA1ORDEM("C5_VOLUME1" ) } )
					EndIf
					If FQ2->(ColumnPos("FQ2_MENNOT")) > 0
						AADD(ACAMPOSSC5     , {"C5_MENNOTA" , FQ2->FQ2_MENNOT      , XA1ORDEM("C5_MENNOTA") } )
					EndIf
					If !Empty(cCmpUsr)
						If SC5->(ColumnPos(cCmpUsr)) > 0
							AADD(ACAMPOSSC5     , {cCmpUsr , FQ2->FQ2_OBS      , XA1ORDEM(cCmpUsr) } )
						EndIf
					EndIf
					// [final] José Eulálio - 01/06/2022 - SIGALOC94-156 - Campo de volume e peso na C6.
					// removido da 94
					//IF SC5->(FIELDPOS( "C5_OBSNF" )) > 0
					//	AADD(ACAMPOSSC5 , {"C5_OBSNF"   , _CTXT		    , XA1ORDEM("C5_OBSNF"  ) } )
					//ENDIF
					IF SC5->(FIELDPOS( "C5_XPROJET" )) > 0
						AADD(ACAMPOSSC5 , {"C5_XPROJET" , CPROJET	    , XA1ORDEM("C5_XPROJET") })
					ENDIF
					IF SC5->(FIELDPOS( "C5_XTIPFAT" )) > 0
						AADD(ACAMPOSSC5 , {"C5_XTIPFAT" , "R"           , XA1ORDEM("C5_XTIPFAT") })
					ENDIF
					IF SC5->(FIELDPOS( "C5_XOBRA" )) > 0
						AADD(ACAMPOSSC5 , {"C5_XOBRA"   , FP1->FP1_OBRA , XA1ORDEM("C5_XOBRA"  ) })
					ENDIF
					// [inicio] José Eulálio - 02/06/2022 - SIGALOC94-345 - #27421 - Campo de obrigatoriedade Tipo de Transporte (lei)
					If FQ2->(ColumnPos("FQ2_TPFRET")) > 0
						AADD(ACAMPOSSC5     , {"C5_TPFRETE" , FQ2->FQ2_TPFRET      , XA1ORDEM("C5_TPFRETE") } )
					EndIf
					If FQ2->(ColumnPos("FQ2_XCODTR")) > 0
						AADD(ACAMPOSSC5     , {"C5_TRANSP" , FQ2->FQ2_XCODTR      , XA1ORDEM("C5_TRANSP") } )
					EndIf
					// [final] José Eulálio - 02/06/2022 - SIGALOC94-345 - #27421 - Campo de obrigatoriedade Tipo de Transporte (lei)
				ENDIF

				// --> CRIA ARRAY PARA OS ITENS DO PEDIDO. 
				_CDESCRI := ALLTRIM(_ASZ1[NI][7])
			
				AITENS := {}
				
				CITEM := SOMA1(CITEM)//ALEXIS DUARTE
				CITEM := IIF(LEN(CITEM)==1,'0'+CITEM,CITEM)//ALEXIS DUARTE
				// CRIA ARRAY PARA OS ITENS
				AADD(AITENS,{"C6_FILIAL"	, _ASZ1[NI][2]          , XA1ORDEM("C6_FILIAL"  )}) // FILIAL
				AADD(AITENS,{"C6_ITEM"		, CITEM					, XA1ORDEM("C6_ITEM"	)}) // ITENS
				AADD(AITENS,{"C6_NUM"		, CNUMSC5				, XA1ORDEM("C6_NUM"		)}) // NUMERO DO PEDIDO
				AADD(AITENS,{"C6_PRODUTO"	, _ASZ1[NI][6]        	, XA1ORDEM("C6_PRODUTO"	)}) // MATERIAL
				AADD(AITENS,{"C6_UM"		, _ASZ1[NI][13]			, XA1ORDEM("C6_UM"		)}) // UNIDADE DE MEDIDA
				AADD(AITENS,{"C6_DESCRI"	, _CDESCRI				, XA1ORDEM("C6_DESCRI"	)}) // DESCRIÇÃO DO PRODUTO
				
				IF _GERREMTES //EXISTBLOCK("GERREMTES") //PONTO DE ENTRADA PARA ALTERAÇÃO DA TES.
					CTESLF := EXECBLOCK("GERREMTES",.T.,.T.,{CTESLF})
				ENDIF
			
				AADD(AITENS,{"C6_TES"		, CTESLF				, XA1ORDEM("C6_TES"		)}) // TES
				AADD(AITENS,{"C6_ENTREG"	, DDATABASE				, XA1ORDEM("C6_ENTREG"	)}) // DATA DA ENTREGA
				AADD(AITENS,{"C6_DESCONT"	, 0						, XA1ORDEM("C6_DESCONT"	)}) // PERCENTUAL DE DESCONTO
				AADD(AITENS,{"C6_COMIS1"	, 0						, XA1ORDEM("C6_COMIS1"	)}) // COMISSAO VENDEDOR
				IF LCLIOBRA
					AADD(AITENS,{"C6_CLI"		, SA1->A1_COD		, XA1ORDEM("C6_CLI"		)}) // CLIENTE
					AADD(AITENS,{"C6_LOJA"		, SA1->A1_LOJA		, XA1ORDEM("C6_LOJA"	)}) // LOJA DO CLIENTE
				ELSE
					AADD(AITENS,{"C6_CLI"		, FP0->FP0_CLI		, XA1ORDEM("C6_CLI"		)}) // CLIENTE
					AADD(AITENS,{"C6_LOJA"		, FP0->FP0_LOJA		, XA1ORDEM("C6_LOJA"	)}) // LOJA DO CLIENTE
				ENDIF
				NVALPROD := NOROUND(_ASZ1[NI][14],2)
				IF NVALPROD <= 0
					CAVISO := STR0067 + ALLTRIM(_ASZ1[NI][6]) + STR0068 + CRLF + STR0069 //"O ITEM '"###"' ESTÁ COM O VALOR ZERADO."###"FAVOR VERIFICAR O CADASTRO DE PRODUTO, SE FOR O CASO!"
					RETURN
				ENDIF
				//CASO PERTENÇA AO GRUPO QUE É CADASTRADO NO PARÂMETRO PERMITE A OPÇÃO DE SELECIONAR O ARMAZÉM COM SALDO
				AADD(AITENS,{"C6_QTDVEN"	, _ASZ1[NI][8]   		   , XA1ORDEM("C6_QTDVEN"	)}) // QUANTIDADE
				AADD(AITENS,{"C6_PRCVEN"	, NVALPROD				   , XA1ORDEM("C6_PRCVEN"	)}) // PRECO DE VENDA / VALOR FRETE
				AADD(AITENS,{"C6_PRUNIT"	, NVALPROD				   , XA1ORDEM("C6_PRUNIT"	)}) // PRECO UNITÁRIO / VALOR FRETE
				AADD(AITENS,{"C6_VALOR"	    , NVALPROD * _ASZ1[NI][8]  , XA1ORDEM("C6_VALOR"	)}) // VALOR TOTAL DO ITEM
				AADD(AITENS,{"C6_QTDLIB"	, _ASZ1[NI][8]   		   , XA1ORDEM("C6_QTDLIB"	)}) // QUANTIDADE LIBERADA	
				AADD(AITENS,{"C6_LOCAL"		, _ASZ1[NI][15]  		   , XA1ORDEM("C6_LOCAL"	)}) // ARMAZEM PADRAO
				
				IF LEN(ALLTRIM(TRANSFORM(NVALPROD * _ASZ1[NI][8],GETSX3CACHE("C6_VALOR","X3_PICTURE")))) > GETSX3CACHE("C6_VALOR","X3_TAMANHO")
					CAVISO := "O TAMANHO DOS CAMPOS DE VALORES DO PEDIDO DE VENDA SÃO INFERIORES A " + CVALTOCHAR(LEN(ALLTRIM(TRANSFORM(NVALPROD*ZAGTMP->FPA_QUANT,GETSX3CACHE("C6_VALOR","X3_PICTURE"))))) + STR0070 + ALLTRIM(TRANSFORM(NVALPROD * _ASZ1[NI][8],GETSX3CACHE("C6_VALOR","X3_PICTURE"))) + "." //". NÃO SENDO POSSÍVEL GERAR O PEDIDO DE VENDA COM VALOR "
					RESTAREA(AAREASC5)
					RESTAREA(AAREASC6)
					RESTAREA(AAREADA3)
					RESTAREA(AAREASA1)
					RETURN
				ENDIF
			
				IF SC6->(FIELDPOS( "C6_XCCUSTO" )) > 0 
					AADD(AITENS,{"C6_XCCUSTO"	, _ASZ1[NI][17]		, XA1ORDEM("C6_XCCUSTO"	)}) // CENTRO DE CENTRO ZAG
				ENDIF
				IF SC6->(FIELDPOS("C6_XAS")) > 0
					AADD(AITENS,{"C6_XAS"		, _ASZ1[NI][4]		, XA1ORDEM("C6_XAS"		)})  // AS
				ENDIF
				IF SC6->(FIELDPOS("C6_CLVL")) > 0
					AADD(AITENS,{"C6_CLVL"		, _ASZ1[NI][4]		, XA1ORDEM("C6_CLVL"	)})  // CLASSE DE VALOR
				ENDIF
			
				// [inicio] José Eulálio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
				If 		FQ3->(ColumnPos("FQ3_OBSCCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSCON")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFIS")) > 0 ;
						.And. SC6->(ColumnPos("C6_OBSCCMP")) > 0 .And. SC6->(ColumnPos("C6_OBSCONT")) > 0 .And. SC6->(ColumnPos("C6_OBSFISC")) > 0 .And. SC6->(ColumnPos("C6_OBSFCMP")) > 0
					AADD(AITENS,{"C6_OBSCCMP"		, _ASZ1[NI][20]		, XA1ORDEM("C6_OBSCCMP"	)})  // TITULO OBS CONTRIBUINTE
					AADD(AITENS,{"C6_OBSCONT"		, _ASZ1[NI][21]		, XA1ORDEM("C6_OBSCONT"	)})  // OBS CONTRIBUINTE
					AADD(AITENS,{"C6_OBSFCMP"		, _ASZ1[NI][22]		, XA1ORDEM("C6_OBSFCMP"	)})  // TITULO OBS FISCO
					AADD(AITENS,{"C6_OBSFISC"		, _ASZ1[NI][23]		, XA1ORDEM("C6_OBSFISC"	)})  // OBS FISCO
				EndIf
				// [final] José Eulálio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
				AADD(ACAMPOSSC6, AITENS )
				
		   ENDIF
		NEXT NI 
		
		IF !LMARK
		   CAVISO := STR0071 + CRLF //"NENHUM ITEM FOI SELECIONADO!"
		   RESTAREA(AAREASC5)
		   RESTAREA(AAREASC6)
		   RESTAREA(AAREADA3)
		   RESTAREA(AAREASA1)
		   RETURN .F.
		ENDIF
		
		// --> ORDENA E ACERTA OS ARRAYS 
		// --> ORDENA O ARRAY DO CABEÇALHO DE ACORDO COM A ORDEM DO CAMPO
		ASORT(ACAMPOSSC5,,,{|X,Y| X[3]<Y[3]})
		// --> TRANSFORMA A ORDEM DO CAMPO EM NULO PARA RESPEITAR O PADRÃO DO EXECAUTO
		FOR NV := 1 TO LEN(ACAMPOSSC5)
			ACAMPOSSC5[NV][3] := NIL
		NEXT NV
		// -->  ACERTO DO ARRAY DE ITENS
		FOR NZ := 1 TO LEN(ACAMPOSSC6)
			// --> ORDENA O ARRAY DO CABEÇALHO DE ACORDO COM A ORDEM DO CAMPO 
			ASORT(ACAMPOSSC6[NZ],,,{|X,Y| X[3]<Y[3]})
			// --> TRANSFORMA A ORDEM DO CAMPO EM NULO PARA RESPEITAR O PADRÃO DO EXECAUTO
			FOR NV := 1 TO LEN(ACAMPOSSC6[NZ])
				ACAMPOSSC6[NZ][NV][3] := NIL
			NEXT NV	
		NEXT NZ
		
		// --> TRATATIVAS PARA A GERAÇÃO DO PEDIDO DE VENDA.
		IF LEN(ACAMPOSSC5) > 0 .AND. LEN(ACAMPOSSC6) > 0
			_NPFILC6	:= ASCAN(ACAMPOSSC6[1],{|X| ALLTRIM(X[1])=="C6_FILIAL"})
			_NPITC6		:= ASCAN(ACAMPOSSC6[1],{|X| ALLTRIM(X[1])=="C6_ITEM"})
			_NPNUMC6	:= ASCAN(ACAMPOSSC6[1],{|X| ALLTRIM(X[1])=="C6_NUM"})
			_NPFILC5	:= ASCAN(ACAMPOSSC5,{|X| ALLTRIM(X[1])=="C5_FILIAL"})
			_NPNUMC5	:= ASCAN(ACAMPOSSC5,{|X| ALLTRIM(X[1])=="C5_NUM"})
			CFILAUX		:= CFILANT
			
		//	BEGIN TRANSACTION
			CNUMSC5 := XSC5NUM()
			ACAMPOSSC5[_NPNUMC5][2]  := CNUMSC5
			FOR NI := 1 TO LEN(ACAMPOSSC6)
			   ACAMPOSSC6[NI][_NPNUMC6][2]  := CNUMSC5
			NEXT NI
			   
			IF ! EMPTY(CNUMSC5)			
				// GRAVA USANDO O EXECAUTO
				PROCESSA({|| EXPEDINS(ACAMPOSSC5,ACAMPOSSC6,LNFREMBE) }, STR0072 + CNUMSC5, STR0034, .T.)  //"PROCESSANDO PEDIDO DE VENDA "###"AGUARDE..."
				IF EMPTY(_CPEDIDO)
					CAVISO := STR0073 + CRLF //"NÃO FOI POSSÍVEL GERAR O PEDIDO DE VENDA PARA O ROMANEIO!"
					RETURN
				ENDIF
						
				// GERA A NOTA 
				PROCESSA({|| GRVNFINS( _CPEDIDO,CTESRF,CTESLF,CSERIE ) }, STR0074 + _CPEDIDO, STR0034, .T.) // GRAVANFS( _CPEDIDO,CTESRF,CTESLF,CSERIE ) //"PROCESSANDO NF P/ O PEDIDO DE VENDA "###"AGUARDE..."
				IF EMPTY( _CNOTA )
					CAVISO := STR0075+_CPEDIDO //"NÃO FOI POSSÍVEL FATURAR O PEDIDO DE REMESSA Nº: "
				 //	DISARMTRANSACTION()
				ELSE						
					CAVISO := STR0076+_CPEDIDO+"." +CRLF + STR0077+_CNOTA+"!" //"GERADO O PEDIDO DE REMESSA Nº: "###"GERADA A NF DE REMESSA "
				ENDIF
				
				IF !EMPTY(_CPEDIDO)
					SC6->(DBGOTOP())
					IF SC6->(DBSEEK(ACAMPOSSC5[_NPFILC5][2] + _CPEDIDO))
						WHILE SC6->(!EOF()) .AND. SC6->C6_FILIAL == ACAMPOSSC5[_NPFILC5][2] .AND. SC6->C6_NUM == _CPEDIDO
						   SC6->(RECLOCK("SC6", .F.))
						   SC6->C6_XROMAN := FQ2->FQ2_NUM
						   SC6->(MSUNLOCK())
						   SC6->(DBSKIP())
						ENDDO
				    ENDIF
				ENDIF
				
				IF !EMPTY(_CNOTA)
					STL->(DBSELECTAREA("STL"))
					STL->(DBSETORDER(1))
					FOR NX := 1 TO LEN(_ASZ1)
					   IF _ASZ1[NX][1]
						  IF STL->(DBSEEK(_ASZ1[NX][2] + _ASZ1[NX][5]))		
						     WHILE STL->(!EOF()) .AND. STL->TL_FILIAL == _ASZ1[NX][2] .AND. STL->TL_ORDEM == _ASZ1[NX][5]
						        IF ALLTRIM(STL->TL_CODIGO) == ALLTRIM(_ASZ1[NX][6])

						        ENDIF
						        STL->(DBSKIP())
						     ENDDO
						  ENDIF
						  FQ3->(DBSELECTAREA("FQ3"))
						  FQ3->(DBGOTOP())
						  FQ3->(DBSETORDER(2))
						  IF FQ3->(DBSEEK(_ASZ1[NX][2] + _ASZ1[NX][4] + _ASZ1[NX][3]))		
						     WHILE FQ3->(!EOF()) .AND. FQ3->FQ3_FILIAL == _ASZ1[NX][2] .AND. FQ3->FQ3_ASF == _ASZ1[NX][4] .AND. FQ3->FQ3_NUM == _ASZ1[NX][3]
						        IF !EMPTY(FQ3->FQ3_ORDEM)
						           IF ALLTRIM(FQ3->FQ3_PROD) == ALLTRIM(_ASZ1[NX][6])
									  FQ3->(RECLOCK("FQ3", .F.))
									  FQ3->FQ3_NFREM  := _CNOTA
									  FQ3->FQ3_SERREM := ADADOSNF[4]
									  FQ3->(MSUNLOCK())						        
								   ENDIF
						        ENDIF
						        FQ3->(DBSKIP())
						     ENDDO
						  ENDIF
					   ENDIF
					NEXT NX 
				ENDIF	
				
						
			ENDIF
		//	END TRANSACTION
			
			CFILANT := CFILAUX
		ENDIF
		
		ADADOSNF	:= {}
		ACAMPOSSC5	:= {}
		ACAMPOSSC6	:= {}
		AITENS		:= {}
		RESTAREA(AAREASC5)
		RESTAREA(AAREASC6)
		RESTAREA(AAREADA3)
		RESTAREA(AAREASA1)
	ENDIF	
ENDIF

RETURN
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ MARCARREGIº AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ FUNÇÃO AUXILIAR DO LISTBOX, SERVE PARA MARCAR E DESMARCAR  º±±
±±º          ³ OS ITENS.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION MARCARREGI(LTODOS)

LOCAL NI        := 0 
LOCAL LMARCADOS := _ASZ1[OFILOS:NAT,1]

IF LTODOS
	LMARCADOS := ! LMARCADOS
	FOR NI := 1 TO LEN(_ASZ1)
		_ASZ1[NI,1] := LMARCADOS
	NEXT NI 
ELSE
	_ASZ1[OFILOS:NAT,1] := !LMARCADOS
ENDIF

OFILOS:REFRESH()
ODLGFIL:REFRESH()
	
RETURN NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ EXPEDINS  º AUTOR ³ IT UP BUSINESS     º DATA ³ 11/04/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ GERA O PEDIDO DE VENDA PARA O ROMANEIO POSICIONADO         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION EXPEDINS(_ACABEC,_AITENS,LNFREMBE)

IF LEN(_ACABEC) > 0 .AND. LEN(_AITENS) > 0
	INCPROC(STR0078) //"AGUARDE... GERANDO PEDIDO DE VENDA E FATURANDO..."
	MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)},_ACABEC,_AITENS,3)
	IF LMSERROAUTO
		MOSTRAERRO()
		ROLLBACKSX8()
		RETURN .F.
	ELSE
		_CPEDIDO := CNUMSC5
		CONFIRMSX8()
	ENDIF
ELSE
	MSGSTOP(STR0079 , STR0031)  //"NAO EXISTEM REGISTROS PARA GERAÇÃO DO PEDIDO!"###"GPO - LOC05102.PRW"
	RETURN .F. 
ENDIF 
		
RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ GRVNFINS  º AUTOR ³ IT UP BUSINESS     º DATA ³ 11/04/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ LIBERA O PEDIDO DE VENDA E GERA O DOCUMENTO DE SAÍDA.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION GRVNFINS( _CPEDIDO , CTESRF , CTESLF , CSERIE ) 

LOCAL AAREAANT  := GETAREA()
LOCAL AAREASC5  := SC5->(GETAREA())
LOCAL AAREASC6  := SC6->(GETAREA())
LOCAL AAREASC9  := SC9->(GETAREA())
LOCAL AAREASE4  := SE4->(GETAREA())
LOCAL AAREASB1  := SB1->(GETAREA())
LOCAL AAREASB2  := SB2->(GETAREA())
LOCAL AAREASF4  := SF4->(GETAREA())
LOCAL APVLNFS   := {}
LOCAL CQUERY    := "" 
LOCAL CALIASQRY := GETNEXTALIAS()
LOCAL CROT 

CROT := PROCNAME()

//IF !LOCA061() 							// --> VALIDAÇÃO DO LICENCIAMENTO (WS) DO GPO 
//	RETURN 
//ENDIF 

PERGUNTE("MT460A",.F.)

SC5->( DBSETORDER(1) ) 		// C5_FILIAL + C5_NUM
SC6->( DBSETORDER(1) ) 		// C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
SC9->( DBSETORDER(1) ) 		// C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO

CQUERY := " SELECT DISTINCT C5_NUM "
CQUERY += " FROM "+RETSQLNAME("SC5")+" SC5 (NOLOCK) "
CQUERY +=        " JOIN "+RETSQLNAME("SC6")+ " SC6 (NOLOCK) ON C6_FILIAL=C5_FILIAL AND C6_NUM=C5_NUM "
CQUERY += " WHERE  C5_FILIAL='"+XFILIAL("SC5")+"' "
CQUERY += "   AND  C5_NUM     = '"+_CPEDIDO+"' "
CQUERY += "   AND  C5_XPROJET = '"+CPROJET+"' "
CQUERY += "   AND  C6_NOTA    = '' "
CQUERY += "   AND  C6_BLOQUEI = '' "
//CQUERY+="   AND  C6_TES IN ('"+CTESLF+"','"+CTESRF+"') "
CQUERY += "   AND  SC5.D_E_L_E_T_ = '' "
CQUERY += "   AND  SC6.D_E_L_E_T_ = '' "
DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERY),CALIASQRY, .F., .T.)

WHILE ! (CALIASQRY)->( EOF() )
	_CPEDIDO := (CALIASQRY)->C5_NUM
	IF SC5->( MSSEEK( XFILIAL( 'SC5' ) + _CPEDIDO, .F. ) )
		IF SC9->( DBSEEK( XFILIAL("SC9")+_CPEDIDO ) )
			WHILE !SC9->(EOF()) .AND. SC9->C9_PEDIDO == _CPEDIDO
				IF SC6->( DBSEEK( XFILIAL("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO ) )
					
					SE4->( DBSETORDER( 1 ) )
					SE4->( MSSEEK( XFILIAL( 'SE4' ) + SC5->C5_CONDPAG, .F. ) )
					
					// POSICIONA NO PRODUTO
					SB1->( DBSETORDER( 1 ) )
					SB1->( MSSEEK( XFILIAL( 'SB1' ) + SC6->C6_PRODUTO, .F. ) )
					
					// POSICIONA NO SALDO EM ESTOQUE
					SB2->( DBSETORDER( 1 ) )
					SB2->( MSSEEK( XFILIAL( 'SB2' ) + SC6->C6_PRODUTO + SC6->C6_LOCAL, .F. ) )
					
					// POSICIONA NO TES
					CTES := SC6->C6_TES
					SF4->( DBSETORDER( 1 ) )
					SF4->( MSSEEK( XFILIAL( 'SF4' ) + CTES, .F. ) )
					
					_NPRCVEN := SC9->C9_PRCVEN
					
					// MONTA ARRAY PARA GERAR A NOTA FISCAL
					AADD( APVLNFS, { SC9->C9_PEDIDO, ;
					SC9->C9_ITEM, ;
					SC9->C9_SEQUEN, ;
					SC9->C9_QTDLIB, ;
					_NPRCVEN, ;
					SC9->C9_PRODUTO, ;
					.F., ;
					SC9->( RECNO() ), ;
					SC5->( RECNO() ), ;
					SC6->( RECNO() ), ;
					SE4->( RECNO() ), ;
					SB1->( RECNO() ), ;
					SB2->( RECNO() ), ;
					SF4->( RECNO() ) })
				ENDIF
				SC9->( DBSKIP() )
			END
		ENDIF
	ENDIF
	(CALIASQRY)->( DBSKIP() )
ENDDO
(CALIASQRY)->( DBCLOSEAREA() )

DBSELECTAREA( "SC9" )

IF ! EMPTY( APVLNFS )
	_CNOTA := MAPVLNFS(APVLNFS,CSERIE, .F., .F., .F., .T., .F., 0, 0, .T., .F.)
	IF SD2->D2_PEDIDO == _CPEDIDO .AND. SD2->D2_DOC == _CNOTA
		ADADOSNF := {SD2->D2_PEDIDO,SD2->D2_ITEMPV,SD2->D2_DOC,SD2->D2_SERIE}
	ELSE
		// ADCIONAR UMA BUSCA PARA VERIFICAR SE O PEDIDO EXISTE EM ALGUMA NOTA DA TABELA, CASO DESPOSICIONE....	
	ENDIF
ENDIF

// RETORNA AS AREAS ORIGINAIS
RESTAREA( AAREASF4 )
RESTAREA( AAREASB2 )
RESTAREA( AAREASB1 )
RESTAREA( AAREASE4 )
RESTAREA( AAREASC9 )
RESTAREA( AAREASC6 )
RESTAREA( AAREASC5 )
RESTAREA( AAREAANT )

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ XSC5NUM   º AUTOR ³ IT UP BUSINESS     º DATA ³ 04/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ VALIDA O PRÓXIMO NUMERO DO PV					          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION XSC5NUM()
		
SC5->( DBSETORDER(1) )
WHILE .T.
	CNUMSC5 := GETSXENUM("SC5","C5_NUM")
	IF ! SC5->( DBSEEK( XFILIAL("SC5") + CNUMSC5 ) )
		EXIT 
	ENDIF 
	CONFIRMSX8() 
ENDDO 
		
RETURN CNUMSC5 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ XA1ORDEM  º AUTOR ³ IT UP BUSINESS     º DATA ³ 04/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ VERIFICA A ORDEM DOS CAMPOS NO X3				          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION XA1ORDEM(CCAMPO)

LOCAL AAREASX3 := (LOCXCONV(1))->(GETAREA()) 

//DBSELECTAREA("SX3") 
(LOCXCONV(1))->(DBSETORDER(2))
(LOCXCONV(1))->(DBSEEK(CCAMPO)) 
CRET := &(LOCXCONV(4))

RESTAREA(AAREASX3)

RETURN CRET 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ DELINS    º AUTOR ³ IT UP BUSINESS     º DATA ³ 24/04/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ VERIFICA SE É POSSIVEL DELETAR O REGISTRO    	          º±±
±±º          ³ CHAMADA: MENU - "EXCLUIR"                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LOCA02905() 
LOCAL LRET := .T.

IF EMPTY(FQ3->FQ3_NFREM) 
	IF EXISTBLOCK("LOCA029A")
		LRET := EXECBLOCK("LOCA029A" , .T. , .T. , {FQ3->(RECNO())}) 
	EndIf
	If lRet
		If AXDELETA("FQ3", FQ3->(RECNO()), 5 ) == 2
			lRet := .t.
		Else
			lRet := .f.
		EndIF
	EndIF
	IF EXISTBLOCK("LOCA029B")
		EXECBLOCK("LOCA029B" , .T. , .T. , {lRet}) 
	EndIf
ELSE 
	MSGSTOP(STR0082 , STR0031)  //"NÃO É POSSIVEL DELETAR O INSUMO, POIS JÁ TEM NF REMESSA GERADA."###"GPO - LOC05102.PRW"
ENDIF   

RETURN



/*
CONSULTORIA  : IT UP BUSINESS 
DESENVOLVEDOR: IT UP BUSINESS 
DESCRIÇÃO    : VERIFICA SE NÃO TEM NOTA DE REMESSA OU RETORNO GERADA PARA O ROMANEIO. 
RETORNO      : .T. = NÃO TEM NOTA DE RETORNO E/OU REMESSA
 			   .F. = TEM NOTA DE RETORNO E/OU REMESSA
*/              
// ======================================================================= \\
FUNCTION LOCA02906(CNUMROMA,CTIPO)
// ======================================================================= \\

LOCAL LRET := .F.

DBSELECTAREA("FQ3")
DBSETORDER(1)					// FQ3_FILIAL + FQ3_NUM 
IF FQ3->(DBSEEK(XFILIAL("FQ3")+FQ2->FQ2_NUM))
	DBSELECTAREA("FPA")
	DBSETORDER(3)
	WHILE FQ3->(!EOF()) .AND. FQ3->FQ3_NUM == FQ2->FQ2_NUM
		DBSELECTAREA("FPA")
		FPA->(DBSETORDER(3)) 	// FPA_FILIAL+FPA_AS+FPA_VIAGEM
		IF FPA->(DBSEEK(XFILIAL("FPA")+FQ3->FQ3_AS+FQ3->FQ3_VIAGEM))
			IF CTIPO == "0"
				IF EMPTY(FPA->FPA_NFREM)
					LRET := .T.
				ELSE
					AVISO("",STR0083) //"ROMANEIO COM NOTA DE REMESSA GERADA."
					RETURN LRET
				ENDIF
			ELSEIF CTIPO == "1"
				IF EMPTY(FPA->FPA_NFRET)
					LRET := .T.
				ELSE
					AVISO("",STR0084) //"ROMANEIO COM NOTA DE RETORNO GERADA."
					RETURN LRET
				ENDIF
			ENDIF
		ELSE
			MSGALERT(STR0085 , STR0031) //"NÃO ENCONTRADO LOCAÇÃO PARA O ROMANEIO INFORMADO."###"GPO - LOC05102.PRW"
			RETURN LRET
		ENDIF
		FQ3->(DBSKIP())
	ENDDO
ELSE
	MSGALERT(STR0086 , STR0031) //"NÃO EXISTE ITEM VINCULADO AO ROMANEIO"###"GPO - LOC05102.PRW"
	LRET := .F.
ENDIF

RETURN LRET


// FRANK Z FUGA EM 25/09/2020
// ROTINA PARA APRESENTACAO DAS LEGENDAS
FUNCTION LOCA02907()
LOCAL _ALEGENDA := {}

AADD(_ALEGENDA , {"BR_VERDE"    , STR0087})  //"ROMANEIO DE EXPEDIÇÃO COM NF"
AADD(_ALEGENDA , {"BR_AMARELO"  , STR0088})  //"ROMANEIO DE EXPEDIÇÃO SEM NF"
AADD(_ALEGENDA , {"BR_AZUL"     , STR0089 })  //"ROMANEIO DE RETORNO COM NF"
AADD(_ALEGENDA , {"BR_VERMELHO"  , STR0090})  //"ROMANEIO DE RETORNO SEM NF"
    If ExistBlock("LOCA029E") //Frank Z Fuga - 18/05/2022 - Chamado 29564 - Novas legendas
        _aLegenda := ExecBlock("LOCA029E" , .T. , .T. , {_aLegenda}) 
    EndIf

BRWLEGENDA(STR0027 , STR0011 , _ALEGENDA)  //"STATUS"###"LEGENDA"

RETURN


// FRANK ZWARG FUGA - 25/09/2020
// VERIFICAR A LEGENDA PARA A MBROWSE
FUNCTION LOCA02908()
LOCAL _NCOR
LOCAL _AAREA := GETAREA()
// 1 = ROMANEIO EXPEDICAO COM NF
// 2 = ROMANEIO EXPEDICAO SEM NF
// 3 = ROMANEIO RETORNO COM NF
// 4 = ROMANEIO RETORNO SEM NF

//FPA->(DBSETORDER(2))
//FPA->(DBSEEK(XFILIAL("FPA")+FQ2->(FQ2_PROJET+FQ2_OBRA+FQ2_ASF)))

FQ3->(DBSETORDER(1))
FQ3->(DBSEEK(XFILIAL("FQ3")+FQ2->FQ2_NUM))
IF FQ2->FQ2_TPROMA == "0"
	_NCOR := 2 // SEM NOTA
ENDIF
IF FQ2->FQ2_TPROMA == "1"
	_NCOR := 4 // SEM NOTA
ENDIF

WHILE !FQ3->(EOF()) .AND. FQ3->FQ3_FILIAL == XFILIAL("FQ3") .AND. FQ2->FQ2_NUM == FQ3->FQ3_NUM
	IF !EMPTY(FQ3->FQ3_NFREM) .AND. FQ2->FQ2_TPROMA == "0"
		_NCOR := 1 // COM NOTA
	ENDIF
	IF !EMPTY(FQ3->FQ3_NFRET) .AND. FQ2->FQ2_TPROMA == "1"
		_NCOR := 3 // COM NOTA
	ENDIF

	FQ3->(DBSKIP())
ENDDO

    If ExistBlock("LOCA029D") //Frank Z Fuga - 18/05/2022 - Chamado 29564 - Novas legendas
        _nCor := ExecBlock("LOCA029D" , .T. , .T. , {_nCor}) 
    EndIf
RESTAREA(_AAREA)
RETURN _NCOR

// IDENTIFICACAO DO CONJUNTO TRANSPORTADOR PARA A EMISSAO DA NOTA
// FRANK Z FUGA - 02/11/20
FUNCTION LOCA02909()
LOCAL NJANELAA    := 385 
LOCAL NJANELAL    := 1103
LOCAL _NRET       := 0
LOCAL OFILBUT
LOCAL NOPC        := 0
LOCAL OCANBUT
LOCAL NLBTAML	  := 540	
LOCAL NLBTAMA	  := 145	
LOCAL LMARK       := .F.
LOCAL   OOK       := LOADBITMAP(GETRESOURCES(),"LBOK")
LOCAL   ONO       := LOADBITMAP(GETRESOURCES(),"LBNO") 
LOCAL _NX
LOCAL _LPODE      := .F.
LOCAL NOPC        := "0"

PRIVATE _ACONJ	  := {}
PRIVATE OFILCONJ
PRIVATE ODLGCONJ

FQ7->(DBSETORDER(2))
FQ7->(DBSEEK(XFILIAL("FQ7")+FQ2->FQ2_PROJET+FQ2->FQ2_OBRA))
WHILE !FQ7->(EOF()) .AND. FQ7->(FQ7_FILIAL+FQ7_PROJET+FQ7_OBRA) == XFILIAL("FQ7")+FQ2->FQ2_PROJET+FQ2->FQ2_OBRA
	IF FQ7->FQ7_TPROMA == "1" .AND. EMPTY(FQ7->FQ7_NFRET)

		// Card 398 - sprint bug - Frank em 14/07/2022
		If FQ7->FQ7_VIAGEM <> FQ2->FQ2_VIAGEM
			FQ7->(dbSkip())
			Loop
		EndIf

		AADD(_ACONJ,{ .F.,;
					  FQ7->FQ7_PROJET,;
					  FQ7->FQ7_OBRA,;
					  FQ7->FQ7_SEQGUI,;
					  FQ7->FQ7_ITEM,;
					  FQ7->FQ7_CC,;
					  FQ7->FQ7_PRECUS,;
					  FQ7->FQ7_VIAGEM,;
					  FQ7->FQ7_DTLIM,;
					  FQ7->FQ7_LCCORI,;
					  FQ7->FQ7_LCLORI,;
					  FQ7->FQ7_LOCCAR,;
					  FQ7->FQ7_LCCDES,;
					  FQ7->FQ7_LCLDES,;
					  FQ7->FQ7_LOCDES,;
					  FQ7->FQ7_VIAORI,;
					  FQ7->(RECNO())})
	ENDIF
	FQ7->(DBSKIP())
ENDDO

IF LEN(_ACONJ) == 0
	MSGALERT(STR0091,STR0029) //"NENHUM CONJUNTO TRANSPORTADOR FOI LOCALIZADO."###"ATENÇÃO!"
	RETURN 0
ENDIF

DEFINE MSDIALOG ODLGCONJ TITLE STR0092 FROM 010,005 TO NJANELAA,NJANELAL PIXEL//OF OMAINWND //"SELEÇÃO DO CONJUNTO TRANSPORTADOR"
	    @ 0.5,0.7 LISTBOX OFILCONJ FIELDS HEADER  " ",STR0035,STR0093,STR0094,STR0095,STR0096,STR0097,STR0098,STR0099,STR0100,STR0101,STR0102,STR0103,STR0104,STR0105,STR0106,STR0107 SIZE NLBTAML,NLBTAMA ON DBLCLICK (MARCAR2()) //"PROJETO"###"OBRA"###"LOCAÇÃO"###"ITEM"###"CENTRO CUSTO"###"PREV.CUSTO"###"VIAGEM"###"DATA LIMITE"###"CLIENTE ORIGEM"###"LOJA ORIGEM"###"CARREGAMENTO"###"CLIENTE DESTINO"###"LOJA DESTINO"###"DESCARREGAMENTO"###"VIAGEM ORIGEM"###"REGISTRO"
	    OFILCONJ:SETARRAY(_ACONJ)
	    OFILCONJ:BLINE := {|| { IF( _ACONJ[OFILCONJ:NAT,1],OOK,ONO),;   
								    _ACONJ[OFILCONJ:NAT,2],;   	 	   
									_ACONJ[OFILCONJ:NAT,3],;
									_ACONJ[OFILCONJ:NAT,4],;
									_ACONJ[OFILCONJ:NAT,5],;
									_ACONJ[OFILCONJ:NAT,6],;
									_ACONJ[OFILCONJ:NAT,7],;
									_ACONJ[OFILCONJ:NAT,8],;
									_ACONJ[OFILCONJ:NAT,9],;
									_ACONJ[OFILCONJ:NAT,10],;
									_ACONJ[OFILCONJ:NAT,11],;
									_ACONJ[OFILCONJ:NAT,12],;
									_ACONJ[OFILCONJ:NAT,13],;
								    _ACONJ[OFILCONJ:NAT,14],;
									_ACONJ[OFILCONJ:NAT,15],;
									_ACONJ[OFILCONJ:NAT,16],;
									_ACONJ[OFILCONJ:NAT,17]}}            
		
		@ 172,007 BUTTON OFILBUT PROMPT STR0108 SIZE 50,12 OF ODLGCONJ PIXEL ;  //"SELEÇÃO"
		                 ACTION ( IIF(MSGYESNO(OEMTOANSI(STR0109) , STR0092) , ;  //"DESEJA MESMO GERAR NF RETORNO PARA ESTE CONJUNTO TRANSPORTADOR?"###"SELEÇÃO DO CONJUNTO TRANSPORTADOR"
		                              NOPC := "1"  , ; 
		                              NOPC := "0") , ; 
		                         ODLGCONJ:END() ) 
	    @ 172,062 BUTTON   OCANBUT PROMPT STR0053             SIZE 50,12 OF ODLGCONJ PIXEL ACTION (NOPC := "0", ODLGCONJ:END()) //"CANCELAR"
    ACTIVATE MSDIALOG ODLGCONJ CENTERED

	IF NOPC == "1"
		_LPODE := .F.
		FOR _NX := 1 TO LEN(_ACONJ)
			IF _ACONJ[_NX,1]
				_LPODE := .T.
				_NRET := _ACONJ[_NX][17]
				EXIT
			ENDIF
		NEXT
		IF !_LPODE
			MSGALERT(STR0110,STR0029) //"NENHUM CONJUNTO TRANSPORTADOR FOI SELECIONADO."###"ATENÇÃO!"
			_NRET := 0
		ENDIF
	ELSE
		MSGALERT(STR0111,STR0029) //"EMISSÃO DA NOTA CANCELADA."###"ATENÇÃO!"
		_NRET := 0
	ENDIF
    
RETURN _NRET

// CONTROLE DA SELECAO DOS CONJUNTOS TRANSPORTADORES
STATIC FUNCTION MARCAR2()
LOCAL NI        := 0 
LOCAL LMARCADOS := _ACONJ[OFILCONJ:NAT,1]
LOCAL _NX       
LOCAL _LPODE    := .T.

FOR _NX := 1 TO LEN(_ACONJ)
	IF _ACONJ[_NX,1] .AND. OFILCONJ:NAT <> _NX
		_LPODE := .F.
	ENDIF
NEXT

IF _LPODE
	_ACONJ[OFILCONJ:NAT,1] := !LMARCADOS
ELSE
	MSGALERT(STR0112,STR0029) //"JÁ EXISTE UMA SELEÇÃO DE UM CONJUNTO TRANSPORDADOR."###"ATENÇÃO!"
	_ACONJ[OFILCONJ:NAT,1] := .F.
ENDIF

OFILCONJ:REFRESH()
ODLGCONJ:REFRESH()
	
RETURN NIL
//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA02910

Retorna o peso dos itens do Romaneio
@type Function
@author Jose Eulalio
@since 01/06/2022

/*/
//------------------------------------------------------------------------------
Function LOCA02910(_LROMANEIO)
Local nPeso		:= 0
Local nPesBru	:= 0
Local nX		:= 0
Local aArea		:= GetArea()

Default _LROMANEIO	:= .F.

If _LROMANEIO 
	// por ser romaneio ja esta posicionado na FQ2
	// rotina chamada do loca010
	FQ3->(dbSetOrder(1))
	FQ3->(dbSeek(xFilial("FQ3")+FQ2->FQ2_NUM))
	While !FQ3->(Eof()) .and. FQ3->(FQ3_FILIAL+FQ3_NUM) == xFilial("FQ3")+FQ2->FQ2_NUM
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+FQ3->FQ3_PROD))
		nPeso	+= FQ3->FQ3_QTD * SB1->B1_PESO
		nPesBru	+= FQ3->FQ3_QTD * SB1->B1_PESBRU
		FQ3->(dbSkip())
	EndDo
EndIf

RestArea(aArea)

Return {nPeso,nPesBru}

/*
// ======================================================================= \\
STATIC FUNCTION QTDENV( _CAS )
// ======================================================================= \\

LOCAL   _AAREAOLD := GETAREA()
LOCAL   _NRET     := .T.
LOCAL   _CQUERY   := ""

IF SELECT("TRBQTD") > 0
	TRBQTD->(DBCLOSEAREA())
ENDIF
_CQUERY := " SELECT SUM(C6_QTDVEN) QTD" + CRLF
_CQUERY += " FROM " + RETSQLNAME("SC6") + " SC6 (NOLOCK) " + CRLF
_CQUERY += "        INNER JOIN " + RETSQLNAME("SC5") + " SC5 (NOLOCK) ON  SC5.C5_FILIAL  = '" + XFILIAL("SC5") + "' "              + CRLF
_CQUERY += "                                                          AND SC5.C5_NUM     = SC6.C6_NUM  AND  SC5.C5_XTIPFAT = 'R' " + CRLF
_CQUERY += "                                                          AND SC5.D_E_L_E_T_ = '' "                                    + CRLF
_CQUERY += " WHERE  SC6.C6_FILIAL  =  '" + XFILIAL("SC6") + "' " + CRLF
_CQUERY += "   AND  SC6.C6_XAS     =  '" + _CAS + "' "           + CRLF
_CQUERY += "   AND  SC6.C6_XAS     <> '' "                       + CRLF
_CQUERY += "   AND  SC6.C6_BLQ NOT IN ('R','S') "                + CRLF
_CQUERY += "   AND  SC6.D_E_L_E_T_ =  '' "
CONOUT("[GERNFREM.PRW] # _CQUERY(5): " + _CQUERY) 
_CQUERY := CHANGEQUERY(_CQUERY) 
TCQUERY _CQUERY NEW ALIAS "TRBQTD"

IF TRBQTD->(!EOF())
	_NRET := TRBQTD->QTD
ENDIF

TRBQTD->(DBCLOSEAREA())

RESTAREA( _AAREAOLD )

RETURN _NRET
*/
