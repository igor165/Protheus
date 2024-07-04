#INCLUDE "protheus.ch"
#INCLUDE "TMSAE75.ch"
#INCLUDE 'FWMVCDEF.ch'

#DEFINE EA_MARCA   1
#DEFINE EA_CGCREM  2
#DEFINE EA_NUMNFC  3
#DEFINE EA_SERNFC  4
#DEFINE EA_LOTEDI  5
#DEFINE EA_QTDVOL  6
#DEFINE EA_PESO    7
#DEFINE EA_PESOM3  8
#DEFINE EA_VALOR   9
#DEFINE EA_CGCDES 10
#DEFINE EA_DESPRO 11
#DEFINE EA_STADE5 12
#DEFINE EA_CODPRO 13
#DEFINE EA_CODEMB 14
#DEFINE EA_SERTMS 15
#DEFINE EA_DESSVT 16
#DEFINE EA_TIPTRA 17
#DEFINE EA_DESTPT 18
#DEFINE EA_SERVIC 19
#DEFINE EA_DESSER 20
#DEFINE EA_CODCLI 21
#DEFINE EA_LOJCLI 22
#DEFINE EA_TIPFRE 23
#DEFINE EA_CGCDEV 24
#DEFINE EA_SELORI 25
#DEFINE EA_EMINFC 26
#DEFINE EA_RECDE5 27
#DEFINE EA_NOMREM 28
#DEFINE EA_NOMDES 29
#DEFINE EA_EDIAUT 30
#DEFINE EA_EDILOT 31
#DEFINE EA_EDIFRT 32
#DEFINE EA_FILORI 33
#DEFINE EA_LOTNFC 34
#DEFINE EA_NUMCOT 35
#DEFINE EA_NFEID  36
#DEFINE EA_CGCCON 37
#DEFINE EA_NOMCON 38
#DEFINE EA_CGCDPC 39
#DEFINE EA_NOMDPC 40
#DEFINE EA_SEQEND 41
#DEFINE EA_OBSAUT 42
#DEFINE EA_SQIDES 43
#DEFINE EA_VALSEG 44
#DEFINE EA_FILDPC 45
#DEFINE EA_CTRDPC 46
#DEFINE EA_METRO3 47
#DEFINE EA_BASEIC 48
#DEFINE EA_VALICM 49
#DEFINE EA_BASIST 50
#DEFINE EA_VALIST 51
#DEFINE EA_EMINFE 52
#DEFINE EA_CODNFE 53
#DEFINE EA_NFELET 54
#DEFINE EA_TIPAGD 55
#DEFINE EA_DATAGD 56
#DEFINE EA_PRDAGD 57
#DEFINE EA_INIAGD 58
#DEFINE EA_FIMAGD 59
#DEFINE EA_MOTAGD 60
#DEFINE EA_CODNEG 61
#DEFINE EA_KM     62
#DEFINE EA_PESLIQ 63
#DEFINE EA_CGCEXP 64
#DEFINE EA_CGCREC 65
#DEFINE EA_PLACA  66
#DEFINE EA_PLARB1 67
#DEFINE EA_PLARB2 68
#DEFINE EA_PLARB3 69
#DEFINE EA_EDIVGE 70
#DEFINE EA_ACLDE5 71

#DEFINE EA_TOTVET 71

#DEFINE LT_QTDLOT  1
#DEFINE LT_CGCREM  2
#DEFINE LT_CGCDES  3
#DEFINE LT_FILORI  4
#DEFINE LT_LOTNFC  5
#DEFINE LT_CALLOT  6
#DEFINE LT_RECDE5  7
#DEFINE LT_LOTEDI  8
#DEFINE LT_PLACA   9 
#DEFINE LT_PLARB1 10 
#DEFINE LT_PLARB2 11 
#DEFINE LT_PLARB3 12 
#DEFINE LT_EDIVGE 13 

#DEFINE GC_LOTEDI  1
#DEFINE GC_FILORI  2
#DEFINE GC_NUMCOT  3
#DEFINE GC_CMPCOT  4
#DEFINE GC_CABCOT  5
#DEFINE GC_ITECOT  6
#DEFINE GC_TIPVEI  7
#DEFINE GC_COTOK   8

#DEFINE DADOSCOT  1
#DEFINE PRODCOT   2
#DEFINE TIPVEICOT 5
#DEFINE FRTCMPCOT 7

#DEFINE CODPASCMP 1
#DEFINE VALPASCMP 2
#DEFINE TIPVALCMP 3
#DEFINE LOTEDICMP 4

//DEFINICOES VETOR aCliDE5
#DEFINE NPOSREM 1
#DEFINE NPOSDES 2
#DEFINE NPOSDEV 3
#DEFINE NPOSCON 4
#DEFINE NPOSDPC 5
#DEFINE NPOSEXP 6
#DEFINE NPOSREC 7
#DEFINE NPOSCOD 1
#DEFINE NPOSLOJ 2
#DEFINE NPOSCGC 3
#DEFINE NPOSCDR 4
#DEFINE NPOSRDZ 5

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAE75  ³ Autor ³ Gustavo Almeida     ³ Data ³ 08/06/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ EDI - Notas Fiscais Importadas - Automatico                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE75()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE75()

Local oSelf
Local cFunction    := "TMSAE75"
Local cPerg        := "TMSAE75"
Local bProcess     := { |oSelf| TMSAE75Prc(oSelf) }
Local cDescription := STR0001   //" Este programa tem como objetivo processar os documentos dos clientes recebidos por EDI, 
                                // gerando documento de transporte do cliente e calculando o frete, conforme as configurações 
                                // de perfil do cliente. "
Private cTitle     := STR0002 //"EDI - Automático"
Private cCadastro  := OemToAnsi(STR0002)  //"EDI - Automático"

tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAE75Prc  ³ Autor ³ Gustavo Almeida   ³ Data ³09/06/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processamento EDI - Automatico                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE75                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAE75Prc(oSelf, lJob)

//-- Dialog
Local oOk      := LoadBitMap(GetResources(),"LBOK")
Local oNo      := LoadBitMap(GetResources(),"LBNO")
Local oDlg
Local oPanel

//-- Controle de dimensoes de objetos
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}
Local aSize    := {}
Local aButtons := {}
Local aSetKey  := {}
Local lRet     := .T.
Local nOpca    := 0

Local nCntFor  := 0
Local aRetPE   := {}

Default lJob   := .F.

Private aItensEDI  := {}
Private aValInf    := {}
Private cSerTms    := ""
Private cTipTra    := ""
Private oListBox   := Nil
Private lTodosMark := .F.   // Usado para o controle da marca de todos os documentos

//-- Variaveis totalizadoras
Private nVolumes   := 0
Private nPesReal   := 0
Private nPesCub    := 0
Private nPesLiq    := 0
Private nValMerc   := 0
Private nDoctos    := 0
Private oVolumes   := NIL
Private oPesReal   := NIL
Private oPesCub    := NIL
Private oPesLiq    := NIL
Private oValMerc   := NIL
Private oDoctos    := NIL

/* Seleção de itens do EDI */
TMSAE75Qry(lJob)

If Len(aItensEDI) == 0
	Help( "", 1, STR0021, ,STR0003, 1, 0 )//-- "ATENÇÃO" ## "Não há documentos em aberto."
	lRet := .F.
EndIf

If lRet
	If !lJob .And. mv_par05 == 1 //-- Selecionar as Notas
		//-- Funcoes em acoes relacionadas
		AAdd(aSetKey , { VK_F4    ,{|| TMSAE75Psq() } } )
		AAdd(aButtons, {'COMPTITL',{|| TMSAE75Psq() }, STR0004 , STR0005 }) //"Pesquisa - <F4>"###"Pesquisa"

		//-- Inclusao de botoes especificos
		If ExistBlock("TME75BUT")
			aRetPE := ExecBlock("TME75BUT",.F.,.F.)
			If	ValType(aRetPE) == "A"
				For nCntFor := 1 To Len(aRetPE)
					AAdd(aButtons,aRetPE[nCntFor])
				Next nCntFor
			EndIf
		EndIf
		//-- Dimensoes padroes
		aSize   := MsAdvSize()
		AAdd( aObjects, { 100, 020, .T., .F., .T.  } )
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 100, 020, .F., .F. } )
		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
		aPosObj := MsObjSize( aInfo, aObjects,.T.)
		
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

		oPanel := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[1,3]), (aPosObj[1,4]), .T.,.T.)

		@ 005,005 CHECKBOX oAllMark VAR lTodosMark PROMPT STR0006 SIZE 168, 08; //"Marca/Desmarca Todos"
			                          ON CLICK( TMSAE75MRK(.T.) ) OF oPanel PIXEL 
		@ 007,080 SAY   STR0007  SIZE 40,9     OF oPanel PIXEL  //"Volumes:"
		@ 004,105 MSGET oVolumes VAR  nVolumes WHEN .F.  SIZE 30,9 OF oPanel PIXEL

		@ 007,145 SAY   STR0008  SIZE 40,9     OF oPanel PIXEL  //"Peso Real:"
		@ 004,175 MSGET oPesReal VAR  nPesReal PICTURE   PesqPict("DT6","DT6_PESO")   WHEN .F. SIZE 50,9 OF oPanel PIXEL

		@ 007,235 SAY   STR0009  SIZE 40,9     OF oPanel PIXEL  //"Peso Cubado:"
		@ 004,270 MSGET oPesCub  VAR nPesCub   PICTURE   PesqPict("DT6","DT6_PESOM3") WHEN .F. SIZE 50,9 OF oPanel PIXEL
		
		@ 007,325 SAY   STR0045  SIZE 40,9     OF oPanel PIXEL  //"Peso Líquido:"
		@ 004,365 MSGET oPesLiq  VAR nPesLiq   PICTURE   PesqPict("DT6","DT6_PESLIQ") WHEN .F. SIZE 50,9 OF oPanel PIXEL		
		
		@ 007,420 SAY   STR0010  SIZE 40,9     OF oPanel PIXEL  //"Vlr. Merc.:"
		@ 004,450 MSGET oValMerc VAR nValMerc  PICTURE   PesqPict("DT6","DT6_VALMER") WHEN .F. SIZE 50,9 OF oPanel PIXEL

		@ 007,510 SAY   STR0011  SIZE 50,9     OF oPanel PIXEL  //"Doctos.:"
		@ 004,540 MSGET oDoctos  VAR nDoctos   WHEN .F.  SIZE 20,9 OF oPanel PIXEL

		//-- Cabecalho dos campos
		@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields HEADER;
		"",;
		RetTitle("DE5_CGCREM"),;
		RetTitle("DE5_NOMREM"),;
		RetTitle("DE5_CGCDES"),;
		RetTitle("DE5_NOMDES"),;
		RetTitle("DTC_NUMNFC"),;
		RetTitle("DTC_SERNFC"),;
		RetTitle("DE5_LOTEDI"),;
		RetTitle("DTC_QTDVOL"),;
		RetTitle("DTC_PESO  "),;
		RetTitle("DTC_PESOM3"),;
		RetTitle("DTC_PESLIQ"),;
		RetTitle("DTC_VALOR "),;
		RetTitle("DTC_DESPRO"),;
		RetTitle("DTC_SERTMS"),;
		RetTitle("DTC_TIPTRA"),;
		RetTitle("DTC_SERVIC") SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL 

		oListBox:SetArray( aItensEDI )
		oListBox:bLDblClick := { || TMSAE75Mrk() }
		oListBox:bLine      := { || {	Iif(aItensEDI[ oListBox:nAT,EA_MARCA ] == "1",oOk,oNo),;
										aItensEDI[ oListBox:nAT,EA_CGCREM],;
										aItensEDI[ oListBox:nAT,EA_NOMREM],;
										aItensEDI[ oListBox:nAT,EA_CGCDES],;
										aItensEDI[ oListBox:nAT,EA_NOMDES],;
										aItensEDI[ oListBox:nAT,EA_NUMNFC],;
										aItensEDI[ oListBox:nAT,EA_SERNFC],;
										aItensEDI[ oListBox:nAT,EA_LOTEDI],;
										aItensEDI[ oListBox:nAT,EA_QTDVOL],;
										aItensEDI[ oListBox:nAT,EA_PESO  ],;
										aItensEDI[ oListBox:nAT,EA_PESOM3],;
										aItensEDI[ oListBox:nAT,EA_PESLIQ],;
										Transform(aItensEDI[ oListBox:nAT,EA_VALOR ], x3Picture( "DET_VALOR" )),;
										aItensEDI[ oListBox:nAT,EA_DESPRO],;
										aItensEDI[ oListBox:nAT,EA_SERTMS]+Iif(!Empty(aItensEDI[ oListBox:nAT,EA_SERTMS]),"=","")+aItensEDI[ oListBox:nAT,EA_DESSVT],;
										aItensEDI[ oListBox:nAT,EA_TIPTRA]+Iif(!Empty(aItensEDI[ oListBox:nAT,EA_TIPTRA]),"=","")+aItensEDI[ oListBox:nAT,EA_DESTPT],;
										aItensEDI[ oListBox:nAT,EA_SERVIC]+Iif(!Empty(aItensEDI[ oListBox:nAT,EA_SERVIC]),"=","")+aItensEDI[ oListBox:nAT,EA_DESSER]}}

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{ || Iif(MsgYesNo(STR0016),nOpca:=1,""), oDlg:End() },{||oDlg:End()},, aButtons) CENTERED 

		If nOpca == 1
			TMSAE75Pre(oSelf)
		EndIf

	Else

		TMSAE75Pre(oSelf,lJob)

	EndIf

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE75Qry³ Autor ³ Gustavo Almeida       ³ Data ³09/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Query - EDI - Automatico                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE75                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAE75Qry(lJob)

Local nI         := 0
Local cQuery     := ""
Local cQryAux    := ""
Local aAreaAtu   := GetArea()
Local cAliasQry  := GetNextAlias()
Local lTME75WHE  := ExistBlock("TME75WHE")
Local lTME75Qry  := ExistBlock("TME75Qry")
Local lAgdEntr   := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.) .AND. DYD->(ColumnPos("DYD_DIAATR")) > 0   //-- Agendamento de Entrega.
Local lINSCEDI   := SuperGetMv( "MV_INSCEDI", .F., .F. ) .And. DE5->(ColumnPos('DE5_INSCRE')) > 0 .And. DE5->(ColumnPos('DE5_INSDES')) > 0 .And. DE5->(ColumnPos('DE5_INSDEV')) > 0 //-- Parametro da Importação do EDI pela Incrição estadual.
Local lPEQRY     := .T.
Local lRet       := .F.
Local lDE5PESLIQ := DE5->(ColumnPos("DE5_PESLIQ")) > 0
Local cCGCEXP    := ""
Local cCGCREC    := ""
Local aCliDE5    := {}
Local aRecnosDE5 := {}
Local lDE5_IDESTR:= DE5->(ColumnPos('DE5_IDESTR')) > 0

