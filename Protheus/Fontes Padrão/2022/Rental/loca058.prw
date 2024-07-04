/*/{PROTHEUS.DOC} LOCA058.PRW 
ITUP BUSINESS - TOTVS RENTAL
TELA DE APROVAวรO DE CONTRATO/PROJETOS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

FUNCTION LOCA058()
LOCAL _AAREAOLD := GETAREA() 
LOCAL _CCODUSR  := RETCODUSR() 

//IF !LOCA061() 								// --> VALIDAวรO DO LICENCIAMENTO (WS) DO GPO 
	//RESTAREA( _AAREAOLD )
	//RETURN NIL 
//ENDIF 

IF ! GETMV("MV_LOCX020")
	MSGALERT("ROTINA 'APROVAวรO DE CONTRATO/PROJETOS' DESABILITADA PELO PARยMETRO MV_LOCX020" , "GPO - LOCT067B.PRW") 
	RESTAREA( _AAREAOLD )
	RETURN NIL
ENDIF

IF _CCODUSR != "000000" .AND. ! FPR->(DBSEEK(XFILIAL("FPR") + _CCODUSR))
	MSGALERT("ATENวรO: VOCส NรO POSSUI AUTORIZAวรO PARA EFETUAR APROVAวรO DE PROJETOS." , "GPO - LOCT067B.PRW") 
	RESTAREA( _AAREAOLD )
	RETURN .F.
ENDIF

MONTATELA()

RESTAREA( _AAREAOLD )

RETURN



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ MONTALBX  บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 07/01/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑณDESCRI…O ณ MONTA QUERY PARA EXTRAIR REGISTROS PENDENTES DE APROVAวรO. ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION MONTALBX()

LOCAL _CQUERY  := ""

_AZA0LIST := {}
_AITENS   := {}

_CQUERY := " SELECT CASE WHEN ZA0_STATUS = '2' THEN 'BR_CINZA'"
_CQUERY += "             WHEN ZA0_STATUS = '3' THEN 'BR_VERDE'"                                                                 	 +CRLF
_CQUERY += "             WHEN ZA0_STATUS = '6' THEN 'BR_VERMELHO' ELSE 'BR_BRANCO' END ZA0_STATUS, ZA0_STATUS ZA0_STSLEG,"           +CRLF
_CQUERY += "       ZA0_PROJET, ZA0_CLI + '/' + ZA0_LOJA + ' - ' + ISNULL(A1_NOME,' ') ZA0_CLINOM,"                                   +CRLF
_CQUERY += "      CASE WHEN ZA0_TIPFAT = 'P'"                                                                                        +CRLF
_CQUERY += "           THEN 'PADRรO'"                                                                                                +CRLF
_CQUERY += "           WHEN ZA0_TIPFAT = 'M'"                                                                                        +CRLF
_CQUERY += "           THEN 'MEDIวรO'"                                                                                               +CRLF
_CQUERY += "           ELSE ZA0_TIPFAT END ZA0_TIPFAT,"                                                                              +CRLF
_CQUERY += "       CASE WHEN ZA0_TIPOSE = 'T'"                                                                                       +CRLF
_CQUERY += "           THEN 'TRANSPORTE'"                                                                                            +CRLF
_CQUERY += "           WHEN ZA0_TIPOSE = 'G'"                                                                                        +CRLF
_CQUERY += "           THEN 'EQUIPAMENTO'"                                                                                           +CRLF
_CQUERY += "           WHEN ZA0_TIPOSE IN ('P','L')"                                                                                 +CRLF
_CQUERY += "           THEN 'LOCAวรO' "                                                                                              +CRLF
_CQUERY += "           ELSE ZA0_TIPOSE END ZA0_TIPOSE,"                                                                              +CRLF
_CQUERY += "       CASE WHEN ZA0_TIPOSE = 'T' "                                                                                      +CRLF
_CQUERY += "           THEN MIN(ZA6_DTINI)"                                                                                          +CRLF
_CQUERY += "           WHEN ZA0_TIPOSE = 'G'"                                                                                        +CRLF
_CQUERY += "           THEN MIN(FP4_DTINI)"                                                                                          +CRLF
_CQUERY += "           WHEN ZA0_TIPOSE IN ('P','L')"                                                                                 +CRLF
_CQUERY += "           THEN MIN(FPA_DTINI) END DTINI,"                                                                               +CRLF
_CQUERY += "       CASE WHEN ZA0_TIPOSE = 'T'"                                                                                       +CRLF
_CQUERY += "           THEN MAX(ZA6_DTFIM)"                                                                                          +CRLF
_CQUERY += "           WHEN ZA0_TIPOSE = 'G'"                                                                                        +CRLF
_CQUERY += "           THEN MAX(FP4_DTFIM)"                                                                                          +CRLF
_CQUERY += "           WHEN ZA0_TIPOSE IN ('P','L')"                                                                                 +CRLF
_CQUERY += "           THEN MAX(FPA_DTFIM) END DTFIM,"                                                                               +CRLF
_CQUERY += "       SUM(FPA_MINDIA) AREA,"                                                       									 +CRLF
_CQUERY += "       CASE WHEN ZA0_TIPOSE = 'T'"                                                                                       +CRLF
_CQUERY += "           THEN SUM(ZA6_VRDIA)"                                                                    						 +CRLF
_CQUERY += "           WHEN ZA0_TIPOSE = 'G'"                                                                                        +CRLF
_CQUERY += "           THEN SUM(FP4_VRHOR)"                                                                                			 +CRLF
_CQUERY += "           WHEN ZA0_TIPOSE IN ('P','L')"                                                                                 +CRLF
_CQUERY += "           THEN SUM(FPA_VRHOR) END VALUN,"                                                                    			 +CRLF
_CQUERY += "       CASE WHEN ZA0_TIPOSE = 'T'"                                                                                       +CRLF
_CQUERY += "           THEN SUM((ZA6_DIASV+ZA6_DIASC)*ZA6_VRDIA)"                                                                    +CRLF
_CQUERY += "           WHEN ZA0_TIPOSE = 'G'"                                                                                        +CRLF
_CQUERY += "           THEN SUM(FP4_QUANT*FP4_VRHOR)"                                                                                +CRLF
_CQUERY += "           WHEN ZA0_TIPOSE IN ('P','L')"                                                                                 +CRLF
_CQUERY += "           THEN SUM(FPA_MINDIA*FPA_VRHOR) END VALMEN,"                                                                   +CRLF
_CQUERY += "       MAX(FPA_MINMES) FPA_MINMES, ZA0_DATINC,"                                                                 		 +CRLF
_CQUERY += "       MAX(FPA_DIAM) FPA_DIAM "                                                                 			 			 +CRLF
_CQUERY += "  FROM " + RETSQLNAME("FP0") + " LEFT JOIN " + RETSQLNAME("SA1")                                                         +CRLF
_CQUERY += "    ON ZA0_CLI  = A1_COD"                                                                                                +CRLF
_CQUERY += "   AND ZA0_LOJA = A1_LOJA"                                                                                               +CRLF
_CQUERY += "   AND " + RETSQLNAME("SA1") + ".D_E_L_E_T_ = ''"                                                                      +CRLF
_CQUERY += "       LEFT JOIN " + RETSQLNAME("FPA")                                                                                   +CRLF
_CQUERY += "    ON ZA0_FILIAL = FPA_FILIAL AND ZA0_PROJET = FPA_PROJET"                                                              +CRLF
_CQUERY += "   AND " + RETSQLNAME("FPA") + ".D_E_L_E_T_ = ''"                                                                      +CRLF
_CQUERY += "       LEFT JOIN " + RETSQLNAME("FP4")                                                                                   +CRLF
_CQUERY += "    ON ZA0_FILIAL = FP4_FILIAL AND ZA0_PROJET = FP4_PROJET"                                                              +CRLF
_CQUERY += "   AND " + RETSQLNAME("FP4") + ".D_E_L_E_T_ = ''"                                                                      +CRLF
_CQUERY += "       LEFT JOIN " + RETSQLNAME("ZA6")                                                                                   +CRLF
_CQUERY += "    ON ZA0_FILIAL = ZA6_FILIAL AND ZA0_PROJET = ZA6_PROJET"                                                              +CRLF
_CQUERY += "   AND " + RETSQLNAME("ZA6") + ".D_E_L_E_T_ = ''"                                                                      +CRLF
_CQUERY += " WHERE ZA0_FILIAL = '" + XFILIAL("FP0")+ "'"                                                                             +CRLF
DO CASE
CASE ASCAN(_ACFIL,_CCFIL) == 2 	// PENDENTES
	_CQUERY += "   AND ZA0_STATUS = '2'"                                                                                      		 +CRLF
CASE ASCAN(_ACFIL,_CCFIL) == 3 	// APROVADOS
	_CQUERY += "   AND ZA0_STATUS = '3'"                                                                                      		 +CRLF
CASE ASCAN(_ACFIL,_CCFIL) == 4 	// REPROVADOS
	_CQUERY += "   AND ZA0_STATUS = '7'"                                                                                  			 +CRLF
OTHERWISE //TODOS
	_CQUERY += "   AND ZA0_STATUS IN ('2','3','7')"                                                                                  +CRLF
ENDCASE
IF !EMPTY(ALLTRIM(_CBUSCA))
	_CQUERY += "   AND ZA0_PROJET LIKE '%" + STRTRAN(STRTRAN(ALLTRIM(_CBUSCA)," ","%"),"'","%") + "%'"                               +CRLF
ENDIF
_CQUERY += "   AND " + RETSQLNAME("FP0") + ".D_E_L_E_T_ = ''"                                                                      +CRLF
_CQUERY += " GROUP BY ZA0_STATUS, ZA0_PROJET, ZA0_CLI, ZA0_LOJA, A1_NOME, ZA0_TIPFAT, ZA0_TIPOSE, ZA0_DATINC"+CRLF
_CQUERY += " ORDER BY ZA0_DATINC, DTINI, ZA0_PROJET"                                                                                 +CRLF

IF SELECT("TRB") > 0
	TRB->(DBCLOSEAREA())
ENDIF

TCQUERY _CQUERY NEW ALIAS "TRB"

IF TRB->(!EOF())
	_AITENS := EXBITENS(TRB->ZA0_PROJET,TRB->ZA0_TIPOSE)
	_CSAY := "ITENS DO PROJETO: " + TRB->ZA0_PROJET
	WHILE TRB->(!EOF())
		AADD(_AZA0LIST,{LOADBITMAP(GETRESOURCES(),TRB->ZA0_STATUS),ALLTRIM(ZA0_PROJET), ALLTRIM(ZA0_CLINOM),;
						  ALLTRIM(TRANSFORM(TRB->AREA,"@E 999,999,999,999.99")),ALLTRIM(TRANSFORM(TRB->VALUN,"@E 999,999,999,999.99")),ALLTRIM(TRANSFORM(TRB->VALMEN,"@E 999,999,999,999.99")),;
						  ROUND((STOD(TRB->DTFIM)-STOD(TRB->DTINI))/30,1), STOD(TRB->DTINI), STOD(TRB->DTFIM), TRB->ZA0_TIPFAT, TRB->ZA0_TIPOSE })
		TRB->(DBSKIP())
	ENDDO             
ELSE
 //	MSGALERT("NรO Hม CONTRATOS A SEREM APROVADAS!")
	AADD(_AZA0LIST,{LOADBITMAP(GETRESOURCES(),"BR_BRANCO"),"","",;
			 "","","",0,STOD(""),STOD(""),"",""})
	AADD(_AITENS,{"","","","","",0,STOD(""),STOD("")})
ENDIF

TRB->(DBCLOSEAREA()) 

RETURN _AZA0LIST



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ MONTATELA บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 07/01/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑณDESCRI…O ณ MONTA INTERFACE GRมFICA PARA EXIBIวรO DOS REGISTROS        ณฑฑ
ฑฑณ   		 ณ PENDENTES DE APROVAวรO.      			  				  ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION MONTATELA()

LOCAL _AAREAOLD := GETAREA()
LOCAL _CLISTBOX  := "" 
LOCAL _CITENS	 := "" 
LOCAL _CSAY		 := ""
LOCAL OZA0LIST                            
LOCAL OZA0ITENS
LOCAL _NMYWIDTH  := OMAINWND:NCLIENTWIDTH
LOCAL _NMULT	 := 1
LOCAL BACAO      := NIL

PRIVATE _AZA0LIST := {}
PRIVATE _AITENS   := {}
PRIVATE _CBUSCA   := SPACE(70)
PRIVATE _ACFIL    := {"TODOS","PENDENTES","APROVADOS","REPROVADOS"}
PRIVATE _CCFIL    := "PENDENTES"

_AZA0LIST   := MONTALBX()

IF     _NMYWIDTH >= 1025 .AND. _NMYWIDTH <= 1280    // 1225  
	_NMULT := 0.94
ELSEIF _NMYWIDTH >=  801 .AND. _NMYWIDTH <= 1024 	//  969  
	_NMULT := 0.81                                                          
ELSEIF _NMYWIDTH <=  800                         	// 745 
	_NMULT := 0.57
ENDIF

DEFINE MSDIALOG OZA0DLG TITLE "CONTROLE DE APROVAวรO" FROM 0,0 TO 37*_NMULT,159*_NMULT OF OMAINWND

@ 7.0,6 SAY OZA0BUSCA VAR "BUSCA POR PROJETO:" SIZE 270,12 OF OZA0DLG PIXEL

OZA0LPESQ := TGET():NEW( 005.5*_NMULT,060*_NMULT,{|U|IF(PCOUNT()>0,_CBUSCA:=U,_CBUSCA )},OZA0DLG,460*_NMULT,010*_NMULT,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F., "", "_CBUSCA",,)

@ 5.0,525.0 BUTTON OZA0BPESQ PROMPT "PESQUISAR" SIZE 45*_NMULT,12*_NMULT OF OZA0DLG PIXEL ACTION (_AZA0LIST:=MONTALBX(),OZA0LIST:SETARRAY(_AZA0LIST),OZA0LIST:REFRESH(),;
OZA0LIST:BLINE := { || {_AZA0LIST[OZA0LIST:NAT,01],_AZA0LIST[OZA0LIST:NAT,02],_AZA0LIST[OZA0LIST:NAT,03],_AZA0LIST[OZA0LIST:NAT,04],;
						   _AZA0LIST[OZA0LIST:NAT,05],_AZA0LIST[OZA0LIST:NAT,06],_AZA0LIST[OZA0LIST:NAT,07],_AZA0LIST[OZA0LIST:NAT,08],;
						   _AZA0LIST[OZA0LIST:NAT,09],_AZA0LIST[OZA0LIST:NAT,10],_AZA0LIST[OZA0LIST:NAT,11] }},OZA0LIST:REFRESH(),_AITENS:=EXBITENS(_AZA0LIST[OZA0LIST:NAT,02],_AZA0LIST[OZA0LIST:NAT,05]),OZA0ITENS:SETARRAY(_AITENS),;
		  		 OZA0ITENS:BLINE := { || {_AITENS[OZA0ITENS:NAT,01],_AITENS[OZA0ITENS:NAT,02],_AITENS[OZA0ITENS:NAT,03],_AITENS[OZA0ITENS:NAT,04],_AITENS[OZA0ITENS:NAT,05],_AITENS[OZA0ITENS:NAT,06],_AITENS[OZA0ITENS:NAT,07],_AITENS[OZA0ITENS:NAT,08]}},OZA0ITENS:REFRESH(),;
		  		 IIF(EMPTY(_AZA0LIST[OZA0LIST:NAT,02]),(OZA0APROV:DISABLE(),OZA0REPROV:DISABLE(),OZA0VISU:DISABLE()),(OZA0APROV:ENABLE(),OZA0REPROV:ENABLE(),OZA0VISU:ENABLE())))  

@ 1.5,.7 LISTBOX OZA0LIST VAR _CLISTBOX FIELDS ;
HEADER  " ", "PROJETO", "CLIENTE", "มREA", "VALOR มREA", "VALOR MENSAL", "MESES LOCAวรO", "DATA INICIAL", "DATA FINAL", "TIPO FAT.", "TIPO"; 
SIZE 568*_NMULT,180*_NMULT ON DBLCLICK;
(IIF(!EMPTY(_AZA0LIST[OZA0LIST:NAT,02] .AND. MSGYESNO("DESEJA APROVAR O PROJETO " + _AZA0LIST[OZA0LIST:NAT,02] + "?")),(PROCESSA({|| APROV(_AZA0LIST[OZA0LIST:NAT,02]) },"APROVANDO PROJETO " + ALLTRIM(_AZA0LIST[OZA0LIST:NAT,02]) + "..."),_AZA0LIST:=MONTALBX(),OZA0LIST:SETARRAY(_AZA0LIST),OZA0LIST:REFRESH(),;
OZA0LIST:BLINE := { || {_AZA0LIST[OZA0LIST:NAT,01],_AZA0LIST[OZA0LIST:NAT,02],_AZA0LIST[OZA0LIST:NAT,03],_AZA0LIST[OZA0LIST:NAT,04],;
						   _AZA0LIST[OZA0LIST:NAT,05],_AZA0LIST[OZA0LIST:NAT,06],_AZA0LIST[OZA0LIST:NAT,07],_AZA0LIST[OZA0LIST:NAT,08],;
						   _AZA0LIST[OZA0LIST:NAT,09],_AZA0LIST[OZA0LIST:NAT,10],_AZA0LIST[OZA0LIST:NAT,11] }},OZA0LIST:REFRESH(),_AITENS:=EXBITENS(_AZA0LIST[OZA0LIST:NAT,02],_AZA0LIST[OZA0LIST:NAT,05]),OZA0ITENS:SETARRAY(_AITENS),;
		  		 OZA0ITENS:BLINE := { || {_AITENS[OZA0ITENS:NAT,01],_AITENS[OZA0ITENS:NAT,02],_AITENS[OZA0ITENS:NAT,03],_AITENS[OZA0ITENS:NAT,04],_AITENS[OZA0ITENS:NAT,05],_AITENS[OZA0ITENS:NAT,06],_AITENS[OZA0ITENS:NAT,07],_AITENS[OZA0ITENS:NAT,08]}},OZA0ITENS:REFRESH(),;
		  		 IIF(EMPTY(_AZA0LIST[OZA0LIST:NAT,02]),(OZA0APROV:DISABLE(),OZA0REPROV:DISABLE(),OZA0VISU:DISABLE()),(OZA0APROV:ENABLE(),OZA0REPROV:ENABLE(),OZA0VISU:ENABLE()))),),IF(BACAO==NIL,,EVAL(BACAO)),OZA0LIST:REFRESH()) NOSCROLL ON CHANGE;
(_AITENS := EXBITENS(_AZA0LIST[OZA0LIST:NAT,02],_AZA0LIST[OZA0LIST:NAT,05]),;
		  				 _CSAY := "ITENS DO PROJETO: " + _AZA0LIST[OZA0LIST:NAT,02],;
		  				 OZA0SAY:REFRESH(),OZA0ITENS:SETARRAY(_AITENS),;
		  				 OZA0ITENS:BLINE := { || {_AITENS[OZA0ITENS:NAT,01],_AITENS[OZA0ITENS:NAT,02],_AITENS[OZA0ITENS:NAT,03],_AITENS[OZA0ITENS:NAT,04],_AITENS[OZA0ITENS:NAT,05],_AITENS[OZA0ITENS:NAT,06],_AITENS[OZA0ITENS:NAT,07],_AITENS[OZA0ITENS:NAT,08]}},OZA0ITENS:REFRESH(),;
		  		 IIF(EMPTY(_AZA0LIST[OZA0LIST:NAT,02]),(OZA0APROV:DISABLE(),OZA0REPROV:DISABLE(),OZA0VISU:DISABLE()),(OZA0APROV:ENABLE(),OZA0REPROV:ENABLE(),OZA0VISU:ENABLE())))

OZA0LIST:SETARRAY(_AZA0LIST)
OZA0LIST:BLINE := { || {_AZA0LIST[OZA0LIST:NAT,01],_AZA0LIST[OZA0LIST:NAT,02],_AZA0LIST[OZA0LIST:NAT,03],_AZA0LIST[OZA0LIST:NAT,04],;
						   _AZA0LIST[OZA0LIST:NAT,05],_AZA0LIST[OZA0LIST:NAT,06],_AZA0LIST[OZA0LIST:NAT,07],_AZA0LIST[OZA0LIST:NAT,08],;
						   _AZA0LIST[OZA0LIST:NAT,09],_AZA0LIST[OZA0LIST:NAT,10],_AZA0LIST[OZA0LIST:NAT,11] }}
	
@   5.0,580 BUTTON OZA0OKAY   PROMPT "FECHAR"       SIZE 45*_NMULT,12*_NMULT OF OZA0DLG PIXEL ACTION (OZA0DLG:END())
@  19.5,580 BUTTON OZA0APROV  PROMPT "APROVAR" 	    SIZE 45*_NMULT,12*_NMULT OF OZA0DLG PIXEL ACTION (PROCESSA({|| APROV(_AZA0LIST[OZA0LIST:NAT,02]) },"APROVANDO PROJETO " + ALLTRIM(_AZA0LIST[OZA0LIST:NAT,02]) + "..."),_AZA0LIST:=MONTALBX(),OZA0LIST:SETARRAY(_AZA0LIST),OZA0LIST:REFRESH(),;
OZA0LIST:BLINE := { || {_AZA0LIST[OZA0LIST:NAT,01],_AZA0LIST[OZA0LIST:NAT,02],_AZA0LIST[OZA0LIST:NAT,03],_AZA0LIST[OZA0LIST:NAT,04],;
						   _AZA0LIST[OZA0LIST:NAT,05],_AZA0LIST[OZA0LIST:NAT,06],_AZA0LIST[OZA0LIST:NAT,07],_AZA0LIST[OZA0LIST:NAT,08],;
						   _AZA0LIST[OZA0LIST:NAT,09],_AZA0LIST[OZA0LIST:NAT,10],_AZA0LIST[OZA0LIST:NAT,11] }},OZA0LIST:REFRESH(),_AITENS:=EXBITENS(_AZA0LIST[OZA0LIST:NAT,02],_AZA0LIST[OZA0LIST:NAT,05]),OZA0ITENS:SETARRAY(_AITENS),;
		  		 OZA0ITENS:BLINE := { || {_AITENS[OZA0ITENS:NAT,01],_AITENS[OZA0ITENS:NAT,02],_AITENS[OZA0ITENS:NAT,03],_AITENS[OZA0ITENS:NAT,04],_AITENS[OZA0ITENS:NAT,05],_AITENS[OZA0ITENS:NAT,06],_AITENS[OZA0ITENS:NAT,07],_AITENS[OZA0ITENS:NAT,08]}},OZA0ITENS:REFRESH(),;
		  		 IIF(EMPTY(_AZA0LIST[OZA0LIST:NAT,02]),(OZA0APROV:DISABLE(),OZA0REPROV:DISABLE(),OZA0VISU:DISABLE()),(OZA0APROV:ENABLE(),OZA0REPROV:ENABLE(),OZA0VISU:ENABLE())))

@  34.0,580 BUTTON OZA0REPROV PROMPT "REPROVAR" 	    SIZE 45*_NMULT,12*_NMULT OF OZA0DLG PIXEL ACTION (PROCESSA({|| REPROV(_AZA0LIST[OZA0LIST:NAT,02]) },"REPROVANDO PROJETO " + ALLTRIM(_AZA0LIST[OZA0LIST:NAT,02]) + "..."),_AZA0LIST:=MONTALBX(),OZA0LIST:SETARRAY(_AZA0LIST),OZA0LIST:REFRESH(),;
OZA0LIST:BLINE := { || {_AZA0LIST[OZA0LIST:NAT,01],_AZA0LIST[OZA0LIST:NAT,02],_AZA0LIST[OZA0LIST:NAT,03],_AZA0LIST[OZA0LIST:NAT,04],;
						   _AZA0LIST[OZA0LIST:NAT,05],_AZA0LIST[OZA0LIST:NAT,06],_AZA0LIST[OZA0LIST:NAT,07],_AZA0LIST[OZA0LIST:NAT,08],;
						   _AZA0LIST[OZA0LIST:NAT,09],_AZA0LIST[OZA0LIST:NAT,10],_AZA0LIST[OZA0LIST:NAT,11] }},OZA0LIST:REFRESH(),_AITENS:=EXBITENS(_AZA0LIST[OZA0LIST:NAT,02],_AZA0LIST[OZA0LIST:NAT,05]),OZA0ITENS:SETARRAY(_AITENS),;
		  		 OZA0ITENS:BLINE := { || {_AITENS[OZA0ITENS:NAT,01],_AITENS[OZA0ITENS:NAT,02],_AITENS[OZA0ITENS:NAT,03],_AITENS[OZA0ITENS:NAT,04],_AITENS[OZA0ITENS:NAT,05],_AITENS[OZA0ITENS:NAT,06],_AITENS[OZA0ITENS:NAT,07],_AITENS[OZA0ITENS:NAT,08]}},OZA0ITENS:REFRESH(),;
		  		 IIF(EMPTY(_AZA0LIST[OZA0LIST:NAT,02]),(OZA0APROV:DISABLE(),OZA0REPROV:DISABLE(),OZA0VISU:DISABLE()),(OZA0APROV:ENABLE(),OZA0REPROV:ENABLE(),OZA0VISU:ENABLE())))

@  48.5,580 BUTTON OZA0VISU   PROMPT "VISUALIZAR"   SIZE 45*_NMULT,12*_NMULT OF OZA0DLG PIXEL ACTION  ZA0VISU(_AZA0LIST[OZA0LIST:NAT,02])
@  63.0,580 BUTTON OZA0LEG	  PROMPT "LEGENDA"  	SIZE 45*_NMULT,12*_NMULT OF OZA0DLG PIXEL ACTION (LEGENDA())

@  75*_NMULT,580*_NMULT  SAY OFILSAY VAR "VISUALIZAวรO" SIZE 270*_NMULT,12*_NMULT OF OZA0DLG PIXEL 
@  6.3*_NMULT,72.5*_NMULT COMBOBOX OCFIL  VAR _CCFIL  ITEMS _ACFIL OF OZA0DLG ON CHANGE (_AZA0LIST:=MONTALBX(),OZA0LIST:SETARRAY(_AZA0LIST),OZA0LIST:REFRESH(),;
OZA0LIST:BLINE := { || { _AZA0LIST[OZA0LIST:NAT][01] , ;
                         _AZA0LIST[OZA0LIST:NAT][02] , ; 
                         _AZA0LIST[OZA0LIST:NAT][03] , ;
                         _AZA0LIST[OZA0LIST:NAT][04] , ;
						 _AZA0LIST[OZA0LIST:NAT][05] , ; 
						 _AZA0LIST[OZA0LIST:NAT][06] , ; 
						 _AZA0LIST[OZA0LIST:NAT][07] , ; 
						 _AZA0LIST[OZA0LIST:NAT][08] , ;
						 _AZA0LIST[OZA0LIST:NAT][09] , ; 
						 _AZA0LIST[OZA0LIST:NAT][10] , ; 
						 _AZA0LIST[OZA0LIST:NAT][11] }} , ; 
				  OZA0LIST:REFRESH() , ;
				  _AITENS := EXBITENS(_AZA0LIST[OZA0LIST:NAT,02] , _AZA0LIST[OZA0LIST:NAT,05]) , ; 
				  OZA0ITENS:SETARRAY(_AITENS) , ;
		  		 OZA0ITENS:BLINE := { || {_AITENS[OZA0ITENS:NAT][01]   , ;
		  		 					      _AITENS[OZA0ITENS:NAT][02]   , ; 
		  		 					      _AITENS[OZA0ITENS:NAT][03]   , ; 
		  		 					      _AITENS[OZA0ITENS:NAT][04]   , ; 
		  		 					      _AITENS[OZA0ITENS:NAT][05]   , ; 
		  		 					      _AITENS[OZA0ITENS:NAT][06]   , ; 
		  		 					      _AITENS[OZA0ITENS:NAT][07]   , ; 
		  		 					      _AITENS[OZA0ITENS:NAT][08]}} , ; 
		  		 OZA0ITENS:REFRESH() , ; 
		  		 IIF(/*_CNIVEL=="1" .AND.*/_AZA0LIST[OZA0LIST:NAT][13]=="4" , (OZA0APROV:DISABLE(),OZA0REPROV:DISABLE()) , (OZA0APROV:ENABLE(),OZA0REPROV:ENABLE())),;
		  		 IIF(EMPTY(_AZA0LIST[OZA0LIST:NAT][02]),(OZA0APROV:DISABLE(),OZA0REPROV:DISABLE(),OZA0VISU:DISABLE()),(OZA0APROV:ENABLE(),OZA0REPROV:ENABLE(),OZA0VISU:ENABLE())))

