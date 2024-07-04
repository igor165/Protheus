#include "pmsicons.ch"
#include "pmsa203.ch"
#include "protheus.ch"
#include "ap5mail.ch"
#INCLUDE "FWADAPTEREAI.CH"

Static aHeaderTar
Static aSimDados  := {}
STATIC __lBlind	:= IsBlind()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA203  ³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de manutencao de Tarefas do Projeto                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Fabio Jadao   ³23/06/03³65006 ³Inclusao do ponto de entrada A203LINOK1   ³±±
±±³              ³        ³      ³para a validacao da linha no aCols - PRD  ³±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA203(nCallOpcx,aGetCpos,cNivTrf,xAutoCAB,xAutoAFA1,xAutoAFB,xAutoAFD,xAutoAFP,xAutoAFA2,xAutoAFZ,lRefresh,xAutoAEL,xAutoAEN)

Local aArea		:= GetArea()
Local aAreaAF8	:= AF8->( GetArea() )
Local nRecAF9	:= nil
Local lAutoExec	:= xAutoCab <> Nil

Private cConjPredec	:= ""
Private aAutoCab	:= {}
Private aAutoAFA1	:= {}
Private aAutoAFA2	:= {}
Private aAutoAFB	:= {}
Private aAutoAFD	:= {}
Private aAutoAFP	:= {}
Private aAutoAFZ	:= {}
Private aAutoAEL	:= {}
Private aAutoAEN	:= {}

SaveInter()

PRIVATE cCadastro	:= STR0001 //"Tarefas do Projeto"
PRIVATE aRotina := MenuDef()
PRIVATE aMemos := {{"AF9_CODMEM","AF9_OBS"}}

Default lRefresh := .F.

If PMSBLKINT(lAutoExec)
	Return Nil
EndIf

If AMIIn(44)

	If nCallOpcx == Nil

		mBrowse(6,1,22,75,"AF9")

	ElseIf lAutoExec

		PRIVATE lPMS203Auto := .T.

		aAutoCab := xAutoCab
		aAutoAFA1:= xAutoAFA1
		aAutoAFA2:= xAutoAFA2
		aAutoAFB := xAutoAFB
		aAutoAFD := xAutoAFD
		aAutoAFP := xAutoAFP
		aAutoAFZ := xAutoAFZ
		aAutoAEL := xAutoAEL
		aAutoAEN := xAutoAEN

		Default aAutoAFA1 := {}
		Default aAutoAFA2 := {}
		Default aAutoAFB := {}
		Default aAutoAFD := {}
		Default aAutoAFP := {}
		Default aAutoAFZ := {}
		Default aAutoAEL := {}
		Default aAutoAEN := {}

		If Ascan(aAutoCab,{|x|Alltrim(x[1]) == 'NEW_AF9_TAREFA'})>0 .and. nCallOpcx==10
			PMSALTTRF("AF9",aAutoCab)
		Else
			MBrowseAuto(nCallOpcx,Aclone(aAutoCab),"AF9")
		Endif
	Else

		// Forca posicionamento para que nas consultas os produtos/insumos
		// sejam carregados corretamente

		/// Parte comentada pois desposicionava a tabela AF8, causando não conformidade
		// por exemplo na aba Cronograma por periodo

		// Eh necessario o posicionamento pois na alteracao da tarefa campos da AF8 serao consultados
		DbSelectArea( "AF8" )
		AF8->( DbSetOrder( 1 ) )
		If (Type("Altera") == "L" .and. !Empty( Altera ) .And. nCallOpcx <> 3) .or. ( nCallOpcx == 4 )
			AF8->( DbSeek( xFilial( "AF8" ) + AF9->AF9_PROJET ) )
		Endif

		If AF8ComAJT( AF8->AF8_PROJET )

			Begin Transaction
			cNivTrf := StrZero(Val(cNivTrf) + 1, TamSX3("AF9_NIVEL")[1])
			nRecAF9 := PMS203Dlg ("AF9",AF9->(RecNo()),nCallOpcx,,,aGetCpos,cNivTrf,@lRefresh)
			End Transaction
		Else
			cNivTrf := StrZero(Val(cNivTrf) + 1, TamSX3("AF9_NIVEL")[1])
			nRecAF9 := PMS203Dlg ("AF9",AF9->(RecNo()),nCallOpcx,,,aGetCpos,cNivTrf,@lRefresh)
		EndIf
	EndIf
EndIf

RestInter()
RestArea( aAreaAF8 )
RestArea(aArea)
Return nRecAF9


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS203Dlg³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ³±±
±±³          ³ de Tarefas de Projetos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS203Dlg(cAlias,nReg,nOpcx,xreserv,yreserv,aGetCpos,cNivTrf,lRefresh)

Local l203Inclui	:= .F.
Local l203Visual	:= .F.
Local l203Altera	:= .F.
Local l203Exclui	:= .F.
Local lContinua	:= .T.
Local nOpc			:= 0
Local aSize		:= {}
Local aObjects	:= {}
Local aButtons	:= {}
Local aInfo		:= {}
Local aPosObj		:= {}

Local aArea		:= {}
Local aAJOArea	:= {}
Local aAreaAF8	:= {}

Local aCampos	// deve ser nulo para o objeto oEnch não bloquear os campos

Local aTitles	:= PmsDetCom(AF8->AF8_PROJET)
/*
	Padrão								CCT
	STR0039 "Produtos"					STR0129 "Insumos"
	STR0009 "Despesas"					STR0009 "Despesas"
	STR0062 "Relac.Tarefas"				STR0130 "Subcomposições"
	STR0038 "Eventos"					STR0062 "Relac.Tarefas"
	STR0040 "Aloc. Recursos"			STR0038 "Eventos"
	STR0051 "Cronograma por Periodo"	STR0051 "Cronograma por Periodo"
	STR0063 "Relac.EDT"					STR0063 "Relac.EDT"
	STR0183 "Tributos"					*** Nao se Aplica ***
*/

Local nPosCpo
Local cCpo
Local nRecAF9
Local cExcTrfPms 	:= SuperGetMv("MV_PMSTEXC",,"S")
Local nx			:= 0
Local ny			:= 0
Local ni			:= 0
Local oDlg
Local oFntVerdana
Local nPosRec		:=	0
Local aRecAval		:= {}
Local aParam			:= {}
Local aColsBkp 		:= {}
Local cMVPMSPRJEXC	:= SuperGetMv("MV_PMSPEXC",.T.,"1") //1-Visualiza,2-Pergunta,3-Não Visualiza
Local aTempSV			:= {}
Local aAllEDT  		:= {}
Local nPosAEFPerc 	:= 0
Local nOpcCron 		:= 0
Local nCntPerc 		:= 0
Local aColsAltera 	:= {NIL ,NIL ,NIL ,NIL ,NIL ,NIL}
Local nPos				:= 0
Local aPosCols 		:= {}
Local nPosDesp, nPosRTar, nPosEvnt, nPosCron, nPosREDT, nPosProd, nPosAloc, nPosSubC, nPosInsm, nPosTrib
Local lAF8ComAJT
Local lFWGetVersao	:= .T.
Local lAltUserOK		:= .F.
Local lPMS203Alt		:= ExistBlock("PMS203Tar")
Local lCalcTrib		:= IIf(Len(aTitles) == 8, .T., .F.)	//Verifica se havera calculo de impostos para as tarefas

PRIVATE oGD[8]
PRIVATE oEnch
PRIVATE oFolder
PRIVATE aHeaderSV		:= {{},{},{},{},{},{},{}}
PRIVATE aColsSV		:= {{},{},{},{},{},{},{}}
PRIVATE aSavN			:= {1,1,1,1,1,1,1}
PRIVATE aRecAFA		:= {}
PRIVATE aRecAFA2		:= {}
PRIVATE aRecAFB		:= {}
PRIVATE aRecAEL		:= {}
PRIVATE aRecAEN		:= {}
PRIVATE aRecAFD		:= {}
PRIVATE aRecAJ4		:= {}
PRIVATE aRecAFP		:= {}
PRIVATE aRecAFZ		:= {}
PRIVATE aRecAN9   	:= {}
PRIVATE oMsgBoard
PRIVATE oTimer
PRIVATE cMsgBoard		:= SPACE(200)
PRIVATE nGDAtu		:= 1
Private oProcess
Private aTarefs		:= {}
//Cronograma Previsto de Consumo
PRIVATE aHeadAEF1		:= {}
PRIVATE aColsAEF1		:= {}
PRIVATE aHeadAEF2		:= {}
PRIVATE aColsAEF2		:= {}
PRIVATE aRecAEF1		:= {}
PRIVATE aRecAEF2		:= {}

// Usa template?
lAF8ComAJT:=AF8ComAJT(AF8->AF8_PROJET)

// Definicao da posicao das abas
nPosProd := FolderOrd(STR0039)
nPosDesp := FolderOrd(STR0009)
nPosRTar := FolderOrd(STR0062)
nPosEvnt := FolderOrd(STR0038)
nPosAloc := FolderOrd(STR0040)
nPosCron := FolderOrd(STR0051)
nPosREDT := FolderOrd(STR0063)
nPosInsm := FolderOrd(STR0129)
nPosSubC := FolderOrd(STR0130)

//Prepara aHeaderSV e aColsSV para exibicao dos tributos da tarefa
If lCalcTrib
	AADD(aHeaderSV,{})
    AADD(aColsSV,{})
	AADD(aSavN,1)
	nPosTrib := FolderOrd(STR0183)//"Tributos"

EndIf

aSimDados := {}

If IsAuto()

	Private aHEADER := {}
	Private aCOLS   := {}
	Private aHEADER1:= {}
	Private aCOLS1  := {}
	Private aHEADER2:= {}
	Private aCOLS2  := {}
	Private aHEADER3:= {}
	Private aCOLS3  := {}
	Private aHEADER4:= {}
	Private aCOLS4  := {}
	Private aHEADER5:= {}
	Private aCOLS5  := {}
	Private aHEADER6:= {}
	Private aCOLS6  := {}
	Private aHEADER7:= {}
	Private aCOLS7  := {}

EndIf

RegToMemory("AFB", .T.) // Despesas
RegToMemory("AFD", .T.) // Relac Tarefas
RegToMemory("AFP", .T.) // Eventos
RegToMemory("AFZ", .T.) // Cronograma por periodo
RegToMemory("AJ4", .T.) // Relac EDT
RegToMemory("AE8", .T.) // Recursos

If !lAF8ComAJT
	// Variaveis de memoria do Padrao
	RegToMemory("AFA", .T.) // Produtos
Else
	// Variaveis de memoria do CCT
	RegToMemory("AEL", .T.) // Insumos
	RegToMemory("AEN", .T.) // Subcomposicoes
EndIf

DEFAULT cNivTrf := "001"

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case
	Case aRotina[nOpcx][4] == 2
		l203Visual := .T.
		Inclui := .F.
		Altera := .F.
		nOpcCron := 0
	Case aRotina[nOpcx][4] == 3
		l203Inclui	:= .T.
		Inclui := .T.
		Altera := .F.
		nOpcCron := GD_UPDATE
	Case aRotina[nOpcx][4] == 4
		l203Altera	:= .T.
		Inclui := .F.
		Altera := .T.
		nOpcCron := GD_UPDATE
	Case aRotina[nOpcx][4] == 5
		l203Exclui	:= .T.
		l203Visual	:= .T.
		nOpcCron := 0
EndCase


// carrega as variaveis de memoria AF9
RegToMemory("AF9",l203Inclui)
If l203Inclui
	M->AF9_NIVEL := cNivTrf
EndIf

// tratamento do array aGetCpos com os campos Inicializados do AF9
If aGetCpos <> Nil
	aCampos	:= {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AF9")
	While !Eof() .and. SX3->X3_ARQUIVO == "AF9"
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nPosCpo	:= aScan(aGetCpos,{|x| x[1]==Alltrim(X3_CAMPO)})
			If nPosCpo > 0
				If aGetCpos[nPosCpo][3]
					aAdd(aCampos,AllTrim(X3_CAMPO))
				EndIf
			Else
				aAdd(aCampos,AllTrim(X3_CAMPO))
			EndIf
		EndIf
		dbSkip()
	EndDo
	For nx := 1 to Len(aGetCpos)
		cCpo	:= "M->"+Trim(aGetCpos[nx][1])
		&cCpo	:= aGetCpos[nx][2]
	Next nx
EndIf


If !Empty(M->AF9_PROJET) .And. l203Inclui

	// verifica o evento de Inclusao na Fase atual
	If !PmsVldFase("AF8",AF8->AF8_PROJET,"15")
		lContinua := .F.
	EndIf

EndIf

If l203Altera

	// verifica o evento de Alteracao na Fase atual
	If ! PmsVldFase("AF8",AF8->AF8_PROJET,"18")
		lContinua := .F.
	EndIf

	If lPMS203Alt
		lAltUserOK := EXECBLOCK("PMS203Tar", .F. , .F. )
		If Valtype(lAltUserOK) == "L"
			lContinua := lAltUserOK
		Endif
	Endif

EndIf

If l203Exclui

	// verifica o evento de Exclusao no Fase atual
	If !PmsVldFase("AF8",AF8->AF8_PROJET,"14")
		lContinua := .F.
	EndIf
	If lContinua .And. ;
		(cExcTrfPms == "N" .And. GeralApp( AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA ) )
		Aviso(STR0014,STR0065,{STR0061},2) //"Atencao"###"Existem apontamentos para esta tarefa, portanto nao pode ser excluida!"###"Fechar"
		lContinua := .F.
	EndIf
	If lContinua
		dbSelectArea("AJO")
		aAJOArea := AJO->(GetArea())
		dbSetOrder(1)
		If MsSeek(xFilial("AJO")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA),.F.)
			If Aviso(STR0170,STR0171,{STR0086,STR0087},2)==2 //"Itens de check list encontrados"###"Essa tarefa possui itens de check list associados. Confirma a exclusão?"###"Sim"###"Nao"
				lContinua := .F.
			EndIf
		EndIf
		RestArea(aAJOArea)
	EndIf
	//
	//
	//
	If lContinua .AND. (IsAuto() .OR. cMVPMSPRJEXC!= "1")
		If ValType(aAutoCab) != "A"
			aAutoCab := {}
		EndIf
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AF9")
		While !Eof() .and. SX3->X3_ARQUIVO == "AF9"
			If x3_context != "V" .and. X3USO(x3_usado) .AND. cNivel >= x3_nivel

				cCpo := "M->"+Trim(X3_CAMPO)

				If (nPosCpo	:= aScan(aAutoCab ,{|x|x[1]==Alltrim(X3_CAMPO)})) > 0
					aAutoCab[nPosCPO,02] := &cCpo
				Else
					aAdd(aAutoCab,{Alltrim(X3_CAMPO),&cCpo,.F.})
				EndIf
			EndIf
			dbSkip()
		EndDo
	EndIf

	If ExistBlock("PMA203EX") // Valida exclusão da tarefa
		lContinua := ExecBlock("PMA203EX",.F.,.F.)
	EndIf

EndIf

If lContinua
	//CRONOGRAMA PREVISTO DE CONSUMO

	// montagem do aHeadAEF1 para o Cronograma Previsto do Produto - Parte 1/2
	SX3->(dbSelectArea("SX3"))
	SX3->(dbSetOrder(1))
	SX3->(dbSeek("AEF"))
	While !SX3->(EOF()) .And. (SX3->X3_ARQUIVO == "AEF")
		If X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !(AllTrim(SX3->X3_CAMPO)$"AEF_RECURS;AEF_DATREF;AEF_QUANT")

			aAdd(aHeadAEF1,{ TRIM(X3TITULO()) ,SX3->X3_CAMPO ,SX3->X3_PICTURE;
			               ,SX3->X3_TAMANHO ,SX3->X3_DECIMAL ,SX3->X3_VALID;
			               ,SX3->X3_USADO ,SX3->X3_TIPO ,SX3->X3_ARQUIVO ,SX3->X3_CONTEXT } )
		EndIf
		SX3->(dbSkip())
	EndDo

	// montagem do aHeadAEF1 para o Cronograma Previsto do Produto - Parte 2/2
	SX3->(dbSelectArea("SX3"))
	SX3->(dbSetOrder(2))
	SX3->(dbSeek("AEF_QUANT"))
	Do Case
		Case AF8->AF8_TPPERI == "2"
			dIni := AF8->AF8_INIPER
			If DOW(AF8->AF8_INIPER)<>1
				dIni -= DOW(AF8->AF8_INIPER)-1
			EndIf
		Case AF8->AF8_TPPERI == "3"
			dIni	:= CTOD("01/"+StrZero(MONTH(AF8->AF8_INIPER),2,0)+"/"+StrZero(YEAR(AF8->AF8_INIPER),4,0))
		Case AF8->AF8_TPPERI == "4"
			dIni	:= CTOD("01/"+StrZero(MONTH(AF8->AF8_INIPER),2,0)+"/"+StrZero(YEAR(AF8->AF8_INIPER),4,0))
		OtherWise
			dIni	:= AF8->AF8_INIPER
	EndCase
	dx := dIni
	nCntPerc := 1
	While dx < AF8->AF8_FIMPER
		AADD(aHeadAEF1 ,{ DTOC(dx), "AEF_QTD"+strZero(nCntPerc,3) , SX3->X3_PICTURE ;
		                 ,SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID;
		                 ,SX3->X3_USADO, SX3->X3_TIPO, "",SX3->X3_CONTEXT } )
		Do Case
			Case AF8->AF8_TPPERI == "2"
				dx += 7
			Case AF8->AF8_TPPERI == "3"
				If DAY(dx) == 01
					dx	:= CTOD("15/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
				Else
					dx += 35
					dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
				EndIf
			Case AF8->AF8_TPPERI == "4"
				dx += 35
				dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
			OtherWise
				dx += 1
		EndCase
		nCntPerc += 1
	EndDo

	// montagem do aHeadAEF2 para o Cronograma Previsto do Recurso - Parte 1/2
	SX3->(dbSelectArea("SX3"))
	SX3->(dbSetOrder(1))
	SX3->(dbSeek("AEF"))
	While !SX3->(EOF()) .And. (SX3->X3_ARQUIVO == "AEF")
		If X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !(AllTrim(SX3->X3_CAMPO)$"AEF_PRODUT;AEF_DATREF;AEF_QUANT")

			aAdd(aHeadAEF2,{ TRIM(X3TITULO()) ,SX3->X3_CAMPO ,SX3->X3_PICTURE ;
			                ,SX3->X3_TAMANHO ,SX3->X3_DECIMAL ,SX3->X3_VALID ;
			                ,SX3->X3_USADO ,SX3->X3_TIPO ,SX3->X3_ARQUIVO ,SX3->X3_CONTEXT } )
		EndIf
		SX3->(dbSkip())
	EndDo

	// montagem do aHeadAEF2 para o Cronograma Previsto do Recurso - Parte 2/2
	SX3->(dbSelectArea("SX3"))
	SX3->(dbSetOrder(2))
	SX3->(dbSeek("AEF_QUANT"))
	Do Case
		Case AF8->AF8_TPPERI == "2"
			dIni := AF8->AF8_INIPER
			If DOW(AF8->AF8_INIPER)<>1
				dIni -= DOW(AF8->AF8_INIPER)-1
			EndIf
		Case AF8->AF8_TPPERI == "3"
			dIni	:= CTOD("01/"+StrZero(MONTH(AF8->AF8_INIPER),2,0)+"/"+StrZero(YEAR(AF8->AF8_INIPER),4,0))
		Case AF8->AF8_TPPERI == "4"
			dIni	:= CTOD("01/"+StrZero(MONTH(AF8->AF8_INIPER),2,0)+"/"+StrZero(YEAR(AF8->AF8_INIPER),4,0))
		OtherWise
			dIni	:= AF8->AF8_INIPER
	EndCase
	nCntPerc := 1
	dx := dIni
	While dx < AF8->AF8_FIMPER
		AADD(aHeadAEF2 ,{ DTOC(dx), "AEF_QTD"+strZero(nCntPerc,3) , SX3->X3_PICTURE ;
		                 ,SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID  ;
		                 ,SX3->X3_USADO, SX3->X3_TIPO, "" ,SX3->X3_CONTEXT } )
		Do Case
			Case AF8->AF8_TPPERI == "2"
				dx += 7
			Case AF8->AF8_TPPERI == "3"
				If DAY(dx) == 01
					dx	:= CTOD("15/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
				Else
					dx += 35
					dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
				EndIf
			Case AF8->AF8_TPPERI == "4"
				dx += 35
				dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
			OtherWise
				dx += 1
		EndCase
		nCntPerc += 1
	EndDo

	//CRONOGRAMA PREVISTO DE CONSUMO

	If ! l203Inclui

		// trava o registro do AF9 - Alteracao,Visualizacao
		If l203Altera.Or.l203Exclui
			If !SoftLock("AF9")
				lContinua := .F.
			Else
				nRecAF9 := AF9->(RecNo())
			Endif
		EndIf

	EndIf


	// Montagem dos aHeader's & aCols's
	aHeaderTar:=nil
	lContinua:=PMS203Vis(aHeaderSV, aColsSV, !l203Inclui, .T., l203Altera .Or. l203Exclui)


	If ExistBlock("PMA203CL")
		ExecBlock("PMA203CL", .T., .T., {})
	EndIf


	If lContinua
		If IsAuto()
			Private aGets := {}
			Private aTela := {}

			/*
			For x := 1 To Len(aHeaderSV)
			For y := 1 To Len(aHeaderSV[x])
			If Empty(aHeaderSV[x][])
			aHeaderSV[x][y][10] :=
			Else
			AheaderSV[X][x][10] :=
			*/

			// Montagem dos ValidAuto comuns entre o Padrao e o CCT
			ValidAuto(aHeaderSV[nPosDesp], 6, "A203GD2FieldOk()")
			ValidAuto(aHeaderSV[nPosCron], 6, "A203GD6FieldOk()")
			ValidAuto(aHeaderSV[nPosRTar], 6, "A203GD3FieldOk()")
			ValidAuto(aHeaderSV[nPosREDT], 6, "A203GD7FieldOk()")

		    // Diferenciacao dos ValidAuto do padrao e do CCT
		   	If !lAF8ComAJT
				ValidAuto(aHeaderSV[nPosProd], 6, "A203GD1FieldOk()")
				ValidAuto(aHeaderSV[nPosAloc], 6, "A203GD5FieldOk()")
			EndIf

			For nx := 1 to Len(aAutoCab)
				cCpo	:= "M->"+Trim(aAutoCab[nx][1])
				&cCpo	:= aAutoCab[nx][2]
			Next nx
		   	If M->AF9_HDURAC==0
		   		M->AF9_HDURAC := PmsCalcHr( M->AF9_START ,M->AF9_HORAI ,M->AF9_FINISH ,M->AF9_HORAF ,M->AF9_CALEND)
		   	Endif
			dbSelectArea("AFC")
			dbSetOrder(1)
			If MsSeek(xFilial()+PadR(M->AF9_PROJET,TamSX3("AF9_PROJET")[1])+PadR(M->AF9_REVISA,TamSX3("AF9_REVISA")[1])+M->AF9_EDTPAI)
				If aScan(aAutoCab,{|x|x[1]=="AF9_NIVEL"})==0
					aAdd(aAutoCab ,{"AF9_NIVEL" ,Soma1(AFC->AFC_NIVEL),.F.})
				EndIf
				If aScan(aAutoCab,{|x|x[1]=="AF9_CALEND"})==0
					aAdd(aAutoCab ,{"AF9_CALEND" ,AFC->AFC_CALEND,.F.})
				EndIf
			EndIf

			lContinua := EnchAuto(cAlias,aAutoCab,{|| iIf( !PMS203DINI(!IsAuto()) ,PMS203DFIM(!IsAuto(),nOpc),),Obrigatorio(aGets,aTela)}) .And.;
				Eval({|| aHeader:=aClone(aHeaderSV[nPosDesp]), aCols := aClone(aColsSV[nPosDesp]), .T.}) .And. MsGetDAuto(aAutoAFB, "A203GD2LinOK",{|| A203GD2TudOk() },aAutoCab,aRotina[nOpcX][4]) .And. Eval({|| aColsSV[nPosDesp] := aClone(aCols), .T.}) .And. ;
				Eval({|| aHeader:=aClone(aHeaderSV[nPosRTar]), aCols := aClone(aColsSV[nPosRTar]), .T.}) .And. MsGetDAuto(aAutoAFD, "A203GD3LinOK",{|| A203GD3TudOk() },aAutoCab,aRotina[nOpcX][4]) .And. Eval({|| aColsSV[nPosRTar] := aClone(aCols), .T.})

			If lContinua
			   	If !lAF8ComAJT
			   		lContinua := lContinua .and. ;
					Eval({|| aHeader:=aClone(aHeaderSV[nPosProd]), aCols := aClone(aColsSV[nPosProd]), .T.}) .And. MsGetDAuto(aAutoAFA1,"A203GD1LinOK",{|| A203GD1TudOk() },aAutoCab,aRotina[nOpcX][4]) .And. Eval({|| aColsSV[nPosProd] := aClone(aCols), .T.}) .And. ;
					Eval({|| aHeader:=aClone(aHeaderSV[nPosAloc]), aCols := aClone(aColsSV[nPosAloc]), .T.}) .And. MsGetDAuto(aAutoAFA2,"A203GD5LinOK",{|| A203GD5TudOk() },aAutoCab,aRotina[nOpcX][4]) .And. Eval({|| aColsSV[nPosAloc] := aClone(aCols), .T.})
			   	EndIf

			   	If lContinua .and. PMSA203Chk( l203Inclui ,l203Altera ,l203Exclui )
			   		nOpc := 1
			   	EndIf

			EndIf

			//
			// exclusão rapida
			//
		ElseIf l203Exclui .AND. cMVPMSPRJEXC$ "2µ3"

			If EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela)},nOpcX)
				If PMSA203Chk( l203Inclui ,l203Altera ,l203Exclui )
					nOpc := 1
					If cMVPMSPRJEXC=="2" .AND. Aviso(STR0168,STR0168+" ?",{STR0169,STR0016},1) == 2 // "Excluir a Tarefa" # "Excluir a Tarefa ?" // confirma // Cancelar
						nOpc := 2
					EndIf
				EndIf
			EndIf
		Else
			//
			// Cronograma Previsto de consumo de produtos
			//
			If !l203Inclui
				nPosAFAProd := aScan(aHeaderSV[1],{|x| AllTrim(x[2])=="AFA_PRODUT"})
				nPosAFAIt   := aScan(aHeaderSV[1],{|x| AllTrim(x[2])=="AFA_ITEM"})
				nPosAFAQt   := aScan(aHeaderSV[1],{|x| AllTrim(x[2])=="AFA_QUANT"})

				nPosAEFIt   := aScan(aHeadAEF1 ,{|x| AllTrim(x[2])=="AEF_ITEM"})
				nPosAEFProd := aScan(aHeadAEF1 ,{|x| AllTrim(x[2])=="AEF_PRODUT"})
				nPosAEFPerc := aScan(aHeadAEF1 ,{|x| AllTrim(x[2])=="AEF_QTD001"})

				If nPosAEFPerc > 0
					dbSelectArea("AEF")
					dbSetOrder(1)
					For nI := 1 to Len(aColsSV[1])
						aadd(aColsAEF1 ,Array(Len(aHeadAEF1)+1))

						aColsAEF1[Len(aColsAEF1) ,nPosAEFIt]  := aColsSV[1][nI ,nPosAFAIt]
						aColsAEF1[Len(aColsAEF1) ,nPosAEFProd]:= aColsSV[1][nI ,nPosAFAProd]

						For nY := nPosAEFPerc to Len(aHeadAEF1)
							If dbSeek(xFilial("AEF")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)+aColsSV[1][nI ,nPosAFAIt]+aColsSV[1][nI ,nPosAFAProd]+space(TamSX3("AEF_RECURS")[1])+dTos(ctod(aHeadAEF1[nY ,1])))
								aColsAEF1[Len(aColsAEF1) ,nY] := AEF->AEF_QUANT
								nTotPerc := AEF->AEF_QUANT
							Else
								aColsAEF1[Len(aColsAEF1) ,nY] := 0
							EndIf
						Next nY
			  			aColsAEF1[Len(aColsAEF1) ,Len(aHeadAEF1)+1] := .F.
					Next nI
				EndIf

				lContinua := .T.
				// carrega array com os registros do AEF da tarefa
				dbSelectArea("AEF")
				dbSetOrder(1)
				dbSeek(xFilial("AEF")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA))
				While !Eof() .And. AEF->(AEF_FILIAL+AEF_PROJET+AEF_REVISA+AEF_TAREFA)==xFilial("AEF")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA).And.lContinua

					If Empty(AEF->AEF_RECURS) .AND. !Empty(AEF->AEF_PRODUT)
						// trava o registro do AFZ - Alteracao, Exclusao
						If l203Altera.Or.l203Exclui
							If !SoftLock("AEF")
								lContinua := .F.
							Else
								aAdd(aRecAEF1,RecNo())
							Endif
						EndIf
					EndIf
					dbSelectArea("AEF")
					dbSkip()
				EndDo

			Else
				Aadd(aColsAEF1 ,Array(Len(aHeadAEF1)+1))
				For ny := 1 to Len(aHeadAEF1)
					If "AEF_QTD" $ aHeadAEF1[ny ,2]
						aColsAEF1[1 ,ny] := CriaVar("AEF_QUANT")
					Else
						aColsAEF1[1 ,ny] := CriaVar(aHeadAEF1[ny ,2])
					EndIf
				Next ny
				aColsAEF1[1 ,Len(aHeadAEF1)+1] := .F.
			EndIf

			//
			// Cronograma Previsto de consumo de produtos
			//
			If !l203Inclui
				nPosAFARec := aScan(aHeaderSV[5],{|x| AllTrim(x[2])=="AFA_RECURS"})
				nPosAFAIt   := aScan(aHeaderSV[5],{|x| AllTrim(x[2])=="AFA_ITEM"})

				nPosAEFIt   := aScan(aHeadAEF2 ,{|x| AllTrim(x[2])=="AEF_ITEM"})
				nPosAEFRec  := aScan(aHeadAEF2 ,{|x| AllTrim(x[2])=="AEF_RECURS"})
				nPosAEFPerc := aScan(aHeadAEF2 ,{|x| AllTrim(x[2])=="AEF_QTD001"})

				If nPosAEFPerc > 0
					dbSelectArea("AEF")
					dbSetOrder(2)
					For nI := 1 to Len(aColsSV[5])
						aadd(aColsAEF2 ,Array(Len(aHeadAEF2)+1))

						aColsAEF2[Len(aColsAEF2) ,nPosAEFIt]  := aColsSV[5][nI ,nPosAFAIt]
						aColsAEF2[Len(aColsAEF2) ,nPosAEFRec]	:= aColsSV[5][nI ,nPosAFARec]

						For nY := nPosAEFPerc to Len(aHeadAEF2)
							If dbSeek(xFilial("AEF")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)+aColsSV[5][nI ,nPosAEFIt]+aColsSV[5][nI ,nPosAEFRec]+space(TamSX3("AEF_PRODUT")[1])+dTos(ctod(aHeadAEF2[nY ,1])))
								aColsAEF2[Len(aColsAEF2) ,nY] := AEF->AEF_QUANT
							Else
								aColsAEF2[Len(aColsAEF2) ,nY] := 0
							EndIf
						Next nY
						aColsAEF2[Len(aColsAEF2) ,Len(aHeadAEF2)+1] := .F.
					Next nI
				EndIf

				lContinua := .T.
				// carrega array com os registros do AEF da tarefa
				dbSelectArea("AEF")
				dbSetOrder(1)
				dbSeek(xFilial("AEF")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA))
				While !Eof() .And. AEF->(AEF_FILIAL+AEF_PROJET+AEF_REVISA+AEF_TAREFA)==xFilial("AEF")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA).And.lContinua

					If !Empty(AEF->AEF_RECURS) .AND. Empty(AEF->AEF_PRODUT)
						// trava o registro do AFZ - Alteracao, Exclusao
						If l203Altera.Or.l203Exclui
							If !SoftLock("AEF")
								lContinua := .F.
							Else
								aAdd(aRecAEF2 ,RecNo())
							Endif
						EndIf
					EndIf
					dbSelectArea("AEF")
					dbSkip()
				End

			Else
				aadd(aColsAEF2 ,Array(Len(aHeadAEF2)+1))
				For ny := 1 to Len(aHeadAEF2)
					If "AEF_QTD" $ aHeadAEF2[ny ,2]
						aColsAEF2[1 ,ny] := CriaVar("AEF_QUANT")
					Else
						aColsAEF2[1 ,ny] := CriaVar(aHeadAEF2[ny ,2])
					EndIf

				Next ny
				aColsAEF2[1 ,Len(aHeadAEF2)+1] := .F.
			EndIf


			// faz o calculo automatico de dimensoes de objetos
			aSize := MsAdvSize(,.F.,400)
			aObjects := {}

			AAdd( aObjects, { 100, 100 , .T., .T. } )
			AAdd( aObjects, { 100, 100 , .T., .T. } )
			AAdd( aObjects, { 100, 10  , .T., .F.,.T. } )

			aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
			aPosObj := MsObjSize( aInfo, aObjects, .T. )

			DEFINE FONT oFntVerdana NAME "Verdana" SIZE 0, -10 BOLD
			DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+aRotina[nOpcx,01] From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

			oEnch := MsMGet():New("AF9",AF9->(RecNo()),nOpcx,,,,,aPosObj[1],aCampos,3,,,,oDlg,,,,,,.T.)

			oPanel := TPanel():New(aPosObj[3,1],aPosObj[3,2],'',oDlg,oDlg:oFont, .T., .T.,, ,aPosObj[3,3],aPosObj[3,4],.T.,.T. )
			@ 2,4 SAY oMsgBoard VAR cMsgBoard of oPanel PIXEL
			DEFINE TIMER oTimer INTERVAL 2000 ACTION (Pms203Msg(SPACE(200))) OF oDlg

			oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,{},oDlg,,,, .T., .T.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
			oFolder:bSetOption:={|nFolder| A203SetOption(nFolder,oFolder:nOption,@aCols,@aHeader,@aColsSV,@aHeaderSV,@aSavN,@oGD) }
			For ni := 1 to Len(oFolder:aDialogs)
				DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[ni]
			Next

			dbSelectArea("AF2")

			// Construcao dos GetDados comuns entre o Padrao e o CCT

			// Tributos
			If lCalcTrib
				oFolder:aDialogs[nPosTrib]:oFont := oDlg:oFont
				aHeader		 := aClone(aHeaderSV[nPosTrib])
				aCols		 := aClone(aColsSV[nPosTrib])
				oGD[nPosTrib]:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,/*nOpcx*/ 1,/*"A203GD8LinOk"*/,/*"A203GD8TudOK"*/,/*"+AFB_ITEM"*/, /*PmsVldFase("AF8",AF9->AF9_PROJET,"32",.F.).And.!l203Visual*/,,1,,990,/*"A203GD2FieldOk()"*/,,,/*"A203GDDel("+alltrim(str(nPosTrib))+")"*/,oFolder:aDialogs[nPosTrib])
				oGD[nPosTrib]:oBrowse:bDrawSelect	:= {|| A203SVCols(@aHeaderSV,@aColsSV,@aSavN,nPosTrib)}
				oGD[nPosTrib]:oBrowse:lDisablePaint := .T.
			EndIf

			// Despesas
			oFolder:aDialogs[nPosDesp]:oFont := oDlg:oFont
			aHeader		 := aClone(aHeaderSV[nPosDesp])
			aCols		 := aClone(aColsSV[nPosDesp])
			oGD[nPosDesp]:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A203GD2LinOk","A203GD2TudOK","+AFB_ITEM", PmsVldFase("AF8",AF9->AF9_PROJET,"32",.F.).And.!l203Visual,,1,,990,"A203GD2FieldOk()",,,"A203GDDel("+alltrim(str(nPosDesp))+")",oFolder:aDialogs[nPosDesp])
			oGD[nPosDesp]:oBrowse:bDrawSelect	:= {|| A203SVCols(@aHeaderSV,@aColsSV,@aSavN,nPosDesp)}
			oGD[nPosDesp]:oBrowse:lDisablePaint := .T.

			// Relacionamento de Tarefas
			oFolder:aDialogs[nPosRTar]:oFont := oDlg:oFont
			aHeader		 := aClone(aHeaderSV[nPosRTar])
			aCols		 := aClone(aColsSV[nPosRTar])
			oGD[nPosRTar]:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A203GD3LinOk","A203GD3TudOK","+AFD_ITEM", PmsVldFase("AF8",AF9->AF9_PROJET,"35",.F.),,1,,990,"A203GD3FieldOk()",,,"A203GD3DelOk",oFolder:aDialogs[nPosRTar])
			oGD[nPosRTar]:oBrowse:bDrawSelect	:= {|| A203SVCols(@aHeaderSV,@aColsSV,@aSavN,nPosRTar)}
			oGD[nPosRTar]:oBrowse:lDisablePaint := .T.

			// Eventos
			oFolder:aDialogs[nPosEvnt]:oFont := oDlg:oFont
			aHeader		 := aClone(aHeaderSV[nPosEvnt])
			aCols		 := aClone(aColsSV[nPosEvnt])
			oGD[nPosEvnt]:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A203GD4LinOk","A203GD4TudOK","+AFP_ITEM", .T.,,1,,990,,,,,oFolder:aDialogs[nPosEvnt])
			oGD[nPosEvnt]:oBrowse:bDrawSelect	:= {|| A203SVCols(@aHeaderSV,@aColsSV,@aSavN,nPosEvnt)}
			oGD[nPosEvnt]:oBrowse:lDisablePaint := .T.

			// Cronograma
			oFolder:aDialogs[nPosCron]:oFont := oDlg:oFont
			aHeader		 := aClone(aHeaderSV[nPosCron])
			aCols		 := aClone(aColsSV[nPosCron])
			oGD[nPosCron]:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A203GD6LinOk","A203GD6LinOk","", .T.,,1,,990,"A203GD6FieldOk",,,,oFolder:aDialogs[nPosCron])
			oGD[nPosCron]:oBrowse:bDrawSelect	:= {|| A203SVCols(@aHeaderSV,@aColsSV,@aSavN,nPosCron)}
			oGD[nPosCron]:oBrowse:lDisablePaint := .T.

			// Relacionamento de EDT
			oFolder:aDialogs[nPosREDT]:oFont := oDlg:oFont
			aHeader		 := aClone(aHeaderSV[nPosREDT])
			aCols		 := aClone(aColsSV[nPosREDT])
			oGD[nPosREDT]:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A203GD7LinOk","A203GD7LinOk","+AJ4_ITEM", .T.,,1,,990,"A203GD7FieldOk()",,,,oFolder:aDialogs[nPosREDT])
			oGD[nPosREDT]:oBrowse:bDrawSelect	:= {|| A203SVCols(@aHeaderSV,@aColsSV,@aSavN,nPosREDT)}
			oGD[nPosREDT]:oBrowse:lDisablePaint := .T.


		    // Diferenciacao dos GetDados do padrao e do CCT

			If !lAF8ComAJT

				// Criacao dos GetDados do Padrao

				// Produtos
				nPos := 12
				oFolder:aDialogs[nPosProd]:oFont := oDlg:oFont
				aHeader		 := aClone(aHeaderSV[nPosProd])
				aCols		 := aClone(aColsSV[nPosProd])
				oGD[nPosProd]:= MsGetDados():New(nPos,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A203GD1LinOk","A203GD1TudOk","+AFA_ITEM",PmsVldFase("AF8",AF9->AF9_PROJET,"29",.F.).And.!l203Visual,,1,,990,"A203GD1FieldOk()",,,"A203GDDel(1)",oFolder:aDialogs[nPosProd])
				oGd[nPosProd]:oBrowse:bDelOk := {|| .T.}
				oGD[nPosProd]:oBrowse:bDrawSelect	:= {|| A203SVCols(@aHeaderSV,@aColsSV,@aSavN,nPosProd)}
				//So para custo total
				@ 3,3 BUTTON oButton PROMPT "!" SIZE 10 ,7   ACTION {|| A203PrdCron(nOpcCron ,aHeader ,aCols ,aHeadAEF1 ,aColsAEF1,'P')} OF oFolder:aDialogs[nPosProd] PIXEL
				@ 3,14 SAY STR0148 SIZE 150,7 Of oFolder:aDialogs[nPosProd] FONT oFntVerdana COLOR RGB(80,80,80) PIXEL //"Cronograma Previsto de Consumo"

				// Alocacao de recursos
				oFolder:aDialogs[nPosAloc]:oFont := oDlg:oFont

				@ 3,3 BUTTON oButton PROMPT "!" SIZE 10 ,7   ACTION {|| A203ChkAloc(l203Altera) } OF oFolder:aDialogs[nPosAloc] PIXEL
				@ 3,14 SAY STR0106 SIZE 150,7 Of oFolder:aDialogs[nPosAloc] FONT oFntVerdana COLOR RGB(80,80,80) PIXEL  //"Disponibilidade da Equipe /Recursos"

				aRecursos := {}
				@ 3,123 BUTTON oButton PROMPT "!" SIZE 10 ,7   ACTION {|| A203Recursos(aRecursos,2)  } OF oFolder:aDialogs[nPosAloc] PIXEL
				@ 3,134 SAY STR0107 SIZE 150,7 Of oFolder:aDialogs[nPosAloc] FONT oFntVerdana COLOR RGB(80,80,80) PIXEL  //"Consultar Alocação dos Recursos"

				aRecursos := {}
				@ 3,234 BUTTON oButton PROMPT "!" SIZE 10 ,7   ACTION {|| A203Recursos(aRecursos,1)  } OF oFolder:aDialogs[nPosAloc] PIXEL
				@ 3,245 SAY STR0108 SIZE 150,7 Of oFolder:aDialogs[nPosAloc] FONT oFntVerdana COLOR RGB(80,80,80) PIXEL  //"Consultar Alocação da Minha Equipe"

				aHeader		 := aClone(aHeaderSV[nPosAloc])
				aCols		 := aClone(aColsSV[nPosAloc])
				oGD[nPosAloc]:= MsGetDados():New(12,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A203GD5LinOk","A203GD5TudOK","+AFA_ITEM", .T.,,1,,990,"A203GD5FieldOk",,,"A203GDDel(5)",oFolder:aDialogs[nPosAloc])
				oGD[nPosAloc]:oBrowse:bDrawSelect	:= {|| A203SVCols(@aHeaderSV,@aColsSV,@aSavN,nPosAloc)}
				oGD[nPosAloc]:oBrowse:lDisablePaint := .T.

				//So para custo total - CRONOGRAMA PREVISTO DE CONSUMO
				@ 3,364 BUTTON oButton PROMPT "!" SIZE 10 ,7   ACTION {|| A203PrdCron(nOpcCron ,aHeader ,aCols ,aHeadAEF2 ,aColsAEF2,'R')} OF oFolder:aDialogs[nPosAloc] PIXEL
				@ 3,375 SAY STR0148 SIZE 150,7 Of oFolder:aDialogs[nPosAloc] FONT oFntVerdana COLOR RGB(80,80,80) PIXEL //"Cronograma Previsto de Consumo"
				aAdd(aPosCols ,120)
				aAdd(aPosCols ,130)
				aAdd(aPosCols ,267)
				aAdd(aPosCols ,277)
				aAdd(aPosCols ,414)
				aAdd(aPosCols ,424)

				// Fim da criacao dos GetDados do Padrao

			Else

				// Criacao dos GetDados do CCT

				// Insumos
				oFolder:aDialogs[nPosInsm]:oFont := oDlg:oFont
				aHeader		 := aClone(aHeaderSV[nPosInsm])
				aCols		 := aClone(aColsSV[nPosInsm])
				oGD[nPosInsm]:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A203InsLinOk","A203InsTudOk","+AEL_ITEM",PmsVldFase("AF8",AF9->AF9_PROJET,"29",.F.).And.!l203Visual,,1,,990,"AlwaysTrue",,,"A203GDDel("+alltrim(str(nPosInsm))+")",oFolder:aDialogs[nPosInsm])
				oGD[nPosInsm]:oBrowse:bDrawSelect	:= {|| A203SVCols(@aHeaderSV,@aColsSV,@aSavN,nPosInsm)}

				// Subcomposicoes
				oFolder:aDialogs[nPosSubC]:oFont := oDlg:oFont
				aHeader		 := aClone(aHeaderSV[nPosSubC])
				aCols		 := aClone(aColsSV[nPosSubC])
				oGD[nPosSubC]:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A203SubLinOk","A203SubTudOk","+AEN_ITEM",PmsVldFase("AF8",AF9->AF9_PROJET,"29",.F.).And.!l203Visual,,1,,990,/*"A203GD9FieldOk()"*/,,,"A203GDDel("+alltrim(str(nPosSubC))+")",oFolder:aDialogs[nPosSubC])
				oGD[nPosSubC]:oBrowse:bDrawSelect := {|| A203SVCols(@aHeaderSV,@aColsSV,@aSavN,nPosSubC)}

				// Fim da criacao dos GetDados do CCT

			EndIf

			aHeader		:= aClone(aHeaderSV[1])
			aCols		:= aClone(aColsSV[1])

			// verifica os botoes de usuarios
			If ExistBlock("PMA203BTN")
				aButtons:= ExecBlock("PMA203BTN",.F.,.F.,{aButtons})
			EndIf

			// adiciona os botoes padroes do sistema

			// simulacao de realocacao (nao inclui no CCT)
			If !lAF8ComAJT .and. (l203Altera .Or. l203Inclui)
				If !lFWGetVersao .or. GetVersao(.F.) == "P10"
					aAdd(aButtons,{BMP_SIMULACAO_ALOCACAO_RECURSOS,{|| A203Simulacao() },STR0109,STR0083}) //###"Simulacao" //"Simulacao de Redistribuição de Recursos"
        		Else
					aAdd(aButtons,{BMP_SIMULACAO_ALOCACAO_RECURSOS,{|| A203Simulacao() },STR0109,STR0109}) //###"Simulacao" //"Simulacao de Redistribuição de Recursos"
				Endif
			Endif

			// Check List
			aAdd(aButtons,{"SELECTALL",{|| M->AF9_CHKLST:=A203GtCkLs() },"Check List","Check List"}) //"Check List"###"Check List"


			// integracao com OUTLOOK
			If !lFWGetVersao .or. GetVersao(.F.) == "P10"
				aAdd(aButtons,{BMP_OUTLOOK,{|| PmsOpenICS() },STR0066,STR0067}) //"Adicionar a agenda do Outlook"###"Outlook"
			Else
				aAdd(aButtons,{BMP_OUTLOOK,{|| PmsOpenICS() },STR0066,STR0066}) //"Adicionar a agenda do Outlook"###"Outlook"
			Endif

			aButtons := AddToExcel(aButtons,{	{"ENCHOICE",cCadastro,oEnch:aGets,oEnch:aTela},;
			{"GETDADOS",aTitles[1],aHeaderSV[1],aColsSV[1]},;
			{"GETDADOS",aTitles[2],aHeaderSV[2],aColsSV[2]},;
			{"GETDADOS",aTitles[3],aHeaderSV[3],aColsSV[3]},;
			{"GETDADOS",aTitles[4],aHeaderSV[4],aColsSV[4]},;
			{"GETDADOS",aTitles[5],aHeaderSV[5],aColsSV[5]},;
			{"GETDADOS",aTitles[6],aHeaderSV[6],aColsSV[6]},;
			{"GETDADOS",aTitles[7],aHeaderSV[7],aColsSV[7]} } )

			// verifica os botoes de usuarios no Template

			If ExistTemplate("PMA203BTN")
				aButtons:= ExecTemplate("PMA203BTN",.F.,.F.,{aButtons})
			EndIf

			aHeader		:= aClone(aHeaderSV[1])
			aCols		:= aClone(aColsSV[1])

			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||EncChgFoco(oEnch) ,If( PMSA203VLD(oEnch,@aHeaderSV,@aColsSV,@aSavN,oGD,@aAllEDT,lCalcTrib) .AND. PMSA203Chk( l203Inclui ,l203Altera ,l203Exclui ) ;
			,(nOpc:=1,oDlg:End()),Nil)},{||oDlg:End()},,aButtons)

		EndIf
	EndIf

	// Nao aplicar refresh na visualizacao do projeto (arvore/planilha)
	lRefresh := .F.

	dbSelectArea("AF9")
	If (nOpc == 1) .And. (l203Inclui .Or. l203Altera .Or. l203Exclui)
		// Aplicar refresh na visualizacao do projeto (arvore/planilha)
		lRefresh := .T.

		// ponto de entrada para permitir alteracao do aCols, ao fazer uma alteração de tarefa
		aColsBkp := AClone( aColsSV )
		If ExistBlock("PMS203Alt")
			aColsSV :=  ExecBlock("PMS203Alt",.F.,.F.,{ aColsSV } )
		EndIf

		if Valtype( aColsSV ) <> "A"
			aColsSV := AClone( aColsBkp )
		endif

		// verifica se existe o ponto de entrada para a permissao ou bloqueio
		// da inclusao,alteracao,exclusao da Tarefa
		Do Case
			Case l203Inclui
				If ExistBlock("PMA203INC")
					If !ExecBlock("PMA203INC",.F.,.F.)
						Return(nRecAF9)
					EndIf
				EndIf

			Case l203Altera
				If ExistBlock("PMA203ALT")
					If !ExecBlock("PMA203ALT",.F.,.F.)
						Return(nRecAF9)
					EndIf
				EndIf

			Case l203Exclui
				If ExistBlock("PMA203DEL")
					If !ExecBlock("PMA203DEL",.F.,.F.)
						Return(nRecAF9)
					EndIf
				EndIf
		EndCase

		If AF8ComAJT( AF8->AF8_PROJET )
			PMS203Grava(l203Exclui,aHeaderSV,aColsSV,1,@nRecAF9,aRecAFA,aRecAFB,aRecAFD,aRecAFP,aRecAFA2,aRecAFZ,aRecAJ4,aRecAEL,aRecAEN, IIf(lAF8ComAJT,M->AF9_COMPUN,) )
			PcoDetlan("000350","01") // Integração com o SIGAPCO
		Else
			Begin Transaction
			PMS203Grava(l203Exclui,aHeaderSV,aColsSV,1,@nRecAF9,aRecAFA,aRecAFB,aRecAFD,aRecAFP,aRecAFA2,aRecAFZ,aRecAJ4,aRecAEL,aRecAEN, IIf(lAF8ComAJT,M->AF9_COMPUN,) )
			PcoDetlan("000350","01") // Integração com o SIGAPCO
			End Transaction
		EndIf

		If ExistBlock("PMA203FI")
			ExecBlock("PMA203FI",.F.,.F.,{l203Inclui,l203Altera,l203Exclui})
		EndIf

		If !lAF8ComAJT // Nao verifica superalocacao de recursos no CCT
			AF8->(dbSetOrder(1))
			AF8->(MsSeek(xFilial()+AF9->AF9_PROJET))
			If !IsAuto() .And.!l203Exclui .And. ;
				(AF8->AF8_REALOC == "1" .Or.;
				(AF8->AF8_REALOC == "3" .And. ;
				Aviso(STR0084,STR0085,{STR0086,STR0087},2) ==1)) //'Assistente de superalocacao'###'Deseja verificar se ha superalocacao nos recursos desta tarefa?'###"Sim"###"Nao"

				nPosRec  := aScan(aHeaderSV[nPosAloc],{|x| AllTrim(x[2])=="AFA_RECURS"})
				For nX:=1	To Len(aColsSV[nPosAloc])
					If !aColsSV[nPosAloc][nx][Len(aColsSV[nPosAloc][nx])]
						AAdd(aRecAval,	aColsSV[nPosAloc][nX][nPosRec ])
					EndIf
				Next nX
				aArea		:= GetArea()
				aAreaAF8	:= AF8->(GetArea())
				// parametros para a redistribuicao
				aParam	:=	{AF8->AF8_START,AF8->AF8_FINISH,AF8->AF8_PRIREA ,IIf((AF8->AF8_REAFIX=="1"),.T.,.F.)}
				If AF8->AF8_REALOC == "1" .Or. ParamBox( { { 1 ,STR0090,AF8->AF8_START		,"@!" 	 ,""  ,""    ,"" ,50 ,.F. } ; //"Data de"
					,{ 1 ,STR0091,AF8->AF8_FINISH	    ,"@!" 	 ,""  ,""    ,"" ,50 ,.F. };  //"Data ate"
					,{ 2 ,STR0092,AF8->AF8_PRIREA		,{STR0104,STR0105} ,120 ,""  ,.F. };  //"Ordem Por"##"1=Data de Inicio, Prioridade"##"2=Prioridade, Data de Inicio"
					,{5, STR0119, IIf((AF8->AF8_REAFIX=="1"),.T.,.F.), 160,,.F.}; //"Fixar datas previstas das tarefas em execução"
					} ;
					,STR0103 ; //"Parametros da Redistribuição"
					,@aParam )
					aParam   := {aParam[1],aParam[2],'','',Val(aParam[3]),,,aParam[4]}
					oProcess := MsNewProcess():New({|| AuxRedistRec( aParam ,M->AF9_PROJET ,M->AF9_REVISA,.F. ,aRecAval)})
					oProcess:Activate()
				EndIf
				RestArea(aAreaAF8)
				RestArea(aArea)
			Endif
		EndIf
	Else
		If AF8ComAJT( AF8->AF8_PROJET )
			DisarmTrans()
		EndIf
	EndIf

	If ExistBlock("PMA203FM")
		ExecBlock("PMA203FM",.F.,.F.,{l203Inclui,l203Altera,l203Exclui,(nOpc == 1)})
	EndIf

EndIf

FreeUsedCode(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destrava Todos os Registros                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnLockAll()

PMS200Rev()

// liberacao de memoria utilizado pelos arrays
aSize(aSize, 0)
aSize := NIL
aSize(aObjects, 0)
aObjects := NIL
aSize(aButtons, 0)
aButtons := NIL
aSize(aInfo, 0)
aInfo := NIL
aSize(aPosObj, 0)
aPosObj := NIL
aSize(aArea, 0)
aArea := NIL
aSize(aAJOArea, 0)
aAJOArea := NIL
aSize(aAreaAF8, 0)
aAreaAF8 := NIL
aSize(aTitles, 0)
aTitles := NIL
aSize(aRecAval, 0)
aRecAval := NIL
aSize(aParam, 0)
aParam := NIL
aSize(aColsBkp, 0)
aColsBkp := NIL
aSize(aTempSV, 0)
aTempSV := NIL
aSize(aAllEDT, 0)
aAllEDT := NIL
aSize(aColsAltera, 0)
aColsAltera := NIL
aSize(aPosCols, 0)
aPosCols := NIL
aSize(oGD, 0)
oGD := NIL
aSize(aHeaderSV, 0)
aHeaderSV := NIL
aSize(aColsSV, 0)
aColsSV := NIL
aSize(aSavN, 0)
aSavN := NIL
aSize(aRecAFA, 0)
aRecAFA := NIL
aSize(aRecAFA2, 0)
aRecAFA2 := NIL
aSize(aRecAFB, 0)
aRecAFB := NIL
aSize(aRecAEL, 0)
aRecAEL := NIL
aSize(aRecAEN, 0)
aRecAEN := NIL
aSize(aRecAFD, 0)
aRecAFD := NIL
aSize(aRecAJ4, 0)
aRecAJ4 := NIL
aSize(aRecAFP, 0)
aRecAFP := NIL
aSize(aRecAFZ, 0)
aRecAFZ := NIL
aSize(aRecAN9, 0)
aRecAN9 := NIL
aSize(aHeadAEF1, 0)
aHeadAEF1 := NIL
aSize(aColsAEF1, 0)
aColsAEF1 := NIL
aSize(aHeadAEF2, 0)
aHeadAEF2 := NIL
aSize(aColsAEF2, 0)
aColsAEF2 := NIL
aSize(aRecAEF1, 0)
aRecAEF1 := NIL
aSize(aRecAEF2, 0)
aRecAEF2 := NIL
If IsAuto()
	aSize(aHEADER, 0)
	aHeader := NIL
	aSize(aCOLS, 0)
	aCols := NIL
	aSize(aHEADER1, 0)
	aHeader := NIL
	aSize(aCOLS1, 0)
	aCols1 := NIL
	aSize(aHEADER2, 0)
	aHeader2 := NIL
	aSize(aCOLS2, 0)
	aCols2 := NIL
	aSize(aHEADER3, 0)
	aHeader3 := NIL
	aSize(aCOLS3, 0)
	aCols3 := NIL
	aSize(aHEADER4, 0)
	aHeader4 := NIL
	aSize(aCOLS4, 0)
	aCols4 := NIL
	aSize(aHEADER5, 0)
	aHeader5 := NIL
	aSize(aCOLS5, 0)
	aCols5 := NIL
	aSize(aHEADER6, 0)
	aHeader5 := NIL
	aSize(aCOLS6, 0)
	aCols6 := NIL
	aSize(aHEADER7, 0)
	aHeader7 := NIL
	aSize(aCOLS7, 0)
	aCols7 := NIL
EndIf

Return nRecAF9

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203SetOption³ Autor ³ Edson Maricate     ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla a GetDados ativa na visualizacao do      ³±±
±±³          ³ Folder.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A203SetOption(nFolder,nOldFolder,aCols,aHeader,aColsSV,aHeaderSV,aSavN,oGD,oGraph)

If nOldFolder <= Len(aHeaderSV) .And. !Empty(aHeaderSV[nOldFolder])

	// salva o conteudo da GetDados se existir
	aColsSV[nOldFolder]		:= aClone(aCols)
	aHeaderSV[nOldFolder]	:= aClone(aHeader)
	aSavN[nOldFolder]		:= n
	oGD[nOldFolder]:oBrowse:lDisablePaint	:= .T.
EndIf

If nFolder!=Nil.And.nFolder <= Len(aHeaderSV) .And. !Empty(aHeaderSV[nFolder])
	oGD[nFolder]:oBrowse:lDisablePaint	:= .F.

	// restaura o conteudo da GetDados se existir
	aCols	:= aClone(aColsSV[nFolder])
	aHeader := aClone(aHeaderSV[nFolder])
	n		:= aSavN[nFolder]
	oGD[nFolder]:oBrowse:Refresh()
	nGDAtu	:= nFolder
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD1LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 1.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD1LinOk(lCalcCusto,lCheckCols,lTdOk)

Local lRet       := .T.
Local nPosItem   := aScan(aHeader,{|x| AllTrim(x[2])=="AFA_ITEM"})
Local nPosAcu    := aScan(aHeader,{|x| Alltrim(x[2])==Alltrim("AFA_ACUMUL")})
Local nPosDtA    := aScan(aHeader,{|x| Alltrim(x[2])==Alltrim("AFA_DTAPRO")})
Local nPosPLNPor := aScan(aHeader,{|x| Alltrim(x[2])==Alltrim("AFA_PLNPOR")})
Local nPosProd   := aScan(aHeader,{|x| Alltrim(x[2])==Alltrim("AFA_PRODUT")})
Local l203Linok1 := ExistBlock("A203LINOK1")
Local lCalcTrib  := IIf(AF8->(AF8->AF8_PAR006 == '1') , .T., .F.)	//Verifica se havera calculo de impostos para as tarefas
//Local nPosRec	  := aScan(aHeader,{|x| AllTrim(x[2])=="AFA_RECURS"})
Local nPosOpc    := aScan(aHeader,{|x| AllTrim(x[2])=="AFA_OPC"})
Local nPosMOpc   := aScan(aHeader,{|x| AllTrim(x[2])=="AFA_MOPC"})

Default lCalcCusto	:= .T.
Default lCheckCols	:= .T.
Default lTdOk		:= Iif(Valtype(lTdOk)<>"L",.F.,lTdOk)

If Type("lCalcCusto") <> "L"
	lCalcCusto	:= .T.
EndIf

If Type("lCheckCols") <> "L"
	lCheckCols	:= .T.
EndIf

If Empty(acols[n,nPosOpc]) .And. Empty(aCols[n,nPosMOpc])
	lRet	:= PMSSelAFAOpc()
EndIf

If lCheckCols .And. lRet
	lRet := MaCheckCols(aHeader,aCols,n)
EndIf

If !(aCols[n][Len(aHeader)+1])
	If Inclui .And. lRet .And. ! aCols[n][Len(aCols[n])]
		lRet := PmsVldFase("AF8",M->AF9_PROJET,"27")
	ElseIf Altera .And. lRet .And. ! aCols[n][Len(aCols[n])]
		AFA->(dbSetOrder(8))
		If AFA->(MsSeek(xFilial() + M->AF9_PROJET + M->AF9_REVISA + ;
			M->AF9_TAREFA + aCols[n][nPosItem] + Space(Len(AFA->AFA_RECURS))))
			If Empty(AFA->AFA_RECURS)
				If AFA->AFA_PRODUT != aCols[n][nPosProd]
					lRet := PmsVldFase("AF8", M->AF9_PROJET, "28")
				EndIf
			EndIf
		Else
			lRet := PmsVldFase("AF8", M->AF9_PROJET, "27")
		EndIf
	EndIf

	// Vai validar se existe os 2 campos AFA_ACUMUL E AFA_DTAPRO
	If lRet .And. (nPosAcu > 0 .And. nPosDtA > 0)
		// for 5- Data de Apropriacao ou 6-Rateio a partir da data de apropriacao
		// e a data de apropriacao vazio, avisa q deve ser informado.
		If aCols[n][nPosAcu]$"5/6" .And. Empty(aCols[n][nPosDtA])
			Alert(STR0113) //"Tipo de Rateio de Apropriacao, é necessario preencher o campo Dat. Aprop. (Data de Apropriacao)"
			lRet:=.F.
		EndIf
	EndIf

	//
	// se existir o campo "planeja por" verifica se o produto vai utilizar pelo 'cronograma de periodo',
	// nesse caso a tarefa deve ter o campo de metodo de meddicao igual.
	//
	If lRet .And. nPosPLNPor > 0
		// Naum permite selecionar por "cronograma por periodo" se a tarefa naum for do mesmo tipo
		If aCols[n][nPosPLNPor] == "2" .AND. M->AF9_TPMEDI # "6"
			Help("  ",1,"PMSA203",,STR0120 + str(n,3,0) + STR0121 +CRLF+ ; // "Na linha " ## " não pode ser definido o planejamento por "
			STR0122 +CRLF+ ; // "'Cronograma por periodo', pois é necessario que a tarefa "
			STR0123 ,1,1) // "utilize o método de medição 'Cronograma por periodo'."
			lRet:=.F.
		EndIf
	EndIf

EndIf

If lCalcCusto

	//Atualiza pasta de tributos da tarefa
	If lCalcTrib
		A203GDAN9Inc(aHeader,aCols, n, 1, aCols[n][Len(aCols[n])] )
	EndIf

	// atualiza o custo da tarefa
	If ExistTemplate("CCTAF9CUSTO")
		ExecTemplate("CCTAF9CUSTO",.F.,.F.,{oFolder:nOption})
	Else
		If !lTdOk // Proteção nao impedir a rotina entrar em um FOR desnecessario, pois caso lTdOk = .T., sinal que já executamos este for anteriormente.
			A203GDCalcCust(Iif(Type("oFolder")="O",oFolder:nOption,)) //Proteção para automação de testes
		Endif
	EndIf
EndIf

// verifica a existencia do ponto de entrada para validacao da linha do aCols no produto
If lRet .and. l203Linok1
	lRet := Execblock("A203LINOK1",.F.,.F.,{lRet})
EndIf


Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD1TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 1.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD1TudOk(nGet)

Local nx
Local lRet := .T.
Local nPosProd	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFA_PRODUT"})
Local nPosQT	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFA_QUANT"})
Local nSavN	:= n
Local lCalcCusto:= .T.

DEFAULT nGet := Iif(Type("oFolder")="O",oFolder:nOption,1)
// se a getdados não foi alterada,
// não é necessário validar os dados
If !IsAuto() .AND. !oGd[1]:lModified
	Return lRet
EndIf

For nx := 1 to Len(aCols)
	n	:= nx
	If !(aCols[n][Len(aHeader)+1]) .And. !Empty(aCols[n][nPosProd]) .Or. !Empty(aCols[n][nPosQT])
		If !A203GD1LinOk(lCalcCusto,.F.,.T.)
			lRet := .F.
			Exit
		EndIf
		lCalcCusto	:= .F.
	EndIf
Next

If lRet
	A203GDCalcCust(nGet)
Endif

n := nSavN

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD5LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 5.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD5LinOk(lCalcCusto)

Local aArea       := GetArea()
Local aAreaSX3    := SX3->(GetArea())
Local aAreaSX2    := SX2->(GetArea())
Local lRet        := .T.
Local nPosItem    := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("AFA_ITEM")})
Local nPosRec     := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("AFA_RECURS")})
Local nPosDtPrf   := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("AFA_DATPRF")})
Local nPosQt      := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("AFA_QUANT")})
Local nPosAloc    := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("AFA_ALOC")})
Local nPosCampo   := 0
Local nPos_ACUMUL := aScan(aHeader,{|x| Alltrim(x[2]) == Alltrim("AFA_ACUMUL")})
Local nPos_DTAPRO := aScan(aHeader,{|x| Alltrim(x[2]) == Alltrim("AFA_DTAPRO")})
Local nPos_PLNPor := aScan(aHeader,{|x| Alltrim(x[2]) == Alltrim("AFA_PLNPOR")})
Local lValida	  := .T.
Local lCalcTrib   := IIf(AF8->AF8_PAR006 == '1' , .T., .F.)	//Verifica se havera calculo de impostos para as tarefas
Local lVldRec 		:= .T.
Local lVldDtPrf 	:= .T.
Local lVldQuant	:= .T.
Local nX			:= 0

Default lCalcCusto := .T.

If Type("lCalcCusto") <> "L"
	lCalcCusto	:= .T.
EndIf

// caso seja um tipo de tarefa - Duração Fixa e com agendamento, nao precisa validar a falta de quantidade.
If !IsAuto() .AND. (M->AF9_AGCRTL=="1") .AND. (M->AF9_TPTRF=="1")
	lValida := Empty(aCols[n][nPosRec]) .Or. Empty(aCols[n][nPosDtPrf]) .or. (n==1)

Endif

If lValida .AND. !IsAuto() .AND. Empty(M->AF9_HDURAC)
	For nX := 1 to Len(aCols)
		If Empty(aCols[nX][nPosQt]) .OR. Empty(aCols[nX][nPosAloc])
			Help(NIL, NIL, STR0195, NIL, STR0196, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0197}) // "Alocação de recurso"##"Foi informado recurso para a tarefa, mas esta não possui duração."##"Favor informar a duração para que a alocação seja calculada."
			lRet := .F.
		EndIf
	Next nX
EndIf

lVldRec 		:= (	nPosRec>0 	.and. Empty(aCols[n][nPosRec])	)
lVldDtPrf 	:= (	nPosDtPrf>0	.and.	Empty(aCols[n][nPosDtPrf]) )
lVldQuant	:= (	nPosQt>0 	.and.	(aCols[n][nPosQt] == 0)		)

If !(aCols[n][Len(aHeader)+1]) .and. lValida
	If lVldRec .Or. lVldDtPrf	.Or. lVldQuant
		Do Case
			Case lVldRec
				nPosCampo:= nPosRec
			Case lVldDtPrf
				nPosCampo:= nPosDtPrf
			Case lVldQuant
				nPosCampo:= nPosQt
		EndCase

		SX3->(dbSetOrder(2))
		SX3->(MsSeek(aHeader[nPosCampo][2]))
		SX2->(dbSetOrder(1))
		SX2->(MsSeek(SX3->X3_ARQUIVO))
		Help("  ",1,"OBRIGAT2",,X2NOME()+CRLF+STR0048+X3DESCRIC()+CRLF+STR0049+Str(n,3,0),3,1) //"Campo: "###"Linha: "
		lRet:= .F.
	EndIf

	If lRet .AND. Inclui
		lRet := PmsVldFase("AF8",M->AF9_PROJET,"27")
	EndIf

	If lRet .AND. Altera
		AFA->(dbSetOrder(1))
		If AFA->(dbSeek(xFilial()+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA+aCols[n][nPosItem]))

			If !Empty(AFA->AFA_RECURS) .and. ( nPosRec > 0 )
				If AFA->AFA_RECURS != aCols[n][nPosRec]
					lRet := PmsVldFase("AF8", M->AF9_PROJET, "28")
				EndIf
			EndIf
		Else
			lRet := PmsVldFase("AF8", M->AF9_PROJET, "27")
		EndIf
	EndIf

	// Vai validar se existe os 2 campos AFA_ACUMUL E AFA_DTAPRO
	If lRet .AND. (nPos_ACUMUL> 0 .AND. nPos_DTAPRO >0)

		// for 5- Data de Apropriacao ou 6-Rateio a partir da data de apropriacao
		// e a data de apropriacao vazio, avisa q deve ser informado.
		If aCols[n][nPos_ACUMUL]$"5/6" .And. Empty(aCols[n][nPos_DTAPRO])
			Alert(STR0113) //"Tipo de Rateio de Apropriacao, é necessario preencher o campo Dat. Aprop. (Data de Apropriacao)"
			lRet := .F.
		EndIf
	EndIf

	//
	// se existir o campo "planeja por" verifica se o produto vai utilizar pelo 'cronograma de periodo',
	// nesse caso a tarefa deve ter o campo de metodo de meddicao igual.
	//
	If lRet .And. nPos_PLNPor > 0

		// Naum permite selecionar por "cronograma por periodo" se a tarefa naum for do mesmo tipo
		If aCols[n][nPos_PLNPor] == "2" .AND. M->AF9_TPMEDI # "6"
			Help("  ",1,"PMSA203",,STR0120 + str(n,3,0) + STR0121 +CRLF+ ; // "Na linha " ## " não pode ser definido o planejamento por "
			STR0122 +CRLF+ ; // "'Cronograma por periodo', pois é necessario que a tarefa "
			STR0123 ,1,1) // "utilize o método de medição 'Cronograma por periodo'."
			lRet:=.F.
		EndIf
	EndIf

	// Se existir a coluna AFA_ALOC
	If lRet .And. nPosAloc>0
		// O valor contido não pode ser maior que a do campo
		If !ChkTam("AFA_ALOC",aCols[n][nPosAloc])
			SX3->(dbSetOrder(2))
			SX3->(MsSeek(aHeader[nPosAloc][2]))
			Help("  ",1,"PMSA203",,STR0184+AllTrim(X3Titulo())+STR0185+alltrim(str(n))+STR0186 ,1,1)
			lRet:=.F.
		EndIf
	EndIf
EndIf

If lCalcCusto

	//Atualiza pasta de tributos da tarefa
	If lCalcTrib
		A203GDAN9Inc(aHeader,aCols, n, 2, aCols[n][Len(aCols[n])] )
	EndIf

	// atualiza o custo da tarefa
	If ExistTemplate("CCTAF9CUSTO")
		ExecTemplate("CCTAF9CUSTO",.F.,.F.,{oFolder:nOption})
	ElseIf !Empty(oFolder)
		A203GDCalcCust(oFolder:nOption)
	Else
		A203GDCalcCust(FolderOrd(STR0040))
	EndIf
EndIf

RestArea(aAreaSX2)
RestArea(aAreaSX3)
RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD5TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 5.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD5TudOk()

Local nx
Local lRet		:= .T.
Local nPosRec	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFA_RECURS"})
Local nPosQT	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFA_QUANT"})
Local nSavN		:= n


// se a getdados não foi alterada,
// não é necessário validar os dados
If !IsAuto() .and. !oGd[5]:lModified
	Return lRet
EndIf

For nx := 1 to Len(aCols)
	n	:= nx
	If !(aCols[n][Len(aHeader)+1]) .And. (!Empty(aCols[n][nPosRec]) .Or. !Empty(aCols[n][nPosQT]))
		If !A203GD5LinOk(.F.)
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

n	:= nSavN

If lRet .And. ExistBlock("PMA203T5")
	lRet := ExecBlock("PMA203T5",.F.,.F.)
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD5FieldOk³ Autor ³ Edson Maricate    ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao Field Ok na GetDados 5                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD5FieldOk()
Local cCampo	 := ReadVar()
Local lRet		 := .T.
Local nPosRec	 := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_RECURS"})
Local nPosProd	 := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_PRODUT"})
Local nPosDtPrf	 := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_DATPRF"})
Local nPosCUSTD	 := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_CUSTD"})
Local nPosQt	 := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_QUANT"})
Local nPosDescri := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_DESCRI"})
Local nPosAloc	 := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_ALOC"})
Local nPosMoeda	 := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_MOEDA"})
Local nTotalEsf  := 0
Local nCount	 := 0
Local nX		 := 0
Local aArea
Local aAreaAFU
Local aAreaAFA
Local aAreaX3
Local lCalcTrib  := IIf(AF8->AF8_PAR006 == '1' , .T., .F.)	//Verifica se havera calculo de impostos para as tarefas

If (cCampo == "M->AFA_RECURS") .And. n<=len(aRecAFA2)
	If AF8->AF8_PAR002=="1" .Or. AF8->AF8_PAR002=="2"
		aArea	:= GetArea()
		aAreaAFU:= AFU->(GetArea())
		aAreaAFA:= AFA->(GetArea())

		AFA->(dbGoto(aRecAFA2[n]))
		dbSelectArea("AFU")
		AFU->(dbSetOrder(1)) //AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA+AFU_RECURS
		If AFU->(MsSeek( xFilial("AFU")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+AFA->AFA_RECURS ))
			Aviso(STR0172,STR0174,{STR0061},2) //"Apontamentos encontrados"##"O recurso selecionado possui apontamentos e nao pode ser alterado"
			RestArea(aAreaAFA)
			RestArea(aAreaAFU)
			RestArea(aArea)
			Return .F.
		EndIf
		RestArea(aAreaAFA)
		RestArea(aAreaAFU)
		RestArea(aArea)
	EndIf
EndIf

Do Case
	Case cCampo == "M->AFA_RECURS"
		If ! Empty(M->AFA_RECURS)
			AE8->(dbSetOrder(1))
			AE8->(dbSeek(xFilial("AE8")+M->AFA_RECURS))
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+AE8->AE8_PRODUT))
			If nPosDescri>0
				aCols[n][nPosDescri] := AE8->AE8_DESCRI
			Endif
			If !Empty(AE8->AE8_PRODUT)
				If nPosProd > 0
					aCols[n][nPosProd] 		:= AE8->AE8_PRODUT
				Endif
				If nposCustD > 0
					aCols[n][nposCustD]		:= RetFldProd(SB1->B1_COD,"B1_CUSTD")
				Endif
				//aCols[n][nPosDescri]	:= SB1->B1_DESC
			EndIf
			If !Empty(AE8->AE8_VALOR) .and. (nposCustD > 0)
				aCols[n][nposCustD]		:= AE8->AE8_VALOR
			EndIf
			If Empty(AE8->AE8_PRODUT) .And. Empty(AE8->AE8_VALOR)
				If nPosProd > 0
					aCols[n][nPosProd] 		:= CriaVar("AE8_PRODUT")
				Endif
				If nposCustD > 0
					aCols[n][nposCustD]		:= CriaVar("B1_CUSTD")
				Endif
				//aCols[n][nPosDescri]	:= CriaVar("B1_DESC")
			EndIf
		Else
			M->AFA_RECURS        := CriaVar(cCampo)
			aCols[n][nPosRec] 	:= CriaVar(cCampo)
			If nPosProd > 0
				aCols[n][nPosProd] 	:= CriaVar("AE8_PRODUT")
			Endif
			If nposCustD > 0
				aCols[n][nposCustD]	:= CriaVar("B1_CUSTD")
			Endif
			If nPosDescri > 0
				aCols[n][nPosDescri]	:= CriaVar("B1_DESC")
			Endif
		EndIf

		//		aCols[n][nPosAloc]  := 0
		//		aCols[n][nPosQt]    := 0
		If nPosDtPrf > 0
			aCols[n][nPosDtPrf] := M->AF9_START
		EndIf

		//Atualizacao de Tributos
		If lCalcTrib
			A203GDAN9Inc(aHeader,aCols, n, 2, aCols[n][Len(aCols[n])] )
		EndIf

	Case cCampo == "M->AFA_QUANT"
		AE8->(dbSetOrder(1))
			Do Case
				CASE M->AF9_TPTRF == "1" // Duração Fixa

					If (M->AF9_HDURAC == 0)
						aCols[n][nPosQt] 	:= &cCampo
						If nPosAloc>0
							M->AF9_HDURAC := aCols[n][nPosQt] * (0,01) /  (aCols[n][nPosAloc] / 100)
						Endif

						If	M->AF9_HDURAC > 0
							PMS203DHRS(.F.)
						Endif
					Else
						If AE8->(dbSeek(xFilial("AE8")+aCols[n][nPosRec]))
							aCols[n][nPosQt] 	 := &cCampo
							If nPosAloc > 0
								aCols[n][nPosAloc] := (PmsAFAQuant(M->AF9_PROJET,M->AF9_REVISA,M->AF9_TAREFA,aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="AFA_PRODUT"})],M->AF9_QUANT,&cCampo,M->AF9_HDURAC,,aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="AFA_RECURS"})])/PmsHrsItvl(M->AF9_START,M->AF9_HORAI,M->AF9_FINISH,M->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,M->AF9_CALEND),M->AF9_PROJET,AE8->AE8_RECURS))*100
							Endif
						Else
							M->AFA_QUANT := 0
							If nPosAloc > 0
								aCols[n][nPosAloc] := 0
							Endif
							aCols[n][nPosQt]	 := 0
						EndIf
					Endif

				CASE M->AF9_TPTRF == "2" // Trabalho Fixo

					If (M->AF9_HDURAC == 0)
						If nPosAloc > 0
							aCols[n][nPosQt] 	:= &cCampo
							M->AF9_HDURAC 		:= aCols[n][nPosQt] * (0,01) /  (aCols[n][nPosAloc] / 100)
						Endif
						If	M->AF9_HDURAC > 0
							PMS203DHRS(.F.)
						Endif
					Else
						If (aCols[n][nPosQt]==0) .and. nPosRec > 0 // caso a linha de alteração seja nova, calcula
							If AE8->(dbSeek(xFilial("AE8")+aCols[n][nPosRec]))
								aCols[n][nPosQt] 	 := &cCampo
								If nPosAloc > 0
									aCols[n][nPosAloc] := 100
								Endif
							Else
								M->AFA_QUANT := 0
								If nPosAloc > 0
									aCols[n][nPosAloc] := 0
								Endif
								aCols[n][nPosQt]	 := 0
							EndIf

						Else  // tratamento para atualizar o aCols corretammente
							If nPosRec > 0
								If AE8->(dbSeek(xFilial("AE8")+aCols[n][nPosRec]))
									aCols[n][nPosQt] := &(ReadVar())
								else
									aCols[n][nPosQt] := 0
								EndIf
							Endif
						EndIf

	               Pms203DtFim(aHeader, aCols)
					EndIf

				CASE M->AF9_TPTRF == "3" // unidades fixas

					If (M->AF9_HDURAC == 0)
						If nPosQt > 0 .and. nPosAloc > 0
							aCols[n][nPosQt] 	:= &cCampo
							M->AF9_HDURAC := aCols[n][nPosQt] * (0,01) /  (aCols[n][nPosAloc] / 100)
						Endif
						If	M->AF9_HDURAC > 0
							PMS203DHRS(.F.)
						Endif
					Else
						If nPosQt > 0
							If (aCols[n][nPosQt]==0) .and. nPosRec>0 // caso a linha de alteração seja nova, calcula
								If AE8->(dbSeek(xFilial("AE8")+aCols[n][nPosRec]))
									aCols[n][nPosQt] 	:= &cCampo
									If (nPosAloc>0)
										aCols[n][nPosAloc]:= 100 //(PmsAFAQuant(M->AF9_PROJET,M->AF9_REVISA,M->AF9_TAREFA,aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="AFA_PRODUT"})],M->AF9_QUANT,&cCampo,M->AF9_HDURAC,,aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="AFA_RECURS"})])/PmsHrsItvl(M->AF9_START,M->AF9_HORAI,M->AF9_FINISH,M->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,M->AF9_CALEND),M->AF9_PROJET,AE8->AE8_RECURS))*100
									Endif
								Else
									M->AFA_QUANT := 0
									If (nPosAloc>0)
										aCols[n][nPosAloc] := 0
									Endif
								aCols[n][nPosQt]	 := 0
							EndIf
	  						Pms203DtFim(aHeader, aCols)
						Else

							If (nPosRec>0) .and. (nPosQt>0) .and. AE8->(dbSeek(xFilial("AE8")+aCols[n][nPosRec]))
								aCols[n][nPosQt] := &(ReadVar())
							Else
								aCols[n][nPosQt] := 0
							EndIf
							Pms203DtFim(aHeader, aCols)
						EndIf
					Endif
				EndIf
			EndCase
			P203SomaEsf() // Recalcula o valor do esforço da tarefa baseado nos novos esforços dos recursos


	/* RETIRADA VALIDAÇÃO POIS ESTA IMPEDE O USO DO CAMPO QTD NA ALOCAÇÃO, SEMPRE MOSTRAVA MSG INDEVIDAMENTE. CUIDADO AO INCLUIR TAL VALIDAÇÃO
		// Verifica se a quantidade de horas
		aAreaX3	:= SX3->( GetArea() )
		DbSelectArea( "SX3" )
		SX3->( DbSetOrder( 2 ) )
		If SX3->( DbSeek( "AFA_ALOC" ) )
			If Len( AllTrim( Str( aCols[n][nPosAloc] ) ) ) > TamSX3( "AFA_ALOC" )[1] - TamSX3( "AFA_ALOC" )[2] - 1
				Help("  ",1,"ALOC_PERC",, X2NOME() + CRLF+STR0048+X3DESCRIC()+CRLF+STR0049+Str(n,3,0),3,1)
				Return .F.
			EndIf
		EndIf

		RestArea( aAreaX3 )*/
		//Atualizacao de Tributos
		If lCalcTrib
			A203GDAN9Inc(aHeader,aCols, n, 2, aCols[n][Len(aCols[n])] )
		EndIf

	Case cCampo == "M->AFA_ALOC"

		AE8->(dbSetOrder(1))
	        //case para 1
			Do Case

				CASE M->AF9_TPTRF == "1" // Duração Fixa

					If (M->AF9_HDURAC == 0)
						aCols[n][nPosAloc] := &cCampo
						If (nPosQt>0)
							M->AF9_HDURAC 		 := aCols[n][nPosQt]*(0,01) / (aCols[n][nPosAloc] / 100)
						Endif
						If	M->AF9_HDURAC > 0
							PMS203DHRS(.F.)
						Endif
					Else
	               If M->AF9_AGCRTL == "2" .OR. (LenVal(aCols)<2) .and. (nPosRec>0)
							If AE8->(dbSeek(xFilial("AE8")+aCols[n][nPosRec]))
								If (nPosQt>0)
									aCols[n][nPosQt]	:= PmsIAFAQuant(M->AF9_PROJET,M->AF9_REVISA,M->AF9_TAREFA,aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="AFA_PRODUT"})],M->AF9_QUANT,(&cCampo*PmsHrsItvl(M->AF9_START,M->AF9_HORAI,M->AF9_FINISH,M->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,M->AF9_CALEND),M->AF9_PROJET,AE8->AE8_RECURS))/100,M->AF9_HDURAC,,aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="AFA_RECURS"})])
								Endif
								If ExistTemplate("CCTAFAALOC")
									ExecTemplate("CCTAFAALOC",.F.,.F.)
								EndIf
							EndIf
						Else
							PmsAgendEsf()
						EndIf
					EndIf

				CASE M->AF9_TPTRF == "2" // Trabalho fixo

					If (M->AF9_HDURAC == 0) .or. (LenVal(aCols)==1)
						aCols[n][nPosAloc] := &cCampo
						If (nPosQt>0)
							aCols[n][nPosQt]	:= PmsIAFAQuant(M->AF9_PROJET,M->AF9_REVISA,M->AF9_TAREFA,aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="AFA_PRODUT"})],M->AF9_QUANT,(&cCampo*PmsHrsItvl(M->AF9_START,M->AF9_HORAI,M->AF9_FINISH,M->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,M->AF9_CALEND),M->AF9_PROJET,AE8->AE8_RECURS))/100,M->AF9_HDURAC,,aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="AFA_RECURS"})])
						Endif
						If	M->AF9_HDURAC > 0
							PMS203DHRS(.F.)
						Endif
					Else
						If (nPosQt>0) .and. (aCols[n][nPosQt]==0) // caso a linha de alteração seja nova, calcula
							If (nPosRec>0) .and. AE8->(dbSeek(xFilial("AE8")+aCols[n][nPosRec])) .and. (nPosQt>0)
								aCols[n][nPosQt]	:= PmsIAFAQuant(M->AF9_PROJET,M->AF9_REVISA,M->AF9_TAREFA,aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="AFA_PRODUT"})],M->AF9_QUANT,(&cCampo*PmsHrsItvl(M->AF9_START,M->AF9_HORAI,M->AF9_FINISH,M->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,M->AF9_CALEND),M->AF9_PROJET,AE8->AE8_RECURS))/100,M->AF9_HDURAC,,aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="AFA_RECURS"})])
								If ExistTemplate("CCTAFAALOC")
									ExecTemplate("CCTAFAALOC",.F.,.F.)
								EndIf
							EndIf

							If (LenVal(aCols)>1)   //só calcula agendamento na primeira entrada de dados
								PmsAgendEsf()    // depois da primeira, nao se recalcula
								Pms203DtFim(aHeader,aCols,M->AF9_HDURAC)
							EndIf

						EndIf

					Endif

				CASE M->AF9_TPTRF == "3" // unidades fixas
					If (M->AF9_HDURAC == 0)// .and. (aCols[n][nPosAloc]<>0)
						aCols[n][nPosAloc] := &cCampo
						If (nPosQt>0)
							M->AF9_HDURAC := aCols[n][nPosQt] * (0,01) /  (aCols[n][nPosAloc] / 100)
						Endif
						If	M->AF9_HDURAC > 0
							PMS203DHRS(.F.)
						Endif
					Else
						If M->AF9_AGCRTL == "2" .OR. (LenVal(aCols)<2) .and. (nPosQt>0) .and. (nPosAloc>0)
						 	aCols[n][nPosQt]	:= (aCols[n][nPosAloc]/100)*(M->AF9_HDURAC)
							Pms203DtFim(aHeader,aCols)
							If ExistTemplate("CCTAFAALOC")
								ExecTemplate("CCTAFAALOC",.F.,.F.)
							EndIf
						Else
							PmsAgendEsf()
							Pms203DtFim(aHeader,aCols,M->AF9_HDURAC)
						EndIf
					EndIf
			EndCase

			P203SomaEsf()// Recalcula o valor do esforço da tarefa baseado nos novos esforços dos recursos



		If lCalcTrib
			A203GDAN9Inc(aHeader,aCols, n, 2, aCols[n][Len(aCols[n])] )
		EndIf


	Case cCampo == "M->AFA_CUSTD"
		aCols[n][nposCustD] := &cCampo

		//Atualizacao de Tributos
		If lCalcTrib
			A203GDAN9Inc(aHeader,aCols, n, 2, aCols[n][Len(aCols[n])] )
		EndIf

	Case cCampo == "M->AFA_MOEDA"
		aCols[n][nposMoeda] := &cCampo

EndCase

// atualiza o custo da tarefa
If ExistTemplate("CCTAF9CUSTO")
	ExecTemplate("CCTAF9CUSTO",.F.,.F.,{oFolder:nOption})
Else
	A203GDCalcCust(oFolder:nOption)
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD1FieldOk³ Autor ³ Edson Maricate    ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao Field Ok na GetDados 1                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD1FieldOk()
Local cCampo     := ReadVar()
Local lRet	     := .T.
Local nPosProd	 := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_PRODUT"})
Local nPosCUSTD  := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_CUSTD"})
Local nPosQt	 := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_QUANT"})
Local nPosDescri := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_DESCRI"})
Local nPosMoeda  := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_MOEDA"})
Local lCalcTrib  := IIf(AF8->AF8_PAR006 == '1' , .T., .F.)	//Verifica se havera calculo de impostos para as tarefas

Do Case
	Case cCampo == "M->AFA_PRODUT"
		SB1->(dbSetOrder(1))

		If ! Empty(M->AFA_PRODUT) .And.;
			SB1->(dbSeek(xFilial("SB1")+M->AFA_PRODUT))
			If (nPosProd > 0)
				aCols[n][nPosProd] 		:= M->AFA_PRODUT
			Endif
			If (nposCustD > 0)
				aCols[n][nposCustD]		:= RetFldProd(SB1->B1_COD,"B1_CUSTD")
			Endif
			If (nPosDescri > 0)
				aCols[n][nPosDescri]	:= SB1->B1_DESC
			Endif
		Else
			If (nPosProd > 0)
				aCols[n][nPosProd] 		:= CriaVar("AFA_PRODUT")
			Endif
			If (nposCustD > 0)
				aCols[n][nposCustD]		:= CriaVar("B1_CUSTD")
			Endif
			If (nPosDescri > 0)
				aCols[n][nPosDescri]	:= CriaVar("B1_DESC")
			EndIf
		EndIf

		//Atualizacao de Tributos
		If lCalcTrib
			A203GDAN9Inc(aHeader,aCols, n, 1, aCols[n][Len(aCols[n])] )
		EndIf

	Case cCampo == "M->AFA_QUANT"
		aCols[n][nPosQt] 		:= &cCampo

		//Atualizacao de Tributos
		If lCalcTrib
			A203GDAN9Inc(aHeader,aCols, n, 1, aCols[n][Len(aCols[n])] )
		EndIf

	Case cCampo == "M->AFA_MOEDA"
		aCols[n][nposMoeda] := &cCampo

	Case cCampo == "M->AFA_CUSTD"
		aCols[n][nposCustD] := &cCampo

		//Atualizacao de Tributos
		If lCalcTrib
			A203GDAN9Inc(aHeader,aCols, n, 1, aCols[n][Len(aCols[n])] )
		EndIf
EndCase

// atualiza o custo da tarefa
If ExistTemplate("CCTAF9CUSTO")
	ExecTemplate("CCTAF9CUSTO",.F.,.F.,{oFolder:nOption})
Else
	A203GDCalcCust(oFolder:nOption)
	If cCampo == "M->AFA_CUSTD" .and. M->AF9_CUSTO == 0
		M->AF9_VALBDI:= M->AF9_CUSTO
		M->AF9_TOTAL := M->AF9_CUSTO+M->AF9_VALBDI
		If !IsAuto() .and. Type("oEnch")="O"
			oEnch:Refresh()
		EndIf
	Endif
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD2FieldOk³ Autor ³ Edson Maricate    ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao Field Ok na GetDados 2                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD2FieldOk()
Local cCampo    := ReadVar()
Local lRet	    := .T.
Local nPosMoeda := aScan(aHeader,{|x|AllTrim(x[2])=="AFB_MOEDA"})
Local nPosValor := aScan(aHeader,{|x|AllTrim(x[2])=="AFB_VALOR"})

Do Case

	Case cCampo == "M->AFB_MOEDA"
		aCols[n][nposMoeda] := &cCampo

	Case cCampo == "M->AFB_VALOR"
		aCols[n][nposValor] := &cCampo

EndCase

// atualiza o custo da tarefa
If ExistTemplate("CCTAF9CALC")
	ExecTemplate("CCTAF9CALC",.F.,.F.,{oFolder:nOption})
	If !IsAuto() .and. valtype(oEnch)="O"
		oEnch:Refresh()
	EndIf
Else
	A203GDCalcCust(oFolder:nOption)
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD6FieldOk³ Autor ³ Edson Maricate    ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao Field Ok na GetDados 6                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD6FieldOk()
//Local lAux := .T.
Local lRet := .T.
Local cVar := &(ReadVar())
Local nTotPerc := 0
Local dIni	:= PMS_MAX_DATE
Local dFim	:= PMS_MIN_DATE
Local nx := 0

For nx := 1 to Len(aHeader)
	If nx==nNewCol // Variavel private criada pela getdados nao retirar
		nTotPerc += cVar
		If cVar > 0 .And. CTOD(aHeader[nx][1]) < dIni
			dIni := CTOD(aHeader[nx][1])
		EndIf
		If cVar > 0 .And. CTOD(aHeader[nx][1]) > dFim
			dFim := CTOD(aHeader[nx][1])
		EndIf
	Else
		nTotPerc += aCols[1][nx]
		If aCols[1][nx] > 0 .And. CTOD(aHeader[nx][1]) < dIni
			dIni := CTOD(aHeader[nx][1])
		EndIf
		If aCols[1][nx]>0 .And. CTOD(aHeader[nx][1]) > dFim
			dFim := CTOD(aHeader[nx][1])
		EndIf
	EndIf
Next

If dIni<=dFim
	Do Case
		Case AF8->AF8_TPPERI == "2"
			dFim	+= 7
		Case AF8->AF8_TPPERI == "3"
			If DAY(dFim) == 01
				dFim	:= CTOD("14/"+StrZero(MONTH(dFim),2,0)+"/"+StrZero(YEAR(dFim),4,0))
			Else
				dFim 	+= 25
				dFim	:= CTOD("01/"+StrZero(MONTH(dFim),2,0)+"/"+StrZero(YEAR(dFim),4,0))-1
			EndIf
		Case AF8->AF8_TPPERI == "4"
			dFim	:= LastDay(CTOD("01/"+StrZero(MONTH(dFim),2,0)+"/"+StrZero(YEAR(dFim),4,0)))
	EndCase
	If nTotPerc <= 100
		M->AF9_HDURAC:= 1
		M->AF9_START := dIni
		M->AF9_HORAI := PMS_MIN_HOUR
		M->AF9_FINISH := dFim
		M->AF9_HORAF := PMS_MAX_HOUR
		If !Pms203DINI(!IsAuto())
			M->AF9_START := PMS_EMPTY_DATE
			M->AF9_HORAI := PMS_MIN_HOUR
			lRet := .F.
		EndIf
		If lRet
			M->AF9_FINISH := dFim
			M->AF9_HORAF := "24:00"
			If !Pms203DFim(.F.,2)
				M->AF9_START := PMS_EMPTY_DATE
				M->AF9_HORAI := PMS_MIN_HOUR
				M->AF9_FINISH:= PMS_EMPTY_DATE
				M->AF9_HORAF := PMS_MIN_HOUR
				lRet := .F.
			EndIf
			If nTotPerc <> 100
				M->AF9_START := PMS_EMPTY_DATE
				M->AF9_HORAI := PMS_MIN_HOUR
				M->AF9_FINISH:= PMS_EMPTY_DATE
				M->AF9_HORAF := PMS_MIN_HOUR
			EndIf
		EndIf
	Else
		MsgAlert(STR0124)
		lRet := .F.
	EndIf
	oEnch:Refresh()
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD3FieldOk³ Autor ³ Marcelo AKama     ³ Data ³ 16-08-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao Field Ok na GetDados 3                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD3FieldOk()
Local cCampo    := ReadVar()
Local lRet	    := .T.
Local aArea		:= {}
Local aAreaAFF	:= {}
Local nPerc
Local nPosTpVRl := aScan(aHeader,{|x|AllTrim(x[2])=="AFD_TPVREL"})
Local nPosTipo  := aScan(aHeader,{|x|AllTrim(x[2])=="AFD_TIPO"})
Local nPosPred  := aScan(aHeader,{|x|AllTrim(x[2])=="AFD_PREDEC"})

If cCampo == "M->AFD_TPVREL"
	If &cCampo == "1"
		aArea := GetArea()
		dbSelectArea("AFF")
		aAreaAFF := AFF->(GetArea())
		AFF->(dbSetOrder(1)) //AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA+DTOS(AFF_DATA)

		If AFF->( MsSeek(xFilial("AFF")+M->AF9_PROJET+M->AF9_REVISA+aCols[n][nPosPred]) )
			Do While !AFF->(Eof()) .And. AFF->(AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA)==xFilial("AFF")+M->AF9_PROJET+M->AF9_REVISA+aCols[n][nPosPred]
				AFF->(dbSkip())
			EndDo
			AFF->(dbSkip(-1))
			nPerc := PMS310QT(.F.,"AFF")
		Else
			nPerc := 0
		EndIf
		Do Case
			Case aCols[n][nPosTipo]=="1" // Fim no Inicio
				If nPerc < 100
					Aviso(STR0014,STR0175,{STR0061},2) //"Atencao"###"Não será possível realizar confirmações nesta tarefa, pois a tarefa predecessora não está encerrada."###"Fechar"
				EndIf
			Case aCols[n][nPosTipo]=="2" // Inicio no Inicio
				If nPerc <= 0
					Aviso(STR0014,STR0176,{STR0061},2) //"Atencao"###"Não será possível realizar confirmações nesta tarefa, pois a tarefa predecessora não foi iniciada."###"Fechar"
				EndIf
			Case aCols[n][nPosTipo]=="3" // Fim no Fim
				If nPerc < 100
					Aviso(STR0014,STR0177,{STR0061},2) //"Atencao"###"Não será possível encerrar esta tarefa, pois a tarefa predecessora não está encerrada."###"Fechar"
				EndIf
			Case aCols[n][nPosTipo]=="4" // Inicio no Fim
				If nPerc <= 0
					Aviso(STR0014,STR0178,{STR0061},2) //"Atencao"###"Não será possível encerrar esta tarefa, pois a tarefa predecessora não foi iniciada."###"Fechar"
				EndIf
		EndCase

		RestArea(aAreaAFF)
		RestArea(aArea)
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD7FieldOk³ Autor ³ Marcelo AKama     ³ Data ³ 16-08-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao Field Ok na GetDados 7                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD7FieldOk()
Local cCampo    := ReadVar()
Local lRet	    := .T.
Local aArea		:= {}
Local aAreaAFQ	:= {}
Local nPerc
Local nPosTpVRl := aScan(aHeader,{|x|AllTrim(x[2])=="AJ4_TPVREL"})
Local nPosTipo  := aScan(aHeader,{|x|AllTrim(x[2])=="AJ4_TIPO"})
Local nPosPred  := aScan(aHeader,{|x|AllTrim(x[2])=="AJ4_PREDEC"})

If cCampo == "M->AJ4_TPVREL"
	If &cCampo == "1"
		aArea := GetArea()
		dbSelectArea("AFQ")
		aAreaAFQ := AFQ->(GetArea())
		AFF->(dbSetOrder(1)) //AFQ_FILIAL+AFQ_PROJET+AFQ_REVISA+AFQ_EDT+DTOS(AFQ_DATA)

		If AFQ->( MsSeek(xFilial("AFQ")+M->AF9_PROJET+M->AF9_REVISA+aCols[n][nPosPred]) )
			Do While !AFQ->(Eof()) .And. AFQ->(AFQ_FILIAL+AFQ_PROJET+AFQ_REVISA+AFQ_EDT)==xFilial("AFF")+M->AF9_PROJET+M->AF9_REVISA+aCols[n][nPosPred]
				AFQ->(dbSkip())
			EndDo
			AFQ->(dbSkip(-1))
			nPerc := PMS310QT(.F.,"AFQ")
		Else
			nPerc := 0
		EndIf
		Do Case
			Case aCols[n][nPosTipo]=="1" // Fim no Inicio
				If nPerc < 100
					Aviso(STR0014,STR0179,{STR0061},2) //"Atencao"###"Não será possível realizar confirmações nesta tarefa, pois a EDT predecessora não está encerrada."###"Fechar"
				EndIf
			Case aCols[n][nPosTipo]=="2" // Inicio no Inicio
				If nPerc <= 0
					Aviso(STR0014,STR0180,{STR0061},2) //"Atencao"###"Não será possível realizar confirmações nesta tarefa, pois a EDT predecessora não foi iniciada."###"Fechar"
				EndIf
			Case aCols[n][nPosTipo]=="3" // Fim no Fim
				If nPerc < 100
					Aviso(STR0014,STR0181,{STR0061},2) //"Atencao"###"Não será possível encerrar esta tarefa, pois a EDT predecessora não está encerrada."###"Fechar"
				EndIf
			Case aCols[n][nPosTipo]=="4" // Inicio no Fim
				If nPerc <= 0
					Aviso(STR0014,STR0182,{STR0061},2) //"Atencao"###"Não será possível encerrar esta tarefa, pois a EDT predecessora não foi iniciada."###"Fechar"
				EndIf
		EndCase

		RestArea(aAreaAFQ)
		RestArea(aArea)
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD2TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 2.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD2TudOk()

Local nx := 0
Local nPosDescri:= aScan(aHeader,{|x|AllTrim(x[2])=="AFB_DESCRI"})
Local nPosValor	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFB_VALOR"})
Local nSavN	:= n
Local lRet	:= .T.
Local nPosFolder := FolderOrd(STR0009)// Despesas

// se a getdados não foi alterada,
// não é necessário validar os dados
If !IsAuto()
	If nPosFolder>0 .AND. !oGd[nPosFolder]:lModified
		Return lRet
	EndIf
EndIf

For nx := 1 to Len(aCols)
	n	:= nx
	If !(aCols[n][Len(aHeader)+1])
		If !A203GD2LinOk(.F.)
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

n	:= nSavN

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD3TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 3.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD3TudOk()
Local nx := 0
Local nPosPredec	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFD_PREDEC"})
Local nSavN	:= n
Local lRet	:= .T.
Local nPosFolder := FolderOrd(STR0062)// 'Relac.Tarefas'

// se a getdados não foi alterada,
// não é necessário validar os dados
If !IsAuto()
	If nPosFolder>0 .AND. !oGd[nPosFolder]:lModified
		Return lRet
	EndIf
EndIf

For nx := 1 to Len(aCols)
	n	:= nx
	If !(aCols[n][Len(aHeader)+1]) .And. !Empty(aCols[n][nPosPredec])
		If !A203GD3LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

n	:= nSavN

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD2LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 2.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD2LinOk(lCalcCusto)

// verifica os campos obrigatorios do SX3
Local lRet			:= MaCheckCols(aHeader,aCols,n)
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="AFB_ITEM"})
Local nPosAcu		:= aScan(aHeader,{|x| Alltrim(x[2])==Alltrim("AFB_ACUMUL")})
Local nPosDtA		:= aScan(aHeader,{|x| Alltrim(x[2])==Alltrim("AFB_DTAPRO")})

Default lCalcCusto	:= .T.

If Type("lCalcCusto") <> "L"
	lCalcCusto	:= .T.
EndIf

If !(aCols[n][Len(aHeader)+1])
	If Inclui .And. lRet .And. ! aCols[n][Len(aCols[n])]
		lRet := PmsVldFase("AF8",M->AF9_PROJET,"30")
	ElseIf Altera .And. lRet .And. ! aCols[n][Len(aCols[n])]
		AFB->(dbSetOrder(1))
		If AFB->(dbSeek(xFilial()+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA+aCols[n][nPosItem]))
			lRet := PmsVldFase("AF8",M->AF9_PROJET,"31")
		Else
			lRet := PmsVldFase("AF8",M->AF9_PROJET,"30")
		EndIf
	EndIf
	// Vai validar se existe os 2 campos AFA_ACUMUL E AFA_DTAPRO
	If lRet .And. (nPosAcu > 0 .And. nPosDtA > 0)
		// for 5- Data de Apropriacao ou 6-Rateio a partir da data de apropriacao
		// e a data de apropriacao vazio, avisa q deve ser informado.
		If aCols[n][nPosAcu]$"5/6" .And. Empty(aCols[n][nPosDtA])
			Alert(STR0113) //"Tipo de Rateio de Apropriacao, é necessario preencher o campo Dat. Aprop. (Data de Apropriacao)"
			lRet := .F.
		EndIf
	EndIf
EndIf

// atualiza o custo da tarefa
If lCalcCusto
	If ExistTemplate("CCTAF9CUSTO")
		ExecTemplate("CCTAF9CUSTO",.F.,.F.,{oFolder:nOption})
	Else
		A203GDCalcCust(Iif(Type("oFolder")="O",oFolder:nOption,)) //Proteção para automação de testes
	EndIf
EndIf

If !IsBlind() //Proteção para automação de testes
	oEnch:Refresh()
EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD3LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 3.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD3LinOk()

// verifica os campos obrigatorios do SX3
Local lRet 		:= MaCheckCols(aHeader,aCols,n)
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="AFD_ITEM"})

If !(aCols[n][Len(aHeader)+1])
	If Inclui .And. lRet .And. ! aCols[n][Len(aCols[n])]
		lRet := PmsVldFase("AF8",M->AF9_PROJET,"33")
	ElseIf Altera .And. lRet .And. ! aCols[n][Len(aCols[n])]
		AFD->(dbSetOrder(1))
		If AFD->(dbSeek(xFilial()+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA+aCols[n][nPosItem]))
			lRet := PmsVldFase("AF8",M->AF9_PROJET,"34")
		Else
			lRet := PmsVldFase("AF8",M->AF9_PROJET,"33")
		EndIf
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD3DelOk³ Autor ³ Marcelo Akama       ³ Data ³ 03-04-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao DelOk da GetDados 3.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD3DelOk()

Local lRet 		:= .T.
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="AFD_PREDEC"})
Local nGet := Iif(Type("oFolder")="O",oFolder:nOption,FolderOrd(STR0062))
If (aCols[n][Len(aHeader)+1])
	lRet := MaCheckCols(aHeader,aCols,n) .and. Pms203VAFD(aCols[n][nPosItem])
EndIf

aColsSV[nGet] := aClone(aCols)

If !IsAuto()
	oGD[nGet]:oBrowse:Refresh()
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS203Grava³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a gravacao do Projeto.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA203                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS203Grava(lDeleta,aHeaderSV,aColsSV,nRecAF1,nRecAF9,aRecAFA,aRecAFB,aRecAFD,aRecAFP,aRecAFA2,aRecAFZ,aRecAJ4,aRecAEL,aRecAEN,cCompUnic, aSimEDT)
Local lAtuCron	  := .T.
Local lAltera	  := (nRecAF9!=Nil)
Local bCampo 	  := {|n| FieldName(n) }
Local nx
Local nCntFor
Local nCntFor2
Local nPosProd	  := 0
Local nPosDescri  := 0
Local nPosPrd	  := 0
Local nPosEvent   := 0
Local nPosRecurs  := 0
Local nPosPrd7	  := 0
Local nPosInsumo  := 0
Local nPosSubcom  := 0
Local aCabEmail   := {STR0052,STR0053,STR0054,STR0055,STR0056,STR0057,STR0088} //"Projeto .....: "###"Tarefa ......: "###"Data Inicial : "###"Hora Inicial : "###"Data Final ..: "###"Hora Final ..: " //"Observacoes"
Local cMailDest
Local cMailServer := SuperGetMv("MV_RELSERV")
Local nSMTPPort	:= SuperGetMV("MV_PORSMTP",.F.,25)  				// Porta SMTP.
Local cMailConta  := SuperGetMv("MV_EMCONTA")
Local cMailSenha  := SuperGetMv("MV_EMSENHA")
Local cMens1
Local cMens2
Local aRecEmail   := {}
Local aTxtEmail   := {}
Local lSendOk
Local lOk         := .F.
Local lEnviaEmail := .F.
Local nCntLin     := 0
Local nCntMail    := 0
Local nNewCod	  := 0
Local cChave      := ""
Local nOpc        := 0
Local aRecUso
Local dCrono
Local aAreaSX3    := {}

Local nPosFldAFD  := 0
Local nPastEven   := 0
Local nPosFldAFZ  := 0
Local nPastaEDT   := 0
Local nPosFldREC  := 0
Local nPosFldPRD  := 0
Local nPosFldAFB  := 0
Local nPosFldAJ4  := 0
Local nPosFldINS  := 0
Local nPosFldSUB  := 0
Local nContItem   := 1
Local lCompUnic   := AF8ComAJT(AF8->AF8_PROJET)
Local nCntCols    := 0
Local lPMA203Ass  := ExistBlock("PMA203Ass")
Local lPMA203Msg  := ExistBlock("PMA203Msg")
Local cRet		  := ""
Local cAssunto    := ""
Local lAltRec		:= SuperGetMv("MV_PMSAREC",,.T.) // Altera responsável da etapa ao incluir um novo recurso?
Local lRelauth	:= SuperGetMv("MV_RELAUTH")
Local aAJOArea		:= {}
Local nUser			:= 0
Local cUser			:= ""

Default cCompUnic := ""
Default aSimEDT   := {}
If !lCompUnic
	nPosFldPRD := FolderOrd(STR0039) // 'Produtos'
	nPosFldREC := FolderOrd(STR0040) // 'Aloc. Recursos'

	nPosRecurs := aScan(aHeaderSV[nPosFldREC],{|x|AllTrim(x[2])=="AFA_RECURS"})
	nPosProd   := aScan(aHeaderSV[nPosFldPRD],{|x|AllTrim(x[2])=="AFA_PRODUT"})
Else
	nPosFldINS := FolderOrd(STR0129) // 'Insumos'
	nPosFldSUB := FolderOrd(STR0130) // 'Subcomposicoes'

	nPosInsumo := aScan(aHeaderSV[nPosFldINS],{|x|AllTrim(x[2])=="AEL_INSUMO"})
	nPosSubcom := aScan(aHeaderSV[nPosFldSUB],{|x|AllTrim(x[2])=="AEN_SUBCOM"})
EndIf

nPosFldAFB := FolderOrd(STR0009) // 'Despesas'
nPosFldAFD := FolderOrd(STR0062) // 'Relac.Tarefas'
nPosFldAFP := FolderOrd(STR0038) // 'Eventos'
nPosFldAFZ := FolderOrd(STR0051) // 'Cronograma por Periodo'
nPosFldAJ4 := FolderOrd(STR0063) // 'Relac.EDT'
nPosFldAN9 := FolderOrd(STR0183) // 'Tributos'

nPosDescri := aScan(aHeaderSV[nPosFldAFB],{|x|AllTrim(x[2])=="AFB_DESCRI"})
nPosPrd	   := aScan(aHeaderSV[nPosFldAFD],{|x|AllTrim(x[2])=="AFD_PREDEC"})
nPosEvent  := aScan(aHeaderSV[nPosFldAFP],{|x|AllTrim(x[2])=="AFP_DESCRI"})
nPosPrd7   := aScan(aHeaderSV[nPosFldAJ4],{|x|AllTrim(x[2])=="AJ4_PREDEC"})

If !lDeleta

	// grava o arquivo de Tarefas do Projeto
	If lAltera
		AF9->(dbGoto(nRecAF9))
		If DTOS(M->AF9_START)+M->AF9_HORAI+DTOS(M->AF9_FINISH)+M->AF9_HORAF+M->AF9_CALEND+Str(M->AF9_HESF)==DTOS(AF9->AF9_START)+AF9->AF9_HORAI+DTOS(AF9->AF9_FINISH)+AF9->AF9_HORAF+AF9->AF9_CALEND+Str(AF9->AF9_HESF)
			lAtuCron	:= .F.
		EndIf
		RecLock("AF9",.F.)
	Else
		// tratamento para duplicidade de codigos
		dbSelectArea("AF9")
		M->AF9_PROJET := PadR(M->AF9_PROJET ,Len(AF9->AF9_PROJET))
		M->AF9_REVISA := PadR(M->AF9_REVISA ,Len(AF9->AF9_REVISA))
		M->AF9_TAREFA := PadR(M->AF9_TAREFA ,Len(AF9->AF9_TAREFA))

		If lCompUnic
			M->AF9_COMPUN := cCompUnic
		EndIf

		dbSetOrder(1)
		If MsSeek(xFilial()+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA)
			If GetNewPar("MV_PMSTCOD","1")=="2"
				nNewCod := 0
				AFC->(dbSetOrder(1))
				AFC->(MsSeek(xFilial()+M->AF9_PROJET+M->AF9_REVISA+M->AF9_EDTPAI))
				While AF9->(dbSeek(xFilial()+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA))
					nNewCod++
					M->AF9_TAREFA := PmsNumAF9(M->AF9_PROJET,M->AF9_REVISA,AFC->AFC_NIVEL,AFC->AFC_EDT,,.F.)
					If nNewCod > 30
						Final(STR0117) // "Erro de duplicidade de códigos automáticos de tarefas durante a gravação."
					EndIf
				End
			Else
				Final(STR0118)//"Erro de duplicidade de códigos manuais de tarefas durante a gravação."
			EndIf
		EndIf
		RecLock("AF9",.T.)
		AF9->AF9_PROJET := M->AF9_PROJET
		AF9->AF9_REVISA := M->AF9_REVISA
		AF9->AF9_TAREFA := M->AF9_TAREFA
		AF9->AF9_COMPUN := M->AF9_COMPUN

	EndIf
	For nx := 1 TO FCount()
		FieldPut(nx,M->&(EVAL(bCampo,nx)))
	Next nx
	AF9->AF9_FILIAL := xFilial("AF9")
	AF9->AF9_HUTEIS	:= AF9->AF9_HDURAC

	If !lCompUnic .And. AF9->(FieldPos("AF9_TPQUAN")) > 0
		AF9->AF9_TPQUAN := '2'
	EndIf

	aAreaSX3 := SX3->(GetArea())
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek("AF9_DTCONV")
		If !Empty(SX3->X3_WHEN) .AND. !&(SX3->X3_WHEN)
			AF9->AF9_DTCONV	:= stod("")
		EndIf
	EndIf
	RestArea(aAreaSX3)

	If Type(M->AF9_CODMEM) <> Nil
		cChave := M->AF9_CODMEM
	Endif
	If Empty(M->AF9_OBS) .And. lAltera
		nOpc := 2 // Deleta Campo Memo
	Else
		nOpc := 1 // Mantem funcionamento anterior
	Endif

	lEnviaEmail     := If(AF9->AF9_EMAIL == "2",.F.,.T.)
	AF9->AF9_EMAIL  := "2"
	MSMM(cChave,TamSx3("AF9_OBS")[1],,M->AF9_OBS,nOpc,,,"AF9","AF9_CODMEM")

	AF9->(MsUnlock())
	nRecAF9	:= AF9->(RecNo())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Integracao protheus X tin	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If FindFunction( "GETROTINTEG" ) .and. FindFunction("FwHasEAI") .and. FWHasEAI("PMSA203",.T.,,.T.)
		FwIntegDef( 'PMSA203' )
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona ponto de entrada para que o cliente customize o curso da tarefa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PMSXCust")
		ExecBlock("PMSXCust") // calcula o custo
		AF9->( dbgoto( nRecAF9 ) )
	EndIf

	// Se existir o folder de Produtos
	If nPosFldPRD > 0
		// grava arquivo AFA (Produtos)
		dbSelectArea("AFA")
		For nCntFor := 1 to Len(aColsSV[nPosFldPRD])
			If !aColsSV[nPosFldPRD][nCntFor][Len(aHeaderSV[nPosFldPRD])+1]
				If !Empty(aColsSV[nPosFldPRD][nCntFor][nPosProd])
					If nCntFor <= Len(aRecAFA)
						dbGoto(aRecAFA[nCntFor])
						PmsAvalAFA("AFA",2)
						RecLock("AFA",.F.)
					Else
						RecLock("AFA",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[nPosFldPRD])
						If ( aHeaderSV[nPosFldPRD][nCntFor2][10] != "V" )
							AFA->(FieldPut(FieldPos(aHeaderSV[nPosFldPRD][nCntFor2][2]),aColsSV[nPosFldPRD][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2
					AFA->AFA_FILIAL	:= xFilial("AFA")
					AFA->AFA_PROJET	:= AF9->AF9_PROJET
					AFA->AFA_REVISA	:= AF9->AF9_REVISA
					AFA->AFA_TAREFA	:= AF9->AF9_TAREFA
					MsUnlock()
					PmsAvalAFA("AFA",1)
				EndIf
			Else
				If nCntFor <= Len(aRecAFA)
					dbGoto(aRecAFA[nCntFor])
					PmsAvalAFA("AFA",2)
					PmsAvalAFA("AFA",3)
					RecLock("AFA",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
		Next nCntFor
	EndIf

	//Se existir o folder de Tributos
	If nPosFldAN9 > 0

		//Considera os registros deletados
		SET DELETED OFF

		// grava arquivo AN9 (Tributos)
		DbSelectArea("WK_AN9")
		WK_AN9->(DbGoTop())

		While WK_AN9->(!EOF())

			If !WK_AN9->(Deleted())

				SET DELETED ON

				DbSelectArea("AN9")
				DbSetOrder(1)
				If AN9->( DbSeek( WK_AN9->( xFilial("AN9")+AN9_PROJET+AN9_REVISA+AN9_TAREFA+AN9_ITEM+AN9_PRODUT+AN9_RECURS+PadR(AN9_CODIMP,3) ) ) )
					RecLock("AN9",.F.)
				Else
					RecLock("AN9",.T.)
				End If

				AN9->(AN9_FILIAL) := xFilial("AN9")
				AN9->(AN9_PROJET) := WK_AN9->(AN9_PROJET)
				AN9->(AN9_REVISA) := WK_AN9->(AN9_REVISA)
				AN9->(AN9_TAREFA) := WK_AN9->(AN9_TAREFA)
				AN9->(AN9_ITEM)   := WK_AN9->(AN9_ITEM)
				AN9->(AN9_PRODUT) := WK_AN9->(AN9_PRODUT)
				AN9->(AN9_RECURS) := WK_AN9->(AN9_RECURS)
				AN9->(AN9_CODIMP) := WK_AN9->(AN9_CODIMP)
				AN9->(AN9_PERC)   := WK_AN9->(AN9_PERC)
				AN9->(AN9_VALIMP) := WK_AN9->(AN9_VALIMP)

				MsUnlock()

				SET DELETED OFF

			Else

				SET DELETED ON

				DbSelectArea("AN9")
				DbSetOrder(1)
				If AN9->( DbSeek( WK_AN9->( xFilial("AN9")+AN9_PROJET+AN9_REVISA+AN9_TAREFA+AN9_ITEM+AN9_PRODUT+AN9_RECURS+PadR(AN9_CODIMP,3) ) ) )
					RecLock("AN9",.F.,.T.)
						AN9->(dbDelete())
					MsUnlock()
				End If

				SET DELETED OFF

			End If

			WK_AN9->(DbSkip())
		End

		//Desconsidera os registros deletados
		SET DELETED ON

	End If

	// Se existir o folder de Despesas
	If nPosFldAFB > 0
		// grava arquivo AFB (Despesas)
		dbSelectArea("AFB")
		For nCntFor := 1 to Len(aColsSV[nPosFldAFB])
			If !aColsSV[nPosFldAFB][nCntFor][Len(aHeaderSV[nPosFldAFB])+1]
				If !Empty(aColsSV[nPosFldAFB][nCntFor][nPosDescri])
					If nCntFor <= Len(aRecAFB)
						dbGoto(aRecAFB[nCntFor])
						RecLock("AFB",.F.)
					Else
						RecLock("AFB",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[nPosFldAFB])
						If ( aHeaderSV[nPosFldAFB][nCntFor2][10] != "V" )
							AFB->(FieldPut(FieldPos(aHeaderSV[nPosFldAFB][nCntFor2][2]),aColsSV[nPosFldAFB][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2
					AFB->AFB_FILIAL	:= xFilial("AFB")
					AFB->AFB_PROJET	:= AF9->AF9_PROJET
					AFB->AFB_REVISA := AF9->AF9_REVISA
					AFB->AFB_TAREFA	:= AF9->AF9_TAREFA
					MsUnlock()
				EndIf
			Else
				If nCntFor <= Len(aRecAFB)
					dbGoto(aRecAFB[nCntFor])
					RecLock("AFB",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
		Next nCntFor
	EndIf

	// Se existir o folder de Relacionamento de tarefa
	If nPosFldAFD > 0
		// grava arquivo AFD (Predecessoras)
		dbSelectArea("AFD")
		For nCntFor := 1 to Len(aColsSV[nPosFldAFD])
			If ! aColsSV[nPosFldAFD][nCntFor][Len(aHeaderSV[nPosFldAFD])+1]
				If !Empty(aColsSV[nPosFldAFD][nCntFor][nPosPrd])
					If nCntFor <= Len(aRecAFD)
						dbGoto(aRecAFD[nCntFor])
						RecLock("AFD",.F.)
					Else
						RecLock("AFD",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[nPosFldAFD])
						If ( aHeaderSV[nPosFldAFD][nCntFor2][10] != "V" )
							AFD->(FieldPut(FieldPos(aHeaderSV[nPosFldAFD][nCntFor2][2]),aColsSV[nPosFldAFD][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2
					AFD->AFD_FILIAL	:= xFilial("AFD")
					AFD->AFD_PROJET	:= AF9->AF9_PROJET
					AFD->AFD_REVISA	:= AF9->AF9_REVISA
					AFD->AFD_TAREFA	:= AF9->AF9_TAREFA
					MsUnlock()
				EndIf
			Else
				If nCntFor <= Len(aRecAFD)
					dbGoto(aRecAFD[nCntFor])
					RecLock("AFD",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
		Next nCntFor

	EndIf

	// Se existir o folder de eventos
	If nPosFldAFP > 0
		// grava arquivo AFP (Eventos Marco)
		dbSelectArea("AFP")
		For nCntFor := 1 to Len(aColsSV[nPosFldAFP])
			If !aColsSV[nPosFldAFP][nCntFor][Len(aHeaderSV[nPosFldAFP])+1]
				If !Empty(aColsSV[nPosFldAFP][nCntFor][nPosEvent])
					If nCntFor <= Len(aRecAFP)
						dbGoto(aRecAFP[nCntFor])
						PMSAvalAFP("AFP",3)
						RecLock("AFP",.F.)
					Else
						RecLock("AFP",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[nPosFldAFP])
						If ( aHeaderSV[nPosFldAFP][nCntFor2][10] != "V" )
							AFP->(FieldPut(FieldPos(aHeaderSV[nPosFldAFP][nCntFor2][2]),aColsSV[nPosFldAFP][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2
					AFP->AFP_FILIAL	:= xFilial("AFP")
					AFP->AFP_PROJET	:= AF9->AF9_PROJET
					AFP->AFP_REVISA	:= AF9->AF9_REVISA
					AFP->AFP_TAREFA := AF9->AF9_TAREFA
					MsUnlock()
				EndIf
			Else
				If nCntFor <= Len(aRecAFP)
					dbGoto(aRecAFP[nCntFor])
					PMSAvalAFP("AFP",3)
					RecLock("AFP",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
		Next nCntFor
	EndIf

	// Se existir o folder de alocacao recursos
	If nPosFldREC > 0
		// grava arquivo AFA (Recursos)
		dbSelectArea("AFA")
		For nCntFor := 1 to Len(aColsSV[nPosFldREC])
			If !aColsSV[nPosFldREC][nCntFor][Len(aHeaderSV[nPosFldREC])+1]
				If !Empty(aColsSV[nPosFldREC][nCntFor][nPosRecurs])
					AE8->(dbSetOrder(1))
					AE8->(dbSeek(xFilial("AE8")+aColsSV[nPosFldREC][nCntFor][nPosRecurs]))
					If nCntFor <= Len(aRecAFA2)
						dbGoto(aRecAFA2[nCntFor])
						PmsAvalAFA("AFA",2)
						RecLock("AFA",.F.)
					Else
						RecLock("AFA",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[nPosFldREC])
						If ( aHeaderSV[nPosFldREC][nCntFor2][10] != "V" )
							AFA->(FieldPut(FieldPos(aHeaderSV[nPosFldREC][nCntFor2][2]),aColsSV[nPosFldREC][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2

					// calcula a quantidade de horas do recurso
					AFA->AFA_FILIAL	:= xFilial("AFA")
					AFA->AFA_PROJET	:= AF9->AF9_PROJET
					AFA->AFA_REVISA	:= AF9->AF9_REVISA
					AFA->AFA_TAREFA	:= AF9->AF9_TAREFA
					AFA->AFA_START	:= AF9->AF9_START
					AFA->AFA_HORAI	:= AF9->AF9_HORAI
					AFA->AFA_FINISH	:= AF9->AF9_FINISH
					AFA->AFA_HORAF	:= AF9->AF9_HORAF
					MsUnlock()

					//
					// Existe responsavel e os campos para integração com o QNC?
					//
					// Se PMS esta integrado com QNC
					//
						If !Empty(AF9->AF9_FNC) .AND. !Empty(AF9->AF9_REVFNC) .AND. !Empty(AF9->AF9_ACAO) .AND. !Empty(AF9->AF9_REVACAO) .AND. !Empty(AF9->AF9_TPACAO)
							If lAltRec
								// Altera o responsavel da ETAPA da FNC
								QNCAltResp(/*NAO PASSAR*/ ,AF9->AF9_ACAO ,AF9->AF9_REVACAO ,AF9->AF9_TPACAO ,RDZRetEnt("AE8",xFilial("AE8")+AFA->AFA_RECURS,"QAA",,,,.F.))
							EndIf
						EndIf

					PmsAvalAFA("AFA",1)
					aAdd(aRecEmail,AFA->AFA_RECURS)
					cMens1 := AF8->AF8_PROJET + " - " + AF8->AF8_DESCRI
					cMens2 := AF9->AF9_TAREFA + " - " + AF9->AF9_DESCRI
					aAdd(aTxtEmail,{cMens1,cMens2,AFA->AFA_START,AFA->AFA_HORAI,AFA->AFA_FINISH,AFA->AFA_HORAF})
					//aAdd(aTxtEmail,{cMens1,cMens2,AFA->AFA_START,AFA->AFA_HORAI,AFA->AFA_FINISH,AFA->AFA_HORAF,AF9->AF9_OBS})
				EndIf
			Else
				If nCntFor <= Len(aRecAFA2)
					dbGoto(aRecAFA2[nCntFor])
					PmsAvalAFA("AFA",2)
					PmsAvalAFA("AFA",3)
					RecLock("AFA",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
		Next nCntFor
	EndIf

	// Se existir o folder Cronograma por periodo
	If nPosFldAFZ > 0
		// grava arquivo AFZ (Cronograma por periodo)
		dbSelectArea("AFZ")
		dbSetOrder(1)

		nTotPerc := 0
		aRecUso  := {}

		For nCntFor := 1 to Len(aHeaderSV[nPosFldAFZ])
			dCrono   := CTOD(aHeaderSV[nPosFldAFZ][nCntFor][1])
			If aColsSV[nPosFldAFZ][1][nCntFor] > 0
				nTotPerc += aColsSV[nPosFldAFZ][1][nCntFor]
				If AFZ->(MsSeek(xFilial()+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA+DTOS(dCrono)))
					aAdd(aRecUso, AFZ->(Recno()))
					RecLock("AFZ",.F.)
				Else
					RecLock("AFZ",.T.)
				EndIf
				AFZ->AFZ_FILIAL := xFilial("AFZ")
				AFZ->AFZ_PROJET	:= AF9->AF9_PROJET
				AFZ->AFZ_REVISA	:= AF9->AF9_REVISA
				AFZ->AFZ_TAREFA	:= AF9->AF9_TAREFA
				AFZ->AFZ_DATA	:= CTOD(aHeaderSV[nPosFldAFZ][nCntFor][1])
				AFZ->AFZ_PERC	:= nTotPerc
				Msunlock()
			EndIf
		Next

		For nCntFor := 1 to Len(aRecAFZ)
			If Ascan(aRecUso, aRecAFZ[nCntFor]) == 0  // se existia o registro e nao foi usado
				AFZ->(dbGoto(aRecAFZ[nCntFor]))
				RecLock("AFZ",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
		Next
	EndIf

	// Se existir o folder predecessoras EDT
	If nPosFldAJ4 > 0
		// grava arquivo AJ4 (Predecessoras EDT)
		dbSelectArea("AJ4")
		For nCntFor := 1 to Len(aColsSV[nPosFldAJ4])
			If !aColsSV[nPosFldAJ4][nCntFor][Len(aHeaderSV[nPosFldAJ4])+1]
				If !Empty(aColsSV[nPosFldAJ4][nCntFor][nPosPrd7])
					If nCntFor <= Len(aRecAJ4)
						dbGoto(aRecAJ4[nCntFor])
						RecLock("AJ4",.F.)
					Else
						RecLock("AJ4",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[nPosFldAJ4])
						If ( aHeaderSV[nPosFldAJ4][nCntFor2][10] != "V" )
							AJ4->(FieldPut(FieldPos(aHeaderSV[nPosFldAJ4][nCntFor2][2]),aColsSV[nPosFldAJ4][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2
					AJ4->AJ4_FILIAL	:= xFilial("AJ4")
					AJ4->AJ4_PROJET	:= AF9->AF9_PROJET
					AJ4->AJ4_REVISA	:= AF9->AF9_REVISA
					AJ4->AJ4_TAREFA	:= AF9->AF9_TAREFA
					MsUnlock()
				EndIf
			Else
				If nCntFor <= Len(aRecAJ4)
					dbGoto(aRecAJ4[nCntFor])
					RecLock("AJ4",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
		Next nCntFor
	EndIf

	aRecUso := {}
	nPosAEFItem := aScan(aHeadAEF1,{|x| AllTrim(x[2])=="AEF_ITEM"})
	nPosAEFProd := aScan(aHeadAEF1,{|x| AllTrim(x[2])=="AEF_PRODUT"})
	nPosAEFPerc := aScan(aHeadAEF1 ,{|x| AllTrim(x[2])=="AEF_QTD001"})

	If nPosAEFPerc >0
		For nCntCols := 1 to len(aColsAEF1)
			nTotPerc := 0
			For nCntFor := nPosAEFPerc to Len(aHeadAEF1)
				dCrono   := CTOD(aHeadAEF1[nCntFor][1])
				If aColsAEF1[nCntCols ,nCntFor] <> 0

					dbSelectArea("AEF")
					dbSetOrder(1)
					If AEF->(MsSeek(xFilial()+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA+aColsAEF1[nCntCols ,nPosAEFItem]+aColsAEF1[nCntCols ,nPosAEFProd]+SPACE(TAMSX3("AEF_RECURS")[1])+DTOS(dCrono)))
						aAdd(aRecUso, AEF->(Recno()))
						RecLock("AEF",.F.)
					Else
						RecLock("AEF",.T.)
					EndIf
					AEF->AEF_FILIAL := xFilial("AEF")
					AEF->AEF_PROJET	:= AF9->AF9_PROJET
					AEF->AEF_REVISA	:= AF9->AF9_REVISA
					AEF->AEF_TAREFA	:= AF9->AF9_TAREFA
					AEF->AEF_ITEM	:= aColsAEF1[nCntCols ,nPosAEFItem]
					AEF->AEF_PRODUT := aColsAEF1[nCntCols ,nPosAEFProd]
					AEF->AEF_DATREF := CTOD(aHeadAEF1[nCntFor][1])
					AEF->AEF_QUANT	:= aColsAEF1[nCntCols ,nCntFor]
					Msunlock()
				EndIf
			Next nCntFor
		Next nCntCols

		For nCntFor := 1 to Len(aRecAEF1)
			If aScan(aRecUso, aRecAEF1[nCntFor]) == 0  // se existia o registro e nao foi usado
				AEF->(dbGoto(aRecAEF1[nCntFor]))
				RecLock("AEF",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
		Next nCntFor
	EndIf

	aRecUso := {}
	nPosAEFItem := aScan(aHeadAEF2,{|x| AllTrim(x[2])=="AEF_ITEM"})
	nPosAEFRec  := aScan(aHeadAEF2,{|x| AllTrim(x[2])=="AEF_RECURS"})
	nPosAEFPerc := aScan(aHeadAEF2 ,{|x| AllTrim(x[2])=="AEF_QTD001"})
	If nPosAEFPerc >0
		For nCntCols := 1 to len(aColsAEF2)
			nTotPerc := 0
			For nCntFor := nPosAEFPerc to Len(aHeadAEF2)
				dCrono   := CTOD(aHeadAEF2[nCntFor][1])
				If aColsAEF2[nCntCols ,nCntFor] <> 0
					dbSelectArea("AEF")
					dbSetOrder(2)
					If AEF->(MsSeek(xFilial()+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA+aColsAEF2[nCntCols ,nPosAEFItem]+aColsAEF2[nCntCols ,nPosAEFRec]+space(tamSx3("AEF_PRODUT")[1])+DTOS(dCrono)))
						aAdd(aRecUso, AEF->(Recno()))
						RecLock("AEF",.F.)
					Else
						RecLock("AEF",.T.)
					EndIf
					AEF->AEF_FILIAL := xFilial("AEF")
					AEF->AEF_PROJET	:= AF9->AF9_PROJET
					AEF->AEF_REVISA	:= AF9->AF9_REVISA
					AEF->AEF_TAREFA	:= AF9->AF9_TAREFA
					AEF->AEF_ITEM	:= aColsAEF2[nCntCols ,nPosAEFItem]
					AEF->AEF_RECURS := aColsAEF2[nCntCols ,nPosAEFRec]
					AEF->AEF_DATREF := CTOD(aHeadAEF2[nCntFor][1])
					AEF->AEF_QUANT	:= aColsAEF2[nCntCols ,nCntFor]
					Msunlock()
				EndIf
			Next nCntFor
		Next nCntCols

		For nCntFor := 1 to Len(aRecAEF2)
			If aScan(aRecUso, aRecAEF2[nCntFor]) == 0  // se existia o registro e nao foi usado
				AEF->(dbGoto(aRecAEF2[nCntFor]))
				RecLock("AEF",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
		Next nCntFor

	EndIf


	// Se existir o folder de Insumos
	If nPosFldINS > 0
		// grava arquivo AEL (Insumos)
		dbSelectArea("AEL")
		For nCntFor := 1 to Len(aColsSV[nPosFldINS])
			If !aColsSV[nPosFldINS][nCntFor][Len(aHeaderSV[nPosFldINS])+1]
				If !Empty(aColsSV[nPosFldINS][nCntFor][nPosInsumo])
					If nCntFor <= Len(aRecAEL)
						dbGoto(aRecAEL[nCntFor])
						PmsAvalAEL(,,aColsSV[nPosFldINS][nCntFor][nPosInsumo],2)
						RecLock("AEL",.F.)
					Else
						RecLock("AEL",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[nPosFldINS])
						If ( aHeaderSV[nPosFldINS][nCntFor2][10] != "V" )
							AEL->(FieldPut(FieldPos(aHeaderSV[nPosFldINS][nCntFor2][2]),aColsSV[nPosFldINS][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2
					AEL->AEL_FILIAL	:= xFilial("AEL")
					AEL->AEL_PROJET	:= AF9->AF9_PROJET
					AEL->AEL_REVISA := AF9->AF9_REVISA
					AEL->AEL_TAREFA	:= AF9->AF9_TAREFA
					MsUnlock()
					PmsAvalAEL(,,AEL->AEL_INSUMO, 1)
				EndIf
			Else
				If nCntFor <= Len(aRecAEL)
					dbSelectArea("AEL")
					AEL->(dbGoTop())
					AEL->( dbGoto(aRecAEL[nCntFor]) )
					PmsAvalAEL(,,aColsSV[nPosFldINS][nCntFor][nPosInsumo], 3)
					AEL->( dbGoto(aRecAEL[nCntFor]) )
					RecLock("AEL",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf

				// Verifica e exclui o insumo se nao estiver sendo usado no
				// projeto ou em alguma estrutura
				If !PA204UsaInsumo( AF9->AF9_PROJET, AF9->AF9_REVISA, aColsSV[nPosFldINS][nCntFor][nPosInsumo], .F. )
					PA204Exc( AF9->AF9_PROJET, AF9->AF9_REVISA, aColsSV[nPosFldINS][nCntFor][nPosInsumo], .T. )
				EndIf
			EndIf
		Next nCntFor
	EndIf

	// Se existir o folder de Subcomposicoes
	If nPosFldSUB > 0
		// grava arquivo AEN (Subcomposicoes)
		dbSelectArea("AEN")
		For nCntFor := 1 to Len(aColsSV[nPosFldSUB])
			If !aColsSV[nPosFldSUB][nCntFor][Len(aHeaderSV[nPosFldSUB])+1]
				If !Empty(aColsSV[nPosFldSUB][nCntFor][nPosSubcom])
					If nCntFor <= Len(aRecAEN)
						dbGoto(aRecAEN[nCntFor])
						PmsAvalAEN(aColsSV[nPosFldSUB][nCntFor][nPosSubcom], 2)
						RecLock("AEN",.F.)
					Else
						RecLock("AEN",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[nPosFldSUB])
						If ( aHeaderSV[nPosFldSUB][nCntFor2][10] != "V" )
							AEN->(FieldPut(FieldPos(aHeaderSV[nPosFldSUB][nCntFor2][2]),aColsSV[nPosFldSUB][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2
					AEN->AEN_FILIAL	:= xFilial("AEN")
					AEN->AEN_PROJET	:= AF9->AF9_PROJET
					AEN->AEN_REVISA := AF9->AF9_REVISA
					AEN->AEN_TAREFA	:= AF9->AF9_TAREFA
					MsUnlock()
					PmsAvalAEN(AEN->AEN_SUBCOM, 1)
				EndIf
			Else
				If nCntFor <= Len(aRecAEN)
					dbGoto(aRecAEN[nCntFor])
					PmsAvalAEN(aColsSV[nPosFldSUB][nCntFor][nPosSubcom], 3)
					RecLock("AEN",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf

				If PMSA205Del( aColsSV[nPosFldSUB][nCntFor][nPosSubcom], AF9->AF9_PROJET, AF9->AF9_REVISA, .F. )
					DbSelectArea( "AJT" )
					AJT->( DbSetOrder( 2 ) )
					If AJT->( DbSeek( xFilial( "AJT" ) + AF9->AF9_PROJET + AF9->AF9_REVISA + aColsSV[nPosFldSUB][nCntFor][nPosSubcom] ) )
						a205Grava( .T., AJT->( RecNo() ), AF9->AF9_PROJET, AF9->AF9_REVISA, aColsSV[nPosFldSUB][nCntFor][nPosSubcom] )
					EndIf
				EndIf
			EndIf
		Next nCntFor
	EndIf

	// Se existir check list
	lOk := .T.
	If Empty(M->AF9_DTATUI)

		dbSelectArea("AJO")
		aAJOArea := AJO->(GetArea())
		dbSetOrder(1)
		AJO->(MsSeek(xFilial("AJO")+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA))
		Do While !AJO->(Eof()) .And. AJO->(AJO_FILIAL+AJO_PROJET+AJO_REVISA+AJO_TAREFA)==xFilial("AJO")+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA
			If !Empty(AJO->AJO_INI)
				lOk := .f.
				Exit
			EndIf
			AJO->(dbSkip())
		EndDo
		RestArea(aAJOArea)
	Else
		lOk := .f.

	EndIf

	If lOk
		SIMFCHKCAL(1, AF9->(Recno()), .T. , " [Projeto: "+ALLTRIM(AF9->AF9_PROJET)+" Tarefa: "+ALLTRIM(AF9->AF9_TAREFA)+"] "+ALLTRIM(AF9->AF9_DESCRI)  )
	EndIf


  	PmsAvalTrf("AF9",1,,lAtuCron,.T.,,aSimDados, aSimEDT)


	If ExistBlock("PMA203GRV")
		ExecBlock("PMA203GRV",.F.,.F.)
	EndIf

	If ExistTemplate("CCT203GRV")
		ExistTemplate("CCT203GRV",.F.,.F.)
	EndIf

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Integracao protheus X tin	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If FindFunction( "GETROTINTEG" ) .and. FindFunction("FwHasEAI") .and. FWHasEAI("PMSA203",.T.,,.T.)
		FwIntegDef( 'PMSA203' )
	Endif
	MaDelAF9(,,,nRecAF9)
EndIf

If lEnviaEmail .And. !Empty(aRecEmail)
	
	If lRelauth
		//Valida se a porta foi informada no endereço	
		If AT(":",cMailServer) == 0
			cMailServer := cMailServer + ":" + cValToChar(nSMTPPort)
		EndIf

		nUser := AT("@",cMailConta)
		cUser := Left( cMailConta, nUser - 1 )

	EndIf
	
	For nCntMail := 1 to Len(aRecEmail)
		lOk := .F.
		dbSelectArea("AE8")
		dbSetOrder(1)
		If dbSeek(xFilial("AE8")+aRecEmail[nCntMail])
			cMailDest   := AE8->AE8_EMAIL
			If !EMPTY(cMailDest)

				cMensagem := '<html><head><title>Recurso</title></head>'
				cAssunto  := STR0059

				If (lPMA203Ass)
					cRet := ExecBlock("PMA203Ass",.F.,.F.,{cMailDest,cAssunto})
					IIf(Valtype(cRet)=="C",cAssunto := cRet, )
				EndIf

				If (lPMA203Msg)
					cRet := ExecBlock("PMA203Msg",.F.,.F.,{cMailDest,cMensagem})
					IIf(Valtype(cRet)=="C",cMensagem := cRet, )
				EndIf

				cMensagem += '<body><center><table border="0"><tr><td colspan="2"><center><h3>' + STR0058 + '</h3></center></td></tr>'
				For nCntLin := 1 to 6
					If nCntLin == 3 .Or. nCntLin = 5
						cMensagem += '<tr><td colspan="2"><hr width="100%"></td></tr>'
					EndIf
					cMensagem += '<tr>'
					cMensagem += '<td><b>' + HTMLEnc(aCabEmail[nCntLin]) + '</b></td>'
					If nCntLin == 3 .Or. nCntLin = 5
						cMensagem += '<td>' + HTMLEnc(DTOC(aTxtEmail[nCntMail][nCntLin])) + '</td>'
					Else
						cMensagem += '<td>' + HTMLEnc(aTxtEmail[nCntMail][nCntLin]) + '</td>'
					EndIf
					cMensagem += '</tr>'
				Next
				cMensagem += '<tr><td colspan="2"><hr width="100%"></td></tr>'
				cMensagem += '<tr><td valign="top"><b>'+STR0064+'<b></td>'
				cMensagem += '<td colspan="2">'
				cMensagem += HTMLEnc(MSMM(AF9->AF9_CODMEM,TamSX3("AF9_OBS")[1],,,3,,,"AF9", "AF9_CODMEM"))
				cMensagem += '</td></tr>'
				cMensagem += '</table></center></body></html>'

				// o CONNECT e obrigatorio para poder executar
				// os commandos seguintes de envio e erro
				// SEND e GET

				CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk

				If lOk
					If lRelauth
						lOk := MailAuth(cMailConta, cMailSenha) 
					EndIf				
					If !lOk
						lOk := MailAuth(cUser, cMailSenha) 
					EndIf
				EndIf
				//EndIf
				//EndIf
				If lOk
					SEND MAIL FROM cMailConta TO AllTrim(cMailDest) SUBJECT cAssunto BODY cMensagem RESULT lSendOk
					If !lSendOk
						GET MAIL ERROR cError
						Aviso(STR0060,cError,{STR0061},2) //"Erro no envio do e-Mail"###"Fechar"
					EndIf
				Else
					GET MAIL ERROR cError
					Aviso(STR0060,cError,{STR0061},2) //"Erro no envio do e-Mail"###"Fechar"
				EndIf
				If lOk
					DISCONNECT SMTP SERVER
				EndIf
			EndIf
		EndIf
	Next
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203SVCols ³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Manipula os acols do Projeto.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA203                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203SVCols(aHeaderSV,aColsSV,aSavN,nGetDados)

If nGetDados <= Len(aHeaderSV) .And. !Empty(aHeaderSV[nGetDados])

	// salva o conteudo da GetDados se existir
	aColsSV[nGetDados]		:= aClone(aCols)
	aHeaderSV[nGetDados]	:= aClone(aHeader)
	aSavN[nGetDados]		:= n

	aCols			:= aColsSV[nGetDados]
	aHeader			:= aHeaderSV[nGetDados]
	n      			:= aSavN[nGetDados]
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AGDTudOk³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao auxiliar utilizada pela EnchoiceBar para executar a   ³±±
±±³          ³ TudOk da GetDados                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Validacao TudOk da Getdados                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AGDTudok(aSavN,aColsSV,aHeaderSV,nGetDados,oGD)
Local aSavCols		:= aClone(aCols)
Local aSavHeader	:= aClone(aHeader)
Local nSavN			:= n
Local lRet        := .T.

Eval(oFolder:bSetOption)
oGD[nGetDados]:oBrowse:lDisablePaint := .F.

aCols	:= aClone(aColsSV[nGetDados])
aHeader	:= aClone(aHeaderSV[nGetDados])
n		:= aSavN[nGetDados]
oFolder:nOption	:= nGetDados

If !isAuto()
	oGD[nGetDados]:Hide()
	oFolder:Hide()
EndIf

Do Case
	Case nGetDados == FolderOrd(STR0039) // Produtos
		lRet := A203GD1Tudok()
	Case nGetDados == FolderOrd(STR0009) // Despesas
		lRet := A203GD2Tudok()
	Case nGetDados == FolderOrd(STR0062) // Relacionamento de tarefas
		lRet := A203GD3Tudok()
	Case nGetDados == FolderOrd(STR0038) // Eventos
		lRet := A203GD4Tudok()
	Case nGetDados == FolderOrd(STR0040) // Alocacao de recursos
		lRet := A203GD5Tudok()
	Case nGetDados == FolderOrd(STR0063) // Relacionamento de EDT
		lRet := A203GD7Tudok()
	Case nGetDados == FolderOrd(STR0129) // Insumos
		lRet := A203InsTudok()
	Case nGetDados == FolderOrd(STR0130) // Sub-Composicoes
		lRet := A203SubTudok()
EndCase


aColsSV[nGetDados]		:= aClone(aCols)
aHeaderSV[nGetDados]	:= aClone(aHeader)

If nGetDados != oFolder:nOption
	aCols	:= aClone(aSavCols)
	aHeader	:= aClone(aSavHeader)
	n		:= nSavN
EndIf

If !isAuto()
	oFolder:Show()
	oGD[nGetDados]:Show()
	oGD[nGetDados]:ForceRefresh()
Endif

If ExistBlock("PM203Mail")
	ExecBlock("PM203Mail",.F.,.F.)
Endif

//If !PmsVldCom()
  //	lRet:= .F.
//EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSA203Eof³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de Filtro utiliada na consulta SXB e no Browse das    ³±±
±±³          ³ tarefas do Projeto                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SXB, PMSA203                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA203Trf()
Local aArea		:= GetArea()
Local aAreaAF9		:= AF9->(GetArea())
Local aAJOArea		:= {}
Local nRecAF9	:= PMSA203(3,,M->AF9_NIVEL)
Local nPosSubTrf:= aScan(aHeader,{|x| AllTrim(x[2])=="AFC_SUBTRF"})
Local nPosDescri:= aScan(aHeader,{|x| AllTrim(x[2])=="AFC_DESCRI"})
Local nPosQuant := aScan(aHeader,{|x| AllTrim(x[2])=="AFC_QUANT"})

If nRecAF9 <> Nil
	AF9->(dbGoto(nRecAF9))
	aCols[n][nPosSubTrf]	:= AF9->AF9_TAREFA
	aCols[n][nPosDescri]	:= AF9->AF9_DESCRI
	aCols[n][nPosQuant]		:= AF9->AF9_QUANT
EndIf

If !Empty(M->AF9_DTATUI)
	lRO := .T.
EndIf

If !lRO
	dbSelectArea("AJO")
	aAJOArea := AJO->(GetArea())
	dbSetOrder(1)
	AJO->(MsSeek(xFilial("AJO")+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA))
	Do While !lRO .And. !AJO->(Eof()) .And. AJO->(AJO_FILIAL+AJO_PROJET+AJO_REVISA+AJO_TAREFA)==xFilial("AJO")+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA
		If !Empty(AJO->AJO_INI)
			lRO:=.T.
		EndIf
		AJO->(dbSkip())
	EndDo
	RestArea(aAJOArea)
EndIf
RestArea(aAreaAF9)
RestArea(aArea)
Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS203VCAL³ Autor ³ Edson Maricate        ³ Data ³ 18-05-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao do Calendario utilizado na tarefa.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA203.                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS203VCAL()
Local nx 		:= 0
Local aAuxRet	:= {}
Local lPredec	:= .F.
Local aArea		:= GetArea()
Local nPosPred	:= 0
Local nPos 		:= 0
Local nPosFldAFD := FolderOrd(STR0062)//'Relac.Tarefas'

If nPosFldAFD >0

	If (ReadVar() == "M->AFC_CALEND")
		Return(PMS201VCAL())
	EndIf

	nPosPred:= aScan(aHeaderSV[nPosFldAFD],{|x| AllTrim(x[2])=="AFD_PREDEC"})
	For nx := 1 to Len(aColsSV[nPosFldAFD])
		If !aColsSV[nPosFldAFD][nx][Len(aColsSV[nPosFldAFD][nx])] .And. nposPred > 0 .And.!Empty(aColsSV[nPosFldAFD][nx][nposPred])
			lPredec := .T.
			Exit
		EndIf
	Next

EndIf

If lPredec
	PMS203PRED(.F.)
Else
	aAuxRet	:= PMSDTaskF(M->AF9_START,M->AF9_HORAI,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
	M->AF9_START := aAuxRet[1]
	M->AF9_HORAI := aAuxRet[2]
	M->AF9_FINISH:= aAuxRet[3]
	M->AF9_HORAF := aAuxRet[4]
EndIf


RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS203DHRS³ Autor ³ Edson Maricate        ³ Data ³ 18-05-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao e calculos na validacao da duracao da tarefa.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA203.                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS203DHRS(lCalcEsf)
Local nx
Local aAuxRet	 := {}
Local lRet		 := .T.
Local aArea		 := GetArea()
Local lPredec	 := .F.
Local nPosPred	 := 0
Local nPosRec	 := 0
Local nPosQuant	 := 0
Local nPosAloc	 := 0
Local nPosFix 	 := 0
Local nTitFolder := 0
Local aTitFolder := 0
Local nPosFldREC := FolderOrd(STR0040)//'Aloc. Recursos'
Local nPosFldAFD := FolderOrd(STR0062)//'Relac.Tarefas'
Local lContinua  := .T.
Local nOpcFolder := Iif(Type("oFolder")="O",oFolder:nOption,1)
Local aOrigDts   := 	{M->AF9_START,	M->AF9_HORAI ,	M->AF9_FINISH , M->AF9_HORAF }
DEFAULT lCalcEsf := .T.

If (nPosFldAFD >0)
	nPosPred	:= aScan(aHeaderSV[nPosFldAFD],{|x| AllTrim(x[2])=="AFD_PREDEC"})

	If nPosPred > 0
		For nx := 1 to Len(aColsSV[nPosFldAFD])
			If !aColsSV[nPosFldAFD][nx][Len(aColsSV[nPosFldAFD][nx])].And.!Empty(aColsSV[nPosFldAFD][nx][nposPred])
				lPredec := .T.
				Exit
			EndIf
		Next
	EndIf

Endif

If (nPosFldREC >0) .AND. lCalcEsf

	IF oFolder:nOption <> nPosFldREC
		oFolder:SetOption(nPosFldREC)
		nOpcFolder := Iif(Type("oFolder")="O",oFolder:nOption,1)
	EndIf

	lContinua := .F.
	// se for tipo 1 - Duração fixa e com agendamento
	If (M->AF9_TPTRF=="1")
		FWMsgRun(,{|| PMSEsfDur(M->AF9_TPTRF)},STR0191,STR0192) //"Aguarde" # "Realizando o cálculo de duração."
	EndIf
	// Se for Tipo 2 - Trabalho fixo
	If (M->AF9_TPTRF=="2") .and. (nOpcFolder == nPosFldREC) .and. ( LenVal(aCols)>0 )
		// recalcula o % (afa_aloc) baseada na nova duração
		FWMsgRun(,{|| PMSEsfDur(M->AF9_TPTRF)},STR0191,STR0193) //"Aguarde" # "Calculando a alocação baseada na duração."
	EndIf
	// Se for Tipo 3 - unidade fixa
	If M->AF9_TPTRF=="3"
		// recalcula a quantidade (afa_quant) baseada na nova duração
		FWMsgRun(,{|| PMSEsfDur(M->AF9_TPTRF)},STR0191,STR0194) //"Aguarde" # "Calculando a quantidade baseada na duração."
	EndIf
EndIf

If lPredec
	PMS203PRED(.F.)
Else
	If Empty(M->AF9_START) .or. !lContinua
		aAuxRet	:= PMSDTaskF(M->AF9_START,M->AF9_HORAI,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
		M->AF9_START := aAuxRet[1]
		M->AF9_HORAI := aAuxRet[2]
		M->AF9_FINISH:= aAuxRet[3]
		M->AF9_HORAF := aAuxRet[4]
		Pms203Msg(STR0011) //"A data final prevista foi recalculada de acordo com o calendario e a duracao da tarefa."
	EndIf
EndIf

If !(lRet:=PA203ResPer(aOrigDts))
	Return lRet
EndIf
If (nPosFldREC >0) .and. lContinua
	nPosRec	    := aScan(aHeaderSV[nPosFldREC],{|x| AllTrim(x[2])=="AFA_RECURS"})
	nPosQuant   := aScan(aHeaderSV[nPosFldREC],{|x| AllTrim(x[2])=="AFA_QUANT"})
	nPosAloc	:= aScan(aHeaderSV[nPosFldREC],{|x| AllTrim(x[2])=="AFA_ALOC"})
	nPosFix 	:= aScan(aHeaderSV[nPosFldREC],{|x| AllTrim(x[2])=="AFA_FIX"})

	If nPosRec > 0 .and. nPosQuant > 0 .and. nPosAloc > 0 .and. nPosFix > 0
		For nx := 1 to Len(aColsSV[nPosFldREC])
			If !aColsSV[nPosFldREC][nx][Len(aColsSV[nPosFldREC][nx])].And.!Empty(aColsSV[nPosFldREC][nx][nPosRec])
				AE8->(dbSetOrder(1))
				AE8->(dbSeek(xFilial()+aColsSV[nPosFldREC][nx][nPosRec]))
				If aColsSV[nPosFldREC][nx][nPosFix] == "1"
					If aColsSV[nPosFldREC][nx][nPosAloc]>0
						aColsSV[nPosFldREC][nx][nPosQuant]	:= (aColsSV[nPosFldREC][nx][nPosAloc]*PmsHrsItvl(M->AF9_START,M->AF9_HORAI,M->AF9_FINISH,M->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,M->AF9_CALEND),M->AF9_PROJET,AE8->AE8_RECURS))/100
					EndIf
				Else
					If aColsSV[nPosFldREC][nx][nPosQuant]>0
						aColsSV[nPosFldREC][nx][nPosAloc]	:= (aColsSV[nPosFldREC][nx][nPosQuant]/M->AF9_HDURAC)*100
					EndIf
				Endif
			EndIf
		Next nX

	EndIf
Endif
RestArea(aArea)

P203SomaEsf()


Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS203DINI³ Autor ³ Edson Maricate        ³ Data ³ 18-05-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de calculo da Data Final Prevista da tarefa.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ATENCAO!!!³Esta tambem e utilizada no modo automatico pela funcao        ³±±
±±³          ³A203GD6FieldOk e devera ser testada na getdados 6 sempre que  ³±±
±±³          ³for alterada.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA203.                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS203DINI(lMsg)

Local nx
Local lRet		:= .T.
//Local lPredec	:= .F.
Local aAuxRet	:= {}
Local aAuxPred	:= {}
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local nPosPred	:= 0
Local nPosTipo	:= 0
Local nPosHRetar:= 0
Local nPosFldAFD := FolderOrd(STR0062) //'Relac.Tarefas'
Local cTrfIni  := DtoS(M->AF9_START)
Local cPrjIni  := DtoS(AF8->AF8_START)

DEFAULT lMsg := .T.

If isauto() // Rotina automatica
	lMsg := .F.
Endif

//VALIDA SE A DATA INICIAL IRÁ SER MENOR QUE O INICIO DO PROJETO
If cTrfIni<cPrjIni
	If isauto() // Rotina automatica
		aAuxRet	:= PMSDTaskF(M->AF9_START,M->AF9_HORAI,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
		M->AF9_DTREST := M->AF9_START
		M->AF9_HRREST := M->AF9_HORAI
	Else
		If lRet:= Aviso(STR0135,STR0136,{STR0086,STR0087},2) ==1// Inicio do projeto //"Esta data e hora da tarefa fará com que o projeto seja iniciado mais cedo. Deseja Continuar?"
			aAuxRet	:= PMSDTaskF(M->AF9_START,M->AF9_HORAI,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
			M->AF9_DTREST := M->AF9_START
			M->AF9_HRREST := M->AF9_HORAI
		EndIf
	EndIf
else
	aAuxRet	:= PMSDTaskF(M->AF9_START,M->AF9_HORAI,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
Endif

If nPosFldAFD>0 .AND. lRet
	nPosPred	:= aScan(aHeaderSV[nPosFldAFD],{|x| AllTrim(x[2])=="AFD_PREDEC"})
	nPosTipo	:= aScan(aHeaderSV[nPosFldAFD],{|x| AllTrim(x[2])=="AFD_TIPO"})
	nPosHRetar:= aScan(aHeaderSV[nPosFldAFD],{|x| AllTrim(x[2])=="AFD_HRETAR"})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida os relacionamentos                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nx := 1 to Len(aColsSV[nPosFldAFD])
		If !aColsSV[nPosFldAFD][nx][Len(aColsSV[nPosFldAFD][nx])].And.! Empty(aColsSV[nPosFldAFD][nx][nposPred])
			AF9->(dbSetOrder(1))
			AF9->(dbSeek(xFilial()+M->AF9_PROJET+M->AF9_REVISA+aColsSV[nPosFldAFD][nx][nposPred]))
			Do Case
				Case aColsSV[nPosFldAFD][nx][nPosTipo] == "1"
					aAuxPred:= PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,aColsSV[nPosFldAFD][nx][nPosHRetar],AF9->AF9_PROJET,Nil)
					If aAuxRet[1] < aAuxPred[1] .Or.(aAuxRet[1] == aAuxPred[1] .And. aAuxRet[2] < aAuxPred[2])
						If lMsg
							Pms203Msg(STR0012,CLR_HRED) //"Data Inicial invalida. Verifique os relacionamentos da Tarefa."
						EndIf
						lRet := .F.
						Exit
					EndIf
				Case aColsSV[nPosFldAFD][nx][nPosTipo] == "2"
					aAuxPred:= PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,aColsSV[nPosFldAFD][nx][nPosHRetar],AF9->AF9_PROJET,Nil)
					If aAuxRet[1] < aAuxPred[1] .Or. (aAuxRet[1] == aAuxPred[1] .And. aAuxRet[2] < aAuxPred[2])
						If lMsg
							Pms203Msg(STR0012,CLR_HRED) //"Data Inicial invalida. Verifique os relacionamentos da Tarefa."
						EndIf
						lRet := .F.
						Exit
					EndIf
				Case aColsSV[nPosFldAFD][nx][nPosTipo] == "3"
					aAuxPred:= PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,aColsSV[nPosFldAFD][nx][nPosHRetar],AF9->AF9_PROJET,Nil)
					If aAuxRet[3] < aAuxPred[1] .Or. (aAuxRet[3] == aAuxPred[1] .And. aAuxRet[4] < aAuxPred[2])
						If lMsg
							Pms203Msg(STR0013,CLR_HRED) //"Data Final invalida. Verifique os relacionamentos da Tarefa."
						EndIf
						lRet := .F.
						Exit
					EndIf
				Case aColsSV[nPosFldAFD][nx][nPosTipo] == "4"
					aAuxPred:= PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,aColsSV[nPosFldAFD][nx][nPosHRetar],AF9->AF9_PROJET,Nil)
					If aAuxRet[3] < aAuxPred[1] .Or.(aAuxRet[3] == aAuxPred[1] .And. aAuxRet[4] < aAuxPred[2])
						If lMsg
							Pms203Msg(STR0013,CLR_HRED) //"Data Final invalida. Verifique os relacionamentos da Tarefa."
						EndIf
						lRet := .F.
						Exit
					EndIf
			EndCase
		EndIf
	Next
EndIf

If lRet
	M->AF9_START := aAuxRet[1]
	M->AF9_HORAI := aAuxRet[2]
	M->AF9_FINISH:= aAuxRet[3]
	M->AF9_HORAF := aAuxRet[4]
	If lMsg
		Pms203Msg(STR0011) //"A data final prevista foi recalculada de acordo com o calendario e a duracao da tarefa."
	EndIf
EndIf

RestArea(aAreaAF9)
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS203DFIM³ Autor ³ Edson Maricate        ³ Data ³ 18-05-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da Data Final Prevista da Tarefa.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ATENCAO!!!³Esta tambem e utilizada no modo automatico pela funcao        ³±±
±±³          ³A203GD6FieldOk e devera ser testada na getdados 6 sempre que  ³±±
±±³          ³for alterada.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA203                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS203DFIM(lAviso,nOpc)

Local nx
Local lRet			:= .T.
Local nDuracao		:= M->AF9_HDURAC
Local aAuxRet		:= {}
Local aAuxPred		:= {}
Local aArea			:= GetArea()
Local dStart		:= M->AF9_START
Local cHoraIni		:= M->AF9_HORAI
Local dFinish		:= M->AF9_FINISH
Local cHoraFim		:= M->AF9_HORAF
Local cCalend		:= M->AF9_CALEND
Local cAloc			:= ""
Local nPosPred		:= 0
Local nPosTipo		:= 0
Local nPosHRetar	:= 0
Local nPosRec		:= 0
Local nPosQuant		:= 0
Local nPosAloc		:= 5
Local nPosFix		:= 0
Local nPosFldREC	:= FolderOrd(STR0040)//'Aloc. Recursos'
Local nPosFldAFD	:= FolderOrd(STR0062)//'Relac.Tarefas'
Local cTrfIni		:= ""
Local cTrfFim		:= ""
Local cPrjIni		:= DtoS(AF8->AF8_START)
Local cPrjFim		:= DtoS(AF8->AF8_FINISH)
Local nDayWeek		:= 0
Local cAlocDay		:= ""
Local lNewCalend	:= SuperGetMv("MV_PMSCALE" , .T. , .F. )
Local cProjeto		:= M->AF9_PROJET

DEFAULT lAviso		:= .T.
Default nOpc		:= 2

//Carrega a última hora possivel de apontamento no dia fim
If ReadVar() == "M->AF9_FINISH" .AND. dStart != dFinish
	If lNewCalend .and. __lTopConn
		cHoraFim := PMSDtFim(dStart,cHoraIni,cCalend,nDuracao)[4]
	Else
		// Verifica a existencia do calendario informado.
		dbSelectArea("SH7")
		If MsSeek(xFilial("SH7")+cCalend)
			cAloc    := Upper(SH7->H7_ALOC)
			nTamanho := Len(cAloc) / 7
			
			//Verifica a data/hora real de inicio
			nDayWeek := DOW(dFinish)
			nDayWeek := If(nDayWeek==1,7,nDayWeek-1)

			cAlocDay := Substr(cAloc,(nTamanho*(nDayWeek-1))+1,nTamanho)
			cAlocDay := PmsChkExc(dStart,M->AF9_PROJET,Nil,cAlocDay)
			
			cHoraFim := Substr(Bit2Tempo(RAT("X",Substr(cAlocDay,1,Len(cAlocDay)-1))),3,5)
		EndIf		
	EndIf
EndIf

If lAviso .And. !IsAuto()
	nOpc := Aviso(STR0014,STR0015,{STR0016,STR0017,STR0018}) //"Atencao"###"Houveram alteracoes na data prevista para a finalizacao da Tarefa. Voce podera escolher entre recalcular a duracao da Tarefa ou conservar a duracao informada e recalcular a Data Inicial Prevista da Tarefa."###"Cancelar"###"Duracao"###"Data Inicial"
EndIf

Do Case
	Case nOpc == 2
		If dStart==dFinish
			nDuracao := PmsHrUtil(dStart,"00"+cHoraIni,"00"+cHoraFim,M->AF9_CALEND)
		Else
			nDuracao := 0
			nDuracao += PmsHrUtil(dStart,"00"+cHoraIni,"0024:00",M->AF9_CALEND)
			dStart++
			While dStart <= dFinish
				If dStart==dFinish
					nDuracao += PmsHrUtil(dStart,"0000:00","00"+cHoraFim,M->AF9_CALEND)
				Else
					nDuracao += PmsHrUtil(dStart,"0000:00","0024:00",M->AF9_CALEND)
				EndIf
				dStart++
			End
		EndIf
		M->AF9_HDURAC := nDuracao

		// se a duração resultante for igual a zero, desconsiderar
		// o recálculo das datas previstas.
		If nDuracao == 0
			aAuxRet := {M->AF9_START, M->AF9_HORAI, M->AF9_FINISH, M->AF9_HORAF}
		Else
			aAuxRet	:= PMSDTaskI(M->AF9_FINISH,M->AF9_HORAF,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
		EndIf
	Case nOpc == 3
		aAuxRet	:= PMSDTaskI(M->AF9_FINISH,M->AF9_HORAF,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
	OtherWise
		lRet := .F.
EndCase

// valida os relacionamentos
If lRet

	If nPosFldAFD > 0
		nPosPred	:= aScan(aHeaderSV[nPosFldAFD],{|x| AllTrim(x[2])=="AFD_PREDEC"})
		nPosTipo	:= aScan(aHeaderSV[nPosFldAFD],{|x| AllTrim(x[2])=="AFD_TIPO"})
		nPosHRetar:= aScan(aHeaderSV[nPosFldAFD],{|x| AllTrim(x[2])=="AFD_HRETAR"})

		For nx := 1 to Len(aColsSV[nPosFldAFD])
			If !aColsSV[nPosFldAFD][nx][Len(aColsSV[nPosFldAFD][nx])].And.!Empty(aColsSV[nPosFldAFD][nx][nposPred])
				AF9->(dbSetOrder(1))
				AF9->(dbSeek(xFilial()+M->AF9_PROJET+M->AF9_REVISA+aColsSV[nPosFldAFD][nx][nposPred]))
				Do Case
					Case aColsSV[nPosFldAFD][nx][nPosTipo] == "1"
						aAuxPred:= PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,aColsSV[nPosFldAFD][nx][nPosHRetar],AF9->AF9_PROJET,Nil)
						If aAuxRet[1] < aAuxPred[1] .Or.(aAuxRet[1] == aAuxPred[1] .And. aAuxRet[2] < aAuxPred[2])
							Pms203Msg(STR0012,CLR_HRED) //"Data Inicial invalida. Verifique os relacionamentos da Tarefa."
							lRet := .F.
							Exit
						EndIf
					Case aColsSV[nPosFldAFD][nx][nPosTipo] == "2"
						aAuxPred:= PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,aColsSV[nPosFldAFD][nx][nPosHRetar],AF9->AF9_PROJET,Nil)
						If aAuxRet[1] < aAuxPred[1] .Or. (aAuxRet[1] == aAuxPred[1] .And. aAuxRet[2] < aAuxPred[2])
							Pms203Msg(STR0012,CLR_HRED) //"Data Inicial invalida. Verifique os relacionamentos da Tarefa."
							lRet := .F.
							Exit
						EndIf
					Case aColsSV[nPosFldAFD][nx][nPosTipo] == "3"
						aAuxPred:= PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,aColsSV[nPosFldAFD][nx][nPosHRetar],AF9->AF9_PROJET,Nil)
						If aAuxRet[3] < aAuxPred[1] .Or. (aAuxRet[3] == aAuxPred[1] .And. aAuxRet[4] < aAuxPred[2])
							Pms203Msg(STR0013,CLR_HRED) //"Data Final invalida. Verifique os relacionamentos da Tarefa."
							lRet := .F.
							Exit
						EndIf
					Case aColsSV[nPosFldAFD][nx][nPosTipo] == "4"
						aAuxPred:= PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,aColsSV[nPosFldAFD][nx][nPosHRetar],AF9->AF9_PROJET,Nil)
						If aAuxRet[3] < aAuxPred[1] .Or.(aAuxRet[3] == aAuxPred[1] .And. aAuxRet[4] < aAuxPred[2])
							Pms203Msg(STR0013,CLR_HRED) //"Data Final invalida. Verifique os relacionamentos da Tarefa."
							lRet := .F.
							Exit
						EndIf
				EndCase
			EndIf
		Next nX
	EndIf
EndIf

If lRet .AND. ExistBlock("PM203FNA") //Tratamento de data inicial da tarefa
	lRet := ExecBlock("PM203FNA",.F.,.F.)
Endif

// VALIDA SE A DATA INICIAL IRÁ SER MENOR QUE O INICIO DO PROJETO
// OU SE A DATA FINAL SERA MAIOR DO QUE O FIM DO PROJETO
If lRet .AND. (M->AF9_RESTRI $ "78")
	cTrfIni := DtoS(aAuxRet[1])
	cTrfFim := DtoS(aAuxRet[3])
	If (cTrfIni < cPrjIni) .and. (M->AF9_RESTRI=="7") .AND. (ReadVar()=="M->AF9_START")
		lRet:= Aviso(STR0135,STR0136,{STR0086,STR0087},2) ==1  // Inicio do projeto //"Esta data e hora da tarefa fará com que o projeto seja iniciado mais cedo. Deseja Continuar?"
	ElseIf (cTrfFim < cPrjFim) .and. (M->AF9_RESTRI=="8") .AND. (ReadVar()=="M->AF9_FINISH")
		lRet:= Aviso(STR0137,STR0138,{STR0086,STR0087},2) ==1	// Fim do projeto // "Esta data e hora da tarefa fará com que o projeto seja finalizado mais tarde. Deseja Continuar?"
	EndIf
EndIf

If lRet
	M->AF9_HDURAC := nDuracao
	M->AF9_START := aAuxRet[1]
	M->AF9_HORAI := aAuxRet[2]
	M->AF9_FINISH:= aAuxRet[3]
	M->AF9_HORAF := aAuxRet[4]

	If (cTrfIni < cPrjIni) .and. (M->AF9_RESTRI=="7")
		M->AF9_DTREST := M->AF9_START
		M->AF9_HRREST := M->AF9_HORAI
	ElseIf (cTrfFim < cPrjFim) .and. (M->AF9_RESTRI=="8")
		M->AF9_DTREST := M->AF9_FINISH
		M->AF9_HRREST := M->AF9_HORAF
	EndIf

	If nPosFldREC > 0
		nPosRec	:= aScan(aHeaderSV[nPosFldREC],{|x| AllTrim(x[2])=="AFA_RECURS"})
		nPosQuant:= aScan(aHeaderSV[nPosFldREC],{|x| AllTrim(x[2])=="AFA_QUANT"})
		nPosAloc	:= aScan(aHeaderSV[nPosFldREC],{|x| AllTrim(x[2])=="AFA_ALOC"})
		nPosFix 	:= aScan(aHeaderSV[nPosFldREC],{|x| AllTrim(x[2])=="AFA_FIX"})


		//Atualiza recursos
		For nx := 1 to Len(aColsSV[nPosFldREC])
			If !aColsSV[nPosFldREC][nx][Len(aColsSV[nPosFldREC][nx])].And.!Empty(aColsSV[nPosFldREC][nx][nposRec])
				AE8->(dbSetOrder(1))
				AE8->(dbSeek(xFilial()+aColsSV[nPosFldREC][nx][nPosRec]))
				If aColsSV[nPosFldREC][nx][nPosFix] == "1"
					If aColsSV[nPosFldREC][nx][nPosAloc]>0
						aColsSV[nPosFldREC][nx][nPosQuant]	:= (aColsSV[nPosFldREC][nx][nPosAloc]*PmsHrsItvl(M->AF9_START,M->AF9_HORAI,M->AF9_FINISH,M->AF9_HORAF,AE8->AE8_CALEND,M->AF9_PROJET,AE8->AE8_RECURS))/100
					EndIf
				Else
					If aColsSV[nPosFldREC][nx][nPosQuant]>0
						aColsSV[nPosFldREC][nx][nPosAloc]	:= (aColsSV[nPosFldREC][nx][nPosQuant]/M->AF9_HDURAC)*100
					EndIf
				Endif
			EndIf
		Next

	EndIf

	Do Case
		Case nOpc==2
			Pms203Msg(STR0019) //"A duracao da tarefa foi recalculada de acordo com o calendario e as datas previstas."
		Case nOpc==3
			Pms203Msg(STR0020) //"A data inicial prevista foi recalculada de acordo com o calendario e a duracao da tarefa."
	EndCase
EndIf

RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS203VAFD³ Autor ³ Edson Maricate        ³ Data ³ 18-05-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao do codigo da tarefa digitada no relacion. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA203                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS203VAFD(cTarefa)
Local nx := 0
Local lRet 		:= .T.
Local nPosFldAFD := FolderOrd(STR0062)//'Relac.Tarefas'
Local nPosPred	:= 0

If cTarefa==M->AF9_TAREFA
	Pms203Msg(STR0021,CLR_HRED) //"Tarefa Invalida. A tarefa predecessora nao pode ser ela mesma."
	lRet := .F.
EndIf

If lRet .and. nPosFldAFD > 0
	nPosPred	:= aScan(aHeaderSV[nPosFldAFD],{|x| AllTrim(x[2])=="AFD_PREDEC"})

	For nx := 1 to len(aColsSV[nPosFldAFD])
		If  nx !=n.And.!aColsSV[nPosFldAFD][nx][Len(aColsSV[nPosFldAFD][nx])].And.aColsSV[nPosFldAFD][nx][nPosPred]==cTarefa
			Pms203Msg(STR0022,CLR_HRED) //"Tarefa Invalida. Voce nao pode vincular uma tarefa predecessora duas vezes a uma tarefa sucessora."
			lRet := .F.
			Exit
		EndIf
	Next nX
EndIf

If lRet .and. !Pms203Loop(M->AF9_PROJET,M->AF9_REVISA,cTarefa,M->AF9_TAREFA)
	Pms203Msg(STR0050,CLR_HRED)   //"Tarefa invalida. Este relacionamento ira criar uma referencia circular no projeto."
	lRet := .F.
EndIf

If lRet .and. !PMS203REL(M->AF9_PROJET , M->AF9_REVISA , M->AFD_PREDEC , M->AF9_TAREFA,M->AF9_EDTPAI, "AFD")
	Pms203Msg(STR0050,CLR_HRED)   //"Você está tentando vincular uma tarefa a outra que possui vários vínculos de tarefa com a primeira tarefa."
	lRet := .F.                   //"Isso caracteriza uma referência circular com as outras tarefas!"
EndIf


Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS203PRED³ Autor ³ Edson Maricate        ³ Data ³ 18-05-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que calcula as Datas de Inicio e Fim da tarefa a partir³±±
±±³          ³de seus reacionamentos.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA203                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS203PRED(lAviso)


Local aAuxRet
Local aArea		 := GetArea()
Local aAreaAF9	 := AF9->(GetArea())
Local aAreaAF8	 := AF8->(GetArea())
Local nPosFldPRD := 0
Local nPosFldAFD := 0
Local nPosFldAJ4 := 0
Local nPosPred	 := 0
Local nPosTipo	 := 0
Local nPosRetar  := 0
Local nPosPrf	 := 0
Local nPosPred7  := 0
Local nPosTipo7  := 0
Local nPosRetar7 := 0
Local lRet		 := .T.
Local nOpc		 := 2
Local nx := 0
Local nAFD
Local nAJ4

DEFAULT lAviso	:= .T.

If(nPosFldAFD := FolderOrd(STR0062))>0//'Relac.Tarefas'
	nPosPred	 := aScan(aHeaderSV[nPosFldAFD],{|x| AllTrim(x[2])=="AFD_PREDEC"})
	nPosTipo	 := aScan(aHeaderSV[nPosFldAFD],{|x| AllTrim(x[2])=="AFD_TIPO"})
	nPosRetar    := aScan(aHeaderSV[nPosFldAFD],{|x| AllTrim(x[2])=="AFD_HRETAR"})
EndIf

If(nPosFldAJ4 := FolderOrd(STR0063))>0 //'Relac.EDT'
	nPosPred7  := aScan(aHeaderSV[nPosFldAJ4],{|x| AllTrim(x[2])=="AJ4_PREDEC"})
	nPosTipo7  := aScan(aHeaderSV[nPosFldAJ4],{|x| AllTrim(x[2])=="AJ4_TIPO"})
	nPosRetar7 := aScan(aHeaderSV[nPosFldAJ4],{|x| AllTrim(x[2])=="AJ4_HRETAR"})
EndIf

// Protecao para quando aColsSV do AFD e/ou AJ4 vem com menos linhas que n
// aconteceu quando inclui uma linha na AFD, exclui e inclui outra.
// Essa outra está na linha 2 mas o array só tem uma linha.
nAFD:=IIf(n<len(aColsSV[nPosFldAFD]),n,len(aColsSV[nPosFldAFD]))
nAJ4:=IIf(n<len(aColsSV[nPosFldAJ4]),n,len(aColsSV[nPosFldAJ4]))

PmsAtuaCols(nGdAtu)

If 	(nGdAtu==nPosFldAFD.And.!Empty(aColsSV[nPosFldAFD][nAFD][nPosPred]) .And. ! Empty(aColsSV[nPosFldAFD][nAFD][nPosTipo])) .Or. ;
	(nGdAtu==nPosFldAJ4.And.!Empty(aColsSV[nPosFldAJ4][nAJ4][nPosPred7]) .And. ! Empty(aColsSV[nPosFldAJ4][nAJ4][nPosTipo7])) .Or. (nGDAtu<>nPosFldAFD .And. nGDAtu<>nPosFldAJ4)
	If (nGdAtu==nPosFldAFD.And.aColsSV[nPosFldAFD][nAFD][nPosPred]!=M->AF9_TAREFA) .Or. (nGdAtu==nPosFldAJ4.AND.aColsSV[nPosFldAJ4][nAJ4][nPosPred7]!=M->AF9_EDTPAI).Or.(nGDAtu<>nPosFldAFD .And. nGDAtu<>nPosFldAJ4)
		If lAviso .And. !IsAuto()
			nOpc := Aviso(STR0014,STR0023,{STR0016,STR0024},2) //"Atencao"###"Houveram alteracoes nos relacionamentos da Tarefa. Estas alteracoes implicam no recalculo das datas previstas para o Inicio e a Finalizacao da tarefa. Deseja continuar ?"###"Cancelar"###"Recalcular"
		EndIf
		If nOpc == 2
			AF8->(dbSetOrder(1))
			AF8->(dbSeek(xFilial()+M->AF9_PROJET))
			M->AF9_START := PMS_MIN_DATE
			M->AF9_HORAI := PMS_MIN_HOUR
			For nx := 1 to len(aColsSV[nPosFldAFD])
				If !aColsSV[nPosFldAFD][nx][Len(aColsSV[nPosFldAFD][nx])]
					AF9->(dbSetOrder(1))
					AF9->(dbSeek(xFilial()+M->AF9_PROJET+M->AF9_REVISA+aColsSV[nPosFldAFD][nx][nPosPred]))
					Do Case
						Case aColsSV[nPosFldAFD][nx][nPosTipo]=="1" //Fim no Inicio
							If !Empty(aColsSV[nPosFldAFD][nx][nPosRetar])

								// aplica o retardo na predecessora de acordo com o calendario do PROJETO
								aAuxRet := PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,aColsSV[nPosFldAFD][nx][nPosRetar])
								aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							Else
								aAuxRet := PMSDTaskF(AF9->AF9_FINISH,AF9->AF9_HORAF,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							EndIf
						Case aColsSV[nPosFldAFD][nx][nPosTipo]=="2" //Inicio no Inicio
							If !Empty(aColsSV[nPosFldAFD][nx][nPosRetar])

								// aplica o retardo na predecessora de acordo com o calendario do PROJETO
								aAuxRet := PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,aColsSV[nPosFldAFD][nx][nPosRetar])
								aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							Else
								aAuxRet := PMSDTaskF(AF9->AF9_START,AF9->AF9_HORAI,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							EndIf
						Case aColsSV[nPosFldAFD][nx][nPosTipo]=="3" //Fim no Fim
							If !Empty(aColsSV[nPosFldAFD][nx][nPosRetar])

								// aplica o retardo na predecessora de acordo com o calendario do PROJETO
								aAuxRet := PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,aColsSV[nPosFldAFD][nx][nPosRetar])
								aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							Else
								aAuxRet := PMSDTaskI(AF9->AF9_FINISH,AF9->AF9_HORAF,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							EndIf
						Case aColsSV[nPosFldAFD][nx][nPosTipo]=="4" //Inicio no Fim
							If !Empty(aColsSV[nPosFldAFD][nx][nPosRetar])

								// aplica o retardo na predecessora de acordo com o calendario do PROJETO
								aAuxRet := PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,aColsSV[nPosFldAFD][nx][nPosRetar])
								aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							Else
								aAuxRet := PMSDTaskI(AF9->AF9_START,AF9->AF9_HORAI,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							EndIf
					EndCase
					If  !Empty(aAuxRet).And.((aAuxRet[1]==M->AF9_START.And.SubStr(aAuxRet[2],1,2)+SubStr(aAuxRet[2],3,2)>SubStr(M->AF9_HORAI,1,2)+SubStr(M->AF9_HORAI,3,2)).Or.;
						(aAuxRet[1] > M->AF9_START))
						M->AF9_START := aAuxRet[1]
						M->AF9_HORAI := aAuxRet[2]
						M->AF9_FINISH:= aAuxRet[3]
						M->AF9_HORAF := aAuxRet[4]
					EndIf
				EndIf
			Next
			For nx := 1 to len(aColsSV[nPosFldAJ4])
				If !aColsSV[nPosFldAJ4][nx][Len(aColsSV[nPosFldAJ4][nx])]
					AFC->(dbSetOrder(1))
					AFC->(dbSeek(xFilial()+M->AF9_PROJET+M->AF9_REVISA+aColsSV[nPosFldAJ4][nx][nPosPred7]))
					Do Case
						Case aColsSV[nPosFldAJ4][nx][nPosTipo7]=="1" //Fim no Inicio
							If !Empty(aColsSV[nPosFldAJ4][nx][nPosRetar7])

								// aplica o retardo na predecessora de acordo com o calendario do PROJETO
								aAuxRet := PMSADDHrs(AFC->AFC_FINISH,AFC->AFC_HORAF,AF8->AF8_CALEND,aColsSV[nPosFldAJ4][nx][nPosRetar7])
								aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							Else
								aAuxRet := PMSDTaskF(AFC->AFC_FINISH,AFC->AFC_HORAF,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							EndIf
						Case aColsSV[nPosFldAJ4][nx][nPosTipo7]=="2" //Inicio no Inicio
							If !Empty(aColsSV[nPosFldAJ4][nx][nPosRetar7])

								// aplica o retardo na predecessora de acordo com o calendario do PROJETO
								aAuxRet := PMSADDHrs(AFC->AFC_START,AFC->AFC_HORAI,AF8->AF8_CALEND,aColsSV[nPosFldAJ4][nx][nPosRetar7])
								aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							Else
								aAuxRet := PMSDTaskF(AFC->AFC_START,AFC->AFC_HORAI,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							EndIf
						Case aColsSV[nPosFldAJ4][nx][nPosTipo7]=="3" //Fim no Fim
							If !Empty(aColsSV[nPosFldAJ4][nx][nPosRetar7])

								// aplica o retardo na predecessora de acordo com o calendario do PROJETO
								aAuxRet := PMSADDHrs(AFC->AFC_FINISH,AFC->AFC_HORAF,AF8->AF8_CALEND,aColsSV[nPosFldAJ4][nx][nPosRetar7])
								aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							Else
								aAuxRet := PMSDTaskI(AFC->AFC_FINISH,AFC->AFC_HORAF,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							EndIf
						Case aColsSV[nPosFldAJ4][nx][nPosTipo7]=="4" //Inicio no Fim
							If !Empty(aColsSV[nPosFldAJ4][nx][nPosRetar7])

								// aplica o retardo na predecessora de acordo com o calendario do PROJETO
								aAuxRet := PMSADDHrs(AFC->AFC_START,AFC->AFC_HORAI,AF8->AF8_CALEND,aColsSV[nPosFldAJ4][nx][nPosRetar7])
								aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							Else
								aAuxRet := PMSDTaskI(AFC->AFC_START,AFC->AFC_HORAI,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
							EndIf
					EndCase
					If  !Empty(aAuxRet).And.((aAuxRet[1]==M->AF9_START.And.SubStr(aAuxRet[2],1,2)+SubStr(aAuxRet[2],3,2)>SubStr(M->AF9_HORAI,1,2)+SubStr(M->AF9_HORAI,3,2)).Or.;
						(aAuxRet[1] > M->AF9_START))
						M->AF9_START := aAuxRet[1]
						M->AF9_HORAI := aAuxRet[2]
						M->AF9_FINISH:= aAuxRet[3]
						M->AF9_HORAF := aAuxRet[4]
					EndIf
				EndIf
			Next
			Pms203Msg(STR0025,CLR_HBLUE) //"As datas previstas foram recalculadas de acordo com as regras de relacionamento."
		Else
			lRet := .F.
		EndIf
	EndIf
EndIf

If lRet .AND. (nPosFldPRD := FolderOrd(STR0039))>0 //'Produtos'
	If (nPosPrf	:= aScan(aHeaderSV[nPosFldPRD],{|x| AllTrim(x[2])=="AFA_DATPRF"}))>0
		For nx := 1 to Len(aColsSV[nPosFldPRD])
			aColsSV[nPosFldPRD][nx][nPosPrf] := M->AF9_START
		Next nX
	EndIf
EndIf

RestArea(aAreaAF8)
RestArea(aAreaAF9)
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS203RINI³ Autor ³ Wagner Mobile Costa   ³ Data ³ 04-07-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da data inicial do recurso                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA203.                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS203RINI(cAlias, lTudoOk)

Local lRet 	:= .T., aCols, nAlias
Local nPosDIni, nPosHIni, nPosDFim, nPosHFim

DEFAULT cAlias	:= "AFA"
DEFAULT lTudoOk	:= .F.

If cAlias == "AFA"
	nAlias := FolderOrd(STR0040) //'Aloc. Recursos'
Else
	nAlias := FolderOrd(STR0038) //'Eventos'
EndIf

If nAlias>0
	aCols 		:= PmsAtuaCols(nAlias)
	nPosDIni	:= aScan(aHeaderSV[nAlias],{|x|AllTrim(x[2])== cAlias + "_START"})
	nPosHIni	:= aScan(aHeaderSV[nAlias],{|x|AllTrim(x[2])== cAlias + "_HORAI"})
	nPosDFim	:= aScan(aHeaderSV[nAlias],{|x|AllTrim(x[2])== cAlias + "_FINISH"})
	nPosHFim	:= aScan(aHeaderSV[nAlias],{|x|AllTrim(x[2])== cAlias + "_HORAF"})

	If aCols[n][Len(aCols[n])]	// Deletado
		Return .T.
	Endif

	If 	(!Empty(aCols[n][nPosDIni]).And.Empty(aCols[n][nPosHIni]).And.;
		aCols[n][nPosDini] < M->AF9_START) .Or.;
		(!Empty(aCols[n][nPosDIni]).And.!Empty(aCols[n][nPosHIni]).And.;
		DTOS(aCols[n][nPosDini])+aCols[n][nPosHIni] < DTOS(M->AF9_START) + M->AF9_HORAI)
		Aviso(STR0014,STR0041,{STR0042},2,STR0043) //"Atencao"###"A data inicial de alocacao devera ser maior ou igual a data inicial prevista para o inicio da tarefa. Verifique a data e hora digitada."###"Ok"###"Data inicial de alocacao invalida."
		lRet := .F.
	Endif

	If (!Empty(aCols[n][nPosDFim]).And.Empty(aCols[n][nPosHFim]).And.;
		aCols[n][nPosDFim] > M->AF9_FINISH).Or.;
		(!Empty(aCols[n][nPosDFim]).And.!Empty(aCols[n][nPosHFim]).And.;
		DTOS(aCols[n][nPosDFim])+aCols[n][nPosHFim] > DTOS(M->AF9_FINISH) + M->AF9_HORAF)
		Aviso(STR0014,STR0044,{STR0042},2,STR0043) //"Atencao"###"A data final de alocacao devera ser menor ou igual a data final prevista para o inicio da tarefa. Verifique a data e hora digitada."###"Ok"###"Data inicial de alocacao invalida."
		lRet := .F.
	Endif
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS203RFIM³ Autor ³ Wagner Mobile Costa   ³ Data ³ 04-07-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da data inicial do recurso                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA203                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS203RFIM(cAlias, lTudoOk)

Return PMS203RINI(cAlias, lTudoOk)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS203Aloc³ Autor ³ Edson Maricate        ³ Data ³ 04-07-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consiste a alocacao do recurso nas datas informadas.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA203                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS203Aloc()


Local lRet := .T.
Local lSeek := .T.
Local dRef := PMS_MIN_DATE
Local cHoraRef := PMS_MIN_HOUR
Local dAuxRef := PMS_MAX_DATE
Local cAuxHoraRef := "24:00"
Local aAloc := {}
Local aAuxAloc := {}
Local nPosRec := aScan(aHeader,{|x|AllTrim(x[2])== "AFA_RECURS"})
Local nPosAloc := aScan(aHeader,{|x|AllTrim(x[2])== "AFA_ALOC"})
Local nx := 0
Local ny := 0

aCols	:= PmsAtuaCols()

If ReadVar()=="M->AFA_RECURS"
	DbSelectArea("AE8")
	DbSetOrder(1)
	DbSeek(xFilial()+M->AFA_RECURS)
	If AE8->AE8_ATIVO == "2"
		Help("",1,STR0014,,STR0189,1,0,,,,,,{STR0190}) // "Atencao"##"Este recurso esta como inativo em seu cadastro."##"Informe um recurso ativo."
		lRet := .F.
	EndIf
EndIf

If !aCols[n][Len(aCols[n])] .AND. lRet
	AE8->(DbSetOrder(1))
	AE8->(DbSeek(xFilial("AE8") + aCols[n][nPosRec]))
	If .F. // AE8->AE8_SUPALO == "2" Retirado temporariamente.
		For nx := 1 to Len(aCols)
			If !aCols[nx][Len(aCols[nx])] .And. aCols[nx][nPosRec]==aCols[n][nPosRec]
				aAdd(aAuxAloc,{M->AF9_START,M->AF9_HORAI,M->AF9_FINISH,M->AF9_HORAF,aCols[nx][nPosAloc]})
			EndIf
		Next
		dbSelectArea("AFA")
		dbSetOrder(3)
		dbSeek(xFilial()+aCols[n][nPosRec])
		While !Eof() .And. xFilial()+aCols[n][nPosRec]==AFA_FILIAL+AFA_RECURS
			If !Empty(AFA_RECURS) .And. aScan(aRecAFA2,AFA->(RecNo()))<=0
				aAdd(aAuxAloc,{AFA_START,AFA_HORAI,AFA_FINISH,AFA_HORAF,AFA_ALOC})
			EndIf
			dbSkip()
		End
		While lSeek
			lSeek := .F.
			For nx := 1 to Len(aAuxAloc)
				If aAuxAloc[nx][1]>dRef .And. aAuxAloc[nx][2]>cHoraRef .And. ;
					aAuxAloc[nx][1]<dAuxRef .And. aAuxAloc[nx][2]<cAuxHoraRef
					lSeek	:= .T.
					dAuxRef	:= aAuxAloc[nx][1]
					cAuxHoraRef:= aAuxAloc[nx][2]
				EndIf
				If aAuxAloc[nx][3]>dRef .And. aAuxAloc[nx][4]>cHoraRef .And.;
					aAuxAloc[nx][3]<dAuxRef .And. aAuxAloc[nx][4]<cAuxHoraRef
					lSeek	:= .T.
					dAuxRef	:= aAuxAloc[nx][3]
					cAuxHoraRef:= aAuxAloc[nx][4]
				EndIf
			Next
			If lSeek
				dRef := dAuxRef
				cHoraRef := cAuxHoraRef
				aAdd(aAloc,{dAuxRef,cAuxHoraRef,0})
				dAuxRef		:= PMS_MAX_DATE
				cAuxHoraRef	:= "24:00"
			EndIf
		End
		For nx := 1 to Len(aAloc)-1
			dIni	:= aAloc[nx][1]
			cHIni	:= aAloc[nx][2]
			dFim	:= aAloc[nx+1][1]
			cHFim	:= aAloc[nx+1][2]
			For ny := 1 to Len(aAuxAloc)
				If  ((DTOS(aAuxAloc[ny][1])+aAuxAloc[ny][2] > DTOS(dIni)+cHIni .And.;
					DTOS(aAuxAloc[ny][1])+aAuxAloc[ny][2] < DTOS(dFim)+cHFim) .Or.;
					(DTOS(aAuxAloc[ny][3])+aAuxAloc[ny][4] > DTOS(dIni)+cHIni .And.;
					DTOS(aAuxAloc[ny][3])+aAuxAloc[ny][4] < DTOS(dFim)+cHFim)) .Or.;
					((DTOS(aAuxAloc[ny][1])+aAuxAloc[ny][2] <= DTOS(dIni)+cHIni .And.;
					DTOS(aAuxAloc[ny][3])+aAuxAloc[ny][4] >= DTOS(dFim)+cHFim))
					aAloc[nx][3] += aAuxAloc[ny][5]
				EndIf
			Next
		Next
		For nx := 1 to Len(aAloc)-1
			dIni	:= aAloc[nx][1]
			cHIni	:= aAloc[nx][2]
			dFim	:= aAloc[nx+1][1]
			cHFim	:= aAloc[nx+1][2]
			If (((DTOS(M->AF9_START)+M->AF9_HORAI>DTOS(dIni)+cHIni.And.;
				DTOS(M->AF9_START)+M->AF9_HORAI<DTOS(dFim)+cHFim).Or.;
				(DTOS(M->AF9_FINISH)+M->AF9_HORAF>DTOS(dIni)+cHFim.And.;
				DTOS(M->AF9_FINISH)+M->AF9_HORAF<DTOS(dFim)+cHFim)).Or.;
				(DTOS(M->AF9_START)+M->AF9_HORAI<=DTOS(dIni)+cHIni.And.;
				DTOS(M->AF9_FINISH)+M->AF9_HORAF>=DTOS(dFim)+cHFim)) .And. aAloc[nx][3]>AE8->AE8_UMAX
				Aviso(STR0045,STR0046,{STR0047},2) //"Recurso Superalocado"###"Este recurso nao podera ser alocado neste periodo pois ficara superalocado. Verifique a alocacao do recurso neste periodo ou informe outro recurso a ser alocado."###'Cancelar'
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf
EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Pms203NoPeriodo ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 11.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Compara dois periodos [DATA/HORA]                          	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1: Periodo a ser comparado                             	   ³±±
±±³          ³ ExpA2: Periodo onde a comparacao deve estar compreendida        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pms203NoPeriodo(aCompara, aPeriodo)

Local lRetorno := .F.

#DEFINE 	DATA_INICIO		1
#DEFINE 	HORA_INICIO		2
#DEFINE 	DATA_FINAL		3
#DEFINE 	HORA_FINAL      4

/*

02/07/2001 - 08:00 - 02/07/2001 - 08:30		- Periodo para comparacao

02/07/2001 - 07:50 - 02/07/2001 - 07:59		- Inicio e fim antes           			.F.

02/07/2001 - 08:31 - 02/07/2001 - 08:35		- Inicio e fim depois            		.F.

02/07/2001 - 08:10 - 02/07/2001 - 08:20		- Dentro do periodo            			.T

02/07/2001 - 07:50 - 02/07/2001 - 08:10		- Inicio antes e fim no periodo     	.T.

02/07/2001 - 08:20 - 02/07/2001 - 08:40		- Inicio no periodo e fim depois    	.T.

02/07/2001 - 07:50 - 02/07/2001 - 08:45		- Inicio antes e fim depois				.T.

*/

If	(Dtos(aCompara[DATA_INICIO]) + aCompara[HORA_INICIO] <;
	Dtos(aPeriodo[DATA_INICIO]) + aPeriodo[HORA_INICIO])	.And.;
	(Dtos(aCompara[DATA_FINAL])  + aCompara[HORA_FINAL] <;
	Dtos(aPeriodo[DATA_INICIO]) + aPeriodo[HORA_INICIO])		// Inicio e fim antes
	lRetorno := .F.
ElseIf	(Dtos(aCompara[DATA_INICIO]) + aCompara[HORA_INICIO] >;
	Dtos(aPeriodo[DATA_FINAL]) + aPeriodo[HORA_FINAL])	.And.;
	(Dtos(aCompara[DATA_FINAL]) + aCompara[HORA_FINAL] >;
	Dtos(aPeriodo[DATA_FINAL]) + aPeriodo[HORA_FINAL])	// Inicio e fim depois
	lRetorno := .F.
ElseIf 	(Dtos(aCompara[DATA_INICIO]) + aCompara[HORA_INICIO] >=;
	Dtos(aPeriodo[DATA_INICIO]) + aPeriodo[HORA_INICIO])	.And.;
	(Dtos(aCompara[DATA_FINAL]) + aCompara[HORA_FINAL] <=;
	Dtos(aPeriodo[DATA_FINAL]) + aPeriodo[HORA_FINAL])	// Dentro do periodo
	lRetorno := .T.
ElseIf 	(Dtos(aCompara[DATA_INICIO]) + aCompara[HORA_INICIO] <;
	Dtos(aPeriodo[DATA_INICIO]) + aPeriodo[HORA_INICIO])	.And.;
	(Dtos(aCompara[DATA_FINAL]) + aCompara[HORA_FINAL] <=;
	Dtos(aPeriodo[DATA_FINAL]) + aPeriodo[HORA_FINAL])	// Inicio antes e fim periodo
	lRetorno := .T.
ElseIf 	(Dtos(aCompara[DATA_INICIO]) + aCompara[HORA_INICIO] >=;
	Dtos(aPeriodo[DATA_INICIO]) + aPeriodo[HORA_INICIO])	.And.;
	(Dtos(aCompara[DATA_FINAL]) + aCompara[HORA_FINAL] >;
	Dtos(aPeriodo[DATA_FINAL]) + aPeriodo[HORA_FINAL])	// Inicio no periodo e fim depois
	lRetorno := .T.
ElseIf 	(Dtos(aCompara[DATA_INICIO]) + aCompara[HORA_INICIO] <;
	Dtos(aPeriodo[DATA_INICIO]) + aPeriodo[HORA_INICIO])	.And.;
	(Dtos(aCompara[DATA_FINAL]) + aCompara[HORA_FINAL] >;
	Dtos(aPeriodo[DATA_FINAL]) + aPeriodo[HORA_FINAL])	// Inicio antes e fim depois
	lRetorno := .T.
Endif

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Pms203Msg³ Autor ³ Edson Maricate         ³ Data ³ 11.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe uma mensagem no painel de mansagens no rodape da Tela ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Texto a ser exibido                                 ³±±
±±³          ³ExpC2 : Cor do texto                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pms203Msg(cTexto,cColor)

DEFAULT cColor := CLR_HBLUE

If !IsAuto()
	cMsgBoard := cTexto
	oMsgBoard:SetColor(cColor,cColor)
	oMsgBoard:Refresh()
	
	If !Empty(cTexto)
		oTimer:Activate()
	EndIf
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD4LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 4.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD4LinOk()

Local lRet		:= .T.
Local nPosItem	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_ITEM"})
Local nPosUso	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_USO"})
Local nPosPrv	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_DTPREV"})
Local nPosCli	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_CLIENT"})
Local nPosLoj	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_LOJA"})
Local nPosVlr	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_VALOR"})
Local nPosCnd	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_COND"})
Local nPosNum	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_NUM"})
Local nPosPref	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_PREFIX"})
Local nPosNat	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_NATURE"})
Local nPosPerc	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_PERC"})
Local nPosDescri:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_DESCRI"})
Local nPosTit 	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_GERTIT"})
Local nPosPrv2	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_GERPRV"})
Local i 		:= 0
Local lPrv		:=	.F.
Local lTit		:=	.F.

If !aCols[n][Len(aHeader)+1]
	If Empty(aCols[n][nPosUso]) .Or. Empty(aCols[n][nPosPrv]) .Or.  Empty(aCols[n][nPosPerc]) .Or. Empty(aCols[n][nPosDescri])
		HELP("   ",1,"OBRIGAT2")
		lRet := .F.
	EndIf

	If lRet .And. !Empty(aCols[n][nPosCli])
		If Empty(aCols[n][nPosLoj]) .Or. Empty(aCols[n][nPosVlr]) .Or. Empty(aCols[n][nPosCnd]);
			.Or. ((Empty(aCols[n][nPosNum]).Or.Empty(aCols[n][nPosPref])) .And. (aCols[n][nPosTit] == "1";
			.Or. aCols[n][nPosPrv2] <> "3"))	.Or. Empty(aCols[n][nPosNat])
			HELP("   ",1,"OBRIGAT2")
			lRet := .F.
		EndIf
	EndIf

	// verificar se o número já está sendo utilizado nos eventos cadastrados
	If lRet .And. !aCols[n][Len(aCols[n])] .And. n > 0 .And. ( aCols[n][nPosTit] == "1" .Or. aCols[n][nPosPrv2] $ "12" )
		lPrv	:=		(aCols[n][nPosPrv2] $ "12" )
		lTit	:=	 	(aCols[n][nPosTit] == "1"  )
		For i := n - 1 To 1 Step -1
			If !aCols[i][Len(aCols[i])]
				If (aCols[i][nPosPref] == aCols[n][nPosPref] .And. aCols[i][nPosNum] == aCols[n][nPosNum] .And.;
					( (lPrv .And.  aCols[i][nPosPrv2] $ "12"  ) .Or. (lTit .And. aCols[i][nPosTit] == "1") ) )
					Aviso(STR0114, STR0115, {"OK"})	//"Titulo informado"##"Este numero de titulo foi informado anteriormente. Informe outro numero de titulo."
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next I

		If lRet
			For i := n + 1 To Len(aCols)
				If !aCols[i][Len(aCols[i])]
					If (aCols[i][nPosPref] == aCols[n][nPosPref] .And. aCols[i][nPosNum] == aCols[n][nPosNum]).And.;
						( (lPrv .And.  aCols[i][nPosPrv2] $ "12"  ) .Or. (lTit .And. aCols[i][nPosTit] == "1"))
						Aviso(STR0114, STR0115, {"OK"})	//"Titulo informado"##"Este numero de titulo foi informado anteriormente. Informe outro numero de titulo."
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next I
		EndIf
	EndIf

	// verificar se o título já existe
	If lRet .And. ExisteTit(aCols[n][nPosPref], aCols[n][nPosNum])

		If !ExisteAFT(aCols[n][nPosPref] ,aCols[n][nPosNum] ,,M->AF9_PROJET ,M->AF9_REVISA ,M->AF9_TAREFA ,aCols[n][nPosItem] )
			Aviso(STR0114, STR0116, {"OK"})	////"Titulo informado"##"Ja existe um titulo com o numero de titulo informado. Informe outro numero de titulo."
			lRet := .F.
		EndIf
	EndIf

EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD4TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 4.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD4TudOk()
Local nx := 0
Local nPosUso	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_USO"})
Local nSavN		:= n
Local lRet		:= .T.
Local nPosFolder := FolderOrd(STR0038) //'Eventos'

// se a getdados não foi alterada,
// não é necessário validar os dados
If !IsAuto()
	If nPosFolder>0 .AND. !oGd[nPosFolder]:lModified
		Return lRet
	EndIf
EndIf

For nx := 1 to Len(aCols)
	n	:= nx
	If !(aCols[n][Len(aHeader)+1]) .And. !Empty(aCols[n][nPosUso])
		If !A203GD4LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

n	:= nSavN

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Pms203Qt  ³ Autor ³ Eduardo Riera         ³ Data ³ 24.12.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³               ³                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pms203Qt()

Local nPosQTSeg := aScan(aHeader,{|x| AllTrim(x[2])=="AFA_QTSEGU"})
Local nPosProdut:= aScan(aHeader,{|x| AllTrim(x[2])=="AFA_PRODUT"})
Local nQuant := &(ReadVar())
Local nRet 	:= ConvUM(aCols[n][nPosProdut],nQuant,0,2)
If nRet > 0
	aCols[n][nPosQtSeg] := nRet
EndIf

Return .T.

Function Pms2032Qt()

Local nPosQuant := aScan(aHeader,{|x| AllTrim(x[2])=="AFA_QUANT"})
Local nPosProdut:= aScan(aHeader,{|x| AllTrim(x[2])=="AFA_PRODUT"})
Local nQuant2 := &(ReadVar())
Local nRet 		:= ConvUM(aCols[n][nPosProdut],0,nQuant2,1)

If nRet > 0
	aCols[n][nPosQuant] := nRet
EndIf


Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms203Cli³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do codigo do cliente digitado.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms203Cli()

Local nPosLj	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFP_LOJA"})
Local lRet		:= Vazio() .Or. ExistCpo("SA1",M->AFP_CLIENT)

If Vazio()
	aCols[n][nPosLj]	:= SPACE(LEN(AFP->AFP_LOJA))
EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms203Lj³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da loja digitada no evento.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms203Lj()

Local nx2:=0
Local nPosAFP	:= 0
Local nPosCli	:= 0

For nx2:= 1 to Len(aHeaderSV)
	nPosAFP := IIf(SubStr(AllTrim(aHeaderSV[nx2][1][2]),1,3) == "AFP",nx2,0)
	If nPosAFP > 0
		Exit
	EndIf
Next

nPosCli	:= aScan(aHeaderSV[nPosAFP],{|x|AllTrim(x[2])=="AFP_CLIENT"})

Return ExistCpo("SA1",aCols[n][nPosCli]+M->AFP_LOJA)

/*/{Protheus.doc} Pms203Loop

Funcao principal para verificar se existe alguma refercia circular no projeto.

@author Edson Maricate

@since 09-02-2001

@version P11

@param cProjet, 		caracter, Codigo do projeto
@param cRevisa, 		caracter, Codigo da revisão
@param cTarefa, 		caracter, Codigo da tarefa (predecessora)
@param cTskChk, 		caracter, Codigo da tarefa (tarefa corrente)

@return Logico, se não houve falha

/*/
Static Function Pms203Loop(cProjet,cRevisa,cTarefa,cTskChk)
Local lRet			:= .T.
Local aArea 		:= GetArea()
Local aAreaAFD	:= AFD->(GetArea())
Local aTarefas 	:= {}
Local aRetorno 	:= {}

	aAdd(aTarefas,cTarefa)
	While Len(aTarefas)>0 .AND. lRet
		aRetorno := Aux203Loop(cProjet,cRevisa,aTarefas,cTskChk)
		lRet := aRetorno[1]
		aTarefas := aClone(aRetorno[2])
	End

RestArea(aAreaAFD)
RestArea(aArea)

Return lRet

/*/{Protheus.doc} Aux203Loop

Funcao auxiliar para o calculo das datas e horas de inicio e fim referente as tarefas sucessoras

@author Reynaldo Tetsu Miyashita

@since 06/11/2013

@version P11

@param cProjet, 		caracter, Codigo do projeto
@param cRevisa, 		caracter, Codigo da revisão
@param aTarefas, 		array,    Codigos da tarefa (predecessoras)
@param cTskChk, 		caracter, Codigo da tarefa (corrente)

@return array, [1] - Verdadeiro, se não houve falha e [2] - Array com os codigos das tarefas sucessoras.

/*/
Static Function Aux203Loop(cProjet,cRevisa,aTarefas, cTskChk)
Local lRet 	:= .T.
Local cTarefa := ""
Local nCntTsk := 0
Local aTaskSuc := {}

For nCntTsk := 1 to len(aTarefas)
	cTarefa := aTarefas[nCntTsk]

			dbSelectArea("AFD")
			dbSetOrder(1)
			dbSeek(xFilial("AFD")+cProjet+cRevisa+cTarefa)
			While lRet .And. !Eof() .And. xFilial("AFD")+cProjet+cRevisa+cTarefa==;
								AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA
				If AFD->AFD_PREDEC == cTskChk
			aTaskSuc := {}
					lRet := .F.
					Exit
				EndIf
		aAdd(aTaskSuc,AFD->AFD_PREDEC)
				dbSelectArea("AFD")
				dbSkip()
			EndDo

	// encerra "forcadamente" o for
	If !lRet
									Exit
								EndIf
Next

Return {lRet, aTaskSuc}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms203TpMd³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do campo Tipo de medicao da tarefa.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Validacao SX3 - AF9_TPMEDI                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms203TpMd()
Local nx := 0
Local nPosFldAFZ:= FolderOrd(STR0051)//'Cronograma por Periodo'

If nPosFldAFZ >0
	// se o folder for o cronograma por Periodo
	If oFolder:nOption==nPosFldAFZ
		For nx := 1 to Len(aHeader)
			aCols[1][nx] := 0
		Next
	Else
		For nx := 1 to Len(aHeaderSV[nPosFldAFZ])
			aColsSV[nPosFldAFZ][1][nx] := 0
		Next
	EndIf
	If !IsAuto()
		oGD[nPosFldAFZ]:oBrowse:Refresh()
	EndIf
EndIf

If M->AF9_TPMEDI == "6"
	M->AF9_START := PMS_EMPTY_DATE
	M->AF9_HORAI := PMS_MIN_HOUR
	M->AF9_FINISH:= PMS_EMPTY_DATE
	M->AF9_HORAF := PMS_MIN_HOUR
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GDDel    ³ Autor ³Fabio Rogerio Pereira³ Data ³02-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a exclusao do item da getdados						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203				                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GDDel(nGet)
Local lRet       := .T.
Local aTmpCols   := {}
Local aTmpHeader := {}
Local nTmpN      := 0
Local nFolRec    := FolderOrd(STR0040)
Local nPos_PLANEJ := aScan(aHeader,{|x| AllTrim(x[2])=="AFA_PLANEJ"})
Local nPos_RECURS := aScan(aHeader,{|x| AllTrim(x[2])=="AFA_RECURS"})
Local aArea
Local aAreaAFU
Local lPMS203Vex := ExistBlock("PMA203VEx")
Local lCalcTrib  := IIf(AF8->AF8_PAR006 == '1', .T., .F.)	//Verifica se havera calculo de impostos para as tarefas

// somente valida a exclusao de itens para opcao diferente de Visualizar
If (oGD[nGet]:nOpc <> 2)

	If !GDDeleted()
		If nPos_PLANEJ > 0 .AND. !Empty(aCols[n][nPos_PLANEJ])
			Alert(STR0167) //"Não é possível a exclusão do item, pois já foi gerado um planejamento!"
			lRet := .F.
		EndIf

		If (nGet == nFolRec) .And. nPos_RECURS > 0 .And. n<=len(aRecAFA2)
			If AF8->AF8_PAR002=="1" .Or. AF8->AF8_PAR002=="2"
				aArea	:= GetArea()
				aAreaAFU:= AFU->(GetArea())

				dbSelectArea("AFU")
				AFU->(dbSetOrder(1)) //AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA+AFU_RECURS
				If AFU->(MsSeek( xFilial("AFU")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+aCols[n][nPos_RECURS] ))
					If Left(Procname(2),25) <> "{|| IF(SELF:LACTIVE .AND."
						Aviso(STR0172,STR0173,{STR0061},2) //"Apontamentos encontrados"##"O recurso selecionado possui apontamentos e nao pode ser excluido"
					EndIf
					lRet := .F.
				EndIf
				RestArea(aAreaAFU)
				RestArea(aArea)
			EndIf
		EndIf
	Endif

	If lRet .and. lPMS203Vex
		aTmpHeader := aClone(aHeader)
		aTmpCols   := aClone(aCols)
		nTmpN := N

		lRet := ExecBlock("PMA203VEx",.F.,.F.,{aTmpCols,nTmpN})

		N := nTmpN
		aCols := aClone(aTmpCols)
		aHeader := aClone(aTmpHeader)
	EndIf

	//Atualizacao de Tributos
	If lCalcTrib
		//Deleta linha da GetDados quando for possível exclusão do item
		If lRet
			/*
			 No evento de delecao de um registro na GetDados de Aloc. Recursos, a rotina de validacao e chamada duas vezes.
			 Para tratar corretamente a exibicao dos impostos no folder de Tributos a partir da funcao A203GDAN9Inc,
			 foi necessario separar o tratamento de registros com flag deletado nas folders Produto e Aloc. Recursos.
			*/
			If nGet == 1
				A203GDAN9Inc(aHeader,aCols, n, nGet, !aCols[n][Len(aCols[n])] )
			ElseIf nGet == 5
				A203GDAN9Inc(aHeader,aCols, n, nGet, aCols[n][Len(aCols[n])] )
			EndIf
		EndIf
	EndIf

	// atualiza o custo da tarefa
	If ExistTemplate("CCTAF9CALC")
		ExecTemplate("CCTAF9CALC",.F.,.F.,{nGet})
	Else
		//Inverto o status de "deletado" da linha pois no momento em que a tecla Delete é pressionada
		//a propriedade não é atualizada, somente após as validações
		aCols[n][Len(aHeader)+1] := !aCols[n][Len(aHeader)+1]

		A203GDCalcCust(nGet)

		//Retorno o status de "deletado" da linha para que o método DelOk faça o tratamento correto,
		//deletando a linha após as validações correspondentes
		aCols[n][Len(aHeader)+1] := !aCols[n][Len(aHeader)+1]
	EndIf

	If (nGet == nFolRec) .and. lRet
		P203SomaEsf()// Recalcula o valor do esforço da tarefa baseado nos novos esforços dos recursos
		If M->AF9_TPTRF $ "2;3"
			Pms203DtFim(aHeader, aCols)
		Endif
	EndIf
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD6LinOk³ Autor ³Fabio Rogerio Pereira³ Data ³ 05-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 6.(Cronograma Periodo)           ³±±
±±³			 ³ Retorna Falso para nao permitir inclusao de linha			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD6LinOk()
Return(.F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS203PRDE³ Autor ³ Edson Maricate        ³ Data ³ 18-05-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que calcula as Datas de Inicio e Fim da tarefa a partir³±±
±±³          ³de seus reacionamentos.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA203                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS203PRDE()
Return PMS203PRED(!IsAuto())

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD7LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 7.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD7LinOk()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet 		:= MaCheckCols(aHeader,aCols,n)
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="AJ4_ITEM"})

If !(aCols[n][Len(aHeader)+1])
	If Inclui .And. lRet .And. ! aCols[n][Len(aCols[n])]
		lRet := PmsVldFase("AF8",M->AF9_PROJET,"33")
	ElseIf Altera .And. lRet .And. ! aCols[n][Len(aCols[n])]
		AJ4->(dbSetOrder(1))
		If AJ4->(dbSeek(xFilial()+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA+aCols[n][nPosItem]))
			lRet := PmsVldFase("AF8",M->AF9_PROJET,"34")
		Else
			lRet := PmsVldFase("AF8",M->AF9_PROJET,"33")
		EndIf
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203GD7TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 7.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GD7TudOk()
Local nx := 0
Local nPosPredec	:= aScan(aHeader,{|x|AllTrim(x[2])=="AJ4_PREDEC"})
Local nSavN	:= n
Local lRet	:= .T.
Local nPosFolder := FolderOrd(STR0063)//'Relac.EDT'

// se a getdados não foi alterada,
// não é necessário validar os dados
If !IsAuto()
	If nPosFolder>0 .AND. !oGd[nPosFolder]:lModified
		Return lRet
	EndIf
EndIf

For nx := 1 to Len(aCols)
	n	:= nx
	If !(aCols[n][Len(aHeader)+1]) .And. !Empty(aCols[n][nPosPredec])
		If !A203GD7LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

n	:= nSavN

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A203GDCalcCustºAutor ³Paulo Carnelossi º Data ³  13/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que recalcula o custo das tarefas e alimenta ench    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GDCalcCust(nGet)

Local aRetCus
Local lCalcTrib := IIf(AF8->AF8_PAR006 == '1' ,.T.,.F.)	//Verifica se havera calculo de impostos para as tarefas
Local nPercBDI := 0

DEFAULT nGet := Iif(Type("oFolder")="O",oFolder:nOption,1)

If ExistTemplate("CCTAF9Calc")
	ExecTemplate("CCTAF9Calc",.F.,.F.,{nGet})
Else
	aRetCus			:= PmsAF9CusTrf(nGet)
	nPercBDI		:= IIf(M->AF9_BDI <> 0,M->AF9_BDI,PmsGetBDIPad('AFC',M->AF9_PROJET,M->AF9_REVISA,M->AF9_EDTPAI, M->AF9_UTIBDI ) )
	M->AF9_CUSTO	:= aRetCus[1]
	M->AF9_CUSTO2	:= aRetCus[2]
	M->AF9_CUSTO3	:= aRetCus[3]
	M->AF9_CUSTO4	:= aRetCus[4]
	M->AF9_CUSTO5	:= aRetCus[5]
	If ! (aRetCus[1] == 0 .And. M->AF9_VALBDI <> 0 ) .and.  nPercBDI <> 0
		M->AF9_VALBDI:= aRetCus[1]*nPercBDI/100
	EndIf
	M->AF9_TOTAL := aRetCus[1]+M->AF9_VALBDI
	If lCalcTrib
		M->AF9_TOTIMP := A203aTotImp()
	EndIf
EndIf

If ExistBlock("PMA203CUS")
	ExecBlock("PMA203CUS",.F.,.F.,{nGet})
EndIf

If !IsAuto() .and. Type("oEnch")="O"
	oEnch:Refresh()
EndIf
Return M->AF9_CUSTO

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A203TemApontºAutor ³Paulo Carnelossi   º Data ³  22/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ A203TemApont(cProjeto,cRevisa,cTrf)                        º±±
±±º          ³ Retorna .T. se tarefa possui apontamento .F. se nao        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A203TemApont(cProjeto,cRevisa,cTrf)
Local dDataRef := PMS_MAX_DATE
Local cTrfDe   := cTrf
Local cTrfAte  := cTrf
Local aApontTrf
aApontTrf := PmsIniCRTE(cProjeto,cRevisa,dDataRef,cTrfDe,cTrfAte)
Return(Len(aApontTrf)>0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A203ChkAloc ºAutor ³                   º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta dialog com a Disponibilidade da Equipe /Recursos     º±±
±±º          ³ com os recursos informados no folder aloc. recursos.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203ChkAloc(lAltera)
Local aCfgGnt   := {6 ,.T. ,.T. ,.T. ,3}
Local dCFGIni   := dDataBase
Local aGantt	:= {}
Local aAuxRet	:= {}
Local aConcat 	:= {}
Local aDispo	:= {}
Local aOpcao := {}
Local nTop     := oMainWnd:nTop+23
Local nLeft    := oMainWnd:nLeft+5
Local nBottom  := oMainWnd:nBottom-60
Local nRight   := oMainWnd:nRight-10
Local nTsk     := 1
Local aCorBarras := {}
Local aItvls	:= {}
Local nTarefa := 0
Local dIniRet	:= PMS_EMPTY_DATE
Local cHoraIniRet := PMS_MIN_HOUR
Local	aAreaAF8	:=	AF8->(GetArea())
Local nAloc		:=	0
Local nPercAloc:=	0
Local nz

Local nLenRec	:=	30
Local oDlg

Local nPosQuant 	:= aScan(aHeader,{|x| AllTrim(x[2])=="AFA_QUANT"})
Local nPosRecurs 	:= aScan(aHeader,{|x| AllTrim(x[2])=="AFA_RECURS"})
Local nPosAloc   	:= aScan(aHeader,{|x| AllTrim(x[2])=="AFA_ALOC"})
Local nPosDescRec	:= aScan(aHeader,{|x| AllTrim(x[2])=="AFA_DESCRI"})
Local nPosDtNec	:= aScan(aHeader,{|x| AllTrim(x[2])=="AFA_DATPRF"})
Local nPosCols		:=	0
Local nTmpAloc		:=	0
Local aArea	:= GetArea()
Local nx
Local ny
Local aConfig := {MsDate(),Substr(Time(),1,5),MsDate()+30,"24:00",1,Posicione("AE8",3,xFilial()+__cUserID,"AE8_EQUIP")}
Local cRecurso := ""
Local lConfirma	:= .F.
Local cSavHoraIni	:= M->AF9_HORAI
Local dSavStart	:= M->AF9_START
Local cRecAtu		:=	""
Local aRet	:=	{}
Local nHrsInt	:=	0
Local dIniDItvl:= PMS_EMPTY_DATE
Local cIniHItvl:=	""
Local lFWGetVersao := .T.
Local aButtons	:= {}

PRIVATE bRfshGantt
//Esta variavel pode ser utilizada dentro do PMA203EQ para definir o tempo total a ser considerado para achar alocacao,
//para o caso em que queira se achar mais tempo para alocar do que tempo de duracao da tarefa
Private nTmpDurac	:=	M->AF9_HDURAC

If ExistBLock('PMA203EQ')
	aConfig[6]	:=	ExecBLock('PMA203EQ',.F.,.F.)
Endif
//MV_PAR05 := 2
If ParamBox({	{1,STR0018,aConfig[1],"","","","",45,.T.},;  //"Data Inicial"
	{1,STR0068,aConfig[2],"99:99","AtVldHora(mv_par02)","","",25,.T.},;  //"Hora Inicial"
	{1,STR0069,aConfig[3],"","","","",45,.T.},; //"Data Final"
	{1,STR0070,aConfig[4],"99:99","AtVldHora(mv_par04)",""   ,"",25,.T.},;
	{3,STR0099,aConfig[5], {STR0100,STR0089 } ,80 ,"",.T.},; //"Mostrar alocacao de"###"Recursos da tarefa"###"Equipe"
	{1,STR0089,aConfig[6],""    ,""                   ,"AED","mv_par05==2",70,.F.}},;
	STR0071,aConfig)  //"Hora Final"###"Assistente de Disponibilidade" //"Equipe"


	If aConfig[5]==1
		For nx := 1 to Len(aCols)
			If !aCols[nx][Len(aCols[nx])]
				AE8->(dbSetOrder(1))
				AE8->(dbSeek(xFilial()+aCols[nx,nPosRecurs]))
				aRetAloc := PmsRetAloc(aCols[nx,nPosRecurs],aConfig[1],aConfig[2],aConfig[3],aConfig[4],3,M->AF9_PROJET,M->AF9_REVISA,If(lAltera,M->AF9_TAREFA,Nil))
				If Empty(aRetAloc)
					aAdd(aItvls,{AE8->AE8_RECURS,aConfig[1],aConfig[2],aConfig[3],aConfig[4],0})
				Else
					For ny := 1 to Len(aRetAloc)
						If ny == 1 .And. aRetAloc[ny,1] > aConfig[1]
							aAuxRet := PMSDTaskF(aConfig[1],aConfig[2],AE8->AE8_CALEND,1,M->AF9_PROJET,AE8->AE8_RECURS)
							aAdd(aItvls,{AE8->AE8_RECURS,aAuxRet[1],aAuxRet[2],aRetAloc[ny,1],aRetAloc[ny,2],0})
						EndIf
						If  ny <> Len(aRetAloc) .And. (( AE8->AE8_UMAX-aRetAloc[ny,3])  * PmsHrsItvl(aRetAloc[ny,1],aRetAloc[ny,2],aRetAloc[ny+1,1],aRetAloc[ny+1,2],AE8->AE8_CALEND,M->AF9_PROJET,AE8->AE8_RECURS) / 100 ) >= aCols[nX,nPosQuant]
							aAdd(aItvls,{AE8->AE8_RECURS,aRetAloc[ny,1],aRetAloc[ny,2],aRetAloc[ny+1,1],aRetAloc[ny+1,2],AE8->AE8_UMAX-aRetAloc[ny,3]})
						EndIf
						If ny == Len(aRetAloc)-1 .And. aRetAloc[Len(aRetAloc),1] < aConfig[3]
							aAuxRet := PMSDTaskI(aConfig[3],aConfig[4],AE8->AE8_CALEND,1,M->AF9_PROJET,AE8->AE8_RECURS)
							aAdd(aItvls,{AE8->AE8_RECURS,aRetAloc[Len(aRetAloc),1],aRetAloc[Len(aRetAloc),2],aAuxRet[3],aAuxRet[4],0})
						EndIf
					Next ny
				EndIf
			EndIf
		Next nx
	ElseIf aConfig[5]==2
		AE8->(dbSetOrder(4))
		AE8->(dbSeek(xFilial()+aConfig[6]))
		While !AE8->(Eof()) .And. xFilial('AE8')==	AE8->AE8_FILIAL .And. 	AE8->AE8_EQUIP==aConfig[6]
			aRetAloc := PmsRetAloc(AE8->AE8_RECURS,aConfig[1],aConfig[2],aConfig[3],aConfig[4],3,M->AF9_PROJET,M->AF9_REVISA,If(lAltera,M->AF9_TAREFA,Nil))
			If Empty(aRetAloc)
				aAdd(aItvls,{AE8->AE8_RECURS,aConfig[1],aConfig[2],aConfig[3],aConfig[4],0})
			Else
				nPosCols	:=	Ascan(aCols,{|x| x[nPosRecurs]==AE8->AE8_RECURS})
				If nPosCols	>	0
					nTmpAloc	:=	aCols[nPosCols,nPosQuant]
				Else
					nTmpAloc	:=	0
				Endif
				For ny := 1 to Len(aRetAloc)
					If ny == 1 .And. aRetAloc[ny,1] > aConfig[1]
						aAuxRet := PMSDTaskF(aConfig[1],aConfig[2],AE8->AE8_CALEND,1,M->AF9_PROJET,AE8->AE8_RECURS)
						aAdd(aItvls,{AE8->AE8_RECURS,aAuxRet[1],aAuxRet[2],aRetAloc[ny,1],aRetAloc[ny,2],0})
					EndIf
					If  ny <> Len(aRetAloc) .And. (( AE8->AE8_UMAX-aRetAloc[ny,3])  * PmsHrsItvl(aRetAloc[ny,1],aRetAloc[ny,2],aRetAloc[ny+1,1],aRetAloc[ny+1,2],AE8->AE8_CALEND,M->AF9_PROJET,AE8->AE8_RECURS) / 100 ) >= nTmpAloc
						aAdd(aItvls,{AE8->AE8_RECURS,aRetAloc[ny,1],aRetAloc[ny,2],aRetAloc[ny+1,1],aRetAloc[ny+1,2],AE8->AE8_UMAX-aRetAloc[ny,3]})
					EndIf
					If ny == Len(aRetAloc)-1 .And. aRetAloc[Len(aRetAloc),1] < aConfig[3]
						aAuxRet := PMSDTaskI(aConfig[3],aConfig[4],AE8->AE8_CALEND,1,M->AF9_PROJET,AE8->AE8_RECURS)
						aAdd(aItvls,{AE8->AE8_RECURS,aRetAloc[Len(aRetAloc),1],aRetAloc[Len(aRetAloc),2],aAuxRet[3],aAuxRet[4],0})
					EndIf
				Next ny
			Endif
			AE8->(DbSkip())
		Enddo
		/**********************************************
		Else // por hsbilidades aConfi[5]==1
		aRechabiles:= A203Requisito( M->AF9_CODREQ , .T. )
		For nx := 1 To Len( aRecHabiles )
		AE8->( dbSetOrder( 1 ) )
		AE8->( dbSeek( xFilial() + aRecHabiles[ nx ] ) )
		aRetAloc := PmsRetAloc(aRecHabiles[nx],aConfig[1],aConfig[2],aConfig[3],aConfig[4],3,M->AF9_PROJET,M->AF9_REVISA,If(lAltera,M->AF9_TAREFA,Nil))
		If Empty(aRetAloc)
		aAdd(aItvls,{AE8->AE8_RECURS,aConfig[1],aConfig[2],aConfig[3],aConfig[4],0})
		Else
		For ny := 1 to Len(aRetAloc)
		If ny == 1 .And. aRetAloc[ny,1] > aConfig[1]
		aAuxRet := PMSDTaskF(aConfig[1],aConfig[2],AE8->AE8_CALEND,1,M->AF9_PROJET,AE8->AE8_RECURS)
		aAdd(aItvls,{AE8->AE8_RECURS,aAuxRet[1],aAuxRet[2],aRetAloc[ny,1],aRetAloc[ny,2],0})
		EndIf
		// deve adicionar se o periodo atende o minimo da alocacao atual.
		If  ny <> Len(aRetAloc) .And. (( AE8->AE8_UMAX-aRetAloc[ny,3])  * PmsHrsItvl(aRetAloc[ny,1],aRetAloc[ny,2],aRetAloc[ny+1,1],aRetAloc[ny+1,2],AE8->AE8_CALEND,M->AF9_PROJET,AE8->AE8_RECURS) / 100 ) >= aCols[nX,nPosQuant]
		aAdd(aItvls,{AE8->AE8_RECURS,aRetAloc[ny,1],aRetAloc[ny,2],aRetAloc[ny+1,1],aRetAloc[ny+1,2],AE8->AE8_UMAX-aRetAloc[ny,3]})
		EndIf
		If ny == Len(aRetAloc)-1 .And. aRetAloc[Len(aRetAloc),1] < aConfig[3]
		aAuxRet := PMSDTaskI(aConfig[3],aConfig[4],AE8->AE8_CALEND,1,M->AF9_PROJET,AE8->AE8_RECURS)
		aAdd(aItvls,{AE8->AE8_RECURS,aRetAloc[Len(aRetAloc),1],aRetAloc[Len(aRetAloc),2],aAuxRet[3],aAuxRet[4],0})
		EndIf
		Next ny
		EndIf
		Next nx
		**********************************************/
	Endif

	For nx := 1 To Len(aItvls)
		dIniDItvl	:= PMS_EMPTY_DATE
		cIniHItvl	:=	""
		If DTOS(aItvls[nx,4])+aItvls[nx,5] < Dtos(aConfig[1])+aConfig[2] //se acaba asntes do inicio
			dIniDItvl	:= PMS_EMPTY_DATE
			cIniHItvl	:=	""
		ElseIf  aItvls[nx,2] > aConfig[1] //Se o inicio eh depois do inicio solicitado incluo o intervalo interiro
			dIniDItvl	:= 	aItvls[nx,2]
			cIniHItvl	:=	 	aItvls[nx,3]
		ElseIf aItvls[nx,2] == aConfig[1] // se inicia no mesmo dia coloco a maior hora
			dIniDItvl	:= aItvls[nx,2]
			cIniHItvl	:=	If(aItvls[nx,3]>aConfig[2],aItvls[nx,3],aConfig[2])
		ElseIf aItvls[nx,2] == aConfig[1] // se inicia ante mais acaba depois do solicitado, o inicio e o solicitado
			dIniDItvl	:=	aConfig[1]
			cIniHItvl	:=	aConfig[2]
		Endif
		If !Empty(dIniDItvl)
			If cRecurso <> aItvls[nx,1]
				AE8->(dbSetOrder(1))
				AE8->(MsSeek(xFilial()+aItvls[nx,1]))
				aAdd(aGantt,{ { aItvls[nx,1] ,AE8->AE8_DESCRI   } ,{}  ,CLR_MAGENTA,	    })
				cRecurso := aItvls[nx,1]
				nLenRec	:=	 Max(nLenRec,Len(Alltrim(cRecurso))*3.7)
				aAdd(aConcat,{})
			EndIf
			aAdd(aConCat[Len(aConcat)],{ DTOS(dIniDItvl) + cIniHItvl , DTOS(aItvls[nx,4])+aItvls[nx,5] ,aItvls[nx,1],aItvls[nx,6],})

			aAdd(aGantt[Len(aGantt),2],{ aItvls[nx,2] ;	// start
			,aItvls[nx,3] ;			// ini
			,aItvls[nx,4] ;			//finish
			,aItvls[nx,5] ;			//fim
			,"" ; 						// texto
			,NIL                          ;
			,NIL                          ;
			,1                            ;
			,CLR_GREEN                    ;
			} )

		Endif
	Next
	If aConfig[5]==1
		If Len(aConcat) > 0
			aRet := InterSecRec(aConcat)
		Endif
		//Verifica qual e a alocacao dos recusros da tarefa (pega a minima entre eles)
		nAloc	:=	0
		For nX := 1 TO Len(aCols)
			nAloc	:=	If(!aCols[nX][Len(aCols[nX])].And.aCols[nX][nPosAloc] < nAloc.Or.nAloc == 0,aCols[nX][nPosAloc],nAloc)
		Next
	Else
		aRet	:=	{}
		For nX:=1	To Len(aConcat)
			For nY:=1 To Len(aConcat[nX])
				AAdd(aRet,aClone(aConcat[nX][nY]))
			Next
		Next
	Endif
	aAdd(aGantt,{ { STR0072 ,""   } ,{} ,CLR_CYAN,   }) //"Intervalos possiveis para Alocação"

	For nx := 1 to Len(aRet)
		If aConfig[5]==2
			//Verifica qual e maxima alocacao que este recurso tem nesta tarefa (soma todas as alocacoes)
			nAloc	:=	0
			For nY := 1 TO Len(aCols)
				nAloc	+=	If(aCols[nY][Len(aCols[nY])].And.aCols[nY][nPosRecurs]==aRet[nX][3],aCols[nY][nPosAloc],0)
			Next
		Endif
		//Alem de verificar se o intervalo e suficiente, verifica se a alocacao d isponivel no intervalo no periodo e suficiente para a
		//alocacao do/s recursos sendo avaliados nas horas necessarias
		nHrsInt	:=	PmsHrsItvl(STOD(Substr(aRet[nx,1],1,8)),Substr(aRet[nx,1],9,5),STOD(Substr(aRet[nx,2],1,8)),Substr(aRet[nx,2],9,5),M->AF9_CALEND,M->AF9_PROJET)
		If nHrsInt*Iif(aRet[nX][4]==0,100,aRet[nX][4]) >= nTmpDurac * nAloc
			M->AF9_START := STOD(Substr(aRet[nx,1],1,8))
			M->AF9_HORAI := Substr(aRet[nx,1],9,5)
			If Pms203DINI(.F.)
				aAdd(aDispo,{DTOS(M->AF9_START)+M->AF9_HORAI,DTOS(M->AF9_FINISH)+M->AF9_HORAF,aRet[nX][3]})
				aAdd(aGantt[Len(aGantt),2], { STOD(Substr(aRet[nx,1],1,8)) ,Substr(aRet[nx,1],9,5) ,STOD(Substr(aRet[nx,2],1,8)),Substr(aRet[nx,2],9,5) ,Alltrim(Str(Iif(aRet[nX][4]==0,100,aRet[nX][4]))+STR0101),NIL	,NIL ,3,Nil})		 //"% disponivel"
			EndIf
		EndIf
	Next
	M->AF9_START := dSavStart
	M->AF9_HORAI := cSavHoraIni
	If (aConfig[5]==2) .And. !Empty(aDispo)
		aSort(aDispo,,,{|x,y| x[1]<y[1]})  //orden por data de inicio
		aRecs		:=	{aDispo[1][3]}
		//Procura todos os recursos com dispo imediata
		For nX := 2	To Len(aDispo)
			If aDispo[nX][1]==aDispo[1][1]
				Aadd(aRecs,aDispo[nX][3])
			Endif
		Next
		//Carrega no aRetAval, todos os periodos dos recursos que comecam na mesma datado sugerido
		aRetAval	:=	{}
		For nX:=1 To Len(aRet)
			If aRet[nX][1]	==	aDispo[1][1] .And. Ascan(aRecs,{|x| x==aRet[nX][3]})   > 0
				AAdd(aRetAval,aClone(aRet[nX]))
			Endif
		Next
		//Procura a menor disponibilidade dos recursos con dispo imediata
		For nX:=1 To Len(aRetAval)
			If nX == 1 .Or. nDiff1 >	Val(StrTran(aRetAval[nX][2],":",""))- Val(StrTran(aRetAval[nX][1],":",""))
				nDIff1	:= Val(StrTran(aRetAval[nX][2],":",""))- Val(StrTran(aRetAval[nX][1],":",""))
				cRecurso	:=aRetAval[nX][3]
			Endif
		Next
		nPosDispo	:=	Ascan(aDispo,{|x| cRecurso==x[3] })
		If nPosDispo <> 1
			aBkp				:=	aClone(aDispo[1])
			aDispo[1]		:= aClone(aDispo[nPosDispo])
			aDispo[nPosDispo]:= aClone(aBkp)
		Endif
	Endif
	If !Empty(aDispo)
		aAdd(aGantt,{ { STR0073+" ("+Alltrim(aDispo[1,3])+")","" } ,{} ,CLR_BLUE,   }) //"Intervalo selecionado"
	Else
		aAdd(aGantt,{ { STR0073,"" } ,{} ,CLR_BLUE,   }) //"Intervalo selecionado"
	Endif

	If !Empty(aDispo)
		nRet := 1
		aAdd(aGantt[Len(aGantt),2], { STOD(Substr(aDispo[1,1],1,8)) ,Substr(aDispo[1,1],9,5) ,STOD(Substr(aDispo[1,2],1,8)) ,Substr(aDispo[1,2],9,5) ,"",NIL	,NIL ,1,Nil})

		DEFINE MSDIALOG oDlg TITLE STR0074 OF oMainWnd PIXEL FROM 1,1 TO 480,780 //"Assistente de Disponibilidade dos Recursos"
		oDlg:lMaximized := .F.

		If !lFWGetVersao .or. GetVersao(.F.) == "P10"

			DEFINE BUTTONBAR oBar SIZE 25,35 3D TOP OF oDlg

			@ 1000 ,38 BUTTON "" SIZE 35,12 ACTION {|| Nil } OF oDlg PIXEL

			// Retroceder
			oBtn := TBtnBmp():NewBar(BMP_RETROCEDER_CAL, BMP_RETROCEDER_CAL,,, TIP_RETROCEDER_CAL , {|| ( nRet:=Max(1,nRet-1) ,aGantt[Len(aGantt),2,1]:= { STOD(Substr(aDispo[nRet,1],1,8)) ,Substr(aDispo[nRet,1],9,5) ,STOD(Substr(aDispo[nRet,2],1,8)) ,Substr(aDispo[nRet,2],9,5) ,"",NIL	,NIL ,1,CLR_GREEN};
			,PmsPrvGnt(cVersao,@oDlg,aCfgGnt,@dCfgIni,aGantt,@aCfgGnt,@nTsk) ;
			,Eval(bRfshGantt) ;
			) },.T.,oBar,,,TIP_RETROCEDER_CAL)
			If SetMdiChild()
				oBtn:cTitle := TOOL_RETROCEDER_CAL
			EndIf

			// Avancar
			oBtn := TBtnBmp():NewBar(BMP_AVANCAR_CAL, BMP_AVANCAR_CAL,,, TIP_AVANCAR_CAL , {|| ( nRet:=Min(Len(aDispo),nRet+1), aGantt[Len(aGantt),2,1]:= { STOD(Substr(aDispo[nRet,1],1,8)) ,Substr(aDispo[nRet,1],9,5) ,STOD(Substr(aDispo[nRet,2],1,8)) ,Substr(aDispo[nRet,2],9,5) ,"",NIL	,NIL ,1,CLR_GREEN};
			,PmsNxtGnt(cVersao,@oDlg,aCfgGnt,@dCfgIni,aGantt,@nTsk) ;
			,Eval(bRfshGantt) ) },.T.,oBar,,,TIP_AVANCAR_CAL)
			If SetMdiChild()
				oBtn:cTitle := TOOL_AVANCAR_CAL
			EndIf

			// OK
			oBtn := TBtnBmp():NewBar( BMP_OK,BMP_OK,,,STR0042+" < Ctrl-O >", {|| (lConfirma:=.T.,oDlg:End()) },.T.,oBar,,,STR0042 + " < Ctrl-O >") //"OK"###"OK"###"Ok"###"Ok"
			If SetMdiChild()
				oBtn:cTitle := STR0042 //"Ok"
			EndIf

			// cancelar
			oBtn := TBtnBmp():NewBar(BMP_CANCEL, BMP_CANCEL,,, TIP_CANCEL +" < Ctrl-X >", {|| (lLoop := .F.,oDlg:End()) },.T.,oBar,,,TIP_CANCEL+" < Ctrl-X >")
			If SetMdiChild()
				oBtn:cTitle := TOOL_CANCEL
			EndIf

		Else
			AADD(aButtons, {BMP_RETROCEDER_CAL	, {|| ( nRet:=Max(1,nRet-1) 			,aGantt[Len(aGantt),2,1]:= { STOD(Substr(aDispo[nRet,1],1,8)) ,Substr(aDispo[nRet,1],9,5) ,STOD(Substr(aDispo[nRet,2],1,8)) ,Substr(aDispo[nRet,2],9,5) ,"" ,NIL ,NIL ,1,CLR_GREEN} ,PmsPrvGnt(cVersao,@oDlg,aCfgGnt,@dCfgIni,aGantt,@aCfgGnt,@nTsk),Eval(bRfshGantt) ) }, TIP_RETROCEDER_CAL})
			AADD(aButtons, {BMP_AVANCAR_CAL		, {|| ( nRet:=Min(Len(aDispo),nRet+1)	,aGantt[Len(aGantt),2,1]:= { STOD(Substr(aDispo[nRet,1],1,8)) ,Substr(aDispo[nRet,1],9,5) ,STOD(Substr(aDispo[nRet,2],1,8)) ,Substr(aDispo[nRet,2],9,5) ,"" ,NIL ,NIL ,1,CLR_GREEN} ,PmsNxtGnt(cVersao,@oDlg,aCfgGnt,@dCfgIni,aGantt,@nTsk)			,Eval(bRfshGantt) ) }, TIP_AVANCAR_CAL })
			EnchoiceBar(oDlg,{|| (lConfirma:=.T.,oDlg:End()) },{|| (lLoop := .F.,oDlg:End()) },,aButtons,,,,,.F.)
		EndIf

		PmsGantt(aGantt,aCfgGnt,@dCfgIni,,oDlg,{14,1,(nBottom/2)-40,(nRight/2)-4},{{STR0075,nLenRec},{STR0076,105}},@nTsk,,STR0077) //"Codigo"###"Nome"###"Grafico de Disponibilidades"

		ACTIVATE MSDIALOG oDlg CENTERED

	Else
		Aviso(STR0080,STR0081,{STR0061},2) //"Livre para alocacao"##"Os recursos selecionados nao possuem alocacäo no periodo solicitado. "
	EndIf

	If lConfirma
		M->AF9_START := aGantt[Len(aGantt),2,1,1]
		M->AF9_HORAI := aGantt[Len(aGantt),2,1,2]
		If aConfig[5]==2
			For nz := 1 To len(aCols)
				If nz == 1
					aCols[1][nPosRecurs]	:=	aDispo[1][3]
					aCols[1][nPosDescRec]:=	Posicione("AE8",1,xFilial('AE8')+aDispo[1][3],"AE8_DESCRI")
					aCols[1][nPosDtNec ]	:=	M->AF9_START
				Else
					aCols[nz][Len(aCols[nz])] := .T.
				EndIf
			Next nz
		Endif
		If !Pms203DINI(!IsAuto())
			M->AF9_START := dSavStart
			M->AF9_HORAI := cSavHoraIni
		EndIf
	EndIf

EndIf
RestArea(aAreaAF8)
RestArea(aArea)
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³InterSecRec ºAutor ³                   º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InterSecRec(aDados)
Local nX	:= 0, nY := 0
Local aDispo	:=	{}

/*Aadd(aDados,	{{'01','03'},{'07','08'},{'10','12'}})
Aadd(aDados,	{{'02','03'},{'07','08'},{'11','12'}} )
Aadd(aDados,	{{'01','02'},{'08','09'},{'11','12'}}
*/
//Unica intersecao é entre 11 e 12

aInter	:=	aDados[1]
nRec	:=	2
While Len(aInter) >0 .And. nRec <= Len(aDados)
	aInterTmp :=	{}
	For nX := 1 To Len(aInter)
		For nY:=	1 To Len(aDados[nRec])
			Compara(aInter[nX],aDados[nRec][nY],@aInterTmp)
		Next nY
	Next nX
	nRec++
	aInter	:=	aClone(aInterTmp)
EndDo
For nX := 1 To Len(aInter)
	If aInter[nX][2]>aInter[nX][1]
		Aadd(aDispo,aInter[nX])
	Endif
Next nX

Return aDispo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Compara     ºAutor ³                   º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Compara(aDad1,aDad2,aDispo)
	If	(	Entre(aDad2[1],aDad2[2],aDad1[1]) .Or. Entre(aDad2[1],aDad2[2],aDad1[2]) .Or.; 		//Segunda comeca o termina dentro da primeira
		Entre(aDad1[1],aDad1[2],aDad2[1]) .Or. Entre(aDad1[1],aDad1[2],aDad2[2]) )		//Primeira comeca o termina dentro da segunda
		AAdd(aDispo,{MaxStr(aDad1[1],aDad2[1]), MinStr(aDad1[2],aDad2[2]),aDad2[3],aDad2[4]})
	Endif
Return aDispo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Entre       ºAutor ³                   º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Entre(x1,x2,xValor)
Local xTmp	:=	x1
If x1 > x2
	x1 :=	x2
	x2	:= xTmp
Endif
Return (xValor>= x1 .And. xValor <=x2)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MaxStr      ºAutor ³                   º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MaxStr(cStr1,cStr2)
Local cRet	:=	cStr1
If cStr2 > cStr1
	cRet	:=	cStr2
Endif
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MinStr      ºAutor ³                   º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MinStr(cStr1,cStr2)
Local cRet	:=	cStr1
If cStr2 < cStr1
	cRet	:=	cStr2
Endif
Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IsAuto    ºAutor  ³Bruno Sobieski      º Data ³  04-25-05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se estamos dentro da MsExecAuto                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA203                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IsAuto()
Return Type("lPMS203Auto") == "L" .And. lPMS203Auto
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidAuto ºAutor  ³Adriano Ueda        º Data ³  04-25-05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Forcar a validacao da rotina automatica em cada HEADER      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA203                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidAuto(aHead, nPos, cValid)
Local i := 1

For i := 1 To Len(aHead)
	If Empty(aHead[i][nPos])
		aHead[i][nPos] := cValid
	Else
		aHead[i][nPos] :=  AllTrim(aHead[i][nPos])+ " .And. " +cValid
	EndIf
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A203RecursºAutor  ³Bruno Sobieski      º Data ³  04-25-05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chama a rotina que mostra a disponiblidade da equipe        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA203                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A203Recursos(aRecursos,nOpcao)
Local cEquipe	 := ""
Local nPosRec    := 0
Local nX		 := 0
Local aRecTar	 := {}
Local aArea		 := GetArea()
Local aAreaAF8	 := AF8->(GetArea())
Local nPosFldREC := FolderOrd(STR0040)//'Aloc. Recursos'

If ExistBLock('PMA203EQ')
	cEquipe	:=	ExecBLock('PMA203EQ',.F.,.F.)
Else
	cEquipe	:=	Posicione("AE8",3,xFilial()+__cUserID,"AE8_EQUIP")
Endif
If nOpcao == 1 //Por equipe
	PMSC112(,,cEquipe)
Else
	If nPosFldREC >0
		nPosRec   := aScan(aHeaderSV[nPosFldREC],{|x| AllTrim(x[2])=="AFA_RECURS"})
		//Para todos os recursos da tarefa
		For nX :=1 To Len(aColsSV[nPosFldREC])
			If !Empty(aColsSV[nPosFldREC][nX][nPosRec]) .And. !aColsSV[nPosFldREC][nX][Len(aColsSV[nPosFldREC][nX])]
				AAdd(aRecTar,aColsSV[nPosFldREC][nX][nPosRec])
			Endif
		Next
		If Len(aRecTar) > 0
			PMSC110(M->AF9_PROJET,M->AF9_REVISA,,,,,aRecTar)
		Endif
	Endif
Endif
RestArea(aAreaAF8)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A203SimulaºAutor  ³Bruno Sobieski      º Data ³  04-25-05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chama a rotina de simulacao, que ira mostrar o impacto da   º±±
±±º          ³modificacao da tarefa atual na alocacao do recurso.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA203                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A203Simulacao()
Local nPosRec  := aScan(aHeaderSV[5],{|x| AllTrim(x[2])=="AFA_RECURS"})
Local nPosAloc := aScan(aHeaderSV[5],{|x| AllTrim(x[2])=="AFA_ALOC" })
Local nPosTipo	:=	aScan(aHeaderSV[3],{|x| AllTrim(x[2])=="AFD_TIPO"})
Local nPosPred	:=	aScan(aHeaderSV[3],{|x| AllTrim(x[2])=="AFD_PREDEC"})
Local nPosHRet	:=	aScan(aHeaderSV[3],{|x| AllTrim(x[2])=="AFD_HRETAR"})
Local nX := 1
Local nY := 1
Local aRecAval	:=	{}
Local aArea		:= GetArea()
Local aAreaAF8	:= AF8->(GetArea())
Local aParam	:= {AF8->AF8_START,AF8->AF8_FINISH,'','',Val(AF8->AF8_PRIREA),,,.T.}
Local aParam2	:= {}
Local aDadosSim :={}
Local nPosFldREC := FolderOrd(STR0040) //'Aloc. Recursos'
Local nPosFldAFD := FolderOrd(STR0062) // 'Relac.Tarefas'
Local aCombo	:= {STR0104,STR0105} //Data+Prioridade", "Proridade+Data
Local aAux
Local lPMSRDSIM	:= ExistBlock("PMSRDSIM")

Private oProcess

If nPosFldREC>0 .AND. nPosFldAFD>0
	nPosRec  := aScan(aHeaderSV[nPosFldREC],{|x| AllTrim(x[2])=="AFA_RECURS"})
	nPosAloc := aScan(aHeaderSV[nPosFldREC],{|x| AllTrim(x[2])=="AFA_ALOC" })
	nPosTipo :=	aScan(aHeaderSV[nPosFldAFD],{|x| AllTrim(x[2])=="AFD_TIPO"})
	nPosPred :=	aScan(aHeaderSV[nPosFldAFD],{|x| AllTrim(x[2])=="AFD_PREDEC"})
	nPosHRet :=	aScan(aHeaderSV[nPosFldAFD],{|x| AllTrim(x[2])=="AFD_HRETAR"})

	For nX:=1	To Len(aColsSV[nPosFldREC])
		If !Empty(aColsSV[nPosFldREC][nX][nPosRec]) .And. !aColsSV[nPosFldREC][nX][Len(aColsSV[nPosFldREC][nX])]
			If lPMSRDSIM
				aAux := ExecBlock("PMSRDSIM",.F.,.F.,{ACLONE(aHeaderSV[nPosFldREC]), ACLONE(aColsSV[nPosFldREC][nX])})
			Else
				aAux := {}
			EndIf
			AAdd(aRecAval ,aColsSV[nPosFldREC][nX][nPosRec ])
			AAdd(aDadosSim ,Array(SIM_QTDELEM))
			aDadosSim[Len(aDadosSim)][SIM_RECAF9  ]:=	IIf(INCLUI,0,AF9->(Recno()))
			aDadosSim[Len(aDadosSim)][SIM_START	  ]:=	M->AF9_START
			aDadosSim[Len(aDadosSim)][SIM_HORAI   ]:= 	M->AF9_HORAI
			aDadosSim[Len(aDadosSim)][SIM_FINISH  ]:= 	M->AF9_FINISH
			aDadosSim[Len(aDadosSim)][SIM_HORAF   ]:= 	M->AF9_HORAF
			aDadosSim[Len(aDadosSim)][SIM_REVISA  ]:= 	M->AF9_REVISA
			aDadosSim[Len(aDadosSim)][SIM_RECURS  ]:= 	aColsSV[5][nX][nPosRec]
			aDadosSim[Len(aDadosSim)][SIM_ALOC    ]:= 	aColsSV[5][nX][nPosAloc]
			aDadosSim[Len(aDadosSim)][SIM_PRIORI  ]:= 	M->AF9_PRIORI
			aDadosSim[Len(aDadosSim)][SIM_HDURAC  ]:= 	M->AF9_HDURAC
			aDadosSim[Len(aDadosSim)][SIM_QUANT   ]:= 	M->AF9_QUANT
			aDadosSim[Len(aDadosSim)][SIM_PROJETO ]:=	M->AF9_PROJET
			aDadosSim[Len(aDadosSim)][SIM_TAREFA  ]:=	M->AF9_TAREFA
			aDadosSim[Len(aDadosSim)][SIM_CALEND  ]:=	M->AF9_CALEND
			aDadosSim[Len(aDadosSim)][SIM_DESCRI  ]:=	M->AF9_DESCRI
			aDadosSim[Len(aDadosSim)][SIM_PREDEC  ]:=	{}
			aDadosSim[Len(aDadosSim)][SIM_USERINFO]:=	aAux
			For nY	:=	1	To Len(aColsSV[nPosFldAFD])
				If !Empty(aColsSV[nPosFldAFD][nY][nPosPred]) .And. !aColsSV[nPosFldAFD][nY][Len(aColsSV[nPosFldAFD][nY])]
					AAdd(aDadosSim[Len(aDadosSim)][SIM_PREDEC],{aColsSV[nPosFldAFD][nY][nPosTipo],aColsSV[nPosFldAFD][nY][nPosPred],aColsSV[nPosFldAFD][nY][nPosHRet]})
				Endif
			Next
		Endif
	Next nX
	If ExistBLock('PMA203SI')
		aDadosSim :=	ExecBLock('PMA203SI',.F.,.F.,{aDadosSim})
	Endif
EndIf

If Len(aDadosSim) > 0

	If ExistBlock("PMSRDORD")
		aAux:=ExecBlock("PMSRDORD",.F.,.F.)
		If valtype(aAux)=='A'
			For nX:=1 to len(aAux)
				If valtype(aAux[nX])=='C'
					AADD(aCombo,aAux[nX])
				Else
					AADD(aCombo,' ')
				EndIf
			Next nX
		EndIf
	EndIf

	If ParamBox( {	{ 1 ,STR0090 	,AF8->AF8_START					,"@!" 	 ,""  ,""    ,"" ,50 ,.T. } ; //"Data de" //"Data de"
		,	{ 1 ,STR0091	,AF8->AF8_FINISH				  	,"@!" 	 ,""  ,""    ,"" ,50 ,.T. };  //"Data ate" //"Data ate"
		,	{ 2 ,STR0092	,aParam[5]  			      	, aCombo ,120 ,""    ,.T.         };  //"Ordem por " //"Ordem Por
		,{5, STR0119, AF8->AF8_REAFIX=="1", 160,,.F.}; //"Fixar datas previstas das tarefas em execução"
		}            ;
		,STR0095 ; //"Parametros"
		,@aParam2 )
		aParam[1]	:=	aParam2[1]
		aParam[2]	:=	aParam2[2]
		aParam[5]	:=	aParam2[3]
		aParam[8]   := aParam2[4]
		oProcess	:=	MsNewProcess():New({|| AuxRedistRec( aParam ,M->AF9_PROJET ,M->AF9_REVISA,.T. ,aRecAval,aDadosSim)})
		oProcess:Activate()
	Endif
Else
	Aviso(STR0014,STR0102,{STR0061},2) //"Nao foram informados recursos para esta tarefa."
Endif
RestArea(aAreaAF8)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS203Vis³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ³±±
±±³          ³ de Tarefas de Projetos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS203Vis(aHeaderSV,aColsSV,lDados,lTrava,lAltOuExc)
Local nX,nY
Local aHeadProd := {}
Local aHeadRecr := {}
Local aHeadInsu := {}
Local nPosDesp, nPosRTar, nPosEvnt, nPosCron, nPosREDT, nPosProd, nPosAloc, nPosSubC, nPosInsm, nPosTrib
Local lContinua	:= .T.
Local lAF8ComAJT
Local nPCusto 	:= 0
Local nPCustI 	:= 0
Local nPQuant 	:= 0
Local nLen	  	:= 0

Default lDados	  := .T.
Default lTrava	  := .F.
Default lAltOuExc := .F.

// Usa template?
lAF8ComAJT:=AF8ComAJT(AF8->AF8_PROJET)

// Definicao da posicao das abas
nPosProd := FolderOrd(STR0039)
nPosDesp := FolderOrd(STR0009)
nPosRTar := FolderOrd(STR0062)
nPosEvnt := FolderOrd(STR0038)
nPosAloc := FolderOrd(STR0040)
nPosCron := FolderOrd(STR0051)
nPosREDT := FolderOrd(STR0063)
nPosInsm := FolderOrd(STR0129)
nPosSubC := FolderOrd(STR0130)

If AF8->AF8_PAR006 == '1'
	nPosTrib := FolderOrd(STR0183) //"Tributos"
EndIf

If aHeaderTar == Nil .Or. Len(aHeaderTar) < 8 //7

	aHeaderTar	:=	{}

    // Montagem dos aHeaders comuns entre o padrao e o CCT
	If nPosTrib == 8
   		// Montagem do aHeaderAN9 ( Tributos )
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AN9")
		While !EOF() .And. (x3_arquivo == "AN9")
			If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And.;
				(AllTrim(X3_CAMPO)$"AN9_CODIMP,AN9_PERC,AN9_VALIMP")
				AADD(aHeaderSV[nPosTrib],{ TRIM(x3titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_arquivo,x3_context } )
			EndIf
			dbSkip()
		End
	EndIf

	// Montagem do aHeaderAFB ( Despesas )
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AFB")
	While !EOF() .And. (x3_arquivo == "AFB")
		If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And.;
			!(AllTrim(X3_CAMPO)$"AFB_RECURS,AFB_ALOC,AFB_START,AFB_HORAI,AFB_FINISH,AFB_HORAF,AFB_REVISA")
			AADD(aHeaderSV[nPosDesp],{ TRIM(x3titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_f3,x3_context } )
		EndIf
		dbSkip()
	End

	// Montagem do aHeaderAFD ( Relac Tarefas )
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AFD")
	While !EOF() .And. (x3_arquivo == "AFD")
		If X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderSV[nPosRTar],{ TRIM(x3titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_f3,x3_context } )
		EndIf
		dbSkip()
	End

	// Montagem do aHeaderAFP ( Eventos )
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AFP")
	While !EOF() .And. (x3_arquivo == "AFP")
		If X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderSV[nPosEvnt],{ TRIM(x3titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_f3,x3_context } )
		EndIf
		dbSkip()
	End

	// Montagem do aHeaderAFZ ( Cronograma Previsto )
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("AFZ_PERC")
	Do Case
		Case AF8->AF8_TPPERI == "2"
			dIni := AF8->AF8_INIPER
			If DOW(AF8->AF8_INIPER)<>1
				dIni -= DOW(AF8->AF8_INIPER)-1
			EndIf
		Case AF8->AF8_TPPERI == "3"
			dIni	:= CTOD("01/"+StrZero(MONTH(AF8->AF8_INIPER),2,0)+"/"+StrZero(YEAR(AF8->AF8_INIPER),4,0))
		Case AF8->AF8_TPPERI == "4"
			dIni	:= CTOD("01/"+StrZero(MONTH(AF8->AF8_INIPER),2,0)+"/"+StrZero(YEAR(AF8->AF8_INIPER),4,0))
		OtherWise
			dIni	:= AF8->AF8_INIPER
	EndCase
	dx := dIni
	While dx < AF8->AF8_FIMPER
		AADD(aHeaderSV[nPosCron],{ DTOC(dx), Alltrim(x3_campo) , "@E 99,999.99%", x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_f3,x3_context } )
		Do Case
			Case AF8->AF8_TPPERI == "2"
				dx += 7
			Case AF8->AF8_TPPERI == "3"
				If DAY(dx) == 01
					dx	:= CTOD("15/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
				Else
					dx += 35
					dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
				EndIf
			Case AF8->AF8_TPPERI == "4"
				dx += 35
				dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
			OtherWise
				dx += 1
		EndCase
	End

	// Montagem do aHeader AJ4
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AJ4")
	While !EOF() .And. (x3_arquivo == "AJ4")
		If X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderSV[nPosREDT],{ TRIM(x3titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_f3,x3_context } )
		EndIf
		dbSkip()
	End

    // Diferenciacao dos aHeaders do padrao e do CCT

    If !lAF8ComAJT

	    // Montagem dos aHeaders do Padrao

		// Montagem do aHeaderAFA ( Produtos )

		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AFA")
		While !EOF() .And. (x3_arquivo == "AFA")
			If X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .And.;
				!(AllTrim(X3_CAMPO)$"AFA_RECURS,AFA_ALOC,AFA_START,AFA_HORAI,AFA_FINISH,AFA_HORAF,AFA_FIX")
				AADD(aHeadProd,X3_CAMPO)
			Endif
			dbSkip()
		End
		If ExistBlock("PMA203PD") // Ponto de entrada para selecao de campos
			aHeadProd	:=	ExecBlock("PMA203PD",.F.,.F.,{aHeadProd})
		EndIf

		dbSelectArea("SX3")
		dbSetOrder(2)
		For nX := 1 to Len(aHeadProd)
			If SX3->(dbSeek(aHeadProd[nX]))
				AADD(aHeaderSV[nPosProd],{ TRIM(x3titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_f3,x3_context } )
			EndIf
		Next nX

		If ExistBlock("PMA203AC") .And. ExistBlock("PMA203PD")
			// Ponto de entrada para ordenacao dos campos
			aTempSV := ExecBlock("PMA203AC",.F.,.F.,{aHeaderSV[nPosProd]})
			If ValType(aTempSV) == "A"
				aHeaderSV[nPosProd] := aClone(aTempSV)
				aTempSV := {}
			Else
				Alert(STR0128 + "'PMA203AC'")
			EndIf
		EndIf

		// montagem do aHeaderAFA-2
		aTmpSV5	:= {"AFA_ITEM"  , "AFA_RECURS",	"AFA_QUANT" , "AFA_ALOC"  , "AFA_FIX"   , "AFA_RESP"  , "AFA_PRODUT",;
					"AFA_DESCRI", "AFA_MOEDA" ,	"AFA_SIMBMO", "AFA_CUSTD" , "AFA_SEGUM" , "AFA_QTSEGU", "AFA_DATPRF", "AFA_ACUMUL"}

		If ExistBlock("PMA203Rc") // Permite a inclusao de campos na pasta de alocacao de recursos
			aTmpSV5 := ExecBlock("PMA203Rc", .T., .T., {aTmpSV5})
		EndIf

		aTmp2SV5 := {"AFA_FILIAL", "AFA_PROJET", "AFA_REVISA", "AFA_TAREFA", "AFA_TIPO"  , "AFA_UM"    , "AFA_START" ,;
					 "AFA_HORAI" , "AFA_FINISH", "AFA_HORAF" , "AFA_COMPOS", "AFA_PLANEJ", "AFA_PADSAL", "AFA_AQUISI",;
					 "AFA_COEFMA", "AFA_COMBUS", "AFA_DEPREC", "AFA_HORANO", "AFA_JUROS" , "AFA_MANUT" , "AFA_MATERI",;
					 "AFA_MDO"   , "AFA_POTENC", "AFA_RESIDU", "AFA_VALCOM", "AFA_VIDAUT", "AFA_DMTX"  , "AFA_CAPM3" ,;
					 "AFA_VELO"  , "AFA_TCDM"  , "AFA_TPERC" , "AFA_TPTOT", "AFA_PHM3"   , "AFA_CSTUNI", "AFA_MT"    ,;
					 "AFA_EMPOLA", "AFA_RECPAI", "AFA_GRPREC"};

		dbSelectArea("SX3")
		dbSetOrder(2)
		For nx := 1 to Len(aTmpSV5)
			SX3->(DbSetOrder(2))
			If SX3->(dbSeek(aTmpSV5[nx]))
				IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
					AADD(aHeadRecr,X3_CAMPO )
				EndIf
			EndIf
		Next

		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AFA")
		While !EOF() .And. (X3_ARQUIVO == "AFA")
			IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
				AScan(aTmp2SV5, { |x| Upper(AllTrim(x)) == Upper(AllTrim(X3_CAMPO))}) == 0 .And. ;
				AScan(aTmpSV5,  { |x| Upper(AllTrim(x)) == Upper(AllTrim(X3_CAMPO))}) == 0
				AADD(aHeadRecr,X3_CAMPO )
			Endif
			dbSkip()
		End

		If ExistBlock("PMA203RE") // Customizacao dos campos que serao exibidos na pasta recursos
			aHeadRecr	:=	ExecBlock("PMA203RE",.F.,.F.,{aHeadRecr})
		EndIf

		dbSelectArea("SX3")
		dbSetOrder(2)
		For nX := 1 to Len(aHeadRecr)
			If SX3->(dbSeek(aHeadRecr[nX]))
				AADD(aHeaderSV[nPosAloc],{ TRIM(x3titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_f3,x3_context } )
			EndIf
		Next nX

		If ExistBlock("PMA203AC") .And. ExistBlock("PMA203RE")
			// Ponto de entrada para ordenacao dos campos
			aTempSV := ExecBlock("PMA203AC",.F.,.F.,{aHeaderSV[nPosAloc]})
			If ValType(aTempSV) == "A"
				aHeaderSV[nPosAloc] := aClone(aTempSV)
				aTempSV := {}
			Else
				Alert(STR0128 + "'PMA203AC'")
			EndIf
		EndIf

	    // Fim dos aHeaders do Padrao

    Else

	    // Montagem dos aHeaders do CCT

		// Montagem do aHeaderAEL ( Insumos )
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AEL")
		While !EOF() .And. (x3_arquivo == "AEL")
			If X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .And.;
				!(AllTrim(X3_CAMPO)$"AEL_PRODFA")
				AADD(aHeadInsu,X3_CAMPO)
			Endif
			dbSkip()
		End
		If ExistBlock("PMA203NS") // Ponto de entrada para selecao e ordenacao dos campos
			aHeadInsu	:=	ExecBlock("PMA203NS",.F.,.F.,{aHeadInsu})
		EndIf

		dbSelectArea("SX3")
		dbSetOrder(2)
		For nX := 1 to Len(aHeadInsu)
			If SX3->(dbSeek(aHeadInsu[nX]))
				AADD(aHeaderSV[nPosInsm],{ TRIM(x3titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_f3,x3_context } )
			EndIf
		Next nX

		// Montagem do aHeaderAEN ( Subcomposicoes )
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AEN")
		While !EOF() .And. (x3_arquivo == "AEN")
			If X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL
				AADD(aHeaderSV[nPosSubC],{ TRIM(x3titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_f3,x3_context } )
			Endif
			dbSkip()
		End

	    // Fim dos aHeaders do CCT

    EndIf

	AAdd(aHeaderTar,aHeaderSV[1])
	AAdd(aHeaderTar,aHeaderSV[2])
	AAdd(aHeaderTar,aHeaderSV[3])
	AAdd(aHeaderTar,aHeaderSV[4])
	AAdd(aHeaderTar,aHeaderSV[5])
	AAdd(aHeaderTar,aHeaderSV[6])
	AAdd(aHeaderTar,aHeaderSV[7])
	If nPosTrib == 8 .AND. Len(aHeaderSV) == 8
		AAdd(aHeaderTar,aHeaderSV[8])
	EndIf

Else
	aHeaderSV:=	aClone(aHeaderTar)
Endif

	// Existe a pasta tributos(Tabela AN9)
	If nPosTrib == 8
		cNomArqAN9 := A203GetWKAN9()
		// Faz a montagem do aColsAN9 ( Tributos )
		A203aColsAN9(aHeaderSV,aColsSV,lDados,lTrava,lAltOuExc)
	EndIf

	// Montagem dos aCols comuns entre o Padrao e o CCT

	// Faz a montagem do aColsAFB ( Despesas )
	If lDados

		aColsSV[nPosDesp]:=	{}

		dbSelectArea("AFB")
		dbSetOrder(1)
		dbSeek(xFilial() + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA)
		While !Eof() .And. AFB->AFB_FILIAL + AFB->AFB_PROJET + AFB->AFB_REVISA + AFB->AFB_TAREFA ==;
			xFilial("AFB") + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA .And. lContinua

			// Trava o registro do AFB - Alteracao,Exclusao
			If lTrava .And. lAltOuExc
				If !SoftLock("AFB")
					lContinua := .F.
				Else
					aAdd(aRecAFB,RecNo())
				Endif
			EndIf
			aADD(aColsSV[nPosDesp],Array(Len(aHeaderSV[2])+1))
			For ny := 1 to Len(aHeaderSV[nPosDesp])
				SX5->(dbSetOrder(1))
				SX5->(dbSeek(xFilial()+"FD" + AFB->AFB_TIPOD))
				If ( aHeaderSV[nPosDesp][ny][10] != "V")
					aColsSV[nPosDesp][Len(aColsSV[nPosDesp])][ny] := FieldGet(FieldPos(aHeaderSV[nPosDesp][ny][2]))
				Else
					Do Case
						Case Alltrim(aHeaderSV[nPosDesp][ny][2]) == "AFB_DESCTP"
							aColsSV[nPosDesp][Len(aColsSV[nPosDesp])][ny] := X5DESCRI()

						Case Alltrim(aHeaderSV[nPosDesp][ny][2]) == "AFB_SIMBMO"
							aColsSV[nPosDesp][Len(aColsSV[nPosDesp])][ny] := SuperGetMv("MV_SIMB"+Alltrim(STR(AFB->AFB_MOEDA,2,0)))

						OtherWise
							aColsSV[nPosDesp][Len(aColsSV[nPosDesp])][ny] := CriaVar(aHeaderSV[nPosDesp][ny][2])
					EndCase
				EndIf
				aColsSV[nPosDesp][Len(aColsSV[nPosDesp])][Len(aHeaderSV[nPosDesp])+1] := .F.
			Next ny
			dbSkip()
		EndDo
	EndIf

	// Faz a montagem de uma linha em branco no aColsAFB
	If Empty(aColsSV[nPosDesp])
		aadd(aColsSV[nPosDesp],Array(Len(aHeaderSV[nPosDesp])+1))
		For ny := 1 to Len(aHeaderSV[nPosDesp])
			If Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_ITEM"
				aColsSV[nPosDesp][1][ny] 	:= "01"
			Else
				aColsSV[nPosDesp][1][ny] := CriaVar(aHeaderSV[nPosDesp][ny][2])
			EndIf
			aColsSV[nPosDesp][1][Len(aHeaderSV[nPosDesp])+1] := .F.
		Next ny
	EndIf


	// Faz a montagem do aColsAFD ( Relac Tarefas )
	If lDados

		aColsSV[nPosRTar]:=	{}

		dbSelectArea("AFD")
		dbSetOrder(1)
		dbSeek(xFilial("AFD") + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA)
		While !Eof() .And. AFD->AFD_FILIAL + AFD->AFD_PROJET + AFD->AFD_REVISA + AFD->AFD_TAREFA ==;
			xFilial("AFD") + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA .And. lContinua
			aAuxArea := AF9->(GetArea())
			AF9->(dbSetOrder(1))
			AF9->(dbSeek(xFilial() + AFD->AFD_PROJET + AFD->AFD_REVISA + AFD->AFD_PREDEC)) // Verificar

			// trava o registro do AFD - Alteracao, Exclusao
			If lTrava .And. lAltOuExc
				If !SoftLock("AFD")
					lContinua := .F.
				Else
					aAdd(aRecAFD,RecNo())
				Endif
			EndIf
			aADD(aColsSV[nPosRTar],Array(Len(aHeaderSV[nPosRTar])+1))
			For ny := 1 to Len(aHeaderSV[nPosRTar])
				If ( aHeaderSV[nPosRTar][ny][10] != "V")
					aColsSV[nPosRTar][Len(aColsSV[nPosRTar])][ny] := FieldGet(FieldPos(aHeaderSV[nPosRTar][ny][2]))
				Else
					Do Case
						Case AllTrim(aHeaderSV[nPosRTar][ny][2]) == "AFD_DESCRI"
							aColsSV[nPosRTar][Len(aColsSV[nPosRTar])][ny] := AF9->AF9_DESCRI

						OtherWise
							aColsSV[nPosRTar][Len(aColsSV[nPosRTar])][ny] := CriaVar(aHeaderSV[nPosRTar][ny][2])
					EndCase
				EndIf
				aColsSV[nPosRTar][Len(aColsSV[nPosRTar])][Len(aHeaderSV[nPosRTar])+1] := .F.
			Next ny
			RestArea(aAuxArea)
			dbSelectArea("AFD")
			dbSkip()
		EndDo
	EndIf
	If Empty(aColsSV[nPosRTar])

		// Faz a montagem de uma linha em branco no aColsAFD
		aadd(aColsSV[nPosRTar],Array(Len(aHeaderSV[nPosRTar])+1))
		For ny := 1 to Len(aHeaderSV[nPosRTar])
			If Trim(aHeaderSV[nPosRTar][ny][2]) == "AFD_ITEM"
				aColsSV[nPosRTar][1][ny] 	:= "01"
			Else
				aColsSV[nPosRTar][1][ny] := CriaVar(aHeaderSV[nPosRTar][ny][2])
			EndIf
			aColsSV[nPosRTar][1][Len(aHeaderSV[nPosRTar])+1] := .F.
		Next ny

	EndIf


	// Faz a montagem do aColsAFP ( Eventos )
	If lDados

		aColsSV[nPosEvnt]:=	{}

		dbSelectArea("AFP")
		dbSetOrder(1)
		dbSeek(xFilial("AFP") + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA)
		While !Eof() .And. AFP->AFP_FILIAL + AFP->AFP_PROJET + AFP->AFP_REVISA + AFP->AFP_TAREFA ==;
			xFilial("AFP") + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA .And. lContinua

			// trava o registro do AFP - Alteracao, Exclusao
			If lTrava .And. lAltOuExc
				If ! SoftLock("AFP")
					lContinua := .F.
				Else
					aAdd(aRecAFP,RecNo())
				Endif
			EndIf
			aADD(aColsSV[nPosEvnt],Array(Len(aHeaderSV[nPosEvnt])+1))
			For ny := 1 to Len(aHeaderSV[nPosEvnt])
				If ( aHeaderSV[nPosEvnt][ny][10] != "V")
					aColsSV[nPosEvnt][Len(aColsSV[nPosEvnt])][ny] := FieldGet(FieldPos(aHeaderSV[nPosEvnt][ny][2]))
				Else
					aColsSV[nPosEvnt][Len(aColsSV[nPosEvnt])][ny] := CriaVar(aHeaderSV[nPosEvnt][ny][2])
				EndIf
				aColsSV[nPosEvnt][Len(aColsSV[nPosEvnt])][Len(aHeaderSV[nPosEvnt])+1] := .F.
			Next ny
			dbSelectArea("AFP")
			dbSkip()
		EndDo
	EndIf
	If Empty(aColsSV[nPosEvnt])

		// Faz a montagem de uma linha em branco no aColsAFP
		aadd(aColsSV[nPosEvnt],Array(Len(aHeaderSV[nPosEvnt])+1))
		For ny := 1 to Len(aHeaderSV[nPosEvnt])
			If Trim(aHeaderSV[nPosEvnt][ny][2]) == "AFP_ITEM"
				aColsSV[nPosEvnt][1][ny] 	:= "01"
			Else
				aColsSV[nPosEvnt][1][ny] := CriaVar(aHeaderSV[nPosEvnt][ny][2])
			EndIf
			aColsSV[nPosEvnt][1][Len(aHeaderSV[nPosEvnt])+1] := .F.
		Next ny
	EndIf


	// Faz a montagem do aColsAFZ ( Cronograma por periodo )

	aColsSV[nPosCron]:=	{}
	aadd(aColsSV[nPosCron],Array(Len(aHeaderSV[nPosCron])+1))
	Afill(aColsSV[nPosCron][1],0)
	aColsSV[nPosCron][1][Len(aHeaderSV[nPosCron])+1] := .F.

	If lDados

		nTotPerc := 0
		For ny := 1 to Len(aHeaderSV[nPosCron])
			AFZ->(dbSetOrder(1))
			If AFZ->(dbSeek(xFilial("AFZ") + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA + DTOS(CTOD(aHeaderSV[nPosCron][ny][1]))))
				aColsSV[nPosCron][1][ny] := AFZ->AFZ_PERC - nTotPerc
				nTotPerc := AFZ->AFZ_PERC
			Else
				aColsSV[nPosCron][1][ny] := 0
			EndIf
			aColsSV[nPosCron][1][Len(aHeaderSV[nPosCron])+1] := .F.
		Next ny

		// carrega array com os registros do AFZ da tarefa
		dbSelectArea("AFZ")
		dbSetOrder(1)
		dbSeek(xFilial("AFZ") + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA)
		While !Eof() .And. AFZ->AFZ_FILIAL + AFZ->AFZ_PROJET + AFZ_REVISA + AFZ->AFZ_TAREFA ==;
			xFilial("AFZ") + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA .And. lContinua

			// trava o registro do AFZ - Alteracao, Exclusao
			If lTrava .And. lAltOuExc
				If !SoftLock("AFZ")
					lContinua := .F.
				Else
					aAdd(aRecAFZ,RecNo())
				Endif
			EndIf
			dbSelectArea("AFZ")
			dbSkip()
		End
	Else
	//	aadd(aColsSV[nPosCron],Array(Len(aHeaderSV[nPosCron])+1))
		For ny := 1 to Len(aHeaderSV[nPosCron])
			aColsSV[nPosCron][1][ny] := CriaVar(aHeaderSV[nPosCron][ny][2])
			aColsSV[nPosCron][1][Len(aHeaderSV[nPosCron])+1] := .F.
		Next ny
	EndIf


	// Faz a montagem do aCols AJ4 ( Relac EDT )
	If lDados

		aColsSV[nPosREDT]:=	{}

		dbSelectArea("AJ4")
		dbSetOrder(1)
		dbSeek(xFilial("AJ4") + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA)
		While !Eof() .And. AJ4->AJ4_FILIAL + AJ4->AJ4_PROJET + AJ4->AJ4_REVISA + AJ4->AJ4_TAREFA ==;
			xFilial("AJ4") + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA .And. lContinua
			aAuxArea := AFC->(GetArea())
			AFC->(dbSetOrder(1))
			AFC->(dbSeek(xFilial("AFC") + AJ4->AJ4_PROJET + AJ4->AJ4_REVISA + AJ4->AJ4_PREDEC)) // Verificar

			// trava o registro do AJ4 - Alteracao, Exclusao
			If lTrava .And. lAltOuExc
				If !SoftLock("AJ4")
					lContinua := .F.
				Else
					aAdd(aRecAJ4,RecNo())
				Endif
			EndIf
			aADD(aColsSV[nPosREDT],Array(Len(aHeaderSV[nPosREDT])+1))
			For ny := 1 to Len(aHeaderSV[nPosREDT])
				If ( aHeaderSV[nPosREDT][ny][10] != "V")
					aColsSV[nPosREDT][Len(aColsSV[nPosREDT])][ny] := FieldGet(FieldPos(aHeaderSV[nPosREDT][ny][2]))
				Else
					Do Case
						Case AllTrim(aHeaderSV[nPosREDT][ny][2]) == "AJ4_DESCRI"
							aColsSV[nPosREDT][Len(aColsSV[nPosREDT])][ny] := AFC->AFC_DESCRI

						OtherWise
							aColsSV[nPosREDT][Len(aColsSV[nPosREDT])][ny] := CriaVar(aHeaderSV[nPosREDT][ny][2])
					EndCase
				EndIf
				aColsSV[nPosREDT][Len(aColsSV[nPosREDT])][Len(aHeaderSV[nPosREDT])+1] := .F.
			Next ny
			RestArea(aAuxArea)
			dbSelectArea("AJ4")
			dbSkip()
		EndDo
	EndIf

	If Empty(aColsSV[nPosREDT])

		// faz a montagem de uma linha em branco no aColsAFD
		aadd(aColsSV[nPosREDT],Array(Len(aHeaderSV[nPosREDT])+1))
		For ny := 1 to Len(aHeaderSV[nPosREDT])
			If Trim(aHeaderSV[nPosREDT][ny][2]) == "AJ4_ITEM"
				aColsSV[nPosREDT][1][ny] 	:= "01"
			Else
				aColsSV[nPosREDT][1][ny] := CriaVar(aHeaderSV[nPosREDT][ny][2])
			EndIf
			aColsSV[nPosREDT][1][Len(aHeaderSV[nPosREDT])+1] := .F.
		Next ny
	EndIf


    // Diferenciacao dos aCols do padrao e do CCT

   	If !lAF8ComAJT

		// Montagem dos aCols do Padrao

		// Faz a montagem do aColsAFA1 ( Produtos )
		If lDados

			aColsSV[nPosProd]:=	{}

			dbSelectArea("AFA")
			dbSetOrder(1)
			dbSeek(xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
			While !Eof() .And. AFA->AFA_FILIAL + AFA->AFA_PROJET + AFA_REVISA + AFA->AFA_TAREFA ==;
				xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA.And.lContinua
				If Empty(AFA->AFA_RECURS)

					// trava o registro do AFA1 - Alteracao,Exclusao
					If lTrava .And. lAltOuExc
						If !SoftLock("AFA")
							lContinua := .F.
						Else
							aAdd(aRecAFA,RecNo())
						EndIf
					EndIf
					aADD(aColsSV[nPosProd],Array(Len(aHeaderSV[nPosProd])+1))
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial()+AFA->AFA_PRODUT))
					For ny := 1 to Len(aHeaderSV[nPosProd])
						If ( aHeaderSV[nPosProd][ny][10] != "V")
							aColsSV[nPosProd][Len(aColsSV[nPosProd])][ny] := FieldGet(FieldPos(aHeaderSV[nPosProd][ny][2]))
						Else
							Do Case
								Case AllTrim(aHeaderSV[nPosProd][ny][2]) == "AFA_TIPO"
									aColsSV[nPosProd][Len(aColsSV[nPosProd])][ny] := SB1->B1_TIPO

								Case AllTrim(aHeaderSV[nPosProd][ny][2]) == "AFA_UM"
									aColsSV[nPosProd][Len(aColsSV[nPosProd])][ny] := SB1->B1_UM

								Case AllTrim(aHeaderSV[nPosProd][ny][2]) == "AFA_SEGUM"
									aColsSV[nPosProd][Len(aColsSV[nPosProd])][ny] := SB1->B1_SEGUM

								Case AllTrim(aHeaderSV[nPosProd][ny][2]) == "AFA_DESCRI"
									aColsSV[nPosProd][Len(aColsSV[nPosProd])][ny] := SB1->B1_DESC

								Case Alltrim(aHeaderSV[nPosProd][ny][2]) == "AFA_SIMBMO"
									aColsSV[nPosProd][Len(aColsSV[nPosProd])][ny] := SuperGetMv("MV_SIMB"+Alltrim(STR(AFA->AFA_MOEDA,2,0)))

								OtherWise
									aColsSV[nPosProd][Len(aColsSV[nPosProd])][ny] := CriaVar(aHeaderSV[nPosProd][ny][2])
							EndCase
						EndIf
						aColsSV[nPosProd][Len(aColsSV[nPosProd])][Len(aHeaderSV[nPosProd])+1] := .F.
					Next ny
				EndIf
				AFA->(dbSkip())
			EndDo
		EndIf

		If Empty(aColsSV[nPosProd])

			// faz a montagem de uma linha em branco no aColsAFA1
			aadd(aColsSV[nPosProd],Array(Len(aHeaderSV[nPosProd])+1))
			For ny := 1 to Len(aHeaderSV[nPosProd])
				If Trim(aHeaderSV[nPosProd][ny][2]) == "AFA_ITEM"
					aColsSV[nPosProd][1][ny] 	:= StrZero(1, TamSX3("AFA_ITEM")[1])
				Else
					aColsSV[nPosProd][1][ny] := CriaVar(aHeaderSV[nPosProd][ny][2])
				EndIf
				aColsSV[nPosProd][1][Len(aHeaderSV[nPosProd])+1] := .F.
			Next ny
		EndIf


		// Faz a montagem do aColsAFA2 ( Alocacao de Recursos )
		If lDados
			FATPDLogUser("PMS203VIS")
			aColsSV[nPosAloc]:=	{}

			dbSelectArea("AFA")
			dbSetOrder(1)
			dbSeek(xFilial("AFA") + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA)
			While !Eof() .And. AFA->AFA_FILIAL + AFA->AFA_PROJET + AFA_REVISA + AFA->AFA_TAREFA ==;
				xFilial("AFA") + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA .And. lContinua
				If ! Empty(AFA->AFA_RECURS)

					// trava o registro do AFA2 - Alteracao, Exclusao
					If lTrava .And. lAltOuExc
						If ! SoftLock("AFA")
							lContinua := .F.
						Else
							aAdd(aRecAFA2,RecNo())
						Endif
					EndIf
					aADD(aColsSV[nPosAloc],Array(Len(aHeaderSV[nPosAloc])+1))
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+AFA->AFA_PRODUT))
					For ny := 1 to Len(aHeaderSV[nPosAloc])
						If ( aHeaderSV[nPosAloc][ny][10] != "V")
							aColsSV[nPosAloc][Len(aColsSV[nPosAloc])][ny] := FieldGet(FieldPos(aHeaderSV[nPosAloc][ny][2]))
						Else
							Do Case
								Case AllTrim(aHeaderSV[nPosAloc][ny][2]) == "AFA_TIPO"
									aColsSV[nPosAloc][Len(aColsSV[nPosAloc])][ny] := SB1->B1_TIPO

								Case AllTrim(aHeaderSV[nPosAloc][ny][2]) == "AFA_UM"
									aColsSV[nPosAloc][Len(aColsSV[nPosAloc])][ny] := SB1->B1_UM

								Case AllTrim(aHeaderSV[nPosAloc][ny][2]) == "AFA_SEGUM"
									aColsSV[nPosAloc][Len(aColsSV[nPosAloc])][ny] := SB1->B1_SEGUM

								Case AllTrim(aHeaderSV[nPosAloc][ny][2]) == "AFA_DESCRI"
									If !Empty(AFA->AFA_RECURS)
										aColsSV[nPosAloc][Len(aColsSV[nPosAloc])][ny] := Posicione("AE8",1,xFilial("AE8") + AFA->AFA_RECURS,"AE8_DESCRI")
									Else
										aColsSV[nPosAloc][Len(aColsSV[nPosAloc])][ny] := SB1->B1_DESC
									EndIf
								OtherWise
									aColsSV[nPosAloc][Len(aColsSV[nPosAloc])][ny] := CriaVar(aHeaderSV[nPosAloc][ny][2])
							EndCase
						EndIf
						aColsSV[nPosAloc][Len(aColsSV[nPosAloc])][Len(aHeaderSV[nPosAloc])+1] := .F.
					Next ny
				EndIf
				AFA->(dbSkip())
			EndDo
		EndIf
		If Empty(aColsSV[nPosAloc])

			// faz a montagem de uma linha em branco no aColsAFA2
			aadd(aColsSV[nPosAloc],Array(Len(aHeaderSV[nPosAloc])+1))
			For ny := 1 to Len(aHeaderSV[nPosAloc])
				If Trim(aHeaderSV[nPosAloc][ny][2]) == "AFA_ITEM"
					aColsSV[nPosAloc][1][ny] 	:= StrZero(1, TamSX3("AFA_ITEM")[1])
				Else
					aColsSV[nPosAloc][1][ny] := CriaVar(aHeaderSV[nPosAloc][ny][2])
				EndIf
				aColsSV[nPosAloc][1][Len(aHeaderSV[nPosAloc])+1] := .F.
			Next ny
		EndIf

		// Fim da ontagem dos aCols do Padrao

    Else

		// Montagem dos aCols do CCT

		// Faz a montagem do aColsAEL ( Insumos )
		If lDados

			aColsSV[nPosInsm]:=	{}

			dbSelectArea("AEL")
			dbSetOrder(1)
			dbSeek(xFilial("AEL")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
			While !Eof() .And. AEL->AEL_FILIAL + AEL->AEL_PROJET + AEL->AEL_REVISA + AEL->AEL_TAREFA ==;
				xFilial("AEL")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA .And. lContinua

				// trava o registro do AEL - Alteracao,Exclusao
				If lTrava .And. lAltOuExc
					If !SoftLock("AEL")
						lContinua := .F.
					Else
						aAdd(aRecAEL,RecNo())
					EndIf
				EndIf
				aADD(aColsSV[nPosInsm],Array(Len(aHeaderSV[nPosInsm])+1))
				For ny := 1 to Len(aHeaderSV[nPosInsm])
					If ( aHeaderSV[nPosInsm][ny][10] != "V")
						aColsSV[nPosInsm][Len(aColsSV[nPosInsm])][ny] := FieldGet(FieldPos(aHeaderSV[nPosInsm][ny][2]))
					Else
						Do Case
							Case '.'+AllTrim(aHeaderSV[nPosInsm][ny][2])+'.' $ ".AEL_TIPO.AEL_DESCRI.AEL_UM.AEL_MOEDA.AEL_SIMBMO.AEL_CUSTD.AEL_SEGUM.AEL_CUSPRD.AEL_CUSIMP.AEL_PRODUC.AEL_QTOT.AEL_CUSIT.AEL_NUMEQ.AEL_VALENC.AEL_PADSAL.AEL_AQUISI.AEL_COEFMA.AEL_COMBUS.AEL_DEPREC.AEL_HORANO.AEL_JUROS.AEL_MANUT.AEL_MATERI.AEL_MDO.AEL_POTENC.AEL_RESIDU.AEL_VALCOM.AEL_VIDAUT.AEL_DMTX.AEL_CAPM3.AEL_VELO.AEL_TCDM.AEL_TPERC.AEL_TPTOT.AEL_PHM3.AEL_CSTUNI.AEL_MT.AEL_EMPOLA.AEL_RECPAI.AEL_GRPREC.AEL_VLJURO."
								aColsSV[nPosInsm][Len(aColsSV[nPosInsm])][ny] := PMSCpoCoUn(AllTrim(aHeaderSV[nPosInsm][ny][2]))
							OtherWise
								aColsSV[nPosInsm][Len(aColsSV[nPosInsm])][ny] := CriaVar(aHeaderSV[nPosInsm][ny][2])
						EndCase
					EndIf
					aColsSV[nPosInsm][Len(aColsSV[nPosInsm])][Len(aHeaderSV[nPosInsm])+1] := .F.
				Next ny
				AEL->(dbSkip())
			EndDo

		EndIf

		If Empty(aColsSV[nPosInsm])

			// faz a montagem de uma linha em branco no aColsAEL
			aadd(aColsSV[nPosInsm],Array(Len(aHeaderSV[nPosInsm])+1))
			For ny := 1 to Len(aHeaderSV[nPosInsm])
				If Trim(aHeaderSV[nPosInsm][ny][2]) == "AEL_ITEM"
					aColsSV[nPosInsm][1][ny] 	:= StrZero(1, TamSX3("AEL_ITEM")[1])
				Else
					aColsSV[nPosInsm][1][ny] := CriaVar(aHeaderSV[nPosInsm][ny][2])
				EndIf
				aColsSV[nPosInsm][1][Len(aHeaderSV[nPosInsm])+1] := .F.
			Next ny
		EndIf


		// Faz a montagem do aColsAEN ( Subcomposicoes )
		If lDados

			aColsSV[nPosSubC]:=	{}

			dbSelectArea("AEN")
			dbSetOrder(1)
			dbSeek(xFilial("AEN")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
			While !Eof() .And. AEN->AEN_FILIAL + AEN->AEN_PROJET + AEN->AEN_REVISA + AEN->AEN_TAREFA ==;
				xFilial("AEN")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA .And. lContinua

				// trava o registro do AEN - Alteracao,Exclusao
				If lTrava .And. lAltOuExc
					If !SoftLock("AEN")
						lContinua := .F.
					Else
						aAdd(aRecAEN,RecNo())
					EndIf
				EndIf
				aADD(aColsSV[nPosSubC],Array(Len(aHeaderSV[nPosSubC])+1))
				For ny := 1 to Len(aHeaderSV[nPosSubC])
					If ( aHeaderSV[nPosSubC][ny][10] != "V")
						aColsSV[nPosSubC][Len(aColsSV[nPosSubC])][ny] := FieldGet(FieldPos(aHeaderSV[nPosSubC][ny][2]))
					Else
						Do Case
							Case '.'+AllTrim(aHeaderSV[nPosSubC][ny][2])+'.' $ ".AEN_DESCRI.AEN_UM.AEN_CUSTO.AEN_CUSIT."
								aColsSV[nPosSubC][Len(aColsSV[nPosSubC])][ny] := PMSCpoCoUn(AllTrim(aHeaderSV[nPosSubC][ny][2]))

							OtherWise
								aColsSV[nPosSubC][Len(aColsSV[nPosSubC])][ny] := CriaVar(aHeaderSV[nPosSubC][ny][2])
						EndCase
					EndIf
					aColsSV[nPosSubC][Len(aColsSV[nPosSubC])][Len(aHeaderSV[nPosSubC])+1] := .F.
				Next ny

				// Calcula o custo da sub composicao conforme a quantidade
				nLen								:= Len(aColsSV[nPosSubC])
				nPCusto 							:= aScan( aHeaderSV[nPosSubC], { |x| "_CUSTO"  $ x[2] } )
				nPCustI 							:= aScan( aHeaderSV[nPosSubC], { |x| "_CUSIT"  $ x[2] } )
				nPQuant 							:= aScan( aHeaderSV[nPosSubC], { |x| "_QUANT"  $ x[2] } )
//				aColsSV[nPosSubC][nLen][nPCusto]	:= aColsSV[nPosSubC][nLen][nPCustI] * aColsSV[nPosSubC][nLen][nPQuant]

				AEN->(dbSkip())
			EndDo

		EndIf

		If Empty(aColsSV[nPosSubC])

			// faz a montagem de uma linha em branco no aColsAEN
			aadd(aColsSV[nPosSubC],Array(Len(aHeaderSV[nPosSubC])+1))
			For ny := 1 to Len(aHeaderSV[nPosSubC])
				If Trim(aHeaderSV[nPosSubC][ny][2]) == "AEN_ITEM"
					aColsSV[nPosSubC][1][ny] 	:= StrZero(1, TamSX3("AEN_ITEM")[1])
				Else
					aColsSV[nPosSubC][1][ny] := CriaVar(aHeaderSV[nPosSubC][ny][2])
				EndIf
				aColsSV[nPosSubC][1][Len(aHeaderSV[nPosSubC])+1] := .F.
			Next ny
		EndIf


		// Fim da montagem dos aCols do CCT
	EndIf

Return lContinua

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Chk203CCTOk ºAutor³                           º Data ³   /  /       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³                                                                     ³±±
±±³          ³                                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos / Template Construção Civil                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Chk203CCTOk()
If ExistTemplate("CCTAF9Calc") .And. ! AF8ComAJT(AF8->AF8_PROJET)
	ExecTemplate("CCTAF9Calc",.F.,.F.,{oFolder:nOption})
EndIf


Return .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ExisteTit   ºAutor ³Adriano Ueda       º Data ³  30/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se o titulo a receber existe                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ExisteTit(cPrefix, cNum, cParcela)
Local lRet := .F.
Local aAreaSE1 := SE1->(GetArea())

Default cParcela := ""

dbSelectArea("SE1")
SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

lRet := SE1->(MsSeek(xFilial("SE1") + cPrefix + cNum + cParcela, .F.))

RestArea(aAreaSE1)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ExisteAFT   ºAutor ³Adriano Ueda       º Data ³  30/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se o titulo esta atrelado a um projeto e tarefa   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ExisteAFT(cPrefix ,cNum ,cParcela ,cProjet ,cRevisa ,cTarefa ,cItEventAFP)
Local lRet := .F.
Local aAreaAFT := AFT->(GetArea())

Default cParcela := ""
Default cTarefa  := ""

dbSelectArea("AFT")

dbSetOrder(1) //AFT_FILIAL+AFT_PROJET+AFT_REVISA+AFT_TAREFA+AFT_PREFIX+AFT_NUM+AFT_PARCEL+A
lRet := (AFT->(MsSeek(xFilial("AFT") + cProjet + cRevisa + cTarefa + cPrefix + cNum + cParcela, .F.)) .AND. AFT->AFT_EVENTO == cItEventAFP)

RestArea(aAreaAFT)
Return lRet

/*/{Protheus.doc} PMSA203VLD

Funcao principal para validar os campos e browses preenchidos na dialog.

@author Reynaldo Miyashita

@since 08/08/2006

@version P11

@param oEnch, 		objeto,
@param aHeaderSV, array,
@param aColsSV, 	array,
@param aSavN, 		array,
@param oGD, 		objeto,
@param aAllEDT		array,
@return Logico, se não houve falha

/*/
Static Function PMSA203VLD(oEnch ,aHeaderSV ,aColsSV ,aSavN ,oGD ,aAllEDT, lCalcTrib)
Local lContinua 	:= .T.
Local nX 			:= 0
Local nPosBase 	:= 0
Local nMaxFolder 	:= Len(aHeaderSV)
Local lSimDts 		:= ValType(aSimDados)=="A" .and. Len(aSimDados)>0
Local nPosRel 		:= FolderOrd(STR0063)
Local aDados  		:= {}
Local nTime := 0

	// atualizo os array aheadersv e aColsSv com o aheader e acols do folder corrente
	A203SVCols(@aHeaderSV,@aColsSV,@aSavN,oFolder:nOption)

	If __lBlind
		lContinua:= AuxA203VLD( oEnch ,aHeaderSV ,aColsSV ,aSavN ,oGD, aAllEDT, lCalcTrib )
	Else
		MsgRun( STR0187,"PMSA203VLD - "+STR0188 , ; //"Aguarde.. Validando as informações da tarefa"##"Processando..."
		        {||lContinua := AuxA203VLD( oEnch ,aHeaderSV ,aColsSV ,aSavN ,oGD, aAllEDT, lCalcTrib )})
	EndIf

Return lContinua

/*/{Protheus.doc} AuxA203VLD

Funcao auxiliar para validar os campos e browses preenchidos na dialog.

@author Reynaldo Miyashita

@since 08/08/2006

@version P11

@param oEnch, 		objeto,
@param aHeaderSV, array,
@param aColsSV, 	array,
@param aSavN, 		array,
@param oGD, 		objeto,
@param aAllEDT		array,
@return Logico, se não houve falha

/*/
Static Function AuxA203VLD( oEnch ,aHeaderSV ,aColsSV ,aSavN ,oGD, aAllEDT, lCalcTrib )
Local lContinua  := .T.
Local nX         := 0
Local nPosBase   := 0
Local nMaxFolder := Len(aHeaderSV)
Local lSimDts    := ValType(aSimDados)=="A" .and. Len(aSimDados)>0
Local aDados     := {}
Local nPosRel    := FolderOrd(STR0063)

Local nPosProd   := FolderOrd(STR0039)	//Posicao Aba Produtos
Local nPosFldREC := FolderOrd(STR0040)	//Posicao Aba Recursos
Local aArea 		:= GetArea()
Local aAreaAF8 	:= AF8->(GetArea())
Local aAreaAFC 	:= AFC->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())

DEFAULT aAllEDT   := {}
DEFAULT lCalcTrib := .F.

If ! Obrigatorio(oEnch:aGets,oEnch:aTela)
	lContinua := .F.
EndIf

If lContinua
	For nX := 1 To nMaxFolder
		If !AGDTudok(aSavN,aColsSV,aHeaderSV,nX,@oGD)
			oFolder:nOption := nX
			A203SVCols(@aHeaderSV,@aColsSV,@aSavN,nX)
			lContinua := .F.
			Exit
		EndIf
	Next nX
EndIf

lContinua := lContinua .AND. A203VldCrnOk( "P" ,aHeadAEF1 ,aColsAEF1 ,aHeaderSV[1] ,aColsSV[1])
lContinua := lContinua .AND. A203VldCrnOk( "R" ,aHeadAEF2 ,aColsAEF2 ,aHeaderSV[5] ,aColsSV[5])

If lContinua .and. HasTemplate("CCT")
	Chk203CCTOk()
EndIf

IF lContinua
	lContinua := PA203Restri(!IsAuto())
Endif

If lContinua .AND. !lSimDts
	// data e hora inicio, data e hora fim e calendario forem diferentes do gravado na base, faz a procura
	If DTOS(M->AF9_START)+M->AF9_HORAI+DTOS(M->AF9_FINISH)+M->AF9_HORAF+M->AF9_CALEND<>DTOS(AF9->AF9_START)+AF9->AF9_HORAI+DTOS(AF9->AF9_FINISH)+AF9->AF9_HORAF+AF9->AF9_CALEND
		If lContinua := PmsCalcSuc(M->AF9_PROJET,M->AF9_REVISA,M->AF9_TAREFA,.T. ,@aAllEDT,,@aTarefs)
			lContinua := P203SimE(M->AF9_PROJET,M->AF9_REVISA,M->AF9_TAREFA,.T. ,@aAllEDT,,@aTarefs, aColsSV[nPosRel] )
		EndIf
	EndIf
EndIf

// IF para verificar se a EDT pai desta tarefa foi inclusa para atualização
// caso a tarefa alterada nao tenha relacionamento, este array estará vazio, porem, precisamos
// validar se a EDT Pai é predecessora de alguma outra tarefa e verificar sua restrição
If (aScan(aAllEDT,M->AF9_EDTPAI) <= 0)
	aAdd(aAllEDT,M->AF9_EDTPAI)
Endif

If lContinua
	If (nPosBase := aScan(aTarefs,{|x|x[1]+x[2] == "AF9" + M->AF9_TAREFA }) >0)
		lContinua := PmsSimEDT(M->AF9_PROJET,M->AF9_REVISA,M->AF9_EDTPAI,@aAllEDT,.T.,,,,@aTarefs)
	Else
		aAdd(aDados,{"AF9",M->AF9_TAREFA,M->AF9_START,M->AF9_HORAI,M->AF9_FINISH,M->AF9_HORAF,M->AF9_HDURAC,M->AF9_HUTEIS,M->AF9_NIVEL,M->AF9_DTATUI,M->AF9_DTATUF, AF9->(RECNO())})
		lContinua := PmsSimEDT(M->AF9_PROJET,M->AF9_REVISA,M->AF9_EDTPAI,@aAllEDT,.T.,,,,aDados)
	Endif
EndIf

//Atualiza a GetDados dos Impostos dos Produtos e Recursos
If lContinua .AND. lCalcTrib
	A203GDAN9Inc(aHeaderSV[nPosProd], aColsSV[nPosProd], 1, nPosProd, aColsSV[nPosProd][1][Len(aColsSV[nPosProd][1])] )	//Produtos

	//Validacao que verifica se a tarefa possui recurso, para entao atualizar a GetDados correspondente
	If !Empty(aColsSV[nPosFldREC][1][2])
		A203GDAN9Inc(aHeaderSV[nPosFldREC], aColsSV[nPosFldREC], 1, nPosFldREC, aColsSV[nPosFldREC][1][Len(aColsSV[nPosFldREC][1])] )	//Recursos
	EndIf

EndIf

If !lContinua
	aSize(aTarefs,0)
	aSize(aAllEDT,0)
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aAreaAF8)
RestArea(aArea)
Return( lContinua )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSA203Chk ºAutor  ³Reynaldo Miyashita º Data ³  08/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                          . º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMSA203Chk( lA203Inclui ,lA203Altera ,lA203Exclui )
Local lRetorno := .T.

If ExistBlock("PMA203VLD")
	lRetorno := ExecBlock("PMA203VLD",.F.,.F.,{la203Inclui,la203Altera,la203Exclui})
EndIf

Return( lRetorno )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³01/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002, "AxPesqui"  , 0 , 1,,.F.},; //"Pesquisar"
						{ STR0003, "PMS203Dlg", 0 , 2},; //"Visualizar"
						{ STR0004, "PMS203Dlg", 0 , 3},; //"Incluir"
						{ STR0005, "PMS203Dlg", 0 , 4},; //"Alterar"
						{ STR0006, "PMS203Dlg", 0 , 5},; //"Excluir"
						{ STR0007, "MSDOCUMENT",0,4 }} //"Conhecimento"
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |PmsVldCom ºAutor  ³Clovis Magenta      º Data ³  27/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de validacao dos produtos da composicao informada na º±±
±±º          ³tarefa. Caso haja produto bloqueado ela informa e nao permi-º±±
±±º          ³tira a continuacao do processo.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA203                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PmsVldCom()

Local lRet:= .T.
Local aArea := GetArea()
Local aAreaAE2 := AE2->(GetArea())
Local aAreaAF9 := AF9->(GetArea())
Local aAreaSB1 := SB1->(GetArea())

dbSelectArea("AE2") // Procura na tabela de produtos da composicao de acordo com o AF9_COMPOS
dbSetOrder(1)   //AE2_FILIAL+AE2_COMPOS+AE2_ITEM
If dbSeek(xFilial("AF9")+ M->AF9_COMPOS, .T.)
	While !Eof() .and. (xFilial("AF9")+M->AF9_COMPOS == AE2->(AE2_FILIAL+AE2_COMPOS))

		dbSelectArea("SB1")
		dbSetOrder(1) //B1_FILIAL+B1_COD
		dbSeek(xFilial("SB1")+AE2->AE2_PRODUT)

		If SB1->B1_MSBLQL == "1"
			lRet := .F.
		Endif

		AE2->( dbSkip() )
	EndDo
EndIf

If lRet==.F.
	MSGAlert(STR0127, STR0126)
EndIf

RestArea(aAreaAE2)
RestArea(aAreaAF9)
RestArea(aAreaSB1)
RestArea(aArea)

Return lRet

/////////////////////////////////////////////////////////////////////////////////////////////
// ENCAPSULAMENTO DA FUNCAO A203TemApont que é STATIC e precisa ser usada no fonte PMSA201.//
/////////////////////////////////////////////////////////////////////////////////////////////
Function A203EncapApt(cProjeto,cRevisa,cTrf)

Local lRet := .T.

lRet := GeralApp(cProjeto,cRevisa,cTrf)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PmsRecHabil³ Autor ³ Reynaldo Miyashita   ³ Data ³ Mar/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os Recursos com as Habilidades requisitadas        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PmsRecHabil(aHabil)
Local cLstHab := ""
Local nCnt := 0
Local cQuery := ""
Local cAliasAE8 := GetNextAlias()
Local cAliasRBI := GetNextAlias()
Local aRecRBI := {} // Habilidades do funcionario
Local nInd := 0
Local nYnd := 0
Local cRecurso := ""
Local nPos
Local aRecxHabil := {} // Recursos qualificados e suas habilidades
Local aRecursos := {} // Códigos dos Recursos qualificados
Local lRet := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Habilidades Relacionadas a Tarefa³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(aHabil)
	cQuery := " SELECT DISTINCT AE8_RECURS "
	cQuery += " FROM "+ RetSQLName( 'AE8' ) +" AE8 "

	cQuery += "  WHERE AE8.AE8_FILIAL = '"+ xFilial( 'AE8' ) +"' "
	cQuery += "  AND (AE8.AE8_ATIVO = '1' OR AE8.AE8_ATIVO = ' ') "
	If AE8->(FieldPos("AE8_MSBLQL")) > 0
		cQuery += "  AND AE8.AE8_MSBLQL <> '1'"
	Endif
	cQuery += "  AND AE8.D_E_L_E_T_ = '"+ Space( 1 ) +"' "
	cQuery += "  ORDER BY AE8_RECURS "
	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., __cRdd , TcGenQry( ,, cQuery ) , cAliasAE8 , .T. , .F. )
	If Select(cAliasAE8) > 0
		dbSelectArea( cAliasAE8 )
		(cAliasAE8)->(dbEval({||aAdd(aRecxHabil ,{ AllTrim((cAliasAE8)->AE8_RECURS) ,{}})}))
		(cAliasAE8)->(dbCloseArea())
	EndIf

Else
	cLstHab := ""
	For nCnt := 1 To Len(aHabil)
		cLstHab += "','" + aHabil[nCnt,01]
	Next nCnt
	cLstHab := SubStr(cLstHab ,3) + "'"

	//
	// busca as habilidades do funcionario através do codigo do funcionario do recurso
	//
	cQuery := " SELECT DISTINCT AE8_RECURS ,RBI_HABIL "
	cQuery += " FROM "+ RetSQLName( 'AE8' ) +" AE8 "

	cQuery += "  INNER JOIN "+ RetSQLName( 'SRA' ) +" SRA ON "
	cQuery += "  AE8.AE8_FILIAL = '"+ xFilial( 'AE8' ) +"' AND SRA.RA_FILIAL  = '"+ xFilial( 'SRA' ) +"' "
	cQuery += "  AND AE8.AE8_CODFUN = SRA.RA_MAT "

	cQuery += "  INNER JOIN "+ RetSQLName( 'RBI' ) +" RBI ON "
	cQuery += "  AE8.AE8_FILIAL = '"+ xFilial( 'AE8' ) +"' AND RBI.RBI_FILIAL  = '"+ xFilial( 'RBI' ) +"' "
	cQuery += "  AND SRA.RA_MAT = RBI.RBI_MAT "

	If Len(aHabil) > 0
		cQuery += "  AND RBI.RBI_HABIL IN ( "+ cLstHab +" ) "
	EndIf

	cQuery += "  WHERE AE8.D_E_L_E_T_  = '"+ Space( 1 ) +"' "
	cQuery += "  AND (AE8.AE8_ATIVO = '1' OR AE8.AE8_ATIVO = ' ') "
	If AE8->(FieldPos("AE8_MSBLQL")) > 0
		cQuery += "  AND AE8.AE8_MSBLQL <> '1'"
	Endif
	cQuery += "  AND SRA.D_E_L_E_T_    = '"+ Space( 1 ) +"' "
	cQuery += "  AND RBI.D_E_L_E_T_    = '"+ Space( 1 ) +"' "
	cQuery += "  ORDER BY AE8_RECURS "
	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., __cRdd , TcGenQry( ,, cQuery ) , cAliasRBI , .T. , .F. )
	If Select(cAliasRBI) >0
		dbSelectArea( cAliasRBI )
		(cAliasRBI)->(dbEval({||aAdd( aRecRBI,{AllTrim((cAliasRBI)->AE8_RECURS) ,(cAliasRBI)->RBI_HABIL ,0})}))
		(cAliasRBI)->(dbCloseArea())
	EndIf

	For nInd := 1 To Len( aRecRbi )
		cRecurso := aRecRbi[ nInd,1 ]
		If (nPos := Ascan( aRecxHabil , {|x| x[1] == cRecurso })) == 0
			Aadd( aRecxHabil ,{ cRecurso ,{aRecRbi[nInd ,2]} })
		Else
			Aadd( aRecxHabil[nPos,02] ,aRecRbi[ nInd,2 ])
		EndIf
	Next nInd
EndIf

aRecxHabil := aSort( aRecxHabil ,,, { |x,y| x[1] < y[1] } ) // ordena por recurso

//
// Verifica se as habilidades do recursos encontrados atendem as habilidades requisitadas.
//
For nInd := 1 To Len(aRecxHabil)
	If Empty(aHabil)
		Aadd( aRecursos, aRecxHabil[ nInd,1 ] )
	Else
		aHabilAux := aClone( aRecxHabil[ nInd, 2 ] )
		lRet := .F.
		If Len( aHabilAux ) >= Len( aHabil ) // A quantidade de habilidades do recurso maior ou igual as requeridas
			For nYnd := 1 To Len( aHabil )
				If !(lRet := (Ascan(aHabilAux ,{|x| x== aHabil[nYnd,1]}) > 0))
					Exit
				EndIf
			Next nYnd
		EndIf
		If lRet
			Aadd( aRecursos, aRecxHabil[ nInd,1 ] )
		EndIf
	EndIf
Next nInd

Return aRecursos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsCalcHr   ºAutor ³Reynaldo Miyashita º Data ³  08/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula a duração atraves da data e hora de inicio e fim   º±±
±±º          ³ e o calendario                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsCalcHr( dStart ,cHoraIni ,dFinish ,cHoraFim ,cCalend)
Local nDuracao := 0

If dStart==dFinish
	nDuracao := PmsHrUtil(dStart,"00"+cHoraIni,"00"+cHoraFim ,cCalend)
Else
	nDuracao := 0
	nDuracao += PmsHrUtil(dStart,"00"+cHoraIni,"0024:00" ,cCalend)
	dStart++
	While dStart <= dFinish
		If dStart==dFinish
			nDuracao += PmsHrUtil(dStart,"0000:00","00"+cHoraFim ,cCalend)
		Else
			nDuracao += PmsHrUtil(dStart,"0000:00","0024:00" ,cCalend)
		EndIf
		dStart++
	End
EndIf
Return nDuracao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSRecDisp  ºAutor ³Reynaldo Miyashita º Data ³  08/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca pelo recurso que está disponivel mais cedo           º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            º±±
±±³          ³ExpA1 : Array contendo as habilidades e notas minimas       º±±
±±³          ³        [1] : Código da habilidade                          º±±
±±³          ³        [2] : Nota minima da habilidade                     º±±
±±³          ³ExpD2 - Data Fim Limite                                     º±±
±±³          ³ExpN3 - Duração em horas                                    º±±
±±³          ³ExpC4 - Código do Projeto (opcional)                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º±±ºUso       ³ AP                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSRecDisp(aGrpHab, dLimite, nDurac, cCodProjeto, aRecursos, cForcaRec)
Local aArea := GetArea()
Local cCodRecurso := ""
Local aConfig := array(5)
Local nY := 0
Local nX := 0
Local aRetAloc :={}
Local aItvls :={}
Local nQtdHr := 0
Local aRetorno := {}
Local cRevisa := ""
Local dInicio := stod("")
Local cHrIni  := ""

DEFAULT cCodProjeto := ""
DEFAULT aRecursos := {}

If cForcaRec <> nil
	aRecursos := {cForcaRec}
Else
	aRecursos := PmsRecHabil(aGrpHab) // busca os recursos que atendam o conjunto de habilidades
EndIf

cRevisa := IIf(Empty(cCodProjeto) ,"" ,PMSAF8VER(cCodProjeto))

// retorno padrao
aRetorno := {}

If !Empty(aRecursos)
	aConfig[1] := MsDate()
	aConfig[2] := Substr(Time(),1,5)
	aConfig[3] := dLimite
	aConfig[4] := "24:00"
	aConfig[5] := 1

	For nx := 1 To Len( aRecursos )
		AE8->(dbSetOrder( 1 ))
		AE8->(dbSeek( xFilial() + aRecursos[ nx ]))
		aRetAloc := PmsRetAloc(AE8->AE8_RECURS,aConfig[1],aConfig[2],aConfig[3],aConfig[4],3,cCodProjeto,cRevisa,/*TAREFA*/,Nil)
		If Empty(aRetAloc)
			nQtdHr := PmsCalcHr(aConfig[1],aConfig[2],aConfig[3],aConfig[4] ,AE8->AE8_CALEND)
			aAuxRet := PMSDTaskF(aConfig[1],aConfig[2],AE8->AE8_CALEND,nQtdHr,cCodProjeto,AE8->AE8_RECURS)
			If nQtdHr >= nDurac
				aAdd(aItvls,{AE8->AE8_RECURS,aAuxRet[1],aAuxRet[2],aAuxRet[3],aAuxRet[4],0 ,nQtdHr})
			EndIf
		Else
			For ny := 1 to Len(aRetAloc)
				If ny == 1 .And. aRetAloc[ny,1] > aConfig[1]
					aAuxRet := PMSDTaskF(aConfig[1],aConfig[2],AE8->AE8_CALEND,1,cCodProjeto,AE8->AE8_RECURS)
					nQtdHr := PmsCalcHr(aAuxRet[1],aAuxRet[2],aRetAloc[ny,1],aRetAloc[ny,2] ,AE8->AE8_CALEND)
					If nQtdHr >= nDurac
						aAdd(aItvls,{AE8->AE8_RECURS,aAuxRet[1],aAuxRet[2],aRetAloc[ny,1],aRetAloc[ny,2],0 ,nQtdHr})
					EndIf
				EndIf
				// Se o ponteiro for dirente do total elementos e a data fim for maior q a data de incio do intervalo
				If ny <> Len(aRetAloc) .AND. dTos(aRetAloc[ny+1,1])+aRetAloc[ny+1,2] >= dTos(aConfig[1])+aConfig[2]

					// se a data de inicio for menor que o inicio do intervalo, substitui
					If dTos(aRetAloc[ny,1])+aRetAloc[ny,2] < dTos(aConfig[1])+aConfig[2]
						dInicio := aConfig[1]
						cHrIni  := aConfig[2]
					Else
						dInicio := aRetAloc[ny,1]
						cHrIni  := aRetAloc[ny,2]
					EndIf

					If (( AE8->AE8_UMAX-aRetAloc[ny,3]) * PmsHrsItvl(dInicio,cHrIni,aRetAloc[ny+1,1],aRetAloc[ny+1,2],AE8->AE8_CALEND,cCodProjeto,AE8->AE8_RECURS) / 100 ) >= nDurac
						nQtdHr := PmsCalcHr(dInicio,cHrIni,aRetAloc[ny+1,1],aRetAloc[ny+1,2] ,AE8->AE8_CALEND)
						If nQtdHr >= nDurac
							aAuxRet	:= PMSDTaskF(dInicio,cHrIni,AE8->AE8_CALEND,@nQtdHr,cCodProjeto,AE8->AE8_CALEND)
							aAdd(aItvls,{AE8->AE8_RECURS,aAuxRet[1],aAuxRet[2],aAuxRet[3],aAuxRet[4],AE8->AE8_UMAX-aRetAloc[ny,3] ,nQtdHr})
							//aAdd(aItvls,{AE8->AE8_RECURS,aRetAloc[ny,1],aRetAloc[ny,2],aRetAloc[ny+1,1],aRetAloc[ny+1,2],AE8->AE8_UMAX-aRetAloc[ny,3] ,nQtdHr})
						EndIf
					EndIf
				EndIf
				If ny == Len(aRetAloc)-1 .And. aRetAloc[Len(aRetAloc),1] < aConfig[3]
					aAuxRet := PMSDTaskI(aConfig[3],aConfig[4],AE8->AE8_CALEND,1,cCodProjeto,AE8->AE8_RECURS)
					nQtdHr := PmsCalcHr(aRetAloc[Len(aRetAloc),1],aRetAloc[Len(aRetAloc),2],aAuxRet[3],aAuxRet[4] ,AE8->AE8_CALEND)
					If nQtdHr >= nDurac
						aAuxRet := PMSDTaskI(aAuxRet[3],aAuxRet[4] ,AE8->AE8_CALEND,nQtdHr,cCodProjeto,AE8->AE8_RECURS)
						aAdd(aItvls,{AE8->AE8_RECURS,aAuxRet[1],aAuxRet[2],aAuxRet[3],aAuxRet[4],0 ,nQtdHr})
					EndIf
				EndIf
			Next ny
		EndIf
	Next nx

	If len(aItvls) > 0
		aSort(aItvls,,,{|x,y| dtos(x[2])+x[3]<dtos(y[2])+y[3]})  //ordena por data de inicio
		AE8->(dbSetOrder( 1 ))
		AE8->(dbSeek( xFilial() + aItvls[1,1]))
		nQtdHr := nDurac
		aAuxRet	:= PMSDTaskF(aItvls[1,2],aItvls[1,3],AE8->AE8_CALEND,@nQtdHr,cCodProjeto,AE8->AE8_CALEND)

		//
		// teoricamente a primeira posicao vai conter a data mais cedo
		//
		aRetorno := {aItvls[1,1] ,aAuxRet[1] ,aAuxRet[2] ,aAuxRet[3] ,aAuxRet[4]}
	EndIf
EndIf

RestArea(aArea)
Return(aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMS203EdtFºAutor  ³Pedro Pereira Lima  º Data ³  12/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtem todas as EDTs filhas de uma determinada EDT           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                              	        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS203EdtF(cEdtPai,cProjet,cRevisa,aEdtF)

Local aArea		:= GetArea()
Local aAreaAFC := AFC->(GetArea())

Default aEdtF  := {}

	If Len(aEdtF) == 0
		aAdd(aEdtF,cEdtPai)
	EndIf

	// obtem todas EDT filhas
	dbSelectArea("AFC")
	dbSetOrder(2) //AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI+AFC_ORDEM
	dbSeek(xFilial("AFC")+cProjet+cRevisa+cEdtPai)
	While AFC->(!Eof()) .AND. ;
	      AFC->(AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI)==xFilial("AFC")+cProjet+cRevisa+cEdtPai

		aAdd(aEdtF,AFC->AFC_EDT)
		PMS203EdtF(AFC->AFC_EDT,cProjet,cRevisa,@aEdtF)
		AFC->(dbSkip())
	EndDo

RestArea(aAreaAFC)
RestArea(aArea)
Return

Function PMS203DRES()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsDetCom ºAutor  ³Pedro Pereira Lima  º Data ³  01/21/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ retorna o array com os nomes das abas da tarefa            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsDetCom(cProjet)

Local aRetCabec := {}
Local lCalcTrib := IIf(AF8->AF8_PAR006 == '1' ,.T.,.F.)	//Verifica se havera calculo de impostos para as tarefas

If AF8comAJT(cProjet) //Cabecalho UTILIZANDO composicao auxiliar
	aRetCabec := { STR0129,;//'Insumos'
					STR0009,;//'Despesas'
					STR0130,;//'Subcomposições'
					STR0062,;//'Relac.Tarefas'
					STR0038,;//'Eventos'
					STR0051,;//'Cronograma por Periodo'
					STR0063}//'Relac.EDT'
	/*Folder Tributos nao se aplica a Composicao Auxiliar*/
Else 								//Cabecalho PADRAO
	aRetCabec := {	STR0039,;//'Produtos'
					STR0009,;//'Despesas'
					STR0062,;//'Relac.Tarefas'
					STR0038,;//'Eventos'
					STR0040,;//'Aloc. Recursos'
					STR0051,;//'Cronograma por Periodo'
					STR0063}//'Relac.EDT'
	If lCalcTrib
		aAdd(aRetCabec,STR0183) //'Tributos'
	EndIf

EndIf

Return aRetCabec

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FolderOrd ºAutor  ³Reynaldo Miyashita  º Data ³  27/01/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ retorna a posicao da aba, a partir da descricao.           º±±
±±º          ³ Por isso a descricao tem que ser igual utilizada na        º±±
±±º          ³ rotina PMSDetCom                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FolderOrd(cFolder)

Local aTitles  := PmsDetCom(AF8->AF8_PROJET)
Local nPosicao := 0

If cPaisLoc == "RUS"
	nPosicao := aScan(aTitles,{|x| Upper(AllTrim(x)) == Upper(AllTrim(cFolder))})
Else
	nPosicao := aScan(aTitles,{|x| Upper(AllTrim(x)) == Upper(cFolder)})
EndIf

Return nPosicao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMA203CU  ºAutor  ³Reynaldo Miyashita  º Data ³  27/01/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o conteudo do campo AF9_COMPUN                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMA203CU(cCompUn,cProjet,cRevisa)
Local lRet       := .F.
Local nX         := 1
Local nY         := 1
Local nPosDesp   := FolderOrd(STR0009) //'Despesas'
Local nPosInsm   := FolderOrd(STR0129) //'Insumos'
Local nPosSubC   := FolderOrd(STR0130) //'Subcomposicoes'
Local nPosRTar   := FolderOrd(STR0062) //'Relac tarefas'
Local nPosEvnt   := FolderOrd(STR0038) //'Eventos'
Local nPosInsumo := 0
Local nPosSubcom := 0
Local nPosDescri := 0
Local nFolder    := oFolder:nOption
Local lProj
Local aArea		 := GetArea()
Local aAreaAJT   := AJT->(GetArea())
Local aAreaAJU   := AJU->(GetArea())
Local aAreaAEH   := AEH->(GetArea())
Local aAreaAJX   := AJX->(GetArea())
Local aAreaAEJ   := AEJ->(GetArea())

Local nPIndImp	:= 0
Local nPIndPrd	:= 0
Local nPCusPrd	:= 0
Local nPCusImp	:= 0
Local nPCustd 	:= 0
Local nCustD	:= 0
Local nPCusto 	:= 0
Local nPCustI 	:= 0
Local nPQuant 	:= 0

//Local aInsumos	:= {}

DEFAULT cCompUn := ""
DEFAULT cProjet := AF8->AF8_PROJET
DEFAULT cRevisa := AF8->AF8_REVISA

If nPosInsm > 0
	nPosInsumo := aScan(aHeaderSV[nPosInsm],{|x|AllTrim(x[2])=="AEL_INSUMO"})
EndIf

If nPosSubC > 0
	nPosSubcom := aScan(aHeaderSV[nPosSubC],{|x|AllTrim(x[2])=="AEN_SUBCOM"})
EndIf

If nPosDesp > 0
	nPosDescri := aScan(aHeaderSV[nPosDesp],{|x|AllTrim(x[2])=="AFB_DESCRI"})
EndIf

If Empty(cCompUn)
	lRet := .T.
Else
	AEG->( DbSeek( xFilial( "AEG" ) + cCompun ) )

	// validar se existe na base de composicao
	lRet := ExistCpo('AEG', cCompun)
	If lRet
		// confirmar sobre posicao dos dados
		lRet := AVISO(STR0014, STR0131, {STR0086, STR0087}, 1) == 1
	EndIf

	If lRet
		lProj	:= .F. //sempre busca do banco de composicao auxiliar

		AEG->( DbSeek( xFilial( "AEG" ) + cCompun ) )

		If Empty( M->AF9_DESCRI )
			M->AF9_DESCRI := AEG->AEG_DESCRI
		EndIf

		If Empty( M->AF9_UM )
			M->AF9_UM := AEG->AEG_UM
		EndIf

		If Empty( M->AF9_GRPCOM )
			M->AF9_GRPCOM := AEG->AEG_GRPCOM
		EndIf

		If Empty( M->AF9_FERRAM )
			M->AF9_FERRAM := AEG->AEG_FERRAM
		EndIf

		M->AF9_TIPO 	:= AEG->AEG_TIPO
		M->AF9_PRODUN	:= AEG->AEG_PRODUN
		M->AF9_QTDEQP	:= AEG->AEG_QTDEQP
		M->AF9_PRODUC	:= AEG->AEG_PRODUC
		M->AF9_BCOMPO	:= AEG->AEG_BCOMPO
		M->AF9_TPPRDE	:= AEG->AEG_TPPRDE

		// carrega as composições auxliares(subcomposicao) na tarefa
		If nPosSubC>0

			oFolder:SetOption( nPosSubc )

			For nX := 1 to Len(aCols)
				If !Empty(aCols[nX][nPosSubcom])
					aCols[nX][Len(aHeaderSV[nPosSubc])+1] := .T.
				EndIf
			Next nX

			If lProj
				dbSelectArea("AJX")
				dbSetOrder(2) // AJX_FILIAL+AJX_PROJET+AJX_REVISA+AJX_COMPUN+AJX_ITEM
				dbSeek(xFilial()+cProjet+cRevisa+cCompUn)
				While !Eof() .And. AJX->AJX_FILIAL + AJX->AJX_PROJET + AJX->AJX_REVISA + AJX->AJX_COMPUN ==;
					xFilial("AJX")+cProjet+cRevisa+cCompUn

					If !Empty(aCols[Len(aCols)][nPosSubcom])
						aAdd(aCols,Array(Len(aHeaderSV[nPosSubc])+1))
					EndIf
					nX := Len(aCols)
					n  := nX

					For ny := 1 to Len(aHeaderSV[nPosSubc])
						Do Case
							Case Trim(aHeaderSV[nPosSubc][ny][2]) == "AEN_ITEM"
								aCols[nX][ny] := StrZero(nX, TamSX3("AEN_ITEM")[1])
							Case Trim(aHeaderSV[nPosSubc][ny][2]) == "AEN_SUBCOM"
								aCols[nX][ny] := AJX_SUBCOM
							Case aHeaderSV[nPosSubc][ny][10] == "V"
								aCols[nX][ny] := PMSCpoCoUn(AllTrim(aHeaderSV[nPosSubc][ny][2]))
							OtherWise
								aCols[nX][ny] := CriaVar(aHeaderSV[nPosSubc][ny][2], .T.)
						EndCase
					Next ny

					// Calcula o custo da sub composicao conforme a quantidade
					nPCusto 			:= aScan( aHeaderSV[nPosSubc], { |x| "_CUSTO"  $ x[2] } )
					nPCustI 			:= aScan( aHeaderSV[nPosSubc], { |x| "_CUSIT"  $ x[2] } )
					nPQuant 			:= aScan( aHeaderSV[nPosSubc], { |x| "_QUANT"  $ x[2] } )

					aCols[nX][Len(aHeaderSV[nPosSubc])+1] := .F.
					dbSkip()
				EndDo
			Else
				dbSelectArea("AEJ")
				dbSetOrder(1) // AEJ_FILIAL+AEJ_COMPOS+AEJ_ITEM
				dbSeek(xFilial()+cCompUn)
				While !Eof() .And. AEJ->AEJ_FILIAL + AEJ->AEJ_COMPOS ==;
					xFilial("AEJ")+cCompUn

					If !Empty(aCols[Len(aCols)][nPosSubcom])
						aAdd(aCols,Array(Len(aHeaderSV[nPosSubc])+1))
					EndIf
					nX := Len(aCols)
					n  := nX

					For ny := 1 to Len(aHeaderSV[nPosSubc])
						Do Case
							Case Trim(aHeaderSV[nPosSubc][ny][2]) == "AEN_ITEM"
								aCols[nX][ny] := StrZero(nX, TamSX3("AEN_ITEM")[1])
							Case Trim(aHeaderSV[nPosSubc][ny][2]) == "AEN_SUBCOM"
								aCols[nX][ny] := AEJ->AEJ_SUBCOM
							Case Trim(aHeaderSV[nPosSubc][ny][2]) == "AEN_QUANT"
								aCols[nX][ny] := AEJ->AEJ_QUANT
							Case aHeaderSV[nPosSubc][ny][10] == "V"
								aCols[nX][ny] := PMSCpoCoUn(AllTrim(aHeaderSV[nPosSubc][ny][2]))
							OtherWise
								aCols[nX][ny] := CriaVar(aHeaderSV[nPosSubc][ny][2], .T.)
						EndCase
					Next ny

					// Calcula o custo da sub composicao conforme a quantidade
					nPCusto 			:= aScan( aHeaderSV[nPosSubc], { |x| "_CUSTO"  $ x[2] } )
					nPCustI 			:= aScan( aHeaderSV[nPosSubc], { |x| "_CUSIT"  $ x[2] } )
					nPQuant 			:= aScan( aHeaderSV[nPosSubc], { |x| "_QUANT"  $ x[2] } )

					aCols[nX][Len(aHeaderSV[nPosSubc])+1] := .F.
					dbSkip()
				EndDo
			EndIf

			n := aSavN[nPosSubC]
			aColsSV[nPosSubC] := aClone(aCols)

		EndIf

		If nPosDesp>0

			oFolder:SetOption( nPosDesp )

			For nX := 1 to Len(aCols)
				If !Empty(aCols[nX][nPosDescri])
					aCols[nX][Len(aHeaderSV[nPosDesp])+1] := .T.
				EndIf
			Next nX

			If lProj
				dbSelectArea("AJV")
				dbSetOrder(2) // AJV_FILIAL+AJV_PROJET+AJV_REVISA+AJV_COMPUN+AJV_ITEM
				dbSeek(xFilial()+cProjet+cRevisa+cCompUn)
				While !Eof() .And. AJV->AJV_FILIAL + AJV->AJV_PROJET + AJV->AJV_REVISA + AJV->AJV_COMPUN ==;
					xFilial("AJV")+cProjet+cRevisa+cCompUn

					If !Empty(aCols[Len(aCols)][nPosDescri])
						aAdd(aCols,Array(Len(aHeaderSV[nPosDesp])+1))
					EndIf
					nX := Len(aCols)
					n  := nX

					For ny := 1 to Len(aHeaderSV[nPosDesp])
						Do Case
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_ITEM"
								aCols[nX][ny] := StrZero(nX, TamSX3("AFB_ITEM")[1])
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_TIPOD"
								aCols[nX][ny] := AJV->AJV_TIPOD
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_DESCRI"
								aCols[nX][ny] := AJV->AJV_DESCRI
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_MOEDA"
								aCols[nX][ny] := AJV->AJV_MOEDA
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_SIMBMO"
								aCols[nX][ny] := GetNewPar("MV_SIMB"+Alltrim(str(AJV->AJV_MOEDA)),"")
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_VALOR"
								aCols[nX][ny] := AJV->AJV_VALOR
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_DMTT"
								aCols[nX][ny] := AJV->AJV_DMTT
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_DMT"
								aCols[nX][ny] := AJV->AJV_DMT
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_DMTP"
								aCols[nX][ny] := AJV->AJV_DMTP
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_CUSTO"
								aCols[nX][ny] := AJV->AJV_CUSTO
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_CONSUM"
								aCols[nX][ny] := AJV->AJV_CONSUM
							OtherWise
								aCols[nX][ny] := CriaVar(aHeaderSV[nPosDesp][ny][2], .T.)
						EndCase
					Next ny

					aCols[nX][Len(aHeaderSV[nPosDesp])+1] := .F.
					dbSkip()
				EndDo
			Else
				dbSelectArea("AEI")
				dbSetOrder(1) // AEI_FILIAL+AEI_COMPUN+AEI_ITEM
				dbSeek(xFilial()+cCompUn)
				While !Eof() .And. AEI->AEI_FILIAL + AEI->AEI_COMPUN ==;
					xFilial("AEI")+cCompUn

					If !Empty(aCols[Len(aCols)][nPosDescri])
						aAdd(aCols,Array(Len(aHeaderSV[nPosDesp])+1))
					EndIf
					nX := Len(aCols)
					n  := nX

					For ny := 1 to Len(aHeaderSV[nPosDesp])
						Do Case
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_ITEM"
								aCols[nX][ny] := StrZero(nX, TamSX3("AFB_ITEM")[1])
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_TIPOD"
								aCols[nX][ny] := AEI->AEI_TIPOD
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_DESCRI"
								aCols[nX][ny] := AEI->AEI_DESCRI
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_MOEDA"
								aCols[nX][ny] := AEI->AEI_MOEDA
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_SIMBMO"
								aCols[nX][ny] := GetNewPar("MV_SIMB"+Alltrim(str(AEI->AEI_MOEDA)),"")
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_VALOR"
								aCols[nX][ny] := AEI->AEI_VALOR
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_DMTT"
								aCols[nX][ny] := AEI->AEI_DMTT
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_DMT"
								aCols[nX][ny] := AEI->AEI_DMT
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_DMTP"
								aCols[nX][ny] := AEI->AEI_DMTP
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_CUSTO"
								aCols[nX][ny] := AEI->AEI_CUSTO
							Case Trim(aHeaderSV[nPosDesp][ny][2]) == "AFB_CONSUM"
								aCols[nX][ny] := AEI->AEI_CONSUM
							OtherWise
								aCols[nX][ny] := CriaVar(aHeaderSV[nPosDesp][ny][2], .T.)
						EndCase
					Next ny

					aCols[nX][Len(aHeaderSV[nPosDesp])+1] := .F.
					dbSkip()
				EndDo
			EndIf

			n := aSavN[nPosDesp]
			aColsSV[nPosDesp] := aClone(aCols)

		EndIf

		If nPosInsm>0

			oFolder:SetOption( nPosInsm )

			For nX := 1 to Len(aCols)
				If !Empty(aCols[Len(aCols)][nPosInsumo])
					aCols[nX][Len(aHeaderSV[nPosInsm])+1] := .T.
				EndIf
			Next nX

			If lProj
				dbSelectArea("AJU")
				dbSetOrder(2) // AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN+AJU_ITEM
				dbSeek(xFilial()+cProjet+cRevisa+cCompUn)
				While !Eof() .And. AJU->AJU_FILIAL + AJU->AJU_PROJET + AJU->AJU_REVISA + AJU->AJU_COMPUN ==;
					xFilial("AJU")+cProjet+cRevisa+cCompUn

					If !Empty(aCols[Len(aCols)][nPosInsumo])
						aAdd(aCols,Array(Len(aHeaderSV[nPosInsm])+1))
					EndIf
					nX := Len(aCols)
					n  := nX

					For ny := 1 to Len(aHeaderSV[nPosInsm])
						Do Case
							Case Trim(aHeaderSV[nPosInsm][ny][2]) == "AEL_ITEM"
								aCols[nX][ny] := StrZero(nX, TamSX3("AEL_ITEM")[1])
							Case Trim(aHeaderSV[nPosInsm][ny][2]) == "AEL_INSUMO"
								aCols[nX][ny] := AJU->AJU_INSUMO
							Case aHeaderSV[nPosInsm][ny][10] == "V"
								aCols[nX][ny] := PMSCpoCoUn(AllTrim(aHeaderSV[nPosInsm][ny][2]))
							Case Trim(aHeaderSV[nPosInsm][ny][2]) == "AEL_DTAPRO"
								aCols[nX][ny] := DDATABASE
							Case Trim(aHeaderSV[nPosInsm][ny][2]) == "AEL_DATPRF"
								aCols[nX][ny] := DDATABASE
							Case Trim(aHeaderSV[nPosInsm][ny][2]) == "AEL_GRORGA"
								aCols[nX][ny] := AJU->AJU_GRORGA
							OtherWise
								aCols[nX][ny] := CriaVar(aHeaderSV[nPosInsm][ny][2], .T.)
						EndCase
					Next ny

					aCols[nX][Len(aHeaderSV[nPosInsm])+1] := .F.
					dbSkip()
				EndDo
			Else
				// Itens de insumo da composicao auxiliar
				dbSelectArea("AEH")
				dbSetOrder(1) // AEH_FILIAL+AEH_COMPUN+AEH_ITEM
				dbSeek(xFilial()+cCompUn)
				While !Eof() .And. AEH->AEH_FILIAL + AEH->AEH_COMPUN ==;
					xFilial("AEH")+cCompUn

					If !Empty(aCols[Len(aCols)][nPosInsumo])
						aAdd(aCols,Array(Len(aHeaderSV[nPosInsm])+1))
					EndIf
					nX := Len(aCols)
					n  := nX

					AJY->( DbSetOrder( 1 ) )
					AJY->( DbSeek( xFilial( "AJY" ) + AF8->AF8_PROJET + AF8->AF8_REVISA + AEH->AEH_INSUMO ) )

					For ny := 1 to Len(aHeaderSV[nPosInsm])
						Do Case
							Case Trim(aHeaderSV[nPosInsm][ny][2]) == "AEL_ITEM"
								aCols[nX][ny] := StrZero(nX, TamSX3("AEL_ITEM")[1])
							Case Trim(aHeaderSV[nPosInsm][ny][2]) == "AEL_INSUMO"
								aCols[nX][ny] := AEH->AEH_INSUMO
							Case Trim(aHeaderSV[nPosInsm][ny][2]) == "AEL_DMT"
								aCols[nX][ny] := AEH->AEH_DMT
							Case Trim(aHeaderSV[nPosInsm][ny][2]) == "AEL_QUANT"
								aCols[nX][ny] := AEH->AEH_QUANT
							Case Trim(aHeaderSV[nPosInsm][ny][2]) == "AEL_HRPROD"
								aCols[nX][ny] := AEH->AEH_HRPROD
							Case Trim(aHeaderSV[nPosInsm][ny][2]) == "AEL_HRIMPR"
								aCols[nX][ny] := AEH->AEH_HRIMPR
							Case Trim(aHeaderSV[nPosInsm][ny][2]) == "AEL_DTAPRO"
								aCols[nX][ny] := DDATABASE
							Case Trim(aHeaderSV[nPosInsm][ny][2]) == "AEL_DATPRF"
								aCols[nX][ny] := DDATABASE
							Case Trim(aHeaderSV[nPosInsm][ny][2]) == "AEL_GRORGA"
								aCols[nX][ny] := AEH->AEH_GRORGA
							Case aHeaderSV[nPosInsm][ny][10] == "V"
								aCols[nX][ny] := PMSCpoCoUn(AllTrim(aHeaderSV[nPosInsm][ny][2]))
							OtherWise
								aCols[nX][ny] := CriaVar(aHeaderSV[nPosInsm][ny][2], .T.)
						EndCase
					Next ny

					// Calcula o custo do item conforme a quantidade de hora produtiva/improdutiva
					nPIndImp			:= aScan( aHeaderSV[nPosInsm], { |x| "_HRIMPR" $ x[2] } )
					nPIndPrd			:= aScan( aHeaderSV[nPosInsm], { |x| "_HRPROD" $ x[2] } )
					nPCusPrd			:= aScan( aHeaderSV[nPosInsm], { |x| "_CUSPRD" $ x[2] } )
					nPCusImp			:= aScan( aHeaderSV[nPosInsm], { |x| "_CUSIMP" $ x[2] } )
					nPCustd 			:= aScan( aHeaderSV[nPosInsm], { |x| "_CUSTD"  $ x[2] } )

					If AEH->AEH_GRORGA=='A'
						nCustD				:= (aCols[nx][nPCusPrd] * aCols[nx][nPIndPrd]) + (aCols[nx][nPCusImp] * aCols[nx][nPIndImp])
						aCols[nx][nPCustd]	:= nCustD
					Else
						nCustD				:= PMSCpoCoUn("AEL_CUSTD")
						aCols[nx][nPCustd]	:= nCustD
					EndIf
					aCols[nX][Len(aHeaderSV[nPosInsm])+1] := .F.
					dbSkip()
				EndDo
			EndIf

			n := aSavN[nPosInsm]
			aColsSV[nPosInsm] := aClone(aCols)
		EndIf

		If nFolder <> nPosRTar
			oFolder:SetOption( nPosRTar )

			MsgAlert( STR0147 )
			oFolder:SetOption( nPosInsm )
		Else
			oFolder:SetOption( nPosEvnt )
		EndIf
	EndIf

	// Recalcula o custo conforme a composicao auxiliar informada
	A203GDCalcCust()
EndIf

RestArea(aArea)
RestArea(aAreaAJT)
RestArea(aAreaAJU)
RestArea(aAreaAEH)
RestArea(aAreaAJX)
RestArea(aAreaAEJ)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMS203REL ºAutor  ³Clovis Magenta     º Data ³  26/03/09    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta funcao ira verificar se o relacionamento desejado teraº±±
±±º          ³ referencia circular ou nao. (não verifica todos as possibi-º±±
±±º			 ³ lidades de referencia circular,sendo especifica)           º±±
±±º			 ³ Irá procurar no caminho feito pela amarração de baixo para º±±
±±º			 ³ cima, onde nao devera encontrar nenhuma tarefa/edt que já  º±±
±±º			 ³ tenha sido amarrada anteriormente.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS203VAJ4, PMS203VAFD                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMS203REL(cProjet,cRevisa,cPredec, cTarefa, cEdtPai, cAlias)
Local aEdts := {}
Local nX 	:= 0
Local lRet 	:= .T.
Local aPredecs := {}

DEFAULT cTarefa := ""

If !Empty(cTarefa)
	aAdd(aPredecs,Alltrim(cTarefa))
EndIf

aAdd(aPredecs,Alltrim(cPredec))

////////////////////////////////////////////////////////////////
// VERIFICA RELACIONAMENTOS ENTRE TAREFAS DE BAIXO PARA CIMA. //
////////////////////////////////////////////////////////////////
If cAlias == "AFD"

	dbSelectArea("AFD")
	dbSetOrder(1) //AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA+AFD_ITEM
	If dbSeek(xFilial("AFD")+cProjet+cRevisa+cPredec)
		If aScan(aPredecs,{|x| x == Alltrim(AFD->AFD_PREDEC)}) > 0 //Encontrou predecessora que causa referencia circular
			lRet := .F.
		Else
			 lRet := PMS203REL(cProjet,cRevisa,AFD->AFD_PREDEC,,cEdtPai,"AFD")
			 IF !lRet
			 	Return .F.
			 Endif
		EndIf
	Else

		/////////////////////////////////////////////////////////////////
		// VERIFICA RELACIONAMENTOS ENTRE TAREFA E EDT, CASO ENCONTRE, //
	    // 			ANALISA TODAS AS TAREFAS FILHAS DESTA EDT          //
		/////////////////////////////////////////////////////////////////
		dbSelectArea("AJ4")
		dbSetOrder(1) // AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA+AJ4_ITEM
		If dbSeek(xFilial("AJ4")+cProjet+cRevisa+cPredec)
			aAdd(aPredecs,Alltrim(AJ4->AJ4_PREDEC))

			Pms203EdtF(AJ4_PREDEC,cProjet,cRevisa,aEdts)
	        If (nPos:= aScan(aEdts, { |x| x == cEdtPai }) > 0)
	           	Return .F.
	        EndIf

			For nX:=1 to Len(aEdts)

				dbSelectArea("AF9")
				dbSetOrder(2) 	//AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI+AF9_ORDEM
				If dbSeek(xFilial("AF9")+cProjet+cRevisa+aEdts[nX])
					While AF9->(!EOF()) .AND. (xFilial("AF9")+cProjet+cRevisa+aEdts[nX] == xFilial("AF9")+AF9->(AF9_PROJET+AF9_REVISA+AF9_EDTPAI))

						dbSelectArea("AFD")
						dbSetOrder(1)	//AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA+AFD_ITEM
						If dbSeek(xFilial("AFD")+cProjet+cRevisa+AF9->AF9_TAREFA)
							If aScan(aPredecs,{|x| x == Alltrim(AFD->AFD_PREDEC)}) > 0 //Encontrou predecessora que causa referencia circular
								Return .F.
							EndIf
						EndIf

						AF9->( dbSkip() )
					EndDo
			    EndIf
			Next nX
		EndIf
	Endif

Elseif cAlias == "AJ4"


	Pms203EdtF(AJ4_PREDEC,cProjet,cRevisa,aEdts)
	If (nPos:= aScan(aEdts, { |x| x == cEdtPai }) > 0) .or. !lRet
		Return .F.
	EndIf

	For nX:=1 to Len(aEdts)

		dbSelectArea("AF9")
		dbSetOrder(2) 	//AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI+AF9_ORDEM
		If dbSeek(xFilial("AF9")+cProjet+cRevisa+aEdts[nX])
			While AF9->(!EOF()) .AND. (xFilial("AF9")+cProjet+cRevisa+aEdts[nX] == xFilial("AF9")+AF9->(AF9_PROJET+AF9_REVISA+AF9_EDTPAI))

				dbSelectArea("AFD")
				dbSetOrder(1)	//AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA+AFD_ITEM
				If dbSeek(xFilial("AFD")+cProjet+cRevisa+AF9->AF9_TAREFA)
					If aScan(aPredecs,{|x| x == Alltrim(AFD->AFD_PREDEC)}) > 0 //Encontrou predecessora que causa referencia circular
						Return .F.
					EndIf
				EndIf

				AF9->( dbSkip() )
			EndDo
	    EndIf
	Next nX
Endif

aPredecs := {}

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSVLDRDZ ºAutor  ³Clovis Magenta      ºData  ³07/15/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que validara o recurso informado na alteracao    º±±
±±º          ³da tarefa de um projeto. Chamada via X3_VALID           º±±
±±º          ³do campos AFA_RECURS e utilizada para SSIM.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ X3_VALID do campo AFA_RECURS							  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PmsVldRDZ()

Local lOk := .T.

If SuperGetMV("MV_QTMKPMS",.F.,1) == 3 .Or. SuperGetMV("MV_QTMKPMS",.F.,1) == 4 //Integracao entre PMSxTMKxQNC
	lOk := !EMPTY(RDZRetEnt("AE8",xFilial("AE8")+M->AFA_RECURS,"QAA",,,,.F.))
EndIf

If !lOk
	Aviso(STR0014,STR0132,{STR0042},1,STR0133) // "Atencao" // ""O recurso escolhido não está relacionado a um usuário do QAA ou não foi encontrado registro de AE8 na tabela RDZ, corrija o relacionamento!""
																			// "Problema Relacional" // "OK"
EndIf
Return lOk

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
/// Implantação da melhoria da versao 11 do Protheus - Calculo de esforço 			///
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSEsfTrf ºAutor  ³Clovis Magenta      º Data ³  20/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que fará o recalculo dos percentuais(AFA_ALOC) e/ou º±±
±±º          ³ Quantidade(AFA_QUANT) e/ou Duração(AF9_HDURAC) baseado no  º±±
±±º          ³ novo total de esforço da tarefa (AF9_HESF).                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gatilho - SX7 (AF9_HESF)                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSEsfTrf()

Local cTipo 	:= M->AF9_TPTRF
Local cAgenda 	:= M->AF9_AGCRTL
Local nDurac	:= M->AF9_HDURAC
Local nGet 		:= Iif(Type("oFolder")="O",oFolder:nOption,1)
Local nFolRec  := FolderOrd(STR0040)
Local aHeadRec	:= aClone(aHeaderSV[nFolRec])
Local aColsRec	:= iif(nGet==nFolRec, aClone(aCols), aClone(aColsSV[nFolRec]) )
Local nPosAloc := aScan(aHeadRec,{|x| Alltrim(x[2])=="AFA_ALOC" })
Local nPosRec  := aScan(aHeadRec,{|x| Alltrim(x[2])=="AFA_RECURS" })
Local nPosQuant:= aScan(aHeadRec,{|x| Alltrim(x[2])=="AFA_QUANT" })
Local nQtdEsf	:=	&(ReadVar())
Local nX			:= 0
Local nTotalEsf:= 0
Local nIndProp := 0
Local nValidas := 0
Local nQtdMaior:= 0
Local nPosValida := 0

Do Case
   /*
   #######################///////////###////////////######################
	///////////////////////////////////#///////////////////////////////////
   #######################///////////###/////////////#####################
	*/
	CASE cTipo $ "1" // Duração fixa
		//Alterei as hrs de esforço da tarefa e a duração é fixa
		//Altera a quantidade do recurso e proporciona o % alocado

		For nX:=1 to Len(aColsRec)
			If !LinDelet(aColsRec[nx]) //pula linha deletada
				nTotalEsf += aColsRec[nx][nPosQuant]
				nValidas++
				nPosValida := nX
			Endif
		Next nX

		If nValidas==1

			nProporc := (nQtdEsf*100)/nDurac

			aColsRec[nPosValida][nPosAloc]  := nProporc
			aColsRec[nPosValida][nPosQuant] := nDurac * (nProporc/100)

		else

			nProporc := ((nQtdEsf-nTotalEsf)*100)/nTotalEsf
			nIndProp := (nProporc/100)+1
			For nX:=1 to Len(aColsRec)
				If !LinDelet(aColsRec[nx]) //pula linha deletada
					aColsRec[nx][nPosAloc]  := aColsRec[nx][nPosAloc]  * nIndProp
					aColsRec[nx][nPosQuant] := aColsRec[nx][nPosQuant] * nIndProp
				EndIf
			Next nX
		EndIf

   /*
   #######################/////////###/###//////////######################
	/////////////////////////////////#///#/////////////////////////////////
   #######################/////////###/###///////////#####################
	*/
	CASE cTipo == "2" //Esforço fixo
		//% alocação se mantem quando altero o esforço total da tarefa

		For nX:=1 to Len(aColsRec)
			If !LinDelet(aColsRec[nx])
				nTotalEsf += aColsRec[nx][nPosQuant]
			EndIf
		Next nX
		nIndProp := nQtdEsf/nTotalEsf

		For nX:=1 to Len(aColsRec)
			If !LinDelet(aColsRec[nx])   //pula linha deletada
				aColsRec[nx][nPosQuant] := aColsRec[nx][nPosQuant] * nIndProp
			Endif
		Next nX

		Pms203DtFim(aHeadRec,aColsRec)

   /*
   #######################/////////###/###/###/////////######################
	/////////////////////////////////#///#///#////////////////////////////////
   #######################/////////###/###/###//////////#####################
	*/
	CASE cTipo == "3" // unidades fixas

		For nX:=1 to Len(aColsRec)
			If !LinDelet(aColsRec[nx]) //pula linha deletada
				nTotalEsf += aColsRec[nx][nPosQuant]
				nValidas++
				nPosValida := nX
			Endif
		Next nX

		If nValidas==1
			nProporc := (nQtdEsf*100)/nDurac
			aColsRec[nPosValida][nPosQuant] := nDurac * (nProporc/100)
		else
 			nProporc := ((nQtdEsf-nTotalEsf)*100)/nTotalEsf
			nIndProp := (nProporc/100)+1
			For nX:=1 to Len(aColsRec)
				If !LinDelet(aColsRec[nx]) //pula linha deletada
					aColsRec[nx][nPosQuant] := aColsRec[nx][nPosQuant] * nIndProp
				EndIf
				If (aColsRec[nx][nPosQuant] > nQtdMaior)
					nQtdMaior := aColsRec[nx][nPosQuant]
				EndIf
			Next nX
		EndIf
		M->AF9_HDURAC := nQtdMaior
		Pms203DtFim(aHeadRec, aColsRec, M->AF9_HDURAC)

EndCase

If nGet == nFolRec
	aCols := aClone(aColsRec)
Else
	aColsSV[nFolRec] := aClone(aColsRec)
EndIf

If !IsAuto() .and. Type("oEnch")=="O"
	oEnch:Refresh()
EndIf

If !IsAuto()
	oGD[nFolRec]:oBrowse:Refresh()
EndIf

Return cTipo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSEsfDur ºAutor  ³Clovis Magenta      º Data ³  20/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que recalcula os percentuais (AFA_ALOC) e/ou Qtdes  º±±
±±º          ³ (AFA_QUANT) baseado na nova duração digitada.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA203                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSEsfDur(nTpTrf)

Local nGet 		:= Iif(Type("oFolder")="O",oFolder:nOption,1)
Local nFolRec  := FolderOrd(STR0040)
Local aHeadRec	:= aClone(aHeaderSV[nFolRec])
Local aColsRec	:= iif(nGet==nFolRec, aClone(aCols), aClone(aColsSV[nFolRec]) )
Local nPosAloc := aScan(aHeadRec,{|x| Alltrim(x[2])=="AFA_ALOC" })
Local nPosRec  := aScan(aHeadRec,{|x| Alltrim(x[2])=="AFA_RECURS" })
Local nPosQt   := aScan(aHeadRec,{|x| Alltrim(x[2])=="AFA_QUANT" })
Local nDurac	:=	M->AF9_HDURAC
Local nX 		:= 0
Local nTotalEsf:=0

If (nPosAloc>0) .and. (nPosRec>0) .and. (nPosQt>0)
	Do Case
		Case nTpTrf == "1"
	   /*
	   #######################///////////###////////////######################
		///////////////////////////////////#///////////////////////////////////
	   #######################///////////###/////////////#####################
		*/
			If (M->AF9_AGCRTL=="1")
				For nX:=1 to Len(aColsRec)
					If !LinDelet(aColsRec[nx]) .and. nPosAloc>0 //completa a quantidade e alocação zeradas para 100%
						nTotalEsf += (aColsRec[nx][nPosAloc]/100)*10 //Exemplo: 100% - 10h // 50% - 5h
					EndIf
				Next nX

				For nX:=1 to Len(aColsRec)
					If !LinDelet(aColsRec[nx]) .and. nPosQt>0 .and. nPosAloc>0   //pula linha deletada
					  	aColsRec[nx][nPosQt] := (aColsRec[nx][nPosAloc]/100)*nDurac
					EndIf
				Next nX
			else
				aAuxRet	:= PMSDTaskF(M->AF9_START,M->AF9_HORAI,M->AF9_CALEND,nDurac,M->AF9_PROJET,Nil)
				M->AF9_START := aAuxRet[1]
				M->AF9_HORAI := aAuxRet[2]
				M->AF9_FINISH:= aAuxRet[3]
				M->AF9_HORAF := aAuxRet[4]
				Pms203Msg(STR0011) //"A data final prevista foi recalculada de acordo com o calendario e a duracao da tarefa."
				For nX:=1 to Len(aColsRec)
					If !LinDelet(aColsRec[nx])
						If nPosRec>0 .and. nPosQt>0 .and. AE8->(dbSeek(xFilial("AE8")+aCols[nX][nPosRec]))
							aColsRec[nX][nPosQt] := PmsIAFAQuant(M->AF9_PROJET,M->AF9_REVISA,M->AF9_TAREFA,aCols[nX][aScan(aHeadRec,{|x| AllTrim(x[2])=="AFA_PRODUT"})],M->AF9_QUANT,(aCols[nX][nPosAloc]*PmsHrsItvl(M->AF9_START,M->AF9_HORAI,M->AF9_FINISH,M->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,M->AF9_CALEND),M->AF9_PROJET,AE8->AE8_RECURS))/100,nDurac,,aCols[nX][aScan(aHeadRec,{|x| AllTrim(x[2])=="AFA_RECURS"})])
							If nPosAloc>0 .and. ReadVar()=="M->AF9_HESF"
								aColsRec[nX][nPosAloc]:= (PmsAFAQuant(M->AF9_PROJET,M->AF9_REVISA,M->AF9_TAREFA,aCols[nX][aScan(aHeadRec,{|x| AllTrim(x[2])=="AFA_PRODUT"})],M->AF9_QUANT,aCols[nX][nPosQt],nDurac,,aCols[nX][aScan(aHeadRec,{|x| AllTrim(x[2])=="AFA_RECURS"})])/PmsHrsItvl(M->AF9_START,M->AF9_HORAI,M->AF9_FINISH,M->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,M->AF9_CALEND),M->AF9_PROJET,AE8->AE8_RECURS))*100
							EndIf
						EndIf
					Endif
				Next nX
		Endif
	   /*
	   #######################/////////###/###//////////######################
		/////////////////////////////////#///#/////////////////////////////////
	   #######################/////////###/###///////////#####################
		*/
		Case nTpTrf == "2"
			For nX:=1 to Len(aColsRec)
				If !LinDelet(aColsRec[nx]) .and. nPosAloc>0 .and. nPosQt>0
					aColsRec[nx][nPosAloc]  := (aColsRec[nx][nPosQt]/nDurac)*100
				EndIf
			Next nX

	   /*
	   #######################/////////###/###/###/////////######################
		/////////////////////////////////#///#///#////////////////////////////////
	   #######################/////////###/###/###//////////#####################
		*/
		Case nTpTrf == "3"
		   For nX:=1 to Len(aColsRec)          //Só proporcionarei as linhas que estiverem com % compativel com a duração anterior
				If !LinDelet(aColsRec[nx]) .and. nPosAloc>0 .and. nPosQt>0
					aColsRec[nx][nPosQt]  := (aColsRec[nx][nPosAloc]/100)*nDurac
				EndIf
			Next nX

	EndCase
Endif
If nGet == nFolRec
	aCols := aClone(aColsRec)
Else
	aColsSV[nFolRec] := aClone(aColsRec)
EndIf

If !IsAuto() .and. Type("oEnch")=="O"
	oEnch:Refresh()
EndIf

If !IsAuto()
	oGD[nFolRec]:oBrowse:Refresh()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³P203SomaEsfºAutor  ³Clovis Magenta      º Data ³  20/08/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que fará a soma de todos os esforços existentes de  º±±
±±º          ³ recursos na tarefa no campo AF9_HESF                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA203                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function P203SomaEsf()

Local nCount 	:= 0
Local nPosQt		:= aScan(aHeader,{|x|AllTrim(x[2])=="AFA_QUANT"})
Local nTotalEsf:= 0
If nPosQt>0
	For nCount:=1 to len(aCols)
		If !LinDelet(aCols[nCount])
			nTotalEsf += aCols[nCount][nPosQt]
		EndIf
	Next nCount
endif
M->AF9_HESF := nTotalEsf

If !IsAuto() .and. Type("oEnch")="O"
	oEnch:Refresh()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsAgendEsfºAutor  ³Clovis Magenta     º Data ³  20/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que fará toda a redistribuição de recursos na tarefaº±±
±±º          ³ dependendo do campo alterado e das configurações existentesº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA203                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAgendEsf()

Local nGet 		:= Iif(Type("oFolder")="O",oFolder:nOption,1)
Local nFolRec  := FolderOrd(STR0040)
Local aHeadRec	:= aClone(aHeaderSV[nFolRec])
Local aColsRec	:= iif(nGet==nFolRec, aClone(aCols), aClone(aColsSV[nFolRec]) )
Local nPosAloc := aScan(aHeadRec,{|x| Alltrim(x[2])=="AFA_ALOC" })
Local nPosQuant:= aScan(aHeadRec,{|x| Alltrim(x[2])=="AFA_QUANT" })
Local nQtdEsf	:=	M->AF9_HESF
Local nTpTrf	:=	M->AF9_TPTRF
Local nX			:= 0
Local nY			:= 0
Local nTotalEsf:= 0
Local nAloc		:= 0
Local nIndProp := 0
Local nValidas := 0
Local nQtdMaior:= 0
Local nAlocMaior:= 0
Local aLinhas	:= {}
Local nPode		:=0

Do Case
   /*
   #######################///////////###////////////######################
	///////////////////////////////////#///////////////////////////////////
   #######################///////////###/////////////#####################
	*/
	Case nTpTrf == "1"    // Duração Fixa

		For nX:=1 to Len(aColsRec)
			If !LinDelet(aColsRec[nx]) 	//completa a quantidade e alocação zeradas para 100%
				If (aColsRec[nX][nPosQuant]==0) .and. (aColsRec[nX][nPosAloc]==0)
					aColsRec[nX][nPosQuant] := nQtdMaior
					aColsRec[nX][nPosAloc]  := nAlocMaior
				EndIf

				nTotalEsf += (aColsRec[nx][nPosAloc]/100)*10 //Exemplo: 100% - 10h // 50% - 5h
			EndIf
		Next nX

		For nX:=1 to Len(aColsRec)
			If !LinDelet(aColsRec[nx])   //pula linha deletada
				nProporc := (aColsRec[nx][nPosAloc]/100)*10

				nIndProp := nProporc/nTotalEsf // Proporção de qto o recurso trabalho por dia

				aColsRec[nx][nPosQuant] := nQtdEsf * nIndProp
				aColsRec[nx][nPosAloc]  := (aColsRec[nx][nPosQuant]*100)/M->AF9_HDURAC
			EndIf
		Next nX

   /*
   #######################/////////###/###//////////######################
	/////////////////////////////////#///#/////////////////////////////////
   #######################/////////###/###///////////#####################
	*/
	Case nTpTrf == "2"  // Trabalho Fixo

		For nX:=1 to Len(aColsRec)      // valor 10 é para referencia
			If !LinDelet(aColsRec[nx])   //pula linha deletada
				nTotalEsf += (aColsRec[nx][nPosAloc]/100)*10 //Exemplo: 100% - 10h // 50% - 5h
			EndIf
		Next nX

		For nX:=1 to Len(aColsRec)
			If !LinDelet(aColsRec[nx])   //pula linha deletada
				nProporc := (aColsRec[nx][nPosAloc]/100)*10

				nIndProp := nProporc/nTotalEsf // Proporção de qto o recurso trabalho por dia

				aColsRec[nx][nPosQuant] := nQtdEsf * nIndProp
			EndIf
		Next nX

		// Reajusta a duração da tarefa para ser igual a maior quantidade de hrs informada
		For nX:=1 to Len(aColsRec)
			If !LinDelet(aColsRec[nx]) .and. (aColsRec[nx][nPosQuant] > nQtdMaior)
				nQtdMaior  := aColsRec[nx][nPosQuant]
			EndIf
		Next nX

		M->AF9_HDURAC := nQtdMaior

   /*
   #######################/////////###/###/###/////////######################
	/////////////////////////////////#///#///#////////////////////////////////
   #######################/////////###/###/###//////////#####################
	*/
	Case nTpTrf == "3"  // Unidades fixas c/ agendamento

		If aColsRec[n][nPosQuant]==0
			For nX:=1 to Len(aColsRec)      // valor 10 é para referencia
				If !LinDelet(aColsRec[nx])   //pula linha deletada
					nTotalEsf += (aColsRec[nx][nPosAloc]/100)*10 //Exemplo: 100% - 10h // 50% - 5h
				EndIf
			Next nX

			For nX:=1 to Len(aColsRec)
				If !LinDelet(aColsRec[nx])   //pula linha deletada
					nProporc := (aColsRec[nx][nPosAloc]/100)*10

					nIndProp := nProporc/nTotalEsf // Proporção de qto o recurso trabalho por dia

					aColsRec[nx][nPosQuant] := nQtdEsf * nIndProp
				EndIf
			Next nX

			// Reajusta a duração da tarefa para ser igual a maior quantidade de hrs informada
			For nX:=1 to Len(aColsRec)
				If !LinDelet(aColsRec[nx]) .and. (aColsRec[nx][nPosQuant] > nQtdMaior)
					nQtdMaior  := aColsRec[nx][nPosQuant]
				EndIf
			Next nX

			M->AF9_HDURAC := nQtdMaior
		EndIf

EndCase

// atualiza o aCols principal
If nGet == nFolRec
	aCols := aClone(aColsRec)
Else
	aColsSV[nFolRec] := aClone(aColsRec)
EndIf

If !IsAuto()
	oGD[nFolRec]:oBrowse:Refresh()
EndIf

P203SomaEsf()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSSelecAgeºAutor  ³Clovis Magenta     º Data ³  20/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao chamada no gatilho(SX7) do campo AF9_TPTRF. Quando  º±±
±±º          ³ tipo da tarefa igual "Trabalho Fixo" = Agendamento Forçado º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ gatilho - SX7                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSSelecAge()
Local cNewValue := ""
Local cTpTarefa := &(ReadVar())

If cTpTarefa == "2" 		// Trabalho Fixo
	cNewValue := "1" // Sim - Agendamento forçado
Else
	cNewValue := "2"
EndIf
Return cNewValue


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSAltAgendºAutor  ³Clovis Magenta     º Data ³  20/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao chamada pelo X3_WHEN do campo AF9_AGCRTL.           º±±
±±º          ³ Quando utilizamos Tarefa tipo "Trabalho Fixo", este campo  º±±
±±º          ³ deverá ficar desabilitado.                       			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ X3_WHEN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAltAgend()
Local lPermite := .T.
Local cTpTarefa := M->AF9_TPTRF

If cTpTarefa == "2"   // Trabalho fixo
	lPermite:= .F.
EndIf

Return lPermite

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A203AGEN  ºAutor  ³Clovis Magenta   		 Data ³  20/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função chamada via botão de redistribuição de agendamento  º±±
±±º          ³ dos recursos na tarefa. Funciona mais corretamente quando  º±±
±±º          ³ usuario informa recursos sem colocar % e quantidade        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA203                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203Agen()
Local lRet := .F.

lRet := M->AF9_TPTRF == "2"

Return !lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  Pms203DtFimºAutor  ³Clovis Magenta      º Data ³  20/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que Recalcula a Data e Hora Final baseado no agenda-º±±
±±º          ³ mento de recursos alocados na tarefa                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ pmsa203                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms203DtFim(aHeadRec, aColsRec, nDurac)
Local aAuxRet	:= {}
Local cCalendar:=""
Local nPosRec  := aScan(aHeadRec,{|x| Alltrim(x[2])=="AFA_RECURS"})
Local nPosQuant:= aScan(aHeadRec,{|x| Alltrim(x[2])=="AFA_QUANT"})
Local nX			:= 0
Local nY			:= 0
DEFAULT nDurac := M->AF9_HDURAC

dbSelectArea("AE8")
dbSetOrder(1)

If (nPosRec>0) .and. (LenVal(aColsRec)==1) .and. (Empty(aColsRec[1][nPosRec])) // Caso seja a primeira linha
	aAuxRet	:= PMSDTaskF(M->AF9_START,M->AF9_HORAI,M->AF9_CALEND,nDurac,M->AF9_PROJET,Nil)
	M->AF9_START := aAuxRet[1]
	M->AF9_HORAI := aAuxRet[2]
	M->AF9_FINISH:= aAuxRet[3]
	M->AF9_HORAF := aAuxRet[4]
Else
	// Caso nao seja a primeira linha de recursos verifica a duração(inicio e fim) de cada recurso e pega a maior Dt Fim
	If ((LenVal(aColsRec)>0)) .or. ((LenVal(aColsRec)==1) .and. !(Empty(aColsRec[1][nPosRec])) .and. !(Empty(aColsRec[1][nPosQuant])) )
	 	For nX:= 1 to Len(aColsRec)
	 		if !LinDelet(aColsRec[nx])
				dbSeek(xFilial("AE8")+aColsRec[nX][nPosRec])

				If EMPTY(AE8->AE8_CALEND)
					cCalendar := M->AF9_CALEND
				Else
					cCalendar := AE8->AE8_CALEND
				EndIf
				nDurac := aColsRec[nX][nPosQuant]
				AADD(aAuxRet, PMSDTaskF(M->AF9_START,M->AF9_HORAI,cCalendar,nDurac,M->AF9_PROJET,Nil))
			EndIf
		Next nX
		aSort(aAuxRet,,,{|x,y| dtos(x[3])+x[4]>dtos(y[3])+y[4]})  //ordena por data final + hora final
		M->AF9_START := aAuxRet[1][1]
		If Len(aAuxRet) > 1
			For nY := 1 to Len(aAuxRet)
				If M->AF9_HORAI > aAuxRet[nY][2]
					M->AF9_HORAI := aAuxRet[nY][2]
				EndIf
				If M->AF9_HORAF < aAuxRet[nY][4]
					M->AF9_HORAF := aAuxRet[nY][4]
				EndIf
			Next
		Else
			M->AF9_HORAI := aAuxRet[1][2]
			M->AF9_HORAF := aAuxRet[1][4]
		EndIf		
		M->AF9_FINISH:= aAuxRet[1][3]
		M->AF9_HDURAC := PmsHrsItvl(M->AF9_START,M->AF9_HORAI,M->AF9_FINISH,M->AF9_HORAF,M->AF9_CALEND) //Calcula Duração a partir do calendário PMSXFUN
	EndIf
EndIf

If !IsAuto() .and. Type("oEnch")=="O"
	oEnch:Refresh()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A203AtuEdtºAutor  ³Clovis Magenta      º Data ³  20/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao recursiva que atualiza o valor total de esforço das º±±
±±º          ³ tarefas em suas EDT´s Pais	                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA203 - 203GRAVA()		                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203AtuEdt(cProjeto,cRevisa,cEDT)

Local nHrsEsf	:= 0
Local aArea		:= GetArea()
Local aAreaAFC	:= AFC->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())

dbSelectArea("AF9")
dbSetOrder(2) // PROJETO + REVISA + EDTPAI
MsSeek(xFilial("AF9")+cProjeto+cRevisa+cEDT)
While !Eof().And.AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI==;
				xFilial("AF9")+cProjeto+cRevisa+cEDT
	nHrsEsf += AF9->AF9_HESF
    AF9->(dbSkip())
EndDo

dbSelectArea("AFC")
dbSetOrder(2) // PROJETO + REVISA + EDTPAI
MsSeek(xFilial("AFC")+cProjeto+cRevisa+cEDT)
While !Eof().And.AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI==;
				xFilial("AFC")+cProjeto+cRevisa+cEDT
	nHrsEsf += AFC->AFC_HESF
	AFC->(dbSkip())
EndDo

dbSelectArea("AFC")
dbSetOrder(1) // PROJETO + REVISA + EDT
If DbSeek(xFilial("AFC")+cProjeto+cRevisa+cEDT)
	RecLock("AFC",.F.)
		AFC->AFC_HESF := nHrsEsf
	MsUnlock()

	A203AtuEdt(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDTPAI)
Endif

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/// Implantação da melhoria da versao 11 do Protheus - Restriçoes  ///
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// 1 - iniciar
// 2 - terminar
// 3 - nao iniciar antes
// 4 - nao iniciar depois
// 5 - nao terminar antes
// 6 - nao terminar depois
// 7 - o mais breve
// 8 - o mais tarde

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA203RestriºAutor  ³Clovis Magenta      º Data ³  16/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação da Inclusao da tarefa para validação SOMENTE da  º±±
±±º          ³ propria tarefa. Teremos outra funcao chamada PA203VldRes() º±±
±±º          ³ porem, para as datas de outras tarefas simuladas.		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PmsSimScs - pmsxfuna                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA203Restri(lAviso)
Local aArea			:= getArea()
Local aAreaAF8			:= AF8->(getArea())
Local aAreaAFC			:= AFC->(getArea())
Local aAreaAF9			:= AF9->(getArea())
LOCAL cStart 		:= DtoS(M->AF9_START)
LOCAL cFinish		:= DtoS(M->AF9_FINISH)
LOCAL cHorai 		:= M->AF9_HORAI
LOCAL cHoraF 		:= M->AF9_HORAF
Local cDataRest 	:= DtoS(M->AF9_DTREST)  // Data restricao
Local cHoraRest  	:= M->AF9_HRREST  // Hora restricao
Local lOk	 	  	:= .T.
Local cRestricao 	:= ""

DEFAULT lAviso 	:= .T.

cHorai := SubStr(cHorai,1,2)+SubStr(cHorai,4,2)
cHoraF := SubStr(cHoraF,1,2)+SubStr(cHoraF,4,2)
cHoraRest := SubStr(cHoraRest,1,2)+SubStr(cHoraRest,4,2)

If !(M->AF9_RESTRI$"7/8") .and. (!Empty(M->AF9_DTREST) .AND. !Empty(M->AF9_HRREST))
	cRestricao := M->AF9_RESTRI
 	Do case
		Case cRestricao == "1"  // iniciar em

			If (cStart+cHorai)<>(cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0014,STR0134,{STR0042},1,STR0133) // "Atencao" // // "Problema Relacional" // "A Data/Hora Inicial da Tarefa inconsistente com a restrição da tarefa."
				Endif
			EndIf

		Case cRestricao == "2"  // terminar em

			If (cFinish+cHoraF) <> (cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0014,STR0139,{STR0042},1,STR0133) // "Atencao" // // "Problema Relacional" // "A Data/Hora Final da Tarefa inconsistente com o relacionamento entre tarefas."
				EndIf
			EndIf

		Case cRestricao == "3"  // nao iniciar antes
			If (cStart+cHorai)<(cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0014,STR0134,{STR0042},1,STR0133) // "Atencao" // // "Problema Relacional" // "A Data/Hora Inicial da Tarefa inconsistente com a restrição da tarefa."
				EndIf
			EndIf

		Case cRestricao == "4"  // nao iniciar depois
			If (cStart+cHorai)>(cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0014,STR0134,{STR0042},1,STR0133) // "Atencao" // // "Problema Relacional" // "A Data/Hora Inicial da Tarefa inconsistente com a restrição da tarefa."
				EndIf
			EndIf

		Case cRestricao == "5"  // nao terminar antes
			If (cFinish+cHoraF)<(cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0014,STR0139,{STR0042},1,STR0133) // "Atencao" // // "Problema Relacional" // "A Data/Hora Final da Tarefa inconsistente com o relacionamento entre tarefas."
				EndIf
			EndIf

		Case cRestricao == "6"  // nao terminar depois
			If (cFinish+cHoraF)>(cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0014,STR0139,{STR0042},1,STR0133) // "Atencao" // // "Problema Relacional" // "A Data/Hora Final da Tarefa inconsistente com o relacionamento entre tarefas."
				EndIf
			EndIf

		Case cRestricao == "7"  // O mais breve possivel
			If cStart < DtoS(AF8->AF8_START)
				If lAviso
					lOk:= Aviso(STR0135,STR0136,{STR0086,STR0087},2) ==1 // Inicio do projeto //"Esta data e hora da tarefa fará com que o projeto seja iniciado mais cedo. Deseja Continuar?"
				Endif
			EndIf

		Case cRestricao == "8"  // O mais tarde possivel
			If cFinish > DtoS(AF8->AF8_FINISH)
				If lAviso
					lOk := Aviso(STR0137,STR0138,{STR0086,STR0087},2) ==1	// Fim do projeto // "Esta data e hora da tarefa fará com que o projeto seja finalizado mais tarde. Deseja Continuar?"
				Endif
			EndIf

	EndCase

EndIf

If lOk

	If cRestricao $ "1,3,4" // inicio
		If !(lOk := PMS203DINI())
			If lAviso
				Aviso(STR0014,STR0134,{STR0042},1,STR0133) // "Atencao" // // "Problema Relacional" // "A Data/Hora Final da Tarefa inconsistente com o relacionamento entre tarefas."
			Endif
		EndIf
	ElseIf cRestricao $ "2,5,6" // fim
		If !(lOk := PMS203DFIM(.F.))
			If lAviso
				Aviso(STR0014,STR0139,{STR0042},1,STR0133) // "Atencao" // // "Problema Relacional" // "A Data/Hora Final da Tarefa inconsistente com o relacionamento entre tarefas."
			Endif
		EndIf
	EndIF
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aAreaAF8)
RestArea(aArea)

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA203VldResºAutor  ³Clovis Magenta      º Data ³  16/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida as novas datas e horas de uma determinada tarefa	  º±±
±±º          ³ 															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PmsSimScs - pmsxfuna                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA203VldRes(aTrfDados, nReg, lAviso)
/*
/////////////////////////////
// Composição do aTrfDados //
// SIM_START  3            //
// SIM_HORAI  4            //
// SIM_FINISH 5            //
// SIM_HORAF  6            //
/////////////////////////////
*/
Local aArea	 		:= GetArea()
Local aAreaAFD 	:= AFD->(GetArea())
Local aAreaAF9 	:= AF9->(GetArea())
Local	cStart 		:= DtoS(aTrfDados[nReg][3])
Local	cFinish		:= DtoS(aTrfDados[nReg][5])
Local	cHorai 		:= SubStr(aTrfDados[nReg][4],1,2)+SubStr(aTrfDados[nReg][4],4,2)
Local	cHoraF 		:= SubStr(aTrfDados[nReg][6],1,2)+SubStr(aTrfDados[nReg][6],4,2)
Local	nRecReg		:= aTrfDados[nReg][12]
Local lVarMemo 	:= iIF(Type("lRotSimula")=="U", .F., lRotSimula)

Local cRestricao 	:= ""
Local cDataRest 	:= "" // DtoS(M->AF9_DTREST)  // Data restricao
Local cHoraRest  	:= "" // M->AF9_HRREST  // Hora restricao
Local lOk	 	  	:= .T.

DEFAULT  lAviso		:= !isAuto()

dbselectarea("AF9")
AF9->(DbGoTo(nRecReg)) // Vai até o registro da AF9

If lVarMemo .and. (M->AF9_TAREFA == AF9->AF9_TAREFA)
	cRestricao := M->AF9_RESTRI
	cDataRest  := DTOS(M->AF9_DTREST)
	cHoraRest  := SubStr(M->AF9_HRREST,1,2)+SubStr(M->AF9_HRREST,4,2)
Else
	cRestricao := AF9->AF9_RESTRI
	cDataRest  := DTOS(AF9->AF9_DTREST)
	cHoraRest  := SubStr(AF9->AF9_HRREST,1,2)+SubStr(AF9->AF9_HRREST,4,2)
Endif

If !(cRestricao$"7/8") .and. (!Empty(cDataRest) .AND. !Empty(cHoraRest))
 	Do case
		Case cRestricao == "1"  // iniciar em

			If (cStart+cHorai)<>(cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0014,STR0140+Alltrim(AF9->AF9_TAREFA)+".",{STR0042},1,STR0133) //"A Data/Hora Inicial da Tarefa inconsistente com a restrição da tarefa "
				Endif
			EndIf

		Case cRestricao == "2"  // terminar em

			If (cFinish+cHoraF) <> (cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0014,STR0141+Alltrim(AF9->AF9_TAREFA)+".",{STR0042},1,STR0133) // "A Data/Hora Final da Tarefa inconsistente com a restrição da tarefa "
				EndIf
			EndIf

		Case cRestricao == "3"  // nao iniciar antes
			If (cStart+cHorai)<(cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0014,STR0140+Alltrim(AF9->AF9_TAREFA)+".",{STR0042},1,STR0133) // "A Data/Hora Inicial da Tarefa inconsistente com a restrição da tarefa "
				EndIf
			EndIf

		Case cRestricao == "4"  // nao iniciar depois
			If (cStart+cHorai)>(cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0014,STR0140+Alltrim(AF9->AF9_TAREFA)+".",{STR0042},1,STR0133) // "A Data/Hora Inicial da Tarefa inconsistente com a restrição da tarefa "
				EndIf
			EndIf

		Case cRestricao == "5"  // nao terminar antes
			If (cFinish+cHoraF)<(cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0014,STR0141+Alltrim(AF9->AF9_TAREFA)+".",{STR0042},1,STR0133) // "A Data/Hora Final da Tarefa inconsistente com a restrição da tarefa "
				EndIf
			EndIf

		Case cRestricao == "6"  // nao terminar depois
			If (cFinish+cHoraF)>(cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0014,STR0141+Alltrim(AF9->AF9_TAREFA)+".",{STR0042},1,STR0133) // "A Data/Hora Final da Tarefa inconsistente com a restrição da tarefa "
				EndIf
			EndIf

		Case cRestricao == "7"  // O mais breve possivel
			If cStart < DtoS(AF8->AF8_START)
				If lAviso
					lOk:= Aviso(STR0135,STR0136,{STR0086,STR0087},2) ==1 //"Início do Projeto","Esta data e hora da tarefa fará com que o projeto seja iniciado mais cedo. Deseja Continuar?"
				Endif
			EndIf

		Case cRestricao == "8"  // O mais tarde possivel
			If cFinish > DtoS(AF8->AF8_FINISH)
				If lAviso
					lOk := Aviso(STR0137,STR0138,{STR0086,STR0087},2) ==1	//"Fim do Projeto","Esta data e hora da tarefa fará com que o projeto seja finalizado mais tarde. Deseja Continuar?"
				Endif
			EndIf

	EndCase

EndIf

lPreAnalise := .T.	// VARIAVEL PRIVATE Q INFORMA SE PRECISA VARRER AS TAREFAS SUCESSORES E RECALCULA-LAS

// Verifica se as datas irao interferir nas restrições das EDT Pai
If lOk .and. Iif(type("M->AFC_EDT")=="C",(AF9->AF9_EDTPAI <> M->AFC_EDT), .T.)
	lOk := PA203EdtPai(aTrfDados[nReg] , "AF9")
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAFD)
RestArea(aArea)

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA203EdtPaiºAutor  ³Clovis Magenta      º Data ³  16/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ funcao que verifica se as datas nao conflirarão com as	  º±±
±±º          ³ restriçoes das EDTs Pai CHAMADA pela PA203VldRes(), que    º±±
±±º          ³ por sua vez é chamada pela PmsSimScs() - PMSXFUNA	      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA203EdtPai(aTarefa, cAlias)

Local lCorreto := .T.
Local aArea := GetArea()
Local aAreaAFC := AFC->(GetArea())
Local aAreaAF9 := AF9->(GetArea())
Local cDataI	:= DtoS(aTarefa[3])
Local cDataF	:= DtoS(aTarefa[5])
Local cHoraI	:= Substr( aTarefa[4],1,2)+Substr( aTarefa[4] ,4,2)
Local cHoraF	:= Substr( aTarefa[6],1,2)+Substr( aTarefa[6],4,2)
Local cDtRest  := ""
Local cHrRest  := ""
Local lMsg := !isAuto()

If cAlias == "AF9"
	dbselectArea("AF9")
	dbGoTo(aTarefa[12]) // busca registro atual

	dbSelectArea("AFC")
	dbSetOrder(1)//AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDT+AFC_ORDEM
	If MsSeek(xFilial("AFC")+AF9->(AF9_PROJET+AF9_REVISA+AF9_EDTPAI))

		If (AFC->AFC_RESTRI$"12")
			cDtRest := DtoS(AFC->AFC_DTREST)
			cHrRest := Substr( AFC->AFC_HRREST,1,2)+Substr( AFC->AFC_HRREST ,4,2)
			Do Case

				Case AFC->AFC_RESTRI == "1"
					If (cDataI+cHoraI)<(cDtRest+cHrRest)
						lCorreto := .F.
					   If lMsg
							Alert(STR0142 + Alltrim(AFC_EDTPAI)+ STR0143) //"A data de restrição da EDT´s Pai - ' " + " ' - impede de realizar tal inclusao/alteração."
						endif
					EndIf
				Case AFC->AFC_RESTRI == "2"
					If (cDataF+cHoraF)>(cDtRest+cHrRest)
						lCorreto := .F.
					   If lMsg
							Alert(STR0142 + Alltrim(AFC_EDTPAI)+ STR0143) //"A data de restrição da EDT´s Pai - ' " + " ' - impede de realizar tal inclusao/alteração."
						endif
					EndIf

			EndCase
		Endif

	EndIf

ELSE // cAlias == AFC

	dbSelectArea("AFC")
	dbGoTo(aTarefa[12])
	dbSetOrder(1)//AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDT+AFC_ORDEM
	If MsSeek(xFilial("AFC")+AFC_PROJET+AFC_REVISA+AFC_EDTPAI)

		If AFC->AFC_RESTRI$"12"
			cDtRest := DtoS(AFC->AFC_DTREST)
			cHrRest := Substr( AFC->AFC_HRREST,1,2)+Substr( AFC->AFC_HRREST ,4,2)
			Do Case

				Case AFC->AFC_RESTRI == "1"
					If (cDataI+cHoraI)<(cDtRest+cHrRest)
						lCorreto := .F.
					   If lMsg
							Alert(STR0142 +Alltrim(AFC_EDTPAI)+ STR0143)//"A data de restrição da EDT´s Pai - ' " + " ' - impede de realizar tal inclusao/alteração."
						endif
					EndIf
				Case AFC->AFC_RESTRI == "2"

					If (cDataF+cHoraF)>(cDtRest+cHrRest)
						lCorreto := .F.
					   If lMsg
							Alert(STR0142 +Alltrim(AFC_EDTPAI)+ STR0143)//"A data de restrição da EDT´s Pai - ' " + " ' - impede de realizar tal inclusao/alteração."
						endif
					EndIf

			EndCase
		Endif
	EndIf

Endif

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return lCorreto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA203ResPerºAutor  ³Clovis Magenta      º Data ³  16/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação da duração inclusa na tarefa x Restrição		  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA203ResPer(aOrigDts)
Local lRet := .T.
Local lMsg := !isAuto()

Default aOrigDts := {}

If !(EMPTY(M->AF9_RESTRI) .AND. EMPTY(M->AF9_DTREST))
	Do Case
		Case M->AF9_RESTRI $ "2" // terminar em
			If !((M->AF9_DTREST == M->AF9_FINISH) .and. (M->AF9_HRREST == M->AF9_HORAF))
				M->AF9_START := aOrigDts[1]
				M->AF9_HORAI := aOrigDts[2]
				M->AF9_FINISH:= aOrigDts[3]
				M->AF9_HORAF := aOrigDts[4]
				If lMsg
					Pms203Msg(STR0144) // "Data Final inconsistente com a informada na restrição."
				endif
				lRet := .F.
			EndIf

		Case M->AF9_RESTRI $ "5" // nao terminar antes
			If (DtoS(M->AF9_DTREST)+SubsTr(M->AF9_HRREST,1,2)+SubsTr(M->AF9_HRREST,4,2) > DtoS(M->AF9_FINISH)+ SubsTr(M->AF9_HORAF,1,2)+SubsTr(M->AF9_HORAF,4,2))
				M->AF9_START := aOrigDts[1]
				M->AF9_HORAI := aOrigDts[2]
				M->AF9_FINISH:= aOrigDts[3]
				M->AF9_HORAF := aOrigDts[4]
				If lMsg
					Pms203Msg(STR0144) // "Data Final inconsistente com a informada na restrição."
				endif
				lRet := .F.
			EndIf

		Case M->AF9_RESTRI $ "6" // nao terminar depois
			If (DtoS(M->AF9_DTREST)+SubsTr(M->AF9_HRREST,1,2)+SubsTr(M->AF9_HRREST,4,2) < DtoS(M->AF9_FINISH)+ SubsTr(M->AF9_HORAF,1,2)+SubsTr(M->AF9_HORAF,4,2))
				M->AF9_START := aOrigDts[1]
				M->AF9_HORAI := aOrigDts[2]
				M->AF9_FINISH:= aOrigDts[3]
				M->AF9_HORAF := aOrigDts[4]
				If lMsg
					Pms203Msg(STR0144) // "Data Final inconsistente com a informada na restrição."
				endif
				lRet := .F.
			EndIf

	EndCase
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA203AtuDtsºAutor  ³Clovis Magenta      º Data ³  16/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza as datas e horas de acordo com as restriçoes	  º±±
±±º          ³ gatilhos dos campos dt e hr restrição                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA203AtuDts(cOpc)

Local xConteudo := &(ReadVar())
Local cRestrict := M->AF9_RESTRI
LOCAL cStart 		:= DtoS(M->AF9_START)
LOCAL cFinish		:= DtoS(M->AF9_FINISH)
LOCAL cHorai 		:= M->AF9_HORAI
LOCAL cHoraF 		:= M->AF9_HORAF
Local cDataRest 	:= DtoS(M->AF9_DTREST)  // Data restricao
Local cHoraRest  	:= M->AF9_HRREST  // Hora restricao

cHorai := SubStr(cHorai,1,2)+SubStr(cHorai,4,2)
cHoraF := SubStr(cHoraF,1,2)+SubStr(cHoraF,4,2)
cHoraRest := SubStr(cHoraRest,1,2)+SubStr(cHoraRest,4,2)

Default cOpc := 1

If (cOpc == "1") // gatilho do campo AF9_DTREST

	Do Case
		Case cRestrict $ "1" //INICIAR EM

			If !Empty(M->AF9_HRREST)
				aAuxRet	:= PMSDTaskF(xConteudo, M->AF9_HRREST ,M->AF9_CALEND,M->AF9_HDURAC,M->AF9_PROJET,Nil)
				M->AF9_START := aAuxRet[1]
				M->AF9_HORAI := aAuxRet[2]
				M->AF9_FINISH:= aAuxRet[3]
				M->AF9_HORAF := aAuxRet[4]
			EndIf

		Case cRestrict $ "2" //TERMINAR EM
			If !Empty(M->AF9_HRREST)
				aAuxRet	:= PMSDTaskI(xConteudo, M->AF9_HRREST ,M->AF9_CALEND,M->AF9_HDURAC,M->AF9_PROJET,Nil)
				M->AF9_START := aAuxRet[1]
				M->AF9_HORAI := aAuxRet[2]
				M->AF9_FINISH:= aAuxRet[3]
				M->AF9_HORAF := aAuxRet[4]
			Endif

		Case cRestrict $ "3" //NAO INICIAR ANTES
			If (cStart+cHorai)<(cDataRest+cHoraRest) .AND. !Empty(M->AF9_HRREST)
				aAuxRet	:= PMSDTaskF(xConteudo, M->AF9_HRREST ,M->AF9_CALEND,M->AF9_HDURAC,M->AF9_PROJET,Nil)
				M->AF9_START := aAuxRet[1]
				M->AF9_HORAI := aAuxRet[2]
				M->AF9_FINISH:= aAuxRet[3]
				M->AF9_HORAF := aAuxRet[4]
			EndIf

		Case cRestrict $ "4" //NAO INICIAR DEPOIS
			If (cStart+cHorai)>(cDataRest+cHoraRest) .and. !Empty(M->AF9_HRREST)
				aAuxRet	:= PMSDTaskF(xConteudo, M->AF9_HRREST ,M->AF9_CALEND,M->AF9_HDURAC,M->AF9_PROJET,Nil)
				M->AF9_START := aAuxRet[1]
				M->AF9_HORAI := aAuxRet[2]
				M->AF9_FINISH:= aAuxRet[3]
				M->AF9_HORAF := aAuxRet[4]
			EndIf

		Case cRestrict $ "5" //NAO TERMINAR ANTES
			If (cFinish+cHoraF)<(cDataRest+cHoraRest) .and. !Empty(M->AF9_HRREST)
				aAuxRet	:= PMSDTaskI(xConteudo, M->AF9_HRREST ,M->AF9_CALEND,M->AF9_HDURAC,M->AF9_PROJET,Nil)
				M->AF9_START := aAuxRet[1]
				M->AF9_HORAI := aAuxRet[2]
				M->AF9_FINISH:= aAuxRet[3]
				M->AF9_HORAF := aAuxRet[4]
			Endif

		Case cRestrict $ "6" //NAO TERMINAR DEPOIS
			If (cFinish+cHoraF)>(cDataRest+cHoraRest) .and. !Empty(M->AF9_HRREST)
				aAuxRet	:= PMSDTaskI(xConteudo, M->AF9_HRREST ,M->AF9_CALEND,M->AF9_HDURAC,M->AF9_PROJET,Nil)
				M->AF9_START := aAuxRet[1]
				M->AF9_HORAI := aAuxRet[2]
				M->AF9_FINISH:= aAuxRet[3]
				M->AF9_HORAF := aAuxRet[4]
			Endif

	EndCase

ElseIf (cOpc == "2")  // gatilho do campo AF9_HRREST

	Do Case

		Case cRestrict $ "1"  //INICIAR EM

			If !Empty(M->AF9_DTREST)
				aAuxRet	:= PMSDTaskF(M->AF9_DTREST, xConteudo ,M->AF9_CALEND,M->AF9_HDURAC,M->AF9_PROJET,Nil)
				M->AF9_START := aAuxRet[1]
				M->AF9_HORAI := aAuxRet[2]
				M->AF9_FINISH:= aAuxRet[3]
				M->AF9_HORAF := aAuxRet[4]
			EndIf

		Case  cRestrict $ "2"  // TERMINAR EM

			If !Empty(M->AF9_DTREST)
				aAuxRet	:= PMSDTaskI(M->AF9_DTREST, xConteudo ,M->AF9_CALEND,M->AF9_HDURAC,M->AF9_PROJET,Nil)
				M->AF9_START := aAuxRet[1]
				M->AF9_HORAI := aAuxRet[2]
				M->AF9_FINISH:= aAuxRet[3]
				M->AF9_HORAF := aAuxRet[4]
			Endif

		Case cRestrict $ "3"  //NAO INICIAR ANTES

			If (cStart+cHorai)<(cDataRest+cHoraRest) .AND. !Empty(M->AF9_DTREST)
				aAuxRet	:= PMSDTaskF(M->AF9_DTREST, xConteudo ,M->AF9_CALEND,M->AF9_HDURAC,M->AF9_PROJET,Nil)
				M->AF9_START := aAuxRet[1]
				M->AF9_HORAI := aAuxRet[2]
				M->AF9_FINISH:= aAuxRet[3]
				M->AF9_HORAF := aAuxRet[4]
			EndIf

		Case cRestrict $ "4"  //NAO INICIAR DEPOIS

			If (cStart+cHorai)>(cDataRest+cHoraRest) .and. !Empty(M->AF9_DTREST)
				aAuxRet	:= PMSDTaskF(M->AF9_DTREST, xConteudo ,M->AF9_CALEND,M->AF9_HDURAC,M->AF9_PROJET,Nil)
				M->AF9_START := aAuxRet[1]
				M->AF9_HORAI := aAuxRet[2]
				M->AF9_FINISH:= aAuxRet[3]
				M->AF9_HORAF := aAuxRet[4]
			EndIf

		Case  cRestrict $ "5"  //NAO TERMINAR ANTES

			If (cFinish+cHoraF)<(cDataRest+cHoraRest) .and. !Empty(M->AF9_DTREST)
				aAuxRet	:= PMSDTaskI(M->AF9_DTREST, xConteudo ,M->AF9_CALEND,M->AF9_HDURAC,M->AF9_PROJET,Nil)
				M->AF9_START := aAuxRet[1]
				M->AF9_HORAI := aAuxRet[2]
				M->AF9_FINISH:= aAuxRet[3]
				M->AF9_HORAF := aAuxRet[4]
			Endif

		Case  cRestrict $ "6"  //NAO TERMINAR DEPOIS

			If (cFinish+cHoraF)>(cDataRest+cHoraRest) .and. !Empty(M->AF9_DTREST)
				aAuxRet	:= PMSDTaskI(M->AF9_DTREST, xConteudo ,M->AF9_CALEND,M->AF9_HDURAC,M->AF9_PROJET,Nil)
				M->AF9_START := aAuxRet[1]
				M->AF9_HORAI := aAuxRet[2]
				M->AF9_FINISH:= aAuxRet[3]
				M->AF9_HORAF := aAuxRet[4]
			Endif

	EndCase

EndIf

M->AF9_HDURAC := PmsCalcHr( M->AF9_START ,M->AF9_HORAI ,M->AF9_FINISH ,M->AF9_HORAF ,M->AF9_CALEND)

Return xConteudo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA203GrvTrfºAutor  ³Clovis Magenta      º Data ³  16/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ grava dados ja simulados pela funcao PMSAvalTrf()- PMSXFUN º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA203GrvTrf(aTrfAF9, aAtuEDT)
Local nX := 0
Local aArea := GetArea()
Local aAreaAFC := AFC->(GetArea())
Local aAreaAF9 := AF9->(GetArea())

DEFAULT aTrfAF9 := {}

For nX:=1 to Len(aTrfAF9)
	If aTrfAF9[nX][1] == "AF9"
		dbSelectArea("AF9")
		dbGoTo(aTrfAF9[nX][12])
		RecLock("AF9",.F.)
			AF9_START := aTrfAF9[nX][3]
			AF9_HORAI := aTrfAF9[nX][4]
			AF9_FINISH:= aTrfAF9[nX][5]
			AF9_HORAF := aTrfAF9[nX][6]
		AF9->(MsUnlock())

		If aScan(aAtuEDT,AF9->AF9_EDTPAI) <= 0
			aAdd(aAtuEDT,AF9->AF9_EDTPAI)
		EndIf

	ElseIf aTrfAF9[nX][1] == "AFC"
		dbSelectArea("AFC")
		dbGoTo(aTrfAF9[nX][12])
		RecLock("AFC",.F.)
			AFC_START := aTrfAF9[nX][3]
			AFC_HORAI := aTrfAF9[nX][4]
			AFC_FINISH:= aTrfAF9[nX][5]
			AFC_HORAF := aTrfAF9[nX][6]
		MsUnlock()
	Endif
Next nX

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA203DtCedoºAutor  ³Clovis Magenta      º Data ³  16/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho do campo AF9_RESTRI que busca a Data mais cedo	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA203DtCedo()
Local dDataRest
Local lCalcPred := .F.

If !isAuto()
	lCalcPred := PMS203PRED(.F.) // recalcula a data inicio e fim baseado na sua predecessora, se tiver
EndIf

// Atribui o novo valor da data de restricao
If !lCalcPred .or. (M->AF9_START == PMS_MIN_DATE .and. M->AF9_HORAI == PMS_MIN_HOUR)

	If Empty(AF8->AF8_START)
		dDataRest := dDataBase
	Else
		dDataRest := AF8->AF8_START
	EndIf

// quando nao se tem predecessora, a funcao PMS203PRED()
// retorna valores padroes para START e HORAI
Elseif lCalcPred .and. !(M->AF9_START == PMS_MIN_DATE .and. M->AF9_HORAI == PMS_MIN_HOUR)
	dDataRest := M->AF9_START
EndIf

Return dDataRest


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA203HrCedoºAutor  ³Clovis Magenta      º Data ³  16/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho do campo AF9_RESTRI que busca a hora mais cedo	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA203HrCedo()

Local cHoraRest := ""
Local aAuxRet   := {}
Local cCalend   := Iif( Empty(M->AF9_CALEND), AF8->AF8_CALEND, M->AF9_CALEND)
Local nDiaSemana:= 1
Local nPosDay	 := 1

If (M->AF9_START == PMS_MIN_DATE .and. M->AF9_HORAI == PMS_MIN_HOUR)

	aAuxRet := PmsCalend(cCalend)

	nDiaSemana := DoW(AF8->AF8_START)
	nPosDay    := aScan(aAuxRet, {|x| x[1]==nDiaSemana } )
	cHoraRest  := Substr(aAuxRet[5][2], 3,6)

   // Altera data e hora inicio e fim da Tarefa
	aAuxRet := PMSDTaskF(M->AF9_DTREST,cHoraRest,cCalend,M->AF9_HDURAC,AF8->AF8_PROJET,Nil)
	M->AF9_START  := aAuxRet[1]
	M->AF9_HORAI  := aAuxRet[2]
	M->AF9_FINISH := aAuxRet[3]
	M->AF9_HORAF  := aAuxRet[4]

Else
	// HORAI calculada pela funcao PA203HRCEDO
	cHoraRest := M->AF9_HORAI
EndIf

Return cHoraRest

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA203Tarde ºAutor  ³Clovis Magenta      º Data ³  16/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao chamada na validação do campo AF9_RESTRI quando	  º±±
±±º          ³ igual a "O mais tarde possivel", ou seja, valor = 8		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA203Tarde(cProjeto, cRevisa, cTarefa, lMemoria)

Local aArea 	 := GetArea()
Local aAreaAF8	 := AF8->(GetArea())
Local aAreaAFC	 := AFC->(GetArea())
Local aAreaAF9	 := AF9->(GetArea())
Local aAreaAFD	 := AFD->(GetArea())
Local cRet   	:= 1
Local nPosBase := 0
Local lOk   	:=.T.
Local nX       := 0

Local cTmp1		:= CriaTrab(nil,.F.)
Local cTmp2		:= CriaTrab(nil,.F.)
Local cAliasPr	:= "ProcAlias"
Local cQuery   := ""
Local cAF9 		:=	RetSQLName("AF9")
Local cAFD 		:=	RetSQLName("AFD")
Local cAFC 		:=	RetSQLName("AFC")
Local cPrjTam 	:= Str(TamSX3("AF9_PROJET")[1])
Local cRevTam 	:= Str(TamSX3("AF9_REVISA")[1])
Local cTrfTam 	:= Str(TamSX3("AF9_TAREFA")[1])
Local cEDTTam 	:= Str(TamSX3("AF9_EDTPAI")[1])
Local cCalTam 	:= Str(TamSX3("AF9_CALEND")[1])
Local cProc		:="PMS203_"+CriaTrab(nil,.F.)
Local cSQL   	:= ""
Local lFirst   := .T.

DEFAULT lMemoria := .T.

aSimDados := {}

if Alltrim(Upper(TcGetDb()))=="INFORMIX"
	TCSqlExec('CREATE TABLE '+cTmp1+' ( TAREFA    char('+cTrfTam+') , EDTPAI   char('+cEDTTam+')    , DTINICIO char(8)	 , HORAI char(5)    , DTFIM  char(8)	 , HORAF char(5)    , HDURAC decimal(28,12)	, RESTRICAO char(1)	, DTREST  char(8)	 , HRREST char(5)    , CALEND char('+cCalTam+') 	, COUNT integer     , R_E_C_N_O_ integer , D_E_L_E_T_ char(1) 	, FLAG INT   )' )
elseif Alltrim(Upper(TcGetDb()))=="DB2"
	TCSqlExec('CREATE TABLE '+cTmp1+' ( TAREFA varchar('+cTrfTam+') , EDTPAI   varchar('+cEDTTam+') , DTINICIO varchar(8) , HORAI varchar(5) , DTFIM  varchar(8) , HORAF varchar(5) , HDURAC double			   , RESTRICAO char(1)  , DTREST  char(8)	 , HRREST char(5)    , CALEND varchar('+cCalTam+') , COUNT integer     , R_E_C_N_O_ integer , D_E_L_E_T_ char(1)	, FLAG INT	 )' )
else
	TCSqlExec('CREATE TABLE '+cTmp1+' ( TAREFA varchar('+cTrfTam+') , EDTPAI   varchar('+cEDTTam+') , DTINICIO varchar(8) , HORAI varchar(5) , DTFIM  varchar(8) , HORAF varchar(5) , HDURAC numeric(28,12)  , RESTRICAO char(1)  , DTREST  char(8)	 , HRREST char(5)    , CALEND varchar('+cCalTam+') , COUNT integer     , R_E_C_N_O_ integer , D_E_L_E_T_ char(1) , FLAG INT   )' )
endif

if Alltrim(Upper(TcGetDb()))=="INFORMIX"
	TCSqlExec('CREATE TABLE '+cTmp2+' ( TAREFA    char('+cTrfTam+') , FLAG INT   )' )
elseif Alltrim(Upper(TcGetDb()))=="DB2"
	TCSqlExec('CREATE TABLE '+cTmp2+' ( TAREFA varchar('+cTrfTam+') , FLAG INT	 )' )
else
	TCSqlExec('CREATE TABLE '+cTmp2+' ( TAREFA varchar('+cTrfTam+') , FLAG INT   )' )
endif

cSQL:=cSQL+ "create procedure "+cProc+" ( "+CRLF
cSQL:=cSQL+ " @OUT_RET	 	int output 			 " +CRLF
cSQL:=cSQL+ " ) as"+CRLF
cSQL:=cSQL+ "" +CRLF
cSQL:=cSQL+ " declare @I			int" 				+CRLF
cSQL:=cSQL+ " declare @iFlag		int" 				+CRLF
cSQL:=cSQL+ " declare @F_CURTRF  int         "	+CRLF  //				-- Fim cursor para DB2
cSQL:=cSQL+ " declare @TAREFA 	varchar(250) "  				+CRLF  //	-- Tarefa
cSQL:=cSQL+ " declare @COUNT 		int		 " 				+CRLF  //-- contador
cSQL:=cSQL+ " declare @R_E_C_N_O_	int			"	+CRLF  //-- Recno do registro
cSQL:=cSQL+ " declare @D_E_L_E_T_	char(1)		" 		+CRLF  //-- Sinal Deletado
cSQL:=cSQL+ ""+CRLF
cSQL:=cSQL+ ""+CRLF
cSQL:=cSQL+ " declare @fim_CUR	int "+CRLF  //-- Indica fim do cursor no DB2
cSQL:=cSQL+ ""+CRLF
cSQL:=cSQL+ " select @OUT_RET=0" +CRLF
cSQL:=cSQL+ " select @I=1" 		+CRLF
cSQL:=cSQL+ " select @COUNT=1000" 	+CRLF
cSQL:=cSQL+ ""+CRLF
cSQL:=cSQL+ "Insert into "+cTmp2+" (TAREFA, FLAG)"+CRLF
cSQL:=cSQL+ "	Select AFD_TAREFA, 1 FROM "+cAFD+CRLF
cSQL:=cSQL+ "		WHERE AFD_FILIAL='"+xFilial("AFD")+"' AND "+CRLF
cSQL:=cSQL+ "		AFD_PROJET= '"+cProjeto+"' AND "+CRLF
cSQL:=cSQL+ "		AFD_REVISA= '"+cRevisa+"' AND "+CRLF
cSQL:=cSQL+ "		AFD_PREDEC= '"+cTarefa+"' AND "+CRLF
cSQL:=cSQL+ "		D_E_L_E_T_<>'*' "+CRLF
cSQL:=cSQL+ ""+CRLF
cSQL:=cSQL+ "While @I=1"+CRLF
cSQL:=cSQL+ "	Begin"+CRLF
cSQL:=cSQL+ "		Insert into "+cTmp2+" (TAREFA, FLAG)"+CRLF
cSQL:=cSQL+ "		Select AFD_TAREFA, 2 FROM "+cAFD+","+cTmp2+CRLF
cSQL:=cSQL+ "			WHERE AFD_FILIAL='"+xFilial("AFD")+"' AND "+CRLF
cSQL:=cSQL+ "			AFD_PROJET= '"+cProjeto+"' AND "+CRLF
cSQL:=cSQL+ "			AFD_REVISA= '"+cRevisa+"' AND "+CRLF
cSQL:=cSQL+ "			AFD_PREDEC= TAREFA AND "+CRLF
cSQL:=cSQL+ "			FLAG=1 AND"+CRLF
cSQL:=cSQL+ "			D_E_L_E_T_<>'*' "+CRLF
cSQL:=cSQL+ ""+CRLF
cSQL:=cSQL+ "		UPDATE "+cTmp2+" SET FLAG=0 WHERE FLAG=1 	-- Desabilita o registro procurado" +CRLF
cSQL:=cSQL+ "		UPDATE "+cTmp2+" SET FLAG=1 WHERE FLAG=2	-- Habilita o novo registro para ser procurado" +CRLF
cSQL:=cSQL+ ""+CRLF
cSQL:=cSQL+ "		(Select @iFlag = Count(FLAG) from "+cTmp2+" Where FLAG=1)"+CRLF
cSQL:=cSQL+ "			If @iFlag < 1 "+CRLF
cSQL:=cSQL+ "				Select @I=0"+CRLF
cSQL:=cSQL+ "	End"+CRLF
cSQL:=cSQL+ ""+CRLF
cSQL:=cSQL+ "" +CRLF
cSQL:=cSQL+ " 		Insert into "+cTmp1+" (TAREFA,EDTPAI, DTINICIO, HORAI, DTFIM, HORAF, HDURAC, RESTRICAO, DTREST, HRREST, CALEND, COUNT, R_E_C_N_O_, D_E_L_E_T_)" +CRLF
cSQL:=cSQL+ " 		Select AF9_TAREFA, AF9_EDTPAI, AF9_START, AF9_HORAI, AF9_FINISH, AF9_HORAF, AF9_HDURAC,AF9_RESTRI,AF9_DTREST,AF9_HRREST,AF9_CALEND, @COUNT, R_E_C_N_O_, D_E_L_E_T_ " +CRLF
cSQL:=cSQL+ " 		FROM " +cAF9+CRLF
cSQL:=cSQL+ " 		WHERE AF9_FILIAL = '"+xFilial('AF9')+"' AND " +CRLF
cSQL:=cSQL+ " 		AF9_PROJET = '"+cProjeto+"' AND " +CRLF
cSQL:=cSQL+ " 		AF9_REVISA = '"+cRevisa+"' AND "  +CRLF
cSQL:=cSQL+ " 		AF9_TAREFA = '"+cTarefa+"' AND "  +CRLF
cSQL:=cSQL+ " 		D_E_L_E_T_<>'*' " +CRLF
cSQL:=cSQL+ ""+CRLF
cSQL:=cSQL+ "		Select @COUNT = @COUNT-1"+CRLF
cSQL:=cSQL+ ""+CRLF
cSQL:=cSQL+ "-- SEGUNDA FASE DA PROCEDURE (LOCALIZAR AS TAREFAS E TRAZER SEUS DADOS"+CRLF
cSQL:=cSQL+ ""+CRLF
cSQL:=cSQL+ "declare CURTRF cursor for "+CRLF
cSQL:=cSQL+ "Select TAREFA from 	"+cTmp2+CRLF
cSQL:=cSQL+ "open CURTRF " +CRLF
cSQL:=cSQL+ "select @F_CURTRF=0 --Fim do cursor para DB2" +CRLF
cSQL:=cSQL+ "fetch next from CURTRF into @TAREFA " +CRLF
cSQL:=cSQL+ "" +CRLF
cSQL:=cSQL+ "While @@fetch_status = 0 " +CRLF
cSQL:=cSQL+ "	Begin " +CRLF
cSQL:=cSQL+ "" +CRLF
cSQL:=cSQL+ " 		Insert into "+cTmp1+" (TAREFA,EDTPAI, DTINICIO, HORAI, DTFIM, HORAF, HDURAC, RESTRICAO, DTREST, HRREST, CALEND, COUNT, R_E_C_N_O_, D_E_L_E_T_)" +CRLF
cSQL:=cSQL+ " 		Select AF9_TAREFA, AF9_EDTPAI, AF9_START, AF9_HORAI, AF9_FINISH, AF9_HORAF, AF9_HDURAC,AF9_RESTRI,AF9_DTREST,AF9_HRREST,AF9_CALEND, @COUNT, R_E_C_N_O_, D_E_L_E_T_ " +CRLF
cSQL:=cSQL+ " 		FROM " +cAF9+CRLF
cSQL:=cSQL+ " 		WHERE AF9_FILIAL = '"+xFilial('AF9')+"' AND " +CRLF
cSQL:=cSQL+ " 		AF9_PROJET = '"+cProjeto+"' AND " +CRLF
cSQL:=cSQL+ " 		AF9_REVISA = '"+cRevisa+"' AND "  +CRLF
cSQL:=cSQL+ " 		AF9_TAREFA = @TAREFA AND "  +CRLF
cSQL:=cSQL+ " 		D_E_L_E_T_<>'*' " +CRLF
cSQL:=cSQL+ ""+CRLF
cSQL:=cSQL+ "		select @F_CURTRF=0"+CRLF
cSQL:=cSQL+ "		select @COUNT = @COUNT-1"+CRLF
cSQL:=cSQL+ "		fetch next from CURTRF into @TAREFA" +CRLF
cSQL:=cSQL+ ""+CRLF
cSQL:=cSQL+ "	End" +CRLF
cSQL:=cSQL+ "" +CRLF
cSQL:=cSQL+ "close CURTRF"+CRLF
cSQL:=cSQL+ "deallocate CURTRF"+CRLF
cSQL:=cSQL+ "" +CRLF
cSQL:=cSQL+ "Select @OUT_RET=1" +CRLF

cSQL:=MsParse(cSQL,Alltrim(TcGetDB()))

if cSQL=''
	If !__lBlind
		MsgAlert(STR0145+" "+cProc+": "+MsParseError())  //'Erro criando a Stored Procedure: '
		conout('Parser Error')
		conout(STR0145+" "+cProc+": "+MsParseError()) //'Erro criando a Stored Procedure: '
	EndIf
else

	cSQL:=PA200Fix(cSQL, Alltrim(TcGetDB()))

	cRet:=TcSqlExec(cSQL)
	if cRet <> 0
		if !__lBlind
 			MsgAlert(STR0145 +" "+cProc+": "+TCSqlError())  //'Erro criando a Stored Procedure:'
			conout('SQL Error')
			conout(STR0145 +" "+cProc+": "+MsParseError()) //'Erro criando a Stored Procedure:'
		endif
		lOk := .F.
	endif

EndIf

If lOk
	TCSPExec( cProc )
	cQuery := "Select * from "+cTmp1+" order by COUNT"
	If Select(cAliasPr)>0
		(cAliasPr)->(dbCloseArea())
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasPr, .T., .T. )
		(cAliasPr)->(dbGoTop())
	else
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasPr, .T., .T. )

		(cAliasPr)->(dbGoTop())
	EndIf

	//////// ORDEM DA TABELA TEMPORARIA ///////////////////////////////
	//     1-TAREFA/ 2-ETPAI/ 3-START/ 4-HORAI/ 5-FINISH/ 6-HORAF    //
	//	7-HDURAC/ 8-RESTRI/ 9-DTREST / 10-HRREST/ 11-RECNO/ 12-DELETE //
	///////////////////////////////////////////////////////////////////
	While (cAliasPr)->(!EOF()) .and. lOk

		If lFirst // primeira vez e registro

			If (cAliasPr)->DTFIM < DtoS(AF8->AF8_FINISH)
				aAuxRet := PMSDTaskI(AF8->AF8_FINISH /*StoD((cAliasPr)->DTFIM)*/,(cAliasPr)->HORAF,(cAliasPr)->CALEND,(cAliasPr)->HDURAC,cProjeto,"")
				aAuxRet := PMSCalRest((cAliasPr)->RESTRICAO, StoD((cAliasPr)->DTREST), (cAliasPr)->HRREST ,aAuxRet,(cAliasPr)->CALEND,(cAliasPr)->HDURAC,AF9->AF9_PROJET, .T.)
				aAdd(aSimDados,{"AF9",(cAliasPr)->TAREFA,aAuxRet[1],aAuxRet[2],aAuxRet[3],aAuxRet[4],(cAliasPr)->HDURAC,(cAliasPr)->HDURAC,"NIVEL","DTATUI","F9_DTATUF", (cAliasPr)->R_E_C_N_O_})
			else
				aAdd(aSimDados,{"AF9",(cAliasPr)->TAREFA,StoD((cAliasPr)->DTINICIO),(cAliasPr)->HORAI,StoD((cAliasPr)->DTFIM),(cAliasPr)->HORAF,(cAliasPr)->HDURAC,(cAliasPr)->HDURAC,"NIVEL","DTATUI","F9_DTATUF", (cAliasPr)->R_E_C_N_O_})
			EndIf

			nPosBase := aScan(aSimDados,{|x|x[1]+x[2] == "AF9" + (cAliasPr)->TAREFA })
			If (nPosBase>0) .and. !(lOk := PA203VldRes(aSimDados, nPosBase))
				Exit
			EndIf

		Elseif (cAliasPr)->COUNT == 1000 // ultimo
			If lMemoria
				P203SimPrd(M->AF9_PROJET,M->AF9_REVISA,(cAliasPr)->TAREFA,.F.,,,@aSimDados,.T.)
			Else
				P203SimPrd(AF9->AF9_PROJET,AF9->AF9_REVISA,(cAliasPr)->TAREFA,.F.,,,@aSimDados,.F.)
			Endif

			nPosBase := aScan(aSimDados,{|x|x[1]+x[2] == "AF9" + (cAliasPr)->TAREFA })

			If (nPosBase>0) .and. !(lOk := PA203VldRes(aSimDados, nPosBase))
				Exit
			EndIf

		Else
			If lMemoria
				P203SimPrd(M->AF9_PROJET,M->AF9_REVISA,(cAliasPr)->TAREFA,.F.,,,@aSimDados,.F.)
			Else
				P203SimPrd(AF9->AF9_PROJET,AF9->AF9_REVISA,(cAliasPr)->TAREFA,.F.,,,@aSimDados,.F.)
			Endif

			nPosBase := aScan(aSimDados,{|x|x[1]+x[2] == "AF9" + (cAliasPr)->TAREFA })

			If (nPosBase>0) .and. !(lOk := PA203VldRes(aSimDados, nPosBase))
				Exit
			EndIf

		Endif
		lFirst := .F.
		(cAliasPr)->(DbSkip())

	EndDo

	(cAliasPr)->(dbCloseArea())
	MsErase(cTmp1,,"TOPCONN")
	MsErase(cTmp2,,"TOPCONN")

	if TcSqlExec('DROP PROCEDURE '+cProc)<>0
		if !__lBlind
			MsgAlert(STR0146 +" "+cProc+": "+TCSqlError())   //'Erro excluindo procedure' // "Procedure não criada: "
		endif
	endif
Endif

If !(lOk)
	aSimDados := {}
EndIf

// ATUALIZA AS DATAS DA TAREFA ATUAL
If lMemoria
	nPosBase := aScan(aSimDados,{|x|x[1]+x[2] == "AF9" + M->AF9_TAREFA })
	If nPosBase > 0
		M->AF9_DTREST	:= aSimDados[nPosBase][3]
		M->AF9_HRREST 	:= aSimDados[nPosBase][4]
		M->AF9_START	:= aSimDados[nPosBase][3]
		M->AF9_HORAI 	:= aSimDados[nPosBase][4]

		aAuxRet := PMSDTaskF(M->AF9_START,M->AF9_HORAI,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)

		M->AF9_FINISH	:= aAuxRet[3]
		M->AF9_HORAF 	:= aAuxRet[4]
	Else
		M->AF9_DTREST	:= iif(Empty(AF8->AF8_FINISH), M->AF9_FINISH, AF8->AF8_FINISH)
		M->AF9_FINISH	:= iif(Empty(AF8->AF8_FINISH), M->AF9_FINISH, AF8->AF8_FINISH)

		aAuxRet := PMSDTaskI(M->AF9_FINISH,M->AF9_HORAF,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
		M->AF9_START	:= aAuxRet[1]
		M->AF9_HORAI 	:= aAuxRet[2]
		M->AF9_FINISH  := aAuxRet[3]
		M->AF9_HORAF 	:= aAuxRet[4]

		M->AF9_HRREST 	:= M->AF9_HORAI

	Endif
Else
	nPosBase := aScan(aSimDados,{|x|x[1]+x[2] == "AF9" + AF9->AF9_TAREFA })
	Reclock("AF9",.F.)
	If nPosBase > 0
		AF9->AF9_DTREST	:= aSimDados[nPosBase][3]
		AF9->AF9_HRREST	:= aSimDados[nPosBase][4]
		AF9->AF9_START	:= aSimDados[nPosBase][3]
		AF9->AF9_HORAI 	:= aSimDados[nPosBase][4]

		aAuxRet := PMSDTaskF(AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)

		AF9->AF9_FINISH	:= aAuxRet[3]
		AF9->AF9_HORAF 	:= aAuxRet[4]
	Else
		AF9->AF9_DTREST	:= iif(Empty(AF8->AF8_FINISH), AF9->AF9_FINISH, AF8->AF8_FINISH)
		AF9->AF9_FINISH	:= iif(Empty(AF8->AF8_FINISH), AF9->AF9_FINISH, AF8->AF8_FINISH)

		aAuxRet := PMSDTaskI(AF9->AF9_FINISH,AF9->AF9_HORAF,AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
		AF9->AF9_START	:= aAuxRet[1]
		AF9->AF9_HORAI 	:= aAuxRet[2]
		AF9->AF9_FINISH := aAuxRet[3]
		AF9->AF9_HORAF 	:= aAuxRet[4]

		AF9->AF9_HRREST := AF9->AF9_HORAI
	Endif
	MsUnlock()
Endif

RestArea(aAreaAFD)
RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aAreaAF8)
RestArea(aArea)

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³P203GetPredºAutor  ³Clovis Magenta      º Data ³  16/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ funcao de recursividade para pegar todo o rastro de 		  º±±
±±º          ³ relacionamentos de predecessoras de uma determinada tarefa º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function P203GetPred(cProjeto, cRevisa, cTarefa, aPreds)

DEFAULT cProjeto	:= ""
DEFAULT cRevisa	:= ""
DEFAULT cTarefa   := ""
DEFAULT aPreds 	:= {}

dbSelectArea("AFD")
dbSetOrder(2) //AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_PREDEC+AFD_ITEM
DbSeek(xFilial("AFD")+cProjeto+cRevisa+cTarefa)
While AFD->(!EOF()) .AND. (xFilial("AFD")+cProjeto+cRevisa+cTarefa == AFD->(AFD_FILIAL+AFD_PROJETO+AFD_REVISA+AFD_PREDEC))

	aAdd(aPreds, {AFD->AFD_TAREFA} )

	If aScan(aPreds,{|x| x[1]==AFD->AFD_TAREFA})==0
		P203GetPred(cProjeto, cRevisa, AFD->AFD_TAREFA, @aPreds)
	Endif

	AFD->(DbSkip())
EndDo

Return aPreds

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203InsTudOk³ Autor ³ Totvs               ³ Data ³ 18-09-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do browse ao confirmar a tarefa                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203InsTudOk()
	Local nSavN		:= n
	Local lRet		:= .T.
	Local nx 		:= 0
	Local nPosIns	:= aScan(aHeader,{|x| Alltrim(x[2]) == Alltrim("AEL_INSUMO")})

If nPosIns > 0
	For nx := 1 To Len( aCols )
		n := nx
		If !(aCols[n][Len(aHeader)+1]) .And. !empty(aCols[n][nPosIns])
			If !A203InsLinOk()
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next

	n := nSavN
Endif
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203SubTudOk³ Autor ³ Totvs               ³ Data ³ 18-09-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do browse ao confirmar a tarefa                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203SubTudOk()
	Local nSavN		:= n
	Local lRet		:= .T.
	Local nx 		:= 0
	Local nPosSub	:= aScan(aHeader,{|x| Alltrim(x[2]) == Alltrim("AEN_SUBCOM")})

If nPosSub >0
	For nx := 1 To Len( aCols )
		n := nx
		If !(aCols[n][Len(aHeader)+1]) .And. !empty(aCols[n][nPosSub])
			If !A203SubLinOk()
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next

	n := nSavN
EndiF
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203InsLinOk³ Autor ³ Totvs               ³ Data ³ 20-07-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 5.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203InsLinOk()
Local aArea       := GetArea()
Local aAreaSX3    := SX3->(GetArea())
Local aAreaSX2    := SX2->(GetArea())
Local lRet        := .T.
Local nPosQt      := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("AEL_QUANT")})
Local nPos_PLNPor := aScan(aHeader,{|x| Alltrim(x[2]) == Alltrim("AEL_PLNPOR")})
Local nPosIns	  := aScan(aHeader,{|x| Alltrim(x[2]) == Alltrim("AEL_INSUMO")})
Local nPosCampo   := 0
Local nInc		  := 0

If !(aCols[n][Len(aHeader)+1])
	If empty(aCols[n][nPosIns])
		nPosCampo:= nPosIns

		SX3->(dbSetOrder(2))
		SX3->(MsSeek(aHeader[nPosCampo][2]))
		SX2->(dbSetOrder(1))
		SX2->(MsSeek(SX3->X3_ARQUIVO))

		Help("  ",1,"OBRIGAT2",,X2NOME()+CRLF+STR0048+X3DESCRIC()+CRLF+STR0049+Str(n,3,0),3,1) //"Campo: "###"Linha: "
		lRet:= .F.
	EndIf

	//
	// se existir o campo "planeja por" verifica se o produto vai utilizar pelo 'cronograma de periodo',
	// nesse caso a tarefa deve ter o campo de metodo de meddicao igual.
	//
	If lRet .And. nPos_PLNPor > 0

		// Naum permite selecionar por "cronograma por periodo" se a tarefa naum for do mesmo tipo
		If aCols[n][nPos_PLNPor] == "2" .AND. M->AF9_TPMEDI # "6"
			Help("  ",1,"PMSA203",,STR0120 + str(n,3,0) + STR0121 +CRLF+ ; // "Na linha " ## " não pode ser definido o planejamento por "
			STR0122 +CRLF+ ; // "'Cronograma por periodo', pois é necessario que a tarefa "
			STR0123 ,1,1) // "utilize o método de medição 'Cronograma por periodo'."
			lRet:=.F.
		EndIf
	EndIf

	// Verifica o insumo ja foi informado em outras linhas e bloqueia
	If lRet .AND. nPosIns > 0 .AND. !aCols[n][Len(aCols[n])]
		For nInc := 1 To Len( aCols )
			If n <> nInc
				If aCols[n][nPosIns] == aCols[nInc][nPosIns] .AND. !aCols[nInc][Len(aCols[n])]
					Help("  ",1,"DUPLIC",,"Não é permitido duplicidade de insumos!",3,1) //"Campo: "###"Linha: "
					lRet := .F.
				EndIf
			EndIf
		Next
	EndIf
EndIf

If lRet .And. !empty(aCols[n][nPosIns])
	lRet := MaCheckCols(aHeader,aCols,n)
EndIf

A203GDCalcCust(oFolder:nOption)

RestArea(aAreaSX2)
RestArea(aAreaSX3)
RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203SubLinOk³ Autor ³ Totvs               ³ Data ³ 20-07-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 5.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203SubLinOk()
Local aArea			:= GetArea()
Local aAreaSX3		:= SX3->(GetArea())
Local aAreaSX2		:= SX2->(GetArea())
Local lRet			:= .T.
Local nPosQt		:= aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("AEN_QUANT")})
Local nPosSub		:= aScan(aHeader,{|x| Alltrim(x[2]) == Alltrim("AEN_SUBCOM")})
Local nPosCampo		:= 0
Local nInc			:= 0

If !(aCols[n][Len(aHeader)+1])
	If empty(aCols[n][nPosSub])
		nPosCampo:= nPosSub

		SX3->(dbSetOrder(2))
		SX3->(MsSeek(aHeader[nPosCampo][2]))
		SX2->(dbSetOrder(1))
		SX2->(MsSeek(SX3->X3_ARQUIVO))

		Help("  ",1,"OBRIGAT2",,X2NOME()+CRLF+STR0048+X3DESCRIC()+CRLF+STR0049+Str(n,3,0),3,1) //"Campo: "###"Linha: "
		lRet:= .F.
	EndIf

	// Verifica o insumo ja foi informado em outras linhas e bloqueia
	If lRet .AND. nPosSub > 0 .AND. !aCols[n][Len(aCols[n])]
		For nInc := 1 To Len( aCols )
			If n <> nInc
				If aCols[n][nPosSub] == aCols[nInc][nPosSub] .AND. !aCols[nInc][Len(aCols[n])]
					Help("  ",1,"DUPLIC",,"Não é permitido duplicidade de sub-composições!",3,1) //"Campo: "###"Linha: "
					lRet := .F.
				EndIf
			EndIf
		Next
	EndIf
EndIf

A203GDCalcCust(oFolder:nOption)

RestArea(aAreaSX2)
RestArea(aAreaSX3)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A203PrdCron ºAutor ³Pedro Pereira Lima º Data ³ 13/11/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Cronograma de consumo de produto                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Cronograma Previsto de Consumo                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203PrdCron(nOpcX ,aHeadAFA ,aColsAFA ,aHeadAEF ,aColsAEF,cProdRec)
Local dIni        := stod("")
Local dX          := stod("")
Local aRecAEF     := {}
Local nTotPerc    := 0
Local nY          := 0
Local nI          := 0
Local nOpc        := 0
Local nPosAFAProd := 0
Local lContinua   := .T.
Local oDlg
Local aArea    	  := GetArea()
Local aAreaSX3    := SX3->(GetArea())
Local aAreaAF8    := AF8->(GetArea())
Local aButAEF	  := {}
Local aColsOri    := {}
Local nPosAEF 	  := 0
Local aColsEdAEF  := NIL
 
PRIVATE oGDPrdCron

AAdd(aButAEF,{'PROCESSA',{|| PmsAFZ2AEF(oGDPrdCron,cProdRec) },STR0149,STR0150}) //"Sugerir cronograma"###"Cronograma"

If M->AF9_TPMEDI == "6"
	If cProdRec == 'P'
		aColsSV[1]	:=	aClone(aCols)
	Else
		aColsSV[5]	:=	aClone(aCols)
	Endif
	nPosAFAProd := aScan(aHeadAFA,{|x| AllTrim(x[2])==IIf(cProdRec=='P',"AFA_PRODUT","AFA_RECURS")})
	nPosAFAIt   := aScan(aHeadAFA,{|x| AllTrim(x[2])=="AFA_ITEM"})
	If Len(aColsAFA) == 1 .and. Empty(aColsAFA[1 ,nPosAFAProd])
		lContinua := .F.
	EndIf

	If lContinua
		//
		// Cronograma Previsto de consumo de produtos
		//
		nPosAEFIt   := aScan(aHeadAEF,{|x| AllTrim(x[2])=="AEF_ITEM"})
		nPosAEFProd := aScan(aHeadAEF,{|x| AllTrim(x[2])==IIf(cProdRec=='P',"AEF_PRODUT","AEF_RECURS")})

		If Len(aColsAEF) == 1 .AND. Empty(aColsAEF[Len(aColsAEF) ,nPosAEFProd])
			aColsAEF := {}
			aColsOri := {}
		EndIf

		aColsOri := aClone(aColsAEF)
		aColsAEF := {}
		
		For nI := 1 to Len(aColsAFA)

			If !Empty(aColsAFA[nI ,nPosAFAProd])
				If  ( nPosAEF := aScan( aColsOri , {|x| ( x[1] <> Nil  .AND.  x[2]  <> Nil )   .And.  ( x[1]+ x[2] == aColsAFA[nI ,nPosAFAIt] + aColsAFA[nI , nPosAFAProd] ) } ) ) == 0
					aadd(aColsAEF ,Array(Len(aHeadAEF)+1))

					aColsAEF[Len(aColsAEF) ,nPosAEFIt]  := aColsAFA[nI ,nPosAFAIt]
					aColsAEF[Len(aColsAEF) ,nPosAEFProd]:= aColsAFA[nI ,nPosAFAProd]

					dbSelectArea("AEF")
					dbSetOrder(1)
					For nY := nPosAEFProd+1 to Len(aHeadAEF)
						If cProdRec == 'P'
							cChave	:=	xFilial("AEF")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)+aColsAFA[nI ,nPosAEFIt]+cValtochar(aColsAFA[nI ,nPosAEFProd] ) +space(TamSX3("AEF_RECURS")[1])+dTos(ctod(aHeadAEF[nY ,1]))
						Else
							cChave	:=	xFilial("AEF")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)+aColsAFA[nI ,nPosAEFIt]+space(TamSX3("AEF_PRODUT")[1])+cValtochar(aColsAFA[nI ,nPosAEFProd] )+dTos(ctod(aHeadAEF[nY ,1]))
						Endif
						If dbSeek(cChave)
							aColsAEF[Len(aColsAEF) ,nY] := AEF->AEF_QUANT
						Else
							aColsAEF[Len(aColsAEF) ,nY] := 0
						EndIf
					Next nY
					aColsAEF[Len(aColsAEF) ,Len(aHeadAEF)+1] := .F.
				Else
					aAdd(aColsAEF ,aColsOri[nPosAEF])
				EndIf
				aColsAEF[Len(aColsAEF) ,Len(aHeadAEF)+1] := aColsAFA[nI ,Len(aHeadAFA)+1]
			EndIf
		Next nI

		If ExistBlock("PMA203AEF")
			aColsEdAEF := ExecBlock("PMA203AEF", .T., .T.)
		EndIf

		DEFINE MSDIALOG oDlg TITLE STR0151 OF oMainWnd PIXEL FROM 1,1 TO 480,780 //"Cronograma Previsto de Consumo da tarefa"
		oDlg:lMaximized := .F.
		oGDPrdCron	:= MsNewGetDados():New(2,2,50,75,nOpcX,"A203GDPrdLOk('"+cProdRec+"')","A203GDCrnTdOk('"+cProdRec+"')",,aColsEdAEF/*alteraveis*/,/*freeze*/,9999,,,,oDlg,aHeadAEF,aColsAEF)
		oGDPrdCron:oBrowse:Align     := CONTROL_ALIGN_ALLCLIENT
		oGDPrdCron:oBrowse:Refresh()

		ACTIVATE MSDIALOG oDlg ON INIT (oGDPrdCron:Refresh() ,EnchoiceBar(oDlg,{||iIf( A203GDCrnTdOk(cProdRec),(nOpc := 1 ,oDlg:End()),NIL)},{||nOpc := 0 ,oDlg:End()},,aButAEF))

		If nOpc == 1
			aColsAEF := oGDPrdCron:aCols

			If cProdRec == 'P'
				A203GDCalcCust(1)
			Else
				A203GDCalcCust(5)
			Endif

		EndIf
	Else
		Alert(STR0152 + " " + IIf(cProdRec=='P',STR0039,STR0008) + " " + STR0153)//"Nao foram informados"### "Produtos"### "Recursos"###"a serem consumidos."
	EndIf
	If cProdRec == 'P'
		aCols := aClone(aColsSV[1]	)
	Else
		aCols := aClone(aColsSV[5]	)
	Endif
Else
	Alert(STR0154) //"Cronograma Previsto de Consumo funciona somente se o método de medição da tarefa for 'Cronograma por periodo'."
EndIf

RestArea(aAreaAF8)
RestArea(aAreaSX3)
RestArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A203PrdLOk    ³ Autor ³ Pedro Pereira Lima³ Data ³ 13/11/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao Field Ok na GetDados oGDPrdCron                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203 - Cronograma Previsto de Consumo                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GDPrdLOk(cProdRec)
Local lRet     		:= .T.
Local nTotPerc 		:= 0
Local nTotPrev      := 0
Local nX       		:= 0
Local nCols			:=	IIf(cProdRec=='P',1,5)
Local nPosAEFPerc 	:= aScan(aHeader ,{|x| AllTrim(x[2])=="AEF_QTD001"})
Local nPosAEFIT 	:= aScan(oGDPrdCron:aHeader ,{|x| AllTrim(x[2])=="AEF_ITEM"})
Local nPosAEFProd	:= aScan(oGDPrdCron:aHeader ,{|x| AllTrim(x[2])==IIf(cProdRec=='P',"AEF_PRODUT","AEF_RECURS")})
Local nPosAFAProd 	:= aScan(aHeaderSV[nCols],{|x| AllTrim(x[2])==IIf(cProdRec=='P',"AFA_PRODUT","AFA_RECURS")})
Local nPosAFAIt   	:= aScan(aHeaderSV[nCols],{|x| AllTrim(x[2])=="AFA_ITEM"})
Local nPosAFAQt   	:= aScan(aHeaderSV[nCols],{|x| AllTrim(x[2])=="AFA_QUANT" })
Local nItProd		:= aScan(aColsSV[nCols],{|x| x[nPosAFAIt]+x[nPosAFAProd]== oGDPrdCron:aCols[oGDPrdCron:nAt][nPosAEFIT]+oGDPrdCron:aCols[oGDPrdCron:nAt][nPosAEFProd]})
Local nTotProd		:=	aColsSV[nCols][nItProd][nPosAFAQt]
Local cPmsCust		:= SuperGetMv("MV_PMSCUST",.F.,"1") //Indica se utiliza o custo pela quantidade unitaria ou total

If cPmsCust == "2"
	nTotProd := nTotProd * M->AF9_QUANT
Endif

If nPosAEFPerc != 0
	For nX := nPosAEFPerc to Len(oGDPrdCron:aHeader)
	   nTotPerc += oGDPrdCron:aCols[oGDPrdCron:nAt ,nX]
	Next nX
EndIf

nTotPrev := (nTotPerc*nTotProd)/100

If nTotPerc != 0 .And. nTotPrev <> nTotProd
	Aviso(STR0155,STR0156 + Alltrim(Str(nTotPrev))+ " " +  STR0157 + " " +Alltrim(Str(nTotProd))+ " " + STR0158 + CRLF + STR0159,{STR0042})//"Diferenca de quantidades"###"A soma da programacao difere do total informado na tarefa ("###"e"###"respectivamente)."###"Modifique a quantidade na pasta de consumos."###"Ok"
	lRet := .F.
EndIf

/*
Ponto de entrada para que o cliente customize Cronograma Previsto de Consumo
*/
If ExistBlock("P203LOk")
	lRet = ExecBlock("P203LOk",.F.,.F.,{oGDPrdCron:aHeader,oGDPrdCron:aCols})
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AFACust       ³ Autor ³ Pedro Pereira Lima³ Data ³ 13/11/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203 - Cronograma Previsto de Consumo                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFACust(cProjeto ,cRevisa ,cTarefa ,cItem ,cProduto ,dData)
Local nCusto     := 0
Local nTotal     := 0
Local dRef     := stod("")
Local aAreaAEF := AEF->(GetArea())

	dbSelectArea("AEF")
	dbSetOrder(1)
	dbSeek(xFilial()+cProjeto+cRevisa+cTarefa+cItem+cProduto)
	While AEF->(!Eof()) .and. AEF->(AEF_FILIAL+AEF_PROJET+AEF_REVISA+AEF_TAREFA+AEF_ITEM+AEF_PRODUT)==xFilial()+cProjeto+cRevisa+cTarefa+cItem+cProduto
		If dData > AEF->AEF_DATREF
			dRef :=AEF->AEF_DATREF
		Else
			dRef := dData
		EndiF

		nCusto := AEFCust(AEF->AEF_PROJET ,AEF->AEF_REVISA ,AEF->AEF_PRODUT ,dRef) * AEF->AEF_QUANT
		nTotal += nCusto
		dbSkip()
	EndDo

RestArea(aAreaAEF)

Return( nCusto )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AEFCust   ºAutor  ³Pedro Pereira Lima  º Data ³  13/11/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Cronograma Previsto de Consumo                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AEFCust(cProjeto ,cRevisa ,cProduto ,dRef)
Local nCusto   := 0
Local aArea    := GetArea()
Local aAreaAEF := AEF->(GetArea())
Local cRecurso := space(TamSX3("AEF_RECURS")[1])

	dbSelectArea("AEF")
	dbSetOrder(1)
	dbSeek(xFilial()+cProjeto+cRevisa+cProduto+cRecurso+dtos(dRef),.T.)
	While AEF->(!Eof()) .AND. AEF->(AEF_PROJET+AEF_REVISA+AEF_PRODUT+AEF_RECURS) == xFilial()+cProjeto+cRevisa+cProduto+cRecurso

		nCusto := AEF->AEF_CUSTD

		If dRef > AEF->AEF_DATREF
			Exit
		EndiF

		AEF->(dbSkip())

	EndDo

RestArea(aAreaAEF)
RestArea(aArea)
Return nCusto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFAPrdCust  ºAutor ³Pedro Pereira Lima º Data ³ 13/11/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Busca o custo do produto                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Cronograma Previsto de Consumo                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFAPrdCust(cProjeto ,cRevisa ,cProduto ,dData)
Local nCust    := 0
Local aArea    := GetArea()
Local aAreaAEC := AEC->(GetArea())

	dbSelectArea("AEC")
	dbSetOrder(1)
	If dbSeek(xFilial()+cProjeto+cRevisa+cProduto+left(dtos(dData),6))
		nCust := AEC->AEC_CUSTD
	EndIf

RestArea(aAreaAEC)
RestArea(aArea)

Return nCust

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DatIniPer ºAutor  ³Pedro Pereira Lima  º Data ³ 13/11/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Cronograma Previsto de Consumo                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DatIniPer( dData ,cTipoPer )
	Do Case
		Case cTipoPer == "2"
			dData += 7
		Case cTipoPer == "3"
			If DAY(dData) == 01
				dData := CTOD("15/"+StrZero(MONTH(dData),2,0)+"/"+StrZero(YEAR(dData),4,0))
			Else
				dData += 35
				dData := CTOD("01/"+StrZero(MONTH(dData),2,0)+"/"+StrZero(YEAR(dData),4,0))
			EndIf
		Case cTipoPer == "4"
			dData += 35
			dData := CTOD("01/"+StrZero(MONTH(dData),2,0)+"/"+StrZero(YEAR(dData),4,0))
		OtherWise
			dData += 1
	EndCase
Return dData

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsAFZ2AEF  ºAutor ³Pedro Pereira Lima º Data ³ 13/11/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Distribui item(ns) no cronograma por consumo conforme      º±±
±±ºcronograma³por periodo                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Cronograma Previsto de Consumo                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAFZ2AEF(oGetd,cProdRec)
Local nPos	:=	oGetD:nAT
Local aParam:={1}
Local nCols			:=	IIf(cProdRec=='P',1,5)
Local nPosAEFPerc := aScan(oGetd:aHeader ,{|x| AllTrim(x[2])=="AEF_QTD001"})
Local nX,nY
Local nPosAEFIt   := aScan(oGetd:aHeader ,{|x| AllTrim(x[2])=="AEF_ITEM"})
Local nPosAEFProd := aScan(oGetd:aHeader ,{|x| AllTrim(x[2])==IIf(cProdRec=='P',"AEF_PRODUT","AEF_RECURS")})

Local nPosAFAProd := aScan(aHeaderSV[nCols],{|x| AllTrim(x[2])==IIf(cProdRec=='P',"AFA_PRODUT","AFA_RECURS")})
Local nPosAFAIt   := aScan(aHeaderSV[nCols],{|x| AllTrim(x[2])=="AFA_ITEM"})
Local nPosAFAQt   := aScan(aHeaderSV[nCols],{|x| AllTrim(x[2])=="AFA_QUANT" })
Local nItProd		:= aScan(aColsSV[nCols],{|x| x[nPosAFAIt]+x[nPosAFAProd]== oGetD:aCols[oGetD:nAt][nPosAEFIT]+oGetD:aCols[oGetD:nAt][nPosAEFProd]})
Local nQtdTot		:=	0
Local nTotPrg		:=	0
Local nDecs 		:=	Tamsx3('AEF_QUANT')[2]
Local nPercFis := 0

If ParamBox( {{ 3 ,STR0160 + " ",1		,{STR0161,STR0162} ,120 ,""  ,.F.,".T." }} ,; //"Utilizar sugestao em:"###"Item atual"###"Todos os itens"
						STR0163,@aParam ) //"Parametros da Sugestao"

	If !Empty(AF8->AF8_ULMES)
		For nX := 1 To Len(aHeaderSV[06])
			If CTOD(aHeaderSV[06 ,nX ,01]) >=AF8->AF8_ULMES
				nPercFis += aColsSV[06 ,01 ,nX]
			EndIf
		Next nX
		If nPercFis <= 0
			nPercFis := 100
		EndIf

		If aParam[1] == 1
			nPosAFAQt   := aScan(aHeaderSV[nCols],{|x| AllTrim(x[2])=="AFA_QTDPRE" })
			nQtdTot		:=	aColsSV[nCols][nItProd][nPosAFAQt]
			nLastPerc	:=	0
			For nX := nPosAEFPerc To Len(oGetd:aHeader)
				If CTOD(oGetd:aHeader[nX ,01]) >=AF8->AF8_ULMES
					oGetd:aCols[oGetd:nAt][nX]	:=	Round((nQtdTot/nPercFis)*aColsSV[6,1,nX-nPosAEFPerc+1] , nDecs)
					nTotPrg	+=	oGetd:aCols[oGetd:nAt][nX]
					nLastPerc	:=	If(aColsSV[6,1,nX-nPosAEFPerc+1] >0,nX,nLastPerc)
				EndIf
			Next nX
			If nTotPrg <> nQtdTot .And. nLastPerc > 0
				oGetd:aCols[oGetd:nAt][nLastPerc]	+=	 nQtdTot - 	nTotPrg
			Endif

		Else
			For nY := 1 To Len(oGetd:aCols)
				nItProd		:= aScan(aColsSV[nCols],{|x| x[nPosAFAIt]+x[nPosAFAProd]== oGetD:aCols[nY][nPosAEFIT]+oGetD:aCols[nY][nPosAEFProd]})
				nPosAFAQt   := aScan(aHeaderSV[nCols],{|x| AllTrim(x[2])=="AFA_QTDPRE" })
				nQtdTot		:=	aColsSV[nCols][nItProd][nPosAFAQt]
				nLastPerc	:=	0
				nTotPrg	:=	0
				For nX := nPosAEFPerc To Len(oGetd:aHeader)
					If CTOD(oGetd:aHeader[nX ,01]) >=AF8->AF8_ULMES
						oGetd:aCols[nY][nX]	:=	Round((nQtdTot/nPercFis)*aColsSV[6,1,nX-nPosAEFPerc+1] , nDecs)
						nTotPrg		+=	oGetd:aCols[nY][nX]
						nLastPerc	:=	If(aColsSV[6,1,nX-nPosAEFPerc+1] >0,nX,nLastPerc)
					EndIF
				Next
				If nTotPrg <> nQtdTot .And. nLastPerc > 0
					oGetd:aCols[nY][nLastPerc]	+=	nQtdTot - 	nTotPrg
				Endif
			Next nY
		Endif

	Else

		If aParam[1] == 1
			nQtdTot		:=	aColsSV[nCols][nItProd][nPosAFAQt]
			nLastPerc	:=	0
			If nPosAEFPerc != 0
				For nX := nPosAEFPerc To Len(oGetd:aHeader)
					oGetd:aCols[oGetd:nAt][nX]	:=	Round(nQtdTot * aColsSV[6,1,nX-nPosAEFPerc+1]/100 , nDecs)
					nTotPrg	+=	oGetd:aCols[oGetd:nAt][nX]
					nLastPerc	:=	If(aColsSV[6,1,nX-nPosAEFPerc+1] >0,nX,nLastPerc)
				Next
			Endif
			If nTotPrg <> nQtdTot .And. nLastPerc > 0
				oGetd:aCols[oGetd:nAt][nLastPerc]	+=	 nQtdTot - 	nTotPrg
			Endif

		Else
			For nY := 1 To Len(oGetd:aCols)
				nItProd		:= aScan(aColsSV[nCols],{|x| x[nPosAFAIt]+x[nPosAFAProd]== oGetD:aCols[nY][nPosAEFIT]+oGetD:aCols[nY][nPosAEFProd]})
				nQtdTot		:=	aColsSV[nCols][nItProd][nPosAFAQt]
				nLastPerc	:=	0
				nTotPrg	:=	0
				If nPosAEFPerc != 0
					For nX := nPosAEFPerc To Len(oGetd:aHeader)
						oGetd:aCols[nY][nX]	:=	Round(nQtdTot * aColsSV[6,1,nX-nPosAEFPerc+1]/100 , nDecs)
						nTotPrg		+=	oGetd:aCols[nY][nX]
						nLastPerc	:=	If(aColsSV[6,1,nX-nPosAEFPerc+1] >0,nX,nLastPerc)
					Next
					If nTotPrg <> nQtdTot .And. nLastPerc > 0
						oGetd:aCols[nY][nLastPerc]	+=	nQtdTot - 	nTotPrg
					Endif
				EndIf
			Next nY
		Endif
	EndIf
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A203GDCrnTd ºAutor ³Pedro Pereira Lima º Data ³ 13/11/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Valida TODAS as celulas preenchidas do cronograma de consumoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Cronograma Previsto de Consumo                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GDCrnTdOk( cPrdRec )
Local nX := 0
Local lRet := .T.
Local nPos := 0

	nPos := oGDPrdCron:nAt

	For nx := 1 to Len(oGDPrdCron:aCols)
		oGDPrdCron:nAt := nX
		If !A203GDPrdLOk(cPrdRec)
			lRet := .F.
			Exit
		EndIf
	Next nX

/*
Ponto de entrada para que o cliente customize Cronograma Previsto de Consumo
*/
If ExistBlock("P203TdOk")
	lRet = ExecBlock("P203TdOk",.F.,.F.,{oGDPrdCron:aHeader,oGDPrdCron:aCols})
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A203VldCrnO ºAutor ³Pedro Pereira Lima º Data ³13/11/2009   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida as celulas preenchidas do cronograma de consumo     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Cronograma Previsto de Consumo                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203VldCrnOk(cProdRec ,aHeader ,aCols ,aHeaderAFA ,aColsAFA)
Local lRet     := .T.
Local nTotPerc := 0
Local nTotPrev := 0
Local nX       := 0
Local nCnt     := 0
Local nCols		  :=	IIf(cProdRec=='P',1,5)
Local nPosAEFPerc := aScan(aHeader ,{|x| AllTrim(x[2])=="AEF_QTD001"})
Local nPosAEFIT   := aScan(aHeader ,{|x| AllTrim(x[2])=="AEF_ITEM"})
Local nPosAEFProd := aScan(aHeader ,{|x| AllTrim(x[2])==IIf(cProdRec=='P',"AEF_PRODUT","AEF_RECURS")})
Local nPosAFAProd := aScan(aHeaderAFA,{|x| AllTrim(x[2])==IIf(cProdRec=='P',"AFA_PRODUT","AFA_RECURS")})
Local nPosAFAIt   := aScan(aHeaderAFA,{|x| AllTrim(x[2])=="AFA_ITEM"})
Local nPosAFAQt   := aScan(aHeaderAFA,{|x| AllTrim(x[2])=="AFA_QUANT" })
Local nItProd	  := 0
Local nTotProd	  := 0
Local cPmsCust		:= SuperGetMv("MV_PMSCUST",.F.,"1") //Indica se utiliza o custo pela quantidade unitaria ou total
Local lQtdTrf		:= (cPmsCust == "2")

If !(nPosAEFProd==0 .or. nPosAFAIt==0 .or. nPosAFAProd==0 .or. nPosAEFIT==0)
	For nCnt := 1 To Len(aCols)

		If (nItProd := aScan(aColsAFA,{|x| x[nPosAFAIt]+x[nPosAFAProd]== aCols[nCnt][nPosAEFIT]+aCols[nCnt][nPosAEFProd]})) >0

			If !aColsAFA[nItProd][Len(aHeaderAFA)+1]
				nTotPerc  := 0
				nTotProd  := aColsAFA[nItProd][nPosAFAQt]

				If lQtdTrf
					nTotProd := nTotProd * M->AF9_QUANT
				Endif

				If nPosAEFPerc!=0
					For nX := nPosAEFPerc to Len(aHeader)
						nTotPerc += aCols[nCnt ,nX]
					Next nX
				Endif

				nTotPrev := (nTotPerc*nTotProd)/100

				If nTotPerc != 0 .And. nTotPrev <> nTotProd
					If cProdRec=='P'
						Aviso(STR0155,STR0164 + " " + aCols[nCnt][nPosAEFIT] + " " + STR0165 + " " + Alltrim(Str(nTotPrev))+ " " + STR0157 + " " + Alltrim(Str(nTotProd))+ " " + STR0158 + CRLF + STR0159,{STR0042}) //"Diferenca de quantidades"###"A soma da programacao do item"###"de produtos difere do total informado para a tarefa"###"e"###"respectivamente)."###"Modifique a quantidade na pasta de consumos."###"Ok"
					Else
						Aviso(STR0155,STR0164 + " " + aCols[nCnt][nPosAEFIT] + " " + STR0166 + " " + Alltrim(Str(nTotPrev))+ " " + STR0157 + " " + Alltrim(Str(nTotProd))+ " " + STR0158 + CRLF + STR0159,{STR0042}) //"Diferenca de quantidades"###"A soma da programacao do item"###"de recursos difere do total informado para a tarefa"###"e"###"respectivamente)."###"Modifique a quantidade na pasta de consumos."###"Ok"
					EndIf
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Next nCnt
Endif
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A203GtCkLs ºAutor ³ Marcelo Akama     º Data ³ 06/05/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Pega o Check List da tarefa                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A203GtCkLs()
Local aArea		:= GetArea()
Local aAJOArea		:= {}
Local lRO		:= .F.
Private aParam	:= {M->AF9_CHKLST}

If !Empty(M->AF9_DTATUI)
	lRO := .T.
EndIf

If !lRO .And. GetNewPar("MV_PMSCHKA","2")=="1"
	lRO := .T.
EndIf

If !lRO
	dbSelectArea("AJO")
	aAJOArea := AJO->(GetArea())
	dbSetOrder(1)
	AJO->(MsSeek(xFilial("AJO")+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA))
	Do While !lRO .And. !AJO->(Eof()) .And. AJO->(AJO_FILIAL+AJO_PROJET+AJO_REVISA+AJO_TAREFA)==xFilial("AJO")+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA
		If !Empty(AJO->AJO_INI)
			lRO:=.T.
		EndIf
		AJO->(dbSkip())
	EndDo
	RestArea(aAJOArea)
EndIf

If ParamBox( {	{ 1, "Check List", aParam[1], "@!", 'Empty(mv_par01) .Or. ExistCpo("AJQ", mv_par01, 1)', "AJQ", IIf(lRO,".F.",".T."), TamSX3("AF9_CHKLST")[1], .F. } ; //"Check List"
		} ;
		,"Parametros" ; //"Parametros"
		,@aParam )
EndIf

RestArea(aArea)

Return aParam[1]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PmsRecOff º Autor ³ Adriano da Silva  º Data ³21/07/2010   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida as celulas preenchidas do cronograma de consumo     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ X3_VALID do campo AFA_RECURS			                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSRecOff()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração das Variaveis										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet		:= .T.
Local aRet		:= {}
Local aArea		:= GetArea()
Local nPosRec 	:= aScan(aHeader,{|x|AllTrim(x[2])== "AFA_RECURS"})
Local nPosNRec 	:= aScan(aHeader,{|x|AllTrim(x[2])== "AFA_DESCRI"})
Local lTMKPMS   := If(GetMv("MV_QTMKPMS",.F.,1) >= 3,.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao do QNC x TMK x PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTMKPMS
	aCols	:= PmsAtuaCols()

	If !aCols[n][Len(aCols[n])] .And. !Empty(aCols[n][nPosRec])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Função que Verifica se o Recurso está Off-Line. Retorna o Recurso e lRet			³
		//³ aRet[1] := Código do Recurso Substituto ou Atual / [2] := lRet .T./.F.				³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := QNCRecOff(aCols[n][nPosRec])

	EndIf

	If Len (aRet) > 0
		aCols[n][nPosRec] := aRet[1]
		aCols[n][nPosNRec] := Posicione("AE8",1,xFilial('AE8')+AllTrim(aCols[n][nPosRec]),"AE8_DESCRI")
		lRet := aRet[2]
	EndIf

	M->AFA_RECURS := aCols[n][nPosRec]
	FATPDLogUser("PMSRECOFF")
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A203GDAN9IncºAutor  ³Fabricio Romera   º Data ³  01/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza inclusao/alteracao e exclusao de impostos na tabela º±±
±±º          ³de impostos das tarefas (AN9)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³A203GD1LinOk                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203GDAN9Inc(aHeader,aCols,n, nGetDados, lExc)

Local cChave
Local cItem      := ""
Local cProd      := ""
Local cRecurso   := Space(15)
Local aImposto   := {}
Local nQtde		 := 0
Local nPrecoUnit := 0
Local nPosItem	 := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_ITEM"})
Local nPosProd	 := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_PRODUT"})
Local nPosQuant	 := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_QUANT"})
Local nPosRecur	 := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_RECURS"})
Local nPosCustD	 := aScan(aHeader,{|x|AllTrim(x[2])=="AFA_CUSTD"})
Local nTamTrf    := TamSXG("014",12)[1]

Default lExc     := aCols[n][Len(aCols[n])]

If nPosItem > 0
	cItem 	   := aCols[n][nPosItem]//Item
EndIf

If nPosProd > 0
	cProd	   := aCols[n][nPosProd]//Cod. Produto
EndIf

If nPosQuant > 0
	nQtde	   := aCols[n][nPosQuant]//Qtde
EndIf

If nPosCustD > 0
	nPrecoUnit := aCols[n][nPosCustD]//Preco Unitario
EndIf

//GetDados de Recursos
//2>Inclusao/Alteracao
//5>Delecao
If nGetDados == 2 .OR. nGetDados == 5
	cRecurso := aCols[n][nPosRecur]	//Recurso Vinculado
EndIf

DbSelectArea("SB1")
DbSetOrder(1)

cChave := xFilial("SB1")+ cProd
SB1->(DbSeek(cChave))

//Calcula impostos para o produto
PMSAN9ClcImp(@aImposto, cProd, nQtde, nPrecoUnit )

DbSelectArea("WK_AN9")
DbSetOrder(1)

If lExc
	A203AN9MAN("WK_AN9", M->(AF9_PROJET) , M->(AF9_REVISA) , PadR(M->(AF9_TAREFA), nTamTrf), 3, cItem, cProd, cRecurso, aImposto) //Exclusao
Else

	cChave := xFilial("AN9") + M->(AF9_PROJET) + M->(AF9_REVISA) + PadR(M->(AF9_TAREFA), nTamTrf) + cItem + cProd + cRecurso

    //Verifica se houve acao sobre item
	If !WK_AN9->(DbSeek(cChave))

		cChave := xFilial("AN9") + M->(AF9_PROJET) + M->(AF9_REVISA) + PadR(M->(AF9_TAREFA), nTamTrf) + cItem

		//Verifica se o produto foi alterado ou incluido
		If !WK_AN9->(DbSeek(cChave))
			A203AN9MAN("WK_AN9", M->(AF9_PROJET) , M->(AF9_REVISA) , PadR(M->(AF9_TAREFA), nTamTrf), 1, cItem, cProd, cRecurso, aImposto) //Inclusao
		Else
			A203AN9MAN("WK_AN9", M->(AF9_PROJET) , M->(AF9_REVISA) , PadR(M->(AF9_TAREFA), nTamTrf), 2, cItem, cProd, cRecurso, aImposto, WK_AN9->(AN9_PRODUT), IIf(Empty(cRecurso), "", WK_AN9->(AN9_RECURS)) ) //Alteracao
		EndIf

	Else
		A203AN9MAN("WK_AN9", M->(AF9_PROJET) , M->(AF9_REVISA) , PadR(M->(AF9_TAREFA), nTamTrf), 4, cItem, cProd, cRecurso, aImposto, WK_AN9->(AN9_PRODUT) ) //Alteracao
	EndIf

EndIf

A203aColsAN9(aHeaderSV,aColsSV,.T.,.F.,.F.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |A203AN9MAN()  ºAutor  ³Fabricio Romera     º Data ³  07/12/10º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza Inclusao/Alteracao e Inclusao na tabela temporaria deº±±
±±º          ³Tributos da Tarefa.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203AN9MAN(cAlias, cProjeto, cRevisa, cTarefa, nOpc, cItem, cProd, cRecurso, aImposto, cProdAnt, cRecursoAnt)

Local cChave
Local J

Default cProdAnt 	:= ""
Default cRecursoAnt := ""

//Tratamento de exclusao quando nao existir custo do produto/recurso posicionado na GetDados durante processo de alteracao
If Len(aImposto) == 0 .AND. nOpc == 4
	nOpc := 3
EndIf

//Atualizacao de valor de imposto
If nOpc == 4

	For J := 1 to Len(aImposto)

		cChave := xFilial("AN9") + cProjeto  + cRevisa + cTarefa + cItem + cProd + cRecurso + aImposto[J][1]

		DbSelectArea(cAlias)
		(cAlias)->(DbSetOrder(1))

		If (cAlias)->(DbSeek(cChave))
			If (cAlias)->(AN9_PERC) != aImposto[J][2] .Or. (cAlias)->(AN9_VALIMP) != aImposto[j][3]

				RecLock(cAlias, .F.)
					(cAlias)->(AN9_PERC)   := aImposto[J][2]
					(cAlias)->(AN9_VALIMP) := aImposto[j][3]
				MsUnlock()
			EndIf
		EndIf

	Next

	Return

EndIf

//Exclui imposto do item corrente
If nOpc == 3

	cChave := xFilial("AN9") + cProjeto + cRevisa + cTarefa + cItem + cProd + cRecurso

	DbSelectArea(cAlias)
	(cAlias)->(DbSetOrder(1))
	(cAlias)->(DbSeek(cChave))

	While (cAlias)->(!Eof()) .And. ;
	  cChave = xFilial("AN9") + (cAlias)->(AN9_PROJET) + (cAlias)->(AN9_REVISA) + (cAlias)->(AN9_TAREFA) + (cAlias)->(AN9_ITEM) + (cAlias)->(AN9_PRODUT) + (cAlias)->(AN9_RECURS)

		RecLock(cAlias,.F.,.T.)
			dbDelete()
		MsUnlock()

		(cAlias)->(DbSkip())

	End

EndIf

//Busca produto alterado e exclui imposto referente ao produto/recurso anterior
If nOpc == 2

	cChave := xFilial("AN9") + cProjeto  + cRevisa + cTarefa + cItem + cProdAnt + IIf(!Empty(cRecursoAnt),cRecursoAnt,cRecurso)

	DbSelectArea(cAlias)
	DbSetOrder(1)
	DbSeek(cChave)

	While (cAlias)->(!Eof()) .And. AllTrim( xFilial("AN9") + (cAlias)->(AN9_PROJET + AN9_REVISA + AN9_TAREFA + AN9_ITEM + AN9_PRODUT + AN9_RECURS) ) == AllTrim(cChave)
		RecLock(cAlias,.F.,.T.)
			dbDelete()
		MsUnlock()

		(cAlias)->(DbSkip())

	End

EndIf

//Novo imposto de Produto
If nOpc == 1 .or. nOpc == 2

	For J := 1 to Len(aImposto)

		RecLock(cAlias, .T.)
			(cAlias)->(AN9_FILIAL) := xFilial("AN9")
			(cAlias)->(AN9_PROJET) := cProjeto
			(cAlias)->(AN9_REVISA) := cRevisa
			(cAlias)->(AN9_TAREFA) := cTarefa
			(cAlias)->(AN9_ITEM)   := cItem
			(cAlias)->(AN9_PRODUT) := cProd
			(cAlias)->(AN9_RECURS) := cRecurso
			(cAlias)->(AN9_CODIMP) := aImposto[J][1]
			(cAlias)->(AN9_PERC)   := aImposto[J][2]
			(cAlias)->(AN9_VALIMP) := aImposto[j][3]
		MsUnlock()

	Next

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A203GetWKAN9()ºAutor  ³Fabricio Romera     º Data ³  07/12/10º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria tabela temporaria de Tributos da Tarefa.                º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A203GetWKAN9()

Local cNomeArq := ""
Local cNomeInd := ""

	If Select("WK_AN9") != 0
		//Limpa arquivo de trabalho
		DbSelectArea("WK_AN9")
		WK_AN9->(DbGoTop())
		While WK_AN9->(!EOF())
			RecLock("WK_AN9",.F.)
				DbDelete()
			MsUnLock()
			WK_AN9->(DbSkip())
		End
		WK_AN9->(__DBPACK())
		//Return
	Else
		//Cria arquivo de trabalho da tabela AN9
		dbSelectArea("AN9")
		aStructAN9 := AN9->(dbStruct())		
		
		If( Type("oTempTbAN9") == "O")
			oTempTbAN9:Delete()
			freeObj(oTempTbAN9)
			oTempTbAN9 := nil
		EndIf
		
		cNomeArq 	:= "WK_AN9"
		
		//-------------------------------------------------------------------
		// Estrutura tabela temporaria TRB.  
		//-------------------------------------------------------------------
		oTempTbAN9	:= FWTemporaryTable():New( cNomeArq )
		
		//-------------------------------------------------------------------
		// Atribui o  os índices.  
		//-------------------------------------------------------------------
		oTempTbAN9:SetFields( aStructAN9 )
		oTempTbAN9:AddIndex("1",{"AN9_FILIAL","AN9_PROJET","AN9_REVISA","AN9_TAREFA","AN9_ITEM","AN9_PRODUT","AN9_RECURS","AN9_CODIMP"})
		
		//------------------
		//Criação da tabela
		//------------------
		oTempTbAN9:Create()
	
		(cNomeArq)->( DBSetOrder( 1 ) )
		
		
	EndIf

	If AF8->AF8_PROJET == AF9->AF9_PROJET //Verifica se a tarefa pertence ao projeto posicionado 
		AN9->(DbGoTop())
		AN9->(dbSeek(xFilial("AN9") + M->AF9_PROJET + M->AF9_REVISA + M->AF9_TAREFA))
	
		While ( AN9->( !Eof() )) .And. AN9->AN9_FILIAL + AN9->AN9_PROJET + AN9->AN9_REVISA + AN9->AN9_TAREFA == xFilial("AF9") + M->AF9_PROJET + M->AF9_REVISA + M->AF9_TAREFA
	
			RecLock("WK_AN9", .T.)
				WK_AN9->(AN9_FILIAL) := AN9->(AN9_FILIAL)
				WK_AN9->(AN9_PROJET) := AN9->(AN9_PROJET)
				WK_AN9->(AN9_REVISA) := AN9->(AN9_REVISA)
				WK_AN9->(AN9_TAREFA) := AN9->(AN9_TAREFA)
				WK_AN9->(AN9_ITEM)   := AN9->(AN9_ITEM)
				WK_AN9->(AN9_PRODUT) := AN9->(AN9_PRODUT)
				WK_AN9->(AN9_RECURS) := AN9->(AN9_RECURS)
				WK_AN9->(AN9_CODIMP) := AN9->(AN9_CODIMP)
				WK_AN9->(AN9_PERC)   := AN9->(AN9_PERC)
				WK_AN9->(AN9_VALIMP) := AN9->(AN9_VALIMP)
			MsUnlock()
	
			AN9->(DbSkip())
		End
	EndIf

Return	cNomeArq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A203aColsAN9()ºAutor  ³Fabricio Romera     º Data ³  07/12/10º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega aCols da GetDados de Tributos.                       º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A203aColsAN9(aHeaderSV,aColsSV,lDados,lTrava,lAltOuExc)

Local ny
Local nPosTrib  := FolderOrd(STR0183) //Tributos
Local lContinua := .T.
Local nRegImp   := 0

DEFAULT lDados := .T.

If lDados
	aColsSV[nPosTrib]:=	{}

	dbSelectArea("WK_AN9")
	dbSetOrder(1)
	dbSeek(xFilial("AN9") + M->AF9_PROJET + M->AF9_REVISA + M->AF9_TAREFA)
	While !Eof() .And. WK_AN9->(AN9_FILIAL + AN9_PROJET + AN9_REVISA + AN9_TAREFA) == xFilial("AF9") + M->(AF9_PROJET + AF9_REVISA + AF9_TAREFA) .And. lContinua

		nRegImp := 0
		//Verifica se ja existe mesmo imposto e percentual para a tarefa
		For ny := 1 to Len(aColsSV[nPosTrib])
			If aColsSV[nPosTrib][ny][1] == WK_AN9->AN9_CODIMP .And. aColsSV[nPosTrib][ny][2] == WK_AN9->AN9_PERC
				nRegImp := ny
				Exit
			End If
		Next

		If nRegImp > 0
			aColsSV[nPosTrib][nRegImp][3] += WK_AN9->AN9_VALIMP
		Else
			// trava o registro do AFP - Alteracao, Exclusao
			If lTrava .And. lAltOuExc
				If ! SoftLock("WK_AN9")
					lContinua := .F.
				Else
					aAdd(aRecAN9,RecNo())
				Endif
			EndIf

			aADD(aColsSV[nPosTrib],Array(Len(aHeaderSV[nPosTrib])+1))

			For ny := 1 to Len(aHeaderSV[nPosTrib])
				If ( aHeaderSV[nPosTrib][ny][10] != "V")
					aColsSV[nPosTrib][Len(aColsSV[nPosTrib])][ny] := FieldGet(FieldPos(aHeaderSV[nPosTrib][ny][2]))
				Else
					aColsSV[nPosTrib][Len(aColsSV[nPosTrib])][ny] := CriaVar(aHeaderSV[nPosTrib][ny][2])
				EndIf
				aColsSV[nPosTrib][Len(aColsSV[nPosTrib])][Len(aHeaderSV[nPosTrib])+1] := .F.
			Next ny
		EndIf

		dbSelectArea("WK_AN9")
		dbSkip()
	EndDo

	//Altera o codigo do impostos para exibir a descricao do imposto
	For ny := 1 to Len(aColsSV[nPosTrib])
		aColsSV[nPosTrib][ny][1] := PMSGetAN9Desc(aColsSV[nPosTrib][ny][1])
	Next
EndIf

If Empty(aColsSV[nPosTrib])

	AADD (aColsSV[nPosTrib],Array(Len(aHeaderSV[nPosTrib])+1))
	For ny := 1 to Len(aHeaderSV[nPosTrib])
		If Trim(aHeaderSV[nPosTrib][ny][2]) == "AN9_ITEM"
			aColsSV[nPosTrib][1][ny] := StrZero(1, TamSX3("AN9_ITEM")[1])
		Else
			aColsSV[nPosTrib][1][ny] := CriaVar(aHeaderSV[nPosTrib][ny][2])
		EndIf
			aColsSV[nPosTrib][1][Len(aHeaderSV[nPosTrib])+1] := .F.
	Next ny
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A203aTotImp() ºAutor  ³Fabricio Romera     º Data ³  07/12/10º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o total de impostos da tarefa.                       º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A203aTotImp()
Local I
Local nTotImp  := 0
Local nPosTrib := FolderOrd(STR0183) //"Tributos"

For I := 1 to Len(aColsSV[nPosTrib])
	nTotImp += aColsSV[nPosTrib][I][3]
Next

Return nTotImp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSAN9ClcImpºAutor³Fabricio Romera     º Data ³  07/16/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula impostos de um produto da tarefa.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAN9ClcImp(aImp, cCodProd, nQtdVend, nPrcUnit )

Local nValICM 		:= 0
Local nAliqICM 		:= 0
Local nValSOL 		:= 0
Local nAliqSOL 		:= 0
Local nValCMP 		:= 0
Local nAliqCMP 		:= 0
Local nValIPI 		:= 0
Local nAliqIPI 		:= 0
Local nValISS 		:= 0
Local nAliqISS 		:= 0
Local nValIRR  		:= 0
Local nAliqIRR 		:= 0
Local nValINSS		:= 0
Local nAliqINSS		:= 0
Local nValCofins		:= 0
Local nAliqCofins		:= 0
Local nValCSL 		:= 0
Local nAliqCSL 		:= 0
Local nValPIS 		:= 0
Local nAliqPIS 		:= 0
Local nValPS2 		:= 0
Local nAliqPS2 		:= 0
Local nValCF2 		:= 0
Local nAliqCF2 		:= 0
Local nValSES 		:= 0
Local nAliqSES 		:= 0
Local nQtdPeso		:= 0
Local nItem       	:= 1
Local nValTotItem 	:= 0
Local aImpCalc		:= {}

Local cTESProd		:= ""

DEFAULT aImp 		:= {}
DEFAULT cCodProd 	:= 0
DEFAULT nQtdVend	:= 0
DEFAULT nPrcUnit	:= 0

nValTotItem := nQtdVend * nPrcUnit

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona Registros                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA1")
DbSetOrder(1)
SA1->( MsSeek(xFilial("SA1")+AF8->AF8_CLIENT+AF8->AF8_LOJA) )

DbSelectArea("SB1")
dbSetOrder(1)
If SB1->(MsSeek(xFilial("SB1")+cCodProd))
	cTESProd := SB1->(B1_TS)
	nQtdPeso := nQtdVend*SB1->B1_PESO
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a funcao fiscal                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisSave()
MaFisEnd()
MaFisIni(AF8->AF8_CLIENT,;	// 1-Codigo Cliente/Fornecedor
	AF8->AF8_LOJA,;			// 2-Loja do Cliente/Fornecedor
	"C",;						// 3-C:Cliente , F:Fornecedor
	"N",;						// 4-Tipo da NF
	SA1->A1_TIPO,;			// 5-Tipo do Cliente/Fornecedor
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	"MATA461")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Agrega os itens para a funcao fiscal         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisAdd(cCodProd,;		// 1-Codigo do Produto ( Obrigatorio )
	cTESProd,;				// 2-Codigo do TES ( Opcional )
	nQtdVend,;				// 3-Quantidade ( Obrigatorio )
	nPrcUnit,;				// 4-Preco Unitario ( Obrigatorio )
	0,;						// 5-Valor do Desconto ( Opcional )
	"",;					// 6-Numero da NF Original ( Devolucao/Benef )
	"",;					// 7-Serie da NF Original ( Devolucao/Benef )
	0,;						// 8-RecNo da NF Original no arq SD1/SD2
	0,;						// 9-Valor do Frete do Item ( Opcional )
	0,;						// 10-Valor da Despesa do item ( Opcional )
	0,;						// 11-Valor do Seguro do item ( Opcional )
	0,;						// 12-Valor do Frete Autonomo ( Opcional )
	nValTotItem,;			// 13-Valor da Mercadoria ( Obrigatorio )
	0)						// 14-Valor da Embalagem ( Opcional )

MaFisAlt("IT_PESO"	,nQtdPeso		,nItem)
MaFisAlt("IT_PRCUNI"	,nPrcUnit		,nItem)
MaFisAlt("IT_VALMERC",nValTotItem	,nItem)

If cPaisLoc == "BRA"
	//ICMS
	nValICM 	:= MaFisRet(nItem, "IT_VALICM")
	nAliqICM 	:= MaFisRet(nItem, "IT_ALIQICM")
	
	//ICMS SOLIDARIDO
	nValSOL 	:= MaFisRet(nItem, "IT_VALSOL")
	nAliqSOL 	:= MaFisRet(nItem, "IT_ALIQSOL")
	
	//ICMS Complementar
	nValCMP 	:= MaFisRet(nItem, "IT_VALCMP")
	nAliqCMP 	:= MaFisRet(nItem, "IT_ALIQCMP")
	
	//IPI
	nValIPI 	:= MaFisRet(nItem, "IT_VALIPI")
	nAliqIPI 	:= MaFisRet(nItem, "IT_ALIQIPI")
	
	//ISS
	nValISS 	:= MaFisRet(nItem, "IT_VALISS")
	nAliqISS 	:= MaFisRet(nItem, "IT_ALIQISS")
	
	//IR
	nValIRR 	:= MaFisRet(nItem, "IT_VALIRR")
	nAliqIRR 	:= MaFisRet(nItem, "IT_ALIQIRR")
	
	//INSS
	nValINSS	:= MaFisRet(nItem, "IT_VALINS")
	nAliqINSS	:= MaFisRet(nItem, "IT_ALIQINS")
	
	//COFINS
	nValCofins	:= MaFisRet(nItem, "IT_VALCOF")
	nAliqCofins := MaFisRet(nItem, "IT_ALIQCOF")
	
	//CSLL
	nValCSL 	:= MaFisRet(nItem, "IT_VALCSL")
	nAliqCSL 	:= MaFisRet(nItem, "IT_ALIQCSL")
	
	//PIS
	nValPIS 	:= MaFisRet(nItem, "IT_VALPIS")
	nAliqPIS 	:= MaFisRet(nItem, "IT_ALIQPIS")
	
	//PIS 2
	nValPS2 	:= MaFisRet(nItem, "IT_VALPS2")
	nAliqPS2 	:= MaFisRet(nItem, "IT_ALIQPS2")
	
	//COFINS 2
	nValCF2 	:= MaFisRet(nItem, "IT_VALCF2")
	nAliqCF2 	:= MaFisRet(nItem, "IT_ALIQCF2")
	
	//SES
	nValSES 	:= MaFisRet(nItem, "IT_VALSES")
	nAliqSES 	:= MaFisRet(nItem, "IT_ALIQSES")
	
	MaFisWrite(1)
	
	If nValIcm > 0
		aAdd(aImp, {"ICM", nAliqICM, nValICM} )
	End If
	If nValSOL > 0
		aAdd(aImp, {"SOL", nAliqSOL, nValSOL} )
	End If
	If nValIPI > 0
		aAdd(aImp, {"IPI" , nAliqIPI, nValIPI} )
	End If
	If nValISS > 0
		aAdd(aImp, {"ISS" , nAliqISS, nValISS} )
	End If
	If nValIRR > 0
		aAdd(aImp, {"IRR" , nAliqIRR, nValIRR} )
	End If
	If nValINSS > 0
		aAdd(aImp, {"INS" , nAliqINSS, nValINSS} )
	End If
	If nValPIS > 0
		aAdd(aImp, {"PIS" , nAliqPIS, nValPIS} )
	End If
	If nValCofins > 0
		aAdd(aImp, {"COF" , nAliqCofins, nValCofins} )
	End If
	If nValCMP > 0
		aAdd(aImp, {"CMP" , nAliqCMP, nValCMP} )
	End If
	If nValCSL > 0
		aAdd(aImp, {"CSL" , nAliqCSL, nValCSL} )
	End If
	If nValPS2 > 0
		aAdd(aImp, {"PS2" , nAliqPS2, nValPS2} )
	End If
	If nValCF2 > 0
		aAdd(aImp, {"CF2" , nAliqCF2, nValCF2} )
	End If
	If nValSES > 0
		aAdd(aImp, {"SES" , nAliqSES, nValSES} )
	End If
Else
	//Na argentina o calculo de impostos depende da serie.
	If cPaisLoc == 'ARG'
		MaFisAlt('NF_SERIENF',LocXTipSer('SA1',MVNOTAFIS))
	Endif

	aImpCalc := MaFisNFCab()
	For nItem := 1 to Len(aImpCalc)
		If aImpCalc[nItem,4] > 0
			aAdd(aImp, {aImpCalc[nItem,1] , aImpCalc[nItem,4], aImpCalc[nItem,5]} )
		EndIf
	Next nItem
EndIf

MaFisEnd()
MaFisRestore()

Return aImp


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSAtuVal ºAutor  ³ Pedro Pereira Lima º Data ³  24/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAtuVal(nVal)
Local nGet		:= IIf(Type("oFolder") == "O",oFolder:nOption,0)
Local aRetCus	:= {}
Local lCCT		:= HasTemplate("CCT") .And. ExistTemplate("CCTAF9Calc")
Local lCalcTrib := IIf(AF8->AF8_PAR006 == '1' , .T., .F.)	//Verifica se havera calculo de impostos para as tarefas
Local nPercBDI := 0

If !IsAuto()
	If lCCT
		ExecTemplate("CCTAF9Calc",.F.,.F.,{nGet})
	Else
		aRetCus			:= PmsAF9CusTrf(nGet)
		nPercBDI		:= IIf(M->AF9_BDI <> 0,M->AF9_BDI,PmsGetBDIPad('AFC',M->AF9_PROJET,M->AF9_REVISA,M->AF9_EDTPAI, M->AF9_UTIBDI ) )
		M->AF9_CUSTO	:= aRetCus[1]
		M->AF9_CUSTO2	:= aRetCus[2]
		M->AF9_CUSTO3	:= aRetCus[3]
		M->AF9_CUSTO4	:= aRetCus[4]
		M->AF9_CUSTO5	:= aRetCus[5]
		If ! (aRetCus[1] == 0 .And. M->AF9_VALBDI <> 0 ) .and.  nPercBDI <> 0
			M->AF9_VALBDI:= aRetCus[1]*nPercBDI/100
		Endif
		M->AF9_TOTAL := aRetCus[1]+M->AF9_VALBDI
		If lCalcTrib
			M->AF9_TOTIMP := A203aTotImp()
		EndIf
	EndIf

	If Type("oEnch") == "O"
		oEnch:Refresh()
	EndIf
EndIf

Return nVal

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³INTEGDEF  ºAutor  ³Wilson de Godoi      º Data ³ 07/12/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para a interação com EAI                             º±±
±±º          ³envio e recebimento                                         º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IntegDef( cXml, nType, cTypeMsg )
Local aRet := {}
		aRet:= PMSI203( cXml, nType, cTypeMsg )
Return aRet

/*/{Protheus.doc} PmsCalcSuc

Função principal para o calculo das datas e horas de inicio e fim referente as tarefas sucessoras

@author Reynaldo Tetsu Miyashita

@since 23/10/2013

@version P11

@param cProjeto,   caracter, Codigo do projeto
@param cRevisa,    caracter, Codigo da revisão
@param cTarefa,    caracter, Codigo  da tarefa
@param lAtuEDT,    logico,   Se deve atualizar as EDTs
@param aAtuEDT,    array,    Codigos da EDT
@param lReprParc,  logico,   Se verdadeiro deve recalcular parcialmente
@param aBaseDados, array     Contem informacoes das tarefas já lidas como: o codigo, data e hora de inicio e fim, Recno

@return logico, Se verdadeiro calculado as novas datas

/*/
Static Function PmsCalcSuc(cProjeto,cRevisa,cTarefa,lAtuEDT, aAtuEDT,lReprParc,aBaseDados)
Local aArea		:= GetArea()
Local aTasks		:= {}
Local aRetorno		:= {}
Local lRet			:= .T.

aTasks := {cTarefa}

While Len(aTasks)>0
	// Funcao auxiliar que irá calcular as novas datas e horas das tarefas sucessoras
	aRetorno := AuxCalcSuc(cProjeto,cRevisa,aTasks,lAtuEDT,@aAtuEDT,lReprParc,@aBaseDados)

	lRet := aRetorno[1] // Se Verdadeiro validou todas as tarefas
	aTasks := aClone(aRetorno[2]) // Código das tarefas sucessoras

EndDo

RestArea(aArea)

Return lRet

/*/{Protheus.doc} AuxCalcSuc

Funcao auxiliar para o calculo das datas e horas de inicio e fim referente as tarefas sucessoras

@author Reynaldo Tetsu Miyashita

@since 23/10/2013

@version P11

@param cProjeto, 		caracter, Codigo do projeto
@param cRevisa, 		caracter, Codigo da revisão
@param aTasks, 		array,    Codigos da tarefa
@param lAtuEDT, 		logico,   Se deve atualizar as EDTs
@param aAtuEDT, 		array,    Codigos da EDT
@param lReprParc, 	logico,   Se verdadeiro deve recalcular parcialmente
@param aBaseDados, 	array     Contem informacoes das tarefas já lidas como: o codigo, data e hora de inicio e fim, Recno

@return array, [1] - As novas datas calculadas e [2] - Array com os codigos das tarefas sucessoras.

/*/
Static Function AuxCalcSuc(cProjeto,cRevisa,aTasks,lAtuEDT, aAtuEDT,lReprParc,aBaseDados)
Local aAreaAFD	:= AFD->(GetArea()) // salva somente a tabela AFD, pois a funcao pmscalcsuc que é a principal salva a area correte
Local lRet 	:= .T.
Local aTskSuc	:= {}
Local nCnt 	:= 0

DEFAULT lAtuEDT	:= .T.
DEFAULT aAtuEDT	:= {}
DEFAULT lReprParc := .F.

dbSelectArea("AFD")
dbSetOrder(2)  // verifica se alguma tarefa depende da tarefa atual (tem ela como predecessora)
For nCnt := 1 To Len(aTasks)
	lRet := .T.
	MSSeek(xFilial("AFD")+cProjeto+cRevisa+aTasks[nCnt])
	While (!Eof() .And. xFilial("AFD")+cProjeto+cRevisa+aTasks[nCnt]==;
			AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_PREDEC) .and. lRet
		PmsSimPrd(AFD->AFD_PROJET,AFD->AFD_REVISA,AFD->AFD_TAREFA,lAtuEDT,@aAtuEDT,lReprParc,@aBaseDados) // calcula se necessario as datas da tarefa informada

		nPosBase := aScan(aBaseDados,{|x|x[1]+x[2] == "AF9" + AFD->AFD_TAREFA })
		If (lRet := PA203VldRes(aBaseDados, nPosBase)) // valida as restricoes de datas da tarefa
			If aScan( aTskSuc, { |x| x==AFD->AFD_TAREFA } ) ==0
				aAdd(aTskSuc, AFD->AFD_TAREFA) // guarda a tarefa para que seja depois verificado se ela tem sucessora.
			EndIf
		Else
			aTskSuc := {}
			Exit
		EndIf
		AFD->(dbSkip())
	EndDo
	// houve alguma falha e cancela
	If !lRet
		Exit
	EndIf
Next nCnt

RestArea(aAreaAFD)
Return {lRet, aClone(aTskSuc)}

/*/{Protheus.doc} PMS203VAJ4

Funcao de validacao do codigo da EDT digitada no relacionam.

@author Edson Maricate

@since 18/05/2001

@version P11

@param cEDT, 		caracter, Codigo da EDT

@return lRet,       logico, Status da vadidaçao da EDT

/*/
Function PMS203VAJ4(cEDT)
Local nx := 0
Local lRet 		:= .T.
Local nPosPred	:= aScan(aHeader,{|x| AllTrim(x[2])=="AJ4_PREDEC"})

If cEDT==M->AF9_EDTPAI
	Pms203Msg(STR0021,CLR_HRED) //"Tarefa Invalida. A tarefa predecessora nao pode ser ela mesma."
	lRet := .F.
EndIf

If lRet
	For nx := 1 to len(aCols)
		If  nx !=n.And.!aCols[nx][Len(aCols[nx])].And.aCols[nx][nPosPred]==cEDT
			Pms203Msg(STR0022,CLR_HRED) //"Tarefa Invalida. Voce nao pode vincular uma tarefa predecessora duas vezes a uma tarefa sucessora."
			lRet := .F.
			Exit
		EndIf
	Next
EndIf

//Verificar!
If lRet .and. !Pms203Loop(M->AF9_PROJET,M->AF9_REVISA,cEdt,M->AF9_EDTPAI,"AFC",.T.)  //Chamada para validacao do relacionamento sob mesma EDTPAI
	Pms203Msg(STR0050,CLR_HRED)   //"Tarefa invalida. Este relacionamento ira criar uma referencia circular no projeto."
	lRet := .F.
EndIf

If lRet .and. !Pms203Loop(M->AF9_PROJET,M->AF9_REVISA,M->AF9_TAREFA,,"AFC",.F.)      //Chamada para relacionamento de EDTsPai diferentes
	Pms203Msg(STR0050,CLR_HRED)   //"Tarefa invalida. Este relacionamento ira criar uma referencia circular no projeto."
	lRet := .F.
EndIf

If lRet .and. !Pms203Loop(M->AF9_PROJET,M->AF9_REVISA,M->AF9_EDTPAI,,"AFC",Nil)  //Chamada para validacao do relacionamento sob mesma EDTPAI
	Pms203Msg(STR0050,CLR_HRED)   //"Tarefa invalida. Este relacionamento ira criar uma referencia circular no projeto."
	lRet := .F.
EndIf

If lRet .and. !PMS203REL(M->AF9_PROJET , M->AF9_REVISA , M->AJ4_PREDEC , M->AF9_TAREFA,M->AF9_EDTPAI, "AJ4")
	Pms203Msg(STR0050,CLR_HRED)   //"Tarefa invalida. Este relacionamento ira criar uma referencia circular no projeto."
	lRet := .F.
EndIf

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

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
    Função que verifica se a melhoria de Dados Protegidos existe.

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