/* Query de seleção de dados de EDI */
cQuery := "SELECT DE5.R_E_C_N_O_ RECNODE5, DE5.DE5_CGCREM CGCREM, DE5.DE5_CGCDES CGCDES, DE5.DE5_LOTEDI LOTEDI, "
If lINSCEDI
    cQuery += "DE5.DE5_INSCRE IEREM, DE5.DE5_INSDES IEDES, DE5.DE5_INSDEV IEDEV, "
EndIf
cQuery += "DE5.DE5_DOC    NUMNFC, DE5.DE5_SERIE  SERNFC, DE5.DE5_QTDVOL QTDVOL, DE5.DE5_PESO   PESO  , DE5.DE5_PESOM3 PESOM3, "
cQuery += "DE5.DE5_VALOR  VALOR , DE5.DE5_CODPRO CODPRO, DE5.DE5_STATUS STADE5, DE5.DE5_SERVIC SERVIC, DE5.DE5_TIPTRA TPTDE5, "
cQuery += "DE5.DE5_CODEMB CODEMB, DE5.R_E_C_N_O_ RECDE5, DE5.DE5_SERTMS SERTMS, DE5.DE5_EMINFC EMINFC, DE5.DE5_TIPFRE TIPFRE, "
cQuery += "DE5.DE5_CGCDEV CGCDEV, DE5.DE5_SELORI SELORI, DE5.DE5_EDIAUT EDIAUT, DE5.DE5_EDILOT EDILOT, DE5.DE5_EDIFRT EDIFRT, "
cQuery += "DE5.DE5_FILORI FILORI, DE5.DE5_LOTNFC LOTNFC, DE5.DE5_NFEID NFEID  , DE5.DE5_CGCCON CGCCON, DE5.DE5_CGCDPC CGCDPC, "
If lDE5_IDESTR
	cQuery += "DE5.DE5_IDESTR IDESTR, "
EndIf
If lAgdEntr
	cQuery += "	DE5.DE5_TIPAGD TIPAGD, DE5.DE5_DATAGD DATAGD, DE5.DE5_PRDAGD PRDAGD, DE5.DE5_INIAGD INIAGD, DE5.DE5_FIMAGD FIMAGD, "
	If "ORACLE" $ Upper(TCGetDB())
		cQuery += " UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(DE5_MOTAGD, 4000,1)) MOTAGD,  "
    ElseIf "POSTGRES" $ Upper(TCGetDB())
        cQuery += " CAST(CAST(DE5_MOTAGD AS BYTEA) AS VARCHAR(8000)) MOTAGD,  "
	Else 	
		cQuery += " CASE WHEN DE5_MOTAGD IS NULL "
		cQuery += "      THEN ' '
		cQuery += "      ELSE CONVERT(VARCHAR(8000),CONVERT(BINARY(8000)  ,DE5_MOTAGD)) "
		cQuery += "      END As MOTAGD, "
	EndIf
EndIf 

If "ORACLE" $ Upper(TCGetDB())
	cQuery += " UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(DE5_OBSAUT, 4000,1)) OBSAUT,  "
ElseIf "POSTGRES" $ Upper(TCGetDB())
	cQuery += " CAST(CAST(DE5_OBSAUT AS BYTEA) AS VARCHAR(8000)) OBSAUT,  "
Else 
	cQuery += " CASE WHEN DE5_OBSAUT IS NULL "
	cQuery += "      THEN ' '
	cQuery += "      ELSE CONVERT(VARCHAR(8000),CONVERT(BINARY(8000)  ,DE5_OBSAUT)) "
	cQuery += "      END As OBSAUT, "
EndIf

cQuery += " DE5.DE5_VALSEG VALSEG, DE5.DE5_FILDPC FILDPC, DE5.DE5_CTRDPC CTRDPC, DE5.DE5_METRO3 METRO3,DE5.DE5_BASEIC BASEIC, "
cQuery += " DE5.DE5_VALICM VALICM, DE5.DE5_BASIST BASIST, DE5.DE5_VALIST VALIST, DE5.DE5_EMINFE EMINFE, DE5.DE5_CODNFE CODNFE, "		 
If lDE5PESLIQ
	cQuery += " DE5.DE5_NFELET NFELET, DE5.DE5_SEQEND SEQEND, DE5.DE5_SQIDES SQIDES, DE5.DE5_PESLIQ PESLIQ "      
Else
	cQuery += " DE5.DE5_NFELET NFELET, DE5.DE5_SEQEND SEQEND, DE5.DE5_SQIDES SQIDES "
EndIf

cQuery += ", DE5.DE5_CODNEG CODNEG "

//-- Campos do Expedidor e Recebedor
If DE5->(ColumnPos("DE5_CGCEXP")) > 0
    cQuery += ", DE5.DE5_CGCEXP CGCEXP "
EndIf
If DE5->(ColumnPos("DE5_CGCREC")) > 0
    cQuery += ", DE5.DE5_CGCREC CGCREC "
EndIf

//-- Campos da(s) placa(s) do(s) Veículo(s)
If DE5->(ColumnPos("DE5_PLACA")) > 0
    cQuery += ", DE5.DE5_PLACA PLACA "
EndIf

If DE5->(ColumnPos("DE5_PLARB1")) > 0
    cQuery += ", DE5.DE5_PLARB1 PLARB1 "
EndIf

If DE5->(ColumnPos("DE5_PLARB2")) > 0
    cQuery += ", DE5.DE5_PLARB2 PLARB2 "
EndIf

If DE5->(ColumnPos("DE5_PLARB3")) > 0
    cQuery += ", DE5.DE5_PLARB3 PLARB3 "
EndIf
cQuery += "  FROM "+ RetSqlName("DE5") + " DE5 "

If lTME75WHE
	cQryAux := ExecBlock("TME75WHE",.F.,.F.)
	If ValType(cQryAux) == "C"
		If "A1_" $ cQryAux
			cQuery += "JOIN "+ RetSqlName("SA1") + " SA1 "
			cQuery += "  ON SA1.A1_FILIAL  = '"+xFilial('SA1')+"'"
			cQuery += " AND SA1.A1_CGC     = DE5.DE5_CGCREM "
			cQuery += " AND SA1.A1_MSBLQL  <> '1' "
			cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
			If lINSCEDI
				cQuery += " AND SA1.A1_INSCR = DE5.DE5_INSCRE "
			EndIf
		EndIf
	Else
		cQryAux := ""
	EndIf
EndIf

cQuery += " WHERE DE5.DE5_FILIAL = '"+xFilial("DE5")+"'"
cQuery += "   AND DE5.DE5_CGCREM BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
cQuery += "   AND DE5.DE5_CGCDES BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
cQuery += "   AND DE5.DE5_STATUS <> '2'"
If lJob
	cQuery += "   AND DE5.DE5_FILORI = '"+cFilAnt+"' "
	cQuery += "   AND DE5.DE5_STAUTO IN(' ','0' ) "
EndIf
cQuery += "   AND DE5.D_E_L_E_T_ = ' '"

If lTME75WHE
	cQuery += " " + cQryAux + " "
EndIf

cQuery += " ORDER BY DE5.DE5_LOTEDI "

dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .T., .T. ) 

While (cAliasQry)->(!Eof())
	If AScan(aRecnosDE5,{|x| x == (cAliasQry)->RECNODE5 }) > 0
		(cAliasQry)->(!DbSkip())
		Loop
	EndIf
	
	//-- Ponto de entrada("TME75QRY")
	If lTME75Qry
		lPEQRY := ExecBlock("TME75QRY",.F.,.F.,{(cAliasQry)->CGCREM, (cAliasQry)->NUMNFC, (cAliasQry)->SERNFC, (cAliasQry)->CODPRO, (cAliasQry)->RECDE5,cAliasQry})
		If	ValType(lPEQRY) == "L"
			lRet := lPEQRY
		Else
			lRet := .T.
		EndIf
	Else
		lRet := .T.	
	EndIf

	If lRet 

		//-- Campos do Expedidor e Recebedor
		If DE5->(ColumnPos("DE5_CGCEXP")) > 0
			cCGCEXP := (cAliasQry)->CGCEXP       //Vanessa
		EndIf
		If DE5->(ColumnPos("DE5_CGCREC")) > 0
			cCGCREC := (cAliasQry)->CGCREC     //Vanessa
		EndIf

		If lINSCEDI .And. lDE5_IDESTR
			aCliDE5 := (cAliasQry)->( CGCCliAtiv( CGCREM, CGCDES, CGCDEV, CGCCON, CGCDPC, cCGCEXP, cCGCREC, IEREM, IEDES, IEDEV, IDESTR ) )
		ElseIf lINSCEDI
			aCliDE5 := (cAliasQry)->( CGCCliAtiv( CGCREM, CGCDES, CGCDEV, CGCCON, CGCDPC, cCGCEXP, cCGCREC, IEREM, IEDES, IEDEV ) )
		Else			
			If lDE5_IDESTR
				aCliDE5 := (cAliasQry)->( CGCCliAtiv( CGCREM, CGCDES, CGCDEV, CGCCON, CGCDPC, cCGCEXP, cCGCREC, , , , IDESTR ) )
			Else
				aCliDE5 := (cAliasQry)->( CGCCliAtiv( CGCREM, CGCDES, CGCDEV, CGCCON, CGCDPC, cCGCEXP, cCGCREC ) )
			EndIf
		EndIf

		aAdd(aItensEDI,Array(EA_TOTVET))
	
		nI      := Len(aItensEDI)
		cSerTms := (cAliasQry)->SERTMS
		cTipTra := (cAliasQry)->TPTDE5
		If mv_par05 == 2 //-- Selecionar todas os documentos	
			aItensEDI[nI,EA_MARCA]:= "1"
		Else
			aItensEDI[nI,EA_MARCA]:= "2"
		EndIf
		aItensEDI[nI,EA_CGCREM] := (cAliasQry)->CGCREM
		aItensEDI[nI,EA_NOMREM] := aCliDE5[NPOSREM][NPOSRDZ]
		aItensEDI[nI,EA_CODCLI] := aCliDE5[NPOSREM][NPOSCOD] 
		aItensEDI[nI,EA_LOJCLI] := aCliDE5[NPOSREM][NPOSLOJ]
		aItensEDI[nI,EA_NUMNFC] := (cAliasQry)->NUMNFC
		aItensEDI[nI,EA_SERNFC] := (cAliasQry)->SERNFC
		aItensEDI[nI,EA_EMINFC] := (cAliasQry)->EMINFC
		aItensEDI[nI,EA_LOTEDI] := (cAliasQry)->LOTEDI
		aItensEDI[nI,EA_QTDVOL] := (cAliasQry)->QTDVOL
		aItensEDI[nI,EA_PESO  ] := (cAliasQry)->PESO
		aItensEDI[nI,EA_PESOM3] := (cAliasQry)->PESOM3
		aItensEDI[nI,EA_PESLIQ] := Iif(lDE5PESLIQ,(cAliasQry)->PESLIQ, 0)
		aItensEDI[nI,EA_VALOR ] := (cAliasQry)->VALOR
		aItensEDI[nI,EA_DESPRO] := Posicione("SB1",1,xFilial("SB1")+(cAliasQry)->CODPRO,"B1_DESC")
		aItensEDI[nI,EA_CGCDES] := (cAliasQry)->CGCDES
		aItensEDI[nI,EA_NOMDES] := aCliDE5[NPOSDES][NPOSRDZ]
		aItensEDI[nI,EA_CGCDEV] := (cAliasQry)->CGCDEV
		aItensEDI[nI,EA_SELORI] := (cAliasQry)->SELORI
		aItensEDI[nI,EA_STADE5] := (cAliasQry)->STADE5
		aItensEDI[nI,EA_CODPRO] := (cAliasQry)->CODPRO
		aItensEDI[nI,EA_CODEMB] := (cAliasQry)->CODEMB
		aItensEDI[nI,EA_TIPFRE] := (cAliasQry)->TIPFRE
		aItensEDI[nI,EA_SERTMS] := cSerTms
		aItensEDI[nI,EA_DESSVT] := TMSValField("cSerTms",.F.)
		aItensEDI[nI,EA_TIPTRA] := cTipTra
		aItensEDI[nI,EA_DESTPT] := TMSValField("cTipTra",.F.)
		aItensEDI[nI,EA_SERVIC] := (cAliasQry)->SERVIC
		aItensEDI[nI,EA_DESSER] := Tabela("L4",(cAliasQry)->SERVIC,.F.)
		aItensEDI[nI,EA_RECDE5] := (cAliasQry)->RECDE5
		aItensEDI[nI,EA_EDIAUT] := (cAliasQry)->EDIAUT
		aItensEDI[nI,EA_EDILOT] := (cAliasQry)->EDILOT
		aItensEDI[nI,EA_EDIFRT] := (cAliasQry)->EDIFRT
		aItensEDI[nI,EA_FILORI] := (cAliasQry)->FILORI
		aItensEDI[nI,EA_LOTNFC] := (cAliasQry)->LOTNFC
		aItensEDI[nI,EA_NUMCOT] := Posicione("DET",1,xFilial("DET")+(cAliasQry)->LOTEDI,"DET_NUMCOT")
		aItensEDI[nI,EA_NFEID ] := (cAliasQry)->NFEID
		aItensEDI[nI,EA_CGCCON] := (cAliasQry)->CGCCON
		aItensEDI[nI,EA_NOMCON] := aCliDE5[NPOSCON][NPOSRDZ]
		aItensEDI[nI,EA_CGCDPC] := (cAliasQry)->CGCDPC
		aItensEDI[nI,EA_NOMDPC] := aCliDE5[NPOSDPC][NPOSRDZ]
		aItensEDI[nI,EA_SEQEND] := (cAliasQry)->SEQEND 			
		aItensEDI[nI,EA_OBSAUT] := (cAliasQry)->OBSAUT
		aItensEDI[nI,EA_SQIDES] := (cAliasQry)->SQIDES
		aItensEDI[nI,EA_VALSEG] := (cAliasQry)->VALSEG
		aItensEDI[nI,EA_FILDPC] := (cAliasQry)->FILDPC
		aItensEDI[nI,EA_CTRDPC] := (cAliasQry)->CTRDPC
		aItensEDI[nI,EA_METRO3] := (cAliasQry)->METRO3
		aItensEDI[nI,EA_BASEIC] := (cAliasQry)->BASEIC
		aItensEDI[nI,EA_VALICM] := (cAliasQry)->VALICM
		aItensEDI[nI,EA_BASIST] := (cAliasQry)->BASIST
		aItensEDI[nI,EA_VALIST] := (cAliasQry)->VALIST
		aItensEDI[nI,EA_EMINFE] := (cAliasQry)->EMINFE
		aItensEDI[nI,EA_CODNFE] := (cAliasQry)->CODNFE
		aItensEDI[nI,EA_NFELET] := (cAliasQry)->NFELET
		If lAgdEntr
			aItensEDI[nI,EA_TIPAGD] := (cAliasQry)->TIPAGD
			aItensEDI[nI,EA_DATAGD] := (cAliasQry)->DATAGD
			aItensEDI[nI,EA_PRDAGD] := (cAliasQry)->PRDAGD
			aItensEDI[nI,EA_INIAGD] := (cAliasQry)->INIAGD
			aItensEDI[nI,EA_FIMAGD] := (cAliasQry)->FIMAGD
			aItensEDI[nI,EA_MOTAGD] := (cAliasQry)->MOTAGD
		Else
			aItensEDI[nI,EA_TIPAGD] := ""
			aItensEDI[nI,EA_DATAGD] := CToD("  /  /  ")
			aItensEDI[nI,EA_PRDAGD] := ""
			aItensEDI[nI,EA_INIAGD] := CToD("  /  /  ")
			aItensEDI[nI,EA_FIMAGD] := CToD("  /  /  ")
			aItensEDI[nI,EA_MOTAGD] := ""
		EndIf 		
		aItensEDI[nI,EA_CODNEG] := (cAliasQry)->CODNEG		
		aItensEDI[nI,EA_KM]     := 0		
        //-- Expedidor e Recebedor
        aItensEDI[nI,EA_CGCEXP] := aCliDE5[NPOSEXP][NPOSCGC]
        aItensEDI[nI,EA_CGCREC] := aCliDE5[NPOSREC][NPOSCGC]
		//-- Campos da(s) placa(s) do(s) Veículo(s)
		If DE5->(ColumnPos("DE5_PLACA")) > 0
            aItensEDI[nI,EA_PLACA] := (cAliasQry)->PLACA
        Else
            aItensEDI[nI,EA_PLACA] := ""
        EndIf
		If DE5->(ColumnPos("DE5_PLARB1")) > 0
            aItensEDI[nI,EA_PLARB1] := (cAliasQry)->PLARB1
        Else
            aItensEDI[nI,EA_PLARB1] := ""
        EndIf
		If DE5->(ColumnPos("DE5_PLARB2")) > 0
            aItensEDI[nI,EA_PLARB2] := (cAliasQry)->PLARB2
        Else
            aItensEDI[nI,EA_PLARB2] := ""
        EndIf
		If DE5->(ColumnPos("DE5_PLARB3")) > 0
            aItensEDI[nI,EA_PLARB3] := (cAliasQry)->PLARB3
        Else
            aItensEDI[nI,EA_PLARB3] := ""
        EndIf

		aItensEDI[nI,EA_ACLDE5] := AClone(aCliDE5)

	EndIf
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(dbCloseArea())

