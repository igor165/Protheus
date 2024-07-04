#INCLUDE "loca021.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{PROTHEUS.DOC} LOCA021.PRW
ITUP BUSINESS - TOTVS RENTAL
FUNÇÃO UTILIZADA NA GERAÇÃO DOS PEDIDOS DE VENDA DO FATURAMENTO AUTOMÁTICO.
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
/*/

FUNCTION LOCA021(_APARAM , _CPRJINI , _CPRJFIM , _APRJAS, _lGeraPVx, _nTipoF) 
LOCAL AAREA
LOCAL CCADASTRO  := STR0001 //" PROCESSA FATURAMENTO"
LOCAL ASAYS      := {}
LOCAL ABUTTONS   := {}
LOCAL NOPC       := 0
LOCAL _cTemp1 := SuperGetMV("MV_LOCX083",.F.,"") // TES de Remessa
LOCAL _cTemp2 := SuperGetMV("MV_LOCX080",.F.,"") // TES de Faturamento 1
LOCAL _cTemp3 := SuperGetMV("MV_LOCX078",.F.,"") // TES de Faturamento 2
LOCAL _cTemp4 := SuperGetMV("MV_LOCX253",.F.,"") // TES de Faturamento 3
local _lPassa := .T.
Local _lRetB  := .T.

PRIVATE OPROCESS
PRIVATE OGETPER
PRIVATE _CGETPER
PRIVATE CPERG    := "LOCP003"
PRIVATE _LJOB    := ( _APARAM <> NIL .OR. VALTYPE(_APARAM) == "A" )
PRIVATE APRJAS
PRIVATE _LGERA   := .T.

DEFAULT _CPRJINI  := ""
DEFAULT _CPRJFIM  := ""
DEFAULT _APRJAS   := {}
DEFAULT _lGeraPVx := .T.

// Frank 16/09/21
Private CPRJINI := _CPRJINI
Private CPRJFIM := _CPRJINI
Private nTipoF  := _nTipoF
Private lGeraPVx:= _lGeraPVx

Private _lTem12	:= .F.
Private _lTem13	:= .F.
Private _lTem14	:= .F.

PERGUNTE(CPERG,.F.)
If type("MV_PAR12") == "C" .and. len(MV_PAR12) > 1
	_lTem12 := .T.
EndIf
If type("MV_PAR13") == "C" .and. len(MV_PAR13) > 1
	_lTem13 := .T.
EndIf
If type("MV_PAR14") == "N"
	_lTem14 := .T.
EndIf

APRJAS := _APRJAS

If !empty(_cTemp1)
	If !empty(_cTemp2)
		if _cTemp1 == _cTemp2
			_lPassa := .F.
		EndIf
	EndIf
	If !empty(_cTemp3)
		if _cTemp1 == _cTemp3
			_lPassa := .F.
		EndIf
	EndIf
	If !empty(_cTemp4)
		if _cTemp1 == _cTemp4
			_lPassa := .F.
		EndIf
	EndIf
EndIF

If !_lPassa
	IF !_LJOB
		MsgAlert(STR0002,STR0003) //"A TES de Remessa não pode ser igual à TES de Faturamento, Verifique os parâmetros: MV_LOCX083, MV_LOCX080, MV_LOCX078, MV_LOCX253."###"Processo bloqueado."
	EndIf
	Return
EndIF

IF _LJOB

	PROCFAT() 

ELSE

	AAREA := GETAREA()

	IF EMPTY(_CPRJINI)
		PERGUNTE(CPERG,.F.)

		AADD(ASAYS,OEMTOANSI(STR0004)) //"ESTA ROTINA TEM POR OBJETIVO GERAR OS PEDIDOS DE VENDA"
		AADD(ASAYS,OEMTOANSI(STR0005)) //"REFERENTE AO PROCESSO DE FATURAMENTO."

		AADD(ABUTTONS, { 5,.T.,{|| PERGUNTE(CPERG,.T.) }} )
		AADD(ABUTTONS, { 1,.T.,{|O| NOPC:= 1,IIF( VALPROC() .AND. MSGYESNO(OEMTOANSI(STR0006),OEMTOANSI(STR0007)),O:OWND:END(),NOPC:=0) } } ) //"CONFIRMA PROCESSAMENTO?"###"ATENÇÃO"
		AADD(ABUTTONS, { 2,.T.,{|O| O:OWND:END() }} )

		FORMBATCH( CCADASTRO, ASAYS, ABUTTONS,,200,405 )
	ELSE
		MV_PAR01 := STOD("")
		MV_PAR02 := STOD(CVALTOCHAR(YEAR(DATE())+1)+"1231")
		MV_PAR03 := FP0->FP0_CLI
		MV_PAR04 := FP0->FP0_CLI
		MV_PAR05 := FP0->FP0_LOJA
		MV_PAR06 := FP0->FP0_LOJA
		MV_PAR07 := SPACE(16)
		MV_PAR08 := REPLICATE("Z",16)
		MV_PAR09 := _CPRJINI
		MV_PAR10 := _CPRJFIM
		MV_PAR11 := nTipoF
		If _lTem12
			MV_PAR12 := space(tamsx3("B1_COD")[1])
		EndIF
		If _lTem13
			MV_PAR13 := replicate("Z",tamsx3("B1_COD")[1])
		EndIF
		If _lTem14
			MV_PAR14 := 1 // Não habilitar a selecao em tela
		EndIF
		IF VALPROC() .AND. MSGYESNO(STR0008 + SUPERGETMV("MV_LOCX248",.F.,STR0009) + " " + ALLTRIM(FP0->FP0_PROJET) + "?") //"CONFIRMA O PROCESSAMENTO DO FATURAMENTO DO "###"PROJETO"
			NOPC := 1
		ENDIF
	ENDIF

	IF EXISTBLOCK("LOCA021B")
		_lRetB := EXECBLOCK("LOCA021B" , .T. , .T. ) 
		If !_lRetB
			Return .F.
		EndIf  
	ENDIF


	IF NOPC == 1 
		_CGETPER := MV_PAR01 
	 	OPROCESS := MSAGUARDE( {|LEND| PROCFAT()}  , STR0010                 , STR0011 , .T. )  //"AGUARDE..."###"GERANDO PEDIDOS DE VENDA..."
	ENDIF 

	RESTAREA( AAREA )

ENDIF

RETURN NIL 



/*/{PROTHEUS.DOC} PROCFAT
@DESCRIPTION PROCESSA FATURAMENTO AUTOMÁTICO.
@TYPE    FUNCTION
/*/
// ======================================================================= \\
STATIC FUNCTION PROCFAT() 
// ======================================================================= \\

LOCAL   _APARAM	  := {SM0->M0_CODIGO,SM0->M0_CODFIL}
LOCAL   CARQLOCK  := "LCJLF001"


PRIVATE _LSEMLCJ  := SUPERGETMV("MV_LOCX252",.F.,.T.)
PRIVATE LOBRNFREM := SUPERGETMV("MV_LOCX067",.F.,.T.)  		// --> OBRIGA OU NAO UMA NOTA FISCAL DE REMESSA PARA GERACAO DA NOTA DE FATURAMENTO AUTOMATICO.            PADRÃO: .T. 
Private NHDLLOCK  := 0

IF _LSEMLCJ 
	// --> LOCK DE GRAVACAO DA ROTINA - MONOUSUARIO. 

	If !LockByName( CARQLOCK, .F., .F. )
		IF !_LJOB
			MSGALERT(STR0014 + CARQLOCK + STR0015 +CRLF+CRLF+STR0016 , STR0017)  //"Concorrência de processo "###", rotina em uso."###"Aguarde o processo, ou avise o administrador do sistema."###"Rental"
		ENDIF
		Return( .F. ) 
	EndIf

ENDIF

// --> PREPARA AMBIENTE DE PROCESSAMENTO.
IF _LJOB
	IF FINDFUNCTION("WFPREPENV")
		WFPREPENV(_APARAM[1] , _APARAM[2]) 
	ELSE
		PREPARE ENVIRONMENT EMPRESA _APARAM[1] FILIAL _APARAM[2]
	ENDIF
ENDIF

GERAPV(_APARAM[1] , _APARAM[2], _LSEMLCJ, CARQLOCK) 

IF _LSEMLCJ //.and. NHDLLOCK > 0
	// --> CANCELA O LOCK DE GRAVACAO DA ROTINA.
	UnLockByName( CARQLOCK, .F., .F. )
ENDIF

RETURN NIL 



/*/{PROTHEUS.DOC} GERAPV
@DESCRIPTION GERACAO DO(S) PEDIDO(S) DE VENDA DO FATURAMENTO AUTOMÁTICO.
@TYPE    FUNCTION
@VERSION 2.0
/*/
// ======================================================================= \\
STATIC FUNCTION GERAPV(_CEMP , _CFIL, _LSEMLCJ, CARQLOCK) 
// ======================================================================= \\

LOCAL   _AAREAOLD   := GETAREA()
LOCAL   _AAREASC5   := SC5->(GETAREA())
LOCAL   _AAREASC6   := SC6->(GETAREA())
LOCAL   _AAREAZA0   := FP0->(GETAREA())
LOCAL   _AAREAZA1   := FP1->(GETAREA())
LOCAL   _AAREAZAG   := FPA->(GETAREA())
LOCAL   _AAREAZC1   := FPG->(GETAREA())
LOCAL   _LCVAL      := SUPERGETMV("MV_LOCX051",.F.,.T.)
LOCAL	LFATAND     := SUPERGETMV("MV_LOCX209" ,.F.,.T.)
LOCAL	LFATLOC     := SUPERGETMV("MV_LOCX210" ,.F.,.F.)
LOCAL   LFATURA     := SUPERGETMV("MV_LOCX049"  ,.F.,.T.)		// FATURA O PEDIDO DE VENDAS? 
LOCAL	LITEMFRT    := SUPERGETMV("MV_LOCX241",.F.,.T.)
LOCAL   CMV_LOCX014  := ""
LOCAL	CITEMFRT    := SUPERGETMV("MV_LOCX069" ,.T.,"" )
LOCAL   _CNATUREZ   := SUPERGETMV("MV_LOCX065" ,.T.,"" )
LOCAL   _CTES       := SUPERGETMV("MV_LOCX080" ,.T.,"" )
LOCAL   _CTESPRO    := SUPERGETMV("MV_LOCX078" ,.T.,"" )
LOCAL   _ADADOS     := {}
LOCAL   _AITEMTEMP  := {}
LOCAL   _AZC1FAT    := {}
LOCAL   _LINCFRETE  := .F.
LOCAL   _CAS        := ""
LOCAL   _CASS       := ""
LOCAL 	CAVISO      := ""
LOCAL   NITENS      := ""
LOCAL   _CPROJET    := ""
LOCAL   _CQUERY     := ""
LOCAL   _CTXT       := ""
LOCAL   _DDTINI     := STOD("")
LOCAL   _DDTFIM     := STOD("")
LOCAL   NSA1RECNO   := 0
LOCAL   _NVALZC1    := 0
LOCAL   _NTOTZC1    := 0
LOCAL   NTOTREC     := 0
LOCAL   _NVLRSEG    := 0
LOCAL   _NX         := 0
LOCAL   NVLR_OKD    := 0 
LOCAL   _CTESEST    := " "
LOCAL   _ACAB1      := {} // FRANK 22/10/20 PEDIDOS DOS RETORNOS PARCIAIS
LOCAL   _AITEM1     := {} // FRANK 22/10/20 ITENS DOS RETORNOS PARCIAIS 
LOCAL   _CTEMP            // FRANK 22/10/20 GERACAO DOS PV RETORNO PARCIAL
LOCAL   _LMENS      := .T.
LOCAL   _LPASSA     := .T.
LOCAL   _LACHOU     
LOCAL   _AAGLUTINA  := {}    
LOCAL   _CCUSTOAG   := ""
LOCAL   _aDescCus   := {} // desconto no pedido de venda em decorrencia de existir custo extra negativo - Frank 15/02/21
LOCAL   _nDescCus   := 0  // valor do desconto - custo extra - Frank 15/02/21
LOCAL   _nDescX     := 0  // calculo do desconto total - Frank 15/02/21
LOCAL   _nDescY     := 0  // para exibir o quanto de desconto teve na mensagem dos pedidos gerados
LOCAL   _lDescCus   := .T. // Indica se o custo extra negativo foi processado - Frank 15/02/21
LOCAL   _nP
LOCAL   OOK         := LOADBITMAP(GETRESOURCES(),"LBOK")
LOCAL   ONO         := LOADBITMAP(GETRESOURCES(),"LBNO") 
LOCAL   NJANELAA    := 385 
LOCAL   NJANELAL    := 1103
LOCAL   NLBTAML	    := 540	
LOCAL   NLBTAMA	    := 145	
LOCAL	OFILBUT
LOCAL	OCANBUT
LOCAL	OMARKBUT
LOCAL	cOpcx		:= "0"
LOCAL	_aSelecao	:= {}
LOCAL	_aSeleca2	:= {}
LOCAL	_lSelecao	:= .F.
LOCAL   _nPos
Local   _CLIBLOQ := EXISTBLOCK("CLIBLOQ")
Local   _LCJLFINI := EXISTBLOCK("LCJLFINI") 
Local   _LOCA021C := EXISTBLOCK("LOCA021C")
Local   _LOCA021D := EXISTBLOCK("LOCA021D")
Local   _MV_LOC253 := SUPERGETMV("MV_LOCX253",.T.,"515")
Local   _MV_LOC080 := GETMV("MV_LOCX080")
Local   _LCJTES := EXISTBLOCK("LCJTES")
Local   _MV_LOCALIZ := getmv("MV_LOCALIZ",,"S")
Local   _LCJLFITE := EXISTBLOCK("LCJLFITE")
Local   _LCJLFFRT := EXISTBLOCK("LCJLFFRT")
Local   _LOCA021A := EXISTBLOCK("LOCA021A")
Local   _LCJNAT := EXISTBLOCK("LCJNAT")
Local   _MV_LOC065 := GETMV("MV_LOCX065")
Local   _LCJLFCAB := EXISTBLOCK("LCJLFCAB")
Local   _MV_LOC278 := supergetmv("MV_LOCX278",,.T.)
Local   _LCJATFPG := EXISTBLOCK("LCJATFPG")
Local   _LCJATZAG := EXISTBLOCK("LCJATZAG")
Local   _MV_LOC243 := SUPERGETMV("MV_LOCX243",.F.,.F.)
Local   _LCJATFIM := EXISTBLOCK("LCJATFIM")
Local   _MV_AGLUNFS := SUPERGETMV("MV_AGLUNFS",,.F.)
Local   _MV_AGLUPRO := SUPERGETMV("MV_AGLUPRO",,"")
Local   _LOCA061Z := EXISTBLOCK("LOCA061Z") 
Local	cCliFat		:= ""
Local	cLojFat		:= ""
Local	cNomFat		:= ""
Local	cPvProjet	:= ""
Local	cPvObra		:= ""
Local	cPvCliente	:= ""
Local	cPvCliAux	:= ""
Local   lLOC021F := EXISTBLOCK("LOCA021F")
Local   lLOC021G := EXISTBLOCK("LOCA021G")
Local   lLOC021H := EXISTBLOCK("LOCA021H")
Local   lLOC021I := EXISTBLOCK("LOCA021I")
Local   lLOC021J := EXISTBLOCK("LOCA021J")
Local   lLOC021K := EXISTBLOCK("LOCA021K")
Local   lLOC021L := EXISTBLOCK("LOCA021L")
Local   lLOC021M := EXISTBLOCK("LOCA021M")
Local   lLOC021N := EXISTBLOCK("LOCA021N")
Local   lLOC021O := EXISTBLOCK("LOCA021O")
Local   lLOC021P := EXISTBLOCK("LOCA021P") // Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
Local   lLOC021Q := EXISTBLOCK("LOCA021Q") // Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
Local   aComplex := {} // Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
Local   nX // Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022

// Selecao dos contratos
Private _ASZ1		:= {}
Private	ODLGFIL
Private OFILOS


Default _LSEMLCJ := .F.
Default CARQLOCK := ""

If !_lJob
	PRIVATE DPAR01      := IIF(Valtype(MV_PAR01) == 'D', MV_PAR01, StoD(Alltrim(MV_PAR01)))
	PRIVATE DPAR02      := IIF(Valtype(MV_PAR02) == 'D', MV_PAR02, StoD(Alltrim(MV_PAR02)))
	PRIVATE CPAR03      := MV_PAR03
	PRIVATE CPAR04      := MV_PAR04
	PRIVATE CPAR05      := MV_PAR05
	PRIVATE CPAR06      := MV_PAR06
	PRIVATE CPAR07      := MV_PAR07
	PRIVATE CPAR08      := MV_PAR08
	PRIVATE CPAR09      := MV_PAR09
	PRIVATE CPAR10      := MV_PAR10
	PRIVATE CPAR11      := MV_PAR11 								// 1 - LOCAÇÃO; 2 - CUSTOS EXTRAS; 3 - AMBOS
	If _lTem12
		PRIVATE CPAR12      := MV_PAR12
	EndIF
	If _lTem13
		PRIVATE CPAR13      := MV_PAR13
	EndIF
	If _lTem14
		PRIVATE CPAR14      := MV_PAR14
	EndIF
Else
	PRIVATE DPAR01      := ctod("01/01/2000")
	PRIVATE DPAR02      := ctod("31/12/5000")
	PRIVATE CPAR03      := space(TamSx3("A1_COD")[1])
	PRIVATE CPAR04      := replicate("Z",TamSx3("A1_COD")[1])
	PRIVATE CPAR05      := space(TamSx3("A1_LOJA")[1])
	PRIVATE CPAR06      := replicate("Z",TamSx3("A1_LOJA")[1])
	PRIVATE CPAR07      := space(TamSx3("T9_CODBEM")[1])
	PRIVATE CPAR08      := replicate("Z",TamSx3("T9_CODBEM")[1])
	PRIVATE CPAR09      := CPRJINI
	PRIVATE CPAR10      := CPRJFIM
	PRIVATE CPAR11      := nTipoF 
	If _lTem12
		PRIVATE CPAR12      := space(TamSx3("B1_COD")[1])
	EndIF
	If _lTem13
		PRIVATE CPAR13      := replicate("Z",TamSx3("B1_COD")[1])
	EndIF
	If _lTem14
		PRIVATE CPAR14      := 1
	EndIF
EndIf

PRIVATE _AASS       := {}
PRIVATE _ACABPV		:= {}
PRIVATE _AITENSPV	:= {}
PRIVATE APEDIDOS    := {}
PRIVATE LFATREM     := SUPERGETMV("MV_LOCX235",.F.,.T.)  		// FATURA
PRIVATE LCLIBLQ     := .F.
PRIVATE LMSERROAUTO	:= .F.
PRIVATE _LPRIMFAT   := .T.
PRIVATE _CNUMPED 	:= SPACE(6)
PRIVATE _NREG		:= 0
PRIVATE _NREGPR		:= 0
PRIVATE NVALLOC     := 0
PRIVATE NVALTOT     := 0
PRIVATE _NVLRFRETE	:= 0

IF !EMPTY(_CTES) 
	_CTESEST := POSICIONE("SF4" , 1 , XFILIAL("SF4")+_CTES , "F4_ESTOQUE") 
	RESTAREA(_AAREAOLD) 
	IF _CTESEST = "S" 
		IF !MSGYESNO(STR0020+_CTES+STR0021 , STR0017)  //"A TES ["###"], DEFINIDA NO PARÂMETRO 'MV_LOCX080', POSSUI MOVIMENTAÇÃO DE ESTOQUE E ESTA CONFIGURAÇÃO NÃO É RECOMENDADA, CONTINUA ASSIM MESMO ???"###"GPO - LCJLF001.PRW"
			RETURN .F.
		ENDIF 
	ENDIF 
ENDIF 

IF SBM->(FIELDPOS("BM_XACESS")) > 0
	CMV_LOCX014 := LOCA00189() 
ELSE
	CMV_LOCX014 := SUPERGETMV("MV_LOCX014" , .F. , "") 
ENDIF

SC5->( DBSETORDER(1) )
FP1->( DBSETORDER(1) )

IF CPAR11 == 1 .OR. CPAR11 == 3 								// 1 - LOCAÇÃO / 3 - AMBOS

	// --> QUERY PRA IDENTIFICAR SE TEM ZAG SEM NOTA FISCAL DE REMESSA
	IF LFATREM
		IF SELECT("TMPFPA") > 0
			TMPFPA->( DBCLOSEAREA() )
		ENDIF
		_CQUERY := " SELECT FPA_PROJET , FPA_GRUA , FPA_AS "
		_CQUERY += " FROM "+RETSQLNAME("FPA")+ " ZAG (NOLOCK) "
		_CQUERY += " JOIN "+RETSQLNAME("FP0")+" ZA0 (NOLOCK) ON FP0_FILIAL='"+XFILIAL("FP0")+"' AND ZA0.D_E_L_E_T_ = '' AND FP0_PROJET = FPA_PROJET "
		_cQuery += " AND  ZA0.FP0_CLI  BETWEEN '"+ CPAR03 +"' AND '"+ CPAR04 +"' "
		_CQUERY += " AND  ZA0.FP0_LOJA  BETWEEN '"+ CPAR05 +"' AND '"+ CPAR06 +"' "

		_CQUERY += " WHERE  FPA_FILIAL  = '"+XFILIAL("FPA")+"' "
		_CQUERY += "   AND  FPA_PROJET BETWEEN '"+ CPAR09 +"' AND '"+ CPAR10 +"' "
		_CQUERY += "   AND  FPA_DTINI  >= '"+ DTOS(DPAR01) +"' "
		_CQUERY += "   AND (FPA_DTFIM  <> '' OR FPA_DTFIM <= '"+ DTOS(DPAR02) +"') "
		_CQUERY += "   AND  FPA_GRUA   BETWEEN '"+ CPAR07 +"' AND '"+ CPAR08 +"' "
		_CQUERY += "   AND  FPA_NFREM   = ' ' "
		_CQUERY += "   AND  FPA_TIPOSE  = 'L' "

		If _lTem12 .and. _lTem13
			_CQUERY += "   AND  FPA_PRODUT BETWEEN '"+ CPAR12 +"' AND '"+ CPAR13 +"' "
		EndIf
		_CQUERY += "   AND  FPA_GRUA BETWEEN '"+ CPAR07 +"' AND '"+ CPAR08 +"' "


		_CQUERY += "   AND  ZAG.D_E_L_E_T_ = '' "
		_CQUERY := CHANGEQUERY(_CQUERY) 
		//CONOUT("[LCJLF001.PRW] # _CQUERY(1): " + _CQUERY)  

		DBUSEAREA( .T., "TOPCONN", TCGENQRY(,,_CQUERY), "TMPFPA", .F., .T.)
	
		/* Removido por Frank em 14/12/21 chamado 27627
		IF LOBRNFREM 			// --> MV_LOCX067 - OBRIGA OU NAO UMA NOTA FISCAL DE REMESSA PARA GERACAO DA NOTA DE FATURAMENTO AUTOMATICO.            PADRÃO: .T. 
			IF !EMPTY(TMPFPA->FPA_PROJET)
				WHILE !TMPFPA->(EOF())
					CAVISO += SUPERGETMV("MV_LOCX248",.F.,STR0009) + ": "+ALLTRIM(TMPFPA->FPA_PROJET)+STR0023+ALLTRIM(TMPFPA->FPA_GRUA)+STR0024+ALLTRIM(TMPFPA->FPA_AS) + CRLF  //"PROJETO"###" EQUIPAMENTO: "###" AS: "
					TMPFPA->(DBSKIP())
				ENDDO
				MSGALERT(STR0025+SPACE(8)+CAVISO + CHR(13)+CHR(10) + ;  //"NÃO FORAM ENCONTRADOS NOTAS FISCAIS DE REMESSA PARA OS SEGUINTES ITENS: "
				         STR0026 , STR0017) //"CASO DESEJE GERAR O FATURAMENTO SEM A REMESSA, VERIFIQUE O PARÂMETRO 'MV_LOCX067'."###"GPO - LCJLF001.PRW"
				RETURN .F.
			ENDIF
		ENDIF 
		*/

	ENDIF

	IF SELECT("TMP") > 0
		TMP->( DBCLOSEAREA() )
	ENDIF
	_CQUERY     := " SELECT ZAG.R_E_C_N_O_ ZAGRECNO, FP1.R_E_C_N_O_ FP1RECNO, ZA0.R_E_C_N_O_ ZA0RECNO, SB1.R_E_C_N_O_ SB1RECNO, SA1.R_E_C_N_O_ SA1RECNO, ISNULL(ST9.R_E_C_N_O_,0) ST9RECNO, FPA_PROJET "
	_CQUERY     += " FROM "+RETSQLNAME("FPA")+" ZAG (NOLOCK) "
	_CQUERY     +=        "       JOIN "+RETSQLNAME("SB1")+" SB1 (NOLOCK) ON B1_FILIAL ='"+XFILIAL("SB1")+"' AND SB1.D_E_L_E_T_ = '' AND B1_COD = FPA_PRODUT "
	_CQUERY     +=        " LEFT  JOIN "+RETSQLNAME("ST9")+" ST9 (NOLOCK) ON T9_FILIAL ='"+XFILIAL("ST9")+"' AND ST9.D_E_L_E_T_ = '' AND T9_CODBEM = FPA_GRUA "
	_CQUERY     +=        "       JOIN "+RETSQLNAME("FP0")+" ZA0 (NOLOCK) ON FP0_FILIAL='"+XFILIAL("FP0")+"' AND ZA0.D_E_L_E_T_ = '' AND FP0_PROJET = FPA_PROJET "
	_CQUERY     +=        "       JOIN "+RETSQLNAME("FP1")+" FP1 (NOLOCK) ON FP1_FILIAL='"+XFILIAL("FP1")+"' AND FP1.D_E_L_E_T_  = ' ' AND FP1_PROJET = FPA_PROJET AND FP1_OBRA = FPA_OBRA "
	_CQUERY     +=        "       JOIN "+RETSQLNAME("SA1")+" SA1 (NOLOCK) ON A1_FILIAL ='"+XFILIAL("SA1")+"' AND SA1.D_E_L_E_T_ <> '*' AND A1_COD = FP0_CLI AND A1_LOJA = FP0_LOJA "
	_CQUERY     +=        " INNER JOIN "+RETSQLNAME("FQ5")+" DTQ (NOLOCK) ON FQ5_FILIAL='"+XFILIAL("FQ5")+"' AND DTQ.D_E_L_E_T_ <> '*' AND FQ5_FILORI = FPA_FILIAL AND FQ5_VIAGEM = FPA_VIAGEM AND FQ5_AS = FPA_AS AND FQ5_STATUS = '6' "
	_CQUERY     += " WHERE  FPA_FILIAL = '"+XFILIAL("FPA")+"' "
	_CQUERY     += "   AND  FPA_DTFIM <> ' '"
	_CQUERY     += "   AND  FPA_DTFIM BETWEEN '"+ DTOS(DPAR01) +"' AND '"+ DTOS(DPAR02) +"'"
	IF ! LFATAND
		_CQUERY += "   AND (FPA_DNFRET = ' ' OR FPA_DNFRET >= '"+ DTOS(DPAR01) +"')"
	ENDIF
	_CQUERY     += "   AND ((FPA_ULTFAT < '"+ DTOS(DPAR02) +"' AND (FPA_ULTFAT <= FPA_DTSCRT OR FPA_DTSCRT = '')) OR FPA_ULTFAT = ' ')"
	IF LFATREM 
	  IF LOBRNFREM  			// --> MV_LOCX067 - OBRIGA OU NAO UMA NOTA FISCAL DE REMESSA PARA GERACAO DA NOTA DE FATURAMENTO AUTOMATICO.            PADRÃO: .T. 
		_CQUERY += "   AND ( FPA_AS IN (SELECT B.C6_XAS FROM "+RETSQLNAME("SC6")+" B WHERE B.C6_FILIAL = '"+xFilial("SC6")+"' AND B.C6_XAS = FPA_AS AND B.D_E_L_E_T_ = '') OR FPA_TIPOSE <> 'L')" 
	  ENDIF 
	ENDIF 
	IF FPA->(FIELDPOS("FPA_PDESC")) > 0
		_CQUERY += "   AND  FPA_PDESC < 100"
	ENDIF
	_CQUERY     += "   AND  A1_COD     BETWEEN '"+ CPAR03 +"' AND '"+ CPAR04 +"' "
	_CQUERY     += "   AND  A1_LOJA    BETWEEN '"+ CPAR05 +"' AND '"+ CPAR06 +"' "
	_CQUERY     += "   AND (FPA_TIPOSE <> 'L' OR FPA_GRUA BETWEEN '"+ CPAR07 +"' AND '"+ CPAR08 +"') "
	_CQUERY     += "   AND  FPA_PROJET BETWEEN '"+ CPAR09 +"' AND '"+ CPAR10 +"' "

	// Novos filtros do produto e acerto do funcionamento do filtro dos bens - Frank em 08/09/21
	If _lTem12 .and. _lTem13
		_CQUERY     += "   AND  FPA_PRODUT BETWEEN '"+ CPAR12 +"' AND '"+ CPAR13 +"' "
	EndIF
	_CQUERY     += "   AND  FPA_GRUA BETWEEN '"+ CPAR07 +"' AND '"+ CPAR08 +"' "

	IF LFATLOC 
		_CQUERY += "   AND  FPA_TIPOSE = 'L' " + CRLF
	ELSE
		_CQUERY += "   AND  FPA_TIPOSE IN ('L','M','Z','O') " + CRLF
	ENDIF
	IF EXISTBLOCK("LCJLFQRY") 									// --> PONTO DE ENTRADA PARA ALTERAÇÃO/INCLUSÃO DE CONDIÇÕES DA QUERY PARA FATURAMENTO AUTOMÁTICO
		_CQUERY := EXECBLOCK("LCJLFQRY" , .T. , .T. , {_CQUERY}) 
	ENDIF
	IF LEN(APRJAS) > 0
		FOR _NX := 1 TO LEN(APRJAS) 
			IF EMPTY(_CASS)
				_CASS := "'"   + APRJAS[_NX]
			ELSE
				_CASS += "','" + APRJAS[_NX]
			ENDIF
			IF _NX == LEN(APRJAS)
				_CASS += "'"
			ENDIF
		NEXT _NX 
		_CQUERY += "   AND  FPA_AS IN ("+_CASS+") " + CRLF
	ENDIF
	_CQUERY     += "   AND  ZAG.D_E_L_E_T_ = '' " 
	If FPA->(ColumnPos("FPA_CLIFAT")) > 0
		_CQUERY     += " ORDER BY 	FPA_PROJET, FPA_OBRA,  " 
		_CQUERY     += " 			FPA_CLIFAT DESC , FPA_LOJFAT, FPA_AS "  // ORDENADO POR CLIENTE para facilitar a quebra posterior do PV
	Else
		_CQUERY     += " ORDER BY FPA_PROJET , FPA_AS " 
	EndIf
	_CQUERY     := CHANGEQUERY(_CQUERY) 

	DBUSEAREA(.T. , "TOPCONN" , TCGENQRY(,,_CQUERY) , "TMP" , .F. , .T.) 
	
	COUNT TO NTOTREC 
	
	DBSELECTAREA("TMP")
	DBGOTOP()

	// Tela para seleção dos registros Frank em 27/10/21
	If !_lJob .and. _lTem14 // se não for job e existe o pergunte da selecao
		If cPar14 == 2 // Se optou por selecionar os contratos para faturamento
			If cPar11 <> 3 // Se optou por locação, ou custo extra (não é válido ambos para a selecao)
				// Selecionar os contratos
				_ASZ1 := {}
				While !TMP->(Eof())
					FPA->( DBGOTO(TMP->ZAGRECNO) )
					FP1->( DBGOTO(TMP->FP1RECNO) )
					SA1->( DBGOTO(TMP->SA1RECNO) )

					//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
					If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT)
						cCliFat := FPA->FPA_CLIFAT
						cLojFat := FPA->FPA_LOJFAT
						cNomFat := alltrim(FPA->FPA_NOMFAT)
					ElseIf !Empty(FP1->FP1_CLIDES)
						cCliFat := FP1->FP1_CLIDES
						cLojFat := FP1->FP1_LOJDES
						cNomFat := alltrim(FP1->FP1_NOMDES)
					Else
						cCliFat := SA1->A1_COD
						cLojFat := SA1->A1_LOJA
						cNomFat := alltrim(SA1->A1_NOME)
					EndIf
					SB1->(dbSetorder(1))
					SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))
					If FPA->FPA_TIPOSE == "Z" .and. !empty(FPA->FPA_ULTFAT)
						TMP->(dbSkip())
						Loop
					EndIF
					aadd(_ASZ1,{.T.,FPA->FPA_PROJET,FPA->FPA_OBRA, FPA->FPA_AS, FPA->FPA_PRODUT, SB1->B1_DESC, TMP->ZAGRECNO, cCliFat, cLojFat, cNomFat})

					// Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
					IF lLOC021P
						aCompleX := EXECBLOCK("LOCA021P" , .T. , .T. , {1} ) 
						If len(aComplex) > 0
							For nX := 1 to len(aComplex[1])
								aadd(_aSZ1[len(_ASZ1)],aComplex[1,nX])
							Next
						EndIF
					ENDIF 
		
					TMP->(dbSkip())
				EndDo

				If len(_aSZ1) == 0
					MsgAlert(STR0085,STR0007) // Não houve registro para a selecao###Atencao
					Return .F.
				EndIF
				
				cOpcx := "0"
				_aSelecao := {}
				DEFINE MSDIALOG ODLGFIL TITLE STR0076 FROM 010,005 TO NJANELAA,NJANELAL PIXEL//Seleção dos projetos
	    		@ 0.5,0.7 LISTBOX OFILOS FIELDS HEADER  " ",STR0077,STR0078,STR0079,STR0080,STR0081,STR0086,STR0087,STR0088 SIZE NLBTAML,NLBTAMA ON DBLCLICK (MARCARREGI(.F.)) //Projeto, Obra, AS, Cod.Produto, Descricao, "Cod.Cliente","Loja","Nome"
				// Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
				IF lLOC021Q
					aCompleX := EXECBLOCK("LOCA021Q" , .T. , .T. , {1} ) 
					If len(aComplex) > 0
						For nX := 1 to len(aComplex[1])
							aadd(OFILOS:aHeaders,aComplex[1,nX])
						Next
					EndIF
				ENDIF 
	    		OFILOS:SETARRAY(_ASZ1)

				cLinha := "{|| { IF( _ASZ1[OFILOS:NAT,1],OOK,ONO),"
				cLinha += "_ASZ1[OFILOS:NAT,2],"
				cLinha += "_ASZ1[OFILOS:NAT,3],"
				cLinha += "_ASZ1[OFILOS:NAT,4],"
				cLinha += "_ASZ1[OFILOS:NAT,5],"
				cLinha += "_ASZ1[OFILOS:NAT,6],"
				cLinha += "_ASZ1[OFILOS:NAT,8],"
				cLinha += "_ASZ1[OFILOS:NAT,9],"
				cLinha += "_ASZ1[OFILOS:NAT,10]"
				// Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
				IF lLOC021Q
					aCompleX := EXECBLOCK("LOCA021Q" , .T. , .T. , {1} ) 
					If len(aComplex) > 0
						For nX := 1 to len(aComplex[1])
							cLinha += ",_ASZ1[OFILOS:NAT,"+alltrim(str(10+nX))+"]"
						Next
					EndIF
				ENDIF 
				cLinha += "}}"

				OFILOS:BLINE := &(cLinha)

				@ 172,007 BUTTON   OMARKBUT PROMPT STR0089           SIZE 55,12 OF ODLGFIL PIXEL ACTION (MARCARREGI(.T.)) //"(Des)marcar todos"  
				@ 172,062 BUTTON OFILBUT PROMPT STR0082 SIZE 55,12 OF ODLGFIL PIXEL ;  //"GERA FATURAMENTO"
		                 ACTION ( IIF(MSGYESNO(OEMTOANSI(STR0083) , STR0007) , ;  //"Confirma a geracao do faturamento?"###"Atencao"
		                              cOpcx := "1"  , ; 
		                              cOpcx := "0") , ; 
		                         ODLGFIL:END() ) 
	    		@ 172,117 BUTTON   OCANBUT PROMPT STR0084             SIZE 55,12 OF ODLGFIL PIXEL ACTION (cOpcx := "0", ODLGFIL:END()) //"CANCELAR"
    			ACTIVATE MSDIALOG ODLGFIL CENTERED
				
				// Validar se selecionou pelo menos um contrato
				If cOpcx == "0"
					Return .F.
				Else
					For _nX := 1 to len(_aSZ1)
						If _aSZ1[_nX,1]
							aadd(_aSelecao,{_aSZ1[_nX][7]})
						EndIF
					Next
				EndIF
				If len(_aSelecao) == 0
					Return .F.
				EndIF
				
			Else
				MsgAlert(STR0075,STR0017) //A opção ambos não permite a seleção dos contratos.###Rental
				Return .F.
			EndIF
		EndIf
	EndIF


	DBSELECTAREA("TMP")
	DBGOTOP()

	
	WHILE TMP->( !EOF() )

		If !_lJob .and. _lTem14 // se não for job e existe o pergunte da selecao
			If cPar14 == 2 // Se optou por selecionar os contratos para faturamento
				If cPar11 <> 3 // Se optou por locação, ou custo extra (não é válido ambos para a selecao)
					_lSelecao := .F.
					If len(_aSelecao) > 0
						For _nX:=1 to len(_aSelecao)
							If _aSelecao[_nX][1] == TMP->ZAGRECNO
								_lSelecao := .T.
								Exit
							EndIF
						Next
					EndIF
					If !_lSelecao
						TMP->(dbSkip())
						Loop
					EndIF
				EndIF
			EndIF
		EndIF
	
		FPA->( DBGOTO(TMP->ZAGRECNO) )
		FP1->( DBGOTO(TMP->FP1RECNO) )
		FP0->( DBGOTO(TMP->ZA0RECNO) )
		SA1->( DBGOTO(TMP->SA1RECNO) )
	
		NSA1RECNO := TMP->SA1RECNO
	
		//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
		If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT)
			cPvCliente := FPA->FPA_CLIFAT + FPA->FPA_LOJFAT
		ElseIf !Empty(FP1->FP1_CLIDES)
			cPvCliente := FP1->FP1_CLIDES + FP1->FP1_LOJDES
		Else
			cPvCliente := FP0->FP0_CLI + FP0->FP0_LOJA 
		EndIf

		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1") + cPvCliente))
		Else
			Help(NIL, NIL, "LOCA021_1", NIL, "Cliente não localizado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe um cliente válido no Projeto " + AllTrim(FPA->FPA_PROJET) + " | Obra: " + FPA->FPA_OBRA + " | Seq: " + FPA->FPA_SEQGRU})
			Return .F.
		EndIf
	
		IF _CLIBLOQ
			IF U_CLIBLOQ(FP0->FP0_CLI , FP0->FP0_LOJA , .T. /*EXIBE MSG?*/)
				TMP->( DBSKIP() )
				LOOP
			ENDIF
		ENDIF
	
		//FP1->( DBSEEK(XFILIAL("FP1")+FPA->FPA_PROJET+FPA->FPA_OBRA) ) 
	
		LCLIBLQ := ( SA1->A1_MSBLQL == "1" ) 
	
		IF LCLIBLQ
			IF RECLOCK("SA1", .F.)
				SA1->A1_MSBLQL := "2"
				SA1->(MSUNLOCK())
			ENDIF
		ENDIF
	
		_ADADOS	   := {}
		_AITENSPV  := {}
		NITENS	   := ""
		_NVLRFRETE := 0
		_NVLRSEG   := 0
		NPESO      := 0
		If lGeraPVx
			_CNUMPED := GETSXENUM("SC5","C5_NUM") 
		Else
			_CNUMPED := ""
		EndIF
		WHILE .T. .and. lGeraPVx
			IF SC5->( DBSEEK(XFILIAL("SC5")+_CNUMPED) )
				CONFIRMSX8()
				_CNUMPED := GETSXENUM("SC5","C5_NUM")
				LOOP
			ELSE
				EXIT
			ENDIF
		ENDDO
		
	
		_AASS      := {}
		_CPROJET   := FPA->FPA_PROJET
		//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
		cPvProjet 	:= TMP->FPA_PROJET
		cPvObra 	:= FP1->FP1_OBRA
		cPvCliAux	:= cPvCliente
	
		_lDescCus := .F. // controle dos descontos por custo extra - Frank 15/02/21 / Frank 19/11/21
		_aDescCus := {}

		//realiza quebra dos itens
		//WHILE TMP->( !EOF() ) .AND. _CPROJET == TMP->FPA_PROJET 
		//nova forma de quebra a partir de SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
		//QUEBRA PEDIDO POR PROJETO / OBRA / CLIENTE
		WHILE TMP->( !EOF() ) .AND. cPvProjet == TMP->FPA_PROJET .And. cPvObra == FP1->FP1_OBRA .And. cPvCliente == cPvCliAux

			FPA->( DBGOTO( TMP->ZAGRECNO ) )
			FP1->( DBGOTO( TMP->FP1RECNO ) )

			If !_lJob .and. _lTem14 // se não for job e existe o pergunte da selecao
				If cPar14 == 2 // Se optou por selecionar os contratos para faturamento
					If cPar11 <> 3 // Se optou por locação, ou custo extra (não é válido ambos para a selecao)
						_lSelecao := .F.
						If len(_aSelecao) > 0
							For _nX:=1 to len(_aSelecao)
								If _aSelecao[_nX][1] == TMP->ZAGRECNO
									_lSelecao := .T.
									Exit
								EndIF
							Next
						EndIF

						nForca := 0
						IF lLOC021F
							nForca := EXECBLOCK("LOCA021F" , .T. , .T. , {} ) 
						ENDIF 

						If !_lSelecao .or. nForca > 0
							TMP->(dbSkip())
							//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
							If TMP->( !EOF() )
								FPA->( DBGOTO( TMP->ZAGRECNO ) )
								FP1->( DBGOTO( TMP->FP1RECNO ) )
								//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
								If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT) .or. nForca == 1
									cPvCliAux := FPA->FPA_CLIFAT + FPA->FPA_LOJFAT
								ElseIf !Empty(FP1->FP1_CLIDES)  .or. nForca == 2
									cPvCliAux := FP1->FP1_CLIDES + FP1->FP1_LOJDES
								Else
									cPvCliAux := FP0->FP0_CLI + FP0->FP0_LOJA 
								EndIf
							EndIf
							Loop
						EndIF
					EndIF
				EndIF
			EndIF



				SB1->( DBGOTO( TMP->SB1RECNO ) )
				ST9->( DBGOTO( TMP->ST9RECNO ) )
					_CAS		:= FPA->FPA_AS 
					_LPRIMFAT   := PRIMFAT(_CAS) 
	
					nForca := 0
					IF lLOC021G
						nForca := EXECBLOCK("LOCA021G" , .T. , .T. , {} ) 
					ENDIF 

					IF !_LPRIMFAT .AND. ALLTRIM(FPA->FPA_TIPOSE) $ "Z#O" .or. nForca > 0
						TMP->(DBSKIP()) 
						//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
						If TMP->( !EOF() ) .or. nForca > 0
							FPA->( DBGOTO( TMP->ZAGRECNO ) )
							FP1->( DBGOTO( TMP->FP1RECNO ) )
							//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
							If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT) .or. nForca == 1
								cPvCliAux := FPA->FPA_CLIFAT + FPA->FPA_LOJFAT
							ElseIf !Empty(FP1->FP1_CLIDES) .or. nForca == 2
								cPvCliAux := FP1->FP1_CLIDES + FP1->FP1_LOJDES
							Else
								cPvCliAux := FP0->FP0_CLI + FP0->FP0_LOJA 
							EndIf
						EndIf
						LOOP 
					ENDIF 
	
					IF _LCJLFINI //EXISTBLOCK("LCJLFINI") 
						EXECBLOCK("LCJLFINI" , .T. , .T. , NIL) 
					ENDIF 
	
					_DDTINI := STOD("") 
					_DDTFIM := STOD("") 
	
					DO CASE
					CASE FPA->FPA_TPBASE == "M"
						NDIASTRB := 30
					CASE FPA->FPA_TPBASE == "Q"
						NDIASTRB := 15
					CASE FPA->FPA_TPBASE == "S"
						NDIASTRB :=  7
					OTHERWISE
						DO CASE
						CASE FPA->( FIELDPOS("FPA_LOCDIA") ) > 0 
							NDIASTRB := FPA->FPA_LOCDIA 
						CASE FPA->( FIELDPOS("FPA_PREDIA") ) > 0 
							NDIASTRB := FPA->FPA_PREDIA 
						OTHERWISE
							NDIASTRB := FPA->FPA_DTENRE - FPA->FPA_DTINI + 1 
						ENDCASE
					ENDCASE
	
				//	FP1_TPMES --- "0" = FECHADO  E  "1" = ABERTO 
	
					NVALLOC := (FPA->FPA_VRHOR/NDIASTRB) 		// TRANSFORMA O VALOR MENSAL EM VALOR DIÁRIO DA LOCAÇÃO CONSIDERANDO O PADRÃO DE 30 DIAS
	
					IF EMPTY(FPA->FPA_ULTFAT) 					// PRIMEIRO FATURAMENTO CONSIDERANDO DATA INICIAL FPA_DTINI E PRÓXIMO FATURAMENTO FPA_DTFIM

						DO CASE
						CASE (FPA->FPA_DTFIM - FPA->FPA_DTINI) > 30  .AND.  FP1->FP1_TPMES == "1"  .AND.  EMPTY(FPA->FPA_DTSCRT) 
							DO CASE
							CASE SUBSTR(DTOS(LASTDAY(FPA->FPA_DTINI)),7,2) == "31" 		// CASO O MES TENHA O DIA 31 ADICIONA O PROPORCIONAL A UM DIA
								NVALLOC := (FPA->FPA_VRHOR + NVALLOC)
							CASE MONTH(FPA->FPA_DTINI) == 2 							// CASO SEJA FEVEREIRO SERA RETIRADO DO VALOR DE LOCAÇÃO OS DIAS A MENOS DO MES
								NVALLOC := (FPA->FPA_VRHOR - (NVALLOC * ( NDIASTRB - VAL( SUBSTR(DTOS(LASTDAY(FPA->FPA_DTINI)),7,2) ) )))
							ENDCASE
							NVALLOC := (NVALLOC/(FPA->FPA_DTFIM - FPA->FPA_DTINI))
							_DDTINI := FPA->FPA_DTINI 
							_DDTFIM := FPA->FPA_DTFIM 
						CASE (FPA->FPA_DTFIM - FPA->FPA_DTINI) > 30  .AND.  FP1->FP1_TPMES == "1"  .AND. !EMPTY(FPA->FPA_DTSCRT) 
							DO CASE
							CASE SUBSTR(DTOS(LASTDAY(FPA->FPA_DTINI)),7,2) == "31" 		// CASO O MES TENHA O DIA 31 ADICIONA O PROPORCIONAL A UM DIA
								NVALLOC := (FPA->FPA_VRHOR + NVALLOC)
							CASE MONTH(FPA->FPA_DTINI) == 2 							// CASO SEJA FEVEREIRO SERA RETIRADO DO VALOR DE LOCAÇÃO OS DIAS A MENOS DO MES
								NVALLOC := (FPA->FPA_VRHOR - (NVALLOC * ( NDIASTRB - VAL( SUBSTR(DTOS(LASTDAY(FPA->FPA_DTINI)),7,2) ) )))
							ENDCASE
							NVALLOC := (NVALLOC/(FPA->FPA_DTSCRT - FPA->FPA_DTINI))
							_DDTINI := FPA->FPA_DTINI 
							_DDTFIM := FPA->FPA_DTSCRT 
						CASE (FPA->FPA_DTFIM - FPA->FPA_DTINI) > 30  .AND.  FP1->FP1_TPMES == "0"  .AND.  EMPTY(FPA->FPA_DTSCRT)
							NVALLOC := FPA->FPA_VRHOR 			// (NVALLOC * (FPA->FPA_DTFIM - FPA->FPA_DTINI))
							_DDTINI := FPA->FPA_DTINI 
							_DDTFIM := FPA->FPA_DTFIM 
						CASE (FPA->FPA_DTFIM - FPA->FPA_DTINI) > 30  .AND.  FP1->FP1_TPMES == "0"  .AND. !EMPTY(FPA->FPA_DTSCRT)
							NVALLOC := (NVALLOC * (FPA->FPA_DTSCRT - FPA->FPA_DTINI))
							_DDTINI := FPA->FPA_DTINI 
							_DDTFIM := FPA->FPA_DTSCRT 
						CASE (FPA->FPA_DTFIM - FPA->FPA_DTINI) < 30  .AND. !EMPTY(FPA->FPA_DTSCRT) 
							NVALLOC := (NVALLOC * (FPA->FPA_DTSCRT - FPA->FPA_DTINI))
							_DDTINI := FPA->FPA_DTINI 
							_DDTFIM := FPA->FPA_DTSCRT 
						CASE (FPA->FPA_DTFIM - FPA->FPA_DTINI) < 30  .AND.  EMPTY(FPA->FPA_DTSCRT) 
							NVALLOC := FPA->FPA_VRHOR 			// (NVALLOC * (FPA->FPA_DTFIM - FPA->FPA_DTINI))
							_DDTINI := FPA->FPA_DTINI 
							_DDTFIM := FPA->FPA_DTFIM 
						OTHERWISE 
							NVALLOC := FPA->FPA_VRHOR 
						ENDCASE
						DPROXFAT := (FPA->FPA_DTFIM + NDIASTRB + 1) 
						DULTFAT	 := FPA->FPA_DTFIM 
						
					ELSE 										// SE TIVER DATA DE ULTIMO FATURAMENTO
	
						DO CASE
						CASE (FPA->FPA_DTFIM - FPA->FPA_ULTFAT) > 30  .AND.  FP1->FP1_TPMES == "1"  .AND.  EMPTY(FPA->FPA_DTSCRT) 
							DO CASE 
							CASE SUBSTR(DTOS(LASTDAY(FPA->FPA_ULTFAT)),7,2) == "31"		// CASO O MES TENHA O DIA 31 ADICIONA O PROPORCIONAL A UM DIA
								NVALLOC := (FPA->FPA_VRHOR + NVALLOC) 
							CASE MONTH(FPA->FPA_ULTFAT) == 2 							// CASO SEJA FEVEREIRO SERA RETIRADO DO VALOR DE LOCAÇÃO OS DIAS A MENOS DO MES
								NVALLOC := (FPA->FPA_VRHOR - (NVALLOC * ( NDIASTRB - VAL( SUBSTR(DTOS(LASTDAY(FPA->FPA_ULTFAT)),7,2) ) )))
							ENDCASE
							NVALLOC := (NVALLOC/(FPA->FPA_DTFIM - FPA->FPA_ULTFAT))
							_DDTINI := FPA->FPA_ULTFAT 
							_DDTFIM := FPA->FPA_DTFIM 
						CASE (FPA->FPA_DTFIM - FPA->FPA_ULTFAT) > 30  .AND.  FP1->FP1_TPMES == "1"  .AND. !EMPTY(FPA->FPA_DTSCRT)
							DO CASE
							CASE SUBSTR(DTOS(LASTDAY(FPA->FPA_ULTFAT)),7,2) == "31"		// CASO O MES TENHA O DIA 31 ADICIONA O PROPORCIONAL A UM DIA
								NVALLOC := (FPA->FPA_VRHOR + NVALLOC)
							CASE MONTH(FPA->FPA_ULTFAT) == 2 							// CASO SEJA FEVEREIRO SERA RETIRADO DO VALOR DE LOCAÇÃO OS DIAS A MENOS DO MES
								NVALLOC := (FPA->FPA_VRHOR - (NVALLOC * ( NDIASTRB - VAL( SUBSTR(DTOS(LASTDAY(FPA->FPA_ULTFAT)),7,2) ) )))
							ENDCASE
							NVALLOC := (NVALLOC/(FPA->FPA_DTSCRT - FPA->FPA_ULTFAT))
							_DDTINI := FPA->FPA_ULTFAT 
							_DDTFIM := FPA->FPA_DTSCRT 
						CASE (FPA->FPA_DTFIM - FPA->FPA_ULTFAT) > 30  .AND.  FP1->FP1_TPMES == "0"  .AND.  EMPTY(FPA->FPA_DTSCRT)
							NVALLOC := FPA->FPA_VRHOR 			// (NVALLOC * (FPA->FPA_DTFIM - FPA->FPA_DTINI))
							_DDTINI := FPA->FPA_ULTFAT 
							_DDTFIM := FPA->FPA_DTFIM 
						CASE (FPA->FPA_DTFIM - FPA->FPA_ULTFAT) > 30  .AND.  FP1->FP1_TPMES == "0"  .AND. !EMPTY(FPA->FPA_DTSCRT) 
							NVALLOC := (FPA->FPA_VRHOR/(FPA->FPA_DTSCRT - FPA->FPA_ULTFAT))
							_DDTINI := FPA->FPA_ULTFAT 
							_DDTFIM := FPA->FPA_DTSCRT 
						CASE (FPA->FPA_DTFIM - FPA->FPA_ULTFAT) < 30  .AND. !EMPTY(FPA->FPA_DTSCRT)
							NVALLOC := (FPA->FPA_VRHOR/(FPA->FPA_DTSCRT - FPA->FPA_ULTFAT))
							_DDTINI := FPA->FPA_ULTFAT 
							_DDTFIM := FPA->FPA_DTSCRT 
						CASE (FPA->FPA_DTFIM - FPA->FPA_ULTFAT) < 30  .AND.  EMPTY(FPA->FPA_DTSCRT)
							NVALLOC := FPA->FPA_VRHOR 			// (NVALLOC * (FPA->FPA_DTFIM - FPA->FPA_ULTFAT)) 
							_DDTINI := FPA->FPA_ULTFAT 
							_DDTFIM := FPA->FPA_DTFIM  
						OTHERWISE
							NVALLOC := FPA->FPA_VRHOR
						ENDCASE
						DPROXFAT := (FPA->FPA_DTFIM + NDIASTRB + 1) 
						DULTFAT	 := FPA->FPA_DTFIM 

					ENDIF
	
					IF EMPTY(FPA->FPA_ULTFAT)
						_DDTINI := FPA->FPA_DTINI
					ELSE
						_DDTINI := FPA->FPA_ULTFAT + 1
					ENDIF

					NVALLOC := FPA->FPA_VRHOR 
	
					IF FPA->FPA_TIPOSE $ "Z#O"
						_DDTINI  := FPA->FPA_DTINI 
						_DDTFIM  := FPA->FPA_DTENRE 
						DPROXFAT := FPA->FPA_DTFIM 
						DULTFAT  := FPA->FPA_DTFIM 
						NVALLOC  := FPA->FPA_VRHOR 
					ELSE
						IF FP1->FP1_TPMES == "0"				// MES FECHADO
							NDIASTRB := 30 // quantidade de dias do mês fechado que foi usado
							_nDiasX  := 30 // quantidade de dias do fator do periodo

							IF _LOCA021C //EXISTBLOCK("LOCA021C") // ponto de entrada para alteracao dos dias fixos = 30
								NDIASTRB := EXECBLOCK("LOCA021C" , .T. , .T. ) 
								_nDiasX  := EXECBLOCK("LOCA021C" , .T. , .T. ) 
							ENDIF

							_DDTFIM  := FPA->FPA_DTFIM 
							DULTFAT  := _DDTFIM 
							DPROXFAT := MONTHSUM(DULTFAT,1) 
	
							// somente se o dia for 30 e proximo mes 31
							// se for 29 de janeiro validar o maior dia de fevereiro
							// frank em 20/07/22 - ajuste do ultimo dia do mes fechado
							If day(dProxFat) == 30 .or. (month(dUltfat) == 1 .and. day(dultfat) == 28)  .or. (month(dUltfat) == 2 .and. (day(dultfat) == 28.or.day(dultfat) == 29))
								nMes := month(dproxfat)
								while nMes == month(dproxfat)
									dProxFat ++
								EndDo
								dproxfat := dproxfat - 1
							EndIf

							// Frank em 20/07/22 - somente quando for segundo faturamento em diante
							// considerar os dias corretos para o calculo
							IF !EMPTY(FPA->FPA_ULTFAT)
								NDIASTRB := _DDTFIM - _DDTINI + 1
								NVALLOC := (NVALLOC * NDIASTRB) / _nDiasX
							EndIf

							IF EMPTY(FPA->FPA_ULTFAT) //.AND. ((_DDTFIM - _DDTINI) + 1) < _nDiasX   //DAY(_DDTINI) - 1 <> DAY(_DDTFIM)
								NDIASTRB := _DDTFIM - _DDTINI + 1 
								NVALLOC := (NVALLOC * NDIASTRB) / _nDiasX
							ENDIF
	
							IF !EMPTY(FPA->FPA_DTSCRT)
								IF FPA->FPA_DTSCRT < _DDTFIM
									NDIASTRB := _nDiasX - (_DDTFIM - FPA->FPA_DTSCRT)
									_DDTFIM  := FPA->FPA_DTSCRT
									IF NDIASTRB < _nDiasX
										NVALLOC := (NVALLOC * NDIASTRB) / _nDiasX
									ENDIF 
								ENDIF 
							ENDIF 
						ELSE
							IF EMPTY(FPA->FPA_DTSCRT)
								_DDTFIM := _DDTINI + NDIASTRB - 1
							ELSE
								IF _DDTINI + NDIASTRB - 1 < FPA->FPA_DTSCRT
									_DDTFIM := _DDTINI + NDIASTRB - 1
								ELSE
									_DDTFIM := FPA->FPA_DTSCRT
								ENDIF
							ENDIF
							DULTFAT  := _DDTFIM
							DPROXFAT := DULTFAT + NDIASTRB
							NVALLOC  := NVALLOC * (_DDTFIM - _DDTINI + 1) / NDIASTRB
						ENDIF
					ENDIF
	
					nForca := 0
					IF lLOC021H
						nForca := EXECBLOCK("LOCA021H" , .T. , .T. , {} ) 
					ENDIF 

					IF NDIASTRB < 0 .OR. _DDTINI > _DDTFIM .or. nForca > 0
						TMP->(DBSKIP())
						//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
						If TMP->( !EOF() )
							FPA->( DBGOTO( TMP->ZAGRECNO ) )
							FP1->( DBGOTO( TMP->FP1RECNO ) )
							//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
							If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT) .or. nForca == 1
								cPvCliAux := FPA->FPA_CLIFAT + FPA->FPA_LOJFAT
							ElseIf !Empty(FP1->FP1_CLIDES) .or. nForca == 2
								cPvCliAux := FP1->FP1_CLIDES + FP1->FP1_LOJDES
							Else
								cPvCliAux := FP0->FP0_CLI + FP0->FP0_LOJA 
							EndIf
						EndIf
						LOOP
					ENDIF
	
					_CPERLOC := DTOC(_DDTINI) + STR0027 + DTOC(_DDTFIM) //" A "

					IF _LOCA021D //EXISTBLOCK("LOCA021D")
						_cPerloc := EXECBLOCK("LOCA021D" , .T. , .T., {_CPERLOC} ) 
					ENDIF
	
					IF NVALLOC < 0 
						_CTES   := _MV_LOC253 //SUPERGETMV("MV_LOCX253",.T.,"515")
						NVALLOC := ROUND((NVALLOC * -1),2)
					ELSE
						NVALLOC := ROUND(NVALLOC,2)
					ENDIF

					NVLR_OKD := NVALLOC 
	
					IF SELECT("TRBSC6") > 0 
						TRBSC6->(DBCLOSEAREA()) 
					ENDIF 
					_CQUERY := " SELECT C5_EMISSAO , C6_NUM" + CRLF 
					_CQUERY += " FROM " + RETSQLNAME("SC6") + " SC6 (NOLOCK) " + CRLF 
					_CQUERY +=        " INNER JOIN " + RETSQLNAME("SC5") + " SC5 (NOLOCK) ON  C5_FILIAL = '" + XFILIAL("SC5") + "'" + CRLF 
					IF SC5->(FIELDPOS("C5_XTIPFAT")) > 0
						_CQUERY += " AND C5_NUM    = C6_NUM  AND  C5_XTIPFAT = 'P'" + CRLF 
					Else
						_CQUERY += " AND C5_NUM    = C6_NUM  " + CRLF 
					EndIF
					_CQUERY +=                                                          " AND SC5.D_E_L_E_T_ = ''" + CRLF 
					_CQUERY += " WHERE  C6_FILIAL = '" + XFILIAL("SC6") + "'"
					If SC6->(FIELDPOS("C6_XAS")) > 0 
						_CQUERY +=   " AND  C6_XAS    = '" + _CAS + "'"
					EndIF
					_CQUERY +=   " AND  C6_ENTREG BETWEEN '" + DTOS(DDATABASE-(NDIASTRB-2)) + "' AND '" + DTOS(DDATABASE+(NDIASTRB-2)) + "'"
					_CQUERY +=   " AND  C6_BLQ NOT IN ('R','S') "
					_CQUERY +=   " AND  SC6.D_E_L_E_T_ = '' "
					_CQUERY := CHANGEQUERY(_CQUERY) 

					TCQUERY _CQUERY NEW ALIAS "TRBSC6" 
	
					_LPASSA := .T. // FRANK 27/10/20 PARA QUESTAO DOS ITENS FILHOS, FICA APRESENTANDO A MENSAGEM VARIAS VEZES

					IF TRBSC6->(!EOF()) .and. SC6->(FIELDPOS("C6_XAS")) > 0 
					
						IF EMPTY(FPA->FPA_SEQEST) // FRANK 27/10/20
							If lGeraPVx
								IF !MSGYESNO(STR0028 + _CAS + STR0029 + CRLF + CRLF + STR0030 , STR0017)  //"JÁ EXISTE UM FATURAMENTO GERADO PARA A AS "###" NESTE MESMO PERÍODO."###"DESEJA CONTINUAR?"###"GPO - LCJLF001.PRW"
									_LPASSA := .F.
								ENDIF
							Else
								_LPASSA := .T.
							EndIf
						ELSE
							IF _LMENS
								IF !MSGYESNO(STR0028 + _CAS + STR0029 + CRLF + CRLF + STR0030 , STR0017)  //"JÁ EXISTE UM FATURAMENTO GERADO PARA A AS "###" NESTE MESMO PERÍODO."###"DESEJA CONTINUAR?"###"GPO - LCJLF001.PRW"
									_LPASSA := .F.
								ENDIF
								_LMENS  := .F.
							ELSE
								_LPASSA := .T.
								_LMENS  := .F.
							ENDIF
						ENDIF

						IF !_LPASSA // FRANK 27/10/20

							IF !EMPTY(FPA->FPA_SEQEST)
								_LMENS := .F.
							ENDIF

							IF MSGYESNO(STR0031 , STR0017) //"DESEJA CANCELAR TODA A GERAÇÃO DE FATURAMENTO?"###"GPO - LCJLF001.PRW"
								TRBSC6->(DBCLOSEAREA()) 
								TMP->(DBCLOSEAREA()) 
								RETURN NIL 
							ELSE 
								TRBSC6->(DBCLOSEAREA()) 
								TMP->(DBSKIP()) 
								//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO

								nForca := 0
								IF lLOC021I
									nForca := EXECBLOCK("LOCA021I" , .T. , .T. , {} ) 
								ENDIF 

								If TMP->( !EOF() ) .or. nForca > 0
									FPA->( DBGOTO( TMP->ZAGRECNO ) )
									FP1->( DBGOTO( TMP->FP1RECNO ) )
									//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
									If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT) .or. nForca == 1
										cPvCliAux := FPA->FPA_CLIFAT + FPA->FPA_LOJFAT
									ElseIf !Empty(FP1->FP1_CLIDES) .or. nForca == 2
										cPvCliAux := FP1->FP1_CLIDES + FP1->FP1_LOJDES
									Else
										cPvCliAux := FP0->FP0_CLI + FP0->FP0_LOJA 
									EndIf
								EndIf
								LOOP 
							ENDIF 
						ENDIF 
					ENDIF 
	
					TRBSC6->(DBCLOSEAREA())
	
					/* Removido por Frank em 03/02/22 não faz sentido um calculo diferente
					IF ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CMV_LOCX014)  .AND.  ALLTRIM(FPA->FPA_TIPOSE) == "L" 
						NVALLOC := VALPRATA(FPA->FPA_AS , _DDTINI , _DDTFIM , FPA->FPA_QUANT , NVALLOC) 
						CONOUT("[LCJLF001.PRW] # NVALLOC (19A): "                  + TRANSFORM(NVALLOC ,"@E 999,999,999.99")) 
					ENDIF 
					*/
	
					IF ALLTRIM(FPA->FPA_TIPOSE) $ "Z#O"
						NVALLOC := FPA->FPA_VRHOR
					ENDIF 
		
					IF NVALLOC <> 0 
						IF  NVALLOC <> ROUND(NVALLOC/FPA->FPA_QUANT,SC6->(GETSX3CACHE("C6_PRCVEN","X3_DECIMAL"))) * FPA->FPA_QUANT 
							NVALLOC := ROUND(NVALLOC/FPA->FPA_QUANT,SC6->(GETSX3CACHE("C6_PRCVEN","X3_DECIMAL"))) * FPA->FPA_QUANT 
						ENDIF 
						NVALLOC := ROUND(NVALLOC,SC6->(GETSX3CACHE("C6_VALOR","X3_DECIMAL")))
	
						_AITEMTEMP := {}
						_CTES := _MV_LOC080 //GETMV("MV_LOCX080")
	
						IF _LCJTES //EXISTBLOCK("LCJTES") 				// --> PONTO DE ENTRADA PARA ALTERAÇÃO DA TES.
							_CTES := EXECBLOCK("LCJTES" , .T. , .T. , {_CTES}) 
						ENDIF
						NITENS := STRZERO( LEN(_AITENSPV)+1 ,TAMSX3("C6_ITEM")[1])

						AADD(_AITEMTEMP         , {"C6_NUM"     , _CNUMPED              , NIL})  // array 1
						AADD(_AITEMTEMP         , {"C6_FILIAL"  , XFILIAL("SC6")        , NIL})  // array 2
						AADD(_AITEMTEMP         , {"C6_ITEM"    , NITENS                , NIL})  // array 3
						AADD(_AITEMTEMP         , {"C6_PRODUTO"	, SB1->B1_COD           , NIL})  // array 4
						IF EMPTY(FPA->FPA_GRUA)
							AADD(_AITEMTEMP     , {"C6_DESCRI"  , ALLTRIM(SB1->B1_DESC)                                 , NIL})   // array 5
						ELSE
							AADD(_AITEMTEMP     , {"C6_DESCRI"  , ALLTRIM(SB1->B1_DESC)+" ("+ALLTRIM(FPA->FPA_GRUA)+")" , NIL})   // array 5
						ENDIF

						// Identificação do local padrão de estoque
						If empty(FPA->FPA_LOCAL) // não informado na locação o local de estoque
							// utilizar o default informado no cadastro de produtos
							_cLocaPad := SB1->B1_LOCPAD
						Else
							_cLocaPad := FPA->FPA_LOCAL
						EndIF
						AADD(_AITEMTEMP,{"C6_LOCAL"	,_cLocaPad       , Nil})   // array 6

						// Alterado por Frank para o tratamento do endereçamento
						// se não houver em estoque deixaremos como não liberado
						// 11/08/21
						_nQtdLib := FPA->FPA_QUANT
						_NQTD    := FPA->FPA_QUANT
						// Controle do endereçamento - Frank 11/08/2021
						// [ inicio - controle de endereçamento ]
						// https://tdn.totvs.com/display/public/PROT/PEST06504+-+Atividade+do+controle+de+numero+de+serie
						_cNumSer := FPA->FPA_GRUA

						IF SC6->(FIELDPOS("C6_FROTA")) > 0
							AADD(_AITEMTEMP,{"C6_FROTA"	,_cNumSer       , Nil})   // array 7
						ENDIF

						IF ALLTRIM(FPA->FPA_TIPOSE) $ "Z"
							SB1->(dbSetOrder(1))
							SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))
							
							If _MV_LOCALIZ == "S" .and. SB1->B1_LOCALIZ == "N" .and. !empty(_cNumSer)
								// Neste caso levaremos apenas para o SC6 o número de série da FPA.
								// Não precisa encontrar o endereçamento na SBF.
								//IF SC6->(FIELDPOS("C6_NUMSERI")) > 0 
								//	AADD(AITENS,{"C6_NUMSERI"	,_cNumSer       , XA1ORDEM("C6_NUMSERI"	)}) 
								//ENDIF
								IF SC6->(FIELDPOS("C6_FROTA")) > 0
									AADD(_AITEMTEMP,{"C6_FROTA"	,_cNumSer       , Nil}) 
								ENDIF
							ElseIf _MV_LOCALIZ == "S" .and. SB1->B1_LOCALIZ == "S" 
								If empty(_cNumSer)
									// Neste caso não foi informado o número de série
									// Então vamos encontrar o local de endereçamento na SBF pelo produto/local que tenha o saldo necessário e levar o
									// endereçamento para a SC6
									SBF->(dbSetOrder(2))
									If !SBF->(dbSeek(xFilial("SBF")+FPA->FPA_PRODUT+_cLocaPAd))
										// Não foi localizado na tabela de endereçamento o produto
										_nQtdLib := 0 // Não libera o pedido de vendas
									Else
										_cLocaEnd := ""
										// Tental localizar um endereço que atenda na totalidade a quantidade da FPA
										While !SBF->(Eof()) .and. SBF->BF_PRODUTO == FPA->FPA_PRODUT .and. SBF->BF_LOCAL == _cLocaPad
											If SBF->BF_QUANT - SBF->BF_EMPENHO >= _NQTD	
												_cLocaEnd := SBF->BF_LOCALIZ
												exit
											EndIF
											SBF->(dbSkip())
										EndDo
										If empty(_cLocaEnd)
											// Não foi localizado um endereço de estoque com a quantidade necessária para o produto
											_nQtdLib := 0 // Não libera o pedido de vendas
										EndIF
										AADD(_AITEMTEMP,{"C6_LOCALIZ"	,_cLocaEnd  , Nil}) 
									EndIF
								Else
									// Neste caso foi informado o número de série
									// Então vamos encontrar o local de endereçamento na SBF produto/local/NS que tenha o saldo necessário e levar
									// o endereçamento para a SC6
									// levar em consideração a mensagem de que existem saldos parciais que atendem o todo avisar e não deixar gerar o pv
									IF SC6->(FIELDPOS("C6_NUMSERI")) > 0 
										AADD(_AITEMTEMP,{"C6_NUMSERI"	,_cNumSer       , Nil}) 
									ENDIF
									IF SC6->(FIELDPOS("C6_FROTA")) > 0
										AADD(_AITEMTEMP,{"C6_FROTA"	,_cNumSer       , Nil}) 
									ENDIF
									SBF->(dbSetOrder(2))
									If !SBF->(dbSeek(xFilial("SBF")+FPA->FPA_PRODUT+_cLocaPAd))
										// "Não foi localizado na tabela de endereçamento o produto
										_nQtdLib := 0 // Não libera o pedido de vendas
									Else
										_cLocaEnd := ""
										// Tental localizar um endereço que atenda na totalidade a quantidade da FPA
										While !SBF->(Eof()) .and. SBF->BF_PRODUTO == FPA->FPA_PRODUT .and. SBF->BF_LOCAL == _cLocaPad
											If alltrim(SBF->BF_NUMSERI) == alltrim(_cNumSer)
												If SBF->BF_QUANT - SBF->BF_EMPENHO >= _NQTD	
													_cLocaEnd := SBF->BF_LOCALIZ
													exit
												EndIF
											EndIF
											SBF->(dbSkip())
										EndDo
										If empty(_cLocaEnd)
											_nTempSld := 0	
											_cMsgSld  := ""
											SBF->(dbSeek(xFilial("SBF")+FPA->FPA_PRODUT+_cLocaPAd))
											While !SBF->(Eof()) .and. SBF->BF_PRODUTO == FPA->FPA_PRODUT .and. SBF->BF_LOCAL == _cLocaPad
												If !empty(SBF->BF_NUMSERI)
													_nTempSld += (SBF->BF_QUANT - SBF->BF_EMPENHO)
													_cMsgSld  += alltrim(SBF->BF_NUMSERI)+" "
													If _nTempSld >= _NQTD	
														exit
													EndIF
												EndIF
												SBF->(dbSkip())
											EndDo
											If _nTempSld >= _NQTD	
												// "Os seguintes equipamentos precisam ser inseridos na aba locação
											Else
												// "Não existe saldo nos itens endereçados para esta quantidade.
											EndIF
											_nQtdLib := 0 // Não libera o pedido de vendas
										EndIF
										AADD(_AITEMTEMP,{"C6_LOCALIZ"	,_cLocaEnd  , Nil}) 
									EndIf
								EndIF
							ElseIf _MV_LOCALIZ == "N" .and. SB1->B1_LOCALIZ == "S" 
								// Neste caso independente de ser infomado o NS 
								// Vamos encontrar o local de endereçamento pelo produto/armazem na SBF que tenha o saldo necessário e levar o
								// endereçamento para a SC6
								// não levaremos o número de série para a sc6.

								SBF->(dbSetOrder(2))
								If !SBF->(dbSeek(xFilial("SBF")+FPA->FPA_PRODUT+_cLocaPAd))
									// Não foi localizado na tabela de endereçamento o produto
									_nQtdLib := 0 // Não libera o pedido de vendas
								Else
									_cLocaEnd := ""
									// Tental localizar um endereço que atenda na totalidade a quantidade da FPA
									While !SBF->(Eof()) .and. SBF->BF_PRODUTO == FPA->FPA_PRODUT .and. SBF->BF_LOCAL == _cLocaPad
										If SBF->BF_QUANT - SBF->BF_EMPENHO >= _NQTD	
											_cLocaEnd := SBF->BF_LOCALIZ
											exit
										EndIF
										SBF->(dbSkip())
									EndDo
									If empty(_cLocaEnd)
										// Não foi localizado um endereço de estoque com a quantidade necessária para o produto
										_nQtdLib := 0 // Não libera o pedido de vendas
									EndIF
									IF SC6->(FIELDPOS("C6_FROTA")) > 0
										AADD(_AITEMTEMP,{"C6_FROTA"	,_cNumSer       , Nil}) 
									ENDIF
									AADD(_AITEMTEMP,{"C6_LOCALIZ"	,_cLocaEnd  , Nil}) 
								EndIF
							EndIF
							If _MV_LOCALIZ == "N" .and. SB1->B1_LOCALIZ == "N"
								IF SC6->(FIELDPOS("C6_FROTA")) > 0
									AADD(_AITEMTEMP,{"C6_FROTA"	,_cNumSer       , Nil}) 
								ENDIF
							EndIF
						Else
							IF SC6->(FIELDPOS("C6_FROTA")) > 0
								AADD(_AITEMTEMP,{"C6_FROTA"	,_cNumSer       , Nil}) 
							ENDIF
						EndIF
						// Fim controle de enderecamento

						nForca := 0
						IF lLOC021J
							nForca := EXECBLOCK("LOCA021J" , .T. , .T. , {} ) 
						ENDIF 

						IF ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CMV_LOCX014) .or. nForca > 0
							IF FPA->(FIELDPOS("FPA_VRAND")) > 0 .or. nForca > 0
								IF FPA->FPA_VRAND > 0 .or. nForca > 0
									TMP->( DBSKIP() )
									//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
									If TMP->( !EOF() ) .or. nForca > 0
										FPA->( DBGOTO( TMP->ZAGRECNO ) )
										FP1->( DBGOTO( TMP->FP1RECNO ) )
										//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
										If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT) .or. nForca == 1
											cPvCliAux := FPA->FPA_CLIFAT + FPA->FPA_LOJFAT
										ElseIf !Empty(FP1->FP1_CLIDES) .or. nForca == 2
											cPvCliAux := FP1->FP1_CLIDES + FP1->FP1_LOJDES
										Else
											cPvCliAux := FP0->FP0_CLI + FP0->FP0_LOJA 
										EndIf
									EndIf
									LOOP
								ENDIF
								AADD(_AITEMTEMP , {"C6_QTDVEN"  , FPA->FPA_QUANT        , NIL})
								AADD(_AITEMTEMP , {"C6_QTDLIB"  , _nQtdLib        , NIL}) // controle de enderecamento frank 11/08/21
								AADD(_AITEMTEMP , {"C6_PRCVEN"  , NVALLOC               , NIL})
								AADD(_AITEMTEMP , {"C6_PRUNIT"  , NVALLOC               , NIL})
								AADD(_AITEMTEMP , {"C6_VALOR"   , NVALLOC               , NIL})
							ELSE
								AADD(_AITEMTEMP , {"C6_QTDVEN"  , FPA->FPA_QUANT        , NIL})
								AADD(_AITEMTEMP , {"C6_QTDLIB"  , _nQtdLib        , NIL}) // controle de enderecamento Frank 11/08/21
								AADD(_AITEMTEMP , {"C6_PRCVEN"  , ROUND(NVALLOC/FPA->FPA_QUANT,SC6->(GETSX3CACHE("C6_PRCVEN","X3_DECIMAL"))) , NIL})
								AADD(_AITEMTEMP , {"C6_PRUNIT"  , ROUND(NVALLOC/FPA->FPA_QUANT,SC6->(GETSX3CACHE("C6_PRUNIT","X3_DECIMAL"))) , NIL})
								AADD(_AITEMTEMP , {"C6_VALOR"   , NVALLOC               , NIL})
							ENDIF
						ELSE
							AADD(_AITEMTEMP     , {"C6_QTDVEN"  , 1                     , NIL})
							AADD(_AITEMTEMP     , {"C6_QTDLIB"  , _nQtdLib              , NIL}) // era 1 11/08/21 Frank controle de enderecamento
							AADD(_AITEMTEMP     , {"C6_PRCVEN"  , NVALLOC               , NIL})
							AADD(_AITEMTEMP     , {"C6_PRUNIT"  , NVALLOC               , NIL})
							AADD(_AITEMTEMP     , {"C6_VALOR"   , NVALLOC               , NIL})
						ENDIF

						If empty(FPA->FPA_TESFAT)
							AADD(_AITEMTEMP         , {"C6_TES"     , _CTES                 , NIL})
						Else
							AADD(_AITEMTEMP         , {"C6_TES"     , FPA->FPA_TESFAT       , NIL})
						EndIf

						IF SC6->(FIELDPOS("C6_XAS")) > 0
							AADD(_AITEMTEMP         , {"C6_XAS"     , FPA->FPA_AS           , NIL})
						EndIf
						IF SC6->(FIELDPOS("C6_XBEM")) > 0
							AADD(_AITEMTEMP         , {"C6_XBEM"    , FPA->FPA_GRUA         , NIL})
						EndIf
						// Removido a pedido do Lui - Frank em 06/07/21
						//AADD(_AITEMTEMP         , {"C6_NUMSERI"	, FPA->FPA_GRUA         , NIL})
						//IF SC6->(FIELDPOS("C6_FROTA")) > 0
						//	AADD(_AITEMTEMP     , {"C6_FROTA"      , FPA->FPA_GRUA        , NIL})
						//ENDIF
						IF SC6->(FIELDPOS("C6_CC")) > 0
							AADD(_AITEMTEMP     , {"C6_CC"      , FPA->FPA_CUSTO        , NIL})
						ENDIF
						IF SC6->(FIELDPOS("C6_XCCUSTO")) > 0 
							AADD(_AITEMTEMP     , {"C6_XCCUSTO" , FPA->FPA_CUSTO        , NIL})
						ENDIF

						IF SC6->(FIELDPOS("C6_XPERLOC")) > 0 
							AADD(_AITEMTEMP     , {"C6_XPERLOC" , _CPERLOC              , NIL})
						ENDIF
						IF SC6->(FIELDPOS("C6_CLVL")) > 0 .AND. _LCVAL
	   					   AADD(_AITEMTEMP      , {"C6_CLVL"    , FPA->FPA_AS           , NIL}) 
						ENDIF
						//IF FPA->(FIELDPOS("FPA_PDESC")) > 0 

							// rotina para validar se existem custos extras negativos para entrar como desconto.
							// Frank Z Fuga em 15/02/21
							//_lDescCus := .F.
							FPG->(dbSetOrder(1))
							FPG->(dbSeek(xFilial("FPG")+FPA->FPA_PROJET+FPA->FPA_AS))
							_nDescCus := 0
							While !FPG->(Eof()) .and. FPG->(FPG_FILIAL+FPG_PROJET+FPG_NRAS) == xFilial("FPG")+FPA->FPA_PROJET+FPA->FPA_AS
								If FPG->FPG_VALTOT < 0 .and. FPG->FPG_COBRA == "S" .and. FPG->FPG_STATUS == "1" .and. FPG->FPG_JUNTO == "S"
									If 	FPG->FPG_DTENT >= IIF(Valtype(MV_PAR01) == 'D', MV_PAR01, StoD(Alltrim(MV_PAR01))) .And. ;
										FPG->FPG_DTENT <= IIF(Valtype(MV_PAR02) == 'D', MV_PAR02, StoD(CVALTOCHAR(YEAR(DATE())+1)+"1231")) 
										If empty(FPG->FPG_PVNUM)
											aadd(_aDescCus,{FPG->(Recno()),FPG->FPG_VALTOT*-1,NITENS})
											_nDescCus += (FPG->FPG_VALTOT*-1)
											_lDescCus := .T.
										EndIf
									EndIF
								EndIF
								FPG->(dbSkip())
							EndDo


							IF FPA->FPA_PDESC > 0 .or. _nDescCus > 0

								// desconto := custo fixo negativo + percentual sobre o valor total 
								// _nDescX := _nDescCus + (FPA->FPA_VLBRUT * (FPA->FPA_PDESC/100)) // comentado por Frank em 09/07/21
								_nDescX := _nDescCus // ajustado por Frank em 09/07/21
								_nDescY += _nDescX
																
								//If FPA->FPA_VLBRUT == _nDescX // comentado por Frank em 09/07/21
								If FPA->FPA_VRHOR  == _nDescX // ajustado por Frank em 09/07/21
									// se o total de desconto for = ao valor do titulo 
									// _nDescX := FPA->FPA_VLBRUT - 0.01 // Forçar um valor positivo para a geração do PV // comentado por Frank em 09/07/21
									_nDescX := _nDescCus - 0.01 // ajustado por Frank em 09/07/21

									_nDescX := (nValLoc * 99.99)/100

									_nDescY += _nDescX
									AADD(_AITEMTEMP , {"C6_VALDESC" , _nDescX        , NIL}) 
									NVALLOC -= _nDescX 
								ElseIf FPA->FPA_VRHOR < _nDescX
									IF ! _LJOB
										MsgAlert(STR0032,STR0033) //"Existem custos extras a serem processados, porém o valor do faturamento não alcança o valor total do desconto."###"Atenção!"
									EndIf	
									_lDescCus := .F.
								Else
									AADD(_AITEMTEMP , {"C6_VALDESC" , _nDescX        , NIL}) 
									NVALLOC -= _nDescX 
								EndIF
		   					ENDIF 
	
						IF _LCJLFITE //EXISTBLOCK("LCJLFITE") 				// --> PONTO DE ENTRADA PARA ALTERAÇÃO DA TES.
							_AITEMTEMP := EXECBLOCK("LCJLFITE" , .T. , .T. , {_AITEMTEMP}) 
						ENDIF
	
						_NREG++
						AADD(_AITENSPV , ACLONE(_AITEMTEMP)) 
	
						NPESO    += 0 //ST9->T9_PESO 
						NVALTOT  += NVALLOC 
						AADD(_AASS , {FPA->FPA_PROJET , FPA->FPA_AS , _DDTFIM , _CNUMPED , NITENS , DULTFAT , DPROXFAT}) 
					ENDIF										// --> IF NVALLOC <> 0 
	
					IF _LCJLFFRT //EXISTBLOCK("LCJLFFRT") 					// --> PONTO DE ENTRADA PARA MANIPULAÇÃO DO VALOR DO FRETE.
						EXECBLOCK("LCJLFFRT" , .T. , .T. , {_LPRIMFAT , _NVLRFRETE}) 
					ELSE
						// --> FRETE
						IF _LPRIMFAT .AND. FPA->FPA_TPGUIM == "C"
							_NVLRFRETE += FPA->FPA_GUIMON
						ENDIF
						IF (FPA->FPA_DTSCRT <= _DDTFIM .AND. !EMPTY(FPA->FPA_DTSCRT) .AND. FPA->FPA_TPGUID == "C") .OR.;
						   (ALLTRIM(FPA->FPA_TIPOSE) $ "Z#O" .and. FPA->FPA_TPGUID == "C")
							_NVLRFRETE += FPA->FPA_GUIDES
						ENDIF
					ENDIF
	
					// --> SEGURO
					IF empty(FPA->FPA_ULTFAT) // Frank 23/06/21
						_NVLRSEG += FPA->FPA_VRSEGU
						NVALTOT  += FPA->FPA_VRSEGU
					EndIF
					_CCUSTOAG := FPA->FPA_CUSTO
	                
	                IF CPAR11 == 3 								// AMBOS
						IF SELECT("TRBFPG") > 0 
							TRBFPG->( DBCLOSEAREA() )
						ENDIF
						_CQUERY := " SELECT  FPG_PRODUT , FPG_QUANT , FPG_DESCRI , FPG_VLUNIT , FPG_TAXAV , "     + CRLF 
						_CQUERY += "         FPG_COBRAT , FPG_VALOR , FPG_VALTOT , ZC1.R_E_C_N_O_ ZC1RECNO "      + CRLF 
						_CQUERY += " FROM " + RETSQLNAME("FPG") + " ZC1 "                                         + CRLF 
						_CQUERY += " WHERE   FPG_NRAS   =  '"+FPA->FPA_AS+ "' "                                   + CRLF 
						_CQUERY += "   AND   FPG_COBRA IN ('S','D') "                                             + CRLF 
						_CQUERY += "   AND   FPG_JUNTO  =  'S' "                                                  + CRLF 
						_CQUERY += "   AND   FPG_STATUS =  '1' "                                                  + CRLF 
						_CQUERY += "   AND   FPG_VALTOT > 0 " + CRLF 
						_CQUERY += "   AND   FPG_PRODUT <> ''  "                                                  + CRLF 

						// novos filtros por produto
						IF _lTem12 .and. _lTem13
							_CQUERY += "   AND   FPG_PRODUT BETWEEN '"+ CPAR12 +"' AND '"+ CPAR13 +"' "
						EndIF


						_CQUERY += "   AND  (FPG_DTENT BETWEEN '" + DTOS(DPAR01) + "' AND '" + DTOS(DPAR02) + "'" + CRLF 
						_CQUERY += "    OR   FPG_DTENT = '')"                                                     + CRLF 
						_CQUERY += "   AND   ZC1.D_E_L_E_T_ = '' "                                                + CRLF 
						_CQUERY := CHANGEQUERY(_CQUERY) 
						//CONOUT("[LCJLF001.PRW] # _CQUERY(4): " + _CQUERY) 
						PLSQUERY(_CQUERY , "TRBFPG") 
						DBSELECTAREA("TRBFPG") 
						TRBFPG->(DBGOTOP()) 
		
						IF !EMPTY(TRBFPG->FPG_PRODUT)
		
							WHILE !TRBFPG->(EOF())
								IF TRBFPG->FPG_COBRAT == "N"
									_NTOTZC1 := TRBFPG->FPG_VALOR
								ELSE
									_NTOTZC1 := TRBFPG->FPG_VALTOT
								ENDIF
		
								_NVALZC1   := ROUND(_NTOTZC1 / TRBFPG->FPG_QUANT,SC6->(GETSX3CACHE("C6_VALOR","X3_DECIMAL")))
								_AITEMTEMP := {}
								NITENS     := STRZERO( LEN(_AITENSPV)+1 ,TAMSX3("C6_ITEM")[1])
								//CONOUT("[LCJLF001.PRW] # ((INICIO ARRAY SC6 - B))") 
								//CONOUT("[LCJLF001.PRW] # _NVALZC1(###): " + TRANSFORM(_NVALZC1,"@E 999,999,999.99")) 
								//CONOUT("[LCJLF001.PRW] # _NTOTZC1(###): " + TRANSFORM(_NTOTZC1,"@E 999,999,999.99")) 
								AADD(_AITEMTEMP , {"C6_NUM"     , _CNUMPED           , NIL})
								AADD(_AITEMTEMP , {"C6_FILIAL"  , XFILIAL("SC6")     , NIL})
								AADD(_AITEMTEMP , {"C6_ITEM"    , NITENS             , NIL})
								
								_cProdXa := TRBFPG->FPG_PRODUT
								_cDescXa := TRBFPG->FPG_DESCRI
								IF _LOCA021A //EXISTBLOCK("LOCA021A") 
									_cProdXa := EXECBLOCK("LOCA021A" , .T. , .T. , {TRBFPG->ZC1RECNO,1}) // 1 = Código do produto
									_cDescXa := EXECBLOCK("LOCA021A" , .T. , .T. , {TRBFPG->ZC1RECNO,2}) // 2 = Descricao do produto
								ENDIF 
								
								AADD(_AITEMTEMP , {"C6_PRODUTO" , _cProdXa , NIL})
								AADD(_AITEMTEMP , {"C6_DESCRI"  , _cDescXa , NIL})
								AADD(_AITEMTEMP , {"C6_QTDVEN"  , TRBFPG->FPG_QUANT  , NIL})
								AADD(_AITEMTEMP , {"C6_PRCVEN"  , _NVALZC1           , NIL})
								AADD(_AITEMTEMP , {"C6_PRUNIT"  , _NVALZC1           , NIL})
								AADD(_AITEMTEMP , {"C6_VALOR"   , _NTOTZC1           , NIL})
								//AADD(_AITEMTEMP , {"C6_TES"     , _CTESPRO           , NIL})
								If !empty(FPA->FPA_TESFAT)
									AADD(_AITEMTEMP , {"C6_TES"     , FPA->FPA_TESFAT    , NIL})
								Else
									AADD(_AITEMTEMP , {"C6_TES"     , _CTESPRO           , NIL})
								EndIF
								AADD(_AITEMTEMP , {"C6_QTDLIB"  , TRBFPG->FPG_QUANT  , NIL})
								AADD(_AITEMTEMP , {"C6_CC"      , FPA->FPA_CUSTO     , NIL})

								IF SC6->(FIELDPOS("C6_XCCUSTO")) > 0 
									AADD(_AITEMTEMP     , {"C6_XCCUSTO" , FPA->FPA_CUSTO        , NIL})
								ENDIF	

								IF SC6->(FIELDPOS("C6_XEXTRA")) > 0 
									AADD(_AITEMTEMP , {"C6_XEXTRA"  , "S"                , NIL})
								EndIf
								IF SC6->(FIELDPOS("C6_XAS")) > 0 
									AADD(_AITEMTEMP , {"C6_XAS"     , FPA->FPA_AS        , NIL})
								EndIf
								IF SC6->(FIELDPOS("C6_XBEM")) > 0 
									AADD(_AITEMTEMP , {"C6_XBEM"    , FPA->FPA_GRUA      , NIL})
								EndIf
								// Removido a pedido do Lui em 06/07/21 - Frank
								//AADD(_AITEMTEMP , {"C6_NUMSERI" , FPA->FPA_GRUA      , NIL})
								IF SC6->(FIELDPOS("C6_FROTA")) > 0
									AADD(_AITEMTEMP     , {"C6_FROTA"      , FPA->FPA_GRUA        , NIL})
								ENDIF
								IF SC6->(FIELDPOS("C6_XPERLOC")) > 0 
									AADD(_AITEMTEMP     , {"C6_XPERLOC" , _CPERLOC              , NIL})
								ENDIF
								//CONOUT("[LCJLF001.PRW] # ((FINAL  ARRAY SC6 - B))") 

								_NREG++
		
								NVALTOT += _NTOTZC1 
		
								AADD( _AITENSPV , ACLONE(_AITEMTEMP) ) 
								AADD( _AZC1FAT , {TRBFPG->ZC1RECNO , _CNUMPED , NITENS} ) 
		
								TRBFPG->(DBSKIP())
							ENDDO 
						ENDIF 
					ENDIF		// IF CPAR11 == 3 				// AMBOS
			 //	ENDIF 
		 //	ENDIF
	
			nForca := 0
			IF lLOC021K
				nForca := EXECBLOCK("LOCA021K" , .T. , .T. , {} ) 
			ENDIF 

			TMP->( DBSKIP() )
			//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
			If TMP->( !EOF() ) .or. nForca > 0
				FPA->( DBGOTO( TMP->ZAGRECNO ) )
				FP1->( DBGOTO( TMP->FP1RECNO ) )
				//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
				If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT) .or. nForca == 1
					cPvCliAux := FPA->FPA_CLIFAT + FPA->FPA_LOJFAT
				ElseIf !Empty(FP1->FP1_CLIDES) .or. nForca == 2
					cPvCliAux := FP1->FP1_CLIDES + FP1->FP1_LOJDES
				Else
					cPvCliAux := FP0->FP0_CLI + FP0->FP0_LOJA 
				EndIf
			EndIf
	
		ENDDO 					// WHILE TMP->( !EOF() ) .AND. _CPROJET == TMP->FPA_PROJET 
	
		_CTXT := STR0034      + ALLTRIM(FP1->FP1_NOMORI) + CRLF //"OBRA: "
		_CTXT += STR0035  + ALLTRIM(FP1->FP1_ENDORI) + CRLF //"ENDERECO: "
		_CTXT += STR0036    + ALLTRIM(FP1->FP1_BAIORI) + CRLF //"BAIRRO: "
		_CTXT += STR0037 + ALLTRIM(FP1->FP1_MUNORI) + CRLF //"MUNICIPIO: "
		_CTXT += STR0038    + ALLTRIM(FP1->FP1_ESTORI) + CRLF //"ESTADO: "
	
		IF ! EMPTY(FP1->FP1_CEIORI)
			_CTXT += STR0039    + ALLTRIM(FP1->FP1_CEIORI) + CRLF //"CEI: "
		ENDIF
		IF _LCJNAT //EXISTBLOCK("LCJNAT") 								// --> PONTO DE ENTRADA PARA ALTERAÇÃO DA NATUREZA FINANCEIRA.
			_CNATUREZ := EXECBLOCK("LCJNAT" , .T. , .T. , {_CNATUREZ}) 
		ENDIF
		_CNATUREZ := _MV_LOC065 //GETMV("MV_LOCX065")
		_CPAGTO   := FPA->FPA_CONPAG 
	
		// Frank em 05/05/22 - indica se usa tabela de preços para a geração do SC5
		// é obrigatório somente quando a condição de pagamento esta amarrada com uma tabela de precos
		_lUsaTab := .F.
		If !empty(FPA->FPA_CODTAB)
			DA0->(dbSetOrder(1))
			If DA0->(dbSeek(xFilial("DA0")+FPA->FPA_CODTAB))
				If !empty(DA0->DA0_CONDPG)
					_lUsaTab := .T.
				EndIf
			EndIf
		EndIF


		_ACABPV	:= {}
		//CONOUT("[LCJLF001.PRW] # ((INICIO ARRAY SC5 - A))") 
		//AADD(_ACABPV , {"C5_FILIAL"	 , XFILIAL("SC5")        , NIL})
		AADD(_ACABPV , {"C5_NUM"     , _CNUMPED              , NIL})
		AADD(_ACABPV , {"C5_TIPO"    , "N"                   , NIL})
		AADD(_ACABPV , {"C5_CLIENTE" , SA1->A1_COD           , NIL})
		AADD(_ACABPV , {"C5_LOJACLI" , SA1->A1_LOJA          , NIL})
		If _lUsaTab
			AADD(_ACABPV , {"C5_TABELA"  , FPA->FPA_CODTAB       , NIL})
		EndIF
		AADD(_ACABPV , {"C5_CONDPAG" , _CPAGTO               , NIL})
		AADD(_ACABPV , {"C5_VEND1"   , FP0->FP0_VENDED       , NIL})
		IF SC5->(FIELDPOS("C5_XPROJET")) > 0 
			AADD(_ACABPV , {"C5_XPROJET" , FP0->FP0_PROJET       , NIL})
		EndIf
		AADD(_ACABPV , {"C5_PESOL"   , NPESO                 , NIL})
		AADD(_ACABPV , {"C5_PBRUTO"  , NPESO                 , NIL})
		IF SC5->(FIELDPOS("C5_XTIPFAT")) > 0 
			AADD(_ACABPV , {"C5_XTIPFAT" , "P"                   , NIL})
		EndIf
		IF SC5->(FIELDPOS("C5_XEXTRA")) > 0 
			AADD(_ACABPV , {"C5_XEXTRA"  , "N"                   , NIL})
		EndIf
		AADD(_ACABPV , {"C5_SEGURO"  , _NVLRSEG              , NIL})
		AADD(_ACABPV , {"C5_NATUREZ" , _CNATUREZ             , NIL})
		AADD(_ACABPV , {"C5_MOEDA"   , FP0->FP0_MOEDA        , NIL})
		//CONOUT("[LCJLF001.PRW] # ((FINAL  ARRAY SC5 - A))") 
	
		_CPERLOC := DTOC(FPA->FPA_DTINI) + " A " + DTOC(FPA->FPA_DTFIM)

		IF _LOCA021D //EXISTBLOCK("LOCA021D")
			_cPerloc := EXECBLOCK("LOCA021D" , .T. , .T., {_CPERLOC} ) 
		ENDIF

		IF LITEMFRT
			IF _NVLRFRETE > 0
				NVALTOT += _NVLRFRETE
				IF SB1->( DBSEEK( XFILIAL("SB1")+ CITEMFRT ) )
					NITENS := STRZERO( LEN(_AITENSPV)+1 ,TAMSX3("C6_ITEM")[1])
					_CPERLOC := DTOC(FPA->FPA_DTINI) + " A " + DTOC(FPA->FPA_DTFIM)

					IF _LOCA021D //EXISTBLOCK("LOCA021D")
						_cPerloc := EXECBLOCK("LOCA021D" , .T. , .T., {_CPERLOC} ) 
					ENDIF

					// Identificação do local padrão de estoque
					If empty(FPA->FPA_LOCAL) // não informado na locação o local de estoque
						// utilizar o default informado no cadastro de produtos
						_cLocaPad := SB1->B1_LOCPAD
					Else
						_cLocaPad := FPA->FPA_LOCAL
					EndIF
					
					_AITEMTEMP := {}
					aadd(_AITEMTEMP, {"C6_NUM"     , _CNUMPED       , NIL})
					aadd(_AITEMTEMP, {"C6_FILIAL"  , XFILIAL("SC6") , NIL})
					aadd(_AITEMTEMP, {"C6_ITEM"    , NITENS         , NIL})
					aadd(_AITEMTEMP, {"C6_PRODUTO" , SB1->B1_COD    , NIL})
					aadd(_AITEMTEMP, {"C6_DESCRI"  , SB1->B1_DESC   , NIL})
					aadd(_AITEMTEMP, {"C6_QTDVEN"  , 1              , NIL})
					aadd(_AITEMTEMP, {"C6_PRCVEN"  , _NVLRFRETE     , NIL})
					aadd(_AITEMTEMP, {"C6_PRUNIT"  , _NVLRFRETE     , NIL})
					aadd(_AITEMTEMP, {"C6_VALOR"   , _NVLRFRETE     , NIL})
					aadd(_AITEMTEMP, {"C6_QTDLIB"  , 1              , NIL})
					aadd(_AITEMTEMP, {"C6_TES"     , _CTES          , NIL})
					aadd(_AITEMTEMP, {"C6_CC"      , FPA->FPA_CUSTO , NIL})
					IF SC6->(FIELDPOS("C6_XPERLOC")) > 0 
						aadd(_AITEMTEMP, {"C6_XPERLOC" , _CPERLOC       , NIL})
					EndIF

					//CONOUT("[LCJLF001.PRW] # ((FINAL  ARRAY SC6 - C))") 
					AADD(_AITENSPV , ACLONE(_AITEMTEMP))
					_LINCFRETE := .F.
					_NREG++
				ELSE
					MSGALERT(STR0040+ ALLTRIM(CITEMFRT) + STR0041 , STR0017)  //"FATURAMENTO AUTOMÁTICO - NÃO FOI ENCONTRADO O PRODUTO DE FRETE -> "###"CADASTRADO NO PARÂMETRO MV_LOCX069"###"GPO - LCJLF001.PRW"
					AADD(_ACABPV , {"C5_FRETE"   , _NVLRFRETE , NIL})
				ENDIF
			ENDIF
		ELSE
			AADD(_ACABPV , {"C5_FRETE"   , _NVLRFRETE , NIL}) 
		ENDIF
	
		IF _LCJLFCAB //EXISTBLOCK("LCJLFCAB") 								// --> PONTO DE ENTRADA PARA INCLUSÃO DE CAMPOS NO CABEÇALHO DO PEDIDO DE VENDA.
			_ACABPV := EXECBLOCK("LCJLFCAB" , .T. , .T. , {_ACABPV,"C"}) 
		ENDIF
		IF _LCJLFCAB //EXISTBLOCK("LCJLFCAB") 								
			_AITENSPV := EXECBLOCK("LCJLFCAB" , .T. , .T. , {_AITENSPV,"I"}) 
		ENDIF

		IF _NREG > 0 .and. lGeraPVx
	
			LMSERROAUTO := .F.

			// Sprint 3 - Frank Z Fuga - EAI - 04/10/22
			If !empty(GetMV("MV_LOCX299",,""))
				SetRotInteg("MATA410")
			EndIf
	
			MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)} , _ACABPV , _AITENSPV , 3)
			IF LMSERROAUTO
				MOSTRAERRO()
				ROLLBACKSXE()
			ELSE
				CONFIRMSX8()
				_NVLRFRETE := 0
				_NVLRSEG   := 0
				_NREGPR++
	
				AADD( APEDIDOS , SC5->C5_NUM ) 
	
				IF RECLOCK("SC5", .F.)
					SC5->C5_ORIGEM := "LOCA021"
					SC5->(MSUNLOCK())
				ENDIF
	
				IF LFATURA
					GRAVANFS(SC5->C5_NUM) 
				ENDIF

				// FRANK - 08/12/2020 - ATUALIZACAO DO CAMPO C6_XPERLOC
				FOR _NX := 1 TO LEN(_AITENSPV)

					_cPerLocx := ""
					For _nP := 1 to len(_aItensPV[_nX])
						IF SC6->(FIELDPOS("C6_XPERLOC")) > 0 
							If alltrim(_aItensPV[_nX][_nP][01]) == "C6_XPERLOC"
								_cPerLocx := _aItensPV[_nX][_nP][02]
							EndIf
						EndIF
					Next

					SC6->(DBSETORDER(1))
					IF SC6->(DBSEEK(XFILIAL("SC6")+_CNUMPED+_AITENSPV[_NX][3][2]))
						SC6->(RECLOCK("SC6",.F.))
						IF SC6->(FIELDPOS("C6_XPERLOC")) > 0
							SC6->C6_XPERLOC := _cPerLocx //_AITENSPV[_NX][16][2]
						EndIf
						IF SC6->(FIELDPOS("C6_XCCUSTO")) > 0
							SC6->C6_XCCUSTO := SC6->C6_CC
						EndIF
						SC6->(MSUNLOCK())
					ENDIF
					If _MV_LOC278 //supergetmv("MV_LOCX278",,.T.)
						DELTITPR()
					EndIf
				NEXT

				// Frank - 15/02/21 - Baixa dos custos extras negativos
				If _lDescCus
					For _nX := 1 to len(_aDescCus)
						FPG->(dbGoto(_aDescCus[_nX][01]))

						If empty(FPG->FPG_SEQ)
							_cSeq := GetSx8Num("FPG","FPG_SEQ")
							ConfirmSx8()
							If FPG->(RecLock("FPG",.F.))
								FPG->FPG_SEQ := _cSeq
								FPG->(MsUnlock())
							EndIF
						EndIf

						IF _LCJATFPG //EXISTBLOCK("LCJATFPG") 				
							EXECBLOCK("LCJATFPG" , .T. , .T. , {}) 
						ELSE
							FPG->(RecLock("FPG",.F.))
							FPG->FPG_STATUS := "2"
							FPG->FPG_PVNUM  := _CNUMPED
							FPG->FPG_PVITEM := _aDescCus[_nX][03]
							FPG->(MsUnlock())
						EndIF
					Next
					_aDescCus := {}
				EndIf
	
				DBSELECTAREA("FPA")
				FOR _NX := 1 TO LEN(_AASS)
					FPA->(DBSETORDER(6))
					IF FPA->(DBSEEK(XFILIAL("FPA") + _AASS[_NX][1] + _AASS[_NX][2]))
						IF _LCJATZAG //EXISTBLOCK("LCJATZAG") 				// --> PONTO DE ENTRADA APÓS A ALTERAÇÃO DE CADA ITEM DA ZAG.
							EXECBLOCK("LCJATZAG" , .T. , .T. , {}) 
						ELSE
							IF RECLOCK("FPA",.F.)
								FPA->FPA_ULTFAT := _AASS[_NX][6]
								FPA->FPA_DTFIM  := _AASS[_NX][7]
								FPA->(MSUNLOCK())
							ENDIF
						ENDIF
					ENDIF
	
					IF _MV_LOC243 //SUPERGETMV("MV_LOCX243",.F.,.F.)
						LOCA062(SC5->C5_FILIAL , _AASS[_NX][4] , _AASS[_NX][5] , FPA->FPA_FILIAL , _AASS[_NX][1] , _AASS[_NX][2]) 
					ENDIF
				NEXT _NX 
	
				FOR _NX := 1 TO LEN(_AZC1FAT)
					DBSELECTAREA("FPG")
					FPG->(DBGOTO(_AZC1FAT[_NX][01]))

					If empty(FPG->FPG_SEQ)
						_cSeq := GetSx8Num("FPG","FPG_SEQ")
						ConfirmSx8()
						If FPG->(RecLock("FPG",.F.))
							FPG->FPG_SEQ := _cSeq
							FPG->(MsUnlock())
						EndIF
					EndIf

					IF _LCJATFPG // EXISTBLOCK("LCJATFPG") 				
						EXECBLOCK("LCJATFPG" , .T. , .T. , {}) 
					ELSE
						IF RECLOCK("FPG",.F.)
							FPG->FPG_STATUS := "2"					// FATURADO
							FPG->FPG_PVNUM  := _AZC1FAT[_NX][02]
							FPG->FPG_PVITEM := _AZC1FAT[_NX][03]
							FPG->(MSUNLOCK())
							//Copia o Banco de Conhecimento do Custo Extra para o Pedido de Venda (LOCA007.PRW)
							LC007BCOPV(SC5->C5_FILIAL,FPG->FPG_PVNUM)
						ENDIF
					EndIF
				NEXT _NX 
	
				IF _LCJATFIM //EXISTBLOCK("LCJATFIM")
					EXECBLOCK("LCJATFIM" , .T. , .T. , NIL) 
				ENDIF
				// DEPOIS DE TUDO GERADO SE HOUVER O PARÂMETRO INDICANDO QUE PRECISA DE UM PEDIDO AGLUTINADO PARA INTEGRAÇÃO COM RM
				// GERARMOS UM NOVO PEDIDO DE VENDAS COM OS ITENS AGLUTINADOS.
				// FRANK ZWARG FUGA - 24/12/2020
				// --------------------------------------------------------------------------------------------------------------------
				IF _MV_AGLUNFS //SUPERGETMV("MV_AGLUNFS",,.F.)
					_AAGLUTINA := {}
					_NVALOR    := 0
					_CMENSNF   := ""
					FOR _NX:=1 TO LEN(_AITENSPV)

						_nPosProd := 0
						_nPosQtd  := 0
						_nPosVlr  := 0
						_nPosCC   := 0
						For _nPos := 1 to len(_AITENSPV[_nX])
							If _AITENSPV[_nX][_nPos][01] == "C6_PRODUTO"
								_nPosProd := _nPos
							ElseIf _AITENSPV[_nX][_nPos][01] == "C6_CC" 
								_nPosCC := _nPos
							ElseIf _AITENSPV[_nX][_nPos][01] == "C6_QTDVEN"
								_nPosQtd := _nPos
							ElseIf _AITENSPV[_nX][_nPos][01] == "C6_PRUNIT"
								_nPosVlr := _nPos
							EndIf
						Next

						_NVALOR 	+= _AITENSPV[_NX][_nPosVlr][2] * _AITENSPV[_NX][_nPosQtd][2]
						_CMENSNF	+= STR0042+ALLTRIM(_AITENSPV[_NX][_nPosProd][2]) //"PRODUTO: "
						_CMENSNF	+= STR0043+ALLTRIM(STR(_AITENSPV[_NX][_nPosQtd][2])) //" QTD.: "
						_CMENSNF	+= STR0044+ALLTRIM(STR(_AITENSPV[_NX][_nPosVlr][2])) //" VLR.UNIT.: "
						_CMENSNF    += STR0045+ALLTRIM(STR(_AITENSPV[_NX][_nPosVlr][2] * _AITENSPV[_NX][_nPosQtd][2])) //" VLR.TOTAL: "
						_CMENSNF	+= CHR(13) + CHR(10)
						If _nPosCC > 0
							_CCUSTOAG   := _AITENSPV[_NX][_nPosCC][2]
						Else
							_CCUSTOAG   := ""
						EndIF
					NEXT
					_CNUMPED2   := GETSXENUM("SC5","C5_NUM") 
					WHILE .T.
						IF SC5->( DBSEEK(XFILIAL("SC5")+_CNUMPED2) )
							CONFIRMSX8()
							_CNUMPED2 := GETSXENUM("SC5","C5_NUM")
							LOOP
						ELSE
							EXIT
						ENDIF
					ENDDO

					SB1->(DBSETORDER(1))
					SB1->(DBSEEK(XFILIAL("SB1")+_MV_AGLUPRO))

					_AAGLUTINA := {}
					aadd(_AAGLUTINA, {"C6_NUM"     , _CNUMPED2      , NIL})
					aadd(_AAGLUTINA, {"C6_FILIAL"  , XFILIAL("SC6") , NIL})
					aadd(_AAGLUTINA, {"C6_ITEM"    , 1              , NIL})
					aadd(_AAGLUTINA, {"C6_PRODUTO" , SB1->B1_COD    , NIL})
					aadd(_AAGLUTINA, {"C6_DESCRI"  , SB1->B1_DESC   , NIL})
					aadd(_AAGLUTINA, {"C6_QTDVEN"  , 1              , NIL})
					aadd(_AAGLUTINA, {"C6_PRCVEN"  , _NVALOR        , NIL})
					aadd(_AAGLUTINA, {"C6_PRUNIT"  , _NVALOR        , NIL})
					aadd(_AAGLUTINA, {"C6_VALOR"   , _NVALOR        , NIL})
					aadd(_AAGLUTINA, {"C6_QTDLIB"  , 1              , NIL})
					aadd(_AAGLUTINA, {"C6_TES"     , _CTES          , NIL})
					aadd(_AAGLUTINA, {"C6_CC"      , _CCUSTOAG      , NIL})
					IF SC6->(FIELDPOS("C6_XPERLOC")) > 0
						aadd(_AAGLUTINA, {"C6_XPERLOC" , _CPERLOC       , NIL})
					EndIF

					_ACABPV	:= {}
					AADD(_ACABPV , {"C5_NUM"     , _CNUMPED2             , NIL})
					AADD(_ACABPV , {"C5_TIPO"    , "N"                   , NIL})
					AADD(_ACABPV , {"C5_CLIENTE" , SA1->A1_COD           , NIL})
					AADD(_ACABPV , {"C5_LOJACLI" , SA1->A1_LOJA          , NIL})
					AADD(_ACABPV , {"C5_CONDPAG" , _CPAGTO               , NIL})
					AADD(_ACABPV , {"C5_VEND1"   , FP0->FP0_VENDED       , NIL})
					IF SC5->(FIELDPOS("C5_XPROJET")) > 0
						AADD(_ACABPV , {"C5_XPROJET" , FP0->FP0_PROJET       , NIL})
					EndIF
					IF SC5->(FIELDPOS("C5_XTIPFAT")) > 0
						AADD(_ACABPV , {"C5_XTIPFAT" , "I"                   , NIL}) // M=MEDICAO, P=PADRAO, I=INTEGRACAO RM
					EndIF
					AADD(_ACABPV , {"C5_SEGURO"  , 0                     , NIL})
					AADD(_ACABPV , {"C5_NATUREZ" , _CNATUREZ             , NIL})
					AADD(_ACABPV , {"C5_MOEDA"   , FP0->FP0_MOEDA        , NIL})

					_AITENSPV := {}
					AADD(_AITENSPV , ACLONE(_AAGLUTINA))

					// Sprint 3 - Frank Z Fuga - EAI - 04/10/22
					If !empty(GetMV("MV_LOCX299",,""))
						SetRotInteg("MATA410")
					EndIf

					MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)} , _ACABPV , _AITENSPV , 3)
					IF LMSERROAUTO
						MOSTRAERRO()
						ROLLBACKSXE()
					ELSE
						CONFIRMSX8()
						SC5->(RECLOCK("SC5",.F.))
						SC5->C5_ORIGEM := "LOCA021"
						SC5->(MSUNLOCK())
						IF SC6->(FIELDPOS("C6_XCCUSTO")) > 0 
							SC6->(RecLock("SC6",.F.))
							SC6->C6_XCCUSTO := SC6->C6_CC
							SC6->(MsUnlock())
						EndIf
					ENDIF
				ENDIF
				// --------------------------------------------------------------------------------------------------------------------
			ENDIF
			_NREG := 0
		ENDIF

		IF len(_AITENSPV) > 0 //_NREG > 0 .and. !lGeraPVx
			IF _LOCA061Z //EXISTBLOCK("LOCA061Z") 
				EXECBLOCK("LOCA061Z" , .T. , .T. , {_ACABPV,_AITENSPV,_AZC1FAT,lGeraPVx}) 
			ENDIF 
		EndIF
	
		IF LCLIBLQ
			SA1->( DBGOTO(NSA1RECNO) ) 
			IF RECLOCK("SA1", .F.)
				SA1->A1_MSBLQL := "1"
				SA1->(MSUNLOCK())
			ENDIF
		ENDIF
	
		DBSELECTAREA("TMP")
	ENDDO 
	
	TMP->( DBCLOSEAREA() )