@ 203.0,6 SAY OZA0SAY VAR _CSAY SIZE 270,12 OF OZA0DLG PIXEL
                         
@ 15,.7 LISTBOX OZA0ITENS VAR _CITENS FIELDS ;
HEADER  "TIPO","PRODUTO","มREA","VALOR มREA","VALOR MENSAL","MESES LOCAวรO","DATA INICIAL","DATA FINAL" SIZE 568*_NMULT,60*_NMULT
OZA0ITENS:SETARRAY(_AITENS)
OZA0ITENS:BLINE := { || {_AITENS[OZA0ITENS:NAT,1],_AITENS[OZA0ITENS:NAT,2],_AITENS[OZA0ITENS:NAT,3],_AITENS[OZA0ITENS:NAT,4],_AITENS[OZA0ITENS:NAT,5]}}                                                                  

ACTIVATE MSDIALOG OZA0DLG CENTERED

RESTAREA( _AAREAOLD )

RETURN



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ EXBITENS  บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 24/01/2014 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑณDESCRI…O ณ RETORNA CONTATOS DE COBRANวA.                         	  ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION EXBITENS(_CPROJET,_CTIPO)

LOCAL _AAREAOLD := GETAREA()
LOCAL _CQUERY   := ""

DEFAULT _CTIPO  := "LOCAวรO" 

