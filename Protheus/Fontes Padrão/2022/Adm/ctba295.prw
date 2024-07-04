#Include "ctba295.Ch"
#Include "PROTHEUS.Ch" 
// 17/08/2009 -- Filial com mais de 2 caracteres
// TRADUÇÃO RELEASE P10 1.2 - 21/07/08
Static lFWCodFil := FindFunction("FWCodFil")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ctba295  ³ Autor ³ Marcos S. Lobo        ³ Data ³ 06.02.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Processamento dos Lancamentos Intercompany       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ctba295(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Jose Glez  ³        ³  MMI-5346 ³Numero de póliza debe ser consecutivo³±±
±±³            ³        ³           ³por mes.                             ³±±
±±³  Marco A.  ³28/05/18³DMINA-2113 ³Se modifican funciones ProxDocItc,   ³±±
±±³            ³        ³           ³y CTA295Doc para Numero de Poliza    ³±±
±±³            ³        ³           ³Consecutivo por mes. (MEX)           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ctba295(lWf,dDataIni,dDataFim,cCodIni,cCodFim,lHP,cHP,lCorrec,lAtuSal,cLote,cMoeda,cTpSald)
Local nOpca		:= 0
Local aSays		:= {}
Local aButtons	:= {}
Local aSM0Area	:= SM0->(GetArea())
Local nTs			:= 0
Local nEmpUsed	:= 0
Local nF			:= 0


Private aFiles := {"CT2","CTF","CTG","CTO","CTP"} // Arquivos que devem ser abertos em outra empresa para o processamento
Private aXFilial	:= {}
Private cCadastro	:= STR0001  		//"Lan‡amentos Intercompany"
Private aEmpUsed	:= {}				// Empresas/Filiais utilizadas no processamento do intercompany
Private aSldUsed	:= {}

Default lWf 		:= .F.				// lWf indica se a execução é através de WorkFlow ou não
Default dDataIni	:= dDataBase		// Data Inicial dos lançamentos que serão processados
Default dDataFim	:= dDataBase		// Data Final dos lançamentos que serão processados
Default cCodIni		:= ""				// Codigo Inicial de Config. Intercompany
Default cCodFim		:= "ZZZ"			// Codigo Final de Config. Intercompany
Default lHP			:= .F.				// .T. = Usa historico padrão / .F. = Usa histórico do Lancamento
Default cHP			:= ""				// Codigo do historico padrao
Default lCorrec		:= .F.				// Se deve corrigir os lançamentos já transportados (atualizacao)
Default lAtuSal		:= .T.				// Flag para atualização de saldos
Default cLote		:= "990000"			// Lote padrão caso não seja informado
Default cMoeda		:= ""
Default cTpSald		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // Da Data                                          ³
//³ mv_par02 // At‚ a Data                                       ³
//³ mv_par03 // Config Inicial                                   ³
//³ mv_par04 // Config Final                                     ³
//³ mv_par05 // Utiliza Historico? Lancamento / Hist Padrao      ³
//³ mv_par06 // Codigo do Hist¢rico Padr„o                       ³
//³ mv_par07 // Atualiza já transportados ? 					 ³
//³ mv_par08 // Atualiza saldos      ?                           ³
//³ mv_par09 // Numero do Lote Destino ?                         ³
//³ mv_par10 // Moeda      ?        (pode usar * para todos)     ³
//³ mv_par11 // Tipo de Saldo    ?  (pode usar * para todos)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

pergunte("CTA295",.f.)

If CtbIsCube()
	aAdd(aFiles,"CT0")
	aAdd(aFiles,"CV0")
	aAdd(aFiles,"CVX")
	aAdd(aFiles,"CVY")
	aAdd(aFiles,"CVZ")
EndIf

If !lWf// Se não for WorkFlow
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra tela de aviso										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMens := OemToAnsi(STR0004)+chr(13)  //"E' melhor que os arquivos associados a"
	cMens += OemToAnsi(STR0005)+chr(13)  //"esta rotina nao  estejam  em  uso  por"
	cMens += OemToAnsi(STR0006)+chr(13)  //"outras esta‡”es."
	cMens += OemToAnsi(STR0007)+chr(13)  //"Fa‡a com que os outros usu rios saiam do"
	cMens += OemToAnsi(STR0008)+chr(13)  //"sistema."
	
	IF !MsgYesNo(cMens,OemToAnsi(STR0003))  //"ATEN€O"
		Return
	Endif
	
	AADD(aSays,OemToAnsi( STR0002 ) ) //"Este programa transporta os lançamentos InterCompany"
	
	AADD(aButtons, { 5,.T.,{|| Pergunte("CTA295",.T. ) } } )
	AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(), FechaBatch(), nOpca:=0 ) }} )
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
	FormBatch( cCadastro, aSays, aButtons )
Endif

If lWf .or. nOpca == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atribui mv_pars para as variaveis da rotina e faz validações ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lWf				/// SO ATUALIZA PELO MV_PAR CASO NAO SEJA PROCESSAMENTO POR AGENDAMENTO
		dDataIni := mv_par01				// Data Inicial dos lançamentos que serão processados
	Endif                                                                                        
	
	If Empty(dDataIni)
		If !lWf
			Help("1",,"DATAOBRIG")
		Endif
		Return
	Endif
	If !lWf				/// SO ATUALIZA PELO MV_PAR CASO NAO SEJA PROCESSAMENTO POR AGENDAMENTO
		dDataFim := mv_par02				// Data Final dos lançamentos que serão processados
	Endif
	If dDataFim < dDataIni
		If !lWf
			Help("1",,"DATA2MENOR")
		Endif
		Return
	Endif
	If !lWf				/// SO ATUALIZA PELO MV_PAR CASO NAO SEJA PROCESSAMENTO POR AGENDAMENTO
		If !Empty(mv_par03)
			cCodIni  := mv_par03				// Codigo Inicial de Config. Intercompany
		Endif
		cCodFim	 := mv_par04				// Codigo Final de Config. Intercompany
	Endif
	If cCodFim < cCodIni
		If !lWf
			Help("1",,"COD2MENOR")
		Endif
		Return
	Endif
	If !lWf				/// SO ATUALIZA PELO MV_PAR CASO NAO SEJA PROCESSAMENTO POR AGENDAMENTO
		lHP		 := If(mv_par05==1,.F.,.T.)	// .T. = Usa historico padrão / .F. = Usa histórico do Lancamento
	Endif
	If lHP									// Se usa o historico padrão
		If !lWf				/// SO ATUALIZA PELO MV_PAR CASO NAO SEJA PROCESSAMENTO POR AGENDAMENTO
			cHP	 := mv_par06				// Codigo do historico padrao
		Endif
		If Empty(cHP)					// Se o codigo do Historico Padrao estiver vazio
			If !lWf
				If MsgYesNo(STR0009,STR0003)	// Confirma com o usuário
					lHP := .F.					// Então assume do Lançamento
				Else
					Return						// ou cancela
				Endif
			Endif
		Endif
	Endif
	If !lWf				/// SO ATUALIZA PELO MV_PAR CASO NAO SEJA PROCESSAMENTO POR AGENDAMENTO
		lCorrec	 := If(mv_par07==1,.T.,.F.)	// Se deve regerar (atualizar) registros já transportados.
		lAtuSal	 := If(mv_par08==1,.T.,.F.)	// Flag para atualização de saldos
		cLote	 := If(Len(mv_par09)<6,STRZERO(val(mv_par09),6),mv_par09)
		cMoeda	 := mv_par10
		cTpSald	 := mv_par11
	Endif
	If alltrim(cMoeda) == "*"				/// SE INDICADO * CONSIDERA TODOS
		cMoeda := ""
	Endif
	If alltrim(cTpSald) == "*"				/// SE INDICADO * CONSIDERA TODOS
		cTpSald := ""
	Endif
Endif


If lWf
	/// Se for Agendamento/Processo WorkFlow nao usa regua
	cta295Proc(.T.,@aEmpUsed,@aSldUsed,dDataIni,dDataFim,cCodIni,cCodFim,lHP,cHP,lCorrec,lAtuSal,cLote,cMoeda,cTpSald)
	
	If lAtuSal 	//// SE FOR SELECIONADO PARA ATUALIZAR SALDOS = SIM
		aAdd(aFiles,"CQ0")
		aAdd(aFiles,"CQ1")
		aAdd(aFiles,"CQ2")
		aAdd(aFiles,"CQ3")
		aAdd(aFiles,"CQ4")
		aAdd(aFiles,"CQ5")
		aAdd(aFiles,"CQ6")
		aAdd(aFiles,"CQ7")	
		aAdd(aFiles,"CQ8")
		aAdd(aFiles,"CQ9")
		aAdd(aFiles,"CTC")
		
		cEmpOld := cEmpAnt
		cFilOld := cFilAnt
		
		For nEmpUsed := 1 To Len(aEmpUsed)			
			cEmpAnt := aEmpUsed[nEmpUsed][1]
			cFilAnt := aEmpUsed[nEmpUsed][2]
			If ca295Abre(aFiles,aEmpUsed[nEmpUsed][1],aEmpUsed[nEmpUsed][2],.F.,.T.,@aXFilial)
				For nTS := 1 to Len(aSldUsed)
					CTBA190(.T.,dDataIni,dDataFim,aEmpUsed[nEmpUsed][2],aEmpUsed[nEmpUsed][2],aSldUsed[nTS],.F.,"01")
				Next
				//Fecha as tabelas na empresa em questão, para não dar erro na empresa de origem (visto que a "troca" de empresa está sendo feita por redefinição de cEmpAnt e pode gerar problema nos dbSelectArea)
				ca295Abre(aFiles,aEmpUsed[nEmpUsed][1],aEmpUsed[nEmpUsed][2],.F.,.T.,@aXFilial, .T.)
			Endif
		Next
		
		cEmpAnt := cEmpOld
		cFilAnt := cFilOld
	EndIf
Else
	If nOpca == 1
		Processa({|lEnd| cta295Proc(.F.,@aEmpUsed,@aSldUsed,dDataIni,dDataFim,cCodIni,cCodFim,lHP,cHP,lCorrec,lAtuSal,cLote,cMoeda,cTpSald)},STR0001,STR0024)
		
		If lAtuSal //// SE FOR SELECIONADO PARA ATUALIZAR SALDOS = SIM
			aAdd(aFiles,"CQ0")
			aAdd(aFiles,"CQ1")
			aAdd(aFiles,"CQ2")
			aAdd(aFiles,"CQ3")
			aAdd(aFiles,"CQ4")
			aAdd(aFiles,"CQ5")
			aAdd(aFiles,"CQ6")
			aAdd(aFiles,"CQ7")	
			aAdd(aFiles,"CQ8")
			aAdd(aFiles,"CQ9")
			aAdd(aFiles,"CTC")			
	
			cEmpOld := cEmpAnt
			cFilOld := cFilAnt
			
			For nEmpUsed := 1 To Len(aEmpUsed)
				cEmpAnt := aEmpUsed[nEmpUsed][1]
				cFilAnt := aEmpUsed[nEmpUsed][2]
				If ca295Abre(aFiles,aEmpUsed[nEmpUsed][1],aEmpUsed[nEmpUsed][2],.F.,.T.,@aXFilial)
					For nTS := 1 to Len(aSldUsed)
						CTBA190(.T.,dDataIni,dDataFim,aEmpUsed[nEmpUsed][2],aEmpUsed[nEmpUsed][2],aSldUsed[nTS],.F.,"01")
					Next					
					//Fecha as tabelas na empresa em questão, para não dar erro na empresa de origem (visto que a "troca" de empresa está sendo feita por redefinição de cEmpAnt e pode gerar problema nos dbSelectArea)
					ca295Abre(aFiles,aEmpUsed[nEmpUsed][1],aEmpUsed[nEmpUsed][2],.F.,.T.,@aXFilial,.T.)
				Endif
			Next
			
			cEmpAnt := cEmpOld
			cFilAnt := cFilOld
		EndIf
	Endif
Endif

// Reabro os arquivos da empresa atual
RestArea(aSM0Area)

cEmpAnt := SM0->M0_CODIGO
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

If !ca295Abre({},SM0->M0_CODIGO,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),.F.,.F.,@aXFilial)			/// SÓ RESTAURA O SX2 ORIGINAL
	cMsg := STR0016+"SX2"+STR0017+SM0->M0_CODIGO+"/"+IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	IF !lWf
		MsgAlert(cMsg)
	Endif
	Final()
Endif
                  
If !ca295Abre(aFiles,SM0->M0_CODIGO,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),.F.,.T.,@aXFilial)
	cMsg := STR0016+STR0017+SM0->M0_CODIGO+"/"+IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )+STR0018
	IF !lWf
		MsgAlert(cMsg)
	Endif
	Return
Else	
	//Fecha as tabelas na empresa em questão, para não dar erro na empresa de origem (visto que a "troca" de empresa está sendo feita por redefinição de cEmpAnt e pode gerar problema nos dbSelectArea)
	ca295Abre(aFiles,SM0->M0_CODIGO,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),.F.,.T.,@aXFilial,.T.)
