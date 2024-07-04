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
//�������������������������������������������������������������������������Ŀ
//� PAR�METROS DA FUN��O:                                                   �
//�   CALIAS  -> ALIAS DA TABELA                                            �
//�   AFIELDS -> ARRAY  COM CAMPOS QUE NAO DEVEM SER DESCONSIDERADOS        �
//�   LSOCPOS -> L�GICO QUE DETERMINA QUE O RETORNO VIR� TB OS CAMPOS       �
//�                                                                         �
//� RETORNO DA FUNCAO                                                       �
//�   ARRAY FORMADO POR: ARRAY COM O AHEADER, QUANT. DE CAMPOS USADOS E A   �
//�                      MATRIZ S� COM OS CAMPOS, QUANDO SOLICITADO         �
//���������������������������������������������������������������������������

LOCAL AHEADER 	:= {}
LOCAL ACAMPOS   := {}
LOCAL COLDALIAS := ALIAS()
LOCAL ASAVSX3 	:= { (LOCXCONV(1))->( INDEXORD() ), (LOCXCONV(1))->( RECNO() ) }
LOCAL NUSAD	  	:= 0

REGTOMEMORY(CALIAS,.F.)

// AJUSTA OS PARAMETROS NECESS�RIOS COM SUAS OP��ES DEFAULT
DEFAULT AFIELDS := {}
DEFAULT LSOCPOS := .F.

// SETA A �REA DO SX3, �NDICE E EXECUTA O SEEK NO CALIAS
DBSELECTAREA("SX3")
DBSETORDER(1)
DBSEEK(CALIAS)

// LOOP PARA MONTAGEM DO AHEADER
WHILE (LOCXCONV(1))->( ! EOF() ) .AND. GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") == CALIAS                     
	IF X3USO( &(LOCXCONV(3)) ) .AND. CNIVEL >= GetSx3Cache(&(LOCXCONV(2)),"X3_NIVEL") .AND. ASCAN( AFIELDS , {|X| ALLTRIM(X) == ALLTRIM( GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")  ) } ) == 0      
		// VERIFICA SE O RETORNO TER� OS CAMPOS
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

// RESTAURA O AMBIENTE DO SX3 E A �REA SELECIONADA ANTERIORMENTE
DBSETORDER( ASAVSX3[1] )
DBGOTO( ASAVSX3[2] )
DBSELECTAREA( COLDALIAS )

RETURN { AHEADER , NUSAD , ACAMPOS } 



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���PROGRAMA  � ACOLS_LOCF� AUTOR � IT UP CONSULTORIA  � DATA � 30/06/2007 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � MONTA AHEADER PARA GETDADOS FUNCOES UTILIZADAS EM DIVERSOS ���
���          � FONTES PARA MONTAR AHEADER E ACOLS                         ���
���          � CHAMADA: LOCT004.PRW / LOCT005.PRW / LOCT060.PRW           ���
�������������������������������������������������������������������������͹��
���USO       � ESPECIFICO GPO                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//�������������������������������������������������������������������������Ŀ
//� PAR�METROS DA FUN��O:                                                   �
//�   CALIAS -> ALIAS DA TABELA                                             �
//�   AHEADER  -> MATRIZ COM O CABE�ALHO DE CAMPOS (AHEADER)                  �
//�   NOPC   -> SEGUE A MESMA L�GICA DAS OP��ES DA MATRIZ AROTINA           �
//�   NORD   -> ORDEM DO �NDICE DE CALIAS                                   �
//�   CCHAVE -> CHAVE PARA O SEEK DE POSICIONAMENTO EM CALIAS               �
//�   BCOND  -> CONDI��O DO `DO WHILE`                                      �
//�   BLINHA -> CONDI��O DE FILTRO (SELE��O) DE REGISTROS                   �
//�   LQUERY -> VARIAVEL LOGICA QUE INDICA SE O ALIAS � UMA QUERY           �
//�                                                                         �
//� RETORNO DA FUNCAO                                                       �
//�   ARRAY COM:                                                            �
//�   ELEMENTO [1] - ARRAY DO ACOLS                                         �
//�   ELEMENTO [2] - ARRAY DOS RECNOS DA TABELA                             �
//���������������������������������������������������������������������������

// AJUSTA OS PARAMETROS NECESS�RIOS COM SUAS OP��ES DEFAULT
DEFAULT CALIAS := ALIAS()
DEFAULT CCHAVE := ""
DEFAULT NOPC   := 3
DEFAULT NORD   := 1
DEFAULT BCOND  := {|| .T.}
DEFAULT BLINHA := {|| .T.}
DEFAULT LQUERY := .F.

// ARMAZENA AREA ORIGINAL DO ARQUIVO A SER UTILIZADO NA MONTAGEM DO ACOLS
AAREAAUX := (CALIAS)->(GETAREA())

IF !NOPC == 3  			// INCLUS�O

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
				// VERIFICA SE O CAMPO � APENAS VIRTUAL
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
				// ACRESCENTA DADOS � MATRIZ
				AADD( ACOLS[ LEN(ACOLS) ], CVARTMP )
			NEXT NLOOP
			
			// ACRESCENTA A ACOLS A VARI�VEL L�GICA DE CONTROLE DE DELE��O DA LINHA
			AADD( ACOLS[ LEN(ACOLS) ], .F. )
			
			// ACRESCENTA A ARECNOS O N�MERO DO REGISTRO
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
