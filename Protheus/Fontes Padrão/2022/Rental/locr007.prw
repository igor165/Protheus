#INCLUDE "locr007.ch" 
/*/{PROTHEUS.DOC} LOCR007.PRW
ITUP BUSINESS - TOTVS RENTAL
IMPRESSAO DO VALE VIAGEM
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "PROTHEUS.CH"

FUNCTION LOCR007(_CNUM)
// --> DECLARACAO DE VARIAVEIS
LOCAL CDESC1         := STR0001 //"ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR O RECIBO DO VALE   "
LOCAL CDESC2         := STR0002 //"POSICIONADO NA TELA."
LOCAL CDESC3         := STR0003 //"EMISSAO RECIBO DE VALE "
LOCAL TITULO         := STR0003 //"EMISSAO RECIBO DE VALE "
LOCAL NLIN           := 80
LOCAL CABEC1         := ""
LOCAL CABEC2         := ""
LOCAL AORD           := {}
LOCAL IMPRIME 

PRIVATE LEND         := .F.
PRIVATE LABORTPRINT  := .F.
PRIVATE LIMITE       := 220
PRIVATE TAMANHO      := "G"
PRIVATE NOMEPROG     := "VALE" // COLOQUE AQUI O NOME DO PROGRAMA PARA IMPRESSAO NO CABECALHO
PRIVATE NTIPO        := 18
PRIVATE ARETURN      := { "ZEBRADO", 1, "ADMINISTRACAO", 2, 2, 1, "", 1}
PRIVATE NLASTKEY     := 0
PRIVATE CPERG        := "LOCP065"
PRIVATE CBTXT        := SPACE(10)
PRIVATE CBCONT       := 00
PRIVATE CONTFL       := 01
PRIVATE M_PAG        := 01
PRIVATE NQTDVO       := 0
PRIVATE WNREL        := 'RECVALE' 		// COLOQUE AQUI O NOME DO ARQUIVO USADO PARA IMPRESSAO EM DISCO
PRIVATE _NCVALE      := _CNUM
PRIVATE CSTRING      := "FPH"

IMPRIME := .T.

DBSELECTAREA("FPH")
DBSETORDER(1)   

VALIDPERG()								// CRIA PERGUNTAS
IF PERGUNTE(CPERG,.T.)
	IF MV_PAR01 == 1					// MATRICIAL 
		// --> MONTA A INTERFACE PADRAO COM O USUARIO... 
		WNREL := SETPRINT(CSTRING,NOMEPROG,""/*CPERG*/,@TITULO,CDESC1,CDESC2,CDESC3,.F.,AORD,.T.,TAMANHO,,.F.)
		IF NLASTKEY == 27
			RETURN
		ENDIF
		
		SETDEFAULT(ARETURN,CSTRING)
		
		IF NLASTKEY == 27
		   RETURN
		ENDIF
		
		NTIPO := IF(ARETURN[4]==1,15,18)
		
		// --> PROCESSAMENTO. RPTSTATUS MONTA JANELA COM A REGUA DE PROCESSAMENTO. 
	 //	VERIMP()
	
		RPTSTATUS({|| RUNREPORT(CABEC1,CABEC2,TITULO,NLIN) },TITULO)
	ELSE 								// A4
		RPTSTATUS({|| IMPA4() },TITULO)
	ENDIF
ENDIF

RETURN



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFUNO    ณ RUNREPORT บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 01/01/2007 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRIO ณ FUNCAO AUXILIAR CHAMADA PELA RPTSTATUS. A FUNCAO RPTSTATUS บฑฑ
ฑฑบ          ณ MONTA A JANELA COM A REGUA DE PROCESSAMENTO.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION RUNREPORT(CABEC1,CABEC2,TITULO,NLIN)

LOCAL NTOTAL   := NQTDTO := 0   
LOCAL COBS01   := ""
LOCAL COBS02   := ""
LOCAL COBS03   := ""
LOCAL CFUNCAO  := ""
LOCAL NX       := 0 
LOCAL I        := 0 