ENDIF			// IF CPAR11 == 1 .OR. CPAR11 == 3 				// 1 - LOCAÇÃO / 3 - AMBOS

IF CPAR11 == 2 .OR. CPAR11 == 3 								// 2 - CUSTOS EXTRAS / 3 - AMBOS 

	IF SELECT("TRBFPG") > 0
		TRBFPG->( DBCLOSEAREA() )
	ENDIF
	_CQUERY     := " SELECT FPG_PRODUT , FPG_QUANT  , FPG_DESCRI , FPG_VLUNIT , " + CRLF
	_CQUERY     += "        FPG_TAXAV  , FPG_VALTOT , ZC1.R_E_C_N_O_ ZC1RECNO , " + CRLF
	_CQUERY     += "        ZA0.R_E_C_N_O_ ZA0RECNO , ZAG.R_E_C_N_O_ ZAGRECNO , " + CRLF
	_CQUERY     += "        FP1.R_E_C_N_O_ FP1RECNO , " + CRLF
	_CQUERY     += " 	    FP0_PROJET PROJET , FP0_CLI , FP0_LOJA , FP0_VENDED " + CRLF
	_CQUERY     += " FROM " + RETSQLNAME("FPG") + " ZC1 "                         + CRLF
	_CQUERY     += "        INNER JOIN " + RETSQLNAME("FPA") + " ZAG ON  ZAG.FPA_AS     = FPG_NRAS   AND  ZAG.FPA_AS    <> '' "         + CRLF
	_CQUERY     += "                                                 AND ZAG.D_E_L_E_T_ = ''  "                                         + CRLF
	
	// Novos filtros do produto e acerto do funcionamento do filtro dos bens - Frank em 08/09/21
	If _lTem12 .and. _lTem13
		_CQUERY     += "   AND  ZAG.FPA_PRODUT BETWEEN '"+ CPAR12 +"' AND '"+ CPAR13 +"' "
	EndIF
	_CQUERY     += "   AND  ZAG.FPA_GRUA BETWEEN '"+ CPAR07 +"' AND '"+ CPAR08 +"' "

	_CQUERY     += "        INNER JOIN " + RETSQLNAME("FQ5") + " DTQ ON  DTQ.FQ5_AS     = FPA_AS     AND  DTQ.FQ5_SOT    = FPA_PROJET " + CRLF
	_CQUERY     += "                                                 AND DTQ.FQ5_STATUS = '6' "                                         + CRLF
	_CQUERY     += "                                                 AND DTQ.D_E_L_E_T_ = ''  "                                         + CRLF
	_CQUERY     += "        INNER JOIN " + RETSQLNAME("FP0") + " ZA0 ON  ZA0.FP0_FILIAL = FPA_FILIAL AND  ZA0.FP0_PROJET = FPA_PROJET " + CRLF
	_CQUERY     += "                                                 AND ZA0.FP0_PROJET BETWEEN '" + CPAR09 + "' AND '" + CPAR10 + "'"  + CRLF
	_CQUERY     += "                                                 AND ZA0.FP0_CLI    BETWEEN '" + CPAR03 + "' AND '" + CPAR04 + "'"  + CRLF
	_CQUERY     += "                                                 AND ZA0.FP0_LOJA   BETWEEN '" + CPAR05 + "' AND '" + CPAR06 + "'"  + CRLF
	_CQUERY     += "                                                 AND ZA0.D_E_L_E_T_ = '' "                                          + CRLF
	_CQUERY     += "        INNER JOIN "+RETSQLNAME("FP1")+" FP1 ON FP1.FP1_FILIAL = FPA_FILIAL" 								 						+ CRLF
	_CQUERY     += "                                                 AND FP1.FP1_PROJET = FPA_PROJET"  									+ CRLF
	_CQUERY     += "                                                 AND FP1_OBRA = FPA_OBRA"  											+ CRLF
	_CQUERY     += "                                                 AND FP1.D_E_L_E_T_ = '' "                                          + CRLF
	_CQUERY     += " WHERE  FPG_FILIAL = '" + XFILIAL("FPG") + "'"                + CRLF
	_CQUERY     += "   AND  FPG_COBRA IN ('S','D')"                               + CRLF
	IF CPAR11 == 3 												// AMBOS -> CONSIDERA APENAS N, POIS O S JÁ FOI FATURADO NO PEDIDO DA LOCAÇÃO 
		_CQUERY += "   AND  FPG_JUNTO = 'N' "                                     + CRLF
	ENDIF
	_CQUERY     += "   AND  FPG_STATUS = '1' "                                    + CRLF
	_CQUERY     += "   AND  FPG_PRODUT <> '' "                                    + CRLF
	_CQUERY     += "   AND (FPG_DTENT BETWEEN '"+DTOS(DPAR01)+"' AND '"+DTOS(DPAR02)+"'" + CRLF
	_CQUERY     += "    OR  FPG_DTENT = '') "                                     + CRLF
	_CQUERY     += "   AND  ZC1.D_E_L_E_T_ = ''"                                  + CRLF
	_CQUERY     += "   AND FPG_VALTOT > 0 " + CRLF
	If FPA->(ColumnPos("FPA_CLIFAT")) > 0
		_CQUERY     += " ORDER BY 	FPA_PROJET, FPA_OBRA,  " 
		_CQUERY     += " 			FPA_CLIFAT DESC , FPA_LOJFAT, FPA_AS, "  // ORDENADO POR CLIENTE para facilitar a quebra posterior do PV
		_CQUERY     += "  			FPG_DTENT , ZC1RECNO " 
	Else
		_CQUERY     += "  ORDER BY PROJET , FPG_NRAS , FPG_DTENT , ZC1RECNO " 
	EndIf
	_CQUERY     := CHANGEQUERY(_CQUERY)	
	//CONOUT("[LCJLF001.PRW] # _CQUERY(5): " + _CQUERY) 

	TCQUERY _CQUERY NEW ALIAS "TRBFPG"
	TRBFPG->(dbGotop())

	// Tela para seleção dos registros Frank em 27/10/21
	nForca := 0
	IF lLOC021L
		nForca := EXECBLOCK("LOCA021L" , .T. , .T. , {} ) 
	ENDIF 
	_ASZ1 := {}
	If !_lJob .and. _lTem14 .or. nForca > 0 // se não for job e existe o pergunte da selecao
		If cPar14 == 2 .or. nForca > 0 // Se optou por selecionar os contratos para faturamento
			If cPar11 <> 3 .or. nForca > 0 // Se optou por locação, ou custo extra (não é válido ambos para a selecao)
				// Selecionar os contratos
				_ASZ1 := {}
				While !TRBFPG->(Eof()) .or. nForca > 0
					FPA->( DBGOTO( TRBFPG->ZAGRECNO ) )
					FP1->( DBGOTO(TRBFPG->FP1RECNO) )
					FP0->( DBGOTO(TRBFPG->ZA0RECNO) )
					
					//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
					If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT) .or. nForca == 1
						cCliFat := FPA->FPA_CLIFAT
						cLojFat := FPA->FPA_LOJFAT
						cNomFat := alltrim(FPA->FPA_NOMFAT)
					ElseIf !Empty(FP1->FP1_CLIDES) .or. nForca == 2
						cCliFat := FP1->FP1_CLIDES
						cLojFat := FP1->FP1_LOJDES
						cNomFat := alltrim(FP1->FP1_NOMDES)
					Else
						cCliFat := FP0->FP0_CLI
						cLojFat := FP0->FP0_LOJA
						cNomFat := alltrim(FP0->FP0_CLINOM)
					EndIf
					SB1->(dbSetorder(1))
					SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))
					aadd(_ASZ1,{.T.,FPA->FPA_PROJET,FPA->FPA_OBRA, FPA->FPA_AS, FPA->FPA_PRODUT, SB1->B1_DESC, TRBFPG->ZC1RECNO, TRBFPG->ZAGRECNO, cCliFat, cLojFat, cNomFat})
					// Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
					IF lLOC021P
						aCompleX := EXECBLOCK("LOCA021P" , .T. , .T. , {3} ) 
						If len(aComplex) > 0
							For nX := 1 to len(aComplex[1])
								aadd(_aSZ1[len(_ASZ1)],aComplex[1,nX])
							Next
						EndIF
					ENDIF 
					TRBFPG->(dbSkip())

					If nForca > 0
						Return
					EndIF

				EndDo

				If len(_aSZ1) == 0
					MsgAlert(STR0085,STR0007) // Não houve registro para a selecao###Atencao
					Return .F.
				EndIF

				cOpcx := "0"
				_aSeleca2 := {}
				DEFINE MSDIALOG ODLGFIL TITLE STR0076 FROM 010,005 TO NJANELAA,NJANELAL PIXEL//Seleção dos projetos
	    		@ 0.5,0.7 LISTBOX OFILOS FIELDS HEADER  " ",STR0077,STR0078,STR0079,STR0080,STR0081,STR0086,STR0087,STR0088 SIZE NLBTAML,NLBTAMA ON DBLCLICK (MARCARREGI(.F.)) //Projeto, Obra, AS, Cod.Produto, Descricao, "Cod.Cliente","Loja","Nome"
				// Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
				IF lLOC021Q
					aCompleX := EXECBLOCK("LOCA021Q" , .T. , .T. , {3} ) 
					If len(aComplex) > 0
						For nX := 1 to len(aComplex[1])
							aadd(OFILOS:aHeaders,aComplex[1,nX])
						Next
					EndIF
				ENDIF 

	    		OFILOS:SETARRAY(_ASZ1)

				cLinha := "{|| { IF( _ASZ1[OFILOS:NAT,1],OOK,ONO),"
				cLinha += "_ASZ1[OFILOS:NAT,2],"
				cLinha += "_ASZ1[OFILOS:NAT,3],"
				cLinha += "_ASZ1[OFILOS:NAT,4],"
				cLinha += "_ASZ1[OFILOS:NAT,5],"
				cLinha += "_ASZ1[OFILOS:NAT,6],"
				cLinha += "_ASZ1[OFILOS:NAT,9],"
				cLinha += "_ASZ1[OFILOS:NAT,10],"
				cLinha += "_ASZ1[OFILOS:NAT,11]"
				// Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
				IF lLOC021Q
					aCompleX := EXECBLOCK("LOCA021Q" , .T. , .T. , {3} ) 
					If len(aComplex) > 0
						For nX := 1 to len(aComplex[1])
							cLinha += ",_ASZ1[OFILOS:NAT,"+alltrim(str(11+nX))+"]"
						Next
					EndIF
				ENDIF 
				cLinha += "}}"

	    		OFILOS:BLINE := &(cLinha)

				@ 172,007 BUTTON OMARKBUT 	PROMPT STR0089 SIZE 55,12 OF ODLGFIL PIXEL ACTION (MARCARREGI(.T.)) //"(Des)marcar todos"  
				@ 172,062 BUTTON OFILBUT 	PROMPT STR0082 SIZE 55,12 OF ODLGFIL PIXEL ;  //"GERA FATURAMENTO"
		                 ACTION ( IIF(MSGYESNO(OEMTOANSI(STR0083) , STR0007) , ;  //"Confirma a geracao do faturamento?"###"Atencao"
		                              cOpcx := "1"  , ; 
		                              cOpcx := "0") , ; 
		                         ODLGFIL:END() ) 
	    		@ 172,117 BUTTON   OCANBUT PROMPT STR0084             SIZE 55,12 OF ODLGFIL PIXEL ACTION (cOpcx := "0", ODLGFIL:END()) //"CANCELAR"
    			ACTIVATE MSDIALOG ODLGFIL CENTERED
				
				// Validar se selecionou pelo menos um contrato
				If cOpcx == "0"
					Return .F.
				Else
					For _nX := 1 to len(_aSZ1)
						If _aSZ1[_nX,1]
							aadd(_aSeleca2,{_aSZ1[_nX][7],_aSZ1[_nX][8]})
						EndIF
					Next
				EndIF
				If len(_aSeleca2) == 0
					Return .F.
				EndIF
				
			Else
				MsgAlert(STR0075,STR0017) //A opção ambos não permite a seleção dos contratos.###Rental
				Return .F.
			EndIF
		EndIf
	EndIF
	TRBFPG->(dbGotop())
	
	NITENS    := ""
	_AITENSPV := {}
	_AZC1FAT  := {}
	
	DBSELECTAREA("FP0")
	DBSELECTAREA("FPA")
	DBSELECTAREA("FPG")
	WHILE TRBFPG->(!EOF())

		If !_lJob .and. _lTem14 // se não for job e existe o pergunte da selecao
			If cPar14 == 2 // Se optou por selecionar os contratos para faturamento
				If cPar11 <> 3 // Se optou por locação, ou custo extra (não é válido ambos para a selecao)
					_lSelecao := .F.
					If len(_aSeleca2) > 0
						For _nX:=1 to len(_aSeleca2)
							If _aSeleca2[_nX][1] == TRBFPG->ZC1RECNO
								_lSelecao := .T.
								Exit
							EndIF
						Next
					EndIF
					If !_lSelecao
						TRBFPG->(dbSkip())
						Loop
					EndIF
				EndIF
			EndIF
		EndIF

		If lGeraPVx
			_CNUMPED := GETSXENUM("SC5","C5_NUM") 
		Else
			_CNUMPED := ""
		EndIF
		SC5->(dbSetOrder(1))
		WHILE .T. .and. lGeraPVx
			IF SC5->( DBSEEK(XFILIAL("SC5") + _CNUMPED) )
				CONFIRMSX8()
				_CNUMPED := GETSXENUM("SC5","C5_NUM")
				LOOP
			ELSE
				CONFIRMSX8()
				EXIT
			ENDIF
		ENDDO
	
		_CNATUREZ := _MV_LOC065 //GETMV("MV_LOCX065")
		_CPROJET  := TRBFPG->PROJET
		_cTabel   := ""
	
		FPA->( DBGOTO(TRBFPG->ZAGRECNO) )
		FP1->( DBGOTO(TRBFPG->FP1RECNO) )
		FP0->( DBGOTO(TRBFPG->ZA0RECNO) )

		nForca := 0
		IF lLOC021M
			nForca := EXECBLOCK("LOCA021M" , .T. , .T. , {} ) 
		ENDIF 

		//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
		If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT) .or. nForca == 1
			cPvCliente := FPA->FPA_CLIFAT + FPA->FPA_LOJFAT
		ElseIf !Empty(FP1->FP1_CLIDES) .or. nForca == 2
			cPvCliente := FP1->FP1_CLIDES + FP1->FP1_LOJDES
		Else
			cPvCliente := FP0->FP0_CLI + FP0->FP0_LOJA 
		EndIf

		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1") + cPvCliente)) .and. nForca == 0
		Else
			Help(NIL, NIL, "LOCA021_2", NIL, "Cliente não localizado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe um cliente válido no Projeto " + AllTrim(FPA->FPA_PROJET) + " | Obra: " + FPA->FPA_OBRA + " | Seq: " + FPA->FPA_SEQGRU})
			Return .F.
		EndIf
	
		//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
		cPvProjet 	:= TRBFPG->PROJET
		cPvObra 	:= FP1->FP1_OBRA
		cPvCliAux	:= cPvCliente

		//realiza quebra dos itens
		//WHILE TRBFPG->(!EOF()) .AND. _CPROJET == TRBFPG->PROJET
		//nova forma de quebra a partir de SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
		//QUEBRA PEDIDO POR PROJETO / OBRA / CLIENTE

		nForca := 0
		IF lLOC021N
			nForca := EXECBLOCK("LOCA021N" , .T. , .T. , {} ) 
		ENDIF 

		WHILE TRBFPG->( !EOF() ) .AND. cPvProjet == TRBFPG->PROJET .And. cPvObra == FP1->FP1_OBRA .And. cPvCliente == cPvCliAux .or. nForca > 0
			FPA->( DBGOTO( TRBFPG->ZAGRECNO ) )
			FPG->( DBGOTO( TRBFPG->ZC1RECNO ) )
			FP1->( DBGOTO( TRBFPG->FP1RECNO ) )

			//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
			If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT) .or. nForca == 1
				cCliFat := FPA->FPA_CLIFAT
				cLojFat := FPA->FPA_LOJFAT
				cNomFat := alltrim(FPA->FPA_NOMFAT)
			ElseIf !Empty(FP1->FP1_CLIDES) .or. nForca == 2
				cCliFat := FP1->FP1_CLIDES
				cLojFat := FP1->FP1_LOJDES
				cNomFat := alltrim(FP1->FP1_NOMDES)
			Else
				cCliFat := FP0->FP0_CLI
				cLojFat := FP0->FP0_LOJA
				cNomFat := alltrim(FP0->FP0_CLINOM)
			EndIf

			If !_lJob .and. _lTem14 .or. nforca > 0 // se não for job e existe o pergunte da selecao
				If cPar14 == 2 .or. nforca > 0 // Se optou por selecionar os contratos para faturamento
					If cPar11 <> 3 .or. nforca > 0 // Se optou por locação, ou custo extra (não é válido ambos para a selecao)
						_lSelecao := .F.
						If len(_aSeleca2) > 0
							For _nX:=1 to len(_aSeleca2)
								If _aSeleca2[_nX][1] == TRBFPG->ZC1RECNO
									_lSelecao := .T.
									Exit
								EndIF
							Next
						EndIF
						If !_lSelecao .or. nforca > 0
							TRBFPG->(dbSkip())
							//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
							If TRBFPG->( !EOF() ) .or. nforca > 0
								FPA->( DBGOTO( TRBFPG->ZAGRECNO ) )
								FP1->( DBGOTO( TRBFPG->FP1RECNO ) )
								//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
								If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT) .or. nForca == 1
									cPvCliAux := FPA->FPA_CLIFAT + FPA->FPA_LOJFAT
								ElseIf !Empty(FP1->FP1_CLIDES) .or. nForca == 2
									cPvCliAux := FP1->FP1_CLIDES + FP1->FP1_LOJDES
								Else
									cPvCliAux := FP0->FP0_CLI + FP0->FP0_LOJA 
								EndIf
							EndIf
							If nForca > 0
								Return
							EndIF
							Loop
						EndIF
					EndIF
				EndIF
			EndIF
	
			IF FPG->FPG_COBRAT == "N"
				_NTOTZC1 := FPG->FPG_VALOR
			ELSE
				_NTOTZC1 := FPG->FPG_VALTOT
			ENDIF
	
			_NVALZC1 := ROUND(_NTOTZC1 / FPG->FPG_QUANT,SC6->(GETSX3CACHE("C6_VALOR","X3_DECIMAL")))
	
			_AITEMTEMP := {}
			NITENS := STRZERO( LEN(_AITENSPV)+1 ,TAMSX3("C6_ITEM")[1])
			AADD(_AITEMTEMP , {"C6_NUM"     , _CNUMPED        , NIL})
			AADD(_AITEMTEMP , {"C6_FILIAL"  , XFILIAL("SC6")  , NIL})
			AADD(_AITEMTEMP , {"C6_ITEM"    , NITENS          , NIL})

			_cProdXa := FPG->FPG_PRODUT
			_cDescXa := FPG->FPG_DESCRI
			IF _LOCA021A //EXISTBLOCK("LOCA021A") 
				_cProdXa := EXECBLOCK("LOCA021A" , .T. , .T. , {FPG->(Recno()),1}) // 1 = Código do produto
				_cDescXa := EXECBLOCK("LOCA021A" , .T. , .T. , {FPG->(Recno()),2}) // 2 = Descricao do produto
			ENDIF 

			AADD(_AITEMTEMP , {"C6_PRODUTO" , _cProdXa , NIL})
			AADD(_AITEMTEMP , {"C6_DESCRI"  , _cDescXa , NIL})
			
			AADD(_AITEMTEMP , {"C6_QTDVEN"  , FPG->FPG_QUANT  , NIL})
			AADD(_AITEMTEMP , {"C6_PRCVEN"  , _NVALZC1        , NIL})
			AADD(_AITEMTEMP , {"C6_PRUNIT"  , _NVALZC1        , NIL})
			AADD(_AITEMTEMP , {"C6_VALOR"   , _NTOTZC1        , NIL})
			If empty(FPA->FPA_TESFAT)
				AADD(_AITEMTEMP , {"C6_TES"     , _CTESPRO        , NIL})
			Else
				AADD(_AITEMTEMP , {"C6_TES"     , FPA->FPA_TESFAT , NIL})
			EndIf
			AADD(_AITEMTEMP , {"C6_QTDLIB"  , FPG->FPG_QUANT  , NIL})
			AADD(_AITEMTEMP , {"C6_CC"      , FPA->FPA_CUSTO  , NIL})
			IF SC6->(FIELDPOS("C6_XEXTRA")) > 0
				AADD(_AITEMTEMP , {"C6_XEXTRA"  , "S"             , NIL})
			EndIF
			IF SC6->(FIELDPOS("C6_XAS")) > 0
				AADD(_AITEMTEMP , {"C6_XAS"     , FPG->FPG_NRAS   , NIL})
			EndIF
			IF SC6->(FIELDPOS("C6_XBEM")) > 0
				AADD(_AITEMTEMP , {"C6_XBEM"    , FPA->FPA_GRUA   , NIL})
			EndIF
			IF SC6->(FIELDPOS("C6_FROTA")) > 0
				AADD(_AITEMTEMP     , {"C6_FROTA"      , FPA->FPA_GRUA        , NIL})
			ENDIF
			IF SC6->(FIELDPOS("C6_XPERLOC")) > 0 
				_CPERLOC := DTOC(FPA->FPA_DTINI) + " A " + DTOC(FPA->FPA_DTFIM)

				IF _LOCA021D //EXISTBLOCK("LOCA021D")
					_cPerloc := EXECBLOCK("LOCA021D" , .T. , .T., {_CPERLOC} ) 
				ENDIF

				AADD(_AITEMTEMP     , {"C6_XPERLOC" , _CPERLOC              , NIL})
			ENDIF
			IF SC6->(FIELDPOS("C6_XCCUSTO")) > 0 
				AADD(_AITEMTEMP     , {"C6_XCCUSTO" , FPA->FPA_CUSTO        , NIL})
			ENDIF

			_NREG++
	
			NVALTOT += _NTOTZC1
	
			AADD( _AITENSPV , ACLONE(_AITEMTEMP) )
			AADD( _AZC1FAT , {TRBFPG->ZC1RECNO,_CNUMPED,NITENS} ) 
	
			_CPAGTO := FPA->FPA_CONPAG
			_cTabel := FPA->FPA_CODTAB
	
			FP0->(DBSETORDER(1))	// ZA0_FILIAL + ZA0_PROJET
			FP0->( DBGOTO( TRBFPG->ZA0RECNO ) )
	
			TRBFPG->(DBSKIP())
			//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO

			nForca := 0
			IF lLOC021O
				nForca := EXECBLOCK("LOCA021O" , .T. , .T. , {} ) 
			ENDIF 

			If TRBFPG->( !EOF() ) .or. nforca > 0
				FPA->( DBGOTO( TRBFPG->ZAGRECNO ) )
				FP1->( DBGOTO( TRBFPG->FP1RECNO ) )
				//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
				If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT) .or. nForca == 1
					cPvCliAux := FPA->FPA_CLIFAT + FPA->FPA_LOJFAT
				ElseIf !Empty(FP1->FP1_CLIDES) .or. nForca == 2
					cPvCliAux := FP1->FP1_CLIDES + FP1->FP1_LOJDES
				Else
					cPvCliAux := FP0->FP0_CLI + FP0->FP0_LOJA 
				EndIf
			EndIf

			If nforca > 0
				Return
			EndIF

		ENDDO

		// Frank em 05/05/22 - indica se usa tabela de preços para a geração do SC5
		// é obrigatório somente quando a condição de pagamento esta amarrada com uma tabela de precos
		_lUsaTab := .F.
		If !empty(_cTabel)
			DA0->(dbSetOrder(1))
			If DA0->(dbSeek(xFilial("DA0")+_cTabel))
				If !empty(DA0->DA0_CONDPG)
					_lUsaTab := .T.
				EndIf
			EndIf
		EndIF
	
		_ACABPV	:= {}
		//CONOUT("[LCJLF001.PRW] # ((INICIO ARRAY SC5 - B))") 
		//AADD(_ACABPV , {"C5_FILIAL"  , XFILIAL("SC5")        , NIL})
		AADD(_ACABPV , {"C5_NUM"     , _CNUMPED              , NIL})
		AADD(_ACABPV , {"C5_TIPO"    , "N"                   , NIL})
		//AADD(_ACABPV , {"C5_CLIENTE" , FP0->FP0_CLI          , NIL})
		AADD(_ACABPV , {"C5_CLIENTE" , cCliFat         		, NIL})
		//(_ACABPV , {"C5_LOJACLI" , FP0->FP0_LOJA         , NIL})
		AADD(_ACABPV , {"C5_LOJACLI" , cLojFat        		, NIL})
		If _lUsaTab
			AADD(_ACABPV , {"C5_TABELA" , _cTabel                , NIL})
		EndIF
		AADD(_ACABPV , {"C5_CONDPAG" , _CPAGTO               , NIL})
		AADD(_ACABPV , {"C5_VEND1"   , FP0->FP0_VENDED       , NIL})
		IF SC5->(FIELDPOS("C5_XPROJET")) > 0 
			AADD(_ACABPV , {"C5_XPROJET" , FP0->FP0_PROJET       , NIL})
		EndIF
		IF SC5->(FIELDPOS("C5_XTIPFAT")) > 0 
			AADD(_ACABPV , {"C5_XTIPFAT" , "P"                   , NIL})
		EndIF
		AADD(_ACABPV , {"C5_NATUREZ" , _CNATUREZ             , NIL})
		AADD(_ACABPV , {"C5_MOEDA"   , FP0->FP0_MOEDA        , NIL})
	
		IF _LCJLFCAB //EXISTBLOCK("LCJLFCAB") 								// --> PONTO DE ENTRADA PARA INCLUSÃO DE CAMPOS NO CABEÇALHO DO PEDIDO DE VENDA.
			_ACABPV := EXECBLOCK("LCJLFCAB" , .T. , .T. , {_ACABPV,"C"}) 
		ENDIF
		IF _LCJLFCAB //EXISTBLOCK("LCJLFCAB") 								
			_AITENSPV := EXECBLOCK("LCJLFCAB" , .T. , .T. , {_AITENSPV,"I"}) 
		ENDIF
	
		IF _NREG > 0 .and. lGeraPVx
	
			LMSERROAUTO := .F.
	
			// Sprint 3 - Frank Z Fuga - EAI - 04/10/22
			If !empty(GetMV("MV_LOCX299",,""))
				SetRotInteg("MATA410")
			EndIf

			MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)} , _ACABPV , _AITENSPV , 3) 
			IF LMSERROAUTO
				MOSTRAERRO()
				ROLLBACKSXE()
			ELSE
				_NREGPR++
	
				AADD( APEDIDOS , SC5->C5_NUM ) 
	
				IF RECLOCK("SC5", .F.)
					SC5->C5_ORIGEM := "LOCA021"
					SC5->(MSUNLOCK())
				ENDIF
	
				IF LFATURA
					GRAVANFS(SC5->C5_NUM) 
				ENDIF
	
				FOR _NX := 1 TO LEN(_AZC1FAT)
					DBSELECTAREA("FPG")
					FPG->(DBGOTO(_AZC1FAT[_NX][01]))

					If empty(FPG->FPG_SEQ)
						_cSeq := GetSx8Num("FPG","FPG_SEQ")
						ConfirmSx8()
						If FPG->(RecLock("FPG",.F.))
							FPG->FPG_SEQ := _cSeq
							FPG->(MsUnlock())
						EndIF
					EndIf

					IF _LCJATFPG //EXISTBLOCK("LCJATFPG") 				
						EXECBLOCK("LCJATFPG" , .T. , .T. , {}) 
					ELSE
						IF RECLOCK("FPG",.F.)
							FPG->FPG_STATUS := "2"					// FATURADO
							FPG->FPG_PVNUM  := _AZC1FAT[_NX][02]
							FPG->FPG_PVITEM := _AZC1FAT[_NX][03]
							FPG->(MSUNLOCK())
							//Copia o Banco de Conhecimento do Custo Extra para o Pedido de Venda (LOCA007.PRW)
							LC007BCOPV(SC5->C5_FILIAL,FPG->FPG_PVNUM)
						ENDIF
					EndIF
				NEXT _NX 

				// FRANK - 08/12/2020 - ATUALIZACAO DO CAMPO C6_XPERLOC
				FOR _NX := 1 TO LEN(_AITENSPV)

					_cPerLocx := ""
					IF SC6->(FIELDPOS("C6_XPERLOC")) > 0
						For _nP := 1 to len(_aItensPV[_nX])
							If alltrim(_aItensPV[_nX][_nP][01]) == "C6_XPERLOC"
								_cPerLocx := _aItensPV[_nX][_nP][02]
							EndIf
						Next
					EndIF

					SC6->(DBSETORDER(1))
					IF SC6->(DBSEEK(XFILIAL("SC6")+_CNUMPED+_AITENSPV[_NX][3][2]))
						IF SC6->(FIELDPOS("C6_XPERLOC")) > 0 
							SC6->(RECLOCK("SC6",.F.))
							SC6->C6_XPERLOC := _cPerlocx //_AITENSPV[_NX][17][2]
							SC6->(MSUNLOCK())
						EndIF
					ENDIF
					If _MV_LOC278 //supergetmv("MV_LOCX278",,.T.)
						DELTITPR()
					EndIf
				NEXT 
	
	
				IF _LCJATFIM //EXISTBLOCK("LCJATFIM")
					EXECBLOCK("LCJATFIM" , .T. , .T. , NIL) 
				ENDIF
			ENDIF
			_NREG := 0
		ENDIF

		IF len(_AITENSPV) > 0 //_NREG > 0 .and. !lGeraPVx
			IF _LOCA061Z //EXISTBLOCK("LOCA061Z") 
				EXECBLOCK("LOCA061Z" , .T. , .T. , {_ACABPV,_AITENSPV,_AZC1FAT,lGeraPVx}) 
			ENDIF 
		EndIF

	ENDDO
	
	TRBFPG->(DBCLOSEAREA())