_AITENS := {}
_CTIPO  := ALLTRIM(UPPER(_CTIPO))

IF EMPTY(ALLTRIM(_CPROJET))
	AADD(_AITENS,{"","","","","",0,STOD(""),STOD("")})
	RESTAREA( _AAREAOLD )
	RETURN _AITENS
ENDIF            

DO CASE
CASE UPPER(_CTIPO) == 'EQUIPAMENTO'
	_CQUERY := " SELECT CASE WHEN FP4_TIPOSE IN ('G','E')"
	_CQUERY += "             THEN 'EQUIPAMENTO'"
	_CQUERY += "             WHEN FP4_TIPOSE = 'U'"
	_CQUERY += "             THEN 'GRUA'"
	_CQUERY += "             WHEN FP4_TIPOSE = 'R'"
	_CQUERY += "             THEN 'REMOวรO'"
	_CQUERY += "             WHEN FP4_TIPOSE = 'T'"
	_CQUERY += "             THEN 'TREINAMENTO'"
	_CQUERY += "             WHEN FP4_TIPOSE = 'M'"
	_CQUERY += "             THEN 'MรO DE OBRA'"
	_CQUERY += "             WHEN FP4_TIPOSE = 'O'"
	_CQUERY += "             THEN 'OUTROS' ELSE FP4_TIPOSE END TIPOSE,"
	_CQUERY += "        RTRIM(LTRIM(B1_DESC)) PRODUTO, FP4_QUANT AREA, FP4_VRHOR VALUN, FP4_QUANT*FP4_VRHOR VALMEN, DATEDIFF(MONTH,FP4_DTINI,FP4_DTFIM) XMESES, FP4_DTINI DTINI, FP4_DTFIM DTFIM"
	_CQUERY += "   FROM " + RETSQLNAME("FP4") + " INNER JOIN " + RETSQLNAME("SB1")
	_CQUERY += "     ON B1_FILIAL = '" + XFILIAL("SB1") + "'"
	_CQUERY += "    AND FP4_PRODUT = B1_COD"
	_CQUERY += "    AND " + RETSQLNAME("SB1") + ".D_E_L_E_T_ = ''"
	_CQUERY += "  WHERE FP4_FILIAL = '" + XFILIAL("FP4") + "'"
	_CQUERY += "    AND FP4_PROJET = '" + _CPROJET + "'"
	_CQUERY += "    AND " + RETSQLNAME("FP4") + ".D_E_L_E_T_ = ''"
	_CQUERY += "  ORDER BY FP4_SEQGRU"
