#INCLUDE "loca045.ch" 
/*/{PROTHEUS.DOC} LOCA045.PRW
ITUP BUSINESS - TOTVS RENTAL
TELA DE APROVACAO DE ADIANTAMENTO MOTORISTAS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

FUNCTION LOCA045()
LOCAL _CUSER	:= RETCODUSR(SUBSTR(CUSUARIO,7,15)) 			// RETORNA O CำDIGO DO USUมRIO
LOCAL AAREA	    := GETAREA()
LOCAL CQUERY    := ""
LOCAL LTODOS	:= .F.
LOCAL OOK       := LOADBITMAP( GETRESOURCES(), "LBOK" )
LOCAL ONO   	:= LOADBITMAP( GETRESOURCES(), "LBNO" )
LOCAL LCANCEL	:= .F.
LOCAL _CMODFOR	:= "" 
LOCAL XDATABASE := DDATABASE
LOCAL _F        := 0 

PRIVATE OLBX       := NIL
PRIVATE LMARCADOS  := .F.
PRIVATE AADIANT    := {}
PRIVATE CPERG      := "LOCP077"
PRIVATE LMSERROAUTO

// --> CAIXA OPERACIONAL 1
PRIVATE  CXOPGBAN   := "" //GETMV("MV_LOCX124")		// CำDIGO DO BANCO DO CAIXA OPERACIONAL GUINDASTE 				// 'MV_LOCX124' 
PRIVATE  CXOPGAG    := "" //GETMV("MV_LOCX123")		// CำDIGO DA AGสNCIA DO CAIXA OPERACIONAL GUINDASTE 			// 'MV_LOCX123' 
PRIVATE  CXOPGCC    := "" //GETMV("MV_LOCX125")		// CำDIGO DA C/C DO CAIXA OPERACIONAL GUINDASTE 				// 'MV_LOCX125' 

// --> CAIXA OPERACIONAL 2
PRIVATE  CXOPTBAN   := "" //GETMV("MV_LOCX130")		// CำDIGO DO BANCO DO CAIXA OPERACIONAL TRANSPORTE				// 'MV_LOCX130' 
PRIVATE  CXOPTAG    := "" //GETMV("MV_LOCX129")		// CำDIGO DA AGสNCIA DO CAIXA OPERACIONAL TRANSPORTE 			// 'MV_LOCX129' 
PRIVATE  CXOPTCC    := "" //GETMV("MV_LOCX131")		// CำDIGO DA C/C DO CAIXA OPERACIONAL TRANSPORTE 				// 'MV_LOCX131'

// --> CAIXA OPERACIONAL 3
PRIVATE  CXOPUBAN   := "" //GETMV("MV_LOCX133")		// CำDIGO DO BANCO DO CAIXA OPERACIONAL GRUA 					// 'MV_LOCX133' 
PRIVATE  CXOPUAG    := "" //GETMV("MV_LOCX132")		// CำDIGO DA AGสNCIA DO CAIXA OPERACIONAL GRUA 					// 'MV_LOCX132' 
PRIVATE  CXOPUCC    := "" //GETMV("MV_LOCX134")		// CำDIGO DA C/C DO CAIXA OPERACIONAL GRUA 						// 'MV_LOCX134'

// --> CAIXA OPERACIONAL 4
PRIVATE  CXOPPBAN   := "" //GETMV("MV_LOCX127")		// CำDIGO DO BANCO DO CAIXA OPERACIONAL PLATAFORMA 				// 'MV_LOCX127'
PRIVATE  CXOPPAG    := "" //GETMV("MV_LOCX126")		// CำDIGO DA AGสNCIA DO CAIXA OPERACIONAL PLAFORMA 				// 'MV_LOCX126' 
PRIVATE  CXOPPCC    := "" //GETMV("MV_LOCX128")		// CำDIGO DA C/C DO CAIXA OPERACIONAL PLATAFORMA 				// 'MV_LOCX128' 

// --> CAIXA MANUTENCACAO 5
PRIVATE  CXMNTBAN   := "" //GETMV("MV_LOCX121")		// CำDIGO DO BANCO DO CAIXA MANUTENCAO 							// 'MV_LOCX121'
PRIVATE  CXMNTAG    := "" //GETMV("MV_LOCX120")		// CำDIGO DA AGสNCIA DO CAIXA MANUTENCAO 						// 'MV_LOCX120'
PRIVATE  CXMNTCC    := "" //GETMV("MV_LOCX122")		// CำDIGO DA C/C DO CAIXA MANUTENCAO 							// 'MV_LOCX122'
// --> BANCO 1
PRIVATE  _CBRBAN   	:= "" //GETMV("MV_LOCX092 ")		// CำDIGO DO BANCO 1 QUE IRม EFETUAR O DEPำSITO DO VALE DO BV	// 'MV_LOCX092 '
PRIVATE  _CBRAG    	:= "" //GETMV("MV_LOCX091  ")		// CำDIGO DA AGสNCIA 1 QUE IRม EFETUAR O DEPำSITO DO VALE DO BV	// 'MV_LOCX091  '
PRIVATE  _CBRCC    	:= "" //GETMV("MV_LOCX093  ")		// CำDIGO DA CONTA 1 QUE IRม EFETUAR O DEPำSITO DO VALE DO BV	// 'MV_LOCX093  '
// --> BANCO 2
PRIVATE  _CBBBAN   	:= "" //GETMV("MV_LOCX089 ")		// CำDIGO DO BANCO 2 QUE IRม EFETUAR O DEPำSITO DO VALE DO BV	// 'MV_LOCX089 '
PRIVATE  _CBBAG    	:= "" //GETMV("MV_LOCX088  ")		// CำDIGO DA AGสNCIA 2 QUE IRม EFETUAR O DEPำSITO DO VALE DO BV	// 'MV_LOCX088  '
PRIVATE  _CBBCC    	:= "" //GETMV("MV_LOCX090  ")		// CำDIGO DA CONTA 2 QUE IRม EFETUAR O DEPำSITO DO VALE DO BV	// 'MV_LOCX090  '

PRIVATE  CNATUREZ   := "" //GETMV("MV_LOCX165")		// NATUREZA PARA ADIANTAMENTO DE DESPESAS DE VIAGEM				// 'MV_LOCX165'
PRIVATE _CTIPOTB	:= "" //GETMV("MV_LOCX094  ")		// TIPO DA MOEDA NA TRANSFERสNCIA "TB" 							// 'MV_LOCX094  '
PRIVATE _CNATORI	:= "" //GETMV("MV_LOCX094NO")		// NATUREZA ORIGEM = "T01       " 								// 'MV_LOCX094NO'
PRIVATE _CNATDES	:= "" //GETMV("MV_LOCX094ND")		// NATUREZA DESTINO= "T01       " 								// 'MV_LOCX094ND' 

// OUTROS CAIXA DESATIVADOS
PRIVATE NVLRCAIXA   := 0
PRIVATE OVLRCAIXA   := NIL

PRIVATE OARIAL12N1	:= TFONT():NEW("ARIAL",12,16,,.T.,,,,.T.,.F.)
PRIVATE OARIAL12N2	:= TFONT():NEW("ARIAL",12,16,,.T.,,,,.T.,.F.)
PRIVATE OFONT1		:= OARIAL12N1
PRIVATE OFONT2		:= OARIAL12N2

//IF !LOCA061() 								// --> VALIDAวรO DO LICENCIAMENTO (WS) DO GPO 
//	RETURN 
//ENDIF 

// VALIDA OS ACESSOS DO USUมRIO
IF FQ1->(DBSEEK(XFILIAL("FQ1") + _CUSER + "LOCA045",.T.))		// PROCURA O CำDIGO DE USUมRIO NA TABELA DE USUมRIOS ANALIZADORES DE PROMOวีES (SZ5)
	_CTIPAD := ""
	FOR _F := 1 TO LEN(ALLTRIM(FQ1->FQ1_CC))
		_CTIPAD += "'" + SUBSTR(FQ1->FQ1_CC,_F,1) + "',"		// ADICIONO TODOS OS TIPOS QUE O USUมRIO PODE APROVAR
	NEXT _F 
	_CTIPAD := LEFT(_CTIPAD,LEN(ALLTRIM(_CTIPAD))-1)			// Sำ PARA RETIRAR A ฺLTIMA VอRGULA DO CAMPO
ELSE
	MSGALERT(STR0001 , STR0002)  //"ATENวรO: USUARIO NรO AUTORIZADO A APROVAR VALES."###"GPO - LOCT003.PRW"
	RETURN .F.
ENDIF

// VALIDA OS PARยMETROS CAIXA OPERACIONAL 1
SA6->(DBSETORDER(1))
IF !(SA6->(DBSEEK(XFILIAL("SA6") + CXOPGBAN + CXOPGAG + CXOPGCC )))
	MSGALERT(STR0003 , STR0002)  //"ATENวรO: PARยMETROS MV_LOCX124, MV_LOCX123 E MV_LOCX125, NรO ESTรO CADASTRADOS OU SรO INVมLIDOS."###"GPO - LOCT003.PRW"
	RETURN .F.
ENDIF

// VALIDA OS PARยMETROS CAIXA OPERACIONAL 2
SA6->(DBSETORDER(1))
IF !(SA6->(DBSEEK(XFILIAL("SA6") + CXOPTBAN + CXOPTAG + CXOPTCC )))
	MSGALERT(STR0004 , STR0002)  //"ATENวรO: PARยMETROS MV_LOCX130, MV_LOCX129 E MV_LOCX131, NรO ESTรO CADASTRADOS OU SรO INVมLIDOS."###"GPO - LOCT003.PRW"
	RETURN .F.
ENDIF
	
// VALIDA OS PARยMETROS CAIXA OPERACIONAL 3
// MV_CXOUGBA - CODIGO DO BANCO DO CAIXA OPERACIONAL GRUAS
// MV_CXOUGAG - CำDIGO DA AGสNCIA DO CAIXA OPERACIONAL GRUAS
// MV_CXOUGCC - CำDIGO DA C/C DO CAIXA OPERACIONAL GRUAS
SA6->(DBSETORDER(1))
IF !(SA6->(DBSEEK(XFILIAL("SA6") + CXOPUBAN + CXOPUAG + CXOPUCC )))
	MSGALERT(STR0005 , STR0002)  //"ATENวรO: PARยMETROS MV_LOCX133, MV_LOCX132 E MV_LOCX134, NรO ESTรO CADASTRADOS OU SรO INVมLIDOS."###"GPO - LOCT003.PRW"
	RETURN .F.
ENDIF

// VALIDA OS PARยMETROS CAIXA OPERACIONAL 4
// MV_LOCX127 - CODIGO DO BANCO DO CAIXA OPERACIONAL PLATAFORMA
// MV_LOCX126 - CำDIGO DA AGสNCIA DO CAIXA OPERACIONAL PLATAFORMA
// MV_LOCX128 - CำDIGO DA C/C DO CAIXA OPERACIONAL PLATAFORMA
SA6->(DBSETORDER(1))
IF !(SA6->(DBSEEK(XFILIAL("SA6") + CXOPPBAN + CXOPPAG + CXOPPCC )))
	MSGALERT(STR0006 , STR0002) //"ATENวรO: PARยMETROS MV_LOCX127, MV_LOCX126 E MV_LOCX128, NรO ESTรO CADASTRADOS OU SรO INVมLIDOS."###"GPO - LOCT003.PRW"
	RETURN .F.
ENDIF

// VALIDA OS PARยMETROS CAIXA MANUTENCAO 5
SA6->(DBSETORDER(1))
IF !(SA6->(DBSEEK(XFILIAL("SA6") + CXMNTBAN + CXMNTAG + CXMNTCC ))) //!(SA6->(DBSEEK(XFILIAL("SA6") + CXOPGBAN + CXOPGAG + CXOPGCC)))
	MSGALERT(STR0007 , STR0002)  //"ATENวรO: PARยMETROS MV_LOCX121, MV_LOCX120 E MV_LOCX122, NรO ESTรO CADASTRADOS OU SรO INVมLIDOS."###"GPO - LOCT003.PRW"
	RETURN .F.
ENDIF

// VALIDA O PARยMETRO MV_NATCAIX - NATUREZA PARA ADIANTAMENTO DE DESPESAS DE VIAGEM
SED->(DBSETORDER(1))
IF !(SED->(DBSEEK(XFILIAL("SED") + CNATUREZ)))
	MSGALERT(STR0008 , STR0002)  //"ATENวรO: PARยMETRO MV_LOCX165, NรO ESTม CADASTRADO OU ษ INVมLIDO."###"GPO - LOCT003.PRW"
	RETURN .F.
ENDIF

//CRIASX1(CPERG)

IF ! PERGUNTE(CPERG,.T.)
	RETURN NIL
ENDIF

MV_PAR01 := IIF(EMPTY(MV_PAR01),CTOD("01/01/01")  ,MV_PAR01)
MV_PAR02 := IIF(EMPTY(MV_PAR02),CTOD("31/12/2999"),MV_PAR02)

IF SELECT("TRB") > 0
	DBSELECTAREA("TRB")
	DBCLOSEAREA()
ENDIF

CQUERY := "SELECT * "
CQUERY += "FROM " + RETSQLNAME("FPH") + " ZL1 "
CQUERY += "WHERE FPH_FILIAL = '"      + XFILIAL("FPH")         + "' AND "
CQUERY += "		 FPH_DEPDT BETWEEN '" + DTOS(MV_PAR01)         + "' AND '" + DTOS(MV_PAR02) + "' AND "
CQUERY += "		 FPH_TIPAD  IN     (" + ALLTRIM(_CTIPAD)       + ") AND "
CQUERY += "		 FPH_TIPAD  = '"      + ALLTRIM(STR(MV_PAR03)) + "' AND "
CQUERY += "		 FPH_APROVA = 'F'                                   AND "
CQUERY += "      D_E_L_E_T_ = '' "
CQUERY += "ORDER BY FPH_EMISSA"
CQUERY := CHANGEQUERY(CQUERY)
DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERY),"TRB", .F., .T.)

DBSELECTAREA("TRB")
DBGOTOP()

// BLOCO ESCRITO PARA SELECIONAR ADIANTAMENTOS
IF TRB->(EOF())
	MSGSTOP(STR0009 , "GPO - LOCT003.PRW")  //"NรO EXISTEM ADIANTAMENTOS A SEREM GERADOS."
	TRB->(DBCLOSEAREA())
	RESTAREA(AAREA)
	RETURN
ENDIF

TRB->(DBGOTOP())
WHILE ! TRB->(EOF())
	AADD(AADIANT, { .F.            	,;
					TRB->FPH_DEPDT	,;
					TRB->FPH_NRVALE	,;
					TRB->FPH_VIAGEM	,;
					TRB->FPH_MOTORI	+ "-" + POSICIONE("DA4",1,XFILIAL("DA4") + TRB->FPH_MOTORI,"DA4_NOME"), ;
					TRB->FPH_VALOR	,;
					TRB->FPH_MODFOR	,;
					TRB->R_E_C_N_O_	,;
					TRB->FPH_TIPAD 	,;
					TRB->FPH_NRBV	,;
					TRB->FPH_BANCO	})
	TRB->(DBSKIP())
ENDDO 
TRB->(DBCLOSEAREA())

DEFINE MSDIALOG ODLG FROM  000,000 TO 430,780 TITLE STR0010 PIXEL //"SELECIONE OS ADIANTAMENTOS"
	@ 012,000 LISTBOX OLBX FIELDS HEADER "", STR0011, STR0012, STR0013, STR0014, STR0015,"MODO FORNEC." ;  //"DT.DEPOSITO"###"NR.VALE"###"VIAGEM"###"MOTORISTA"###"VALOR ADIANTAMENTO"
	          COLSIZES 10,30,30,30,180,100,100 SIZE 380,170 OF ODLG PIXEL ON DBLCLICK( AADIANT[OLBX:NAT,01] := VERSALDO(), OLBX:REFRESH() )
	OLBX:SETARRAY(AADIANT)
	OLBX:BLINE := { || {IF(	AADIANT[OLBX:NAT,01],OOK,ONO),; 		// CHECKBOX
	STOD(AADIANT[OLBX:NAT,02]),;									// EMISSAO
	AADIANT[OLBX:NAT,03],;              							// LISTAGEM
	AADIANT[OLBX:NAT,04],;											// VIAGEM
	AADIANT[OLBX:NAT,05],;											// MOTORISTA
	TRANSFORM(AADIANT[OLBX:NAT,06],"@E 999,999.99"),;				// VALOR
	AADIANT[OLBX:NAT,07]}} 											// MODO FORNECIMENTO
	OLBX:NFREEZE  := 1
	@ 000,000  BITMAP OBMP RESNAME "PROJETOAP"    OF ODLG SIZE 420,780 NOBORDER WHEN .F. PIXEL
	@ 195,0.5  CHECKBOX OCHK VAR LTODOS PROMPT STR0016 SIZE 70, 10 OF ODLG PIXEL ON CLICK(MARCARREGI(.T.)) //"MARCA/DESMARCA TODOS"
	@ 200, 325 BUTTON STR0017       SIZE 28,13 PIXEL OF ODLG ACTION ( ODLG:END()) //"OK"
	@ 200, 360 BUTTON STR0018 SIZE 28,13 PIXEL OF ODLG ACTION (LCANCEL:=.T., ODLG:END()) //"CANCELAR"
ACTIVATE MSDIALOG ODLG CENTERED

IF LCANCEL
	RESTAREA(AAREA)
	RETURN
ENDIF

_NVLGER	:= _NQTGER := _NQTNGER := 0

BEGIN TRANSACTION

	NX := 0
	PERGUNTE("FIN050",.F.)
	WHILE NX < LEN(AADIANT)
		NX++
		IF !AADIANT[NX,01]
			_NQTNGER++
			LOOP
		ENDIF

		DA4->(DBSETORDER(1))
		DA4->(DBSEEK(XFILIAL("DA4") + SUBSTR(AADIANT[NX,05],1,6),.F.))

		SA2->(DBSETORDER(1))
		IF !SA2->(DBSEEK(XFILIAL("SA2")+ DA4->DA4_FORNEC + DA4->DA4_LOJA,.F.))
			MSGSTOP(STR0019+ALLTRIM(SA2->A2_COD)+"/"+ALLTRIM(SA2->A2_LOJA)+"-"+ALLTRIM(SA2->A2_NOME)+STR0020+SUBSTR(AADIANT[NX,05],1,6)+STR0021 , STR0002)  //"FORNECEDOR "###", VINCULADO AO MOTORISTA "###", NรO ENCONTRADO !!!, VERIFIQUE O CADASTRO DO MOTORISTA."###"GPO - LOCT003.PRW"
			LOOP
		ENDIF

		CPREFIXO := "ADT"
		CNUM     := LEFT(AADIANT[NX,03],9)		//SUBSTR(AADIANT[NX, 03],1,6) + SPACE(03)
		CPARCELA := SPACE(TAMSX3("E2_PARCELA")[1])
		CTIPO    := "PA "
		CFORNECE := SA2->A2_COD
		CLOJA    := SA2->A2_LOJA
		CHIST    := STR0023 + LEFT(AADIANT[NX,3],9) + STR0024 + AADIANT[NX,10] + STR0025 + AADIANT[NX,4]  //"REF.VALE "###"-BV "###"-VIAGEM "

		CCHAVE   := XFILIAL("SE2")+CPREFIXO+CNUM+CPARCELA+CTIPO+CFORNECE+CLOJA

		SE2->(DBSETORDER(1))
		IF SE2->(DBSEEK(CCHAVE,.F.))
			MSGSTOP(STR0026+ALLTRIM(SA2->A2_COD)+"/"+ALLTRIM(SA2->A2_LOJA)+"-"+ALLTRIM(SA2->A2_NOME)+STR0027+SUBSTR(AADIANT[NX,5],1,6) , STR0002)  //"TอTULO Jม EXISTENTE PARA O FORNECEDOR "###" - MOTORISTA "###"GPO - LOCT003.PRW"
			LOOP
		ENDIF
		
		FPH->(DBGOTO(AADIANT[NX,08]))
		/*		
		IF ! (FPH->FPH_DEPDT >= DDATABASE)
			MSGSTOP("A DATA BASE DO SISTEMA ษ MAIOR OU IGUAL A DATA DE DEPำSITO, APROVE O VALE COM A  DATABASE DO SISTEMA IGUAL A DATA DE DEPำSITO -> "+"REF.VALE "+LEFT(AADIANT[NX,3],9)+"-BV "+AADIANT[NX,10]+"-VIAGEM "+AADIANT[NX,4] , "GPO - LOCT003.PRW") 
			LOOP
		ENDIF
		*/
		IF ! EMPTY( FPH->FPH_DEPDT )
			DDATABASE := FPH->FPH_DEPDT
		ENDIF

		ASE2 		:= {}
	 //	_CBANCO	 	:= IIF(AADIANT[NX, 09]=="1",CXOPGBAN,CXOPTBAN)
	 //	_CAGENCIA 	:= IIF(AADIANT[NX, 09]=="1",CXOPGAG ,CXOPTAG )
	 //	_CNUMCON  	:= IIF(AADIANT[NX, 09]=="1",CXOPGCC ,CXOPTCC )

		_CBANCO	  := IIF(AADIANT[NX, 09]=="1",CXOPGBAN,;
		             IIF(AADIANT[NX, 09]=="2",CXOPTBAN,;
		             IIF(AADIANT[NX, 09]=="3",CXOPUBAN,;
		             IIF(AADIANT[NX, 09]=="4",CXOPPBAN,;
		             IIF(AADIANT[NX, 09]=="5",CXMNTBAN,"")))))		//1=GUINDASTE;2=TRANSPORTE;3=PLATAFORMA;4=GRUA;5=MANUTENCAO
		_CAGENCIA := IIF(AADIANT[NX, 09]=="1",CXOPGAG ,;
		             IIF(AADIANT[NX, 09]=="2",CXOPTAG ,;
		             IIF(AADIANT[NX, 09]=="3",CXOPUAG ,;
		             IIF(AADIANT[NX, 09]=="4",CXOPPAG ,;
		             IIF(AADIANT[NX, 09]=="5",CXMNTAG ,"")))))		// 1=GUINDASTE;2=TRANSPORTE;3=PLATAFORMA;4=GRUA;5=MANUTENCAO
		_CNUMCON  := IIF(AADIANT[NX, 09]=="1",CXOPGCC ,;
		             IIF(AADIANT[NX, 09]=="2",CXOPTCC ,;
		             IIF(AADIANT[NX, 09]=="3",CXOPUCC ,;
		             IIF(AADIANT[NX, 09]=="4",CXOPPCC ,;
		             IIF(AADIANT[NX, 09]=="5",CXMNTCC ,"")))))		// 1=GUINDASTE;2=TRANSPORTE;3=PLATAFORMA;4=GRUA;5=MANUTENCAO
		
		_CMODFOR  	:= AADIANT[NX, 07]
		_CBANTB	 	:= IIF(AADIANT[NX, 11]=="1",_CBBBAN ,_CBRBAN )	// 1=BANCO DO BRASIL;2=BRADESCO
		_CAGETB	 	:= IIF(AADIANT[NX, 11]=="1",_CBBAG  ,_CBRAG  )	// 1=BANCO DO BRASIL;2=BRADESCO
		_CCCTB	 	:= IIF(AADIANT[NX, 11]=="1",_CBBCC  ,_CBRCC  )	// 1=BANCO DO BRASIL;2=BRADESCO

		_CCCUSTO    := LOCA05101(AADIANT[NX, 09])					// 1=GUINDASTE;2=TRANSPORTE;3=PLATAFORMA;4=GRUA

		IF ! EMPTY( AADIANT[NX, 10] ) 								// NรO TEM BV
			FPI->( DBSETORDER(1) )
			IF FPI->( DBSEEK( XFILIAL("FPI") + AADIANT[NX, 10] ) )
				_CCCUSTO := FPI->FPI_CCUSTO
			ENDIF
		ENDIF
		
		SE2->(DBGOBOTTOM())
		
		//PREENCHE O ARRAY
		AADD(ASE2,{"E2_FILIAL" , XFILIAL("SE2")			, NIL})
		AADD(ASE2,{"E2_PREFIXO", CPREFIXO				, NIL})
		AADD(ASE2,{"E2_NUM"    , CNUM					, NIL})
		AADD(ASE2,{"E2_PARCELA", CPARCELA				, NIL})
		AADD(ASE2,{"E2_TIPO"   , CTIPO 					, NIL})
		AADD(ASE2,{"E2_NATUREZ", CNATUREZ				, NIL})
		AADD(ASE2,{"E2_FORNECE", DA4->DA4_FORNEC		, NIL})
		AADD(ASE2,{"E2_LOJA"   , DA4->DA4_LOJA   		, NIL})
		AADD(ASE2,{"E2_NOMFOR" , SA2->A2_NREDUZ 		, NIL})
		AADD(ASE2,{"E2_EMISSAO", DDATABASE				, NIL})
		AADD(ASE2,{"E2_VENCTO" , STOD(AADIANT[NX, 02])	, NIL})
		AADD(ASE2,{"E2_VENCREA", STOD(AADIANT[NX, 02])	, NIL})
		AADD(ASE2,{"E2_VALOR"  , AADIANT[NX, 06]		, NIL})
		AADD(ASE2,{"E2_CCD"    , _CCCUSTO            	, NIL})
		AADD(ASE2,{"E2_HIST"   , CHIST          		, NIL})
		AADD(ASE2,{"E2_DATALIB", STOD(AADIANT[NX, 02])  , NIL})
		AADD(ASE2,{"E2_VRETINS", 0                      , NIL})
		AADD(ASE2,{"AUTBANCO"  , _CBANCO                , NIL})
		AADD(ASE2,{"AUTAGENCIA", _CAGENCIA              , NIL})
		AADD(ASE2,{"AUTCONTA"  , _CNUMCON               , NIL})
		
		//PERGUNTE("FIN050",.F.)
		
		// VARIAVEIS MENSAGEM DE ERRO
		LMSERROAUTO := .F.
		LMSHELPAUTO := .T.
		
		// GRAVA CONTAS A PAGAR
		MSEXECAUTO({|X,Y,Z|FINA050(X,Y,Z)},ASE2,NIL,3)
		
	 //	ATUSALBCO(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,"-")
		
		// CONTROLA MENSAGEM DE ERRO
		IF LMSERROAUTO
			MOSTRAERRO()
			EXIT
        ELSE
			// MUDEI A POSIวรO DA GERAวรO DE TB PARA CRIAR SOMENTE SE CRIAR O TITULO NO SE2. 
			IF _CMODFOR == "2"					// DEPำSITO
				// GERA A TB DO BANCO PARA O CAIXA OPERACIONAL
				LOCA04501( _CBANTB,;				// BANCO   ORIGEM
				          _CAGETB,;				// AGสNCIA ORIGEM
				          _CCCTB,;				// C/C ORIGEM
				          _CNATORI,;			// NATUREZA ORIGEM
				          _CBANCO,;				// BANCO DESTINO
				          _CAGENCIA,;			// AGสNCIA DESTINO
				          _CNUMCON,;			// C/C DESTINO
				          _CNATDES,;			// NATUREZA DESTINO
				          _CTIPOTB,;			// TIPO DA MOEDA PARA TRANSFERสNCIA "TB"
				          AADIANT[NX, 06],;		// VALOR
				          CNUM,;				// NฺMERO DO DOCUMENTO
				          "TB " + CHIST,;		// HISTำRICO
				          DA4->DA4_NOME )		// BENEFICIมRIO
			ENDIF
			
			DBSELECTAREA("FPH")
			DBGOTO(AADIANT[NX,08])
			RECLOCK("FPH",.F.)
				FPH->FPH_APROVA := .T.
				FPH->FPH_DTAPRO := XDATABASE //DDATABASE
				FPH->FPH_SALDO  += AADIANT[NX,06]
				FPH->FPH_USUPRO := SUBSTR(CUSUARIO,7,6)
			FPH->(MSUNLOCK())
			
			CNRBV   := FPH->FPH_NRBV
			
			_NVLGER += AADIANT[NX, 06]
			_NQTGER ++
		ENDIF
		
		DBSKIP() 
	ENDDO 
	
	IF     _NQTGER  > 0 
		MSGINFO(STR0028 + ALLTRIM(TRANSFORM(_NVLGER,"@E 9,999,999.99")) , STR0002)  //" ADIANTAMENTOS FORAM GERADOS NO FINANCEIRO. VALOR TOTAL R$ "###"GPO - LOCT003.PRW"
	ELSEIF _NQTNGER > 0 
		MSGSTOP(STR0029 , STR0002)  //" NAO FORAM APROVADOS OS ADIANTAMENTOS NESSE PROCESSAMENTO."###"GPO - LOCT003.PRW"
	ENDIF
	