ENDIF			// IF CPAR11 == 2 .OR. CPAR11 == 3 				// 2 - CUSTOS EXTRAS / 3 - AMBOS 

// FRANK FUGA - 21/10/2020
// GERACAO DA COBRANCA DA PRO-RATA NO CASO DE NOTA FISCAL DEVOLVIDA PARCIALMENTE
IF CPAR11 == 1 .OR. CPAR11 == 3 // LOCACAO
	IF SELECT("TMPFQZ") > 0
		TMPFQZ->( DBCLOSEAREA() )
	ENDIF
	_CQUERY := " SELECT FQZ.R_E_C_N_O_ AS REG, FQZ.FQZ_PROJET "
	_CQUERY += " FROM "+RETSQLNAME("FQZ")+ " FQZ (NOLOCK) "
	_CQUERY += " WHERE  FQZ.FQZ_FILIAL  = '"+XFILIAL("FQZ")+"' "
	_CQUERY += "   AND  FQZ.FQZ_PROJET BETWEEN '"+ CPAR09 +"' AND '"+ CPAR10 +"' "
	_CQUERY += "   AND  FQZ.FQZ_DTINI  >= '"+ DTOS(DPAR01) +"' "
	_CQUERY += "   AND (FQZ.FQZ_DTFIM  <> '' OR FQZ.FQZ_DTFIM <= '"+ DTOS(DPAR02) +"') "
	_CQUERY += "   AND  FQZ.FQZ_PV   = '' "
	_CQUERY += "   AND  FQZ.FQZ_MSBLQL  = '2' "
	_CQUERY += "   AND  FQZ.D_E_L_E_T_ = '' "
	_CQUERY += " ORDER BY FQZ.FQZ_PROJET "
	_CQUERY := CHANGEQUERY(_CQUERY)
	TCQUERY _CQUERY NEW ALIAS "TRBFQZ"

	_CTEMP    := ""
	_ACABPV   := {}
	_CNATUREZ := _MV_LOC065 //GETMV("MV_LOCX065")
	_NREGX    := 0
		
	WHILE !TRBFQZ->(EOF())
		FQZ->(DBGOTO(TRBFQZ->REG))
		_NREGX := TRBFQZ->REG
		IF TRBFQZ->FQZ_PROJET <> _CTEMP

			FPA->(DBSETORDER(3))
			FPA->(DBSEEK(XFILIAL("FPA")+FQZ->FQZ_AS))
			
			If !_lJob .and. _lTem14 // se não for job e existe o pergunte da selecao
				If cPar14 == 2 // Se optou por selecionar os contratos para faturamento
					If cPar11 == 1 // Se optou por locação
						_lSelecao := .F.
						If len(_aSelecao) > 0
							For _nX:=1 to len(_aSelecao)
								If _aSelecao[_nX][1] == FPA->(Recno())
									_lSelecao := .T.
									Exit
								EndIF
							Next
						EndIF
						If !_lSelecao
							TRBFQZ->(dbSkip())
							Loop
						EndIF
					EndIF
				EndIF
			EndIF
			If !_lJob .and. _lTem14 // se não for job e existe o pergunte da selecao
				If cPar14 == 2 // Se optou por selecionar os contratos para faturamento
					If cPar11 == 2 // Se optou por custo extra
						_lSelecao := .F.
						If len(_aSeleca2) > 0
							For _nX:=1 to len(_aSeleca2)
								If _aSeleca2[_nX][2] == FPA->(Recno())
									_lSelecao := .T.
									Exit
								EndIF
							Next
						EndIF
						If !_lSeleca2
							TRBFQZ->(dbSkip())
							Loop
						EndIF
					EndIF
				EndIF
			EndIF

			_CTEMP := TRBFQZ->FQZ_PROJET	
			_CNUMPED := GETSXENUM("SC5","C5_NUM") 
			CONFIRMSX8()
			WHILE .T.
				SC5->(DBSETORDER(1))
				IF SC5->( DBSEEK(XFILIAL("SC5") + _CNUMPED) )
					_CNUMPED := GETSXENUM("SC5","C5_NUM")
					CONFIRMSX8()
					LOOP
				ELSE
					EXIT
				ENDIF
			ENDDO

			FPA->(DBSETORDER(3))
			FPA->(DBSEEK(XFILIAL("FPA")+FQZ->FQZ_AS))
			FP0->(DBSETORDER(1))
			FP0->(DBSEEK(XFILIAL("FP0")+TRBFQZ->FQZ_PROJET))
			_CPAGTO := FPA->FPA_CONPAG

			//AADD(_ACABPV , {"C5_FILIAL"  , XFILIAL("SC5")        , NIL})
			AADD(_ACABPV , {"C5_NUM"     , _CNUMPED              , NIL})
			AADD(_ACABPV , {"C5_TIPO"    , "N"                   , NIL})
			AADD(_ACABPV , {"C5_CLIENTE" , FP0->FP0_CLI          , NIL})
			AADD(_ACABPV , {"C5_LOJACLI" , FP0->FP0_LOJA         , NIL})
			AADD(_ACABPV , {"C5_CODTAB"  , FPA->FPA_CODTAB       , NIL})
			AADD(_ACABPV , {"C5_CONDPAG" , _CPAGTO               , NIL})
			AADD(_ACABPV , {"C5_VEND1"   , FP0->FP0_VENDED       , NIL})
			If SC5->(FIELDPOS("C5_XPROJET")) > 0 
				AADD(_ACABPV , {"C5_XPROJET" , FP0->FP0_PROJET       , NIL})
			EndIF
			If SC5->(FIELDPOS("C5_XTIPFAT")) > 0 
				AADD(_ACABPV , {"C5_XTIPFAT" , "P"                   , NIL}) // P=PADRAO, M=MEDICAO
			EndIF
			AADD(_ACABPV , {"C5_NATUREZ" , _CNATUREZ             , NIL})
			AADD(_ACABPV , {"C5_MOEDA"   , FP0->FP0_MOEDA        , NIL})

			_AITENSPV := {}
			IF SELECT("TMPFQZ2") > 0
				TMPFQZ2->( DBCLOSEAREA() )
			ENDIF
			_CQUERY := " SELECT FQZ.R_E_C_N_O_ AS REG, FQZ.FQZ_PROJET "
			_CQUERY += " FROM "+RETSQLNAME("FQZ")+ " FQZ (NOLOCK) "
			_CQUERY += " WHERE  FQZ.FQZ_FILIAL  = '"+XFILIAL("FQZ")+"' "
			_CQUERY += "   AND  FQZ.FQZ_PROJET = '"+TRBFQZ->FQZ_PROJET+"'"
			_CQUERY += "   AND  FQZ.FQZ_DTINI  >= '"+ DTOS(DPAR01) +"' "
			_CQUERY += "   AND  FQZ.FQZ_PERPRO > 0 AND FQZ.FQZ_VLRPRO > 0 "
			_CQUERY += "   AND (FQZ.FQZ_DTFIM  <> '' OR FQZ.FQZ_DTFIM <= '"+ DTOS(DPAR02) +"') "
			_CQUERY += "   AND  FQZ.FQZ_PV   = '' "
			_CQUERY += "   AND  FQZ.FQZ_MSBLQL  = '2' "
			_CQUERY += "   AND  FQZ.D_E_L_E_T_ = '' "
			_CQUERY += " ORDER BY FQZ.FQZ_PROJET "
			_CQUERY := CHANGEQUERY(_CQUERY)
			TCQUERY _CQUERY NEW ALIAS "TRBFQZ2"
			_AREGFQZ := {}
			WHILE !TRBFQZ2->(EOF())
				_AITEMTEMP := {}
				FQZ->(DBGOTO(TRBFQZ2->REG))

				SB1->(DBSETORDER(1))
				SB1->(DBSEEK(XFILIAL("SB1")+FQZ->FQZ_COD))
				FPA->(DBSETORDER(3))
				FPA->(DBSEEK(XFILIAL("FPA")+FQZ->FQZ_AS))
				FP0->(DBSETORDER(1))
				FP0->(DBSEEK(XFILIAL("FP0")+FQZ->FQZ_PROJET))

				_nGeraC6 := 1
				_lGeraC6 := .T.
				// Regra 1: para não ser considerado o registro como retorno parcial
				// a mesma AS não pode haver registros repetidos na FQZ
				FQZ->(dbSetOrder(2))
				FQZ->(dbSeek(xFilial("FQZ")+FP0->FP0_PROJET))
				While !FQZ->(Eof()) .and. FQZ->FQZ_FILIAL+FQZ->FQZ_PROJET == xFilial("FQZ")+FP0->FP0_PROJET
					If FQZ->(Recno()) <> TRBFQZ2->REG .and. alltrim(FQZ->FQZ_AS) == alltrim(FPA->FPA_AS) .and. FQZ->FQZ_MSBLQL == "2"
						_nGeraC6 ++
					EndIF
					FQZ->(dbSkip())
				EndDo
				FQZ->(DBGOTO(TRBFQZ2->REG))
				FQZ->(dbSetOrder(1))
				

				// Regra 2 para não ser considerado o registro como retorno parcial
				// Se a quantidade devolvida é a mesma que a quantidade da FQA e o retorno da regra 1 foi positivo
				// ignorar o registro.
				If _nGeraC6 == 1
					If FPA->FPA_QUANT == FQZ->FQZ_QTD
						_lGeraC6 := .F.
					EndIF
				EndIF

				If !_lGeraC6
					TRBFQZ2->(DBSKIP())
					Loop
				EndIF
				// RECALCULAR NO MOMENTO DO FATURAMENTO
				/*
				FQZ->(RECLOCK("FQZ",.F.))
				FQZ->FQZ_VLRUNI := FPA->FPA_PRCUNI
				FQZ->FQZ_ULTFAT := FPA->FPA_ULTFAT
				FQZ->FQZ_DTINI  := FPA->FPA_DTINI
				FQZ->FQZ_DTFIM  := FPA->FPA_DTFIM
				FQZ->FQZ_VLRTOT := FQZ->FQZ_QTD * FPA->FPA_PRCUNI
				IF !EMPTY(FQZ->FQZ_ULTFAT)
					FQZ->FQZ_PERPRO := FQZ->FQZ_RETIRA - FQZ->FQZ_ULTFAT
				ELSE
					FQZ->FQZ_PERPRO := FQZ->FQZ_RETIRA - FQZ->FQZ_DTINI
				ENDIF
				FQZ->FQZ_VLRPRO := (FQZ->FQZ_VLRTOT * FQZ->FQZ_PERPRO) / IF(FPA->FPA_LOCDIA==0,1,FPA->FPA_LOCDIA)
				FQZ->(MSUNLOCK())
				*/

				AADD(_AREGFQZ,{TRBFQZ2->REG})

				NITENS := STRZERO( LEN(_AITENSPV)+1 ,TAMSX3("C6_ITEM")[1])
				AADD(_AITEMTEMP , {"C6_NUM"     , _CNUMPED        , NIL})
				AADD(_AITEMTEMP , {"C6_FILIAL"  , XFILIAL("SC6")  , NIL})
				AADD(_AITEMTEMP , {"C6_ITEM"    , NITENS          , NIL})
				AADD(_AITEMTEMP , {"C6_PRODUTO" , FQZ->FQZ_COD , NIL})
				AADD(_AITEMTEMP , {"C6_DESCRI"  , SB1->B1_DESC , NIL})
				AADD(_AITEMTEMP , {"C6_QTDVEN"  , FQZ->FQZ_QTD  , NIL})
				AADD(_AITEMTEMP , {"C6_PRCVEN"  , FQZ->FQZ_VLRPRO / FQZ->FQZ_QTD        , NIL})
				AADD(_AITEMTEMP , {"C6_PRUNIT"  , FQZ->FQZ_VLRPRO / FQZ->FQZ_QTD        , NIL})
				AADD(_AITEMTEMP , {"C6_VALOR"   , FQZ->FQZ_VLRPRO        , NIL})
				//AADD(_AITEMTEMP , {"C6_TES"     , _CTESPRO        , NIL})
				If empty(FPA->FPA_TESFAT)
					AADD(_AITEMTEMP , {"C6_TES"     , _CTESPRO        , NIL})
				Else
					AADD(_AITEMTEMP , {"C6_TES"     , FPA->FPA_TESFAT , NIL})
				EndIF
				AADD(_AITEMTEMP , {"C6_QTDLIB"  , FQZ->FQZ_QTD  , NIL})
				AADD(_AITEMTEMP , {"C6_CC"      , FPA->FPA_CUSTO  , NIL})
				If SC6->(FIELDPOS("C6_XEXTRA")) > 0 
					AADD(_AITEMTEMP , {"C6_XEXTRA"  , "N"             , NIL})
				EndIF
				If SC6->(FIELDPOS("C6_XAS")) > 0 
					AADD(_AITEMTEMP , {"C6_XAS"     , FQZ->FQZ_AS   , NIL})
				EndIF
				If SC6->(FIELDPOS("C6_XBEM")) > 0 
					AADD(_AITEMTEMP , {"C6_XBEM"    , FPA->FPA_GRUA   , NIL})
				EndIf
				IF SC6->(FIELDPOS("C6_FROTA")) > 0
					AADD(_AITEMTEMP     , {"C6_FROTA"      , FPA->FPA_GRUA        , NIL})
				ENDIF
				IF SC6->(FIELDPOS("C6_XPERLOC")) > 0 
					_CPERLOC := DTOC(FPA->FPA_DTINI) + " A " + DTOC(FPA->FPA_DTFIM)

					IF _LOCA021D //EXISTBLOCK("LOCA021D")
						_cPerloc := EXECBLOCK("LOCA021D" , .T. , .T., {_CPERLOC} ) 
					ENDIF

					AADD(_AITEMTEMP     , {"C6_XPERLOC" , _CPERLOC              , NIL})
				ENDIF

				IF SC6->(FIELDPOS("C6_XCCUSTO")) > 0 
					AADD(_AITEMTEMP     , {"C6_XCCUSTO" , FPA->FPA_CUSTO        , NIL})
				ENDIF

				_NREG++
				NVALTOT += FQZ->FQZ_VLRTOT
	
				AADD( _AITENSPV , ACLONE(_AITEMTEMP) )
				TRBFQZ2->(DBSKIP())

			ENDDO
			TRBFQZ2->( DBCLOSEAREA() )		
			// GERAR O PV DA DEVOLUÇÃO PARCIAL.
			If len(_AITENSPV) > 0 .and. lGeraPVx

				// Sprint 3 - Frank Z Fuga - EAI - 04/10/22
				If !empty(GetMV("MV_LOCX299",,""))
					SetRotInteg("MATA410")
				EndIf

				MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)} , _ACABPV , _AITENSPV , 3) 
				IF LMSERROAUTO
					MOSTRAERRO()
				ELSE
				
					// FRANK - 08/12/2020 - ATUALIZACAO DO CAMPO C6_XPERLOC
					FOR _NX := 1 TO LEN(_AITENSPV)

						_cPerLocx := ""
						IF SC6->(FIELDPOS("C6_XPERLOC")) > 0
							For _nP := 1 to len(_aItensPV[_nX])
								If alltrim(_aItensPV[_nX][_nP][01]) == "C6_XPERLOC"
									_cPerLocx := _aItensPV[_nX][_nP][02]
								EndIf
							Next
						EndIF

						SC6->(DBSETORDER(1))
						IF SC6->(DBSEEK(XFILIAL("SC6")+_CNUMPED+_AITENSPV[_NX][3][2]))
							If SC6->(FIELDPOS("C6_XPERLOC")) > 0 
								SC6->(RECLOCK("SC6",.F.))
								SC6->C6_XPERLOC := _cPerLocx //_AITENSPV[_NX][17][2]
								SC6->(MSUNLOCK())
							EndIF
						ENDIF
					NEXT

					_NREGPR++
					AADD( APEDIDOS , SC5->C5_NUM ) 
					FOR _NX := 1 TO LEN(_AREGFQZ)
						FQZ->(DBGOTO(_AREGFQZ[_NX][1]))
						FQZ->(RECLOCK("FQZ",.F.))
						FQZ->FQZ_PV := SC5->C5_NUM
						FQZ->(MSUNLOCK())
					NEXT
					_AREGFQZ := {}

				ENDIF
			EndIf
			
		ENDIF
		TRBFQZ->(DBSKIP())
	ENDDO
	TRBFQZ->( DBCLOSEAREA() )