CASE UPPER(_CTIPO) == 'TRANSPORTE'
	_CQUERY := " SELECT CASE WHEN ZA6_TIPOSE = 'M' 'MOBILIZAวรO'"
	_CQUERY += "             WHEN ZA6_TIPOSE = 'D' 'DESMOBILIZAวรO'"
	_CQUERY += "             WHEN ZA6_TIPOSE = 'E' 'ESTADIA'"
	_CQUERY += "             ELSE 'TRANSPORTE' END TIPOSE,"
	_CQUERY += "        RTRIM(LTRIM(B1_DESC)) PRODUTO, ZA6_DIASV+ZA6_DIASC AREA, ZA6_VRDIA VALUN, (ZA6_DIASV+ZA6_DIASC)*ZA6_VRDIA VALMEN, DATEDIFF(MONTH,ZA6_DTINI,ZA6_DTFIM) XMESES, ZA6_DTINI DTINI, ZA6_DTFIM DTFIM"
	_CQUERY += "   FROM " + RETSQLNAME("ZA6") + " INNER JOIN " + RETSQLNAME("SB1")
	_CQUERY += "     ON B1_FILIAL = '" + XFILIAL("SB1") + "'"
	_CQUERY += "    AND ZA6_PRODUT = B1_COD"
	_CQUERY += "    AND " + RETSQLNAME("SB1") + ".D_E_L_E_T_ = ''"
	_CQUERY += "  WHERE ZA6_FILIAL = '" + XFILIAL("ZA6") + "'"
	_CQUERY += "    AND ZA6_PROJET = '" + _CPROJET + "'"
	_CQUERY += "    AND " + RETSQLNAME("ZA6") + ".D_E_L_E_T_ = ''"
	_CQUERY += "  ORDER BY ZA6_SEQTRA"
