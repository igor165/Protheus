#include "pmsc010a.ch"
#include "mproject.ch"
#include "pmsicons.ch"
#include "PROTHEUS.ch"

#define _QUANT				1
#define _START 				2
#define _HORAI 				3
#define _FINISH 				4
#define _HORAF 				5
#define _CALEND 				6
#define _NAME					7
#define _UM 					8
#define _ORDEM				9
#define _RESTRI				10
#define _DTREST				11
#define _HRREST				12
#define _WORK					13
#define _AGCRTL 				14
#define _PRIORITY 			15
#define _TEXT1				16
#define _OUTLINELEVEL		17
#define _PERCENTCOMPLETE		18
#define _PREDECESSORS		19
#define _RESOURCENAMES		20
#define _TYPEWORK				21
#define _ALIAS				22
#define _TYPETASK				23

Static lWarning := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} Aux010Write
Programa de Sincronizacao do Projeto com o MS-Project

@author Edson Maricate
@since 09-02-2001
@version P10 R4

@param cAlias,,
@param nReg,,
@param nOpcx,,
@param oApp,,
@param nVersao,,
@param cArquivo,,
@param lRecurso,,
@param lAloc,,
@param lRelac,,
@param lPOC,,
@param aRecAmarr,,
@param lUnico,,
@param nIDProject

@return

/*/
//-------------------------------------------------------------------
Function Aux010Write(cAlias,nReg,nOpcx,oApp,nVersao, cArquivo,lRecurso,lAloc,lRelac,lPOC,aRecAmarr,lUnico,nIDProject)

Local aAuxArea		:= {}
Local aDadosTsk 		:= {}
Local aDadosUsr		:= {}
Local aDtAFY			:= {}
Local aRecAF9 		:= {}
Local aRecAFA 		:= {}
Local aRecAFC 		:= {}
Local aRecAFD 		:= {}
Local aRecAJ4 		:= {}
Local aRelac			:= {}
Local aResources		:= {}
Local aRet 			:= {}
Local aTemp			:= {}

Local bContAFF 		:= .T.

Local cAFA_FIX 		:= CriaVar('AFA_FIX',.T.)
Local cAliasAFP		:= RetSQLName("AFP")
Local cAliasTmp		:= getNextAlias()
Local cAllCalend		:= ''
Local cAllUM			:= ''
Local cAloc			:= ""
Local cExcTrfPms		:= SuperGetMv("MV_PMSTEXC",,"S")
Local cLogPath		:= ""
Local cMaxTsk			:= ""
Local cMens91			:= ""
Local cMens93			:= ""
Local cMens95			:= ""
Local cMensagem 		:= ""
Local cNivelOne		:= ""
Local cPictAF9 		:= ""
Local cPictAFC 		:= ""
Local cProjeto		:= Alltrim(AF8->AF8_PROJET)
Local cQuery			:= ""
Local cRestProject 	:= ""
Local cRetCod			:= ""
Local cTASKSUMMARY	:= ""
Local cTipoRest 		:= ""
Local cTipoTrf		:= ""
Local cYes       		:= ""

Local lAdNivel		:= .T.
Local lContinua		:= .T.
Local lFase91 		:= .F.
Local lFase93 		:= .F.
Local lFase95 		:= .F.
Local lInclusao		:= .T.
Local lIngles 		:= .F.
Local lLogCustom		:= ExistBlock("PMC010LOG")
Local lPergMais		:= .T.
Local lPMS010IM		:= ExistBlock("PMS010IM")
Local lPMSGetFld		:= ExistBlock("PMSGetFld")
Local lPMSPutFld		:= ExistBlock("PMSPutFld")
Local lPMSVLRPRD		:= Existblock("PMSVLRPRD")
Local lPortugues		:= .F.
Local lRet 			:= .F.
Local lUsaTxt30		:= SuperGetMv("MV_PMSTX30",, .F. )

Local i				:= 0
Local nBuffer			:= 0
Local nC				:= 0
Local nMaxTsk			:= 0
Local nNivel1			:= 0
Local nPercComp		    := 0
Local nPosWork		    := 0
Local nT				:= 0
Local nTamAF9Ord		:= TamSx3('AF9_ORDEM')[1]
Local nTamAFAIte		:= TamSX3("AFA_ITEM")[1]
Local nTamAFCOrd		:= TamSx3('AFC_ORDEM')[1]
Local nTamAFDIte		:= TamSX3("AFD_ITEM")[1]
Local nTamAJ4Ite		:= TamSX3("AJ4_ITEM")[1]
Local nw				:= 0
Local nz				:= 0

Local oProject

Private aEDTPAI		:= {}
PRIVATE lHasCCT 		:= HasTemplate("CCT")
Private nMV_PRECISA	:= SuperGetMV("MV_PRECISA")
PRIVATE lTopConn		:= IfDefTopCTB()
Private nTamAF9Niv	:= TamSX3("AF9_NIVEL")[1]
Private nTamAFCNiv	:= TamSX3("AFC_NIVEL")[1]

DEFAULT nIDProject := 1

oProject	:= oApp:Projects(nIDProject) // projeto atual
cYes		:= IIF( nVersao == 2 /*ingles*/, "YES", IIf( nVersao == 3 /*espanhol*/, "SI", "SIM" ) )
nMaxTsk	:= oProject:Tasks:Count
cMaxTsk	:= AllTrim(Str(nMaxTsk))
cNivelOne	:= strzero(1,nTamAFCNiv)
lIngles	:= ( nVersao == 2 )
lPortugues	:= ( nVersao == 1 )
lFase91 	:= PmsVldFase("AF8", AF8->AF8_PROJET, "91", .F., @cMens91)
lFase93 	:= PmsVldFase("AF8", AF8->AF8_PROJET, "93", .F., @cMens93)
lFase95 	:= PmsVldFase("AF8", AF8->AF8_PROJET, "95", .F., @cMens95)


If !lLogCustom
	If ParamBox({{1,STR0044,SPACE(50),"","",,"",55,.F.}},STR0045) // "Caminho: " ##"Arquivo Log"
		cLogPath := Upper(MV_PAR01)
	EndIf
Else
	cLogPath := ExecBlock("PMC010LOG",.F.,.F.)
EndIf

PMSLogInt("AF8",,,cLogPath,,lUnico)

oApp:VISIBLE:= .F.
ProcRegua(nMaxTsk+3)

For nw := 1 to nMaxTsk

	IncProc(STR0036+" "+AllTrim(Str(nw))+" "+STR0037+" "+cMaxTsk+ " "+STR0038)  //"Importando "##" de "##" tarefas do MS-Project..."

	//
	// Retorno se ?uma EDT, isto ? para o project se ?uma tarefa resumo.
	//
	cTASKSUMMARY := PmsReadTsk(nw,PJTASKSUMMARY)
	cTASKSUMMARY := Upper(Alltrim(cTASKSUMMARY))

	If lUsaTxt30
		cTxt30 := PmsReadTsk(nw , PJCUSTOMTASKTEXT30)
		lContinua := cTxt30 == "1"
	Endif

	IF lContinua
		If cTASKSUMMARY==cYes

			aadd(aDadosTsk ,{	Val(PMSPonVir(PmsReadTsk(nw,PJTASKNUMBER1))); 							// 1 AFC->AFC_QUANT := Val(PMSPonVir(aDadosPrj[nw][nx])
								, 	PmsReadData(nVersao, PmsReadTsk(nw,PJTASKSTART)); 					// 2 AFC->AFC_START := PmsReadData(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadHora(nVersao, PmsReadTsk(nw,PJTASKSTART)); 					// 3 AFC->AFC_HORAI := PmsReadHora(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadData(nVersao, PmsReadTsk(nw,PJTASKFINISH)); 					// 4 AFC->AFC_FINISH:= PmsReadData(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadHora(nVersao, PmsReadTsk(nw,PJTASKFINISH)); 					// 5 AFC->AFC_HORAF := PmsReadHora(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadCale(nVersao, PmsReadTsk(nw,PJTASKCALENDAR),@cAllCalend); 	// 6 AFC->AFC_CALEND	:= PmsReadCale(nVersao,aDadosPrj[nw][nx]),@cAllCalend)
								, 	ALLTRIM(PmsReadTsk(nw,PJTASKNAME)); 								// 7 AFC->AFC_DESCRI
								, 	PmsReadUM(PmsReadTsk(nw,PJTASKTEXT2) , AFC->AFC_DESCRI,@cAllUM); 	// 8 AFC->AFC_UM := PmsReadUM(aDadosPrj[nw][nw],AFC->AFC_DESCRI,@cAllUM)
								, 	PmsReadTsk(nw,PJTASKID);											// 9 AFC->AFC_ORDEM := StrZero(Val(aDadosPrj[nw][nw]),TamSx3('AFC_ORDEM')[1])
								, 	UPPER(PmsReadTsk(nw,PJTASKCONSTRAINTTYPE)); 						// 10 AFC->AFC_RETRI := UPPER(aDadosPrj[nw][nx])
								, 	PmsReadData(nVersao,PmsReadTsk(nw,PJTASKCONSTRAINTDATE));			// 11 AFC->AFC_DTREST := PmsReadData(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadHora(nVersao,PmsReadTsk(nw,PJTASKCONSTRAINTDATE));			// 12 AFC->AFC_HRREST := PmsReadHora(nVersao,aDadosPrj[nw][nx])
								, 	Val(PMSPonVir(PmsReadTsk(nw,PJTASKWORK))); 							// 13 AFC->AFC_HESF := Val(PMSPonVir(aDadosPrj[nw][nx]))
								, 	" " ; 																// 14 AF9->AF9_AGCRTL
								, 	Val(PmsReadTsk(nw,PJTASKPRIORITY));	  								// 15 AF9->AF9_PRIORI	:= Val(aDadosPrj[nw][nx])
								,	PmsReadTsk(nw,PJTASKTEXT1);                                 		// 16 AFC_EDT CODIGO DA EDT
								,	PmsReadTsk(nw,PJTASKOUTLINELEVEL);									// 17 AFC_NIVEL EDT
								,	PmsReadTsk(nw,PJTASKPERCENTCOMPLETE);								// 18 AFQ_PERC
								,	PmsReadTsk(nw,PJTASKPREDECESSORS);									// 19 Predecessoras
					  			,	PmsReadTsk(nw,PJTASKRESOURCENAMES);									// 20 Recursos
								,	"resource work";													// 21 Tipo de Recurso
								, 	"AFC";																// 22 Alias da tabela
								,	PmsReadTsk(nw,PJTASKTYPE);											// 23 tipo da tarefa  25
								})
			If lPMSGetFld
				aDadosUsr := Execblock("PMSGetFld", .F.,.F., { aDadosUsr , 1 , nw } )
			Endif
		Else

		  	aadd(aDadosTsk ,{	Val(PMSPonVir(PmsReadTsk(nw,PJTASKNUMBER1))); 							// 1 AF9->AF9_QUANT := Val(PMSPonVir(aDadosPrj[nw][nx])
								, 	PmsReadData(nVersao,PmsReadTsk(nw,PJTASKSTART)); 					// 2 AF9->AF9_START := PmsReadData(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadHora(nVersao,PmsReadTsk(nw,PJTASKSTART));					// 3 AF9->AF9_HORAI := PmsReadHora(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadData(nVersao,PmsReadTsk(nw,PJTASKFINISH)); 					// 4 AF9->AF9_FINISH:= PmsReadData(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadHora(nVersao,PmsReadTsk(nw,PJTASKFINISH)); 					// 5 AF9->AF9_HORAF := PmsReadHora(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadCale(nVersao,PmsReadTsk(nw,PJTASKCALENDAR),@cAllCalend);		// 6 AF9->AF9_CALEND	:= PmsReadCale(nVersao,aDadosPrj[nw][nx]),@cAllCalend)
								, 	ALLTRIM(PmsReadTsk(nw,PJTASKNAME)); 								// 7 AF9->AF9_DESCRI
								, 	PmsReadUM(PmsReadTsk(nw,PJTASKTEXT2),AFC->AFC_DESCRI,@cAllUM);		// 8 AF9->AF9_UM := PmsReadUM(aDadosPrj[nw][nx],AFC->AFC_DESCRI,@cAllUM)
								, 	PmsReadTsk(nw,PJTASKID);											// 9 AF9->AF9_ORDEM := StrZero(Val(aDadosPrj[nw][nx]),TamSx3('AFC_ORDEM')[1])
								, 	UPPER(PmsReadTsk(nw,PJTASKCONSTRAINTTYPE));							// 10 AF9->AF9_RETRI := UPPER(aDadosPrj[nw][nx])
								, 	PmsReadData(nVersao,PmsReadTsk(nw,PJTASKCONSTRAINTDATE));			// 11 AF9->AF9_DTREST := PmsReadData(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadHora(nVersao,PmsReadTsk(nw,PJTASKCONSTRAINTDATE));			// 12 AF9->AF9_HRREST := PmsReadHora(nVersao,aDadosPrj[nw][nx])
								, 	Val(PMSPonVir(PmsReadTsk(nw,PJTASKWORK)));							// 13 AF9->AF9_HESF := Val(PMSPonVir(aDadosPrj[nw][nx]))
								, 	PmsReadTsk(nw,PJTASKEFFORTDRIVEN); 									// 14 AF9->AF9_AGCRTL
								, 	Val(PmsReadTsk(nw,PJTASKPRIORITY));									// 15 AF9->AF9_PRIORI	:= Val(aDadosPrj[nw][nx])
								,	PmsReadTsk(nw,PJTASKTEXT1);											// 16 AF9_TAREFA CODIGO DA TAREFA
								,	PmsReadTsk(nw,PJTASKOUTLINELEVEL);									// 17 AF9_NIVEL NIVEL DA TAREFA NO PROJETO
								,	PmsReadTsk(nw,PJTASKPERCENTCOMPLETE);								// 18 AFF_PERC
								,	PmsReadTsk(nw,PJTASKPREDECESSORS);									// 19 Predecessoras
								,	PmsReadTsk(nw,PJTASKRESOURCENAMES);									// 20 Recursos
								,	"resource work";													// 21 Tipo de Recurso
								, 	"AF9";																// 22 Alias da tabela
								,	PmsReadTsk(nw,PJTASKTYPE);											// 23 tipo da tarefa
								})
			If lPMSGetFld
				aDadosUsr := Execblock("PMSGetFld", .F.,.F., { aDadosUsr , 2 , nw })
			Endif

		Endif
	Endif
Next nw

ProcRegua(Len(aDadosTsk))

SX3->(dbSetOrder(2))
If SX3->(MsSeek("AFC_DESCRI"))
	If Empty(Alltrim(SX3->X3_PICTURE))
		cPictAFC :=""
	Else
		cPictAFC :='"'+Alltrim(SX3->X3_PICTURE)+'"'
	EndIf
EndIf

SX3->(dbSetOrder(2))
If SX3->(MsSeek("AF9_DESCRI"))
	If Empty(Alltrim(SX3->X3_PICTURE))
		cPictAF9 :=""
	Else
		cPictAF9 :='"'+Alltrim(SX3->X3_PICTURE)+'"'
	EndIf
EndIf