DBSELECTAREA("FPH")

// DADOS DO VALE
CPROJETO   := FPH_SOT
CEMISSAO   := FPH_EMISSAO
CVALE      := FPH_NRVALE
CMODFOR    := FPH_MODFOR
CMOTORISTA := FPH_MOTORI  
CVIAGEM    := FPH_VIAGEM
NVALOR     := FPH_VALOR
LAPROVA    := FPH_APROVA 
CNRBV      := FPH_NRBV      
COBS       := FPH_OBS
CNOME      :=  ""
CSIT       := FPH->FPH_APROVA              

// COMPOSIวAO DAS LINHAS DE OBSERVAวีES.
IF LEN(COBS) > 59
	COBS01 := SUBSTR(COBS,1,59)
	FOR NX := 2 TO 3 
		IF NX == 2
			COBS02 := SUBSTR(COBS,(59*(NX-1))+1,59) 
		ELSE
			COBS03 := SUBSTR(COBS,(59*(NX-1))+1,59) 
		ENDIF 
	NEXT 
ELSE
	COBS01 := SUBSTR(COBS,1,59)
ENDIF

DBSELECTAREA("FPI")
DBSETORDER(1)
DBSEEK(XFILIAL("FPI") + CNRBV)   
CVIAGEM := IIF(!EMPTY(FPI->FPI_SOT),FPI->FPI_SOT,FPI->FPI_NOMCCU)
CDEPTO  := IIF(FPH->FPH_TIPAD=="2",STR0004, STR0005) //"2 - TRANSPORTE"###"1 - GUINDASTE"
CVIAGEM := PADR(CVIAGEM,25)  
CFROTA  := FPI->FPI_FROTA

DBSELECTAREA("DA4")
DBSETORDER(1)
DBSEEK(XFILIAL("DA4") + CMOTORISTA)   
CNOME := DA4_NOME               

// POSICIONANDO PARA LOCALIZAR A FUNวรO DO MOTORISTA
DBSELECTAREA("SRA")
DBSETORDER(1)
IF DBSEEK(XFILIAL("SRA")+DA4->DA4_MAT)  
	DBSELECTAREA("SRJ")
	DBSETORDER(1)
	IF DBSEEK(XFILIAL("SRJ")+SRA->RA_CODFUNC)     
		CFUNCAO := SRJ->RJ_DESC
	ENDIF
ENDIF

DBSELECTAREA("FPH")

@ 01, 00      PSAY CHR(18)+"|---------------------------------------------------------------------|"
@ 02, 01      PSAY SUBSTR(SM0->M0_NOMECOM,1,40)
@ 03, 01      PSAY STR0006+ DTOC(DDATABASE)+ STR0007+ TIME()+ STR0008  //"   IMPRESSO EM: "###" มS "###" HS"
@ 04, 00      PSAY "========================================   USUมRIO...: " + SUBSTR(CUSUARIO,7,15)
@ 05, 00      PSAY REPLICATE("-",42)+":"+REPLICATE("-",37)
     
@ 06, 00      PSAY "|--------------------------- V A L E    V I A G E M --------------------------|"
@ 07, 05      PSAY STR0009 + CVALE +"                           R$  " + ALLTRIM(STR(NVALOR,18,2))  //" N. VALE: "
@ 08, 04      PSAY "==========================                   ===============================" 
@ 09, 03      PSAY EXTENSO(NVALOR)+ REPLICATE("*",77 - LEN(EXTENSO(NVALOR)))
@ 11, 03      PSAY REPLICATE("*",77)
@ 12, 00      PSAY "|--------------------------------------------------------------------------|"
FOR I := 1 TO 1
	@ 13, 05  PSAY STR0010   + UPPER(CNOME)  //"NOME :  "
	@ 14, 05  PSAY STR0011 + UPPER(CFUNCAO)  //"FUNวรO :  "
NEXT I 
IF LEN(CNRBV)>0
	@ 15, 05  PSAY STR0012 + CNRBV+"                          DATA BOLETIM: " + SUBSTRING(DTOS(CEMISSAO),7,2 )+ "/" + SUBSTRING(DTOS(CEMISSAO),5,2) + "/" + SUBSTRING(DTOS(CEMISSAO),3,2) //" BOLETIM: "