ENDIF


IF EXISTBLOCK("LCJLFFIM") 										// --> PONTO DE ENTRADA NO FINAL DO FATURAMENTO AUTOMATICO.
	//U_LCJLFFIM(CPAR09,CPAR10)
	EXECBLOCK("LCJLFFIM" , .T. , .T. , {CPAR09,CPAR10}) 
ENDIF

IF _NREGPR > 0
	CMSG := STR0046+ALLTRIM(STR(_NREGPR))+ " " + CRLF //"TOTAL DE REGISTROS PROCESSADOS: "
	ASORT(APEDIDOS,,,{|X,Y| X < Y })
	IF LEN(APEDIDOS) > 0
		CMSG += STR0047 + APEDIDOS[1] + STR0048+APEDIDOS[ LEN(APEDIDOS) ] + " "+ CRLF //"PRIMEIRO PEDIDO: "###" - ULTIMO PEDIDO: "
	ENDIF
	CMSG += STR0049+ ALLTRIM(STR(LEN(APEDIDOS))) + CRLF //"TOTAL DE PEDIDOS GERADOS: "
	CMSG += STR0050+ ALLTRIM( TRANSFORM(NVALTOT,"@E 999,999,999,999.99") ) //"VALOR: "
	IF ! _LJOB
	
		IF _LSEMLCJ .and. !empty(CARQLOCK)
			// --> CANCELA O LOCK DE GRAVACAO DA ROTINA.
			FCLOSE(NHDLLOCK)
			FERASE(CARQLOCK)
			NHDLLOCK := 0
		ENDIF

		AVISO(STR0051 , CMSG , {"OK"} , 2)  //"PROCESSAMENTO EXECUTADO COM SUCESSO!"
	ENDIF