END TRANSACTION 

DDATABASE := XDATABASE 

RESTAREA(AAREA)

RETURN



// ======================================================================= \\
STATIC FUNCTION MARCARREGI(LTODOS)
// ======================================================================= \\

LOCAL NI := 0 

IF LTODOS
	LMARCADOS := ! LMARCADOS
	FOR NI := 1 TO LEN(AADIANT)
		LADIANTBKP    := AADIANT[NI,1]
		AADIANT[NI,1] := LMARCADOS
	NEXT NI 
ENDIF

OCHK:OFONT := ODLG:OFONT
OLBX:REFRESH(.T.)
ODLG:REFRESH(.T.)
OBMP:REFRESH(.T.)

RETURN NIL



// ======================================================================= \\
STATIC FUNCTION VERSALDO()
// ======================================================================= \\

LOCAL LRET   := .F.

IF OLBX:AARRAY[OLBX:NAT][1]
	LRET := .F. 
	OLBX:AARRAY[OLBX:NAT][1] := LRET 
ELSE
	LRET := .T. 
	OLBX:AARRAY[OLBX:NAT][1] := LRET 
ENDIF

AADIANT := ACLONE(OLBX:AARRAY) 
OLBX:REFRESH()

RETURN LRET 



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNวรO    ณ GERATB บ AUTOR ณ IT UP BUSINESS       บ DATA ณ 21/09/2007  บฑฑ
ฑฑฬออออออออออุออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESCRICAO ณ FUNวรO PARA EFETUAR TRANSFERสNCIA BANCมRIA AUTOMมTICAMENTE บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบPARยMETROSณ CBCOORIG   - BANCO   ORIGEM                                บฑฑ
ฑฑบ          ณ CAGENORIG  - AGสNCIA ORIGEM                                บฑฑ
ฑฑบ          ณ CCTAORIG   - C/C ORIGEM                                    บฑฑ
ฑฑบ          ณ CNATURORI  - NATUREZA ORIGEM                               บฑฑ
ฑฑบ          ณ CBCODEST   - BANCO DESTINO                                 บฑฑ
ฑฑบ          ณ CAGENDEST  - AGสNCIA DESTINO                               บฑฑ
ฑฑบ          ณ CCTADEST   - C/C DESTINO                                   บฑฑ
ฑฑบ          ณ CNATURDES  - NATUREZA DESTINO                              บฑฑ
ฑฑบ          ณ CTIPOTRAN  - TIPO DA MOEDA PARA TRANSFERสNCIA "TB"         บฑฑ
ฑฑบ          ณ NVALORTRAN - VALOR                                         บฑฑ
ฑฑบ          ณ CDOCTRAN   - NฺMERO DO DOCUMENTO                           บฑฑ
ฑฑบ          ณ CHIST100   - HISTำRICO                                     บฑฑ
ฑฑบ          ณ CBENEF100  - BENEFICIมRIO                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
FUNCTION LOCA04501(CBCOORIG, CAGENORIG, CCTAORIG, CNATURORI, CBCODEST, CAGENDEST, CCTADEST, CNATURDES, CTIPOTRAN, NVALORTRAN, CDOCTRAN, CHIST100, CBENEF100)