RestArea(aAreaAtu)

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE75Pre³ Autor ³ Gustavo Almeida       ³ Data ³09/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preparacao da Cotacao/NF                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE75Pre()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE75                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE75Pre(oSelf,lJob)

Local nI       := 0
Local nJ       := 0
Local nSeek    := 0
Local nSeek2   := 0
Local aItem    := {}
Local aCabDTP  := {}
Local aCabDTC  := {}
Local aIteDTC  := {}
Local aItensOk := {}
Local aLotNFC  := {}
Local aPerfil  := {}
Local aGeraCot := {}
Local cRet     := ""
Local cLotNFC  := ""
Local cCliRem  := ""
Local cLojRem  := ""
Local cCliDes  := ""
Local cLojDes  := ""
Local cCliExp  := ""
Local cLojExp  := ""
Local cCliRec  := ""
Local cLojRec  := ""
Local cCliDev  := ""
Local cLojDev  := ""
Local cCliCon  := ""
Local cLojCon  := ""
Local cCliDpc  := ""
Local cLojDpc  := ""
Local cDevFre  := ""
Local cCdrOri  := ""
Local cCdrDes  := ""
Local lTMSCTe  := SuperGetMv( "MV_TMSCTE", .F., .F. )	//-- Parametro do CT-e ativo.
Local aAreaAtu := GetArea()
Local lRet     := .T.
Local aMsgErr  := {}
Local aVisErr  := {}
Local aErroLog := {}
Local cSeqEnd  := ""
Local nLinMemo := 0
Local nCntMemo := 0
Local cFILDPC := ""
Local cCTRDPC := ""
Local cEMINFE := ""
Local cCODNFE := ""
Local cNFELET := ""
Local nVALSEG := 0
Local nMETRO3 := 0
Local nBASEIC := 0
Local nVALICM := 0
Local nBASIST := 0
Local nVALIST := 0
Local nPosaIt := 0

/*Agendamento de Entrega */
Local cTipAgd := ""
Local dDatAgd := ""
Local cPrdAgd := ""
Local cIniAgd := ""
Local cFimAgd := ""
Local cMotAgd := ""
Local lAgdEntr := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.) .AND. DYD->(ColumnPos("DYD_DIAATR")) > 0   //-- Agendamento de Entrega.

/* Cotação */
Local aCmpFrt     := {}
Local aDadosDT4   := {}
Local aTipVei     := {}
Local aCotacao    := {{},{},{},{},{},{},{}}
Local aTotFrtCp   := {}
Local lCallExec   := .F.
Local lCallPE     := .F.  //-- Utilizado no retorno do PE TME75QNF
Local nSeekItem   := 0
Local cNotaFisc   := ""
Local cEDIAut     := ""
Local cEDILot     := ""
Local cEDIFrt     := ""
Local aCpos       := {}
Local nCntFor     := 0
Local lTME75CAB   := ExistBlock("TME75CAB")
Local lTME75ITE   := ExistBlock("TME75ITE")
Local lTME75QNF   := ExistBlock("TME75QNF")
Local aCpitem     := {}

Local cCdrPar	  := SuperGetMv("MV_CDRORI",.F.,"")
Local cEDIVGE     := ""
Local cViagem     := ""
Local aStatDE5

Local lIdentDoc	  := DTC->(ColumnPos("DTC_DOCTMS")) > 0

/* Compatibilizar na cotação */
Private aRotina   := {{},{},{"&Incluir","TMSA40Mnt",0,3,0,NIL}}
Private cCadastro := ""
Private cNumCot   := ""
Private Inclui    := .F.

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lTmsCFec       := TmsCFec()
Private lAutoErrNoFile := .T.

Default lJob := .F.

If !lJob
	oSelf := oSelf
	oSelf:SaveLog(STR0012) //"Processamento iniciado "
EndIf

If Ascan(aItensEDI,{ | e | e[EA_MARCA] == "1" }) == 0
	AAdd(aMsgErr,{STR0014,'00','TMSAE55()'}) //"Nenhum item foi selecionado!"
	lRet := .F.