ELSE
	IF ! _LJOB

		IF _LSEMLCJ .and. !empty(CARQLOCK)
			// --> CANCELA O LOCK DE GRAVACAO DA ROTINA.
			FCLOSE(NHDLLOCK)
			FERASE(CARQLOCK)
			NHDLLOCK := 0
		ENDIF

		MSGSTOP(STR0052 , STR0017)  //"NÃO EXISTEM REGISTROS PARA PROCESSAMENTO!"###"GPO - LCJLF001.PRW"
	ELSE
		//CONOUT("[LCJLF001.PRW] - NÃO EXISTEM REGISTROS PARA PROCESSAMENTO!") 
	ENDIF
ENDIF

//CONOUT("[LCJLF001.PRW] - PROCFAT() - GERAPV() - FINAL ") 

FPG->(RESTAREA(_AAREAZC1))
FPA->(RESTAREA(_AAREAZAG))
FP1->(RESTAREA(_AAREAZA1))
FP0->(RESTAREA(_AAREAZA0))
SC6->(RESTAREA(_AAREASC6))
SC5->(RESTAREA(_AAREASC5))
RESTAREA(_AAREAOLD)

RETURN NIL



/*/{PROTHEUS.DOC} GRAVANFS
@DESCRIPTION GERAÇÃO DE NOTA FISCAL DE SAÍDA.
@TYPE    FUNCTION
@AUTHOR  IT UP BUSINESS
@SINCE   16/09/2016
@VERSION 2.0
/*/
// ======================================================================= \\
STATIC FUNCTION GRAVANFS( _CPEDIDO )
// ======================================================================= \\

