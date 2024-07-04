#INCLUDE "loca035.ch" 
/*/{PROTHEUS.DOC} LOCA035.PRW
ITUP BUSINESS - TOTVS RENTAL
ESTORNO DA C.T.R.C. ( ESTORNA A NOTA FISCAL E PEDIDOS DE VENDA GERADOS )
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
#INCLUDE "PROTHEUS.CH"     
#INCLUDE "TOPCONN.CH"

FUNCTION LOCA035()
LOCAL AREGSD2 := {}
LOCAL AREGSE1 := {}
LOCAL AREGSE2 := {}
LOCAL LVALIDO := .F.
LOCAL CNUMNF  := CRIAVAR("F2_DOC")
LOCAL CSERIE  := CRIAVAR("F2_SERIE")

PRIVATE LMOSTRACTB  := LAGLCTB := LCONTAB := LCARTEIRA := .F.
PRIVATE LMSERROAUTO := .F.
PRIVATE	LMSHELPAUTO := .F.

AAREASF2 := SF2->(GETAREA())
AAREASC5 := SC5->(GETAREA())
AAREASC9 := SC9->(GETAREA())

IF !MSGYESNO(STR0001) //"CONFIRMA O ESTORNO DO C.T.R.C ?"
	RETURN .T.
ENDIF

DBSELECTAREA("SF2")
DBSETORDER(1)
DBGOTOP()
IF MSSEEK(XFILIAL("SF2") + FQ5->FQ5_NUMCTR + FQ5->FQ5_SERCTR)
	LVALIDO := .T.
	CCODCLI := SF2->F2_CLIENTE
	CLOJA   := SF2->F2_LOJA
	_TIPOMOV:= "S"
	_SERIE	:= SF2->F2_SERIE
	_NFISCAL:= SF2->F2_DOC
ELSE
	MSGALERT(STR0002 , STR0003)  //"NAO EXISTE NOTA FISCAL PARA O ITEM INFORMADO !"###"GPO - LOCF015.PRW"
ENDIF
/*
IF !EMPTY(FQ5->FQ5_CTRDES)
	LVALIDO := .F.
	MSGALERT("JÁ EXISTE CTRC COMPLEMENTAR PARA ESTA VIAGEM (VIAGEM " + FQ5->FQ5_CTRDES + ") !")
ENDIF
*/
IF !EMPTY(FQ5->FQ5_CTRDES)//TEM COMPLEMENTO
	LVALIDO := VERIFCTR(FQ5->FQ5_AS , FQ5->FQ5_CTRDES) 
	IF !LVALIDO
		MSGALERT(STR0004 , STR0003)  //"NÃO É POSSIVEL ESTORNAR O CTRC, POIS O CTRC COMPLEMENTAR ESTÁ GERADO!"###"GPO - LOCF015.PRW"
	ENDIF
ENDIF                       

IF !LVALIDO .AND. EMPTY(FQ5->FQ5_TPCTRC)//REGRA VALIDA SOMENTE PARA CTRC NORMAL, E NAO COMPLEMENTO.
	LVALIDO := PRAZOCANC()
	IF !LVALIDO
		MSGALERT(STR0005+ALLTRIM(STR(GETMV("MV_CTEEXC")))+" DIAS ("+ALLTRIM(STR(GETMV("MV_CTEEXC")*24))+STR0006 , STR0003)  //"O PRAZO PARA CANCELAMENTO DO CTRC JÁ EXPIROU, PRAZO MÁXIMO PARA ESTORNO É: "###" HORAS) !"###"GPO - LOCF015.PRW"
	ENDIF
ENDIF

