#INCLUDE "loca036.ch" 
/*/{PROTHEUS.DOC} LOCA036.PRW
ITUP BUSINESS - TOTVS RENTAL
MONTA AHEADER PARA GETDADOS FUNCOES UTILIZADAS EM DIVERSOS FONTES PARA MONTAR AHEADER E ACOLS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
#INCLUDE "PROTHEUS.CH"

FUNCTION LOCA036(CALIAS , AFIELDS , LSOCPOS)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARÂMETROS DA FUNÇÃO:                                                   ³
//³   CALIAS  -> ALIAS DA TABELA                                            ³
//³   AFIELDS -> ARRAY  COM CAMPOS QUE NAO DEVEM SER DESCONSIDERADOS        ³
//³   LSOCPOS -> LÓGICO QUE DETERMINA QUE O RETORNO VIRÁ TB OS CAMPOS       ³
//³                                                                         ³
//³ RETORNO DA FUNCAO                                                       ³
//³   ARRAY FORMADO POR: ARRAY COM O AHEADER, QUANT. DE CAMPOS USADOS E A   ³
//³                      MATRIZ SÓ COM OS CAMPOS, QUANDO SOLICITADO         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL AHEADER 	:= {}
LOCAL ACAMPOS   := {}
LOCAL COLDALIAS := ALIAS()
LOCAL ASAVSX3 	:= { (LOCXCONV(1))->( INDEXORD() ), (LOCXCONV(1))->( RECNO() ) }
LOCAL NUSAD	  	:= 0

REGTOMEMORY(CALIAS,.F.)

// AJUSTA OS PARAMETROS NECESSÁRIOS COM SUAS OPÇÕES DEFAULT
DEFAULT AFIELDS := {}
DEFAULT LSOCPOS := .F.

// SETA A ÁREA DO SX3, ÍNDICE E EXECUTA O SEEK NO CALIAS
DBSELECTAREA("SX3")
DBSETORDER(1)
DBSEEK(CALIAS)

// LOOP PARA MONTAGEM DO AHEADER
WHILE (LOCXCONV(1))->( ! EOF() ) .AND. GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") == CALIAS                     
	IF X3USO( &(LOCXCONV(3)) ) .AND. CNIVEL >= GetSx3Cache(&(LOCXCONV(2)),"X3_NIVEL") .AND. ASCAN( AFIELDS , {|X| ALLTRIM(X) == ALLTRIM( GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")  ) } ) == 0      
		// VERIFICA SE O RETORNO TERÁ OS CAMPOS
		IF LSOCPOS
			AADD( ACAMPOS, ALLTRIM( GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO") ) )
		ENDIF
		
		AADD( AHEADER, { ALLTRIM(X3TITULO()) , ;
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")       , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE")     , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO")     , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL")     , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_VALID")       , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_USADO")       , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO")        , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_F3")          , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT")     , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX")        , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_RELACAO")     , } )   
		
		NUSAD ++
		// ELIMINO VALID QUE ESTA COM PROBLEMA//
		IF GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO") $ "DTR_CODVEI"	
		    AHEADER[NUSAD][6]:=""   // ORIGINAL - VAZIO() .OR. (EXISTCPO('DA3') .AND. TMSA240VLD())                                                                               
	    ENDIF
	ENDIF
	
	DBSELECTAREA("SX3")
	DBSKIP()
ENDDO

// RESTAURA O AMBIENTE DO SX3 E A ÁREA SELECIONADA ANTERIORMENTE
DBSETORDER( ASAVSX3[1] )
DBGOTO( ASAVSX3[2] )
DBSELECTAREA( COLDALIAS )

RETURN { AHEADER , NUSAD , ACAMPOS } 



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ ACOLS_LOCFº AUTOR ³ IT UP CONSULTORIA  º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ MONTA AHEADER PARA GETDADOS FUNCOES UTILIZADAS EM DIVERSOS º±±
±±º          ³ FONTES PARA MONTAR AHEADER E ACOLS                         º±±
±±º          ³ CHAMADA: LOCT004.PRW / LOCT005.PRW / LOCT060.PRW           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION LOCA03601( CALIAS , AHEADER , NOPC , NORD , CCHAVE , BCOND , BLINHA , LQUERY ) 

#DEFINE _X3CONTEXTO 10
LOCAL ACOLS    := {}
LOCAL ARECNOS  := {}
LOCAL AAREAAUX := {}
LOCAL AAREAATU := GETAREA()
LOCAL NLOOP    := 0
LOCAL NHEAD    := LEN(AHEADER) 
LOCAL CVARTMP 

REGTOMEMORY(CALIAS,.F.)

CACAO := IIF(NOPC==1 , STR0001 , IIF(NOPC==3 , STR0002 , STR0003))  //"- VISUALIZAR"###"- ALTERAR"###"- EXCLUIR"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARÂMETROS DA FUNÇÃO:                                                   ³
//³   CALIAS -> ALIAS DA TABELA                                             ³
//³   AHEADER  -> MATRIZ COM O CABEÇALHO DE CAMPOS (AHEADER)                  ³
//³   NOPC   -> SEGUE A MESMA LÓGICA DAS OPÇÕES DA MATRIZ AROTINA           ³
//³   NORD   -> ORDEM DO ÍNDICE DE CALIAS                                   ³
//³   CCHAVE -> CHAVE PARA O SEEK DE POSICIONAMENTO EM CALIAS               ³
//³   BCOND  -> CONDIÇÃO DO `DO WHILE`                                      ³
//³   BLINHA -> CONDIÇÃO DE FILTRO (SELEÇÃO) DE REGISTROS                   ³
//³   LQUERY -> VARIAVEL LOGICA QUE INDICA SE O ALIAS É UMA QUERY           ³
//³                                                                         ³
//³ RETORNO DA FUNCAO                                                       ³
//³   ARRAY COM:                                                            ³
//³   ELEMENTO [1] - ARRAY DO ACOLS                                         ³
//³   ELEMENTO [2] - ARRAY DOS RECNOS DA TABELA                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// AJUSTA OS PARAMETROS NECESSÁRIOS COM SUAS OPÇÕES DEFAULT
DEFAULT CALIAS := ALIAS()
DEFAULT CCHAVE := ""
DEFAULT NOPC   := 3
DEFAULT NORD   := 1
DEFAULT BCOND  := {|| .T.}
DEFAULT BLINHA := {|| .T.}
DEFAULT LQUERY := .F.

// ARMAZENA AREA ORIGINAL DO ARQUIVO A SER UTILIZADO NA MONTAGEM DO ACOLS
AAREAAUX := (CALIAS)->(GETAREA())

IF !NOPC == 3  			// INCLUSÃO

	DBSELECTAREA(CALIAS)
	DBCLEARFILTER()
	IF LQUERY
		DBGOTOP()
	ELSE
		DBSETORDER(NORD)
		DBSEEK(CCHAVE)
	ENDIF
	
	// MONTA O ACOLS
	WHILE !EOF() .AND. EVAL( BCOND )
		IF EVAL(BLINHA)
			AADD( ACOLS, {} )
			FOR NLOOP := 1 TO NHEAD
				// VERIFICA SE O CAMPO É APENAS VIRTUAL
				IF AHEADER[ NLOOP, _X3CONTEXTO ] == "V"
					IF AHEADER[ NLOOP ][ 2 ] == "DTR_NOMMOT"
					   CVARTMP  := POSICIONE("DA4",1,XFILIAL("DA4")+FIELDGET( FIELDPOS("DTR_CODMOT")),"DA4_NOME" )
					ELSE
					    CVARTMP := CRIAVAR( AHEADER[ NLOOP ][ 2 ] )
				    ENDIF
				ELSE 
			        IF FUNNAME(0)=="LOCA047" .AND. ALLTRIM(AHEADER[ NLOOP ][ 2 ]) == "ZA7_QTD"
                       CVARTMP := FIELDGET( FIELDPOS( AHEADER[ NLOOP, 2] ) ) - FIELDGET( FIELDPOS( "ZA7_QJUE" ) )
			        ELSE 
			           CVARTMP := FIELDGET( FIELDPOS( AHEADER[ NLOOP, 2] ) ) 
				    ENDIF
				ENDIF
				// ACRESCENTA DADOS À MATRIZ
				AADD( ACOLS[ LEN(ACOLS) ], CVARTMP )
			NEXT NLOOP
			
			// ACRESCENTA A ACOLS A VARIÁVEL LÓGICA DE CONTROLE DE DELEÇÃO DA LINHA
			AADD( ACOLS[ LEN(ACOLS) ], .F. )
			
			// ACRESCENTA A ARECNOS O NÚMERO DO REGISTRO
			IF LQUERY
				AADD( ARECNOS, (CALIAS)->R_E_C_N_O_)
			ELSE
				AADD( ARECNOS, (CALIAS)->(RECNO()) )
			ENDIF
		ENDIF
		(CALIAS)->(DBSKIP())
	ENDDO

ELSE     

	AADD( ACOLS, {} )
	FOR NLOOP := 1 TO NHEAD
		AADD( ACOLS[LEN(ACOLS)], CRIAVAR( AHEADER[NLOOP, 2] ) )
	NEXT NLOOP
	AADD( ACOLS[LEN(ACOLS)] , .F.)
	AADD( ARECNOS , {} )                                     	

ENDIF

// RESTAURA AREA ORIGINAL DO ARQUIVO UTILIZADO NA MONTAGEM DO ACOLS
RESTAREA(AAREAAUX)

// RESTAURA AREA ORIGNAL DA ENTRADA DA ROTINA
RESTAREA(AAREAATU)

RETURN { ACOLS , ARECNOS } 