LOCAL 	AFINA100 	:= {}
//LOCAL	_CPROCESSO	:=	"0" //PARA CRIAวรO DE TB VIA RECLOC CASO SEJA POR MSEXECAUTO COMENTAR 
PRIVATE LMSERROAUTO := .F.

//CBCOORIG   := ALLTRIM(CBCOORIG)  + SPACE(TAMSX3("E5_BANCO"  )[1]-LEN(ALLTRIM(CBCOORIG )) ) 
//CAGENORIG  := ALLTRIM(CAGENORIG) + SPACE(TAMSX3("E5_AGENCIA")[1]-LEN(ALLTRIM(CAGENORIG)) ) 
//CCTAORIG   := ALLTRIM(CCTAORIG)  + SPACE(TAMSX3("E5_CONTA"  )[1]-LEN(ALLTRIM(CCTAORIG )) ) 
//CNATURORI  := ALLTRIM(CNATURORI) + SPACE(TAMSX3("E5_NATUREZ")[1]-LEN(ALLTRIM(CNATURORI)) ) 
//CBCODEST   := ALLTRIM(CBCODEST)  + SPACE(TAMSX3("E5_BANCO"  )[1]-LEN(ALLTRIM(CBCODEST )) ) 
//CAGENDEST	 := ALLTRIM(CAGENDEST) + SPACE(TAMSX3("E5_AGENCIA")[1]-LEN(ALLTRIM(CAGENDEST)) ) 
//CCTADEST   := ALLTRIM(CCTADEST)  + SPACE(TAMSX3("E5_CONTA"  )[1]-LEN(ALLTRIM(CCTADEST )) ) 
//CNATURDES  := ALLTRIM(CNATURDES) + SPACE(TAMSX3("E5_NATUREZ")[1]-LEN(ALLTRIM(CNATURDES)) ) 
//CTIPOTRAN  := ALLTRIM(CTIPOTRAN) + SPACE(TAMSX3("E5_TIPO"   )[1]-LEN(ALLTRIM(CTIPOTRAN)) ) 
//CDOCTRAN   := ALLTRIM(CDOCTRAN)  + SPACE(TAMSX3("E5_DOCUMEN")[1]-LEN(ALLTRIM(CDOCTRAN )) ) 
//CHIST100   := ALLTRIM(CHIST100)  + SPACE(TAMSX3("E5_HISTOR" )[1]-LEN(ALLTRIM(CHIST100 )) ) 
//CBENEF100  := ALLTRIM(CBENEF100) + SPACE(TAMSX3("E5_BENEF"  )[1]-LEN(ALLTRIM(CBENEF100)) ) 
//PARA CRIAวรO DE TB VIA RECLOC CASO SEJA POR MSEXECAUTO COMENTAR 
//_CPROCESSO := IIF(CPAISLOC$"BRA",GETSXENUM("SE5","E5_PROCTRA","E5_PROCTRA"+CEMPANT),_CPROCESSO)
//CONFIRMSX8()

