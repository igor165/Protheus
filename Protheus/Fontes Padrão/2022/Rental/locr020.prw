/*/{PROTHEUS.DOC} LOCR020.PRW 
ITUP BUSINESS - TOTVS RENTAL
RELATORIO DISPONIBLIDADE DE FROTA
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "RWMAKE.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

FUNCTION LOCR020()
// --> DECLARACAO DE VARIAVEIS.
LOCAL CDESC1       := "ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO "
LOCAL CDESC2       := "DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
LOCAL CDESC3       := "DISPONIBILIDADE DE FROTA"
LOCAL TITULO       := "DISPONIBILIDADE DE FROTA"
LOCAL NLIN         := 80
LOCAL CPERG        :="LOCP022"
LOCAL CABEC1       := ""
LOCAL CABEC2       := ""
LOCAL AORD         := {}       
LOCAL IMPRIME 
//LOCAL CSTATUS    := ""

PRIVATE LEND        := .F.
PRIVATE LABORTPRINT := .F.
PRIVATE LIMITE      := 120
PRIVATE TAMANHO     := "M"
PRIVATE NOMEPROG    := "LOCR020" // COLOQUE AQUI O NOME DO PROGRAMA PARA IMPRESSAO NO CABECALHO
PRIVATE NTIPO       := 18
PRIVATE ARETURN     := { "ZEBRADO", 1, "ADMINISTRACAO", 2, 2, 1, "", 1}
PRIVATE NLASTKEY    := 0
PRIVATE CBTXT       := SPACE(10)
PRIVATE CBCONT      := 00
PRIVATE CONTFL      := 01
PRIVATE M_PAG       := 01
PRIVATE WNREL       := "LOCR020" // COLOQUE AQUI O NOME DO ARQUIVO USADO PARA IMPRESSAO EM DISCO
PRIVATE CSTRING     := ""

IMPRIME := .T.

VALIDPERG(CPERG)
PERGUNTE(CPERG,.T.)

IF MV_PAR03 == 1
	TITULO  := "DISPONIBILIDADE DE FROTA - TRANSPORTES"
			  //         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	          //1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	CABEC1  := "FROTA    AT                            CLIENTE                                 PROGRAMACAO     LOCALIDADE                                  STATUS"        
	TAMANHO := "G"
ELSE
	DO CASE
	CASE MV_PAR03 == 2 
		TITULO       := "DISPONIBILIDADE DE FROTA - GUINDASTES"
	CASE MV_PAR03 == 3
	    TITULO       := "DISPONIBILIDADE DE FROTA - PLATAFORMAS"
	CASE MV_PAR03 == 4
	    TITULO       := "DISPONIBILIDADE DE FROTA - ACESSORIOS"
	ENDCASE

	IF MV_PAR08 = 1
		CABEC1	:= "FROTA             FANTASIA      NOME DO BEM                               ACESSORIO         FANTASIA      LOCAL                                 CLIENTE                               DT INICIO   DT FIM      STATUS
				//  XXXXXXXXXXXXXXXX  XXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99/99/9999  99/99/9999  XXXXXXXXXXXXXX
				//  0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
				//           10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220
				//  FPO_FROTA         T9_NOME                                   T9_CODFA      FPO_CODBEM        POSICIONE     FPO_NOMCLI                            FPO_LOCAL                             FPO_DTINI   FPO_DTFIM   CSTATUS
    ELSE
		CABEC1	:= "FROTA             FANTASIA      NOME DO BEM                               ACESSORIO         FANTASIA      NOME DO BEM                           CLIENTE                               DT INICIO   DT FIM      STATUS
				//  XXXXXXXXXXXXXXXX  XXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99/99/9999  99/99/9999  XXXXXXXXXXXXXX
				//  0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
				//           10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220
				//  FPO_FROTA         T9_NOME                                   T9_CODFA      FPO_CODBEM        POSICIONE     FPO_NOMCLI                            FPO_LOCAL                             FPO_DTINI   FPO_DTFIM   CSTATUS
    ENDIF
//    CABEC1:= "EQUIPAMENTO                                        CLIENTE                                                      INICIO        FIM                      STATUS"
	TAMANHO:= "G"
ENDIF    	

MONTABEM()

// --> MONTA A INTERFACE PADRAO COM O USUARIO...
WNREL := SETPRINT(CSTRING,NOMEPROG,CPERG,@TITULO,CDESC1,CDESC2,CDESC3,.T.,AORD,.T.,TAMANHO,,.T.)

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
ฑฑบFUNO    ณRUNREPORT บ AUTOR ณ AP6 IDE            บ DATA ณ  25/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESCRIO ณ FUNCAO AUXILIAR CHAMADA PELA RPTSTATUS. A FUNCAO RPTSTATUS บฑฑ
ฑฑบ          ณ MONTA A JANELA COM A REGUA DE PROCESSAMENTO.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ PROGRAMA PRINCIPAL                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/   
STATIC FUNCTION RUNREPORT(CABEC1,CABEC2,TITULO,NLIN)

LOCAL CCODBEM := ""
LOCAL CAS     := ""  
LOCAL CFROTA  := ""
LOCAL CPROJET := ""
LOCAL CCLI    := ""
LOCAL NREC    := 0

DBSELECTAREA("TRB")

// --> SETREGUA -> INDICA QUANTOS REGISTROS SERAO PROCESSADOS PARA A REGUA.
SETREGUA(RECCOUNT())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ POSICIONAMENTO DO PRIMEIRO REGISTRO E LOOP PRINCIPAL. PODE-SE CRIAR ณ
//ณ A LOGICA DA SEGUINTE MANEIRA: POSICIONA-SE NA FILIAL CORRENTE E PRO ณ
//ณ CESSA ENQUANTO A FILIAL DO REGISTRO FOR A FILIAL CORRENTE. POR EXEM ณ
//ณ PLO, SUBSTITUA O DBGOTOP() E O WHILE !EOF() ABAIXO PELA SINTAXE:    ณ
//ณ                                                                     ณ
//ณ DBSEEK(XFILIAL())                                                   ณ
//ณ WHILE !EOF() .AND. XFILIAL() == A1_FILIAL                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DBGOTOP()
WHILE !EOF() 

   // --> VERIFICA O CANCELAMENTO PELO USUARIO... 
   IF LABORTPRINT
      @ NLIN,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      EXIT
   ENDIF

   // --> IMPRESSAO DO CABECALHO DO RELATORIO... 
   IF NLIN > 55 // SALTO DE PมGINA. NESTE CASO O FORMULARIO TEM 55 LINHAS...
      CABEC(TITULO,CABEC1,CABEC2,NOMEPROG,TAMANHO,NTIPO)
      NLIN := 8
   ENDIF

	// --> REGRAS DE IMPRESSAO
	IF     MV_PAR03 == 1 										// TRANSPORTES
		CSTATUS := POSICIONE("SX5",1,XFILIAL("SX5")+"77" +ALLTRIM(TRB->FPM_STATUS),"X5_DESCRI") 
	ELSEIF MV_PAR03 = 2 .OR. MV_PAR03 = 3 .OR. MV_PAR03 = 4   	// GUINDASTES, PLATAFORMAS OU ACESSORIOS
	//  CSTATUS := POSICIONE("SX5",1,XFILIAL("SX5")+"77" +ALLTRIM(TRB->FPM_STATUS),"X5_DESCRI") 
	//	1=DISPONIVEL;2=MOBILIZADO;3=TRABALHANDO;4=DESMOBILIZANDO;5=MONTAGEM;6=DESMONTAGEM;7=VENDA;8=VENDIDO;9=MANUTENCAO           ;R=RESERVADO
	//  1=DISPO     ;2=MOB       ;3=TRAB       ;4=DESMOBI       ;5=MONTA   ;6=DESMONTA   ;7=VENDA;8=VENDIDO;9=MANUT     ;0=MO; F=FO;R=RESERVADO
		DO CASE
		CASE TRB->FPO_STATUS = "1"; CSTATUS := "DISPONIVEL    " 
		CASE TRB->FPO_STATUS = "2"; CSTATUS := "MOBILIZADO    " 
		CASE TRB->FPO_STATUS = "3"; CSTATUS := "TRABALHANDO   " 
		CASE TRB->FPO_STATUS = "4"; CSTATUS := "DESMOBILIZANDO" 
		CASE TRB->FPO_STATUS = "5"; CSTATUS := "MONTAGEM      " 
		CASE TRB->FPO_STATUS = "6"; CSTATUS := "DESMONTAGEM   " 
		CASE TRB->FPO_STATUS = "7"; CSTATUS := "VENDA         " 
		CASE TRB->FPO_STATUS = "8"; CSTATUS := "VENDIDO       " 
		CASE TRB->FPO_STATUS = "9"; CSTATUS := "MANUTENCAO    " 
		CASE TRB->FPO_STATUS = "0"; CSTATUS := "MO            " 
		CASE TRB->FPO_STATUS = "F"; CSTATUS := "FO            " 
		CASE TRB->FPO_STATUS = "R"; CSTATUS := "RESERVADO     " 
		OTHERWISE                 ; CSTATUS := ""
		ENDCASE
	ENDIF
   
	NREC := RECNO()

	// --> POSICIONA NA TABELA DE PROJETOS
	DBSELECTAREA("FP0")
	DBSETORDER(1)
	DBSEEK(XFILIAL()+CPROJET)
	CCLI := ZA0_CLINOM
   				     
	DBSELECTAREA("TRB")
	DBGOTO(NREC)					// ##	// RECNO(NREC) 

	// IMPRESSAO DO RELATORIO     
	IF     MV_PAR03 == 1 // TRANSPORTES   
		IF CFROTA <> TRB->T9_CODFA
	    	NLIN := NLIN + 2
	 	  	@ NLIN,00 PSAY ALLTRIM(TRB->T9_CODFA) + " - " + ALLTRIM(TRB->T9_NOME) + " (" + ALLTRIM(TRB->T9_CODBEM) + ")"
		ENDIF
	   	NLIN := NLIN + 1
	    @ NLIN, 00 PSAY TRB->T9_CODFA                                        
	    @ NLIN, 10 PSAY TRB->FPM_AS    
	    @ NLIN, 38 PSAY POSICIONE("FP0",1,XFILIAL("FP0")  + TRB->FPM_PROJET  , "ZA0_CLINOM")		//CCLI
	   	@ NLIN, 80 PSAY SUBST(TRB->FPM_DTPROG,7,2)+"/"+SUBST(TRB->FPM_DTPROG,5,2)+"/"+SUBST(TRB->FPM_DTPROG,1,4) 
	   	@ NLIN, 95 PSAY FPM_LOCALI
	   	@ NLIN,140 PSAY CSTATUS     
	   	
	    CAS     := TRB->FPM_AS
	    CFROTA  := TRB->T9_CODFA
	    CCODBEM := TRB->T9_CODBEM

	ELSEIF MV_PAR03 == 2 .OR. MV_PAR03 == 3 .OR. MV_PAR03 = 4	// GUINDASTES, PLATAFORMAS OU ACESSORIOS
		_DLANI := CTOD(SUBST(TRB->FPO_DTINI,7,2)+"/"+SUBST(TRB->FPO_DTINI,5,2)+"/"+SUBST(TRB->FPO_DTINI,1,4))
		_DLANF := CTOD(SUBST(TRB->FPO_DTFIM,7,2)+"/"+SUBST(TRB->FPO_DTFIM,5,2)+"/"+SUBST(TRB->FPO_DTFIM,1,4))
		_DPERI := MV_PAR04
		_DPERF := MV_PAR05
		IF !((_DLANI<=_DPERI .AND. _DLANI<=_DPERF .AND. _DLANF>=_DPERI .AND. _DLANF>=_DPERF) .OR. ;	// PERอODO TOTALMENTE DENTRO DO LANวAMENTO
			 (_DLANI>=_DPERI .AND. _DLANI<=_DPERF .AND. _DLANF>=_DPERI .AND. _DLANF<=_DPERF) .OR. ;	// PERอODO TOTALMENTE FORA DO LANวAMENTO
			 (_DLANI<=_DPERI .AND. _DLANI<=_DPERF .AND. _DLANF>=_DPERI .AND. _DLANF<=_DPERF) .OR. ;	// LANวAMENTO TERMINA NO PERอODO
			 (_DLANI>=_DPERI .AND. _DLANI<=_DPERF .AND. _DLANF>=_DPERI .AND. _DLANF>=_DPERF))		// LANวAMENTO INICIA NO PERอODO
	
			DBSKIP() // AVANCA O PONTEIRO DO REGISTRO NO ARQUIVO
			LOOP
		ENDIF
	
		IF CCODBEM <> TRB->T9_CODBEM
			NLIN := NLIN + 1
			@ NLIN,000  PSAY TRB->FPO_FROTA 
			@ NLIN,018  PSAY TRB->T9_CODFA
			@ NLIN,032  PSAY TRB->T9_NOME
		ENDIF 

		@ NLIN,074		PSAY TRB->FPO_CODBEM
		@ NLIN,092		PSAY POSICIONE("ST9",1,XFILIAL("ST9") + TRB->FPO_CODBEM,"T9_CODFA")
		@ NLIN,106		PSAY IIF(MV_PAR08 == 1,LEFT(TRB->FPO_LOCAL ,36),LEFT(POSICIONE("ST9",1,XFILIAL("ST9") + TRB->FPO_CODBEM,"T9_NOME"),36))
		@ NLIN,144		PSAY LEFT(TRB->FPO_NOMCLI,36)
	    @ NLIN,182 		PSAY SUBSTR(TRB->FPO_DTINI,7,2) + "/" + SUBSTR(TRB->FPO_DTINI,5,2) + "/" + SUBSTR(TRB->FPO_DTINI,1,4)
	  	@ NLIN,194 		PSAY SUBSTR(TRB->FPO_DTFIM,7,2) + "/" + SUBSTR(TRB->FPO_DTFIM,5,2) + "/" + SUBSTR(TRB->FPO_DTFIM,1,4)
	  	@ NLIN,206 		PSAY CSTATUS

	    NLIN := NLIN + 1 // AVANCA A LINHA DE IMPRESSAO
	    CCODBEM:=TRB->T9_CODBEM
	ENDIF
	   
	DBSKIP() // AVANCA O PONTEIRO DO REGISTRO NO ARQUIVO
	   
ENDDO

// --> FINALIZA A EXECUCAO DO RELATORIO... 
SET DEVICE TO SCREEN

// --> SE IMPRESSAO EM DISCO, CHAMA O GERENCIADOR DE IMPRESSAO... 
IF ARETURN[5]==1
   DBCOMMITALL()
   SET PRINTER TO
   OURSPOOL(WNREL)
ENDIF

MS_FLUSH()

RETURN 



// ======================================================================= \\
STATIC FUNCTION MONTABEM()
// ======================================================================= \\
// --> FUNCAO PARA MONTAR OS TRANSPORTES E TIPOS DE TANSPORTES

IF SELECT("TRB") > 0
   DBSELECTAREA("TRB")
   DBCLOSEAREA()
ENDIF   

IF MV_PAR03 == 1 //TRANSPORTES - TABELA ZLE
	CQUERY := " SELECT T9_CODBEM,T9_CODFA,T9_CODFAMI,T9_NOME,FPM_DTPROG, FPM_STATUS, FPM_AS, "
	CQUERY += " FPM_PROJET, FPM_LOCALI, FPM_OBRA, FPM_VIAGEM "  
	CQUERY += " FROM "+ RETSQLNAME("ST9") + " ST9 
	CQUERY += " LEFT OUTER JOIN "+ RETSQLNAME("FPM") + " ZLE ON  T9_CODBEM = FPM_FROTA "
	CQUERY += " WHERE FPM_FILIAL BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"' "
	IF !EMPTY(MV_PAR01)
		CQUERY += " AND T9_CODFAMI  =  '"+MV_PAR01+"'
	ENDIF	
	IF !EMPTY(MV_PAR02)                               
		CQUERY += " AND T9_CODBEM  =  '"+MV_PAR02+"'
	ENDIF	
	CQUERY += " AND FPM_DTPROG  BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"' "
	CQUERY += " AND ST9.D_E_L_E_T_ = ' ' AND ZLE.D_E_L_E_T_ = ' ' " 
	CQUERY += " ORDER BY T9_CODFA,FPM_DTPROG "
ELSEIF MV_PAR03 == 2 .OR. MV_PAR03 == 3	.OR. MV_PAR03 == 4	//GUINDASTES, GRUAS, PLATAFORMAS OU ACESSORIOS - TABELA ZLG
	CQUERY := " SELECT T9_CODBEM,T9_NOME,T9_CODFA,T9_CODFAMI,FPO_DTINI,FPO_DTFIM,FPO_PROJET,FPO_STATUS, "
	CQUERY += " FPO_NOMCLI, FPO_LOCAL, FPO_CODBEM, FPO_FROTA "  
	CQUERY += " FROM "+ RETSQLNAME("ST9") + " ST9 
	CQUERY += " LEFT OUTER JOIN "+ RETSQLNAME("FPO") + " ZLG ON  T9_CODBEM = FPO_FROTA " 
	CQUERY += " WHERE FPO_FILIAL BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"' "
	IF MV_PAR03 = 2 .OR. MV_PAR03 = 3
		CQUERY += " AND FPO_CODBEM = '" + SPACE(LEN(FPO->FPO_CODBEM)) + "'
	ELSE
		CQUERY += " AND FPO_CODBEM <> '" + SPACE(LEN(FPO->FPO_CODBEM)) + "'
	ENDIF
	IF !EMPTY(MV_PAR01)
		CQUERY += " AND T9_CODFAMI = '" + MV_PAR01 + "'
	ENDIF
	IF !EMPTY(MV_PAR02) 
		CQUERY += " AND T9_CODBEM  = '" + MV_PAR02 + "'
	ENDIF
	CQUERY += " AND ST9.D_E_L_E_T_ = ' '  AND ZLG.D_E_L_E_T_ = ' '"
	CQUERY += " ORDER BY T9_CODFA,FPO_DTINI "
/*ELSEIF MV_PAR03 == 3 //ACESSORIOS - TABELA ZLG                     
	CQUERY := " SELECT T9_CODBEM,T9_NOME,T9_CODFA,T9_CODFAMI,FPO_DTINI,FPO_DTFIM,FPO_PROJET,FPO_STATUS, "
	CQUERY += " FPO_NOMCLI, FPO_LOCAL "  
	CQUERY += " FROM "+ RETSQLNAME("ST9") + " ST9 
	//CQUERY += " FROM "+ RETSQLNAME("ST9") + " ST9 ,"+ RETSQLNAME("FPM") + " ZLE "
	CQUERY += " LEFT OUTER JOIN "+ RETSQLNAME("FPO") + " ZLG ON  T9_CODBEM = FPO_FROTA "
	IF !EMPTY(MV_PAR01)
		CQUERY += " WHERE T9_CODFAMI  =  '"+MV_PAR01+"'
	ENDIF
	IF !EMPTY(MV_PAR02) 
		CQUERY += " AND T9_CODBEM  =  '"+MV_PAR02+"'
	ENDIF
	CQUERY += " AND ST9.D_E_L_E_T_ = ' '  AND ZLG.D_E_L_E_T_ = ' '"*/
