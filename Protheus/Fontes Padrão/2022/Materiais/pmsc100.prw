#include "pmsc100.ch"
#include "protheus.ch"
#include "msgraphi.ch"
#include "pmsicons.ch"

#DEFINE DTINICIAL      1
#DEFINE DTFINAL        2
#DEFINE PERIODO        3
#DEFINE PEDCOMPRA      4
#DEFINE DESPESAS       5
#DEFINE PEDVENDA       6
#DEFINE RECEITAS       7
#DEFINE SALDODIA       8
#DEFINE VARIACAODIA    9
#DEFINE SAIDASACUM     10
#DEFINE ENTRADASACUM   11
#DEFINE VARIACAOACUM   12
#DEFINE SALDOACUM      13

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSC100  ³ Autor ³ Edson Maricate        ³ Data ³ 17-02-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Sistema de Informacao de Projetos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC100()

If AMIIn(44) .And. !PMSBLKINT()
	PRIVATE cCadastro	:= STR0004 //"Painel de Controle"

	Pergunte("PMA200",.F.)
	
	PRIVATE aRotina := MenuDef()
	Private	aCores:= PmsAF8Color()
	
	SetKey (VK_F12, {|| PMSC100Pg() })
	
	CrteFilIni()

	mBrowse(6,1,22,75,"AF8",,,,,,aCores)

	CrteFilEnd()	
	Set Key VK_F12 To
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS100Leg³ Autor ³  Fabio Rogerio Pereira ³ Data ³ 19-03-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Exibicao de Legendas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC100, SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC100Leg(cAlias,nReg,nOpcx)
Local aLegenda:= {}
Local i       := 0

For i:= 1 To Len(aCores)
	Aadd(aLegenda,{aCores[i,2],aCores[i,3]})
Next i

aLegenda:= aSort(aLegenda,,,{|x,y| x[1] < y[1]})

BrwLegenda(cCadastro,STR0111,aLegenda) //"Legenda"

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSC100Dlg³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Consulta ao Sistema de Informacao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC100Dlg(cAlias,nReg,nOpcx)

Local cSavCadastro := cCadastro
Local oDlg
Local oTree
Local oMenu
Local cArquivo		:= CriaTrab(,.F.)

PRIVATE cRevisa		:= AF8->AF8_REVISA

Pergunte("PMA200",.F.)

// muda o titulo da consulta
Do Case
	Case nOpcx == 2
		cCadastro	+= STR0011 + AF8->AF8_PROJET // //" - Progresso Financeiro : "
	Case nOpcx == 3
		cCadastro	+= STR0012 + AF8->AF8_PROJET // //" - Progresso Fisico  : "
	Case nOpcx == 4
		cCadastro	+= STR0013 + AF8->AF8_PROJET	 // //" - Analise da Execucao : "
	Case nOpcx == 5
		cCadastro	+= STR0014 + AF8->AF8_PROJET	 // //" - Grafico do Valor Ganho : "
	Case nOpcx == 6
		cCadastro	+= STR0015 + AF8->AF8_PROJET	 // //" - Grafico de Eficiencia e Performance do Projeto ( Grafico Abba ) : "
	Case nOpcx == 7
		cCadastro	+= STR0016 //" - Fluxo de Caixa - "
EndCase