AFINA100 := { {"CBCOORIG"   , ALLTRIM(CBCOORIG)      , NIL} , ;
              {"CAGENORIG"  , ALLTRIM(CAGENORIG)     , NIL} , ;
              {"CCTAORIG"   , ALLTRIM(CCTAORIG)      , NIL} , ;				
              {"CNATURORI"  , ALLTRIM(CNATURORI)     , NIL} , ;		
              {"CBCODEST"   , ALLTRIM(CBCODEST)      , NIL} , ;
              {"CAGENDEST"  , ALLTRIM(CAGENDEST)     , NIL} , ;
              {"CCTADEST"   , ALLTRIM(CCTADEST)      , NIL} , ;
              {"CNATURDES"  , ALLTRIM(CNATURDES)     , NIL} , ;
              {"CTIPOTRAN"  , ALLTRIM(CTIPOTRAN)     , NIL} , ;
              {"CDOCTRAN"   , ALLTRIM(CDOCTRAN)      , NIL} , ;
              {"NVALORTRAN" , NVALORTRAN             , NIL} , ;
              {"CHIST100"   , SUBSTR(CHIST100,1,40)  , NIL} , ;
              {"CBENEF100"  , SUBSTR(CBENEF100,1,30) , NIL} } 

MSEXECAUTO({|X,Y,Z| FINA100(X,Y,Z)},0,AFINA100,7) 

	IF LMSERROAUTO
		MOSTRAERRO()
 //	ELSE
 //		MSGALERT("TRANSFERสNCIA EXECUTADA COM SUCESSO !")
	ENDIF