ENDIF
@ 16, 05      PSAY STR0013 + SUBSTRING(DTOS(CEMISSAO),7,2 )+ "/" + SUBSTRING(DTOS(CEMISSAO),5,2) + "/" + SUBSTRING(DTOS(CEMISSAO),3,2) //" DATA DO VALE: "
@ 17, 05      PSAY STR0014 + CFROTA //" FROTA.......: "
@ 18, 05      PSAY STR0015 + CVIAGEM + STR0016 +CDEPTO  //" PROJETO/C.C.: "###"       DEPARTAMENTO:"
@ 19, 05      PSAY STR0017 + FPI->FPI_NOMCLI //" CLIENTE: "
@ 20, 05      PSAY STR0018 + IIF(CMODFOR=="1",STR0019, STR0020) //" FORNECIMENTO: "###"1 - CAIXA"###"2 - DEPOSITO"
@ 21, 05      PSAY STR0021 + COBS01 //" OBSERVACAO..: "
@ 22, 05      PSAY "               " + COBS02
@ 23, 05      PSAY "               " + COBS03
@ 26, 10      PSAY "____________________                    ______________________________"
@ 27, 10      PSAY STR0022+UPPER(CNOME) //"APROVACAO GERENCIA                       "
@ 28, 00      PSAY "|-------------------------------------------------------------------------------|"
@ 29, 00      PSAY CHR(18)

SET DEVICE TO SCREEN

SETPGEJECT(.F.)

// --> SE IMPRESSAO EM DISCO, CHAMA O GERENCIADOR DE IMPRESSAO... 
IF ARETURN[5]==1
	DBCOMMITALL()
	SET PRINTER TO
	OURSPOOL(WNREL)
ENDIF

MS_FLUSH()

RETURN 



// ======================================================================= \\
STATIC FUNCTION VALIDPERG()
// ======================================================================= \\

LOCAL _SALIAS := ALIAS()
LOCAL AREGS   := {}
LOCAL I , J 

DBSELECTAREA("SX1")
DBSETORDER(1)
CPERG := PADR(CPERG,10)
  AADD(AREGS,{CPERG,"01",STR0023 , "" , "" , "MV_CH1" , "N" , 01,0,0,"C","","MV_PAR01",STR0024,"","","","","A4","","","","","","","","","","","","","","","","","","","","","",""})   //"TIPO DE IMPRESSรO ? "###"MATRICIAL"
//AADD(AREGS,{CPERG,"01","VALE NO. :          " , "" , "" , "MV_CH1" , "C" , 10,00,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","FPH","S","",""})
//AADD(AREGS,{CPERG,"02","DO PERIODO         ?" , "" , "" , "MV_CH2" , "D" , 08,00,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
//AADD(AREGS,{CPERG,"03","ATE PERIODO        ?" , "" , "" , "MV_CH3" , "D" , 08,00,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
//AADD(AREGS,{CPERG,"04","PRODUTO DE  	    ?"  , "" , "" , "MV_CH4" , "C" , 15,00,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SB1","S","",""})
//AADD(AREGS,{CPERG,"05","PRODUTO ATE  	    ?"  , "" , "" , "MV_CH5" , "C" , 15,00,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SB1","S","",""})
//AADD(AREGS,{CPERG,"06","NUM. MESES S/ MOV. ?" , "" , "" , "MV_CH6" , "N" , 02,00,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
FOR I:=1 TO LEN(AREGS)
	IF !DBSEEK(CPERG+AREGS[I,2])
		RECLOCK("SX1",.T.)
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
  


// ======================================================================= \\
STATIC FUNCTION IMPA4()
// ======================================================================= \\

PRIVATE CCABEC   := ""

OOBJPRINT:= TMSPRINTER():NEW(CCABEC)
OOBJPRINT:SETSIZE( 210, 297 )

