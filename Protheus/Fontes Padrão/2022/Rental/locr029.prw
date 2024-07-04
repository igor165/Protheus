#INCLUDE "locr029.ch" 
/*/{PROTHEUS.DOC} LOCR029.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATORIO DE MINUTA DE FRETE DE TRANSPORTE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"

FUNCTION LOCR029(NOPC, _CPARAM2)
LOCAL LADJUSTTOLEGACY := .F.
LOCAL LDISABLESETUP   := .F.
LOCAL NRET 

PRIVATE CARQUIVO  := STR0001+STR0002+ALLTRIM(FPF->FPF_PROJET)+"_"+STRTRAN(TIME(),":","")+".PDF" //"TRANSPORTE RODOVIARIO "###"PROJETO "
PRIVATE CLOCAL    := "C:\TRANSPORTE\"
PRIVATE CPROJETO  := FPF->FPF_PROJET
PRIVATE COBRA     := FPF->FPF_OBRA
PRIVATE CAS       := FPF->FPF_AS
PRIVATE DDATA     := FPF->FPF_DATA
PRIVATE CMINUTA   := CEMPANT + FPF->FPF_FILIAL + FPF->FPF_MINUTA
PRIVATE CLSTAS    := ""
PRIVATE CLSTSQCAR := ""
PRIVATE OPRINTER
PRIVATE I         := 0
PRIVATE NLIN      := 10
PRIVATE NFIM      := 55
PRIVATE CLOGO	  := ""
PRIVATE NVALOR	  := 0
PRIVATE CTIPO	  := ""
PRIVATE L		  := 1
PRIVATE CPERG	  := "LOCP066"
PRIVATE CDESCTIPO := _CPARAM2
PRIVATE CTEXTO    := STR0003 //"1A VIA - EMPRESA"

NRET := MAKEDIR(STR0004) //"C:\TRANSPORTE"

IF NOPC = 1
	LDISABLESETUP  := .F.
ELSE
	LDISABLESETUP  := .T.
ENDIF

OPRINTER := FWMSPRINTER():NEW(CARQUIVO, 6, LADJUSTTOLEGACY,, LDISABLESETUP, , , , , , .F., )
OPRINTER:CPATHPDF := CLOCAL
OPRINTER:SETPORTRAIT()
OPRINTER:SETPAPERSIZE(9)
IF NOPC = 1
	OPRINTER:SETVIEWPDF( .T. )
ELSE
	OPRINTER:SETVIEWPDF( .F. )
ENDIF

OFONT1    := TFONTEX():NEW(OPRINTER,"TIMES NEW ROMAN",08,08,.T.,.T.,.F.)// 1
OFONT2    := TFONTEX():NEW(OPRINTER,"TIMES NEW ROMAN",08,08,.F.,.F.,.F.)// 1
OFONT3    := TFONTEX():NEW(OPRINTER,"TIMES NEW ROMAN",16,16,.T.,.T.,.F.)// 1

// LOGO
IF CFILANT $ "0101|0102|0201|0401"
	CLOGO := GETSRVPROFSTRING("STARTPATH","") + SUPERGETMV("MV_LOCX016",,"\system\")  // parametro removido do padr�o
ELSE
	CLOGO := GETSRVPROFSTRING("STARTPATH","") + SUPERGETMV("MV_LOCX017",,"\system\")  // parametro removido do padr�o
ENDIF

// VERIFICA��O DE CARGAS JUNTAS
FQ5->( DBSETORDER(9) )	//	FQ5_FILIAL, FQ5_AS, FQ5_VIAGEM
FQ5->( DBSEEK( XFILIAL("FQ5") + CAS, .T. ) )
AAREADTQ := FQ5->( GETAREA() )

_ASS        := {}
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
		
		IF FQ5->FQ5_STATUS == "6" 
			AADD( _ASS, { FQ5->FQ5_AS, FQ5->FQ5_SEQCAR, FQ5->FQ5_JUNTO, FQ5->( RECNO() ) } )
			CLSTAS    += IIF(EMPTY(CLSTAS)    , "" , ",") + "'"+ALLTRIM(FQ5->FQ5_AS)+"'"
			CLSTSQCAR += IIF(EMPTY(CLSTSQCAR) , "" , ",") + "'"+FQ5->FQ5_SEQCAR+"'"
			FQ5->( DBSEEK( _FQ5_FILIAL + _FQ5_SOT + _FQ5_OBRA, .T. ) )
			LOOP
		ENDIF
	ENDIF
	
	FQ5->( DBSKIP() )
ENDDO 

IF LEN( _ASS ) == 0
	FQ5->( RESTAREA( AAREADTQ ) )
	IF FQ5->FQ5_STATUS == "6"
		AADD( _ASS, { FQ5->FQ5_AS, FQ5->FQ5_SEQCAR, FQ5->FQ5_JUNTO, FQ5->( RECNO() ) } )
		CLSTAS    += "'"+ALLTRIM(FQ5->FQ5_AS)+"'"
		CLSTSQCAR += "'"+FQ5->FQ5_SEQCAR+"'"
	ENDIF
ENDIF

FQ5->( RESTAREA( AAREADTQ ) )

// QUERY 
IF SELECT("TRBZA0") > 0
	TRBFP0->(DBCLOSEAREA())
ENDIF
CSQL     := " SELECT DISTINCT ZA0_CLI,ZA0_LOJA,ZA0_TIPOSE,ZA0_PROJET,ZA0_CLINOM,ZA6_DTINI,ZA6_DTFIM "
CSQL     += ",ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZA6_OBSVIA)),'') AS OBSZA6 ,ZA6_NOMORI,ZA6_ENDORI,ZA6_BAIORI,ZA6_MUNOR2"
CSQL     += ",ZA6_ESTOR2,ZA6_CONORI,ZA6_TELORI,ZA6_NOMDES,ZA6_ENDDES,ZA6_BAIDES,ZA6_MUNDE2,ZA6_ESTDE2,ZA6_CONDES,ZA6_TELDES FROM "+RETSQLNAME("FP0")+ " ZA0"
CSQL     += " INNER JOIN "+RETSQLNAME("ZA6")+ " ZA6 ON ZA6_FILIAL='"+XFILIAL("ZA6")+"' AND ZA0_PROJET = ZA6_PROJET AND ZA6_OBRA='"+COBRA+"'"
CSQL     += " INNER JOIN "+RETSQLNAME("ZA7")+ " ZA7 ON ZA7_FILIAL='"+XFILIAL("ZA7")+"' AND ZA0_PROJET = ZA7_PROJET  AND ZA6_OBRA=ZA7_OBRA "
CSQL     += " WHERE ZA0_FILIAL='"+XFILIAL("FP0")+"'"
CSQL     += " AND ZA0_PROJET ='"+CPROJETO+"' "
//CSQL   += " AND  ZA6_AS ='"+CAS+"' "
IF !EMPTY(CLSTAS)
	CSQL += " AND  ZA7_AS IN ("+CLSTAS+") "
ENDIF
CSQL     += " AND ZA0.D_E_L_E_T_ ='' "
CSQL     += " AND ZA6.D_E_L_E_T_ ='' "
CSQL     += " AND ZA7.D_E_L_E_T_ ='' "
PLSQUERY(CSQL,"TRBZA0")
DBSELECTAREA("TRBZA0")
TRBFP0->(DBGOTOP())

IF SELECT("TRBSUM") > 0
	TRBSUM->(DBCLOSEAREA())
ENDIF

IF EMPTY(TRBFP0->FP0_CLI)
	MSGINFO("N�O H� DADOS A SEREM EXIBIDOS, VERIFIQUE O PROJETO","GPO - RELMINUTA.PRW") 
	RETURN
ENDIF

CSQL:= " SELECT ZA7_DTCAR,ZA7_HRCAR FROM "+RETSQLNAME("ZA7")+ " ZA7"
CSQL+= " WHERE ZA7_FILIAL='"+XFILIAL('ZA7')+"'"
CSQL+= " AND ZA7_PROJET ='"+TRBFP0->FP0_PROJET+"' "
IF !EMPTY(CLSTAS)
	CSQL+= " AND  ZA7_AS IN ("+CLSTAS+") "
ENDIF
CSQL+= " AND  ZA7_OBRA = '"+COBRA+"' "
CSQL+= " AND ZA7.D_E_L_E_T_ ='' "
PLSQUERY(CSQL,"TRBSUM")

DBSELECTAREA("TRBSUM")
TRBSUM->(DBGOTOP())

WHILE !TRBFP0->(EOF())
	FDADOS()
	TRBFP0->(DBSKIP())
ENDDO

RETURN NIL



// ======================================================================= \\
STATIC FUNCTION FDADOS()
// ======================================================================= \\

LOCAL I := 0 

IF L = 1
	OPRINTER:STARTPAGE()
ELSE
	NFIM := NLIN+45
ENDIF

CCNPJ:=POSICIONE("SA1",1,XFILIAL("SA1")+TRBFP0->FP0_CLI+TRBFP0->FP0_LOJA,"A1_CGC")

OPRINTER:BOX(NLIN,10,NFIM,0590)
NLIN += 10
OPRINTER:SAYBITMAP(NLIN,515,CLOGO,0065,0030 )
NLIN += 2
OPRINTER:SAY(NLIN,020,STR0005+CMINUTA,OFONT3:OFONT) //"MINUTA DE FRETE - "
OPRINTER:SAY(NLIN,300,STR0006+TRBFP0->FP0_PROJET,OFONT3:OFONT) //"PROJETO: "
NLIN += 15
OPRINTER:SAY(NLIN,300,STR0007+ DTOC(FPF->FPF_DATA) ,OFONT3:OFONT) //"DATA:      "
OPRINTER:SAY(NLIN,020,STR0008+CDESCTIPO,OFONT3:OFONT) //"TIPO CARREGAMENTO: "
NLIN += 15
OPRINTER:SAY(NLIN,020,CTEXTO,OFONT3:OFONT)
NLIN += 5
NFIM += 15 

OPRINTER:BOX(NLIN,0010,NFIM,0590)
NLIN += 10
OPRINTER:SAY(NLIN,0020,STR0009,OFONT2:OFONT) //"CLIENTE:"
OPRINTER:SAY(NLIN,0050,TRBFP0->FP0_CLINOM,OFONT2:OFONT)
OPRINTER:SAY(NLIN,0315,STR0010,OFONT2:OFONT) //"CNPJ:"
OPRINTER:SAY(NLIN,0335,CCNPJ,OFONT2:OFONT)
NLIN:=NFIM
NFIM+=15
OPRINTER:BOX(NLIN,0010,NFIM,0590)
NLIN += 10
OPRINTER:SAY(NLIN,0020,STR0011,OFONT2:OFONT) //"CARREGAMENTO:"
OPRINTER:SAY(NLIN,0070,DTOC(TRBSUM->ZA7_DTCAR)+" - "+TRANSFORM(TRBSUM->ZA7_HRCAR,"@R 99:99"),OFONT2:OFONT)
OPRINTER:SAY(NLIN,0315,STR0012,OFONT2:OFONT) //"PRAZO DE VIAGEM:"
NVALOR:= (VAL(DTOS(TRBFP0->ZA6_DTFIM)))-(VAL(DTOS(TRBFP0->ZA6_DTINI)))

OPRINTER:SAY(NLIN,0370,CVALTOCHAR(NVALOR),OFONT2:OFONT)

NLIN:=NFIM
NLIN+=0015
OPRINTER:BOX(NLIN,0010,NFIM,0590)
NLIN += 10
OPRINTER:SAY(NLIN,0280,STR0013,OFONT2:OFONT) //"DADOS DO TRANSPORTADOR"

IF SELECT("TRBTRA") > 0
	TRBTRA->(DBCLOSEAREA())
ENDIF

CSQL:= " SELECT FPF_FROTA, T9_NOME, T9_PLACA, ISNULL(ZLO1.FPQ_MAT,'') MOTORISTA, ISNULL(ZLO2.FPQ_MAT,'') AJUDANTE  FROM " + RETSQLNAME("FPF") + " ZBX "
CSQL+= " INNER JOIN " + RETSQLNAME("ST9") + " ST9 ON T9_FILIAL='"+XFILIAL("ST9")+"' AND FPF_FROTA = T9_CODBEM AND ST9.D_E_L_E_T_ = '' "
CSQL+= " LEFT JOIN " + RETSQLNAME("FPQ") + " ZLO1 ON ZLO1.FPQ_FILIAL='"+XFILIAL("FPQ")+"' AND ZLO1.FPQ_PROJET=FPF_PROJET AND ZLO1.FPQ_OBRA=FPF_OBRA AND ZLO1.FPQ_DATA=FPF_DATA "
CSQL+= 		" AND ZLO1.FPQ_AS=FPF_AS AND ZLO1.FPQ_FUNCAO='M' AND ZLO1.D_E_L_E_T_='' "

CSQL+= " LEFT JOIN " + RETSQLNAME("FPQ") + " ZLO2 ON ZLO2.FPQ_FILIAL='"+XFILIAL("FPQ")+"' AND ZLO2.FPQ_PROJET=FPF_PROJET AND ZLO2.FPQ_OBRA=FPF_OBRA AND ZLO2.FPQ_DATA=FPF_DATA "
CSQL+= 		" AND ZLO2.FPQ_AS=FPF_AS AND ZLO2.FPQ_FUNCAO='A' AND ZLO2.D_E_L_E_T_='' "

CSQL+= " WHERE FPF_FILIAL = '"+XFILIAL("FPF")+"' "
CSQL+= " AND FPF_PROJET = '"+CPROJETO+"' "
CSQL+= " AND FPF_OBRA = '"+COBRA+"' "
CSQL+= " AND FPF_DATA = '"+DTOS(DDATA)+"' "
CSQL+= " AND ZBX.D_E_L_E_T_ = ''"
PLSQUERY(CSQL,"TRBTRA")

DBSELECTAREA("TRBTRA")
TRBTRA->(DBGOTOP())

NLIN := NFIM

NFIM+=50
OPRINTER:BOX(NLIN,0010,NFIM,0590)
NLIN += 10
OPRINTER:SAY(NLIN,0020,STR0014,OFONT2:OFONT) //"VEICULO "
OPRINTER:SAY(NLIN,0200,STR0015,OFONT2:OFONT) //"N. FROTA "
OPRINTER:SAY(NLIN,0250,STR0016,OFONT2:OFONT) //"PLACA "
OPRINTER:SAY(NLIN,0300,STR0017,OFONT2:OFONT) //"MOTORISTA "
OPRINTER:SAY(NLIN,0450,STR0018,OFONT2:OFONT) //"AUXILIAR "
NLIN += 10
WHILE TRBTRA->(!EOF())
	OPRINTER:SAY(NLIN,0020,SUBSTR(TRBTRA->T9_NOME,1,40),OFONT2:OFONT)
	OPRINTER:SAY(NLIN,0200,TRBTRA->FPF_FROTA,OFONT2:OFONT)
	OPRINTER:SAY(NLIN,0250,TRBTRA->T9_PLACA,OFONT2:OFONT)
	
	IF ! EMPTY( TRBTRA->MOTORISTA )
		DA4->( DBSETORDER(4) )
		IF DA4->( DBSEEK( XFILIAL("DA4")+TRBTRA->MOTORISTA ) )
			OPRINTER:SAY( NLIN, 300, DA4->DA4_NOME, OFONT2:OFONT)
		ENDIF
	ENDIF
	
	IF ! EMPTY( TRBTRA->AJUDANTE )
		DA4->( DBSETORDER(4) )
		IF DA4->( DBSEEK( XFILIAL("DA4")+TRBTRA->AJUDANTE ) )
			OPRINTER:SAY( NLIN, 450, DA4->DA4_NOME, OFONT2:OFONT)
		ENDIF
	ENDIF
	
	NLIN+=10
	TRBTRA->(DBSKIP())
ENDDO

NLIN := NFIM
NFIM += 15
OPRINTER:BOX(NLIN,0010,NFIM,0590)
NLIN += 10
OPRINTER:SAY(NLIN,0300,STR0019,OFONT2:OFONT) //"DADOS DAS PE�AS"

NLIN:=NFIM
NFIM+=65
OPRINTER:BOX(NLIN,0010,NFIM,0590)
NLIN += 10
OPRINTER:SAY(NLIN,0020,STR0020,OFONT1:OFONT) //"NOME: "
OPRINTER:SAY(NLIN,0200,STR0021,OFONT1:OFONT) //"S�RIE: "
OPRINTER:SAY(NLIN,0250,STR0022,OFONT1:OFONT) //"COMP.: "
OPRINTER:SAY(NLIN,0300,STR0023,OFONT1:OFONT) //"LARGURA: "
OPRINTER:SAY(NLIN,0350,STR0024,OFONT1:OFONT) //"ALTURA: "
OPRINTER:SAY(NLIN,0450,STR0025,OFONT1:OFONT) //"PESO UNIT�RIO: "
OPRINTER:SAY(NLIN,0540,STR0026,OFONT1:OFONT) //"PESO TOTAL: "
NLIN += 10
IF SELECT("TRBPEC") > 0
	TRBPEC->(DBCLOSEAREA())
ENDIF

CSQL:= " SELECT ZA7_COMP,ZA7_LARG,ZA7_ALTU,ZA7_PESO,ZA7_CARGA FROM "+RETSQLNAME("ZA7")+ " ZA7"
CSQL+= " WHERE ZA7_FILIAL='"+XFILIAL("ZA7")+"'
CSQL+= " AND ZA7_PROJET ='"+TRBFP0->FP0_PROJET+"' "
CSQL+= " AND ZA7_OBRA ='"+COBRA+"' "

IF !EMPTY(CLSTAS)
	CSQL+= " AND  ZA7_AS IN ("+CLSTAS+") "
ENDIF

CSQL+= " AND ZA7.D_E_L_E_T_ = '' "
PLSQUERY(CSQL,"TRBPEC")
DBSELECTAREA("TRBPEC")
TRBPEC->(DBGOTOP()) 
NLIN += 10
NPESO:=0
WHILE TRBPEC->(!EOF())
	OPRINTER:SAY(NLIN,0020,TRBPEC->ZA7_CARGA,OFONT1:OFONT)
	OPRINTER:SAY(NLIN,0260,CVALTOCHAR(TRBPEC->ZA7_COMP),OFONT1:OFONT)
	OPRINTER:SAY(NLIN,0310,CVALTOCHAR(TRBPEC->ZA7_LARG),OFONT1:OFONT)
	OPRINTER:SAY(NLIN,0360,CVALTOCHAR(TRBPEC->ZA7_ALTU),OFONT1:OFONT)
	OPRINTER:SAY(NLIN,0460,CVALTOCHAR(TRBPEC->ZA7_PESO),OFONT1:OFONT)
	NLIN  += 10
	NPESO += TRBPEC->ZA7_PESO
	TRBPEC->(DBSKIP())
ENDDO 
NLIN-=10
OPRINTER:SAY(NLIN,0550,CVALTOCHAR(NPESO),OFONT1:OFONT)

NLIN:=NFIM

NFIM+=70

OPRINTER:BOX(NLIN,0010,NFIM,0590)
NLIN+=10
OPRINTER:SAY(NLIN,0020,"ORIGEM: ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0070,"LOCAL: ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0090,TRBFP0->ZA6_NOMORI,OFONT2:OFONT)
NLIN += 10
OPRINTER:SAY(NLIN,0070,"ENDERE�O: ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0110,TRBFP0->ZA6_ENDORI,OFONT2:OFONT)
OPRINTER:SAY(NLIN,0300,"COMPLEMENTO: ",OFONT2:OFONT)
NLIN += 10
OPRINTER:SAY(NLIN,0070,"BAIRRO: ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0100,TRBFP0->ZA6_BAIORI,OFONT2:OFONT)
OPRINTER:SAY(NLIN,0240,"CIDADE: ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0270,TRBFP0->ZA6_MUNOR2,OFONT2:OFONT)
OPRINTER:SAY(NLIN,0540,"UF: ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0560,TRBFP0->ZA6_ESTOR2,OFONT2:OFONT)
NLIN += 10
OPRINTER:SAY(NLIN,0070,"CONTATO: ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0100,TRBFP0->ZA6_CONORI,OFONT2:OFONT)
OPRINTER:SAY(NLIN,0240,"TELEFONE: ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0270,TRBFP0->ZA6_TELORI,OFONT2:OFONT)
NLIN += 15
OPRINTER:SAY(NLIN,0020,"DATA/HORA CHEGADA PORTARIA ",OFONT2:OFONT)
OPRINTER:BOX(NLIN-10,0120,NFIM-5,0240)
OPRINTER:SAY(NLIN,0320,"DATA/HORA CHEGADA PORTARIA ",OFONT2:OFONT)
OPRINTER:BOX(NLIN-10,0420,NFIM-5,0580)
NLIN:=NFIM
NFIM:=NLIN+70
OPRINTER:BOX(NLIN,0010,NFIM,0590)
NLIN += 10
OPRINTER:SAY(NLIN,0020,"DESTINO: ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0070,"LOCAL: ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0090,TRBFP0->ZA6_NOMDES,OFONT2:OFONT)
NLIN += 10
OPRINTER:SAY(NLIN,0070,"ENDERE�O: ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0110,TRBFP0->ZA6_ENDDES,OFONT2:OFONT)
OPRINTER:SAY(NLIN,0300,"COMPLEMENTO: ",OFONT2:OFONT)
NLIN += 10
OPRINTER:SAY(NLIN,0070,"BAIRRO ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0100,TRBFP0->ZA6_BAIDES,OFONT2:OFONT)
OPRINTER:SAY(NLIN,0240,"CIDADE ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0270,TRBFP0->ZA6_MUNDE2,OFONT2:OFONT)
OPRINTER:SAY(NLIN,0540,"UF ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0560,TRBFP0->ZA6_ESTDE2,OFONT2:OFONT)
NLIN += 10
OPRINTER:SAY(NLIN,0070,"CONTATO ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0100,TRBFP0->ZA6_CONDES,OFONT2:OFONT)
OPRINTER:SAY(NLIN,0240,"TELEFONE ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0270,TRBFP0->ZA6_TELDES,OFONT2:OFONT)
NLIN += 15
OPRINTER:SAY(NLIN+5,0020,"DATA/HORA CHEGADA PORTARIA ",OFONT2:OFONT)
OPRINTER:BOX(NLIN-10,0120,NFIM-5,0240)
OPRINTER:SAY(NLIN+5,0320,"DATA/HORA CHEGADA PORTARIA ",OFONT2:OFONT)
OPRINTER:BOX(NLIN-10,0420,NFIM-5,0580)

NLIN:=NFIM
NFIM+=40

OPRINTER:BOX(NLIN,0010,NFIM+25,0590)
NLIN += 10
OPRINTER:SAY(NLIN,0020,"OBSERVA��O: ",OFONT2:OFONT)
XT  := 4 //MLCOUNT(COBSVIA,150)

// POSICIONE NA ZA6 PARA PEGAR O CAMPO MEMO
FOR I:=1 TO XT
	IF I =1
		OPRINTER:SAY( NLIN , 0060 ,  MEMOLINE(TRBFP0->OBSZA6,250, I ),OFONT2:OFONT)
	ELSE
		OPRINTER:SAY( NLIN , 0020 ,  MEMOLINE(TRBFP0->OBSZA6 ,350, I ),OFONT2:OFONT)
	ENDIF
	NLIN += 10
NEXT I 

NLIN := NFIM 
NFIM += 25
OPRINTER:BOX(NLIN,0010,NFIM,0590)
NLIN += 10
OPRINTER:SAY(NLIN,0020,"DATA:   _____ / _______/ __________ ",OFONT2:OFONT)
OPRINTER:SAY(NLIN,0250,"___________________________________________________",OFONT1:OFONT)
NLIN += 10
OPRINTER:SAY(NLIN,0250,"NOME / RG DO CLIENTE ",OFONT2:OFONT)
IF L =1
	CTEXTO := "2A VIA - CLIENTE"
	NLIN   += 10
	L      := 2
	FDADOS()
ELSE
	OPRINTER:ENDPAGE()
 //	U_RELBORDO()	// RELAT�RIO DE BORDO
	CFILEPRINT := CLOCAL+CARQUIVO
	FILE2PRINTER( CFILEPRINT, "PDF" )
	OPRINTER:PREVIEW()
	FREEOBJ(OPRINTER)
	OPRINTER := NIL
ENDIF

RETURN .T.