aMenu := {;
{TIP_PROJ_INFO, {||PmsPrjInf()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},; //"Informacoes do Projeto..."
{TIP_PROJ_CONSULTAS, {|| PMSC100MS(nOpcx,@oTree,cArquivo) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS}} //"&Consultar"

If mv_par01 == 2
	aCampos := {{"AF9_TAREFA","AFC_EDT",8,,,.F.,"",},{"AF9_DESCRI","AFC_DESCRI",55,,,.F.,"",150}}
	A200ChkPln(@aCampos)
	PmsPlanAF8(cCadastro,cRevisa,aCampos,@cArquivo,,,,aMenu,@oDlg,,,,.T.)
Else
	PmsDlgAF8(cCadastro,@oMenu,cRevisa,@oTree,,,,,aMenu,@oDlg,,@cArquivo,.T.)
EndIf

cCadastro := cSavCadastro

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSC100MS³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de direcionamento do menu da consulta.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC100MS(nView,oTree,cArquivo)
Local cAlias
Local nRecView

Private oProcess

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

(cAlias)->(dbGoto(nRecView))

If cAlias$"AF9/AFC"
	Do Case
		Case nView == 2
			oProcess := MsNewProcess():New({|| PmsCfgPFI(,oTree,,cArquivo) } ,STR0202 ) // "Gerando progresso Financeiro"
			oProcess:Activate() 
		Case nView == 3
			Processa({|| PmsCfgPFS(,oTree,,cArquivo) })
		Case nView == 4
			PMSC100AEX(oTree,cArquivo)
		Case nView == 5
			Processa({||PMSCfgEV(,oTree,,cArquivo)})
		Case nView == 6
			Processa({||PMC100Flx(oTree,cArquivo)})
	EndCase
Else
	Aviso(STR0115,STR0116,{STR0117},2) //"Atencao!"###"Selecao invalida. Selecione uma EDT ou uma Tarefa." //'Ok'
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSC100PFI³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta uma consulta do Progresso Financeiro         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC100                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC100PFI(oTree,aParametros,cArquivo)

Local oDlg
Local oGraphic
Local aArea		:= GetArea()
Local cAlias
Local nRecView
Local nStep
Local dx
Local nSerie
Local cTexto	:= ""
Local aSize     := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aInfo     := {}
Local aView		:= {}
Local aView2    := {}
Local cSimbolo	:= GetMv("MV_SIMB" + Str(aParametros[5], 1))
Local aTpGrafico:= { {"1" , 1}; //"1=Linha"
					,{"2" , 2}; //"2=Area"
					,{"3" , 3}; //"3=Pontos"
					,{"4" , 4}; //"4=Barra"
					,{"5" ,12}} //"5=Linha Rapida"
Local nPosTpGraf := 0
Local nTipoGraf  := 0
Local aAlltasks	 :=	{}
Local aAllEDT	 :=	{}
Local aTasks	 :=	{}
Local nY
Local aAux       := {}
Local nPos
Local aGrpTsk    := {}
Local aItTsk     := {}
Local aButtons		:= {}
Local nX	:= 0
Local lPMC100PFI := ExistBlock("PMC100PFI")  
Local aRetButt := {}

nPosTpGraf := aScan(aTpGrafico ,{|aItem| aItem[1]==aParametros[2] })
If nPosTpGraf > 0
	nTipoGraf := aTpGrafico[nPosTpGraf][2]
Else
	nTipoGraf := 1
EndIf

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

If ! (cAlias $ "AFC|AF9")
	Aviso(STR0115,STR0116,{STR0117},2) //"Atencao!"###"Selecao invalida. Selecione uma EDT ou uma Tarefa." //'Ok'
	Return
EndIf

// se o registro não estiver posicionado
If !(nRecView==NIL.OR.Empty(nRecView)) .AND. !((cAlias)->(RecNo())==nRecView)
	(cAlias)->(dbGoto(nRecView))
EndIf

aSize := MsAdvSize(,.F.,400)
aObjects := {}

AAdd( aObjects, { 100, 100 , .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

oFolder := TFolder():New(aPosObj[1,1],aPosObj[1,2],{STR0018,STR0019},{},oDlg,,,, .T., .F.,aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1]) //### //"Planilha de Valores"###"Representacao Grafica"

@ aPosObj[1,3]-aPosObj[1,1]-25,10  BITMAP oBmp RESNAME BMP_VERDE SIZE 16,16 NOBORDER PIXEL OF oFolder:aDialogs[2]
@ aPosObj[1,3]-aPosObj[1,1]-25,20  SAY STR0025 OF oFolder:aDialogs[2] PIXEL // //"Progresso Financeiro Previsto"
@ aPosObj[1,3]-aPosObj[1,1]-25,100 BITMAP oBmp1 RESNAME BMP_AZUL SIZE 16,16 NOBORDER PIXEL OF oFolder:aDialogs[2]
@ aPosObj[1,3]-aPosObj[1,1]-25,110 SAY STR0026 OF oFolder:aDialogs[2] PIXEL // //"Progresso Financeiro Realizado"

@ 2,2 MSGRAPHIC oGraphic SIZE aPosObj[1,4]-10,aPosObj[1,3]-aPosObj[1,1]-30 OF oFolder:aDialogs[2]

oGraphic:SetMargins( 0, 10, 10,10 )
oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
oGraphic:SetTitle( cSimbolo, "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
oGraphic:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .F. )
nSerie	:= oGraphic:CreateSerie( nTipoGraf )
nSerie2	:= oGraphic:CreateSerie( nTipoGraf )

Do Case
	Case cAlias=="AF9"
		If Empty(aParametros[3])
			aParametros[4]	:= If(AF9->AF9_FINISH>AF9->AF9_DTATUF,AF9->AF9_FINISH,If(!Empty(AF9->AF9_DTATUF),AF9->AF9_DTATUF,AF9->AF9_FINISH))
			aParametros[3]	:= If(AF9->AF9_START<AF9->AF9_DTATUI,AF9->AF9_START,If(!Empty(AF9->AF9_DTATUI),AF9->AF9_DTATUI,AF9->AF9_START))
		EndIf
		
		nStep   := INT((aParametros[4] - aParametros[3])/aParametros[1])
		nStep	:= If(nStep<=0,1,nStep)
		oProcess:SetRegua1(((aParametros[4]-aParametros[3])/nStep))
		oProcess:SetRegua2(2)
		
		For dx := aParametros[3] to aParametros[4] STEP nStep
			oProcess:IncRegua1( STR0203 + dtoc(dX) ) // "Data: "
			oProcess:IncRegua2(STR0204) // "Processando Previsto..."
			aHandle	:= PmsIniCOTP(AF9->AF9_PROJET,AF9->AF9_REVISA,dx,AF9->AF9_TAREFA,AF9->AF9_TAREFA)
			nVal := NoRound(PmsRetCOTP(aHandle,1,AF9->AF9_TAREFA)[aParametros[5]],2)
			oGraphic:Add(nSerie,nVal,DTOC(dx),CLR_HGREEN)
			aAdd(aView,{DTOC(dx),Transform(nVal,"@E 999,999,999,999.99"),0})
			oProcess:IncRegua2(STR0205) //"Processando Realizado..."
			aHandle	:= PmsIniCRTE(AF9->AF9_PROJET,AF9->AF9_REVISA,dx,AF9->AF9_TAREFA,AF9->AF9_TAREFA)
			nVal := NoRound(PmsRetCRTE(aHandle,1,AF9->AF9_TAREFA)[aParametros[5]],2)
			oGraphic:Add(nSerie2,nVal,DTOC(dx),CLR_HBLUE)
			aView[Len(aView)][3] := Transform(nVal,"@E 999,999,999,999.99")
		Next
	Case cAlias=="AFC"
		If Empty(aParametros[3])
			aParametros[4]	:= If(AFC->AFC_FINISH>AFC->AFC_DTATUF,AFC->AFC_FINISH,If(!Empty(AFC->AFC_DTATUF),AFC->AFC_DTATUF,AFC->AFC_FINISH))
			aParametros[3]	:= If(AFC->AFC_START<AFC->AFC_DTATUI,AFC->AFC_START,If(!Empty(AFC->AFC_DTATUI),AFC->AFC_DTATUI,AFC->AFC_START))
		EndIf
		nStep	:= INT((aParametros[4] - aParametros[3])/aParametros[1])
		nStep	:= If(nStep<=0,1,nStep)
		
		// adiciona a frente no filtro de tarefas caso seja selecionada
		If GetNewPar('MV_PMSCCT','1') == '2' .And. !Empty(aParametros[7])
			PmsSetFrt(aParametros[7])
		Endif

		cTexto	:= STR0020 + AFC->AFC_PROJET + STR0022 + AFC->AFC_EDT +"-"+AFC->AFC_DESCRI // "Projeto - " //" EDT : "
		MsAguarde({||PmsLoadTrf(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aAllEDT,,aAllTasks,If(Len(aParametros)>=6,aParametros[6],Nil ) ,.T. ,aTasks) ,cTexto})
		
		oProcess:SetRegua1(((aParametros[4]-aParametros[3])/nStep))
		oProcess:SetRegua2(Len(aAllTasks))

		aGrpTsk := {}
		aItTsk := {}
		For nY := 1 To Len(aTasks)
	   		aAdd( aItTsk ,aTasks[nY])
			If (nY % 200) == 0
				aAdd( aGrpTsk ,aItTsk )
				aItTsk := {}
			EndIf
		Next nY
		If Len(aItTsk) >0
			aAdd( aGrpTsk ,aItTsk )
		EndIf

		For dx := aParametros[3] to aParametros[4] STEP nStep
			oProcess:IncRegua1( STR0203 + dtoc(dX) ) // "Data: "
			aHandPrev := {}
			aHandReal := {}
			
			oProcess:SetRegua2(Len(aAllTasks))
			For nY:=	1 To	Len(aAllTasks)
				AF9->(MsGoTo(aAlltasks[nY]))
				aHandPrev	:= PmsIniCOTP(AFC->AFC_PROJET,AFC->AFC_REVISA,dx,AF9->AF9_TAREFA,AF9->AF9_TAREFA,,aHandPrev)
				oProcess:IncRegua2(STR0204) // "Processando Previsto..."
			Next nY
			
			oProcess:SetRegua2(Len(aGrpTsk))
			For nY := 1 To Len(aGrpTsk)
				aHandReal	:= PmsIniCRTE(AFC->AFC_PROJET,AFC->AFC_REVISA,dx,,,,,,,aHandReal,,aGrpTsk[nY])
				oProcess:IncRegua2(STR0205) // "Processando Realizado..."
			Next nY
			
			nVal := NoRound(PmsRetCOTP(aHandPrev,2,AFC->AFC_EDT)[aParametros[5]],2)
			oGraphic:Add(nSerie,nVal,DTOC(dx),CLR_HGREEN)
			aAdd(aView ,{DTOC(dx) ,Transform(nVal,"@E 999,999,999,999.99") ,0})
			
			nVal := NoRound(PmsRetCRTE(aHandReal,2,AFC->AFC_EDT)[aParametros[5]],2)

			If GetNewPar("MV_PMSTANT",.T.) //considera os titulos antecipados?
				aAux := {}
				aAux := PmsRetCRTE(aHandReal ,2 ,AFC->AFC_EDT)[6]
	
				For nPos := 1 to Len(aAux)
					If !Empty(aAux[nPos]) .And. AllTrim(aAux[nPos ,01])=="PA" .And. aAux[nPos ,02] <= DtoS(dx)
						nVal -= aAux[nPos ,03]
					EndIf
				Next nPos
			EndIf
			oGraphic:Add(nSerie2 ,nVal ,DTOC(dX) ,CLR_HBLUE)
			aView[Len(aView) ,03] := TransForm(nVal ,"@E 999,999,999,999.99")
		Next dX
EndCase

oView	:= TWBrowse():New( 2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,{STR0001,STR0023+cSimbolo,STR0024+cSimbolo},{100,90,90},oFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,) // //"Custo Previsto  "###"Custo Real  "
oView:SetArray(aView)
oView:bLine := { || aView[oView:nAT]}

Aadd(aView2,{STR0001,STR0023+cSimbolo,STR0024+cSimbolo}) //######
For dx := 1 to Len(aView)
	Aadd( aView2, aClone(aView[dx]) )
Next

aAdd(aButtons,{"BMPPOST" ,{|| oFolder:SetOption(2), PmsGrafMail(oGraphic,STR0027 ,{STR0028+cTexto },aView2) },STR0029 ,STR0178 })//"Progresso Financeiro Previsto x Realizado"###"Progresso Financeiro : "###"Enviar por E-Mail" ### "E-Mail"
aAdd(aButtons,{BMP_IMPRIMIR,{||oGraphic:SaveToImage(criatrab(,.F.)+".bmp","\temp\"),CtbGrafPrint(oGraphic,STR0027,{STR0028+cTexto },aView2,,, { 160 ,2950 ,((oGraphic:nBottom - oGraphic:nTop) * 3) + 425} ) }, STR0030 ,STR0179 })//"Impressao do grafico"## "Imprimir"

If lPMC100PFI //Progresso Financeiro
	aRetButt := ExecBlock("PMC100PFI",.F.,.F.)
	If ValType(aRetButt) == "A" .And. Len(aRetButt) > 0 //Preservo os botões originais
		For nX := 1 To Len(aRetButt)
			aAdd(aButtons,aRetButt[nX])
		Next nX
	EndIf
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End() },{||oDlg:End()},,aButtons)
PmsSetFrt("")
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsCfgPFI³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe uma tela com as configuracoes de visualizacao do Gantt  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsCfgPFI(oDlg,oTree,aParametros,cArquivo)
Local aTpGrafico:= {STR0088,; //"1=Linha"
					STR0089,; //"2=Area"
					STR0090,; //"3=Pontos"
					STR0091,; //"4=Barra"
					STR0099 } //"5=Linha Rapida"
Local nMoedas	:= MoedFin()
Local nx
Local aMoedas	:= {}
Local lContinua := .T.
Local aPergs	:=	{}

DEFAULT aParametros := {30,"1",AF8->AF8_START,dDataBase,1,"","             "}

If Len(aParametros) <6
	aadd(aParametros,"")
Endif

For nX := 1 to nMoedas
	aAdd(aMoedas,GetMV("MV_SIMB"+AllTrim(Str(nX,2,0))))
Next nX

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
EndIf
If cAlias == "AFC" .Or. cAlias == "AF8"
	aPergs	:=	{	{1,STR0031,aParametros[1],"@E 99","Positivo(mv_par01)",,".T.",40,.T.},; // //"Numero de Intervalos"
			{2,STR0032,aParametros[2],aTpGrafico,80,"",.F.},;  //"Tipo do Grafico"
			{1,STR0033,aParametros[3],"","",,"",50,.T.},; // //"Data Inicial"
			{1,STR0034,aParametros[4],"","",,"",50,.T.},;
			{3,STR0002,aParametros[5],aMoedas,50,"",.F.},; //"Visualizar valores em	
			{7,"Filtrar tarefas ","AF9",""}} //"Filtro "

		If GetNewPar('MV_PMSCCT','1') == '2'
			AAdd(aPergs,{1,"Frente ",aParametros[7],"@!","Vazio() .Or. ExistCpo('LJM')","LJM",".T.",50,.F.})
		Endif
Else
	aPergs	:=	{	{1,STR0031,aParametros[1],"@E 99","Positivo(mv_par01)",,".T.",40,.T.},; // //"Numero de Intervalos"
			{2,STR0032,aParametros[2],aTpGrafico,80,"",.F.},;  //"Tipo do Grafico"
			{1,STR0033,aParametros[3],"","",,"",50,.T.},; // //"Data Inicial"
			{1,STR0034,aParametros[4],"","",,"",50,.T.},;
			{3,STR0002,aParametros[5],aMoedas,50,"",.F.}; //"Visualizar valores em	
		}

Endif

While lContinua
	If ParamBox(aPergs,STR0003,@aParametros) //### //"Data Final"
		If oDlg <> Nil
			oDlg:End()
		EndIf
		
		If aParametros[4]> aParametros[3]
				PMSC100PFI(oTree,@aParametros,cArquivo)
				lContinua := .F.
		Else
			Alert(STR0180)
		EndIf
	Else
		lContinua := .F.
	EndIf
End

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSC100PFS³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta uma consulta do Progresso Fisico.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC100                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC100PFS(oTree,aParametros,cArquivo)

Local oDlg
Local oGraphic
Local nStep
Local dx
Local nSerie
Local aArea		:= GetArea()
Local cAlias
Local nRecView
Local aSize     := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aInfo     := {}
Local aView2    := {}
Local aView     := {}
Local nX		:= 0
Local aTpGrafico:= { {"1" , 1}; //"1=Linha"
					,{"2" , 2}; //"2=Area"
					,{"3" , 3}; //"3=Pontos"
					,{"4" , 4}; //"4=Barra"
					,{"5" ,12}} //"5=Linha Rapida"
Local nPosTpGraf := 0
Local nTipoGraf  := 0
Local nDec_PERC     := TamSX3("AFF_PERC")[2]
Local cPictAFF_PERC := x3Picture("AFF_PERC")
Local aButtons := {}
Local lPMC100PGF := ExistBlock("PMC100PGF")
Local aRetButt	:= {}


nPosTpGraf := aScan(aTpGrafico ,{|aItem| aItem[1]==aParametros[2] })
If nPosTpGraf > 0
	nTipoGraf := aTpGrafico[nPosTpGraf][2]
Else
	nTipoGraf := 1
EndIf

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

If ! (cAlias $ "AFC|AF9")
	Aviso(STR0115,STR0116,{STR0117},2) //"Atencao!"###"Selecao invalida. Selecione uma EDT ou uma Tarefa." //'Ok'
	Return
EndIf

aSize := MsAdvSize(,.F.,400)
aObjects := {}

AAdd( aObjects, { 100, 100 , .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

oFolder := TFolder():New(aPosObj[1,1],aPosObj[1,2],{STR0018,STR0019},{},oDlg,,,, .T., .F.,aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1]) //### //"Planilha de Valores"###"Representacao Grafica"

@ 2,2 MSGRAPHIC oGraphic SIZE aPosObj[1,4]-10,aPosObj[1,3]-aPosObj[1,1]-30 OF oFolder:aDialogs[2]

oGraphic:SetMargins( 0, 10, 10,10 )
oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
oGraphic:SetTitle( "%", "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
oGraphic:SetLegenProp( GRP_SCRBOTTOM, CLR_WHITE, GRP_SERIES, .T. )
nSerie  := oGraphic:CreateSerie( nTipoGraf, STR0037 ) //"Progresso Fisico Previsto"
nSerie2 := oGraphic:CreateSerie( nTipoGraf, STR0038 ) //"Progresso Fisico Realizado"

// adiciona a frente no filtro de tarefas caso seja selecionada
If GetNewPar('MV_PMSCCT','1') == '2' .And. !Empty (aParametros[5])
	PmsSetFrt(aParametros[5])
Endif
Do Case
	Case cAlias=="AF9"
		cTexto	:= STR0020 + AF9->AF9_PROJET + STR0021 + AF9->AF9_TAREFA +"-"+AF9->AF9_DESCRI	 //###
		If GetNewPar('MV_PMSCCT','1') == '2'.And. !Empty (aParametros[5])
			cTexto += " - Frente: " + aParametros[5]
		Endif
		If Empty(aParametros[3])
			aParametros[4]	:= If(AF9->AF9_FINISH>AF9->AF9_DTATUF,AF9->AF9_FINISH,If(!Empty(AF9->AF9_DTATUF),AF9->AF9_DTATUF,AF9->AF9_FINISH))
			aParametros[3]	:= If(AF9->AF9_START<AF9->AF9_DTATUI,AF9->AF9_START,If(!Empty(AF9->AF9_DTATUI),AF9->AF9_DTATUI,AF9->AF9_START))
		EndIf
		nStep   	:= INT((aParametros[4] - aParametros[3])/aParametros[1])
		nStep		:= If(nStep<1,1,nStep)
		ProcRegua(((aParametros[4]-aParametros[3])/nStep)*2)
		For dx := aParametros[3] to aParametros[4] STEP nStep
			nPerc		:= PmsPrvAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dx)/AF9->AF9_HDURAC*100
			nPerc 		:= If( nPerc>100 ,100 ,NoRound(nPerc ,nDec_PERC) )
			IncProc()
			oGraphic:Add(nSerie,nPerc,DTOC(dx),CLR_HGREEN)
			aAdd(aView,{DTOC(dx),Transform(nPerc,cPictAFF_PERC),0,Transform(nPerc*AF9->AF9_QUANT/100,"@E 9999999999.99"),0})
			
			nPerc		:= PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dx)
			nPerc 		:= NoRound(nPerc ,nDec_PERC ) 
			IncProc()
			oGraphic:Add(nSerie2,nPerc,DTOC(dx),CLR_HBLUE)
			aView[Len(aView)][3] := Transform(nPerc,cPictAFF_PERC)
			aView[Len(aView)][5] := Transform(nPerc*AF9->AF9_QUANT/100,"@E 9999999999.99")
			
		Next dX
	Case cAlias=="AFC"
		cTexto	:= STR0020 + AFC->AFC_EDT + STR0022 + AFC->AFC_EDT +"-"+AFC->AFC_DESCRI //###
		If GetNewPar('MV_PMSCCT','1') == '2' .And. !Empty (aParametros[5])
			cTexto += " - Frente: " + aParametros[5]
		Endif
		If Empty(aParametros[3])
			aParametros[4]	:= If(AFC->AFC_FINISH>AFC->AFC_DTATUF,AFC->AFC_FINISH,If(!Empty(AFC->AFC_DTATUF),AFC->AFC_DTATUF,AFC->AFC_FINISH))
			aParametros[3]	:= If(AFC->AFC_START<AFC->AFC_DTATUI,AFC->AFC_START,If(!Empty(AFC->AFC_DTATUI),AFC->AFC_DTATUI,AFC->AFC_START))
		EndIf
		nStep   := INT((aParametros[4] - aParametros[3])/aParametros[1])
		
		nStep	:= If(nStep<=0,1,nStep)
		ProcRegua(((aParametros[4]-aParametros[3])/nStep)*2)
		For dX := aParametros[3] to aParametros[4] STEP nStep
			nPerc := PmsPrvAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,dx)/AFC->AFC_HUTEIS*100
			nPerc := NoRound(nPerc ,nDec_PERC ) 
			IncProc()
			oGraphic:Add(nSerie,nPerc,DTOC(dx),CLR_HGREEN)
			aAdd(aView,{DTOC(dx),Transform(nPerc,cPictAFF_PERC),0,TransForm(nPerc*AFC->AFC_QUANT/100,"@E 9999999999.99"),0})

			// CCTR - Verifica se estamos usados Frente e Pega o seu Percentual
			If GetNewPar('MV_PMSCCT','1') == '2'  .And.!Empty(PmsGetFrt())
				nPerc := CCTPOCAFC(AFC->AFC_PROJETO,AFC->AFC_REVISA,AFC->AFC_EDT,dX)
			Else
				nPerc := PmsPOCAFC(AFC->AFC_PROJETO,AFC->AFC_REVISA,AFC->AFC_EDT,dx)
			Endif			
			nPerc := NoRound(nPerc ,nDec_PERC ) 
			IncProc()
			oGraphic:Add(nSerie2,nPerc,DTOC(dx),CLR_HBLUE)
			aView[Len(aView)][3] := TransForm(nPerc,cPictAFF_PERC)
			aView[Len(aView)][5] := Transform(nPerc*AFC->AFC_QUANT/100,"@E 9999999999.99")			
		Next dX
EndCase

oView   := TWBrowse():New( 2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,{STR0001,STR0035,STR0036,STR0181,STR0182},{100,90,90,90,90},oFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,) //###### //"% Prevista"###"% Real"###"Quant. Prevista"###"Quant. Realizada"
oView:SetArray(aView)
oView:bLine := { || aView[oView:nAT]}

Aadd(aView2,{STR0001,STR0035,STR0036, STR0181,STR0182}) //######

For nX := 1 to Len(aView)
	Aadd( aView2, aClone(aView[nx]) )
Next nX

aAdd(aButtons,{"BMPPOST" ,{||oFolder:SetOption(2), PmsGrafMail(oGraphic,STR0039,{STR0040+cTexto },aView2) },STR0029 ,STR0178 })//### "Progresso Fisico Previsto x Realizado" ### "Progresso Fisico : "###"Enviar por E-Mail" ### "E-Mail"
aAdd(aButtons,{BMP_IMPRIMIR,{||oGraphic:SaveToImage(criatrab(,.F.)+".bmp","\temp\"),CtbGrafPrint(oGraphic,STR0184,{STR0185+cTexto },aView2,,{ 360, 700, 1200, 1700, 2200},{ 160 ,2950 ,((oGraphic:nBottom - oGraphic:nTop) * 3) + 425} ) }, STR0030 ,STR0179 })

If lPMC100PGF //Progresso Financeiro
	aRetButt := ExecBlock("PMC100PGF",.F.,.F.)
	If ValType(aRetButt) == "A" .And. Len(aRetButt) > 0 //Preservo os botões originais
		For nX := 1 To Len(aRetButt)
			aAdd(aButtons,aRetButt[nX])
		Next nX
	EndIf
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End() },{||oDlg:End()},,aButtons) //"Impressao do grafico" ### "Imprimir"


PmsSetFrt("")
RestArea(aArea)

Return( NIL )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsCfgPFI³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe uma tela com as configuracoes de visualizacao do Gantt  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsCfgPFS(oDlg,oTree,aParametros,cArquivo)
Local aTpGrafico:= {STR0088,; //"1=Linha"
					STR0089,; //"2=Area"
					STR0090,; //"3=Pontos"
					STR0091,; //"4=Barra"
					STR0099 } //"5=Linha Rapida"
Local lContinua := .T.

DEFAULT aParametros := {30,"1",AF8->AF8_START,dDataBase,"              "}

While lContinua
	aPergs	:=	{	{1,STR0031,aParametros[1],"@E 99","Positivo(mv_par01)",,".T.",40,.T.},; //
		{2,STR0032,aParametros[2],aTpGrafico,80,"",.F.},;  //"Tipo do Grafico"
		{1,STR0033,aParametros[3],"","",,"",50,.T.},; //
		{1,STR0034,aParametros[4],"","",,"",50,.T.}}

	If GetNewPar('MV_PMSCCT','1') == '2' 
		AAdd(aPergs,{1,"Frente ",aParametros[5],"@!","Vazio() .Or. ExistCpo('LJM')","LJM",".T.",50,.F.})		
	Endif

	If ParamBox(aPergs,STR0003,@aParametros) //###
		If oDlg <> Nil
			oDlg:End()
		EndIf                     
		If aParametros[4] > aParametros[3] 
			PMSC100PFS(oTree,@aParametros,cArquivo)
			lContinua := .F.
		Else
			Alert(STR0198) //"A data final não deve ser igual ou menor que a data inicial."
		Endif
	Else
		lContinua := .F.
	EndIf
End	

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSC100AEX³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta uma consulta da analise da execucao.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC100                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC100AEX(oTree,cArquivo)

Local oDlg
Local aArea     := GetArea()
Local cAlias
Local nRecView
Local aView     := {}
Local dDataRef	
Local dET		
Local nCPT      := 0
Local nCOTP     := 0
Local nCRTE     := 0
Local nCOTE     := 0
Local nVC       := 0
Local nVP       := 0
Local nECT      := 0
Local nIDC      := 0
Local nIDP      := 0
Local aMoedas   := {}
Local nMoedas   := MoedFin()
Local nx
Local aRet      := {}
Local aAlltasks := {}
Local aAllEDT   := {}
Local nY
Local cFrente   := "              "
Local aPergs
Local aSavArea := {}
Local aButtons := {}
Local aRetButt := {}
Local lPMC100AEX := ExistBlock("PMC100AEX")

// verifica as Perguntas Seleciondas
For nx := 1 to nMoedas
	aAdd(aMoedas,GetMV("MV_SIMB"+AllTrim(Str(nx,2,0))))
Next

aPergs	:=	 {	{1,STR0001,dDataBase,"","","","",55,.T.},; // //"Data de Referencia"
				{3,STR0002,1,aMoedas,50,"",.F.}} //"Visualizar valores em
	
If GetNewPar('MV_PMSCCT','1') == '2'
	AAdd(aPergs,				{1,"Frente ",cFrente,"@!","Vazio() .Or. ExistCpo('LJM')","LJM",".T.",50,.F.})
Endif

If !ParamBox(aPergs,;//Altera pelo Template de CCT
	STR0003,@aRet)  //"Parametros"
	Return
Endif

// adiciona a frente no filtro de tarefas caso seja selecionada
If GetNewPar('MV_PMSCCT','1') == '2' .And. !Empty (aRet[3])
	PmsSetFrt(aRet[3])
Endif
dDataRef	:= aRet[1]
dET		:= aRet[1]

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

If ! (cAlias $ "AFC|AF9")
	Aviso(STR0115,STR0116,{STR0117},2) //"Atencao!"###"Selecao invalida. Selecione uma EDT ou uma Tarefa." //'Ok'
	Return
EndIf
              
aSavArea := GetArea()
dbSelectArea(cAlias)
dbGoTo(nRecView)

Do Case
	Case cAlias=="AF9"
		aHandle	:= PmsIniCOTP(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_FINISH,AF9->AF9_TAREFA,AF9->AF9_TAREFA)
		nCPT		:= PmsRetCOTP(aHandle,1,AF9->AF9_TAREFA)[aRet[2]]
		aHandle	:= PmsIniCOTP(AF9->AF9_PROJET,AF9->AF9_REVISA,dDataRef,AF9->AF9_TAREFA,AF9->AF9_TAREFA)
		nCOTP		:= PmsRetCOTP(aHandle,1,AF9->AF9_TAREFA)[aRet[2]]
		aHandle	:= PmsIniCOTE(AF9->AF9_PROJET,AF9->AF9_REVISA,dDataRef,AF9->AF9_TAREFA,AF9->AF9_TAREFA)
		nCOTE		:= PmsRetCOTE(aHandle,1,AF9->AF9_TAREFA)[aRet[2]]
		aHandle	:= PmsIniCRTE(AF9->AF9_PROJET,AF9->AF9_REVISA,dDataRef,AF9->AF9_TAREFA,AF9->AF9_TAREFA)
		nCRTE		:= PmsRetCRTE(aHandle,1,AF9->AF9_TAREFA)[aRet[2]]
		nVC		:= (nCOTE - nCRTE)/nCOTE*100
		nIDC	:= nCOTE/nCRTE*100
		nECT	:= nCPT/nIDC*100
		nIDP	:= nCOTE/nCOTP*100
		nVP		:= (nCOTE-nCOTP)/nCOTE*100
		
		// se não existe um IDP, não é possível calcular o DET		
		If nIDP == 0
			dET := PMS_EMPTY_DATE
		Else
			dET := Int((AF9->AF9_FINISH - AF9->AF9_START) / nIDP * 100) + AF9->AF9_START
		EndIf
		
		aAdd(aView ,{STR0020 ,"   " ,SPACE(8)+DTOC(aRet[1])                         ,""}) //
		aAdd(aView ,{STR0041 ,"   " ,Transform(nCPT ,"@E 999,999,999,999.99")           ,""}) // //"Custo Previsto no Termino"
		aAdd(aView ,{STR0042 ,"   " ,Transform(nCOTP ,"@E 999,999,999,999.99")          ,""}) // //"COTP - Custo Orcado do Trabalho Previsto"
		aAdd(aView ,{STR0043 ,"   " ,Transform(nCOTE ,"@E 999,999,999,999.99")          ,""}) // //"COTE - Custo Orcado do Trabalho Executado"
		aAdd(aView ,{STR0044 ,"   " ,Transform(nCRTE ,"@E 999,999,999,999.99")          ,""}) // //"CRTE - Custo Real do Trabalho Executado"
		aAdd(aView ,{STR0045 ,"   " ,SPACE(6)+Transform(nVC/100 ,"@E 99.99999999") ,SPACE(8)+Transform(nVC,"@E 9999.99%")})		 // //"VC - Variacao nos Custos"
		aAdd(aView ,{STR0046 ,"   " ,SPACE(6)+Transform(nIDC/100 ,"@E 99.99999999") ,SPACE(8)+Transform(nIDC,"@E 9999.99%")}) // //"IDC - Indice de Desempenho de Custos"
		aAdd(aView ,{STR0047 ,"   " ,Transform(nECT ,"@E 999,999,999,999.99")           ,""}) // //"ECT - Estimativa de Custo no Termino"
		aAdd(aView ,{STR0048 ,"   " ,SPACE(6)+Transform(nVP/100 ,"@E 99.99999999") ,SPACE(8)+Transform(nVP,"@E 9999.99%")})		 // //"VP - Variacao nos Prazos"
		aAdd(aView ,{STR0049 ,"   " ,SPACE(6)+Transform(nIDP/100 ,"@E 99.99999999") ,SPACE(8)+Transform(nIDP,"@E 9999.99%")}) // //"IDP - Indice de Desempenho de Prazo"
		aAdd(aView ,{STR0050 ,"   " ,SPACE(8)+DTOC(dET)                             ,""}) // //"DET - Data Estimada para o Termino"
	Case cAlias=="AFC"
		PmsLoadTrf(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aAllEDT,,aAllTasks)
		aHandle	:=	{}
		For	nY	:=	1	To Len(aAlltasks)	                                              
			AF9->(MsGoTo(aAlltasks[nY]))
			aHandle	:= PmsIniCOTP(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_FINISH,AF9->AF9_TAREFA,AF9->AF9_TAREFA,,aHandle)
		Next
		nCPT		:= PmsRetCOTP(aHandle,2,AFC->AFC_EDT)[aRet[2]]
		aHandle	:=	{}
		For	nY	:=	1	TO Len(aAlltasks)	                                              
			AF9->(MsGoTo(aAlltasks[nY]))
			aHandle	:= PmsIniCOTP(AFC->AFC_PROJET,AFC->AFC_REVISA,dDataRef,AF9->AF9_TAREFA,AF9->AF9_TAREFA,,aHandle)
		Next
		nCOTP		:= PmsRetCOTP(aHandle,2,AFC->AFC_EDT)[aRet[2]]
		aHandle	:=	{}
		For	nY	:=	1	To Len(aAlltasks)	                                              
			AF9->(MsGoTo(aAlltasks[nY]))
			aHandle	:= PmsIniCOTE(AFC->AFC_PROJET,AFC->AFC_REVISA,dDataRef,AF9->AF9_TAREFA,AF9->AF9_TAREFA,aHandle)
		Next
		nCOTE		:= PmsRetCOTE(aHandle,2,AFC->AFC_EDT)[aRet[2]]
		aHandle	:=	{}
		For	nY	:=	1	To Len(aAlltasks)	                                              
			AF9->(MsGoTo(aAlltasks[nY]))
			aHandle	:= PmsIniCRTE(AFC->AFC_PROJET,AFC->AFC_REVISA,dDataRef,AF9->AF9_TAREFA,AF9->AF9_TAREFA,,,,,aHandle)
		Next
		nCRTE	:= PmsRetCRTE(aHandle,2,AFC->AFC_EDT)[aRet[2]]
		nVC		:= (nCOTE - nCRTE)/nCOTE*100
		nIDC	:= nCOTE/nCRTE*100
		nECT	:= nCPT/nIDC*100
		nIDP	:= nCOTE/nCOTP*100
		nVP		:= (nCOTE-nCOTP)/nCOTE*100

		// se não existe um IDP, não é possível calcular o DET		
		If nIDP == 0
			dET   := PMS_EMPTY_DATE
		Else
			dET		:= Int((AFC->AFC_FINISH - AFC->AFC_START) / nIDP * 100) + AFC->AFC_START
		EndIf
		
		aAdd(aView ,{STR0001 ,"   " ,SPACE(8)+DTOC(aret[1])                         ,""}) //              
		aAdd(aView ,{STR0041 ,"   " ,Transform(nCPT ,"@E 999,999,999,999.99")           ,""}) // 
		aAdd(aView ,{STR0042 ,"   " ,Transform(nCOTP ,"@E 999,999,999,999.99")          ,""}) //
		aAdd(aView ,{STR0043 ,"   " ,Transform(nCOTE ,"@E 999,999,999,999.99")          ,""}) //
		aAdd(aView ,{STR0044 ,"   " ,Transform(nCRTE ,"@E 999,999,999,999.99")          ,""}) //
		aAdd(aView ,{STR0045 ,"   " ,SPACE(6)+Transform(nVC/100 ,"@E 99.99999999") ,SPACE(8)+Transform(nVC,"@E 9999.99%")})	 	 //
		aAdd(aView ,{STR0061 ,"   " ,SPACE(6)+Transform(nIDC/100 ,"@E 99.99999999") ,SPACE(8)+Transform(nIDC,"@E 9999.99%")}) //
		aAdd(aView ,{STR0047 ,"   " ,Transform(nECT ,"@E 999,999,999,999.99")           ,""}) // 
		aAdd(aView ,{STR0048 ,"   " ,SPACE(6)+Transform(nVP/100 ,"@E 99.99999999") ,SPACE(8)+Transform(nVP,"@E 9999.99%")})	 	 //
		aAdd(aView ,{STR0049 ,"   " ,SPACE(6)+Transform(nIDP/100 ,"@E 99.99999999") ,SPACE(8)+Transform(nIDP,"@E 9999.99%")}) //
		aAdd(aView ,{STR0050 ,"   " ,SPACE(8)+DTOC(dET)                             ,""}) //                  
EndCase

DEFINE MSDIALOG oDlg FROM 0,0  TO 320,593 TITLE cCadastro Of oMainWnd PIXEL

@ 12,2 TO 32,296 Label "" Of oDlg PIXEL
If cAlias == "AF9"
	@ 18,10 SAY STR0020+AF9->AF9_TAREFA+STR0021+AF9->AF9_TAREFA + " - "+AF9->AF9_DESCRI of oDlg PIXEL //###
Else
	@ 18,10 SAY STR0020+AFC->AFC_PROJET+STR0022+AFC->AFC_EDT + " - "+AFC->AFC_DESCRI of oDlg PIXEL //###
EndIf

// imprime o nome da Frente CCTR
If GetNewPar('MV_PMSCCT','1') == '2'  .And. !Empty(PmsGetFrt())
	@ 18,220 SAY "Frente: " + PmsGetFrt() of oDlg PIXEL
Endif
oView	:= TWBrowse():New( 35,2,295,120,,{STR0051,"",STR0052,STR0206},{130,1,60,60},oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //### //"Referencia"###"    Valor"
oView:SetArray(aView)
oView:bLine := { || aView[oView:nAT]}

aAdd(aButtons,{"BMPPOST",{||PmsGrafMail(,cCadastro,{cCadastro },aView) },STR0029,STR0178})

If lPMC100AEX //Progresso Financeiro
	aRetButt := ExecBlock("PMC100AEX",.F.,.F.)
	If ValType(aRetButt) == "A" .And. Len(aRetButt) > 0 //Preservo os botões originais
		For nX := 1 To Len(aRetButt)
			aAdd(aButtons,aRetButt[nX])
		Next nX
	EndIf
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End() },{||oDlg:End()} ,,aButtons) CENTERED //

PmsSetFrt("")

RestArea(aSavArea)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSC100Pg  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 31-07-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Abre tela com perguntas da rotina PMSC100                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC100                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC100Pg

Pergunte("PMA200",.T.)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSCLegenda³ Autor ³ Wagner Mobile Costa   ³ Data ³ 25-07-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta legenda dos graficos / GANTT.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC100                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSCLegenda(oDlg, aRodape, nSizeAtu, nSizeDef)

Local aColRod := { { } }
Local nRodape := 0
Local nSobObj := 10

If aRodape = Nil
	aRodape := { 	{ BMP_VERDE, STR0053, (oDlg:nBottom / 2.2), 05 },; // //"Previsto"
	{ BMP_AZUL, STR0054, (oDlg:nBottom / 2.2), (oDlg:nRight / 2.2) - 15 } } // //"Realizado"
ElseIf nSizeAtu # Nil .And. nSizeDef # Nil
	For nRodape := 1 To Len(aRodape)
		Aadd(aColRod[1], aRodape[nRodape][4])
	Next
	
	aColRod := MsObjGetPos(nSizeAtu, nSizeDef, aColRod)
	
	For nRodape := 1 To Len(aRodape)
		aRodape[nRodape][4] := aColRod[1][nRodape]
	Next
Endif

If Len(aRodape) > 0
	@ aRodape[1][3],aRodape[1][4] BITMAP Nil RESNAME aRodape[1][1] of oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aRodape[1][3],aRodape[1][4] + nSobObj SAY aRodape[1][2] of oDlg PIXEL
Endif

If Len(aRodape) > 1		// Uso as posicoes fixas
	@ aRodape[2][3],aRodape[2][4] BITMAP Nil RESNAME aRodape[2][1] of oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aRodape[2][3],aRodape[2][4] + nSobObj SAY aRodape[2][2] of oDlg PIXEL
Endif

If Len(aRodape) > 2
	@ aRodape[2][3],aRodape[3][4] BITMAP Nil RESNAME aRodape[3][1] of oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aRodape[2][3],aRodape[3][4] + nSobObj SAY aRodape[3][2] of oDlg PIXEL
Endif

If Len(aRodape) > 3
	@ aRodape[3][3],aRodape[4][4] BITMAP Nil RESNAME aRodape[4][1] of oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aRodape[3][3],aRodape[4][4] + nSobObj SAY aRodape[4][2] of oDlg PIXEL
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C100Click ³ Autor ³ Wagner Mobile Costa   ³ Data ³01/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizacao da alocacao dos recursos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oPar1  : Objeto GRID atual                                 ³±±
±±³          ³ aPar1  : Array com alocacao ou % por data dos apontamentos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C100Click(oGantt, lAlocacao)

Local oDlg
Local aAlocacao
Local aDialogo
Local nInter
Local aArray 	:= {}
Local nArray    := 0
Local cTitulo 	:= ""
Local bTitulo	:= { |cChave| SX3->(MSSeek(cChave)), AllTrim(X3Titulo()) }


#DEFINE DATA_INICIO			1
#DEFINE HORA_INICIO	        2
#DEFINE DATA_FINAL			3
#DEFINE HORA_FINAL			4
#DEFINE DESCRICAO_GANTT	    5
#DEFINE POSICAO_GANTT		6
#DEFINE TEXTO_INTERVALO	    7
#DEFINE COR_INTERVALO		8
#DEFINE ALOCACAO			9
#DEFINE CODIGO_TAREFA      10
#DEFINE POS_DET_ALOCACAO   11
#DEFINE POSICAO_INI_GANTT  12
#DEFINE POSICAO_FIM_GANTT  13

SX3->(DbSetOrder(2))

If oGantt:nLineAtu = 0
	Return .T.
Endif

If lAlocacao
	aAlocacao := oGantt:Cargo[oGantt:nLineAtu]
	
	For nInter 	:= 1 To Len(aAlocacao)
		For nArray := 1 To Len(aAlocacao[nInter][POS_DET_ALOCACAO])
			If 	aAlocacao[nInter][POS_DET_ALOCACAO][nArray][POSICAO_INI_GANTT] >=;
				oGantt:nIntervIni .And.;
				aAlocacao[nInter][POS_DET_ALOCACAO][nArray][POSICAO_FIM_GANTT] <=;
				oGantt:nIntervFim
				Aadd(aArray, { aAlocacao[nInter][POS_DET_ALOCACAO][nArray][CODIGO_TAREFA],;
				Trans(aAlocacao[nInter][POS_DET_ALOCACAO][nArray][ALOCACAO], "@R 999.99 %"),;
				Dtoc(aAlocacao[nInter][POS_DET_ALOCACAO][nArray][DATA_INICIO]),;
				aAlocacao[nInter][POS_DET_ALOCACAO][nArray][HORA_INICIO],;
				Dtoc(aAlocacao[nInter][POS_DET_ALOCACAO][nArray][DATA_FINAL]),;
				aAlocacao[nInter][POS_DET_ALOCACAO][nArray][HORA_FINAL] })
			Endif
			cTitulo := aAlocacao[nInter][POS_DET_ALOCACAO][nArray][DESCRICAO_GANTT]
		Next
	Next
	aDialogo := { 150, 0, 270, 600 }
Else
	aAlocacao := oGantt:Cargo
	For nArray := 1 To Len(aAlocacao)
		For nInter := 1 To Len(aAlocacao[nArray])
			If aAlocacao[nArray][nInter][3] = oGantt:nLineAtu
				Aadd(aArray, aAlocacao[nArray][nInter])
				cTitulo := aAlocacao[nArray][nInter][4]
			Endif
		Next
	Next
	aArray := ASort(aArray,,, { | x, y | 	X[1] < Y[1] })
	aDialogo := { 150, 0, 270, 420 }
Endif

If Len(aArray) = 0
	Return .T.
Endif

DEFINE MSDIALOG oDlg TITLE cTitulo From aDialogo[1],aDialogo[2] To;
aDialogo[3],aDialogo[4] OF oMainWnd PIXEL

If lAlocacao
	@ 05,05 	LISTBOX oQual VAR cVar Fields HEADER STR0055,; //"Tarefa"
	Eval(bTitulo, "AFA_ALOC"),;
	Eval(bTitulo, "AFA_START"),;
	Eval(bTitulo, "AFA_HORAI"),;
	Eval(bTitulo, "AFA_FINISH"),;
	Eval(bTitulo, "AFA_HORAF");
	SIZE (oDlg:nClientWidth / 2)- 38,(oDlg:nClientHeight / 2) - 10 ON DBLCLICK (oDlg:End()) PIXEL
	oQual:SetArray( aArray )
	oQual:bLine := { || { 	aArray[oQual:nAT, 1], aArray[oQual:nAT, 2],;
	aArray[oQual:nAT, 3], aArray[oQual:nAT, 4],;
	aArray[oQual:nAT, 5], aArray[oQual:nAT, 6] } }
Else
	@ 05,05 	LISTBOX oQual VAR cVar Fields HEADER 	Eval(bTitulo, "AFF_DATA"),;
	Eval(bTitulo, "AFF_QUANT");
	SIZE (oDlg:nClientWidth / 2) - 38,(oDlg:nClientHeight / 2) - 10 ON DBLCLICK (oDlg:End()) PIXEL
	oQual:SetArray( aArray )
	oQual:bLine := { || { 	aArray[oQual:nAT, 1], aArray[oQual:nAT, 2] } }
Endif

DEFINE SBUTTON FROM 3,(oDlg:nRight / 2) - 33 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSC100EV³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta uma consulta do grafico do valor ganho.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC100                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC100EV(oTree,aParametros,cArquivo)
Local oDlg
Local oGraphic
Local nStep
Local dx
Local nSerie
Local nValor   := 0
Local aArea		:= GetArea()
Local cAlias
Local nRecView
Local aSize     := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aInfo     := {}
Local aView     := {}
Local aView2    := {}
Local cSimbolo  := GetMv("MV_SIMB" + Str(aParametros[5], 1))
Local nX 		:= 0
Local aTpGrafico:= { {"1" , 1}; //"1=Linha"
					,{"2" , 2}; //"2=Area"
					,{"3" , 3}; //"3=Pontos"
					,{"4" , 4}; //"4=Barra"
					,{"5" ,12}} //"5=Linha Rapida"
Local nPosTpGraf := 0
Local nTipoGraf  := 0
Local aAlltasks	:=	{}
Local aAllEDT	:=	{}
Local nY      
Local aButtons := {}
Local aRetButt := {}
Local lPMC100EV := ExistBlock("PMC100EV")


nPosTpGraf := aScan(aTpGrafico ,{|aItem| aItem[1]==aParametros[2] })
If nPosTpGraf > 0
	nTipoGraf := aTpGrafico[nPosTpGraf][2]
Else
	nTipoGraf := 1
EndIf


If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

If ! (cAlias $ "AFC|AF9")
	Aviso(STR0115,STR0116,{STR0117},2) //"Atencao!"###"Selecao invalida. Selecione uma EDT ou uma Tarefa." //'Ok'
	Return
EndIf

// adiciona a frente no filtro de tarefas caso seja selecionada
If GetNewPar('MV_PMSCCT','1') == '2' .And. !Empty (aParametros[Iif ((cAlias == "AFC"),7,6)])
	PmsSetFrt(aParametros[Iif ((cAlias == "AFC"),7,6)])
Endif

aSize := MsAdvSize(,.F.,400)
aObjects := {}

AAdd( aObjects, { 100, 100 , .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

oFolder := TFolder():New(aPosObj[1,1],aPosObj[1,2],{STR0018,STR0019},{},oDlg,,,, .T., .F.,aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1]) //### //"Planilha de Valores"###"Representacao Grafica"

@ aPosObj[1,3]-aPosObj[1,1]-30,10 BITMAP oBmp1 RESNAME BMP_VERMELHO SIZE 16,16 NOBORDER PIXEL OF oFolder:aDialogs[2]
@ aPosObj[1,3]-aPosObj[1,1]-30,20 SAY STR0043 OF oFolder:aDialogs[2] PIXEL //
@ aPosObj[1,3]-aPosObj[1,1]-20,10 BITMAP oBmp2 RESNAME BMP_AZUL SIZE 16,16 NOBORDER PIXEL OF oFolder:aDialogs[2]
@ aPosObj[1,3]-aPosObj[1,1]-20,20 SAY STR0044 OF oFolder:aDialogs[2] PIXEL //
@ aPosObj[1,3]-aPosObj[1,1]-30,150 BITMAP oBmp RESNAME BMP_VERDE SIZE 16,16 NOBORDER PIXEL OF oFolder:aDialogs[2]
@ aPosObj[1,3]-aPosObj[1,1]-30,160 SAY STR0042 OF oFolder:aDialogs[2]PIXEL //

@ 2,2 MSGRAPHIC oGraphic SIZE aPosObj[1,4]-10,aPosObj[1,3]-aPosObj[1,1]-35 OF oFolder:aDialogs[2]

oGraphic:SetMargins( 0, 10, 10,10 )
oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
oGraphic:SetTitle( GetMv("MV_SIMB" + Str(aParametros[5], 1)), "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
oGraphic:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .F. )
nSerie  := oGraphic:CreateSerie( nTipoGraf )
nSerie2 := oGraphic:CreateSerie( nTipoGraf )
nSerie3 := oGraphic:CreateSerie( nTipoGraf )

Do Case
	Case cAlias=="AF9"
		cTexto	:= STR0020 + AF9->AF9_PROJET + STR0021 + AF9->AF9_TAREFA +"-"+AF9->AF9_DESCRI	 //###
		If Empty(aParametros[3])
			aParametros[4]	:= If(AF9->AF9_FINISH>AF9->AF9_DTATUF,AF9->AF9_FINISH,If(!Empty(AF9->AF9_DTATUF),AF9->AF9_DTATUF,AF9->AF9_FINISH))
			aParametros[3]	:= If(AF9->AF9_START<AF9->AF9_DTATUI,AF9->AF9_START,If(!Empty(AF9->AF9_DTATUI),AF9->AF9_DTATUI,AF9->AF9_START))
		EndIf
		
		nStep   := INT((aParametros[4] - aParametros[3])/aParametros[1])
		
		nStep	:= If(nStep<=0,1,nStep)
		ProcRegua(((aParametros[4]-aParametros[3])/nStep)*2)
		For dx := aParametros[3] to aParametros[4] STEP nStep
			aHandle	:= PmsIniCOTP(AF9->AF9_PROJET,AF9->AF9_REVISA,dx,AF9->AF9_TAREFA,AF9->AF9_TAREFA)
			IncProc()
			nValor := NoRound(PmsRetCOTP(aHandle,1,AF9->AF9_TAREFA)[aParametros[5]],2)
			
			oGraphic:Add(nSerie,nValor,DTOC(dx),CLR_HGREEN)
			aAdd(aView,{DTOC(dx),Transform(nValor,"@E 999,999,999,999.99"),0,0})
			
			aHandle := PmsIniCOTE(AF9->AF9_PROJET,AF9->AF9_REVISA,dx,AF9->AF9_TAREFA,AF9->AF9_TAREFA)
			IncProc()
			nValor := NoRound(PmsRetCOTP(aHandle,1,AF9->AF9_TAREFA)[aParametros[5]],2)
			
			oGraphic:Add(nSerie2,nValor,DTOC(dx),CLR_HRED)
			aView[Len(aView)][3] := Transform(nValor,"@E 999,999,999,999.99")
			
			aHandle	:= PmsIniCRTE(AF9->AF9_PROJET,AF9->AF9_REVISA,dx,AF9->AF9_TAREFA,AF9->AF9_TAREFA)
			IncProc()
			nValor := NoRound(PmsRetCRTE(aHandle,1,AF9->AF9_TAREFA)[aParametros[5]],2)
			
			oGraphic:Add(nSerie3,nValor,DTOC(dx),CLR_HBLUE)
			aView[Len(aView)][4] := Transform(nValor,"@E 999,999,999,999.99")
			
		Next
	Case cAlias=="AFC"
		cTexto	:= STR0020 + AFC->AFC_PROJETO + STR0022 + AFC->AFC_EDT +"-"+AFC->AFC_DESCRI //
		If Empty(aParametros[3])
			aParametros[4]	:= If(AFC->AFC_FINISH>AFC->AFC_DTATUF,AFC->AFC_FINISH,If(!Empty(AFC->AFC_DTATUF),AFC->AFC_DTATUF,AFC->AFC_FINISH))
			aParametros[3]	:= If(AFC->AFC_START<AFC->AFC_DTATUI,AFC->AFC_START,If(!Empty(AFC->AFC_DTATUI),AFC->AFC_DTATUI,AFC->AFC_START))
		EndIf
		nStep	:= INT((aParametros[4] - aParametros[3])/aParametros[1])
		nStep	:= If(nStep<=0,1,nStep)
		ProcRegua(((aParametros[4]-aParametros[3])/nStep)*2)
		PmsLoadTrf(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aAllEDT,,aAllTasks,If(Len(aParametros)>=6,aParametros[6],Nil))
//		PmsLoadTrf(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aAllEDT,,aAllTasks)
		For dx := aParametros[3] to aParametros[4] STEP nStep
			aHandle	:=	{}
			For	nY	:=	1	To Len(aAlltasks)	                                              
				AF9->(MsGoTo(aAlltasks[nY]))
				aHandle	:= PmsIniCOTP(AFC->AFC_PROJET,AFC->AFC_REVISA,dx,AF9->AF9_TAREFA,AF9->AF9_TAREFA,,aHandle)
			Next
//			aHandle	:= PmsIniCOTP(AFC->AFC_PROJET,AFC->AFC_REVISA,dx)
			IncProc()
			nValor := NoRound(PmsRetCOTP(aHandle,2,AFC->AFC_EDT)[aParametros[5]],2)
			oGraphic:Add(nSerie,nValor,DTOC(dx),CLR_HGREEN)
			
			aAdd(aView,{DTOC(dx),Transform(nValor,"@E 999,999,999,999.99"),0,0})
			aHandle	:=	{}
			For	nY	:=	1 To	Len(aAlltasks)	                                              
				AF9->(MsGoTo(aAlltasks[nY]))
				aHandle	:= PmsIniCOTE(AFC->AFC_PROJET,AFC->AFC_REVISA,dX,AF9->AF9_TAREFA,AF9->AF9_TAREFA,aHandle)
			Next
//			aHandle	:= PmsIniCOTE(AFC->AFC_PROJET,AFC->AFC_REVISA,dX)
			IncProc()
			nValor := NoRound(PmsRetCOTE(aHandle,2,AFC->AFC_EDT)[aParametros[5]],2)
			oGraphic:Add(nSerie2,nValor,DTOC(dx),CLR_HRED)
			
			aView[Len(aView)][3] := TransForm(nValor,"@E 999,999,999,999.99")
			aHandle	:=	{}
			For	nY	:=	1	To Len(aAlltasks)	                                              
				AF9->(MsGoTo(aAlltasks[nY]))
				aHandle	:= PmsIniCRTE(AFC->AFC_PROJET,AFC->AFC_REVISA,dx,AF9->AF9_TAREFA,AF9->AF9_TAREFA,,,,,aHandle)
			Next
//			aHandle	:= PmsIniCRTE(AFC->AFC_PROJET,AFC->AFC_REVISA,dx)

			IncProc()
			nValor := NoRound(PmsRetCRTE(aHandle,2,AFC->AFC_EDT)[aParametros[5]],2)
			oGraphic:Add(nSerie3,nValor,DTOC(dx),CLR_HBLUE)
			
			aView[Len(aView)][4] := TransForm(nValor,"@E 999,999,999,999.99")
			
			
		Next
EndCase

oView   := TWBrowse():New( 2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,{STR0001,STR0023+cSimbolo,STR0056+cSimbolo,STR0024+cSimbolo},{90,70,70,70},oFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,) //######### //"Custo Trabalhado  "
oView:SetArray(aView)
oView:bLine := { || aView[oView:nAT]}

Aadd(aView2,{STR0001,STR0023+cSimbolo,STR0056+cSimbolo,STR0024+cSimbolo}) //###
For nx := 1 to Len(aView)
	Aadd( aView2, aClone(aView[nx]) )
Next

aAdd(aButtons,{"BMPPOST",{||oFolder:SetOption(2), PmsGrafMail(oGraphic,STR0027,{STR0028+cTexto },aView2) },STR0029,STR0178 })//"Progresso Financeiro Previsto x Realizado"###"Progresso Financeiro : "###"Enviar por E-Mail" ### "E-Mail"
aAdd(aButtons,{BMP_IMPRIMIR,{||oGraphic:SaveToImage(criatrab(,.F.)+".bmp","\temp\"),CtbGrafPrint(oGraphic,STR0186,{STR0187+cTexto },aView2,,{ 360, 700, 1200, 1700, 2300},{ 160 ,2950 ,((oGraphic:nBottom - oGraphic:nTop) * 3) + 425} ) }, STR0030 ,STR0179 })//"Impressao do grafico"### "Imprimir" 

If lPMC100EV //Progresso Financeiro
	aRetButt := ExecBlock("PMC100EV",.F.,.F.)
	If ValType(aRetButt) == "A" .And. Len(aRetButt) > 0 //Preservo os botões originais
		For nX := 1 To Len(aRetButt)
			aAdd(aButtons,aRetButt[nX])
		Next nX
	EndIf
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End() },{||oDlg:End()},,aButtons)
PmsSetFrt("") //Limpa o filtro da Frente
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsCfgEV ³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe uma tela com as configuracoes de visualizacao do Gantt  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsCfgEv(oDlg,oTree,aParametros,cArquivo)
Local aTpGrafico:= {STR0088,; //"1=Linha"
					STR0089,; //"2=Area"
					STR0090,; //"3=Pontos"
					STR0091,; //"4=Barra"
					STR0099 } //"5=Linha Rapida"
Local nMoedas	:= MoedFin()
Local nx
Local aMoedas	:= {}
Local lContinua := .T.
Local aPergs	:=	{}         
Local cFrente := "               "
DEFAULT aParametros := {30,"1",AF8->AF8_START,dDataBase,1,""}

For nX := 1 to nMoedas
	aAdd(aMoedas,GetMV("MV_SIMB"+AllTrim(Str(nX,2,0))))
Next nX

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
EndIf

If cAlias == "AFC" .Or. cAlias == "AF8"
	aPergs	:={	{1,STR0031,aParametros[1],"@E 99","Positivo(mv_par01)",,".T.",40,.T.},; //
		{2,STR0032,aParametros[2],aTpGrafico,80,"",.F.},;  //"Tipo do Grafico"
		{1,STR0033,aParametros[3],"","",,"",50,.T.},; //
		{1,STR0034,aParametros[4],"","",,"",50,.T.},;
		{3,STR0002,aParametros[5],aMoedas,50,"",.F.},; //"Visualizar valores em	
		{7,"Filtrar tarefas ","AF9",""}; //"Filtro "
		}
Else
	aPergs	:={	{1,STR0031,aParametros[1],"@E 99","Positivo(mv_par01)",,".T.",40,.T.},; //
		{2,STR0032,aParametros[2],aTpGrafico,80,"",.F.},;  //"Tipo do Grafico"
		{1,STR0033,aParametros[3],"","",,"",50,.T.},; //
		{1,STR0034,aParametros[4],"","",,"",50,.T.},;
		{3,STR0002,aParametros[5],aMoedas,50,"",.F.}; //"Visualizar valores em	
		}
Endif
If GetNewPar('MV_PMSCCT','1') == '2'
	aAdd(aPergs,{1,"Frente ",cFrente,"@!","Vazio() .Or. ExistCpo('LJM')","LJM",".T.",50,.F.})//Altera pelo Template de CCT
Endif
While lContinua 
	If ParamBox(aPergs,STR0003,@aParametros) //###
		If oDlg <> Nil
			oDlg:End()
		EndIf
		
		If aParametros[4] > aParametros[3] 
			PMSC100EV(oTree,@aParametros,cArquivo)
			lContinua := .F.
		Else
			Alert(STR0180)
		Endif
	Else
		lContinua := .F.
	EndIf	
End

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C100FLC   ³ Autor ³Fabio Rogerio Pereira  ³ Data ³ 07/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta uma consulta do fluxo de caixa               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC100                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C100FLC(cAlias,nRecView,aParametros,aParFLC)
Local oDlg
Local oGraphic
Local oView
Local oBmp
Local oBmp1
Local nStep 	:= 0
Local nSerie	:= 0
Local nSerie2	:= 0
Local nSerie3	:= 0
Local nData     := 0
Local nRecAcum  := 0
Local nDespAcum := 0
Local nValor    := 0
Local aArea		:= GetArea()
Local cTexto	:= ""
Local cProjeto  := ""
Local cRevisa   := ""
Local cEDT      := ""
Local cTarefa   := ""
Local cPict		:= PesqPict("AFT","AFT_VALOR1")
Local aValor    := {}
Local aView     := {}
Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aTpGrafico:= { {"1" , 1}; //"1=Linha"
					,{"2" , 2}; //"2=Area"
					,{"3" , 3}; //"3=Pontos"
					,{"4" , 4}; //"4=Barra"
					,{"5" ,12}} //"5=Linha Rapida"
Local nPosTpGraf := 0
local nTipoGraf  := 0

DEFAULT aParametros := {30,"1","1"}

nPosTpGraf := aScan(aTpGrafico ,{|aItem| aItem[1]==aParametros[2] })
If nPosTpGraf > 0
	nTipoGraf := aTpGrafico[nPosTpGraf][2]
Else
	nTipoGraf := 1
EndIf

For nData:= aParFLC[1] To (aParFLC[1] + aParFLC[3])
	Aadd(aValor,{nData,0,0,0,0,0,0,0,0})
Next nData

// carrega as variaveis de memoria
(cAlias)->(dbGoto(nRecView))
RegToMemory(cAlias,.F.)

Do Case
	Case cAlias=="AF8"
		cProjeto:= AF8->AF8_PROJET
		cRevisa := AF8->AF8_REVISA
		cEDT    := Posicione("AFC",1,xFilial("AFC")+cProjeto+cRevisa,"AFC_EDT")
		cTarefa := ""
		cTexto	:= STR0020 + cProjeto + STR0071 + cRevisa//"Projeto:  Revisao: "
		
	Case cAlias=="AF9"
		cProjeto:= AF9->AF9_PROJET
		cRevisa := AF9->AF9_REVISA
		cTarefa := AF9->AF9_TAREFA
		cTexto	:= STR0020 + cProjeto + STR0071 + cRevisa + STR0021 + cTarefa + "-" + AF9->AF9_DESCRI //" Revisao: "
		
	Case cAlias=="AFC"
		cProjeto:= AFC->AFC_PROJET
		cRevisa := AFC->AFC_REVISA
		cEDT    := AFC->AFC_EDT
		cTexto	:= STR0020 + cProjeto + STR0071 + cRevisa + STR0022 + cEDT + "-" + AFC->AFC_DESCRI
		
EndCase

// calcula o valor dos titulos da EDT/Tarefa
PmsAFTCalc( aParFLC[1],aParFLC[1]+aParFLC[3],cProjeto,cRevisa,cEDT,cTarefa,aParFLC[2],@aValor)

// calcula o valor das notas da EDT/Tarefa
PmsAFSCalc( aParFLC[1],aParFLC[1]+aParFLC[3],cProjeto,cRevisa,cEDT,cTarefa,aParFLC[2],@aValor)

// calcula o valor dos Ped.Venda da EDT/Tarefa
If (aParFLC[5] == 1)
	PmsSC6Calc(aParFLC[1],aParFLC[1]+aParFLC[3],cProjeto,cRevisa,cEDT,cTarefa,aParFLC[2],@aValor)
EndIf

// calcula o valor dos movimentos bancarios da EDT/Tarefa
PmsSE5Calc( aParFLC[1],aParFLC[1]+aParFLC[3],cProjeto,cRevisa,cEDT,cTarefa,aParFLC[2],@aValor,"R")

// calcula o valor das despesas da EDT/Tarefa
PmsAFRCalc(aParFLC[1],aParFLC[1]+aParFLC[3],cProjeto,cRevisa,cEDT,cTarefa,aParFLC[2],@aValor)

// calcula o valor das notas de entrada da EDT/Tarefa
PmsAFNCalc(aParFLC[1],aParFLC[1]+aParFLC[3],cProjeto,cRevisa,cEDT,cTarefa,aParFLC[2],@aValor)

// calcula o valor dos Ped.Compra daEDT/Tarefa
If (aParFLC[4] == 1)
	PmsAFGCalc(aParFLC[1],aParFLC[1]+aParFLC[3],cProjeto,cRevisa,cEDT,cTarefa,aParFLC[2],@aValor)
EndIf

// calcula o valor dos movimentos bancarios da EDT/Tarefa
If PmsSE5()
	PmsSE5Calc( aParFLC[1],aParFLC[1]+aParFLC[3],cProjeto,cRevisa,cEDT,cTarefa,aParFLC[2],@aValor,"P")
EndIf

For nData:= 1 To Len(aValor)
	nRecAcum += aValor[nData,2]
	nDespAcum+= aValor[nData,3]
	
	aValor[nData,4]:= aValor[nData,2] - aValor[nData,3]
	aValor[nData,5]:= (aValor[nData,4]/Max(aValor[nData,2],aValor[nData,3])) * 100
	aValor[nData,6]:= nRecAcum
	aValor[nData,7]:= nDespAcum
	aValor[nData,8]:= nRecAcum - nDespAcum
	aValor[nData,9]:= (aValor[nData,8]/Max(nDespAcum,nRecAcum)) * 100
	
	Aadd(aView,{ aValor[nData,1],;
	Transform(aValor[nData,2],cPict),;
	Transform(aValor[nData,3],cPict),;
	Transform(aValor[nData,4],cPict),;
	Transform(aValor[nData,5],"9999.99%"),;
	Transform(aValor[nData,6],cPict),;
	Transform(aValor[nData,7],cPict),;
	Transform(aValor[nData,8],cPict),;
	Transform(aValor[nData,9],"9999.99%")})
Next

If (Len(aView) == 0)
	aView := {{"  /  /  ",Transform(0,cPict),Transform(0,cPict),Transform(0,cPict),Transform(0,cPict),Transform(0,cPict),Transform(0,cPict),Transform(0,cPict),Transform(0,cPict)}}
EndIf

aAdd( aObjects, { 100, 40, .T., .T., .F. } )
aAdd( aObjects, { 100, 60, .T., .T., .T. } )
aSize  := MsAdvSize(.T.)
aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
aPosObj:= MsObjSize( aInfo, aObjects, .T.,.F. )

DEFINE MSDIALOG oDlg TITLE cCadastro + cTexto FROM aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

oEnch := MsMGet():New(cAlias,(cAlias)->(RecNo()),2,,,,,aPosObj[1],,3,,,,oDlg)

@ aPosObj[2,1],aPosObj[2,2] FOLDER oFolder SIZE aPosObj[2,3],aPosObj[2,4] OF oDlg PROMPTS STR0018,STR0019 PIXEL

// exibe a planilha com os valores do fluxo de caixa
oView:= TWBrowse():New( 1,1,aPosObj[2,3]-5,aPosObj[2,4]-15,,{STR0001,STR0072,STR0073,STR0074,STR0075,STR0076,STR0077,STR0078,STR0079},{50,90,90,90,90,90,90,90,90},; //"Receita"###"Despesa"###"Saldo do Dia"###"Var. Dia"###"Rec.Acumulada"###"Desp.Acumulada"###"Saldo Acumulado"###"Var.Acumulado"
oFolder:aDialogs[1],,,,,{||PmsC100Detail(aView[oView:nAT][1],cProjeto,cRevisa,cEDT,cTarefa,IIf(cAlias == "AF9",1,2))},,,,,,STR0080,.F.,,.T.,,.F.,,,) //"Duplo click para visualizar os detalhes"
oView:SetArray(aView)
oView:bLine:= {|| {aView[oView:nAT,1], aView[oView:nAt,2],aView[oView:nAt,3],aView[oView:nAt,4],aView[oView:nAt,5],;
aView[oView:nAt,6],aView[oView:nAt,7],aView[oView:nAt,8],aView[oView:nAt,9]}}

@ 01,01 MSGRAPHIC oGraphic SIZE aPosObj[2,3]-5,aPosObj[2,4]-40 OF oFolder:aDialogs[2]

oGraphic:SetMargins( 0, 10, 10,10 )
oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
oGraphic:SetTitle( "" , "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
oGraphic:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .F. )
nSerie  := oGraphic:CreateSerie( nTipoGraf )
nSerie2 := oGraphic:CreateSerie( nTipoGraf )
nSerie3 := oGraphic:CreateSerie( nTipoGraf )

nStep   := INT(aParFLC[3]/aParametros[1])
nStep	:= If(nStep<=0,1,nStep)

ProcRegua((aParFLC[3]/nStep)*2)

For nData:= 1 To Len(aValor)
	IncProc()
	
	// verifica se exibe Receita/Despesa ou o Saldo Acunulado
	If (aParametros[3] == "1")
		@ aPosObj[2,4]-35, 10 BITMAP oBmp RESNAME BMP_AZUL SIZE 16,16 NOBORDER PIXEL OF oFolder:aDialogs[2]
		@ aPosObj[2,4]-35, 20 SAY OemtoAnsi(STR0081) OF oFolder:aDialogs[2] PIXEL //"Receitas"
		
		@ aPosObj[2,4]-25, 10 BITMAP oBmp1 RESNAME BMP_VERMELHO SIZE 16,16 NOBORDER PIXEL OF oFolder:aDialogs[2]
		@ aPosObj[2,4]-25, 20 SAY OemToAnsi(STR0082) OF oFolder:aDialogs[2] PIXEL //"Despesas"
		
		@ aPosObj[2,4]-35, 50 BITMAP oBmp RESNAME BMP_VERDE SIZE 16,16 NOBORDER PIXEL OF oFolder:aDialogs[2]
		@ aPosObj[2,4]-35, 60 SAY OemToAnsi(STR0083) OF oFolder:aDialogs[2] PIXEL  //"Saldo"
		
		//Pega o valor da receita/ou acumulado no dia
		nValor:= aValor[nData,2]
		oGraphic:Add(nSerie,nValor,DTOC(aValor[nData,1]),CLR_HBLUE)
		
		//Pega o valor da despesa no dia
		nValor:= aValor[nData,3]
		oGraphic:Add(nSerie2,nValor,DTOC(aValor[nData,1]),CLR_HRED)
		
		//Pega o valor do saldo acumulado
		nValor:= aValor[nData,8]
		oGraphic:Add(nSerie3,nValor,DTOC(aValor[nData,1]),CLR_HGREEN)
	Else
		@ aPosObj[2,4]-35, 10 BITMAP oBmp RESNAME BMP_VERDE SIZE 16,16 NOBORDER PIXEL OF oFolder:aDialogs[2]
		@ aPosObj[2,4]-35, 20 SAY OemToAnsi(STR0083) OF oFolder:aDialogs[2] PIXEL  //"Saldo"
		
		//Pega o valor do saldo acumulado
		nValor:= aValor[nData,8]
		oGraphic:Add(nSerie,nValor,DTOC(aValor[nData,1]),CLR_HGREEN)
	EndIf
Next nData

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End() },{||oDlg:End()},,{{"BMPPOST",{||PmsGrafMail(oGraphic,STR0084,{STR0085+cTexto },aView) },STR0029},; //"Fluxo de Caixa do Projeto"###"Fluxo de Caixa : "
{"GERPROJ",{||C100FLCGraf(@oDlg,cAlias,nRecView,@aParametros,aParFLC)},STR0003}})

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C100FLCGraf   ³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 07/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe uma tela com as configuracoes de visualizacao do Grafico 	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico             		                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C100FLCGraf(oDlg,cAlias,nRecView,aParametros,aParFLC)
Local aTpVisual := {STR0086,; //"1=Receita X Despesa"
					STR0087} //"2=Projecao de Saldo"
Local aTpGrafico:= {STR0088,; //"1=Linha"
					STR0089,; //"2=Area"
					STR0090,; //"3=Pontos"
					STR0091,; //"4=Barra"
					STR0099 } //"5=Linha Rapida"
				
If ParamBox({	{1,STR0031,aParametros[1],"@E 99","Positivo(mv_par01)",,".T.",40,.T.},;
	{2,STR0032,aParametros[2],aTpGrafico,80,"",.F.},;
	{2,STR0103,aParametros[3],aTPVisual ,80,"",.F.}},STR0003,@aParametros) //"Tipo de Visualizacao"
	oDlg:End()
	C100FLC(cAlias,nRecView,@aParametros,aParFLC)
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAFTCalc³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 07/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o valor dos titulos da EDT/Tarefa                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsAFTCalc(dDtIni,dDtFim,cProjeto,cRevisa,cEDT,cTarefa,nMoeda,aValor)
Local nPosVenc  := 0
Local aArea	    := GetArea()
Local aAreaAFC  := AFC->(GetArea())
Local aAreaAF9  := AF9->(GetArea())
DEFAULT dDtIni  := dDatabase
DEFAULT dDtFim  := dDatabase
DEFAULT cEDT    := ""
DEFAULT cTarefa := ""
DEFAULT cProjeto:= ""
DEFAULT cRevisa := ""

// pesquisa todos os titulos das tarefas da EDT
If !Empty(cEDT)
	dbSelectArea("AFT")
	dbSetOrder(4)
	dbSeek(xFilial("AFT") + cProjeto + cRevisa + cEDT)
	
	While !Eof() .And. (AFT->AFT_FILIAL+AFT->AFT_PROJET+AFT->AFT_REVISA+AFT->AFT_EDT == ;
		xFilial("AFT")+cProjeto+cRevisa+cEDT)
		
		// valida o periodo do titulo
		If (AFT->AFT_VENREA >= dDtIni) .And. (AFT->AFT_VENREA <= dDtFim)
			nPosVenc := aScan(aValor,{|x| x[1] == AFT->AFT_VENREA})
			If nPosVenc > 0
				aValor[nPosVenc][2] += xMoeda(AFT->AFT_VALOR1,1,nMoeda,AFT->AFT_VENREA)
			Else
				aAdd(aValor,{AFT->AFT_VENREA,xMoeda(AFT->AFT_VALOR1,1,nMoeda,AFT->AFT_VENREA),0,0,0,0,0,0,0})
			EndIf
		EndIf
		
		dbSelectArea("AFT")
		dbSkip()
	End
	
	dbSelectArea("AF9")
	dbSetOrder(2)
	dbSeek(xFilial("AF9") + cProjeto + cRevisa + cEDT,.T.)
	While !Eof() .And. (AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI == ;
		xFilial("AF9") + cProjeto + cRevisa + cEDT)
		
		dbSelectArea("AFT")
		dbSetOrder(1)
		dbSeek(xFilial("AFT") + cProjeto + cRevisa + AF9->AF9_TAREFA)
		
		While !Eof() .And. (AFT->AFT_FILIAL+AFT->AFT_PROJET+AFT->AFT_REVISA+AFT->AFT_TAREFA == ;
			xFilial("AFT")+cProjeto+cRevisa+AF9->AF9_TAREFA)
			
			// valida o periodo do titulo
			If (AFT->AFT_VENREA >= dDtIni) .And. (AFT->AFT_VENREA <= dDtFim)
				nPosVenc := aScan(aValor,{|x| x[1] == AFT->AFT_VENREA})
				If nPosVenc > 0
					aValor[nPosVenc][2] += xMoeda(AFT->AFT_VALOR1,1,nMoeda,AFT->AFT_VENREA)
				Else
					aAdd(aValor,{AFT->AFT_VENREA,xMoeda(AFT->AFT_VALOR1,1,nMoeda,AFT->AFT_VENREA),0,0,0,0,0,0,0})
				EndIf
			EndIf
			
			dbSelectArea("AFT")
			dbSkip()
		End
		
		dbSelectArea("AF9")
		dbSkip()
	End
	
	// calcula as EDT`s filhas se existir
	dbSelectArea("AFC")
	dbSetOrder(2)
	dbSeek(xFilial("AFC") + cProjeto + cRevisa + cEDT)
	While !Eof() .And. (xFilial("AFC") + cProjeto + cRevisa + cEDT ==;
		AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI)
		
		PmsAFTCalc(dDtIni,dDtFim,cProjeto,cRevisa,AFC->AFC_EDT,cTarefa,nMoeda,@aValor)
		dbSelectArea("AFC")
		dbSkip()
	End
	
ElseIf !Empty(cTarefa)
	dbSelectArea("AFT")
	dbSetOrder(1)
	dbSeek(xFilial("AFT") + cProjeto + cRevisa + cTarefa)
	
	While !Eof() .And. (AFT->AFT_FILIAL+AFT->AFT_PROJET+AFT->AFT_REVISA+AFT->AFT_TAREFA == ;
		xFilial("AFT")+cProjeto+cRevisa+cTarefa)
		
		// valida o periodo do titulo
		If (AFT->AFT_VENREA >= dDtIni) .And. (AFT->AFT_VENREA <= dDtFim)
			nPosVenc := aScan(aValor,{|x| x[1] == AFT->AFT_VENREA})
			If nPosVenc > 0
				aValor[nPosVenc][2] += xMoeda(AFT->AFT_VALOR1,1,nMoeda,AFT->AFT_VENREA)
			Else
				aAdd(aValor,{AFT->AFT_VENREA,xMoeda(AFT->AFT_VALOR1,1,nMoeda,AFT->AFT_VENREA),0,0,0,0,0,0,0})
			EndIf
		EndIf
		
		dbSelectArea("AFT")
		dbSkip()
	End
EndIf

aValor:= ASORT(aValor,,, { |x, y| x[1] < y[1] })

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAFRCalc³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 10/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o valor das despesas da EDT/Tarefa                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsAFRCalc(dDtIni,dDtFim,cProjeto,cRevisa,cEDT,cTarefa,nMoeda,aValor)
Local nPosVenc  := 0
Local aArea	    := GetArea()
Local aAreaAFC  := AFC->(GetArea())
Local aAreaAF9  := AF9->(GetArea())

DEFAULT dDtIni  := dDatabase
DEFAULT dDtFim  := dDatabase
DEFAULT cEDT    := ""
DEFAULT cTarefa := ""
DEFAULT cProjeto:= ""
DEFAULT cRevisa := ""

// pesquisa todas as despesas das tarefas da EDT
If !Empty(cEDT)
	dbSelectArea("AF9")
	dbSetOrder(2)
	dbSeek(xFilial("AF9") + cProjeto + cRevisa + cEDT,.T.)
	While !Eof() .And. (AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI == ;
		xFilial("AF9") + cProjeto + cRevisa + cEDT)
		
		dbSelectArea("AFR")
		dbSetOrder(1)
		dbSeek(xFilial("AFR") + cProjeto + cRevisa + AF9->AF9_TAREFA)
		
		While !Eof() .And. (AFR->AFR_FILIAL+AFR->AFR_PROJET+AFR->AFR_REVISA+AFR->AFR_TAREFA == ;
			xFilial("AFR")+cProjeto+cRevisa+AF9->AF9_TAREFA)
			
			// valida o periodo do titulo
			If (AFR->AFR_VENREA >= dDtIni) .And. (AFR->AFR_VENREA <= dDtFim)
				nPosVenc := aScan(aValor,{|x| x[1] == AFR->AFR_VENREA})
				If nPosVenc > 0
					aValor[nPosVenc][3] += xMoeda(AFR->AFR_VALOR1,1,nMoeda,AFR->AFR_VENREA)
				Else
					aAdd(aValor,{AFR->AFR_VENREA,0,xMoeda(AFR->AFR_VALOR1,1,nMoeda,AFR->AFR_VENREA),0,0,0,0,0,0})
				EndIf
			EndIf
			
			dbSelectArea("AFR")
			dbSkip()
		End
		
		dbSelectArea("AF9")
		dbSkip()
	End
	
	// calcula as EDT`s filhas se existir
	dbSelectArea("AFC")
	dbSetOrder(2)
	dbSeek(xFilial("AFC") + cProjeto + cRevisa + cEDT)
	While !Eof() .And. (xFilial("AFC") + cProjeto + cRevisa + cEDT ==;
		AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI)
		PmsAFRCalc(dDtIni,dDtFim,cProjeto,cRevisa,AFC->AFC_EDT,cTarefa,nMoeda,@aValor)
		dbSelectArea("AFC")
		dbSkip()
	End
	
ElseIf !Empty(cTarefa)
	dbSelectArea("AFR")
	dbSetOrder(1)
	dbSeek(xFilial("AFR") + cProjeto + cRevisa + cTarefa)
	
	While !Eof() .And. (AFR->AFR_FILIAL+AFR->AFR_PROJET+AFR->AFR_REVISA+AFR->AFR_TAREFA == ;
		xFilial("AFR")+cProjeto+cRevisa+cTarefa)
		
		// valida o periodo da despesas
		If (AFR->AFR_VENREA >= dDtIni) .And. (AFR->AFR_VENREA <= dDtFim)
			nPosVenc := aScan(aValor,{|x| x[1] == AFR->AFR_VENREA})
			If nPosVenc > 0
				aValor[nPosVenc][3] += xMoeda(AFR->AFR_VALOR1,1,nMoeda,AFR->AFR_VENREA)
			Else
				aAdd(aValor,{AFR->AFR_VENREA,0,xMoeda(AFR->AFR_VALOR1,1,nMoeda,AFR->AFR_VENREA),0,0,0,0,0,0})
			EndIf
		EndIf
		
		dbSelectArea("AFR")
		dbSkip()
	End
EndIf

aValor:= ASORT(aValor,,, { |x, y| x[1] < y[1] })

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsSC6Calc³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 10/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o valor dos pedidos de venda da EDT/Tarefa             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsSC6Calc(dDtIni,dDtFim,cProjeto,cRevisa,cEDT,cTarefa,nMoeda,aValor)
Local nPosVenc  := 0
Local nParcela  := 0
Local aArea	    := GetArea()
Local aAreaAFC  := AFC->(GetArea())
Local aAreaAF9  := AF9->(GetArea())
Local aParcelas := {}

DEFAULT dDtIni  := dDatabase
DEFAULT dDtFim  := dDatabase
DEFAULT cEDT    := ""
DEFAULT cTarefa := ""
DEFAULT cProjeto:= ""
DEFAULT cRevisa := ""

// pesquisa todos os Pde.Venda da EDT
If !Empty(cEDT)
	dbSelectArea("AF9")
	dbSetOrder(2)
	dbSeek(xFilial("AF9") + cProjeto + cRevisa + cEDT,.T.)
	While !Eof() .And. (AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI == ;
		xFilial("AF9") + cProjeto + cRevisa + cEDT)
		
		dbSelectArea("SC6")
		dbSetOrder(8)
		dbSeek(xFilial("SC6") + cProjeto + AF9->AF9_TAREFA)
		
		While !Eof() .And. (SC6->C6_FILIAL+SC6->C6_PROJPMS+SC6->C6_TASKPMS == ;
			xFilial("SC6")+cProjeto+AF9->AF9_TAREFA)
			
			// somente verifica os itens cuja TES gera duplicata
			If Empty(SC6->C6_NOTA + SerieNfId("SC6",2,"C6_SERIE"))
				
				SF4->(dbSetOrder(1))
				SF4->(dbSeek(xFilial("SF4") + SC6->C6_TES))
				
				If (SF4->F4_DUPLIC == "S") .And. (SF4->F4_MOVPRJ $ "15")
					SC5->(dbSetOrder(1))
					SC5->(dbSeek(xFilial("SC5") + SC6->C6_NUM))
					
					// valida a condicao de pagamento
					aParcelas:= Condicao(SC6->C6_VALOR,SC5->C5_CONDPAG,,SC5->C5_EMISSAO)
					
					For nParcela:= 1 To Len(aParcelas)
						If (aParcelas[nParcela][1] >= dDtIni) .And. (aParcelas[nParcela][1] <= dDtFim)
							nPosVenc := aScan(aValor,{|x| x[1] == aParcelas[nParcela][1]})
							If (nPosVenc > 0)
								aValor[nPosVenc][2] += xMoeda(aParcelas[nParcela][2],1,nMoeda,aParcelas[nParcela][1])
							Else
								aAdd(aValor,{aParcelas[nParcela][1],xMoeda(aParcelas[nParcela][2],1,nMoeda,aParcelas[nParcela][1]),0,0,0,0,0,0,0})
							EndIf
						EndIf
					Next
				EndIf
			EndIf
			
			dbSelectArea("SC6")
			dbSkip()
		End
		
		dbSelectArea("AF9")
		dbSkip()
	End
	
	// calcula as EDT`s filhas se existir
	dbSelectArea("AFC")
	dbSetOrder(2)
	dbSeek(xFilial("AFC") + cProjeto + cRevisa + cEDT)
	While !Eof() .And. (xFilial("AFC") + cProjeto + cRevisa + cEDT ==;
		AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI)
		PmsSC6Calc(dDtIni,dDtFim,cProjeto,cRevisa,AFC->AFC_EDT,cTarefa,nMoeda,@aValor)
		dbSelectArea("AFC")
		dbSkip()
	End
	
ElseIf !Empty(cTarefa)
	dbSelectArea("SC6")
	dbSetOrder(8)
	dbSeek(xFilial("SC6") + cProjeto + cTarefa)
	
	While !Eof() .And. (SC6->C6_FILIAL+SC6->C6_PROJPMS+SC6->C6_TASKPMS == ;
		xFilial("SC6")+cProjeto+cTarefa)
		
 		// somente verifica os itens cuja TES gera duplicata
		If Empty(SC6->C6_NOTA + SerieNfId("SC6",2,"C6_SERIE"))
			
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4") + SC6->C6_TES))
			
			If (SF4->F4_DUPLIC == "S") .And. (SF4->F4_MOVPRJ $ "15")
				SC5->(dbSetOrder(1))
				SC5->(dbSeek(xFilial("SC5") + SC6->C6_NUM))
				
				// valida a condicao de pagamento
				aParcelas:= Condicao(SC6->C6_VALOR,SC5->C5_CONDPAG,,SC5->C5_EMISSAO)
				
				For nParcela:= 1 To Len(aParcelas)
					If (aParcelas[nParcela][1] >= dDtIni) .And. (aParcelas[nParcela][1] <= dDtFim)
						nPosVenc := aScan(aValor,{|x| x[1] == aParcelas[nParcela][1]})
						If nPosVenc > 0
							aValor[nPosVenc][2] += xMoeda(aParcelas[nParcela][2],1,nMoeda,aParcelas[nParcela][1])
						Else
							aAdd(aValor,{aParcelas[nParcela][1],xMoeda(aParcelas[nParcela][2],1,nMoeda,aParcelas[nParcela][1]),0,0,0,0,0,0,0})
						EndIf
					EndIf
				Next
			EndIf
		EndIf
		
		dbSelectArea("SC6")
		dbSkip()
	End
EndIf

aValor:= ASORT(aValor,,, { |x, y| x[1] < y[1] })

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAFGCalc³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 10/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o valor dos pedidos de compra da EDT/Tarefa            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsAFGCalc(dDtIni,dDtFim,cProjeto,cRevisa,cEDT,cTarefa,nMoeda,aValor)
Local nPosVenc  := 0
Local nParcela  := 0
Local aArea	    := GetArea()
Local aAreaAFC  := AFC->(GetArea())
Local aAreaAF9  := AF9->(GetArea())
Local aParcelas := {}

DEFAULT dDtIni  := dDatabase
DEFAULT dDtFim  := dDatabase
DEFAULT cEDT    := ""
DEFAULT cTarefa := ""
DEFAULT cProjeto:= ""
DEFAULT cRevisa := ""

// pesquisa todos os Pde.Venda da EDT
If !Empty(cEDT)
	dbSelectArea("AF9")
	dbSetOrder(2)
	dbSeek(xFilial("AF9") + cProjeto + cRevisa + cEDT,.T.)
	While !Eof() .And. (AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI == ;
		xFilial("AF9") + cProjeto + cRevisa + cEDT)
		
		dbSelectArea("AFG")
		dbSetOrder(1)
		dbSeek(xFilial("AFG") + cProjeto + cRevisa + AF9->AF9_TAREFA)
		
		While !Eof() .And. (AFG->AFG_FILIAL+AFG->AFG_PROJET+AFG->AFG_REVISA+AFG->AFG_TAREFA == ;
			xFilial("AFG")+cProjeto+cRevisa+AF9->AF9_TAREFA)
			
			SC1->(dbSetOrder(1))
			SC1->(dbSeek(xFilial("SC1") + AFG->AFG_NUMSC + AFG->AFG_ITEMSC))
			
			If !Empty(SC1->C1_PEDIDO)
				
				// pesquisa os pedidos da solicitacao de compras
				dbSelectArea("SC7")
				dbSetOrder(1)
				dbSeek(xFilial("SC7") + SC1->C1_PEDIDO + SC1->C1_ITEMPED)
				
				While !Eof() .And. (xFilial("SC7") == SC7->C7_FILIAL) .And. (SC1->C1_PEDIDO == SC7->C7_NUM) .And.;
					(SC1->C1_ITEMPED == SC7->C7_ITEM)
					
					// somente utiliza os pedidos não baixados
					If (AFG->AFG_QUANT > SC7->C7_QUJE)
						
						// somente verifica os itens cuja TES gera duplicata
						SF4->(dbSetOrder(1))
						SF4->(dbSeek(xFilial("SF4") + SC7->C7_TES))
						
						If (SF4->F4_DUPLIC == "S") .Or. Empty(SC7->C7_TES)
							
							// valida a condicao de pagamento
							aParcelas:= Condicao((SC7->C7_PRECO * IIf(AFG->AFG_QUANT > SC7->C7_QUJE,AFG->AFG_QUANT - SC7->C7_QUJE,0)),SC7->C7_COND,,SC7->C7_EMISSAO)
							
							For nParcela:= 1 To Len(aParcelas)
								If (aParcelas[nParcela][1] >= dDtIni) .And. (aParcelas[nParcela][1] <= dDtFim)
									
									nPosVenc := aScan(aValor,{|x| x[1] == aParcelas[nParcela][1]})
									If nPosVenc > 0
										aValor[nPosVenc][3] += xMoeda(aParcelas[nParcela][2],1,nMoeda,aParcelas[nParcela][1])
									Else
										aAdd(aValor,{aParcelas[nParcela][1],0,xMoeda(aParcelas[nParcela][2],1,nMoeda,aParcelas[nParcela][1]),0,0,0,0,0,0})
									EndIf
								EndIf
							Next
						EndIf
					EndIf
					
					dbSelectArea("SC7")
					dbSkip()
				End
				
			EndIf
			
			dbSelectArea("AFG")
			dbSkip()
		End
		
		dbSelectArea("AF9")
		dbSkip()
	End
	
	// calcula as EDT`s filhas se existir
	dbSelectArea("AFC")
	dbSetOrder(2)
	dbSeek(xFilial("AFC") + cProjeto + cRevisa + cEDT)
	While !Eof() .And. (xFilial("AFC") + cProjeto + cRevisa + cEDT ==;
		AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI)
		PmsAFGCalc(dDtIni,dDtFim,cProjeto,cRevisa,AFC->AFC_EDT,cTarefa,nMoeda,@aValor)
		dbSelectArea("AFC")
		dbSkip()
	End
	
ElseIf !Empty(cTarefa)
	dbSelectArea("AFG")
	dbSetOrder(1)
	dbSeek(xFilial("AFG") + cProjeto + cRevisa + cTarefa)
	
	While !Eof() .And. (AFG->AFG_FILIAL+AFG->AFG_PROJET+AFG->AFG_REVISA+AFG->AFG_TAREFA == ;
		xFilial("AFG")+cProjeto+cRevisa+cTarefa)
		
		SC1->(dbSetOrder(1))
		SC1->(dbSeek(xFilial("SC1") + AFG->AFG_NUMSC + AFG->AFG_ITEMSC))
		
		If !Empty(SC1->C1_PEDIDO)
			
			// pesquisa os pedidos da solicitacao de compras
			dbSelectArea("SC7")
			dbSetOrder(1)
			dbSeek(xFilial("SC7") + SC1->C1_PEDIDO + SC1->C1_ITEMPED)
			
			While !Eof() .And. (xFilial("SC7") == SC7->C7_FILIAL) .And. (SC1->C1_PEDIDO == SC7->C7_NUM) .And.;
				(SC1->C1_ITEMPED == SC7->C7_ITEM)
				
				// somente utiliza os pedidos não baixados
				If (AFG->AFG_QUANT > SC7->C7_QUJE)
					
					// somente verifica os itens cuja TES gera duplicata
					SF4->(dbSetOrder(1))
					SF4->(dbSeek(xFilial("SF4") + SC7->C7_TES))
					
					If (SF4->F4_DUPLIC == "S") .Or. Empty(SC7->C7_TES)
						
						// valida a condicao de pagamento
						aParcelas:= Condicao((SC7->C7_PRECO * IIf(AFG->AFG_QUANT > SC7->C7_QUJE,AFG->AFG_QUANT - SC7->C7_QUJE,0)),SC7->C7_COND,,SC7->C7_EMISSAO)
						
						For nParcela:= 1 To Len(aParcelas)
							If (aParcelas[nParcela][1] >= dDtIni) .And. (aParcelas[nParcela][1] <= dDtFim)
								nPosVenc := aScan(aValor,{|x| x[1] == aParcelas[nParcela][1]})
								If nPosVenc > 0
									aValor[3] += xMoeda(aParcelas[nParcela][2],1,nMoeda,aParcelas[nParcela][1])
								Else
									aAdd(aValor,{aParcelas[nParcela][1],0,xMoeda(aParcelas[nParcela][2],1,nMoeda,aParcelas[nParcela][1]),0,0,0,0,0,0})
								EndIf
							EndIf
						Next
					EndIf
				EndIf
				
				dbSelectArea("SC7")
				dbSkip()
			End
			
		EndIf
		
		dbSelectArea("AFG")
		dbSkip()
	End
EndIf

aValor:= ASORT(aValor,,, { |x, y| x[1] < y[1] })

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsC100Detail³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 11/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe os dados de Ped.Venda,Ped.Compra,Titulos e Despesas da data ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsC100Detail(dData,cProjeto,cRevisa,cEDT,cTarefa,nOpcao)
Local oFolder
Local oDlg
Local oGetAFT
Local oGetSC5
Local oGetAFR
Local oGetAFG
Local aSize    := {}
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}
Local aSvFolder:= {}

//	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//	³ Matriz aSvFolder 					³
//	³									³
//	³- Titulo		        			³
//	³ [1][1] SX3 do AFT 	 			³
//	³ [1][2] Dados do AFT	 			³
//	³ [1][3] Titulos Campos				³
//	³									³
//	³- Ped.Venda	           			³
//	³ [2][1] SX3 do AFT 	 			³
//	³ [2][2] Dados do AFT	 			³
//	³ [2][3] Titulos Campos				³
//	³									³
//	³- Despesas		           			³
//	³ [3][1] SX3 do AFT 	 			³
//	³ [3][2] Dados do AFT	 			³
//	³ [3][3] Titulos Campos				³
//	³									³
//	³- Ped. Compra	           			³
//	³ [4][1] SX3 do AFT 	 			³
//	³ [4][2] Dados do AFT	 			³
//	³ [4][3] Titulos Campos				³
//	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// inicializa aSvFolder
Aadd(aSvFolder,{{},{},{}})
Aadd(aSvFolder,{{},{},{}})
Aadd(aSvFolder,{{},{},{}})
Aadd(aSvFolder,{{},{},{}})


aAdd( aObjects, { 100, 100, .T., .T., .T. } )
aSize  := MsAdvSize()
aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
aPosObj:= MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg FROM aSize[7],0 TO aSize[6],aSize[5] TITLE OemToAnsi(STR0104 + Dtoc(dData)) PIXEL of oMainWnd  //"Detalhes do Dia "

// cria o folder para a exibicao dos dados de titulos,ped.venda,despesas,ped.compra
@ aPosObj[1,1],aPosObj[1,2] FOLDER oFolder SIZE aPosObj[1,3],aPosObj[1,4]-5 OF oDlg PROMPTS STR0105 , STR0106, STR0082, STR0107 PIXEL  //"Titulos"###"Pedidos de Venda"###"Pedidos de Compra"

// carrega o acols dos titulos
C100Config("AFT",@aSvFolder,dData,cProjeto,cRevisa,cEDT,cTarefa,nOpcao)

oGetAFT:= TWBrowse():New( 	1,1,aPosObj[1,3]-5,aPosObj[1,4]-20,,aSvFolder[1][3],,;
oFolder:aDialogs[1],,,,,{||C100Visual("AFT",aSvFolder[1][1],aSvFolder[1][2],oGetAFT:nAT)},,,,,,STR0080,.F.,,.T.,,.F.,,,)
oGetAFT:SetArray(aSvFolder[1][2])
oGetAFT:bLine := { ||aSvFolder[1][2][oGetAFT:nAT]}

// carrega o acols dos pedidos de venda
C100Config("SC5",@aSvFolder,dData,cProjeto,cRevisa,cEDT,cTarefa,nOpcao)

oGetSC5:= TWBrowse():New( 	1,1,aPosObj[1,3]-5,aPosObj[1,4]-20,,aSvFolder[2][3],,;
oFolder:aDialogs[2],,,,,{||C100Visual("SC5",aSvFolder[2][1],aSvFolder[2][2],oGetSC5:nAT)},,,,,,STR0080,.F.,,.T.,,.F.,,,)
oGetSC5:SetArray(aSvFolder[2][2])
oGetSC5:bLine := { ||aSvFolder[2][2][oGetSC5:nAT]}

// carrega o acols das despesas
C100Config("AFR",@aSvFolder,dData,cProjeto,cRevisa,cEDT,cTarefa,nOpcao)

oGetAFR:= TWBrowse():New( 	1,1,aPosObj[1,3]-5,aPosObj[1,4]-20,,aSvFolder[3][3],,;
oFolder:aDialogs[3],,,,,{||C100Visual("AFR",aSvFolder[3][1],aSvFolder[3][2],oGetAFR:nAT)},,,,,,STR0080,.F.,,.T.,,.F.,,,)
oGetAFR:SetArray(aSvFolder[3][2])
oGetAFR:bLine := { ||aSvFolder[3][2][oGetAFR:nAT]}

// carrega o acols dos pedidos de compra
C100Config("AFG",@aSvFolder,dData,cProjeto,cRevisa,cEDT,cTarefa,nOpcao)

oGetAFG:= TWBrowse():New( 	1,1,aPosObj[1,3]-5,aPosObj[1,4]-20,,aSvFolder[4][3],,;
oFolder:aDialogs[4],,,,,{||C100Visual("AFG",aSvFolder[4][1],aSvFolder[4][2],oGetAFG:nAT)},,,,,,STR0080,.F.,,.T.,,.F.,,,)
oGetAFG:SetArray(aSvFolder[4][2])
oGetAFG:bLine := { ||aSvFolder[4][2][oGetAFG:nAT]}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End() },{||oDlg:End()})

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³C100Config   ³ Autor ³ Fabio Rogerio Pereira³ Data ³12.12.01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta ACOLS e AHEADER conforme o alias passado			  ³±±   .
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³    C100Config(ExpC1,ExpN1,ExpC2,ExpF1)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Alias selecionado								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ PMSC100													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C100Config(cAlias,aSvFolder,dData,cProjeto,cRevisa,cEDT,cTarefa,nOpcao)
Local nX 		:= 0
Local aTmpHeader:= {}	//aHeader Temporario
Local aTmpCols	:= {}  	//acols Temporario

// monta aHeader a partir dos campos do SX3
aCampos:= {}

dbSelectArea("SX3")
dbSetOrder(1)
MsSeek(cAlias)

While !Eof() .And. (SX3->X3_ARQUIVO == cAlias)
	
	If !("_FILIAL" $ SX3->X3_CAMPO) .And. cNivel >= SX3->X3_NIVEL
		
		Aadd(aCampos,AllTrim(SX3->X3_CAMPO))
		
		AADD(aTmpHeader,{	TRIM(SX3->X3_TITULO),;
		SX3->X3_CAMPO,;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		SX3->X3_VALID,;
		SX3->X3_USADO,;
		SX3->X3_TIPO,;
		SX3->X3_ARQUIVO,;
		SX3->X3_CONTEXT 	} )
		
	EndIf
	
	dbSelectArea("SX3")
	dbSkip()
End

// carrega os registros das base para a getdados
If (cAlias == "AFT")
	PmsAFTTrack(dData,cProjeto,cRevisa,cEDT,cTarefa,@aTmpCols,aTmpHeader)
	If (Len(aTmpCols) == 0)
		dbSelectArea("AFT")
		aAdd(aTmpCols,Array(Len(aTmpHeader)+1))
		
		For nX := 1 To Len(aTmpHeader)
			aTmpCols[Len(aTmpCols)][nX] := Transform(CriaVar(aTmpHeader[nX][2],.F.),PesqPict("AFT",aTmpHeader[nX][2]))
		Next nX
		
		aTmpCols[Len(aTmpCols)][Len(aTmpHeader)+1] := .F.
	EndIf
	
	aSvFolder[1][1] := aClone(aTmpHeader)
	aSvFolder[1][2] := aClone(aTmpCols)
	aEval(aSvFolder[1][1],{|Campos| Aadd(aSvFolder[1][3],Campos[1])})
	
ElseIf (cAlias == "SC5")
	PmsSC5Track(dData,cProjeto,cRevisa,cEDT,cTarefa,@aTmpCols,aTmpHeader)
	
	If (Len(aTmpCols) == 0)
		dbSelectArea("SC5")
		aAdd(aTmpCols,Array(Len(aTmpHeader)+1))
		
		For nX := 1 To Len(aTmpHeader)
			aTmpCols[Len(aTmpCols)][nX] := Transform(CriaVar(aTmpHeader[nX][2],.F.),PesqPict("SC5",aTmpHeader[nX][2]))
		Next nX
		
		aTmpCols[Len(aTmpCols)][Len(aTmpHeader)+1] := .F.
	EndIf
	
	aSvFolder[2][1] := aClone(aTmpHeader)
	aSvFolder[2][2] := aClone(aTmpCols)
	aEval(aSvFolder[2][1],{|Campos| Aadd(aSvFolder[2][3],Campos[1])})
	
ElseIf (cAlias == "AFR")
	PmsAFRTrack(dData,cProjeto,cRevisa,cEDT,cTarefa,@aTmpCols,aTmpHeader)
	
	If (Len(aTmpCols) == 0)
		dbSelectArea("AFR")
		aAdd(aTmpCols,Array(Len(aTmpHeader)+1))
		
		For nX := 1 To Len(aTmpHeader)
			aTmpCols[Len(aTmpCols)][nX] := Transform(CriaVar(aTmpHeader[nX][2],.F.),PesqPict("AFR",aTmpHeader[nX][2]))
		Next nX
		
		aTmpCols[Len(aTmpCols)][Len(aTmpHeader)+1] := .F.
	EndIf
	
	aSvFolder[3][1] := aClone(aTmpHeader)
	aSvFolder[3][2] := aClone(aTmpCols)
	aEval(aSvFolder[3][1],{|Campos| Aadd(aSvFolder[3][3],Campos[1])})
	
ElseIf (cAlias == "AFG")
	PmsAFGTrack(dData,cProjeto,cRevisa,cEDT,cTarefa,@aTmpCols,aTmpHeader)
	
	If (Len(aTmpCols) == 0)
		dbSelectArea("AFG")
		aAdd(aTmpCols,Array(Len(aTmpHeader)+1))
		
		For nX := 1 To Len(aTmpHeader)
			aTmpCols[Len(aTmpCols)][nX] := Transform(CriaVar(aTmpHeader[nX][2],.F.),PesqPict("AFG",aTmpHeader[nX][2]))
		Next nX
		
		aTmpCols[Len(aTmpCols)][Len(aTmpHeader)+1] := .F.
	EndIf
	
	aSvFolder[4][1] := aClone(aTmpHeader)
	aSvFolder[4][2] := aClone(aTmpCols)
	aEval(aSvFolder[4][1],{|Campos| Aadd(aSvFolder[4][3],Campos[1])})
	
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAFTTrack³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 07/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rastreia os titulos da EDT/Tarefa                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsAFTTrack(dData,cProjeto,cRevisa,cEDT,cTarefa,aAFT,aCampos)
Local aArea	    := GetArea()
Local aAreaAFC  := AFC->(GetArea())
Local aAreaAF9  := AF9->(GetArea())
Local nX        := 0

DEFAULT dData   := dDatabase
DEFAULT cEDT    := ""
DEFAULT cTarefa := ""
DEFAULT cProjeto:= ""
DEFAULT cRevisa := ""

// pesquisa todos os titulos das tarefas da EDT
If !Empty(cEDT)
	dbSelectArea("AFT")
	dbSetOrder(4)
	dbSeek(xFilial("AFT") + cProjeto + cRevisa + cEDT)
	
	While !Eof() .And. (AFT->AFT_FILIAL+AFT->AFT_PROJET+AFT->AFT_REVISA+AFT->AFT_EDT == ;
		xFilial("AFT")+cProjeto+cRevisa+cEDT)
		
		// valida o periodo do titulo
		If (AFT->AFT_VENREA == dData)
			aAdd(aAFT,Array(Len(aCampos)+1))
			
			For nX := 1 To Len(aCampos)
				
				If ( aCampos[nX][10] <> "V" .And. aCampos[nX][08] <> "M")
					aAFT[Len(aAFT)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("AFT",aCampos[nX][2]))
				Else
					If ( aCampos[nX][08] <> "M" )
						aAFT[Len(aAFT)][nX] := Transform(CriaVar(aCampos[nX][2],.F.),PesqPict("AFT",aCampos[nX][2]))
					Else
						aAFT[Len(aAFT)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("AFT",aCampos[nX][2]))
					Endif
				Endif
			Next nX
			
			aAFT[Len(aAFT)][Len(aCampos)+1] := .F.
		EndIf
		
		dbSelectArea("AFT")
		dbSkip()
	End
	
	dbSelectArea("AF9")
	dbSetOrder(2)
	dbSeek(xFilial("AF9") + cProjeto + cRevisa + cEDT,.T.)
	While !Eof() .And. (AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI == ;
		xFilial("AF9") + cProjeto + cRevisa + cEDT)
		
		dbSelectArea("AFT")
		dbSetOrder(1)
		dbSeek(xFilial("AFT") + cProjeto + cRevisa + AF9->AF9_TAREFA)
		
		While !Eof() .And. (AFT->AFT_FILIAL+AFT->AFT_PROJET+AFT->AFT_REVISA+AFT->AFT_TAREFA == ;
			xFilial("AFT")+cProjeto+cRevisa+AF9->AF9_TAREFA)
			
			// valida o periodo do titulo
			If (AFT->AFT_VENREA == dData)
				aAdd(aAFT,Array(Len(aCampos)+1))
				
				For nX := 1 To Len(aCampos)
					
					If ( aCampos[nX][10] <> "V" .And. aCampos[nX][08] <> "M")
						aAFT[Len(aAFT)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("AFT",aCampos[nX][2]))
					Else
						If ( aCampos[nX][08] <> "M" )
							aAFT[Len(aAFT)][nX] := Transform(CriaVar(aCampos[nX][2],.F.),PesqPict("AFT",aCampos[nX][2]))
						Else
							aAFT[Len(aAFT)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("AFT",aCampos[nX][2]))
						Endif
					Endif
				Next nX
				
				aAFT[Len(aAFT)][Len(aCampos)+1] := .F.
			EndIf
			
			dbSelectArea("AFT")
			dbSkip()
		End
		
		dbSelectArea("AF9")
		dbSkip()
	End
	
	// calcula as EDT`s filhas se existir
	dbSelectArea("AFC")
	dbSetOrder(2)
	dbSeek(xFilial("AFC") + cProjeto + cRevisa + cEDT)
	While !Eof() .And. (xFilial("AFC") + cProjeto + cRevisa + cEDT ==;
		AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI)
		PmsAFTTrack(dData,cProjeto,cRevisa,AFC->AFC_EDT,cTarefa,aAFT,aCampos)
		dbSelectArea("AFC")
		dbSkip()
	End
	
ElseIf !Empty(cTarefa)
	dbSelectArea("AFT")
	dbSetOrder(1)
	dbSeek(xFilial("AFT") + cProjeto + cRevisa + cTarefa)
	
	While !Eof() .And. (AFT->AFT_FILIAL+AFT->AFT_PROJET+AFT->AFT_REVISA+AFT->AFT_TAREFA == ;
		xFilial("AFT")+cProjeto+cRevisa+cTarefa)
		
		// valida o periodo do titulo
		If (AFT->AFT_VENREA == dData)
			aAdd(aAFT,Array(Len(aCampos)+1))
			
			For nX := 1 To Len(aCampos)
				
				If ( aCampos[nX][10] <> "V" .And. aCampos[nX][08] <> "M")
					aAFT[Len(aAFT)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("AFT",aCampos[nX][2]))
				Else
					If ( aCampos[nX][08] <> "M" )
						aAFT[Len(aAFT)][nX] := Transform(CriaVar(aCampos[nX][2],.F.),PesqPict("AFT",aCampos[nX][2]))
					Else
						aAFT[Len(aAFT)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("AFT",aCampos[nX][2]))
					Endif
				Endif
				
			Next nX
			
			aAFT[Len(aAFT)][Len(aCampos)+1] := .F.
		EndIf
		
		dbSelectArea("AFT")
		dbSkip()
	End
EndIf

aAFT:= ASORT(aAFT,,, { |x, y| x[1] < y[1] })

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAFRTrack ³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 13/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna as despesas da EDT/Tarefa                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsAFRTrack(dData,cProjeto,cRevisa,cEDT,cTarefa,aAFR,aCampos)
Local aArea	    := GetArea()
Local aAreaAFC  := AFC->(GetArea())
Local aAreaAF9  := AF9->(GetArea())
Local nX        := 0

DEFAULT dData   := dDatabase
DEFAULT cEDT    := ""
DEFAULT cTarefa := ""
DEFAULT cProjeto:= ""
DEFAULT cRevisa := ""

// pesquisa todas as despesas das tarefas da EDT
If !Empty(cEDT)
	dbSelectArea("AF9")
	dbSetOrder(2)
	dbSeek(xFilial("AF9") + cProjeto + cRevisa + cEDT,.T.)
	While !Eof() .And. (AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI == ;
		xFilial("AF9") + cProjeto + cRevisa + cEDT)
		
		dbSelectArea("AFR")
		dbSetOrder(1)
		dbSeek(xFilial("AFR") + cProjeto + cRevisa + AF9->AF9_TAREFA)
		
		While !Eof() .And. (AFR->AFR_FILIAL+AFR->AFR_PROJET+AFR->AFR_REVISA+AFR->AFR_TAREFA == ;
			xFilial("AFR")+cProjeto+cRevisa+AF9->AF9_TAREFA)
			
			// valida o periodo do titulo
			If (AFR->AFR_VENREA == dData)
				dbSelectArea("AFR")
				aAdd(aAFR,Array(Len(aCampos)+1))
				
				For nX := 1 To Len(aCampos)
					
					If ( aCampos[nX][10] <> "V" .And. aCampos[nX][08] <> "M")
						aAFR[Len(aAFR)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("AFR",aCampos[nX][2]))
					Else
						If ( aCampos[nX][08] <> "M" )
							aAFR[Len(aAFR)][nX] := Transform(CriaVar(aCampos[nX][2],.F.),PesqPict("AFR",aCampos[nX][2]))
						Else
							aAFR[Len(aAFR)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("AFR",aCampos[nX][2]))
						Endif
					Endif
				Next nX
				
				aAFR[Len(aAFR)][Len(aCampos)+1] := .F.
				
			EndIf
			
			dbSelectArea("AFR")
			dbSkip()
		End
		
		dbSelectArea("AF9")
		dbSkip()
	End
	
	// calcula as EDT`s filhas se existir
	dbSelectArea("AFC")
	dbSetOrder(2)
	dbSeek(xFilial("AFC") + cProjeto + cRevisa + cEDT)
	While !Eof() .And. (xFilial("AFC") + cProjeto + cRevisa + cEDT ==;
		AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI)
		PmsAFRTrack(dData,cProjeto,cRevisa,AFC->AFC_EDT,cTarefa,@aAFR,aCampos)
		dbSelectArea("AFC")
		dbSkip()
	End
	
ElseIf !Empty(cTarefa)
	dbSelectArea("AFR")
	dbSetOrder(1)
	dbSeek(xFilial("AFR") + cProjeto + cRevisa + cTarefa)
	
	While !Eof() .And. (AFR->AFR_FILIAL+AFR->AFR_PROJET+AFR->AFR_REVISA+AFR->AFR_TAREFA == ;
		xFilial("AFR")+cProjeto+cRevisa+cTarefa)
		
		// valida o periodo da despesa
		If (AFR->AFR_VENREA == dData)
			dbSelectArea("AFR")
			aAdd(aAFR,Array(Len(aCampos)+1))
			
			For nX := 1 To Len(aCampos)
				
				If ( aCampos[nX][10] <> "V" .And. aCampos[nX][08] <> "M")
					aAFR[Len(aAFR)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("AFR",aCampos[nX][2]))
				Else
					If ( aCampos[nX][08] <> "M" )
						aAFR[Len(aAFR)][nX] := Transform(CriaVar(aCampos[nX][2],.F.),PesqPict("AFR",aCampos[nX][2]))
					Else
						aAFR[Len(aAFR)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("AFR",aCampos[nX][2]))
					Endif
				Endif
			Next nX
			
			aAFR[Len(aAFR)][Len(aCampos)+1] := .F.
		EndIf
		
		dbSelectArea("AFR")
		dbSkip()
	End
EndIf

aAFR:= ASORT(aAFR,,, { |x, y| x[1] < y[1] })

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsSC5Track³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 13/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os pedidos de venda da EDT/Tarefa                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsSC5Track(dData,cProjeto,cRevisa,cEDT,cTarefa,aSC5,aCampos)
Local nParcela  := 0
Local aArea	    := GetArea()
Local aAreaAFC  := AFC->(GetArea())
Local aAreaAF9  := AF9->(GetArea())
Local aParcelas := {}
Local nX		:= 0

DEFAULT dData   := dDatabase
DEFAULT cEDT    := ""
DEFAULT cTarefa := ""
DEFAULT cProjeto:= ""
DEFAULT cRevisa := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa todos os Pde.Venda da EDT            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cEDT)
	dbSelectArea("AF9")
	dbSetOrder(2)
	dbSeek(xFilial("AF9") + cProjeto + cRevisa + cEDT,.T.)
	While !Eof() .And. (AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI == ;
		xFilial("AF9") + cProjeto + cRevisa + cEDT)
		
		dbSelectArea("SC6")
		dbSetOrder(8)
		dbSeek(xFilial("SC6") + cProjeto + AF9->AF9_TAREFA)
		
		While !Eof() .And. (SC6->C6_FILIAL+SC6->C6_PROJPMS+SC6->C6_TASKPMS == ;
			xFilial("SC6")+cProjeto+AF9->AF9_TAREFA)
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Somente verifica os itens cuja TES gera duplicata.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(SC6->C6_NOTA + SerieNfId("SC6",2,"C6_SERIE"))
				
				SF4->(dbSetOrder(1))
				SF4->(dbSeek(xFilial("SF4") + SC6->C6_TES))
				
				If (SF4->F4_DUPLIC == "S") .And. (SF4->F4_MOVPRJ $ "15")
					SC5->(dbSetOrder(1))
					SC5->(dbSeek(xFilial("SC5") + SC6->C6_NUM))
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida a condicao de pagamento.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aParcelas:= Condicao(SC6->C6_VALOR,SC5->C5_CONDPAG,,SC5->C5_EMISSAO)
					
					For nParcela:= 1 To Len(aParcelas)
						If (aParcelas[nParcela][1] == dData)
							dbSelectArea("SC5")
							
							aAdd(aSC5,Array(Len(aCampos)+1))
							
							For nX := 1 To Len(aCampos)
								
								If ( aCampos[nX][10] <> "V" .And. aCampos[nX][08] <> "M")
									aSC5[Len(aSC5)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("SC5",aCampos[nX][2]))
								Else
									If ( aCampos[nX][08] <> "M" )
										aSC5[Len(aSC5)][nX] := Transform(CriaVar(aCampos[nX][2],.F.),PesqPict("SC5",aCampos[nX][2]))
									Else
										aSC5[Len(aSC5)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("SC5",aCampos[nX][2]))
									Endif
								Endif
							Next nX
							
							aSC5[Len(aSC5)][Len(aCampos)+1] := .F.
							
							Exit
						EndIf
					Next
				EndIf
			EndIf
			
			dbSelectArea("SC6")
			dbSkip()
		End
		
		dbSelectArea("AF9")
		dbSkip()
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula as EDT`s filhas se existir.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFC")
	dbSetOrder(2)
	dbSeek(xFilial("AFC") + cProjeto + cRevisa + cEDT)
	While !Eof() .And. (xFilial("AFC") + cProjeto + cRevisa + cEDT ==;
		AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI)
		PmsSC5Track(dData,cProjeto,cRevisa,AFC->AFC_EDT,cTarefa,@aSC5,aCampos)
		dbSelectArea("AFC")
		dbSkip()
	End
	
ElseIf !Empty(cTarefa)
	dbSelectArea("SC6")
	dbSetOrder(8)
	dbSeek(xFilial("SC6") + cProjeto + cTarefa)
	
	While !Eof() .And. (SC6->C6_FILIAL+SC6->C6_PROJPMS+SC6->C6_TASKPMS == ;
		xFilial("SC6")+cProjeto+cTarefa)
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente verifica os itens cuja TES gera duplicata.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(SC6->C6_NOTA + SerieNfId("SC6",2,"C6_SERIE"))
			
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4") + SC6->C6_TES))
			
			If (SF4->F4_DUPLIC == "S") .And. (SF4->F4_MOVPRJ $ "15")
				SC5->(dbSetOrder(1))
				SC5->(dbSeek(xFilial("SC5") + SC6->C6_NUM))
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida a condicao de pagamento.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aParcelas:= Condicao(SC6->C6_VALOR,SC5->C5_CONDPAG,,SC5->C5_EMISSAO)
				
				For nParcela:= 1 To Len(aParcelas)
					If (aParcelas[nParcela][1] == dData)
						dbSelectArea("SC5")
						aAdd(aSC5,Array(Len(aCampos)+1))
						
						For nX := 1 To Len(aCampos)
							
							If ( aCampos[nX][10] <> "V" .And. aCampos[nX][08] <> "M")
								aSC5[Len(aSC5)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("SC5",aCampos[nX][2]))
							Else
								If ( aCampos[nX][08] <> "M" )
									aSC5[Len(aSC5)][nX] := Transform(CriaVar(aCampos[nX][2],.F.),PesqPict("SC5",aCampos[nX][2]))
								Else
									aSC5[Len(aSC5)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("SC5",aCampos[nX][2]))
								Endif
							Endif
						Next nX
						
						aSC5[Len(aSC5)][Len(aCampos)+1] := .F.
						
						Exit
					EndIf
				Next
			EndIf
		EndIf
		
		dbSelectArea("SC6")
		dbSkip()
	End
EndIf

aSC5:= ASORT(aSC5,,, { |x, y| x[1] < y[1] })

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAFGTrack³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 13/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os pedidos de compra da EDT/Tarefa                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsAFGTrack(dData,cProjeto,cRevisa,cEDT,cTarefa,aAFG,aCampos)
Local nParcela  := 0
Local aArea	    := GetArea()
Local aAreaAFC  := AFC->(GetArea())
Local aAreaAF9  := AF9->(GetArea())
Local aParcelas := {}
Local nX		:= 0

DEFAULT dData   := dDatabase
DEFAULT cEDT    := ""
DEFAULT cTarefa := ""
DEFAULT cProjeto:= ""
DEFAULT cRevisa := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa todos os Pde.Venda da EDT            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cEDT)
	dbSelectArea("AF9")
	dbSetOrder(2)
	dbSeek(xFilial("AF9") + cProjeto + cRevisa + cEDT,.T.)
	While !Eof() .And. (AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI == ;
		xFilial("AF9") + cProjeto + cRevisa + cEDT)
		
		dbSelectArea("AFG")
		dbSetOrder(1)
		dbSeek(xFilial("AFG") + cProjeto + cRevisa + AF9->AF9_TAREFA)
		
		While !Eof() .And. (AFG->AFG_FILIAL+AFG->AFG_PROJET+AFG->AFG_REVISA+AFG->AFG_TAREFA == ;
			xFilial("AFG")+cProjeto+cRevisa+AF9->AF9_TAREFA)
			
			SC1->(dbSetOrder(1))
			SC1->(dbSeek(xFilial("SC1") + AFG->AFG_NUMSC + AFG->AFG_ITEMSC))
			
			If !Empty(SC1->C1_PEDIDO)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pesquisa os pedidos da solicitacao de compras.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SC7")
				dbSetOrder(1)
				dbSeek(xFilial("SC7") + SC1->C1_PEDIDO + SC1->C1_ITEMPED)
				
				While !Eof() .And. (xFilial("SC7") == SC7->C7_FILIAL) .And. (SC1->C1_PEDIDO == SC7->C7_NUM) .And.;
					(SC1->C1_ITEMPED == SC7->C7_ITEM)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Somente verifica os itens cuja TES gera duplicata.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SF4->(dbSetOrder(1))
					SF4->(dbSeek(xFilial("SF4") + SC7->C7_TES))
					
					If (SF4->F4_DUPLIC == "S") .Or. Empty(SC7->C7_TES)
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Valida a condicao de pagamento.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aParcelas:= Condicao((SC7->C7_PRECO * AFG->AFG_QUANT),SC7->C7_COND,,SC7->C7_EMISSAO)
						
						For nParcela:= 1 To Len(aParcelas)
							If (aParcelas[nParcela][1] == dData)
								dbSelectArea("AFG")
								aAdd(aAFG,Array(Len(aCampos)+1))
								
								For nX := 1 To Len(aCampos)
									
									If ( aCampos[nX][10] <> "V" .And. aCampos[nX][08] <> "M")
										aAFG[Len(aAFG)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("AFG",aCampos[nX][2]))
									Else
										If ( aCampos[nX][08] <> "M" )
											aAFG[Len(aAFG)][nX] := Transform(CriaVar(aCampos[nX][2],.F.),PesqPict("AFG",aCampos[nX][2]))
										Else
											aAFG[Len(aAFG)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("AFG",aCampos[nX][2]))
										Endif
									Endif
								Next nX
								
								aAFG[Len(aAFG)][Len(aCampos)+1] := .F.
								
							EndIf
						Next
					EndIf
					
					dbSelectArea("SC7")
					dbSkip()
				End
				
			EndIf
			
			dbSelectArea("AFG")
			dbSkip()
		End
		
		dbSelectArea("AF9")
		dbSkip()
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula as EDT`s filhas se existir.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFC")
	dbSetOrder(2)
	dbSeek(xFilial("AFC") + cProjeto + cRevisa + cEDT)
	While !Eof() .And. (xFilial("AFC") + cProjeto + cRevisa + cEDT ==;
		AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI)
		PmsAFGTrack(dData,cProjeto,cRevisa,AFC->AFC_EDT,cTarefa,@aAFG,aCampos)
		dbSelectArea("AFC")
		dbSkip()
	End
	
ElseIf !Empty(cTarefa)
	dbSelectArea("AFG")
	dbSetOrder(1)
	dbSeek(xFilial("AFG") + cProjeto + cRevisa + cTarefa)
	
	While !Eof() .And. (AFG->AFG_FILIAL+AFG->AFG_PROJET+AFG->AFG_REVISA+AFG->AFG_TAREFA == ;
		xFilial("AFG")+cProjeto+cRevisa+cTarefa)
		
		SC1->(dbSetOrder(1))
		SC1->(dbSeek(xFilial("SC1") + AFG->AFG_NUMSC + AFG->AFG_ITEMSC))
		
		If !Empty(SC1->C1_PEDIDO)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pesquisa os pedidos da solicitacao de compras.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SC7")
			dbSetOrder(1)
			dbSeek(xFilial("SC7") + SC1->C1_PEDIDO + SC1->C1_ITEMPED)
			
			While !Eof() .And. (xFilial("SC7") == SC7->C7_FILIAL) .And. (SC1->C1_PEDIDO == SC7->C7_NUM) .And.;
				(SC1->C1_ITEMPED == SC7->C7_ITEM)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Somente verifica os itens cuja TES gera duplicata.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SF4->(dbSetOrder(1))
				SF4->(dbSeek(xFilial("SF4") + SC7->C7_TES))
				
				If (SF4->F4_DUPLIC == "S") .Or. Empty(SC7->C7_TES)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida a condicao de pagamento.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aParcelas:= Condicao((SC7->C7_PRECO * AFG->AFG_QUANT),SC7->C7_COND,,SC7->C7_EMISSAO)
					
					For nParcela:= 1 To Len(aParcelas)
						If (aParcelas[nParcela][1] == dData)
							aAdd(aAFG,Array(Len(aCampos)+1))
							
							For nX := 1 To Len(aCampos)
								
								If ( aCampos[nX][10] <> "V" .And. aCampos[nX][08] <> "M")
									aAFG[Len(aAFG)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("AFG",aCampos[nX][2]))
								Else
									If ( aCampos[nX][08] <> "M" )
										aAFG[Len(aAFG)][nX] := Transform(CriaVar(aCampos[nX][2],.F.),PesqPict("AFG",aCampos[nX][2]))
									Else
										aAFG[Len(aAFG)][nX] := Transform(FieldGet(FieldPos(aCampos[nX][2])),PesqPict("AFG",aCampos[nX][2]))
									Endif
								Endif
							Next nX
							
							aAFG[Len(aAFG)][Len(aCampos)+1] := .F.
						EndIf
					Next
				EndIf
				
				dbSelectArea("SC7")
				dbSkip()
			End
			
		EndIf
		
		dbSelectArea("AFG")
		dbSkip()
	End
EndIf

aAFG:= ASORT(aAFG,,, { |x, y| x[1] < y[1] })

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C100Visual ³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 13/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Visualiza as origens dos dados                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C100Visual(cAlias,aCampos,aDados,nPos)
Local cCadAux := cCadastro
Local nPPref  := 0
Local nPNum   := 0
Local nPParc  := 0
Local nPTipo  := 0
Local nPFornec:= 0
Local nPLoja  := 0
Local nPItem  := 0

CursorWait()

Do Case
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibe os dados do titulo a receber.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case (cAlias == "AFT")
		cCadastro+= STR0108 //" Contas a Receber"
		nPPref:= Ascan(aCampos,{|x| AllTrim(x[2]) == "AFT_PREFIX"})
		nPNum := Ascan(aCampos,{|x| AllTrim(x[2]) == "AFT_NUM"})
		nPParc:= Ascan(aCampos,{|x| AllTrim(x[2]) == "AFT_PARCEL"})
		nPTipo:= Ascan(aCampos,{|x| AllTrim(x[2]) == "AFT_TIPO"})
		
		dbSelectArea("SE1")
		dbSetOrder(1)
		If dbSeek(xFilial("SE1") + aDados[nPos][nPPref] + aDados[nPos][nPNum] + aDados[nPos][nPParc] + aDados[nPos][nPTipo])
			AxVisual("SE1",Recno(),2)
		EndIf
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe os dados do titulo a pagar.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case (cAlias == "AFR")
		cCadastro+= STR0109 //" Contas a Pagar"
		
		nPPref  := Ascan(aCampos,{|x| AllTrim(x[2]) == "AFR_PREFIX"})
		nPNum   := Ascan(aCampos,{|x| AllTrim(x[2]) == "AFR_NUM"})
		nPParc  := Ascan(aCampos,{|x| AllTrim(x[2]) == "AFR_PARCEL"})
		nPTipo  := Ascan(aCampos,{|x| AllTrim(x[2]) == "AFR_TIPO"})
		nPFornec:= Ascan(aCampos,{|x| AllTrim(x[2]) == "AFR_FORNEC"})
		nPLoja  := Ascan(aCampos,{|x| AllTrim(x[2]) == "AFR_LOJA"})
		
		dbSelectArea("SE2")
		dbSetOrder(1)
		If dbSeek(xFilial("SE2") + aDados[nPos][nPPref] + aDados[nPos][nPNum] + aDados[nPos][nPParc] + aDados[nPos][nPTipo] + aDados[nPos][nPFornec] + aDados[nPos][nPLoja])
			AxVisual("SE2",Recno(),2)
		EndIf
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe os dados do Pedido de Venda.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case (cAlias == "SC5")
		cCadastro+= STR0106
		
		nPNum   := Ascan(aCampos,{|x| AllTrim(x[2]) == "C5_NUM"})
		
		dbSelectArea("SC5")
		dbSetOrder(1)
		If dbSeek(xFilial("SC5") + aDados[nPos][nPNum])
			AxVisual("SC5",Recno(),2)
		EndIf
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe os dados do pedido de compras.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case (cAlias == "AFG")
		cCadastro+= STR0107
		
		nPNum   := Ascan(aCampos,{|x| AllTrim(x[2]) == "AFG_NUMSC"})
		nPItem  := Ascan(aCampos,{|x| AllTrim(x[2]) == "AFG_ITEMSC"})
		
		dbSelectArea("SC1")
		dbSetOrder(1)
		If dbSeek(xFilial("SC1") + aDados[nPos][nPNum] + aDados[nPos][nPItem])
			AxVisual("SC1",Recno(),2)
		EndIf
EndCase

cCadastro:= cCadAux

CursorArrow()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsSE5Calc³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 07/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o valor dos titulos da EDT/Tarefa                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsSE5Calc(dDtIni,dDtFim,cProjeto,cRevisa,cEDT,cTarefa,nMoeda,aValor,cTipo)
Local nPosVenc  := 0
Local aArea	    := GetArea()
Local aAreaAFC  := AFC->(GetArea())
Local aAreaAF9  := AF9->(GetArea())
DEFAULT dDtIni  := dDatabase
DEFAULT dDtFim  := dDatabase
DEFAULT cEDT    := ""
DEFAULT cTarefa := ""
DEFAULT cProjeto:= ""
DEFAULT cRevisa := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa todos os titulos das tarefas da EDT. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cEDT)
	dbSelectArea("SE5")
	dbSetOrder(9)
	dbSeek(xFilial("SE5") + cProjeto + cEDT)
	
	While !Eof() .And. (SE5->E5_FILIAL+SE5->E5_PROJPMS+SE5->E5_EDTPMS == ;
		xFilial("SE5")+cProjeto+cEDT)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o periodo do titulo.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SE5->E5_SITUACA <> "C") .And. (SE5->E5_DATA >= dDtIni) .And. (SE5->E5_DATA <= dDtFim) .And. (SE5->E5_RECPAG == cTipo)
			nPosVenc := aScan(aValor,{|x| x[1] == SE5->E5_DATA})
			If nPosVenc > 0
				If (cTipo == "R")
					aValor[nPosVenc][2] += xMoeda(SE5->E5_VALOR,1,nMoeda,SE5->E5_DATA)
				Else
					aValor[nPosVenc][3] += xMoeda(SE5->E5_VALOR,1,nMoeda,SE5->E5_DATA)
				EndIf
			Else
				If (cTipo == "R")
					aAdd(aValor,{SE5->E5_DATA,xMoeda(SE5->E5_VALOR,1,nMoeda,SE5->E5_DATA),0,0,0,0,0,0,0})
				Else
					aAdd(aValor,{SE5->E5_DATA,0,xMoeda(SE5->E5_VALOR,1,nMoeda,SE5->E5_DATA),0,0,0,0,0,0})
				EndIf
			EndIf
		EndIf
		
		dbSelectArea("SE5")
		dbSkip()
	End
	
	dbSelectArea("AF9")
	dbSetOrder(2)
	dbSeek(xFilial("AF9") + cProjeto + cRevisa + cEDT,.T.)
	While !Eof() .And. (AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI == ;
		xFilial("AF9") + cProjeto + cRevisa + cEDT)
		
		dbSelectArea("SE5")
		dbSetOrder(9)
		dbSeek(xFilial("SE5") + cProjeto)
		
		While !Eof() .And. (SE5->E5_FILIAL+SE5->E5_PROJPMS+SE5->E5_TASKPMS == ;
			xFilial("SE5")+cProjeto+AF9->AF9_TAREFA)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida o periodo do titulo.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (SE5->E5_SITUACA <> "C") .And. (SE5->E5_DATA >= dDtIni) .And. (SE5->E5_DATA <= dDtFim) .And. (SE5->E5_RECPAG == cTipo)
				nPosVenc := aScan(aValor,{|x| x[1] == SE5->E5_DATA})
				If nPosVenc > 0
					If (cTipo == "R")
						aValor[nPosVenc][2] += xMoeda(SE5->E5_VALOR,1,nMoeda,SE5->E5_DATA)
					Else
						aValor[nPosVenc][3] += xMoeda(SE5->E5_VALOR,1,nMoeda,SE5->E5_DATA)
					EndIf
				Else
					If (cTipo == "R")
						aAdd(aValor,{SE5->E5_DATA,xMoeda(SE5->E5_VALOR,1,nMoeda,SE5->E5_DATA),0,0,0,0,0,0,0})
					Else
						aAdd(aValor,{SE5->E5_DATA,0,xMoeda(SE5->E5_VALOR,1,nMoeda,SE5->E5_DATA),0,0,0,0,0,0})
					EndIf
				EndIf
			EndIf
			
			dbSelectArea("SE5")
			dbSkip()
		End
		
		dbSelectArea("AF9")
		dbSkip()
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula as EDT`s filhas se existir.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFC")
	dbSetOrder(2)
	dbSeek(xFilial("AFC") + cProjeto + cRevisa + cEDT)
	While !Eof() .And. (xFilial("AFC") + cProjeto + cRevisa + cEDT ==;
		AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI)
		
		PmsSE5Calc(dDtIni,dDtFim,cProjeto,cRevisa,AFC->AFC_EDT,cTarefa,nMoeda,@aValor,cTipo)
		dbSelectArea("AFC")
		dbSkip()
	End
	
ElseIf !Empty(cTarefa)
	dbSelectArea("SE5")
	dbSetOrder(9)
	dbSeek(xFilial("SE5") + cProjeto)
	
	While !Eof() .And. (SE5->E5_FILIAL+SE5->E5_PROJPMS+SE5->E5_TASKPMS == ;
		xFilial("SE5")+cProjeto+cTarefa)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o periodo do titulo.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SE5->E5_SITUACA <> "C") .And. (SE5->E5_DATA >= dDtIni) .And. (SE5->E5_DATA <= dDtFim) .And. (SE5->E5_RECPAG == cTipo)
			nPosVenc := aScan(aValor,{|x| x[1] == SE5->E5_DATA})
			If nPosVenc > 0
				If (cTipo == "R")
					aValor[nPosVenc][2] += xMoeda(SE5->E5_VALOR,1,nMoeda,SE5->E5_DATA)
				Else
					aValor[nPosVenc][3] += xMoeda(SE5->E5_VALOR,1,nMoeda,SE5->E5_DATA)
				EndIf
			Else
				If (cTipo == "R")
					aAdd(aValor,{SE5->E5_DATA,xMoeda(SE5->E5_VALOR,1,nMoeda,SE5->E5_DATA),0,0,0,0,0,0,0})
				Else
					aAdd(aValor,{SE5->E5_DATA,0,xMoeda(SE5->E5_VALOR,1,nMoeda,SE5->E5_DATA),0,0,0,0,0,0})
				EndIf
			EndIf
		EndIf
		
		dbSelectArea("SE5")
		dbSkip()
	End
EndIf

aValor:= ASORT(aValor,,, { |x, y| x[1] < y[1] })

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAFSCalc³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 10/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o valor das notas da EDT/Tarefa                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsAFSCalc(dDtIni,dDtFim,cProjeto,cRevisa,cEDT,cTarefa,nMoeda,aValor)
Local nPosVenc  := 0
Local nValor    := 0
Local nTotalDup := 0
Local cPrefixo  := ""
Local aArea	    := GetArea()
Local aAreaAFC  := AFC->(GetArea())
Local aAreaAF9  := AF9->(GetArea())
DEFAULT dDtIni  := dDatabase
DEFAULT dDtFim  := dDatabase
DEFAULT cEDT    := ""
DEFAULT cTarefa := ""
DEFAULT cProjeto:= ""
DEFAULT cRevisa := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa todas as notas e titulos da tarefa.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa todos os titulos das tarefas da EDT. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cEDT)
	dbSelectArea("AFS")
	dbSetOrder(3)
	dbSeek(xFilial("AFS") + cProjeto + cRevisa + cEDT)
	
	While !Eof() .And. (AFS->AFS_FILIAL+AFS->AFS_PROJET+AFS->AFS_REVISA+AFS->AFS_EDT == ;
		xFilial("AFS")+cProjeto+cRevisa+cEDT)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente verifica os itens cuja TES gera duplicata.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SD2->(dbSetOrder(6))
		If SD2->(dbSeek(xFilial("SD2")+AFS->AFS_COD+AFS->AFS_LOCAL+DTOS(AFS->AFS_EMISSAO)+AFS->AFS_NUMSEQ))
			
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial()+SD2->D2_TES))
			
			If (SF4->F4_DUPLIC == "S") .And. (SF4->F4_MOVPRJ $ "15")
				
				SF2->(dbSetOrder(1))
				SF2->(dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))
				
				dbSelectArea("SD2")
				dbSetOrder(3)
				
				nTotalDup	:= 0
				MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
				dbSelectArea("SD2")
				While !Eof().And. SD2->D2_FILIAL == xFilial("SD2") .And.;
					SD2->D2_DOC     == SF2->F2_DOC .And.;
					SD2->D2_SERIE   == SF2->F2_SERIE .And.;
					SD2->D2_CLIENTE == SF2->F2_CLIENTE .And.;
					SD2->D2_LOJA    == SF2->F2_LOJA
					
					SF4->(dbSetOrder(1))
					SF4->(dbSeek(xFilial()+SD2->D2_TES))
					If (SF4->F4_DUPLIC == "S") .And. (SF4->F4_MOVPRJ $ "15")
						nTotalDup+= SD2->D2_TOTAL
					EndIf
					
					dbSelectArea("SD2")
					dbSkip()
				End
				
				SD2->(dbSetOrder(6))
				SD2->(dbSeek(xFilial("SD2")+AFS->AFS_COD+AFS->AFS_LOCAL+DTOS(AFS->AFS_EMISSAO)+AFS->AFS_NUMSEQ))
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica a existencia de titulos e receber e aplica a proporcao.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SE1")
				dbSetOrder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				cPrefixo := IIf(Empty(SF2->F2_PREFIXO), &(SuperGetMv("MV_1DUPREF")), SF2->F2_PREFIXO)
				cPrefixo := PadR(cPrefixo,Len(SE2->E2_PREFIXO))
				dbSeek(xFilial("SE1") + SD2->D2_CLIENTE + SD2->D2_LOJA + cPrefixo + AFS->AFS_DOC)

				While !Eof() .And. (xFilial("SE1") == SE1->E1_FILIAL) .And. (SE1->E1_CLIENTE == SD2->D2_CLIENTE) .And.;
					(SE1->E1_LOJA == SD2->D2_LOJA) .And. (SE1->E1_PREFIXO == cPrefixo) .And. (SE1->E1_NUM == AFS->AFS_DOC)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida o periodo do titulo.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (SE1->E1_VENREA >= dDtIni) .And. (SE1->E1_VENREA <= dDtFim)
						nValor   := ((SD2->D2_TOTAL / nTotalDup) * SE1->E1_VALOR)
						nPosVenc := aScan(aValor,{|x| x[1] == SE1->E1_VENREA})
						If nPosVenc > 0
							aValor[nPosVenc][2] += xMoeda(nValor,1,nMoeda,SE1->E1_VENREA)
						Else
							aAdd(aValor,{SE1->E1_VENREA,xMoeda(nValor,1,nMoeda,SE1->E1_VENREA),0,0,0,0,0,0,0})
						EndIf
					EndIf
					
					dbSelectArea("SE1")
					dbSkip()
				End
			EndIf
		EndIf
		
		dbSelectArea("AFS")
		dbSkip()
	End
	
	dbSelectArea("AF9")
	dbSetOrder(2)
	dbSeek(xFilial("AF9") + cProjeto + cRevisa + cEDT,.T.)
	While !Eof() .And. (AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI == ;
		xFilial("AF9") + cProjeto + cRevisa + cEDT)
		
		dbSelectArea("AFS")
		dbSetOrder(1)
		dbSeek(xFilial("AFS") + cProjeto + cRevisa + AF9->AF9_TAREFA)
		
		While !Eof() .And. (AFS->AFS_FILIAL+AFS->AFS_PROJET+AFS->AFS_REVISA+AFS->AFS_TAREFA == ;
			xFilial("AFS")+cProjeto+cRevisa+AF9->AF9_TAREFA)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Somente verifica os itens cuja TES gera duplicata.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SD2->(dbSetOrder(6))
			If SD2->(dbSeek(xFilial("SD2")+AFS->AFS_COD+AFS->AFS_LOCAL+DTOS(AFS->AFS_EMISSAO)+AFS->AFS_NUMSEQ))
				
				SF4->(dbSetOrder(1))
				SF4->(dbSeek(xFilial()+SD2->D2_TES))
				
				If (SF4->F4_DUPLIC == "S") .And. (SF4->F4_MOVPRJ $ "15")
					
					SF2->(dbSetOrder(1))
					SF2->(dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))
					
					dbSelectArea("SD2")
					dbSetOrder(3)
					
					nTotalDup	:= 0
					MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
					dbSelectArea("SD2")
					While !Eof().And. SD2->D2_FILIAL == xFilial("SD2") .And.;
						SD2->D2_DOC     == SF2->F2_DOC .And.;
						SD2->D2_SERIE   == SF2->F2_SERIE .And.;
						SD2->D2_CLIENTE == SF2->F2_CLIENTE .And.;
						SD2->D2_LOJA    == SF2->F2_LOJA
						
						SF4->(dbSetOrder(1))
						SF4->(dbSeek(xFilial()+SD2->D2_TES))
						If (SF4->F4_DUPLIC == "S") .And. (SF4->F4_MOVPRJ $ "15")
							nTotalDup+= SD2->D2_TOTAL
						EndIf
						
						dbSelectArea("SD2")
						dbSkip()
					End
					
					SD2->(dbSetOrder(6))
					SD2->(dbSeek(xFilial("SD2")+AFS->AFS_COD+AFS->AFS_LOCAL+DTOS(AFS->AFS_EMISSAO)+AFS->AFS_NUMSEQ))
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica a existencia de titulos e receber e aplica a proporcao.        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SE1")
					dbSetOrder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					cPrefixo := IIf(Empty(SF2->F2_PREFIXO), &(SuperGetMv("MV_1DUPREF")), SF2->F2_PREFIXO)
					cPrefixo := PadR(cPrefixo,Len(SE2->E2_PREFIXO))
					dbSeek(xFilial("SE1") + SD2->D2_CLIENTE + SD2->D2_LOJA + cPrefixo + AFS->AFS_DOC)
					
					While !Eof() .And. (xFilial("SE1") == SE1->E1_FILIAL) .And. (SE1->E1_CLIENTE == SD2->D2_CLIENTE) .And.;
						(SE1->E1_LOJA == SD2->D2_LOJA) .And. (SE1->E1_PREFIXO == cPrefixo) .And. (SE1->E1_NUM == AFS->AFS_DOC)
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Valida o periodo do titulo.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (SE1->E1_VENCREA >= dDtIni) .And. (SE1->E1_VENCREA <= dDtFim)
							nValor   := ((SD2->D2_TOTAL / nTotalDup) * SE1->E1_VALOR)
							nPosVenc := aScan(aValor,{|x| x[1] == SE1->E1_VENCREA})
							If nPosVenc > 0
								aValor[nPosVenc][2] += xMoeda(nValor,1,nMoeda,SE1->E1_VENCREA)
							Else
								aAdd(aValor,{SE1->E1_VENCREA,xMoeda(nValor,1,nMoeda,SE1->E1_VENCREA),0,0,0,0,0,0,0})
							EndIf
						EndIf
						
						dbSelectArea("SE1")
						dbSkip()
					End
				EndIf
			EndIf
			
			dbSelectArea("AFS")
			dbSkip()
		End
		
		dbSelectArea("AF9")
		dbSkip()
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula as EDT`s filhas se existir.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFC")
	dbSetOrder(2)
	dbSeek(xFilial("AFC") + cProjeto + cRevisa + cEDT)
	While !Eof() .And. (xFilial("AFC") + cProjeto + cRevisa + cEDT ==;
		AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI)
		
		PmsAFSCalc(dDtIni,dDtFim,cProjeto,cRevisa,AFC->AFC_EDT,cTarefa,nMoeda,@aValor)
		dbSelectArea("AFC")
		dbSkip()
	End
	
