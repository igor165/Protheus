#INCLUDE "loca059.ch" 
#INCLUDE "TOTVS.CH" 
#INCLUDE "TOPCONN.CH" 
#INCLUDE "AP5MAIL.CH" 
#INCLUDE "TBICONN.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 

/*/{PROTHEUS.DOC} LOCA059.PRW
ITUP BUSINESS - TOTVS RENTAL
APONTADOR AS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

FUNCTION LOCA059()
LOCAL   CEXPFILTRO 
LOCAL   _LTEMVINC := SUPERGETMV("MV_LOCX029",.F.,.T.)
LOCAL   _LC111COR := EXISTBLOCK("LC111COR")
LOCAL   _LC059FIL := EXISTBLOCK("LC059FIL")
LOCAL   _LC111ROT := EXISTBLOCK("LC111ROT")
Local	aScFunc	  := {}
Local   lLOCA59Q  := EXISTBLOCK("LOCA59Q")
Local 	lForca    := .F.

PRIVATE LVERZBX
PRIVATE AROTINA   := {}
PRIVATE CCADASTRO := STR0001 //"Apontador AS"
PRIVATE CPERG     := "LOCP010"
PRIVATE CSERV	  := ""
PRIVATE ACORES
PRIVATE LMINUTA	  := SUPERGETMV("MV_LOCX097",.F.,.T.) //SUPERGETMV("MV_LOCX052",.F.,.T.) trocado a pedido do Lui em 19/08/21 Frank.
PRIVATE LROMANEIO := SUPERGETMV("MV_LOCX071",.F.,.T.)
PRIVATE LFUNCAS   := SUPERGETMV("MV_LOCX237" ,.F.,.F.)
PRIVATE LFILTFIL  := SUPERGETMV("MV_LOCX236",.F.,.T.)

PUBLIC  DDT1      := CTOD("")
PUBLIC  DDT2      := CTOD("")
PUBLIC  CTP1      := ""
PUBLIC  CFIL1     := ""
PUBLIC  CFIL2     := "" 

// U_AJREMOCAO()										// --> CRIA PARÂMETROS, TABELAS, CONSULTAS E ETC - DESCONTINUADO, POIS ESTÁ NO WIZARD DE INSTALAÇÃO.

LVERZBX := GETMV("MV_LOCX097",,.f.) 							// --> HABILITA CONTROLE DE MINUTA

VALIDPERG()

// FRANK 23/09/2020 - SE FOREM CRIADAS NOVAS PERGUNTAS PRECISAM SER TRATADAS NO FILTRO DO ACEITE EM LOTE
IF ! PERGUNTE(CPERG,.T.)
	RETURN NIL
ENDIF 

If MV_PAR03 == 1
	MV_PAR03 := "L"
Else
	MV_PAR03 := "F"
EndIf

DDT1  := MV_PAR01
DDT2  := MV_PAR02
CTP1  := MV_PAR03
CFIL1 := MV_PAR04
CFIL2 := MV_PAR05

CSERV := IIF( CTP1 $ "TELF" , CTP1 , " " )						  							// INCLUSO O TIPO "F" PARA ASF. 

AADD(AROTINA     , {STR0002       , "AXPESQUI"                , 0 , 01} )				// PESQUISAR //"Pesquisar"
AADD(AROTINA     , {STR0003      , "LOCA05902()"               , 0 , 02} ) 				// IMPRESSÃO DA  AS //"Imprime AS"
IF LFUNCAS
	AADD(AROTINA , {STR0004        , "LOCA05903()"               , 0 , 03} )				// FECHA         AS //"Fecha AS"
	AADD(AROTINA , {STR0005      , "LOCA05904()"               , 0 , 04} )				// ENCERRA       AS //"Encerra AS"
	AADD(AROTINA , {STR0006       , "LOCA05905()"               , 0 , 05} )				// REABERTURA DA AS //"Reabre AS"
	AADD(AROTINA , {STR0007    , "LOCA05906(.F.)"            , 0 , 08} ) //"Eestornar AS"
	AADD(AROTINA , {STR0008      , "LOCA05907()"               , 0 , 06} )				// REJEITA AS DO DIA //"Rejeita AS"
ENDIF 
AADD(AROTINA     , {STR0009      , "LOCA05908()"               , 0 , 07} )				// ACEITA  AS SELECIONADA  //"Aceitar AS"
IF CSERV == "F" 
	AADD(AROTINA , {STR0010 , "LOCA05913()"           , 0 , LEN(AROTINA)+1} )	// DIÁLOGO QUE PREENCHE ALGUNS CAMPOS  //"Programação ASF"
ENDIF 
AADD(AROTINA     , {STR0011            , "LOCA05916()"            , 0 , 09} )				// TRATAMENTO AS POR LOTE  //"Lote"
AADD(AROTINA     , {STR0012         , "LOCA05901"                , 0 , 10} )				// LEGENDA  //"Legenda"

If lLOCA59Q	
	lForca := EXECBLOCK("LOCA59Q",.T.,.T.,{})
EndIf
//Gerar SC 
If CSERV == "L"  .And. FQ5->(FIELDPOS("FQ5_NSC")) > 0 .or. lForca 		 	// verifica se o campo existe
	AADD(aScFunc     , {"Geração"				, "LOCA05928"  , 0 , 6}) //"Geração"
	AADD(aScFunc     , {"Exclusão"              , "LOCA05930"  , 0 , 6}) //"Geração"
	AADD(AROTINA     , {"Solicitação de Compras", aScFunc      , 0 , 09} )				// "Solicitação de Compras"
EndIf
If MV_PAR03 <> "F" // solicitação do Lui feito por Frank em 06/07/21
	AADD(AROTINA     , {STR0013   , "LOCA05919"              , 0 , 10} )				// TROCA EQUIPAMENTO  //"Trocar Equip."
EndIf

IF LROMANEIO 
	AADD(AROTINA , {STR0014        , "LOCA05925(FQ5->FQ5_AS)" , 0 , 07} )				// ROMANEIO		// --> ERA - P.E:  LOC05101(FQ5->FQ5_AS)  //"Romaneio"
	IF _LTEMVINC 
		FQ1->(DBSELECTAREA("FQ1")) 
		FQ1->(DBSETORDER(1)) 
		IF FQ1->(DBSEEK(XFILIAL("FQ1") + RETCODUSR(SUBSTR(CUSUARIO,7,15)) + "VINCOS")) 
			AADD(AROTINA , {STR0015 , "U_FVINCOS(FQ5->FQ5_AS)" , 0 , LEN(AROTINA)+1 } )  //"Vincula OS"
			AADD(AROTINA , {STR0016 , "U_FDESVOS(FQ5->FQ5_AS)" , 0 , LEN(AROTINA)+1 } )  //"Desvinc OS"
		ENDIF 
	ENDIF 
ENDIF 

If !LFUNCAS
	AADD(AROTINA , {STR0017     , "LOCA05906(.F.)"            , 0 , 08} ) //"Estornar AS"
EndIf

ACORES := { {' EMPTY(FQ5->FQ5_DATFEC) .AND.  EMPTY(FQ5->FQ5_DATENC) .AND. FQ5->FQ5_STATUS == "1"', 'BR_VERDE'    },; //  PENDENTE
            {'!FQ5->FQ5_STATUS $ "1/6" '														 , 'BR_VERMELHO' },; //  REJEITADO
            {'FQ5->FQ5_STATUS == "6"'															 , 'BR_LARANJA'  } } //  ACEITA

			// Legendas removida por Frank em 06/07/21 a pedido do Lui
			//{'!EMPTY(FQ5->FQ5_DATFEC) .AND.  EMPTY(FQ5->FQ5_DATENC) .AND. FQ5->FQ5_STATUS == "1"', 'BR_AMARELO'  },; //  FECHADA
            //{'!EMPTY(FQ5->FQ5_DATFEC) .AND. !EMPTY(FQ5->FQ5_DATENC) .AND. FQ5->FQ5_STATUS == "1"', 'BR_AZUL'     },; //  ENCERRADO

IF _LC111COR 												// --> PONTO DE ENTRADA PARA ALTERAÇÃO/INCLUSÃO DE CORES NO BROWSER.
	ACORES := EXECBLOCK("LC111COR",.T.,.T.,{ACORES})
ENDIF 

DBSELECTAREA("FQ5")

CEXPFILTRO         := "     FQ5_DATINI >= '" + DTOS(DDT1) + "'" 
CEXPFILTRO         += " AND FQ5_DATFIM <= '" + DTOS(DDT2) + "'" 
CEXPFILTRO         += " AND FQ5_TPAS    = '" + CSERV      + "'" 

CEXPFILTRO         += " AND FQ5_FILIAL  = '" + xFilial("FQ5") + "'" 

/*
IF LFILTFIL
	CEXPFILTRO     += " AND FQ5_FILORI  = '" + CFILANT    + "'" 
ELSE
	IF !EMPTY(CFIL1) 
		CEXPFILTRO += " AND FQ5_FILORI >= '" + CFIL1      + "'" 
	ELSE
		CEXPFILTRO += " AND FQ5_FILORI >= '' "   
	ENDIF 
	IF !EMPTY(CFIL2) 
		CEXPFILTRO += " AND FQ5_FILORI <= '" + CFIL2      + "'" 
	ELSE
		CEXPFILTRO += " AND FQ5_FILORI <= 'ZZ' " 
	ENDIF 
ENDIF 
*/
// CEXPFILTRO         += " AND FQ5_STATUS <> '9' " Removido por Frank a pedido do Lui em 06/07/21

// Ponto de entrada para filtrar o browse
// Frank Zwarg Fuga - 16/06/2021
IF _LC059FIL //EXISTBLOCK("LC059FIL")
	CEXPFILTRO += EXECBLOCK("LC059FIL" , .T. , .T. , {CEXPFILTRO}) 
ENDIF
	
IF _LC111ROT //EXISTBLOCK("LC111ROT") 												// --> PONTO DE ENTRADA PARA INCLUSÃO DE BOTÕES NO AÇÕES RELACIONADAS
	AROTINA := EXECBLOCK("LC111ROT",.T.,.T.,{AROTINA})
ENDIF 

MBROWSE(6 , 1 , 22 , 75 , "FQ5" , , , , , 1 , ACORES , , , , , , , , CEXPFILTRO) 

RETURN NIL



// ======================================================================= \\
FUNCTION LOCA05901() 
// ======================================================================= \\
// --> LEGENDA

LOCAL ALEGENDA
LOCAL _LC111LEG := EXISTBLOCK("LC111LEG")

ALEGENDA := { {"BR_VERDE"    , STR0018},; //"Em aberto"
			  {"BR_VERMELHO" , STR0019},; //"Rejeitada"
			  {"BR_LARANJA"  , STR0020} } //"AS aceita"

			  //{"BR_AMARELO"  , "Fechado"  },; legendas removida por Frank a pedido do Lui 06/07/21
			  //{"BR_AZUL"     , "Encerrado"},; legendas removida por Frank a pedido do Lui 06/07/21


IF _LC111LEG //EXISTBLOCK("LC111LEG") 												// --> PONTO DE ENTRADA PARA ALTERAÇÃO/INCLUSÃO DE LEGENDA.
	ALEGENDA := EXECBLOCK("LC111LEG",.T.,.T.,{ALEGENDA})
ENDIF 

BRWLEGENDA(CCADASTRO , STR0012 , ALEGENDA)  //"Legenda"

RETURN .T.



// ======================================================================= \\
FUNCTION LOCA05902() 
// ======================================================================= \\
// --> IMPRESSÃO DAS AS 

LOCAL CFILOLD := CFILANT
    
CFILANT := FQ5->FQ5_FILORI

FP0->(DBSETORDER(1))
FP0->(DBSEEK(FQ5->FQ5_FILORI + FQ5->FQ5_SOT))

DO CASE
CASE FP0->FP0_TIPOSE == "E"								// --> AS DE EQUIPAMENTO
	LOCR011( FQ5->FQ5_AS )
CASE FP0->FP0_TIPOSE == "T"								// --> AS DE TRANSPORTE (AST)
	LOCR012( FQ5->FQ5_AS )
CASE FP0->FP0_TIPOSE == "L"								// --> AS DE PLATAFORMA (ASP)
	LOCR015( FQ5->FQ5_AS )
OTHERWISE
	MSGSTOP(STR0021+FP0->FP0_TIPOSE+")" , STR0022)  //"Não existe AS definida para esse tipo de serviço. ("###"Atenção!"
ENDCASE

CFILANT := CFILOLD

RETURN .T.



// ======================================================================= \\
FUNCTION LOCA05903() 
// ======================================================================= \\
// --> FECHA AS

LOCAL CFILOLD := CFILANT

CFILANT := FQ5->FQ5_FILORI

IF FQ5->FQ5_STATUS == "6"
	Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   	Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 	{STR0025}) //"AS aceita, operação cancelada."
ELSEIF ! EMPTY(FQ5->FQ5_DATFEC) 
	Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   	Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 	{STR0026}) //"AS já se encontra fechada."
ELSEIF ! EMPTY(FQ5->FQ5_DATENC) 
	Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   	Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 	{STR0027}) //"AS já se encontra encerrada."
ELSEIF MSGYESNO(STR0028 + DTOC(DDATABASE) + ") ?" , STR0022)  //"CONFIRMA O FECHAMENTO DA AS NA DATA DE HOJE ("###"Atenção!"
	RECLOCK("FQ5",.F.) 
	FQ5->FQ5_DATFEC := DDATABASE 
	FQ5->FQ5_HORFEC := TIME() 
	FQ5->(MSUNLOCK()) 
ENDIF 

CFILANT := CFILOLD

RETURN NIL



// ======================================================================= \\
FUNCTION LOCA05904() 			
// ======================================================================= \\
// --> ENCERRA AS

LOCAL CFILOLD := CFILANT

CFILANT := FQ5->FQ5_FILORI

IF FQ5->FQ5_STATUS == "6" 
	Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   	Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 	{STR0025}) //"AS aceita, operação cancelada."
ELSEIF ! EMPTY(FQ5->FQ5_DATENC) 
	Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   	Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 	{STR0027}) //"AS já se encontra encerrada."
ELSEIF   EMPTY(FQ5->FQ5_DATFEC) 
	Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   	Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 	{STR0029}) //"AS precisa ser fechada antes de ser encerrada."
ELSEIF MSGYESNO(STR0030 + DTOC(DDATABASE) + ") ?" , STR0022)  //"Confirma o encerramento da AS na data de hoje ("###"Atenção!"
	RECLOCK("FQ5",.F.) 
	FQ5->FQ5_DATENC := DDATABASE 
	FQ5->FQ5_HORENC := TIME() 
	FQ5->(MSUNLOCK()) 
ENDIF 

CFILANT := CFILOLD

RETURN NIL



// ======================================================================= \\
FUNCTION LOCA05905() 
// ======================================================================= \\
// --> REABRE AS - SE A AS ENCONTRA-SE ENCERRADA

LOCAL CFILOLD := CFILANT

CFILANT := FQ5->FQ5_FILORI

DO CASE
CASE  FQ5->FQ5_STATUS == "6"
	Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   	Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 	{STR0025}) //"AS aceita, operação cancelada."
CASE ! EMPTY(FQ5->FQ5_DATENC)							// --> SE A AS ENCONTRA-SE ENCERRADA
	IF MSGYESNO(STR0031 , STR0022) //"Confirma o estorno do encerramento da AS ?"###"Atenção!"
		RECLOCK("FQ5",.F.)
		FQ5->FQ5_DATENC := CTOD("//")
		FQ5->FQ5_HORENC := SPACE(LEN(FQ5->FQ5_HORENC))
		FQ5->(MSUNLOCK())
	ENDIF
CASE ! EMPTY(FQ5->FQ5_DATFEC)
	IF MSGYESNO("Confirma o estorno do fechamento da AS?" , "Atenção!")
		RECLOCK("FQ5",.F.)
		FQ5->FQ5_DATFEC := CTOD("//")
		FQ5->FQ5_HORFEC := SPACE(LEN(FQ5->FQ5_HORENC))
		FQ5->(MSUNLOCK()) 
	ENDIF
OTHERWISE
	Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   	Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 	{STR0032}) //"AS encontra-se aberta."
ENDCASE

CFILANT := CFILOLD

RETURN NIL



// ======================================================================= \\
FUNCTION LOCA05906(LRET) 
// ======================================================================= \\
// --> ESTORNA AS

LOCAL _AAREAOLD := GETAREA()
LOCAL _AAREAZA0 := FP0->(GETAREA())
LOCAL _AAREAZAG := FPA->(GETAREA())
LOCAL _AAREAZBX := FPF->(GETAREA())
LOCAL _AAREAZLG := FPO->(GETAREA())
LOCAL CRET      := ""
LOCAL CFILOLD   := CFILANT

CFILANT := FQ5->FQ5_FILORI

IF FQ5->FQ5_STATUS == "6"
	FP0->(DBSETORDER(1)) 
	FP0->(DBSEEK(FQ5->FQ5_FILORI + FQ5->FQ5_SOT))

	DO CASE
	CASE FP0->FP0_TIPOSE == "L"
		FPA->(DBSETORDER(3))
		IF FPA->(MSSEEK( XFILIAL("FPA") + FQ5->FQ5_AS )) //"FPA"
			IF ! EMPTY(FPA->FPA_NFREM)
				CRET := STR0034+ ALLTRIM(FQ5->FQ5_AS)+STR0035 //"Não será possível estonar o aceite da(S) AS(S): "###" Já existe NF de remessa atrelada a este(S) item(S)."
			ENDIF
		ENDIF
	CASE FP0->FP0_TIPOSE == "E"
		_CQUERY := " SELECT TOP 1 DIVERGENCIA "                       + CRLF
		_CQUERY += " FROM (SELECT TOP 1 1 DIVERGENCIA "               + CRLF
		_CQUERY += "       FROM " + RETSQLNAME("SC6") + " SC6 "       + CRLF
		_CQUERY += "              INNER JOIN " + RETSQLNAME("SC5") + " SC5 ON SC5.C5_FILIAL  = C6_FILIAL AND SC5.C5_NUM     = C6_NUM " + CRLF
		_CQUERY += " 		                                              AND SC5.C5_XTIPFAT = 'R'       AND SC5.D_E_L_E_T_ = '' "     + CRLF
		_CQUERY += " 	   WHERE  SC6.C6_XAS = '" + FQ5->FQ5_AS + "'" + CRLF
		_CQUERY += " 	     AND  SC6.C6_BLQ NOT IN ('R','S')"        + CRLF
		_CQUERY += " 	     AND  SC6.D_E_L_E_T_ = ''"                + CRLF
		_CQUERY += " 	UNION ALL "                                   + CRLF
		_CQUERY += " 	   SELECT TOP 1 2 DIVERGENCIA "               + CRLF
		_CQUERY += " 	   FROM " + RETSQLNAME("FPF") + " ZBX"        + CRLF
		_CQUERY += " 	   WHERE  ZBX.FPF_AS = '" + FQ5->FQ5_AS + "'" + CRLF
		_CQUERY += " 	     AND  ZBX.FPF_STATUS NOT IN ('1','5')"    + CRLF
		_CQUERY += " 	     AND  ZBX.D_E_L_E_T_ = ''"                + CRLF
		_CQUERY += " 	UNION ALL "                                   + CRLF
		_CQUERY += " 	   SELECT TOP 1 3 DIVERGENCIA "               + CRLF
		_CQUERY += " 	   FROM " + RETSQLNAME("FPQ") + " ZLO"        + CRLF
		_CQUERY += " 	   WHERE  ZLO.FPQ_AS = '" + FQ5->FQ5_AS + "'" + CRLF
		_CQUERY += " 	     AND  ZLO.FPQ_AGENDA = '2'"               + CRLF
		_CQUERY += " 	     AND  ZLO.D_E_L_E_T_ = ''"                + CRLF
		_CQUERY += " 	UNION ALL "                                   + CRLF
		_CQUERY += " 	   SELECT TOP 1 4 DIVERGENCIA "               + CRLF
		_CQUERY += " 	   FROM " + RETSQLNAME("FPN") + " ZLF"        + CRLF
		_CQUERY += " 	   WHERE  ZLF.FPN_AS = '" + FQ5->FQ5_AS + "'" + CRLF
		_CQUERY += " 	     AND  ZLF.FPN_NUMPV <> ''"                + CRLF
		_CQUERY += " 	     AND  ZLF.D_E_L_E_T_ = '' ) AS TMP "
		IF SELECT("TRBDIV") > 0 
			TRBDIV->(DBCLOSEAREA()) 
		ENDIF 
		TCQUERY _CQUERY NEW ALIAS "TRBDIV" 
		
		IF TRBDIV->(!EOF())
			DO CASE
			CASE TRBDIV->DIVERGENCIA == 1
				CRET := STR0036+ ALLTRIM(FQ5->FQ5_AS)+STR0035 //"Não será possível estornar o aceite da(S) AS(S): "###" Já existe NF de remessa atrelada a este(s) item(s)."
			CASE TRBDIV->DIVERGENCIA == 2
				CRET := STR0036+ ALLTRIM(FQ5->FQ5_AS)+STR0037 //"Não será possível estornar o aceite da(S) AS(S): "###" Já existe(m) minuta(s) atrelada(s) a este(s) item(s)."
			CASE TRBDIV->DIVERGENCIA == 3
				CRET := STR0036+ ALLTRIM(FQ5->FQ5_AS)+STR0038 //"Não será possível estornar o aceite da(S) AS(S): "###" Já existe(M) mão(s) de obra atrelada(s) a este(s) item(s)."
			CASE TRBDIV->DIVERGENCIA == 4
				CRET := STR0036+ ALLTRIM(FQ5->FQ5_AS)+STR0039 //"Não será possível estornar o aceite da(S) AS(S): "###" Já existe(M) medição(ões) atreladas(s) a este(s) item(s)."
			ENDCASE
		ENDIF
		
		TRBDIV->(DBCLOSEAREA())
	ENDCASE
	
	IF EMPTY(CRET)	
		FPF->(DBSETORDER(4))							// FPF_FILIAL + FPF_AS + FPF_MINUTA
		IF FPF->( MSSEEK( XFILIAL("FPF") + FQ5->FQ5_AS ) )
			WHILE FPF->(!EOF()) .AND. FPF->(FPF_FILIAL + FPF_AS) == (XFILIAL("FPF") + FQ5->FQ5_AS)
				IF FPF->FPF_STATUS $ "1#5"				// PREVISTA / CANCELADA
					IF FPF->(RECLOCK("FPF",.F.))
						FPF->(DBDELETE())
						FPF->(MSUNLOCK())
					ENDIF
				ENDIF
				FPF->(DBSKIP())
			ENDDO
		ENDIF
		
		_CQUERY := " SELECT   ZLO.R_E_C_N_O_ ZLORECNO"                + CRLF
		_CQUERY += " FROM " + RETSQLNAME("FPQ") + " ZLO"              + CRLF
		_CQUERY += " WHERE    FPQ_AS         = '" + FQ5->FQ5_AS + "'" + CRLF
		_CQUERY += "   AND    FPQ_AGENDA     = '1'"                   + CRLF
		_CQUERY += "   AND    ZLO.D_E_L_E_T_ = ''"                    + CRLF
		_CQUERY += " ORDER BY FPQ_AS , FPQ_DATA DESC"
		IF SELECT("TRBFPQ") > 0
			TRBFPQ->(DBCLOSEAREA())
		ENDIF
		TCQUERY _CQUERY NEW ALIAS "TRBFPQ"
		
		WHILE TRBFPQ->(!EOF())
			DBSELECTAREA("FPQ")
			FPQ->(DBGOTO(TRBFPQ->FPQRECNO))
			IF FPQ->(RECLOCK("FPQ",.F.))
				FPQ->(DBDELETE())
				FPQ->(MSUNLOCK())
			ENDIF
			TRBFPQ->(DBSKIP())
		ENDDO
		
		TRBFPQ->(DBCLOSEAREA())
		
		FPO->(DBSETORDER(4))					// FPO_FILIAL + FPO_PROJET + FPO_OBRA + FPO_NRAS + FPO_VIAGEM
		IF FPO->( MSSEEK(XFILIAL("FPO") + FQ5->FQ5_SOT + FQ5->FQ5_OBRA + FQ5->FQ5_AS + FQ5->FQ5_VIAGEM) )
			WHILE FPO->(!EOF()) .AND. FPO->(FPO_FILIAL + FPO_PROJET + FPO_OBRA + FPO_NRAS + FPO_VIAGEM) == (XFILIAL("FPO") + FQ5->FQ5_SOT + FQ5->FQ5_OBRA + FQ5->FQ5_AS + FQ5->FQ5_VIAGEM)
				IF FPO->FPO_STATUS == "R"		// RESERVADA
					IF FPO->(RECLOCK("FPO",.F.))
						FPO->(DBDELETE())
						FPO->(MSUNLOCK())
					ENDIF
				ENDIF
				FPO->(DBSKIP())
			ENDDO
		ENDIF
		
		IF RECLOCK("FQ5",.F.)
			FQ5->FQ5_STATUS := "1"
			FQ5->FQ5_ACEITE := CTOD("")
			FQ5->(MSUNLOCK())
		ENDIF	
	ENDIF
ENDIF

CFILANT := CFILOLD

FPO->(RESTAREA( _AAREAZLG ))
FPF->(RESTAREA( _AAREAZBX ))
FPA->(RESTAREA( _AAREAZAG ))
FP0->(RESTAREA( _AAREAZA0 ))
RESTAREA( _AAREAOLD )

RETURN IIF( LRET , CRET , "" ) 




// ======================================================================= \\
FUNCTION LOCA05907(XMSG) 
// ======================================================================= \\
// --> REJEITA AS

LOCAL LOK      := .F. 
LOCAL CCC      := ""
LOCAL CCCO     := ""
LOCAL CMSG     := ""
LOCAL CPARA	   := "" 
LOCAL CTITULO  := ""
LOCAL _CTIPOAS := "AS "
LOCAL OMSG
LOCAL EFROM    := ALLTRIM(USRRETNAME(RETCODUSR())) + " <" + ALLTRIM(USRRETMAIL(RETCODUSR())) + ">" 
LOCAL ABUTTONS := {}
LOCAL CBODY    := ""
LOCAL _LREJ    := .T.
LOCAL CFILOLD  := CFILANT
Local _LC111VRJ := EXISTBLOCK("LC111VRJ")
Local _LC111REJ := EXISTBLOCK("LC111REJ")

PRIVATE _ODLGMAIL
Private _MV_LOC248 := SUPERGETMV("MV_LOCX248",.F.,STR0044)

CFILANT := FQ5->FQ5_FILORI

IF _LC111VRJ //EXISTBLOCK("LC111VRJ") 												// --> PONTO DE ENTRADA PARA ALTERAÇÃO/INCLUSÃO DE CONDIÇÕES DA QUERY PARA GERAÇÃO DA NOTA FISCAL DE REMESSA. 
	_LREJ := EXECBLOCK("LC111VRJ",.T.,.T.,NIL)
	IF !_LREJ
	    CFILANT := CFILOLD
		RETURN NIL
	ENDIF
ELSE
	IF FQ5->FQ5_STATUS == "6" 	// VALIDAÇÃO PARA NÃO PERMITIR QUE A AS SEJA REJEITADA DEPOIS DO ACEITE.
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   	Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 	{STR0040}) //"AS encontra-se aceita e não poderá ser rejeitada."
		CFILANT := CFILOLD
		RETURN NIL
	ENDIF
	IF FQ5->FQ5_STATUS == "9" 	// VALIDAÇÃO PARA NÃO PERMITIR QUE A AS SEJA REJEITADA DEPOIS DO ACEITE.
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   	Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 	{STR0041}) //"AS já encontra-se rejeitada."
		CFILANT := CFILOLD
		RETURN NIL
	ENDIF
ENDIF

FP0->( DBSETORDER(1)) 
FP0->( DBSEEK(FQ5->FQ5_FILORI + FQ5->FQ5_SOT) )

CMSG  := FQ5->FQ5_OBSCOM + CRLF 

DO CASE
CASE FP0->FP0_TIPOSE == "E"
	CPARA := GETMV("MV_LOCX176",,"")
CASE FP0->FP0_TIPOSE == "T"
	CPARA := GETMV("MV_LOCX180",,"")
ENDCASE

CTITULO	:= STR0042 + _CTIPOAS + STR0043 + ALLTRIM(FQ5->FQ5_AS) + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + STR0045 + FP0->FP0_REVISA + SPACE(100) //"Referente a rejeição da "###" número "###"PROJETO"###", revisão "
//							DATA INÍCIO/FIM , LOCAL DA OBRA, CIDADE, ESTADO, NOME DO CLIENTE
CBODY   := STR0046+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0047+ALLTRIM(FQ5->FQ5_DESTIN)+STR0048+ALLTRIM(FQ5->FQ5_NOMCLI) //"Data INI/FIM: "###",  obra: "###",  cliente: "

IF EMPTY(XMSG)
	DEFINE MSDIALOG _ODLGMAIL TITLE STR0049   FROM C(230),C(359) TO C(400),C(882) PIXEL		// DE 610 PARA 400 //"Motivo da rejeição"
		@ C(014),C(011) SAY STR0050   			SIZE C(030),C(008) COLOR CLR_BLACK PIXEL OF _ODLGMAIL //"Motivo:"
		@ C(015),C(042) GET OMSG VAR CMSG MEMO 		SIZE C(210),C(065) 				   PIXEL OF _ODLGMAIL
	ACTIVATE MSDIALOG _ODLGMAIL CENTERED ON INIT ENCHOICEBAR(_ODLGMAIL, {||LOK:=.T., _ODLGMAIL:END()},{||_ODLGMAIL:END()},,ABUTTONS)
ELSE
	CMSG := XMSG										// --> VEM MENSAGEM COMO PARÂMETRO DA ROTINA DE REJEIÇÃO POR LOTE 
	LOK  := .T.
ENDIF

IF LOK 
   	IF !EMPTY(ALLTRIM(CPARA)) 
   		LOCA05909( EFROM, CPARA , CCC, CTITULO, CTITULO + CRLF + CBODY + CRLF + STR0051 + CRLF + CMSG, NIL, CCCO)  //"Motivo da rejeição:"
	ENDIF 
	IF RECLOCK("FP0",.F.)
		FP0->FP0_OBS := "==> " + CTITULO + CRLF + CMSG 
		FP0->(MSUNLOCK()) 
	ENDIF 
	IF RECLOCK("FQ5",.F.) 
		FQ5->FQ5_STATUS := "9" 
		FQ5->FQ5_ACEITE := CTOD("") 
		FQ5->FQ5_OBSCOM := "==> " + CTITULO + CRLF + CMSG
		FQ5->(MSUNLOCK()) 
	ENDIF 
	IF _LC111REJ //EXISTBLOCK("LC111REJ") 											// --> PONTO DE ENTRADA EXECUTADO APÓS A REJEIÇÃO DA AS. 
		EXECBLOCK("LC111REJ",.T.,.T.,{FQ5->FQ5_FILIAL, FQ5->FQ5_FILORI, FQ5->FQ5_SOT, FQ5->FQ5_OBRA, FQ5->FQ5_AS})
	ENDIF
ENDIF 

CFILANT := CFILOLD

RETURN NIL



// ======================================================================= \\
FUNCTION LOCA05908(CLOTE , LMSROTAUTO, _lAviso) 
// ======================================================================= \\
// --> ROTINA PARA APROVAÇÃO DE UMA OS 

LOCAL OFONT      := TFONT():NEW("ARIAL",11,,.T.,.T.,5,.T.,5,.T.,.F.)
LOCAL LOK 		 := .F.
LOCAL CCC	 	 := SPACE(100)
LOCAL CCCO	 	 := SPACE(100)
LOCAL CMSG	 	 := ""
LOCAL CPARA	 	 := SPACE(100)
LOCAL CTITULO	 := SPACE(100)
LOCAL EFROM		 := ALLTRIM(USRRETNAME(__CUSERID)) + " <" + ALLTRIM(USRRETMAIL(__CUSERID)) + ">"
LOCAL LCONFLITO  := .F.
LOCAL LCZLG
LOCAL COBRA      := ""
LOCAL LDTENCAV   := .F.
LOCAL AINFOENC   := {}
LOCAL LREVIS     := .F.
LOCAL CTPANT     := ""
LOCAL AAREADTQ 
LOCAL _FQ5_FILIAL 
LOCAL _FQ5_SOT 
LOCAL _FQ5_OBRA 
LOCAL _FQ5_AS 
LOCAL _FQ5_SEQCAR 
LOCAL _FQ5_JUNTO 
LOCAL NI         := 0 
LOCAL NY         := 0 
LOCAL DDT        := 0 
LOCAL CFILOLD    := CFILANT 
LOCAL LGERSC     := .F. 				// SUPERGETMV("MV_LOCX262",,.F.) 		// --> GERA SOLICITAÇÃO DE COMPRA 
LOCAL _LMAIL 
LOCAL LGRVPERZLG 
Local _MV_LOC248 := SUPERGETMV("MV_LOCX248",.F.,STR0044)
Local _LC111AC1 := EXISTBLOCK("LC111AC1")
Local _LC111ANT := EXISTBLOCK("LC111ANT")
Local _LC111ACE := EXISTBLOCK("LC111ACE")
Local CGRPAND	:= SUPERGETMV("MV_LOCX014",.F.,"" ) 
Local _LRET 	:= .T.
Local lLOCA59A  := EXISTBLOCK("LOCA59A")
Local lLOCA59B  := EXISTBLOCK("LOCA59B")
Local lLOCA59C  := EXISTBLOCK("LOCA59C")
Local lLOCA59D  := EXISTBLOCK("LOCA59D")
Local lLOCA59Z  := EXISTBLOCK("LOCA59Z")
Local lForca    := .F.


PRIVATE _ODLG 
PRIVATE LACESS   := .F. 
PRIVATE _ASS     := {} 
PRIVATE LANTACE  := .T. 

DEFAULT LMSROTAUTO := .F.
DEFAULT _lAviso    := .T.

_lMens := _lAviso

IF ! (VALTYPE("LMINUTA")   == "L") 
	LMINUTA   := SUPERGETMV("MV_LOCX097",.F.,.T.) //SUPERGETMV("MV_LOCX052" , .F. , .T.) trocado a pedido do Lui em 19/08/21 Frank
ENDIF 

IF ! (VALTYPE("LROMANEIO") == "L") 
	LROMANEIO := SUPERGETMV("MV_LOCX071" , .F. , .T.) 
ENDIF 

CFILANT    := FQ5->FQ5_FILORI 
_LMAIL     := SUPERGETMV("MV_LOCX018" ,.F.,.T.) 
LGRVPERZLG := SUPERGETMV("MV_LOCX240",.F.,.T.) 

//caso exista o campo BM_XACESS, utiliza ele como referência
IF SBM->(FIELDPOS("BM_XACESS")) > 0
	CGRPAND := LOCA00189()
ENDIF

//valida se existe produto que pode gerar sem Equipamento
If FQ5->FQ5_TPAS == "L" .And. Empty(FQ5->FQ5_GUINDA)
	//Posiciona na FPA
	FPA->(DBSETORDER(3))				// FPA_FILIAL + FPA_AS + FPA_VIAGEM
	If FPA->(DBSEEK( XFILIAL("FPA") + FQ5->FQ5_AS )) .AND. !EMPTY(FQ5->FQ5_AS)
		//Posiciona no produto
		SB1->(DBSETORDER(1))
		If SB1->(DBSEEK(XFILIAL("SB1") + FPA->FPA_PRODUT))
			//verifica se o grupo de produto está liberado
			If FPA->FPA_TIPOSE <> "M" 
				_LRET := ALLTRIM(GETADVFVAL("SB1", "B1_GRUPO",XFILIAL("SB1") + FPA->FPA_PRODUT,1,"")) $ ALLTRIM(CGRPAND)
			EndIf
		EndIf
	EndIf
	//retorno do erro
	If lLOCA59A	
		_LRET := EXECBLOCK("LOCA59A",.T.,.T.,{})
	EndIf
	If !_LRET
		//Ferramenta Migrador de Contratos
		lForca := .F.
		If lLOCA59B	
			lForca := EXECBLOCK("LOCA59B",.T.,.T.,{})
		EndIf
		If (Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C") .or. lForca
			cLocErro := STR0265 + CRLF //"É necessário indicar um Equipamento ou Produto válido para prosseguir com o Aceite de AS."
		Else
			MSGSTOP(STR0265 , STR0022) //"É necessário indicar um Equipamento ou Produto válido para prosseguir com o Aceite de AS."###"Atenção!"	
		EndIf
		//RETIRAR ESSE RETURN (TROCAR POR LCONTINUA)
		RETURN _LRET 
	EndIf
EndIf
DBSELECTAREA("FQ5")


IF _LC111AC1 //EXISTBLOCK("LC111AC1") 												// --> PONTO DE ENTRADA PARA VALIDAR AS LINHAS DA ABA LOCAÇÕES ANTES DE SALVAR.
	_LRET := .T.
	_LRET := EXECBLOCK("LC111AC1",.T.,.T.,{FQ5->FQ5_GUINDA, FQ5->FQ5_AS, FQ5->FQ5_VIAGEM, CLOTE })
	IF !_LRET
		CFILANT := CFILOLD 
		RETURN _LRET 
	ENDIF 
ENDIF 

IF FQ5->FQ5_STATUS != "1" .OR. ! EMPTY(FQ5->FQ5_DATENC)
	If _lMens
		//Ferramenta Migrador de Contratos
		If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
			cLocErro := STR0052+CRLF
		Else
			MSGSTOP(STR0052 , STR0022) //"Somente uma AS aberta pode ser aceita!"###"Atenção!"	
		EndIf
	EndIF
	CFILANT := CFILOLD 
	RETURN .F. 
ENDIF 

FP0->(DBSETORDER(1))
FP0->(DBSEEK(FQ5->FQ5_FILORI + FQ5->FQ5_SOT))

IF LMINUTA
	FPA->(DBSETORDER(3))				// FPA_FILIAL + FPA_AS + FPA_VIAGEM
	IF FPA->(DBSEEK( XFILIAL("FPA") + FQ5->FQ5_AS )) .AND. !EMPTY(FQ5->FQ5_AS) 
		IF FPA->FPA_TIPOSE <> "M" 
			LMINUTA := .F.
		ENDIF
	ENDIF
ENDIF

IF LVERZBX  .AND.  LMINUTA 
	IF FP0->FP0_TIPOSE == "T"
		AAREADTQ    := FQ5->( GETAREA() )
		_FQ5_FILIAL := FQ5->FQ5_FILIAL
		_FQ5_SOT    := FQ5->FQ5_SOT
		_FQ5_OBRA   := FQ5->FQ5_OBRA
		_FQ5_AS     := FQ5->FQ5_AS
		_FQ5_SEQCAR := FQ5->FQ5_SEQCAR
		_FQ5_JUNTO  := FQ5->FQ5_JUNTO
		
		FQ5->( DBSETORDER(8) )	//	FQ5_FILIAL, FQ5_SOT, FQ5_OBRA, FQ5_AS, R_E_C_N_O_, D_E_L_E_T_
		FQ5->( DBSEEK( _FQ5_FILIAL + _FQ5_SOT + _FQ5_OBRA, .T. ) )
		WHILE ! FQ5->( EOF() ) .AND. FQ5->FQ5_FILIAL == _FQ5_FILIAL .AND. FQ5->FQ5_SOT == _FQ5_SOT .AND. FQ5->FQ5_OBRA == _FQ5_OBRA
			IF ASCAN( _ASS, {|X| X[4] == FQ5->( RECNO() ) } ) == 0 .AND. (;
			   _FQ5_SEQCAR == FQ5->FQ5_JUNTO .OR.;
			   ( !EMPTY(_FQ5_JUNTO) .AND. _FQ5_JUNTO == FQ5->FQ5_SEQCAR ) .OR.;
			   ( !EMPTY(_FQ5_JUNTO) .AND. _FQ5_JUNTO == FQ5->FQ5_JUNTO ) .OR.;
			   ASCAN( _ASS, {|X| X[2] == FQ5->FQ5_JUNTO } ) > 0 .OR.;
			   ASCAN( _ASS, {|X| X[3] == FQ5->FQ5_SEQCAR } ) > 0 )
				
				IF FQ5->FQ5_STATUS == "1"
					AADD( _ASS, { FQ5->FQ5_AS, FQ5->FQ5_SEQCAR, FQ5->FQ5_JUNTO, FQ5->( RECNO() ) } )
					FQ5->( DBSEEK( _FQ5_FILIAL + _FQ5_SOT + _FQ5_OBRA, .T. ) )
					LOOP
				ENDIF
			ENDIF
			FQ5->(DBSKIP())
		ENDDO
		
		IF LEN( _ASS ) > 1
			//Ferramenta Migrador de Contratos
			If !(Type("lLocAuto") == "L" .And. lLocAuto)
				IF AVISO(STR0053,STR0054 + _MV_LOC248 + ": "+ALLTRIM(_FQ5_SOT)+STR0055+_FQ5_OBRA+" ?" ,{"SIM","NAO"},2) != 1 //"Aceite de AS de transporte (Carga Junta)"###"Confirma o aceite da AS do "###" - Viagem: "
					FQ5->( RESTAREA( AAREADTQ ) )
					RETURN .F.
				ENDIF
			ENDIF
		ELSEIF LEN( _ASS ) == 0
			FQ5->( RESTAREA( AAREADTQ ) )
			AADD( _ASS, { FQ5->FQ5_AS, FQ5->FQ5_SEQCAR, FQ5->FQ5_JUNTO, FQ5->( RECNO() ) } )
		ENDIF
		
		FOR NI := 1 TO LEN( _ASS )
			FQ5->( DBGOTO( _ASS[NI][4] ) )
			FACEMINUTA(CLOTE) 					// ACEITA MINUTA
		NEXT NI
		
		FQ5->( RESTAREA( AAREADTQ ) )
	ELSE
		FACEMINUTA(CLOTE) 						// ACEITA MINUTA
	ENDIF

	CFILANT := CFILOLD 

	RETURN NIL
ENDIF

CPROJET := FQ5->FQ5_SOT
COBRA   := FQ5->FQ5_OBRA

IF FQ5->FQ5_TPAS == "T"							// VALIDAÇÃO PARA O TIPO = TRANSPORTE
	DBSELECTAREA("FPM")
	DBSETORDER(6)
	IF DBSEEK(XFILIAL("FPM")+FQ5->FQ5_SOT+FQ5->FQ5_OBRA+FQ5->FQ5_VIAGEM)
		LREVIS := .T.
	ENDIF
	
	IF FP0->FP0_TIPOSE == "E" 					// SE O PROJETO FOR DE EQUIPAMENTO
		CTPANT := "G"
		DBSELECTAREA("FP4")
		DBSETORDER(3)
		IF DBSEEK(XFILIAL("FP4")+FQ5->FQ5_AS+FQ5->FQ5_VIAGEM)
			
			DBSELECTAREA("FPM")
			DBSETORDER(5)
			DBSEEK(XFILIAL("FPM")+FP4->FP4_GUINDA)
			
			WHILE !FPM->(EOF()) .AND. ALLTRIM(FPM->FPM_FROTA) == ALLTRIM(FP4->FP4_GUINDA)
				IF ALLTRIM(FPM->FPM_STATUS) == "1"
					FPM->(DBSKIP())
					LOOP
				ENDIF
				
				IF LREVIS						// AS 2º VEZ
					IF ALLTRIM(FPM->FPM_STATUS) == "9" .OR. ALLTRIM(FPM->FPM_STATUS) == "M"
						FPM->(DBSKIP())
						LOOP
					ENDIF
					IF ALLTRIM(FQ5->FQ5_AS+FQ5->FQ5_SOT+FQ5->FQ5_OBRA+FP4->FP4_GUINDA) == ALLTRIM(FPM->FPM_AS+FPM->FPM_PROJET+FPM->FPM_OBRA+FPM->FPM_FROTA)
						FPM->(DBSKIP())
						LOOP
					ENDIF
					IF DTOS(FPM->FPM_DTPROG) >= DTOS(FQ5->FQ5_DATINI) .AND. DTOS(FPM->FPM_DTPROG) <= DTOS(FQ5->FQ5_DATFIM)
						LDTENCAV := .T.
						AADD(AINFOENC,FPM->FPM_FROTA);AADD(AINFOENC,FPM->FPM_DTPROG);AADD(AINFOENC,FPM->FPM_AS);AADD(AINFOENC,FPM->FPM_PROJET);AADD(AINFOENC,POSICIONE("FP0",1,XFILIAL("FP0")+FPM->FPM_PROJET,"FP0_CLINOM"))
						EXIT
					ENDIF
				ELSE
					IF DTOS(FPM->FPM_DTPROG) >= DTOS(FQ5->FQ5_DATINI) .AND. DTOS(FPM->FPM_DTPROG) <= DTOS(FQ5->FQ5_DATFIM)
						LDTENCAV := .T.
						AADD(AINFOENC,FPM->FPM_FROTA);AADD(AINFOENC,FPM->FPM_DTPROG);AADD(AINFOENC,FPM->FPM_AS);AADD(AINFOENC,FPM->FPM_PROJET);AADD(AINFOENC,POSICIONE("FP0",1,XFILIAL("FP0")+FPM->FPM_PROJET,"FP0_CLINOM"))
						EXIT
					ENDIF
				ENDIF
				
				FPM->(DBSKIP())
			ENDDO
		ENDIF
		
	ELSE
		
		IF EMPTY(FQ5->FQ5_JUNTO)
			DBSELECTAREA("FP8")
			DBSETORDER(1) 						// PROJET+OBRA+SEQTRA+SEQCAR
			DBSEEK(XFILIAL("FP8")+FQ5->FQ5_SOT+FQ5->FQ5_OBRA+FQ5->FQ5_OBRA+FQ5->FQ5_SEQCAR)
			
			WHILE !FP8->(EOF()) .AND. ALLTRIM(FP8->FP8_FILIAL+FP8->FP8_PROJET+FP8->FP8_OBRA+FP8->FP8_SEQTRA+FP8->FP8_SEQCAR) == ALLTRIM(XFILIAL("FP8")+FQ5->FQ5_SOT+FQ5->FQ5_OBRA+FQ5->FQ5_OBRA+FQ5->FQ5_SEQCAR)
				DBSELECTAREA("FPM")
				DBSETORDER(5)
				DBSEEK(XFILIAL("FPM")+FP8->FP8_TRANSP)
				
				WHILE !FPM->(EOF()) .AND. ALLTRIM(FPM->FPM_FROTA) == ALLTRIM(FP8->FP8_TRANSP)
					IF ALLTRIM(FPM->FPM_STATUS) == "1"
						FPM->(DBSKIP())
						LOOP
					ENDIF
					IF LREVIS 					// AS 2º VEZ
						IF ALLTRIM(FPM->FPM_STATUS) == "9" .OR. ALLTRIM(FPM->FPM_STATUS) == "M"
							FPM->(DBSKIP())
							LOOP
						ENDIF
						IF ALLTRIM(FQ5->FQ5_AS+FQ5->FQ5_SOT+FQ5->FQ5_OBRA+FP8->FP8_TRANSP) == ALLTRIM(FPM->FPM_AS+FPM->FPM_PROJET+FPM->FPM_OBRA+FPM->FPM_FROTA)
							FPM->(DBSKIP())
							LOOP
						ENDIF
						IF DTOS(FPM->FPM_DTPROG) >= DTOS(FQ5->FQ5_DATINI) .AND. DTOS(FPM->FPM_DTPROG) <= DTOS(FQ5->FQ5_DATFIM)
							LDTENCAV := .T.
							AADD(AINFOENC,FPM->FPM_FROTA);AADD(AINFOENC,FPM->FPM_DTPROG);AADD(AINFOENC,FPM->FPM_AS);AADD(AINFOENC,FPM->FPM_PROJET);AADD(AINFOENC,POSICIONE("FP0",1,XFILIAL("FP0")+FPM->FPM_PROJET,"FP0_CLINOM"))
							EXIT
						ENDIF
					ELSE
						IF DTOS(FPM->FPM_DTPROG) >= DTOS(FQ5->FQ5_DATINI) .AND. DTOS(FPM->FPM_DTPROG) <= DTOS(FQ5->FQ5_DATFIM)
							LDTENCAV := .T.
							AADD(AINFOENC,FPM->FPM_FROTA);AADD(AINFOENC,FPM->FPM_DTPROG);AADD(AINFOENC,FPM->FPM_AS);AADD(AINFOENC,FPM->FPM_PROJET);AADD(AINFOENC,POSICIONE("FP0",1,XFILIAL("FP0")+FPM->FPM_PROJET,"FP0_CLINOM"))
							EXIT
						ENDIF
					ENDIF
					FPM->(DBSKIP())
				ENDDO
				
				FP8->(DBSKIP())
			ENDDO
		ENDIF
		IF !VALIDAS(FQ5->FQ5_SOT , FQ5->FQ5_OBRA , FQ5->FQ5_JUNTO) 
			CFILANT := CFILOLD
			RETURN .F.
		ENDIF
		
	ENDIF
	
	IF LDTENCAV
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   	Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 	{STR0056+ALLTRIM(AINFOENC[1])+STR0057+POSICIONE("ST9",1,XFILIAL("ST9")+ALLTRIM(AINFOENC[1]),"T9_PLACA")+STR0058+CHR(13)+STR0059+SUBSTR(DTOS(AINFOENC[2]),7,2)+"/"+SUBSTR(DTOS(AINFOENC[2]),5,2)+"/"+SUBSTR(DTOS(AINFOENC[2]),1,4)+CHR(13)+_MV_LOC248 + ": "+AINFOENC[4]+CHR(13)+STR0060+AINFOENC[3]+CHR(13)+STR0061+AINFOENC[5]+CHR(13)+""}) //"Não foi possível aceitar a AS, pois a frota:"###" Placa:"###" esta com datas encavaladas na 'Prog. diária Transp'. "###"Data: "###"Projeto"###"AS: "###"Cliente: "
		CFILANT := CFILOLD
		//Ferramenta Migrador de Contratos
		If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
			cLocErro := STR0056+ALLTRIM(AINFOENC[1])+STR0057+POSICIONE("ST9",1,XFILIAL("ST9")+ALLTRIM(AINFOENC[1]),"T9_PLACA")+STR0058+CHR(13)+STR0059+SUBSTR(DTOS(AINFOENC[2]),7,2)+"/"+SUBSTR(DTOS(AINFOENC[2]),5,2)+"/"+SUBSTR(DTOS(AINFOENC[2]),1,4)+CHR(13)+_MV_LOC248 + ": "+AINFOENC[4]+CHR(13)+STR0060+AINFOENC[3]+CHR(13)+STR0061+AINFOENC[5]+CHR(13)+""+CRLF
		EndIf
		RETURN .F.
	ENDIF
	
ENDIF

CMSG  := FP0->FP0_OBS + CHR(13)+CHR(10) 
_CFIL := XFILIAL() 		// RIGHT(ALLTRIM(FQ5->FQ5_AS),2)
CCC   := ""
CPARA := ""

DO CASE
CASE FP0->FP0_TIPOSE == "E"
	_CTIPOAS := "AS"
	CPARA    := GETMV("MV_LOCX032",,"")
CASE FP0->FP0_TIPOSE == "L"
	_CTIPOAS := "ASG"
	CPARA    := GETMV("MV_LOCX178",,"")
CASE FP0->FP0_TIPOSE == "T"
	_CTIPOAS := "AST"
	CPARA    := GETMV("MV_LOCX180",,"")
ENDCASE

IF 	FQ5->FQ5_TPAS == "F"
	_CTIPOAS := "ASF"
	IF FP0->FP0_TIPOSE == "E"
		CPARA := GETMV("MV_LOCX032",,"")
	ELSE
		CPARA := GETMV("MV_LOCX033",,"")
	ENDIF
Else
	_CTIPOAS := "AS "
	IF FP0->FP0_TIPOSE == "E"
		CPARA := GETMV("MV_LOCX032",,"")
	ELSE
		CPARA := GETMV("MV_LOCX033",,"")
	ENDIF
ENDIF

IF FQ5->FQ5_TPAS != "F" .AND. SUPERGETMV("MV_LOCX230",.F.,.T.)	// VERIFICAÇÃO DE CONFLITO DE DATAS DTQ X ZAG 
	CALIAS     := ALIAS()
	ADIASMANUT := {} 											// PARA ARMAZENAR OS DIAS QUE A FROTA ESTÁ EM MANUNTEÇÃO
	AOPCCMB    := MONTACOMBO("FPO_STATUS") 						// CARREGA OS ITENS DO COMBOBOX DA SX3
	
	IF SELECT("TRAB") > 0
		DBSELECTAREA("TRAB")
		TRAB->(DBCLOSEAREA()) 
	ENDIF
	
    // VERIFICA SE FROTA ESTAH LIBERADA
	// STATUS POSSIVEIS NESTA ROTINA 0,2,3,4,5,6,7,8,R 
    CQUERY := " SELECT FPO_NRAS, FPO_NOMCLI, FPO_STATUS, FPO_DTINI, FPO_DTFIM, FPO_HRINI, FPO_HRFIM " 
    CQUERY += " FROM " + RETSQLNAME("FPO") + " ZLG "
    CQUERY += " WHERE   ZLG.D_E_L_E_T_ = '' "
    CQUERY += "     AND ZLG.FPO_FROTA  = '" + FP4->FP4_GUINDA + "' "
    CQUERY += "     AND ZLG.FPO_CODBEM = '' "
    IF !EMPTY(FP4->FP4_AS)
       CQUERY += "  AND ZLG.FPO_NRAS <> '" + FP4->FP4_AS + "' "
    ENDIF
    CQUERY += "     AND ZLG.FPO_STATUS IN ('0','2','3','4','5','6','7','8','R')"
	CQUERY += "     AND (    ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTINI <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI > '" + FP4->FP4_HRINI + "' AND FPO_HRINI < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' ) " + CRLF  
    CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTINI <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRFIM > '" + FP4->FP4_HRINI + "' AND FPO_HRFIM < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' ) " + CRLF
    CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTINI <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI = '" + FP4->FP4_HRINI + "' AND FPO_HRFIM = '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' ) " + CRLF
    CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTINI <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI < '" + FP4->FP4_HRINI + "' AND FPO_HRFIM > '" + FP4->FP4_HRINI + "' ) " + CRLF
    CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTINI <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' AND FPO_HRFIM > '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' ) " + CRLF
    CQUERY += "    " + CRLF 
    CQUERY += "           OR ( ZLG.FPO_DTFIM >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI > '" + FP4->FP4_HRINI + "' AND FPO_HRINI < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' )  " + CRLF
    CQUERY += "           OR ( ZLG.FPO_DTFIM >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRFIM > '" + FP4->FP4_HRINI + "' AND FPO_HRFIM < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "')  " + CRLF   
    CQUERY += "           OR ( ZLG.FPO_DTFIM >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI = '" + FP4->FP4_HRINI + "' AND FPO_HRFIM = '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' ) " + CRLF 
    CQUERY += "           OR ( ZLG.FPO_DTFIM >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI < '" + FP4->FP4_HRINI + "' AND FPO_HRFIM > '" + FP4->FP4_HRINI + "' ) " + CRLF
    CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTINI <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' AND FPO_HRFIM > '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' ) " + CRLF
    CQUERY += "     " + CRLF 
    CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI > '" + FP4->FP4_HRINI + "' AND FPO_HRINI < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' )  " + CRLF
    CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRFIM > '" + FP4->FP4_HRINI + "' AND FPO_HRFIM < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "')   " + CRLF
    CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI = '" + FP4->FP4_HRINI + "' AND FPO_HRFIM = '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' )  " + CRLF
    CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI < '" + FP4->FP4_HRINI + "' AND FPO_HRFIM > '" + FP4->FP4_HRINI + "' ) " + CRLF
    CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' AND FPO_HRFIM > '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' )) " + CRLF
    CQUERY += " ORDER BY ZLG.FPO_DTINI "
	CQUERY := CHANGEQUERY(CQUERY)
	DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERY),"TRAB", .F., .T.)
	TCSETFIELD("TRAB" , "FPO_DTINI" , "D" , 8 , 0)
	TCSETFIELD("TRAB" , "FPO_DTFIM" , "D" , 8 , 0)
	
	LCONFLITO := .F.
	XMSG      := STR0062 //"Conflito AS X PROG. DIÁRIA, aceite cancelado!"
	
	WHILE ! EOF()
		LCONFLITO := .T.
		CMSG := STR0063 + DTOC(FQ5->FQ5_DATINI) + STR0064 + DTOC(FQ5->FQ5_DATFIM) + STR0065 + FPO_NRAS + CHR(10) //"O período de "###" até "###" conflita com a AS: "
		CMSG += STR0066 + DTOC(FPO_DTINI) + STR0064 + DTOC(FPO_DTFIM) + STR0067 + AOPCCMB[ASCAN(AOPCCMB, {|X| X[3]==FPO_STATUS}), 4] + STR0068 + FPO_NOMCLI //"De "###" Até "###" Status: "###"  Cliente: "
		MSGSTOP(STR0069+FQ5->FQ5_GUINDA+"]  -  "+CMSG , STR0022)  //"Conflito de datas na frota: ["###"Atenção!"
		DBSELECTAREA("TRAB")
		DBSKIP()
	ENDDO
	TRAB->(DBCLOSEAREA())
	
	IF ! LCONFLITO 										// VERIFICAR SE EXISTE PERÍODO DE MANUTENÇÃO 
		IF SELECT("TRAB") > 0
			DBSELECTAREA("TRAB")
			DBCLOSEAREA()
		ENDIF
		
		CQUERY := " SELECT FPO_NRAS, FPO_NOMCLI, FPO_STATUS, FPO_DTINI, FPO_DTFIM, FPO_HRINI, FPO_HRFIM " 
		CQUERY += " FROM " + RETSQLNAME("FPO") + " ZLG "
		CQUERY += " WHERE   ZLG.D_E_L_E_T_ = '' "
		CQUERY += "     AND ZLG.FPO_FROTA = '" + FP4->FP4_GUINDA + "'"
		CQUERY += "     AND ZLG.FPO_CODBEM = ''"
		CQUERY += "     AND ZLG.FPO_STATUS IN ('9','C')"	// STATUS DE MANUTENÇÃO 9-PREVENTIVO C-CORRETIVO
		CQUERY += "     AND (    ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTINI <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI > '" + FP4->FP4_HRINI + "' AND FPO_HRINI < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' ) " + CRLF  
        CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTINI <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRFIM > '" + FP4->FP4_HRINI + "' AND FPO_HRFIM < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' ) " + CRLF
        CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTINI <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI = '" + FP4->FP4_HRINI + "' AND FPO_HRFIM = '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' ) " + CRLF
        CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTINI <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI < '" + FP4->FP4_HRINI + "' AND FPO_HRFIM > '" + FP4->FP4_HRINI + "' ) " + CRLF
        CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTINI <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' AND FPO_HRFIM > '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' ) " + CRLF
        CQUERY += "    " + CRLF 
        CQUERY += "           OR ( ZLG.FPO_DTFIM >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI > '" + FP4->FP4_HRINI + "' AND FPO_HRINI < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' )  " + CRLF
        CQUERY += "           OR ( ZLG.FPO_DTFIM >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRFIM > '" + FP4->FP4_HRINI + "' AND FPO_HRFIM < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "')  " + CRLF   
        CQUERY += "           OR ( ZLG.FPO_DTFIM >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI = '" + FP4->FP4_HRINI + "' AND FPO_HRFIM = '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' ) " + CRLF 
        CQUERY += "           OR ( ZLG.FPO_DTFIM >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI < '" + FP4->FP4_HRINI + "' AND FPO_HRFIM > '" + FP4->FP4_HRINI + "' ) " + CRLF
        CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTINI <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' AND FPO_HRFIM > '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' ) " + CRLF
        CQUERY += "     " + CRLF 
        CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI > '" + FP4->FP4_HRINI + "' AND FPO_HRINI < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' )  " + CRLF
        CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRFIM > '" + FP4->FP4_HRINI + "' AND FPO_HRFIM < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "')   " + CRLF
        CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI = '" + FP4->FP4_HRINI + "' AND FPO_HRFIM = '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' )  " + CRLF
        CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI < '" + FP4->FP4_HRINI + "' AND FPO_HRFIM > '" + FP4->FP4_HRINI + "' ) " + CRLF
        CQUERY += "           OR ( ZLG.FPO_DTINI >= '" + DTOS(FP4->FP4_DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(FP4->FP4_DTFIM) + "' AND ZLG.FPO_HRINI < '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' AND FPO_HRFIM > '" + IIF(ALLTRIM(FP4->FP4_HRFIM) == "2400", "0000", FP4->FP4_HRFIM) + "' )) " + CRLF
		CQUERY += " ORDER BY ZLG.FPO_DTINI" 
		CQUERY := CHANGEQUERY(CQUERY)
		DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERY),"TRAB", .F., .T.)
		TCSETFIELD("TRAB","FPO_DTINI",   "D",8,0)
		TCSETFIELD("TRAB","FPO_DTFIM",   "D",8,0)
		
		WHILE ! EOF()
			CMSG := STR0063 + DTOC(FQ5->FQ5_DATINI) + " ATÉ " + DTOC(FQ5->FQ5_DATFIM)  //"O PERÍODO DE "
			CMSG += STR0070 + AOPCCMB[ASCAN(AOPCCMB, {|X| X[3]==FPO_STATUS}), 4] + CHR(10) //" CONFLITA COM MANUTENÇÃO, STATUS: "
			CMSG += STR0071 + DTOC(FPO_DTINI) + STR0064 + DTOC(FPO_DTFIM) //"MANUTENÇÃO DE "###" ATÉ "
			MSGSTOP(STR0072+FQ5->FQ5_GUINDA+"]  -  " + CMSG , STR0022)  //"Conflito manutenção na frota: ["###"Atenção!"
			
			FOR DDT := FPO_DTINI TO FPO_DTFIM
				IF ASCAN(ADIASMANUT, DDT) == 0
					AADD(ADIASMANUT, DDT)
				ENDIF
			NEXT DDT
			
			IF FQ5->FQ5_DATINI >= FPO_DTINI .AND. FQ5->FQ5_DATFIM <= FPO_DTFIM				// SE O PERÍODO DE MANUTENÇÃO COMPREENDER TODA A AS, BLOQUEIA ACEITE.
				LCONFLITO := .T.
			ENDIF
			
			DBSELECTAREA("TRAB")
			DBSKIP()
		ENDDO
		TRAB->(DBCLOSEAREA())
	ENDIF
	
	DBSELECTAREA(CALIAS)
ENDIF

IF FQ5->FQ5_TPAS == "F" .AND. (EMPTY(FQ5->FQ5_DTINI) .OR. EMPTY(FQ5->FQ5_DTFIM))
	LCONFLITO := .T.
	XMSG      := STR0073 //"A AS deve ser programada!"
ENDIF

IF EMPTY(CLOTE) .and. _lMens
	DEFINE MSDIALOG _ODLG     TITLE STR0074+_CTIPOAS  FROM C(230),C(359) TO C(400),C(882) PIXEL		// DE 610 PARA 400 //"Aceite de "
		@ C(017),C(010) SAY STR0075+_CTIPOAS+" Nº: "+FQ5->FQ5_AS FONT OFONT COLOR CLR_BLACK PIXEL OF _ODLG //"Confirma o aceite da "
		@ C(025),C(010) SAY _MV_LOC248 + STR0076+ALLTRIM(FQ5->FQ5_SOT) + STR0077 + FP0->FP0_REVISA + " ?" FONT OFONT COLOR CLR_BLACK PIXEL OF _ODLG //"PROJETO"###" Nº: "###" Rev.: "
		IF LCONFLITO
			@ C(040),C(010) SAY XMSG FONT OFONT COLOR CLR_RED PIXEL OF _ODLG
		ENDIF
	ACTIVATE MSDIALOG _ODLG CENTERED ON INIT ENCHOICEBAR(_ODLG, {|| LOK := .T. , _ODLG:END()} , {||_ODLG:END() } )
ELSE
	LOK := .T.
ENDIF

IF LCONFLITO
	MSGINFO(STR0078+ALLTRIM(FQ5->FQ5_AS)+STR0079+CHR(13)+STR0080+FQ5->FQ5_GUINDA , STR0022)  //"Operação cancelada! Esta AS ["###"] não poderá ser aceita, pois existem conflitos! "###"FROTA: "###"Atenção!"
	CFILANT := CFILOLD
	RETURN .F.
ENDIF

IF LOK
	// --> PESQUISA SE EXISTE ZLE PARA A AS, CASO EXISTA E NÃO TENHA RELAÇÃO COM ZAE, EXCLUI-SE.
	IF FQ5->FQ5_TPAS == "T"		// AS DE TRANSPORTE
		AAREAZLE := FPM->( GETAREA() )
		AAREAZAE := FP8->( GETAREA() )
		
		FPM->( DBSETORDER(4) )
		FPM->( DBSEEK( XFILIAL("FPM") + FQ5->FQ5_AS + FQ5->FQ5_VIAGEM ) )
		WHILE ! FPM->( EOF() ) .AND. XFILIAL("FPM")==FPM->FPM_FILIAL  .AND.  FQ5->FQ5_AS==FPM->FPM_AS  .AND.  FQ5->FQ5_VIAGEM==FPM->FPM_VIAGEM
			_LFOUND := .F.
			
			FP8->( DBSEEK( XFILIAL("FP8") + FQ5->FQ5_SOT + FQ5->FQ5_OBRA, .T. ) )
			WHILE ! FP8->( EOF() ) .AND. XFILIAL("FP8")==FP8->FP8_FILIAL  .AND.  FQ5->FQ5_SOT==FP8->FP8_PROJET  .AND.  FQ5->FQ5_OBRA==FP8->FP8_OBRA
				IF FPM->FPM_FROTA == FP8->FP8_TRANSP
					_LFOUND := .T.
					EXIT
				ENDIF
				FP8->( DBSKIP() )
			ENDDO
			
			IF ! _LFOUND
				RECLOCK("FPM",.F.)
				FPM->(DBDELETE()) 
				FPM->(MSUNLOCK()) 
			ENDIF
			FPM->( DBSKIP() )
		ENDDO
		
		FP8->( RESTAREA( AAREAZAE ) )
		FPM->( RESTAREA( AAREAZLE ) )
	ENDIF
	
	IF FQ5->FQ5_TPAS == "T"							// --> SE GUINDASTE/EQUIPAMENTOS.
		LOCA05923(FQ5->FQ5_DATINI,FQ5->FQ5_DATFIM,FQ5->FQ5_AS,FQ5->FQ5_NOMCLI,FQ5->FQ5_SOT,FQ5->FQ5_OBRA,FQ5->FQ5_VIAGEM,LREVIS,FQ5->FQ5_SEQCAR)
	ENDIF
	
	IF FQ5->FQ5_TPAS == "F" 
		// --> ROTINA QUE REALIZA A CRIAÇÃO DA SOLICITAÇÃO DE COMPRA AUTOMÁTICA.
		IF LGERSC  .AND.  !LMSROTAUTO 
			IF SELECT ("TMP") > 0 
				TMP->(DBCLOSEAREA()) 
			ENDIF 
			IF LEN(TAMSX3("FQ7_ITTPFR")) > 0 		// --> SE O CAMPO NAO EXISTIR NAO VALIDA O TIPO DE FRETE.
				CQUERY := " SELECT FQ7_TPOPE , FQ7_CC , FQ7_CIDORI , FQ7_CIDEST , FQ7_OBRA , FQ7_TPROMA , FQ7_ITTPFR "
			ELSE
				CQUERY := " SELECT FQ7_TPOPE , FQ7_CC , FQ7_CIDORI , FQ7_CIDEST , FQ7_OBRA , FQ7_TPROMA "
			ENDIF
			CQUERY     += " FROM "+RETSQLNAME("FQ7")+" ZUC "
			CQUERY     +=        " INNER JOIN "+RETSQLNAME("FPO")+" ZLG ON ZLG.D_E_L_E_T_ = '' AND FPO_VIAGEM = FQ7_VIAORI "
			CQUERY     += " WHERE  ZUC.D_E_L_E_T_ = '' "
			CQUERY     +=   " AND  ZUC.FQ7_VIAGEM = '"+FQ5->FQ5_VIAGEM+"' "
			TCQUERY CQUERY NEW ALIAS "TMP"
			
			DBSELECTAREA("TMP")
			
			CGSCPROD    := LOCA016(TMP->FQ7_TPOPE) 	// --> BUSCA O PRODUTO VINCULADO COM A SC
			_FQ7_CC  	:= TMP->FQ7_CC
			_FQ7_CIDORI	:= TMP->FQ7_CIDORI
			_FQ7_CIDEST	:= TMP->FQ7_CIDEST
			_FQ7_OBRA	:= TMP->FQ7_OBRA
			_FQ7_TPROMA	:= TMP->FQ7_TPROMA
			IF LEN(TAMSX3("FQ7_ITTPFR")) > 0 			// --> SE O CAMPO NAO EXISTIR NAO VALIDA O TIPO DE FRETE.
				_FQ7_TPFRET	:=  TMP->FQ7_ITTPFR 
			ENDIF
			IF SELECT ("TMP") > 0
				TMP->(DBCLOSEAREA())
			ENDIF
			IF !EMPTY(CGSCPROD)
				IF LEN(TAMSX3("FQ7_ITTPFR")) > 0 		// --> SE O CAMPO NAO EXISTIR NAO VALIDA O TIPO DE FRETE. 
					IF _FQ7_TPFRET <> "1" 				// --> SE O TIPO DE FRETE FOR DIFERENTE DE 1 NAO GERA SOLICITACAO DE FRETE. 
						LGERSC := .F. 
					ENDIF 
				ENDIF 
				IF LGERSC 
					Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   				Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 				{STR0081}) //"Rotina de geração de solicitação de compras descontinuada."
					
				 //	U_ITLOCGSC(CGSCPROD , FQ5->FQ5_AS , _FQ7_CC , _FQ7_CIDORI , _FQ7_CIDEST , _FQ7_OBRA , _FQ7_TPROMA)	// --> GERA SOLICITAÇÃO DE COMPRA SOBRE O CONJUNTO TRANSPORTADOR.
				ENDIF
			ELSE
				Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   			Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 			{STR0082}) //"Solicitação de compras não gerada. Produto não localizado no cadastro de tipo de operação X produto."
				RETURN .F. 
			ENDIF 
		ENDIF 

		DDTINI  := FQ5->FQ5_DTINI
		DDTFIM  := FQ5->FQ5_DTFIM
		CHRINI  := SUBSTR(FQ5->FQ5_HRINI,1,2) + SUBSTR(FQ5->FQ5_HRINI,3,4)
		CHRFIM  := SUBSTR(FQ5->FQ5_HRFIM,1,2) + SUBSTR(FQ5->FQ5_HRFIM,3,4)
		CTPAMA  := FQ5->FQ5_TIPAMA
		CPACLIS := FQ5->FQ5_PACLIS
		CTITULO := STR0083 + _CTIPOAS + STR0043 + ALLTRIM(FQ5->FQ5_AS) + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + STR0045 + FP0->FP0_REVISA + SPACE(100) //"Referente a aceite da "###" Número "###"PROJETO"###", Revisão "
		EFROM 	:= ALLTRIM(USRRETNAME(__CUSERID)) + " <" + ALLTRIM(USRRETMAIL(__CUSERID)) + ">"
		
		CMSG	:= CTITULO + "<BR><BR>"
		CMSG    += STR0046+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0084+ALLTRIM(FQ5->FQ5_DESTIN)+STR0085+ALLTRIM(FQ5->FQ5_NOMCLI)+"<BR><BR>" //"Data INI/FIM: "###", Obra: "###", Cliente: "
		CMSG	+= STR0086 + USRRETNAME(__CUSERID) + "<BR><BR>" //"Dados informados pelo usuário: "
		CMSG	+= "<TABLE><TR><TH>"+STR0087+"</TH><TD>"+DTOC(DDTINI)+"</TD></TR>" //"<TABLE><TR><TH>Data carregamento:</TH><TD>"
		CMSG	+= "<TR><TH>"+STR0088+"</TH><TD>"+SUBSTR(CHRINI,1,2)+":"+SUBSTR(CHRINI,3,2)     +"</TD></TR>" //"<TR><TH>Hora carregamento:       </TH><TD>"
		CMSG	+= "<TR><TH>"+STR0089+"</TH><TD>"+DTOC(DDTFIM)+"</TD></TR>" //"<TR><TH>Data descarregamento:    </TH><TD>"
		CMSG	+= "<TR><TH>"+STR0090+"</TH><TD>"+SUBSTR(CHRFIM,1,2)+":"+SUBSTR(CHRFIM,3,2)     +"</TD></TR>" //"<TR><TH>Hora descarregamento:    </TH><TD>"
		CMSG	+= "<TR><TH>"+STR0091+"</TH><TD>"+CTPAMA      +"</TD></TR>" //"<TR><TH>Tipo amarração:          </TH><TD>"
		CMSG	+= "<TR><TH>"+STR0092+"</TH><TD>"+CPACLIS  +"</TD></TR></TABLE>" //"<TR><TH>Nº da carreta:           </TH><TD>"
		
		IF EMPTY(CLOTE)
			LOCA05909( EFROM, CPARA , "", CTITULO, CMSG, /*CANEXO*/ , "")
		ENDIF

	    IF _LC111ANT //EXISTBLOCK("LC111ANT") 										// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
			LANTACE := EXECBLOCK("LC111ANT",.T.,.T.,{ FQ5->FQ5_AS, CTITULO, CMSG, CLOTE })
	    ENDIF

		IF LANTACE		
			RECLOCK("FQ5",.F.)
			FQ5->FQ5_STATUS := "6" 					// APROVADO !
			FQ5->FQ5_ACEITE := DDATABASE 			// DATA APROVAÇÃO
			FQ5->(MSUNLOCK()) 
			
			IF _LC111ACE //EXISTBLOCK("LC111ACE") 									// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
				EXECBLOCK("LC111ACE",.T.,.T.,{FQ5->FQ5_AS , CTITULO , CMSG , CLOTE})
			ENDIF 

			IF LROMANEIO  .AND.  ALLTRIM(FQ5->FQ5_TPAS) == "F" 
				GERROMAN() 
			ENDIF
		ENDIF 

	ENDIF
	
	IF FQ5->FQ5_TPAS == "T" 						// SE FOR TRANSPORTE
		IF EMPTY(FQ5->FQ5_JUNTO)
			IF !XMOTORISTA(FQ5->FQ5_DATINI,FQ5->FQ5_DATFIM,FQ5->FQ5_AS,FQ5->FQ5_NOMCLI,FQ5->FQ5_SOT,FQ5->FQ5_OBRA,FQ5->FQ5_VIAGEM,LREVIS,FQ5->FQ5_SEQCAR)
				CFILANT := CFILOLD
				RETURN .F.
			ENDIF
		ENDIF
		LACESS := .T.
	ENDIF 											// FIM CRIAÇÃO DE PROGRAMAÇÃO DE TRANSPORTES
	
	IF FQ5->FQ5_TPAS $ "E;L" 						// SE FOR GUINDASTE OU GRUA
		LAVALIA := .F. 								// DISPARA AVALIACAO DAS PROGRAMACOES
		
		IF FQ5->FQ5_TPAS == "E" 					// SE GUINDASTE
			DBSELECTAREA("FP4")
			DBSETORDER(3)
			DBSEEK(XFILIAL("FP4")+FQ5->FQ5_AS+FQ5->FQ5_VIAGEM)  // AJUSTADO POSICIONAMENTO NA ZA5 
			LAVALIA := ! EMPTY(FP4->FP4_VIAGEM) 	// ATIVA AVALIACAO SE VIAGEM NAO VAZIA
		ELSEIF FQ5->FQ5_TPAS == "L" 				// SE GRUA
			DBSELECTAREA("FPA")
			DBSETORDER(3)
			DBSEEK(XFILIAL("FPA")+ FQ5->FQ5_AS +FQ5->FQ5_VIAGEM)
			LAVALIA := ! EMPTY(FPA->FPA_VIAGEM) 	// ATIVA AVALIACAO SE VIAGEM NAO VAZIA
		ENDIF
		
		IF LAVALIA 									// USA O PROCESSO ATUAL - GERANDO A PROGRAMACAO
			FPO->(DBSETORDER(1))
			ST9->(DBSETORDER(1))
			
			CFROTA 	:= FQ5->FQ5_GUINDA
			DTINI	:= FQ5->FQ5_DATINI
			DTFIM	:= FQ5->FQ5_DATFIM
			CNRAS	:= FQ5->FQ5_AS
			
			FP0->(DBSETORDER(1))
			FP0->(DBSEEK(FQ5->FQ5_FILORI + FQ5->FQ5_SOT))
			
			IF ST9->(DBSEEK(XFILIAL("ST9")+CFROTA)) .AND. !EMPTY(ALLTRIM(CFROTA))
				//X_CODFA := ST9->T9_CODFA
				CCODCLI := FP0->FP0_CLI
				CLOJCLI := FP0->FP0_LOJA
				CALIAS  := ALIAS()
				
				IF SELECT("TRAB") > 0
					TRAB->(DBCLOSEAREA())
				ENDIF
				
				// VERIFICA SE EXISTE REGISTRO PARA A MESMA FROTA E CLIENTE.
				CQUERY := " SELECT   TOP 1 R_E_C_N_O_ ZLGRECNO "
				CQUERY += " FROM " + RETSQLNAME("FPO") 
				CQUERY += " WHERE    D_E_L_E_T_ = '' "
				CQUERY += "   AND    FPO_FROTA  = '" + FQ5->FQ5_GUINDA + "'"
				CQUERY += "   AND    FPO_NRAS   = '" + FQ5->FQ5_AS + "'"
				CQUERY += "   AND    FPO_CODCLI = '" + CCODCLI + "'"
				CQUERY += "   AND    FPO_LOJA   = '" + CLOJCLI + "'"
				CQUERY += "   AND    FPO_STATUS NOT IN ('9','C')"
				CQUERY += " ORDER BY R_E_C_N_O_ DESC"
				DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERY),"TRAB", .F., .T.)
				
				LZLG := EOF() 						// NAO TEM REGISTROS CADASTRADOS
				IF ! LZLG
					FPO->( DBGOTO(TRAB->ZLGRECNO) )
				ENDIF
				
				IF SELECT("TRAB") > 0
					TRAB->(DBCLOSEAREA())
				ENDIF
				
				DBSELECTAREA(CALIAS)
				
				LACESS := LOCA05917(CFROTA,CNRAS ,DTOS(DTINI),DTOS(DTFIM),,, FQ5->FQ5_HORINI, FQ5->FQ5_HORFIM )//VERIFICA SE EXISTE FROTA PROGRAMADA
				
				IF LACESS
					IF SELECT("LOFRO") > 0
						LOFRO->(DBCLOSEAREA())
					ENDIF
					
					CQRY2     := " SELECT * "
					CQRY2     += " FROM "+RETSQLNAME("FPO") + " ZLG "
					CQRY2     += " WHERE  ZLG.D_E_L_E_T_ = '' "             
					CQRY2     += "   AND  ZLG.FPO_FROTA  = '" + CFROTA + "' " 
					CQRY2     += "   AND  ZLG.FPO_CODBEM = '' " 
				    IF !EMPTY(CNRAS)
						CQRY2 += "   AND  ZLG.FPO_NRAS <> '" + CNRAS + "' "
				    ENDIF
				    CQRY2     += "  AND ( ( ZLG.FPO_DTINI >= '" + DTOS(DTINI) + "' AND ZLG.FPO_DTINI <= '" + DTOS(DTFIM) + "' AND ZLG.FPO_HRINI > '" + FQ5->FQ5_HORINI + "' AND FPO_HRINI < '" + IIF(ALLTRIM(FQ5->FQ5_HORFIM) == "2400", "0000", FQ5->FQ5_HORFIM) + "' ) " 
				    CQRY2     += "  OR    ( ZLG.FPO_DTFIM >= '" + DTOS(DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(DTFIM) + "' AND ZLG.FPO_HRFIM > '" + FQ5->FQ5_HORINI + "' AND FPO_HRFIM < '" + IIF(ALLTRIM(FQ5->FQ5_HORFIM) == "2400", "0000", FQ5->FQ5_HORFIM) + "' ) "
				    CQRY2     += "  OR    ( ZLG.FPO_DTINI >= '" + DTOS(DTINI) + "' AND ZLG.FPO_DTFIM <= '" + DTOS(DTFIM) + "' AND ZLG.FPO_HRINI = '" + FQ5->FQ5_HORINI + "' AND FPO_HRFIM = '" + IIF(ALLTRIM(FQ5->FQ5_HORFIM) == "2400", "0000", FQ5->FQ5_HORFIM) + "' ))"						
					DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQRY2),"LOFRO", .F., .T.)
					
					ACZLG	 := {}
					ADAENCA1 := {}
					ADAENCA2 := {}
					N        := 1
					LADD     := .T.
					
					WHILE LOFRO->(!EOF())  //CARREGA AS DATAS DAS PROGRAMAÇÕES QUE ESTÃO ENCAVALADAS
						IF LOFRO->FPO_NRAS <> CNRAS  .OR. EMPTY(LOFRO->FPO_NRAS) .OR. LOFRO->FPO_STATUS <> "R"
						 //	AADD(ADAENCA1,{LOFRO->FPO_DTINI,LOFRO->FPO_DTFIM,LOFRO->FPO_NRAS,LOFRO->FPO_STATUS,LOFRO->FPO_CODBEM,LOFRO->R_E_C_N_O_})
						ELSE
						 //	AADD(ADAENCA2,{LOFRO->R_E_C_N_O_})
						ENDIF
						LOFRO->(DBSKIP())
					ENDDO
					
					ASORT(ADAENCA1,,,{|X,Y| X[1] <Y[1]}) 
					
					FPO->(DBSETORDER(5))
					FPO->(DBSEEK(XFILIAL("FPO")+CNRAS+CFROTA))
					WHILE CNRAS == FPO->FPO_NRAS
				   		IF EMPTY(FPO->FPO_CODBEM)
				   			IF FPO->FPO_STATUS == "R" .AND. ;
							    ( ( FPO->FPO_DTINI >= DTINI .AND. FPO->FPO_DTINI <= DTFIM .AND. FPO->FPO_HRINI >  FQ5->FQ5_HORINI .AND. FPO->FPO_HRINI <  FQ5->FQ5_HORFIM ) .OR.; 
							      ( FPO->FPO_DTFIM >= DTINI .AND. FPO->FPO_DTFIM <= DTFIM .AND. FPO->FPO_HRFIM >  FQ5->FQ5_HORINI .AND. FPO->FPO_HRFIM <  FQ5->FQ5_HORFIM ) .OR.;
							      ( FPO->FPO_DTINI >= DTINI .AND. FPO->FPO_DTFIM <= DTFIM .AND. FPO->FPO_HRINI == FQ5->FQ5_HORINI .AND. FPO->FPO_HRFIM == FQ5->FQ5_HORFIM ) )											   			   
								RECLOCK("FPO",.F.)
								FPO->(DBDELETE())
								FPO->(MSUNLOCK())
							ENDIF
						ENDIF
						FPO->(DBSKIP())
					ENDDO
					
					// --> CRIAÇÃO DA ZLG
					IF LEN(ADAENCA1) == 0
						AADD(ACZLG,{DTINI,DTFIM}) 				// ADICIONA NO ARRAY A DATA INICIAL E FINAL QUE DEVERÁ SER INCLUIDA
					ENDIF
					
					FOR NY := 1 TO LEN(ADAENCA1)
						IF ADAENCA1[NY][1] >= DTOS(DTINI) 		// VERIFICA SE A DTINICIAL DA PROGRAMACAO E MAIOR QUE A DATA DA ASG.
							IF ADAENCA1[NY][2] <= DTOS(DTFIM) 	// VERIFICA SE A DTFINAL DA PROGRAMACAO E MENOR QUE A DA ASG, SE FOR DEVERA DELETAR
								IF ADAENCA1[NY][4] $  "R|1"
									FPO->(DBGOTO(ADAENCA1[NY][6]))
									RECLOCK("FPO",.F.)
									FPO->(DBDELETE())			// DELETA A PROGRAMAÇÃO POIS A ATUAL IRÁ SUBSTITUIR A ORIGINAL
									FPO->(MSUNLOCK())
									AADD(ACZLG,{DTINI,DTFIM}) 	// ADICIONA NO ARRAY A DATA INICIAL E FINAL QUE DEVERÁ SER INCLUIDA
								ELSE
									IF NY == 1
										IF !LOCQ111(CFROTA,CNRAS ,DTOS(DTINI),DTOS((STOD(ADAENCA1[NY][1])-1)))//!LOCQ111(CFROTA,CNRAS ,(ADAENCA1[NY][1]),(ADAENCA1[NY][2]))
											AADD(ACZLG,{DTINI,(STOD(ADAENCA1[NY][1])-1)})  //ADICIONA NO ARRAY A DATA INICIAL E FINAL -1 DA PROGRAMAÇÃO ENCAVALADA
										ENDIF
									ELSE
										IF !LOCQ111(CFROTA,CNRAS ,DTOS(STOD(ADAENCA1[NY-1][2])+1),DTOS(STOD(ADAENCA1[NY][1])-1) )
											AADD(ACZLG,{(STOD(ADAENCA1[NY-1][2])+1),(STOD(ADAENCA1[NY][1])-1) })
										ENDIF
									ENDIF
									IF ADAENCA1[NY][2] < DTOS(DTFIM)
										IF !LOCQ111(CFROTA,CNRAS ,DTOS(STOD((ADAENCA1[NY][2]))+1),DTOS(DTFIM))//!LOCQ111(CFROTA,CNRAS ,(ADAENCA1[NY][1]),(ADAENCA1[NY][2]))
											AADD(ACZLG,{STOD(ADAENCA1[NY][2])+1,DTFIM})
										ENDIF
									ENDIF
								ENDIF
							ELSE   								// AJUSTA A PROGRAMACAO DA DATA FINAL DO PROJETO + 1
								IF ADAENCA1[NY][4] <> "C"
									FPO->(DBGOTO(ADAENCA1[NY][6]))
									RECLOCK("FPO",.F.)
									FPO->FPO_DTFIM := (DTFIM)
									FPO->(MSUNLOCK())
									IF NY == 1
										AADD(ACZLG,{DTINI,DTFIM})  //ADICIONA NO ARRAY A DATA INICIAL E FINAL QUE DEVERÁ SER INCLUIDA
									ELSE
										AADD(ACZLG,{(STOD(ADAENCA1[NY-1][2])+1),(STOD(ADAENCA1[NY][1])-1)}) //05/12/11 //ADICIONA NO ARRAY A DATA INICIAL E FINAL QUE DEVERÁ SER INCLUIDA
									ENDIF
								ELSE
									IF NY == 1
										IF ADAENCA1[NY][1] == DTOS(DTINI)
											IF !LOCQ111(CFROTA,CNRAS ,DTOS((STOD(ADAENCA1[NY][2])+1)),DTOS(DTFIM))
												AADD(ACZLG,{(STOD(ADAENCA1[NY][2])+1),(DTFIM)})  //ADICIONA NO ARRAY A DATA INICIAL E FINAL -1 DA PROGRAMAÇÃO ENCAVALADA
											ENDIF
										ELSE
											AADD(ACZLG,{DTINI,(STOD(ADAENCA1[NY][1])-1)})  //ADICIONA NO ARRAY A DATA INICIAL E FINAL -1 DA PROGRAMAÇÃO ENCAVALADA
										ENDIF
									ELSE
										AADD(ACZLG,{(STOD(ADAENCA1[NY-1][2])+1),(STOD(ADAENCA1[NY][1])-1)})  //ADICIONA NO ARRAY A DATA INICIAL E FINAL -1 DA PROGRAMAÇÃO ENCAVALADA
									ENDIF
									IF ADAENCA1[NY][2] < DTOS(DTFIM)
										IF !LOCQ111(CFROTA,CNRAS ,DTOS(STOD((ADAENCA1[NY][2]))+1),DTOS(DTFIM))
											AADD(ACZLG,{STOD(ADAENCA1[NY][2])+1,DTFIM})
										ENDIF
									ENDIF
								ENDIF
							ENDIF
						ENDIF
					NEXT NY
					
					IF SELECT("LOFRO") > 0
						LOFRO->(DBCLOSEAREA())
					ENDIF
					
					LCZLG := .F.
					
					CQRY2:= " SELECT * "
					CQRY2+= " FROM "+RETSQLNAME("FPO")
					CQRY2+= " WHERE D_E_L_E_T_ = '' "
					CQRY2+= " 	AND FPO_STATUS = 'R' "//('A','E','S') "
					CQRY2+= " 	AND FPO_NRAS = '"+CNRAS+"' "
					DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQRY2),"LOFRO", .F., .T.)
					
					DBSELECTAREA("LOFRO")
					LOFRO->(DBGOTOP())
					
					WHILE LOFRO->(!EOF())
						IF  LOFRO->FPO_NRAS == CNRAS .AND. LOFRO->FPO_FROTA <> CFROTA
							FPO->(DBGOTO(LOFRO->R_E_C_N_O_))
							RECLOCK("FPO",.F.)
							FPO->(DBDELETE())
							FPO->(MSUNLOCK())
							LCZLG := .T.
						ENDIF
						LOFRO->(DBSKIP())
					ENDDO
					
					IF SELECT("LOFRO") > 0
						LOFRO->(DBCLOSEAREA())
					ENDIF

					/*
					// CRIADO PROCESSO URGENTE PARA QUE SEJA DELETADA TODO REGISTRO QUE SEJA MENOR OU MAIOR QUE A DATA INICIAL E FINAL.
					CQRY2 := " SELECT 'V1' RESULT,* "
					CQRY2 += " FROM "+RETSQLNAME("FPO")
					CQRY2 += " WHERE D_E_L_E_T_ = '' "
					CQRY2 += " 	AND FPO_STATUS NOT IN ('A','E','S','C','2','4','5','6') "
					CQRY2 += " 	AND FPO_NRAS = '"+CNRAS+"' "
					CQRY2 += " 	AND FPO_DTINI < '"+DTOS(DTINI)+"' "
					
					CQRY2 += " 	UNION ALL
					
					CQRY2 += " SELECT 'V2' RESULT,*
					CQRY2 += " FROM "+RETSQLNAME("FPO")
					CQRY2 += " WHERE D_E_L_E_T_ = '' "
					CQRY2 += " 	AND FPO_STATUS NOT IN ('A','E','S','C','2','4','5','6') "
					CQRY2 += " 	AND FPO_NRAS = '"+CNRAS+"' "
					CQRY2 += " 	AND FPO_DTFIM > '"+DTOS(DTFIM)+"'"
					DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQRY2),"LOFRO", .F., .T.)
					
					WHILE LOFRO->(!EOF())
						IF  LOFRO->FPO_NRAS == CNRAS .AND. LOFRO->FPO_FROTA == CFROTA
							IF LOFRO->RESULT == "V1"
								IF STOD(LOFRO->FPO_DTFIM) < DTINI
									FPO->(DBGOTO(LOFRO->R_E_C_N_O_))
									RECLOCK("FPO",.F.)
									FPO->(DBDELETE())
									FPO->(MSUNLOCK())
								ELSE
									FPO->(DBGOTO(LOFRO->R_E_C_N_O_))
									RECLOCK("FPO",.F.)
									FPO->FPO_DTINI := DTINI
									FPO->(MSUNLOCK())
								ENDIF
							ELSEIF LOFRO->RESULT == "V2"
								IF STOD(LOFRO->FPO_DTINI) > DTFIM
									FPO->(DBGOTO(LOFRO->R_E_C_N_O_))
									RECLOCK("FPO",.F.)
									FPO->(DBDELETE())
									FPO->(MSUNLOCK())
								ELSE
									FPO->(DBGOTO(LOFRO->R_E_C_N_O_))
									RECLOCK("FPO",.F.)
									FPO->FPO_DTFIM := DTFIM
									FPO->(MSUNLOCK())
								ENDIF
								LCZLG := .T.
							ENDIF
						ENDIF
						LOFRO->(DBSKIP())
					ENDDO
					
					FOR NY:= 1 TO LEN(ACZLG)
						IF !LOCQ111(CFROTA,CNRAS ,DTOS(ACZLG[NY][1]),DTOS(ACZLG[NY][2]))
							CRIAZLG(.T. , ACZLG[NY][1] , ACZLG[NY][2])				// CRIA A PROGRAMAÇÃO DIÁRIA ATUAL
						ENDIF
					NEXT NY
					*/

				ENDIF
				
				// --> CHAMADA DA FUNÇÃO LGERPRG PARA REALIZAR A PROGRAMAÇÃO AUTOMÁTICA ACESSORIOS PADRÃO E ROTATIVOS.
				IF EMPTY(FQ5->FQ5_ACEITE) .OR. LCZLG
					LGERPRG(LCZLG)
				ENDIF
				
			ELSE
				IF EMPTY(CFROTA)		// --> SE NÃO TEM FROTA DEIXA PASSAR.
					LACESS := .T.
				ELSE
					// --> AVALIA E GRAVA ALTERAÇÕES
					LOCA05910(FQ5->FQ5_AS , FQ5->FQ5_GUINDA , FQ5->FQ5_TPAS , FQ5->FQ5_DATINI , FQ5->FQ5_DATFIM, FQ5->FQ5_VIAGEM)
				ENDIF
			ENDIF
		ENDIF
	ENDIF								// FIM CRIAÇÃO DE PROGRAMAÇÃO DE GUINDASTES E GRUAS
	
	// --> CRIANDO REGISTROS PARA MEDIÇÃO 
	// --> QUANTIDADES DE ITENS PARA O REGISTRO DE MEDIÇÃO 
	IF FP4->FP4_TIPOCA == "F" 			// GERAR SOMENTE UMA MEDIÇÃO CASO A LOCAÇÃO SEJA FECHADA.
		_NITENS := 1
	ELSEIF !EMPTY(FQ5->FQ5_DATFIM) .AND. !EMPTY(FQ5->FQ5_DATINI) .AND. FQ5->FQ5_DATINI <= FQ5->FQ5_DATFIM
		_NITENS := IIF(FQ5->FQ5_DATFIM - FQ5->FQ5_DATINI==0, 1,(FQ5->FQ5_DATFIM - FQ5->FQ5_DATINI)+1)
	ELSE
    	CFILANT := CFILOLD
		//Ferramenta Migrador de Contratos
		If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
			cLocErro := STR0253+CRLF //"Erro nos campos de Data Inicial e Data Final"
		EndIf
		RETURN NIL 
	ENDIF
	
	DBSELECTAREA("FPO")
	FPO->(DBSETORDER(4))
	FPO->(DBSEEK(XFILIAL("FPO") + FQ5->FQ5_SOT + FQ5->FQ5_OBRA + FQ5->FQ5_AS + FQ5->FQ5_VIAGEM))

	_DMOBREA := CTOD("//")
	_DDESREA := CTOD("//")
	
	// PROJETO
	DBSELECTAREA("FP0")
	FP0->(DBSETORDER(1))
	FP0->(DBSEEK(XFILIAL("FP0") + FQ5->FQ5_SOT))
	_CNUMPED := FP0->FP0_NUMPED
	_CFILPED := FP0->FP0_FILPED
	_CCODCLI := FP0->FP0_CLI
	_CLOJCLI := FP0->FP0_LOJA
	
	IF FP0->FP0_TIPOSE == "E" 			//GUINDASTE / TRANSPORTE INTERNO
		DBSELECTAREA("FP4")
		FP4->(DBSETORDER(2))
		FP4->(DBSEEK( XFILIAL("FP4") + FQ5->FQ5_SOT + FQ5->FQ5_OBRA + FQ5->FQ5_AS + FQ5->FQ5_VIAGEM))
		IF     FP4->FP4_TPMEDI == "Q"
			_DMEDPRE := FP4_DTINI + 15
		ELSEIF FP4->FP4_TPMEDI == "M"
			_DMEDPRE := FP4_DTINI + 30
		ELSEIF FP4->FP4_TPMEDI == "S"
			_DMEDPRE := FP4_DTINI + 7
		ELSEIF FP4->FP4_TPMEDI == "E"
			_DMEDPRE := FP4_DTINI
		ENDIF
		_CFROTA := FP4->FP4_GUINDA
		_CDESEQ := POSICIONE("ST9" , 1 , XFILIAL("ST9") + _CFROTA , "T9_NOME") 
		_CHRINI := SUBSTR(FP4->FP4_HRINI,1,2) + SUBSTR(FP4->FP4_HRINI,3,4)
		_CHRFIM := SUBSTR(FP4->FP4_HRFIM,1,2) + SUBSTR(FP4->FP4_HRFIM,3,4)
		_NHRTOT := FP4->FP4_MINDIA
		_CBASE  := FP4->FP4_TIPOCA
		_NVRHOR := FP4->FP4_VRHOR
		_NVTOTH := IIF(FP4->FP4_TIPOCA == "F" , FP4->FP4_VRHOR , FP4->FP4_VRHOR * FP4->FP4_MINDIA) 
		_NVRMOB := FP4->FP4_VRMOB
		_NVRDES := FP4->FP4_VRDES
		_CTPSEG := FP4->FP4_TPSEGU
		_NPERSG := FP4->FP4_PERSEG
		_NVBASS := FP4->FP4_VRCARG
		_NVRSEG := FP4->FP4_VRSEGU
		_CTPISS := FP4->FP4_TPISS
		_NPRISS := FP4->FP4_PERISS
		_NVRISS := FP4->FP4_VRISS
		_NTNSPS := FP4->FP4_VRPESO
		_NANCOR := 0
		_NTELES := 0
		_MONTAG := 0
		_DESMON := 0
	 //	_CCDANT := FP4->FP4__CODLC
		_NTOTKM := FP4->FP4_PREKM
		IF _CTPSEG $ "I;C"
			IF _CBASE == "K"
				_NVRTOM := (_NTOTKM * _NVRHOR) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS
			ELSE
				_NVRTOM := (      0 * _NVRHOR) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS
			ENDIF
		ELSE
			IF _CBASE == "K"
				_NVRTOM := (_NTOTKM * _NVRHOR) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS + _NVRSEG
			ELSE
				_NVRTOM := (      0 * _NVRHOR) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS + _NVRSEG
			ENDIF
		ENDIF
		_CORIVN := FP4->FP4_FILIAL
		_CFIMAQ := FP4->FP4_FLMAQ
		_CFIMOR := FP4->FP4_FLMO
		_NPOVEN := 0 //POSICIONE("ZLK", 1, XFILIAL("ZLK") + FP4->FP4_RATEIO, "ZLK_PCOML")
		_NPRMAQ := 0 //POSICIONE("ZLK", 1, XFILIAL("ZLK") + FP4->FP4_RATEIO, "ZLK_PBEM")
		_NPRMAO := 0 //POSICIONE("ZLK", 1, XFILIAL("ZLK") + FP4->FP4_RATEIO, "ZLK_PMO")
		_NPORMA := FP4->FP4_PERMAO
		_NVRORV := _NVRTOM * _NPOVEN / 100
		_NVRMAQ := _NVRTOM * _NPRMAQ / 100
		_NVRMAO := _NVRTOM * _NPRMAO / 100
		
		IF FPO->FPO_STATUS == "2"
			IF FP4->FP4_TPMEDM == "O"
				_DMOBREA := FPO->FPO_DTINI
			ELSEIF FP4->FP4_TPMEDM $ "I;E;Q;S;M"
				_DMOBREA := FPO->FPO_DTFIM
			ENDIF
		ELSEIF FPO->FPO_STATUS == "4"
			IF FP4->FP4_TPMEDM == "O"
				_DDESREA := FPO->FPO_DTINI
			ELSEIF FP4->FP4_TPMEDM $ "I;E;Q;S;M"
				_DDESREA := FPO->FPO_DTFIM
			ENDIF
		ENDIF
		
	ELSEIF FP0->FP0_TIPOSE == "L"
		DBSELECTAREA("FPA")
		FPA->(DBSETORDER(2))
		FPA->(DBSEEK(XFILIAL("FPA") + FQ5->FQ5_SOT + FQ5->FQ5_OBRA + FQ5->FQ5_AS + FQ5->FQ5_VIAGEM))
		IF FPA->FPA_TPMEDI == "Q"
			_DMEDPRE := FPA->FPA_DTINI + 15
		ELSEIF FPA->FPA_TPMEDI == "M"
			_DMEDPRE := FPA->FPA_DTINI + 30
		ELSEIF FPA->FPA_TPMEDI == "S"
			_DMEDPRE := FPA->FPA_DTINI + 7
		ELSEIF FPA->FPA_TPMEDI == "E"
			_DMEDPRE := FPA->FPA_DTINI
		ELSE
			_DMEDPRE := FPA->FPA_DTINI
		ENDIF
		_CFROTA := FPA->FPA_GRUA
		_CDESEQ := POSICIONE("ST9", 1, XFILIAL("ST9") + _CFROTA, "T9_NOME")
		_CHRINI := SUBSTR(FPA->FPA_HRINI,1,2)  + SUBSTR(FPA->FPA_HRINI,3,4)
		_CHRFIM := SUBSTR(FPA->FPA_HRFIM,1,2)  + SUBSTR(FPA->FPA_HRFIM,3,4)
		_NHRTOT := FPA->FPA_PREDIA 				// FPA->FPA_MINDIA
		_CBASE  := FPA->FPA_TIPOCA
		_NVRHOR := FPA->FPA_VRHOR
		_NVTOTH := FPA->FPA_VRHOR * _NHRTOT 	// FPA->FPA_MINDIA
		_NVRMOB := FPA->FPA_VRMOB
		_NVRDES := FPA->FPA_VRDES
		_CTPSEG := FPA->FPA_TPSEGU
		_NPERSG := FPA->FPA_PERSEG
		_NVBASS := FPA->FPA_VRCARG
		_NVRSEG := FPA->FPA_VRSEGU
		_CTPISS := FPA->FPA_TPISS
		_NPRISS := FPA->FPA_PERISS
		_NVRISS := FPA->FPA_VRISS
		_NTNSPS := FPA->FPA_VRPESO
		_NANCOR := FPA->FPA_ANCORA
		_NTELES := FPA->FPA_TELESC
		_MONTAG := FPA->FPA_MONTAG
		_DESMON := FPA->FPA_DESMON
		_CCDANT := FPA->FPA_CODLCR
		_NTOTKM := 0
		IF _CTPSEG $ "I;C"
			IF _CBASE == "K"
				_NVRTOM := (_NTOTKM * _NVRHOR ) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS
			ELSE
				_NVRTOM := (      0 * _NVRHOR ) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS
			ENDIF
		ELSE
			IF _CBASE == "K"
				_NVRTOM := (_NTOTKM * _NVRHOR ) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS + _NVRSEG
			ELSE
				_NVRTOM := (      0 * _NVRHOR ) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS + _NVRSEG
			ENDIF
		ENDIF
		_CORIVN := FPA->FPA_FILIAL
		_CFIMAQ := FPA->FPA_FLMAQ
		_CFIMOR := FPA->FPA_FLMO
		_NPOVEN := 0 //POSICIONE("ZLK", 1, XFILIAL("ZLK") + FPA->FPA_RATEIO, "ZLK_PCOML")
		_NPRMAQ := 0 //POSICIONE("ZLK", 1, XFILIAL("ZLK") + FPA->FPA_RATEIO, "ZLK_PBEM")
		_NPRMAO := 0 //POSICIONE("ZLK", 1, XFILIAL("ZLK") + FPA->FPA_RATEIO, "ZLK_PMO")
		_NPORMA := FPA->FPA_PERMAO
		_NVRORV := _NVRTOM * _NPOVEN / 100
		_NVRMAQ := _NVRTOM * _NPRMAQ / 100
		_NVRMAO := _NVRTOM * _NPRMAO / 100
		
		IF FPO->FPO_STATUS == "2"
			IF     FP4->FP4_TPMEDM == "O"
				_DMOBREA := FPO->FPO_DTINI
			ELSEIF FP4->FP4_TPMEDM $ "I;E;Q;S;M"
				_DMOBREA := FPO->FPO_DTFIM
			ENDIF
		ELSEIF FPO->FPO_STATUS == "4"
			IF     FP4->FP4_TPMEDM == "O"
				_DDESREA := FPO->FPO_DTINI
			ELSEIF FP4->FP4_TPMEDM $ "I;E;Q;S;M"
				_DDESREA := FPO->FPO_DTFIM
			ENDIF
		ENDIF
		
	ELSEIF FP0->FP0_TIPOSE == "T" .AND. ZA6->ZA6_INTMUN == "S"
		DBSELECTAREA("ZA6")
		ZA6->(DBSETORDER(2))
		ZA6->(DBSEEK(XFILIAL("FQ5") + FQ5->FQ5_AS + FQ5_VIAGEM))
		_DMEDPRE:= ZA6->ZA6_DTINI
		_CFROTA := ZA6->ZA6_TRANSP
		_CDESEQ := POSICIONE("ST9", 1, XFILIAL("ST9") + _CFROTA, "T9_NOME")
		_CHRINI := SUBSTR(ZA6->ZA6_HRINI,1,2)  + SUBSTR(ZA6->ZA6_HRINI,3,4)
		_CHRFIM := SUBSTR(ZA6->ZA6_HRFIM,1,2)  + SUBSTR(ZA6->ZA6_HRFIM,3,4)
		_NHRTOT := __HRS2MIN(_CHRFIM) - __HRS2MIN(_CHRINI)
		_CBASE  := ZA6->ZA6_TIPOCA
		_NVRHOR := ZA6->ZA6_VRDIA / 8
		_NVTOTH := _NVRHOR * _NHRTOT
		_NVRMOB := 0
		_NVRDES := 0
		
		DBSELECTAREA("ZA7")
		ZA7->(DBSETORDER(4))
		ZA7->(DBSEEK(XFILIAL("ZA7") + FQ5->FQ5_SOT + FQ5->FQ5_OBRA + FQ5->FQ5_VIAGEM))
		_CTPSEG := ZA7->ZA7_FORMAS
		_NPERSG := ZA7->ZA7_VALADV
		_NVBASS := 0
		
		DBSELECTAREA("FQ8")
		FQ8->(DBSETORDER(2))
		FQ8->(DBSEEK(XFILIAL("FQ8") + FQ5->FQ5_SOT + FQ5->FQ5_OBRA + ZA7->ZA7_SEQTRA))
		_NVRSEG := ROUND( ( FQ8->FQ8_VRFRET * _NPERSG / 100 ) ,2)
		_CTPISS := ZA7->ZA7_INCICM
		_NPRISS := ZA7->ZA7_VALICM
		_NVRISS := ROUND( ( FQ8->FQ8_VRFRET * _NPRISS / 100 ) / (( 100 - _NPRISS ) / 100) ,2)
		_NTNSPS := ZA7->ZA7_VRCARG
		_NANCOR := 0
		_NTELES := 0
		_MONTAG := 0
		_DESMON := 0
		_CCDANT := ZA6->ZA6_CODLCR
		
	 //	DBSELECTAREA("ZLX") 				// --> TABELA DESCONTINUADA.
	 //	ZLX->(DBSETORDER(1))
	 //	ZLX->(DBSEEK(XFILIAL("ZLX") + FQ5->FQ5_SOT))
	 //	_NTOTKM := ZLX->ZLX_KM
		_NTOTKM := 0 						// --> PARA INICIAR ZERADAO, POIS TABELA ZLX FOI DESCONTINUADA.
		IF _CTPSEG $ "I;C"
			IF _CBASE == "K"
				_NVRTOM := (_NTOTKM * _NVRHOR) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS
			ELSE
				_NVRTOM := (      0 * _NVRHOR) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS
			ENDIF
		ELSE
			IF _CBASE == "K"
				_NVRTOM := (_NTOTKM * _NVRHOR) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS + _NVRSEG
			ELSE
				_NVRTOM := (      0 * _NVRHOR) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS + _NVRSEG
			ENDIF
		ENDIF
		
		_CORIVN := ""
		_CFIMAQ := ""
		_CFIMOR := ""
		_NPOVEN := 0
		_NPRMAQ := 0
		_NVRORV := 0
		_NVRMAQ := 0
		_NVRMAO := 0
		_NPRMAO := 0
		
		IF FPO->FPO_STATUS == "2"
			IF FP4->FP4_TPMEDM == "O"
				_DMOBREA := FPO->FPO_DTINI
			ELSEIF FP4->FP4_TPMEDM $ "I;E;Q;S;M"
				_DMOBREA := FPO->FPO_DTFIM
			ENDIF
		ELSEIF FPO->FPO_STATUS == "4"
			IF FP4->FP4_TPMEDM == "O"
				_DDESREA := FPO->FPO_DTINI
			ELSEIF FP4->FP4_TPMEDM $ "I;E;Q;S;M"
				_DDESREA := FPO->FPO_DTFIM
			ENDIF
		ENDIF
		// --> QUANDO O TIPO DE SEGURO FOR IGUAL A "T, R, O" SÓ CRIARA UM LINHA PARA O REGISTRO
		_NITENS := 1
	ENDIF
	
	IF LACESS
		CTITULO := STR0083 + _CTIPOAS + STR0043 + FQ5->FQ5_AS + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + STR0045 + FP0->FP0_REVISA + SPACE(100) //"Referente a aceite da "###" Número "###", Revisão "
		CMSG    := STR0046+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0047+ALLTRIM(FQ5->FQ5_DESTIN)+STR0048+ALLTRIM(FQ5->FQ5_NOMCLI)+"" //"Data INI/FIM: "###",  Obra: "###",  Cliente: "

		IF _LC111ANT //EXISTBLOCK("LC111ANT") 										// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS 
			LANTACE := EXECBLOCK("LC111ANT",.T.,.T.,{ FQ5->FQ5_AS, CTITULO, CMSG, CLOTE }) 
		ENDIF 

		IF LANTACE
			RECLOCK("FQ5",.F.)
			FQ5->FQ5_STATUS := "6" 					// APROVADO !
			FQ5->FQ5_ACEITE := DDATABASE 			// DATA APROVAÇÃO
			FQ5->(MSUNLOCK()) 
		
			IF _LC111ACE //EXISTBLOCK("LC111ACE") 									// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
				EXECBLOCK("LC111ACE",.T.,.T.,{FQ5->FQ5_AS , CTITULO , CMSG})
			ENDIF

			IF LROMANEIO .AND. ALLTRIM(FQ5->FQ5_TPAS) == "F"
				GERROMAN()
			ENDIF
			
			IF EMPTY(CLOTE) 
				LOCA05909(EFROM , CPARA , CCC , CTITULO , CMSG , NIL , CCCO) 
			ENDIF
			// [inicio] José Eulálio - 13/05/2022 -  SIGALOC94-338 - Geração de cancelamento SC via Apontador
			If FQ5->(FIELDPOS("FQ5_NSC")) > 0
				If !Empty(FQ5->FQ5_NSC)
					//verifica se já gerou pedido de compras
					SC1->(DbSetOrder(1)) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
					If SC1->(DbSeek(xFilial("SC1") + FQ5->FQ5_NSC))
						If Empty(SC1->C1_PEDIDO)
							If MsgYesNo("Deseja Excluir a Solicitação de Compras " + AllTrim(FQ5->FQ5_NSC), STR0022) // "Deseja Excluir a Solicitação de Compras " + NNNN ### Atenção!
								LOCA05930()
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			// [fim] José Eulálio - 13/05/2022 -  SIGALOC94-338 - Geração de cancelamento SC via Apontador
		ENDIF 
	ENDIF
	
	lForca := .F.
	If lLOCA59Z	
		lForca := EXECBLOCK("LOCA59Z",.T.,.T.,{})
	EndIf

	IF (FQ5->FQ5_TPAS == "L" .AND. (FQ5->FQ5_STATUS != "6" .AND. FQ5->FQ5_ACEITE != DDATABASE)) .or. lForca 		// LOCAÇÃO DE PLATAFORMA 
		IF _LC111ANT //EXISTBLOCK("LC111ANT") 										// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
			LANTACE := EXECBLOCK("LC111ANT",.T.,.T.,{ FQ5->FQ5_AS, CTITULO, CMSG, CLOTE })
	    ENDIF
		IF LANTACE 
			RECLOCK("FQ5",.F.)
			FQ5->FQ5_STATUS := "6" 					// APROVADO !
			FQ5->FQ5_ACEITE := DDATABASE 			// DATA APROVAÇÃO
			FQ5->(MSUNLOCK())
			IF _LC111ACE //EXISTBLOCK("LC111ACE") 									// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
				EXECBLOCK("LC111ACE",.T.,.T.,{FQ5->FQ5_AS , "" , ""}) 
			ENDIF
			IF LROMANEIO .AND. ALLTRIM(FQ5->FQ5_TPAS) == "F"
				GERROMAN()
			ENDIF
			// [inicio] José Eulálio - 13/05/2022 -  SIGALOC94-338 - Geração de cancelamento SC via Apontador
			lForca := .F.
			If lLOCA59C	
				lForca := EXECBLOCK("LOCA59C",.T.,.T.,{})
			EndIf
			If FQ5->(FIELDPOS("FQ5_NSC")) > 0
				If !Empty(FQ5->FQ5_NSC) .or. lForca
					//verifica se já gerou pedido de compras
					SC1->(DbSetOrder(1)) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
					If SC1->(DbSeek(xFilial("SC1") + FQ5->FQ5_NSC))
						lForca := .F.
						If lLOCA59D	
							lForca := EXECBLOCK("LOCA59D",.T.,.T.,{})
						EndIf
						If Empty(SC1->C1_PEDIDO) .or. lForca
							If MsgYesNo("Deseja Excluir a Solicitação de Compras " + AllTrim(FQ5->FQ5_NSC), STR0022) // "Deseja Excluir a Solicitação de Compras " + NNNN ### Atenção!
								LOCA05930()
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			// [fim] José Eulálio - 13/05/2022 -  SIGALOC94-338 - Geração de cancelamento SC via Apontador
		ENDIF 

	ENDIF
	
ENDIF

CFILANT := CFILOLD

RETURN .T. 



// ======================================================================= \\
STATIC FUNCTION CRIAZLG(LZLG , DINI , DFIM , XSTATUS) 
// ======================================================================= \\
// --> PARA EVITAR DE TER QUE REPETIR O MESMO CÓDIGO VÁRIAS VEZES.
// --> SERVE PARA CRIAR A PROGRAMAÇÃO DIÁRIA A PARTIR DA AS (DTQ).

LOCAL NPOSBARRA := AT("/",FQ5->FQ5_SOT) 
Local _LC111ZLG := EXISTBLOCK("LC111ZLG")

DEFAULT XSTATUS := "R"

FPO->(RECLOCK("FPO",LZLG)) 
FPO->FPO_FILIAL	:= XFILIAL("FPO")
FPO->FPO_FROTA  := FQ5->FQ5_GUINDA
FPO->FPO_CODCLI	:= POSICIONE("FP0",1,XFILIAL("FP0")+FQ5->FQ5_CONTRA,"FP0_CLI")
FPO->FPO_LOJA	:= FP0->FP0_LOJA
FPO->FPO_NOMCLI	:= POSICIONE("SA1",1,XFILIAL("SA1")+FP0->FP0_CLI+FP0->FP0_LOJA,"A1_NOME") 
FPO->FPO_LOCAL	:= ALLTRIM( SA1->A1_NREDUZ) +" / "+ ALLTRIM(FQ5->FQ5_DESTIN) 
FPO->FPO_DTINI	:= DINI         		// FQ5->FQ5_DATINI
FPO->FPO_DTFIM	:= DFIM         		// FQ5->FQ5_DATFIM
FPO->FPO_NRAS   := FQ5->FQ5_AS 			// NUMERO DA AS
FPO->FPO_PROJET := FQ5->FQ5_SOT 		// NUMERO DO PROJETO
IF NPOSBARRA > 0                		// INDICA QUE EXISTE REVISAO.
	IF FQ5->FQ5_TPAS == "E"
		FPO->FPO_REVISA := STRZERO(POSICIONE("FP4",3,FQ5->FQ5_FILORI+FQ5->FQ5_AS+FQ5->FQ5_VIAGEM,"FP4_REVNAS"), 2)
	ELSEIF FQ5->FQ5_TPAS == "L"
		FPO->FPO_REVISA := STRZERO(POSICIONE("FPA",3,FQ5->FQ5_FILORI+FQ5->FQ5_AS+FQ5->FQ5_VIAGEM,"FPA_REVNAS"), 2)
	ENDIF
ENDIF
FPO->FPO_OBRA   := FQ5->FQ5_OBRA 		// OBRA
FPO->FPO_VIAGEM := FQ5->FQ5_VIAGEM 		// VIAGEM
FPO->FPO_STATUS := XSTATUS

IF _LC111ZLG //EXISTBLOCK("LC111ZLG") 												// --> PONTO DE ENTRADA PARA GRAVAÇÃO DE NOVOS CAMPOS NA ZLG
	EXECBLOCK("LC111ZLG",.T.,.T.,{ LZLT })
ENDIF
FPO->(MSUNLOCK())

RETURN NIL



// ======================================================================= \\
FUNCTION LOCA05909(_CREMET, _CDEST, _CCC, _CASSUNTO, CBODY, _CANEXO, _CCCO, _LMSG) 
// ======================================================================= \\
// --> ENVIA EMAIL - ROTINA PADRÃO

LOCAL CENVIA    	:= ALLTRIM(GETMV("MV_RELFROM"))
LOCAL _CSERMAIL		:= ALLTRIM(GETMV("MV_RELSERV"))
LOCAL _CDE     		:= ALLTRIM(GETMV("MV_RELACNT"))
LOCAL _CSENHA		:= ALLTRIM(GETMV("MV_RELPSW"))
LOCAL LSMTPAUTH  	:= GETMV("MV_RELAUTH",,.F.)
LOCAL _LENVIADO		:= .F.
LOCAL _LCONECTOU	:= .F.
LOCAL _CMAILERROR	:= ""
LOCAL _CBODY 

_CBODY  := CBODY
_CREMET := CENVIA

IF ISINCALLSTACK("APCRETORNO")	
	//CONOUT("RETORNOU WF")
ENDIF 
      
IF PCOUNT() < 8																	// NÃO MOSTRA A MENSAGEM DE EMAIL ENVIADO COM SUCESSO
	_LMSG	:= .T.
ENDIF 
                                                             	
CONNECT SMTP SERVER _CSERMAIL ACCOUNT _CDE PASSWORD _CSENHA RESULT _LCONECTOU	// CONECTA AO SERVIDOR DE EMAIL

IF !(_LCONECTOU)																// SE NAO CONECTOU AO SERVIDOR DE EMAIL, AVISA AO USUARIO
	GET MAIL ERROR _CMAILERROR
	IF _LMSG
		//conout("erro no envio do email rotina loca059")
		//MSGSTOP(STR0093 + CHR(13) + CHR(10) + ;  //"Não foi possível conectar ao servidor de e-mail."
		//	    STR0094				  + CHR(13) + CHR(10) + ;  //"Procure o administrador da rede."
		//	    STR0095								  + _CMAILERROR)  //"Erro retornado: "
	ENDIF
ELSE   
	IF LSMTPAUTH
		LAUTOK := MAILAUTH(_CDE,_CSENHA)
    ELSE                      
        LAUTOK := .T.
    ENDIF
	IF !LAUTOK 
		IF _LMSG
			//conout("erro no envio do email rotina loca059")
			//MSGSTOP(STR0096 , STR0022)  //"Não foi possível autenticar no servidor."###"Atenção!"
		ENDIF
	ELSE   
		IF EMPTY(_CREMET)
			_CREMET := CAPITAL(STRTRAN(ALLTRIM(USRRETNAME(RETCODUSR())),"."," ")) + " <" + ALLTRIM(CENVIA) + ">"
		ENDIF
		IF !EMPTY(_CANEXO)
			SEND MAIL FROM _CREMET TO _CDEST CC _CCC BCC _CCCO SUBJECT _CASSUNTO BODY CBODY ATTACHMENT _CANEXO RESULT _LENVIADO
		ELSE
			SEND MAIL FROM _CREMET TO _CDEST CC _CCC BCC _CCCO SUBJECT _CASSUNTO BODY CBODY RESULT _LENVIADO
		ENDIF
		IF !(_LENVIADO)
			GET MAIL ERROR _CMAILERROR
			IF _LMSG
				//conout("erro no envio do email rotina loca059")
				//MSGSTOP(STR0097	+ CHR(13) + CHR(10) +; //"Não foi possível enviar o e-mail."
				//	    STR0094	+ CHR(13) + CHR(10) +; //"Procure o administrador da rede."
				//	    STR0095					+ _CMAILERROR) //"Erro retornado: "
			ENDIF
		ELSE
			IF _LMSG
				//MSGINFO(STR0098 , STR0022)  //"E-mail enviado com sucesso!"###"Atenção!"
			ENDIF
		ENDIF
    ENDIF 

	DISCONNECT SMTP SERVER
ENDIF 

RETURN _LENVIADO



// ======================================================================= \\
STATIC FUNCTION VALIDPERG() 
// ======================================================================= \\
// --> VERIFICA A EXISTENCIA DAS PERGUNTAS CRIANDO-AS CASO SEJA NECESSARIO.

LOCAL _SALIAS := ALIAS() 
LOCAL AREGS   := {} 
LOCAL I,J

DBSELECTAREA("SX1")
DBSETORDER(1)
CPERG := PADR(CPERG,10)

//          GRUPO/ORDEM/PERGUNTA                                                   /VARIAVEL /TIPO/TAMANHO/DECIMAL/PRESEL/GSC/VALID                              	/VAR01     /DEF01         /DEF01         /DEF01         /CNT01/VAR02/DEF02        /DEF02        /DEF02        /CNT02/VAR03/DEF03   /DEF03   /DEF03   /CNT03/VAR04/DEF04         /DEF04         /DEF04         /CNT04/VAR05/DEF05        /DEF05        /DEF05        /CNT05/F3    /PYME/SXG/HELP/PICTURE/IDFIL
AADD(AREGS,{CPERG,"01" , STR0099    , STR0099    , STR0099    , "MV_CH1" ,"D" ,08     ,0      ,0     ,"G",""                                	,"MV_PAR01",""            ,""            ,""            ,""   ,""   ,""           ,""           ,""           ,""   ,""   ,""      ,""      ,""      ,""   ,""   ,""            ,""            ,""            ,""   ,""   ,""           ,""           ,""           ,""   ,""    ,"S" ,"" ,"" ,""})  //"PERÍODO DE ?"###"PERÍODO DE ?"###"PERÍODO DE ?"
AADD(AREGS,{CPERG,"02" , STR0100   , STR0100   , STR0100   , "MV_CH2" ,"D" ,08     ,0      ,0     ,"G",""                                	,"MV_PAR02",""            ,""            ,""            ,""   ,""   ,""           ,""           ,""           ,""   ,""   ,""      ,""      ,""      ,""   ,""   ,""            ,""            ,""            ,""   ,""   ,""           ,""           ,""           ,""   ,""    ,"S" ,"" ,"" ,""})  //"PERÍODO ATÉ ?"###"PERÍODO ATÉ ?"###"PERÍODO ATÉ ?"
AADD(AREGS,{CPERG,"03" , STR0101 , STR0101 , STR0101 , "MV_CH3" ,"C" ,01     ,0      ,0     ,"G","" 	                                ,"MV_PAR03","L"           ,""            ,""            ,""   ,""   ,""           ,""           ,""           ,""   ,""   ,""      ,""      ,""      ,""   ,""   ,""            ,""            ,""            ,""   ,""   ,""           ,""           ,""           ,""   ,""    ,"S" ,"" ,"" ,""})   //"TIPO DE SERVIÇO"###"TIPO DE SERVIÇO"###"TIPO DE SERVIÇO"

FOR I:=1 TO LEN(AREGS) 
    IF !DBSEEK(CPERG+AREGS[I][2])
        RECLOCK("SX1",.T.)
        FOR J:=1 TO FCOUNT()
            IF J <= LEN(AREGS[I])
                FIELDPUT(J,AREGS[I][J])
            ENDIF
        NEXT J 
        MSUNLOCK() 
    ENDIF 
NEXT I 

DBSELECTAREA(_SALIAS) 

RETURN NIL 



// ======================================================================= \\
FUNCTION LOCA05910(X_AS , X_COD , X_TIPO , X_INI , X_FIM , X_VIAGEM) 
// ======================================================================= \\
/// --> REAVALIA AS PROGRAMACOES DE ACORDO COM AS ALTERACOES FEITAS NO CADASTRO DE AS.
// X_AS   - NUMERO DA AS
// X_COD  - CODIGO DO PRODUTO
// X_TIPO - TIPO DE PRODUTO
// X_INI  - INICIO DA PROGRAMACAO NEGOCIADA
// X_FIM  - FIM DA PROGRAMACAO NEGOCIADA

LOCAL AAREA    := GETAREA()
LOCAL NTEMPO   := 0 				// PERIODO DA AS ( DIAS CORRIDOS )

NTEMPO := X_FIM - X_INI + 1 

// --> AVALIA A EXISTENCIA DE PROGRAMAÇÕES 
IF LOCA05911(X_AS,X_COD,X_TIPO,X_INI,X_FIM, X_VIAGEM)
	RESTAREA(AAREA) 
	RETURN .T. 
ENDIF 

IF SELECT("ANTES") <> 0
	DBSELECTAREA("ANTES")
	DBCLOSEAREA()
ENDIF

// --> SELECIONANDO PARA PROGRAMACOES DA AS PARA O MESMO PRODUTO DA AS COM STATUS 1, R , 3
CQUERY := " SELECT FPO_NRAS , FPO_CODBEM , FPO_PROJET , FPO_OBRA , FPO_VIAGEM , FPO_NOMCLI , FPO_STATUS , FPO_DTINI , FPO_DTFIM , R_E_C_N_O_  ZLGRECNO " 
CQUERY += " FROM "+RETSQLNAME("FPO")+" " 
CQUERY += " WHERE  D_E_L_E_T_ = '' "
CQUERY +=   " AND  FPO_FROTA  = '" + X_COD + "' "
CQUERY +=   " AND  FPO_CODBEM = ''"
CQUERY +=   " AND  FPO_NRAS   = '" + X_AS  + "' "
CQUERY +=   " AND  FPO_STATUS IN ('1','3','R') "
CQUERY += " ORDER BY FPO_DTINI; "
DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERY),"ANTES", .F., .T.)
TCSETFIELD("ANTES" , "FPO_DTINI" , "D" , 8 , 0) 
TCSETFIELD("ANTES" , "FPO_DTFIM" , "D" , 8 , 0) 

// --> TRATAMENTO DATAS INICIAL
DBSELECTAREA("ANTES")
WHILE ! EOF()
	IF ANTES->FPO_STATUS $ "1/3/R" 			// SE A PROGRAMACAO ANTERIOR ESTAVA COMO DISPONIVEL OU TRABALHANDO OU RESERVADO E A PROGRAMACAO ANTERIOR ESTA ABAIXO DA ALTERACAO
		FPO->( DBGOTO( ANTES->ZLGRECNO ) )
		RECLOCK("FPO",.F.)
		// DATA INICIAL DA PROGRAMACAO ANTERIOR EH MENOR DO QUE A DATA DE INICIO NEGOCIADA ATUAL
		FPO->FPO_DTINI  := X_INI
		// SE A DATA FINAL DA PROGRAMACO NEGOCIADA EH MENOR QUE A DA PROGRAMACAO ANTERIOR 
		FPO->FPO_DTFIM  := X_FIM 			// NAO FAZER NADA 
		// SE STATUS ANTERIOR EH DISPONIVEL , MUDO PARA RESERVADO
		FPO->FPO_STATUS := IIF(ANTES->FPO_STATUS == "1","3"  , FPO->FPO_STATUS ) 
		FPO->(MSUNLOCK()) 
	ENDIF
	DBSELECTAREA("ANTES") 
	DBSKIP() 
ENDDO 

ANTES->(DBCLOSEAREA())

IF SELECT("ATUAL") <> 0
	DBSELECTAREA("ATUAL")
	DBCLOSEAREA()
ENDIF
	
// --> SELECIONANDO PARA PROGRAMACOES DE OUTRAS ASS PARA O MESMO PRODUTO DA AS COM STATUS TIPO 9 , C - MANUTENCAO
CQUERY := " SELECT FPO_NRAS, FPO_CODBEM, FPO_PROJET, FPO_OBRA, FPO_VIAGEM, FPO_NOMCLI,FPO_STATUS,FPO_DTINI,FPO_DTFIM, R_E_C_N_O_  ZLGRECNO "
CQUERY += " FROM " + RETSQLNAME("FPO") 
CQUERY += " WHERE  D_E_L_E_T_ =  '' "
CQUERY +=   " AND  FPO_FROTA  =  '" + X_COD + "' "
CQUERY +=   " AND  FPO_CODBEM =  ''"
CQUERY +=   " AND  FPO_NRAS   <> '" + X_AS  + "' "
CQUERY +=   " AND  FPO_STATUS IN ('9','C') "
DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERY),"ATUAL", .F., .T.)
TCSETFIELD("ATUAL" , "FPO_DTINI" , "D" , 8 , 0) 
TCSETFIELD("ATUAL" , "FPO_DTFIM" , "D" , 8 , 0) 

// --> SE DATA INICIO NEGOCIADA ESTA ENTRE UMA PROGRAMACAO DE MANUTENCAO
DBSELECTAREA("ATUAL")
WHILE ! EOF()
	IF ATUAL->FPO_STATUS $ "9/C"		// SE DATA INICIAL NEGOCIADO ESTA ENTRE AS DATAS DA MANUTENCAO E A DATA FINAL NEGOCIADA FOR SUPERIOR A DATA FIM DA MANUTENCAO
		IF ( ATUAL->FPO_DTINI <= X_INI .AND. X_INI <= ATUAL->FPO_DTFIM ) .AND. X_FIM > ATUAL->FPO_DTFIM
			FPO->( DBGOTO( ATUAL->ZLGRECNO ) )
			RECLOCK("FPO",.F.)
			FPO->FPO_DTINI  := ATUAL->FPO_DTFIM + 1
			FPO->(MSUNLOCK()) 
		ENDIF

		IF ( ATUAL->FPO_DTINI >= X_FIM .AND. X_FIM <= ATUAL->FPO_DTFIM ) .AND. X_INI < ATUAL->FPO_DTINI
			FPO->( DBGOTO( ATUAL->ZLGRECNO ) )
			RECLOCK("FPO",.F.)
			FPO->FPO_DTFIM  := ATUAL->FPO_DTINI - 1
			FPO->(MSUNLOCK()) 
		ENDIF

		// --> SE O PERIODO DE MANUTENCAO ESTIVER ENTRE O INICIO E FIM DO NEGOCIADO
		IF  ( X_INI < ATUAL->FPO_DTINI .AND. ATUAL->FPO_DTFIM < X_FIM)
			CRIAZLG(.T. , X_INI , ATUAL->FPO_DTINI-1 , "R") 
			CRIAZLG(.T. , ATUAL->FPO_DTFIM+1 , X_FIM , "R") // TERMINO NO FIM DO CONTRATO .
		ENDIF
	ENDIF
	DBSELECTAREA("ATUAL")
	DBSKIP()
ENDDO

ATUAL->( DBCLOSEAREA() )

RESTAREA(AAREA)

RETURN .F.



// ======================================================================= \\
FUNCTION LOCA05911(Y_AS,Y_COD,Y_TIPO,Y_INI,Y_FIM, X_VIAGEM)
// ======================================================================= \\
// AVALIA AS PROGRAMACOES DE ACORDO COM AS ALTERACOES FEITAS NO CADASTRO DE AS.
// Y_AS   - NUMERO DA AS
// Y_COD  - CODIGO DO PRODUTO
// Y_TIPO - TIPO DE PRODUTO
// Y_INI  - INICIO DA PROGRAMACAO NEGOCIADA
// Y_FIM  - FIM DA PROGRAMACAO NEGOCIADA
LOCAL AAREA     := GETAREA()
LOCAL LCONFLITO := .F.

IF SELECT("ATUAL") <> 0
	DBSELECTAREA("ATUAL") 
	DBCLOSEAREA() 
ENDIF 

// --> SELECIONANDO PARA PROGRAMACOES DAS OUTRAS ASS PARA O MESMO PRODUTO DA AS COM STATUS TIPO 2/3/4/5/6/7/8/R 
CQUERY := " SELECT FPO_NRAS , FPO_NOMCLI , FPO_STATUS , FPO_DTINI , FPO_DTFIM "
CQUERY += " FROM " + RETSQLNAME("FPO") 
CQUERY += " WHERE  D_E_L_E_T_ =  '' "
CQUERY +=   " AND  FPO_FROTA  =  '" + Y_COD + "'"
CQUERY +=   " AND  FPO_CODBEM =  ''"
CQUERY +=   " AND  FPO_NRAS   <> '" + Y_AS + "'"
CQUERY +=   " AND  FPO_STATUS IN ('2','3','4','5','6','7','8','R')"
CQUERY +=   " AND (FPO_DTINI BETWEEN '" + DTOS(Y_INI) + "' AND '" + DTOS(Y_FIM) + "'"
CQUERY +=    " OR  FPO_DTFIM BETWEEN '" + DTOS(Y_INI) + "' AND '" + DTOS(Y_FIM) + "'"
CQUERY +=    " OR (FPO_DTINI <= '" + DTOS(Y_INI) + "' AND FPO_DTFIM >='" + DTOS(Y_FIM) + "')"
CQUERY +=    " OR (FPO_DTINI >= '" + DTOS(Y_INI) + "' AND FPO_DTFIM <='" + DTOS(Y_FIM) + "'))"
CQUERY += " ORDER BY FPO_DTINI;"
DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERY),"ATUAL", .F., .T.)
TCSETFIELD("ATUAL" , "FPO_DTINI" , "D" , 8 , 0) 
TCSETFIELD("ATUAL" , "FPO_DTFIM" , "D" , 8 , 0) 

WHILE ! EOF()
	LCONFLITO := .T.
	CMSG := STR0102 + Y_COD + STR0103+DTOC(ATUAL->FPO_DTINI)+STR0104+DTOC(ATUAL->FPO_DTFIM) //"Já existe programação para esta frota ( "###" ) que não pertence a essa AS. Para as datas entre "###" e "
	MSGSTOP(STR0105+Y_AS+"]  -  "+CMSG , STR0022)  //"Conflito de data na frota da ["###"Atenção!"
	DBSKIP() 
ENDDO 

IF LCONFLITO 
	RESTAREA(AAREA)
	RETURN .T.
ENDIF
     
IF SELECT("ATUAL") <> 0 
	DBSELECTAREA("ATUAL") 
	DBCLOSEAREA() 
ENDIF 

// --> SELECIONANDO PARA PROGRAMACOES DA MESMA AS PARA O MESMO PRODUTO DA AS COM STATUS TIPO 2/4/5/6/7/8/R
CQUERY := " SELECT FPO_NRAS , FPO_NOMCLI , FPO_STATUS , FPO_DTINI , FPO_DTFIM " 
CQUERY += " FROM " + RETSQLNAME("FPO")
CQUERY += " WHERE  D_E_L_E_T_ = '' "
CQUERY +=   " AND  FPO_FROTA  = '" + Y_COD + "' "
CQUERY +=   " AND  FPO_CODBEM = ''"
CQUERY +=   " AND  FPO_NRAS   = '" + Y_AS  + "' "
CQUERY +=   " AND  FPO_STATUS IN ('2','4','5','6','7','8','R') "
CQUERY +=   " AND  FPO_VIAGEM <> '" + X_VIAGEM + "'"
CQUERY +=   " AND (FPO_DTINI BETWEEN '" + DTOS(Y_INI) + "' AND '" + DTOS(Y_FIM) + "'"
CQUERY +=    " OR  FPO_DTFIM BETWEEN '" + DTOS(Y_INI) + "' AND '" + DTOS(Y_FIM) + "'"
CQUERY +=    " OR (FPO_DTINI <= '" + DTOS(Y_INI) + "' AND FPO_DTFIM >='" + DTOS(Y_FIM) + "')"
CQUERY +=    " OR (FPO_DTINI >= '" + DTOS(Y_INI) + "' AND FPO_DTFIM <='" + DTOS(Y_FIM) + "'))"
CQUERY += " ORDER BY FPO_DTINI;"
DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERY),"ATUAL", .F., .T.)
TCSETFIELD("ATUAL" , "FPO_DTINI" , "D" , 8 , 0)
TCSETFIELD("ATUAL" , "FPO_DTFIM" , "D" , 8 , 0)

WHILE ! EOF()
	LCONFLITO := .T.
	CMSG := STR0106 + Y_COD + STR0107+DTOC(ATUAL->FPO_DTINI)+STR0104+DTOC(ATUAL->FPO_DTFIM) //"Já existe programação(ões) para esta frota ( "###" ) que pertence(m) a essa AS, entre os dias : "###" e "
	MSGSTOP(STR0108+Y_AS+"]  -  "+CMSG , STR0022)  //"Conflito de datas na AS ["###"Atenção!"
	DBSKIP()
ENDDO

ATUAL->(DBCLOSEAREA())
RESTAREA(AAREA)

RETURN LCONFLITO
                


// ======================================================================= \\
FUNCTION LOCA05912(CCODEQUI)
// ======================================================================= \\
// FUNCAO GERA PROGRAMAÇÃO DE ACORDO COM A ESTRUTURA DO EQUIPAMENTO X ACESSORIOS ( ROTATIVOS ) - ARQUIVO ZM2
// ETG11 
// DEFINICAO DE VARIAVEIS
LOCAL AAREA    := GETAREA()  
LOCAL CCODZLG, CCLIENTE, CLOJA, CNOMCLI
LOCAL DDTINI 
LOCAL DDTFIM
LOCAL CAS
LOCAL CSOT
LOCAL CREV
LOCAL COBRA
LOCAL CVIAGEM
LOCAL CSTATUS
LOCAL CCODEST
LOCAL NSALDO , NQTEMP , NQTREQ
//LOCAL CTIPACE

CCODZLG  := FPO->FPO_FROTA
CCLIENTE := FPO->FPO_CODCLI	
CLOJA    := FPO->FPO_LOJA
CNOMCLI  := FPO->FPO_NOMCLI
DDTINI   := FPO->FPO_DTINI
DDTFIM   := FPO->FPO_DTFIM
CAS      := FPO->FPO_NRAS
CSOT     := FPO->FPO_PROJET								// FPO->FPO_SOT 
CREV     := FPO->FPO_REVISA
COBRA    := FPO->FPO_OBRA 
CVIAGEM  := FPO->FPO_VIAGEM 
CSTATUS  := FPO->FPO_STATUS

DBSELECTAREA("FPW")
DBSETORDER(1)
DBSEEK(XFILIAL("FPW")+CCODEQUI) 						// PESQUISA O EQUIPAMENTO

WHILE FPW->(!EOF()) .AND. CCODEQUI == FPW->FPW_EQUIP 	// LENDO ESTRUTURA 
	CCODEST := POSICIONE("ST9",1,XFILIAL("ST9")+FPW->FPW_CODACE,"T9_CODESTO")
	NSALDO  := POSICIONE("SB2",1,XFILIAL("SB2")+CCODEST,"B2_QATU")
	NQTEMP  := FPW->FPW_QUANT
	NQTREQ  := IIF(NSALDO > 0,IIF(NSALDO < NQTEMP , NSALDO ,NQTEMP),0)//IIF(NSALDO > 0,IIF(NSALDO - NQTEMP >= 0 , NQTEMP , IIF(NQTEMP - NSALDO > 0 , NQTEMP - NSALDO, 0 )),0)

	IF EMPTY(NQTREQ) .OR. NQTREQ == 0 					// .OR. CTIPACE <> "R"
		FPW->(DBSKIP())
		LOOP
	ENDIF

	RECLOCK("FPO",.T.)
	FPO->FPO_FILIAL	:= XFILIAL("FPO")
	FPO->FPO_FROTA	:= CCODZLG
	FPO->FPO_CODCLI	:= CCLIENTE 
	FPO->FPO_LOJA	:= CLOJA  
	FPO->FPO_LOCAL	:= ALLTRIM(POSICIONE("SA1",1,XFILIAL("SA1")+CCODCLI+CLOJCLI,"A1_NREDUZ"))+" / "+ALLTRIM(FQ5->FQ5_DESTIN)
	FPO->FPO_DESCAC := POSICIONE("ST9",1,XFILIAL("ST9")+FPW->FPW_CODACE,"T9_NOME")
	//FPO->FPO_CODFAN := POSICIONE("ST9",1,XFILIAL("ST9")+FPW->FPW_CODACE,"T9_CODFA")
	FPO->FPO_NOMCLI	:= CNOMCLI
	FPO->FPO_DTINI	:= DDTINI
	FPO->FPO_DTFIM	:= DDTFIM
	FPO->FPO_NRAS	:= CAS 
	FPO->FPO_PROJET	:= CSOT
	FPO->FPO_REVISA	:= CREV 
	FPO->FPO_OBRA	:= COBRA
	FPO->FPO_VIAGEM	:= CVIAGEM 
	FPO->FPO_STATUS	:= "R"
	FPO->FPO_CODBEM := FPW->FPW_CODACE
	FPO->FPO_QTACES := NQTREQ
	FPO->FPO_COMPR  := ROUND(VAL(SUBSTR("0"+POSICIONE("STB",1,XFILIAL("STB")+TRAB->T9_CODBEM+"000002","TB_DETALHE"),1,5)),2)
	FPO->FPO_LARGUR := ROUND(VAL(SUBSTR("0"+POSICIONE("STB",1,XFILIAL("STB")+TRAB->T9_CODBEM+"000003","TB_DETALHE"),1,5)),2)
	FPO->FPO_ALTURA := ROUND(VAL(SUBSTR("0"+POSICIONE("STB",1,XFILIAL("STB")+TRAB->T9_CODBEM+"000001","TB_DETALHE"),1,5)),2)
	FPO->FPO_PESO   := ROUND(VAL(SUBSTR("0"+POSICIONE("STB",1,XFILIAL("STB")+TRAB->T9_CODBEM+"000004","TB_DETALHE"),1,5)),2)

	FPO->(MSUNLOCK())
		
	FPW->(DBSKIP())
ENDDO          

RESTAREA(AAREA)

RETURN NIL



// ======================================================================= \\
FUNCTION LOCA05913() 
// ======================================================================= \\
// --> "PROGRAMAÇÃO ASF" 

LOCAL CFILOLD   := CFILANT 

PRIVATE ODLG
PRIVATE LOK     := .F.
PRIVATE DDTINI  := FQ5->FQ5_DTINI
PRIVATE DDTFIM  := FQ5->FQ5_DTFIM
PRIVATE CHRINI  := FQ5->FQ5_HRINI
PRIVATE CHRFIM  := FQ5->FQ5_HRFIM
PRIVATE CTPAMA  := FQ5->FQ5_TIPAMA
PRIVATE CPACLIS := FQ5->FQ5_PACLIS
Private _MV_LOC248 := SUPERGETMV("MV_LOCX248",.F.,STR0044)

CFILANT := FQ5->FQ5_FILORI 

IF  !EMPTY(FQ5->FQ5_DATFEC) .OR. !EMPTY(FQ5->FQ5_DATENC) .OR. !FQ5->FQ5_STATUS $ "16"
	MSGINFO(STR0109 , STR0022)  //"Operação cancelada. Só é possível realizar a programação do frete, com uma AS aberta."###"Atenção!"
	CFILANT := CFILOLD
	RETURN NIL 
ENDIF 

DEFINE MSDIALOG ODLG  TITLE STR0110         FROM C(230),C(360) TO C(460),C(600)                      PIXEL  //"Programação de frente"
	@ C(030),C(010) SAY   STR0111                                                                      PIXEL OF ODLG  //"Data carregamento:"
	@ C(037),C(010) GET   DDTINI                                                                                    PIXEL OF ODLG 
	@ C(030),C(070) SAY   STR0112                                                                      PIXEL OF ODLG  //"Hora carregamento:"
	@ C(037),C(070) GET   CHRINI  PICTURE "@R 99:99"         VALID LOCA05915(CHRINI)                               PIXEL OF ODLG 

	@ C(055),C(010) SAY   STR0113                                                                   PIXEL OF ODLG  //"Data descarregamento:"
	@ C(062),C(010) MSGET DDTFIM                                                                                    PIXEL OF ODLG 
	@ C(055),C(070) SAY   STR0114                                                                   PIXEL OF ODLG  //"Hora descarregamento:"
	@ C(062),C(070) MSGET CHRFIM  PICTURE "@R 99:99"         VALID LOCA05915(CHRFIM)                               PIXEL OF ODLG 

	@ C(080),C(010) SAY   STR0115                                                                         PIXEL OF ODLG  //"Tipo amarração:"
	SX5->(dbSetOrder(1))
	If SX5->(dbSeek(xFilial("SX5")+"ZL"))
		@ C(087),C(010) MSGET CTPAMA  PICTURE "XXXXXX"  F3 "ZL"  VALID EMPTY(CTPAMA) .OR. EXISTCPO("SX5","ZL"+CTPAMA,1) PIXEL OF ODLG 
	Else
		@ C(087),C(010) MSGET CTPAMA  PICTURE "XXXXXX"  F3 "QT"  VALID EMPTY(CTPAMA) .OR. EXISTCPO("SX5","QT"+CTPAMA,1) PIXEL OF ODLG 
	EndIf

	@ C(080),C(070) SAY   STR0116                                                                          PIXEL OF ODLG  //"Nº da carreta:"
	@ C(087),C(070) MSGET CPACLIS PICTURE "@R 999"           VALID LOCA05918()  when(.F.)                                     PIXEL OF ODLG 
ACTIVATE MSDIALOG ODLG CENTERED ON INIT ENCHOICEBAR(ODLG, {|| LOK := LOCA05914() }, {|| ODLG:END()} )

IF LOK 
	BEGIN TRANSACTION 
		RECLOCK("FQ5",.F.)
		FQ5->FQ5_DTINI	:= DDTINI
		FQ5->FQ5_DTFIM	:= DDTFIM
		FQ5->FQ5_HRINI	:= CHRINI
		FQ5->FQ5_HRFIM	:= CHRFIM
		FQ5->FQ5_TIPAMA	:= CTPAMA
		FQ5->FQ5_PACLIS	:= CPACLIS
		FQ5->FQ5_DTPROG	:= DDATABASE
		FQ5->FQ5_STATUS := "1" 
		FQ5->(MSUNLOCK()) 
	END TRANSACTION

	CPARA	:= SUPERGETMV("MV_LOCX057",.F.,"LOLIVEIRA@ITUP.COM.BR") 
	EFROM 	:= ALLTRIM(USRRETNAME(__CUSERID)) + " <" + ALLTRIM(USRRETMAIL(__CUSERID)) + ">" 
	CTITULO := STR0117 + FQ5->FQ5_AS + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) //"Referente a programação da ASF número "###"PROJETO"

	CMSG	:= CTITULO + "<BR><BR>"
	CMSG	+= STR0086 + USRRETNAME(__CUSERID) + "<BR><BR>" //"Dados informados pelo usuário: "
	CMSG    += STR0046+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0084+ALLTRIM(FQ5->FQ5_DESTIN)+STR0085+ALLTRIM(FQ5->FQ5_NOMCLI)+"<BR><BR>"  //"Data INI/FIM: "###", Obra: "###", Cliente: "
	CMSG	+= STR0087+DTOC(DDTINI)+"</TD></TR>" //"<TABLE><TR><TH>Data carregamento:</TH><TD>"
	CMSG	+= STR0088+SUBSTR(CHRINI,1,2)+":"+SUBSTR(CHRINI,3,2)     +"</TD></TR>" //"<TR><TH>Hora carregamento:       </TH><TD>"
	CMSG	+= STR0089+DTOC(DDTFIM)+"</TD></TR>" //"<TR><TH>Data descarregamento:    </TH><TD>"
	CMSG	+= STR0090+SUBSTR(CHRFIM,1,2)+":"+SUBSTR(CHRFIM,3,2)     +"</TD></TR>" //"<TR><TH>Hora descarregamento:    </TH><TD>"
	CMSG	+= STR0091+CTPAMA      +"</TD></TR>" //"<TR><TH>Tipo amarração:          </TH><TD>"
	CMSG	+= STR0092+CPACLIS     +"</TD></TR>" //"<TR><TH>Nº da carreta:           </TH><TD>"

	CANEXO := ""

	LOCA05909( EFROM, CPARA , "", CTITULO, CMSG, CANEXO , "")
ENDIF 

CFILANT := CFILOLD
	
RETURN NIL



// ======================================================================= \\
FUNCTION LOCA05914()
// ======================================================================= \\

LOCAL LRET := .T.

IF DDTINI > DDTFIM .OR. (DDTINI == DDTFIM .AND. CHRINI > CHRFIM)
	LRET := .F.
	MSGSTOP(STR0118 , STR0022)  //"Dados incorretos: a data de carregamento não pode ser maior do que a data de descarregamento."###"Atenção!"
ELSE
	ODLG:END()
ENDIF

RETURN LRET



// ======================================================================= \\
FUNCTION LOCA05915(CPARAM)
// ======================================================================= \\

LOCAL LRET := .T.

IF LEFT(CPARAM,2) > "23" .OR. RIGHT(ALLTRIM(CPARAM),2) > "59" 
	MSGSTOP(STR0119 , STR0022)  //"Dados incorretos: o horário deve ser entre 00:00 ATÉ 23:59"###"Atenção!"
	LRET := .F. 
ENDIF 

RETURN LRET



// ======================================================================= \\
FUNCTION LOCA05916(_CFILTRO)
// ======================================================================= \\
// --> "LOTE" - TRATAMENTE AS POR LOTE.

LOCAL AAREADTQ  := FQ5->(GETAREA())
LOCAL CMSG      := ""
LOCAL NI        := 0 
LOCAL _NX       := 0 
LOCAL CAVISO    := ""
LOCAL LOK       := .F.
LOCAL LNPROG    := .F.
LOCAL CPARA     := ""
LOCAL _CPRJOLD  := ""
LOCAL _AASLOTE  := {}
LOCAL EFROM     := ALLTRIM(USRRETNAME(__CUSERID)) + " <" + ALLTRIM(USRRETMAIL(__CUSERID)) + ">"
LOCAL CCC       := ""
LOCAL CCCO      := ""
LOCAL CTITULO   := ""
LOCAL _CQUERY   := ""
Local cPesq 	:= Space(50) 
LOCAL MVPAR01
LOCAL MVPAR02
LOCAL MVPAR03
Local _MV_LOC248 := SUPERGETMV("MV_LOCX248",.F.,STR0044)
Local _LC111TIT := EXISTBLOCK("LC111TIT")
Local _LC111USR := EXISTBLOCK("LC111USR")
Local _LC111LQR := EXISTBLOCK("LC111LQR")
local _LC111LFL := EXISTBLOCK("LC111LFL")
Local _LC111LBT := EXISTBLOCK("LC111LBT")

PRIVATE CACAO   := ""
PRIVATE OOK     := LOADBITMAP( GETRESOURCES(), "LBOK" )
PRIVATE ONO     := LOADBITMAP( GETRESOURCES(), "LBNO" )
PRIVATE ALINHA  := {}
PRIVATE _AALX   := {}
PRIVATE LTODOS  := .F.
PRIVATE OLBX
PRIVATE ODLG
PRIVATE _NTPACE	:= 0
PRIVATE NTOTMIN := 0						// PARA RETORNAR O NUMERO DE MINUTAS CRIADAS
Private aLstBxOri	:= {}

DEFAULT _CFILTRO := "" // FRANK ZWARG FUGA EM 23/09/2020

_CQUERY := " SELECT DTQ.FQ5_AS     , DTQ.FQ5_GUINDA , DTQ.FQ5_VIAGEM , DTQ.FQ5_SOT , " + CRLF
_CQUERY += "        DTQ.FQ5_DESTIN , DTQ.FQ5_ORIGEM , DTQ.R_E_C_N_O_ FQ5RECNO, DTQ.FQ5_XPROD, DTQ.FQ5_OBRA, DTQ.R_E_C_N_O_ AS REG " + CRLF
_CQUERY += " FROM " + RETSQLNAME("FQ5") + " DTQ "               + CRLF
_CQUERY += " WHERE  DTQ.FQ5_FILIAL =  '" + XFILIAL("FQ5") + "'" + CRLF
_CQUERY +=   " AND  DTQ.FQ5_FILORI =  '" + CFILANT        + "'" + CRLF
_CQUERY +=   " AND  DTQ.FQ5_DATFEC =  '' "                      + CRLF
_CQUERY +=   " AND  DTQ.FQ5_DATENC =  '' "                      + CRLF
_CQUERY +=   " AND  DTQ.FQ5_STATUS =  '1'"                      + CRLF
_CQUERY +=   " AND  DTQ.FQ5_TPAS   = '" + CSERV           + "'" + CRLF
_CQUERY +=   " AND  DTQ.FQ5_DATINI >= '" + DTOS(MV_PAR01) +"' " + CRLF
_CQUERY +=   " AND  DTQ.FQ5_DATFIM <= '" + DTOS(MV_PAR02) +"' " + CRLF

IF !EMPTY(_CFILTRO)
	_CQUERY += _CFILTRO
ENDIF

IF _LC111LQR //EXISTBLOCK("LC111LQR") 												// --> PONTO DE ENTRADA PARA FILTRO NA QUERY DE ACEITE DE AS EM LOTE.
	_AALX := EXECBLOCK("LC111LQR",.T.,.T.,{_CQUERY})
	IF VALTYPE(_AALX) == "A"
		_CQUERY := _AALX[1]
		_NTPACE := _AALX[2]
	ELSE
		_CQUERY := _AALX
	ENDIF
ENDIF
_CQUERY +=   " AND  DTQ.D_E_L_E_T_ = ''" + CRLF
_CQUERY += " ORDER BY DTQ.FQ5_SOT , DTQ.FQ5_AS , DTQ.FQ5_VIAGEM , FQ5RECNO " 
IF SELECT("TRBFQ5") > 0
	TRBFQ5->(DBCLOSEAREA())
ENDIF
TCQUERY _CQUERY NEW ALIAS "TRBFQ5"
	
WHILE TRBFQ5->(!EOF())
		AADD(ALINHA, { .F.            	 ,;
		               TRBFQ5->FQ5_AS    ,;
		               TRBFQ5->FQ5_GUINDA,;
		               TRBFQ5->FQ5_VIAGEM,;
		               TRBFQ5->FQ5_SOT   ,;
		               TRBFQ5->FQ5_DESTIN,;
		               TRBFQ5->FQ5_ORIGEM,;
		               TRBFQ5->FQ5RECNO,;
					   TRBFQ5->FQ5_XPROD,;  // FRANK - 23/09/2020
					   TRBFQ5->FQ5_OBRA,;   // FRANK - 23/09/20
					   TRBFQ5->REG         })	// FRANK - 26/10/2020
	TRBFQ5->(DBSKIP())
ENDDO
TRBFQ5->(DBCLOSEAREA())

IF _LC111LFL //EXISTBLOCK("LC111LFL") 												// --> PONTO DE ENTRADA PARA FILTRO DAS AS'S EXIBIDAS PARA ACEITE EM LOTE.
	ALINHA := EXECBLOCK("LC111LFL",.T.,.T.,{ALINHA})
ENDIF

IF LEN(ALINHA) > 0
	DEFINE MSDIALOG ODLG FROM  000,000 TO 430,780 TITLE STR0120 PIXEL //"Selecione as AS (Lote)"
		@ 012,5 LISTBOX OLBX FIELDS HEADER "", STR0121,STR0122,STR0123,_MV_LOC248,STR0124,STR0125,STR0126,STR0127,STR0128  SIZE 380,170 OF ODLG PIXEL ON DBLCLICK (MARCARREGI(.F.)) //"Nº AS"###"Equipamento"###"Viagem"###"PROJETO"###"Destino"###"Origem"###"Produto"###"Obra"###"Registro"
		OLBX:SETARRAY(ALINHA)
		OLBX:BLINE := {|| { IF( ALINHA[OLBX:NAT,1],OOK,ONO),; 			// CHECKBOX
								ALINHA[OLBX:NAT,2],; 					// Nº AS
								ALINHA[OLBX:NAT,3],; 					// EQUIPAMENTO
								ALINHA[OLBX:NAT,4],;					// VIAGEM
								ALINHA[OLBX:NAT,5],;					// PROJETO
								ALINHA[OLBX:NAT,6],;            		// DESTINO
								ALINHA[OLBX:NAT,7],;            		// ORIGEM
								ALINHA[OLBX:NAT,9],;					// PRODUTO - FRANK 23/09/2020
								ALINHA[OLBX:NAT,10],;					// OBRA
								ALINHA[OLBX:NAT,11]}}   				// RECNO()
	
		@ 195,5 CHECKBOX LTODOS PROMPT STR0129 SIZE 100, 10 OF ODLG PIXEL ON CLICK MARCARREGI(.T.) //"Marca/Desmarca Todos"

		IF _LC111LBT //EXISTBLOCK("LC111LBT") 										// --> PONTO DE ENTRADA PARA INCLUSÃO DE BOTÕES NA TELA DE ACEITE EM LOTE.
			EXECBLOCK("LC111LBT",.T.,.T.,{_CQUERY, _NTPACE})
		ELSE
			//@ 195, 200 BUTTON "FILTRO"	  SIZE 30,15 PIXEL OF ODLG ACTION (CACAO:="F", ODLG:END())
			@ 195, 280 BUTTON STR0130   SIZE 30,15 PIXEL OF ODLG ACTION (CACAO:="A", ODLG:END()) // 240 //"Aceitar"
			//@ 195, 280 BUTTON "ESTORNAR"  SIZE 30,15 PIXEL OF ODLG ACTION (CACAO:="E", ODLG:END())
			@ 195, 320 BUTTON STR0131  SIZE 30,15 PIXEL OF ODLG ACTION (CACAO:="R", ODLG:END()) //"Rejeitar"
		ENDIF
		@ 195, 360 BUTTON STR0132  SIZE 30,15 PIXEL OF ODLG ACTION (ODLG:END()) //"Cancelar"
	ACTIVATE MSDIALOG ODLG CENTERED
ELSE
	CAVISO := STR0133 //"Não há AS(S) a serem exibidas!"
ENDIF

IF !EMPTY(CACAO)

	// TRATAMENTO ESPECIFICO PARA OS FILTROS - FRANK 23/09/2020
	IF CACAO == "F"
		MVPAR01 := MV_PAR01
		MVPAR02 := MV_PAR02
		MVPAR03 := MV_PAR03
		_CFILTRO := ""
		SX1->(DBSETORDER(1))
		IF SX1->(DBSEEK("ITLOT111"))
			// FILTROS:
			// PROJETO, OBRA, AS E PRODUTO
			IF PERGUNTE("ITLOT111",.T.)
				IF !EMPTY(MV_PAR01)
					_CFILTRO += " AND DTQ.FQ5_SOT = '"+MV_PAR01+"' "
				ENDIF	
				IF !EMPTY(MV_PAR02)
					_CFILTRO += " AND DTQ.FQ5_OBRA = '"+MV_PAR02+"' "
				ENDIF	
				IF !EMPTY(MV_PAR03)
					_CFILTRO += " AND DTQ.FQ5_AS = '"+MV_PAR03+"' "
				ENDIF	
				IF !EMPTY(MV_PAR04)
					_CFILTRO += " AND DTQ.FQ5_XPROD = '"+MV_PAR04+"' "
				ENDIF	
			ENDIF 
		ELSE
			Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   			Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 			{STR0134}) //"O conjunto de perguntas da rotina não está no dicionário de dados."
		ENDIF
		MV_PAR01 := MVPAR01
		MV_PAR02 := MVPAR02
		MV_PAR03 := MVPAR03
		LOCA05916(_CFILTRO)
	ENDIF

	IF CACAO == "R"
		CPARA := GETMV("MV_LOCX178",,"") 
		LOK   := .F. 
		DEFINE MSDIALOG _ODLGMAIL TITLE STR0135 FROM C(230),C(359) TO C(400),C(882) PIXEL	//DE 610 PARA 400 //"Motivo da rejeição do lote"
			@ C(025),C(011) SAY STR0050   			SIZE C(030),C(008) PIXEL OF _ODLGMAIL //"Motivo:"
			@ C(025),C(042) GET OMSG VAR CMSG MEMO 		SIZE C(200),C(055) PIXEL OF _ODLGMAIL
		ACTIVATE MSDIALOG _ODLGMAIL CENTERED ON INIT ENCHOICEBAR(_ODLGMAIL, {||LOK:=.T., _ODLGMAIL:END()}, {||_ODLGMAIL:END()} )
		IF ! LOK 
			FQ5->(RESTAREA(AAREADTQ)) 
			RETURN .F. 
		ENDIF 
		CMSG := STR0136 + CMSG + CRLF + CRLF //"Motivo: "
	ELSE
	 //	IF FQ5->FQ5_TPAS == "F"
			CPARA := GETMV("MV_LOCX033",,"")
	 //	ELSE
		 //	CPARA := GETMV("MV_LOCX178")
	 //	ENDIF
	ENDIF 

	FOR NI:=1 TO LEN(ALINHA)
		IF ALINHA[NI,1]													// SELECIONADO
			FQ5->(DBGOTO( ALINHA[NI,11] ))					// RECNO
			IF CACAO == "R"
				LOCA05907(CMSG)
			ELSEIF CACAO == "A"
				IF ! LNPROG .AND. CSERV=="F" .AND. EMPTY(FQ5->FQ5_TIPAMA)
					LNPROG := .T.
				ENDIF
				IF CSERV!="F" .OR. !EMPTY(FQ5->FQ5_TIPAMA)
					LOCA05908("LOTE")
				ENDIF
			ELSEIF CACAO == "E"
				CAVISO += LOCA05906(.T.)
			ENDIF
		ENDIF
	NEXT NI 
		
	IF (CACAO == "A" .OR. CACAO == "R") .AND. !EMPTY(ALLTRIM(CPARA))
		FOR NI := 1 TO LEN(ALINHA)
			IF ALINHA[NI,1]
		
				IF EMPTY(_CPRJOLD)
					_CPRJOLD := ALINHA[NI,5]
				ENDIF
				
				IF ALLTRIM(_CPRJOLD) <> ALLTRIM(ALINHA[NI,5])
					// MANDA E-MAIL
					IF CACAO == "R"
						CTITULO := STR0137 + _MV_LOC248 + ": " + ALLTRIM(_CPRJOLD) //"Referente ao rejeite da(s) AS(s) - "###"PROJETO"
					ELSE
						IF _LC111TIT //EXISTBLOCK("LC111TIT")
							CTITULO := EXECBLOCK("LC111TIT", .T., .T., {_NTPACE, _CPRJOLD})
						ELSE
							CTITULO := STR0138 + _MV_LOC248 + ": " + ALLTRIM(_CPRJOLD) //"Referente ao aceite da(s) AS(s) - "###"MV_LOCX248"###"PROJETO"
						ENDIF
					ENDIF
					
					CMSG := CTITULO + CHR(13) + CHR(10) + CHR(13) + CHR(10) + CMSG + CHR(13) + CHR(10) 
					
					IF _LC111USR // EXISTBLOCK("LC111USR")
						CMSG += EXECBLOCK("LC111USR", .T., .T., {_NTPACE, CACAO}) + CRLF + CRLF
					ENDIF
				
					FOR _NX := 1 TO LEN(_AASLOTE)
						FQ5->(DBGOTO( _AASLOTE[_NX] ))	// RECNO
						IF CACAO == "R"
							CMSG += STR0140 + ALLTRIM(FQ5->FQ5_AS) + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + CRLF //"Referente ao rejeite da AS número "###"PROJETO"
						ELSE
							CMSG += STR0141 + ALLTRIM(FQ5->FQ5_AS) + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + CRLF //"Referente ao aceite da AS número "###"PROJETO"
						ENDIF
						CMSG     += STR0046+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0047+ALLTRIM(FQ5->FQ5_DESTIN)+STR0048+ALLTRIM(FQ5->FQ5_NOMCLI)+"" + CRLF + CRLF //"Data INI/FIM: "###",  Obra: "###",  Cliente: "
					NEXT _NX

				//	IF EXISTBLOCK("LC111ACE") 							// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
				//		EXECBLOCK("LC111ACE" , .T. , .T. , NIL) 
				//	ENDIF

	   				LOCA05909( EFROM, CPARA , CCC, CTITULO, CMSG, NIL, CCCO)
					
					_AASLOTE := {}
				ENDIF

				AADD(_AASLOTE,ALINHA[NI,LEN(ALINHA[NI])])			
		
				_CPRJOLD := ALINHA[NI,5] 		// PROJETO
			ENDIF
		NEXT NI 
			
		IF LEN(_AASLOTE) > 0
			// MANDA E-MAIL
			FQ5->(DBGOTO( _AASLOTE[1] ))		// RECNO
			
			IF CACAO == "R"
				CTITULO := STR0137 + _MV_LOC248 + ": " + ALLTRIM(FQ5->FQ5_SOT) //"Referente ao rejeite da(s) AS(s) - "###"PROJETO"
			ELSE
				IF _LC111TIT //EXISTBLOCK("LC111TIT")
					CTITULO := EXECBLOCK("LC111TIT", .T., .T., {_NTPACE, _CPRJOLD})
				ELSE
					CTITULO := STR0138 + _MV_LOC248 + ": " + ALLTRIM(FQ5->FQ5_SOT) //"Referente ao aceite da(s) AS(s) - "###"PROJETO"
				ENDIF
			ENDIF
			
			CMSG := CTITULO + CHR(13) + CHR(10) + CHR(13) + CHR(10) + CMSG + CHR(13) + CHR(10) 
					
			IF _LC111USR //EXISTBLOCK("LC111USR") 
				CMSG += EXECBLOCK("LC111USR", .T., .T., {_NTPACE, CACAO}) + CRLF + CRLF 
			ENDIF 
				
			FOR _NX := 1 TO LEN(_AASLOTE)
				FQ5->(DBGOTO( _AASLOTE[_NX] )) 	// RECNO
				IF CACAO == "R"
					CMSG += STR0140 + ALLTRIM(FQ5->FQ5_AS) + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + CRLF //"Referente ao rejeite da AS número "###"PROJETO"
				ELSE
					CMSG += STR0141 + ALLTRIM(FQ5->FQ5_AS) + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + CRLF //"Referente ao aceite da AS número "###"PROJETO"
				ENDIF
				CMSG     += STR0046+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0047+ALLTRIM(FQ5->FQ5_DESTIN)+STR0048+ALLTRIM(FQ5->FQ5_NOMCLI)+"" + CRLF //"Data INI/FIM: "###",  Obra: "###",  Cliente: "
			NEXT _NX 

		 //	IF EXISTBLOCK("LC111ACE") 									// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
		 //		EXECBLOCK("LC111ACE" , .T. , .T. , NIL) 
		 //	ENDIF

			LOCA05909( EFROM, CPARA , CCC, CTITULO, CMSG, NIL, CCCO)
		ENDIF 
		
	ENDIF

	IF LNPROG
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   		Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 		{STR0142}) //"Existem ASF sem programação."
	ENDIF
	IF NTOTMIN > 0
		MSGINFO(STR0143 +ALLTRIM(STR(NTOTMIN))+STR0144 , STR0022)  //"Foram geradas "###" minutas."###"Atenção!"
	ENDIF
ENDIF

IF ! EMPTY(CAVISO)
	AVISO(CTITULO,CAVISO,{"OK"},2)
ENDIF

FQ5->(RESTAREA(AAREADTQ))

RETURN .T.



// ======================================================================= \\
STATIC FUNCTION MARCARREGI(LTODOS)
// ======================================================================= \\
// --> FUNÇÃO AUXILIAR DO LISTBOX, SERVE PARA MARCAR E DESMARCAR OS ITENS

LOCAL LMARCADOS := ALINHA[OLBX:NAT,1]
LOCAL LDESMARQ  := .F.
LOCAL LMARK     := .T.
LOCAL LFIRST    := .T.
LOCAL NI        := 0
LOCAL _NXX 
LOCAL _CPAI
Local _MARKREG := EXISTBLOCK("MARKREG")

IF LTODOS
	LMARCADOS := ! LMARCADOS
	FOR NI := 1 TO LEN(ALINHA)
		IF _MARKREG //EXISTBLOCK("MARKREG") 										// --> PONTO DE ENTRADA PARA VERIFICAR SE O REGISTRO QUE ESTÁ SENDO MARCADO ESTÁ DISPONÍVEL.
			LTEM := EXECBLOCK("MARKREG",.T.,.T.,{LTODOS, ALINHA, NI, ASCAN(ALINHA , { |X| X[1] == .T. } ),IIF(LFIRST,.T.,.F.)})
			LFIRST := .F.
			IF !LTEM
	           LMARK := .F.
			ELSE
			   LMARK := .T.
			ENDIF
		ENDIF 
		IF LMARK 
		   ALINHA[NI,1] := LMARCADOS
		ENDIF
	NEXT NI 
	IF LDESMARQ
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   		Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 		{STR0145}) //"Falta preencher a programação. AS não selecionadas."
	ENDIF
ELSE
	IF _MARKREG //EXISTBLOCK("MARKREG") 											// --> PONTO DE ENTRADA PARA VERIFICAR SE O REGISTRO QUE ESTÁ SENDO MARCADO ESTÁ DISPONÍVEL.
		LTEM := EXECBLOCK("MARKREG",.T.,.T.,{LTODOS, ALINHA, OLBX:NAT, ALINHA[OLBX:NAT,1], .F.})
		IF !LTEM
		   MSGSTOP(STR0146 , STR0022)  //"Não é possível marcar esse item, pois o equipamento não está como reservado."###"Atenção!"
		   RETURN ALINHA
		ENDIF
	ENDIF
	ALINHA[OLBX:NAT,1] := ! LMARCADOS

	// FRANK 23/09/2020
	// VERIFICAR SE O PRODUTO MARCADO FAZ PARTE DE UMA ESTRUTURA
	IF SUPERGETMV("MV_LOCX028",,.F.) // PARAMETRO QUE INDICA SE USA O CONCEITO DE ENTRUTURA PAI -> FILHO //"MV_LOCX028"
		IF ALINHA[OLBX:NAT,1]
			FPA->(DBSETORDER(3))
			IF FPA->(DBSEEK(XFILIAL("FPA")+ALINHA[OLBX:NAT,2]))
				IF !EMPTY(FPA->FPA_SEQEST)
					IF MSGYESNO(STR0148,STR0149) //"MARCAR TODOS OS ITENS?"###"ITEM FORMADOR DE UMA ESTRUTURA PAI-FILHO."
						_CPAI := SUBSTR(FPA->FPA_SEQEST,1,3)
						FOR _NXX := 1 TO LEN(ALINHA)
							IF FPA->(DBSEEK(XFILIAL("FPA")+ALINHA[_NXX,2]))
								IF SUBSTR(FPA->FPA_SEQEST,1,3) == _CPAI
									ALINHA[_NXX,1] := .T.
								ENDIF
							ENDIF
						NEXT
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	ENDIF

ENDIF

OLBX:REFRESH()
ODLG:REFRESH()

RETURN NIL



// ======================================================================= \\
STATIC FUNCTION LGERPRG(LCZLG)
// ======================================================================= \\
// --> ROTINA PARA CRIAR AS PROGRAMAÇÕES DE ACESSÓRIOS CONFORME ESPECIFICAÇÕES DA ETG11. 

LOCAL AAREA  := GETAREA()
LOCAL CQUERY := "" 
LOCAL LRET 	 := .T.
LOCAL NJ     := 0 
Local _LC111MSG := EXISTBLOCK("LC111MSG")

IF SELECT("TRAB") > 0
	TRAB->(DBCLOSEAREA())
ENDIF

// --> VERIFICA SE EXISTE ACESSORIOS PADRÕES CONFORME ESPECIFICADO NO CAMPO T9_ACESSOR. 
CQUERY := " SELECT   T9_CODBEM , T9_NOME , T9_CODESTO " 
CQUERY += " FROM " + RETSQLNAME("ST9")
CQUERY += " WHERE    D_E_L_E_T_ = '' "
CQUERY +=   " AND    T9_FILIAL  =  '" + XFILIAL("ST9") + "'"
//CQUERY +=   " AND    T9_CODFA   =  '" + X_CODFA + "'"
CQUERY +=   " AND    T9_SITBEM  <> 'I'"
//CQUERY +=   " AND    T9_ACESSOR =  'P'"
CQUERY += " ORDER BY T9_CODBEM"
TCQUERY CQUERY NEW ALIAS "TRAB"

DBSELECTAREA("TRAB")
TRAB->(DBGOTOP())

DBSELECTAREA("FPO")
DBSETORDER(1)

WHILE TRAB->(!EOF())

	NSALDO  := POSICIONE("SB2",1,XFILIAL("SB2")+TRAB->T9_CODESTO,"B2_QATU")

	IF NSALDO <= 0
		TRAB->(DBSKIP())
		LOOP 	
	ENDIF

	IF SELECT("LTRB") > 0
		LTRB->(DBCLOSEAREA())
	ENDIF

	// --> VERIFICA SE EXISTE PROGRAMAÇÃO DISPONÍVEL PARA O ACESSÓRIO 
	CQRY:= " SELECT R_E_C_N_O_ RECNOZLG"
	CQRY+= " FROM " + RETSQLNAME("FPO")
	CQRY+= " WHERE  D_E_L_E_T_ = '' "
	CQRY+=   " AND  FPO_STATUS = '1' "
	CQRY+=   " AND  FPO_CODBEM = '"+TRAB->T9_CODBEM+"' "
	CQRY+=   " AND (FPO_DTINI BETWEEN '"+DTOS(FQ5->FQ5_DATINI)+"' AND '"+DTOS(FQ5->FQ5_DATFIM)+" '"
	CQRY+=    " OR  FPO_DTFIM BETWEEN '"+DTOS(FQ5->FQ5_DATINI)+"' AND '"+DTOS(FQ5->FQ5_DATFIM)+" '"
	CQRY+=    " OR (FPO_DTINI <= '" +DTOS(FQ5->FQ5_DATINI)+ "' AND FPO_DTFIM >='" +DTOS(FQ5->FQ5_DATFIM)+ "')"
	CQRY+=    " OR (FPO_DTINI >= '" +DTOS(FQ5->FQ5_DATINI)+ "' AND FPO_DTFIM <='" +DTOS(FQ5->FQ5_DATFIM)+ "') )"
	TCQUERY CQRY NEW ALIAS "LTRB"

	WHILE ! LTRB->(EOF())
		FPO->(DBGOTO(LTRB->RECNOZLG))
	
		IF FQ5->FQ5_DATINI <= FPO->FPO_DTINI .AND. FQ5->FQ5_DATFIM >= FPO->FPO_DTFIM	// PROG DISPONÍVEL ABRANGIDA PELA AS
			RECLOCK("FPO",.F.)
			FPO->(DBDELETE())
			FPO->(MSUNLOCK())
			LTRB->(DBSKIP())
			LOOP
		ENDIF

		IF FPO->FPO_DTINI <= FQ5->FQ5_DATINI .AND. FPO->FPO_DTFIM >= FQ5->FQ5_DATFIM	// AS ABRANGIDA PELA PROG DISPONÍVEL
			AREGORI := {} 			// CARREGAR REGISTROS PARA DUPLICAÇÃO
			FOR NJ := 1 TO FPO->(FCOUNT())
				AADD(AREGORI, FPO->(FIELDGET(NJ)) )
			NEXT NJ 
			RECLOCK("FPO",.F.) 		// AJUSTE DO REGISTRO DE DISPONIBILIDADE INICIAL
			FPO->FPO_DTFIM := FQ5->FQ5_DATINI - 1
			FPO->(MSUNLOCK())
		ENDIF

		IF FQ5->FQ5_DATINI <= FPO->FPO_DTINI .AND. FQ5->FQ5_DATFIM >= FPO->FPO_DTINI .AND. FQ5->FQ5_DATFIM <= FPO->FPO_DTFIM	// PROG DISPONÍVEL ABRANGIDA PELA AS PARCIAL, NO INÍCIO
			RECLOCK("FPO",.F.)
			FPO->(DBDELETE()) 		// FPO->FPO_DTINI := FQ5->FQ5_DATFIM + 1	// AJUSTE DA DATA FINAL DO REGISTRO DE DISPONIBILIDADE
			FPO->(MSUNLOCK())
		ENDIF
		
		IF FQ5->FQ5_DATINI >= FPO->FPO_DTINI .AND. FQ5->FQ5_DATINI <= FPO->FPO_DTFIM .AND. FQ5->FQ5_DATFIM >= FPO->FPO_DTFIM	// PROG DISPONÍVEL ABRANGIDA PELA AS PARCIAL, NO FIM
			RECLOCK("FPO",.F.)
			FPO->FPO_DTFIM := FQ5->FQ5_DATINI - 1	// AJUSTE DA DATA FINAL DO REGISTRO DE DISPONIBILIDADE
			FPO->(MSUNLOCK()) 
		ENDIF 

		LTRB->(DBSKIP())
	ENDDO 

	IF SELECT("LTRB") > 0
		LTRB->(DBCLOSEAREA())
	ENDIF

	// VERIFICA SE EXISTE PROGRAMAÇÃO PARA O ACESSÓRIO
	CQRY := " SELECT FPO_FROTA , FPO_STATUS, FPO_DTINI, FPO_DTFIM, R_E_C_N_O_ RECNOZLG"
	CQRY += " FROM " + RETSQLNAME("FPO")
	CQRY += " WHERE  D_E_L_E_T_ = '' "
	CQRY +=   " AND  FPO_STATUS NOT IN ('A','S','E','1') "
	CQRY +=   " AND  FPO_CODBEM = '"+TRAB->T9_CODBEM+"' "
	CQRY +=   " AND  FPO_NRAS <> '' "
	CQRY +=   " AND (FPO_DTINI BETWEEN '"+DTOS(FQ5->FQ5_DATINI)+"' AND '"+DTOS(FQ5->FQ5_DATFIM)+" '"
	CQRY +=    " OR  FPO_DTFIM BETWEEN '"+DTOS(FQ5->FQ5_DATINI)+"' AND '"+DTOS(FQ5->FQ5_DATFIM)+" '"
	CQRY +=    " OR (FPO_DTINI <= '" +DTOS(FQ5->FQ5_DATINI)+ "' AND FPO_DTFIM >='" +DTOS(FQ5->FQ5_DATFIM)+ "')"
	CQRY +=    " OR (FPO_DTINI >= '" +DTOS(FQ5->FQ5_DATINI)+ "' AND FPO_DTFIM <='" +DTOS(FQ5->FQ5_DATFIM)+ "') )"
	TCQUERY CQRY NEW ALIAS "LTRB"

	DBSELECTAREA("LTRB")

	IF LTRB->(EOF())
		FPO->(RECLOCK("FPO",.T.))
		FPO->FPO_FILIAL := XFILIAL("FPO") 
		FPO->FPO_FROTA  := CFROTA
		FPO->FPO_CODCLI := CCODCLI                                                           	// INCLUSAO CJDECAMPOS 13/09/2011
		FPO->FPO_LOJA   := CLOJCLI                                                            	// INCLUSAO CJDECAMPOS 13/09/2011
		FPO->FPO_NOMCLI := POSICIONE("SA1",1,XFILIAL("SA1")+CCODCLI+CLOJCLI,"A1_NOME")       	// INCLUSAO CJDECAMPOS 13/09/2011
		FPO->FPO_LOCAL	:= ALLTRIM(POSICIONE("SA1",1,XFILIAL("SA1")+CCODCLI+CLOJCLI,"A1_NREDUZ"))+" / "+ALLTRIM(FQ5->FQ5_DESTIN) 
		FPO->FPO_NRAS   := FQ5->FQ5_AS
		FPO->FPO_CODBEM := TRAB->T9_CODBEM
		FPO->FPO_DESCAC := TRAB->T9_NOME
		FPO->FPO_DTINI  := FQ5->FQ5_DATINI
		FPO->FPO_DTFIM  := FQ5->FQ5_DATFIM
		FPO->FPO_PROJET := FQ5->FQ5_SOT						// NUMERO DO PROJETO
		FPO->FPO_OBRA   := FQ5->FQ5_OBRA
		FPO->FPO_VIAGEM := FQ5->FQ5_VIAGEM
		FPO->FPO_QTACES := 1								// ALTERADO CJDECAMPOS 13/09/2011
		FPO->FPO_STATUS := "R"
		FPO->FPO_COMPR  := ROUND(VAL(SUBSTR("0"+POSICIONE("STB",1,XFILIAL("STB")+TRAB->T9_CODBEM+"000002","TB_DETALHE"),1,5)),2)
		FPO->FPO_LARGUR := ROUND(VAL(SUBSTR("0"+POSICIONE("STB",1,XFILIAL("STB")+TRAB->T9_CODBEM+"000003","TB_DETALHE"),1,5)),2)
		FPO->FPO_ALTURA := ROUND(VAL(SUBSTR("0"+POSICIONE("STB",1,XFILIAL("STB")+TRAB->T9_CODBEM+"000001","TB_DETALHE"),1,5)),2)
		FPO->FPO_PESO   := ROUND(VAL(SUBSTR("0"+POSICIONE("STB",1,XFILIAL("STB")+TRAB->T9_CODBEM+"000004","TB_DETALHE"),1,5)),2)
		//FPO->FPO_CODFAN := ST9->T9_CODFA
		FPO->(MSUNLOCK()) 
  	ELSE
		IF _LC111MSG //EXISTBLOCK("LC111MSG")
			LRET := EXECBLOCK("LC111MSG",.T.,.T.,)
		ENDIF
		FPO->(DBGOTO(LTRB->RECNOZLG))
		IF LRET
  			XMSG := STR0150+TRAB->T9_CODBEM+STR0151+CVALTOCHAR(FQ5->FQ5_DATINI)+ STR0064+CVALTOCHAR(FQ5->FQ5_DATFIM) //"O acessório "###" não foi programado pois já existe programação entre "###" até "
			XMSG += STR0152 + FPO->FPO_NRAS + STR0153 + DTOC(FPO->FPO_DTINI) + STR0154 + DTOC(FPO->FPO_DTFIM) //". AS: "###" de: "###" até: "
			AVISO(STR0155, XMSG, {"OK"},2) //"Acessório não programado"
		ENDIF
	ENDIF

	TRAB->(DBSKIP()) 

ENDDO

// --> CHAMADA DA FUNÇÃO FDOZLG PARA CRIAÇÃO DOS ACESSÓRIOS ROTATIVOS
LOCA05912(CFROTA) 

IF SELECT("TRAB") > 0
	TRAB->(DBCLOSEAREA())
ENDIF

RESTAREA( AAREA )

RETURN NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ LOAA      º AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ FUNÇÃO QUE IRÁ VERIFICAR SE A EXISTE PROGRAMAÇÃO DIÁRIA    º±±
±±º          ³ QUE ENCAVALA COM A FROTA REFERENTE A DATA INICIAL E FINAL. º±±
±±º          ³                                                            º±±
±±ºPARAMENTRO³ CFROTA (CARACTER)                                          º±±
±±º          ³ DTINI  (CARACTER) AAAAMMDD                                 º±±
±±º          ³ DTFIM  (CARACTER) AAAAMMDD                                 º±±
±±º          ³                                                            º±±
±±ºRETORNO   ³ LOGICO : .T. NÃO EXISTE ENCAVALAMENTO DE PROGRAMAÇÃO       º±±
±±º          ³          .F. EXISTE ENCAVALAMENTO DE PROGRAMAÇÃO           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LOCA05917(CFROTA,CNRAS, DTINI ,DTFIM ,CCODBEM,XEXCLUSAO, CHRINI, CHRFIM)

LOCAL LRET        := .T.  
LOCAL CPROJ	      := ""
LOCAL CQRY1 , CQRY2
LOCAL AAREA       := GETAREA()
Local _MV_LOC248 := SUPERGETMV("MV_LOCX248",.F.,STR0044)

DEFAULT CNRAS	  := SPACE(21)
DEFAULT CCODBEM   := "" 
DEFAULT XEXCLUSAO := "'A','E','S','9','C','9'"
DEFAULT CHRINI    := "0000"
DEFAULT CHRFIM    := "2400"

CHRINI := ALLTRIM( CHRINI )
CHRFIM := ALLTRIM( CHRFIM )

IF SELECT("NFRO") > 0                     
	NFRO->(DBCLOSEAREA())
ENDIF

CQRY1:= " SELECT FQ5_ACEITE, FQ5_AS "
CQRY1+= " FROM "+RETSQLNAME("FQ5")
CQRY1+= " WHERE  D_E_L_E_T_ = '' "
CQRY1+=   " AND  FQ5_GUINDA = '"+CFROTA+"'"
CQRY1+=   " AND  FQ5_AS = '"+CNRAS+"'"
TCQUERY CQRY1 NEW ALIAS "NFRO"

DBSELECTAREA("NFRO")

IF SELECT("LOAS") > 0
	LOAS->(DBCLOSEAREA())
ENDIF

CQRY2         := " SELECT FPO_STATUS , FPO_NRAS , FPO_PROJET , FPO_DTINI , FPO_HRINI , FPO_HRFIM " 
CQRY2         += " FROM "+RETSQLNAME("FPO")+ " ZLG "
CQRY2         += " WHERE  D_E_L_E_T_ = '' "
CQRY2         +=   " AND  FPO_FILIAL = '"+XFILIAL("FPO")+"' "
IF EMPTY(NFRO->FQ5_AS) 		// SE NAO TEM AS
	CQRY2     +=   " AND  FPO_STATUS NOT IN ('A','E','S') "
ELSE
	IF EMPTY(NFRO->FQ5_ACEITE)
		CQRY2 +=   " AND  FPO_STATUS NOT IN ('A','E','S','C','9') "
	ELSE
		CQRY2 +=   " AND  FPO_STATUS NOT IN ("+XEXCLUSAO+")"
		CQRY2 +=   " AND  FPO_NRAS <> '"+NFRO->FQ5_AS+"' "
	ENDIF 
ENDIF
IF EMPTY(CCODBEM)	
	CQRY2     +=   " AND  FPO_FROTA = '"+CFROTA+"' " 
	CQRY2     +=   " AND  FPO_CODBEM = '' "
	IF !EMPTY(CNRAS) 		// SE NAO TEM AS
		CQRY2 +=   " AND  FPO_NRAS != '" + CNRAS + "' " 
	ENDIF 
ELSE
	CQRY2     +=   " AND  FPO_CODBEM = '"+CCODBEM+"' " 	
ENDIF
/*
// --> PELA DATA
CQRY2         +=   " AND (FPO_DTINI BETWEEN '" + DTINI + "' AND '" + DTFIM + "'"
CQRY2         +=    " OR  FPO_DTFIM BETWEEN '" + DTINI + "' AND '" + DTFIM + "'"
CQRY2         +=    " OR (FPO_DTINI <= '" + DTINI + "' AND FPO_DTFIM >='" + DTFIM + "')"
CQRY2         +=    " OR (FPO_DTINI >= '" + DTINI + "' AND FPO_DTFIM <='" + DTFIM + "'))"
// --> PELA HORA
CQRY2         +=   " AND (FPO_HRINI BETWEEN '" + CHRINI + "' AND '" + CHRFIM + "'"
CQRY2         +=    " OR  FPO_HRFIM BETWEEN '" + CHRINI + "' AND '" + CHRFIM + "'"
CQRY2         +=    " OR (FPO_HRINI <= '" + CHRINI + "' AND FPO_HRFIM >='" + CHRFIM + "')"
CQRY2         +=    " OR (FPO_HRINI >= '" + CHRINI + "' AND FPO_HRFIM <='" + CHRFIM + "'))"
CQRY2         += " ORDER BY FPO_DTINI, FPO_HRINI"
TCQUERY CQRY2 NEW ALIAS "LOAS"
*/
CQRY2     += " AND ( ( ZLG.FPO_DTINI BETWEEN '" + DTINI + "' AND '" + DTFIM + "' AND ZLG.FPO_HRINI > '" + CHRINI + "' AND FPO_HRINI < '" + CHRFIM + "' ) "
CQRY2     += " OR    ( ZLG.FPO_DTFIM BETWEEN '" + DTINI + "' AND '" + DTFIM + "' AND ZLG.FPO_HRFIM > '" + CHRINI + "' AND FPO_HRFIM < '" + CHRFIM + "' ) "
CQRY2     += " OR    ( ZLG.FPO_DTINI <= '" + DTINI + "' AND ZLG.FPO_DTFIM >='" + DTFIM + "' AND ZLG.FPO_HRINI < '" + CHRINI + "' AND FPO_HRFIM > '" + CHRFIM + "' )"
CQRY2     += " OR    ( ZLG.FPO_DTINI >= '" + DTINI + "' AND ZLG.FPO_DTFIM <='" + DTFIM + "' AND ZLG.FPO_HRINI > '" + CHRINI + "' AND FPO_HRFIM < '" + CHRFIM + "' ))"
CQRY2 += " ORDER BY ZLG.FPO_DTINI, ZLG.FPO_HRINI"
TCQUERY CQRY2 NEW ALIAS "LOAS"

DBSELECTAREA("LOAS") 

WHILE LOAS->(!EOF())
	IF LOAS->FPO_STATUS <> '1'  
		CPROJ += STR0156 + ALLTRIM(LOAS->FPO_NRAS) + " - " + _MV_LOC248 + ": " + ALLTRIM(LOAS->FPO_PROJET) + " - " + DTOC(STOD( LOAS->FPO_DTINI )) + " DAS " + TRANSFORM(LOAS->FPO_HRINI, "@R 99:99" ) + " AS " + TRANSFORM(LOAS->FPO_HRFIM, "@R 99:99" ) + CRLF //"AS:"###"PROJETO"
		LRET := .F.
	ENDIF
	LOAS->(DBSKIP())
ENDDO 

IF ! LRET
	CPROJ := STR0157+DTOC(STOD(DTINI))+STR0064+DTOC(STOD(DTFIM)) + STR0158 + CRLF + CPROJ //"No intervalo de :"###" até "###" existem programações"
	Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   	Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 	{STR0159+CFROTA+STR0160+CPROJ+"]" }) //"Conflito de programação do bem: ["###"]  -  Projeto: ["
ENDIF

IF SELECT("NFRO") > 0 
	NFRO->(DBCLOSEAREA())
ENDIF

IF SELECT("LOAS") > 0 
	LOAS->(DBCLOSEAREA())
ENDIF

RESTAREA( AAREA )

RETURN LRET  



// ======================================================================= \\
FUNCTION LOCA05918()
// ======================================================================= \\

LOCAL CQUERY  := "" 
LOCAL LRET    := .T. 
LOCAL CVIAORI := "" 
LOCAL CMSGALE := "" 

IF EMPTY( CPACLIS )						// PERMITIR PASSAR EM BRANCO - "Nº DA CARRETA:"
	RETURN .T. 
ENDIF 

CPACLIS := STRZERO( VAL(CPACLIS), 3)	// TIREI DA LINHA DO MSGET E TROUXE PRA CÁ.

// --> VERIFICA A PACKLIST PODERÁ SER UTILIZADA.
IF SELECT ("TMP") > 0
	TMP->(DBCLOSEAREA())
ENDIF

CQUERY+= " SELECT * "
CQUERY+= " FROM "+RETSQLNAME("FPS")+" ZLW (NOLOCK) " 
CQUERY+=        " INNER JOIN "+RETSQLNAME("FPO")+" ZLG (NOLOCK) ON ZLG.D_E_L_E_T_ = ''  AND  FPO_VIAGEM = FPS_VIAORI " 
CQUERY+= " WHERE  ZLW.D_E_L_E_T_ = ''  AND  FPS_VIAGEM = '"+FQ5->FQ5_VIAGEM+"' " 
TCQUERY CQUERY NEW ALIAS "TMP" 

DBSELECTAREA("TMP")	
CVIAORI := TMP->FPS_VIAORI 
IF TMP->(EOF())
	LRET    := .F. 
	CMSGALE := STR0161+FQ5->FQ5_VIAGEM+STR0162  //"Não foi localizada a viagem ["###"] nas tabelas de Prog. diário de equipamentos X Conj. transp. equipamentos."
ELSE 
	WHILE TMP->(!EOF()) 
		IF CPACLIS = TMP->FPO_CARRET 
			LRET    := .T. 
			CMSGALE := "" 
			EXIT 
		ENDIF 
		CMSGALE := STR0163+ALLTRIM(CPACLIS)+STR0164+ALLTRIM(TMP->FPO_NRAS)+STR0165+ALLTRIM(TMP->FPO_VIAGEM)+"]."  //"O 'Nº da carreta:' informado ["###"] não está vinculado no campo 'CARRETA' (FPO_CARRET) da A.S. ["###"] / Viagem ["
		LRET    := .F. 
		TMP->(DBSKIP())
	ENDDO 
ENDIF

// --> VERIFICA A PACKLIST PODERÁ SER UTILIZADA
IF SELECT ("TMP") > 0
	TMP->(DBCLOSEAREA())
ENDIF

CQUERY  := " SELECT * " 
CQUERY  += " FROM "+RETSQLNAME("FQ7")+" ZUC "
CQUERY  += "        INNER JOIN "+RETSQLNAME("FPO")+" ZLG ON ZLG.D_E_L_E_T_ = '' AND FPO_VIAGEM = FQ7_VIAORI "
CQUERY  += " WHERE  ZUC.D_E_L_E_T_ = '' "
CQUERY  += "   AND  FQ7_VIAGEM = '"+FQ5->FQ5_VIAGEM+"' "
TCQUERY CQUERY NEW ALIAS "TMP"
DBSELECTAREA("TMP")	

CVIAORI := TMP->FQ7_VIAORI

IF SELECT ("TMP") > 0 
	TMP->(DBCLOSEAREA()) 
ENDIF 

IF ! LRET
	MSGINFO("Packing list não mencionada na programação! " + CHR(13)+CHR(10) + ; 
	        CMSGALE , "Atenção!") 
	LRET := .F. 
ENDIF 

RETURN LRET 



// ======================================================================= \\
STATIC FUNCTION LOCQ111(CFROTA , CNRAS , DTINI , DTFIM , CCODBEM) 
// ======================================================================= \\

LOCAL LRET := .F.

IF SELECT("LOFRO2") > 0
	LOFRO2->(DBCLOSEAREA())
ENDIF 

CQRY2:= " SELECT  COUNT(*) CONTA "
CQRY2+= " FROM "+RETSQLNAME("FPO")
CQRY2+= " WHERE   D_E_L_E_T_ = '' "             
CQRY2+= " 	AND   FPO_FROTA = '"+CFROTA+"' " 
CQRY2+= " 	AND   FPO_CODBEM = '' " 
CQRY2 += "  AND  (FPO_DTINI BETWEEN '" + (DTINI) + "' AND '" + (DTFIM) + "'"
CQRY2 += "   OR   FPO_DTFIM BETWEEN '" + (DTINI) + "' AND '" + (DTFIM) + "'"
CQRY2 += "   OR  (FPO_DTINI <= '" + (DTINI) + "' AND FPO_DTFIM >='" + (DTFIM) + "')"
CQRY2 += "   OR  (FPO_DTINI >= '" + (DTINI) + "' AND FPO_DTFIM <='" + (DTFIM) + "'))"

TCQUERY CQRY2 NEW ALIAS "LOFRO2"

DBSELECTAREA("LOFRO2") 

IF LOFRO2->CONTA > 0
	LRET := .T.
ENDIF

RETURN LRET



// ======================================================================= \\
STATIC FUNCTION VALIDAS(CPROJ , COBRA , CJUNTO) 
// ======================================================================= \\

LOCAL AAREA    := GETAREA()
LOCAL AAREADTQ := FQ5->(GETAREA())
LOCAL LRET     := .T.
	
DBSELECTAREA("FQ5")
DBSETORDER(8)
IF DBSEEK(XFILIAL("FQ5")+CPROJ+COBRA)
	WHILE !FQ5->(EOF()) .AND. ALLTRIM(FQ5->FQ5_SOT) == ALLTRIM(CPROJ) .AND. ALLTRIM(FQ5->FQ5_OBRA) == ALLTRIM(COBRA) .AND. ALLTRIM(FQ5->FQ5_SEQCAR) == ALLTRIM(CJUNTO)
		IF !EMPTY(FQ5->FQ5_JUNTO)
			FQ5->(DBSKIP())
			LOOP			
		ENDIF 	
  			
		IF EMPTY(FQ5->FQ5_DATFEC) .AND.  EMPTY(FQ5->FQ5_DATENC) .AND. FQ5->FQ5_STATUS == "1" //EM ABERTO
			LRET := .F.
			EXIT							
		ENDIF
		
		IF !EMPTY(FQ5->FQ5_DATENC) .AND. !EMPTY(FQ5->FQ5_DATENC) .AND. FQ5->FQ5_STATUS == "1" //ENCERRADO
			LRET := .F.
			EXIT							
		ENDIF
		
		IF !FQ5->FQ5_STATUS $ "1/6" //REJEITADO
			LRET := .F.
			EXIT							
		ENDIF 
		
		FQ5->(DBSKIP())
	ENDDO
	IF !LRET          
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   		Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 		{STR0166+FQ5->FQ5_AS+STR0167}) //"Não é possível aceitar a AS, pois a AS pai '"###"' não foi aceita."
	ENDIF 
ENDIF
	
RESTAREA(AAREA)
RESTAREA(AAREADTQ)

RETURN LRET



// ======================================================================= \\
STATIC FUNCTION XMOTORISTA(DDTINI,DDTFIM,CAS,CNOMCLI,CSOT,COBRA,CVIAGEM,LREVIS,CSEQCAR)
// ======================================================================= \\

LOCAL CCOD	:= SPACE(6)
LOCAL LRET	:= .T.
    
DEFINE MSDIALOG ODLGUSER TITLE STR0168 FROM 000,000 TO 120,300 PIXEL OF OMAINWND //"Motorista"
	@ 010,010 SAY    STR0169 OF ODLGUSER PIXEL  //"Informe o código do motorista para geração da frota."
	@ 030,010 MSGET  CCOD F3 "DA4" SIZE 80,10 PIXEL OF ODLGUSER 
	@ 030,100 BUTTON STR0170   SIZE 35,14 PIXEL OF ODLGUSER ACTION (PROCESSA({|| GERAFROTA(CCOD,DDTINI,DDTFIM,CAS,CNOMCLI,CSOT,COBRA,CVIAGEM,LREVIS,CSEQCAR) })) //"Confirmar"
ACTIVATE MSDIALOG ODLGUSER CENTERED 
	
RETURN(LRET)



// ======================================================================= \\
STATIC FUNCTION GERAFROTA(CCOD,DDTINI,DDTFIM,CAS,CNOMCLI,CSOT,COBRA,CVIAGEM,LREVIS,CSEQCAR)
// ======================================================================= \\

LOCAL AAREA    := GETAREA()
LOCAL AAREADA4 := DA4->(GETAREA())
LOCAL AAREAZLO := FPQ->(GETAREA())
LOCAL AAREAST9 := ST9->(GETAREA())
LOCAL AAREAZAE := FP8->(GETAREA())
LOCAL AAREAZLE := FPM->(GETAREA())
//LOCAL AAREAZA6 := ZA6->(GETAREA())
LOCAL LEXIT    := .F.
LOCAL DDATAINI := DDTINI
LOCAL ADELET   := {}
LOCAL AINSERT  := {} 
LOCAL CFROTA   := "" 
LOCAL CNOMMOT  := "" 
LOCAL LPULA    := .F. 
LOCAL NX       := 0 
LOCAL DDIA     := 0 
	
DBSELECTAREA("DA4")
DBSETORDER(1)
IF DBSEEK(XFILIAL("DA4")+CCOD) .AND. !EMPTY(CCOD)

	CNOMMOT := DA4->DA4_NOME			// INTEGRAÇÃO DIÁRIO DE BORDO / OCORRÊNCIAS

	DBSELECTAREA("FQA")
	DBSETORDER(1)
	DBSEEK(XFILIAL("FQA")+CVIAGEM)
	WHILE !FQA->(EOF()) .AND. FQA->FQA_VIAGEM == CVIAGEM
		RECLOCK("FQA",.F.) 
		FQA->FQA_NOMMOT := CNOMMOT                 
		FQA->(MSUNLOCK()) 
		FQA->(DBSKIP())
	ENDDO

	IF !EMPTY(DA4->DA4_MAT)
		CNOMMOT := DA4->DA4_NOME
		IF !LREVIS
			WHILE !LEXIT
				IF DTOS(DDATAINI) > DTOS(DDTFIM)	
					LEXIT := .T.    
					LOOP
				ENDIF
        		
				DBSELECTAREA("FPQ")
				DBSETORDER(1)
				IF DBSEEK(XFILIAL("FPQ")+DA4->DA4_MAT+DTOS(DDATAINI))
					WHILE !FPQ->(EOF()) .AND. ALLTRIM(FPQ->FPQ_MAT) == ALLTRIM(DA4->DA4_MAT) .AND. DTOS(DDATAINI) == DTOS(FPQ->FPQ_DATA)
						IF ALLTRIM(FPQ->FPQ_TIPINC) == "M"
							FPQ->(DBSKIP())
							LOOP
						ENDIF
						AADD(ADELET, FPQ->(RECNO()) )
						AADD(AINSERT,{DA4->DA4_MAT,DDATAINI,CAS,CNOMCLI,CSOT,COBRA})					
						DDATAINI++	           
						FPQ->(DBSKIP()) 
	        		ENDDO 
        		ELSE 
	        		RECLOCK("FPQ",.T.)
					FPQ->FPQ_FILIAL := XFILIAL("FPQ")
					FPQ->FPQ_MAT 	:= DA4->DA4_MAT
					FPQ->FPQ_DATA 	:= DDATAINI
					FPQ->FPQ_AGENDA := "2"
					FPQ->FPQ_STATUS := "OBRA"
					FPQ->FPQ_AS 	:= CAS
					FPQ->FPQ_DESC 	:= CNOMCLI
					FPQ->FPQ_PROJET := CSOT
					FPQ->FPQ_OBRA 	:= COBRA
					FPQ->FPQ_FILMAT := XFILIAL("FPQ")
					FPQ->FPQ_TIPINC := "A"
					FPQ->(MSUNLOCK()) 
				ENDIF
	        			
		   		DDATAINI++ 
    		ENDDO
	        				
	        IF LEN(ADELET) > 0
	        	FOR NX := 1 TO LEN(ADELET)
	        		DBSELECTAREA("FPQ")
			    	DBGOTO(ADELET[NX])
				    WHILE !RECLOCK("FPQ",.F.)
				    ENDDO
					DBDELETE()
				    MSUNLOCK() 
	        	NEXT NX
	        ENDIF
		        
	        IF LEN(AINSERT) > 0
	        	FOR NX := 1 TO LEN(AINSERT)
	        		DBSELECTAREA("FPQ")
					RECLOCK("FPQ",.T.)
					FPQ->FPQ_FILIAL := XFILIAL("FPQ")
					FPQ->FPQ_MAT 	:= AINSERT[NX][1]
					FPQ->FPQ_DATA 	:= AINSERT[NX][2]
					FPQ->FPQ_AGENDA := "2"
					FPQ->FPQ_STATUS := "OBRA"
					FPQ->FPQ_AS 	:= AINSERT[NX][3]
					FPQ->FPQ_DESC 	:= AINSERT[NX][4]
					FPQ->FPQ_PROJET := AINSERT[NX][5]
					FPQ->FPQ_OBRA 	:= AINSERT[NX][6]
					FPQ->FPQ_FILMAT := XFILIAL("FPQ")
					FPQ->FPQ_TIPINC := "A"
					FPQ->(MSUNLOCK()) 
	        	NEXT NX
	        ENDIF 
	    ELSE
	    	VALIDZLO(CAS,CNOMCLI,CSOT,COBRA,DDTINI,DDTFIM)	
	    ENDIF
    ENDIF
ENDIF
    
ST9->(DBSETORDER(1))
FP8->(DBSETORDER(1))
FPM->(DBSETORDER(1)) 								// FPM_FILIAL+ ANOMES + FPM_FROTA+ FPM_DTPROG
    
// POSICIONAR NA ZAE APARTIR DA DTQ OBRA PROJETO E SEQCAR E GERR CORRETAMENTE A ZLE
IF FP0->FP0_TIPOSE == "E" 							// SE O PROJETO FOR DE EQUIPAMENTO.

	DBSELECTAREA("FP4") 
	DBSETORDER(3) 
	IF DBSEEK(XFILIAL("FP4")+FQ5->FQ5_AS+FQ5->FQ5_VIAGEM)		

		DBSELECTAREA("FPM")
	    DBSETORDER(5)
	    DBSEEK(XFILIAL("FPM")+FP4->FP4_GUINDA)
	    
	    CFROTA := FP4->FP4_GUINDA  
	    
	    ST9->(DBSEEK(XFILIAL("ST9")+CFROTA))
		
		IF LREVIS 									// SE FOR ACEITA DE AS PELA 2º VEZ
			DELETEZLE(DDTINI,DDTFIM,CCOD,CNOMMOT,CFROTA,ST9->T9_NOME)
		ELSE
			FOR DDIA := DDTINI TO DDTFIM
				FPM->(MSSEEK(XFILIAL("FPM")+SUBSTR(DTOS( DDIA ),1,6) + CFROTA + DTOS( DDIA ))) 
				
				IF FPM->(FOUND()) 
					IF FPM->FPM_STATUS $ "8|9|M" 	// PULAR 8,9,M
						LPULA := .T.						
					ENDIF 
				ENDIF
					
				IF !LPULA
					FPM->(RECLOCK("FPM", !FPM->(FOUND())))
					FPM->FPM_FILIAL	:= XFILIAL("FPM")
					FPM->FPM_ANOMES := LEFT( DTOS( DDIA ) , 6 )
					FPM->FPM_DTPROG := DDIA
					FPM->FPM_DIASEM := DIASEMANA(DDIA)
					FPM->FPM_FROTA  := CFROTA
					FPM->FPM_CODBEM := ""
					FPM->FPM_DESCRI := ST9->T9_NOME
					FPM->FPM_AS     := CAS 			// FQ5->FQ5_AS
					FPM->FPM_PROJET := CSOT 		// FQ5->FQ5_SOT  // NUMERO DO PROJETO
					FPM->FPM_OBRA   := COBRA 		// FQ5->FQ5_OBRA
					FPM->FPM_VIAGEM := CVIAGEM 		// FQ5->FQ5_VIAGEM 
					FPM->FPM_TIPO   := "T" 			// FQ5->FQ5_TPAS
					FPM->FPM_STATUS := "R"    
					FPM->FPM_HORA	:= TIME()
					FPM->FPM_CODMOT	:= CCOD
					FPM->FPM_NOMMOT	:= CNOMMOT
					FPM->(MSUNLOCK()) 
				ENDIF
				LPULA := .F. 
			NEXT
		ENDIF
	ENDIF

ELSE

	DBSELECTAREA("FP8")
	DBSETORDER(1) 									// PROJET+OBRA+SEQTRA+SEQCAR
	DBSEEK(XFILIAL("FP8")+CSOT+COBRA+COBRA+CSEQCAR)
	    
    WHILE !FP8->(EOF()) .AND. ALLTRIM(FP8->FP8_FILIAL+FP8->FP8_PROJET+FP8->FP8_OBRA+FP8->FP8_SEQTRA+FP8->FP8_SEQCAR) == ALLTRIM(XFILIAL("FP8")+CSOT+COBRA+COBRA+CSEQCAR)
    	
    	CFROTA := IIF(!EMPTY(FP8->FP8_TRALOC), FP8->FP8_TRALOC, FP8->FP8_TRANSP)

		IF EMPTY(CFROTA) .OR. !ST9->(DBSEEK(XFILIAL("ST9")+CFROTA))
			FP8->(DBSKIP())
			LOOP
		ENDIF
            
		IF LREVIS 									// SE FOR ACEITA DE AS PELA 2º VEZ
			DELETEZLE(DDTINI,DDTFIM,CCOD,CNOMMOT,CFROTA,ST9->T9_NOME)
		ELSE
			FOR DDIA := DDTINI TO DDTFIM
				FPM->(MSSEEK(XFILIAL("FPM")+SUBSTR(DTOS( DDIA ),1,6) + CFROTA + DTOS( DDIA ))) 
				IF FPM->(FOUND()) 
					IF FPM->FPM_STATUS $ "8|9|M" 	// PULAR 8,9,M
						LPULA := .T.						
					ENDIF 
				ENDIF
				IF !LPULA
					FPM->(RECLOCK("FPM", !FPM->(FOUND())))
					FPM->FPM_FILIAL	:= XFILIAL("FPM")
					FPM->FPM_ANOMES := LEFT( DTOS( DDIA ) , 6 )
					FPM->FPM_DTPROG := DDIA
					FPM->FPM_DIASEM := DIASEMANA(DDIA)
					FPM->FPM_FROTA  := CFROTA
					FPM->FPM_CODBEM := ""
					FPM->FPM_DESCRI := ST9->T9_NOME
					FPM->FPM_AS     := CAS 			// FQ5->FQ5_AS
					FPM->FPM_PROJET := CSOT 		// FQ5->FQ5_SOT  // NUMERO DO PROJETO
					FPM->FPM_OBRA   := COBRA 		// FQ5->FQ5_OBRA
					FPM->FPM_VIAGEM := CVIAGEM 		// FQ5->FQ5_VIAGEM 
					FPM->FPM_TIPO   := "T" 			// FQ5->FQ5_TPAS
					FPM->FPM_STATUS := "R"    
					FPM->FPM_HORA	:= TIME()
					FPM->FPM_CODMOT	:= CCOD
					FPM->FPM_NOMMOT	:= CNOMMOT
					FPM->(MSUNLOCK()) 
				ENDIF 
				LPULA := .F.		 
			NEXT 
		ENDIF 
	
		FP8->(DBSKIP())	
    ENDDO 

ENDIF
	
ODLGUSER:END()
    
RESTAREA(AAREA)
RESTAREA(AAREADA4)
RESTAREA(AAREAZLO)
RESTAREA(AAREAST9)
RESTAREA(AAREAZAE)
RESTAREA(AAREAZLE)
//RESTAREA(AAREAZA6)

RETURN NIL



// ======================================================================= \\
STATIC FUNCTION DELETEZLE(DDTINI, DDTFIM, CCOD, CNOMMOT, CFROTA, CT9NOME) 
// ======================================================================= \\

LOCAL AAREA    := GETAREA()
LOCAL AAREAZLE := FPM->(GETAREA())
LOCAL ADELET   := {}
LOCAL AINSERT  := {}
LOCAL DDIA     := 0 
LOCAL NX       := 0 
	
DBSELECTAREA("FPM")
DBSETORDER(6)
DBSEEK(XFILIAL("FPM")+FQ5->FQ5_SOT+FQ5->FQ5_OBRA+FQ5->FQ5_VIAGEM)

WHILE !FPM->(EOF()) .AND. ALLTRIM(FPM->FPM_PROJET+FPM->FPM_OBRA+FPM->FPM_VIAGEM) == ALLTRIM(FQ5->FQ5_SOT+FQ5->FQ5_OBRA+FQ5->FQ5_VIAGEM)
	IF ALLTRIM(FPM->FPM_FROTA) != ALLTRIM(CFROTA)
		FPM->(DBSKIP())	
		LOOP
	ENDIF
			
	IF DTOS(FPM->FPM_DTPROG) < DTOS(FQ5->FQ5_DATINI) .OR. DTOS(FPM->FPM_DTPROG) > DTOS(FQ5->FQ5_DATFIM)
   		IF ALLTRIM(FPM->FPM_STATUS) $ "R/3/1/4/5/2/7/6"
			AADD(ADELET, FPM->(RECNO())) 
		ENDIF 
	ENDIF 
	
	FPM->(DBSKIP())
ENDDO
	
FOR DDIA := DDTINI TO DDTFIM
	DBSELECTAREA("FPM")
	DBSETORDER(1)
	IF DBSEEK(XFILIAL("FPM")+SUBSTR(DTOS( DDIA ),1,6)+CFROTA+DTOS( DDIA ))
		IF FPM->FPM_STATUS $ "1" //PULAR 8,9,M
			AADD(ADELET,FPM->(RECNO()))
			AADD(AINSERT,{DDIA})
		ENDIF 
	ELSE
	 	AADD(AINSERT,{DDIA})
	ENDIF
NEXT DDIA

FOR NX := 1 TO LEN(ADELET) 
	DBSELECTAREA("FPM") 
	DBGOTO(ADELET[NX]) 
    WHILE !RECLOCK("FPM",.F.) 
    ENDDO 
	DBDELETE()
    MSUNLOCK()			    
NEXT NX  
	
FOR NX := 1 TO LEN(AINSERT) 
	FPM->(RECLOCK("FPM",.T.)) 
	FPM->FPM_FILIAL	:= XFILIAL("FPM") 
	FPM->FPM_ANOMES := LEFT( DTOS(AINSERT[NX][1]) , 6 ) 
	FPM->FPM_DTPROG := AINSERT[NX][1]
	FPM->FPM_DIASEM := DIASEMANA(AINSERT[NX][1])
	FPM->FPM_FROTA  := CFROTA
	FPM->FPM_CODBEM := ""
	FPM->FPM_DESCRI := CT9NOME
	FPM->FPM_AS     := FQ5->FQ5_AS
	FPM->FPM_PROJET := FQ5->FQ5_SOT 	// NUMERO DO PROJETO
	FPM->FPM_OBRA   := FQ5->FQ5_OBRA
	FPM->FPM_VIAGEM := FQ5->FQ5_VIAGEM 
	FPM->FPM_TIPO   := "T" 				//FQ5->FQ5_TPAS
	FPM->FPM_STATUS := "R"    
	FPM->FPM_HORA	:= TIME()
	FPM->FPM_CODMOT	:= CCOD
	FPM->FPM_NOMMOT	:= CNOMMOT
	FPM->(MSUNLOCK())					 	
NEXT NX 
	
RESTAREA(AAREA) 
RESTAREA(AAREAZLE) 

RETURN 



// ======================================================================= \\
STATIC FUNCTION VALIDZLO(CAS , CNOMCLI , CSOT , COBRA , DDTINI , DDTFIM) 
// ======================================================================= \\
// --> GRAVA TODOS OS ZLE E OU ZLO NUM ARRAY ... DEPOIS RODA O NOVO PERIODO E COMPARA COM O PERIDO DO ARRAY(ANTERIOR), E FAZ A VALIDAÇÃO
LOCAL AAREA		:= GETAREA()
LOCAL AAREAZLO	:= FPQ->(GETAREA())
LOCAL ADELET	:= {}
LOCAL AINSERT	:= {}
LOCAL CMAT		:= ""
LOCAL DDIA      := 0 
LOCAL NX        := 0 

DBSELECTAREA("FPQ")
DBSETORDER(3)
DBSEEK(XFILIAL("FPQ")+CSOT+COBRA)
CMAT := DA4->DA4_MAT
WHILE !FPQ->(EOF()) .AND. ALLTRIM(FPQ->FPQ_PROJET+FPQ->FPQ_OBRA) == ALLTRIM(CSOT+COBRA)
	IF ALLTRIM(DA4->DA4_MAT) != ALLTRIM(CMAT) 
		FPQ->(DBSKIP()) 
		LOOP 
	ENDIF 
	IF ALLTRIM(FPQ->FPQ_TIPINC) == "M"
		FPQ->(DBSKIP())
		LOOP
	ENDIF 
	IF DTOS(FPQ->FPQ_DATA) < DTOS(DDTINI) .OR. DTOS(FPQ->FPQ_DATA) > DTOS(DDTFIM) 
		AADD(ADELET,FPQ->(RECNO())) 
	ENDIF 

	FPQ->(DBSKIP())
ENDDO 
	
FOR DDIA := DDTINI TO DDTFIM
	DBSELECTAREA("FPQ")
	DBSETORDER(1)
	IF DBSEEK(XFILIAL("FPQ")+DA4->DA4_MAT+DTOS(DDIA))
		IF ALLTRIM(FPQ->FPQ_TIPINC) == "M"
			FPQ->(DBSKIP())
			LOOP
		ENDIF
		AADD(ADELET,FPQ->(RECNO()))
	ENDIF
	AADD(AINSERT,{DDIA})
NEXT DDIA      

IF LEN(ADELET) > 0
   	FOR NX := 1 TO LEN(ADELET)
      	DBSELECTAREA("FPQ")
    	DBGOTO(ADELET[NX])
	    WHILE !RECLOCK("FPQ",.F.) 
	    ENDDO 
		DBDELETE() 
	    MSUNLOCK() 
	NEXT NX
ENDIF
        
IF LEN(AINSERT) > 0
	FOR NX := 1 TO LEN(AINSERT)
		DBSELECTAREA("FPQ")
		RECLOCK("FPQ",.T.)
		FPQ->FPQ_FILIAL := XFILIAL("FPQ")
		FPQ->FPQ_MAT 	:= CMAT
		FPQ->FPQ_DATA 	:= AINSERT[NX,1]
		FPQ->FPQ_AGENDA := "2"
		FPQ->FPQ_STATUS := "OBRA"
		FPQ->FPQ_AS 	:= CAS
		FPQ->FPQ_DESC 	:= CNOMCLI
		FPQ->FPQ_PROJET := CSOT
		FPQ->FPQ_OBRA 	:= COBRA
		FPQ->FPQ_FILMAT := XFILIAL("FPQ")
		FPQ->FPQ_TIPINC := "A"
		FPQ->(MSUNLOCK()) 
	NEXT NX
ENDIF 
 
RESTAREA(AAREA)
RESTAREA(AAREAZLO)

RETURN


/*/{PROTHEUS.DOC} LOCA05919.PRW
TOTVS RENTAL - módulo 94
Esta função tem por finalidade a execução da troca do equipamento
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 23/06/2020
/*/
// ======================================================================= \\
FUNCTION LOCA05919()
// ======================================================================= \\
// --> TROCA EQUIPAMENTO.

LOCAL CFILOLD := CFILANT

Private lExibe    := .T.
Private cEscolhe  := ""


CFILANT := FQ5->FQ5_FILORI

IF SUBSTR(FQ5->FQ5_AS,1,2) == "22" // RECURSO HUMANO
	Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   	Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 	{STR0171}) //"Só é possível realizar a troca de equipamentos, no caso de recurso a seleção é feita no aceita da AS."
ELSE
	LOCA05920()
ENDIF

CFILANT := CFILOLD

RETURN


/*/{PROTHEUS.DOC} LOCA05919.PRW
TOTVS RENTAL - módulo 94
Esta função tem por finalidade o processamento da troca do equipamento
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 23/06/2020
/*/

// ======================================================================= \\
FUNCTION LOCA05920()
// ======================================================================= \\

LOCAL AAREA       := GETAREA() 
LOCAL AAREAZA0    := FP0->(GETAREA())
LOCAL AAREAZA5    := FP4->(GETAREA())
Local aAreaSB1    := SB1->(GetArea())
LOCAL ODLGT       := NIL                                       
LOCAL ACAB        := {}
LOCAL ACOLSCP1    := {}
LOCAL AFIELDFILL  := {}                   
LOCAL LOK         := .F.
LOCAL NITEM       := 1
LOCAL NX          := 0 
LOCAL NY          := 0 
Local _MV_LOC248  := SUPERGETMV("MV_LOCX248",.F.,STR0044)
Local _LTREQCAB   := EXISTBLOCK("LTREQCAB")
Local lLOCX305	:= SuperGetMV("MV_LOCX305",.F.,.T.) //Define se aceita geração de contrato sem equipamento

PRIVATE AALTERCPO := {"EQUIPNV"}
PRIVATE AITENS    := {} 
PRIVATE OLBX1     := NIL
PRIVATE BFIELDOK  := {|| VALIDTRC()}
PRIVATE BLINHAOK  := {|| VALIDLIN()}

IF !(EMPTY(FQ5->FQ5_DATFEC) .AND.  EMPTY(FQ5->FQ5_DATENC) .AND. FQ5->FQ5_STATUS == "1")
	Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   	Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 	{STR0172}) //"Só é permitido trocar equipamento de AS 'EM ABERTO'."
	RETURN 
ENDIF 

AADD(ACAB , { "Item"              , ;
              "ITEM"              , ;
              "@!"                , ; 
              02                  , ;
              00                  , ;
              ""                  , ;
              "€€€€€€€€€€€€€€ "   , ;
              "C"                 , ;
              "   "               , ;
              "R"                 , ;
              " "                 , ;
              " " })
	
AADD(ACAB , { STR0173     , ; //"Recurso atual"
              "EQUIPAT"           , ;
			  "@!"                , ; 
			  16                  , ;
			  00                  , ;
			  ""                  , ;
	          "€€€€€€€€€€€€€€ "   , ;
    	      "C"                 , ;
	          "   "               , ;
    	      "R"                 , ;
        	  " "                 , ;
	          " " })
	          
AADD(ACAB , { STR0174 , ; //"Placa + Descrição"
			  "PLADESC"           , ;
			  "@!"                , ; 
			  71                  , ;
			  00                  , ;
			  ""                  , ;
	          "€€€€€€€€€€€€€€ "   , ;
    	      "C"                 , ;
	          "   "               , ;
    	      "R"                 , ;
        	  " "                 , ;
	          " " })	          
	          
AADD(ACAB , { STR0175      , ; //"Novo Recurso"
			  "EQUIPNV"           , ;
			  "@!"                , ; 
			  16                  , ;
			  00                  , ;
			  ""                  , ;	
	          "€€€€€€€€€€€€€€ "   , ;
    	      "C"                 , ;
			"ST9003"            , ; // José Eulálio - 12/05/2022 - SIGALOC94-337 - Ajuste na troca de equipamento (seleção de bem) conforme campo
    	      "R"                 , ;
        	  " "                 , ;
	          " " }) 
	          
AADD(ACAB , { STR0174 , ; //"Placa + Descrição"
			  "DESCPLA"           , ;
			  "@!"                , ; 
			  71                  , ;
			  00                  , ;
			  ""                  , ;
	          "€€€€€€€€€€€€€€ "   , ;
    	      "C"                 , ;
	          "   "               , ;
    	      "R"                 , ;
        	  " "                 , ;
	          " " })

DBSELECTAREA("FP0") 
DBSETORDER(1) 
IF ! DBSEEK(XFILIAL("FP0")+FQ5->FQ5_SOT) 
	Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   	Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 	{ STR0176+CHR(10)+CHR(13) + _MV_LOC248 + STR0177+ALLTRIM(FQ5->FQ5_SOT)  }) //"Troca de equipamento."###"Projeto"###" não encontrado: "
	RETURN .F. 
ENDIF 

IF FP0->FP0_TIPOSE == "E"
	DBSELECTAREA("FP4")
	DBSETORDER(2) 					// PROJET+OBRA+AS+VIAGEM
	DBSEEK(XFILIAL("FP4")+FQ5->(FQ5_SOT+FQ5_OBRA+FQ5_AS+FQ5_VIAGEM)) 

	FQ5->( DBSETORDER(1) )			// FILIAL + VIAGEM
	WHILE !FP4->(EOF()) .AND. FP4->(FP4_FILIAL+FP4_PROJET+FP4_OBRA+FP4_AS+FP4_VIAGEM) == XFILIAL("FP4")+FQ5->(FQ5_SOT+FQ5_OBRA+FQ5_AS+FQ5_VIAGEM)
		IF !EMPTY( FP4->FP4_VIAGEM ) .AND. FQ5->( DBSEEK( XFILIAL("FQ5") + FP4->FP4_VIAGEM ) )
			ATMP := GETEQPINFO(FP4->FP4_GUINDA)			
		    AADD(AITENS,{STRZERO(NITEM,2),FP4->FP4_GUINDA, ATMP[1]+" "+ATMP[2],SPACE(16),SPACE(71),FP4->(RECNO()),FQ5->(RECNO())})
		    NITEM++ 
	    ENDIF
		FP4->(DBSKIP())
	ENDDO

ELSEIF FP0->FP0_TIPOSE == "T"  
	DBSELECTAREA("ZA7")
	DBSETORDER(2)
	IF ! DBSEEK(XFILIAL("ZA7")+FQ5->(FQ5_SOT+FQ5_OBRA+FQ5_VIAGEM))
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   		Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 		{STR0178}) //"Item aba cargas não encontrado."
		RESTAREA( AAREA )			// RESTAURA DTQ
		RETURN .F.
	ENDIF

	FQ5->( DBSETORDER(1) )			// FILIAL + VIAGEM
	IF !EMPTY( ZA7->ZA7_VIAGEM ) .AND. FQ5->( DBSEEK( XFILIAL("FQ5") + ZA7->ZA7_VIAGEM ) )
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
	   		Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	 		{"Item aba cargas sem AS gerada."})
		RESTAREA( AAREA )			// RESTAURA DTQ
		RETURN .F.
	ENDIF

	DBSELECTAREA("FP8")
	DBSETORDER(1)
	DBSEEK(XFILIAL("FP8")+ZA7->(ZA7_PROJET+ZA7_OBRA+ZA7_SEQTRA+ZA7_SEQCAR))

	WHILE !FP8->(EOF()) .AND. FP8->(FP8_FILIAL+FP8_PROJET+FP8_OBRA+FP8_SEQTRA+FP8_SEQCAR) == XFILIAL("FP8")+ZA7->(ZA7_PROJET+ZA7_OBRA+ZA7_SEQTRA+ZA7_SEQCAR) 
		ATMP := GETEQPINFO(FP8->FP8_TRANSP)			
	    AADD(AITENS,{STRZERO(NITEM,2),FP8->FP8_TRANSP, ATMP[1]+" "+ATMP[2],SPACE(16),SPACE(71),FP8->(RECNO()),FQ5->(RECNO())})
	    NITEM++ 
		FP8->(DBSKIP())
	ENDDO

ELSEIF FP0->FP0_TIPOSE == "L"
	DBSELECTAREA("FPA")
	DBSETORDER(1) 					// FPA_FILIAL+FPA_PROJET+FPA_OBRA+FPA_SEQGRU+FPA_CNJ
	DBSEEK(XFILIAL("FPA") + FQ5->FQ5_SOT + FQ5->FQ5_OBRA, .T. )

	FQ5->( DBSETORDER(1) )			// FILIAL + VIAGEM
	WHILE !(FPA->(EOF())) .AND. FPA->(FPA_FILIAL+FPA_PROJET+FPA_OBRA) == XFILIAL("FPA") + FQ5->FQ5_SOT + FQ5->FQ5_OBRA
		// 16/09/2022 - Jose Eulalio - SIGALOC94-517 - Parou de apresentar no GRID todos itens da obra na opção troca de equipamento
		//IF !EMPTY( FPA->FPA_VIAGEM ) .AND. FPA->FPA_VIAGEM == FQ5->FQ5_VIAGEM //FQ5->( DBSEEK( XFILIAL("FQ5") + FPA->FPA_VIAGEM ) )
		IF !EMPTY( FPA->FPA_VIAGEM ) .AND. FQ5->( DBSEEK( XFILIAL("FQ5") + FPA->FPA_VIAGEM ) )
			If FPA->FPA_TIPOSE <> "M"
				If !empty(FPA->FPA_GRUA)
					ATMP := GETEQPINFO(FPA->FPA_GRUA)
					AADD(AITENS, { STRZERO(NITEM,2), FPA->FPA_GRUA, ATMP[1]+" "+ATMP[2],SPACE(16),SPACE(71), FPA->(RECNO()), FQ5->(RECNO()) } )
					NITEM++
				ElseIf lLOCX305
					SB1->(DBSETORDER(1))
					If SB1->(DBSEEK(XFILIAL("SB1") + FQ5->FQ5_XPROD))
						//Se não for um bem acessório, adiciona
						If !LOCXITU26(SB1->B1_COD)
							AADD(AITENS, { STRZERO(NITEM,2), FPA->FPA_GRUA, AllTrim(FQ5->FQ5_XPROD) + "|" + AllTrim(SB1->B1_DESC),SPACE(16),SPACE(71), FPA->(RECNO()), FQ5->(RECNO()) } )
							NITEM++
						EndIf
					EndIf
				EndIf
			EndIf
		ENDIF
		FPA->(DBSKIP())
	ENDDO

ELSE
	MSGALERT(STR0176+CHR(10)+CHR(13)+STR0179 + _MV_LOC248 + STR0180+ FP0->FP0_TIPOSE , STR0022)  //"Troca de equipamento."###"Tipo do "###"Projeto"###" Inválido: "###"Atenção!"
	RESTAREA( AAREA )				// RESTAURA DTQ
	RETURN .F.

ENDIF

RESTAREA( AAREA )					// RESTAURA DTQ

IF _LTREQCAB //EXISTBLOCK("LTREQCAB") 												// --> PONTO DE ENTRADA PARA ALTERAÇÃO DE CAMPOS NA TROCA DE EQUIPAMENTO.
	ACAB := EXECBLOCK("LTREQCAB",.T.,.T.,{ACAB})
ENDIF

If len(aItens) == 0
	Help(Nil,	Nil,"RENTAL: "+alltrim(upper(Procname())),;
	   	Nil,STR0181,1,0,Nil,Nil,Nil,Nil,Nil,; //"Não foram localizados equipamentos para substituição."
	 	{STR0182}) //"Verifique no orçamento se foram informados os bens, para a locação em questão."
	RESTAREA(AAREAZA5) 
	RESTAREA(AAREAZA0) 
	RESTAREA(AAREA)
	Return .F.
EndIF

// ALIMENTA O ACOLS
FOR NX := 1 TO LEN(AITENS)
	AFIELDFILL := {} 
	FOR NY := 1 TO LEN(AITENS[NX])
		AADD(AFIELDFILL, AITENS[NX,NY])
	NEXT NY

	AADD(AFIELDFILL, .F.)

	AADD(ACOLSCP1, AFIELDFILL)		   
NEXT NX
                                                    
DEFINE MSDIALOG ODLGT FROM 0,0 TO 285,1100 PIXEL TITLE STR0122 //"Equipamento"
	NW := (ODLGT:NCLIENTWIDTH/2)
	NH := (ODLGT:NCLIENTHEIGHT/2)-25	
	
	OLBX1 := MSNEWGETDADOS():NEW( 05 , 01, 120, NW, GD_UPDATE, "EVAL(BLINHAOK)", "ALLWAYSTRUE", "+", AALTERCPO,, 999, "EVAL( BFIELDOK )", "", "ALLWAYSTRUE", ODLGT, ACAB, ACOLSCP1)
	
	OTBROWSEBUTTON := TBROWSEBUTTON():NEW( 130,500,"OK",ODLGT  , {|| IIF(VALIDTROCAEQ(OLBX1:ACOLS),(LOK := .T., ODLGT:END()),LOK := .F.)},37,12,,,.F.,.T.,.F.,,.F.,,,)  
ACTIVATE MSDIALOG ODLGT CENTERED

IF LOK 
	LOCA05921(OLBX1:ACOLS,FP0->FP0_TIPOSE)
ENDIF 
  	
RESTAREA(AAREAZA5) 
RESTAREA(AAREAZA0) 
RESTAREA(AAREA)
RestArea(aAreaSB1)

RETURN NIL



// ======================================================================= \\
STATIC FUNCTION VALIDLIN()
// ======================================================================= \\

LOCAL LRET := .T.
Local _LCVLDLIN := EXISTBLOCK("LCVLDLIN")

IF _LCVLDLIN //EXISTBLOCK("LCVLDLIN") 												// --> PONTO DE ENTRADA PARA INCLUSÃO DE BOTÕES NA TELA DE ACEITE EM LOTE.
	LRET := EXECBLOCK("LCVLDLIN",.T.,.T.,{})
ENDIF

RETURN LRET



// ======================================================================= \\
STATIC FUNCTION VALIDTRC()
// ======================================================================= \\

LOCAL LRET := .T.

ST9->( DBSETORDER(1) )
IF !ST9->( DBSEEK(XFILIAL("ST9") + M->EQUIPNV ) )
	MSGALERT(STR0183+ALLTRIM(M->EQUIPNV)+STR0184 , STR0022)  //"Recurso informado ("###") Inválido."###"Atenção!"
	LRET := .F.
ELSE
	ACOLS[N,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="DESCPLA"})] := ST9->T9_NOME
ENDIF

RETURN LRET



// ======================================================================= \\
STATIC FUNCTION VALIDTROCAEQ(ATROCA) 
// ======================================================================= \\
// --> VALIDA SE AS SIGLAS SÃO IGUAIS.

LOCAL CEQUIATU  := ""
LOCAL CEQUINOV	:= ""
LOCAL LRET		:= .T.
LOCAL _LVLDTIPO := SUPERGETMV("MV_LOCX256",.F.,.F.)
LOCAL NX        := 0 
Local _VALGRUA := EXISTBLOCK("VALGRUA")

FOR NX := 1 TO LEN(ATROCA)
	
	IF ! EMPTY( ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})] )
		CEQUIATU := ALLTRIM(GETADVFVAL("ST9", "T9_CODFAMI",XFILIAL("ST9")+ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPAT"})],1,"")) //SUBSTR(ATROCA[NX,2],1,3)//+SUBSTR(ATROCA[NX,2],6,3)
		CEQUINOV := ALLTRIM(GETADVFVAL("ST9", "T9_CODFAMI",XFILIAL("ST9")+ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})],1,"")) //SUBSTR(ATROCA[NX,4],1,3)//+SUBSTR(ATROCA[NX,4],6,3)

		DBSELECTAREA("ST9")
	 	DBSETORDER(1)
	    IF !DBSEEK(XFILIAL("ST9")+ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]) 
	    	MSGALERT(STR0185+ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="ITEM"})]+STR0186+ALLTRIM(ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})])+STR0187 , STR0022)  //"Item: "###" - O recurso selecionado ("###") é inválido."###"Atenção!"
			LRET := .F.
			EXIT	                                                                                                     
	    ENDIF

		IF _LVLDTIPO
			IF (CEQUIATU <> CEQUINOV) .AND. LRET
				MSGALERT(STR0185+ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="ITEM"})]+STR0186+ALLTRIM(ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})])+STR0188+ALLTRIM(ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPAT"})])+")." , STR0022)  //"Item: "###" - O recurso selecionado ("###"), não tem o mesmo tipo ou configuração do que foi vendido ("###"Atenção!"
				LRET := .F.
				EXIT
			ENDIF
		ENDIF
			
        // VERIFICA SE O EQUIPAMENTO É VALIDO.
		IF _VALGRUA //EXISTBLOCK("VALGRUA") 										// --> PONTO DE ENTRADA ANTES DA ALTERAÇÃO DE STATUS DO BEM.
		   LRET := EXECBLOCK("VALGRUA",.T.,.T.,{.T.,ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]})
		   IF !LRET
		      EXIT
		   ENDIF
		ENDIF 
	ENDIF

NEXT NX 

RETURN(LRET)



// ======================================================================= \\
FUNCTION LOCA05921(ATROCA,CTIPO)
// ======================================================================= \\
// --> GRAVA DOS EQUIPAMENTOS (T, E, L)

LOCAL AAREA    := GETAREA()
LOCAL AAREAZA5 := FP4->(GETAREA())  
LOCAL AAREAZLG := FPO->(GETAREA())
LOCAL AAREAST9 := ST9->(GETAREA())
LOCAL AAREADTQ := FQ5->(GETAREA())
LOCAL AAREASHB := SHB->(GETAREA())
LOCAL CMSG     := ""
LOCAL NX       := 0 
LOCAL _cStOld  := ""
Local _LC111TEQ := EXISTBLOCK("LC111TEQ")

FOR NX := 1 TO LEN(ATROCA)
	IF !EMPTY( ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})] )	// SÓ VAI TROCAR SE ESTIVER PREENCHIDO

		// posicionar no bem antigo para saber o status dele
		IF ST9->( DBSEEK( XFILIAL("ST9") + FQ5->FQ5_GUINDA ) )
			_cStOld := ST9->T9_STATUS
		Else
			//08/09/2021 - Jose Eulalio - DSERLOCA-296 
			//Caso não localize o bem (produto sem bem)
			_cStOld := "10"
		EndIf

		ST9->( DBSETORDER(1) )
		IF ! ST9->( DBSEEK( XFILIAL("ST9")+ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})] ) )
			CMSG := "BEM " + ALLTRIM( ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})] ) + STR0189 //" NÃO ENCONTRADO!"
			EXIT
		ENDIF
		
		FQ5->( DBGOTO( ATROCA[NX,LEN(ATROCA[NX])-1] )) 							// POSICIONA A DTQ DA LINHA DO ITEM 
		FPA->( DBGOTO( ATROCA[NX,LEN(ATROCA[NX])-2] ) )
		
		// ALOCA BEM NOVO
		//IF EXISTBLOCK("T9STSALT") 										// --> PONTO DE ENTRADA ANTES DA ALTERAÇÃO DE STATUS DO BEM.
			//EXECBLOCK("T9STSALT",.T.,.T.,{ST9->T9_STATUS,_cStOld,FQ5->FQ5_SOT,"",""})
			LOCXITU21(ST9->T9_STATUS,_cStOld,FQ5->FQ5_SOT,"","")
		//ENDIF
		RECLOCK("ST9",.F.)
		ST9->T9_STATUS := _cStOld
		ST9->(MSUNLOCK()) 
		
		RECLOCK("FQ5",.F.)
		IF FP0->FP0_TIPOSE == "T"
			CBEMOLD         := FQ5->FQ5_EQUIP
			FQ5->FQ5_EQUIP  := ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]
		ELSE
			CBEMOLD         := FQ5->FQ5_GUINDA
			FQ5->FQ5_GUINDA := ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]
		ENDIF
		FQ5->(MSUNLOCK()) 
		
		// DISPONIBILIZA BEM ANTIGO
		NRECST9 := ST9->( RECNO() )
		
		//IF EXISTBLOCK("T9STSALT") 										// --> PONTO DE ENTRADA ANTES DA ALTERAÇÃO DE STATUS DO BEM.
		//	EXECBLOCK("T9STSALT",.T.,.T.,{ST9->T9_STATUS,"01",FQ5->FQ5_SOT,"","",.T.})
		//ENDIF

		_cTemps00 := ""
		TQY->(dbSetOrder(1))
		TQY->(dbGotop())
		While !TQY->(Eof())
			If TQY->TQY_STTCTR == "00"
				_cTemps00 := TQY->TQY_STATUS
			EndIF
			TQY->(dbSkip())
		EndDo


		IF ST9->( DBSEEK( XFILIAL("ST9") + CBEMOLD ) )
			//IF EXISTBLOCK("T9STSALT") 									// --> PONTO DE ENTRADA ANTES DA ALTERAÇÃO DE STATUS DO BEM.
				//EXECBLOCK("T9STSALT",.T.,.T.,{ST9->T9_STATUS,"00",FQ5->FQ5_SOT,"","",.T.})
				LOCXITU21(ST9->T9_STATUS,_cTemps00,FQ5->FQ5_SOT,"","",.T.)
			//ENDIF
			RECLOCK("ST9",.F.)
			ST9->T9_STATUS := _cTemps00 //"01" - atendimento ao card gerado pelo Rafael em 11/02/21 - Frank Fuga
			ST9->(MSUNLOCK()) 
		ENDIF
		
		ST9->( DBGOTO( NRECST9 ) )
		
		IF FP0->FP0_TIPOSE == "T"
			DBSELECTAREA("FPM")
			FPM->( DBSETORDER(4) )	//AS+FROTA
			FPM->( DBSEEK(XFILIAL("FPM")+FQ5->(FQ5_AS+FQ5_VIAGEM)) )
			WHILE !FPM->(EOF()) .AND. FPM->(FPM_FILIAL+FPM_AS+FPM_VIAGEM) == XFILIAL("FPM")+FQ5->(FQ5_AS+FQ5_VIAGEM)
				RECLOCK("FPM",.F.)
				FPM->(DBDELETE()) 
				FPM->(MSUNLOCK()) 
				FPM->(DBSKIP())
			ENDDO
			
			FP8->( DBGOTO( ATROCA[NX,LEN(ATROCA[NX])-2] ) )
			RECLOCK("FP8",.F.)
			FP8->FP8_TRANSP := ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]
			FP8->FP8_DESTRA := ST9->T9_NOME
			FP8->(MSUNLOCK()) 
			
		ELSEIF FP0->FP0_TIPOSE == "E"
			DBSELECTAREA("FP4")
			FP4->( DBGOTO( ATROCA[NX,LEN(ATROCA[NX])-2] ) )
			IF RECLOCK("FP4",.F.)
				FP4->FP4_GUINDA := ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]
				FP4->FP4_DESGUI := ST9->T9_NOME
				FP4->(MSUNLOCK())
			ENDIF
			
		ELSEIF FP0->FP0_TIPOSE == "L"
			DBSELECTAREA("ST9")
			ST9->( DBSETORDER(1) )
			ST9->(DBSEEK(XFILIAL("ST9") + ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]))
			DBSELECTAREA("SHB")
			SHB->( DBSETORDER(1) )
			SHB->(DBSEEK(XFILIAL("SHB") + ST9->T9_CENTRAB))

			FPA->( DBGOTO( ATROCA[NX,LEN(ATROCA[NX])-2] ) )		// FPA->( DBGOTO( ATROCA[NX,LEN(ATROCA[NX])-1] ) )
			RECLOCK("FPA",.F.)
			FPA->FPA_GRUA	:= ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]
			FPA->FPA_DESGRU	:= ALLTRIM(ST9->T9_NOME)
			IF SHB->(FIELDPOS("HB_XCCFAT")) > 0
				FPA->FPA_CUSTO	:= SHB->HB_XCCFAT 
			ENDIF
			FPA->(MSUNLOCK()) 
		ENDIF
		
		// INTEGRAÇÃO DIÁRIO DE BORDO / OCORRÊNCIAS
		FQA->( DBSETORDER(1) )									// VIAGEM
		IF FQA->( DBSEEK(XFILIAL("FQA")+FQ5->FQ5_VIAGEM) )
			RECLOCK("FQA",.F.)
			IF NX == 1
				FQA->FQA_PLACA	:= ST9->T9_PLACA
			ELSE
				FQA->FQA_VEICUL := ST9->T9_PLACA
			ENDIF
			FQA->(MSUNLOCK()) 
		ENDIF
		
		FPO->( DBSETORDER(4) )									// PROJET+OBRA+AS+VIAGEM
		IF FPO->( DBSEEK(XFILIAL("FPO")+FQ5->(FQ5_SOT+FQ5_OBRA+FQ5_AS+FQ5_VIAGEM)) )
			WHILE FPO->(!EOF()) .AND.;
				FPO->(FPO_FILIAL + FPO_PROJET + FPO_OBRA + FPO_NRAS + FPO_VIAGEM) == XFILIAL("FPO")+FQ5->(FQ5_SOT+FQ5_OBRA+FQ5_AS+FQ5_VIAGEM)
				IF RECLOCK("FPO",.F.)
					FPO->FPO_FROTA := ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]
					FPO->(MSUNLOCK())
				ENDIF
				FPO->(DBSKIP())
			ENDDO
		ENDIF
		
		IF FP0->FP0_TIPOSE == "T"
			// CRIA A ZLE
		ENDIF
		
		IF _LC111TEQ //EXISTBLOCK("LC111TEQ") 										// --> PONTO DE ENTRADA NO FINAL DA ATUALIZAÇÃO DE TROCA DE EQUIPAMENTO DA AS.
			EXECBLOCK("LC111TEQ",.T.,.T.,{ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]})
		ENDIF

	ENDIF
NEXT NX 

IF ! EMPTY( CMSG )
	MSGALERT(CMSG , STR0022) //"Atenção!"
ELSE
	MSGINFO(STR0190 , STR0022) //"Troca de equipamento efetuada com sucesso."###"Atenção!"
ENDIF

RESTAREA(AAREASHB)
RESTAREA(AAREADTQ)
RESTAREA(AAREAST9)
RESTAREA(AAREAZLG)
RESTAREA(AAREAZA5)
RESTAREA(AAREA)

RETURN EMPTY( CMSG )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ FILST9    º AUTOR ³ IT UP BUSINESS     º DATA ³ 15/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ EXECUTA FILTRO DO CONTROLE DE ACESSO E RESTRICAO NA        º±±
±±º          ³ CONSULTA SXB                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
FUNCTION LOCA05922() 

LOCAL LRET := .F. 
STATIC CCONDICAO 

IF CCONDICAO == NIL 
	CCONDICAO := &( " { || " + CHKRH( FUNNAME() , ALIAS() , IF(ISINCALLSTACK("SETPRINT"), "2", "1") ) + " } " ) 
ENDIF 

LRET := EVAL( CCONDICAO )

RETURN(IIF( VALTYPE(LRET)=="U" , .T. , LRET)) 



// ======================================================================= \\
FUNCTION LOCA05923(DDTINI, DDTFIM, CAS, CNOMCLI, CSOT, COBRA, CVIAGEM, LREVIS, CSEQCAR, CCOD, CAJUD, CTITULO) 
// ======================================================================= \\
// CRIAÇÃO DE MOTORISTA PARA GUINDASTE

LOCAL   LOK      := .F.
LOCAL   ODLGUSER

DEFAULT CCOD	 := SPACE(6)
DEFAULT CAJUD    := SPACE(6)
DEFAULT CTITULO  := "Motorista"

DEFINE MSDIALOG ODLGUSER TITLE CTITULO FROM 000,000 TO 180,300 PIXEL OF OMAINWND
	@ 010,010 SAY   STR0191                   OF ODLGUSER PIXEL //"Motorista:"
	@ 020,010 MSGET CCOD      F3 "DA4" SIZE 80,010 OF ODLGUSER PIXEL

	@ 040,010 SAY   STR0192                    OF ODLGUSER PIXEL //"Ajudante:"
	@ 050,010 MSGET CAJUD     F3 "DA4" SIZE 80,010 OF ODLGUSER PIXEL

	@ 070,110 BUTTON STR0170 SIZE 35,14 PIXEL OF ODLGUSER ACTION ( LOK := .T., ODLGUSER:END() ) //"Confirmar"
ACTIVATE MSDIALOG ODLGUSER CENTERED

IF LOK
	PROCESSA({|| GERA2FROTA( CCOD, DDTINI, DDTFIM, CAS, CNOMCLI, CSOT, COBRA, CVIAGEM, LREVIS, CSEQCAR, "M" /*MOTORISTA*/) })
	IF ! EMPTY( CAJUD )
		PROCESSA({|| GERA2FROTA( CAJUD, DDTINI, DDTFIM, CAS, CNOMCLI, CSOT, COBRA, CVIAGEM, LREVIS, CSEQCAR, "A" /*AJUDANTE*/) })
	ENDIF
ENDIF

RETURN CCOD



// ======================================================================= \\
STATIC FUNCTION GERA2FROTA(CCOD,DDTINI,DDTFIM,CAS,CNOMCLI,CSOT,COBRA,CVIAGEM,LREVIS,CSEQCAR, CFUNCAO)
// ======================================================================= \\

LOCAL AAREA		:= GETAREA()
LOCAL AAREADA4	:= DA4->(GETAREA())
LOCAL AAREAZLO	:= FPQ->(GETAREA())
LOCAL LEXIT		:= .F.
LOCAL DDATAINI	:= DDTINI
LOCAL ADELET	:= {}
LOCAL AINSERT	:= {}      
LOCAL CNOMMOT	:= "" 
LOCAL NX        := 0 

DEFAULT CFUNCAO := ""

DBSELECTAREA("DA4")
DBSETORDER(1)
IF DBSEEK(XFILIAL("DA4")+CCOD) .AND. !EMPTY(CCOD)
	IF !EMPTY(DA4->DA4_MAT)
		CNOMMOT := DA4->DA4_NOME

        WHILE !LEXIT
			IF DTOS(DDATAINI) > DTOS(DDTFIM) 
				LEXIT := .T. 
				LOOP 
			ENDIF 
        		
			DBSELECTAREA("FPQ") 
			DBSETORDER(1) 
       		IF DBSEEK(XFILIAL("FPQ")+DA4->DA4_MAT+DTOS(DDATAINI))
        		WHILE !FPQ->(EOF()) .AND. ALLTRIM(FPQ->FPQ_MAT) == ALLTRIM(DA4->DA4_MAT) .AND. DTOS(DDATAINI) == DTOS(FPQ->FPQ_DATA) 
					IF ALLTRIM(FPQ->FPQ_TIPINC) == "M" 
						FPQ->(DBSKIP()) 
						LOOP 
					ENDIF 
					AADD(ADELET, FPQ->(RECNO()) ) 
					AADD(AINSERT,{DA4->DA4_MAT,DDATAINI,CAS,CNOMCLI,CSOT,COBRA}) 
					DDATAINI++ 
					FPQ->(DBSKIP()) 
        		ENDDO 
       		ELSE
        		RECLOCK("FPQ",.T.)
				FPQ->FPQ_FILIAL := XFILIAL("FPQ")
				FPQ->FPQ_MAT 	:= DA4->DA4_MAT
				FPQ->FPQ_DATA 	:= DDATAINI
				FPQ->FPQ_AGENDA := "2"
				FPQ->FPQ_STATUS := "OBRA"
				FPQ->FPQ_AS 	:= CAS
				FPQ->FPQ_DESC 	:= CNOMCLI
				FPQ->FPQ_PROJET := CSOT
				FPQ->FPQ_OBRA 	:= COBRA
				FPQ->FPQ_FILMAT := XFILIAL("FPQ")
				FPQ->FPQ_TIPINC := "A"
				FPQ->FPQ_FUNCAO := CFUNCAO
				FPQ->(MSUNLOCK()) 
			ENDIF
        			
			DDATAINI++ 
		ENDDO

        IF LEN(ADELET) > 0
        	FOR NX := 1 TO LEN(ADELET)
        		DBSELECTAREA("FPQ")
		    	DBGOTO(ADELET[NX])
			    WHILE !RECLOCK("FPQ",.F.)
			    ENDDO
				DBDELETE()
			    MSUNLOCK() 
        	NEXT NX 
        ENDIF 
	        
        IF LEN(AINSERT) > 0
        	FOR NX := 1 TO LEN(AINSERT)
        		DBSELECTAREA("FPQ")
				RECLOCK("FPQ",.T.)
				FPQ->FPQ_FILIAL := XFILIAL("FPQ")
				FPQ->FPQ_MAT 	:= AINSERT[NX,1]
				FPQ->FPQ_DATA 	:= AINSERT[NX,2]
				FPQ->FPQ_AGENDA := "2"
				FPQ->FPQ_STATUS := "OBRA"
				FPQ->FPQ_AS 	:= AINSERT[NX,3]
				FPQ->FPQ_DESC 	:= AINSERT[NX,4]
				FPQ->FPQ_PROJET := AINSERT[NX,5]
				FPQ->FPQ_OBRA 	:= AINSERT[NX,6]
				FPQ->FPQ_FILMAT := XFILIAL("FPQ")
				FPQ->FPQ_TIPINC := "A"
				FPQ->(MSUNLOCK()) 
        	NEXT NX 
        ENDIF 

		_XFUNC := "" 
		SRA->( DBSETORDER(1) ) 
		IF SRA->( DBSEEK( XFILIAL("SRA") + DA4->DA4_MAT ) ) 
			SRJ->( DBSETORDER (1) ) 
			IF SRJ->( DBSEEK( SRA->RA_FILIAL + SRA->RA_CODFUNC ) )
				_XFUNC := SRJ->RJ_DESC 
			ENDIF 
		ENDIF 

		RECLOCK("FPL",.T.) 
		FPL->FPL_FILIAL := XFILIAL("FPL")
		FPL->FPL_FROTA  := FQ5->FQ5_GUINDA
		FPL->FPL_ITEM   := "001"
		FPL->FPL_MATRIC := DA4->DA4_MAT
		FPL->FPL_NOME   := DA4->DA4_NOME
		FPL->FPL_DTINI  := DDTINI
		FPL->FPL_DTFIM  := DDTFIM
		FPL->FPL_AS     := CAS
		FPL->FPL_PROJET := CSOT
		FPL->FPL_OBRA   := COBRA
		FPL->FPL_VIAGEM := CVIAGEM
		FPL->FPL_FILMAT := XFILIAL("FPL")
		FPL->FPL_FUNCAO := _XFUNC
		FPL->(MSUNLOCK()) 
    ENDIF
ENDIF

IF TYPE("ODLGUSER") != "U"
	ODLGUSER:END()
ENDIF
 
RESTAREA(AAREADA4)
RESTAREA(AAREAZLO)
RESTAREA(AAREA)

RETURN NIL



// ----------------------------------------------------------------------- \\
/*/{PROTHEUS.DOC} GETEQPINFO
@AUTHOR  IT UP BUSINESS 
@SINCE   22/12/2014
@VERSION 1.0
@RETURN  AEQUIP , ARRAY , DADOS DO EQUIPAMENTO  
				  AEQUIP[1] - PLACA
				  AEQUIP[2] - DESCRIÇÃO
/*/
// ----------------------------------------------------------------------- \\
STATIC FUNCTION GETEQPINFO(CCODEQUIP)
// ----------------------------------------------------------------------- \\

LOCAL AAREAST9 	:= ST9->(GETAREA())
LOCAL AEQUIP	:= {}
	
DBSELECTAREA("ST9")
DBSETORDER(1)
IF MSSEEK(XFILIAL("ST9") + CCODEQUIP)
	AADD(AEQUIP , ALLTRIM(ST9->T9_PLACA))
	AADD(AEQUIP , ALLTRIM(ST9->T9_NOME))
ELSE
	AADD(AEQUIP , "") 
	AADD(AEQUIP , "") 
ENDIF 

RESTAREA(AAREAST9)

RETURN AEQUIP



// ----------------------------------------------------------------------- \\
STATIC FUNCTION FACEMINUTA(CLOTE) 
// ----------------------------------------------------------------------- \\
// --> ACEITA MINUTA

LOCAL NVERZBX , AVERZBX , AERROSZBX := {} 
LOCAL NPOS , DDATAAUX
LOCAL CFROTA , CAS , DINI , DFIM 
LOCAL CPROJET , COBRA 
LOCAL AGRAVAR 
LOCAL NGRAVADOS  := 0
LOCAL AFROTAS    := {}				// TODO CONJUNTO TRANSPORTADOR
LOCAL _NX        := 0 
LOCAL _U         := 0 
LOCAL _V         := 0 
Local _MV_LOC248 := SUPERGETMV("MV_LOCX248",.F.,STR0044)
Local _LC111ANT  := EXISTBLOCK("LC111ANT")
Local _LC111ACE  := EXISTBLOCK("LC111ACE")
//LOCAL LREVIS  := .F. 				// VARIÁVEL USADA PARA TRANSPORTE ==> FQ5->FQ5_TPAS=="T"

DEFAULT CLOTE := ""

IF FQ5->FQ5_STATUS != "1" .OR. !EMPTY(FQ5->FQ5_DATENC) .OR. !EMPTY(FQ5->FQ5_DATENC)
	IF EMPTY( CLOTE )
		If _lMens
			//Ferramenta Migrador de Contratos
			If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
				cLocErro := STR0052+CRLF
			Else
				MSGSTOP(STR0052 , STR0022) //"Somente uma AS aberta pode ser aceita!"###"Atenção!"		
			EndIf
		EndIF
	ENDIF 
	RETURN .F. 
ENDIF

// --> VALIDAÇÃO DA DISPONIBILIDADE DO EQUIPAMENTO   (*INICIO*) 
// POSICIONAR NA ZA5 PEGAR A DATA INICIO E A DATA FIM. 
// AINDA NA ZA5 PEGAR O TURNO, PODE EXISTIR TURNOS ESPECIFICOS PARA OS FINAIS DE SEMANA.  PEGAR O HORÁRIO INICIO E FIM.
// TENDO AS INFORMAÇÕES DE DATA INICIO, DATA FIM, HORÁRIOS... POSICIONAR ZLG E VERIFICAR SE ESTIVER PRE-RESERVADO CRIAR 
// UM REGISTRO PASSANDO PARA RESERVADO, SE ESTIVER DIFERENTE DE PRE-RESERVADO, AVISAR QUE O O BEM JÁ ESTA RESERVADO.
_LXBLOQ := .F.
IF !EMPTY(FQ5->FQ5_GUINDA)
	_AXVALEQUI	:= {}
	FP4->(DBSETORDER(7))
	IF FP4->(DBSEEK(XFILIAL("FP4")+FQ5->FQ5_SOT+FQ5->FQ5_AS))
		_DXINI 	 := FP4->FP4_DTINI
		_DXFIM	 := FP4->FP4_DTFIM
		_CRESERV := ""
		FPE->(DBSETORDER(1))
		FPE->(DBSEEK(XFILIAL("FPE")+FQ5->FQ5_SOT+FP4->FP4_OBRA+FQ5->FQ5_GUINDA))
		WHILE !FPE->(EOF()) .AND. FPE->(FPE_FILIAL+FPE_PROJET+FPE_OBRA+FPE_FROTA) == XFILIAL("FPE")+FQ5->FQ5_SOT+FP4->FP4_OBRA+FQ5->FQ5_GUINDA
			//                PROJETO        , OBRA         , EQUIPAMENTO   , DTINI , DTFIM , HINI           , HFIM           , 1-OK, 2-NAO, 3-TROCA
			AADD(_AXVALEQUI,{ FPE->FPE_PROJET, FPE->FPE_OBRA, FPE->FPE_FROTA, _DXINI, _DXFIM, FPE->FPE_HRINIT, FPE->FPE_HOFIMT, "1" })
			FPE->(DBSKIP())
		ENDDO
		FOR _NX:=1 TO LEN(_AXVALEQUI)
			FPO->(DBSETORDER(1))
			FPO->(DBSEEK(XFILIAL("FPO")+_AXVALEQUI[_NX][03]))
			WHILE !FPO->(EOF()) .AND. FPO->FPO_FILIAL + FPO->FPO_FROTA == XFILIAL("FPO") + _AXVALEQUI[_NX][03]
				IF FPO->FPO_DTINI >= _AXVALEQUI[_NX][04] .AND. FPO->FPO_DTFIM <= _AXVALEQUI[_NX][05]
					_CHINI := FPO->FPO_HRINI
					IF SUBSTR(_CHINI,3,1) == ":"
						_CHINI := SUBSTR(_CHINI,1,2)+"0"+SUBSTR(_CHINI,4,1)
					ENDIF
					_CHFIM := FPO->FPO_HRFIM
					IF SUBSTR(_CHFIM,3,1) == ":"
						_CHFIM := SUBSTR(_CHFIM,1,2)+"0"+SUBSTR(_CHFIM,4,1)
					ENDIF
					IF _CHINI >= _AXVALEQUI[_NX][06] .AND. _CHFIM <= _AXVALEQUI[_NX][07]
						IF FPO->FPO_STATUS == "0"
							_AXVALEQUI[_NX][08] := "3"
						ELSE
							_AXVALEQUI[_NX][08] := "2"
						ENDIF
					ENDIF
				ENDIF
				FPO->(DBSKIP())
			ENDDO
		NEXT _NX 
		
		_LXBLOQ   := .F. // VERIFICA SE BLOQUEIA
		_LXBLOQ2  := .F. // VERIFICA SE BLOQUEIA POR PRE-RESERVA
		_CRESERV  := ""
		_CRESERV2 := ""
		FOR _NX:=1 TO LEN(_AXVALEQUI)
			IF _AXVALEQUI[_NX][08] == "2"
				_LXBLOQ := .T.
				_CRESERV += IF(EMPTY(_CRESERV),"","; ")+ALLTRIM(_AXVALEQUI[_NX][03])
			ENDIF
			IF _AXVALEQUI[_NX][08] == "3"
				_LXBLOQ2 := .T.
				_CRESERV2 += IF(EMPTY(_CRESERV2),"","; ")+ALLTRIM(_AXVALEQUI[_NX][03])
			ENDIF
		NEXT _NX 
		IF _LXBLOQ
			MSGALERT(STR0193+_CRESERV , STR0022) //"Operação cancelada! Existem itens reservados "###"Atenção!"
			RETURN .F.
		ENDIF
		IF _LXBLOQ2
			MSGALERT(STR0194+_CRESERV2 , STR0022)  //"Operação cancelada! Existem itens que precisam ser reservados."###"Atenção!"
			RETURN .F.
		ENDIF
	ENDIF
ENDIF
// --> VALIDAÇÃO DA DISPONIBILIDADE DO EQUIPAMENTO   (*FINAL* )

CFROTA  := IIF( EMPTY(FQ5->FQ5_GUINDA), FQ5->FQ5_EQUIP, FQ5->FQ5_GUINDA )
CAS     := FQ5->FQ5_AS
DINI    := FQ5->FQ5_DATINI
DFIM    := FQ5->FQ5_DATFIM
CPROJET := FQ5->FQ5_SOT
COBRA   := FQ5->FQ5_OBRA

IF DINI > DFIM
	IF EMPTY( CLOTE )
		MSGALERT(STR0195+DTOC(DINI)+STR0196+DTOC(DFIM)+"." , STR0022)  //"Data de início "###" maior que data final "###"Atenção!"
	ENDIF
	RETURN .F.
ENDIF

IF ! EMPTY( CFROTA )
	AADD( AFROTAS, CFROTA )
ENDIF

IF LMINUTA
	FPA->(DBSETORDER(3))			// FPA_FILIAL + FPA_AS + FPA_VIAGEM
	IF FPA->(DBSEEK( XFILIAL("FPA") + FQ5->FQ5_AS )) .AND. !EMPTY(FQ5->FQ5_AS)
		IF FPA->FPA_TIPOSE <> "M"
			LMINUTA := .F.
		ENDIF
	ENDIF
ENDIF

IF FQ5->FQ5_TPAS == "T"				// EH TRANSPORTE, CARREGAR TODO CONJUNTO TRANSPORTADOR
	FP8->( DBSETORDER(1) ) 			// FP8_FILIAL, FP8_PROJET, FP8_OBRA, FP8_SEQTRA, FP8_SEQCAR, FP8_SEQCON, R_E_C_N_O_, D_E_L_E_T_
	FP8->( DBSEEK(XFILIAL("FP8")+CPROJET+COBRA,.T. ) )
	WHILE ! FP8->( EOF() ) .AND. FP8->( FP8_FILIAL + FP8_PROJET + FP8_OBRA ) == XFILIAL("FP8")+CPROJET+COBRA
		IF ASCAN( _ASS, {|IT| IT[2] == FP8->FP8_SEQCAR }) > 0
			IF ! EMPTY(FP8->FP8_TRANSP) .AND. ASCAN( AFROTAS, FP8->FP8_TRANSP ) == 0
				AADD( AFROTAS , FP8->FP8_TRANSP )
			ENDIF 
		ENDIF 
		FP8->( DBSKIP() ) 
	ENDDO 
ENDIF 

IF LEFT( FQ5->FQ5_AS, 2 ) == "06"	// M.O. 
	AADD( AFROTAS , "" )
ENDIF

IF LEN( AFROTAS ) > 0
	AERROSZBX := {}					// GUARDA INCONSISTENCIAS PARA EXIBIR
	FOR _U := DINI TO DFIM
	    FOR _V := 1 TO LEN( AFROTAS )
	    	CFROTA  := AFROTAS[_V]
			AVERZBX := LOCA00514("FACEMINUTA",CFROTA,CFROTA, /*DINI*/ _U, /*DFIM*/ _U, CAS, FQ5->FQ5_HORINI, FQ5->FQ5_HORFIM)  //VERIFICA SE EXISTE ZBX
			IF LEN(AVERZBX) > 0 .AND. FQ5->FQ5_TPAS != "F"
				FOR NVERZBX :=1 TO LEN(AVERZBX)
					AADD(AERROSZBX,{CFROTA,CAS,DINI,DFIM,AVERZBX[NVERZBX,2],AVERZBX[NVERZBX,4],AVERZBX[NVERZBX,5],STR0197}) //" ==> EXISTE MINUTA COM STATUS DIFERENTE DE 1=PREVISTA"
				NEXT 
			ENDIF 
		NEXT _V 
	NEXT _U

	IF LEN( AERROSZBX ) > 0
		IF EMPTY( CLOTE ) .AND. MSGYESNO(STR0198) //"Visualiza as inconsistências ?"
			LOCA00516(AERROSZBX,STR0199)  //VISUALIZA OS ERROS //"INCONSISTÊNCIAS"
		ENDIF
		RETURN .F.
	ENDIF
ENDIF

FP4->(DBSETORDER(2)) 		// FP4_FILIAL + FP4_PROJET + FP4_OBRA + FP4_AS + FP4_VIAGEM 
//ZA6->(DBSETORDER(1)) 		// ZA6_FILIAL, ZA6_PROJET, ZA6_OBRA, ZA6_SEQTRA, R_E_C_N_O_, D_E_L_E_T_
FPA->(DBSETORDER(1)) 		// FPA_FILIAL, FPA_PROJET, FPA_OBRA, FPA_SEQGRU, R_E_C_N_O_, D_E_L_E_T_
AGRAVAR := {}

FOR _V := 1 TO LEN( AFROTAS )
	CFROTA := AFROTAS[_V]
	FOR NPOS := 1 TO (DFIM-DINI)+1
		DDATAAUX := DINI + (NPOS-1)

		IF DOW(DDATAAUX) == 1 .OR. DOW(DDATAAUX) == 7	// EH SABADO OU DOMINGO
			IF FP4->(DBSEEK(XFILIAL("FP4")+FQ5->FQ5_SOT+FQ5->FQ5_OBRA+FQ5->FQ5_AS+FQ5->FQ5_VIAGEM))  //POSICIONA NO EQUIPAMENTO
				DO CASE
				CASE FP4->(DOW(DDATAAUX)==1 .AND. FP4_DOMING=="N") ; LOOP  //TRABALHA SÁBADO?
				CASE FP4->(DOW(DDATAAUX)==7 .AND. FP4_SABADO=="N") ; LOOP  //TRABALHA DOMINGO?
				ENDCASE
			ENDIF
			/*
			IF ZA6->( DBSEEK(XFILIAL("ZA6")+CPROJET+COBRA, .T. ) )
				IF ( DOW(DDATAAUX) == 1 .AND. ZA6->ZA6_DOMING == "N" ) .OR. ( DOW(DDATAAUX) == 7 .AND. ZA6->ZA6_SABADO == "N" )
					LOOP
				ENDIF
			ENDIF
			*/
			IF FPA->( DBSEEK(XFILIAL("FPA")+CPROJET+COBRA, .T. ) )
				IF ( DOW(DDATAAUX) == 1 .AND. FPA->FPA_DOMING == "N" ) .OR. ( DOW(DDATAAUX) == 7 .AND. FPA->FPA_SABADO == "N" )
					LOOP
				ENDIF
			ENDIF
		ENDIF
		AADD(AGRAVAR,{CFROTA,DDATAAUX,CPROJET,COBRA,0,FQ5->FQ5_HORINI,FQ5->FQ5_HORFIM})  //A QUINTA POSIÇÃO É PARA GUARDAR O RECNO() NA FAJUSTAZBX()
	NEXT NPOS 
NEXT

IF LMINUTA 											// POR PADRÃO DEVE GRAVAR A MINUTA
	NGRAVADOS := FAJUSTAZBX(CAS, AGRAVAR, CLOTE) 	// AJUSTA AS MINUTAS DA AS INFORMADA   --- AQUI GRAVA/GERA A MINUTA
	IF LEN(AGRAVAR) == 0
		IF EMPTY( CLOTE )
			MSGALERT(STR0200 , STR0022) //"Nenhuma data selecionada para geração da minuta."###"Atenção!"
		ENDIF
		RETURN .F.
	ENDIF
	IF EMPTY( CLOTE )
		MSGINFO(STR0143+ALLTRIM(STR(NGRAVADOS))+STR0201 , STR0022)  //"Foram geradas "###" minutas para a AS selecionada."###"Atenção!"
	ELSE
		NTOTMIN += NGRAVADOS
	ENDIF
ENDIF

IF NGRAVADOS > 0 .OR. ! LMINUTA
	CPARA	:= SUPERGETMV("MV_LOCX057",.F.,"LOLIVEIRA@ITUP.COM.BR")
	EFROM 	:= ALLTRIM(USRRETNAME(__CUSERID)) + " <" + ALLTRIM(USRRETMAIL(__CUSERID)) + ">"
	CTITULO := STR0202 + ALLTRIM(FQ5->FQ5_AS) + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + STR0203 //"AS No. "###"PROJETO"###" Aceita "

	CMSG	:= CTITULO + "<BR><BR>"
	CMSG	+= STR0086 + USRRETNAME(__CUSERID) + "<BR><BR>" //"Dados informados pelo usuário: "
	CMSG    += STR0046+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0084+ALLTRIM(FQ5->FQ5_DESTIN)+STR0085+ALLTRIM(FQ5->FQ5_NOMCLI)+"<BR><BR><BR>"  //"Data INI/FIM: "###", Obra: "###", Cliente: "
	IF NGRAVADOS > 0
		CMSG    += STR0143+ ALLTRIM(STR(NGRAVADOS)) +STR0204 //"Foram geradas "###" Minutas"
	ENDIF 

	CPARA := GETMV("MV_LOCX033",,"")

	IF _LC111ANT //EXISTBLOCK("LC111ANT") 											// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
		LANTACE := EXECBLOCK("LC111ANT",.T.,.T.,{ FQ5->FQ5_AS, CTITULO, CMSG, CLOTE })
	ENDIF

	IF LANTACE 
		IF FQ5->(RECLOCK("FQ5",.F.))
			FQ5->FQ5_STATUS := "6"
			FQ5->FQ5_ACEITE := DDATABASE
			FQ5->(MSUNLOCK()) 
		ENDIF 
		IF _LC111ACE //EXISTBLOCK("LC111ACE") 										// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
			EXECBLOCK("LC111ACE",.T.,.T.,{FQ5->FQ5_AS , CTITULO , CMSG}) 
		ENDIF 
		IF LROMANEIO .AND. ALLTRIM(FQ5->FQ5_TPAS) == "F"
			GERROMAN()
		ENDIF
		IF EMPTY(CLOTE) 
			LOCA05909( EFROM, CPARA , "", CTITULO, CMSG, "" , "") 
		ENDIF 
	ENDIF 
ELSE 
	IF EMPTY( CLOTE ) 
		MSGALERT(STR0205 , STR0022)  //"Não foi gerada nenhuma minuta para a AS selecionada."###"Atenção!"
	ENDIF 
ENDIF

RETURN .T.



// ======================================================================= \\
STATIC FUNCTION FAJUSTAZBX(CAS, AGRAVAR, CLOTE)  	
// ======================================================================= \\
// --> AJUSTA AS MINUTAS DA AS INFORMADA 

LOCAL   AAREADTQ  := FQ5->( GETAREA() )
LOCAL   NPOS , NGRAVADOS 
LOCAL   CTIPOSE
LOCAL   LPULA
LOCAL   AERROSZBX := {}
LOCAL   AEXCLUIR  := {}
Local   _LC111ZBX := EXISTBLOCK("LC111ZBX")

DEFAULT CLOTE     := ""

FQ5->( DBSETORDER(9) )
IF FQ5->( DBSEEK( XFILIAL("FQ5") + CAS, .T. ) ) .AND. FQ5->FQ5_TPAS != "F"
	//FMONTAZBX("QRYZBX",CAS) 						// MONTA A QUERY 
	FMONTAZBX("QRYFPF",CAS) 						// MONTA A QUERY 
	QRYFPF->(DBGOTOP())
	WHILE QRYFPF->(!EOF())
		NPOS := QRYFPF->(ASCAN(AGRAVAR,{|X| X[1]+DTOS(X[2])==FPF_FROTA+DTOS(FPF_DATA)}))
		IF NPOS==0 									// VAI EXCLUIR A MINUTA
			IF QRYFPF->(FPF_STATUS$"1,5") 			// 1=PREVISTA , 2=CONFIRMADA , 3=BAIXADA , 4=ENCERRADA , 5=CANCELADA , 6=MEDIDA
				QRYFPF->(AADD(AEXCLUIR,FPF_RECNO))  // VAI EXCLUIR A MINUTA
			ELSE
				QRYFPF->(AADD(AERROSZBX,{FPF_FROTA,FPF_AS,FPF_DATA,FPF_DATA,FPF_DATA,FPF_MINUTA,FPF_STATUS,STR0206+FPF_MINUTA+STR0207+DTOC(FPF_DATA)+".",STR0208+FPF_MINUTA+STR0209})) //"EXISTE UMA MINUTA ("###") CONFIRMADA NO DIA "###"ESTORNAR A MINUTA "###" E ACEITAR A AS NOVAMENTE."
			ENDIF
		ELSE
			AGRAVAR[NPOS,5] := QRYFPF->FPF_RECNO  	// 5=GUARDA O RECNO()
		ENDIF
		QRYFPF->(DBSKIP())
	ENDDO 
ENDIF 

NGRAVADOS := 0 

IF LEN(AERROSZBX) == 0								// CRIACAO DA MINUTA
	FOR NPOS:=1 TO LEN(AGRAVAR)
		IF AGRAVAR[NPOS,5] == 0  					// 5=GUARDA O RECNO()
			LPULA := .F.

			IF LEFT( CAS, 2 ) == "31"				// FRETE DE LOCAÇÃO 
				CTIPOSE := "T"
			ELSE						// SENÃO BUSCA O BEM
				CTIPOSE := POSICIONE("ST9",1,XFILIAL("ST9")+AGRAVAR[NPOS,1], "T9_TIPOSE")
			ENDIF 

			IF CTIPOSE == "T"
				FPF->( DBSETORDER(5) )	// FPF_FILIAL, FPF_DATA, FPF_FROTA, FPF_MINUTA, R_E_C_N_O_, D_E_L_E_T_
				FPF->( DBSEEK( XFILIAL("FPF") + DTOS(AGRAVAR[NPOS,2]) + AGRAVAR[NPOS,1], .T. ) )
				WHILE ! FPF->( EOF() ) .AND. FPF->FPF_FILIAL == XFILIAL("FPF") .AND. FPF->FPF_DATA == AGRAVAR[NPOS,2] .AND. FPF->FPF_FROTA == AGRAVAR[NPOS,			1]
					IF FPF->FPF_PROJET == AGRAVAR[NPOS,3] .AND. FPF->FPF_OBRA == AGRAVAR[NPOS,4]                                                                   	
						LPULA := .T.
						NGRAVADOS++
						EXIT 
					ENDIF 
					FPF->( DBSKIP() ) 
				ENDDO 
			ENDIF 

			IF ! LPULA .AND. RECLOCK("FPF",.T.)
				FPF->FPF_FILIAL := XFILIAL("FPF")
				FPF->FPF_FROTA  := AGRAVAR[NPOS,1]
				IF LEFT( CAS, 2 ) == "06"
					FPF->FPF_TIPOSE := "E"			// MAO DE OBRA 
				ELSE
					FPF->FPF_TIPOSE := CTIPOSE		// POSICIONE("ST9",1,XFILIAL("ST9")+AGRAVAR[NPOS,1], "T9_TIPOSE")
				ENDIF 
				FPF->FPF_DATA   := AGRAVAR[NPOS,2]
				FPF->FPF_MINUTA := FPROXIMAM()		// GETSXENUM("FPF","FPF_MINUTA")
				FPF->FPF_AS     := CAS
				FPF->FPF_PROJET := AGRAVAR[NPOS,3]
				FPF->FPF_OBRA   := AGRAVAR[NPOS,4]
				FPF->FPF_STATUS := "1"  			// 1=PREVISTA,2=CONFIRMADA,3=BAIXADA,4=ENCERRADA,5=CANCELADA,6=MEDIDA
				FPF->FPF_HORAI  := AGRAVAR[NPOS, 6]
				FPF->FPF_HORAF  := AGRAVAR[NPOS, 7]
				FPF->FPF_EMISSA := DDATABASE
				NGRAVADOS++
				FPF->(MSUNLOCK())
				CONFIRMSX8()

				IF _LC111ZBX //EXISTBLOCK("LC111ZBX") 								// --> PONTO DE ENTRADA EXECUTADO APÓS A GRAVAÇÃO DA ZBX.
					EXECBLOCK("LC111ZBX",.T.,.T., NIL)
				ENDIF
			ENDIF
		ELSE
			NGRAVADOS++
		ENDIF
	NEXT

	FOR NPOS:=1 TO LEN(AEXCLUIR)
		FPF->(DBGOTO(AEXCLUIR[NPOS])) 				// POSICIONA NA MINUTA
		IF RECLOCK("FPF",.F.)
			FPF->(DBDELETE()) 						// 1=PREVISTA,2=CONFIRMADA,3=BAIXADA,4=ENCERRADA,5=CANCELADA,6=MEDIDA
			FPF->FPF_DTOCOR := DDATABASE
			FPF->(MSUNLOCK())
		ENDIF
	NEXT
ELSE
	IF EMPTY( CLOTE ) .AND. MSGYESNO(STR0198) //"Visualiza as inconsistências ?"
		LOCA05924(AERROSZBX,STR0199) 	// VISUALIZA OS ERROS //"INCONSISTÊNCIAS"
		RETURN(NGRAVADOS)
	ENDIF
ENDIF

FQ5->( RESTAREA( AAREADTQ ) )

RETURN(NGRAVADOS)



// ======================================================================= \\
STATIC FUNCTION FMONTAZBX(CALIASQRY,CAS) 
// ======================================================================= \\
// --> MONTA A QUERY
LOCAL AESTRU , CQRY := "" , CCRLF := CHR(13)+CHR(10) 
LOCAL NPOS := 0 
Local _cCampos := ""

_cCampos := "FPF_FROTA,FPF_AS,FPF_DATA,FPF_STATUS,FPF_MINUTA,FPF_HORAI,FPF_HORAF,FPF_FILIAL,FPF_RECNO"

CQRY += " SELECT FPF_FROTA , FPF_AS    , FPF_DATA   , FPF_STATUS , FPF_MINUTA , " + CCRLF 
CQRY +=        " FPF_HORAI , FPF_HORAF , FPF_FILIAL , R_E_C_N_O_ AS FPF_RECNO "   + CCRLF 
CQRY += " FROM " + RETSQLNAME("FPF") + " ZBX" + CCRLF
CQRY += " WHERE  ZBX.D_E_L_E_T_=''" + CCRLF
CQRY +=   " AND  FPF_FILIAL = '" + XFILIAL("FPF") + "'" + CCRLF
CQRY +=   " AND  FPF_AS     = '" + CAS            + "'" + CCRLF
CQRY := CHANGEQUERY(CQRY)
IF !SELECT(CALIASQRY) == 0
	(CALIASQRY)->(DBCLOSEAREA())
ENDIF
DBUSEAREA(.T. , "TOPCONN" , TCGENQRY(,,CQRY) , CALIASQRY , .F. , .T.) 

AESTRU := FPF->(DBSTRUCT()) 
FOR NPOS:=1 TO LEN(AESTRU)
	IF AESTRU[NPOS][2]<>"C" .AND. AESTRU[NPOS][2]<>"M"
		//IF (CALIASQRY)->(!TYPE(AESTRU[NPOS][1])=="U")
		If alltrim(AESTRU[NPOS][1]) $ _cCampos
			TCSETFIELD(CALIASQRY,AESTRU[NPOS][1],AESTRU[NPOS][2],AESTRU[NPOS][3],AESTRU[NPOS][4]) 
		ENDIF
	ENDIF
NEXT NPOS 

RETURN NIL



// ======================================================================= \\
STATIC FUNCTION FPROXIMAM() 	
// ======================================================================= \\
// --> TRAZ A PRÓXIMA MINUTA

LOCAL AAREA    := GETAREA()
LOCAL AAREAZBX := FPF->(GETAREA()) 
LOCAL CRET

FPF->( DBSETORDER(2) ) 			// FPF_FILIAL+FPF_MINUTA

WHILE .T.
	CRET := GETSXENUM("FPF","FPF_MINUTA")
	IF ! FPF->( DBSEEK(XFILIAL("FPF")+CRET) )
		EXIT
	ELSE
		CONFIRMSX8()
	ENDIF 
ENDDO 

RESTAREA(AAREAZBX)
RESTAREA(AAREA)

RETURN CRET



/*
// ======================================================================= \\
STATIC FUNCTION FDEBUG(CMENS)
// ======================================================================= \\
// --> NÃO EXISTE NENHUMA CHAMADA !
LOCAL LRET := .T. 

IF PSWADMIN(,,__CUSERID)==0 			// ADMINISTRADOR 
	IF !MSGYESNO(CMENS)
		LRET:=.F.
	ENDIF
ENDIF

RETURN(LRET)
*/



// ======================================================================= \\
FUNCTION LOCA05924(AERROS,CTITJAN) 
// ======================================================================= \\
// --> VISUALIZA OS ERROS
LOCAL NPOS , ACOLS , ACOLS0 , AHEADER , BHEADER , ODLG , ABUTTONS:={}
LOCAL NSTATUS , ASTATUS:=FSTATUS("LOCA00516")  	// MONTA OS STATUS

PRIVATE OBROWSE

ACOLS:={}
FOR NPOS:=1 TO LEN(AERROS)
	ACOLS0:={}
	AADD(ACOLS0,AERROS[NPOS,1])
	AADD(ACOLS0,AERROS[NPOS,2])
	AADD(ACOLS0,AERROS[NPOS,3])
	AADD(ACOLS0,AERROS[NPOS,4])
	AADD(ACOLS0,AERROS[NPOS,5])
	AADD(ACOLS0,AERROS[NPOS,6])
	AADD(ACOLS0,AERROS[NPOS,8])  				// INCONSISTÊNCIA
	AADD(ACOLS0,AERROS[NPOS,9])  				// SOLUÇÃO
	AADD(ACOLS0,AERROS[NPOS,7])  				// STATUS
	AADD(ACOLS,ACOLS0)
NEXT NPOS 

AHEADER := {}
BHEADER := "{||ACOLS[OBROWSE:AT(),7]}";AADD(AHEADER,{OEMTOANSI(STR0210),&BHEADER,"C","@X",1,40,0}) //"Inconsistência"
BHEADER := "{||ACOLS[OBROWSE:AT(),8]}";AADD(AHEADER,{OEMTOANSI(STR0211       ),&BHEADER,"C","@X",1,40,0}) //"Solução"
BHEADER := "{||ACOLS[OBROWSE:AT(),1]}";AADD(AHEADER,{OEMTOANSI(STR0122   ),&BHEADER,"C","@!",1,10,0}) //"Equipamento"
BHEADER := "{||ACOLS[OBROWSE:AT(),2]}";AADD(AHEADER,{OEMTOANSI(STR0212        ),&BHEADER,"C","@!",1,10,0}) //"Nro AS"
BHEADER := "{||ACOLS[OBROWSE:AT(),3]}";AADD(AHEADER,{OEMTOANSI(STR0213        ),&BHEADER,"D","@E",1,08,0}) //"Início"
BHEADER := "{||ACOLS[OBROWSE:AT(),4]}";AADD(AHEADER,{OEMTOANSI(STR0214           ),&BHEADER,"D","@E",1,08,0}) //"Fim"
BHEADER := "{||ACOLS[OBROWSE:AT(),5]}";AADD(AHEADER,{OEMTOANSI(STR0215          ),&BHEADER,"D","@E",1,08,0}) //"Data"
BHEADER := "{||ACOLS[OBROWSE:AT(),6]}";AADD(AHEADER,{OEMTOANSI(STR0216        ),&BHEADER,"C","@!",1,10,0}) //"Minuta"
BHEADER := "{||ACOLS[OBROWSE:AT(),9]}";AADD(AHEADER,{OEMTOANSI(STR0217        ),&BHEADER,"C","@!",1,01,0}) //"Status"

DEFINE MSDIALOG ODLG FROM 100,0 TO 500,1000 TITLE OEMTOANSI(CTITJAN) OF OMAINWND PIXEL
	OBROWSE := FWBROWSE():NEW() 
	OBROWSE:SETDATAARRAY()
	OBROWSE:SETARRAY(ACOLS)
	FOR NSTATUS:=1 TO LEN(ASTATUS)
		OBROWSE:ADDLEGEND(ASTATUS[NSTATUS,3],ASTATUS[NSTATUS,1],ASTATUS[NSTATUS,2])
	NEXT
	OBROWSE:SETCOLUMNS(AHEADER)
	OBROWSE:SETOWNER(ODLG)
	OBROWSE:DISABLEREPORT()
	OBROWSE:DISABLECONFIG()
	OBROWSE:ACTIVATE()
ACTIVATE MSDIALOG ODLG CENTERED ON INIT ENCHOICEBAR(ODLG,{|| ODLG:END() },{|| ODLG:END() },,ABUTTONS)

RETURN



/*/{PROTHEUS.DOC} GERROMAN
@DESCRIPTION GERACAO DE ROMANEIO.
@TYPE FUNCTION
@AUTHOR  IT UP BUSINESS
@SINCE   10/08/2016
@VERSION 1.0
/*/
// ======================================================================= \\
STATIC FUNCTION GERROMAN()
// ======================================================================= \\

LOCAL _AAREAOLD := GETAREA()
LOCAL _AAREAZUC := FQ7->(GETAREA())
LOCAL _AAREASZ0 := FQ2->(GETAREA())
LOCAL _CQUERY   := ""
LOCAL _CNUMROM  := ""

// --> BUSCA O ULTIMO NUMERO DE ROMANEIO.
_CQUERY := " SELECT MAX(FQ2_NUM) NUMROM" + CRLF
_CQUERY += " FROM " + RETSQLNAME("FQ2") + " SZ0" + CRLF
_CQUERY += " WHERE  FQ2_FILIAL = '" + XFILIAL("FQ2") + "'" + CRLF
_CQUERY += "   AND  SZ0.D_E_L_E_T_ = ' '" + CRLF
IF SELECT("TRBFQ2") > 0
	TRBFQ2->(DBCLOSEAREA())
ENDIF
_CQUERY := CHANGEQUERY(_CQUERY)
TCQUERY _CQUERY NEW ALIAS "TRBFQ2"

IF TRBFQ2->(EOF())
	_CNUMROM := STRZERO(1,GETSX3CACHE("FQ2_NUM","X3_TAMANHO"))
ELSE
	_CNUMROM := STRZERO(VAL(TRBFQ2->NUMROM)+1,GETSX3CACHE("FQ2_NUM","X3_TAMANHO"))
ENDIF

TRBFQ2->(DBCLOSEAREA())

IF ALLTRIM(FQ5->FQ5_TPAS) == "F"
	DBSELECTAREA("FQ7")
	FQ7->(DBSETORDER(3))				// FQ7_FILIAL + FQ7_VIAGEM
	IF FQ7->(DBSEEK(XFILIAL("FQ7") + FQ5->FQ5_VIAGEM))
		DBSELECTAREA("FQ2")
		FQ2->(DBSETORDER(3))			// FQ2_FILIAL + FQ2_ASF + FQ2_NUM
		IF FQ2->(!DBSEEK(XFILIAL("FQ2") + FQ5->FQ5_AS))
			IF RECLOCK("FQ2",.T.)
				FQ2->FQ2_FILIAL  := XFILIAL("FQ2")
				FQ2->FQ2_NUM	    := _CNUMROM
				FQ2->FQ2_PROJET  := FQ5->FQ5_SOT
				FQ2->FQ2_OBRA    := FQ5->FQ5_OBRA
				FQ2->FQ2_PEDIDO  := FQ5->FQ5_SOT
				FQ2->FQ2_ASF     := FQ5->FQ5_AS
				FQ2->FQ2_VIAGEM  := FQ5->FQ5_VIAGEM
				FQ2->FQ2_TPROMA := FQ7->FQ7_TPROMA
				FQ2->FQ2_CLIENT := FQ5->FQ5_CODCLI
				FQ2->FQ2_LOJA    := FQ5->FQ5_LOJA
				FQ2->FQ2_TIPOVE	:= FQ7->FQ7_X5COD
				FQ2->FQ2_PTIPVE := FQ7->FQ7_DESCRI
				FQ2->FQ2_OBS		:= FQ7->FQ7_OBS
				FQ2->FQ2_NOMCLI  := ALLTRIM(POSICIONE("SA1",1,XFILIAL("SA1") + FQ5->FQ5_CODCLI + FQ5->FQ5_LOJA,"A1_NOME"))
				FQ2->(MSUNLOCK())
			ENDIF
		ENDIF
	ENDIF
ENDIF

FQ2->(RESTAREA( _AAREASZ0 ))
FQ7->(RESTAREA( _AAREAZUC ))
RESTAREA( _AAREAOLD )

RETURN




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ LT111ROM  º AUTOR ³ IT UP BUSINESS     º DATA ³ 09/04/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ TELA PARA VINCULAR UM EQUIPAMENTOS AO FRETE, NA ROTINA DE  º±±
±±º          ³ ROMANEIO.                                                  º±±
±±º          ³ --> COPIADO DO P.E. LOC05101.PRW <--                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LOCA05925(_CASF , LMSROTAUTO, _CFILAUTO)  // FRANK 06/10/2020 INSERIDO A FILIAL DA REMESSA PARA O CASO DE SER AUTOMATICO

LOCAL _AAREAOLD  := GETAREA()
LOCAL _AAREADTQ  := FQ5->(GETAREA())
LOCAL _AAREASZ0  := FQ2->(GETAREA())
LOCAL _AAREASZ1  := FQ3->(GETAREA())
LOCAL _AAREAZUC  := FQ7->(GETAREA())
LOCAL _AAREAST9  := ST9->(GETAREA())
LOCAL _AAREASF2  := SF2->(GETAREA())
LOCAL _CERRO	 := ""
LOCAL _CQUERY	 := ""
LOCAL _CNUMROM   := ""
LOCAL CMV_LOCX014 := ""
LOCAL LUMAOPCAO  := .F.
LOCAL LMARCAITEM := .T.
LOCAL OOK        := LOADBITMAP(GETRESOURCES(),"LBOK")
LOCAL ONO        := LOADBITMAP(GETRESOURCES(),"LBNO")
LOCAL BACAO      := NIL
LOCAL OVINCZAG
LOCAL OCANC
LOCAL _NOPC      := 0
LOCAL NINICIAL   := 0 
LOCAL _NQTD		 := 0 // CONTROLE DO SALDO NA SZ1
LOCAL _NENV      := 0 // QUANTIDADE ENVIADA PELA NOTA DE SAIDA
LOCAL _NRET      := 0 // QUANTIDADE JA PROGRAMADA EM ROMANEIO
LOCAL _LFORCA    := .F. // FORCA HABILITAR O BOTACO DE VINCULAR - FRANK 26/10/20
Local lLOCX304	 := SuperGetMV("MV_LOCX304",.F.,.F.) // Utiliza o cliente destino informado na aba conjunto transportador será o utilizado como cliente da nota fiscal de remessa,
Local lLOCA59E   := EXISTBLOCK("LOCA59E")    
Local lLOCA59F   := EXISTBLOCK("LOCA59F")

PRIVATE _AARRAY  := {}
PRIVATE _ABACK   := {} // USADO PARA FAZER UM BACKUP DOS ROMANEIOS DE RETORNO PARCIAL. FRANK 15/10/20
PRIVATE OLISTBOX


DEFAULT _CASF 		:= FQ5->FQ5_AS
DEFAULT	LMSROTAUTO 	:= .F.
DEFAULT _CFILAUTO	:= CFILANT

IF SBM->(FIELDPOS("BM_XACESS")) > 0
	CMV_LOCX014 := LOCA00189()
ELSE
	CMV_LOCX014 := SUPERGETMV("MV_LOCX014",.F.,"")
ENDIF

DBSELECTAREA("FQ5")
FQ5->(DBSETORDER(9))
IF FQ5->(DBSEEK(XFILIAL("FQ5") + _CASF))
	IF FQ5->FQ5_STATUS <> "6" .OR. FQ5->FQ5_TPAS <> "F"
		_CERRO := STR0218 //"ASF não está aceita, ou não é do tipo frete!"
	ENDIF

	DBSELECTAREA("FQ2")
	FQ2->(DBSETORDER(3))			// FQ2_FILIAL + FQ2_ASF + FQ2_NUM
	IF !FQ2->(DBSEEK(XFILIAL("FQ2") + _CASF)) .AND. EMPTY(_CERRO)
		_CERRO := STR0219 //"Romaneio não encontrado!"

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
				FQ2->FQ2_NOMCLI  := ALLTRIM(POSICIONE("SA1" , 1 , XFILIAL("SA1") + FQ5->FQ5_CODCLI + FQ5->FQ5_LOJA , "A1_NOME")) 
				FQ2->(MSUNLOCK())
				_CERRO := ""

				// GUARDAR NUMERO DO ROMANEIO NO NOVO CAMPO
				FQ5->(RECLOCK("FQ5",.F.))
				FQ5->FQ5_XROMAN := FQ2->FQ2_NUM
				FQ5->(MSUNLOCK())
			ENDIF
		ENDIF
	ENDIF

ELSE
	_CERRO := "ASF " + ALLTRIM(_CASF) + STR0220 //" Não encontrada!"
ENDIF

// VERIFICAR SE É A VIAGEM DE RETORNO - FRANK - 15/10/20
IF EMPTY(_CERRO)
	FQ7->(DBSETORDER(3)) // FILIAL + VIAGEM
	IF !FQ7->(DBSEEK(XFILIAL("FQ7")+FQ5->FQ5_VIAGEM))
		_CERRO := STR0221 //"Viagem não localizada no conjunto transportador."
	ENDIF
ENDIF

IF EMPTY(_CERRO)

	/*
		PROCEDIMENTO PARA SEPARAÇÃO DO QUE É REMESSA E RETORNO DE LOCAÇÃO.
		ESSE PROCEDIMENTO FOI NECESSÁRIO CRIAR POIS A SELEÇÃO DOS ITENS DE RETORNO SERÁ FEITO PELO PEDIDO COMERCIAL.
	*/
	IF .T.	// FQ2->FQ2_TPROMA == "0" 				// --> PROCESSA SOMENTE REMESSA

		If lLOCX304 .And. FQ2->FQ2_TPROMA == "1"
			//_CQUERY     += "  SELECT DISTINCT FQ7_LCCORI, FQ7_LCLORI, FQ7_LCCDES, FQ7_LCLDES, FPA_PROJET PROJETO , FPA_GRUA CODBEM , ISNULL(T9_NOME,FPA_DESGRU) BEM , "                    + CRLF
			_CQUERY     += "  SELECT DISTINCT F2_CLIENTE, F2_LOJA, FPA_PROJET PROJETO , FPA_GRUA CODBEM , COALESCE(T9_NOME,FPA_DESGRU) BEM , "                    + CRLF
		Else
			_CQUERY     += "  SELECT  FPA_PROJET PROJETO , FPA_GRUA CODBEM , COALESCE(T9_NOME,FPA_DESGRU) BEM , "                    + CRLF
		EndIf
		_CQUERY     += "          COALESCE(T6_NOME,FPA_DESGRU) FAMILIA , FPA_SEQGRU , FPA_AS , FPA_PRODUT, FPA_QUANT, FPA_FILREM, FPA_FILEMI, FPA_OBRA, ZAG.R_E_C_N_O_ AS REG, "           + CRLF
		_CQUERY     += "   FPA_FILREM, FPA_NFREM, FPA_SERREM, FPA_ITEREM "
		_CQUERY     += "  FROM " + RETSQLNAME("FPA")+" ZAG (NOLOCK)"                                                           + CRLF
		_CQUERY     += "  	      INNER JOIN " + RETSQLNAME("FQ5") + " DTQ (NOLOCK) ON  DTQ.FQ5_AS     = ZAG.FPA_AS "          + CRLF
		_CQUERY     += "                                                            AND DTQ.FQ5_STATUS = '6' "                 + CRLF
		_CQUERY     += "                                                            AND DTQ.D_E_L_E_T_ = '' "                  + CRLF
		_CQUERY     += "  	      LEFT  JOIN " + RETSQLNAME("ST9") + " ST9 (NOLOCK) ON  ST9.T9_CODBEM  = ZAG.FPA_GRUA "        + CRLF
		_CQUERY     += "  	                                                        AND ST9.D_E_L_E_T_ = '' "                  + CRLF
		_CQUERY     += "  	      LEFT  JOIN " + RETSQLNAME("ST6") + " ST6 (NOLOCK) ON  ST6.T6_CODFAMI = ST9.T9_CODFAMI "      + CRLF
		_CQUERY     += "  	                                                        AND ST6.D_E_L_E_T_ = '' "                  + CRLF
		If lLOCX304 .And. FQ2->FQ2_TPROMA == "1"
			_CQUERY     += "  	      LEFT JOIN " + RETSQLNAME("FQ7") + " FQ7 "      + CRLF
			_CQUERY     += "  	      	ON FQ7_FILIAL = '" + FQ5->FQ5_FILORI + "' "      + CRLF
			_CQUERY     += "  	     	AND FQ7.D_E_L_E_T_ = ' ' "      + CRLF
			_CQUERY     += "  	      	AND FQ7_PROJET = FPA_PROJET "      + CRLF
			_CQUERY     += "  	      	AND FPA_OBRA = FPA_OBRA "      + CRLF
			_CQUERY     += "  	      	AND FQ7_SEQGUI = FPA_SEQGRU "      + CRLF
			_CQUERY     += "  	      LEFT JOIN " + RETSQLNAME("SF2") + " SF2 "      + CRLF
			_CQUERY     += "  	      	ON F2_FILIAL = FPA_FILREM "      + CRLF
			_CQUERY     += "  	      	AND F2_DOC = FPA_NFREM "      + CRLF
			_CQUERY     += "  	      	AND F2_SERIE = FPA_SERREM "      + CRLF
			_CQUERY     += "  	      	AND SF2.D_E_L_E_T_ = ' ' "      + CRLF
		EndIf
		_CQUERY     += " WHERE    ZAG.FPA_FILIAL =  '" + FQ5->FQ5_FILORI + "'"                                                 + CRLF
		_CQUERY     += "   AND    ZAG.FPA_PROJET =  '" + FQ5->FQ5_SOT    + "'"                                                 + CRLF
		_CQUERY     += "   AND    ZAG.FPA_OBRA   =  '" + FQ5->FQ5_OBRA   + "'"                                                 + CRLF
		_CQUERY     += "   AND    ZAG.FPA_AS     <> '' "                                                                       + CRLF
		// alterado por Frank em 28/09/21 para aceitar tambem os itens substituidos
		_CQUERY     += "   AND    (ZAG.FPA_TIPOSE =  'L' OR  ZAG.FPA_TIPOSE =  'S')"                                                                      + CRLF
		_CQUERY     += "   AND    ZAG.D_E_L_E_T_ =  '' "                                                                       + CRLF
		IF     (FQ2->FQ2_TPROMA == "0")				// --> REMESSA
			_CQUERY += "   AND    ZAG.FPA_NFREM  =  '' "                                                                       + CRLF
		ELSEIF (FQ2->FQ2_TPROMA == "1")				// --> RETORNO
			_CQUERY += "   AND    ZAG.FPA_NFREM  <> '' "                                                                       + CRLF
			//_CQUERY += "   AND    ZAG.FPA_DTPRRT <> '' "                                                                       + CRLF FRANK REMOVEU EM 02/11/20
			_CQUERY += "   AND    ZAG.FPA_NFRET  =  '' "                                                                       + CRLF
		ELSE
			RETURN
		ENDIF

		//IF FQ7->FQ7_TPROMA == "0" // VIAGEM DE IDA	removido por frank em 03/01/2022
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
		If lLOCX304 .And. FQ2->FQ2_TPROMA == "1"
			_CQUERY     += "                        AND  SZ0.FQ2_ASF     LIKE '%" + AllTrim(FQ2->FQ2_ASF) + "%' "                      + CRLF
		Else
			_CQUERY     += "                        AND  SZ0.FQ2_ASF     LIKE '%" + SUBSTR(_CASF,1,10) + "%' "                      + CRLF
		EndIf
			_CQUERY     += " 		                AND  SZ0.FQ2_TPROMA = '"+FQ2->FQ2_TPROMA+"' "                                  + CRLF
			_CQUERY     += " 		                AND  SZ0.D_E_L_E_T_ = '') "                                                    + CRLF
		//ENDIF
		

	ELSEIF FQ2->FQ2_TPROMA == "1"					// --> PROCESSA SOMENTE RETORNO

		/*
		_CQUERY := "  SELECT FPA_PROJET PROJETO , FPA_GRUA CODBEM , ISNULL(FPA_DESGRU,'') BEM , " + CRLF
		_CQUERY += "         COALESCE(FPA_DESGRU,'') FAMILIA , FPA_SEQGRU , FPA_AS , FPA_PRODUT, FPA_QUANT, FPA_FILREM, FPA_FILEMI, FPA_OBRA "  + CRLF
		_CQUERY += " FROM " + RETSQLNAME("FPA")+" ZAG "               + CRLF
		_CQUERY += " WHERE   FPA_FILIAL =  '" + FQ5->FQ5_FILORI + "'" + CRLF
		_CQUERY += "   AND   FPA_PROJET =  '" + FQ5->FQ5_SOT    + "'" + CRLF
		_CQUERY += "   AND   FPA_OBRA   =  '" + FQ5->FQ5_OBRA   + "'" + CRLF
		_CQUERY += "   AND   FPA_AS     <> '' "                       + CRLF
		_CQUERY += "   AND   FPA_NFREM  <> '' "                       + CRLF
		_CQUERY += "   AND   FPA_DTPRRT <> '' "                       + CRLF
		_CQUERY += "   AND   ZAG.D_E_L_E_T_ = '' "                    + CRLF
		*/

	ENDIF

	IF SELECT("TRBFPA") > 0
		TRBFPA->(DBCLOSEAREA())
	ENDIF

	//CONOUT("##LOCT111.PRW - LT111ROM() - _CQUERY: " + _CQUERY)
	_CQUERY := CHANGEQUERY(_CQUERY)
	TCQUERY _CQUERY NEW ALIAS "TRBFPA"

	IF TRBFPA->(EOF())
		AADD(_AARRAY , {.F. , "" , "" , "" , "" , "", 0,"","","",0,0}) // FRANK 06/10/2020 CONTROLE POR FILIAL
	ELSE

		If lLOCX304 .And. FQ2->FQ2_TPROMA == "1"
			cCliOri := LOCA05931("FQ2_CLIFAT") + LOCA05931("FQ2_LOJFAT")
		EndIf

		WHILE TRBFPA->(!EOF())

			//verifica se o cliente é o mesmo no conjunto transportador SOMENTE no retorno
			If lLOCX304 .And. FQ2->FQ2_TPROMA == "1"
				//Se for diferente pula
				lForca := .F.
				If lLOCA59E	
					lForca := EXECBLOCK("LOCA59E",.T.,.T.,{})
				EndIf
				If LOCA05931("FQ2_CLIFAT") + LOCA05931("FQ2_LOJFAT") <> TRBFPA->( F2_CLIENTE + F2_LOJA ) .or. lForca
					TRBFPA->(DBSKIP())
					Loop
				EndIf 
			EndIf
			IF FQ7->FQ7_TPROMA == "1" // VIAGEM DE RETORNO FRANK - 15/10/20
				// VALIDAR A QUANTIDADE LIBERADA POR ROMANEIO - FRANK 14/10/2020
				_NQTD := 0

				// ENCONTRAR A QUANTIDADE ENVIADA (NOTA FISCAL DE SAIDA)
				_NENV := 0
				IF !EMPTY(TRBFPA->FPA_NFREM)
					SC6->(DBSETORDER(4))
					SC6->(DBSEEK(substr(TRBFPA->FPA_FILREM,1,tamsx3("FPA_FILREM")[1])+TRBFPA->FPA_NFREM+TRBFPA->FPA_SERREM))
					WHILE !SC6->(EOF()) .AND. SC6->(C6_FILIAL+C6_NOTA+C6_SERIE) == substr(TRBFPA->FPA_FILREM,1,tamsx3("FPA_FILREM")[1])+TRBFPA->FPA_NFREM+TRBFPA->FPA_SERREM
						IF ALLTRIM(SC6->C6_ITEM) == ALLTRIM(TRBFPA->FPA_ITEREM)
							_NENV := SC6->C6_QTDVEN
							EXIT
						ENDIF
						SC6->(DBSKIP())
					ENDDO
				ENDIF

				// ENCONTRAR O QUE JÁ FOI PROGRAMADO EM ROMANEIO
				/*
				_NRET := 0
				_CQUERY := " SELECT FQ3_QTD "
				_CQUERY += " FROM " + RETSQLNAME("FQ3") + " SZ1" 
				_CQUERY += " WHERE  FQ3_FILIAL = '" + XFILIAL("FQ3") + "'" 
				_CQUERY += "   AND  FQ3_NUM = '" + FQ2->FQ2_NUM + "'" 
				_CQUERY += "   AND  FQ3_ASF = '" + FQ5->FQ5_AS + "'"
				_CQUERY += "   AND  SZ1.D_E_L_E_T_ = ''"
				IF SELECT("TRBSZ1") > 0
					TRBFQ3->(DBCLOSEAREA())
				ENDIF
				TCQUERY _CQUERY NEW ALIAS "TRBSZ1" 
				_NRET := TRBFQ3->FQ3_QTD
				TRBFQ3->(DBCLOSEAREA())
				*/

				_NRET := 0
				/*
				_CQUERY := " SELECT SUM(FQ3_QTD) AS TOT "
				_CQUERY += " FROM " + RETSQLNAME("FQ3") + " SZ1" 
				_CQUERY += " WHERE "
				_CQUERY += "       SZ1.FQ3_FILIAL = '"+XFILIAL("FQ3")+"' AND "
				_CQUERY += "       SZ1.FQ3_AS = '"+TRBFPA->FPA_AS+"' AND "
				//_CQUERY += "       SZ1.FQ3_VIAGEM = '"+FPA->FPA_VIAGEM+"' AND "
				//_CQUERY += "       SZ1.FQ3_NUM = '"+SF1->F1_IT_ROMA+"' AND "
				_CQUERY += "       SZ1.D_E_L_E_T_ = '' "
				IF SELECT("TRBSZ1") > 0
					TRBFQ3->(DBCLOSEAREA())
				ENDIF
				TCQUERY _CQUERY NEW ALIAS "TRBSZ1" 
				_NRET := TRBFQ3->TOT
				TRBFQ3->(DBCLOSEAREA())
				*/

				FQZ->(DBSETORDER(2))
				FQZ->(DBSEEK(XFILIAL("FQZ")+TRBFPA->PROJETO))
				WHILE !FQZ->(EOF()) .AND. FQZ->FQZ_FILIAL == XFILIAL("FQZ") .AND. FQZ->FQZ_PROJET == TRBFPA->PROJETO
					IF FQZ->FQZ_OBRA == TRBFPA->FPA_OBRA
						IF FQZ->FQZ_MSBLQL == "2"
							IF ALLTRIM(FQZ->FQZ_AS) == ALLTRIM(TRBFPA->FPA_AS)
								_NRET += FQZ->FQZ_QTD //TRBFPA->FPA_QUANT
							ENDIF
						ENDIF
					ENDIF

					FQZ->(DBSKIP())
				ENDDO


				_NQTD := _NENV - _NRET
				

			ELSE
				_NQTD := TRBFPA->FPA_QUANT
			ENDIF
			
			IF TRBFPA->FPA_QUANT >= _NQTD .OR. FQ7->FQ7_TPROMA == "1" // CONTROLE DA QUANTIDADE FRANK 14/10/2020

				SB1->(DBSETORDER(1))
				SB1->(DBSEEK(XFILIAL("SB1")+TRBFPA->FPA_PRODUT))

				IF EMPTY(TRBFPA->CODBEM) .AND. ALLTRIM(GETADVFVAL("SB1", "B1_GRUPO",XFILIAL("SB1")+TRBFPA->FPA_PRODUT,1,"")) $ ALLTRIM(CMV_LOCX014)
					AADD(_AARRAY , {.F. , TRBFPA->FAMILIA , TRBFPA->CODBEM , ALLTRIM(GETADVFVAL("SB1","B1_DESC",XFILIAL("SB1")+TRBFPA->FPA_PRODUT,1,"")) , TRBFPA->FPA_SEQGRU , TRBFPA->FPA_AS, TRBFPA->FPA_QUANT, TRBFPA->FPA_PRODUT, SB1->B1_DESC, TRBFPA->FPA_FILEMI, _NQTD, TRBFPA->REG	}) 
				ELSE
					AADD(_AARRAY , {.F. , TRBFPA->FAMILIA , TRBFPA->CODBEM , TRBFPA->BEM                                                                 , TRBFPA->FPA_SEQGRU , TRBFPA->FPA_AS, TRBFPA->FPA_QUANT, TRBFPA->FPA_PRODUT, SB1->B1_DESC, TRBFPA->FPA_FILEMI, _NQTD, TRBFPA->REG}) 
				ENDIF

				IF FQ7->FQ7_TPROMA == "0"
					_AARRAY[LEN(_AARRAY)][1] := .T.
					_LFORCA := .T.
				ELSE
					If !lLOCX304
						_AARRAY[LEN(_AARRAY)][1] := .T.
						_LFORCA := .T.
					EndIf
				ENDIF

			ENDIF

			TRBFPA->(DBSKIP())
		ENDDO
	ENDIF

	//TRBFPA->(DBCLOSEAREA())
	lForca := .F.
	If lLOCA59F	
		lForca := EXECBLOCK("LOCA59F",.T.,.T.,{})
	EndIf
	If Len(_AARRAY) == 0 .or. lForca
		AADD(_AARRAY , {.F. , "" , "" , "" , "" , "", 0,"","","",0,0}) 
	EndIf

	_ABACK := _AARRAY // BACKUP ANTES DE INFORMAR OS ROMANEIOS PARCIAIS - FRANK 15/10/20

	IF !LMSROTAUTO
		DEFINE MSDIALOG ODLG1 TITLE STR0222 FROM 0,0 TO 25,86 OF OMAINWND //"Vínculo frete X equipamento"
			@ 1.5 , .7 LISTBOX OLISTBOX FIELDS ; 
			           HEADER  " " , STR0223 , STR0224 , STR0225 , STR0226 , "AS", STR0227,STR0228,STR0229,STR0230,STR0231,STR0128 SIZE 330,147 ;  //"Família"###"Cód. bem"###"Bem"###"Sequência"###"Quantidade"###"Cód.prod"###"Desc.prod"###"Fil.remessa"###"Qtd.ret"###"Registro"
			           ON DBLCLICK (_AARRAY := FMARCAITM(OLISTBOX:NAT,_AARRAY,LUMAOPCAO,LMARCAITEM) , IIF((EMPTY(_AARRAY[OLISTBOX:NAT][4]) .OR. !FVERARRY(_AARRAY)) , OVINCZAG:DISABLE() , OVINCZAG:ENABLE()) , ; 
			           IIF(BACAO==NIL , , EVAL(BACAO)) , OLISTBOX:REFRESH()) 
	
			OLISTBOX:SETARRAY(_AARRAY)
			OLISTBOX:BLINE := { || { IIF(_AARRAY[OLISTBOX:NAT][1],OOK,ONO) , ; 
			                             _AARRAY[OLISTBOX:NAT][2]          , ; 
			                             _AARRAY[OLISTBOX:NAT][3]          , ; 
			                             _AARRAY[OLISTBOX:NAT][4]          , ; 
									     _AARRAY[OLISTBOX:NAT][5]          , ; 
									     _AARRAY[OLISTBOX:NAT][6]          , ;
										 _AARRAY[OLISTBOX:NAT][7]          , ;
										 _AARRAY[OLISTBOX:NAT][8]          , ;
										 _AARRAY[OLISTBOX:NAT][9]          , ;
										 _AARRAY[OLISTBOX:NAT][10]         , ;
										 _AARRAY[OLISTBOX:NAT][11]         , ;
										 _AARRAY[OLISTBOX:NAT][12]         } }
	
			@ 172, 7 BUTTON OVINCZAG PROMPT STR0232 SIZE 45,12 OF ODLG1 PIXEL ACTION (_NOPC := 1,ODLG1:END())  //"Vincular"
			OVINCZAG:DISABLE()
			IF _LFORCA
				OVINCZAG:ENABLE()
			ENDIF
			@ 172,57 BUTTON OCANC    PROMPT STR0132 SIZE 45,12 OF ODLG1 PIXEL ACTION (_NOPC := 0,ODLG1:END()) //"Cancelar"
			IF FQ7->FQ7_TPROMA == "1" // VIAGEM DE RETORNO - FRANK 15/10/20 - BOTAO PARA RETORNO PARCIAL
				@ 172,107 BUTTON ORETP   PROMPT STR0233  SIZE 45,12 OF ODLG1 PIXEL ACTION (RETPARX(OLISTBOX:NAT)) //"Ret.parcial"
			ENDIF
		ACTIVATE MSDIALOG ODLG1 CENTERED
	ELSE
		FOR NINICIAL := 1 TO LEN(_AARRAY)
			IF _AARRAY[NINICIAL][10] == _CFILAUTO // FRANK 06/10/2020 TRATAMENTO DA FILIAL DE REMESSA
				_AARRAY[NINICIAL][1]:= .T.	// SE FOR ROTINA AUTOMATICA TODOS OS ITENS SERÃO VINCULADOS
			ENDIF
		NEXT NINICIAL 
		_NOPC := 1
	ENDIF
	IF _NOPC == 1
		PROCESSA({|| FGERASZ1(_CASF) } , STR0234 , STR0235 , .T.)  //"Gravando no Romaneio..."###"Aguarde..."
	ENDIF

ELSE
	MSGALERT(_CERRO , STR0022)  //"Atenção!"
ENDIF

IF SELECT("TRBFPA")
	TRBFPA->(DBCLOSEAREA())
EndIF

RESTAREA( _AAREAST9 )
RESTAREA( _AAREAZUC )
RESTAREA( _AAREASZ1 )
RESTAREA( _AAREASZ0 )
RESTAREA( _AAREADTQ )
RESTAREA( _AAREAOLD )
RESTAREA( _AAREASF2 )

RETURN IIF(EMPTY(_CERRO) , .T. , .F.) 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ FGERASZ1  º AUTOR ³ IT UP BUSINESS     º DATA ³ 09/04/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ TELA PARA VINCULAR UM EQUIPAMENTOS AO FRETE, NA ROTINA DE  º±±
±±º          ³ ROMANEIO.                                                  º±±
±±º          ³ --> COPIADO DO P.E. LOC05101.PRW <--                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION FGERASZ1(_CASF)

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
_CQUERY := CHANGEQUERY(_CQUERY)
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
		FQ3->FQ3_VIAGEM  := POSICIONE("FPA" , 3 , XFILIAL("FPA") + _AARRAY[_NX][6] , "FPA_VIAGEM") 
		FQ3->FQ3_QTD		:= _AARRAY[_NX][11] // ERA A POSICAO 7 FRANK Z FUGA EM 14/10/20
		FQ3->FQ3_PROD	:= _AARRAY[_NX][8]
		FQ3->FQ3_DESPROD	:= _AARRAY[_NX][9]

		DBSELECTAREA("ST9")

		ST9->(DBSETORDER(1))
		IF ST9->(DBSEEK(XFILIAL("ST9") + _AARRAY[_NX][3]))
			FQ3->FQ3_CODBEM  := ST9->T9_CODBEM
			FQ3->FQ3_NOMBEM  := ST9->T9_NOME
			FQ3->FQ3_FAMBEM  := ST9->T9_CODFAMI
			FQ3->FQ3_FAMILIA := ALLTRIM(POSICIONE("ST6" , 1 , XFILIAL("ST6")+ST9->T9_CODFAMI , "T6_NOME")) 
			FQ3->FQ3_HORBEM  := ST9->T9_POSCONT
		ENDIF
		FQ3->(MSUNLOCK())

		_NITEM++
		_NGRAVA++
	ENDIF
NEXT _NX 

_CMSG := CVALTOCHAR(_NGRAVA) + STR0236 + CVALTOCHAR(_NRECEB) + STR0237 //" de "###" Itens foram gravados no romaneio."

IF _NGRAVA < _NRECEB
	_CMSG += CRLF + CRLF + STR0238 //"Verifique se o equipamento do projeto está OK no cadastro de bens!"
	MSGALERT(_CMSG , STR0022)  //"Atenção!"
ELSE
	MSGINFO(_CMSG , STR0022)  //"Atenção!"
ENDIF

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ FVERARRY  º AUTOR ³ IT UP BUSINESS     º DATA ³ 09/04/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ VERIFICA SE O ARRAY POSSUI ALGUM REGISTRO MARCADO COMO .T. º±±
±±º          ³ --> COPIADO DO P.E. LOC05101.PRW <--                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION FVERARRY(_AARRAY)

LOCAL _NCNT		 := 1
LOCAL _LRETORNO := .F.

WHILE _NCNT <= LEN(_AARRAY)
	IF _AARRAY[_NCNT][1]
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
±±ºPROGRAMA  ³ FMARCAITM º AUTOR ³ IT UP BUSINESS     º DATA ³ 09/04/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ MARCA E DESMARCA UM ÚNICO ITEM.                  		  º±±
±±º          ³ --> COPIADO DO P.E. LOC05101.PRW <--                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION FMARCAITM(NAT,_AARRAY,LUMAOPCAO,LMARCAITEM)
LOCAL _NX
LOCAL _CFILREM := _AARRAY[NAT][10] // FRANK 06/10/20 CONTROLE DA FILIAL DE REMESSA
LOCAL _AAREA   := GETAREA()
LOCAL _LBLOQ   := .F.

DEFAULT LMARCAITEM := .T.

IF TYPE("LUMAOPCAO") == "L" .AND. LUMAOPCAO
	//LMARCAITEM := .F.
ENDIF

// FRANK - 06/10/2020 NÃO PERMITE MARCAR ITENS DE FILIAIS DIFERENTES
FOR _NX := 1 TO LEN(_AARRAY)
	IF _NX <> NAT
		IF _AARRAY[_NX][10] <> _CFILREM .AND. _AARRAY[_NX][1]
			MSGALERT(STR0239+ALLTRIM(STR(_NX)),STR0022) //"Conflito de filiais de remessa, veja o item: "###"Atenção!"
			LMARCAITEM := .F.
			EXIT
		ENDIF
	ENDIF
NEXT

// FRANK - 06/10/2020 VERIFICAR NOS ITENS JÁ GRAVADOS SE HAVERÁ CONFLITO DE FILIAIS.
IF LMARCAITEM
	FQ3->(DBSETORDER(1))
	FQ3->(DBSEEK(XFILIAL("FQ3")+FQ2->FQ2_NUM))
	WHILE !FQ3->(EOF()) .AND. FQ3->FQ3_FILIAL == XFILIAL("FQ3") .AND. FQ3->FQ3_NUM == FQ2->FQ2_NUM
		FPA->(DBSETORDER(3))
		IF FPA->(DBSEEK(XFILIAL("FPA")+FQ3->FQ3_AS+FQ3->FQ3_VIAGEM))
			IF FPA->FPA_FILEMI <> _AARRAY[NAT][10]
				_LBLOQ := .T.
				EXIT
			ENDIF
		ENDIF
		FQ3->(DBSKIP())
	ENDDO
	IF _LBLOQ
		MSGALERT(STR0240,STR0022) //"Conflito de filiais de remessa, gere um novo conjunto transpotador, para realizar o vínvulo."###"Atenção!"
		LMARCAITEM := .F.
	ENDIF
ENDIF

// FRANK - 06/10/20 VERIFICAR SE JÁ EXISTE O ROMANEIO COM NOTA AGREGADA, SE FOR O CASO NÃO PERMITIR O VÍNCULO
IF LMARCAITEM
	FQ3->(DBSETORDER(1))
	FQ3->(DBSEEK(XFILIAL("FQ3")+FQ2->FQ2_NUM))
	WHILE !FQ3->(EOF()) .AND. FQ3->FQ3_FILIAL == XFILIAL("FQ3") .AND. FQ3->FQ3_NUM == FQ2->FQ2_NUM
		IF !EMPTY(FQ3->FQ3_NFREM)
			MSGALERT(STR0241+ALLTRIM(FQ3->FQ3_NFREM),STR0022) //"Já existe uma nota emitida para este romaneio: "###"Atenção!"
			LMARCAITEM := .F.
		ENDIF
		FQ3->(DBSKIP())
	ENDDO
ENDIF


_AARRAY[NAT][1] := !_AARRAY[NAT][1]

IF !LMARCAITEM
	_AARRAY[NAT][1] := .F.
ENDIF

RESTAREA(_AAREA)
RETURN _AARRAY


// TRATAMENTO PARA O RETORNO PARCIAL 
// FRANK Z FUGA - 14/10/2020
STATIC FUNCTION RETPARX(NAT)
LOCAL ORETPAR
LOCAL LOK
LOCAL _NRET := _AARRAY[NAT][11]
LOCAL OQTD
LOCAL _NX
LOCAL _LPASSA := .F.
LOCAL AHEADER := {}
LOCAL ACOLS   := {}
LOCAL CALIAS
LOCAL CCHAVE
LOCAL CCONDICAO
LOCAL NINDICE
LOCAL CFILTRO
LOCAL _CTEMP  := "" // MONTAGEM DO FILTRO
LOCAL ODLGGET
LOCAL NSTYLE   := GD_UPDATE
LOCAL MAXGETDAD := 99999	
LOCAL CCAMPOSSIM := "FPA_GRUA;FPA_DESGRU;FPA_PRODUT;FPA_DESPRO;FPA_QUANT"
LOCAL _NY
LOCAL _NREG
LOCAL _NQTD

FOR _NX := 1 TO LEN(_AARRAY)
	IF _AARRAY[_NX][01]
		_LPASSA := .T.
		IF !EMPTY(_CTEMP)
			_CTEMP += ";"
		ENDIF
		//_CTEMP += "'"+ALLTRIM(STR(_AARRAY[_NX][12]))+"'" // CONTEÚDO DO RECNO DA ZAG
		_CTEMP += ALLTRIM(STR(_AARRAY[_NX][12])) // CONTEÚDO DO RECNO DA ZAG
	ENDIF
NEXT
IF !_LPASSA
	MSGALERT(STR0242,STR0243) //"Nenhum item do romaneio foi selecionado."###"Falha na seleção."
	RETURN .F.
ENDIF

// MONTAGEM DO CABECALHO E ITENS DA GETDADOS COM BASE NA ZAG
CALIAS    := "FPA"
CCHAVE    := XFILIAL(CALIAS)+FQ5->FQ5_SOT
CCONDICAO := 'FPA_FILIAL+FPA_PROJET=="'+CCHAVE+'"'
NINDICE   := 1 									
CFILTRO   := CCONDICAO+" .AND. ALLTRIM(STR(FPA->(RECNO()))) $ " + "'"+_CTEMP+"'"
AHEADER   := FHEADER("FPA", CCAMPOSSIM)
ACOLS     := FCOLS(AHEADER,CALIAS,NINDICE,CCHAVE,CCONDICAO,CFILTRO)

DEFINE MSDIALOG ORETPAR TITLE STR0244   FROM 30,20 TO 500,882 PIXEL		// DE 610 PARA 400 //"Retorno parcial."
ODLGGET := MSNEWGETDADOS():NEW(34,02,232,432 ,NSTYLE,,,"",,,MAXGETDAD,,,.T.,ORETPAR,AHEADER,ACOLS)
ACTIVATE MSDIALOG ORETPAR CENTERED ON INIT ENCHOICEBAR(ORETPAR, {||LOK:=.T., IF(MSGYESNO(STR0245,STR0022),ORETPAR:END(),.F.)},{||ORETPAR:END()},,) //"Confirma o retorno parcial dos itens informados?"###"Atenção!"
IF LOK
	FOR _NX:=1 TO LEN(ODLGGET:ACOLS)
		IF !ODLGGET:ACOLS[_NX][LEN(AHEADER)+1]
			_NREG := ODLGGET:ACOLS[_NX][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_XXX4"})] // RECNO DA ZAG
			_NQTD := ODLGGET:ACOLS[_NX][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_XXX3"})] // QUANTIDADE INFORMADA
			FOR _NY := 1 TO LEN(_AARRAY)
				IF _AARRAY[_NY][12] == _NREG
					_AARRAY[_NY][11] := _NQTD
				ENDIF
			NEXT
		ENDIF
	NEXT
ELSE
	// VOLTAR COM AS QUANTIDADES ORIGINAIS DA NOTA DE REMESSA X ROMANEIO
	_AARRAY := _ABACK
ENDIF
OLISTBOX:REFRESH()
RETURN .T.


// ======================================================================= \\
STATIC FUNCTION FHEADER( CALIAS , CCAMPOSSIM , CCAMPOSNAO) 
// ======================================================================= \\

LOCAL   ATABAUX
LOCAL   AHEADER    := {}

DEFAULT CCAMPOSSIM := ""
DEFAULT CCAMPOSNAO := ""

CCAMPOSSIM := UPPER( ALLTRIM(CCAMPOSSIM) )
CCAMPOSNAO := UPPER( ALLTRIM(CCAMPOSNAO) )

(LOCXCONV(1))->( DBSETORDER(1) )
(LOCXCONV(1))->( DBSEEK( CALIAS, .T. ) )
WHILE ! (LOCXCONV(1))->( EOF() ) .AND. GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") == CALIAS  

	IF ! X3USO( &(LOCXCONV(3)) )					// NÃO ESTÁ EM USO
		(LOCXCONV(1))->(DBSKIP())
		LOOP
	ENDIF

	IF UPPER( ALLTRIM( GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO") ) ) $ CCAMPOSNAO	// ESTÁ EM CAMPOSNÃO   
		(LOCXCONV(1))->(DBSKIP())
		LOOP
	ENDIF

	IF ! EMPTY( CCAMPOSSIM ) .AND. ! UPPER( ALLTRIM( GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO") ) ) $ CCAMPOSSIM		// NÃO É EM CAMPOSSIM
		(LOCXCONV(1))->(DBSKIP())
		LOOP
	ENDIF

	ATABAUX := {}
	IF ALLTRIM(GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")) == "FPA_QUANT"
		AADD(ATABAUX , STR0227) //"Quantidade"
	ELSE
		AADD(ATABAUX , TRIM(X3TITULO()))
	ENDIF
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")   )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE") )  
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO") )  
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL") )  
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_VALID") )       
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_USADO") )       
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO") )        
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_F3") )          
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") )     
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX") )        
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_RELACAO") )     
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_WHEN") )  	       
	AADD(ATABAUX , "V"  ) // SX3->X3_VISUAL
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTVAR") )     
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_OBRIGAT") )         

	AADD(AHEADER , ATABAUX             )

	(LOCXCONV(1))->(DBSKIP())
ENDDO 

// INSERINDO A COLUNA SOBRE A QUANTIDADE ENVIADA VIA NOTA DE SAIDA
(LOCXCONV(1))->(DBSETORDER(2))
(LOCXCONV(1))->(DBSEEK("FPA_QUANT"))
ATABAUX := {}
AADD(ATABAUX , STR0246) //"Enviado"
AADD(ATABAUX , "FPA_XXX1"   ) // SOMENTE ESTRUTURA DA GETDADOS, ESTE CAMPO NAO EXISTE
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE") )     
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO") )     
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL") )     
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_VALID") )       
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_USADO") )       
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO") )        
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_F3") )          
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") )     
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX") )        
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_RELACAO") )     
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_WHEN") )        
AADD(ATABAUX , "V"  )
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTVAR") )         
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_OBRIGAT") )         
AADD(AHEADER , ATABAUX             )

// INSERINDO A COLUNA SOBRE A QUANTIDADE JA DIGITADA EM OUTROS ROMANEIOS
(LOCXCONV(1))->(DBSETORDER(2))
(LOCXCONV(1))->(DBSEEK("FPA_QUANT"))
ATABAUX := {}
AADD(ATABAUX , STR0247) //"Qtd.Romaneio"
AADD(ATABAUX , "FPA_XXX2"   ) // SOMENTE ESTRUTURA DA GETDADOS, ESTE CAMPO NAO EXISTE
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE") )     
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO") )     
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL") )     
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_VALID") )       
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_USADO") )       
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO") )        
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_F3") )          
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") )     
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX") )     
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_RELACAO") )     
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_WHEN") )     
AADD(ATABAUX , "V"  )
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTVAR") )     
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_OBRIGAT") )     
AADD(AHEADER , ATABAUX             )

// QUANTIDADE INFORMADA
(LOCXCONV(1))->(DBSETORDER(2))
(LOCXCONV(1))->(DBSEEK("FPA_QUANT"))
ATABAUX := {}
AADD(ATABAUX , STR0248) //"A Receber"
AADD(ATABAUX , "FPA_XXX3"   ) // SOMENTE ESTRUTURA DA GETDADOS, ESTE CAMPO NAO EXISTE
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE") )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO") )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL") )  
AADD(ATABAUX , "LOCA05926()"   )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_USADO")   )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO")    )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_F3")      )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX")    )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_RELACAO") )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_WHEN")    )  
AADD(ATABAUX , "R"  )
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTVAR")     )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_OBRIGAT")     )  
AADD(AHEADER , ATABAUX             ) 

// ARMAZENAR O RECNO PARA VINCULO COM A LISTBOX
(LOCXCONV(1))->(DBSETORDER(2))
(LOCXCONV(1))->(DBSEEK("FPA_QUANT"))
ATABAUX := {}
AADD(ATABAUX , STR0249      ) //"Controle"
AADD(ATABAUX , "FPA_XXX4"      ) // SOMENTE ESTRUTURA DA GETDADOS, ESTE CAMPO NAO EXISTE
AADD(ATABAUX , "9999999999999" )
AADD(ATABAUX , 12              ) 
AADD(ATABAUX , 0               )
AADD(ATABAUX , ""              )
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_USADO")   )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO")    )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_F3")      )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX")    )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_RELACAO") )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_WHEN")    )  
AADD(ATABAUX , "V"  )
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTVAR")     )  
AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_OBRIGAT")     )  
AADD(AHEADER , ATABAUX             )

RETURN ACLONE(AHEADER) 


// ======================================================================= \\
STATIC FUNCTION FCOLS(AHEADER, CALIAS, NINDICE, CCHAVE, CCONDICAO, CFILTRO) 
// ======================================================================= \\

LOCAL NPOS
LOCAL ACOLS0
LOCAL ACOLS     := {}
LOCAL CALIASANT := ALIAS()
LOCAL _NENV     := 0 // QUANTIDADE ENVIADA 
LOCAL _NRET     := 0 // QUANTIDADE RETORNADA
LOCAL _CITEM

DBSELECTAREA(CALIAS)

(CALIAS)->(DBSETORDER(NINDICE))
(CALIAS)->(DBSEEK(CCHAVE,.T.))
WHILE (CALIAS)->(!EOF() .AND. &CCONDICAO)
	IF !(CALIAS)->(&CFILTRO)
		(CALIAS)->(DBSKIP())
        LOOP
	ENDIF
	ACOLS0 := {} 
	FOR NPOS:=1 TO LEN(AHEADER)
		IF AHEADER[NPOS,2] <> "FPA_XXX1" .AND. AHEADER[NPOS,2] <> "FPA_XXX2" .AND. AHEADER[NPOS,2] <> "FPA_XXX3" .AND. AHEADER[NPOS,2] <> "FPA_XXX4"
			IF !AHEADER[NPOS,10]=="V"  				// X3_CONTEXT
				(CALIAS)->(AADD(ACOLS0,FIELDGET(FIELDPOS(AHEADER[NPOS,2]))))
			ELSE
				(CALIAS)->(AADD(ACOLS0,CRIAVAR(AHEADER[NPOS,2])))
			ENDIF
		ELSEIF AHEADER[NPOS,2] == "FPA_XXX1" // BUSCAR DAS NOTAS DE SAIDA
			(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
		ELSEIF AHEADER[NPOS,2] == "FPA_XXX2" // BUSCAR DO QUE FOI INSERIDO NA ZA1
			(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
		ELSEIF AHEADER[NPOS,2] == "FPA_XXX3" // DIGITAR
			(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
		ELSEIF AHEADER[NPOS,2] == "FPA_XXX4" // DIGITAR
			(CALIAS)->(AADD(ACOLS0,FPA->(RECNO())))
		ENDIF
	NEXT
	AADD(ACOLS0,.F.  )  						// DELETED
	AADD(ACOLS,ACOLS0)

	IF !EMPTY(FPA->FPA_NFREM)
		SC6->(DBSETORDER(4))
		SC6->(DBSEEK(substr(FPA->FPA_FILREM,1,tamsx3("FPA_FILREM")[1])+FPA->FPA_NFREM+FPA->FPA_SERREM))
		WHILE !SC6->(EOF()) .AND. SC6->(C6_FILIAL+C6_NOTA+C6_SERIE) == substr(FPA->FPA_FILREM,1,tamsx3("FPA_FILREM")[1])+FPA->FPA_NFREM+FPA->FPA_SERREM
			IF ALLTRIM(SC6->C6_ITEM) == ALLTRIM(FPA->FPA_ITEREM)
				_NENV := SC6->C6_QTDVEN
				EXIT
			ENDIF
			SC6->(DBSKIP())
		ENDDO
		ACOLS[LEN(ACOLS)][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_XXX1"})] := _NENV
	ENDIF

	// ENCONTRAR O QUE JÁ FOI RETORNADO
	/*
	_CQUERY := " SELECT FQ3_QTD "
	_CQUERY += " FROM " + RETSQLNAME("FQ3") + " SZ1" 
	_CQUERY += " WHERE  FQ3_FILIAL = '" + XFILIAL("FQ3") + "'" 
	_CQUERY += "   AND  FQ3_VIAGEM = '" + FQ5->FQ5_VIAGEM + "'" 
	_CQUERY += "   AND  SZ1.D_E_L_E_T_ = ''"
	IF SELECT("TRBSZ1") > 0
		TRBFQ3->(DBCLOSEAREA())
	ENDIF
	TCQUERY _CQUERY NEW ALIAS "TRBSZ1" 
	_NRET := TRBFQ3->FQ3_QTD
	TRBFQ3->(DBCLOSEAREA())
	*/

	/*_CQUERY := " SELECT FQ3_QTD "
	_CQUERY += " FROM " + RETSQLNAME("FQ3") + " SZ1" 
	_CQUERY += " INNER JOIN "+ RETSQLNAME("FPA") + " ZAG " 
	_CQUERY += "       ON ZAG.FPA_FILIAL = '"+XFILIAL("FPA")+"' AND "
	_CQUERY += "       ZAG.FPA_PROJET = '"+FPA->FPA_PROJET+"' AND "
	_CQUERY += "       ZAG.FPA_OBRA = '"+FPA->FPA_OBRA+"' AND "
	_CQUERY += "       ZAG.FPA_AS = '"+FPA->FPA_AS+"' AND "
	_CQUERY += "       ZAG.D_E_L_E_T_ = '' "
	_CQUERY += " INNER JOIN "+ RETSQLNAME("FQ7") + " ZUC " 
	_CQUERY += "       ON ZUC.FQ7_FILIAL = '"+XFILIAL("FQ7")+"' AND "
	_CQUERY += "       ZUC.FQ7_VIAORI = ZAG.FPA_VIAGEM AND "
	_CQUERY += "       ZUC.FQ7_PROJET = ZAG.FPA_PROJET AND "
	_CQUERY += "       ZUC.FQ7_OBRA = ZAG.FPA_OBRA AND "
	_CQUERY += "       ZUC.FQ7_TPROMA = '1' AND "
	_CQUERY += "       ZUC.D_E_L_E_T_ = '' "
	_CQUERY += " INNER JOIN "+ RETSQLNAME("FQ5") + " DTQ " 
	_CQUERY += "       ON DTQ.FQ5_FILIAL = '"+XFILIAL("FQ5")+"' AND "
	_CQUERY += "       DTQ.FQ5_SOT = ZAG.FPA_PROJET AND "
	_CQUERY += "       DTQ.FQ5_OBRA = ZAG.FPA_OBRA AND "
	_CQUERY += "       DTQ.FQ5_VIAGEM = ZUC.FQ7_VIAGEM AND "
	_CQUERY += "       DTQ.D_E_L_E_T_ = '' "
	_CQUERY += " WHERE "
	_CQUERY += "       SZ1.FQ3_FILIAL = '"+XFILIAL("FQ3")+"' AND "
	_CQUERY += "       SZ1.FQ3_ASF = DTQ.FQ5_AS AND "
	_CQUERY += "       SZ1.FQ3_PROJET = DTQ.FQ5_SOT AND "
	_CQUERY += "       SZ1.FQ3_VIAGEM = ZAG.FPA_VIAGEM AND "
	_CQUERY += "       SZ1.D_E_L_E_T_ = '' "*/

	_NRET := 0
	/*
	_CQUERY := " SELECT FQ3_QTD, FQ3_ITEM, FQ3_NUM "
	_CQUERY += " FROM " + RETSQLNAME("FQ3") + " SZ1" 
	_CQUERY += " WHERE "
	_CQUERY += "       SZ1.FQ3_FILIAL = '"+XFILIAL("FQ3")+"' AND "
	_CQUERY += "       SZ1.FQ3_AS = '"+FPA->FPA_AS+"' AND "
	//_CQUERY += "       SZ1.FQ3_VIAGEM = '"+FPA->FPA_VIAGEM+"' AND "
	//_CQUERY += "       SZ1.FQ3_NUM = '"+SF1->F1_IT_ROMA+"' AND "
	_CQUERY += "       SZ1.D_E_L_E_T_ = '' "
	_CQUERY += " ORDER BY FQ3_ITEM "

	IF SELECT("TRBSZ1") > 0
		TRBFQ3->(DBCLOSEAREA())
	ENDIF
	TCQUERY _CQUERY NEW ALIAS "TRBSZ1" 

	_NREGSZ0 := FQ2->(RECNO())
	WHILE !TRBFQ3->(EOF())
		FQ2->(DBSETORDER(1))
		FQ2->(DBSEEK(XFILIAL("FQ2")+TRBFQ3->FQ3_NUM))
		IF FQ2->FQ2_TPROMA == "1"
			_NRET += TRBFQ3->FQ3_QTD
		ENDIF
		TRBFQ3->(DBSKIP())
	ENDDO
	FQ2->(DBGOTO(_NREGSZ0))

	TRBFQ3->(DBCLOSEAREA())
	*/

	FQZ->(DBSETORDER(2))
	FQZ->(DBSEEK(XFILIAL("FQZ")+FPA->FPA_PROJET))
	WHILE !FQZ->(EOF()) .AND. FQZ->FQZ_FILIAL == XFILIAL("FQZ") .AND. FQZ->FQZ_PROJET == FPA->FPA_PROJET
		IF FQZ->FQZ_OBRA == FPA->FPA_OBRA
			IF FQZ->FQZ_MSBLQL == "2"
				IF ALLTRIM(FQZ->FQZ_AS) == ALLTRIM(FPA->FPA_AS)
					_NRET += FQZ->FQZ_QTD
				ENDIF
			ENDIF
		ENDIF
		FQZ->(DBSKIP())
	ENDDO


	ACOLS[LEN(ACOLS)][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_XXX2"})] := _NRET

	// QUANTIDADE A SER RETORNADO NO ROMANEIO
	ACOLS[LEN(ACOLS)][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_XXX3"})] := _NENV - _NRET

	// INFORME DO REGISTRO DA ZAG
	ACOLS[LEN(ACOLS)][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_XXX4"})] := FPA->(RECNO())
	
	(CALIAS)->(DBSKIP())
ENDDO 

IF EMPTY(ACOLS)
	ACOLS0 := {}
	FOR NPOS := 1 TO LEN(AHEADER)
		IF AHEADER[NPOS,2] <> "FPA_XXX1" .AND. AHEADER[NPOS,2] <> "FPA_XXX2" .AND. AHEADER[NPOS,2] <> "FPA_XXX3" .AND. AHEADER[NPOS,2] <> "FPA_XXX4"
			(CALIAS)->(AADD(ACOLS0,CRIAVAR(AHEADER[NPOS,2])))
		ELSEIF AHEADER[NPOS,2] == "FPA_XXX1" // BUSCAR DAS NOTAS DE SAIDA
			(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
		ELSEIF AHEADER[NPOS,2] == "FPA_XXX2" // BUSCAR DA ZA1
			(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
		ELSEIF AHEADER[NPOS,2] == "FPA_XXX3" // DIGITAR
			(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
		ELSEIF AHEADER[NPOS,2] == "FPA_XXX4" // RECNO
			(CALIAS)->(AADD(ACOLS0,FPA->(RECNO())))
		ENDIF
	NEXT
	AADD(ACOLS0 , .F.)  						// DELETED
	AADD(ACOLS,ACOLS0)
ENDIF

ACOLS0 := {}
FOR NPOS := 1 TO LEN(AHEADER)
	IF AHEADER[NPOS,2] <> "FPA_XXX1" .AND. AHEADER[NPOS,2] <> "FPA_XXX2" .AND. AHEADER[NPOS,2] <> "FPA_XXX3"  .AND. AHEADER[NPOS,2] <> "FPA_XXX4"
		(CALIAS)->(AADD(ACOLS0,CRIAVAR(AHEADER[NPOS,2])))
	ELSEIF AHEADER[NPOS,2] == "FPA_XXX1" // BUSCAR DAS NOTAS DE SAIDA
		(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
	ELSEIF AHEADER[NPOS,2] == "FPA_XXX2" // BUSCAR DA ZA1
		(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
	ELSEIF AHEADER[NPOS,2] == "FPA_XXX3" // DIGITAR
		(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
	ELSEIF AHEADER[NPOS,2] == "FPA_XXX4" // RECNO
		(CALIAS)->(AADD(ACOLS0,FPA->(RECNO())))
	ENDIF
NEXT
AADD( ACOLS0, .F. )  							// DELETED

DBSELECTAREA(CALIASANT)

RETURN ACLONE(ACOLS)


// ROTINA PARA VALIDACAO DA QUANTIDADE DO ROMANEIO
// FRANK 15/10/2020
//FUNCTION VLDZAG3
FUNCTION LOCA05926
LOCAL _LRET := .T.
LOCAL _CERRO := ""
IF &(READVAR()) > ACOLS[N][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_XXX1"})]
	_CERRO := STR0250 //"Quatidade informada no romaneio maior do que a quantidade enviada para o cliente."
	_LRET := .F.
ENDIF
IF &(READVAR()) > ACOLS[N][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"})] .AND. _LRET
	_CERRO := STR0251 //"Quantidade informada é maior do que a disponível no contrato."
	_LRET := .F.
ENDIF
IF &(READVAR()) == 0 .AND. _LRET
	_CERRO := STR0252 //"Quantidade inválida."
	_LRET := .F.
ENDIF
IF !_LRET
	MSGALERT(_CERRO,STR0022) //"Atenção!"
ENDIF
RETURN _LRET


// Frank Zwarg Fuga em 25/02/2021
// Filtro adicional na consulta padrão ST9002
/*
Function LOCA05927
Local _nX		:= 0
Local _cRetorno := ".T."
Local cFamilia	:= ""
Local cModelo	:= ""
Local cEquipAtu	:= ""
Local cAliasT9	:= ""
Local cQuery	:= ""
Local aAreaAtu	:= GetArea()

For _nX:=1 to 20
	If upper(alltrim(ProcName(_nX))) == "LOCA05919"

		//Equipamento Atual
		cEquipAtu := AllTrim(ACOLS[N,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPAT"})])
		//Pega familia e modelo
		cAliasT9 := GetNextAlias()
		cQuery	:= " SELECT T9_CODESTO, T9_CODFAMI, T9_MODELO, T9_TIPMOD FROM ST9010 "
		cQuery	+= " WHERE T9_CODBEM = '" + cEquipAtu + "' "
		cQuery	+= " AND T9_FILIAL = '" + xFilial("ST9") + "' "
		cQuery	+= " AND D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasT9, .T., .F. )

		If (cAliasT9)->(!EOF())
			//Familia
			cFamilia := (cAliasT9)->T9_CODFAMI
			//Modelo
			//cModelo := (cAliasT9)->T9_MODELO
			cModelo := (cAliasT9)->T9_TIPMOD // Jose Eulalio - 19/05/2022 - SIGALOC94-317 - Substituir o campo T9_MODELO pelo campo T9_TIPMOD na consulta específica de troca de equipamento.
		EndIf

		(cAliasT9)->(dbCloseArea())

		//retorna área atual para não gerar erro quando não tem resultados
		RestArea(aAreaAtu)
		
		//Produto
		FPA->(dbSetOrder(6))
		If FPA->(dbSeek(xFilial("FPA")+FQ5->FQ5_SOT+FQ5->FQ5_AS))
			_cRetorno := "("
			_cRetorno += "ST9->T9_CODESTO == '"+FPA->FPA_PRODUT+"'"
		EndIf

		//Familia
		If !(Empty(cFamilia))
			If _cRetorno == ".T."
				_cRetorno := "("
			Else
				_cRetorno += " .OR. "
			EndIf
			_cRetorno += " ST9->T9_CODFAMI == '" + cFamilia + "'"
		EndIf

		//Modelo
		If !(Empty(cModelo))
			If _cRetorno == ".T."
				_cRetorno := "("
			Else
				_cRetorno += " .OR. "
			EndIf
			//_cRetorno += " ST9->T9_MODELO == '" + cModelo + "'"
			_cRetorno += " ST9->T9_TIPMOD == '" + cModelo + "'" // Jose Eulalio - 19/05/2022 - SIGALOC94-317 - Substituir o campo T9_MODELO pelo campo T9_TIPMOD na consulta específica de troca de equipamento.
		EndIf

		If _cRetorno <> ".T."
			_cRetorno += ")"
		EndIf
		Exit
	EndIF
Next

Return &(_cRetorno)
*/

//------------------------------------------------------------------------------
/*/	{Protheus.doc} LOCA05928

@description	Gera Solicitação de Compras	
@return			Boolean
@author			Jose Eulalio    
@since			14/04/2022
@version		12
/*/
//------------------------------------------------------------------------------
Function LOCA05928()
Local cTitDlg	:= STR0254 + ' - ' + STR0044 + ' - ' + FQ5->FQ5_SOT //Seleção de Itens // Projeto
Local aTamObra	:= TamSx3("FQ5_OBRA")
Local aTamSeqG	:= TamSx3("FPA_SEQGRU")
Local aTamAS	:= TamSx3("FQ5_AS")
Local aTamProd	:= TamSx3("FQ5_XPROD")
Local aTamQtde	:= TamSx3("FPA_QUANT")
Local aTamClie	:= TamSx3("FQ5_NOMCLI")
Local aCampos	:= {{"","","","","",""}}
Local aPesquisa	:= {}
Local nI		:= 0
//Local oColumn

Private lMarker := .T.
Private aBusca	:= {}

//atualiza cCadastro
ccadastro := STR0044  + " " + FQ5->FQ5_SOT //Projeto #### 
 
//Alimenta o array
If CargaFQ5(FQ5->FQ5_SOT)
 
	DEFINE MsDIALOG o3Dlg TITLE cTitDlg From 0, 4 To 650, 1180 Pixel
		
		oPnMaster := tPanel():New(0,0,,o3Dlg,,,,,,0,0)
		oPnMaster:Align := CONTROL_ALIGN_ALLCLIENT
	
		oBuscaBrw := fwBrowse():New()
		oBuscaBrw:setOwner( oPnMaster )
	
		oBuscaBrw:setDataArray()
		oBuscaBrw:setArray( aBusca )
		oBuscaBrw:disableConfig()
		oBuscaBrw:disableReport()
	
		oBuscaBrw:SetLocate() // Habilita a Localização de registros
	
		//Create Mark Column
		oBuscaBrw:AddMarkColumns({|| IIf(aBusca[oBuscaBrw:nAt,01], "LBOK", "LBNO")},; //Code-Block image
			{|| SelectOne(oBuscaBrw, aBusca)},; //Code-Block Double Click
			{|| SelectAll(oBuscaBrw, 01, aBusca) }) //Code-Block Header Click

		//-------------------------------------------------------------------
		// Campos
		//-------------------------------------------------------------------
		// Estrutura do aFields
		//				[n][1] Campo
		//				[n][2] Título
		//				[n][3] Tipo
		//				[n][4] Tamanho
		//				[n][5] Decimal
		//				[n][6] Picture
		//-------------------------------------------------------------------

		Aadd(aCampos, {"CAMPO02", STR0127	,aTamObra[3] ,aTamObra[1] ,aTamObra[2]	, X3Picture( "FPA_OBRA" )}	) //"Obra"
		Aadd(aCampos, {"CAMPO03", STR0226	,aTamSeqG[3] ,aTamSeqG[1] ,aTamSeqG[2]	, X3Picture( "FPA_SEQGRU" )}) //"Sequencia"
		Aadd(aCampos, {"CAMPO04", STR0121	,aTamAS[3]   ,aTamAS[1]   ,aTamAS[2]	, X3Picture( "FPA_AS" )}	) //"Nº AS"
		Aadd(aCampos, {"CAMPO05", STR0126	,aTamProd[3] ,aTamProd[1] ,aTamProd[2]	, X3Picture( "FPA_PRODUT" )}) //"Produto"
		Aadd(aCampos, {"CAMPO06", STR0255	,aTamClie[3] ,aTamClie[1] ,aTamClie[2]	, X3Picture( "FQ5_NOMCLI" )}) //"Cliente"
		Aadd(aCampos, {"CAMPO07", STR0227	,aTamQtde[3] ,aTamQtde[1] ,aTamQtde[2]	, X3Picture( "FPA_QUANT" )}	) //"Quantidade"

		// Adiciona as colunas do Browse
		/*For nI := 2 To Len( aCampos )
			ADD COLUMN oColumn DATA { || aBusca[oBuscaBrw:nAt,nI] + ' }' ) Title aCampos[nI][2]  PICTURE aCampos[nI][6] Of oBuscaBrw
		Next nI*/

		For nI := 2 To Len( aCampos )
			Aadd( aPesquisa, { aCampos[nI][2], {{"",aCampos[nI][3],aCampos[nI][4],aCampos[nI][5],aCampos[nI][2],,}} } ) //"Código"
		Next nI

		oBuscaBrw:DisableReport()
		oBuscaBrw:DisableConfig(.T.)
		oBuscaBrw:SetSeek( , aPesquisa )
		
		oBuscaBrw:addColumn({ STR0127	, {||aBusca[oBuscaBrw:nAt,02]}, "C", "@!"    , 1,  	aTamObra[1]	, , .F. , , .F.,, "aBusca[oBuscaBrw:nAt,02]",, .F., .T.,  , "CAMPO02"    }) //"Obra"
		oBuscaBrw:addColumn({ STR0226	, {||aBusca[oBuscaBrw:nAt,03]}, "C", "@!"    , 1,  	aTamSeqG[1] , , .F. , , .F.,, "aBusca[oBuscaBrw:nAt,03]",, .F., .T.,  , "CAMPO03"    }) //"Sequencia"
		oBuscaBrw:addColumn({ STR0121   , {||aBusca[oBuscaBrw:nAt,04]}, "C", "@!"    , 1,  	aTamAS[1]	, , .F. , , .F.,, "aBusca[oBuscaBrw:nAt,04]",, .F., .T.,  , "CAMPO04"    }) //"Nº AS"
		oBuscaBrw:addColumn({ STR0126   , {||aBusca[oBuscaBrw:nAt,05]}, "C", "@!"    , 1, 	aTamProd[1] , , .F. , , .F.,, "aBusca[oBuscaBrw:nAt,05]",, .F., .T.,  , "CAMPO05"    }) //"Produto"
		oBuscaBrw:addColumn({ STR0255   , {||aBusca[oBuscaBrw:nAt,06]}, "C", "@!"    , 1, 	aTamClie[1]	, , .F. , , .F.,, "aBusca[oBuscaBrw:nAt,06]",, .F., .T.,  , "CAMPO06"    }) //"Cliente"
		oBuscaBrw:addColumn({ STR0227   , {||aBusca[oBuscaBrw:nAt,07]}, "N", ""      , 1,  	aTamQtde[1] , , .F. , , .F.,, "aBusca[oBuscaBrw:nAt,07]",, .F., .T.,  , "CAMPO07"    }) //"Quantidade"
		

		// Adiciona as colunas do Filtro
		/*oBuscaBrw:SetFieldFilter(aCampos)
		oBuscaBrw:SetUseFilter()*/
	
		oBuscaBrw:setEditCell( .T. , { || .T. } ) //activa edit and code block for validation
	
		oBuscaBrw:Activate(.T.)
	
	Activate MsDialog o3Dlg CENTERED On Init EnchoiceBar(o3Dlg, {||GeraSc(),o3Dlg:end()},{||o3Dlg:end()})
EndIf

return .t.

Static Function SelectOne(oBrowse, aArquivo)
aArquivo[oBuscaBrw:nAt,1] := !aArquivo[oBuscaBrw:nAt,1]
oBrowse:Refresh()
Return .T.

Static Function SelectAll(oBrowse, nCol, aArquivo)
Local _ni := 1
For _ni := 1 to len(aArquivo)
    aArquivo[_ni,1] := lMarker
Next
oBrowse:Refresh()
lMarker:=!lMarker
Return .T.


//------------------------------------------------------------------------------
/*/	{Protheus.doc} CargaFQ5

@description	Realiza carga dos itens que podem gerar SC
@return			Nil
@author			Jose Eulalio    
@since			14/04/2022
@version		12
/*/
//------------------------------------------------------------------------------
Static Function CargaFQ5(cAsFq5)
Local cQuery 	:= ""
Local cCliSC 	:= ""
Local cQryT3	:= GetNextAlias()
Local lRet		:= .T.
Local lLOCA59G  := EXISTBLOCK("LOCA59G")
Local lLOCA59H  := EXISTBLOCK("LOCA59H")
Local lLOCA59I  := EXISTBLOCK("LOCA59I")

//If FQ5->(FIELDPOS("FQ5_NSC")) == 0 .or. FPA->(FIELDPOS("FPA_NOMFAT"))  == 0
If FPA->(FIELDPOS("FPA_NOMFAT"))  == 0
	Return .F.
EndIf

cQuery += " SELECT DISTINCT " + CRLF
cQuery += " 	FPA_PROJET, FPA_OBRA, FPA_SEQGRU, FPA_AS, FPA_PRODUT, FPA_NOMFAT CLIFPA, " + CRLF
cQuery += " 	FP1_NOMDES CLIFP1,FP0_CLINOM CLIFP0, FPA_QUANT, FPA.R_E_C_N_O_ AS RECNOFPA,  " + CRLF
If FQ5->(FIELDPOS("FQ5_NSC")) > 0
	cQuery += " 	FQ5_NOMCLI, FQ5_NSC, FQ5.R_E_C_N_O_ AS RECNOFQ5 " + CRLF
Else
	cQuery += " 	FQ5_NOMCLI, FQ5.R_E_C_N_O_ AS RECNOFQ5 " + CRLF
EndIF
cQuery += " FROM " + RetSqlName("FPA") + " FPA " + CRLF
cQuery += " INNER JOIN " + RetSqlName("FP0") + " FP0 " + CRLF
cQuery += " 	ON FP0_PROJET = FPA_PROJET " + CRLF
cQuery += " INNER JOIN " + RetSqlName("FQ5") + " FQ5 " + CRLF
cQuery += " 	ON FQ5_FILIAL = '" + xFilial("FQ5") + "' AND " + CRLF
cQuery += " 	FQ5.D_E_L_E_T_ = ' ' AND " + CRLF
cQuery += " 	FPA_PROJET = FQ5_SOT AND" + CRLF
cQuery += " 	FQ5_TPAS = 'L' AND " + CRLF
cQuery += " 	FQ5_GUINDA = '' AND " + CRLF
cQuery += " 	FQ5_DATFEC = '' AND " + CRLF
cQuery += " 	FQ5_DATENC = '' AND " + CRLF
cQuery += " 	FQ5_STATUS = '1' AND " + CRLF
If FQ5->(FIELDPOS("FQ5_NSC")) > 0
	cQuery += " 	FQ5_NSC = '' AND " + CRLF
EndIf
//cQuery += " 	FQ5_ISC = '' AND " + CRLF
cQuery += " 	FPA_AS = FQ5_AS " + CRLF
cQuery += " INNER JOIN " + RetSqlName("FP1") + " FP1 " + CRLF
cQuery += " 	ON FP1_PROJET = FPA_PROJET " + CRLF
cQuery += " 	AND FP1_OBRA = FPA_OBRA " + CRLF
cQuery += " WHERE " + CRLF 
cQuery += " 	FP0_FILIAL = '" + xFilial("FP0") + "' AND " + CRLF
cQuery += " 	FP1_FILIAL = '" + xFilial("FP1") + "' AND " + CRLF
cQuery += " 	FPA_FILIAL = '" + xFilial("FPA") + "' AND " + CRLF
cQuery += " 	FP0.D_E_L_E_T_ = ' ' AND " + CRLF
cQuery += " 	FP1.D_E_L_E_T_ = ' ' AND " + CRLF
cQuery += " 	FPA.D_E_L_E_T_ = ' ' AND " + CRLF
cQuery += " 	FPA_PROJET = '" + cAsFq5 + "' " + CRLF

cQuery:=ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryT3, .T., .F. )

(cQryT3)->(DbGoTop())
lForca := .F.
If lLOCA59I	
	lForca := EXECBLOCK("LOCA59I",.T.,.T.,{})
EndIf
If (cQryT3)->(!EOF()) .and. !lForca
	While (cQryT3)->(!EOF())

		lForca := .F.
		If lLOCA59G	
			lForca := EXECBLOCK("LOCA59G",.T.,.T.,{})
		EndIf

		If FQ5->(FIELDPOS("FQ5_NSC")) > 0
			If Empty((cQryT3)->FQ5_NSC) .or. lForca
				//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
				If lLOCA59H
					EXECBLOCK("LOCA59H",.T.,.T.,{})
				EndIf
				If !Empty((cQryT3)->CLIFPA)
					cCliSC := alltrim((cQryT3)->CLIFPA)
				ElseIf !Empty((cQryT3)->CLIFP1)
					cCliSC := alltrim((cQryT3)->CLIFP1)
				ElseIf !Empty((cQryT3)->FQ5_NOMCLI)
					cCliSC := alltrim((cQryT3)->FQ5_NOMCLI)
				Else
					cCliSC := alltrim((cQryT3)->CLIFP0)
				EndIf
				aadd(aBusca,	{	.f.								, ;
									alltrim((cQryT3)->FPA_OBRA)		, ;
									alltrim((cQryT3)->FPA_SEQGRU)	, ;
									alltrim((cQryT3)->FPA_AS)		, ;
									alltrim((cQryT3)->FPA_PRODUT)	, ;
									cCliSC							, ;
									(cQryT3)->FPA_QUANT				, ;
									(cQryT3)->RECNOFPA				, ;
									(cQryT3)->RECNOFQ5				})
			EndIf
		EndIf
	
		(cQryT3)->(dbSkip())
	EndDo
Else
	lRet := .F.
	FwAlertInfo(STR0256, STR0022) // "Não existem itens que possam gerar Solicitação de Compras"   //"Atenção!"
EndIf
(cQryT3)->(dbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraSc

Gera solicitações de compras a partir de AS sem equipamentos indicados
@type  Static Function
@author Jose Eulalio
@since 14/04/2022
@see https://tdn.engpro.totvs.com.br/pages/releaseview.action?pageId=318605213

/*/
//------------------------------------------------------------------------------
Static Function GeraSc()
Local cDoc 		:= ""
Local cItem		:= ""
Local cListaSC	:=  STR0257 + ": " + CRLF //"Solicitações de Compras incluídas com sucesso: "
Local nX 		:= 0
Local nY 		:= 0
Local nTamItem	:= TamSx3("C1_ITEM")[1]
Local aCabSC 	:= {}
Local aItens 	:= {}
Local aItensSC 	:= {}
Local aLinhaC1 	:= {}
Local aAreaFQ5 	:= FQ5->(GetArea())
Local aAreaFPA 	:= FPA->(GetArea())
Local aHeaderAux:= {}
Local lLOCX051	:= SuperGetMV("MV_LOCX051",.F.,.F.)
Local lLOCA59J  := EXISTBLOCK("LOCA59J")
Local lLOCA59K  := EXISTBLOCK("LOCA59K")
Local lLOCA59L  := EXISTBLOCK("LOCA59L")

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

For nX := 1 To Len(oBuscaBrw:oData:aArray)
	If oBuscaBrw:oData:aArray[nX][1]
		Aadd(aItens, {oBuscaBrw:oData:aArray[nX][5],oBuscaBrw:oData:aArray[nX][7],oBuscaBrw:oData:aArray[nX][9]})
	EndIf
Next nX

Begin TRANSACTION

For nX := 1 To Len(aItens)

	//Limpa as variáveis para a rotina automática
	aCabSC 		:= {}
	aItensSC	:= {}
	aLinhaC1 	:= {}
	//cItem		:= StrZero(nx,nTamItem)
	cItem		:= StrZero(1,nTamItem)
	
	//| Verifica numero da SC |
	cDoc := GetSXENum("SC1","C1_NUM")
	SC1->(dbSetOrder(1))
	lForca := .F.
	If lLOCA59J
		lForca := EXECBLOCK("LOCA59J",.T.,.T.,{})
	EndIf
	While SC1->(dbSeek(xFilial("SC1") + cDoc)) .or. lForca
		ConfirmSX8()
		cDoc := GetSXENum("SC1","C1_NUM")
		If lforca
			exit
		EndIf
	EndDo

	//| Monta cabecalho |
	aadd(aCabSC,{"C1_NUM" 		, cDoc					})
	aadd(aCabSC,{"C1_SOLICIT"	, UsrRetName(__cUserID)	})
	aadd(aCabSC,{"C1_EMISSAO"	, dDataBase				})

	aadd(aLinhaC1,{"C1_ITEM" 	, cItem						,Nil})
	
	lForca := .F.
	If lLOCA59K
		lForca := EXECBLOCK("LOCA59K",.T.,.T.,{})
	EndIf

	If aItens[nX][3] > 0 .and. !lForca
		FQ5->(DbGoTo(aItens[nX][3]))
		aadd(aLinhaC1,{"C1_PRODUTO"	, FQ5->FQ5_XPROD 			,Nil})
		aadd(aLinhaC1,{"C1_QUANT" 	, FQ5->FQ5_XQTD  			,Nil})
		aadd(aLinhaC1,{"C1_DATPRF" 	, FQ5->FQ5_DATINI  			,Nil})
		aadd(aLinhaC1,{"C1_OBS" 	, FQ5->FQ5_OBSCOM  			,Nil})
		//posiciona no armazém da FPA
		FPA->(DBSETORDER(3))
		If FPA->(DBSEEK(XFILIAL("FPA") + FQ5->FQ5_AS))
			aadd(aLinhaC1,{"C1_LOCAL" 	, FPA->FPA_LOCAL  			,Nil})
		EndIf
		//envia Classe Valor
		If lLOCX051
			aadd(aLinhaC1,{"C1_CLVL" 	, FQ5->FQ5_AS      		,Nil})
		EndIf
	Else
		aadd(aLinhaC1,{"C1_PRODUTO"	, AllTrim(aItens[nX][1])	,Nil})
		aadd(aLinhaC1,{"C1_QUANT" 	, aItens[nX][2] 			,Nil})
	EndIf
	aadd(aItensSC,aLinhaC1)

	//Guardo o aHeader atual para não causar problema na rotina automática
	If Type("aHeader") == "A"
		aHeaderAux 	:= aClone(aHeader)
		aHeader		:= {}
	EndIf

	//| Teste de Inclusao - Execução Rotina Automática |
	MSExecAuto({|x,y| mata110(x,y)},aCabSC,aItensSC)

	//Restauro o aHeader
	If Type("aHeader") == "A"
		aHeader := aClone(aHeaderAux)
	EndIf

	lForca := .F.
	If lLOCA59L
		lForca := EXECBLOCK("LOCA59L",.T.,.T.,{})
	EndIf

	If !lMsErroAuto .and. !lForca
		cListaSC += cDoc + CRLF
	Else
		MostraErro()
		aErrPCAuto := GETAUTOGRLOG()
		For nY := 1 to Len(aErrPCAuto)
			//Conout(aErrPCAuto[nY])
		Next nY
		DisarmTransaction()
		Exit
	EndIf

	//Grava na FQ5
	If aItens[nX][3] > 0
		FQ5->(DbGoTo(aItens[nX][3]))
		RecLock("FQ5",.F.)
			If FQ5->(FIELDPOS("FQ5_NSC")) > 0
				FQ5->FQ5_NSC := cDoc
				FQ5->FQ5_ISC := cItem
			EndIf
		FQ5->(MsUnlock())
	EndIf

Next nX

If !lMsErroAuto	
	FwAlertSuccess(cListaSC,STR0258) //"Sucesso"
EndIf

End TRANSACTION

RestArea(aAreaFQ5)
RestArea(aAreaFPA)

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} ExcluiSc

Exclui solicitações de compras geradas no apontador
@type  Static Function
@author Jose Eulalio
@since 13/05/2022
@see https://tdn.engpro.totvs.com.br/pages/releaseview.action?pageId=318605213

/*/
//------------------------------------------------------------------------------
Function LOCA05930()
Local cDoc
Local lLOCA59M  := EXISTBLOCK("LOCA59M")
nForca := 0
If FQ5->(FIELDPOS("FQ5_NSC")) > 0
	cDoc	:= FQ5->FQ5_NSC
Else
	cDoc    := ""
EndIF
If lLOCA59M	
	nForca := EXECBLOCK("LOCA59M",.T.,.T.,{})
EndIf
If !(Empty(cDoc)) .or. nForca == 1
	ExcluiSc(cDoc)
ElseIf Empty(cDoc) .or. nForca == 2
	FWAlertWarning("Não existe Solicitação de Compras para esta Autorização de Serviço!",STR0022) //"Atenção!"
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ExcluiSc

Exclui solicitações de compras geradas no apontador
@type  Static Function
@author Jose Eulalio
@since 13/05/2022
@see https://tdn.engpro.totvs.com.br/pages/releaseview.action?pageId=318605213

/*/
//------------------------------------------------------------------------------
Static Function ExcluiSc(cDoc)
Local nY		:= 0
Local aCabSC	:= {}
Local aItensSC 	:= {}
Local aRateioCX := {}
Local aAreaSC1	:= SC1->(GetArea())
Local lContinua	:= .T.
Local lLOCA59N  := EXISTBLOCK("LOCA59N")
Local lLOCA59O  := EXISTBLOCK("LOCA59O")

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

//verifica se já gerou pedido de compras
SC1->(DbSetOrder(1)) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
lForca := .F.
If lLOCA59N	
	lForca := EXECBLOCK("LOCA59N",.T.,.T.,{})
EndIf
If SC1->(DbSeek(xFilial("SC1") + cDoc)) .or. lForca
	If !(Empty(SC1->C1_PEDIDO)) .or. lForca
		lContinua := .F.
		FWAlertWarning(STR0262 + AllTrim(cDoc) + STR0263,STR0022) // "A Solicitação de Compras " + cDoc + " não pode ser excluída, pois já gerou Pedido de Compras." ####  "Atenção!"
	EndIf
EndIf

If lContinua

	Begin TRANSACTION

	aadd(aCabSC,{"C1_NUM" 		,cDoc		})
	aadd(aCabSC,{"C1_SOLICIT"	,cUserName 	})
	aadd(aCabSC,{"C1_EMISSAO"	,dDataBase	})

	MSExecAuto({|w,x,y,z| MATA110(w,x,y,,,z)},aCabSC,aItensSC,5,aRateioCX)
	lForca := .F.
	If lLOCA59O	
		lForca := EXECBLOCK("LOCA59O",.T.,.T.,{})
	EndIf

	If !lMsErroAuto .and. !lForca
		RecLock("FQ5",.F.)
		If FQ5->(FIELDPOS("FQ5_NSC")) > 0
			FQ5->FQ5_NSC := ""
			FQ5->FQ5_ISC := ""
		EndIf
		FQ5->(MsUnlock())
		FwAlertSuccess(STR0262 + AllTrim(cDoc) + STR0264,STR0258) //"A Solicitação de Compras " + cDod + " foi excluída!" #### "Sucesso"
	Else
		MostraErro()
		aErrPCAuto := GETAUTOGRLOG()
		For nY := 1 to Len(aErrPCAuto)
			//Conout(aErrPCAuto[nY])
		Next nY
		DisarmTransaction()
	EndIf

	End TRANSACTION
EndIf

RestArea(aAreaSC1)

Return

Function LOCA05932
lExibe := .T.
Return ST9->T9_CODBEM

//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA05929

Consulta específica que substitui o Filtro adicional na consulta padrão ST9002 (Function LOCA05927), a consulta atual é ST9003
@type  Static Function
@author Jose Eulalio
@since 12/05/2022
@see https://centraldeatendimento.totvs.com/hc/pt-br/articles/360018949211-Cross-Segmento-TOTVS-Backoffice-Linha-Protheus-ADVPL-Consulta-espec%C3%ADfica

/*/
//------------------------------------------------------------------------------
Function LOCA05929()
Local aCpos  	:= {}
Local aRet   	:= {}
Local cQuery 	:= ""
Local cAlias 	:= GetNextAlias()
Local cAliasT9 	:= GetNextAlias()
Local cEquipAtu := AllTrim(ACOLS[N,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPAT"})])
Local cFamilia	:= ""
Local cModelo	:= ""
Local cTroqEq	:= ""
Local cPesq 	:= Space(50) 
//Local lRet   	:= .F.
Local oDlg
Local oLbx
Local lLOCA59P  := EXISTBLOCK("LOCA59P")
Local aArea     := GetArea()

Private lPadrao	:= AllTrim(AHEADER[ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"}),9]) == "ST9003"
Private aLstBxOri	:= {}

//query para recuperar Produto, Familia e Modelo do Equipamento atual
cQuery	:= " SELECT T9_CODESTO, T9_CODFAMI, T9_MODELO, T9_TIPMOD FROM " + RetSqlName("ST9") + " "
cQuery	+= " WHERE T9_CODBEM = '" + cEquipAtu + "' "
cQuery	+= " AND T9_FILIAL = '" + xFilial("ST9") + "' "
cQuery	+= " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasT9, .T., .F. )

If (cAliasT9)->(!EOF())
	//Familia
	cFamilia := (cAliasT9)->T9_CODFAMI
	//Modelo
	//cModelo := (cAliasT9)->T9_MODELO
	cModelo := (cAliasT9)->T9_TIPMOD
EndIf

(cAliasT9)->(dbCloseArea())

//retorna a opção do tipo de troca de equipamento da obra
FPA->(dbSetOrder(6)) //FPA_FILIAL+FPA_PROJET+FPA_AS
If FPA->(dbSeek(xFilial("FPA")+FQ5->FQ5_SOT+FQ5->FQ5_AS))
	FP1->(dbSetOrder(1)) //FP1_FILIAL+FP1_PROJET+FP1_OBRA
	If FP1->(dbSeek(xFilial("FPA")+ FPA->(FPA_PROJET + FPA_OBRA)))
		//olha campo novo
		If FP1->(fieldPos("FP1_TROCEQ")) > 0
			cTroqEq := FP1->FP1_TROCEQ
		EndIf
	EndIf
EndIf

//query para filtrar os bens disponíveis e dentro da regra de produto, familia e modelo
cQuery	:= " SELECT DISTINCT T9_CODBEM, T9_NOME,T9_CODESTO, T9_CODFAMI,T9_MODELO,T9_TIPMOD FROM " + RetSqlName("ST9")
cQuery	+= " WHERE T9_FILIAL = '" + xFilial("ST9") + "' "
cQuery	+= " AND D_E_L_E_T_ = ' '  "
cQuery	+= " AND T9_SITMAN = 'A' "
cQuery	+= " AND T9_SITBEM = 'A' "
cQuery	+= " AND T9_STATUS = '00' "
cQuery  += " AND T9_CODBEM <> '"+cEquipAtu+"' "

//filtro de Acordo a escolha
If cTroqEq == "2" // Produto OU Familia
	cQuery	+= " AND (T9_CODESTO = '" + FPA->FPA_PRODUT + "'  "
	If !Empty(cFamilia)
		cQuery	+= " OR T9_CODFAMI = '" + cFamilia + "'"
	EndIf
	cQuery	+= ")"
ElseIf cTroqEq == "3" // Produto E Modelo
	cQuery	+= " AND (T9_CODESTO = '" + FPA->FPA_PRODUT + "'  "
	cQuery	+= " AND T9_TIPMOD <> '' "
	cQuery	+= " AND T9_TIPMOD = '" + cModelo + "' )"
ElseIf cTroqEq == "4" // Produto OU Modelo OU Familia
	cQuery	+= " AND (T9_CODESTO = '" + FPA->FPA_PRODUT + "'  "
	If !Empty(cFamilia)
		cQuery	+= " OR T9_CODFAMI = '" + cFamilia + "' "
	EndIf
	If !Empty(cModelo)
		cQuery	+= " OR T9_TIPMOD = '" + cModelo + "' "
	EndIf
	cQuery	+= ")"
Else
	cQuery	+= " AND T9_CODESTO = '" + FPA->FPA_PRODUT + "'  "
EndIf

cQuery += " ORDER BY 1 "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

While (cAlias)->(!Eof())
	//aAdd(aCpos,{(cAlias)->(T9_CODBEM), (cAlias)->(T9_NOME), (cAlias)->(T9_CODESTO), (cAlias)->(T9_CODFAMI), (cAlias)->(T9_MODELO)})
	aAdd(aCpos,{(cAlias)->(T9_CODBEM), (cAlias)->(T9_NOME), (cAlias)->(T9_CODESTO), (cAlias)->(T9_CODFAMI), (cAlias)->(T9_TIPMOD)})
	(cAlias)->(dbSkip())
End

(cAlias)->(dbCloseArea())

lForca := .F.
If lLOCA59P	
	lForca := EXECBLOCK("LOCA59P",.T.,.T.,{})
EndIf

//caso seja consulta ST9003, sempre exibe ao selecionar a lupa
If lPadrao
	lExibe := .T.
EndIf

If lExibe
	lRet 	:= .F.
	lExibe 	:= .F.
	If (Len(aCpos) < 1 ) .or. lForca
		//aAdd(aCpos,{" "," "," "," "," "})
		//pergunta se deseja gerar Solicitação de Compras
		If MsgYesNo(STR0286, STR0287) //"Deseja gerar Solicitação de Compras?" ###  "Sem produtos para indicar"
			//Gera Solicitação de Compras
			LOCA05928()
		EndIf
	Else

		If Len(aCpos) > 0 
			//monta a tela da consulta
			DEFINE MSDIALOG oDlg TITLE STR0259 FROM 0,0 TO 320,700 PIXEL	// "Equipamentos disponíveis"
				//Texto de pesquisa
				@ 003,002 MsGet oPesqEv Var cPesq Size 292,009 COLOR CLR_BLACK PIXEL OF oDlg

				//Interface para selecao de indice e filtro
				@ 003,295 Button STR0002    Size 043,012 PIXEL OF oDlg Action IF(!Empty(oLbx:aArray[oLbx:nAt][2]),ITPESQ(oLbx,cPesq),Nil) //Pesquisar

				@ 023,003 LISTBOX oLbx FIELDS HEADER STR0225, STR0260, STR0126, STR0223, STR0261 SIZE 345,115 OF oDlg PIXEL	// 'Bem' ### 'Descrição' ### 'Produto' ### 'Familia' ### 'Modelo'
				oLbx:SetArray( aCpos )
				//copia array original
				aLstBxOri := aClone(oLbx:aArray)
				oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3], aCpos[oLbx:nAt,4], aCpos[oLbx:nAt,5]}}
				oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3], oLbx:aArray[oLbx:nAt,4], oLbx:aArray[oLbx:nAt,5]}}}
			DEFINE SBUTTON FROM 140,318 TYPE 1 ACTION (oDlg:End(),  lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3], oLbx:aArray[oLbx:nAt,4], oLbx:aArray[oLbx:nAt,5]})  ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg CENTER

			//retorna o resultado
			If Len(aRet) > 0 .And. lRet .or. lForca
				If Empty(aRet[1]) .or. lForca
					lRet := .F.
					cEscolhe := ""
				Else
					//If alltrim(ST9->T9_CODBEM) == alltrim(aRet[1])
					//	lRet := .T.
						cEscolhe := aRet[1]
						//caso seja consulta ST9003, posiciona na ST9
						If lPadrao
							ST9->(dbSetOrder(1))
        					ST9->(dbSeek(xFilial("ST9")+aRet[1]))
						EndIf
					//EndIF
				EndIf
			EndIf
		Else
			//mostra mensagem para não simplesmente fechar a tela
			//FWAlertWarning(STR0181, STR0022) //"Não foram localizados equipamentos para substituição." ###  "Atenção!" //linha não foi adicionada para não cair no advpr sem necessidade
			lRet := .F.
		EndIF
	EndIf
Else
	If len(ST9->T9_CODBEM) == len(cEscolhe) .and. ST9->T9_CODBEM == cEscolhe
		lRet := .T.
	Else
	 	lRet := .F.
	EndIF
EndIf
RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA05931

Retorna Cliente do do Conjunto Transportador
@type  Static Function
@author Jose Eulalio
@since 27/05/2022

/*/
//------------------------------------------------------------------------------
Function LOCA05931(cCampo)
Local cRet		:= ""
Local aAreAtu	:= GetArea()
Local aAreFp1	:= FP1->(GetArea())
Local aAreFq7	:= FQ7->(GetArea())
Local lLOCX304	:= SuperGetMV("MV_LOCX304",.F.,.F.) // Utiliza o cliente destino informado na aba conjunto transportador será o utilizado como cliente da nota fiscal de remessa,
Local nPosVirt	:= 0

nPosVirt:= TamSx3(cCampo)[1]

If lLOCX304 .and. Type("nPosVirt") == "N" .And. nPosVirt > 0
	FQ7->(DbSetOrder(3)) // FQ7_FILIAL + FQ7_VIAGEM
	If FQ7->(DbSeek(xFilial("FQ7") + FQ2->FQ2_VIAGEM))
		//SE ENVIO
		If FQ2->FQ2_TPROMA == "0"
			If cCampo == "FQ2_CLIFAT"
				cRet	:= FQ7->FQ7_LCCDES
			ElseIf cCampo == "FQ2_LOJFAT"
				cRet	:= FQ7->FQ7_LCLDES
			ElseIf cCampo == "FQ2_NOMFAT"
				cRet	:= FQ7->FQ7_LOCDES
			EndIf
		//SE RETORNO
		Else 
			If cCampo == "FQ2_CLIFAT"
				cRet	:= FQ7->FQ7_LCCORI
			ElseIf cCampo == "FQ2_LOJFAT"
				cRet	:= FQ7->FQ7_LCLORI
			ElseIf cCampo == "FQ2_NOMFAT"
				cRet	:= FQ7->FQ7_LOCCAR
			EndIf
		EndIf
	EndIf
EndIf

//Caso não venha do parâmetro, busca da Obra
If Empty(cRet)
	FP1->(DbSetOrder(1)) //FP1_FILIAL+FP1_PROJET+FP1_OBRA
	If FP1->(DbSeek(xFilial("FP1") + FQ2->(FQ2_PROJET + FQ2_OBRA)))
		If cCampo == "FQ2_CLIFAT"
			cRet	:= FP1->FP1_CLIORI
		ElseIf cCampo == "FQ2_LOJFAT"
			cRet	:= FP1->FP1_LOJORI
		ElseIf cCampo == "FQ2_NOMFAT"
			cRet	:= FP1->FP1_NOMORI
		EndIf
	EndIf
EndIf

RestArea(aAreAtu)
RestArea(aAreFp1)
RestArea(aAreFq7)

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ITPESQEV

Funcao para pesquisar dentro da consulta padrao SXB
@type  Static Function
@author Jose Eulalio
@since 16/09/2022

/*/
//------------------------------------------------------------------------------
Static Function ITPESQ(oLstBx,cPesq)
Local _nX		
Local _nY		
Local nTamArray	:= len(oLstBx:aArray)
Local nContArra	:= 1
Local _lAchou 	:= .F.
Local aLstBxNew	:= {}

If empty(cPesq) .Or. Len(cPesq) < 2
	MsgAlert(STR0288,STR0022)	// "Favor informar o que deseja pesquisar " ##### "Atenção!"
	oLstBx:setarray(aLstBxOri)
	oLstBx:bLine 	:= {|| {aLstBxOri[oLstBx:nAt,1],;
							aLstBxOri[oLstBx:nAt,2],;
							aLstBxOri[oLstBx:nAt,3],;
							aLstBxOri[oLstBx:nAt,4],;
							aLstBxOri[oLstBx:nAt,5]}}	
	oLstBx:nAt := 1
	oLstBx:Refresh()
Else
	//Busca a partir da linha posicionada + 1
	For _nx := 1 to nTamArray
		For _nY := 1 to 5
			If UPPER(AllTrim(cPesq)) $ UPPER(alltrim(oLstBx:aArray[_nX,_nY]))
				Aadd(aLstBxNew,oLstBx:aArray[_nX])
				Exit
			EndIf
			++nContArra
		Next _nY
	Next _nx
	If Len(aLstBxNew) > 0
		_lAchou := .T.
		aSort(aLstBxNew,,,{|x,y| x[1]+x[5] < y[1]+y[5]})
		oLstBx:setarray(aLstBxNew)
		oLstBx:bLine 	:= {|| {aLstBxNew[oLstBx:nAt,1],;
								aLstBxNew[oLstBx:nAt,2],;
								aLstBxNew[oLstBx:nAt,3],;
								aLstBxNew[oLstBx:nAt,4],;
								aLstBxNew[oLstBx:nAt,5]}}	
		oLstBx:nAt := 1
		oLstBx:Refresh()
	EndIf
	If !_lAchou
		If nContArra >= nTamArray
			MsgAlert(STR0289,STR0022)	// "Não localizado." ##### "Atenção!"
			oLstBx:setarray(aLstBxOri)
			oLstBx:bLine 	:= {|| {aLstBxOri[oLstBx:nAt,1],;
									aLstBxOri[oLstBx:nAt,2],;
									aLstBxOri[oLstBx:nAt,3],;
									aLstBxOri[oLstBx:nAt,4],;
									aLstBxOri[oLstBx:nAt,5]}}	
			oLstBx:nAt := 1
			oLstBx:Refresh()
		Else
			oLstBx:nAt := 1
		EndIf
	EndIf
EndIf
Return .T.
