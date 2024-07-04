#INCLUDE "pmsmonit.ch"
#include "protheus.ch"
#include "pmsicons.ch"

#define CRLF Chr(13)+Chr(10)
#DEFINE CLR_ORANGE	RGB(255,128,000) //Laranja
#DEFINE CLR_YELLOW	RGB(250,232,005) //Amarelo Ouro
#DEFINE CLR_WINE	RGB(128,000,023) //Vinho

STATIC aCache  // armazena os recno das tarefas referentes ao recurso
STATIC cLoginRec := ""
STATIC cNaoApl := '00'
STATIC cNaoEnv := '01'
STATIC nQtdObjMax := 0  // controle de objetos no grafico de gantt

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ PMSMONIT ณ Autor ณ Edson Maricate        ณ Data ณ 18-03-2005 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Programa Monitor de Tarefas - PMS / Integrado SourceSafe     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR  ณ DATA   ณ BOPS ณ  MOTIVO DA ALTERACAO                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ        ณ      ณ                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSMONIT()
Local aTskAppont	:= NewIni()
Local aCfgMon		:= {"",6,.F.,.F.,.F.,.T.,dDataBase-15,dDataBase+14,4,"",2,Padr("",Len(AF9->AF9_PROJET)),Padr("zz",Len(AF9->AF9_PROJET))}
Local aConfig		:= {}
Local nTam			:= TamSX3("AE8_RECURS")[1]
Local aParam		:= {}
Local aParamTMP		:= {}
Local cCodRec		:= ""
Local aAreaAE8		:= {}
Local aCfgGantt		:= array(10)
Local cFiltMon		:= ""
Local cAliasTarefas	:= "AF9"

Private cCadastro   := STR0001 //"Monitor de Tarefas"
Private nRecno      := 0
Private nQtdTarefas := 0  // Projeto TDI - TEGOAQ - Quantidade de tarefas no monitor

Private oClips  := LoadBitmap( GetResources(), "clips_pq")
Private oNada   := LoadBitmap( GetResources(), "nada")

Private posDataMot := 1		// aList[n,01] Data
Private posHoraMot := 2		// aList[n,02] Hora
Private posTipErr  := 3		// aList[n,03] Cod Tipo de Erro
Private posDescri  := 4		// aList[n,04] Descricao do tipo de erro
Private posMotivo  := 5		// aList[n,05] descricao do motivo
Private posCodRej  := 6		// aList[n,06] codigo usuario rejeicao
Private posNomRej  := 7		// aList[n,07] nome usuario rejeicao
Private posAnexo   := 8		// aList[n,08] icone de anexo
Private posEntidade:= 9		// aList[n,09] alias utilizado na pesquisa
Private posRecno   := 10	// aList[n,10] registro da ANB ou ANC
Private posQtdHoras:= 11	// aList[n,11] quantidade de horas
Private aRecList   := {}	// vetor de recursos adicionais utilizada na funcao QAlocPMS no fonte QNCXFUN

aCache := Nil

If AMIIn(44) .And. !PMSBLKINT()
	nQtdObjMax := 0  // controle maximo de objetos na tela do grafico de gantt

	cCodRec := ""
	
	//
	// Verifica se o usuario estแ cadastrado como um recurso
	//
	DbSelectArea("AE8")
	aAreaAE8 := AE8->(GetArea())
	DbSetOrder(3) // buscar pelo codigo do funcionario
	If dbSeek(xFilial()+__cUserID)
		cCodRec := AE8->AE8_RECURS
		cLoginRec := AE8->AE8_RECURS 
	EndIf
	RestArea(aAreaAE8)
	
	aCfgMon[1] := padr(cCodRec ,nTam) // c๓digo do recurso
	
	aParam := {}
	aAdd( aParam ,{ 1,STR0002,aCfgMon[1],"@!",'ExistCpo("AE8",,1)',"AE8","",60,.T.}) //"Recurso:"
	aAdd( aParam ,{ 3,STR0003,aCfgMon[2],{STR0004,STR0005,STR0006,STR0007,STR0008,STR0009},70,,.F.}) //"Escala de Tempo"###"Diario"###"Semanal"###"Mensal"###"Mensal (Zoom 30%)"###"Bimestral"###"Melhor escala"
	aAdd( aParam ,{ 4,STR0010,aCfgMon[3],STR0011,45,,.F.}) //"Exibir detalhes :"###"Projeto/Tarefa"
	aAdd( aParam ,{ 4,"",aCfgMon[4],STR0036,80,,.F.}) //"Codigo do Recurso"
	aAdd( aParam ,{ 4,"",aCfgMon[5],STR0037,80,,.F.}) //"Descri็ใo do Recurso"
	aAdd( aParam ,{ 4,"",aCfgMon[6],STR0038,80,,.F.}) //"Exibir Tarefas"
	aAdd( aParam ,{ 1,STR0012,aCfgMon[7],"","","","",45,.T.}) //"Data Inicial"
	aAdd( aParam ,{ 1,STR0013,aCfgMon[8],"","","","",45,.T.}) //"Data Final"

	// Projeto TDI TDSFLX
	aAdd( aParam ,{ 3,STR0014,aCfgMon[9],{STR0015,STR0016,STR0017,STR0192},115,,.F.}) //"Considerar"###"Todas as tarefas"###"Tarefas finalizadas"###"Tarefas a executar"###"Tarefas sem Restricao" // projeto TDI TDSFLX
	aAdd( aParam ,{12,STR0068,cAliasTarefas,aCfgMon[10],.T.})  //"Filtrar tarefas"

	// Adicionar o WHEN com base no parametro MV_PMSTDFIL
	aAdd( aParam ,{ 3,STR0172,aCfgMon[11],{STR0173,STR0174},60,,.F.})  // "Filtrar considerando"##"Multiplas Filiais"##"Filial corrente"

	// Projeto TDI TFFODO - Novo filtro Projeto Inicial/Projeto Final
	aAdd( aParam ,{ 1,STR0204 ,aCfgMon[12],"@!","","AF8","",70,.F.}) //"Projeto Inicial"
	aAdd( aParam ,{ 1,STR0205 ,aCfgMon[13],"@!","","AF8","",70,.F.}) //"Projeto Final"

	If ExistBlock("PMSMON04")
		aParamTMP := ExecBlock("PMSMON04", .T., .T., aParam)
		If ValType(aParamTMP) == "A"
			aParam := aParamTMP
		EndIf
	EndIf

	If ExistBlock("PMSMTFIL")
		cFiltMon := ExecBlock("PMSMTFIL",.F.,.F.)
	Else
		cFiltMon := AN7Change( cAliasTarefas, "PMSCFGREC", "PMSMONIT" )
	EndIf
	
	If ParamBox(aParam,STR0018,aCfgMon,{||PMSMONVLD(aCfgMon)},,.F.,120,3,,IIf(!Empty(cFiltMon),cFiltMon,Nil)) //"Parametros"
	
		// monta o array de op็๕es da janela do gantt
		
		cLoginRec  := iIf(Empty(cLoginRec) ,aCfgMon[1] ,cLoginRec )
		cCodRec    := aCfgMon[1]
		aCfgGantt[1] := aCfgMon[2]
		aCfgGantt[2] := aCfgMon[3]
		aCfgGantt[3] := aCfgMon[4]
		aCfgGantt[4] := aCfgMon[5]
		aCfgGantt[5] := aCfgMon[6]
		aCfgGantt[6] := aCfgMon[7]
		aCfgGantt[7] := aCfgMon[8]
		aCfgGantt[8] := aCfgMon[9]
		aCfgGantt[9] := aCfgMon[10]
		aCfgGantt[10]:= aCfgMon[11]  // Inserido por Carlos Queiroz em 28/03/11

		aConfig := aClone(aCfgMon) 
		
		// carrega o arquivo Ini
		aTskAppont := LoadIni(cLoginRec)

		// se houver codigo do projeto e a data for diferente da database
		If (!Empty(aTskAppont[3]) .And. MsDate() != STOD(aTskAppont[7]))
			// solicita o percentual de confirmacao da tarefa executada ontem e encerra o apontamento.
			Finaliza(aTskAppont)
		EndIf
		
		//
		// Gantt com as tarefas do recurso
		//
		PmcUsrGtt(cCodRec ,aConfig ,aTskAppont,aCfgGantt)
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPmcUsrGttณ Autor ณ Edson Maricate        ณ Data ณ 18-03-2005 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณMonta uma tela de consulta com a alocacao do recurso selecio- ณฑฑ
ฑฑณ          ณnado.                                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณGenerico                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmcUsrGtt(cRecurso ,aConfig ,aTskAppont,aCfgGantt)
Local aArea    := GetArea()
Local aAreaAE8 := {}
Local dIniGnt
Local aGantt   := {}
Local aDep	   := {}
Local nTsk
Local lRet	  := .T.

dbSelectArea("AE8")
aAreaAE8 := AE8->(GetArea())
dbSetOrder(1)
If MsSeek(xFilial("AE8")+cRecurso)
	oMainWnd:CoorsUpdate()
	While lRet
		lRet := AuxUsrGtt(@aConfig,@dIniGnt,@aGantt,@nTsk,cRecurso,@aDep,aTskAppont,aCfgGantt)
	EndDo
Else
	Aviso(STR0019,STR0020 + cRecurso+ STR0021,{STR0022},2) //"Recurso inexistente"###"O recurso de c๓digo: "###" nใo estแ cadastrado."###"Fechar"
EndIf

RestArea(aAreaAE8)
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAuxUsrGttบAutor  ณMicrosiga           บ Data ณ  08/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AuxUsrGtt(aConfig,dIniGnt,aGantt,nTsk,cRecurso,aDep,aTskAppont,aCfgGantt)
Local nTop			:= oMainWnd:nTop+35
Local nLeft			:= oMainWnd:nLeft+10
Local nBottom		:= oMainWnd:nBottom-12
Local nRight		:= oMainWnd:nRight-10

Local oFont
Local oTimerAFU
Local oBtn
Local oBar 
Local oMsgBoard
Local oLayer
Local oLayer1
Local oLayer2

Local lRet			:= .F.
Local lContinua		:= .T.

Local aButtons		:= {}
Local aButTmp		:= {}
Local aMenu			:= {}
Local nInterv		:= GetNewPar("MV_PMSMNTT" ,5)
Local nCnt			:= 0
Local cActMnItem	:= ""
Local oGantt

Local bOldRfGnt

Local nOldLeft

Private bRfshGantt
PRIVATE bRfshGant1
Private oDlg

Private cMsg		:= If(!Empty(aTskAppont[3]),STR0023+Alltrim(aTskAppont[3])+"/"+AllTrim(aTskAppont[5])+"-"+Alltrim(aTskAppont[6])+STR0024+DTOC(STOD(aTskAppont[7]))+" "+aTskAppont[8],Padr(STR0025,120)) //"Em Execu็ใo : "###" Inicio : "###"Recurso Ocioso"
Private cMsgItem1	:= ""

Private aTskAppAux	:= aTskAppont

nRecno := Val(AllTrim(aTskAppont[2]))

If aConfig == Nil
	aConfig := {6,.F.,.T.,.T.,.T.,dDataBase-320,dDataBase+25,3,"",2}

	lContinua := PmsCfgRec(@oDlg,@aConfig,@dIniGnt,@aGantt)
EndIf

If lContinua 
	RegToMemory("AFA",.T.) // preventiva para nใo gerar error.log, por causa da AFA_SIMBMO
	RegToMemory("AFB",.T.) // preventiva para nใo gerar error.log, por causa da AFB_SIMBMO
	aGantt	:= {}
	
	//
	// carrega as tarefas referente ao recurso informado
	//
	LoadArray(aGantt,cRecurso,aConfig,aDep,aTskAppont)
	
	If Empty(aGantt)
		Aviso(STR0030,STR0031,{STR0022},2) //"Atencao!"###"Nao existem projetos alocados para este recurso na data selecionada. Verifique o recurso e o periodo selecionado."###"Fechar"
	Else
		// 
		// permite customizar o menu de contexto da tarefa, adicionando novos itens de menu
		//
		If ExistBlock("PMSMON01")
			aMenu := ExecBlock("PMSMON01",,,{aMenu})
			If ValType(aMenu) != "A"
				aMenu := {}
			EndIf
			For nCnt := 1 To Len(aMenu)
				If	Len(aMenu[nCnt]) <> 3 .OR. ValType(aMenu[nCnt,01]) <> "C" .OR. ValType(aMenu[nCnt,02]) <> "C" .OR. ValType(aMenu[nCnt,03]) <> "C" .OR.;
					Empty(aMenu[nCnt,01]) .OR. Empty(aMenu[nCnt,02])          .OR. Empty(aMenu[nCnt,03])
					aMenu := {}
					EXIT
				EndIf
			Next nCnt
		EndIf
		
		MENU oMenu POPUP
			MENUITEM STR0027 ACTION (oTimerAFU:DeActivate(), GttActive(oGantt,.F.), AF9->(dbGoto(nRecNo)), Inicia(aTskAppont,oMsgBoard),                          GttActive(oGantt), oTimerAFU:Activate())	//"&Executar Tarefa"
			oMenu:aItems[Len(oMenu:aItems)]:cName := "Executar Tarefa"
			MENUITEM STR0028 ACTION (oTimerAFU:DeActivate(), GttActive(oGantt,.F.), AF9->(dbGoto(nRecNo)), PMSA203(2,,"000"),                                     GttActive(oGantt), oTimerAFU:Activate())	//"&Visualizar Tarefa"
			oMenu:aItems[Len(oMenu:aItems)]:cName := "Visualiza Tarefa"
			MENUITEM STR0029 ACTION (oTimerAFU:DeActivate(), GttActive(oGantt,.F.), AF9->(dbGoto(nRecNo)), PMSA203(4,,"000"),                                     GttActive(oGantt), oTimerAFU:Activate())	//"&Alterar Tarefa"
			oMenu:aItems[Len(oMenu:aItems)]:cName := "Altera Tarefa"
			MENUITEM STR0059 ACTION (oTimerAFU:DeActivate(), GttActive(oGantt,.F.), AF9->(dbGoto(nRecNo)), PmMonSwTsk(),                                          GttActive(oGantt), oTimerAFU:Activate())	//"&Informacoes da Tarefa"
			oMenu:aItems[Len(oMenu:aItems)]:cName := "Informacoes Tarefa"
			
			If GetNewPar("MV_QTMKPMS",0) > 1 // parametro para ativar amarracao de documento
				MENUITEM STR0064 ACTION (oTimerAFU:DeActivate(), GttActive(oGantt,.F.), AF9->(dbGoto(nRecNo)), PMSQNCDOC(),                                        GttActive(oGantt), oTimerAFU:Activate())	//"A&nexar Documento"
				oMenu:aItems[Len(oMenu:aItems)]:cName := "Anexar Documento"
			EndIf
			
			If GetNewPar("MV_QTMKPMS",0) == 3 .Or. GetNewPar("MV_QTMKPMS",0) == 4
				MENUITEM STR0085 ACTION (oTimerAFU:DeActivate(), GttActive(oGantt,.F.), AF9->(dbGoto(nRecNo)), SIMAF9View(nRecNo),                                 GttActive(oGantt), oTimerAFU:Activate())	//"Rastrear QNC X TMK"
				oMenu:aItems[Len(oMenu:aItems)]:cName := "Rastrear QNC X TMK"
			EndIf

			MENUITEM STR0111 ACTION (oTimerAFU:DeActivate(), GttActive(oGantt,.F.), AF9->(dbGoto(nRecNo)), SIMBPMSCHK(nRecNo,Val(AllTrim(aTskAppont[2]))<>nRecNo), GttActive(oGantt), oTimerAFU:Activate())	//"Check List"
			oMenu:aItems[Len(oMenu:aItems)]:cName := "CheckList"
			MENUITEM STR0150 ACTION (oTimerAFU:DeActivate(), GttActive(oGantt,.F.), AF9->(dbGoto(nRecNo)), PMSMonRej(aTskAppont,oMsgBoard),                        GttActive(oGantt), oTimerAFU:Activate())	//"Rejeitar"
			oMenu:aItems[Len(oMenu:aItems)]:cName := "Rejeitar"
			MENUITEM STR0151 ACTION (oTimerAFU:DeActivate(), GttActive(oGantt,.F.), AF9->(dbGoto(nRecNo)), PMSMonHstR(),                                           GttActive(oGantt), oTimerAFU:Activate())	//"Historico Rejeicoes"
			oMenu:aItems[Len(oMenu:aItems)]:cName := "Historico Rejeicoes"

			// Projeto TDI - TEGO43 - Percentual realizado
			MENUITEM STR0189 ACTION (oTimerAFU:DeActivate(), GttActive(oGantt,.F.), AF9->(dbGoto(nRecNo)), PMSMonPerc(),                                           GttActive(oGantt), oTimerAFU:Activate())	//"% Realizado"
			oMenu:aItems[Len(oMenu:aItems)]:cName := "Percentual realizado"

			If !( Empty(aMenu) )
				For nCnt := 1 To len(aMenu)
					cActMnItem	:= "{|oMenuItem| (oTimerAFU:DeActivate(), GttActive(oGantt,.F.), AF9->(dbGoto(nRecNo)), " + AllTrim(aMenu[nCnt,03]) + ", GttActive(oGantt), oTimerAFU:Activate())}"
					MENUITEM aMenu[nCnt,01] BLOCK &cActMnItem 
					oMenu:aItems[Len(oMenu:aItems)]:cName := aMenu[nCnt,02]
				Next nCnt
			EndIf
		ENDMENU
		
		MENU oMenuFNC POPUP
			MENUITEM STR0065 ACTION (oTimerAFU:DeActivate(),GttActive(oGantt,.F.),AF9->(dbGoto(nRecNo)),nOldLeft:=oDlg:nLeft,oDlg:Move(oDlg:nTop,-oDlg:nWidth,oDlg:nWidth-10,oDlg:nHeight),cCadastro := STR0065,TMKA503A(),cCadastro := STR0001,oDlg:Move(oDlg:nTop,nOldLeft,oDlg:nWidth,oDlg:nHeight),GttActive(oGantt),oTimerAFU:Activate()) //"Chamados"
			MENUITEM STR0066 ACTION (oTimerAFU:DeActivate(),GttActive(oGantt,.F.),AF9->(dbGoto(nRecNo)),nOldLeft:=oDlg:nLeft,oDlg:Move(oDlg:nTop,-oDlg:nWidth,oDlg:nWidth-10,oDlg:nHeight),                     QNCA040() ,cCadastro := STR0001,oDlg:Move(oDlg:nTop,nOldLeft,oDlg:nWidth,oDlg:nHeight),GttActive(oGantt),oTimerAFU:Activate()) //"Fichas NC"
			MENUITEM STR0067 ACTION (oTimerAFU:DeActivate(),GttActive(oGantt,.F.),AF9->(dbGoto(nRecNo)),nOldLeft:=oDlg:nLeft,oDlg:Move(oDlg:nTop,-oDlg:nWidth,oDlg:nWidth-10,oDlg:nHeight),                     QNCA030() ,cCadastro := STR0001,oDlg:Move(oDlg:nTop,nOldLeft,oDlg:nWidth,oDlg:nHeight),GttActive(oGantt),oTimerAFU:Activate()) //"Planos de Acao"
		ENDMENU

		//
		// adiciona botใo de filtro na barra de bot๕es da dialog
		//
		aAdd(aButtons ,{BMP_OPCOES,{||(oTimerAFU:DeActivate(),GttActive(oGantt,.F.),If(PmsCfgRec(@oDlg,aConfig,@dIniGnt,aGantt),(Eval(bRfshGantt)),Nil),GttActive(oGantt),oTimerAFU:Activate())},STR0026 }) //"Op็๕es"

		//
		// adiciona botใo EQUIPE na barra de bot๕es da dialog
		//
		aAdd(aButtons ,{BMP_SIMULACAO_ALOCACAO_RECURSOS,{||(oTimerAFU:DeActivate(),GttActive(oGantt,.F.),   PMSC120(aConfig,dIniGnt,aGantt,nTsk,cRecurso,aDep,aTskAppont,aCfgGantt), GttActive(oGantt),oTimerAFU:Activate())}, "Equipe" }) //"Equipe"

		//
		// adiciona botใo de acesso ao cadastro na barra de bot๕es da dialog
		//
		If GetNewPar("MV_QTMKPMS",0) == 3 .Or. GetNewPar("MV_QTMKPMS",0) == 4
			aAdd(aButtons ,{ IIf(SetMdiChild(),"QNCIMG32","QNCIMG16") ,{|| oMenuFNC:Activate(IIf(SetMdiChild(),475,228),IIf(SetMdiChild(),50,24),oDlg) },STR0088 }) //"FNC"
		EndIf

		//
		// adiciona botใo de acesso ao check list na barra de bot๕es da dialog
		//
		aAdd(aButtons ,{ "SELECTALL" ,{|| SIMBPMSCHK(Val(AllTrim(aTskAppont[2]))) }, STR0111 }) //"Check List"

		//
		// adiciona botใo de legenda na barra de bot๕es da dialog
		//
		aAdd(aButtons ,{ "UPDWARNING" ,{|| PMSMonLeg() },STR0140 }) //"Legenda"

		//
		// adiciona botao de Rejeicoes na barra de botoes da dialog - qmt_no=icone da carinha mal-humorada
		aAdd(aButtons ,{ "qmt_no" ,{|| PMSLstRej(,aTskAppont,cRecurso),Eval(bRfshGantt)},"Rejei็๕es" }) //"Rejei็๕es"
		
		PMSLstRej(1,,cRecurso)
		// permite customizar os bot๕es do barra de bot๕es da janela, adicionando novos bot๕es na enchoicebar
		//
		If ExistBlock("PMSMON02")
			aButTmp := ExecBlock("PMSMON02")
			If ValType(aButTmp) == "A"
				For nCnt := 1 To len(aButTmp)
					If Len(aButTmp[nCnt]) >= 2
						aAdd(aButtons ,aButTmp[nCnt])
					EndIf
				Next nCnt
			EndIf
		EndIf

		DEFINE FONT oFont NAME "Arial" SIZE 0, -10
		DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD
		DEFINE MSDIALOG oDlg TITLE STR0032 OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight  //"Gantt de Aloca็ใo do Recurso"

			oDlg:lMaximized := .T.	

			// converte de minuto para milisegundo			
			nInterv := (nInterv*60000)

			oTimerAFU:= TTimer():New(nInterv,{|| TimerAFU(aTskAppont ,oMsgBoard) },oDlg)
			oTimerAFU:Activate()

			oLayer := FwLayer():New()
				
			oLayer:init(oDlg,.F.)
					
			oLayer:addLine("TOP", 5, .F.)
			oLayer:addLine("CLIENT", 95, .F.)
					
			oLayer1 := oLayer:getLinePanel("TOP")
			oLayer2 := oLayer:getLinePanel("CLIENT") 

			@ 2,1 BTNBMP oBmp1 RESOURCE "dbg09" SIZE 25,25 ACTION (oTimerAFU:DeActivate(),GttActive(oGantt,.F.),Finaliza(aTskAppont,oMsgBoard),GttActive(oGantt),oTimerAFU:Activate() ) Of oLayer1 
			oBmp1:cToolTip := STR0033 //"Clique aqui para parar a tarefa em Execu็ใo."

			@ 2,14 MSGET oMsgBoard VAR cMsg SIZE oLayer2:nWidth-100,9 Of oLayer1 PIXEL Font oBold READONLY

			@ 1000,38 BUTTON "OK" SIZE 35,12 ACTION {|| Nil} OF oDlg PIXEL
	
			PmsGantt(aGantt,aCfgGantt,@dIniGnt,,oLayer2,{14,1,(nBottom/2)-40,(nRight/2)-4},{{STR0011,95},{STR0034,30},{STR0035,105}},@nTsk,aDep,,@oGantt,,{1,2,3},,.T.) //"Projeto/Tarefa"###"Codigo"###"Nome"
	
			bOldRfGnt  := bRfshGantt 
			bRfshGant1 := {|| LoadArray(aGantt,cRecurso,aConfig,aDep,aTskAppont),Eval(bOldRfGnt)} 
			bRfshGantt := {|| (aCache:=Nil),LoadArray(@aGantt,cRecurso,@aConfig,@aDep,aTskAppont),Eval(bOldRfGnt)}

			FATPDLogUser("AUXUSRGTT")
	
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oTimerAFU:End(),oDlg:End()},{||oTimerAFU:End(),oDlg:End()},,aButtons) CENTERED
	EndIf

EndIf		
	
PMSFREEOBJ(oBtn)
PMSFREEOBJ(oBar)
PMSFREEOBJ(oMsgBoard)
PMSFREEOBJ(oGantt)

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPmsCfgRecณ Autor ณ Edson Maricate         ณ Data ณ 09-02-2001 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณExibe uma tela com as configuracoes de visualizacao do Gantt  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณGenerico                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsCfgRec(oDlg,aConfig,dIni,aGantt)
Local lRet			:= .F.
Local aOldCfg		:= aClone(aConfig)
Local cFiltMon		:= ""
Local cAliasTarefas	:= "AF9"

If ExistBlock("PMSMTFIL")
	cFiltMon := ExecBlock("PMSMTFIL",.F.,.F.)
Else
	cFiltMon := AN7Change( cAliasTarefas, "PMSCFGREC", "PMSMONIT" )
EndIf

nQtdObjMax := 0  // controle maximo de objetos na tela do grafico de gantt

// Projeto TDI TFFODO - Novo filtro Projeto Inicial/Projeto Final
If ParamBox({{1,STR0002,aConfig[1],,,,".F.",60,.F.},;	
				{ 3,STR0003,aConfig[2],{STR0004,STR0005,STR0006,STR0007,STR0008,STR0009},70,,.F.},; //"Escala de Tempo"###"Diario"###"Semanal"###"Mensal"###"Mensal (Zoom 30%)"###"Bimestral"###"Melhor escala"
				{ 4,STR0010,aConfig[3],STR0011,80,,.F.},; //"Exibir detalhes :"###"Projeto/Tarefa"
				{ 4,"",aConfig[4],STR0036,80,,.F.},; //"Codigo do Recurso"
				{ 4,"",aConfig[5],STR0037,80,,.F.},; //"Descri็ใo do Recurso"
				{ 4,"",aConfig[6],STR0038,80,,.F.},; //"Exibir Tarefas"
				{ 1,STR0012,aConfig[7],"","","","",45,.T.},; //"Data Inicial"
				{ 1,STR0013,aConfig[8],"","","","",45,.T.},; //"Data Final"
				{ 3,STR0018,aConfig[9],{STR0015,STR0016,STR0017,STR0192},115,,.F.},;//"Parametros"###"Considerar"###"Todas as tarefas"###"Tarefas finalizadas"###"Tarefas a executar"###"Tarefas sem Restricao"    // projeto TDI TDSFLX  // projeto TDI TFFODO (default alterado)
				{12,STR0068,cAliasTarefas,aConfig[10],.T.},; //"Filtrar tarefas"
  				{ 3,STR0172,aConfig[11],{STR0173,STR0174},60,,.F.},; //Filiais
  				{ 1,"Projeto Inicial",aConfig[12],"","","","",60,.F.},; //Projeto Inicial
  				{ 1,"Projeto Final",aConfig[13],"","","","",60,.F.}},; //Projeto Final
				STR0058,aConfig,,,.F.,120,3,,IIf(!Empty(cFiltMon),cFiltMon,Nil))  //"Op็๕es"

	If aOldCfg[2] != aConfig[2]
		dIni	:= CTOD("  /  /  ")
	EndIf
	If aOldCfg[5] != aConfig[5] .Or. aOldCfg[6] != aConfig[6] .Or. aOldCfg[7] != aConfig[7] .Or.aOldCfg[8] != aConfig[8]
		aGantt 	:= {}
	EndIf
	If aOldCfg[9] != aConfig[9]
		aGantt	:= {}
	EndIf
	lRet := .T.
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadArray บAutor  ณMicrosiga           บ Data ณ  09/21/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadArray(aGantt,cRecurso,aConfig,aDep,aTskAppont)
Return Processa({||AuxLoadArray(aGantt,cRecurso,aConfig,aDep,aTskAppont)},STR0039) //"Carregando Tarefas do Recurso."


/*/{Protheus.doc} AuxLoadArray

Funcao auxiliar para o pesquisa das tarefas alocadas para um recurso de acordo com os parametros

@author (desconhecido)

@since 21/09/2005

@version P11

@param aGantt, 		array, Tarefas que tem o recurso alocado
@param cRecurso, 		caracter, Codigo do recurso 
@param aConfig, 		array, Parametros de filtro para pesquisa
@param aDep, 			array, 
@param aTskAppont,	array, Informa็๕es da tarefa em execu็ใo no momento 	

Local lTMKPMS  := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ณ

/*/
Static Function AuxLoadArray(aGantt,cRecurso,aConfig,aDep,aTskAppont)
Local aArea 		:= GetArea()
Local aAreaAE8 	:= AE8->(GetArea())
Local aAreaAF9 	:= AF9->(GetArea())
Local aAreaAFA 	:= AFA->(GetArea())
Local aAreaAN8 	:= {}
Local aAreaAFD 	:= {}
Local aRGB 	 	:= {}
Local aCorBarras 	:= LoadCorBarra( "MV_PMSACOR" )
Local aAloc		:= {}
Local aRecAF9		:= {}
Local aLoadCache 	:= {}
Local nx 			:= 0
Local oFnt
Local lContinua	:= .T.
Local lRestrOK	:= .F.
Local lRejeit		:= .F.
Local lRejNIni	:= .F.
Local lPredRej	:= .F.
Local lPMSUserMnt	:= ExistBlock("PMSUserMnt")
Local lPMSQTDM 	:= SuperGetMV("MV_PMSQTDM",,.F.)  // parametro que controla a exibicao da quantidade de horas restante
Local lTMKPMS  	:= If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ณ
Local lQNC030REJ	:= FindFunction("QNC030REJ")
Local cHrsRst  	:= ""  // saldo de horas restantes para a tarefa
Local cTdFil		:= IIf( aConfig[11] == 2, "2", "1" ) //Por default considera somente a filial corrente //Inserido por Carlos Queiroz em 28/03/11
Local cFilialAFD	:= ""
Local cFilialAN8	:= ""
Local cObfNRecur	:= IIF(FATPDIsObfuscate("AE8_DESCRI",,.T.),FATPDObfuscate("RESOURCE NAME","AE8_DESCRI",,.T.),"")        