/*
// ROTINA DE TB AUTOMมTICA CUSTOMIZADA NA VERSรO 8, AONDE NรO EXISTE MSEXECAUTO PARA A MESMA
// --> ATUALIZA MOVIMENTACAO BANCARIA C/REFERENCIA A SAIDA			 ณ
DBSELECTAREA( "SA6" )
DBSEEK(XFILIAL("SA6") + CBCOORIG + CAGENORIG + CCTAORIG)
RECLOCK("SE5",.T.)
	SE5->E5_FILIAL  := XFILIAL("SE5")
	SE5->E5_DATA	:= DDATABASE
	SE5->E5_BANCO	:= CBCOORIG
	SE5->E5_AGENCIA := CAGENORIG
	SE5->E5_CONTA	:= CCTAORIG
	SE5->E5_RECPAG  := "P"
	SE5->E5_NUMCHEQ := CDOCTRAN
	SE5->E5_HISTOR  := CHIST100
	SE5->E5_TIPODOC := "TR"
	SE5->E5_MOEDA	:= CTIPOTRAN
	SE5->E5_VALOR   := NVALORTRAN
	SE5->E5_DTDIGIT := DDATABASE
	SE5->E5_BENEF	:= CBENEF100
	SE5->E5_DTDISPO := DDATABASE
	SE5->E5_NATUREZ := CNATURORI
	SE5->E5_FILORIG := CFILANT 
	SE5->E5_ORIGEM	:= "LOCA045"
	SE5->E5_PROCTRA := _CPROCESSO
SE5->(MSUNLOCK())

// --> ATUALIZA SALDO BANCARIO.	
ATUSALBCO(CBCOORIG,CAGENORIG,CCTAORIG,DDATABASE,SE5->E5_VALOR,"-")

// --> ATUALIZA MOVIMENTACAO BANCARIA C/REFERENCIA A ENTRADA.
DBSELECTAREA( "SA6" )
DBSEEK(XFILIAL("SA6") + CBCODEST + CAGENDEST + CCTADEST)
RECLOCK("SE5",.T.)
	SE5->E5_FILIAL  := XFILIAL("SE5")
	SE5->E5_DATA	:= DDATABASE
	SE5->E5_BANCO	:= CBCODEST
	SE5->E5_AGENCIA := CAGENDEST
	SE5->E5_CONTA	:= CCTADEST
	SE5->E5_RECPAG  := "R"
	SE5->E5_DOCUMEN := CDOCTRAN
	SE5->E5_HISTOR  := CHIST100
	SE5->E5_TIPODOC := "TR"
	SE5->E5_MOEDA	:= CTIPOTRAN
	SE5->E5_VALOR   := NVALORTRAN
	SE5->E5_DTDIGIT := DDATABASE
	SE5->E5_BENEF	:= CBENEF100
	SE5->E5_DTDISPO := DDATABASE
	SE5->E5_NATUREZ := CNATURDES
	SE5->E5_FILORIG := CFILANT
	SE5->E5_ORIGEM	:= "LOCA045"
	SE5->E5_PROCTRA := _CPROCESSO
SE5->(MSUNLOCK())

// --> ATUALIZA SALDO BANCARIO. 
ATUSALBCO(CBCODEST,CAGENDEST,CCTADEST,DDATABASE,SE5->E5_VALOR,"+")
*/
RETURN