ENDIF

CQUERY := CHANGEQUERY(CQUERY)
TCQUERY CQUERY NEW ALIAS "TRB"

RETURN



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFUNO    ณ VALIDPERG บ AUTOR ณ AP5 IDE            บ DATA ณ 13/09/2006 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRIO ณ VERIFICA A EXISTENCIA DAS PERGUNTAS CRIANDO-AS CASO SEJA   บฑฑ
ฑฑบ          ณ NECESSARIO (CASO NAO EXISTAM).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ PROGRAMA PRINCIPAL                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION VALIDPERG(CPERG)

LOCAL _SALIAS := ALIAS()
LOCAL AREGS := {}
LOCAL I,J

DBSELECTAREA("SX1")
DBSETORDER(1)
CPERG := PADR(CPERG,10)

//         {GRUPO,ORDEM,PERGUNT         ,PERSPA         ,PERENG         ,VARIAVL ,TIPO	,TAMANHO,DECIMAL,PRESEL	,GSC,VALID      ,VAR01      ,DEF01			,DEFSPA1		,DEFENG1        ,CNT01	,VAR02	,DEF02			,DEFSPA2		,DEFENG2		,CNT02	,VAR03	,DEF03			,DEFSPA3		,DEFENG3		,CNT03	,VAR04	,DEF04			,DEFSPA4		,DEFENG4		,CNT04	,VAR05	,DEF05	,DEFSPA5,DEFENG5,CNT05	,F3   	,PYME	,GRPSXG	,HELP	,PICTURE     })
AADD(AREGS,{CPERG,"01" ,"FAMILIA"		,"FAMILIA"		,"FAMILIA"		,"MV_CH1","C"	,06		,0		,0		,"G",""			,"MV_PAR01"	,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""		,""		,""		,""		,"ST6"	,"S"	,""		,""		,""})
AADD(AREGS,{CPERG,"02" ,"FROTA"			,"FROTA"		,"FROTA"		,"MV_CH2","C"	,16		,0		,0		,"G",""			,"MV_PAR02"	,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""		,""		,""		,""		,"ST9"	,"S"	,""		,""		,""})
AADD(AREGS,{CPERG,"03" ,"TIPO"			,"TIPO"			,"TIPO"			,"MV_CH3","C"	,01		,0		,1		,"C",""			,"MV_PAR03"	,"TRANSPORTES"	,"TRANSPORTES"	,"TRANSPORTES"	,""		,""		,"GUINDASTES"	,"GUINDASTES"	,"GUINDASTES"	,""		,""		,"PLATAFORMAS"	,"PLATAFORMAS"	,"PLATAFORMAS"	,""		,""		,"ACESSORIOS"	,"ACESSORIOS"	,"ACESSORIOS"	,""		,""		,""		,""		,""		,""		,""		,"S"	,""		,""		,""}) 
AADD(AREGS,{CPERG,"04" ,"PERIODO DE ?"	,"PERIODO DE ?"	,"PERIODO DE?"	,"MV_CH4","D"	,08		,0		,0		,"G",""			,"MV_PAR04"	,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""		,""		,""		,""		,""		,"S"	,""		,""		,""}) 
AADD(AREGS,{CPERG,"05" ,"PERIODO ATE ?"	,"PERIODO ATE ?","PERIODO ATE?"	,"MV_CH5","D"	,08		,0		,0		,"G","" 		,"MV_PAR05"	,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""		,""		,""		,""		,""		,"S"	,""		,""		,""}) 
AADD(AREGS,{CPERG,"06" ,"FILIAL DE ?"	,"FILIAL DE ?"	,"FILIAL DE?"	,"MV_CH6","C"	,02		,0		,0		,"G",""			,"MV_PAR06"	,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""		,""		,""		,""		,""		,"S"	,""		,""		,""})
AADD(AREGS,{CPERG,"07" ,"FILIAL ATE ?"	,"FILIAL ATE ?"	,"FILIAL ATE?"	,"MV_CH7","C"	,02		,0		,0		,"G",""			,"MV_PAR07"	,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""				,""				,""				,""		,""		,""		,""		,""		,""		,""		,"S"	,""		,""		,""})
AADD(AREGS,{CPERG,"08" ,"CAMPO LOCAL ?"	,"CAMPO LOCAL ?","CAMPO LOCAL ?","MV_CH8","C"	,00		,0		,1		,"C",""			,"MV_PAR08"	,"SIM"			,"SIM"        	,"SIM"        	,""		,""		,"NรO"       	,"NรO"       	,"NรO"       	,""		,""		,"",""			,"PLATAFORMAS"	,""				,""		,""		,""				,""				,""				,""		,""		,""		,""		,""		,""		,""		,"S"	,""		,""		,""}) 

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
        NEXT J 
        MSUNLOCK()
    ENDIF
NEXT I 

DBSELECTAREA(_SALIAS)

RETURN
