/*/{PROTHEUS.DOC} LOCR002.PRW 
ITUP BUSINESS - TOTVS RENTAL
RELAT�RIO DE TITULOS PENDENTE PARA O CLIENTE DA PROPOSTA
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "TOTVS.CH"

FUNCTION LOCR002()
RETURN LOCR002()

FUNCTION LCRCM007()

LOCAL OREPORT
LOCAL OSECTION
LOCAL _CDESREP	:=	"ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
      _CDESREP	+=	"EXIBINDO A AN�LISE DAS MEDI��ES N�O FATURADAS DE FORMA SINT�TICA, PARA APRECIA��O DA CONTROLADORIA."
      _CDESREP	+=	"MEDI��ES N�O FATURADAS SINT�TICO"
      
//			   TREPORT():NEW(CREPORT		,CTITLE	                       ,UPARAM ,BACTION						     ,CDESCRIPTION,LLANDSCAPE,UTOTALTEXT,LTOTALINLINE,CPAGETTEXT,LPAGETINLINE,LTPAGEBREAK,NCOLSPACE)
OREPORT 	:= TREPORT():NEW("LOCR002"	    ,"RELA��O DE TITULOS PENDENTES",	   ,{|OREPORT| PRINTREPORT(@OREPORT)} , _CDESREP   ,.F.)


//			   TRSECTION():NEW(OPARENT, CTITLE              ,  UTABLE         ,AORDER,LLOADCELLS,LLOADORDER,UTOTALTEXT,LTOTALINLINE,LHEADERPAGE,LHEADERBREAK,LPAGEBREAK,LLINEBREAK,NLEFTMARGIN,LLINESTYLE,NCOLSPACE,LAUTOSIZE,CCHARSEPARATOR,NLINESBEFORE,NCOLS,NCLRBACK,NCLRFORE,NPERCENTAGE)*/	
OSECTION 	:= TRSECTION():NEW(OREPORT, "CONTAS A RECEBER"  ,  {"SE1"})

/*/DEFINE AS CELULAS DE IMPRES�O
TRCELL():NEW(OPARENT ,  CNAME     , 	CALIAS,  CTITLE                  , CPICTURE                  ,NSIZE   , LPIXEL	, BBLOCK, CALIGN, LLINEBREAK, CHEADERALIGN, LCELLBREAK, NCOLSPACE, LAUTOSIZE, NCLRBACK, NCLRFORE, LBOLD)*/
TRCELL():NEW(OSECTION,	"E1_FILIAL"  , 	"SE1", 	"FILIAL"				,							,  	     ,			,{|| FWFILIALNAME(CEMPANT,VALCLI->E1_FILIAL) } )
TRCELL():NEW(OSECTION,	"E1_PREFIXO" , 	"SE1", 	"PREFIXO"				,    						,  )
TRCELL():NEW(OSECTION,	"E1_NUM"	 , 	"SE1", 	"N�MERO"			    ,							,  )
TRCELL():NEW(OSECTION,	"E1_PARCELA" , 	"SE1", 	"PARCELA"				,							,  )
TRCELL():NEW(OSECTION,	"E1_TIPO"    , 	"SE1", 	"TIPO"					,							,  )
TRCELL():NEW(OSECTION,	"E1_NATUREZ" , 	"SE1", 	"NATUREZA"				,							,  )
TRCELL():NEW(OSECTION,	"E1_NOMCLI"  , 	"SE1", 	"NOME DO CLIENTE"		,							,  )
TRCELL():NEW(OSECTION,	"E1_VENCREA" , 	"SE1", 	"VENCIMENTO"			,"@D"						,  )
TRCELL():NEW(OSECTION,	"E1_VALOR"   , 	"SE1", 	"$ VALOR"				, "@E 999,999,999,999.99"	,  )
	
/*/DEFINE A FUN��O DE TOTALIZA��O DO RELATR�RIO
TRFUNCTION():NEW(OCELL					    ,CNAME	,CFUNCTION	,OBREAK	,CTITLE                	,CPICTURE               ,UFORMULA	,LENDSECTION,LENDREPORT,LENDPAGE,OPARENT,BCONDITION,LDISABLE,BCANPRINT)*/
TRFUNCTION():NEW(OSECTION:CELL("E1_VALOR")	,NIL	,"SUM"		,		,"TOTAL ===>"			,"@E 999,999,999,999.99",			,  .F.		,.T.)

RETURN OREPORT



// ======================================================================= \\
STATIC FUNCTION PRINTREPORT(OREPORT)
// ======================================================================= \\
// --> DADOS DO RELATORIO DE TITULOS PENDENTES PARA O CLIENTE DA PROPOSTA
LOCAL OSECTION := OREPORT:SECTION(1)

OSECTION:BEGINQUERY()

BEGINSQL ALIAS "VALCLI"
	COLUMN E1_VENCREA AS DATE
	
	%NOPARSER%					
		
	SELECT 
		E1_FILIAL,
		E1_PREFIXO,
		E1_NUM,
		E1_PARCELA,	
		E1_TIPO,
		E1_NATUREZ,
		E1_NOMCLI,
		E1_VENCREA,
		E1_VALOR,
		R_E_C_N_O_		
	FROM 
		%TABLE:SE1%
	WHERE
		%NOTDEL%						AND
		E1_CLIENTE = %EXP:_CCLIVALID%	AND
		E1_LOJA	   = %EXP:_CLOJVALID%	AND
		E1_TIPO NOT LIKE '%-%'			AND
		E1_VENCREA	< %EXP:_DDATAREF%	AND
		E1_BAIXA	= ' '
ENDSQL   

OSECTION:ENDQUERY() 

OSECTION:PRINT()

RETURN NIL