Else
	//-- Ordena Array de Itens
	ASort( aItensEDI,,,{|x,y| x[ EA_MARCA ] + x[ EA_CGCREM ] + x[ EA_LOTEDI ] + x[EA_NUMNFC] + x[EA_SERNFC] + x[EA_CODPRO] < y[ EA_MARCA ] + y[ EA_CGCREM ] + y[ EA_LOTEDI ] + y[EA_NUMNFC] + y[EA_SERNFC] + y[EA_CODPRO] } )

	For nI := 1 To Len(aItensEDI)

		If aItensEDI[nI,EA_MARCA] == "1"

			cCliRem := aItensEDI[nI,EA_CODCLI]
			cLojRem := aItensEDI[nI,EA_LOJCLI]

			//-- Carrega Perfil do Cliente do Item Selecionado
			cCliDev := aItensEDI[nI,EA_ACLDE5][NPOSDEV][NPOSCOD]
			cLojDev := aItensEDI[nI,EA_ACLDE5][NPOSDEV][NPOSLOJ]
			aPerfil := TmsPerfil(cCliDev,cLojDev,.F.)
			If Empty(aPerfil)
				lRet := .F.
			EndIf

			//-- Viagem Edi Auto: 0-Não Utiliza;1-Gera Viagem
			cEDIVGE := "0"
			If !Empty(aPerfil) .And. Len(aPerfil) >= 62
				cEDIVGE := aPerfil[62]
			EndIf
			aItensEDI[nI,EA_EDIVGE] := cEDIVGE //-- 0-Não Utiliza;1-Gera Viagem

			If lRet .And. !Empty(aItensEDI[nI,EA_EDIAUT]) .And. aItensEDI[nI,EA_EDIAUT] <> "0" 
				cEDIAut := aItensEDI[nI,EA_EDIAUT] //-- 1 = Lote s/ calculo   ou 2 = Lote c/ calculo
				cEDILot := aItensEDI[nI,EA_EDILOT] //-- 1 = Por Processamento ou 2 = Por Destinatário
				cEDIFrt := aItensEDI[nI,EA_EDIFRT] //-- 1 = Assume Frete CIF/FOB ou 2 = Apenas Informativo  ou 3 Assume CIF ou 4 Assume FOB
				//-- Adiciona o Item
				aAdd( aItensOk , nI )
			ElseIf lRet
				cEDIAut := aPerfil[50] //-- 1 = Lote s/ calculo   ou 2 = Lote c/ calculo
				cEDILot := aPerfil[51] //-- 1 = Por Processamento ou 2 = Por Destinatário
				cEDIFrt := aPerfil[52] //-- 1 = Assume Frete CIF/FOB ou 2 = Apenas Informativo  ou 3 Assume CIF ou 4 Assume FOB

				If lRet .And. ( cEDIAut == "0" .Or. cEDILot == "0" .Or. cEDIFrt == "0")
					AAdd(aMsgErr,{STR0019+aItensEDI[nI,EA_CODCLI]+"/"+aItensEDI[nI,EA_LOJCLI],'00','TMSAE55()'}) //"Perfil do Cliente não configurado para EDI Automático: "
					//-- Atualiza Status do DE5
					AtuSTAuto( Nil, aItensEDI , nI, nI, "2", @aMsgErr )
					lRet := .F.
				Else
					aItensEDI[nI,EA_EDIAUT] := cEDIAut //-- 1 = Lote s/ calculo   ou 2 = Lote c/ calculo
					aItensEDI[nI,EA_EDILOT] := cEDILot //-- 1 = Por Processamento ou 2 = Por Destinatário ou 3 = por placa
					aItensEDI[nI,EA_EDIFRT] := cEDIFrt //-- 1 = Assume Frete CIF/FOB ou 2 = Apenas Informativo  ou 3 Assume CIF ou 4 Assume FOB
					//-- Atualiza condicoes do perfil em DE5
					DE5->(dbGoTo(aItensEDI[nI,EA_RECDE5]))

					Begin Transaction

						RecLock('DE5',.F.)
						DE5->DE5_EDIAUT := cEDIAut
						DE5->DE5_EDILOT := cEDILot
						DE5->DE5_EDIFRT := cEDIFrt
						MsUnLock()

					End Transaction

					//-- Adiciona o Item
					aAdd( aItensOk , nI )
				EndIf
			EndIf

			//-- Lotes de Notas
			If lRet
				If !Empty(aItensEDI[nI,EA_LOTNFC])
					If Ascan( aLotNFC, {|e| e[LT_FILORI]+e[LT_LOTNFC] == aItensEDI[nI,EA_FILORI]+aItensEDI[nI,EA_LOTNFC] }) == 0
						aAdd(aLotNFC,Array(13))
						aLotNFC[Len(aLotNFC),LT_QTDLOT] := Posicione('DTP',2,xFilial('DTP')+aItensEDI[nI,EA_FILORI]+aItensEDI[nI,EA_LOTNFC],'DTP_QTDLOT')
						aLotNFC[Len(aLotNFC),LT_CGCREM] := aItensEDI[nI,EA_CGCREM]
						aLotNFC[Len(aLotNFC),LT_CGCDES] := aItensEDI[nI,EA_CGCDES]
						aLotNFC[Len(aLotNFC),LT_FILORI] := aItensEDI[nI,EA_FILORI]
						aLotNFC[Len(aLotNFC),LT_LOTNFC] := aItensEDI[nI,EA_LOTNFC]
						aLotNFC[Len(aLotNFC),LT_CALLOT] := .F.
						aLotNFC[Len(aLotNFC),LT_RECDE5] := {}
						aLotNFC[Len(aLotNFC),LT_LOTEDI] := aItensEDI[nI,EA_LOTEDI]
						aLotNFC[Len(aLotNFC),LT_PLACA ] := aItensEDI[nI,EA_PLACA ]
						aLotNFC[Len(aLotNFC),LT_PLARB1] := aItensEDI[nI,EA_PLARB1]
						aLotNFC[Len(aLotNFC),LT_PLARB2] := aItensEDI[nI,EA_PLARB2]
						aLotNFC[Len(aLotNFC),LT_PLARB3] := aItensEDI[nI,EA_PLARB3]
						aLotNFC[Len(aLotNFC),LT_EDIVGE] := aItensEDI[nI,EA_EDIVGE]
						Aadd(aLotNFC[Len(aLotNFC),LT_RECDE5],aItensEDI[nI,EA_RECDE5])
					EndIf
				Else
					//-- Cria Lote de Documentos conforme Perfil do Cliente
					If cEDILot == "1" //-- Por Processamento
						nSeek := Ascan( aLotNFC, {|e| e[LT_CGCREM] + e[LT_LOTEDI] == aItensEDI[nI,EA_CGCREM] + aItensEDI[nI,EA_LOTEDI] })
						If nSeek == 0
							aAdd(aLotNFC,Array(13))
							nSeek := Len(aLotNFC)
							aLotNFC[Len(aLotNFC),LT_QTDLOT] := 0
							aLotNFC[Len(aLotNFC),LT_CGCREM] := aItensEDI[nI,EA_CGCREM]
							aLotNFC[Len(aLotNFC),LT_CGCDES] := ""
							aLotNFC[Len(aLotNFC),LT_FILORI] := cFilAnt
							aLotNFC[Len(aLotNFC),LT_LOTNFC] := ""
							aLotNFC[Len(aLotNFC),LT_CALLOT] := .F.
							aLotNFC[Len(aLotNFC),LT_RECDE5] := {}
							aLotNFC[Len(aLotNFC),LT_LOTEDI] := aItensEDI[nI,EA_LOTEDI]
							aLotNFC[Len(aLotNFC),LT_PLACA ] := aItensEDI[nI,EA_PLACA ]
							aLotNFC[Len(aLotNFC),LT_PLARB1] := aItensEDI[nI,EA_PLARB1]
							aLotNFC[Len(aLotNFC),LT_PLARB2] := aItensEDI[nI,EA_PLARB2]
							aLotNFC[Len(aLotNFC),LT_PLARB3] := aItensEDI[nI,EA_PLARB3]
							aLotNFC[Len(aLotNFC),LT_EDIVGE] := aItensEDI[nI,EA_EDIVGE]
						EndIf
						If cNotaFisc <> aItensEDI[nI,EA_NUMNFC] + aItensEDI[nI,EA_SERNFC]
							aLotNFC[nSeek,LT_QTDLOT] += 1
							cNotaFisc := aItensEDI[nI,EA_NUMNFC] + aItensEDI[nI,EA_SERNFC]
						EndIf
						Aadd(aLotNFC[nSeek,LT_RECDE5],aItensEDI[nI,EA_RECDE5])

					ElseIf cEDILOT $ "2;3" //-- Por Destinatário ## Por Placa Veic
						If cEDILOT == "2" //-- Por Destinatário 
							nSeek := Ascan( aLotNFC, {|e| e[LT_CGCREM]+e[LT_CGCDES]+e[LT_LOTEDI]  == aItensEDI[nI,EA_CGCREM]+aItensEDI[nI,EA_CGCDES]+aItensEDI[nI,EA_LOTEDI] })
						ElseIf cEDILOT == "3" //-- Por Placa Veic
							nSeek := Ascan( aLotNFC, {|e| e[LT_PLACA]  == aItensEDI[nI,EA_PLACA] })
						EndIf
						If nSeek == 0
							aAdd(aLotNFC,Array(13))
							nSeek := Len(aLotNFC)
							aLotNFC[Len(aLotNFC),LT_QTDLOT] := 0
							aLotNFC[Len(aLotNFC),LT_CGCREM] := aItensEDI[nI,EA_CGCREM]
							aLotNFC[Len(aLotNFC),LT_CGCDES] := aItensEDI[nI,EA_CGCDES]
							aLotNFC[Len(aLotNFC),LT_FILORI] := cFilAnt
							aLotNFC[Len(aLotNFC),LT_LOTNFC] := ""
							aLotNFC[Len(aLotNFC),LT_CALLOT] := .F.
							aLotNFC[Len(aLotNFC),LT_RECDE5] := {}
							aLotNFC[Len(aLotNFC),LT_LOTEDI] := aItensEDI[nI,EA_LOTEDI]
							aLotNFC[Len(aLotNFC),LT_PLACA ] := aItensEDI[nI,EA_PLACA ]
							aLotNFC[Len(aLotNFC),LT_PLARB1] := aItensEDI[nI,EA_PLARB1]
							aLotNFC[Len(aLotNFC),LT_PLARB2] := aItensEDI[nI,EA_PLARB2]
							aLotNFC[Len(aLotNFC),LT_PLARB3] := aItensEDI[nI,EA_PLARB3]
							aLotNFC[Len(aLotNFC),LT_EDIVGE] := aItensEDI[nI,EA_EDIVGE]
						EndIf
						If cNotaFisc <> aItensEDI[nI,EA_NUMNFC] + aItensEDI[nI,EA_SERNFC]
							aLotNFC[nSeek,LT_QTDLOT] += 1
							cNotaFisc := aItensEDI[nI,EA_NUMNFC] + aItensEDI[nI,EA_SERNFC]
						EndIf
						Aadd(aLotNFC[nSeek,LT_RECDE5],aItensEDI[nI,EA_RECDE5]) 
					EndIf
				EndIf
			EndIf

			//-- Cotacoes
			If lRet .And. !Empty(aItensEDI[nI,EA_LOTEDI]) .And. Empty(aItensEDI[nI,EA_NUMCOT])  ;
				    .And. (;
					       cEDIFrt == '1' ; //-- Assume Frete CIF/FOB
					       .Or. (cEDIFrt == '3' .And. aItensEDI[nI,EA_TIPFRE] == "1"  ); //-- Assume Apenas Frete CIF
					       .Or. (cEDIFrt == '4' .And. aItensEDI[nI,EA_TIPFRE] == "2"  ); //-- Assume Apenas Frete FOB
					      )

				//-- Verifica cotacao para o Lote EDI
				nSeek := Ascan( aGeraCot, {|e| e[GC_LOTEDI] == aItensEDI[nI,EA_LOTEDI] } )

				If nSeek == 0

					aAdd( aGeraCot,Array(8) )
					aGeraCot[Len(aGeraCot),GC_LOTEDI] := aItensEDI[nI,EA_LOTEDI]
					aGeraCot[Len(aGeraCot),GC_FILORI] := cFilAnt
					aGeraCot[Len(aGeraCot),GC_NUMCOT] := ""
					aGeraCot[Len(aGeraCot),GC_COTOK ] := .F.
					aCmpFrt   := {}
					aDadosDT4 := {}

					aTelSol := TMSAF05DUE(aItensEDI[nI,EA_CODCLI],aItensEDI[nI,EA_LOJCLI],aItensEDI[nI,EA_TIPTRA],.T.)//--Codigo do Solicitante	

					//-- Composição
					DET->(DbSetOrder(1)) //- DET_FILIAL+DET_LOTEDI
					DET->(MsSeek(xFilial("DET")+aItensEDI[nI,EA_LOTEDI]))
					nJ := 1 //-- Inicia numeração de componentes
					Do While DET->(!Eof()) .And. xFilial("DET")+aItensEDI[nI,EA_LOTEDI] == DET->(DET_FILIAL+DET_LOTEDI)
						aAdd( aCmpFrt, Array(4) )
						aCmpFrt[nJ,CODPASCMP]:= DET->DET_CODPAS
						aCmpFrt[nJ,VALPASCMP]:= DET->DET_VALOR
						aCmpFrt[nJ,TIPVALCMP]:= DET->DET_TIPVAL
						aCmpFrt[nJ,LOTEDICMP]:= DET->DET_LOTEDI
						nJ++
						DET->(DbSkip())
					EndDo

					aGeraCot[Len(aGeraCot),GC_CMPCOT] := AClone(aCmpFrt)

					//-- Cabecalho da cotacao
					// EDI
					// Se alterar a posição dos campos deste array deve ordernar 
					// o array aCposCab da função TMSAF05Ini
					aDadosDT4 := {}
					aAdd( aDadosDT4, cFilAnt) // Filial Origem
					aAdd( aDadosDT4, aTelSol[1]    ) //--Codigo do Solicitante						
					aAdd( aDadosDT4, aItensEDI[nI,EA_TIPFRE] ) // Tipo Frete
					aAdd( aDadosDT4, aItensEDI[nI,EA_SELORI] ) // Seleciona Regiao
					If aItensEDI[nI,EA_SELORI] == "1"          // Transportadora
						aAdd( aDadosDT4, cCdrPar ) // Regiao Origem	
					Else
						aAdd( aDadosDT4, aItensEDI[nI,EA_ACLDE5][NPOSREM][NPOSCDR] ) // Regiao Origem
					EndIf
					aAdd( aDadosDT4, aItensEDI[nI,EA_ACLDE5][NPOSDES][NPOSCDR] )    // Regiao Destino
					aAdd( aDadosDT4, aItensEDI[nI,EA_SERTMS] ) // Entrega
					aAdd( aDadosDT4, aItensEDI[nI,EA_TIPTRA] ) // Tipo Transporte
					aAdd( aDadosDT4, aItensEDI[nI,EA_SERVIC] ) // Servico
					aAdd( aDadosDT4, aItensEDI[nI,EA_CODCLI] ) // Remetente
					aAdd( aDadosDT4, aItensEDI[nI,EA_LOJCLI] ) // Loja Remetente
					aAdd( aDadosDT4, aItensEDI[nI,EA_ACLDE5][NPOSDES][NPOSCOD] ) // Destinatario
					aAdd( aDadosDT4, aItensEDI[nI,EA_ACLDE5][NPOSDES][NPOSLOJ] ) // Loja Destinatario
					aAdd( aDadosDT4, aItensEDI[nI,EA_ACLDE5][NPOSDEV][NPOSCOD] ) // Devedor
					aAdd( aDadosDT4, aItensEDI[nI,EA_ACLDE5][NPOSDEV][NPOSLOJ] ) // Loja Devedor
					aAdd( aDadosDT4, "" ) // Solicitacao 
					aAdd( aDadosDT4, aItensEDI[nI,EA_KM] ) // KM
					aAdd( aDadosDT4, "2" ) // Distancia Ida/Volta
					aAdd( aDadosDT4, "0" ) // Tipo de NFC
					aAdd( aDadosDT4, "" ) // DocTMS

					DC5->( DbSetOrder( 1 ) )
					If DC5->( DbSeek( xFilial('DC5') + aItensEDI[nI,EA_SERVIC] ) )
						aDadosDT4[Len(aDadosDT4)]:= DC5->DC5_DOCTMS // DocTMS
					EndIf
					aAdd( aDadosDT4, "0" ) // Contribuinte
					aAdd( aDadosDT4, "" ) // Obs
					aAdd( aDadosDT4, aItensEDI[nI,EA_CODNEG] ) // Código da Negociação
					aAdd( aDadosDT4, "2" ) // Tipo de Documento - Verificar

					aGeraCot[Len(aGeraCot),GC_CABCOT] := AClone(aDadosDT4)

					//-- Itens da cotacao
					aGeraCot[Len(aGeraCot),GC_ITECOT] := {}
					aAdd(aGeraCot[Len(aGeraCot),GC_ITECOT], {} )
					aDadosDT4 := {}
					aAdd(aDadosDT4,StrZero(Len(aGeraCot[Len(aGeraCot),GC_ITECOT]),2)) // Item da cotacao
					aAdd(aDadosDT4,aItensEDI[nI,EA_CODPRO]) // Codigo Produto
					aAdd(aDadosDT4,aItensEDI[nI,EA_CODEMB]) // Cod.Embalagem
					aAdd(aDadosDT4,aItensEDI[nI,EA_QTDVOL]) // Volumes
					aAdd(aDadosDT4,  0  ) // Unitizadores
					aAdd(aDadosDT4,aItensEDI[nI,EA_PESO  ]) // Peso Real
					aAdd(aDadosDT4,aItensEDI[nI,EA_PESOM3]) // Peso Cubado
					aAdd(aDadosDT4,  0  ) // Metro Cubico
					aAdd(aDadosDT4,aItensEDI[nI,EA_VALOR ]) // Valor da Mercadoria
					aAdd(aDadosDT4, .F. ) // Item deletado ou nao

					aGeraCot[Len(aGeraCot),GC_ITECOT, Len(aGeraCot[Len(aGeraCot),GC_ITECOT])] := AClone(aDadosDT4)

					//-- Tipos de Veiculos
					DEU->(DbSetOrder(1)) //- DEU_FILIAL+DEU_CGCREM+DEU_DOC+DEU_SERIE
					DEU->(MsSeek(xFilial("DEU")+aItensEDI[nI,EA_CGCREM]+aItensEDI[nI,EA_NUMNFC]+aItensEDI[nI,EA_SERNFC]))
					Do While DEU->(!Eof()) .And. xFilial("DEU")+aItensEDI[nI,EA_CGCREM]+aItensEDI[nI,EA_NUMNFC]+aItensEDI[nI,EA_SERNFC] == DEU->(DEU_FILIAL+DEU_CGCREM+DEU_DOC+DEU_SERIE)
						aDadosDT4 := {}
						aAdd( aDadosDT4, DEU->DEU_ITEM   ) // Item
						aAdd( aDadosDT4, DEU->DEU_TIPVEI ) // Tipo Veiculo
						aAdd( aDadosDT4, DEU->DEU_QTDVEI ) // Qtde Veiculo
						aAdd( aDadosDT4, .F. )             // Deletado (T/F)
						aAdd( aTipVei, AClone(aDadosDT4) )
						DEU->(DbSkip())
					EndDo

					aGeraCot[Len(aGeraCot),GC_TIPVEI] := AClone(aTipVei)
				Else

					nSeekItem := Ascan( aGeraCot[nSeek,GC_ITECOT], {|x|  x[2] == aItensEDI[nI,EA_CODPRO]} )
					If nSeekItem == 0

						//-- Itens da cotacao
						aAdd(aGeraCot[Len(aGeraCot),GC_ITECOT], {} )

						aDadosDT4 := {}
						aAdd(aDadosDT4,StrZero(Len(aGeraCot[Len(aGeraCot),GC_ITECOT]),2)) // Item da cotacao
						aAdd(aDadosDT4,aItensEDI[nI,EA_CODPRO]) // Codigo Produto
						aAdd(aDadosDT4,aItensEDI[nI,EA_CODEMB]) // Cod.Embalagem
						aAdd(aDadosDT4,aItensEDI[nI,EA_QTDVOL]) // Volumes
						aAdd(aDadosDT4,  0  ) // Unitizadores
						aAdd(aDadosDT4,aItensEDI[nI,EA_PESO  ]) // Peso Real
						aAdd(aDadosDT4,aItensEDI[nI,EA_PESOM3]) // Peso Cubado
						aAdd(aDadosDT4,  0  ) // Peso Líquido
						aAdd(aDadosDT4,  0  ) // Metro Cubico
						aAdd(aDadosDT4,aItensEDI[nI,EA_VALOR ]) // Valor da Mercadoria
						aAdd(aDadosDT4, .F. ) // Item deletado ou nao

						aGeraCot[Len(aGeraCot),GC_ITECOT, Len(aGeraCot[Len(aGeraCot),GC_ITECOT])] := AClone(aDadosDT4)
					Else
					//-- Itens da Cotacao
						aGeraCot[nSeek,GC_ITECOT,nSeekItem,4] += aItensEDI[nI,EA_QTDVOL] // Volumes
						aGeraCot[nSeek,GC_ITECOT,nSeekItem,6] += aItensEDI[nI,EA_PESO  ] // Peso Real
						aGeraCot[nSeek,GC_ITECOT,nSeekItem,7] += aItensEDI[nI,EA_PESOM3] // Peso Cubado
						aGeraCot[nSeek,GC_ITECOT,nSeekItem,9] += aItensEDI[nI,EA_VALOR ] // Valor da Mercadoria
					EndIf
					//-- Tipo de Veiculos
					DEU->(DbSetOrder(1)) //- DEU_FILIAL+DEU_CGCREM+DEU_DOC+DEU_SERIE
					DEU->(MsSeek(xFilial("DEU")+aItensEDI[nI,EA_CGCREM]+aItensEDI[nI,EA_NUMNFC]+aItensEDI[nI,EA_SERNFC]))
					Do While DEU->(!Eof()) .And. xFilial("DEU")+aItensEDI[nI,EA_CGCREM]+aItensEDI[nI,EA_NUMNFC]+aItensEDI[nI,EA_SERNFC] == DEU->(DEU_FILIAL+DEU_CGCREM+DEU_DOC+DEU_SERIE)
						//-- Verifica se tipo de veiculo já foi adicionado no aGeraCot
						nSeek2 := Ascan( aGeraCot[nSeek,GC_TIPVEI], {|e| e[2] == DEU->DEU_TIPVEI })

						If nSeek2 == 0
							aDadosDT4 := {}
							aAdd( aDadosDT4, StrZero(Len(aGeraCot[nSeek,GC_TIPVEI])+1,2)  ) // Item
							aAdd( aDadosDT4, DEU->DEU_TIPVEI ) // Tipo Veiculo
							aAdd( aDadosDT4, DEU->DEU_QTDVEI ) // Qtde Veiculo
							aAdd( aDadosDT4, .F. )             // Deletado (T/F)
							aAdd( aGeraCot[nSeek,GC_TIPVEI], AClone(aDadosDT4) )
						Else
							aGeraCot[nSeek,GC_TIPVEI,nSeek2,3] += DEU->DEU_QTDVEI  // Qtde Veiculo
						EndIf

						DEU->(DbSkip())

					EndDo

				EndIf
			EndIf
		EndIf
	Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Etapa 1 - Criação de Lotes de Notas Fiscais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	oSelf:SetRegua1(4)//-- Quantidade de Etapas

	oSelf:IncRegua1(STR0037)//"Etapa 1 - Criação de Lotes de Notas Fiscais"
	oSelf:SaveLog(STR0037) //"Etapa 1 - Criação de Lotes de Notas Fiscais"
