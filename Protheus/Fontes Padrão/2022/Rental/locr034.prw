#INCLUDE "locr034.ch" 
/*/{PROTHEUS.DOC} LOCR034.PRW
ITUP BUSINESS - TOTVS RENTAL
GRAFICO DE GANTT - DISPONIBILIDADE DE FROTA
NA VERS�O ANTERIOR CHAMAVA-SE LOCGANT
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
#INCLUDE "PROTHEUS.CH" 
FUNCTION LOCR034()
// -- FORMBATCH
LOCAL CPERG     := "LOCP062"
LOCAL ASAYS		 := {}
LOCAL ABUTTONS	 := {}
LOCAL NOPCA     := 0
// -- MSDIALOG
PRIVATE CCADASTRO  := STR0001 //"DISPONIBILIDADE DE FROTA"
PRIVATE CFILTRO    := "" 				// NAO RETIRAR ( USADO NA TMSA144 )

//VALIDPERG(CPERG)
PERGUNTE(CPERG,.T.)

AADD( ASAYS, STR0002 ) //"ESTE PROGRAMA TEM COMO OBJETIVO, MONTAR O GR�FICO DE GANTT, "
AADD( ASAYS, STR0003 )  //"DE ACORDO COM A DISPONIBILIDADE DA FROTA. "
		
AADD( ABUTTONS, { 5, .T., {|| PERGUNTE(CPERG) } } )
AADD( ABUTTONS, { 1, .T., {|O| NOPCA := 1, O:OWND:END() } } )
AADD( ABUTTONS, { 2, .T., {|O| O:OWND:END() } } )
	
FORMBATCH( CCADASTRO, ASAYS, ABUTTONS )

IF EMPTY(MV_PAR03) .OR. EMPTY(MV_PAR04) 
	MSGINFO(STR0004, STR0005)                  //"PERIODO INICIAL OU FINAL ESTA EM BRANCO"###"LOC_A143 - GANTT"
	RETURN
ENDIF
	
IF NOPCA == 1
	CCADASTRO += " - " +	IIF(MV_PAR02==1,STR0006,STR0007) //"TRANSPORTE"###"EQUIPAMENTOS"
	PROCESSA( { | LEND | MONTAGANT( @LEND ) }, CCADASTRO, STR0008, .T. ) //"MONTANDO GR�FICO DE GANTT..."
ENDIF

RETURN NIL



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���FUN��O    �MONTAGANTT � AUTOR � IT UP BUSINESS     � DATA � 30/06/2007 ���
�������������������������������������������������������������������������Ĵ��
���DESCRI��O � ROTINA DE PROCESSAMENTO PARA MONTAR GRAFICO GANTT.         ���
�������������������������������������������������������������������������Ĵ��
��� USO      � ESPECIFICO GPO                                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION MONTAGANT( LEND )

// -- CONTROLE DE DIMENSOES
LOCAL ASIZE     := {}
LOCAL AOBJECTS  := {}
LOCAL AINFO     := {}
// -- CONTROLE DA FUNCAO PMSGANTT
LOCAL NTSK
LOCAL DINI      := CTOD("")		//DDATABASE
LOCAL NBOTTOM   := -60
LOCAL NRIGHT     := -10
LOCAL ABUTTONS  := {}
LOCAL ACONFIG   := {1,.T.,.T.,.T.,.T.,,"1","1",.T.}		// OS PAR�METROS 3, 4 E 5 S�O OBRIGATORIAMENTE L�GICOS - CRISTIAM ROSSI EM 12/08/2016
LOCAL ODLG , OBOLD
// -- CONTROLE GERAIS
LOCAL AAUXCFG    := {}

//LOCAL APOSOBJ := {}

PRIVATE AGANTT   := {}
PRIVATE OGANTT
PRIVATE BRFSHGANTT //VARIAVEL UTILIZADA NO PMSGANTT PARA FAZER O REFRESH

// DEFINE FONT OBOLD NAME "ARIAL" BOLD
OBOLD := TFONT():NEW("ARIAL",,12,,.T.,,,,.T.,.F.)

// -- GERA O ARRAY UTILIZADO NA FUNCAO PMSGANTT.
AADD(ABUTTONS, { "NOCHECKED" , { || LEGFROTA() } , STR0009 , STR0009 } ) //"LEGENDA"###"LEGENDA"

// -- CALCULA AS DIMENSOES DA TELA.
ASIZE    := MSADVSIZE( .T. )
NBOTTOM  += OMAINWND:NBOTTOM
NRIGHT   += OMAINWND:NRIGHT
AOBJECTS	:= {}
AADD(AOBJECTS,{100,50,.T.,.T.,.T.})
AINFO	   := {ASIZE[1],ASIZE[2],ASIZE[3],ASIZE[4],0,0}
APOSOBJH	:= MSOBJSIZE(AINFO,AOBJECTS,.T.,.F.)

DEFINE MSDIALOG ODLG TITLE CCADASTRO OF OMAINWND PIXEL FROM ASIZE[7],00 TO ASIZE[6],ASIZE[5]

AAUXCFG := { ACONFIG[1], ACONFIG[3], ACONFIG[4], ACONFIG[5], ACONFIG[6], ACONFIG[7], ACONFIG[9] }

IF MV_PAR02 == 1
	FROTAT( , , OBOLD ) 
ELSE
	FROTA( , , OBOLD ) 
ENDIF

_CCABREL := IIF(MV_PAR02==1,STR0006,STR0010) //"TRANSPORTE"###"EQUIPAMENTO"

PMSGANTT(AGANTT,;
		ACONFIG,;
		@DINI,;
		NIL,;
		ODLG,;
		{14,1,(NBOTTOM/2)-40,(NRIGHT/2)-4},;
		{{_CCABREL,45},{STR0011,130}},; //"DESCRI��O"
		@NTSK,;
		NIL,;
		"",;
		@OGANTT )

ACTIVATE MSDIALOG ODLG CENTERED ON INIT ENCHOICEBAR(ODLG,{|| ODLG:END() },{|| ODLG:END() },,ABUTTONS)

RETURN NIL



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���FUN��O    � FROTACOR  � AUTOR � IT UP BUSINESS     � DATA � 30/06/2007 ���
�������������������������������������������������������������������������Ĵ��
���DESCRI��O � OBTEM A COR DO STATUS DA FROTA NO GANTT.                   ���
�������������������������������������������������������������������������Ĵ��
���PARAMETRO � STATUS DA FROTA                                            ���
�������������������������������������������������������������������������Ĵ��
��� USO      � ESPECIFICO GPO                                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION FROTACOR( CSTATUS )

// -- CONTROLES GERAIS.
LOCAL ACORES := {}
LOCAL CCOR   := ""
LOCAL NSEEK  := 0

IF EMPTY(CSTATUS)
	CSTATUS := ""
ENDIF                 
    
IF MV_PAR02 == 1 		// TRANSPORTES    
	IF !CSTATUS $ "1/2/3/4/5/6/7/8/9/F/M/R"
    	CSTATUS:=""
    ENDIF                                  
 //	AADD( ACORES , { ""  , RGB(0,0,0)       })	// SEM STATUS    - PRETO
	AADD( ACORES , { "1" , RGB(0,255,0)     })	// DISPONIV      - VERDE	
	AADD( ACORES , { "2" , RGB(153,51,0)    })	// MOBILIZA      - MARRON
	AADD( ACORES , { "3" , RGB(255,0,0)     })	// TRABALHA 	 - VERMELHO
	AADD( ACORES , { "4" , RGB(153,51,0)    })	// CARREGAN      - MARRON
	AADD( ACORES , { "5" , RGB(153,51,0)    })	// DESCARRE      - MARRON
	AADD( ACORES , { "6" , RGB(0,0,0)       })	// PARADO        - PRETO
	AADD( ACORES , { "7" , RGB(153,51,0)    })	// DESMOBIL      - MARRON
	AADD( ACORES , { "8" , RGB(255,102,0)   })	// ESTADIAS      - LARANJA
	AADD( ACORES , { "9" , RGB(192,192,192) })	// MANUTENC CORR - CINZA
	AADD( ACORES , { "F" , RGB(255,0,255)	})	// FRETE         - PINK
	AADD( ACORES , { "M" , RGB(192,192,192) })	// MANUTENC PREV - CINZA
	AADD( ACORES , { "R" , RGB(0,0,255)     })	// RESERVADO 	 - AZUL
 ELSE			    	// EQUIPAMENTOS
 	IF !CSTATUS $ "0/1/2/3/4/5/6/7/8/9/C/R"
   		CSTATUS := " "
	ENDIF
	AADD( ACORES , { " " , RGB(0,0,255)	    })	// SEM STATUS    - AZUL
	AADD( ACORES , { "0" , RGB(0,150,255)   })	// MO 	         - AZUL CLARO
	AADD( ACORES , { "1" , RGB(0,255,0)     })	// DISPONIVEL    - VERDE
	AADD( ACORES , { "2" , RGB(255,102,0)   })	// MOBILIZADO    - LARANJA
	AADD( ACORES , { "3" , RGB(255,0,0)	    })	// TRABALHO      - VERMELHO
	AADD( ACORES , { "4" , RGB(255,255,0)   })	// DESMOBILIZADO - AMARELO
	AADD( ACORES , { "5" , RGB(153,51,0)    })	// MONTAGEM      - MARROM
	AADD( ACORES , { "6" , RGB(153,51,0)    })	// DESMONTAGEM   - MARROM
	AADD( ACORES , { "7" , RGB(255,255,255) })	// VENDA         - BRANCO
	AADD( ACORES , { "8" , RGB(192,192,192) })	// VENDIDO       - CINZA
	AADD( ACORES , { "9" , RGB(255,0,255)   })	// MANUT PREV    - PINK
	AADD( ACORES , { "C" , RGB(0,0,0)	    })	// MANUT CORR    - PRETO
	AADD( ACORES , { "R" , RGB(0,0,255)	    })	// RESERVADO     - AZUL
ENDIF

IF ( NSEEK := ASCAN( ACORES, { |X| X[1] == CSTATUS } ) ) > 0
	CCOR   := ACORES[ NSEEK, 2 ]
ENDIF

RETURN ( CCOR )



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���FUN��O    � FROTATXT  � AUTOR � IT UP BUSINESS     � DATA � 30/06/2007 ���
�������������������������������������������������������������������������Ĵ��
���DESCRI��O � OBTEM O TEXTO REFER�NTE AO STATUS DA FROTA NO GANTT.       ���
�������������������������������������������������������������������������Ĵ��
���PARAMETRO � STATUS DA FROTA                                            ���
�������������������������������������������������������������������������Ĵ��
��� USO      � ESPECIFICO GPO                                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION FROTATXT( CSTATUS, CAS, CPROJET, CLABEL )

LOCAL CRET      := ""
LOCAL COBRA     := ""		// IIF(!EMPTY(CNOMORI) .OR. !EMPTY(CESTORI),SUBSTR(CNOMORI,1,10)+"/"+CESTORI,"")
//LOCAL CNOMORI := ""		// ALLTRIM(POSICIONE("FP1",1,SUBSTR(CPROJET,5,2) + CPROJET,"FP1_NOMORI"))
//LOCAL CESTORI := ""		// ALLTRIM(POSICIONE("FP1",1,SUBSTR(CPROJET,5,2) + CPROJET,"FP1_ESTORI"))

IF CSTATUS == "3"
	FP1->( DBSETORDER(1) )
	IF FP1->( DBSEEK( XFILIAL("FP1") + CPROJET ) ) .AND. !EMPTY( FP1->FP1_NOMORI )
		COBRA += ALLTRIM(FP1->FP1_NOMORI) + IIF( !EMPTY(FP1->FP1_ESTORI), "/", "") + ALLTRIM(FP1->FP1_ESTORI)
	ELSE
		FP0->( DBSETORDER(1) )
		IF FP0->( DBSEEK( XFILIAL("FP0") + CPROJET ) ) .AND. !EMPTY( FP0->FP0_CLI )
			SA1->( DBSETORDER(1) )
			IF SA1->( DBSEEK( XFILIAL("SA1") + FP0->( ZA0_CLI + ZA0_LOJA ) ) )
				COBRA += ALLTRIM( IIF( !EMPTY(SA1->A1_NREDUZ), SA1->A1_NREDUZ, SA1->A1_NOME) ) + IIF( !EMPTY(SA1->A1_EST), "/", "") + ALLTRIM(SA1->A1_EST)
			ENDIF
		ENDIF
	ENDIF
	RETURN COBRA
ENDIF

IF MV_PAR02 == 1		//TRANSPORTES    
	CRET := ;
	IIF(CSTATUS=="0",CLABEL,;		//0-INDISP
	IIF(CSTATUS=="1",CLABEL,;		//1-DISP
	IIF(CSTATUS=="2",CLABEL,;		//2-MOBIL
	IIF(CSTATUS=="3",COBRA,;		//3-TRAB
	IIF(CSTATUS=="4",CLABEL,;		//4-CARR
	IIF(CSTATUS=="5",CLABEL,;		//5-DESCAR
	IIF(CSTATUS=="6",CLABEL,;		//6-PARADO
	IIF(CSTATUS=="7",CLABEL,;		//7-DESMOB
	IIF(CSTATUS=="8",CLABEL,;		//8-ESTADIAS
	IIF(CSTATUS=="9",CLABEL,""))))))))))//MANUT
ELSE				//EQUIPAMENTOS
	CRET := ;
	IIF(CSTATUS=="0",CLABEL,;		//0-MO
	IIF(CSTATUS=="1",CLABEL,;		//1-DISP
	IIF(CSTATUS=="2",CLABEL,;		//2-MOBI
	IIF(CSTATUS=="3",COBRA,;		//3-TRAB
	IIF(CSTATUS=="4",CLABEL,;		//4-DESMOB
	IIF(CSTATUS=="5",CLABEL,;		//5-MONT
	IIF(CSTATUS=="6",CLABEL,;		//6-DESMON
	IIF(CSTATUS=="7",CLABEL,;		//7-VENDA
	IIF(CSTATUS=="8",CLABEL,;		//8-VENDIDO
	IIF(CSTATUS=="9",CLABEL,;		//9-MANUT PREV
	IIF(CSTATUS=="C",CLABEL,;		//C-MANUT CORR
	IIF(CSTATUS=="R",CLABEL,""))))))))))))	//R-RESERV
ENDIF	

RETURN ( CRET )



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���FUN��O    � LEGFROTA  � AUTOR � IT UP BUSINESS     � DATA � 30/06/2007 ���
�������������������������������������������������������������������������Ĵ��
���DESCRI��O � EXIBE A LEGENDA DO STATUS DA FROTA                         ���
�������������������������������������������������������������������������Ĵ��
���SINTAXE   � LEGFROTA()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� USO      � ESPECIFICO GPO                                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION LEGFROTA( ASTATUS, CAS, CPROJETO )

LOCAL CTITULO := ''

IF MV_PAR02 == 1 //TRANSPORTES  
                                                   	
	CTITULO := STR0012			 //"TRANSPORTES"
	ASTATUS := {{ 'BR_VERDE'	, STR0013 	 	},; //"DISPONIVEL"
				{ 'BR_MARRON'   , STR0014 		},; //"MOBILIZADO"
				{ 'BR_VERMELHO' , STR0015	  	},; //"TRABALHANDO"
				{ 'BR_MARRON'   , STR0016	  	},; //"CARREGANDO"
				{ 'BR_MARRON'   , STR0017	},; //"DESCAREGANDO"
				{ 'BR_PRETO'    , STR0018	  		},; //"PARADO"
				{ 'BR_MARRON'   , STR0019	},; //"DESMOBILIZACAO"
				{ 'BR_LARANJA'  , STR0020	  	},; //"ESTADIAS"
				{ 'BR_CINZA'    , STR0021	},; //"MANUT.CORRETIVA"
				{ 'BR_PINK'     , STR0022	  		},; //"FRETE"
				{ 'BR_CINZA'    , "MANUT.PREVENTIVA"},;			 
				{ 'BR_AZUL'     , STR0023    	}}  //"RESERVADO"
			 
ELSE			//EQUIPAMENTOS
	CTITULO :=	IIF(MV_PAR02==2,STR0007,; //"EQUIPAMENTOS"
				IIF(MV_PAR02==3,STR0024,; //"GRUA"
				IIF(MV_PAR02==4,STR0025,; //"PLATAFORMA"
				IIF(MV_PAR02==5,STR0026,"")))) //"REMO��O"
	ASTATUS := {{ 'BR_VERDE'    , STR0027},; //"DISPONIVEL    "
				{ 'BR_LARANJA'  , STR0028},; //"MOBILIZADO    "
				{ 'BR_VERMELHO'	, STR0029},; //"TRABALHANDO   "
				{ 'BR_AMARELO'  , STR0030},; //"DESMOBILIZANDO"
				{ 'BR_MARRON'   , STR0031},; //"MONTAGEM      "
				{ 'BR_MARRON'   , STR0032},;  //"DESMONTAGEM   "
				{ 'BR_BRANCO'	, STR0033},; //"VENDA         "
				{ 'BR_CINZA'	, STR0034},; //"VENDIDO       "
				{ 'BR_PINK'		, STR0035},; //"MANUT PREV    "
				{ "BR_PRETO"	, STR0036},; //"MANUT CORR    "
				{ 'BR_AZUL'		, STR0037}} //"RESERVADO     "
ENDIF

BRWLEGENDA( CTITULO, STR0038, ASTATUS ) //"STATUS"

RETURN NIL 



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���FUN��O    � VALIDPERG � AUTOR � IT UP BUSINESS     � DATA � 30/06/2007 ���
�������������������������������������������������������������������������͹��
���DESCRI��O � VERIFICA A EXISTENCIA DAS PERGUNTAS CRIANDO-AS CASO SEJA   ���
���          � NECESSARIO (CASO NAO EXISTAM).                             ���
�������������������������������������������������������������������������͹��
��� USO      � ESPECIFICO GPO                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC FUNCTION VALIDPERG(CPERG)
/*
LOCAL _SALIAS := ALIAS()
LOCAL AREGS := {}
LOCAL I,J

DBSELECTAREA("SX1")
DBSETORDER(1)
CPERG := PADR(CPERG,10)

//         {GRUPO,ORDEM,PERGUNT         ,PERSPA          ,PERENG             ,VARIAVL ,TIPO,TAMANHO,DECIMAL,PRESEL,GSC,VALID      ,VAR01      ,DEF01,DEFSPA1,DEFENG1                     ,CNT01,VAR02,DEF02,DEFSPA2,DEFENG2,CNT02,VAR03,DEF03,DEFSPA3,DEFENG3,CNT03,VAR04,DEF04,DEFSPA4,DEFENG4,CNT04,VAR05,DEF05,DEFSPA5,DEFENG5,CNT05,F3   ,PYME,GRPSXG,HELP,PICTURE     })
AADD(AREGS,{CPERG,"01" ,STR0039,STR0039,STR0039,"MV_CH1","C",06,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","ST6","S","","",""}) //"FAMILIA"###"FAMILIA"###"FAMILIA"
//AADD(AREGS,{CPERG,"02" ,"FROTA INDIVIDUAL","FROTA","FROTA","MV_CH2","C",16,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","ST9","S","","",""})
AADD(AREGS,{CPERG,"02" ,STR0040,STR0040,STR0040,"MV_CH2","C",00,0,1,"C","","MV_PAR02",STR0012,STR0012,STR0012,"","",STR0007,STR0007,STR0007,"","","","","","","","","","","","","","","","","","S","","",""})  //"TIPO"###"TIPO"###"TIPO"###"TRANSPORTES"###"TRANSPORTES"###"TRANSPORTES"###"EQUIPAMENTOS"###"EQUIPAMENTOS"###"EQUIPAMENTOS"
AADD(AREGS,{CPERG,"03" ,STR0041,STR0041,"PERIODO DE?","MV_CH3","D",08,0,0,"G","NAOVAZIO()","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""})  //"PERIODO DE?"###"PERIODO DE?"
AADD(AREGS,{CPERG,"04" ,STR0042,STR0042,STR0042,"MV_CH4","D",08,0,0,"G","NAOVAZIO()" ,"MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""}) //"PERIODO ATE?"###"PERIODO ATE?"###"PERIODO ATE?"
AADD(AREGS,{CPERG,"05" ,STR0043,STR0043,STR0043,"MV_CH5","C",02,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""}) //"FILIAL DE?"###"FILIAL DE?"###"FILIAL DE?"
AADD(AREGS,{CPERG,"06" ,STR0044,STR0044,STR0044,"MV_CH6","C",02,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""}) //"FILIAL ATE?"###"FILIAL ATE?"###"FILIAL ATE?"

// CCF 04.10 
PUTSX1(CPERG,"07",STR0045,"","","MV_CH7","C",16,00,00,"G","","ST9 ","","","MV_PAR07","","","","","","","","","","","","","","","","",,,,"") //"FROTA DE?   "
PUTSX1(CPERG,"08",STR0046,"","","MV_CH8","C",16,00,00,"G","","ST9 ","","","MV_PAR08","","","","","","","","","","","","","","","","",,,,"") //"FROTA ATE?  "
PUTSX1(CPERG,"09",STR0047,"","","MV_CH9","C",06,00,00,"G","","CLI   ","","","MV_PAR09","","","","","","","","","","","","","","","","",,,,"") //"CLIENTE DE? "
PUTSX1(CPERG,"10",STR0048,"","","MV_CHA","C",06,00,00,"G","","CLI   ","","",STR0049,"","","","","","","","","","","","","","","","",,,,"") //"CLIENTE ATE?"###"MV_PAR10"
PUTSX1(CPERG,"11","LOJA DE?    ","","","MV_CHB","C",02,00,00,"G","","      ","","","MV_PAR11","","","","","","","","","","","","","","","","",,,,"")
PUTSX1(CPERG,"12",STR0050,"","","MV_CHC","C",02,00,00,"G","","      ","","","MV_PAR12","","","","","","","","","","","","","","","","",,,,"") //"LOJA ATE?   "

FOR I:=1 TO LEN(AREGS)
    IF !DBSEEK(CPERG+AREGS[I,2])
        RECLOCK("SX1",.T.)
        FOR J:=1 TO FCOUNT()
            IF J <= LEN(AREGS[I])
                FIELDPUT(J,AREGS[I,J])
            ENDIF
        NEXT
        MSUNLOCK()
	ELSEIF I==3
        RECLOCK("SX1",.F.)
        FOR J:=1 TO FCOUNT()
            IF J <= LEN(AREGS[I])
                FIELDPUT(J,AREGS[I,J])
            ENDIF
        NEXT
        MSUNLOCK()
    ENDIF
NEXT

DBSELECTAREA(_SALIAS)
*/
RETURN


 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���FUN��O    � FROTA     � AUTOR � IT UP BUSINESS     � DATA � 30/06/2007 ���
