#include "PLSMGER.CH"
#include "PROTHEUS.CH"

STATIC cArquivo   := ""
STATIC cPerg      := "PLS1100    "
STATIC aCriticas  := {}
STATIC cCodPaPro  := GetNewPar("MV_PLSTBPD", "01") // Codigo da tabela padrão
STATIC aCodEdi	  := {}
STATIC cCodLayPLS := ""
STATIC aTpPart    := {}
STATIC nLine      := 1
STATIC lImpPTU    := .T.
STATIC a1100Pos   := {}
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ PLSP1100   ³ Autor ³                    ³ Data ³ 04.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Importacao A1100                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSP1100()

LOCAL aCores 	  := {}
PRIVATE nRecno	  := 0
PRIVATE cNumero	  := ""
PRIVATE aCdCores  := {}
PRIVATE cCadastro := "Importacao PTU 1100"
PRIVATE aDadRda   :={}       
PRIVATE aDadUsr   :={}

PRIVATE aRotina   := {{ "Pesquisar"		 ,'AxPesqui'	, 0 , K_Pesquisar  },;
		              { "Visualizar"	 ,'PLSED1100'	, 0 , K_Visualizar },;
                      { "Importar"		 ,'PLSED1100IM'	, 0 , K_Incluir    },;
                      { "Canc.Importacao",'PLSED1100CN'	, 0 , K_Alterar    },;
                      { "Legenda"    	 ,'PLSP1100LEG'	, 0 , K_Incluir    }}

aCores   := {{ "BRJ->BRJ_STATUS='2'", 'BR_VERMELHO' }}
aCdCores := {{ 'BR_VERMELHO' ,'Importado' }}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama mBrowse padrao...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("BRJ")
cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '5' AND D_E_L_E_T_ = ' '"
SET FILTER TO &cPLSFiltro

oBrwBRJ := FWmBrowse():New()
oBrwBRJ:SetAlias( 'BRJ' )
oBrwBRJ:SetDescription( cCadastro ) 
oBrwBRJ:SetFilterDefault( cPLSFiltro )     

oBrwBRJ:AddLegend( "BRJ->BRJ_STATUS == '2'",	'BR_VERMELHO',	'Importado' )      

oBrwBRJ:Activate()

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ PLSED1100IM³ Autor ³              		³ Data ³ 04.10.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Importacao A1100                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSED1100IM()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aSays     := {}
LOCAL aButtons  := {}
LOCAL aRetPri   := {}
LOCAL aArea     := {}
LOCAL cCadastro := "Efetua a importacao do Layout A-1100"
LOCAL nFor
LOCAL nPos
LOCAL aNotas    := {}
LOCAL lFatal	:= .F.
LOCAL lImport	:= .F.
LOCAL lAnalisar := .F.   
LOCAL lProc     := .F.
PRIVATE cUniDes := PLSINTPAD()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregas as criticas em memoria              			                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CarregaCrit()

aCritReal := {}
aResumo   := {}
aCritNota := {}
aNotas	  := {}
aCritReal := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dados para exibicao da tela de perguntas/processamento             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aSays,"Efetua a importacao do Layout A-1100")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botoes para janela de processamento                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aButtons, { 5,.T.,{|| aCriticas := {},  CarregaCrit(), Pergunte(cPerg,.T. ) } } )
aadd(aButtons, { 1,.T.,{|| Proc2BarGauge({|| aRetPri := ProcA1100() }, cCadastro) , lProc := .T.,FechaBatch() }} )
aadd(aButtons, { 2,.T.,{|| FechaBatch() }} )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe janela de processamento                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FormBatch( cCadastro, aSays, aButtons,, 160 )

If lProc //Len(aCritReal) > 0
	
	DbSelectArea("BRJ")
	oDialog   := nil
	aArea     := GetArea()
	cCadastro := "Resumo do processamento"
	oFolder := nil
	bOK     := {|| RestArea(aArea) , nOpca :=1 , oDialog:End()}
	bCancel := {|| RestArea(aArea) , nOpca :=2 , oDialog:End()}
	oCriti01:= nil
	oCriti02:= nil
	oCriti03:= nil
	nFor	:= 1
	bBlock  := {|| }
	aBut	:= {}
	aCab01  := { {"Codigo","@C",040} , {"Critica","@C",200 } , {"Linha","@C",040 } , {"Descricao","@C",300 } }
	aCab02  := { {"Guia","@C",080} , {"Status","@C",100 },{"Alias","@C",60 }, {"Numero do Registro","99999999",60 },{"Loc.Dig/PEG/Nota","@C",100 } }
	aCab03  := { {"Guia","@C",080} , {"Critica","@C",200 } , {"Descricao","@C",150 },{"Dado","@C",100 }}
	aCab04  := { {"Tipo de Critica","@C",080},{"Numero da Guia","@C",080} , {"Matricula","@C",060}, {"Nome do Usuario","@C",080} ,{"Impresso","@C",040 } , {"Codigo do Evento","@C",040 } }
	aCritRea:= {}
	aResum  := {}
	aCritNot:= {}
	aNota	:= {}
	
	DEFINE MSDIALOG oDialog TITLE cCadastro FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()
	
	@ 030,003 FOLDER oFolder SIZE 350,185 OF oDialog PIXEL PROMPTS  OemtoAnsi("Criticas do arquivo"),OemtoAnsi("Guias geradas"),OemtoAnsi("Criticas das guias"),OemtoAnsi("Outras criticas PTU")
	
	If Len(aCritReal) > 0
		
		oCriti01 := TcBrowse():New( 20, 005, 340, 140,,,, oFolder:aDialogs[1],,,,,,,,,,,, .F.,, .T.,, .F., )
		aCritRea := aClone(aCritReal)
		For nFor := 1 To Len(aCab01)
			bBlock := "{ || aCritRea[oCriti01:nAt, "+Str(nFor,4)+"] }"
			bBlock := &bBlock
			oCriti01:AddColumn(TcColumn():New(aCab01[nFor,1],bBlock,aCab01[nFor,2],nil,nil,nil,aCab01[nFor,3],.F.,.F.,nil,nil,nil,.F.,nil))
		Next
		oCriti01:SetArray(aCritRea)
		aCritReal := {}
	Endif
	
	If Len(aResumo) > 0
		
		oCriti02 := TcBrowse():New( 012, 005, 340, 140,,,, oFolder:aDialogs[2],,,,,,,,,,,, .F.,, .T.,, .F., )
		aResum	 := aClone(aResumo)
		For nFor := 1 To Len(aCab02)
			bBlock := "{ || aResum[oCriti02:nAt, "+Str(nFor,4)+"] }"
			bBlock := &bBlock
			oCriti02:AddColumn(TcColumn():New(aCab02[nFor,1],bBlock,aCab02[nFor,2],nil,nil,nil,aCab02[nFor,3],.F.,.F.,nil,nil,nil,.F.,nil))
		Next
		oCriti02:SetArray(aResum)
		aResumo := {}
	Endif
	
	If Len(aCritNota) > 0
		
		oCriti03 := TcBrowse():New( 012, 005, 340, 140,,,, oFolder:aDialogs[3],,,,,,,,,,,, .F.,, .T.,, .F., )
		For nFor := 1 To Len(aCritNota)
			nPos := Ascan(aCriticas,{|x| x[1] == aCritNota[nFor,2]})
			If nPos > 0
				aCritNota[nFor,2] := aCritNota[nFor,2]+" - "+aCriticas[nPos,2]
			Endif
		Next
		aCritNot := aClone(aCritNota)
		For nFor := 1 To Len(aCab03)
			bBlock := "{ || aCritNot[oCriti03:nAt, "+Str(nFor,4)+"] }"
			bBlock := &bBlock
			oCriti03:AddColumn(TcColumn():New(aCab03[nFor,1],bBlock,aCab03[nFor,2],nil,nil,nil,aCab03[nFor,3],.F.,.F.,nil,nil,nil,.F.,nil))
		Next
		oCriti03:SetArray(aCritNot)
		aCritNota := {}
	Endif
	
	If Len(aNotas) > 0
		
		oCriti04 := TcBrowse():New( 012, 005, 340, 140,,,, oFolder:aDialogs[4],,,,,,,,,,,, .F.,, .T.,, .F., )
		aNota := aClone(aNotas)
		For nFor := 1 To Len(aCab04)
			bBlock := "{ || aNota[oCriti04:nAt, "+Str(nFor,4)+"] }"
			bBlock := &bBlock
			oCriti04:AddColumn(TcColumn():New(aCab04[nFor,1],bBlock,aCab04[nFor,2],nil,nil,nil,aCab04[nFor,3],.F.,.F.,nil,nil,nil,.F.,nil))
		Next
		oCriti04:SetArray(aNota)
		aNotas := {}
	Endif
	
	Aadd(aBut, {"RELATORIO",{ || ImpCriT(aCritRea,aCab01,aResum,aCab02,aCritNot,aCab03,aNota,aCab04,"Criticas","M",132) },"Imprimir"} )
	
	ACTIVATE MSDIALOG oDialog  ON INIT EnchoiceBar(oDialog,bOK,bCancel,.F.,aBut) CENTER