EndIf


If lRet
	If !lJob
		oSelf:SetRegua2(Len(aLotNFC))
	EndIf

	For nI := 1 To Len(aLotNFC)
		Begin Transaction
    
			nPosaIt := AScan( aItensEDI, { |aIt| aIt[EA_RECDE5] == aLotNFC[nI,LT_RECDE5,1] } )

			If Empty(aItensEDI[nPosaIt,EA_LOTNFC])
				//-- Viagem Edi Auto: 0-Não Utiliza;1-Gera Viagem
				cViagem := ""
				If aLotNFC[nI,LT_EDIVGE] == "1"
					If !lJob
						oSelf:IncRegua2(STR0046)    //Gerando a viagem
					EndIf

					cViagem := AE75IncVge(@aLotNFC,nI,@aMsgErr)
					If Empty(cViagem)
						lRet := .F.
						DisarmTransaction()
					EndIf				
				EndIf

				If !lJob
					oSelf:IncRegua2(STR0030)//"Gerando Lotes..."
				EndIf
				If lRet
					lMsErroAuto := .F.
					aAdd(aCabDTP,{"DTP_QTDLOT",aLotNFC[nI,LT_QTDLOT],NIL})
					aAdd(aCabDTP,{"DTP_QTDDIG",0                    ,NIL})
					aAdd(aCabDTP,{"DTP_STATUS","1"                  ,NIL})
					If lTMSCTe
						aAdd(aCabDTP,{"DTP_TIPLOT","3" ,NIL})
					EndIf
					If aLotNFC[nI,LT_EDIVGE] == "1"
						aAdd(aCabDTP,{"DTP_VIAGEM",cViagem ,NIL})
					EndIf
					MsExecAuto({|x,y|cRet := TmsA170(x,y)},aCabDTP,3)
					If lMsErroAuto
						AAdd(aMsgErr,{STR0031+TRANSFORM(aLotNFC[nI,LT_CGCREM], x3Picture( "DE5_CGCREM" )),'00','TMSAE55()'}) //"Erro ao criar lote no processamento do CGC: "
						lRet := .F.
						DisarmTransaction()
					Else
						aLotNFC[nI,LT_LOTNFC] := cRet
						For nJ := 1 To Len(aLotNFC[nI,LT_RECDE5])
							DE5->(dbGoTo(aLotNFC[nI,LT_RECDE5,nJ]))
							RecLock('DE5',.F.)
							DE5->DE5_FILORI := cFilAnt
							DE5->DE5_LOTNFC := cRet
							MsUnLock()

							nPosaIt := AScan( aItensEDI, { |aIt| aIt[EA_RECDE5] == aLotNFC[nI,LT_RECDE5,nJ] } )
							aItensEDI[nPosaIt,EA_LOTNFC] := cRet

						Next nJ
					EndIf
				EndIf
			EndIf
		End Transaction

		If !lRet 
			aLotNFC[nI,LT_LOTNFC] := cRet
			For nJ := 1 To Len(aLotNFC[nI,LT_RECDE5])
				//-- Atualiza status DE5
				nPosaIt := AScan( aItensEDI, { |aIt| aIt[EA_RECDE5] == aLotNFC[nI,LT_RECDE5,nJ] } )
				AtuSTAuto( Nil, aItensEDI , nPosaIt, nPosaIt, "2", @aMsgErr )
			Next nJ
			Exit
		EndIf
	Next nI
EndIf