DEFINE FONT oFnt NAME "Arial" SIZE 0, -11 BOLD

aGantt  := {}
aDep	:= {}

dbSelectArea("AE8")
dbSetOrder(1)
If dbSeek(xFilial("AE8")+cRecurso)

	ProcRegua(1)
	IncProc(STR0040) //"Selecionando as tarefas. Aguarde..."
	aLoadCache := aClone(aCache)
	aAloc	   := PmsRetAloc(AE8->AE8_RECURS,aConfig[7],"00:00",aConfig[8],"24:00",aConfig[9],,,,aRecAF9,,@aLoadCache,aConfig[10],cTdFil, aConfig[12], aConfig[13],.T.)
	aCache 	:= aClone(aLoadCache)

	// Projeto TDI - TEGOAQ - Quantidade de tarefas no monitor
	nQtdTarefas := 0

	If !Empty(aAloc)
		aAdd(aGantt,{{"",AE8->AE8_RECURS,IIF(Empty(cObfNRecur),AE8->AE8_DESCRI,cObfNRecur)},{},CLR_HBLUE,oFnt})
		For nx := 1 to Len(aAloc)-1
			If aAloc[nx][3] > 0
				dIni	:= aAloc[nx][1]
				cHIni	:= aAloc[nx][2]
				dFim	:= aAloc[nx+1][1]
				cHFim	:= aAloc[nx+1][2]
				cView	:= "PmsDispBox({	{'"+STR0041+"','"+AE8->AE8_RECURS+"'},"+; //"Recurso "
										"	{'"+STR0042+"','"+IIF(Empty(cObfNRecur),AE8->AE8_DESCRI,cObfNRecur)+"'},"+; //"Descricao"
										"	{'"+STR0043+"','"+Transform(AE8->AE8_UMAX,"@E 9999.99%")+"'},"+; //"% Aloc.Max."
										"	{'"+STR0044+"','"+If(AE8->AE8_SUPALO=="1",STR0045,STR0046)+"'},"+; //"Perm.Sup.Alo."###"Sim"###"Nใo"
										"	{'"+STR0012+"','"+DTOC(dIni)+"-"+cHIni+"'},"+; // //"Data Inicial"
										"	{'"+STR0013+"','"+DTOC(dFim)+"-"+cHFim+"'},"+; //"Data Final"
										"	{'"+STR0047+"','"+Transform(aAloc[nx][3],"@E 9999.99%")+"'}},2,'"+STR0048+"',{40,120},,1)" //"% Aloc.Periodo"###"Detalhes"
				aRGB := ValorCorBarra( "2" ,aCorBarras ,2 )
				aAdd(aGantt[Len(aGantt)][2],{dIni,cHIni,dFim,cHFim,"",If(aAloc[nx][3]>AE8->AE8_UMAX ,ValorCorBarra( "1" ,aCorBarras ) ;
																							 		,RGB( (255-Int((aAloc[nx][3]/AE8->AE8_UMAX*100)*((255-aRGB[1])/100))) ,(255-Int((aAloc[nx][3]/AE8->AE8_UMAX*100)*((255-aRGB[2])/100))) ,(255-Int((aAloc[nx][3]/AE8->AE8_UMAX*100)*((255-aRGB[3])/100))) ) ;
																			),cView,2,CLR_BLACK})
			EndIf
		Next nX

		If aConfig[6]
			dbSelectArea("AFD")
			aAreaAFD := AFD->(GetArea())
			dbSetOrder(1)
			
			dbSelectArea("AN8")
			aAreaAN8 := AN8->(GetArea())
			dbSetOrder(1) //AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA+DTOS(AN8_DATA)+AN8_HORA+AN8_TRFORI
							
			cFilialAFD := xFilial("AFD")
			cFilialAN8 := xFilial("AN8")
			
			dbSelectArea("AFA")
			dbSetOrder(5)
			
			ProcRegua(Len(aRecAF9))
			For nx := 1 to Len(aRecAF9)
				cHrsRst   := ""
				lContinua := .T.

				IncProc(STR0049) //"Carregando as tarefas..."
				dbSelectArea("AF9")
				dbGoto(aRecAF9[nx])
			 	nColor	:= RGB( (255-Int(MAx(AF9->AF9_PRIORI,100)/10*((255-ValorCorBarra( "3" ,aCorBarras,2 )[1])/100))) ,(255-Int(Max(AF9->AF9_PRIORI,100)/10*((255-ValorCorBarra( "3" ,aCorBarras,2 )[2])/100))) ,(255-Int(Max(AF9->AF9_PRIORI,100)/10*((255-ValorCorBarra( "3" ,aCorBarras,2 )[3])/100))) )
				If AFA->(MsSeek(AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+cRecurso )) 
				
					lRestrOk := PmsVlRelac(AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA, 100, .F.)
					lRejeit  := .F.
					lRejNIni := .F.
					lPredRej := .F.

					AN8->(dbSetOrder(1)) //AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA+DTOS(AN8_DATA)+AN8_HORA+AN8_TRFORI
					If AN8->( MsSeek( cFilialAN8+AFA->(AFA_PROJET+AFA_REVISA+AFA_TAREFA) ) )
						Do While !AN8->(Eof()) .And. AN8->(AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA)==cFilialAN8+AFA->(AFA_PROJET+AFA_REVISA+AFA_TAREFA) .And. (AN8->AN8_STATUS=='2' .Or. AN8->AN8_STATUS=='3')
							AN8->(dbSkip())
						EndDo
						lRejeit  := !AN8->(Eof()) .And. AN8->(AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA)==cFilialAN8+AFA->(AFA_PROJET+AFA_REVISA+AFA_TAREFA)
						lRejNIni := lRejeit .And. Empty(AN8->AN8_STATUS)
					EndIf

					AN8->(dbSetOrder(2)) //AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TRFORI+DTOS(AN8_DATA)+AN8_HORA+AN8_TAREFA
					If AN8->( MsSeek( cFilialAN8+AFA->(AFA_PROJET+AFA_REVISA+AFA_TAREFA) ) )
						Do While !AN8->(Eof()) .And. AN8->(AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA)==cFilialAN8+AFA->(AFA_PROJET+AFA_REVISA+AFA_TAREFA) .And. (AN8->AN8_STATUS=='2' .Or. AN8->AN8_STATUS=='3')
							AN8->(dbSkip())
						EndDo
						lPredRej := !AN8->(Eof())  .And. AN8->(AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA)==cFilialAN8+AFA->(AFA_PROJET+AFA_REVISA+AFA_TAREFA)
					EndIf

					// Projeto TDI - TDSLF0 - Identificacao de chamados rejeitados no Monitor de Tarefas
					if ! lRejeit .and. lTMKPMS
						lRejeit := QNC030REJ(AF9->AF9_FILIAL, AF9->AF9_ACAO, AF9->AF9_REVACA, AF9->AF9_TPACAO)
					Endif	

					Do Case
						Case !Empty(aTskAppont[2]) .And. Val(aTskAppont[2])==aRecAF9[nx]
							nColor := CLR_BLACK
							nColorBar := CLR_BLACK
						// Projeto TDI - TDSLF0 - Identificacao de chamados rejeitados no Monitor de Tarefas
						Case lRejeit
							nColorBar := CLR_ORANGE
						Case AFA->((!Empty(AFA->AFA_RESP) .And. AFA->AFA_RESP <> "1"))   // Recurso nใo ้ responsavel pela tarefa.
							nColorBar := CLR_MAGENTA
						Case !Empty(AF9->AF9_DTATUF) .And. !lRejeit
							nColorBar := CLR_GRAY
						Case ((dDataBase > AF9->AF9_START .And. Empty(AF9->AF9_DTATUI)) .Or. (dDataBase > AF9->AF9_FINISH .And. Empty(AF9->AF9_DTATUF))) .And. lRestrOk
							nColorBar := CLR_HRED
						Case !Empty(AF9->AF9_DTATUI) .And. !lRejNIni .And. !lPredRej
							nColorBar := CLR_BROWN
						Case dDataBase > AF9->AF9_START .And. !lRestrOk
							nColorBar := CLR_HMAGENTA
						Case !lRestrOk
							nColorBar := CLR_BLUE
						OtherWise
							nColorBar := CLR_GREEN
					EndCase
               
					// Projeto TDI - TEGOAQ - Quantidade de tarefas no monitor 
					nQtdTarefas++

					If lPMSUserMnt
						If ExecBlock("PMSUserMnt")
							// Projeto TDI - TDSLF0 - Identificacao de chamados rejeitados no Monitor de Tarefas
							if lPMSQTDM
								cHrsRst := PMSMonPerc(2) // retorna a quantidade de horas restante
							Endif
							aAdd(aGantt,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,"",""},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF, if(lPMSQTDM,"Saldo:"+cHrsRst+"h ","")+if(lRejeit,"*REJEITADA* ","")+AllTrim(AF9->AF9_PROJET)+":"+Alltrim(AF9->AF9_DESCRI)+"-"+AllTrim(TransForm(AFA->AFA_ALOC,"@E 99999.99%"))+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,CTOD("01/12/2020")),"@E 999.99%")),,"(nRecno:="+Str(AF9->(Recno()))+",PmMonCtrMnu(oMenu),oMenu:Activate(x,y,oBar))",1,nColorBar}},nColor,oFnt})
						Else
							lContinua := .F.
						Endif
					Else
						// Projeto TDI - TDSLF0 - Identificacao de chamados rejeitados no Monitor de Tarefas
						If lPMSQTDM
							cHrsRst := PMSMonPerc(2) // retorna a quantidade de horas restante
						Endif
						aAdd(aGantt,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,"",""},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF, if(lPMSQTDM,"Saldo:"+cHrsRst+"h ","")+if(lRejeit,"*REJEITADA* ","")+AllTrim(AF9->AF9_PROJET)+":"+Alltrim(AF9->AF9_DESCRI)+"-"+AllTrim(TransForm(AFA->AFA_ALOC,"@E 99999.99%"))+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,CTOD("01/12/2020")),"@E 999.99%")),,"(nRecno:="+Str(AF9->(Recno()))+",PmMonCtrMnu(oMenu),oMenu:Activate(x,y,oBar))",1,nColorBar}},nColor,oFnt})
					Endif

					// se existe predecessora pra tarefa
					If lContinua
						AFD->(MsSeek(cFilialAFD+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA))
						While !AFD->(EOF()) .And. cFilialAFD+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==AFD->(AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA)
							nPos := aScan( aDep ,{|aTarefa| aTarefa[1] == AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_TAREFA})
							If nPos > 0
								aadd( aDep[nPos][2],{ AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_PREDEC ,AFD->AFD_TIPO } )
							Else
								aadd( aDep ,{ AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_TAREFA ,{ {AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_PREDEC ,AFD->AFD_TIPO} }} )
							Endif
							AFD->(dbSkip())
						EndDo
					Endif
				Endif
			Next nX
			RestArea(aAreaAN8)
			RestArea(aAreaAFD)
		EndIf
	EndIf
EndIf

// se existir estouro de objetos
GanttObjMax(aGantt)

RestArea(aAreaAFA)
RestArea(aAreaAF9)
RestArea(aAreaAE8)
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmMonCtrMnuบAutor  ณMicrosiga           บ Data ณ  09/21/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PmMonCtrMnu(oMenu)
Local nI       := 0
Local aArea    := GetArea()
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAF8 := AF8->(GetArea())
Local aAreaAFF := AFF->(GetArea())
Local aAreaAN8 := {}
Local nPerc
Local lOk
Local lOk2
Local aPred
Local lRejeit
Local cAN8Status := ""
Local lPMSMON08 := ExistBlock("PMSMON08")
Local oAux
Local cTipoRejeicao	:= ""
Local aAJOArea		:= {}
Local nPosMenu		:= 0
Local nMV_QTMKPMS		:= GetNewPar("MV_QTMKPMS",0)

CursorWait()

AF9->(dbGoTo(nRecNo))				//Posiciona AF9 sobre a tarefa clicada no Gantt
									//Obs.: nRecNo possui o RecNo() da tarefa clicada
                  
// limpar a variavel para evitar a mensagem em todos os itens
cMsgItem1 := ""

dbSelectArea("AN8")
aAreaAN8 := AN8->(GetArea())
AN8->(dbSetOrder(2)) //AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TRFORI+DTOS(AN8_DATA)+AN8_HORA+AN8_TAREFA
If AN8->( MsSeek( xFilial("AN8")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA) ) )
	lRejeit := .F.

	While !AN8->( Eof() ) .And. AN8->(AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TRFORI)==xFilial("AN8")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
		cAN8Status := AN8->AN8_STATUS
		AN8->( DbSkip() )
	End

	If cAN8Status <= "1"  // se estแ em branco tambem considera que tem rejeicao em andamento
		lRejeit := .T.
	EndIf
Else
	lRejeit := .F.
EndIf
RestArea(aAreaAN8)

If AFF->( MsSeek(xFilial("AFF")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)) )
	Do While !AFF->(Eof()) .And. AFF->(AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA)==xFilial("AFF")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
		AFF->(dbSkip())
	EndDo
	AFF->(dbSkip(-1))
	nPerc := PMS310QT(.F.,"AFF")
Else
	nPerc := 0
EndIf

For nI := 1 To Len(oMenu:aItems)
	oMenu:aItems[nI]:Disable()
Next nI

// Somente estas posicoes sใo fixas
//--------------------------------
// oMenu:aItems[nI]
//--------------------------------
// nI - Item do Menu 
//--------------------------------
// 01 - Executar Tarefa 
// 02 - Visualizar Tarefa
// 03 - Alterar Tarefa
// 04 - Informacoes da Tarefa
//--------------------------------

If lRejeit
	oMenu:aItems[01]:Disable()
	cMsgItem1 := STR0178//"O plano foi rejeitado e nใo pode ser executado!"
Else
	If xFilial("AF9") <> AF9->AF9_FILIAL
		oMenu:aItems[01]:Disable()
		cMsgItem1 := STR0179 + " " + AF9->AF9_FILIAL //"O plano foi criado na filial"
	Else
		If PmsVldFase("AF8", AF9->AF9_PROJET, "86" ,.F.)
			If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,"",3,"RECURS",AF9->AF9_REVISA,__cUserID,.F.)
				If nPerc >= 100
					oMenu:aItems[01]:Disable()
				Else
					oMenu:aItems[01]:Enable()
				EndIf
			Else
				oMenu:aItems[01]:Disable()
				cMsgItem1 := STR0180 //"Usuario sem permissao para executar a tarefa"
			EndIF
		Else
			oMenu:aItems[01]:Disable()
			cMsgItem1 := STR0181 // "A tarefa nao pode ser executado pois a fase do projeto nao permite!"
		EndIf
	EndIf
EndIf

// Chamado TFDSM7
// verifica se a tarefa esta em processo de rejeicao
if Empty(cMsgItem1)  
	DbSelectArea("AN8")  
	aAreaAN8 := AN8->(GetArea())
	
	cAN8Status := "3"

	// posiciona na proxima tarefa e em seguida retorna para o ultimo registro de ocorrencia da tarefa
	AN8->( DbSetOrder(1)) //AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TRFORI+DTOS(AN8_DATA)+AN8_HORA+AN8_TAREFA
	AN8->( DbSeek( xFilial("AN8")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)+"x",.T.) )
	AN8->( Dbskip(-1))

	// se apos o posicionamento esta efetivamente na tarefa, verifica o status	(evitando um do/while)
	if AN8->( AN8_PROJET+AN8_REVISA+AN8_TAREFA)	== AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
		cAN8Status := AN8->AN8_STATUS
	Endif			

	If cAN8Status == " "
		cMsgItem1 := STR0206 //"Esta tarefa esta em processo de rejeicao. Clique no botao 'Rejeicoes' para analisar a rejeicao antes de executar a tarefa."
	EndIf
	RestArea(aAreaAN8)
Endif 

oMenu:aItems[02]:Enable()

// Se a fase do projeto permite alterar a tarefa
If xFilial("AF9") <> AF9->AF9_FILIAL
	oMenu:aItems[03]:Disable()
Else
	If PmsVldFase("AF8",AF9->AF9_PROJET,"18" ,.F.)
		oMenu:aItems[03]:Enable()
	Else
		oMenu:aItems[03]:Disable()
	EndIf
EndIf

oMenu:aItems[04]:Enable()

If nMV_QTMKPMS > 1 // parametro para ativar amarracao de documento
	// Busca pela opcao "Anexar Documento" para assim habilitar
	nPosMenu := aScan(oMenu:aItems,{|x|x:cName=="Anexar Documento"})
	If nPosMenu >0 
		oMenu:aItems[nPosMenu]:Enable()
	EndIf
EndIf

If nMV_QTMKPMS == 3 .Or. nMV_QTMKPMS == 4
	If !empty(AF9->AF9_FNC) .And. !empty(AF9->AF9_ACAO)
		// Busca pela opcao "Anexar Documento" para assim habilitar
		nPosMenu := aScan(oMenu:aItems,{|x|x:cName=="Rastrear QNC X TMK"})
		If nPosMenu >0 
			oMenu:aItems[nPosMenu]:Enable()
		EndIf
	EndIf
EndIf

// habilita a opcao checklist, caso a tarefa tiver checklist
dbSelectArea("AJO")
aAJOArea	:= AJO->(GetArea())
dbSetOrder(1)   
If MsSeek(xFilial("AJO")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA),.F.)
	// Se nao existirem itens de check list, retorna
	nPosMenu := aScan(oMenu:aItems,{|x|x:cName=="CheckList"})
	oMenu:aItems[nPosMenu]:Enable()
EndIf	
RestArea(aAJOArea)

dbSelectArea("AF8")
dbSetOrder(1)
If MsSeek(xFilial("AF8")+AF9->AF9_PROJET)

	If AF8->AF8_PAR002 == "1" .OR. AF8->AF8_PAR002 == "2" // verifica se e rejeicao por tarefa
		If AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)==aTskAppAux[3]+aTskAppAux[4]+aTskAppAux[5] // Tarefa em execucao
			aPred := PegaPredec(AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA, AE8->AE8_RASTRO)
			If len(aPred)>0 // Verifica se tem predecessora
				// Busca pela opcao rejeitar para assim habilitar
				nPosMenu := aScan(oMenu:aItems,{|x|x:cName=="Rejeitar"})
				If nPosMenu >0 
					oMenu:aItems[nPosMenu]:Enable()
				EndIf
			EndIf

			lOk2 := .T.
			If AF8->AF8_PAR002 == "1" // rejeicao por FNC
				If nMV_QTMKPMS == 3 .Or. nMV_QTMKPMS == 4
					DbSelectArea( "ANC" )
					DbSetOrder( 1 )
					// Se nao houver registros de rejeicao, desabilita a opcao no menu
					If	ANB->( !DbSeek( xFilial( "ANB" ) + AllTrim( AF9->( AF9_FILIAL + AF9_PROJET + AF9_REVISA + AF9_TAREFA ) ) ) )
						lOk2 := .F.
					EndIf
				EndIf
			Else
				If AF8->AF8_PAR002 == "2" // rejeicao por tarefa
					DbSelectArea( "ANC" )
					DbSetOrder( 1 )
					// Se nao houver registros de rejeicao, desabilita a opcao no menu
					If	ANC->( !DbSeek( xFilial( "ANC" ) + AllTrim( AF9->( AF9_FILIAL + AF9_PROJET + AF9_REVISA + AF9_TAREFA ) ) ) ) 
						lOk2 := .F.
					EndIf
				EndIf
			EndIf
		EndIf
		If lOk2
			// Busca pela opcao "Historico Rejeicoes" para assim habilitar
			nPosMenu := aScan(oMenu:aItems,{|x|x:cName=="Historico Rejeicoes"})
			If nPosMenu >0 
				oMenu:aItems[nPosMenu]:Enable()
			EndIf
		EndIf
	EndIf
EndIf

If ExistBlock("PMSMON03")
	ExecBlock("PMSMON03", .F., .F., oMenu)
EndIf

If !Empty( cMsgItem1 ) .AND. GetNewPar("MV_QTMKPMS",0) == 3 .OR. GetNewPar("MV_QTMKPMS",0) == 4
	oMenu:aItems[01]:Enable()
EndIf

If lPMSMON08
	oAux := ExecBlock("PMSMON08", .F., .F., oMenu)
	If ValType(oAux) == "O"
		oMenu := oAux
   EndIf
EndIf

// Projeto TDI - TEGO43 - Percentual ja realizado da tarefa
// menu "% Realizado"
nPos := Ascan(oMenu:aItems, { |e| e:ccaption = STR0189 } )
if nPos > 0
	oMenu:aItems[nPos]:Enable()
Endif

RestArea(aAreaAFF)
RestArea(aAreaAF8)
RestArea(aAreaAF9)
RestArea(aArea)

CursorArrow()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTimerAFU  บAutor  ณMicrosiga           บ Data ณ  25/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TimerAFU(aTskAppont ,oMsgBoard)
Local aNewTsk := LoadIni(cLoginRec)

	If !Empty(aNewTsk) .AND. !(aNewTsk[2] == aTskAppont[2]) // se leu o arquivo de configuracao e for diferente o codigo da tarefa
		aTskAppont := aClone(aNewTsk)
		If !Empty(aTskAppont[2])
			cMsg := STR0023+Alltrim(aTskAppont[3])+"/"+AllTrim(aTskAppont[5])+"-"+Alltrim(aTskAppont[6])+STR0051+DTOC(STOD(aTskAppont[7]))+" "+aTskAppont[8] //"Em Execu็ใo : "###" - Iniciada : "
		Else
			cMsg := Padr(STR0025,120) 
		EndIf
		If !(oMsgBoard == NIL)
			oMsgBoard:Refresh()
		EndIf
		If Type("bRfshGant1")<>"U"
			Eval(bRfshGant1) 
		Endif
		
	EndIf

	If !Empty(aTskAppont[3]) .and. MsDate() == STOD(aTskAppont[7]) // Se foi informado o recno da tabela af9
		GravaAFU(aTskAppont,STR0069) //"Atualizando apontamento de Recurso..."
	EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaAFU  บAutor  ณMicrosiga           บ Data ณ  25/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GravaAFU(aTskAppont ,cMensagem)
Local aArea    := GetArea()
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAF8 := AF8->(GetArea())
Local aAreaAFU := {}
Local nOpc     := 0
Local aGetCPos := {}
Local lRet     := .F.
Local cHoraI   := aTskAppont[8] // Hora inicio
Local cHoraF   := ""
Local cHoraFim := ""
Local nDecAFU  := TamSX3("AFU_HQUANT")[2]
Local nQtdHora := 0
Local nRecAFU  := 0  
Local _cMsgErro   := ""
Local _cErrDetail := ""
Local _cFile      := ""
Local lExecA320   := .F.
Local bPMSA320    := {||.T.}
Local nCnt        := 0
Local lApontDup   := .F.       
Local nRecApont   := 0
Local aOptions    := {}        
Local nOpcAviso   := 0
Local cFileLog    := ""
Local aError      := {}
Local cMsgAux

// Controle de Apontamentos com Horas Excedentes
Local nSaldo		:= 0
Local nQtdInfo		:= 0
Local nDifHrs		:= 0
Local aCalcHr		:= {}
Local cMsg			:= ""
Local cTO			:= ""
Local cCC			:= ""
Local cCalend		:= ""
Local cAssunto		:= ""
Local cQuery 		:= ""
Local cAliasTMP 	:= ""

#IFDEF TOP
	Local n320Altera	:= 8
	Local lSQL		:= Upper(TcSrvType()) != "AS/400" .and. Upper(TcSrvType()) != "ISERIES" .and. ! ("POSTGRES" $ Upper(TCGetDB()))
#ELSE
	Local n320Altera	:= 7
	Local lSQL		:= .F.
#ENDIF