//Elseif Len(aCritReal)+Len(aCritReal)+Len(aResumo)+Len(aNotas) == 0  .and. (lAnalisar .or. lImport)
//	MsgInfo("Nao foram encontradas criticas no arquivo.")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina principal...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("BRJ")
cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '5' AND D_E_L_E_T_ = ' '"
SET FILTER TO &cPLSFiltro

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ProcA1100   ³ Autor ³                    ³ Data ³ 17.01.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Processamento da Importacao A700                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcA1100()

LOCAL cCodSer   := ""       
LOCAL nQtd102   := 0
LOCAL nQtd103   := 0
LOCAL nI        := 0   
LOCAL nRSeqIni  := 0 
LOCAL lImportar :=.T.
LOCAL aStruc	:= { {"CAMPO","C",300,0}}
LOCAL aIte      := {}
LOCAL aRetProc  := {}
LOCAL oTempTable
LOCAL lPLSTRTPTU := ExistBlock("PLSTRTPTU")

PRIVATE lAbortPrint := .F. // Controle para abortar (sempre como esta aqui)
PRIVATE NQTD703 := 0  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private utilizadas no PLSTRTPTU_SCS2                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aDados   := {}
PRIVATE aItens   := {}            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa as variaveis                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lImpPTU    := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mensagem ao usuario...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProcG1("Preparando importacao.")
ProcessMessage()
CarregaCrit()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca parametros...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

cLayPLS     	:= mv_par01
cArquivo    	:= AllTrim(mv_par02)

If !ProcPerImp(cLayPLS,cArquivo)
	lFatal := .t.
	lImportar:= .f.
	Return()
Endif

//--< Criação do objeto FWTemporaryTable >---
oTempTable := FWTemporaryTable():New( "Trb" )
oTemptable:SetFields( aStruc )
oTempTable:AddIndex( "INDTRB1",{ "CAMPO" } )
oTempTable:Create()

IncProcG1("Iniciando Transacao.")
ProcessMessage()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a transacao														 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se layout existe...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DE9->(DbSetOrder(1))
If ! DE9->(MsSeek(xFilial("DE9")+cLayPLS))
	AnalisaCrit("01","")
	lFileOpen := .F.
Else
	cCodLayPLS := AllTrim(DE9->DE9_VERLAY)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Regra - Testa existencia do arquivo...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! File(cArquivo)
	AnalisaCrit("01","")
	lFileOpen := .F.
Else
	IncProcG1("Abrindo arquivo de origem.")
	ProcessMessage()

	DbSelectArea("Trb")
	nFileStat := AppFromTXT(cArquivo)
	
	If nFileStat = 0 // OK
		lFileOpen := .T.
		Trb->(DbGoBottom())
		If Empty(Trb->Campo)
			Trb->(RecLock("Trb",.F.))
			Trb->(DbDelete())
			Trb->(MsUnLock())
		Endif
		Trb->(DbGoTop())
	ElseIf nFileStat = -1
		// Falha de abertura
		lFileOpen := .F.
		MsgStop("Falha na Abertura do Arquivo. Codigo do erro -1")
	elseIF nFileStat = -2
		// Falha de abertura
		lFileOpen := .F.
		MsgStop("Falha na Abertura do Arquivo. Codigo do erro -2")
	elseIF nFileStat = -3
		// Falha de abertura
		lFileOpen := .F.
		MsgStop("Falha na Abertura do Arquivo. Codigo do erro -3")
	Endif
Endif