LOCAL   _AAREAOLD := GETAREA()
LOCAL   _AAREASC5 := SC5->(GETAREA())
LOCAL   _AAREASC6 := SC6->(GETAREA())
LOCAL   _AAREASC9 := SC9->(GETAREA())
LOCAL   _AAREASE4 := SE4->(GETAREA())
LOCAL   _AAREASB1 := SB1->(GETAREA())
LOCAL   _AAREASB2 := SB2->(GETAREA())
LOCAL   _AAREASF4 := SF4->(GETAREA())
LOCAL   _ATABAUX  := {}
LOCAL   _APVLNFS  := {}
LOCAL   _CQUERY   := ""
LOCAL   _CNOTA    := ""
LOCAL   _CSERIE   := GETMV("MV_LOCX024")

//CONOUT("[LCJLF001.PRW] - PROCFAT() - GERAPV() - GRAVANFS() - INICIO") 

PERGUNTE("MT460A",.F.)

_APVLNFS := {}

SC5->( DBSETORDER(1) )	// C5_FILIAL + C5_NUM
SC6->( DBSETORDER(1) )	// C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
SC9->( DBSETORDER(1) )	// C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO

IF SELECT("TRBNFR") > 0
	TRBNFR->(DBCLOSEAREA())
ENDIF
_CQUERY := " SELECT C9_PEDIDO PEDIDO , C9_ITEM   ITEM  , C9_SEQUEN  SEQUEN  , " + CRLF 
_CQUERY += "        C9_QTDLIB QUANT  , C9_PRCVEN VALOR , C9_PRODUTO PRODUTO , " + CRLF 
_CQUERY += "        SC9.R_E_C_N_O_ SC9RECNO, SC5.R_E_C_N_O_ SC5RECNO , "        + CRLF 
_CQUERY += "        SC6.R_E_C_N_O_ SC6RECNO, SE4.R_E_C_N_O_ SE4RECNO , "        + CRLF 
_CQUERY += "        SB1.R_E_C_N_O_ SB1RECNO, SB2.R_E_C_N_O_ SB2RECNO , "        + CRLF 
_CQUERY += "        SF4.R_E_C_N_O_ SF4RECNO "                                   + CRLF 
_CQUERY += " FROM " + RETSQLNAME("SC9") + " SC9 (NOLOCK) "                      + CRLF 
_CQUERY += "        INNER JOIN " + RETSQLNAME("SC6") + " SC6 (NOLOCK) ON  C6_FILIAL  = '" + XFILIAL("SC6") + "'"                + CRLF
_CQUERY += "                                                          AND C6_NUM     = C9_PEDIDO  AND C6_ITEM    = C9_ITEM "    + CRLF
_CQUERY += "                                                          AND C6_PRODUTO = C9_PRODUTO AND C6_BLQ NOT IN ('R','S') " + CRLF
_CQUERY += "                                                          AND SC6.D_E_L_E_T_ = '' "                                 + CRLF
_CQUERY += "        INNER JOIN " + RETSQLNAME("SC5") + " SC5 (NOLOCK) ON  C5_FILIAL  = '" + XFILIAL("SC5") + "'"                + CRLF
_CQUERY += "                                                          AND C5_NUM     = C6_NUM     AND SC5.D_E_L_E_T_ = '' "     + CRLF
_CQUERY += "        INNER JOIN " + RETSQLNAME("SE4") + " SE4 (NOLOCK) ON  E4_FILIAL  = '" + XFILIAL("SE4") + "'"                + CRLF
_CQUERY += "                                                          AND E4_CODIGO  = C5_CONDPAG AND SE4.D_E_L_E_T_ = '' "     + CRLF 
_CQUERY += "        INNER JOIN " + RETSQLNAME("SB1") + " SB1 (NOLOCK) ON  B1_FILIAL  = '" + XFILIAL("SB1") + "'"                + CRLF
_CQUERY += "                                                          AND B1_COD     = C6_PRODUTO AND SB1.D_E_L_E_T_ = '' "     + CRLF
_CQUERY += "        INNER JOIN " + RETSQLNAME("SB2") + " SB2 (NOLOCK) ON  B2_FILIAL  = '" + XFILIAL("SB2") + "'"                + CRLF
_CQUERY += "                                                          AND B2_COD     = C6_PRODUTO AND B2_LOCAL   = C6_LOCAL "   + CRLF
_CQUERY += "                                                          AND SB2.D_E_L_E_T_ = '' "                                 + CRLF
_CQUERY += "        INNER JOIN " + RETSQLNAME("SF4") + " SF4 (NOLOCK) ON  F4_FILIAL  = '" + XFILIAL("SF4") + "'"                + CRLF
_CQUERY += "                                                          AND F4_CODIGO  = C6_TES     AND SF4.D_E_L_E_T_ = '' "     + CRLF
_CQUERY += " WHERE  C9_FILIAL  = '" + XFILIAL("SC9") + "'"                      + CRLF
_CQUERY += "   AND  C9_PEDIDO  = '" + _CPEDIDO + "'"                            + CRLF
_CQUERY += "   AND  C9_NFISCAL = ''"                                            + CRLF
_CQUERY += "   AND  SC9.D_E_L_E_T_ = ''"                                        + CRLF
_CQUERY += " ORDER BY PEDIDO , ITEM , SEQUEN , PRODUTO " 
_CQUERY := CHANGEQUERY(_CQUERY)	
//CONOUT("[LCJLF001.PRW] # _CQUERY(6): " + _CQUERY) 