�������������������������������������������������������������������������Ĵ��
���DESCRI��O � ATUALIZA O ARRAY UTILIZADO PELA ROTINA GANTT.              ���
�������������������������������������������������������������������������Ĵ��
���SINTAXE   � FROTA()                                                    ���
�������������������������������������������������������������������������Ĵ��
��� USO      � ESPECIFICO                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION FROTA(CFILORI , CVIAGEM , OBOLD)

// -- QUERY.
LOCAL CQUERY     := ""
LOCAL CALIASQRY  := ""

// -- CONTROLES GERAIS.
LOCAL CSTATUS    := "" 
LOCAL NSEEK      := 0 
LOCAL _DATA      := CTOD("")
LOCAL DDATINI    := CTOD("")
LOCAL DDATFIM    := CTOD("")
LOCAL CDESCR     := ""
LOCAL CCODBEM    := ""
//LOCAL CNOME    := ""
//LOCAL _DATINI  := CTOD("")
//LOCAL _DATFIM  := CTOD("")
//LOCAL DINI     := CTOD("")

DEFAULT OBOLD    := NIL

IF EMPTY( OBOLD )
	DEFINE FONT OBOLD NAME "ARIAL" BOLD
ENDIF

If MV_PAR02 == 1
	MsgAlert(STR0051,STR0052) //"Processo liberado apenas para a op��o equipamentos."###"Aten��o!"
	Return
