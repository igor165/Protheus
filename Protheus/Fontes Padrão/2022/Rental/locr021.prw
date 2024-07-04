/*/{PROTHEUS.DOC} LOCR021.PRW 
ITUP BUSINESS - TOTVS RENTAL
RELATำRIO DO TIME SHEET
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

FUNCTION LOCR021()
// --> DECLARACAO DE VARIAVEIS.
LOCAL AORD := {}
LOCAL CDESC1       := "ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
LOCAL CDESC2       := "EXIBINDO A LOCAวรO DE FUNCIONมRIOS POR PERอODO, DATA, STATUS, AS COM AS HORAS DE INTEGRAวรO." 
LOCAL CDESC3       := "TIME SHEET"
LOCAL TITULO       := "TIME SHEET"
LOCAL NLIN         := 80
LOCAL CABEC1       := "FL   MATRIC  NOME DO FUNCIONARIO             FUNCAO                STATUS        AS                           CLIENTE                                        MUNICIPIO                     UF   DIAS  VT     HORAS"
                   //  9999 999999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX  99999  99999  99999
                   //  01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                   //           10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220
LOCAL CABEC2       := ""
LOCAL IMPRIME 

PRIVATE LEND       := .F.
PRIVATE LABORTPRINT:= .F.
PRIVATE LIMITE     := 220
PRIVATE TAMANHO    := "G"
PRIVATE NOMEPROG   := "TSHEET" // COLOQUE AQUI O NOME DO PROGRAMA PARA IMPRESSAO NO CABECALHO
PRIVATE NTIPO      := 15
PRIVATE ARETURN    := { "ZEBRADO", 1, "ADMINISTRACAO", 1, 2, 1, "", 1}
PRIVATE NLASTKEY   := 0
PRIVATE CPERG      := "LOCP069"
PRIVATE CBTXT      := SPACE(10)
PRIVATE CBCONT     := 00
PRIVATE CONTFL     := 01
PRIVATE M_PAG      := 01
PRIVATE WNREL      := "TSHEET" // COLOQUE AQUI O NOME DO ARQUIVO USADO PARA IMPRESSAO EM DISCO
PRIVATE CSTRING    := "FPQ"

IMPRIME := .T.

DBSELECTAREA("FPQ")
DBSETORDER(1)

VALIDPERG()
PERGUNTE(CPERG,.F.)

VALIDPAR()

// --> MONTA A INTERFACE PADRAO COM O USUARIO... 
WNREL := SETPRINT(CSTRING,NOMEPROG,CPERG,@TITULO,CDESC1,CDESC2,CDESC3,.F.,AORD,.F.,TAMANHO,,.F.)

IF NLASTKEY == 27
	RETURN
ENDIF

SETDEFAULT(ARETURN,CSTRING)

IF NLASTKEY == 27
   RETURN
ENDIF

NTIPO := IF(ARETURN[4]==1,15,18)

// --> PROCESSAMENTO. RPTSTATUS MONTA JANELA COM A REGUA DE PROCESSAMENTO. 
RPTSTATUS({|| RUNREPORT(CABEC1,CABEC2,TITULO,NLIN) },TITULO)

RETURN



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNO    ณRUNREPORT บ AUTOR ณ AP5 IDE            บ DATA ณ  07/05/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESCRIO ณ FUNCAO AUXILIAR CHAMADA PELA RPTSTATUS. A FUNCAO RPTSTATUS บฑฑ
ฑฑบ          ณ MONTA A JANELA COM A REGUA DE PROCESSAMENTO.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION RUNREPORT(CABEC1,CABEC2,TITULO,NLIN)

SETPRVT("XTQCOM,XTQVEN,XTQEST,XTQPED,XTVCOM,XTVVEN,XTVEST,XTVPED,XIMPLINHA")
SETPRVT("XLQCOM,XLQVEN,XLQEST,XLQPED,XLVCOM,XLVVEN,XLVEST,XLVPED")

// MONTA ARQUIVO DE TRABALHO
// CRIA O ARQUIVO TEMPORARIO PARA SELECIONAR OS BUDGETS
/*
PRIVATE XSTRU := {}
ATAM:=TAMSX3("FPQ_FILIAL")
AADD(XSTRU, {"FPQ_FILIAL" ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("RA_MAT")
AADD(XSTRU, {"RA_MAT"     ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("RA_NOME")
AADD(XSTRU, {"RA_NOME"    ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("RA_CODFUNC")
AADD(XSTRU, {"RA_CODFUNC" ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("RA_DESCFUN")
AADD(XSTRU, {"RA_DESCFUN" ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("FPQ_STATUS")
AADD(XSTRU, {"FPQ_STATUS" ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("FPQ_AS")
AADD(XSTRU, {"FPQ_AS"     ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("FPQ_PROJET")
AADD(XSTRU, {"FPQ_PROJET" ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("FPQ_OBRA")
AADD(XSTRU, {"FPQ_OBRA"   ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("FPQ_DESC")
AADD(XSTRU, {"FPQ_DESC"   ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("RA_SALARIO")
AADD(XSTRU, {"RA_DSHEET"  ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("RA_SALARIO")
AADD(XSTRU, {"RA_VT"      ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("RA_SALARIO")
AADD(XSTRU, {"FPQ_HORAS"  ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("A1_COD")
AADD(XSTRU, {"A1_COD"     ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("A1_LOJA")
AADD(XSTRU, {"A1_LOJA"    ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("A1_MUN")
AADD(XSTRU, {"A1_MUN"     ,ATAM[3],ATAM[1],ATAM[2] } )
ATAM:=TAMSX3("A1_EST")
AADD(XSTRU, {"A1_EST"     ,ATAM[3],ATAM[1],ATAM[2] } )
PRIVATE _CDEPTO
PRIVATE CARQ := CRIATRAB(XSTRU,.T.)
DBUSEAREA(.T.,,CARQ,"TRB",.T.)
PRIVATE CINDA := SUBSTR(CRIATRAB(NIL,.F.),1,7) + "A"
INDREGUA("TRB",CINDA,"RA_MAT+FPQ_STATUS+FPQ_AS",,,"SELECIONANDO REGISTROS...")   //MATRICULA
DBSETORDER(1)
IF MV_PAR17 == 1
	_CDEPTO := GETMV("MV_LOCX110") //"'72033','72032','92000'"
ELSE
    _CDEPTO := GETMV("MV_LOCX106") //"'91000','71041','71031','93000'"
ENDIF
*/