TCQUERY _CQUERY NEW ALIAS "TRBNFR"

WHILE TRBNFR->(!EOF())
	_ATABAUX := {}

	AADD( _ATABAUX , TRBNFR->PEDIDO   )
	AADD( _ATABAUX , TRBNFR->ITEM     )
	AADD( _ATABAUX , TRBNFR->SEQUEN   )
	AADD( _ATABAUX , TRBNFR->QUANT    )
	AADD( _ATABAUX , TRBNFR->VALOR    )
	AADD( _ATABAUX , TRBNFR->PRODUTO  )
	AADD( _ATABAUX , .F.              )
	AADD( _ATABAUX , TRBNFR->SC9RECNO )
	AADD( _ATABAUX , TRBNFR->SC5RECNO )
	AADD( _ATABAUX , TRBNFR->SC6RECNO )
	AADD( _ATABAUX , TRBNFR->SE4RECNO )
	AADD( _ATABAUX , TRBNFR->SB1RECNO )
	AADD( _ATABAUX , TRBNFR->SB2RECNO )
	AADD( _ATABAUX , TRBNFR->SF4RECNO )

	AADD( _APVLNFS , ACLONE(_ATABAUX) )

	TRBNFR->(DBSKIP())
ENDDO

TRBNFR->(DBCLOSEAREA())