EndIF


IF MV_PAR02 == 1 // TRANSPORTES
    CQUERY := " SELECT T9_CODBEM,T9_NOME,T9_MODELO,T9_CODFA,T9_CODFAMI,FPM_DTPROG, ISNULL(FPM_STATUS, '1') FPM_STATUS, FPM_AS, FPM_PROJET, FPM_AS, FPM_PROJET, FPM_LOCALI " 
	CQUERY += " FROM "+ RETSQLNAME("ST9") + " ST9 
	CQUERY += " LEFT JOIN "+ RETSQLNAME("FPM") + " ZLE ON FPM_FILIAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	CQUERY += " AND T9_CODBEM = FPM_FROTA "
	CQUERY += " AND FPM_DTPROG BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	CQUERY += " AND ZLE.D_E_L_E_T_ = '' "
	CQUERY += " WHERE T9_FILIAL = '"+XFILIAL("ST9")+"'"
	CQUERY += " AND T9_CODBEM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'"
	CQUERY += " AND (ST9.T9_TIPOSE = 'T' OR ST9.T9_TIPOSE = 'I' OR ST9.T9_TIPOSE = 'O') "
	IF !EMPTY(MV_PAR01)
		CQUERY += " AND ST9.T9_CODFAMI  =  '"+MV_PAR01+"'
	ENDIF