//-- Re ordena Array de Itens agora com LOTNFC
ASort( aItensEDI,,,{|x,y| x[ EA_MARCA ] + x[ EA_LOTNFC ] + x[ EA_CGCREM ] + x[ EA_LOTEDI ] + x[EA_NUMNFC] + x[EA_SERNFC] + x[EA_CODPRO] < y[ EA_MARCA ] + y[ EA_LOTNFC ] + y[ EA_CGCREM ] + y[ EA_LOTEDI ] + y[EA_NUMNFC] + y[EA_SERNFC] + y[EA_CODPRO] } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Etapa 2 - Criação de Cotação de Frete      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If !lJob
	oSelf:IncRegua1(STR0038)//"Etapa 2 - Criação de Cotação de Frete"
	oSelf:SaveLog(STR0038)//"Etapa 2 - Criação de Cotação de Frete"
EndIf

If !Empty(aGeraCot) .And. lRet

	If !lJob
		oSelf:SetRegua2(Len(aGeraCot))
	EndIf

	For nI := 1 To Len(aGeraCot)
		aCmpFrt   := {}
		cCodPro   := ""
		aCotacao  := {{},{},{},{},{},{},{}}

		If !lJob
			oSelf:IncRegua2(STR0032)//"Gerando Cotações..."
		EndIf

		aCotacao[DADOSCOT]  := AClone(aGeraCot[nI,GC_CABCOT])
		aCotacao[PRODCOT]   := AClone(aGeraCot[nI,GC_ITECOT])
		aCotacao[TIPVEICOT] := AClone(aGeraCot[nI,GC_TIPVEI])
		aCotacao[FRTCMPCOT] := AClone(aGeraCot[nI,GC_CMPCOT])

		Begin Transaction

		cNumCot  := ""
		l040Auto := .T.	
		TMSA040Mnt( "DT4", 0, 3 , , aCotacao,/*M->DTC_NUMSOL*/, CriaVar("DT4_NUMCOT",.F.) , .F.)
		l040Auto := .F.

		//-- Validação da Composição informada
		If !Empty(cNumCot)

			aCmpFrt := AClone(aGeraCot[nI,GC_CMPCOT])
			cCodPro := aGeraCot[nI,GC_ITECOT,1,2] //-- Codigo do Produto
			aTotFrtCp := {}

			DT8->(dbSetOrder(1)) //-- DT8_FILIAL+DT8_FILORI+DT8_NUMCOT+DT8_CODPRO+DT8_CODPAS
			If DT8->(MsSeek(xFilial("DT8")+cFilAnt+cNumCot)) .And. lRet
				While !DT8->(Eof()) .And. DT8->(DT8_FILORI+DT8_NUMCOT) == cFilAnt+cNumCot
					nSeek := aScan( aTotFrtCp, { |x| x[1] == DT8->DT8_CODPAS }  )
					If  nSeek == 0
						aAdd( aTotFrtCp, { DT8->DT8_CODPAS, DT8->DT8_VALPAS, DT8->DT8_VALTOT } )
					Else
						aTotFrtCp[ nSeek, 2 ] += DT8->DT8_VALPAS
						aTotFrtCp[ nSeek, 3 ] += DT8->DT8_VALTOT
					EndIf
					DT8->( DbSkip() )
				EndDo
			Else
				lRet := .F.
			EndIf

			If lRet
				For nJ := 1 To Len(aGeraCot[nI,GC_CMPCOT])
					nSeek := aScan( aTotFrtCp, { |x| x[1] == aCmpFrt[nJ,CODPASCMP] } )
					If nSeek > 0
						If aCmpFrt[nJ,TIPVALCMP] == "1"
							If aTotFrtCp[ nSeek, 3 ] <> aCmpFrt[nJ,VALPASCMP]
								lRet := .F.
							EndIf
						Else
							If aTotFrtCp[ nSeek, 2 ] <> aCmpFrt[nJ,VALPASCMP]
								lRet := .F.
							EndIf
						EndIf
					Else
						lRet := .F.
						Exit
					EndIf
				Next nJ
			EndIf

			If !lRet
				aAdd(aMsgErr,{STR0033+aGeraCot[nI,GC_LOTEDI],'00','TMSAE55()'})//"EDI Automático - Erro em composição informada em Lote EDI: "
				aGeraCot[nI,GC_COTOK ] := .F.
				lRet := .T.
				DisarmTransaction()
			Else
				aGeraCot[nI,GC_NUMCOT] := cNumCot
				aGeraCot[nI,GC_COTOK ] := .T.
				DET->(dbSetOrder(1))
				DET->(MsSeek(xFilial("DET")+aGeraCot[nI,GC_LOTEDI]))
				Do While !DET->(Eof()) .And. DET->DET_FILIAL+DET->DET_LOTEDI == xFilial("DET")+aGeraCot[nI,GC_LOTEDI]
					RecLock('DET',.F.)
					DET->DET_FILORI := aGeraCot[nI,GC_FILORI]
					DET->DET_NUMCOT := cNumCot
					MsUnLock()
					DET->(DbSkip())
				EndDo

			EndIf
		Else

			aAdd(aMsgErr,{STR0023+aGeraCot[nI,GC_LOTEDI],'00','TMSAE55()'}) //"EDI Automático - Erro na geração da cotação de frete do Lote EDI: "
			DisarmTransaction()

		EndIf

		End Transaction

		//-- Tratamento de erros
		If !aGeraCot[nI,GC_COTOK ] 
			//-- Busca o Lote envolvido na cotação
			nSeek := Ascan( aLotNFC, {|e|  e[LT_LOTEDI] == aGeraCot[nI,GC_LOTEDI] })
			//-- Percorre as NF's associadas ao Lote
			For nJ := 1 To Len(aLotNFC[nSeek,LT_RECDE5])
				//-- Atualiza status DE5
				nPosaIt := AScan( aItensEDI, { |aIt| aIt[EA_RECDE5] == aLotNFC[nSeek,LT_RECDE5,nJ] } )
				AtuSTAuto( Nil, aItensEDI , nPosaIt, nPosaIt, "2", @aMsgErr )
			Next nJ
		EndIf
	Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Etapa 3 - Inclusão de Notas Fiscais        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If !lJob
	oSelf:IncRegua1(STR0039)//"Etapa 3 - Inclusão de Notas Fiscais do Cliente"
	oSelf:SaveLog(STR0039)//"Etapa 3 - Inclusão de Notas Fiscais do Cliente"
EndIf

If lRet
	//-- Regua de processo
	If !lJob
		oSelf:SetRegua2(Len(aItensOk))
	EndIf

	//-- Processamento dos itens Ok
	For nI := 1 To Len(aItensOk)
		
		cNumCot := ""
		If !lJob
			oSelf:IncRegua2(STR0034)//"Documentos de Transporte de Cliente..."
		EndIf

		cCliRem := aItensEDI[aItensOk[nI],EA_CODCLI]
		cLojRem := aItensEDI[aItensOk[nI],EA_LOJCLI]
		cCliDes := aItensEDI[aItensOk[nI],EA_ACLDE5][NPOSDES][NPOSCOD]
		cLojDes := aItensEDI[aItensOk[nI],EA_ACLDE5][NPOSDES][NPOSLOJ]
		cCdrDes := aItensEDI[aItensOk[nI],EA_ACLDE5][NPOSDES][NPOSCDR]
		cCliCon := aItensEDI[aItensOk[nI],EA_ACLDE5][NPOSCON][NPOSCOD]
		cLojCon := aItensEDI[aItensOk[nI],EA_ACLDE5][NPOSCON][NPOSLOJ]
		cCliDpc := aItensEDI[aItensOk[nI],EA_ACLDE5][NPOSDPC][NPOSCOD]
		cLojDpc := aItensEDI[aItensOk[nI],EA_ACLDE5][NPOSDPC][NPOSLOJ]				
		cCliExp := aItensEDI[aItensOk[nI],EA_ACLDE5][NPOSEXP][NPOSCOD]
		cLojExp := aItensEDI[aItensOk[nI],EA_ACLDE5][NPOSEXP][NPOSLOJ]
		cCliRec := aItensEDI[aItensOk[nI],EA_ACLDE5][NPOSREC][NPOSCOD]
		cLojRec := aItensEDI[aItensOk[nI],EA_ACLDE5][NPOSREC][NPOSLOJ]
			
		If !Empty(aItensEDI[aItensOk[nI],EA_CGCDEV])
			cCliDev := aItensEDI[aItensOk[nI],EA_ACLDE5][NPOSDEV][NPOSCOD]
			cLojDev := aItensEDI[aItensOk[nI],EA_ACLDE5][NPOSDEV][NPOSLOJ]		
		Else
			If Empty(aItensEDI[aItensOk[nI],EA_TIPFRE]) .Or. aItensEDI[aItensOk[nI],EA_TIPFRE] == "1" //-- CIF
				cCliDev := cCliRem
				cLojDev := cLojRem
			Else
				cCliDev := cCliDes
				cLojDev := cLojDes
			EndIf
		EndIf

		If cCliDev+cLojDev == cCliRem+cLojRem
			cDevFre := "1" //-- Remetente
		ElseIf cCliDev+cLojDev == cCliDes+cLojDes
			cDevFre := "2" //-- Destinatário
		ElseIf cCliDev+cLojDev == cCliCon+cLojCon
			cDevFre := "3" //-- Consignatário
		ElseIf cCliDev+cLojDev == cCliDpc+cLojDpc
			cDevFre := "4" //-- Despachante
        ElseIf cClidev+cLojDev == cCliExp+cLojExp
            cDevFre := "6" //-- Expedidor
        ElseIf cClidev+cLojDev == cCliRec+cLojRec
            cDevFre := "7" //-- Recebedor
		Else
			cDevFre := "5" //-- Outros
		EndIf

		//-- Região de Origem
		If aItensEDI[aItensOk[nI],EA_SELORI] == "1"
			cCdrOri := cCdrPar
		Else
			cCdrOri := aItensEDI[aItensOk[nI],EA_ACLDE5][NPOSREM][NPOSCDR]
		EndIf

		//-- Posiciona Registro
		DE5->(DbGoTo(aItensEDI[aItensOk[nI],EA_RECDE5]))

		//-- Localiza o lote de nf
		If aItensEDI[aItensOk[nI],EA_EDILOT] == "1" //-- Por Processamento 
			nSeek := Ascan( aLotNFC, {|e| e[LT_CGCREM]+e[LT_LOTEDI] == aItensEDI[aItensOk[nI],EA_CGCREM]+aItensEDI[aItensOk[nI],EA_LOTEDI] } )
		ElseIf aItensEDI[aItensOk[nI],EA_EDILOT] == "3" //-- Por Placa
			nSeek := Ascan( aLotNFC, {|e| e[LT_PLACA] == aItensEDI[aItensOk[nI],EA_PLACA]  } )
		Else
			nSeek := Ascan( aLotNFC, {|e| e[LT_CGCREM] == aItensEDI[aItensOk[nI],EA_CGCREM] .And. e[LT_CGCDES] == aItensEDI[aItensOk[nI],EA_CGCDES] .And. e[LT_LOTEDI] == aItensEDI[aItensOk[nI],EA_LOTEDI] } )
		EndIf

		cLotNFC := aLotNFC[nSeek,LT_LOTNFC]
		If aItensEDI[nI,EA_EDIAUT] == "2" .And. !aLotNFC[nSeek,LT_CALLOT] //-- Lote c/ calculo
			aLotNFC[nSeek,LT_CALLOT] := .T.
		EndIf

		//-- Verifica se foi gerado cotação para o lotedi
		If Empty(aItensEDI[aItensOk[nI],EA_NUMCOT]); 
				    .And. (;
					       aItensEDI[aItensOk[nI],EA_EDIFRT] == '1' ; //-- Assume Frete CIF/FOB
					       .Or. (aItensEDI[aItensOk[nI],EA_EDIFRT] == '3' .And. aItensEDI[nI,EA_TIPFRE] == "1"  ); //-- Assume Apenas CIF
					       .Or. (aItensEDI[aItensOk[nI],EA_EDIFRT] == '4' .And. aItensEDI[nI,EA_TIPFRE] == "2"  ); //-- Assume Apenas FOB
					      )

			nSeek := Ascan( aGeraCot ,{|e| e[GC_LOTEDI] == aItensEDI[aItensOk[nI],EA_LOTEDI] .And. e[GC_COTOK ] == .T. } )

			If nSeek <> 0
				cNumCot := aGeraCot[nSeek,GC_NUMCOT]
			EndIf

		ElseIf aItensEDI[aItensOk[nI],EA_EDIFRT] == '1' ; //-- Assume Frete CIF/FOB
				.Or. (aItensEDI[aItensOk[nI],EA_EDIFRT] == '3' .And. aItensEDI[nI,EA_TIPFRE] == "1"  ); //-- Assume Apenas CIF
				.Or. (aItensEDI[aItensOk[nI],EA_EDIFRT] == '4' .And. aItensEDI[nI,EA_TIPFRE] == "2"  ) //-- Assume Apenas FOB

			cNumCot := aItensEDI[aItensOk[nI],EA_NUMCOT]

		EndIf
		
		
		cSeqEnd := aItensEDI[aItensOk[nI],EA_SEQEND]
		cFILDPC := aItensEDI[aItensOk[nI],EA_FILDPC] 
		cCTRDPC := aItensEDI[aItensOk[nI],EA_CTRDPC]
		cEMINFE := aItensEDI[aItensOk[nI],EA_SEQEND]
		cCODNFE := aItensEDI[aItensOk[nI],EA_CODNFE]
		cNFELET := aItensEDI[aItensOk[nI],EA_NFELET]
		
		If lAgdEntr
			cTipAgd := aItensEDI[aItensOk[nI],EA_TIPAGD]
			dDatAgd := aItensEDI[aItensOk[nI],EA_DATAGD]
			cPrdAgd := aItensEDI[aItensOk[nI],EA_PRDAGD]
			cIniAgd := aItensEDI[aItensOk[nI],EA_INIAGD]
			cFimAgd := aItensEDI[aItensOk[nI],EA_FIMAGD]
			cMotAgd := aItensEDI[aItensOk[nI],EA_MOTAGD]	
		EndIf 
		
		cTxtMemo1 := ""
		nLinMemo := MlCount(aItensEDI[aItensOk[nI],EA_OBSAUT],250)		
		For nCntMemo := 1 To nLinMemo
			cTxtMemo1 += MemoLine(aItensEDI[aItensOk[nI],EA_OBSAUT],250,nCntMemo)
		Next nCntMemo
		
		nVALSEG += aItensEDI[aItensOk[nI],EA_VALSEG]
		nMETRO3 := aItensEDI[aItensOk[nI],EA_METRO3]
		nBASEIC := aItensEDI[aItensOk[nI],EA_BASEIC]
		nVALICM := aItensEDI[aItensOk[nI],EA_VALICM]
		nBASIST := aItensEDI[aItensOk[nI],EA_BASIST]		
		nVALIST := aItensEDI[aItensOk[nI],EA_VALIST]		 

		// Verifica novamente o tipo do documento caso a região de calculo seja alterada
		cDocTms := Space(Len( DC5->DC5_DOCTMS))
		If lIdentDoc 
			DC5->(dbSetOrder(1)) //--DC5_FILIAL+DC5_SERVIC
			If DC5->(MsSeek(xFilial("DC5")+ aItensEDI[aItensOk[nI],EA_SERVIC])) .And. !Empty(DC5->DC5_DOCTMS)
				cDocTms := DC5->DC5_DOCTMS
			EndIf
		EndIf

		aCabDTC := {	{"DTC_FILORI" ,cFilAnt   , Nil},;
						{"DTC_LOTNFC" ,cLotNFC   , Nil},;
						{"DTC_CLIREM" ,aItensEDI[aItensOk[nI],EA_CODCLI], Nil},;
						{"DTC_LOJREM" ,aItensEDI[aItensOk[nI],EA_LOJCLI], Nil},;
						{"DTC_DATENT" ,dDataBase , Nil},;
						{"DTC_CLIDES" ,cCliDes   , Nil},;
						{"DTC_LOJDES" ,cLojDes   , Nil},;
						{"DTC_CLICON" ,cCliCon   , Nil},;
						{"DTC_LOJCON" ,cLojCon   , Nil},;
						{"DTC_CLIDPC" ,cCliDpc   , Nil},;
						{"DTC_LOJDPC" ,cLojDpc   , Nil},;
						{"DTC_CLIDEV" ,cCliDev   , Nil},;
						{"DTC_LOJDEV" ,cLojDev   , Nil},;
						{"DTC_DEVFRE" ,cDevFre   , Nil},;
						{"DTC_SERTMS" ,aItensEDI[aItensOk[nI],EA_SERTMS], Nil},;
						{"DTC_TIPTRA" ,aItensEDI[aItensOk[nI],EA_TIPTRA], Nil},;
						{"DTC_CODNEG" ,aItensEDI[aItensOk[nI],EA_CODNEG], Nil},;
						{"DTC_SERVIC" ,aItensEDI[aItensOk[nI],EA_SERVIC], Nil},;
						{"DTC_TIPNFC" ,"0"       , Nil},;
						{"DTC_TIPFRE" ,aItensEDI[aItensOk[nI],EA_TIPFRE], Nil},;
						{"DTC_CLIEXP",cCliExp	, NIL},;
						{"DTC_LOJEXP",cLojExp	, NIL},;
						{"DTC_SELORI" ,aItensEDI[aItensOk[nI],EA_SELORI], Nil},;
						{"DTC_CDRORI" ,cCdrOri   , Nil},;
						{"DTC_CDRDES" ,cCdrDes   , Nil},;
						{"DTC_DISTIV" ,"2"       , Nil},;
						{"DTC_NUMCOT" ,Iif(!Empty(cNumCot),cNumCot, CriaVar("DTC_NUMCOT")) , Nil},;
						{"DTC_SQEDES" ,cSeqEnd   , Nil},;
						{"DTC_OBS"    ,cTxtMemo1 , Nil},; 
						{"DTC_FILDPC" ,cFILDPC , Nil},;
						{"DTC_CTRDPC" ,cCTRDPC , Nil},;
						{"DTC_VALSEG" ,nVALSEG , Nil}}
        
        If DTC->(ColumnPos("DTC_CLIREC")) > 0 .And. DE5->(ColumnPos("DE5_CGCREC")) > 0
            Aadd(aCabDTC,{"DTC_CLIREC",cCliRec,NIL})
            Aadd(aCabDTC,{"DTC_LOJREC",cLojRec,NIL})
        EndIf
		If lIdentDoc
            Aadd(aCabDTC,{"DTC_DOCTMS",cDocTms,NIL})
		EndIf

//-- Ponto de entrada para alterar dados do cabeçalho da nota antes do execauto
		If lTME75CAB
			aCpos := Execblock("TME75CAB",.F.,.F.,{aCabDTC,aItensEDI[aItensOk[nI],EA_RECDE5]})
			If Valtype(aCpos) = 'A'
				For nCntFor := 1 To Len(aCpos)
					nSeek2 := aScan(aCabDTC,{|x| AllTrim(Upper(x[1])) == AllTrim(Upper(aCpos[nCntFor][1]))})
					If nSeek2 <> 0
						aCabDTC[nSeek2][2] := aCpos[nCntFor][2]
					Else
						AAdd( aCabDTC, aCpos[nCntFor] )
					EndIf
				Next nCntFor
			EndIf
		EndIf
		If lAgdEntr
			aItem   := {	{"DTC_NUMNFC" ,aItensEDI[aItensOk[nI],EA_NUMNFC], Nil},;
							{"DTC_SERNFC" ,aItensEDI[aItensOk[nI],EA_SERNFC], Nil},;
							{"DTC_CODPRO" ,aItensEDI[aItensOk[nI],EA_CODPRO], Nil},;
							{"DTC_CODEMB" ,aItensEDI[aItensOk[nI],EA_CODEMB], Nil},;
							{"DTC_CF"     ,DE5->DE5_CFOPNF                  , Nil},;
							{"DTC_EMINFC" ,StoD(aItensEDI[aItensOk[nI],EA_EMINFC]), Nil},;
							{"DTC_QTDVOL" ,aItensEDI[aItensOk[nI],EA_QTDVOL], Nil},;
							{"DTC_PESO"   ,aItensEDI[aItensOk[nI],EA_PESO  ], Nil},;
							{"DTC_PESOM3" ,aItensEDI[aItensOk[nI],EA_PESOM3], Nil},;
							{"DTC_PESLIQ" ,aItensEDI[aItensOk[nI],EA_PESLIQ], Nil},;
							{"DTC_VALOR"  ,aItensEDI[aItensOk[nI],EA_VALOR ], Nil},;
							{"DTC_QTDUNI" ,0         , Nil},;
							{"DTC_EDI"    ,"1"       , Nil},;
							{"DTC_NFENTR" ,"2"       , Nil},;
							{"DTC_NFEID"  ,aItensEDI[aItensOk[nI],EA_NFEID ], Nil} ,; 						
							{"DTC_METRO3" ,nMETRO3, Nil},;
							{"DTC_BASICM" ,nBASEIC, Nil},;
							{"DTC_VALICM" ,nVALICM, Nil},;
							{"DTC_BASESU" ,nBASIST, Nil},;
							{"DTC_VALIST" ,nVALIST, Nil},;
							{"DTC_EMINFE" ,cEMINFE , Nil},;
							{"DTC_CODNFE" ,cCODNFE , Nil},;
							{"DTC_NFELET" ,cNFELET , Nil},;
							{"DTC_TIPAGD" ,cTipAgd, Nil},;
							{"DTC_DATAGD" ,dDatAgd, Nil},;
							{"DTC_PRDAGD" ,cPrdAgd, Nil},;
							{"DTC_INIAGD" ,cIniAgd , Nil},;
							{"DTC_FIMAGD" ,cFimAgd , Nil},;
							{"DTC_MOTAGD" ,cMotAgd , Nil}}
		Else 
			aItem   := {	{"DTC_NUMNFC" ,aItensEDI[aItensOk[nI],EA_NUMNFC], Nil},;
							{"DTC_SERNFC" ,aItensEDI[aItensOk[nI],EA_SERNFC], Nil},;
							{"DTC_CODPRO" ,aItensEDI[aItensOk[nI],EA_CODPRO], Nil},;
							{"DTC_CODEMB" ,aItensEDI[aItensOk[nI],EA_CODEMB], Nil},;
							{"DTC_CF"     ,DE5->DE5_CFOPNF                  , Nil},;
							{"DTC_EMINFC" ,StoD(aItensEDI[aItensOk[nI],EA_EMINFC]), Nil},;
							{"DTC_QTDVOL" ,aItensEDI[aItensOk[nI],EA_QTDVOL], Nil},;
							{"DTC_PESO"   ,aItensEDI[aItensOk[nI],EA_PESO  ], Nil},;
							{"DTC_PESOM3" ,aItensEDI[aItensOk[nI],EA_PESOM3], Nil},;
							{"DTC_PESLIQ" ,aItensEDI[aItensOk[nI],EA_PESLIQ], Nil},;
							{"DTC_VALOR"  ,aItensEDI[aItensOk[nI],EA_VALOR ], Nil},;
							{"DTC_QTDUNI" ,0         , Nil},;
							{"DTC_EDI"    ,"1"       , Nil},;
							{"DTC_NFENTR" ,"2"       , Nil},;
							{"DTC_NFEID"  ,aItensEDI[aItensOk[nI],EA_NFEID ], Nil} ,; 						
							{"DTC_METRO3" ,nMETRO3, Nil},;
							{"DTC_BASICM" ,nBASEIC, Nil},;
							{"DTC_VALICM" ,nVALICM, Nil},;
							{"DTC_BASESU" ,nBASIST, Nil},;
							{"DTC_VALIST" ,nVALIST, Nil},;
							{"DTC_EMINFE" ,cEMINFE , Nil},;
							{"DTC_CODNFE" ,cCODNFE , Nil},;
							{"DTC_NFELET" ,cNFELET , Nil}}

		EndIf 
				
        //--P.E. Adiciona novos campos nos Itens da nota
        If lTME75ITE
            aCpitem := Execblock("TME75ITE",.F.,.F.,{aItem,aItensEDI[aItensOk[nI],EA_RECDE5]})
            If Valtype(aCpitem) = 'A'
            	For nCntFor := 1 To Len(aCpitem)
					nSeek2 := aScan(aItem,{|x| AllTrim(Upper(x[1])) == AllTrim(Upper(aCpitem[nCntFor][1]))})
					If nSeek2 <> 0
						aItem[nSeek2][2] := aCpitem[nCntFor][2]
					Else
                		AAdd( aItem, aCpitem[nCntFor] )
					EndIf
                Next nCntFor
            EndIf
        EndIf
        
		aAdd(aIteDTC,aClone(aItem))
			
		If Len(aItensOk) == nI
			lCallExec := .T.
		ElseIf	aItensEDI[aItensOk[nI],  EA_LOTNFC]+aItensEDI[aItensOk[nI],  EA_CODCLI]+aItensEDI[aItensOk[nI],  EA_LOJCLI]+aItensEDI[aItensOk[nI],  EA_CGCDES]+aItensEDI[aItensOk[nI],  EA_CODNEG]+aItensEDI[aItensOk[nI],  EA_SERVIC]+aItensEDI[aItensOk[nI],  EA_LOTEDI] <> ;
				aItensEDI[aItensOk[nI+1],EA_LOTNFC]+aItensEDI[aItensOk[nI+1],EA_CODCLI]+aItensEDI[aItensOk[nI+1],EA_LOJCLI]+aItensEDI[aItensOk[nI+1],EA_CGCDES]+aItensEDI[aItensOk[nI+1],EA_CODNEG]+aItensEDI[aItensOk[nI+1],EA_SERVIC]+aItensEDI[aItensOk[nI+1],EA_LOTEDI]
			lCallExec := .T.
		EndIf

		//-- Ponto de entrada para alterar o comportamento da quebra de NF (agrupamento)
		If lTME75QNF
			lCallPE := Execblock("TME75QNF",.F.,.F.,{aItensEDI,aItensOk[nI],nI,lCallExec})
			If Valtype(lCallPE) == 'L'
				lCallExec := lCallPE
			EndIf
		EndIf

		If lCallExec
			Begin Transaction
			//-- Inclusão da Nf's do cliente
			MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aIteDTC,,,3)

			If lMsErroAuto
				AAdd(aMsgErr,{STR0034+TRANSFORM(aItensEDI[aItensOk[nI],EA_CGCREM], x3Picture( "DE5_CGCREM" )),'00','TMSAE55()'}) //"EDI Automático - Erro ao incluir documento de transporte do cliente CGC: "
				lRet := .F.
				DisarmTransaction()
			Else
				//-- Grava tipo de veículo em DVU
				TMSAtuTVei( cFilAnt, aItensEDI[aItensOk[nI]], cLotNFC )

				//-- Atualiza Status EDI
				AtuSTAuto( aItensOk, aItensEDI , nI, (nI-Len(aIteDTC)+1), "1" )

			EndIf
			End Transaction

			//-- Atualiza o status da DE5 em caso de insucesso
			If !lRet
				AtuSTAuto( aItensOk, aItensEDI , nI, (nI-Len(aIteDTC)+1), "2", @aMsgErr )
			EndIf

			aIteDTC   := {}
			lCallExec := .F.
			nVALSEG := 0
		EndIf
	Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Etapa 4 - Lote de NF com calculo           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//-- A partir desta etapa, não executa-se via JOB, pois já existem soluções para fechamento e transmissão
