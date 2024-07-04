#INCLUDE "FileIO.CH"
#INCLUDE "FINA370.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWLIBVERSION.CH"

//-----------------------------------------------------------
// Posicao do array para controle do processamento MultThread
//-----------------------------------------------------------
#DEFINE ARQUIVO			1
#DEFINE MARCA			2 
#DEFINE QTD_REGISTROS	3
#DEFINE VAR_STATUS		4

#DEFINE NRECNO			1
#DEFINE NMODEL			2
#DEFINE NALIAS			3

//-------------------------------------------------------
// Flag de processamento escrito no arquivo de controle
// de threads
//-------------------------------------------------------
#DEFINE MSG_OK			"OK"
#DEFINE MSG_ERRO		"ERRO"

// Flags de processamento das variáveis globais ---------------------------------------
#DEFINE stThrError		'-1' // STATUS - Excecao: Erro de execução
#DEFINE stThrReady		 '0' // STATUS - Etapa: Variavel pronta para execução
#DEFINE stThrStart		 '1' // STATUS - Etapa: Iniciando execucao da Thread
#DEFINE stThrConnect	 '2' // STATUS - Etapa: Conexão/Ambiente estabelecidos
#DEFINE stThrTbltmp		 '3' // STATUS - Etapa: Retorno da criação da tabela temporária
#DEFINE stThrFinish		 '4' // STATUS - Etapa: Encerramento da Thread
// ------------------------------------------------------------------------------------
#DEFINE MVP03EMISSAO 1
#DEFINE MVP03DATABASE 2
#DEFINE MVP12PERIODO 1
#DEFINE MVP12DOCUMENTO 2
#DEFINE MVP12PROCESSO 3
#DEFINE MVP13TOTBOR 1
#DEFINE MVP13BORBOR 2
// ------------------------------------------------------------------------------------

// Estudo de Métricas
Static __lMetric  := .F.
Static __cFunBkp  := ""
Static __cFunMet  := ""

Static __lAutoMThrd := .F.
Static __lConoutR	:= FindFunction("CONOUTR")
Static __aFinAlias	:= {}
Static __lSchedule  := FWGetRunSchedule()
Static _oCTBAFIN	:= NIL
Static _cSGBD		
Static _MSSQL7		
Static _cOperador	
Static _cSpaceMark	:= ''
Static _lMvPar18    := .F.
Static _lCtbIniLan	:= FindFunction("CtbIniLan")
Static _lBlind	    := IsBlind()
Static __oQryTroc	:= NIl
STATIC _oPergunte	:= NIL
Static __nRecCmpCR	:=0

Static l370E5R		:= Existblock("F370E5R" )
Static l370E5P		:= Existblock("F370E5P" )
Static l370E5T		:= Existblock("F370E5T" )
Static l370E1FIL	:= Existblock("F370E1F" )   // Criado Ponto de Entrada
Static l370E1LGC	:= Existblock("F370E1L" )   // Criado Ponto de Entrada
Static l370E2FIL	:= Existblock("F370E2F" )   // Criado Ponto de Entrada
Static l370E5FIL	:= Existblock("F370E5F" )   // Criado Ponto de Entrada
STATIC lF370E5MBX	:= Existblock("F370E5MBX" )  // Criado Ponto de Entrada
Static l370EFFIL	:= Existblock("F370EFF" )   // Criado Ponto de Entrada
Static l370EFKEY	:= Existblock("F370EFK" )   // Criado Ponto de Entrada
Static l370EUFIL	:= Existblock("F370EUF" )   // Criado Ponto de Entrada
Static lF370NATP	:= Existblock("F370NATP")   // Criado Ponto de Entrada
Static lF370E1WH	:= Existblock("F370E1W" )   // Criado Ponto de Entrada para o While do SE1
Static l370E5KEY	:= Existblock("F370E5K" )   // Criado Ponto de Entrada
Static l370BORD 	:= Existblock("F370BORD")   // Criado Ponto de Entrada
Static l370CTBUSR 	:= Existblock("F370CTBUSR")
Static lCtbPFO7		:= Existblock("CtbPFO7")
Static l370E5CON	:= Existblock("F370E5CT")	 // Ponto de entrada para filtro do SE5 na contabilização
Static __CtbFPos 	:= Existblock("CtbFPos ")    // Ponto de Entrada, acionado ap? a contabiliza?o da filial

Static cCarteira
Static cCtBaixa
Static lUsaFlag
Static lPCCBaixa
Static lPosE1MsFil
Static lPosE2MsFil
Static lPosE5MsFil
Static lPosEfMsFil
Static lPosEuMsFil
Static lSeqCorr
Static lUsaFilOri
Static __dDataCtb := Nil
Static __dDataBas := Nil
Static __cQryFlag
Static _nPulseLife := Seconds()
STATIC __lHasLoja := NIL
Static __oTabFLF
Static __oTabSE5
Static __oTabSEU
Static __oTabSEF 
Static __oTabSE2
Static __oTabSE1
Static __oTabFWI

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CTBAFIN	³ Autor ³ Mauricio Pequim Jr	³ Data ³ 06/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Lan‡amentos Cont beis Off-Line - TOP			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBFIN() 												  ³±±     
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFIN													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBAFIN(lDireto,lAutoMThrd)

// -----------------------------------------------------------------------------
// Define Variáveis
// -----------------------------------------------------------------------------
Local lPanelFin	  := If (FindFunction("IsPanelFin"),IsPanelFin(),.F.)
Local nOpca		  := 0
Local aSays		  :={}
Local aButtons	  :={}
Local nNumProc	  := SuperGetMv("MV_CFINTHR", .F., 1 )
Local cFilProcIni := cFilAnt
Local cFilProcFim := cFilAnt
Local nX		  := 0
Local lUsaLog	:= SuperGetMv("MV_FINLOG",.T.,.F.)
Local cPathLog := SuperGetMv("MV_DIRDOC")
Local cLogArq 	:= "Fina370Log.TXT"
Local cCaminho := cPathLog + cLogArq
Local lProcCtb 
Local cDescription	:= STR0010 + " " + STR0011 
Local bProcess		:= {|oSelf|nOpca:=1} //{|oSelf|F370Process(oSelf)}
Local aKeyProc		:= NIL

Private cCadastro := STR0009  //"Contabiliza‡„o Off Line"
Private LanceiCtb := .F.

SetVarNameLen(50)  //determina tamanho do nome das variaveis globais para status do progresso das threads

nNumProc := If((nNumProc > 30),30,nNumProc)

Default lDireto	  := .F.
DEFAULT lAutoMThrd := .F.

DEFAULT _cSGBD		:= Alltrim(Upper(TCGetDB()))
DEFAULT _MSSQL7		:= _cSGBD $ "MSSQL7"
DEFAULT _cOperador	:= If(_MSSQL7,"+","||")
lProcCtb := SuperGetMv( "MV_CTBUPRC" , .T. , .F. ) .and. (_cSGBD $ "MSSQL7|ORACLE" ) 

__lAutoMThrd := lAutoMThrd

_cSpaceMark	:= "'"+SPACE(LEN(GETNEXTALIAS()))+"'"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                        ³
//³ mv_par01 - Mostra Lan‡amentos Contabeis ?  1- Sim, 2- Não   ³
//³ mv_par02 - Aglutina Lan‡amentos Contabeis? 1- Sim, 2- Não   ³
//³ mv_par03 - Contabiliza Emissoes? 1-Emissao / 2-Data Base    ³
//³ mv_par04 - Data Inicio                                      ³
//³ mv_par05 - Data Fim										        ³
//³ mv_par06 - Carteira ? 1-Receber/2-Pagar/3-Cheques/4-Todas   ³
//³ mv_par07 - Contab. Baixas ? 1-Dt Baixa/2-Dt Digit/3-DtDispo ³
//³ mv_par08 - Considera filiais abaixo? 1- Sim / 2 - Nao       ³
//³ mv_par09 - Da Filial                                        ³
//³ mv_par10 - Ate a Filial                                     ³
//³ mv_par11 - Atualiza Sinteticas                              ³
//³ mv_par12 - Separa por ? (Periodo,Documento,Processo)        ³
//³ mv_par13 - Ctb Bordero - Total/Por Bordero                  ³
//³ mv_par14 - Considera Filial Original?  1- Sim, 2 - Não      ³
//³ mv_par15 - Filial de                                        ³
//³ mv_par16 - Filial Até                                       ³
//³ mv_par17 - Contab. Tit. Provisorio? 1-Sim/2-Nao             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Obs: este array aRotina foi inserido apenas para permitir o
// funcionamento das rotinas internas do advanced.
Private aRotina:={ 	{ STR0012,"AxPesqui" , 0 , 1},;  //"Localizar"
					{ STR0013,"fA100Pag" , 0 , 3},;  //"Pagar"
					{ STR0014,"fA100Rec" , 0 , 3},;  //"Receber"
					{ STR0015,"fA100Can" , 0 , 5},;  //"Excluir"
					{ STR0016,"fA100Tran", 0 , 3},;  //"Transferir"
					{ STR0017,"fA100Clas", 0 , 5} }  //"Classificar"

Private lCabecalho
Private VALOR     	:= 0
Private VALORLOTE	:= 0
Private VALOR6		:= 0
Private VALOR7		:= 0
Private nTpLog      := SuperGetMv("MV_TIPOLOG",.T.,1)
Private FO1VADI     := 0 

fErase(cCaminho)
/*   Se o parametro MV_CTBUPRC e for .T. NÃO  executar com multi threads */
nNumProc := If( lProcCtb, 1, nNumProc)
// Inicializa as variaveis staticas da contabilização
If SuperGetMV( "MV_CTBCLSC" ,.F., .F. )
	ClearCx105()
Endif

// Inicia as variaveis staticas do fonte.
FinIniVar()

// Variaveis utilizadas na contabilizacao do modulo SigaFin
// declarada neste ponto, caso o acesso seja feito via SigaAdv

Debito  	:= ""
Credito 	:= ""
CustoD		:= ""
CustoC		:= ""
ItemD 		:= ""
ItemC 		:= ""
CLVLD		:= ""
CLVLC		:= ""

Conta		:= ""
Custo 		:= ""
Historico 	:= ""
ITEM		:= ""
CLVL		:= ""

Abatimento  := 0
REGVALOR    := 0
STRLCTPAD 	:= ""		//para contabilizar o historico do cheque
NUMCHEQUE 	:= ""		//para contabilizar o numero do cheque
ORIGCHEQ  	:= ""		//para contabilizar o Origem do cheque
cHist190La 	:= ""
VARIACAO	:= 0
VARIACAORA	:= 0
dDataUser	:= MsDate()
CODFORCP  	:= ""	//para contabilizar o Codigo do Fornecedor da Compensacao
LOJFORCP 	:= ""	//para contabilizar a Loja do Fornecedor da Compensacao

If !__lSchedule
	Pergunte("FIN370",.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o log de processamento                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogIni( aButtons )

AADD(aSays,STR0010) //"  Este programa tem como objetivo gerar Lan‡amentos Cont beis Off para t¡tulos"
AADD(aSays,STR0011) //"emitidos e/ou baixas efetuadas."
If lPanelFin  //Chamado pelo Painel Financeiro			
	aButtonTxt := {}			
	If Len(aButtons) > 0
		AADD(aButtonTxt,{STR0036,STR0036,aButtons[1][3]}) // Visualizar			
	Endif
	AADD(aButtonTxt,{STR0037,STR0037, {||Pergunte("FIN370",.T. )}}) // Parametros						
	FaMyFormBatch(aSays,aButtonTxt,{||nOpca :=1},{||nOpca:=0})	
ElseIf !lAutoMThrd .AND. !__lSchedule .AND. !lDireto        			
	tNewProcess():New( "CTBAFIN", cCadastro, bProcess, cDescription, "FIN370" )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÊ
//³Validação para multthread.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÊ
nNumProc := IIF(__lSchedule .OR. nNumProc < 1 , 1, nNumProc)

If nNumProc > 1 .And. (nOpcA == 1 .OR. lAutoMThrd)
	If CtbValMult(.T.,MV_PAR02 == 1,MV_PAR01 == 1,MV_PAR12 )
		nOpcA := 1
	Else
		nOpcA := 0
	EndIf
EndIf

If (__lSchedule .or. lDireto) .OR. nOpcA == 1

	If !CtbValiDt(,dDataBASE,,,,{"FIN001","FIN002"},)
		Return
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("INICIO")
	
	lMulti := nNumProc > 1 .And. CtbValMult(.F.,MV_PAR02 == 1,MV_PAR01 == 1,MV_PAR12 )
	
	If mv_par08 == 1      //Considera filiais abaixo? 1- Sim / 2 - Nao 
		cFilProcIni	:= mv_par09
		cFilProcFim := mv_par10		
		
		If mv_par14 == 1  //Considera Filial Original?  1- Sim, 2 - Não
			cFilProcIni	:= mv_par15
			cFilProcFim := mv_par16
		EndIf

		If lAutoMThrd .or. CTBCanProc(mv_par06, mv_par04, mv_par05,cFilProcIni,cFilProcFim)
			aKeyProc := {{'CCART',STR(mv_par06,1)},{'DTDE',DTOS(mv_par04)},{'DTATE',DTOS(mv_par05)},{'FILDE',cFilProcIni},{'FILATE',cFilProcFim}}
			If lMulti
				FWMsgRun(,{|| CTBMTFIN(mv_par06,nNumProc) },STR0063,STR0038) //"Contabilizando... - Processamento MultThread"
			ELSEIF (__lSchedule .or. lDireto) .AND. !lAutoMThrd
				BatchProcess(cCadastro,STR0010 + Chr(13)+Chr(10) + STR0011, "FIN370",{ || CTBFINProc(.T.) }, { || .F. })
			Else
				If _lCtbIniLan
					CtbIniLan()
				EndIf
				Processa({|lEnd| CTBFINProc()})  // Chamada da funcao de Contabilizacao Off-Line
				If FindFunction("CtbFinLan")
					CtbFinLan()
				EndIf
			EndIf
		EndIf
	Else
		If lAutoMThrd .or. CTBCanProc(mv_par06, mv_par04, mv_par05)
			aKeyProc := {{'CCART',STR(mv_par06,1)},{'DTDE',DTOS(mv_par04)},{'DTATE',DTOS(mv_par05)}}
			If lMulti
				FWMsgRun(,{|| CTBMTFIN(mv_par06,nNumProc) },STR0063,STR0038) //"Contabilizando... - Processamento MultThread"
			ELSEIF (__lSchedule .or. lDireto) .AND. !lAutoMThrd
				BatchProcess(cCadastro,STR0010 + Chr(13)+Chr(10) + STR0011, "FIN370",{ || CTBFINProc(.T.) }, { || .F. })
			Else
				If _lCtbIniLan
					CtbInilan()
				EndIf
				Processa({|lEnd| CTBFINProc()})  // Chamada da funcao de Contabilizacao Off-Line
				If FindFunction("CtbFinLan")
					CtbFinLan()
				EndIf
			EndIf
		EndIf
	EndIf
	
	//Libera o Processamento e envia mensagem no server (tempo)
	If !lAutoMThrd .and. !EMPTY(aKeyProc)
		CTBFreeProc(aKeyProc)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("FIM")

Endif

// Verifico se as áreas foram encerradas
For nX := 1 TO Len( __aFinAlias )
    CTBCloseArea(__aFinAlias[nX],.T.)
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O codigo abaixo eh utilizado nesse ponto para garantir que tanto o alias³
//³quanto o browse serao recriados sem problemas na utilizacao do painel   ³
//|financeiro quando a rotina nao eh chamada de forma semi-automatica pois | 
//|esse tratamento eh realizado na rotina T											|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPanelFin //Chamado pelo Painel Financeiro			
	dbSelectArea(FinWindow:cAliasFile)			
	ReCreateBrow(FinWindow:cAliasFile,FinWindow)      	
Endif
	
If lUsaLog
	aIncons := FA370TXT(cCaminho)
	If Len(aIncons) > 0
		If nTpLog == 1
			Aviso(STR0031,STR0052+cCaminho+"'.",{'OK'},2) //"Foram gravados registros de inconsistências na tabela SE5 nesta contabilização. Favor verificar os registros no arquivo 'Fina370Log.TXT', existente na pasta '"
		ElseIf nTpLog == 2	
			FA370Rel(aIncons) //Relatório de inconsistências.
		EndIf
	EndIF
EndIf

//--------------------------------------------
// Ponto de Entrada ao final do processamento
//   para processos complementares do usuario
//--------------------------------------------
If l370CTBUSR
	Execblock("F370CTBUSR",.F.,.F.)
EndIf		

Return
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CTBFINProc³ Autor ³ Wagner Xavier 	    ³ Data ³ 24/08/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Lan‡amentos Cont beis Off-Line				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINA370()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFIN													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBFINProc(lBat,lLerSE1,cAliasSE1,lLerSE2,cAliasSE2,lLerSEF,cAliasSEF,lLerSE5,cAliasSE5,lMultiThr,lLerSEU,cAliasSEU,lTrocoMT)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Vari veis 											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local lPadrao
	Local nTotal		:= 0
	Local nHdlPrv		:= 0
	Local cArquivo		:= ""
	Local cPadrao
	Local nValLiq		:= 0
	Local nDescont		:= 0
	Local nJuros		:= 0
	Local nMulta		:= 0
	Local nCorrec		:= 0
	Local nVl
	Local nDc
	Local nJr
	Local nMt
	Local lTitulo		:= .F.
	Local dDataAnt		:= dDataIni := dDataBase
	Local nPeriodos		:= 0
	Local nLaco   		:= 0
	Local cChave		:= ""
	Local nRegSE5		:= 0
	Local nRegOrigSE5	:= 0
	Local lX			:= .f.
	Local lAdiant 		:= .F.
	Local lEstorno 		:= .F.
	Local lEstRaNcc 	:= .F.
	Local lEstPaNdf 	:= .F.
	Local lEstCart2 	:= .F.
	Local nValorTotal 	:= 0
	Local cCondWhile	:= " "
	Local nRegAnt
	Local bCampo
	Local nOrderSEU
	Local cChaveSev
	Local cChaveSeZ
	Local nRecSe1
	Local nRecSe2
	Local cNumBor		:= ""
	Local cProxBor		:= ""
	Local cLstBor		:= ""
	LOCAL nPosBor       := 0
	Local nBordero		:= 0
	Local nTotBord		:= 0
	Local nBordDc		:= 0
	Local nBordJr  		:= 0
	Local nBordMt		:= 0
	Local nBordCm  		:= 0
	Local nTotDoc		:= 0
	Local nTotProc 		:= 0
	Local lPadraoCC
	Local lSkipLct 		:= .F.
	Local cSitOri  		:= " "
	Local cSitCob 		:= " "
	Local cSeqSE5 		:= ""
	Local lPadraoCCE
	Local cPadraoCC
	Local lMultNat 		:= .F.
	Local nRecSev
	Local nRecSez
	Local aFlagCTB 		:= {}
	Local nPis			:= 0
	Local nCofins  		:= 0
	Local nCsll	   		:= 0
	Local nVretPis 		:= 0
	Local nVretCof 		:= 0
	Local nVretCsl 		:= 0
	Local aRecsSE5 		:= {}
	Local nX 			:= 0
	Local nTamDoc		:= TamSX3("E5_PREFIXO")[1]+TamSX3("E5_NUMERO")[1]+TamSX3("E5_PARCELA")[1]+TamSX3("E5_TIPO")[1]
	Local nTamBor		:= TamSX3("EA_NUMBOR")[1]
	Local lMulNatSE2	:= .F.
	Local cProxChq		:= ""
	Local cChequeAtual	:= ""
	Local aStru			:= SE5->(DbStruct())
	Local cSepProv		:= If("|"$MVPROVIS,"|",",") 
	Local lEstCompens	:= .F.
	Local cSELSerie		:= ""
	Local cSELRecibo	:= ""
	Local lFindITF		:= FindFunction("FinProcITF") .and. cpaisloc <> "BRA"
	Local lQrySE1		:= .F.
	Local aRecsSEI	:= {}
	Local nJ := 0
	Local cMVSLDBXCR 	:= SuperGetMv("MV_SLDBXCR",.F.,.F.)	//Indica como sera controlado o saldo da baixa do contas a receber, somente quando o cheque for compensado, ou no momento da baixa (B,C)
	Local lCtMovPa		:= SuperGetMv("MV_CTMOVPA",.T.,"1") == "2" // Indica se a Contabiliza‡?o Offline do LP513 ocorrer  pelo T¡tulo(SE2) ou Mov.Bancario(SE5) do Pagamento Antecipado. 1="SE2" / 2="SE5"
	Local nRecMovPa		:= 0
	Local lPAMov		:= .F.
	Local lCtCheqLib    := SuperGetMv("MV_CTCHQBX",.T.,"1") == "2"	// Contabilizar na data da liberação
	Local cAliasTroc	:= ""
	Local lTroTemSE5	:= .F.

	//Variaveis para gravação do código de correlativo
	Local aDiario		:= {}

	// Quando processamento por MultiThread a função CTBMTFIN() é que controla as filiais e os registros
	// Portanto, aqui assumimos o ambiente estabelecido pela Thread em execução
	Local aSM0			:= IF(lMultiThr,{nil},AdmAbreSM0())	

	Local nContFil		:= 0
	Local __cFilAnt		:= cFilAnt
	Local nPosReg		:= 0
	Local dDataCtb		:= Nil // variavel de controle da contabilização.
	Local aAreaATU		:= {}
	Local aRecsTRF		:= {}
	Local aFils			:= {}
	Local lPass			:= .F.
	Local lAGP			:= .F.
	Local lMvAGP		:= SuperGetMv("MV_CTBAGP",.F.,.F.)
	Local lF370ChkAgp	:= FindFunction("F370ChkAgp")
	Local cNatTroc		:= Alltrim(IIf( cPaisLoc <> "BRA", SuperGetMV("MV_NATTROC"), GetNewPar("MV_NATTROC",'"TROCO"') ))
	LOCAL lGroupDoc		:= SUPERGETMV("MV_GPDOCTB",.F.,.F.)
	Local lQuebraDoc	:= .T.
	Local lBxCnab 		:= SuperGetMv("MV_BXCNAB",.T.,"N") == "S"
	Local lAvancaReg	:= .T.

	LOCAL aCT5			:= {}	// Cache de LPs - Construido pelo CTB - DETPROVA
	LOCAL cFilAntCT5    := xFilial('CT5')	// Variável de Controle para limpeza do Cache aCT5

	Local cUniao		:= SuperGetMv( "MV_UNIAO" )
	Local cMunic		:= SuperGetMv( "MV_MUNIC" )
	Local cOrdLCTB		:= Alltrim(SuperGetMv("MV_ORDLCTB"))
	//1 - Contabiliza por titulo ; 2 - contabiliza por venda (somente quando possuir integração)
	Local nCtbVenda		:= SuperGetMV("MV_CTBINTE",,1)
	Local lRACont		:= .F.
	Local lRAMov		:= .F.
	Local aAreaAux		:= NIL
	Local cLA			:= ""
	Local cChE5Comp		:= ""
	Local aAreaSE1		:= NIL
	Local aAreaSE2		:= NIL
	Local nVlDecresc	:= 0
	Local nVlAcresc		:= 0
	Local nRecProccess  := 0
	Local nRecSE5Ch		:= 0

	// Variaveis para contabilização dos juros informados na liquidação (FO1 e FO2)
	Local cNumLiq       := ""
	Local nRecFO2       := 0
	Local aDadosFO1     := {}
	Local lHasFilOrig	:= .F.
	Local cMvSimb1		:= SuperGetMV("MV_SIMB1",,"R$")						// Simbolo da moeda
	Local cTipoMov		:= ''
	Local lLoop			:= .F.
	Local cRecPag		:= ""
	Local nSkip			:= 0
	LOCAL dIniProc		:= CTOD('')
	LOCAL dFinProc		:= CTOD('')
	LOCAL cProcesso     := ''
	Local lExistFWI     := FwAliasInDic("FWI", .F.)
	LOCAL bGetMV        := {|PARMV|SuperGetMv(PARMV,SPACE(GetSX3Cache("E5_PREFIXO","X3_TAMANHO")))}
	LOCAL cNulo         := ''
	Local cCampo        := ''
	Local lLjFlTitRc 	:= ExistFunc("LjFilTitRc")
	LOCAL aLoteCNAB     := {}
	LOCAL nI            := 0
	LOCAL aSQLStatement  := {}
	LOCAL nRecSE5Atu	:= 0
	LOCAL aGetArea      := {}
	LOCAL bSumTRF       := NIL
	LOCAL cTamREC       := STRZERO(TAMSX3('E5_ORDREC')[1] + TAMSX3('E5_SERREC')[1],3)
	Local nE5PREFIXO    := TamSX3('E5_PREFIXO')[1]
	Local nE5NUMERO     := TamSx3('E5_NUMERO')[1]
	Local nE5PARCELA    := TamSx3('E5_PARCELA')[1]
	Local nE5TIPO       := TamSx3('E5_TIPO')[1]
	Local nE5CLIFOR     := TamSx3('E5_CLIFOR')[1]
	Local nE5LOJA       := TamSx3('E5_LOJA')[1]

	Private Inclui		:= .T.
	Private cLote		:= Space(4)
	Private nSaveSx8Len := GetSx8Len()
	Private cSeqCv4		:= ""

	// Registro de LOG de inconsistências
	PRIVATE nTpLog		:= IF(lMultiThr,1,SuperGetMv("MV_TIPOLOG",.T.,1))
	PRIVATE cPathLog	:= SuperGetMv("MV_DIRDOC")
	PRIVATE aIncons		:= {}

	DEFAULT lBat    	:= .F.
	DEFAULT lLerSE5 	:= .T.
	DEFAULT lLerSE1 	:= .T.
	DEFAULT lLerSE2 	:= .T.
	DEFAULT lLerSEF 	:= .T.
	DEFAULT lLerSEU  	:= .T.
	DEFAULT cAliasSE5	:= "SE5"
	DEFAULT cAliasSE2 	:= "SE2"
	DEFAULT cAliasSEF	:= "SEF"
	DEFAULT cAliasSE1	:= "SE1"
	DEFAULT cAliasSEU	:= "TRBSEU"
	DEFAULT lMultiThr	:= .F.
	DEFAULT lTrocoMT	:= .F.
	DEFAULT _cSGBD		:= Alltrim(Upper(TCGetDB()))
	DEFAULT _MSSQL7		:= _cSGBD $ "MSSQL7"

	IF SUBSTR(cPathLog,LEN(cPathLog),1) <> '\'
		cPathLog := cPathLog + '\'
		PUTMV('MV_DIRDOC',cPathLog)
	ENDIF

	// Processa SEF se existir ao menos um LP configurado.
	If lLerSEF
		lLerSEF := VldVerPad({'559','566','567','590'}) 
	EndIf

	// Inicia as variaveis staticas do fonte.
	FinIniVar()

	Do CASE
		CASE _cSGBD $ "ORACLE|INFORMIX|DB2"
			cNulo := "NVL"
		CASE _cSGBD $ "POSTGRES|MYSQL"
			cNulo := "COALESCE"
		OTHERWISE
			cNulo := "ISNULL"
	End CASE

	LoadPergunte()

	cSeqCv4 := GetSx8Num("CV4", "CV4_SEQUEN")

	IF Len( aSM0 ) <= 0
		Help(" ",1,"NOFILIAL")
		Return .F.
	Endif

	If TcSrvType() == "AS/400"
		HELP(" ",1,"USEFINA370")			
		Return .F.
	Endif	

	If __lMetric
		SetFunName(__cFunMet)

		// Metrica: Aglutina Lançamentos Contábeis
		cMetricDscr := IF(MV_PAR02 == 1,"CTBAFIN_AGLUTINA_SIM","CTBAFIN_AGLUTINA_NAO")
		FwCustomMetrics():setSumMetric(cMetricDscr, "financeiro-protheus_qtd-por-conteudo_total", 1)

		// Metrica: Contabiliza Emissões
		cMetricDscr := IF(MV_PAR03 == 1,"CTBAFIN_EMISSOES_DTEMISSAO","CTBAFIN_EMISSOES_DATABASE")
		FwCustomMetrics():setSumMetric(cMetricDscr, "financeiro-protheus_qtd-por-conteudo_total", 1)

		// Metrica: Contabiliza Baixas
		IF MV_PAR07 == 1
			cMetricDscr := "CTBAFIN_BAIXAS_DTBAIXA"
		ELSEIF MV_PAR07 == 2
			cMetricDscr := "CTBAFIN_BAIXAS_DTDIGIT"
		ELSEIF MV_PAR07 == 3
			cMetricDscr := "CTBAFIN_BAIXAS_DTDISPO"
		ENDIF
		FwCustomMetrics():setSumMetric(cMetricDscr, "financeiro-protheus_qtd-por-conteudo_total", 1)

		// Metrica: Separa por
		IF MV_PAR12 == 1
			cMetricDscr := "CTBAFIN_SEPARA_PERIODO"
		ELSEIF MV_PAR12 == 2
			cMetricDscr := "CTBAFIN_SEPARA_DOCUMENTO"
		ELSEIF MV_PAR12 == 3
			cMetricDscr := "CTBAFIN_SEPARA_PROCESSO"
		ENDIF
		FwCustomMetrics():setSumMetric(cMetricDscr, "financeiro-protheus_qtd-por-conteudo_total", 1)

		// Metrica: Contabiliza Borderô
		IF MV_PAR13 == 1
			cMetricDscr := "CTBAFIN_BORDERO_TOTAL"
		ELSEIF MV_PAR13 == 2
			cMetricDscr := "CTBAFIN_BORDERO_BORDERO"
		ENDIF
		FwCustomMetrics():setSumMetric(cMetricDscr, "financeiro-protheus_qtd-por-conteudo_total", 1)

		SetFunName(__cFunBkp)
	Endif

	cFilDe  := cFilAnt
	cFilAte := cFilAnt

	If mv_par08 == 1
		cFilDe := mv_par09
		cFilAte:= mv_par10
	Endif

	If FindFunction("F370Fil")
		aGetArea := GetArea()
		aFils := F370Fil(mv_par09,mv_par10) // Retorna filiais que o usuario tem acesso
		RestArea(aGetArea)
		aSize(aGetArea,0)
		aGetArea := nil 
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros						 ³
	//³ mv_par01 // Mostra Lan‡amentos Cont beis 					 ³
	//³ mv_par02 // Aglutina Lan‡amentos Cont beis					 ³
	//³ mv_par03 // Emissao / Data Base 							 ³
	//³ mv_par04 // Data Inicio										 ³
	//³ mv_par05 // Data Fim										 ³
	//³ mv_par06 // Carteira : Receber / Pagar /Cheque / Ambas 		 ³
	//³ mv_par07 // Baixas por Data de Emiss„o ou Digita‡„o			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	IF lMultiThr
		cProcesso := IF(lLerSE1,'SE1',IF(lLerSE2,'SE2',IF(lLerSE5,'SE5',IF(lLerSEF,'SEF',IF(lLerSEU,'SEU',IF(lTrocoMT,'TROCO',''))))))
		CTBConout('['+PROCNAME()+']:[PROCESSANDO: '+cProcesso+']:FILIAL:['+cFilAnt+']:['+DTOS(DATE())+']:['+TIME()+']:THREAD START:['+alltrim(str(ThreadID()))+']')
	ENDIF

	For nContFil := 1 to Len(aSM0)
		
		// ---------------------------------------------------------------------------------------------------------------------------
		// Quando processamento por MultiThread a função CTBMTFIN() é que controla as filiais e os registros.
		// Portanto, aqui assumimos o ambiente estabelecido pela Thread em execução
		// ---------------------------------------------------------------------------------------------------------------------------
		IF !lMultiThr
			If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt  
				Loop
			EndIf
			If MV_PAR14 == 1
				If aSM0[nContFil][SM0_CODFIL] < MV_PAR15 .Or. aSM0[nContFil][SM0_CODFIL] > MV_PAR16
					Loop
				EndIf
			Endif
			
			cFilAnt := aSM0[nContFil][SM0_CODFIL]
			// Limpa Cache de LPs
			IF !EMPTY(aCT5) .AND. (cFilAntCT5 <> xFilial('CT5'))
				cFilAntCT5 := xFilial('CT5')
				LimpaArray(aCT5)
			ENDIF
		ENDIF
		// ---------------------------------------------------------------------------------------------------------------------------
		
		If !Empty(aFils) 
			If Ascan(aFils,{|x| Alltrim(x) == Alltrim(cFilAnt)}) == 0 
				Loop
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a SumAbatRec para abrir alias auxiliar __SE1 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Select("__SE1") == 0
			SumAbatRec("","","",1,"")
		Endif	
		
		If lLerSe5
			// Verifica qual a data a ser utilizada para baixa --------------------------------
			cCampo := IIF(mv_par07 == 1,"E5_DATA",Iif(mv_par07 == 2,"E5_DTDIGIT","E5_DTDISPO"))

			LimpaArray(aRecsSE5)
			lHasFilOrig := .F.

			//Query para contabilização do troco pela FK5 - Se for multithread, a princípio só chama na primeira thread - Rever quando o fonte estiver olhando apenas para as FKs
			If (mv_par06 == 2 .or. mv_par06 == 4) .And. (!lMultiThr .Or. lTrocoMT)
				cAliasTroc := IF(!EMPTY(__lHasLoja),QueryTroco( cFilAnt, mv_par04, mv_par05 ),'')
			EndIf
			
			If lMultiThr
				(cAliasSE5)->(dbGoTop())
			Else
				cQuery := ""
				
				DbSelectArea("SE5")
				aStru  := SE5->(DBSTRUCT())

				// CLÁUSULA SELECT - Campos de retorno da Consulta --------------------------------------------
				AADD(aSQLStatement,"SELECT ")
				AEVAL(aStru, { |e,i| ATAIL(aSQLStatement) += IF(i==1,"SE5.",",SE5." ) + AllTrim(e[1])} )
				IF mv_par07 == 2
					ATAIL(aSQLStatement) := STRTRAN( ATAIL(aSQLStatement), "SE5.E5_DTDIGIT", "CASE WHEN SE5.E5_TIPODOC IN ('TR','TE') THEN SE5.E5_DATA ELSE SE5.E5_DTDIGIT END E5_DTDIGIT" )
				ELSEIF mv_par07 == 3
					ATAIL(aSQLStatement) := STRTRAN( ATAIL(aSQLStatement), "SE5.E5_DTDISPO", "CASE WHEN SE5.E5_TIPODOC IN ('TR','TE') THEN SE5.E5_DATA ELSE SE5.E5_DTDISPO END E5_DTDISPO" )
				ENDIF
				ATAIL(aSQLStatement) += "," + cNulo + "(FKA.FKA_IDPROC,' ') FKA_IDPROC,SE5.R_E_C_N_O_ SE5RECNO,"
				ATAIL(aSQLStatement) += "CASE WHEN "+ cNulo + "(MPA.R_E_C_N_O_,0) > 0 THEN MPA.R_E_C_N_O_ "
				ATAIL(aSQLStatement) += "WHEN "+ cNulo + "(MPAES.R_E_C_N_O_,0) > 0 THEN MPAES.R_E_C_N_O_ "
				ATAIL(aSQLStatement) += "ELSE 0 END RECNOPA "

				// CLÁUSULA FROM - Tabela base da Consulta e ligações -----------------------------------------
				AADD(aSQLStatement,"FROM ")
				ATAIL(aSQLStatement) += RetSqlName("SE5") + " SE5 "

				// CLÁUSULA JOIN - Ligação FKA - Retorna Identificador do Processo - Campo FKA_IDPROC ---------
				AADD(aSQLStatement,"LEFT JOIN ")
				ATAIL(aSQLStatement) += RetSqlName("FKA") + " FKA "
				ATAIL(aSQLStatement) += "ON FKA.FKA_FILIAL = SE5.E5_FILIAL AND FKA.FKA_TABORI = SE5.E5_TABORI AND FKA.FKA_IDORIG = SE5.E5_IDORIG AND FKA.D_E_L_E_T_ = ' ' "

				// CLÁUSULA JOIN Ligação SE5 - Retorna RECNO das compensações a pagar/receber (PA/RA/NDF/NCC) - COLUNA RECNOPA ------
				AADD(aSQLStatement,"LEFT JOIN ")
				ATAIL(aSQLStatement) += RetSqlName("SE5") + " MPA "
				ATAIL(aSQLStatement) += "ON MPA.E5_FILIAL = SE5.E5_FILIAL AND MPA.E5_DATA = SE5.E5_DATA AND "
				//Filtra E5_DOCUMEN p/ compensações a pagar (prefixo+numero+parcela+tipo+fornecedor+loja)
				ATAIL(aSQLStatement) += " ((MPA.E5_PREFIXO   = SUBSTR(SE5.E5_DOCUMEN,1,"+cValToChar(nE5PREFIXO)+")"
				ATAIL(aSQLStatement) += " AND MPA.E5_NUMERO  = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO)+","+cValToChar(nE5NUMERO)+")"
				ATAIL(aSQLStatement) += " AND MPA.E5_PARCELA = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO)+","+cValToChar(nE5PARCELA)+")"
				ATAIL(aSQLStatement) += " AND MPA.E5_TIPO    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA)+","+cValToChar(nE5TIPO)+")"
				ATAIL(aSQLStatement) += " AND MPA.E5_CLIFOR  = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA+nE5TIPO)+","+cValToChar(nE5CLIFOR)+")"
				ATAIL(aSQLStatement) += " AND MPA.E5_LOJA    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA+nE5TIPO+nE5CLIFOR)+","+cValToChar(nE5LOJA)+")"
				ATAIL(aSQLStatement) += " ) OR "
				//Filtra E5_DOCUMEN p/ compensações a receber (prefixo+numero+parcela+tipo+loja)
				ATAIL(aSQLStatement) += " (MPA.E5_PREFIXO    = SUBSTR(SE5.E5_DOCUMEN,1,"+cValToChar(nE5PREFIXO)+")"
				ATAIL(aSQLStatement) += " AND MPA.E5_NUMERO  = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO)+","+cValToChar(nE5NUMERO)+")"
				ATAIL(aSQLStatement) += " AND MPA.E5_PARCELA = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO)+","+cValToChar(nE5PARCELA)+")"
				ATAIL(aSQLStatement) += " AND MPA.E5_TIPO    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA)+","+cValToChar(nE5TIPO)+")"
				ATAIL(aSQLStatement) += " AND MPA.E5_LOJA    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA+nE5TIPO)+","+cValToChar(nE5LOJA)+"))) "
				//Filtros em comum entre compensacoes pagar/receber
				ATAIL(aSQLStatement) += " AND MPA.E5_SEQ = SE5.E5_SEQ AND MPA.E5_MOTBX = SE5.E5_MOTBX AND MPA.E5_MOTBX = 'CMP' "
				ATAIL(aSQLStatement) += " AND MPA.E5_TIPODOC  IN ('CP','BA') AND SE5.E5_TIPODOC  IN ('CP','BA') "
				ATAIL(aSQLStatement) += " AND MPA.D_E_L_E_T_ = ' '"

				// CLÁUSULA JOIN Ligação SE5 - Retorna RECNO dos estornos de compensações a pagar/receber (PA/RA/NDF/NCC) - COLUNA RECNOPA ------
				AADD(aSQLStatement,"LEFT JOIN ")
				ATAIL(aSQLStatement) += RetSqlName("SE5") + " MPAES "
				ATAIL(aSQLStatement) += "ON MPAES.E5_FILIAL    = SE5.E5_FILIAL AND MPAES.E5_DATA = SE5.E5_DATA AND "
				//Filtra E5_DOCUMEN p/ compensações a pagar (prefixo+numero+parcela+tipo+fornecedor+loja)
				ATAIL(aSQLStatement) += " ((MPAES.E5_PREFIXO   = SUBSTR(SE5.E5_DOCUMEN,1,"+cValToChar(nE5PREFIXO)+")"
				ATAIL(aSQLStatement) += " AND MPAES.E5_NUMERO  = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO)+","+cValToChar(nE5NUMERO)+")"
				ATAIL(aSQLStatement) += " AND MPAES.E5_PARCELA = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO)+","+cValToChar(nE5PARCELA)+")"
				ATAIL(aSQLStatement) += " AND MPAES.E5_TIPO    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA)+","+cValToChar(nE5TIPO)+")"
				ATAIL(aSQLStatement) += " AND MPAES.E5_CLIFOR  = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA+nE5TIPO)+","+cValToChar(nE5CLIFOR)+")"
				ATAIL(aSQLStatement) += " AND MPAES.E5_LOJA    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA+nE5TIPO+nE5CLIFOR)+","+cValToChar(nE5LOJA)+")"
				ATAIL(aSQLStatement) += " ) OR "
				//Filtra E5_DOCUMEN p/ compensações a receber (prefixo+numero+parcela+tipo+loja)
				ATAIL(aSQLStatement) += " (MPAES.E5_PREFIXO    = SUBSTR(SE5.E5_DOCUMEN,1,"+cValToChar(nE5PREFIXO)+")"
				ATAIL(aSQLStatement) += " AND MPAES.E5_NUMERO  = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO)+","+cValToChar(nE5NUMERO)+")"
				ATAIL(aSQLStatement) += " AND MPAES.E5_PARCELA = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO)+","+cValToChar(nE5PARCELA)+")"
				ATAIL(aSQLStatement) += " AND MPAES.E5_TIPO    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA)+","+cValToChar(nE5TIPO)+")"
				ATAIL(aSQLStatement) += " AND MPAES.E5_LOJA    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA+nE5TIPO)+","+cValToChar(nE5LOJA)+"))) "
				//Filtros em comum entre compensacoes pagar/receber
				ATAIL(aSQLStatement) += " AND MPAES.E5_SEQ     = SE5.E5_SEQ AND MPAES.E5_MOTBX = SE5.E5_MOTBX AND MPAES.E5_MOTBX = 'CMP' "
				ATAIL(aSQLStatement) += " AND MPAES.E5_TIPODOC  = SE5.E5_TIPODOC AND MPAES.E5_TIPODOC = 'ES' "
				ATAIL(aSQLStatement) += " AND MPAES.D_E_L_E_T_ = ' '"

				// CLÁUSULA WHERE - Filtros da Consulta -------------------------------------------------------
				AADD(aSQLStatement,"WHERE ")
				IF ((MV_PAR14 == 1) .AND. (cFilAnt >= MV_PAR15) .AND. (cFilAnt <= MV_PAR16))
					If lPosE5MsFil .AND. !lUsaFilOri
						ATAIL(aSQLStatement) += "SE5.E5_MSFIL = '"  + cFilAnt + "' AND "
					Else
						ATAIL(aSQLStatement) += "SE5.E5_FILORIG = '"  + cFilAnt + "' AND "
						lHasFilOrig := .T.
					Endif
				Else
					ATAIL(aSQLStatement) += "SE5.E5_FILIAL = '" + xFilial("SE5") + "' AND "
				EndIf

				IF MV_PAR07 == 1
						ATAIL(aSQLStatement) += "SE5.E5_DATA BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "
						ATAIL(aSQLStatement) += "SE5.E5_TIPODOC IN ('DH','PA','RA','BA','VL','V2','AP','EP','PE','RF','IF','CP','TL','ES','TR','DB','OD','LJ','E2','TE','  ','IT') AND "
				ELSEIF MV_PAR07 == 2 //Contabiliza Baixas pela Data de Digitação
						ATAIL(aSQLStatement) += "((SE5.E5_DTDIGIT BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "
						ATAIL(aSQLStatement) += "SE5.E5_TIPODOC IN ('DH','PA','RA','BA','VL','V2','AP','EP','PE','RF','IF','CP','TL','ES','TR','DB','OD','LJ','E2','TE','  ','IT')) OR "
						ATAIL(aSQLStatement) += "(SE5.E5_DATA BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "
						ATAIL(aSQLStatement) += "SE5.E5_TIPODOC IN ('TR','TE'))) AND "
				ELSEIF MV_PAR07 == 3 //Contabiliza Baixas pela Data de Disponibilidade
						ATAIL(aSQLStatement) += "((SE5.E5_DTDISPO BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "
						ATAIL(aSQLStatement) += "SE5.E5_TIPODOC IN ('DH','PA','RA','BA','VL','V2','AP','EP','PE','RF','IF','CP','TL','ES','TR','DB','OD','LJ','E2','TE','  ','IT')) OR "
						ATAIL(aSQLStatement) += "(SE5.E5_DATA BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "
						ATAIL(aSQLStatement) += "SE5.E5_TIPODOC IN ('TR','TE'))) AND "
				ENDIF
				ATAIL(aSQLStatement) += "SE5.E5_SITUACA <> 'C' AND "
				ATAIL(aSQLStatement) += "(SE5.E5_LA <> 'S ' OR (CAST(SE5.E5_ORDREC " + _cOperador + " SE5.E5_SERREC AS CHAR(" + cTamREC + ")) <> '' AND SE5.E5_RECPAG = 'R' AND SE5.E5_TIPODOC = 'BA')) AND "

				// PONTO DE NETRADA - F370E5MBX - filtrar E5_MOTBX.
				aMotBX := {'DSD'}
				IF lF370E5MBX
					aMotBX := Execblock("F370E5MBX",.F.,.F.,aMotBX)
				ENDIF
				cMotBX := FormatIn( UPPER( ALLTRIM( ArrayToStr( aMotBX ) ) ), ";" )
				ATAIL(aSQLStatement) += "SE5.E5_MOTBX NOT IN " + cMotBX + " AND " 

				IF cPaisLoc == "RUS"
					ATAIL(aSQLStatement) += " SE5.E5_ORIGEM <> '"+PADR("RU06D07",GetSX3Cache("E5_ORIGEM","X3_TAMANHO")," ")+"' AND "
					ATAIL(aSQLStatement) += " NOT ( SE5.E5_TIPO = 'PA' AND SE5.E5_ORIGEM = ' ' AND SE5.E5_TIPODOC = 'BA' AND SE5.E5_PREFIXO = '" + PADR(EVAL(bGetMV,"MV_BSTPRE"),GetSX3Cache("E5_PREFIXO","X3_TAMANHO")," ") + "' AND SE5.E5_MOVFKS = 'N' AND SE5.E5_IDORIG = ' '  AND SE5.E5_TABORI = ' ' ) AND "
				ENDIF
				ATAIL(aSQLStatement) += "SE5.D_E_L_E_T_ = ' ' "

				// PONTIO DE ENTRADA - F370E5F - alterar/complementar filtro de registros WHERE.
				IF l370E5FIL
					cQuery := ""
					AEVAL(aSQLStatement,{ |e| cQuery += e})
					LimpaArray(aSQLStatement)

					cQuery := Execblock("F370E5F",.F.,.F.,cQuery)
					AADD(aSQLStatement,SUBSTR(cQuery, 1, AT("FROM",cQuery)-1))
					AADD(aSQLStatement,SUBSTR(cQuery, AT("FROM",cQuery),AT("WHERE",cQuery)-1-LEN(ATAIL(aSQLStatement))))
					AADD(aSQLStatement,SUBSTR(cQuery, AT("WHERE",cQuery)))
				ENDIF

				// CLÁUSULA ORDER BY - Sequencia de ordenação da Consulta -------------------------------------
				AADD(aSQLStatement,"")
				ATAIL(aSQLStatement) += "E5_FILIAL,E5_DATA,E5_RECPAG,E5_NUMCHEQ,E5_DOCUMEN,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_TIPO,E5_CLIFOR,E5_LOJA,E5_SEQ"
				IF mv_par12 <> MVP12DOCUMENTO .And. cOrdLCTB == "E"
					ATAIL(aSQLStatement) += ",SE5RECNO"
				ENDIF
				IF lHasFilOrig .AND. !EMPTY(ATAIL(aSQLStatement))
					ATAIL(aSQLStatement) := STRTRAN(ATAIL(aSQLStatement),'E5_FILIAL','E5_FILORIG')
				ENDIF
				IF MV_PAR07 == 2 //Contabiliza Baixas pela Data de Digitação
					ATAIL(aSQLStatement) := STRTRAN(ATAIL(aSQLStatement),"E5_DATA","E5_DTDIGIT")
				ELSEIF MV_PAR07 == 3 //Contabiliza Baixas pela Data de Disponibilidade
					ATAIL(aSQLStatement) := STRTRAN(ATAIL(aSQLStatement),"E5_DATA","E5_DTDISPO")
				ENDIF
				
				// PONTO DE ENTRADA - F370E5K - alterar ordenacao da consulta
				If l370E5KEY
					ATAIL(aSQLStatement) := Execblock("F370E5K",.F.,.F.,ATAIL(aSQLStatement))
				EndIf
				
				// seta a ordem de acordo com a opcao do usuario
				IF MV_PAR12 == MVP12DOCUMENTO
					ATAIL(aSQLStatement) := STRTRAN(ATAIL(aSQLStatement),"E5_DOCUMEN+","E5_DOCUMEN+SE5.R_E_C_N_O_+")
				ENDIF
				ATAIL(aSQLStatement) := "ORDER BY " + SqlOrder(ATAIL(aSQLStatement))

				cQuery := ""
				AEVAL(aSQLStatement,{ |e| cQuery += e})
				LimpaArray(aSQLStatement)

				If _MSSQL7
					cQuery := StrTran(cQuery,'SUBSTR(','SUBSTRING(')
				EndIf 

				cQuery := ChangeQuery(cQuery)
				
				CTBConout('['+PROCNAME()+']:[Criação de tabela temporária: ['+cQuery+']')
				
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), FINNextAlias(@cAliasSE5) , .F., .T.)
		
				CTBTCSetField(aStru, cAliasSE5)

				DbGoTop()
			EndIf
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Contabiliza pelo E2_EMIS1 - CONTAS PAGAR   			³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (mv_par06 = 2 .Or. mv_par06 = 4) .and. lLerSe2

			If lMultiThr
				(cAliasSE2)->(dbGoTop())
			Else
				dbSelectArea("SE2")
				cChave := "E2_FILIAL+DTOS(E2_EMIS1)+E2_NUMBOR+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA"

				aStru := SE2->(DbStruct())
				cQuery := ""

				// Obtem os registros a serem processados 
				cQuery := "SELECT E2_FILIAL,E2_EMIS1,E2_NUMBOR,E2_PREFIXO,E2_NUM,E2_PARCELA,"
				cQuery += " E2_TIPO,E2_FORNECE,E2_LOJA, E2_TITPAI, E2_ORIGEM,"
				cQuery += " SE2.R_E_C_N_O_ SE2RECNO "
				cQuery += "  FROM " + RetSqlName("SE2") + " SE2 "

				IF ((MV_PAR14 == 1) .AND. (cFilAnt >= MV_PAR15) .AND. (cFilAnt <= MV_PAR16))							
					If lPosE2MsFil .AND. !lUsaFilOri
						cQuery += "WHERE E2_MSFIL = '"  + cFilAnt + "' AND "
					Else
						cQuery += "WHERE E2_FILORIG = '"  + cFilAnt + "' AND "
					Endif				
				Else
					cQuery += "WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND "
				EndIf

				cQuery += "E2_EMIS1 BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "
				
				// Soh adiciona filtro na query se nao contabiliza titulos provisorios
				If mv_par17 <> 1
					cQuery += "E2_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
				EndIf
				
				cQuery += "E2_STATUS <> 'D' AND "	// Título base de desdobramento - Contabilizar pelas parcelas
				cQuery += "E2_LA <> 'S' AND E2_ORIGEM <> 'FINA677' AND "
				If cPaisLoc == "RUS"
					cQuery += " E2_ORIGEM <> '"+PADR("RU06D07",GetSX3Cache("E2_ORIGEM","X3_TAMANHO")," ")+"' AND "
				EndIf
				cQuery += "D_E_L_E_T_ = ' ' "
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de Entrada para filtrar registros do SE2. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If l370E2FIL
					cQuery := Execblock("F370E2F",.F.,.F.,cQuery)
				EndIf
				
				// seta a ordem de acordo com a opcao do usuario
				cQuery += " ORDER BY " + SqlOrder(cChave)

				cQuery := ChangeQuery(cQuery)

				CTBConout('['+PROCNAME()+']:[Criação de tabela temporária: ['+cQuery+']')

				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), FINNextAlias(@cAliasSE2), .F., .T.)
				
				CTBTCSetField(aStru, cAliasSE2)

				DbGoTop()
			EndIf
		Endif
		
		//SEF
		If (mv_par06 = 3 .Or. mv_par06 = 4 ) .and. lLerSef
			If lMultiThr
				// A Thread já enviou a tabela filtrada.
				// Apenas posicionar no inicio.
				(cAliasSEF)->(dbGoTop())
			Else
				cAliasSEF := CtbGrvCheq("EF_FILIAL+DTLIB+EF_BANCO+EF_AGENCIA+EF_CONTA")
			EndIf
		EndIf
		
		// Laço da contabilização dia a dia - pela emissão (mv_par03 = 1) ou pela database (mv_par03 = 2)
		If MV_PAR03 == MVP03EMISSAO
			nPeriodos := mv_par05 - mv_par04 + 1 // Data Final - Data inicial
			nPeriodos := Iif( nPeriodos == 0, 1, nPeriodos )
		Else
			nPeriodos := 1
		Endif
		
		dDataIni := mv_par04
		
		If ! lBat
			ProcRegua(nPeriodos)
		Endif
		PulseLife() //- Pulso de vida da conexão
		For nLaco := 1 to nPeriodos
			If ! lBat
				IncProc()
			Endif
			PulseLife() //- Pulso de vida da conexão
			dbSelectArea( "SE1" )
			
			nTotal     := 0
			nHdlPrv    := 0
			lCabecalho := .F.
			STRLCTPAD  := ""
			__dDataCtb := Nil
			// Se a contabilização for pela data de emissão, altera o valor
			// da data-base e dos parâmetros, para efetuar a contabilização
			// e a seleção dos registros respectivamente.
			IF MV_PAR03 == MVP03EMISSAO
				dDataCtb := dDataIni + nLaco - 1

				dIniProc := dDataCtb
				dFinProc := dDataCtb

				// Forço a alteração do database para o periodo que estou contabilizando
				dDataBase := dDataCtb
			ELSE
				dIniProc := mv_par04
				dFinProc := mv_par05
			ENDIF
			
			If cPaisLoc == "RUS"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Run outflow bank statement automatic offline accounting Posting ³
				//³ for Russia                                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RU06XFUN52_CTBF4C(mv_par01,dIniProc,dFinProc)
			EndIf
			// Verifica o Numero do Lote - SX5 Tabela 09 Chave FIN
			cLote := LoteCont("FIN")
			
			If (mv_par06 == 1 .or. mv_par06 == 4) .and. lLerSe1
				// Contas a Receber - SE1
				If lMultiThr
					dbSelectArea( cAliasSE1 )
					If MV_PAR03 <> MVP03EMISSAO
						cCondWhile:= "'"+xFilial("SE1")+"' == "+cAliasSE1+"->E1_FILIAL .And. ( "+cAliasSE1+"->E1_EMISSAO >= dIniProc .And. "+cAliasSE1+"->E1_EMISSAO <= dFinProc )"
					Else
						cCondWhile:= "'"+xFilial("SE1")+"' == "+cAliasSE1+"->E1_FILIAL .And. "+cAliasSE1+"->E1_EMISSAO == dIniProc"
					Endif
				Else
					dbSelectArea("SE1")
					lQrySE1	:= .T.

					cChave := "E1_FILIAL+E1_EMISSAO+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA"

					// Obtem os registros a serem processados
					cQuery := "SELECT E1_FILIAL,E1_EMISSAO,E1_NOMCLI,E1_PREFIXO,E1_NUM,E1_PARCELA"
					cQuery += "     , SE1.R_E_C_N_O_ SE1RECNO "
					cQuery += "  FROM " + RetSqlName("SE1") + " SE1 "

					// Filtro das filiais
					IF ((MV_PAR14 == 1) .AND. (cFilAnt >= MV_PAR15) .AND. (cFilAnt <= MV_PAR16))											
						If lPosE1MsFil .AND. !lUsaFilOri
						cQuery += " WHERE E1_MSFIL = '" + cFilAnt + "'"
					Else
							cQuery += " WHERE E1_FILORIG = '" + cFilAnt + "'"
						Endif												
					Else
						cQuery += " WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
					EndIf
					
					cQuery += "  AND E1_EMISSAO BETWEEN '" + DTOS(dIniProc) + "' AND '" + DTOS(dFinProc) + "'"

					cQuery += "  AND E1_LA <> 'S' AND E1_ORIGEM <> 'FINA677' "

					If nCtbVenda == 2 //Contabilização por venda
						cQuery += " AND E1_ORIGEM <> 'FINI055'"
					Endif
					
					cQuery += "  AND D_E_L_E_T_ = ' ' "

					// Ponto de Entrada para filtrar registros do SE1.
					If l370E1FIL
						cQuery := Execblock("F370E1F",.F.,.F.,cQuery)
					EndIf
					
					// seta a ordem de acordo com a opcao do usuario
					cQuery += " ORDER BY " + SqlOrder(cChave)
					
					cQuery := ChangeQuery(cQuery)
					
					CTBConout('['+PROCNAME()+']:[Criação de tabela temporária: ['+cQuery+']')

					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), FINNextAlias(@cAliasSE1), .F., .T.)

					If lQrySE1
						If Select( cAliasSE1 ) == 0
							UserException( 'ERRO NA BUSCA DOS DADOS DA SE1' )
							Final()
						Endif
					Else
						cAliasSE1 := "SE1"
						
						dbSelectArea( cAliasSE1 )
						(cAliasSE1)->(dbSetOrder(6))
						(cAliasSE1)->(dbSeek(xFilial('SE1')+Dtos(dIniProc),.T. ))
					Endif

					If lF370E1WH
						cCondWhile:= Execblock("F370E1W",.F.,.F.)
					Else
						cCondWhile:= " .T. "
					EndIf
				EndIf
				
				DbSelectArea(cAliasSE1)
				While (cAliasSE1)->(!Eof()) .And. &cCondWhile
					PulseLife() //- Pulso de vida da conexão
					If ( cAliasSE1 <> "SE1" )
						SE1->(dbGoto( (cAliasSE1)->SE1RECNO ) )
					EndIf
					
					// Confirma a seleção do titulo para contabilização
					If l370E1LGC .And. ( cAliasSE1 == "SE1" )
						If !Execblock("F370E1L",.F.,.F.)
							(cAliasSE1)->(dbSkip())
							Loop
						EndIf
					EndIf
					
					cPadrao := "500"

					// Desdobramento
					If SE1->E1_DESDOBR == "1" // 1-Sim | 2-Não
						cPadrao := "504"
					EndIf
					
					dDataCtb := IF(MV_PAR03 == MVP03EMISSAO, SE1->E1_EMISSAO, dDataBase)
					
					// Verifica se será gerado Lançamento Contábil
					If SE1->E1_LA == "S" .Or. (SE1->E1_TIPO $ MVPROVIS .And. mv_par17 <> 1)
						(cAliasSE1)->( dbSkip())
						Loop
					Endif
					
					// Posiciona no cliente
					SearchFor('SA1',1,xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA))
					
					// Posiciona na natureza
					SearchFor('SED',1,xFilial('SED')+SE1->E1_NATUREZ)
					
					// Posiciona na SE5,se RA
					lRAMov := .F.
					If SE1->E1_TIPO $ MVRECANT
						SearchFor('SE5',2,xFilial('SE5')+"RA"+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DtoS(E1_EMISSAO)+E1_CLIENTE+E1_LOJA))
						IF SE5->(EOF())
							SearchFor('SE5',2,xFilial('SE5')+"CH"+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DtoS(E1_EMISSAO)+E1_CLIENTE+E1_LOJA))
						ENDIF
						lRAMov := !SE5->(EOF())

						SE5->(dbSetOrder(1))
					Endif
					
					// Posiciona no banco
					SearchFor('SA6',1,xFilial('SA6')+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA))
					// Se for um recebimento antecipado e nao encontrou o banco
					// pelo SE1, pesquisa pelo SE5.
					IF SE1->E1_TIPO $ MVRECANT
						If SA6->(Eof())
							SearchFor('SA6',1,xFilial('SA6')+SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA))
						Endif
						cPadrao:="501"
					Endif
					
					lPadrao := VerPadrao(cPadrao)
					
					If lPadrao 
						If !lCabecalho
							a370Cabecalho(@nHdlPrv,@cArquivo)
						Endif
						nRecSe1 := SE1->(Recno())
						
						// Se utiliza multiplas naturezas, contabiliza pelo SEV
						If  SE1->E1_MULTNAT == "1" .AND. !EMPTY(cChaveSev := RetChaveSev("SE1")) .And. SearchFor('SEV',4,cChaveSev+'R')
							cChaveSez := RetChaveSev("SE1",,"SEZ")
							nRecSe1 := SE1->(Recno())

							DbSelectArea("SEV")
							While SEV->(!Eof()) .AND.;
									xFilial("SEV")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_IDENT) == cChaveSev+"1"
								PulseLife() //- Pulso de vida da conexão
								If SEV->EV_LA != "S"
									// Posiciona na natureza, pois a conta pode estar la.
									SearchFor('SED',1,xFilial("SED")+SEV->EV_NATUREZ)
									If (SEV->EV_RATEICC == "1") .and. (lPadraoCc := VerPadrao("506"))	// Rateou multinat por c.custo
										If lUsaFlag
											aAdd(aFlagCTB,{"EV_LA","S","SEV",SEV->(Recno()),0,0,0})
										EndIf

										// Posiciona no arquivo de Rateio C.Custo da MultiNat
										SearchFor('SEZ',4,cChaveSeZ+SEV->EV_NATUREZ)
										While SEZ->(!Eof()) .and.;
												xFilial("SEZ")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+;
												EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT) == cChaveSeZ+SEV->EV_NATUREZ+"1"
											
											If SEZ->EZ_LA != "S"
												If lUsaFlag
													aAdd(aFlagCTB,{"EZ_LA","S","SEZ",SEZ->(Recno()),0,0,0})
												EndIf

												nTotDoc	+=	DetProva(nHdlPrv,"506","FINA370",cLote,,,,,,aCT5,,@aFlagCTB)

												If LanceiCtb // Vem do DetProva
													If !lUsaFlag
														RecLock("SEZ")
														SEZ->EZ_LA    := "S"
														SEZ->(MsUnlock())
													EndIf
												ElseIf lUsaFlag
													If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == SEZ->(Recno()) }))>0
														aFlagCTB := Adel(aFlagCTB,nPosReg)
														aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
													Endif
												EndIf
											Endif
											SEZ->(dbSkip())
										Enddo
									Else
										If lUsaFlag
											aAdd(aFlagCTB,{"EV_LA","S","SEV",SEV->(Recno()),0,0,0})
										EndIf
										nTotDoc	:= DetProva(nHdlPrv,cPadrao,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB,{"SEV",SEV->(Recno())})
									Endif
									
									If LanceiCtb // Vem do DetProva
										If !lUsaFlag	
											RecLock("SEV")
											SEV->EV_LA := "S"
											SEV->(MsUnlock())
										EndIf
									ElseIf lUsaFlag
										If (nPosReg := aScan(aFlagCTB,{ |x| x[4] == SEV->(Recno()) }))>0
											aFlagCTB := Adel(aFlagCTB,nPosReg)
											aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
										Endif
									Endif
								Endif

								DbSelectArea("SEV")
								SEV->(DbSkip())
							Enddo
							nTotal  	+=	nTotDoc
							nTotProc	+=	nTotDoc // Totaliza por processo

							If !lCabecalho
								a370Cabecalho(@nHdlPrv,@cArquivo)
							Endif
							nRecSev := SEV->(Recno())
							nRecSez := SEZ->(Recno())
							SEV->(DBGOTO(0))
							SEZ->(DBGOTO(0))

							nTotDoc	+=	DetProva(nHdlPrv,"506","FINA370",cLote,,,,,,aCT5,,@aFlagCTB)

							If MV_PAR12 == MVP12DOCUMENTO 
								IF nTotDoc > 0 // Por documento
									Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataCtb)
									nTotDoc := 0
								Endif
								LimpaArray(aFlagCTB)
							Endif
							
							SE1->(DbGoto(nRecSe1))
						Endif

						cNumLiq := SE1->E1_NUMLIQ
						If lUsaFlag
							// Carrega em aFlagCTB os recnos ref. SE5 e FKs
							// Quando não lUsaFlag aRecsSE5 efetuará a marcação
							If lRAMov
								CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
							EndIf
							aAdd(aFlagCTB,{"E1_LA","S","SE1",SE1->(Recno()),0,0,0})
						EndIf
						If !lCabecalho	// Se não houver cabeçalho aberto, abre.
							a370Cabecalho(@nHdlPrv,@cArquivo)
						EndIf

						//Posiciono FO2 e alimento variável referente ao juros informado na liquidação
						If !Empty(cNumLiq)
							dbSelectArea("FO2")
							nRecFO2 := F460PosFO2( nRecSe1 , cNumLiq )
							If nRecFO2 > 0
								FO2->(dbGoto(nRecFO2))
								JUROS3 := FO2->FO2_VLJUR
							EndIf
						EndIf					
						nTotDoc	:= DetProva(nHdlPrv,cPadrao,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB)
						nTotal	+= nTotDoc
						nTotProc	+= nTotDoc //Totaliza por processo

						If MV_PAR12 == MVP12DOCUMENTO // Por documento
							IF nTotDoc > 0
								If lSeqCorr
									aDiario := {{"SE1",SE1->(recno()),SE1->E1_DIACTB,"E1_NODIA","E1_DIACTB"}}
								EndIf
								Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,@aDiario,dDataCtb)
							Endif
							LimpaArray(aFlagCTB)
						Endif

						// Atualiza Flag de Lançamento Contábil
						If LanceiCtb
							If !lUsaFlag
								Reclock("SE1")
								REPLACE SE1->E1_LA With "S"
								SE1->(MsUnlock())
							EndIf
						ElseIf lUsaFlag
							If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == SE1->(Recno()) }))>0
								aFlagCTB := Adel(aFlagCTB,nPosReg)
								aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
							Endif
						EndIf
					Endif
					DbSelectArea(cAliasSE1)
					(cAliasSE1)->(dbSkip())
				Enddo			
				
				If MV_PAR12 == MVP12PROCESSO 
					If nTotProc > 0 // Por processo
						Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataCtb)
						nTotProc := 0
					Endif
					LimpaArray(aFlagCTB)
				Endif
				
				// Encerro o temporario criado para a contabilização.
				If lQrySE1 .And. Select( cAliasSE1 ) > 0
					DbSelectArea(cAliasSE1)
					(cAliasSE1)->(DbCloseArea())
					cAliasSE1 := "SE1"
				Endif
			Endif		

			If (mv_par06 == 2 .or. mv_par06 == 4) .and. lLerSE2

				IF Select(cAliasSE2)<=0
					If !__lSchedule
						MsAguarde( {|| CTBSleep( 2000 ) }, "Erro ao trazer os dados da SE2.", "CTBAFIN")
					EndIf
				
					cAliasSE2 := "SE2"
				Endif
		
				// Contas a Pagar - SE2
				// Contabiliza pelo E2_EMIS1
				dbSelectArea(cAliasSE2)
				While (cAliasSE2)->( !Eof() ) .And. (cAliasSE2)->E2_EMIS1 >= dIniProc .And. (cAliasSE2)->E2_EMIS1 <= dFinProc
					PulseLife() //- Pulso de vida da conexão
					If !lPass .And. lMvAGP
						While !Eof()
							If (cAliasSE2)->E2_PREFIXO == "AGP" .And. Empty((cAliasSE2)->E2_TITPAI) .And. Alltrim((cAliasSE2)->E2_ORIGEM) == "FINA378"
								lAGP := .T.
								Exit
							EndIf
							nSkip += 1
							(cAliasSE2)->(DbSkip())
						EndDo
						lPass := .T.
						If nSkip >= 1
							nSkip := 0
							(cAliasSE2)->(DbGotop())
						EndIf
					EndIf
					
					DBSelectArea("SE2")
					SE2->(dbGoto((cAliasSE2)->SE2RECNO))
					lMulNatSE2 := .F.
					lPAMov	:= .F.
					dDataCtb := IF(MV_PAR03 == MVP03EMISSAO, SE2->E2_EMIS1, dDataBase)
										
					// Nao contabiliza titulos de impostos aglutinados com origem na rotina FINA378
					// O parâmetro MV_CTBAGP libera a contabilização dos títulos do PCC aglutinados.
					If !lAGP // Neste caso o Parâmetro de contabilização dos impostos aglutinados inverte a operação
						If	AllTrim( Upper( SE2->E2_ORIGEM ) ) == "FINA378" .And. SE2->E2_PREFIXO == "AGP"	// Aglutinacao Pis/Cofins/Csll
							(cAliasSE2)->(dbSkip())
							Loop
						Endif
					ElseIf AllTrim(SE2->E2_CODRET) == "5952" .And. ( (SE2->E2_PREFIXO != "AGP" .Or. !Empty(SE2->E2_TITPAI)) .And. AllTrim(SE2->E2_ORIGEM) != "FINA378") .And. (lF370ChkAgp .And. F370ChkAgp())
						RecLock("SE2",.F.)
						SE2->E2_LA := 'S'
						SE2->(MsUnLock())
						(cAliasSE2)->(dbSkip())
						Loop
					EndIf

					// Contabiliza movimentacao bancaria de adiantamento - MV_CTMOVPA
					If SE2->E2_TIPO $ MVPAGANT
						If lCtMovPa
							(cAliasSE2)->(dbSkip())
							Loop
						EndIf
						nRecMovPa := F080MovPA(.T.,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA)
						lPAMov := nRecMovPa > 0
					Endif

					If	SE2->E2_TIPO $ MVTAXA+"/"+MVISS+"/"+MVINSS .And.;
						( AllTrim(SE2->E2_FORNECE) $ cUniao .Or.;
						AllTrim(SE2->E2_FORNECE) $ cMunic)
						// Contabiliza rateio de impostos em multiplas naturezas e multiplos centros de custos.
						lPadrao:=VerPadrao("510")
						If lPadrao
							If SE2->E2_RATEIO != "S"
								If !lCabecalho
									a370Cabecalho(@nHdlPrv,@cArquivo)
								Endif
								
								// Se utiliza multiplas naturezas, contabiliza pelo SEV
								If SE2->E2_MULTNAT=="1" .AND. !EMPTY(cChaveSev := RetChaveSev("SE2")) .And. SearchFor('SEV',4,cChaveSev+'P')
									cChaveSeZ := RetChaveSev("SE2",,"SEZ")
									lMulNatSE2 := .F.
									nRecSe2 := SE2->(Recno())

									While SEV->(!Eof()) .AND. xFilial("SEV")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_IDENT) == cChaveSev+"1"
										PulseLife() //- Pulso de vida da conexão
										If SEV->EV_LA != "S"
											// Posiciona na natureza, pois a conta pode estar la.
											SearchFor('SED',1,xFilial("SED")+SEV->EV_NATUREZ)
											If (SEV->EV_RATEICC == "1") .and. (lPadraoCC := VerPadrao("508"))	// Rateou multinat por c.custo
												If lUsaFlag
													aAdd(aFlagCTB,{"EV_LA","S","SEV",SEV->(Recno()),0,0,0})
												EndIf

												// Posiciona no arquivo de Rateio C.Custo da MultiNat
												SearchFor('SEZ',4,cChaveSeZ+SEV->EV_NATUREZ)
												While SEZ->(!Eof()) .and. xFilial("SEZ")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+;
														EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT) == cChaveSeZ+SEV->EV_NATUREZ+"1"
													PulseLife() //- Pulso de vida da conexão
													If SEZ->EZ_LA != "S"
														If lUsaFlag
															aAdd(aFlagCTB,{"EZ_LA","S","SEZ",SEZ->(Recno()),0,0,0})
														EndIf

														VALOR := 0
														VALOR2 := 0
														VALOR3 := 0
														VALOR4 := 0
														Do Case
															Case SEZ->EZ_TIPO $ MVTAXA
																VALOR2 := SEZ->EZ_VALOR
															Case SEZ->EZ_TIPO $ MVISS
																VALOR3 := SEZ->EZ_VALOR
															Case SEZ->EZ_TIPO $ MVINSS
																VALOR4 := SEZ->EZ_VALOR
														EndCase
														nTotDoc	+=	DetProva(nHdlPrv,"508","FINA370",cLote,,,,,,aCT5,,@aFlagCTB)

														If LanceiCtb // Vem do DetProva
															If !lUsaFlag
																RecLock("SEZ")
																SEZ->EZ_LA := "S"
																SEZ->(MsUnlock())
															EndIf
														ElseIf lUsaFlag
															If (nPosReg := aScan(aFlagCTB,{ |x| x[4] == SEZ->(Recno()) }))>0
																aFlagCTB := Adel(aFlagCTB,nPosReg)
																aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
															Endif														
														Endif

													Endif
													SEZ->(dbSkip())
												Enddo
											Else
												VALOR := 0
												VALOR2 := 0
												VALOR3 := 0
												VALOR4 := 0
												Do Case
													Case SEV->EV_TIPO $ MVTAXA
														VALOR2 := SEV->EV_VALOR
													Case SEV->EV_TIPO $ MVISS
														VALOR3 := SEV->EV_VALOR
													Case SEV->EV_TIPO $ MVINSS
														VALOR4 := SEV->EV_VALOR
												EndCase

												If lUsaFlag
													aAdd(aFlagCTB,{"EV_LA","S","SEV",SEV->(Recno()),0,0,0})
												EndIf

												nTotDoc	+=	DetProva(nHdlPrv,"510","FINA370",cLote,,,,,,aCT5,,@aFlagCTB)
											Endif
											If LanceiCtb // Vem do DetProva
												If !lUsaFlag
													RecLock("SEV")
													SEV->EV_LA := "S"
													SEV->(MsUnlock())
												EndIf
											ElseIf lUsaFlag
												If (nPosReg := aScan(aFlagCTB,{ |x| x[4] == SEV->(Recno()) }))>0
													aFlagCTB := Adel(aFlagCTB,nPosReg)
													aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
												Endif
											Endif

										Endif
										dbSelectArea("SEV")
										SEV->(DbSkip())
									Enddo
									nTotal  	+=	nTotDoc
									nTotProc	+=	nTotDoc // Totaliza por processo
									nRecSev := SEV->(Recno())
									nRecSez := SEZ->(Recno())
									SEV->(DBGOTO(0))
									SEZ->(DBGOTO(0))

									dbSelectArea("SE2")			// permite contabilizar os impostos pelo SE2
									SE2->(dbGoto(nRecSe2))
									If lUsaFlag
										aAdd(aFlagCTB,{"E2_LA","S","SE2",SE2->(Recno()),0,0,0})
									EndiF
									If !lCabecalho
										a370Cabecalho(@nHdlPrv,@cArquivo)
									Endif
									
									nTotDoc	+=	DetProva(nHdlPrv,"508","FINA370",cLote,,,,,,aCT5,,@aFlagCTB)
									SEV->(dbGoto(nRecSev))
									SEZ->(dbGoto(nRecSez))
									dbSelectArea("SE2")
									SE2->(DbGoto(nRecSe2))
									If MV_PAR12 == MVP12DOCUMENTO 
										If nTotDoc > 0 // Por documento
											If lF370NatP
												ExecBlock("F370NATP",.F.,.F.,{nHdlPrv,cLote})
											Endif
											If lSeqCorr
												aDiario := {{"SE2",SE2->(recno()),SE2->E2_DIACTB,"E2_NODIA","E2_DIACTB"}}
											EndIf
											Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,@aDiario,dDataCtb)
											nTotDoc := 0
										Endif
										LimpaArray(aFlagCTB)
									Endif
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Atualiza Flag de Lan‡amento Cont bil 	   ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If LanceiCtb
										If !lUsaFlag
											Reclock("SE2")
											Replace SE2->E2_LA With "S"
											SE2->(MsUnlock())
										EndIF
									ElseIf lUsaFlag
										If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == SE2->(Recno()) }))>0
											aFlagCTB := Adel(aFlagCTB,nPosReg)
											aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
										Endif
									EndIf
								Endif
							Endif
						Endif
						// Fim da contabilizacao de titulos de impostos por multiplas natureza
						// e multiplos centros de custos
						dbSelectArea( cAliasSE2 )
						If lMulNatSE2
							(cAliasSE2)->(dbSkip())
							Loop
						Endif
					Endif
					cPadrao := "510"
					
					IF	SE2->E2_TIPO $ MVPAGANT
						cPadrao:="513"
					EndIF
					
					If	SE2->E2_RATEIO == "S"
						cPadrao := "511"
					EndIf
					
					If	SE2->E2_DESDOBR == "S"
						cPadrao := "577"
					EndIf
					
					// Posiciona no fornecedor
					SearchFor('SA2',1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
					
					// Posiciona na natureza
					SearchFor('SED',1,xFilial("SED")+SE2->E2_NATUREZ)

					dbSelectArea("SE2")
					
					// Posiciona na SE5 e no Banco,se PA e SEF para Cheque
					If SE2->E2_TIPO $ MVPAGANT
						dbSelectArea("SE5")
						SE5->(dbSetOrder(1))
						If lPaMov
							SE5->( DbGoTo(nRecMovPa) )
						EndIf
						
						// Busca CHEQUE
						SearchFor('SEF',3,xFilial('SEF')+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_NUMBCO))
						
						// Busca Movimento Bancario
						If SE5->(Found()) .or. lPaMov
							SearchFor('SA6',1,xFilial('SA6')+SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA))
						Else
							SearchFor('SA6',1,xFilial('SA6')+SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA))
						Endif

						// Desposiciona SE5
						SE5->(DbGoTo(0))
						dbSelectArea( "SE2" )
					Endif

					If (lPadrao := VerPadrao(cPadrao)) .OR. lMultNat
						If SE2->E2_RATEIO != "S"
							If !lCabecalho
								a370Cabecalho(@nHdlPrv,@cArquivo)
							Endif
							
							// Se utiliza multiplas naturezas, contabiliza pelo SEV
							If SE2->E2_MULTNAT == "1" .AND. !EMPTY(cChaveSev := RetChaveSev("SE2")) .And. SearchFor('SEV',2,cChaveSev)
								cChaveSeZ := RetChaveSev("SE2",,"SEZ")
								nRecSe2 := SE2->(Recno())
								DbSelectArea("SEV")
								SEV->(dbSetOrder(2))
								While xFilial("SEV")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+;
									EV_LOJA+EV_IDENT) == cChaveSev+"1" .And. SEV->(!Eof())
									PulseLife() //- Pulso de vida da conexão
									If SEV->EV_LA != "S"
										// Posiciona na natureza, pois a conta pode estar la.
										SearchFor('SED',1,xFilial("SED")+SEV->EV_NATUREZ)
										dbSelectArea("SEV")
										If (SEV->EV_RATEICC == "1") .and. (lPadraoCC := VerPadrao("508")) // Rateou multinat por c.custo
                                            If lUsaFlag
                                                aAdd(aFlagCTB,{"EV_LA","S","SEV",SEV->(Recno()),0,0,0})
                                            EndIf

											// Posiciona no arquivo de Rateio C.Custo da MultiNat
											SearchFor('SEZ',4,cChaveSeZ+SEV->EV_NATUREZ)
											While SEZ->(!Eof()) .and. xFilial("SEZ")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+;
													EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT) == cChaveSeZ+SEV->EV_NATUREZ+"1"

												If SEZ->EZ_LA != "S"
													If lUsaFlag
														aAdd(aFlagCTB,{"EZ_LA","S","SEZ",SEZ->(Recno()),0,0,0})
													EndiF
		
													VALOR2	:= 0
													VALOR3	:= 0
													VALOR4	:= 0
													VALOR  	:= 0
													Do Case
														Case SEZ->EZ_TIPO $ MVTAXA
															VALOR2 := SEZ->EZ_VALOR
														Case SEZ->EZ_TIPO $ MVISS
															VALOR3 := SEZ->EZ_VALOR
														Case SEZ->EZ_TIPO $ MVINSS
															VALOR4 := SEZ->EZ_VALOR
														Otherwise
															VALOR  := SEZ->EZ_VALOR
													EndCase
													nTotDoc	+=	DetProva(nHdlPrv,"508","FINA370",cLote,,,,,,aCT5,,@aFlagCTB)

													If LanceiCtb // Vem do DetProva
														If !lUsaFlag
															RecLock("SEZ")
															SEZ->EZ_LA    := "S"
															SEZ->(MsUnlock())
														EndIf
													ElseIf lUsaFlag
														If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == SEZ->(Recno()) }))>0
															aFlagCTB := Adel(aFlagCTB,nPosReg)
															aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
														Endif
													Endif
												Endif

												SEZ->(dbSkip())
											Enddo
											DbSelectArea("SEV")
										Else
											VALOR  := 0
											VALOR2 := 0
											VALOR3 := 0
											VALOR4 := 0
											Do Case
												Case SEV->EV_TIPO $ MVTAXA
													VALOR2 := SEV->EV_VALOR
												Case SEV->EV_TIPO $ MVISS
													VALOR3 := SEV->EV_VALOR
												Case SEV->EV_TIPO $ MVINSS
													VALOR4 := SEV->EV_VALOR
												Otherwise
													VALOR  := SEV->EV_VALOR
											EndCase
											If lUsaFlag
												aAdd(aFlagCTB,{"EV_LA","S","SEV",SEV->(Recno()),0,0,0})
											EndIf
											nTotDoc	+= DetProva(nHdlPrv,cPadrao,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB,{"SEV",SEV->(Recno())})
										Endif
										If LanceiCtb // Vem do DetProva
											If !lUsaFlag
												RecLock("SEV")
												SEV->EV_LA    := "S"
												SEV->(MsUnlock())
											EndIf
										ElseIf lUsaFlag
											If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == SEV->(Recno()) }))>0
												aFlagCTB := Adel(aFlagCTB,nPosReg)
												aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
											Endif
										Endif

									Endif
									dbSelectArea("SEV")
									SEV->(DbSkip())

									// Inicializa Variáveis
									VALOR  := 0
									VALOR2 := 0
									VALOR3 := 0
									VALOR4 := 0
									
								Enddo
								nTotal  	+=	nTotDoc
								nTotProc	+=	nTotDoc // Totaliza por processo
								
								// Desposiciona SEV
								SEV->(DBGOTO(0))
								
								// Posiciona Título PPrincipal
								dbSelectArea("SE2")
								SE2->(DbGoto(nRecSe2))

								If lUsaFlag
									aAdd(aFlagCTB,{"E2_LA","S","SE2",SE2->(Recno()),0,0,0})
								Endif
								nTotDoc	+= DetProva(nHdlPrv,cPadrao,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB)
								If LanceiCtb .AND. !lUsaFlag// Vem do DetProva
									RecLock("SE2")
									Replace SE2->E2_LA With "S"
									SE2->(MsUnlock())
								ElseIf !LanceiCtb .and. lUsaFlag
									If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == SE2->(Recno()) }))>0
										aFlagCTB := Adel(aFlagCTB,nPosReg)
										aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
									Endif
								Endif

								If MV_PAR12 == MVP12DOCUMENTO .OR. MV_PAR12 == MVP12PROCESSO
									If lF370NatP
										ExecBlock("F370NATP",.F.,.F.,{nHdlPrv,cLote})
									Endif

									If MV_PAR12 == MVP12DOCUMENTO .AND. nTotDoc > 0 // Por documento
										If lSeqCorr
											aDiario := {{"SE2",SE2->(recno()),SE2->E2_DIACTB,"E2_NODIA","E2_DIACTB"}}
										EndIf
										Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,@aDiario,dDataCtb)
										nTotDoc := 0
										LimpaArray(aFlagCTB)
									Endif
								Endif

							Endif

							dbSelectArea( "SE2" )
							// Títulos de Natureza Simples - Sem registro na SEV/SEZ
							If !SE2->E2_LA == "S" .AND. SE2->E2_MULTNAT <> '1'
								If !lCabecalho
									a370Cabecalho(@nHdlPrv,@cArquivo)
								Endif
								
								If lUsaFlag
									aAdd(aFlagCTB,{"E2_LA","S","SE2",SE2->(Recno()),0,0,0})
								EndIf
								
								nTotDoc	+=	DetProva(nHdlPrv,cPadrao,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB)

								nTotProc+= nTotDoc
								nTotal	+=	nTotDoc
								If MV_PAR12 == MVP12DOCUMENTO 
									If nTotDoc > 0 // Por documento
										If lSeqCorr
											aDiario := {{"SE2",SE2->(recno()),SE2->E2_DIACTB,"E2_NODIA","E2_DIACTB"}}
										EndIf
										Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,@aDiario,dDataCtb)
										nTotDoc := 0
									Endif
									LimpaArray(aFlagCTB)
								Endif

								// Atualiza Flag de Lan‡amento Contábil
								// Grava o FLAG inclusive quando não contabilizou e neste caso não será com aFlagCTB
								If !lUsaFlag .OR. !LanceiCTB
									Reclock("SE2")
									Replace SE2->E2_LA With "S"
									SE2->(MsUnlock())
									
									If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == SE2->(Recno()) })) > 0
										aFlagCTB := Adel(aFlagCTB,nPosReg)
										aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
									Endif
								EndIf
							EndIf
						Else	// Rateio Contábil
							// Devido a estrutura do programa, o rateio ja eh "quebrado"
							// por documento.
							If !lCabecalho							/// Se não houver cabeçalho aberto, abre.
								a370Cabecalho(@nHdlPrv,@cArquivo)
							EndIf

							RegToMemory("SE2",.F.,.F.)

							If lUsaFlag
								aAdd(aFlagCTB,{"E2_LA","S","SE2",SE2->(Recno()),0,0,0})
							EndIf

							F370RatFin(cPadrao,"FINA370",cLote,4," ",4,,,,@nHdlPrv,@nTotDoc,@aFlagCTB)

							lCabecalho := If(nHdlPrv <= 0, lCabecalho, .T.)
							nTotProc	+= nTotDoc
							nTotal	+=	nTotDoc

							If MV_PAR12 == MVP12DOCUMENTO 
								If nTotDoc > 0 // Por documento
									If lSeqCorr
										aDiario := {{"SE2",SE2->(recno()),SE2->E2_DIACTB,"E2_NODIA","E2_DIACTB"}}
									EndIf						
									Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,@aDiario,dDataCtb)
								Endif
								LimpaArray(aFlagCTB)
							Endif
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza Flag de Lan‡amento Cont bil		  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If LanceiCtb
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Atualiza Flag de Lan‡amento Cont bil		  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								dbSelectArea("SE2")
								If !lUsaFlag
									Reclock("SE2")
									Replace SE2->E2_LA With "S"
									SE2->(MsUnlock())
								EndIf
							ElseIf lUsaFlag
								If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == SE2->(Recno()) }))>0
									aFlagCTB := Adel(aFlagCTB,nPosReg)
									aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
								Endif
							EndIf
							
						Endif
					Endif
					dbSelectArea(cAliasSE2)
					(cAliasSE2)->(dbSkip())
					LanceiCtb := .F.
				Enddo

				If MV_PAR12 == MVP12PROCESSO 
					IF nTotProc > 0 // Por processo
						Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataCtb)
						nTotProc := 0
					Endif
					LimpaArray(aFlagCTB)
				Endif
				
				dbSelectArea( cAliasSE2 )
			Endif
				
			//Contabilizacao do SE5
			If lLerSE5
				
				//Query para contabilização do troco pela FK5
				If !Empty(cAliasTroc)
					
					While (cAliasTroc)->( !EOF() ) .And. (cAliasTroc)->FK5_DATA >= dIniProc .And. (cAliasTroc)->FK5_DATA <= dFinProc
						lTroTemSE5 := .F.
						nTotProc := 0
						FK5->( dbGoTo( (cAliasTroc)->R_E_C_N_O_  ) )
						PulseLife() //- Pulso de vida da conexão
						SED->( dbSetOrder(1) ) //ED_FILIAL+ED_CODIGO
						SED->( dbSeek( FWxFilial("SED") + FK5->FK5_NATURE ) )
						SA6->( dbSetOrder(1) ) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
						SA6->( MsSeek( FWxFilial("SA6") + FK5->FK5_BANCO + FK5->Fk5_AGENCI + FK5->FK5_CONTA ) )

						If FK5->FK5_TPDOC == "VL"
							cPadrao := "5C8" //Movimento Bancário - Movimento de Troco

							SE5->( dbSetOrder(21) ) //E5_FILIAL+E5_IDORIG+E5_TIPODOC
							If SE5->( msSeek( FWxFilial("SE5") + Fk5->FK5_IDMOV + FK5->FK5_TPDOC ) )
								lTroTemSE5 := .T.
							EndIf
						ElseIf FK5->FK5_TPDOC == "ES"
							cPadrao := "5C9" //Movimento Bancário - Estorno de Movimento de Troco
						EndIf
						
						lPadrao := VerPadrao(cPadrao)
						
						If lPadrao
							If !lCabecalho
								a370Cabecalho( @nHdlPrv, @cArquivo )
								lCabecalho := Iif( nHdlPrv > 0, .T., .F. )
							EndIf

							//Se atualiza as flags dos registros de troco pelo CTB
							If lUsaFlag
								aAdd( aFlagCTB, {"FK5_LA", "S", "FK5", (cAliasTroc)->R_E_C_N_O_, 0, 0, 0} )
								If lTroTemSE5
									aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ) , 0, 0, 0} )
								EndIf
							EndiF

							nTotDoc	:= DetProva( nHdlPrv, cPadrao, "FINA370", cLote,,,,,, aCT5,, @aFlagCTB ) //Total por documento
							nTotProc += nTotDoc //Total por processo
							nTotal += nTotDoc //Total por período

							//Se não atualiza as flags de registros de troco pelo CTB, então atualiza aqui com reclock
							If !lUsaFlag .And. LanceiCtb
								Reclock( "FK5", .F. )
								FK5->FK5_LA := "S"
								FK5->( msUnlock() )

								If lTroTemSE5
									Reclock( "SE5", .F. )
									SE5->E5_LA := "S"
									SE5->( msUnlock() )
								EndIf
							EndIf

							//Contabiliza o troco por documento
							If MV_PAR12 == MVP12DOCUMENTO
								If nTotDoc > 0
									Ca370Incl( cArquivo, @nHdlPrv, cLote, @aFlagCTB,, FK5->FK5_DATA )
								Endif
								
								LimpaArray(aFlagCTB)
							Endif

						EndIf
						
						(cAliasTroc)->( dbSkip() )
					EndDo

				EndIf

				LimpaArray(aRecsSE5)
				LimpaArray(aRecsTRF) //Registros de transferencia bancaria

				cCondFilSE5 := xFilial("SE5")
				
				cCondWhile:= "( (" + cAliasSE5 + "->" + cCampo + " >= dIniProc .And. " + cAliasSE5 + "->" + cCampo + " <= dFinProc ) .AND. "
				cCondWhile += " !(" + cAliasSE5 + "->E5_TIPODOC  $ 'TR#TE') ) .OR. "

				cCondWhile += "( ((" + cAliasSE5 + "->E5_DATA >= dIniProc .AND. " + cAliasSE5 + "-> E5_DATA <= dFinProc) .OR. "
				cCondWhile += " (" + cAliasSE5 + "->" + cCampo + " >= dIniProc .And. " + cAliasSE5 + "->" + cCampo + " <= dFinProc)) "
				cCondWhile += " .AND. " + cAliasSE5 + "->E5_TIPODOC $ 'TR#TE' .OR. Empty(" + cAliasSE5 + "->(E5_TIPODOC+E5_TIPO))) " //  Filtra somente as transferencias bancarias

				nValorTotal := 0 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Variaveis para suporte a Recebimentos Diversos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cSELSerie	:= ""
				cSELRecibo	:= ""
				// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				
				cRecPag := (cAliasSE5)->E5_RECPAG
				cNumBor := ""
				cProxBor := ""

				If MV_PAR12 == MVP12PROCESSO
					// Para cada período processa SE5 em duas etapas:
					//   - Primeiro nas Aplicações/Emprestimos e Movimentos Bancários; e
					//   - Segundo nas Movimentações relacionadas à SE1-CR e SE2-CP.
					If cTipoMov == 'TITULOS'
						(caliasSE5)->(DBGOTOP())
					EndIf
					cTipoMov := 'DIRETO'
				EndIf
				
				While VldDtE5(cAliasSe5,cCampo,dFinProc,mv_par04,@cTipoMov)
					PulseLife() //- Pulso de vida da conexão				
					// garanto que estarei posicionado no primeiro registro da data --------- 
					If !(&cCondWhile)
						(cAliasSE5)->( dbSkip() )
						Loop
					Endif

					dbSelectArea( "SE5" ) // ------------------------------------------------
					If MV_PAR13 == MVP13TOTBOR	// Ctb Bordero - Total/Por Bordero
						SE5->(dbSetOrder(1))	// "E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ"
					Else
						SE5->(dbSetOrder(10))	// "E5_FILIAL+E5_DOCUMEN"
					Endif
					
					// Emparelha as tabelas Temporária e Oficial ---------------------------- 
					SE5->(dbGoto((cAliasSE5)->(SE5RECNO)))

					dDataCtb := IF(SE5->E5_TIPODOC $ 'TR#TE',SE5->E5_DATA,(cAliasSE5)->(&cCampo))
					
					// Totaliza movimento bancário DIRETO e/ou de TÍTULOS - Controlando por processo (MV_PAR12 == MVP12PROCESSO)
					If MV_PAR12 == MVP12PROCESSO
						If cTipoMov == "DIRETO" .and. !EMPTY((cAliasSE5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
							(cAliasSE5)->(dbSkip())
							If !VldDtE5(cAliasSe5,cCampo,dFinProc,mv_par04)
								(cAliasSE5)->(dbGOTOP())
								cTipoMov := "TITULOS"
							EndIf	
							lLoop := .T.
						ElseIf	cTipoMov == "TITULOS" .and. EMPTY((cAliasSE5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
							(cAliasSE5)->(dbSkip())
							lLoop := .T.
						EndIf

						If !EMPTY(nTotProc) .and. cRecPag <> (cAliasSE5)->E5_RECPAG
							cRecPag := (cAliasSE5)->E5_RECPAG
							Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataCtb)
							LimpaArray(aFlagCTB)
							nTotProc := 0
						EndIf

						If lLoop
							lLoop := .F.
							LOOP
						EndIf
					EndIf

					// Posiciona SED Natureza ----------------------------------------------
					SearchFor('SED',1,xFilial("SED")+SE5->E5_NATUREZ)
					// Posiciona SA6 Banco -------------------------------------------------
					SearchFor('SA6',1,xFilial("SA6")+SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA))
					// Posiciona SEA Bordero -----------------------------------------------
					nPosBor := 0
					If !EMPTY(SE5->E5_DOCUMEN) .AND.;
						SearchFor('SEA',4,SE5->(E5_FILORIG+PADR(E5_DOCUMEN,nTamBor)+E5_RECPAG+E5_PREFIXO+E5_NUMERO+E5_PARCELA))
						cNumBor := PADR(SE5->E5_DOCUMEN,nTamBor)
					ElseIf !EMPTY(SE5->E5_DTCANBX) 
						cNumBor :=  PADR(SE5->E5_DOCUMEN,nTamBor)
						cProxBor := PADR(SE5->E5_DOCUMEN,nTamBor)
					EndIf

					dbSelectArea("SE5")		// Restaura a área da tabela Oficial 	

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Movimentos Bancarios e Aplicacoes/Emprestimos - SE5  		  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (SE5->E5_TIPODOC $ "  /TR/TE/DB/PA/OD/AP/RF/PE/EP/IT/DH" .OR. Empty(SE5->(E5_TIPODOC+E5_TIPO)))
						cPadrao := ""

						lRaCont := .F. //Limpa variavel de Contabilização de Baixa de RA - LP 520
						
						If SE5->E5_RECPAG == 'R' .and. SE5->E5_TIPODOC $ "  |DB|DH" .and. ( mv_par06 == 1 .or. mv_par06 == 4 )
							cPadrao	:= Iif( SE5->E5_SITUACA <> "E", "563", "564" )
						ElseIf SE5->E5_RECPAG == 'P' .and. ( mv_par06 == 2 .or. mv_par06 == 4 )
							If !SE5->E5_TIPODOC $ "PA#TR#TE" .AND. SE5->E5_SITUACA <> "E"
								cPadrao := "562"
							ElseIf !SE5->E5_TIPODOC $ "PA#TR#TE" .AND. SE5->E5_RECPAG = "P"
								cPadrao := "565"
							EndIf
						Endif

						If SE5->E5_TIPO $ MVRECANT .AND. SE5->E5_RECPAG ="P" .AND. ALLTRIM(SE5->E5_LA) <> "S"
							lRACont := .T.
							cPadrao := '520'
						Endif 

						//se for ITF utiliza lancamento especifico
						If lFindITF .And. FinProcITF( SE5->( Recno() ),2 )
							If SE5->E5_SITUACA == 'E' .Or. SE5->E5_SITUACA == 'C'
								cPadrao := "56B"
							Else
								cPadrao := "56A"
							EndIf
						EndIf
						//Tranferencias

						//Não contabiliza movimentos da carteira a receber caso esteja contabilizando apenas a carteira a pagar.
						//Não contabiliza movimentos da carteira a pagar caso esteja contabilizando apenas a carteira a receber
						If !(SE5->E5_TIPODOC $ "TR#TE")
							If (mv_par06 != 1 .and. mv_par06 !=4) .And. SE5->E5_RECPAG == 'R'
								(cAliasSE5)->( dbSkip() )

								If MV_PAR12 == MVP12PROCESSO .AND. (cAliasSE5)->(EOF()) .and. cTipoMov == "DIRETO"
									(cAliasSE5)->(dbGOTOP())
									cTipoMov := "TITULOS"
								EndIf	

								Loop
							ElseIf (mv_par06 != 2 .and. mv_par06 !=4) .AND. SE5->E5_RECPAG == 'P'
								(cAliasSE5)->( dbSkip() )

								If MV_PAR12 == MVP12PROCESSO .AND. (cAliasSE5)->(EOF()) .and. cTipoMov == "DIRETO"
									(cAliasSE5)->(dbGOTOP())
									cTipoMov := "TITULOS"
								EndIf	

								Loop
							EndIf						
												
							// Nao contabiliza transferencia para carteira descontada
							// Este sera feito pela Baixa do titulo
							If SE5->E5_TIPODOC $ "TR#TE" .and. !Empty(SE5->E5_NUMERO)
								(cAliasSE5)->( dbSkip() )
								Loop
							Endif
						Endif

						// Nao contabiliza movimento bancario totalizador da baixa CNAB ou automatica
						// Este sera feito pela Baixa do titulo (LP530 ou LP532)
						If Empty(SE5->E5_TIPODOC) .and. !Empty(SE5->E5_LOTE)
							(cAliasSE5)->( dbSkip() )
							Loop
						Endif
						
						If SE5->E5_RECPAG == "P" .and. SE5->E5_TIPODOC $ "TR#TE" .and. MV_PAR06 == 4
							cPadrao := "560"
							AADD(aRecsTRF,{SE5->(RECNO()),"560",IIF(!Empty(SE5->E5_NUMCHEQ),SE5->E5_NUMCHEQ,SE5->E5_DOCUMEN),(cAliasSE5)->FKA_IDPROC,0})
							(cAliasSE5)->(dbSkip())

							If MV_PAR12 == MVP12PROCESSO .AND. (cAliasSE5)->(EOF()) .and. cTipoMov == "DIRETO"
								(cAliasSE5)->(dbGOTOP())
								cTipoMov := "TITULOS"
							EndIf	

							Loop 
						Elseif SE5->E5_RECPAG == "R" .and. SE5->E5_TIPODOC $ "TR#TE" .and. MV_PAR06 == 4
							cPadrao := "561"
							AADD(aRecsTRF,{SE5->(RECNO()),"561",IIF(!Empty(SE5->E5_NUMCHEQ),SE5->E5_NUMCHEQ,SE5->E5_DOCUMEN),(cAliasSE5)->FKA_IDPROC,0})
							(cAliasSE5)->(dbSkip())

							If MV_PAR12 == MVP12PROCESSO .AND. (cAliasSE5)->(EOF()) .and. cTipoMov == "DIRETO"
								(cAliasSE5)->(dbGOTOP())
								cTipoMov := "TITULOS"
							EndIf	

							Loop
						EndIf

						// Contabiliza movimentacao bancaria de adiantamento - MV_CTMOVPA
						If !lCtMovPa .And. SE5->E5_RECPAG == "P" .And. SE5->E5_TIPO	$ MVPAGANT
							(cAliasSE5)->(dbSkip())
							Loop
						Endif
						
						// Nao contabiliza movimentacao bancaria de adiantamento
						// Este sera feito pelo SE1
						If SE5->E5_RECPAG == "R" .And. SE5->E5_TIPO	$ MVRECANT
							(cAliasSE5)->(dbSkip())
							Loop
						Endif

						//Aplicacoes e emprestimos
						lX			:= .F.
						SEH->(dbSetOrder(1))
						
						/*
							-------------------------------------------------------------------------------------
							580 - Inclusão de Aplicacao Financeira e/ou Empréstimos
							Aplicações  - E5_RECPAG = 'P' .AND. E5_TIPODOC = 'AP'
							Empréstimos - E5_RECPAG = 'R' .AND. E5_TIPODOC = 'EP'
							-------------------------------------------------------------------------------------
							581 - Estorno/Exclusao de Aplicacao Financeira e/ou Empréstimos
							Aplicações  - E5_RECPAG = 'R' .AND. E5_TIPODOC = 'AP'
							Empréstimos - E5_RECPAG = 'P' .AND. E5_TIPODOC = 'EP'
							-------------------------------------------------------------------------------------
							585 - Resgate Aplicacao Financeira e/ou Pagamento de Empréstimos
							Resgate     - E5_RECPAG = 'R' .AND. E5_TIPODOC = 'RF'
							Pagamento   - E5_RECPAG = 'P' .AND. E5_TIPODOC = 'PE'
							-------------------------------------------------------------------------------------
							586 - Estorno de Resgate Aplicação Financeira e/ou Pagamento de Empréstimos
							Resgate     - E5_RECPAG = 'P' .AND. E5_TIPODOC = 'RF'
							Pagamento   - E5_RECPAG = 'R' .AND. E5_TIPODOC = 'PE'
							-------------------------------------------------------------------------------------
							APROPRIAÇÕES
							582 - Apropriacao de Rendimentos de Aplicações e/ou Juros de Emprestimo
							584 - Estorno Apropriacao - Rotina FINA183 (apenas aplicações do tipo FAF)
							-------------------------------------------------------------------------------------
						*/					

						If SE5->E5_TIPODOC $ "AP/RF/PE/EP" .And. SEH->(MsSeek(xFilial("SEH")+SubStr(SE5->E5_DOCUMEN,1,8)))
							lX		:= .T.
							If SE5->E5_TIPODOC $ "AP/EP"
								If ( SE5->E5_TIPODOC=="AP" .And. SE5->E5_RECPAG=="P" ) .Or.;
									( SE5->E5_TIPODOC=="EP" .And. SE5->E5_RECPAG=="R" )
									cPadrao := "580"
								Else
									cPadrao := "581"
								EndIf
							Else
								If ( SE5->E5_TIPODOC=="RF" .And. SE5->E5_RECPAG=="R" ) .Or.;
									( SE5->E5_TIPODOC=="PE" .And. SE5->E5_RECPAG=="P" )
									cPadrao := "585"
								Else
									cPadrao := "586"
								EndIf
							EndIf
							// SEH ja esta posicionado
							RecLock("SEH")
							SEH->EH_VALREG := 0
							SEH->EH_VALREG2:= 0
							SEH->EH_VALIRF := 0
							// Soh zera valor do IOF para buscar o movimento de IOF (EI_TIPODOC igual a "I2") nos casos de aplicacoes.
							If SEH->EH_APLEMP == "APL"
								SEH->EH_VALIOF := 0
							EndIf	
							SEH->EH_VALSWAP:= 0
							SEH->EH_VALISWP:= 0
							SEH->EH_VALOUTR:= 0
							SEH->EH_VALGAP := 0
							SEH->EH_VALCRED:= 0
							SEH->EH_VALJUR := 0
							SEH->EH_VALJUR2:= 0
							SEH->EH_VALVCLP:= 0
							SEH->EH_VALVCCP:= 0
							SEH->EH_VALVCJR:= 0
							SEH->EH_VALREG := 0
							SEH->EH_VALREG2:= 0
							MsUnlock()
							
							SearchFor('SEI',1,xFilial("SEI")+SEH->EH_APLEMP+ Alltrim(SE5->E5_DOCUMEN),.T.)
							
							If ( !VerPadrao("581") .And. cPadrao$"581#580" .And. SEI->EI_STATUS=="C" )
								(cAliasSE5)->(dbSkip())
								Loop
							EndIf
							If ( !VerPadrao("586") .And. cPadrao$"586#585" .And. SEI->EI_STATUS=="C" )
								(cAliasSE5)->(dbSkip())
								Loop
							EndIf
							
							aRecsSEI := {}
							While SEI->(!Eof()) .and. ( SEI->(EI_FILIAL+EI_APLEMP+EI_NUMERO+EI_REVISAO+EI_SEQ)==xFilial("SEI")+SEH->EH_APLEMP+ Alltrim(SE5->E5_DOCUMEN))
								RecLock("SEH")
								If SEI->EI_MOTBX == "APR"
									If SEI->EI_TIPODOC == "I1"
										SEH->EH_VALIRF := Abs(SEI->EI_VALOR)
									EndIf
									If SEI->EI_TIPODOC == "I2"
										SEH->EH_VALIOF := Abs(SEI->EI_VALOR)
									EndIf
									If SEI->EI_TIPODOC == "I3"
										SEH->EH_VALISWP:= Abs(SEI->EI_VALOR)
									EndIf
									If SEI->EI_TIPODOC == "I4" 
										SEH->EH_VALOUTR:= Abs(SEI->EI_VALOR)
									EndIf
									If SEI->EI_TIPODOC == "I5"
										SEH->EH_VALGAP := Abs(SEI->EI_VALOR)
									EndIf
									If SEI->EI_TIPODOC == "JR"
										SEH->EH_VALJUR := Abs(SEI->EI_VALOR)
										SEH->EH_VALJUR2:= Abs(SEI->EI_VLMOED2)
									EndIf
									If SEI->EI_TIPODOC == "V1"
										SEH->EH_VALVCLP := Abs(SEI->EI_VALOR)
									EndIf
									If SEI->EI_TIPODOC == "V2"
										SEH->EH_VALVCCP := Abs(SEI->EI_VALOR)
									EndIf
									If SEI->EI_TIPODOC == "V3"
										SEH->EH_VALVCJR := Abs(SEI->EI_VALOR)
									EndIf
									If SEI->EI_TIPODOC $ "I1/I2/I3/I4/I5/JR/V1/V2/V3"
										If lUsaFlag
											AAdd( aFlagCTB, {"EI_LA","S","SEI",SEI->(Recno()),0,0,0} )
											CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
										Else
											AAdd( aRecsSEI, SEI->(Recno()) )
											AAdd( aRecsSE5, {SE5->(Recno()),'FINM030','FK5'} )
										EndIf
									EndIf
								EndIf
								SEH->(MsUnLock())
								dbSelectArea("SEI")
								SEI->(dbSkip())
							EndDo

							// A contabilização do LP582 deve ocorrer pela presença de registros na SEI
							If ( VerPadrao("582") ) .AND. (!EMPTY(aRecsSEI) .OR. !EMPTY(aFlagCTB))
								// Localiza e posiciona Fornecedor
								SA2->(MsGOTO(FornEmpr(SEH->EH_NUMERO, SEH->EH_DATA, SEH->EH_NATUREZ)))
								
								If !lCabecalho
									a370Cabecalho(@nHdlPrv,@cArquivo)
								EndIf
								nTotDoc	:= DetProva(nHdlPrv,"582","FINA370",cLote,,,,,,aCT5,,@aFlagCTB)
								If LanceiCtb // Vem do DetProva
									For nJ := 1 To Len( aRecsSEI )
										SEI->( dbGoTo( aRecsSEI[nJ] ) )
										RecLock("SEI")
										SEI->EI_LA := "S"
										SEI->( MsUnlock() )
									Next nJ	
								EndIf

								nTotProc += nTotDoc
								nTotal	+=	nTotDoc

								If MV_PAR12 == MVP12DOCUMENTO 
									IF nTotDoc > 0 // Por documento
										If lSeqCorr
											aDiario := {{"SE5",SE5->(recno()),SE5->E5_DIACTB,"E5_NODIA","E5_DIACTB"}}
										EndIf
										Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,@aDiario,dDataCtb)
									Endif
									LimpaArray(aFlagCTB)
								Endif
							EndIf
							
							SearchFor('SEH',1,xFilial("SEH")+SubStr(SE5->E5_DOCUMEN,1,8), .T.)
							RecLock("SEH")
							SEH->EH_VALREG := 0
							SEH->EH_VALREG2:= 0
							SEH->EH_VALIRF := 0
							// Soh zera valor do IOF para buscar o movimento de IOF (EI_TIPODOC igual a "I2") nos casos de aplicacoes.
							If SEH->EH_APLEMP == "APL"
								SEH->EH_VALIOF := 0
							EndIf
							SEH->EH_VALSWAP:= 0
							SEH->EH_VALISWP:= 0
							SEH->EH_VALOUTR:= 0
							SEH->EH_VALGAP := 0
							SEH->EH_VALCRED:= 0
							SEH->EH_VALJUR := 0
							SEH->EH_VALJUR2:= 0
							SEH->EH_VALVCLP:= 0
							SEH->EH_VALVCCP:= 0
							SEH->EH_VALVCJR:= 0
							SEH->EH_VALREG := 0
							SEH->EH_VALREG2:= 0
							SEH->(MsUnlock())
							
							SearchFor('SEI',1,xFilial("SEI")+SEH->EH_APLEMP+SubStr(SE5->E5_DOCUMEN,1,10), .T.)
							
							aRecsSEI := {}
							While SEI->(!Eof()) .and. ( SEI->EI_FILIAL+SEI->EI_APLEMP+SEI->EI_NUMERO+SEI->EI_REVISAO+SEI->EI_SEQ==;
								xFilial("SEI")+SEH->EH_APLEMP+SubStr(SE5->E5_DOCUMEN,1,10) )
								RecLock("SEH")
								If SEI->EI_MOTBX == "NOR"
									If ( SEI->EI_TIPODOC == "RG" )
										SEH->EH_VALREG := Abs(SEI->EI_VALOR)
										SEH->EH_VALREG2:= Abs(SEI->EI_VALOR)
									EndIf
									If ( SEI->EI_TIPODOC == "I1" )
										SEH->EH_VALIRF := Abs(SEI->EI_VALOR)	
									EndIf
									If ( SEI->EI_TIPODOC == "I2" )
										SEH->EH_VALIOF := Abs(SEI->EI_VALOR)
									EndIf
									If ( SEI->EI_TIPODOC == "SW" )
										SEH->EH_VALSWAP:= Abs(SEI->EI_VALOR)
									EndIf
									If ( SEI->EI_TIPODOC == "I3" )
										SEH->EH_VALISWP:= Abs(SEI->EI_VALOR)
									EndIf
									If ( SEI->EI_TIPODOC == "I4" )
										SEH->EH_VALOUTR:= Abs(SEI->EI_VALOR)
									EndIf
									If ( SEI->EI_TIPODOC == "I5" )
										SEH->EH_VALGAP := Abs(SEI->EI_VALOR)
									EndIf
									If ( SEI->EI_TIPODOC == "VL" )
										SEH->EH_VALCRED:= Abs(SEI->EI_VALOR)
									EndIf
									If ( SEI->EI_TIPODOC == "JR" )
										SEH->EH_VALJUR := Abs(SEI->EI_VALOR)
										SEH->EH_VALJUR2:= Abs(SEI->EI_VLMOED2)
									EndIf
									If ( SEI->EI_TIPODOC == "V1" )
										SEH->EH_VALVCLP := Abs(SEI->EI_VALOR)
									EndIf
									If ( SEI->EI_TIPODOC == "V2" )
										SEH->EH_VALVCCP := Abs(SEI->EI_VALOR)
									EndIf
									If ( SEI->EI_TIPODOC == "V3" )
										SEH->EH_VALVCJR := Abs(SEI->EI_VALOR)
									EndIf
									If ( SEI->EI_TIPODOC == "BL" )
										SEH->EH_VALREG := Abs(SEI->EI_VALOR)
										SEH->EH_VALREG2:= Abs(SEI->EI_VLMOED2)
									EndIf
									If ( SEI->EI_TIPODOC == "BC" )
										SEH->EH_VALREG := Abs(SEI->EI_VALOR)
										SEH->EH_VALREG2:= Abs(SEI->EI_VLMOED2)
									EndIf
									If ( SEI->EI_TIPODOC == "BJ" )
										SEH->EH_VALJUR := Abs(SEI->EI_VALOR)
										SEH->EH_VALJUR2:= Abs(SEI->EI_VLMOED2)
									EndIf
									If ( SEI->EI_TIPODOC == "BP" )
										VALOR := Abs(SEI->EI_VALOR)
									EndIf
									If SEI->EI_TIPODOC $ "I1/I2/I3/I4/I5/JR/VL/V1/V2/V3/BL/BC/BJ/BP/RG"
										If lUsaFlag
											AAdd( aFlagCTB, {"EI_LA","S","SEI",SEI->(Recno()),0,0,0} )
										Else
											AAdd( aRecsSEI, SEI->(Recno()) )
										EndIf
									EndIf
								EndIf
								SEH->(MsUnLock())
								dbSelectArea("SEI")
								SEI->(dbSkip())
							EndDo
						EndIf
						
						dbSelectArea("SE5")
						
						//-------------------------------------------------------------
						// Caracteriza-se lancamento os registros com :
						// E5_TIPODOC = brancos
						// E5_TIPODOC = "DB" // Receita Bancaria - FINA200
						// E5_TIPODOC = "OD" // Outras Despesas  - FINA200
						// E5_TIPODOC = "TR" // Transferencia Banc - FINA100
						// E5_TIPODOC = "TE" // Est. Transf Bancar - FINA100
						// E5_TIPODOC = "IT" // Movimento de ITF (Bolivia) - FINA100
						//-------------------------------------------------------------
						If !lX .and. !(SE5->E5_TIPODOC $ "DB/DH/OD/PA/  /TR/TE/IT")
							(cAliasSE5)->(dbSkip())
							Loop
						Endif
						
						If SE5->E5_RATEIO == "S"
							If SE5->E5_RECPAG = "R"
								If SE5->E5_SITUACA == "E"
									cPadrao := "557"
								Else
								cPadrao := "517"
								EndIf					    
							Else
								If SE5->E5_SITUACA == "E"
									cPadrao := "558"
								Else
								cPadrao := "516"
								EndIf					    
							Endif
						EndIf

						If SE5->E5_TIPO $ MVPAGANT
							// Desposiciona SE2
							SE2->( DbGoTo(0) )
							cPadrao := "513"
						EndIf

						// Posiciona na natureza
						SearchFor('SED',1,xFilial('SED')+SE5->E5_NATUREZ)
						
						// Posiciona no Banco
						SearchFor('SA6',1,xFilial("SA6")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA)
						
						dbSelectArea("SE5")
						lPadrao:=VerPadrao(cPadrao)
						
						If l370E5R .and. SE5->E5_RECPAG == "R"
							Execblock("F370E5R",.F.,.F.)
						Endif

						If l370E5P .and. SE5->E5_RECPAG == "P"
							Execblock("F370E5P",.F.,.F.)
						Endif
						
						IF lPadrao
							If SE5->E5_RATEIO != "S"
								If !lCabecalho
									a370Cabecalho(@nHdlPrv,@cArquivo)
								Endif

								IF lUsaFlag
									CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
								ELSE
									AAdd(aRecsSE5,{ SE5->(Recno()),'FINM030','FK5',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')}) // Mov.Bancaria
								ENDIF

								nTotDoc	:= DetProva(nHdlPrv,cPadrao,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB)

								If cPadrao == "585" .And. LanceiCtb // Vem do DetProva
									For nJ := 1 To Len( aRecsSEI )
										SEI->( dbGoTo( aRecsSEI[nJ] ) )
										RecLock("SEI")
										SEI->EI_LA := "S"
										SEI->( MsUnlock() )
									Next nJ
								EndIf

								nTotProc	+= nTotDoc
								nTotal		+=	nTotDoc
								
								If MV_PAR12 == MVP12DOCUMENTO 
									IF nTotDoc > 0 // Por documento
										If lSeqCorr
											aDiario := {{"SE5",SE5->(recno()),SE5->E5_DIACTB,"E5_NODIA","E5_DIACTB"}}
										EndIf
										Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,@aDiario,dDataCtb)
									Endif
									LimpaArray(aFlagCTB)
								Endif
							Else
								
								If nHdlPrv <= 0
									a370Cabecalho(@nHdlPrv,@cArquivo)
								EndIf
								RegToMemory("SE5",.F.,.F.)

								IF lUsaFlag
									CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
								ELSE
									aAdd(aRecsSE5,{ SE5->(Recno()),'FINM030','FK5',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')}) // Mov.Bancaria
								ENDIF

								// Devido a estrutura do programa, o rateio ja eh "quebrado"
								// por documento.                                                          
								F370RatFin(cPadrao,"FINA370",cLote,4," ",4,,,,@nHdlPrv,@nTotDoc,@aFlagCTB)
								lCabecalho := If(nHdlPrv <= 0, lCabecalho, .T.)
								nTotProc	+= nTotDoc
								nTotal		+=	nTotDoc
								
								If MV_PAR12 == MVP12DOCUMENTO 
									If nTotDoc > 0 // Por documento
										If lSeqCorr
											aDiario := {{"SE5",SE5->(recno()),SE5->E5_DIACTB,"E5_NODIA","E5_DIACTB"}}
										EndIf
										Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,@aDiario,dDataCtb)
									Endif
									LimpaArray(aFlagCTB)
								Endif
							Endif
						EndIf

					// Baixas a Receber
					ElseIf SE5->E5_RECPAG == "R" .and. (mv_par06 == 1 .or. mv_par06 == 4)				    
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Contabilizacao de Recebimentos Diversos - Tabela SEL³
						//³Executada atraves das movimentacoes no SE5          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty( SE5->(E5_ORDREC + E5_SERREC) )
								
							// Paises localizados executam a rotina FINA371
							// que contabiliza tambem Ordem de Pago.
							If cPaisLoc == 'BRA' .and.;
								( SE5->E5_SERREC + SE5->E5_ORDREC ) <> ( cSELSerie + cSELRecibo )

								cSELSerie	:= SE5->E5_SERREC
								cSELRecibo	:= SE5->E5_ORDREC
						
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Controle de contabilizacao.              ³
								//³Percorre e contabiliza todos os registros³
								//³de um recibo.                            ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								F370CTBSEL(	cSELSerie,;
											cSELRecibo,;
											@nTotDoc,;
											cLote,;
											@nHdlPrv,;
											@cArquivo,;
											lUsaFlag,;
											@aFlagCTB,;
											@aCT5;
										)

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Separa por ?                                      ³
								//³Acumuladores para a geracao do Documento Contabil.³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If MV_PAR12 == MVP12PERIODO .and. nTotDoc > 0		// Por Periodo
									nTotal += nTotDoc
								ElseIf MV_PAR12 == MVP12DOCUMENTO 
									If nTotDoc > 0	// Por Documento
										Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataCtb)
										nTotDoc := 0 // Inicializa Variavel
									Endif
									LimpaArray(aFlagCTB)
								ElseIf MV_PAR12 == MVP12PROCESSO					// Por Processo
									nTotProc += nTotDoc
								Endif
							EndIf
							If AllTrim(SE5->E5_LA) == "S"
								(cAliasSE5)->(dbSkip()) // Nestes casos a movimentacao nao eh contabilizada pelo SE5
								Loop
							EndIf
						Endif
						// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ					
					
						lAdiant := (SE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG)
						lEstorno := (SE5->E5_TIPODOC == "ES")
						lEstRaNcc := (SE5->E5_TIPODOC == "ES" .and. SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG)
						lCompens := (SE5->E5_TIPODOC == "BA" .and. SE5->E5_MOTBX == "CMP")
						lEstCompens := (SE5->E5_TIPODOC == "ES" .and. SE5->E5_MOTBX == "CMP")

						VALOR := 0
						FO1VADI := 0
						aDadosFO1 := {}
		
						// Registros gerados pelo SIGALOJA - Pgto Dinheiro 
						// Contabilizar apenas quando E5_TIPODOC = 'VL' e E5_MOTBX == 'NOR'
						If SE5->E5_TIPODOC == 'BA' .AND. SE5->E5_MOTBX == 'LOJ' .AND. (SE5->E5_TIPO == cMvSimb1 .OR. SE5->E5_MOEDA == cMvSimb1)
							IF lUsaFlag
								CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
							ELSE	
								AADD(aRecsSE5, {SE5->(RECNO()), 'FINM010' ,'FK1',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} )
							ENDIF
							(cAliasSE5)->(dbSkip())
							LOOP
						EndIf
						
						// Despreza inclusao de RA que sera contabilizado pelo SE1
						If SE5->E5_TIPODOC == "RA" .and. SE5->E5_TIPO $ MVRECANT
							IF lUsaFlag
								CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
							ELSE	
								aAdd(aRecsSE5, {SE5->(RECNO()), 'FINM010' ,'FK1',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} )
							ENDIF
							(cAliasSE5)->(dbSkip())
							LOOP
						Endif

						// Despreza baixas por compensacao do titulo principal, para nao duplicar.
						If SE5->E5_TIPODOC == "CP" .and. SE5->E5_MOTBX == "CMP"
							lCompens := .T.
							IF lUsaFlag
								CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
							ELSE	
								aAdd(aRecsSE5, {SE5->(RECNO()), 'FINM010', 'FK1',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} ) //Baixas a Receber.
							ENDIF
							(cAliasSE5)->(dbSkip())
							LOOP
						Endif
											
						// Despreza estorno de compensacao do titulo de antecipação, para nao duplicar.
						If SE5->E5_TIPODOC == "ES" .and. SE5->E5_MOTBX == "CMP" .and. (SE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG)
							IF lUsaFlag
								CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
							ELSE	
								aAdd(aRecsSE5, {SE5->(RECNO()), 'FINM020', 'FK2',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} ) //Baixas a Pagar.
							ENDIF
							(cAliasSE5)->(dbSkip())
							LOOP
						Endif

						// Despreza movimento totalizador de Baixa Automática por Lote - (MV_BXCNAB = 'S')
						If EMPTY(SE5->(E5_PREFIXO+E5_NUMERO+E5_TIPO)) .AND. !EMPTY(E5_LOTE) .AND. E5_TIPODOC == 'VL'
							(cAliasSE5)->(dbSkip())
							LOOP
						EndIF

						// Despreza movimento Baixa quando MV_SLDBXCR = "C" para não duplicar, contabilizará pela SEF.
						If !EMPTY(SE5->E5_NUMCHEQ) .AND. E5_TIPODOC == 'BA' .AND. cMVSLDBXCR == "C"
							(cAliasSE5)->(dbSkip())
							LOOP
						EndIF

						If (lAdiant .or. lEstorno) .and. !lEstRaNcc
							dbSelectArea("SE2")
							SE2->(dbSetOrder(1))
							If !SE2->(MsSeek(xFilial("SE2")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA))
								If SE5->E5_MOTBX == "CMP" .and. !SE2->(MsSeek(SE5->E5_FILORIG+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA))
									// Localizada inconsistência no arquivo SE5. A função CTBCONSTSE5
									// pergunta se o usuário quer continuar ou abandonar.
									If !__lSchedule .And. !CTBCONSTSE5(lMultiThr)  .And. !lMultiThr
										Return .F.
									Endif
									dbSelectArea(cAliasSE5)
									(cAliasSE5)->(dbSkip())
									Loop
								Endif
							EndIf
						Else
							dbSelectArea( "SE1" )
							SE1->(dbSetOrder(2))
							
							cFilorig := IIf(lLjFlTitRc,LjFilTitRc(),xFilial("SE1"))
							If !SE1->(MsSeek(cFilOrig +SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO))
								If !Empty(SE5->E5_FILORIG)
									cFilOrig := SE5->E5_FILORIG
								Endif

								If !SE1->(MsSeek(cFilOrig +SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO))
									// Localizada inconsistência no arquivo SE5. A função CTBCONSTSE5
									// pergunta se o usuário quer continuar ou abandonar.
									If !lCompens .and. !(cChE5Comp == cFilOrig +SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO .and. SE5->E5_LA = cLa)	
										If !__lSchedule .And. !CTBCONSTSE5(lMultiThr)  .And. !lMultiThr
											Return .F.
										Endif
									EndIf
									dbSelectArea(cAliasSE5)
									(cAliasSE5)->(dbSkip())
									Loop
								Endif
							Endif

							//Carregar variável FO1VADI
							If Alltrim(SE5->E5_MOTBX) == "LIQ"
								cNumLiq := Alltrim(SE5->E5_DOCUMEN)
								If !Empty(SE5->E5_IDORIG)
									dbSelectArea("FO0")
									FO0->(dbSetOrder(2))
									FO0->(dbSeek(xFilial("FO0") + cNumLiq + SE5->E5_CLIFOR + SE5->E5_LOJA))
									aDadosFO1 := F460AbFO1(FO0->FO0_PROCES,FO0->FO0_VERSAO,SE5->E5_IDORIG)
									If Len(aDadosFO1) > 0
										FO1VADI := aDadosFO1[1,2]
									EndIf
								EndIf
							EndIf
							
							// Carrega variaveis para contabilizacao dos
							// abatimentos (impostos da lei 10925).
							dbSelectArea("__SE1")
							__SE1->(dbSetOrder(1))
							__SE1->(dbSeek(cFilOrig +SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA)))
							While __SE1->(!EOF()) .And.;
									__SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA) ==;
									(cFilOrig + SE5->(E5_PREFIXO + E5_NUMERO + E5_PARCELA))
								If __SE1->E1_TIPO == MVPIABT
									VALOR5 := __SE1->E1_VALOR			
								ElseIf __SE1->E1_TIPO == MVCFABT
									VALOR6 := __SE1->E1_VALOR
								ElseIf __SE1->E1_TIPO == MVCSABT
									VALOR7 := __SE1->E1_VALOR						
								Endif			
								__SE1->(dbSkip())
							Enddo

						Endif
						
						nPis:=0
						nCofins:=0
						nCsll:=0
						nVretPis:=0
						nVretCof:=0
						nVretCsl:=0
						VARIACAO := 0
						VARIACAORA := 0
						
						If (lAdiant .or. lEstorno) .and. !lEstRaNcc
							nValLiq	:= SE2->E2_VALLIQ
							nDescont := SE2->E2_DESCONT
							nJuros	:= SE2->E2_JUROS
							nMulta	:= SE2->E2_MULTA
							nCorrec	:= SE2->E2_CORREC
							If lPccBaixa
								nPis		:= SE2->E2_PIS
								nCofins	:= SE2->E2_COFINS
								nCsll		:= SE2->E2_CSLL
								nVretPis := SE2->E2_VRETPIS
								nVretCof := SE2->E2_VRETCOF
								nVretCsl := SE2->E2_VRETCSL
							Endif
						Else
							nValLiq	:= SE1->E1_VALLIQ
							nDescont := SE1->E1_DESCONT
							nJuros	:= SE1->E1_JUROS
							nMulta	:= SE1->E1_MULTA
							nCorrec	:= SE1->E1_CORREC
							cSitOri  := SE1->E1_SITUACA
						Endif
						
						dbSelectArea( "SE5" )
						nVl:=nDc:=nJr:=nMt:=VARIACAO:=VARIACAORA:=0
						lTitulo := .F.
						cSeq	  :=	SE5->E5_SEQ
						cBanco  := " "
						nRegSE5 := 0
						nRegOrigSE5 := 0
						nPisBx := 0
						nCofBx := 0
						nCslBx := 0

						dbSelectArea("SE5")

						If lTitulo := (SE5->E5_TIPODOC $ "BA|VL|V2|ES|LJ|CP")
							
							cBanco	:= SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA
							nRegSE5	:= SE5->(Recno())
							lMultnat:= SE5->E5_MULTNAT == "1"
							cSeqSE5	:= SE5->E5_SEQ
							nVl		:= E5_VALOR
							nDc 	:= SE5->E5_VLDESCO
							nJr		:= SE5->E5_VLJUROS
							nMt		:= SE5->E5_VLMULTA
							VARIACAO := SE5->E5_VLCORRE
							cSitCob	:= " "

							If !Empty(SE5->E5_SITCOB)
								cSitCob := SE5->E5_SITCOB
							Endif

							// Carrega as variaveis VALOR da Compensacao CR						
							If lCompens
								VARIACAORA := VARIACAO //Correção monetária do registro RA
								aAreaATU := SE5->(GetArea())
								SE5->(DbSetOrder(2)) //E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_DATA+E5_CLIFOR+E5_LOJA+E5_SEQ
								If SE5->(MsSeek(SE5->(E5_FILIAL+"CP"+PadR(E5_DOCUMEN,nTamDoc)+DTOS(E5_DATA)+E5_FORNADT+E5_LOJAADT+E5_SEQ))) .And. SE5->E5_SITUACA != 'C'
									
									// Disposição dos valores nas variáveis difere da contabilização online
									// http://tdn.totvs.com/display/PROT/FIN0003_LPAD_Variaveis_de_contabilizacao_da_compensacao_CR
									VALOR  := SE5->E5_VALOR
									VALOR2 := SE5->E5_VRETISS
									VALOR3 := SE5->E5_VRETINS
									VALOR4 := SE5->E5_VRETIRF
									VALOR5 := SE5->E5_VRETPIS
									VALOR6 := SE5->E5_VRETCOF
									VALOR7 := SE5->E5_VRETCSL
									VALOR8 := SE5->E5_VLACRES
									VALOR9 := SE5->E5_VLDESCO
									VARIACAO := SE5->E5_VLCORRE //Correção monetária do registro NF

									__nRecCmpCR:=SE5->(Recno())// Registro NF, para carregar valores acessorios em FINCARVAR()

									aAreaSE1 := SE1->(GetArea())
									SearchFor('SE1',1,XFILIAL('SE1',SE5->E5_FILORIG)+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA))								
									REGVALOR := SE1->(Recno()) // Variavel para usuario reposicionar o registro do SE1
									RestArea(aAreaSE1)															
									aSize(aAreaSE1,0)
									aAreaSE1 := nil 

								EndIf
								RestArea(aAreaATU)
								aSize(aAreaATU,0)
								aAreaATU := nil 
							EndIf

							If lPccBaixa
								IF Empty(SE5->E5_PRETPIS)
									nPisBx := SE5->E5_VRETPIS
									nCofBx := SE5->E5_VRETCOF
									nCslBx := SE5->E5_VRETCSL
								Endif
							Endif

						Endif
						
						IF lTitulo
							If lAdiant .and. !lEstCompens
								cPadrao := "530"
							ElseIf lEstCompens  //Estorno Compensacao Pagar
								cPadrao := "589"	
							ElseIf lEstRaNcc
								cPadrao := '527'
							Elseif lEstorno
								cPadrao := "531"
							ElseIf lCompens
								cPadrao := "596"
							Else
								dbSelectArea( "SE1" )
								If cPaisLoc == "CHI" .And. SE5->E5_MOTBX == "DEV"
									cPadrao := "574"
								Else
									cPadrao := fa070Pad()
								EndIf
							Endif
							
							IF (lPadrao := VerPadrao(cPadrao)) .OR. lMultnat

								IF lUsaFlag
									IF !EMPTY((cAliasSE5)->RECNOPA)
										nRecSE5Atu := SE5->(RECNO())
										SE5->(DBGOTO((cAliasSE5)->RECNOPA))
										CTBAddFlag(aFlagCTB,'')
										SE5->(DBGOTO(nRecSE5Atu))
									ENDIF								
									CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
								ELSE
									IF SE5->E5_TABORI == "FK1"
										AAdd( aRecsSE5, {SE5->(Recno()),'FINM010','FK1',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} ) //baixa a receber
									ELSE
										AAdd( aRecsSE5, {SE5->(Recno()),'FINM020','FK2',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} ) //  estorno de Baixas a pagar
									ENDIF
								ENDIF

								IF (lAdiant .or. lEstorno) .and. !lEstRaNcc
									// Protecao provisoria: lTitulo .T. sem SE2
									IF SE2->(!EOF()) .AND. SE2->(!BOF())
										Reclock("SE2",,,,lMultiTHR)
										Replace E2_VALLIQ  With nVl
										Replace E2_DESCONT With nDc
										Replace E2_JUROS	 With nJr
										Replace E2_MULTA	 With nMt
										Replace E2_CORREC  With IIF(!lCompens,VARIACAO,VARIACAORA)
										IF lPccBaixa
											Replace E2_PIS		With nPisBx
											Replace E2_COFINS	With nCofBx
											Replace E2_CSLL	With nCslBx
											Replace E2_VRETPIS	With nPisBx
											Replace E2_VRETCOF	With nCofBx
											Replace E2_VRETCSL	With nCslBx
										ENDIF
										SE2->(MsUnlock())
									ENDIF
								ELSE
									// Protecao provisoria: lTitulo .T. sem SE1
									IF SE1->(!EOF()) .AND. SE1->(!BOF())
										Reclock("SE1",,,,lMultiTHR)
										Replace E1_VALLIQ  With nVl
										Replace E1_DESCONT With nDc
										Replace E1_JUROS   With nJr
										Replace E1_MULTA   With nMt
										Replace E1_CORREC  With IIF(!lCompens,VARIACAO,VARIACAORA)
										If !Empty(cSitCob)
											Replace E1_SITUACA With cSitCob
										Endif
										SE1->( MsUnlock())
									ENDIF
								ENDIF

								// Posiciona no cliente/fornecedor e Natureza
								If (lAdiant .or. lEstorno) .and. !lEstRaNcc
									SearchFor('SA2',1,xFilial('SA2')+SE2->(E2_FORNECE+E2_LOJA))
									SearchFor('SED',1,xFilial('SED')+SE2->E2_NATUREZ)
								Else
									SearchFor('SA1',1,xFilial('SA1')+SE1->(E1_CLIENTE+E1_LOJA))
									SearchFor('SED',1,xFilial('SED')+SE1->E1_NATUREZ)
								Endif

								// Posiciona no banco
								SA6->(dbSetOrder(1))
								SA6->(MsSeek(xFilial("SA6")+cBanco))
							
								If !lCabecalho
									a370Cabecalho(@nHdlPrv,@cArquivo)
								Endif

								//Contabilizando estorno de C.Pagar
								If lMultnat
									If lEstorno
										cChaveSev := RetChaveSev("SE2")+"2"+cSeqSE5
										cChaveSez := RetChaveSev("SE2",,"SEZ")
									Else
										cChaveSev := RetChaveSev("SE1")+"2"+cSeqSE5
										cChaveSez := RetChaveSev("SE1",,"SEZ")
									Endif
								EndIf
								
								DbSelectArea("SEV")
								SEV->(dbSetOrder(2))
								// Se utiliza multiplas naturezas, contabiliza pelo SEV
								If  lMultNat .And. !EMPTY(cChaveSev) .AND. SearchFor('SEV',2,cChaveSev)
									nRecSe1 := SE1->(Recno())
									nRecSe2 := SE2->(Recno())
									
									DbSelectArea("SEV")
									
									While xFilial("SEV")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+;
										EV_LOJA+EV_IDENT+EV_SEQ) == cChaveSev .And. !SEV->(Eof())
										PulseLife() //- Pulso de vida da conexão
										//Se estou contabilizando um estorno, trata-se de um C. Pagar,
										//So vou contabilizar os EV_SITUACA == E
										If (lEstorno .and. !(SEV->EV_SITUACA == "E")) .or. ;
											(!lEstorno .and. (SEV->EV_SITUACA == "E"))
											//Se nao for um estorno, nao devo contabilizar o registro se
											//EV_SITUACA == E
											SEV->(dbSkip())
											Loop
										ElseIf lEstorno
											//O lancamento a ser considerado passa a ser o do estorno
											lPadraoCC := lPadraoCCE
										Endif
										
										If SEV->EV_LA != "S"
											// Posiciona na natureza, pois a conta pode estar la.
											SearchFor('SED',1,xFilial("SED")+SEV->EV_NATUREZ)
											dbSelectArea("SEV")
											lPadraoCc := VerPadrao("536")
											lPadraoCcE := VerPadrao("539")
											If SEV->EV_RATEICC == "1" .and. If(lEstorno,lPadraoCcE,lPadraoCc) // Rateou multinat por c.custo
                                                If lUsaFlag
                                                    aAdd(aFlagCTB,{"EV_LA","S","SEV",SEV->(Recno()),0,0,0})
                                                EndIf

												// Posiciona no arquivo de Rateio C.Custo da MultiNat
												SearchFor('SEZ',4,cChaveSeZ+SEV->EV_NATUREZ+"2"+cSeqSE5)
												While SEZ->(!Eof()) .and.;
														xFilial("SEZ")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+;
														EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT+EZ_SEQ) == cChaveSeZ+SEV->EV_NATUREZ+"2"+cSeqSE5
													
													//Se estou contabilizando um estorno, trata-se de um C. Pagar,
													//So vou contabilizar os EZ_SITUACA == E
													//Se nao for um estorno, nao devo contabilizar o registro se
													//EZ_SITUACA == E
													If (lEstorno .and. !(SEZ->EZ_SITUACA == "E")) .or. ;
														(!lEstorno .and. (SEZ->EZ_SITUACA == "E"))
														SEZ->(dbSkip())
														Loop
													Endif
													If SEZ->EZ_LA != "S"
														aAdd(aFlagCTB,{"EZ_LA","S","SEZ",SEZ->(Recno()),0,0,0})
														//O lacto padrao fica:
														//536 - Rateio multinat com c.custo C.Receber
														//539 - Estorno de Rat. Multinat C.Custo C.Pagar
														cPadraoCC := If(SEZ->EZ_SITUACA == "E","539","536")
														VALOR := SEZ->EZ_VALOR
														nTotDoc	+=	DetProva(nHdlPrv,cPadraoCC,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB)
														If LanceiCtb // Vem do DetProva
															If !lUsaFlag
																RecLock("SEZ")
																SEZ->EZ_LA := "S"
																SEZ->(MsUnlock())
															EndIf
														ElseIf lUsaFlag
															If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == SEZ->(Recno()) }))>0
																aFlagCTB := Adel(aFlagCTB,nPosReg)
																aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
															Endif
														Endif
													Endif
													SEZ->(dbSkip())
												Enddo
											Else
												If lUsaFlag
													aAdd(aFlagCTB,{"EV_LA","S","SEV",SEV->(Recno()),0,0,0})
												EndIf
												nTotDoc := DetProva(nHdlPrv,cPadrao,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB,{'SEV',SEV->(RECNO())})
											Endif
											
											If LanceiCtb // Vem do DetProva
												If !lUsaFlag
													RecLock("SEV")
													SEV->EV_LA := "S"
													SEV->(MsUnlock())
												EndIf
											ElseIf lUsaFlag
												If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == SEV->(Recno()) }))>0
													aFlagCTB := Adel(aFlagCTB,nPosReg)
													aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
												Endif
											Endif
										Endif
										SEV->(DbSkip())
										VALOR := 0
									Enddo
									nTotProc +=	nTotDoc // Totaliza por processo
									nTotal +=	nTotDoc
									
									If MV_PAR12 == MVP12DOCUMENTO 
										If nTotDoc > 0 // Por documento
											Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataCtb)
											nTotDoc := 0
										Endif
										LimpaArray(aFlagCTB)
									Endif
							
									dbSelectArea("SE2")
									SE2->(MsGoto(nRecSe2))
									
									dbSelectArea("SE1")
									SE1->(MsGoto(nRecSe1))
								Else
									SEV->(DBGOTO(0))

									DbSelectArea("SE1")
									If SE1->E1_TIPO == MVPIABT
										VALOR5 := SE1->E1_VALOR			
									ElseIf SE1->E1_TIPO == MVCFABT
										VALOR6 := SE1->E1_VALOR
									ElseIf SE1->E1_TIPO == MVCSABT
										VALOR7 := SE1->E1_VALOR											
									ElseIf Iif(!Empty(SE1->E1_SITUACA), (FN022SITCB(SE1->E1_SITUACA)[6]) , .F. ) // Situação de Cobrança: Cobrança Simples 
										nBordero += SE5->E5_VALOR
										nValorTotal += SE5->E5_VALOR

										IF MV_PAR12 == MVP12DOCUMENTO .AND. MV_PAR13 == MVP13TOTBOR
											CTBLOTECNAB(aLoteCNAB,ALLTRIM(SE5->E5_LOTE),ALLTRIM(SE5->E5_DOCUMEN),SE5->E5_VALOR)
										ENDIF
									Endif	
									
									If lCompens .OR. (cPadrao == '521')
										STRLCTPAD := SE5->E5_DOCUMEN
										If !ALLTRIM(STRLCTPAD) $ cLstBor
											cLstBor += If(!EMPTY(cLstBor),':','') + ALLTRIM(STRLCTPAD)
										EndIf
									EndIf
									
									nTotDoc	:= DetProva(nHdlPrv,cPadrao,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB)
									nTotProc += nTotDoc
									nTotal += nTotDoc								

									// Controle de Borderos
									IF !EMPTY(cNumBor)
										IF lUsaFlag
											CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
										ELSE
											AAdd( aRecsSE5, {SE5->(Recno()),'FINM010','FK1',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} )
										ENDIF

										(cAliasSE5)->(dbSkip())
										lAvancaReg := .F.
										IF (cAliasSE5)->E5_TIPODOC $ "BA|VL|V2|ES|LJ|CP"
											cProxBor := PADR((cAliasSE5)->E5_DOCUMEN,nTamBor)
										ELSE
											cProxBor := SPACE(nTamBor)
										ENDIF
									ENDIF
									
									If MV_PAR12 == MVP12DOCUMENTO .AND. (cPadrao <> '521' .OR. (cPadrao == '521' .AND. EMPTY(cNumBor)))
										If nTotDoc > 0 // Por documento
											Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataCtb)
										Endif
										LimpaArray(aFlagCTB)
									Endif
								Endif
							Endif

							VALOR2 := 0
							VALOR3 := 0
							VALOR4 := 0
							VALOR5 := 0
							VALOR6 := 0
							VALOR7 := 0
							VALOR8 := 0
							VALOR9 := 0
							REGVALOR := 0
							__nRecCmpCR:=0
							
							// Devolve a posição original do arquivo
							If nRegOrigSE5 > 0
								SE5->(dbGoTo(nRegOrigSE5))
							Endif
							If !lAdiant .and. !lEstorno
								dbSelectArea("SE1")
								If !SE1->(Eof()) .And. !SE1->(Bof())
									Reclock("SE1",,,,lMultiTHR)
									Replace SE1->E1_VALLIQ With nValliq
									Replace SE1->E1_DESCONT With nDescont
									Replace SE1->E1_JUROS With nJuros
									Replace SE1->E1_MULTA With nMulta
									Replace SE1->E1_CORREC With nCorrec
									Replace SE1->E1_SITUACA With cSitOri
									SE1->(MsUnlock())
								EndIF
							Else
								dbSelectArea("SE2")
								If !SE2->(Eof()) .And. !SE2->(Bof())
									Reclock("SE2",,,,lMultiTHR)
									Replace SE2->E2_VALLIQ With nValliq
									Replace SE2->E2_DESCONT With nDescont
									Replace SE2->E2_JUROS With nJuros
									Replace SE2->E2_MULTA With nMulta
									Replace SE2->E2_CORREC With nCorrec
									If lPccBaixa
										Replace SE2->E2_PIS With nPis
										Replace SE2->E2_COFINS With nCofins
										Replace SE2->E2_CSLL With nCsll
										Replace SE2->E2_VRETPIS With nVretPis
										Replace SE2->E2_VRETCOF With nVretCof
										Replace SE2->E2_VRETCSL With nVretCsl
									Endif
									SE2->(MsUnlock())
								EndIf
							Endif
						Endif

					// Baixas a Pagar
					ElseIf SE5->E5_RECPAG == "P" .and.  (mv_par06 == 2 .or. mv_par06 == 4)

						dbSelectArea( "SE5" )
						VALOR 		:= 0
						VALOR2		:= 0
						VALOR3		:= 0
						VALOR4		:= 0
						VALOR5		:= 0
						VALOR6		:= 0
						VALOR7		:= 0
						VALOR8		:= 0
						VALOR9		:= 0

						lAdiant := (SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG)
						lEstorno := (SE5->E5_TIPODOC == "ES")
						lEstPaNdf := (SE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG .and. SE5->E5_TIPODOC == "ES")
						lEstCart2 := (SE5->E5_TIPODOC == "E2")
						lCompens := (SE5->E5_TIPODOC == "CP" .and. SE5->E5_MOTBX == "CMP")
						lEstCompens := (SE5->E5_TIPODOC == "ES" .and. SE5->E5_MOTBX == "CMP")

						BEGIN SEQUENCE
							// Despreza baixas do titulo de antecipação, para nao duplicar.
							If SE5->E5_TIPODOC == "BA" .and. SE5->E5_MOTBX == "CMP"
								IF lUsaFlag
									CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
								ELSE
									AAdd( aRecsSE5, {SE5->(Recno()),'FINM020','FK2',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} ) // Baixas a pagar.
								ENDIF
								BREAK
							Endif
								
							// Despreza inclusao de PA que sera contabilizado pelo SE2
							If SE5->E5_TIPODOC == "PA" .and. SE5->E5_TIPO $ MVPAGANT
								BREAK
							Endif

							//Nao serão contabilizadas os movimentos de troco de vendas do sigaloja pela SE5. Há um trecho específico para contabilização dos mesmos pela FK5.
							If SE5->E5_TIPODOC $ "VL#TR" .AND. !Empty(SE5->E5_NUMERO) .and. SE5->E5_MOEDA == "TC"
								If Upper(AllTrim(SE5->E5_NATUREZ)) $ Upper(cNatTroc) //"Troco"  
									BREAK
								EndIf
							EndIf

							// Despreza estorno de compensacao do titulo principal, para nao duplicar.
							If SE5->E5_TIPODOC == "ES" .and. SE5->E5_MOTBX == "CMP" .and. !(SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG)
								IF lUsaFlag
									CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
								ELSE
									AAdd( aRecsSE5, {SE5->(Recno()),'FINM010','FK1',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} ) // Baixas a receber.
								ENDIF
								BREAK
							Endif

							// Apenas contabiliza se :
							// For realmente uma baixa de contas a PAGAR
							// mv_ctbaixa diferente de "C" - Cheque
							// Ou se for igual a C e for uma baixa no banco caixa
							If !lAdiant .and. !lEstorno .and. !lEstCart2
								If cCtBaixa == "C" .And. SE5->E5_MOTBX == "NOR" .And.;
									If(cPaisLoc == 'BRA', Empty(SE5->E5_AGLIMP), .T.) .And.;
									!(Substr(SE5->E5_BANCO,1,2)=="CX" .or. SE5->E5_BANCO$cCarteira)
									dbSelectArea(cAliasSE5)

									// Verificando a continuação do bordero
									If !Empty(cNumBor)
										IF lUsaFlag
											CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
										ELSE
											AAdd( aRecsSE5, {SE5->(Recno()),'FINM020','FK2',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} )
										ENDIF
									
										(cAliasSE5)->(dbSkip())
										lAvancaReg := .F.

										If (cAliasSE5)->(!Eof()) .AND. (&cCondWhile) 
											cProxBor := PADR((cAliasSE5)->E5_DOCUMEN,nTamBor)
										else
											cProxBor := ""
										EndIf
									EndIf
									BREAK
								Endif
							Endif
								
							// A baixa de adiantamento ou estorno de baixa a receber gera registro a pagar
								
							If (lAdiant .or. lEstorno .or. lEstCart2) .and. !lEstPaNdf
								SE1->(dbSetOrder(2))
								If !SE1->(MsSeek(xFilial("SE1")+SE5->(E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)))
									If SE5->E5_MOTBX == "CMP" .and. !SE1->(MsSeek(SE5->(E5_FILORIG+E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)))
										// Localizada inconsistência no arquivo SE5.
										// A função CTBCONSTSE5 pergunta se o usuário quer continuar ou abandonar
										// verifica se a compensação do Adiantamento foi contabilizado RECPAG= R e TIPODOC= BA 
										If (!lEstCompens ) 
											If !__lSchedule .And. !CTBCONSTSE5(lMultiThr)  .And. !lMultiThr
												Return .F.
											Endif
										Else
											cChE5Comp := SE5->(E5_FILORIG+E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)
											cLA := SE5->E5_LA
										EndIf
										dbSelectArea(cAliasSE5)
										BREAK
									EndIf
								Endif
							Else
								SE2->(dbSetOrder(1))
								cFilorig := xFilial("SE2")
								If !SE2->(MsSeek(cFilOrig+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))
									If !Empty(SE5->E5_FILORIG)
										cFilOrig := SE5->E5_FILORIG
									Else
										cFilOrig := SE5->E5_FILIAL
									Endif

									If !SE2->(MsSeek(cFilOrig+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))
										//Se for o totalizador da baixa automatica, nao pode ser gerada mensagem
										If lBxCnab .and. AllTrim(SE5->E5_ORIGEM) $ "FINA090|FINA091|FINA300|FINA430|FINA740|FINA750" .AND.;
											SE5->E5_TIPODOC == "VL" .AND. !Empty(SE5->E5_LOTE) .AND.;
											Empty(SE5->(E5_TIPO+E5_DOCUMEN+E5_NUMERO+E5_PARCELA+E5_CLIFOR+E5_LOJA))
											dbSelectArea(cAliasSE5)
											BREAK
										EndIf
										
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Localizada inconsistência no arquivo SE5. A função CTBCONSTSE5	 ³
										//³ pergunta se o usuário quer continuar ou abandonar.				 ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If !__lSchedule .And. !CTBCONSTSE5(lMultiThr)  .And. !lMultiThr
											Return .F.
										Endif
										dbSelectArea(cAliasSE5)
										BREAK
									Endif
								Endif
								
								// Nao contabiliza titulos de impostos aglutinados com origem na rotina FINA378
								// Neste caso o Parâmetro de contabilização dos impostos aglutinados inverte a operação
								If !lAGP .and. !lMvAGP
									// Aglutinacao Pis/Cofins/Csll
									If AllTrim( Upper( SE2->E2_ORIGEM ) ) == "FINA378" .And. SE2->E2_PREFIXO == "AGP"
										BREAK
									Endif
								ElseIf AllTrim(SE2->E2_CODRET) == "5952" .And.;
										((SE2->E2_PREFIXO != "AGP" .And. !Empty(SE2->E2_TITPAI)) .And. AllTrim(SE2->E2_ORIGEM) != "FINA378") .And.;
										(lF370ChkAgp .And. F370ChkAgp())

									IF lUsaFlag
										CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
									ELSE
										AAdd( aRecsSE5, {SE5->(Recno()),'FINM020','FK2',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} )
									ENDIF

									BREAK
								EndIf					
							Endif
								
							nPis:=0
							nCofins:=0
							nCsll:=0
							nVretPis:=0
							nVretCof:=0
							nVretCsl:=0
							
							If (lAdiant .or. lEstorno .or. lEstCart2) .and. !lEstPaNdf
								nValLiq := SE1->E1_VALLIQ
								nDescont := SE1->E1_DESCONT
								nJuros := SE1->E1_JUROS
								nMulta := SE1->E1_MULTA
								nCorrec := SE1->E1_CORREC
							Else
								nValLiq := SE2->E2_VALLIQ
								nDescont := SE2->E2_DESCONT
								nJuros := SE2->E2_JUROS
								nMulta := SE2->E2_MULTA
								nCorrec := SE2->E2_CORREC
								If lPccBaixa
									nPis := SE2->E2_PIS
									nCofins := SE2->E2_COFINS
									nCsll := SE2->E2_CSLL
									nVretPis := SE2->E2_VRETPIS
									nVretCof := SE2->E2_VRETCOF
									nVretCsl := SE2->E2_VRETCSL
								Endif
							Endif
							
							dbSelectArea( "SE5" )
							nVl:=nDc:=nJr:=nMt:=VARIACAO:=VARIACAORA:=0
							lTitulo := .F.
							cSeq := SE5->E5_SEQ
							cBanco := " "
							nRegSE5 := 0
							nRegOrigSE5 := 0
							
							STRLCTPAD := SE5->E5_DOCUMEN
							If SE5->(FieldPos("E5_FORNADT")) > 0
								CODFORCP := SE5->E5_FORNADT
								LOJFORCP := SE5->E5_LOJAADT
							EndIf
				
							nPisBx := 0
							nCofBx := 0
							nCslBx := 0
							
							If lTitulo := (SE5->E5_TIPODOC $ "BA/VL/V2/ES/LJ/E2/CP")
								cBanco := SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA)
								cCheque := SE5->E5_NUMCHEQ          
								nRegSE5 := SE5->(Recno())
								lMultnat := SE5->E5_MULTNAT == "1"
								cSeqSE5 := SE5->E5_SEQ
								nVl := SE5->E5_VALOR
								nDc := SE5->E5_VLDESCO
								nJr := SE5->E5_VLJUROS
								nMt := SE5->E5_VLMULTA
								VARIACAO := SE5->E5_VLCORRE
								
								If lCompens
									aAreaATU := SE5->(GetArea())
									SE5->(DbSetOrder(2)) //E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_DATA+E5_CLIFOR+E5_LOJA+E5_SEQ
									If SE5->(MsSeek(SE5->(E5_FILIAL+"BA"+PadR(E5_DOCUMEN,nTamDoc)+DTOS(E5_DATA)+E5_FORNADT+E5_LOJAADT+E5_SEQ))) .And. SE5->E5_SITUACA != 'C'
											
										aAreaSE2 := SE2->(GetArea())
										SearchFor('SE2',1,XFILIAL('SE2',SE5->E5_FILORIG)+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA))
										nVlDecresc := SE2->E2_DECRESC
										nVlAcresc := SE2->E2_ACRESC
										REGVALOR := SE2->(Recno()) // Variavel para usuario reposicionar o registro do SE2
										RestArea(aAreaSE2)
										aSize(aAreaSE2,0)
										aAreaSE2 := nil 
			
										// Disposição dos valores nas variáveis difere da contabilização online
										// http://tdn.totvs.com/display/PROT/FIN0020_LPAD_Variaveis_de_contabilizacao_da_compensacao_CP
										VALOR := SE5->E5_VALOR
										VALOR2 := nVlAcresc
										VALOR3 := nVlDecresc
										VALOR4 := SE5->E5_VLCORRE
										VARIACAO := SE5->E5_VLCORRE
									EndIf
									RestArea(aAreaATU)
									aSize(aAreaATU,0)
									aAreaATU := nil 
								Elseif lEstCompens // Carrega as variaveis do estorno da Compensacao CR
									VARIACAORA := VARIACAO //Armazena a correção monetária do RA antes do posicionamento na NF logo abaixo
									aAreaATU := SE5->(GetArea())
									SE5->(DbSetOrder(2)) //E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_DATA+E5_CLIFOR+E5_LOJA+E5_SEQ
									If SE5->(MsSeek(SE5->(E5_FILIAL+E5_TIPODOC+PadR(E5_DOCUMEN,nTamDoc)+DTOS(E5_DATA)+E5_FORNADT+E5_LOJAADT+E5_SEQ)))
										
										// Disposição dos valores nas variáveis difere da contabilização online
										// http://tdn.totvs.com/display/PROT/FIN0003_LPAD_Variaveis_de_contabilizacao_da_compensacao_CR
										VALOR  := SE5->E5_VALOR
										VALOR2 := SE5->E5_VRETISS
										VALOR3 := SE5->E5_VRETINS
										VALOR4 := SE5->E5_VRETIRF
										VALOR5 := SE5->E5_VRETPIS
										VALOR6 := SE5->E5_VRETCOF
										VALOR7 := SE5->E5_VRETCSL
										VALOR8 := SE5->E5_VLACRES
										VALOR9 := SE5->E5_VLDESCO
										VARIACAO := SE5->E5_VLCORRE //Correção monetária do registro NF
									EndIf
									RestArea(aAreaATU)
									aSize(aAreaATU,0)
									aAreaATU := nil 
								EndIf						

								If lPccBaixa
									IF Empty(SE5->E5_PRETPIS)
										nPisBx := SE5->E5_VRETPIS
										nCofBx := SE5->E5_VRETCOF
										nCslBx := SE5->E5_VRETCSL
									Endif
								Endif

								// Verificando a continuação do bordero
								If !Empty(cNumBor)
									IF lUsaFlag
										CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
									ELSE
										AAdd( aRecsSE5, {SE5->(Recno()),'FINM020','FK2',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} )
									ENDIF

									(cAliasSE5)->(dbSkip())
									lAvancaReg := .F.

									If (cAliasSE5)->(!Eof()) .AND. (&cCondWhile) .AND. SE5->E5_RECPAG == (cAliasSE5)->E5_RECPAG
										cProxBor := PADR((cAliasSE5)->E5_DOCUMEN,nTamBor)
									else
										cProxBor := ""
									EndIf
								EndIf
							EndIf
							
							If lTitulo
								If lEstorno .and. lEstPaNdf
									cPadrao := "531"
								ElseIf lEstCompens  //Estorno Compensacao Receber
									cPadrao := "588"									
								ElseIf lEstorno
									cPadrao := "527"								
									If Iif(!Empty(SE1->E1_SITUACA), (FN022SITCB(SE1->E1_SITUACA)[6]) , .F. ) // Situação de Cobrança: Cobrança Simples 
										VALOR := SE1->E1_VALOR
									EndIf
								Elseif lEstCart2
									cPadrao := "540"
								ElseIf lAdiant
									cPadrao := SE1->(fa070Pad())
								Elseif lCompens
									cPadrao := "597"
									cProxBor := ""
								Else
									cPadrao := Iif(Empty(SE5->E5_DOCUMEN) .Or. SE5->E5_MOTBX $ "PCC|LIQ|IRF" .Or. "FINA080" $ SE5->E5_ORIGEM,"530","532")
									// Ponto de Entrada para validar lançamento padrão
									If l370BORD
										cPadrao := Execblock("F370BORD",.F.,.F.,{cNumBor})
									EndIf
								Endif
								
								IF (lPadrao := VerPadrao(cPadrao)) .OR. lMultNat 

									// Atualiza Flag de Lançamento Contábil
									nRegAnt := SE5->(Recno())
									If (aScan(aRecsSE5,{|x| x[1]==nRegAnt}) == 0)
										IF SE5->E5_TIPODOC $ "BA|VL|V2|ES|LJ|CP"
											If Alltrim(SE5->E5_TIPODOC) == "ES" .And. !Empty(SE5->E5_NUMCHEQ)
												AAdd( aRecsSE5, {SE5->(Recno()),'FINM030','FK5',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} ) //  estorno de cheque
											Else 
												If SE5->E5_TABORI == "FK1" .OR.;
													(SE5->E5_RECPAG == "R" .and. SE5->E5_TIPODOC <> "ES" .and. !SE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG) .OR.;
													(SE5->E5_RECPAG == "P" .and. SE5->E5_TIPODOC == "ES" .and. !SE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG) .OR.;
													(SE5->E5_RECPAG == "P" .and. SE5->E5_TIPODOC <> "ES" .and. SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG)  

													AAdd( aRecsSE5, {SE5->(Recno()),'FINM010','FK1',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} ) //baixa a receber
												Else
													AAdd( aRecsSE5, {SE5->(Recno()),'FINM020','FK2',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} ) //  estorno de Baixas a pagar
												Endif
											EndIf	
										Else
											AAdd( aRecsSE5, {SE5->(Recno()),'','',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} ) //Valores acessórios
										EndIf

										IF lUsaFlag
											IF !EMPTY((cAliasSE5)->RECNOPA)
												nRecSE5Atu := SE5->(RECNO())
												SE5->(DBGOTO((cAliasSE5)->RECNOPA))
												CTBAddFlag(aFlagCTB,'')
												SE5->(DBGOTO(nRecSE5Atu))
											ENDIF
											CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
										ENDIF									
									Endif

									If (lAdiant .or. lEstorno .or. lEstCart2) .and. !lEstPaNdf
										// Protecao provisoria: lTitulo .T. sem SE1
										IF SE1->(!EOF()) .AND. SE1->(!BOF())
											Reclock("SE1",,,,lMultiTHR)
											Replace SE1->E1_VALLIQ With nVl
											Replace SE1->E1_DESCONT With nDc
											Replace SE1->E1_JUROS With nJr
											Replace SE1->E1_MULTA With nMt
											Replace SE1->E1_CORREC With VARIACAO
											SE1->(MsUnlock())
										ENDIF
									Else
										// Protecao provisoria: lTitulo .T. sem SE2
										IF SE2->(!EOF()) .AND. SE2->(!BOF())
											Reclock("SE2",,,,lMultiTHR)
											Replace SE2->E2_VALLIQ With nVl
											Replace SE2->E2_DESCONT With nDc
											Replace SE2->E2_JUROS With nJr
											Replace SE2->E2_MULTA With nMt
											Replace SE2->E2_CORREC With VARIACAO
											If lPccBaixa
												Replace SE2->E2_PIS With nPisBx
												Replace SE2->E2_COFINS With nCofBx
												Replace SE2->E2_CSLL With nCslBx
												Replace SE2->E2_VRETPIS With nPisBx
												Replace SE2->E2_VRETCOF With nCofBx
												Replace SE2->E2_VRETCSL With nCslBx
											Endif
											SE2->(MsUnlock())
										ENDIF
									Endif

									// Posiciona no fornecedor
									If (lAdiant .or. lEstorno .or. lEstCart2) .and. !lEstPaNdf
										SearchFor('SA1',1,xFilial('SA1')+SE1->(E1_CLIENTE+E1_LOJA))
										SearchFor('SED',1,xFilial('SED')+SE1->E1_NATUREZ)
									Else
										SearchFor('SA2',1,xFilial('SA2')+SE2->E2_FORNECE+SE2->E2_LOJA)
										SearchFor('SED',1,xFilial('SED')+SE2->E2_NATUREZ)
									Endif
									
									// Posiciona no banco
									SearchFor('SA6',1,xFilial('SA6')+cBanco)
									dbSelectArea("SE5")

									If lUsaFlag .and. lAvancaReg
										CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
									EndIf

									// Totalizo por Bordero
									If cPadrao = "532"
										nValorTotal += SE2->E2_VALLIQ
										nBordero += SE2->E2_VALLIQ
										nTotBord += SE2->E2_VALLIQ
										nBordDc += SE2->E2_DESCONT
										nBordJr += SE2->E2_JUROS
										nBordMt += SE2->E2_MULTA
										nBordCm += SE2->E2_CORREC
										If !ALLTRIM(STRLCTPAD) $ cLstBor
											cLstBor += If(!EMPTY(cLstBor),':','') + ALLTRIM(STRLCTPAD)
										EndIf
									Endif

									If !lCabecalho
										a370Cabecalho(@nHdlPrv,@cArquivo)
									Endif

									// Se utiliza multiplas naturezas, contabiliza pelo SEV
									If  lMultNat 						
										//Contabilizando estorno de C.Receber
										If lEstorno
											cChaveSev := RetChaveSev("SE1")+"2"+cSeqSE5
											cChaveSez := RetChaveSev("SE1",,"SEZ")
										Else
											cChaveSev := RetChaveSev("SE2")+"2"+cSeqSE5
											cChaveSez := RetChaveSev("SE2",,"SEZ")
										Endif
								
										If SearchFor('SEV',2,cChaveSev)
				
											nValorTotal -= SE2->E2_VALLIQ							

											nRecSe2 := SE2->(RECNO())
											nRecSe1 := SE1->(RECNO())
											
											While SEV->(!Eof()) .AND.;
													xFilial("SEV")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+;
													EV_CLIFOR+EV_LOJA+EV_IDENT+EV_SEQ) == cChaveSev
													
												//Se estou contabilizando um estorno, trata-se de um C. Pagar,
												//So vou contabilizar os EV_SITUACA == E
												//Se nao for um estorno, nao devo contabilizar o registro se
												//EV_SITUACA == E
												lPadraoCc := VerPadrao("537") //Rateio por C.Custo de MultiNat C.Pagar
												lPadraoCcE := VerPadrao("538") //Estorno do rateio C.Custo de MultiMat CR
												If (lEstorno .and. !(SEV->EV_SITUACA == "E")) .or. ;
													(!lEstorno .and. (SEV->EV_SITUACA == "E"))
													SEV->(dbSkip())
													Loop
												ElseIf lEstorno
													//O lancamento a ser considerado passa a ser o do estorno
													lPadraoCC := lPadraoCCE
												Endif
												
												If SEV->EV_LA != "S"
													// Posiciona na natureza, pois a conta pode estar la.
													SearchFor('SED',1,xFilial("SED")+SEV->EV_NATUREZ)
													dbSelectArea("SEV")

													If SEV->EV_RATEICC == "1" .and. lPadraoCC // Rateou multinat por c.custo
                                                        If lUsaFlag
                                                            aAdd(aFlagCTB,{"EV_LA","S","SEV",SEV->(Recno()),0,0,0})
                                                        EndIf
														// Posiciona no arquivo de Rateio C.Custo da MultiNat
														SearchFor('SEZ',4,cChaveSeZ+SEV->EV_NATUREZ+"2"+cSeqSE5)
														While SEZ->(!Eof()) .AND.;
																xFilial("SEZ")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+;
																EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT+EZ_SEQ) == cChaveSeZ+SEV->EV_NATUREZ+"2"+cSeqSE5
															
															//Se estou contabilizando um estorno, trata-se de um C. Pagar,
															//So vou contabilizar os EZ_SITUACA == E
															//Se nao for um estorno, nao devo contabilizar o registro se
															//EZ_SITUACA == E
															If (lEstorno .and. !(SEZ->EZ_SITUACA == "E")) .or. ;
																(!lEstorno .and. (SEZ->EZ_SITUACA == "E"))
																SEZ->(dbSkip())
																Loop
															Endif
															If SEZ->EZ_LA != "S"
																If lUsaFlag
																	aAdd(aFlagCTB,{"EZ_LA","S","SEZ",SEZ->(Recno()),0,0,0})
																EndIf
																//O lacto padrao fica:
																//537 - Rateio multinat com c.custo C.Pagar
																//538 - Estorno de Rat. Multinat C.Custo C.Receber
																cPadraoCC := If(SEZ->EZ_SITUACA == "E","538","537")
																VALOR := SEZ->EZ_VALOR
																nTotDoc += DetProva(nHdlPrv,cPadraoCC,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB)
																If LanceiCtb // Vem do DetProva
																	If !lUsaFlag
																		RecLock("SEZ")
																		SEZ->EZ_LA := "S"
																		SEZ->(MsUnlock())
																	EndIf
																ElseIf lUsaFlag
																	If (nPosReg := aScan(aFlagCTB,{ |x| x[4] == SEZ->(Recno()) }))>0
																		aFlagCTB := Adel(aFlagCTB,nPosReg)
																		aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
																	Endif
																Endif
															Endif
															SEZ->(dbSkip())
														Enddo
													Else
														If lUsaFlag
															aAdd(aFlagCTB,{"EV_LA","S","SEV",SEV->(Recno()),0,0,0})
														EndIf
														nTotDoc := DetProva(nHdlPrv,cPadrao,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB,{'SEV',SEV->(RECNO())})
													Endif

													If LanceiCtb // Vem do DetProva
														If !lUsaFlag
															RecLock("SEV")
															SEV->EV_LA := "S"
															SEV->(MsUnlock())
														EndIf
													ElseIf lUsaFlag
														If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == SEV->(Recno()) }))>0
															aFlagCTB := Adel(aFlagCTB,nPosReg)
															aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
														Endif			
													Endif
												Endif
												DbSelectArea("SEV")
												SEV->(DbSkip())
												VALOR := 0
											Enddo
											nTotProc	+=	nTotDoc // Totaliza por processo
											nTotal  	+=	nTotDoc
											
											If MV_PAR12 == MVP12DOCUMENTO 
												IF nTotDoc > 0 // Por documento
													Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataCtb)
													nTotDoc := 0
												Endif
												LimpaArray(aFlagCTB)
											Endif

											VALOR := 0									
											VALOR2 := 0
											VALOR3 := 0
											REGVALOR := 0
											
											SE1->(DbGoto(nRecSe1))
											SE2->(DbGoto(nRecSe2))
										EndIf
									Else
										SEV->(DBGOTO(0))

										nTotDoc := DetProva(nHdlPrv,cPadrao,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB)
										nTotProc += nTotDoc
										nTotal += nTotDoc

										If MV_PAR12 == MVP12DOCUMENTO 
											If Empty( cProxBor ) .and. cPadrao <> "532"
												If nTotDoc > 0 // Por Documento
													Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataCtb)
													nTotDoc := 0
												Endif
												LimpaArray(aFlagCTB)
											Endif
										Endif
									Endif
								Endif

								If (lAdiant .or. lEstorno .or. lEstCart2) .and. !lEstPaNdf
									If SE1->(!Eof() .And. !Bof())
										Reclock("SE1",,,,lMultiTHR)
										Replace SE1->E1_VALLIQ With nValliq
										Replace SE1->E1_DESCONT With nDescont
										Replace SE1->E1_JUROS With nJuros
										Replace SE1->E1_MULTA With nMulta
										Replace SE1->E1_CORREC With nCorrec
										SE1->(MsUnlock())
									EndIF
								Else
									If SE2->(!Eof() .And. !Bof())
										Reclock("SE2",,,,lMultiTHR)
										Replace SE2->E2_VALLIQ With nValliq
										Replace SE2->E2_DESCONT With nDescont
										Replace SE2->E2_JUROS With nJuros
										Replace SE2->E2_MULTA With nMulta
										Replace SE2->E2_CORREC With nCorrec
										If lPccBaixa
											Replace SE2->E2_PIS With nPis
											Replace SE2->E2_COFINS With nCofins
											Replace SE2->E2_CSLL With nCsll
											Replace SE2->E2_VRETPIS With nVretPis
											Replace SE2->E2_VRETCOF With nVretCof
											Replace SE2->E2_VRETCSL With nVretCsl
										Endif
										SE2->(MsUnlock())
									EndIf
								Endif

								dbSelectArea("SE5")
							Endif

						END SEQUENCE
					Endif

					// Disponibilizo a Variavel VALOR com o total dos borderos considerando as configurações.
					// O Parâmetro 'Por Documento' equivale ao parâmetro 'Totaliza Bordero/Bordero'
					// Totalização pela quebra da carteira (LP532-Bordero X )
					If lPadrao .AND.;
                        (nBordero+nBordDc+nBordMt+nBordJr+nBordCm) > 0 .AND.;
                        !(cProxBor == cNumBor) .AND.;
					    (MV_PAR12 == MVP12DOCUMENTO .OR. MV_PAR13 == MVP13BORBOR .OR. (cPadrao == '532' .AND. (cAliasSE5)->E5_RECPAG == "R"))

						If !lCabecalho
							a370Cabecalho(@nHdlPrv,@cArquivo)
						EndIf

						// Quebra por Documento
						nValorTotal := If(MV_PAR12 == MVP12DOCUMENTO .OR. MV_PAR13 == MVP13BORBOR,0,nValorTotal)
						// Quebra por processo
						nValorTotal := If((cPadrao == '532' .AND. (cAliasSE5)->E5_RECPAG == "R"),0,nValorTotal)
						VALOR 		:= nBordero
						VALOR2		:= nBordDc
						VALOR3		:= nBordJr
						VALOR4		:= nBordMt
						VALOR5		:= nBordCm
						STRLCTPAD	:= cLstBor
						nBordero 	:= 0.00
						nBordDc		:= 0
						nBordJr		:= 0
						nBordMt		:= 0
						nBordCm		:= 0
						cLstBor		:= ''

						// Reposicionamento de tabelas
						If mv_par06 == 1 .OR. mv_par06 == 2 .OR. mv_par06 == 4	// Carteiras: Receber, Pagar ou Todas
							SE1->(dbGoTo(0))
							SE2->(dbGoTo(0))
							SE5->(dbGoTo(0))
							FK1->(dbGoTo(0))
							FK2->(dbGoTo(0))
							FK5->(dbGoTo(0))
						Endif

						nTotDoc := DetProva(nHdlPrv,cPadrao,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB)
						nTotProc += nTotDoc
						nTotal += nTotDoc

						VALOR := 0
						VALOR2 := 0
						VALOR3 := 0
						VALOR4 := 0
						VALOR5 := 0

						If lSeqCorr
							aDiario := {{"SE5",SE5->(recno()),SE5->E5_DIACTB,"E5_NODIA","E5_DIACTB"}}
						EndIf

						If MV_PAR12 == MVP12DOCUMENTO
							Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,@aDiario,dDataCtb)
							LimpaArray(aFlagCTB)
						EndIf

					Endif
					
					dbSelectArea(cAliasSE5)
					If lAvancaReg
						(cAliasSE5)->(dbSkip())
					else
						lAvancaReg := .T.
					EndIf

					If (cAliasSE5)->(EOF()) .AND. MV_PAR12 == MVP12PROCESSO .AND. cTipoMov == "DIRETO"
						(cAliasSE5)->(dbGOTOP())
						cTipoMov := "TITULOS"
					EndIf
				Enddo

				//Contabiliza movimentos bancários por processo
				If EMPTY(nValorTotal) .and. !EMPTY(nTotProc) .and. MV_PAR12 == MVP12PROCESSO
					Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataCtb)
					LimpaArray(aFlagCTB)
					nTotProc := 0
				EndIf

				//Contabilização de baixas de títulos por borderô de pagamento
				If ((nValorTotal > 0) .OR. !EMPTY(aLoteCNAB)) .AND. MV_PAR13 == MVP13TOTBOR .AND. cPadrao $ "521;532"
					If !lCabecalho
						a370Cabecalho(@nHdlPrv,@cArquivo)
					EndIf
					
					VALOR       := nValorTotal

					STRLCTPAD   := cLstBor
					
					nValorTotal := 0.00
					nBordero    := 0.00
					nBordDc     := 0.00
					nBordJr     := 0.00
					nBordMt     := 0.00
					nBordCm     := 0.00
					cLstBor     := ''
					
					VALOR2      := 0.00
					VALOR3      := 0.00
					VALOR4      := 0.00
					VALOR5      := 0.00

					// Se estiver contabilizando carteira a Pagar apenas,
					// desposiciona E1 tambem, pois no LP podera conter
					// E1_VALLIQ e este campo retornara um valor, duplicando
					// o LP 527. Ex. Criar um LP 527 contabilizando pelo E1_VALLIQ
					// Fazer uma Baixa e um cancelamento, contabilizar off-line
					// escolhendo apenas a carteira a Pagar
					If mv_par06 == 1 .or. mv_par06 == 2 .Or. mv_par06 == 4
						SE2->(dbGoTo(0))
						SE1->(DbGoTo(0))
						SE5->(DbGoTo(0))
						FK1->(DbGoTo(0))
						FK2->(DbGoTo(0))
						FK5->(DbGoTo(0))
					Endif

					IF !EMPTY(VALOR)
						nTotDoc := DetProva(nHdlPrv,cPadrao,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB)
						nTotProc += nTotDoc
						nTotal += nTotDoc
					ENDIF

					IF !EMPTY(aLoteCNAB)
						VALOR     := 0
						VALORLOTE := 0
						STRLCTPAD := ""

						FOR nI := 1 TO LEN(aLoteCNAB)
							VALORLOTE += aLoteCNAB[nI][3]

							// A variável STRLCTPAD oferece informações do LOTE e borderos associados ao mesmo:
							// Lt:[00000001]:Bd[111218:111219:..:Bdn]
							IF EMPTY(STRLCTPAD)
								STRLCTPAD += 'Lt:' + aLoteCNAB[nI][1] + ':Bd[' + aLoteCNAB[nI][2] + ']'
							ELSE
								STRLCTPAD := STUFF(STRLCTPAD, AT(']',STRLCTPAD), 0, ':' + aLoteCNAB[nI][2])
							ENDIF

							IF nI == LEN(aLoteCNAB) .OR. !(aLoteCNAB[nI][1] == aLoteCNAB[nI+1][1])
								nTotDoc := DetProva(nHdlPrv,cPadrao,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB)
								
								// Encerra o laço sobre aLoteCNAB caso o primeiro retorno seja nulo.
								IF EMPTY(nTotDoc)
									VALORLOTE := 0
									STRLCTPAD := ""
									EXIT
								ENDIF

								// Adiciona os acumuladores
								nTotProc += nTotDoc
								nTotal += nTotDoc

								// Reinicia Variáveis
								VALORLOTE := 0
								STRLCTPAD := ""
							ENDIF
						NEXT nI

						LimpaArray(aLoteCNAB)
					ENDIF

					IF !EMPTY(nTotal)
						If lSeqCorr
							aDiario := {{"SE5",SE5->(recno()),SE5->E5_DIACTB,"E5_NODIA","E5_DIACTB"}}
						EndIf
						Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,@aDiario,dDataCtb)
						LimpaArray(aFlagCTB)
					ENDIF
				EndIF

				
				//Contabilizacao das transferencias
				dbSelectArea("SE5") 
				SE5->(dbSetOrder(1))    // E5_FILIAL, E5_DATA, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NUMCHEQ
				SA6->(dbSetOrder(1))	// A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON
				// Ordenação Documento/LP
				aSort(aRecsTRF,,,{|x,y| x[3]+x[2] > y[3]+y[2]})
				// Soma dos valores contabilizados num mesmo documento (E5_NUMCHEQ / E5_DOCUMEN)
				bSumTRF := {|| nSum := 0, AEVAL(aRecsTRF,{|E| nSum += IF(TRIM(E[3])==TRIM(aRecsTRF[nX,3]),E[5],0)}),nSum}
				// Processa contabilização
				For nX := 1 to Len(aRecsTRF)
					SE5->(dbGoto(aRecsTRF[nX,1]))
					SA6->(MsSeek(xFilial("SA6") + SE5->(E5_BANCO + E5_AGENCIA + E5_CONTA)))
					
					If (lPadrao := VerPadrao(aRecsTRF[nX,2]))
						If !lCabecalho
							a370Cabecalho(@nHdlPrv,@cArquivo)
						EndIf

						IF lUsaFlag
							CTBAddFlag(aFlagCTB,aRecsTRF[nX,4])
						ELSE
							AADD(aRecsSE5, {SE5->(RECNO()), 'FINM030', 'FK5',IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,'')} ) // Movimentação bancaria.
						ENDIF

						nTotDoc	:= DetProva(nHdlPrv,aRecsTRF[nX,2],"FINA370",cLote,,,,,,aCT5,,@aFlagCTB)
						aRecsTRF[nX,5] := nTotDoc   // Guarda o Valor Contabilizado para o controle de quebras
						nTotal		+=	nTotDoc
						nTotProc	+= nTotDoc

						If SE5->E5_TIPODOC $ 'TR#TE'
							dDataCtb := SE5->E5_DATA
						EndIf				
						
						If MV_PAR12 == MVP12DOCUMENTO 
							If (nTotDoc > 0) .Or. (lGroupDoc .AND. !EMPTY(EVAL(bSumTRF)))    // Por documento 
								If lSeqCorr
									aDiario := {{"SE5",SE5->(recno()),SE5->E5_DIACTB,"E5_NODIA","E5_DIACTB"}}
								EndIf

								IF lGroupDoc
									// Movimentação Bancária - Controle por documento 
									IF LEN(aRecsTRF) == nX
										lQuebraDoc := .T.
									ELSE
										lQuebraDoc := !(ALLTRIM(aRecsTRF[nX,3]) == ALLTRIM(aRecsTRF[nX+1,3]))
									ENDIF
								ENDIF
								
								IF lQuebraDoc
									Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,@aDiario,dDataCtb)
									LimpaArray(aFlagCTB)
								Endif

							Endif
						Endif
					Endif
				Next
				LimpaArray(aRecsTRF)
			Endif

			If Len(aRecsSE5) > 0
				dbSelectArea("SE5")
				For nX := 1 to Len(aRecsSE5)
					SE5->(dbGoto(aRecsSE5[nX][NRECNO]))
					CTBGrvFlag(aRecsSE5[nX])
				Next
				LimpaArray(aRecsSE5) //Limpa variavel.
			Endif
			
			If MV_PAR12 == MVP12PROCESSO
				IF nTotProc > 0 // Por processo
					Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataCtb)
					nTotProc := 0
				Endif
				LimpaArray(aFlagCTB)
			Endif
			//Fim da contabilização do SE5				

			// Contabilização de Cheques
			If (mv_par06 = 3  .Or. mv_par06 = 4) .and. lLerSEF
			
				While (cAliasSEF)->(!EOF() .AND. FWXFILIAL("SEF") == EF_FILIAL .AND. DTLIB < dIniProc)
					(cAliasSEF)->(dbSkip())
				EndDo

				While (cAliasSEF)->(!EOF() .AND. FWXFILIAL("SEF") == (cAliasSEF)->EF_FILIAL .AND. (cAliasSEF)->DTLIB >= dIniProc .AND. (cAliasSEF)->DTLIB <= dFinProc)
					PulseLife() //- Pulso de vida da conexão
					// Guarda posição para contabilizar e Posiciona tabela principal - SEF
					nRecProccess := (cAliasSEF)->SEFRECNO
					SEF->(dbGoTo(nRecProccess))
					cChequeAtual := SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM)

					// Guarda posição da SE5 para a contabilizacao pela data de liberação e posteriormente posicionar na SE5
					nRecSE5Ch := (cAliasSEF)->SE5RECNO
					
					// Guarda Data Liberação e Avança para o próximo na tabela temporária - Principal já posicionada
					dDTLIB := (cAliasSEF)->DTLIB
					dDataCTB := (cAliasSEF)->DTLIB
					
					(cAliasSEF)->(DBSKIP())
					cProxChq := (cAliasSEF)->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM)  //Utilizado para quebra por documento

					WHILE SEF->(!EOF() .AND. FWXFILIAL("SEF")+cChequeAtual == EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM) .AND. SEF->EF_LA <> 'S'
						If 	!Empty(SEF->EF_NUM) .AND. ;
							(Alltrim(SEF->EF_ORIGEM) $ "FINA050#FINA040#FINA080#FINA070#FINA190#FINA090#FINA091#FINA390TIT#FINA390AVU#FINA191#FINA460" .OR. ;
							Empty(SEF->EF_ORIGEM))
							
							cPadrao := "590"	// Contas a Pagar - Geracao de Cheques sobre Titulos baixados
							lChqSTit := .F.
							IF SEF->EF_ORIGEM == "FINA390TIT"
								cPadrao := "566"	// Contas a Pagar - Geracao de Cheques sobre Titulos em aberto
							Endif
							IF SEF->EF_ORIGEM == "FINA390AVU"
								cPadrao := "567"	// 	Contas a Pagar - Geracao de Cheques Avulsos
							Endif
							If Alltrim(SEF->EF_ORIGEM) == "FINA191" .OR. Alltrim(SEF->EF_ORIGEM) == "FINA070" .Or. Alltrim(SEF->EF_ORIGEM) == "FINA460"
								cPadrao := "559"	// Compensação de Cheques Recebidos
							EndIf
							If Alltrim(SEF->EF_ORIGEM) == "FINA040" //Cheque gerados pelo SIGALOJA ou gerados na inclusão de títulos da carteira CR.
								If cMVSLDBXCR == "C"	.and. !Empty(SEF->EF_DTCOMP)					
									cPadrao := "559"  // Compensação de Cheques Recebidos
								Elseif SE1->E1_STATUS == "B" 
									cPadrao := "559"  // Compensação de Cheques Recebidos
								Else
									Exit
								Endif	
							Endif		
							If !cCtBaixa $ "AC" .and. Alltrim(SEF->EF_ORIGEM) $ "FINA050#FINA080#FINA190#FINA090#FINA091#FINA390TIT"
								Exit
							Endif
							
							// Contabilizo a emissão LP567 inclusive dos cancelados que não foram excluídos
							// A contabilização do cancelamento LP568 é online
							If SEF->EF_IMPRESS == "C" .AND. SEF->EF_LA == 'S'
								Exit
							Endif
							
							// Nao contabilizo cheques de PA nao aglutinados
							// Registro totalizador n?o tˆm preenchidos os campos EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO
							If SEF->EF_IMPRESS != "A" .and. Alltrim(SEF->EF_ORIGEM) == "FINA050" .AND. !EMPTY(SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO)) 
								Exit
							Endif
							//Não contabilizo cheque recebido que nao foram compensados
							If Empty(SEF->EF_DTCOMP) .and. Alltrim(SEF->EF_ORIGEM)=="FINA191"
								Exit
							Endif
							
							If SEF->EF_IMPRESS $ "SNC "			// Cheque impresso ou não, ou Cancelado e não contabilizado na emissão
								VALOR     := SEF->EF_VALOR		// para lan‡amento padr„o
								STRLCTPAD := SEF->EF_HIST
								NUMCHEQUE := SEF->EF_NUM
								ORIGCHEQ  := ALLTRIM(SEF->EF_ORIGEM)
								cChequeAtual := SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM)
								
								// Desposiciona propositalmente o SEF para que APENAS a
								// variavel VALOR esteja com conteudo. O reposicionamen
								// to‚ feito na volta do Looping.
								If ORIGCHEQ == "FINA190" .OR.; // Junção de cheques
									(ORIGCHEQ == "FINA050" .AND. EMPTY(SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO))) // Totalizador gerado na inclus?o de PA
									cChequeAtual := SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM)
									SEF->(DBGOTO(0))
									SE1->(DBGOTO(0))
									SE2->(DBGOTO(0))
									SE5->(DBGOTO(0))
								Endif
								If Alltrim(SEF->EF_ORIGEM) == "FINA080"  // Baixas a Pagar
									// Se o cheque nao foi impresso, desposiciona as tabelas para contabilizar somente com as variaveis
									If SEF->EF_IMPRESS $ "N "
										SEF->(DBGOTO(0))
										SE1->(DBGOTO(0))
										SE2->(DBGOTO(0))
										SE5->(DBGOTO(0))
									Else	// Cheque impresso
										// Posiciona SE5 na movimentação de baixa do titulo do cheque e mantem as outras tabelas posicionadas
										SE5->(dbSetOrder(2))
										If !SE5->( MsSeek( xFilial("SE5")+"CH"+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+DTOS(dDTLIB)+EF_FORNECE+EF_LOJA+SEF->EF_SEQUENC))) .OR.;
											!SE5->( MsSeek( xFilial("SE5")+"VL"+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+DTOS(dDTLIB)+EF_FORNECE+EF_LOJA+SEF->EF_SEQUENC)))
											SE5->( MsSeek( xFilial("SE5")+"BA"+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+DTOS(dDTLIB)+EF_FORNECE+EF_LOJA+SEF->EF_SEQUENC)))
										EndIf
										SE5->(dbSetOrder(1))
										cChequeAtual := SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM)								
									EndIf
								Endif
								If Alltrim(SEF->EF_ORIGEM) == "FINA090"  // Baixa Automática de Títulos
									aAreaAux := SE5->(GetArea())
									SE5->(dbSetOrder(17))	//E5_FILIAL, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NUMCHEQ, E5_TIPODOC, E5_SEQ, R_E_C_N_O_, D_E_L_E_T_
									If SE5->(dbSeek(xFilial('SE5')+SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM+"CH")))
										CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
									EndIf
									SE5->(DBSETORDER(aAreaAux[2]))	// Restaura o índice da SE5
								EndIf
								If Alltrim(SEF->EF_ORIGEM) == "FINA390TIT"  // Chq s/ Titulo
									SE1->(DBGOTO(0))
									SE2->(DBGOTO(0))
									VALOR     := 0
									lChqStit	:= .T.
								Endif
								If Alltrim(SEF->EF_ORIGEM) == "FINA390AVU"  // Cheque Avulso
									VALOR     := 0
									STRLCTPAD := ""
									NUMCHEQUE := ""
									ORIGCHEQ  := ""
									lChqStit	:= .T.
								Endif
							Elseif SEF->EF_IMPRESS == "A"	// Cheque Aglutinado
								VALOR     := 0
								STRLCTPAD := ""
								NUMCHEQUE := ""
								ORIGCHEQ  := ""
								cChequeAtual := SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM)

								// Posiciona no SE5
								If lCtCheqLib
									SE5->(dbGoto(nRecSE5Ch))
								Else
									SE5->(dbSetOrder(2))
									If !SE5->(dbSeek(xFilial('SE5')+"CH"+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+DTOS(dDTLIB)+EF_FORNECE+EF_LOJA+EF_SEQUENC))) .OR.;
										!SE5->(dbSeek(xFilial('SE5')+"VL"+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+DTOS(dDTLIB)+EF_FORNECE+EF_LOJA+EF_SEQUENC)))
										SE5->(dbSeek(xFilial('SE5')+"BA"+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+DTOS(dDTLIB)+EF_FORNECE+EF_LOJA+EF_SEQUENC)))
									EndIf
								Endif
								If !SE5->(EOF()) .AND. lUsaFlag
									CTBAddFlag(aFlagCTB,IF(lLerSE5,(cAliasSE5)->FKA_IDPROC,''))
								EndIf
								SE5->(dbSetOrder(1))
							Endif
							
							// Posiciona Outras Tabelas (SA6;SE1;SE2;SED;SA1;SA2)
							IF cPadrao == '559'	// Compensação de Cheques Recebidos
								SearchFor('SE5',2,xFilial('SE5')+"CH"+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+DTOS(dDTLIB)+EF_CLIENTE+EF_LOJACLI))
								SearchFor('SA6',1,xFilial('SA6')+SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA))
							ELSE
								IF SEF->(EOF()) .AND. !EMPTY(cChequeAtual)
									SearchFor('SA6',1,xFilial('SA6')+cChequeAtual)
								ELSE
									SearchFor('SA6',1,xFilial('SA6')+SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA))
								ENDIF
							ENDIF

							If !lChqSTit
								If SEF->EF_TIPO $ MVRECANT + "/" + MV_CRNEG
									// Neste caso o titulo veio de um Contas a Receber (SE1)
									If SearchFor('SE1',1,xFilial("SE1")+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_FORNECE+EF_LOJA))
										SearchFor('SED',1,xFilial('SED')+SE1->E1_NATUREZ)
										SearchFor('SA1',1,xFilial("SA1")+SEF->EF_FORNECE+SEF->EF_LOJA)
									Endif
								Else
									If SearchFor('SE2',1,xFilial("SE2")+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_FORNECE+EF_LOJA))
										SearchFor('SED',1,xFilial('SED')+SE2->E2_NATUREZ)
										SearchFor('SA2',1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
									EndIf
								Endif
								If EMPTY(SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO)) .OR. Alltrim(SEF->EF_ORIGEM) == "FINA390TIT"  // Chq s/ Titulo
									SEF->(DBGOTO(0))
								Endif
							EndIf
							
							lPadrao := VerPadrao(cPadrao)
							IF lPadrao
								If !lCabecalho
									a370Cabecalho(@nHdlPrv,@cArquivo)
								EndIF       
								If lUsaFlag
									aAdd(aFlagCTB,{"EF_LA","S","SEF",nRecProccess,0,0,0})
								EndIf                                                                                   

								// Deve passar a tabela de cheques (SEF) e Recno posicionado para gravar na CTK/CV3
								// Assim, no momento da exclusao do lancto. pelo CTB, limpa o flag da SEF corretamente
								LanceiCtb := .F. // Vem do DetProva
								nTotDoc  += DetProva(nHdlPrv,cPadrao,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB,{"SEF",nRecProccess})

								nTotProc += nTotDoc
								nTotal   += nTotDoc

								// Atualiza Flag de Lan‡amento Cont bil do cheque contabilizado
								If LanceiCTB .AND. !lUsaFlag
									SEF->(DBGOTO(nRecProccess))
									Reclock("SEF")
									SEF->EF_LA := "S"
									SEF->(MsUnlock())
								EndIf
							Endif
						Endif

						SEF->(DBSKIP())	//Verifica existência do registro aglutinador
						nRecProccess := SEF->(RECNO())

						// Sendo o mesmo registro, utilizar o registro da tabela temporária.
						IF nRecProccess == (cAliasSEF)->SEFRECNO
							EXIT
						ENDIF
					ENDDO

					// Por documento
					If !EMPTY(lPadrao) .AND. MV_PAR12 == MVP12DOCUMENTO .AND. cChequeAtual != cProxChq
						If !EMPTY(nTotDoc) 
							Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataCtb)
							nTotDoc := 0							
						Endif
						LimpaArray(aFlagCTB)
					EndIf

				Enddo
				If MV_PAR12 == MVP12PROCESSO 
					If nTotProc > 0 // Por processo
						Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataCtb)
					Endif
					LimpaArray(aFlagCTB)
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caixinha   SEU990             				     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par06 != 3 .and. lLerSEU
			
				If !lMultiTHR
				
					If Select(cAliasSEU) # 0
						dbSelectArea(cAliasSEU)
						dbCloseArea()
						fErase(cAliasSEU + OrdBagExt())
						fErase(cAliasSEU + GetDbExtension())
					Endif

					//Caso Seja Dt Baixa utilizar EU_BAIXA, se nao utilizar EU_DTDIGIT  
					If mv_par07 == 1
						cQuery := "SELECT DISTINCT EU_FILIAL, EU_CAIXA, EU_BAIXA AS DATASEU, 'OUTROS' AS TIPOMOV "
					Else
						cQuery := "SELECT DISTINCT EU_FILIAL, EU_CAIXA, EU_DTDIGIT AS DATASEU, 'OUTROS' AS TIPOMOV "
					EndIf
					
					cQuery += "FROM " + RetSqlName("SEU") + " "
					
					If ((MV_PAR14 == 1) .AND. (cFilAnt >= MV_PAR15) .AND. (cFilAnt <= MV_PAR16))  					
						If lPosEuMsFil .AND. !lUsaFilOri
							cQuery += "WHERE EU_MSFIL = '" + cFilAnt + "' AND "
						Else
							cQuery += "WHERE EU_FILORI = '"  + cFilAnt + "' AND " 
						Endif				
					Else
						cQuery += "WHERE EU_FILIAL = '" + xFilial("SEU") + "' AND "
					EndIf				
					
					If mv_par07 == 1
						cQuery += "EU_BAIXA BETWEEN '" + DTOS(dIniProc) + "' AND '" + DTOS(dFinProc) + "' AND " 
					Else
						cQuery += "EU_DTDIGIT BETWEEN '" + DTOS(dIniProc) + "' AND '" + DTOS(dFinProc) + "' AND "
					EndIf
					
					If _lMvPar18 .And. mv_par18 == 1
						cQuery += "EU_TIPO NOT IN ('01','03') AND  "
					EndIf
					
					cQuery += "EU_LA <> 'S' AND D_E_L_E_T_ = ' ' "

					If _lMvPar18 .And. mv_par18 == 1
						//Se for para considerar adiantamento de caixinha em aberto e solicitar pela baixa (mv_par07 = 1),  
						//irá filtrar pela data de digitação
						cQuery += " UNION ALL "
						cQuery += "SELECT DISTINCT EU_FILIAL, EU_CAIXA, EU_DTDIGIT AS DATASEU, 'ADTO' AS TIPOMOV "
						cQuery += "FROM " + RetSqlName("SEU") + " "
						
						If ((MV_PAR14 == 1) .AND. (cFilAnt >= MV_PAR15) .AND. (cFilAnt <= MV_PAR16))  					
							If lPosEuMsFil .AND. !lUsaFilOri
								cQuery += "WHERE EU_MSFIL = '" + cFilAnt + "' AND "
							Else
								cQuery += "WHERE EU_FILORI = '"  + cFilAnt + "' AND " 
							Endif				
						Else
							cQuery += "WHERE EU_FILIAL = '" + xFilial("SEU") + "' AND "
						EndIf				
							
						cQuery += "EU_DTDIGIT BETWEEN '" + DTOS(dIniProc) + "' AND '" + DTOS(dFinProc) + "' AND "
						cQuery += "EU_TIPO IN ('01','03') AND  "
						cQuery += "EU_LA <> 'S' AND D_E_L_E_T_ = ' ' "
					EndIf
					
					cQuery += "ORDER BY " + SqlOrder("EU_FILIAL+EU_CAIXA+DTOS(DATASEU)")

					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSEU, .F., .T.)

					TCSetField(cAliasSEU,'EU_BAIXA','D',TamSX3('EU_BAIXA')[1])
					TCSetField(cAliasSEU,'EU_DTDIGIT','D',TamSX3('EU_DTDIGIT')[1])
					TCSetField(cAliasSEU,'DATASEU','D',TamSX3('EU_DTDIGIT')[1])
				EndIf
					
				(cAliasSEU)->(dbGoTop())

				dbSelectArea( "SET" )
				SET->(dbSetOrder( 1 ))	//ET_FILIAL+ET_CODIGO 
		
				While !(cAliasSEU)->(Eof()) .And. xFilial("SEU") == (cAliasSEU)->EU_FILIAL
					PulseLife() //- Pulso de vida da conexão
					// Localiza Caixinha 
					If SET->(dbSeek(xFilial("SET") + (cAliasSEU)->EU_CAIXA))

						nOrderSEU := IIf( mv_par07 == 1, 2, 4 ) // 2 - EU_FILIAL, EU_CAIXA, EU_BAIXA, EU_NUM // 4- EU_FILIAL+EU_CAIXA+DTOS(EU_DTDIGIT)+EU_NUM
						bCampo    := IIf( mv_par07 == 1, {|| SEU->EU_BAIXA }, {|| SEU->EU_DTDIGIT } )
						If ALLTRIM((cAliasSEU)->TIPOMOV) == 'ADTO'
							nOrderSEU := 4
							bCampo := {|| SEU->EU_DTDIGIT }
							bValAdt := {|| SEU->EU_TIPO $ '01;03'}
						ElseIf _lMvPar18 .and. mv_par18 == 1
							bValAdt := {|| !SEU->EU_TIPO $ '01;03'}	
						else
							bValAdt := {|| .T. }	
						EndIf
				
						dbSelectArea( "SEU" )
						SEU->(dbSetOrder( nOrderSEU ))
						SEU->(dbSeek( xFilial("SEU") + (cAliasSEU)->EU_CAIXA + DTOS((cAliasSEU)->DATASEU) , .F. ))
						
						While SEU->(!Eof()) .And. xFilial("SEU") == SEU->EU_FILIAL .And. SEU->EU_CAIXA == SET->ET_CODIGO .And. Eval(bCampo) <= dFinProc

							If !Eval(bValAdt)
								SEU->(DBSKIP())
								LOOP
							EndIf
							
							dDataCTB := Eval(bCampo)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Ponto de Entrada para filtrar registros do SEU. ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If l370EUFIL
								If !Execblock("F370EUF",.F.,.F.)
									SEU->(dbSkip())
									Loop
								EndIf
							EndIf
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica se ser  gerado Lan‡amento Cont bil			  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If SEU->EU_LA == "S"
								SEU->( dbSkip())
								Loop
							Endif
							
							// Tipo 00 sem Nro de adiantamento = Despesa (P)
							// Tipo 00 com Nro de adiantamento = Prestação de contas (R)
							// Tipo 01 - Adiantamento (P)
							// Tipo 02 - Devolucao de adiantamento (R)
							// Tipo 10 - Movimento Banco -> Caixinha  (R)
							// Tipo 11 - Movimento Caixinha -> Banco (P)
							
							lSkipLct := .F.
							
							//Receber
							//Verifico se eh Despesa. Se for, ignoro
							If mv_par06 == 1 .and. SEU->EU_TIPO $ "00" .AND. EMPTY(SEU->EU_NROADIA)
								lSkipLct := .T.
							Endif
							//Verifico se eh um Adiantamento ou Devolucao para o banco. Se for Ignoro
							If mv_par06 == 1 .and. SEU->EU_TIPO $ "01/03/11"
								lSkipLct := .T.
							Endif
							
							//Pagar
							//Verifico se eh Prestacao de contas de adiantamento para o caixinha.
							//Se for, ignoro pois eh movimento de entrada
							If mv_par06 == 2 .and. SEU->EU_TIPO $ "00" .and. !EMPTY(SEU->EU_NROADIA)
								lSkipLct := .T.
							Endif
							//Verifico se eh uma devolucao de dinheiro de adiantamento para o caixinha ou
							// se eh uma reposicao (Banco -> Caixinha).
							// Se for Ignoro pois eh movimento de entrada!!
							If mv_par06 == 2 .and. SEU->EU_TIPO $ "02/10"
								lSkipLct := .T.
							Endif
							
							If lSkipLct
								SEU->( dbSkip())
								Loop
							Endif
							
							//Reposicao = 10 - Devolucao de reposicao = 11
							If SEU->EU_TIPO $ "10/11"
								// Posiciona no banco
								SA6->(dbSetOrder(1))
								SA6->(MsSeek(xFilial("SA6")+SET->(ET_BANCO+ET_AGEBCO+ET_CTABCO)))
								cPadrao := IF(SEU->EU_TIPO == "10","573","57E")
							Else
								If SEU->EU_TIPO == '02'
									cPadrao:="579"
								Else
									cPadrao:="572"
								EndIf
							Endif
							
							dbSelectArea("SEU")
							lPadrao:=VerPadrao(cPadrao)
							IF lPadrao
								If !lCabecalho
									a370Cabecalho(@nHdlPrv,@cArquivo)
								Endif
								If lUsaFlag
									aAdd(aFlagCTB,{"EU_LA","S","SEU",SEU->(Recno()),0,0,0})
								EndIf
								nTotDoc	:=	DetProva(nHdlPrv,cPadrao,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB)
								nTotProc	+= nTotDoc
								nTotal	+=	nTotDoc
		
								If MV_PAR12 == MVP12DOCUMENTO 
									IF nTotDoc > 0 // Por documento
										If lSeqCorr
											aDiario := {{"SEU",SEU->(recno()),SEU->EU_DIACTB,"EU_NODIA","EU_DIACTB"}}
										EndIf
										Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,@aDiario,dDataCtb)
									Endif
									LimpaArray(aFlagCTB)
								Endif
								// Atualiza Flag de Lancamento Contabil
								If LanceiCtb
									If !lUsaFlag
										Reclock("SEU")
										REPLACE SEU->EU_LA With "S"
										SEU->(MsUnlock( ))
									EndIf
								ElseIf lUsaFlag
									If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == SEU->(Recno()) }))>0
										aFlagCTB := Adel(aFlagCTB,nPosReg)
										aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
									Endif
								EndIf
							Endif
							SEU->(dbSkip())
						Enddo
					EndIf
					
					(cAliasSEU)->(DbSkip())
				Enddo
				
				If MV_PAR12 == MVP12PROCESSO .and. nTotProc > 0	 // Por processo 
					Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataCtb)
					LimpaArray(aFlagCTB)
					nTotProc := 0
				Endif
				
			Endif
			
			/* contabiliza os itens de viagens - nao contabiliza se a carteira escolhida é "cheques" 
			em multi-thread a propria funcao da thread executa a fctba677 
			*/
			If !lMultiThr .And. !(MV_PAR06 == 3) 
				FCTBA677(@lCabecalho,@nHdlPrv,@cArquivo,@lUsaFlag,@aFlagCTB,@cLote,@nTotal,,,dIniProc,dFinProc)
			Endif
			
			If lExistFWI .And. !lMultiThr .And. (mv_par06 == 1 .or. mv_par06 == 4) 
				FCTBSITCOB(@nHdlPrv,@cArquivo,@aFlagCTB,@nTotal,"",.F.,dIniProc,dFinProc)
			EndIf
			
			If lCabecalho .And. nTotal > 0 .And. MV_PAR12 == MVP12PERIODO // Por periodo
				Ca370Incl(cArquivo, @nHdlPrv, cLote, @aFlagCTB, Nil, IIf(__dDataCtb == Nil, dDataCtb, __dDataCtb))
				LimpaArray(aFlagCTB)
				__dDataCtb := Nil
			Endif

			//Ponto de Entrada acionado após a contabilização da Filial
			If (__CtbFPos)
				ExecBlock("CtbFPos", .F., .F.)
			EndIf

			If Len(aRecsSE5) > 0
				For nX := 1 to Len(aRecsSE5)
					SE5->(dbGoto(aRecsSE5[nX][NRECNO]))
					If !"S" $ SE5->E5_LA
						CTBGrvFlag(aRecsSE5[nX])
					Endif
				Next
				LimpaArray(aRecsSE5)
			Endif

		Next nLaco // final do la‡o dos dias

		IF !lMultiThr
            CTBCloseArea(cAliasSE5)
            CTBCloseArea(cAliasSE2)
            CTBCloseArea(cAliasSEF)
            CTBCloseArea(cAliasSEU)
            CTBCloseArea(cAliasTroc)
		EndIf

		IF MV_PAR14 == 2	// Considera Filial Original?  1- Sim, 2 - Não
			If Empty(FWXFilial("SE1"))
				lLerSE1 := .F.
			Endif
			
			If Empty(FWXFilial("SE2"))
				lLerSE2 := .F.
			Endif
			
			If Empty(FWXFilial("SE5"))
				lLerSE5 := .F.
			Endif
			
			If Empty(FWXFilial("SEF"))
				lLerSEF := .F.
			Endif
			
			If Empty(FWXFilial("SEU"))
				lLerSEU := .F.
			Endif
		ENDIF

		If !lLerSE1 .and. !lLerSE2 .and. !lLerSE5 .and. !lLerSEF .And. !lLerSEU
			Exit
		Endif
		
	Next nContFil

	IF lMultiThr
		CTBConout('['+PROCNAME()+']:[PROCESSO ENCERRADO: '+cProcesso+']:FILIAL:['+cFilAnt+']:['+DTOS(DATE())+']:['+TIME()+']:THREAD FINISH:['+alltrim(str(ThreadID()))+']')
	ENDIF

	// Encerra tabela temporária _oCTBAFIN (FWTemporaryTable())
	CTBClean()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recupera o valor real da data base por seguranca	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dDataBase := dDataAnt

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recupera a filial original                      	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilAnt := __cFilAnt

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recupera a Integridade dos Dados									  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsUnlockAll()

	SE1->(dbSetOrder(1))
	SE1->(dbSeek(xFilial('SE1')))

	SE2->(dbSetOrder(1))
	SE2->(dbSeek(xFilial('SE2')))

	SEF->(dbSetOrder(1))
	SEF->(dbSeek(xFilial('SEF')))

	SE5->(Retindex("SE5"))
	SE5->(dbClearFilter())

	If SuperGetMV( "MV_CTBCLSC" ,.F., .F. )
		ClearCx105()
	Endif

	__oQryTroc := Nil

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Ca370Incl ³ Autor ³ Claudio D. de Souza   ³ Data ³ 12/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Envia lancamentos para contabilizade.                  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Ca370Incl													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³FINA370													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ca370Incl(cArquivo,nHdlPrv,cLote,aFlagCTB,aDiario,dDataCtb)
Local lDigita
Local lAglut

Default aDiario := {}

If nHdlPrv > 0
	lDigita := IIF(mv_par01 == 1, .T., .F.)
	lAglut  := IIF(mv_par02 == 1, .T., .F.)
	
    CTBConout('['+PROCNAME()+']:[Execução CA100INCL() - Tamanho aFlagCTB: ['+ALLTRIM(STR(LEN(aFlagCTB)))+']')
	cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut,,dDataCtb,,@aFlagCTB,,aDiario)
	lCabecalho := .F.
	nHdlPrv := 0
Endif

LimpaArray(aFlagCTB)
LimpaArray(aDiario)

Return Nil

//--------------------------------------------------------------------------
/*/{Protheus.doc} LimpaArray
Limpa a memória e inicaliza o vetor
@Param aVetor 	Vetor de dados

@author Norberto M de Melo
@since 06/07/2020
@version 01
/*/
//---------------------------------------------------------------------------
STATIC FUNCTION LimpaArray(aVetor AS ARRAY)
	FWFReeArray(aVetor)
	aVetor := {}
RETURN NIL

//--------------------------------------------------------------------------
/*/{Protheus.doc} CTBLOTECNAB
Manutenção de Lotes CNAB na variável aLoteCNAB.
Adiciona novo item no array ou incrementa valor do item existente.

@Param aLoteCNAB AS ARRAY
@Param cLote AS CHARACTER
@Param cBordero AS CHARACTER
@Param nValor AS NUMERIC

@author Norberto M de Melo
@since 10/09/2021
@version 01
/*/
//---------------------------------------------------------------------------
STATIC FUNCTION CTBLOTECNAB(aLoteCNAB AS ARRAY,cLote AS CHARACTER,cBordero AS CHARACTER,nValor AS NUMERIC)
LOCAL nPosLote AS NUMERIC
DEFAULT aLoteCNAB := {}

	IF !EMPTY(cLote) .AND. !EMPTY(cBordero) .AND. !EMPTY(nValor) 
		nPosLote := ASCAN(aLoteCNAB,{|E| E[1] == cLote .AND. E[2] == cBordero})
		
		IF EMPTY(nPosLote)
			AADD(aLoteCNAB,{cLote,cBordero,nValor})
		ELSE
			aLoteCNAB[nPosLote][3] += nValor
		ENDIF
	ENDIF

RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³F370CTBSELºAutor  ³Microsiga           º Data ³  03/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que pesquisa e contabiliza todos os registro de um  º±±
±±º          ³ recibo gerado pelo FINA087a                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA370                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F370CTBSEL( cSerie, cRecibo, nTotal, cLote, nHdlPrv, cArquivo, lUsaFlag, aFlagCTB, aCT5 )
Local lResult		:=	.T.
Local aListArea		:=	{ GetArea() } // Atencao: A primeira deve ser restaurada por ultimo. (UEPS)
Local i				:=	0
Local cKeyImp		:=	""
Local cAlias		:=	""
Local lAchou		:=	.F.
Local nLinha		:=	1 
Local aRecSEL		:= {}

DEFAULT aCT5 := {}

lResult := VerPadrao( "575" )

If lResult .and. !lCabecalho
	a370Cabecalho( @nHdlPrv, @cArquivo )
	
	If nHdlPrv <= 0
		Help( " ", 1, "A100NOPROV" )
		lResult := .F.
	EndIf
EndIf

If lResult
	GetDBArea( "SEL", @aListArea )
	SEL->( DBSetOrder( 8 ) )	// EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	SEL->( DBSeek( xFilial("SEL") + cSerie + cRecibo ) )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera Lancamento Contab. para RECIBO.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do while	!SEL->( EOF() ) .and.;
		( SEL->EL_SERIE == cSerie ) .and.;
		( SEL->EL_RECIBO == cRecibo ) .and.;
		( SEL->EL_LA <> 'S' )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda Registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD( aRecSEL, SEL->(RECNO()) )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona Banco.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GetDBArea( "SA6", @aListArea )
		SA6->( DbsetOrder( 1 ) )
		SA6->( MsSeek( xFilial("SA6") + SEL->EL_BANCO + SEL->EL_AGENCIA + SEL->EL_CONTA, .F.) )
		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se tem titulo vinculado.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GetDBArea( "SE1", @aListArea )
		SE1->( DbsetOrder( 2 ) )
		SE1->( DbSeek(	xFilial("SE1") +;
		SEL->EL_CLIORIG +;
		SEL->EL_LOJORIG +;
		SEL->EL_PREFIXO +;
		SEL->EL_NUMERO +;
		SEL->EL_PARCELA +;
		SEL->EL_TIPO, .F.) )
		
		If !SE1->( EOF() )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona na Natureza do Titulo .³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			GetDBArea( "SED", @aListArea )
			SED->( DbsetOrder( 1 ) )
			SED->( DbSeek(	xFilial("SED") +;
			SE1->E1_NATUREZ, .F.) )
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona Cliente.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GetDBArea( "SA1", @aListArea )
		SA1->( DbsetOrder( 1 ) )
		SA1->( DbSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA, .F.) )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona no cabecalho da NF vinculada.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
			Case ( Alltrim( SEL->EL_TIPO ) == Alltrim( GetSESnew("NCC") ) )
				cAlias := "SF1"
			Case ( Alltrim( SEL->EL_TIPO ) == Alltrim( GetSESnew("NDE") ) )
				cAlias := "SF1"
			Otherwise
				cAlias := "SF2"
		EndCase
		cKeyImp := 	xFilial(cAlias)	+;
		SE1->E1_NUM		+;
		SE1->E1_PREFIXO	+;
		SE1->E1_CLIENTE	+;
		SE1->E1_LOJA
		
		If ( cAlias == "SF1" )
			cKeyImp += SE1->E1_TIPO
		Endif
		
		Posicione( cAlias, 1, cKeyImp, "F" + SubStr( cAlias, 3, 1 ) + "_VALIMP1" )
		lAchou := .F.
		
		GetDBArea( "SEL", @aListArea )
		If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
			aAdd( aFlagCTB, {"EL_LA", "S", "SEL", SEL->( Recno() ), 0, 0, 0} )
		Endif
		
		nTotal += DetProva( nHdlPrv,;
		"575" /*cPadrao*/,;
		"FINA087a" /*cPrograma*/,;
		cLote,;
		nLinha,;
		/*lExecuta*/,;
		/*cCriterio*/,;
		/*lRateio*/,;
		/*cChaveBusca*/,;
		aCT5,;
		/*lPosiciona*/,;
		@aFlagCTB,;
		/*aTabRecOri*/,;
		/*aDadosProva*/ )
		
		SEL->( DbSkip() )
	EndDo
	
	If !lUsaFlag .and. ( Len( aRecSEL ) > 0 )
		For i := 1 To Len( aRecSEL )
			SEL->( DBGoTo( aRecSEL[ i ] ) )
			RecLock( "SEL", .F. )
			Replace EL_LA With "S"
			MsUnLock()
		Next i
	EndIf
	
EndIf

// Restaura todas as areas.
// A ultima area a ser restaurada sera a area ativa no momento da chamada a esta funcao.
for i := Len( aListArea	 ) to 1 Step -1 // UEPS
	RestArea( aListArea[ i ] )
Next i
aSize(aListArea,0)
aListArea := nil 

Return lResult

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetDBArea ºAutor  ³Microsiga           º Data ³  03/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Seleciona uma area de dados, armazena a area numa lista    º±±
±±º          ³ para permitir a restauracao porterior.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA370                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GetDBArea( cAlias, aListGetArea )
Default cAlias			:= Alias()
Default aListGetArea	:= {}

DBSelectArea( cAlias )
// Pesquisa para evitar duplicidade.
If ASCAN( aListGetArea, { | aVal | aVal[ 1 ] == cAlias } ) == 0
	AADD( aListGetArea, (cAlias)->( GetArea() ) )
Endif

Return NIL /*Function GetDBArea*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PROCESSAMENTO MULTITHREAD³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBMTFIN  ºAutor  ³Marcos Justo        º Data ³  12/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Contabilização do Financeiro - Multi Thread                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBMTFIN(nCarteira,nNumProc)
Local aArea 	  := GetArea()
Local aSM0 		  := AdmAbreSM0()
Local nContFil	  := 0
Local cFilIni	  := cFilAnt
Local lRet		  := .T.
Local cFilDe	  := cFilAnt
Local cFilAte	  := cFilAnt
Local nX		  := 0
Local aSitPad     := {}
Local nTotSM0     := Len(aSM0)

If mv_par08 == 1	//Considera filiais abaixo? 1- Sim / 2 - Nao 
	cFilDe := mv_par09
	cFilAte:= mv_par10
Endif

If mv_par14 == 1	// Considera Filial Original?  1- Sim, 2 - Não
	cFilDe := MV_PAR15
	cFilAte:= MV_PAR16
Endif

For nContFil := 1 to nTotSM0
	If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt
		Loop
	EndIf
	cFilAnt := aSM0[nContFil][SM0_CODFIL]
	
	If lRet .And. ( nCarteira == 1 .Or.  nCarteira == 4)
		// Verifica se vai usar filial origem e valida se cFilAnt est  dentro das op‡?es informadas.
		IF (MV_PAR14 == 2) .OR.;
			((MV_PAR14 == 1) .AND. (cFilAnt >= MV_PAR15) .AND. (cFilAnt <= MV_PAR16)) 
			PulseLife() //- Pulso de vida da conexão
			lRet := CtbMRec(nNumProc)
		EndIf
	EndIf
	
	If lRet .And. ( nCarteira == 2 .Or.  nCarteira == 4)
		// Verifica se vai usar filial origem e valida se cFilAnt est  dentro das op‡?es informadas.
		IF (MV_PAR14 == 2) .OR.;
			((MV_PAR14 == 1) .AND. (cFilAnt >= MV_PAR15) .AND. (cFilAnt <= MV_PAR16))
			PulseLife() //- Pulso de vida da conexão
			lRet := CtbMPag(nNumProc)
		EndIf
	EndIf
	
	If lRet .And. ( nCarteira == 3 .Or.  nCarteira == 4)
		// Processa SEF se existir ao menos um LP configurado.
		If VldVerPad({'559','566','567','590'})
			// Verifica se vai usar filial origem e valida se cFilAnt est  dentro das op‡?es informadas.
			IF (MV_PAR14 == 2) .OR.;
				((MV_PAR14 == 1) .AND. lPosEfMsFil .AND. (cFilAnt >= MV_PAR15) .AND. (cFilAnt <= MV_PAR16)) .OR.;
				((MV_PAR14 == 1) .AND. !lPosEfMsFil)
				PulseLife() //- Pulso de vida da conexão
				lRet := CtbMCheq(nNumProc)
			EndIf
		EndIf
	EndIf
	
	If lRet
		For nX := 1 to 2
			// Verifica se vai usar filial origem e valida se cFilAnt est  dentro das op‡?es informadas.
			IF (MV_PAR14 == 2) .OR.;
				((MV_PAR14 == 1) .AND. (cFilAnt >= MV_PAR15) .AND. (cFilAnt <= MV_PAR16))
				PulseLife() //- Pulso de vida da conexão
				lRet := lRet .And. CtbMMov(nNumProc, nX == 1,FINNextAlias())
			ENDIF
		Next
	EndIf
	
	If lRet
		// Verifica se vai usar filial origem e valida se cFilAnt est  dentro das op‡?es informadas.
		IF (MV_PAR14 == 2) .OR.;
			((MV_PAR14 == 1) .AND. (cFilAnt >= MV_PAR15) .AND. (cFilAnt <= MV_PAR16))
			PulseLife() //- Pulso de vida da conexão
			lRet := CtbMCaix(nNumProc)	// Caixinha: SET/SEU
		EndIf
	EndIf
	
	If lRet .And. !(nCarteira == 3)
		PulseLife() //- Pulso de vida da conexão
		lRet := CtbMViag(nNumProc)
	Endif
	
    If lRet .And. ( nCarteira == 1 .Or.  nCarteira == 4)
        // Lps para transferencia de carteira - Receber 
        aSitPad := {'540','541','542','543','544','545','546','547','548','549','54G','54H','550','551','552','553','554','555','556'}
        If FwAliasInDic("FWI", .F.) .And. VldVerPad(aSitPad)
            // Verifica se vai usar filial origem e valida se cFilAnt est  dentro das op‡?es informadas.
            IF (MV_PAR14 == 2) .OR.;
                ((MV_PAR14 == 1) .AND. (cFilAnt >= MV_PAR15) .AND. (cFilAnt <= MV_PAR16)) 
				PulseLife() //- Pulso de vida da conexão
                lRet := CtbMSitCob(nNumProc)
            EndIf
        EndIf
    EndIf

	If !lRet
		EXIT
	EndIf
	
	PulseLife() //- Pulso de vida da conexão
Next nContFil

cFilAnt := cFilIni
CTBClean()
RestArea(aArea)
aSize(aArea,0)
Return lRet

/*/{Protheus.doc} CtbMTProc()
//Chama função de contabilização offline 
@author norbertom
@since 10/02/2019
@version undefined
@param cAlias,cTabCtb
@param cIdThread, char, Número da thread
@return return, return_description
CtbMTProc(cAlias,cTabCtb)
(examples)
@see (links_or_references)
/*/
Static Function CtbMTProc(cAlias,cTabCtb,cIdThread)
	Local aArea		:= GetArea()
	Local lRet		:= .T.

	Local lBat		:= .T.
	Local lMultiThr	:= .T.

	Local cAliasSE1	:= NIL
	Local cAliasSE2	:= NIL
	Local cAliasSE5	:= NIL
	Local cAliasSEF	:= NIL
	Local cAliasSEU	:= NIL

	Local lLerSE1	:= .F. 
	Local lLerSE2	:= .F.
	Local lLerSE5	:= .F.
	Local lLerSEF	:= .F.
	Local lLerSEU	:= .F.
	Local lTrocoMT  := .F.

	DEFAULT cAlias := ''
	DEFAULT cTabCTB := ''
	DEFAULT cIdThread := ""

	If		lLerSE1 := cAlias == 'SE1'
		cAliasSE1 := cTabCTB
	ElseIf	lLerSE2 := cAlias == 'SE2'
		cAliasSE2 := cTabCTB
	ElseIf	lLerSE5 := cAlias == 'SE5'
		cAliasSE5 := cTabCTB
		lTrocoMT := (!EMPTY(__lHasLoja) .AND. (cIdThread == "1"))
	ElseIf	lLerSEF := cAlias == 'SEF'
		cAliasSEF := cTabCTB
	ElseIf	lLerSEU := cAlias == 'SEU'
		cAliasSEU := cTabCTB
	EndIf

	If !EMPTY(cAlias) .AND. !EMPTY(cTabCTB)
		(cTabCtb)->(dbGoTop())
		CTBFINProc(lBat,lLerSE1,cAliasSE1,lLerSE2,cAliasSE2,lLerSEF,cAliasSEF,lLerSE5,cAliasSE5,lMultiThr,lLerSEU,cAliasSEU,lTrocoMT)
	EndIf

	RestArea(aArea)
	aSize(aArea,0)
	aArea := nil 
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CtbMViag()
Divide os registros selecionados de prestação de contas de viagens para
multi-processamento (multi-threads).

@author Marcello Gabriel
@since 18/08/2016
@version 12.1.7

@param nNumProc, número de processos
/*/
Static Function CtbMViag(nNumProc)
Local aArea 		:= GetArea()
Local lRet			:= .T.
Local nX			:= 0
Local aProcs 		:= {}
Local cTabMult		:= ""// Tabela fisica para o processamento multi thread
Local cPadraoItem	:= "8B3"
Local cPadraoCabec	:= "8B5"
Local nTotalReg		:= 0
Local cRaizNome		:= 'CTBFINPROC'
Local aStruSQL		:= {}
Local cTabJob		:= "TRBFLF"
Local cChave		:= ''

If VerPadrao(cPadraoItem) .Or. VerPadrao(cPadraoCabec)
	
	LoadPergunte()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o arquivo de trabalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTabMult := CtbGrvViag(.T.,,@nTotalReg)
	
	If !Empty(cTabMult) .And. (cTabMult)->(!EOF())
		
		aStruSQL := (cTabMult)->( DbStruct() )
		aProcs := CTBPrepFIN(@nNumProc,cTabMult,nTotalReg,"CTBFLAG",cRaizNome,"")
		
		CTBConout('['+PROCNAME()+']:['+cFilAnt+']:['+DTOS(DATE())+']:['+TIME()+']-QTDE:['+ALLTRIM(STR(nTotalReg))+']')
		If  nTotalReg >= nNumProc .And. ((nNumProc > 1) .OR. __lAutoMThrd) // MultiThread
			
			//Inicializa as Threads Transação controlada nas Threads
			For nX := 1 to Len(aProcs)
				StartJob("JOBCTBVIAG", GetEnvServer(), .F., cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],"CTBFLAG",cTabMult,aStruSQL,cTabJob,cValToChar(nX),aProcs[nX][VAR_STATUS],"",__cUserId,cUserName,cAcesso,cUsuario,_oCTBAFIN:GETREALNAME())
				CTBSleep(1500)
			Next nX
			
			//NAO RETIRAR A INSTRUCAO DO SLEEP
			//Esperar 05 segundos antes de monitorar para dar tempo das threads criar arquivo de semaforo
			CTBSleep(5000)
			//Realiza o controle das Threads
			lRet := FINMonitor(aProcs,4)
		ElseIf nNumProc == 1
			cTabJob	 := SelFINJob(NIL,cTabMult,aStruSQL,"CTBFLAG",aProcs[nNumProc][MARCA],cTabJob,cChave,_oCTBAFIN:GETREALNAME())
			lRet := FCTBA677(,,,,,,,cTabJob,.T.)
			If Select(cTabJob) > 0
				(cTabJob)->(dbCloseArea())
			EndIf
		EndIf
	EndIf
	
	If Select(cTabMult) > 0
		(cTabMult)->( dbCloseArea() )
	Endif

	RestArea(aArea)
	aSize(aArea,0)
	aArea := nil 

Endif
Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} CtbGrvViag()
Seleciona os registros de prestação de contas de viagens e os divide
para multi-processamento (multi-threads).

@author Marcello Gabriel
@since 18/08/2016
@version 12.1.7

@param lTabTemp, indica a geração da tabela temporária 
@param cQuery, passado por referência, receberá o texto da consulta 
@param nTotalReg, passado por referência, receberá a quantidade de registros encotnrados na query
/*/
Static Function CtbGrvViag(lTabTemp,cQuery,nTotalReg,dIniProc,dFinProc)
	Local aStruSQL		:= {}
	Local lMsFil		:= .F.
	Local lFlfLA		:= .F.
	Local cQuery2		:= ""
	Local cQuery3       := ""
	Local cAliasCNT 	:= ""
	Local cChave 		:= "REGFLF"
	Local cTabTemp		:= ""
	Local cCamposSel    := ""
	Local cCamposIns    := ""
	Local cNulo         := "NVL"

	Default lTabTemp	:= .F.
	Default cQuery		:= ""
	Default nTotalReg   := 0
	Default dIniProc	:= MV_PAR04
	Default dFinProc	:= MV_PAR05

	If (_MSSQL7 .Or. (_cSGBD $ "POSTGRES|MYSQL"))
		cNulo := Iif(_MSSQL7, "ISNULL", "COALESCE")
	EndIf

	lMsFil     := (FLF->(ColumnPos("FLF_MSFIL")) > 0)
	lFlfLA	   := (FLF->(ColumnPos('FLF_LA')) > 0 )
	cCamposSel := "FLF.R_E_C_N_O_ REGFLF," + _cSpaceMark + " CTBFLAG, FLF.R_E_C_N_O_, " + cNulo + "(FO7.R_E_C_N_O_, 0) REGFO7 "

	If _MSSQL7
		cCamposSel := "FLF.R_E_C_N_O_ REGFLF," + _cSpaceMark + " CTBFLAG, " + cNulo + "(FO7.R_E_C_N_O_, 0) REGFO7 "
	EndIf 

	cQuery := "SELECT " + cCamposSel + " FROM " + RetSqlName("FLF") + " FLF "
	cQuery += "LEFT JOIN " + RetSqlName("FO7") + " FO7 "
	cQuery += "ON (FLF.FLF_FILIAL = FO7.FO7_FILIAL AND FLF.FLF_TIPO = FO7.FO7_TPVIAG "
	cQuery += "AND FLF.FLF_PRESTA = FO7.FO7_PRESTA AND FLF.FLF_PARTIC = FO7.FO7_PARTIC "
	cQuery += "AND FLF.D_E_L_E_T_ = FO7.D_E_L_E_T_ ) WHERE "

	If MV_PAR14 == 1 .And. lMsFil
		cQuery += "FLF.FLF_MSFIL BETWEEN '" + mv_par15 + "' AND '" + mv_par16 + "' "
	Else
		cQuery += "FLF.FLF_FILIAL = '" + xFilial("FLF") + "' "
	Endif

	cQuery += "AND FLF.FLF_STATUS IN ('7','8') "

	If lFlfLa
		cQuery += "AND FLF.FLF_LA = ' ' "
	Endif

	cQuery += "AND FLF.FLF_EMISSA BETWEEN '" + DTOS(dIniProc) + "' AND '" + DTOS(dFinProc) + "' "
	cQuery += "AND FLF.D_E_L_E_T_ = ' ' "

	If lTabTemp
		aStruSQL := {}
		AADD(aStruSQL, {"REGFLF",  "N", 10, 00})
		AADD(aStruSQL, {"CTBFLAG", "C", LEN(&_cSpaceMark), 00})
		AADD(aStruSQL, {"REGFO7",  "N", 10, 00})

		//Inicio do bloco que substitui SqlToTrb
		If FinZap_Tmp(__oTabFLF)
			__oTabFLF := FINNEWTBL('FLF',aStruSQL,cChave) 
		EndIF 
		_oCTBAFIN:= __oTabFLF
		cTabTemp := __oTabFLF:cAlias

		cQuery2 := " INSERT "
		If _cSGBD == "ORACLE"
			cQuery2 += " /*+ APPEND */ "
		Endif
		
		cCamposIns := "REGFLF, CTBFLAG, R_E_C_N_O_, REGFO7 "
		
		If _MSSQL7
			cCamposIns := "REGFLF, CTBFLAG, REGFO7 "	
		EndIf 

		cQuery2 += " INTO " + __oTabFLF:GETREALNAME() + " ("+cCamposIns+") " + cQuery

		CTBConout('['+PROCNAME()+']:[Criação de tabela temporária: ['+cQuery2+']')

		If TcSqlExec(cQuery2) <> 0
			CTBConout( PROCNAME()+"[ERRO INSERT]:[" + TcSQLError() + ']' )		
		EndIf

		cQuery3 := "SELECT COUNT(1) QUANT "
		cQuery3 += "  FROM " + __oTabFLF:GETREALNAME() + " TAB "

		cAliasCNT := FINNextAlias()
		dbUseArea( .T. , "TOPCONN" , TCGenQry(,,cQuery3) , cAliasCNT )
		(cAliasCNT)->(DbGoTop())
		nTotalReg := (cAliasCNT)->QUANT
		(cAliasCNT)->(dbCloseArea())

		//tiro o arquivo de eof
		DbSelectArea(cTabTemp)
		(cTabTemp)->(dbGoTop())
		//Fim do bloco que substitui SqlToTrb
	Endif

Return cTabTemp

//-------------------------------------------------------------------
/*/{Protheus.doc} JobCtbViag()
Executa o job para os registros de prestação de contas de viagens.

@author Marcello Gabriel
@since 18/08/2016
@version 12.1.7
/*/
Function JOBCTBViag(cEmpX,cFilX,cMarca,cFileLck,cCpoFlag,cTabMaster,aStructTab,cTabJob,cId,cVarStatus,cChave,cXUserId,cXUserName,cXAcesso,cXUsuario,cFWTMP)
Local nHandle	 := 0
Local lRet		 := .T.

Private lMsErroAuto 
Private lMsHelpAuto 
Private lAutoErrNoFile 

Default cFWTMP := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre o arquivo de Lock parao controle externo das threads³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHandle := FINLock(cFileLck)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue(cVarStatus,stThrStart)

//Seta job para nao consumir licensas
RpcSetType(3)
RpcClearEnv()
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX,cFilX,,,,,)

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue(cVarStatus,stThrConnect)

//Set o usuário para buscar as perguntas do profile
lMsErroAuto := .F.
lMsHelpAuto := .T. 
lAutoErrNoFile := .T.

__cUserId := cXUserId 
cUserName := cXUserName
cAcesso   := cXAcesso
cUsuario  := cXUsuario

DEFAULT _cSGBD		:= Alltrim(Upper(TCGetDB()))
DEFAULT _MSSQL7		:= _cSGBD $ "MSSQL7"
DEFAULT _cOperador	:= If(_MSSQL7,"+","||")

cTabJob	 := SelFINJob(cVarStatus,cTabMaster,aStructTab,cCpoFlag,cMarca,cTabJob,cChave,cFWTMP)

Pergunte("FIN370",.F.)

// Realiza o processamento
lRet := FCTBA677(,,,,,,,cTabJob,.T.)

JOBFINEnd(cVarStatus,nHandle,lRet)

If Select(cTabJob) > 0
	(cTabJob)->(dbCloseArea())
EndIf

Return()


//MOVIMENTAÇÃO BANCARIA
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbMMov   ºAutor  ³Alvaro Camillo Neto º Data ³  31/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Contabilização de movimentacao bancaria                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbMMov(nNumProc,lMovNorm,cTabJOB)
	Local aArea 		:= GetArea()
	Local lRet			:= .T.
	Local nX			:= 0
	Local aProcs 		:= {}
	Local cTabMult		:= ""// Tabela fisica para o processamento multi thread
	Local cChave		:= ""
	Local nTotalReg		:= 0
	Local cRaizNome		:= 'CTBFINPROC'
	Local aStruSQL		:= {}
	Local nMaxReg		:= SuperGetMv("MV_CTBNMRB",.T.,0)	// Numero Maximo de registros a contabilizar. (Tratamento para evitar estouro na TEMPDB)
	Local nSaldoReg		:= 0

	LoadPergunte()

	If mv_par07 == 1 //DATA
		cChave := "E5_FILIAL+E5_DATA+E5_RECPAG+E5_NUMCHEQ+E5_DOCUMEN+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ"
	ElseIf mv_par07 == 2		//DATA DE DIGITACAO
		cChave := "E5_FILIAL+E5_DTDIGIT+E5_RECPAG+E5_NUMCHEQ+E5_DOCUMEN+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ"
	Else 							//DATA DE DISPONIBILIDADE
		cChave := "E5_FILIAL+E5_DTDISPO+E5_RECPAG+E5_NUMCHEQ+E5_DOCUMEN+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ"
	Endif

	If !lMovNorm
		cChave := StrTran(cChave,'E5_RECPAG+E5_NUMCHEQ+E5_DOCUMEN','E5_PROCTRA+E5_RECPAG')
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o arquivo de trabalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTabMult := CtbGrvMov(lMovNorm,cChave,@nTotalReg)
	nMaxReg := If(EMPTY(nMaxReg),nTotalReg,nMaxReg)	// Se não informado pelo parâmetro assume a quantidade total como padrão

	If !Empty(cTabMult) .And. (cTabMult)->(!EOF())
		
		While lRet .and. nTotalReg > 0

			If nTotalReg >= nMaxReg
				nSaldoReg := (nTotalReg - nMaxReg)	// Continua no Laço While
			Else
				nSaldoReg := 0
			EndIf
			
			aStruSQL := (cTabMult)->( DbStruct() )
			aProcs := CTBPrepFIN(@nNumProc,cTabMult,MIN(nMaxReg,nTotalReg),"CTBFLAG",cRaizNome, IIF(lMovNorm , "", "E5_DOCUMEN" ) )
			
			CTBConout('['+PROCNAME()+']:['+cFilAnt+']:['+DTOS(DATE())+']:['+TIME()+']-QTDE:['+ALLTRIM(STR(nTotalReg))+']')
			If  nTotalReg >= nNumProc .And. ((nNumProc > 1) .OR. __lAutoMThrd) // MultiThread
				nTotalReg := nSaldoReg

				//Inicializa as Threads Transação controlada nas Threads
				For nX := 1 to Len(aProcs)
					StartJob("JOBCTBMOV", GetEnvServer(), .F., cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],"CTBFLAG",cTabMult,aStruSQL,cTabJob,cValToChar(nX),aProcs[nX][VAR_STATUS],cChave,__cUserId,cUserName,cAcesso,cUsuario,_oCTBAFIN:GETREALNAME())
					CTBSleep(1500)
				Next nX
				
				//NAO RETIRAR A INSTRUCAO DO SLEEP
				//Esperar 05 segundos antes de monitorar para dar tempo das threads criar arquivo de semaforo
				CTBSleep(5000)
				//Realiza o controle das Threads
				lRet := FINMonitor(aProcs,4)
			ElseIf nNumProc == 1
				cTabJob	 := SelFINJob(NIL,cTabMult,aStruSQL,"CTBFLAG",aProcs[nNumProc][MARCA],cTabJob,cChave,_oCTBAFIN:GETREALNAME())
				lRet 	 := CtbMTProc('SE5',cTabJob)
				If Select(cTabJob) > 0
					(cTabJob)->(dbCloseArea())
				EndIf
					
				nTotalReg := 0	//  Deve sair do laço While
			EndIf
			
		EndDo	
	EndIf

	If Select(cTabMult) > 0
		(cTabMult)->( dbCloseArea() )
	Endif

	RestArea(aArea)
	aSize(aArea,0)
	aArea := nil 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbGrvMov  ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava arquivo temporario das movimentacoes bancarias        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbGrvMov(lMovNorm AS LOGICAL, cChave AS CHARACTER, nTotalReg AS NUMERIC) AS CHARACTER
	Local aStruSQL        AS ARRAY
	Local cTab            AS CHARACTER
	Local cQuery          AS CHARACTER
	Local cQuery2         AS CHARACTER
	Local cCamposSel      AS CHARACTER
	Local cCamposIns      AS CHARACTER
	Local aStruSE5        AS ARRAY
	Local cAliasCNT       AS CHARACTER
	Local l370E5FIL       AS LOGICAL
	LOCAL cNulo           AS CHARACTER
	LOCAL cTamREC         AS CHARACTER
	Local nE5PREFIXO      AS NUMERIC
	Local nE5NUMERO       AS NUMERIC
	Local nE5PARCELA      AS NUMERIC
	Local nE5TIPO         AS NUMERIC
	Local nE5CLIFOR       AS NUMERIC
	Local nE5LOJA         AS NUMERIC

	aStruSQL        := {}
	cTab            := ""
	cQuery          := ""
	cQuery2         := ""
	cCamposSel      := ""
	cCamposIns      := ""
	aStruSE5        := {}
	cAliasCNT       := ""
	l370E5FIL       := Existblock("F370E5F")   // Criado Ponto de Entrada
	cNulo           := ""
	cTamREC         := STRZERO(TAMSX3("E5_ORDREC")[1] + TAMSX3("E5_SERREC")[1],3)
	nE5PREFIXO      := TamSX3("E5_PREFIXO")[1]
	nE5NUMERO       := TamSx3("E5_NUMERO")[1]
	nE5PARCELA      := TamSx3("E5_PARCELA")[1]
	nE5TIPO         := TamSx3("E5_TIPO")[1]
	nE5CLIFOR       := TamSx3("E5_CLIFOR")[1]
	nE5LOJA         := TamSx3("E5_LOJA")[1]

	Do CASE
	CASE _cSGBD $ "ORACLE|INFORMIX|DB2"
		cNulo := "NVL"
	CASE _cSGBD $ "POSTGRES|MYSQL"
		cNulo := "COALESCE"
	OTHERWISE
		cNulo := "ISNULL"
	End CASE

	DEFAULT nTotalReg := 0

	LoadPergunte()

	dbSelectArea("SE5")
	SE5->(dbSetOrder(1))

	// Montagem da estrtura do arquivo
	aStruSE5  := SE5->(DbStruct())
	aStruSQL := aClone(aStruSE5)
	AADD(aStruSQL,{"FKA_IDPROC"   	,"C",TAMSX3("FKA_IDPROC")[1],TAMSX3("FKA_IDPROC")[2]})
	AADD(aStruSQL,{"SE5RECNO"   	,"N",15,00})
	AADD(aStruSQL,{"RECNOPA"   		,"N",15,00})
	AADD(aStruSQL,{"CTBFLAG" 		,"C",LEN(&_cSpaceMark),00})

	If  !__oTabSE5 == nil
		__oTabSE5:Delete()
		FreeObj(__oTabSE5)
		__oTabSE5:= nil 
	EndIf 
	// Cria tabela temporaria. 
	// Não faz limpeza com a função FinZap_Tmp para reaproveitar, pois precisa ser criada uma nova tabela com novos índices
	// com ordenação correta para função FINFLAG
	__oTabSE5 := FINNEWTBL('SE5',aStruSQL,cChave) 
	_oCTBAFIN := __oTabSE5
	cTab := __oTabSE5:cAlias

	// Montagem da Query
	cCamposSel := ''
	cCamposIns := ''
	aEval(aStruSE5,{|e,i| cCamposIns += If(i==1,'',",")+AllTrim(e[1])})
	aEval(aStruSE5,{|e,i| cCamposSel += If(i==1,'SE5.',",SE5.")+AllTrim(e[1])})

	//Para bancos diferentes de MSSQL a tabela temporaria é criada via MsCreate, entao precisamos criar a coluna R_E_C_N_O_ manualmente e alimenta-la
	If !_MSSQL7
		cCamposIns += ',FKA_IDPROC,SE5RECNO,RECNOPA,CTBFLAG,R_E_C_N_O_'
		Else
		cCamposIns += ',FKA_IDPROC,SE5RECNO,RECNOPA,CTBFLAG'
	EndIf 

	If mv_par07 == 2
		cCamposSel := STRTRAN( cCamposSel, "SE5.E5_DTDIGIT", "CASE WHEN SE5.E5_TIPODOC IN ('TR','TE') THEN SE5.E5_DATA ELSE SE5.E5_DTDIGIT END E5_DTDIGIT" )
	ElseIf mv_par07 == 3
		cCamposSel := STRTRAN( cCamposSel, "SE5.E5_DTDISPO", "CASE WHEN SE5.E5_TIPODOC IN ('TR','TE') THEN SE5.E5_DATA ELSE SE5.E5_DTDISPO END E5_DTDISPO" )
	EndIF

	cQuery := "SELECT " + cCamposSel
	cQuery += "," + cNulo + "(FKA.FKA_IDPROC,' ') FKA_IDPROC,SE5.R_E_C_N_O_ SE5RECNO," 

	//Determina se a coluna RECNOPA tera o conteudo do alias MPA (compensacoes) ou MPAES (estorno)
	cQuery += "CASE WHEN "+ cNulo + "(MPA.R_E_C_N_O_,0) > 0 THEN MPA.R_E_C_N_O_ "
	cQuery += "WHEN "+ cNulo + "(MPAES.R_E_C_N_O_,0) > 0 THEN MPAES.R_E_C_N_O_ "
	cQuery += "ELSE 0 END RECNOPA, "

	//Para bancos diferentes de MSSQL a tabela temporaria é criada via MsCreate, entao precisamos criar a coluna R_E_C_N_O_ manualmente e alimenta-la
	If _MSSQL7
		cQuery += _cSpaceMark + " CTBFLAG"
	ElseIf _cSGBD == 'ORACLE'
		cQuery += _cSpaceMark + " CTBFLAG, ROWNUM CONTADOR"
	Elseif _cSGBD == 'POSTGRES'
		cQuery += _cSpaceMark + " CTBFLAG, row_number() OVER (ORDER BY SE5.R_E_C_N_O_) CONTADOR"
	Else
		cQuery += _cSpaceMark + " CTBFLAG,SE5.R_E_C_N_O_"
	EndIf

	cQuery += " FROM " + RetSqlName("SE5") + " SE5 "

	//Amarração entre SE5 x FKA
	cQuery += " LEFT JOIN " + RetSqlName("FKA") + " FKA "
	cQuery += " ON FKA.FKA_FILIAL = SE5.E5_FILIAL AND FKA.FKA_TABORI = SE5.E5_TABORI AND FKA.FKA_IDORIG = SE5.E5_IDORIG AND FKA.D_E_L_E_T_ = ' '"

	//Amarração entre SE5 x Compensacoes pagar/receber (alias MPA)
	cQuery += " LEFT JOIN " + RetSqlName("SE5") + " MPA "
	cQuery += " ON MPA.E5_FILIAL = SE5.E5_FILIAL AND MPA.E5_DATA = SE5.E5_DATA AND "
	//Filtra E5_DOCUMEN p/ compensações a pagar (prefixo+numero+parcela+tipo+fornecedor+loja)
	cQuery += " ((MPA.E5_PREFIXO   = SUBSTR(SE5.E5_DOCUMEN,1,"+cValToChar(nE5PREFIXO)+")"
	cQuery += " AND MPA.E5_NUMERO  = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO)+","+cValToChar(nE5NUMERO)+")"
	cQuery += " AND MPA.E5_PARCELA = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO)+","+cValToChar(nE5PARCELA)+")"
	cQuery += " AND MPA.E5_TIPO    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA)+","+cValToChar(nE5TIPO)+")"
	cQuery += " AND MPA.E5_CLIFOR  = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA+nE5TIPO)+","+cValToChar(nE5CLIFOR)+")"
	cQuery += " AND MPA.E5_LOJA    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA+nE5TIPO+nE5CLIFOR)+","+cValToChar(nE5LOJA)+")"
	cQuery += " ) OR "
	//Filtra E5_DOCUMEN p/ compensações a receber (prefixo+numero+parcela+tipo+loja)
	cQuery += " (MPA.E5_PREFIXO    = SUBSTR(SE5.E5_DOCUMEN,1,"+cValToChar(nE5PREFIXO)+")"
	cQuery += " AND MPA.E5_NUMERO  = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO)+","+cValToChar(nE5NUMERO)+")"
	cQuery += " AND MPA.E5_PARCELA = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO)+","+cValToChar(nE5PARCELA)+")"
	cQuery += " AND MPA.E5_TIPO    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA)+","+cValToChar(nE5TIPO)+")"
	cQuery += " AND MPA.E5_LOJA    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA+nE5TIPO)+","+cValToChar(nE5LOJA)+"))) "
	//Filtros em comum entre compensacoes pagar/receber
	cQuery += " AND MPA.E5_SEQ = SE5.E5_SEQ AND MPA.E5_MOTBX = SE5.E5_MOTBX AND MPA.E5_MOTBX = 'CMP' "
	cQuery += " AND MPA.E5_TIPODOC  IN ('CP','BA') AND SE5.E5_TIPODOC  IN ('CP','BA') AND MPA.D_E_L_E_T_ = ' ' "

	//Amarração entre SE5 x Estorno de compensacoes pagar/receber (alias MPAES)
	cQuery += " LEFT JOIN " + RetSqlName("SE5") + " MPAES "
	cQuery += " ON MPAES.E5_FILIAL = SE5.E5_FILIAL AND MPAES.E5_DATA = SE5.E5_DATA AND "
	//Filtra E5_DOCUMEN p/ compensações a pagar (prefixo+numero+parcela+tipo+fornecedor+loja)
	cQuery += " ((MPAES.E5_PREFIXO   = SUBSTR(SE5.E5_DOCUMEN,1,"+cValToChar(nE5PREFIXO)+")"
	cQuery += " AND MPAES.E5_NUMERO  = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO)+","+cValToChar(nE5NUMERO)+")"
	cQuery += " AND MPAES.E5_PARCELA = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO)+","+cValToChar(nE5PARCELA)+")"
	cQuery += " AND MPAES.E5_TIPO    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA)+","+cValToChar(nE5TIPO)+")"
	cQuery += " AND MPAES.E5_CLIFOR  = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA+nE5TIPO)+","+cValToChar(nE5CLIFOR)+")"
	cQuery += " AND MPAES.E5_LOJA    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA+nE5TIPO+nE5CLIFOR)+","+cValToChar(nE5LOJA)+")"
	cQuery += " ) OR "
	//Filtra E5_DOCUMEN p/ compensações a receber (prefixo+numero+parcela+tipo+loja)
	cQuery += " (MPAES.E5_PREFIXO    = SUBSTR(SE5.E5_DOCUMEN,1,"+cValToChar(nE5PREFIXO)+")"
	cQuery += " AND MPAES.E5_NUMERO  = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO)+","+cValToChar(nE5NUMERO)+")"
	cQuery += " AND MPAES.E5_PARCELA = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO)+","+cValToChar(nE5PARCELA)+")"
	cQuery += " AND MPAES.E5_TIPO    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA)+","+cValToChar(nE5TIPO)+")"
	cQuery += " AND MPAES.E5_LOJA    = SUBSTR(SE5.E5_DOCUMEN,1+"+cValToChar(nE5PREFIXO+nE5NUMERO+nE5PARCELA+nE5TIPO)+","+cValToChar(nE5LOJA)+"))) "
	//Filtros em comum entre compensacoes pagar/receber
	cQuery += " AND MPAES.E5_SEQ = SE5.E5_SEQ AND MPAES.E5_MOTBX = SE5.E5_MOTBX AND MPAES.E5_MOTBX = 'CMP' "
	cQuery += " AND MPAES.E5_TIPODOC  = SE5.E5_TIPODOC AND MPAES.E5_TIPODOC = 'ES' AND MPAES.D_E_L_E_T_ = ' ' "

	If mv_par14 == 1
		If lPosE5MsFil .AND. !lUsaFilOri
			cQuery += "WHERE SE5.E5_MSFIL = '"  + cFilAnt + "' AND "
		Else
			cQuery += "WHERE SE5.E5_FILORIG = '"  + cFilAnt + "' AND "
		Endif
	Else
		cQuery += "WHERE SE5.E5_FILIAL = '" + xFilial("SE5") + "' AND "
	EndIf

	If mv_par07 == 1		//DATA
		cQuery += "SE5.E5_DATA BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "
		cQuery += "SE5.E5_TIPODOC IN ('DH','PA','RA','BA','VL','V2','AP','EP','PE','RF','IF','CP','TL','ES','TR','DB','OD','LJ','E2','TE','  ')  AND "
	ElseIf mv_par07 == 2	//DATA DE DIGITACAO
		cQuery += "((SE5.E5_DTDIGIT BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "
		cQuery += "SE5.E5_TIPODOC IN ('DH','PA','RA','BA','VL','V2','AP','EP','PE','RF','IF','CP','TL','ES','TR','DB','OD','LJ','E2','TE','  '))  OR "
		cQuery += "(SE5.E5_DATA BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "
		cQuery += "SE5.E5_TIPODOC IN ('TR','TE')))  AND "
	Else					//DATA DE DISPONIBILIDADE
		cQuery += "((SE5.E5_DTDISPO BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "
		cQuery += "SE5.E5_TIPODOC IN ('DH','PA','RA','BA','VL','V2','AP','EP','PE','RF','IF','CP','TL','ES','TR','DB','OD','LJ','E2','TE','  '))  OR "
		cQuery += "(SE5.E5_DATA BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "
		cQuery += "SE5.E5_TIPODOC IN ('TR','TE')))  AND "
	Endif

	cQuery += "SE5.E5_SITUACA <> 'C' AND "
	cQuery += "(SE5.E5_LA <> 'S ' OR (CAST(SE5.E5_ORDREC " + _cOperador + " SE5.E5_SERREC AS CHAR(" + cTamREC + ")) <> '' AND SE5.E5_RECPAG = 'R' AND SE5.E5_TIPODOC = 'BA')) AND "  // Filtra registros de Recebimentos Diversos p/Contabilizacao

	// Ponto de Entrada para filtrar E5_MOTBX.
	aMotBX := {'DSD'}
	If lF370E5MBX
		aMotBX := Execblock("F370E5MBX",.F.,.F.,aMotBX)
	EndIf
	cMotBX := FormatIn( UPPER( ALLTRIM( ArrayToStr( aMotBX ) ) ), ";" )
	cQuery += "SE5.E5_MOTBX NOT IN " + cMotBX + " AND "

	If lMovNorm
		cQuery += " (SE5.E5_DOCUMEN = ' ' AND SE5.E5_NUMCHEQ = ' ') AND "
	Else
		cQuery += " (SE5.E5_DOCUMEN <> ' ' OR SE5.E5_NUMCHEQ <> ' ') AND "
	EndIf

	cQuery += "SE5.D_E_L_E_T_ = ' ' "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para filtrar registros do SE5. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l370E5FIL
		cQuery := Execblock("F370E5F",.F.,.F.,cQuery)
	EndIf

	// seta a ordem de acordo com a opcao do usuario
	cQuery += " ORDER BY " + SqlOrder(cChave)
	If _MSSQL7
		cQuery := StrTran(cQuery,'SUBSTR(','SUBSTRING(')
	EndIf 
	cQuery := ChangeQuery( cQuery )

	//Inicio do bloco que substitui SqlToTrb
	cQuery2 := " INSERT "
	If _cSGBD == "ORACLE"
		cQuery2 += " /*+ APPEND */ "
	Endif
	cQuery2 += " INTO " + __oTabSE5:GETREALNAME() + " ("+cCamposIns+") " + cQuery

	CTBConout('['+PROCNAME()+']:[Criação de tabela temporária: ['+cQuery2+']')

	If TcSqlExec(cQuery2) <> 0
		CTBConout( PROCNAME()+"[ERRO INSERT]:[" + TcSQLError() + ']' )		
	EndIf

	cQuery := "SELECT COUNT(1) QUANT "
	cQuery += "  FROM " + __oTabSE5:GETREALNAME() + " TAB "

	cAliasCNT := FINNextAlias()
	dbUseArea( .T. , "TOPCONN" , TCGenQry(,,cQuery) , cAliasCNT )
	(cAliasCNT)->(DbGoTop())
	nTotalReg := (cAliasCNT)->QUANT
	(cAliasCNT)->(dbCloseArea())

	//tiro o arquivo de eof
	DbSelectArea(cTab)
	(cTab)->(dbGoTop())
	//Fim do bloco que substitui SqlToTrb

RETURN cTab
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JOBCTBMov ºAutor  ³Alvaro Camillo Neto º Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Job da contabilização de movimentacoes bancarias           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function JOBCTBMov(cEmpX,cFilX,cMarca,cFileLck,cCpoFlag,cTabMaster,aStructTab,cTabJob,cId,cVarStatus,cChave,cXUserId,cXUserName,cXAcesso,cXUsuario,cFWTMP)
Local nHandle	 := 0
Local lRet		 := .T.

Private lMsErroAuto 
Private lMsHelpAuto 
Private lAutoErrNoFile 

DEFAULT cFWTMP	:= ''
DEFAULT cId	 	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre o arquivo de Lock parao controle externo das threads³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHandle := FINLock(cFileLck)

If  nHandle >= 0
	PutGlbValue(cVarStatus,stThrStart)

	//Seta job para nao consumir licensas
	RpcSetType(3)
	RpcClearEnv()
	// Seta job para empresa filial desejada
	RpcSetEnv( cEmpX,cFilX,,,,,)

	PutGlbValue(cVarStatus,stThrConnect)

	//Set o usuário para buscar as perguntas do profile
	lMsErroAuto := .F.
	lMsHelpAuto := .T. 
	lAutoErrNoFile := .T.

	__cUserId := cXUserId 
	cUserName := cXUserName
	cAcesso   := cXAcesso
	cUsuario  := cXUsuario
	DEFAULT _cSGBD		:= Alltrim(Upper(TCGetDB()))
	DEFAULT _MSSQL7		:= _cSGBD $ "MSSQL7"
	DEFAULT _cOperador	:= If(_MSSQL7,"+","||")
	
	//cria temporario de contabilizacao no banco de dados e otimiza validacao do lancamento
	If _lCtbIniLan
		CtbIniLan()
	EndIf
	
	cTabJob	 := SelFINJob(cVarStatus,cTabMaster,aStructTab,cCpoFlag,cMarca,cTabJob,cChave,cFWTMP)

	// Realiza o processamento
	lRet := CtbmtProc('SE5',cTabJob,cId)

	JOBFINEnd(cVarStatus,nHandle,lRet)

	If Select(cTabJob) > 0
		(cTabJob)->(dbCloseArea())
	EndIf

	//exclui temporario de contabilizacao utilizado para otimizacao validacao do lancamento
	If FindFunction("CtbFinLan")
		//FINALIZA E APAGA ARQUIVO TMP NO BANCO
		CtbFinLan()
	EndIf
	
Else
	PutGlbValue(cVarStatus,stThrError)
EndIf

Return

// CAIXINHA

/*/{Protheus.doc} CtbMCaix
//Consulta, prepara e executa a contabilização do caixinha.
@author norbertom
@since 10/02/2019
@version P!@
@param nNumProc, numeric, description
@return return, return_description
@example
CtbMCaix(nNumProc)
@see (links_or_references)
/*/
Static Function CtbMCaix(nNumProc)
	Local aArea 		:= GetArea()
	Local lRet			:= .T.
	Local nX			:= 0
	Local aProcs 		:= {}
	Local cTabMult		:= ""// Tabela fisica para o processamento multi thread
	Local cChave        := ""

	Local nTotalReg	:= 0
	Local cRaizNome	:= 'CTBFINPROC'
	Local aStruSQL	:= {}
	Local cTabJob	:= "TRBSEU"

	cChave := "EU_FILIAL+EU_CAIXA+DATASEU"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o arquivo de trabalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTabMult := CtbGrvCaix(cChave,@nTotalReg)

	If !Empty(cTabMult) .And. (cTabMult)->(!EOF())
		
		aStruSQL := (cTabMult)->( DbStruct() )
		aProcs := CTBPrepFIN(@nNumProc,cTabMult,nTotalReg,"CTBFLAG",cRaizNome)

		CTBConout('['+PROCNAME()+']:['+cFilAnt+']:['+DTOS(DATE())+']:['+TIME()+']-QTDE:['+ALLTRIM(STR(nTotalReg))+']')
		If  nTotalReg >= nNumProc .And. ((nNumProc > 1) .OR. __lAutoMThrd) // MultiThread
			
			//Inicializa as Threads Transação controlada nas Threads
			For nX := 1 to Len(aProcs)
				StartJob("JOBCTBCAIX", GetEnvServer(), .F., cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],"CTBFLAG",cTabMult,aStruSQL,cTabJob,cValToChar(nX),aProcs[nX][VAR_STATUS],cChave,__cUserId,cUserName,cAcesso,cUsuario,_oCTBAFIN:GETREALNAME())
				CTBSleep(1500)
			Next nX
			
			//NAO RETIRAR A INSTRUCAO DO SLEEP
			//Esperar 05 segundos antes de monitorar para dar tempo das threads criar arquivo de semaforo
			CTBSleep(5000)  
			//Realiza o controle das Threads
			lRet := FINMonitor(aProcs,3)
		ElseIf nNumProc == 1
			cTabJob	 := SelFINJob(NIL,cTabMult,aStruSQL,"CTBFLAG",aProcs[nNumProc][MARCA],cTabJob,cChave,_oCTBAFIN:GETREALNAME())
			lRet 	 := CtbMTProc('SEU',cTabJob)
			If Select(cTabJob) > 0
				(cTabJob)->(dbCloseArea())
			EndIf
		EndIf
	EndIf

	If Select(cTabMult) > 0
		(cTabMult)->( dbCloseArea() )
	Endif

	RestArea(aArea)
	aSize(aArea,0)
	aArea := nil 
Return lRet 

/*/{Protheus.doc} CtbGrvCaix
//Monta a consulta e cria a tabela temporária.
@author norbertom
@since 10/02/2019
@version undefined
@param nNumProc, numeric, description
@return return, return_description
@example
CtbGrvCaix(cChave,nTotalReg)
@see (links_or_references)
/*/
Static Function CtbGrvCaix(cChave,nTotalReg)
	Local aStruSQL		:= {}
	Local cTab			:= ""
	Local cQuery		:= ""
	Local cQuery2		:= ""
	Local cCamposSel	:= ''
	Local cCamposAux	:= ''
	Local cCamposIns	:= ''
	Local aStruAux		:= {}
	Local aStruSEU   	:= {}
	Local cAliasCNT		:= NIL
	Local nI			:= NIL

	Default cChave		:= ''
	Default nTotalReg	:= 0

	LoadPergunte()

	If mv_par07 == 1
		cCamposSel := "EU_FILIAL,EU_CAIXA,EU_BAIXA AS DATASEU, 'OUTROS' AS TIPOMOV "
	Else
		cCamposSel := "EU_FILIAL,EU_CAIXA,EU_DTDIGIT AS DATASEU, 'OUTROS' AS TIPOMOV "
	EndIf

	// Montagem da estrtura do arquivo
	dbSelectArea("SEU")
	SEU->(dbSetOrder(1))
	aStruAux := SEU->(dbStruct())
	For nI := 1 TO LEN(aStruAux)
		If ALLTRIM(aStruAux[nI][1]) $ cCamposSel
			If ALLTRIM(aStruAux[nI][1])$"EU_BAIXA/EU_DTDIGIT"
				AADD(aStruSEU,{"DATASEU"   	,"D",8,00})	
			Else
				AADD(aStruSEU,aStruAux[nI])
			EndIf
		EndIf
	Next nI
	aStruSQL := aClone(aStruSEU)

	AADD(aStruSQL,{"TIPOMOV"   	,"C",10,00})
	AADD(aStruSQL,{"SEURECNO"   ,"N",15,00})
	AADD(aStruSQL,{"CTBFLAG" 	,"C",LEN(&_cSpaceMark),00})

	// Cria tabela temporaria
	If FinZap_Tmp(__oTabSEU)
		__oTabSEU := FINNEWTBL('SEU',aStruSQL,cChave) 
	EndIF 
	_oCTBAFIN:= __oTabSEU
	cTab := __oTabSEU:cAlias

	// Montagem da Query
	aEval(aStruSEU,{|e,i| cCamposIns += If(i==1,'',",")+AllTrim(e[1])})
	cCamposAux := cCamposIns

	If !_MSSQL7
		cCamposIns += ", TIPOMOV,CTBFLAG,R_E_C_N_O_"
	Else
		cCamposIns += ", TIPOMOV,CTBFLAG "
	EndIf 

	cQuery := "SELECT DISTINCT " + cCamposSel

	If !_MSSQL7
		cQuery += "," + _cSpaceMark + " CTBFLAG,SEU.R_E_C_N_O_"
	Else
		cQuery += "," + _cSpaceMark + " CTBFLAG"
	EndIf 

	cQuery += "  FROM " + RetSqlName("SEU")+" SEU "

	If mv_par14 == 1
		If lPosEfMsFil .AND. !lUsaFilOri
			cQuery += "WHERE SEU.EU_MSFIL = '"  + cFilAnt + "' AND "
		Else
			cQuery += "WHERE SEU.EU_FILORI = '"  + cFilAnt + "' AND "
		Endif		
	Else
		cQuery += "WHERE SEU.EU_FILIAL = '" + xFilial("SEU") + "' AND "
	EndIf
	If mv_par07 == 1
		cQuery += " SEU.EU_BAIXA   between '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "
	Else
		cQuery += " SEU.EU_DTDIGIT between '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "
	EndIf

	If _lMvPar18 .And. mv_par18 == 1
		cQuery += "EU_TIPO NOT IN ('01','03') AND  "
	EndIf

	cQuery += " SEU.EU_LA <> 'S' AND "
	cQuery += " SEU.D_E_L_E_T_ = ' ' "

	If _lMvPar18 .And. mv_par18 == 1
		cQuery += " UNION "
							
		cQuery += "SELECT DISTINCT EU_FILIAL, EU_CAIXA, EU_DTDIGIT AS DATASEU, 'ADTO' AS TIPOMOV "
		If !_MSSQL7
			cQuery += "," + _cSpaceMark + " CTBFLAG,SEU.R_E_C_N_O_"
		Else
			cQuery += "," + _cSpaceMark + " CTBFLAG"
		EndIf 
		cQuery += "  FROM " + RetSqlName("SEU")+" SEU "

		If mv_par14 == 1
			If lPosEfMsFil .AND. !lUsaFilOri
				cQuery += "WHERE SEU.EU_MSFIL = '"  + cFilAnt + "' AND "
			Else
				cQuery += "WHERE SEU.EU_FILORI = '"  + cFilAnt + "' AND "
			Endif		
		Else
			cQuery += "WHERE SEU.EU_FILIAL = '" + xFilial("SEU") + "' AND "
		EndIf
		cQuery += " SEU.EU_DTDIGIT BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "
		cQuery +=  "SEU.EU_TIPO IN ('01','03') AND "
		cQuery += " SEU.EU_LA <> 'S' AND "
		cQuery += " SEU.D_E_L_E_T_ = ' ' "
	EndIf

	// seta a ordem de acordo com a opcao do usuario
	cQuery += " ORDER BY " + SqlOrder(cChave)

	//Inicio do bloco que substitui SqlToTrb
	cQuery2 := " INSERT "
	If _cSGBD == "ORACLE"
		cQuery2 += " /*+ APPEND */ "
	Endif
	cQuery2 += " INTO " + __oTabSEU:GETREALNAME() + " ("+cCamposIns+") " + cQuery

	CTBConout('['+PROCNAME()+']:[Criação de tabela temporária: ['+cQuery2+']')

	If TcSqlExec(cQuery2) <> 0
		CTBConout( PROCNAME()+"[ERRO INSERT]:[" + TcSQLError() + ']' )
	EndIf

	cQuery := "SELECT COUNT(1) QUANT "
	cQuery += "  FROM " + __oTabSEU:GETREALNAME() + " TAB "

	cAliasCNT := FINNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCNT )
	(cAliasCNT)->(DbGoTop())
	nTotalReg := (cAliasCNT)->QUANT
	(cAliasCNT)->(dbCloseArea())

	//tiro o arquivo de eof
	DbSelectArea(cTab)
	(cTab)->(dbGoTop())
	//Fim do bloco que substitui SqlToTrb

RETURN cTab

/*/{Protheus.doc} JOBCTBCaix
// Lançador das threads Caixinha.
@author norbertom
@since 10/02/2019
@version undefined
@param nNumProc, numeric, description
@return return, return_description
@example
JOBCTBCaix(cEmpX,cFilX,cMarca,cFileLck,cCpoFlag,cTabMaster,aStructTab,cTabJob,cId,cVarStatus,cChave,cXUserId,cXUserName,cXAcesso,cXUsuario,cFWTMP)
@see (links_or_references)
/*/
Function JOBCTBCaix(cEmpX,cFilX,cMarca,cFileLck,cCpoFlag,cTabMaster,aStructTab,cTabJob,cId,cVarStatus,cChave,cXUserId,cXUserName,cXAcesso,cXUsuario,cFWTMP)
Local nHandle	 := 0
Local lRet		 := .T.

Private lMsErroAuto 
Private lMsHelpAuto 
Private lAutoErrNoFile 

DEFAULT cFWTMP	:= ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre o arquivo de Lock parao controle externo das threads³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHandle := FINLock(cFileLck)

If  nHandle >= 0
	PutGlbValue(cVarStatus,stThrStart)

	//Seta job para nao consumir licensas
	RpcSetType(3)
	RpcClearEnv()
	// Seta job para empresa filial desejada
	RpcSetEnv( cEmpX,cFilX,,,,,)

	PutGlbValue(cVarStatus,stThrConnect)

	//Set o usuário para buscar as perguntas do profile
	lMsErroAuto := .F.
	lMsHelpAuto := .T. 
	lAutoErrNoFile := .T.

	__cUserId := cXUserId 
	cUserName := cXUserName
	cAcesso   := cXAcesso
	cUsuario  := cXUsuario
	DEFAULT _cSGBD		:= Alltrim(Upper(TCGetDB()))
	DEFAULT _MSSQL7		:= _cSGBD $ "MSSQL7"
	DEFAULT _cOperador	:= If(_MSSQL7,"+","||")

	//cria temporario de contabilizacao no banco de dados e otimiza validacao do lancamento
	If _lCtbIniLan
		CtbIniLan()
	EndIf
	
	cTabJob	 := SelFINJob(cVarStatus,cTabMaster,aStructTab,cCpoFlag,cMarca,cTabJob,cChave,cFWTMP)

	// Realiza o processamento
	lRet := CtbMTProc('SEU',cTabJob)

	JOBFINEnd(cVarStatus,nHandle,lRet)

	If Select(cTabJob) > 0
		(cTabJob)->(dbCloseArea())
	EndIf

	//exclui temporario de contabilizacao no banco de dados utilizado para otimizacao validacao do lancamento
	If FindFunction("CtbFinLan")
		//FINALIZA E APAGA ARQUIVO TMP NO BANCO
		CtbFinLan()
	EndIf
	
Else
	PutGlbValue(cVarStatus,stThrError)
EndIf

Return

//CHEQUES

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbMCheq   ºAutor  ³Alvaro Camillo Neto º Data ³  31/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Contabilização de cheques                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbMCheq(nNumProc)
	Local aArea 		:= GetArea()
	Local lRet			:= .T.
	Local nX			:= 0
	Local aProcs 		:= {}
	Local cTabMult		:= ""// Tabela fisica para o processamento multi thread
	Local cChave        := "EF_FILIAL+EF_DATA+EF_BANCO+EF_AGENCIA+EF_CONTA"

	Local nTotalReg	:= 0
	Local cRaizNome	:= 'CTBFINPROC'
	Local aStruSQL	:= {}
	Local cTabJob	:= "TRBSEF"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o arquivo de trabalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTabMult := CtbGrvCheq(cChave,@nTotalReg)

	If !Empty(cTabMult) .And. (cTabMult)->(!EOF())
		
		aStruSQL := (cTabMult)->( DbStruct() )
		aProcs := CTBPrepFIN(@nNumProc,cTabMult,nTotalReg,"CTBFLAG",cRaizNome)

		CTBConout('['+PROCNAME()+']:['+cFilAnt+']:['+DTOS(DATE())+']:['+TIME()+']-QTDE:['+ALLTRIM(STR(nTotalReg))+']')
		If  nTotalReg >= nNumProc .And. ((nNumProc > 1) .OR. __lAutoMThrd) // MultiThread
			
			//Inicializa as Threads Transação controlada nas Threads
			For nX := 1 to Len(aProcs)
				StartJob("JOBCTBCHEQ", GetEnvServer(), .F., cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],"CTBFLAG",cTabMult,aStruSQL,cTabJob,cValToChar(nX),aProcs[nX][VAR_STATUS],cChave,__cUserId,cUserName,cAcesso,cUsuario,_oCTBAFIN:GETREALNAME())
				CTBSleep(1500)
			Next nX
			
			//NAO RETIRAR A INSTRUCAO DO SLEEP
			//Esperar 05 segundos antes de monitorar para dar tempo das threads criar arquivo de semaforo
			CTBSleep(5000)  
			//Realiza o controle das Threads
			lRet := FINMonitor(aProcs,3)
		ElseIf nNumProc == 1
			cTabJob	 := SelFINJob(NIL,cTabMult,aStruSQL,"CTBFLAG",aProcs[nNumProc][MARCA],cTabJob,cChave,_oCTBAFIN:GETREALNAME())
			lRet 	 := CtbMTProc('SEF',cTabJob)
			If Select(cTabJob) > 0
				(cTabJob)->(dbCloseArea())
			EndIf
		EndIf
	EndIf

	If Select(cTabMult) > 0
		(cTabMult)->( dbCloseArea() )
	Endif

	RestArea(aArea)
	aSize(aArea,0)
	aArea := nil 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbGrvCheq  ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava arquivo temporario dos cheques                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbGrvCheq(cChave,nTotalReg)
	Local aStruSQL		:= {}
	Local cTab			:= ""
	Local cQuery		:= ""
	Local cQuery2		:= ""
	Local cCamposSel	:= ''
	Local cCamposIns	:= ''
	Local aStruSEF   	:= {}
	Local cAliasCNT     := ''
	Local l370EFFIL 	:= Existblock("F370EFF")   // Criado Ponto de Entrada
	Local lCtCheqLib    := SuperGetMv("MV_CTCHQBX",.T.,"1") == "2"	// Contabilizar na data da liberação
	Local cMVSLDBXCR 	:= SuperGetMv("MV_SLDBXCR",.F.,.F.)	//Controlade do Saldo na Baixa: (C) quando cheque for compensado - (B) no momento da baixa
	LOCAL nI			:= 0
	Local lCtbChLib     := .F.

	Default nTotalReg	:= 0

	LoadPergunte()

	dbSelectArea("SEF")
	SEF->(dbSetOrder(1))

	// Montagem da estrutura do arquivo
	aStruSEF  := SEF->(dbStruct())
	aStruSQL := aClone(aStruSEF)
	AADD(aStruSQL,{"DTLIB","D",TAMSX3("E5_DATA")[1],TAMSX3("E5_DATA")[2]})
	AADD(aStruSQL,{"SEFRECNO"   	,"N",15,00})
	AADD(aStruSQL,{"SE5RECNO"   	,"N",15,00})
	AADD(aStruSQL,{"CTBFLAG" 		,"C",LEN(&_cSpaceMark),00})

	// Cria tabela temporaria
	If FinZap_Tmp(__oTabSEF)
		__oTabSEF := FINNEWTBL('SEF',aStruSQL,cChave) 
	EndIF 
	_oCTBAFIN:= __oTabSEF
	cTab := __oTabSEF:cAlias

	// Montagem da Query
	cCamposSel := ''
	cCamposIns := ''
	aEval(aStruSEF,{|e,i| cCamposIns += If(i==1,'',",")+AllTrim(e[1])})
	cCamposSel := cCamposIns

	If !_MSSQL7
		cCamposIns += ',DTLIB,SEFRECNO,SE5RECNO,CTBFLAG,R_E_C_N_O_'
	Else
		cCamposIns += ',DTLIB,SEFRECNO,SE5RECNO,CTBFLAG'
	EndIf 

	FOR nI := 1 TO 2	// 1 - Cheques Recebidos // 2 - Cheques para Pagamentos

		lCtbChLib := ((nI == 1) .AND. (cMVSLDBXCR == 'C')) .OR. ((nI == 2) .AND. lCtCheqLib)

		cQuery += "SELECT " + cCamposSel

		// Contabilizar na data da liberação
		IF lCtbChLib
			cQuery += ",SE5.E5_DATA DTLIB"
		ELSE
			cQuery += ",SEF.EF_DATA DTLIB"
		ENDIF

		cRecSE5 := IIF(lCtbChLib,"SE5.R_E_C_N_O_", '0')

		If !_MSSQL7
			cQuery += ",SEF.R_E_C_N_O_ SEFRECNO,"+cRecSE5+" SE5RECNO," + _cSpaceMark + " CTBFLAG,SEF.R_E_C_N_O_"
		Else
			cQuery += ",SEF.R_E_C_N_O_ SEFRECNO,"+cRecSE5+" SE5RECNO," + _cSpaceMark + " CTBFLAG"
		EndIf 

		cQuery += "  FROM " + RetSqlName("SEF")+" SEF "

		// Contabilizar na data da liberação
		If lCtbChLib
			cQuery += "INNER JOIN " + RetSqlName("SE5") + " SE5 ON "
			cQuery += "SE5.E5_FILIAL = SEF.EF_FILIAL AND " 
			cQuery += "SE5.E5_PREFIXO = SEF.EF_PREFIXO AND SE5.E5_NUMERO = SEF.EF_TITULO AND SE5.E5_PARCELA = SEF.EF_PARCELA AND "
			cQuery += "SE5.E5_NUMCHEQ = SEF.EF_NUM "
		EndIf

		If mv_par14 == 1
			If lPosEfMsFil .AND. !lUsaFilOri
				cQuery += "WHERE EF_MSFIL = '"  + cFilAnt + "' AND "
			Else
				cQuery += "WHERE EF_FILORIG = '"  + cFilAnt + "' AND "
			Endif		
		Else
			cQuery += "WHERE EF_FILIAL = '" + xFilial("SEF") + "' AND "
		EndIf

		// Contabilizar na data da liberação
		If lCtbChLib
			cQuery += "EF_LIBER = 'S' AND "
			cQuery += "EF_LA <> 'S' AND "

			// Insere a validação da carteira somente para uso Exclusivo do CR / CP
			// Se ambos utilizam na Compensação (CR) e na Liberação (CP) a validação não é necessária
			IF (nI == 1) .AND. (cMVSLDBXCR == 'C')
				cQuery += "EF_CART = 'R' AND "
			ELSEIF (nI == 2) .AND. (cMVSLDBXCR == 'C')
				cQuery += "EF_CART <> 'R' AND "
			ENDIF

			cQuery += "SEF.D_E_L_E_T_ = ' ' AND "
			cQuery += "E5_DATA BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND " 
			cQuery += "(E5_TIPODOC = 'CH' OR E5_TIPODOC = 'CA') AND "
			cQuery += "E5_LA <> 'S' AND "
			cQuery += "E5_SITUACA <> 'C' AND "
			cQuery += "SE5.D_E_L_E_T_ = ' ' AND "
			cQuery += "(SELECT COUNT(EST.E5_FILIAL) FROM " + RetSqlName("SE5") + " EST "
			cQuery += "WHERE EST.E5_FILIAL = SEF.EF_FILIAL "
			cQuery += "AND EST.E5_PREFIXO = SEF.EF_PREFIXO "
			cQuery += "AND EST.E5_NUMERO = SEF.EF_TITULO "
			cQuery += "AND EST.E5_PARCELA = SEF.EF_PARCELA "
			cQuery += "AND EST.E5_NUMCHEQ = SEF.EF_NUM "
			cQuery += "AND EST.E5_SEQ = SE5.E5_SEQ "
			cQuery += "AND EST.E5_TIPODOC = 'ES' "
			cQuery += "AND EST.D_E_L_E_T_ = ' ') = 0 "
		Else	// Contabilizar na data da geração
			cQuery += "EF_DATA BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "
			
			//Filtra a carteira na SEF caso o loop (FOR) nao seja interrompido e seja executado 2 vezes
			IF (cMVSLDBXCR == 'B' .and. lCtCheqLib) .or. (cMVSLDBXCR == 'C' .and. lCtCheqLib) .or. (cMVSLDBXCR == 'C' .and. !lCtCheqLib)
				If nI == 1 
					cQuery += "EF_CART = 'R' AND "
				Else
					cQuery += "EF_CART <> 'R' AND "
				Endif
			Endif

			cQuery += "EF_LA <> 'S' AND SEF.D_E_L_E_T_ = ' ' "
		EndIF

		// Utilizado para filtrar dados do SEF no momento da contabilização.
		If l370EFFIL
			cQuery += Execblock("F370EFF",.F.,.F.,cQuery)
		EndIf

		// Permite alterar a chave de ordenação da contabilização de cheques, na rotina Contabilização offline.
		If l370EFKEY
			cChave := Execblock("F370EFK",.F.,.F.,cChave)
		EndIf

		// Quando os cheques (recebidos ou pagos) não utilizam controle de Compensação ou de Liberação, interrompe o laço para só ler a SEF
		IF (nI == 1) .AND. EMPTY(lCtCheqLib) .AND. (cMVSLDBXCR == 'B') 
			EXIT
		ELSEIF (nI == 1)
			cQuery += "UNION ALL "
		ENDIF
		
	NEXT nI

	// Seta a ordem de acordo com a opcao do usuario
	cQuery += " ORDER BY " + SqlOrder(cChave)

	//Inicio do bloco que substitui SqlToTrb
	cQuery2 := " INSERT "
	If _cSGBD == "ORACLE"
		cQuery2 += " /*+ APPEND */ "
	Endif

	// Montagem da querie de execução.
	cQuery2 += " INTO " + __oTabSEF:GETREALNAME() + " ("+cCamposIns+") " + cQuery

	CTBConout('['+PROCNAME()+']:[Criação de tabela temporária: ['+cQuery2+']')

	If TcSqlExec(cQuery2) <> 0
		CTBConout( PROCNAME()+"[ERRO INSERT]:[" + TcSQLError() + ']' )
	EndIf

	cQuery := "SELECT COUNT(1) QUANT "
	cQuery += "  FROM " + __oTabSEF:GETREALNAME() + " TAB "

	cAliasCNT := FINNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCNT )
	(cAliasCNT)->(DbGoTop())
	nTotalReg := (cAliasCNT)->QUANT
	(cAliasCNT)->(dbCloseArea())

	//tiro o arquivo de eof
	DbSelectArea(cTab)
	(ctab)->(dbGoTop())
	//Fim do bloco que substitui SqlToTrb

RETURN ctab
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JOBCTBCheq  ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Job da contabilização de cheques                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function JOBCTBCheq(cEmpX,cFilX,cMarca,cFileLck,cCpoFlag,cTabMaster,aStructTab,cTabJob,cId,cVarStatus,cChave,cXUserId,cXUserName,cXAcesso,cXUsuario,cFWTMP)
Local nHandle	 := 0
Local lRet		 := .T.

Private lMsErroAuto 
Private lMsHelpAuto 
Private lAutoErrNoFile 

DEFAULT cFWTMP	:= ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre o arquivo de Lock parao controle externo das threads³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHandle := FINLock(cFileLck)

If  nHandle >= 0
	PutGlbValue(cVarStatus,stThrStart)

	//Seta job para nao consumir licensas
	RpcSetType(3)
	RpcClearEnv()
	// Seta job para empresa filial desejada
	RpcSetEnv( cEmpX,cFilX,,,,,)

	PutGlbValue(cVarStatus,stThrConnect)

	//Set o usuário para buscar as perguntas do profile
	lMsErroAuto := .F.
	lMsHelpAuto := .T. 
	lAutoErrNoFile := .T.

	__cUserId := cXUserId 
	cUserName := cXUserName
	cAcesso   := cXAcesso
	cUsuario  := cXUsuario
	DEFAULT _cSGBD		:= Alltrim(Upper(TCGetDB()))
	DEFAULT _MSSQL7		:= _cSGBD $ "MSSQL7"
	DEFAULT _cOperador	:= If(_MSSQL7,"+","||")

	//cria temporario de contabilizacao no banco de dados e otimiza validacao do lancamento
	If _lCtbIniLan
		CtbIniLan()
	EndIf
	
	cTabJob	 := SelFINJob(cVarStatus,cTabMaster,aStructTab,cCpoFlag,cMarca,cTabJob,cChave,cFWTMP)

	// Realiza o processamento
	lRet := CtbMTProc('SEF',cTabJob)

	JOBFINEnd(cVarStatus,nHandle,lRet)

	If Select(cTabJob) > 0
		(cTabJob)->(dbCloseArea())
	EndIf

	//exclui temporario de contabilizacao no banco de dados utilizado para otimizacao validacao do lancamento
	If FindFunction("CtbFinLan")
		//FINALIZA E APAGA ARQUIVO TMP NO BANCO
		CtbFinLan()
	EndIf
	
Else
	PutGlbValue(cVarStatus,stThrError)
EndIf

Return

//CONTAS A PAGAR

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbMPag   ºAutor  ³Alvaro Camillo Neto º Data ³  31/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Contabilização do titulos a pagar                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbMPag(nNumProc)
	Local aArea 		:= GetArea()
	Local lRet			:= .T.
	Local nX			:= 0
	Local aProcs 		:= {}
	Local cTabMult		:= ""// Tabela fisica para o processamento multi thread
	Local cChave 		:= "E2_FILIAL+E2_EMIS1+E2_NUMBOR+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA"

	Local nTotalReg	:= 0
	Local cRaizNome	:= 'CTBFINPROC'
	Local aStruSQL	:= {}
	Local cTabJob	:= "TRBSE2"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o arquivo de trabalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTabMult := CtbGrvPag(cChave,@nTotalReg)

	If !Empty(cTabMult) .And. (cTabMult)->(!EOF())
		
		aStruSQL := (cTabMult)->( DbStruct() )
		aProcs := CTBPrepFIN(@nNumProc,cTabMult,nTotalReg,"CTBFLAG",cRaizNome)

		CTBConout('['+PROCNAME()+']:['+cFilAnt+']:['+DTOS(DATE())+']:['+TIME()+']-QTDE:['+ALLTRIM(STR(nTotalReg))+']')
		If  nTotalReg >= nNumProc .And. ((nNumProc > 1) .OR. __lAutoMThrd) // MultiThread
			
			//Inicializa as Threads Transação controlada nas Threads
			For nX := 1 to Len(aProcs)
				StartJob("JOBCTBPAG", GetEnvServer(), .F., cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],"CTBFLAG",cTabMult,aStruSQL,cTabJob,cValToChar(nX),aProcs[nX][VAR_STATUS],cChave,__cUserId,cUserName,cAcesso,cUsuario,_oCTBAFIN:GETREALNAME())
				CTBSleep(1500)
			Next nX
			
			//NAO RETIRAR A INSTRUCAO DO SLEEP
			//Esperar 05 segundos antes de monitorar para dar tempo das threads criar arquivo de semaforo
			CTBSleep(5000)
			//Realiza o controle das Threads
			lRet := FINMonitor(aProcs,2)
		ElseIf nNumProc == 1
			cTabJob	 := SelFINJob(NIL,cTabMult,aStruSQL,"CTBFLAG",aProcs[nNumProc][MARCA],cTabJob,cChave,_oCTBAFIN:GETREALNAME())
			lRet 	 := CtbMTProc('SE2',cTabJob)
			If Select(cTabJob) > 0
				(cTabJob)->(dbCloseArea())
			EndIf
		EndIf
	EndIf

	If Select(cTabMult) > 0
		(cTabMult)->( dbCloseArea() )
	Endif

	RestArea(aArea)
	aSize(aArea,0)
	aArea := nil 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbGrvPag  ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava arquivo temporario dos titulos a Pagar                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbGrvPag(cChave,nTotalReg)
	Local aStruSQL		:= {}
	Local cTab			:= ""
	Local cQuery		:= ""
	Local cQuery2		:= ""
	Local cCamposSel	:= ''
	Local cCamposIns	:= ''
	Local aStruSE2		:= {}
	Local cSepProv		:= If("|"$MVPROVIS,"|",",")
	Local cAliasCNT		:= ''

	Static l370E2FIL	:= Existblock("F370E2F")   // Criado Ponto de Entrada

	Default nTotalReg	:= 0

	LoadPergunte()

	dbSelectArea("SE2")
	dbSetOrder(1)

	// Montagem da estrtura do arquivo
	aStruSE2  := SE2->(dbStruct())
	aStruSQL := aClone(aStruSE2)
	AADD(aStruSQL,{"SE2RECNO"    	,"N",15,00})
	AADD(aStruSQL,{"CTBFLAG" 		,"C",LEN(&_cSpaceMark),00})

	// Cria tabela temporaria
	If FinZap_Tmp(__oTabSE2)
		__oTabSE2 := FINNEWTBL('SE2',aStruSQL,cChave) 
	EndIF 
	_oCTBAFIN:= __oTabSE2
	cTab := __oTabSE2:cAlias

	// Montagem da Query
	cCamposSel := ''
	cCamposIns := ''
	aEval(aStruSE2,{|e,i| cCamposIns += If(i==1,'',",")+AllTrim(e[1])})
	cCamposSel := cCamposIns
	If !_MSSQL7
		cCamposIns += ',SE2RECNO,CTBFLAG,R_E_C_N_O_'
	Else
		cCamposIns += ',SE2RECNO,CTBFLAG'
	EndIf 

	cQuery := "SELECT " + cCamposSel
	If !_MSSQL7
		cQuery += ",SE2.R_E_C_N_O_ SE2RECNO," + _cSpaceMark + " CTBFLAG,SE2.R_E_C_N_O_"
	Else
		cQuery += ",SE2.R_E_C_N_O_ SE2RECNO," + _cSpaceMark + " CTBFLAG"
	EndIf 
	cQuery += "  FROM " + RetSqlName("SE2")+" SE2 "

	If mv_par14 == 1	
		If lPosE2MsFil .AND. !lUsaFilOri
		cQuery += "WHERE E2_MSFIL = '"  + cFilAnt + "' AND "
	Else
			cQuery += "WHERE E2_FILORIG = '"  + cFilAnt + "' AND "
		Endif	
	Else
		cQuery += "WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND "
	EndIf

	cQuery += "E2_EMIS1 between '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' AND "

	// Soh adiciona filtro na query se nao contabiliza titulos provisorios
	If mv_par17 <> 1
		cQuery += "E2_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
	EndIf

	cQuery += " E2_LA <> 'S' AND E2_ORIGEM <> 'FINA677' AND "
	cQuery += " D_E_L_E_T_ = ' ' "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para filtrar registros do SE2. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l370E2FIL
		cQuery := Execblock("F370E2F",.F.,.F.,cQuery)
	EndIf

	// seta a ordem de acordo com a opcao do usuario
	cQuery += " ORDER BY " + SqlOrder(cChave)

	//Inicio do bloco que substitui SqlToTrb
	cQuery2 := " INSERT "
	If _cSGBD == "ORACLE"
		cQuery2 += " /*+ APPEND */ "
	Endif
	cQuery2 += " INTO " + __oTabSE2:GETREALNAME() + " ("+cCamposIns+") " + cQuery

	CTBConout('['+PROCNAME()+']:[Criação de tabela temporária: ['+cQuery2+']')

	If TcSqlExec(cQuery2) <> 0
		CTBConout( PROCNAME()+"[ERRO INSERT]:[" + TcSQLError() + ']' )
	EndIf

	// Obtem a Contagem de Registros a processar.
	cQuery := "SELECT COUNT(1) QUANT "
	cQuery += "  FROM " + __oTabSE2:GETREALNAME() + " TAB "

	cAliasCNT := FINNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCNT )
	(cAliasCNT)->(DbGoTop())
	nTotalReg := (cAliasCNT)->QUANT
	(cAliasCNT)->(dbCloseArea())

	//tiro o arquivo de eof
	DbSelectArea(cTab)
	(ctab)->(dbGoTop())
	//Fim do bloco que substitui SqlToTrb

RETURN ctab
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JOBCTBPag ºAutor  ³Alvaro Camillo Neto º Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Job da contabilização do titulo a pagar                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function JOBCTBPag(cEmpX,cFilX,cMarca,cFileLck,cCpoFlag,cTabMaster,aStructTab,cTabJob,cId,cVarStatus,cChave,cXUserId,cXUserName,cXAcesso,cXUsuario,cFWTMP)
Local nHandle	 := 0
Local lRet		 := .T.

Private lMsErroAuto 
Private lMsHelpAuto 
Private lAutoErrNoFile 

DEFAULT cFWTMP	:= ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre o arquivo de Lock parao controle externo das threads³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHandle := FINLock(cFileLck)

If  nHandle >= 0
	PutGlbValue(cVarStatus,stThrStart)

	//Seta job para nao consumir licensas
	RpcSetType(3)
	RpcClearEnv()
	// Seta job para empresa filial desejada
	RpcSetEnv( cEmpX,cFilX,,,,,)

	PutGlbValue(cVarStatus,stThrConnect)

	//Set o usuário para buscar as perguntas do profile
	lMsErroAuto := .F.
	lMsHelpAuto := .T. 
	lAutoErrNoFile := .T.

	__cUserId := cXUserId 
	cUserName := cXUserName
	cAcesso   := cXAcesso
	cUsuario  := cXUsuario
	DEFAULT _cSGBD		:= Alltrim(Upper(TCGetDB()))
	DEFAULT _MSSQL7		:= _cSGBD $ "MSSQL7"
	DEFAULT _cOperador	:= If(_MSSQL7,"+","||")

	//cria temporario de contabilizacao no banco de dados e otimiza validacao do lancamento
	If _lCtbIniLan
		CtbIniLan()
	EndIf
	
	cTabJob	 := SelFINJob(cVarStatus,cTabMaster,aStructTab,cCpoFlag,cMarca,cTabJob,cChave,cFWTMP)

	// Realiza o processamento
	lRet := CtbMTProc('SE2',cTabJob)

	JOBFINEnd(cVarStatus,nHandle,lRet)

	If Select(cTabJob) > 0
		(cTabJob)->(dbCloseArea())
	EndIf

	//exclui temporario de contabilizacao no banco de dados utilizado para otimizacao validacao do lancamento
	If FindFunction("CtbFinLan")
		//FINALIZA E APAGA ARQUIVO TMP NO BANCO
		CtbFinLan()
	EndIf
	
Else
	PutGlbValue(cVarStatus,stThrError)
EndIf

Return

// CONTAS A RECEBER

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbMRec   ºAutor  ³Alvaro Camillo Neto º Data ³  31/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Contabilização do titulos a receber                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbMRec(nNumProc)
	Local aArea 		:= GetArea()
	Local lRet			:= .T.
	Local nX			:= 0
	Local aProcs 		:= {}
	Local cTabMult		:= ""// Tabela fisica para o processamento multi thread
	Local cChave 		:= "E1_FILIAL+E1_EMISSAO+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA"

	Local nTotalReg	:= 0
	Local cRaizNome	:= 'CTBFINPROC'
	Local aStruSQL	:= {}
	Local cTabJob	:= "TRBSE1"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o arquivo de trabalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTabMult := CtbGrvRec(cChave,@nTotalReg)

	If !Empty(cTabMult) .And. (cTabMult)->(!EOF())
		
		aStruSQL := (cTabMult)->( DbStruct() )
		aProcs := CTBPrepFIN(@nNumProc,cTabMult,nTotalReg,"CTBFLAG",cRaizNome)

		CTBConout('['+PROCNAME()+']:['+cFilAnt+']:['+DTOS(DATE())+']:['+TIME()+']-QTDE:['+ALLTRIM(STR(nTotalReg))+']')
		If  nTotalReg >= nNumProc .And. ((nNumProc > 1) .OR. __lAutoMThrd) // MultiThread
			
			//Inicializa as Threads Transação controlada nas Threads
			For nX := 1 to Len(aProcs)
				StartJob("JOBCTBREC", GetEnvServer(), .F., cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],"CTBFLAG",cTabMult,aStruSQL,cTabJob,cValToChar(nX),aProcs[nX][VAR_STATUS],cChave,__cUserId,cUserName,cAcesso,cUsuario,_oCTBAFIN:GETREALNAME())
				CTBSleep(1500)
			Next nX
			
			//NAO RETIRAR A INSTRUCAO DO SLEEP
			//Esperar 05 segundos antes de monitorar para dar tempo das threads criar arquivo de semaforo
			CTBSleep(5000)  
			//Realiza o controle das Threads
			lRet := FINMonitor(aProcs,1)
		ElseIf nNumProc == 1
			cTabJob	 := SelFINJob(NIL,cTabMult,aStruSQL,"CTBFLAG",aProcs[nNumProc][MARCA],cTabJob,cChave,_oCTBAFIN:GETREALNAME())
			lRet 	 := CtbMTProc('SE1',cTabJob)
			If Select(cTabJob) > 0	
				(cTabJob)->(dbCloseArea())
			EndIf
		EndIf
	EndIf

	If Select(cTabMult) > 0
		(cTabMult)->( dbCloseArea() )
	Endif

	RestArea(aArea)
	aSize(aArea,0)
	aArea := nil 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbGrvRec ºAutor  ³Alvaro Camillo Neto º Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava arquivo temporario dos titulos a receber              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbGrvRec(cChave, nTotalReg)
	Local aStruSQL		:= {}
	Local cTab			:= ""
	Local cQuery		:= ""
	Local cQuery2		:= ""
	Local cCamposSel	:= ''
	Local cCamposIns	:= ''
	Local aStruSE1   	:= {}
	Local cAliQry       := ""
	Local nCtbVenda		:= SuperGetMV("MV_CTBINTE",,1) // 1 - Contabiliza por titulo ; 2 - contabiliza por venda (somente quando possuir integração)
	Local cAliasCNT		:= ''
	Local l370E1FIL     := Existblock("F370E1F" )   // Criado Ponto de Entrada

	Default nTotalReg   := 0

	cAliQry := cTab + "_1" 

	LoadPergunte()

	dbSelectArea("SE1")
	dbSetOrder(1)

	// Montagem da estrtura do arquivo
	aStruSE1  := SE1->(dbStruct())
	aStruSQL := aClone(aStruSE1)
	AADD(aStruSQL,{"SE1RECNO"    	,"N",15,00})
	AADD(aStruSQL,{"CTBFLAG" 		,"C",LEN(&_cSpaceMark),00})

	// Cria tabela temporaria
	If FinZap_Tmp(__oTabSE1)
		__oTabSE1 := FINNEWTBL('SE1',aStruSQL,cChave) 
	EndIF 
	_oCTBAFIN:= __oTabSE1
	cTab := __oTabSE1:cAlias

	// Montagem da Query
	cCamposSel := ''
	cCamposIns := ''
	aEval(aStruSE1,{|e,i| cCamposIns += IF(i==1,'',',')+AllTrim(e[1])})
	cCamposSel := cCamposIns
	If !_MSSQL7
		cCamposIns += ',SE1RECNO,CTBFLAG,R_E_C_N_O_'
	Else
		cCamposIns += ',SE1RECNO,CTBFLAG'
	EndIf 

	cQuery := "SELECT " + cCamposSel
	If !_MSSQL7
		cQuery += ",SE1.R_E_C_N_O_ SE1RECNO," + _cSpaceMark + " CTBFLAG,SE1.R_E_C_N_O_"
	Else
		cQuery += ",SE1.R_E_C_N_O_ SE1RECNO," + _cSpaceMark + " CTBFLAG"
	EndIf 
	cQuery += "  FROM " + RetSqlName("SE1")+" SE1 "

	If mv_par14 == 1
		If lPosE1MsFil .AND. !lUsaFilOri
			cQuery += "WHERE E1_MSFIL = '"  + cFilAnt + "'"
	Else
			cQuery += "WHERE E1_FILORIG = '"  + cFilAnt + "'"
		Endif	
	Else
		cQuery += "WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
	EndIf

	cQuery += " AND SE1.E1_EMISSAO BETWEEN '"+DTOS(mv_par04)+"' AND '"+DTOS(mv_par05)+"'"
	cQuery += " AND SE1.E1_LA <> 'S' AND E1_ORIGEM <> 'FINA677'  "       

	If nCtbVenda == 2 //Contabilização por venda
		cQuery += " AND E1_ORIGEM <> 'FINI055'"
	Endif

	cQuery += " AND D_E_L_E_T_ = ' ' "

	// Ponto de Entrada para filtrar registros do SE1.
	If l370E1FIL
		cQuery := Execblock("F370E1F",.F.,.F.,cQuery)
	EndIf

	cQuery += " ORDER BY " + SqlOrder(cChave)

	//Inicio do bloco que substitui SqlToTrb
	cQuery2 := " INSERT "
	If _cSGBD == "ORACLE"
		cQuery2 += " /*+ APPEND */ "
	Endif
	cQuery2 += " INTO " + __oTabSE1:GETREALNAME() + " ("+cCamposIns+") " + cQuery

	CTBConout('['+PROCNAME()+']:[Criação de tabela temporária: ['+cQuery2+']')

	If TcSqlExec(cQuery2) <> 0
		CTBConout( PROCNAME()+"[ERRO INSERT]:[" + TcSQLError() + ']' )	
	EndIf

	// Obtem a Contagem de Registros a processar.
	cQuery := "SELECT COUNT(1) QUANT "
	cQuery += "  FROM " + __oTabSE1:GETREALNAME() + " TAB "

	cAliasCNT := FINNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCNT )

	nTotalReg := (cAliasCNT)->QUANT
	(cAliasCNT)->(dbCloseArea())

	//tiro o arquivo de eof
	DbSelectArea(cTab)
	(ctab)->(dbGoTop())
	//Fim do bloco que substitui SqlToTrb

RETURN ctab

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JOBCTBREC ºAutor  ³Alvaro Camillo Neto º Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Job da contabilização do titulo a receber                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function JOBCTBREC(cEmpX,cFilX,cMarca,cFileLck,cCpoFlag,cTabMaster,aStructTab,cTabJob,cId,cVarStatus,cChave,cXUserId,cXUserName,cXAcesso,cXUsuario,cFWTMP)
Local nHandle	 := 0
Local lRet		 := .T.   

Private lMsErroAuto 
Private lMsHelpAuto 
Private lAutoErrNoFile 

DEFAULT cFWTMP	:= ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre o arquivo de Lock parao controle externo das threads³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHandle := FINLock(cFileLck)

If  nHandle >= 0
	PutGlbValue(cVarStatus,stThrStart)

	//Seta job para nao consumir licensas
	RpcSetType(3)
	RpcClearEnv()
	// Seta job para empresa filial desejada
	RpcSetEnv( cEmpX,cFilX,,,,,)

	PutGlbValue(cVarStatus,stThrConnect)

	//Set o usuário para buscar as perguntas do profile
	lMsErroAuto := .F.
	lMsHelpAuto := .T. 
	lAutoErrNoFile := .T.

	__cUserId := cXUserId 
	cUserName := cXUserName
	cAcesso   := cXAcesso
	cUsuario  := cXUsuario
	DEFAULT _cSGBD		:= Alltrim(Upper(TCGetDB()))
	DEFAULT _MSSQL7		:= _cSGBD $ "MSSQL7"
	DEFAULT _cOperador	:= If(_MSSQL7,"+","||")

	//cria temporario de contabilizacao no banco de dados e otimiza validacao do lancamento
	If _lCtbIniLan
		CtbIniLan()
	EndIf
	
	cTabJob	 := SelFINJob(cVarStatus,cTabMaster,aStructTab,cCpoFlag,cMarca,cTabJob,cChave,cFWTMP)

	// Realiza o processamento
	lRet := CtbMTProc('SE1',cTabJob)
		
	JOBFINEnd(cVarStatus,nHandle,lRet)

	If Select(cTabJob) > 0
		(cTabJob)->(dbCloseArea())
	EndIf

	//exclui temporario de contabilizacao no banco de dados utilizado para otimizacao validacao do lancamento
	If FindFunction("CtbFinLan")
		//FINALIZA E APAGA ARQUIVO TMP NO BANCO
		CtbFinLan()
	EndIf
	
Else
	PutGlbValue(cVarStatus,stThrError)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINMonitorºAutor  ³Alvaro Camillo Neto º Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função responsavel por monitorar as threads de processamen º±±
±±º          ³ to                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FINMonitor(aProcs,nTipo)
Local lRet			:= .T.
Local nX			:= 0
Local nHandle		:= 0
Local cMsg			:= ""
Local cRotErro		:= ""
Local cTipoErro		:= ""
Local cMsgErro		:= ""
Local aErros		:= {}
Local cMarkSem		:= "***"
Local nMarkSem		:= 0
Local cArqSem		:= ""
Local cOrigem		:= ""
Local nTMPGerado	:= 0
Local aTMPGerado	:= ARRAY(LEN(aProcs))

DEFAULT nTipo := 0

AFILL(aTMPGerado,.F.)

Do Case
	Case nTipo == 1 //Contas a receber
		cOrigem := 'CTBREC'
	Case nTipo == 2 //Contas a pagar
		cOrigem := 'CTBPAG'
	Case nTipo == 3 //Cheque
		cOrigem := 'CTBCHQ'
	Case nTipo == 4 //Movimentacao
		cOrigem := 'CTBMOV'
EndCase

WHILE .T.
	For nX := 1 to Len(aProcs)
		If nTMPGerado < Len(aProcs)
			If !aTMPGerado[nX] .and. GetGlbValue(aProcs[nX][VAR_STATUS]) >= '3'
				aTMPGerado[nX] := .T.
				nTMPGerado++
                CTBConout('['+PROCNAME()+']:FILIAL:['+cFilAnt+']:['+DTOS(DATE())+']:['+TIME()+']:TMP GERADO MARCA:['+aProcs[nX][MARCA]+']')
			EndIf
		EndIf
		
		If aScan(aProcs,{|aItem| aItem[1] == cMarkSem + aProcs[nX][1]} ) == 0
			//espera 15 segundos antes de tentar lockar o arquivo
			//CTBSleep(15000)
			nHandle := FINLock(aProcs[nX][1])
			If  nHandle >= 0
				FClose(nHandle)
				aProcs[nX][1] := cMarkSem + aProcs[nX][1]
				nMarkSem++
			EndIf
		EndIf
	Next
	If nMarkSem >= Len(aProcs)
		Exit
	EndIF

	CTBSleep(2000)  //espera +5 segundos antes de entrar novamente no laco FOR....NEXT
ENDDO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se todas a threads foram processadas corretamente³
//³libera o recurso e apaga o arquivo                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aProcs)
	cArqSem := STRTRAN(aProcs[nX][1],"*","")
	
	FT_FUse(cArqSem)
	FT_FGoTop()
	cMsg := FT_FReadLn()
	FT_FUse()
	fErase(cArqSem)
	
	If lRet .And. ALLTRIM(cMsg) != MSG_OK
		lRet := .F.
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica quais threads deram erro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRet
	Do Case
		Case nTipo == 1 //Contas a receber
			cRotErro := STR0039	//" Erro no processamento Contas a receber: "
		Case nTipo == 2 //Contas a pagar
			cRotErro := STR0040	//" Erro no processamento Contas a pagar: "
		Case nTipo == 3 //Cheque
			cRotErro := STR0041	//" Erro no processamento Cheques: "
		Case nTipo == 4 //Movimentacao
			cRotErro := STR0042	//" Erro no processamento Movimentação bancária: "
		Otherwise
			cRotErro := STR0046	//"Erro no Processamento"
	EndCase
	
	For nX := 1 to Len(aProcs)
		cStatus := GetGlbValue(aProcs[nX][VAR_STATUS])
		If cStatus != '3' // Concluido com sucesso
			Do Case
				Case cStatus == "1" // Erro na Conexão
					cTipoErro := STR0043//" Erro na inicialização do processo"
				Case cStatus == "2" // Erro no Processamento
					cTipoErro := STR0044 //" Erro no processo de contabilização"
			EndCase
			cMsgErro := cRotErro + cTipoErro + STR0045 + cValTochar(nX) //" processo numero "
			ProcLogAtu("ERRO",STR0046,cMsgErro)//"Erro no Processamento"
			aAdd(aErros,cMsgErro)
		EndIf
	Next nX
EndIf

// Limpa Variáveis Globais
For nX := 1 TO LEN(aProcs)
	ClearGlbValue(aProcs[nX][VAR_STATUS])
Next nX

If !lRet .AND. !__lAutoMThrd
	If !__lSchedule .AND. MsgYesNo(STR0047)	//"Ocorreram inconsistencia no processo, deseja imprimir o relatorio de erros?"
		CtRConOut(aErros)
	EndIf
EndIf

CTBConout('['+PROCNAME()+']:FILIAL:['+cFilAnt+']:['+DTOS(DATE())+']:['+TIME()+']:MONITOR FINISH:['+alltrim(str(ThreadID()))+']')

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SelFINJob ºAutor  ³Alvaro Camillo Neto º Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Seleciona os registros para o processamento da Thread      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SelFINJob(cArqSem,cTabMaster,aStructTab,cCpoFlag,cMarca,cTabJob,cChave,cFWTMP)
Local cQuery	:= ""
Local nX		:= 0

Default cArqSem	:= ''
Default cTabJob	:= FINNextAlias()
Default cFWTMP	:= cTabMaster
Default cChave	:= ""
 
cQuery += " SELECT "

For nX := 1 to Len(aStructTab)
	cQuery += " "+aStructTab[nX][1]+"  ,"
Next nX

cQuery := Left(cQuery,Len(cQuery)-1)
cQuery +=" FROM " + cFWTMP + " "
cQuery +=" WHERE " + cCpoFlag + " = '"+cMarca+"' "

If !Empty(cChave) 
	cQuery += " ORDER BY " + SqlOrder(cChave)
EndIf
 
cQuery := ChangeQuery(cQuery)

CTBConout('['+PROCNAME()+']:[Criação de tabela temporária: ['+cQuery+']')

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTabJob, .F., .T.)

CTBTCSetField(aStructTab, cTabJob)

IF !(cTabJob)->(EOF())
	(cTabJob)->(dbGotop())
ENDIF

If !EMPTY(cArqSem)
	PutGlbValue(cArqSem,stThrTbltmp)
EndIf

Return cTabJob

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FINUnLock ³ Autor ³Controladoria          ³ Data ³ 15/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Encerra a trava                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FINUnLock(nHandle,lOk)
DEFAULT nHandle := -1
DEFAULT lOk := .T.

IF nHandle >= 0
	FWRITE(nHandle,IF(lOk,MSG_OK,MSG_ERRO))
	FCLOSE(nHandle)
ENDIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FINLock   |Autor  ³Alvaro Camillo Neto    | Data ³ 15/04/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria arquivo para travar processos e garantir que sao unicos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FINLock(cFile)
Local nHJob := -1
If File(cFile)
	nHJob := FOPEN(cFile,2)
Else
	nHJob := MSFCREATE(cFile)
EndIf
Return nHJob

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBPrepFINºAutor  ³Alvaro Camillo Neto º Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Prepara as informacoes para o processamento multithread     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBPrepFIN(nNumProc,cTabTemp,nTotalReg,cCpoFlag,cRaizNome,cCpoCond)
	Local aProcs 		:= NIL
	Local nX		 	:= 0
	Local cDirSem  		:= "\Semaforo\"
	Local cNomeArq		:= ""
	Local cMarca  		:= ""
	Local nRegAProc		:= 0 // Registros a processar
	Local nRegJProc		:= 0 // Total de registros já processados
	Local cVarStatus	:= ""
	Local nMxRcTHR		:= GETNEWPAR("MV_MXRCTHR",200)	// Nº mínimo de registros por thhread

	Default cCpoCond := ""

	//Cria a pasta do semaforo caso não exista
	If !ExistDir(cDirSem)
		MontaDir(cDirSem)
	EndIf

	//Realizar calculo da quantidade de registros por thread.
	While nNumProc > 1
		IF (nTotalReg / nNumProc) >= nMxRcTHR
			EXIT
		ENDIF
		nNumProc := nNumProc - 1
	EndDo

	aProcs := Array(nNumProc)

	For nX := 1 to Len(aProcs)
		cNomeArq 	:= cDirSem + cRaizNome + cEmpAnt + cFilAnt +'_'+ cValtoChar(ThreadID()) +'_'+ cValtoChar(nX) + '.lck'
		cNomeArq 	:= STRTRAN(cNomeArq,' ','_')
		cMarca		:= GETNEXTALIAS()
		nRegAProc	:= IIf( nX == Len(aProcs), nTotalReg-nRegJProc, Int(nTotalReg / nNumProc) )
		nRegJProc	+= nRegAProc
		cVarStatus  :="cFINP"+cEmpAnt+cFilAnt+StrZero(nX,2)+cMarca
		cVarStatus  := STRTRAN(cVarStatus,' ','_')
		aProcs[nX]	:= {cNomeArq ,cMarca,nRegAProc,cVarStatus }
		PutGlbValue(cVarStatus,stThrReady)
	Next nX

	//Realiza o Update dos campos de flag setando quais registros
	//cada thread irá processar.
	FINFlag(cTabTemp,aProcs,cCpoFlag,cCpoCond)

Return aProcs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINFlag   ºAutor  ³ALvaro Camillo Neto º Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza o Update dos campos de flag setando quais registros º±±
±±º          ³cada thread irá processar.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FINFlag(cTabMult,aProcs,cCpoFlag,cCpoCond)
Local nX		:= 1
Local cChave	:= ""
Local cCompar	:= ""
Local nQuant	:= 0
Local lOK		:= .T.
Local cNumCMP	:= ''
Local cRecnoI	:= ''
Local cRecnoF	:= ''
Local cLista	:= ''

// Campos que serão utilizados para definir a condição de divisão dos registros
// Enquanto a expressão estiver na tabela esse conjunto ficara com a mesma marca.
Default cCpoCond := ''

IF !EMPTY(Len(aProcs))
	
	(cTabMult)->(dbGoTop())

	// Utilizado aninhamento de WHILE em substituição ao aninhamento FOR/WHILE pois 
	// o comando EXIT no nivel mais interno fazia sair dos dois niveis de uma vez.
	While (cTabMult)->(!EOF())
			
		nQuant := 0

		lOK := !Empty(cCpoCond)	// Habilita a avaliação de relacionamento registro a registro
		WHILE lOK

			If !EMPTY((cTabMult)->&(cCpoFlag)) .AND. ((cTabMult)->&(cCpoFlag) <> aProcs[nX][MARCA])
				(cTabMult)->(dbSkip())
				LOOP
			EndIf
		
			nQuant++	// Controle da quantidade de registros para cada Thread
			If _MSSQL7 .AND. nQuant == 1 
				cRecnoI := CVALTOCHAR((cTabMult)->(RECNO()))
			EndIf
			
			// Campo para avaliação de grupo de registros.
			If !Empty(cCpoCond)
				cCompar := ALLTRIM((cTabMult)->&(cCpoCond))
				
				// Tratamento para as transferências bancárias onde o sistema relaciona 
				// a saida no campo E5_NUMCHEQ e a entrada no campo E5_DOCUMEN
				IF (cCpoCond == 'E5_DOCUMEN') .AND. EMPTY(cCompar)
					cCompar := ALLTRIM((cTabMult)->E5_NUMCHEQ)
				ENDIF
				
				// Tratamento para as transações de Compensação
				IF (cCpoCond == 'E5_DOCUMEN') .And. E5_MOTBX == 'CMP'
					cNumCMP := (cTabMult)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
				ENDIF
			EndIf
			
			// cCpoCond tem como objetivo não separar registros de um mesmo processo (Ex.: Borderos, Compensação, etc.).
			// Portanto este criterio pode implicar um numero maior de registros marcados do que o informado em aProcs.
			If (nQuant <= aProcs[nX][QTD_REGISTROS]) .OR.;
			   (!Empty( cCpoCond ) .AND. (cChave == ALLTRIM( cCompar ) .OR. cChave == cNumCMP))
				
				If !_MSSQL7
					If EMPTY(cLista)
						cLista := '(' + ALLTRIM(STR((cTabMult)->(RECNO())))
					Else
						cLista += ',' + ALLTRIM(STR((cTabMult)->(RECNO())))
					EndIf
					
					If Len(cLista) >= 999
						cLista += ')'
						cUpdate := "UPDATE " + cTabMult + " SET " + cCpoFlag + " = '" + aProcs[nX][MARCA] + "' WHERE R_E_C_N_O_ IN " + cLista
						
						If TcSqlExec(cUpdate) < 0 
							CTBConout( PROCNAME()+"[ERRO AO ATUALIZAR]:[" + TcSQLError() + ']' )
						EndIf
						
						cLista := "" 
					Endif 
				ELSE	
					cRecnoF := CVALTOCHAR((cTabMult)->(RECNO()))
				ENDIF
			Else
				lOK := .F.
			EndIf
			
			If !Empty(cCpoCond)
				cChave := ALLTRIM((cTabMult)->&(cCpoCond))
				
				// Tratamento para as transferências bancárias onde o sistema relaciona 
				// a saida no campo E5_NUMCHEQ e a entrada no campo E5_DOCUMEN
				IF (cCpoCond == 'E5_DOCUMEN') .AND. EMPTY(cChave)
					cChave := (cTabMult)->E5_NUMCHEQ
				EndIf
			EndIf

			IF lOK			
				(cTabMult)->(dbSkip())
				IF (cTabMult)->(EOF())
					EXIT
				ENDIF
			ENDIF
		EndDo

		IF Empty(cCpoCond)
			IF _cSGBD == 'POSTGRES'
				cUpdate := "UPDATE " + _oCTBAFIN:GETREALNAME() + " SET " + cCpoFlag + " = '" + aProcs[nX][MARCA] + "' "
				cUpdate += "WHERE R_E_C_N_O_ IN "
				cUpdate += "(SELECT R_E_C_N_O_ FROM " + _oCTBAFIN:GETREALNAME() + " "
				cUpdate += "WHERE " + cCpoFlag + " = ' ' LIMIT " + ALLTRIM(STR(aProcs[nX][QTD_REGISTROS])) + ") "
			ELSEIF _cSGBD == 'ORACLE'
				cUpdate := "UPDATE " + _oCTBAFIN:GETREALNAME() + " SET " + cCpoFlag + " = '" + aProcs[nX][MARCA] + "' "
				cUpdate += "WHERE " + cCpoFlag + " = ' ' AND ROWNUM < " + ALLTRIM(STR(aProcs[nX][QTD_REGISTROS] + 1))
			ELSEIF _cSGBD $ "MSSQL7"
				cUpdate := "UPDATE TOP (" + ALLTRIM(STR(aProcs[nX][QTD_REGISTROS])) + ") " + _oCTBAFIN:GETREALNAME() + " "
				cUpdate += "SET " + cCpoFlag + " = '" + aProcs[nX][MARCA] + "' WHERE " + cCpoFlag + " = '' "
			ENDIF
		ELSEIF !_MSSQL7 .AND. !Empty(cLista)
			cLista += ')'
			cUpdate := "UPDATE " + cTabMult + " SET " + cCpoFlag + " = '" + aProcs[nX][MARCA] + "' "
			cUpdate += "WHERE R_E_C_N_O_ IN " + cLista
		ELSEIF _MSSQL7 .AND. !Empty(cRecnoI+cRecnoF)
			cUpdate := "UPDATE " + _oCTBAFIN:GETREALNAME() + " SET " + cCpoFlag + " = '" + aProcs[nX][MARCA] + "' " 
			cUpdate += "WHERE R_E_C_N_O_ BETWEEN '"+cRecnoI+"' AND '"+cRecnoF+"' "
		ENDIF

		CTBConout('['+PROCNAME()+']:FILIAL:['+cFilAnt+']:['+DTOS(DATE())+']:['+TIME()+']:QUERIE THREAD:['+cUpdate+']')

		If TcSqlExec(cUpdate) < 0 
			CTBConout( PROCNAME()+"[ERRO AO ATUALIZAR]:[" + TcSQLError() + ']' )
		EndIf	

		cLista := "" 
		
		IF (nX < Len(aProcs))
			nX++
		ELSE
			EXIT
		ENDIF

	EndDo

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINNextAliasºAutor  ³Alvaro Camillo Neto º Data ³  15/04/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Proteção para retornar o próximo alias disponivel no Banco  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION FINNextAlias(cNextAlias AS CHARACTER) AS CHARACTER
//- o nome gerado com a GetNextAlias já retorno como tamanho de 10 posições
//- não acrescente nenhuma string, pois teremos erros com o Oracle 
cNextAlias := "CTBA"+RIGHT(GetNextAlias(),6)
AADD(__aFinAlias,cNextAlias)
CTBConout('['+PROCNAME()+'] ALIAS Validado: [' + cNextAlias + ']')
RETURN cNextAlias

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbValMultºAutor  ³Alvaro Camillo Neto º Data ³  05/19/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o processamento será feito MultiThread           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbValMult(lMostraHelp,lAglutina,lMostraLanc,nTipo)
Local lRet 		:= .T.
Local nHelp		:= 1
Default lMostraHelp := .F.
Default nTipo 		:= 1
Default lMostraLanc := .F.

If lMostraHelp .And. !__lSchedule
	nHelp := 1
Else
	nHelp := 0
EndIf


If lRet .And. nTipo != 2
	If lMostraHelp .And. !__lSchedule
		lRet := MsgYesNo(STR0048,STR0049)//"O processamento Multithread está disponivel apenas para processamento por documento, o processamento será feito sem multithread. Concorda com operação?"##"Atenção"
	Else
		lRet := .F.
	EndIf
EndIf

If lRet .And. lAglutina
	If lMostraHelp .And. !__lSchedule
		lRet := MsgYesNo(STR0050,STR0049)//"O processamento Multithread está disponivel apenas para processamento sem aglutinação, o processamento será feito sem multithread. Concorda com operação?" ##"Atenção"
	Else
		lRet := .F.
	EndIf
EndIf

If lRet
	If FindFunction("CTBINTRAN")
		lCtbInTran := CTBINTRAN(nHelp,lMostraLanc)
	Else
		lCtbInTran := .F.
	EndIf
	
	If !lCtbInTran
		If lMostraHelp .And. !_lBlind
			lRet := MsgYesNo(STR0051,STR0049)//"O processamento será feito sem multithread. Concorda com operação?" ##"Atenção"
		Else
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JOBFINEnd ºAutor  ³Microsiga           º Data ³  06/21/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Finaliza a Thread verificando se ocorrer help (erro)      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function JOBFINEnd(cVarStatus,nHandle,lRet)
Local nX	:= 0
Local aLog  := {}
Local cMsg	:= ""

aLog  := GETAUTOGRLOG()

If !Empty(aLog)
	For nX := 1 to Len(aLog)
		cMsg := aLog[nX] 	
	Next
	CTBConout(PROCNAME() + "[Error]:[" + cMsg + ']',.T.)
	PutGlbValue(cVarStatus,stThrError)
Else
	PutGlbValue(cVarStatus,stThrFinish)
	FINUnLock(nHandle,lRet)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FinIniVar ºAutor  ³Microsiga           º Data ³  06/21/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicializa as variaveis staticas da contabilização         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinIniVar()

If TYPE("cCarteira") == 'U' .or. cCarteira == Nil
	cCarteira	:= SuperGetMv("MV_CARTEIR")
EndIf

If TYPE("cCtBaixa") == 'U' .or. cCtBaixa == Nil
	cCtBaixa	:= SuperGetMv("MV_CTBAIXA")
EndIf

If TYPE("lUsaFlag") == 'U' .or. lUsaFlag == Nil
	lUsaFlag	:= GetNewPar("MV_CTBFLAG",.F.)
EndIf

If TYPE("lPCCBaixa") == 'U' .or. lPCCBaixa == Nil 
	lPCCBaixa	:= SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ;
						!Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
						!Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
						!Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )
EndIf

If __lHasLoja == Nil
	dbSelectArea('SL1')
	__lHasLoja:=!Eof()
EndIf

IF EMPTY(__lMetric)
    __lMetric  := FwLibVersion() >= "20210517"
    __cFunBkp   := FunName()
    __cFunMet	:= Iif(AllTrim(__cFunBkp)=='RPC',"RPCCTBAFIN",__cFunBkp)
ENDIF

If lPosE1MsFil == Nil
	lPosE1MsFil	:= !Empty( SE1->( FieldPos( "E1_MSFIL" ) ) )
EndIf

If lPosE2MsFil == Nil
	lPosE2MsFil	:= !Empty( SE2->( FieldPos( "E2_MSFIL" ) ) )
EndIf

If lPosE5MsFil == Nil
	lPosE5MsFil	:= !Empty( SE5->( FieldPos( "E5_MSFIL" ) ) )
EndIf

If lPosEfMsFil == Nil
	lPosEfMsFil	:= !Empty( SEF->( FieldPos( "EF_MSFIL" ) ) )
EndIf

If lPosEuMsFil == Nil
	lPosEuMsFil	:= !Empty( SEU->( FieldPos( "EU_MSFIL" ) ) )
EndIf

If lSeqCorr == Nil
	lSeqCorr	:= FindFunction( "UsaSeqCor" ) .And. UsaSeqCor()
EndIf

If lUsaFilOri == Nil
	lUsaFilOri	:= SuperGetMv("MV_CTMSFIL",.F.,.F.)
EndIf		

_oPergunte := FwSx1Util():New()
_oPergunte:AddGroup("FIN370")
_oPergunte:SearchGroup()
IF LEN(_oPergunte:GetGroup("FIN370")) > 1 .AND. !Empty(_oPergunte:GetGroup("FIN370")[2])
	_lMvPar18 := LEN(_oPergunte:GetGroup("FIN370")[2]) >= 18
ENDIF
FWFReeObj(_oPergunte)
__dDataBas := dDataBase
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} FCTBA677()
Gera Lançamento contabil off line pela Prestação de Contas.

@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.6
/*/

Function FCTBA677(lCabecalho,nHdlPrv,cArquivo,lUsaFlag,aFlagCTB,cLoteCtb,nTotal,cAliasFLF,lMultThr,dIniProc,dFinProc)
Local lRet			:= .T.
Local lPadraoItem	:= .F.
Local lPadraoCabec	:= .F.
Local cPadraoItem	:= "8B3"		/* prestacao por item */
Local cPadraoCabec	:= "8B5"		/* prestacao por cabecalho */
Local aGetArea  	:= GetArea()
Local nTotDoc		:= 0
Local nValLanc		:= 0
Local nPosReg		:= 0
Local cQuery		:= ""
Local cAliasFL		:= ""
Local cFilFLE		:= ""
Local lMsFil		:= .F.
Local aTabRecOri	:= {'',0}	// aTabRecOri[1]-> Tabela Origem ; aTabRecOri[2]-> RecNo
Local lFlfLa	    := .F.
Local aCT5          := {}
LOCAL cKeyTit	    := ""

Default lCabecalho	:= .F.
Default nHdlPrv		:= 0
Default nTotal		:= 0
Default cArquivo	:= ""
Default lUsaFlag	:= SuperGetMV("MV_CTBFLAG",.T.,.F.)
Default aFlagCTB 	:= {}
Default cLoteCTB   	:= LoteCont("FIN")
Default cAliasFLF	:= ""
Default lMultThr	:= .F.
Default dIniProc	:= MV_PAR04
Default dFinProc	:= MV_PAR05

lMsFil := (FLF->(ColumnPos("FLF_MSFIL")) > 0)
lFlfLa := (FLF->(ColumnPos('FLF_LA')) > 0) 
cLote  := If(cLote=NIL,Space(TamSX3("CT2_LOTE")[1]),cLote) 

lPadraoItem  := VerPadrao(cPadraoItem)                                               
lPadraoCabec := VerPadrao(cPadraoCabec)                                               

FLE->(DbSetOrder(1))
FO7->(DbSetOrder(2))

If !lCabecalho
	a370Cabecalho(@nHdlPrv,@cArquivo)
Endif
		
If lPadraoItem .Or. lPadraoCabec
	If lMultThr .And. Select(cAliasFLF) > 0
	 	cAliasFL := cAliasFLF
	Else
		CtbGrvViag(.F., @cQuery, Nil, dIniProc, dFinProc)
		cAliasFL := FINNextAlias()
		DbUseArea(.T., "TOPCONN", TCGenQry(Nil, Nil, cQuery), cAliasFL, .F., .T.)
	Endif
	
	While !(cAliasFL)->(Eof())
		FLF->(DbGoTo((cAliasFL)->REGFLF))
		
		If !(MV_PAR12 == MVP12PERIODO) .And. nHdlPrv == 0
			a370Cabecalho(@nHdlPrv,@cArquivo)
		Endif
		
		If FLF->FLF_STATUS $ "7|8"
			If (lCtbPFO7 .Or. (cAliasFL)->REGFO7 > 0)
				If lCtbPFO7
					Execblock("CtbPFO7",.F.,.F.)
				Else
					FO7->(DbGoto((cAliasFL)->REGFO7))
				Endif
				
				If MV_PAR03 == MVP03EMISSAO 
					If FO7->FO7_RECPAG == "R"
						cKeyTit := FO7->(FO7_CLIFOR+FO7_LOJA+FO7_PREFIX+FO7_TITULO+FO7_PARCEL+FO7_TIPO)
						dbSelectArea("SE1")
						SE1->(Dbsetorder(2))	// E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
							
						If SE1->(MsSeek(xFilial("SE1",FO7->FO7_FILIAL)+cKeyTit))
							If SE1->E1_EMISSAO >= dIniProc .AND. SE1->E1_EMISSAO <= dFinProc
								dDataBase := SE1->E1_EMISSAO
							EndIf
						EndIf
					Else
						cKeyTit := FO7->(FO7_PREFIX+FO7_TITULO+FO7_PARCEL+FO7_TIPO+FO7_CLIFOR+FO7_LOJA)
						DBSelectArea("SE2")
						SE2->(dbSetOrder(1))	// E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
							
						If SE2->(MsSeek(xFilial("SE2",FO7->FO7_FILIAL)+cKeyTit))
							If SE2->E2_EMISSAO >= dIniProc .AND. SE2->E2_EMISSAO <= dFinProc
								dDataBase := SE2->E2_EMISSAO
							EndIf
						EndIf	
					EndIf
				Endif
			EndIf
		Else
			DBSelectArea("FLN")
			FLN->(DbSetOrder(1))//FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC+FLN_SEQ+FLN_TPAPR
			
			If MSSEEK(xFilial("FLN", FLF->FLF_FILIAL)+FLF->FLF_TIPO+ FLF->FLF_PRESTA+ FLF->FLF_PARTIC)
				While FLN->(!Eof()) .And. xFilial("FLN", FLF->FLF_FILIAL)+FLF->FLF_TIPO+ FLF->FLF_PRESTA+ FLF->FLF_PARTIC == FLN->(FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC)
					If FLN->FLN_STATUS <> "2"
						FLN->(DbSkip())
					Else
						Exit
					EndIf		
				EndDo
			Endif

			IF FLN->FLN_DTAPRO >= dIniProc .AND. FLN->FLN_DTAPRO <= dFinProc
				dDataBase := FLN->FLN_DTAPRO
			ELSE
				(cAliasFL)->(DBSKIP())
			ENDIF
		EndIf
		
		If lPadraoCabec
			If (cAliasFL)->REGFO7 == 0
				If MV_PAR12 == MVP12DOCUMENTO .And. !Empty(FLF->FLF_DTFECH)
					dDataBase := FLF->FLF_DTFECH
				ElseIf MV_PAR12 != MVP12DOCUMENTO
					__dDataCtb := __dDataBas
				EndIf
			EndIf
			
			If lUsaFlag .and. lFlfLa
				aAdd(aFlagCTB,{"FLF_LA","S","FLF",FLF->(Recno()),0,0,0})
			EndIf
			
			aTabRecOri := {"FLF", FLF->(RECNO())}			
			nValLanc := DetProva(nHdlPrv,cPadraoCabec,"FINA370",cLoteCTB,,,,,,aCT5,,@aFlagCTB, aTabRecOri)
			nTotal += nValLanc
			nTotDoc += nValLanc
			
			If LanceiCtb // Vem do DetProva
				If !lUsaFlag .and. lFlfLa
					RecLock("FLF")
					FLF->FLF_LA := "S"
					MsUnlock( )
				EndIf
			ElseIf lUsaFlag
				If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == FLF->(Recno()) }))>0
					aFlagCTB := Adel(aFlagCTB,nPosReg)
					aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
				Endif
			EndIf
		Endif
		
		If lPadraoItem
			DbSelectArea("FLE")
			
			If MV_PAR14 == 1 .And. lMsFil
				cFilFLE := xFilial("FLE",FLF->FLF_MSFIL)
			Else
				cFilFLE := xFilial("FLE")
			Endif
			
			FLE->(DbSeek(cFilFLE + FLF->FLF_TIPO + FLF->FLF_PRESTA + FLF->FLF_PARTIC))
			
			While FLE->FLE_FILIAL == cFilFLE .And. FLE->FLE_TIPO == FLF->FLF_TIPO .And. FLE->FLE_PRESTA == FLF->FLF_PRESTA .And. FLE->FLE_PARTIC == FLF->FLF_PARTIC
				If FLE->FLE_LA != "S"
					If lUsaFlag
						aAdd(aFlagCTB,{"FLE_LA","S","FLE",FLE->(Recno()),0,0,0})
					EndIf
					
					aTabRecOri := { 'FLE', FLE->( RECNO() ) }
					nValLanc := DetProva(nHdlPrv,cPadraoItem,"FINA370",cLoteCTB,,,,,,aCT5,,@aFlagCTB, aTabRecOri)
					nTotal += nValLanc
					nTotDoc += nValLanc
					
					If LanceiCtb // Vem do DetProva
						If !lUsaFlag
							RecLock("FLE")
							FLE->FLE_LA := "S"
							MsUnlock( )
						EndIf
					ElseIf lUsaFlag
						If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == FLE->(Recno()) }))>0
							aFlagCTB := Adel(aFlagCTB,nPosReg)
							aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
						Endif
					EndIf
				Endif
				
				FLE->(DbSkip())
			Enddo
		Endif
		
		If MV_PAR12 == MVP12DOCUMENTO
			If nValLanc > 0
				Ca370Incl(cArquivo,@nHdlPrv,cLoteCtb,@aFlagCTB,,dDataBase)
			Endif
			LimpaArray(aFlagCTB)
		Endif
		
		DbSelectArea(cAliasFL)
		(cAliasFL)->(DbSkip())
	Enddo

	If MV_PAR12 == MVP12PROCESSO
		If nTotDoc > 0
			Ca370Incl(cArquivo, @nHdlPrv, cLoteCtb, @aFlagCTB, Nil, IIf(__dDataCtb == Nil, dDataBase, __dDataCtb))
			nTotDoc := 0
		Endif
		
		__dDataCtb := Nil
		LimpaArray(aFlagCTB)
	Endif

	If Select(cAliasFL)>0
		DbSelectArea(cAliasFL)
		DbCloseArea()
		MsErase(cAliasFL)
	Endif
Endif

RestArea(aGetArea)
aSize(aGetArea,0)
aGetArea := nil 
Return(lRet)

/*/{Protheus.doc} SchedDef
Uso - Execucao da rotina via Schedule.

Permite usar o botao Parametros da nova rotina de Schedule
para definir os parametros(SX1) que serao passados a rotina agendada.

@return  aParam
/*/
Static Function SchedDef(aEmp)
	Local aParam := {}

	aParam := {	"P"			,;	//Tipo R para relatorio P para processo
				"FIN370"	,;	//Nome do grupo de perguntas (SX1)
				Nil			,;	//cAlias (para Relatorio)
				Nil			,;	//aArray (para Relatorio)
				Nil			}	//Titulo (para Relatorio)

Return aParam

/*/{Protheus.doc} VldVerPad 
Valida a existencia de Lan‡amentos Padr?o. 
@author norbertom 
@since 13/09/2017 
@version 1.0 
@param aLstLP, array, Lista de Lan‡amentos Padr?o para validar na fun‡?o VerPadrao(). 
@return  lRet, logico, Verdadeiro se existir 1 ou mais Lps cadastrados e ativos, sen?o Falso. 
/*/ 
Function VldVerPad(aLstLP) 
Local lRet := .T. 
Local nI := 0 
DEFAULT aLstLP := {} 
	
	For nI := 1 To Len(aLstLP) 
		lRet := VerPadrao(aLstLP[nI]) 
		If lRet 
			Exit 
		EndIf 
	Next nI 

Return lRet

/*/{Protheus.doc} CTBClean

Limpa o objeto da temporarytable
 
@Author	Leonardo Castro
@since	08/02/2018
/*/
STATIC FUNCTION CTBClean()
	If !__oTabFLF == nil
		__oTabFLF:Delete()
		FreeObj(__oTabFLF)
		__oTabFLF := nil 
	EndIf 

	If  !__oTabSE5 == nil
		__oTabSE5:Delete()
		FreeObj(__oTabSE5)
		__oTabSE5:= nil 
	EndIf 

	If  !__oTabSEU == nil
		__oTabSEU:Delete()
		FreeObj(__oTabSEU)
		__oTabSEU:= nil 
	EndIf 

	If  !__oTabSEF  == nil
		__oTabSEF:Delete()
		FreeObj(__oTabSEF)
		__oTabSEF:= nil 
	EndIf 

	If  !__oTabSE2 == nil
		__oTabSE2:Delete()
		FreeObj(__oTabSE2)
		__oTabSE2:= nil 
	EndIf 

	If  !__oTabSE1 == nil
		__oTabSE1:Delete()
		FreeObj(__oTabSE1)
		__oTabSE1:= nil 
	EndIf 

	If  !__oTabFWI == nil
		__oTabFWI:Delete()
		FreeObj(__oTabFWI)
		__oTabFWI:= nil 
	EndIf 

	IF _oCTBAFIN <> Nil
		_oCTBAFIN:Delete()
		FREEOBJ(_oCTBAFIN)
		_oCTBAFIN := Nil
	ENDIF

RETURN NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBGrvFlag
Efetua validações para a gravação do Flags 
@author  Norberto M de Melo
@since   23/02/201
@version P12
/*/
//-------------------------------------------------------------------
STATIC FUNCTION CTBGrvFlag(aIdFlag as Array)
	/**Declaração */
	LOCAL nI		as Numeric
	LOCAL aAreas	as Array
	LOCAL cTab		as Character
	LOCAL aFKRec	as Array

	/**Inicialização */
	DEFAULT aIdFlag	:= {} 
	nI		:= 0
	aAreas	:= {}
	cTab	:= ''
	aFKRec	:= {}

	/**Implementação */
	AADD(aAreas, GETAREA())

	IF !SE5->(EOF())
		CTBAddFlag(aFKRec,IF(LEN(aIdFlag) >= 4,aIdFlag[4],''))

		If !lUsaFlag
			For nI := 1 To Len(aFKRec)
				(aFKRec[nI,3])->(dbGoTo(aFKRec[nI,4]))

				IF !(aFKRec[nI,3])->(EOF())
					Reclock(aFKRec[nI,3],.F.)
					&(aFKRec[nI,1]) := 'S'
					MsUnlock()
				EndIf
			Next nI
		EndIf
	ENDIF

	// restaura as areas utilizadas da última para a primeira - Sistema UEPS ou LIFO
	FOR nI := LEN(aAreas) TO 1 Step -1
		RestArea(aAreas[nI])
	NEXT nI
	aSize(aAreas,0)
	aAreas := nil 
	aSize(aFKRec,0)
	aFKRec := nil 

RETURN NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBAddFlag
Adiciona os recnos do relacionamento do registro SE5 atual e seus registros FKs
@author  Norberto M de Melo
@since   25/04/2021
@version 2.0
/*/
//-------------------------------------------------------------------
STATIC FUNCTION CTBAddFlag(aCTBFlags as Array, cIDPROC AS CHARACTER)
Local aBind := {}
Local cAlias := Alias()
DEFAULT aCTBFlags := {}
DEFAULT cIDPROC := ''

	IF ASCAN(aCTBFlags,{|E| E[3] == 'SE5' .AND. E[4] == SE5->(RECNO())}) == 0
		AAdd(aCTBFlags,{"E5_LA","S","SE5",SE5->(Recno()),0,0,0})
	ENDIF

	IF EMPTY(cIDPROC) .AND. !EMPTY(SE5->(E5_TABORI+E5_IDORIG))
		FKA->(DBSETORDER(03))	// FKA_FILIAL, FKA_TABORI, FKA_IDORIG
		FKA->(DBSEEK(xFilial("SE5")+SE5->(E5_TABORI+E5_IDORIG)))
		cIDPROC := FKA->FKA_IDPROC
	ENDIF

	IF !EMPTY(cIDPROC)
		If __cQryFlag == nil 
			__cQryFlag := "SELECT FKA_FILIAL, FKA_IDORIG, FKA_TABORI, "
			__cQryFlag += " CASE  FKA_TABORI  "
			__cQryFlag += " 	WHEN 'FK1' THEN (SELECT FK1.R_E_C_N_O_ FROM "
			__cQryFlag += RetSqlName("FK1")+" FK1 "
			__cQryFlag += " 							WHERE FK1.FK1_FILIAL = FKA.FKA_FILIAL "
			__cQryFlag += " 								AND FK1.FK1_IDFK1 = FKA.FKA_IDORIG " 
			__cQryFlag += " 								AND FK1.D_E_L_E_T_ = ? ) "
			__cQryFlag += " 	WHEN 'FK2' THEN (SELECT FK2.R_E_C_N_O_ FROM "
			__cQryFlag += RetSqlName("FK2")+" FK2 "
			__cQryFlag += " 							WHERE FK2.FK2_FILIAL = FKA.FKA_FILIAL "
			__cQryFlag += " 								AND FK2.FK2_IDFK2 = FKA.FKA_IDORIG  "
			__cQryFlag += " 								AND FK2.D_E_L_E_T_ = ? ) "
			__cQryFlag += " 	WHEN 'FK5' THEN (SELECT FK5.R_E_C_N_O_ FROM "
			__cQryFlag += RetSqlName("FK5")+" FK5 "
			__cQryFlag += " 							WHERE FK5.FK5_FILIAL = FKA.FKA_FILIAL"
			__cQryFlag += " 							AND FK5.FK5_IDMOV = FKA.FKA_IDORIG  "
			__cQryFlag += " 							AND FK5.D_E_L_E_T_ = ? ) "
			__cQryFlag += " 	ELSE
			__cQryFlag += " 	0
			__cQryFlag += " END RECNO
			__cQryFlag += " FROM "
			__cQryFlag += RetSqlName("FKA")+" FKA "
			__cQryFlag += " WHERE FKA_FILIAL = ? "
			__cQryFlag += " AND FKA_IDPROC   = ? "
			__cQryFlag += " AND FKA_TABORI  IN ('FK1','FK2','FK5')"
			__cQryFlag += " AND FKA.D_E_L_E_T_   = ? "
			__cQryFlag := ChangeQuery(__cQryFlag)
		EndIf 
		AADD(aBind,Space(1))
		AADD(aBind,Space(1))
		AADD(aBind,Space(1))
		AADD(aBind,xFilial("FKA"))
		AADD(aBind,cIdProc)
		AADD(aBind,Space(1))
		
		dbUseArea(.T.,"TOPCONN",TcGenQry2(,,__cQryFlag,aBind),'QFKAFLAG')

		WHILE !QFKAFLAG->(EOF()) 
			AADD(aCTBFlags,{QFKAFLAG->FKA_TABORI+"_LA","S",QFKAFLAG->FKA_TABORI,QFKAFLAG->RECNO,0,0,0})
			QFKAFLAG->(DBSKIP())
		ENDDO
		QFKAFLAG->(dbCloseArea())
	ENDIF
	aSize(aBind,0)
	aBind := nil 
	If !Empty(cAlias)
		dbSelectArea(cAlias)
	EndIf 
RETURN NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} FINNEWTBL
Criação de tabela Temporária
@author  Norberto M de Melo
@since   06/03/2018
@version 01
/*/
//-------------------------------------------------------------------
STATIC FUNCTION FINNEWTBL(cAlias as Character, aStruSQL as Array, cChave as Character) as Character
	/**Declaração */
	LOCAL cTab AS CHARACTER
	LOCAL aArea AS ARRAY
    LOCAL oFWTT AS OBJECT

	/**Inicialização */
	DEFAULT cAlias := ''
	DEFAULT aStruSQL := {}
	DEFAULT cChave := ''
	aArea := GetArea()
    cTab := ""

	/**Implementação */
    IF !EMPTY(cAlias) .AND. !EMPTY(aStruSQL)
    	cTab := FINNextAlias()

		dbSelectArea(cAlias)
		(cAlias)->(dbSetOrder(1))
		If EMPTY(cChave)
			cChave := (cAlias)->(INDEXKEY())
		EndIf

		oFWTT := FINBCCTblTmp():New(cTab)
		oFWTT:SetFields(aStruSQL)
		oFWTT:AddIndex('1',cChave)
		oFWTT:Create()

	ENDIF

	RestArea(aArea)
	aSize(aArea,0)
	aArea := nil 
RETURN oFWTT
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CTBCONSTSE5³ Autor ³ Vinicius Barreira	  ³ Data ³24/08/95³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de Aviso de Falha na consistˆncia do SE5			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBCONSTSE5() 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFIN													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBCONSTSE5(lMultiThr AS LOGICAL)
Local lRet		:= .F.
Local lUsaLog	:= SuperGetMv("MV_FINLOG",.T.,.F.)
Local cTexto	:= ""
Local cDate		:= DtoC(date())
Local cHour		:= substr(time(),1,5)
Local cPathLog	:= SuperGetMv("MV_DIRDOC")
Local cLogArq	:= "Fina370Log.TXT"
Local cCaminho	:= cPathLog + cLogArq
Local lCtbafin	:= FwIsInCallStack("CTBAFIN")

DEFAULT lMultiThr := .F.

If valtype("nTpLog") == "U"
	nTpLog := 1
EndIf

If !lMultiThr .AND. !IsBlind()
	If lUsaLog
		cTexto += "*** "+cDate+" "+cHour+"--> "+ STR0025 + "PREF. + NUM + PARC + TIP"+chr(13)+chr(10) // "Dados do título:"
		cTexto += SE5->E5_PREFIXO+"-"+SE5->E5_NUMERO+"-"+SE5->E5_PARCELA+"-"+SE5->E5_TIPO + chr(13)+chr(10)
		cTexto += STR0035 + ": " + ALLTRIM(STR(SE5->(RECNO()))) +chr(13)+chr(10)    //"Registro SE5 ->"
		cTexto += "*** ---------------------- ***"

		If lCtbafin .Or. nTpLog == 1  
			FinLog( cCaminho, cTexto ) 
		ElseIf nTpLog == 2
			aAdd(aIncons, cTexto )
		EndIf

		lGerouTxt := .T.
		lRet := .T.

	Else
		lRet := MsgYesNo (STR0020+chr(13)+chr(10)+;
							chr(13)+chr(10)+ STR0024 + Iif(SE5->E5_RECPAG=="R",STR0014,STR0013)+;
							chr(13)+chr(10)+ STR0025 + SE5->E5_PREFIXO+"-"+SE5->E5_NUMERO+"-"+SE5->E5_PARCELA+"-"+SE5->E5_TIPO +;
							 chr(13)+chr(10)+ STR0035 + STR(SE5->(RECNO())),cCadastro)
	EndIf

Else 
	If lUsaLog
		cTexto += "*** "+cDate+" "+cHour+"--> "+ STR0025 + "PREF. + NUM + PARC + TIP"+chr(13)+chr(10) // "Dados do título:"
		cTexto += SE5->E5_PREFIXO+"-"+SE5->E5_NUMERO+"-"+SE5->E5_PARCELA+"-"+SE5->E5_TIPO + chr(13)+chr(10)
		cTexto += STR0035 + ": " + ALLTRIM(STR(SE5->(RECNO()))) +chr(13)+chr(10)    //"Registro SE5 ->"
		cTexto += "*** ---------------------- ***"

		If lCtbafin .Or. nTpLog == 1  
			FinLog( cCaminho, cTexto ) 
		ElseIf nTpLog == 2
			aAdd(aIncons, cTexto )
		EndIf
		
		lGerouTxt := .T.
		lRet := .T.
	EndIf
EndIf
Return lRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} VldDtE5()
Condicional While para validação se o a data do Movimento Bancario 
está no range selecionado. 

@Param cAliasSe5 	Alias da tabela temporaria SE5
@Param cCampo 		Data Utilizada "E5_DATA","E5_DTDIGIT" ou "E5_DTDISPO"
@Param dPar05 		Pergunte F12 = ( mv_par05 - Data Fim)	
@Param dPar04		Data Inicial 
@Param cTipoMov     Determina se o processo está contabilizando Movimentos bancários ou Baixas

@author Luiz Henrique
@since 22/01/2020
@version 12.1.27
/*/
//---------------------------------------------------------------------------
Static Function VldDtE5(cAliasSe5,cCampo,dPar05,dPar04,cTipoMov)

	Local lRet 			:= .F.

	Default cAliasSe5 	:= "" 
	Default cCampo	  	:= ""
	Default dPar05		:= dDataBase
	Default dPar04	:= dDataBase

	If !Empty(cAliasSe5) .AND. (cAliasSE5)->(!Eof()) 
		If (cAliasSE5)->E5_TIPODOC $ 'TR#TE' .OR. Empty((cAliasSE5)->(E5_TIPODOC+E5_TIPO)) 		
			If(cAliasSE5)->E5_DATA >= dPar04 .AND. (cAliasSE5)->E5_DATA <= dPar05
				lRet := .T.
			ElseIf (cAliasSE5)->(&cCampo) <= dPar05			
				lRet := .T.
			EndIf
		ElseIf (cAliasSE5)->(&cCampo) <= dPar05
			lRet := .T.
		EndIf
	EndIf
	If !lRet .AND. cTipoMov == 'DIRETO'
		lRet := .T.
		cTipoMov := 'TITULOS'
		(cAliasSE5)->(DBGOTOP())
	EndIf

Return lRet

/*/{Protheus.doc} CtbMSitCob()
Divide os registros selecionados de Transferencia de situação de cobrança 
multi-processamento (multi-threads).

@author Fernando Navarro 
@since 24/06/2020
@version 12.1.30

@param nNumProc, número de processos
/*/
Static Function CtbMSitCob(nNumProc As Numeric) As Logical 

    Local aArea 		As Array
    Local aStruSQL		As Array
    Local aProcs 		As Array

    Local cChave		As Character
    Local cPerg 		As Character
    Local cRaizNome		As Character
    Local cTabJob		As Character
    Local cTabMult		As Character

    Local lRet			As Logical

    Local nTotalReg		As Numeric
    Local nX			As Numeric 

    aArea       := GetArea()
    lRet        := .T.
    nX          := 0
    aProcs      := {}
    cTabMult    := ""// Tabela fisica para o processamento multi thread
    nTotalReg   := 0
    cRaizNome   := 'CTBFINPROC'
    aStruSQL    := {}
    cTabJob     := "TRBFWI"
    cPerg       := "FIN370"
    cChave      := "FWI_FILIAL+DTOS(FWI_DTMOVI)+FWI_LANPAD+FWI_NUMBOR+FWI_SEQ"

	LoadPergunte()
    
    //Monta o arquivo de trabalho
    cTabMult := CtbGrvSitC(@nTotalReg)
    
    If nTotalReg > 0
        
        aStruSQL := (cTabMult)->( DbStruct() )
        aProcs := CTBPrepFIN(@nNumProc,cTabMult,nTotalReg,"CTBFLAG",cRaizNome,cChave)
        
		CTBConout('['+PROCNAME()+']:['+cFilAnt+']:['+DTOS(DATE())+']:['+TIME()+']-QTDE:['+ALLTRIM(STR(nTotalReg))+']')
        If  nTotalReg >= nNumProc .And. ((nNumProc > 1) .OR. __lAutoMThrd) // MultiThread
            
            //Inicializa as Threads Transação controlada nas Threads
            For nX := 1 to Len(aProcs)
                StartJob("JOBCTBSITC", GetEnvServer(), .F., cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],"CTBFLAG",cTabMult,aStruSQL,cTabJob,aProcs[nX][VAR_STATUS],cChave,__cUserId,cUserName,cAcesso,cUsuario,_oCTBAFIN:GETREALNAME())
                CTBSleep(1500)
            Next nX
            
            //NAO RETIRAR A INSTRUCAO DO SLEEP
            //Esperar 05 segundos antes de monitorar para dar tempo das threads criar arquivo de semaforo
            CTBSleep(5000)
            //Realiza o controle das Threads
            lRet := FINMonitor(aProcs,4)
        ElseIf nNumProc == 1
            cTabJob	 := SelFINJob(NIL,cTabMult,aStruSQL,"CTBFLAG",aProcs[nNumProc][MARCA],cTabJob,cChave,_oCTBAFIN:GETREALNAME())
            lRet := FCTBSITCOB(,,,,cTabJob,.T.)
            If Select(cTabJob) > 0
                (cTabJob)->(dbCloseArea())
            EndIf
        EndIf
    EndIf
    
    If Select(cTabMult) > 0
        (cTabMult)->( dbCloseArea() )
    Endif

    MsErase(cTabMult)
    RestArea(aArea)
	aSize(aArea,0)
	aArea := nil 

Return(lRet)


/*/{Protheus.doc} CtbGrvSitC()
Monta temporário para processamento tanto multi-threado como individual com os registros de Transferencia de situação de cobrança para. 
Parametro são utilizados apenas no processamento multi-thread. 

@author Fernando Navarro 
@since 24/06/2020
@version 12.1.30

@param nTotalReg, Numero de registros a serem processados pelo processo multithread 
@param cChave,    Chave do indice que será criado na tabela temporaria / também será usado para segregrar os registro no processo multithread. 
/*/
Static Function CtbGrvSitC(nTotalReg As Numeric, _dIni As Date, _dFim As Date) As String 

    Local aStruFWI  As Array 
    Local aStruSE1  As Array 
    Local aStruSQL  As Array 

    Local cCampos    As Character
    Local cCamposIns As Character
    Local cChave     As Character 
    Local cInsert    As Character
    Local cQuery     As Character
    Local cTabela    As Character
    Local cUpdate    As Character

    Default nTotalReg	:= 0 
	Default _dIni 		:= mv_par04
	Default _dFim		:= mv_par05	

    cChave     := "FWI_FILIAL+FWI_DTMOVI+FWI_LANPAD+FWI_NUMBOR+FWI_SEQ+FWI_PREFIX+FWI_NUMERO+FWI_PARCEL+FWI_TIPO+FWI_CLIENT+FWI_LOJA"

    aStruSE1 := SE1->(DbStruct())
    aStruFWI := FWI->(DbStruct())
    aStruSQL := {}
    cCampos  := ""

    aEval(aStruFWI,{|Campos| AAdd(aStruSQL, Campos)})
    //aEval(aStruSE1,{|Campos| AAdd(aStruSQL, Campos)})

    aEval(aStruSQL,{|Campos,i| cCampos += IF(i==1,'',',')+AllTrim(Campos[1])})

    AAdd(aStruSQL,{"SE1RECNO"    ,"N",15,00})
    AAdd(aStruSQL,{"FWIRECNO"    ,"N",15,00})
    AADD(aStruSQL,{"CTBFLAG"     ,"C",LEN(&_cSpaceMark),00})
    AADD(aStruSQL,{"SUMABATRE"   ,"C",01,00})

    cCamposIns := cCampos
    cCamposIns += ",SE1RECNO " 
    cCamposIns += ",FWIRECNO " 
    cCamposIns += ",CTBFLAG " 
    cCamposIns += ",SUMABATRE " 

    If !_MSSQL7
        cCamposIns += ", R_E_C_N_O_"
    EndIf 

    // Cria tabela temporaria
	If FinZap_Tmp(__oTabFWI)
		__oTabFWI := FINNEWTBL('FWI',aStruSQL,cChave) 
	EndIF 
	_oCTBAFIN:= __oTabFWI
	cTabela  := __oTabFWI:cAlias

    cQuery := "SELECT " + cCampos 
    cQuery += ",SE1.R_E_C_N_O_ AS SE1RECNO "
    cQuery += ",FWI.R_E_C_N_O_ AS FWIRECNO "
    cQuery += "," + _cSpaceMark + " AS CTBFLAG " 
    cQuery += ", 'N' AS SUMABATRE "
    If !_MSSQL7
        cQuery += ", FWI.R_E_C_N_O_"
    EndIf 

    cQuery += " FROM " + RetSqlName("FWI") + " FWI "
    cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
    cQuery += " ON E1_FILORIG = FWI_FILORI "
    cQuery += " AND E1_PREFIXO = FWI_PREFIX "
    cQuery += " AND E1_NUM = FWI_NUMERO "
    cQuery += " AND E1_PARCELA = FWI_PARCEL "
    cQuery += " AND E1_TIPO = FWI_TIPO "
    cQuery += " AND E1_CLIENTE = FWI_CLIENT "
    cQuery += " AND E1_LOJA = FWI_LOJA "
    cQuery += " AND SE1.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE  "
    If MV_PAR14 == 1
        cQuery += " FWI_FILORI = '" + cFilAnt + "' "
    Else 
        cQuery += " FWI_FILIAL = '" + FwXFilial("FWI") + "' "
    EndIf
    cQuery += " AND FWI_DTMOVI BETWEEN '"+DTOS(_dIni)+"' AND '"+DTOS(_dFim)+"'"
    // Avalia e buscas apenas os LPs Configurados
    cQuery += " AND EXISTS "
    cQuery += "(SELECT 'LPADRAO' FROM " + RetSqlName("CT5") + " CT5 "
    cQuery += " WHERE CT5_FILIAL = '" + FwXFilial("CT5") + "' "
    cQuery += " AND CT5_LANPAD = FWI_LANPAD "
    cQuery += " AND CT5_STATUS IN ( '1', ' ' ) "
    cQuery += " AND CT5.D_E_L_E_T_ = ' ' ) "
    cQuery += " AND FWI_LA <> 'S' "
    cQuery += " AND FWI.D_E_L_E_T_ = ' ' "
    If !Empty(cChave) 
       cQuery += " ORDER BY " + SqlOrder(cChave)
    EndIf

    cInsert := " INSERT "
    If _cSGBD == "ORACLE"
        cInsert += " /*+ APPEND */ "
    EndIf
    cInsert += " INTO " + __oTabFWI:GETREALNAME() + " ("+cCamposIns+") " + cQuery

    CTBConout('['+PROCNAME()+']:[Criação de tabela temporária: ['+cInsert+']')

    If TcSqlExec(cInsert) <> 0
		CTBConout( PROCNAME()+"[ERRO AO ATUALIZAR]:[" + TcSQLError() + ']' )
    EndIf

    // Identifica possíveis candidatos a terem abatimentos, afim de melhorar a performance.
    cUpdate := " UPDATE " + __oTabFWI:GETREALNAME() + " SET SUMABATRE = 'S' "
    cUpdate += " WHERE R_E_C_N_O_ > 0 "
    cUpdate += " AND EXISTS (SELECT 'TITPAI' FROM " + RetSqlName("SE1") + " SE1 "
    cUpdate += " WHERE E1_FILIAL = FWI_FILIAL AND E1_PREFIXO = FWI_PREFIX "
    cUpdate += " AND E1_NUM = FWI_NUMERO AND E1_PARCELA = FWI_PARCEL "
    cUpdate += " AND E1_TITPAI <> ' ' AND SE1.D_E_L_E_T_ = ' ' ) "

    CTBConout('['+PROCNAME()+']:[Criação de tabela temporária: ['+cUpDate+']')

    If TcSqlExec(cUpdate) <> 0
		CTBConout( PROCNAME()+"[ERRO AO ATUALIZAR]:[" + TcSQLError() + ']' )
    EndIf

    // Obtem a Contagem de Registros a processar.
    cQuery := "SELECT COUNT(1) NREGS "
    cQuery += "  FROM " + __oTabFWI:GETREALNAME() + " TAB "

    nTotalReg := MpSysExecScalar(cQuery, "NREGS")

    (cTabela)->(DbGotop())

Return cTabela

/*/{Protheus.doc} JobCtbSitC()
Executa o job para os registros de Transferencia de situação de cobrança.

@author Fernando Navarro 
@since 24/06/2020
@version 12.1.30
/*/
Function JobCtbSitC(cEmpX As Character, cFilX As Character, cMarca As Character, cFileLck As Character,;
                    cCpoFlag As Character, cTabMaster As Character,aStructTab As Array, cTabJob As Character,;
                    cVarStatus As Character, cChave As Character,cXUserId  As Character,;
                    cXUserName As Character, cXAcesso As Character, cXUsuario As Character, cFWTMP As Character)

    Local lRet      As Logical 
    Local nHandle   As Numeric

    Private lMsErroAuto 
    Private lMsHelpAuto 
    Private lAutoErrNoFile 

    //Abre o arquivo de Lock parao controle externo das threads
    nHandle := FINLock(cFileLck)

    // STATUS 1 - Iniciando execucao do Job
    PutGlbValue(cVarStatus,stThrStart)

    //Seta job para nao consumir licensas
    RpcSetType(3)
    RpcClearEnv()
    // Seta job para empresa filial desejada
    RpcSetEnv( cEmpX,cFilX,,,,,)

    // STATUS 2 - Conexao efetuada com sucesso
    PutGlbValue(cVarStatus,stThrConnect)

    //Set o usuário para buscar as perguntas do profile
    lMsErroAuto := .F.
    lMsHelpAuto := .T. 
    lAutoErrNoFile := .T.

    __cUserId := cXUserId 
    cUserName := cXUserName
    cAcesso   := cXAcesso
    cUsuario  := cXUsuario
	DEFAULT _cSGBD		:= Alltrim(Upper(TCGetDB()))
	DEFAULT _MSSQL7		:= _cSGBD $ "MSSQL7"
	DEFAULT _cOperador	:= If(_MSSQL7,"+","||")

    cTabJob	 := SelFINJob(cVarStatus,cTabMaster,aStructTab,cCpoFlag,cMarca,cTabJob,cChave,cFWTMP)

    // Realiza o processamento
    lRet := FCTBSITCOB(,,,,cTabJob,.T.)

    JOBFINEnd(cVarStatus,nHandle,lRet)

    If Select(cTabJob) > 0
        (cTabJob)->(dbCloseArea())
    EndIf

Return

/*/{Protheus.doc} FCTBSITCOB()
Gera Lançamento contabil off line Transferencia de situação de cobrança.

@author Fernando Navarro 
@since 24/06/2020
@version 12.1.30
/*/

Function FCTBSITCOB(nHdlPrv As Numeric, cArquivo As Character, aFlagCTB As Array,;
                    nTotal As Numeric, cAliasFWI As Character, lMultThr As Logical,;
					_dIni As Date, _dFim As Date) As Logical

    Local aCT5          As Array
    Local aGetArea      As Array
    Local aTabRecOri    As Array   // aTabRecOri[1]-> Tabela Origem ; aTabRecOri[2]-> RecNo

    Local cAlias        As Character
    Local cChaveBor     As Character
    Local cQuery        As Character

    Local nDescEst      As Numeric 
    Local nPosReg       As Numeric
    Local nTotAbat      As Numeric
    Local nTotDoc       As Numeric
    Local nValCred      As Numeric
    Local nValIof       As Numeric
    Local nValLanc      As Numeric

    Private oEstFKAFK5  As Object

    Default nHdlPrv		:= 0
    Default nTotal		:= 0
    Default cArquivo	:= ""
    Default aFlagCTB 	:= {}
    Default cAliasFWI	:= ""
    Default lMultThr	:= .F.
	Default _dIni 		:= mv_par04
	Default _dFim		:= mv_par05

    cLote       := If(cLote=NIL,LoteCont("FIN"),cLote)
    lCabecalho  := If(lCabecalho=NIL,.F.,lCabecalho)

	LoadPergunte()

    STRLCTPAD   := ""     // Disponibiliza a situacao anterior para ser utilizada no LP
    VALOR       := 0      // para contabilizar o total descontado (Private)
    IOF         := 0      // Valor da taxa IOF calculada
    VALOR2      := 0      // Saldo dos titulo para contabilizacao da diferenca
    ABATIMENTO	:= 0      // Valor do abatimento dos titulos no bordero 
    VAR_IXB     := ""     // Dados do banco anterior a transferencia 
    PIS         := 0      // Valores dos impostos para FINA061
    COFINS      := 0      // Valores dos impostos para FINA061
    CSLL        := 0      // Valores dos impostos para FINA061

    aCT5        := {}
    aGetArea    := GetArea()
    aTabRecOri  := {'',0}	// aTabRecOri[1]-> Tabela Origem ; aTabRecOri[2]-> RecNo
    cAlias      := ""
    cChaveBor   := ""
    cQuery      := ""
    nPosReg     := 0
    nTotAbat    := 0 
    nTotDoc     := 0
    nValCred    := 0 
    nValIof     := 0 
    nValLanc    := 0

    FWI->(DbSetOrder(1))

    If !lCabecalho
        a370Cabecalho(@nHdlPrv,@cArquivo)
    Endif
    
	If lMultThr .And. Select(cAliasFWI) > 0
        cAlias := cAliasFWI
    Else            
        cAlias := CtbGrvSitC(,_dIni,_dFim)
    Endif

	While !EMPTY(cAlias) .and. (cAlias)->(!Eof())
		PulseLife() //- Pulso de vida da conexão
        FWI->(MsGoTo((cAlias)->FWIRECNO))
        SE1->(MsGoTo((cAlias)->SE1RECNO))

        dDataBase := FWI->FWI_DTMOVI

        // Banco vazio, contabiliza anterior
        If !Empty(FWI->FWI_BANCO)
            SA6->(DbSetOrder(1))
            SA6->(MsSeek(FwxFilial("SA6",FWI->FWI_FILORI)+FWI->(FWI_BANCO+FWI_AGENCI+FWI_CONTA)))
        Else
            SA6->(DbSetOrder(1))
            SA6->(MsSeek(FwxFilial("SA6",FWI->FWI_FILORI)+FWI->(FWI_BCOANT+FWI_AGEANT+FWI_CONANT)))
        EndIf

        SEA->(DbSetOrder(4)) // EA_FILORIG+EA_NUMBOR+EA_CART+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA
        SEA->(MsSeek(FWI->(FWI_FILORI+FWI_NUMBOR+"R"+FWI_PREFIX+FWI_NUMERO+FWI_PARCEL+FWI_TIPO+FWI_CLIENT+FWI_LOJA)))

        If cChaveBor <> FWI->FWI_FILIAL+FWI->FWI_SEQ+FWI->FWI_NUMBOR+FWI->FWI_IDMOV
            cChaveBor := FWI->FWI_FILIAL+FWI->FWI_SEQ+FWI->FWI_NUMBOR+FWI->FWI_IDMOV
            nValCred := 0
            nValIof  := 0
            nTotAbat := 0
        EndIf 

        IF Empty(FWI->FWI_NUMBOR)
            cChaveBor := ""
            PIS         := 0
            COFINS      := 0
            CSLL        := 0
        Else
            nValCred += FWI->FWI_VALOR
            nTotAbat += IIF((cAlias)->SUMABATRE == 'S', SumAbatRec(FWI->FWI_PREFIX,FWI->FWI_NUMERO,FWI->FWI_PARCEL, SE1->E1_MOEDA,"S",FWI->FWI_DTMOVI) , 0) 
            If lPCCBaixa 
                PIS      := SE1->E1_PIS
                COFINS   := SE1->E1_COFINS
                CSLL     := SE1->E1_CSLL 
            EndIf 
        EndIf 

        If !lCabecalho 
            a370Cabecalho(@nHdlPrv,@cArquivo)
        Endif

        If lUsaFlag 
            aAdd(aFlagCTB,{"FWI_LA","S","FWI",FWI->(Recno()),0,0,0})
        EndIf

        aTabRecOri := { 'FWI', FWI->( RECNO() ) }

		//Posiciona a F71 na contabilização do PIX
		If FWI->FWI_LANPAD $ "54G|54H"
			If FieldPos("FWI_IDF71") > 0
				F71->(dbSetOrder(3)) //F71_IDTRAN
				F71->(dbSeek(FWI->FWI_IDF71))
			EndIf
		EndIf
		
        nValLanc := DetProva(nHdlPrv,FWI->FWI_LANPAD,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB, aTabRecOri)
        nTotal   += nValLanc
        nTotDoc  += nValLanc
        If LanceiCtb // Vem do DetProva
            If !lUsaFlag
                RecLock("FWI")
                FWI->FWI_LA := "S"
                MsUnlock( )
            EndIf
        ElseIf lUsaFlag
            If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == FWI->(Recno()) }))>0
                aFlagCTB := Adel(aFlagCTB,nPosReg)
                aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
            Endif
        EndIf

        If Empty(cChaveBor)
            // Movimento de tranferencia (Situacao cobranca - Descontada)
            If !Empty(FWI->FWI_IDMOV) 

                SE1->(DBGOTO(0))
                SE5->(DbSetOrder(21)) // E5_FILIAL+E5_IDORIG+E5_TIPODOC
                FK5->(DbSetOrder(1))  // FK5_FILIAL+FK5_IDMOV
                If SE5->(DbSeek(FWxFilial("SE5",FWI->FWI_FILORI)+FWI->FWI_IDMOV)) .And. ;
                    FK5->(DbSeek(FWxFilial("FK5",FWI->FWI_FILORI)+FWI->FWI_IDMOV))

                    STRLCTPAD   := FWI->FWI_SITUAC
                    VALOR       := FWI->FWI_VALOR
                    IOF         := FWI->FWI_IOF
                    VALOR2      := FWI->(FWI_VALOR+FWI_DESCON+FWI_IOF)
                    ABATIMENTO  := 0
                    VAR_IXB     := FWI->FWI_BCOANT

                    If lUsaFlag 
                        aAdd(aFlagCTB,{"E5_LA","S","SE5",SE5->(Recno()),0,0,0})
                        aAdd(aFlagCTB,{"FK5_LA","S","FK5",FK5->(Recno()),0,0,0})
                        aAdd(aFlagCTB,{"FWI_LA","S","FWI",FWI->(Recno()),0,0,0})
                    EndIf

                    nValLanc := DetProva(nHdlPrv,FWI->FWI_LANPAD,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB, aTabRecOri)
                    nTotal   += nValLanc
                    nTotDoc  += nValLanc

                    If LanceiCtb // Vem do DetProva
                        If !lUsaFlag
                            RecLock("SE5")
                            SE5->E5_LA := "S"
                            MsUnlock()

                            RecLock("FK5")
                            FK5->FK5_LA := 'S'
                            MsUnlock()

                            RecLock("FWI")
                            FWI->FWI_LA := 'S'
                            MsUnlock()
                        EndIf
                    ElseIf lUsaFlag
                        If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == SE5->(Recno()) }))>0
                            aFlagCTB := Adel(aFlagCTB,nPosReg)
                            aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
                        Endif
                    EndIf

                    // Zera as variaveis contábeis para o proximo lançamento.
                    STRLCTPAD   := ""
                    VALOR       := 0 
                    IOF         := 0 
                    VALOR2      := 0 
                    ABATIMENTO	:= 0 

                    SE5->(DBGOTO(0))
                    FKE->(DBGOTO(0))

                EndIf 
            EndIf
            If (MV_PAR12 == MVP12DOCUMENTO) 
                If nTotDoc > 0
                    Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataBase)
                Endif
                nTotDoc := 0
                LimpaArray(aFlagCTB)
            Endif
        Endif

        (cAlias)->(DbSkip())

        If !Empty(cChaveBor)
            //Movimento do bordero (Situacao cobranca - Descontada)
            If cChaveBor <> (cAlias)->(FWI_FILIAL+FWI_SEQ+FWI_NUMBOR+FWI_IDMOV)
				SE1->(DBGOTO(0))
                nDescEst := 0 
                If FWI->FWI_LANPAD == "554"
                    cEstFKAFK5 := EstFKAFK5(FWI->FWI_IDMOV)
                    FK6->(DbSetOrder(2)) // // FK6_FILIAL+FK6_IDMOV
                    If FK6->(DbSeek(FWxFilial("FK6",FWI->FWI_FILORI)+cEstFKAFK5))
                        nDescEst := FK6->FK6_VALMOV
                    EndIf 
                Else
                    cEstFKAFK5 := FWI->FWI_IDMOV
                    nDescEst   := FWI->FWI_DESCON
                EndIf

                SE5->(DbSetOrder(21)) // E5_FILIAL+E5_IDORIG+E5_TIPODOC
                FK5->(DbSetOrder(1))  // FK5_FILIAL+FK5_IDMOV
                If SE5->(MsSeek(FWxFilial("SE5",FWI->FWI_FILORI)+cEstFKAFK5)) .And. ;
                    FK5->(MsSeek(FWxFilial("FK5",FWI->FWI_FILORI)+cEstFKAFK5))

                    STRLCTPAD   := FWI->FWI_SITUAC
                    VALOR       := FK5->FK5_VALOR
                    IOF         := FWI->FWI_IOF
                    VALOR2      := nValCred
                    ABATIMENTO  := nTotAbat // Total dos abatimentos dos titulos. 
                    VAR_IXB     := FWI->FWI_BCOANT

                    If lUsaFlag 
                        aAdd(aFlagCTB,{"E5_LA","S","SE5",SE5->(Recno()),0,0,0})
                        aAdd(aFlagCTB,{"FK5_LA","S","FK5",FK5->(Recno()),0,0,0})
                    EndIf

                    nValLanc := DetProva(nHdlPrv,FWI->FWI_LANPAD,"FINA370",cLote,,,,,,aCT5,,@aFlagCTB, aTabRecOri)
                    nTotal   += nValLanc
                    nTotDoc  += nValLanc

                    If LanceiCtb // Vem do DetProva
                        If !lUsaFlag
                            RecLock("SE5")
                            SE5->E5_LA := "S"
                            MsUnlock()

                            RecLock("FK5")
                            FK5->FK5_LA := 'S'
                            MsUnlock()
                        EndIf
                    ElseIf lUsaFlag
                        If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == SE5->(Recno()) }))>0
                            aFlagCTB := Adel(aFlagCTB,nPosReg)
                            aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
                        Endif
                    EndIf

                    // Zera as variaveis contábeis para o proximo lançamento.
                    STRLCTPAD   := ""
                    VALOR       := 0 
                    IOF         := 0 
                    VALOR2      := 0 
                    ABATIMENTO	:= 0 

                    SE5->(DBGOTO(0))
                EndIf 

                If (MV_PAR12 == MVP12DOCUMENTO) 
                    If nTotDoc > 0
                        Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataBase)
                    Endif
                    nTotDoc := 0
                    LimpaArray(aFlagCTB)
                Endif
            EndIf
        EndIf 

    Enddo
	If !EMPTY(cAlias) 
		(cAlias)->(dbCloseArea())
	EndIf 

    If (MV_PAR12 == MVP12PROCESSO) 
        If nTotDoc > 0
            Ca370Incl(cArquivo,@nHdlPrv,cLote,@aFlagCTB,,dDataBase)
        Endif
        nTotDoc := 0
        LimpaArray(aFlagCTB)
    Endif

    RestArea(aGetArea)
	aSize(aGetArea,0)
	aGetArea := nil 

    If oEstFKAFK5 <> Nil 
        oEstFKAFK5:Destroy()
        oEstFKAFK5:= Nil 
    EndIf

Return .T. 

/*/{Protheus.doc} EstFKAFK5()
Posiciona a FK5 de estorno do movimento de cancelamento do Bordero Contas a Receber. 

@author Fernando Navarro 
@since 06/07/2020
@version 12.1.30
/*/

Static Function EstFKAFK5(cIdMov As Character) As Logical 

    Local cQuery    As Character 

    Local cIDEstFK5 As Character

    cIDEstFK5 := " " 

    If oEstFKAFK5 == Nil 

        cQuery := " SELECT FKA_IDORIG ESTFKAFK5 FROM " + RetSQLName("FKA") + " FKA " 
        cQuery += " INNER JOIN " + RetSQLName("FK5") + " FK5 ON FKA_IDORIG = FK5_IDMOV " 
        cQuery += " AND FKA_FILIAL = FK5_FILIAL "
        cQuery += " WHERE FKA_IDPROC IN ( "
        cQuery += " SELECT FKA_IDPROC FROM " + RetSQLName("FKA") + " AUX " 
        cQuery += " WHERE AUX.FKA_IDORIG = ? "
        cQuery += " AND   AUX.FKA_TABORI = 'FK5' " 
        cQuery += " AND   AUX.D_E_L_E_T_ = ' ' " 
        cQuery += " ) "
        cQuery += " AND  FKA.FKA_IDORIG <> ? " 
        cQuery += " AND  FKA.D_E_L_E_T_ = ' ' " 
        cQuery += " AND  FKA.FKA_TABORI = 'FK5' "

        cQuery := ChangeQuery(cQuery)

        oEstFKAFK5 := FWPreparedStatement():New(cQuery)

    Endif 

    oEstFKAFK5:SetString(1,cIdMov)
    oEstFKAFK5:SetString(2,cIdMov)

    cQuery     := oEstFKAFK5:GetFixQuery()
    cIDEstFK5  := MpSysExecScalar(cQuery,"ESTFKAFK5")

Return cIDEstFK5 

/*/{Protheus.doc} QueryTroco
Função para montar a query para buscar os registros de troco
que ainda não foram contabilizados 

@author pedro.alencar
@since 15/06/2020
@version 1.0
@type static function

@param dDataIni, date, Data inicial do período a ser filtrado
@param dDataFim, date, Data final do período a ser filtrado
@return cRet, Alias do resultset com os dados dos registros de troco não contabilizados
/*/
Static Function QueryTroco( cFilQry As Char, dDataIni As Date, dDataFim As Date ) As Char
	Local cRet As Char
	Local cQuery As Char
	Local cAliasTroc As Char
	Local aCamposQry As Array
	Local aAuxTamSX3 As Array
	Local nI As Numeric
	Default cFilQry := ""
	Default dDataIni := CTOD("//")
	Default dDataFim := CTOD("//")
	
	aCamposQry := {}
	aAuxTamSX3 := TAMSX3("FK5_DATA")
	AADD( aCamposQry, {"FK5_DATA", "D", aAuxTamSX3[1], aAuxTamSX3[2]} )
	
	cRet := ""
	If __oQryTroc == Nil
		cQuery := " SELECT R_E_C_N_O_, "
		
		For nI := 1 To Len(aCamposQry)
			cQuery += aCamposQry[nI,1]
			If nI < Len(aCamposQry)
				cQuery += ','
			EndIf
		Next nI

		cQuery += " FROM " + RetSQLName("FK5") + " FK5 "
		cQuery += " WHERE "
		cQuery +=		" FK5_FILORI = ? "
		cQuery +=		" AND FK5_DATA BETWEEN ? AND ? "
		cQuery +=		" AND FK5_MOEDA = ? "
		cQuery +=		" AND FK5_TPDOC IN (?, ?) "
		cQuery +=		" AND FK5_LA = ? "
		cQuery +=		" AND FK5.D_E_L_E_T_ = ? "
		cQuery += " ORDER BY FK5_FILIAL, FK5_DATA"

		cQuery := ChangeQuery(cQuery)
		__oQryTroc := FWPreparedStatement():New(cQuery)
	EndIf
	__oQryTroc:SetString(1, cFilQry)
	__oQryTroc:SetString(2, DTOS(dDataIni))
	__oQryTroc:SetString(3, DTOS(dDataFim))
	__oQryTroc:SetString(4, 'TC')
	__oQryTroc:SetString(5, 'VL')
	__oQryTroc:SetString(6, 'ES')
	__oQryTroc:SetString(7, Space(Len(FK5->FK5_LA)))
	__oQryTroc:SetString(8, Space(1))

	cQuery := __oQryTroc:GetFixQuery()
	cAliasTroc := MpSysOpenQuery(cQuery,,aCamposQry)
	
	If (cAliasTroc)->( !EOF() )
		cRet := cAliasTroc
	Else
		(cAliasTroc)->( dbCloseArea() )
	Endif
	
	FwFreeArray(aAuxTamSX3)
	FwFreeArray(aCamposQry)
Return cRet

/*/{Protheus.doc} SearchFor()
Função auxiliar para o posicionamento das entidades relacionadas ao processo contábil.

@author Norberto M de Melo
@since 25/08/2020
@version 1.0
@type static function

@param cAlias, character, Alias da tabela a ser pesquisada
@param nIndexOrder, numeric, Indice a ser utilizado na pesquisa
@return cExpression, character, Expressão para a pesquisa
/*/
STATIC FUNCTION SearchFor(cAlias AS Character, nIndexOrder AS Numeric, cExpression AS Character, lForcedSeek AS Logical) AS Logical
Local lRet AS Logical
DEFAULT cAlias := ALIAS()
DEFAULT nIndexOrder := (cAlias)->(INDEXORD())
DEFAULT lForcedSeek := .F.

lRet := (cAlias)->(!EOF())

IF !EMPTY(cExpression) .AND. !EMPTY(nIndexOrder)
	// Altera a ordem do indice caso seja diferente 
	IF (cAlias)->(INDEXORD()) <> nIndexOrder
		(cAlias)->(DBSETORDER(nIndexOrder))
	ENDIF
	// Efetua a pesquisa no caso de o registro atual não corresponder à expressão pesquisada
	IF lForcedSeek .OR. !cExpression $ (cAlias)->&(INDEXKEY())
		lRet := (cAlias)->(MSSEEK(cExpression))
	ENDIF
ENDIF

RETURN lRet

/*/{Protheus.doc} LoadPergunte()
Carrega nas variáveis MV_PAR** as configurações de execução do grupo FINA370 (SX1).

@author Norberto M de Melo
@since 07/12/2020
@version 1.0
@type static function

@return NIL
/*/
STATIC FUNCTION LoadPergunte()
	If !__lSchedule .AND. !FwIsInCallStack("CTBAFIN")
        Pergunte("FIN370",.F.)
	EndIf
RETURN NIL

/*/{Protheus.doc} CTBTCSetField()
Prepara chamada à função TCSETFIELD() 

@author Norberto M de Melo
@since 07/12/2020
@version 1.0
@type static function

@return NIL
/*/
STATIC FUNCTION CTBTCSetField(aStru AS ARRAY, cAlias AS CHARACTER)
	LOCAL nI AS NUMERIC

	IF !EMPTY(aStru) .AND. !EMPTY(cAlias)
		FOR nI := 1 TO LEN(aStru)
			IF aStru[nI][2] $ "NLD"
				TCSetField(cAlias, aStru[nI][1], aStru[nI][2], aStru[nI][3], aStru[nI][4])
			ENDIF
		NEXT nI
	ENDIF
RETURN NIL

/*/{Protheus.doc} CTBSleep()
Controle do tempo de espera - 

@author Norberto M de Melo
@since 28/05/2021
@version 1.0
@type static function

@return NIL
/*/
STATIC FUNCTION CTBSleep(nMS AS NUMERIC)
LOCAL nCycleTime AS NUMERIC
DEFAULT nMS := 1000	// Milissegundos -> 1 segundo

	nCycleTime := INT(nMS)
	WHILE (nCycleTime > 0)
		IF nCycleTime >= 500
			SLEEP(500)	// Milissegundos -> 0,5 segundo
			nCycleTime -= 500
		ELSE
			SLEEP(nCycleTime)
			nCycleTime := 0
		ENDIF
	ENDDO
RETURN

/*/{Protheus.doc} CtbLP596Cr()
Indica para FINCARVAR() o registro origem referente o processo de compensação
do Contas a Receber, onde  estarão vinculados os lançamentos de impostos e valores acessórios.

@author Fabio Zanchim
@since 04/03/2022
@version 1.0
@type function
/*/
Function CtbLP596Cr()
Return(__nRecCmpCR)

/*/
	{Protheus.doc} PulseLife
	Envia para o appserver um "pulso" da conexão do smartclient esta vivo
	Este procedimento evita que a conexão fique presa caso o smartclient caia 
	@type  Function
	@author Nilton Rodrigues
	@since 31/05/2022
	@version 1.0
/*/
Static Function PulseLife()
	If Seconds() - _nPulseLife > 30
		_nPulseLife := Seconds()
		SYSREFRESH()//- sincroniza com o appserver
	EndIf 
Return

/*/ {Protheus.doc} FinZap_Tmp
Função responsável por efetuar a limpeza da tabela temporária
em sua reutilização para evitarmos constantes DDL ao banco
@type  Function
@author Nilton Rodrigues
@since 13/07/2022
@param oTabTmp, object, Objeto do tipo FWTemporaryTable
@version 1.0
/*/
Static Function FinZap_Tmp( oTabTmp AS OBJECT ) AS LOGICAL
	Local nI         AS NUMERIC
	Local nPict      AS NUMERIC 
	Local cTableName AS CHARACTER
	Local cTableDrop AS CHARACTER 
	Local cIdxName   AS CHARACTER 
	Local cAliasTMP  AS CHARACTER

	If !EMPTY(oTabTmp)

        //- inicia as variável para o tratamento
        //- Com exceção do SQLServer o cAlias, serám a tabela 
        //- e o Alias
        cAliasTMP  := oTabTmp:cAlias
        cTableName := oTabTmp:cAlias
        cTableDrop := oTabTmp:cAlias
        cIdxName   := oTabTmp:cAlias
        nPict      := 2 //- para uso do strzero
        //- em SQLSERVER é usado a FWTEmporaryTable para criação
        If _MSSQL7
            cTableDrop := oTabTmp:cRealName
            cTableName := oTabTmp:OFWTMPTBL:cTableName
            cIdxName   := oTabTmp:OFWTMPTBL:cIndexname
            nPict      := 1
        EndIf 
        //- fecha o alias e abre a tabela temporária para correção do recno pela temporária.
        //- esse contorno é para um erro gerado com o dbAccess
        CTBCloseArea(cAliasTMP)
        //- O uso do delete se dá pelo fato de que o truncate possui 
        //- um commit implicito e isso faz com que o rollback não 
        //- funcione corretamente, portanto não se deve usar Truncate
        TcSqlExec(" DELETE FROM "+ cTableDrop )  //_Zap_
        //- efetua a abetura do temporário para que os caches sejam refeito pelo dbAccess
        //- o alias usado é o mesmo usado na criação da tabela temporária.
        DbUseArea(.T.,"TOPCONN", cTableName,cAliasTMP,.F.,.F.)
        dbSelectArea(cAliasTMP)
        
        //- reabre os indices que existiam na ordem criada 
        For nI := 1 to Len(oTabTmp:aIndexes)
            dbSetIndex(cIdxName+StrZero(nI,nPict))
        Next nI
        
        //- volta a ordem 1, caso exista indices
        If Len(oTabTmp:aIndexes) > 0 
            (cAliasTMP)->(dbsetorder(1))
        EndIf 
        
        (cAliasTMP)->(dbgotop())
	EndIf

Return EMPTY(oTabTmp)

/*/ {Protheus.doc} CTBCloseArea
Função auxiliar centralizada para o fechamento de Area de trabalho
@type  Function
@author Norberto M de Melo
@since 29/08/2022
@version 1.0
/*/
STATIC FUNCTION CTBCloseArea(cTabalias AS CHARACTER,lErase AS LOGICAL)
    DEFAULT lErase := .F.
    
    IF !EMPTY(cTabalias) .AND. SELECT(cTabalias) > 0
        (cTabalias)->(DBCLOSEAREA())
        IF lErase
            MsErase(cTabAlias)
        ENDIF
    ENDIF
RETURN NIL