/*
	IF CFILANT <> "01"
		CQUERY += " AND SUBSTRING(T9_CENTRAB,1,2)  =  '"+CFILANT+"'
	ENDIF 
*/
	CQUERY += " AND ST9.D_E_L_E_T_ = ' '"
	CQUERY += " ORDER BY ST9.T9_CODFA,FPM_DTPROG "

ELSE			//EQUIPAMENTOS - TABELA ZLG
	
	CQRYF:= "FROM " + RETSQLNAME("ST9") + " ST9  LEFT JOIN "  + CRLF
	CQRYF+= 			RETSQLNAME("FPO") + " ZLG ON  ST9.T9_CODBEM = FPO_FROTA AND ZLG.D_E_L_E_T_ = ' ' "  + CRLF
	CQRY := "WHERE ST9.D_E_L_E_T_ = ' ' AND "  + CRLF
	CQRY +=       "ST9.T9_TIPOSE = '" +	IIF(MV_PAR02==2,"E",;
									IIF(MV_PAR02==3,"U",;
									IIF(MV_PAR02==4,"P",;
									IIF(MV_PAR02==5,"R","")))) + "' "  + CRLF
	CQRY += "	   AND ST9.T9_CODFAMI <> ' ' "   + CRLF
	CQRY += "	   AND ST9.T9_TIPOSE  <> 'A' AND ST9.T9_CODBEM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' -- F ROTA DE/ATE"  + CRLF
	CQRY += " AND SUBSTRING(ST9.T9_CENTRAB,1,2) BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'   "  + CRLF
	
	IF !EMPTY(MV_PAR01)
		CQRY += " AND ST9.T9_CODFAMI  =  '"+MV_PAR01+"'  "+ CRLF
	ENDIF

	CQRYZLG := 	  "AND   FPO_STATUS NOT IN ('A','E','S') AND ZLG.FPO_CODBEM = '' AND  ((ZLG.FPO_DTINI <= "  + DTOS(MV_PAR03) + " AND ZLG.FPO_DTINI <= " + DTOS(MV_PAR04)  + " AND ZLG.FPO_DTFIM >= "  + DTOS(MV_PAR03) + "  AND ZLG.FPO_DTFIM >= " + DTOS(MV_PAR04) + ") OR " +CRLF	// PER�ODO TOTALMENTE DENTRO DO LAN�AMENTO
	CQRYZLG +=       " (ZLG.FPO_DTINI >= "  + DTOS(MV_PAR03) + " AND ZLG.FPO_DTINI <= " + DTOS(MV_PAR04)  + " AND ZLG.FPO_DTFIM >= "  + DTOS(MV_PAR03) + "  AND ZLG.FPO_DTFIM <= " + DTOS(MV_PAR04) + ") OR "+CRLF	// PER�ODO TOTALMENTE FORA DO LAN�AMENTO
	CQRYZLG +=       " (ZLG.FPO_DTINI <= "  + DTOS(MV_PAR03) + " AND ZLG.FPO_DTINI <= " + DTOS(MV_PAR04)  + " AND ZLG.FPO_DTFIM >= "  + DTOS(MV_PAR03) + "  AND ZLG.FPO_DTFIM <= " + DTOS(MV_PAR04) + ") OR "+CRLF	// LAN�AMENTO TERMINA NO PER�ODO
	CQRYZLG +=       " (ZLG.FPO_DTINI >= "  + DTOS(MV_PAR03) + " AND ZLG.FPO_DTINI <= " + DTOS(MV_PAR04)  + " AND ZLG.FPO_DTFIM >= "  + DTOS(MV_PAR03) + "  AND ZLG.FPO_DTFIM >= " + DTOS(MV_PAR04) + "))  "+CRLF	// LAN�AMENTO INICIA NO PER�ODO
	CQRYCLI := "      AND ((ZLG.FPO_CODCLI BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'--CLIENTE DE/ATE" + CRLF
	CQRYCLI += "      AND ZLG.FPO_LOJA BETWEEN   '"+MV_PAR11+"' AND '"+MV_PAR12+"') OR (FPO_CODCLI = '' AND FPO_LOJA = '' AND FPO_STATUS IN ('C','9')) )--LOJA DE/ATE" + CRLF
    
	CTMPCLI := "TR34C"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2) //CRIATRAB(,.F.)
	CQRYINT := "SELECT 	DISTINCT ST9.T9_CODBEM,	ST9.T9_NOME,ST9.T9_MODELO,ST9.T9_CODFA,ST9.T9_CODFAMI,ZLG.FPO_DTINI,ZLG.FPO_DTFIM "+CRLF
	CQRYINT += "INTO  " + CTMPCLI + CRLF
	CQRYINT += CQRYF+CQRY+CQRYZLG+CQRYCLI
	CQRYINT += " ORDER BY T9_CODBEM,FPO_DTINI " 
	
	TCSQLEXEC(CQRYINT)
	
	CQRYINT := "SELECT 	DISTINCT ST9.T9_CODBEM,	ST9.T9_NOME,ST9.T9_MODELO,ST9.T9_CODFA,ST9.T9_CODFAMI,ZLG.FPO_DTINI,ZLG.FPO_DTFIM "+CRLF
	CQRYINT += CQRYF+CRLF
	CQRYINT += " JOIN " + CTMPCLI + " CLI ON ST9.T9_CODBEM = CLI.T9_CODBEM "+ CRLF
	CQRYINT += CQRY+CQRYZLG
	CQRYINT += " ORDER BY T9_CODBEM,FPO_DTINI " 
	
	CARQDIAS := LOCXITU07(CQRYINT,"T9_CODBEM", "FPO_DTINI","FPO_DTFIM",MV_PAR03, MV_PAR04 )                


	CQUERY := "SELECT 	T9_CODBEM,	T9_NOME,T9_MODELO,T9_CODFA,T9_CODFAMI,FPO_DTINI,FPO_DTFIM,FPO_PROJET,FPO_STATUS, " + CRLF
	CQUERY += " 		FPO_NOMCLI, FPO_LOCAL, FPO_NRAS, FPO_PROJET "   + CRLF
	CQUERY += CQRYF +CQRY + CQRYZLG+CQRYCLI+CRLF

	IF EMPTY(MV_PAR09+MV_PAR11) 
		CQUERY += "UNION ALL " + CRLF
		CQUERY += "SELECT 	T9_CODBEM,	T9_NOME,T9_MODELO,T9_CODFA,T9_CODFAMI,'"+ DTOS(MV_PAR03)+ "','"+ DTOS(MV_PAR04) + "','','1' , " + CRLF
		CQUERY += " 		'', '','','' "   + CRLF
		CQUERY += CQRYF+ CQRYZLG+CQRYCLI+CQRY +" AND FPO_LOJA IS NULL " + CRLF
   ENDIF
    //EU INCLUI ESSE UNION
	CQUERY += "UNION ALL " + CRLF
	
	CQUERY += "SELECT T9.T9_CODBEM, T9_NOME,T9_MODELO,T9_CODFA,T9_CODFAMI,DTINI, DTFIM,'','1', '','', '',''" + CRLF
	CQUERY += "FROM "+ RETSQLNAME("ST9") + " T9 " + CRLF
	CQUERY += "JOIN "+CARQDIAS + " DIAS ON DIAS.T9_CODBEM = T9.T9_CODBEM " + CRLF
	CQUERY += "WHERE T9.D_E_L_E_T_ = ''" + CRLF 
	CQUERY += "ORDER BY 1, 5,6 " + CRLF 