cCodSeq := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se arquivo de importacao foi lido inicia checagem de regras...           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFileOpen
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mensagem ao usuario...                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BarGauge1Set(Trb->(RecCount()))
	IncProcG1("Preparando ambiente de processamento.")
	ProcessMessage()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta layout para matriz de apoio...                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MonLayout(cLayPLS)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Regra - Buscar em qual posicao fica o tipo de registro no layout...      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DE0->(DbSetOrder(1))
	If DE0->(MsSeek(xFilial("DE0")+cLayPLS))
		
		aRetFun    := PLSA1100GPF(AllTrim(DE0->DE0_CODREG),"TP_REG")
		_nPosITREG := aRetFun[1]
		_nPosFTREG := 3
		
		If _nPosITREG == 0 .Or. _nPosFTREG == 0
			AnalisaCrit("03","")
		Endif
		
		aRetFun   := PLSA1100GPF(AllTrim(DE0->DE0_CODREG),"NR_SEQ")
		_nPosISEQ := aRetFun[1]
		_nPosFSEQ := aRetFun[2]
		
		If _nPosISEQ == 0 .Or. _nPosFSEQ == 0
			AnalisaCrit("04","")
		Endif
	Else
		AnalisaCrit("05","")
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validar estrutura fisica do arquivo...                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ! Trb->(Eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibe mensagem de processamento...                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IncProcG1("Analisando estrutura do arquivo [ "+Subs(Trb->Campo,_nPosISEQ,_nPosFSEQ)+" ]")
		ProcessMessage()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Regras registro R101                								     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "101"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica Operadora de Destino                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ! BA0->(MsSeek(xFilial("BA0")+PLSA1100GCF("R1101","CD_UNI")))
				AnalisaCrit("15",PL5GetCo("R1101","CD_UNI"),PLSA1100GCF("R1101","CD_UNI"))
			Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Regras registro R102                								     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "102"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Regra - Testa se existe a unimed origem e destino...                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			//If PLSA1100GCF("R1102","CD_UNI_EXE") == PlsIntPad()
		    //  	AnalisaCrit("74",PL5GetCo("R1102","CD_UNI_EXE"),PLSA1100GCF("R1102","CD_UNI_EXE"))
			//EndIf      
			
    		//If PLSA1100GCF("R1102","CD_UNI_BEN") <> PlsIntPad()
			//    AnalisaCrit("73",PL5GetCo("R1102","CD_UNI_BEN"),PLSA1100GCF("R1102","CD_UNI_BEN"))
			//EndIf
			
			BA0->(DbSetOrder(1))
			If ! BA0->(MsSeek(xFilial("BA0")+PLSA1100GCF("R1102","CD_UNI_EXE")))
				AnalisaCrit("08",PL5GetCo("R1102","CD_UNI_EXE"),PLSA1100GCF("R1102","CD_UNI_EXE"))
			Endif         
			
			//BEA->(DbSetOrder(15))//BEA_FILIAL + BEA_NRTROL   
		    //If BEA->(DbSeek(xFilial("BEA")+PLSA1100GCF("R1102","NR_IDENT_E")))
			//    AnalisaCrit("75",PL5GetCo("R1102","NR_IDENT_E"),PL5GetCo("R1102","NR_IDENT_E"))
			//EndIf
			nQtd102 ++     
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Regras registro R103                								     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "103"
			nQtd103 ++
			lDiaria   := .F.
			nRecno    := Trb->(Recno())
			BR8->(DbSetOrder(3))
			cCodSer := alltrim(PLSA1100GCF("R1103","CD_SERVICO"))
			If BR8->(MsSeek(xFilial("BR8")+cCodSer)) .and. BR8->BR8_TPPROC == '4'
				lDiaria := .T.
			Endif 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Regra - Quantidade total de registros								     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "109"
			If val(PLSA1100GCF("R1109","QT_TOTR102")) != nQtd102
				AnalisaCrit("33","Quantidade no campo QT_TOTR102 ["+PLSA1100GCF("R1109","QT_TOTR1102")+"], quantidade no arquivo ["+STRZERO(nQtd102 ,5)+"]")
			Endif
			If val(PLSA1100GCF("R1109","QT_TOTR103")) != nQtd103
				AnalisaCrit("34","Quantidade no campo QT_TOTR703 ["+PLSA1100GCF("R709","QT_TOTR703")+"], quantidade no arquivo ["+STRZERO(nQtd703 ,5)+"]")
			Endif
		Endif
		
		Trb->(DbSkip())
		nRSeqIni ++
		nLine ++
	Enddo
	IncProcG1("Analise finalizada com sucesso.")
	Trb->(DbGoTop())
	aRecnosGer := {}
	BarGauge2Set(nRSeqIni)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ INICIO DO PROCESSAMENTO... Somente se tudo foi validado [lImpPTU]        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lImpPTU .And. lImportar
		lOK := .T.
		nTot := 0
		While ! Trb->(Eof())
			IncProcG2("	["+AllTrim(Str(nTot))+" ] De [ "+AllTrim(Str(nRSeqIni))+" ] "+AllTrim(Str((nTot*100)/nRSeqIni,3))+"% Concluido ")
			
			ProcessMessage()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ R1101 - HEADER                                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "101"
				nTot++
				Trb->(DbSkip())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ R1102 - DADOS DO PEDIDO                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "102"
				
				nTot++
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se aDados preenchido, gera a guia                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If len (aDados) > 0
					If lPLSTRTPTU
         				aRet := ExecBlock("PLSTRTPTU",.F.,.F.)
         				If ValType(aRet) <> 'U' .And. len(aRet) > 0
         				    aRetProc:=aRet[1]
         				    aadd(aResumo,{aRetProc[1][1],aRetProc[1][2],/*cAliasPLS*/,/*Recno()*/,""})
         				EndIf
				    EndIf
				    
				    aDados := {}
				    aItens := {} 
				    aIte   := {}    
				    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicia novo registro R102                                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				    cUniOri		:= PLSA1100GCF("R1102","CD_UNI_EXE")
					cDataPro	:= PLSA1100GCF("R1102","DT_SOLICIT")
                    
  					aDadUsr := {}	  
  					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta aDados                                                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			   		If cUniOri <> PlsIntPad()
						BA1->(DbSetOrder(2))
						IF BA1->(!DbSeek(xFilial("BA1")+PLSA1100GCF("R1102","CD_UNI_BEN")+PLSA1100GCF("R1102","ID_BENEF")))
							AnalisaCrit("72",PLSA1100GCF("R1102","CD_UNI_BEN")+PLSA1100GCF("R1102","ID_BENEF"))            
						Else
	                	    aDadUsr  := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),'1',.F.,dDatabase,,,)
						Endif   
				    
				   		Aadd(aDados,{"CD_TRANS","00600"})
						Aadd(aDados,{"TP_CLIENTE","A1100"})
						Aadd(aDados,{"CD_UNI_ORI",cUniOri})  
						Aadd(aDados,{"NR_IDENT_O",PLSA1100GCF("R1102","NR_IDENT_E")})    
						Aadd(aDados,{"NR_IDENT_D",PLSA1100GCF("R1102","NR_IDENT_B")})      
						Aadd(aDados,{"CD_UNI",PlsIntPad()/*cUniOri*/})
						Aadd(aDados,{"ID_BENEF",PLSA1100GCF("R1102","ID_BENEF")})  
					    If len(aDadUsr) > 0
					    	Aadd(aDados,{"NR_VIA_CAR",cValToChar(aDadUsr[53])}) 
					    EndIf 
					EndIf    
				Else
					cUniOri		:= PLSA1100GCF("R1102","CD_UNI_EXE")
					cDataPro	:= PLSA1100GCF("R1102","DT_SOLICIT")
                    
     				aDadUsr := {}
					BA1->(DbSetOrder(2))
					IF BA1->(!DbSeek(xFilial("BA1")+PLSA1100GCF("R1102","CD_UNI_BEN")+PLSA1100GCF("R1102","ID_BENEF")))
						AnalisaCrit("72",PLSA1100GCF("R1102","CD_UNI_BEN")+PLSA1100GCF("R1102","ID_BENEF"))            
					Else
                	    aDadUsr  := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),'1',.F.,dDatabase,,,)
					Endif   
				    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta aDados                                                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			   		If cUniOri <> PlsIntPad()
				   		Aadd(aDados,{"CD_TRANS","00600"})
						Aadd(aDados,{"TP_CLIENTE","A1100"})
						Aadd(aDados,{"CD_UNI_ORI",cUniOri})  
						Aadd(aDados,{"NR_IDENT_O",PLSA1100GCF("R1102","NR_IDENT_E")})    
						Aadd(aDados,{"NR_IDENT_D",PLSA1100GCF("R1102","NR_IDENT_B")})      
						Aadd(aDados,{"CD_UNI",PlsIntPad()/*cUniOri*/})
						Aadd(aDados,{"ID_BENEF",PLSA1100GCF("R1102","ID_BENEF")})  
						Aadd(aDados,{"DT_ATENDIM",cDataPro})  
					    If len(aDadUsr) > 0
					    	Aadd(aDados,{"NR_VIA_CAR",cValToChar(aDadUsr[53])})
					    EndIf
					EndIf    	
				EndIf 
					
				Trb->(DbSkip())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ R103 - ITENS                                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "103"  
			    If cUniOri <> PlsIntPad()
				    aIte := {}
					Aadd(aIte,{"TP_TABELA",PLSA1100GCF("R1103","TP_TABELA")})
				    Aadd(aIte,{"CD_SERVICO",PLSA1100GCF("R1103","CD_SERVICO")})
	                Aadd(aIte,{"QT_SERVICO",PLSA1100GCF("R1103","QT_AUTORIZ")})  
	                Aadd(aIte,{"DS_OPME",""})//PLSA1100GCF("R1103","DS_SERVICO")
	                Aadd(aIte,{"VL_SERVICO","00000000000000"}) 
	                Aadd(aIte,{"ID_RESPWSD",PLSA1100GCF("R1103","ID_RESP_WS")}) 
	                Aadd(aIte,{"CD_MENS_ER",PLSA1100GCF("R1103","CD_MENS_ER")})
					Aadd(aIte,{"SQ_ITEM",PLSA1100GCF("R1103","SQ_ITEM")})
					
					Aadd(aItens,aIte)  
				EndIf	
		        Trb->(DbSkip())
			  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ R109 - TRAILER                                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "109"  
		    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se aDados preenchido, gera a guia                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    	If len (aDados) > 0
					If lPLSTRTPTU
         				aRet := ExecBlock("PLSTRTPTU",.F.,.F.) 
         				If ValType(aRet) <> 'U' .And. len(aRet) > 0
         				    aRetProc:=aRet[1]
         				    aadd(aResumo,{aRetProc[1][1],aRetProc[1][2],/*cAliasPLS*/,/*Recno()*/,""})
         				EndIf
         			EndIf	
			    EndIf
				    
			    aDados := {}
			    aItens := {}        
				Exit
			Endif
		Enddo  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria Registro na tabela BRJ                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CriaBRJ()
       	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Marca BD6s com codigo da importacao                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		For nI := 1 to len(aResumo)
	    	BEA->(DbSetOrder(1))//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
	    	If BEA->(DbSeek(xFilial("BEA")+aResumo[nI][1]))
	    		BD6->(DbSetOrder(1))//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
	    	    If BD6->(DbSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA->BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV))) 
	    	        While BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_CODLDP+BEA->BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV) == BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) .And. !BD6->(Eof())
	    	            BD6->(RecLock("BD6",.F.))
	    	            BD6->BD6_SEQIMP := BRJ->BRJ_CODIGO   
	    	            BD6->(MsUnLock())
	    	            
	    	        	BD6->(DbSkip())
	    	        EndDo
	    	    EndIf 
	    	EndIf	
        Next
	Else
		If lImportar
			MsgStop("O arquivo nao foi importado devido a criticas fatais.")
		Endif
		
		lFatal := .T.
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a transacao												     |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
End Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha o arquivo de trabalho...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if( select( "Trb" ) > 0 )
	oTempTable:Delete()