LJMSGRUN(STR0025,,{|| IMPREL() }) //"POR FAVOR AGUARDE, VALES..."

OOBJPRINT:PREVIEW()

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ IMPREL    บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 30/06/2007 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION IMPREL()

LOCAL NTOTAL   := NQTDTO := 0   
LOCAL COBS01   := ""
LOCAL COBS02   := ""
LOCAL COBS03   := ""
LOCAL CFUNCAO  := ""
LOCAL NX       := 0 

PRIVATE OFONT1 := TFONT():NEW("ARIAL"     ,11,11,,.F.,,,,,.F.)   // NORMAL
PRIVATE OFONT2 := TFONT():NEW("ARIAL"     ,16,16,,.F.,,,,,.F.)   // NORMAL

DBSELECTAREA("FPH")

// DADOS DO VALE
CPROJETO   := FPH_SOT
CEMISSAO   := FPH_EMISSAO
CVALE      := FPH_NRVALE
CMODFOR    := FPH_MODFOR
CMOTORISTA := FPH_MOTORI  
CVIAGEM    := FPH_VIAGEM
NVALOR     := FPH_VALOR
LAPROVA    := FPH_APROVA 
CNRBV      := FPH_NRBV      
COBS       := FPH_OBS
CNOME      :=  ""
CSIT       := FPH->FPH_APROVA              

// COMPOSIวAO DAS LINHAS DE OBSERVAวีES.
IF LEN(COBS) > 59
	COBS01 := SUBSTR(COBS,1,59)
	FOR NX := 2 TO 3 
		IF NX == 2
			COBS02 := SUBSTR(COBS,(59*(NX-1))+1,59)   
		ELSE
			COBS03 := SUBSTR(COBS,(59*(NX-1))+1,59)      
		ENDIF
	NEXT  
ELSE
	COBS01 := SUBSTR(COBS,1,59)
ENDIF

DBSELECTAREA("FPI")
DBSETORDER(1)
DBSEEK(XFILIAL("FPI") + CNRBV)   
CVIAGEM := IIF(!EMPTY(FPI->FPI_SOT) , FPI->FPI_SOT , FPI->FPI_NOMCCU) 
CDEPTO  := IIF(FPH->FPH_TIPAD=="2",STR0004, STR0026) //"2 - TRANSPORTE"###"1 - EQUIPAMENTO"
CVIAGEM := PADR(CVIAGEM,25)  
CFROTA  := FPI->FPI_FROTA

DBSELECTAREA("DA4")
DBSETORDER(1)
DBSEEK(XFILIAL("DA4") + CMOTORISTA)   
CNOME   := DA4_NOME
   
// POSICIONANDO PARA LOCALIZAR A FUNวรO DO MOTORISTA
DBSELECTAREA("SRA")
DBSETORDER(1)
IF DBSEEK(XFILIAL("SRA")+DA4->DA4_MAT)  
	DBSELECTAREA("SRJ")
	DBSETORDER(1)
	IF DBSEEK(XFILIAL("SRJ")+SRA->RA_CODFUNC)     
		CFUNCAO := SRJ->RJ_DESC
	ENDIF
ENDIF
   