If Len(aDadosTsk) > 0
	//lAdNivel := !(Alltrim(aDadosTsk[1,_TEXT1]) == cProjeto) .AND. !lUsaTxt30
	// Se existir o nivel de estrutura do MS-Project como 0, ?o a tarefa resumo do projeto
	// Não deve acrescentar aumentar o nivel para o PMS
	lAdNivel := aScan(aDadosTsk,{|x|x[_OUTLINELEVEL]=="0"})==0 .AND. !lUsaTxt30
EndIf

// o 1o nivel no PMS é o codigo do projeto equivalente ao nivel 0 no MS-Project
aAdd(aEDTPAI ,{AF8->AF8_PROJET ,cNivelOne})

Begin Transaction
For nw:=1 to Len(aDadosTsk)

	If nw%10 == 0
		IncProc(STR0039+" "+AllTrim(Str(nw))+" "+STR0037+" "+AllTrim(Str(Len(aDadosTsk)))+ " "+STR0040) //"Gravando "##" de "##" EDT´s do MS-Project..."
	Endif

	If aDadosTsk[nw,_ALIAS] == "AFC"
   		// Nao se trata da tarefa resumo do projeto (EDT Principal)
   		If aDadosTsk[nw,_OUTLINELEVEL] <> '0'
			dbSelectArea("AFC")
			dbSetOrder(1)
			If !Empty(aDadosTsk[nw,_TEXT1]) .And. MsSeek(xFilial("AFC")+AF8->AF8_PROJET+AF8->AF8_REVISA+aDadosTsk[nw,_TEXT1])
				RecLock("AFC",.F.)
				lInclusao := .F.
			Else
				cRetCod := Pmc010Cod("AFC",AF8->AF8_PROJET,AF8->AF8_REVISA,,,aDadosTsk[nw],lAdNivel)
				RecLock("AFC",.T.)
				AFC->AFC_FILIAL 	:= xFilial("AFC")
				AFC->AFC_PROJET	:= AF8->AF8_PROJET
				AFC->AFC_REVISA	:= AF8->AF8_REVISA
				AFC->AFC_EDT		:= cRetCod
				lInclusao := .T.
			EndIf
			aDadosTsk[nw,_TEXT1] := AFC->AFC_EDT
			AFC->AFC_QUANT	:= If(aDadosTsk[nw,_QUANT]==0,1,aDadosTsk[nw,_QUANT])
			AFC->AFC_START	:= aDadosTsk[nw,_START]
			AFC->AFC_HORAI	:= aDadosTsk[nw,_HORAI]
			AFC->AFC_FINISH	:= aDadosTsk[nw,_FINISH]
			AFC->AFC_HORAF	:= aDadosTsk[nw,_HORAF]
			AFC->AFC_CALEND	:= aDadosTsk[nw,_CALEND]
			AFC->AFC_NIVEL	:= If(lAdNivel,STRZERO(VAL(aDadosTsk[nw,_OUTLINELEVEL])+1, nTamAFCNiv),STRZERO(VAL(aDadosTsk[nw,_OUTLINELEVEL]), nTamAFCNiv))

			If (AFC->AFC_NIVEL == cNivelOne)
				nNivel1++
				AFC->AFC_EDTPAI := ""
			Else
				AFC->AFC_EDTPAI := If(Empty(aEDTPAI),AF8->AF8_PROJET,PC010EdtPai(aEDTPai,aDadosTsk[nw],lAdNivel))
			Endif

			If Empty(cPictAFC)
				AFC->AFC_DESCRI	:= aDadosTsk[nw,_NAME]
			Else
				AFC->AFC_DESCRI	:= Transform(aDadosTsk[nw,_NAME],&cPictAFC)
			EndIf

			AFC->AFC_UM		:= aDadosTsk[nw,_UM]
			If !Empty(AFC->AFC_ORDEM) // campo ORDEM somente ser?tratado se originalmente o projeto possuir tal controle.
																	//Este campo pode causar efeitos colaterais na estrutura do projeto caso alimentado incorretamente.
				AFC->AFC_ORDEM := StrZero(Val(aDadosTsk[nw,_ORDEM]) , nTamAFCOrd)
			EndIf

			cTipoRest := aDadosTsk[nw,_RESTRI]
			If  lPortugues

				Do Case

					Case cTipoRest ==  "NÃO INICIAR ANTES DE"
						AFC->AFC_RESTRI := "1"

					Case cTipoRest ==  "NÃO TERMINAR DEPOIS DE"
						AFC->AFC_RESTRI := "2"

					Case cTipoRest ==  "O MAIS BREVE POSSÍVEL"
						AFC->AFC_RESTRI := "3"

					Otherwise
						AFC->AFC_RESTRI := ""
				Endcase

			ElseIf lIngles // ingles

				Do Case

					Case cTipoRest == "START NO EARLIER THAN"
						AFC->AFC_RESTRI := "1"

					Case cTipoRest ==  "FINISH NO LATER THAN"
						AFC->AFC_RESTRI := "2"

					Case cTipoRest ==  "AS SOON AS POSSIBLE"
						AFC->AFC_RESTRI := "3"

					Otherwise
						AFC->AFC_RESTRI := ""

				EndCase

			Else

				Do Case
					Case cTipoRest ==  "NO COMENZAR ANTES DEL"
						AFC->AFC_RESTRI := "1"

					Case cTipoRest ==  "NO FINALIZAR DESPUÉS DEL"
						AFC->AFC_RESTRI := "2"

					Case 	cTipoRest ==  "LO ANTES POSIBLE"
						AFC->AFC_RESTRI := "3"
					Otherwise
						AFC->AFC_RESTRI := ""
				EndCase

			Endif

			If !Empty(aDadosTsk[nw,_DTREST]) .AND. !Empty(aDadosTsk[nw,_HRREST])
				AFC->AFC_DTREST := aDadosTsk[nw,_DTREST]
				AFC->AFC_HRREST := aDadosTsk[nw,_HRREST]
			EndIf

			If lPMSPutFld
				ExecBlock("PMSPutFld", .F. , .F. , {aDadosUsr, 1, nw} )
			Endif

			oProject:Tasks(nw):SetField('PJTASKTEXT1',AFC->AFC_EDT)
			oProject:Tasks(nw):SetField('PJTASKTEXT23',AFC->AFC_EDT)
			oProject:Tasks(nw):SetField('PJTASKNUMBER1', PMSPonVir(Str(AFC->AFC_QUANT)))

			nBuffer++
			FreeUsedCodes(.T.)
			aAdd(aRecAFC,AFC->(RecNo()))
			aAdd(aEDTPAI,{AFC->AFC_EDT,AFC->AFC_NIVEL})
			PMSLogInt("AFC", lInclusao,,cLogPath)

			If nNivel1 > 1
				Aviso(STR0030,STR0031+Chr(13)+chr(10)+STR0032,{STR0033},2)
				Exit
			Endif
		EndIf // nao se trata da tarefa resumo do projeto
	Else

		dbSelectArea("AF9")
		dbSetOrder(1)
		If !Empty(aDadosTsk[nw,_TEXT1]) .And.MsSeek(xFilial("AF9")+AF8->AF8_PROJET+AF8->AF8_REVISA+aDadosTsk[nw,_TEXT1])
			RecLock("AF9",.F.)
			lInclusao := .F.
		Else
			cRetCod := Pmc010Cod("AF9",AF8->AF8_PROJET,AF8->AF8_REVISA,,,aDadosTsk[nw],lAdNivel)
			RecLock("AF9",.T.)
			AF9->AF9_FILIAL := xFilial("AF9")
			AF9->AF9_PROJET	:= AF8->AF8_PROJET
			AF9->AF9_REVISA	:= AF8->AF8_REVISA
			AF9->AF9_TAREFA	:= cRetCod
			lInclusao := .T.
		EndIf
		aDadosTsk[nw,_TEXT1] := AF9->AF9_TAREFA
		AF9->AF9_QUANT		:= If(aDadosTsk[nw,_QUANT]==0,1,aDadosTsk[nw,_QUANT])
		AF9->AF9_START		:= aDadosTsk[nw,_START]
		AF9->AF9_HORAI		:= aDadosTsk[nw,_HORAI]
		AF9->AF9_FINISH		:= aDadosTsk[nw,_FINISH]
		AF9->AF9_HORAF		:= aDadosTsk[nw,_HORAF]
		AF9->AF9_CALEND		:= aDadosTsk[nw,_CALEND]
		If !lUsaTxt30
			AF9->AF9_EDTPAI 	:= If(Empty(aEDTPAI),AF8->AF8_PROJET,PC010EdtPai(aEDTPai,aDadosTsk[nw],lAdNivel))
		Endif
		AF9->AF9_NIVEL		:= If(lAdNivel,STRZERO(VAL(aDadosTsk[nw,_OUTLINELEVEL])+1, nTamAF9Niv),STRZERO(VAL(aDadosTsk[nw,_OUTLINELEVEL]), nTamAF9Niv))

		If Empty(cPictAF9)
			AF9->AF9_DESCRI	:= aDadosTsk[nw,_NAME]
		Else
			AF9->AF9_DESCRI	:= Transform(aDadosTsk[nw,_NAME],&cPictAF9)
		EndIf

		AF9->AF9_UM		:= aDadosTsk[nw,_UM]
		AF9->AF9_PRIORI	:= aDadosTsk[nw,_PRIORITY]

		If AllTrim(aDadosTsk[nw,_DTREST]) <> "NA"
			AF9->AF9_DTREST := aDadosTsk[nw,_DTREST]
			AF9->AF9_HRREST := aDadosTsk[nw,_HRREST]
		Else
			AF9->AF9_DTREST := stod("")
			AF9->AF9_HRREST := ""
		EndIf

		If lPortugues

			cRestProject := aDadosTsk[nw,_RESTRI]

			Do Case
				// iniciar
				Case cRestProject == "DEVE INICIAR EM"
					cTipoRest := "1"

				// terminar
				Case cRestProject == "DEVE TERMINAR EM"
					cTipoRest := "2"

				// nao iniciar antes
				Case cRestProject == "NÃO INICIAR ANTES DE"
					cTipoRest := "3"

				// nao iniciar depois
				Case cRestProject == "NÃO INICIAR DEPOIS DE"
					cTipoRest := "4"

				// nao terminar antes
				Case cRestProject == "NÃO TERMINAR ANTES DE"
					cTipoRest := "5"

				// nao terminar depois
				Case cRestProject == "NÃO TERMINAR DEPOIS DE"
					cTipoRest := "6"

				// o mais breve
				Case cRestProject == "O MAIS BREVE POSSÍVEL"
					cTipoRest := "7"

				// o mais tarde
				Case cRestProject == "O MAIS TARDE POSSÍVEL"
					cTipoRest := "8"

				Otherwise
					cTipoRest := " "
			EndCase

		ElseIf lIngles
			// converte o tipo de restricao
			// importada para o PMS
			cRestProject := aDadosTsk[nw,_RESTRI]

			Do Case
				// iniciar
				Case cRestProject == "MUST START ON"
					cTipoRest := "1"

				// terminar
				Case cRestProject == "MUST FINISH ON"
					cTipoRest := "2"

				// nao iniciar antes
				Case cRestProject == "START NO EARLIER THAN"
					cTipoRest := "3"

				// nao iniciar depois
				Case cRestProject == "START NO LATER THAN"
					cTipoRest := "4"

				// nao terminar antes
				Case cRestProject == "FINISH NO EARLIER THAN"
					cTipoRest := "5"

				// nao terminar depois
				Case cRestProject == "FINISH NO LATER THAN"
					cTipoRest := "6"

				// o mais breve
				Case cRestProject == "AS SOON AS POSSIBLE"
					cTipoRest := "7"

				// o mais tarde
				Case cRestProject == "AS LATE AS POSSIBLE"
					cTipoRest := "8"

				Otherwise
					cTipoRest := " "
			EndCase
		Else
			// converte o tipo de restricao
			// importada para o PMS
			cRestProject := aDadosTsk[nw,_RESTRI]
			Do Case
				// iniciar
				Case cRestProject == "DEBE COMENZAR EL"
					cTipoRest := "1"

				// terminar
				Case cRestProject == "DEBE FINALIZAR EL"
					cTipoRest := "2"

				// nao iniciar antes
				Case cRestProject == "NO COMENZAR ANTES DEL"
					cTipoRest := "3"

				// nao iniciar depois
				Case cRestProject == "NO COMENZAR DESPUÉS DEL"
					cTipoRest := "4"

				// nao terminar antes
				Case cRestProject == "NO FINALIZAR ANTES DEL"
					cTipoRest := "5"

				// nao terminar depois
				Case cRestProject == "NO FINALIZAR DESPUÉS DEL"
					cTipoRest := "6"

				// o mais breve
				Case cRestProject == "LO ANTES POSIBLE"
					cTipoRest := "7"

				// o mais tarde
				Case cRestProject == "LO MÁS TARDE POSIBLE"
					cTipoRest := "8"

				Otherwise
					cTipoRest := " "
			EndCase

		EndIf

		AF9->AF9_RESTRI := cTipoRest

		If !Empty(AF9->AF9_ORDEM) // campo ORDEM somente ser?tratado se originalmente o projeto possuir tal controle.
																//Este campo pode causar efeitos colaterais na estrutura do projeto caso alimentado incorretamente.
			If ValType(aDadosTsk[nw,_ORDEM]) == "C" .AND. !Empty(aDadosTsk[nw,_ORDEM])
				AF9->AF9_ORDEM := StrZero(Val(aDadosTsk[nw,_ORDEM]),nTamAF9Ord)
			EndIf
		EndIf

		//Alimenta campo de "tipo da tarefa" no PROJECT
		cTipoTrf := aDadosTsk[ nw , _TYPETASK ]

		Do Case

			Case Substr(cTipoTrf,1,1) == 'D'
				AF9->AF9_TPTRF := '1'
			Case Substr(cTipoTrf,1,1) == 'T'
				AF9->AF9_TPTRF := '2'
			Case Substr(cTipoTrf,1,1) == 'U'
				AF9->AF9_TPTRF := '3'

		EndCase

		AF9->AF9_HESF := aDadosTsk[nw,_WORK]

		If lPMSPutFld
			ExecBlock("PMSPutFld", .F. , .F. , {aDadosUsr, 2, nw} )
		Endif

		oProject:Tasks(nw):SetField('PJTASKTEXT1',AF9->AF9_TAREFA)
		oProject:Tasks(nw):SetField('PJTASKTEXT23',AF9->AF9_TAREFA)
		oProject:Tasks(nw):SetField('PJTASKNUMBER1', PMSPonVir(Str(AF9->AF9_QUANT)))

		PMSLogInt("AF9" , lInclusao,,cLogPath)
		nBuffer++
		//LIbera os codigos reservados
		FreeUsedCodes(.T.)
		aAdd(aRecAF9,AF9->(RecNo()))

	Endif

	If nBuffer > 3000
		AFC->(MsUnlockAll())
		AF9->(MsUnlockAll())
		nBuffer:= 0
	Endif

Next nw

For i := 1 To oProject:Resources:GetCount()
	aTemp := {}
	Aadd(aTemp, oProject:Resources(i):GetField("PJRESOURCENAME"))
	If TYPE(" oProject:Resources(i):GetField('PJRESOURCEWORK')) " ) == 'C'
		Aadd(aTemp, Val(oProject:Resources(i):GetField("PJRESOURCEWORK")))
	Endif
	Aadd(aResources, aTemp)
Next i

