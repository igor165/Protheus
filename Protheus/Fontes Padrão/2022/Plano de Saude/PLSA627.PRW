#INCLUDE "PLSA627.CH"
#include "PROTHEUS.CH"
#include "PLSMGER2.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

#define K_Imprimir  K_Alterar
#define cCodigosPF  "104,116,117,123,124,125,127,134,137,138,139,140,141,142,143,144,145,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,182,183"
#define cCodigosRP	"186,188" // Referente ao reembolso patronal.

STATIC aEventosCb	:= {}
STATIC aAcertos		:= {}
STATIC aEveUsr		:= {}
STATIC oFrezFai		:= nil
STATIC nGravado   	:= 0
STATIC bSemFat		:= {|| PL627LDSMF() }
STATIC aCriFat		:= Pls627Cri()
STATIC lLimMaxTit   := .F.
STATIC lAbortPrint  := .F.
STATIC nMaxTitLid   := 0
STATIC nCodTimeOut	:= 90
STATIC ___lVld		:= .F.
STATIC aCabNiv1 	:= {}
STATIC aDadNiv1 	:= {}
STATIC oGetNiv1
STATIC oGetCri1
STATIC aCabNiv2 	:= {}
STATIC aDadNiv2 	:= {}
STATIC oGetNiv2
STATIC oGetCri2
STATIC aCabNiv3 	:= {}
STATIC aDadNiv3 	:= {}
STATIC oGetNiv3
STATIC oGetCri3
STATIC aCabNiv4 	:= {}
STATIC aDadNiv4 	:= {}
STATIC oGetNiv4
STATIC oGetCri4
STATIC aCabNiv5 	:= {}
STATIC aDadNiv5 	:= {}
STATIC oGetNiv5
STATIC oGetCri5
STATIC aCabNiv6 	:= {}
STATIC aDadNiv6 	:= {}
STATIC oGetNiv6
STATIC oGetCri6
STATIC aCabNiv7 	:= {}
STATIC aDadNiv7 	:= {}
STATIC oGetNiv7
STATIC oGetCri7
STATIC aCabRes  	:= {}
STATIC aDadRes  	:= {}
STATIC aCabSE1G 	:= {}
STATIC aDadSE1G 	:= {}
STATIC aCabBTV  	:= {}
STATIC aDadBTV  	:= {}
STATIC aCabBBT  	:= {}
STATIC oGetBTV
STATIC aCabCri1 	:= {}
STATIC aDadCri1 	:= {}
STATIC oGetCri1
STATIC aCabCri2 	:= {}
STATIC aDadCri2 	:= {}
STATIC aCabCri3 	:= {}
STATIC aDadCri3 	:= {}
STATIC aCabCri4 	:= {}
STATIC aDadCri4 	:= {}
STATIC aCabCri5 	:= {}
STATIC aDadCri5 	:= {}
STATIC aCabCri6 	:= {}
STATIC aDadCri6 	:= {}
STATIC aCodLan		:= {}
STATIC lFinImp 		:= FindFunction("FRaRtImp")      //Define se ha retencao de impostos PCC/IRPJ no R.A
STATIC lPl627Nat 	:= ExistBlock("PL627NAT")
STATIC lPl627Agl 	:= ExistBlock("PL627AGL")
STATIC lPlSvrNiv 	:= ExistBlock("PLSVRNIV", .F., .F., )
STATIC lPl627Vcb	:= ExistBlock("PL627VCB")
STATIC lPlPrefE1	:= ExistBlock("PLPREFE1")
STATIC lPlNumTit	:= ExistBlock("PLNUMTIT")
STATIC lPlPref2		:= ExistBlock("PLPREFE2")
STATIC lPlNumBco	:= ExistBlock("PLNUMBCO")
STATIC nMenu := 0
Static objCENFUNLGP := CENFUNLGP():New()
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

/*/{Protheus.doc} PLSA627
Geracao de Cobranca.

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLSA627()
	LOCAL cPrefixo  := ""
	LOCAL cFiltro	:= ""
	LOCAL lPeFil	:= .F.

	// Define o cabecalho da tela de atualizacoes

	PRIVATE aRotina  := {} //MenuDef()
	PRIVATE cCadastro:= PLSRetTit("BDC")

	nMenu:=1
	aRotina  := MenuDef()
	aCodLan := PL627LANTB()

	// Ajustes no dicionario...
	// Caso o indice 19 da tabea BEAJ nao tenha cido criada nao deixa o sistema
	// processeguir, alteracao requisita e aprovado pelo Tulio.

	If ! CheckBEAIndex("BEAJ")
		Return .F.
	EndIf


	// Diferente de brasil

	If cPaisLOC <> "BRA"
		cPrefixo := GetNewPar("MV_PLPFE11",'"PLS"')	// Lote de faturameto.
		cPrefixo := Eval({|| &cPrefixo })

		If Empty(A460Especie(cPrefixo))
			Help("",1,"PLSESPEC")
			return
		EndIf

		// Somente se o controle nao for pelo hardlock

		If SuperGetMV("MV_TPNRNFS") == '1'
			SX5->(DbSetOrder(1))
			If ! SX5->( dbSeek(xFilial("SX5")+"01"+cPrefixo) )
				Help("",1,"PLSTAB01")
				return
			EndIf
		EndIf
	EndIf

	// Endereca a funcao de BROWSE

	BDC->(DbSetOrder(1))
	BDC->(msSeek(xFilial("BDC")))

	If ExistBlock ("PL627FIL")
		lPeFil	:= .T.
		cFiltro := ExecBlock("PL627FIL",.F.,.F.)
	Endif

	BDC->(mBrowse(06,01,22,75,"BDC",,,,,,,,,,,,,,Iif(lPeFil,cFiltro,NIL)))



Return

/*/{Protheus.doc} PL627MOV
Movimentacao da geracao de cobranca Pessoa Fisica e Juridi

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PL627MOV(cAlias,nReg,nOpc,lDelDireto,lVerDiv,lNewRet,lAutomato)
	LOCAL nI		 := 0
	LOCAL I__f       := 0
	LOCAL nOpca	 	 := 0
	LOCAL i 		 := 0
	LOCAL _nH		 := 0
	LOCAL lRet		 := .T.
	LOCAL cLote		 := ""
	LOCAL aMatGC	 := {}
	LOCAL aButtons	 := {}
	LOCAL aCriticas  := {}
	LOCAL aStruBD6   := {}
	LOCAL aStruBD5   := {}
	LOCAL aStruBE4   := {}
	LOCAL aCamp		 := {}
	LOCAL oEnchoice	 := NIL
	LOCAL oDlg		 := NIL
	LOCAL bOk		 := {|| PLSA627OK(@oDlg, @nOpc, @nOpca,oEnchoice) }
	LOCAL bCancel	 := {|| oDlg:End() }
	LOCAL lExclu   := .F.
	LOCAL cFunNa	 :=FunName()

	DEFAULT lDelDireto := .F.
	DEFAULT lVerDiv    := .F.
	DEFAULT lNewRet    := .F.
	DEFAULT lAutomato  := .F.

	PRIVATE cPadrao:="P05"
	PRIVATE oFolder
	PRIVATE oBrwNiv
	PRIVATE aTELA   := {}
	PRIVATE aGETS   := {}
	PRIVATE lDadNiv  := {0,0,0,0,0,0,0,0,0}
	PRIVATE lDadCri  := {0,0,0,0,0,0,0,0,0}
	PRIVATE cCodDet  := {"","","","","","",""}
	PRIVATE cPrfBDF  := cNumBDF := cParBDF := cTipoBDF := cSeqBDF := ""
	PRIVATE cCodInt  := If(nOpc == K_Incluir, 	Space(Len(BDC->BDC_CODOPE)),BDC->BDC_CODOPE)
	PRIVATE nOpcX	 := nOpc
	PRIVATE oBrwBDW  := NIL
	PRIVATE aCabBDW  := {}
	PRIVATE aDadBDW  := {}
	PRIVATE aVetBDW  := {}
	PRIVATE nSeqFrz		:= 1

	//Variaveis de controle - Para utilização no codigo fonte GPPROCES.PRW
	PRIVATE nRecRCHAux	:= 0
	PRIVATE nTotCalFunc	:= 0
	PRIVATE nTotCalReg	:= 1
	PRIVATE lGrid	:= .F.
	PRIVATE nMinGrid := GetMvRH("MV_MINGRID",, 0)
	PRIVATE cProces		:= Space( TamSX3( "RCJ_CODIGO" )[1] )
	PRIVATE cRoteiro 	:= Space( TamSX3( "RY_CALCULO" )[1] )
	PRIVATE cPeriodo	:= Space( TamSX3( "RCH_PER" )[1] )
	PRIVATE cNumPag		:= Space( TamSX3( "RCH_NUMPAG" )[1] )
	PRIVATE cFilMat 	:= Space(99)	// Filtro de Matricula
	PRIVATE cFilDep 	:= Space(99)	// Filtro de Departamento
	PRIVATE cFilPosto 	:= Space(99)	// Filtro de Posto
	PRIVATE cFilCC		:= Space(99)	// Filtro de Centro de Custo
	PRIVATE cFilLocPag	:= Space(99)	// Filtro de Localidade de Pago
	PRIVATE cAtual		:= ""
	PRIVATE lHabGrab	:= .F.
	PRIVATE lHabTrace	:= .F.
	PRIVATE lVarios		:= .F.
	PRIVATE __aFormulas	:= {}
	PRIVATE aRotMark   	:= {}
	PRIVATE cAliasMark 	:= "TABAUX"
	PRIVATE cCadastro		:= OemToAnsi(STR0005) // "Processos de Cálculo"
	PRIVATE lAbortPrint 	:= .F.
	PRIVATE aFilter		:= {} // Array com os Filtros
	PRIVATE nStatus		:= 1
	PRIVATE cProcDesc	:= Space( TamSX3( "RCJ_DESCRI" )[1] )
	PRIVATE cRotDesc 	:= Space( TamSX3( "RY_DESC" )[1] )
	PRIVATE dDataIni	:= Ctod("//")
	PRIVATE dDataFim	:= Ctod("//")

	//Gera o filter
	fGeraFilter(@aFilter,xFilial(),xFilial(),xFilial(),xFilial(),xFilial())



	// Controle de linhas da matriz
	nMaxTitLid := GetNewPar("MV_PLSFTLL",1000)

	// Seta o tempo de espera para alocacao dos agentes TEMPO EM SEGUNDOS
	nCodTimeOut := GetNewPar("MV_PLSTICO",90)

	// Alimenta variavel estatica com os lancamentos de faturamento..

	SetEventos()
	SetEveAcu()
	SetEveUsr()
	SetFrzFai()

	//Estorno de pagamento ou Novo lote de cobrança
	if nOpc == K_Excluir .or. nOpc == K_Incluir

		if ! PLVLDBLQCO(dDataBase, { iIf( nOpc == K_Excluir, "PLS006", "PLS015" ) }, .t.)
			return .f.
		endIf

	endIf

	//Verifica integridade
	If nOpc == K_Visualizar .or. nOpc == K_Excluir
		BDD->( DbSetOrder(1) )//BDD_FILIAL + BDD_INTERC + BDD_CODOPE + BDD_NUMERO + BDD_NIVEL
		If !BDD->( MsSeek(xFilial("BDC")+BDC->(BDC_INTERC+BDC_CODOPE+BDC_NUMERO) ) )
			PLCABRES(BDC->BDC_CODOPE,BDC->BDC_NUMERO,Iif(BDC->BDC_INTERC=='1',.T.,.F.) )
		EndIf
	EndIf

	aCamp := {"BD6_STAFAT","BD6_OPEFAT","BD6_NUMFAT","BD6_PREFIX","BD6_NUMTIT","BD6_PARCEL","BD6_TIPTIT","BD6_INTFAT",;
		"BD5_STAFAT","BD5_OPEFAT","BD5_NUMFAT","BD5_PREFIX","BD5_NUMTIT","BD5_PARCEL","BD5_TIPTIT","BD5_INTFAT",;
		"BE4_STAFAT","BE4_OPEFAT","BE4_NUMFAT","BE4_PREFIX","BE4_NUMTIT","BE4_PARCEL","BE4_TIPTIT","BE4_INTFAT"}

	aStruBD6 := BD6->(DbStruct())
	aStruBD5 := BD5->(DbStruct())
	aStruBE4 := BE4->(DbStruct())

	For i := 1 To Len(aCamp)
		If aScan(aStruBD6,{|x| AllTrim(x[1]) == AllTrim(aCamp[i])}) == 0 .and. ;
				aScan(aStruBD5,{|x| AllTrim(x[1]) == AllTrim(aCamp[i])}) == 0 .and. ;
				aScan(aStruBE4,{|x| AllTrim(x[1]) == AllTrim(aCamp[i])}) == 0
			aadd(aCriticas,{"02",STR0040 + " [" +aCamp[i]+ "] " + STR0041})   //"Nao foi possivel localizar o campo"###"no dicionario de dados."
		EndIf
	Next

	If Len(aCriticas) > 0
		PLSCRIGEN(aCriticas,{ {STR0046,"@C",20},{STR0047,"@C",260} }, STR0048,NIL,NIL,NIL,NIL, NIL,NIL,"G",220) //"Codigo"###"Critica"###"Verificacao de integridade."
	EndIf


	// Monta botoes da enchoicebar...

	aadd(aButtons,{"FILTRO"   ,{|| (M->BDC_EXPFIF := BuildExpr("BA3",oDlg,M->BDC_EXPFIF), lRefresh := .T.) },STR0049,STR0050} ) //"Filtro Familias"###"Filtro"

	If nOpc <> K_Incluir .And. BDC->BDC_TIPO == "1"
		aadd(aButtons,{"PROJETPMS" ,{|| PLSCobGrp("","",4,BDC->BDC_CODOPE,BDC->BDC_CODOPE+BDC->BDC_NUMERO) },STR0051,STR0052} ) //"Detalhe da Cobranca"###"Detalhe"
	EndIf

	If (cFunNa == "PLSA627" .OR. cFunNa $ "PLSA094A/PLSA094B/PLSA094C") .AND. cFunNa<> NIL
		Cr627Cols(nOpc, BDC->(BDC_CODOPE+BDC_NUMERO), BDC->BDC_INTERC)
	Endif

	// Sub-Contratos para Calculo (Pessoa Juridica)

	If cFunNa == "PLSA627" .OR. cFunNa == "PLSA094C"
		dbSelectArea("BDW")
		Store Header "BDW" TO aCabBDW For .T.
		BDW->(DbSetOrder(1))

		If nOpc # K_Incluir .And. BDW->(msSeek(xFilial("BDW")+"0"+BDC->(BDC_CODOPE+BDC_NUMERO)))
			Store COLS "BDW" TO aDadBDW FROM aCabBDW VETTRAB aVetBDW While BDW->(BDW_FILIAL+BDW_TIPO+BDW_CODOPE+BDW_NUMERO) == xFilial("BDW")+"0"+BDC->(BDC_CODOPE+BDC_NUMERO)
		Else
			Store COLS Blank "BDW" TO aDadBDW FROM aCabBDW
		EndIf
	Else
		lRet := .F.
		Pl627Exc(BDC->BDC_CODOPE, BDC->BDC_NUMERO, "0")
		PLUPTENC("BDC",nOpc)
		PLSA625SE1( BDC->(BDC_CODOPE+BDC_NUMERO),,,,,,,.T.,lAutomato)
	Endif

	// Monta dados do cabecalho...

	If cFunNa == "PLSA627" .OR. cFunNa == "PLSA094C"
		If nOpc == K_Incluir
			Copy "BDC" TO Memory Blank
		Else
			Copy "BDC" TO MEMORY
		EndIf
	Else
		lRet := .F.
		Pl627Exc(BDC->BDC_CODOPE, BDC->BDC_NUMERO, "0")
		PLUPTENC("BDC",nOpc)
		PLSA625SE1( BDC->(BDC_CODOPE+BDC_NUMERO),,,,,,,.T.,lAutomato)
	Endif
	nGravado := 0

	If !lAutomato
		PLSCRIABFQ()
	EndIf

	// Redefine o conteudo padrao do numero do lote...

	If nOpc == K_Incluir
		M->BDC_NUMERO := "AUTO"
	EndIf

	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 200, .T., .T. } )
	AAdd( aObjects, { 200, 100, .T., .T.,.T. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	If (nOpc # K_Excluir .Or. (nOpc = K_Excluir .And. ! lDelDireto))
		If !lAutomato

			// Define Dialogo...

			DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

			// Monta Enchoice...

			Zero()
			oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.)
		EndIf

		// Define Folder....

		If nOpc <> K_Incluir .AND. !lAutomato
			@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4]+15 OF oDlg  PIXEL	PROMPTS	STR0053,STR0054,STR0055,STR0056,STR0057,STR0058,STR0059,STR0060,STR0061 //,"Comissao" //"Resumo da Cobranca"###"Niv. Empresa"###"Niv. Contrato"###"Niv. Sub-Contrato"###"Niv. Familia"###"Niv. Usuario"###"Niv. Opcional"###"Titulos Gerados"###"Titulos Cancelados"
			If M->BDC_CONGER >= nMaxTitLid .Or. M->BDC_CONCRI >= nMaxTitLid
				oFolder:bChange := { || a627VLot(oFolder:nOption,nOpc) }
			EndIf
		Else
			If !lAutomato
				@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4]+15 OF oDlg  PIXEL	PROMPTS	STR0062 //"Sub-Contratos"
			EndIf
		EndIf

		If !lAutomato
			Cr627FolCri(nOpc)
		EndIf

		// Monta Niveis...

		If nOpc == K_Incluir
			oBrwBDW := TPLSBrw():New(002,001,aPosObj[2][3],aPosObj[2][4],nil  ,oFolder:aDialogs[1],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBDW ,aDadBDW ,.F.      ,"BDW" ,nOpc,STR0063,nil,nil,nil,aVetBDW,"Pls625BDW") //"Sub-Contrato Calculo"
			oBrwBDW:oBrowse:oBrowse:bWhen := { || M->BDC_TIPO == "1" .and. Iif(BDC->(FieldPos("BDC_LOTREN"))>0,Empty(M->BDC_LOTREN),.T.) }
		EndIf
		If !lAutomato

			// Ativa o Dialogo...

			ACTIVATE MSDIALOG oDlg ON INIT ( oEnchoice:oBox:SetFocus(), Eval({||EnchoiceBar(oDlg, bOk, bCancel, .F., aButtons)}),;
				If(lVerDiv .And. nOpc == K_Visualizar,PLS627CHK(BDC->(Recno()),.F.),nil))
		EndIf
		If nOpc == K_Incluir
			aDadBDW := aClone(oBrwBDW:aCols)
		EndIf
	Else
		nOpca := If(nOpc = K_Excluir .And. lDelDireto, K_OK, 0)
	EndIf

	// Rotina de gravacao dos dados...

	If nOpca == K_OK

		If nOpc == K_Incluir

			// Monta a matriz de grupo de cobranca

			If Type('BDC_GRCOBV') <> 'U' .And. !Empty(M->BDC_GRCOBV)

				cAux := M->BDC_GRCOBV + ','

				While !Empty(cAux)
					AaDd(aMatGC,SubStr( cAux , 1 , At(',',cAux) - 1 ) )
					cAux := SubStr( cAux , At(',',cAux) + 1 , Len(cAux) )
				EndDo

			ElseIf !Empty(M->BDC_GRPCOB)
				AaDd(aMatGC,M->BDC_GRPCOB)
			Else
				AaDd(aMatGC,'')
			EndIf

			// Execucao isolada por grupo de cobranca ou segue normalmente
			For nI:=1 To Len(aMatGC)

				If !Empty(aMatGC[nI])
					M->BDC_GRPCOB := aMatGC[nI]
				EndIf

				// Abre semaforo...
				If Eval(bSemFat)
					Processa( {|| _nH := PL627SMF() }, STR0064 ) //"Controle de semaforo"
				EndIf

				// Aponta a hora de inicio do processamento...

				M->BDC_HORA	:= Time()

				// Processa apuracao e gravacao do faturamento...

				Proc2BarGauge( { || lRet := PLS627PROC(nOpc, _nH) },;
					STR0065+Iif(M->BDC_TIPO == "2", STR0066, STR0067)+Space(7)+M->BDC_HORA,;
					STR0068,STR0068,.T.) //"Gerando faturamento de "Pessoa Fisica"###"Pessoa Juridica"" Tabela: [" ####"Inicio: "###"Processando..."###"Processando..."

				// Confirma semafaro.

				If lRet
					BDC->( ConfirmSx8() )
				EndIf
			Next

			// Executa funcao para exibir resultado do lote...
			If lRet
				PL627MOV(cAlias,BDC->(Recno()),K_Visualizar,,.T.)
			EndIf

		ElseIf nOpc == K_Excluir

			// Ponto de Entrada para validar se o lote vai ou nao ser excluido

			If ExistBlock("PL627EXC")
				If !Execblock("PL627EXC",.F.,.F.)
					MsgAlert(STR0070)  //"Nao e possivel excluir o Lote!"
					Return .F.
				EndIf
			EndIf

			// Abre semaforo...

			If Eval(bSemFat)
				Processa( {|| _nH := PL627SMF() }, STR0064 ) //"Controle de Semaforo"
			EndIf

			SX5->( MsSeek( cFilial+"09FIN" ) )

			cLote := SubStr( SX5->(X5Descri() ),1,4)


			// Exclui titulos a receber...

			Proc2BarGauge( { || lExclu := PLSA625SE1( BDC->(BDC_CODOPE+BDC_NUMERO),Iif(Type('M->BDC_INTERC')<>'U',M->BDC_INTERC=='1',.F.),NIL,NIL,NIL,NIL,nil ) },;
				STR0268+BDC->BDC_NUMERO+" ]" + Space(3)+Time(),; //" Exclusão do lote de faturamento [ "
				STR0068,STR0068,.T.)
			If !lExclu .And. cFunNa == "PLSA627"  //Se a exclusao for chamada do Lote Cob. o lret ja vem .F. excluindo registros indevidamente
				lRet := .F.
			Endif


			// Grava cabecalho da geracao da cobranca...

			If lRet
				Pl627Exc(BDC->BDC_CODOPE, BDC->BDC_NUMERO, "0")
				If !(cFunNa $ "PLSA094A,PLSA001")
					PLUPTCOLS("BDW",aDadBDW,aCabBDW,aVetBDW,nOpc,;
						{ 	{ "BDW_NUMERO", M->BDC_NUMERO },;
						{"BDW_CODOPE", M->BDC_CODOPE}, {"BDW_TIPO","0"} },.T.)
				EndIf
				PLUPTENC("BDC",nOpc)
			EndIf
			If lExclu
				Pl627Exc(BDC->BDC_CODOPE, BDC->BDC_NUMERO, "0")
				If !(cFunNa $ "PLSA094A,PLSA001")
					PLUPTCOLS("BDW",aDadBDW,aCabBDW,aVetBDW,nOpc,;
						{ 	{ "BDW_NUMERO", BDC->BDC_NUMERO },;
						{"BDW_CODOPE", BDC->BDC_CODOPE}, {"BDW_TIPO","0"} },.T.)
				EndIf
				PLUPTENC("BDC",nOpc)
			EndIf

			// Fecha semaforo...

			If Eval(bSemFat)
				PLSFechaSem(_nH,"PLSA627.SMF")
			EndIf
		EndIf
	EndIf

	KilFrzFai()

Return IIf(lNewRet,lRet,nOpca == K_OK)

/*/{Protheus.doc} PLS627PROC
Apura o faturamento...

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLS627PROC(nOpc, _nH, lAutomato, lPessoaF,aItens,lSchedule)
	LOCAL jConta := 0
	LOCAL iConta := 0
	local lRet	 := .f.
	Default aItens := If( !lPessoaF, Array(1,15), )
	Default lSchedule := .F. // Esta vindo da chamada do schedule de lote cobrança

	If FindFunction("GetParAuto") .And. lAutomato

		aCodLan := PL627LANTB()

		aRetAuto := GetParAuto("PLSA627TestCase")
		M->BDC_ANOINI := aRetAuto[1]
		M->BDC_MESINI := aRetAuto[2]
		M->BDC_ANOFIM := aRetAuto[3]
		M->BDC_MESFIM := aRetAuto[4]
		M->BDC_EXPFIF := aRetAuto[5]
		M->BDC_CODOPE := aRetAuto[6]
		M->BDC_TIPO := aRetAuto[7]
		M->BDC_INTERC := aRetAuto[8]
		M->BDC_HORAF	:= Time()
		M->BDC_HORA	:= Time()
		M->BDC_GRPCOB	:= " "
		M->BDC_LOTREN := " "
		M->BDC_CONGER	:= 0
		M->BDC_CONCRI	:= 0
		M->BDC_VALOR	:= 100.00
		M->BDC_VENINI	:= 1
		M->BDC_VENFIM	:= 31
		M->BDC_VENCTO	:= 1
		M->BDC_MODPAG	:= aRetAuto[26] //"3"
		M->BDC_AGLUTI	:= "1"
		M->BDC_CARIMP	:= "1"
		M->BDC_DTEMIS := dDataBase
		M->BDC_FATGR	:= "0"
		M->BDC_REEMB	:= "2"
		M->BDC_DTPREE	:=	Stod(" ")
		M->BDC_CONSAD	:= " "
		M->BDC_USUOPE := PLSRtCdUsr()

		If BDC->(FieldPos('BDC_RATIMP')) > 0 .and. Len(aRetAuto) > 26
			M->BDC_RATIMP :=aRetAuto[27]
		Endif

		If ! lPessoaF

			aItens[1][1] := " "
			aItens[1][2] := " "
			aItens[1][3] := " "
			aItens[1][4] := " "
			aItens[1][5] := " "
			aItens[1][6] := " "
			aItens[1][7] := " "
			aItens[1][8] := " "
			aItens[1][9] := " "
			aItens[1][10] := " "
			aItens[1][11] := " "
			aItens[1][12] := " "
			aItens[1][13] := " "
			aItens[1][14] := " "
			aItens[1][15] := .F.

		EndIf

	EndIf

	// Atualiza campos bdc

	M->BDC_NUMERO := PLSA625Num()
	M->BDC_DATGER := dDataBase

	// Atualiza bdc

	PLUPTENC("BDC",nOpc)

	If lAutomato

		aAdd(aRetAuto, aRetAuto[6] + cValToChar(M->BDC_NUMERO) ) // BM1_PLNUCO

	EndIf

	nRegBDC := BDC->( Recno() )

	// Primeiro Verifico se o periodo esta correto

	If M->BDC_ANOINI+M->BDC_MESINI <= M->BDC_ANOFIM+M->BDC_MESFIM

		// Se o periodo estiver no mesmo ano

		If M->BDC_ANOINI == M->BDC_ANOFIM

			// O mes inicial tem que ser menor que o final

			If M->BDC_MESINI <= M->BDC_MESFIM

				For IConta := Val(M->BDC_MESINI) To Val(M->BDC_MESFIM)

					lRet := A627Itens(	M->BDC_NUMERO,;								// Nomero do lote
						M->BDC_ANOINI,;								// Ano inicial
						StrZero(IConta,2),;							// Mes atual
						M->BDC_EXPFIF,;								// Campo filtro.
						M->BDC_CODOPE,;								// Codigo da operadora
						Iif( lAutomato, Iif ( lPessoaF, M->BDC_EXPFIF, aItens ) , If(M->BDC_TIPO == "1" .And. !lSchedule , oBrwBDW:aCols,aItens) ), ;	// Matriz com filtro
						Iif(M->BDC_INTERC=='1',.T.,.F.),;			// Intercambio
						M->BDC_TIPO,;								// Tipo: Pessoa Fisica / Juridica
						nOpc,lAutomato,;							// nOpc = 2-Visualizar, 3-Inclusao, 4-Exclusao
						lSchedule)										// Esta vindo da rotina de Schedule de lote de cobrança

				Next
			EndIf

			// Se forem anos diferentes

		Elseif M->BDC_ANOINI < M->BDC_ANOFIM

			// Percorro todos os anos'

			For JConta := Val(M->BDC_ANOINI) to Val(M->BDC_ANOFIM)

				// Se o ano que esta sendo processado for menor que o ultimo

				If (JConta < Val(M->BDC_ANOFIM))

					// Se for o ano inicial entao comeco do mes inicial ate o mes 12

					If (JConta == Val(M->BDC_ANOINI))
						For IConta := Val(M->BDC_MESINI) To 12

							// Mensagem de processamento

							IncProcG2(STR0075 + Strzero(IConta,2) + STR0076 + StrZero(JConta,4)) //"Gerando Mes:"###" Ano:"
							ProcessMessage()

							lRet := A627Itens(	M->BDC_NUMERO,;						// Nomero do lote
								StrZero(JConta,4),;							// Ano inicial
								Strzero(IConta,2),;							// Mes atual
								M->BDC_EXPFIF,;								// Campo filtro.
								M->BDC_CODOPE,;								// Codigo da operadora
								If(M->BDC_TIPO = "1" .And. !lSchedule , oBrwBDW:aCols,aItens),;	// Matriz com filtro
								Iif(M->BDC_INTERC=='1',.T.,.F.),;			// Intercambio
								M->BDC_TIPO,,,lSchedule)								// Tipo: Pessoa Fisica / Juridica
						Next

						// Caso contrario percorro todos os meses do ano

					Else
						For IConta := 1  to 12

							// Mensagem de processamento

							IncProcG2(STR0075 + Strzero(IConta,2) + STR0076 + StrZero(JConta,4)) //"Gerando Mes:"###" Ano:"
							ProcessMessage()

							lRet := A627Itens(	M->BDC_NUMERO,;						// Nomero do lote
								StrZero(JConta,4),;							// Ano inicial
								Strzero(IConta,2),;							// Mes atual
								M->BDC_EXPFIF,;								// Campo filtro.
								M->BDC_CODOPE,;								// Codigo da operadora
								If(M->BDC_TIPO = "1" .And. !lSchedule , oBrwBDW:aCols,),;	// Matriz com filtro
								Iif(M->BDC_INTERC=='1',.T.,.F.),;			// Intercambio
								M->BDC_TIPO,,,lSchedule)								// Tipo: Pessoa Fisica / Juridica
						Next
					EndIf

					// Caso o ano que esta sendo processados seja o ultimo percorro do mes 1 ate o mes final

				Elseif (JConta == vAL(M->BDC_ANOFIM))

					For IConta:= 1 To Val(M->BDC_MESFIM)

						// Mensagem de processamento

						IncProcG2(STR0075 + Strzero(IConta,2) + STR0076 + StrZero(JConta,4)) //"Gerando Mes:"###" Ano:"
						ProcessMessage()

						lRet := A627Itens(M->BDC_NUMERO,;						// Nomero do lote
							StrZero(JConta,4),;							// Ano inicial
							Strzero(IConta,2),;							// Mes atual
							M->BDC_EXPFIF,;								// Campo filtro.
							M->BDC_CODOPE,;								// Codigo da operadora
							If(M->BDC_TIPO = "1" .And. !lSchedule , oBrwBDW:aCols,),;	// Matriz com filtro
							Iif(M->BDC_INTERC=='1',.T.,.F.),;			// Intercambio
							M->BDC_TIPO,,,lSchedule)								// Tipo: Pessoa Fisica / Juridica
					Next
				EndIf
			Next
		EndIf

		// Ponto de entrada no filna da rotina...

		If ExistBlock("PL627FIM")
			ExecBlock("PL627FIM",.F.,.F.)

			// LOG

			PLSLOGFAT("PL627FIM",1,.F.)
		EndIf
	EndIf

	// Grava hora final do processamento do lote...

	BDC->( dbGoto(nRegBDC) )

	BDC->( Reclock("BDC", .F.) )
	BDC->BDC_HORAF := Time()
	BDC->( MsUnlock() )

	BDC->( dbCommitall() )

	// Fecha semaforo...

	If Eval(bSemFat)
		PLSFechaSem(_nH,"PLSA627.SMF")
	EndIf

Return(lRet)

/*/{Protheus.doc} A627Itens
Grava itens do bordero de cobranca.

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function A627Itens(	cNumCob,cAno,cMes,cFilBA3,cOperadora, aItens, lInterC, cTipo, nOpc, lAutomato,lSchedule)

	LOCAL nY		  := 0
	LOCAL nI 		  := 0
	LOCAL nItens      := 0
	LOCAL nTotLNF	  := 0
	LOCAL nTotTit	  := 0
	LOCAL nValor	  := 0
	LOCAL nGauge1	  := 0
	LOCAL nGauge2	  := 0
	LOCAL nBDW_CODEMP := Iif( lAutomato, Val(aRetAuto[9]),  If(!lSchedule,oBrwBDW:PLRETPOS("BDW_CODEMP"),2))
	LOCAL nBDW_CONEMP := Iif( lAutomato, Val(aRetAuto[10]), If(!lSchedule,oBrwBDW:PLRETPOS("BDW_CONEMP"),4))
	LOCAL nBDW_VERCON := Iif( lAutomato, Val(aRetAuto[11]), If(!lSchedule,oBrwBDW:PLRETPOS("BDW_VERCON"),5))
	LOCAL nBDW_SUBCON := Iif( lAutomato, Val(aRetAuto[12]), If(!lSchedule,oBrwBDW:PLRETPOS("BDW_SUBCON"),6))
	LOCAL nBDW_VERSUB := Iif( lAutomato, Val(aRetAuto[13]), If(!lSchedule,oBrwBDW:PLRETPOS("BDW_VERSUB"),7))
	LOCAL nBDWCODEMF  := Iif( lAutomato, Val(aRetAuto[14]), If(!lSchedule,oBrwBDW:PLRETPOS("BDW_CODEMF"),8))
	LOCAL nBDWCONEMF  := Iif( lAutomato, Val(aRetAuto[15]), If(!lSchedule,oBrwBDW:PLRETPOS("BDW_CONEMF"),10))
	LOCAL nBDWVERCOF  := Iif( lAutomato, Val(aRetAuto[16]), If(!lSchedule,oBrwBDW:PLRETPOS("BDW_VERCOF"),11))
	LOCAL nBDWSUBCOF  := Iif( lAutomato, Val(aRetAuto[17]), If(!lSchedule,oBrwBDW:PLRETPOS("BDW_SUBCOF"),12))
	LOCAL nBDWVERSUF  := Iif( lAutomato, Val(aRetAuto[18]), If(!lSchedule,oBrwBDW:PLRETPOS("BDW_VERSUF"),13))
	LOCAL cSql		  := ""
	LOCAL cCodInt	  := ""
	LOCAL cCodEmp 	  := ""
	LOCAL cConEmp 	  := ""
	LOCAL cVerCon 	  := ""
	LOCAL cSubCon 	  := ""
	LOCAL cVerSub 	  := ""
	LOCAL cMatric 	  := ""
	LOCAL cTipReg	  := ""
	LOCAL cInterc	  := "0"
	LOCAL cCodPro 	  := ""
	LOCAL cVerPro 	  := ""
	LOCAL cDirFile	  := ""
	LOCAL lFisica	  := (M->BDC_TIPO == '2' .or. empty(M->BDC_TIPO))
	LOCAL lRegs		  := .F.
	LOCAL lGerSE1	  := .T.
	LOCAL bEmissao	  := {|| Iif( BDC->( FieldPos('BDC_DTEMIS') ) > 0 .and. GetNewPar("MV_PLSNFBR","0")=="0", M->BDC_DTEMIS, dDataBase ) }
	LOCAL aRet 		  := {}
	LOCAL aCobAbr	  := {}
	LOCAL aCliente    := {}
	LOCAL aVet1		  := {}
	LOCAL aVet2		  := {}
	LOCAL aVlrCob	  := {}
	LOCAL aVlrAcu	  := {}
	LOCAL aRetAux	  := {}
	LOCAL cCliente	  := ""
	LOCAL cLoja		  := ""
	LOCAL aDataVenc   := {} // Callback var.
	LOCAL dVenc 	  := ctod("")	// vencimento
	LOCAL dVencCO 	  := ctod("")   // vencimento do custo operacional.
	LOCAL cNivel	  := ""
	LOCAL nParFin	  := 0
	LOCAL nL		  := 0
	LOCAL nM		  := 0
	LOCAL nN		  := 0
	LOCAL lPLS627QR   := ExistBlock("PLS627QR")
	LOCAL lPLS627OG   := ExistBlock("PLS627OG")
	LOCAL lRatImpost  := IIF( BDC->(FieldPos('BDC_RATIMP')) > 0, M->BDC_RATIMP == "1", .F.)
	LOCAL aRatTotal	  := {}
	LOCAL cFormPagto  := ""

	DEFAULT lInterC   := .F.
	DEFAULT aItens	  := { {} }
	DEFAULT lSchedule := .F.

	If FindFunction("GetParAuto") .And. lAutomato

		M->BDC_LOTREN := aRetAuto[19]
		M->BDC_CARIMP := aRetAuto[20]
		M->BDC_VENINI := Val(aRetAuto[21])
		M->BDC_VENFIM := Val(aRetAuto[22])
		M->BDC_GRPCOB := aRetAuto[23]
		M->BDC_VENCTO := Val(aRetAuto[24])
		M->BDC_AGLUTI := aRetAuto[25]
		M->BDC_MODPAG := aRetAuto[26]

	EndIf


	// lFisica - 1. Elemento
	If lFisica
		aItens := { {} }
	EndIf

	// aItens - for geral do faturamento

	BA1->( DbSetOrder(1) )
	BA3->( DbSetOrder(1) )

	For nItens := 1 To Len(aItens)

		// Aborta

		If lAbortPrint

			Exit
		EndIf

		// Item deletado

		If ! lFisica .And. aItens[nItens][Len(aItens[nItens])]
			Loop
		EndIf

		If !lAutomato .and. !lSchedule


			// Obtem o tamanho da regua...

			nGauge1 := PL169GAUGE(1, aItens, nItens, M->BDC_TIPO, M->BDC_EXPFIF)
			nGauge2 := PL169GAUGE(2, aItens, nItens, M->BDC_TIPO, M->BDC_EXPFIF)

			// Monta tamanho da regua numero 1

			BarGauge1Set(nGauge1)

			// Monta tamanho da regua numero 2

			BarGauge2Set(nGauge2)

		EndIf

		// Inicia a montar a query principal para selecionar as familias...

		cSql := "SELECT BA3_CODINT, BA3_TIPOUS, BA3_CODCLI, BA3_LOJA, "
		cSql += "BA3_COBNIV, BA3_VENCTO, BA3_CODFOR, BA3_LOJFOR, BA3_CODEMP, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, "
		cSql += "BA3_VERSUB, BA3_MATRIC, BA3_CODPLA, BA3_VERSAO, BA3_NATURE, BA3_DATBLO, "
		If BA3->( FieldPos("BA3_CONDPA") ) > 0
			cSql += "BA3_CONDPA, "
		EndIf
		If BA3->(Fieldpos("BA3_TIPPAG")) > 0 .AND. BA3->( Fieldpos("BA3_PORTAD") ) > 0 .and.;
				BA3->(Fieldpos("BA3_AGEDEP")) > 0 .AND. BA3->( Fieldpos("BA3_CTACOR") ) > 0 .and.;
				BA3->(Fieldpos("BA3_BCOCLI")) > 0 .AND. BA3->( Fieldpos("BA3_AGECLI") ) > 0 .and.;
				BA3->(Fieldpos("BA3_CTACLI")) > 0

			cSql += "BA3_TIPPAG, BA3_PORTAD, BA3_AGEDEP, BA3_CTACOR, BA3_BCOCLI, BA3_AGECLI, BA3_CTACLI, "
		EndIf

		cSql += "BG9_LOJA, BG9_VENCTO, BG9_CODFOR, BG9_LOJFOR, BG9_NATURE, BG9_TIPO  ,BG9_CODCLI, "
		If BG9->( FieldPos("BG9_CONDPA") ) > 0
			cSql += "BG9_CONDPA, "
		EndIf
		If BG9->(Fieldpos("BG9_TIPPAG")) > 0 .AND. BG9->( Fieldpos("BG9_PORTAD") ) > 0 .and.;
				BG9->(Fieldpos("BG9_AGEDEP")) > 0 .AND. BG9->( Fieldpos("BG9_CTACOR") ) > 0 .and.;
				BG9->(Fieldpos("BG9_BCOCLI")) > 0 .AND. BG9->( Fieldpos("BG9_AGECLI") ) > 0 .and.;
				BG9->(Fieldpos("BG9_CTACLI")) > 0

			cSql += "BG9_TIPPAG, BG9_PORTAD, BG9_AGEDEP, BG9_CTACOR, BG9_BCOCLI, BG9_AGECLI, BG9_CTACLI, "
		EndIf

		cSql += RetSqlName("BG9")+".R_E_C_N_O_ BG9REC,  "+RetSqlName("BA3")+".R_E_C_N_O_ BA3REC  "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// Campo utilizados quando eh pessoa juridica... no bdc 1=juridica no ba3 1=fisica
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTipo == '1'
			cSql += ",BT5_INTERC, BT5_TIPOIN, BT5_COBNIV, BT5_CODCLI, BT5_LOJA  , BT5_VENCTO, "
			cSql += "BT5_CODFOR , BT5_LOJFOR, BQC_COBNIV, BQC_CODCLI, BQC_LOJA  , BT5_NATURE, "
			cSql += "BQC_VENCTO , BQC_CODFOR, BQC_LOJFOR, BQC_GRATUI, BT6_CODPRO, BQC_NATURE, BT6_VERSAO, "

			If BT5->( FieldPos("BT5_CONDPA") ) > 0
				cSql += "BT5_CONDPA, "
			EndIf
			If BQC->( FieldPos("BQC_CONDPA") ) > 0
				cSql += "BQC_CONDPA, "
			EndIf
			If BT5->(Fieldpos("BT5_TIPPAG")) > 0 .AND. BT5->( Fieldpos("BT5_PORTAD") ) > 0 .and.;
					BT5->(Fieldpos("BT5_AGEDEP")) > 0 .AND. BT5->( Fieldpos("BT5_CTACOR") ) > 0 .and.;
					BT5->(Fieldpos("BT5_BCOCLI")) > 0 .AND. BT5->( Fieldpos("BT5_AGECLI") ) > 0 .and.;
					BT5->(Fieldpos("BT5_CTACLI")) > 0

				cSql += "BT5_TIPPAG, BT5_PORTAD, BT5_AGEDEP, BT5_CTACOR, BT5_BCOCLI, BT5_AGECLI, BT5_CTACLI, "
			EndIf

			If BQC->(Fieldpos("BQC_TIPPAG")) > 0 .AND.  BQC->( Fieldpos("BQC_PORTAD") ) > 0 .and.;
					BQC->(Fieldpos("BQC_AGEDEP")) > 0 .AND. BQC->( Fieldpos("BQC_CTACOR") ) > 0 .and.;
					BQC->(Fieldpos("BQC_BCOCLI")) > 0 .AND. BQC->( Fieldpos("BQC_AGECLI") ) > 0 .and.;
					BQC->(Fieldpos("BQC_CTACLI")) > 0

				cSql += "BQC_TIPPAG, BQC_PORTAD, BQC_AGEDEP, BQC_CTACOR, BQC_BCOCLI, BQC_AGECLI, BQC_CTACLI, "
			EndIf
			If BQC->( FieldPos("BQC_TPVCPP") ) > 0
				cSql += "BQC_TPVCPP, "
			EndIf
			If BQC->( FieldPos("BQC_VENCCO") ) > 0
				cSql += "BQC_VENCCO, "
			EndIf
			If BQC->( FieldPos("BQC_TPVCCO") ) > 0
				cSql += "BQC_TPVCCO, "
			EndIf

			cSql += RetSqlName("BT5")+".R_E_C_N_O_ BT5REC ,"
			cSql += RetSqlName("BQC")+".R_E_C_N_O_ BQCREC ,"
			cSql += RetSqlName("BT6")+".R_E_C_N_O_ BT6REC  "
		EndIf

		// Tabelas de uso geral... pessoa fisica/juridica

		cSql += "FROM "+RetSqlName("BA3")+", "+RetSqlName("BG9")+" "

		// Tabelas de uso exclusivo para pessoa juridica...

		If cTipo == '1'
			cSql += ", "+RetSqlName("BT5")+", "+RetSqlName("BQC")+", "+RetSqlName("BT6")+" "
		EndIf

		// Inicializa montagem do filtro...

		cSql += "WHERE BA3_FILIAL = '" + xFilial("BA3") + "' "
		cSql += "AND BG9_FILIAL = '" + xFilial("BG9") + "' "

		If cTipo == '1'
			cSql += "AND BT5_FILIAL = '" + xFilial("BT5") + "' "
			cSql += "AND BQC_FILIAL = '" + xFilial("BQC") + "' "
			cSql += "AND BT6_FILIAL = '" + xFilial("BT6") + "' "
		EndIf

		cSql += "AND BA3_CODINT = BG9_CODINT "
		cSql += "AND BA3_CODEMP = BG9_CODIGO "

		// Filtro para pessoa juridica...

		If cTipo = '1'
			cSql += "AND BA3_CODINT = BT5_CODINT "
			cSql += "AND BA3_CODEMP = BT5_CODIGO "
			cSql += "AND BA3_CONEMP = BT5_NUMCON "
			cSql += "AND BA3_VERCON = BT5_VERSAO "

			cSql += "AND BA3_CODINT || BA3_CODEMP = BQC_CODIGO  "
			cSql += "AND BA3_CONEMP = BQC_NUMCON "
			cSql += "AND BA3_VERCON = BQC_VERCON "
			cSql += "AND BA3_SUBCON = BQC_SUBCON "
			cSql += "AND BA3_VERSUB = BQC_VERSUB "

			cSql += "AND BA3_CODINT = BT6_CODINT "
			cSql += "AND BA3_CODEMP = BT6_CODIGO "
			cSql += "AND BA3_CONEMP = BT6_NUMCON "
			cSql += "AND BA3_VERCON = BT6_VERCON "
			cSql += "AND BA3_SUBCON = BT6_SUBCON "
			cSql += "AND BA3_VERSUB = BT6_VERSUB "
			cSql += "AND BA3_CODPLA = BT6_CODPRO "
			cSql += "AND BA3_VERSAO = BT6_VERSAO "
			cSql += "AND "+RetSqlName("BT6")+".D_E_L_E_T_ = ' ' "
			cSql += "AND "+RetSqlName("BT5")+".D_E_L_E_T_ = ' ' "
			cSql += "AND "+RetSqlName("BQC")+".D_E_L_E_T_ = ' ' "
		EndIf

		// Trata lote de renovacao...

		If BDC->( FieldPos("BDC_LOTREN") ) > 0
			If !Empty(M->BDC_LOTREN)
				cSql += "AND EXISTS (SELECT * FROM "+RetSqlName("BED")+" "
				cSql += " WHERE BED_FILIAL = '"+xFilial("BED")+"' "
				cSql += "AND BA3_CODINT = BED_CODINT "
				cSql += "AND BA3_CODEMP = BED_CODEMP "
				cSql += "AND BA3_MATRIC = BED_MATRIC "
				cSql += "AND BED_CDIDEN = '"+M->BDC_LOTREN+"' "
				cSql += "AND "+RetSqlName("BED")+".D_E_L_E_T_ = ' ' )"
			EndIf
		EndIf

		// Uso geral

		cSql += "AND "+RetSqlName("BA3")+".D_E_L_E_T_ = ' ' "
		cSql += "AND "+RetSqlName("BG9")+".D_E_L_E_T_ = ' ' "

		// Filtro para pessoa juridica... monta filtro informado na getdados...

		If cTipo == '1'  .and. Iif(BDC->( FieldPos("BDC_LOTREN") ) > 0,Empty(M->BDC_LOTREN),.T.)

			// Se for informado empresa...

			If ! Empty(aItens[nItens][nBDWCODEMF])
				cSql += "AND BA3_CODEMP >= '" + aItens[nItens][nBDW_CODEMP] + "' AND BA3_CODEMP <= '" + aItens[nItens][nBDWCODEMF] + "' "

			Elseif ! Empty(aItens[nItens][nBDW_CODEMP])
				cSql += "AND BA3_CODEMP = '" + aItens[nItens][nBDW_CODEMP] + "' "

			EndIf

			// Se for informado contrato...

			If ! Empty(aItens[nItens][nBDWCONEMF] + aItens[nItens][nBDWVERCOF])
				cSql += "AND (BA3_CONEMP >= '" + aItens[nItens][nBDW_CONEMP] + "' AND BA3_VERCON >= '" + aItens[nItens][nBDW_VERCON] + "') AND " +;
					"(BA3_CONEMP <= '" + aItens[nItens][nBDWCONEMF] + "' AND BA3_VERCON <= '" + aItens[nItens][nBDWVERCOF] + "') "

			ElseIf ! Empty(aItens[nItens][nBDW_CONEMP] + aItens[nItens][nBDW_VERCON])
				cSql += "AND BA3_CONEMP = '" + aItens[nItens][nBDW_CONEMP] + "' AND BA3_VERCON = '" + aItens[nItens][nBDW_VERCON] + "' "
			EndIf

			// Se for informado sub contrato...

			If ! Empty(aItens[nItens][nBDWSUBCOF] + aItens[nItens][nBDWVERSUF])
				cSql += "AND (BA3_SUBCON >= '" + aItens[nItens][nBDW_SUBCON] + "' AND BA3_VERSUB >= '" + aItens[nItens][nBDW_VERSUB] + "') AND " +;
					"(BA3_SUBCON <= '" + aItens[nItens][nBDWSUBCOF] + "' AND BA3_VERSUB <= '" + aItens[nItens][nBDWVERSUF] + "') "

			ElseIf ! Empty(aItens[nItens][nBDW_SUBCON] + aItens[nItens][nBDW_VERSUB])
				cSql += "AND BA3_SUBCON = '" + aItens[nItens][nBDW_SUBCON] + "' AND BA3_VERSUB = '" + aItens[nItens][nBDW_VERSUB] + "' "
			EndIf

			// Somente pessoa juridica...

			cSql += "AND BA3_TIPOUS = '2' "
			cSql += "AND BA3_CODINT = '"+M->BDC_CODOPE+"' "

			// Filtra por grupo de cobranca...

			If !Empty(M->BDC_GRPCOB)
				cSql += "AND BA3_GRPCOB = '" + M->BDC_GRPCOB + "' "
			EndIf

			If ! Empty(cFilBA3)
				cSql += " AND (" + PlsParSql(cFilBA3) + ") "
			EndIf

		ElseIf cTipo == '2' .And. Iif(BDC->( FieldPos("BDC_LOTREN") ) > 0, Empty(M->BDC_LOTREN), .T.)

			// Filtra exclusivo para pessoa fisica...

			If ! Empty(cFilBA3)
				cSql += " AND (" + PlsParSql(cFilBA3) + ") "
			EndIf

			cSql += "AND BA3_VENCTO >= " + AllTrim(Str(M->BDC_VENINI)) + " AND "
			cSql += "BA3_VENCTO <= " + AllTrim(Str(M->BDC_VENFIM)) + " AND "
			cSql += "BA3_TIPOUS = '1' "

			If  BDC->(FieldPos("BDC_CARIMP")) > 0
				If  ! Empty(M->BDC_CARIMP)
					cSql += " AND BA3_CARIMP = '" + M->BDC_CARIMP + "' "
				EndIf
			EndIf

			// Filtra por grupo de cobranca...

			If !Empty(M->BDC_GRPCOB)
				cSql += "AND BA3_GRPCOB = '"+M->BDC_GRPCOB+"' "
			EndIf
		EndIf

		// Ordena o resultado da query...

		If cTipo == '1'
			cSql += "ORDER BY BA3_FILIAL, BA3_CODINT, BA3_CODEMP, BA3_CONEMP, "
			cSql += "BA3_VERCON, BA3_SUBCON, BA3_VERSUB,BT6_CODPRO,BA3_MATRIC"
		Else
			cSql += "ORDER BY BA3_FILIAL,BA3_CODINT,BA3_CODEMP,BA3_MATRIC"
		EndIf

		// PE para tratamento da query principal
		If lPLS627QR
			cSql := ExecBlock("PLS627QR",.F.,.F.,{cSql})
			PLSLOGFAT("PLS627QR",1,.F.)
		EndIf


		// Faz o parce para oracle...

		cSql := StrTran(cSql,"DTOS(", "(" )
		cSql := StrTran(cSql,"DTOC(", "(" )
		cSql := StrTran(cSql,"CTOD(", "(" )

		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"SELEFAM",.F.,.T.)

		aStruct := SELEFAM->( DbStruct() )


		// While Principal

		While !SELEFAM->( Eof() )

			// Aborta
			If lAbortPrint

				Exit

			EndIf

			If !lAutomato .and. !lSchedule
				// Mensagem de processamento

				IncProcG1( Iif(!Empty(M->BDC_GRPCOB), STR0281 + M->BDC_GRPCOB + " - ","") + STR0080 + SELEFAM->BA3_CODEMP+' - '+ PadR(Posicione("BG9",1,xFilial("BG9")+SELEFAM->(BA3_CODINT+BA3_CODEMP),"BG9_DESCRI"),60),.T.,,.F.) //"Faturando Empresa: "
				ProcessMessage()

			EndIf

			lRegs 	:= .T.
			cCodInt := SELEFAM->BA3_CODINT
			cCodEmp := SELEFAM->BA3_CODEMP
			nCont 	:= 0




			// LOG

			PLSLOGFAT("VALOR DA FAMILIA",0,,"EMPRESA",SELEFAM->BA3_CODEMP)

			// While Empresa Processa familias...
			While !SELEFAM->( Eof() ) .And. SELEFAM->BA3_CODINT == cCodInt .And. SELEFAM->BA3_CODEMP == cCodemp

				// Aborta
				If lAbortPrint
					PLSGRILOG('5020 - ABORT Manual',STR0228)
					Exit
				EndIf

				BQC->(MsSeek(xFilial("BQC")+SELEFAM->BA3_CODINT+SELEFAM->BA3_CODEMP+SELEFAM->BA3_CONEMP+SELEFAM->BA3_VERCON+SELEFAM->BA3_SUBCON+SELEFAM->BA3_VERSUB))
				BT5->(MsSeek(xFilial("BT5")+SELEFAM->BA3_CODINT+SELEFAM->BA3_CODEMP+SELEFAM->BA3_CONEMP+SELEFAM->BA3_VERCON))
				BG9->(MsSeek(xFilial("BG9")+SELEFAM->BA3_CODINT+SELEFAM->BA3_CODEMP))

				// Pessoa Juridica
				If cTipo == '1'

					// Posiciona o BT5...

					cInterc := Iif(Empty(SELEFAM->BT5_INTERC),'0',SELEFAM->BT5_INTERC)

					// Ou e intercambio ou nao... de acordo com a opcao definida no lote

					If cInterc <> M->BDC_INTERC
						SELEFAM->( dbSkip() )
						Loop
					EndIf

					// Liga variavel para indicar se eh intercambio ou nao...

					lInterc := (SELEFAM->BT5_INTERC=='1')

					// Atualiza variaveis...

					cConEmp := SELEFAM->BA3_CONEMP
					cVerCon := SELEFAM->BA3_VERCON
					cSubCon := SELEFAM->BA3_SUBCON
					cVerSub := SELEFAM->BA3_VERSUB
					cCodPro := SELEFAM->BT6_CODPRO
					cVerPro := SELEFAM->BT6_VERSAO
					cMatric := SELEFAM->BA3_MATRIC


					// While no mesmo produto para evitar pocisionamentos redundantes      |

					While !SELEFAM->( Eof() ) .And. cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodPro+cVerPro ==;
							SELEFAM->(	BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO )

						If ! lAutomato .and. !lSchedule

							// Mensagem de processamento

							IncProcG2(STR0090 + " - " + SELEFAM->(BA3_CODINT+"."+BA3_CODEMP+"."+BA3_MATRIC),.T.,,.F.) //"Calculando Familia"
						EndIf



						//Nome do arquivo mais diretorio

						cDirFile := ""

						//Matriz de parametros para processamento Grid ou nao

						aVet1 := {}
						aVet1 := {	0,;						//01
							SELEFAM->BA3_CODINT,;	//02
							SELEFAM->BA3_CODEMP,;	//03
							SELEFAM->BA3_MATRIC,;	//04
							cAno,;					//05
							cMes,;					//06
							cConEmp,;				//07
							cVerCon,;				//08
							cSubCon,;				//09
							cVerSub,;				//10
							cCodPro,;				//11
							cVerPro,;				//12
							SELEFAM->BA3_TIPOUS,;  //13
							SELEFAM->BA3REC,;		//14
							SELEFAM->BG9REC,;		//15
							SELEFAM->BT5REC,;		//16
							SELEFAM->BQCREC,;		//17
							SELEFAM->BT6REC,;		//18
							cNumCob,;				//19
							lInterC,;				//20
							cTipReg,;				//21
							cDirFile}               //22

						BA3->(MsSeek(xFilial("BA3")+SELEFAM->BA3_CODINT+SELEFAM->BA3_CODEMP+SELEFAM->BA3_MATRIC+SELEFAM->BA3_CONEMP+SELEFAM->BA3_VERCON+SELEFAM->BA3_SUBCON+SELEFAM->BA3_VERSUB))


						aCliente := PLS770NIV(SELEFAM->BA3_CODINT,SELEFAM->BA3_CODEMP,;
							SELEFAM->BA3_MATRIC,If(SELEFAM->BA3_TIPOUS=="1","F","J"),;
							SELEFAM->BA3_CONEMP,SELEFAM->BA3_VERCON,SELEFAM->BA3_SUBCON,;
							SELEFAM->BA3_VERSUB,1)



						aUsuarios := PLSLOADUSR(cCodInt,cCodEmp,SELEFAM->BA3_MATRIC,cAno,cMes,,)


						//Calcula valor de cobrança

						aRetAux := CalcFatGri(aVet1,.F., aUsuarios,aCliente, M->BDC_MODPAG)

						// Monta a aCobAbr
						If Len(aRetAux) > 0
							PLSACOBRG( aRetAux ,@aCobAbr,@aCliente )
						EndIf

						// Proximo

						SELEFAM->( dbSkip() )

						//Fim While Pessoa Juridica

					EndDo

					//Pessoa Fisica

				Else

					If !lAutomato .and. !lSchedule


						// Mensagem de processamento

						IncProcG2(STR0090 + " - " + SELEFAM->(BA3_CODINT+"."+BA3_CODEMP+"."+BA3_MATRIC),.T.,,.F.) //"Calculando Familia"

					EndIf


					//Nome do arquivo mais diretorio

					cDirFile := ""



					//Matriz de parametros para processamento Grid ou nao

					aVet1 := {}
					aVet1 := {	0,;						//01
						SELEFAM->BA3_CODINT,;	//02
						SELEFAM->BA3_CODEMP,;	//03
						SELEFAM->BA3_MATRIC,;	//04
						cAno,;					//05
						cMes,;					//06
						cConEmp,;				//07
						cVerCon,;				//08
						cSubCon,;				//09
						cVerSub,;				//10
						cCodPro,;				//11
						cVerPro,;				//12
						SELEFAM->BA3_TIPOUS,;	//13
						SELEFAM->BA3REC,;		//14
						SELEFAM->BG9REC,;		//15
						0,;						//16
						0,;						//17
						0,;						//18
						cNumCob,;				//19
						lInterC,;				//20
						cTipReg,;				//21
						cDirFile}               //22


					BA3->(MsSeek(xFilial("BA3")+SELEFAM->BA3_CODINT+SELEFAM->BA3_CODEMP+SELEFAM->BA3_MATRIC+SELEFAM->BA3_CONEMP+SELEFAM->BA3_VERCON+SELEFAM->BA3_SUBCON+SELEFAM->BA3_VERSUB))


					aCliente := PLS770NIV(SELEFAM->BA3_CODINT,SELEFAM->BA3_CODEMP,;
						SELEFAM->BA3_MATRIC,If(SELEFAM->BA3_TIPOUS=="1","F","J"),;
						SELEFAM->BA3_CONEMP,SELEFAM->BA3_VERCON,SELEFAM->BA3_SUBCON,;
						SELEFAM->BA3_VERSUB,1)



					aUsuarios := PLSLOADUSR(cCodInt,cCodEmp,SELEFAM->BA3_MATRIC,cAno,cMes,,)


					//Calcula valor de cobrança
					aRetAux := CalcFatGri(aVet1,.F.,aUsuarios,aCliente, M->BDC_MODPAG)

					// Monta a aCobAbr
					If Len(aRetAux) > 0
						PLSACOBRG( aRetAux ,@aCobAbr,@aCliente )
					EndIf

					// Proximo

					SELEFAM->( dbSkip() )
				EndIf

				// Fim do While Empresa

			EndDo

			// LOG
			PLSLOGFAT("VALOR DA FAMILIA",1)

			// Gera titulos baseados na matriz aCobAbr
			// Ponto de entrada para ordernar sequencia de geração dos titulos

			If lPLS627OG
				aRetPto := ExecBlock("PLS627OG",.F.,.F.,{aCobAbr})
				aCobAbr := aRetPto[1]
				aRetPto := {}

				// LOG
				PLSLOGFAT("PLS627OG",1,.F.)
			EndIf


			//Gerando Titulos

			nTotAbr := Len(aCobAbr)

			If !lAutomato .and. !lSchedule
				BarGauge1Set( nTotAbr )
			EndIf

			For nI := 1 to nTotAbr

				If !lAutomato .and. !lSchedule
					IncProcG1( Strzero(nI,6) + STR0269 + Alltrim(StrZero(nTotAbr,6)) + " => " + STR0280 + AllTrim(aCobAbr[nI,4,1])+" - "+AllTrim(aCobAbr[nI,4,3]) ,.T.,,.F.) //"Cliente.: "
				EndIf

				// Vai tratar a aCobAbr[6] e retornar a matriz pronta  quantidade de titulos
				aRet := PLSPRETIT(aCobAbr[nI],.F.,M->BDC_AGLUTI,M->BDC_MODPAG,cAno,cMes)

				If ValType(aRet[4]) == "L"

					//Patronal diferenciado (Acordo ANS CApesesp)
					If aRet[4]

						For nL:= 1 to Len(aRet[1])
							nPos101:=1
							nPos188:=2
							If aRet[1,nL,1,3]="101"
								nPos101:=nL
							ElseIf aRet[1,nL,1,3]="186"
								nPos188:=nL
							Endif
						Next

						For nL:= 1 to Len(aRet[1])
							If nPos101 = nL
								For nM:= 1 to Len(aRet[1,nL])
									If aRet[1,nL,nM,1]="1"
										For nN:=1 to Len(aRet[1,nPos188])
											If aRet[1,nPos188,nN,1]="1"  .and. 	aRet[1,nPos188,nN,7]= aRet[1,nL,nM,7]  .and. aRet[1,nL,nM,3] $ ("101,108")
												aRet[1,nL,nM,2]:= IIf (aRet[1,nPos101,nN,2] - aRet[1,nPos188,nN,23] <= 0 ,0,aRet[1,nPos101,nN,2] - aRet[1,nPos188,nN,23])
												aRet[1,nL,nM,23]:= aRet[1,nPos188,nN,2]
											Else
												If aRet[1,nPos188,nN,1]<>"1"
													aRet[1,nL,nM,23]:=0
													aRet[1,nL,nM,2] :=0
												Endif
											Endif
										Next nN
									Else
										If aRet[1,nL,nM,3] $ "186,187,188"
											aRet[1,nL,nM,23]:=0
											aRet[1,nL,nM,2] :=0
										Endif
									Endif
								Next
							Endif
						Next

						For nL:= 1 to Len(aRet[1])
							If nPos188 = nL
								For nM:= 1 to Len(aRet[1,nL])
									If aRet[1,nL,nM,1]<>"1"
										aRet[1,nL,nM,2]:=0
										aRet[1,nL,nM,23]:= 0
									Else
										aRet[1,nL,nM,2]:=aRet[1,nL,nM,23]
									Endif
								Next
							Endif
						Next

					Endif
				Endif

				aVlrCob  := aClone(aRet[1])
				aVlrAcu  := aClone(aRet[2])
				nParFin	 := aRet[3]
				nTotTit	 := Len(aVlrCob)
				aRet 	 := {}

				If !lAutomato .and. !lSchedule
					BarGauge2Set( nTotTit )
				EndIf

				//Processo de geracao de titulo
				For nY:=1 To nTotTit

					If !lAutomato .and. !lSchedule

						If lGerSE1
							IncProcG2(STR0243 + Strzero(nY,5) + STR0269 + Alltrim(StrZero(nTotTit,5)),.T.,,.F.) //"Gerando titulo "###". Aguarde ..."
						Else
							IncProcG2(STR0243 + Strzero(nY,5) + STR0269 + Alltrim(StrZero(nTotTit,5)),.T.,,.F.) //"Gerando desconto "###". Aguarde ..."
						EndIf

					EndIf

					//Total de linhas da nota
					nTotLNF  := Len(aVlrCob[nY])
					cDirFile := ""

					//Matriz de parametros para processamento
					cCliente := ""
					cLoja := ""
					cChaveNiv := ""
					cFormPagto := ""
					dVenc := ""
					dVencCO := ""
					cNivel := ""
					
					// Se tiver um subNivel de cobranca vou utilizar ele para gerar o titulo.
					If Len(aCobAbr[nI,4]) > 33 .and. Len(aCobAbr[nI,4,34]) > 0 .and. Len(aCobAbr[nI,4,34,1]) > 0

						// Cliente do sub nivel. Cobranca patrocinada
						If Len(aVlrCob[nY][1]) >= 66 .and. aVlrCob[nY][1][66] == "3"

							cCliente := aCobAbr[nI,4,34,1,1]
							cLoja := aCobAbr[nI,4,34,1,2]
							cChaveNiv := aCobAbr[nI,7,3] // Chave do nivel de cobranca do subcontrato.
							cFormPagto := aCobAbr[nI,4,34,1,21]

							// Calcula o vencimento baseado no sub nivel de cobranca.
							aDataVenc := PLS627VENC(aCobAbr[nI,4,34],cAno,cMes)

							dVenc := aDataVenc[1] // Vencimento pre-pagamento.
							dVencCO := aDataVenc[2] // Vencimento custo Operacional.
							cNivel := aCobAbr[nI,4,34,1,18]	// Nivel de cobranca.

						Endif
					Endif

					// Se não for cobranca patrocinada, realiza a cobranca convencional ou auto patrocinada.
					If Empty(cCliente) .and. Empty(cLoja) .And. Val(aCobAbr[nI,9]) != 0
						cCliente 	:= aCobAbr[nI,1]
						cLoja 		:= aCobAbr[nI,2]					// Cliente do sub nivel. Cobranca convencional ou auto patrocinada
						cChaveNiv	:= aCobAbr[nI,7,Val(aCobAbr[nI,9])]	// Chave do nivel de cobranca.

						dVencCO 	:= aCobAbr[nI,20]					// Vencimento custo Operacional.
						dVenc 		:= aCobAbr[nI,5]                	// Vencimento pre-pagamento.
						cNivel 		:= aCobAbr[nI,9]					// Nivel de cobranca.

					Elseif Empty(dVenc) .and. Empty(dVencCO)
						dVencCO 	:= aCobAbr[nI,20]					// Vencimento custo Operacional.
						dVenc  		:= aCobAbr[nI,5]                	// Vencimento pre-pagamento.

					Elseif Empty(dVenc)
						dVenc 		:= aCobAbr[nI,20]					// Vencimento custo Operacional.

					Elseif Empty(dVencCO)
						dVencCO 	:= aCobAbr[nI,5]                	// Vencimento pre-pagamento.
					Endif

					If Empty(cFormPagto)
						cFormPagto := aCobAbr[nI,13]
					EndIf

					// Detalhes dos itens.
					aVet2 := {}
					aVet2 := {	1,;								 	//01 - Esta posicao e para dizer o que vai ser feito na unifatgrid
						cChaveNiv,;							//02 - Chave do nivel de cobranca
						aVlrCob[nY],;						//03 - Array contendo a composicao da cobranca.
						aVlrAcu,;							//04 - Array contendo a composicao da cobranca por acumulados.
						dVencCO,;							//05 - Vencimento Custo Ope.
						dVenc,;				   				//06 - Vencimento
						cMes,;								//07 - Mes
						cAno,;								//08 - Ano
						M->BDC_VENCTO,;						//09 - Vencimento backup
						cNumCob,;							//10 - Numero da cobranca
						Eval(bEmissao),;					//11 - Data de Emissao
						M->BDC_AGLUTI,;						//12
						M->BDC_CODOPE,;						//13
						cCliente,;							//14 Cliente.
						cLoja,;								//15 Loja.
						aCobAbr[nI,4,15],;					//16
						cNivel,;					   		//17 Nivel de cobranca
						aClone(aCobAbr[nI,7]),;				//18
						aCobAbr[nI,10],;					//19
						aCobAbr[nI,11],;					//20
						aCobAbr[nI,12],;					//21
						cFormPagto,;						//22
						aCobAbr[nI,14],;					//23
						aCobAbr[nI,15],;					//24
						aCobAbr[nI,16],;					//25
						aCobAbr[nI,17],;					//26
						aCobAbr[nI,18],;					//27
						aCobAbr[nI,19],;					//28
						aCobAbr[nI,22],;					//29
						BDC->(Recno()),;					//30
						lInterc,;							//31
						cDirFile,;							//32
						nTotLNF,;							//33
						If(nY<=nParFin,1,2),;				//34
						lRatImpost}							//35

					//Processamento em grid

					If nTotLNF > 0
						PLSGERTIT(aVet2)
					EndIf
					aVlrAcu := {}
				Next
			Next

			If !lAutomato .and. !lSchedule

				ProcessMessage()
			EndIf



			// LOG

			PLSLOGFAT("TITULOS",1)

			// Zera matriz

			aCobAbr := {}

			// Fim do While Principal

		EndDo
		SELEFAM->( DbCloseArea() )
		DbSelectArea("BA1")
	Next


	// LOG

	PLSLOGFAT("PROCESSO FINAL",0)

	If !lAutomato .and. !lSchedule


		// Complemento do cabecalho da cobranca

		PLCABRES(M->BDC_CODOPE,cNumCob,lInterC,.T.)

	EndIf

	// LOG

	PLSLOGFAT("PROCESSO FINAL",1)
	// Regnois

	If ! lRegs
		Help("",1,"REGNOIS")
		Return(.F.)
	EndIf



Return(.T.)

/*/{Protheus.doc} PLS627NIV
Esta funcao ira tratar o nivel de cobranca do usuario
Parametros cCodInt - Codigo da Instituicao
           cCodEmp - Codigo da Empresa
           cMat    - Matricula do Usuarios
           cTipCon - F = Fisica, J = Juridica
           cNumCon - Numero do Contrato
           cVerCon - Versao do Contrato
           cSubCon - Sub Contrato
           cVerSub - Versao do Sub-Contrato

Retorno    aRet[01] - Codigo do Cliente
           aRet[02] - Loja do Cliente
           aRet[03] - Nome do Cliente
           aRet[04] - Endereco
           aRet[05] - Municipio
           aRet[06] - Estado
           aRet[07] - Natureza
           aRet[08] - Bairro
           aRet[09] - Estado
           aRet[10] - CEP
           aRet[11] - Telefone
           aRet[12] - CGC
           aRet[13] - Inscricao Estadual
           aRet[14] - Tipo da Cobranca (2 - Aberta,1 - Fechada)
           aRet[15] - Tipo da Empresa  (1 - Fisica,2 - Juridica)
           aRet[16] - Dia do Vencimento
           aRet[17] - Tipo (1 - Cliente, 2 - Fornecedor)
           aRet[18] - Nivel(6/Operadora(Intercambio)5Usuario/4Familia
                            /3SubCon/2Contr/1Empresa)
           aRet[19] - Tipo de pagamento
           aRet[20] - Portador
           aRet[21] - Agencia do portador
           aRet[22] - Conta do portador
           aRet[23] - Banco   cliente
           aRet[24] - Agencia cliente
           aRet[25] - Conta cliente
@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLS627NIV(cCodInt,cCodEmp,cMat,cTipCon,cNumCon,cVerCon,cSubCon,cVerSub,_nTipFam,lHelp,cAlias,aRecnos)

	Local aCliFor := {{"ZZZZZZ",; 	//1
		"ZZ",; 		//2
		"",;        //3
		"",;        //4
		"",;        //5
		"",;        //6
		"",;        //7
		"",;        //8
		"",;        //9
		"",;		//10
		"",;   		//11
		"",;        //12
		"",;        //13
		"",;        //14
		"",;        //15
		0,;        //16
		"",;        //17
		"",;        //18
		"",;        //19
		"",;        //20
		'',;        //21
		'',;        //22
		'',;        //23
		'',;        //24
		'',;        //25
		'',;        //26
		'',;        //27
		"",;        //28
		0,;        //29
		"",;        //30
		"",;        //31
		"",;		//32
		"",;  //33
		{}}}		//34


	// Sava a area de trabalho...

	LOCAL aArea 	:= GetArea()

	LOCAL aAreaBA3		:= BA3->(GetArea())
	LOCAL aAreaBG9		:= BG9->(GetArea())
	LOCAL aAreaBT5		:= BT5->(GetArea())
	LOCAL aAreaBQC		:= BQC->(GetArea())
	LOCAL aAreaBT6		:= BT6->(GetArea())

	LOCAL cMdFatPt	:= ""
	LOCAL aSubNiv	:= {}


	// Define se e uma cobranca que vai ate o nivel de usuario...

	DEFAULT lHelp   := .T.

	If lPlSvrNiv
		aCliFor[1] := ExecBlock("PLSVRNIV", .F., .F., { cCodInt,cCodEmp,cNumCon,cVerCon,cSubCon,cVerSub,cMat})

		// LOG

		PLSLOGFAT("PLSVRNIV",1,.F.)

		If ValType(aCliFor[1]) = "A"
			Return aCliFor
		EndIf
	EndIf

	// Obtem o modo de cobrança da parcela patronal.
	If BQC->( FieldPos("BQC_CODPAT") ) > 0 .and. BQC->( FieldPos("BQC_MDFTPT") ) > 0 .and. !BQC->( Eof() ) .and. cTipCon $ "J,2"
		// Primeiro olha no produto do sub contrato.
		If !BT6->( Eof() ) .and. BT6->( FieldPos("BT6_CODPAT") ) > 0 .and. BT6->( FieldPos("BT6_MDFTPT") ) > 0
			If !Empty(BT6->BT6_CODPAT) .and. !Empty(BT6->BT6_MDFTPT)
				cMdFatPt := BT6->BT6_MDFTPT
			Endif
		Endif

		// Se nao tiver no produto do subcontrato, busca no proprio subcontrato.
		If Empty(cMdFatPt)
			If !Empty(BQC->BQC_CODPAT) .and. !Empty(BQC->BQC_MDFTPT)
				cMdFatPt := BQC->BQC_MDFTPT
			Endif
		Endif
	Endif


	// Faz as Verificacoes de Niveis de acordo com o tipo de contrato...

	If cTipCon $ "F,1"

		// Caso a cobranca esteja no nivel da Familia...

		If BA3->BA3_COBNIV == "1"  .And. (!Empty(BA3->BA3_CODCLI) .OR. !Empty(BA3->BA3_CODFOR)) // Familia
			If !Empty(BA3->BA3_CODCLI)

				aCliFor := PLSAPGEND(BA3->BA3_CODCLI,;
					BA3->BA3_LOJA,;
					"2",;
					BG9->BG9_TIPO,;
					BA3->BA3_VENCTO,;
					"4",;
					NIL,;
					Iif(BA3->(FieldPos("BA3_CONDPA"))>0,BA3->BA3_CONDPA,''),;
					'0',;
					0,;
					'0',nil,nil,nil,nil,nil,nil,nil,nil,cMdFatPt)

			EndIf

			aCliFor[1][7] := A627BusNat(BA3->BA3_TIPOUS,BA3->BA3_NATURE,(aCliFor[1][1]+aCliFor[1][2]),(BA3->BA3_CODINT+BA3->BA3_CODPLA+BA3->BA3_VERSAO),;
				"4",cMdFatPt)

			If BA3->(Fieldpos("BA3_TIPPAG")) > 0
				aCliFor[1][21] := BA3->BA3_TIPPAG
				aCliFor[1][22] := BA3->BA3_PORTAD
				aCliFor[1][23] := BA3->BA3_AGEDEP
				aCliFor[1][24] := BA3->BA3_CTACOR
				aCliFor[1][25] := BA3->BA3_BCOCLI
				aCliFor[1][26] := BA3->BA3_AGECLI
				aCliFor[1][27] := BA3->BA3_CTACLI
			EndIf
		Else
			Return(aCliFor)
		EndIf
	Else

		// Caso a cobranca esteja no nivel da Familia...

		If BA3->BA3_COBNIV == "1"  .And. (!Empty(BA3->BA3_CODCLI) .Or. !Empty(BA3->BA3_CODFOR)) // Familia

			if !Empty(BA3->BA3_CODCLI)

				aCliFor := PLSAPGEND(BA3->BA3_CODCLI,;
					BA3->BA3_LOJA,;
					"1",;
					BG9->BG9_TIPO,;
					BA3->BA3_VENCTO,;
					"4",;
					BQC->BQC_GRATUI,;
					Iif(BA3->(FieldPos("BA3_CONDPA"))>0,BA3->BA3_CONDPA,''),;
					'0',;
					0,;
					'0',nil,nil,nil,nil,nil,nil,nil,nil,cMdFatPt)

				// Cria um nivel de cobranca alternativo para cobrar a parcela patronal do subcontrato.
				// Pode-se dizer que isto eh um subnivel de cobranca.
				If cMdFatPt $ "1,3" // 1=Empresa; 3=Compartilihada. Essas duas modalidades geram titulo para a empresa.
					If !BQC->( Eof() )
						aSubNiv := PLSAPGEND(BQC->BQC_CODCLI,;
							BQC->BQC_LOJA,;
							'',;
							BG9->BG9_TIPO,;
							BQC->BQC_VENCTO,;
							"3",;
							BQC->BQC_GRATUI,;
							Iif(BQC->(FieldPos("BQC_CONDPA"))>0,BQC->BQC_CONDPA,''),;
							Iif(BQC->(FieldPos("BQC_TPVCPP"))>0,BQC->BQC_TPVCPP,''),;
							Iif(BQC->(FieldPos("BQC_VENCCO"))>0,BQC->BQC_VENCCO,0),;
							Iif(BQC->(FieldPos("BQC_TPVCCO"))>0,BQC->BQC_TPVCCO,''),;
							nil,nil,nil,nil,nil,nil,nil,nil,cMdFatPt)

						// Adiciona o sub nivel de cobranca dentro da matriz de nivel de cobranca.
						If Len(aCliFor[1]) > 33
							aSubNiv[1][21] := BQC->BQC_TIPPAG

							aCliFor[1][34] := aClone(aSubNiv)
						Endif
					Endif
				Endif
			EndIf

			aCliFor[1][7] := A627BusNat(BG9->BG9_TIPO,BA3->BA3_NATURE,(aCliFor[1][1]+aCliFor[1][2]),(BA3->BA3_CODINT+BA3->BA3_CODPLA+BA3->BA3_VERSAO),;
				"4",cMdFatPt)

			If BA3->(Fieldpos("BA3_TIPPAG")) > 0
				aCliFor[1][21] := BA3->BA3_TIPPAG
				aCliFor[1][22] := BA3->BA3_PORTAD
				aCliFor[1][23] := BA3->BA3_AGEDEP
				aCliFor[1][24] := BA3->BA3_CTACOR
				aCliFor[1][25] := BA3->BA3_BCOCLI
				aCliFor[1][26] := BA3->BA3_AGECLI
				aCliFor[1][27] := BA3->BA3_CTACLI
			EndIf


			// Caso a cobranca esteja no nivel do sub contrato..

		ElseIf BQC->BQC_COBNIV == "1"  .And. (!Empty(BQC->BQC_CODCLI) .OR. !Empty(BQC->BQC_CODFOR)) //Sub-Conbtrato

			If !Empty(BQC->BQC_CODCLI)
				aCliFor := PLSAPGEND(BQC->BQC_CODCLI,;
					BQC->BQC_LOJA,;
					'',;
					BG9->BG9_TIPO,;
					BQC->BQC_VENCTO,;
					"3",;
					BQC->BQC_GRATUI,;
					Iif(BQC->(FieldPos("BQC_CONDPA"))>0,BQC->BQC_CONDPA,''),;
					Iif(BQC->(FieldPos("BQC_TPVCPP"))>0,BQC->BQC_TPVCPP,''),;
					Iif(BQC->(FieldPos("BQC_VENCCO"))>0,BQC->BQC_VENCCO,0),;
					Iif(BQC->(FieldPos("BQC_TPVCCO"))>0,BQC->BQC_TPVCCO,''),;
					nil,nil,nil,nil,nil,nil,nil,nil,cMdFatPt)

			EndIf

			aCliFor[1][7] := A627BusNat(BG9->BG9_TIPO,BQC->BQC_NATURE,(aCliFor[1][1]+aCliFor[1][2]),(BA3->BA3_CODINT+BA3->BA3_CODPLA+BA3->BA3_VERSAO),;
				"3",cMdFatPt)

			If BQC->(Fieldpos("BQC_TIPPAG")) > 0
				aCliFor[1][21] := BQC->BQC_TIPPAG
				aCliFor[1][22] := BQC->BQC_PORTAD
				aCliFor[1][23] := BQC->BQC_AGEDEP
				aCliFor[1][24] := BQC->BQC_CTACOR
				aCliFor[1][25] := BQC->BQC_BCOCLI
				aCliFor[1][26] := BQC->BQC_AGECLI
				aCliFor[1][27] := BQC->BQC_CTACLI
			EndIf

			// Caso a cobranca esteja no nivel do contrato..

		Elseif BT5->BT5_COBNIV == "1" .And. (!Empty(BT5->BT5_CODCLI) .Or. !Empty(BT5->BT5_CODFOR)) //Contrato

			If !Empty(BT5->BT5_CODCLI)

				aCliFor := PLSAPGEND(BT5->BT5_CODCLI,;
					BT5->BT5_LOJA,;
					'',;
					BG9->BG9_TIPO,;
					BT5->BT5_VENCTO,;
					"2",;
					BQC->BQC_GRATUI,;
					Iif(BT5->(FieldPos("BT5_CONDPA"))>0,BT5->BT5_CONDPA,''),;
					'0',;
					0,;
					'0',nil,nil,nil,nil,nil,nil,nil,nil,cMdFatPt)

			EndIf

			aCliFor[1][7] := A627BusNat(BG9->BG9_TIPO,BT5->BT5_NATURE,(aCliFor[1][1]+aCliFor[1][2]),(BA3->BA3_CODINT+BA3->BA3_CODPLA+BA3->BA3_VERSAO),;
				"2",cMdFatPt)

			If BT5->(Fieldpos("BT5_TIPPAG")) > 0
				aCliFor[1][21] := BT5->BT5_TIPPAG
				aCliFor[1][22] := BT5->BT5_PORTAD
				aCliFor[1][23] := BT5->BT5_AGEDEP
				aCliFor[1][24] := BT5->BT5_CTACOR
				aCliFor[1][25] := BT5->BT5_BCOCLI
				aCliFor[1][26] := BT5->BT5_AGECLI
				aCliFor[1][27] := BT5->BT5_CTACLI
			EndIf

			// Caso a cobranca esteja no nivel de empresa...

		ElseIf ( !Empty(BG9->BG9_CODCLI) .Or. !Empty(BG9->BG9_CODFOR) )   //Empresa

			If !Empty(BG9->BG9_CODCLI)

				aCliFor := PLSAPGEND(BG9->BG9_CODCLI,;
					BG9->BG9_LOJA,;
					'',;
					BG9->BG9_TIPO,;
					BG9->BG9_VENCTO,;
					"1",;
					BQC->BQC_GRATUI,;
					Iif(BG9->(FieldPos("BG9_CONDPA"))>0,BG9->BG9_CONDPA,''),;
					'0',;
					0,;
					'0',nil,nil,nil,nil,nil,nil,nil,nil,cMdFatPt)

			EndIf

			aCliFor[1][7] := A627BusNat(BG9->BG9_TIPO,BG9->BG9_NATURE,(aCliFor[1][1]+aCliFor[1][2]),(BA3->BA3_CODINT+BA3->BA3_CODPLA+BA3->BA3_VERSAO),;
				"1",cMdFatPt)

			If BG9->(Fieldpos("BG9_TIPPAG")) > 0
				aCliFor[1][21] := BG9->BG9_TIPPAG
				aCliFor[1][22] := BG9->BG9_PORTAD
				aCliFor[1][23] := BG9->BG9_AGEDEP
				aCliFor[1][24] := BG9->BG9_CTACOR
				aCliFor[1][25] := BG9->BG9_BCOCLI
				aCliFor[1][26] := BG9->BG9_AGECLI
				aCliFor[1][27] := BG9->BG9_CTACLI
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
	RestArea(aAreaBA3)
	RestArea(aAreaBG9)
	RestArea(aAreaBT5)
	RestArea(aAreaBQC)




Return(aCliFor)

/*/{Protheus.doc} Pl627Exc
Exclui itens relacionados a cobranca

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function Pl627Exc(cCodOpe, cNumero, cInterC, lAutomato)
	LOCAL cSql

	// Exclui resumo...

	cSql := "SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("BDD") + " "
	cSql += "WHERE BDD_FILIAL = '" + xFilial("BDD") + "' AND "
	cSql += "BDD_INTERC = '" + cInterC + "' AND BDD_CODOPE = '" + cCodOpe + "' AND "
	cSql += "BDD_NUMERO = '" + cNumero + "' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"SELEBDD",.F.,.T.)

	While ! Eof()
		BDD->(DbGoTo(SELEBDD->RECNO))
		BDD->(RecLock("BDD",.F.))
		BDD->(DbDelete())
		BDD->(MsUnLock())
		DbSelectArea("SELEBDD")
		DbSkip()
	Enddo

	SELEBDD->( dbClosearea() )

	// Exclui Detalhes...

	cSql := "SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("BDF") + " "
	cSql += "WHERE BDF_FILIAL = '" + xFilial("BDF") + "' AND "
	cSql += "BDF_INTERC = '" + cInterC + "' AND BDF_CODOPE = '" + cCodOpe + "' AND "
	cSql += "BDF_NUMERO = '" + cNumero + "' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"SELEBDF",.F.,.T.)

	While ! Eof()
		BDF->(DbGoTo(SELEBDF->RECNO))
		BDF->(RecLock("BDF",.F.))
		BDF->(DbDelete())
		BDF->(MsUnLock())
		DbSelectArea("SELEBDF")
		DbSkip()
	Enddo
	SELEBDF->( dbClosearea() )

	// Exclui Criticas...

	If !lAutomato
		cSql := "SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("BDG") + " "
		cSql += "WHERE BDG_FILIAL = '" + xFilial("BDG") + "' AND "
		cSql += "BDG_INTERC = '" + cInterC + "' AND BDG_CODOPE = '" + cCodOpe + "' AND "
		cSql += "BDG_NUMERO = '" + cNumero + "' AND D_E_L_E_T_ = ' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"SELEBDG",.F.,.T.)
	EndIf

	While ! Eof()
		BDG->(DbGoTo(SELEBDG->RECNO))
		BDG->(RecLock("BDG",.F.))
		BDG->(DbDelete())
		BDG->(MsUnLock())
		DbSelectArea("SELEBDG")
		DbSkip()
	Enddo
	SELEBDG->( DbCloseArea() )

Return

/*/{Protheus.doc} Cr627Cols
Monta Acols utilizados para os lotes de cobranca

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function Cr627Cols(nOpc, cChave, cInterC)
	LOCAL nCols := 0
	LOCAL nLido := 0
	LOCAL nN1BDF_TIPO := nN1BDF_PREFIX := nN1BDF_NUMTIT := nN1BDF_PARCEL := nN1BDF_TIPTIT := 0
	LOCAL nN2BDF_TIPO := nN2BDF_PREFIX := nN2BDF_NUMTIT := nN2BDF_PARCEL := nN2BDF_TIPTIT := 0
	LOCAL nN3BDF_TIPO := nN3BDF_PREFIX := nN3BDF_NUMTIT := nN3BDF_PARCEL := nN3BDF_TIPTIT := 0
	LOCAL nN4BDF_TIPO := nN4BDF_PREFIX := nN4BDF_NUMTIT := nN4BDF_PARCEL := nN4BDF_TIPTIT := 0
	LOCAL nCntFor     := 0
	LOCAL nX 		  := 0
	LOCAL cQuery      := ""
	LOCAL cAlias      := ""
	LOCAL aStruBDF	  := BDF->(DbStruct())
	LOCAL aStruBDD	  := BDD->(DbStruct())
	LOCAL aStruBDG	  := BDG->(DbStruct())
	LOCAL aStruBTV	  := BTV->(DbStruct())
	LOCAL nMaxTitLid := GetNewPar("MV_PLSFTLL",1000)

	DEFAULT cInterC   := "0"

	If BDC->BDC_CONGER >= nMaxTitLid .Or. BDC->BDC_CONCRI >= nMaxTitLid
		lLimMaxTit := .T.
	Else
		lLimMaxTit := .F.
	EndIf

	// Apresento a mensagem

	aDadRes  := {}; aDadBTV  := {}; aDadSE1G := {}
	aDadNiv1 := {}; aDadNiv2 := {}; aDadNiv3 := {}; aDadNiv4 := {}; aDadNiv5 := {}; aDadNiv6 := {}
	aDadCri1 := {}; aDadCri2 := {}; aDadCri3 := {}; aDadCri4 := {}; aDadCri5 := {}; aDadCri6 := {}

	// No caso diferente de inclusao mostro o resumo da geracao...


	If nOpc <> K_Incluir

		If Len( aCabRes ) == 0
			Store Header "BDD" TO aCabRes For .T.
		EndIf

		P627TrtFol("BDD",cInterC,cChave,aStruBDD,aCabRes,aDadRes,nil,.F.,nil)

		// No caso diferente de inclusao mostro detalhes do Nivel 1...

		If Len( aCabNiv1 ) == 0
			Store Header "BDF" TO aCabNiv1 For ! SX3->X3_CAMPO $ "BDF_NUMCON,BDF_VERCON,BDF_SUBCON,BDF_VERSUB,BDF_MATRIC,BDF_TIPREG,BDF_SEQSE3"
		EndIf

		P627TrtFol("BDF",cInterC,cChave,aStruBDF,aCabNiv1,aDadNiv1,lDadNiv,lLimMaxTit,1)

		// No caso diferente de inclusao mostro detalhes do Nivel 2...

		If Len( aCabNiv2 ) == 0
			Store Header "BDF" TO aCabNiv2 For ! SX3->X3_CAMPO $ "BDF_SUBCON,BDF_VERSUB,BDF_MATRIC,BDF_TIPREG,BDF_SEQSE3"
		EndIf

		P627TrtFol("BDF",cInterC,cChave,aStruBDF,aCabNiv2,aDadNiv2,lDadNiv,lLimMaxTit,2)

		// No caso diferente de inclusao mostro detalhes do Nivel 3...

		If Len( aCabNiv3 ) == 0
			Store Header "BDF" TO aCabNiv3 For ! SX3->X3_CAMPO $ "BDF_MATRIC,BDF_TIPREG,BDF_SEQSE3"
		EndIf

		P627TrtFol("BDF",cInterC,cChave,aStruBDF,aCabNiv3,aDadNiv3,lDadNiv,lLimMaxTit,3)

		// No caso diferente de inclusao mostro detalhes do Nivel 4...

		If Len( aCabNiv4 ) == 0
			Store Header "BDF" TO aCabNiv4 For ! SX3->X3_CAMPO $ "BDF_NUMCON,BDF_VERCON,BDF_SUBCON,BDF_VERSUB,BDF_TIPREG,BDF_MATFAM,BDF_SEQSE3"
		EndIf

		P627TrtFol("BDF",cInterC,cChave,aStruBDF,aCabNiv4,aDadNiv4,lDadNiv,lLimMaxTit,4)

		// No caso diferente de inclusao mostro detalhes do Nivel 5...

		If Len( aCabNiv5 ) == 0
			Store Header "BDF" TO aCabNiv5 For ! SX3->X3_CAMPO $ "BDF_NUMCON,BDF_VERCON,BDF_SUBCON,BDF_VERSUB,BDF_MATFAM,BDF_SEQSE3"
		EndIf

		P627TrtFol("BDF",cInterC,cChave,aStruBDF,aCabNiv5,aDadNiv5,lDadNiv,lLimMaxTit,5)

		// No caso diferente de inclusao mostro detalhes do Nivel 6...

		If Len( aCabNiv6 ) == 0
			Store Header "BDF" TO aCabNiv6 For ! SX3->X3_CAMPO $ "BDF_SEQSE3"
		EndIf

		P627TrtFol("BDF",cInterC,cChave,aStruBDF,aCabNiv6,aDadNiv6,lDadNiv,lLimMaxTit,6)

		// No caso diferente de inclusao mostro todas as criticas referenciadas Nivel 1...

		If Len( aCabCri1 ) == 0
			Store Header "BDG" TO aCabCri1 For .T.
		EndIf

		P627TrtFol("BDG",cInterC,cChave,aStruBDG,aCabCri1,aDadCri1,lDadCri,lLimMaxTit,1)

		// No caso diferente de inclusao mostro todas as criticas referenciadas Nivel 2...

		If Len( aCabCri2 ) == 0
			Store Header "BDG" TO aCabCri2 For .T.
		EndIf

		P627TrtFol("BDG",cInterC,cChave,aStruBDG,aCabCri2,aDadCri2,lDadCri,lLimMaxTit,2)

		// No caso diferente de inclusao mostro todas as criticas referenciadas Nivel 3...


		If Len( aCabCri3 ) == 0
			Store Header "BDG" TO aCabCri3 For .T.
		EndIf

		P627TrtFol("BDG",cInterC,cChave,aStruBDG,aCabCri3,aDadCri3,lDadCri,lLimMaxTit,3)

		// No caso diferente de inclusao mostro todas as criticas referenciadas Nivel 4...

		If Len( aCabCri4 ) == 0
			Store Header "BDG" TO aCabCri4 For .T.
		EndIf

		P627TrtFol("BDG",cInterC,cChave,aStruBDG,aCabCri4,aDadCri4,lDadCri,lLimMaxTit,4)

		// No caso diferente de inclusao mostro todas as criticas referenciadas Nivel 5...

		If Len( aCabCri5 ) == 0
			Store Header "BDG" TO aCabCri5 For .T.
		EndIf

		P627TrtFol("BDG",cInterC,cChave,aStruBDG,aCabCri5,aDadCri5,lDadCri,lLimMaxTit,5)

		// No caso diferente de inclusao mostro todas as criticas referenciadas Nivel 6...

		If Len( aCabCri6 ) == 0
			Store Header "BDG" TO aCabCri6 For .T.
		EndIf

		P627TrtFol("BDG",cInterC,cChave,aStruBDG,aCabCri6,aDadCri6,lDadCri,lLimMaxTit,6)

		// Titulos Cancelados

		If PLSALIASEX("BTV")

			If Len( aCabBTV ) == 0
				Store Header "BTV" TO aCabBTV For .T.
			EndIf

			cAlias := "QRYBTV"
			cQuery := "SELECT BTV.* "
			cQuery += " FROM "
			cQuery += RetSqlName("BTV")+ " BTV "
			cQuery += " WHERE "
			cQuery += "BTV_FILIAL = '"+xFilial("BDG")+"' AND "
			cQuery += "BTV_PLNUCO = '"+cChave+"' AND "
			cQuery += "BTV_INTERC = '"+cInterC+"' AND "
			cQuery += "BTV.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)

			If !lLimMaxTit
				For nCntFor := 1 To Len(aStruBTV)
					If ( aStruBTV[nCntFor,2]<>"C" )
						TcSetField(cAlias,aStruBTV[nCntFor,1],aStruBTV[nCntFor,2],aStruBTV[nCntFor,3],aStruBTV[nCntFor,4])
					EndIf
				Next


				While (cAlias)->(!Eof())

					Aadd(aDadBTV,Array(Len(aCabBTV)+1))

					BDG->(MsGoto((cAlias)->R_E_C_N_O_))

					For nX := 1 To Len(aCabBTV)
						If ( aCabBTV[nX,10] !=  "V" )
							aDadBTV[Len(aDadBTV)][nX] := (cAlias)->(FieldGet(FieldPos(aCabBTV[nX,2])))
						Else
							aDadBTV[Len(aDadBTV)][nX] := CriaVar(aCabBTV[nX,2],.T.)
						EndIf
					Next
					aDadBTV[Len(aDadBTV)][Len(aCabBTV)+1] := .F.

					(cAlias)->(dbSkip())
				EndDo
				If Empty(aDadBTV)
					Store COLS Blank "BTV" TO aDadBTV FROM aCabBTV
					lDadNiv[9]:= 1
				EndIf
			Else
				If (cAlias)->(Eof())
					lDadNiv[9]:= 1
				EndIf
			EndIf
			(cAlias)->(DbCloseArea())

		EndIf

		// Titulos Gerados

		If Len(aCabSE1G) == 0
			Store Header "SE1" TO aCabSE1G For .T.
		EndIf

		If !lLimMaxTit

			nN1BDF_TIPO   := Ascan(aCabNiv1, { |x| AllTrim(x[2]) = "BDF_TIPO" })
			nN1BDF_PREFIX := Ascan(aCabNiv1, { |x| AllTrim(x[2]) = "BDF_PREFIX" })
			nN1BDF_NUMTIT := Ascan(aCabNiv1, { |x| AllTrim(x[2]) = "BDF_NUMTIT" })
			nN1BDF_PARCEL := Ascan(aCabNiv1, { |x| AllTrim(x[2]) = "BDF_PARCEL" })
			nN1BDF_TITTIP := Ascan(aCabNiv1, { |x| AllTrim(x[2]) = "BDF_TIPTIT" })

			nN2BDF_TIPO   := Ascan(aCabNiv2, { |x| AllTrim(x[2]) = "BDF_TIPO" })
			nN2BDF_PREFIX := Ascan(aCabNiv2, { |x| AllTrim(x[2]) = "BDF_PREFIX" })
			nN2BDF_NUMTIT := Ascan(aCabNiv2, { |x| AllTrim(x[2]) = "BDF_NUMTIT" })
			nN2BDF_PARCEL := Ascan(aCabNiv2, { |x| AllTrim(x[2]) = "BDF_PARCEL" })
			nN2BDF_TITTIP := Ascan(aCabNiv2, { |x| AllTrim(x[2]) = "BDF_TIPTIT" })

			nN3BDF_TIPO   := Ascan(aCabNiv3, { |x| AllTrim(x[2]) = "BDF_TIPO" })
			nN3BDF_PREFIX := Ascan(aCabNiv3, { |x| AllTrim(x[2]) = "BDF_PREFIX" })
			nN3BDF_NUMTIT := Ascan(aCabNiv3, { |x| AllTrim(x[2]) = "BDF_NUMTIT" })
			nN3BDF_PARCEL := Ascan(aCabNiv3, { |x| AllTrim(x[2]) = "BDF_PARCEL" })
			nN3BDF_TITTIP := Ascan(aCabNiv3, { |x| AllTrim(x[2]) = "BDF_TIPTIT" })

			nN4BDF_TIPO   := Ascan(aCabNiv4, { |x| AllTrim(x[2]) = "BDF_TIPO" })
			nN4BDF_PREFIX := Ascan(aCabNiv4, { |x| AllTrim(x[2]) = "BDF_PREFIX" })
			nN4BDF_NUMTIT := Ascan(aCabNiv4, { |x| AllTrim(x[2]) = "BDF_NUMTIT" })
			nN4BDF_PARCEL := Ascan(aCabNiv4, { |x| AllTrim(x[2]) = "BDF_PARCEL" })
			nN4BDF_TITTIP := Ascan(aCabNiv4, { |x| AllTrim(x[2]) = "BDF_TIPTIT" })

			Aadd(aCabSe1G, aClone(aCabSe1G[1]))

			If aScan(aCabSe1G,{|x| x[2] == 'E1_STATUS'}) == 0

				aCabSe1G[Len(aCabSe1G)][1]  := "Status"
				aCabSe1G[Len(aCabSe1G)][2]  := "E1_STATUS"
				aCabSe1G[Len(aCabSe1G)][3]  := "@BMP"
				aCabSe1G[Len(aCabSe1G)][4]  := 0
				aCabSe1G[Len(aCabSe1G)][10] := "V"
				aHeader := {}
				Aadd(aHeader, aCabSe1G[Len(aCabSe1G)])

				For nCols := 1 To Len(aCabSe1G) - 1
					Aadd(aHeader, aCabSe1G[nCols])
				Next

				aCabSe1G := AClone(aHeader)
			EndIf

			Store COLS Blank "SE1" TO aDadSE1G FROM aCabSE1G

			aDadSe1G[1][1] := ""
			lDadNiv[8] := 1
			nCols := 1
			nLido := 0

			Pl625CarSE1(aDadNIV1, @nCols, @nLido, nN1BDF_PREFIX, nN1BDF_NUMTIT, nN1BDF_PARCEL,;
				nN1BDF_TITTIP, nN1BDF_TIPO, aDadSE1G, "0", cChave)
			Pl625CarSE1(aDadNIV2, @nCols, @nLido, nN2BDF_PREFIX, nN2BDF_NUMTIT, nN2BDF_PARCEL,;
				nN2BDF_TITTIP, nN2BDF_TIPO, aDadSE1G, "0", cChave)
			Pl625CarSE1(aDadNIV3, @nCols, @nLido, nN3BDF_PREFIX, nN3BDF_NUMTIT, nN3BDF_PARCEL,;
				nN3BDF_TITTIP, nN3BDF_TIPO, aDadSE1G, "0", cChave)
			Pl625CarSE1(aDadNIV4, @nCols, @nLido, nN4BDF_PREFIX, nN4BDF_NUMTIT, nN4BDF_PARCEL,;
				nN4BDF_TITTIP, nN4BDF_TIPO, aDadSE1G, "0", cChave)

		EndIf

	EndIf

	nCols := 1
	nLido := 0



Return .T.

/*/{Protheus.doc} Cr627FolCri
Monta Tela de critica para os lotes de cobranca

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function Cr627FolCri(nOpc)
	LOCAL oFldTit   := NIL
	LOCAL oFldTitC  := NIL
	LOCAL aButRec 	:= { { 'S4WB013N',	{||	Fc040Con() }, STR0103 } } //"Posicao do titulo a Receber"
	LOCAL aCpoBBT	:= {	"BBT_NIVEL","BBT_PREFIX","BBT_NUMTIT","BBT_PARCEL",;
		"BBT_TIPTIT","BBT_BASIRR","BBT_BASISS","BBT_BASINS",;
		"BBT_BASCOF","BBT_BASCOF","BBT_BASCSL","BBT_BASPIS",;
		"BBT_PERIRF","BBT_PERINS","BBT_PERCSL","BBT_PERCOF",;
		"BBT_PERPIS","BBT_PERISS","BBT_MODPAG"}
	LOCAL oEnc
	LOCAL oGetSE1G

	PRIVATE aTELA   := {}
	PRIVATE aGETS   := {}

	If nOpc <> K_Incluir
		If !lLimMaxTit

			// Folder Grupo/Empresa

			if lDadNiv[1] == 0
				@ 001,001 FOLDER oFldNiv1 SIZE aPosObj[2][3]-05,aPosObj[2][4]-05 OF oFolder:aDialogs[2] PIXEL	PROMPTS	STR0104,STR0105 //"Detalhes"###"Criticas"

				oGetNiv1 := TPLSBrw():New(002,020,aPosObj[2][3]-10,aPosObj[2][4]-17,nil  ,oFldNiv1:aDialogs[1],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabNiv1   ,aDadNiv1 ,.F.      ,"BDF" ,K_Visualizar,STR0054,nil,nil,nil,nil,nil,nil,nil,nil,aButRec) //"Niv. Empresa"

				@ 005,005 BTNBMP oBotao01 RESOURCE "VERNOTA" SIZE 030 ,030 OF oFldNiv1:aDialogs[1] PIXEL MESSAGE STR0272 ACTION GdSeek(oGetNiv1:oBrowse,OemtoAnsi(STR0272),oGetNiv1:aHeader,oGetNiv1:aCols,.F.)

				oGetNiv1:bLostFocus := {|| 	cCodDet[1] := oGetNiv1:aCols[oGetNiv1:Linha(),oGetNiv1:PlRetPos("BDF_CODSEQ",.T.,aCabNiv1)],;
					cPrfBDF := oGetNiv1:aCols[oGetNiv1:Linha(),oGetNiv1:PlRetPos("BDF_PREFIX",.T.,aCabNiv1)],;
					cNumBDF := oGetNiv1:aCols[oGetNiv1:Linha(),oGetNiv1:PlRetPos("BDF_NUMTIT",.T.,aCabNiv1)],;
					cParBDF := oGetNiv1:aCols[oGetNiv1:Linha(),oGetNiv1:PlRetPos("BDF_PARCEL",.T.,aCabNiv1)],;
					cTipoBdf := oGetNiv1:aCols[oGetNiv1:Linha(),oGetNiv1:PlRetPos("BDF_TIPTIT",.T.,aCabNiv1)],;
					oGetNiv1:aButEsp := If((SE1->(DbSetOrder(1)),;
					SE1->(DbSeek(xFilial("SE1") + cPrfBDF +;
					cNumBDF + cParBDF + cTipoBDF))), aButRec, {}) }
				oGetNiv1:bChange    := {|| Eval(oGetNiv1:bLostFocus), ChangeBRW(1)}
				Eval(oGetNiv1:bLostFocus)
				if lDadCri[1] == 0
					bFilter  		  := {|nLine,aCols,aHeader| aCols[nLine,GdFieldPos("BDG_CODSEQ",aHeader)]==cCodDet[1] }
					oGetCri1 		  := TPLSBrw():New(002,001,aPosObj[2][3]-10,aPosObj[2][4]-17,nil  ,oFldNiv1:aDialogs[2],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCri1   ,aDadCri1 ,.F.      ,"BDG" ,K_Visualizar,STR0106,nil,nil,nil,,,,bFilter) //"Criticas dos Detalhes"
					oGetCri1:oPai 	  := oGetNiv1
					oGetCri1:aOrigem  := {"BDF_CODSEQ"}
					oGetCri1:aRelac   := {"BDG_CODSEQ"}
				Else
					@ 005, 006 Say oSayCri1 PROMPT STR0107 SIZE 150, 006 OF oFldNiv1:aDialogs[2] PIXEL COLOR CLR_HBLUE //"Nao foram encontradas criticas para este nivel"
				EndIf
			Else
				@ 005, 006 Say oSayNiv1 PROMPT STR0108 SIZE 150, 006 OF oFolder:aDialogs[2] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
			EndIf
		Else
			If lDadNiv[1] <> 0
				@ 005, 006 Say oSayNiv1 PROMPT STR0108 SIZE 150, 006 OF oFolder:aDialogs[2] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
			Else
				@ 035,035 BUTTON oBtPsq1 PROMPT STR0270 ACTION  {| | cCadastro := STR0271,A627VisLoteTit(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,'1',aCabNiv1)}  SIZE 40,11 of oFolder:aDialogs[2] PIXEL
				oBtPsq1:cTOOLTIP   := STR0270
			EndIf
		EndIf

		// Folder Contrato

		If !lLimMaxTit
			if lDadNiv[2] == 0
				@ 001,001 FOLDER oFldNiv2 SIZE aPosObj[2][3]-05,aPosObj[2][4]-05 OF oFolder:aDialogs[3] PIXEL	PROMPTS	STR0104,STR0105 //"Detalhes"###"Criticas"
				oGetNiv2 := TPLSBrw():New(002,020,aPosObj[2][3]-10,aPosObj[2][4]-17,nil  ,oFldNiv2:aDialogs[1],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabNiv2   ,aDadNiv2 ,.F.      ,"BDF" ,K_Visualizar,STR0055,nil,nil,nil,nil,nil,nil,nil,nil,aButRec) //"Niv. Contrato"

				@ 005,005 BTNBMP oBotao02 RESOURCE "VERNOTA" SIZE 030 ,030 OF oFldNiv2:aDialogs[1] PIXEL MESSAGE STR0272 ACTION GdSeek(oGetNiv2:oBrowse,OemtoAnsi(STR0272),oGetNiv2:aHeader,oGetNiv2:aCols,.F.)

				oGetNiv2:bLostFocus := {|| 	cCodDet[2] := oGetNiv2:aCols[oGetNiv2:Linha(),oGetNiv2:PlRetPos("BDF_CODSEQ",.T.,aCabNiv2)],;
					cPrfBDF := oGetNiv2:aCols[oGetNiv2:Linha(),oGetNiv2:PlRetPos("BDF_PREFIX",.T.,aCabNiv2)],;
					cNumBDF := oGetNiv2:aCols[oGetNiv2:Linha(),oGetNiv2:PlRetPos("BDF_NUMTIT",.T.,aCabNiv2)],;
					cParBDF := oGetNiv2:aCols[oGetNiv2:Linha(),oGetNiv2:PlRetPos("BDF_PARCEL",.T.,aCabNiv2)],;
					cTipoBdf := oGetNiv2:aCols[oGetNiv2:Linha(),oGetNiv2:PlRetPos("BDF_TIPTIT",.T.,aCabNiv2)],;
					oGetNiv2:aButEsp := If((SE1->(DbSetOrder(1)),;
					SE1->(DbSeek(xFilial("SE1") + cPrfBDF +;
					cNumBDF + cParBDF + cTipoBDF))), aButRec, {}) }
				oGetNiv2:bChange    := {|| Eval(oGetNiv2:bLostFocus), ChangeBRW(2)}
				Eval(oGetNiv2:bLostFocus)
				if lDadCri[2] == 0
					bFilter  := {|nLine,aCols,aHeader| aCols[nLine,GdFieldPos("BDG_CODSEQ",aHeader)]==cCodDet[2] }
					oGetCri2 := TPLSBrw():New(002,001,aPosObj[2][3]-10,aPosObj[2][4]-17,nil  ,oFldNiv2:aDialogs[2],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCri2   ,aDadCri2 ,.F.      ,"BDG" ,K_Visualizar,STR0106,nil,nil,nil,,,,bFilter) //"Criticas dos Detalhes"
					oGetCri2:oPai := oGetNiv2
					oGetCri2:aOrigem  := {"BDF_CODSEQ"}
					oGetCri2:aRelac   := {"BDG_CODSEQ"}
				Else
					@ 005, 006 Say oSayCri2 PROMPT STR0107 SIZE 150, 006 OF oFldNiv2:aDialogs[2] PIXEL COLOR CLR_HBLUE //"Nao foram encontradas criticas para este nivel"
				EndIf
			Else
				@ 005, 006 Say oSayNiv2 PROMPT STR0108 SIZE 150, 006 OF oFolder:aDialogs[3] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
			EndIf
		Else
			If lDadNiv[2] <> 0
				@ 005, 006 Say oSayNiv2 PROMPT STR0108 SIZE 150, 006 OF oFolder:aDialogs[3] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
			Else
				@ 035,035 BUTTON oBtPsq2 PROMPT STR0270 ACTION  {| | cCadastro := STR0055,A627VisLoteTit(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,'2',aCabNiv2)}  SIZE 40,11 of oFolder:aDialogs[3] PIXEL
				oBtPsq2:cTOOLTIP   := STR0270
			EndIf
		EndIf

		// Folder Sub-Contrato

		If !lLimMaxTit
			if lDadNiv[3] == 0
				@ 001,001 FOLDER oFldNiv3 SIZE aPosObj[2][3]-05,aPosObj[2][4]-05 OF oFolder:aDialogs[4] PIXEL	PROMPTS	STR0104,STR0105 //"Detalhes"###"Criticas"
				oGetNiv3 := TPLSBrw():New(002,020,aPosObj[2][3]-10,aPosObj[2][4]-17,nil  ,oFldNiv3:aDialogs[1],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabNiv3   ,aDadNiv3 ,.F.      ,"BDF" ,K_Visualizar,STR0056,nil,nil,nil,nil,nil,nil,nil,nil,aButRec) //"Niv. Sub-Contrato"

				@ 005,005 BTNBMP oBotao03 RESOURCE "VERNOTA" SIZE 030 ,030 OF oFldNiv3:aDialogs[1] PIXEL MESSAGE STR0272 ACTION GdSeek(oGetNiv3:oBrowse,OemtoAnsi(STR0272),oGetNiv3:aHeader,oGetNiv3:aCols,.F.)

				oGetNiv3:bLostFocus := {||	cCodDet[3] := oGetNiv3:aCols[oGetNiv3:Linha(),oGetNiv3:PlRetPos("BDF_CODSEQ",.T.,aCabNiv3)],;
					cPrfBDF := oGetNiv3:aCols[oGetNiv3:Linha(),oGetNiv3:PlRetPos("BDF_PREFIX",.T.,aCabNiv3)],;
					cNumBDF := oGetNiv3:aCols[oGetNiv3:Linha(),oGetNiv3:PlRetPos("BDF_NUMTIT",.T.,aCabNiv3)],;
					cParBDF := oGetNiv3:aCols[oGetNiv3:Linha(),oGetNiv3:PlRetPos("BDF_PARCEL",.T.,aCabNiv3)],;
					cTipoBdf := oGetNiv3:aCols[oGetNiv3:Linha(),oGetNiv3:PlRetPos("BDF_TIPTIT",.T.,aCabNiv3)],;
					oGetNiv3:aButEsp := If((SE1->(DbSetOrder(1)),;
					SE1->(DbSeek(xFilial("SE1") + cPrfBDF +;
					cNumBDF + cParBDF + cTipoBDF))), aButRec, {}) }
				oGetNiv3:bChange    := {|| Eval(oGetNiv3:bLostFocus), ChangeBRW(3)}
				Eval(oGetNiv3:bLostFocus)
				if lDadCri[3] == 0
					bFilter  := {|nLine,aCols,aHeader| aCols[nLine,GdFieldPos("BDG_CODSEQ",aHeader)]==cCodDet[3] }
					oGetCri3 := TPLSBrw():New(002,001,aPosObj[2][3]-10,aPosObj[2][4]-17,nil  ,oFldNiv3:aDialogs[2],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCri3   ,aDadCri3 ,.F.      ,"BDG" ,K_Visualizar,STR0106,nil,nil,nil,,,,bFilter) //"Criticas dos Detalhes"
					oGetCri3:oPai := oGetNiv3
					oGetCri3:aOrigem  := {"BDF_CODSEQ"}
					oGetCri3:aRelac   := {"BDG_CODSEQ"}
				Else
					@ 005, 006 Say oSayCri3 PROMPT STR0107 SIZE 150, 006 OF oFldNiv3:aDialogs[2] PIXEL COLOR CLR_HBLUE //"Nao foram encontradas criticas para este nivel"
				EndIf

			Else
				@ 005, 006 Say oSayNiv3 PROMPT STR0108 SIZE 150, 006 OF oFolder:aDialogs[4] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
			EndIf
		Else
			If lDadNiv[3] <> 0
				@ 005, 006 Say oSayNiv3 PROMPT STR0108 SIZE 150, 006 OF oFolder:aDialogs[4] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
			Else
				@ 035,035 BUTTON oBtPsq3 PROMPT STR0270 ACTION  {| | cCadastro := STR0056,A627VisLoteTit(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,'3',aCabNiv3)}  SIZE 40,11 of oFolder:aDialogs[4] PIXEL
				oBtPsq3:cTOOLTIP   := STR0270
			EndIf
		EndIf

		// Folder Familia

		If !lLimMaxTit
			If lDadNiv[4] == 0
				@ 001,001 FOLDER oFldNiv4 SIZE aPosObj[2][3]-05,aPosObj[2][4]-05 OF oFolder:aDialogs[5] PIXEL	PROMPTS	STR0104,STR0105 //"Detalhes"###"Criticas"

				oGetNiv4 := TPLSBrw():New(002,020,aPosObj[2][3]-10,aPosObj[2][4]-17,nil  ,oFldNiv4:aDialogs[1],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabNiv4   ,aDadNiv4 ,.F.      ,"BDF" ,K_Visualizar,STR0057,nil,nil,nil,nil,nil,nil,nil,nil,aButRec) //"Niv. Familia"

				@ 005,005 BTNBMP oBotao04 RESOURCE "VERNOTA" SIZE 030 ,030 OF oFldNiv4:aDialogs[1] PIXEL MESSAGE STR0272 ACTION GdSeek(oGetNiv4:oBrowse,OemtoAnsi(STR0272),oGetNiv4:aHeader,oGetNiv4:aCols,.F.)

				oGetNiv4:bLostFocus := {|| 	cCodDet[4] := oGetNiv4:aCols[oGetNiv4:Linha(),oGetNiv4:PlRetPos("BDF_CODSEQ",.T.,aCabNiv4)],;
					cPrfBDF := oGetNiv4:aCols[oGetNiv4:Linha(),oGetNiv4:PlRetPos("BDF_PREFIX",.T.,aCabNiv4)],;
					cNumBDF := oGetNiv4:aCols[oGetNiv4:Linha(),oGetNiv4:PlRetPos("BDF_NUMTIT",.T.,aCabNiv4)],;
					cParBDF := oGetNiv4:aCols[oGetNiv4:Linha(),oGetNiv4:PlRetPos("BDF_PARCEL",.T.,aCabNiv4)],;
					cTipoBdf := oGetNiv4:aCols[oGetNiv4:Linha(),oGetNiv4:PlRetPos("BDF_TIPTIT",.T.,aCabNiv4)],;
					oGetNiv4:aButEsp := If((SE1->(DbSetOrder(1)),;
					SE1->(DbSeek(xFilial("SE1") + cPrfBDF +;
					cNumBDF + cParBDF + cTipoBDF))), aButRec, {})}
				oGetNiv4:bChange    := {|| Eval(oGetNiv4:bLostFocus), ChangeBRW(4)}
				Eval(oGetNiv4:bLostFocus)
				if lDadCri[4] == 0
					bFilter  := {|nLine,aCols,aHeader| aCols[nLine,GdFieldPos("BDG_CODSEQ",aHeader)]==cCodDet[4] }
					oGetCri4 := TPLSBrw():New(002,001,aPosObj[2][3]-10,aPosObj[2][4]-17,nil  ,oFldNiv4:aDialogs[2],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCri4   ,aDadCri4 ,.F.      ,"BDG" ,K_Visualizar,STR0106,nil,nil,nil,,,,bFilter) //"Criticas dos Detalhes"
					oGetCri4:oPai := oGetNiv4
					oGetCri4:aOrigem  := {"BDF_CODSEQ"}
					oGetCri4:aRelac   := {"BDG_CODSEQ"}
				Else
					@ 005, 006 Say oSayCri4 PROMPT STR0107 SIZE 150, 006 OF oFldNiv4:aDialogs[2] PIXEL COLOR CLR_HBLUE //"Nao foram encontradas criticas para este nivel"
				EndIf

			Else
				@ 005, 006 Say oSayNiv4 PROMPT STR0108 SIZE 150, 006 OF oFolder:aDialogs[5] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
			EndIf
		Else
			If lDadNiv[4] <> 0
				@ 005, 006 Say oSayNiv4 PROMPT STR0108 SIZE 150, 006 OF oFolder:aDialogs[5] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
			Else
				@ 035,035 BUTTON oBtPsq4 PROMPT STR0270 ACTION  {| | cCadastro := STR0057,A627VisLoteTit(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,'4',aCabNiv4)}  SIZE 40,11 of oFolder:aDialogs[5] PIXEL
				oBtPsq4:cTOOLTIP   := STR0270
			EndIf
		EndIf

		// Folder Usuario

		If !lLimMaxTit
			if lDadNiv[5] == 0
				@ 001,001 FOLDER oFldNiv5 SIZE aPosObj[2][3]-05,aPosObj[2][4]-05 OF oFolder:aDialogs[6] PIXEL	PROMPTS	STR0104,STR0105 //"Detalhes"###"Criticas"
				oGetNiv5 := TPLSBrw():New(002,020,aPosObj[2][3]-10,aPosObj[2][4]-17,nil  ,oFldNiv5:aDialogs[1],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabNiv5   ,aDadNiv5 ,.F.      ,"BDF" ,K_Visualizar,STR0058,nil,nil,nil,nil,nil,nil,nil,nil,aButRec) //"Niv. Usuario"

				@ 005,005 BTNBMP oBotao05 RESOURCE "VERNOTA" SIZE 030 ,030 OF oFldNiv5:aDialogs[1] PIXEL MESSAGE STR0272 ACTION GdSeek(oGetNiv5:oBrowse,OemtoAnsi(STR0272),oGetNiv5:aHeader,oGetNiv5:aCols,.F.)

				oGetNiv5:bLostFocus := {|| 	cCodDet[5] := oGetNiv5:aCols[oGetNiv5:Linha(),oGetNiv5:PlRetPos("BDF_CODSEQ",.T.,aCabNiv5)],;
					cPrfBDF := oGetNiv5:aCols[oGetNiv5:Linha(),oGetNiv5:PlRetPos("BDF_PREFIX",.T.,aCabNiv5)],;
					cNumBDF := oGetNiv5:aCols[oGetNiv5:Linha(),oGetNiv5:PlRetPos("BDF_NUMTIT",.T.,aCabNiv5)],;
					cParBDF := oGetNiv5:aCols[oGetNiv5:Linha(),oGetNiv5:PlRetPos("BDF_PARCEL",.T.,aCabNiv5)],;
					cTipoBdf := oGetNiv5:aCols[oGetNiv5:Linha(),oGetNiv5:PlRetPos("BDF_TIPTIT",.T.,aCabNiv5)],;
					oGetNiv5:aButEsp := If((SE1->(DbSetOrder(1)),;
					SE1->(DbSeek(xFilial("SE1") + cPrfBDF +;
					cNumBDF + cParBDF + cTipoBDF))), aButRec, {})}
				oGetNiv5:bChange    := {|| Eval(oGetNiv5:bLostFocus), ChangeBRW(5)}
				Eval(oGetNiv5:bLostFocus)
				if lDadCri[5] == 0
					bFilter  := {|nLine,aCols,aHeader| aCols[nLine,GdFieldPos("BDG_CODSEQ",aHeader)]==cCodDet[5] }
					oGetCri5 := TPLSBrw():New(002,001,aPosObj[2][3]-10,aPosObj[2][4]-17,nil  ,oFldNiv5:aDialogs[2],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCri5   ,aDadCri5 ,.F.      ,"BDG" ,K_Visualizar,STR0106,nil,nil,nil,,,,bFilter) //"Criticas dos Detalhes"
					oGetCri5:oPai := oGetNiv5
					oGetCri5:aOrigem  := {"BDF_CODSEQ"}
					oGetCri5:aRelac   := {"BDG_CODSEQ"}
				Else
					@ 005, 006 Say oSayCri5 PROMPT STR0107 SIZE 150, 006 OF oFldNiv5:aDialogs[2] PIXEL COLOR CLR_HBLUE //"Nao foram encontradas criticas para este nivel"
				EndIf

			Else
				@ 005, 006 Say oSayNiv5 PROMPT STR0108 SIZE 150, 006 OF oFolder:aDialogs[6] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
			EndIf
		Else
			If lDadNiv[5] <> 0
				@ 005, 006 Say oSayNiv5 PROMPT STR0108 SIZE 150, 006 OF oFolder:aDialogs[6] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
			Else
				@ 035,035 BUTTON oBtPsq5 PROMPT STR0270 ACTION  {| | cCadastro := STR0058,A627VisLoteTit(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,'5',aCabNiv5)}  SIZE 40,11 of oFolder:aDialogs[6] PIXEL
				oBtPsq5:cTOOLTIP   := STR0270
			EndIf
		EndIf

		// Folder Opcional

		If !lLimMaxTit
			if lDadNiv[6] == 0
				@ 001,001 FOLDER oFldNiv6 SIZE aPosObj[2][3]-05,aPosObj[2][4]-05 OF oFolder:aDialogs[7] PIXEL	PROMPTS	STR0104,STR0105 //"Detalhes"###"Criticas"
				oGetNiv6 := TPLSBrw():New(002,020,aPosObj[2][3]-10,aPosObj[2][4]-17,nil  ,oFldNiv6:aDialogs[1],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabNiv6   ,aDadNiv6 ,.F.     ,"BDF" ,K_Visualizar,STR0059,nil,nil,nil,nil,nil,nil,nil,nil,aButRec) //"Niv. Opcional"

				@ 005,005 BTNBMP oBotao06 RESOURCE "VERNOTA" SIZE 030 ,030 OF oFldNiv6:aDialogs[1] PIXEL MESSAGE STR0272 ACTION GdSeek(oGetNiv6:oBrowse,OemtoAnsi(STR0272),oGetNiv6:aHeader,oGetNiv6:aCols,.F.)

				oGetNiv6:bLostFocus := {|| 	cCodDet[6] := oGetNiv6:aCols[oGetNiv6:Linha(),oGetNiv6:PlRetPos("BDF_CODSEQ",.T.,aCabNiv6)],;
					cPrfBDF := oGetNiv6:aCols[oGetNiv6:Linha(),oGetNiv6:PlRetPos("BDF_PREFIX",.T.,aCabNiv6)],;
					cNumBDF := oGetNiv6:aCols[oGetNiv6:Linha(),oGetNiv6:PlRetPos("BDF_NUMTIT",.T.,aCabNiv6)],;
					cParBDF := oGetNiv6:aCols[oGetNiv6:Linha(),oGetNiv6:PlRetPos("BDF_PARCEL",.T.,aCabNiv6)],;
					cTipoBdf := oGetNiv6:aCols[oGetNiv6:Linha(),oGetNiv6:PlRetPos("BDF_TIPTIT",.T.,aCabNiv6)],;
					oGetNiv6:aButEsp := If((SE1->(DbSetOrder(1)),;
					SE1->(DbSeek(xFilial("SE1") + cPrfBDF +;
					cNumBDF + cParBDF + cTipoBDF))), aButRec, {})}
				oGetNiv6:bChange    := {|| Eval(oGetNiv6:bLostFocus), ChangeBRW(6)}
				Eval(oGetNiv6:bLostFocus)
				if lDadCri[6] == 0
					bFilter  := {|nLine,aCols,aHeader| aCols[nLine,GdFieldPos("BDG_CODSEQ",aHeader)]==cCodDet[6] }
					oGetCri6 := TPLSBrw():New(002,001,aPosObj[2][3]-10,aPosObj[2][4]-17,nil  ,oFldNiv6:aDialogs[2],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCri6   ,aDadCri6 ,.F.      ,"BDG" ,K_Visualizar,STR0106,nil,nil,nil,,,,bFilter) //"Criticas dos Detalhes"
					oGetCri6:oPai := oGetNiv6
					oGetCri6:aOrigem  := {"BDF_CODSEQ"}
					oGetCri6:aRelac   := {"BDG_CODSEQ"}
				Else
					@ 005, 006 Say oSayCri6 PROMPT STR0107 SIZE 150, 006 OF oFldNiv6:aDialogs[2] PIXEL COLOR CLR_HBLUE //"Nao foram encontradas criticas para este nivel"
				EndIf

			Else
				@ 005, 006 Say oSayNiv6 PROMPT STR0108 SIZE 150, 006 OF oFolder:aDialogs[7] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
			EndIf
		Else
			If lDadNiv[6] <> 0
				@ 005, 006 Say oSayNiv6 PROMPT STR0108 SIZE 150, 006 OF oFolder:aDialogs[7] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
			Else
				@ 035,035 BUTTON oBtPsq6 PROMPT STR0270 ACTION  {| | cCadastro := STR0059,A627VisLoteTit(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,'6',aCabNiv6)}  SIZE 40,11 of oFolder:aDialogs[7] PIXEL
				oBtPsq6:cTOOLTIP   := STR0270
			EndIf
		EndIf

		// Folder Titulos

		If Len( aCabBBT ) == 0
			Store Header "BBT" TO aCabBBT For .T.
		EndIf

		If !lLimMaxTit

			If lDadNiv[8] == 0

				@ 001,001 FOLDER oFldTit SIZE aPosObj[2][3]-05,aPosObj[2][4]-05 OF oFolder:aDialogs[8] PIXEL	PROMPTS	STR0109,STR0110 //"Titulos"###"Complemento"
				oFldTit:bChange := { |nFolder| nReg := PLS627CTIT(nFolder,oGetSE1G)}

				oGetSE1G := TPLSBrw():New(002,020,aPosObj[2][3]-10,aPosObj[2][4]-17,nil  ,oFldTit:aDialogs[1] ,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabSE1G  ,aDadSE1G,.F.      ,"SE1" ,K_Visualizar,STR0060,nil,nil,nil,nil) //"Titulos Gerados"

				@ 005,005 BTNBMP oBotao07 RESOURCE "VERNOTA" SIZE 030 ,030 OF oFldTit:aDialogs[1] PIXEL MESSAGE STR0272 ACTION GdSeek(oGetSE1G:oBrowse,OemtoAnsi(STR0272),oGetSE1G:aHeader,oGetSE1G:aCols,.F.)

				// Chama a funca para atribuir conteudo inicial para o folder Complementos.

				nReg := PLS627CTIT(2,oGetSE1G)

				oEnc := BBT->(MSMGet():New("BBT",0,K_Visualizar,,,,aCpoBBT,{001,001,aPosObj[2][4]-17,aPosObj[2][3]-10},aCpoBBT,,,,,oFldTit:aDialogs[2],,,.T.))

			Else
				@ 005,006 say oSaytit PROMPT STR0108 SIZE  150, 006 OF oFolder:aDialogs[8] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
			EndIf

		Else

			If lDadNiv[8] <> 0
				@ 005, 006 Say oSaytit PROMPT STR0108 SIZE 150, 006 OF oFolder:aDialogs[8] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
			Else
				@ 035,035 BUTTON oBtPsq8 PROMPT STR0270 ACTION {| | cCadastro := STR0109,A627VisFatTit(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,aCabBBT)} SIZE 40,11 of oFolder:aDialogs[8] PIXEL
				oBtPsq8:cTOOLTIP   := STR0270
			EndIf

		EndIf

		// Folder Titulos Cancelados
		If PLSALIASEX("BTV")

			If !lLimMaxTit

				If lDadNiv[9] == 0

					@ 001,001 FOLDER oFldTitC SIZE aPosObj[2][3]-05,aPosObj[2][4]-05 OF oFolder:aDialogs[9] PIXEL	PROMPTS	STR0109 //"Titulos"
					oGetBTV  := TPLSBrw():New(002,020,aPosObj[2][3]-10,aPosObj[2][4]-17,nil  ,oFldTitC:aDialogs[1],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBTV   ,aDadBTV ,.F.      ,"BTV" ,K_Visualizar,STR0061,nil,nil,nil,nil) //"Titulos Cancelados"
					@ 005,005 BTNBMP oBotao08 RESOURCE "VERNOTA" SIZE 030 ,030 OF oFldTitC:aDialogs[1] PIXEL MESSAGE STR0272 ACTION GdSeek(oGetBTV:oBrowse,OemtoAnsi(STR0272),oGetBTV:aHeader,oGetBTV:aCols,.F.)

				Else
					@ 005,006 say oSayNiv7 PROMPT STR0108 SIZE  150, 006 OF oFolder:aDialogs[9] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
				EndIf

			Else

				If lDadNiv[9] <> 0
					@ 005,006 say oSayNiv7 PROMPT STR0108 SIZE  150, 006 OF oFolder:aDialogs[9] PIXEL COLOR CLR_HBLUE //"Nao foram gerados titulos para este nivel"
				Else
					@ 035,035 BUTTON oBtPsq7 PROMPT STR0270 ACTION {| | cCadastro := STR0262,A627ViTc(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,aCabBTV) }  SIZE 40,11 of oFolder:aDialogs[9] PIXEL
					oBtPsq7:cTOOLTIP   := STR0270
				EndIf

			EndIf

		EndIf

	EndIf

	// Monta Resumo...
	If nOpc <> K_Incluir
		oGetRes := TPLSBrw():New(002,001,aPosObj[2][3],aPosObj[2][4],nil  ,oFolder:aDialogs[1],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabRes   ,aDadRes ,.F.      ,"BDD" ,K_Visualizar,STR0111,nil,nil,nil,nil) //"Resumo do Lote"
	EndIf

Return .T.

/*/{Protheus.doc} ChangeBrw
Atualiza as GETDADOS de acordo com a localidade

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Static Function ChangeBrw(nNumero)

	if nNumero == 1 .And. lDadCri[nNumero] == 0
		oGetCri1:ForceRefresh(oGetNiv1)
	Elseif nNumero == 2  .And. lDadCri[nNumero] == 0
		oGetCri2:ForceRefresh(oGetNiv2)
	Elseif nNumero == 3  .And. lDadCri[nNumero] == 0
		oGetCri3:ForceRefresh(oGetNiv3)
	Elseif nNumero == 4  .And. lDadCri[nNumero] == 0
		oGetCri4:ForceRefresh(oGetNiv4)
	Elseif nNumero == 5  .And. lDadCri[nNumero] == 0
		oGetCri5:ForceRefresh(oGetNiv5)
	Elseif nNumero == 6  .And. lDadCri[nNumero] == 0
		oGetCri6:ForceRefresh(oGetNiv6)
	Elseif nNumero == 7  .And. lDadCri[nNumero] == 0
		oGetCri7:ForceRefresh(oGetNiv7)
	EndIf

Return

/*/{Protheus.doc} A627BusNat
Obtem a natureza para gerar o titulo.

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function A627BusNat(cTipo,cNatNivel,cKeyCli,cKeyPro,cNivCob,cMdFatPt)
	LOCAL cRet := ''

	DEFAULT cNivCob  := ""
	DEFAULT cMdFatPt := ""

	If lPl627Nat
		cRet := ExecBlock("PL627NAT",.F.,.F.,{cTipo, cNatNivel, cKeyCli, cKeyPro, cNivCob, cMdFatPt})
	Else

		If cTipo == '1'

			If !Empty(cNatNivel)
				cRet := cNatNivel
			Else
				cRet := Posicione("BI3",1,xFilial("BI3")+cKeyPro, "BI3_NATURE")
				If Empty(cRet)
					cRet := Posicione("SA1",1,xFilial("SA1")+cKeyCli, "A1_NATUREZ")
				EndIf
				If Empty(cRet)
					cRet := SuperGetMv("MV_PLSNAT", .F., "PLS")
				EndIf
			EndIf

		Else

			If !Empty(cNatNivel)
				cRet := cNatNivel
			Else
				cRet := Posicione("SA1",1,xFilial("SA1")+cKeyCli, "A1_NATUREZ")
				If Empty(cRet)
					cRet := SuperGetMv("MV_PLSNAT", .F., "PLS")
				EndIf
			EndIf

		EndIf

	EndIf

Return(cRet)

/*/{Protheus.doc} PLSINCBFQ
Inclui os codigos do BFQ (lancamento de cobranca ) sob demanda..

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Static Function PLSINCBFQ(cCodigo,cCodOpe)

	If cCodigo == "101"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "01"
		BFQ->BFQ_DESCRI  := STR0112 //"Produto/Plano (Mensalidade)"
		BFQ->BFQ_SEQUEN  := "001"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "1"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "102"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "02"
		BFQ->BFQ_DESCRI  := STR0113 //"Opcionais/Termos Aditivos     "
		BFQ->BFQ_SEQUEN  := "002"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "1"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "103"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "03"
		BFQ->BFQ_DESCRI  := STR0114 //"Taxa Inscricao/Adesao"
		BFQ->BFQ_SEQUEN  := "003"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "1"
		BFQ->BFQ_TIPFAT	:= "1"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "104"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "04"
		BFQ->BFQ_DESCRI  := STR0115 //"Custo Operac. Servicos Medicos"
		BFQ->BFQ_SEQUEN  := "004"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "1"
		BFQ->BFQ_TIPFAT	:= "1"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "105"			// Nao esta sendo tratado pelo sistema.
	ElseIf cCodigo == "106"			// Nao esta sendo tratado pelo sistema.
	ElseIf cCodigo == "107"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "07"
		BFQ->BFQ_DESCRI  := STR0116 //"Cartao de Identificacao       "
		BFQ->BFQ_SEQUEN  := "007"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "1"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "108"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "08"
		BFQ->BFQ_DESCRI  := STR0117 //"Reembolso de Livre Escolha    "
		BFQ->BFQ_SEQUEN  := "008"
		BFQ->BFQ_DEBCRE  := "2"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "109"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "09"
		BFQ->BFQ_DESCRI  := STR0118 //"Via de Boleto"
		BFQ->BFQ_SEQUEN  := "009"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "110"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "10"
		BFQ->BFQ_DESCRI  := STR0119 //"Valor do Agravo"
		BFQ->BFQ_SEQUEN  := "010"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "111"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "11"
		BFQ->BFQ_DESCRI  := STR0120 //"Juros mes anterior"
		BFQ->BFQ_SEQUEN  := "011"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "112"			// Nao esta sendo tratado pelo sistema.
		//       BFQ->BFQ_DESCRI  := "Ajuste do Reajuste"
	ElseIf cCodigo == "113"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "13"
		BFQ->BFQ_DESCRI  := STR0121 //"Debitos Serv. Medicos"
		BFQ->BFQ_SEQUEN  := "013"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "1"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "114"        	// Nao esta sendo tratado pelo sistema.
		//       BFQ->BFQ_DESCRI  := "Devolucao de Valor"
	ElseIf cCodigo == "115"			// Nao esta sendo tratado pelo sistema.
		//       BFQ->BFQ_DESCRI  := "Reajuste Retroativo (Empresas)"
	ElseIf cCodigo == "116"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "16"
		BFQ->BFQ_DESCRI  := STR0122 //"Ft Moderador/Co-Participacao"
		BFQ->BFQ_SEQUEN  := "016"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "117"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "17"
		BFQ->BFQ_DESCRI  := STR0123 //"Taxa Administrativa"
		BFQ->BFQ_SEQUEN  := "017"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "1"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "118"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "18"
		BFQ->BFQ_DESCRI  := STR0124 //"Mensalidade Retroativa"
		BFQ->BFQ_SEQUEN  := "018"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "119"			// Nao esta sendo tratado pelo sistema.
		//       BFQ->BFQ_DESCRI  := "Alteracao de Vencimento"
	ElseIf cCodigo == "120"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "20"
		BFQ->BFQ_DESCRI  := STR0125 //"Custo Operac. Compras Pgto Ato"
		BFQ->BFQ_SEQUEN  := "020"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "121"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "21"
		BFQ->BFQ_DESCRI  := STR0126 //"Co-Partic. Compras Pagto Ato"
		BFQ->BFQ_SEQUEN  := "021"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "122"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "22"
		BFQ->BFQ_DESCRI  := STR0127 //"Taxas Compras Pagto Ato"
		BFQ->BFQ_SEQUEN  := "022"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "123"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "23"
		BFQ->BFQ_DESCRI  := STR0128 //"Custo Oper. Compras a Faturar"
		BFQ->BFQ_SEQUEN  := "023"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "124"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "24"
		BFQ->BFQ_DESCRI  := STR0129 //"Co-Partic. Compras a Faturar  "
		BFQ->BFQ_SEQUEN  := "024"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "125"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "25"
		BFQ->BFQ_DESCRI  := STR0130 //"Taxas Compras a Faturar"
		BFQ->BFQ_SEQUEN  := "025"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "126"			// Nao esta sendo tratado pelo sistema.
		//       BFQ->BFQ_DESCRI  := "Renovacao de Contrato"
	ElseIf cCodigo == "127"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "27"
		BFQ->BFQ_DESCRI  := STR0131 //"Custo Operac. Serv. Acessorios"
		BFQ->BFQ_SEQUEN  := "027"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "1"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "128"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "28"
		BFQ->BFQ_DESCRI  := STR0132 //"Debito Serv. Acessorio"
		BFQ->BFQ_SEQUEN  := "028"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "129"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "29"
		BFQ->BFQ_DESCRI  := STR0133 //"Credito Serv Medicos"
		BFQ->BFQ_SEQUEN  := "029"
		BFQ->BFQ_DEBCRE  := "2"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "1"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "130"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "30"
		BFQ->BFQ_DESCRI  := STR0134 //"Credito Serv Acessorio"
		BFQ->BFQ_SEQUEN  := "030"
		BFQ->BFQ_DEBCRE  := "2"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "198"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "98"
		BFQ->BFQ_DESCRI  := STR0135 //"Valor Base de Imposto de Renda"
		BFQ->BFQ_SEQUEN  := "098"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "199"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "99"
		BFQ->BFQ_DESCRI  := STR0136 //"Imposto de Renda"
		BFQ->BFQ_SEQUEN  := "099"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "131"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "31"
		BFQ->BFQ_DESCRI  := STR0137 //"Credito Odontologico     "
		BFQ->BFQ_SEQUEN  := "031"
		BFQ->BFQ_DEBCRE  := "2"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "1"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "132"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "32"
		BFQ->BFQ_DESCRI  := STR0138 //"Debito Odontologico 	 "
		BFQ->BFQ_SEQUEN  := "032"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "1"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "133"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "33"
		BFQ->BFQ_DESCRI  := STR0139 //"Tx Adesao do Opcional "
		BFQ->BFQ_SEQUEN  := "033"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "134"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "34"
		BFQ->BFQ_DESCRI  := STR0140 //"Custo operacional outros servicos "
		BFQ->BFQ_SEQUEN  := "034"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "135"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "35"
		BFQ->BFQ_DESCRI  := STR0141 //"Debito outros servicos "
		BFQ->BFQ_SEQUEN  := "035"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "136"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "36"
		BFQ->BFQ_DESCRI  := STR0142 //"Credito outros servicos "
		BFQ->BFQ_SEQUEN  := "036"
		BFQ->BFQ_DEBCRE  := "2"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "137"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "37"
		BFQ->BFQ_DESCRI  := STR0143 //"Prod. de Coop./Pessoa Física (C.O.)"
		BFQ->BFQ_SEQUEN  := "037"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "138"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "38"
		BFQ->BFQ_DESCRI  := STR0144 //"Prod. de Coop./Pessoa Juridica (C.O.)"
		BFQ->BFQ_SEQUEN  := "038"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "139"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "39"
		BFQ->BFQ_DESCRI  := STR0145 //"Serv. Coop. PF Outras Operadoras (C.O.)"
		BFQ->BFQ_SEQUEN  := "039"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "140"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "40"
		BFQ->BFQ_DESCRI  := STR0146 //"Serv. Coop. PJ Outras Operadoras (C.O.)"
		BFQ->BFQ_SEQUEN  := "040"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "141"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "41"
		BFQ->BFQ_DESCRI  := STR0147 //"Serv. Aux. Diagn. Terapia (SADT) (C.O.)"
		BFQ->BFQ_SEQUEN  := "041"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "142"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "42"
		BFQ->BFQ_DESCRI  := STR0148 //"Serv. SADT outras Operadoras (C.O.)"
		BFQ->BFQ_SEQUEN  := "042"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "143"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "43"
		BFQ->BFQ_DESCRI  := STR0149 //"Prod. Nao Cooperado (C.O.)"
		BFQ->BFQ_SEQUEN  := "043"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "144"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "44"
		BFQ->BFQ_DESCRI  := STR0150 //"Prod. Nao Coop. Outras Operadoras (C.O.)"
		BFQ->BFQ_SEQUEN  := "044"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "145"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "45"
		BFQ->BFQ_DESCRI  := STR0151 //"Custos em Servicos Proprios (C.O.)"
		BFQ->BFQ_SEQUEN  := "045"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "146"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "46"
		BFQ->BFQ_DESCRI  := STR0152 //"Opcional Retroativo"
		BFQ->BFQ_SEQUEN  := "046"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "1"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "147"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "47"
		BFQ->BFQ_DESCRI  := STR0153 //"Prod. de Coop./P. F. (CO-P.)"
		BFQ->BFQ_SEQUEN  := "047"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "148"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "48"
		BFQ->BFQ_DESCRI  := STR0154 //"Prod. de Coop./P. J. (CO-P.)"
		BFQ->BFQ_SEQUEN  := "048"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "149"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "49"
		BFQ->BFQ_DESCRI  := STR0155 //"Serv. Coop.PF Outras Oper.(CO-P.)"
		BFQ->BFQ_SEQUEN  := "049"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "150"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "50"
		BFQ->BFQ_DESCRI  := STR0156 //"Serv. Coop.PJ Outras Oper.(CO-P.)"
		BFQ->BFQ_SEQUEN  := "050"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "151"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "51"
		BFQ->BFQ_DESCRI  := STR0157 //"Serv. Aux. (SADT) (CO-P.)"
		BFQ->BFQ_SEQUEN  := "051"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "152"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "52"
		BFQ->BFQ_DESCRI  := STR0158 //"Serv. SADT outras Oper.(CO-P.)"
		BFQ->BFQ_SEQUEN  := "052"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "153"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "53"
		BFQ->BFQ_DESCRI  := STR0159 //"Prod. Nao Cooperado (CO-P.)"
		BFQ->BFQ_SEQUEN  := "053"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "154"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "54"
		BFQ->BFQ_DESCRI  := STR0160 //"Prod. Nao Coop. Outras Oper.(CO-P.)"
		BFQ->BFQ_SEQUEN  := "054"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "155"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "55"
		BFQ->BFQ_DESCRI  := STR0161 //"Custos em Serv.Propr.(CO-P.)"
		BFQ->BFQ_SEQUEN  := "055"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "156"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "56"
		BFQ->BFQ_DESCRI  := STR0162 //"Taxa Custo Operac. Servicos Medicos"
		BFQ->BFQ_SEQUEN  := "056"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "1"
		BFQ->BFQ_TIPFAT	:= "1"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "157"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "57"
		BFQ->BFQ_DESCRI  := STR0163 //"Taxa Adm. Serv. Acessorios"
		BFQ->BFQ_SEQUEN  := "057"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "1"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "158"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "58"
		BFQ->BFQ_DESCRI  := STR0164 //"Taxa Outros Servicos "
		BFQ->BFQ_SEQUEN  := "058"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "159"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "59"
		BFQ->BFQ_DESCRI  := STR0165 //"Taxa Prod. Coop/PF (C.O.)"
		BFQ->BFQ_SEQUEN  := "059"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "160"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "60"
		BFQ->BFQ_DESCRI  := STR0166 //"Taxa Prod. Coop/PJ (C.O.)"
		BFQ->BFQ_SEQUEN  := "060"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "161"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "61"
		BFQ->BFQ_DESCRI  := STR0167 //"Taxa Serv Coop PF Outras Oper (CO)"
		BFQ->BFQ_SEQUEN  := "061"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "162"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "62"
		BFQ->BFQ_DESCRI  := STR0168 //"Taxa Serv Coop PJ Outras Oper (CO)"
		BFQ->BFQ_SEQUEN  := "062"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "163"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "63"
		BFQ->BFQ_DESCRI  := STR0169 //"Taxa Serv Aux Diagn Terapia (SADT) (CO)"
		BFQ->BFQ_SEQUEN  := "063"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "164"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "64"
		BFQ->BFQ_DESCRI  := STR0170 //"Taxa Serv SADT Outras Oper (CO)"
		BFQ->BFQ_SEQUEN  := "064"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "165"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "65"
		BFQ->BFQ_DESCRI  := STR0171 //"Taxa Prod Nao Cooperado (CO)"
		BFQ->BFQ_SEQUEN  := "065"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "166"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "66"
		BFQ->BFQ_DESCRI  := STR0172 //"Taxa Prod Nao Coop Outras Oper (CO)"
		BFQ->BFQ_SEQUEN  := "066"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "167"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "67"
		BFQ->BFQ_DESCRI  := STR0173 //"Taxa Custos Servicos Proprios (CO)"
		BFQ->BFQ_SEQUEN  := "067"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "168"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "68"
		BFQ->BFQ_DESCRI  := STR0174 //"Taxa Ft Moderador/Co-Participacao"
		BFQ->BFQ_SEQUEN  := "068"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "169"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "69"
		BFQ->BFQ_DESCRI  := STR0175 //"Taxa Prod. de Coop./P. F. (CO-P.)"
		BFQ->BFQ_SEQUEN  := "069"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "170"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "70"
		BFQ->BFQ_DESCRI  := STR0176 //"Taxa Prod. de Coop./P. J. (CO-P.)"
		BFQ->BFQ_SEQUEN  := "070"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "171"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "71"
		BFQ->BFQ_DESCRI  := STR0177 //"Taxa Serv. Coop.PF Outras Oper.(CO-P.)"
		BFQ->BFQ_SEQUEN  := "071"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "172"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "72"
		BFQ->BFQ_DESCRI  := STR0178 //"Taxa Serv. Coop.PJ Outras Oper.(CO-P.)"
		BFQ->BFQ_SEQUEN  := "072"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "173"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "73"
		BFQ->BFQ_DESCRI  := STR0179 //"Taxa Serv. Aux. (SADT) (CO-P.)"
		BFQ->BFQ_SEQUEN  := "073"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "174"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "74"
		BFQ->BFQ_DESCRI  := STR0180 //"Taxa Serv. SADT outras Oper.(CO-P.)"
		BFQ->BFQ_SEQUEN  := "074"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "175"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "75"
		BFQ->BFQ_DESCRI  := STR0181 //"Taxa Prod. Nao Cooperado (CO-P.)"
		BFQ->BFQ_SEQUEN  := "075"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "176"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "76"
		BFQ->BFQ_DESCRI  := STR0182 //"Taxa Prod. Nao Coop. Outras Oper.(CO-P.)"
		BFQ->BFQ_SEQUEN  := "076"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "177"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "77"
		BFQ->BFQ_DESCRI  := STR0183 //"Taxa Custos em Serv.Propr.(CO-P.)"
		BFQ->BFQ_SEQUEN  := "077"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())

	ElseIf cCodigo == "180"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "80"
		BFQ->BFQ_DESCRI  := STR0184 //"Deb. Serv. Med."
		BFQ->BFQ_SEQUEN  := "080"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "181"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "81"
		BFQ->BFQ_DESCRI  := STR0185 //"Deb. Parcelamento Co-Participação"
		BFQ->BFQ_SEQUEN  := "081"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "182" .and. cPaisLoc == "URU"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "82"
		BFQ->BFQ_DESCRI  := STR0233
		BFQ->BFQ_SEQUEN  := "082"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "183" .and. cPaisLoc == "URU"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "83"
		BFQ->BFQ_DESCRI  := STR0234
		BFQ->BFQ_SEQUEN  := "083"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "184"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "84"
		BFQ->BFQ_DESCRI  := STR0186 //"Gratuidade do Usuario"
		BFQ->BFQ_SEQUEN  := "084"
		BFQ->BFQ_DEBCRE  := "2"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "185"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "85"
		BFQ->BFQ_DESCRI  := "Co-Participação Reembolso"
		BFQ->BFQ_SEQUEN  := "085"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "1"
		BFQ->BFQ_ATIVO	:= "0"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf

		BFQ->(MsUnLock())

	ElseIf cCodigo == "186"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "86"
		BFQ->BFQ_DESCRI  := "Mensalidade Tab. Reemb Patronal"
		BFQ->BFQ_SEQUEN  := "086"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "1"
		BFQ->BFQ_ATIVO	:= "0"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf

		BFQ->(MsUnLock())

	ElseIf cCodigo == "188"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "88"
		BFQ->BFQ_DESCRI  := "Desconto mensalidade patrocinada"
		BFQ->BFQ_SEQUEN  := "088"
		BFQ->BFQ_DEBCRE  := "2"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_TIPFAT	:= "1"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "189"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "89"
		BFQ->BFQ_DESCRI  := STR0289 //"Acrescimo Familia/Usuario"
		BFQ->BFQ_SEQUEN  := "089"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "190"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "90"
		BFQ->BFQ_DESCRI  := STR0285 //"Diferenca Reajuste Mensalidade"
		BFQ->BFQ_SEQUEN  := "090"
		BFQ->BFQ_DEBCRE  := "1"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo == "191"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "91"
		BFQ->BFQ_DESCRI  := STR0288 //"Desconto Familia/Usuario"
		BFQ->BFQ_SEQUEN  := "091"
		BFQ->BFQ_DEBCRE  := "2"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "0"
		BFQ->BFQ_TIPFAT	:= "2"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	ElseIf cCodigo = "197"
		BFQ->(RecLock("BFQ",.T.))
		BFQ->BFQ_FILIAL  := xFilial("BFQ")
		BFQ->BFQ_CODINT  := cCodOpe
		BFQ->BFQ_PROPRI  := "1"
		BFQ->BFQ_CODLAN  := "97"
		BFQ->BFQ_DESCRI  := "Cred Pro-Rata Bloqueio Usuario"
		BFQ->BFQ_SEQUEN  := "097"
		BFQ->BFQ_DEBCRE  := "2"
		BFQ->BFQ_CONTAB  := "0"
		BFQ->BFQ_ATOCOO  := "1"
		BFQ->BFQ_TIPFAT	:= "1"
		BFQ->BFQ_ATIVO   := "1"
		If BFQ->(FieldPos("BFQ_FORCAL")) > 0
			BFQ->BFQ_FORCAL	:= "PLSVLRACU"
		EndIf
		BFQ->(MsUnLock())
	EndIf



Return

/*/{Protheus.doc} PL627SMF
Abre semaforo do faturamento...

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Static Function PL627SMF()
	LOCAL	_nH := ''

	IncProc(STR0187, .F.) //"Preparando ambiente de trabalho... Por favor, aguarde!"
	ProcessMessage()

	_nH := PLSAbreSem("PLSA627.SMF")

Return(_nH)

/*/{Protheus.doc} PL169GAUGE
Calcula tamanho da regua...

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Static Function PL169GAUGE(nTipo, aItens, nItens, cTipo, cFilBA3)
	LOCAL nGauge 	  := 0
	LOCAL nBDW_CODEMP := oBrwBDW:PLRETPOS("BDW_CODEMP")
	LOCAL nBDW_CONEMP := oBrwBDW:PLRETPOS("BDW_CONEMP")
	LOCAL nBDW_VERCON := oBrwBDW:PLRETPOS("BDW_VERCON")
	LOCAL nBDW_SUBCON := oBrwBDW:PLRETPOS("BDW_SUBCON")
	LOCAL nBDW_VERSUB := oBrwBDW:PLRETPOS("BDW_VERSUB")
	LOCAL nBDWCODEMF  := oBrwBDW:PLRETPOS("BDW_CODEMF")
	LOCAL nBDWCONEMF  := oBrwBDW:PLRETPOS("BDW_CONEMF")
	LOCAL nBDWVERCOF  := oBrwBDW:PLRETPOS("BDW_VERCOF")
	LOCAL nBDWSUBCOF  := oBrwBDW:PLRETPOS("BDW_SUBCOF")
	LOCAL nBDWVERSUF  := oBrwBDW:PLRETPOS("BDW_VERSUF")
	LOCAL aAuxEmp 	  := {}

	// Inicia a montar a quary principal para selecionar as familias...

	If nTipo == 1
		cSql := "SELECT DISTINCT(BA3_CODEMP) EMPRESA FROM "+RetSqlName("BA3")+", "+RetSqlName("BG9")+" "
	Else
		cSql := "SELECT COUNT(*) TOTAL FROM "+RetSqlName("BA3")+", "+RetSqlName("BG9")+" "
	EndIf

	// Tabelas de uso exclusivo para pessoa juridica...

	If cTipo == '1'
		cSql += ", "+RetSqlName("BT5")+", "+RetSqlName("BQC")+", "+RetSqlName("BT6")+" "
	EndIf

	// Inicializa montagem do filtro...

	cSql += "WHERE BA3_FILIAL = '"+ xFilial("BA3") + "' "
	cSql += "AND BG9_FILIAL = '"+ xFilial("BG9") + "' "
	cSql += "AND BA3_CODINT = BG9_CODINT "
	cSql += "AND BA3_CODEMP = BG9_CODIGO "

	// Filtro para pessoa juridica...

	If cTipo = '1'
		cSql += "AND BT5_FILIAL = '"+ xFilial("BT5") + "' "
		cSql += "AND BQC_FILIAL = '"+ xFilial("BQC") + "' "
		cSql += "AND BT6_FILIAL = '"+ xFilial("BT6") + "' "

		cSql += "AND BA3_CODINT = BT5_CODINT "
		cSql += "AND BA3_CODEMP = BT5_CODIGO "
		cSql += "AND BA3_CONEMP = BT5_NUMCON "
		cSql += "AND BA3_VERCON = BT5_VERSAO "

		cSql += "AND BA3_CODINT || BA3_CODEMP = BQC_CODIGO  "
		cSql += "AND BA3_CONEMP = BQC_NUMCON "
		cSql += "AND BA3_VERCON = BQC_VERCON "
		cSql += "AND BA3_SUBCON = BQC_SUBCON "
		cSql += "AND BA3_VERSUB = BQC_VERSUB "

		cSql += "AND BA3_CODINT = BT6_CODINT "
		cSql += "AND BA3_CODEMP = BT6_CODIGO "
		cSql += "AND BA3_CONEMP = BT6_NUMCON "
		cSql += "AND BA3_VERCON = BT6_VERCON "
		cSql += "AND BA3_SUBCON = BT6_SUBCON "
		cSql += "AND BA3_CODPLA = BT6_CODPRO "
		cSql += "AND BA3_VERSAO = BT6_VERSAO "
		cSql += "AND "+RetSqlName("BT6")+".D_E_L_E_T_ = ' ' "
		cSql += "AND "+RetSqlName("BT5")+".D_E_L_E_T_ = ' ' "
		cSql += "AND "+RetSqlName("BQC")+".D_E_L_E_T_ = ' ' "
	EndIf

	// Trata lote de renovacao...

	If BDC->( FieldPos("BDC_LOTREN") ) > 0
		If !Empty(M->BDC_LOTREN)
			cSql += "AND EXISTS (SELECT * FROM "+RetSqlName("BED")+" "
			cSql += " WHERE BED_FILIAL = '"+xFilial("BED")+"' "
			cSql += "AND BA3_CODINT = BED_CODINT "
			cSql += "AND BA3_CODEMP = BED_CODEMP "
			cSql += "AND BA3_MATRIC = BED_MATRIC "
			cSql += "AND BED_CDIDEN = '"+M->BDC_LOTREN+"' "
			cSql += "AND "+RetSqlName("BED")+".D_E_L_E_T_ = ' ' )"
		EndIf
	EndIf

	// Uso geral

	cSql += "AND "+RetSqlName("BA3")+".D_E_L_E_T_ = ' ' "
	cSql += "AND "+RetSqlName("BG9")+".D_E_L_E_T_ = ' ' "

	// Filtro para pessoa juridica... monta filtro informado na getdados...

	If cTipo == '1'  .and. Iif(BDC->( FieldPos("BDC_LOTREN") ) > 0,Empty(M->BDC_LOTREN),.T.)

		// Se for informado empresa...

		If ! Empty(aItens[nItens][nBDWCODEMF])
			cSql += "AND BA3_CODEMP >= '" + aItens[nItens][nBDW_CODEMP] + "' AND " +;
				"BA3_CODEMP <= '" + aItens[nItens][nBDWCODEMF] + "' "

		Elseif ! Empty(aItens[nItens][nBDW_CODEMP])
			cSql += "AND BA3_CODEMP = '" + aItens[nItens][nBDW_CODEMP] + "' "

		EndIf

		// Se for informado contrato...

		If ! Empty(aItens[nItens][nBDWCONEMF] + aItens[nItens][nBDWVERCOF])
			cSql += "AND (BA3_CONEMP >= '" + aItens[nItens][nBDW_CONEMP] + "' AND "+;
				"BA3_VERCON >= '" + aItens[nItens][nBDW_VERCON] + "') AND " +;
				"(BA3_CONEMP <= '" + aItens[nItens][nBDWCONEMF] + "' AND " +;
				"BA3_VERCON <= '" + aItens[nItens][nBDWVERCOF] + "') "
		ElseIf ! Empty(aItens[nItens][nBDW_CONEMP] + aItens[nItens][nBDW_VERCON])
			cSql += "AND BA3_CONEMP = '" + aItens[nItens][nBDW_CONEMP] + "' AND " +;
				"BA3_VERCON = '" + aItens[nItens][nBDW_VERCON] + "' "
		EndIf

		// Se for informado sub contrato...

		If ! Empty(aItens[nItens][nBDWSUBCOF] + aItens[nItens][nBDWVERSUF])
			cSql += "AND (BA3_SUBCON >= '" + aItens[nItens][nBDW_SUBCON] + "' AND "+;
				"BA3_VERSUB >= '" + aItens[nItens][nBDW_VERSUB] + "') AND " +;
				"(BA3_SUBCON <= '" + aItens[nItens][nBDWSUBCOF] + "' AND " +;
				"BA3_VERSUB <= '" + aItens[nItens][nBDWVERSUF] + "') "
		ElseIf ! Empty(aItens[nItens][nBDW_SUBCON] + aItens[nItens][nBDW_VERSUB])
			cSql += "AND BA3_SUBCON = '" + aItens[nItens][nBDW_SUBCON] + "' AND " +;
				"BA3_VERSUB = '" + aItens[nItens][nBDW_VERSUB] + "' "
		EndIf

		// Somente pessoa juridica...

		cSql += "AND BA3_TIPOUS = '2' "
		cSql += "AND BA3_CODINT = '"+M->BDC_CODOPE+"' "

		// Filtra por grupo de cobranca...

		If !Empty(M->BDC_GRPCOB)
			cSql += "AND BA3_GRPCOB = '"+M->BDC_GRPCOB+"' "
		EndIf

		If ! Empty(cFilBA3)
			cSql += " AND (" + PlsParSql(cFilBA3) + ") "
		EndIf

	Elseif cTipo == '2' .And. Iif(BDC->( FieldPos("BDC_LOTREN") ) > 0, Empty(M->BDC_LOTREN), .T.)

		// Filtra exclusivo para pessoa fisica...

		If ! Empty(cFilBA3)
			cSql += " AND (" + PlsParSql(cFilBA3) + ") "
		EndIf

		cSql += "AND BA3_VENCTO >= " + AllTrim(Str(M->BDC_VENINI)) + " AND "
		cSql += "BA3_VENCTO <= " + AllTrim(Str(M->BDC_VENFIM)) + " AND "
		cSql += "BA3_TIPOUS = '1' "

		If  BDC->(FieldPos("BDC_CARIMP")) > 0
			If  ! empty(M->BDC_CARIMP)
				cSql += " AND BA3_CARIMP = '" + M->BDC_CARIMP + "' "
			EndIf
		EndIf

		// Filtra por grupo de cobranca...

		If !Empty(M->BDC_GRPCOB)
			cSql += "AND BA3_GRPCOB = '"+M->BDC_GRPCOB+"' "
		EndIf
	EndIf

	// Ordena por empresas...

	If nTipo == 1
		cSql += "ORDER BY BA3_CODEMP "
	EndIf

	// Faz o parce para oracle...

	cSql := StrTran(cSql,"DTOS(", "(" )
	cSql := StrTran(cSql,"DTOC(", "(" )
	cSql := StrTran(cSql,"CTOD(", "(" )

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"GAUGE",.F.,.T.)

	If nTipo == 1
		GAUGE->( dbEval({|| nGauge ++, Aadd(aAuxEmp, GAUGE->EMPRESA) }) )
	Else
		nGauge := GAUGE->TOTAL
	EndIf

	GAUGE->( dbClosearea() )



Return(nGauge)

/*/{Protheus.doc} PLSLGCOB
Retorna conteudo do paramentro que ativa/desativa o LOG do faturamento.

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLSLGCOB()
Return(GetNewPar("MV_PLSXCOB","0")=="1")

/*/{Protheus.doc} PL627CDTIT

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PL627CDTIT(cPrefixo,cChave)
	LOCAL cNumero 	:= ""
	LOCAL cTabCont  := ""
	LOCAL cPreOld	:= ""
	LOCAL cTpNrNfs 	:= SuperGetMV("MV_TPNRNFS")
	LOCAL nLenSE1N  := 0
	LOCAL cAliTp  	:= ""
	DEFAULT cChave  := ""

	// Pais

	If ( cPaisLoc == "BRA" .And. GetNewPar("MV_PLSNFBR","0")=="0" ) .Or. AllTrim(cPrefixo) == "TAX"
		cTabCont := "BK"
		cAliTp   := "PLS"
	Else
		cTabCont := "01"
		cAliTp   := "NFF"
	EndIf

	// Numero do titulo

	cNumero := NxtSX5Nota(cPrefixo,.T.,cTpNrNfs,nil,cTabCont,cAliTp)

	// Outro pais

	If cPaisLOC == "URU"

		// Tamanho do titulo

		nLenSE1N := TamSX3("F2_DOC")[1]

		// Checagem para saber se a sequencia esta na ultima contagem e iniciar novamente
		// A0001 ATE A9999 nova sequencia B0001 ATE B9999 assim por diante

		If cNumero > Replicate( "9",nLenSE1N )
			cPreOld	 := cPrefixo + Space( 3-Len(cPrefixo) )
			cPrefixo := Soma1( AllTrim(cPrefixo) ) + Space( 3-Len(cPrefixo) )

			// Caso exista a necessidade de somar um ao prefixo deve ser atualizado os paramentros

			PutMvPar( "MV_ESSER11", cPrefixo )
			PutMvPar( "MV_ESPECIE", StrTran( GetMV("MV_ESPECIE") , cPreOld, cPrefixo) )

			// Proximo Numero

			cNumero := NxtSX5Nota(cPrefixo,.T.,cTpNrNfs)
		EndIf
	EndIf



Return(cNumero)

/*/{Protheus.doc} PLSCRIABFQ
Cria BFQ se nao existir

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLSCRIABFQ()
	LOCAL nFor

	// Atualiza cadastro de lanc. de faturamento...

	For nFor := 100 To 200
		BFQ->(DbSetOrder(1))
		If ! BFQ->(msSeek(xFilial("BFQ")+PlsIntPad()+StrZero(nFor,3)))
			PLSINCBFQ(StrZero(nFor,3),PlsIntPad())
		EndIf
	Next




Return

/*/{Protheus.doc} PL627BXCAN
Executa baixa de titulos por cancelamento quando o titulo nao puder ser excluido.

@author  PLS TEAM
@version P12
@since   07/03/05
/*/
Function PL627BXCAN(lCtbBaixa)

	Private cNumTit := SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA
	Private dBaixa := If(dDataBase < SE1->E1_EMISSAO, SE1->E1_EMISSAO, dDatabase)
	Private cTipo := SE1->E1_TIPO
	Private cNsNum := " "
	Private dDataCred := SE1->E1_EMISSAO
	Private nDespes := 0
	Private nDescont := 0
	Private nValRec := SE1->E1_SALDO
	Private nJuros := 0
	Private nMulta := 0
	Private nCM := 0
	Private nAcresc := 0
	Private nDescresc := 0
	Private nTotAbat := 0
	Private cLoteFin := ""
	Private cMarca := ""
	Private cMotBx := GetNewPar("MV_PLMOTBC","CAN")
	Private cHist070 := STR0188 //"Titulo cancelado pelo Plano de Saude."
	Private cBanco := ""
	Private cAgencia := ""
	Private cConta := ""
	Private nValEstrang
	Private lRaRtImp := lFinImp .And. FRaRtImp()

	//NAO RETIRAR ESSA VARIAVEL DAQUI,ELA EH USADA DENTRO DO FINA070...
	nValEstrang := 0

	//Testa integridade do titulo...
	if !SE1->(Deleted()) .And. SE1->(!Eof())

		//Baixa titulo no Contas a Receber
		fA070Grv(lCtbBaixa, .F., lCtbBaixa, cNsNum, .F., dDataBase, .F., "", "", nil)

		SE1->(RecLock("SE1",.F.))

		If Alltrim(SE1->E1_ORIGEM) == 'PLSA090'
			SE1->E1_HIST := 'PL627BXCAN->' + STR0284    //Guia compra proced. Exc.
		Else
			SE1->E1_HIST := "PL627BXCAN-> Baixa por Cancelamento"
		EndIf

		SE1->(MsUnLock())

		//Ponto de entrada após a Baixa titulo no Contas a Receber
		If ExistBlock("PL627CAN")
			ExecBlock("PL627CAN", .F., .F.)
		EndIf

	EndIf

Return()

/*/{Protheus.doc} PL627HSBM1
Grava historico da composicao da cobranca quando o sistema
estiver utilizando controle de numeracao do titulo e o
titulo nao puder ser excluido sendo baixado por cancelamento

@author  PLS TEAM
@version P11
@since   04.01.05
/*/
Function PL627HSBM1(cPrefixo, cTitulo, cParcela, cTipo, cNumCob)
	local i			 := 0
	local cCpoBM1    := ''
	local cCpoBMN    := ''
	local cChave	 := ''
	local cChvMac	 := ''
	local lMVPLSGRHI := getNewPar("MV_PLSGRHI", '0') == '1'

	default cPrefixo := ''
	default cTitulo	 := ''
	default cParcela := ''
	default cTipo	 := ''

	if lMVPLSGRHI

		if ! empty(cTitulo)
			BM1->( dbSetorder(04) ) //BM1_FILIAL+BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL+BM1_TIPTIT+BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG+BM1_CODTIP
			cChave  := cPrefixo + cTitulo + cParcela + cTipo
			cChvMac := 'BM1->(BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL+BM1_TIPTIT)'
		else
			BM1->( dbSetorder(08) ) //BM1_FILIAL+BM1_PLNUCO+BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL+BM1_TIPTIT+BM1_NIVCOB
			cChave  := cNumCob
			cChvMac := 'BM1->BM1_PLNUCO'
		endIf

		if BM1->( msSeek( xFilial("BM1") + cChave ) )

			while !BM1->( eof() ) .and. &cChvMac == cChave

				BMN->( recLock("BMN", .t.) )

				for i := 1 to BM1->( fCount() )

					cCpoBM1 := BM1->( Field(i) )
					cCpoBMN	:= StrTran(cCpoBM1, "BM1", "BMN")

					if BMN->( fieldPos(cCpoBMN) ) > 0

						cCpoBMN	 := "BMN->" + cCpoBMN
						&cCpoBMN := BM1->( fieldGet(i) )

					endIf

				next

				BMN->( msUnlock() )

				BM1->( dbSkip() )
			endDo

		endIf

	endIf

return()

/*/{Protheus.doc} PL627LDSMF

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Static Function PL627LDSMF()
Return((GetNewPar("MV_PLSSMFT", '0')=='1').and. !IsInCallStack("PLSA001"))

/*/{Protheus.doc} PLS627CHK
 Verifica integridade dos valores do lote de cobranca

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLS627CHK(nRecno,lMsg)
	LOCAL aCritica 	:= {}
	LOCAL cPictTit	:= "@R "+	Replicate("!",TamSX3("E1_PREFIXO")[1])+;
		Replicate("!",TamSX3("E1_NUM")[1])+;
		Replicate("!",TamSX3("E1_PARCELA")[1])+;
		Replicate("!",TamSX3("E1_TIPO")[1])

	LOCAL aCabec := { {STR0189	,cPictTit,60},; //"Titulo"
		{STR0190	,"@R !!!!.!!!!.!!!!!!.!!",60},; //"Matricula"
		{STR0191 ,"@!",20},; //"Ano"
		{STR0192 ,"@!",20},; //"Mes"
		{STR0193 ,"@!",35},; //"Analise"
		{STR0194 ,"@!",25},; //"Lancto"
		{STR0195 ,"@!",25},; //"Seq"
		{STR0217 + " BM1","@E 999,999,999.9999",40},; //"Total"
		{STR0217 + " BDH","@E 999,999,999.9999",40},; //"Total"
		{STR0217 + " BD6","@E 999,999,999.9999",40},; //"Total"
		{STR0217 + " SE1","@E 999,999,999.9999",40},; //"Total"
		{STR0218,"@E 999,999,999.9999",40} } //"Diferenca"
	Default lMsg := .T.

	// Verifica se foi criado indice

	If  ! SIX->(msSeek("BDH8"))
		If  lMsg
			MsgAlert(STR0196 + chr(13) + ; //"Favor criar o indice 8 na tabela BDH, com os seguintes campos: "
				"BDH_FILIAL + BDH_PREFIX + BDH_NUMTIT + BDH_PARCEL + BDH_TIPTIT + BDH_CODINT + BDH_CODEMP + BDH_MATRIC + " + chr(13) + ;
				"BDH_TIPREG + BDH_ANOFT + BDH_MESFT + BDH_SEQPF")
		EndIf
		Return()
	EndIf

	// Analisa integridade do lote de cobranca

	msAguarde( { || P627CHKLT(@aCritica,nRecno) }, STR0197, STR0198, .T. ) //"Aguarde..."###"Analisando divergencias do lote de cobranca ..."

	// Exibe mensagem com resultado da analise

	If Len(aCritica) > 0
		PlsCriGen(aCritica, aCabec, STR0199 + BDC->BDC_NUMERO) //"Analise de Divergencias - lote: "
	Else
		If lMsg
			MsgAlert(STR0200)	 //"Nenhuma divergencia encontrada neste lote."
		EndIf
	EndIf



Return()

/*/{Protheus.doc} P627CHKLT
Verifica integridade dos valores do lote de cobranca

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Static Function P627CHKLT(aCritica,nRecno)
	LOCAL i := 0

	// Posiciona BBT-Complemento do Titulo a Receber

	BDC->( DbGoTo(nRecno) )
	BBT->( DbSetOrder(8) )
	BBT->( msSeek(xFilial("BBT")+BDC->(BDC_CODOPE+BDC_NUMERO)) )

	// Processa cada registro do BBT-Complemento do Titulo a Receber

	While !BBT->( Eof() ) .And. BBT->(BBT_FILIAL+BBT_NUMCOB) == xFilial("BBT")+BDC->(BDC_CODOPE+BDC_NUMERO)

		// Mensagem de processamento

		MsProcTxt( STR0201 + BBT->(BBT_PREFIX+" "+BBT_NUMTIT+" "+BBT_PARCEL+" "+BBT_TIPTIT))  //"Analisando titulo "

		// Atualiza array com criticas
		aRet := P627CHSE1( BBT->(BBT_PREFIX+BBT_NUMTIT+BBT_PARCEL+BBT_TIPTIT) )

		If  ! aRet[1]
			For i := 1 to len(aRet[2])
				AaDd(aCritica,aRet[2,i])
			Next
		EndIf

		// Acessa proximo registro
		BBT->( DbSkip() )
	EndDo



Return()

/*/{Protheus.doc} P627CHBDH
Verifica integridade dos valores de cobranca Tabelas analisadas: BDH x BD6

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function P627CHBDH(cMat,cAno,cMes,lFat,cTitulo)
	LOCAL cCodInt   := substr(cMat, 1,4)
	LOCAL cCodEmp   := substr(cMat, 5,4)
	LOCAL cMatric   := substr(cMat, 9,6)
	LOCAL cTipReg   := substr(cMat,15,2)
	LOCAL nTotBDH   := 0
	LOCAL nTotBD6   := 0
	LOCAL lRet      := .T.
	LOCAL aRet      := {}
	LOCAL aCritica  := {}
	LOCAL nDifMin   := GetNewPar("MV_PLSDIFA",0.01)

	// Posiciona BDH

	BDH->(dbSetOrder(1))
	BDH->(msSeek(xFilial("BDH")+cCodInt+cCodEmp+cMatric+cTipReg+cAno+cMes))

	// Analisa cada BDH

	While ! BDH->(Eof()) .And. BDH->(BDH_FILIAL+BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT) == ;
			xFilial("BDH")+cCodInt+cCodEmp+cMatric+cTipReg+cAno+cMes

		// Bypassa BDH

		If  lFat .and. BDH->BDH_STATUS <> "0"
			BDH->(dbSkip())
			Loop
		EndIf
		If  ! lFat .and. BDH->BDH_STATUS == "0"
			BDH->(DbSkip())
			Loop
		EndIf
		If  !Empty(cTitulo) .and. BDH->(BDH_PREFIX+BDH_NUMTIT+BDH_PARCEL+BDH_TIPTIT) <> cTitulo
			BDH->(DbSkip())
			Loop
		EndIf

		// Calcula totais do BDH x BD6

		aRet    := P627TTBDH(BDH->(RecNo()),cTitulo)
		nTotBDH := aRet[1]
		nTotBD6 := aRet[2]

		// Verifica se houve diferenca

		If  abs(nTotBD6 - nTotBDH) >= nDifMin
			lRet := .F.
			aadd(aCritica,{BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_SEQPF),;
				BDH->BDH_ANOFT,;
				BDH->BDH_MESFT,;
				BDH->BDH_SEQPF,;
				nTotBDH,;
				nTotBD6,;
				nTotBDH-nTotBD6})
		EndIf

		// Acessa proximo registro

		BDH->(dbSkip())
	Enddo



Return({lRet,aCritica})

/*/{Protheus.doc} P627CHSE1
Verifica integridade dos valores de cobranca
           Tabelas analisadas: SE1 x BM1 x BDH
@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function P627CHSE1(cTitulo)
	LOCAL nTotSE1   := 0
	LOCAL nTotBM1   := 0
	LOCAL nTotBDH   := 0
	LOCAL nTotBD6   := 0
	LOCAL nPos		:= 0
	LOCAL cMatant   := ""
	LOCAL lRet      := .T.
	LOCAL lTemReem  := .F.
	LOCAL aRet      := {}
	LOCAL aCritica  := {}
	LOCAL aBM1      := {}
	LOCAL nDifMin   := GetNewPar("MV_PLSDIFA",0.01)
	LOCAL lGerNFBRA	:= ( GetNewPar("MV_PLSNFBR","0") == "1" .Or. cPaisLOC <> 'BRA' )
	LOCAL lNcc		:= GetNewPar("MV_PLGENCC","0") <> '0'

	// Posiciona SE1

	SE1->( dbSetOrder(1) )
	If SE1->( msSeek(xFilial("SE1")+cTitulo) )

		// Calcula valor total do SE1

		If cPaisLOC <> 'BRA'
			SF2->( DbSetOrder(1) )
			If SF2->(DbSeek(xFilial("SF2")+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA)))
				If SuperGetMV('MV_DESCSAI')=='1'
					nTotSE1 := ( (SF2->F2_VALFAT)-(SF2->(round(F2_VALIMP1,2)+round(F2_VALIMP2,2)+round(F2_VALIMP3,2)+round(F2_VALIMP4,2)+round(F2_VALIMP5,2)+round(F2_VALIMP6,2))) )-SF2->F2_DESCONT
				Else
					nTotSE1 := ( (SF2->F2_VALFAT)-(SF2->(round(F2_VALIMP1,2)+round(F2_VALIMP2,2)+round(F2_VALIMP3,2)+round(F2_VALIMP4,2)+round(F2_VALIMP5,2)+round(F2_VALIMP6,2))) )
				EndIf
			EndIf
		Else
			nTotSE1 := SE1->E1_VALOR
			If GetNewPar('MV_TPABISS','1')=='1'
				SF2->( DbSetOrder(1) )
				If SF2->(DbSeek(xFilial("SF2")+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA))) .And. SF2->F2_RECISS=='1'
					nTotSE1 += SF2->F2_VALISS
				Endif
			Endif
		EndIf

		// Calcula valor do BM1

		BM1->( dbSetOrder(4) )
		If BM1->( msSeek(xFilial("BM1")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)) )
			While !BM1->( Eof() ) .And. BM1->(BM1_FILIAL+BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL+BM1_TIPTIT) == xFilial("BM1")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)

				// Inicializa variaveis

				cMatant := BM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG)
				aBM1    := {}

				// Processa cada registro do BM1

				While ! BM1->(Eof()) .And. BM1->(BM1_FILIAL+BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL+BM1_TIPTIT+BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG) == xFilial("BM1")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)+cMatant

					// Acumula total do BM1

					If  BM1->BM1_TIPO == "1"
						nTotBM1 += BM1->BM1_VALOR
					ElseIf lNcc // Como Ja foi descontado a NCC no valor total não precisa somar
						nTotBM1 -= BM1->BM1_VALOR
					EndIf
					If BM1->BM1_CODTIP == '108'
						lTemReem := .T.
					EndIf

					// Monta array com os tipos de lancamentos encontrados no BM1

					If  BM1->BM1_CODTIP $ cCodigosPF
						nPos := aScan(aBM1,{|x| x[3] == BM1->BM1_CODTIP})
						If  nPos == 0
							AaDd(aBM1,{BM1->BM1_ANO,BM1->BM1_MES,BM1->BM1_CODTIP,BM1->BM1_VALOR,0})
						Else
							aBM1[nPos,4] += BM1->BM1_VALOR
						EndIf
					EndIf

					// Acessa proximo registro

					BM1->( dbSkip() )
				EndDo

				// Verifica se houve algum BM1 que possua BDH

				If Len(aBM1) > 0

					// Posiciona BDH

					BDH->(dbSetOrder(8))
					BDH->(msSeek(xFilial("BDH")+cTitulo+cMatant))

					// Analisa cada BDH

					While ! BDH->(Eof()) .And. BDH->(BDH_FILIAL+BDH_PREFIX+BDH_NUMTIT+BDH_PARCEL+BDH_TIPTIT+BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG) == xFilial("BDH")+cTitulo+cMatant

						// Calcula valor total do BDH por tipo de lancamento

						If  BDH->(FieldPos("BDH_VALOR ")) > 0 ; cCodTip := "116" ; nValor := BDH->BDH_VALOR  ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VALOR1")) > 0 ; cCodTip := "147" ; nValor := BDH->BDH_VALOR1 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VALOR2")) > 0 ; cCodTip := "148" ; nValor := BDH->BDH_VALOR2 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VALOR3")) > 0 ; cCodTip := "149" ; nValor := BDH->BDH_VALOR3 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VALOR4")) > 0 ; cCodTip := "150" ; nValor := BDH->BDH_VALOR4 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VALOR5")) > 0 ; cCodTip := "151" ; nValor := BDH->BDH_VALOR5 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VALOR6")) > 0 ; cCodTip := "152" ; nValor := BDH->BDH_VALOR6 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VALOR7")) > 0 ; cCodTip := "153" ; nValor := BDH->BDH_VALOR7 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VALOR8")) > 0 ; cCodTip := "154" ; nValor := BDH->BDH_VALOR8 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VALOR9")) > 0 ; cCodTip := "155" ; nValor := BDH->BDH_VALOR9 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRCOP")) > 0 ; cCodTip := "104" ; nValor := BDH->BDH_VLRCOP ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRTAX")) > 0 ; cCodTip := "117" ; nValor := BDH->BDH_VLRTAX ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VALCPF")) > 0 ; cCodTip := "124" ; nValor := BDH->BDH_VALCPF ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VALCOF")) > 0 ; cCodTip := "123" ; nValor := BDH->BDH_VALCOF ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VALTCF")) > 0 ; cCodTip := "125" ; nValor := BDH->BDH_VALTCF ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRCP2")) > 0 ; cCodTip := "127" ; nValor := BDH->BDH_VLRCP2 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRCP3")) > 0 ; cCodTip := "134" ; nValor := BDH->BDH_VLRCP3 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRCP4")) > 0 ; cCodTip := "137" ; nValor := BDH->BDH_VLRCP4 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRCP5")) > 0 ; cCodTip := "138" ; nValor := BDH->BDH_VLRCP5 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRCP6")) > 0 ; cCodTip := "139" ; nValor := BDH->BDH_VLRCP6 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRCP7")) > 0 ; cCodTip := "140" ; nValor := BDH->BDH_VLRCP7 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRCP8")) > 0 ; cCodTip := "141" ; nValor := BDH->BDH_VLRCP8 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRCP9")) > 0 ; cCodTip := "142" ; nValor := BDH->BDH_VLRCP9 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRCPA")) > 0 ; cCodTip := "143" ; nValor := BDH->BDH_VLRCPA ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRCPB")) > 0 ; cCodTip := "144" ; nValor := BDH->BDH_VLRCPB ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRCPC")) > 0 ; cCodTip := "145" ; nValor := BDH->BDH_VLRCPC ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT11")) > 0 ; cCodTip := "156" ; nValor := BDH->BDH_VLRT11 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT12")) > 0 ; cCodTip := "157" ; nValor := BDH->BDH_VLRT12 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT13")) > 0 ; cCodTip := "158" ; nValor := BDH->BDH_VLRT13 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT14")) > 0 ; cCodTip := "159" ; nValor := BDH->BDH_VLRT14 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT15")) > 0 ; cCodTip := "160" ; nValor := BDH->BDH_VLRT15 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT16")) > 0 ; cCodTip := "161" ; nValor := BDH->BDH_VLRT16 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT17")) > 0 ; cCodTip := "162" ; nValor := BDH->BDH_VLRT17 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT18")) > 0 ; cCodTip := "163" ; nValor := BDH->BDH_VLRT18 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT19")) > 0 ; cCodTip := "164" ; nValor := BDH->BDH_VLRT19 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT1A")) > 0 ; cCodTip := "165" ; nValor := BDH->BDH_VLRT1A ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT1B")) > 0 ; cCodTip := "166" ; nValor := BDH->BDH_VLRT1B ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT1C")) > 0 ; cCodTip := "167" ; nValor := BDH->BDH_VLRT1C ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT21")) > 0 ; cCodTip := "168" ; nValor := BDH->BDH_VLRT21 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT24")) > 0 ; cCodTip := "169" ; nValor := BDH->BDH_VLRT24 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT25")) > 0 ; cCodTip := "170" ; nValor := BDH->BDH_VLRT25 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT26")) > 0 ; cCodTip := "171" ; nValor := BDH->BDH_VLRT26 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT27")) > 0 ; cCodTip := "172" ; nValor := BDH->BDH_VLRT27 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT28")) > 0 ; cCodTip := "173" ; nValor := BDH->BDH_VLRT28 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT29")) > 0 ; cCodTip := "174" ; nValor := BDH->BDH_VLRT29 ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT2A")) > 0 ; cCodTip := "175" ; nValor := BDH->BDH_VLRT2A ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT2B")) > 0 ; cCodTip := "176" ; nValor := BDH->BDH_VLRT2B ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRT2C")) > 0 ; cCodTip := "177" ; nValor := BDH->BDH_VLRT2C ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRTIM")) > 0 ; cCodTip := "182" ; nValor := BDH->BDH_VLRTIM ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf
						If  BDH->(FieldPos("BDH_VLRPES")) > 0 ; cCodTip := "183" ; nValor := BDH->BDH_VLRPES ; P627TTBM1(cCodTip,nValor,@aBM1) ; EndIf

						// Calcula valor total do BDH

						aRet    := P627TTBDH(BDH->(RecNo()),cTitulo)
						nTotBDH := aRet[1]
						nTotBD6 := aRet[2]
						// Verifica se houve diferenca - BDH x BD6

						If  abs(nTotBDH - nTotBD6) >= nDifMin
							lRet := .F.
							AaDd(aCritica,{	cTitulo,;
								cMatant,;
								BDH->BDH_ANOFT,;
								BDH->BDH_MESFT,;
								"BDH x BD6",;
								"",;
								BDH->BDH_SEQPF,;
								0,;
								nTotBDH,;
								nTotBD6,;
								0,;
								nTotBDH-nTotBD6})
						EndIf
						// Acessa proximo registro

						BDH->( dbSkip() )
					EndDo

					// Verifica se houve diferenca - BM1 x BDH

					For nPos := 1 to len(aBM1)
						If  abs(aBM1[nPos,4] - aBM1[nPos,5]) >= nDifMin
							AaDd(aCritica,{	cTitulo,;
								cMatant,;
								aBM1[nPos,1],;
								aBM1[nPos,2],;
								"BM1 x BDH",;
								aBM1[nPos,3],;
								"",;
								aBM1[nPos,4],;
								aBM1[nPos,5],;
								0,;
								0,;
								aBM1[nPos,4] - aBM1[nPos,5]})
						EndIf
					Next
				EndIf
			EndDo
		Else
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "BM1 - Nao encontrado com base no SE1 ["+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)+"]", 0, 0, {})
		EndIf

		// Verifica se houve diferenca - SE1 x BM1

		If abs(nTotSE1 - nTotBM1) >= nDifMin .And. SE1->E1_TIPO <> "NCC"
			lRet := .F.
			AaDd(aCritica,{	SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO),;
				"",;
				"",;
				"",;
				"SE1 x BM1",;
				"",;
				"",;
				nTotBM1,;
				0,;
				0,;
				nTotSE1,;
				nTotBM1-nTotSE1})
		EndIf
	EndIf



Return( {lRet,aCritica} )

/*/{Protheus.doc} P627CHSE1
Calcula totais do BDH x BD6

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function P627TTBDH(nRecno,cTitulo)
	LOCAL nTotBDH   := 0
	LOCAL nTotBD6   := 0
	LOCAL cKeyBDH 	:= ""
	LOCAL cKeyBD6 	:= ""
	LOCAL nOrdem	:= 12

	// Posiciona BDH

	BDH->(dbGoTo(nRecno))

	// Calcula valor total do BDH

	If  BDH->(FieldPos("BDH_VALOR ")) > 0 ; nTotBDH += BDH->BDH_VALOR  ; EndIf
	If  BDH->(FieldPos("BDH_VALOR1")) > 0 ; nTotBDH += BDH->BDH_VALOR1 ; EndIf
	If  BDH->(FieldPos("BDH_VALOR2")) > 0 ; nTotBDH += BDH->BDH_VALOR2 ; EndIf
	If  BDH->(FieldPos("BDH_VALOR3")) > 0 ; nTotBDH += BDH->BDH_VALOR3 ; EndIf
	If  BDH->(FieldPos("BDH_VALOR4")) > 0 ; nTotBDH += BDH->BDH_VALOR4 ; EndIf
	If  BDH->(FieldPos("BDH_VALOR5")) > 0 ; nTotBDH += BDH->BDH_VALOR5 ; EndIf
	If  BDH->(FieldPos("BDH_VALOR6")) > 0 ; nTotBDH += BDH->BDH_VALOR6 ; EndIf
	If  BDH->(FieldPos("BDH_VALOR7")) > 0 ; nTotBDH += BDH->BDH_VALOR7 ; EndIf
	If  BDH->(FieldPos("BDH_VALOR8")) > 0 ; nTotBDH += BDH->BDH_VALOR8 ; EndIf
	If  BDH->(FieldPos("BDH_VALOR9")) > 0 ; nTotBDH += BDH->BDH_VALOR9 ; EndIf
	If  BDH->(FieldPos("BDH_VLRCOP")) > 0 ; nTotBDH += BDH->BDH_VLRCOP ; EndIf
	If  BDH->(FieldPos("BDH_VLRTAX")) > 0 ; nTotBDH += BDH->BDH_VLRTAX ; EndIf
	If  BDH->(FieldPos("BDH_VALCPF")) > 0 ; nTotBDH += BDH->BDH_VALCPF ; EndIf
	If  BDH->(FieldPos("BDH_VALCOF")) > 0 ; nTotBDH += BDH->BDH_VALCOF ; EndIf
	If  BDH->(FieldPos("BDH_VALTCF")) > 0 ; nTotBDH += BDH->BDH_VALTCF ; EndIf
	If  BDH->(FieldPos("BDH_VLRCP2")) > 0 ; nTotBDH += BDH->BDH_VLRCP2 ; EndIf
	If  BDH->(FieldPos("BDH_VLRCP3")) > 0 ; nTotBDH += BDH->BDH_VLRCP3 ; EndIf
	If  BDH->(FieldPos("BDH_VLRCP4")) > 0 ; nTotBDH += BDH->BDH_VLRCP4 ; EndIf
	If  BDH->(FieldPos("BDH_VLRCP5")) > 0 ; nTotBDH += BDH->BDH_VLRCP5 ; EndIf
	If  BDH->(FieldPos("BDH_VLRCP6")) > 0 ; nTotBDH += BDH->BDH_VLRCP6 ; EndIf
	If  BDH->(FieldPos("BDH_VLRCP7")) > 0 ; nTotBDH += BDH->BDH_VLRCP7 ; EndIf
	If  BDH->(FieldPos("BDH_VLRCP8")) > 0 ; nTotBDH += BDH->BDH_VLRCP8 ; EndIf
	If  BDH->(FieldPos("BDH_VLRCP9")) > 0 ; nTotBDH += BDH->BDH_VLRCP9 ; EndIf
	If  BDH->(FieldPos("BDH_VLRCPA")) > 0 ; nTotBDH += BDH->BDH_VLRCPA ; EndIf
	If  BDH->(FieldPos("BDH_VLRCPB")) > 0 ; nTotBDH += BDH->BDH_VLRCPB ; EndIf
	If  BDH->(FieldPos("BDH_VLRCPC")) > 0 ; nTotBDH += BDH->BDH_VLRCPC ; EndIf
	If  BDH->(FieldPos("BDH_VLRT11")) > 0 ; nTotBDH += BDH->BDH_VLRT11 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT12")) > 0 ; nTotBDH += BDH->BDH_VLRT12 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT13")) > 0 ; nTotBDH += BDH->BDH_VLRT13 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT14")) > 0 ; nTotBDH += BDH->BDH_VLRT14 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT15")) > 0 ; nTotBDH += BDH->BDH_VLRT15 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT16")) > 0 ; nTotBDH += BDH->BDH_VLRT16 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT17")) > 0 ; nTotBDH += BDH->BDH_VLRT17 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT18")) > 0 ; nTotBDH += BDH->BDH_VLRT18 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT19")) > 0 ; nTotBDH += BDH->BDH_VLRT19 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT1A")) > 0 ; nTotBDH += BDH->BDH_VLRT1A ; EndIf
	If  BDH->(FieldPos("BDH_VLRT1B")) > 0 ; nTotBDH += BDH->BDH_VLRT1B ; EndIf
	If  BDH->(FieldPos("BDH_VLRT1C")) > 0 ; nTotBDH += BDH->BDH_VLRT1C ; EndIf
	If  BDH->(FieldPos("BDH_VLRT21")) > 0 ; nTotBDH += BDH->BDH_VLRT21 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT24")) > 0 ; nTotBDH += BDH->BDH_VLRT24 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT25")) > 0 ; nTotBDH += BDH->BDH_VLRT25 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT26")) > 0 ; nTotBDH += BDH->BDH_VLRT26 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT27")) > 0 ; nTotBDH += BDH->BDH_VLRT27 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT28")) > 0 ; nTotBDH += BDH->BDH_VLRT28 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT29")) > 0 ; nTotBDH += BDH->BDH_VLRT29 ; EndIf
	If  BDH->(FieldPos("BDH_VLRT2A")) > 0 ; nTotBDH += BDH->BDH_VLRT2A ; EndIf
	If  BDH->(FieldPos("BDH_VLRT2B")) > 0 ; nTotBDH += BDH->BDH_VLRT2B ; EndIf
	If  BDH->(FieldPos("BDH_VLRT2C")) > 0 ; nTotBDH += BDH->BDH_VLRT2C ; EndIf
	If  BDH->(FieldPos("BDH_VLRTIM")) > 0 ; nTotBDH += BDH->BDH_VLRTIM ; EndIf
	If  BDH->(FieldPos("BDH_VLRPES")) > 0 ; nTotBDH += BDH->BDH_VLRPES ; EndIf

	// Calcula valor total do BD6

	SIX->( dbSetorder(01) )
	If cPaisLOC <> "BRA" .And. SIX->( dbSeek("BD6L") )
		cKeyBDH := BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_LANCF+BDH_SEQPF)
		cKeyBD6 := "BD6->(BD6_FILIAL+BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_ANOPAG+BD6_MESPAG+BD6_LANCF+BD6_SEQPF)"
		nOrdem := 21
	Else
		cKeyBDH := BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_SEQPF)
		cKeyBD6 := "BD6->(BD6_FILIAL+BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_ANOPAG+BD6_MESPAG+BD6_SEQPF)"
		nOrdem := 12
	Endif

	nTotBD6 := 0
	BD6->(dbSetOrder(nOrdem))
	BD6->(MsSeek(xFilial("BD6")+cKeyBDH))
	While !BD6->(Eof()) .And. &cKeyBD6 ==	xFilial("BD6") + cKeyBDH

		// Bypassa BD6

		If  ! (BD6->BD6_FASE $ "3,4" .and. BD6->BD6_SITUAC == '1' .and. BD6->BD6_BLOCPA <> "1")
			BD6->(dbSkip())
			Loop
		EndIf
		If  ! Empty(cTitulo) .And. BD6->(BD6_PREFIX+BD6_NUMTIT+BD6_PARCEL+BD6_TIPTIT) <> cTitulo
			BD6->(dbSkip())
			Loop
		EndIf

		// Desconsidera a guia que foi comprada e paga no ato.

		If BD6->BD6_QUACOB == "1"
			BD6->(DbSkip())
			Loop
		EndIf

		// Acumula total do BD6

		nTotBD6 += BD6->BD6_VLRTPF

		// Acessa proximo registro

		BD6->(dbSkip())
	Enddo



Return({nTotBDH,nTotBD6})

/*/{Protheus.doc} P627TTBM1
Acumula valor total do BM1

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Static Function P627TTBM1(cCodTip,nValor,aBM1)
	LOCAL nPos := 0

	// Acumula valor do BDH no BM1 correspondente

	If  nValor > 0
		nPos := aScan(aBM1,{|x| x[3] == cCodTip})
		If  nPos > 0
			aBM1[nPos,5] += nValor
		EndIf
	EndIf



Return()

/*/{Protheus.doc} PLS627VLD
Valida campos de data inicio e fim no lote de cobranca...

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLS627VLD()
	LOCAL lRet := .F.

	If Empty(M->BDC_MESFIM) .OR.;
			((M->BDC_ANOFIM+M->BDC_MESFIM >= M->BDC_ANOINI+M->BDC_MESINI) .And.;
			(M->BDC_MESFIM >= "01" .And. M->BDC_MESFIM <= "12") )

		lRet := .T.
	EndIf



Return(lRet)

/*/{Protheus.doc} PLSA627OK
Consiste a confirmacao do lote de cobranca...

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLSA627OK(oDlg,nOpc, nOpca, oEnchoice)
	LOCAL lRet := .T.

	If  nOpc = K_Incluir

		// Verifica campos obrigatorios...
		lRet := Obrigatorio(oEnchoice:aGets,oEnchoice:aTela)

		//Valida o campo de Data de Pagamento.
		If lRet .And. BDC->(FieldPos("BDC_DTPREE")) > 0 .And. BDC->(FieldPos("BDC_REEMB")) > 0 .And. M->BDC_REEMB == "1" .And. Empty(M->BDC_DTPREE)
			MsgAlert("O Campo Data de Reembolso deve ser preenchido!" )
			lRet := .F.
		Endif

		//Pede confirmacao dos dados informados...
		If lRet
			lRet := MsgYesNo(STR0202) //"Confirma os parametros informados?"
		EndIf

		//Chama ponto de entrada para verificacoes especificas do usuario...
		If lRet .And. Existblock("PL627BOK")
			lRet := ExecBlock("PL627BOK",.F.,.F.,{lRet,nOpc})
			// Consiste o retorno do ponto de entrada...
			If ValType(lRet) <> "L"
				MsgAlert(STR0203) //"O retorno do ponto de entrada PL627BOK esta inconsistente."
				lRet := .T.
			EndIf
		EndIf

		//Atualiza variavel de controle...
		If lRet
			nOpca := 1
			oDlg:End()
		Else
			nOpca := 2
		EndIf

	Elseif nOpc == K_Excluir

		//Pede confirmacao dos dados informados...
		If lRet
			lRet := msgYesNo('Atenção!' + CRLF + 'Exclusão do lote de cobrança e movimentação contábil!' + CRLF + '(Somente para título já contabilizado)' + CRLF + 'Obs.: Com o bloqueio do calendário contábil a operação não será executada!' + CRLF + CRLF + 'Confirma a exclusão do lote de cobrança?')
		EndIf

		//Chama ponto de entrada para verificacoes especificas do usuario...
		If lRet .and. Existblock("PL627BOK")
			lRet := ExecBlock("PL627BOK",.F.,.F.,{lRet, nOpc})

			//Consiste o retorno do ponto de entrada...
			If ValType(lRet) <> "L"
				MsgAlert(STR0203) //"O retorno do ponto de entrada PL627BOK esta inconsistente."
				lRet := .T.
			EndIf
		EndIf

		//Atualiza variavel de controle...
		If lRet
			nOpca := 1
			oDlg:End()
		Else
			nOpca := 2
		EndIf
	Else
		oDlg:End()
	EndIf

Return()

/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional
Parametros do array a Rotina:
          1. Nome a aparecer no cabecalho
          2. Nome da Rotina associada
          3. Reservado
          4. Tipo de Transa??o a ser efetuada:
          	  1 - Pesquisa e Posiciona em um Banco de Dados
              2 - Simplesmente Mostra os Campos
              3 - Inclui registros no Bancos de Dados
              4 - Altera o registro corrente
              5 - Remove o registro corrente do Banco de Dados
          5. Nivel de acesso
          6. Habilita Menu Funcional

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Static Function MenuDef()
	Private aRotina := {}

	If nMenu == 0

		aRotina := {	{ STR0001, 'AxPesqui'                       , 0, K_Pesquisar  , 0 , .f. },;	//"Pesquisar"
			{ STR0002, 'PL627MEN(2)' , 0 , K_Visualizar , 0, nil },; //"Visualizar"
			{ STR0205, 'PL627MEN(3)' , 0 , K_Incluir    , 0, nil },; //"Novo Lote"
			{ STR0206, 'PL627MEN(5)' , 0 , K_Excluir    , 0, nil },; //"Excluir  Lote"
			{ STR0207, 'PL627MNU(5)', 0 , K_Excluir     , 0, nil },; //"Ver. &Divergencias"
			{ "XML TISS", "PL_M52EXEC('HS_PEDIExp')" /*"HSPAHM52()" "Hs_M52EXEC('HS_PEDIExp')"*/, 0, 2},; //"xmltiss""
			{ STR0001, 'AxPesqui' , 0 , K_Pesquisar   	, 0, .f. },; //"Pesquisar"
			{ STR0002, 'AxVisual' , 0 , K_Visualizar 	, 0, nil },;
			{ STR0254, 'A627MCri', 0 , K_Visualizar 	, 0, nil },;
			{ STR0252, "PLSA627LEG"					    , 0, K_Incluir },;
			{ STR0001, 'AxPesqui' , 0 , K_Pesquisar  	, 0, .f. },; //"Pesquisar"
			{ STR0002, 'AxVisual' , 0 , K_Visualizar 	, 0, nil },;
			{ "Legenda", "PLSA627LEG"					, 0, K_Incluir },;
			{ STR0259, "PLSA627DTT"						, 0, K_Incluir } }

	Elseif nMenu == 1

		aRotina := {	{ STR0001, 'AxPesqui'                           , 0 , K_Pesquisar  , 0, .F.},;	//"Pesquisar"
			{ STR0002, 'PL627MEN(2)' , 0 , K_Visualizar , 0, Nil},;	//"Visualizar"
			{ STR0205, 'PL627MEN(3)' , 0 , K_Incluir    , 0, Nil},;	//"Novo Lote"
			{ STR0206, 'PL627MEN(5)' , 0 , K_Excluir    , 0, Nil},; //"Excluir  Lote"
			{ STR0207, 'PL627MNU(5)'          , 0 , K_Excluir    , 0, Nil},;
			{ "XML TISS", "PL_M52EXEC('HS_PEDIExp')" /*"HSPAHM52()" "Hs_M52EXEC('HS_PEDIExp')"*/, 0, 2} }	//"Ver. &Divergencias"


		// Se existir rdmake padrao, monta opcao para chama-lo...
		If ExistBlock("PLR590")
			Aadd(aRotina,{ STR0208    , 'ExecBlock("PLR590", .F., .F., {})' , 0 , K_Imprimir , 0, Nil}) //"Imprimir Lote"
		EndIf

	elseIf nMenu ==2


		aRotina := {	{ STR0001, 'AxPesqui' , 0 , K_Pesquisar  , 0, .F. },;	//"Pesquisar"
			{ STR0002, 'AxVisual' , 0 , K_Visualizar , 0, Nil },;
			{ STR0254,'A627MCri', 0 , K_Visualizar , 0, nil },;
			{STR0252	 , "PLSA627LEG"	, 0 , K_Incluir }}

	Elseif nMenu >= 3


		aRotina := {	{ STR0001, 'AxPesqui' , 0 , K_Pesquisar  , 0, .F. },;	//"Pesquisar"
			{ STR0002, 'AxVisual' , 0 , K_Visualizar , 0, Nil }}

	endif

	If nMenu ==4
		Aadd(aRotina, { "Legenda"    	     , "PLSA627LEG"		, 0 , K_Incluir     })
		Aadd(aRotina, { STR0259    	 , "PLSA627DTT"		, 0 , K_Incluir     })
	Endif


Return(aRotina)

/*/{Protheus.doc} PLS627CTIT
Gera a apresentacao do complemento do titulo no folder
"titulos gerados" na visualizacao do lote de cobranca.

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Static Function PLS627CTIT(nFolder,oGetSE1G)
	LOCAL I__f      := 0
	LOCAL cPrefixo	:= ''
	LOCAL cTitulo 	:= ''
	LOCAL cParcela	:= ''
	LOCAL cTipoTit	:= ''

	If Len(oGetSE1G:aCols) <= 0
		Return(0)
	EndIf

	If nFolder == 2
		cPrefixo := oGetSE1G:FieldGet("E1_PREFIXO")
		cTitulo  := oGetSE1G:FieldGet("E1_NUM")
		cParcela := oGetSE1G:FieldGet("E1_PARCELA")
		cTipoTit := oGetSE1G:FieldGet("E1_TIPO")

		BBT->( dbSetorder(07) )
		If BBT->( MsSeek(xFilial("BBT")+cPrefixo+cTitulo+cParcela+cTipoTit) )
			Copy "BBT" TO MEMORY
		Else
			Copy "BBT" TO MEMORY Blank
		EndIf
	EndIf



Return(BBT->(Recno()))

/*/{Protheus.doc} PLSA625Num
Retorna o proximo numero do lote a partir de uma operadora

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLSA625Num(cCodInt)
Return(GetSx8Num("BDC","BDC_NUMERO"))

/*/{Protheus.doc} PLSA625MDa
Monta prefixo, numero e nosso numero da um titulo no SE1...

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLSA625MDa(cAno,cMes,Tipo,cOrig,aChaves,cNivCob,cChave,lSoPre,cCusOpe)
	LOCAL cPrefixo  := ""
	LOCAL cNumero   := ""
	LOCAL cNossoN   := ""
	LOCAL lGerNFBRA	:= ( GetNewPar("MV_PLSNFBR","0") == "1" .Or. cPaisLOC <> 'BRA' )

	DEFAULT aChaves := {{}}
	DEFAULT cNivCob	:= ''
	DEFAULT cOrig 	:= "1"
	DEFAULT lSoPre	:= .F.
	DEFAULT cCusOpe	:= ""

	If Empty(cOrig)
		cOrig := "1"
	EndIf

	// Monta dados para o titulo atual a ser gerado...

	If Tipo == "1"
		Do Case
			Case cOrig == "1"
				cPrefixo := GetNewPar("MV_PLPFE11",'"PLS"')// Lote de faturameto.
			Case cOrig == "2"
				cPrefixo := GetNewPar("MV_PLPFE12",'"PLS"')	// Lote de faturameto intercambio eventual.
			Case cOrig == "3"
				cPrefixo := GetNewPar("MV_PLPFE13",'"PLS"')	// Cobranca de usuarios no ato da inclusao.
			Case cOrig == "4"
				cPrefixo := GetNewPar("MV_PLPFE14",'"PLS"')
			Case cOrig == "5"
				cPrefixo := GetNewPar("MV_PLPFE15",'"PLS"')
			Case cOrig == "6"
				cPrefixo := GetNewPar("MV_PLPFE16",'"PLS"')	// Identificacao do usuario
			Case cOrig == "7"
				cPrefixo := GetNewPar("MV_PLPFE17",'"PLS"')
			Case cOrig == "8"
				cPrefixo := GetNewPar("MV_PLPFE18",'"PDF"')	// Desconto em folha
			Case cOrig == "9"
				cPrefixo := GetNewPar("MV_PLPFE19",'"PLS"')//Titulo NDC para Lote de intercambio

		EndCase
		If Empty (cPrefixo)
			cPrefixo := '"PLS"'
		Endif

		// Se for .T. somente vai retornar o prefixo

		If !lSoPre
			cPrefixo := Eval({|| &cPrefixo })

			DbSelectArea("BA1")
			If lGerNFBRA .And. Empty(A460Especie(cPrefixo))

				// Caso nao tenha ligacao no MV_ESPECIE volta a padrao UNI. Melhorar esse LOG

				cPrefixo := "UNI"
			EndIf

			If 	lPlPrefE1
				cPrefixo := ExecBLock("PLPREFE1",.F.,.F.,{cPrefixo, cNumero, cAno, cMes, aChaves, cNivCob, cOrig, cCusOpe})
				// LOG

				PLSLOGFAT("PLPREFE1",1,.F.)
			EndIf

			// Gera o numero do titulo

			cNumero := PL627CDTIT(@cPrefixo,cChave)


			If lPlNumTit
				cNumero := ExecBlock("PLNUMTIT",.F.,.F.,{cPrefixo,cNumero})

				// LOG

				PLSLOGFAT("PLNUMTIT",1,.F.)
			EndIf
		EndIf
	Else

		If lPlPref2
			cPrefixo := ExecBLock("PLPREFE2",.F.,.F.,{cAno,cMes})

			// LOG

			PLSLOGFAT("PLPREFE2",1,.F.)
		Else
			cPrefixo := "PLS"
		EndIf

		// Se for .T. somente vai retornar o prefixo

		If !lSoPre
			cNumero  := PLSE2NUM(cPrefixo)
		EndIf

	EndIf

	If lPlNumBco
		cNossoN  := ExecBlock("PLNUMBCO",.F.,.F.,{cPrefixo, cNumero, cAno, cMes, aChaves, cNivCob})

		// LOG

		PLSLOGFAT("PLNUMBCO",1,.F.)
	Else
		cNossoN  := ""
	EndIf



Return({cPrefixo,cNumero,cNossoN})

/*/{Protheus.doc} PLSA625Cri
Grava arquivos de criticas..

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLSA625Cri(cNumCob,nValor,aVetCri,cCodInt,cCodEmp,cNumCon,cVerCon,cSubCon,;
		cVerSub,cMatric,cTipReg,_cNivel,cAno,cMes,lInterC,lFaturamento,aRecBDF,;
		cChave, cTipo, lConsidBBT)

	Local nOpc := 0
	Local I	:= 0
	Local cInterC := ""

	Default lInterC := .F.
	Default lFaturamento := .T.
	Default cTipo := '1'
	Default lConsidBBT := .T.

	// Se e intercambio
	If lInterC
		cInterC := "1"
	Else
		cInterC := "0"
	EndIf

	// Veririfica matriz
	If Len(aVetCri) > 0
		If ValType(aVetCri[1]) == "A" .And. ValType(aVetCri[1,1]) == "L" .And. aVetCri[1][1]
			lCrit := .F.
		ElseIf ValType(aVetCri[1]) == "A"
			lCrit :=  .T.
		ElseIf aVetCri[1]
			lCrit := .F.
		Else
			lCrit := .T.
		EndIf
	Else
		lCrit := .F.
	EndIf

	// Avalia o retorno...
	If nGravado = 0 .And. Type("aDadBdw") <> "U"

		PLUPTCOLS(	"BDW",;
			aDadBDW,;
			aCabBDW,;
			aVetBDW,;
			nOpc,;
			{ 	{"BDW_NUMERO", M->BDC_NUMERO },;
			{"BDW_CODOPE", M->BDC_CODOPE},;
			{"BDW_TIPO","0"} },;
			.T.)
	EndIf

	If nOpc = K_Incluir .And. nGravado = 0

		nOpc := K_Alterar

		If Type("nOpcX")#"U"
			nOpcX := K_Alterar
		EndIf

	EndIf

	nGravado ++

	// Tratamento para o vetor com informacoes detalhadas...
	cTemp := BDF->( GetSx8Num("BDF","BDF_CODSEQ") )
	BDF->( ConfirmSx8() )

	BDF->( RecLock("BDF",.T.) )
	BDF->BDF_FILIAL := xFilial("BDF")
	BDF->BDF_CODSEQ := cTemp
	BDF->BDF_NUMERO := cNumCob
	BDF->BDF_CODOPE := cCodInt
	BDF->BDF_INTERC := cInterC
	BDF->BDF_CODEMP := cCodEmp

	If _cNivel == "2"
		BDF->BDF_NUMCON := cNumCon
		BDF->BDF_VERCON := cVerCon
	Elseif _cNivel == "3"
		BDF->BDF_NUMCON := cNumCon
		BDF->BDF_VERCON := cVerCon
		BDF->BDF_SUBCON := cSubCon
		BDF->BDF_VERSUB := cVerSub
	Elseif _cNivel == "4"
		BDF->BDF_MATRIC := cMatric
	Elseif _cNivel == "5"
		BDF->BDF_MATRIC := cMatric
		BDF->BDF_TIPREG := cTipReg
	Elseif _cNivel == "7"
		BDF->BDF_NUMCON := cNumCon
		BDF->BDF_VERCON := cVerCon
		BDF->BDF_SUBCON := cSubCon
		BDF->BDF_VERSUB := cVerSub
		BDF->BDF_MATRIC := cMatric
		BDF->BDF_TIPREG := cTipReg
	EndIf
	BDF->BDF_TIPO   := iif(!lCrit,"0","1")
	BDF->BDF_VALOR  := nValor
	BDF->BDF_NIVEL  := _cNivel
	If lConsidBBT
		BDF->BDF_ANOTIT := BBT->BBT_ANOTIT
		BDF->BDF_MESTIT := BBT->BBT_MESTIT
	Else
		BDF->BDF_ANOTIT := cAno
		BDF->BDF_MESTIT := cMes
	EndIf
	BDF->BDF_MATFAM := cCodInt+cCodEmp+cMatric

	If !lCrit .And. lFaturamento .And. lConsidBBT// não gravar quando desconto em folha
		BDF->BDF_PREFIX := BBT->BBT_PREFIX
		BDF->BDF_NUMTIT := BBT->BBT_NUMTIT
		BDF->BDF_PARCEL := BBT->BBT_PARCEL
		BDF->BDF_TIPTIT := BBT->BBT_TIPTIT

	ElseIf !lCrit .And. aRecBdf # Nil
		AaDd(aRecBDF, { BDF->(Recno()), cChave })

	EndIf
	BDF->( MsUnlock() )

	// Atualiza a critica detalhda...
	For I := 1 to Len(aVetCri)

		If ValType(aVetCri[I,1]) == "L" .And. aVetCri[I,1]
			Loop
		EndIf

		BDG->( RecLock("BDG",.T.) )
		BDG->BDG_FILIAL := xFilial("BDG")
		BDG->BDG_INTERC := cInterC
		BDG->BDG_CODOPE := cCodInt
		BDG->BDG_NUMERO := cNumCob
		BDG->BDG_CODSEQ := cTemp
		BDG->BDG_CODCRI := aVetCri[I,2]
		If BDG->( FieldPos("BDG_DESCRI") ) > 0
			BDG->BDG_DESCRI := aVetCri[I,3]
		EndIf
		BDG->BDG_NIVEL  := _cNivel
		BDG->BDG_DTCRIT := dDataBase
		BDG->( MsUnLock() )
	Next

	// LOG
	PLSLOGFAT("DADOS CAB E ITEM DO LOTE DE COBRANCA",1)

Return

/*/{Protheus.doc} PLSA625SE1
Descricao  Deleta titulos/comissoes pagas para o lote de   cobranca  ou
           tambem podera deletar um titulo de um lote de cobranca
aRet:[1] - Contabilizado ?
	 [2] - Movimentado ?
	 [3] - Baixado por cancelamento ?
	 [4] - Eh o ultimo titulo do prefixo ?
	 [5] - Controla numeracao do SE1 ?
	 [6] - Foi baixado para desconto em folha ?
	 [7] - O titulo referente a producao medica foi baixado ?
	 [8] - O titulo foi baixado devido a lancamento na folha de pagamento

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLSA625SE1(cNumCob,lInterC,cBBT_PREFIX,cBBT_NUMTIT,cBBT_PARCEL,cBBT_TIPTIT,noUsed,lPortal,lAutomato)
	LOCAL cFor 			:= "BBT_NUMCOB = '"+cNumCob+"'"
	LOCAL cArea 		:= Alias()
	LOCAL nI			:= 1
	LOCAL nTotExc		:= 0
	LOCAL nTotEmp		:= 0
	LOCAL nV			:= 0
	LOCAL cSQL      	:= ""
	LOCAL cTxtPad		:= ""
	LOCAL cEmpOld		:= ""
	local cChavAux		:= ""
	local lRet			:= .t.
	local lJaCri		:= .f.
	LOCAL aFuncio   	:= {}
	local aEstorno		:= {}
	LOCAL aCriticas		:= {}
	LOCAL aVet1			:= {}
	LOCAL aCabec		:= { 	{STR0209,"@C",20},{STR0210,"@C",30},; //"Prefixo"###"Numero"
		{STR0211,"@C",20},{STR0212,"@C",20},; //"Parcela"###"Tipo"
		{STR0047,"@C",250} } //"Critica"
	LOCAL aTitNcc		:= {}
	LOCAL lExcComp		:= .T.
	LOCAL lUltimo		:= .T.
	LOCAL lBxCancel := GetNewPar("MV_PLBXCAN",.F.) // Baixa por cancelamento

	DEFAULT noUsed := .F.

	SE1->( DbClearFilter() )

	//Query do bbt
	cFor := "SELECT * FROM " + RetSqlName("BBT")
	cFor += " WHERE BBT_FILIAL = '" + xFilial("BBT") + "' AND "
	cFor += "       BBT_NUMCOB = '"+cNumCob+"' AND "

	If lInterC <> nil .and. lInterC
		cFor += "BBT_INTERC = '1' AND "
	Else
		cFor += "BBT_INTERC <> '1' AND "
	EndIf
	//Se tem prefixo,titulo...
	If cBBT_PREFIX # nil
		cFor += "BBT_PREFIX = '" + cBBT_PREFIX + "' AND "
		cFor += "BBT_NUMTIT = '" + cBBT_NUMTIT + "' AND "
		cFor += "BBT_PARCEL = '" + cBBT_PARCEL + "' AND "
		cFor += "BBT_TIPTIT = '" + cBBT_TIPTIT + "' AND "
	EndIf
	cFor += " D_E_L_E_T_ = ' ' "
	cFor += " ORDER BY BBT_FILIAL, BBT_PREFIX DESC, BBT_NUMTIT DESC, BBT_PARCEL DESC "

	cFor := ChangeQuery(cFor)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cFor), "BBTQRY", .F., .T.)

	//Analiza baixas e a situacao do titulo, antes de exclui-lo...
	BBTQRY->( dbGotop() )
	While ! BBTQRY->(Eof())

		//Somente exclusao pelo numero do lote de cobranca
		If cBBT_PREFIX == nil
			If BBTQRY->BBT_CODEMP <> cEmpOld
				cEmpOld := BBTQRY->BBT_CODEMP
				nTotEmp++
			EndIf
			nTotExc++
			cEmpOld := ""
		EndIf

		//Verfica a exclusao dos Titulos
		If BBTQRY->BBT_RECPAG == "0"

			if cFilAnt + BBTQRY->(BBT_PREFIX+BBT_NUMTIT) <> cChavAux
				cChavAux := cFilAnt +  BBTQRY->(BBT_PREFIX+BBT_NUMTIT)
			else
				BBTQRY->(dbSkip())
				loop
			endIf

			SE1->( dbSetOrder(1) )//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If SE1->( msSeek( xFilial("SE1") + BBTQRY->(BBT_PREFIX+BBT_NUMTIT) ) )

				If lUltimo .And. FindFunction("CheckExcTit") .And. lBxCancel // O primeiro titulo é o ultimo do lote
					lExcComp := CheckExcTit(SE1->E1_PREFIXO,SE1->E1_NUM) // .F. = Estorno / .T. = Exclusão
					lUltimo := .F.
				EndIf

				//Temos clientes que possui a tabela SE1 que não segue o mesmo compartilhamento da tabela BBT, por isso estamos usando  xFilial("SE1")+BBTQRY->(BBT_PREFIX+BBT_NUMTIT)
				//Na tabela BBT temos prefixo e numero do titulo e preciamos adicionar a filial da tabela SE1 devido aos tipo de compartilhamento diferente entre BBT e SE1

				While SE1->(!Eof()) .and.  SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) ==   xFilial("SE1")+BBTQRY->(BBT_PREFIX+BBT_NUMTIT)

					//Antes de efetuar a exclução precisamos vericar se o titulo existe NCC e se esta compensado no titulo principal
					//Para isso precisamos da função do financeiro MaIntBxCR
					If Alltrim(SE1->E1_TIPO) <> "NCC"
						Pl627TitNcc()
					Endif

					//Executa funcao que analisa a possibilidade de exclusao de uma guia que teve movimentacao financeiro relacionada..
					aRet := PLSA090AE1(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA)

					//[1]  - Calendario contabil (.T./.F.)
					//[2]  - Movimentado (.T./.F.)
					//[9]  - Indica que existe lote de cobrança posterior para mesmo ano e mes (.T./.F.)
					//[11] - Indica titulo em carteira (.T./.F.)

					//bloqueio calendario contabil
					if aRet[1]
						aadd(aCriticas, { SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, "Lote não pode ser excluído, pois existe bloqueio do calendário contábil!", .f. } )
						lJaCri := .t.
					endIf

					//Caso exista lote de cobrança posterior para mesmo ano e mes , nao pode excluir o lote...
					If aRet[9]
						AaDd(aCriticas, {SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,STR0283, .f.}) //"LOTE NAO PODE SER EXCLUIDO, POIS FOI GERADO OUTRO LOTE POSTERIOR"
						lJaCri := .t.
					Endif

					//Titulo nao esta em carteira, nao pode excluir o lote...
					if aRet[11]
						AaDd(aCriticas, {SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,STR0214, .f.}) //"Titulo transferido para banco."
						lJaCri := .t.
					EndIf

					//movimentacao
					if aRet[2]

						//Verifica se o titulo foi baixado total ou parcialmente
						if SE1->E1_VALOR <> SE1->E1_SALDO .And. SE1->E1_SALDO > 0
							AaDd(aCriticas, { SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, STR0258, .t.} ) //"baixado Parcialmente."
						else

							If ! aRet[13]
								AaDd(aCriticas, { SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, STR0213, .t.} ) //"Titulo baixado."
							Endif

						endIf

						//compensacao NCC
						if aRet[13]

							if ! lJaCri
								aadd(aEstorno, SE1->(recno()) )
							endIf

						else
							aEstorno := {}
							lJaCri 	 := .t.
						endIf

					endIf

					SE1->(DbSkip())

				endDo

				//Lancamento na Folha para o lote se foi gerada ou nao
			ElseIf  BM1->(FieldPos("BM1_AGMTFU")) > 0  .And. BM1->(FieldPos("BM1_VERSIG")) > 0 .And. BM1->(FieldPos("BM1_AGFTFU")) > 0

				cSql := "SELECT BM1_AGFTFU,BM1_AGMTFU,BM1_ANO,BM1_MES,BM1_VERSIG FROM "+RetSqlName("BM1")
				cSql += " WHERE "
				cSql += " BM1_FILIAL = '" + xFilial("BM1")	   + "' AND "
				cSql += " BM1_PREFIX = '" + BBTQRY->BBT_PREFIX + "' AND "
				cSql += " BM1_NUMTIT = '" + BBTQRY->BBT_NUMTIT + "' AND "
				cSql += " BM1_PARCEL = '" + BBTQRY->BBT_PARCEL + "' AND "
				cSql += " BM1_TIPTIT = '" + BBTQRY->BBT_TIPTIT + "' AND "
				cSql += " D_E_L_E_T_ = ' '"

				cSql := ChangeQuery(cSql)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPBM1",.F.,.T.)

				TMPBM1->(DBEval( { | | AaDd(aFuncio, {BM1_AGFTFU+BM1_AGMTFU+BM1_ANO+BM1_MES+BM1_VERSIG,;
					.F.,;
					BM1_AGFTFU,;
					BM1_AGMTFU}) }))
				TMPBM1->(DbCloseArea())

				SRD->(DbSetOrder(1))//RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC
				For nI := nI to Len(aFuncio)

					If SRD->(MsSeek(aFuncio[nI][1]))
						aFuncio[nI][2] := .T.
					EndIf

				Next

			EndIf

		EndIf

		BBTQRY->( dbSkip() )
	EndDo

	//tratamento para retirar compensacao NCC
	if len(aEstorno) > 0 .and. IIF(!lAutomato,msgYesNo('Confirmar o estorno da compensação dos titulos?'), .T.)

		for nI := 1 to len(aEstorno)

			SE1->( msGoTo( aEstorno[nI] ) )

			if PLTITBXCR(.t.,lExcComp)

				nPos := aScan(aCriticas, {|x| x[1] == SE1->E1_PREFIXO .and. x[2] == SE1->E1_NUM .and. x[3] == SE1->E1_PARCELA .and. x[4] == SE1->E1_TIPO } )

				if nPos > 0
					aDel( aCriticas, nPos )
					aSize( aCriticas, len(aCriticas) - 1 )
				endIf

			endIf

		next

	endIf

	//Encontrado titulos baixados ou que nao estao em carteira...
	if len(aCriticas) > 0
		lRet := .f.
	endIf

	if lRet

		If aScan(aFuncio,{|x| x[2] }) > 0

			cTxtPad := STR0015
			cTxtPad += STR0016
			For nI:= 1 to Len(aFuncio)
				If aFuncio[nI][2]
					cTxtPad += '['+aFuncio[nI][3]+'-'+aFuncio[nI][4]+']  '
				EndIf
			Next
			msgAlert(cTxtPad)

			BBTQRY->( dbClosearea() )
			Return(.f.)
		EndIf

		//Monta barras
		If ! lPortal
			If !lAutomato
				If cBBT_PREFIX == Nil
					BarGauge1Set( nTotEmp )
					BarGauge2Set( nTotExc )
				EndIf
			EndIf
		Endif

		//Inicia exclusao
		BBTQRY->( DbGoTop() )
		While !BBTQRY->( Eof() )

			//Somente exclusao pelo numero do lote de cobranca
			If cBBT_PREFIX == Nil
				nV++
				//Empresa que esta sendo processada
				If BBTQRY->BBT_CODEMP <> cEmpOld

					cEmpOld := BBTQRY->BBT_CODEMP

					If ! lPortal
						If !lAutomato
							IncProcG1( STR0273 + cEmpOld + ' - '+ PadR( Posicione("BG9",1,xFilial("BG9")+BBTQRY->BBT_CODOPE+cEmpOld,"BG9_DESCRI"),60 ),.T.,,.F.)
							ProcessMessage()
						EndIf
					endif

				EndIf

				//Mensagem de processamento
				if !lPortal
					If !lAutomato
						IncProcG2( STR0274 + StrZero(nV,6) + STR0269 +AllTrim( StrZero( nTotExc ,6) ),.T.,,.F.)
					EndIf
				endif

			EndIf

			//Matriz de trabalho
			aVet1 := {  2,;
				BBTQRY->R_E_C_N_O_,;
				cNumCob,;
				lInterc}

			if ! A625SE1C(aVet1)

				aadd(aCriticas, {BBTQRY->BBT_PREFIX,BBTQRY->BBT_NUMTIT,BBTQRY->BBT_PARCEL,BBTQRY->BBT_TIPTIT,"Inconsistencia na exclusão do titulo", .f.})

				lRet := .f.
				exit

			endIf
			BBTQRY->( DbSkip() )
		EndDo
		BBTQRY->(DbCloseArea())

		if lRet

			If !lPortal

				If !lAutomato
					ProcessMessage()
				EndIf

			Endif


			//Ponto Entrada antes do Update das tabelas abaixo.
			If ExistBlock("PLS625ES")
				ExecBlock("PLS625ES",.F.,.F.,{cNumCob})
			EndIf

			//Inicia uma nova transacao, nao pode ficar na mesma transacao acima.
			BEGIN TRANSACTION

				//Desmarca os bsq que nao tem titulo
				cSql := "SELECT BSQ_NUMCOB  FROM "+RetSQLName("BSQ") "
				cSql += "WHERE BSQ_FILIAL = '" + xFilial("BSQ") + "' "
				cSql += "  AND BSQ_NUMCOB = '"+cNumCob+"' "
				cSql += "  AND BSQ_PREFIX = ' ' "
				cSql += "  AND BSQ_NUMTIT = ' ' "
				cSql += "  AND BSQ_PARCEL = ' ' "
				cSql += "  AND BSQ_TIPTIT = ' ' "
				cSql += "  AND D_E_L_E_T_ = ' ' "
				cSql := ChangeQuery(cSql)

				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"SELEBSQ",.F.,.T.)

				If ! SELEBSQ->(Eof())

					cSql := "UPDATE "+RetSQLName("BSQ")+" SET BSQ_NUMCOB = ' ' "
					cSql += "WHERE BSQ_FILIAL = '" + xFilial("BSQ") + "' "
					cSql += "  AND BSQ_NUMCOB = '"+cNumCob+"' "
					cSql += "  AND BSQ_PREFIX = ' ' "
					cSql += "  AND BSQ_NUMTIT = ' ' "
					cSql += "  AND BSQ_PARCEL = ' ' "
					cSql += "  AND BSQ_TIPTIT = ' ' "
					cSql += "  AND D_E_L_E_T_ = ' ' "

					TCSqlExec(cSql)

				EndIf

				SELEBSQ->( dbClosearea() )

				//Atualiza pessoa fisica
				cSql := "SELECT BA3_NUMCOB  FROM "+RetSQLName("BA3") "
				cSql += " WHERE BA3_FILIAL = '"+xFilial("BA3")+"' AND BA3_NUMCOB = '"+cNumCob+"' "
				cSql += " AND "+BA3->(RetSQLName("BA3"))+".D_E_L_E_T_ = ' ' "

				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"SELEBA3",.F.,.T.)

				If ! SELEBA3->(Eof())

					cSql := " UPDATE " + BA3->(RetSQLName("BA3")) + " SET BA3_NUMCOB = '',BA3_ULTCOB = '' "
					cSql += " WHERE BA3_FILIAL = '"+xFilial("BA3")+"' AND BA3_NUMCOB = '"+cNumCob+"' "
					cSql += " AND "+BA3->(RetSQLName("BA3"))+".D_E_L_E_T_ = ' ' "

					TCSQLExec(cSql)

				EndIf
				SELEBA3->( dbClosearea() )

				//So desmarco as iformacoes abaixo caso todo o lote tenha sido excluido...

				cSql := "SELECT BQC_NUMCOB  FROM "+RetSQLName("BQC") "
				cSql += " WHERE BQC_FILIAL = '"+xFilial("BQC")+"' AND BQC_NUMCOB = '"+cNumCob+"' "
				cSql += " AND "+BQC->(RetSQLName("BQC"))+".D_E_L_E_T_ = ' ' "

				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"SELEBQC",.F.,.T.)

				If ! SELEBQC->(Eof())

					cSql := " UPDATE " + BQC->(RetSQLName("BQC")) + " SET BQC_NUMCOB = '',BQC_ULTCOB = '' "
					cSql += " WHERE BQC_FILIAL = '"+xFilial("BQC")+"' AND BQC_NUMCOB = '"+cNumCob+"' "
					cSql += " AND "+BQC->(RetSQLName("BQC"))+".D_E_L_E_T_ = ' ' "

					TCSQLExec(cSql)

				EndIf
				SELEBQC->( dbClosearea() )

				//As informacoes abaixo sao referente ao lote inteiro, e ja que o lote
				//esta sendo excluido inteiramente, executo a query
				//de execucao uma unica vez, ao invez de executa-las titulo a titulo.
				//Deleta o resumo da cobranca...
				cSql := "SELECT BDD_NUMERO  FROM "+RetSQLName("BDD") "
				cSql += "WHERE BDD_FILIAL = '" + xFilial("BDD") + "' "
				cSql += "AND BDD_CODOPE = '"+Substr(cNumCob,1,TamSX3("BDD_CODOPE")[1])+"' "
				cSql += "AND BDD_NUMERO = '"+Substr(cNumCob,TamSX3("BDD_CODOPE")[1]+1,len(cNumCob))+"' "
				cSql += "AND "+BDD->(RetSQLName("BDD"))+".D_E_L_E_T_ = ' ' "

				cSql := ChangeQuery(cSql)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"SELEBDD",.F.,.T.)

				If ! SELEBDD->(Eof())

					cSql := " UPDATE " + BDD->(RetSQLName("BDD")) + " SET D_E_L_E_T_ = '*' WHERE BDD_FILIAL = '"+xFilial("BDD")+"' "
					cSql += "AND BDD_CODOPE = '"+Substr(cNumCob,1,TamSX3("BDD_CODOPE")[1])+"' "
					cSql += "AND BDD_NUMERO = '"+Substr(cNumCob,TamSX3("BDD_CODOPE")[1]+1,len(cNumCob))+"' "
					cSql += "AND "+BDD->(RetSQLName("BDD"))+".D_E_L_E_T_ = ' ' "

					TCSQLExec(cSql)

				EndIf
				SELEBDD->( dbClosearea() )

				//Deleta o resumo da cobranca por nivel...
				cSql := "SELECT BDF_NUMERO  FROM "+RetSQLName("BDF") "
				cSql += "WHERE BDF_FILIAL = '" + xFilial("BDG") + "' "
				cSql += "AND BDF_CODOPE = '"+Substr(cNumCob,1,TamSX3("BDF_CODOPE")[1])+"' "
				cSql += "AND BDF_NUMERO = '"+Substr(cNumCob,TamSX3("BDF_CODOPE")[1]+1,len(cNumCob))+"' "
				cSql += "AND "+BDF->(RetSQLName("BDF"))+".D_E_L_E_T_ = ' ' "

				cSql := ChangeQuery(cSql)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"SELEBDF",.F.,.T.)

				If ! SELEBDF->(Eof())
					cSql := " UPDATE " + BDF->(RetSQLName("BDF")) + " SET D_E_L_E_T_ = '*' WHERE BDF_FILIAL = '"+xFilial("BDF")+"' "
					cSql += "AND BDF_CODOPE = '"+Substr(cNumCob,1,TamSX3("BDF_CODOPE")[1])+"' "
					cSql += "AND BDF_NUMERO = '"+Substr(cNumCob,TamSX3("BDF_CODOPE")[1]+1,len(cNumCob))+"' "
					cSql += "AND "+BDF->(RetSQLName("BDF"))+".D_E_L_E_T_ = ' ' "
					TCSQLExec(cSql)
				EndIf

				SELEBDF->( dbClosearea() )

				//Deleta o resumo da cobranca por nivel...
				cSql := "SELECT BDG_NUMERO  FROM "+RetSQLName("BDG") "
				cSql += "WHERE BDG_FILIAL = '" + xFilial("BDG") + "' "
				cSql += "AND BDG_CODOPE = '"+Substr(cNumCob,1,TamSX3("BDG_CODOPE")[1])+"' "
				cSql += "AND BDG_NUMERO = '"+Substr(cNumCob,TamSX3("BDG_CODOPE")[1]+1,len(cNumCob))+"' "
				cSql += "AND " +BDG->(RetSQLName("BDG"))+".D_E_L_E_T_ = ' ' "

				cSql := ChangeQuery(cSql)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"SELEBDG",.F.,.T.)

				If ! SELEBDG->(Eof())

					cSql := " UPDATE " + BDG->(RetSQLName("BDG")) + " SET D_E_L_E_T_ = '*' WHERE BDG_FILIAL = '"+xFilial("BDG")+"' "
					cSql += "AND BDG_CODOPE = '"+Substr(cNumCob,1,TamSX3("BDG_CODOPE")[1])+"' "
					cSql += "AND BDG_NUMERO = '"+Substr(cNumCob,TamSX3("BDG_CODOPE")[1]+1,len(cNumCob))+"' "
					cSql += "AND "+BDG->(RetSQLName("BDG"))+".D_E_L_E_T_ = ' ' "

					TCSQLExec(cSql)

				EndIf

				SELEBDG->( dbClosearea() )

				If PlsAliasExi("B6U")

					// Deleta os registro relacioandos ao Rateio do Imposto do Lote de Cobrança
					cSql := "SELECT B6U_NUMCOB FROM " + RetSQLName("B6U")
					cSql += " WHERE B6U_FILIAL = '" + xFilial("B6U") + "' AND "
					cSql += "	B6U_CODINT = '" + Substr(cNumCob,1,4) + "' AND "
					cSql += "	B6U_NUMCOB = '" + Substr(cNumCob,5) + "' AND "
					cSql += B6U->(RetSQLName("B6U")) + ".D_E_L_E_T_ = ' ' "

					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"SELEB6U",.F.,.T.)

					If ! SELEB6U->(Eof())

						cSql := " UPDATE " + B6U->(RetSQLName("B6U")) + " SET D_E_L_E_T_ = '*' "
						cSql += " WHERE B6U_FILIAL = '" + xFilial("B6U") + "' AND "
						cSql += "	B6U_CODINT = '" + Substr(cNumCob,1,4) + "' AND "
						cSql += "	B6U_NUMCOB = '" + Substr(cNumCob,5) + "' AND "
						cSql += B6U->(RetSQLName("B6U")) + ".D_E_L_E_T_ = ' ' "

						TCSQLExec(cSql)

					EndIf
					SELEB6U->( dbClosearea() )

				EndIf

			End Transaction

		endIf

	else
		BBTQRY->(DbCloseArea())
	endIf

	If ! Empty(cArea)
		DbSelectArea(cArea)
	EndIf

	If ExistBlock("PLS625ET")
		ExecBlock("PLS625ET",.F.,.F.,{cNumCob})
		PLSLOGFAT("PLS625ET",1,.F.)
	EndIf

	//Encontrado titulos baixados ou que nao estao em carteira...
	If ! lRet .and. len(aCriticas) > 0  .and. !lAutomato
		PLSCRIGEN(aCriticas,aCabec, STR0048,NIL,NIL,NIL,NIL, NIL,NIL,"G",220) //"Verificacao de integridade."
	EndIf

Return(lRet)

/*/{Protheus.doc} A625SE1C

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function A625SE1C(aDados)
	LOCAL nCnt			:= 0
	LOCAL nForReg		:= 0
	LOCAL nRecBBT 		:= aDados[2]
	LOCAL cNumCob 		:= aDados[3]
	LOCAL cSql			:= ""
	LOCAL lInterc		:= aDados[4]
	LOCAL aRegs			:= {}
	LOCAL lDatPagto     := GetNewPar("MV_PLSDTPG",.F.)
	LOCAL lExclui		:= .F.
	local lRet			:= .t.

	//Posiciona o registro do BBT
	BBT->( DbGoto(nRecBBT) )

	BEGIN TRANSACTION

		If BBT->BBT_RECPAG == "0"

			SE1->(DbSetOrder(1))
			If SE1->( msSeek( xFilial("SE1") + BBT->(BBT_PREFIX + BBT_NUMTIT + BBT_PARCEL + BBT_TIPTIT) ) )
				//exclui titulos ou nota
				if ! P629ExcE1()
					disarmTransaction()
					lRet := .f.
				endIf

			EndIf

		Else

			SE2->(DbSetOrder(1))
			If SE2->(MsSeek(xFilial("SE2") + BBT->(BBT_PREFIX+BBT_NUMTIT+BBT_PARCEL+BBT_TIPTIT)))

				if SE2->E2_SALDO == SE2->E2_VALOR

					//TODO - chamar rotina automatica
					SE2->(RecLock("SE2",.F.))
					SE2->(DbDelete())
					SE2->(MsUnLock())

				EndIf

			EndIf

		EndIf

		if lRet
			//Desmarco faturamento das taxas de identificacao de usuario...
			cSql := " UPDATE " + BED->(RetSQLName("BED"))
			cSql += " SET BED_FATUR = '0',"
			cSql += " 	  BED_ANMSFT = ' ',"
			cSql += " 	  BED_NUMCOB = ' ',"
			cSql += " 	  BED_PREFIX = ' ',"
			cSql += " 	  BED_NUMTIT = ' ',"
			cSql += " 	  BED_PARCEL = ' ',"
			cSql += " 	  BED_TIPTIT = ' ' "
			cSql += " WHERE BED_FILIAL = '"+xFilial("BED")+"' "
			cSQL += "   AND BED_NUMCOB = '"+cNumCob+"' "

			If lInterC
				cSQL += "  AND BED_INTERC = '1' "
			Else
				cSQL += "  AND BED_INTERC = '0' "
			EndIf

			cSQL += " AND BED_PREFIX = '" + BBT->BBT_PREFIX + "' "
			cSQL += " AND BED_NUMTIT = '" + BBT->BBT_NUMTIT + "' "
			cSQL += " AND BED_PARCEL = '" + BBT->BBT_PARCEL + "' "
			cSQL += " AND BED_TIPTIT = '" + BBT->BBT_TIPTIT + "' "
			cSQL += " AND BED_FATUR  = '1' "
			cSQL += " AND BED_COBRAR = '1' "
			cSQL += " AND BED_VALOR > 0 "
			cSql += " AND "+BED->(RetSQLName("BED"))+".D_E_L_E_T_ = ' ' "

			TCSQLExec(cSql)

			//Desmarco faturamento das vias de boleto...
			cSQL := "SELECT BEE.R_E_C_N_O_ RECBEE "
			cSQL += "FROM " + BEE->(RetSQLName("BEE")) + " BEE, " + BM1->(RetSQLName("BM1")) + " BM1 "
			cSQL += "WHERE BEE_FILIAL = '" + xFilial("BEE") + "' AND "
			cSQL += "BM1_FILIAL = '" + xFilial("BM1") + "' AND "
			cSQL += "BM1_PLNUCO = '"+cNumCob+"' AND BM1_INTERC = '0' AND BM1.D_E_L_E_T_ = ' ' AND "
			cSQL += "BM1_PREFIX = '" + BBT->BBT_PREFIX + "' AND BM1_NUMTIT = '" + BBT->BBT_NUMTIT + "' AND "
			cSQL += "BM1_PARCEL = '" + BBT->BBT_PARCEL + "' AND BM1_TIPTIT = '" + BBT->BBT_TIPTIT + "' AND "
			cSQL += "BEE_CODINT = BM1_CODINT AND "
			cSQL += "BEE_CODEMP = BM1_CODEMP AND "
			cSQL += "BEE_MATRIC = BM1_MATRIC AND "
			cSQL += "BEE_NUMCOB = '"+cNumCob+"' AND BEE.D_E_L_E_T_ = ' '"

			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)

			Do While ! TRB->(Eof())

				BEE->(DbGoTo(TRB->RECBEE))

				BEE->(RecLock("BEE", .F.))
				BEE->BEE_FATUR  := "0"
				BEE->BEE_ANMSFT := ""
				BEE->BEE_NUMCOB := ""
				BEE->(MsUnlock())

				TRB->(DbSkip())
			EndDo

			TRB->(DbCloseArea())

			//Desmarco flags do usuario com relacao a taxa de adesao...
			If lInterC

				// Primeiro UPDATE para o BM1_CODTIP = 103, atualiza os campos BA1_CBTXAD e BA1_VLTXAD, se BA1_NUMCOB = cNumCob
				cSQL := "UPDATE "+BA1->(RetSQLName("BA1"))
				cSQL += " SET   BA1_CBTXAD = '0', BA1_VLTXAD = 0
				cSQL += " WHERE  R_E_C_N_O_ IN (SELECT BA1.R_E_C_N_O_ RECBA1 "
				cSQL += " FROM " + BA1->(RetSQLName("BA1"))  +" BA1, " + BM1->(RetSQLName("BM1"))  +" BM1 "
				cSQL += " WHERE  BA1_FILIAL =  '" + xFilial("BA1")  +"'"
				cSQL += " AND BM1_FILIAL = '" + xFilial("BM1") +"'"
				cSQL += " AND BM1_PLNUCO = '" + cNumCob + "'"
				cSQL += " AND BM1_INTERC = '1' AND BM1.D_E_L_E_T_ = ' ' "
				cSQL += " AND BM1_PREFIX = '" + BBT->BBT_PREFIX +"'"
				cSQL += " AND BM1_NUMTIT = '" + BBT->BBT_NUMTIT +"'"
				cSQL += " AND BM1_PARCEL = '" + BBT->BBT_PARCEL +"'"
				cSQL += " AND BM1_TIPTIT = '" + BBT->BBT_TIPTIT +"'"
				cSQL += " AND BA1_CODINT = BM1.BM1_CODINT"
				cSQL += " AND BA1_CODEMP = BM1.BM1_CODEMP"
				cSQL += " AND BA1_MATRIC = BM1.BM1_MATRIC"
				cSQL += " AND BA1_TIPREG = BM1.BM1_TIPREG"
				cSQL += " AND BA1_DIGITO = BM1.BM1_DIGITO"
				cSQL += " AND BM1_CODTIP = '103' "
				cSQL += " AND BA1_NUMCOB = '" + cNumCob + "'"
				cSQL += " AND BA1.D_E_L_E_T_ = ' ') "

				If TcSqlExec( cSQL ) < 0
					FWLogMsg('WARN',, 'SIGAPLS', 'PLA627', '', '01','Erro na query de atualização:' + TCSQLError() , 0, 0, {})
				EndIf

				// Segundo UPDATE para o BM1_CODTIP = 103, atualiza os campos BA1_JACOBR,BA1_COBINI e BA1_ANOMES, se BA1_COBINI = cNumCob
				cSQL := "UPDATE " + BA1->(RetSQLName("BA1"))
				cSQL += " SET   BA1_JACOBR = '0', BA1_COBINI = ' ',  BA1_ANOMES = ' '"
				cSQL += " WHERE  R_E_C_N_O_ IN (SELECT BA1.R_E_C_N_O_ RECBA1 "
				cSQL += " FROM "   +BA1->(RetSQLName("BA1"))  +" BA1, "  +BM1->(RetSQLName("BM1"))  +" BM1 "
				cSQL += " WHERE  BA1_FILIAL =  '" + xFilial("BA1")  +"'"
				cSQL += " AND BM1_FILIAL = '" + xFilial("BM1") +"'"
				cSQL += " AND BM1_PLNUCO = '" + cNumCob + "'"
				cSQL += " AND BM1_INTERC = '1' AND BM1.D_E_L_E_T_ = ' ' "
				cSQL += " AND BM1_PREFIX = '" + BBT->BBT_PREFIX +"'"
				cSQL += " AND BM1_NUMTIT = '" + BBT->BBT_NUMTIT +"'"
				cSQL += " AND BM1_PARCEL = '" + BBT->BBT_PARCEL +"'"
				cSQL += " AND BM1_TIPTIT = '" + BBT->BBT_TIPTIT +"'"
				cSQL += " AND BA1_CODINT = BM1.BM1_CODINT"
				cSQL += " AND BA1_CODEMP = BM1.BM1_CODEMP"
				cSQL += " AND BA1_MATRIC = BM1.BM1_MATRIC"
				cSQL += " AND BA1_TIPREG = BM1.BM1_TIPREG"
				cSQL += " AND BA1_DIGITO = BM1.BM1_DIGITO"
				cSQL += " AND BM1_CODTIP = '103' "
				cSQL += " AND BA1_COBINI = '" + cNumCob + "'"
				cSQL += " AND BA1.D_E_L_E_T_ = ' ') "

				If TcSqlExec( cSQL ) < 0
					FWLogMsg('WARN',, 'SIGAPLS', 'PLA627', '', '01','Erro na query de atualização:' + TCSQLError() , 0, 0, {})
				EndIf

			Else

				// Primeiro UPDATE para o BM1_CODTIP = 103, atualiza os campos BA1_CBTXAD e BA1_VLTXAD
				cSQL := "UPDATE " +BA1->(RetSQLName("BA1"))
				cSQL += " SET BA1_CBTXAD = '0', BA1_VLTXAD = 0
				cSQL += " WHERE  R_E_C_N_O_ IN (SELECT BA1.R_E_C_N_O_ RECBA1 "
				cSQL += " FROM " + BA1->(RetSQLName("BA1"))  +" BA1, " + BM1->(RetSQLName("BM1"))  +" BM1 "
				cSQL += " WHERE  BA1_FILIAL =  '" + xFilial("BA1")  +"'"
				cSQL += " AND BM1_FILIAL = '" + xFilial("BM1") +"'"
				cSQL += " AND BM1_PLNUCO = '" + cNumCob + "'"
				cSQL += " AND BM1_INTERC = '0' AND BM1.D_E_L_E_T_ = ' ' "
				cSQL += " AND BM1_PREFIX = '" + BBT->BBT_PREFIX +"'"
				cSQL += " AND BM1_NUMTIT = '" + BBT->BBT_NUMTIT +"'"
				cSQL += " AND BM1_PARCEL = '" + BBT->BBT_PARCEL +"'"
				cSQL += " AND BM1_TIPTIT = '" + BBT->BBT_TIPTIT +"'"
				cSQL += " AND BA1_CODINT = BM1.BM1_CODINT"
				cSQL += " AND BA1_CODEMP = BM1.BM1_CODEMP"
				cSQL += " AND BA1_MATRIC = BM1.BM1_MATRIC"
				cSQL += " AND BA1_TIPREG = BM1.BM1_TIPREG"
				cSQL += " AND BA1_DIGITO = BM1.BM1_DIGITO"
				cSQL += " AND BM1_CODTIP = '103' "
				cSQL += " AND BA1_NUMCOB = '" + cNumCob + "'"
				cSQL += " AND BA1.D_E_L_E_T_ = ' ') "

				If TcSqlExec( cSQL ) < 0
					FWLogMsg('WARN',, 'SIGAPLS', 'PLA627', '', '01','Erro na query de atualização:' + TCSQLError() , 0, 0, {})
				EndIf

				// Segundo UPDATE para o BM1_CODTIP = 103, atualiza os campos BA1_JACOBR, BA1_COBINI e BA1_ANOMES se o BA1_COBINI for igual a cNumCob
				cSQL := "UPDATE " + BA1->(RetSQLName("BA1"))
				cSQL += " SET   BA1_JACOBR = '0', BA1_COBINI = ' ',  BA1_ANOMES = ' '"
				cSQL += " WHERE  R_E_C_N_O_ IN (SELECT BA1.R_E_C_N_O_ RECBA1 "
				cSQL += " FROM "   +BA1->(RetSQLName("BA1"))  +" BA1, "  +BM1->(RetSQLName("BM1"))  +" BM1 "
				cSQL += " WHERE  BA1_FILIAL =  '" + xFilial("BA1")  +"'"
				cSQL += " AND BM1_FILIAL = '" + xFilial("BM1") +"'"
				cSQL += " AND BM1_PLNUCO = '" + cNumCob + "'"
				cSQL += " AND BM1_INTERC = '0' AND BM1.D_E_L_E_T_ = ' ' "
				cSQL += " AND BM1_PREFIX = '" + BBT->BBT_PREFIX +"'"
				cSQL += " AND BM1_NUMTIT = '" + BBT->BBT_NUMTIT +"'"
				cSQL += " AND BM1_PARCEL = '" + BBT->BBT_PARCEL +"'"
				cSQL += " AND BM1_TIPTIT = '" + BBT->BBT_TIPTIT +"'"
				cSQL += " AND BA1_CODINT = BM1.BM1_CODINT"
				cSQL += " AND BA1_CODEMP = BM1.BM1_CODEMP"
				cSQL += " AND BA1_MATRIC = BM1.BM1_MATRIC"
				cSQL += " AND BA1_TIPREG = BM1.BM1_TIPREG"
				cSQL += " AND BA1_DIGITO = BM1.BM1_DIGITO"
				cSQL += " AND BM1_CODTIP = '103' "
				cSQL += " AND BA1_NUMCOB = '" + cNumCob + "'"
				cSQL += " AND BA1_COBINI = '" + cNumCob + "'"
				cSQL += " AND BA1.D_E_L_E_T_ = ' ') "
				If TcSqlExec( cSQL ) < 0
					FWLogMsg('WARN',, 'SIGAPLS', 'PLA627', '', '01','Erro na query de atualização:' + TCSQLError() , 0, 0, {})
				EndIf

				// Terceiro UPDATE para o BM1_CODTIP = 101, atualiza os campos BA1_JACOBR, BA1_COBINI e BA1_ANOMES se o BA1_COBINI for igual a cNumCob
				cSQL := "UPDATE "+BA1->(RetSQLName("BA1"))
				cSQL += " SET   BA1_JACOBR = '0', BA1_COBINI = ' ',  BA1_ANOMES = ' '"
				cSQL += " WHERE  R_E_C_N_O_ IN (SELECT BA1.R_E_C_N_O_ RECBA1 "
				cSQL += " FROM "   +BA1->(RetSQLName("BA1"))  +" BA1, "  +BM1->(RetSQLName("BM1"))  +" BM1 "
				cSQL += " WHERE  BA1_FILIAL =  '" + xFilial("BA1")  +"'"
				cSQL += " AND BM1_FILIAL = '" + xFilial("BM1") +"'"
				cSQL += " AND BM1_PLNUCO = '"+cNumCob +"'"
				cSQL += " AND BM1_INTERC = '0' AND BM1.D_E_L_E_T_ = ' ' "
				cSQL += " AND BM1_PREFIX = '" + BBT->BBT_PREFIX +"'"
				cSQL += " AND BM1_NUMTIT = '" + BBT->BBT_NUMTIT +"'"
				cSQL += " AND BM1_PARCEL = '" + BBT->BBT_PARCEL +"'"
				cSQL += " AND BM1_TIPTIT = '" + BBT->BBT_TIPTIT +"'"
				cSQL += " AND BA1_CODINT = BM1.BM1_CODINT"
				cSQL += " AND BA1_CODEMP = BM1.BM1_CODEMP"
				cSQL += " AND BA1_MATRIC = BM1.BM1_MATRIC"
				cSQL += " AND BA1_TIPREG = BM1.BM1_TIPREG"
				cSQL += " AND BA1_DIGITO = BM1.BM1_DIGITO"
				cSQL += " AND BM1_CODTIP = '101' "
				cSQL += " AND BA1_COBINI = '"+cNumCob +"'"
				cSQL += " AND BA1.D_E_L_E_T_ = ' ') "
				If TcSqlExec( cSQL ) < 0
					FWLogMsg('WARN',, 'SIGAPLS', 'PLA627', '', '01','Erro na query de atualização:' + TCSQLError() , 0, 0, {})
				EndIf

				//Taxa de adesao do opcional..
				cSQL := "UPDATE "+BA1->(RetSQLName("BA1"))
				cSQL += " SET   BA1_TXADOP = '0', BA1_VLTXOP = 0, BA1_VLTXAD = 0 "
				cSQL += " WHERE  R_E_C_N_O_ IN (SELECT BA1.R_E_C_N_O_ RECBA1 "
				cSQL += " FROM "   +BA1->(RetSQLName("BA1"))  +" BA1, "  +BM1->(RetSQLName("BM1"))  +" BM1 "
				cSQL += " WHERE  BA1_FILIAL =  '" + xFilial("BA1")  +"'"
				cSQL += " AND BM1_FILIAL = '" + xFilial("BM1") +"'"
				cSQL += " AND BM1_PLNUCO = '"+cNumCob +"'"
				cSQL += " AND BM1_INTERC = '0' AND BM1.D_E_L_E_T_ = ' ' "
				cSQL += " AND BM1_PREFIX = '" + BBT->BBT_PREFIX +"'"
				cSQL += " AND BM1_NUMTIT = '" + BBT->BBT_NUMTIT +"'"
				cSQL += " AND BM1_PARCEL = '" + BBT->BBT_PARCEL +"'"
				cSQL += " AND BM1_TIPTIT = '" + BBT->BBT_TIPTIT +"'"
				cSQL += " AND BA1_CODINT = BM1.BM1_CODINT"
				cSQL += " AND BA1_CODEMP = BM1.BM1_CODEMP"
				cSQL += " AND BA1_MATRIC = BM1.BM1_MATRIC"
				cSQL += " AND BA1_TIPREG = BM1.BM1_TIPREG"
				cSQL += " AND BA1_DIGITO = BM1.BM1_DIGITO"
				cSQL += " AND BM1_CODTIP = '133' "
				cSQL += " AND BA1.D_E_L_E_T_ = ' ') "
				If TcSqlExec( cSQL ) < 0
					FWLogMsg('WARN',, 'SIGAPLS', 'PLA627', '', '01','Erro na query de atualização:' + TCSQLError() , 0, 0, {})
				EndIf

				BZX->(DbSetOrder(2))//BZX_FILIAL + BZX_NUMCOB
				If BZX->(DbSeek( xFilial("BZX") + cNumCob ))

					While BZX->(!Eof()) .And. BZX->BZX_NUMCOB = cNumCob
						BZX->( RecLock("BZX", .F.) )
						BZX->BZX_NUMCOB := " "
						BZX->(MsUnLock())

						BZX->(DbSkip())
					EndDo

				EndIf

			EndIf

			//Desmarco as movimentacoes de debito / credito...
			BSQ->( dbSetorder(03) )//BSQ_FILIAL + BSQ_PREFIX + BSQ_NUMTIT + BSQ_PARCEL + BSQ_TIPTIT + BSQ_SEQ
			If BSQ->( dbSeek( xFilial("BSQ")+BBT->(BBT_PREFIX+BBT_NUMTIT+BBT_PARCEL) ) )

				While !BSQ->( Eof() ) .And. BSQ->(BSQ_FILIAL+BSQ_PREFIX+BSQ_NUMTIT+BSQ_PARCEL) ==	BBT->(BBT_FILIAL+BBT_PREFIX+BBT_NUMTIT+BBT_PARCEL)
					AaDd( aRegs, BSQ->( Recno() ) )
					BSQ->( dbSkip() )
				EndDo

			EndIf

			//For nos registros bsq
			BSP->( dbSetorder(01) )
			BSQ->( dbSetorder(09) )

			For nCnt := 1 To Len(aRegs)

				BSQ->( DbGoto(aRegs[nCnt]) )

				// Reset.
				lExclui := .F.

				If !BSQ->( Eof() )

					If BSP->( dbSeek(xFilial("BSP") + BSQ->BSQ_CODLAN) )

						// Se o credito estiver vinculado ao credito de reembolso patronal ele será excluido ao invez de estornado.
						If BSP->BSP_CODLAN == "188"
							lExclui := .T.
						Endif

					Endif

					BSQ->( RecLock("BSQ", .F.) )

					If BSQ->BSQ_AUTOMA == "X" .or. lExclui
						BSQ->( DbDelete() )
					Else
						BSQ->BSQ_NUMCOB := ''
						BSQ->BSQ_PREFIX := ''
						BSQ->BSQ_NUMTIT := ''
						BSQ->BSQ_PARCEL := ''
						BSQ->BSQ_TIPTIT := ''
					EndIf

					BSQ->( MsUnlock() )
				EndIf
			Next

			//Desmarco as movimentacoes de co-participacao e custo operacional...
			aRegs := {}

			//Fixado...
			If SIX->(dbSeek("BDH8"))

				BDH->(DbSetOrder(8))

				If BDH->(DbSeek(xFilial("BDH")+AllTrim(BBT->(BBT_PREFIX+BBT_NUMTIT+BBT_PARCEL+BBT_TIPTIT))))

					While ! BDH->(Eof()) .And.	xFilial("BDH")+AllTrim(BBT->(BBT_PREFIX+BBT_NUMTIT+BBT_PARCEL+BBT_TIPTIT)) ==;
							xFilial("BDH")+AllTrim(BDH->(BDH_PREFIX+BDH_NUMTIT+BDH_PARCEL+BDH_TIPTIT))

						AaDd(aRegs,BDH->(Recno()))

						BDH->(DbSkip())
					Enddo

				EndIf

			Else

				BDH->(DbSetOrder(5))
				If BDH->(DbSeek(xFilial("BDH")+BBT->BBT_CODOPE+BBT->BBT_NUMCOB))

					While ! BDH->(Eof()) .And. BDH->(BDH_FILIAL+BDH_OPEFAT+BDH_NUMFAT) == xFilial("BDH")+BBT->BBT_CODOPE+BBT->BBT_NUMCOB

						If AllTrim(BBT->(BBT_PREFIX+BBT_NUMTIT+BBT_PARCEL+BBT_TIPTIT)) == AllTrim(BDH->BDH_NUMSE1)
							AaDd(aRegs,BDH->(Recno()))
						EndIf

						BDH->(DbSkip())
					Enddo

				EndIf

			EndIf

			//nova funcao que alem de atualizar o bdh atualiza as notas e eventos. plsmctmd.prw
			If ! FindFunction("PLSNOTXBDH")

				For nForReg := 1 To Len(aRegs)

					BDH->(DbGoTo(aRegs[nForReg]))
					BDH->(RecLock("BDH",.F.))
					BDH->BDH_STATUS := "1"
					BDH->BDH_OPEFAT := ""
					BDH->BDH_NUMFAT := ""
					BDH->BDH_NUMSE1 := ""
					BDH->(MsUnLock())

				Next

			Else

				For nForReg := 1 To Len(aRegs)
					BDH->(DbGoTo(aRegs[nForReg]))
					PLSNOTXBDH("1","","",{"","","",""},.F.)
				Next

			EndIf
			aRegs := {}

			//Exclui o bm1 da fatura.
			cSql := "UPDATE " + RetSQLName("BM1") + " SET D_E_L_E_T_ = '*' WHERE BM1_FILIAL = '"+ xFilial("BM1") +"' "
			cSql += "AND BM1_PREFIX = '" + BBT->BBT_PREFIX + "' "
			cSql += "AND BM1_NUMTIT = '" + BBT->BBT_NUMTIT + "' "
			cSql += "AND BM1_PARCEL = '" + BBT->BBT_PARCEL + "' "
			cSql += "AND BM1_TIPTIT = '" + BBT->BBT_TIPTIT + "' "
			cSql += "AND D_E_L_E_T_ = ' ' "

			TCSQLExec(cSql)

			If PLSALIASEX("BK2") .And. BK2->(FieldPos("BK2_SALDO")) > 0 .And. BK2->(FieldPos("BK2_DIGITO")) > 0 .And. BK2->(FieldPos("BK2_PLNUCO")) > 0

				// Tratamento para arcelamento
				If BK2->(FieldPos("BK2_PARCEL")) > 0

					cSQL := "UPDATE "+RetSqlName("BK2")+" SET BK2_LOTPAR = '',BK2_PLNUCO = '' "
					cSQL += "WHERE BK2_PLNUCO = '"+cNumCob+"' AND "
					cSQL += "BK2_PARCEL <> '' AND " // Indica que utiliza a rotina de parcelamento
					cSQL += "BK2_LOTPAR = 'S' AND " // Indica se ja foi faturado
					cSQL += "D_E_L_E_T_ = ' '"
					TCSQLExec(cSQL)

					cSQL := "SELECT BK2.R_E_C_N_O_ RECBK2 FROM " + RetSQLName("BK2") + " BK2 WHERE "+;
						"BK2_FILIAL = '"+xFilial("BK2")+"' AND "+;
						"BK2_PLNUCO = '"+cNumCob	   +"' AND "+;
						"BK2_PARCEL = '' AND "+;
						"D_E_L_E_T_ = ' '"

					cSQL := ChangeQuery(cSQL)

					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)

					Do While ! TRB->(Eof())

						BK2->(DbGoTo(TRB->RECBK2))

						BK2->(RecLock("BK2", .F.))
						BK2->(DbDelete())
						BK2->(MsUnlock())

						TRB->(DbSkip())
					EndDo

					TRB->(DbCloseArea())

				Else

					cSQL := "SELECT BK2.R_E_C_N_O_ RECBK2 FROM " + RetSQLName("BK2") + " BK2 WHERE "+;
						"BK2_FILIAL = '"+xFilial("BK2")+"' AND "+;
						"BK2_PLNUCO = '"+cNumCob	   +"' AND "+;
						"D_E_L_E_T_ = ' '"

					cSQL := ChangeQuery(cSQL)

					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)

					Do While ! TRB->(Eof())

						BK2->(DbGoTo(TRB->RECBK2))

						BK2->(RecLock("BK2", .F.))
						BK2->(DbDelete())
						BK2->(MsUnlock())

						TRB->(DbSkip())
					EndDo

					TRB->(DbCloseArea())
				EndIf

			EndIf

			If BKD->(FieldPos("BKD_PLNUCO")) > 0

				cSQL := "SELECT BKD.R_E_C_N_O_ RECBKD FROM " + RetSQLName("BKD") + " BKD WHERE "
				cSQL += "BKD_FILIAL = '"+xFilial("BKD")+"' AND "
				cSQL += "BKD_PLNUCO = '"+cNumCob	   +"' AND "
				cSQL += "D_E_L_E_T_ = ' '"
				cSQL := ChangeQuery(cSQL)

				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)

				Do While ! TRB->(Eof())

					BKD->(DbGoTo(TRB->RECBKD))

					BKD->(RecLock("BKD", .F.))
					BKD->BKD_PLNUCO := ''
					BKD->BKD_CHVSE1 := ''
					BKD->(MsUnlock())

					TRB->(DbSkip())
				EndDo

				TRB->(DbCloseArea())
			EndIf

			If PLSALIASEXI("B44")

				cSQL := "SELECT B44.R_E_C_N_O_ RECB44 FROM " + RetSQLName("B44") + " B44 WHERE B44_FILIAL = '"+xFilial("B44")+"' AND " +;
					"B44_PREFIX = '" 	+ BBT->BBT_PREFIX + "' AND " +;
					"B44_NUM = '" 		+ BBT->BBT_NUMTIT + "' AND " +;
					"B44_PARCEL = '" 	+ BBT->BBT_PARCEL + "' AND " +;
					"B44_TIPO = '" 		+ BBT->BBT_TIPTIT + "' AND D_E_L_E_T_ = ' '"

				cSQL := ChangeQuery(cSQL)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)

				Do While ! TRB->(Eof())

					B44->(DbGoTo(TRB->RECB44))

					If lDatPagto

						BCI->(DbSetOrder(5))//BCI_FILIAL, BCI_OPERDA, BCI_CODRDA, BCI_CODOPE, BCI_CODLDP, BCI_CODPEG, BCI_FASE, BCI_SITUAC
						If BCI->(MsSeek(xFilial("BCI")+B44->(B44_OPERDA+B44_CODRDA+B44_CODEMP+B44_CODLDP+B44_CODPEG)))

							BD5->(DbSetOrder(1))//BD5_FILIAL, BD5_CODOPE, BD5_CODLDP, BD5_CODPEG, BD5_NUMERO, BD5_SITUAC, BD5_FASE, BD5_DATPRO, BD5_OPERDA, BD5_CODRDA
							If BD5->(MsSeek(xFilial("BD5")+BCI->(BCI_OPERDA+BCI_CODLDP+BCI_CODPEG) +B44->B44_NUMGUI+ BCI->(BCI_SITUAC+BCI_FASE)))

								// Retorna a Fase
								BD5->(Reclock("BD5",.F.))
								BD5->BD5_FASE := "3" // Pronto
								BD5->(MsUnlock())

								//Atualiza status	PEG
								PLSM190Pro( ,,,,,,,,,,,,.T.,BCI->(Recno()) )

								//Atualiza data de Processamento
								BXU->(dbsetOrder(3))//BXU_FILIAL+BXU_CODINT+DTOS(BXU_DATPAG)+BXU_REEMB
								If BXU->(MsSeek(xFilial("BXU")+BD5->BD5_CODOPE+dtos(BCI->BCI_DATPAG)+"1"))
									If !Empty(BXU->BXU_DATPRO)
										BXU->(RecLock("BXU", .F.))
										BXU->BXU_DATPRO := ctod("")
										BXU->(MsUnlock())
									Endif
								Endif

							Endif
						Endif
					Endif

					B44->(RecLock("B44", .F.))
					B44->B44_PREFIX := ''
					B44->B44_NUM    := ''
					B44->B44_PARCEL := ''
					B44->B44_TIPO   := ''
					B44->(MsUnlock())

					//Se estiver vinculado a um protocolo de reembolso atualiza o protocolo
					If B44->(FieldPos("B44_PROTOC")) > 0 .AND. !Empty( AllTrim(B44->B44_PROTOC));
							.AND. PLSALIASEXI("BOW") .AND. PLSALIASEXI("BOX")

						BOW->(DbSetOrder(1))
						BOW->(DbSeek(xFilial('BOW') + B44->B44_PROTOC ))

						//Altera o Status do Protocolo
						BOW->(RecLock('BOW',.F.))
						BOW->BOW_PREFIX := ''
						BOW->BOW_NUM    := ''
						BOW->BOW_PARCEL := ''
						BOW->BOW_TIPO   := ''
						BOW->( MsUnlock() )

						//Retorna a fase da PEG para PRONTA
						BD5->(DbSetOrder(1))
						If BD5->(MsSeek(xFilial("BD5")+BOW->(BOW_OPEMOV+BOW_CODLDP+BOW_CODPEG+BOW_NUMAUT)))

							BD5->(RecLock('BD5',.F.))
							BD5->BD5_FASE := '3'
							BD5->( MsUnlock() )

							BD6->(DbSetOrder(1))
							BD7->(DbSetOrder(11))
							If BD6->(MsSeek(xFilial("BD6")+BOW->(BOW_OPEMOV+BOW_CODLDP+BOW_CODPEG+BOW_NUMAUT)))

								While !BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == BOW->(BOW_FILIAL+BOW_OPEMOV+BOW_CODLDP+BOW_CODPEG+BOW_NUMAUT)

									BD6->(RecLock('BD6',.F.))
									BD6->BD6_FASE := '3'
									BD6->( MsUnlock() )

									If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO)))

										While !BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO) == ;
												BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO)

											BD7->(RecLock('BD7',.F.))
											BD7->BD7_FASE := '3'
											BD7->( MsUnlock() )

											BD7->(DbSkip())
										EndDo

									EndIf

									BD6->(DbSkip())
								EndDo

							EndIf

						EndIf

						//Grava o histórico
						PLGRVBOX(BOW->BOW_PROTOC,BOW->BOW_MATRIC,BOW->BOW_STATUS, BOW->BOW_NUMAUT, /*cNumCC*/,;
							/*dDtBaix*/, /*cObs*/, BOW->BOW_CODLDP, BOW->BOW_CODPEG, BOW->BOW_ORIMOV,BOW->BOW_NF)

					EndIf

					TRB->(DbSkip())
				EndDo

				TRB->(DbCloseArea())
			EndIf

			If PLSALIASEX("B1T")

				cSQL := "SELECT B1T.R_E_C_N_O_ RECB1T FROM " + RetSQLName("B1T") + " B1T WHERE "+;
					"B1T_FILIAL = '"+xFilial("B1T")+"' AND "+;
					"B1T_PLNUCO = '"+cNumCob	   +"' AND "+;
					"D_E_L_E_T_ = ' '"

				cSQL := ChangeQuery(cSQL)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)

				Do While ! TRB->(Eof())

					B1T->(DbGoTo(TRB->RECB1T))

					B1T->(RecLock("B1T", .F.))
					B1T->(DbDelete())
					B1T->(MsUnlock())

					TRB->(DbSkip())
				EndDo

				TRB->(DbCloseArea())
			EndIf

			If  SRC->(FieldPos("RC_PLNUCO"))  > 0

				cSQL := "SELECT SRC.R_E_C_N_O_ RECSRC FROM " + RetSQLName("SRC") + " SRC WHERE " +;
					"RC_PLNUCO = '"+ cNumCob +"' AND "+;
					"D_E_L_E_T_ = ' '"
				cSQL := ChangeQuery(cSQL)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)

				Do While ! TRB->(Eof())

					SRC->(DbGoTo(TRB->RECSRC))

					SRC->(RecLock("SRC", .F.))
					SRC->(DbDelete())
					SRC->(MsUnlock())

					TRB->(DbSkip())
				EndDo

				TRB->(DbCloseArea())
			EndIf

			If (PLSALIASEX("RHR"))

				If  RHR->(FieldPos("RHR_PLNUCO"))  > 0
					cSQL := "DELETE FROM " + RetSQLName("RHR") + " WHERE " +;
						"RHR_PLNUCO = '"+ cNumCob +"' AND "+;
						"D_E_L_E_T_ = ' '"
					TCSqlExec(cSql)
				EndIf

			Endif

			If (PLSALIASEX("RHO"))

				If  RHO->(FieldPos("RHO_PLNUCO"))  > 0

					cSQL := "DELETE FROM " + RetSQLName("RHO") + " WHERE " +;
						"RHO_PLNUCO = '"+ cNumCob +"' AND "+;
						"D_E_L_E_T_ = ' '"
					TCSqlExec(cSql)

				Endif

			EndIf

			//Deleta o BBT.
			BBT->(RecLock("BBT",.F.))
			BBT->(DbDelete())
			BBT->(MsUnLock())

		endIf

	END TRANSACTION

Return(lRet)

/*/{Protheus.doc} PLSA625Cd
Retorna proximo codigo da sequencia

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLSA625Cd(_cCampo,_cAlias,_cIndice,_cCpoPula,cVlrPula)
	LOCAL nRet    	:= 0
	LOCAL cFiltro	:= ""
	LOCAL cArea		:= Alias()
	LOCAL cNomeCpo 	:= _cAlias + "->" + _cCampo
	LOCAL TAM 		:= Len(&cNomeCpo)
	LOCAL lHelpSalv := IF(Type('Help')=="L",Help,.F.)
	local aCpoPula := {}
	local ni
	local nTamanho := 1
	local cWhere := ""

	DEFAULT _cIndice := 1

	If At(_cAlias+"->(", _cCpoPula) > 0
		_cCpoPula := Subs(_cCpoPula, At(_cAlias+"->(", _cCpoPula) + 6, Len(_cCpoPula))
		_cCpoPula := Left(_cCpoPula, Len(_cCpoPula) - 1)
		If AT("+",_cCpoPula)> 0

			aCpoPula := strTokArr(_cCpoPula,"+")

			for ni := 1 to len(aCpoPula)

				nTamSx3 := tamSx3(aCpoPula[ni])[1]

				iF !("FILIAL" $ UPPER(aCpoPula[ni]))
					if ( ni == len(aCpoPula) )
						cWhere += aCpoPula[ni] + " = '" + subStr(cVlrPula,nTamanho,nTamSx3)
					else
						cWhere += aCpoPula[ni] + " = '" + subStr(cVlrPula,nTamanho,nTamSx3) + "' AND "
					endif
				EndIf

				nTamanho := nTamSx3 + nTamanho

			next ni

		EndIf
	EndIf

	if Substr(_cAlias,1,2) >= "SA" .And. Substr(_cAlias,1,2) <= "SX"
		cATmp := Substr(_cAlias,2,2)
	Else
		cATmp := Substr(_cAlias,1,3)
	EndIf

	cFiltro	:= 	"SELECT MAX(" + _cCampo + ") CONTADOR FROM " + RetSqlName(_cAlias) + " " +;
		"WHERE " + cATmp + "_FILIAL = '" + xFilial(_cAlias) + "' AND " +;
		iif(!empty(cWhere),cWhere,_cCpoPula + "= '" + cVlrPula) + "' AND D_E_L_E_T_ <> '*'"

	cFiltro := ChangeQuery(cFiltro)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cFiltro),"CONTADOR",.F.,.T.)

	If ValType(CONTADOR) = "C"
		nRet := Soma1(CONTADOR)
	Else
		nRet := StrZero(Val(CONTADOR)+1,TAM)
	EndIf

	FreeUsedCode(.T.)
	Help := .T.	// Nao apresentar Help MayUse
	While !FreeForUse(_cAlias,Alltrim(cVlrPula+nRet),.F.)
		nRet := Soma1(nRet)
		Help := .T.	// Nao apresentar Help MayUse
	Enddo

	CONTADOR->( DbCloseArea() )

	Help := lHelpSalv

	If ! Empty(cArea)
		DbSelectArea(cArea)
	EndIf



Return(nRet)

/*/{Protheus.doc} PLS625Bdw
Efetua validacao dos campos chaves do detalhe de cobranca

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLS625Bdw()
	LOCAL nCols		  := 0
	LOCAL nLinha 	  := oBrwBDW:Linha()
	LOCAL nLinAdd	  := If(oBrwBDW:lInAddLine, n, nLinha)
	LOCAL nBDW_CODEMP := oBrwBDW:PLRETPOS("BDW_CODEMP")
	LOCAL nBDW_CONEMP := oBrwBDW:PLRETPOS("BDW_CONEMP")
	LOCAL nBDW_VERCON := oBrwBDW:PLRETPOS("BDW_VERCON")
	LOCAL nBDW_SUBCON := oBrwBDW:PLRETPOS("BDW_SUBCON")
	LOCAL nBDW_VERSUB := oBrwBDW:PLRETPOS("BDW_VERSUB")
	LOCAL cBDW_CODEMP := If(nLinAdd > Len(oBrwBDW:aCols), "", oBrwBDW:aCols[nLinAdd, nBDW_CODEMP])
	LOCAL cBDW_CONEMP := If(nLinAdd > Len(oBrwBDW:aCols), "", oBrwBDW:aCols[nLinAdd, nBDW_CONEMP])
	LOCAL cBDW_VERCON := If(nLinAdd > Len(oBrwBDW:aCols), "", oBrwBDW:aCols[nLinAdd, nBDW_VERCON])
	LOCAL cBDW_SUBCON := If(nLinAdd > Len(oBrwBDW:aCols), "", oBrwBDW:aCols[nLinAdd, nBDW_SUBCON])
	LOCAL cBDW_VERSUB := If(nLinAdd > Len(oBrwBDW:aCols), "", oBrwBDW:aCols[nLinAdd, nBDW_VERSUB])
	LOCAL lRet 		  := .T.

	If 	! Empty(M->BDW_CODEMF) .And. M->BDW_CODEMF < M->BDW_CODEMP
		Help("",1,"BDW_CODEMF")
		Return .F.
	EndIf

	If 	! Empty(M->BDW_CONEMP) .And. ! Empty(M->BDW_CODEMF) .And.;
			((M->BDW_CODEMF + M->BDW_CONEMF + M->BDW_VERCOF <;
			M->BDW_CODEMP + M->BDW_CONEMP + M->BDW_VERCON) .Or. Empty(M->BDW_CONEMF))
		Help("",1,"BDW_CONEMF")
		Return .F.
	EndIf

	If 	! Empty(M->BDW_SUBCON) .And. ! Empty(M->BDW_CODEMF) .And.;
			((M->BDW_CODEMF + M->BDW_CONEMF + M->BDW_VERCOF + M->BDW_SUBCOF + M->BDW_VERSUF <;
			M->BDW_CODEMP + M->BDW_CONEMP + M->BDW_VERCON + M->BDW_SUBCON + M->BDW_VERSUB) .Or.;
			Empty(M->BDW_SUBCOF))
		Help("",1,"BDW_SUBCOF")
		Return .F.
	EndIf

	If ! Empty(M->BDW_CONEMP) .And. Empty(M->BDW_VERCON)
		Help("",1,"BDW_VERCON")
		Return .F.
	EndIf

	If ! Empty(M->BDW_CONEMF) .And. Empty(M->BDW_VERCOF)
		Help("",1,"BDW_VERCOF")
		Return .F.
	EndIf

	If ! Empty(M->BDW_SUBCON) .And. Empty(M->BDW_VERSUB)
		Help("",1,"BDW_VERCON")
		Return .F.
	EndIf

	If ! Empty(M->BDW_SUBCOF) .And. Empty(M->BDW_VERSUF)
		Help("",1,"BDW_VERSUF")
		Return .F.
	EndIf

	If nLinAdd <= Len(oBrwBDW:aCols)
		oBrwBDW:aCols[nLinAdd, nBDW_CODEMP] := M->BDW_CODEMP
		oBrwBDW:aCols[nLinAdd, nBDW_CONEMP] := M->BDW_CONEMP
		oBrwBDW:aCols[nLinAdd, nBDW_VERCON] := M->BDW_VERCON
		oBrwBDW:aCols[nLinAdd, nBDW_SUBCON] := M->BDW_SUBCON
		oBrwBDW:aCols[nLinAdd, nBDW_VERSUB] := M->BDW_VERSUB
	EndIf

	For nCols := 1 To Len(oBrwBDW:aCols)
		If  ! oBrwBDW:IsDeleted(nCols) .And. nCols <> nLinAdd .And.;
				((oBrwBDW:aCols[nCols, nBDW_CODEMP] = M->BDW_CODEMP .And.;
				oBrwBDW:aCols[nCols, nBDW_CONEMP] = M->BDW_CONEMP .And.;
				oBrwBDW:aCols[nCols, nBDW_VERCON] = M->BDW_VERCON .And.;
				oBrwBDW:aCols[nCols, nBDW_SUBCON] = M->BDW_SUBCON .And.;
				oBrwBDW:aCols[nCols, nBDW_VERSUB] = M->BDW_VERSUB) .Or.;
				(oBrwBDW:aCols[nCols, nBDW_CODEMP] = M->BDW_CODEMP .And.;
				Empty(	oBrwBDW:aCols[nCols, nBDW_CONEMP] +;
				oBrwBDW:aCols[nCols, nBDW_VERCON] +;
				oBrwBDW:aCols[nCols, nBDW_SUBCON] +;
				oBrwBDW:aCols[nCols, nBDW_VERSUB])) .Or.;
				(oBrwBDW:aCols[nCols, nBDW_CODEMP] = M->BDW_CODEMP .And.;
				oBrwBDW:aCols[nCols, nBDW_CONEMP] = M->BDW_CONEMP .And.;
				oBrwBDW:aCols[nCols, nBDW_VERCON] = M->BDW_VERCON .And.;
				Empty(	oBrwBDW:aCols[nCols, nBDW_SUBCON] +;
				oBrwBDW:aCols[nCols, nBDW_VERSUB])) .Or.;
				(oBrwBDW:aCols[nCols, nBDW_CODEMP] = M->BDW_CODEMP .And.;
				oBrwBDW:aCols[nCols, nBDW_CONEMP] = M->BDW_CONEMP .And.;
				oBrwBDW:aCols[nCols, nBDW_VERCON] = M->BDW_VERCON .And.;
				! Empty(oBrwBDW:aCols[nCols, nBDW_SUBCON] +;
				oBrwBDW:aCols[nCols, nBDW_VERSUB]) .And.;
				Empty(M->BDW_SUBCON + M->BDW_VERSUB)) .Or.;
				(oBrwBDW:aCols[nCols, nBDW_CODEMP] = M->BDW_CODEMP .And.;
				Empty(	M->BDW_CONEMP + M->BDW_VERCON + M->BDW_SUBCON+;
				M->BDW_VERSUB) .And.;
				! Empty(oBrwBDW:aCols[nCols, nBDW_CONEMP] +;
				oBrwBDW:aCols[nCols, nBDW_VERCON] +;
				oBrwBDW:aCols[nCols, nBDW_SUBCON] +;
				oBrwBDW:aCols[nCols, nBDW_VERSUB])))
			Help("",1,"JAGRAVADO")
			lRet := .F.
			Exit
		EndIf
	Next

	If nLinAdd <= Len(oBrwBDW:aCols)
		oBrwBDW:aCols[nLinAdd, nBDW_CODEMP] := cBDW_CODEMP
		oBrwBDW:aCols[nLinAdd, nBDW_CONEMP] := cBDW_CONEMP
		oBrwBDW:aCols[nLinAdd, nBDW_VERCON] := cBDW_VERCON
		oBrwBDW:aCols[nLinAdd, nBDW_SUBCON] := cBDW_SUBCON
		oBrwBDW:aCols[nLinAdd, nBDW_VERSUB] := cBDW_VERSUB
	EndIf



Return lRet

/*/{Protheus.doc} Pl625CarSE1
Exibe a legenda...

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function Pl625CarSE1(	aCobranca, nCols, nLido, nBDF_PREFIX, nBDF_NUMTIT, nBDF_PARCEL,;
		nBDF_TIPTIT, nBDF_TIPO, aSE1, cTipo, cNumCob)
	LOCAL nHeader		:= 0
	LOCAL nCnt 			:= 0
	LOCAL nE1_PREFIXO 	:= Ascan(aCabSE1G, { |x| AllTrim(x[2]) = "E1_PREFIXO" })
	LOCAL nE1_NUM 		:= Ascan(aCabSE1G, { |x| AllTrim(x[2]) = "E1_NUM" })
	LOCAL nE1_PARCELA 	:= Ascan(aCabSE1G, { |x| AllTrim(x[2]) = "E1_PARCELA" })
	LOCAL nE1_TIPO 		:= Ascan(aCabSE1G, { |x| AllTrim(x[2]) = "E1_TIPO" })
	LOCAL cAlias		:= If(cTipo = "2", "BTV", "SE1")


	SE1->(DbSetOrder(01))
	BTV->(dbSetorder(01))

	For nCnt := 1 To Len(aCobranca)

		If Ascan(aSE1, { |x| 	x[nE1_PREFIXO] 	= aCobranca[nCnt][nBDF_PREFIX] .And.;
				x[nE1_NUM] 		= aCobranca[nCnt][nBDF_NUMTIT] .And.;
				x[nE1_PARCELA] 	= aCobranca[nCnt][nBDF_PARCEL] .And.;
				x[nE1_TIPO] 	= aCobranca[nCnt][nBDF_TIPTIT] }) = 0

			If SE1->(MsSeek(xFilial("SE1") + aCobranca[nCnt][nBDF_PREFIX] +aCobranca[nCnt][nBDF_NUMTIT]) )

				While !SE1->(Eof()) .and.  SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == CFILANT + aCobranca[nCnt][nBDF_PREFIX] +aCobranca[nCnt][nBDF_NUMTIT]

					//Garante integridade do lote.
					If SE1->E1_PLNUCOB <> cNumCob
						SE1->(DbSkip())
						Loop
					EndIf

					nLido ++

					If nLido > nCols
						Aadd(aSE1, AClone(aSE1[1]))
						nCols ++
					EndIf

					If SE1->E1_VALOR = SE1->E1_SALDO
						aSE1[nCols][1] := "ENABLE"
					ElseIf SE1->E1_SALDO = 0
						aSE1[nCols][1] := "DISABLE"
					Else
						aSE1[nCols][1] := "BR_AZUL"
					EndIf

					For nHeader := 2 To Len(aCABSE1G)
						If SE1->( FieldPos(AllTrim(aCabSE1G[nHeader][2])) ) > 0
							aSE1[nCols][nHeader] := &(cAlias + "->" + AllTrim(aCabSE1G[nHeader][2]))
						EndIf
					Next

					lDadNiv[8] := 0

					SE1->(DbSkip())
				EndDo

			Endif

		EndIf
	Next

Return .T.

/*/{Protheus.doc} PLS625Vld
Efetua validacao dos campos chaves do detalhe de cobranca

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLS625Vld()
	LOCAL lRet 		:= .T.
	LOCAL cFunName	:= FunName()

	//Validacao do preenchimento dos campos que chamam a funcao

	If ReadVar() = "M->BDW_CODEMP" .And. ! Empty(M->BDW_CODEMP)
		lRet := BG9->(MsSeek(xFilial("BG9") + cCodInt+M->BDW_CODEMP)) .And.;
			BT5->(MsSeek(xFilial("BT5") + cCodInt+M->BDW_CODEMP))
		If ! lRet .Or. (BT5->BT5_INTERC = "1" .And. cFunName = "PLSA625")
			Help("",1,"REGNOIS")
			lRet := .F.
		Else
			M->BDW_CONEMP := Space(Len(M->BDW_CONEMP))
			M->BDW_VERCON := Space(Len(M->BDW_VERCON))
			M->BDW_SUBCON := Space(Len(M->BDW_SUBCON))
			M->BDW_VERSUB := Space(Len(M->BDW_VERCON))
			M->BDW_DESCRI := BG9->BG9_DESCRI
		EndIf
	ElseIf ReadVar() = "M->BDW_CODEMF" .And. ! Empty(M->BDW_CODEMF)	// Empresa Final
		lRet := BG9->(MsSeek(xFilial("BG9") + cCodInt+M->BDW_CODEMF)) .And.;
			BT5->(MsSeek(xFilial("BT5") + cCodInt+M->BDW_CODEMF))
		If ! lRet .Or. (BT5->BT5_INTERC = "1" .And. cFunName = "PLSA625")
			Help("",1,"REGNOIS")
			lRet := .F.
		Else
			M->BDW_CONEMF := Space(Len(M->BDW_CONEMF))
			M->BDW_VERCOF := Space(Len(M->BDW_VERCOF))
			M->BDW_SUBCOF := Space(Len(M->BDW_SUBCOF))
			M->BDW_VERSUF := Space(Len(M->BDW_VERCOF))
			M->BDW_DESCRF := BG9->BG9_DESCRI
		EndIf
	ElseIf ReadVar() = "M->BDW_CONEMP" .And. ! Empty(M->BDW_CONEMP)
		lRet := ExistCpo("BT5",cCodInt+M->BDW_CODEMP+M->BDW_CONEMP)
		If lRet		// Gatilho o campo
			M->BDW_VERCON := BT5->BT5_VERSAO
			M->BDW_SUBCON := Space(Len(M->BDW_SUBCON))
			M->BDW_VERSUB := Space(Len(M->BDW_VERCON))

		EndIf

		//Contrato Final

	ElseIf ReadVar() = "M->BDW_CONEMF" .And. ! Empty(M->BDW_CONEMF)
		lRet := ExistCpo("BT5",cCodInt+M->BDW_CODEMP+M->BDW_CONEMF)

		//Gatilho o campo

		If lRet
			If BT5->BT5_INTERC = "1" .And. cFunName = "PLSA625"
				Help("",1,"REGNOIS")
				lRet := .F.
			Else
				M->BDW_VERCOF := BT5->BT5_VERSAO
				M->BDW_SUBCOF := Space(Len(M->BDW_SUBCOF))
				M->BDW_VERSUF := Space(Len(M->BDW_VERCOF))
			EndIf

		EndIf
	ElseIf ReadVar() = "M->BDW_VERCON" .And. ! Empty(M->BDW_VERCON)
		lRet := ExistCpo("BT5",cCODINT+M->BDW_CODEMP+M->BDW_CONEMP+M->BDW_VERCON)
	ElseIf ReadVar() = "M->BDW_VERCOF" .And. ! Empty(M->BDW_VERCOF)
		lRet := ExistCpo("BT5",cCODINT+M->BDW_CODEMF+M->BDW_CONEMF+M->BDW_VERCOF)
	ElseIf ReadVar() = "M->BDW_SUBCON" .And. ! Empty(M->BDW_SUBCON)
		lRet := ExistCpo("BQC",cCODINT+M->BDW_CODEMP+M->BDW_CONEMP+M->BDW_VERCON+M->BDW_SUBCON)

		//Gatilho o campo

		If lRet

			M->BDW_VERSUB := BQC->BQC_VERSUB

		EndIf
	ElseIf ReadVar() = "M->BDW_SUBCOF" .And. ! Empty(M->BDW_SUBCOF)	// Sub-Contrato Final
		lRet := ExistCpo("BQC",cCODINT+M->BDW_CODEMF+M->BDW_CONEMF+M->BDW_VERCOF+M->BDW_SUBCOF)

		//Gatilho o campo

		If lRet

			M->BDW_VERSUF := BQC->BQC_VERSUB

		EndIf
	ElseIf ReadVar() = "M->BDW_VERSUB" .And. ! Empty(M->BDW_VERSUB)
		lRet := ExistCpo("BQC",cCODINT+M->BDW_CODEMP+M->BDW_CONEMP+M->BDW_VERCON+M->BDW_SUBCON+M->BDW_VERSUB)
	ElseIf ReadVar() = "M->BDW_VERSUF" .And. ! Empty(M->BDW_VERSUF)
		lRet := ExistCpo("BQC",cCODINT+M->BDW_CODEMF+M->BDW_CONEMF+M->BDW_VERCOF+M->BDW_SUBCOF+M->BDW_VERSUF)
	EndIf



Return lRet


/*/{Protheus.doc} PLS625Ope
Permite a digitacao da operadora caso nao tenha contratos

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLS625Ope
	LOCAL lRet 	 := .T.
	LOCAL nCols  := 0
	LOCAL nLinha := 0
	LOCAL nBDW_CODEMP, nBDW_CONEMP, nBDW_VERCON, nBDW_SUBCON, nBDW_VERSUB
	LOCAL cBDW_CODEMP, cBDW_CONEMP, cBDW_VERCON, cBDW_SUBCON, cBDW_VERSUB

	If Type("M->BDC_TIPO") <> "U" .And. M->BDC_TIPO = "2"
		Return .T.
	Else
		nLinha := oBrwBDW:Linha()
		nBDW_CODEMP := oBrwBDW:PLRETPOS("BDW_CODEMP")
		nBDW_CONEMP := oBrwBDW:PLRETPOS("BDW_CONEMP")
		nBDW_VERCON := oBrwBDW:PLRETPOS("BDW_VERCON")
		nBDW_SUBCON := oBrwBDW:PLRETPOS("BDW_SUBCON")
		nBDW_VERSUB := oBrwBDW:PLRETPOS("BDW_VERSUB")
		cBDW_CODEMP := oBrwBDW:aCols[nLinha, nBDW_CODEMP]
		cBDW_CONEMP := oBrwBDW:aCols[nLinha, nBDW_CONEMP]
		cBDW_VERCON := oBrwBDW:aCols[nLinha, nBDW_VERCON]
		cBDW_SUBCON := oBrwBDW:aCols[nLinha, nBDW_SUBCON]
		cBDW_VERSUB := oBrwBDW:aCols[nLinha, nBDW_VERSUB]

		For nCols := 1 To Len(oBrwBDW:aCols)
			If ! Empty(	oBrwBDW:aCols[nLinha, nBDW_CODEMP] +;
					oBrwBDW:aCols[nLinha, nBDW_CONEMP] +;
					oBrwBDW:aCols[nLinha, nBDW_VERCON] +;
					oBrwBDW:aCols[nLinha, nBDW_SUBCON] +;
					oBrwBDW:aCols[nLinha, nBDW_VERSUB])
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf



Return lRet

/*/{Protheus.doc} PLS627CRI
Carrega as criticas do faturamento para uma matriz estatica
com objetivo de eliminar o arquivo PLSA627.CH do SOURCE SAFE
cria-lo no ATUSX, possibilitando a tratucao do conteudo.

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLS627CRI()
	LOCAL aCriticas := {{"01",STR0017},;//"Titulo gerado com sucesso."
		{"02",STR0018},;//"Valor de cobranca e igual a zero."
		{"03",STR0019},;//"Nao foi possivel encontrar a familia."
		{"04",STR0020},;//"Contrato gratuito neste ano/mes."
		{"05",STR0021},;//"Data de vencimento invalida."
		{"06",STR0022},;//"Nao foi possivel encontrar o subcontrato do grupo empresa."
		{"07",STR0023},;//"Familia bloqueada."
		{"08",STR0024},;//"Nao foi possivel encontrar o contrato do grupo empresa."
		{"09",STR0025},;//"Titulo ja existia no cadastro de titulos (SE1) neste ano/mes."
		{"10",STR0026},;//"O cliente do nivel de cobranca e invalido."
		{"11",STR0027},;//"A matricula do usuario e Invalida."
		{"12",STR0028},;//"O produto informado na familia nao existe no cadastro."
		{"13",STR0029},;//"Nao foi possivel encontrar o grupo empresa."
		{"14",STR0030},;//"Natureza nao informada no nivel de cobranca."
		{"15",STR0031},;//"Subcontrato bloqueado."
		{"16",STR0032},;//"Nao foi possivel encontrar o produto deste subcontrato."
		{"17",STR0033},;//"Nao foi possivel encontrar a forma de cobranca."
		{"18",STR0034},;//"O campo 'Rotina' da familia esta em branco."
		{"19",STR0035},;//"Nao foi possivel encontrar a ou rotina de calculo informada."
		{"20",STR0036},;//"Sub contrato bloqueado"
		{"21",STR0037},;//"O Codigo do funcionario na familia e invalido."
		{"22",STR0038},;//"Data de emissao informada e inferior a emissao do ultimo titulo."
		{"23",STR0220},;//"Existe(m) lançamento(s) que não possui(em) o vinculo com o Produto (SB1) parametrizado."
		{"24",STR0221},;//"Existe(m) lançamento(s) que não possui(em) o vinculo com a TES parametrizada."
		{"25",STR0222},;//"Pelo menos uma TES deve estar parametrizada para Gerar Duplicata (F4_DUPLIC)."
		{"26",STR0278},;//"O valor do Crédito é igual ou maior que o valor do Débito"
		{"27",STR0279},;//"Valor de cobranca e igual a zero para familia"
		{"28",STR0287},;//"Existe(m) lançamento(s) que não possui(em) o parametrizacao para integração com Gestão de Pessoal."
		{"29","Erro: "}}// "Erro no processamento da rotina automatica"

	//  PL627Cri - Ponto de entrada para adicionar mais criticas

	If ExistBlock("PL627Cri")
		aCriticas := aClone(ExecBlock("PL627Cri",.F.,.F.,{aCriticas}))
	EndIf



Return(aCriticas)

/*/{Protheus.doc} A627RetCri
Incrementa a matriz de critica de acordo com o codigo...
O conteudo da critica esta na matriz estatica aCriFat

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function A627RetCri(aCritica, cCodCri, nValor, lTipo, aMatBA1, cErro)
	LOCAL nPos		:= 0
	Local aRecBSQ	:= PLRETBSQ()
	Local nLenBSQ   := Len(PLRETBSQ())
	local nI		:= 0
	Local aAreaBSQ	:= BSQ->(GetArea())

	DEFAULT lTipo 	:= .F.
	DEFAULT aMatBA1 := {}
	default cErro 	:= ''

	If (nPos := Ascan(aCriFat, {|x| x[1] == cCodCri})) > 0
		AaDd(aCritica, { lTipo, aCriFat[nPos][1], aCriFat[nPos][2] + cErro, nValor, .f., 0, aMatBA1 } )
	EndIf

	If nLenBSQ > 0 .and. cCodCri <> "01" .and. cCodCri <> "26"

		For nI := 1 TO nLenBSQ
			BSQ->( DbGoto(aRecBSQ[nI]) )

			If Empty(BSQ->BSQ_NUMTIT)//Só limpo o BSQ se ainda não foi gerado titulo
				BSQ->(Reclock("BSQ", .F.) )
				BSQ->BSQ_NUMCOB := ""
				BSQ->(MsUnlock())

			EndIf

		Next
		PLRETBSQ(.T.)
	EndIf

	RestArea(aAreaBSQ)

Return(aCritica)


/*/{Protheus.doc} CalcFatGri
Os parametros passados vem do metodo execute do grid

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function CalcFatGri(aMatriz,lGrid,aUsuarios,aCliente, cModPag )
	LOCAL nI		:= 0
	LOCAL nTotLNF	:= 0
	LOCAL lRetMov	:= Iif(cModPag $ '2,3, ', .T., .F.)
	LOCAL aRetAux	:= {}
	LOCAL aMatAux	:= {}
	LOCAL cCodInt 	:= aMatriz[2]
	LOCAL cCodEmp 	:= aMatriz[3]
	LOCAL cMatric 	:= aMatriz[4]
	LOCAL cAno		:= aMatriz[5]
	LOCAL cMes		:= aMatriz[6]
	LOCAL cConEmp	:= aMatriz[7]
	LOCAL cVerCon	:= aMatriz[8]
	LOCAL cSubCon	:= aMatriz[9]
	LOCAL cVerSub	:= aMatriz[10]
	LOCAL cCodPro	:= aMatriz[11]
	LOCAL cVerPro	:= aMatriz[12]
	LOCAL cTipoUs	:= aMatriz[13]
	LOCAL nBa3Rec	:= aMatriz[14]
	LOCAL nBg9Rec	:= aMatriz[15]
	LOCAL nBt5Rec	:= aMatriz[16]
	LOCAL nBqCRec	:= aMatriz[17]
	LOCAL nBt6Rec	:= aMatriz[18]
	LOCAL cNumCob	:= aMatriz[19]
	LOCAL lInterC	:= aMatriz[20]
	LOCAL cTipReg	:= aMatriz[21]
	LOCAL cDirFile	:= aMatriz[22]
	DEFAULT aUsuarios := {}
	DEFAULT aCliente  :={}

	If Len(aUsuarios) == 0
		Return( aMatAux )
	EndIf

	// Obtem o valor de cobranca da familia...

	aRet := PLSVLRFAM(	cCodInt+cCodEmp+cMatric,;
		cAno,;
		cMes,;
		aEventosCb,;
		nil,;
		nil,;
		aUsuarios,;
		nil,;
		lRetMov,;
		LastDay(StoD(cAno+cMes+"01")),;
		nil,;
		aEveUsr,;
		cNumCob,;
		nil,;
		IIF(TYPE("M->BDC_REEMB")<>"U",M->BDC_REEMB,"2"),;
		IIF(TYPE("M->BDC_DTPREE")<>"U" .And. !Empty(M->BDC_DTPREE),M->BDC_DTPREE,nil),;
		aCliente)


	// So considera a primeira posicao da matriz
	aRetAux := aRet[1]

	// Se tem valor de cobranca
	If Len(aRetAux) > 0

		// Se nao teve critica

		If aRetAux[1]

			For nI := 1 To Len(aRetAux[2])

				AaDd(aMatAux, {	aRetAux[2][nI][01],;
					aRetAux[2][nI][02],;
					aRetAux[2][nI][03],;
					aRetAux[2][nI][04],;
					aRetAux[2][nI][05],;
					aRetAux[2][nI][06],;
					aRetAux[2][nI][07],;
					aRetAux[2][nI][08],;
					aRetAux[2][nI][09],;
					aRetAux[2][nI][10],;
					aRetAux[2][nI][11],;
					aRetAux[2][nI][12],;
					aRetAux[2][nI][13],;
					aRetAux[2][nI][14],;
					aRetAux[2][nI][15],;
					aRetAux[2][nI][16],;
					aRetAux[2][nI][17],;
					aRetAux[2][nI][18],;
					aRetAux[2][nI][19],;
					aRetAux[2][nI][20],;
					aRetAux[2][nI][21],;
					aRetAux[2][nI][22],;
					aRetAux[2][nI][23],;
					aRetAux[2][nI][24],;
					aRetAux[2][nI][25],;
					aRetAux[2][nI][26],;
					aRetAux[2][nI][27],;
					aRetAux[2][nI][28],;
					aRetAux[2][nI][29],;
					aRetAux[2][nI][30],;
					aRetAux[2][nI][31],;
					aRetAux[2][nI][32],;
					aRetAux[2][nI][33],;
					aRetAux[2][nI][34],;
					aRetAux[2][nI][35],;
					aRetAux[2][nI][36],;
					aRetAux[2][nI][37],;
					aRetAux[2][nI][38],;
					aRetAux[2][nI][39],;
					aRetAux[2][nI][40],;
					cCodInt,;//41
					cCodEmp,;//42
					cMatric,;//43
					cConEmp,;//44
					cVerCon,;//45
					cSubCon,;//46
					cVerSub,;//47
					cCodPro,;//48
					cVerPro,;//49
					'',;	 //50
					0,;	 	 //51
					cTipoUs,;//52
					nBa3Rec,;//53
					nBg9Rec,;//54
					nBt5Rec,;//55
					nBqCRec,;//56
					nBt6Rec,;//57
					cNumCob,;//58
					Iif(aRetAux[5],aRetAux[2][nI][41],cAno),;	 //59
					Iif(aRetAux[5],aRetAux[2][nI][42],cMes),;	 //60
					lInterC,;	//61
					cTipReg,;	//62
					aRet[4],;	//63
					{},;     	//64
					aRetAux[6],;//65
					"1" ,;//66  // 1 = Pre-Pagamento.
					aRetAux[2][nI][45],; //67 - Tipo do Plano no GPE
					aRetAux[2][nI][46],; //68 - Tipo de Fornecedor no GPE (1-Ass. Medica;2- Ass. Odontologica)
					aRetAux[2][nI][47],; // 69- Cod. fornecedor
					aRetAux[2][nI][48],; // 70- Cod. Dependente
					aRetAux[2][nI][49],;//71- Cod do Plano
					If(Len(aRetAux[2][nI])>49,aRetAux[2][nI][50],.F. )}) //Patronal diferenciado (Acordo ANS CApesesp)

			Next

		Else
			aMatAux := { { nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
				nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
				nil,nil,nil,nil,nil,nil,;
				cCodInt,;	//41
				cCodEmp,;	//42
				cMatric,;	//43
				cConEmp,;	//44
				cVerCon,;	//45
				cSubCon,;	//46
				cVerSub,;	//47
				cCodPro,;	//48
				cVerPro,;	//49
				aRetAux[2],;//50
				aRetAux[4],;//51
				cTipoUs,;	//52
				nBa3Rec,;	//53
				nBg9Rec,;	//54
				nBt5Rec,;	//55
				nBqCRec,;	//56
				nBt6Rec,;	//57
				cNumCob,;	//58
				cAno,;	 	//59
				cMes,;	 	//60
				lInterC,;	//61
				cTipReg,;	//62
				{},;	 	//63
				{},; 		//64
				aRetAux[6],;//65
				.F.,; //66
				nil,; //67 - Tipo do Plano no GPE
				nil,; //68 - Tipo de Fornecedor no GPE (1-Ass. Medica;2- Ass. Odontologica)
				nil,; // 69- Cod. fornecedor
				nil,; // 70- Cod. Dependente
				nil,;//71- Cod do Plano
				.F. } }//72- Patronal diferenciado (Acordo ANS CApesesp)

		EndIf
	EndIf



Return( aMatAux )

/*/{Protheus.doc} SetEventos
Inicia matriz statica

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function SetEventos()
	If ( aEventosCb == Nil )
		aEventosCb := PLSINPBFQ(PlsIntPad())
	EndIf

Return(aEventosCb)

/*/{Protheus.doc} SetEveAcu
Inicia matriz statica

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function SetEveAcu()

	If ( aAcertos == Nil )
		aAcertos := PLSINPBFQ(PlsIntPad(),{|| !Empty(BFQ_LANACE)})
	EndIf


Return(aAcertos)

/*/{Protheus.doc} SetEveUsr
Inicia matriz statica

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function SetEveUsr()
	If ( aEveUsr == Nil )
		aEveUsr := PLSRETLANU(PlsIntPad())
	EndIf

Return(aEveUsr)

/*/{Protheus.doc} SetFrzFai
inicializa a variavel estatica que
@author  PLS TEAM
@since   20173007
@version p11
/*/
function SetFrzFai()
	PLSInitHx(@oFrezFai,!IsSrvUnix())
return

/*/{Protheus.doc} RetFai627
inicializa a variavel estatica que
@author  PLS TEAM
@since   20173007
@version p11
/*/
function RetFai627()
return oFrezFai

/*/{Protheus.doc} KilFrzFai
finaliza a variavel estatica que
@author  PLS TEAM
@since   20173007
@version p11
/*/
function KilFrzFai()
	if valtype("oFrezFai") == "O"
		PLSFreHash(@oFrezFai)
		oFrezFai := nil
		DelClassIntF()
	endif
return

/*/{Protheus.doc} PLSFreHash
Finaliza o objeto/array com as informações de retorno das rotinas
@author PLS TEAM
@since 09/11/2016
@param xObj, undefined, objeto a ser finalizado
@return null
/*/
function PLSFreHash(xObj)
	local lRet		:= .F.
	local lHashMap 	:= !IsSrvUnix()

	//Retorna o objeto de dados conforme configuracao do servidor
	if lHashMap
		lRet := xObj:Clean()
	else
		lRet := .T.
		PlsFreArr(@xObj)
	endif

return lRet

/*/{Protheus.doc} A627CobAbr

@author  PLS TEAM
@since   20173007
@version p11
/*/
Function A627CobAbr(aCobAbr,aCliente,cCodInt,cCodEmp,cMatric,cTipo,cConEmp,cVerCon,cSubCon,cVerSub,cTipReg,aRecnos,cAno,cMes)
	LOCAL nPos 			:= 0
	LOCAL dVenc   		:= cTod("")
	LOCAL dVencCO 		:= cTod("")
	LOCAL aVenc			:= {}
	LOCAL cMesAux 		:= ""
	LOCAL cAnoAux 		:= ""
	LOCAL nVencto		:= 0
	LOCAL nCobComple 	:= 0
	LOCAL nRecBA3		:= aRecnos[1]
	LOCAL aChaves		:= {}

	// Obtem o nivel de cobranca e o cliente...

	aCliente := PLS627NIV(cCodInt,cCodEmp,cMatric,If(cTipo=="1","F","J"),cConEmp,cVerCon,cSubCon,cVerSub ,1,nil,nil,aRecnos)

	// Matriz com os niveis de cobranca possiveis...

	aChaves := 	{cCodInt + cCodEmp,;
		cCodInt + cCodEmp + cConEmp + cVerCon,;
		cCodInt + cCodEmp + cConEmp + cVerCon + cSubCon + cVerSub,;
		cCodInt + cCodEmp + cMatric,;
		cCodInt + cCodEmp + cMatric + cTipReg,;
		cCodInt + cCodEmp + cMatric + cTipReg,nRecBA3}

	// Verifica se ja existe o cliente no array, para criar ou atualizar os valores...
	//| Obs. A pesquisa na matriz de nivel de cobranca nao eh necessario ser feito para pessoa fisica.

	If cTipo <> '1'
		nPos := Ascan(aCobAbr, {|x|	x[01] == aCliente[1,01] .And.;
			x[02] == aCliente[1,02] .And.;
			x[09] == aCliente[1,18] .And.;
			Val(aCliente[1,18]) > 0 .AND. ;
			x[07][Val(aCliente[1,18])] == aChaves[Val(aCliente[1,18])] })
	EndIf

	// Cria o array com os dados da fatura por cliente...

	If nPos == 0
		aDataVenc := PLS627VENC(aCliente,cAno,cMes)

		// Datas de vencimento.
		dVenc 	:= aDataVenc[1]
		dVencCO := aDataVenc[2]


		// Inclui registro na matriz acobabr

		AaDd(aCobAbr, {	aCliente[1,1],;		//01 - Cliente
			aCliente[1,2],;		//02 - Loja
			aCliente[1,14],;	//03
			aCliente[1],;		//04
			dVenc,;				//05 - Vencimento padrao
			{},;				//06 -
			aChaves,;			//07 - Chave dos niveis de cobranca
			0,;					//08 -
			aCliente[1,18],;	//09 - Nivel de cobranca
			aCliente[1,19],;	//10 - Gratuidade
			nCobComple,;		//11
			aCliente[1,7],;		//12 - Natureza
			aCliente[1,21],;	//13 - Tipo de cobranca
			aCliente[1,22],;	//14 - Banco operadora
			aCliente[1,23],;	//15 - Agencia operadora
			aCliente[1,24],;	//16 - Conta operadora
			aCliente[1,25],;	//17 - Banco cliente
			aCliente[1,26],;	//18 - Agencia cliente
			aCliente[1,27],;	//19 - Conta cliente.
			dVencCO,;			//20 - Vencimento CO
			{},;				//21
			aRecnos,;			//22 - Registros
			aCliente[1,28],;	//23 - Tipo vencimento PP
			aCliente[1,30],;	//24 - Tipo vencimento CO
			"",;            	//25 - posicao livre de uso geral
			Iif( Len(aCliente[1]) >= 33, aCliente[1,33],"" ) }) //26 - Indica o tipo de cobranca da tabela patronal.


		//Ultima posicao da matriz

		nPos := Len(aCobAbr)
	EndIf



Return(nPos)

/*/{Protheus.doc} PLS627VENC

@author  PLS TEAM
@since   20173007
@version p11
/*/
Function PLS627VENC(aCliente,cAno,cMes)
	LOCAL dVenc   		:= cTod("")
	LOCAL dVencCO 		:= cTod("")
	LOCAL aVenc			:= {}
	LOCAL cMesAux 		:= ""
	LOCAL cAnoAux 		:= ""
	LOCAL nVencto		:= 0


	// Obtem a data de vencimento... Prioriza a condicao de pagamento

	If !Empty(aCliente[1,20])
		aVenc := Condicao(10, aCliente[1,20],,dDatabase)
		If Len(aVenc) > 0
			dVenc := aVenc[1][1]
		EndIf
	Else

		// ponto de entrata para tratar regras especificas para o dia do vencimento da fatura...

		If ExistBlock("PL627VCT")
			aVenc := ExecBlock("PL627VCT", .F., .F., {	M->BDC_VENCTO,;
				aCliente[1,16],;
				cMes,;
				cAno,;
				aCliente[1,28],;
				aCliente[1,29],;
				aCliente[1,30],;
				'2'} )

			dVenc   := aVenc[1]
			dVencCO := aVenc[2]

			// LOG

			PLSLOGFAT("PL627VCT",1,.F.)
		Else

			// Cacula data de vencimento para o pre pagamento...

			If Len(aCliente[1]) > 27 .And. aCliente[1,28] == '2' // Fora o mes...
				/*/
				cMesAux := StrZero( (Val(cMes)+1),2 )

				If cMesAux > '12'
					cMesAux := '01'
					cAnoAux := StrZero((Val(cAno)+1), 4)
				EndIf
				/*/
				dVenc:=Iif( BDC->( FieldPos('BDC_DTEMIS') ) > 0 .and. GetNewPar("MV_PLSNFBR","0")=="0", M->BDC_DTEMIS, dDataBase )+aCliente[1,16]
			Else
				cMesAux:= cMes
				cAnoAux:= cAno
				dVenc := PLMontVen( Iif(M->BDC_VENCTO > 0, M->BDC_VENCTO, If(nVencto > 0, nVencto, aCliente[1,16] ) ),cMesAux,cAnoAux)
			EndIf



			// Cacula data de vencimento para o custo operacional...

			If Len(aCliente[1]) > 27 .And. aCliente[1,30] == '2' // Fora o mes...
				/*/
			cMesAux := StrZero((Val(cMes)+1), 2)

			If cMesAux > '12'
				cMesAux := '01'
				cAnoAux := StrZero((Val(cAno)+1), 4)
			EndIf
				/*/
				dVencCO:=Iif( BDC->( FieldPos('BDC_DTEMIS') ) > 0 .and. GetNewPar("MV_PLSNFBR","0")=="0", M->BDC_DTEMIS, dDataBase )+aCliente[1,29]

				// Vencimento fixo...

			Else
				cMesAux := cMes
				cAnoAux := cAno


				dVencCO := PLMontVen(Iif(M->BDC_VENCTO > 0, M->BDC_VENCTO, If(nVencto > 0, nVencto, aCliente[1,29])),cMesAux,cAnoAux)

			EndIf

			// Se nao for informada data do CO, ela assumira a mesma data do PP...|

			If Empty(dVencCO)
				dVencCO := dVenc
			EndIf
		EndIf
	Endif

Return({dVenc,dVencCO})


/*/{Protheus.doc} A627CTERR

@author  PLS TEAM
@since   20173007
@version p11
/*/
Function A627CTERR()
	LOCAL xResult
	LOCAL cForm			:=&(ReadVar())
	LOCAL lRet			:=.T.
	LOCAL aRetSyntax 	:= {}

	//An lise estrutural de sintaxe

	aRetSyntax := ParAnalise(cForm)

	IF !empty(aRetSyntax[1])
		Help(" ",1,"ERR_FORM",,OemToAnsi( STR0236 + aRetSyntax[1]),3,0) // Estrutura Inconsistente :
		lRet := .F.
	EndIf

	If lRet
		bBlock := ErrorBlock( { |e| ChecErro(e) } )
		BEGIN SEQUENCE
			xResult := &cForm
			RECOVER
			lRet := .F.
		END SEQUENCE
		ErrorBlock(bBlock)
	EndIf



Return lRet

/*/{Protheus.doc} ChecErro
Emite mensagem caso encontre erro na expressao ADVPL do
campo BDC_EXPFIF

@author  PLS TEAM
@since   20173007
@version p11
/*/
STATIC FUNCTION ChecErro(e)
	Help(" ",1,"ERR_FORM",,e:Description,3,1)
	BREAK

	/*/{Protheus.doc} ParAnalise
Analisa validade da expressao ADVPL digitada no camp BDC_EXPFIF

@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Static Function ParAnalise(cTexto)
		LOCAL uAbre
		LOCAL uFecha
		LOCAL cStack	:= ""
		LOCAL cAspas	:= ""
		LOCAL nPosAt	:= 1
		LOCAL uLastPar	:= 1
		LOCAL cPosAtual	:= ""
		LOCAL cSeparador:= ","
		LOCAL aSepFunc	:= {"()","[]","{}"}
		LOCAL aParam	:= {}

		//Arranca os caracteres da esquerda se forem 'espa?o' ou 'TAB'

		While left(cTexto,1)==" " .or. left(cTexto,1)==chr(9)
			cTexto:=right(cTexto,len(cTexto)-1)
		EndDo

		While nPosAt<=len(cTexto)
			cPosAtual:=substr(cTexto,nPosAt,1)

			//Achou "ASPAS"

			If cPosAtual==chr(34) .or. cPosAtual==chr(39)
				cAspas:=If(empty(cAspas),cPosAtual,If(cAspas == cPosAtual,"",cAspas))
			EndIf

			//Apenas analiza a estrutura caso nao esteja entre aspas

			If empty(cAspas)
				uAbre :=ascan(aSepFunc,{|_v|  left(_v,1) == cPosAtual})
				uFecha:=ascan(aSepFunc,{|_v| right(_v,1) == cPosAtual})

				//Abriu ou Fechou uma estrutura

				If uAbre+uFecha>0

					//Abriu uma estrutura ! Acrescenta no STACK

					If uAbre>0
						If !empty(substr(cTexto,uLastPar,nPosAt-uLastPar))
							aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
						EndIf
						uLastPar:=nPosAt+1	 ; cStack:=cStack+cPosAtual

						//Fechou uma estrutura : Checa o STACK

					Else

						//Se fechou certo, tira do Stack

						If right(cStack,1)==Left(aSepFunc[uFecha],1)
							cStack:=left(cStack,len(cStack)-1)

							//Estrutura fechada incorretamente

						Else
							cStack:=right(aSepFunc[uFecha],1)
							EXIT
						EndIf
						If !empty(substr(cTexto,uLastPar,nPosAt-uLastPar))
							aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
						EndIf
						uLastPar:=nPosAt+1
					EndIf

					//Verifica separador

				Else
					If cPosAtual==cSeparador
						aadd(aParam,SubStr(cTexto,uLastPar,nPosAt-uLastPar))
						uLastPar:=nPosAt+1
					EndIf
				EndIf
			EndIf
			nPosAt++
		EndDo

		IF !empty(cTexto) .and. len(aParam) == 0
			aadd(aParam,AllTrim(cTexto))
		EndIf
		cStack+=if(empty(cAspas),"",cAspas)



	Return {cStack,aParam}

	/*/{Protheus.doc} PLSACOBRG
Monta a matriz a aCobAbr

@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function PLSACOBRG( aMatAux ,aCobAbr, aCliente )
		LOCAL nPos		:= 0
		LOCAL nCnt		:= 0
		LOCAL cCodInt 	:= ""
		LOCAL cCodEmp 	:= ""
		LOCAL cMatric 	:= ""
		LOCAL cConEmp 	:= ""
		LOCAL cVerCon 	:= ""
		LOCAL cSubCon 	:= ""
		LOCAL cVerSub 	:= ""
		LOCAL cCodCri	:= ""
		LOCAL nValor	:= 0
		LOCAL cTipoUs  	:= ""
		LOCAL cNumCob	:= ""
		LOCAL cAno		:= ""
		LOCAL cMes		:= ""
		LOCAL lInterC	:= .F.
		LOCAL cTipReg	:= ""
		LOCAL aRetAcu	:= {}
		LOCAL aRecnos   := {}
		LOCAL aCritica 	:= {}

		// Se nao tem valor de cobranca sai da funcao

		If Len(aMatAux) == 0
			Return
		EndIf

		// Parametros comuns na matriz referente a parametro de entrada aVet1

		cCodInt := aMatAux[1,41]
		cCodEmp := aMatAux[1,42]
		cMatric := aMatAux[1,43]
		cConEmp := aMatAux[1,44]
		cVerCon := aMatAux[1,45]
		cSubCon := aMatAux[1,46]
		cVerSub := aMatAux[1,47]

		cCodCri	:= aMatAux[1,50]
		cTipoUs := aMatAux[1,52]

		cNumCob	:= aMatAux[1,58]
		cAno	:= aMatAux[1,59]
		cMes	:= aMatAux[1,60]
		lInterC	:= aMatAux[1,61]
		cTipReg	:= aMatAux[1,62]
		aRetAcu	:= aMatAux[1,63]

		aMatAux[1,63] := {}

		aRecnos := { aMatAux[1,53], aMatAux[1,54], aMatAux[1,55], aMatAux[1,56], aMatAux[1,57] }

		// Cria um novo aCobAbr ou obtem a posicao da matriz a qual a familia pertence...
		// Monta aCobAbr																  |

		nPos := A627CobAbr(@aCobAbr,@aCliente,cCodInt,cCodEmp,cMatric,cTipoUs,cConEmp,;
			cVerCon,cSubCon,cVerSub,cTipReg,aRecnos,cAno,cMes)

		If ValType(aCliente) == "A" .And. Len(aCliente) >= 1 .And. aCliente[1,1] == "ZZZZZZ"
			cCodCri := "10"
			aCliente[1,18] := "4"
		EndIf

		//PL627AGL  - Ponto de Entrada para Incluir mais campos na Aglutinacao.

		If Empty(cCodCri) .And. lPl627Agl
			aRetAGL := ExecBlock("PL627AGL",.F.,.F.,{aMatAux} )
			cCodCri := aRetAGL[1]
			aMatAux := aClone(aRetAGL[2])
			nValor  := 0
			aRetAGL := {}
		EndIf

		// Verifica se houve critica

		If !Empty(cCodCri)

			A627RetCri(@aCritica, cCodCri, nValor)

			PLSA625Cri(	cNumCob,;
				0,;
				aCritica,;
				cCodInt,;
				cCodEmp,;
				cConEmp,;
				cVerCon,;
				cSubCon,;
				cVerSub,;
				cMatric,;
				" ",;
				aCliente[1,18],;
				cAno,;
				cMes,;
				lInterC,,,,;
				'2')		//Tipo dois, inconsistencia.
		Else

			// Ponto de entrada para tratar o retorno da matriz de valor de cobranca...

			If lPl627Vcb
				aMatAux := ExecBlock("PL627VCB",.F.,.F.,{Iif(cTipoUs == '1',"F","J"),aMatAux})

				// LOG

				PLSLOGFAT("PL627VCB",1,.F.)
			EndIf

			// Atualiza a composicao da cobranca na matriz de titulos a serem gerados...

			If Len(aCobAbr[nPos,6]) == 0
				aCobAbr[nPos,6]  := aClone(aMatAux)
				aCobAbr[nPos,21] := aClone(aRetAcu)
			Else

				// Adiciona mais valor na posicao encontrada

				For nCnt := 1 To Len(aMatAux)
					AaDd( aCobAbr[nPos,6], aClone(aMatAux[nCnt]) )
				Next

				// Adiciona mais valor na posicao encontrada acumulados

				For nCnt := 1 To Len(aRetAcu)
					AaDd( aCobAbr[nPos,21], aClone(aRetAcu[nCnt]) )
				Next
			EndIf
		EndIf



	Return

	/*/{Protheus.doc} PLCABRES
Ajusta cabecalho da cobranca

@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Static Function PLCABRES(cCodInt,cNumCob,lInterC,lShow)
		LOCAL nI		:= 0
		LOCAL nTQtdGer  := 0
		LOCAL nTQtdCri  := 0
		LOCAL nTValor	:= 0
		LOCAL nTVlrNCC	:= 0
		LOCAL nRecBDD	:= 0
		LOCAL aMatCon	:= {}
		LOCAL _cNivel	:= ""
		LOCAL cInterC   := Iif(lInterC,"1","0")
		LOCAL lFind		:= .F.

		DEFAULT lShow   := .F.

		// Informacao
		If lShow
			IncProcG2(STR0240,.F.) //"Montando Resumo Cobrança"
			ProcessMessage()
		EndIf

		// Monta totais BDF - Detalhes Cobrança Níveis
		BDD->( DbSetOrder(1) )//BDD_FILIAL + BDD_INTERC + BDD_CODOPE + BDD_NUMERO + BDD_NIVEL
		BDF->( DbSetOrder(1) )//BDF_FILIAL + BDF_INTERC + BDF_CODOPE + BDF_NUMERO
		If BDF->( DbSeek(xFilial("BDF")+cInterC+cCodInt+cNumCob) )

			While !BDF->( Eof() ) .And. cInterC+cCodInt+cNumCob == BDF->(BDF_INTERC + BDF_CODOPE + BDF_NUMERO)

				// Inclui o bdd se o nivel for diferente de 7 e nao existir
				_cNivel	:= BDF->BDF_NIVEL
				lFind   := BDD->( MsSeek(xFilial("BDD")+cInterC+cCodInt+cNumCob+_cNivel) )

				If _cNivel <> "7" .And. ! lFind
					BDD->( RecLock("BDD",.T.) )
					BDD->BDD_FILIAL := xFilial("BDD")
					BDD->BDD_INTERC := cInterC
					BDD->BDD_NUMERO := cNumCob
					BDD->BDD_CODOPE := cCodInt
					BDD->BDD_NIVEL  := _cNivel
					BDD->( MsUnLock() )
				EndIf

				nRecBDD := BDD->( Recno() )

				// Matriz de Dados
				If Ascan(aMatCon, {|x| x[1] == nRecBDD} ) == 0
					AaDd(aMatCon, { nRecBDD, _cNivel , 0, 0, 0, 0 } )
				EndIf

				// Verifica se houve critica.
				nPos := Ascan(aMatCon, {|x| x[2] == _cNivel} )

				If BDF->BDF_TIPO == "1"

					nTQtdCri++

					If nPos > 0
						aMatCon[nPos,5]++
					EndIf

				Else
					nTQtdGer++

					If nPos > 0
						aMatCon[nPos,3]++
					Endif

					// Verifica se e reembolso, para tirar negativo do valor  (para resumo cob)| RDS
					If BDC->(FieldPos("BDC_REEMB"))> 0 .And. (TYPE("M->BDC_REEMB") <> "U" .and. M->BDC_REEMB $ "1") .and. nPos>0
						aMatCon[nPos,4] := -(aMatCon[nPos,4])
					Endif

					nTValor  +=  Iif(BDF->BDF_TIPTIT <> 'NCC', BDF->BDF_VALOR, 0)
					nTVlrNCC +=  Iif(BDF->BDF_TIPTIT == 'NCC', BDF->BDF_VALOR, 0)

					If nPos > 0
						aMatCon[nPos, 4] += Iif(BDF->BDF_TIPTIT <> 'NCC', BDF->BDF_VALOR, 0)
						aMatCon[nPos, 6] += Iif(BDF->BDF_TIPTIT == 'NCC', BDF->BDF_VALOR, 0)
					Endif

				EndIf

				BDF->( DbSkip() )
			EndDo

			// Atualiza BDD - Resumo da Cobrança
			for nI := 1 To Len(aMatCon)

				nRecBDD := aMatCon[nI,1]

				BDD->( dbGoto(nRecBDD) )

				// Atualiza
				BDD->( recLock("BDD", .f.) )
				BDD->BDD_GERADO := aMatCon[nI,3]
				BDD->BDD_CRITIC := aMatCon[nI,5]
				BDD->BDD_VALOR  := iIf( aMatCon[nI,4] > 0, aMatCon[nI,4], aMatCon[nI,6] )
				BDD->( MsUnLock() )

			next

			// Atualiza BDC - Cabeçalho de Cobrança
			BDC->( DbSetOrder(1) ) //BDC_FILIAL + BDC_CODOPE + BDC_NUMERO
			if BDC->( MsSeek(xFilial("BDC") + cCodInt + cNumCob) )

				BDC->( recLock("BDC", .f.) )
				BDC->BDC_CONGER := nTQtdGer
				BDC->BDC_CONCRI := nTQtdCri
				BDC->BDC_VALOR  := iIf( nTValor > 0, nTValor, nTVlrNCC )
				BDC->( MsUnLock() )

			endIf

		endIf

	Return()

	/*/{Protheus.doc} A627VisLoteTit
Ajusta cabecalho da cobranca

@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Static Function A627VisLoteTit(cCodOpe,cNumLote,cInterc,cNivel,aFixCpo)
		LOCAL   cSQL    := ""
		PRIVATE aRotina := {} //MenuEsp()
		PRIVATE aCores  :={	{ "(cCodCor := Plsa627Blq()) == '2'", 'BR_VERMELHO' },;
			{ "cCodCor == '1'", 'BR_VERDE'} }

		PRIVATE aCdCores:= { { 'BR_VERDE'    ,OemtoAnsi(STR0250) },;
			{ 'BR_VERMELHO' ,OemtoAnsi(STR0251) } }

		nMenu:= 2
		aRotina := MenuDef()
		//Aadd(aRotina, { STR0252	 , "PLSA627LEG"	, 0 , K_Incluir })

		cSQL := "@BDF_FILIAL = '"+xFilial("BDF")+"' AND BDF_INTERC = '"+cInterc+"' AND BDF_CODOPE = '"+cCodOpe+"' AND BDF_NUMERO = '"+cNumLote+"' AND BDF_NIVEL = '"+cNivel+"' AND D_E_L_E_T_ = ' '"

		DbSelectArea("BDF")
		DbSetOrder(6)
		SET FILTER TO &cSQL
		MsSeek(xFilial("BDF"))
		BDF->( mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"BDF",aFixCpo,nil,nil,nil,nil,aCores,nil,nil,nil,nil,.T.,nil) )
		DbSelectArea("BDF")
		DbSetOrder(1)
		DbClearFilter()



	Return

	/*/{Protheus.doc} PLSA627Leg
Ajusta cabecalho da cobranca

@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function PLSA627Leg()

		BrwLegenda(cCadastro,STR0253 ,aCdCores)

	Return

	/*/{Protheus.doc} Plsa627Blq
Ajusta cabecalho da cobranca

@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function Plsa627Blq()
		LOCAL cRet := ""

		BDG->(DbSetOrder(1))
		If BDG->(MsSeek(xFilial("BDG")+BDF->(BDF_INTERC+BDF_CODOPE+BDF_NUMERO+BDF_NIVEL+BDF_CODSEQ)))
			cRet := "2"
		Else
			cRet := "1"
		EndIf

	Return cRet

	/*/{Protheus.doc} A627MCri
Ajusta cabecalho da cobranca

@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function A627MCri()
		LOCAL nTot 		:= 0
		LOCAL nLastRec  := 0
		LOCAL cSQL 		:= ""
		PRIVATE aRotina := {}//MenuEsp2()

		nMenu:= 3
		aRotina:=MenuDef()
		BDG->(DbSetOrder(1))
		If BDG->(DbSeek(xFilial("BDG")+BDF->(BDF_INTERC+BDF_CODOPE+BDF_NUMERO+BDF_NIVEL+BDF_CODSEQ)))
			While BDG->(!Eof()) .and. xFilial("BDG")+BDF->(BDF_INTERC+BDF_CODOPE+BDF_NUMERO+BDF_NIVEL+BDF_CODSEQ) == BDG->(BDG_FILIAL + BDG_INTERC + BDG_CODOPE + BDG_NUMERO + BDG_NIVEL  + BDG_CODSEQ)
				nTot++
				nLastRec := BDG->(Recno())
				BDG->(DbSkip())
			Enddo
			If nTot == 1
				BDG->(DbGoTo(nLastRec))
				BDG->(AxVisual("BDG",nLastRec,K_Visualizar))
			Else

				cSQL := "@BDG_FILIAL = '"+xFilial("BDG")+"' AND BDG_INTERC = '"+BDF->BDF_INTERC+"' AND BDG_CODOPE = '"+BDF->BDF_CODOPE+"' AND "
				cSQL += " BDG_NUMERO = '"+BDF->BDF_NUMERO+"' AND BDG_NIVEL = '"+BDF->BDF_NIVEL+"' AND BDG_CODSEQ = '"+BDF->BDF_CODSEQ+"' AND D_E_L_E_T_ = ' '"

				DbSelectArea("BDG")
				DbSetOrder(1)
				SET FILTER TO &cSQL
				MsSeek(xFilial("BDG"))
				BDG->( mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"BDG",aCabCri2,nil,nil,nil,nil,NIL,nil,nil,nil,nil,.T.,nil) )
				DbSelectArea("BDG")
				DbSetOrder(1)
				DbClearFilter()
			Endif
		Else
			MsgStop(STR0255)
		EndIf
	Return

	/*/{Protheus.doc} A627VisFatTit
Ajusta cabecalho da cobranca

@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Static Function A627VisFatTit(cCodOpe,cNumLote,cInterC,aCab)
		LOCAL   cSQL    := ""
		PRIVATE aRotina := {}//MenuEsp2()

		PRIVATE aCores   :={ 	{ "(cCoSBBT := Plsa627BBT()) == '1'", 'BR_VERDE' },;
			{ "cCoSBBT == '2'", 'BR_VERMELHO'},;
			{ "cCoSBBT == '3'", 'BR_AZUL'} }

		PRIVATE aCdCores  	:= { 	{ 'BR_VERDE'    ,OemtoAnsi(STR0256) },;
			{ 'BR_VERMELHO' ,OemtoAnsi(STR0257) },;
			{ 'BR_AZUL' ,OemtoAnsi(STR0258) } }
		nMenu:=4

		aRotina:=MenuDef()

		cSQL := "@BBT_FILIAL = '"+xFilial("BBT")+"' AND BBT_NUMCOB = '"+cCodOpe+cNumLote+"' AND D_E_L_E_T_ = ' '"

		DbSelectArea("BBT")
		DbSetOrder(1)
		SET FILTER TO &cSQL
		MsSeek(xFilial("BBT"))
		BBT->( mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"BBT",aCab,nil,nil,nil,nil,aCores,nil,nil,nil,nil,.F.,nil) )
		DbSelectArea("BBT")
		DbSetOrder(1)
		DbClearFilter()

	Return

	/*/{Protheus.doc} PLSA627DTT
Ajusta cabecalho da cobranca

@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function PLSA627DTT()
		SE1->(DbSetOrder(1))
		If SE1->(MsSeek(xFilial("SE1")+BBT->BBT_PREFIX+BBT->BBT_NUMTIT+BBT->BBT_PARCEL+BBT->BBT_TIPTIT))
			SE1->(AxVisual("SE1",SE1->(Recno()),K_Visualizar))
		EndIf
	Return


	/*/{Protheus.doc} Plsa627BBT
Ajusta cabecalho da cobranca

@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function Plsa627BBT()
		LOCAL cRet := ""
		SE1->(DbSetORder(1))
		If SE1->(MsSeek(xFilial("SE1")+BBT->BBT_PREFIX+BBT->BBT_NUMTIT+BBT->BBT_PARCEL+BBT->BBT_TIPTIT))
			If SE1->E1_VALOR = SE1->E1_SALDO
				cRet := "1"
			ElseIf SE1->E1_SALDO = 0
				cRet := "2"
			Else
				cRet := "3"
			EndIf
		EndIf
	Return cRet

	/*/{Protheus.doc} a627VLot

@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function a627VLot(nFolder,nOpc)

		If nFolder == 2 .and. lDadNiv[1] == 0
			cCadastro := STR0260
			A627VisLoteTit(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,'1',aCabNiv1)
		ElseIf nFolder == 3 .and.  lDadNiv[2] == 0
			cCadastro := STR0263
			A627VisLoteTit(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,'2',aCabNiv2)
		ElseIf nFolder == 4 .and.  lDadNiv[3] == 0
			cCadastro := STR0264
			A627VisLoteTit(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,'3',aCabNiv3)
		ElseIf nFolder == 5 .and. lDadNiv[4] == 0
			cCadastro := STR0265
			A627VisLoteTit(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,'4',aCabNiv4)
		ElseIf nFolder == 6 .and. lDadNiv[5] == 0
			cCadastro := STR0266
			A627VisLoteTit(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,'5',aCabNiv5)
		ElseIf nFolder == 7 .and. lDadNiv[6] == 0
			cCadastro := STR0267
			A627VisLoteTit(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,'6',aCabNiv6)
		ElseIf nFolder == 8 .and. lDadNiv[8] == 0
			cCadastro := STR0261
			A627VisFatTit(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,aCabBBT)
		ElseIf nFolder == 9 .and. lDadNiv[9] == 0
			cCadastro := STR0262
			A627ViTc(BDC->BDC_CODOPE,BDC->BDC_NUMERO,BDC->BDC_INTERC,aCabBTV)
		EndIf


	Return

	/*/{Protheus.doc} A627ViTc
Ajusta cabecalho da cobranca

@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function A627ViTc(cCodOpe,cNumero,cInterC,aCabCab)
		LOCAL   cSQL    := ""
		PRIVATE aRotina := {} // MenuEsp2()

		nMenu := 5
		aRotina :=MenuDef()

		cSQL := "@BTV_FILIAL = '"+xFilial("BTV")+"' AND BTV_PLNUCO = '"+cCodOpe+cNumero+"' AND BTV_INTERC = '"+cInterC+"' AND D_E_L_E_T_ = ' '"

		DbSelectArea("BTV")
		DbSetOrder(2)
		SET FILTER TO &cSQL
		MsSeek(xFilial("BTV"))
		BTV->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"BTV",aCabCab,nil,nil,nil,nil,nil,nil,nil,nil,nil,.T.,nil))
		DbSelectArea("BTV")
		DbSetOrder(1)
		DbClearFilter()

	Return

	/*/{Protheus.doc} P627TrtFol
Ajusta cabecalho da cobranca

@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function P627TrtFol(cAlias,cInterC,cChave,aStr,aCab,aDad,aDadl,lLimMaxTit,nNivel)
		LOCAL nCntFor   := 1
		LOCAL nX 		:= 1
		LOCAL cAliasQry := ""
		LOCAL cQuery    := ""

		cAliasQry := "QRY"+cAlias
		cQuery 	  := "SELECT "+cAlias+".* "
		cQuery 	  += " FROM "
		cQuery    += RetSqlName(cAlias)+ " " + cAlias
		cQuery    += " WHERE "
		cQuery    += cAlias+"_FILIAL = '"+xFilial(cAlias)+"' AND "
		cQuery    += cAlias+"_INTERC = '"+cInterC+"' AND "
		cQuery    += cAlias+"_CODOPE = '"+subs(cChave,1,4)+"' AND "
		cQuery    += cAlias+"_NUMERO = '"+subs(cChave,5,12)+"' AND "
		If nNivel <> nil
			cQuery    += cAlias+"_NIVEL  = '"+AllTrim(str(nNivel))+"' AND "
		EndIf
		cQuery    += cAlias+".D_E_L_E_T_ = ' ' "
		cQuery    := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

		If !lLimMaxTit

			For nCntFor := 1 To Len(aStr)
				If ( aStr[nCntFor,2]<>"C" )
					TcSetField(cAliasQry,aStr[nCntFor,1],aStr[nCntFor,2],aStr[nCntFor,3],aStr[nCntFor,4])
				EndIf
			Next

			While (cAliasQry)->(!Eof())

				Aadd(aDad,Array(Len(aCab)+1))

				(cAlias)->(MsGoto((cAliasQry)->R_E_C_N_O_))

				For nX := 1 To Len(aCab)
					If ( aCab[nX,10] !=  "V" )
						aDad[Len(aDad)][nX] := (cAliasQry)->(FieldGet(FieldPos(aCab[nX,2])))
					Else
						aDad[Len(aDad)][nX] := CriaVar(aCab[nX,2],.T.)
					EndIf
				Next
				aDad[Len(aDad)][Len(aCab)+1] := .F.

				(cAliasQry)->(dbSkip())
			EndDo

			If Empty(aDad)
				Store COLS Blank cAlias TO aDad FROM aCab
				If aDadl <> nil
					aDadl[nNivel]:= 1
				EndIf
			EndIf
		Else
			If (cAliasQry)->(Eof())
				If aDadl <> nil
					aDadl[nNivel]:= 1
				EndIf
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())

	Return

	/*/{Protheus.doc} PLSGRILOG


@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function PLSGRILOG(cMsg,cTit)
		DEFAULT cTit := ''

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "DATA: " + DToC(Date()) + " HORA: " + Time(), 0, 0, {})
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cMsg, 0, 0, {})

		If !Empty(cTit)
			MsgStop(cMsg,cTit)
		EndIf

	Return

	/*/{Protheus.doc} PLCOGRID
Se foi com grid ou nao
@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function PLCOGRID()
	Return( Iif( Type("lGrid") == 'L' , Iif( lGrid , '1' , '0' ) ,'0' ) )

	/*/{Protheus.doc} PLGRPCOO
Seleciona grupo de cobranca
@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function PLGRPCOO(cDado,cCampo,lCspadrao)

		LOCAL nInd        := 0
		LOCAL nOpca       := 0
		LOCAL bOK         := { || nOpca := K_OK, oDlg:End() }
		LOCAL bCancel     := { || oDlg:End() }
		LOCAL aDados      := {}
		LOCAL aPosObj     := {}
		LOCAL aObjects    := {}
		LOCAL aSize       := {}
		LOCAL aInfo       := {}
		LOCAL oDlg        := NIL
		LOCAL oDados	    := NIL
		DEFAULT cCampo    := ""
		DEFAULT lCspadrao := .F.


		// Coloca virgula no inicio da string (caso tenha inicializador padrao)

		cDado := AllTrim( cDado )
		If  SubStr(cDado, Len(cDado), 1) != "," .And. cDado != ""
			cDado += ","
		EndIf

		BR0->( DbSetOrder(1) )
		BR0->( DbGoTop() )
		While ! BR0->( Eof() )
			aAdd(aDados, { BR0->BR0_CODIGO,BR0->BR0_DESCRI, IIf(BR0->BR0_CODIGO $ cDado, .T., .F.) })
			BR0->(DbSkip())
		EndDo

		aSize 	 := MsAdvSize()
		aSize[7] := Round(aSize[7] * 0.75, 0)
		aSize[6] := Round(aSize[6] * 0.75, 0)
		aSize[5] := Round(aSize[5] * 0.75, 0)
		aSize[4] := Round(aSize[4] * 0.75, 0)
		aSize[3] := Round(aSize[3] * 0.75, 0)
		aObjects := {}
		AAdd( aObjects, { 1, 10, .T., .F., .T. } )
		AAdd( aObjects, { 1, 1, .T., .T., .T. } )

		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )

		DEFINE MSDIALOG oDlg TITLE STR0275 FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel //"Grupo de Cobrança"

		@ aPosObj[1][1],aPosObj[1][2]+5 SAY oSay PROMPT STR0276 SIZE aPosObj[1][3],aPosObj[1][4] OF oDlg PIXEL COLOR CLR_HBLUE//"Selecione o(s) Grupos de Combrança(s)"

		oDados := TcBrowse():New( aPosObj[2][1], aPosObj[2][2], aPosObj[2][3], aPosObj[2][4],,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

		oDados:AddColumn(TcColumn():New(" ",{ || IF(aDados[oDados:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },"@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))

		oDados:AddColumn(TcColumn():New(STR0046,{ || OemToAnsi(aDados[oDados:nAt,1]) },"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

		oDados:AddColumn(TcColumn():New(STR0277,{ || OemToAnsi(aDados[oDados:nAt,2]) },"@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))

		//-------------------------------------------------------------------
		//  LGPD
		//-------------------------------------------------------------------
		if objCENFUNLGP:isLGPDAt()
			aCampos := {.F.,"BR0_CODIGO","BR0_DESCRI"}
			aBls := objCENFUNLGP:getTcBrw(aCampos)

			oDados:aObfuscatedCols := aBls
		endif

		oDados:SetArray(aDados)
		oDados:bLDblClick := { || aDados[oDados:nAt,3] := IF(aDados[oDados:nAt,3],.F.,.T.) }

		ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{}) CENTER

		If nOpca == K_OK

			cDado := ""
			For nInd := 1 To Len(aDados)
				If aDados[nInd,3]
					cDado += aDados[nInd,1]+","
				EndIf
			Next
		EndIf

		// Tira a virgula do final da string

		If SubStr(cDado, Len(cDado), 1) == ","
			cDado := SubStr(cDado, 1, Len(cDado) - 1)
		EndIf

		If !Empty(cCampo)
			cCampo  := "M->" + cCampo
			&cCampo := cDado
			___lVld := .T.
		EndIf



	Return If(lCspadrao, .T., cDado)

	/*/{Protheus.doc} PLVLDCGR
Valida conteudo do campo
@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function PLVLDCGR()
		LOCAL lRet := .F.

		If ___lVld
			___lVld := .F.
			lRet 	 := .T.
		EndIf

	Return(lRet)

	/*/{Protheus.doc} PLSGtNItem
Ajusta conteudo do parametro MV_NUMITEN
@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function PLSGtNItem(cNivelCob,aMatNiv)
		LOCAL nLimItens	 	:= 0
		LOCAL nNumIteSX6 	:= GetMV("MV_NUMITEN")
		DEFAULT cNivelCob	:= ""
		DEFAULT aMatNiv		:= {}

		// Quantidade de itens por nivel

		If ExistBlock("PLSGTNIT")
			nLimItens  := ExecBlock("PLSGTNIT",.F.,.F.,{cNivelCob,aMatNiv,nNumIteSX6})[1]
		EndIf

		// Retorno

		If nLimItens == 0 .Or. nNumIteSX6 < nLimItens
			nLimItens := nNumIteSX6
		EndIf

	Return(nLimItens)


	/*/{Protheus.doc} PLSPRETIT
Cria matriz de titulos
@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function PLSPRETIT(aCobAbr,lGrid,cAglutina,cModPag,cAno,cMes)
		LOCAL nX			:= 0
		LOCAL nI			:= 0
		LOCAL nY 			:= 0
		LOCAL nPT			:= 0
		LOCAL nPos			:= 1
		LOCAL nTotMat		:= 0
		LOCAL nParFin		:= 0
		LOCAL aVlrCobAux	:= {}
		LOCAL aVlrCob		:= {{},{},{}} // [1] = Custo; [2] = Pre-Pagamento; [3] = Parcela Patrocinada.
		LOCAL aVlrAcu		:= {{},{}}
		local aMatNota		:= {}
		LOCAL cCodUsr		:= ""
		LOCAL cNomUsr		:= ""
		LOCAL lNegativo	 	:= .F.
		LOCAL lPatroDif		:= .f.   //Patronal diferenciado (Acordo ANS CApesesp)
		LOCAL lConsad		:=  BDC->( FieldPos('BDC_CONSAD') ) > 0
		LOCAL lGerNFBRA		:= ( getNewPar("MV_PLSNFBR","0") == "1" .Or. cPaisLOC <> 'BRA' )

		// Se aglutina lancamentos ou nao
		If BDC->( FieldPos("BDC_AGLUTI") ) > 0 .And. cAglutina == '0'

			// Lancamentos de faturamentos - Valores

			For nX := 1 To Len(aCobAbr[6])

				// Parcela de Reembolso Patronal.
				// Não desmembra o titulo de mensalidade patrocinada se o tipo de cobranca da patronal for = Titular.
				If (Iif(ValType("aCobAbr[6,nX,3]") == "C",aCobAbr[6,nX,3] $ "186,188", .F.)) .AND. Len(aCobAbr) >= 26 .and. aCobAbr[26] <> "2"

				// Marca o lancamento como Custo operacional para calculo de vencimento diferenciado no titulo
				If Len( aCobAbr[6,nX] ) >= 66
					aCobAbr[6,nX,66] := "3"	// Patrocinado
				EndIf

				If	Len( aCobAbr[6,nX] ) >= 72
					If aCobAbr[6,nX,72]
						lPatroDif:=.T. //Patronal diferenciado (Acordo ANS CApesesp)
					Endif
				Endif

				// Verificar o tipo de cobrança
				// [1] - Patrocinado: Cobra da empresa - verificar cliente e dados deste nivel de cobrança.
				// [2] - Auto Patrocianado: Cobra tudo do nivel de cobrança da familia.
				// [3] - Compartilhado: Cobra da empresa e consede abatimento para a familia.

				// Adiciona na matriz correspondente.
				Aadd(aVlrCob[3], aCobAbr[6,nX] )

				// Custo operacional
				ElseIf (aCobAbr[6,nX,3] $ cCodigosPF) .And. cModPag $ '2,3, '

				// Marca o lancamento como Custo operacional para calculo de vencimento diferenciado no titulo
				If Len( aCobAbr[6,nX] ) >= 66
					aCobAbr[6,nX,66] := "2"	// Custo Operacional
				EndIf
				Aadd(aVlrCob[1], aCobAbr[6,nX] )

				// Outros lancamentos.
				ElseIf !(aCobAbr[6,nX,3] $ cCodigosPF) .And. cModPag $ '1,3, '
				// Marca o lancamento como Custo operacional para calculo de vencimento diferenciado no titulo
				If Len( aCobAbr[6,nX] ) >= 66
					aCobAbr[6,nX,66] := "1"	// Pre-Pagamento
				EndIf

				Aadd(aVlrCob[2], aCobAbr[6,nX] )
				ElseIf  aCobAbr[6,nX,16]=="BSQ" .And. lConsad  .And. cModPag $ '2, ' // dertermina os debitos e creditos da BSQ irão entrar na cobrança corrente

				If ValType(M->BDC_CONSAD) ="C"	.And.  M->BDC_CONSAD $ "1, "
					// Marca o lancamento como Custo operacional para calculo de vencimento diferenciado no titulo
					If Len( aCobAbr[6,nX] ) >= 66
						aCobAbr[6,nX,66] := "2"	// Pre-Pagamento
					EndIf

					Aadd(aVlrCob[1], aCobAbr[6,nX] )
				Endif

			EndIf
			Next


			// Acumulados

			For nX := 1 To Len(aCobAbr[21])

				// Custo operacional

				If (aCobAbr[21,nX,3] $ cCodigosPF) .And. cModPag $ '2,3, '
				AaDd(aVlrAcu[1], aCobAbr[21,nX] )

				// Outros

				ElseIf !(aCobAbr[21,nX,3] $ cCodigosPF) .And. cModPag $ '1,3, '
				AaDd(aVlrAcu[2], aCobAbr[21,nX] )
			EndIf
			Next
		Else
			For nX := 1 To Len(aCobAbr[6])

				// Parcela de Reembolso Patronal.
				// Não desmembra o titulo de mensalidade patrocinada se o tipo de cobranca da patronal for = Titular.
				If (Iif(ValType("aCobAbr[6,nX,3]") == "C",aCobAbr[6,nX,3] $ "186,188", .F.)) .AND. Len(aCobAbr) >= 26 .and. aCobAbr[26] <> "2"

				// Marca o lancamento como Custo operacional para calculo de vencimento diferenciado no titulo
				If Len( aCobAbr[6,nX] ) >= 66
					aCobAbr[6,nX,66] := "3"	// Patrocinado
				EndIf

				//Patronal diferenciado (Acordo ANS CApesesp)
				If	Len( aCobAbr[6,nX] ) >= 72
					If aCobAbr[6,nX,72]
						lPatroDif :=.T.
					Endif
				Endif

				// Adiciona na matriz correspondente.
				Aadd(aVlrCob[3], aCobAbr[6,nX] )

				// Custo operacional
				ElseIf (aCobAbr[6,nX,3] $ cCodigosPF) .And. cModPag $ '2, '

				// Marca o lancamento como Custo operacional para calculo de vencimento diferenciado no titulo
				If Len( aCobAbr[6,nX] ) >= 66
					aCobAbr[6,nX,66] := "2"	// Custo Operacional
				EndIf
				Aadd(aVlrCob[1], aCobAbr[6,nX] )

				// Outros lancamentos.
				ElseIf !(aCobAbr[6,nX,3] $ cCodigosPF) .And. cModPag $ '1, '
				// Marca o lancamento como Custo operacional para calculo de vencimento diferenciado no titulo
				If Len( aCobAbr[6,nX] ) >= 66
					aCobAbr[6,nX,66] := "1"	// Pre-Pagamento
				EndIf

				Aadd(aVlrCob[2], aCobAbr[6,nX] )

				ElseIf  aCobAbr[6,nX,16]=="BSQ" .And. lConsad  // dertermina os debitos e creditos da BSQ irão entrar na cobrança corrente

				If ValType(M->BDC_CONSAD) ="C"	.And.  M->BDC_CONSAD $ "1, "  .And. cModPag $ '2, '
					// Marca o lancamento como Custo operacional para calculo de vencimento diferenciado no titulo
					If Len( aCobAbr[6,nX] ) >= 66
						aCobAbr[6,nX,66] := "2"	// Custo Operacional
					EndIf

					Aadd(aVlrCob[1], aCobAbr[6,nX] )
				Endif

			EndIf
			Next

			If cModPag $ '3, ' //Ambas
				For nPT := 1 to Len(aCobAbr[6])
					If !aCobAbr[6][nPT][3] $ ("186,188")
						aAdd(aVlrCob[2],aCobAbr[6][nPT])
					Endif
				Next
			EndIf

			aVlrAcu[2] := aCobAbr[21]
		EndIf

		// Cobrança patronal de modo Compartilhada
		// Inclui Crédito para familia (NCC) quando o patronal não utilizar diferencial (B1L_PERPAT igual a 0)
		If Len(aCobAbr) >= 26 .and. aCobAbr[26] == "3" .and. ValType(aVlrCob[3]) == "A" .and. Len(aVlrCob[3]) > 0 .And. !lPatroDif
			VlrCredPatronal(@aCobAbr, @aVlrCob, cAno, cMes)
		Endif

		nTotMat := len(aVlrCob)

		if lGerNFBRA

			// Pega o numero de itens com base no parametro MV_NUMITEM ou RDMake
			nItensNF := PLSGtNItem(aCobAbr[9],aCobAbr[7])

			// Verifica se tem alguma itens a serem divididos
			for nI := 1 to nTotMat

				if len(aVlrCob[nI]) > nItensNF

					for nY := 1 to len(aVlrCob[nI])

						aadd(aMatNota, aVlrCob[nI, nY])

						if len(aMatNota) == nItensNF
							aadd(aVlrCobAux, aMatNota)
							aMatNota := {}
						endIf

					next

					if len(aMatNota) > 0
						aadd(aVlrCobAux, aMatNota)
						aMatNota := {}
					endIf

				endIf

			next

		endIf

		// Se nao for nf ou item de nota
		If Len(aVlrCobAux)==0

			For nI := 1 To nTotMat

				If Len(aVlrCob[nI]) > 0
					AaDd(aVlrCobAux, aVlrCob[nI])
				EndIf

			Next

		EndIf

		// Limpa memoria
		aVlrCob := {}

	Return( { aVlrCobAux, aVlrAcu, nParFin, lPatroDif } )


	/*/{Protheus.doc} PLSGERTIT
Gera titulo

@author  PLS TEAM
@version P12
@since   20/02/10
	/*/
	Function PLSGERTIT(aApoio)
		LOCAL cChave		:= aApoio[2]
		LOCAL aVlrCob		:= aApoio[3]
		LOCAL aVlrAcu		:= aApoio[4]
		LOCAL dVenc1		:= aApoio[5] //Vencimento Custo Ope.
		LOCAL dVenc2		:= aApoio[6] //Vencimento
		LOCAL cMes			:= aApoio[7]
		LOCAL cAno			:= aApoio[8]
		LOCAL dVencTo		:= aApoio[9]
		LOCAL cNumCob		:= aApoio[10]
		LOCAL dEmissao		:= aApoio[11]
		LOCAL cAglutina		:= aApoio[12]
		LOCAL cCodOpe		:= aApoio[13]
		LOCAL cCodCli		:= aApoio[14]
		LOCAL cLoja			:= aApoio[15]
		LOCAL cTpTitulo		:= aApoio[16]
		LOCAL _cNivel		:= aApoio[17]
		LOCAL aMatBa3		:= aApoio[18]
		LOCAL cGratuito		:= aApoio[19]
		LOCAL nCobComple	:= aApoio[20]
		LOCAL cNaturez		:= aApoio[21]
		LOCAL cTipoPag		:= aApoio[22]
		LOCAL cPortado		:= aApoio[23]
		LOCAL cAgePor		:= aApoio[24]
		LOCAL cCCPor		:= aApoio[25]
		LOCAL cBcoCli		:= aApoio[26]
		LOCAL cAgeCli		:= aApoio[27]
		LOCAL cCCCli		:= aApoio[28]
		LOCAL aRecnos		:= aApoio[29]
		LOCAL nRegBDC		:= aApoio[30]
		LOCAL lInterC		:= aApoio[31]
		LOCAL cDirFile		:= aApoio[32]
		LOCAL nTotLNF		:= aApoio[33]
		LOCAL nParFin		:= aApoio[34]
		LOCAL lRatImpost	:= aApoio[35]

		LOCAL cMesAux 		:= ""
		LOCAL cAnoAux 		:= ""
		local cPrefixo		:= ""
		local cNumero		:= ""
		local cNossoN		:= ""

		LOCAL nY 			:= 0
		LOCAL nI			:= 0
		LOCAL nJ			:= 0
		LOCAL nTotLid		:= 0

		local nVlrPatronal	:= 0
		local nValor		:= 0
		local nVlrCre		:= 0
		local nVlrDeb		:= 0
		local nVlrPCre		:= 0
		local nVlrPDeb		:= 0
		local nCredTotal    := 0
		local nDebitTotal   := 0

		local nValAcu		:= 0
		local nVencto		:= 0
		local nPLGERREC		:= 0
		local nPeriod   	:= 0

		local dVenc			:= CToD("")
		local cAnoMesAnt	:= PLSDIMAM(cAno,cMes,"0")
		local cTipReg		:= GetNewPar("MV_PLTRTIT","00")

		local lNCC			:= .f.
		local lTitNum		:= .f.
		local lCusOpe		:= .f.
		local lPeriod   	:= .f.

		local aMatBA1		:= {}
		local aMatCre		:= {}
		local aMatDeb		:= {}
		local aRetTit		:= {}
		local aCredit		:= {}
		local lGerNFBRA		:= getNewPar("MV_PLSNFBR","0") == "1"
		local lGerNCC		:=(getNewPar("MV_PLSNFBR","0") == "0").OR.( getNewPar("MV_PLGENCC","0")=='1')
		local nM			:= 0
		local aCritica      := {}

		PLSLOGFAT("GERANDO TITULOS",0,.T.)

		//Monto o array com base no arquivo gravado em disco
		If ! Empty(cDirFile)

			PLSLOGFAT("LENDO DO ARQUIVO - " + cDirFile,1)

			//Montando matriz
			aVlrCob := PLSFARRAY(cDirFile,nTotLNF)
			nTotLid := Len(aVlrCob)

			PLSLOGFAT("REG. EM DISCO - " + AllTrim( Str( nTotLNF ) ) + " TRANSFERIDO P/ MATRIZ - " + AllTrim( Str( nTotLid ) ),1)

		EndIf

		//Pega o primeiro registro para verificar se e um titulo de custo operacional
		If Len(aVlrCob) > 0 .And. Len(aVlrCob[1]) >= 66
			lCusOpe	:= Iif(aVlrCob[1,66]=="2", .T., .F.)
		EndIf

		// Soma o valor do titulo
		nVlrCre	 := 0
		nVlrDeb	 := 0
		nVlrPCre := 0
		nVlrPDeb := 0
		nValAcu	 := 0

		If ExistBlock("PLSALTCOB")
			aVlrCob := Execblock("PLSALTCOB",.F.,.F., { aVlrCob } )
		Endif

		For nY := 1 To Len(aVlrCob)

			If  !lGerNcc
				//Regra
				//Quando o paramentro MV_PLSNFBR (geração de nota) estiver habilitado e o paramentro MV_PLGENCC ( geração de NCC no financeiro ) estiver desabilitado
				//significa que antes de gerar a nota a rotina ou titulo no financeiro, vai compensar o credito com debito e gerar a nota ou título com o valor liquido ja
				//decontado os credito, e irá efetuar baixa do credito na BSQ
				//Modo antigo

				If aVlrCob[nY,1] == '1'
					nValor += Round(aVlrCob[nY,2], 2)
					nDebitTotal += Round(aVlrCob[nY,2], 2)
				Else
					nValor -= Round(aVlrCob[nY,2], 2)
					nCredTotal += Round(aVlrCob[nY,2], 2)
				EndIf

				nVlrDeb := nValor

				If aVlrCob[nY,1] == '1'
					aadd(aMatDeb, aClone(aVlrCob[nY]))
				else
					aadd(aMatCre, aClone(aVlrCob[nY]))
				endIf

			Else
				//Regra 1
				//Quando o paramentro MV_PLSNFBR (geração de nota) estiver habilitado e o paramentro MV_PLGENCC ( geração de NCC no financeiro ) estiver habilitado
				//significa que a rotina rotina irá gerar o valor da nota com seu valor bruto, sem descontar os credito, isso sera feito compensação manual na rotina do financeiro


				//Regra 2
				//Quando o paramentro MV_PLSNFBR (geração de nota) estiver desabilitado significa que sera gerados dos titulos nos SE1
				//Caso algune desses campos estiver ativo(BT5_CONAUT/BQC_CONAUT/BA3_CONAUT), significa que sera feita a compensação automatica.
				//Chamada da função MaintBxCr()

				//Se e credito ou debito
				If aVlrCob[nY,1] == '1'
					nVlrDeb += Round(aVlrCob[nY,2], 2)
				Else
					nVlrCre += Round(aVlrCob[nY,2], 2)
				EndIf

				// Se é credito ou debito
				If aVlrCob[nY,1] == '1'
					nVlrPDeb +=	aVlrCob[nY,23]
				Else
					nVlrPCre += aVlrCob[nY,23]
				EndIf

				If aVlrCob[nY,1] == '1'
					aadd(aMatDeb, aClone(aVlrCob[nY]))
				else
					aadd(aMatCre, aClone(aVlrCob[nY]))
				endIf

			Endif

			// Verifica se e Periodicidade
			If ! lPeriod .And. Len(aVlrCob[nY]) > 64 .And. aVlrCob[nY,65] > 0
				lPeriod := .t.
				nPeriod := aVlrCob[nY,65]
			EndIf

		Next

		If ! lGerNFBRA
			aVlrCob := aSize(aVlrCob, 0)
			aVlrCob := {}
		Endif

		If Len(aVlrAcu) >= nParFin

			For nY := 1 To Len(aVlrAcu[nParFin])

				If Len(aVlrAcu[nParFin,nY]) > 24
					nValAcu += Round(aVlrAcu[nParFin,nY,24], 2) + Round(aVlrAcu[nParFin,nY,25], 2)
				EndIf

			Next

		EndIf

		// Calcula a data de emissao para utilizar na regra de data de vencimeno.
		If Empty(dEmissao)

			// Pre-pagento
			If nParFin > 1
				dEmissao := Ctod( "01/" + cMes + "/" + cAno )
				// Custo operacional...
			Else
				dEmissao := LastDay( CTod("01/" + Subs(cAnoMesAnt,5,2) + "/" + Subs(cAnoMesAnt,1,4) ) )
			EndIf

		EndIf

		// Aplica regra para calculo da data de vencimento, para nao permitir que ela seja menor que a data de emissao.            |
		If Iif( lCusOpe, dVenc1, dVenc2 ) < dEmissao

			cMesAux := StrZero((Val(cMes)+1), 2)
			cAnoAux := cAno

			If cMesAux > '12'
				cMesAux := '01'
				cAnoAux := StrZero((Val(cAno)+1), 4)
			EndIf

			If lCusOpe
				dVenc := PLMontVen(Iif(dVencTo > 0, dVencTo, If(nVencto > 0, nVencTo, Day(dVenc1))),cMesAux,cAnoAux)
			Else
				dVenc := PLMontVen(Iif(dVencTo > 0, dVencTo, If(nVencto > 0, nVencTo, Day(dVenc2))),cMesAux,cAnoAux)
			EndIf

		Else
			dVenc := Iif( lCusOpe ,dVenc1, dVenc2)
		EndIf

		// Inicio da gravacao dos dados do titulo
		nPLGERREC++

		//grava o titulo principal e NCC se existir
		while nVlrDeb > 0 .or. nVlrCre > 0

			lNCC 	:= .f.
			aCredit := {}

			if  lGerNCC
				//Regra
				//Vai gerar NCC estou em um While primeiro ele vai gerar  titulo
				//Apos feito isso sera gerado o credito para compensação, e se alguns desses campos estiver habilitado(BT5_CONAUT/BQC_CONAUT/BA3_CONAUT),
				//significa que sera feita a compensação automatica.
				//Chamada da função MaintBxCr()


				if nVlrDeb > 0

					lTitNum		:= .t.
					nValor  	:= nVlrDeb


					nVlrPatronal:= nValor
					aVlrCob 	:= aClone(aMatDeb)
					aMatDeb 	:= aSize(aMatDeb, 0)
					aMatDeb 	:= {}
					nVlrDeb		:= 0
					cPrefixo	:= ''
					cNumero		:= ''
					cNossoN		:= ''
					aCredit 	:= aClone(aMatCre)

				elseIf nVlrCre > 0

					lTitNum		:= ! lTitNum

					If GetNewPar("MV_PLGENCC","0")=='0'
						lNCC		:= .f.
						nValor  	:= 0
					Else
						lNCC		:= .t.
						nValor  	:= nVlrCre
					Endif

					nVlrPatronal:= nVlrPCre
					aVlrCob 	:= aClone(aMatCre)
					aMatCre 	:= aSize(aMatCre, 0)
					aMatCre 	:= {}
					nVlrCre		:= 0

				EndIf

			else
				//Regra gerando nota fiscal
				//Nesse item iremos gerar a nota fical caso tenha creditos no sera tratado no plstose1 PLSAGLUSD2
				If nVlrDeb > 0
					aMatCre		:= {}
					lTitNum		:= .t.
					nVlrDeb		:= 0
					nVlrCre		:= 0

					nVlrPatronal:= nValor

				Endif
			endIf

			// Geracao do titulo
			aRetTit := PLGERREC(	@cPrefixo,;									// 01 Prefixo
				@cNumero,;									// 02 Numero do titulo
				cChave,;									// 03 Chave do nivel de cobranca
				cMes,;										// 04 Mes
				cAno,;										// 05 Ano
				dVenc,;										// 06 Data de vencimento do titulo
				cNumCob,;									// 07 Numero do lote de conbranca
				nValor,;									// 08 Valor do titulo
				@cNossoN,;									// 09 Nosso numero
				cCodCli,;									// 10 Codigo do cliente
				cLoja,;										// 11 Loja do cliente
				cTpTitulo,;								    // 12 Tipo do titulo
				aVlrCob,;									// 13 Matriz com a composicao da cobranca // Posicao [6] da aCobAbr
				_cNivel,;									// 14 Nivel de cobranca
				aMatBa3,;									// 15 Matriz com as familias
				cGratuito,;									// 16 Gratuidade do mes
				.T.,;										// 17 Cobranca aberta ou fechada ( obsoleto )
				nCobComple,;								// 18 Acrecimos, complemento do titulo
				.F.,;										// 19 Intercambio sim ou nao
				.F.,;										// 20 Inciste ( obsoleto )
				NIL,;										// 21 Banco
				NIL,;										// 22 Situacao do titulo (E1_SITUACA)
				cNaturez,;									// 23 Natureza
				Iif(lCusOpe,'1','0'),;						// 24 Indica se eh fatura de custo operacionao ou nao - 1 = Somente Custo Operacional, 0 = Outros, ou inclusive com custo!
				'1',;                                       // 25 Indica que o  titulo foi gerado pelo lote de cobranca...
				cTipoPag,; 									// 26 Tipo de pagamento
				cPortado,;									// 27 Portador
				cAgePor,;									// 28 Agencia portador
				cCCPor,;									// 29 Conta corrente portador
				cBcoCli,;									// 30 Banco cliente
				cAgeCli,;									// 31 Agencia cliente
				cCCCli,;                        			// 32 Conta cliente
				dEmissao,;									// 33 Data de emissao
				.t.,;										// 34 Liga criticas
				.f.,;										// 35 Liga ou desliga contabilizacao on-line.
				Iif(lCusOpe .Or. cAglutina == '1', aRecnos, {}),; // 36 Passa matriz com Recno's.
				aVlrAcu,;									// 37 Acumulado para proxima competencia
				nValAcu,;                           		// 38 valor acumulado
				cCodOpe,;									// 39 Codigo da operadora
				aEventosCb,;				    			// 40 Eventos da cobranca
				aAcertos,;									// 41 Eventos da cobranca por valores acumulados.
				aEveUsr,;									// 42 Eventos da cobranca do usuario.
				nPLGERREC,;									// 43
				{},;                                 		// 44
				lNCC,;										// 45 Define se e NCC
				nil,;										// 46 Nao esta mais sendo usado
				lTitNum,;									// 47 Cria o proximo numero do titulo
				"1",;										// 48 Tipo usada na funcao plsa625MDA
				"1",;										// 49 Origem usada na funcao plsa625MDA
				lPeriod,;       							// 50 Verifica se é Periodicidade
				/*nPeriod*/,;       						// 51 - Numero de meses da Periodicidade
				/*cTipCob*/,;       						// 52 - Tipo de cobranca Ptu A500 / 1-NDC 2-Fatura 3-Ambos
				/*nPosIntTit*/,;      						// 53 - Posicao titulo intercambio
				aCredit,;									// 54 - Conteudo que sera gerado NCC para apuracao da base de impostos
				lRatImpost)        							// 55 - Gravação do Rateio de Impostos

			// Grava os detalhes finais a respeito da gravacao to titulo.
			BDC->( DbGoto(nRegBDC) )

			// Grava mais informacoes sobre dados gerados e dados criticados no lote.
			If ! BDC->( Eof() )

				If Len(aRetTit[1]) > 0

					// Somente se titulo foi gerado
					If aRetTit[1,1]

						// Dados do Usuario
						aMatBA1 := aRetTit[1,7]

						// Atualiza dados do usuario
						For nI := 1 To Len(aMatBA1)

							BA1->( DbGoto(aMatBA1[nI,1]) )

							// Atualiza tabela
							BA1->( RecLock("BA1", .F.) )

							BA1->BA1_JACOBR := "1"

							If Empty(BA1->BA1_COBINI)
								BA1->BA1_COBINI := aMatBA1[nI,2]
								BA1->BA1_ANOMES := aMatBA1[nI,3]
							EndIf

							// Cobranca de taxa no ato nao vai gerar o BM1 somente coloca o numero da cobranca
							If 	BA1->BA1_CBTXAD = "1" .And. Empty(BA1->BA1_NUMCOB)
								BA1->BA1_NUMCOB := aMatBA1[nI,2]
							EndIf

							// Conforme lancamento
							If aMatBA1[nI,4] > 0
								BA1->BA1_CBTXAD := "1"
								BA1->BA1_NUMCOB := aMatBA1[nI,2]
								BA1->BA1_VLTXAD := aMatBA1[nI,4]
							EndIf

							If aMatBA1[nI,5] > 0
								BA1->BA1_TXADOP := "1"
								BA1->BA1_VLTXOP := aMatBA1[nI,5]
							EndIf

							BA1->( MsUnLock() )

						Next

						SIX->(DbSetOrder(1))//INDICE + ORDEM
						If  SIX->(DbSeek("BZX" + "2")) .And. ("BZX")->(FieldPos("BZX_NUMCOB")) > 0

							//Posicionando na tabela BZX para gravar o campo BZX_NUMCOB que indicará se a taxa de adesão do opcional para o beneficiário já foi cobrada
							BZX->(DbSetOrder(1))//BZX_FILIAL + BZX_CODOPE + BZX_CODEMP + BZX_MATRIC + BZX_TIPREG + BZX_CODOPC + BZX_VEROPC

							For nJ := 1 TO Len(aVlrCob)

								//verificando se é taxa de adesão
								If aVlrCob[nJ][3] == "133"

									If BZX->(DbSeek( xFilial("BZX") + SubStr(aVlrCob[nJ][7],1,16) + aVlrCob[nJ][4] + aVlrCob[nJ][35] ))
										BZX->(RecLock("BZX", .F.))
										BZX->BZX_NUMCOB := SubStr(aVlrCob[nJ][7],1,4) +  cNumCob //CODOPE + NUMCOB
										BZX->(MsUnLock())
										BZX->(DbSkip())
									EndIf

								EndIf

							Next

						EndIf

						PLSLOGFAT("ATUALIZA DADOS DO USUARIO",1)

					EndIf

					// Critica
					PLSA625Cri(cNumCob,;
						Iif(aRetTit[1,4] > 0 , nVlrPatronal, nValor),;
						aRetTit,;
						Substr(aMatBa3[3],01,04),;
						Substr(aMatBa3[3],05,04),;
						Substr(aMatBa3[3],09,12),;
						Substr(aMatBa3[3],21,03),;
						Substr(aMatBa3[3],24,09),;
						Substr(aMatBa3[3],33,03),;
						Substr(aMatBa3[4],09,06),;
						Iif(_cNivel == "5", Substr(aMatBa3[5],15,2), cTipReg),;
						_cNivel,;
						Iif( lCusOpe, Substr(cAnoMesAnt,1,4),cAno),;
						Iif( lCusOpe, Substr(cAnoMesAnt,5,2),cMes),;
						lInterC)

				EndIf

			EndIf

			PLSLOGFAT("PROCESSO DE GERACAO DO TITULO",1,.F.)

		endDo

		// Situação para Nota Fiscal com NCC Desabilitado onde possui crédito maior ou igual ao debito
		If (nCredTotal >= nDebitTotal .And. nCredTotal <> 0 .And. nDebitTotal <> 0) .And. lGerNFBRA .And. !lGerNcc
			aCritica := A627RetCri(aCritica, "26", (nDebitTotal - nCredTotal))

			If ExistBlock("PLS510AC")

				aRetPto	 := ExecBlock("PLS510AC",.F.,.F.,{_cNivel,cChave,nValor,aCritica,cMes,cAno,cNumCob,aVlrCob,.F.})
				aCritica := aRetPto[2]

				PLSLOGFAT("PLS510AC",1,.F.)

			EndIf

			PLSA625Cri( cNumCob,;
				(nDebitTotal - nCredTotal),;
				aCritica,;
				Substr(aMatBa3[3], 01, 04),;
				Substr(aMatBa3[3], 05, 04),;
				Substr(aMatBa3[3], 09, 12),;
				Substr(aMatBa3[3], 21, 03),;
				Substr(aMatBa3[3], 24, 09),;
				Substr(aMatBa3[3], 33, 03),;
				Substr(aMatBa3[4], 09, 06),;
				IIF(_cNivel == "5", Substr(aMatBa3[5], 15, 2), cTipReg),;
				_cNivel,;
				IIF(lCusOpe, Substr(cAnoMesAnt, 1, 4), cAno),;
				IIF(lCusOpe, Substr(cAnoMesAnt, 5, 2), cMes),;
				lInterC,,,,, .F.)
		EndIf

	Return( { STR0235, .T., cChave, "", "" } )

	/*/{Protheus.doc} PLSLOGFAT
Log do faturamento
Cuidado ao usar esta funcao no GRID o ambiente pode nao estar preparado
@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function PLSLOGFAT(cTitulo,nTp,lSp,cTitCha,cChave)
		LOCAL lLogF  	:= GetNewPar("MV_PLSFAPU","0")=="1"
		DEFAULT cChave 	:= ""
		DEFAULT lSp		:= (nTp==1)

		// LOG

		If lLogF
			PLSLOGFIL(PadR(AllTrim(ProcName(1)),12)+": "+PadR("["+AllTrim(cTitulo)+"]",60)+" => "+Iif(nTp==0,"INICIO","FIM   ")+" ["+DToC(Date())+" - "+Time()+"]",__PLSFLOGX)

			If !Empty(cChave)
				PLSLOGFIL(cTitCha+' - ['+cChave+']',__PLSFLOGX)
			EndIf
			If lSp
				PLSLOGFIL("",__PLSFLOGX)
			EndIf
		EndIf

	Return

	/*/{Protheus.doc} PL627LANTB

@author  PLS TEAM
@since   20173007
@version p11
	/*/
	Function PL627LANTB()
		LOCAL aRet := {}
		LOCAL nCount := 0
		local CsQL := ""
		Local lAutomato := IsInCallstack("PLSA627052")

		// Pesquisa o codigo do tipo de deb/cred relacionado ao lanc. de faturamento de juros no mes seguinte..

		cSql := "SELECT * FROM "+BSP->(RetSqlName("BSP"))+" WHERE BSP_FILIAL = '"+xFilial("BSP")+"' "
		cSql += "AND BSP_CODLAN = '188' "
		cSql += "AND D_E_L_E_T_ = ' ' "
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cSql)),"TRBTAB",.F.,.T.)

		// Conta os registros obtidos... permitido no maximo 1 registro...

		TRBTAB->( dbEval({|| nCount ++ }) )


		// Verifica se o retorno eh valido...

		If nCount == 0
			TRBTAB->(dbClosearea())
			Return(aRet)

		Elseif nCount > 1
			If( !lAutomato,MsgAlert("Existe mais de um TIPO DE LANC. DE DEBITO/CREDITO relacionado ao codigo '188', "+;
					"referente a Desconto de mensalidade Patrocinada, cadastrado no sistema! Verifique o cadastro de lancamentos de debito/creditos."),)
				lRet := .F.

			Else
				TRBTAB->( dbGotop() )
				aRet	 := {TRBTAB->BSP_CODSER,TRBTAB->BSP_DESCRI,TRBTAB->BSP_TIPSER,TRBTAB->BSP_CODLAN}
			Endif


			// Fecha area de trabalho temporaria...

			TRBTAB->(dbClosearea())

			Return( aRet )

			/*/{Protheus.doc} PlsInitHx
Inicializa variaveis tipo HashMap caso o servidor nao seja Linux
@type function
@author PLS TEAM
@since 18/10/2016
			/*/
			function PLSInitHx(xObj,lHashMap)
				default lHashMap := !IsSrvUnix()

				if lHashMap
					xObj := THashMap():New()
				else
					xObj := {}
				endif

			return
			/*/{Protheus.doc} PL627men
Para carregar o menudef na rotina de Privilégios
@type function
@author PLS TEAM
@since 18/10/2016
			/*/
			Function PL627men(nopc)

				//  LGPD
				objCENFUNLGP:useLogUser()

				PL627MOV("BDC", BDC->(Recno()),nopc)

			Return


			/*/{Protheus.doc} PL627MNU
@type function
@author PLS TEAM
@since 18/10/2016
			/*/
			Function PL627MNU()

				PLS627CHK(BDC->(Recno()))

			Return

			/*/{Protheus.doc} Pl627TitNcc()
Verifica se na exclusão há titulos Ncc Ja compensados
Antes de chamar essa função o ponteiro deve estar posicionado no SE1 corrente
@type function
@author PLS TEAM
@since 18/10/2016
			/*/
			Function Pl627TitNcc()

				Local lret 		:= .T.
				Local aAreaSE1 	:= SE1->(GetArea())
				Local cTitRef	:= SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM)
				Local aRecSE1	:= {}
				Local aRecNCC	:= {}
				Local aEstorno	:= {}

				Pergunte("FIN330",.F.)

				lContabiliza    := MV_PAR09 == 1
				lAglutina       := .F.
				lDigita         := .F.


				SE5->(DbSetORder(7))
				FK1->(DbSetORder(2))

				//Chave para ser recuperada na FK7.
				cChave := SE1->E1_FILIAL + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" +SE1->E1_CLIENTE + "|" + SE1->E1_LOJA

				//Recupera o Id da FK7
				cIdDoc := FinBuscaFK7(cChave,"SE1")


				//Precisamos verficar estiver se o titulo principal teve a baixa total ou parcial feito pelo módulo de contas a receber, se caso isso for,
				//não podemos seguir com o cancelamento do lote
				If Alltrim(SE1->E1_TIPO) == "DP"  .and. !Empty(cIdDoc)

					If(FK1->(DbSeek(xFilial("FK1")+cIdDoc)))
						While !FK1->(Eof()) .and. FK1->( FK1_FILIAL+FK1_IDDOC) == FK1->FK1_FILIAL + cIdDoc

							//Se tiver lançamentos no SE5 que não seja de origem do PLS (PLSA627) e não posso deixar baixar e nem cancelar as NCC desse titulo
							If Alltrim(FK1->(FK1_ORIGEM)) <> "PLSA627"
								Return(.F.)
							Endif

							FK1->(DbSkip())
						Enddo

					EndIf

				EndIf


				aAdd(aRecSE1,SE1->(Recno()))


				While SE1->(!Eof()) .and.  SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == cTitRef

					If Alltrim(SE1->E1_TIPO) == "NCC" .And. SE1->E1_SALDO <> 0 //Ajustado para quando for o saldo <> 0 porque se o campo E1_BAIXA estivesse com data, ele excluía a baixa do título ao entrar na MaIntBxCR
						aAdd(aRecNCC,SE1->(Recno()))
					Else
						If(SE5->(DbSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) )))
							aAdd(aEstorno, {{SE5->E5_DOCUMEN},SE5->E5_SEQ})
						Endif

					Endif

					SE1->(DbSkip())
				Enddo

				RestArea(aAreaSE1)

				If Len(aRecNCC) > 0  .and. Len(aEstorno) > 0
					lRet := MaIntBxCR(3,aRecSE1,,aRecNCC,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,aEstorno )

					if lRet .And. lHabMetric .and. lLibSupFw .and. lVrsAppSw
						FWMetrics():addMetrics(FunName(), {{"totvs-saude-planos-protheus_utilizacao-de-ncc_total", 1 }} )
					endif
				Endif


			Return lRet

			/*/{Protheus.doc} Pl627TitNcc()
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSRETAGL ³ Autor ³ Alexander Santos      ³ Data ³ 04.03.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna condicao de aglutinacao							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
			/*/
			Function PLSRETAGL(aVlrCob,cItemOri,cCodProSB1,cCodTES,cValorItem,cMatric,;
					cPPrcVen,cPTES,cPCod,cPMat,aStruSD2,lCredito)
				LOCAL nJ			:= 0
				LOCAL nPosAGL		:= 0
				LOCAL bAglut 		:= ""
				LOCAL cPDescon		:= "40"
				LOCAL aAuxAGL 		:= {}
				DEFAULT aStruSD2	:= {}
				DEFAULT lCredito	:= .F.
				DEFAULT cPMat		:= ""
				DEFAULT cMatric		:= ""
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Conteudo Default														   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				bAglut := " {|| Ascan("+cItemOri+",{ |x| x["+cPCod+"] == "+cCodProSB1+" .And. "
				bAglut +=                              	" x["+cPTES+"] == "+cCodTES
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Nao considera valor na pesquisa de credito								   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lCredito
					If GetNewPar("MV_PLSPRAG","0") == "1"
						bAglut += " .And. abs(x["+cPPrcVen+"]) == abs("+cValorItem+") "
					Endif
				ElseIf !Empty(cPMat)
					bAglut += " .And. x["+cPMat+"] == "+cMatric
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se considera ou nao o valor liquido na regra de aglutinacao				   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If GetNewPar("MV_PLSVLDI","0") == "1"
						bAglut += " .And. x[1] == '1' "
						bAglut += " .And. ( abs(x["+cPPrcVen+"])-abs(x["+cPDescon+"]) ) >= abs("+cValorItem+") "
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existem mais campos a serem Aglutinados 					   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aVlrCob) < 64 .Or. Len(aVlrCob[64]) = 0
					bAglut     += "}) }"
				Else
					aAuxAGL	:= aVlrCob[64]
					For nJ := 1 to Len(aAuxAGL)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ considera aglutinacao e o campo existe no sd2							   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Len(aStruSD2)>0
							nPosAGL := aScan(aStruSD2,{|x| AllTrim(x[1]) == AllTrim(aAuxAGL[nJ,2]) } )

							If aAuxAGL[nJ,3] .And. nPosAGL > 0
								If ValType(aAuxAGL[nJ,1]) == "C"
									bAglut     += " .And. x[" + cValToChar(nPosAGL) + "] == '" + aAuxAGL[nJ,1] +  "' "
								ElseIf ValType(aAuxAGL[nJ,1]) == "N"
									bAglut     += " .And. abs(x[" + cValToChar(nPosAGL) + "]) == abs(" + cValToChar(aAuxAGL[nJ,1]) +  ") "
								ElseIf ValType(aAuxAGL[nJ,1]) == "D"
									bAglut     += " .And. DTOS(x[" + cValToChar(nPosAGL) + "]) == '" + DTOS(aAuxAGL[nJ,1]) +  "' "
								EndIf
							EndIf
						Else
							If aAuxAGL[nJ,3]
								If ValType(aAuxAGL[nJ,1]) == "C"
									bAglut     += " .And. x[64," + cValToChar(nJ) + ",1] == '" + aAuxAGL[nJ,1] +  "' "
								ElseIf ValType(aAuxAGL[nJ,1]) == "N"
									bAglut     += " .And. abs(x[64," + cValToChar(nJ) + ",1]) == abs(" + cValToChar(aAuxAGL[nJ,1]) +  ") "
								ElseIf ValType(aAuxAGL[nJ,1]) == "D"
									bAglut     += " .And. DTOS(x[64," + cValToChar(nJ) + ",1]) == '" + DTOS(aAuxAGL[nJ,1]) +  "' "
								EndIf
							EndIf
						EndIf
					Next nJ
					bAglut     += "}) }"
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Fim da Funcao															   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Return(bAglut)


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} CredVlrPatronal
Gera um lançamento de crédito (188) de desconto para o beneficiário com o valor da parcela
patrocinada como o modo de cobrança for COMPARTILHADA

@author Vinicius Queiros Teixeira
@since 12/05/2022
@version Protheus 12
@obs
Parcela Patronal Compartilhada: são gerados dois títulos para cada família do subcontrato.
A parcela patrocinada é gerada para a empresa e revertida em desconto na mensalidade da
família. Portanto, ao gerar o titulo da família, um desconto na mensalidade é concedido,
referente à parcela patrocinada. Para conceder o desconto para a família, um lançamento
de crédito é gerado (NCC).
/*/
//---------------------------------------------------------------------------------------
Static Function VlrCredPatronal(aCobAbr, aVlrCob, cAno, cMes)

	Local lRetorno := .F.
	Local nValorProduto := 0
	Local nValorPatronal := 0
	Local nValorCredito := 0
	Local lNegativo := .F.
	Local nX := 0
	Local nPos := 0
	Local cMatriculaBenef := ""
	Local aCobBeneficiarios := {}
	Local oDadosCobranca := Nil
	Local nSourceBound := 0

	Default aCobAbr := {}
	Default aVlrCob := {{},{},{}} // // [1] = Custo; [2] = Pre-Pagamento; [3] = Parcela Patrocinada.
	Default cAno := ""
	Default cMes := ""

	If Len(aVlrCob[3]) > 0
		For nX := 1 To Len(aVlrCob[3])

			cMatriculaBenef := aVlrCob[3][nX][7]
			nValorPatronal := aVlrCob[3][nX][2]

			nPos := Ascan(aCobBeneficiarios, {|x| x["matricula"] == cMatriculaBenef})

			IIf(nPos > 0, aCobBeneficiarios[nPos]["valorPatronal"] += nValorPatronal, Nil)

			If nPos == 0
				oDadosCobranca := JsonObject():New()

				oDadosCobranca["matricula"] := cMatriculaBenef					
				oDadosCobranca["valorProduto"] := 0
				oDadosCobranca["valorPatronal"] := nValorPatronal
				oDadosCobranca["operadora"] := aVlrCob[3][nX][41]
				oDadosCobranca["empresa"] := aVlrCob[3][nX][42]
				oDadosCobranca["matriculaFamilia"] := aVlrCob[3][nX][43]
				oDadosCobranca["contrato"] := aVlrCob[3][nX][44]
				oDadosCobranca["versaoContrato"] := aVlrCob[3][nX][45]
				oDadosCobranca["subcontrato"] := aVlrCob[3][nX][46]
				oDadosCobranca["versaoSubcontrato"] := aVlrCob[3][nX][47]
				oDadosCobranca["nome"] := Alltrim(aVlrCob[3][nX][8])
				oDadosCobranca["posicaoBeneficiario"] := Ascan(aCobAbr[6], {|x| x[7] == cMatriculaBenef})

				aAdd(aCobBeneficiarios, oDadosCobranca)

				FreeObj(oDadosCobranca)
				oDadosCobranca := Nil			
			EndIf

		Next
	EndIf

	If Len(aVlrCob[2]) > 0
		For nX := 1 To Len(aVlrCob[2])
			If aVlrCob[2][nX][3] == "101" // 101 = Produto/Plano (Mensalidade)

				cMatriculaBenef := aVlrCob[2][nX][7]
				nValorProduto := aVlrCob[2][nX][2]
				
				nPos := Ascan(aCobBeneficiarios, {|x| x["matricula"] == cMatriculaBenef})

				If nPos > 0
					aCobBeneficiarios[nPos]["valorProduto"] += nValorProduto
				EndIf

			Endif
		Next
	EndIf

	For nX := 1 To Len(aCobBeneficiarios)

		nValorProduto := aCobBeneficiarios[nX]["valorProduto"]
		nValorPatronal := aCobBeneficiarios[nX]["valorPatronal"]
		nSourceBound := aCobBeneficiarios[nX]["posicaoBeneficiario"]

		// O valor do crédito da parcela patronal está limitado ao valor total da mensalidade da família.
		Do Case
			Case nValorProduto > nValorPatronal
				nValorCredito := nValorPatronal
				lNegativo := .F.

			Case nValorProduto < nValorPatronal
				nValorCredito := nValorProduto
				lNegativo := .T.

			Case nValorProduto == nValorPatronal
				nValorCredito := nValorProduto
				lNegativo := .T.
		EndCase

		If nValorCredito > 0 .And. Len(aCodLan) > 0 .And. Len(aCobAbr) > 0

			Begin Transaction

				BSQ->( Reclock("BSQ",.T.) )
				BSQ->BSQ_FILIAL := xFilial("BSQ")
				BSQ->BSQ_CODSEQ := GETSX8NUM("BSQ","BSQ_CODSEQ")
				BSQ->BSQ_USUARI := aCobBeneficiarios[nX]["matricula"]
				BSQ->BSQ_CODINT := aCobBeneficiarios[nX]["operadora"]
				BSQ->BSQ_CODEMP := aCobBeneficiarios[nX]["empresa"]
				BSQ->BSQ_MATRIC := aCobBeneficiarios[nX]["matriculaFamilia"]
				BSQ->BSQ_CONEMP := aCobBeneficiarios[nX]["contrato"]
				BSQ->BSQ_VERCON := aCobBeneficiarios[nX]["versaoContrato"]
				BSQ->BSQ_SUBCON:= aCobBeneficiarios[nX]["subcontrato"]
				BSQ->BSQ_VERSUB := aCobBeneficiarios[nX]["versaoSubcontrato"]
				BSQ->BSQ_ANO := cAno
				BSQ->BSQ_MES := cMes
				BSQ->BSQ_CODLAN	:= aCodLan[1]
				BSQ->BSQ_TIPO := "2" // Crédito
				BSQ->BSQ_VALOR := IIf(!lNegativo, nValorCredito, (nValorCredito - 0.03))
				BSQ->BSQ_TIPEMP := "2" // Pessoa Juridica
				BSQ->BSQ_AUTOMA := "1"
				BSQ->BSQ_COBNIV := "4" // Nivel Familia
				BSQ->(MsUnLock())

			End Transaction
			BSQ->(ConfirmSx8())

			// Cria um clone da posicao da matriz do titular que se refere a mensalidade patronal
			Aadd( aCobAbr[6], aClone(aCobAbr[6][nSourceBound]) )
			nPos := Len(aCobAbr[6])

			aCobAbr[6][nPos][01] := aCodLan[3]
			aCobAbr[6][nPos][02] := IIf(!lNegativo, nValorCredito, (nValorCredito - 0.03))
			aCobAbr[6][nPos][03] := "188"
			aCobAbr[6][nPos][04] := aCodLan[1]
			aCobAbr[6][nPos][05] := aCodLan[2]
			aCobAbr[6][nPos][08] := aCobBeneficiarios[nX]["nome"]
			aCobAbr[6][nPos][09] := .F.
			aCobAbr[6][nPos][17] := "BSQ"
			aCobAbr[6][nPos][18] := BSQ->BSQ_CODSEQ
			aCobAbr[6][nPos][27] := BSQ->( Recno() )
			aCobAbr[6][nPos][30] := BSQ->BSQ_CODSEQ

			If Len(aCobAbr[6,nPos]) >= 66
				aCobAbr[6,nPos,66] := "1" // Pre-Pagamento
			EndIf

			Aadd(aVlrCob[2], aCobAbr[6, nPos] )

			lRetorno := .T.
		Endif

	Next nX

Return lRetorno