ENDIF

//CQUERY  := CHANGEQUERY( CQUERY )
CALIASQRY := GETNEXTALIAS()
//MEMOWRITE("C:\LOCGANT.SQL", CQUERY)
DBUSEAREA( .T., 'TOPCONN', TCGENQRY(,, CQUERY), CALIASQRY, .T., .T. )
		
IF MV_PAR02 == 1
	TCSETFIELD(CALIASQRY,"FPM_DTPROG","D",8,0)
ELSE
	TCSETFIELD(CALIASQRY,"FPO_DTINI","D",8,0)
	TCSETFIELD(CALIASQRY,"FPO_DTFIM","D",8,0)
ENDIF	

(CALIASQRY)->( DBGOTOP() )     
WHILE (CALIASQRY)->( !EOF() )
   	
		//������������������������������������������������������������������������Ŀ
		//� FORMATO DO VETOR AGANTT            LUI                                    �
		//������������������������������������������������������������������������Ĵ
		//� AGANTT[1] = ARRAY - FROTAS ALOCADAS                                      �
		//� 	AGANTT[1,1] = FROTA                                                  �
		//� 	AGANTT[1,2] = TEXTO PARA EXIBIR AO LADO ESQUERDO DA FROTA         �
		//� 	AGANTT[1,3] = INDICE                                �
		//� 	AGANTT[1,4] =                                    �
		//� AGANTT[2] = PROGRAMACAO DA FROTA                           �
		//� 	AGANTT[2,1] = DATA INICIO DA PROGRAMACAO                        �
		//� 	AGANTT[2,2] =                         �
		//� 	AGANTT[2,3] = DATA FIM DA PROGRAMACAO                           �
		//� 	AGANTT[2,4] =                            �
		//� 	AGANTT[2,5] = TEXTO PARA EXIBIR SOBRE O STATUS DA FROTA             �
		//� 	AGANTT[2,6] = COR DO STATUS DA FROTA                                �
		//� 	AGANTT[2,7] = A��O AO CLICAR NO STATUS                     �
		//� 	AGANTT[2,8] = INDICA ONDE O TEXTO DO 5O ELEMENTO SERA EXIBIDO        �
		//� 		1 = AO LADO DA TAREFA( VIAGEM ) OU 2 = SOBRE A TAREFA( VIAGEM ).  �
		//� 	AGANTT[2,9] = COR DO CABECALHO DO GRAFICO                            �
		//� AGANTT[3] = ELEMENTO NAO UTILIZADO                                     �
		//� AGANTT[4] = TIPO DA FONT UTILIZADA                                     �
		//��������������������������������������������������������������������������
 
   IF MV_PAR02 == 1 // TRANSPORTES
   		CCODBEM    := ( CALIASQRY )->T9_CODFA
    	CCODIGO    := ( CALIASQRY )->T9_CODBEM
		CDESCR     := ( CALIASQRY )->T9_NOME