End Transaction
For nw := 1 to Len(aDadosTsk) // processa os relacionamentos da tarefa
	If nw%10 == 0
		IncProc(STR0041+" "+AllTrim(Str(nw))+" "+STR0037+" "+AllTrim(Str(Len(aDadosTsk)))+ " "+STR0038) //"Gravando amarrações: "##" de "##" tarefas do MS-Project..."
   Endif
   IF aDadosTsk[nw,_ALIAS] == "AF9"
		dbSelectArea("AF9")
		nT++
		dbgoto(aRecAF9[nT])
		nPercComp := Val(aDadosTsk[nw,_PERCENTCOMPLETE])
		aRelac := {}
		// processa o Percentual Realizado dos Eventos
		If !lTopConn

			dbSelectArea("AFP")
			dbSetOrder(1)
			If MsSeek(xFilial("AFP")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
				While !Eof() .And. xFilial("AFP")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
								AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_TAREFA
					RecLock("AFP",.F.)
		        	AFP->AFP_DTCALC	:= PmsDtPrv(AF9->AF9_START,AF9->AF9_FINISH,AFP->AFP_PERC,AF9->AF9_TPMEDI)
					nBuffer++
					dbSkip()
				EndDo
			EndIf

		Else

			cQuery := " SELECT R_E_C_N_O_ RECNO_ FROM "+cAliasAFP
			cQuery += " WHERE AFP_FILIAL = '"+xFilial("AFP")+"' "
			cQuery += " AND AFP_PROJET = '"+AF9->AF9_PROJET+"' "
			cQuery += " AND AFP_REVISA = '"+AF9->AF9_REVISA+"' "
			cQuery += " AND AFP_TAREFA = '"+AF9->AF9_TAREFA+"' "
			cQuery += " AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp , .T. , .T. )
			While (cAliasTmp)->(!Eof())

				AFP->(DbGoTo((cAliasTmp)->RECNO_))

				RecLock("AFP",.F.)
		        	AFP->AFP_DTCALC	:= PmsDtPrv(AF9->AF9_START,AF9->AF9_FINISH, AFP->AFP_PERC ,AF9->AF9_TPMEDI)
				nBuffer++
				(cAliasTmp)->(dbSkip())
			EndDo

			(cAliasTmp)->(dbCloseArea())

		Endif

		// processa o Percentual Realizado da Tarefa
		If lPOC .and. (nPercComp>0)
			dbSelectArea("AFF")
			dbSetOrder(1)
			If PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataBase) <> nPercComp

				bContAFF := .T.

				If MsSeek(xFilial("AFF")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+DTOS(dDataBase))
					If nPercComp <> 0

						// alteracao de confirmacao
						If !lFase93
							bContAFF := .F.
							if PMSShowWar() <> 2

								If lPergMais
									lRet := .F.
									While !lRet
										lRet := Parambox({{9,STR0020,180,,.T.},;  //	"Alteracao de Confirmacao nao Permitida"
															{9, cMens93,100,,.F.},;
															{1, STR0012, AF9->AF9_TAREFA, "@", '.F.',,'.F.', 30, .F.},; //"Tarefa"###"
															{5, STR0013, .F., 160,,.F.}}, STR0014, aRet) //"Nao exibir esta mensagem novamente."###"Alteracao de confirmacao: "
									EndDo
									lPergMais := !aRet[5]
								EndIf
							endif
							if PMSShowWar() <> 2
								PMSLogInt("AF9" , .F. ,'',,STR0020+" "+cMensagem)
							endif
						EndIf
					Else

						// exclusao de confirmacao
						If !lFase95
							bContAFF := .F.
							if PMSShowWar() <> 2
								If lPergMais
									lRet := .F.
									While !lRet
										lRet := Parambox({{9,STR0021,180,,.T.},;  //	"Exclusao de Confirmacao nao Permitida"
															{9, cMens95,100,,.F.},;
															{1, STR0012, AF9->AF9_TAREFA, "@", '.F.',,'.F.', 30, .F.},; //"Tarefa"###"
															{5, STR0013, .F., 160,,.F.}}, STR0015, aRet) //"Nao exibir esta mensagem novamente."###"Exclusao de confirmacao: "
									EndDo
									lPergMais := !aRet[5]
								EndIf
							endif
							if PMSShowWar() <> 1
								PMSLogInt("AF9" , .F. ,'',,STR0021+""+cMensagem)
							endif
						EndIf
					EndIf

					If bContAFF
						RecLock("AFF",.F.)
						PMSAvalAFF("AFF",2,,.F.,.F.)
					EndIf
				Else

					// inclusao de confirmacao
					If !lFase91
						bContAFF := .F.
						If PMSShowWar() <> 2
							If lPergMais
								lRet := .F.
								While !lRet
									lRet := Parambox({{9,STR0022,180,,.T.},; //	"Inclusao de Confirmacao nao Permitida"
														{9, cMens91,100,,.F.},;
														{1, STR0012, AF9->AF9_TAREFA, "@", '.F.',,'.F.', 30, .F.},; //"Tarefa"###"
														{1, STR0017, AF9->AF9_DESCRI, "@", '.F.',,'.F.', 100, .F.},; //"Desc. Tarefa"
														{5, STR0013, .F., 160,,.F.}}, STR0016, aRet) //"Nao exibir esta mensagem novamente."###"Inclusao de confirmacao: "
								EndDo
								lPergMais := !aRet[5]
							EndIf
						endif
						If PMSShowWar() <> 1
							PMSLogInt("AF9" , .F. ,'',,STR0022+ " "+cMensagem)
						endif
					EndIf

					If bContAFF
						RecLock("AFF",.T.)
					EndIf
				EndIf

				If bContAFF
					AFF->AFF_FILIAL := xFilial("AFF")
					AFF->AFF_PROJET	:= AF9->AF9_PROJET
					AFF->AFF_REVISA	:= AF9->AF9_REVISA
					AFF->AFF_TAREFA	:= AF9->AF9_TAREFA
					AFF->AFF_QUANT	:= AF9->AF9_QUANT*nPercComp/100
					AFF->AFF_USER		:= RetCodUsr()
					AFF->AFF_DATA		:= dDataBase

					PMSAvalAFF("AFF",1,,.F.,.F.)
					nBuffer++
				EndIf
			EndIf
		EndIf

		aRelac := {}

		// processa os recursos alocados na tarefa
		If !Empty(aDadosTsk[nw][_RESOURCENAMES])
			aRelac := PmsReadRecs(nVersao,aDadosTsk[nw][_RESOURCENAMES],@aRecAmarr)
		Endif

		aRecAFA	:= {}
		dbSelectArea("AFA")
		dbSetOrder(1)
		MsSeek(xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
		While !Eof() .And. xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
							AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA
			If !Empty(AFA->AFA_RECURS)
				aAdd(aRecAFA,AFA->(RecNo()))
			EndIf
			dbSkip()
		EndDo
		For nz := 1 to Len(aRelac)
			AE8->(dbSetOrder(1))
			If AE8->(MsSeek(xFilial("AE8")+Substr(aRelac[nz,1],1,LEN(AE8->AE8_RECURS))))
				SB1->(dbSetOrder(1))
				SB1->(MsSeek(xFilial("AE8")+AE8->AE8_PRODUT))
				If nz <= Len(aRecAFA)
					AFA->(dbGoto(aRecAFA[nz]))
				Endif
				If AllTrim(Substr(aRelac[nz,1],1,LEN(AE8->AE8_RECURS)))==AllTrim(AFA->AFA_RECURS)
					PmsAvalAFA("AFA",2)
					RecLock("AFA",.F.)
					If lPMS010IM
						AFA->AFA_ALOC := ExecBlock("PMS010IM", .F., .F., {aRelac[nz,2]})
					Else
						If AFA->AFA_FIX == "1"
							If ChkTam("AFA_ALOC",aRelac[nz,2])
								AFA->AFA_ALOC  := aRelac[nz,2]
							Else
								AFA->AFA_ALOC  := 0
								PMSLogInt("AFA", .F.,,,I18N(STR0098,{AFA->AFA_ITEM,str(aRelac[nz][2])})) // "O item #1[numero]# recursos est?com o % de alocação superior ao tamanho do campo AFA_ALOC: #2[Horas de retardo]#"
							EndIf
							AFA->AFA_QUANT := (AFA->AFA_ALOC * PmsHrsItvl(AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,AF9->AF9_CALEND),AF9->AF9_PROJET,AE8->AE8_RECURS)) / 100
						Else
							nPosWork := aScan(aResources, {|x| SubStr(Upper(AllTrim(x[1])),1,At("-",Upper(AllTrim(x[1])))-1) == Upper(Alltrim(AE8->AE8_RECURS)) })

							If nPosWork > 0
								AFA->AFA_QUANT := aResources[nPosWork][2]
								AFA->AFA_ALOC  := (AFA->AFA_QUANT * 100) / PmsHrsItvl(AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,AF9->AF9_CALEND),AF9->AF9_PROJET,AE8->AE8_RECURS)
							Else
								AFA->AFA_QUANT := (AFA->AFA_ALOC*PmsHrsItvl(AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,AF9->AF9_CALEND),AF9->AF9_PROJET,AE8->AE8_RECURS))/100
							EndIf
						EndIf
					EndIf

					AFA->AFA_DATPRF	:= AF9->AF9_START
					AFA->AFA_START	:= AF9->AF9_START
					AFA->AFA_HORAI	:= AF9->AF9_HORAI
					AFA->AFA_FINISH	:= AF9->AF9_FINISH
					AFA->AFA_HORAF	:= AF9->AF9_HORAF
					nBuffer++
					PmsAvalAFA("AFA",1)
				Else
					If nz <= Len(aRecAFA)
						PmsAvalAFA("AFA",2)
						PmsAvalAFA("AFA",3)
						RecLock("AFA",.F.)
					Else
						RecLock("AFA",.T.)
					EndIf
					AFA->AFA_FILIAL	:= xFilial("AFA")
					AFA->AFA_ITEM	:= StrZero(nz, nTamAFAIte)
					AFA->AFA_PROJET	:= AF9->AF9_PROJET
					AFA->AFA_REVISA	:= AF9->AF9_REVISA
					AFA->AFA_TAREFA	:= AF9->AF9_TAREFA
					AFA->AFA_RECURS	:= Substr(aRelac[nz,1],1,LEN(AE8->AE8_RECURS))
					AFA->AFA_FIX    := cAFA_FIX

					If lPMS010IM
						AFA->AFA_ALOC := ExecBlock("PMS010IM", .F., .F., {aRelac[nz,2]})
					Else
						If ChkTam("AFA_ALOC",aRelac[nz,2])
							AFA->AFA_ALOC	:= aRelac[nz,2]
						Else
							AFA->AFA_ALOC  := 0
							PMSLogInt("AFA", .F.,,,I18N(STR0098,{AFA->AFA_ITEM,str(aRelac[nz][2])})) // "O item #1[numero]# recursos est?com o % de alocação superior ao tamanho do campo AFA_ALOC: #2[Horas de retardo]#"
						EndIf
						AFA->AFA_QUANT 	:= (AFA->AFA_ALOC*PmsHrsItvl(AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,AF9->AF9_CALEND),AF9->AF9_PROJET,AE8->AE8_RECURS))/100
					EndIf

					AFA->AFA_DATPRF	:= AF9->AF9_START
					AFA->AFA_START	:= AF9->AF9_START
					AFA->AFA_HORAI	:= AF9->AF9_HORAI
					AFA->AFA_FINISH	:= AF9->AF9_FINISH
					AFA->AFA_HORAF	:= AF9->AF9_HORAF

					If !Empty(AE8->AE8_PRODUT)
						AFA->AFA_PRODUT	:= AE8->AE8_PRODUT
						IF lPMSVLRPRD .and. Execblock("PMSVLRPRD",.F.,.F.)
							AFA->AFA_CUSTD	:= RetFldProd(SB1->B1_COD,"B1_CUSTD")
						Else
							AFA->AFA_CUSTD	:= AE8->AE8_VALOR
						Endif
						AFA->AFA_MOEDA	:= VAL(SB1->B1_MCUSTD)
					Else
						AFA->AFA_CUSTD	:= AE8->AE8_VALOR
						AFA->AFA_MOEDA	:= 1
					EndIf
					nBuffer++
					PmsAvalAFA("AFA",1)
				EndIf
			EndIf
		Next
		If Len(aRecAFA)>Len(aRelac) .and. !lUsaTxt30
			For nz := Len(aRelac)+1 to Len(aRecAFA)
				AFA->(dbGoto(aRecAFA[nz]))
				PmsAvalAFA("AFA",2)
				PmsAvalAFA("AFA",3)
				RecLock("AFA",.F.,.T.)
				dbDelete()
				MsUnlock()
			Next
		EndIf
		aRelac := {}
		aAuxArea	:= AF9->(GetArea())
		If !empty(aDadosTsk[nw,_PREDECESSORS])
			aRelac := PmsReadRela(nVersao,aDadosTsk[nw,_PREDECESSORS],aDadosTsk, _ORDEM,_TEXT1)
		Endif
		aAtuAFD	:= {}
		aRecAFD	:= {}
		dbSelectArea("AFD")
		dbSetOrder(1)
		MsSeek(xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
		While !Eof() .And. xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
							AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA
			aAdd(aRecAFD,AFD->(RecNo()))
			dbSkip()
		EndDo

		// RELACIONAMENTOS EDT -> TAREFA
		aAtuAJ4	:= {}
		aRecAJ4	:= {}
		dbSelectArea("AJ4")
		dbSetOrder(1)
		MsSeek(xFilial("AJ4")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
		While !Eof() .And. xFilial("AJ4")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
						AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA
			aAdd(aRecAJ4,AJ4->(RecNo()))
			dbSkip()
		EndDo

		AF9->(dbSetOrder(1))
		AFC->(dbSetOrder(1))
		For nz := 1 to Len(aRelac)
			// busca pela tarefa predecessora
			If AF9->(MsSeek(xFilial("AF9")+AF8->AF8_PROJET+AF8->AF8_REVISA+aRelac[nz][1]))
				RestArea(aAuxArea)
				If nz > Len(aRecAFD)
					RecLock("AFD",.T.)
				Else
					AFD->(dbGoto(aRecAFD[nz]))
					RecLock("AFD",.F.)
				EndIf
				AFD->AFD_FILIAL	:= xFilial("AFD")
				AFD->AFD_PROJET	:= AF9->AF9_PROJET
				AFD->AFD_REVISA	:= AF9->AF9_REVISA
				AFD->AFD_TAREFA	:= AF9->AF9_TAREFA
				AFD->AFD_ITEM		:= STRZERO(nz,nTamAFDIte)
				AFD->AFD_PREDEC	:= aRelac[nz][1]
				AFD->AFD_TIPO		:= aRelac[nz][2]
				If ChkTam("AFD_HRETAR",aRelac[nz][3])
					AFD->AFD_HRETAR	:= aRelac[nz][3]
				Else
					AFD->AFD_HRETAR	:= 0
					PMSLogInt("AFD", (nz > Len(aRecAFD)),,,I18N(STR0099,{AFD->AFD_ITEM,str(aRelac[nz][3])})) //"O item #1[numero]# de relacionamento de tarefa tem horas de retardo superior ao tamanho do campo AFD_HRETAR: #2[Horas de retardo]#"
				EndIf

				aAdd(aAtuAFD, AFD->(recno()))

				nBuffer++
			Else
				// busca pela EDT predecessora
				If AFC->(MsSeek(xFilial("AFC")+AF8->AF8_PROJET+AF8->AF8_REVISA+aRelac[nz][1]))
					RestArea(aAuxArea)
					If nz > Len(aRecAJ4)
						RecLock("AJ4",.T.)
					Else
						AJ4->(dbGoto(aRecAJ4[nz]))
						RecLock("AJ4",.F.)
					EndIf
					AJ4->AJ4_FILIAL	:= xFilial("AJ4")
					AJ4->AJ4_PROJET	:= AF9->AF9_PROJET
					AJ4->AJ4_REVISA	:= AF9->AF9_REVISA
					AJ4->AJ4_TAREFA	:= AF9->AF9_TAREFA
					AJ4->AJ4_ITEM		:= STRZERO(nz,nTamAJ4Ite)
					AJ4->AJ4_PREDEC	:= aRelac[nz][1]
					AJ4->AJ4_TIPO		:= aRelac[nz][2]
					If ChkTam("AJ4_HRETAR",aRelac[nz][3])
						AJ4->AJ4_HRETAR	:= aRelac[nz][3]
					Else
						AJ4->AJ4_HRETAR	:= 0
						PMSLogInt("AJ4", (nz > Len(aRecAJ4)),,,I18N(STR0100,{AJ4->AJ4_ITEM,str(aRelac[nz][3])}))//"O item #1[numero]# de relacionamento de EDT tem horas de retardo superior ao tamanho do campo AFD_HRETAR: #2[Horas de retardo]#"
					EndIf

					aAdd(aAtuAJ4, AJ4->(recno()))
					nBuffer++
				Else
					// Não encontrou relacionametno equivalente no PMS
					CONOUT("Não encontrou relacionamento equivalente.")
			   EndIf
			EndIf
		Next nZ

		If Len(aRecAFD)> 0 .and. !lUsaTxt30
			For nz := 1 to Len(aRecAFD) // relacionamentos do PMS
				nC := aScan(aAtuAFD,{|x|x ==aRecAFD[nz] }) // relacionamentos do project incluido/alterado no pms
				If nC == 0
					AFD->(dbGoto(aRecAFD[nz]))
					RecLock("AFD",.F.,.T.)
					dbDelete()
					MsUnlock()
					nBuffer++
				EndIf
			Next nZ
		EndIf

		If Len(aRecAJ4)> 0 .and. !lUsaTxt30
			For nz := 1 to Len(aRecAJ4) // relacionamentos do PMS
				nC := aScan(aAtuAJ4,{|x|x ==aRecAJ4[nz] }) // relacionamentos do project incluido/alterado no pms
				If nC == 0
					AJ4->(dbGoto(aRecAJ4[nz]))
					RecLock("AJ4",.F.,.T.)
					dbDelete()
					MsUnlock()
					nBuffer++
				EndIf
			Next nZ
		EndIf

		If nBuffer > 3000
			AFP->(MsUnlockAll())
			AFF->(MsUnlockAll())
			AFA->(MsUnlockAll())
			AFD->(MsUnlockAll())
			AJ4->(MsUnlockAll())
			nBuffer:= 0
		Endif
		RestArea(aAuxArea)
	endif
next nw // Len(aDadosTsk) = processa os relacionamentos da tarefa

If nBuffer > 0
	AFP->(MsUnlockAll())
	AFF->(MsUnlockAll())
	AFA->(MsUnlockAll())
	AFD->(MsUnlockAll())
	AJ4->(MsUnlockAll())
Endif

If Len(aDadosTsk) > 0
	IncProc(STR0042) //"Atualizando Datas do projeto!"
	dbSelectArea("AF9")
	dbSetOrder(1)

	cProjeto := PadR(AF8->AF8_PROJETO, Len(AF8->AF8_PROJETO))
	cRevisa  := AF8->AF8_REVISA
	aDtAFY	:= PmsChkAFY(cProjeto)

	cAliasTmp := GetNextAlias()

	BeginSQL Alias cAliasTmp

	SELECT AF9.R_E_C_N_O_ RecAF9

	FROM %table:AF9% AF9

	WHERE AF9.AF9_FILIAL = %xfilial:AF9%
			AND AF9.AF9_PROJET = %exp:cProjeto%
			AND AF9.AF9_REVISA = %exp:cRevisa%
			AND AF9.%NotDel%
	ORDER BY %Order:AF9%

	EndSql

	While (cAliasTmp)->(!Eof())
		AF9->(DbGoTo((cAliasTmp)->RecAF9))

		cCalend := AF9->AF9_CALEND

		If aScan(aRecAF9,AF9->(RecNo()))>0

			If AF9->AF9_START==AF9->AF9_FINISH
				cAloc	:= ""
				nDuracao := PmsPeriodo(AF9->AF9_START,"00"+AF9->AF9_HORAI,"00"+AF9->AF9_HORAF,cCalend,cAloc,aDtAFY)
			Else
				nDuracao := 0
				dStart	:= AF9->AF9_START
				dFinish	:= AF9->AF9_FINISH
				cAloc	:= ""
				nDuracao := PmsPeriodo(AF9->AF9_START,"00"+AF9->AF9_HORAI,"0024:00",cCalend,cAloc,aDtAFY)
				dStart++
				While dStart <= dFinish
					cAloc	:= ""
					If dStart==dFinish
						nDuracao += PmsPeriodo(dStart,"0000:00","00"+AF9->AF9_HORAF,cCalend,cAloc,aDtAFY)
					Else
						nDuracao += PmsPeriodo(dStart,"0000:00","0024:00",cCalend,cAloc,aDtAFY)
					EndIf
					dStart++
				EndDo
			EndIf
			RecLock("AF9")
			AF9->AF9_HDURAC := nDuracao
			AF9->AF9_HUTEIS := nDuracao
			MsUnlock()

		ElseIf !lUsaTxt30

			If (cExcTrfPms == "N" .And. GeralApp( AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA ) )
				if PMSShowWar() <> 2
					Aviso(STR0034,STR0035,{STR0033},2) //"Atencao"###"Existem apontamentos para esta tarefa, portanto nao pode ser excluida!"###"Fechar"
				endif
				if PMSShowWar() <> 1
					PMSLogInt("AF9" , .F. ,'D',cLogPath,STR0035)
				endif
			else
				PMSLogInt("AF9" , .F. ,'D',cLogPath)
				MaDelAF9(,,,AF9->(RecNo()))

			EndIf

		EndIf

		(cAliasTmp)->(DbSkip())
	EndDo

	(cAliasTmp)->(DbCloseArea())
	dbSelectArea("AF9")
	dbSetOrder(1)

	If !lUsaTxt30
		IncProc(STR0019) //"Recalculando datas do projeto..."
		dbSelectArea("AFC")
		dbSetOrder(1)
		MsSeek(xFilial("AFC")+AF8->AF8_PROJET+AF8->AF8_REVISA)
		While !Eof() .And. xFilial("AFC")+AF8->AF8_PROJET+AF8->AF8_REVISA==AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA
			If aScan(aRecAFC,AFC->(Recno()))<=0  .and. AFC->AFC_NIVEL <> cNivelOne
				PMSLogInt("AFC" , .F., 'D',cLogPath)
				MaDelAFC(,,,AFC->(RecNo()))
			EndIf
			AFC->(dbSkip())
		EndDo
	Endif

	IncProc()

	// Atualiza as datas previstas e realizadas das edts
	P010EDTATU(AF8->AF8_PROJET, AF8->AF8_REVISA)

	// recalcula o custo do projeto, a partir das tarefas
	PMS200ReCalc()

	If !lUsaTxt30
		dbSelectArea("AFD")
		dbSetOrder(1)
		MsSeek(xFilial("AFD")+AF8->AF8_PROJET+AF8->AF8_REVISA)
		While !Eof() .And. xFilial("AFD")+AF8->AF8_PROJET+AF8->AF8_REVISA==AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA
			dbSelectArea("AF9")
			dbSetOrder(1)
			If !MsSeek(xFilial("AF9")+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_PREDEC)
				RecLock("AFD",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
			dbSelectArea("AFD")
			dbSkip()
		EndDo
	Endif

	If !lUsaTxt30
		dbSelectArea("AJ4")
		dbSetOrder(1)
		MsSeek(xFilial("AJ4")+AF8->AF8_PROJET+AF8->AF8_REVISA)
		While !Eof() .And. xFilial("AJ4")+AF8->AF8_PROJET+AF8->AF8_REVISA==AJ4->AJ4_FILIAL+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA
			dbSelectArea("AFC")
			dbSetOrder(1)
			If !MsSeek(xFilial("AFC")+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA+AJ4->AJ4_PREDEC)
				RecLock("AJ4",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
			dbSelectArea("AJ4")
			dbSkip()
		EndDo
	Endif

Endif

IncProc()
oApp:VISIBLE:= .T.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Aux010Sinc
Programa de Exportacao do Projeto com o MS-Project

@author Edson Maricate
@since 09-02-2001
@version P10 R4

@param cAlias,,
@param nReg,,
@param nOpcx,,
@param oApp,,
@param nVersao,,
@param cArquivo,,
@param lRecurso,,
@param lAloc,,
@param lRelac,,
@param lPOC,,
@param lStruct,,
@param aEDTs,,
@param nIDProject,,

@return

/*/
//-------------------------------------------------------------------
Function Aux010Sinc(cAlias,nReg,nOpcx,oApp,nVersao,cArquivo,lRecurso,lAloc,lRelac,lPOC,lStruct,aEDTs,nIDProject)

Local aCalAFY		:=	{}
Local aCalBase  	:= {PJSUNDAY, PJMONDAY, PJTUESDAY, PJWEDNESDAY, PJTHURSDAY, PJFRIDAY, PJSATURDAY}
Local aCalend		:= {}
Local aProject	:= {}
Local aRecursos	:= {}
Local aSH7			:=	{}
Local cTempPath 	:= GetTempPath()
Local lAfyMaloc 	:= .F.
Local lP010AFCVL 	:= ExistBlock("P010AFCVL")
Local lP010ATab 	:= ExistBlock("P010ATab")
Local lRet 		:= .T.
Local nQtdTsk 	:= 0 // quantidade de tarefas j?existente no arquivo do project (*.MPP)
Local nx 			:= 0
Local oProject

DEFAULT lStruct := .T.

Private cFilialAE8 	:= xFilial("AE8") // utilizado na funcao PmcAddPrj
Private cFilialAF9 	:= xFilial("AF9") // utilizado na funcao PmcAddPrj
Private cFilialAFA 	:= xFilial("AFA") // utilizado na funcao PmcAddPrj
Private cFilialAFC 	:= xFilial("AFC") // utilizado na funcao PmcAddPrj
Private lExpWork		:= GetMv("MV_PMSWORK",,.F.) // utilizado na funcao PmcAddPrj
Private lP010AF9S		:= ExistBlock("P010AF9S") // utilizado na funcao PmcAddPrj
Private lP010AFCS		:= ExistBlock("P010AFCS") // utilizado na funcao PmcAddPrj
Private lPMA010FR		:= ExistBlock("PMA010FR")
Private lPMSSetFld 	:= ExistBlock("PMSSetFld") // utilizado na funcao PmcAddPrj
Private nTamAF9Ord	:= TamSx3('AF9_ORDEM')[1]
Private nTamAFCOrd	:= TamSx3('AFC_ORDEM')[1]

If Right(cTempPath,1) $ '/\'
	cTempPath	:=	Substr(cTempPath,1,Len(cTempPath)-1)
Endif

PmsIncProc(.T.,,STR0023)//'Inicializando MS Project'

oApp:VISIBLE:= .F.
If cArquivo <> Nil .And. !Empty(cArquivo)
	__CopyFile( cArquivo , cTempPath+"\INTEGRACAO_MSPROJECT.MPP" )
	oApp:FileOpen(cTempPath+"\INTEGRACAO_MSPROJECT.MPP")
Else
	oApp:Projects:Add(.F.)

	// altera os campos exibidos pelo MS-Project
	oApp:TableEdit( 'Ap6View', .T.,.T. , .T.,    ,'ID' ,               ,        , 6	, PJCENTER, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER )
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Text1'       , STR0001, 15,  PJLEFT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER ) //'Codigo'
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Name'		   , STR0002 , 24,  PJLEFT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER )  //'Nome da Tarefa'
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Number1'     , STR0003,  10, PJRIGHT, .T., .T., , 1, ,PJCENTER )  //"Quantidade"
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Text2'       , STR0004,  8, PJRIGHT, .T., .T., , 1, ,PJCENTER )  //"UM"
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Duration'    , STR0005,  9, PJRIGHT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER ) //"Duracao"
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Start'       , STR0006, 12, PJRIGHT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER ) //"Inicio"
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Finish'      , STR0007, 12, PJRIGHT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER ) //"Fim"
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'PercentComplete'  , STR0008, 12,  PJLEFT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER ) //"% Concluida"
	
	If lP010ATab
		ExecBlock("P010ATab",.F.,.F.,{oApp})
	EndIf
	oApp:TableApply( 'Ap6View' )
EndIf

// Entende-se que o ultimo "projeto" adicionado é o que será trabalhado
nIDProject := oApp:Projects:GetCount()

// obtem a planilha do project atual
oProject := oApp:Projects(nIDProject)

// armazena a quantidade de tarefas existentes na planilha que est?sendo aberta.
nQtdTsk := oProject:Tasks:Count

// carrega os calendarios do sistema no MS-Project
PmsIncProc(.T.,,STR0043) //"Exportando calendarios..."
dbSelectArea("SH7")
dbSetOrder(1)
dbSeek(xFilial("SH7"))
While !Eof() .And. SH7->H7_FILIAL == xFilial("SH7")
	oApp:BaseCalendarCreate(SH7->H7_CODIGO)
	aCalend := PmsCalend(SH7->H7_CODIGO)
	AAdd(aSH7,SH7->H7_CODIGO)
	For nx := 1 to Len(aCalend)
		lWork := !Empty(aCalend[nx, 2]) .or. !Empty(aCalend[nx, 3]) .or. ;
			!Empty(aCalend[nx, 4]) .or. !Empty(aCalend[nx, 5]) .or. ;
			!Empty(aCalend[nx, 6]) .or.  !Empty(aCalend[nx, 7]) .or. ;
			!Empty(aCalend[nx, 8]) .or. !Empty(aCalend[nx, 9]) .or. ;
			!Empty(aCalend[nx, 10]) .or. !Empty(aCalend[nx, 11])

		oApp:BaseCalendarEditDays(SH7->H7_CODIGO, , , aCalBase[aCalend[nx, 1]], lWork ,PmsWrHora(nVersao,aCalend[nx, 2]), PmsWrHora(nVersao,aCalend[nx, 3]),;
				PmsWrHora(nVersao,aCalend[nx, 4]), PmsWrHora(nVersao,aCalend[nx, 5]),PmsWrHora(nVersao,aCalend[nx, 6]),PmsWrHora(nVersao,aCalend[nx, 7]),,PmsWrHora(nVersao,aCalend[nx, 8]),PmsWrHora(nVersao,aCalend[nx, 9]),;
				PmsWrHora(nVersao,aCalend[nx, 10]), PmsWrHora(nVersao,aCalend[nx, 11]))
	Next
	SH7->( dbSkip() )
EndDo
/*
Parâmetros de BaseCalendarEditDays() :
Name			Required/Optional	Data Type	Description

Name			Required				String		String. The name of the base calendar to change.
StartDate	Optional				Variant		The first date to change. If StartDate is specified without EndDate, that date is the only day affected. If WeekDay is specified, StartDate is ignored.
EndDate		Optional				Variant		The last date to change. If EndDate is specified without StartDate, that date is the only day affected. If WeekDay is specified, EndDate is ignored.
WeekDay		Optional				Long			The weekday to change. If StartDate or EndDate is specified, WeekDay is ignored. Can be one of the PjWeekday constants.
Working		Optional				Boolean		True if the days are working days.
From1			Optional				Variant		The start time of the first shift.
To1			Optional				Variant		The end time of the first shift.
From2			Optional				Variant		The start time of the second shift.
To2			Optional				Variant		The end time of the second shift.
From3			Optional				Variant		The start time of the third shift.
To3			Optional				Variant		The end time of the third shift.
Default		Optional				Boolean		Resets the dates specified by StartDate and EndDate, or by WeekDay, to the default values. If Working is specified, Default is ignored.
From4			Optional				Variant		The start time of the fourth shift.
To4			Optional				Variant		The end time of the fourth shift.
From5			Optional				Variant		The start time of the fifth shift.
To5			Optional				Variant		The end time of the fifth shift.
*/
DbSelectArea("AFY")
DbSetOrder(1) // AFY_FILIAL+AFY_PROJET+AFY_RECURS+DTOS(AFY_DATA)
dbSeek(xFilial("AFY"))
While AFY->(!EOF()) .AND. AFY->AFY_FILIAL == xFilial("AFY")
	If Empty(AFY->AFY_PROJET) .or. (AFY->AFY_PROJET==AF8->AF8_PROJET)
		aExcpt := {}
		aExcpt := PMSExcecpt(AFY->AFY_MALOC)
		lWork := !Empty(aExcpt[1, 2]) .or. !Empty(aExcpt[1, 3]) .or. ;
			!Empty(aExcpt[1, 4]) .or. !Empty(aExcpt[1, 5]) .or. ;
			!Empty(aExcpt[1, 6]) .or.  !Empty(aExcpt[1, 7]) .or. ;
			!Empty(aExcpt[1, 8]) .or. !Empty(aExcpt[1, 9]) .or. ;
			!Empty(aExcpt[1, 10]) .or. !Empty(aExcpt[1, 11])
		For nx := 1 to Len(aSH7)
			oApp:BaseCalendarEditDays(aSH7[nx], AFY->AFY_DATA, , , lWork ,PmsWrHora(nVersao,aExcpt[1, 2]), PmsWrHora(nVersao,aExcpt[1, 3]),;
				PmsWrHora(nVersao,aExcpt[1, 4]), PmsWrHora(nVersao,aExcpt[1, 5]),PmsWrHora(nVersao,aExcpt[1, 6]),PmsWrHora(nVersao,aExcpt[1, 7]),,PmsWrHora(nVersao,aExcpt[1, 8]),PmsWrHora(nVersao,aExcpt[1, 9]),;
				PmsWrHora(nVersao,aExcpt[1, 10]), PmsWrHora(nVersao,aExcpt[1, 11]))
		Next nx
	Endif
	AFY->(DbSkip())
EndDo
/* Ainda temos que implementar
oApp:ProjectSummaryInfo(,,,,,,,,,,,,AF8->AF8_CALEND)
oApp:BaseCalendars("123").WeekDays(1).Shift2.Finish
oApp:BaseCalendars("123").WeekDays(1).Shift2.Finish
*/
If lRecurso .AND. !lUsaAJT

	// carrega os recursos do sistema no MS-Project
	dbSelectArea("AE8")
	dbSetOrder(1)
	dbSeek(cFilialAE8)
	While !Eof() .And. cFilialAE8==AE8->AE8_FILIAL
		If lPMA010FR
			If !ExecBlock("PMA010FR", .F., .F.)
				dbSkip()
				Loop
			EndIf
		EndIf
		PmsIncProc(.T.,,STR0024)//'Exportando planilha de recursos...'
		If AE8->AE8_ATIVO <> "2"
			aAdd(aRecursos, AllTrim(AE8->AE8_RECURS) + "-" + AllTrim(AE8->AE8_DESCRI))
			aAdd(aRecAmarr, { AE8->AE8_RECURS+"-"+AE8->AE8_DESCRI, AllTrim(AE8->AE8_RECURS) + "-" + AllTrim(AE8->AE8_DESCRI)} )
			oProject:Resources:Add( AllTrim(AE8->AE8_RECURS)+"-"+AllTrim(AE8->AE8_DESCRI) )
			If nVersao == 2
				oProject:Resources(Len(aRecursos)):SetField('PJRESOURCETYPE',If(AE8->AE8_TIPO=="1","Material","Work") )  //'Material'###'Trabalho'
			ElseIf nVersao	==	3
				oProject:Resources(Len(aRecursos)):SetField('PJRESOURCETYPE',If(AE8->AE8_TIPO=="1","Material","Trabajo") )
  			Else
				oProject:Resources(Len(aRecursos)):SetField('PJRESOURCETYPE',If(AE8->AE8_TIPO=="1","Material","Trabalho") )  //'Material'###'Trabalho'
  			Endif
			oProject:Resources(Len(aRecursos)):SetField('PJRESOURCEINITIALS',AllTrim(AE8->AE8_RECURS))  //'Material'###'Trabalho'

			// Para exportar as Unidades Maximas do recurso e necessario converter para string e concatenar o %
			// O MS-Project analisara e mostrara os valores corretamente formatados, de acordo com a configuracao
			// do usuario (Tools -> Options -> Schedule -> Show Assignments Units As)
			oProject:Resources(Len(aRecursos)):SetField('PJRESOURCEMAXUNITS', Str(AE8->AE8_UMAX) + '%')
			If Ascan(aSH7,AE8->AE8_CALEND) > 0
				oProject:Resources(Len(aRecursos)):SetField('PJRESOURCEBASECALENDAR', AE8->AE8_CALEND )
			Endif
		EndIf
		dbSelectArea("AE8")
		dbSkip()
	End
ElseIf lAloc .AND. !lUsaAJT

	// carrega somente os recusos alocados no projeto no MS-Project
	PmsIncProc(.T.,,STR0025)//'Exportando recursos alocados...'
	dbSelectArea("AFA")
	dbSetOrder(1)
	dbSeek(cFilialAFA+AF8->AF8_PROJET+AF8->AF8_REVISA)
	While !Eof() .And. cFilialAFA+AF8->AF8_PROJET+AF8->AF8_REVISA==AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA
		AE8->(dbSetOrder(1))
		AE8->(dbSeek(cFilialAE8+AFA->AFA_RECURS))
		If !Empty(AFA->AFA_RECURS) .And. aScan(aRecursos,AllTrim(AE8->AE8_RECURS) + "-" + AllTrim(AE8->AE8_DESCRI))<=0
			If lPMA010FR
				If !ExecBlock("PMA010FR", .F., .F.)
					AFA->( dbSkip() )
					Loop
				EndIf
			EndIf

			PmsIncProc(.T.,,STR0025)//'Exportando recursos alocados...'
			If AE8->AE8_ATIVO<>"2"
				aAdd(aRecursos, AllTrim(AE8->AE8_RECURS) + "-" + AllTrim(AE8->AE8_DESCRI))
				aAdd(aRecAmarr, { AE8->AE8_RECURS+"-"+AE8->AE8_DESCRI, AllTrim(AE8->AE8_RECURS) + "-" + AllTrim(AE8->AE8_DESCRI)} )
				oProject:Resources:Add( AllTrim(AE8->AE8_RECURS)+"-"+AllTrim(AE8->AE8_DESCRI) )
				If nVersao	==	2
					oProject:Resources(Len(aRecursos)):SetField('PJRESOURCETYPE',If(AE8->AE8_TIPO=="1","Material","Work") )  //'Material'###'Trabalho'
				ElseIf nVersao	==	3
					oProject:Resources(Len(aRecursos)):SetField('PJRESOURCETYPE',If(AE8->AE8_TIPO=="1","Material","Trabajo" ) )
   				Else
					oProject:Resources(Len(aRecursos)):SetField('PJRESOURCETYPE',If(AE8->AE8_TIPO=="1","Material","Trabalho") )  //'Material'###'Trabalho'
   				Endif

				oProject:Resources(Len(aRecursos)):SetField('PJRESOURCEINITIALS',AllTrim(AE8->AE8_RECURS))  //'Material'###'Trabalho'

				// Para exportar as Unidades Maximas do recurso e necessario converter para string e concatenar o %
				// O MS-Project analisara e mostrara os valores corretamente formatados, de acordo com a configuracao
				// do usuario (Tools -> Options -> Schedule -> Show Assignments Units As)
				oProject:Resources(Len(aRecursos)):SetField('PJRESOURCEMAXUNITS', Str(AE8->AE8_UMAX) + '%')
				If Ascan(aSH7,AE8->AE8_CALEND) > 0
					oProject:Resources(Len(aRecursos)):SetField('PJRESOURCEBASECALENDAR', AE8->AE8_CALEND )
				Endif
			EndIf
		EndIf
		AFA->( dbSkip() )
	EndDo
EndIf

// Adiciona no array aProject as tarefas do Project. Para assim gerar corretamente os relacionamentos baseados
For nX := 1 To nQtdTsk
	aAdd(aProject ,{" ", 0 ," "})
Next nX

// se for pra exportar a estrutura do projeto
If lStruct
	// carrega o Projeto
	PmsIncProc(.T.,,STR0026)//'Exportando projeto...'
	dbSelectArea("AFC")
	dbSetOrder(3)
	MsSeek(cFilialAFC+AF8->AF8_PROJET+AF8->AF8_REVISA+"001")
	While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
						AFC->AFC_NIVEL==cFilialAFC+AF8->AF8_PROJET+AF8->AF8_REVISA+"001"
		If lP010AFCVL
			lRet := ExecBlock("P010AFCVL", .F., .F.)
			If ValType(lRet) == "L" .And. !lRet
				AFC->(dbSkip())
				Loop
			EndIf
		EndIf
		PmcAddPrj(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,oApp,aProject,aRecursos,nVersao,lAloc,lPOC,aEDTs,@nIdProject)
		AFC->(dbSkip())
	EndDo

	If lRelac
		PmsIncProc(.T.,,STR0027)//'Exportando relacionamentos...'

		// adiciona as predecessoras da tarefa
		dbSelectArea("AFD")
		dbSetOrder(1)
		MsSeek(xFilial("AFD")+AF8->AF8_PROJET+AF8->AF8_REVISA)
		While !Eof() .And. xFilial("AFD")+AF8->AF8_PROJET+AF8->AF8_REVISA==;
							AFD_FILIAL+AFD_PROJET+AFD_REVISA

			nTask := aScan(aProject,{|x| x[3] == AFD->AFD_PREDEC })
			nTask2:= aScan(aProject,{|x| x[3] == AFD->AFD_TAREFA })
			Do Case
				Case AFD->AFD_TIPO == "1"
					oApp:LinkTasksEdit( nTask ,nTask2,,PJFINISHTOSTART,Alltrim(Str(Round(AFD->AFD_HRETAR,0))) + " h")
				Case AFD->AFD_TIPO == "2"
					oApp:LinkTasksEdit( nTask,nTask2,,PJSTARTTOSTART,Alltrim(Str(Round(AFD->AFD_HRETAR,0))) + " h")
				Case AFD->AFD_TIPO == "3"
					oApp:LinkTasksEdit( nTask,nTask2,,PJFINISHTOFINISH,Alltrim(Str(Round(AFD->AFD_HRETAR,0))) + " h")
				Case AFD->AFD_TIPO == "4"
					oApp:LinkTasksEdit( nTask,nTask2,,PJSTARTTOFINISH,Alltrim(Str(Round(AFD->AFD_HRETAR,0))) + " h")
			EndCase
			AFD->(dbSkip())
		EndDo

		// adiciona as predecessoras da tarefa
		dbSelectArea("AJ4")
		dbSetOrder(1)
		MsSeek(xFilial("AJ4")+AF8->AF8_PROJET+AF8->AF8_REVISA)
		While !Eof() .And. xFilial("AJ4")+AF8->AF8_PROJET+AF8->AF8_REVISA==;
							AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA

			nTask := aScan(aProject,{|x| x[3] == AJ4->AJ4_PREDEC })
			nTask2:= aScan(aProject,{|x| x[3] == AJ4->AJ4_TAREFA })
			Do Case
				Case AJ4->AJ4_TIPO == "1"
					oApp:LinkTasksEdit( nTask ,nTask2,,PJFINISHTOSTART,Alltrim(Str(Round(AJ4->AJ4_HRETAR,0))) + " h")
				Case AJ4->AJ4_TIPO == "2"
					oApp:LinkTasksEdit( nTask,nTask2,,PJSTARTTOSTART,Alltrim(Str(Round(AJ4->AJ4_HRETAR,0))) + " h")
				Case AJ4->AJ4_TIPO == "3"
					oApp:LinkTasksEdit( nTask,nTask2,,PJFINISHTOFINISH,Alltrim(Str(Round(AJ4->AJ4_HRETAR,0))) + " h")
				Case AJ4->AJ4_TIPO == "4"
					oApp:LinkTasksEdit( nTask,nTask2,,PJSTARTTOFINISH,Alltrim(Str(Round(AJ4->AJ4_HRETAR,0))) + " h")
			EndCase
			AJ4->(dbSkip())
		EndDo
	EndIf
EndIf
oApp:VISIBLE:= .T.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PmcAddPrj
Exporta a EDT e as tarefas para o MS-Project

@author Edson Maricate
@since 09-02-2001
@version P10 R4

@param cChave,,
@param oApp,,
@param aProject,,
@param aRecursos,,
@param nVersao,,
@param lAloc,,
@param lPOC,,
@param aEDTs,,
@param nIDProject,,

@return

/*/
//-------------------------------------------------------------------
Static Function PmcAddPrj(cChave,oApp,aProject,aRecursos,nVersao,lAloc,lPOC,aEDTs,nIDProject)
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFC	:= AFC->(GetArea())
Local aDadosWork 	:= {}
Local aNodes 		:= {}
Local aRecAFA		:= {}
Local cDataRest 	:= ""
Local cHoraI		:= ""
Local cHoraF    	:= ""
Local cHoraRest 	:= ""
Local cNo      	:= IIF( nVersao == 2 /*ingles*/, "NO", IIf( nVersao == 3 /*espanhol*/, "NO", "NAO" ) )
Local cRecursos 	:= ""
Local cTipoAg  	:= ""
Local cTipoRest 	:= ""
Local cTipoTrf	:= ""
Local cValWork	:= ""
Local cYes     	:= IIF( nVersao == 2 /*ingles*/, "YES", IIf( nVersao == 3 /*espanhol*/, "SI", "SIM" ) )
Local lPMS010EX 	:= ExistBlock("PMS010EX")
Local lRetAF9   	:= .T.
Local lRetAFC		:= .T.
Local nNode  		:= 0
Local nPerc		:= 0
Local nValWork	:= 0
Local oProject

DEFAULT nIDProject := 1

oProject := oApp:Projects(nIDProject)

PmsIncProc(.T.,,STR0028+AFC->AFC_EDT+"'")//"Exportando EDT '"
If lExpWork
	aDadosWork := PmsQryWork() // inicializa a tabela temporária de trabalho realizado (AFU)
Endif

If PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,1,"ESTRUT",AFC->AFC_REVISA).And. (aEDTs==Nil .Or. aScan(aEDTs, {|x| x==AFC->AFC_EDT}) > 0)

	If Val(AFC->AFC_NIVEL) > 1 // Não se trata da EDT Principal(Tarefa resumo do projeto)
		// adiciona a EDT no MS-Project
		aAdd(aProject,{"AFC",AFC->(RecNo()),AFC->AFC_EDT})
		oProject:Tasks:Add(AllTrim(StrGantt(AFC->AFC_DESCRI)))
		oProject:Tasks(Len(aProject)):Calendar	:= AFC->AFC_CALEND
		oProject:Tasks(Len(aProject)):Text1	:= AFC->AFC_EDT

		oProject:Tasks(Len(aProject)):SetField('PJTASKACTUALSTART',SUBSTR(DTOC(AFC->AFC_START),1,8)+ " " + AFC->AFC_HORAI)
		oProject:Tasks(Len(aProject)):SetField('PJTASKOUTLINELEVEL',Val(AFC->AFC_NIVEL)-1)
		oProject:Tasks(Len(aProject)):SetField('PJTASKNUMBER1', PMSPonVir(Str(AFC->AFC_QUANT)))
		oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT2',AFC->AFC_UM)
		oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT23',AFC->AFC_EDT)
		oProject:Tasks(Len(aProject)):SetField('PJTASKSUMMARY' ,cYes )

		// Na versão do MS-Project 2013, a coluna Modo de tarefa interfere
		// na atribuicao de valores nas seguintes propriedades da tarefa:
		//      tipo de restricao
		//      data de restricao
		//      tipo de tarefa
		//      controlada por empenho
		//      o agendamento ignora calendarios do recurso
		// Para resolver isso, o modo de tarefa deve ser alterado para automatico, atribuir as
		// propriedades citadas e por fim retornar para manual
		oProject:Tasks(Len(aProject)):SetField('PJTASKMANUAL', '0') // Altero o modo de tarefa como automatico

		If nVersao == 2 // ingles

			Do Case
				Case AFC->AFC_RESTRI == "1"
					cTipoRest := "Start no earlier than"

				Case AFC->AFC_RESTRI == "2"
					cTipoRest := "Finish no later than"

				Case AFC->AFC_RESTRI == "3"
					cTipoRest := "As soon as possible"

				Otherwise
					cTipoRest := ""
			EndCase

		ElseIf nVersao == 3    //espanhol

			Do Case
				Case AFC->AFC_RESTRI == "1"
					cTipoRest := "No comenzar antes del"

				Case AFC->AFC_RESTRI == "2"
					cTipoRest := "No finalizar después del"

				Case AFC->AFC_RESTRI == "3"
					cTipoRest := "Lo antes posible"

				Otherwise
					cTipoRest := ""
			EndCase

		Else

			Do Case
				Case AFC->AFC_RESTRI == "1"
						cTipoRest := "Não iniciar antes de"

				Case AFC->AFC_RESTRI == "2"
					cTipoRest := "Não terminar depois de"

				Case AFC->AFC_RESTRI == "3"
					cTipoRest := "O Mais Breve Possível"

				Otherwise
					cTipoRest := ""
			Endcase

		Endif

		oProject:Tasks(Len(aProject)):SetField('PJTASKCONSTRAINTTYPE', cTipoRest)

		// exporta da data e hora de restricao da EDT
		If !Empty(AFC->AFC_DTREST)
			cDataRest := strZero(Day(AFC->AFC_DTREST),2)+"/"+strZero(Month(AFC->AFC_DTREST),2,0)+"/"+Right(strZero(Year(AFC->AFC_DTREST),4),2) // garantindo o formato em DD/MM/YY
			cHoraRest := AFC->AFC_HRREST

			oProject:Tasks(Len(aProject)):SetField('PJTASKCONSTRAINTDATE', cDataRest + " " + cHoraRest)
		EndIf

		If !Empty(AFC->AFC_START)
			oProject:Tasks(Len(aProject)):SetField('PJTASKSTART', strZero(Day(AFC->AFC_START),2)+"/"+strZero(Month(AFC->AFC_START),2,0)+"/"+Right(strZero(Year(AFC->AFC_START),4),2)+" "+AFC->AFC_HORAI) // garantindo o formato em DD/MM/YY
		Endif
		If !Empty(AFC->AFC_FINISH)
			oProject:Tasks(Len(aProject)):SetField('PJTASKFINISH', strZero(Day(AFC->AFC_FINISH),2)+"/"+strZero(Month(AFC->AFC_FINISH),2)+"/"+Right(strZero(Year(AFC->AFC_FINISH),4),2)+" "+AFC->AFC_HORAF ) // garantindo o formato em DD/MM/YY
		EndIf

		oProject:Tasks(Len(aProject)):Duration := '0 h'

		oProject:Tasks(Len(aProject)):SetField('PJTASKMANUAL', '1') // Altero o modo de tarefa como manual

		oProject:Tasks(Len(aProject)):SetField('PJTASKWORK', AFC->AFC_HESF)

		If lPMSSetFld
			ExecBlock("PMSSetFld", .F. , .F. , {oProject, 1, Len(aProject)} )
		Endif
	EndIf
EndIf

dbSelectArea("AF9")
dbSetOrder(2)
MsSeek(cFilialAF9+cChave)
While !Eof() .And. AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+;
					AF9->AF9_EDTPAI==cFilialAF9+cChave

	If lP010AF9S
		lRetAF9 := ExecBlock("P010AF9S", .F., .F.)
		If ValType(lRetAF9) == "L" .And. !lRetAF9
			AF9->(dbSkip())
			Loop
		EndIf
	EndIf

	aAdd(aNodes, {PMS_TASK,;
	              AF9->(Recno()),;
	              If(Empty(AF9->AF9_ORDEM), StrZero(0,nTamAF9Ord), AF9->AF9_ORDEM),;
	              AF9->AF9_TAREFA})
		AF9->(dbSkip())
Enddo

dbSelectArea("AFC")
dbSetOrder(2)
MsSeek(cFilialAFC+cChave)
While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
			AFC->AFC_EDTPAI==cFilialAFC+cChave

	If lP010AFCS
		lRetAFC := ExecBlock("P010AFCS", .F., .F.)
		If ValType(lRetAFC) == "L" .And. !lRetAFC
			AFC->(dbSkip())
			Loop
		EndIf
	EndIf

	aAdd(aNodes, {PMS_WBS,;
	              AFC->(Recno()),;
	              If(Empty(AFC->AFC_ORDEM), StrZero(0,nTamAFCOrd), AFC->AFC_ORDEM),;
	              AFC->AFC_EDT})
		AFC->(dbSkip())
End

aSort(aNodes, , , {|x, y| x[3]+x[4] < y[3]+y[4]})

cTipoRest := ""
cDataRest := ""
cHoraRest := ""
cTipoAg   := ""
cTipoTrf  := ""

For nNode := 1 To Len(aNodes)
	If aNodes[nNode][1] == PMS_TASK
		AF9->(dbGoto(aNodes[nNode][2]))

		PmsIncProc(.T.,,STR0029+AF9->AF9_TAREFA+"'")//"Exportando Tarefa '"
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,1,"ESTRUT",AF9->AF9_REVISA) .And. (aEDTs==Nil .Or. aScan(aEDTs, {|x| x==AF9->AF9_EDTPAI}) > 0)

			cDataI := IIf(!Empty(AF9->AF9_START),strZero(Day(AF9->AF9_START),2)+"/"+strZero(Month(AF9->AF9_START),2,0)+"/"+Right(strZero(Year(AF9->AF9_START),4),2),NIL) // garantindo o formato em DD/MM/YY
			cDataF := IIf(!Empty(AF9->AF9_FINISH),strZero(Day(AF9->AF9_FINISH),2)+"/"+strZero(Month(AF9->AF9_FINISH),2)+"/"+Right(strZero(Year(AF9->AF9_FINISH),4),2),NIL) // garantindo o formato em DD/MM/YY
			cHoraI := AF9->AF9_HORAI
			cHoraF := AF9->AF9_HORAF
			cTipoRest := ""
			aAdd(aProject,{"AF9",AF9->(RecNo()),AF9->AF9_TAREFA})
			oProject:Tasks:Add(AllTrim(StrGantt(AF9->AF9_DESCRI)))

			oProject:Tasks(Len(aProject)):Calendar	:= AF9->AF9_CALEND
			oProject:Tasks(Len(aProject)):Text1	:= AF9->AF9_TAREFA

			If cDataI <> Nil
				oProject:Tasks(Len(aProject)):SetField('PJTASKACTUALSTART', cDataI + " " + cHoraI )
			EndIf
			oProject:Tasks(Len(aProject)):SetField('PJTASKNUMBER1', PMSPonVir(Str(AF9->AF9_QUANT)))
			oProject:Tasks(Len(aProject)):SetField('PJTASKOUTLINELEVEL',Val(AF9->AF9_NIVEL)-1)
			oProject:Tasks(Len(aProject)):SetField('PJTASKPRIORITY',Max(AF9->AF9_PRIORI,0))
			oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT2',AF9->AF9_UM)
			oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT23',AF9->AF9_TAREFA)
			If lExpWork
				cValWork :=	PmsGetWork(aDadosWork)
				oProject:Tasks(Len(aProject)):SetField('PJTASKDURATION1', cValWork )
			Endif

			// Na versão do MS-Project 2013, a coluna Modo de tarefa interfere
			// na atribuicao de valores nas seguintes propriedades da tarefa:
			//      tipo de restricao
			//      data de restricao
			//      tipo de tarefa
			//      controlada por empenho
			//      o agendamento ignora calendarios do recurso
			// Para resolver isso, o modo de tarefa deve ser alterado para automatico, atribuir as
			// propriedades citadas e por fim retornar para manual
			oProject:Tasks(Len(aProject)):SetField('PJTASKMANUAL', '0') // Altero o modo de tarefa como automatico

			// converte o tipo de restricao para
			// exportar para o MS-Project

			If nVersao == 2 // Microsoft Project 2000 em ingles

				Do Case

					// iniciar
					Case AF9->AF9_RESTRI == "1"
							cTipoRest := "Must Start On"

					// terminar
					Case AF9->AF9_RESTRI == "2"

						cTipoRest := "Must Finish On"

					// nao iniciar antes
					Case AF9->AF9_RESTRI == "3"
						cTipoRest := "Start No Earlier Than"

					// nao iniciar depois
					Case AF9->AF9_RESTRI == "4"
						cTipoRest := "Start No Later Than"

					// nao terminar antes
					Case AF9->AF9_RESTRI == "5"
						cTipoRest := "Finish No Earlier Than"

					// nao terminar depois
					Case AF9->AF9_RESTRI == "6"
						cTipoRest := "Finish No Later Than"

					// o mais breve
					Case AF9->AF9_RESTRI == "7"
						cTipoRest := "As Soon As Possible"

					// o mais tarde
					Case AF9->AF9_RESTRI == "8"
						cTipoRest := "As Late As Possible"

				EndCase
			ElseIf nVersao == 3  // Microsoft Project 2000 em espanhol

				Do Case
					// iniciar
					Case AF9->AF9_RESTRI == "1"
						cTipoRest := "Debe comenzar el"

					// terminar
					Case AF9->AF9_RESTRI == "2"

						cTipoRest := "Debe finalizar el"

					// nao iniciar antes
					Case AF9->AF9_RESTRI == "3"
						cTipoRest := "No comenzar antes del"

					// nao iniciar depois
					Case AF9->AF9_RESTRI == "4"
						cTipoRest := "No comenzar después del"

					// nao terminar antes
					Case AF9->AF9_RESTRI == "5"
						cTipoRest := "No finalizar antes del"

					// nao terminar depois
					Case AF9->AF9_RESTRI == "6"
						cTipoRest := "No finalizar después del"

					// o mais breve
					Case AF9->AF9_RESTRI == "7"
						cTipoRest := "Lo antes posible"

					// o mais tarde
					Case AF9->AF9_RESTRI == "8"
						cTipoRest := "Lo más tarde posible"

				EndCase
			Else // Microsoft Project 2000 em portugues

				Do Case

					// iniciar
					Case AF9->AF9_RESTRI == "1"
							cTipoRest := "Deve iniciar em"

					// terminar
					Case AF9->AF9_RESTRI == "2"

						cTipoRest := "Deve terminar em"

					// nao iniciar antes
					Case AF9->AF9_RESTRI == "3"
						cTipoRest := "Não iniciar antes de"

					// nao iniciar depois
					Case AF9->AF9_RESTRI == "4"
						cTipoRest := "Não iniciar depois de"

					// nao terminar antes
					Case AF9->AF9_RESTRI == "5"
						cTipoRest := "Não terminar antes de"

					// nao terminar depois
					Case AF9->AF9_RESTRI == "6"
						cTipoRest := "Não terminar depois de"

					// o mais breve
					Case AF9->AF9_RESTRI == "7"
						cTipoRest := "O mais breve possível"

					// o mais tarde
					Case AF9->AF9_RESTRI == "8"
						cTipoRest := "O mais tarde possível"
				EndCase
			EndIf

		 	oProject:Tasks(Len(aProject)):SetField('PJTASKCONSTRAINTTYPE', cTipoRest)

			// exporta da data da restricao
			// da tarefa
			If !Empty(AF9->AF9_DTREST)
				cDataRest := strZero(Day(AF9->AF9_DTREST),2)+"/"+strZero(Month(AF9->AF9_DTREST),2,0)+"/"+Right(strZero(Year(AF9->AF9_DTREST),4),2) // garantindo o formato em DD/MM/YY
				cHoraRest := AF9->AF9_HRREST

				oProject:Tasks(Len(aProject)):SetField('PJTASKCONSTRAINTDATE', cDataRest + " " + cHoraRest)
			EndIf

			If cDataI <> Nil
				oProject:Tasks(Len(aProject)):Start	:= cDataI + " " + cHoraI
				oProject:Tasks(Len(aProject)):SetField('PJTASKBASELINESTART', cDataI  + " " + cHoraI)
				If cDataF <> Nil
					oProject:Tasks(Len(aProject)):SetField('PJTASKBASELINEFINISH', cDataF  + " " + cHoraF)
				EndIf
				oProject:Tasks(Len(aProject)):SetField('PJCUSTOMTASKDATE1', strZero(Day(AF9->AF9_DTATUI),2)+"/"+strZero(Month(AF9->AF9_DTATUI),2,0)+"/"+Right(strZero(Year(AF9->AF9_DTATUI),4),2)) // garantindo o formato em DD/MM/YY
				oProject:Tasks(Len(aProject)):SetField('PJCUSTOMTASKDATE2', strZero(Day(AF9->AF9_DTATUF),2)+"/"+strZero(Month(AF9->AF9_DTATUF),2,0)+"/"+Right(strZero(Year(AF9->AF9_DTATUF),4),2)) // garantindo o formato em DD/MM/YY
			Endif
			oProject:Tasks(Len(aProject)):Duration := Alltrim(TransForm(AF9->AF9_HDURAC,"@E 999999999.99")) +' h'

			oProject:Tasks(Len(aProject)):SetField('PJTASKMANUAL', '1') // Altero o modo de tarefa como manual

			If nVersao==2 // Microsoft Project em ingles
				Do Case

					Case AF9->AF9_AGCRTL == '1'
						cTipoAg 	:= 'Yes'
					Case AF9->AF9_AGCRTL == '2'
						cTipoAg 	:= 'No'

				EndCase

			Elseif nVersao == 3 // Microsoft Project em espanhol
				Do Case

					Case AF9->AF9_AGCRTL == '1'
						cTipoAg 	:= 'Sí'
					Case AF9->AF9_AGCRTL == '2'
						cTipoAg 	:= 'No'

				EndCase

			Else

				Do Case

					Case AF9->AF9_AGCRTL == '1'
						cTipoAg 	:= 'Sim'
					Case AF9->AF9_AGCRTL == '2'
						cTipoAg 	:= 'Não'

				EndCase

			Endif

			//Alimenta campo de agendamento da tarefa
			oProject:Tasks(Len(aProject)):SetField('pjTaskEffortDriven', cTipoAg)

			If nVersao==2
			// Microsoft Project em ingles
				Do Case

					Case AF9->AF9_TPTRF == '1'
						cTipoTrf 	:= 'Fixed Duration'
					Case AF9->AF9_TPTRF == '2'
						cTipoTrf 	:= 'Fixes Work'
					Case AF9->AF9_TPTRF == '3'
						cTipoTrf 	:= 'Fixed Units'

				EndCase

			Elseif nVersao == 3
				// Microsoft Project em espanhol
				Do Case

					Case AF9->AF9_TPTRF == '1'
						cTipoTrf 	:= 'Yes'
					Case AF9->AF9_TPTRF == '2'
						cTipoTrf 	:= 'No'
					Case AF9->AF9_TPTRF == '3'
						cTipoTrf 	:= 'No'

				EndCase

			Else

				Do Case

					Case AF9->AF9_TPTRF == '1'
						cTipoTrf 	:= 'Duração fixa'
					Case AF9->AF9_TPTRF == '2'
						cTipoTrf 	:= 'Trabalho fixo'
					Case AF9->AF9_TPTRF == '3'
						cTipoTrf 	:= 'Unidades fixas'

				EndCase

			Endif

			//Alimenta campo de "tipo da tarefa" no PROJECT
			oProject:Tasks(Len(aProject)):SetField('PJTASKTYPE', cTipoTrf)

			oProject:Tasks(Len(aProject)):SetField('PJTASKSUMMARY' ,cNo )

			oProject:Tasks(Len(aProject)):SetField('PJTASKMANUAL', '1') // Altero o modo de tarefa como manual

			// adiciona os recursos da tarefa
			If lAloc
				aRecAFA	:=	{}
				cRecursos := ''
				dbSelectArea("AFA")
				dbSetOrder(1)
				MsSeek(cFilialAFA+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
				While !Eof() .And. cFilialAFA+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
									AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA
					If !Empty(AFA->AFA_RECURS)
						AE8->(dbSetOrder(1))
						If AE8->(dbSeek(cFilialAE8+AFA->AFA_RECURS))
							If lPMS010EX
								nAFAAloc := ExecBlock("PMS010EX", .F., .F., {AFA->AFA_ALOC})
							Else
								nAFAAloc := AFA->AFA_ALOC
							EndIf
							If Ascan(aRecAFA,AFA->AFA_RECURS) == 0
								cRecursos += AllTrim(AE8->AE8_RECURS)+"-"+AllTrim(AE8->AE8_DESCRI)+"[" + Str(nAFAAloc,4,0)  + "%];"
								AAdd(aRecAFA,AFA->AFA_RECURS)
							Endif
						Endif
					EndIf
					AFA->( dbSkip() )
				EndDo
			EndIf

			// A ordem de atribuir valor no MS-Project para os campos Duracao, Nomes do Recurso e trabalho é definido pelo Tipo de Tarefa

			Do Case
				Case AF9->AF9_TPTRF == '1' // Duração Fixa
					oProject:Tasks(Len(aProject)):Duration := Alltrim(TransForm(AF9->AF9_HDURAC,"@E 999999999.99")) +' h'
					oProject:Tasks(Len(aProject)):ResourceNames := cRecursos
					oProject:Tasks(Len(aProject)):SetField('PJTASKWORK', AF9->AF9_HESF)
				Case AF9->AF9_TPTRF == '2' // Esforco fixo (trabalho fixo)
					oProject:Tasks(Len(aProject)):ResourceNames := cRecursos
					oProject:Tasks(Len(aProject)):SetField('PJTASKWORK', AF9->AF9_HESF)
					oProject:Tasks(Len(aProject)):Duration := Alltrim(TransForm(AF9->AF9_HDURAC,"@E 999999999.99")) +' h'
				Case AF9->AF9_TPTRF == '3' // Unidades fixas
					oProject:Tasks(Len(aProject)):ResourceNames := cRecursos
					oProject:Tasks(Len(aProject)):SetField('PJTASKWORK', AF9->AF9_HESF)
					oProject:Tasks(Len(aProject)):Duration := Alltrim(TransForm(AF9->AF9_HDURAC,"@E 999999999.99")) +' h'
			EndCase

			oProject:Tasks(Len(aProject)):SetField('PJTASKSUMMARY' ,cNo )

			If lPOC
				nPerc := PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataBase)
				oProject:Tasks(Len(aProject)):SetField('PJTASKPERCENTCOMPLETE',Round( nPerc ,0))
			EndIf

			If lPMSSetFld
				ExecBlock("PMSSetFld", .F. , .F. , {oProject, 2, Len(aProject)} )
			Endif

		EndIf
	Else
		AFC->(dbGoto(aNodes[nNode][2]))

		PmcAddPrj(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,oApp,aProject,aRecursos,nVersao,lAloc,lPOC,aEDTs,nIdProject)
	EndIf

Next nNode

RestArea(aAreaAFC)
RESTAREA(aAreaAF9)
RestArea(aArea)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Pmc010Cod

Integracao do Projeto com o MS-Project.

@author Edson Maricate
@since 29.10.2002
@version P10 R4

@param nulo, nulo, nulo

@return nulo

/*/
//-------------------------------------------------------------------
Static Function Pmc010Cod(cAlias,cProjeto,cRevisa,cCodWBS,cCodDig, aTask,lAdNivel)
Local aArea		:= GetArea()
Local aAreaAFC	:= {}
Local aAreaAF9	:= {}
Local cRetCod
Local cNivelAFC	:= ""
Local cNivelAF9	:= ""
Local cNivelOne	:= STRZERO(1, nTamAF9Niv)

If cAlias == "AFC"
	aAreaAFC := AFC->(GetArea())
	cNivelAFC	:= STRZERO(VAL(aTask[_OUTLINELEVEL]), nTamAFCNiv)

	If !Empty(cCodDig)
		dbSelectArea("AFC")
		dbSetOrder(1)
		If dbSeek(xFilial("AFC")+cProjeto+cRevisa+cCodDig) .Or. Len(AllTrim(cCodDig))>Len(AFC->AFC_EDT)
			cRetCod := PmsNumAFC(AF8->AF8_PROJET,AF8->AF8_REVISA,If(Empty(aEDTPAI),cNivelOne,aEDTPAI[Len(aEDTPAI),2]),If(Empty(aEDTPAI),AF8->AF8_PROJET,aEDTPAI[Len(aEDTPAI),1]))
		Else
			cRetCod := cCodDig
		EndIf
	Else
		cRetCod := PmsNumAFC(AF8->AF8_PROJET,AF8->AF8_REVISA,If(Empty(aEDTPAI),cNivelOne,cNivelAFC),If(Empty(aEDTPAI),AF8->AF8_PROJET,PC010EdtPai(aEDTPAI,aTask,lAdNivel)))
	EndIf
	RestArea(aAreaAFC)
Else
	aAreaAF9 := AF9->(GetArea())
	cNivelAF9	:= STRZERO(VAL(aTask[_OUTLINELEVEL]), nTamAF9Niv)
	If !Empty(cCodDig)
		dbSelectArea("AF9")
		dbSetOrder(1)
		If dbSeek(xFilial("AF9")+cProjeto+cRevisa+cCodDig) .Or. Len(AllTrim(cCodDig))>Len(AF9->AF9_TAREFA)
			cRetCod := PmsNumAF9(AF8->AF8_PROJET,AF8->AF8_REVISA,If(Empty(aEDTPAI),cNivelOne,aEDTPAI[Len(aEDTPAI),2]),If(Empty(aEDTPAI),AF8->AF8_PROJET,aEDTPAI[Len(aEDTPAI),1]))
		Else
			cRetCod := cCodDig
		EndIf
	Else
		cRetCod := PmsNumAF9(AF8->AF8_PROJET,AF8->AF8_REVISA,If(Empty(aEDTPAI),cNivelOne,cNivelAF9),If(Empty(aEDTPAI),AF8->AF8_PROJET,PC010EdtPai(aEDTPAI,aTask,lAdNivel)))
	EndIf
	RestArea(aAreaAF9)
EndIf

RestArea(aArea)
Return cRetCod


//-------------------------------------------------------------------
/*/{Protheus.doc} PC010EdtPai

(a definir)

@author Adriano Ueda
@since 15-06-2003
@version P10 R4

@param aEDTPai,,
@param aTask,,
@param lAdNivel,,

@return

/*/
//-------------------------------------------------------------------
Static Function PC010EdtPai(aEDTPai,aTask,lAdNivel)
Local cEdtPai := ""
Local cNivel	:= ""
Local lOk		:= .T.
Local nX 		:= Len(aEDTPai)

DEFAULT lAdNivel := .T.

If lAdNivel
	cNivel	:= STRZERO(VAL(aTask[_OUTLINELEVEL])+1, nTamAFCNiv)
Else
	cNivel	:= STRZERO(VAL(aTask[_OUTLINELEVEL]), nTamAFCNiv)
Endif

While (nX<>0) .and. lOk
	If (aEDTPai[nX,2] < cNivel)
		cEdtPai := aEDTPai[nX,1]
		lOk := .F.
	EndIf
	nX--
Enddo

Return cEdtPai


//-------------------------------------------------------------------
/*/{Protheus.doc} PMSPonVir

substitui o ponto por virgula e a virgula por ponto em uma string contendo um numero com casas decimais

@author Adriano Ueda
@since 15-06-2003
@version P10 R4

@param cText, caracter, o numero para substitui

@return cBuffer, caracter

/*/
//-------------------------------------------------------------------
Function PMSPonVir(cText)
Local cBuffer		:= "0"
Local nPosStrHora	:= At(" h", cText)
Local nPosPtoHrs	:= 0
Local nPosVirHrs	:= 0
Local nPosAnterior	:= 0

If  nPosStrHora > 0 .AND. Substr(cText,1,1) $ "123456789"
	nPosVirHrs	:= At(",",cText)
	nPosPtoHrs	:= At(".",cText)
	If nPosVirHrs <> 0 .AND. nPosPtoHrs <> 0	// Há PONTO e VÍRGULA na string analisada
		If nPosVirHrs > nPosPtoHrs
			// Se o posicionamento da VÍRGULA é posterior ao PONTO, então é porque a VÍRGULA é a separação dos DECIMAIS
			cText := StrTran(cText, ".", "") // Então, retira os PONTOS da string e deixa só a VÍRGULA
		Else
			// Se o posicionamento do PONTO é posterior à VÌRGULA, então é porque o PONTO é a separação dos DECIMAIS
			cText := StrTran(cText, ",", "") // Então, retira as VIRGULAS da string e deixa só o PONTO
		EndIf
	Else
		If nPosVirHrs > 0
			While nPosVirHrs > 0
				nPosAnterior	:= nPosVirHrs
				nPosVirHrs		:= At(",", cText, nPosVirHrs+1)
			EndDo
			If (nPosStrHora - nPosAnterior) > 3
				// Se a diferença entre o posicionamento da última "," e o " h" da string for maior que 3,
				// é porque identificou-se que a VÍRGULA é máscara de MILHAR
				cText := StrTran(cText, ",", "")	// Então, retiram-se as VÍRGULAS da string, e assim, não existirão VÍRGULAS de MILHAR na String
			EndIf
		EndIf
		If nPosPtoHrs > 0
			While nPosPtoHrs > 0
				nPosAnterior	:= nPosPtoHrs
				nPosPtoHrs		:= At(".", cText, nPosPtoHrs+1)
			EndDo
			If (nPosStrHora - nPosAnterior) > 3
				// Se a diferença entre o posicionamento do último "." e o " h" da string for maior que 3,
				// é porque identificou-se que o PONTO é máscara de MILHAR
				cText := StrTran(cText, ".", "")	// Então, retiram-se os PONTOS da string, e assim, não existirão PONTOS de MILHAR na String
			EndIf
		EndIf
	EndIf
	cText := StrTran(cText, ".", ",")	// Força VIRGULA como separador de DECIMAIS na String, pois logo mais abaixo, a VÍRGULA voltará a ser PONTO
EndIf

If ValType(cText) == "C" .and. ! Empty(cText)
	cBuffer := cText
	cBuffer := StrTran(cBuffer, ".", "[PON]")
	cBuffer := StrTran(cBuffer, ",", ".")
	cBuffer := StrTran(cBuffer, "[PON]", ",")
EndIf
Return cBuffer


//-------------------------------------------------------------------
/*/{Protheus.doc} PMSLogInt

Funcao para criacao de LOG .csv referente aos itens importados do MSProject para o SIGAPMS

@author Clovis Magenta
@since 29.10.2002
@version P10 R4

@param cAlias,,
@param lInclusao,,
@param cDelete,,
@param cPathLog,,
@param cMsg,,
@param lUnico,,

@return caracter, caminho e nome do arquivo

/*/
//-------------------------------------------------------------------
Function PMSLogInt( cAlias , lInclusao , cDelete, cPathLog, cMsg, lUnico)
Local aArea		:= GetArea()
Local cBarra		:= If( isSrvUnix(), "/", "\" )
Local cDirAnt		:= CurDir()
Local cTexto		:= ""
Local cSep			:= ";"
Local lRet			:= .T.
Local lCabec		:= .F.
Local lPMSEXCE1	:= ExistBlock("PMSEXCE1")
Local lPMSEXCE2	:= ExistBlock("PMSEXCE2")
Local nHandle		:= 0

Static  cPath		:= ""
Static  lArqUnico	:= NIL
Static  cArqLog	:= ""

DEFAULT lInclusao	:= .F.
DEFAULT cDelete 	:= ""
Default cPathLog	:= ""
Default cMsg		:= ""

// Caso nao exista, cria pasta \LOGPMS para armazenamento do log.
If Empty(cPathLog)
	if empty(cPath)
		cPath	:= GetSrvProfString("StartPath", "") + If( Right( GetSrvProfString("StartPath",""), 1 ) == cBarra, "", cBarra ) + "LOGPMS"
	endif
Else
	cPath := AllTrim(cPathLog)
	cPath += If( Right( cPath,1) == cBarra, "", cBarra )
EndIf

if lArqUnico = NIl .and. lUnico = NIL
	lArqUnico := .F.
elseif lUnico <> NIL
	lArqUnico := lUnico
endif


If Empty(cPath) .And. SubStr(AllTrim(cPath),Len(AllTrim(cPath)),1) != cBarra
	cPath := AllTrim(cPath) + cBarra
EndIf

if lUnico <> NIL

	cArqLog	:= "LOGPMS_" + AllTrim(AF8->AF8_PROJET) + "_" + Alltrim(AF8->AF8_REVISA)+ AllTrim( DtoS(dDatabase) ) + "_" + Substr(Time(),1,2) + Substr(Time(),4,2) +".CSV"

elseif !lArqUnico

	cArqLog	:= "LOGPMS_" + AllTrim(AF8->AF8_PROJET) + "_" + Alltrim(AF8->AF8_REVISA)+ AllTrim( DtoS(dDatabase) ) + "_" + Substr(Time(),1,2) + Substr(Time(),4,2) + ".CSV"

endif

if !Empty(cMsg)   // Ha avisos sendo logados
	PMSC10SetW(.T.)
endif

// Cria a pasta LOGPMS caso nao exista.
If !File( cPath )
	MakeDir(cPath)
EndIf

// Muda para pasta LOGPMS
If Empty(cPath)
	CurDir( cPath )
EndIf

// Tratamento para criacao do arquivo de log
If !File( cPath +cArqLog )
	lCabec	:= .T.
	nHandle := fCreate(cPath + cArqLog)
	If nHandle < 0
		nError := fError()
		// Nao foi possivel criar o arquivo de Log ### Erro numero:
		MsgAlert( STR0046 + cPath + cArqLog + ". " + 'Erro numero: ' + PadR( Str(nError), 4 ) ) // 'Nao foi possivel criar o arquivo de Log'
		lRet := .F.
	Else
		fClose(nHandle)
	EndIf
Endif

// Se conseguiu criar o arquivo, grava os dados de diferenca de saldo
If lRet

	nHandle := fOpen( cPath +cArqLog, 2 )
	fSeek( nHandle, 0, 2 )     // Posiciona no final do arquivo

 	// Se for arquivo novo, grava cabecalho
	If lCabec

		cTexto := "PROJETOS E TAREFAS" + cSep + "ALTERADAS " + cSep + cSep + cSep + cSep + cSep + cSep + cSep + cSep + cSep
		cTexto += "DADOS DA" + cSep + "IMPORTACAO PMS"

		fWrite( nHandle, cTexto + Chr(13) + Chr(10), Len(cTexto) + 2 )
		fSeek(  nHandle, 0, 2 )     // Posiciona no final do arquivo

		cTexto := 	"Usuário" 				+ cSep + "Data" 				+ cSep + "Tipo" 				+ cSep + "Projeto" 			+ cSep
		cTexto +=	"Cod. Tarefa"			+ cSep + "Descr. Tarefa"		+ cSep + "Alterado/Incluso"     + cSep + "Descrição"

		IF lPMSEXCE1
			cTexto := Execblock("PMSEXCE1", .F., .F., {cTexto, cSep, cAlias})
		Endif

		fWrite( nHandle, cTexto + Chr(13) + Chr(10), Len(cTexto) + 2 )
		fSeek(  nHandle, 0, 2 )     // Posiciona no final do arquivo

	EndIf

	// Grava linha de log no arquivo da pasta LOGPMS
	Do Case
		Case cAlias == 'AF8'

			cTexto := ToXLSFormat( AllTrim( Upper( cUserName ) ) ) + cSep
			cTexto += ToXLSFormat( DtoC( Date() ) ) 	+ cSep
			cTexto += ToXLSFormat( 'PROJETO'     ) 		+ cSep
			cTexto += ToXLSFormat( AF8->AF8_PROJET ) 	+ cSep
			cTexto += ToXLSFormat( AF8->AF8_DESCRI )	+ cSep
			If lInclusao
				cTexto += ToXLSFormat( 'Incluído' )	+ cSep
			ElseIf cDelete == "D"
				cTexto += ToXLSFormat( 'Deletado' )	+ cSep
			Else
				cTexto += ToXLSFormat( 'Alterado' )	+ cSep
			Endif

		Case cAlias == 'AF9' // Valores calculados e gravados

			cTexto := ToXLSFormat( AllTrim( Upper( cUserName ) ) ) + cSep
			cTexto += ToXLSFormat( DtoC( Date() ) ) 	+ cSep
			cTexto += ToXLSFormat( 'TAREFA'        ) 	+ cSep
			cTexto += ToXLSFormat( AF9->AF9_PROJET ) 	+ cSep
			cTexto += ToXLSFormat( AF9->AF9_TAREFA ) 	+ cSep
			cTexto += ToXLSFormat( AF9->AF9_DESCRI )	+ cSep
			If lInclusao
				cTexto += ToXLSFormat( 'Incluído' )	+ cSep
			ElseIf cDelete == "D"
				cTexto += ToXLSFormat( 'Deletado' )	+ cSep
			Else
				cTexto += ToXLSFormat( 'Alterado' )	+ cSep
			Endif

		Case cAlias == 'AFC'

			cTexto := ToXLSFormat( AllTrim( Upper( cUserName ) ) ) + cSep
			cTexto += ToXLSFormat( DtoC( Date() ) ) 	+ cSep
			cTexto += ToXLSFormat( 'EDT'          ) 	+ cSep
			cTexto += ToXLSFormat( AFC->AFC_PROJET ) 	+ cSep
			cTexto += ToXLSFormat( AFC->AFC_EDT    ) 	+ cSep
			cTexto += ToXLSFormat( AFC->AFC_DESCRI )	+ cSep
			If lInclusao
				cTexto += ToXLSFormat( 'Incluído' )	+ cSep
			Else
				cTexto += ToXLSFormat( 'Alterado' )	+ cSep
			Endif

		Case cAlias == 'AFD'
			cTexto := ToXLSFormat( AllTrim( Upper( cUserName ) ) ) + cSep
			cTexto += ToXLSFormat( 'Relacionamento entre Tarefas')+ cSep
			cTexto += ToXLSFormat( AF9->AF9_PROJET ) 	+ cSep
			cTexto += ToXLSFormat( AF9->AF9_TAREFA ) 	+ cSep
			cTexto += ToXLSFormat( AF9->AF9_DESCRI )	+ cSep
			If lInclusao
				cTexto += ToXLSFormat( 'Incluído' )	+ cSep
			Else
				cTexto += ToXLSFormat( 'Alterado' )	+ cSep
			Endif

		Case cAlias == 'AJ4'
			cTexto := ToXLSFormat( AllTrim( Upper( cUserName ) ) ) + cSep
			cTexto += ToXLSFormat( 'Relacionamento de Tarefa com EDT')+ cSep
			cTexto += ToXLSFormat( AF9->AF9_PROJET ) 	+ cSep
			cTexto += ToXLSFormat( AF9->AF9_TAREFA ) 	+ cSep
			cTexto += ToXLSFormat( AF9->AF9_DESCRI )	+ cSep
			If lInclusao
				cTexto += ToXLSFormat( 'Incluído' )	+ cSep
			Else
				cTexto += ToXLSFormat( 'Alterado' )	+ cSep
			Endif

		Case cAlias == 'AFA'
			cTexto := ToXLSFormat( AllTrim( Upper( cUserName ) ) ) + cSep
			cTexto += ToXLSFormat( 'Recurso alocado na Tarefa')+ cSep
			cTexto += ToXLSFormat( AF9->AF9_PROJET ) 	+ cSep
			cTexto += ToXLSFormat( AF9->AF9_TAREFA ) 	+ cSep
			cTexto += ToXLSFormat( AF9->AF9_DESCRI )	+ cSep
			If lInclusao
				cTexto += ToXLSFormat( 'Incluído' )	+ cSep
			Else
				cTexto += ToXLSFormat( 'Alterado' )	+ cSep
			Endif

	EndCase

	cTexto += ToXLSFormat( cMsg )	+ cSep

	IF lPMSEXCE2
		cTexto := Execblock("PMSEXCE2", .F., .F., {cTexto, cSep, cAlias})
	Endif

	fWrite( nHandle, cTexto + Chr(13) + Chr(10), Len(cTexto) + 2 )
	fSeek(  nHandle, 0, 2 )     // Posiciona no final do arquivo

EndIf

fClose( nHandle )

// Volta para pasta \system
CurDir( cBarra + cDirAnt )

RestArea( aArea )

Return( cPath +cArqLog )

//-------------------------------------------------------------------
/*/{Protheus.doc} PmsGetWork

Exportar quantidade de horas apontadas por recursos na coluna Duracao 1 do MSProject.

@author Clovis Magenta
@since 21/06/12
@version P10 R4

@param aDadosWork,,

@return cValWork

/*/
//-------------------------------------------------------------------
Static Function PmsGetWork(aDadosWork)
Local aArea		:= GetArea()
Local cValWork 	:= ""
Local nValWork	:= 0
Local nPos			:= 0

If (nPos := aScan(aDadosWork, {|x| x[1] == AF9->AF9_TAREFA})) > 0
	nValWork := aDadosWork[nPos][2]
Endif
cValWork := Alltrim(TransForm(nValWork,"@E 999999999.99")) +' h'

RestArea(aArea)

Return cValWork

//-------------------------------------------------------------------
/*/{Protheus.doc} PmsQryWork

Calcula a quantidade de horas apontadas nas tarefas do projeto

@author Clovis Magenta
@since 21/06/12
@version P10 R4

@param nulo,,

@return array

/*/
//-------------------------------------------------------------------
Static Function PmsQryWork()
Local aArea  		:= GetArea()
Local aDadosWork	:=	{}
Local cQuery 		:= ""
Local cTemp   	:= "_AFU"

cQuery += "SELECT AFU_FILIAL,AFU_PROJET,AFU_REVISA,AFU_TAREFA,SUM(AFU_HQUANT) AFU_HQUANT FROM " + RetSqlName("AFU")
cQuery += " WHERE D_E_L_E_T_ = '' "
cQuery += " AND AFU_CTRRVS = '1' "
cQuery += " AND AFU_PROJET = '"+AF8->AF8_PROJET+"'"
cQuery += " AND AFU_REVISA = '"+AF8->AF8_REVISA+"'"
cQuery += " GROUP BY AFU_FILIAL,AFU_PROJET,AFU_REVISA,AFU_TAREFA"
cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTemp , .T., .T.)

DbSelectArea(cTemp)
(cTemp)->(dbGoTop())

While (cTemp)->(!EOF())
	aadd(aDadosWork,{AFU_TAREFA , AFU_HQUANT})
	(cTemp)->(dbSkip())
Enddo

(cTemp)->(dbCloseArea())

RestArea(aArea)
Return aDadosWork


//-------------------------------------------------------------------
/*/{Protheus.doc} p010edtatu

Exportar quantidade de horas apontadas por recursos na coluna Duracao 1 do MSProject.

@author Clovis Magenta
@since 21/06/12
@version P11

@param cProjeto,,
@param cRevisa,,
@param cHrFim,,
@param cCalend,,
@param cAloc,,

@return

/*/
//-------------------------------------------------------------------
Static Function p010edtatu(cProjeto, cRevisa)
Local aSelectEDT := {}

	PMSLoadEDT(cProjeto, cRevisa, Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)), .T., .T., @aSelectEDT)
	PMSLoadEDT(cProjeto, cRevisa, Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)), .F., .T., @aSelectEDT)

	If !Empty(aSelectEDT)
	     aSort(aSelectEDT,,, {|x, y| y[2] < x[2] })
	     PMSEDTPrv(cProjeto, cRevisa, Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)), aSelectEDT)
	     PMSEDTReal(cProjeto, cRevisa, Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)), aSelectEDT)
	EndIf

return .t.


//-------------------------------------------------------------------
/*/{Protheus.doc} PmsPeriodo

Obtem o periodo em horas baseado no calendario
Observacao: Criado p/melhoria de performance do pmsc010a

@author Alex Egydio
@since 9.08.2012
@version P11

@param dData,,
@param cHrIni,,
@param cHrFim,,
@param cCalend,,
@param cAloc,,

@return

/*/
//-------------------------------------------------------------------
Static Function PmsPeriodo(dData,cHrIni,cHrFim,cCalend,cAloc,aDtAFY)
Local nDayWeek		:= DOW(dData)
Local nMinBit		:= 60 / nMV_PRECISA
Local nBitIni		:= Round((Val(Substr(cHrIni,3,2))*60+Val(Substr(cHrIni,6,2)))/nMinBit,0)+1
Local nBitFim		:= Round((Val(Substr(cHrFim,3,2))*60+Val(Substr(cHrFim,6,2)))/nMinBit,0)+1
Local nTamanho		:= 0
Local nHoras		:= 0
Local nSeek			:= 0

DEFAULT cAloc	:= ""
DEFAULT aDtAFY  :=  {}

nSeek := ASCan(aDtAFY,{|x| dData >= x[1] .And. dData <= x[2]})

If !Empty(aDtAFY) .And. nSeek > 0
	cAloc := aDtAFY[nSeek,3]
Else
	If Empty(cAloc) .Or. !(SH7->H7_CODIGO==cCalend)
		nDayWeek := If(nDayWeek==1,7,nDayWeek-1)
		SH7->(DbSetOrder(1))
		If	SH7->(MsSeek(xFilial("SH7")+cCalend))
			cAloc    := SH7->H7_ALOC
			nTamanho := Len(cAloc) / 7
		Else
			Conout("Calendario Cod. "+cCalend+" nao existe no cadastro de calendarios...")
		EndIf
		cAloc := Substr(cAloc,(nTamanho*(nDayWeek-1))+1,nTamanho)
	EndIf
EndIf

nHoras := ((Len(StrTran(Substr(cAloc,nBitIni,nBitFim-nBitIni)," ","")))*nMinBit)/60

Return(NoRound(nHoras,2))


//-------------------------------------------------------------------
/*/{Protheus.doc} PmsChkAFY

Excecoes ao Calendario
Observacao: Criado p/melhoria de performance do pmsc010a

@author Alex Egydio
@since 9.08.2012
@version P11

@param cProjeto,,

@return

/*/
//-------------------------------------------------------------------
Static Function PmsChkAFY(cProjeto)
Local aAreaAnt	:= GetArea()
Local aRet			:= {}
Local cAliasTmp	:= "PmsChkAFY"
Local cPrjAux		:= Space(Len(AFY->AFY_PROJET))
Local cAloc		:= ""

BeginSQL Alias cAliasTmp

SELECT AFY.R_E_C_N_O_ RecAFY

FROM %table:AFY% AFY

WHERE AFY.AFY_FILIAL = %xfilial:AFY%
		AND ( AFY.AFY_PROJET = %exp:cProjeto% OR AFY.AFY_PROJET = %exp:cPrjAux% )
		AND AFY.%NotDel%

ORDER BY %Order:AFY%

EndSql

While (cAliasTmp)->(!Eof())
	AFY->(DbGoTo( (cAliasTmp)->RecAFY ))

	cAloc := AFY->AFY_MALOC

	AAdd(aRet,{ AFY->AFY_DATA, AFY->AFY_DATAF, cAloc })

	(cAliasTmp)->(DbSkip())
EndDo
(cAliasTmp)->(DbCloseArea())

RestArea(aAreaAnt)
Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PMSC10SetW

Seta a variavel que indica se houve uma mensagem de erro logada

@author Alexandre Circenis
@since 19.03.2013
@version P11

@param lSet,,

@return

/*/
//-------------------------------------------------------------------
Function PMSC10SetW(lSet)
If ValType(lSet) = 'L'
	lWarning := lSet
endif
Return lWarning