DEFAULT cMensagem := STR0070 //"Gravando apontamento do recurso..."
	
	// formata a hora final de acordo com o parametro MV_PRECISA
	cHoraF := iIf(MsDate() == STOD(aTskAppont[7]) ,PmsFmtHr(Left(Time(),5)) ,"" )
	// formata a hora inicial de acordo com o parametro MV_PRECISA
	cHoraI := PmsFmtHr(cHoraI)
   
	dbSelectArea("AF9")
	dbGoto(Val(AllTrim(aTskAppont[2])))
 	
	nRecAFU  := 0
	
	//
	// deve buscar o registro AFU que coincida com o projeto/tarefa/recurso/data/hora
	//	
	dbSelectArea("AFU")
	aAreaAFU := AFU->(GetArea())
	If lSQL
		cQuery := "SELECT R_E_C_N_O_ "
		cQuery += " FROM "+RetSqlName("AFU") + " AFU "
		cQuery += " WHERE AFU_FILIAL = '"+xFilial("AFU")+"'  "
		cQuery += " and AFU_CTRRVS = '1' "
		cQuery += " and AFU_RECURS = '"+aTskAppont[1]+"' "
		cQuery += " and AFU_DATA = '"+aTskAppont[7]+"' "
		cQuery += " and AFU_HORAI = '"+cHoraI+"' "
		cQuery += " and D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		cAliasTMP := GetNextAlias()
		
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTMP,.F.,.T.)
		
		If (cAliasTMP)->(!Eof())
			If (cAliasTMP)->R_E_C_N_O_>0
				nRecAFU := (cAliasTMP)->R_E_C_N_O_
			EndIf
		EndIf
		(cAliasTMP)->(dbCloseArea())	 
	Else
		dbSetOrder(3) // AFU_FILIAL+AFU_CTRRVS+AFU_RECURS+DTOS(AFU_DATA)
		dbSeek(xFilial("AFU") + "1" + aTskAppont[1] + aTskAppont[7])
		While !Eof() .And. xFilial("AFU") + "1" + aTskAppont[1] + aTskAppont[7] ==;
						AFU->AFU_FILIAL + AFU->AFU_CTRRVS + AFU->AFU_RECURS + DTOS(AFU->AFU_DATA)
	
			If AFU->(AFU_PROJET+AFU_REVISA+AFU_TAREFA) == AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
				// se for a tarefa atual, considera esta para apontamento
				If AFU->AFU_HORAI == cHoraI
			    	nRecAFU  := Recno()
				EndIF
			EndIf
			dbSkip()
		EndDo
	EndIf
	
	lApontDup := .F.
	// se houver existir tarefa com esta hora informada.	
	If VldAppHora(aTskAppont[1] ,SToD(aTskAppont[7]) ,cHoraI ,cHoraF ,nRecAFU)>0
		lApontDup := .T.
	EndIf
	
	//
	// Se executa a rotina PMSA320 ou nao.
	//
	lExecA320 := .F.
		
	//
	// Se achou o registro ou nใo existe registro do apontamento ou nem houve apontamento no periodo 
	//	
	If nRecAFU>0 .OR. (nRecAFU==0 .AND. !lApontDup)
	
		dbSelectArea("AF8")
		dbSetOrder(1)
		If dbSeek(xFilial()+AF9->AF9_PROJET)  
		
			// se existir, atualiza, senao inclui
			nOpc := iIf(nRecAFU==0 ,3 ,n320Altera)
		
			aAdd(aGetCPos ,{"AFU_PROJET" ,AF9->AF9_PROJET     ,.F.})
			aAdd(aGetCPos ,{"AFU_TAREFA" ,AF9->AF9_TAREFA     ,.F.})
			aAdd(aGetCPos ,{"AFU_REVISA" ,AF9->AF9_REVISA     ,.F.})
			aAdd(aGetCPos ,{"AFU_RECURS" ,aTskAppont[1]       ,.F.})
			aAdd(aGetCPos ,{"AFU_DATA"   ,STOD(aTskAppont[7]) ,.F.})
			aAdd(aGetCPos ,{"AFU_HORAI"  ,aTskAppont[8]       ,.F.})

			// Verifica se esta habilitado no projeto o bloqueio de horas excedentes.
			If PACtrlApon( AF9->AF9_PROJET ) .AND. PACtrlHoras( AF9->AF9_PROJET )
				nQtdInfo	:= PmsHrsItvl(	STOD(aTskAppont[7]), aTskAppont[8], STOD(aTskAppont[7]), aTskAppont[8], ;
											ReadValue("AE8", 1, xFilial("AE8") + aTskAppont[1], "AE8_CALEND"),;
											AF9->AF9_PROJET, aTskAppont[1], , .T.)
				nSaldo		:= PA320ChkApon( AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA, aTskAppont[1], nQtdInfo, STOD(aTskAppont[7]) )

				If nSaldo > 0
					//Este deve gerar um apontamento com o saldo de horas e gerar um pr้-apontamento com a diferen็a de horas. 
					If nQtdInfo > nSaldo
						nDifHrs := nQtdInfo - nSaldo
	
						// Define o apontamento com o saldo
						cCalend		:= Posicione("AE8",1,xFilial("AE8")+aTskAppont[1],"AE8_CALEND")
						aCalcHr		:= PMSADDHrs( STOD(aTskAppont[7]), aTskAppont[8], cCalend, nSaldo, AF9->AF9_PROJET, aTskAppont[1] )
						aAdd(aGetCPos ,{"AFU_HQUANT" ,nSaldo,.T.})
						If !Empty( aCalcHr )
							aAdd(aGetCPos ,{"AFU_HORAF"  ,aCalcHr[2],.T.})
						EndIf
					Else
						//Se a tarefa estแ sendo encerrada no mesmo dia que foi iniciada
						If MsDate() == STOD(aTskAppont[7])
							lExecA320 := .T.
							cHoraF := Left(Time(),5)

							aAdd(aGetCPos ,{"AFU_HORAF"  ,cHoraF ,.T.})

							// calcula a quantidade de horas
							nQtdHora := Round(SubtHoras(STOD(aTskAppont[7]),aTskAppont[8],STOD(aTskAppont[7]),cHoraF),nDecAFU)

							aAdd(aGetCPos ,{"AFU_HQUANT" ,nQtdHora ,.T.})
						Else
							//Se existe um apontamento sem ser fechado para esta tarefa, solicitar a hora em que deveria terminar o apontamento
							If nRecAFU>0 .and. Empty(cHoraF)
								
								// atualiza o registro de apontamento
								nOpc := n320Altera
				
								// posiciona o registro
								AFU->(dbGoTo(nRecAFU))
								
								Aviso(STR0071, STR0072,{"OK"},2) //"Apontamento de recurso em aberto"##"Existe apontamento de hora do recurso anterior a database em aberto. Sera aberto janela para informar a hora final."
						 		aParam	:=	{}
								aAdd(aParam ,{1,STR0073,Dtoc(AFU->AFU_DATA),"@D",'.T.',"",".F.",60,.F.}) //"Data de apontamento"
								aAdd(aParam ,{1,STR0074,AFU->AFU_HORAI,"@R 99:99",'.T.',"",".F.",60,.F.}) //"Hora Inicio"
								aAdd(aParam ,{1,STR0075,AFU->AFU_HORAF,"@R 99:99",'AtVldHora(mv_par03)',"","",60,.T.}) //"Hora Fim"
								mv_par03:= "00:00"
								While mv_par03 < AFU->AFU_HORAI
									ParamBox(aParam,STR0076,,,,.F.,60,3) //"Parametros"
			  						mv_par03:= PmsFmtHr(mv_par03)
									If mv_par03 < AFU->AFU_HORAI
										MsgStop(STR0077,STR0078) //"Hora invalida"
									Endif
			
									nRecApont := VldApphora(AFU->AFU_RECURS ,AFU->AFU_DATA ,AFU->AFU_HORAI ,mv_par03 ,nRecAFU)
			
			                        If nRecApont >0 
										If !IsBlind()
											aOptions := {STR0079,"OK"} //"Detalhes"
											cMsgAux := ""
										Else
											aOptions := {"OK"}
											cMsgAux := Alltrim(AFU->AFU_RECURS)+": "+DTOC(AFU->AFU_DATA)+" "+AFU->AFU_HORAI+" - "+mv_par03+CRLF
											AFU->(dbGoTo(nRecApont))
											cMsgAux += Alltrim(AFU->AFU_RECURS)+": "+DTOC(AFU->AFU_DATA)+" "+AFU->AFU_HORAI+" - "+AFU->AFU_HORAF+" ("+Alltrim(str(AFU->(Recno())))+")"+CRLF
											AFU->(dbGoTo(nRecAFU))
										endIf	
										nOpcAviso := Aviso(STR0030,STR0080+CRLF+cMsgAux,aOptions,2) //"Atencao!"##"Ja existem apontamentos gravados para este recurso neste periodo. Verifique a hora informada"
										If len(aOptions)>1 .AND. nOpcAviso == 1
											// posiciona o registro jแ existente
											AFU->(dbGoTo(nRecApont))
											AxVisual("AFU",nRecApont,2)
											// retorna para o registro anterior
											AFU->(dbGoTo(nRecAFU))
										EndIf
										mv_par03:= "00:00"
									EndIf
								Enddo
								
								cHoraF := mv_par03
								lExecA320 := .T.
			
								aAdd(aGetCPos ,{"AFU_HORAF"  ,cHoraF,.T.})
								aAdd(aGetCPos ,{"AFU_OBS"    ,STR0050  ,}) //"Apontamento encerrado automaticamente."
							EndIf
						EndIf
					EndIf

					lExecA320 := .T.
				Else
					// Pelo fato de nao haver saldo, deve gerar um pre-apontamento
					aGetCPos := {}
					
					// Guarda o horario final do apontamento normal (com saldo)
					cHoraFim	:= cHoraF
					cHoraF		:= Left(Time(),5)

					DbSelectArea( "AJK" )
					AJK->( DbSetOrder( 1 ) )
					If AJK->( DbSeek( xFilial( "AJK" ) + "1" + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA + aTskAppont[1] + aTskAppont[7] ) )
						// calcula a quantidade de horas						
						nQtdHora	:= NoRound(SubtHoras(STOD(aTskAppont[7]),AJK->AJK_HORAI,STOD(aTskAppont[7]),PmsFmtHr( cHoraF )),nDecAFU)
										// na gravacao do projeto(PMSA410) o sistema grava o AF9_HDURAC campo sem arredondar, foi alterado para nao 
										// gerar diferencas.
						RecLock( "AJK" )
						AJK->AJK_HQUANT	:= nQtdHora
						AJK->AJK_HORAF	:= PmsFmtHr( cHoraF )
						AJK->( MsUnLock() )
					Else
						// calcula a quantidade de horas
						nQtdHora	:= NoRound(SubtHoras(STOD(aTskAppont[7]),cHoraFim,STOD(aTskAppont[7]),cHoraF),nDecAFU)
							// na gravacao do projeto(PMSA410) o sistema grava o AF9_HDURAC campo sem arredondar, foi alterado para nao 
							// gerar diferencas.

						RecLock( "AJK", .T. )
						AJK->AJK_FILIAL	:= xFilial( "AJK" )
						AJK->AJK_CTRRVS	:= "1"
						AJK->AJK_PROJET	:= AF9->AF9_PROJET
						AJK->AJK_TAREFA	:= AF9->AF9_TAREFA
						AJK->AJK_REVISA	:= AF9->AF9_REVISA
						AJK->AJK_RECURS	:= aTskAppont[1]
						AJK->AJK_HQUANT	:= nQtdHora
						AJK->AJK_DATA	:= STOD(aTskAppont[7])
						AJK->AJK_HORAI	:= cHoraFim // Inicia no termino do apontamento com saldo
						AJK->AJK_HORAF	:= PmsFmtHr( cHoraF )
						AJK->AJK_SITUAC	:= "1"	// Pendente
						AJK->( MsUnLock() )
					EndIf

					lExecA320	:= .F.
					lRet		:= .T.
				EndIf
			Else
				//Se a tarefa estแ sendo encerrada no mesmo dia que foi iniciada
				If MsDate() == STOD(aTskAppont[7])
				
					lExecA320 := .T.
					cHoraF := Left(Time(),5)
					
					aAdd(aGetCPos ,{"AFU_HORAF"  ,cHoraF ,.T.})
					
					// calcula a quantidade de horas
					nQtdHora := Round(SubtHoras(STOD(aTskAppont[7]),aTskAppont[8],STOD(aTskAppont[7]),cHoraF),nDecAFU)
					
					aAdd(aGetCPos ,{"AFU_HQUANT" ,nQtdHora ,.T.})
					
					lExecA320 := .T.
				
				// Apontamento do dia anterior
				//	
		 		Else
					//Se existe um apontamento sem ser fechado para esta tarefa, solicitar a hora em que deveria terminar o apontamento
					If nRecAFU>0 .and. Empty(cHoraF)
						
						// atualiza o registro de apontamento
						nOpc := n320Altera
		
						// posiciona o registro
						AFU->(dbGoTo(nRecAFU))
						
						Aviso(STR0071, STR0072,{"OK"},2) //"Apontamento de recurso em aberto"##"Existe apontamento de hora do recurso anterior a database em aberto. Sera aberto janela para informar a hora final."
				 		aParam	:=	{}
						aAdd(aParam ,{1,STR0073,Dtoc(AFU->AFU_DATA),"@D",'.T.',"",".F.",60,.F.}) //"Data de apontamento"
						aAdd(aParam ,{1,STR0074,AFU->AFU_HORAI,"@R 99:99",'.T.',"",".F.",60,.F.}) //"Hora Inicio"
						aAdd(aParam ,{1,STR0075,AFU->AFU_HORAF,"@R 99:99",'AtVldHora(mv_par03)',"","",60,.T.}) //"Hora Fim"
						mv_par03:= "00:00"
						While mv_par03 < AFU->AFU_HORAI
							ParamBox(aParam,STR0076,,,,.F.,60,3) //"Parametros"
	  						mv_par03:= PmsFmtHr(mv_par03)
							If mv_par03 < AFU->AFU_HORAI
								MsgStop(STR0077,STR0078) //"Hora invalida"
							Endif
	
							nRecApont := VldApphora(AFU->AFU_RECURS ,AFU->AFU_DATA ,AFU->AFU_HORAI ,mv_par03 ,nRecAFU)
	
	                        If nRecApont >0 
								If !IsBlind()
									aOptions := {STR0079,"OK"} //"Detalhes"
									cMsgAux := ""
								Else
									aOptions := {"OK"}
									cMsgAux := Alltrim(AFU->AFU_RECURS)+": "+DTOC(AFU->AFU_DATA)+" "+AFU->AFU_HORAI+" - "+mv_par03+CRLF
									AFU->(dbGoTo(nRecApont))
									cMsgAux += Alltrim(AFU->AFU_RECURS)+": "+DTOC(AFU->AFU_DATA)+" "+AFU->AFU_HORAI+" - "+AFU->AFU_HORAF+" ("+Alltrim(str(AFU->(Recno())))+")"+CRLF
									AFU->(dbGoTo(nRecAFU))
								endIf	
								nOpcAviso := Aviso(STR0030,STR0080+CRLF+cMsgAux,aOptions,2) //"Atencao!"##"Ja existem apontamentos gravados para este recurso neste periodo. Verifique a hora informada"
								If len(aOptions)>1 .AND. nOpcAviso == 1
									// posiciona o registro jแ existente
									AFU->(dbGoTo(nRecApont))
									AxVisual("AFU",nRecApont,2)         
									// retorna para o registro anterior
									AFU->(dbGoTo(nRecAFU))								
								EndIf
								mv_par03:= "00:00"
							EndIf
						Enddo
						
						cHoraF := mv_par03
						lExecA320 := .T.
	
						aAdd(aGetCPos ,{"AFU_HORAF"  ,cHoraF,.T.})
						aAdd(aGetCPos ,{"AFU_OBS"    ,STR0050  ,}) //"Apontamento encerrado automaticamente."
					EndIf
				Endif
			EndIf
		EndIf

		If lExecA320
			lMsErroAuto = .F.
	
			If nOpc == n320Altera .AND. nRecAFU > 0
				// posiciona o registro
				AFU->(dbGoTo(nRecAFU))
			Else
				nOpc := 3
			EndIf
			
			// Apontamento de recursos atrav้s de "rotina automatica"
			bPMSA320 := {|| MSExecAuto({|a,b,c| lRet := PMSA320(a,b,,c)},aGetCpos, nOpc,__cUserID)}
	
			MsAguarde(bPMSA320,,cMensagem)
			
			If lMsErroAuto            
				
				// le o arquivo com as mensagens de erro
				cFileLog := AllTrim(NomeAutoLog())
				_cMsgErro := MemoRead(cFileLog)
				              
				aError:={}
                aAdd( aError ,"PMSA320:Error | "+STR0184+":" + cFileLog + " "+STR0166+":"+dtoc(Msdate())+" "+STR0167+":"+Time()) //"Arquivo"##"Data"##"Hora"
                aAdd( aError ,"                Thread Id: " + Alltrim(str(ThreadId())))                
                aAdd( aError ,"                "+STR0185+"  : "+__cUserID)            //"Codigo do Usuario"
                aAdd( aError ,"                Recno AF9: " + AllTrim(aTskAppont[2]))
                aAdd( aError ,"                Recno AFU: " + AllTrim(Str(nRecAfu)))
                aAdd( aError ,"                "+STR0186+"  : "+aTskAppont[1]) //"C๓digo do Recurso"
                aAdd( aError ,"                "+STR0187+" cHoraF : " + AllTrim(cHoraF)) //"Variavel"
                aAdd( aError ,"                "+STR0187+" nOpc   : " + AllTrim(str(nOpc))) //"Variavel"
                aAdd( aError ,"                "+STR0188+" : " + AllTrim(_cMsgErro)) //"Mensagem de Erro"
                aAdd( aError ,"PMSA320:Error | "+STR0184+":" + cFileLog ) //"Arquivo"
                
                For nCnt := 1 to len(aError)
					ConOut(aError[nCnt])
                Next nCnt

				_cErrDetail := ""
                For nCnt := 1 to len(aError)
					_cErrDetail += aError[nCnt]+chr(10)+chr(13)
                Next nCnt

				_cFile := "PMSSIM"+DTOS(date())+STRTRAN(TIME(), ":", "")+"ID"+Alltrim(str(ThreadId()))+".LOG"
				
				MemoWrite(_cFile,_cErrDetail)
				
				MostraErro()
				lRet := .F.
			Else
				lRet := .T.
			EndIf	
		EndIf

	EndIf			
	
	RestArea(aAreaAFU)
	RestArea(aAreaAF8)
	RestArea(aAreaAF9)
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} Inicia

Inicia o apontamento do recurno na tarefa selecionada. Gerando confirma็ใo para tarefa e 
apontamento para o recurso

IMPORTANTE: Esta funcao deve ser chamada considerando que o registro na tabela AF9 esta 
posicionado
@author desconhecido

@since 21/09/05

@version P10 R4

@param aTskAppont
@param oMsgBoard

@return nulo