ElseIf !Empty(cTarefa)
	dbSelectArea("AFS")
	dbSetOrder(1)
	dbSeek(xFilial("AFS") + cProjeto + cRevisa + cTarefa)
	
	While !Eof() .And. (AFS->AFS_FILIAL+AFS->AFS_PROJET+AFS->AFS_REVISA+AFS->AFS_TAREFA == ;
		xFilial("AFS")+cProjeto+cRevisa+cTarefa)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente verifica os itens cuja TES gera duplicata.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SD2->(dbSetOrder(6))
		If SD2->(dbSeek(xFilial("SD2")+AFS->AFS_COD+AFS->AFS_LOCAL+DTOS(AFS->AFS_EMISSAO)+AFS->AFS_NUMSEQ))
			
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial()+SD2->D2_TES))
			
			If (SF4->F4_DUPLIC == "S") .And. (SF4->F4_MOVPRJ $ "15")
				
				SF2->(dbSetOrder(1))
				SF2->(dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))
				
				dbSelectArea("SD2")
				dbSetOrder(3)
				
				nTotalDup	:= 0
				MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
				dbSelectArea("SD2")
				While !Eof().And. SD2->D2_FILIAL == xFilial("SD2") .And.;
					SD2->D2_DOC     == SF2->F2_DOC .And.;
					SD2->D2_SERIE   == SF2->F2_SERIE .And.;
					SD2->D2_CLIENTE == SF2->F2_CLIENTE .And.;
					SD2->D2_LOJA    == SF2->F2_LOJA
					
					SF4->(dbSetOrder(1))
					SF4->(dbSeek(xFilial()+SD2->D2_TES))
					If (SF4->F4_DUPLIC == "S") .And. (SF4->F4_MOVPRJ $ "15")
						nTotalDup+= SD2->D2_TOTAL
					EndIf
					
					dbSelectArea("SD2")
					dbSkip()
				End
				
				SD2->(dbSetOrder(6))
				SD2->(dbSeek(xFilial("SD2")+AFS->AFS_COD+AFS->AFS_LOCAL+DTOS(AFS->AFS_EMISSAO)+AFS->AFS_NUMSEQ))
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica a existencia de titulos e receber e aplica a proporcao.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SE1")
				dbSetOrder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				cPrefixo := IIf(Empty(SF2->F2_PREFIXO), &(SuperGetMv("MV_1DUPREF")), SF2->F2_PREFIXO)
				cPrefixo := PadR(cPrefixo,Len(SE2->E2_PREFIXO))
				dbSeek(xFilial("SE1") + SD2->D2_CLIENTE + SD2->D2_LOJA + cPrefixo + AFS->AFS_DOC)
				
				While !Eof() .And. (xFilial("SE1") == SE1->E1_FILIAL) .And. (SE1->E1_CLIENTE == SD2->D2_CLIENTE) .And.;
					(SE1->E1_LOJA == SD2->D2_LOJA) .And. (SE1->E1_PREFIXO == cPrefixo) .And. (SE1->E1_NUM == AFS->AFS_DOC)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida o periodo do titulo.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (SE1->E1_VENCREA >= dDtIni) .And. (SE1->E1_VENCREA <= dDtFim)
						nValor   := ((SD2->D2_TOTAL / nTotalDup) * SE1->E1_VALOR)
						nPosVenc := aScan(aValor,{|x| x[1] == SE1->E1_VENCREA})
						If nPosVenc > 0
							aValor[nPosVenc][2] += xMoeda(nValor,1,nMoeda,SE1->E1_VENCREA)
						Else
							aAdd(aValor,{SE1->E1_VENCREA,xMoeda(nValor,1,nMoeda,SE1->E1_VENCREA),0,0,0,0,0,0,0})
						EndIf
					EndIf
					
					dbSelectArea("SE1")
					dbSkip()
				End
			EndIf
		EndIf
		
		dbSelectArea("AFS")
		dbSkip()
	End