// ======================================================================= \\
FUNCTION LOCA04502(_NOPC)
Local _aArea  := GetArea()
Local _cParam := ""
Local _xRet   := "" 
dbSelectArea('SX6')
	SX6->(DBSetOrder(1))

	Do Case
		Case _nOpc == 1											//C๓digo do banco do caixa operacional 2
			_cParam := "MV_CXOPTBA"
		Case _nOpc == 2				
			_cParam := "MV_CXOPTAG"
		Case _nOpc == 3											//C๓digo da ag๊ncia do caixa operacional 2
			_cParam := "MV_CXOPTCC"
		Case _nOpc == 4											//C๓digo do banco do caixa operacional 1
			_cParam := "MV_CXOPGBA"
		Case _nOpc == 5											//C๓digo da ag๊ncia do caixa operacional 1
			_cParam := "MV_CXOPGAG"
		Case _nOpc == 6											//C๓digo da ag๊ncia do caixa operacional 1
			_cParam := "MV_CXOPGCC"
		Case _nOpc == 7											//Natureza para adiantamento de despesas de viagem
			_cParam := "MV_NATVBV"
		Case _nOpc == 8											//Natureza para adiantamento de despesas de viagem
			_cParam := "MV_NATDBV"
		Case _nOpc == 9											//C๓digo do banco 2 que irแ efetuar o dep๓sito do vale do BV
			_cParam := "MV_BBBAN"
		Case _nOpc == 10										//C๓digo da ag๊ncia do Banco 2 que irแ efetuar o dep๓sito do vale do BV
			_cParam := "MV_BBAG"
		Case _nOpc == 11										//C๓digo da conta do Banco 2 que irแ efetuar o dep๓sito do vale do BV
			_cParam := "MV_BBCC"
		Case _nOpc == 12										//C๓digo do banco 1 que irแ efetuar o dep๓sito do vale do BV
			_cParam := "MV_BRBAN"
		Case _nOpc == 13										//C๓digo da ag๊ncia do Banco 1 que irแ efetuar o dep๓sito do vale do BV
			_cParam := "MV_BRAG"
		Case _nOpc == 14										//C๓digo da conta do Banco 1 que irแ efetuar o dep๓sito do vale do BV
			_cParam := "MV_BRCC"
		Case _nOpc == 15										//Tipo da transfer๊ncia "TB"
			_cParam := "MV_BVTB"
		Case _nOpc == 16											//Natureza Origem = "T01"
			_cParam := "MV_BVTBNO"
		Case _nOpc == 17											//Natureza Destino = "T01"
			_cParam := "MV_BVTBND"
		Case _nOpc == 18								//C๓digo do banco do caixa operacional desativado
			_cParam := "MV_CXOPPBA"
		Case _nOpc == 19								//C๓digo da ag๊ncia do caixa operacional desativado
			_cParam := "MV_CXOPPAG"
		Case _nOpc == 20								//C๓digo da ag๊ncia do caixa operacional desativado
			_cParam := "MV_CXOPPCC"
		Case _nOpc == 21								//C๓digo do banco do caixa operacional desativado
			_cParam := "MV_CXOPUBA"
		Case _nOpc == 22								//C๓digo da ag๊ncia do caixa operacional desativado
			_cParam := "MV_CXOPUAG"
		Case _nOpc == 23								//C๓digo da ag๊ncia do caixa operacional desativado
			_cParam := "MV_CXOPUCC"
		Case _nOpc == 24								//C๓digo da ag๊ncia do caixa Manutencao
			_cParam := "MV_CXMNTCC"
		Case _nOpc == 25								//C๓digo da ag๊ncia do caixa Manuten็ใo
			_cParam := "MV_CXMNTAG"
		Case _nOpc == 26								//C๓digo da ag๊ncia do caixa Manutencao
			_cParam := "MV_CXMNTBA"
	EndCase

	If !empty(_cParam)
		_xRet := GetMv(_cParam)
	EndIf