If !lJob
	oSelf:IncRegua1(STR0040)//"Etapa 4 - Lote de NF com calculo"
	oSelf:SaveLog(STR0040)//"Etapa 4 - Lote de NF com calculo"

	If lRet
		oSelf:SetRegua2(Len(aLotNFC))
		For nI := 1 To Len(aLotNFC)
			oSelf:IncRegua2(STR0036)//"Calculando Lotes..."
			If aLotNFC[nI,LT_CALLOT]
				TMSA200Prc(aLotNFC[nI,LT_FILORI],aLotNFC[nI,LT_LOTNFC])
			EndIf
		Next nI
	EndIf
EndIf

//-- Help
aErroLog := GetAutoGrLog()
If !Empty(aErroLog)
	For nI := 1 To Len(aErroLog)
		Aadd(aMsgErr, { NoAcentoCTE(aErroLog[nI] ),'00','TMSAE55()' })
	Next nI
EndIf

If !Empty(aMsgErr)
	AaddMsgErr( aMsgErr, @aVisErr)
	If !lJob
		TmsMsgErr( aVisErr )
	EndIf
EndIf

If !lJob
	oSelf:SaveLog(STR0013) //"Processamento finalizado"
EndIf
RestArea(aAreaAtu)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAtuTVei³ Autor ³ Gustavo Almeida       ³ Data ³09/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Atualização da Tabela DVU                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE75                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSAtuTVei(cFilOri, aItemEDI, cLotNFC)

DEU->(dbSetOrder(1))
DEU->(MsSeek(xFilial("DEU") + aItemEDI[EA_CGCREM] + aItemEDI[EA_NUMNFC] + aItemEDI[EA_SERNFC]))
Do While !DEU->(Eof()) .And. DEU->DEU_FILIAL+DEU->DEU_CGCREM+DEU->DEU_DOC+DEU->DEU_SERIE == xFilial("DEU")+aItemEDI[EA_CGCREM]+aItemEDI[EA_NUMNFC]+aItemEDI[EA_SERNFC]
	RecLock("DVU", .T.)
	DVU->DVU_FILIAL := xFilial("DVU")
	DVU->DVU_ITEM   := DEU->DEU_ITEM
	DVU->DVU_FILORI := cFilOri
	DVU->DVU_LOTNFC := cLotNFC
	DVU->DVU_NUMNFC := aItemEDI[EA_NUMNFC]
	DVU->DVU_SERNFC := aItemEDI[EA_SERNFC]
	DVU->DVU_CLIREM := aItemEDI[EA_ACLDE5][NPOSREM][NPOSCOD]
	DVU->DVU_LOJREM := aItemEDI[EA_ACLDE5][NPOSREM][NPOSLOJ]
	DVU->DVU_TIPVEI := DEU->DEU_TIPVEI
	DVU->DVU_QTDVEI := DEU->DEU_QTDVEI
	DVU->(MsUnLock())
	DEU->(DbSkip())
EndDo

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAE75MRK ³ Autor ³ Gustavo Almeida     ³ Data ³09/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca itens no listbox                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE75MRK                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE75                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE75MRK(lTodos,nItem)

Local nI       := 0
Local nPosLine := 1
Local bBlock   := { || }
Local lPEMRK   := .T.
Local lTME75MRK  := ExistBlock("TME75MRK")
Local nItens	 	:= 0

Default nItem  := oListBox:nAt
Default lTodos := .F. 

If !lTodos

	CursorWait()
	//-- Todos com o mesmo loteedi serão marcados ou desmarcados
	If !Empty( aItensEDI[nItem,EA_LOTEDI] )
		nPosLine := aScan( aItensEDI, { |x| x[EA_LOTEDI] == aItensEDI[nItem,EA_LOTEDI] } )
		bBlock   := { || aItensEDI[nI,EA_LOTEDI] == aItensEDI[nItem,EA_LOTEDI] }

	Else
		nPosLine := aScan( aItensEDI, { |x| x[EA_CGCREM] + x[EA_NUMNFC] + x[EA_SERNFC] == aItensEDI[nItem,EA_CGCREM] + aItensEDI[nItem,EA_NUMNFC] + aItensEDI[nItem,EA_SERNFC] } )
		bBlock   := { || aItensEDI[nI,EA_NUMNFC] + aItensEDI[nI,EA_SERNFC] + aItensEDI[nI,EA_CGCREM] == aItensEDI[nItem,EA_NUMNFC] + aItensEDI[nItem,EA_SERNFC] + aItensEDI[nItem,EA_CGCREM] }

	EndIf

		For nI := nPosLine To Len(aItensEDI)

			If Eval( bBlock )
			
				//-- Ponto de entrada("TME75MRK")Checkbox.
				If lTME75MRK
					lPEMRK := ExecBlock("TME75MRK",.F.,.F.,{aItensEDI[nI,EA_CGCREM], aItensEDI[nI,EA_NUMNFC], aItensEDI[nI,EA_SERNFC], nPosLine, lTodosMark, aItensEDI[nI]})
					If	ValType(lPEMRK) == "L"
						lTodosMark := lPEMRK						
						If lTodosMark
							aItensEDI[nI,EA_MARCA] := "1"
						Else
							aItensEDI[nI,EA_MARCA] := "2"
						EndIf				
					EndIf
				Else
					aItensEDI[nI,EA_MARCA] := Iif( aItensEDI[nI,EA_MARCA] == "1", "2", "1" )	
				EndIf
				
				nVolumes := 0
				nPesReal := 0
				nValMerc := 0
				nPesReal := 0
				nPesCub  := 0
				nPesLiq  := 0
				nDoctos := 0
				For nItens := 1 to Len (aItensEDI)
					If aItensEDI[nItens,EA_MARCA] == "1"
						nVolumes += aItensEDI[nItens,EA_QTDVOL]
						nPesReal += aItensEDI[nItens,EA_PESO  ]
						nPesCub  += aItensEDI[nItens,EA_PESOM3]
						nPesLiq  += aItensEDI[nItens,EA_PESLIQ]
						nValMerc += aItensEDI[nItens,EA_VALOR ]
						nDoctos  += 1
					EndIf
				Next
			Else
				Exit
			EndIf

		Next nI
	CursorArrow()
Else
	CursorWait()
	nVolumes := 0
	nPesReal := 0
	nPesCub  := 0
	nPesLiq  := 0
	nValMerc := 0
	nDoctos  := 0

	For nI := 1 To Len(aItensEDI)
			
		//-- Ponto de entrada("TME75MRK")Checkbox.
		If lTME75MRK
			lPEMRK := ExecBlock("TME75MRK",.F.,.F.,{aItensEDI[nI,EA_CGCREM], aItensEDI[nI,EA_NUMNFC], aItensEDI[nI,EA_SERNFC], nPosLine, lTodosMark, aItensEDI[nI]})
			If	ValType(lPEMRK) == "L"
				lTodosMark := lPEMRK
			EndIf
		EndIf
			
		If lTodosMark		
			aItensEDI[nI,EA_MARCA] := "1"
			nVolumes += aItensEDI[nI,EA_QTDVOL]
			nPesReal += aItensEDI[nI,EA_PESO  ]
			nPesCub  += aItensEDI[nI,EA_PESOM3]
			nPesLiq  += aItensEDI[nI,EA_PESLIQ]
			nValMerc += aItensEDI[nI,EA_VALOR ]
			nDoctos  += 1
		Else
			aItensEDI[nI,EA_MARCA] := "2"
		EndIf
	Next nI

	CursorArrow()
EndIf

oVolumes:Refresh()
oPesReal:Refresh()
oValMerc:Refresh()
oPesCub:Refresh()
oPesLiq:Refresh()
oDoctos:Refresh()
oListBox:Refresh()

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE75Psq ³  Autor ³ Gustavo Almeida     ³ Data ³20.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa Documentos EDI                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE75Psq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE75                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE75Psq()

Local aCbx		:= {}
Local cCampo	:= ""
Local cOrd

Local lSeek		:= .F.
Local nOrdem	:= 1
Local nSeek		:= 0
Local oCbx
Local oDlg
Local oPsqGet

cCampo := AllTrim(Posicione('SX3', 2, 'DE5_CGCREM'	, 'X3Titulo()'))
Aadd( aCbx, cCampo )

cCampo := AllTrim(Posicione('SX3', 2, 'DT6_NOMREM'	, 'X3Titulo()'))
Aadd( aCbx, cCampo ) 

cCampo := AllTrim(Posicione('SX3', 2, 'DE5_CGCDES'	, 'X3Titulo()'))
Aadd( aCbx, cCampo )

cCampo := AllTrim(Posicione('SX3', 2, 'DT6_NOMDES'	, 'X3Titulo()'))
Aadd( aCbx, cCampo )