OTHERWISE
	_CQUERY := " SELECT CASE WHEN FPA_TIPOSE IN ('L','P')"
	_CQUERY += "             THEN 'LOCAวรO'"
	_CQUERY += "             WHEN FPA_TIPOSE = 'M'"
	_CQUERY += "             THEN 'MรO DE OBRA'"
	_CQUERY += "             WHEN FPA_TIPOSE = 'S'"
	_CQUERY += "             THEN 'SUBSTITUอDO'"
	_CQUERY += "             WHEN FPA_TIPOSE = 'T'"
	_CQUERY += "             THEN 'TRANSFERสNCIA'"
	_CQUERY += "             WHEN FPA_TIPOSE = 'D'"
	_CQUERY += "             THEN 'DEMONSTRAวรO'"
	_CQUERY += "             WHEN FPA_TIPOSE = 'Z'"
	_CQUERY += "             THEN 'TREINAMENTO'"
	_CQUERY += "             WHEN FPA_TIPOSE = 'O'"
	_CQUERY += "             THEN 'OUTROS' ELSE FPA_TIPOSE END TIPOSE,"
	_CQUERY += "        RTRIM(LTRIM(B1_DESC)) PRODUTO, FPA_MINDIA AREA, FPA_VRHOR VALUN, FPA_MINDIA*FPA_VRHOR VALMEN, FPA_MINMES XMESES, FPA_DTINI DTINI, FPA_DTFIM DTFIM"
	_CQUERY += "   FROM " + RETSQLNAME("FPA") + " INNER JOIN " + RETSQLNAME("SB1")
	_CQUERY += "     ON B1_FILIAL = '" + XFILIAL("SB1")+ "'"
	_CQUERY += "    AND FPA_PRODUT = B1_COD"
	_CQUERY += "    AND " + RETSQLNAME("SB1") + ".D_E_L_E_T_ = ''"
	_CQUERY += "  WHERE FPA_FILIAL = '" + XFILIAL("FPA") + "'"
	_CQUERY += "    AND FPA_PROJET = '" + _CPROJET + "'"
	_CQUERY += "    AND " + RETSQLNAME("FPA") + ".D_E_L_E_T_ = ''"
	_CQUERY += "  ORDER BY FPA_SEQGRU"