DBSELECTAREA( "SC9" )

IF LEN(_APVLNFS) > 0
	IF EXISTBLOCK("LCJSER") 									// --> PONTO DE ENTRADA PARA ALTERAÇÃO DA SÉRIE.
		_CSERIE := EXECBLOCK("LCJSER" , .T. , .T. , {_CSERIE}) 
	ENDIF

	_CNOTA := MAPVLNFS(_APVLNFS , _CSERIE , .F. , .F. , .F. , .T. , .F. , 0 , 0 , .T. , .F.) 

	PUTGLBVALUE("CNF_PAR" , _CNOTA) 							// --> ALIMENTA NO. DA NF
ENDIF

SF4->(RESTAREA( _AAREASF4 ))
SB2->(RESTAREA( _AAREASB2 ))
SB1->(RESTAREA( _AAREASB1 ))
SE4->(RESTAREA( _AAREASE4 ))
SC9->(RESTAREA( _AAREASC9 ))
SC6->(RESTAREA( _AAREASC6 ))
SC5->(RESTAREA( _AAREASC5 ))
RESTAREA( _AAREAOLD )

RETURN _CNOTA



/*/{PROTHEUS.DOC} PRIMFAT
@DESCRIPTION VERIFICA SE É O PRIMEIO FATURAMENTO DA AS.
@TYPE    FUNCTION
@AUTHOR  IT UP BUSINESS
@SINCE   24/10/2016
@VERSION 1.0
/*/
// ======================================================================= \\
STATIC FUNCTION PRIMFAT(_CNRAS) 
// ======================================================================= \\

LOCAL   _LRET   := .T. 
LOCAL   _CQUERY := "" 

IF SC6->(FIELDPOS("C6_XAS")) > 0
	IF SELECT("TRBPRI") > 0
		TRBPRI->(DBCLOSEAREA())
	ENDIF
	_CQUERY := " SELECT C6_XAS "                                        + CRLF
	_CQUERY += " FROM " + RETSQLNAME("SC6") + " SC6 (NOLOCK) "          + CRLF
	_CQUERY +=        " INNER JOIN "+RETSQLNAME("SC5")+" SC5 (NOLOCK) " + CRLF
	_CQUERY +=                   " ON  SC5.C5_FILIAL  = SC6.C6_FILIAL " + CRLF
	_CQUERY +=                   " AND SC5.C5_NUM     = SC6.C6_NUM    " + CRLF
	If SC5->(FIELDPOS("C5_XTIPFAT")) > 0 
		_CQUERY +=                   " AND SC5.C5_XTIPFAT = 'P' "           + CRLF
	EndIf
	_CQUERY +=                   " AND SC5.D_E_L_E_T_ = '' "            + CRLF
	_CQUERY += " WHERE  SC6.D_E_L_E_T_ = '' "                           + CRLF
	_CQUERY +=   " AND  SC6.C6_XAS     = '" + _CNRAS + "' "             + CRLF
	_CQUERY +=   " AND  SC6.C6_BLQ NOT IN ('R','S') "                   + CRLF
	_CQUERY +=   " AND  SC6.C6_FILIAL  = '"+XFILIAL("SC6")+"' "         + CRLF
	_CQUERY := CHANGEQUERY(_CQUERY)	
	//CONOUT("[LCJLF001.PRW] # _CQUERY(7): " + _CQUERY) 

	TCQUERY _CQUERY NEW ALIAS "TRBPRI"

	IF TRBPRI->(!EOF())
		_LRET := .F. 
	ENDIF

	TRBPRI->(DBCLOSEAREA())
EndIf

RETURN _LRET



/*/{PROTHEUS.DOC} VALPRATA
@DESCRIPTION RETORNA VALOR A SER FATURADO COM DEVOLUCOES PARCIAIS.
@TYPE    FUNCTION
@AUTHOR  IT UP BUSINESS
@SINCE   08/03/2019
@VERSION 1.0
/*/
// ======================================================================= \\
STATIC FUNCTION VALPRATA(_CAS , _DDTINI , _DDTFIM , _NQUANT , _NVALBRUT) 
// ======================================================================= \\

//LOCAL   _AAREAOLD := GETAREA()
//LOCAL   _CQUERY   := ""
//LOCAL   _DULTDT   := STOD("")
//LOCAL   _NQTDATU  := 0
LOCAL   _NRET     := 0
//LOCAL   _NVALDIA  := 0
/*
DEFAULT _CAS      := ""
DEFAULT _DDTINI   := STOD("")
DEFAULT _DDTFIM   := STOD("")
DEFAULT _NQUANT   := 0
DEFAULT _NVALBRUT := 0

_NVALDIA := _NVALBRUT / (_DDTFIM - _DDTINI + 1)
_DULTDT  := _DDTINI

IF SC6->(FIELDPOS("C6_XAS")) > 0
	IF SELECT("TRBSD1") > 0
		TRBSD1->(DBCLOSEAREA())
	ENDIF

	_CQUERY := " SELECT '" + DTOS(_DDTINI-1) + "' D1_EMISSAO , '' D1_DOC , '' D1_SERIE , '' D1_ITEM , SUM(D1_QUANT) D1_QUANT " + CRLF
	_CQUERY += " FROM " + RETSQLNAME("SC6") + " SC6 "                                                                          + CRLF
	_CQUERY += "         INNER JOIN " + RETSQLNAME("SC5") + " SC5 ON  C5_FILIAL  = C6_FILIAL AND C5_NUM     = C6_NUM  "        + CRLF 
	If SC5->(FIELDPOS("C5_XTIPFAT")) > 0 
		_CQUERY += " AND C5_XTIPFAT = 'R'       AND SC5.D_E_L_E_T_ = ''  "        + CRLF 
	Else
		_CQUERY += " AND SC5.D_E_L_E_T_ = ''  "        + CRLF 
	EndIF
	_CQUERY += "         INNER JOIN " + RETSQLNAME("SD2") + " SD2 ON  D2_FILIAL  = C6_FILIAL AND D2_PEDIDO  = C6_NUM  "        + CRLF
	_CQUERY += "                                                  AND D2_ITEMPV  = C6_ITEM   AND D2_DOC     = C6_NOTA "        + CRLF
	_CQUERY += "                                                  AND D2_SERIE   = C6_SERIE  AND SD2.D_E_L_E_T_ = ''  "        + CRLF
	_CQUERY += "         INNER JOIN " + RETSQLNAME("SD1") + " SD1 ON  D1_FILIAL  = D2_FILIAL AND D1_NFORI   = D2_DOC  "        + CRLF
	_CQUERY += "                                                  AND D1_SERIORI = D2_SERIE  AND D1_ITEMORI = D2_ITEM "        + CRLF
	_CQUERY += "                                                  AND D1_EMISSAO BETWEEN '"+DTOS(_DDTINI)+"' AND '"+DTOS(_DDTFIM)+"'" + CRLF
	_CQUERY += "                                                  AND SD1.D_E_L_E_T_ = '' "                                    + CRLF
	_CQUERY += " WHERE   C6_XAS = '" + _CAS + "'" + CRLF
	_CQUERY += "   AND   SC6.D_E_L_E_T_ = ''" + CRLF

	_CQUERY += "  UNION ALL " + CRLF

	_CQUERY += " SELECT  D1_EMISSAO , D1_DOC , D1_SERIE , D1_ITEM , D1_QUANT"                                                  + CRLF
	_CQUERY += " FROM " + RETSQLNAME("SC6") + " SC6 "                                                                          + CRLF
	_CQUERY += "         INNER JOIN " + RETSQLNAME("SC5") + " SC5 ON  C5_FILIAL  = C6_FILIAL AND C5_NUM     = C6_NUM  "        + CRLF
	If SC5->(FIELDPOS("C5_XTIPFAT")) > 0 
		_CQUERY += " AND C5_XTIPFAT = 'R'       AND SC5.D_E_L_E_T_ = ''  "        + CRLF
	Else
		_CQUERY += " AND SC5.D_E_L_E_T_ = ''  "        + CRLF
	EndIF
	_CQUERY += "         INNER JOIN " + RETSQLNAME("SD2") + " SD2 ON  D2_FILIAL  = C6_FILIAL AND D2_PEDIDO  = C6_NUM  "        + CRLF 
	_CQUERY += "                                                  AND D2_ITEMPV  = C6_ITEM   AND D2_DOC     = C6_NOTA "        + CRLF
	_CQUERY += "                                                  AND D2_SERIE   = C6_SERIE  AND SD2.D_E_L_E_T_ = ''  "        + CRLF
	_CQUERY += "         INNER JOIN " + RETSQLNAME("SD1") + " SD1 ON  D1_FILIAL  = D2_FILIAL AND D1_NFORI   = D2_DOC  "        + CRLF
	_CQUERY += "                                                  AND D1_SERIORI = D2_SERIE  AND D1_ITEMORI = D2_ITEM "        + CRLF
	_CQUERY += "                                                  AND D1_EMISSAO BETWEEN '"+DTOS(_DDTINI)+"' AND '"+DTOS(_DDTFIM)+"'" + CRLF
	_CQUERY += "                                                  AND SD1.D_E_L_E_T_ = '' "                                    + CRLF
	_CQUERY += " WHERE   C6_XAS = '" + _CAS + "' "                                                                             + CRLF
	_CQUERY += "   AND   SC6.D_E_L_E_T_ = '' "                                                                                 + CRLF

	_CQUERY += " ORDER BY D1_EMISSAO " 
	_CQUERY := CHANGEQUERY(_CQUERY)	
	//CONOUT("[LCJLF001.PRW] # _CQUERY(8): " + _CQUERY) 

	TCQUERY _CQUERY NEW ALIAS "TRBSD1"

	WHILE TRBSD1->(!EOF()) .AND. !EMPTY(FPA->FPA_NFRET)
		IF STOD(TRBSD1->D1_EMISSAO) < _DULTDT
			_NQTDATU := _NQUANT - TRBSD1->D1_QUANT
			_NVALDIA := _NVALDIA * _NQTDATU / _NQUANT
		ELSE
			_NRET    += _NVALDIA * (STOD(TRBSD1->D1_EMISSAO) - _DULTDT + 1)
			_DULTDT  := STOD(TRBSD1->D1_EMISSAO)
			_NQTDATU := _NQTDATU - TRBSD1->D1_QUANT
			_NVALDIA := _NVALDIA * _NQTDATU / _NQUANT
		ENDIF
		TRBSD1->(DBSKIP()) 
	ENDDO

	TRBSD1->(DBCLOSEAREA()) 
EndIf

IF _DULTDT < _DDTFIM 
	_NRET    += _NVALDIA * (_DDTFIM - _DULTDT + 1) 
ENDIF 

RESTAREA( _AAREAOLD ) 

IF !EMPTY(FPA->FPA_NFRET)
	_NRET := 0
ENDIF
*/
RETURN _NRET



/*/{PROTHEUS.DOC} CRIASX1
@DESCRIPTION CRIA PERGUNTE DO FATURAMENTO AUTOMATICO.
@TYPE    FUNCTION
/*/
STATIC FUNCTION CRIASX1()
RETURN NIL


/*/{PROTHEUS.DOC} VALPROC
@DESCRIPTION FUNÇÃO PARA VALIDAR SE PODE REALIZAR O PROCESSAMENTO E CHAMADA DO PONTO DE ENTRADA LCJF1CLD
@TYPE    FUNCTION
@AUTHOR  IT UP BUSINESS
/*/
// ======================================================================= \\
STATIC FUNCTION VALPROC()
// ======================================================================= \\
LOCAL LRET := .T.

IF LRET .AND. EXISTBLOCK("LCJF1VLD")							// --> PONTO DE ENTRADA PARA VALIDACAO DE GERACAO DA FATURA AUTOMATICO.
	LRET := EXECBLOCK("LCJF1VLD" , .T. , .T. , NIL) 
ENDIF

RETURN LRET


// Rotina para verificar se tem que deletar o movimento da pro-rata
// neste momento estamos posicionados na linha da SC6.
Function DELTITPR()
Local _cAs 
Local _cQuery
Local _nReg
Local _aArea := GetArea()

IF SC6->(FIELDPOS("C6_XAS")) > 0
	_cAs := SC6->C6_XAS

	_cQuery := " SELECT FPA.R_E_C_N_O_ AS REG " 
	_cQuery += " FROM " + RETSQLNAME("FPA") + " FPA "
	_cQuery += " WHERE FPA.FPA_FILEMI = '"+xFilial("FPA")+"' "
	_cQuery += " AND FPA.FPA_AS = '"+_cAs+"' "
	_cQuery += " AND FPA.D_E_L_E_T_ = '' "
	IF SELECT("TRBVLD") > 0
		TRBVLD->(DBCLOSEAREA())
	ENDIF
	TCQUERY _CQUERY NEW ALIAS "TRBVLD"
	If !TRBVLD->(Eof())
		_nReg := TRBVLD->REG
	EndIF
	TRBVLD->(DBCLOSEAREA())

	If _nReg > 0 
		FPA->(dbGoto(_nReg))

		FQB->(dbSetOrder(1))
		FQB->(dbSeek(xFilial("FQB")+FPA->FPA_PROJET+FPA->FPA_AS))

		While !FQB->(Eof()) .and. FQB->(FQB_FILIAL+FQB_PROJET+FQB_AS) == xFilial("FQB")+FPA->FPA_PROJET+FPA->FPA_AS

			//If alltrim(str(month(SC5->C5_EMISSAO)))+alltrim(str(year(SC5->C5_EMISSAO))) == alltrim(str(month(FQB->FQB_PERIOD)))+alltrim(str(year(FQB->FQB_PERIOD)))
			// alterado pelo card 209 - frank em 03/01/22
			If alltrim(str(month(FPA->FPA_ULTFAT)))+alltrim(str(year(FPA->FPA_ULTFAT))) == alltrim(str(month(FQB->FQB_PERIOD)))+alltrim(str(year(FQB->FQB_PERIOD)))

				SE1->(dbSetOrder(1))
				SE1->(dbSeek(xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR)) 

				While !SE1->(Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR
					If SE1->E1_PARCELA == FQB->FQB_PARC
						SE1->(RecLock("SE1",.F.))
						SE1->(dbDelete())
						SE1->(MsUnlock())
					EndIF
					SE1->(dbSkip())
				EndDo

				FQB->(RecLock("FQB",.F.))
				FQB->(dbDelete())
				FQB->(MsUnlock())
			EndIF

			FQB->(dbSkip())
		EndDo

	EndIF
EndIF
RestArea(_aArea)
Return .T.


// Como testar a rotina automatica da geracao do faturamento automatico
// Frank Z Fuga - 16/09/21
/*
Function LOCA021Y
Local _aParam 	:= {SM0->M0_CODIGO,SM0->M0_CODFIL}	// Empresa e filial da execução 
Local _CPRJINI  := "202110255             "			// Contrato inicial
Local _CPRJFIM	:= "202110255             "			// Contrato final
Local _APRJAS	:= {"3010255001001010101        "}	// As que serão processadas
Local _lGeraPVx	:= .T.								// Se gera o pedido de vendas
Local _nTipoF   := 3 // 1=Locação, 2=Custo Extra, 3=Ambos
LOCA021(_APARAM , _CPRJINI , _CPRJFIM , _APRJAS, _lGeraPVx, _nTipoF) 
Return
*/



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ MARCARREGIº AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ FUNÇÃO AUXILIAR DO LISTBOX, SERVE PARA MARCAR E DESMARCAR  º±±
±±º          ³ OS ITENS.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION MARCARREGI(LTODOS)

LOCAL NI        := 0 
LOCAL LMARCADOS := _ASZ1[OFILOS:NAT,1]

IF LTODOS
	LMARCADOS := ! LMARCADOS
	FOR NI := 1 TO LEN(_ASZ1)
		_ASZ1[NI,1] := LMARCADOS
	NEXT NI 
ELSE
	_ASZ1[OFILOS:NAT,1] := !LMARCADOS
ENDIF

OFILOS:REFRESH()
ODLGFIL:REFRESH()
	
RETURN NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} LC007DOC
@description	Chama MsDocument
@author			José Eulálio
@version   		1.00
@since     		16/11/2021
/*/			
//-------------------------------------------------------------------
STATIC FUNCTION LC007DOC()
ItupDocs("FPG", FPG->(Recno()))
RETURN
