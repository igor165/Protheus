#INCLUDE "loca043.ch" 
/*/{PROTHEUS.DOC} LOCA043.PRW
ITUP BUSINESS - TOTVS RENTAL
TELA - OPERACIONAL  VALE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "RWMAKE.CH"                                            
#INCLUDE "TOPCONN.CH"                                                                                    
#INCLUDE "PROTHEUS.CH"                                               

FUNCTION LOCA043()
LOCAL AAREAZA1 := GETAREA()                          																	// AAREASZ5 := GETAREA() 
LOCAL ACORES   := { {'FPH_APROVA == .F.  .AND. (EMPTY(FPH_NRBV) .OR. LEN(ALLTRIM(FPH_NRBV))==0 ) ',	'BR_AMARELO'},;		// SEM APROVACAO SEM BV
					{'FPH_APROVA == .F.  .AND. !EMPTY(FPH_NRBV)',	'BR_VERDE'	},;										// SEM APROVACAO COM BV
					{'FPH_APROVA == .T.  .AND. (EMPTY(FPH_NRBV) .OR. LEN(ALLTRIM(FPH_NRBV))==0 ) ',	'BR_VERMELHO'},;	// APROVADO SEM BV
					{'FPH_APROVA == .T.  .AND. !EMPTY(FPH_NRBV)',	'BR_AZUL'	}}  									// APROVADO COM BV 
					 	
PRIVATE CCADASTRO := STR0001 //"ADIANTAMENTO VIAGEM"
PRIVATE AROTINA   := { {STR0002	  , "AXPESQUI"          , 0 , 1} , ;        //"PESQUISAR"
					   {STR0003  , "AXVISUAL"          , 0 , 2} , ; //"VISUALIZAR"
		               {STR0004	  , "LOCA04301"        , 0 , 3} , ; //"INCLUIR"
		               {STR0005	  , "LOCA04303"        , 0 , 4} , ;                                     //"ALTERAR"
		               {STR0006	  , "LOCA04304(RECNO())" , 0 , 5} , ; //"EXCLUIR"
		               {STR0007	  , "LOCA039()"       , 0 , 5} , ; //"ESTORNAR"
					   {STR0008 , "LOCR007('Y')"    , 0 , 6} , ;  //"IMP. RECIBO"
					   {"___________" , "LOCR014()"      , 0 , 8} , ;  
					   {STR0009	  , "LOCA04305()"      , 0 , 9} }  //"LEGENDA"
                                                
// --> VARIAVEIS DE CONTROLE NAS ROTINAS DE OPERACAO 
PRIVATE LINCLUI  := .F. 
PRIVATE LALTERA  := .F. 
PRIVATE LESCLUI  := .F. 
PRIVATE LESTORNA := .F. 

PUBLIC _CUSER    := RETCODUSR(SUBSTR(CUSUARIO,7,15))  //RETORNA O CÓDIGO DO USUÁRIO

//IF !LOCA061() 							// --> VALIDAÇÃO DO LICENCIAMENTO (WS) DO GPO 
	//RETURN 
//ENDIF 

SET KEY VK_F4 TO LOCR007(FPH->FPH_NRVALE)
  
DBSELECTAREA("FPH")
DBSETORDER(1)					 	

MBROWSE(6 , 1 , 22 , 75 , "FPH" , , , , , , ACORES) 

SET KEY VK_F4 TO

RESTAREA(AAREAZA1)                

RETURN NIL
    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ AXINCZL1  º AUTOR ³ IT UP BUSINESS     º DATA ³ 01/01/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ ROTINA DE MANUTENCAO DE CADASTRO DE SERVICOS - "INCLUIR"   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LOCA04301() 

LOCAL LRET     := .T.
//LOCAL _CUSER := RETCODUSR(SUBSTR(CUSUARIO,7,15)) 			// RETORNA O CÓDIGO DO USUÁRIO

PRIVATE CMOTOR 

PUBLIC _CTIPAD	:= ""
                      
LINCLUI := .T.

// VALIDA OS ACESSOS DO USUÁRIO
CMOTOR := FPH->FPH_MOTORI
FQ1->(DBSETORDER(1))
IF FQ1->(DBSEEK(XFILIAL("FQ1") + _CUSER + "LOCA044",.T.)) 	// PROCURA O CÓDIGO DE USUÁRIO NA TABELA DE USUÁRIOS ANALIZADORES DE PROMOÇÕES (SZ5)
	_CTIPAD += ALLTRIM(FQ1->FQ1_CC)							// ADICIONO TODOS OS TIPOS QUE O USUÁRIO PODE APROVAR
	IF LOCA04307()	
		AXINCLUI("FPH", , , , , ,"LOCA04302()")
	ELSE
		MSGINFO(STR0010 , STR0011) //"EXISTE VALOR PENDENTE DO ULTIMO B.V PARA ESTE MOTORISTA!"###"GPO - LOCT001.PRW"
		LRET := .F.
	ENDIF
ELSE
	MSGALERT(STR0012 , STR0011) //"ATENÇÃO: USUARIO NÃO AUTORIZADO A LANÇAR ADIANTAMENTOS DE VIAGEM."###"GPO - LOCT001.PRW"
	LRET := .F.
ENDIF

LINCLUI := .F.

RETURN LRET        



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ LC001TUDOK º AUTOR ³ IT UP BUSINESS      º DATA ³ 01/01/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ VALIDA A INCLUSÃO/ALTERAÇÃO DO VALE                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LOCA04302()

LOCAL _LRET := .F.

FPI->(DBSETORDER(1))
FPI->(DBSEEK(XFILIAL("FPI") + M->FPH_NRBV))

IF !FPI->(EOF()) .AND. ALLTRIM(M->FPH_TIPAD) <> ALLTRIM(FPI->FPI_DEPTO)
	MSGALERT(STR0013 , STR0011)  //"NÃO SERÁ  POSSIVEL EFETUAR A INCLUSÃO / ALTERAÇÃO DOS REGISTROS, VERIFIQUE SE O CAIXA ESTA CORRETO EM RELAÇÃO A BV!"###"GPO - LOCT001.PRW"
	_LRET := .F.
ELSE
	_LRET := .T.
ENDIF

RETURN _LRET



// ======================================================================= \\
FUNCTION LOCA04303() 
// ======================================================================= \\
// --> PROCESSO DE ALTERAÇÃO - MENU: "ALTERAR" 
LOCAL LRET   := .T.

PUBLIC _CTIPAD	:= ""

LALTERA := .T.

DBSELECTAREA("FPH")

//VALIDA OS ACESSOS DO USUÁRIO
IF FQ1->(DBSEEK(XFILIAL("FQ1") + _CUSER + "LOCA044",.T.))	// PROCURA O CÓDIGO DE USUÁRIO NA TABELA DE USUÁRIOS ANALIZADORES DE PROMOÇÕES (SZ5)
	_CTIPAD += ALLTRIM(FQ1->FQ1_CC)							// ADICIONO TODOS OS TIPOS QUE O USUÁRIO PODE APROVAR
	IF !FPH->FPH_APROVA .OR. EMPTY(FPH->FPH_USUPRO) .OR. EMPTY(FPH->FPH_DTAPRO) 
	     AXALTERA("FPH",FPH->(RECNO()),4, , , ,"LOCA04302()")
	ELSE
        MSGALERT(STR0014 , STR0011) //"ESTE VALE ESTA APROVADO E O PROCESSO DE ALTERAÇÃO FOI CANCELADO, FAVOR REALIZAR ESTORNO DA OPERAÇÃO!"###"GPO - LOCT001.PRW"
        LRET := .F.
	ENDIF
ELSE    
	MSGALERT(STR0015 , STR0011) //"ATENÇÃO: USUARIO NÃO AUTORIZADO A ALTERAR ADIANTAMENTOS DE VIAGEM."###"GPO - LOCT001.PRW"
	LRET :=  .F.
ENDIF 

LALTERA := .F.

RETURN LRET  



// ======================================================================= \\
FUNCTION LOCA04304(NREG) 
// ======================================================================= \\
// --> PROCESSO DE EXCLUSÃO  - MENU: "EXCLUIR" 

// LOCAL _CUSER := RETCODUSR(SUBSTR(CUSUARIO,7,15)) 		// RETORNA O CÓDIGO DO USUÁRIO

IF FQ1->(DBSEEK(XFILIAL("FQ1") + _CUSER + "LOCA044",.T.))	// PROCURA O CÓDIGO DE USUÁRIO NA TABELA DE USUÁRIOS ANALIZADORES DE PROMOÇÕES (SZ5)
	IF FPH->FPH_APROVA == .T. .AND. !EMPTY(FPH->FPH_NRBV)
		MSGBOX(STR0016,STR0017 , STR0011) //"EXCLUSÃO NÃO PERMITIDA. ADIANTAMENTO JÁ FOI APROVADO!"###"EXCLUSÃO"###"GPO - LOCT001.PRW"
	ELSE           
		IF MSGYESNO(STR0018 + FPH->FPH_NRVALE + "-" + ALLTRIM(FPH->FPH_NOMMOT) + " ?" , STR0011)  //"CONFIRMA EXCLUSÃO DO VALE DE N° "###"GPO - LOCT001.PRW"
	        DBSELECTAREA("FPH")    
			_CNRBV	 := FPH->FPH_NRBV
			_CNRVALE := FPH->FPH_NRVALE
			AXDELETA("FPH",FPH->(RECNO()),5,,,,,)
		ENDIF    
	ENDIF 
ELSE 
	MSGALERT(STR0019 , STR0011)  //"ATENÇÃO: USUARIO NÃO AUTORIZADO A EXCLUIR ADIANTAMENTOS DE VIAGEM."###"GPO - LOCT001.PRW"
	RETURN .F. 
ENDIF 

RETURN 



// ======================================================================= \\
FUNCTION LOCA04305() 
// ======================================================================= \\
// --> PROCESSO DE LEGENDA   - MENU: "LEGENDA" 

LOCAL ACORES2 := {}
                                                            
ACORES2 := { {"BR_AMARELO"  , STR0020} , ;  //"NAO APROVADO SEM B.V"
             {"BR_VERDE"    , STR0021} , ;  //"NAO APROVADO COM B.V"
             {"BR_VERMELHO" , STR0022    } , ; //"APROVADO SEM B.V"
             {"BR_AZUL"     , STR0023   } }  //"APROVADO COM B.V."

BRWLEGENDA(CCADASTRO , STR0024 , ACORES2) //"LEGENDA DO BROWSE"

RETURN                                                                         



// ======================================================================= \\
FUNCTION LOCA04306(_NRBV, _MOTO)  
// ======================================================================= \\
// VALIDA SE O MOTORISTA INFORMADO NO VALE É O MESMO INFORMADO NO BV
// CHAMADA: VALIDAÇÃO DO CAMPO: FPH_NRBV 

LOCAL _LRET := .T.

FPI->(DBSETORDER(1))
FPI->(DBSEEK(XFILIAL("FPI") + _NRBV))

IF _MOTO <> FPI->FPI_MOTORI
	MSGALERT(STR0025+_MOTO +STR0026+FPI->FPI_MOTORI , STR0011)  //"MOTORISTA DE B.V -> "###' É DIFERENTE DO MOTORISTA DO VALE -> '###"GPO - LOCT001.PRW"
	_LRET := .F.
ELSE                                                  
	_LRET := .T.
ENDIF 

RETURN _LRET



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³VLDVLSPEND º AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ VALIDA VALOR PENDENDO DO MOTORISTA - CHAMADA: LOCT001.PRW  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LOCA04307()

LOCAL LRET   := .T.
LOCAL CQUERY := "SELECT FPI_PENDEN FROM "+RETSQLTAB("FPI")+" WHERE FPI_FILIAL = "+VALTOSQL(XFILIAL("FPI"))+" AND LTRIM(RTRIM(FPI_MOTORI)) = "+VALTOSQL(ALLTRIM(CMOTOR))+" AND FPI_STATUS = 'F' AND D_E_L_E_T_ = ' ' AND FPI_DTFECH = (SELECT MAX(FPI_DTFECH) FROM "+RETSQLTAB("FPI")+" WHERE  FPI_FILIAL = "+VALTOSQL(XFILIAL("FPI"))+" AND LTRIM(RTRIM(FPI_MOTORI)) = "+VALTOSQL(ALLTRIM(CMOTOR))+" AND FPI_STATUS = 'F' AND D_E_L_E_T_ = '')"

IF SELECT("QRX") > 0
	DBSELECTAREA("QRX")
	QRX->(DBCLOSEAREA())
ENDIF
TCQUERY CQUERY NEW ALIAS "QRX"

WHILE !EMPTY(QRX->FPI_PENDEN) .AND. LRET
	IF QRX->FPI_PENDEN > 0
		LRET := .F.
	ENDIF
ENDDO 

IF SELECT("QRX") > 0
	DBSELECTAREA("QRX")
	QRX->(DBCLOSEAREA())
ENDIF

RETURN LRET