DBSELECTAREA("FPH")
OOBJPRINT:SAY( 0050 , 0050 ,  "|"+REPLICATE("-",121)+"|", OFONT2   , 100 )
OOBJPRINT:SAY( 0150 , 0050 ,  SUBSTR(SM0->M0_NOMECOM,1,40), OFONT2   , 100 )
OOBJPRINT:SAY( 0250 , 0050 ,  STR0027+ DTOC(DDATABASE)+ STR0007+ TIME()+ STR0008 + STR0028 + SUBSTR(CUSUARIO,7,15), OFONT2   , 100 )  //" IMPRESSO EM: "###" มS "###" HS"###" - USUมRIO...: "
OOBJPRINT:SAY( 0350 , 0050 ,  "|"+REPLICATE("-",45)+STR0029+REPLICATE("-",45)+"|", OFONT2   , 100 )   //" V A L E    V I A G E M "
OOBJPRINT:SAY( 0450 , 0150 ,  STR0009 + CVALE +"                           R$  " + ALLTRIM(STR(NVALOR,18,2)), OFONT2   , 100 ) //" N. VALE: "
OOBJPRINT:SAY( 0550 , 0150 ,  "=========================                  =========================", OFONT2   , 100 )
OOBJPRINT:SAY( 0650 , 0150 ,  EXTENSO(NVALOR)+ REPLICATE("*",77 - LEN(EXTENSO(NVALOR))), OFONT2   , 100 )
OOBJPRINT:SAY( 0750 , 0150 ,  REPLICATE("*",77), OFONT2   , 100 )
OOBJPRINT:SAY( 0850 , 0050 ,  "|"+REPLICATE("-",121)+"|", OFONT2   , 100 )
OOBJPRINT:SAY( 0950 , 0050 ,  STR0030 + UPPER(CNOME) , OFONT2   , 100 ) //"NOME:  "
OOBJPRINT:SAY( 1050 , 0050 ,  STR0031 + CFUNCAO, OFONT2   , 100 ) //"FUNวรO:  "
IF LEN(CNRBV)>0
	OOBJPRINT:SAY( 1150 , 0050 ,  STR0012 + CNRBV+"                          DATA BOLETIM: " + SUBSTRING(DTOS(CEMISSAO),7,2 )+ "/" + SUBSTRING(DTOS(CEMISSAO),5,2) + "/" + SUBSTRING(DTOS(CEMISSAO),3,2) , OFONT2   , 100 ) //" BOLETIM: "
ENDIF                                                           
OOBJPRINT:SAY( 1250 , 0050 ,  STR0013 + SUBSTRING(DTOS(CEMISSAO),7,2 )+ "/" + SUBSTRING(DTOS(CEMISSAO),5,2) + "/" + SUBSTRING(DTOS(CEMISSAO),3,2) , OFONT2   , 100 ) //" DATA DO VALE: "
OOBJPRINT:SAY( 1350 , 0050 ,  STR0014 + CFROTA , OFONT2   , 100 ) //" FROTA.......: "
OOBJPRINT:SAY( 1450 , 0050 ,  STR0015 + CVIAGEM + STR0016 +CDEPTO, OFONT2   , 100 ) //" PROJETO/C.C.: "###"       DEPARTAMENTO:"
OOBJPRINT:SAY( 1550 , 0050 ,  STR0017 + FPI->FPI_NOMCLI, OFONT2   , 100 ) //" CLIENTE: "
OOBJPRINT:SAY( 1650 , 0050 ,  STR0018 + IIF(CMODFOR=="1",STR0019, STR0020) , OFONT2   , 100 ) //" FORNECIMENTO: "###"1 - CAIXA"###"2 - DEPOSITO"
OOBJPRINT:SAY( 1750 , 0050 ,  STR0021, OFONT2   , 100 ) //" OBSERVACAO..: "
OOBJPRINT:SAY( 1750 , 0350 ,  COBS01 , OFONT2   , 100 )
OOBJPRINT:SAY( 1850 , 0350 ,  COBS02 , OFONT2   , 100 )
OOBJPRINT:SAY( 1950 , 0350 ,  COBS03 , OFONT2   , 100 ) 
OOBJPRINT:SAY( 2050 , 0250 ,  "____________________                    ______________________________" , OFONT2   , 100 )
OOBJPRINT:SAY( 2150 , 0250 ,  STR0022+UPPER(CNOME) , OFONT2   , 100 ) //"APROVACAO GERENCIA                       "
OOBJPRINT:SAY( 2250 , 0050 ,  "|"+REPLICATE("-",130)+"|", OFONT2   , 100 )
    
OOBJPRINT:ENDPAGE()
LCHEK := .T.
NCOL1 := 0
NCOL2 := 0

RETURN