ENDCASE

IF SELECT("TRB1") > 0
	TRB1->(DBCLOSEAREA())
ENDIF

TCQUERY _CQUERY NEW ALIAS "TRB1"

IF TRB1->(!EOF())
	WHILE TRB1->(!EOF())
		AADD(_AITENS,{TRB1->TIPOSE,ALLTRIM(TRB1->PRODUTO),ALLTRIM(TRANSFORM(TRB1->AREA,"@E 999,999,999,999.99")),;
		ALLTRIM(TRANSFORM(TRB1->VALUN,"@E 999,999,999,999.99")),ALLTRIM(TRANSFORM(TRB1->VALMEN,"@E 999,999,999,999.99")),;
		TRB1->XMESES,STOD(TRB1->DTINI),STOD(TRB1->DTFIM)})
		TRB1->(DBSKIP())
	ENDDO
ELSE
	AADD(_AITENS,{"","","","","",0,STOD(""),STOD("")})
ENDIF

TRB1->(DBCLOSEAREA())

RESTAREA( _AAREAOLD )

RETURN _AITENS



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ APROV     บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 07/01/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑณDESCRI…O ณ APROVAวรO DO PROJETO SELECIONADO.                          ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION APROV(_CPROJET)

LOCAL _AAREAOLD := GETAREA()
LOCAL _AAREAZA0 := FP0->(GETAREA())