//		CDESCR     := IIF(EMPTY(( CALIASQRY )->T9_MODELO),RIGHT(ALLTRIM(( CALIASQRY )->T9_NOME),10),( CALIASQRY )->T9_MODELO)
		CHISTO	   := IIF(( CALIASQRY )->FPM_STATUS=="0", "INDISPON",;
					  IIF(( CALIASQRY )->FPM_STATUS=="1", STR0053,; //"DISPONIV"
					  IIF(( CALIASQRY )->FPM_STATUS=="2", STR0054,; //"MOBILIZA"
					  IIF(( CALIASQRY )->FPM_STATUS=="3", STR0055,; //"TRABALHA"
					  IIF(( CALIASQRY )->FPM_STATUS=="4", STR0056,; //"CARREGAN"
					  IIF(( CALIASQRY )->FPM_STATUS=="5", STR0057,; //"DESCARRE"
					  IIF(( CALIASQRY )->FPM_STATUS=="6", STR0018,; //"PARADO"
					  IIF(( CALIASQRY )->FPM_STATUS=="7", STR0058,; //"DESMOBIL"
					  IIF(( CALIASQRY )->FPM_STATUS=="8", STR0020,; //"ESTADIAS"
					  IIF(( CALIASQRY )->FPM_STATUS=="9", STR0059,"")))))))))) //"MANUTENC"
   		_DATA	   := ( CALIASQRY )->FPM_DTPROG
   		DDATINI	   := _DATA
   		DDATFIM    := _DATA 
   		CSTATUS    := ( CALIASQRY )->FPM_STATUS
   		CAS        := ( CALIASQRY )->FPM_AS
   		CPROJET    := ( CALIASQRY )->FPM_PROJET
   		DDATULT    := _DATA 
   		CLABEL     := ( CALIASQRY )->FPM_LOCALI
	ELSE 			//EQUIPAMENTOS
		CCODBEM    := ( CALIASQRY )->T9_CODFA
    	CCODIGO    := ( CALIASQRY )->T9_CODBEM
		CDESCR     := ( CALIASQRY )->T9_NOME