/*
// ======================================================================= \\
STATIC FUNCTION IMP_GRUA() 
// ======================================================================= \\
// --> NรO EXISTE CHAMADA DA FUNวรO !

PRIVATE OFONT1  := TFONT():NEW("ARIAL"     ,11,11,,.F.,,,,,.F.)   // NORMAL
PRIVATE OFONT2  := TFONT():NEW("ARIAL"     ,18,18,,.T.,,,,,.F.)   // NEGRITO
PRIVATE OFONT3  := TFONT():NEW("ARIAL"     ,11,11,,.T.,,,,,.T.)   // NEGRITO / SUBLINHADO
PRIVATE OFONT4  := TFONT():NEW("ARIAL"     ,10,10,,.F.,,,,,.F.)   // NORMAL
PRIVATE OFONT5  := TFONT():NEW("ARIAL"     ,10,10,,.T.,,,,,.F.)   // NEGRITO
PRIVATE OFONT6  := TFONT():NEW("ARIAL"     ,10,10,,.T.,,,,,.T.)   // NEGRITO / SUBLINHADO
PRIVATE OFONT7  := TFONT():NEW("VENDANA"   ,07,07,,.F.,,,,,.F.)   // NORMAL
PRIVATE OFONT8  := TFONT():NEW("VENDANA"   ,07,07,,.F.,,,,,.T.)   // SUBLINHADO
PRIVATE OFONT9  := TFONT():NEW("ARIAL"     ,08,08,,.F.,,,,,.F.)   // NORMAL
PRIVATE OFONT10 := TFONT():NEW("ARIAL"     ,08,08,,.T.,,,,,.F.)   // NEGRITO
PRIVATE OFONT11 := TFONT():NEW("ARIAL"     ,07,07,,.F.,,,,,.F.)   // NORMAL
PRIVATE OFONT12 := TFONT():NEW("ARIAL"     ,07,07,,.T.,,,,,.F.)   // NORMAL

// --> CRIA AS TABELAS TEMPORARIA PARA GERACAO DO RELATORIO. 
AAREAZA0:=FP0->(GETAREA())
AAREAZA1:=FP1->(GETAREA())
AAREAZA5:=FP4->(GETAREA())
AAREAZA6:=ZA6->(GETAREA())
AAREASE4:=SE4->(GETAREA())

FQ5->(DBSETORDER(8))                                                   
FQ5->(DBSEEK(XFILIAL("FQ5")+FP0->FP0_PROJET))

IMPREL()
OOBJPRINT:ENDPAGE()

RESTAREA(AAREAZA0)
RESTAREA(AAREAZA1)
RESTAREA(AAREAZA5)
RESTAREA(AAREAZA6)
RESTAREA(AAREASE4)

RETURN(NIL) 
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ VERIMP    บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 01/01/2007 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
STATIC FUNCTION VERIMP()

LOCAL NLIN := 80

IF ARETURN[5]==2
	
	NOPC       := 1
	#IFNDEF WINDOWS
		CCOR       := "B/BG"
	#ENDIF
	WHILE .T.
		
		SETPRC(0,0)
		DBCOMMITALL()
		
		@ NLIN ,054 PSAY "*"
		
		#IFNDEF WINDOWS
			SET DEVICE TO SCREEN
			DRAWADVWINDOW(" FORMULARIO ",10,25,14,56)
			SETCOLOR(CCOR)
			@ 12,27 SAY "FORMULARIO ESTA POSICIONADO?"
			NOPC := MENUH({"SIM","NAO","CANCELA IMPRESSAO"},14,26,"B/W,W+/N,R/W","SNC","",1)
			SET DEVICE TO PRINT
		#ELSE
			IF     MSGYESNO("FOMULARIO ESTA POSICIONADO ? ")
				NOPC := 1
			ELSEIF MSGYESNO("TENTA NOVAMENTE ? ")
				NOPC := 2
			ELSE
				NOPC := 3
			ENDIF
		#ENDIF
		
		DO CASE
		CASE NOPC==1
			LCONTINUA := .T.
			EXIT
		CASE NOPC==2
			LOOP
		CASE NOPC==3
			LCONTINUA := .F. 
			RETURN
		ENDCASE
	ENDDO 
ENDIF

RETURN
*/