IF EMPTY(ALLTRIM(_CPROJET))
	MSGALERT("CONTRATO NรO INFORMADO!" , "GPO - LOCT067B.PRW") 
	RESTAREA( _AAREAZA0 )
	RESTAREA( _AAREAOLD )
	RETURN
ENDIF

DBSELECTAREA("FP0")
FP0->(DBSETORDER(1))
IF FP0->(DBSEEK(XFILIAL("FP0") + _CPROJET))
	INCLUI := .F.
	ALTERA := .F.
	AROTINA := {}
	IF RECLOCK("FP0",.F.)
		FP0->FP0_STATUS := "3"
		FP0->(MSUNLOCK())
		MSGINFO("CONTRATO APROVADA!" , "GPO - LOCT067B.PRW") 
	ENDIF
ELSE
	MSGALERT("CONTRATO NรO ENCONTRADO!" , "GPO - LOCT067B.PRW") 
ENDIF

RESTAREA( _AAREAZA0 )
RESTAREA( _AAREAOLD )

RETURN



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ REPROV    บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 12/01/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑณDESCRI…O ณ REPROVAวรO DO PROJETO SELECIONADO.                         ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION REPROV(_CPROJET)

LOCAL _AAREAOLD := GETAREA()
LOCAL _AAREAZA0 := FP0->(GETAREA())