cCampo := AllTrim(Posicione('SX3', 2, 'DUD_DOC'		, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_SERIE'	, 'X3Titulo()'))
Aadd( aCbx, cCampo )

cCampo := AllTrim(Posicione('SX3', 2, 'DE5_LOTEDI'	, 'X3Titulo()'))
Aadd( aCbx, cCampo )

cCampo := Space( 40 )

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0005 //"Pesquisa"

@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt

@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL 

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If lSeek
	cCampo := AllTrim( cCampo )
	If nOrdem == 1
		//-- CGC Remetente
		ASort( aItensEDI,,,{|x,y| x[ EA_CGCREM ] < y[ EA_CGCREM ] })
		nSeek := Ascan( aItensEDI,{ | x | PadR( x[ EA_CGCREM ], Len( cCampo ) ) == cCampo } )
		
	ElseIf nOrdem == 2
		//-- Nome Remetente
		ASort( aItensEDI,,,{|x,y| x[ EA_NOMREM ] < y[ EA_NOMREM ] })
		nSeek := Ascan( aItensEDI,{ | x | PadR( x[ EA_NOMREM ], Len( cCampo ) ) == cCampo } )
		
	ElseIf nOrdem == 3
		//-- CGC Destinatário
		ASort( aItensEDI,,,{|x,y| x[ EA_CGCDES ] < y[ EA_CGCDES ] })
		nSeek := Ascan( aItensEDI,{ | x | PadR( x[ EA_CGCDES ], Len( cCampo ) ) == cCampo } )

	ElseIf nOrdem == 4
		//-- Nome Destinatário
		ASort( aItensEDI,,,{|x,y| x[ EA_NOMDES ] < y[ EA_NOMDES ] })
		nSeek := Ascan( aItensEDI,{ | x | PadR( x[ EA_NOMDES ], Len( cCampo ) ) == cCampo } )

	ElseIf nOrdem == 5
		//-- Docto + Serie
		ASort( aItensEDI,,,{|x,y| x[ EA_NUMNFC ] + x[ EA_SERNFC ] <  y[ EA_NUMNFC ] + y[ EA_SERNFC ] })
		nSeek := Ascan( aItensEDI,{ | x | PadR( x[ EA_NUMNFC ] + x[ EA_SERNFC ], Len( cCampo ) ) == cCampo } )

	ElseIf nOrdem == 6
		//-- Lote Edi
		ASort( aItensEDI,,,{|x,y| x[ EA_LOTEDI ] < y[ EA_LOTEDI] })
		nSeek := Ascan( aItensEDI,{ | x | PadR( x[ EA_LOTEDI ], Len( cCampo ) ) == cCampo } )

	EndIf
EndIf

If nSeek > 0
	oListBox:nAT := nSeek
	oListBox:Refresh()
EndIf
oListBox:SetFocus()

Return NIL

//===========================================================================================================
/*------------- Busca a CNPJ e Incrição Estadual-------------------------------------------
@author  	ALEX AMARAL
@version 	P12 R14
@build		
@since 	26/05/2017
@return 	 */                                                                                                         
//===========================================================================================================
Function TMS75IEDI(cCNPJ, cIEDes, cIEDev )

Local cQuery     := ""
Local cAliasSA1  := GetNextAlias()
Local aRet       := {}

Default cCNPJ  := ""
Default cIEDes := ""
Default cIEDev := ""

		cQuery := " SELECT A1_CGC, A1_INSCR, A1_COD, A1_LOJA, A1_CDRDES, SA1.R_E_C_N_O_ RECNOEDI "
		cQuery += "   FROM " + RetSQLTab("SA1")
		cQuery += "   WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery += "     AND A1_CGC = '" + cCNPJ + "'" 	
		If !Empty(cIEDes) 
			cQuery += "     AND A1_INSCR = '" + cIEDes +"' " //--Busca o IE do Destinatario
		ElseIf !Empty(cIEDev)
			cQuery += "     AND A1_INSCR = '" + cIEDev +"' " //--Busca o IE do Devedor
		EndIf
		cQuery += "     AND A1_CDRDES <> ' ' "
		cQuery += "     AND D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasSA1, .F., .T. )		
		
	
		If !(cAliasSA1)->(Eof())
			aRet := {(cAliasSA1)->A1_COD,(cAliasSA1)->A1_LOJA, (cAliasSA1)->A1_CDRDES,(cAliasSA1)->RECNOEDI }
		EndIf
		(cAliasSA1)->(DbCloseArea())

Return( aRet )
	
/*/{Protheus.doc} AtuSTAuto
//TODO Atualiza Status EDI
@author caio.y
@since 06/10/2017
@version 1.0
@return ${return}, ${return_description}
@param aItensEDI, array, descricao
@param nI, Numeric, posicao final no array aItensEDI a ser atualizada
@param nStart, Numeric, posicial Inicial no array aItensEDI a ser atualizada
@type function
/*/
Static Function AtuSTAuto(aItensOk, aItensEDI, nI, nStart, cStatus, aMsgErr)
Local aAreaDE5	:= DE5->(GetArea())
Local nCnt		:= 1 
Local cErro     := ""
Local aErroLog, nErroIni

Default aItensEDI		:= {}
Default nI				:= 1
Default nStart 			:= nI
Default cStatus			:= "1"
Default aMsgErr			:= {}

//-- Quando não executou com sucesso, captura erros de Help/ExecAuto
If cStatus == "2"
	//-- Salva o erro Atual na mensagem (erro do AE75 para a rotina)
	nErroIni := Len(aMsgErr)
	cErro    := Iif(nErroIni > 0,aTail(aMsgErr)[1],"") + Chr(13) + Chr(10)

	//-- Soma os erros de Help/ExecAuto
	aErroLog := GetAutoGrLog()
	If !Empty(aErroLog)
		For nCnt := 1 To Len(aErroLog)
			Aadd(aMsgErr, { NoAcentoCTE(aErroLog[nCnt] ),'00','TMSAE55()' })
			cErro += aErroLog[nCnt] + Chr(13) + Chr(10)
		Next nCnt
	EndIf
EndIf

//-- Grava Status
For nCnt := nStart  To nI 
	//-- Atualiza DE5
	If aItensOk != Nil
		DE5->(dbGoTo(aItensEDI[aItensOk[nCnt],EA_RECDE5]))
	Else
		DE5->(dbGoTo(aItensEDI[nCnt,EA_RECDE5]))
	EndIf
		
	RecLock("DE5",.F.)
	DE5->DE5_STAUTO := cStatus //-- "1" - Exec. com Sucesso; "2" - Executado com erro
	//-- Gravar Campo Memo.
	If DE5->(ColumnPos("DE5_LOGAUT")) > 0
		DE5->DE5_LOGAUT := cErro
	EndIf
	MsUnlock()
	
Next nCnt

RestArea(aAreaDE5)

Return

/*/{Protheus.doc} AE75IncVge
//Inclui Viagem para o Lote EDI
@author Katia
@since 26/05/2021
@version 12.1.33
@param aLotNFC, array, descricao
@param nI, Numeric, descricao
@type function
/*/
Static Function AE75IncVge(aLotNFC,nI,aMsgErr)
Local cRet       := ""
Local aAreas     := {DE5->(GetArea()),DA3->(GetArea()),GetArea()}
Local cCodMot    := ""
Local cCodVei    := ""
Local cCodRb1    := ""
Local cCodRb2    := ""
Local cCodRb3    := ""
Local cRota      := GetMv("MV_ROTGENT",,"")
Local oModel     := Nil
Local lVgeMod3   := AliasInDic("DM3") .And. FindFunction('TMSAF60')

Default aLotNFC:= {}
Default nI     := 0
Default aMsgErr:= {}

lRet:= lVgeMod3 .And. Len(aLotNFC) > 0 .And. nI > 0
If lRet
	//-- Verifica se o veículo existe
	If !Empty(aLotNFC[nI,LT_PLACA])
		DA3->(DbSetOrder(3)) //-- DA3_FILIAL+DA3_PLACA
		If DA3->(DbSeek(xFilial("DA3")+PadR(aLotNFC[nI,LT_PLACA],Len(DA3->DA3_PLACA)) ))
			cCodVei := DA3->DA3_COD
			cCodMot := DA3->DA3_MOTORI
		EndIf
	EndIf

	//-- Se não encontrou Veiculo/Motorista, aciona como PLANEJADA a viagem e coloca genéricos
	If Empty(cCodVei) .Or. Empty(cCodMot)
		cCodVei := Iif(Empty(cCodVei),SuperGetMv('MV_VEIGEN',,""), cCodVei)
		cCodMot := SuperGetMv('MV_MOTGEN',,"")
	Else
		cCodRb1 := Posicione("DA3",3,xFilial("DA3")+PadR(aLotNFC[nI,LT_PLARB1],Len(DA3->DA3_PLACA)),"DA3_COD" )
		cCodRb2 := Posicione("DA3",3,xFilial("DA3")+PadR(aLotNFC[nI,LT_PLARB2],Len(DA3->DA3_PLACA)),"DA3_COD" )
		cCodRb3 := Posicione("DA3",3,xFilial("DA3")+PadR(aLotNFC[nI,LT_PLARB3],Len(DA3->DA3_PLACA)),"DA3_COD" )
	EndIf

	SaveInter() 

	oModel := FwLoadModel("TMSAF60")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()		
	//---- DTQ
	oModel:SetValue( "MdFieldDTQ", "DTQ_SERTMS"		, StrZero( 3, Len( DTQ->DTQ_SERTMS )) )
	oModel:SetValue( "MdFieldDTQ", "DTQ_TIPTRA"		, StrZero( 1, Len( DTQ->DTQ_TIPTRA )) )
	oModel:SetValue( "MdFieldDTQ", "DTQ_TIPVIA"		, StrZero( 3, Len( DTQ->DTQ_TIPVIA )) ) //Planejada
	oModel:SetValue( "MdFieldDTQ", "DTQ_ROTA"		, AllTrim(cRota) )

	//---- DTR
	oModel:SetValue( "MdGridDTR", "DTR_ITEM"		,  StrZero( 1, Len( DTR->DTR_ITEM ) ))
	oModel:SetValue( "MdGridDTR", "DTR_CODVEI"		, cCodVei)		
	If !Empty( cCodRb1 )
		oModel:SetValue( "MdGridDTR", "DTR_CODRB1"	, cCodRb1)
	EndIf
	If !Empty( cCodRb2 )
		oModel:SetValue( "MdGridDTR", "DTR_CODRB2"	, cCodRb2)
	EndIf
	If !Empty( cCodRb3 )
		oModel:SetValue( "MdGridDTR", "DTR_CODRB3"	, cCodRb3)
	EndIf

	//--- DUP
	oModel:SetValue( "MdGridDUP", "DUP_CODMOT"		, cCodMot)
	oModel:SetValue( "MdGridDUP", "DUP_CONDUT"		, '1')

	If !oModel:VldData() .Or. !oModel:CommitData()
		AAdd(aMsgErr,{STR0047+oModel:GetErrorMessage()[6],'00','TMSAE75()'}) //"Falha ao Incluir Viagem - " 
		lRet:= .F.		
	Else
		cRet := oModel:GetValue( "MdFieldDTQ", "DTQ_VIAGEM")
	EndIf

	oModel:DeActivate()
	oModel:= Nil
		
	RestInter() 
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})
FwFreeArray(aAreas)
Return cRet

Function CGCCliAtiv(cCGCREM, cCGCDES, cCGCDEV, cCGCCON, cCGCDPC, cCGCEXP, cCGCREC, cIEREM, cIEDES, cIEDEV, IDESTR)

Local aArea     := GetArea()
Local aRet      := Array(7)
Local cQuery    := ""
Local lOR       := .F.
Local cAliasSA1 := GetNextAlias()

DEFAULT cCGCREM := ""
DEFAULT cCGCDES := ""
DEFAULT cCGCDEV := ""
DEFAULT cCGCCON := ""
DEFAULT cCGCDPC := ""
DEFAULT cCGCEXP := ""
DEFAULT cIEREM  := ""
DEFAULT cIEDES  := ""
DEFAULT cIEDEV  := ""
DEFAULT IDESTR  := ""

    AEval(aRet, {|x,y| aRet[y] := { "", "", "", "", "" } })

    If !Empty(cCGCREM+cCGCDES+cCGCDEV+cCGCCON+cCGCDPC+cCGCEXP+cCGCREC)

        cQuery := "SELECT A1_COD, A1_LOJA, A1_CGC, A1_CDRDES, A1_INSCR, A1_NREDUZ, A1_PFISICA, A1_TIPO " + CRLF
		cQuery += "FROM " + RetSQLName("SA1") + " SA1 " + CRLF
        cQuery += "WHERE " + CRLF
        If !Empty(cCGCREM)
            cQuery += "( A1_CGC = '" + cCGCREM + "' "
            lOR := .T.
        EndIf
        If !Empty(cCGCDES)
            cQuery += Iif(lOR,"OR ","( ")
            cQuery += "A1_CGC = '" + cCGCDES + "' "
            lOR := .T.
        EndIf
        If !Empty(cCGCDEV)
            cQuery += Iif(lOR,"OR ","( ")
            cQuery += "A1_CGC = '" + cCGCDEV + "' "
            lOR := .T.
        EndIf
        If !Empty(cCGCCON)
            cQuery += Iif(lOR,"OR ","( ")
            cQuery += "A1_CGC = '" + cCGCCON + "' "
            lOR := .T.
        EndIf
        If !Empty(cCGCDPC)
            cQuery += Iif(lOR,"OR ","( ")
            cQuery += "A1_CGC = '" + cCGCDPC + "' "
            lOR := .T.
        EndIf
        If !Empty(cCGCEXP)
            cQuery += Iif(lOR,"OR ","( ")
            cQuery += "A1_CGC = '" + cCGCEXP + "' "
        EndIf
        If !Empty(cCGCREC)
            cQuery += Iif(lOR,"OR ","( ")
            cQuery += "A1_CGC = '" + cCGCREC + "' "
        EndIf
        cQuery += " ) " + CRLF
        cQuery += " AND A1_FILIAL = '" + xFilial("SA1") + "' " + CRLF
		cQuery += " AND A1_CDRDES <> ' ' " + CRLF
		cQuery += " AND D_E_L_E_T_ = ' ' " + CRLF
        If SA1->(ColumnPos("A1_MSBLQL")) > 0
		    cQuery += " AND A1_MSBLQL <> '1' " + CRLF
        EndIf
	    cQuery += "ORDER BY A1_COD, A1_LOJA"

		cQuery := ChangeQuery( cQuery )
		DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasSA1, .F., .T. )		

        Do While !(cAliasSA1)->(Eof())

            If Empty(aRet[NPOSREM][NPOSCOD]) .And. cCGCREM == (cAliasSA1)->A1_CGC
                If Empty(cIEREM) .Or. AllTrim(cIEREM) == AllTrim((cAliasSA1)->A1_INSCR)
                    (cAliasSA1)->( aRet[NPOSREM] := {A1_COD, A1_LOJA, A1_CGC, A1_CDRDES, A1_NREDUZ} )
                EndIf
            EndIf
			If Empty(aRet[NPOSDES][NPOSCOD]) .And. cCGCDES == (cAliasSA1)->A1_CGC .And. AllTrim(IDESTR) == AllTrim((cAliasSA1)->A1_PFISICA)
				If Empty(cIEDES) .Or. AllTrim(cIEDES) == AllTrim((cAliasSA1)->A1_INSCR)
					(cAliasSA1)->( aRet[NPOSDES] := {A1_COD, A1_LOJA, A1_CGC, A1_CDRDES, A1_NREDUZ} )
				EndIf
			EndIf
			If Empty(aRet[NPOSDEV][NPOSCOD]) .And. cCGCDEV == (cAliasSA1)->A1_CGC
                If Empty(cIEDEV) .Or. AllTrim(cIEDEV) == AllTrim((cAliasSA1)->A1_INSCR)
                    (cAliasSA1)->( aRet[NPOSDEV] := {A1_COD, A1_LOJA, A1_CGC, A1_CDRDES, A1_NREDUZ} )
                EndIf
            EndIf
            If Empty(aRet[NPOSCON][NPOSCOD]) .And. cCGCCON == (cAliasSA1)->A1_CGC
                (cAliasSA1)->( aRet[NPOSCON] := {A1_COD, A1_LOJA, A1_CGC, A1_CDRDES, A1_NREDUZ} )
            EndIf
            If Empty(aRet[NPOSDPC][NPOSCOD]) .And. cCGCDPC == (cAliasSA1)->A1_CGC
                (cAliasSA1)->( aRet[NPOSDPC] := {A1_COD, A1_LOJA, A1_CGC, A1_CDRDES, A1_NREDUZ} )
            EndIf
            If Empty(aRet[NPOSEXP][NPOSCOD]) .And. cCGCEXP == (cAliasSA1)->A1_CGC
                (cAliasSA1)->( aRet[NPOSEXP] := {A1_COD, A1_LOJA, A1_CGC, A1_CDRDES, A1_NREDUZ} )
            EndIf
            If Empty(aRet[NPOSREC][NPOSCOD]) .And. cCGCREC == (cAliasSA1)->A1_CGC
                (cAliasSA1)->( aRet[NPOSREC] := {A1_COD, A1_LOJA, A1_CGC, A1_CDRDES, A1_NREDUZ} )
            EndIf
            (cAliasSA1)->(DbSkip())
        EndDo

        (cAliasSA1)->(DbCloseArea())
        RestArea(aArea)

    EndIf

Return aRet