RestArea(_aArea)
RETURN _xRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNO    ณ CRIASX1  บ AUTOR ณ AP5 IDE            บ DATA ณ  07/05/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESCRIO ณ VERIFICA A EXISTENCIA DAS PERGUNTAS CRIANDO-AS CASO SEJA   บฑฑ
ฑฑบ          ณ NECESSARIO (CASO NAO EXISTAM).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ PROGRAMA PRINCIPAL                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION CRIASX1(CPERG) 
/*
PUTSX1(CPERG,"01" ,"DATA DE       ?"     ,"DATA DE       ?"     ,"DATA DE       ?"     ,"MV_CH1" ,"D" ,08     ,0      ,0     ,"G","" ,""	,"","","MV_PAR01",""            	,"","",""   			,"","",""           ,""   	,"",""			,"","","","","",,,)
PUTSX1(CPERG,"02" ,"DATA ATE      ?"     ,"DATA ATE      ?"     ,"DATA ATE      ?"     ,"MV_CH2" ,"D" ,08     ,0      ,0     ,"G","" ,""	,"","","MV_PAR02",""            	,"","",""   			,"","",""           ,""   	,"",""			,"","","","","",,,)
PUTSX1(CPERG,"03" ,STR0030      ,STR0030      ,STR0030      ,"MV_CH3" ,"C" ,27     ,0      ,4     ,"C","" ,""	,"","","MV_PAR03",STR0031	,"","",,STR0032	,"","","---------"	,"" 	,"",STR0033,  ,"",  ,"","","","","","","","","","","",,,) //"TIPO DE VALE ?"###"TIPO DE VALE ?"###"TIPO DE VALE ?"###"OPERACIONAL 1"###"OPERACIONAL 2"###"MANUTENวรO"
PUTSX1(CPERG,"04" ,STR0034     ,STR0034     ,STR0034     ,"MV_CH4" ,"C" ,09     ,0      ,0     ,"G","" ,"FPI"	,"","","MV_PAR04",""            	,"","",""   			,"","",""           ,""   	,"",""			,"","","","","",,,) //"NR. DE B.V DE ?"###"NR. DE B.V DE ?"###"NR. DE B.V DE ?"
PUTSX1(CPERG,"05" ,STR0035    ,STR0035    ,STR0035    ,"MV_CH5" ,"C" ,09     ,0      ,0     ,"G","" ,"FPI"	,"","","MV_PAR05",""            	,"","",""   			,"","",""           ,""   	,"",""			,"","","","","",,,) //"NR. DE B.V ATE ?"###"NR. DE B.V ATE ?"###"NR. DE B.V ATE ?"
*/
RETURN