// CARREGA OS DADOS PARA IMPRESSAO
LJMSGRUN("SELECIONANDO REGISTROS PARA IMPRESSรO.",,{||DADZLO()})

//DBSELECTAREA("TRB")	
//IF MV_PAR16 == 2
//	PRIVATE CINDA := SUBSTR(CRIATRAB(NIL,.F.),1,7) + "A"
//	INDREGUA("TRB",CINDA,"RA_NOME+RA_MAT+FPQ_STATUS+FPQ_AS",,,"SELECIONANDO REGISTROS...") //NOME
//ELSEIF MV_PAR16 == 3
//	PRIVATE CINDA := SUBSTR(CRIATRAB(NIL,.F.),1,7) + "A"
//	INDREGUA("TRB",CINDA,"RA_DESCFUN+RA_MAT+FPQ_STATUS+FPQ_AS",,,"SELECIONANDO REGISTROS...") //NOME
//ENDIF
//_NSUBVAL := 0 //TOTALIZADOR DE SUB-TOTAIS POR PERอODO
//_NSUBTON := 0
//_NTOTVAL := 0 //TOTALIZADOR DE VALORES ANTERIORES
//_NTOTTON := 0

TITULO := ALLTRIM(TITULO) +" PERIODO DE " + ALLTRIM(DTOC(MV_PAR01)) + " A " + ALLTRIM(DTOC(MV_PAR02))

// --> SETREGUA -> INDICA QUANTOS REGISTROS SERAO PROCESSADOS PARA A REGUA.
DBSELECTAREA("QRY")
SETREGUA(RECCOUNT())

DBGOTOP()
WHILE !EOF()

//	_NSUBVAL := _NSUBTON := 0

	_CMAT := QRY->FPQ_MAT
	_LIMPLINHA := .T.
	WHILE !EOF()
		IF LABORTPRINT
			@ NLIN,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			EXIT
		ENDIF

		INCREGUA()

		IF NLIN > 55 // SALTO DE PมGINA. NESTE CASO O FORMULARIO TEM 55 LINHAS...
      		CABEC(TITULO,CABEC1,CABEC2,NOMEPROG,TAMANHO,NTIPO)
      		NLIN := 7
   		    _LIMPLINHA := .T.
   		ENDIF														   