EndIf

aValor:= ASORT(aValor,,, { |x, y| x[1] < y[1] })

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAFNCalc³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 10/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o valor das notas da EDT/Tarefa                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsAFNCalc(dDtIni,dDtFim,cProjeto,cRevisa,cEDT,cTarefa,nMoeda,aValor)
Local nPosVenc  := 0
Local aArea	    := GetArea()
Local aAreaAFC  := AFC->(GetArea())
Local aAreaAF9  := AF9->(GetArea())
Local cPrefixo  := ""
DEFAULT dDtIni  := dDatabase
DEFAULT dDtFim  := dDatabase
DEFAULT cEDT    := ""
DEFAULT cTarefa := ""
DEFAULT cProjeto:= ""
DEFAULT cRevisa := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa todas as notas e titulos da tarefa.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa todos os titulos das tarefas da EDT. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cEDT)
	dbSelectArea("AF9")
	dbSetOrder(2)
	dbSeek(xFilial("AF9") + cProjeto + cRevisa + cEDT,.T.)
	While !Eof() .And. (AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI == ;
		xFilial("AF9") + cProjeto + cRevisa + cEDT)
		
		dbSelectArea("AFN")
		dbSetOrder(1)
		dbSeek(xFilial("AFN") + cProjeto + cRevisa + AF9->AF9_TAREFA)
		
		While !Eof() .And. (AFN->AFN_FILIAL+AFN->AFN_PROJET+AFN->AFN_REVISA+AFN->AFN_TAREFA == ;
			xFilial("AFN")+cProjeto+cRevisa+AF9->AF9_TAREFA)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Somente verifica os itens cuja TES gera duplicata.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			SD1->(dbSeek(xFilial("SD1") + AFN->AFN_DOC + AFN->AFN_SERIE + AFN->AFN_FORNEC + AFN->AFN_LOJA))
			
			SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
			SF1->(dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))

			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4") + SD1->D1_TES))
			
			If (SF4->F4_DUPLIC == "S")
				dbSelectArea("SE2")
				dbSetOrder(6) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
				cPrefixo := IIf(Empty(SF1->F1_PREFIXO), &(SuperGetMv("MV_2DUPREF")), SF1->F1_PREFIXO)
				cPrefixo := PadR(cPrefixo,Len(SE2->E2_PREFIXO))
				dbSeek(xFilial("SE2") + SD1->D1_FORNECE + SD1->D1_LOJA + cPrefixo + AFN->AFN_DOC)
				
				While !Eof() .And. (xFilial("SE2") == SE2->E2_FILIAL) .And. (SE2->E2_FORNECE == SD1->D1_FORNECE) .And.;
					(SE2->E2_LOJA == SD1->D1_LOJA) .And. (SE2->E2_PREFIXO == cPrefixo) .And. (SE2->E2_NUM == AFN->AFN_DOC)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida o periodo do titulo.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (SE2->E2_VENCREA >= dDtIni) .And. (SE2->E2_VENCREA <= dDtFim)
						nPosVenc := aScan(aValor,{|x| x[1] == SE2->E2_VENCREA})
						If nPosVenc > 0
							aValor[nPosVenc][3] += xMoeda(SE2->E2_VALOR,1,nMoeda,SE2->E2_VENCREA)
						Else
							aAdd(aValor,{SE2->E2_VENCREA,xMoeda(SE2->E2_VALOR,1,nMoeda,SE2->E2_VENCREA),0,0,0,0,0,0,0})
						EndIf
					EndIf
					
					dbSelectArea("SE2")
					dbSkip()
				End
			EndIf
			
			dbSelectArea("AFN")
			dbSkip()
		End
		
		dbSelectArea("AF9")
		dbSkip()
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula as EDT`s filhas se existir.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFC")
	dbSetOrder(2)
	dbSeek(xFilial("AFC") + cProjeto + cRevisa + cEDT)
	While !Eof() .And. (xFilial("AFC") + cProjeto + cRevisa + cEDT ==;
		AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI)
		
		PmsAFNCalc(dDtIni,dDtFim,cProjeto,cRevisa,AFC->AFC_EDT,cTarefa,nMoeda,@aValor)
		dbSelectArea("AFC")
		dbSkip()
	End
	
ElseIf !Empty(cTarefa)
	dbSelectArea("AFN")
	dbSetOrder(1)
	dbSeek(xFilial("AFN") + cProjeto + cRevisa + cTarefa)
	
	While !Eof() .And. (AFN->AFN_FILIAL+AFN->AFN_PROJET+AFN->AFN_REVISA+AFN->AFN_TAREFA == ;
		xFilial("AFN")+cProjeto+cRevisa+cTarefa)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente verifica os itens cuja TES gera duplicata.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SD1->(dbSetOrder(1))
		SD1->(dbSeek(xFilial("SD1") + AFN->AFN_DOC + AFN->AFN_SERIE + AFN->AFN_FORNEC + AFN->AFN_LOJA))
		
		SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		SF1->(dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))

		SF4->(dbSetOrder(1))
		SF4->(dbSeek(xFilial("SF4") + SD1->D1_TES))
		
		If (SF4->F4_DUPLIC == "S")
			dbSelectArea("SE2")
			dbSetOrder(6) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
			cPrefixo := IIf(Empty(SF1->F1_PREFIXO), &(SuperGetMv("MV_2DUPREF")), SF1->F1_PREFIXO)
			cPrefixo := PadR(cPrefixo,Len(SE2->E2_PREFIXO))
			dbSeek(xFilial("SE2") + SD1->D1_FORNECE + SD1->D1_LOJA + cPrefixo + AFN->AFN_DOC)
			While !Eof() .And. (xFilial("SE2") == SE2->E2_FILIAL) .And. (SE2->E2_FORNECE == SD1->D1_FORNECE) .And.;
				(SE2->E2_LOJA == SD1->D1_LOJA) .And. (SE2->E2_PREFIXO == cPrefixo) .And. (SE2->E2_NUM == AFN->AFN_DOC)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida o periodo do titulo.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (SE2->E2_VENCREA >= dDtIni) .And. (SE2->E2_VENCREA <= dDtFim)
					nPosVenc := aScan(aValor,{|x| x[1] == SE2->E2_VENCREA})
					If nPosVenc > 0
						aValor[nPosVenc][3] += xMoeda(SE2->E2_VALOR,1,nMoeda,SE2->E2_VENCREA)
					Else
						aAdd(aValor,{SE2->E2_VENCREA,xMoeda(SE2->E2_VALOR,1,nMoeda,SE2->E2_VENCREA),0,0,0,0,0,0,0})
					EndIf
				EndIf
				
				dbSelectArea("SE2")
				dbSkip()
			End
		EndIf
		
		dbSelectArea("AFN")
		dbSkip()
	End
EndIf

aValor:= ASORT(aValor,,, { |x, y| x[1] < y[1] })

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms100Flx³ Autor ³ Edson Maricate         ³ Data ³ 16/08/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe o Fluxo de Caixa do Projeto                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pmc100Flx(oTree,cArquivo)
Local nPeriodo     := 0
Local aDias        := {1,7,10,15,30}
Local nQtdePer     := 0
Local cAlias       := ""
Local nRecView     := 0
Local aHandle      := {}
Local aFluxo       := {}
Local nDias        := 0
Local nTotRec      := 0
Local nTotDesp     := 0
Local nDespAnt     := 0
Local nReceAnt     := 0
Local nSaldo       := 0
Local nSaldoAcm    := 0
Local nSaldoDia    := 0
Local nEntradasDia := 0
Local nEntradasAcum:= 0
Local nSaidasDia   := 0
Local nSaidasAcum  := 0
Local nX           := 0
Local aArrayFlx    := {}
Local aSize        := {}
Local aObjects     := {}
Local aInfo        := {}
Local aPosObj      := {}
Local aGrafFluxo   := {}
Local aPeriodos    := {	STR0169,; //"Diario"
						STR0170,; //"Semanal"
						STR0171,; //"Decendial"
						STR0172,; //"Quinzenal"
						STR0173} //"Mensal"
						
Local aPeriodos2 	:= {STR0162,; //"1=Diario"
						STR0163,; //"2=Semanal"
						STR0164,; //"3=Decendial"
						STR0165,; //"4=Quinzenal"
						STR0166} //"5=Mensal"
Local aConsideraAnt := {"1="+STR0069 , "2="+STR0068} //{"1=Não","2=Sim"}
Local oDlg
Local dDataTrab
Local dRet_1_Ant  := dDataBase
Local nRestPer    := 0
Local nDiasTot    := 0
Local dData       := 0
Local nMes        := 0
Local nQtdDias    := 0
Local nI          := 0
Local aPergPer    := {}
Local aMoedas     := {}
Local nMoedas     := MoedFin()
Local aPergs
Local aAnaArrayTrb := {}
Local sHeadTReport := ""
Local aMv_Par      := {}
Local dDataAux
Local aAux         := {}
Local aTitAntec    := {}
Local nValAux      := 0
Local nReceAntDia  := 0
Local nDespAntDia  := 0
Local nDespAtr     := 0
Local nReceAtr     := 0

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

If ! (cAlias $ "AFC|AF9")
	Aviso(STR0115,STR0116,{STR0117},2) //"Atencao!"###"Selecao invalida. Selecione uma EDT ou uma Tarefa." //'Ok'
	Return
EndIf

For nX := 1 to nMoedas
	aAdd(aMoedas,GetMV("MV_SIMB"+AllTrim(Str(nX,2,0))))
Next nX
aPergs := {  {1,STR0001,dDataBase,"","","","",55,.T.};              //"Data de Referencia"
            ,{3,STR0002, 1,aMoedas,50,"",.F.} ;                     //"Visualizar valores em
            ,{2,STR0167, 1,aPeriodos2,80,"",.F.} ;                  //"Periodo"
            ,{1,STR0168,30,"@E 999","Mv_Par02 > 0","","",55,.T.} ;  //"Qtde.Dias"
            ,{2,STR0200, 1,aConsideraAnt,80,"",.F.} ;               //Acumular Antecipados
           }
			    
If GetNewPar('MV_PMSCCT','1') == '2'  
  AAdd(aPergs,{1,"Frente ","               ","@!","Vazio() .Or. ExistCpo('LJM')","LJM",".T.",50,.F.})
Endif
If !ParamBox(aPergs;//Altera pelo Template de CCT
				,STR0003,@aPergPer)  //"Parametros"
	Return
EndIf

aPergPer[5] := If(ValType(aPergPer[5])=="N",aPergPer[5],Val(aPergPer[5]))
nPeriodo    := If(ValType(aPergPer[3])=="N",aPergPer[3],Val(aPergPer[3]))
nDiasTot    := aPergPer[4]
nDias       := aDias[nPeriodo]

//array utilizado para os parametros do PMSR180
dDataAux := aPergPer[1] + aPergPer[4]
aMv_Par  := {AF8->AF8_PROJET,AF8->AF8_PROJET,aPergPer[1],dDataAux,aPergPer[4],nPeriodo}

If (nPeriodo <> 5)
	If nDiasTot < nDias
		nQtdePer := 0
		nRestPer := nDiasTot
		nDias    := nDiasTot
	Else
		nQtdePer := Int(nDiasTot / nDias)
		nRestPer := nDiasTot - (nQtdePer * nDias)
	Endif
	
	// Gera os registros para todas as datas do periodo, inclusive a database
	dDataTrab:= aPergPer[1]
	For nX := 1 To nQtdePer
		If (Ascan(aArrayFlx, {|e|e[DTINICIAL]==dDataTrab}) == 0)
			Aadd(aArrayFlx, {dDataTrab,(dDataTrab + nDias - 1),PMC100DescPer(dDataTrab, nDias),0,0,0,0,0,0,0,0,0,0})
		Endif
		
		dDataTrab += nDias
	Next nX
	
	// calcula o restante do periodo, se houver
	If nRestPer > 0
		If (Ascan(aArrayFlx, {|e|e[DTINICIAL]==dDataTrab}) == 0)
			Aadd(aArrayFlx, {dDataTrab,(dDataTrab+nRestPer),PMC100DescPer(dDataTrab, nRestPer),0,0,0,0,0,0,0,0,0,0})
		Endif
	EndIf
	
Else

	nQtdDias  := 0
	dDataTrab := aPergPer[1]
	nMes      := Month(dDataTrab)
	For dData:= aPergPer[1] To aPergPer[1]+nDiasTot
		If (nMes <> Month(dData))
			nQtdePer++
			nMes     := Month(dData)
			
			If (Ascan(aArrayFlx, {|e|e[DTINICIAL]==dDataTrab}) == 0)
				Aadd(aArrayFlx, {dDataTrab,(dDataTrab+nQtdDias-1),PMC100DescPer(dDataTrab, nDias),0,0,0,0,0,0,0,0,0,0})
				dDataTrab+= nQtdDias
				nQtdDias:= 0
			EndIf
		EndIf
		
		nQtdDias++
	Next dData
	
	If (nQtdDias > 0)
		If (Ascan(aArrayFlx, {|e|e[DTINICIAL]==dDataTrab}) == 0)
			Aadd(aArrayFlx, {dDataTrab,(dDataTrab+nQtdDias),PMC100DescPer(dDataTrab, nDias),0,0,0,0,0,0,0,0,0,0})
		EndIf
	EndIf
EndIf

Do Case
	Case cAlias=="AFC"
		aHandle := PmsIniFin(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,.T.,aPergPer[2],,aAnaArrayTrb)
		aFluxo  := PmsRetFinVal(aHandle,4,AFC->AFC_EDT)
		sHeadTReport := STR0020 + AFC->AFC_PROJET +"    "+ STR0022+AFC->AFC_EDT  //"Projeto - "+" EDT : "
	Case cAlias=="AF9"
		aHandle := PmsIniFin(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_EDTPAI,.T.,aPergPer[2],,aAnaArrayTrb)
		aFluxo  := PmsRetFinVal(aHandle,3,AF9->AF9_TAREFA)
		sHeadTReport := STR0020 + AF9->AF9_PROJET +"    "+ STR0021 + AF9->AF9_TAREFA //"Projeto - "+" Tarefa : "
		For nX := 1 to Len(aAnaArrayTrb)
			If aAnaArrayTrb[nX,1] == AF9->AF9_TAREFA
				aAdd(aAux,aAnaArrayTrb[nX])
			EndIf
		Next nX
		aAnaArrayTrb := aAux
EndCase

//calcula o saldo da despesa atrasada(nDespAtr) e receita atrasasa(nReceAtr)
For nI:= 1 To Len(aAnaArrayTrb)
	Do Case
		Case (aAnaArrayTrb[nI,3]=="PEDIDO DE COMPRA") .And. (aAnaArrayTrb[nI,2]<dDataBase)
			nDespAtr += aAnaArrayTrb[nI,7]
		Case (aAnaArrayTrb[nI,3]=="TITULO PAGAR") .And. (aAnaArrayTrb[nI,2]<dDataBase)
			If !(AllTrim(aAnaArrayTrb[nI,8])=="PA")
				nDespAtr += aAnaArrayTrb[nI,11]
			EndIf
		Case (aAnaArrayTrb[nI,3]=="DOCUMENTO ENTRADA") .And. (aAnaArrayTrb[nI,2]<dDataBase)
			nDespAtr += aAnaArrayTrb[nI,11]
		Case (aAnaArrayTrb[nI,3]=="PEDIDO DE VENDA") .And. (aAnaArrayTrb[nI,2]<dDataBase)
			nReceAtr += aAnaArrayTrb[nI,7]
		Case (aAnaArrayTrb[nI,3]=="TITULO RECEBER") .And. (aAnaArrayTrb[nI,2]<dDataBase)
			If !(AllTrim(aAnaArrayTrb[nI,8])=="RA")
				nReceAtr += aAnaArrayTrb[nI,11]
			EndIf
		Case (aAnaArrayTrb[nI,3]=="NOTA FISCAL") .And. (aAnaArrayTrb[nI,2]<dDataBase)
			nReceAtr += aAnaArrayTrb[nI,11]
	EndCase
Next nI

//calcula o saldo da despesa antecipada(nDespAnt)
For nI:= 1 To Len(aFluxo[2])
	If aFluxo[2,nI,3] > 0 //a posicao 3 deste array eh o valor acumulado de despesa antecipada
		nDespAnt += aFluxo[2,nI,3]
		If aPergPer[5]==2 //Acumular Antecipados
			aAdd(aTitAntec,{aFluxo[2,nI,1], 'PA', aFluxo[2,nI,3] })
		EndIf
	EndIf
Next nI

//calcula o saldo da receita antecipada(nReceAnt)
For nI:= 1 To Len(aFluxo[5])
	If aFluxo[5,nI,3] > 0 //a posicao 3 deste array eh o valor acumulado de receita antecipada
		nReceAnt += aFluxo[5,nI,3]
		If aPergPer[5]==2 //Acumular Antecipados
			aAdd(aTitAntec,{aFluxo[5,nI,1], 'RA', aFluxo[5,nI,3] })
		EndIf
	EndIf
Next nI

aSort(aFluxo[5],,,{|x,y| x[1]<y[1]} )
aSort(aFluxo[2],,,{|x,y| x[1]<y[1]} )
aSort(aTitAntec,,,{|x,y| x[1]<y[1]} )
aSort(aAnaArrayTrb,,,{|x,y| DtoS(x[2])+x[3] < DtoS(y[2])+y[3] })

//calcula o saldo inicial
nSaldo    := aFluxo[6] - aFluxo[3] // Receita - Despesa

//inicio:calcula o fluxo antes da data de refencia
nSaldoAcm := 0
//titulos a pagar
nI := 1
While (nI<=Len(aFluxo[2])) 
	If (aFluxo[2,nI,1]<aArrayFlx[1,DTINICIAL])
		nSaldoAcm -= aFluxo[2,nI,2] + aFluxo[2,nI,3]
		If aPergPer[5]==2  //Acumular Antecipados?1.nao 2.sim
			nValAux   := ValAntec(aFluxo[2,nI,1],aFluxo[2,nI,2],'PA',@aTitAntec)
			nSaldoAcm += nValAux
		EndIf
	EndIf
	nI++
EndDo

//pedidos de compra
nI := 1
While (nI<=Len(aFluxo[1]))
	If (aFluxo[1,nI,1]<aArrayFlx[1,DTINICIAL])
		nSaldoAcm -= aFluxo[1,nI,2]
		If aPergPer[5]==2  //Acumular Antecipados?1.nao 2.sim
			nValAux   := ValAntec(aFluxo[1,nI,1],aFluxo[1,nI,2],'PA',@aTitAntec)
			nSaldoAcm += nValAux
		EndIf
	EndIf
	nI++
EndDo

//titulos a receber
nI := 1
While (nI <= Len(aFluxo[5]))
	If (aFluxo[5,nI,1] < aArrayFlx[1,DTINICIAL])
		nSaldoAcm += aFluxo[5,nI,2] + aFluxo[5,nI,3]
		If aPergPer[5]==2  //Acumular Antecipados?1.nao 2.sim
			nValAux   := ValAntec(aFluxo[5,nI,1],aFluxo[5,nI,2],'RA',@aTitAntec)
			nSaldoAcm -= nValAux
		EndIf
	EndIf
	nI++
EndDo

//pedidos de venda
nI := 1
While (nI <= Len(aFluxo[4]))
	If (aFluxo[4,nI,1] < aArrayFlx[1,DTINICIAL])
		nSaldoAcm += aFluxo[4,nI,2]
		If aPergPer[5]==2  //Acumular Antecipados?1.nao 2.sim
			nValAux   := ValAntec(aFluxo[4,nI,1],aFluxo[4,nI,2],'RA',@aTitAntec)
			nSaldoAcm -= nValAux
		EndIf
	EndIf
	nI++
EndDo

nSaldo := nSaldoAcm
//fim:calcula o fluxo antes da data de refencia

For nX := 1 To Len(aArrayFlx)
	nSaldoDia   := 0
	nReceAntDia := 0
	nDespAntDia := 0
	
	//titulos a pagar
	For nI:= 1 To Len(aFluxo[2])
		If (aFluxo[2,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[2,nI,1] <= aArrayFlx[nX,DTFINAL])
			aArrayFlx[nX,DESPESAS] += aFluxo[2,nI,2]
			If (aFluxo[2,nI,1] >= aPergPer[1]) .And. (aFluxo[2,nI,3]>0)
				aArrayFlx[nX,DESPESAS] += aFluxo[2,nI,3]
				nTotDesp  += aFluxo[2,nI,3]
				nSaldoDia -= aFluxo[2,nI,3]
				If (aFluxo[2,nI,1] >= aPergPer[1])
					nSaldoAcm -= aFluxo[2,nI,3]
				EndIf
			EndIf

			If aFluxo[2,nI,2] > 0
				If aPergPer[5]==2  //Acumular Antecipados?1.nao 2.sim
					nValAux     := ValAntec(aFluxo[2,nI,1],aFluxo[2,nI,2],'PA',@aTitAntec)
					nDespAntDia += nValAux
					nTotDesp    += aFluxo[2,nI,2] - nValAux
					nSaldoDia   -= aFluxo[2,nI,2] - nValAux
					nSaldoAcm   -= aFluxo[2,nI,2] - nValAux
				Else
					nTotDesp    += aFluxo[2,nI,2]
					nSaldoDia   -= aFluxo[2,nI,2]
					nSaldoAcm   -= aFluxo[2,nI,2]
				EndIf
			EndIf
		EndIf
	Next nI

	//pedidos de compra
	For nI:= 1 To Len(aFluxo[1])
		If (aFluxo[1,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[1,nI,1] <= aArrayFlx[nX,DTFINAL])
			aArrayFlx[nX,PEDCOMPRA] += aFluxo[1,nI,2]

			If aFluxo[1,nI,2] > 0
				If aPergPer[5]==2  //Acumular Antecipados?1.nao 2.sim
					nValAux     := ValAntec(aFluxo[1,nI,1],aFluxo[1,nI,2],'PA',@aTitAntec)
					nDespAntDia += nValAux
					nTotDesp    += aFluxo[1,nI,2] - nValAux
					nSaldoDia   -= aFluxo[1,nI,2] - nValAux
					nSaldoAcm   -= aFluxo[1,nI,2] - nValAux
				Else
					nTotDesp    += aFluxo[1,nI,2]
					nSaldoDia   -= aFluxo[1,nI,2]
					nSaldoAcm   -= aFluxo[1,nI,2]
				EndIf
			EndIf

		EndIf
	Next nI

	//titulos a receber
	For nI:= 1 To Len(aFluxo[5])
		If (aFluxo[5,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[5,nI,1] <= aArrayFlx[nX,DTFINAL])
			aArrayFlx[nX,RECEITAS] += aFluxo[5,nI,2]
			If (aFluxo[5,nI,1] >= aPergPer[1]) .And. (aFluxo[5,nI,3]>0)
				aArrayFlx[nX,RECEITAS] += aFluxo[5,nI,3]
				nTotRec   += aFluxo[5,nI,3]
				nSaldoDia += aFluxo[5,nI,3]
				If (aFluxo[5,nI,1] >= aPergPer[1])
					nSaldoAcm += aFluxo[5,nI,3]
				EndIf
			EndIf

			If aFluxo[5,nI,2] > 0
				If aPergPer[5]==2  //Acumular Antecipados?1.nao 2.sim
					nValAux := ValAntec(aFluxo[5,nI,1],aFluxo[5,nI,2],'RA',@aTitAntec)
					nReceAntDia += nValAux
					nTotRec   += aFluxo[5,nI,2] - nValAux
					nSaldoDia += aFluxo[5,nI,2] - nValAux
					nSaldoAcm += aFluxo[5,nI,2] - nValAux
				Else
					nTotRec   += aFluxo[5,nI,2]
					nSaldoDia += aFluxo[5,nI,2]
					nSaldoAcm += aFluxo[5,nI,2]
				EndIf
			EndIf

		EndIf
	Next nI

	//pedidos de venda
	For nI:= 1 To Len(aFluxo[4])
		If (aFluxo[4,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[4,nI,1] <= aArrayFlx[nX,DTFINAL])
			aArrayFlx[nX,PEDVENDA] += aFluxo[4,nI,2]

			If aPergPer[5]==2  //Acumular Antecipados?1.nao 2.sim
				nValAux     := ValAntec(aFluxo[4,nI,1],aFluxo[4,nI,2],'RA',@aTitAntec)
				nReceAntDia += nValAux
				nTotRec     += aFluxo[4,nI,2] - nValAux
				nSaldoDia   += aFluxo[4,nI,2] - nValAux
				nSaldoAcm   += aFluxo[4,nI,2] - nValAux
			Else
				nTotRec     += aFluxo[4,nI,2]
				nSaldoDia   += aFluxo[4,nI,2]
				nSaldoAcm   += aFluxo[4,nI,2]
			EndIf

		EndIf
	Next nI

	nSaidasDia    := aArrayFlx[nX,PEDCOMPRA] + aArrayFlx[nX,DESPESAS] - nDespAntDia
	nEntradasDia  := aArrayFlx[nX,PEDVENDA]  + aArrayFlx[nX,RECEITAS] - nReceAntDia
	nSaidasAcum   += nSaidasDia
	nEntradasAcum += nEntradasDia
	
	aArrayFlx[nX,SALDODIA]     := nSaldoDia
	aArrayFlx[nX,VARIACAODIA]  := (nSaidasDia/nEntradasDia) * 100
	aArrayFlx[nX,SAIDASACUM]   := nSaidasAcum
	aArrayFlx[nX,ENTRADASACUM] := nEntradasAcum
	aArrayFlx[nX,VARIACAOACUM] := (nSaidasAcum/nEntradasAcum) * 100
	aArrayFlx[nX,SALDOACUM]    := nSaldoAcm
	
Next nX

aGrafFluxo := aClone(aArrayFlx)

aSize := MsAdvSize()
aadd( aObjects, {  30,  70, .T., .T.} )
aadd( aObjects, {  20, 180, .T., .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE STR0084 FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL OF oMainWnd //"Fluxo de Caixa do Projeto"

@  0,  1 TO 48,500 OF oDlg PIXEL

@  6,  6 TO 44,116 PROMPT STR0118 OF oDlg PIXEL  //"Totais no Período"
@  6,120 TO 44,230 PROMPT STR0201 OF oDlg PIXEL  //"Antecipados em Aberto"
@  6,234 TO 44,344 PROMPT STR0199 OF oDlg PIXEL  //"Valores Atrasados"
@  6,348 TO 44,458 PROMPT STR0119 OF oDlg PIXEL  //"Saldos"

@ 16, 11 SAY STR0082 OF oDlg PIXEL  //"Despesas"
@ 29, 11 SAY STR0081 OF oDlg PIXEL  //"Receitas"
@ 16,125 SAY STR0082 OF oDlg PIXEL  //"Despesas"
@ 29,125 SAY STR0081 OF oDlg PIXEL  //"Receitas"
@ 16,239 SAY STR0082 OF oDlg PIXEL  //"Despesas"
@ 29,239 SAY STR0081 OF oDlg PIXEL  //"Receitas"
@ 16,353 SAY STR0120 OF oDlg PIXEL  //"Saldo Inicial"
@ 29,353 SAY STR0121 OF oDlg PIXEL  //"Saldo Final"

@ 14, 58 MSGET nTotDesp  SIZE 55,10 OF oDlg WHEN .F. PICTURE "@E 999,999,999,999.99" PIXEL
@ 29, 58 MSGET nTotRec   SIZE 55,10 OF oDlg WHEN .F. PICTURE "@E 999,999,999,999.99" PIXEL
@ 14,172 MSGET nDespAnt  SIZE 55,10 OF oDlg WHEN .F. PICTURE "@E 999,999,999,999.99" PIXEL
@ 29,172 MSGET nReceAnt  SIZE 55,10 OF oDlg WHEN .F. PICTURE "@E 999,999,999,999.99" PIXEL
@ 14,286 MSGET nDespAtr  SIZE 55,10 OF oDlg WHEN .F. PICTURE "@E 999,999,999,999.99" PIXEL
@ 29,286 MSGET nReceAtr  SIZE 55,10 OF oDlg WHEN .F. PICTURE "@E 999,999,999,999.99" PIXEL
@ 14,400 MSGET nSaldo    SIZE 55,10 OF oDlg WHEN .F. PICTURE "@E 999,999,999,999.99" PIXEL
@ 29,400 MSGET nSaldoAcm SIZE 55,10 OF oDlg WHEN .F. PICTURE "@E 999,999,999,999.99" PIXEL

@ 08,463 BUTTON STR0127 SIZE 32, 11 OF oDlg PIXEL ACTION PMSGrafFlx(oDlg,aGrafFluxo,aPergPer[2],aPeriodos[nPeriodo]) //"Grafico"
@ 32,463 BUTTON STR0125 SIZE 32, 11 OF oDlg PIXEL ACTION oDlg:End() //"Fechar"
@ 20,463 BUTTON STR0126 SIZE 32, 11 OF oDlg PIXEL ACTION PMSR180(aArrayFlx,{nTotDesp,nTotRec,nSaldo,nSaldoAcm,nDespAnt,nReceAnt},aMv_Par) //"Imprimir"

//Periodo,Valor Ped.Compra,Despesas,Despesas Acumuladas,Valor Ped.Venda,Receitas,Receitas Acumuladas,Saldo Dia,Var.Dia,Saidas Acumuladas,Entradas Acumuladas,Saldo Acumulado,Var.Acumulada
@ aPosObj[2,1]-63, aPosObj[2,2] LISTBOX oFluxo FIELDS ;
HEADER STR0122 + " - " + aPeriodos[nPeriodo],STR0123,STR0082,STR0124,STR0081,STR0074,STR0174,STR0175,STR0176,STR0078,STR0177 SIZE aPosObj[2,3],aPosObj[2,4]+60 ;   //"Data"###"Vlr.Prev.PC"###"Despesas"###"Vlr.Prev.PV"###"Receitas"###"Saldo do Dia"###"Saldo Acumulado" //"Var.Dia"###"Saidas Acum."###"Entradas Acum."###"Var.Acumu."
OF oDlg ON DBLCLICK ( FluxoAna(aAnaArrayTrb,aArrayFlx[oFluxo:nAt,3],aArrayFlx[oFluxo:nAt,1],aArrayFlx[oFluxo:nAt,2],sHeadTReport)) PIXEL //"Não foi selecionado Processa analitico! Impossivel consultar."

oFluxo:SetArray(aArrayFlx)
oFluxo:bLine := { || {	xPadC(aArrayFlx[oFluxo:nAT][PERIODO],45),;
								Transform(aArrayFlx[oFluxo:nAT][PEDCOMPRA]   ,"@e 999,999,999,999.99"),;
								Transform(aArrayFlx[oFluxo:nAT][DESPESAS]    ,"@e 999,999,999,999.99"),;
								Transform(aArrayFlx[oFluxo:nAT][PEDVENDA]    ,"@e 999,999,999,999.99"),;
								Transform(aArrayFlx[oFluxo:nAT][RECEITAS]    ,"@e 999,999,999,999.99"),;
								Transform(aArrayFlx[oFluxo:nAT][SALDODIA]    ,"@e 999,999,999,999.99"),;
								Transform(aArrayFlx[oFluxo:nAT][VARIACAODIA] ,"@e 9999.99%"),;
								Transform(aArrayFlx[oFluxo:nAT][SAIDASACUM]  ,"@e 999,999,999,999.99"),;
								Transform(aArrayFlx[oFluxo:nAT][ENTRADASACUM],"@e 999,999,999,999.99"),;
								Transform(aArrayFlx[oFluxo:nAT][SALDOACUM]   ,"@e 999,999,999,999.99"),;
								Transform(aArrayFlx[oFluxo:nAT][VARIACAOACUM],"@e 9999.99%")}}
ACTIVATE MSDIALOG oDlg

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ValAntec  ³ Autor ³Daniel Tadashi Batori   ³ Data ³ 21/06/2007    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Utilizada no fluxo do projeto se a pergunta "Acumular Antecipados"³±±
±±³          ³estiver "Sim".                                                    ³±±
±±³          ³Retorna o valor que sera compensado no registro do fluxo.         ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dData : data do valor da receita/despesa                          ³±±
±±³          ³nValor : valor a ser procurado nos antecipados                    ³±±
±±³          ³cTipo : tipo do valor (PA/RA)                                     ³±±
±±³          ³aTitAntec : array dos titulos antecipados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValAntec(dData,nValor,cTipo,aTitAntec)
Local nPos        := 0
Local nCompensado := 0

nPos := aScan(aTitAntec,{|x| x[1]<=dData .And. x[2]==cTipo .And. x[3]>0 })
While (nPos > 0) .And. !(nValor==0)
	If aTitAntec[nPos,3] >= nValor
		nCompensado       += nValor
		aTitAntec[nPos,3] -= nValor
		nValor            := 0
	Else
		nValor            -= aTitAntec[nPos,3]
		nCompensado       += aTitAntec[nPos,3]
		aTitAntec[nPos,3] := 0
	EndIf
	nPos := aScan(aTitAntec,{|x| x[1]<=dData .And. x[2]==cTipo .And. x[3]>0 })
EndDo

Return nCompensado

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PMSGrafFlx³ Autor ³Adriano Ueda            ³ Data ³ 18/11/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grafico do Fluxo de Caixa no PMS                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMSGrafFlx(oDlg,aFluxo,nMoeda,cTit)
Local oDlgSer
Local oSer
Local oVisual
Local cCbx := STR0088
Local cVisual := STR0130 //"Projecao do Saldo"
Local nCbx := 1
Local aCbx := { STR0088,; //"1=Linha"
                STR0089,; //"2=Area"
                STR0090,; //"3=Pontos"
                STR0091,; //"4=Barra"
                STR0099}  //"5=Linha Rapida"
Local aTpGrafico:= {  1; //"1=Linha"
					, 2; //"2=Area"
					, 3; //"3=Pontos"
					, 4; //"4=Barra"
					,12} //"5=Linha Rapida"
Local aVisual := {STR0145, STR0130} //"Receitas x Despesas"###"Projecao do Saldo"
Local nVisual := 2

DEFINE MSDIALOG oDlgSer TITLE STR0146 FROM 0,0 TO 100,280 PIXEL OF oDlg //"Tipo do graficos"

@ 008, 005 SAY STR0147 PIXEL OF oDlgSer //"Escolha o tipo de serie:"
@ 008, 063 MSCOMBOBOX oSer VAR cCbx ITEMS aCbx SIZE 077, 120 OF oDlgSer PIXEL ON CHANGE nCbx := oSer:nAt
@ 022, 005 SAY STR0148 PIXEL OF oDlgSer //"Tipo de Visualizacao   :"
@ 022, 063 MSCOMBOBOX oVisual VAR cVisual ITEMS aVisual SIZE 077, 120 OF oDlgSer PIXEL ON CHANGE nVisual := oVisual:nAt
oVisual:cSX1Hlp := "PMSC1001"
@ 035, 045 BUTTON STR0149 SIZE 30,12 OF oDlgSer PIXEL ACTION PMSMonGraf(aFluxo,aTpGrafico[nCbx],nVisual,nMoeda,cTit) //"&Ok"
@ 035, 075 BUTTON STR0150 SIZE 30,12 OF oDlgSer PIXEL ACTION oDlgSer:End() //"&Sair"

ACTIVATE MSDIALOG oDlgSer CENTER

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PMSMonGraf³ Autor ³Adriano Ueda            ³ Data ³ 18/11/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta o Grafico do Fluxo de Caixa no PMS                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PMSMonGraf(aFluxo,nCbx,nVisual,nMoeda,cTit)
Local oDlg
Local obmp
Local oBold
Local oGraphic
Local nSerie		:= 0
Local nSerie2		:= 0
Local aArea			:= GetArea()
Local aTabela
Local nX 			:= 0

//Periodo,Valor Ped.Compra,Despesas,Valor Ped.Venda,Receitas,Saldo Dia,Var.Dia,Saidas Acumuladas,Entradas Acumuladas,Saldo Acumulado,Var.Acumulada
aTabela := {{ STR0122 + " - " + cTit,STR0123,STR0082,STR0124,STR0081,STR0074,STR0174,STR0175,STR0176,STR0078,STR0177 }}

For nX := 1 To Len(aFluxo)
	Aadd(aTabela,{	Pad(Transform(aFluxo[nX,PERIODO],""),17),;
	Transform(aFluxo[nX,PEDCOMPRA]	,"@e 999,999,999,999.99"),;
	Transform(aFluxo[nX,DESPESAS],"@e 999,999,999,999.99"),;
	Transform(aFluxo[nX,PEDVENDA],"@e 999,999,999,999.99"),;
	Transform(aFluxo[nX,RECEITAS],"@e 999,999,999,999.99"),;
	Transform(aFluxo[nX,SALDODIA],"@e 999,999,999,999.99"),;
	Transform(aFluxo[nX,VARIACAODIA],"@e 9999.99%"),;
	Transform(aFluxo[nX,SAIDASACUM],"@e 999,999,999,999.99"),;
	Transform(aFluxo[nX,ENTRADASACUM],"@e 999,999,999,999.99"),;
	Transform(aFluxo[nX,SALDOACUM],"@e 999,999,999,999.99"),;
	Transform(aFluxo[nX,VARIACAOACUM],"@e 9999.99%")})
Next

DEFINE MSDIALOG oDlg FROM 0,0 TO 450,700 PIXEL TITLE STR0152 //"Representacao grafica do Fluxo de Caixa"
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

// Layout da janela
@ 000, 000 BITMAP oBmp RESNAME BMP_PROJETOAP oF oDlg SIZE 50, 250 NOBORDER WHEN .F. PIXEL
@ 003, 060 SAY STR0153 + If( nVisual == 1, STR0145, STR0154) FONT oBold PIXEL //"Fluxo de Caixa - "###"Receitas x Despesas"###"Projecao de Saldo"

@ 014, 050 TO 16 ,400 LABEL '' OF oDlg PIXEL

@ 014, 050 TO 16 ,400 LABEL '' OF oDlg PIXEL

@ 020, 055 MSGRAPHIC oGraphic SIZE 285, 158 OF oDlg PIXEL
oGraphic:SetMargins( 2, 6, 6, 6 )

// Habilita a legenda, apenas se houver mais de uma serie de dados.
oGraphic:SetLegenProp( GRP_SCRTOP, CLR_YELLOW, GRP_SERIES, .F.)
nSerie  := oGraphic:CreateSerie(nCbx)

// Adiciona mais uma serie de dados, conforme o tipo do grafico
If nVisual == 1 // Contas a Pagar x Contas a Receber
	nSerie2 := oGraphic:CreateSerie(nCbx)
	@ 185, 57 SAY STR0081 OF oDlg COLOR CLR_HBLUE FONT oBold PIXEL //"Receitas"
	@ 195, 57 SAY STR0082 OF oDlg COLOR CLR_HRED  FONT oBold PIXEL //"Despesas"
Endif

If nSerie != GRP_CREATE_ERR .And. nSerie2 != GRP_CREATE_ERR
	
	aEval(aFluxo,{|e|If(nVisual==1,(oGraphic:Add(nSerie ,e[RECEITAS],Transform(e[PERIODO],""),CLR_HBLUE),;
	oGraphic:Add(nSerie2,e[DESPESAS]  ,Transform(e[PERIODO],""),CLR_HRED)),;
	oGraphic:Add(nSerie ,e[SALDOACUM]    ,Transform(e[PERIODO],""),If(e[SALDOACUM]<0,CLR_HRED,CLR_HBLUE)))})
Else
	IW_MSGBOX(STR0155, "Atencao", "STOP") //"Nao foi possivel criar a serie"
Endif

oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
oGraphic:SetTitle( GetMv("MV_SIMB"+Alltrim(Str(nMoeda,2))),"", CLR_HRED , A_LEFTJUST , GRP_TITLE )
oGraphic:SetTitle( "", cTit, CLR_GREEN, A_RIGHTJUS , GRP_FOOT  ) //"Datas"

@ 190, 254 BUTTON o3D PROMPT STR0156 SIZE 40,14 OF oDlg PIXEL ACTION (oGraphic:l3D := !oGraphic:l3D, o3d:cCaption := If(oGraphic:l3D, STR0156, STR0157)) //"&2D"###"&2D"###"&3D"
@ 190, 295 BUTTON STR0158 SIZE 40,14 OF oDlg PIXEL ACTION GrafSavBmp( oGraphic ) //"Salvar BMP"
@ 190, 170 BUTTON STR0159 SIZE 40,14 OF oDlg WHEN oGraphic:l3D PIXEL ACTION oGraphic:ChgRotat( nSerie, 1, .T. ) // nRotation tem que estar entre 1 e 30 passos //"Rotacao &-"
@ 190, 212 BUTTON STR0160 SIZE 40,14 OF oDlg WHEN oGraphic:l3D PIXEL ACTION oGraphic:ChgRotat( nSerie, 1, .F. ) // nRotation tem que estar entre 1 e 30 passos //"Rotacao &+"

@ 207, 050 TO 209 ,400 LABEL '' OF oDlg  PIXEL
If !__lPyme
	@ 213, 254 BUTTON STR0161 SIZE 40,12 OF oDlg PIXEL ACTION PmsGrafMail(oGraphic,STR0119,{STR0153 + If( nVisual == 1, STR0145, STR0154)},aTabela,1) //"E-Mail"###"Saldos"###"Fluxo de caixa -"###"Receitas x Despesas"###"Projecao de Saldo"
Endif
@ 213, 295 BUTTON STR0150 SIZE 40,12 OF oDlg PIXEL ACTION oDlg:End() //"&Sair"

ACTIVATE MSDIALOG oDlg CENTER
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ PMC100Desc ºAutor  ³ Adriano            º Data ³  21/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Devolve a descricao do periodo a partir de uma data e o numeroº±±
±±º          ³de dias                            								            º±±
±±º          ³                                                           		º±±
±±º          ³Parametros:                                                		º±±
±±º          ³dDataIniPer - data de inicio do periodo                       º±±
±±º          ³nPeriodo    - numero de dias do periodo, incluido a data de   º±±
±±º          ³              inicio                                          º±±
±±º          ³                                                              º±±
±±º          ³              01 - Diario                                     º±±
±±º          ³              07 - Semanal                                    º±±
±±º          ³              10 - Decendial                                  º±±
±±º          ³              15 - Quinzenal                                  º±±
±±º          ³              30 - Mensal                                     º±±
±±º          ³              xx - Numero arbitrario de dias                  º±±
±±º          ³                                                              º±±
±±º          ³              valores <= 0 sao ignorados                      º±±
±±º          ³Retorno:                                                    	º±±
±±º          ³  string contendo a descricao do periodo                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSR180                                                   		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMC100DescPer(dDataIniPer, nPeriodo)
Local cDesc := ""

If nPeriodo > 0
	Do Case
		Case nPeriodo == 1  // Diario
			cDesc := Dtoc(dDataIniPer)
			
		Case nPeriodo == 7  // Semanal
			cDesc := Left(Dtoc(dDataIniPer),5)+ " a " + Left(Dtoc(dDataIniPer+6),5) //" a "
			
		Case nPeriodo == 10 // Decendial
			cDesc := Left(Dtoc(dDataIniPer),5)+ " a " + Left(Dtoc(dDataIniPer+9),5) //" a "
			
		Case nPeriodo == 15 // Quinzenal
			cDesc := Left(Dtoc(dDataIniPer),5)+ " a " + Left(Dtoc(dDataIniPer+14),5) //" a "
			
		Case nPeriodo == 30 // Mensal
			cDesc := MesExtenso(Month(dDataIniPer)) + "/" + AllTrim(Str(Year(dDataIniPer))) // mes
			
		Otherwise           // Qualquer periodo arbitrario, considerado em dias
			cDesc := Left(Dtoc(dDataIniPer),5)+ " a " + Left(Dtoc(dDataIniPer+(nPeriodo-1)),5)  //" a "
	EndCase
EndIf
Return cDesc

Function CTTrfIsFrt(cFrt)
	LL1->(DbSetOrder(1))
	Return LL1->(DbSeek(xFilial("LL1")+ AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA+cFrt))
Return 


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
Local aRotina 	:= {	{ STR0005 ,"AxPesqui"   ,0 ,1 },; // //"Pesquisar"
								{ STR0006 ,"PMSC100Dlg" ,0 ,2 },; // //"Pgr.F&inanceiro"
								{ STR0110 ,"PMSC100Dlg" ,0 ,2 },; // //"Pgr.&Fisico"
								{ STR0007 ,"PMSC100Dlg" ,0 ,2 },; // //"An.Execucao"
								{ STR0008 ,"PMSC100Dlg" ,0 ,2 },; // //"Graf.Vlr.Ganho"
								{ STR0010 ,"PMSC100Dlg" ,0 ,2 },;  //"Fluxo de Caixa"
								{ STR0183 ,"PMSC130()"  ,0 ,2 },;  //"Rentabilidade"
								{ STR0111 ,"PMSC100Leg" ,0 ,2, ,.F. }} //"Legenda"
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FluxoAna  ³ Autor ³ Daniel Tadashi Batori ³ Data ³23/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aAnaArrayTrb : array com os registros analiticos            ³±±
±±³          ³cPeriodo : periodo a ser detalhado                          ³±±
±±³          ³dDataIni : Data Inicial                                     ³±±
±±³          ³dDataFim : Data Final                                       ³±±
±±³          ³sHeadTReport : string a ser utilizada no header do TReport  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FluxoAna(aAnaArrayTrb,cPeriodo,dDataIni,dDataFim,sHeadTReport)
// Variaveis Locais da Funcao
Local aSize, aObjects := {}, aInfo, aPosObj
Local aButton := {	{BMP_IMPRESSAO,	{|| PMSR370(cPeriodo,aCol1,aCol2,aCol3,aCol4,aCol5,aCol6,aCol7,aCol8,sHeadTReport) }, STR0126 }} //"Imprimir"
Local aCol1   := {}  // Array a ser tratado internamente na MsNewGetDados como aCols
Local aCol2   := {}  // Array a ser tratado internamente na MsNewGetDados como aCols
Local aCol3   := {}  // Array a ser tratado internamente na MsNewGetDados como aCols
Local aCol4   := {}  // Array a ser tratado internamente na MsNewGetDados como aCols
Local aCol5   := {}  // Array a ser tratado internamente na MsNewGetDados como aCols
Local aCol6   := {}  // Array a ser tratado internamente na MsNewGetDados como aCols
Local aCol7  := {}  // Array a ser tratado internamente na MsNewGetDados como aCols
Local aCol8  := {}  // Array a ser tratado internamente na MsNewGetDados como aCols
// Variaveis Private da Funcao
Private oDlg     // Dialog Analitico
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        
Private oFolder
Private aFolder := {STR0189,STR0190,STR0191,STR0208,STR0192,STR0193,STR0194,STR0207} //"Pedidos de Compra","Documentos de Entrada","Títulos a Pagar","Mov.Bancaria a Pagar","Pedidos de Venda","Notas Fiscais","Títulos a Receber","Mov.Bancaria a Receber"
// Privates das NewGetDados
Private oGetDados1 //Pedidos de Compra
Private oGetDados2 //Doc. de Entrada
Private oGetDados3 //Titulos a Pagar
Private oGetDados4 //Mov.Bancaria a Pagar
Private oGetDados5 //Pedidos de Venda
Private oGetDados6 //Notas Fiscais
Private oGetDados7 //Titulos de Venda
Private oGetDados8 //Mov.Bancaria a Receber

aSize := MsAdvSize()
aadd( aObjects, { 100, 100, .T., .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 } 
aPosObj := MsObjSize( aInfo, aObjects )  

DEFINE MSDIALOG oDlg TITLE STR0188+" "+cPeriodo FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL of oMainWnd

oFolder := TFolder():New(aPosObj[1,1],aPosObj[1,2],aFolder,{},oDlg,,,,.T.,.F.,aPosObj[1,3],aPosObj[1,4]-15,)

fGetDados(aAnaArrayTrb, dDataIni, dDataFim, aPosObj,aCol1,aCol2,aCol3,aCol4,aCol5,aCol6,aCol7,aCol8)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg, {|| oDlg:End() }, {|| oDlg:End()},,aButton) )

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fGetDados() ³ Autor ³ Adriano Ueda              ³ Data ³22/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem das GetDados                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³aAnaArrayTrb : array com os registros analiticos                  ³±±
±±³           ³dDataIni : Data Inicial                                           ³±±
±±³           ³dDataFim : Data Final                                             ³±±
±±³           ³aPosObj : array com a posição das GetDados a serem criadas        ³±±
±±³           ³aCol1 := array com os registros de Pedidos de Compra              ³±±
±±³           ³aCol2 : array com os registros de Documentos de Entrada           ³±±
±±³           ³aCol3 : array com os registros de Títulos a Pagar                 ³±±
±±³           ³aCol4 : array com os registros de Mov.Bancaria a Pagar            ³±±
±±³           ³aCol5 : array com os registros de Pedidos de Venda                ³±±
±±³           ³aCol6 : array com os registros de Notas Fiscais                   ³±±
±±³           ³aCol7 : array com os registros de Títulos a Receber               ³±±
±±³           ³aCol8 : array com os registros de Mov.Bancaria a Receber          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao ³ O Objeto oGetDados1 foi criado como Private no inicio do Fonte   ³±±
±±³           ³ desta forma voce podera trata-lo em qualquer parte do            ³±±
±±³           ³ seu programa:                                                    ³±±
±±³           ³                                                                  ³±±
±±³           ³ Para acessar o aCols desta MsNewGetDados: oGetDados1:aCols[nX,nY]³±±
±±³           ³ Para acessar o aHeader: oGetDados1:aHeader[nX,nY]                ³±±
±±³           ³ Para acessar o "n"    : oGetDados1:nAT                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGetDados(aAnaArrayTrb,dDataIni,dDataFim,aPosObj,aCol1,aCol2,aCol3,aCol4,aCol5,aCol6,aCol7,aCol8)
// Variaveis deste Form                                                                                                         
Local nX     := 0
Local oSayTotal
Local oGetTotal
Local nTotal := 555
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Vetor responsavel pela montagem da aHeader
Local aCpoGDa1 := {"C7_DATPRF","C7_FILIAL","C7_NUM","C7_ITEM","C7_TOTAL"}
Local aCpoGDa2 := {"E2_VENCREA","D1_FILIAL","D1_DOC",SerieNfId("SD1",3,"D1_SERIE"),"D1_ITEM","D1_COD","D1_TOTAL","D1_FORNECE","D1_LOJA"}
Local aCpoGDa3 := {"E2_VENCREA","E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA","E2_VALOR"}
Local aCpoGDa4 := {"E5_DTDISPO","E5_MOEDA","E5_NATUREZ","E5_BANCO","E5_AGENCIA","E5_CONTA","AJE_VALOR"}
Local aCpoGDa5 := {"C6_ENTREG","C6_FILIAL","C6_NUM","C6_ITEM","C6_VALOR"}
Local aCpoGDa6 := {"E1_VENCREA","D2_FILIAL","D2_DOC",SerieNfId("SD2",3,"D2_SERIE"),"D2_ITEM","D2_COD","D2_TOTAL","D2_CLIENTE","D2_LOJA"}
Local aCpoGDa7 := {"E1_VENCREA","E1_FILIAL","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_CLIENTE","E1_LOJA","E1_VALOR"}
Local aCpoGDa8 := {"E5_DTDISPO","E5_MOEDA","E5_NATUREZ","E5_BANCO","E5_AGENCIA","E5_CONTA","AJE_VALOR"}
Local aTotal   := {0,0,0,0,0,0,0,0}
// Vetor com os campos que poderao ser alterados
Local aAlter   := {""}
// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local nOpc     := 0 //GD_INSERT+GD_DELETE+GD_UPDATE
Local cLinOk   := "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk  := "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos := ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                   // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                   // segundo campo>+..."                                                               
Local nFreeze   := 000             // Campos estaticos na GetDados.                                                               
Local nMax      := 999             // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cFieldOk  := "AllwaysTrue"   // Funcao executada na validacao do campo                                           
Local cSuperDel := ""              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk    := "AllwaysTrue"   // Funcao executada para validar a exclusao de uma linha do aCols                   
Local aHead1    := {}              // Array a ser tratado internamente na MsNewGetDados como aHeader
Local aHead2    := {}              // Array a ser tratado internamente na MsNewGetDados como aHeader
Local aHead3    := {}              // Array a ser tratado internamente na MsNewGetDados como aHeader
Local aHead4    := {}              // Array a ser tratado internamente na MsNewGetDados como aHeader
Local aHead5    := {}              // Array a ser tratado internamente na MsNewGetDados como aHeader
Local aHead6    := {}              // Array a ser tratado internamente na MsNewGetDados como aHeader
Local aHead7    := {}              // Array a ser tratado internamente na MsNewGetDados como aHeader
Local aHead8    := {}              // Array a ser tratado internamente na MsNewGetDados como aHeader
Local nPosData  := 0

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

SX3->(DbSetOrder(2)) // Campo

// Pedidos de Compra
// Carrega aHead1
For nX := 1 to Len(aCpoGDa1)
	If SX3->(DbSeek(aCpoGDa1[nX]))
		Aadd(aHead1,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
	Endif                                                                                                                         
Next nX                                                                                                                         
// Documentos de Entradas
// Carrega aHead2
For nX := 1 to Len(aCpoGDa2)
	If SX3->(DbSeek(aCpoGDa2[nX]))
		Aadd(aHead2,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
	Endif
Next nX
// Titulos a Pagar
// Carrega aHead3
For nX := 1 to Len(aCpoGDa3)
	If SX3->(DbSeek(aCpoGDa3[nX]))
		Aadd(aHead3,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
	Endif
Next nX
// Mov.Bancaria a Pagar
// Carrega aHead4
For nX := 1 to Len(aCpoGDa4)
	If SX3->(DbSeek(aCpoGDa4[nX]))
		Aadd(aHead4,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
	Endif
Next nX
// Pedidos de Venda
// Carrega aHead5
For nX := 1 to Len(aCpoGDa5)
	If SX3->(DbSeek(aCpoGDa5[nX]))
		Aadd(aHead5,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
	Endif
Next nX
// Titulos a Receber
// Carrega aHead6
For nX := 1 to Len(aCpoGDa6)
	If SX3->(DbSeek(aCpoGDa6[nX]))
		Aadd(aHead6,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
	Endif
Next nX
// Titulos a Receber
// Carrega aHead7
For nX := 1 to Len(aCpoGDa7)
	If SX3->(DbSeek(aCpoGDa7[nX]))
		Aadd(aHead7,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
	Endif
Next nX
// Mov.Bancaria a Receber
// Carrega aHead8
For nX := 1 to Len(aCpoGDa8)
	If SX3->(DbSeek(aCpoGDa8[nX]))
		Aadd(aHead8,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
	Endif
Next nX

// Montagem das aCols
nTam := Len(aAnaArrayTrb)
While dDataIni <= dDataFim
	nPosData := aScan(aAnaArrayTrb,{|x| x[2]==dDataIni})
	If nPosData > 0
		While nPosData<=nTam .And. aAnaArrayTrb[nPosData,2]==dDataIni
		   Do Case
	          Case aAnaArrayTrb[nPosData,3]=="PEDIDO DE COMPRA"
	          	Aadd( aCol1 , {aAnaArrayTrb[nPosData,2],aAnaArrayTrb[nPosData,4],aAnaArrayTrb[nPosData,5],aAnaArrayTrb[nPosData,6],aAnaArrayTrb[nPosData,7],.F.})
	          	aTotal[1] += aAnaArrayTrb[nPosData,7]
	          Case aAnaArrayTrb[nPosData,3]=="DOCUMENTO ENTRADA"
	          	Aadd( aCol2 , {aAnaArrayTrb[nPosData,2],aAnaArrayTrb[nPosData,4],aAnaArrayTrb[nPosData,5],aAnaArrayTrb[nPosData,6],aAnaArrayTrb[nPosData,7],aAnaArrayTrb[nPosData,8],aAnaArrayTrb[nPosData,11],aAnaArrayTrb[nPosData,9],aAnaArrayTrb[nPosData,10],.F.})
	          	aTotal[2] += aAnaArrayTrb[nPosData,11]
	          Case aAnaArrayTrb[nPosData,3]=="TITULO PAGAR"
	          	Aadd( aCol3 , {aAnaArrayTrb[nPosData,2],aAnaArrayTrb[nPosData,4],aAnaArrayTrb[nPosData,5],aAnaArrayTrb[nPosData,6],aAnaArrayTrb[nPosData,7],aAnaArrayTrb[nPosData,8],aAnaArrayTrb[nPosData,9],aAnaArrayTrb[nPosData,10],aAnaArrayTrb[nPosData,11],.F.})
	          	aTotal[3] += aAnaArrayTrb[nPosData,11]
          	Case aAnaArrayTrb[nPosData,3]=="MOV.BANCARIA PAGAR"
	          	Aadd( aCol4 , {aAnaArrayTrb[nPosData,2],aAnaArrayTrb[nPosData,4],aAnaArrayTrb[nPosData,5],aAnaArrayTrb[nPosData,6],aAnaArrayTrb[nPosData,7],aAnaArrayTrb[nPosData,8],aAnaArrayTrb[nPosData,9],.F.})
	          	aTotal[4] += aAnaArrayTrb[nPosData,9]
	          Case aAnaArrayTrb[nPosData,3]=="PEDIDO DE VENDA"
	          	Aadd( aCol5 , {aAnaArrayTrb[nPosData,2],aAnaArrayTrb[nPosData,4],aAnaArrayTrb[nPosData,5],aAnaArrayTrb[nPosData,6],aAnaArrayTrb[nPosData,7],.F.})
	          	aTotal[5] += aAnaArrayTrb[nPosData,7]
	          Case aAnaArrayTrb[nPosData,3]=="NOTA FISCAL"
	          	Aadd( aCol6 , {aAnaArrayTrb[nPosData,2],aAnaArrayTrb[nPosData,4],aAnaArrayTrb[nPosData,5],aAnaArrayTrb[nPosData,6],aAnaArrayTrb[nPosData,7],aAnaArrayTrb[nPosData,8],aAnaArrayTrb[nPosData,11],aAnaArrayTrb[nPosData,9],aAnaArrayTrb[nPosData,10],.F.})
	          	aTotal[6] += aAnaArrayTrb[nPosData,11]
	          Case aAnaArrayTrb[nPosData,3]=="TITULO RECEBER"
	          	Aadd( aCol7 , {aAnaArrayTrb[nPosData,2],aAnaArrayTrb[nPosData,4],aAnaArrayTrb[nPosData,5],aAnaArrayTrb[nPosData,6],aAnaArrayTrb[nPosData,7],aAnaArrayTrb[nPosData,8],aAnaArrayTrb[nPosData,9],aAnaArrayTrb[nPosData,10],aAnaArrayTrb[nPosData,11],.F.})
	          	aTotal[7] += aAnaArrayTrb[nPosData,11]
	          Case aAnaArrayTrb[nPosData,3]=="MOV.BANCARIA RECEBER"
	          	Aadd( aCol8 , {aAnaArrayTrb[nPosData,2],aAnaArrayTrb[nPosData,4],aAnaArrayTrb[nPosData,5],aAnaArrayTrb[nPosData,6],aAnaArrayTrb[nPosData,7],aAnaArrayTrb[nPosData,8],aAnaArrayTrb[nPosData,9],.F.})
	          	aTotal[8] += aAnaArrayTrb[nPosData,9]
			EndCase
			nPosData += 1
		EndDo
	EndIf
	dDataIni += 1
EndDo
aSort(aCol1,,,{|x,y| DtoS(x[1])+x[2]+x[3]+x[4] < DtoS(y[1])+y[2]+y[3]+y[4] })
aSort(aCol2,,,{|x,y| DtoS(x[1])+x[2]+x[3]+x[4]+x[5] < DtoS(y[1])+y[2]+y[3]+y[4]+y[5] })
aSort(aCol3,,,{|x,y| DtoS(x[1])+x[2]+x[3]+x[4]+x[5]+x[6]+x[8] < DtoS(y[1])+y[2]+y[3]+y[4]+y[5]+y[6]+y[8] })
aSort(aCol4,,,{|x,y| DtoS(x[1])+x[2]+x[3] < DtoS(y[1])+y[2]+y[3] })
aSort(aCol5,,,{|x,y| DtoS(x[1])+x[2]+x[3]+x[4] < DtoS(y[1])+y[2]+y[3]+y[4] })
aSort(aCol6,,,{|x,y| DtoS(x[1])+x[2]+x[3]+x[4]+x[5] < DtoS(y[1])+y[2]+y[3]+y[4]+y[5] })
aSort(aCol7,,,{|x,y| DtoS(x[1])+x[2]+x[3]+x[4]+x[5]+x[6]+x[8] < DtoS(y[1])+y[2]+y[3]+y[4]+y[5]+y[6]+y[8] })
aSort(aCol8,,,{|x,y| DtoS(x[1])+x[2]+x[3] < DtoS(y[1])+y[2]+y[3] })

If Empty(aCol1)
	aCol1 := {{"","","","",0,.F.}}
EndIf
If Empty(aCol2)
	aCol2 := {{"","","","","","",0,"","",.F.}}
EndIf	
If Empty(aCol3)
	aCol3 := {{"","","","","","","","",0,.F.}}
EndIf	
If Empty(aCol4)
	aCol4 := {{"","","","","","",0,.F.}}
EndIf	
If Empty(aCol5)
	aCol5 := {{"","","","",0,.F.}}
EndIf
If Empty(aCol6)
	aCol6 := {{"","","","","","",0,"","",.F.}}
EndIf
If Empty(aCol7)
	aCol7 := {{"","","","","","","","",0,.F.}}
EndIf	
If Empty(aCol8)
	aCol8 := {{"","","","","","",0,.F.}}
EndIf	

oGetDados1 := MsNewGetDados():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,nOpc,cLinOk,cTudoOk,cIniCpos,;
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk, oFolder:aDialogs[1] ,aHead1,aCol1)
oGetDados2 := MsNewGetDados():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,nOpc,cLinOk,cTudoOk,cIniCpos,;
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk, oFolder:aDialogs[2] ,aHead2,aCol2)
oGetDados3 := MsNewGetDados():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,nOpc,cLinOk,cTudoOk,cIniCpos,;
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk, oFolder:aDialogs[3] ,aHead3,aCol3)
oGetDados4 := MsNewGetDados():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,nOpc,cLinOk,cTudoOk,cIniCpos,;
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk, oFolder:aDialogs[4] ,aHead4,aCol4)
oGetDados5 := MsNewGetDados():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,nOpc,cLinOk,cTudoOk,cIniCpos,;
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk, oFolder:aDialogs[5] ,aHead5,aCol5)
oGetDados6:= MsNewGetDados():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,nOpc,cLinOk,cTudoOk,cIniCpos,;
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk, oFolder:aDialogs[6] ,aHead6,aCol6)
oGetDados7 := MsNewGetDados():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,nOpc,cLinOk,cTudoOk,cIniCpos,;
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk, oFolder:aDialogs[7] ,aHead7,aCol7)
oGetDados8 := MsNewGetDados():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,nOpc,cLinOk,cTudoOk,cIniCpos,;
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk, oFolder:aDialogs[8] ,aHead8,aCol8)

nTotal := aTotal[1]
oFolder:bSetOption:={|nAtu| PMSC100Atu(aTotal,nAtu,oSayTotal,oGetTotal,@nTotal)}
@ aPosObj[1,4]+4, aPosObj[1,2]+  1   SAY oSayTotal VAR STR0195+" "+STR0189 PIXEL OF oDlg FONT oBold //"Total de"+"Pedidos de Compra"
@ aPosObj[1,4]+4, aPosObj[1,2]+110 MSGET oGetTotal VAR nTotal PICTURE "@E 999,999,999,999.99" WHEN .F. PIXEL OF oDlg SIZE 60,10 FONT oBold

Return Nil                                                                                                                      

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   PMSC100Atu   ³ Autor   ³ Daniel Tadashi Batori  ³ Data ³ 29/01/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel para atualizar o total da tela de acordo com a aba ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³aTotal : array com os totais por aba do analitico                      ³±±
±±³           ³nAtu : aba selecionada                                                 ³±±
±±³           ³oSayTotal : objeto a ser atualizado com a string da aba                ³±±
±±³           ³oGetTotal : objeto a ser atualizado com o valor total da aba           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PMSC100Atu(aTotal,nAtu,oSayTotal,oGetTotal,nTotal)

Do Case
	Case nAtu==1
		oSayTotal:cCaption := STR0195+" "+STR0189 //"Total de""Pedidos de Compra"
		nTotal := aTotal[1]
	Case nAtu==2
		oSayTotal:cCaption := STR0195+" "+STR0190 //"Total de""Doc. de Entrada"
		nTotal := aTotal[2]
	Case nAtu==3
		oSayTotal:cCaption := STR0195+" "+STR0191 //"Total de""Títulos a Pagar"
		nTotal := aTotal[3]
	Case nAtu==4
		oSayTotal:cCaption := STR0195+" "+STR0208 //"Total de""Mov.Bancaria a Pagar"
		nTotal := aTotal[4]
	Case nAtu==5
		oSayTotal:cCaption := STR0195+" "+STR0192 //"Total de""Pedidos de Venda"
		nTotal := aTotal[5]
	Case nAtu==6
		oSayTotal:cCaption := STR0195+" "+STR0193 //"Total de""Notas Fiscais"
		nTotal := aTotal[6]
	Case nAtu==7
		oSayTotal:cCaption := STR0195+" "+STR0194 //"Total de""Títulos a Receber"
		nTotal := aTotal[7]
	Case nAtu==8
		oSayTotal:cCaption := STR0195+" "+STR0207 //"Total de""Mov.Bancaria a Receber"
		nTotal := aTotal[8]
EndCase

oGetTotal:Refresh()
oSayTotal:Refresh()

Return 