/*/
Static Function Inicia(aTskAppont, oMsgBoard)
Local aArea    := GetArea()
Local aAreaAFF := AFF->(GetArea())
Local aAreaAF8 := {}
Local aAreaQI3 := {}
Local aAreaAN8 := {}
Local aGetCPos := {}
Local lOk := .T.

// Orizio >>>
If ValType( cMsgItem1 ) == "C"
	If !Empty( cMsgItem1 ) .AND. ( GetNewPar("MV_QTMKPMS",0) == 3 .OR. GetNewPar("MV_QTMKPMS",0) == 4 )
		Help( " ", 1, "PXEXEC",, cMsgItem1, 1, 0 ) //"Nao se pode rejeitar a primeira etapa!"
		Return
	EndIf
EndIf
// Orizio <<<

If Empty(aTskAppont[3]) // codigo de projeto em branco igual a recurso sem execuca็ใo de tarefa
	dbSelectArea("AF9")
	If Empty(AF9->AF9_DTATUI).AND. PmsVldFase("AF8",AF9->AF9_PROJET,"91")
		dbSelectArea("AFF")
		dbSetOrder(1)
		If dbSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+DTOS(MSDATE()) )
			nOpc := 4
		Else
			nOpc := 3
		EndIf
		aGetCpos	:= {	{"AFF_PROJET" ,AF9->AF9_PROJET,.F.},;
							{"AFF_REVISA" ,AF9->AF9_REVISA,.F.},;
							{"AFF_DESCRI" ,"",.F.},;
							{"AFF_TAREFA" ,AF9->AF9_TAREFA,.F.},;
							{"AFF_DATA"   ,MSDate(),.F.} ,;
							{"AFF_QUANT"  ,0.01,.F.} ,;
							{"AFF_USER"   ,__cUserID,.F.} }
							
		
		lMsErroAuto = .F.
		MSExecAuto({|x,y|PMSA311Aut(x,y)},aGetCpos,nOpc)
		If lMsErroAuto
			MostraErro()
			lOk := .F.
		EndIf
	ElseIf !PmsVlRelac(AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA, 1) 
		lOk := .F.
	EndIf

	If lOk .AND. ( GetNewPar("MV_QTMKPMS",0) == 3 .OR. GetNewPar("MV_QTMKPMS",0) == 4 )
		DbSelectArea( "AF8" )
		aAreaAF8 := AF8->(GetArea())
		DbSetOrder( 1 )
		If AF8->( DbSeek( xFilial( "AF8" ) + AF9->AF9_PROJET ) )
			If AF8->AF8_PAR002 == "2" // Controle de rejeicao por FNC
				DbSelectArea( "QI3" )
				aAreaQI3 := QI3->(GetArea())
				DbSetOrder( 2 )
				If QI3->( DbSeek( xFilial( "QI3" ) + AF9->AF9_ACAO + AF9->AF9_REVACA ) )
					If !Empty( QI3->QI3_ENCREA )
						Aviso( STR0177, STR0176, { "Ok" }, 2 ) //"A tarefa nใo pode ser executada pois o plano foi encerrado por uma tarefa paralela." ### "Plano Encerrado"
						lOk := .F.
					EndIf
				EndIf
				RestArea(aAreaQI3)
			EndIf
		EndIf
		RestArea(aAreaAF8)
	EndIf

	If lOk
	
		aTskAppont[1] := iIf(Empty(aTskAppont[1]) ,cLoginRec ,aTskAppont[1])
		aTskAppont[2] := str(AF9->(RecNo()))
		aTskAppont[3] := AF9->AF9_PROJET
		aTskAppont[4] := AF9->AF9_REVISA
		aTskAppont[5] := AF9->AF9_TAREFA
		aTskAppont[6] := TiraCharEsp(AllTrim(AF9->AF9_DESCRI))
		aTskAppont[7] := dtos(MSDate())
		aTskAppont[8] := Left(Time(),5)

		cMsg	:= Padr(STR0025,120) //"Recurso Ocioso"
		
		If GravaAFU(aTskAppont,STR0081) //"Iniciando apontamento do recurso..."
			GravaIni(aTskAppont)
			If !Empty(aTskAppont[3]) // codigo do projeto preenchido 
				cMsg	:= STR0023+Alltrim(aTskAppont[3])+"/"+AllTrim(aTskAppont[5])+"-"+Alltrim(aTskAppont[6])+STR0051+DTOC(STOD(aTskAppont[7]))+" "+aTskAppont[8] //"Em Execu็ใo : "###" - Iniciada : "
			EndIf

			// Projeto TDI TEGJD7 - Atualizacao do recurso atual no chamado
			QNCGRVOPE()  // continda no QNCXFUN
		Else
			Aviso(STR0082,STR0083,{"Ok"},2) //"Apontamento jแ existe"##"Existem apontamentos para esta dia e horario. Verifique."
			aTskAppont := NewIni()
		EndIf
	EndIf
	If Type("bRfshGant1")<>"U"
		Eval(bRfshGant1) 
	Endif
	
	If !(oMsgBoard ==NIL)
		oMsgBoard:Refresh() 
	EndIf
EndIf

RestArea(aAreaAFF)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaIni  บAutor  ณMicrosiga           บ Data ณ  09/21/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GravaIni(aTskAppont)
Local cRecurso  := If(!Empty(aTskAppont[1]),aTskAppont[1] ,cLoginRec)

	// Se o array estiver vazio, apaga registro no AFW ou entao grava para controle
	If Empty( aTskAppont[2] )
		DbSelectArea( "AFW" )
		AFW->( DbSetOrder( 1 ) )
		If AFW->( DbSeek( xFilial( "AFW" ) + cRecurso ) )
			RecLock( "AFW" )
			AFW->( DbDelete() )
			MsUnLock()
		EndIf
	Else
		DbSelectArea( "AFW" )
		RecLock( "AFW", .T. )
		AFW->AFW_FILIAL 	:= xFilial( "AFW" )
		AFW->AFW_RECURS 	:= cRecurso
		AFW->AFW_PROJET 	:= aTskAppont[3]
		AFW->AFW_TAREFA 	:= aTskAppont[5]
		AFW->AFW_DATA   	:= StoD( aTskAppont[7] )
		AFW->AFW_HORA   	:= aTskAppont[8]
		MsUnLock()
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadIni   บAutor  ณMicrosiga           บ Data ณ  09/21/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadIni( cRecurso )
Local aRet		:= {}
Local aAreaAF9	:= AF9->( GetArea() )

Default cRecurso := ""

cRecurso	:= If( !Empty( cRecurso ), cRecurso, cLoginRec )
aRet		:= NewIni()

DbSelectArea( "AFW" )
AFW->( DbSetOrder( 1 ) )
If AFW->( DbSeek( xFilial( "AFW" ) + cRecurso ) )
	DbSelectArea( "AF8" )
	AF8->( DbSetOrder( 1 ) )
	If AF8->( DbSeek( xFilial( "AF8" ) + AFW->AFW_PROJET ) )
		DbSelectArea( "AF9" )
		AF9->( DbSetOrder( 1 ) )
		If AF9->( DbSeek( xFilial( "AF9" ) + AFW->AFW_PROJET + AF8->AF8_REVISA + AFW->AFW_TAREFA ) )
			aRet[1]	:= cRecurso
			aRet[2]	:= Str( AF9->( RecNo() ) )
			aRet[3]	:= AFW->AFW_PROJET
			aRet[4]	:= AF8->AF8_REVISA
			aRet[5]	:= AFW->AFW_TAREFA
			aRet[6]	:= TiraCharEsp( AllTrim( AF9->AF9_DESCRI ) )
			aRet[7]	:= DtoS(AFW->AFW_DATA) //DtoS( MSDate() )
			aRet[8]	:= AFW->AFW_HORA //Left( Time(), 5 )
		EndIf
	EndIf
EndIf	

If Empty( aRet[1] )
	aRet[1] := cRecurso
EndIf

RestArea( aAreaAF9 )
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNewIni    บAutor  ณMicrosiga           บ Data ณ  09/21/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ[ 1] - codigo do recurso                                    บฑฑ
ฑฑบ          ณ[ 2] - numero do registro da tarefa                         บฑฑ
ฑฑบ          ณ[ 3] - Codigo do Projeto                                    บฑฑ
ฑฑบ          ณ[ 4] - Codigo da revisao                                    บฑฑ
ฑฑบ          ณ[ 5] - codigo da tarefa                                     บฑฑ
ฑฑบ          ณ[ 6] - Descricao da tarefa                                  บฑฑ
ฑฑบ          ณ[ 7] - Data de inicio do apontamento                        บฑฑ
ฑฑบ          ณ[ 8] - Hora de inicio do apontamento                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NewIni()
Return({"","","","","","",DTOS(CTOD("01/01/00")),Left( Time(), 5 )})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinaliza  บAutor  ณMicrosiga           บ Data ณ  09/21/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Finaliza(aTskAppont,oMsgBoard,lRejeicao,aMotivos)
Local lOk 	   := .T.
Local aNewTask := NewIni()
Local cTarefa  := Upper(AllTrim(aTskAppont[6]))  
Local nOpc     := 0
Local aArea    := GetArea()
Local aAreaAF9 := {}
Local aAreaAFF := {}
Local aAreaAN8 := {}
Local aGetCPos := {}
Local lRejTarefa	:= .T.
Local lRejeit
Local lAprova
//Local lEncerr
Local lDevolv
Local nHoras
Local cMotivo
Local nOpcApr
Local nRecAux
Local cChave
Local cTrfOri
Local aCalcHr

// Realiza a notificacao da rejeicao
Local aLista     := {}
Local aCntsObrig := {}
Local aMotivo	 := {}
Local cStrEnvio	 := ""
Local cMsgEml	 := ""
Local nInc		 := 0
Local aRecurs	 := {}

Local nRecAFF

Private INCLUI := .F.

DEFAULT lRejeicao := .F.
DEFAULT aMotivos := {}

If !Empty(aTskAppont[3])

	dbSelectArea("AF9")
	aAreaAF9 := AF9->(GetArea())
	dbSetOrder(1)
	If dbSeek(xFilial("AF9")+aTskAppont[3]+aTskAppont[4]+aTskAppont[5])
		lAprova := .F.
		lRejeit := .F.
		If lRejTarefa
			If lRejeicao
				lRejeit := .T.
			EndIf

			dbSelectArea("AN8")
			aAreaAN8 := AN8->(GetArea())
			AN8->(dbSetOrder(1)) //AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA+DTOS(AN8_DATA)+AN8_HORA+AN8_TRFORI
			If AN8->( MsSeek( xFilial("AN8")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA) ) )
				Do While !AN8->(Eof()) .And. AN8->(AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA)==xFilial("AN8")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
					If AN8->AN8_STATUS == "1"
						lRejeit := .F.
					EndIf

					If Empty(AN8->AN8_STATUS)
						lAprova := .T.
						nHoras := AN8->AN8_HORAS
						cMotivo := E_MSMM(AN8->AN8_CODMEM)
					EndIf
					AN8->(dbSkip())
				EndDo
			EndIf
			RestArea(aAreaAN8)
		EndIf
		If lAprova
			lOk := .F.
			lDevolv := .T.
			cTrfOri := ""
			nOpcApr := AprvRejeic(AF9->AF9_TAREFA, nHoras, @aMotivo)
			If nOpcApr==1 .Or. nOpcApr==2  // 1=Aceitou; 2=Rejeitou
				aAreaAN8 := AN8->(GetArea())
				AN8->(DbSetOrder(1))
				If AN8->( MsSeek( xFilial("AN8")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA) ) )
					Do While !AN8->(Eof()) .And. AN8->(AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA)==xFilial("AN8")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
						If Empty(AN8->AN8_STATUS)
							nRecAux := AN8->(RecNo())
							cChave  := xFilial("AN8")+AN8->(AN8_PROJET+AN8_REVISA+AN8_TAREFA+DTOS(AN8_DATA))
							AN8->( MsSeek( cChave ) )
							Do While !AN8->(Eof()) .And. AN8->(AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA+DTOS(AN8_DATA))==cChave
								If AN8->AN8_STATUS=="1"
									lDevolv := .F.
								EndIf
								AN8->(dbSkip())
							EndDo
							AN8->(dbGoto(nRecAux))
							cTrfOri := AN8->AN8_TRFORI
							RecLock("AN8",.F.)
							AN8->AN8_STATUS := IIf(nOpcApr==1,'1','2')
							MsUnlock()
							If IsInCallStack("PMSLSTREJ")
								If __TRB->AN8_FILIAL==AN8->AN8_FILIAL .AND. __TRB->AN8_PROJET==AN8->AN8_PROJET .AND. __TRB->AN8_REVISA==AN8->AN8_REVISA .AND. __TRB->AN8_TAREFA==AN8->AN8_TAREFA
							      If __TRB->(RecLock("__TRB",.F.))
							      	__TRB->(DbDelete())
							      	MsUnlock()
							      Endif
								Endif
							Endif
							lOk := .T.
						EndIf
						AN8->(dbSkip())
					EndDo
				EndIf
				If nOpcApr==1
					dbSelectArea("AF9")
					RecLock("AF9",.F.)
					AF9->AF9_TPHORA := '2'
					MsUnlock()
					If !Empty(cTrfOri) .And. AF8->AF8_PAR003=="1"
						nRecAux:=AF9->(RecNo())
						If AF9->( MsSeek( xFilial("AF9")+AF9->(AF9_PROJET+AF9_REVISA+cTrfOri) ) )
							aCalcHr	:= PMSADDHrs( AF9->AF9_START, AF9->AF9_HORAI, AF8->AF8_CALEND, AF9->AF9_HUTEIS+nHoras, AF9->AF9_PROJET,Nil )
							If !Empty( aCalcHr ) .And. nHoras > 0
								RecLock("AF9",.F.)
								AF9->AF9_FINISH := aCalcHr[1]
								AF9->AF9_HORAF  := aCalcHr[2]
								AF9->AF9_HUTEIS := AF9->AF9_HUTEIS+nHoras
								MsUnlock()
							EndIf
						EndIf
						AF9->(dbGoTo(nRecAux))
					EndIf
				EndIf
				If nOpcApr==2
					dbSelectArea("AFF")
					dbSetOrder(1)
					If AFF->( MsSeek(xFilial("AFF")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+DTOS(dDatabase)) )
						nRecAFF := AFF->(Recno())
						RegToMemory("AFF", .F.)
						M->AFF_PERC   := 100
						M->AFF_QUANT  := 1
					Else
						nRecAFF := nil
						RegToMemory("AFF", .T.)
						M->AFF_FILIAL := xFilial("AFF")
						M->AFF_DATA   := dDataBase
						M->AFF_PERC   := 100
						M->AFF_QUANT  := 1
						M->AFF_PROJET := AF9->AF9_PROJET
						M->AFF_REVISA := AF9->AF9_REVISA
						M->AFF_TAREFA := AF9->AF9_TAREFA
					EndIf
					PMS311Grava(.F.,nRecAFF)
				EndIf
				RestArea(aAreaAN8)
			Else
				// cancelou a operacao de rejeicao entao deve limpar o vetor para que a tarefa nao fique marcada
				aTskAppont[2] 	:= ""
				aTskAppont[3] 	:= ""
				aTskAppont[4] 	:= ""
				aTskAppont[5] 	:= ""
				aTskAppont[6] 	:= ""
				aTskAppont[7] 	:= ""
				aTskAppont[8] 	:= ""
			EndIf
		EndIf

		If lRejeit .AND. PMSCtrlRej( AF9->AF9_PROJET )

			// Realiza a notificacao da rejeicao
			// Obtem a lista de contatos envolvidos na tarefa a partir das predecessoras
			PegaPredec( AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA, AE8->AE8_RASTRO, @aRecurs )
			For nInc := 1 To Len( aRecurs )
				DbSelectArea( "AE8" )
				AE8->( DbSetOrder( 1 ) )
				If AE8->( DbSeek( xFilial( "AE8" ) + aRecurs[nInc] ) )
					aAdd( aLista, { AE8->AE8_DESCRI, Lower( AE8->AE8_EMAIL ) } )
				EndIf
			Next

			// PmsMonFin: Ponto de entrada para customizar a lista de contatos
			If ExistBlock( "PmsMonFin" )
				aLista := ExecBlock( "PmsMonFin", .F., .F., { aLista } )
			EndIf

			// PmsMon07: Ponto de entrada para customizar a lista de contatos obrigatorios
			If ExistBlock("PMSMON07")
				aCntsObrig := ExecBlock("PMSMON07",,,{aLista, aCntsObrig})
				If ValType(aCntsObrig) != "A"
					aCntsObrig := {}
				EndIf
			EndIf

	        // Envia o e-mail para os envolvidos
			cStrEnvio := PmsSlEmail( aLista, aCntsObrig )
		
			
			If !Empty( cStrEnvio )
				cMsgEml	:= STR0162 + chr(13) + chr(10)
				cMsgEml	+= STR0170 + AF9->AF9_PROJET + chr(13) + chr(10)
				cMsgEml	+= STR0171 + AllTrim( AF9->AF9_TAREFA ) + "-" + AllTrim( AF9->AF9_DESCRI ) + chr(13) + chr(10)

				// PmsMonEml: Ponto de entrada para customizar o texto do email
				If ExistBlock( "PmsMonEml" )
					cMsgEml := ExecBlock( "PmsMonEml", .F., .F., { cMsgEml, aMotivos } )
				EndIf

				PMSSendMail(	STR0162,; 					// Assunto
								cMsgEml,;					// Mensagem
								cStrEnvio,;					// Destinatario
								"",;						// Destinatario - Copia
								.F. )						// Se requer dominio na autenticacao
			EndIf
		EndIf
		
		If lOk .And. !lRejeit
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica se essa tarefa jแ foi encerrada anteriormente devido ao problema de arquivo .INI que permite duas finaliza็๕es consecutivas                                           ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !Empty(AF9->AF9_DTATUF) .AND. !IsInCallStack("PMSLSTREJ") .OR. !Empty(AF9->AF9_DTATUF) .AND. IsInCallStack("PMSLSTREJ") .AND. nOpcApr==2
				MsgInfo(STR0052+cTarefa+STR0053,STR0054) //"A tarefa "###" encontra-se finalizada. Execute um <REFRESH> em seu monitor de tarefas."###"Aten็ใo"
				aTskAppont := aClone(aNewTask)
				GravaIni(aTskAppont)
				cMsg 	:= Padr(STR0025,120) //"Recurso Ocioso"
				If !(oMsgBoard == NIL)
					oMsgBoard:Refresh()
				EndIf
				lOk := .F.
			//
			// se a tarefa nใo foi encerrada, isto ้, a data de termino real nใo foi preenchido
			//
			Else
				dbSelectArea("AFF")
				aAreaAFF := AFF->(GetArea())
				dbSetOrder(1)
				If dbSeek(xFilial("AFF")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+DTOS(MSDATE()) )
					ALTERA 	:= .T.
					INCLUI 	:= .F.
					nOpc := 4
				Else
					ALTERA 	:= .F.
					INCLUI 	:= .T.
					nOpc := 3
				EndIf
				If lRejeicao
					aGetCpos	:= {	{"AFF_PROJET" ,AF9->AF9_PROJET,.F.},;
										{"AFF_REVISA" ,AF9->AF9_REVISA,.F.},;
										{"AFF_DESCRI" ,AF9->AF9_DESCRI,.F.},;
										{"AFF_TAREFA" ,AF9->AF9_TAREFA,.F.},;
										{"AFF_DATA"   ,MSDate(),.F.} ,;
										{"AFF_QUANT"  ,0.01,.F.} ,;
										{"AFF_USER"   ,__cUserID,.F.} }
					lMsErroAuto = .F.
					MSExecAuto({|x,y|PMSA311Aut(x,y)},aGetCpos,nOpc)
					If lMsErroAuto
						MostraErro()
						lOk := .F.
					EndIf
				Else
				  If !IsInCallStack("PMSLSTREJ")
						lOk := PMSA311( nOpc ,{	{"AFF_PROJET",AF9->AF9_PROJET,.F.},;
												{"AFF_REVISA",AF9->AF9_REVISA,.F.},;
												{"AFF_TAREFA",AF9->AF9_TAREFA,.F.},;
												{"AFF_DESCRI",AF9->AF9_DESCRI,.F.},;
												{"AFF_DATA"  ,MsDate(),.F.}	 })
					Else
						aGetCpos	:= {	{"AFF_PROJET" ,AF9->AF9_PROJET,.F.},;
											{"AFF_REVISA" ,AF9->AF9_REVISA,.F.},;
											{"AFF_DESCRI" ,AF9->AF9_DESCRI,.F.},;
											{"AFF_TAREFA" ,AF9->AF9_TAREFA,.F.},;
											{"AFF_DATA"   ,MSDate(),.F.} ,;
											{"AFF_QUANT"  ,0.90,.F.} ,;
											{"AFF_USER"   ,__cUserID,.F.} }
						lMsErroAuto = .F.
						MSExecAuto({|x,y|PMSA311Aut(x,y)},aGetCpos,nOpc)
						If lMsErroAuto
							MostraErro()
							lOk := .F.
						EndIf
						AFD->(DbSetOrder(2))
						If lOk .and. AFD->(DbSeek(xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)) //BUSCA PREDECESSORA
			  				If AFF->(dbSeek(xFilial()+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA+DTOS(MSDATE()) ))
								ALTERA 	:= .T.
								INCLUI 	:= .F.
								nOpc := 4
							Else
								ALTERA 	:= .F.
								INCLUI 	:= .T.
								nOpc := 3
							EndIf
                     	If AF9->(DbSeek(xFilial("AF9")+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA)) .AND. AFD->AFD_TAREFA<>cTrfOri
								aGetCpos	:= {	{"AFF_PROJET" ,AF9->AF9_PROJET,.F.},;
													{"AFF_REVISA" ,AF9->AF9_REVISA,.F.},;
													{"AFF_DESCRI" ,AF9->AF9_DESCRI,.F.},;
													{"AFF_TAREFA" ,AF9->AF9_TAREFA,.F.},;
													{"AFF_DATA"   ,MSDate(),.F.} ,;
													{"AFF_QUANT"  ,0.90,.F.} ,;
													{"AFF_USER"   ,__cUserID,.F.} }
								lMsErroAuto = .F.
								MSExecAuto({|x,y|PMSA311Aut(x,y)},aGetCpos,nOpc)
								If lMsErroAuto
									MostraErro()
									lOk := .F.
								EndIf
			              	If lOk
							  		AFD->(DbSkip())
									While lOk .and. !AFD->(EOF()) .and. (AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA==AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA).AND. AFD->AFD_TAREFA<>cTrfOri
	                           		If AF9->(DbSeek(xFilial("AF9")+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA))
											If AFF->(DbSeek(xFilial()+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA+DTOS(MSDATE()) ))
												ALTERA 	:= .T.
												INCLUI 	:= .F.
												nOpc := 4
											Else
						               		ALTERA 	:= .F.
												INCLUI 	:= .T.
							  					nOpc := 3
											Endif
											aGetCpos	:= {	{"AFF_PROJET" ,AF9->AF9_PROJET,.F.},;
																{"AFF_REVISA" ,AF9->AF9_REVISA,.F.},;
																{"AFF_DESCRI" ,AF9->AF9_DESCRI,.F.},;
																{"AFF_TAREFA" ,AF9->AF9_TAREFA,.F.},;
																{"AFF_DATA"   ,MSDate(),.F.} ,;
																{"AFF_QUANT"  ,0.90,.F.} ,;
																{"AFF_USER"   ,__cUserID,.F.} }
											lMsErroAuto = .F.
											MSExecAuto({|x,y|PMSA311Aut(x,y)},aGetCpos,nOpc)
											If lMsErroAuto
												MostraErro()
												lOk := .F.
											EndIf
                              		Endif
                              		AFD->(DbSkip())
                					Enddo
           					Endif
                     	Endif
						Endif
					Endif
				EndIf
				RestArea(aAreaAFF)
			EndIf
		EndIf

		If lOk
			//
			// mesmo se houver erro na gravacao do apontamento, este serแ encerrado
			//
			lOk := GravaAFU(aTskAppont,STR0084) //"Encerrando apontamento do recurso..."
			if ! lOk
				nOpcApr := 0  // se falhou na gravacao da AFU deve cancelar tudo
			Endif

			if nOpcApr <> 0
				aTskAppont[2] 	:= ""
				aTskAppont[3] 	:= ""
				aTskAppont[4] 	:= ""
				aTskAppont[5] 	:= ""
				aTskAppont[6] 	:= ""
				aTskAppont[7] 	:= ""
				aTskAppont[8] 	:= ""

				GravaIni(aTskAppont)
			Endif

			If lAprova .And. nOpcApr==1
				// Localiza o evento de notificacao do projeto
				DbSelectArea("AN6")
				AN6->( DbSetOrder(1) )
				AN6->( DbSeek( xFilial("AN6") + AFU->AFU_PROJET + "000000000000006" ) )
				Do While !AN6->(Eof()) .And. xFilial("AN6") + AFU->AFU_PROJET == AN6->( AN6_FILIAL + AN6_PROJET ) .And. AN6->AN6_EVENT == "000000000000006"
					// Se o campo funcao de usuario estiver preenchido deve Macroexecutar
					If !Empty( AN6->AN6_USRFUN )
						&(AN6->AN6_USRFUN)
					EndIf
					
					// Obtem o assunto da notificacao
					cAssunto := STR0163 // "Notifica็ใo de Evento - Aprova็ใo de Rejei็ใo de Tarefa"
					If !Empty( AN6->AN6_ASSUNT )
						cAssunto := AN6->AN6_ASSUNT
					EndIf
					
					// macro executa para obter o titulo
					If Left( AllTrim( AN6->AN6_ASSUNT ), 1 ) = "="
						cAssunto := Right( cAssunto, Len( cAssunto ) -1 )
						cAssunto := &(cAssunto)
					EndIf
					
					// Obtem o destinatario
					cTo	:= PASeekPara( AE8->AE8_RECURS, AN6->AN6_PARA )
					cCC	:= PASeekPara( AE8->AE8_RECURS, AN6->AN6_COPIA )
					
					// Cria a mensagem
					cMsgEml := AN6->AN6_MSG
					
					// macro executa para obter a mensagem
					If Left( AllTrim( AN6->AN6_MSG ), 1 ) = "="
						cMsgEml := Right( cMsgEml, Len( cMsgEml ) -1 )
						cMsgEml := &(cMsgEml)
					EndIf
					
			        //Deve ser gerada uma notifica็ใo de evento do projeto encaminhando um e-mail para o superior do recurso;
					If !Empty( cTO )
						PMSSendMail(	cAssunto,; 						// Assunto
										cMsgEml,;						// Mensagem
										cTO,;							// Destinatario
										cCC,;							// Destinatario - Copia
										.F. )							// Se requer dominio na autenticacao
					EndIf
					
					AN6->( DbSkip() )
					
				EndDo
		
			EndIf

			If lAprova .And. nOpcApr==2

				// Localiza o evento de notificacao do projeto
				DbSelectArea("AN6")
				AN6->( DbSetOrder(1) )
				AN6->( DbSeek( xFilial("AN6") + AFU->AFU_PROJET + "000000000000006" ) )
				Do While !AN6->(Eof()) .And. xFilial("AN6") + AFU->AFU_PROJET == AN6->( AN6_FILIAL + AN6_PROJET ) .And. AN6->AN6_EVENT == "000000000000006"
					// Se o campo funcao de usuario estiver preenchido deve Macroexecutar
					If !Empty( AN6->AN6_USRFUN )
						&(AN6->AN6_USRFUN)
					EndIf
					
					// Obtem o assunto da notificacao
					cAssunto := STR0164 // "Notifica็ใo de Evento - Rejei็ใo de Rejei็ใo de Tarefa"
					If !Empty( AN6->AN6_ASSUNT )
						cAssunto := AN6->AN6_ASSUNT
					EndIf
					
					// macro executa para obter o titulo
					If Left( AllTrim( AN6->AN6_ASSUNT ), 1 ) = "="
						cAssunto := Right( cAssunto, Len( cAssunto ) -1 )
						cAssunto := &(cAssunto)
					EndIf
					
					// Obtem o destinatario
					cTo	:= PASeekPara( AE8->AE8_RECURS, AN6->AN6_PARA )
					cCC	:= PASeekPara( AE8->AE8_RECURS, AN6->AN6_COPIA )
					
					// Cria a mensagem
					cMsgEml := AN6->AN6_MSG
					
					// macro executa para obter a mensagem
					If Left( AllTrim( AN6->AN6_MSG ), 1 ) = "="
						cMsgEml := Right( cMsgEml, Len( cMsgEml ) -1 )
						cMsgEml := &(cMsgEml)
					EndIf
					
			        //Deve ser gerada uma notifica็ใo de evento do projeto encaminhando um e-mail para o superior do recurso;
					If !Empty( cTO )
						PMSSendMail(	cAssunto,; 						// Assunto
										cMsgEml,;						// Mensagem
										cTO,;							// Destinatario
										cCC,;							// Destinatario - Copia
										.F. )							// Se requer dominio na autenticacao
					EndIf
					
					AN6->( DbSkip() )
					
				EndDo
		
			EndIf

			// Projeto TDI - TELXEZ Anexo no processo de rejeicao
			// atualizar o status do recurso somente se foi tudo ok
			If lOk
				cMsg := Padr(STR0025,120) //"Recurso Ocioso"
				If !(oMsgBoard == NIL)
					oMsgBoard:Refresh()
				EndIf
			Endif

			If Type("bRfshGant1")<>"U"
				Eval(bRfshGant1)
			Endif
		EndIf
	Else
		aTskAppont := aClone(aNewTask)
		GravaIni(aTskAppont)
		cMsg := Padr(STR0025,120) //"Recurso Ocioso"
		If !(oMsgBoard == NIL)
			oMsgBoard:Refresh()
		EndIf
	Endif
	RestArea(aAreaAF9)
Else
	MsgInfo(STR0055,STR0054) //"Nใo existe tarefa em execu็ใo no momento."###"Aten็ใo"
	If !(oMsgBoard == NIL)
		cMsg 	:= Padr(STR0025,120) //"Recurso Ocioso"
		oMsgBoard:Refresh()
	EndIf
EndIf

RestArea(aArea)

Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTiraCharEspบAutor ณMicrosiga           บ Data ณ  09/21/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TiraCharEsp(cText)
Local aTextos	:=	{{"'",'"'},;
					 {CHR(10),""},;
					 {CHR(13)," "}}
Local cRet	:=	""
Local nX		:=	0
Local nPosChr:= 0

cText	:=	Alltrim(cText)
For nX := 1 To Len(cText)
	If (nPosChr	:=	Ascan(aTextos,{|x| x[1]==Substr(cText,nX,1) })) > 0
		cRet	+=	aTextos[nPosChr][2]
	Else
		cRet	+=	Substr(cText,nX,1)
	Endif
Next nX

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsFmtHr บAutor  ณReynaldo Miyashita  บ Data ณ  26/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ formata a hora informada conforme MV_PREVISA               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Hora formatada                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PmsFmtHr(cHora)
Local nPrecisao := GetMV("MV_PRECISA")
Local nInterv     := 60 / nPrecisao
Local nX
If Len(Alltrim(cHora)) == 4 .And. Substr(cHora,3,1) <> ":"
	cHora	:=	Substr(cHora,1,2)+":"+Substr(cHora,3,2)
Endif
	For nX := 1 to nPrecisao
		Do  Case 
			Case nX == 1
				 If Val(Substr(cHora,4,2)) < nInterv
					 If Val(Substr(cHora,4,2)) < nInterv/2 
					    cHora := Substr(cHora,1,3)+"00"
					    exit
					 Else
					    cHora := Substr(cHora,1,3)+Iif(Len(Alltrim(Str(nInterv)))>1,Alltrim(Str(nInterv)),"0"+Alltrim(Str(nInterv)))
					    exit                     //Incluido IIF para que a hora seja passada com o "0" do minuto a esquerda "14:'0'1"
					 EndIf                       //Antes, estava sendo retornada a hora sem o "0", ou seja, "14:1", que o sistema considerava como "14:10"
			     EndIf
	
			Case nX > 1 .AND. nX < nPrecisao
				 If Val(Substr(cHora,4,2)) > (nInterv*(nX-1)) .AND. Val(Substr(cHora,4,2)) < (nInterv*nX)
				    If Val(Substr(cHora,4,2)) < ((nInterv*nX)-(nInterv/2))
				       cHora := Substr(cHora,1,3)+Iif(Len(Alltrim(Str(nInterv*(nX-1))))>1,Alltrim(Str(nInterv*(nX-1))),"0"+Alltrim(Str(nInterv*(nX-1))))
				       exit
					Else
				       cHora := Substr(cHora,1,3)+Iif(Len(Alltrim(Str(nInterv*nX)))>1,Alltrim(Str(nInterv*nX)),"0"+Alltrim(Str(nInterv*nX)))
				       exit							//Incluido IIF para que a hora seja passada com o "0" do minuto a esquerda "14:'0'1"
				 	EndIf								//Antes, estava sendo retornada a hora sem o "0", ou seja, "14:1", que o sistema considerava como "14:10"
				 EndIf
	
			Case nX == nPrecisao
				 If Val(Substr(cHora,4,2)) > (nInterv*(nX-1)) .AND. Val(Substr(cHora,4,2)) < (nInterv*nX)
				 	If Val(Substr(cHora,4,2)) < ((nInterv*nX)-(nInterv/2)) .AND. Val(Substr(cHora,4,2)) > nInterv*(nX-1)
				       cHora := Substr(cHora,1,3)+Iif(Len(Alltrim(Str(nInterv*(nX-1))))>1,Alltrim(Str(nInterv*(nX-1))),"0"+Alltrim(Str(nInterv*(nX-1))))
				       exit							//Incluido IIF para que a hora seja passada com o "0" do minuto a esquerda "14:'0'1"
				    Else								//Antes, estava sendo retornada a hora sem o "0", ou seja, "14:1", que o sistema considerava como "14:10"
				       cHora := Soma1(Substr(cHora,1,2))+":00"
				       exit
				    EndIf
				 EndIf
		End Case
	Next nX

	//
	// Conforme ISO 8601, o formato de hora de um dia deve ser efetuado da seguinte forma:
	//
	// Primeira hora do dia ้ 00:00 
	// Ultima hora do dia ้ 23:59
	//
	// Sempre que se estiver se referindo a 1 dia.
	//
//	If cHora == "24:00"
//		cHora := "23:59"
//EndIf
	
Return cHora


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSMONIT  บAutor  ณMicrosiga           บ Data ณ  07/14/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PMSQNCDOC()
Local aArea := GetArea()
Local aAreaAF9 := {}
Local lRetIsOk := .T.
Private cMatFil:= xFilial("AF9") 
Private cMatCod
Private aHeadAne  := {}      
                    
dbSelectArea("AF9") 
aAreaAF9 := GetArea()
If !Empty(AF9->AF9_ACAO) .AND. !Empty(AF9->AF9_REVACA) .AND. !Empty(AF9->AF9_TPACAO)
	lRetIsOk := QNCVldDocs(AF9->AF9_ACAO,AF9->AF9_TPACAO,AF9->AF9_REVACA,.F.)
EndIf
     
RestArea(aAreaAF9)
RestArea(aArea)         

Return lRetIsOk


Static Function VldApphora(cRecurso ,dApont ,cHoraI ,cHoraF ,nRecAFU)
Local aArea		:= GetArea()
Local aAreaAFU	:= {}
Local nReturn	:= 0

DEFAULT nRecAFU := 0
     
	dbSelectArea("AFU")
	aAreaAFU := GetArea()
	dbSetOrder(3)
	dbSeek(xFilial("AFU")+"1"+cRecurso+DTOS(dApont))
	While !Eof() .And. xFilial("AFU")+"1"+cRecurso+DTOS(dApont)==;
						AFU->AFU_FILIAL+AFU->AFU_CTRRVS+AFU->AFU_RECURS+DTOS(AFU->AFU_DATA)
		If (nRecAFU != RecNo()) .And. ;
		   (;
			 (Substr(cHoraF,1,2) + Substr(cHoraF,4,2) > Substr(AFU->AFU_HORAI,1,2) + Substr(AFU->AFU_HORAI,4,2)   .And.;
			  Substr(cHoraF,1,2) + Substr(cHoraF,4,2) < Substr(AFU->AFU_HORAF,1,2) + Substr(AFU->AFU_HORAF,4,2));
			 .Or.;
			 (Substr(cHoraF,1,2)  + Substr(cHoraF,4,2)  >= Substr(AFU->AFU_HORAF,1,2) + Substr(AFU->AFU_HORAF,4,2) .And.;
			  Substr(cHoraI,1,2) + Substr(cHoraI,4,2) < Substr(AFU->AFU_HORAF,1,2) + Substr(AFU->AFU_HORAF,4,2));
		   )  
		   	nReturn := AFU->(Recno())
			Exit
		EndIf
		dbskip()
	EndDo
	
	RestArea(aAreaAFU)
	RestArea(aArea)
	
Return nReturn

// Devido ao ADVPL gerenciar 999 objetos em um objeto MSDialog foi adicionado esta validacao para diminuir o estouro de objetos 
// que gera error.log.
// 
// Em alguns testes realizados para gerar a janela com quadros, combos e labels ้ necessแrio cerca de 200 objetos 
// (aproximadamente 20% dos 999) que varia conforme periodo selecionado
// E para cada barra de gantt ้ necessแrio cerca 15 objetos considerando 1 relacionamento inicio no fim.
//
// Logo, supondo que teremos cerca de 70% dos 999 objetos para desenhar as barras de gantt, verifico a quantidade 
// de elementos no array aGannt que contem cada tarefa e multiplico por 15. Se este resultado for maior que os 70% 
// livres. Apresento uma mensagem de alerta e aborto o processo.
//
// 24.09.2008 - SIGA2031
//
Static Function GanttObjMax(aGantt)
Local lRet := .T.
Local nTskMax := int((999*0.65)/10)
Local nCnt := 0
Local aGntTmp := {}
Local lMsg := .F.

// se a quantidade de tarefas permitidas forem menor que o filtro solicitado
If nTskMax < (Len(aGantt))
	if nQtdObjMax == 0  // variavel estatica no inicio do programa
		nQtdObjMax := nTskMax
		lMsg := .T.
	Endif	

	if lMsg
		Aviso(STR0056,STR0057,{STR0022},2) //"Excedido a quantidade de tarefas"###"Parโmetros informados ultrapassam a quantidade mแxima de tarefas permitidas, serแ apresentado somente o permitido"###"Fechar"
	Endif	
		For nCnt := 1 To nTskMax
			aAdd(aGntTmp ,aGantt[nCnt])
		Next nCnt
		aGntTmp := aClone(aGantt)
		lRet := .F.
	EndIf
	
Return lRet

Static Function GttActive(oObject,lActive)

DEFAULT lActive := .T.

	If lActive
		oObject:Enable()
		Eval(bRfshGantt)
	Else
		oObject:Disable()
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmMonSwTskบAutor  ณMarcelo Akama       บ Data ณ  10/23/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PmMonSwTsk()
Local aArea    := GetArea()
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAFA := AFA->(GetArea())

Local aAreaAE8 := AE8->(GetArea())
Local aDados   := {}
Local nX
Local cAux
Local cObfNRecur := IIF(FATPDIsObfuscate("AE8_DESCRI",,.T.),FATPDObfuscate("RESOURCE NAME","AE8_DESCRI",,.T.),"")        


AF9->(dbGoTo(nRecNo))

Aadd(aDados,{ STR0060, {AF9->AF9_TAREFA, CLR_BLACK} })
Aadd(aDados,{ STR0061, {AF9->AF9_DESCRI, CLR_BLACK} })
Aadd(aDados,{ STR0062, {Alltrim(str(AF9->AF9_HDURAC)), CLR_BLACK} })

dbSelectArea("AE8")
AE8->(dbSetOrder(1))
dbSelectArea("AFA")
AFA->(dbSetOrder(5))
AFA->(dbSeek(xFilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)))
Do While !AFA->(Eof()) .And. AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)==xFilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA) .And. empty(AFA->AFA_RECURS)
	AFA->(dbSkip())
EndDo
nX := 0
Do While !AFA->(Eof()) .And. AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)==xFilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
	nX++
	If AE8->(dbSeek(xFilial("AF8")+AFA->AFA_RECURS))
		cAux := IIF(Empty(cObfNRecur),AE8->AE8_DESCRI,cObfNRecur)  
	Else
		cAux := AFA->AFA_RECURS
	EndIf
	Aadd(aDados,{ STR0063+' '+StrZero(nX,4), {cAux, CLR_BROWN} })
	AFA->(dbSkip())
EndDo

If ExistBlock("PMSMONIT")
	aDados:= ExecBlock("PMSMONIT",.F.,.F.,{aDados})
EndIf

PmsDispBox(aDados,2,STR0048,{40,120},/*cBackColor*/,1,/*cClrLegend*/,RGB(250,250,250)/*,oDlg,nColIni,nLinIni,lAllClient,cDescri,cTextSay*/)

RestArea(aAreaAE8)
RestArea(aAreaAFA)
RestArea(aAreaAF9)
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMBC     บAutor  ณMarcos S. Lobo      บ Data ณ  08/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPermite a visualiza็ใo/Rastro do Plano, FNC e Chamado a     บฑฑ
ฑฑบ          ณpartir de tarefa no PMS.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SIMAF9View(_nRecAF9)

Local _aAreaOri := GetArea()
Local _aAreaAF9 := {}
Local _nOpcSel	:= 1 

If Type("INCLUI") <> "L"
	Private INCLUI := .F.
EndIf

If Type("ALTERA") <> "L"
	Private ALTERA := .F.
EndIf

dbSelectArea("AF9")
_aAreaAF9 := GetArea()
DEFAULT _nRecAF9 := AF9->(Recno())
If _nRecAF9 > 0
	//
	// Posiciona na tarefa
	//
	AF9->(MsGoto(_nRecAF9))
	
	If !Empty(AF9->AF9_ACAO)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPosiciona na tarefa atual.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		While _nOpcSel <> 0
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณChama tela de pesquisa.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			_aOps := QNAskRast()
			_nOpcSel := _aOps[1]
			_nOpcRev := _aOps[2]
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณOp็ใo 1 = Plano.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If _nOpcSel == 1
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณRevisใo Atual. (ULTIMA)	ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If _nOpcRev == 1	
					dbSelectArea("QI3")		
					dbSetOrder(2)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณSe conseguir posicionar, abre visualiza็ใo do plano.	 ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If MsSeek(xFilial("QI3")+AF9->(AF9_ACAO+AF9_REVACA),.F.)								
						QNCTPLAN( QI3->(Recno()), 2 )
					ElseIf !IsBlind()
						MsgInfo(STR0097+' '+ALLTRIM(AF9->AF9_ACAO)+" "+ALLTRIM(AF9->AF9_REVACA)+' '+STR0098) // "Plano de Acao" # "nao encontrado!"
					EndIf
									
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณPrimeira Revisใo. 	ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				ElseIf _nOpcRev == 2	
					dbSelectArea("QI3")		
					dbSetOrder(2)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณSe conseguir posicionar, abre visualiza็ใo do plano.	 ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If DbSeek(xFilial("QI3")+AF9->AF9_ACAO,.F.)								
						QNCTPLAN( QI3->(Recno()), 2 )
					ElseIf !IsBlind()
						MsgInfo(STR0097+' '+ALLTRIM(AF9->AF9_ACAO)+" 00 "+STR0098) // "Plano de Acao" # "nao encontrado!"
					EndIf
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณTodas as revis๕es. 	ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				ElseIf _nOpcRev == 3
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณChama rotina para montar um combobox com todas as revis๕es do plano.	 ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					QNShowRvs("QI3",AF9->AF9_ACAO)	
				EndIf
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณOp็ใo 2 = FNC.  ณ		
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			ElseIf _nOpcSel == 2
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณRevisใo Atual. (ULTIMA)	ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			 
				If _nOpcRev == 1  
					DbSelectArea("QI2")
			        DbSetOrder(2)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณSe conseguir posicionar, abre visualiza็ใo da FNC.	 ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			        If MsSeek(xFilial("QI2")+AF9->(AF9_FNC+AF9_REVFNC),.F.)
						QNCTFNC( QI2->(Recno()), 2 ) 
					Else
						MsgInfo(STR0099+' '+ALLTRIM(AF9->AF9_FNC)+" "+ALLTRIM(AF9->AF9_REVFNC)+' '+STR0100) //"FNC do Plano de Acao"##"nao encontrada!"
					EndIf								
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณPrimeira Revisใo. 	ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
				ElseIf _nOpcRev == 2	
					dbSelectArea("QI2")
			        dbSetOrder(2)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณSe conseguir posicionar, abre visualiza็ใo da FNC.	 ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			        If DbSeek(xFilial("QI2")+AF9->AF9_FNC)
						QNCTFNC( QI2->(Recno()), 2 ) 
					Else
						MsgInfo(STR0099+' '+ALLTRIM(AF9->AF9_FNC)+" 00 "+STR0100) //"FNC do Plano de Acao"##"nao encontrada!"
					EndIf				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณTodas as revis๕es. 	ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				ElseIf _nOpcRev == 3
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณChama rotina para montar um combobox com todas as revis๕es da FNC.	 ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					QNShowRvs("QI2",AF9->AF9_FNC)
				EndIf
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณOp็ใo 3 = Chamado.ณ		
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 			ElseIf _nOpcSel == 3
				DbSelectArea("QI2")
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณPosiciona na FNC para pegar o numero do Chamado.	 ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		        QI2->(DbSetOrder(2))
		        If MsSeek(xFilial("QI2")+AF9->(AF9_FNC+AF9_REVFNC),.F.)
					DbSelectArea("ADE")
					DbSetOrder(1)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณSe conseguir posicionar, abre visualiza็ใo do chamado.	 ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If MsSeek(xFilial("ADE")+QI2->QI2_NCHAMA,.F.)
						TK503AOpc("ADE",ADE->(Recno()) ,2)
					ElseIf !IsBlind()
						MsgInfo(STR0101+' '+ALLTRIM(QI2->QI2_FNC)+" "+ALLTRIM(QI2->QI2_REV)+' '+STR0098) //"Chamado da FNC"##"nใo encontrado!"
					EndIf
	 			ElseIf !IsBlind()
	 				MsgInfo(STR0099+' '+ALLTRIM(AF9->AF9_FNC)+" "+ALLTRIM(AF9->AF9_REVFNC)+' '+STR0100) //"FNC do Plano de Acao"##"nใo encontrada!"
				EndIf				
			Else
				_nOpcSel := 0
			EndIf
		EndDo
		
	ElseIf !IsBlind()
		MsgInfo(STR0103) //"Tarefa nใo esta relacionada com Plano de A็ใo QNC."
	EndIf				
ElseIf !IsBlind()
	MsgInfo(STR0104) //"Tarefa nใo posicionada, atualize a tela e/ou execu็ใo de tarefa !"
EndIf

RestArea(_aAreaAF9)
RestArea(_aAreaOri)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMBC     บAutor  ณMicrosiga           บ Data ณ  08/13/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function QNCTPLAN( _nRecQI3, _nOpc )                    

DEFAULT _nRecQI3 := 0
DEFAULT _nOpc	 := 2

dBSelectArea("QI3")
If _nRecQI3 > 0
	Private INCLUI := .F.
	Private ALTERA := .F.
	Private EXCLUI := .F.
	Private aRotina := {}
	aAdd(aRotina, { STR0105 , "AxPesqui" , 0 , 1,,.F.} )  //"Pesquisar"
	aAdd(aRotina, { STR0106 , "QNC030Alt", 0 , 2} )  //"Visualizar"
	///aAdd(aRotina, { STR0003 , "QNC030Alt", 0 , nOpcInclui} )  //"Incluir"
	//MBrowseAuto(2,aRotina,"QI3")
	Private aHeadAne := {} 
	Private aColAnx  := {}
	Private aHdQI5   := {}
	Private aHdQI8	 := {}
	
	QNC030Alt("QI3",QI3->(Recno()),_nOpc,/*lAltEAcao*/)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMBC     บAutor  ณMicrosiga           บ Data ณ  08/13/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function QNCTFNC( _nRecQI2, _nOpc )

DEFAULT _nRecQI2 := 0
DEFAULT _nOpc	 := 2

