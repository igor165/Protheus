#INCLUDE "loca055.ch" 
/*/{PROTHEUS.DOC} LOCA055.PRW
ITUP BUSINESS - TOTVS RENTAL
ATIVA��O DO CADASTRO DE FUNCION�RIOS PARA O TIME SHEET
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "PROTHEUS.CH"                                                                                                                     
#INCLUDE "RWMAKE.CH"

FUNCTION LOCA055()
LOCAL   _AAREA64  := GETAREA() 

PRIVATE ACORES    := {{'RA_TSHEET=="S"' , "BR_VERDE"   } , ;
				      {'RA_TSHEET<>"S"' , "BR_VERMELHO"} } 

PRIVATE CCADASTRO := STR0001 //"CAMPOS PARA O TIME SHEET"

PRIVATE AROTINA   := {{STR0002 , "AXPESQUI   " , 0 , 1} , ; //"PESQUISAR "
		              {STR0003 , "LOCA05502(2)" , 0 , 2} , ; //"VISUALIZAR"
		              {STR0004 , "LOCA05502(4)" , 0 , 3} , ; //"ALTERAR   "
					  {STR0005 , "U_LEG064   " , 0 , 4} } //"LEGENDA   "

PRIVATE ACAMPOS   := {{STR0006  , "RA_MAT    "  , ""} , ; //"CODIGO   "
	           		  {STR0007  , "RA_NOME   "  , ""} , ; //"NOME     "
		              {STR0008  , "RA_CODFUNC"  , ""} , ; //"FUN��O   "
		              {STR0009  , "RA_TSHEET "  , ""} , ; //"LOCA��O? "
		              {STR0010  , "RA_DSHEET "  , ""} , ; //"DIAS TRAB"
        		      {STR0011  , "RA_FOLGA  "  , ""} } //, ; //"FOLGA?   "
		              //{"VT?      "  , "RA_VT     "  , ""} } removido da 94

DBSELECTAREA("SRA")
DBSETORDER(1)

MBROWSE(6,1,22,75,"SRA",ACAMPOS,,,,,ACORES)

RESTAREA(_AAREA64)

RETURN  



// ======================================================================= \\
FUNCTION LOCA05501()
// ======================================================================= \\
// --> CHAMADA: MENU - "LEGENDA"

BRWLEGENDA(CCADASTRO,STR0012,{{"BR_VERDE"	   , STR0013    },; //"LEGENDA"###"CONTROLA LOCA��O"
                                {"BR_VERMELHO" , STR0014}})  //"N�O CONTROLA LOCA��O"

RETURN .T.



// ======================================================================= \\
FUNCTION LOCA05502(POPC)
// ======================================================================= \\
// --> CHAMADA: MENU - "VISUALIZAR" (2)  &  "ALTERAR" (4) 

LOCAL _NOPC			:= POPC
LOCAL _CUSER		:= RETCODUSR(SUBS(CUSUARIO,7,15))  //RETORNA O C�DIGO DO USU�RIO
LOCAL _LALTERA		:= IIF(_NOPC==4,.T.,.F.)
LOCAL APARAMBOX     := {}
LOCAL ARET 		    := {} 

PRIVATE LCANCEL     := .F.
PRIVATE _CFILMAT	:= SRA->RA_FILIAL
PRIVATE _CMAT		:= SRA->RA_MAT
PRIVATE _CNOME		:= SRA->RA_NOME
PRIVATE _CCODFUNC	:= SRA->RA_CODFUNC
PRIVATE _CDESFUNC	:= POSICIONE("SRJ" , 1 , SRA->RA_FILIAL+SRA->RA_CODFUNC , "RJ_DESC") 
PRIVATE _NINI       := IIF(SRA->RA_TSHEET == "S" , 1 , 2) 
PRIVATE _CTSHEET	:= SRA->RA_TSHEET
PRIVATE _NDSHEET	:= SRA->RA_DSHEET
PRIVATE _CFOLGA		:= SRA->RA_FOLGA
PRIVATE _CVT		:= 0 // removido da 94 SRA->RA_VT

FQ1->(DBSEEK(XFILIAL("FQ1") + _CUSER + "LOCA053",.T.))	// PROCURA O C�DIGO DE USU�RIO NA TABELA DE USU�RIOS ANALIZADORES DE PROMO��ES (Z_5)
_CCC := FQ1->FQ1_CC

FQ1->(DBSEEK(XFILIAL("FQ1") + _CUSER + "LOCT053B",.T.))	// PROCURA O C�DIGO DE USU�RIO NA TABELA DE USU�RIOS ANALIZADORES DE PROMO��ES (Z_5)
_CTPSERV := FQ1->FQ1_CC
	
IF ALLTRIM(SRA->RA_CC) $ _CCC .OR. "ALL" $ UPPER(ALLTRIM(_CCC+_CTPSERV))
	AADD(APARAMBOX,{1,STR0015           , _CFILMAT  , "@!", "", "", ".F.", 50, .T.}) 			// TIPO CARACTERE //"FILIAL"
	AADD(APARAMBOX,{1,STR0016        , _CMAT     , "@!", "", "", ".F.", 50, .T.}) 			// TIPO CARACTERE //"MATR�CULA"
	AADD(APARAMBOX,{1,STR0017             , _CNOME    , "@!", "", "", ".F.", 80, .T.}) 			// TIPO CARACTERE //"NOME"
	AADD(APARAMBOX,{1,STR0018      , _CCODFUNC , "@!", "", "", ".F.", 50, .T.}) 			// TIPO CARACTERE //"COD. FUN��O"
	AADD(APARAMBOX,{1,STR0019     , _CDESFUNC , "@!", "", "", ".F.", 80, .T.}) 			// TIPO CARACTERE //"DESC. FUN��O"
	AADD(APARAMBOX,{2,STR0013 , _NINI     , {STR0020,STR0021} , 40 , "_LALTERA" , .T.}) 	// COMBO  //"CONTROLA LOCA��O"###"SIM"###"N�O"
		
	IF PARAMBOX(APARAMBOX,STR0022,@ARET,,,,,,,,.F.)  //"PAR�METROS"
		IF VALTYPE(ARET[6]) == "C"
			IF     ALLTRIM(UPPER(ARET[6])) == STR0020 //"SIM"
				ARET[6] := "S"
			ELSEIF ALLTRIM(UPPER(ARET[6])) == STR0021 //"N�O"
				ARET[6] := "N"
			ENDIF
		ELSEIF VALTYPE(ARET[6]) == "N"
			IF     ARET[6] == 1
				ARET[6] := "S"
			ELSEIF ARET[6] == 2
				ARET[6] := "N"
			ENDIF
		ENDIF   
		IF _LALTERA
			SRA->(DBSETORDER(1))
			IF SRA->(DBSEEK( ARET[1] + ARET[2] ))
				SRA->(RECLOCK("SRA",.F.))
				SRA->RA_TSHEET := ARET[6]
				SRA->(MSUNLOCK()) 
			ENDIF 
		ENDIF 
	ENDIF 
ELSE
	MSGALERT(STR0023 + ALLTRIM(_CCC) + STR0024 + ALLTRIM(_CTPSERV) + ".",STR0025)  //"ATEN��O: VOC� N�O TEM ACESSO A ESTE FUNCION�RIO. VOC� POSSUI ACESSO AOS CENTROS DE CUSTO "###", E AOS SEGMENTOS "###"GPO - LOCT064.PRW"
ENDIF

RETURN


/*
// ======================================================================= \\
STATIC FUNCTION GRA064(_CMAT, _CTSHEET, _NDSHEET, _CFOLGA, _CVT)
// ======================================================================= \\
// --> N�O EXISTE NENHUMA CHAMADA !
SRA->(DBSETORDER(1))
IF SRA->(DBSEEK(XFILIAL("SRA")+_CMAT))
	RECLOCK("SRA",.F.)
	SRA->RA_TSHEET := _CTSHEET
	SRA->RA_DSHEET := _NDSHEET
	SRA->RA_FOLGA  := _CFOLGA
	SRA->RA_VT     := _CVT
	SRA->(MSUNLOCK()) 
ENDIF
          
RETURN .T.
*/