// "FL   MATRIC  NOME DO FUNCIONARIO             FUNCAO                STATUS        AS                           CLIENTE                                        MUNICIPIO                     UF   DIAS  VT     HORAS"
//  99   999999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX  99999  99999  99999
//  01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//           10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220
		IF _LIMPLINHA .OR. _CMAT <> QRY->FPQ_MAT
			NLIN++
			@ NLIN,000 PSAY QRY->FPQ_FILIAL
			@ NLIN,005 PSAY QRY->FPQ_MAT
			@ NLIN,013 PSAY QRY->RA_NOME
			@ NLIN,045 PSAY QRY->RJ_DESC
			_CMAT := QRY->FPQ_MAT
			_LIMPLINHA := .F.
		ENDIF	
   		
   		@ NLIN,067 PSAY FWGETSX5( "75", QRY->FPQ_STATUS )[1][4] //QRY->FPQ_STATUS
   		@ NLIN,081 PSAY QRY->FPQ_AS
   		@ NLIN,110 PSAY QRY->FPQ_DESC
   		@ NLIN,157 PSAY QRY->A1_MUN
   		@ NLIN,187 PSAY QRY->A1_EST
   		@ NLIN,191 PSAY QRY->RA_DSHEET PICTURE "99999"
   		//@ NLIN,198 PSAY QRY->RA_VT     PICTURE "99999" removido da 94
   		@ NLIN,205 PSAY QRY->FPQ_HORAS PICTURE "99999"
   		NLIN++ // AVANCA A LINHA DE IMPRESSAO

   		// ACUMULA OS TOTAIS DA LINHA
	//	_NSUBVAL += 
	//	_NSUBTON += 

		// ACUMULA OS TOTAIS GERAIS
	//	_NTOTVAL += 
	//	_NTOTTON += 

	//	DBSELECTAREA("QRY")
   		QRY->(DBSKIP()) // AVANCA O PONTEIRO DO REGISTRO NO ARQUIVO
	ENDDO	
   
	// IMPRIME OS SUB-TOTAIS DO PERอODO
//	IF _NSUBVAL>0 .OR. _NSUBTON>0
//		@ NLIN,09 PSAY "TOTAL"
//		@ NLIN,17 PSAY TRANSFORM(_NSUBVAL,"@E 9999,999,999,999.99")
//		@ NLIN,38 PSAY TRANSFORM(_NSUBTON,"@E 9999,999,999,999.99")
//		@ NLIN,59 PSAY TRANSFORM(_NSUBVAL/_NSUBTON,"@E 9999,999,999,999.99")
//       NLIN ++
//	ENDIF
    @ NLIN,00 PSAY REPLICATE("_",LIMITE)
    NLIN ++
ENDDO

// IMPRIME OS TOTAIS GERAIS
//IF _NTOTVAL>0 .OR. _NTOTTON>0
//	@ NLIN,09 PSAY "GERAL"
//	@ NLIN,17 PSAY TRANSFORM(_NTOTVAL,"@E 9999,999,999,999.99")
//	@ NLIN,38 PSAY TRANSFORM(_NTOTTON,"@E 9999,999,999,999.99")
//	@ NLIN,59 PSAY TRANSFORM(_NTOTVAL/_NTOTTON,"@E 9999,999,999,999.99")
//   NLIN ++
//ENDIF
//@ NLIN,00 PSAY REPLICATE("_",LIMITE)
//NLIN ++

// --> FINALIZA A EXECUCAO DO RELATORIO... 
SET DEVICE TO SCREEN

// --> SE IMPRESSAO EM DISCO, CHAMA O GERENCIADOR DE IMPRESSAO... 
IF ARETURN[5]==1
	DBCOMMITALL()
	SET PRINTER TO
	OURSPOOL(WNREL)
ENDIF

MS_FLUSH()

// DELETA O ARQUIVO DE TRABALHO
//DBSELECTAREA("TRB")
QRY->(DBCLOSEAREA())
//DELETE FILE (CARQ  + ".DBF")
//DELETE FILE (CINDA + ORDBAGEXT())

RETURN 



// ======================================================================= \\
STATIC FUNCTION DADZLO()
// ======================================================================= \\
// --> UTILIZADA PARA CARREGAR OS VALORES DAS COMPRAS DOS PRODUTOS