endIf

Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³PLSA1100GCF ³ Autor ³ Daher       		³ Data ³ 17.01.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Retorna um determinado dado a partir do layout/arq. de trab.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSA1100GCF(cTipReg,cDado,cSeq)
LOCAL nPos
LOCAL cRet   := ""
DEFAULT cSeq := ""

nPos := Ascan( a1100Pos , {  | x | x[1] == cTipReg .And. (x[2] == cDado .or. alltrim(x[6]) == alltrim(cSeq)) } )
If nPos > 0
	cRet := Subs(Trb->Campo,a1100Pos[nPos,3],(a1100Pos[nPos,4]-a1100Pos[nPos,3])+1)
Else
	AnalisaCrit("43","Campo "+cDado+" Tipo de Registro "+cTipReg)
Endif

Return(cRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ PL5GetCo   ³ Autor ³ Daher		        ³ Data ³ 17.01.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Retorna o intervalo de colunas 								³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PL5GetCo(cTipReg,cDado)
LOCAL nPos
LOCAL cRet := ""

nPos := Ascan( a1100Pos , {  | x | x[1] == cTipReg .And. x[2] == cDado } )
If nPos > 0
	cRet := "Posicao no arquivo ["+alltrim(str(a1100Pos[nPos,3])) + "] -> [" + alltrim(str(a1100Pos[nPos,4]))+"] "
else
	cRet := "ERRO"
Endif

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ MonLayout  ³ Autor ³            		³ Data ³ 10.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Monta matriz de apoio com todos os layouts do respectivo EDI³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MonLayout(cLayPLS)

DE1->(DbSetOrder(1))
If DE1->(MsSeek(xFilial("DE1")+cLayPLS))
	While ! DE1->(Eof()) .And. DE1->DE1_FILIAL == xFilial("DE1") .And. DE1->DE1_CODLAY == cLayPLS
		aadd(a1100Pos,{AllTrim(DE1->DE1_CODREG),AllTrim(DE1->DE1_CAMPO),Val(DE1->DE1_POSINI),Val(DE1->DE1_POSFIM), Val(DE1->DE1_POSFIM)-Val(DE1->DE1_POSINI)+1,DE1->DE1_SEQUEN})
		DE1->(DbSkip())
	Enddo
Endif

Return 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ AnalisaPEG ³ Autor ³                    ³ Data ³ 10.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Cria registro na tabela BRJ                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriaBRJ()
	nHBRJ := PLSAbreSem("PLSBRJ.SMF")
	BRJ->(RecLock("BRJ",.T.))
	BRJ->BRJ_FILIAL := xFilial("BRJ")
	BRJ->BRJ_CODIGO := GetSx8Num("BRJ","BRJ_CODIGO")
	BRJ->BRJ_DATA   := dDataBase
	BRJ->BRJ_REGPRI := "5"
	BRJ->BRJ_CODOPE := ""//BCI->BCI_CODOPE
	BRJ->BRJ_CODLDP := ""//BCI->BCI_CODLDP
	BRJ->BRJ_CODPEG := ""//BCI->BCI_CODPEG
	BRJ->BRJ_ARQUIV := cArquivo
	BRJ->BRJ_OPEORI := GETNEWPAR("MV_PLOPEMO","0999")
	BRJ->BRJ_NOMORI := BA0->(Posicione("BA0",1,xFilial("BA0")+Alltrim(GETNEWPAR("MV_PLOPEMO","0999")),"BA0_NOMINT")) //BA0->(Posicione("BA0",1,xFilial("BA0")+cUniOri,"BA0_NOMINT"))
	BRJ->BRJ_ANO    := ""
	BRJ->BRJ_TPPAG  := CriaVar("BRJ_TPPAG")
	BRJ->BRJ_ANOPAG := ""
	BRJ->BRJ_MESPAG := ""//Subs(cAMPAG,5,2)
	BRJ->BRJ_MES 	:= ""//Subs(cAMPAG,5,2)
	BRJ->BRJ_STATUS := "1"
	BRJ->BRJ_CAMCOM := PLSRTCCOMP(BRJ->BRJ_OPEORI)
	
	BRJ->(MsUnLock())
	BRJ->(ConfirmSX8())
	nRecBRJ    := BRJ->(Recno())
	cCodSeq    := BRJ->BRJ_CODIGO
	PLSFechaSem(nHBRJ,"PLSBRJ.SMF")  
	
Return	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³PLSED1100   ³ Autor ³                    ³ Data ³ 07.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ 			Consulta da importação							³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|			  | 															|±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSED1100
PLSED1100GN("1",.T.)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³PLSED1100N  ³ Autor ³                    ³ Data ³ 24.01.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³Trata a exclusão de uma importacao							³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|			  |Daher	   | Alteracoes diversas							|±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSED1100CN
LOCAL aRet
LOCAL lOK
LOCAL aDados
LOCAL nFor
LOCAL nI        := 0
LOCAL aBD6Clear := {}
LOCAL cChave    := BRJ->BRJ_CODIGO
LOCAL cSql 		:= ""

If BRJ->BRJ_STATUS == "2"
	MsgInfo("Esta importacao nao podera ser excluido porque ja foi paga.")
	Return
Endif

cSql := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("BD6")
cSql += " WHERE BD6_FILIAL = '"+xFilial("BD6")+"' AND"
cSql += " BD6_SEQIMP = '"+cChave+"' AND "
cSql += " (BD6_NUMSE1 <> ' ' OR  BD6_NUMTIT <> ' ' OR BD6_PREFIX <> ' ' OR BD6_TIPTIT <> ' ') AND "
cSql += " D_E_L_E_T_ = ' '"
PLSQuery(cSql,"Trb")
If Trb->TOTAL > 0
	Trb->(DbCloseArea())
	MsgInfo("Não será possível a exclusão. Existem guias nesta importação que já foram cobradas.")
	Return
Endif
Trb->(DbCloseArea())

aRet   := PLSED1100GN("2",.T.)
lOK    := aRet[1]
aDados := aRet[2]
 
If lOK
	Begin Transaction
	
	/*For nFor := 1 To Len(aDados)
		BCI->(DbSetOrder(1))
		If BCI->(MsSeek(xFilial("BCI")+aDados[nFor,1]+aDados[nFor,2]+aDados[nFor,3]))
			PLSEXCPEG()
		Endif
	Next*/
	
	DbSelectArea("BRJ")
	SET FILTER TO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa registro na BRJ                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	BRJ->(DbSetOrder(1))
	While BRJ->(DbSeek(xFilial("BRJ")+cChave))
		BRJ->(RecLock("BRJ",.F.))
		BRJ->(DbDelete())
		BRJ->(MsUnLock())
	Enddo      
	
	BEA->(DbSetOrder(1))//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO  
	BEG->(DbSetOrder(1))//BEG_FILIAL + BEG_OPEMOV + BEG_ANOAUT + BEG_MESAUT + BEG_NUMAUT + BEG_SEQUEN
	BE2->(DbSetOrder(1))//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
	BD5->(DbSetOrder(1))//BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_SITUAC + BD5_FASE   
	BD6->(DbSetOrder(1))//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
	BD7->(DbSetOrder(1))//BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC
	BDX->(DbSetOrder(1))//BDX_FILIAL + BDX_CODOPE + BDX_CODLDP + BDX_CODPEG + BDX_NUMERO + BDX_ORIMOV + BDX_CODPAD + BDX_CODPRO + BDX_SEQUEN + BDX_CODGLO
	B0S->(DbSetOrder(1))//B0S_FILIAL + B0S_NUMSEQ + B0S_TIPTRA + B0S_OPESOL + B0S_ENVREC
	B0T->(DbSetOrder(1))//B0T_FILIAL + B0T_NUMSEQ + B0T_TIPTRA + B0T_OPESOL + B0T_IDENT+B0T_VARIAV   
	BSA->(DbSetOrder(1))//BSA_FILIAL + BSA_NUMSEQ + BSA_IDENT
	BE4->(DbSetOrder(1))//BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
	BEJ->(DbSetOrder(1))//BEJ_FILIAL + BEJ_CODOPE + BEJ_ANOINT + BEJ_MESINT + BEJ_NUMINT + BEJ_SEQUEN      
	BEL->(DbSetOrder(1))//BEL_FILIAL + BEL_CODOPE + BEL_ANOINT + BEL_MESINT + BEL_NUMINT + BEL_SEQUEN + BEL_CODGLO
					
	For nFor := 1 to len(aRet[2])
		            
	    If BEA->(DbSeek(aRet[2][nFor][1]))  
	       
			If B0S->(DbSeek(xFilial("B0S")+Substr(BEA->BEA_NRTROL,1,10)+"00600"+BEA->BEA_OPEINT)) 
	            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   		//³ Limpa registros na B0T                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
				If B0T->(DbSeek(xFilial("B0S")+Substr(BEA->BEA_NRTROL,1,10)+"00600"+BEA->BEA_OPEINT)) 
					While B0S->(B0S_FILIAL+B0S_NUMSEQ+B0S_TIPTRA+B0S_OPESOL) == xFilial("B0T")+B0T->(B0T_NUMSEQ+B0T_TIPTRA+B0T_OPESOL) .And. !B0T->(Eof())
						B0T->(RecLock("B0T",.F.))
	   			   		B0T->(DbDelete())
						B0T->(MsUnLock())
						
						B0T->(DbSkip())
					EndDo  
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Limpa registros na B0S                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
					B0S->(RecLock("B0S",.F.))
	   			   	B0S->(DbDelete())
					B0S->(MsUnLock())
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Limpa registros na BSA                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	            If BSA->(DbSeek(xFilial("BSA")+BEA->BEA_NRTROL))  
	            	While BEA->(BEA_FILIAL+BEA_NRTROL) == xFilial("BSA")+BSA->BSA_NUMSEQ .And. !BSA->(Eof())
	            		BSA->(RecLock("BSA",.F.))
	   			   		BSA->(DbDelete())
						BSA->(MsUnLock())	
						
						BSA->(DbSkip())
	            	EndDo
	            EndIf
			EndIf
	        
	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Guias SADT                                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	        If BEA->BEA_TIPGUI $ "01/02"
	            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Limpa registros na BD5                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	        	If BD5->(DbSeek(xFilial("BD5")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))    
	            	BD5->(RecLock("BD5",.F.))
	   				BD5->(DbDelete())
					BD5->(MsUnLock())
	        	EndIf  
	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Guias Internacao                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  	
	        ElseIf BEA->BEA_TIPGUI == "03"
	           
	            If BE4->(DbSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))	 
	            
	                If BEJ->(DbSeek(xFilial("BEJ")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT))) 
	                    
	                    While BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) == xFilial("BEJ")+BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT) .And. !BEJ->(Eof())
	                       
				   	  		If BEL->(DbSeek(xFilial("BEL")+BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN)))
				   	  			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					 			//³ Limpa registros na BEL                                                   ³
					   	  		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
				   	  			While BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN) ==  xFilial("BEL")+BEL->(BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT+BEL_SEQUEN) .And. !BEL->(Eof())	
				   	  		    	BEL->(RecLock("BEL",.F.))
	   			   					BEL->(DbDelete())
				   		   			BEL->(MsUnLock())
				   	  		    	BEL->(DbSkip())
				   	  		    EndDo
				   	  		EndIf
				   	  		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				 			//³ Limpa registros na BEJ                                                   ³
				   	  		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	                     	BEJ->(RecLock("BEJ",.F.))
	   			   			BEJ->(DbDelete())
				   			BEJ->(MsUnLock())
	                    	BEJ->(DbSkip())
	                    EndDo
	                EndIf
	            	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Limpa registros na BE4                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	               	BE4->(RecLock("BE4",.F.))
	   				BE4->(DbDelete())
					BE4->(MsUnLock())
	        	EndIf   
            EndIf      
	        
	        If BE2->(DbSeek(xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))      
	           	While BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == xFilial("BE2")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)
	               	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Limpa registros na BEG                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	               	If BEG->( MsSeek( xFilial("BEG")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN) ) )
						While !BEG->(Eof()) .And. BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) == BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN) .And. !BEG->(Eof())
	                		BEG->(RecLock("BEG",.F.))
	   						BEG->(DbDelete())
							BEG->(MsUnLock())
						
	                    	BEG->(DbSkip())
	                    EndDo
	                EndIf
	               	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Limpa registros na BE2                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	               	BE2->(RecLock("BE2",.F.))
	   		   		BE2->(DbDelete())
					BE2->(MsUnLock())
	               
	               	BE2->(DbSkip())
	            EndDo
	        EndIf   
	       
	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Limpa registros na BD6                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	        If BD6->(DbSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))  
                While BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI) == xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) .And. !BD6->(Eof())
                	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Limpa registros na BD7                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))   
						While BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) == xFilial("BD7")+BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) .And. !BD7->(Eof())
					    	BD7->(RecLock("BD7",.F.))
	   			   			BD7->(DbDelete())
							BD7->(MsUnLock())
					    	
					    	BD7->(DbSkip())
					    EndDo
					EndIf   
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Limpa registros na BDX                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If BDX->(MsSeek(xFilial("BDX")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO)))
						BDX->(RecLock("BDX",.F.))
						BDX->(dbDelete())
						BDX->(MsUnlock())
					EndIf
				
					BD6->(RecLock("BD6",.F.))
	   				BD6->(DbDelete())
					BD6->(MsUnLock())
					
					BD6->(DbSkip())
				EndDo	
            EndIf 
          	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Limpa registro BEA                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           	BEA->(RecLock("BEA",.F.))
	   		BEA->(DbDelete())
			BEA->(MsUnLock())
						
	    EndIf
	Next

	End Transaction
	
	DbSelectArea("BRJ")
	cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '5' AND D_E_L_E_T_ = ' '"
	SET FILTER TO &cPLSFiltro
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSP1100LEG³ Autor ³ Daher     		    ³ Data ³ 05.05.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe a legenda...                                         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSP1100LEG()

