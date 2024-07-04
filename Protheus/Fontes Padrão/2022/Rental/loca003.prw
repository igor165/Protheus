/*/{PROTHEUS.DOC} LOCA003.PRW
ITUP BUSINESS - TOTVS RENTAL
ESTA CLASSE SERVE PARA CONTROLAR DADOS DE UM ACOLS, UTIL QUANDO SE TRABALHA COM O CONCEITO BE CHANGE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.

// Frank Fuga em 07/04/2022
Para nao travar o rental existe a tratativa de nao exibir os error.logs
se houver a necessidade de mostrar o error.log basta criar o ponto de entrada _LOCA03PE
o conte�do do PE deve ser ERRORBLOCK(oError)

/*/

#INCLUDE "PROTHEUS.CH"

CLASS BECHANGE
	DATA AHEADER
	DATA ACOLS
	DATA LEDIT
	DATA AGET
	DATA CERRO
	DATA BORD

	METHOD CREATE(AHEADER, ACOLS, CORDER) CONSTRUCTOR
	METHOD SETHEADER(AHEADER)
	METHOD SETACOLS(ACOLS)
	METHOD GETDATA(CCOND)
	METHOD SETDATA(ACOLS, CCOND)
	METHOD SETORDER(CORD)
	METHOD GETERRO()
	METHOD FREE()
	METHOD REMOVEITEM(CCOND) 
ENDCLASS



/*BEGINDOC
//������������������?
//?ETHOD CREATE    ?
//?STANCIA A CLASSE?
//������������������?
ENDDOC*/
METHOD CREATE(AHEADER, ACOLS, CORDER) CLASS BECHANGE

::SETHEADER(AHEADER)
::SETACOLS(ACOLS)

::LEDIT   := .F.
::AGET    := {}
::CERRO   := ""

::SETORDER(CORDER)

RETURN SELF 


/*BEGINDOC
//��������������������������������������������������������������������������������������������Ŀ
//?ETHOD SETHEADER                                                                            ?
//?TRIBUI O AHEADER A CLASSE.                                                                 ?
//?RRAY COM PELO MENOS 2 DIMENS?S, A SEGUNDA DEVE TER O NOME DA COLUNA PARA EFEITO DE FILTROS?
//����������������������������������������������������������������������������������������������
ENDDOC*/
METHOD SETHEADER(AHEADER) CLASS BECHANGE
	IF ! EMPTY(AHEADER)
		::AHEADER := ACLONE(AHEADER)
	ENDIF
RETURN NIL



/*BEGINDOC
//������������������������������������?
//?METHOD SETACOLS                   ?
//?ATRIBUI O ACOLS COMPLETO A CLASSE ?
//������������������������������������?
ENDDOC*/
METHOD SETACOLS(ACOLS) CLASS BECHANGE

IF !EMPTY(ACOLS)
	::ACOLS := ACLONE(ACOLS)
ENDIF

RETURN NIL


/*BEGINDOC
//������������������������������������������������������������������������������������������������������������������Ŀ
//?ETHOD GETDATA                                                                                                    ?
//?ECUPERA ACOLS DA CLASSE, ACEITA FILTRO CONDICIONAL, ARMAZENA POSICIONAMENTO DAS LINHAS PARA POSTERIOR ATUALIZA��O?
//��������������������������������������������������������������������������������������������������������������������
ENDDOC*/
METHOD GETDATA(CCOND) CLASS BECHANGE

LOCAL OERROR   := ERRORBLOCK({|E| LERRO := .T., ::CERRO := E:DESCRIPTION})
LOCAL LERRO    := .F.
LOCAL ATMP     := ACLONE(::ACOLS)
LOCAL ARET     := {}
LOCAL NI
LOCAL BBLOCO
Local _LOCA03PE := EXISTBLOCK("LOCA03PE")

DEFAULT CCOND  := ".T."

::LEDIT := .T.
::AGET  := {}
::CERRO := ""

BEGIN SEQUENCE
	FOR NI:=1 TO LEN(::AHEADER)
		CCOND := STRTRAN(UPPER(CCOND), UPPER(ALLTRIM(::AHEADER[NI,2])), 'ATMP[NI,' + ALLTRIM(STR(NI))+ ']')
	NEXT

	IF LERRO
		IF _LOCA03PE
			EXECBLOCK("_LOCA03PE" , .T. , .T. , {oError}) 
		ENDIF
		RETURN {}
	ENDIF

	BBLOCO := &("{|NI| " + CCOND + "}")

	FOR NI:=1 TO LEN(ATMP)
		IF LERRO
			IF _LOCA03PE
				EXECBLOCK("_LOCA03PE" , .T. , .T. , {oError}) 
			ENDIF
			RETURN {}
		ENDIF
		IF  EVAL(BBLOCO, NI)
			AADD(ARET, ACLONE(ATMP[NI]) )
			AADD(::AGET, NI)
		ENDIF
	NEXT
END SEQUENCE

IF _LOCA03PE
	EXECBLOCK("_LOCA03PE" , .T. , .T. , {oError}) 
ENDIF

RETURN ACLONE(ARET)


/*BEGINDOC
//����������������������������Ŀ
//?METHOD SETDATA             ?
//?ATUALIZA OS DADOS DO ACOLS ?
//������������������������������
ENDDOC*/
METHOD SETDATA(ACOLS) CLASS BECHANGE

LOCAL OERROR   := ERRORBLOCK({|E| LERRO := .T., ::CERRO := E:DESCRIPTION})
LOCAL LERRO    := .F.
LOCAL ATMP     := ACLONE(::ACOLS)
LOCAL BTMP     := ::BORD
LOCAL NI
Local _LOCA03PE := EXISTBLOCK("LOCA03PE")