LOCAL NX        := 0 
LOCAL _CFILATU	:= SM0->M0_CODFIL
LOCAL _CSITFOLH	:=	""
LOCAL _CCATFUNC	:=	""
LOCAL _CCCDEPTO

DO CASE
CASE ALLTRIM(MV_PAR17) == "T"
	_CCCDEPTO	:=	GETMV("MV_LOCX110",.F.,"")
CASE ALLTRIM(MV_PAR17) == "E"
	_CCCDEPTO	:=	GETMV("MV_LOCX106",.F.,"")	
CASE ALLTRIM(MV_PAR17) == "L"
	_CCCDEPTO	:=	GETMV("MV_LOCX105",.F.,"") 
OTHERWISE
	_CCCDEPTO	:=	"''" 
ENDCASE	

FOR NX := 1 TO LEN(MV_PAR13)
	_CSITFOLH += "'"+SUBSTR(MV_PAR13,NX,1)+"',"
NEXT NX
_CSITFOLH := SUBSTR(_CSITFOLH,1,LEN(_CSITFOLH)-1)

FOR NX := 1 TO LEN(MV_PAR14)
	_CCATFUNC += "'"+SUBSTR(MV_PAR14,NX,1)+"',"
NEXT NX 
_CCATFUNC := SUBSTR(_CCATFUNC,1,LEN(_CCATFUNC)-1)

IF SELECT("QRY") > 0
	QRY->(DBCLOSEAREA()) 
ENDIF
_CQUERY := "SELECT	ZLO.FPQ_FILIAL	,	ZLO.FPQ_MAT	,	SRA.RA_NOME		,	SRJ.RJ_DESC		,		"
_CQUERY += "		ZLO.FPQ_STATUS	, 	ZLO.FPQ_AS	,	ZLO.FPQ_DESC	,	ZLO.FPQ_PROJET	,		"
_CQUERY += "		ZLO.FPQ_OBRA	,	SA1.A1_MUN	, 	SA1.A1_EST		,							"
//_CQUERY += "		SUM(CASE WHEN ZLO.FPQ_VT = 'S' THEN 1 ELSE 0 END) RA_VT, 						" removido da 94
_CQUERY += "		0 RA_VT, 						"
_CQUERY += "       	SUM(ZLO.FPQ_HORAS) FPQ_HORAS	, 	COUNT(*) RA_DSHEET							"
_CQUERY += "FROM   " + RETSQLNAME("FPQ") + " ZLO INNER JOIN 										"
_CQUERY +=             RETSQLNAME("SRA") + " SRA ON 												"
_CQUERY += "       SRA.D_E_L_E_T_ = '' AND 															"
_CQUERY += "       SRA.RA_FILIAL = '" + _CFILATU + "' AND 											"
_CQUERY += "       ZLO.FPQ_MAT = SRA.RA_MAT INNER JOIN 												"
_CQUERY +=             RETSQLNAME("SRJ") + " SRJ ON 												"                                   	
_CQUERY += "       SRJ.D_E_L_E_T_ = '' AND 															"
_CQUERY += "       SRA.RA_CODFUNC = SRJ.RJ_FUNCAO LEFT JOIN 										"
_CQUERY +=             RETSQLNAME("FQ5") + " DTQ ON 												"
_CQUERY += "       DTQ.D_E_L_E_T_ = '' AND 															"
_CQUERY += "       ZLO.FPQ_AS = DTQ.FQ5_AS AND 														"
_CQUERY += "       ZLO.FPQ_PROJET = DTQ.FQ5_CONTRA LEFT JOIN 										"
_CQUERY +=             RETSQLNAME("AAM") + " AAM ON 												"
_CQUERY += "       AAM.D_E_L_E_T_ = '' AND 															"
_CQUERY += "       DTQ.FQ5_CONTRA = AAM.AAM_CONTRT LEFT JOIN 										"
_CQUERY +=             RETSQLNAME("SA1") + " SA1 ON 												"
_CQUERY += "       SA1.D_E_L_E_T_ = '' AND 															"
_CQUERY += "       AAM.AAM_CODCLI = SA1.A1_COD AND 													"
_CQUERY += "       AAM.AAM_LOJA   = SA1.A1_LOJA 													"
_CQUERY += "WHERE  ZLO.D_E_L_E_T_ = ''                             	 AND 							"
_CQUERY += "       ZLO.FPQ_MAT     BETWEEN '" + MV_PAR03        + "' AND '" + MV_PAR04 + "' AND 	"
_CQUERY += "       ZLO.FPQ_STATUS  BETWEEN '" + MV_PAR05        + "' AND '" + MV_PAR06 + "' AND 	"
_CQUERY += "       ZLO.FPQ_AS      BETWEEN '" + MV_PAR07        + "' AND '" + MV_PAR10 + "' AND 	"
_CQUERY += "       ZLO.FPQ_PROJET  BETWEEN '" + MV_PAR08        + "' AND '" + MV_PAR11 + "' AND 	"
_CQUERY += "       ZLO.FPQ_OBRA    BETWEEN '" + MV_PAR09        + "' AND '" + MV_PAR12 + "' AND 	"
_CQUERY += "       ZLO.FPQ_DATA    BETWEEN '" + DTOS(MV_PAR01)  + "' AND '" + DTOS(MV_PAR02) + "' 	"
//_CQUERY += "       AND	SRA.RA_CC       IN ("+ALLTRIM(_CCCDEPTO)+")									"
_CQUERY += "       AND	SRA.RA_SITFOLH  IN ("+ALLTRIM(_CSITFOLH)+")									"
_CQUERY += "       AND	SRA.RA_CATFUNC  IN ("+ALLTRIM(_CCATFUNC)+") 								"
_CQUERY += "GROUP BY ZLO.FPQ_FILIAL,ZLO.FPQ_MAT,SRA.RA_NOME,SRJ.RJ_DESC,ZLO.FPQ_STATUS, 			"
_CQUERY += "ZLO.FPQ_AS,ZLO.FPQ_DESC,ZLO.FPQ_PROJET, ZLO.FPQ_OBRA, SA1.A1_MUN, SA1.A1_EST 			"
IF MV_PAR16 == 2
	_CQUERY += "       ORDER BY RA_NOME+FPQ_MAT+FPQ_STATUS+FPQ_AS"