Endif

dbSelectArea("CT2")
dbSetOrder(1)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³cta295Proc ³ Autor ³ Marcos S. Lobo        ³ Data ³ 01.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa lancamentos Inter Company                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ cta295Proc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
1/*/
Static Function cta295Proc(lWf,aEmpUsed,aSldUsed,dDataIni,dDataFim,cCodIni,cCodFim,lHP,cHP,lCorrec,lAtuSal,cLote,cMoeda,cTpSald)

Local nStru
Local nMoedLC := 1
Local nMoedas := 1
Local lTemM1  := .F.
Local nRecM1  := 0
Local nRecDST := 0
Local lTpLock := .T.
Local cCT1FIM := ""
Local cCTTFIM := ""
Local cCTDFIM := ""
Local cCTHFIM := ""
Local cE05FIM := ""
Local cE06FIM := ""
Local cE07FIM := ""
Local cE08FIM := ""
Local cE09FIM := ""
Local cArqInd := ""
Local lExstCT1Ig	:= .F.
Local lExstCTTIg	:= .F.
Local lExstCTDIg	:= .F.
Local lExstCTHIg	:= .F.
Local lExstE05Ig	:= .F.
Local lExstE06Ig	:= .F.
Local lExstE07Ig	:= .F.
Local lExstE08Ig	:= .F.
Local lExstE09Ig	:= .F.
Local Nk			:= 0
Local lCT295GRV		:= ExistBlock( "CT295GRV" )  //P.E. executado antes da gravacao dos lancamentos de destino   
Local lGestao		:= Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa   
Local cModeEmp := ""
Local cModeUni := ""
Local cModeFil := ""

Private lINCLUI     := .T.
Private lDELETA		:= .F.
Private M->CV5_EMPORI := cEmpAnt
Private nIndCT2 := 0

DEFAULT lWf			:= .F.							/// INDICA SE É PROCESSAMENTO PELO WORKFLOW (.T.=SIM/.F.=NAO)
DEFAULT aEmpUsed	:= {}
DEFAULT aSldUsed	:= {}

If !Cta295Vld(lWf,@aEmpUsed,dDataIni,dDataFim,cCodIni,cCodFim,lHP,@cHP,lCorrec,lAtuSal,cMoeda,cTpSald) /// VALIDAÇÕES ANTES DO PROCESSAMENTO
	Return											/// SE NÃO ESTIVER OK... ABORTA
Endif

//// VARIAVEIS PARA O CONTROLE DE NUMERACAO DE DOCUMENTO CONTABIL (FUNCAO PROXDOC)
Private cSubLote	:= "001"
Private cDoc		:= ""
Private cLinha		:= StrZero( 1, Len(CT2->CT2_LINHA) )//"001"
Private CTF_LOCK	:= 0

If lFWCodFil .And. lGestao
	cModeEmp := FWModeAccess("CT2",1)	
	cModeUni := FWModeAccess("CT2",2)	
	cModeFil := FWModeAccess("CT2",3)
EndIf

If Alltrim(cTpSald) == "*"				/// SE INDICADO * CONSIDERA TODOS
	cTpSald := ""
Endif

If CtbUso("CV5_CT1IGU")
	lExstCT1Ig := .T.
Else
	lExstCT1Ig := .F.
EndIf

If CtbUso("CV5_CTTIGU")
	lExstCTTIg := .T.
Else
	lExstCTTIg := .F.
EndIf

If CtbUso("CV5_CTDIGU")
	lExstCTDIg := .T.
Else
	lExstCTDIg := .F.
EndIf

If CtbUso("CV5_CTHIGU")
	lExstCTHIg := .T.
Else
	lExstCTHIg := .F.
EndIf

If CV5->(FieldPos("CV5_E05IGU")) > 0 .And. CtbUso("CV5_E05IGU")
	lExstE05Ig := .T.
Else
	lExstE05Ig := .F.
EndIf

If CV5->(FieldPos("CV5_E06IGU")) > 0 .And. CtbUso("CV5_E06IGU")
	lExstE06Ig := .T.
Else
	lExstE06Ig := .F.
EndIf

If CV5->(FieldPos("CV5_E07IGU")) > 0 .And. CtbUso("CV5_E07IGU")
	lExstE07Ig := .T.
Else
	lExstE07Ig := .F.
EndIf

If CV5->(FieldPos("CV5_E08IGU")) > 0 .And. CtbUso("CV5_E08IGU")
	lExstE08Ig := .T.
Else
	lExstE08Ig := .F.
EndIf

If CV5->(FieldPos("CV5_E09IGU")) > 0 .And. CtbUso("CV5_E09IGU")
	lExstE09Ig := .T.
Else
	lExstE09Ig := .F.
EndIf

aStruDST:= CT2->(dbStruct())						/// ESTRUTURA DO ARQUIVO CT2
nLenDST := Len(aStruDST)							/// TAMANHO DA ESTRUTURA DO CT2

cEmpOri := SM0->M0_CODIGO							/// CODIGO DA EMPRESA ORIGINAL
cFilOri := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )							/// CODIGO DA FILIAL ORIGINAL

cEmpORIAtu := cEmpAnt								/// CODIGO DA EMPRESA ORIGEM ATUAL
cFilORIAtu := cFilAnt								/// CODIGO DA FILIAL ORIGEM ATUAL
cEmpDSTAtu := ""									/// CODIGO DA EMPRESA DESTINO ATUAL
cFilDSTAtu := ""									/// CODIGO DA FILIAL DESTINO ATUAL

dbSelectArea("CV5")
cFilCV5 := xFilial("CV5")
If !lWf
	ProcRegua(CV5->(RecCount()))
Endif
dbSetOrder(1)
MsSeek(cFilCV5+cCodIni,.T.)
While !CV5->(Eof()) .and. CV5->CV5_FILIAL == cFilCV5 .and. CV5->CV5_COD <= cCodFim	
	cCT1FIM := If(Empty(CV5->CV5_CT1FIM),REPLICATE("Z",Len(CV5->CV5_CT1FIM)),CV5->CV5_CT1FIM)
	cCTTFIM := If(Empty(CV5->CV5_CTTFIM),REPLICATE("Z",Len(CV5->CV5_CTTFIM)),CV5->CV5_CTTFIM)
	cCTDFIM := If(Empty(CV5->CV5_CTDFIM),REPLICATE("Z",Len(CV5->CV5_CTDFIM)),CV5->CV5_CTDFIM)
	cCTHFIM := If(Empty(CV5->CV5_CTHFIM),REPLICATE("Z",Len(CV5->CV5_CTHFIM)),CV5->CV5_CTHFIM)
	If CV5->(FieldPos("CV5_E05FIM")) > 0
		cE05FIM := If(Empty(CV5->CV5_E05FIM),REPLICATE("Z",Len(CV5->CV5_E05FIM)),CV5->CV5_E05FIM)
	EndIf
	If CV5->(FieldPos("CV5_E06FIM")) > 0
		cE06FIM := If(Empty(CV5->CV5_E06FIM),REPLICATE("Z",Len(CV5->CV5_E06FIM)),CV5->CV5_E06FIM)
	EndIf
	If CV5->(FieldPos("CV5_E07FIM")) > 0
		cE07FIM := If(Empty(CV5->CV5_E07FIM),REPLICATE("Z",Len(CV5->CV5_E07FIM)),CV5->CV5_E07FIM)
	EndIf
	If CV5->(FieldPos("CV5_E08FIM")) > 0
		cE08FIM := If(Empty(CV5->CV5_E08FIM),REPLICATE("Z",Len(CV5->CV5_E08FIM)),CV5->CV5_E08FIM)
	EndIf
	If CV5->(FieldPos("CV5_E09FIM")) > 0
		cE09FIM := If(Empty(CV5->CV5_E09FIM),REPLICATE("Z",Len(CV5->CV5_E09FIM)),CV5->CV5_E09FIM)
	EndIf
	
	If !lWf
		IncProc(STR0011+CV5->CV5_COD+" "+STR0010+" "+CV5->(CV5_EMPORI+"/"+CV5_FILORI+" -> "+CV5_EMPDES+"/"+CV5_FILDES))
	Endif
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//// ZERA AS VARIAVEIS DO WHILE PRINCIPAL (CV5)
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	If CV5->CV5_EMPORI <> cEmpORIAtu .or. CV5->CV5_FILORI <> cFilOriAtu 	/// SE A EMPRESA/FILIAL ORIGEM FOREM DIFERENTES DA ATUAL ABERTA
		cEmpORIAtu := CV5->CV5_EMPORI
		cFilORIAtu := CV5->CV5_FILORI
		cEmpAnt := CV5->CV5_EMPORI
		cFilAnt := CV5->CV5_FILORI
		If !ca295Abre(aFiles,CV5->CV5_EMPORI,CV5->CV5_FILORI,.F.,.T.,@aXFilial)		/// SE NÃO CONSEGUIU ABRIR OS ARQUIVOS
			CV5->(dbSkip())													/// TENTA O PROXIMO REGISTRO DE INTERCOMPANY
			Loop                        			
		Endif
	Endif
	
	If CV5->CV5_EMPDES <> cEmpDSTAtu .or. CV5->CV5_FILDES <> cFilDSTAtu		/// SE A EMPRESA/FILIAL DESTINO FOREM DIFERENTES DA ATUAL ABERTA
		cEmpDSTAtu := CV5->CV5_EMPDES
		cFilDSTAtu := CV5->CV5_FILDES
		
		cEmpAnt := CV5->CV5_EMPDES
		cFilAnt := CV5->CV5_FILDES
		If !ca295Abre(aFiles,CV5->CV5_EMPDES,CV5->CV5_FILDES,.T.,.T.,@aXFilial)		/// SE NÃO CONSEGUIU ABRIR OS ARQUIVOS
			CV5->(dbSkip())													/// TENTA O PROXIMO REGISTRO DE INTERCOMPANY
			Loop
		Endif                  			
		 
		If !Empty(cArqInd)
			dbSelectArea("CT2DST")
			dbClearFil()
			dbSetOrder(1)
			If File(cArqInd+OrdBagExt())
				FErase(cArqInd+OrdBagExt())
			Endif
		Endif		
		dbSelectArea("CT2DST")
		cArqInd := CriaTrab(Nil,.F.)                       
		cFiltro := "CT2DST->CT2_FILIAL == '"+xFilDST(aXFilial,"CT2")+"' .and. DTOS(CT2DST->CT2_DATA) >= '"+DTOS(dDataIni)+"' .and. DTOS(CT2DST->CT2_DATA) <= '"+DTOS(dDataFim)+"' .and. !Empty(CT2DST->CT2_IDENTC) "
		IndRegua("CT2DST",cArqInd,"CT2_FILIAL+CT2_IDENTC",,cFiltro,"Selecionando Registros...")		//"Selecionando Registros..."		
		nIndCT2 := IndexOrd()
	    dbSetOrder(nIndCT2)			
		
		If Ascan(aEmpUsed,{|x| x[1] == cEmpDSTATU .and. x[2] == cFilDSTAtu}) <= 0	 //// SE O CONJUNTO A EMPRESA ATUAL NAO ESTIVER NO ARRAY DE EMPRESAS UTILIZADAS
			aAdd(aEmpUsed,{CV5->CV5_EMPDES,CV5->CV5_FILDES})							/// ADICIONA NA LISTA DE EMPRESAS USADAS
		Endif
	Endif
	                                 
	/// ABERTOS OS ARQUIVOS ORIGEM E DESTINO VARRE O CT2 EM BUSCA DOS LANÇAMENTOS PARA CADA COMBINACAO NO INTERVALO
	dbSelectArea("CT2")
	cEmpAux := cEmpAnt
	cFilAux := cFilAnt
	cEmpAnt := cEmpORIAtu
	cFilAnt := cFilORIAtu
	If lFWCodFil .And. lGestao
		cFilORICV5 := FWxFilial( "CT2" ,CV5->CV5_FILORI,FWModeAccess("CT2",1),FWModeAccess("CT2",2),FWModeAccess("CT2",3) )	
	Else
		cFilORICV5 := xFilial("CT2",CV5->CV5_FILORI) 
	EndIf
	cEmpAnt := cEmpAux
	cFilAnt := cFilAux	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/// BUSCA A CHAVE CONTABIL DO CV5 NOS LANCAMENTOS DEBITO - LANCAMENTOS A DEBITO (TIPO 1) E PARTIDA DOBRADA
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	cKeySeek := cFilORICV5
	nOrdSeek := 2            						
	bCondMain := {|| CT2->CT2_DEBITO <= cCT1FIM }			/// CONDICAO PRINCIPAL DO WHILE
	bCondWhile := {|| CT2->CT2_DEBITO < CV5->CV5_CT1ORI .or. CT2->CT2_DEBITO	> cCT1FIM .or. CT2->CT2_CCD 	< CV5->CV5_CTTORI .or. CT2->CT2_CCD 	> cCTTFIM .or. CT2->CT2_ITEMD	< CV5->CV5_CTDORI .or. CT2->CT2_ITEMD	> cCTDFIM .or. CT2->CT2_CLVLDB < CV5->CV5_CTHORI .or. CT2->CT2_CLVLDB	> cCTHFIM }											/// CONDICAO A SER TESTADA DENTRO DO WHILE
	
	DO CASE
		CASE !EMPTY(CV5->CV5_CT1ORI)
			cKeySeek += CV5->CV5_CT1ORI
			cKeySeek += DTOS(dDataIni)
		CASE !EMPTY(CV5->CV5_CTTORI)
			nOrdSeek := 4
			cKeySeek += CV5->CV5_CTTORI
			cKeySeek += DTOS(dDataIni)
			bCondMain := {|| CT2->CT2_CCD <= cCTTFIM }			/// CONDICAO PRINCIPAL DO WHILE
			bCondWhile := {|| CT2->CT2_DEBITO < CV5->CV5_CT1ORI .or. CT2->CT2_DEBITO	> cCT1FIM .or. CT2->CT2_ITEMD	< CV5->CV5_CTDORI .or. CT2->CT2_ITEMD	> cCTDFIM .or. CT2->CT2_CLVLDB < CV5->CV5_CTHORI .or. CT2->CT2_CLVLDB	> cCTHFIM }	/// CONDICAO A SER TESTADA DENTRO DO WHILE
		CASE !EMPTY(CV5->CV5_CTDORI)
			nOrdSeek := 6
			cKeySeek += CV5->CV5_CTDORI
			cKeySeek += DTOS(dDataIni)
			bCondMain := {|| CT2->CT2_ITEMD <= cCTDFIM }		/// CONDICAO PRINCIPAL DO WHILE
			bCondWhile := {|| CT2->CT2_DEBITO < CV5->CV5_CT1ORI .or. CT2->CT2_DEBITO	> cCT1FIM .or. CT2->CT2_CCD 	< CV5->CV5_CTTORI .or. CT2->CT2_CCD 	> cCTTFIM .or. CT2->CT2_CLVLDB < CV5->CV5_CTHORI .or. CT2->CT2_CLVLDB	> cCTHFIM }	/// CONDICAO A SER TESTADA DENTRO DO WHILE
		CASE !EMPTY(CV5->CV5_CTHORI)
			nOrdSeek := 8
			cKeySeek += CV5->CV5_CTHORI
			cKeySeek += DTOS(dDataIni)
			bCondMain := {|| CT2->CT2_CLVLDB <= cCTHFIM }		/// CONDICAO PRINCIPAL DO WHILE
			bCondWhile := {|| CT2->CT2_DEBITO < CV5->CV5_CT1ORI .or. CT2->CT2_DEBITO	> cCT1FIM .or. CT2->CT2_CCD 	< CV5->CV5_CTTORI .or. CT2->CT2_CCD 	> cCTTFIM .or. CT2->CT2_ITEMD	< CV5->CV5_CTDORI .or. CT2->CT2_ITEMD	> cCTDFIM }  /// CONDICAO A SER TESTADA DENTRO DO WHILE
	ENDCASE
	
	dbSelectArea("CT2")
	CT2->(dbSetOrder(nOrdSeek))
	CT2->(MsSeek(cKeySeek,.T.))
	While !CT2->(Eof()) .and. CT2->CT2_FILIAL == cFilORICV5 .and. Eval(bCondMain)
		lINCLUI := .T.														//// INDICA SE DEVE INCLUIR/ALTERAR
		lDELETA := .F.
		lTemM1	:= .F.
		nRecM1  := 0
		nRecDST := 0
		
		If CT2->CT2_DC == "2" 												// Pula os registros de Credito 
			CT2->(dbSkip())
			Loop
		Endif  
		
		If !CT2->CT2_INTERC$"S1Y" 											//// ADICIONA SOMENTE SE O FLAG ESTIVER MARCADO E SE AINDA NÃO FOI PROCESSADO
			CT2->(dbSkip())
			Loop
		Endif
		
		If !Empty(cMoeda) .and. CT2->CT2_MOEDLC <> cMoeda					//// FILTRO DE MOEDA SE INFORMADO
			CT2->(dbSkip())
			Loop
		Endif
		
		If !Empty(cTpSald) .and. CT2->CT2_TPSALD <> cTpSald					//// FILTRO DE TIPO SE SALDO SE INFORMADO
			CT2->(dbSkip())
			Loop
		Endif
		                                                
		If CT2->CT2_DATA < dDataIni .or. CT2->CT2_DATA > dDataFim .or. Eval(bCondWhile)													/// CONDICAO DE FILTRO DAS DEMAIS ENTIDADES
			CT2->(dbSkip())
			Loop
		Endif

		If CV5->(FieldPos("CV5_E05ORI")) > 0 .And. CV5->(FieldPos("CV5_E05FIM")) > 0 .And. CT2->(FieldPos("CT2_EC05DB")) > 0
			If CT2->CT2_EC05DB < CV5->CV5_E05ORI .or. CT2->CT2_EC05DB > cE05FIM
				CT2->(dbSkip())
				Loop
			EndIf
		EndIf

		If CV5->(FieldPos("CV5_E06ORI")) > 0 .And. CV5->(FieldPos("CV5_E06FIM")) > 0 .And. CT2->(FieldPos("CT2_EC06DB")) > 0
			If CT2->CT2_EC06DB < CV5->CV5_E06ORI .or. CT2->CT2_EC06DB > cE06FIM
				CT2->(dbSkip())
				Loop
			EndIf
		EndIf

		If CV5->(FieldPos("CV5_E07ORI")) > 0 .And. CV5->(FieldPos("CV5_E07FIM")) > 0 .And. CT2->(FieldPos("CT2_EC07DB")) > 0
			If CT2->CT2_EC07DB < CV5->CV5_E07ORI .or. CT2->CT2_EC07DB > cE07FIM
				CT2->(dbSkip())
				Loop
			EndIf
		EndIf

		If CV5->(FieldPos("CV5_E08ORI")) > 0 .And. CV5->(FieldPos("CV5_E08FIM")) > 0 .And. CT2->(FieldPos("CT2_EC08DB")) > 0
			If CT2->CT2_EC08DB < CV5->CV5_E08ORI .or. CT2->CT2_EC08DB > cE08FIM
				CT2->(dbSkip())
				Loop
			EndIf
		EndIf

		If CV5->(FieldPos("CV5_E09ORI")) > 0 .And. CV5->(FieldPos("CV5_E09FIM")) > 0 .And. CT2->(FieldPos("CT2_EC09DB")) > 0
			If CT2->CT2_EC09DB < CV5->CV5_E09ORI .or. CT2->CT2_EC09DB > cE09FIM
				CT2->(dbSkip())
				Loop
			EndIf
		EndIf
		
		dbSelectArea("CT2DST")					//// SE O REGISTRO AINDA EXISTIR NA EMPRESA DESTINO
		dbSetOrder(nIndCT2)
		If MsSeek(xFilDST(aXFilial,"CT2")+CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC+CT2_SEQLAN+CT2_SEQHIS),.F.)	//// ORIGEM NO INTERCOMPANY (PARA VALIDACAO NO PROX. PROCESSAMENTO)
			If !lCorrec	.and. (!Empty(CT2DST->CT2_DEBITO) .OR. !Empty(CT2DST->CT2_CCD) .OR. !Empty(CT2DST->CT2_ITEMD) .OR. !Empty(CT2DST->CT2_CLVLDB))
				CT2->(dbSetOrder(nOrdSeek))		//// SE O PARAMETRO ATUALIZA ALTERAÇÕES ESTIVER = NAO
				CT2->(dbSkip())
				Loop                            /// O REGISTRO JÁ EXISTE ENTÃO NAO DEVE PROCESSAR				
			Else
				lINCLUI := .F.					/// SE EXISTIR E FOR CORREÇÃO NAO DEVERÁ INCLUIR E SIM ALTERAR
				If CT2->(Deleted())				/// SE ESTIVER DELETADO DEVE EXCLUIR NO DESTINO
					lDELETA := .T.
				Endif
			Endif
			nRecDST := CT2DST->(Recno())
		Else
			If CT2->(Deleted())					//// SE FOR INCLUSAO E A ORIGEM ESTIVER DELETADA
				CT2->(dbSetOrder(nOrdSeek))
				CT2->(dbSkip())
				Loop							//// PASSA PARA O PROXIMO
			Endif		
		Endif
		
		If CT2->CT2_MOEDLC <> "01"			//// SE FOR LANCAMENTO DE OUTRA MOEDA PROCURA NA MOEDA1
			If MsSeek(xFilDST(aXFilial,"CT2")+CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+"01"),.F.)
				cLote		:= CT2DST->CT2_LOTE
				cSubLote 	:= CT2DST->CT2_SBLOTE
				cDoc		:= CT2DST->CT2_DOC
				cLinha		:= CT2DST->CT2_LINHA
				lTemM1		:= .T.
				nRecM1		:= CT2DST->(Recno())
			Endif			
		Endif
               
		//////////////////////////////////////////////////////////////////////////////////////////////////////////
		//// SE TRATA-SE DE INCLUSAO OBTEM O NUMERO SEQUENCIAL DE DOCUMENTO		
		CTA295Doc(CT2->CT2_DATA,@cLote,@cSubLote,@cDoc,@lINCLUI,@CTF_LOCK)
		//////////////////////////////////////////////////////////////////////////////////////////////////////////	
		
		If Ascan(aSldUsed,CT2->CT2_TPSALD) <= 0		//// TIPO DE SALDO AINDA NAO ESTA NA LISTA DE SALDOS USADOS
			aAdd(aSldUsed,CT2->CT2_TPSALD)			//// ADICIONA NA LISTA DE SALDOS UTILIZADOS
		Endif
		
		nMoedas := Val(CT2->CT2_MOEDLC)
		
		//// OBTEM A NUMERACAO DE LINHA PARA A GRAVACAO DO LANCAMENTO DESTINO
		If lINCLUI
			cLinha := CT2->CT2_LINHA
			dbSelectArea("CTFDST")
			MsGoTo(CTF_LOCK)
			If Empty(CTFDST->CTF_LINHA)
				cLinha := StrZero( 1, Len(CT2->CT2_LINHA) ) //"001"    
			Else
				dbSelectArea("CT2DST")
				dbSetOrder(1)
				While CT2DST->(MsSeek(xFilDST(aXFilial,"CT2")+dtos(CT2->CT2_DATA)+cLote+cSubLote+cDoc+cLinha,.F.))
					cLinha := SOMA1(CTFDST->CTF_LINHA)
					RecLock("CTFDST",.F.)
					CTFDST->CTF_LINHA := cLinha
					CTFDST->(MsUnlock())
				Enddo
			Endif
			RecLock("CTFDST",.F.)
			CTFDST->CTF_LINHA := cLinha
			CTFDST->(MsUnlock())
		Endif
		
		//// EFETUA A GRAVACAO DO LANCAMENTO NO CT2 DA EMPRESA DESTINO
		For nMoedLC := 1 to nMoedas
			If lDELETA
				CT2DST->(MsGoTo(nRecDST))
				If CT2->CT2_MOEDLC <> CT2DST->CT2_MOEDLC .AND. CT2DST->CT2_VALOR <> 0			/// SE O MOVIMENTO DE OUTRA MOEDA (01) COM VALOR, NAO DEVE SER EXCLUIDO
					Loop
				Endif
				RecLock("CT2DST",.F.)
				CT2DST->(dbDelete())
			Else
				lTpLock := lINCLUI
				If CT2->CT2_MOEDLC <> "01"			/// SE FOR LANCAMENTO DE OUTRA MOEDA
					If lTemM1 .and. nMoedLC == 1  	/// VERIFICA SE A MOEDA 1 JA EXISTE
						CT2DST->(MsGoTo(nRecM1))
						cLinha := CT2DST->CT2_LINHA
						lTpLock := .F.
					ElseIf !lINCLUI 
						CT2DST->(MsGoTo(nRecDST))
					Endif
					If nMoedLC <> nMoedas .and. nMoedLC <> 1		/// SE NAO FOR A MOEDA DO LANCAMENTO E NAO FOR A MOEDA 1
						Loop										/// PASSA PARA A PROXIMA MOEDA
					Endif
				Endif
		    
				RecLock("CT2DST",lTpLock)							/// REPLICA OS DADOS ORIGEM PARA O DESTINO A DEBITO
				For nStru := 1 to nLenDST
					DO CASE
						CASE aStruDST[nStru][1] == "CT2_FILIAL"
							cConteudo := xFilDST(aXFilial,"CT2")
						CASE aStruDST[nStru][1] == "CT2_LOTE"
							cConteudo := cLote
						CASE aStruDST[nStru][1] == "CT2_SBLOTE"
							cConteudo := cSubLote
						CASE aStruDST[nStru][1] == "CT2_DOC"
							cConteudo := cDoc
						CASE aStruDST[nStru][1] == "CT2_LINHA"
							cConteudo := cLinha
						CASE aStruDST[nStru][1] == "CT2_MOEDLC"
							cConteudo := STRZERO(nMoedLC,Len(CT2->CT2_MOEDLC))
						CASE aStruDST[nStru][1] == "CT2_VALOR" .and. nMoedLC == 1 .and. nMoedas <> 1
							cConteudo := CT2DST->CT2_VALOR					/// NAO ALTERA O VALOR DESTINO NA MOEDA 1
						CASE aStruDST[nStru][1] == "CT2_DEBITO"
							If lExstCT1Ig .And. CV5->CV5_CT1IGU == "S"
								cConteudo := CT2->CT2_DEBITO							
							Else
								cConteudo := CV5->CV5_CT1DES//If(Empty(CV5->CV5_CT1DES),CT2->CT2_DEBITO,CV5->CV5_CT1DES)
							EndIf
						CASE aStruDST[nStru][1] == "CT2_CCD"
							If lExstCTTIg .And. CV5->CV5_CTTIGU == "S"
								cConteudo := CT2->CT2_CCD
							Else						
								cConteudo := CV5->CV5_CTTDES//If(Empty(CV5->CV5_CTTDES),CT2->CT2_CCD,CV5->CV5_CTTDES)
							EndIf
						CASE aStruDST[nStru][1] == "CT2_ITEMD"                                                   
							If lExstCTDIg .And. CV5->CV5_CTDIGU == "S"
								cConteudo := CT2->CT2_ITEMD
							Else												
								cConteudo := CV5->CV5_CTDDES//If(Empty(CV5->CV5_CTDDES),CT2->CT2_ITEMD,CV5->CV5_CTDDES)							
							EndIf
						CASE aStruDST[nStru][1] == "CT2_CLVLDB"                                                   
							If lExstCTHIg .And. CV5->CV5_CTHIGU == "S"
								cConteudo := CT2->CT2_CLVLDB
							Else																		
								cConteudo := CV5->CV5_CTHDES//If(Empty(CV5->CV5_CTHDES),CT2->CT2_CLVLDB,CV5->CV5_CTHDES)
							EndIf
						CASE aStruDST[nStru][1] == "CT2_EC05DB"
							If lExstE05Ig .And. CV5->CV5_E05IGU == "S"
								cConteudo := CT2->CT2_EC05DB
							Else
								cConteudo := CV5->CV5_E05DES
							EndIf
						CASE aStruDST[nStru][1] == "CT2_EC06DB"
							If lExstE06Ig .And. CV5->CV5_E06IGU == "S"
								cConteudo := CT2->CT2_EC06DB
							Else
								cConteudo := CV5->CV5_E06DES
							EndIf
						CASE aStruDST[nStru][1] == "CT2_EC07DB"
							If lExstE07Ig .And. CV5->CV5_E07IGU == "S"
								cConteudo := CT2->CT2_EC07DB
							Else
								cConteudo := CV5->CV5_E07DES
							EndIf
						CASE aStruDST[nStru][1] == "CT2_EC08DB"
							If lExstE08Ig .And. CV5->CV5_E08IGU == "S"
								cConteudo := CT2->CT2_EC08DB
							Else
								cConteudo := CV5->CV5_E08DES
							EndIf
						CASE aStruDST[nStru][1] == "CT2_EC09DB"
							If lExstE09Ig .And. CV5->CV5_E09IGU == "S"
								cConteudo := CT2->CT2_EC09DB
							Else
								cConteudo := CV5->CV5_E09DES
							EndIf
							                                  
						//// TRATAMENTO PARA OS LANCAMENTOS DE PARTIDA DOBRADA CASO A CONTRA-PARTIDA NAO ESTEJA CONFIGURADA
						CASE aStruDST[nStru][1] == "CT2_DC"
							cConteudo := If(CT2->CT2_DC$"3XP" .and. !lINCLUI,CT2->CT2_DC,"1")
						CASE aStruDST[nStru][1] == "CT2_HIST"
							cConteudo := If( lHP, cHP, &("CT2->"+aStruDST[nStru][1]) )
						CASE aStruDST[nStru][1] == "CT2_EMPORI"
							cConteudo := cEmpOriATU
						CASE aStruDST[nStru][1] == "CT2_FILORI"
							cConteudo := cFilOriATU
						CASE aStruDST[nStru][1] == "CT2_IDENTC"
							cConteudo := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+STRZERO(nMoedLC,Len(CT2->CT2_MOEDLC))+CT2_SEQLAN+CT2_SEQHIS)	//// ORIGEM NO INTERCOMPANY (PARA VALIDACAO NO PROX. PROCESSAMENTO)
						CASE aStruDST[nStru][1] == "CT2_INTERC"
							cConteudo := "2"								//// ORIGEM - INTERCOMPANY (NAO GERA PARA OUTRAS EMPRESAS)

						CASE aStruDST[nStru][1] == "CT2_CREDIT"
							cConteudo := If(CT2->CT2_DC == "1","",CT2_CREDIT)
						CASE aStruDST[nStru][1] == "CT2_CCC"
							cConteudo := If(CT2->CT2_DC == "1","",CT2_CCC)
						CASE aStruDST[nStru][1] == "CT2_ITEMC"
							cConteudo := If(CT2->CT2_DC == "1","",CT2_ITEMC)
						CASE aStruDST[nStru][1] == "CT2_CLVLCR"
							cConteudo := If(CT2->CT2_DC == "1","",CT2_CLVLCR)
						CASE aStruDST[nStru][1] == "CT2_EC05CR"
							cConteudo := If(CT2->CT2_DC == "1","",CT2_EC05CR)
						CASE aStruDST[nStru][1] == "CT2_EC06CR"
							cConteudo := If(CT2->CT2_DC == "1","",CT2_EC06CR)
						CASE aStruDST[nStru][1] == "CT2_EC07CR"
							cConteudo := If(CT2->CT2_DC == "1","",CT2_EC07CR)
						CASE aStruDST[nStru][1] == "CT2_EC08CR"
							cConteudo := If(CT2->CT2_DC == "1","",CT2_EC08CR)
						CASE aStruDST[nStru][1] == "CT2_EC09CR"
							cConteudo := If(CT2->CT2_DC == "1","",CT2_EC09CR)
						OTHERWISE
							cConteudo := &("CT2->"+aStruDST[nStru][1])
					ENDCASE
					/// SE FOR INCLUSAO OU ALTERACAO FORA OS CAMPOS INDICADOS EFETUA O REPLACE PARA O CT2 DESTINO
					If (lINCLUI .AND. !aStruDST[nStru][1]$("CT2_CREDIT/CT2_CCC/CT2_ITEMC/CT2_CLVLCR/CT2_EC05CR/CT2_EC06CR/CT2_EC07CR/CT2_EC08CR/CT2_EC09CR")) .OR. (!lINCLUI .AND. !aStruDST[nStru][1]$("CT2_FILIAL/CT2_DATA/CT2_LOTE/CT2_SBLOTE/CT2_DOC/CT2_LINHA"))
						&("CT2DST->"+aStruDST[nStru][1]) := cConteudo
					Endif
				Next
			Endif
			
			If lCT295GRV
				ExecBlock("CT295GRV",.F.,.F.,{lInclui}) 
			Endif
					
			CT2DST->(MsUnlock())		
		Next
		
		If !lHP														//// SE FOR GRAVACAO PELO HISTORICO DO LANCAMENTO
			GrvCt2Tp4(aStruDST,lCorrec,@CTF_LOCK,@cLote,cSubLote)					//// EFETUA A GRAVACAO DAS CONTINUACOES DE HISTORICO
		Endif
		
		dbSelectArea("CT2")
		CT2->(dbSetOrder(nOrdSeek))
		CT2->(dbSkip())
	Enddo
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/// LIMPA NA EMPRESA DESTINO OS DELETADOS NA EMPRESA ORIGEM
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	cFilDST  := xFilDST(aXFilial,"CT2") 
	cKeySeek := cFilDST
	nOrdSeek := 2
	bCondMain := {|| CT2DST->CT2_DEBITO <= cCT1FIM }			/// CONDICAO PRINCIPAL DO WHILE
	bCondWhile := {|| CT2DST->CT2_DEBITO < CV5->CV5_CT1ORI .or. CT2DST->CT2_DEBITO	> cCT1FIM .or. CT2DST->CT2_CCD 	< CV5->CV5_CTTORI .or. CT2DST->CT2_CCD 	> cCTTFIM .or. CT2DST->CT2_ITEMD	< CV5->CV5_CTDORI .or. CT2DST->CT2_ITEMD	> cCT1FIM .or. CT2DST->CT2_CLVLDB < CV5->CV5_CTHORI .or. CT2DST->CT2_CLVLDB	> cCT1FIM }											/// CONDICAO A SER TESTADA DENTRO DO WHILE
	
	DO CASE
		CASE !EMPTY(CV5->CV5_CT1ORI)
			cKeySeek += CV5->CV5_CT1ORI
			cKeySeek += DTOS(dDataIni)
		CASE !EMPTY(CV5->CV5_CTTORI)
			nOrdSeek := 4
			cKeySeek += CV5->CV5_CTTORI
			cKeySeek += DTOS(dDataIni)
			bCondMain := {|| CT2DST->CT2_CCD <= cCTTFIM }			/// CONDICAO PRINCIPAL DO WHILE
			bCondWhile := {|| CT2DST->CT2_DEBITO < CV5->CV5_CT1ORI .or. CT2DST->CT2_DEBITO	> cCT1FIM .or. CT2DST->CT2_ITEMD	< CV5->CV5_CTDORI .or. CT2DST->CT2_ITEMD	> cCTDFIM .or. CT2DST->CT2_CLVLDB < CV5->CV5_CTHORI .or. CT2DST->CT2_CLVLDB	> cCTHFIM }	/// CONDICAO A SER TESTADA DENTRO DO WHILE
		CASE !EMPTY(CV5->CV5_CTDORI)
			nOrdSeek := 6
			cKeySeek += CV5->CV5_CTDORI
			cKeySeek += DTOS(dDataIni)
			bCondMain := {|| CT2DST->CT2_ITEMD <= cCTDFIM }		/// CONDICAO PRINCIPAL DO WHILE
			bCondWhile := {|| CT2DST->CT2_DEBITO < CV5->CV5_CT1ORI .or. CT2DST->CT2_DEBITO	> cCT1FIM .or. CT2DST->CT2_CCD 	< CV5->CV5_CTTORI .or. CT2DST->CT2_CCD 	> cCTTFIM .or. CT2DST->CT2_CLVLDB < CV5->CV5_CTHORI .or. CT2DST->CT2_CLVLDB	> cCTHFIM }	/// CONDICAO A SER TESTADA DENTRO DO WHILE
		CASE !EMPTY(CV5->CV5_CTHORI)
			nOrdSeek := 8
			cKeySeek += CV5->CV5_CTHORI
			cKeySeek += DTOS(dDataIni)
			bCondMain := {|| CT2DST->CT2_CLVLDB <= cCTHFIM }		/// CONDICAO PRINCIPAL DO WHILE
			bCondWhile := {|| CT2DST->CT2_DEBITO < CV5->CV5_CT1ORI .or. CT2DST->CT2_DEBITO	> cCT1FIM .or. CT2DST->CT2_CCD 	< CV5->CV5_CTTORI .or. CT2DST->CT2_CCD 	> cCTTFIM .or. CT2DST->CT2_ITEMD	< CV5->CV5_CTDORI .or. CT2DST->CT2_ITEMD	> cCTDFIM }  /// CONDICAO A SER TESTADA DENTRO DO WHILE
	ENDCASE
	             
	dbSelectArea("CT2DST")
	CT2DST->(dbSetOrder(nOrdSeek))
	CT2DST->(MsSeek(cKeySeek,.T.))
	While !CT2DST->(Eof()) .and. CT2DST->CT2_FILIAL == cFilDST .and. Eval(bCondMain)
		If !Empty(cTpSald) .and. CT2DST->CT2_TPSALD <> cTpSald					//// FILTRO DE TIPO SE SALDO SE INFORMADO
			CT2DST->(dbSkip())        
			Loop
		Endif
		       
		If Empty(CT2DST->CT2_IDENTC) 											//// SE NAO FOR LANCAMENTO GERADO POR INTERCOMPANY
			CT2DST->(dbSkip())
			Loop
		Endif
		                                                
		If CT2DST->CT2_DATA < dDataIni .or. CT2DST->CT2_DATA > dDataFim .or. Eval(bCondWhile)													/// CONDICAO DE FILTRO DAS DEMAIS ENTIDADES
			CT2DST->(dbSkip())
			Loop
		Endif
		
		dbSelectArea("CT2")
		dbSetOrder(1)
		If !MsSeek(CT2DST->CT2_IDENTC,.F.)										/// SE NAO ENCONTRAR O LANCAMENTO ORIGEM
			RecLock("CT2DST",.F.)
			CT2DST->(dbDelete()) 												/// DELETA O LANCAMENTO DA EMPRESA DESTINO
			CT2DST->(MsUnlock())
		Endif
			
		CT2DST->(dbSkip())
	EndDo
	    
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/// BUSCA A CHAVE CONTABIL DO CV5 NOS LANCAMENTOS CREDITO - LANCAMENTOS A CREDITO (TIPO 2) E PARTIDA DOBRADA
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	cKeySeek := cFilORICV5
	nOrdSeek := 3
	bCondMain := {|| CT2->CT2_CREDIT <= cCT1FIM }			/// CONDICAO PRINCIPAL DO WHILE
	bCondWhile := {|| CT2->CT2_CREDIT < CV5->CV5_CT1ORI .or. CT2->CT2_CREDIT	> cCT1FIM .or. CT2->CT2_CCC 	< CV5->CV5_CTTORI .or. CT2->CT2_CCC 	> cCTTFIM .or. CT2->CT2_ITEMC	< CV5->CV5_CTDORI .or. CT2->CT2_ITEMC	> cCTDFIM .or. CT2->CT2_CLVLCR < CV5->CV5_CTHORI .or. CT2->CT2_CLVLCR	> cCTHFIM }											/// CONDICAO A SER TESTADA DENTRO DO WHILE
	
	DO CASE
		CASE !EMPTY(CV5->CV5_CT1ORI)
			cKeySeek += CV5->CV5_CT1ORI
			cKeySeek += DTOS(dDataIni)
		CASE !EMPTY(CV5->CV5_CTTORI)
			nOrdSeek := 5                                                
			cKeySeek += CV5->CV5_CTTORI
			cKeySeek += DTOS(dDataIni)
			bCondMain := {|| CT2->CT2_CCC <= cCTTFIM }			/// CONDICAO PRINCIPAL DO WHILE
			bCondWhile := {|| CT2->CT2_CREDIT < CV5->CV5_CT1ORI .or. CT2->CT2_CREDIT	> cCT1FIM .or. CT2->CT2_ITEMC	< CV5->CV5_CTDORI .or. CT2->CT2_ITEMC	> cCTDFIM .or. CT2->CT2_CLVLCR < CV5->CV5_CTHORI .or. CT2->CT2_CLVLCR	> cCTHFIM }	/// CONDICAO A SER TESTADA DENTRO DO WHILE
		CASE !EMPTY(CV5->CV5_CTDORI)
			nOrdSeek := 7
			cKeySeek += CV5->CV5_CTDORI
			cKeySeek += DTOS(dDataIni)
			bCondMain := {|| CT2->CT2_ITEMC <= cCTDFIM }		/// CONDICAO PRINCIPAL DO WHILE
			bCondWhile := {|| CT2->CT2_CREDIT < CV5->CV5_CT1ORI .or. CT2->CT2_CREDIT	> cCT1FIM .or. CT2->CT2_CCC 	< CV5->CV5_CTTORI .or. CT2->CT2_CCC 	> cCTTFIM .or. CT2->CT2_CLVLCR < CV5->CV5_CTHORI .or. CT2->CT2_CLVLCR	> cCTHFIM }	/// CONDICAO A SER TESTADA DENTRO DO WHILE
		CASE !EMPTY(CV5->CV5_CTHORI)
			nOrdSeek := 9
			cKeySeek += CV5->CV5_CTHORI
			cKeySeek += DTOS(dDataIni)
			bCondMain := {|| CT2->CT2_CLVLCR <= cCTHFIM }		/// CONDICAO PRINCIPAL DO WHILE
			bCondWhile := {|| CT2->CT2_CREDIT < CV5->CV5_CT1ORI .or. CT2->CT2_CREDIT	> cCT1FIM .or. CT2->CT2_CCC 	< CV5->CV5_CTTORI .or. CT2->CT2_CCC 	> cCTTFIM .or. CT2->CT2_ITEMC	< CV5->CV5_CTDORI .or. CT2->CT2_ITEMC	> cCTDFIM }  /// CONDICAO A SER TESTADA DENTRO DO WHILE
	ENDCASE
	
	dbSelectArea("CT2")
	CT2->(dbSetOrder(nOrdSeek))
	CT2->(MsSeek(cKeySeek,.T.))
	While !CT2->(Eof()) .and. CT2->CT2_FILIAL == cFilORICV5 .and. Eval(bCondMain)
		lINCLUI := .T.													//// INDICA SE DEVE INCLUIR/ALTERAR
		lDELETA := .F.
		lTemM1	:= .F.
		nRecM1  := 0
		nRecDST := 0
		
	 	If CT2->CT2_DC == "1"       										// Pula os registros de debito
			CT2->(dbSkip())
			Loop
		Endif  
		
		If !CT2->CT2_INTERC$"S1Y" 											//// ADICIONA SOMENTE SE O FLAG ESTIVER MARCADO E SE AINDA NÃO FOI PROCESSADO
			CT2->(dbSkip())
			Loop
		Endif
		
		If !Empty(cMoeda) .and. CT2->CT2_MOEDLC <> cMoeda					//// FILTRO DE MOEDA SE INFORMADO
			CT2->(dbSkip())
			Loop
		Endif
		
		If !Empty(cTpSald) .and. CT2->CT2_TPSALD <> cTpSald					//// FILTRO DE TIPO SE SALDO SE INFORMADO
			CT2->(dbSkip())
			Loop
		Endif
		
		If CT2->CT2_DATA < dDataIni .or. CT2->CT2_DATA > dDataFim .or. Eval(bCondWhile)													/// CONDICAO DE FILTRO DAS DEMAIS ENTIDADES
			CT2->(dbSkip())
			Loop
		Endif
		
		If CV5->(FieldPos("CV5_E05ORI")) > 0 .And. CV5->(FieldPos("CV5_E05FIM")) > 0 .And. CT2->(FieldPos("CT2_EC05CR")) > 0
			If CT2->CT2_EC05CR < CV5->CV5_E05ORI .or. CT2->CT2_EC05CR > cE05FIM
				CT2->(dbSkip())
				Loop
			EndIf
		EndIf

		If CV5->(FieldPos("CV5_E06ORI")) > 0 .And. CV5->(FieldPos("CV5_E06FIM")) > 0 .And. CT2->(FieldPos("CT2_EC06CR")) > 0
			If CT2->CT2_EC06CR < CV5->CV5_E06ORI .or. CT2->CT2_EC06CR > cE06FIM
				CT2->(dbSkip())
				Loop
			EndIf
		EndIf

		If CV5->(FieldPos("CV5_E07ORI")) > 0 .And. CV5->(FieldPos("CV5_E07FIM")) > 0 .And. CT2->(FieldPos("CT2_EC07CR")) > 0
			If CT2->CT2_EC07CR < CV5->CV5_E07ORI .or. CT2->CT2_EC07CR > cE07FIM
				CT2->(dbSkip())
				Loop
			EndIf
		EndIf

		If CV5->(FieldPos("CV5_E08ORI")) > 0 .And. CV5->(FieldPos("CV5_E08FIM")) > 0 .And. CT2->(FieldPos("CT2_EC08CR")) > 0
			If CT2->CT2_EC08CR < CV5->CV5_E08ORI .or. CT2->CT2_EC08CR > cE08FIM
				CT2->(dbSkip())
				Loop
			EndIf
		EndIf

		If CV5->(FieldPos("CV5_E09ORI")) > 0 .And. CV5->(FieldPos("CV5_E09FIM")) > 0 .And. CT2->(FieldPos("CT2_EC09CR")) > 0
			If CT2->CT2_EC09CR < CV5->CV5_E09ORI .or. CT2->CT2_EC09CR > cE09FIM
				CT2->(dbSkip())
				Loop
			EndIf
		EndIf
				
		dbSelectArea("CT2DST")					//// SE O REGISTRO AINDA NÃO EXISTIR NA EMPRESA DESTINO
		dbSetOrder(nIndCT2)
		If MsSeek(xFilDST(aXFilial,"CT2")+CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC+CT2_SEQLAN+CT2_SEQHIS),.F.)	//// ORIGEM NO INTERCOMPANY (PARA VALIDACAO NO PROX. PROCESSAMENTO)
			If !lCorrec	.and. (!Empty(CT2DST->CT2_CREDIT) .OR. !Empty(CT2DST->CT2_CCC) .OR. !Empty(CT2DST->CT2_ITEMC) .OR. !Empty(CT2DST->CT2_CLVLCR))
				CT2->(dbSetOrder(nOrdSeek))		//// SE O PARAMETRO ATUALIZA ALTERAÇÕES ESTIVER = NAO
				CT2->(dbSkip())
				Loop							//// O REGISTRO JÁ EXISTE ENTÃO NAO DEVE PROCESSAR
			Else
				lINCLUI := .F.					/// SE EXISTIR E FOR CORREÇÃO NAO DEVERÁ INCLUIR E SIM ALTERAR
				If CT2->(Deleted())				/// SE ESTIVER DELETADO DEVE EXCLUIR NO DESTINO
					lDELETA := .T.
				Endif
			Endif
			nRecDST := CT2DST->(Recno())
		Else
			If CT2->(Deleted())					//// SE FOR INCLUSAO E A ORIGEM ESTIVER DELETADA
				CT2->(dbSetOrder(nOrdSeek))
				CT2->(dbSkip())
				Loop							//// PASSA PARA O PROXIMO
			Endif		
		Endif

		If CT2->CT2_MOEDLC <> "01"			//// SE FOR LANCAMENTO DE OUTRA MOEDA PROCURA
			If MsSeek(xFilDST(aXFilial,"CT2")+CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+"01"),.F.)
				cLote		:= CT2DST->CT2_LOTE
				cSubLote 	:= CT2DST->CT2_SBLOTE
				cDoc		:= CT2DST->CT2_DOC
				cLinha		:= CT2DST->CT2_LINHA
				lTemM1		:= .T.
				nRecM1		:= CT2DST->(Recno())
			Endif			
		Endif
			
		//////////////////////////////////////////////////////////////////////////////////////////////////////////
		//// SE TRATA-SE DE INCLUSAO OBTEM O NUMERO SEQUENCIAL DE DOC
		CTA295Doc(CT2->CT2_DATA,@cLote,@cSubLote,@cDoc,@lINCLUI,@CTF_LOCK)
		//////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		If Ascan(aSldUsed,CT2->CT2_TPSALD) <= 0		//// TIPO DE SALDO AINDA NAO ESTA NA LISTA DE SALDOS USADOS
			aAdd(aSldUsed,CT2->CT2_TPSALD)			//// ADICIONA NA LISTA DE SALDOS UTILIZADOS
		Endif
		
		nMoedas := Val(CT2->CT2_MOEDLC)
		
		//// OBTEM A NUMERACAO DE LINHA PARA A GRAVACAO DO LANCAMENTO DESTINO
		If lINCLUI
			cLinha := CT2->CT2_LINHA
			dbSelectArea("CTFDST")
			MsGoTo(CTF_LOCK)
			If Empty(CTFDST->CTF_LINHA)
				cLinha := StrZero( 1, Len(CT2->CT2_LINHA) )//"001"
			Else
				dbSelectArea("CT2DST")
				dbSetOrder(1)
				While CT2DST->(MsSeek(xFilDST(aXFilial,"CT2")+dtos(CT2->CT2_DATA)+cLote+cSubLote+cDoc+cLinha,.F.))
					cLinha := SOMA1(CTFDST->CTF_LINHA)
					RecLock("CTFDST",.F.)
					CTFDST->CTF_LINHA := cLinha
					CTFDST->(MsUnlock())
				Enddo
			Endif
			RecLock("CTFDST",.F.)
			CTFDST->CTF_LINHA := cLinha
			CTFDST->(MsUnlock())
		Endif
		
		//// EFETUA A GRAVACAO DO LANCAMENTO NO CT2 DA EMPRESA DESTINO
		For nMoedLC := 1 to nMoedas
			If lDELETA
				CT2DST->(MsGoTo(nRecDST))
				If CT2->CT2_MOEDLC <> CT2DST->CT2_MOEDLC .AND. CT2DST->CT2_VALOR <> 0			/// SE O MOVIMENTO DE OUTRA MOEDA (01) COM VALOR, NAO DEVE SER EXCLUIDO
					Loop
				Endif
				RecLock("CT2DST",.F.)	/// REPLICA DADOS ORIGEM PARA O DESTINO - CREDITO
				CT2DST->(dbDelete())
			Else
				lTpLock := lINCLUI
				If CT2->CT2_MOEDLC <> "01"			/// SE FOR LANCAMENTO DE OUTRA MOEDA
					If lTemM1 .and. nMoedLC == 1	/// VERIFICA SE A MOEDA 1 JA EXISTE
						CT2DST->(MsGoTo(nRecM1))
						cLinha := CT2DST->CT2_LINHA
						lTpLock := .F.
					ElseIf !lINCLUI 
						CT2DST->(MsGoTo(nRecDST))
					Endif
					If nMoedLC <> nMoedas .and. nMoedLC <> 1		/// SE NAO FOR A MOEDA DO LANCAMENTO E NAO FOR A MOEDA 1
						Loop										/// PASSA PARA A PROXIMA MOEDA
					Endif
				Endif
				RecLock("CT2DST",lTpLock)	/// REPLICA DADOS ORIGEM PARA O DESTINO - CREDITO

				For nStru := 1 to nLenDST
					DO CASE
						CASE aStruDST[nStru][1] == "CT2_FILIAL"
							cConteudo := xFilDST(aXFilial,"CT2")
						CASE aStruDST[nStru][1] == "CT2_LOTE"
							cConteudo := cLote
						CASE aStruDST[nStru][1] == "CT2_SBLOTE"
							cConteudo := cSubLote
						CASE aStruDST[nStru][1] == "CT2_DOC"
							cConteudo := cDoc
						CASE aStruDST[nStru][1] == "CT2_LINHA"
							cConteudo := cLinha
						CASE aStruDST[nStru][1] == "CT2_MOEDLC"
							cConteudo := STRZERO(nMoedLC,Len(CT2->CT2_MOEDLC))
						CASE aStruDST[nStru][1] == "CT2_VALOR" .and. nMoedLC == 1 .and. nMoedas <> 1
							cConteudo := CT2DST->CT2_VALOR					/// NAO ALTERA O VALOR DESTINO NA MOEDA 1
						CASE aStruDST[nStru][1] == "CT2_CREDIT"      
							If lExstCT1Ig .And. CV5->CV5_CT1IGU == "S"						
								cConteudo := CT2->CT2_CREDIT
							Else
								cConteudo := CV5->CV5_CT1DES//If(Empty(CV5->CV5_CT1DES),CT2->CT2_CREDIT,CV5->CV5_CT1DES)
							EndIf
						CASE aStruDST[nStru][1] == "CT2_CCC"
							If lExstCTTIg .And. CV5->CV5_CTTIGU == "S"						
								cConteudo := CT2->CT2_CCC
							Else						
								cConteudo := CV5->CV5_CTTDES//If(Empty(CV5->CV5_CTTDES),CT2->CT2_CCC,CV5->CV5_CTTDES)
							EndIf
						CASE aStruDST[nStru][1] == "CT2_ITEMC"  
							If lExstCTDIg .And. CV5->CV5_CTDIGU == "S"						
								cConteudo := CT2->CT2_ITEMC
							Else												
								cConteudo := CV5->CV5_CTDDES//If(Empty(CV5->CV5_CTDDES),CT2->CT2_ITEMC,CV5->CV5_CTDDES)
							EndIf
						CASE aStruDST[nStru][1] == "CT2_CLVLCR"
							If lExstCTHIg .And. CV5->CV5_CTHIGU == "S"						
								cConteudo := CT2->CT2_CLVLCR
							Else																		
								cConteudo := CV5->CV5_CTHDES//If(Empty(CV5->CV5_CTHDES),CT2->CT2_CLVLCR,CV5->CV5_CTHDES)
							EndIf
							
						//// TRATAMENTO PARA OS LANCAMENTOS DE PARTIDA DOBRADA CASO A CONTRA-PARTIDA NAO ESTEJA CONFIGURADA
						CASE aStruDST[nStru][1] == "CT2_DC"
							cConteudo := If(CT2->CT2_DC$"3XP" .and. !lINCLUI,CT2->CT2_DC,"2")
							
						CASE aStruDST[nStru][1] == "CT2_HIST"
							cConteudo := If( lHP, cHP, &("CT2->"+aStruDST[nStru][1]) )
						CASE aStruDST[nStru][1] == "CT2_EMPORI"
							cConteudo := cEmpOriATU
						CASE aStruDST[nStru][1] == "CT2_FILORI"
							cConteudo := cFilOriATU
						CASE aStruDST[nStru][1] == "CT2_IDENTC"
							cConteudo := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+STRZERO(nMoedLC,Len(CT2->CT2_MOEDLC))+CT2_SEQLAN+CT2_SEQHIS)	//// ORIGEM NO INTERCOMPANY (PARA VALIDACAO NO PROX. PROCESSAMENTO)
						CASE aStruDST[nStru][1] == "CT2_INTERC"
							cConteudo := "2"
							
						CASE aStruDST[nStru][1] == "CT2_DEBITO"
							cConteudo := If(CT2->CT2_DC == "1","",CT2_DEBITO)
						CASE aStruDST[nStru][1] == "CT2_CCD"
							cConteudo := If(CT2->CT2_DC == "1","",CT2_CCD)
						CASE aStruDST[nStru][1] == "CT2_ITEMD"
							cConteudo := If(CT2->CT2_DC == "1","",CT2_ITEMD)
						CASE aStruDST[nStru][1] == "CT2_CLVLDB"
							cConteudo := If(CT2->CT2_DC == "1","",CT2_CLVLDB)
							
															//// ORIGEM - INTERCOMPANY (NAO GERA PARA OUTRAS EMPRESAS)
						OTHERWISE
							cConteudo := &("CT2->"+aStruDST[nStru][1])
					ENDCASE 
						
					/// SE FOR INCLUSAO OU ALTERACAO FORA OS CAMPOS INDICADOS EFETUA O REPLACE PARA O CT2 DESTINO
					If (lINCLUI .AND. !aStruDST[nStru][1]$("CT2_DEBITO/CT2_CCD/CT2_ITEMD/CT2_CLVLDB")) .OR. (!lINCLUI .AND. !aStruDST[nStru][1]$("CT2_FILIAL/CT2_DATA/CT2_LOTE/CT2_SBLOTE/CT2_DOC/CT2_LINHA"))
						&("CT2DST->"+aStruDST[nStru][1]) := cConteudo
					Endif
				Next
			Endif
			If lCT295GRV
				ExecBlock("CT295GRV",.F.,.F.,{lInclui}) 
			Endif
			
			CT2DST->(MsUnlock())
		Next
		
		If !lHP														//// SE FOR GRAVACAO PELO HISTORICO DO LANCAMENTO
			GrvCt2Tp4(aStruDST,lCorrec,@CTF_LOCK,@cLote,cSubLote)					//// EFETUA A GRAVACAO DAS CONTINUACOES DE HISTORICO
		Endif
		
		dbSelectArea("CT2")
		CT2->(dbSetOrder(nOrdSeek))
		CT2->(dbSkip())
	Enddo
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/// LIMPA NA EMPRESA DESTINO OS DELETADOS NA EMPRESA ORIGEM
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	cFilDST  := xFilDST(aXFilial,"CT2") 
	cKeySeek := cFilDST
	nOrdSeek := 3
	bCondMain := {|| CT2DST->CT2_CREDIT <= cCT1FIM }			/// CONDICAO PRINCIPAL DO WHILE
	bCondWhile := {|| CT2DST->CT2_CREDIT < CV5->CV5_CT1ORI .or. CT2DST->CT2_CREDIT	> cCT1FIM .or. CT2DST->CT2_CCC 	< CV5->CV5_CTTORI .or. CT2DST->CT2_CCC 	> cCTTFIM .or. CT2DST->CT2_ITEMC	< CV5->CV5_CTDORI .or. CT2DST->CT2_ITEMC	> cCT1FIM .or. CT2DST->CT2_CLVLCR < CV5->CV5_CTHORI .or. CT2DST->CT2_CLVLCR	> cCT1FIM }											/// CONDICAO A SER TESTADA DENTRO DO WHILE
	
	DO CASE
		CASE !EMPTY(CV5->CV5_CT1ORI)
			cKeySeek += CV5->CV5_CT1ORI
			cKeySeek += DTOS(dDataIni)
		CASE !EMPTY(CV5->CV5_CTTORI)
			nOrdSeek := 5                                                
			cKeySeek += CV5->CV5_CTTORI
			cKeySeek += DTOS(dDataIni)
			bCondMain := {|| CT2DST->CT2_CCC <= cCTTFIM }			/// CONDICAO PRINCIPAL DO WHILE
			bCondWhile := {|| CT2DST->CT2_CREDIT < CV5->CV5_CT1ORI .or. CT2DST->CT2_CREDIT	> cCT1FIM .or. CT2DST->CT2_ITEMC	< CV5->CV5_CTDORI .or. CT2DST->CT2_ITEMC	> cCTDFIM .or. CT2DST->CT2_CLVLCR < CV5->CV5_CTHORI .or. CT2DST->CT2_CLVLCR	> cCTHFIM }	/// CONDICAO A SER TESTADA DENTRO DO WHILE
		CASE !EMPTY(CV5->CV5_CTDORI)
			nOrdSeek := 7
			cKeySeek += CV5->CV5_CTDORI
			cKeySeek += DTOS(dDataIni)
			bCondMain := {|| CT2DST->CT2_ITEMC <= cCTDFIM }		/// CONDICAO PRINCIPAL DO WHILE
			bCondWhile := {|| CT2DST->CT2_CREDIT < CV5->CV5_CT1ORI .or. CT2DST->CT2_CREDIT	> cCT1FIM .or. CT2DST->CT2_CCC 	< CV5->CV5_CTTORI .or. CT2DST->CT2_CCC 	> cCTTFIM .or. CT2DST->CT2_CLVLCR < CV5->CV5_CTHORI .or. CT2DST->CT2_CLVLCR	> cCTHFIM }	/// CONDICAO A SER TESTADA DENTRO DO WHILE
		CASE !EMPTY(CV5->CV5_CTHORI)
			nOrdSeek := 9
			cKeySeek += CV5->CV5_CTHORI
			cKeySeek += DTOS(dDataIni)
			bCondMain := {|| CT2DST->CT2_CLVLCR <= cCTHFIM }		/// CONDICAO PRINCIPAL DO WHILE
			bCondWhile := {|| CT2DST->CT2_CREDIT < CV5->CV5_CT1ORI .or. CT2DST->CT2_CREDIT	> cCT1FIM .or. CT2DST->CT2_CCC 	< CV5->CV5_CTTORI .or. CT2DST->CT2_CCC 	> cCTTFIM .or. CT2DST->CT2_ITEMC	< CV5->CV5_CTDORI .or. CT2DST->CT2_ITEMC	> cCTDFIM }  /// CONDICAO A SER TESTADA DENTRO DO WHILE
	ENDCASE

	dbSelectArea("CT2DST")
	CT2DST->(dbSetOrder(nOrdSeek))
	CT2DST->(MsSeek(cKeySeek,.T.))
	While !CT2DST->(Eof()) .and. CT2DST->CT2_FILIAL == cFilDST .and. Eval(bCondMain)
		If !Empty(cTpSald) .and. CT2DST->CT2_TPSALD <> cTpSald					//// FILTRO DE TIPO SE SALDO SE INFORMADO
			CT2DST->(dbSkip())
			Loop
		Endif
		
		If Empty(CT2DST->CT2_IDENTC) 											//// SE NAO FOR LANCAMENTO GERADO POR INTERCOMPANY
			CT2DST->(dbSkip())
			Loop
		Endif
		                                                
		If CT2DST->CT2_DATA < dDataIni .or. CT2DST->CT2_DATA > dDataFim .or. Eval(bCondWhile)													/// CONDICAO DE FILTRO DAS DEMAIS ENTIDADES
			CT2DST->(dbSkip())
			Loop
		Endif
		
		dbSelectArea("CT2")
		dbSetOrder(1)
		If !MsSeek(CT2DST->CT2_IDENTC,.F.)										/// SE NAO ENCONTRAR O LANCAMENTO ORIGEM
			RecLock("CT2DST",.F.)
			CT2DST->(dbDelete()) 												/// DELETA O LANCAMENTO DA EMPRESA DESTINO
			CT2DST->(MsUnlock())
		Endif
			
		CT2DST->(dbSkip())
	EndDo
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//// PROXIMO REGISTRO DE "ROTEIRO" DO INTERCOMPANY
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////		
	dbSelectArea("CV5")
	CV5->(dbSkip())
Enddo

If !Empty(cArqInd)
	dbSelectArea("CT2DST")
	dbClearFil()
	dbSetOrder(1)
	If File(cArqInd+OrdBagExt())
		FErase(cArqInd+OrdBagExt())
	Endif
Endif		

// Restaura as areas e a posição das variaveis originais
dbSelectArea("SM0")
MsSeek(cEmpOri+cFilOri)

cEmpAnt := cEmpOri												/// CODIGO DA EMPRESA ORIGINAL
cFilAnt := cFilOri												/// CODIGO DA FILIAL ORIGINAL

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA295   ºAutor  ³Marcos S. Lobo      º Data ³  08/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Cta295Vld(lWf,aEmpUsed,dDataIni,dDataFim,cCodIni,cCodFim,lHP,cHP,lCorrec,lAtuSal,cMoeda,cTpSald)
Local lOk 		:= .T.
Local aAreaAnt 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aStrCT2ORI:= {}
Local cEmpOld 	:= cEmpAnt
Local cFilOld 	:= cFilAnt
Local aEmp2Use	:= {}
Local lGestao		:= Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa
Local bVerEmp		:= { || }

If lGestao
	bVerEmp := { || SM0->M0_CODIGO+IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <> cEmpAnt+cFilAnt }
Else
	bVerEmp := { || SM0->M0_CODIGO <> cEmpAnt }	
EndIf

DEFAULT cMoeda	:= ""			///Se cMoeda = branco... considera todas as moedas
If cMoeda == "*"				// Se indicar * considera todas as moedas
	cMoeda := ""
EndIF

dbSelectArea("CT2")
aStrCT2ORI	:= CT2->(dbStruct())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CARREGA ARRAY SOMENTE COM AS EMPRESAS E FILIAIS ³
//³QUE SERAO UTILIZADAS NO PROCESSAMENTO.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CV5")
dbSetOrder(1)
cFilCV5 := xFilial("CV5")
dbSeek(cFilCV5+cCodIni,.T.)
cEmpFilAtu := ""
While CV5->(!Eof()) .and. CV5->CV5_FILIAL == cFilCV5 .and. CV5->CV5_COD <= cCodFim
	If cEmpFilAtu <> CV5->(CV5_EMPDES+CV5_FILDES)
		If aScan(aEmp2Use,{|x| x == CV5->(CV5_EMPDES+CV5_FILDES) } ) <= 0
			aAdd(aEmp2Use,CV5->(CV5_EMPDES+CV5_FILDES))
		EndIf
		cEmpFilAtu := CV5->(CV5_EMPDES+CV5_FILDES)
	EndIf
	CV5->(dbSkip())	
EndDo
        
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// EFETUA A CHECAGEM DO SX3 DE TODAS AS EMPRESAS
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
dbSelectArea("SM0")
If !lWf
	ProcRegua(SM0->(RecCount()))
Endif
dbSetOrder(1)
dbGoTop()
aArqs := {"SX3"}
cEmpAnt := "99"
While !SM0->(Eof())											//// RODA O ARQUIVO DE EMPRESAS
	If !lWf
		IncProc(STR0019+SM0->M0_CODIGO+"/"+IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ))  //"Validando empresa/filial..."
	Endif
	If Eval(bVerEmp)
		cEmpAnt := SM0->M0_CODIGO
		cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
		If !ca295Abre(aArqs,SM0->M0_CODIGO,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),.T.,.F.,@aXFilial)		//// SE NAO CONSEGUIU ABRIR O SX3 DA EMPRESA/FILIAL // .T. PARA NAO PERDER O ALIAS SX3 PADRAO ABERTO
			cMsg := STR0016+"SX3"+STR0017+SM0->M0_CODIGO+"/"+IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
			IF !lWf
				MsgAlert(cMsg)
			Endif
			
			cEmpAnt := cEmpOld
			cFilAnt := cFilOld
			Return .F.											//// RETORNA ERRO
		Else
			dbSelectArea("SX3")
			dbSetOrder(2)
			If !MsSeek("CT2_INTERC") 	 						/// SE NAO ENCONTRAR OS CAMPOS DO INTERCOMPANY
				cMsg := STR0020+"CT2_INTERC"+STR0021+STR0017+SM0->M0_CODIGO+"/"+IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
				IF !lWf
					MsgAlert(cMsg)
				Endif
				
				cEmpAnt := cEmpOld
				cFilAnt := cFilOld
				Return .F.										/// RETORNA ERRO
			Else
				If !X3Uso(SX3->X3_USADO)						/// SE ENCONTRAR E NAO ESTIVER EM USO
					cMsg := STR0020+"CT2_INTERC"+STR0022+STR0017+SM0->M0_CODIGO+"/"+IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )   //não encontrado   //na Empresa/Filial "
					IF !lWf
						MsgAlert(cMsg)
					Endif
					
					cEmpAnt := cEmpOld
					cFilAnt := cFilOld
					Return .F.									/// RETORNA ERRO
				Endif
			Endif
			
			dbSelectArea("SX3")
			dbSetOrder(2)
			If !MsSeek("CT2_IDENTC") 	 						/// SE NAO ENCONTRAR OS CAMPOS DO INTERCOMPANY
				cMsg := STR0020+"CT2_IDENTC"+STR0021+STR0017+SM0->M0_CODIGO+"/"+IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
				IF !lWf
					MsgAlert(cMsg)
				Endif
				Return .F.										/// RETORNA ERRO
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄC
			//³VALIDACAO DE AMARRAÇÕES E BLOQUEIOS DE MOEDA/CALENDARIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄC
			If aScan(aEmp2Use,{|x| AllTrim(x) == AllTrim(SM0->(M0_CODIGO) + IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )) } ) > 0				
				// Se estiver entre as empresas/filiais utilizadas
				aArqs := {"CTG","CTP","CTO","CTE"}
				If ca295Abre(aArqs,SM0->M0_CODIGO,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),.F.,.F.,@aXFilial)		//// SE NAO CONSEGUIU ABRIR O SX3 DA EMPRESA/FILIAL // .T. PARA NAO PERDER O ALIAS SX3 PADRAO ABERTO
					If CtVlDTMoed(dDataIni,dDataFim,If(Empty(cMoeda),1,2),cMoeda,,cTpSald)
						// Se houver moeda, data ou data em moeda com status bloqueado.
						cEmpAnt := cEmpOld
						cFilAnt := cFilOld
						Return .F.
					EndIf
					
					//Fecha as tabelas na empresa em questão, após fazer as validações de moeda e calendário
					ca295Abre(aArqs,SM0->M0_CODIGO,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),.F.,.F.,@aXFilial, .T.)
				Endif				
			EndIf	
		Endif
	Endif
	SM0->(dbSkip())
Enddo

RestArea(aAreaSM0)

cEmpAnt := SM0->M0_CODIGO
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
If !ca295Abre({},SM0->M0_CODIGO,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),.F.,.F.,@aXFilial)			/// SÓ RESTAURA O SX2 ORIGINAL
	cMsg := STR0016+"SX2"+STR0017+SM0->M0_CODIGO+"/"+IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	IF !lWf
		MsgAlert(cMsg)
	Endif
	
	cEmpAnt := cEmpOld
	cFilAnt := cFilOld
	Return .F.
Endif


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// EFETUAR A CHECAGEM DA ESTRUTURA DO CT2 PARA TODAS AS EMPRESAS
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
dbSelectArea("SM0")
If !lWf
	ProcRegua(SM0->(RecCount()))
Endif
dbSetOrder(1)
dbGoTop()
aArqs := {"CT2"}
cEmpAnt := "99"
While !SM0->(Eof())											//// RODA O ARQUIVO DE EMPRESAS
	If !lWf
		IncProc(STR0023+SM0->M0_CODIGO+"/"+IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ))
	Endif
	If SM0->M0_CODIGO <> cEmpAnt
		cEmpAnt := SM0->M0_CODIGO
		cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
		If !ca295Abre(aArqs,SM0->M0_CODIGO,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),.T.,.T.,@aXFilial)		//// SE NAO CONSEGUIU ABRIR O CT2 DA EMPRESA/FILIAL // .T. PARA NAO PERDER O ALIAS CT2 PADRAO ABERTO
			cMsg := STR0016+"CT2"+STR0017+SM0->M0_CODIGO+"/"+IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
			IF !lWf
				MsgAlert(cMsg)
			Endif
			
			cEmpAnt := cEmpOld
			cFilAnt := cFilOld
			Return .F.											//// RETORNA ERRO
		Endif
	Endif
	SM0->(dbSkip())
Enddo

RestArea(aAreaSM0)

If !ca295Abre({},SM0->M0_CODIGO,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),.F.,.F.,@aXFilial)			/// SÓ RESTAURA O SX2 ORIGINAL
	cMsg := STR0016+"SX2"+STR0017+SM0->M0_CODIGO+"/"+IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	IF !lWf
		MsgAlert(cMsg)
	Endif
	
	cEmpAnt := cEmpOld
	cFilAnt := cFilOld
	Return .F.
Endif

cEmpAnt := cEmpOld
cFilAnt := cFilOld

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// BUSCA O HISTORICO PADRAO INDICADO NO PARÂMETRO
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
If lHp
	ChkFile("CT8") // proteção para criação da CT8 
	dbSelectArea("CT8")
	dbSetOrder(1)
	If MsSeek(xFilial("CT8")+cHP)
		cHP := CT8->CT8_DESC
	Else
		cHP := ""
	Endif
EndIf

RestArea(aAreaAnt)

Return(lOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA295   ºAutor  ³Marcos S. Lobo      º Data ³  08/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function xFilDST(aXFilial,cAlias)

Local cFilX := "  "

If !Empty(cAlias)
	nPosAlias := Ascan(aXFilial,{|x| x[1] == cAlias })
	If nPosAlias > 0
		cFilX := aXFilial[nPosAlias][2] 	/// FILIAL DO ALIAS
	Endif
Endif

Return(cFilX)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA295   ºAutor  ³Marcos S. Lobo      º Data ³  08/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ProxDocItc(dDataLanc,cLote,cSubLote,cDoc,CTF_LOCK)

Local aArea		:= GetArea()
Local aAreaCTF	:= CTFDST->(GetArea())
Local aAreaCT2	:= CT2DST->(GetArea())
Local lRet		:= .T.
Local cKeyCTF	:= ""
Local dDataCTF	:= dDataLanc
Local cKeyCT2	:= ""

DEFAULT CTF_LOCK := 0

// Consecutivo por mes, aplica solo para CTF
If cPaisLoc == "MEX"
	dDataCTF := StoD( Substr(DtoS(dDataCTF), 1, 6) + "01" )
EndIf

dbSelectArea( "CTFDST" )
dbSetOrder( 1 )
cKeyCTF := xFilDST(aXFilial,"CTF")+dtos(dDataCTF)+padr(cLote,Len(CTF_LOTE))+PADR(cSubLote,LEN(CTF_SBLOTE))
cKeyCT2 := xFilDST(aXFilial,"CTF")+dtos(dDataLanc)+padr(cLote,Len(CTF_LOTE))+PADR(cSubLote,LEN(CTF_SBLOTE))

lQuery := .F.
cQuery := "SELECT Max(CTF_DOC) MAXDOC "
cQuery += "FROM "+RetSqlName("CTFDST")+" CTF "
cQuery += "WHERE CTF_FILIAL='"+xFilDST(aXFilial,"CTF")+"' AND "
cQuery += "CTF_DATA = '"+DTOS(dDataCTF)+"' AND "
cQuery += "CTF_LOTE = '"+cLote+"' AND "
cQuery += "CTF_SBLOTE = '"+cSubLote+"' AND "
cQuery += "D_E_L_E_T_=' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"PROXDOCITC")

cDoc := MAXDOC

dbSelectArea("PROXDOCITC")
dbCloseArea()

dbSelectArea("CTFDST")

If STRZERO(VAL(cDoc),6) == "999999"
	lRet := .F.
Else
	If ValType(cDOC) == "U" .or. Empty(cDoc)
		cDoc := "000001"
	Else
		cDoc := StrZero(Val(cDoc)+1,6)
	Endif
EndIf

If lRet
	dbSelectArea("CT2DST")
	dbSetOrder(1)
	While CT2DST->(MsSeek(cKeyCT2+cDoc,.F.))
		If cDoc == "999999"
			lRet := .F.
			Exit
		Else
			cDoc := StrZero(Val(cDoc)+1,6)
		EndIf
	EndDo
EndIf

If lRet
	dbSelectArea("CTFDST")
	dbSetOrder(1)
	If !CTFDST->(MsSeek(cKeyCTF+cDoc,.F.))
		RecLock("CTFDST",.T.)								//// SE NAO ESTA NO CTF INCLUI
		CTFDST->CTF_FILIAL	:= xFilDST(aXFilial,"CTF")
		CTFDST->CTF_DATA	:= dDataCTF
		CTFDST->CTF_LOTE	:= cLote
		CTFDST->CTF_SBLOTE	:= cSubLote
		CTFDST->CTF_DOC		:= cDoc
		CTFDST->(MsUnlock())
		FkCommit()
	Else
		RecLock("CTFDST",.F.)								//// SE ESTA NO CTF MAS NAO EXISTE NO CT2 (ZERA LINHA)
		CTFDST->CTF_LINHA	:= ""
		CTFDST->(MsUnlock())
	Endif
	CTF_LOCK := CTFDST->(Recno())
Endif

RestArea(aAreaCT2)
RestArea(aAreaCTF)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA295   ºAutor  ³Marcos S. Lobo      º Data ³  08/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GRVCT2TP4(aStruDST,lCorrec,CTF_LOCK,cLote,cSubLote)

Local nStru

/////////////////////////////////////////////////////////////////////////////////////////////////////
//// TRATAMENTO PARA TRANSFERIR AS CONTINUAÇÕES DE HISTÓRICO CASO EXISTAM
/////////////////////////////////////////////////////////////////////////////////////////////////////
nOrdCT2 := CT2->(IndexOrd())
nRecCT2 := CT2->(Recno())
cSEQLAN := CT2->CT2_SEQLAN

dDataLan	:= CT2DST->CT2_DATA
cDoc		:= CT2DST->CT2_DOC

dbSelectArea("CT2")
cKeyCT210	:= CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_SEQLAN+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC)
dbSetOrder(10)
CT2->(dbSkip())
If CT2->CT2_SEQLAN == cSEQLAN .AND. CT2->CT2_DC == "4"
	While !CT2->(Eof()) .and. CT2->CT2_DC == "4" .and. cKeyCT210 == CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_SEQLAN+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC)
		//// OBTEM A NUMERACAO DE LINHA PARA A GRAVACAO DO LANCAMENTO DESTINO (CONTINUACAO DE HISTORICO)
		dbSelectArea("CT2DST")
		dbSetOrder(nIndCT2)
		
		//// PROCURA NO DESTINO PELA CHAVE DE RASTREAMENTO PARA LOCALIZAR SE EXISTE DOCUMENTO
		If MsSeek(xFilDST(aXFilial,"CT2")+CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC+CT2_SEQLAN+CT2_SEQHIS),.F.)	//// ORIGEM NO INTERCOMPANY
			lINCLUI := .F.				//// SE LOCALIZOU NA EMPRESA DESTINO, SO IRA ATUALIZAR O REGISTRO JA EXISTENTE
			lDELETA := .F.
			
			If !lCorrec 									/// SE CORREÇÃO NAO ESTIVER LIGADA E NAO FOR INCLUSÃO
				Exit											/// CANCELA A RE-GRAVACAO DA CONTINUACAO DE HISTORICO
			Endif
			
			If CT2->(Deleted())
				lDELETA := .T.
			Endif
			
		Else
			lINCLUI := .T.
			lDELETA := .F.
			
			If CT2->(Deleted())									/// SE FOR INCLUSAO E A ORIGEM ESTIVER DELETADA
				CT2->(dbSetOrder(10))
				CT2->(dbSkip())
				Loop											/// PASSA PARA O PROXIMO
			Endif
			
			CTA295Doc(dDataLan,@cLote,cSubLote,@cDoc,lINCLUI,@CTF_LOCK)			//// FAZ A CHECAGEM DE EXISTÊNCIA DO CTF RETORNANDO O CTF_LOCK
			
			cLinha := Soma1(Strzero(Val(cLinha),Len(CT2->CT2_LINHA)))   //CT2->CT2_LINHA	///  cLinha so deve ser utilizado caso seja inclusao de registro

			dbSelectArea("CTFDST")
			MsGoTo(CTF_LOCK)
			If !Eof()
				If Empty(CTFDST->CTF_LINHA)
					cLinha := StrZero( 1, Len(CT2->CT2_LINHA) )//"001"
				Else
					dbSelectArea("CT2DST")
					dbSetOrder(1)
					While CT2DST->(MsSeek(xFilDST(aXFilial,"CT2")+dtos(CT2->CT2_DATA)+cLote+cSubLote+cDoc+cLinha,.F.))
						cLinha := SOMA1(CTFDST->CTF_LINHA)
						RecLock("CTFDST",.F.)
						CTFDST->CTF_LINHA := cLinha
						CTFDST->(MsUnlock())
					Enddo
				Endif
				RecLock("CTFDST",.F.)
				CTFDST->CTF_LINHA := cLinha
				CTFDST->(MsUnlock())
			Endif
		Endif
		
		//// EFETUA A GRAVACAO DO LANCAMENTO NO CT2 DA EMPRESA DESTINO (CONTINUACAO DE HISTORICO
		RecLock("CT2DST",lINCLUI)							/// REPLICA OS DADOS ORIGEM PARA O DESTINO CONT. HISTORICO
		If lDELETA
			CT2DST->(dbDelete())
		Else
			For nStru := 1 to nLenDST
				DO CASE
					CASE aStruDST[nStru][1] == "CT2_FILIAL"
						cConteudo := xFilDST(aXFilial,"CT2")
					CASE aStruDST[nStru][1] == "CT2_LOTE"
						cConteudo := cLote
					CASE aStruDST[nStru][1] == "CT2_SBLOTE"
						cConteudo := cSubLote
					CASE aStruDST[nStru][1] == "CT2_DOC"
						cConteudo := cDoc
					CASE aStruDST[nStru][1] == "CT2_LINHA"
						cConteudo := cLinha
					CASE aStruDST[nStru][1] == "CT2_EMPORI"
						cConteudo := cEmpOriATU
					CASE aStruDST[nStru][1] == "CT2_FILORI"
						cConteudo := cFilOriATU
					CASE aStruDST[nStru][1] == "CT2_IDENTC"
						cConteudo := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC+CT2_SEQLAN+CT2_SEQHIS)	//// ORIGEM NO INTERCOMPANY (PARA VALIDACAO NO PROX. PROCESSAMENTO)
					CASE aStruDST[nStru][1] == "CT2_INTERC"
						cConteudo := "2"								//// ORIGEM - INTERCOMPANY (NAO GERA PARA OUTRAS EMPRESAS)
					OTHERWISE
						cConteudo := &("CT2->"+aStruDST[nStru][1])
				ENDCASE
				/// SE FOR INCLUSAO OU ALTERACAO FORA OS CAMPOS INDICADOS EFETUA O REPLACE PARA O CT2 DESTINO
				If lINCLUI .OR. (!lINCLUI .AND. !aStruDST[nStru][1]$("CT2_FILIAL/CT2_DATA/CT2_LOTE/CT2_SBLOTE/CT2_DOC/CT2_LINHA"))
					&("CT2DST->"+aStruDST[nStru][1]) := cConteudo
				Endif
			Next
		Endif
		CT2DST->(MsUnlock())
		
		CT2->(dbSkip())
	Enddo
Endif
CT2->(dbSetOrder(nOrdCT2))						/// RESTAURA O INDICE DO CT2 ORIGEM
CT2->(MsGoTo(nRecCT2))							/// RESTAURA A POSICAO DE REGISTRO DO CT2 ORIGEM

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA295   ºAutor  ³Marcos S. Lobo      º Data ³  08/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTA295Doc(dDataLanc,cLote,cSubLote,cDoc,lINCLUI,CTF_LOCK)

Local aAreaOri := GetArea()
Local nOrdCT2  := CT2DST->(IndexOrd())
Local nRecCT2  := CT2DST->(Recno())
Local dDataCT2 := CtoD("")

dbSelectArea("CT2DST")      
dbSetOrder(nIndCT2)

If MsSeek(xFilDST(aXFilial,"CT2")+CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC),.F.)	//// PROCURA SE EXISTE REGISTRO DO MESMO DOCUMENTO ORIGEM
	/// SE ENCONTROU REGISTRO QUE PERTENCE AO MESMO DOCUMENTO NO DESTINO
	cDoc := CT2DST->CT2_DOC			//// USA O MESMO NUMERO DE DOCUMENTO DESTINO
	//// OBTEM O NUMERO DE REGISTRO NO CTF (SE JA EXISTE USA O MESMO P/ SO INCREMENTAR A LINHA)
	dbSelectArea("CTFDST")
	dbSetOrder(1)
	
	//// LOCALIZA O CTF PELO DOCUMENTO DESTINO CT2 JÁ EXISTENTE
	
	// Consecutivo por mes, aplica solo para CTF
	If cPaisLoc == "MEX"
		dDataLanc := StoD( Substr(DtoS(dDataLanc), 1, 6) + "01" )
		dDataCT2 := StoD( Substr(DtoS(CT2DST->CT2_DATA), 1, 6) + "01" )
	Else
		dDataCT2 := CT2DST->CT2_DATA
	EndIf
	
	If !MsSeek(xFilDST(aXFilial,"CTF")+CT2DST->(DTOS(dDataCT2)+CT2_LOTE+CT2_SBLOTE+CT2_DOC),.F.)
		RecLock("CTFDST",.T.)								//// SE NAO ENCONTRAR ATUALIZA O CTF
		CTFDST->CTF_FILIAL	:= xFilDST(aXFilial,"CTF")
		CTFDST->CTF_DATA	:= dDataLanc
		CTFDST->CTF_LOTE	:= cLote
		CTFDST->CTF_SBLOTE	:= cSubLote
		CTFDST->CTF_DOC		:= cDoc
		CTFDST->(MsUnlock())
		FkCommit()
	Endif
	cLote    := CTFDST->CTF_LOTE
	cDoc 	 := CTFDST->CTF_DOC
	CTF_LOCK := CTFDST->(Recno())							//// GUARDA O NUMERO DE REGISTRO PARA CONTROLE DA LINHA
Else														//// SE TRATA-SE DO PRIMEIRO REGISTRO DO DOC ORIGEM A SER TRANSPORTADO
	Do While !ProxDocITC(CT2->CT2_DATA,cLote,cSubLote,@cDoc,@CTF_LOCK)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o N§ do Doc estourou, incrementa o lote         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cLote := Soma1(cLote)
	Enddo
Endif

CT2DST->(dbSetOrder(nOrdCT2))
CT2DST->(MsGoTo(nRecCT2))
RestArea(aAreaOri)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA295   ºAutor  ³Marcos S. Lobo      º Data ³  08/13/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct295File(aXFilial,cAliasNm)
Local nPosAlias	:= 0
Local cArq			:= ""
Default cAliasNM	:= Alias()
Default aXFilial	:= {}

nPosAlias := Ascan(aXFilial,{|x| x[1] == cAliasNM })
If nPosAlias <= 0	 //// SE O CONJUNTO A EMPRESA ATUAL NAO ESTIVER NO ARRAY DE EMPRESAS UTILIZADAS
	dbSelectArea("SX2")
	dbSetOrder(1)
	If dbSeek(cAliasNM)
		cArq := alltrim(RetFullName(cAliasNM,cEmpAnt))
	Else
		cArq := cAliasNM+cEmpAnt+"0"
	Endif

Else
	cArq := aXFilial[nPosAlias][3]
Endif

Return(cArq)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ca295Abre ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 07/02/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Abre arquivos para processar Intercompany                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ca295Abre(aFiles,cEmp,cFil,lDst,lSX2,aXFilial,lFechar)

Local lOk		:= .T.
Local cSX2		:= "SX2"+cEmp+"0"
Local cInd		:= ""
Local nFiles

DEFAULT lDst	:= .F.						//// INDICA QUE OS ALIAS DEVEM SER ABERTOS COM A EXTENSAO DST NO NOME
DEFAULT lSX2	:= .T.
DEFAULT aXFilial:= {}
Default lFechar := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o arquivo SX2???.DBF.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("SX2") > 0
	dbSelectArea("SX2")
	dbCloseArea()
Endif

OpenSxs(,,,,cEmp,cSX2,"SX2",,.F.)

For nFiles := 1 to Len(aFiles)
	
	cAlias    := Left(aFiles[nFiles],3)
	If cAlias $ "EC05/E05;EC06/E06;EC07/E07;EC08/E08;EC09/E09"
		cAlias := 'CV0'
	Endif
	
	If lDst
		cAliasNEW := cAlias+"DST"
	Else
		cAliasNEW := cAlias
	Endif
	 
	If Select(cAliasNew) > 0
		dbSelectArea(cAliasNEW)
		&( cAliasNew )->( dbCloseArea() ) /// FECHA O ARQUIVO DESTINO
	Endif

	dbSelectArea("SX2")
	dbSetOrder(1)
	If MsSeek(cAlias,.F.)
		cModoFil := FWModeAccess(cAlias,3,cEmp) + FWModeAccess(cAlias,2,cEmp) + FWModeAccess(cAlias,1,cEmp)
		cModo := IIF( "E" $ cModoFil   , "E", "C" )
	Else
		cModo := "E"
	Endif
	
	If lFechar
		EmpOpenFile(cAliasNEW,cAlias,1,.F.,cEmp,@cModo)			
		Loop
	Endif  
	
	EmpOpenFile(cAliasNEW,cAlias,1,.T.,cEmp,@cModo)
	
	If lDST
		cFilAlias := xFilial(cAlias,cFil)
		nPosAlias := Ascan(aXFilial,{|x| x[1] == cAlias })
		If nPosAlias <= 0	 //// SE O CONJUNTO A EMPRESA ATUAL NAO ESTIVER NO ARRAY DE EMPRESAS UTILIZADAS
			aAdd(aXFilial,{cAlias,cFilAlias,ALLTRIM(RetFullName(cAlias,cEmp))})	/// ADICIONA NA LISTA DE EMPRESAS USADAS
		Else
			aXFilial[nPosAlias][2] := cFilAlias							/// ATUALIZA A FILIAL DO ALIAS
			aXFilial[nPosAlias][3] := ALLTRIM(RetFullName(cAlias,cEmp))			/// ATUALIZA O NOME DO ARQUIVO
		Endif
	Endif
	
	IF NETERR()
		dbSelectArea("SX2")
		Return .F.
	ENDIF
Next

Return(lOk)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA295   ºAutor  ³Marcos S. Lobo      º Data ³  01/26/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a contagem dos indices no Sindex.                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SIXCount(cINDICE)
Local nOrdens := 0
Local cAliasOri := Alias()
Local nOrdOri	:= IndexOrd()
Local nRecOri	:= Recno()
If Empty(cINDICE)
	cINDICE := Alias()
Endif

dbSelectArea("SIX")
dbSetOrder(1)
MsSeek(cINDICE,.T.)
While SIX->(!Eof()) .and. cINDICE == SIX->INDICE
	nOrdens++
	SIX->(dbSkip())
EndDo

dbSelectArea(cAliasOri)
dbSetOrder(nOrdOri)
MsGoTo(nRecOri)

Return(nOrdens)