dBSelectArea("QI2")
If _nRecQI2 > 0 
	Private INCLUI := .F.
	Private ALTERA := .F.
	Private EXCLUI := .F.
	Private aRotina := {}
	aAdd(aRotina, { STR0105 , "AxPesqui" , 0 , 1,,.F.} )  //"Pesquisar"
	aAdd(aRotina, { STR0106 , "QNC040Alt", 0 , 2} )  //"Visualizar"
	/*Private aHeadAne := {} 
	Private aColAnx  := {}
	Private aHdQI5   := {}
	Private aHdQI8	 := {}*/
	
	QNC040Alt("QI2",QI2->(Recno()),_nOpc,/*lPreenche*/,/*aCampos*/)			
EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMBC     บAutor  ณMicrosiga           บ Data ณ  08/13/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function QNAskRast()

Local _aOpts := {0,0}
Local _oDlg
Local _lOk	 := .F.
Local _x1_	 := 0
Local _x2_	 := 0

Local _oRadioBJ
Local _nRadioBJ := 1

Local _oRadioRV
Local _nRadioRV := 1

DEFINE MSDIALOG _oDlg TITLE STR0094 FROM 0,0 TO 220,190 PIXEL //"Rastro QNC X TMK..."

@05,10 SAY STR0086 PIXEL OF _oDlg //"Qual relacionamento deseja ver?"
_oRadioBJ:= tRadMenu():New(15, 010, {STR0087,STR0088,STR0089}, ; // "##"Plano"##"FNC"##"Chamado"
					{|_x1_|if(PCount()>0,_nRadioBJ:=_x1_,_nRadioBJ)}, _oDlg,,,,,,,,50,10,,.T.,.T.,.T.) 
@47,10 SAY STR0090 PIXEL OF _oDlg //"Revisใo:"
_oRadioRV:= tRadMenu():New(57, 010, {STR0091,STR0092,STR0093}, ; //"Atual"##"Primeira"##"Selecionar"
					{|_x2_|if(PCount()>0,_nRadioRV:=_x2_,_nRadioRV)}, _oDlg,,,,,,,,50,10,,.T.,.T.,.T.)

DEFINE SBUTTON _oBTOk FROM 95,20 TYPE 1 ACTION (_lOk:=.T.,_oDlg:End()) PIXEL ENABLE OF _oDlg
DEFINE SBUTTON FROM 95,55 TYPE 2 ACTION (_lOk:=.F.,_oDlg:End()) PIXEL ENABLE OF _oDlg
		
ACTIVATE MSDIALOG _oDlg CENTERED ON INIT _oBTOk:SetFocus()

If _lOk
	_aOpts := {_nRadioBJ,_nRadioRV}
EndIf

Return(_aOpts)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMBC     บAutor  ณMicrosiga           บ Data ณ  08/13/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function QNShowRvs(_cAlias,_cCOD)
Local _aArea    := GetArea()
Local _aAreaQI2 := {}
Local _aAreaQI3 := {}
Local _cTitulo  := ""
Local _aCombo   := {}
Local _oCombo	:= Nil 
Local _cRev		:= ""
Local _oDlg

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcura revis๕es de uma FNC.	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If _cAlias == "QI2"
	_cTitulo := STR0088+": "+_cCod // "FNC"
	_cLabel  := STR0107+": " // "da FNC"
	DbSelectArea("QI2")
	_aAreaQI2 := QI2->(GetArea())		
	QI2->(DbSetOrder(2))
	If QI2->(DbSeek(xFilial("QI2")+_cCOD))
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAdiciona todas as revis๕es.	 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		While QI2->(!EOF()) .And. QI2->QI2_FNC == _cCOD
			AADD(_aCombo,QI2->QI2_REV)
			QI2->(DbSkip())
		EndDo
	EndIf
	If Len(_aCombo) == 0
		RestArea(_aAreaQI2)
	EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcura revis๕es de um plano. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf _cAlias == "QI3"
	_cTitulo := STR0087+": "+_cCod	 //"Plano"
	_cLabel  := STR0108+": " //"do Plano"
	DbSelectArea("QI3")
	_aAreaQI3 := QI3->(GetArea())			
	QI3->(DbSetOrder(2))
	If QI3->(DbSeek(xFilial("QI3")+_cCOD))
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAdiciona todas as revis๕es.	 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		While QI3->(!EOF()) .And. QI3->QI3_CODIGO == _cCOD
			AADD(_aCombo,QI3->QI3_REV)
			QI3->(DbSkip())
		EndDo
	EndIf
	If Len(_aCombo) == 0
		RestArea(_aAreaQI3)
	EndIf	
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe encontrou alguma revisใo, abre uma Dialog para o usuแrio selecionar uma.	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(_aCombo) > 0
	_cRev := _aCombo[1]
	DEFINE MSDIALOG _oDlg TITLE _cTitulo FROM 0,0 TO 110,198 OF _oDlg PIXEL  //"Reserva de Arquivos/Fontes"
	@ 5 ,20 SAY STR0109+' '+_cLabel  SIZE 100,10 PIXEL OF _oDlg //"Selecione a revisao"
	@ 15,20 COMBOBOX _oCombo VAR _cRev ITEMS _aCombo SIZE 65,10  PIXEL OF _oDlg
	@ 35,35 BUTTON STR0102       SIZE 36,16 PIXEL ACTION _oDlg:End() //"&Ok"
	ACTIVATE MSDIALOG _oDlg CENTER	
	
	If _cAlias == "QI2"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe conseguir posicionar, abre visualiza็ใo da FNC.	 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If QI2->(DbSeek(xFilial("QI2")+_cCOD+_cRev))
			QNCTFNC( QI2->(Recno()) , 2 )
		ElseIf !IsBlind()
			MsgInfo(STR0099+' '+ALLTRIM(AF9->AF9_ACAO)+" "+ALLTRIM(AF9->AF9_REVACA)+' '+STR0100) //"FNC do Plano de Acao"##"nao encontrada!"
		EndIf
		RestArea(_aAreaQI2)		
	ElseIf _cAlias == "QI3" 
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe conseguir posicionar, abre visualiza็ใo do Plano.	 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If QI3->(DbSeek(xFilial("QI3")+_cCOD+_cRev))
			QNCTPLAN( QI3->(Recno()) , 2 )
		ElseIf !IsBlind()
			MsgInfo(STR0097+' '+ALLTRIM(AF9->AF9_ACAO)+" "+ALLTRIM(AF9->AF9_REVACA)+' '+STR0098) //"Plano de Acao"##"nao encontrado!"
		Endif
		RestArea(_aAreaQI3)
	Endif
EndIf

RestArea(_aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMACHKL  บAutor  ณMarcelo Akama       บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo Chamadora do Check-List                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSMONIT                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SIMBPMSCHK(nRecAF9, lReadOnly)

Local aArea		:= GetArea()
Local aAreaAF9		:= {}
Local aAJOArea		:= {}

DEFAULT nRecAF9 := 0
DEFAULT lReadOnly := .F.

If nRecAF9 <> 0
	
	dbSelectArea("AF9")
	aAreaAF9	:= GetArea()
	dbGoTo(nRecAF9)


	dbSelectArea("AJO")
	aAJOArea	:= AJO->(GetArea())
	dbSetOrder(1)   
	If !MsSeek(xFilial("AJO")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA),.F.)
		// Se nao existirem itens de check list, retorna
		Return
	EndIf	
	RestArea(aAJOArea)

	
	SIMFCHKCAL( IIf(lReadOnly, 3, 2) , nRecAF9, .T., " ["+STR0170+" "+ALLTRIM(AF9->AF9_PROJET)+" "+STR0171+" "+ALLTRIM(AF9->AF9_TAREFA)+"] "+ALLTRIM(AF9->AF9_DESCRI) ) //"Projeto:"##"Tarefa:"

	RestArea(aAreaAF9)
	
ElseIf !IsBlind()
	MsgInfo(STR0110) //"Execute uma tarefa !"
EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMFCHKCALบAutor  ณMarcelo Akama       บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamadora Check-List a partir registro posicionado do AF9  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSMONIT                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SIMFCHKCAL(nOpcAV, nRecAF9, lShowDLG, cAddTxt, nRecDes)

Local aFieldLst	:= {}
Local aFieldView	:= {}
Local aButtLst	:= {}
Local nPart		:= 1
Local aAJOArea	:= {}
Local nA			:= 0
Local aArea		:= GetArea()

Private aChkLst	:= {}

DEFAULT nRecAF9	:= 0
DEFAULT nOpcAV	:= 0
DEFAULT lShowDLG	:= .T.

If IsBlind()
	lShowDLG := .F.
EndIf

If nRecAF9 > 0
	dbSelectArea("AF9")
	AF9->( DbGoTo(nRecAF9))
	
	// Projeto TDI - TEHNAO
	// Copia de Checklist durante a copia da EDT/tarefa
	if IsInCallStack("PMSPRJCOPY")
		M->AF9_CHKLST := AF9->AF9_CHKLST
	Endif	
	
	If nOpcAV <= 0 .and. !IsBlind()
		nOpcAV := Aviso( STR0111+" "+cAddTxt , STR0112, {STR0113,STR0114,STR0115}) // "Check List"##"Selecione a op็ใo desejada para a lista de verifica็๕es: "##"Gera Nova"##"Verificar"##"Fechar"
	EndIf
	
	// Projeto TDI - TEHNAO
	// mudanca conceito no checklist
	If nOpcAV == 1 ///Quando estiver carregando o ChkList inicial
		nOpcCh := 1
		if ! Empty(M->AF9_CHKLST)
			AJO->( Dbsetorder(1)) // AJO_FILIAL+AJO_PROJET+AJO_REVISA+AJO_TAREFA+AJO_ITEM+AJO_ORDEM
			lExisteChk := AJO->( Dbseek(xFilial("AJO")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)) 

			if ! IsInCallStack("PMSPRJCOPY") .and. lExisteChk .and. AJO->AJO_ORDEM <> AF9->AF9_CHKLST
				nOpcCh := Aviso( STR0111,STR0207, {STR0045,STR0046} ) // "Checklist"##"Jแ existe check-list para a tarefa, deseja recriar?"##"Sim"##"Nใo"
			Endif
		Endif		
	                                                       		
		// se selecionar nao recria, deve ignorar a etapa de manutencao de checklist
		if nOpcCh == 2
			nOpcAV := 0
		Endif
	EndIf

	If nOpcAV == 1 ///Quando estiver carregando o ChkList inicial
		
		aFieldLst  := {"SPACE(10)","AJN_ORDEM","AJN_ITEM","SIMFAJMD(AJN->AJN_ITEM)" ,"AJN_OBRIGA","AJN_REPEXE","AJN->(Recno())",".T."}
		aFieldView := {"SPACE(10)","AJN_ORDEM","AJN_ITEM","AJN_DESCRI"				,"AJN_OBRIGA","AJN_REPEXE"}

		dbSelectArea("AJN")
		dbSetOrder(3)
		/// CARREGA OS ITENS DE CHECAGEM
		aChkPart := {}
		If MsSeek(xFilial("AJN")+AF9->AF9_CHKLST,.F.)
			aChkPart	:= SIMFLLIS("AJN", 3, AJN->(Recno()), aFieldLst, "AJN->AJN_CODIGO == '"+AF9->AF9_CHKLST+"'", "", .T. ) ///Carrega itens a verificar.
			AEVAL(aChkPart,{|x| aAdd(aChkLst , aClone(x) )})
		EndIf		
		dbSelectArea("AJN")
		
		If Len(aChkLst) > 0
			///////////////////
			///Adiciona bot๕es na tela do check-list
			///////////////////
			// Projeto TDI - TEHNAO
			// mudanca conceito no checklist
			If !lShowDLG .or. SIMFCHKDLG( "1", aFieldLst, aFieldView, aChkLst, cAddTxt, aButtLst)
				aGrvFieLst  := {"","AJO_ORDEM","AJO_ITEM","","AJO_OBRIGA","AJO_REPEXE","","","","","",".T."}

				// Projeto TDI - TEHNAO
				// Copia de Checklist durante a copia da EDT/tarefa
				if IsInCallStack("PMSPRJCOPY")
					For nA := 1 to Len(aChkLst)
						AJN->( Dbgoto(aChkLst[nA,Len(aChkLst[nA])-1]))
						if AJN->AJN_OBRIGA == '1' .or. ;
						   AJO->( Dbseek(xFilial("AJO")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+aChkLst[nA,3]+aChkLst[nA,2])) 
							aChkLst[nA,8] := .T.
						Else	
							aChkLst[nA,8] := .F.
						Endif	
				   Next
					AF9->( Dbgoto(nRecDes)) // posiciona no AF9 destino
				Endif

				If SIMFINCAJO(aChkLst,aGrvFieLst,AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,.F.)//lShowDlg)
					If lShowDLG
						Aviso( STR0111, STR0116, {STR0102} ) //"Check List"##"Itens de verifica็ใo gerados para a tarefa !"##Ok
					EndIf
				EndIf
			EndIf
		EndIf
		
	ElseIf nOpcAV == 2 .Or. nOpcAV == 3

		dbSelectArea("AJO")
		aAJOArea := AJO->(GetArea())
		dbSetOrder(2)
		If MsSeek(xFilial("AJO")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA),.F.)
			aFieldLst  := {"SPACE(10)","AJO_ORDEM","AJO_ITEM","SIMFAJMD(AJO->AJO_ITEM)"	,"AJO_OBRIGA","AJO_REPEXE","AJO_INI","AJO_FIM","AJO_STATUS","AJO_WFID","AJO->(Recno())","!Empty(AJO_FIM)"}
			aFieldView := {"SPACE(10)","AJO_ORDEM","AJO_ITEM","AJO_DESCRI"				,"AJO_OBRIGA","AJO_REPEXE","AJO_INI","AJO_FIM","AJO_STATUS","AJO_WFID" }
			aChkLst	:= SIMFLLIS("AJO", 2, AJO->(Recno()), aFieldLst, "AJO->AJO_PROJET == '"+AF9->AF9_PROJET+"' .And. AJO->AJO_REVISA == '"+AF9->AF9_REVISA+"' .And. AJO->AJO_TAREFA == '"+AF9->AF9_TAREFA+"' ")///Carrega itens AJO a executar.
			dbSelectArea("AJO")
		EndIf
			
		If Len(aChkLst) > 0
			// Projeto TDI - TEHNAO
			// Copia de Checklist durante a copia da EDT/tarefa
			if IsInCallStack("PMSPRJCOPY")
				For nA := 1 to Len(aChkLst)
					AJN->( Dbgoto(aChkLst[nA,Len(aChkLst[nA])-1]))
					if AJN->AJN_OBRIGA == '1' .or. ;
					   AJO->( Dbseek(xFilial("AJO")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+AJN->AJN_ITEM+AJN->AJN_ORDEM)) 
						aChkLst[nA,8] := .T.
					Endif	
			   Next
         Else
				If SIMFCHKDLG( IIf(nOpcAV==2,"2","3"), aFieldLst, aFieldView, aChkLst, cAddTxt, aButtLst)
					///Se confirmou a tela do chklist.
				EndIf
			Endif	
			RestArea(aAJOArea)
		EndIf
	EndIf
Endif

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMFCHKDLGบAutor  ณMarcelo Akama       บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo Principal INTERFACE DO CHECK-LIST                   บฑฑ
ฑฑบ          ณ carrega os itens de verifica็ใo e permite disparar as      บฑฑ
ฑฑบ          ณ a็๕es relacionadas.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSMONIT                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SIMFCHKDLG(cAcao, aFieldLst, aFieldView, aChkLst, cAddTxt, aButtLst  )

Local aArea		:= GetArea()
Local lRet			:= .F.
Local oPanel
Local aSize		:= MsAdvSize()
Local oBtnClose
Local oBtnExec
Local cChkLst
Local aHeadLst	:= {}
Local aHeadSiz	:= {}
Local nOpcao		:= 0
Local lReload		:= .T.
Local nCnt
Local aButTmp
Local nA
Local oLayer
Local oLayer1
Local oLayer2

Private cRetBloco	:= "OK"
Private oDlgChkLst
Private oChkLst

DEFAULT cAcao			:= "1"
DEFAULT aFieldLst		:= {}
DEFAULT aFieldView	:= {}
DEFAULT aChkLst		:= {}
DEFAULT cAddTxt		:= ""
DEFAULT aButtLst		:= {}

AEVAL(aSize, {|x| IIf(valtype(x)=="N",x*=.75,)}) ///Redimensionamento da dialog x MsAdvSize

aHeadLst := SIMFaHLST(aFieldView)
aHeadSiz := SIMFaHSIZ(aFieldView,aHeadLst)

//
// permite customizar os bot๕es do barra de bot๕es da janela, adicionando novos bot๕es na enchoicebar
//
If ExistBlock("PMSMON06")
	aButTmp := ExecBlock("PMSMON06", .T., .T., {aFieldLst})
	If ValType(aButTmp) == "A"
		For nCnt := 1 To len(aButTmp)
			If Len(aButTmp[nCnt]) >= 2
				aAdd(aButtLst ,aButTmp[nCnt])
			EndIf
		Next nCnt
	EndIf
EndIf

// Projeto TDI - TEHNAO
// mudanca conceito no checklist
if cAcao == "1"
	AJO->( Dbsetorder(1)) // AJO_FILIAL+AJO_PROJET+AJO_REVISA+AJO_TAREFA+AJO_ITEM+AJO_ORDEM

	// verifica se ja existe checklist para a tarefa
	lExisteChk := AJO->( Dbseek(xFilial("AJO")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)) 

	if lExisteChk
		// desmarca todos se for alteracao
		if ALTERA
			Aeval( aChkLst, {|e| e[Len(e)] := .F.} )
		Endif	
	Endif	
		
	// marca os ja marcados e os obrigatorios
	For nA := 1 to Len(aChkLst)
		AJN->( Dbgoto(aChkLst[nA,Len(aChkLst[nA])-1]))
		if AJN->AJN_OBRIGA == '1' .or. ;
		   AJO->( Dbseek(xFilial("AJO")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+AJN->AJN_ITEM+AJN->AJN_ORDEM)) 
			aChkLst[nA,8] := .T.
		Endif	
   Next
Endif
Do While lReLoad

	lReload := .F.
	
	If Len(aChkLst) > 0
				
		DEFINE MSDIALOG oDlgChkLst FROM aSize[7],000 TO aSize[6],aSize[5] TITLE OemToAnsi(STR0117 + cAddTxt) PIXEL OF oMainWnd // "Lista de Verifica็๕es"
		
		oLayer := FwLayer():New()
			
		oLayer:init(oDlgChkLst,.F.)

		If cAcao=="1" .OR. cAcao == "2"
			oLayer:addLine("TOP", 10, .F.)
			oLayer:addLine("CLIENT", 90, .F.)

			oLayer1 := oLayer:getLinePanel("TOP")
			oLayer2 := oLayer:getLinePanel("CLIENT") 
	
			If cAcao == "1"
				@ 10,005 SAY STR0118 PIXEL OF oLayer1 //"ATENวรO ! Gera็ใo do check-list para a tarefa !"
				@ 30,005 SAY STR0119 PIXEL OF oLayer1 //"SELECIONE O QUE DEVERม SER VERIFICADO NA EXECUวรO DESTA TAREFA."
			Else
				If cAcao == "2"
					@ 20,005 SAY STR0120 PIXEL OF oLayer1 //"Verifique (execute) os itens de check-list."
				EndIf
			EndIf
		Else
			oLayer:addLine("CLIENT", 100, .F.)
					
			oLayer1 := oLayer:getLinePanel("CLIENT")
		EndIf
		
		@ 1, 005 LISTBOX oChkLst VAR cChkLst FIELDS HEADER aHeadLst COLSIZES aHeadSiz SIZE 2,5 OF oLayer2 PIXEL ON DBLCLICK ( SIMFCHLCLK( aChkLst, oChkLst, cAcao, aFieldLst ),  oDlgChkLst:Refresh() )
		oChkLst:Align := CONTROL_ALIGN_ALLCLIENT 
		
		If cAcao == "3"
			oChkLst:bLDblClick := {|| }
		EndIf
		
		oChkLst:aColSizes:= aClone(aHeadSiz)
		oChkLst:aHeaders := aClone(aHeadLst)
		oChkLst:SetArray(aChkLst)
		// Projeto TDI - TEHNAO
		// mudanca conceito no checklist
		// nOpcCh => 1 marca todos ; 2 desmarca os nao obrigatorios ; 3 marca os obrigatorios e os que ja existem na AJO
		oChkLst:bLine    := {|| SIMFPNTLIN(aChkLst, aFieldLst , oChkLst:nAt ) }
		
		If cAcao == "1"
			oChkLst:cToolTip := OemToAnsi(STR0121) //"Marque/Desmarque os itens que serใo usados na execu็ใo da tarefa."
		ElseIf cAcao == "2"
			oChkLst:cToolTip := OemToAnsi(STR0122)	//"Duplo clique para executar a verifica็ใo !"
		Else
			oChkLst:cToolTip := ""
		EndIf
		
		ACTIVATE MSDIALOG oDlgChkLst ON INIT EnchoiceBar(oDlgChkLst,{|| nOpcao:=1 , oDlgChkLst:End() },{||nOpcao:=2,oDlgChkLst:End()},,aButtLst) CENTERED
		
		If nOpcao == 1
			IF cAcao == "2"
				lRet := SIMCHLok()[1]
				If !lRet 
					lReload := .T.					
				EndIf
			Else
				lRet := .T.
			EndIf
		EndIf
		
	Else
		MsgInfo(STR0123,STR0117) //"Nใo foram localizados itens para verifica็ใo."##"Lista de Verifica็๕es"
	EndIf 
EndDo

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMFLLIS  บAutor  ณMarcelo Akama       บ Data ณ  10/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega array com o conte๚do/itens do ListBox do Check-Listบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSMONIT                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SIMFLLIS(cAlias, nOrdem, nRegIni, aStr2Load, cCondW, cCondIn, cChkInicial )

Local aArea		:= GetArea()
Local aIT2Chk	:= {}
Local a1ITEM	:= {}
Local lCONDIn	:= .F.
Local lAdic		:= .T.

DEFAULT cAlias		:= Alias()
DEFAULT aStr2Load	:= {}
DEFAULT nOrdem		:= 1
DEFAULT nRegIni		:= (cAlias)->(Recno())
DEFAULT cCondW		:= ".T."
DEFAULT cCondIn		:= ""
DEFAULT cChkInicial := .F.

lCondIn:=!Empty(cCondIn)

dbSelectArea("SX3")
dbSetOrder(2)

If !Empty(cAlias) .and. Len(aStr2Load) > 0
	DbSelectArea("AJM")
	AJM->(DbSetOrder(1))
	
	dbSelectArea(cAlias)
	dbSetOrder(nOrdem)
	dbGoTo(nRegIni)
	
	Do While (cAlias)->(!Eof()) .And. &(cAlias+"->"+cAlias+"_FILIAL") == xFilial(cAlias) .And. &(cCondW)
		lAdic := .T.
		If AJM->(DbSeek(xFilial("AJM")+&(cAlias+"->("+aStr2Load[3]+")")))
			If !Empty(AJM->AJM_CNDEXB) .And. !&(AJM->AJM_CNDEXB) .AND. !cChkInicial
				lAdic := .F.
			EndIf
		EndIf
		
		If lCondIn .And. lAdic
			If ! &(cCondIn)
				lAdic := .F.
			EndIf
		EndIf
		
		If lAdic
			a1ITEM := {}
			AEVAL(aStr2Load, {|x| aAdd(a1ITEM, &(cAlias+"->("+x+")") )})
			aAdd(aIT2Chk, a1ITEM )
		EndIf
		
		(cAlias)->(dbSkip())
	EndDo
	
EndIf

RestArea(aArea)

Return(aIT2Chk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMFaHLST บAutor  ณMarcelo Akama       บ Data ณ  07/22/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ A partir do array de campos, carrega os tํtulos do ListBox บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSMONIT                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SIMFAHLST(aFieldLst)/// Retorna os tํtulos dos campos (HEADER) para o listbox.

Local aArea		:= GetArea()
Local aRet		:= {}
Local aTitX3	:= {}

DEFAULT aFieldLst := {}

AEVAL(aFieldLst,{|x| aTitX3:=TitSx3(x), aAdd(aRet, IIf(Len(aTitX3)>0,Alltrim(aTitX3[1])," ") ) })

RestArea(aArea)

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMFaHLST บAutor  ณMarcelo Akama       บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ A partir do array de campos, carrega o tamanho das colunas บฑฑ
ฑฑบDesc.     ณ do ListBox (COLSIZES) 									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSMONIT                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SIMFaHSIZ(aNameFields,aNameList)

Local aRet		:= {}
Local nCnt		:= 0
Local cBox		:= ""
Local aBox		:= {}

DEFAULT aNameFields	:= {}
DEFAULT aNameList		:= {}

If len(aNameFields)== len(aNameList)
	dbSelectArea("SX3")
	dbSetOrder(2)
	For nCnt := 1 to Len(aNameFields)
	
		If dbSeek(aNameFields[nCnt])
			If SX3->X3_TAMANHO > len(aNameList[nCnt])
				If SX3->X3_TAMANHO > 30  
					AADD( aRet, 50 )
				Else
					AADD( aRet, SX3->X3_TAMANHO )
				EndIf
				
			Else
				cBox := X3CBox()
				If !Empty(cBox) .AND. aNameFields[nCnt] == 'AJO_STATUS'
					aBox := RetSX3Box(cBox,,,2,)
					AADD( aRet, Len(aBox[Val(Substr(AJO->AJO_STATUS,2))][3])*4)
				Else
					AADD( aRet, (Len(aNameList[nCnt]))*4 )
				EndIf
			EndIf
		Else
			AADD( aRet, (Len(aNameList[nCnt]))*4 )
		EndIf
	
	Next nCnt
EndIf

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMFCHLCLKบAutor  ณMarcelo Akama       บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ A็ใo executada no evento (DOUBLE) DBLCLICK do ListBox	  บฑฑ
ฑฑบDesc.     ณ Recebe o objeto checklist com o item posicionado, e a a็ใo บฑฑ
ฑฑบDesc.     ณ atualiza o AJO se for a็ใo "2"="verifica็ใo do check-list" บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSMMONIT                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SIMFCHLCLK( aChkLst, oChkLst, cAcao, aFieldLst)

Local aAJOArea := {}

Local lRet		:= .T.
Local nLinIT 	:= 1
Local lPeRet 	:= .F.
Local lOK2EXE	:= .T.
Local lRetBlk 	:= .F.
Local nColFIM	:= Ascan(aFieldLst,{|x| x == "AJO_FIM" } )
Local nColINI	:= Ascan(aFieldLst,{|x| x == "AJO_INI" } )
Local nColWFI	:= Ascan(aFieldLst,{|x| x == "AJO_WFID" } )
Local nColSTT	:= Ascan(aFieldLst,{|x| x == "AJO_STATUS" } )
Local nColObr	:= Ascan(aFieldLst,{|x| x == "AJO_OBRIGA" } )
Local lPChlClk	:= ExistBlock( 'PMSFCHLCLK' )

DEFAULT cAcao 		:= "1"

nLinIT 		:= Len(aChkLst[oChkLst:nAt])

If cAcao == "1"
	
	If  ( Ascan(aFieldLst,{|x| x == "AJN_OBRIGA" } ) > 0 )
		nColObr	:= Ascan(aFieldLst,{|x| x == "AJN_OBRIGA" } )
	EndIf

	aChkLst[oChkLst:nAt,nLinIT] := !aChkLst[oChkLst:nAt][nLinIT]
	// se for obrigatorio e tentou desmarcar, avisa e nao deixa
	if aChkLst[oChkLst:nAt,nColObr] == "1" .and. !aChkLst[oChkLst:nAt][nLinIT]
		MsgStop(OemToAnsi(STR0203),OemToAnsi(STR0030))
		aChkLst[oChkLst:nAt,nLinIT] := .T.
	Endif
ElseIf cAcao == "2"
	dbSelectArea("AJO")
	aAJOArea := AJO->(GetArea())
	dbGoTo(aChkLst[oChkLst:nAt][nLinIT-1])			///Coluna do Recno  => Len - 1
	
	If !Empty(AJO->AJO_FIM) .and. AJO->AJO_REPEXE == "2"
		Aviso( STR0124, STR0125, {STR0115}) //"Check-List da Tarefa"##"Item jแ verificado, marcado para nใo permitir repeti็ใo."##"Fechar"
	Else
		dbSelectArea("AJM")
		dbSetOrder(1)
		If MsSeek(xFilial("AJM")+AJO->AJO_ITEM,.F.)
			
			//////////////////////////////////////////////////////////////////////////////////////////////////////
			/// TRATAMENTO DA CONDICAO ANTES DE EXECUTAR (AJM_CNDEXE)
			//////////////////////////////////////////////////////////////////////////////////////////////////////
			lOK2EXE := .T.
			If !Empty(AJM->AJM_CNDEXE)
				lOK2EXE := &(AJM->AJM_CNDEXE)
						If !( ValType( lOK2EXE ) == "L" )
					lOK2EXE := .F.
				EndIf
			EndIf
		
			If lOK2EXE
				If Empty(AJO->AJO_INI)
					RecLock("AJO",.F.)
					AJO->AJO_INI := cUserName+DTOC(Date())+Time()
					AJO->(MsUnlock())
				EndIf
				If !Empty(AJM->AJM_CNDCMP)
					lRetBlk := AJMCODBLK() //Excuta Rotina de Check-List
					If lRetBlk
						Do While !&(AJM->AJM_CNDCMP)
							If AJO->AJO_REPEXE == "1" .and. !IsBlind()
								If Aviso(STR0126+AJO->AJO_ITEM,CRLF+STR0127,{STR0045,STR0046},2,STR0128)  == 1 //"Condi็ใo para concluir, item de check-list: "##"Cancelar para executar depois ?"##"Sim"##"Nao"##"Condi็ใo para concluir nใo atendida !"
									Exit
								EndIf
							ElseIf AJO->AJO_REPEXE == "2" .and. !IsBlind()
								Aviso(STR0126+AJO->AJO_ITEM,STR0129+CRLF+STR0130,{STR0102},2,STR0128) //"Condi็ใo para concluir, item de check-list: "##"Item configurado para apenas UMA execu็ใo."##"A a็ใo deste item serแ executada novamente."##"Ok"##"Condi็ใo para concluir nใo atendida !"
							EndIf
								If !AJMCODBLK() //Excuta Rotina de Check-List
									Exit
								EndIf
						EndDo
					cRetBloco := IIf (&(AJM->AJM_CNDCMP), "OK", "" )
					Endif				
				Else
					lRetBlk := AJMCODBLK() //Excuta Rotina de Check-List
				EndIf
			EndIf						
		EndIf

		If lOK2EXE .And. lRetBlk 
			If !Empty(cRetBloco)
				RecLock("AJO",.F.)
				AJO->AJO_INI := cUserName+DTOC(Date())+Time()				
				AJO->AJO_FIM := cUserName+DTOC(Date())+Time()
				AJO->(MsUnlock())
				aChkLst[oChkLst:nAt][nLinIT] := .T.
				If nColFIM > 0
					aChkLst[oChkLst:nAt][nColFIM] := AJO->AJO_FIM
				EndIf
				If nColINI > 0
					aChkLst[oChkLst:nAt][nColINI] := AJO->AJO_INI
				EndIf
				
				If nColWFI > 0
					aChkLst[oChkLst:nAt][nColWFI] := AJO->AJO_WFID
				EndIf
				
				If nColSTT > 0
					aChkLst[oChkLst:nAt][nColSTT] := AJO->AJO_STATUS
				EndIf
			ElseIf !Empty(AJO->AJO_FIM)
				RecLock("AJO",.F.)
				AJO->AJO_FIM := ""
				AJO->(MsUnlock())
				aChkLst[oChkLst:nAt][nLinIT] := .F.
				If nColINI > 0
					aChkLst[oChkLst:nAt][nColINI] := AJO->AJO_INI
				EndIf
				If nColFIM > 0
					aChkLst[oChkLst:nAt][nColFIM] := AJO->AJO_FIM
				EndIf
				
				If nColWFI > 0
					aChkLst[oChkLst:nAt][nColWFI] := AJO->AJO_WFID
				EndIf
				
				If nColSTT > 0
					aChkLst[oChkLst:nAt][nColSTT] := AJO->AJO_STATUS
				EndIf

			EndIf
			//Ponto de Entrada Apos a Atualizacao dos Campos
			// AJO_INI / AJO_FIM
			If lPChlClk
				lPeRet := ExecBlock( 'PMSFCHLCLK',.F.,.F., { AJO->AJO_PROJET, AJO->AJO_REVISA, AJO->AJO_TAREFA, AJO->AJO_ITEM } )
				If lPeRet
					aChkLst[oChkLst:nAt][nLinIT] := .T.
					
					If nColFIM > 0
						aChkLst[oChkLst:nAt][nColFIM] := AJO->AJO_FIM
					EndIf
					
					If nColINI > 0
						aChkLst[oChkLst:nAt][nColINI] := AJO->AJO_INI
					EndIf
					
					If nColWFI > 0
						aChkLst[oChkLst:nAt][nColWFI] := AJO->AJO_WFID
					EndIf
					
					If nColSTT > 0
						aChkLst[oChkLst:nAt][nColSTT] := AJO->AJO_STATUS
					EndIf
					
				EndIf
			EndIf
			
		EndIf
	EndIf	
Else
	aChkLst[oChkLst:nAt][nLinIT] := .T.
EndIf

If ValType(oChkLst) == "O"
	oChkLst:Refresh()	
EndIf

If Len(aAJOArea) > 0
	RestArea(aAJOArea)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMFPNTLINบAutor  ณMarcelo Akama       บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pinta a linha do ListBox, a partir da interface            บฑฑ
ฑฑบDesc.     ณ A็ใo executada no evento oListBox:Bline() do CheckList	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSMONIT                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SIMFPNTLIN(aChkLst,aHeadLst,nAt)
Local aLinCont	:= {}
Local cContCol	:= ""
Local nCP		:= 1
Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())
Local aBox
Local cBox
Local nPos