ELSE
	_CQUERY += "       ORDER BY RJ_DESC+FPQ_MAT+FPQ_STATUS+FPQ_AS "
ENDIF
_CQUERY := CHANGEQUERY(_CQUERY)  
TCQUERY _CQUERY NEW ALIAS "QRY"

/*
DBSELECTAREA("QRY")
DBGOTOP()
WHILE QRY->(!EOF())
	IF QRY->RA_SITFOLH $ MV_PAR13 .AND. QRY->RA_CATFUNC $ MV_PAR14
		DBSELECTAREA("TRB")
		IF DBSEEK(QRY->RA_MAT + QRY->FPQ_STATUS + QRY->FPQ_AS)
			RECLOCK('TRB',.F.)
		ELSE
			RECLOCK('TRB',.T.)
			TRB->FPQ_FILIAL	:= QRY->FPQ_FILIAL
			TRB->RA_MAT		:= QRY->RA_MAT
			TRB->RA_NOME	:= QRY->RA_NOME
			TRB->RA_CODFUNC	:= QRY->RA_CODFUNC
			TRB->RA_DESCFUN	:= QRY->RJ_DESC
			TRB->FPQ_STATUS	:= QRY->FPQ_STATUS
			TRB->FPQ_AS		:= QRY->FPQ_AS
			TRB->FPQ_PROJET	:= QRY->FPQ_PROJET
			TRB->FPQ_OBRA	:= QRY->FPQ_OBRA
			TRB->FPQ_DESC	:= QRY->FPQ_DESC
			TRB->A1_COD		:= QRY->A1_COD
			TRB->A1_LOJA	:= QRY->A1_LOJA
			TRB->A1_MUN		:= QRY->A1_MUN
			TRB->A1_EST		:= QRY->A1_EST
		ENDIF
		TRB->RA_DSHEET	:= TRB->RA_DSHEET	+ 1
		TRB->RA_VT		:= TRB->RA_VT		+ IIF(QRY->FPQ_VT == "S",1,0)
		TRB->FPQ_HORAS	:= TRB->FPQ_HORAS	+ QRY->FPQ_HORAS
		MSUNLOCK('TRB')
	ENDIF
    DBSELECTAREA("QRY")
    DBSKIP()
ENDDO
QRY->(DBCLOSEAREA("QRY"))
*/