IF ! ::LEDIT
	::CERRO := "ANTES DO METODO SETDATA, DEVE HAVER O METODO GETDATA"
	IF _LOCA03PE
		EXECBLOCK("_LOCA03PE" , .T. , .T. , {oError}) 
	ENDIF
	RETURN .F.
ENDIF

::ACOLS := {}

FOR NI:=1 TO LEN(ATMP)
	IF LERRO
		IF _LOCA03PE
			EXECBLOCK("_LOCA03PE" , .T. , .T. , {oError}) 
		ENDIF
		RETURN .F.
	ENDIF
	IF ASCAN(::AGET, NI) == 0
		AADD(::ACOLS, ACLONE(ATMP[NI]) )
	ENDIF
NEXT

FOR NI:=1 TO LEN(ACOLS)	// ADICIONA NOVOS
	AADD(::ACOLS, ACLONE(ACOLS[NI]) )
NEXT

IF !EMPTY(BTMP)
	ATMP    := ACLONE(::ACOLS)
	ATMP    := ASORT(ATMP,,, BTMP)
	::ACOLS := ACLONE(ATMP)
ENDIF

IF _LOCA03PE
	EXECBLOCK("_LOCA03PE" , .T. , .T. , {oError}) 
ENDIF

::CERRO := ""
::LEDIT := .F.
::AGET  := {}

RETURN .T.



/*BEGINDOC
//����������������������������?
//?ETHOD SETORDER            ?
//?TRIBUI ORDENA��O AOS DADOS?
//����������������������������?
ENDDOC*/
METHOD SETORDER(CORD) CLASS BECHANGE

LOCAL OERROR   := ERRORBLOCK({|E| LERRO := .T., ::CERRO := E:DESCRIPTION})
LOCAL LERRO    := .F.
LOCAL ATMP     := ACLONE(::ACOLS)
LOCAL BTMP
LOCAL NI
Local _LOCA03PE := EXISTBLOCK("LOCA03PE")

IF EMPTY(CORD)
	::BORD  := NIL
	IF _LOCA03PE
		EXECBLOCK("_LOCA03PE" , .T. , .T. , {oError}) 
	ENDIF
	RETURN .T.
ENDIF

BEGIN SEQUENCE
	FOR NI:=1 TO LEN(::AHEADER)
		CORD := STRTRAN(UPPER(CORD), UPPER(ALLTRIM(::AHEADER[NI,2])), 'A[' + ALLTRIM(STR(NI))+ ']')
	NEXT
	CORD += " < " + STRTRAN(UPPER(CORD), 'A[', 'B[')
	BTMP := &("{|A,B| " + CORD + "}")
END SEQUENCE

IF _LOCA03PE
	EXECBLOCK("_LOCA03PE" , .T. , .T. , {oError}) 
ENDIF

IF LERRO
	RETURN .F.
ENDIF

ATMP := ASORT(ATMP,,, BTMP)

::ACOLS := ACLONE(ATMP)
::BORD  := BTMP

RETURN .T.



/*BEGINDOC
//��������������������������Ŀ
//?METHOD GETERRO           ?
//?RETORNA MENSAGEM DE ERRO ?
//����������������������������
ENDDOC*/
METHOD GETERRO() CLASS BECHANGE

RETURN ::CERRO



/*BEGINDOC
//����������������������������������������?
//?ETHOD FREE                            ?
//?TRIBUI NIL PARA OS ATRIBUTOS DA CLASSE?
//����������������������������������������?
ENDDOC*/
METHOD FREE() CLASS BECHANGE

::AHEADER	:= NIL
::ACOLS		:= NIL
::LEDIT		:= NIL
::AGET		:= NIL
::CERRO		:= NIL
::BORD		:= NIL

ERRORBLOCK({|| })

RETURN NIL



/*BEGINDOC
//����������������������������������������������������������?
//?ETHOD REMOVEITEM                                        ?
//?PAGA ITENS DO ACOLS DA CLASSE, ACEITA FILTRO CONDICIONAL?
//����������������������������������������������������������?
ENDDOC*/
METHOD REMOVEITEM(CCOND) CLASS BECHANGE

LOCAL OERROR   := ERRORBLOCK({|E| LERRO := .T., ::CERRO := E:DESCRIPTION})
LOCAL LERRO    := .F.
LOCAL ATMP     := ACLONE(::ACOLS)
LOCAL NI
LOCAL ARET     := {}
LOCAL BBLOCO
Local _LOCA03PE := EXISTBLOCK("LOCA03PE")

DEFAULT CCOND  := ".T." 

BEGIN SEQUENCE
	FOR NI:=1 TO LEN(::AHEADER)
		CCOND := STRTRAN(UPPER(CCOND), UPPER(ALLTRIM(::AHEADER[NI,2])), 'ATMP[NI,' + ALLTRIM(STR(NI))+ ']')
	NEXT

	IF LERRO
		IF _LOCA03PE
			EXECBLOCK("_LOCA03PE" , .T. , .T. , {oError}) 
		ENDIF
		RETURN .F.
	ENDIF

	BBLOCO := &("{|NI| " + CCOND + "}")

	FOR NI:=1 TO LEN(ATMP)
		IF LERRO
			IF _LOCA03PE
				EXECBLOCK("_LOCA03PE" , .T. , .T. , {oError}) 
			ENDIF
			RETURN .F.
		ENDIF
		IF  ! EVAL(BBLOCO, NI)
			AADD(ARET, ACLONE(ATMP[NI]) )
		ENDIF
	NEXT
END SEQUENCE

//ERRORBLOCK(oError) circenis
::ACOLS := ACLONE(ARET)

RETURN .T.