BEGIN TRANSACTION
// --> VERIFICA SE O ESTORNO DO DOCUMENTO DE SAIDA PODE SER FEITO     ³
IF LVALIDO .AND. MACANDELF2("SF2",SF2->(RECNO()),@AREGSD2,@AREGSE1,@AREGSE2)
	// --> ESTORNA O DOCUMENTO DE SAIDA                                   ³
   	LJMSGRUN(STR0007,,{|| SF2->(MADELNFS(AREGSD2,AREGSE1,AREGSE2,LMOSTRACTB,LAGLCTB,LCONTAB,LCARTEIRA)) } ) //"AGUARDE...EXCLUINDO NOTA FISCAL CTRC..."
	MSUNLOCKALL()

	LJMSGRUN(STR0008,,{|| EXCLUIPV() } ) //"AGUARDE...EXCLUINDO PEDIDO DE VENDA CTRC..."

	LJMSGRUN(STR0009 ,,{|| EXCLUILF(_TIPOMOV , _SERIE , _NFISCAL , CCODCLI , CLOJA) } )  //"AGUARDE...EXCLUINDO LIVROS FISCAIS CTRC..."
	
	LJMSGRUN(STR0010,,{|| EXCLUITMS() } ) //"AGUARDE...INFORMAÇÕES DO TMS REFERENTE AO CTRC..."

    RECLOCK("FQ5",.F.)
	FQ5->FQ5_NUMCTR := CNUMNF
	FQ5->FQ5_SERCTR := CSERIE
	FQ5->FQ5_NUMPV  := ""  
//	FQ5->FQ5_VLRINF := 0.00 
//	FQ5->FQ5_TOTFRE := 0.00 
    FQ5->(MSUNLOCK()) 
ENDIF

END TRANSACTION

RESTAREA(AAREASF2)
RESTAREA(AAREASC5)
RESTAREA(AAREASC9)

RETURN .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ EXCLUIPV  º AUTOR ³ IT UP BUSINESS     º DATA ³ 26/04/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ ESTORNA E EXCLUI O PEDIDO DE VENDA C.T.R.C                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION EXCLUIPV()

PRIVATE	LLIBER    := .F.
PRIVATE	LTRANSF   := .F.
PRIVATE	LLIBEROK  := .F.
PRIVATE	LRESIDOK  := .F.
PRIVATE	LFATUROK  := .F.
PRIVATE	NVLRCRED  := 0
PRIVATE	NMOEDAORI := 1