RETURN 



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNO    ณVALIDPERG บ AUTOR ณ AP5 IDE            บ DATA ณ  07/05/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESCRIO ณ VERIFICA A EXISTENCIA DAS PERGUNTAS CRIANDO-AS CASO SEJA   บฑฑ
ฑฑบ          ณ NECESSARIO (CASO NAO EXISTAM).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ PROGRAMA PRINCIPAL                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION VALIDPERG() 

LOCAL _SALIAS := ALIAS() 
LOCAL AREGS   := {} 
LOCAL I,J

DBSELECTAREA("SX1")
DBSETORDER(1)
CPERG := PADR(CPERG,10)

//          GRUPO/ORDEM/PERGUNTA                                                            /VARIAVEL /TIPO/TAMANHO/DECIMAL/PRESEL/GSC/VALID                                          /VAR01     /DEF01/DEF01/DEF01/CNT01/       VAR02/DEF02/DEF02/DEF02/CNT02/VAR03/DEF03/DEF03/DEF03/CNT03/VAR04/DEF04/DEF04/DEF04/CNT04/VAR05/DEF05/DEF05/DEF05/CNT05/F3    /PYME/SXG/HELP/PICTURE/IDFIL
AADD(AREGS,{CPERG,"01" ,"PERอODO DE ?"        ,"PERอODO DE ?"        ,"PERอODO DE ?"        ,"MV_CH1" ,"D" ,08     ,0      ,0     ,"G",""                                             ,"MV_PAR01",""   ,""   ,""   ,""          ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,""  ,"" ,""  ,""     ,""})
AADD(AREGS,{CPERG,"02" ,"PERอODO ATษ ?"       ,"PERอODO ATษ ?"       ,"PERอODO ATษ ?"       ,"MV_CH2" ,"D" ,08     ,0      ,0     ,"G",""                                             ,"MV_PAR02",""   ,""   ,""   ,""          ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,""  ,"" ,""  ,""     ,""})
AADD(AREGS,{CPERG,"03" ,"MATRICULA DE ?"      ,"MATRICULA DE ?"      ,"MATRICULA DE ?"      ,"MV_CH3" ,"C" ,06     ,0      ,0     ,"G",""                                             ,"MV_PAR03",""   ,""   ,""   ,""          ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"SRA" ,"S" ,"" ,""  ,""     ,""})
AADD(AREGS,{CPERG,"04" ,"MATRICULA ATษ ?"     ,"MATRICULA ATษ ?"     ,"MATRICULA ATษ ?"     ,"MV_CH4" ,"C" ,06     ,0      ,0     ,"G",""                                             ,"MV_PAR04",""   ,""   ,""   ,""          ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"SRA" ,"S" ,"" ,""  ,""     ,""})
AADD(AREGS,{CPERG,"05" ,"STATUS DE ?"         ,"STATUS DE ?"         ,"STATUS DE ?"         ,"MV_CH5" ,"C" ,06     ,0      ,0     ,"G","EXISTCPO('SX5','75'+MV_PAR05)"                ,"MV_PAR05",""   ,""   ,""   ,""          ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"75"  ,"S" ,"" ,""  ,""     ,""})
AADD(AREGS,{CPERG,"06" ,"STATUS ATษ ?"        ,"STATUS ATษ ?"        ,"STATUS ATษ ?"        ,"MV_CH6" ,"C" ,06     ,0      ,0     ,"G","VAZIO() .OR. EXISTCPO('SX5','75'+MV_PAR06)"   ,"MV_PAR06",""   ,""   ,""   ,""          ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"75"  ,"S" ,"" ,""  ,""     ,""})
AADD(AREGS,{CPERG,"07" ,"NR. DA A.S. DE ?"    ,"NR. DA A.S. DE ?"    ,"NR. DA A.S. DE ?"    ,"MV_CH7" ,"C" ,27     ,0      ,0     ,"G",""                                             ,"MV_PAR07",""   ,""   ,""   ,""          ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"DTQAS","S" ,"" ,""  ,""     ,""})
AADD(AREGS,{CPERG,"08" ,"NR. DO PROJETO DE ?" ,"NR. DO PROJETO DE ?" ,"NR. DO PROJETO DE ?" ,"MV_CH8" ,"C" ,22     ,0      ,0     ,"G",""                                             ,"MV_PAR08",""   ,""   ,""   ,""          ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"FP0" ,"S"  ,"" ,"" ,""     ,""})
AADD(AREGS,{CPERG,"09" ,"NR. DA OBRA DE ?"    ,"NR. DA OBRA DE ?"    ,"NR. DA OBRA DE ?"    ,"MV_CH9" ,"C" ,03     ,0      ,0     ,"G",""                                             ,"MV_PAR09",""   ,""   ,""   ,""          ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,""   ,"" ,"" ,""     ,""})
AADD(AREGS,{CPERG,"10" ,"NR. DA A.S. ATษ ?"   ,"NR. DA A.S. ATษ ?"   ,"NR. DA A.S. ATษ ?"   ,"MV_CHA" ,"C" ,27     ,0      ,0     ,"G",""                                             ,"MV_PAR10",""   ,""   ,""   ,""          ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"DTQAS","S" ,"" ,""  ,""     ,""})
AADD(AREGS,{CPERG,"11" ,"NR. DO PROJETO ATษ ?","NR. DO PROJETO ATษ ?","NR. DO PROJETO ATษ ?","MV_CHB" ,"C" ,22     ,0      ,0     ,"G",""                                             ,"MV_PAR11",""   ,""   ,""   ,""          ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"FP0", "S"  ,"" ,"" ,""     ,""})
AADD(AREGS,{CPERG,"12" ,"NR. DA OBRA DE ?"    ,"NR. DA OBRA DE ?"    ,"NR. DA OBRA DE ?"    ,"MV_CHC" ,"C" ,03     ,0      ,0     ,"G",""                                             ,"MV_PAR12",""   ,""   ,""   ,""          ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,""   ,"" ,"" ,""     ,""})
AADD(AREGS,{CPERG,"13" ,"SITUACOES ?"         ,"SITUACIONES ?"       ,"STATUS ?"            ,"MV_CHD" ,"C" ,05     ,0      ,0     ,"G","FSITUACAO"                                    ,"MV_PAR13",""   ,""   ,""   ," ****"     ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,""   ,"" ,"" ,""     ,""})
AADD(AREGS,{CPERG,"14" ,"CATEGORIAS ?"        ,"CATEGORIAS ?"        ,"CATEGORIES ?"        ,"MV_CHE" ,"C" ,10     ,0      ,0     ,"G","FCATEGORIA"                                   ,"MV_PAR14",""   ,""   ,""   ,"*****HM***",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,""   ,"" ,"" ,""     ,""})
AADD(AREGS,{CPERG,"15" ,"FILTRA SUA FILIAL ?" ,"FILTRA SUA FILIAL ?" ,"FILTRA SUA FILIAL ?" ,"MV_CHF" ,"N" ,01     ,0      ,2     ,"C",""                                             ,"MV_PAR15","SIM","SIM","SIM",""          ,""   ,"NรO","NรO","NรO",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,"S"  ,"" ,"" ,""     ,""})
AADD(AREGS,{CPERG,"16" ,"ORDENAR POR:"        ,"ORDENAR POR:"        ,"ORDENAR POR:"        ,"MV_CHG" ,"N" ,01     ,0      ,2     ,"C",""                                             ,"MV_PAR16","CำD.","CำD.","CำD.",""       ,""   ,"NOME","NOME","NOME","",""   ,"FUNCAO"   ,"FUNCAO"   ,"FUNCAO"   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,"S"  ,"" ,"" ,""     ,""})
//AADD(AREGS,{CPERG,"17" ,"DEPARTAMENTO  ?"     ,"DEPARTAMENTO  ?"     ,"DEPARTAMENTO  ?"     ,"MV_CHH" ,"C" ,01     ,0      ,2     ,"G","EXISTCPO('SX5','78'+MV_PAR17)"                ,"MV_PAR17",""   ,""   ,""   ,""          ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"78"    ,"S"  ,"" ,"" ,""   ,""})      
      