IF EMPTY(ALLTRIM(_CPROJET))
	MSGALERT("CONTRATO NรO INFORMADO!" , "GPO - LOCT067B.PRW") 
	RESTAREA(_AAREAZA0)
	RESTAREA(_AAREAOLD)
	RETURN
ENDIF

DBSELECTAREA("FP0")
FP0->(DBSETORDER(1))
IF FP0->(DBSEEK(XFILIAL("FP0") + _CPROJET))
	IF RECLOCK("FP0",.F.)
		FP0->FP0_STATUS := "4"
		FP0->(MSUNLOCK())
   		MSGINFO("CONTRATO REPROVADO!" , "GPO - LOCT067B.PRW") 
	ENDIF
ELSE
	MSGALERT("CONTRATO NรO ENCONTRADO!" , "GPO - LOCT067B.PRW")
ENDIF

RESTAREA( _AAREAZA0 )
RESTAREA( _AAREAOLD )

RETURN



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ ZA0VISU   บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 07/01/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑณDESCRI…O ณ VISUALIZAวรO DO PROJETO SELECONADO.                        ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION ZA0VISU(_CPROJET)

LOCAL _AAREAOLD := GETAREA()
LOCAL _AAREAZA0 := FP0->(GETAREA())

PRIVATE ACAMPOZA0 := {}

DBSELECTAREA("FP0")
FP0->(DBSETORDER(1))
LOCA00110(_CPROJET)

RESTAREA( _AAREAZA0 )
RESTAREA( _AAREAOLD )

RETURN



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ LEGENDA   บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 07/01/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑณDESCRICAO ณ CRIAวรO DO BOTรO LEGENDA DOS PROJETOS.                     ณฑฑ
ฑฑณ          ณ AZUL     - NEGOCIAวรO                                      ณฑฑ
ฑฑณ          ณ AMARELO  - PENDENTE DE APROVAวรO                           ณฑฑ
ฑฑณ          ณ VIOLETA  - APROVADO                                        ณฑฑ
ฑฑณ          ณ BRANCO   - REPROVADO                                       ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION LEGENDA()

LOCAL ALEGENDA := { {"BR_CINZA"   ,"PENDENTE DE APROVAวรO"},;
     {"BR_VERDE"	  ,"CONTRATO APROVADO"    },;
                    {"BR_VERMELHO","CONTRATO REPROVADO"   }}

BRWLEGENDA( "STATUS", "LEGENDA", ALEGENDA)

RETURN .T.