//		CDESCR     := IIF(EMPTY(( CALIASQRY )->T9_MODELO),RIGHT(ALLTRIM(( CALIASQRY )->T9_NOME),10),( CALIASQRY )->T9_MODELO)
		CHISTO     := IIF(( CALIASQRY )->FPO_STATUS=="0",STR0060,; //"MO"
					  IIF(( CALIASQRY )->FPO_STATUS=="1",STR0013,; //"DISPONIVEL"
					  IIF(( CALIASQRY )->FPO_STATUS=="2",STR0014,; //"MOBILIZADO"
					  IIF(( CALIASQRY )->FPO_STATUS=="3","(" + DTOC(( CALIASQRY )->FPO_DTFIM) + ")" ,;
					  IIF(( CALIASQRY )->FPO_STATUS=="4",STR0061,; //"DESMOBILIZADO"
					  IIF(( CALIASQRY )->FPO_STATUS=="5",STR0062,; //"MONTAGEM"
					  IIF(( CALIASQRY )->FPO_STATUS=="6",STR0063,; //"DESMONTAGEM"
					  IIF(( CALIASQRY )->FPO_STATUS=="7",STR0064,; //"VENDA"
					  IIF(( CALIASQRY )->FPO_STATUS=="8",STR0065,; //"VENDIDO"
					  IIF(( CALIASQRY )->FPO_STATUS=="9",STR0066,; //"MANUT PREV"
					  IIF(( CALIASQRY )->FPO_STATUS=="C",STR0067,; //"MANUT CORR"
					  IIF(( CALIASQRY )->FPO_STATUS=="R",STR0023,"")))))))))))) //"RESERVADO"
		DDATINI    := IIF(( CALIASQRY )->FPO_DTINI < MV_PAR03, MV_PAR03,( CALIASQRY )->FPO_DTINI )
   		DDATFIM    := IIF(( CALIASQRY )->FPO_DTFIM > MV_PAR04, MV_PAR04,( CALIASQRY )->FPO_DTFIM )
   		CSTATUS    := ( CALIASQRY )->FPO_STATUS
   		CAS        := ( CALIASQRY )->FPO_NRAS
   		CPROJET    := ( CALIASQRY )->FPO_PROJET
   		DDATULT    := ( CALIASQRY )->FPO_DTFIM
   		CLABEL     := ( CALIASQRY )->FPO_LOCAL
	ENDIF		                               

	NSEEK  := ASCAN( AGANTT, {  | ATAR|  ATAR[1,1] == CCODIGO } )

    IF NSEEK  == 0 
   		XSTATUS := 1                          
	   	AADD( AGANTT,	{ { /*TRANSFORM(CCODBEM,"@R XXX-99-999-999")*/ CCODIGO, CDESCR /*+ "  " + CHISTO*/, /*CCHAVE*/ CCODIGO, DDATULT },;
						{ {DDATINI,"00:00",DDATFIM,"24:00",FROTATXT( CSTATUS, CAS, CPROJET, CLABEL ),FROTACOR( CSTATUS ),"",2,CLR_GRAY} },,OBOLD})
	ELSE
	   	AADD( AGANTT[NSEEK, 2],	{DDATINI,"00:00",DDATFIM,"24:00",FROTATXT( CSTATUS, CAS, CPROJET, CLABEL ),FROTACOR( CSTATUS ),"",2,CLR_GRAY} )
	ENDIF

	IF EMPTY( AGANTT )                          
		//-- ADICIONA UM ELEMENTO EM BRANCO, SOMENTE PARA EXIBIR O GANTT SEM NENHUMA TAREFA.
		AADD( AGANTT,	{ { "", "", "" },;
						{ {CTOD(""),CTOD(""),"","","",CTOD(""),CTOD(""),"","",CLR_WHITE,"",2,CLR_GRAY, "",CTOD(""),CTOD(""),"","",CLR_WHITE,"",CTOD(""),CTOD(""),"","",CLR_WHITE,CTOD(""),CTOD(""),"","",CLR_WHITE } },, OBOLD } )
	ENDIF
	DBSKIP()
ENDDO

RETURN NIL


// ======================================================================= \\
STATIC FUNCTION FROTAT( CFILORI, CVIAGEM, OBOLD )
// ======================================================================= \\

LOCAL AAREA      := GETAREA()
LOCAL CQUERY     := ""
LOCAL CSTATUS    := "" 
LOCAL NSEEK      := 0 
LOCAL _DATA      := CTOD("")
LOCAL DDATINI    := CTOD("")
LOCAL DDATFIM    := CTOD("")
LOCAL CDESCR     := ""
LOCAL _I
LOCAL CALIASQRY  := GETNEXTALIAS()