FOR I:=1 TO LEN(AREGS)
	IF !DBSEEK(CPERG+AREGS[I,2])
		RECLOCK("SX1",.T.)
//	ELSE
//		RECLOCK("SX1",.F.)
		FOR J:=1 TO FCOUNT()
			IF J <= LEN(AREGS[I])
				FIELDPUT(J,AREGS[I,J])
			ENDIF
		NEXT J
		MSUNLOCK()
	ENDIF
NEXT I

DBSELECTAREA(_SALIAS)

RETURN



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ VALIDPAR  บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 12/05/2009 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ CRIA OS PARAMETROS UTILIZADOS PELO RELATำRIO               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION VALIDPAR()

LOCAL _SALIAS   := ALIAS()
LOCAL AREGS     := {}
LOCAL I,J
LOCAL CCNTTRA   := "'720000','720418'"	//"'72103','72016'"   	CC ANTIGO
LOCAL CCNTGUI   := "'910000'"			//"'91000'"				CC ANTIGO
LOCAL CCNTGRU   := "'930000'"			//"'93000'"             CC ANTIGO
//LOCAL CCNTMAN := "'950000'"			//"'96000'"				CC ANTIGO
//LOCAL CCNTPLA := "'950000'"			//"'96000'"				CC ANTIGO
//LOCAL CCNTMAR := "'0'"