BrwLegenda(cCadastro,"Status" ,aCdCores)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ AnalisaCrit³ Autor ³ Tulio	              ³ Data ³ 05.05.0³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ 										                      ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function AnalisaCrit(cCodigo,cDado,cDadoAux,cTipo,cLote,cNota)
LOCAL nPos
LOCAL lFlag := .T.
LOCAL cCritica
DEFAULT cDadoAux := ""
DEFAULT cTipo    := "1"

nPos := Ascan(aCriticas,{|x| x[1] == cCodigo})

If nPos > 0
	If Empty(cDadoAux)
		cCritica := aCriticas[nPos,2]
	Else
		cCritica := AllTrim(aCriticas[nPos,2])+"   ["+AllTrim(cDadoAux)+"]"
	Endif
	
	If cTipo == "1"
		aadd(aCritReal,{aCriticas[nPos,1],cCritica,alltrim(str(nLine)),cDado})
	Elseif cTipo == "2"
		aadd(aGuiaNaoExi,{aCriticas[nPos,1],cCritica,cLote,cNota,cDado })
	Endif
	
	lFlag := aCriticas[nPos,3]=="1"
Else
	If cTipo == "1"
		aadd(aCritReal,{cCodigo,"Codigo da Critica nao localizado",alltrim(str(nLine)),cDado})
	Elseif cTipo == "2"
		aadd(aGuiaNaoExi,{cCodigo,"Codigo da Critica nao localizado",cLote,cNota,"","","","" })
	Endif
	
	lFlag := .F.