CQUERY := " SELECT T9_CODBEM,T9_NOME,T9_MODELO,T9_CODFA,T9_CODFAMI, ISNULL(FPM_DTPROG, '"+DTOS(MV_PAR03)+"') FPM_DTPROG, ISNULL(FPM_STATUS, '1') FPM_STATUS, FPM_AS, FPM_PROJET, FPM_AS, FPM_PROJET, FPM_LOCALI " 
CQUERY += " FROM "+ RETSQLNAME("ST9") + " ST9 
CQUERY += " LEFT JOIN "+ RETSQLNAME("FPM") + " ZLE ON FPM_FILIAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
CQUERY += " AND T9_CODBEM = FPM_FROTA "
CQUERY += " AND FPM_DTPROG BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
CQUERY += " AND ZLE.D_E_L_E_T_ = '' "
CQUERY += " WHERE T9_FILIAL = '"+XFILIAL("ST9")+"'"
CQUERY += " AND T9_CODBEM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'"
CQUERY += " AND (ST9.T9_TIPOSE = 'T' OR ST9.T9_TIPOSE = 'I' OR ST9.T9_TIPOSE = 'O') "
IF !EMPTY(MV_PAR01)
	CQUERY += " AND ST9.T9_CODFAMI  =  '"+MV_PAR01+"'
ENDIF
/*
IF CFILANT <> "01"
	CQUERY += " AND SUBSTRING(T9_CENTRAB,1,2)  =  '"+CFILANT+"'
ENDIF 
*/
CQUERY += " AND ST9.D_E_L_E_T_ = ' '"
CQUERY += " ORDER BY T9_CODBEM, FPM_DTPROG "

//MEMOWRITE("C:\LOCGANT_TRANSP.SQL", CQUERY)
DBUSEAREA( .T., 'TOPCONN', TCGENQRY(,, CQUERY), CALIASQRY, .T., .T. )

TCSETFIELD(CALIASQRY,"FPM_DTPROG","D",8,0)

WHILE (CALIASQRY)->( !EOF() )

	CCODIGO    := ( CALIASQRY )->T9_CODBEM

	WHILE (CALIASQRY)->( !EOF() ) .AND. CCODIGO == (CALIASQRY)->T9_CODBEM

		CDESCR     := ( CALIASQRY )->T9_NOME
		CHISTO	   := IIF(( CALIASQRY )->FPM_STATUS=="0", STR0068,; //"INDISPON"
					  IIF(( CALIASQRY )->FPM_STATUS=="1", STR0053,; //"DISPONIV"
					  IIF(( CALIASQRY )->FPM_STATUS=="2", STR0054,; //"MOBILIZA"
					  IIF(( CALIASQRY )->FPM_STATUS=="3", STR0055,; //"TRABALHA"
					  IIF(( CALIASQRY )->FPM_STATUS=="4", STR0056,; //"CARREGAN"
					  IIF(( CALIASQRY )->FPM_STATUS=="5", STR0057,; //"DESCARRE"
					  IIF(( CALIASQRY )->FPM_STATUS=="6", STR0018,; //"PARADO"
					  IIF(( CALIASQRY )->FPM_STATUS=="7", STR0058,; //"DESMOBIL"
					  IIF(( CALIASQRY )->FPM_STATUS=="8", STR0020,; //"ESTADIAS"
					  IIF(( CALIASQRY )->FPM_STATUS=="9", STR0059,"")))))))))) //"MANUTENC"
		_DATA	   := ( CALIASQRY )->FPM_DTPROG
	   	DDATINI	   := _DATA
	   	DDATFIM    := _DATA 
	   	CSTATUS    := ( CALIASQRY )->FPM_STATUS
	   	CAS        := ( CALIASQRY )->FPM_AS
	   	CPROJET    := ( CALIASQRY )->FPM_PROJET
	   	DDATULT    := _DATA 
	   	CLABEL     := ( CALIASQRY )->FPM_LOCALI

		NSEEK  := ASCAN( AGANTT, {  | ATAR|  ATAR[1,1] == CCODIGO } )

	    IF NSEEK  == 0
	   		XSTATUS := 1                          
		   	AADD( AGANTT,	{ {CCODIGO, CDESCR, CCODIGO, DDATULT },;
							{ {DDATINI,"00:00",DDATFIM,"24:00",FROTATXT( CSTATUS, CAS, CPROJET, CLABEL ),FROTACOR( CSTATUS ),"",2,CLR_GRAY} },,OBOLD})
			NSEEK := LEN( AGANTT )
		ELSE
		   	AADD( AGANTT[NSEEK, 2],	{DDATINI,"00:00",DDATFIM,"24:00",FROTATXT( CSTATUS, CAS, CPROJET, CLABEL ),FROTACOR( CSTATUS ),"",2,CLR_GRAY} )
		ENDIF

		(CALIASQRY)->(DBSKIP())
	ENDDO

	IF ! (CALIASQRY)->( EOF() ) .AND. _DATA < MV_PAR04	// GERAR REGISTROS DISPON�VEL
		FOR _I := _DATA TO MV_PAR04
			AADD( AGANTT[NSEEK, 2],	{ _I, "00:00", _I, "24:00", FROTATXT( CSTATUS, CAS, CPROJET, CLABEL ),FROTACOR( CSTATUS ),"",2,CLR_GRAY} )
		NEXT
	ENDIF

ENDDO

IF EMPTY( AGANTT )
	//-- ADICIONA UM ELEMENTO EM BRANCO, SOMENTE PARA EXIBIR O GANTT SEM NENHUMA TAREFA.
	AADD( AGANTT,	{ { "", "", "" },;
					{ {CTOD(""),CTOD(""),"","","",CTOD(""),CTOD(""),"","",CLR_WHITE,"",2,CLR_GRAY, "",CTOD(""),CTOD(""),"","",CLR_WHITE,"",CTOD(""),CTOD(""),"","",CLR_WHITE,CTOD(""),CTOD(""),"","",CLR_WHITE } },, OBOLD } )
ENDIF

(CALIASQRY)->( DBCLOSEAREA() )
RESTAREA( AAREA )

RETURN NIL