DEFAULT aChkLst	:= {}
DEFAULT aHeadLst:= {}
DEFAULT nAt		:= 0

dbSelectArea("SX3")
SX3->(dbSetOrder(2))

If nAt <> 0 .And. nAt <= Len(aChkLst)
	
	//Verifica se campo eh obrigatorio nao permite manipular
	IF aChkLst[nAt][5] == "1" 
		aChkLst[nAt][8] := .T.
	Endif

	For nCP := 1 to Len(aChkLst[nAt])
		If nCP == 1 .or. "_MARK"$aHeadLst[nCP]
			cContCol := SIMFCHKPNT( aChkLst[nAt][Len(aChkLst[nAt])] )
		ElseIf SX3->( dbSeek(aHeadLst[nCP]) )
			cBox := X3CBox()
			If !Empty(cBox)
				aBox := RetSX3Box(cBox,,,IIf( aHeadLst[nCP] == 'AJO_STATUS', 2, 1 ),)
				If (nPos:= Ascan(aBox, { |x| x[2] == aChkLst[nAt][nCP] })) > 0
					cContCol := aBox[nPos,3]
				Else
					cContCol := aChkLst[nAt][nCP]
				EndIf
			ElseIf !Empty(SX3->X3_PICTURE)
				cContCol := Transform( aChkLst[nAt][nCP] , SX3->X3_PICTURE )
			Else
				cContCol := aChkLst[nAt][nCP]
			EndIf
		Else
			cContCol := aChkLst[nAt][nCP]
		Endif
		
		aAdd( aLinCont, cContCol )
	Next
	
EndIf

RestArea(aAreaSX3)
RestArea(aArea)
Return(aLinCont)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑบPrograma  ณSIMACHKL  บAutor  ณMarcelo Akama       บ Data ณ  07/05/10    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SIMCHLok(cEntid,cChave)
Local lRet		:= .T.
Local cTemPend	:= ""
Local aAJOArea := {}

DEFAULT cEntid := "AF9"
DEFAULT cChave := AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)

dbSelectArea("AJM")
dbSetOrder(1)


dbSelectArea("AJO")
aAJOArea := AJO->(GetArea())
dbSetOrder(1)
If dbSeek(xFilial("AJO")+cChave,.F.)
	Do While !AJO->(Eof()) .and. AJO->(AJO_PROJET+AJO_REVISA+AJO_TAREFA) == cChave
		If AJM->(MsSeek(xFilial("AJM")+AJO->AJO_ITEM,.F.)) .And. !Empty(AJO->AJO_FIM) .And. !Empty(AJM->AJM_CNDCMP) .And. !&(AJM->AJM_CNDCMP)
			cTemPend += "-> "+AJO->AJO_ITEM+" "
				cTemPend += ALLTRIM(AJM->AJM_DESCRI)
				cTemPend += CRLF
			ElseIf AJO->AJO_OBRIGA == "1" .And. Empty(AJO->AJO_FIM)
				If Empty( AJM->AJM_CNDEXB ) .OR. ( !Empty(AJM->AJM_CNDEXB) .And. &(AJM->AJM_CNDEXB) )
					cTemPend += "-> "+AJO->AJO_ITEM+" "
					IF AJO->AJO_ITEM == AJM->AJM_CODIGO
						cTemPend += ALLTRIM(AJM->AJM_DESCRI)
					EndIf
					cTemPend += CRLF
				EndIf
			EndIf

		AJO->(dbSkip())
	EndDo
EndIf
RestArea(aAJOArea)

	
If !Empty(cTemPend)
	lRet := .F.
	If !IsBlind()
		nOpAVDEP := Aviso(STR0124, cTemPend,{STR0102}, 3, STR0131) //"Check-List da Tarefa"##"Ok"##"Itens obrigat๓rios nใo finalizados"
	EndIf
EndIf

Return( {lRet, cTemPend} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMFINCAJOบAutor  ณMarcelo Akama       บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Descarrega o Array do ListBox apresentado no check-list qdoบฑฑ
ฑฑบDesc.     ณ esta com a็ใo "1"="Gerar lista de pend๊ncias", incluindo osบฑฑ
ฑฑบDesc.     ณ registros na AJO.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSMONIT                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SIMFINCAJO(aChkLst, aFieldLst, cProjet, cRevisa, cTarefa, lShowDLG)

Local aArea		:= GetArea()
Local aAJOArea		:= {}
Local nITCHK 	:= 1
Local lRetGvou	:= .F.
Local cObriga 	:= "2"
Local cREPEXE	:= "1"
Local cSolAprov		:= Nil
Local nPOrdem
Local nPItem
Local nPObriga
Local nPRepExe
Local lAJODel	:= .T.
Local lNewReg	:= .T.

DEFAULT aChkLst		:= {}
DEFAULT aFieldLst	:= {}
DEFAULT cProjet		:= ""
DEFAULT cRevisa		:= ""
DEFAULT cTarefa		:= ""

DEFAULT lShowDLG	:= .T.

If IsBlind()
	lShowDLG := .F.
EndIf

If Len(aCHKLst) > 0 .and. Len(aFieldLst) > 0
	
	nPOrdem := Ascan(aFieldLst,"AJO_ORDEM")
	nPItem  := Ascan(aFieldLst,"AJO_ITEM")
	
	If nPOrdem > 0 .and. nPItem > 0
		
		nPOBRIGA := Ascan(aFieldLst,"AJO_OBRIGA" )
		nPREPEXE := Ascan(aFieldLst,"AJO_REPEXE" )
		
		If !Empty(cProjet) .and. !Empty(cTarefa)
			

			dbSelectArea("AJO")
			aAJOArea := AJO->(GetArea())
			dbSetOrder(1)
			If MSSeek(xFilial("AJO")+cProjet+cRevisa+cTarefa,.F.)
				lAJODel := .T.
				If lShowDLG
					If !MsgYesNo(STR0132) //"Encontrado check-list anterior para esta tarefa. Recriar ?"
						lAJODel := .F.
					EndIf
					
					If lAJODel
						lTemMark := .F.
						For nITCHK := 1 to Len(aChkLst)
							If aChkLst[nITCHK][Len(aChkLst[nITCHK])]
								lTemMark := .T.
								Exit
							EndIf
						Next
						
						If !lTemMark .and. !MsgYesNo( STR0133 ) //"Nใo hแ sele็ใo no check-list da etapa atual, deseja realmente apagar a lista anterior ?"
							lAJODel := .F.
						EndIf
					EndIf
				EndIf
					
				If lAJODel
					SIMFDELAJO(cProjet, cRevisa, cTarefa)
				EndIf				
				
			EndIf
		
		EndIf
		
		If lAJODel

			BEGIN TRANSACTION

			For nITCHK := 1 to Len(aChkLst)
				If aChkLst[nITCHK][Len(aChkLst[nITCHK])]
					If nPOBRIGA > 0
						cObriga := aChkLst[nITchk][nPOBRIGA]
					Else
						dbSelectArea("AJN")
						dbSetOrder(1)
						If MsSeek(xFilial("AJN")+aChkLst[nITchk][nPItem],.F.)
							cObriga := AJN->AJN_OBRIGA
						Else
							dbSelectArea("AJM")
							dbSetOrder(1)
							If MsSeek(xFilial("AJM")+aChkLst[nITchk][nPItem],.F.)
								cObriga := AJM->AJM_OBRIGA
								cSolAprov := AJM->AJM_SOLAPR
							Else
								cObriga := "2"	//Nใo
							EndIf
						EndIf
					EndIf
					
					If nPREPEXE > 0
						cREPEXE := aChkLst[nITchk][nPREPEXE]
					Else
						dbSelectArea("AJN")
						dbSetOrder(1)
						If MsSeek(xFilial("AJN")+aChkLst[nITchk][nPItem],.F.)
							cREPEXE := AJN->AJN_REPEXE
						Else
							dbSelectArea("AJM")
							dbSetOrder(1)
							If MsSeek(xFilial("AJM")+aChkLst[nITchk][nPItem],.F.)
								cREPEXE := AJM->AJM_REPEXE
								cSolAprov := AJM->AJM_SOLAPR
							Else
								cREPEXE := "2"	//Nใo
								cObriga 	:= "2"	//Nใo
								cSolAprov := "2"	//Nใo
							EndIf
						EndIf
					EndIf
					
					dbSelectArea("AJO")
					AJO->( DbSetOrder( 1 ) )
					lNewReg := AJO->( !DbSeek( xFilial( "AJO" ) + cProjet + cRevisa + cTarefa + aChkLst[nITchk][nPItem] + aChkLst[nITchk][nPOrdem] ) )
					RecLock( "AJO", lNewReg )
			
					If lNewReg
						AJO->AJO_FILIAL := xFilial("AJO")
						AJO->AJO_PROJET := cProjet
						AJO->AJO_REVISA := cRevisa
						AJO->AJO_TAREFA := cTarefa
						AJO->AJO_ITEM   := aChkLst[nITchk][nPItem]
						AJO->AJO_ORDEM  := aChkLst[nITchk][nPOrdem]
						AJO->AJO_STATUS := IIf( cSolAprov == '2', cNaoApl, cNaoEnv )
					EndIf
			
					AJO->AJO_OBRIGA := cObriga
					AJO->AJO_REPEXE := cREPEXE
					AJO->(MsUnlock())
					lRetGvou := .T.
		
				EndIf
			Next
			END TRANSACTION
		EndIf		
	EndIf
EndIf

If Len(aAJOArea) >0
	RestArea(aAJOArea)
Endif
RestArea(aArea)

Return(lRetGvou)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMFDELAJOบAutor  ณMarcelo Akama       บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Apaga os registros de check-list (AJO) relacionado a tarefaบฑฑ
ฑฑบDesc.     ณ Utilizado ao acionar o Check-List com a็ใo "1 = Gerar listaบฑฑ
ฑฑบDesc.     ณ de pend๊ncias", e jแ existe lista anterior.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSMONIT                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SIMFDELAJO(cProjet, cRevisa, cTarefa)
Local aAJOArea := {}

DEFAULT cProjet := ""
DEFAULT cRevisa := ""
DEFAULT cTarefa := ""

If !Empty(cProjet) .and. !Empty(cTarefa) 
	dbSelectArea("AJO")
	aAJOArea := AJO->(GetArea())
	dbSetOrder(1)
	If MsSeek(xFilial("AJO")+cProjet+cRevisa+cTarefa,.F.)
		
		BEGIN TRANSACTION
		
		Do While AJO->(!Eof()) .and. AJO->AJO_FILIAL == xFilial("AJO") .And. AJO->AJO_PROJET == cProjet .And. AJO->AJO_REVISA == cRevisa .And. AJO->AJO_TAREFA == cTarefa
			RecLock("AJO",.F.)
			dbDelete()
			AJO->(MsUnlock())
			AJO->(dbSkip())
		EndDo
		
		END TRANSACTION
		
	EndIf
	RestArea(aAJOArea)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMFAJMD  บAutor  ณMarcelo Akama       บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtem a descri็ใo do item de checagem de acordo com o AJM. บฑฑ
ฑฑบDesc.     ณ Executado no evento oListBox:Bline() para colocar descri็ใoบฑฑ
ฑฑบDesc.     ณ nos itens do check-list (AJN_DESCRI ou AJO_DESCRI-virtuais)บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSMONIT                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SIMFAJMD(cCodAJM)

Local cRet	:= ""
DEFAULT cCodAJM := ""

If !Empty(cCodAJM)
	dbSelectArea("AJM")
	dbSetOrder(1)
	If MsSeek(xFilial("AJM")+cCodAJM,.F.)
		cRet := AJM->AJM_DESCRI
	EndIf
EndIf

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAJMCODBLK บAutor  ณMarcelo Akama       บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ STATIC Avalia e executa o CODEBLOCK indicado no AJM_CODEBLKบฑฑ
ฑฑบ          ณ Chamada pela fun็ใo do evento oListBox:DBLCLICK()		  บฑฑ
ฑฑบ          ณ do Check-List 											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSMONIT                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AJMCODBLK()
//////////////////////////////////////////////////////////////////////////////////////////////////////
/// TRATAMENTO DA AวรO ARMAZENADA (AJM_CODBLK) /// U_SIMBC("QI2FROMAF9",4,"T")
//////////////////////////////////////////////////////////////////////////////////////////////////////
Local nOpc
Local lRetExBlk	:= .F.
Local cExecBlk	:= "{ || "+ IIf(Empty(AJM->AJM_CODBLK),".T.",AllTrim( AJM->AJM_CODBLK )) +" }"
Local bExecBlk	:= &( cExecBlk )
cRetBloco := "OK"

If AJM->AJM_CODBLT == "3"
	lRetExBlk := Eval( bExecBlk )
	cRetBloco := IIf( lRetExBlk, 'OK', '' )
ElseIf AJM->AJM_CODBLT == "2"
	nOpc := 0
	nOpc := Aviso( STR0134+ALLTRIM(AJM->AJM_CODIGO), STR0135, {STR0136,STR0137,STR0138}) //"Check-List da Tarefa / Item: "##" Possui a็ใo armazenada, executar agora ?"##"Executar"##"Apenas Ok"##"Cancelar"
	If nOpc == 1
	    If Empty(AJM->AJM_CODBLK)
	      lRetExBlk := .T.
	    Else
	      lRetExBlk := &(AJM->AJM_CODBLK)
	    EndIf
		cRetBloco := IIf( lRetExBlk, 'OK', '' )
	ElseIf nOpc == 2
  		lRetExBlk := .T.
		cRetBloco := "OK"
	Else
		cRetBloco := ""
	EndIf
EndIf

Return( lRetExBlk )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMFCHKPNTบAutor  ณMarcelo Akama       บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pinta o ํcone Check, na linha do ListBox 				  บฑฑ
ฑฑบDesc.     ณ Chamado na fun็ใo do evento oListBox:Bline() do CheckList  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSMONIT                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SIMFCHKPNT(lChecked,cBMPChk,cBMPUnChk) /// CARREGA A IMAGEM DA PRIMEIRA POSIวรO DO LIST BOX (CHAMADA PELA oList:bLine :=

Local oLed := " "

DEFAULT lChecked	:= .F.
DEFAULT cBMPChk		:= 'WFCHK'
DEFAULT cBMPUnChk	:= 'WFUNCHK'

If lChecked
	oLed:=LoaDbitmap( GetResources(),cBMPChk)
Else
	oLed:=LoaDbitmap( GetResources(),cBMPUnChk)
EndIf

Return(oLed)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPMSMonLegณ Autor ณ  Marcelo Akama         ณ Data ณ 17-08-2010 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Programa de Exibicao de Legendas                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ PMSMONIT                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSMonLeg()
Local oBtn
Local oGrp
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oDlg

DEFINE MSDIALOG oDlg TITLE STR0140 FROM 0, 0  TO 180, 500 PIXEL //"Legenda"

@  4,   4 GROUP oGrp TO 66, 245 PROMPT STR0141 OF oDlg PIXEL //"Legenda de cores do texto da tarefa"
@ 15,  10 SAY oSay1 PROMPT STR0142 OF oDlg COLOR CLR_BLACK    PIXEL // "Tarefa em execucao"
@ 25,  10 SAY oSay2 PROMPT STR0143 OF oDlg COLOR CLR_MAGENTA  PIXEL // "Tarefa que o recurso nao e o responsavel"
@ 35,  10 SAY oSay3 PROMPT STR0144 OF oDlg COLOR CLR_HRED     PIXEL // "Tarefa em atraso"
@ 45,  10 SAY oSay4 PROMPT STR0145 OF oDlg COLOR CLR_GRAY     PIXEL // "Tarefa encerrada"
@ 55,  10 SAY oSay4 PROMPT STR0190 OF oDlg COLOR CLR_ORANGE   PIXEL // "Tarefa rejeitada"
@ 15, 130 SAY oSay5 PROMPT STR0146 OF oDlg COLOR CLR_BROWN    PIXEL // "Tarefa iniciada"
@ 25, 130 SAY oSay6 PROMPT STR0147 OF oDlg COLOR CLR_GREEN    PIXEL // "Tarefa a executar"
@ 35, 130 SAY oSay7 PROMPT STR0148 OF oDlg COLOR CLR_BLUE     PIXEL // "Tarefa a executar com restricao"
@ 45, 130 SAY oSay8 PROMPT STR0149 OF oDlg COLOR CLR_HMAGENTA PIXEL // "Tarefa em atraso com restricao"

@ 70, 205 BUTTON oBtn PROMPT STR0022 SIZE 37, 12 ACTION oDlg:End() OF oDlg PIXEL //"Fechar"

ACTIVATE MSDIALOG oDlg CENTERED
  
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPMSMonRejณ Autor ณ  Marcelo Akama         ณ Data ณ 26-08-2010 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Rejeicao de tarefas                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ PMSMONIT                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSMonRej(aTskAppont,oMsgBoard)
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFU	:= AFU->(GetArea())
Local aAreaAFF	:= AFF->(GetArea())
Local nLBox		:= 1
Local aItems	:= {}
Local nOk		:= 0
Local nHoras	:= 0
Local aMotivo	:= {}
Local aMotivos	:= {}
Local lOk		:= .T.
Local oOk 		:= LoadBitmap( GetResources(), "LBOK")
Local oNo 		:= LoadBitmap( GetResources(), "LBNO")
Local oLBox
Local oSay
Local oBtn1
Local oBtn2
Local oDlg
Local aAux
Local aAuxBlk
Local dData
Local cHora
Local cTarefa
Local nI
Local aCpyTskAp	:= aClone( aTskAppont )
Local nRecAFF
Local nPerc

Private aHeaderANA := {}
Private aColsANA   := {}

Private INCLUI     := .F.

cTarefa := AF9->AF9_TAREFA

dbSelectArea("AFU")
dbSetOrder(1)
If MsSeek( xFilial("AFU")+"1"+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA) )
	Do While !AFU->(Eof()) .And. AFU->(AFU_FILIAL+"1"+AFU_PROJET+AFU_REVISA+AFU_TAREFA)==xFilial("AFU")+"1"+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
		nHoras += AFU->AFU_HQUANT
		AFU->(dbSkip())
	EndDo
EndIf

aAuxBlk := PegaPredec(AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA, AE8->AE8_RASTRO)

aAux := {}
dbSelectArea("AFF")
dbSetOrder(1)
For nI := 1 to Len(aAuxBlk)
	If AFF->( MsSeek(xFilial("AFF")+AF9->AF9_PROJET+AF9->AF9_REVISA+aAuxBlk[nI][1]) )
		Do While !AFF->(Eof()) .And. AFF->(AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA)==xFilial("AFF")+AF9->(AF9_PROJET+AF9_REVISA)+aAuxBlk[nI][1]
			AFF->(dbSkip())
		EndDo
		AFF->(dbSkip(-1))
		nPerc := PMS310QT(.F.,"AFF")
	Else
		nPerc := 0
	EndIf
	If nPerc >= 100
		AADD(aAux, aAuxBlk[nI])
	EndIf
Next nI

If ExistBlock("PMSMON05")
	aAuxBlk := ExecBlock("PMSMON05", .T., .T., {aAux})
	If ValType(aAuxBlk) == "A"
		aAux := aAuxBlk
	EndIf
EndIf

// No caso da primeira etapa, nao permite rejeicao!
If Empty( aAux )
	Help( " ", 1, "PXFUNAPON",, STR0175, 1, 0 ) //"Nao se pode rejeitar a primeira etapa!"
	Return
EndIf

dbSelectArea("AF9")
AF9->(dbSetOrder(1))
For nI := 1 to Len(aAux)
	If AF9->( MsSeek(xFilial("AF9")+AF9->AF9_PROJET+AF9->AF9_REVISA+aAux[nI][1]) )
		AADD(aItems, {.F., AF9->AF9_TAREFA, AF9->AF9_DESCRI, aAux[nI][2], "", {}})
	EndIf
Next

DEFINE MSDIALOG oDlg TITLE STR0054 FROM 0, 0 TO 300, 550 PIXEL // "Aten็ใo"

@  4, 4 SAY oSay PROMPT STR0152 OF oDlg PIXEL // "Selecione as tarefas que serใo rejeitadas:"
@ 15, 4 LISTBOX oLBox VAR nLBox FIELDS HEADER "",STR0060,STR0061 SIZE 265, 115 OF oDlg PIXEL ON DBLCLICK IIf(VlSelPred(aItems, oLBox:nAt),(aItems[oLBox:nAt,1]:=!aItems[oLBox:nAt,1],oLBox:Refresh()),) //"Tarefa"##"Descricao"
oLBox:SetArray(aItems)
oLBox:bLine := { || {If(aItems[oLBox:nAt,1],oOk,oNo),aItems[oLBox:nAt,2],aItems[oLBox:nAt,3]}}
DEFINE SBUTTON oBtn1 FROM 135, 210 TYPE 1 OF oDlg ACTION (iif(vldLstTar(aItems),(nOk:=1, oDlg:End()),nOk := 0)) ENABLE
DEFINE SBUTTON oBtn2 FROM 135, 240 TYPE 2 OF oDlg ACTION (nOk:=0, oDlg:End()) ENABLE

ACTIVATE MSDIALOG oDlg CENTERED

If nOk == 1
	lOk := .T.
	dData := Date()
	cHora := Left(Time(),5)
	aMotivos := {}
	For nI := 1 To Len(aItems)
		If aItems[nI][1]
			aMotivo := {}
			// a funcao RejeitaTrf monta estes vetores que serao utilizados pela funcao PMA311Anexo
			aHeaderANA := {}
			aColsANA   := {}
			lOk := RejeitaTrf(aItems[nI][2], nHoras, @aMotivo)
			aItems[nI][6] := aMotivo
			AADD(aMotivos, {aItems[nI][2], aMotivo})
		EndIf
	Next nI	

	If lOk
		BEGIN TRANSACTION
			lOk := Finaliza(aTskAppont,oMsgBoard,.T.,aMotivos, cTarefa)
			if lOk
				For nI := 1 to len(aItems)
					If aItems[nI][1]
						AF8->(DbSeek(xFilial("AF8")+AF9->AF9_PROJET))
						If AF8->AF8_PAR002 <> "2" //Diferente de tarefa
							dbSelectArea("AFF")
							dbSetOrder(1)
							If AFF->( MsSeek(xFilial("AFF")+AF9->AF9_PROJET+AF9->AF9_REVISA+aItems[nI][2]+DTOS(dDatabase)) )
								nRecAFF := AFF->(Recno())
								RegToMemory("AFF", .F.)
								M->AFF_PERC   := 0
								M->AFF_QUANT  := 0
							Else
								nRecAFF := nil
								INCLUI := .T.
								RegToMemory("AFF", .T.)
								M->AFF_FILIAL := xFilial("AFF")
								M->AFF_DATA   := dDataBase
								M->AFF_PERC   := 0
								M->AFF_QUANT  := 0
								M->AFF_PROJET := AF9->AF9_PROJET
								M->AFF_REVISA := AF9->AF9_REVISA
								M->AFF_TAREFA := aItems[nI][2]
							EndIf
							PMS311Grava(.F.,nRecAFF)
					   Endif

						DbSelectArea( "AN8" )
						RecLock( "AN8", .T. )
						AN8->AN8_FILIAL		:= xFilial( "AN8" )
						AN8->AN8_PROJET		:= AF9->AF9_PROJET
						AN8->AN8_REVISA		:= AF9->AF9_REVISA
						AN8->AN8_TAREFA		:= aItems[nI][2]
						AN8->AN8_TRFORI		:= cTarefa
						AN8->AN8_DATA		:= dData
						AN8->AN8_HORA		:= cHora
						AN8->AN8_STATUS		:= ""
						AN8->AN8_HORAS		:= nHoras
						MSMM(,TamSx3("AN8_CODMEM")[1],,aItems[nI][5],1,,,"AN8","AN8_CODMEM")
						MsUnLock()
						// Grava os motivos de rejeicoes da tarefa
						If !Empty( aItems[nI][6] ) 
							If PMSCtrlRej( AF9->AF9_PROJET )
								cAlias := "ANB"

								// grava os motivos da rejeicao
								PMSGrvMotivo( .T., aItems[nI][6], aCpyTskAp[1], AF9->( RecNo() ), AN8->( RecNo() ) )

								// Projeto TDI - TELXEZ Anexo no processo de rejeicao
								if MsgYesNo(STR0200) //  "Deseja incluir anexos para os motivos informados ?"
									//	chamar a rotina de exibicao das rejeicoes com opcao de anexos
									PMA311Anexo(cAlias, aHeaderANA, aColsANA, aMotivo)
								Endif
							EndIf
						EndIf
					EndIf
				Next

				If lOk .and. AliasInDic("AN6")
					// Localiza o evento de notificacao do projeto
					DbSelectArea("AN6")
					AN6->( DbSetOrder(1) )
					AN6->( DbSeek( xFilial("AN6") + AFU->AFU_PROJET + "000000000000005" ) )
					Do While !AN6->(Eof()) .And. xFilial("AN6") + AFU->AFU_PROJET == AN6->( AN6_FILIAL + AN6_PROJET ) .And. AN6->AN6_EVENT == "000000000000005"
						// Se o campo funcao de usuario estiver preenchido deve Macroexecutar
						If !Empty( AN6->AN6_USRFUN )
							&(AN6->AN6_USRFUN)
						EndIf

						// Obtem o assunto da notificacao
						cAssunto := STR0162 // "Notifica็ใo de Evento - Rejeicao de Tarefa"
						If !Empty( AN6->AN6_ASSUNT )
							cAssunto := AN6->AN6_ASSUNT
						EndIf

						// macro executa para obter o titulo
						If Left( AllTrim( AN6->AN6_ASSUNT ), 1 ) = "="
							cAssunto := Right( cAssunto, Len( cAssunto ) -1 )
							cAssunto := &(cAssunto)
						EndIf

						// Obtem o destinatario
						cTo	:= PASeekPara( AE8->AE8_RECURS, AN6->AN6_PARA )
						cCC	:= PASeekPara( AE8->AE8_RECURS, AN6->AN6_COPIA )

						// Cria a mensagem
						cMsg := AN6->AN6_MSG

						// macro executa para obter a mensagem
						If Left( AllTrim( AN6->AN6_MSG ), 1 ) = "="
							cMsg := Right( cMsg, Len( cMsg ) -1 )
							cMsg := &(cMsg)
						EndIf

				        //Deve ser gerada uma notifica็ใo de evento do projeto encaminhando um e-mail para o superior do recurso;
						If !Empty( cTO )
							PMSSendMail(	cAssunto,; 						// Assunto
											cMsg,;							// Mensagem
											cTO,;							// Destinatario
											cCC,;							// Destinatario - Copia
											.F. )							// Se requer dominio na autenticacao
						EndIf

						AN6->( DbSkip() )

					EndDo
				EndIf
			Endif

			// Projeto TDI - TELXEZ Anexo no processo de rejeicao
			// controla a tarefa em execucao se o processo de anexo for cancelado
			if ! lOk
				// restaura a tarefa em execucao
				aTskAppont := aClone(aCpyTskAp)
			Endif

		END TRANSACTION

	Endif