Endif

If ! lFlag .And. lImpPTU
	lImpPTU := .F.
Endif

Return(lFlag)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSLSC1100  ³ Autor ³ Daher       ³ Data ³ 01.06.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ F3 da listagem das criticas do ptu 1100                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ F3 BYP                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao do mBrowse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSLAR1100(cArqImp)
LOCAL cSalvo := cArqImp

cArqImp := cGetFile("*.*","Selecione o Arquivo",0,"SERVIDOR\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

If Empty(cArqImp)
	cArqImp := cSalvo
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ appfromtxt ³ Autor ³ SP                ³ Data ³ 01.06.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ apend from txt que funciona no linux                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
===========================================================================
Função de Importação de TXT para alias exclusivo TRB
Identifica linhas com CRLF e apenas LF ( formatos windows e Linux )
=========================================================================== /*/
Static Function AppFromTXT(cTXTFile)
Local nH , nTam , nBuff , cBuff , cTXTBuff := ""
nH := fopen(cTXTFile)
if nH == -1
	Return -1 // Falha de abertura
Endif
nTam := fseek(nH,0,2)
fseek(nH,0)
If nTam <= 0
	fclose(nH)
	Return -2 // Tamanho do arquivo invalido
Endif
While nTam > 0 .or. !empty(cTXTBuff)
	
	If len(cTXTBuff) < 10000 .and. nTam > 0
		// Mantem um buffer minimo de 10K do arquivo em memória
		nBuff := min(10000,nTam)
		cBuff := space(nBuff)
		nRead := fread(nH,@cBuff,nBuff)
		If nRead<>nBuff
			fclose(nH)
			Return -3 // Falha de Leitura
		Endif
		cTXTBuff += left(cBuff,nBuff)
		nTam := nTam - nBuff
	Endif
	
	// Identifica linhas do arquivo com CRLF e LF
	nPos := at(chr(10),cTXTBuff)
	If nPos > 0
		IF substr(cTXTBuff,nPos-1,1) == chr(13)
			cLine := substr(cTXTBuff,1,nPos-2)
		Else
			cLine := substr(cTXTBuff,1,nPos-1)
		Endif
		cTXTBuff := substr(cTXTBuff,nPos+1)
		
		// Alimenta campo com a linha
		TRB->(dbappend(.T.))
		TRB->CAMPO := cLine
		
	Else
		
		cLine := cTXTBuff
		cTXTBuff := ''
		
		If !empty(cLine)
			// Alimenta campo com a ultima linha
			// Apenas se tiver conteudo
			Trb->(dbappend(.T.))
			Trb->CAMPO := cLine
		Endif
		
	Endif
	
Enddo

fclose(nH)

// Reposiciona no topo a tabela
TRB->(dbCommit())
Trb->(DbGoTop())

Return 0 // Append Ok

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ CarregaCrit³ Autor ³ Tulio		        ³ Data ³ 17.01.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Carrega criticas padroes				                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CarregaCrit()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| ATENCAO !!! nao excluir nenhum destes aadd e sempre que for adicionar, adiciona-los ao final da funca|
//| ATENCAO !!! nao excluir nenhum destes aadd e sempre que for adicionar, adiciona-los ao final da funca|
//| ATENCAO !!! nao excluir nenhum destes aadd e sempre que for adicionar, adiciona-los ao final da funca|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aCriticas,{"01","Arquivo de importacao nao encontrado.","0"})
aadd(aCriticas,{"02","Nao foi possivel criar usuario generico.","0"})
aadd(aCriticas,{"03","Falha ao buscar posicao do tipo de registro.","0"})
aadd(aCriticas,{"04","Falha ao buscar posicao do numero sequencial.","0"})
aadd(aCriticas,{"05","Nao encontrado nenhum tipo de registro para o layout informado.","0"})
aadd(aCriticas,{"06","Layout definido na operadora origem nao disponivel para utilizacao.","0"})
aadd(aCriticas,{"07","Sequencia invalida para o campo NR_SEQ.","1"})
aadd(aCriticas,{"08","Operadora Prestadora nao encontrada.","0"})
aadd(aCriticas,{"09","Operadora Prestadora cadastrada como RDA nao encontrada.","0"})
aadd(aCriticas,{"10","Operadora Prestadora cadastrada como RDA invalida.","0"})
aadd(aCriticas,{"11","Data de geracao invalida.","1"})
aadd(aCriticas,{"12","Numero da competencia invalido.", "1"})
aadd(aCriticas,{"13","Data de vencimento da fatura invalida.","1" })
aadd(aCriticas,{"14","Data de emissao da fatura invalida.","1"})
aadd(aCriticas,{"15","Operadora destino nao encontrada.","1"})
aadd(aCriticas,{"16","Numero de notas (LOTE+NOTA) repetidos em um mesmo lote.","1"})
aadd(aCriticas,{"17","Tipo de nota invalido.","1"})
aadd(aCriticas,{"18","Codigo da excecao ao atendimento invalido.","1"})
aadd(aCriticas,{"19","Codigo de tipo de consulta invalido.","1"})
aadd(aCriticas,{"20","Codigo de indicador do atendimento em ambulatorio invalido.","1"})
aadd(aCriticas,{"21","Codigo do tipo de paciente nao encontrado no cadastro de tipos de pacientes.","1"})
aadd(aCriticas,{"22","Chave (LOTE+NOTA) do registro 702 diferente do registro 703.","1"})
aadd(aCriticas,{"23","Numero de notas (LOTE+NOTA) repetidos em um mesmo lote.","1"})
aadd(aCriticas,{"24","Codigo do tipo de admissao nao encontrado no cadastro de tipos de admissao.","1"})
aadd(aCriticas,{"26","Chave (LOTE+NOTA) do registro 702 diferente do registro 704.","1"})
aadd(aCriticas,{"27","Data do servico invalida.","1"})
aadd(aCriticas,{"28","Nao foi possivel localizar o tipo de nascimento na tabela de tipos de nascimento.","1"})
aadd(aCriticas,{"29","Codigo do PTU nao localizado na tabela de vias de acesso.","1"})
aadd(aCriticas,{"31","Tipo de pessoa informado invalido.","1"})
aadd(aCriticas,{"32","Numero de notas (LOTE+NOTA) repetidos em um mesmo lote.","1"})
aadd(aCriticas,{"33","Quantidade de registros do tipo 702 invalida.","1"})
aadd(aCriticas,{"34","Quantidade de registros do tipo 703 invalida.","1"})
aadd(aCriticas,{"35","Quantidade de registros do tipo 704 invalida.","1"})
aadd(aCriticas,{"36","Quantidade de registros do tipo 705 invalida.","1"})
aadd(aCriticas,{"37","Quantidade de registros, com excecao diferente de zero, invalida.","1"})
aadd(aCriticas,{"38","Quantidade de registros de ambulatorio invalida.","1"})
aadd(aCriticas,{"39","Quantidade total de servicos cobrados invalida.","1"})
aadd(aCriticas,{"40","Valor total de servicos [VL_TOT_SER] nos registros do tipo 704 invalido.","1"})
aadd(aCriticas,{"41","Valor total da fatura (HEADER), nao corresponde ao somatorio dos valores.","1"})
aadd(aCriticas,{"43","Campo do tipo de registro nao encontrado no layout.","1"})
aadd(aCriticas,{"44","Campo do tipo de registro nao encontrado no layout.","1"})
aadd(aCriticas,{"45","Codigo do servico nao encontrado.","1"})
aadd(aCriticas,{"46","Nota pre-autorizada sem eventos autorizados encontratos.","0"})
aadd(aCriticas,{"47","Campo data de internacao x data de alta invalido na guia de internacao.","1"})
aadd(aCriticas,{"48","Codigo de procedimento existente porem sem unidade definida na tde.","1"})
aadd(aCriticas,{"49","Para a conversao de CBHPM para AMB deve ser informado o parametro 'Tp.Tab. CBHPM' corretamente.","0"})
aadd(aCriticas,{"50","Codigo de procedimento generico nao localizado na tabela padrao.","0"})
aadd(aCriticas,{"51","Arquivo de importacao informado ja importado com a sequencia de importacao informada.","0"})
aadd(aCriticas,{"52","Valor total apresentado pela unimed diferente do total importado.","0"})
aadd(aCriticas,{"53","Guia do arquivo PTU nao encontrada como importada.","0"})
aadd(aCriticas,{"54","Nao localizado nro. do imp. no arquivo, verif. a regra de gravacao do impresso.","0"})
aadd(aCriticas,{"55","Nao localizado nro. do imp. no sistema, verif. a regra de gravacao do impresso.","0"})
aadd(aCriticas,{"56","Nao existe registro 704 para o registro 702 no arquivo informado.","1"})
aadd(aCriticas,{"57","Valor importado no campo BD7_VLRAPR diferente do total da fatura.","1"})
aadd(aCriticas,{"58","Quantidade de valores apresentados no registro 704 maior que a composicao do procedimento.","1"})
aadd(aCriticas,{"59","Preenchimento do campo TP_OBSTETRICIA obrigatorio para a nota informada.","1"})
aadd(aCriticas,{"60","Ao menos um dos campos das sequencias 017 a 021 devem ser preenchidos.","1"})
aadd(aCriticas,{"61","Preenchimento do campo TP_SAIDA_CONS_SADT obrigatorio para guias de servico.","1"})
aadd(aCriticas,{"62","Incompatibilidade entre participacoes enviadas e a participacao do procedimento.","1"})
aadd(aCriticas,{"63","Informado registro do tipo 703 sem que existam diarias informadas no lote.","1"})
aadd(aCriticas,{"64","Domínio do caráter de atendimento inválido, para os procedimentos contidos na nota.","1"})
aadd(aCriticas,{"65","Para o tipo de atendimento 07 (SADT Internado) o número da guia principal deve ser informado.","1"})
aadd(aCriticas,{"66","Conteúdo campo tipo de admissão inválido.","1"})
aadd(aCriticas,{"67","Tipo de internação informado no regitro 703 inválido.","1"})
aadd(aCriticas,{"68","Ao menos um dos campos das seqüências 022 a 030 deverá estar sinalizado como Sim.","1"})
aadd(aCriticas,{"69","Os campos de sequência 34 a 38 deverão ser preenchidos com a quantidade de nascidos vivos.","1"})
aadd(aCriticas,{"70","O campo NR_DECLARA_OBITO deve ser informado pois o campo CD_CID_OBITO foi preenchido.","1"})
aadd(aCriticas,{"71","O campo CD_CNES_PREST deve ser informado para prestadores do tipo hospital.","1"})
aadd(aCriticas,{"72","Usuario não encontrado na base de dados de destino.","0"})
aadd(aCriticas,{"73","Operadora Origem do Beneficiario diferente da Operadora Padrão","0"})    
aadd(aCriticas,{"74","Operadora Prestadora do Atendimento igual a Operadora Padrão","0"})   
aadd(aCriticas,{"75","Número de transação ja importado","0"})

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ JaImportado³ Autor ³ Tulio		        ³ Data ³ 17.01.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Verifica se o arquivo jah foi importado                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function JaImportado(cArquivo)
LOCAL lFound     := .F.
LOCAL aDirArq    := DIRECTORY(cArquivo)
LOCAL cArqBusca  := ""
If Len(aDirArq) > 0
	cArqBusca := aDirArq[1,1]
Endif

BRJ->(DbSetOrder(1))
If BRJ->(DbSeek(xFilial("BRJ")))
	While ! BRJ->(Eof()) .And. BRJ->BRJ_FILIAL == xFilial("BRJ")
		
		If UPPER(cArqBusca) $ UPPER(BRJ->BRJ_ARQUIVO)
			lFound := .T.
			Exit
		Endif
		
		BRJ->(DbSkip())
	Enddo
Endif
Return(lFound)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ ProcPerImp ³ Autor ³ Daher		        ³ Data ³ 17.01.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Verifica se pode ocorrer a importacao                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcPerImp(cLayPLS,cArquivo)

LOCAL lRet 		:= .T.
LOCAL aRet 		:= {}

If JaImportado(cArquivo)
	CarregaCrit()
	aadd(aRet,{aCriticas[48,1],aCriticas[48,2]})
	lRet := .F.
Endif

If Len(aRet) <> 0
	PLSCRIGEN(aRet,{ {"Codigo","@C",040},{"Descricao","@C",080} }, "Falhas que impossibilitam a importacao.",NIL,NIL,NIL,NIL, NIL,NIL,"G",220)
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ImpCriT   ³ Autor ³ Daher		        ³ Data ³ 17/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime uma critica						   			      ³±±
±±³          ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpCriT(aCritRea,aCab01,aResum,aCab02,aCritNot,aCab03,aNota,aCab04,cTitulo,cTpRel,nTmRel)
LOCAL aPrints := {}
LOCAL nI := 0

If Len(aCritRea) > 0
	aadd(aPrints,{"criticas do arquivo",aCritRea,aCab01})
Endif
If Len(aResum) > 0
	aadd(aPrints,{"guias geradas",aResum,aCab02})
Endif
If Len(aCritNot) > 0
	aadd(aPrints,{"criticas das guias",aCritNot,aCab03})
Endif
If Len(aNota) > 0
	aadd(aPrints,{"outras criticas",aNota,aCab04})
Endif

For nI:=1 To Len(aPrints)
	If MsgYesNo("Imprimir "+aPrints[nI][1]+" ?")
		RImpCriT(aPrints[nI][2],aPrints[nI][3],aPrints[nI][1],cTpRel,nTmRel)
	Endif
Next

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RImpCriT  ³ Autor ³ Daher		        ³ Data ³ 17/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime uma critica						   			      ³±±
±±³          ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RImpCriT(aDados,aCabec,cTit,cTpRel,nTmRel)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis padroes para todos os relatorios...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nFor
LOCAL nFor2
LOCAL cDado
LOCAL uDado
LOCAL cPerg       := nil // Pergunta padrao (SX1) dos parametros
PRIVATE nQtdLin     := 58       // Qtd de Linhas Por Pagina
PRIVATE nLimite     := 132       // Limite de Colunas
PRIVATE cTamanho    := "M"       // P=Pequeno;M=Medio;G=Grande -> P=80;M=132;G=220 (colunas)
PRIVATE cTitulo     := cTit // Titulo do Relatorio
PRIVATE cDesc1      := cTitulo // Descritivo para o usuario
PRIVATE cDesc2      := "" // Descritivo para o usuario
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BA1" // Alias
PRIVATE cRel        := "IMPCRIGEN" // Nome do Relatorio
PRIVATE nli         := 01   // Variavel padrao para controlar numero de linha
PRIVATE nQtdini     := nli  // Variavel para controlar numero de linha inicial
PRIVATE m_pag       := 1    // Variavel padrao para contar numero da pagina
PRIVATE lCompres    := .F. // nao mude e padrao
PRIVATE lDicion     := .F. // nao mude e padrao
PRIVATE lFiltro     := .F. // Habilitar o filtro ou nao
PRIVATE lCrystal    := .F. // nao mudar controle do crystal reports
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } // padrao nao mude
PRIVATE lAbortPrint := .F. // Controle para abortar (sempre como esta aqui)
PRIVATE cCabec1     := "" // Primeira linha do cabecalho ;
PRIVATE cCabec2     := "" // utilizado pela funcao cabec...
PRIVATE nColuna     := 03 // Numero da coluna que sera impresso as colunas

DEFAULT cTpRel     := "M"
DEFAULT nTmRel     := 132

nLimite     := nTmRel
cTamanho    := cTpRel
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama SetPrint (padrao)                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRel  := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi cancelada a operacao (padrao)                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nLastKey  == 27 // Verifica o cancelamento...
	Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura impressora (padrao)                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,cAlias)

@ ++nLi, nColuna pSay "**** "+cTit+" ****"

@ ++nLi, nColuna pSay Replicate("*",nLimite-nColuna)
cDado := ""
For nFor := 1 To Len(aCabec)
	cDado += aCabec[nFor,1]+Space(10)
Next
@ ++nLi, nColuna pSay cDado
@ ++nLi, nColuna pSay Replicate("*",nLimite-nColuna)

For nFor := 1 To Len(aDados)
	cDado := ""
	For nFor2 := 1 To Len(aCabec)
		uDado := aDados[nFor,nFor2]
		If     ValType(uDado) == "C"
			cDado += uDado+Space(02)
		ElseIf ValType(uDado) == "D"
			cDado += dtoc(uDado)+Space(02)
		ElseIf ValType(uDado) == "N"
			cDado += str(uDado,17,4)+Space(02)
		Endif
	Next
	@ ++nLi, nColuna pSay cDado
Next

@ ++nLi, nColuna pSay Replicate("*",nLimite-nColuna)
@ ++nLi, nColuna pSay StrZero(Len(aDados),2)+" Registro(s) Listado(s)"
@ ++nLi, nColuna pSay Replicate("*",nLimite-nColuna)

If  aReturn[5] == 1
	Set Printer To
	Ourspool(cRel)
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ PLSA1100GPF³ Autor ³                    ³ Data ³ 10.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Retorna a posicao de um determinado campo no layout.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSA1100GPF(cTipReg,cDado)
LOCAL nPos
LOCAL nPosIni := 0
LOCAL nPosFin := 0

nPos := Ascan( a1100Pos , {  | x | x[1] == cTipReg .And. x[2] == cDado } )
If nPos > 0
	nPosIni := a1100Pos[nPos,3]
	nPosFin := a1100Pos[nPos,4]
Else
	AnalisaCrit("44","Campo "+cDado+" Tipo de Registro "+cTipReg)
Endif

Return({nPosIni,nPosFin})


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³PLSED1100GN ³ Autor ³                    ³ Data ³ 23.11.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ 															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|			  | 															|±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSED1100GN(cTipo,lMsg)
LOCAL aDados   := {}
LOCAL lRet     := .F.
LOCAL cChave   := BRJ->BRJ_CODIGO
LOCAL nRecno   := BRJ->(Recno())
LOCAL nOrdem   := BRJ->(IndexOrd())
LOCAL aGuias   := {}        

DEFAULT lMsg := .F.

BAU->(dbSetOrder(7))
BAU->(MsSeek(xFilial("BAU")+BRJ->BRJ_OPEORI))

aadd(aDados,{"Data da Importacao",dtoc(BRJ->BRJ_DATA)})
aadd(aDados,{"Arquivo de Importacao",AllTrim(BRJ->BRJ_ARQUIV)})
aadd(aDados,{"Operadora Origem",BRJ->BRJ_OPEORI+" - "+Alltrim(BRJ->BRJ_NOMORI)})
aadd(aDados,{"",""})

aadd(aDados,{"Status",X3COMBO("BRJ_STATUS",BRJ->BRJ_STATUS)})

aadd(aDados,{"",""})     
aadd(aDados,{"Guias Criadas",""})

DbSelectArea("BRJ")
BRJ->(DbClearFilter())
BRJ->(DbSetOrder(1))
BRJ->(MsSeek(xFilial("BRJ")+cChave))
While ! BRJ->(Eof()) .And. BRJ->BRJ_CODIGO == cChave   
	BD6->(DbSetOrder(14))//BD6_FILIAL+BD6_SEQIMP+BD6_INCAUT
	If BD6->(DbSeek(xFilial("BD6")+BRJ->BRJ_CODIGO))
		While xFilial("BD6")+BD6->BD6_SEQIMP == xFilial("BD6")+BRJ->BRJ_CODIGO .And. !BD6->(Eof())
			//If BD6->BD6_TIPGUI $ "01/02"
			BEA->(DbSetOrder(12))//BEA_FILIAL+BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV
				If BEA->(DbSeek(xFilial("BEA")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
			    IF Ascan(aGuias,{|x| x[1] == BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)}) = 0 
			    	aadd(aDados,{"",BEA->(BEA_OPEMOV+"."+BEA_ANOAUT+"."+BEA_MESAUT+"."+BEA_NUMAUT)})
					aadd(aGuias,{BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)})
			    EndIf
			EndIf
			//Else
			//EndIf
			BD6->(DbSkip())		
		EndDo
	Endif

	BRJ->(DbSkip())
Enddo

If Len(aDados) > 0 .And. lMsg
	lRet := PLSCRIGEN(aDados,{ {"Campo","@C",80} , {"Conteudo","@C",80 } },IF(cTipo=="1","Dados da Importacao - Arquivo "+AllTrim(cArquivo),"Confirma Cancelamento da Importacao - Arquivo "+AllTrim(cArquivo)),NIL,NIL,NIL,NIL, NIL,NIL,"G",220)[1]
Endif

DbSelectArea("BRJ")
cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '5' AND D_E_L_E_T_ = ' '"
SET FILTER TO &cPLSFiltro

BRJ->(DbGoTo(nRecno))
BRJ->(DbSetOrder(nOrdem))

Return(If(cTipo=="1",lRet,{lRet,aGuias}))