DBSELECTAREA("SX6")
DBSETORDER(1)

//         FILIAL   /NOME          /TIPO /DESCRIวรO                                                /DSCSPA		/DSCENG  		/DESCRI1    														/DSCSPA1  		/DSCENG1   		/DESCRI2  		/DSCSPA2  		/DSCENG2  		/CONTEUD  		/CONTSPA  		/CONTENG  		/PROPRI  /PYME
AADD(AREGS,{"  "      ,"MV_LOCX110"   ,"C"  ,PADC("CENTRO DE CUSTOS PARA FILTROS EM RELATำRIOS",50)  ,""			,""				,PADC(" EX.: 'CC1','CC2','CC3'."                   ,50)				,""				,""				,""				,""				,""				,CCNTTRA  		,CCNTTRA  		,CCNTTRA 		,"R"    ,""})
AADD(AREGS,{"  "      ,"MV_LOCX106"   ,"C"  ,PADC("CENTRO DE CUSTOS PARA FILTROS EM RELATำRIOS",50)  ,""  			,""			,PADC(" EX.: 'CC1','CC2','CC3'."                   ,50)			    ,""				,""				,""				,""				,""				,CCNTGUI  		,CCNTGUI  		,CCNTGUI  		,"R"    ,""})
AADD(AREGS,{"  "      ,"MV_LOCX105"   ,"C"  ,PADC("CENTRO DE CUSTOS PARA FILTROS EM RELATำRIOS",50)  ,""  			,""			,PADC(" EX.: 'CC1','CC2','CC3'."                   ,50)			    ,""				,""				,""				,""				,""				,CCNTGRU  		,CCNTGRU  		,CCNTGRU  		,"R"    ,""})
//AADD(AREGS,{"  "      ,"MV_LOCX109"   ,"C"  ,PADC("CENTRO DE CUSTOS PARA FILTROS EM RELATำRIOS",50)  ,""  			,""			,PADC(" EX.: 'CC1','CC2','CC3'."                   ,50)			    ,""				,""				,""				,""				,""				,CCNTPLA  		,CCNTPLA  		,CCNTPLA  		,"U"    ,""})
//AADD(AREGS,{"  "      ,"MV_LOCX107"   ,"C"  ,PADC("CENTRO DE CUSTOS PARA FILTROS EM RELATำRIOS",50)  ,""  			,""			,PADC(" EX.: 'CC1','CC2','CC3'."                   ,50)			    ,""				,""				,""				,""				,""				,CCNTMAN  		,CCNTMAN  		,CCNTMAN  		,"U"    ,""})
//AADD(AREGS,{"  "      ,"MV_LOCX108"   ,"C"  ,PADC("CENTRO DE CUSTOS PARA FILTROS EM RELATำRIOS",50)  ,""  			,""			,PADC(" EX.: 'CC1','CC2','CC3'."                   ,50)			    ,""				,""				,""				,""				,""				,CCNTMAR  		,CCNTMAR  		,CCNTMAR  		,"U"    ,""})
	
FOR I:=1 TO LEN(AREGS)
    IF !(DBSEEK(AREGS[I,1]+AREGS[I,2]))
        RECLOCK("SX6",.T.)
	    FOR J:=1 TO FCOUNT()
    	    IF J <= LEN(AREGS[I])
        	    FIELDPUT(J,AREGS[I,J])
	        ENDIF
    	NEXT J 
	   MSUNLOCK()
	ENDIF
NEXT I 

DBSELECTAREA(_SALIAS)

RETURN