EndIf

RestArea(aAreaAFF)
RestArea(aAreaAFU)
RestArea(aAreaAF9)
RestArea(aArea)
Return( lOk )

/*/{Protheus.doc} vldLstTar

Funcao que valida se na janela de selecao de tarefa para rejeicao foi selecionada alguma tarefa

@author Reynaldo Tetsu Miyashita

@since 29/11/2013

@version P10 R4

@param aItems,     array,     Codigo e descri็๕es das tarefas a serem selecionadas para rejeicao

@return lReturn, Logico, Se o retorno for verdadeiro entao foi selecionado pelo menos 1. 

/*/
Static Function vldLstTar(aItems)
Local lReturn := .F.
Local nLoop := 0

For nLoop := 1 To len(aItems)
	// se o item da lista de tarefas esta selecionado
	If aItems[nLoop,1]
		lReturn := .T.
	EndIf
Next nLoop

If !lReturn
	Help( " ", 1, "LSTTSKREJ",, STR0208, 1, 0 ) //"Nใo foi selecionado nenhuma tarefa para rejei็ใo" 
EndIf

Return lReturn


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณVlSelPredณ Autor ณ  Marcelo Akama         ณ Data ณ 26-08-2010 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Validacao de selecao de predecessoras para rejeicao          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ PMSMONIT                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VlSelPred(aItems, nPos)
Local lRet := .T.
Local nI

If !aItems[nPos][1]
	nI := 1
	Do While lRet .And. nI <= Len(aItems)
		If nI<>nPos .And. aItems[nI][1]
			If Left(aItems[nPos][4],2)==Left(aItems[nI][4],2)
				lRet := Left(aItems[nPos][4],len(aItems[nPos][4])-2)==Left(aItems[nI][4],len(aItems[nI][4])-2)
			EndIf
		EndIf
		nI++
	EndDo
EndIf

If !lRet
	MsgInfo(STR0153) //"Nao e permitido selecionar uma tarefa que esteja na mesma linha de outra tarefa ja selecionada mas em nivel diferente."
EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณRejeitaTrfณ Autor ณ  Marcelo Akama        ณ Data ณ 27-08-2010 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Rejeicao de tarefa                                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ PMSMONIT                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RejeitaTrf(cTarefa, nHoras, aMotivos)
Local oMotivo
Local oBtn1
Local oBtn2
Local oSay1
Local oSay2
Local oGrp
Local oDlg
Local lRet
Local cGetOpc		:= GD_INSERT+GD_DELETE+GD_UPDATE
Local oGDItens
Local nInc			:= 0
Local nPosTpErro	:= 0
Local nPosDesc		:= 0

Private aGets   	:= {}
Private aTela   	:= {}
Private bLinGtd		:= {|| If(Valtype(oGDItens)="O",oGDItens:nAt,0) }
Private INCLUI		:= .T.
Private oEnch
Private oGetD

// Correcao validacao de motivo - torna orbigatoria a informacao de pelo menos um motivo valido

aHeaderANA := {}
aColsANA   := {}

//***************
// Monta aCols	*
//***************
aHeaderANA			:= GetaHeader( "ANB", { "ANB_TIPERR", "ANB_MOTIVO" /*exibir*/ }, { "ANA_SEVCOD" /*nao exibir*/} )
aAdd( aColsANA, { Space( TamSX3( "ANB_TIPERR" )[1] ), Space( TamSX3( "ANB_MOTIVO" )[1] ), NIL } )
aColsANA[Len(aColsANA),Len(aHeaderANA) + 1] := .F.

Do While .T.
	DEFINE MSDIALOG oDlg TITLE STR0060+" "+cTarefa FROM 0, 0 TO 250,450 PIXEL //"Tarefa"

	@   5,   5 GROUP oGrp TO 20, 220 OF oDlg PIXEL
	@  10,   7 SAY oSay1 PROMPT STR0154+' '+alltrim(str(nHoras)) SIZE 54, 7 OF oDlg PIXEL //"Total de Horas:"
	@  20,   5 SAY oSay2 PROMPT STR0155 SIZE 25, 7 OF oDlg PIXEL //"Motivo:"

	oGDItens:= MsNewGetDados():New( 030,005,105,225, cGetOpc,,,,,,,,,, oDlg, aHeaderANA, aColsANA )

	@ 110, 147 BUTTON oBtn1 PROMPT STR0156 SIZE 37, 12 ACTION IIf( !VldRjtTrf( oGDItens, aScan( aHeaderANA, { |x| x[2] == "ANB_MOTIVO" } ) ), MsgInfo(STR0158), (lRet := .T., oDlg:End()) ) OF oDlg PIXEL //"Ok"##"Motivo nao informado"
	@ 110, 187 BUTTON oBtn2 PROMPT STR0157 SIZE 37, 12 ACTION (lRet := .F., oDlg:End()) OF oDlg PIXEL //"Cancela"

	ACTIVATE MSDIALOG oDlg CENTERED

	// Atualiza o array a motivos com as informacoes digitadas
	aMotivos := {}
	aColsANA := aClone(oGDItens:aCols)

	Exit
	
Enddo

if lRet
	nPosTpErro	:= aScan( aHeaderANA, { |x| x[2] == "ANB_TIPERR" } )
	nPosDesc	:= aScan( aHeaderANA, { |x| x[2] == "ANB_MOTIVO" } )

	For nInc := 1 To Len( aColsANA )
		if ! aColsANA[nInc,Len(aColsANA[1])]
			aAdd( aMotivos, { aColsANA[nInc,nPosTpErro], aColsANA[nInc,nPosDesc], 0 } )
		Endif	
	Next
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณVldRjtTrfณ Autor ณ Totvs                  ณ Data ณ 15-03-2011 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Validacao do motivo de rejeicao                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VldRjtTrf( oBrw, nPosDesc, nPosCod )
Local aMotivo	:= oBrw:aCols
Local nDel     := Len(aMotivo[1])
Local lRet 		:= .T.
Local nInc

Default nPosDesc := 2
Default nPosCod  := 1

For nInc := 1 To Len( aMotivo )
	if ! aMotivo[nInc,nDel] // nao excluidos
		if Empty( aMotivo[nInc,nPosDesc] ) .Or. Empty( aMotivo[nInc,nPosCod]) 
			lRet := .F.
		EndIf
	Endif	
Next

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณAprvRejeicณ Autor ณ  Marcelo Akama        ณ Data ณ 02-09-2010 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Aprovacao de rejeicao                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ PMSMONIT                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function AprvRejeic(cTarefa, nHoras, aMotivos, nUseModo )
// cTarefa  -> descricao da tarefa
// nHoras   -> total de horas
// aMotivos -> vetor com a lista dos motivos de rejeicao
Local nOpcao  := 2 	// visualizar
Local aList   := {}	// a funcao PMSMonHstR atualiza este vetor
Local nRet	  := 0
Local nInc

// Projeto TDI TELXEZ - Anexo na rejeicao da tarefa
// Le os motivos na tabela ANB e monta o vetor aList
nRet  := PmsMonHstr(nOpcao, .T., aList, nUseModo)

// Atualiza o array a motivos com as informacoes digitadas
aMotivos := {}
If nRet == 1  // aceitou a rejeicao
	For nInc := 1 To Len( aList )
		aAdd( aMotivos, { aList[nInc, posTipErr], aList[nInc, posMotivo], 0 } )
	Next
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PMSMonHstR

Historico de rejeicoes

@author Marcelo Akama

@since 09-09-2010

@version P10

@param nOpcao, 	numerico,	Op็ใo de cadastro(2-Visualizar, 3-Incluir)
@param lModo, 		Logico, Controla a exibicao dos botoes Aceita e Cancela	
@param aList, 		Array,	contem as informacoes dos registros de rejeicao da tabela ANC ou ANB
@param nUseModo, 	Numerico,	0=Padrao da Fun็ใo 1=Chamada pelo botใo apenas para visualiza็ใo 2=Cham. Botใo p/ Avalia็ใo

@return nOpcRej,	numerico, opcao de rejeicao quando parametro lModo = .T.