// --> ESTORNA PEDIDOS DE VENDA. 
DBSELECTAREA("SC5")
DBSETORDER(1)
DBSEEK(XFILIAL("SC5")+FQ5->FQ5_NUMPV)
WHILE !EOF() .AND. SC5->C5_FILIAL == XFILIAL("SC5") .AND. SC5->C5_NUM == FQ5->FQ5_NUMPV

	ACABPV   := {}
	AITEMPV  := {}
	AITEMSC6 := {}

	// --> CARREGA INFORMACOES DO CABECALHO DO PEDIDO DE VENDA.		  ³
	(LOCXCONV(1))->( DBSETORDER(1) )
	(LOCXCONV(1))->( DBSEEK("SC5") )
	WHILE !SX3->(EOF()) .AND. GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") == "SC5"
		IF X3USO( &(LOCXCONV(3)) ) .AND. CNIVEL>=GetSx3Cache(&(LOCXCONV(2)),"X3_NIVEL") .AND. GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") != "V"        
			AADD(ACABPV,{GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO"),&(GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")),NIL})      
		ENDIF
		(LOCXCONV(1))->(DBSKIP())
	ENDDO

	DBSELECTAREA("SC6")
	DBSETORDER(1)
	MSSEEK(XFILIAL("SC6")+FQ5->FQ5_NUMPV)
	WHILE !EOF() .AND. SC6->C6_FILIAL == XFILIAL("SC6") .AND. SC6->C6_NUM == FQ5->FQ5_NUMPV
		
		// --> CARREGA INFORMACOES DOS ITENS DO PEDIDO. 
		(LOCXCONV(1))->( DBSETORDER(1) )
		(LOCXCONV(1))->( DBSEEK("SC6") )
		WHILE !(LOCXCONV(1))->(EOF()) .AND. GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") == "SC6"
			IF X3USO( &(LOCXCONV(3)) ) .AND. CNIVEL>=GetSx3Cache(&(LOCXCONV(2)),"X3_NIVEL") .AND. GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") != "V"     
				AADD(AITEMSC6,{GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO"),&(GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")),NIL})     
			ENDIF
			(LOCXCONV(1))->(DBSKIP())
		ENDDO
	
		IF LEN(AITEMSC6) > 0
			AADD(AITEMPV,ACLONE(AITEMSC6))
		ENDIF
		AITEMSC6 := {}
		
		// --> ESTORNA ITEM DO PEDIDO DE VENDA.
		DBSELECTAREA("SC9")
		DBSETORDER(1)
		IF MSSEEK(XFILIAL("SC9")+SC6->C6_NUM+SC6->C6_ITEM)
			MAAVALSC6("SC6",2,"SC5",LLIBER,LTRANSF,@LLIBEROK,@LRESIDOK,@LFATUROK,NIL,@NVLRCRED,NIL,NIL,NMOEDAORI)
		ENDIF
	
		DBSELECTAREA("SC6")
		DBSKIP()
	
    ENDDO

	// --> EXCLUI PEDIDO DE VENDA. 
	IF LEN(ACABPV) > 0 .AND. LEN(AITEMPV) > 0
		MSEXECAUTO({|X,Y,Z|MATA410(X,Y,Z)},ACABPV,{AITEMPV},5)
	ENDIF
	
	IF LMSERROAUTO
		// CRIA O DIRETORIO ERROS, CASO ELE NAO EXISTA
		MAKEDIR("\ERROS\")
		// GRAVA O ERRO GERADO NA PASTA ERROS
		MOSTRAERRO("\ERROS\", "015.LOG")
		ROLLBACKSX8()
	ELSE
   		CONFIRMSX8()
    ENDIF
	
	DBSELECTAREA("SC5")
	DBSKIP()
	
ENDDO

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ EXCLUILF  ºAUTOR  ³ IT UP BUSINESS     º DATA ³ 12/11/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ ESTORNA E EXCLUI O LIVRO FISCAL REFERENTE AO C.T.R.C       º±±
±±º          ³ POIS A FUNÇÃO MADELNFS NÃO EXCLUI MAIS A TABELA SFT        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION EXCLUILF(_TIPOMOV , _SERIE , _NFISCAL , CCODCLI , CLOJA) 

// --> ESTORNA LIVRO FISCAL (SFT) 
DBSELECTAREA("SFT")
DBSETORDER(1)			// FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
DBSEEK(XFILIAL("SFT")+_TIPOMOV+_SERIE+_NFISCAL+CCODCLI+CLOJA)

WHILE !EOF()  .AND.  SFT->FT_FILIAL  == XFILIAL("SFT")  .AND.  SFT->FT_TIPOMOV == _TIPOMOV  .AND.  SFT->FT_SERIE == _SERIE  .AND.  ; 
					 SFT->FT_NFISCAL == _NFISCAL        .AND.  SFT->FT_CLIEFOR == CCODCLI   .AND.  SFT->FT_LOJA  == CLOJA
	RECLOCK("SFT",.F.) 
	SFT->(DBDELETE()) 
	SFT->(MSUNLOCK()) 
	DBSKIP() 
ENDDO 

RETURN 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ EXCLUITMS ºAUTOR  ³MICROSIGA           º DATA ³ 12/12/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION EXCLUITMS()

LOCAL CALIAS := GETNEXTALIAS() 

// RETORNA RENOS A SEREM APAGADOS DA DT6
BEGINSQL ALIAS CALIAS
	SELECT 
		R_E_C_N_O_ REC
	FROM
		%TABLE:DT8%
	WHERE
		%NOTDEL%                            AND  
		DT8_FILDOC = %EXP:FQ5->FQ5_FILORI%  AND  
		DT8_DOC	   = %EXP:FQ5->FQ5_NUMCTR%  AND  
		DT8_SERIE  = %EXP:FQ5->FQ5_SERCTR% 
ENDSQL

// APAGA INFORMAÇÕES DA DT8
WHILE !(CALIAS)->(EOF())
	DBSELECTAREA("DT8") 
	DBGOTO((CALIAS)->REC) 
	
	RECLOCK("DT8",.F.) 
	DT8->(DBDELETE()) 
	DT8->(MSUNLOCK()) 
	
	(CALIAS)->(DBSKIP()) 
ENDDO 

// FECHA O ALIAS
(CALIAS)->(DBCLOSEAREA())

// OBTEM UM NOVO ALIAS
CALIAS	:=	GETNEXTALIAS()

// RETORNA RENOS A SEREM APAGADOS DA DT6
BEGINSQL ALIAS CALIAS
	SELECT 
		R_E_C_N_O_ REC
	FROM
		%TABLE:DT6%
	WHERE
		%NOTDEL%                            AND  
		DT6_FILDOC = %EXP:FQ5->FQ5_FILORI%  AND  
		DT6_DOC	   = %EXP:FQ5->FQ5_NUMCTR%  AND  
		DT6_SERIE  = %EXP:FQ5->FQ5_SERCTR%       
ENDSQL

// APAGA DT6
WHILE !(CALIAS)->(EOF())
	DBSELECTAREA("DT6")
	DBGOTO((CALIAS)->REC)

	RECLOCK("DT6",.F.)
	DT6->(DBDELETE())
	DT6->(MSUNLOCK())
	
	(CALIAS)->(DBSKIP())
ENDDO 

// FECHA O ALIAS
(CALIAS)->(DBCLOSEAREA())

RETURN



// ======================================================================= \\
STATIC FUNCTION VERIFCTR(CAS,CVIAG)
// ======================================================================= \\
// CTR COMPLEMENTAR

LOCAL LRET     := .T.
LOCAL AAREA    := GETAREA() 
LOCAL AAREADTQ := FQ5->(GETAREA())

DBSELECTAREA("FQ5")
DBSETORDER(9) 											// AS+VIAGEM
IF DBSEEK(XFILIAL("FQ5")+CAS+CVIAG)
	IF !EMPTY(FQ5->FQ5_NUMCTR) .AND. FQ5_NUMCTR <> "-"	// CTRC GERADA, RETORNA .F. E NAO PODE ESTORNAR.
		LRET := .F. 
	ENDIF 
ENDIF 

RESTAREA(AAREADTQ)
RESTAREA(AAREA)

RETURN(LRET)



// ======================================================================= \\
STATIC FUNCTION PRAZOCANC() 
// ======================================================================= \\
// VERIFICA PRAZO PARA CANCELAMENTO MV_CTEEXC

LOCAL LRET		:= .T.
LOCAL AAREA		:= GETAREA() 
LOCAL CQUERY	:= ""
LOCAL NDIASCANC	:= GETMV("MV_CTEEXC")
LOCAL CNFE		:= FQ5->FQ5_SERCTR+FQ5->FQ5_NUMCTR 
LOCAL CTIME		:= SUBSTR(TIME(),1,5)
LOCAL CHORANFE	:= ""

CQUERY := " SELECT * "
CQUERY += " FROM   SPED054 "
CQUERY += " WHERE  D_E_L_E_T_ = '' "
CQUERY +=   " AND  NFE_ID = '"+CNFE+"' "
CQUERY := CHANGEQUERY(CQUERY)
IF SELECT("TRB01") > 0
	TRB01->(DBCLOSEAREA())
ENDIF                                                                    
TCQUERY CQUERY NEW ALIAS "TRB01"    

TCSETFIELD("TRB01","DTREC_SEFR","D",08,00) 

DBSELECTAREA("TRB01")

IF     DATEDIFFDAY(DDATABASE,TRB01->DTREC_SEFR) >  NDIASCANC 	// SE MAIOR QUE O PRAZO 
	LRET := .F.          
ELSEIF DATEDIFFDAY(DDATABASE,TRB01->DTREC_SEFR) == NDIASCANC 	// SE IGUAL O PRAZO, VERIFA AS HORAS 
	CTIME 	 := STRTRAN(CTIME,":",".")
	CHORANFE := SUBSTR(TRB01->HRREC_SEFR,1,5)
	CHORANFE := STRTRAN(CHORANFE,":",".")
	IF VAL(CTIME) > VAL(CHORANFE)		
		LRET := .F.
	ENDIF
ENDIF

RESTAREA(AAREA)

RETURN(LRET)