/*
STATIC FUNCTION VALIDPERG
LOCAL _SALIAS := ALIAS()
LOCAL AREGS := {}
LOCAL I,J

DBSELECTAREA("SX1")
DBSETORDER(1)
CPERG := PADR(CPERG,10)

//          GRUPO/ORDEM/PERGUNTA                                                            /VARIAVEL /TIPO/TAMANHO/DECIMAL/PRESEL/GSC/VALID/VAR01     /DEF01         /DEF01         /DEF01         /CNT01/VAR02/DEF02        /DEF02        /DEF02        /CNT02/VAR03/DEF03			/DEF03			/DEF03/CNT03/VAR04	/DEF04	/DEF04	/DEF04/CNT04/VAR05/DEF05/DEF05/DEF05/CNT05/F3      /PYME/SXG/HELP/PICTURE/IDFIL
AADD(AREGS,{CPERG,"01" ,"DATA DE       ?"     ,"DATA DE       ?"     ,"DATA DE       ?"     ,"MV_CH1" ,"D" ,08     ,0      ,0     ,"G",""   ,"MV_PAR01",""            ,""            ,""            ,""   ,""   ,""           ,""           ,""           ,""   ,""   ,""   			,""   			,""   ,""   ,""   	,""   	,""   	,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""      ,"S" ,"" ,"" ,""})
AADD(AREGS,{CPERG,"02" ,"DATA ATE      ?"     ,"DATA ATE      ?"     ,"DATA ATE      ?"     ,"MV_CH2" ,"D" ,08     ,0      ,0     ,"G",""   ,"MV_PAR02",""            ,""            ,""            ,""   ,""   ,""           ,""           ,""           ,""   ,""   ,""   			,""   			,""   ,""   ,""   	,""   	,""   	,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""      ,"S" ,"" ,"" ,""})
//AADD(AREGS,{CPERG,"03" ,"TIPO DE VALE ?"      ,"TIPO DE VALE ?"      ,"TIPO DE VALE ?"      ,"MV_CH3" ,"N" ,01     ,0      ,2     ,"C",""   ,"MV_PAR03","GUINDASTE"   ,"GUINDASTE"   ,"GUINDASTE"   ,""   ,""   ,"TRANSPORTES","TRANSPORTES","TRANSPORTES",""   ,""   ,"PLATAFORMA"   ,"PLATAFORMA"   ,""   ,""   ,"GRUA"	,"GRUA"	,"GRUA"	,""   ,""   ,"MANUTENวรO"   ,"MANUTENวรO"   ,"MANUTENวรO"   ,""   ,""   ,""      ,"S" ,"" ,"" ,""})
AADD(AREGS,{CPERG,"03" ,"TIPO DE VALE ?"      ,"TIPO DE VALE ?"      ,"TIPO DE VALE ?"      ,"MV_CH3" ,"N" ,01     ,0      ,2     ,"C",""   ,"MV_PAR03","EQUIPAMENTO"   ,"EQUIPAMENTO"   ,"EQUIPAMENTO"   ,""   ,""   ,"TRANSPORTES","TRANSPORTES","TRANSPORTES" ,""    ,""   			,"NรO USADO" ,"NรO USADO" ,""   ,"NรO USADO"   	,"NรO USADO"		,"NรO USADO"		,""		,""   	,""   ,"MANUTENวรO"   ,"MANUTENวรO"   ,"MANUTENวรO"   ,""   ,""   ,""      ,"S" ,"" ,"" ,""})
AADD(AREGS,{CPERG,"04" ,"NR. DE B.V DE ?"     ,"NR. DE B.V DE ?"     ,"NR. DE B.V DE ?"     ,"MV_CH4" ,"C" ,09     ,0      ,0     ,"G",""   ,"MV_PAR04",""            ,""            ,""            ,""   ,""   ,""           ,""           ,""           ,""   ,""   ,""   			,""   			,""   			,""   	,""   	,""   	,""   	,""   	,""   ,""   ,""   ,""   ,""   ,""   ,"FPI"   ,"S" ,"" ,"" ,""})
AADD(AREGS,{CPERG,"05" ,"NR. DE B.V ATE ?"    ,"NR. DE B.V ATE ?"    ,"NR. DE B.V ATE ?"    ,"MV_CH5" ,"C" ,09     ,0      ,0     ,"G",""   ,"MV_PAR05",""            ,""            ,""            ,""   ,""   ,""           ,""           ,""           ,""   ,""   ,""   			,""   			,""   			,""   	,""   	,""   	,""   	,""   	,""   ,""   ,""   ,""   ,""   ,""   ,"FPI"   ,"S" ,"" ,"" ,""})

FOR I:=1 TO LEN(AREGS)
	IF !DBSEEK(CPERG+AREGS[I,2])
		RECLOCK("SX1",.T.)
		FOR J:=1 TO FCOUNT()
			IF J <= LEN(AREGS[I])
				FIELDPUT(J,AREGS[I,J])
			ENDIF
		NEXT J 
		MSUNLOCK()
	ELSE
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
*/