/*/
//-------------------------------------------------------------------
Function PMSMonHstR(nOpcao, lModo, aList, nUseModo)
Local oMotivo
Local cMotivo	:= "" // Projeto TDI TELXEZ - Anexo na rejeicao da tarefa
Local oCodErro
Local cCodErro	:= ""
Local oSay
Local oList
Local oDlg
Local aCBox		:= RetSX3Box( Posicione("SX3", 2, "AN8_STATUS", "X3CBox()"),,,1 )
Local lOk
Local cChave1
Local cChave2
Local nOpcRej := 0  // opcao de rejeicao quando parametro lModo = .T.
Local aArea := GetArea()
Local aAreaAF8 := {}
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAFF := AFF->(GetArea())
Local aAreaAN8 := AN8->(GetArea())
Local cProjeto := ""

// Projeto TDI TELXEZ - Anexo na rejeicao da tarefa
Local oClips    := LoadBitmap( GetResources(), "clips_pq" )
Local oNada     := LoadBitmap( GetResources(), "nada")   // LoadBitmap( GetResources(), "clips_pq" )
Local uRotCham    := nUseModo   // controla a gravacao se # Nil foi chamada pela rotina de aprovacao

Default nOpcao    := 2 // visualizar
Default lModo     := .F.  // controla a exibicao dos botoes Aceita e Cancela
Default nUseModo	:= 0 //0=Padrao da Fun็ใo 1=Chamada pelo botใo apenas para visualiza็ใo 2=Cham. Botใo p/ Avalia็ใo
Default aList     := {}	// a funcao PMSMonHstR atualiza este vetor

Private INCLUI := .F.
	
	If nUseModo == 0
		dbSelectArea("AF8")
		aAreaAF8 := AF8->(GetArea())
		dbSetOrder(1)
		If dbSeek(xFilial("AF8")+AF9->AF9_PROJET)
			If AF8->AF8_PAR002 == "1" // se o projeto configurado para trabalhar com rejeicao por FNC
				If ( GetNewPar("MV_QTMKPMS",0) == 3 .Or. GetNewPar("MV_QTMKPMS",0) == 4 ) // avalia se a integracao com QNC e/ou TMK estแ ativa
					// le os motivos na tabela ANC - historico de rejeicao por fnc 
						PmsLeANC(aList, AF9->AF9_FILIAL, AF9->AF9_ACAO, AF9->AF9_REVACA, AF9->AF9_TPACAO)
					Else
				Endif
			Else
				If AF8->AF8_PAR002 == "2" // se o projeto configurado para trabalhar com rejeicao por tarefa
					// le os motivos na tabela ANB- historico de rejeicao por tarefa
					PmsLeANB(aList, AF9->AF9_FILIAL, AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA, lModo)
				EndIf
			Endif
		Else	
			aList := {}
		EndIf
		RestArea(aAreaAF8) 
	Else
		PmsLeANB(aList, __TRB->AN8_FILIAL, __TRB->AN8_PROJET, __TRB->AN8_REVISA, __TRB->AN8_TAREFA, lModo)
		PmsLeANC(aList, __TRB->AN8_FILIAL, __TRB->AN8_PROJET, __TRB->AN8_REVISA, __TRB->AN8_TAREFA)
	EndIf

	If !Empty( aList )
		// Projeto TDI TELXEZ - Anexo na rejeicao da tarefa
		//vetores com as coordenadas dos objetos da tela para facilitar futuras manutencoes
		aVetDiag  := 	{000, 000, 410, 790}		// coordanadas da janela
		aVetTxt   := {	{112, 006},;				// coordenadas do texto 'cod.tp.erro'
							{158, 006}}					// coordenadas do texto 'motivo'
		aVetList  := 	{005, 004, 390, 105}		// coordenadas do LISTBOX
		aColSize  := 	{11,15,15,15,60,15,30}	// tamanhos das colunas do LISTBOX
		aVetMot   := {	{120, 005, 340, 035} ,;	// coordenadas da janela do cod.tp.erro
							{165, 005, 340, 035}}	// coordenadas da janela do motivo
		aVetButOk := {	{120,350,35,12},;			// botao Aceita / Cancela
							{143,350,35,12},;			// botao Rejeita
							{166,350,35,12} }			// botao Cancela

		if ! lModo
			DEFINE MSDIALOG oDlg TITLE STR0151+" - "+STR0060+" "+AF9->AF9_TAREFA FROM aVetDiag[1], aVetDiag[2] TO aVetDiag[3], aVetDiag[4] PIXEL STYLE nOR( DS_MODALFRAME, WS_POPUP, , WS_VISIBLE )	 //"Historico de Rejeicao"###Tarefa"
		Else	
			DEFINE MSDIALOG oDlg TITLE STR0151+" - "+STR0060+" "+AF9->AF9_TAREFA FROM aVetDiag[1], aVetDiag[2] TO aVetDiag[3], aVetDiag[4] PIXEL //"Historico de Rejeicao"###Tarefa"
		Endif

		@ aVetMot[1,1], aVetMot[1,2] GET oCodErro VAR cCodErro 	WHEN .F. OF oDlg MULTILINE SIZE aVetMot[1,3], aVetMot[1,4] HSCROLL PIXEL
		@ aVetMot[2,1], aVetMot[2,2] GET oMotivo	 VAR cMotivo 	WHEN .F. OF oDlg MULTILINE SIZE aVetMot[2,3], aVetMot[2,4] HSCROLL PIXEL

		// Projeto TDI TELXEZ - Anexo na rejeicao da tarefa
		@ aVetList[1], aVetList[2] LISTBOX oList ;
				FIELDS HEADER "   ", STR0166,STR0167,STR0182,TITSX3("ANA_DESCRI")[1],"Usr.Rej.","Nome Usr.Rej." ;
				SIZE aVetList[3], aVetList[4] PIXEL OF oDlg ;
				COLSIZES aColSize[01], aColSize[02],aColSize[03],aColSize[04],aColSize[05], aColSize[06], aColSize[07] ;
				ON CHANGE (cCodErro:=aList[oList:nAt,posTipErr]+" "+aList[oList:nAt,posDescri], oCodErro:refresh(), cMotivo:=aList[oList:nAt,posMotivo], oMotivo:refresh())  // "Data"##"Hora"##"Tp. Erro"

		oList:SetArray(aList)
		oList:bLine := {|| {aList[oList:nAt,posAnexo], aList[oList:nAt,posDataMot], aList[oList:nAt,posHoraMot], Left(aList[oList:nAt,posTipErr],aColSize[4]), Left(aList[oList:nAt,posDescri],aColSize[5]), Left(aList[oList:nAt,posCodRej],aColSize[6]), Left(aList[oList:nAt,posNomRej],aColSize[7]) }}
		oList:blDblClick := {||  MonHstClick(aList[oList:nAt,posAnexo], aList[oList:nAt,posEntidade], aList[oList:nAt,posRecno]) }

		@ aVetTxt[1,1], aVetTxt[1,2] SAY oSay PROMPT OemToAnsi(Alltrim(TITSX3(iIf(AF8->AF8_PAR002 == "1","ANB_TIPERR","ANC_TIPERR"))[1])) SIZE 45, 7 OF oDlg PIXEL //"Cod.Tp.Erro"
		@ aVetTxt[2,1], aVetTxt[2,2] SAY oSay PROMPT OemToAnsi(Alltrim(TITSX3(iIf(AF8->AF8_PAR002 == "1","ANB_MOTIVO","ANC_MOTIVO"))[1])) SIZE 45, 7 OF oDlg PIXEL //"Motivo:"
		
		cMotivo 	:= aList[1,posMotivo]
		cCodErro := aList[1,posTipErr] + " "+aList[1,posDescri]

		if lModo .and. nUseModo <> 1
			@ aVetButOk[1,1],aVetButOk[1,2] BUTTON STR0159  SIZE aVetButOk[1,3],aVetButOk[1,4] ACTION {|| nOpcRej := 1, oDlg:end() } OF oDlg PIXEL // "Aceita"
			@ aVetButOk[2,1],aVetButOk[2,2] BUTTON STR0160 SIZE aVetButOk[2,3],aVetButOk[2,4] ACTION {|| nOpcRej := 2, oDlg:end() } OF oDlg PIXEL //"Rejeita"
			@ aVetButOk[3,1],aVetButOk[3,2] BUTTON STR0157 SIZE aVetButOk[3,3],aVetButOk[3,4] ACTION {|| nOpcRej := 0, oDlg:end() } OF oDlg PIXEL //"Cancela"
		Else			
			@ aVetButOk[1,1],aVetButOk[1,2] BUTTON STR0157 SIZE aVetButOk[1,3],aVetButOk[1,4] ACTION {|| nOpcRej := 0, oDlg:end() } OF oDlg PIXEL //"Cancela"
		Endif	

		ACTIVATE MSDIALOG oDlg CENTERED

		if uRotCham <> Nil // controla se foi chamada pela rotina de aprovacao
			BEGIN TRANSACTION
				If nOpcRej == 1  // Aceita
					If nUseModo==2
						AN8->(DbGoto(__TRB->RECNO))

						if nUseModo <> 0
							AF9->( Dbseek(__TRB->AN8_FILIAL+   __TRB->AN8_PROJET + __TRB->AN8_REVISA + __TRB->AN8_TAREFA))
						Endif	

				   		// Chamado TFDSM7 -  problema no processo de rejeicao
				   		// limpa a data final 
				   		RecLock( "AF9", .F. )
						AF9->AF9_DTATUF := Ctod("")
						AF9->( MsUnLock() )

				   		// altera o status para '1' = Aceitou a Rejeicao
				   		RecLock( "AN8", .F. )
						AN8->AN8_STATUS := '1'
						AN8->( MsUnLock() )

						// atualiza o percentual da tarefa para 1%
						dbSelectArea("AFF")
						dbSetOrder(1)
						If AFF->( DbSeek(xFilial("AFF")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+DTOS(dDatabase)) )
							nRecAFF := AFF->(Recno())
							RegToMemory("AFF", .F.)
							M->AFF_PERC   := 90
							M->AFF_QUANT  := 0.9000
						Else
							nRecAFF := nil
							RegToMemory("AFF", .T.)
							M->AFF_FILIAL := xFilial("AFF")
							M->AFF_DATA   := dDataBase
							M->AFF_PERC   := 90
							M->AFF_QUANT  := 0.9000
							M->AFF_PROJET := AF9->AF9_PROJET
							M->AFF_REVISA := AF9->AF9_REVISA
							M->AFF_TAREFA := AF9->AF9_TAREFA
						EndIf
						PMS311Grava(.F.,nRecAFF)
						RestArea(aAreaAFF)

						MsAguarde({||PMSREABPRE(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA)},STR0209) //"Reabrindo predecessoras..." 

						// exclui o registro da tabela temporaria
						RecLock("__TRB", .F.)
						__TRB->( Dbdelete())
						__TRB->( Msunlock())
					   
					Endif

				// RECUSA A rejeicao
				Elseif nOpcRej == 2 
				  	If IsInCallStack("PMSLSTREJ")
						AN8->(DbGoto(__TRB->RECNO))

					   RecLock( "AN8", .F. )
					   AN8->AN8_STATUS := '2'
					   AN8->( MsUnLock() )
						
						dbSelectArea("AFF")
						dbSetOrder(1)
						If AFF->( MsSeek(xFilial("AN8")+AN8->AN8_PROJET+AN8->AN8_REVISA+AN8->AN8_TAREFA+DTOS(dDatabase)) )
							nRecAFF := AFF->(Recno())
							RegToMemory("AFF", .F.)
							M->AFF_PERC   := 100
							M->AFF_QUANT  := 1
						Else
							nRecAFF := nil
							RegToMemory("AFF", .T.)
							M->AFF_FILIAL := xFilial("AFF")
							M->AFF_DATA   := dDataBase
							M->AFF_PERC   := 100
							M->AFF_QUANT  := 1
							M->AFF_PROJET := AN8->AN8_PROJET
							M->AFF_REVISA := AN8->AN8_REVISA
							M->AFF_TAREFA := AN8->AN8_TAREFA
						EndIf
						PMS311Grava(.F.,nRecAFF)

						RecLock("__TRB", .F.)
						__TRB->( Dbdelete())
						__TRB->( Msunlock())

					Endif
				Endif	
			END TRANSACTION
			
		Endif
	Else
		Help( " ", 1, "PXHISTREJ",, STR0183, 1, 0 ) //"Nao ha historico de rejeicoes."
	EndIf

Return( nOpcRej )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsMonQtTar บAutorณAldo Barbosa dos Santosบ Data ณ  15/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe a quantidade de tarefas que esta no monitor no momento   บฑฑ
ฑฑบ          ณconsiderando os filtros iniciais                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PmsMonQtTar()

MsgAlert("Com os filtros atuais, existem "+Alltrim(Str(nQtdTarefas))+" tarefas para serem executadas.")

Return Nil



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSMonPerc  บAutorณAldo Barbosa dos Santosบ Data ณ  02/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChamado TEGO43 Percentual ja realizado da tarefa               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑบ          ณExibe o percentual ja realizado da tarefa no monitor ou a      บฑฑ
ฑฑบ          ณquantidade de horas restantes da tarefa                        บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PMSMonPerc(nModo, cFil, cProjet, cRevisa, cTarefa)
// nModo   => 1=Execucao via menu; 2=Execucao pelo Monitor
// cFilial => Filial da tarefa
// cProjet => Projeto da tarefa
// cRevisa => Revisao do projeto
// cTarefa => Tarefa

Local aArea    := GetArea()
Local cQuery   := ""
Local uRetorno := .T.
Local cAlias, nQtdAFU, nQtdMinutos, nQtdHora, nQtdMon, dDataAFW,cHoraAFW, nSaldo

Default cFil    := AF9->AF9_FILIAL
Default cProjet := AF9->AF9_PROJET
Default cRevisa := AF9->AF9_REVISA
Default cTarefa := AF9->AF9_TAREFA
Default nModo   := 1

// horas ja apontadas no AFU em formato decimal
cQuery := "Select SUM(AFU_HQUANT) QTDHORAS From "+RetSqlName("AFU") + " AFU "
cQuery += "Where AFU_FILIAL = '"+cFil+"'  "
cQuery += "  and AFU_PROJET = '"+cProjet+"' "
cQuery += "  and AFU_REVISA = '"+cRevisa+"' "
cQuery += "  and AFU_TAREFA = '"+cTarefa+"' "
cQuery += "  and D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
cAlias :=	GetNextAlias()
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)
TCSetField(cAlias,"QTDHORAS","N",12,2)

// transformando de decimal para minutos
nQtdAFU		:= (cAlias)->QTDHORAS 
nQtdMinutos := nQtdAFU*60

(cAlias)->( DbcloseArea())


// horas em apontamento atraves do monitor - horario inicial no formado hora
cQuery := "Select AFW_DATA, AFW_HORA From "+RetSqlName("AFW") + " AFW "
cQuery += "Where AFW_FILIAL = '"+cFil+"'  "
cQuery += "  and AFW_PROJET = '"+cProjet+"' "
cQuery += "  and AFW_TAREFA = '"+cTarefa+"' "
cQuery += "  and D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
cAlias :=	GetNextAlias()
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)

TCSetField(cAlias,"AFW_DATA","D",8,0)
TCSetField(cAlias,"AFW_HORA","C",5,0)
dDataAFW := (cAlias)->AFW_DATA
cHoraAFW := (cAlias)->AFW_HORA + ":00"
(cAlias)->( DbcloseArea())

// se tem apontamento em execucao deve calcular os minutos ate o momento atual
nQtdMon := 0
if ! Empty(dDataAFW)
	cTempo := INTERVALO(dDataAFW,cHoraAFW, Date(),Left(Time(),5)+"00" )
	
	// conversao da diferenca de agora ate o inicio do apontamento para minutos
	nQtdHora := Val(Left(cTempo,2)) * 60
	nQtdMin  := Val(Substr(cTempo,4,2))
	nQtdMon  := nQtdHora+nQtdMin  // quantidade de minutos desde o inicio da execucao da tarefa atual
Endif	          

// total de minutos apontados somados aos minutos do monitor em execucao
nQtdMinutos += nQtdMon


// localizacao das horas alocadas para o recurso na tarefa considerando a alocacao de recursos no AFA
cQuery := "select AFA_QUANT From "+RetSqlName("AFA") + " AFA "
cQuery += "Where AFA_FILIAL = '"+cFil+"'  "
cQuery += "  and AFA_PROJET = '"+cProjet+"' "
cQuery += "  and AFA_REVISA = '"+cRevisa+"' "
cQuery += "  and AFA_TAREFA = '"+cTarefa+"' "
cQuery += "  and D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
cAlias :=	GetNextAlias()
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)

nQtdProp := (cAlias)->AFA_QUANT // quantidade de horas reservadas para o recurso na tarefa
(cAlias)->( DbcloseArea())

// calculo do percentual ja executado ate agora
nQtdTar	:= nQtdProp * 60					// converte as horas do recurso em minutos
nPerc	:= ( nQtdMinutos / nQtdTar ) * 100	// calculo do percentual ja realizado

nQtdHoras := ( nQtdMinutos / 60 )
cHoraUsada := AllTrim( Transform(Int(Abs(nQtdHoras)),"@E 999,999") )  + ":" + Strzero((nQtdHoras-Int(nQtdHoras))*60,2) 

nSaldo := ( nQtdTar - nQtdMinutos ) / 60

if nModo == 1
	MsgAlert(;
	"Jแ foram utilizadas " + cHoraUsada +;
	" horas da tarefa, correspondendo a " + AllTrim( Transform( nPerc,"@e 999,999.9" ) ) + "% do total." + Chr( 13 ) + ;
	If( nSaldo >= 0, "Restam ", "A tarefa ultrapassou em ") + AllTrim( Transform(Int(Abs(nSaldo)),"@E 999,999") ) + ":" +;
	Strzero( (Abs(nSaldo) - Int(Abs(nSaldo)))*60, 2 ) + " horas " +;
	If( nSaldo >= 0, "de saldo para esta tarefa", "a quantidade prevista" ) )
Else
	uRetorno := If(nSaldo>=0,AllTrim( Transform(Int(Abs(nSaldo)),"@E 999,999") )+":"+Strzero((Abs(nSaldo)-Int(Abs(nSaldo)))*60,2),"00:00")
Endif

RestArea(aArea)

Return( uRetorno )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIntervalo   บAutorณAldo Barbosa dos Santosบ Data ณ  04/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPermite o calculo de tempo com base em data/hora inicio e      บฑฑ
ฑฑบ          ณdata/hora fim (copiada da internet)                            บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static function INTERVALO(d1,h1,d2,h2)
private d:=0,h:=0,m:=0,s,si

si=iif(d2>d1 .or. (d2=d1 .and. h2>h1),1,0)
h1=(val(left(h1,2))*60)+val(subst(h1,4,2))
h2=(val(left(h2,2))*60)+val(subst(h2,4,2))
if si=1
  d2=((d2-d1)*1440)+h2
  d1=h1
  s=d2-d1
else
  d1=((d1-d2)*1440)+h1
  d2=h2
  s=d1-d2
endif

do while .t.
  if s>59
    if (s/60)>24
      d=int(s/60/24)
      s=s-(d*24*60)
    else
      h=int(s/60)
      s=s-(h*60)
      if h=24
        h=0
        d=d+1
      endif
    endif
  else
    m=s
    exit
  endif
enddo
s=iif((d+h+m)=0,"",iif(si=0,"-",""))

return( s+""+strzero(h+(d*24),2)+":"+strzero(m,2) )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSIniTsk   บAutorณWagner Montenegroบ Data ณ  26/04/12         บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicializa aCloneTSK para PMSLstReJ                            บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PMSIniTsk(aCloneTsk,cRecurso)
Default aCloneTsk:=NewIni()
AF9->(DbSetOrder(1))
If AF9->(DbSeek(xFilial("AF9")+__TRB->AN8_PROJET+__TRB->AN8_REVISA+__TRB->AN8_TAREFA))
	aCloneTsk[1]	:= cRecurso //__TRB->AN8_RECURS
	aCloneTsk[2]	:= Str( AF9->( RecNo() ) )
	aCloneTsk[3]	:= __TRB->AN8_PROJET
	aCloneTsk[4]	:= __TRB->AN8_REVISA
	aCloneTsk[5]	:= __TRB->AN8_TAREFA
	aCloneTsk[6]	:= TiraCharEsp( AllTrim( AF9->AF9_DESCRI ) )
	aCloneTsk[7]	:= DtoS(__TRB->AN8_DATA) //DtoS( MSDate() )
	aCloneTsk[8]	:= __TRB->AN8_HORA //Left( Time(), 5 )
Endif
Return(aCloneTsk)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSLstReJ   บAutorณWagner Montenegroบ Data ณ  26/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAvalia็ใo de Rejei็๕es                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PMSLstReJ(nModoAval,aTskAppont,cRecurso, lMsg)
// lMsg -> exibe ou nao as mensagens em tela

Local oDlg
Local aGetArea:=GetArea()
Local nHorWin := 585
Local nPosBut3:= nHorWin-300
Local nPosBut2:= nPosBut3-40
Local nPosBut1:= nPosBut2-40
Local cString
Local nCountS
Local cNomeArq := ""
Local cIndex :=""
Local cChave :=""
Local nX
Local aStruct:={}
Local oPmsMonit	:= Nil

// Chamado TDI TFDSM7
Local lRet := .F. // retorno da funcao (.T. = tem rejeicoes pendentes)

Private aHeader:={}
Private aCampos:={}

Default aTskAppont:={}
Default nModoAval :=0
Default lMsg := .T.

Private INCLUI := .F.
Private aIndex		:= {}

// Obs: este array aRotina foi inserido apenas para permitir o
// funcionamento das rotinas internas da MSGETDB
If Type("aRotina") != "A"
	Private aRotina := { { "aRotina Falso", "AxInclui", 0 , 1} }
Endif

cString := "SELECT COUNT(*) NCOUNT FROM "+RetSQLName("AN8")+" AN8 INNER JOIN "+RetSQLName("AFA")+" AFA ON AN8.AN8_FILIAL=AFA.AFA_FILIAL AND AN8_PROJET=AFA_PROJET AND AN8_REVISA=AFA_REVISA AND AN8_TAREFA=AFA_TAREFA  WHERE AFA.AFA_FILIAL='"+xFilial("AFA")+"' AND AFA.AFA_RECURS='"+cRecurso+"' AND AFA.D_E_L_E_T_<>'*' AND  AN8.AN8_STATUS=' ' AND AN8.D_E_L_E_T_<>'*'"
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cString),"__TRBREJ", .F., .T.)

nCountS := Round(__TRBREJ->NCOUNT,0)

If nModoAval==0
	If nCountS > 0
		cString := "SELECT AN8_FILIAL,AN8_PROJET,AN8_REVISA,AN8_TAREFA,AN8_TRFORI,AN8_DATA,AN8_HORA,AN8_HORAS,AN8_STATUS,AN8_CODMEM,AN8.R_E_C_N_O_ FROM "+RetSQLName("AN8")
		cString += " AN8 INNER JOIN "+RetSQLName("AFA")+" AFA ON AN8.AN8_FILIAL=AFA.AFA_FILIAL AND AN8_PROJET=AFA_PROJET AND AN8_REVISA=AFA_REVISA AND AN8_TAREFA=AFA_TAREFA"
		cString += " WHERE AFA.AFA_FILIAL='"+xFilial("AFA")+"' AND AFA.AFA_RECURS='"+cRecurso+"' AND AFA.D_E_L_E_T_<>'*' AND  AN8.AN8_STATUS=' ' AND AN8.D_E_L_E_T_=' '"
		cString += " ORDER BY AN8_DATA,AN8_HORA"
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cString),"__TRBAPR", .F., .T.)
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AN8")
		While !EOF() .And. (X3_ARQUIVO == "AN8")
			If X3_CAMPO $ "AN8_FILIAL/AN8_PROJET/AN8_REVISA/AN8_TAREFA/AN8_TRFORI/AN8_CODMEM/AN8_DATA  /AN8_HORA  /AN8_HORAS  "
			   AADD(aHeader,{ TRIM(X3Titulo()), X3_CAMPO, X3_PICTURE,;
				X3_TAMANHO, X3_DECIMAL, X3_VALID,;
				X3_USADO, X3_TIPO, "__TRBAPR", X3_CONTEXT } )
				AADD(aCampos, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO,SX3->X3_DECIMAL } )
				AADD(aStruct,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			EndIf
			SX3->(dbSkip())
		EndDO
		AADD(aStruct,{"RECNO","N",10,0})  
		AADD(aStruct,{"FLAG","L",1,0})
		
		
		//Cria o Objeto do FwTemporaryTable
		oPmsMonit := FwTemporaryTable():New("__TRB") 
		
		//Cria a estrutura do alias temporario
		oPmsMonit:SetFields(aStruct)

		//Criando a Tabela Temporaria
		oPmsMonit:Create()
		
	   DbSelectarea("__TRBAPR")
		__TRBAPR->(DbGoTop())
		While !__TRBAPR->(EOF())
			If __TRB->(RecLock("__TRB",.T.))
				For nX := 1 to Len( aCampos )
				   If aCampos[nX][2]=="D"
				      __TRB->(FieldPut(nX,STOD(&("__TRBAPR->"+(aCampos[nX][1])))))
			   	Else
				  		__TRB->(FieldPut(nX,&("__TRBAPR->"+(aCampos[nX][1]))))
				  	Endif
				Next
			Endif
			__TRB->RECNO := __TRBAPR->R_E_C_N_O_
			__TRB->(MsUnlock())
			__TRBAPR->(DbSkip())
		Enddo
		__TRB->(DbGoTop())

		DEFINE MSDIALOG oDlg FROM 0,0 TO 400,650 PIXEL TITLE STR0197 //'Avalia็ใo de Rejei็ใo'
	   oBrowse:= MsGetDB():New(1,1,180,326,1,,,,,,,.T.,,"__TRB")
		TButton():New(185,nPosBut2, STR0194 ,oDlg,{|| If(!Empty(__TRB->AN8_PROJET),AprvRejeic(__TRB->AN8_PROJET,__TRB->AN8_HORAS,E_MSMM(__TRB->AN8_CODMEM),1),oBrowse:Refresh()),oBrowse:ForceRefresh()},38,12,,,,.T.) //'Visualizar'
		TButton():New(185,nPosBut1, STR0195 ,oDlg,{|| If(!Empty(__TRB->AN8_PROJET),AprvRejeic(__TRB->AN8_PROJET,__TRB->AN8_HORAS,E_MSMM(__TRB->AN8_CODMEM),2),oBrowse:Refresh()),oBrowse:ForceRefresh()},38,12,,,,.T.) //'Avaliar'  //		TButton():New(185,nPosBut1, STR0195 ,oDlg,{|| If(!Empty(__TRB->AN8_PROJET),Finaliza(PMSIniTsk(aTskAppont,cRecurso)),oBrowse:ForceRefresh()),oBrowse:ForceRefresh()},38,12,,,,.T.) //'Avaliar'
		TButton():New(185,nPosBut3, STR0196 ,oDlg,{|| oDlg:End()},38,12,,,,.T.) //'Fechar'
		ACTIVATE MSDIALOG oDlg CENTERED
		__TRBAPR->(DbCloseArea())
	Else
		if lMsg 
			Aviso( STR0197, STR0198, { "Ok" }, 2 ) //"Avalia็ใo de Rejei็ใo", "Voc๊ nใo possui rejei็๕es para avaliar."
		Endif
		lRet := .T.	
	Endif
Else
	If nCountS > 0
		if lMsg
			Aviso( STR0197, STR0199, { "Ok" }, 2 ) //"Avalia็ใo de Rejei็ใo","Aten็ใo, voc๊ possui rejei็๕es para avalia็ใo."
		Endif	
		lRet := .T.
	Endif
Endif

If Select("__TRBREJ")>0
	__TRBREJ->(DbCloseArea())
Endif

If Select("__TRB")>0
	__TRB->(DbCloseArea())
Endif

If oPmsMonit <> Nil
	oPmsMonit:Delete()
	oPmsMonit := Nil
Endif

RestArea(aGetArea)

Return( lRet )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonHstClick บAutorณAldo Barbosa dos Santosบ Data ณ  07/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณA tela de anexos                                               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MonHstClick(oAnexo, cAlias, nReg)
// cAnexo - campo do vetor que controla o anexo
// cAlias - alias do registro para o banco de conhecimento
// nReg   - numero registro da tabela que sera direcionado para o banco de conhecimento
Local lRet		:= .F.
Local nOpc	:= 2

SaveInter()
// entra na execucao do MsDocument apenas se existir anexo para evitar erros
if ! Empty(cAlias) .and. oAnexo:cname <> oNada:cname
	lRet := MsDocument(cAlias, nReg, nOpc)
EndIf

RestInter()

Return( lRet )



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsLeANB    บAutorณAldo Barbosa dos Santosบ Data ณ  25/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a query e carrega o vetor com os motivos da tabela ANB   บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PmsLeANB(aList, cFilAF9, cProAF9, cRevAF9, cTarAF9, lModo)
// aList   -> vetor com os motivos (retorna por referencia)
// cFilAF9 -> filial
// cProAF9 -> projeto
// cRevAF9 -> revisao
// cTarAF9 -> tarefa
// lModo   -> .T. somente a ultima rejeicao
Local aArea := {ANB->( GetArea()), GetArea()}
Local cQuery, nA
Default lModo := .F.

// localiza os motivos da rejeicao
cQuery := "SELECT ANB_PROJET, ANB_REVISA, ANB_DATA DATAMOT, ANB_HORA HORAMOT, ANB_TIPERR TIPERR, ANB.R_E_C_N_O_ REGMOT, ANB_REJEIT REJEIT, ANB_EXEC EXECUTOR, ANA_DESCRI, ANB_ITEM ITEMMOT "
cQuery += "FROM "+RetSqlName("ANB")+" ANB "
cQuery += " INNER JOIN "+RetSqlName("ANA")+" ANA ON "
cQuery += " ANA.ANA_FILIAL = '"+xFilial("ANA")+"' AND ANA.ANA_CODIGO = ANB.ANB_TIPERR AND ANA.D_E_L_E_T_ = ' ' "
cQuery += "WHERE ANB_FILIAL = '"+xFilial("ANB")+"' AND ANB_PROJET = '"+cProAF9+"' AND ANB_REVISA = '"+cRevAF9+"' AND ANB_TAREFA = '"+cTarAF9+"' AND ANB.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY ANB_FILIAL DESC, ANB_DATA DESC, ANB_HORA DESC, ITEMMOT ASC "

// executa a query e monta o vetor
PmsLeMot( "ANB", cQuery, aList, lModo )

For nA := 1 to Len(aArea)
	RestArea(aArea[nA])
Next

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsLeANC    บAutorณAldo Barbosa dos Santosบ Data ณ  25/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a query e carrega o vetor com os motivos da tabela ANC   บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PmsLeANC(aList, cFilAF9, cProAF9, cRevAF9, cTpaAF9)
// aList   -> vetor com os motivos (retorna por referencia)
// cFilAF9 -> filial
// cProAF9 -> projeto
// cRevAF9 -> revisao
// cTarAF9 -> tarefa
Local aArea := {AN8->( GetArea()), AF9->( GetArea()), ANC->( GetArea()), QI5->( GetArea()), GetArea()}
Local cFilQI5, cCodQI5, cRevQI5, cSeqQI5, nRevQI5
Local cQuery, nA

cFilQI5 := Space(Len(QI5->QI5_FILIAL))
cCodQI5 := Space(Len(QI5->QI5_CODIGO))
cRevQI5 := Space(Len(QI5->QI5_REV))
cSeqQI5 := Space(Len(QI5->QI5_SEQ))

// localiza a acao atual
QI5->(dbSetOrder(6)) // QI5_FILIAL+QI5_PROJET+QI5_TAREFA+QI5_CODIGO+QI5_REV+QI5_TPACAO
If QI5->(DbSeek( cFilAF9 + cProAF9 + cTpaAF9))
	cFilQI5 := QI5->QI5_FILIAL
	cCodQI5 := QI5->QI5_CODIGO
	cRevQI5 := QI5->QI5_REV
	cSeqQI5 := QI5->QI5_SEQ
EndIf

// se for a revisao maior que a revisao 00 subtrai 1 para achar a revisao anterior
if cRevQI5 > Replicate("0",Len(cRevQi5))
	nRevQI5 := Val(cRevQI5) - 1
	cRevQI5 := Strzero(nRevQI5,Len(cRevQi5))
Endif

// localiza o ultimo registro do plano anterior
AF9->( Dbsetorder(6))  // AF9_FILIAL+AF9_ACAO+AF9_REVACA+AF9_TPACAO
AF9->( Dbseek(cFilQi5+cCodQI5+cRevQI5))
cTarefa := AF9->AF9_TAREFA

Do While AF9->( ! EOF()) .and. AF9->AF9_FILIAL == cFilQi5 .and.;
         AF9->AF9_ACAO == cCodQi5 .and. AF9->AF9_REVACA == cRevQi5 
	cTarefa := AF9->AF9_TAREFA
	if Empty(AF9->AF9_DTATUF)
		Exit
	Endif
	AF9->( Dbskip())
Enddo		

// localiza os motivos da rejeicao
cQuery := "SELECT QI5_CODIGO, QI5_REV, ANC_DATA DATAMOT, ANC_HORA HORAMOT, ANC_TIPERR TIPERR, ANC.R_E_C_N_O_ REGMOT, ANC_REJEIT REJEIT, ANC_EXEC EXECUCAO, ANA_DESCRI "
cQuery += "FROM "+RetSqlName("QI5")+" QI5, "+RetSqlName("ANC")+" ANC, "+RetSqlName("ANA")+" ANA "
cQuery += "WHERE QI5_FILIAL = '"+cFilQI5+"' AND QI5_CODIGO = '"+cCodQI5+"' AND QI5_REV = '"+cRevQI5+"' "
cQuery += "  AND QI5_TAREFA = '"+cTarefa+"' AND QI5.D_E_L_E_T_ = ' ' "
cQuery += "  AND ANC_FILIAL = QI5_FILIAL AND ANC_PROJET = QI5_PROJET AND ANC_TAREFA = QI5_TAREFA AND ANC.D_E_L_E_T_ = ' '   "
cQuery += "  AND ANA_CODIGO = ANC_TIPERR AND ANA.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY ANC_FILIAL ASC, ANC_DATA ASC, ANC_HORA ASC  "

// executa a query e monta o vetor
PmsLeMot( "ANC", cQuery, aList )

For nA := 1 to Len(aArea)
	RestArea(aArea[nA])
Next

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsLeMot    บAutorณAldo Barbosa dos Santosบ Data ณ  25/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os motivos no array                                    บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PmsLeMot(cEntidade, cQuery, aList, lModo)
Local aArea   := GetArea()
Local oClips  := LoadBitmap( GetResources(), "clips_pq") // LoadBitmap( GetResources(), "clips_pq" )
Local oNada   := LoadBitmap( GetResources(), "nada")  // LoadBitmap( GetResources(), "clips_pq" )
Local cCodEnt := ""
Local cAlias

Default lModo := .F.

// a query e montadada em funcao especifico
cQuery := ChangeQuery(cQuery)
cAlias := GetNextAlias()
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)
TCSetField(cAlias,"DATAMOT","D",8,0)

cChave := (cAlias)->(Dtos(DATAMOT)+HORAMOT)
Do While (cAlias)->( ! Eof()) .and. if(lModo, cChave == (cAlias)->(Dtos(DATAMOT)+HORAMOT), .T.)
	// posiciona no registro que esta sendo lido pois as funcoes de anexo necessitam do registro posicionado
	DbselectArea( cEntidade )
	(cEntidade)->( Dbgoto((cAlias)->REGMOT))

	// localizar o nome e codigo do usuario que rejeitou
	if cEntidade == "ANB"
		aRetUser := PmsUsuario(Nil,(cAlias)->REJEIT)
	Else
		aRetUser := PmsUsuario((cAlias)->REJEIT)
	Endif
	
	
	cCodRej  := Alltrim(aRetUser[2])
	cNomRej  := iIf(Empty(aRetUser[4]), STR0210, Alltrim(aRetUser[4])) //"Nใo Encontrado"

	// localizar o nome e codigo do usuario que executou
	if cEntidade == "ANB"
		aRetUser := PmsUsuario(Nil, (cAlias)->EXECUTOR)
	Else
		aRetUser := PmsUsuario((cAlias)->EXECUTOR)
	Endif
	cCodExe  := Alltrim(aRetUser[2])
	cNomExe  := iIf(Empty(aRetUser[4]), STR0210, Alltrim(aRetUser[4])) //"Nใo Encontrado"
	

	// verifica se a rejeicao tem anexos
	lAnexo  := .F.
	cCodEnt := ""
	if PmsMonCodEnt(cEntidade, @cCodEnt)
		lAnexo := PmsMonAnexo(xFilial("AC9"),cEntidade,xFilial(cEntidade),cCodent)
	Endif

	// Projeto TDI TELXEZ - Anexo na rejeicao da tarefa
	Aadd(aList,{ DTOC((cAlias)->DATAMOT),; 		// [01] Data
					 (cAlias)->HORAMOT			,; 	// [02] Hora
					 (cAlias)->TIPERR				,; 	// [03] Cod Tipo de Erro
					 (cAlias)->ANA_DESCRI		,; 	// [04] Descricao do tipo de erro
					 if(cEntidade=="ANB",ANB->ANB_MOTIVO,ANC->ANC_MOTIVO )	,; // [05] descricao do motivo
					 cCodRej 						,; 	// [06] descricao do motivo
					 cNomRej							,; 	// [07] descricao do motivo
					 if(lAnexo,oClips, oNada)	,; 	// [08] icone de anexo
					 cEntidade						,; 	// [09] alias utilizado na pesquisa
					 (cEntidade)->( Recno()) ,;		// [10] registro da anc
					 0 })										// [11] quantidade de horas

	(cAlias)->( Dbskip())
Enddo

(cAlias)->( DbcloseArea())

RestArea(aArea)

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsUsuario  บAutorณAldo Barbosa dos Santosบ Data ณ  25/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLocaliza o codigo e nome do usuario                            บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PmsUsuario( cCodUsu, cCodAE8 )
Local aArea := GetArea()
Local aAreaAE8 := {}
Local aRet := Array(30)
Default cCodUsu := ""
Default cCodAE8 := ""

aFill(aRet,"")

if ! Empty(cCodAE8)
	dbSelectArea("AE8")
	aAreaAE8 := AE8->(GetArea())
	Dbsetorder(1)    // AE8_FILIAL+AE8_RECURS+AE8_DESCRI
	If Dbseek(xFilial("AE8")+cCodAE8)
		cCodUsu := AE8->AE8_USER
		PswOrder(1)
		if PswSeek(cCodUsu)
			aRet := PswRet(1)[1]
		Endif
	EndIf
	RestArea(aAreaAE8)
Endif

RestArea(aArea)
Return( aClone(aRet) )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsMonAnexo บAutorณAldo Barbosa dos Santosบ Data ณ  25/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLocaliza se o motivo tem anexo                                 บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PmsMonAnexo(cFilAC9, cEntidade, cFilEnt, cCodent)
Local aArea := { AC9->( GetArea()), GetArea() }
Local lRet  := .F.
Local cQuery, cAlias, nA

#IFDEF TOP
	cQuery := "SELECT Count(AC9.R_E_C_N_O_) QTDAC9 FROM " + RetSqlName( "AC9" ) + " AC9 "
	cQuery += "WHERE "
	cQuery += "AC9_FILIAL='" + xFilial( "AC9" )     + "' AND "
	cQuery += "AC9_FILENT='" + xFilial( cEntidade ) + "' AND "
	cQuery += "AC9_ENTIDA='" + cEntidade            + "' AND "
	cQuery += "AC9_CODENT='" + Left(cCodEnt,Len(AC9->AC9_CODENT))   + "' AND "
	cQuery += "D_E_L_E_T_<>'*' "
	cQuery := ChangeQuery(cQuery)
	cAlias :=	GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)
	TcSetField(cAlias,"QTDAC9","N",10,0)

	lRet := (cAlias)->QTDAC9 > 0
	(cAlias)->( DbcloseArea())
#ELSE
	AC9->( Dbsetorder(2))  // AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
	lRet := AC9->( Dbseek(xFilial("AC9")+cEntidade+xFilial(cEntidade)+Left(cCodent,Len(AC9->AC9_CODENT))))
#ENDIF

For nA := 1 to Len(aArea)
	RestArea(aArea[nA])
Next

Return( lRet )



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsMonCodEntบAutorณAldo Barbosa dos Santosบ Data ณ  31/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLocaliza o codigo da entidade para localizacao de anexo        บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PmsMonCodEnt(cEntidade, cCodEnt, cCodDesc)
// @cCodEnt  -> retorna o codigo da entidade
// @cCodDesc -> retorna a descricao
// lAchou    -> .T. encontrou o codigo da entidade
Local aEntidade		:= MsRelation()
Local nScan 		:= AScan( aEntidade, { |x| x[1] == cEntidade } )
Local lAchou		:= .F.
Local aArea			:= { SX2->( GetArea()), (cEntidade)->( GetArea()), GetArea()}
Local nA			:= 0
Local aChave		:= {}
Local cUnico		:= ""

DbSelectArea(cEntidade)

If Empty( nScan )
	// Localiza a chave unica pelo SX2
	cUnico   := FWX2Unico(cEntidade)
	If ! Empty(cUnico)
		cCodEnt  := Left((cEntidade)->( &cUnico ),Len(AC9->AC9_CODENT))	// Macro executa a chave unica
		cCodDesc := Substr( AllTrim( cCodEnt ), TamSX3("A1_FILIAL")[1] + 1 )
		lAchou   := .T.
	EndIf
Else
	aChave   := aEntidade[ nScan, 2 ]
	cCodEnt  := MaBuildKey( cEntidade, aChave )
	cCodDesc := AllTrim( cCodEnt ) + "-" + Capital( Eval( aEntidade[ nScan, 3 ] ) )
	lAchou := .T.
EndIf

For nA := 1 to Len(aArea)
	RestArea(aArea[1])
Next nA
FreeObj(aArea)
Return( lAchou )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAN7CHANVE บAutor  ณMicrosiga           บ Data ณ  08/17/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AN7Change( cAliasTarefas, cSource, cTarget )
Local cRet	:= "PMSMONIT"
Local cUser	:= oApp:cUserID
Local aArea	:= GetArea( )

Default cSource := "PMSCFGREC"
Default cTarget := "PMSMONIT"

cSource := PADR( "PMSCFGREC",10 )
cTarget := PADR( "PMSMONIT", 10 )

DBSelectArea( "AN7" )		// Filtro de Usuario por Rotina
AN7->( DBSetOrder( 1 ) )	// AN7_FILIAL+AN7_USER+AN7_FUNCAO+AN7_ALIAS+AN7_FILTR

While AN7->( MsSeek( xFilial( "AN7" ) + cUser + cSource + cAliasTarefas ) )
	RecLock( "AN7", .F. )
	AN7_FUNCAO := cTarget
	MsUnlock( )
EndDo

RestArea( aArea )
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsMonVLDบAutorณRamon Nevesบ 				  Data ณ  22/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidar se usuแrio pode visualizar dados do recurso selecionadoบฑฑ
ฑฑบ          ณconsiderando hierarquia e equipes                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Function PMSMONVLD(aCfgMon)
Local lRet		    := .T.
Local cRecUsu		:= ""
Local cEquipeUsu	:= "" 
Local cFuncUsu		:= ""
Local nPosUsu		:= 0
Local cRec2			:= ""
Local cEquipe2		:= ""
Local cFunc2		:= ""
Local nPos2			:= 0
Local aAN1			:= {}  
Local aAreaAN1		:= {} 
Local aAreaAE8		:= {}
Local lValid        := .T.

If ExistBlock("PMSMONLIB")
	lValid:=ExecBlock("PMSMONLIB",.F.,.F.)
EndIf
 

If lValid
	If lRet
		DbSelectArea("AE8")
		aAreaAE8 := AE8->(GetArea())
		DbSetOrder(1) // buscar pelo codigo do funcionario
		If dbSeek(xFilial()+aCfgMon[1])
			cRecUsu	:= AE8->AE8_RECURS  
			cEquipeUsu	:= AE8->AE8_EQUIP 
			cFuncUsu	:= AE8->AE8_FUNCAO
			lRet		:= .T.  
		Else
			lRet := .F.		
		EndIf
		RestArea(aAreaAE8)          
	EndIf	
	
	If lRet
		DbSelectArea("AE8")
		aAreaAE8 := AE8->(GetArea())
		DbSetOrder(3) // buscar pelo codigo do funcionario
		If dbSeek(xFilial()+__cUserID)
			cRec2		:= AE8->AE8_RECURS  
			cEquipe2	:= AE8->AE8_EQUIP
			cFunc2		:= AE8->AE8_FUNCAO
			lRet		:= .T.  
		Else
			lRet := .F.		
		EndIf
		RestArea(aAreaAE8)          
	EndIf	
	
	// 
	If !Empty(cRecUsu) .and. Empty(cFuncUsu) .AND. Empty(cFunc2)
		lRet := .T.
	Else
		If lRet 
			If cEquipeUsu == cEquipe2 
				DbSelectArea("AN1")
				aAreaAN1 := AN1->(GetArea())
				DbSetOrder(2) //FILIAL+NIVSUP(NIVEL SUPERIOR)
				AN1->(DbGoTop())
				While AN1->(!EOF()) .AND. XFILIAL("AN1") == AN1->AN1_FILIAL
					AADD(aAN1, AllTrim(AN1->AN1_CODIGO) )     //preenche o array de acordo com a hierarqui de funcoes
					AN1->(DbSkip())
				EndDo		
				RestArea(aAreaAN1)
				If ValType(aAN1) == "A"
					nPosUsu	:= aScan(aAN1, AllTrim(cFuncUsu))	
					nPos2	:= aScan(aAN1, AllTrim(cFunc2))	
				EndIf
				If nPosUsu < nPos2       //
					Help( " ", 1, "PHIERARQUIA",, STR0202, 1, 0 ) //'Usuแrio sem permissใo para visualizar dados devido regras de hierarquia'
					lRet := .F.
				EndIf
				RestArea(aAreaAN1)  				   
			Else
				lRet := .F.
				Help( " ", 1, "PDIFEQUIPE",, STR0201, 1, 0 ) //'Usuแrio sem permissใo para visualizar dados de recursos de outra equipe'
			EndIf		
		EndIf
	EndIf
EndIF		
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSREABPREบAutor  ณMicrosiga           บ Data ณ  04/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PMSREABPRE(cProjeto,cRevisao,cTarefa)
Local aAreaAF9   := AF9->(GetArea())
Local aAreaAFD   := AFD->(GetArea())
Local aAreaAFF   := AFF->(GetArea())
Local aPredec	 := {}
Local lAchouPred := .T.
Local lReabre    := .F.
Local nOpc 		 := 0
Local nTotPred	 := 0 
Local _nPerc     := 0
Local cAliasAFF	 := ""

Default cProjeto := ""
Default cRevisao := ""
Default cTarefa  := ""

If !Empty(cProjeto) .And. !Empty(cRevisao) .And.!Empty(cTarefa) 
	DbSelectArea("AFD")
	AFD->(DbSetOrder(2))
	//BUSCA TODAS AS PREDECESSORA ENVOLVIDAS
	If AFD->(DbSeek(xFilial("AFD")+cProjeto+cRevisao+cTarefa))
		//adiciona as tarefas que possuem a atual como predecessoras para reabertura
		While AFD->(!EOF()) .And. AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_PREDEC == xFilial("AFD")+cProjeto+cRevisao+cTarefa
			AADD(aPredec,{AFD->AFD_PROJET,AFD->AFD_REVISA,AFD->AFD_TAREFA})
			AFD->(DbSkip())
		EndDo
		//varre as demais predecess๕es para reabertura
		While lAchouPred
			lAchouPred := .F.
			For nTotPred := 1 to Len(aPredec)
				If AFD->(DbSeek(xFilial("AFD")+aPredec[nTotPred][1]+aPredec[nTotPred][2]+aPredec[nTotPred][3]))
					If ASCAN(aPredec,{|x| ALLTRIM(x[3]) == AllTrim(AFD->AFD_TAREFA) }) == 0
						lAchouPred := .T.
						AADD(aPredec,{AFD->AFD_PROJET,AFD->AFD_REVISA,AFD->AFD_TAREFA})
						While AFD->(!EOF()) .And. AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_PREDEC == xFilial("AFD")+aPredec[nTotPred][1]+aPredec[nTotPred][2]+aPredec[nTotPred][3]
							AADD(aPredec,{AFD->AFD_PROJET,AFD->AFD_REVISA,AFD->AFD_TAREFA})
							AFD->(DbSkip())
						EndDo
					EndIf
				EndIf
			Next nTotPred
		EndDo
	EndIf
	
	DbSelectArea("AF9")
	AF9->(DbSetOrder(1))
	//REABRE PREDECESSORAS
	For nTotPred := 1 to Len(aPredec)
		lReabre := .T.
		_nPerc  := 0
		//Se tiver confirma็ใo no dia, altera
		If AFF->(dbSeek(xFilial("AFF")+aPredec[nTotPred][1]+aPredec[nTotPred][2]+aPredec[nTotPred][3]+DTOS(MSDATE()) ))
			ALTERA 	:= .T.
			INCLUI 	:= .F.
			nOpc := 4
			_nPerc := AFF->AFF_QUANT
		//Se nใo possui confirma็ใo no dia mas possui alguma confirma็ใo, inclui
		ElseIf AFF->(dbSeek(xFilial("AFF")+aPredec[nTotPred][1]+aPredec[nTotPred][2]+aPredec[nTotPred][3]))
			ALTERA 	:= .F.
			INCLUI 	:= .T.
			nOpc := 3
			
			//pega ultimo percentual executado
			cAliasAFF	:= GetNextAlias()		
			BeginSql Alias cAliasAFF
				SELECT AFF_QUANT, AFF_DATA
				FROM %table:AFF% AFF
				WHERE AFF_FILIAL= %xFilial:AFF% AND
					AFF_PROJET = %Exp:aPredec[nTotPred][1]%	 AND
					AFF_REVISA = %Exp:aPredec[nTotPred][2]%	 AND
					AFF_TAREFA = %Exp:aPredec[nTotPred][3]%	 AND
					AFF.%NotDel%
				ORDER BY AFF_DATA DESC
			EndSQL
			(cAliasAFF)->(DbGoTop())
			_nPerc := (cAliasAFF)->AFF_QUANT
			(cAliasAFF)->(DbCloseArea())
		//Se nใo possui nenhuma confirma็ใo significa que ainda nใo foi executada e por isso nใo ้ necessario reabrir
		Else
			lReabre := .F.
		EndIf
		If lReabre .And. AF9->(DbSeek(xFilial("AF9")+aPredec[nTotPred][1]+aPredec[nTotPred][2]+aPredec[nTotPred][3]))
			aGetCpos	:= {	{"AFF_PROJET" ,AF9->AF9_PROJET,.F.},;
								{"AFF_REVISA" ,AF9->AF9_REVISA,.F.},;
								{"AFF_DESCRI" ,AF9->AF9_DESCRI,.F.},;
								{"AFF_TAREFA" ,AF9->AF9_TAREFA,.F.},;
								{"AFF_DATA"   ,MSDate(),.F.} ,;
								{"AFF_QUANT"  ,If(_nPerc==1,0.90,_nPerc),.F.} ,;//Se o ultimo percentual for 100%, reabre com 90%. Caso contrario, reabre com o mesmo percentual anterior.
								{"AFF_USER"   ,__cUserID,.F.} }				
			lMsErroAuto = .F.
			MSExecAuto({|x,y|PMSA311Aut(x,y)},aGetCpos,nOpc)
			If lMsErroAuto
				MostraErro()
				lOk := .F.
			EndIf
		EndIf
	Next nTotPred 
	RestArea(aAreaAF9)
	RestArea(aAreaAFD)
	RestArea(aAreaAFF)
EndIf

Return

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta fun็ใo deve utilizada somente ap๓s 
    a inicializa็ใo das variaveis atravez da fun็ใo FATPDLoad.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, L๓gico, Retorna se o campo serแ ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa็๕es enviadas, 
    quando a regra de auditoria de rotinas com campos sensํveis ou pessoais estiver habilitada
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que serแ utilizada no log das tabelas
    @param nOpc, Numerico, Op็ใo atribuํda a fun็ใo em execu็ใo - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria nใo esteja aplicada, tamb้m retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet
//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun็ใo que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive