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
#define _IDPROJ				24
#define _TEXT26				25
#define _TEXT27				26
#define _TEXT28				27

STATIC _lAcesso := .F.
STATIC nTamNIVEL

//-------------------------------------------------------------------
/*/{Protheus.doc} Aux010BGrv
Programa de Sincronizacao do Projeto com o MS-Project

@author Edson Maricate
@since 09-02-2001
@version P10 R4

@param oProcess,,
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
@param MV_PMSTX30,,
@param lSemelhante,,
@param aRecAmarr,,
@param lUnico,,
@param nIDProject

@return

/*/
//-------------------------------------------------------------------
Function Aux010BGrv(oProcess, cAlias,nReg,nOpcx,oApp,nVersao,cArquivo,lRecurso,lAloc,lRelac,lPOC,MV_PMSTX30,lSemelhante,aRecAmarr,lUnico,nIdProject)

Local aAuxArea		:= {}
Local aDadosTsk 	:= {}
Local aDadosUsr		:= {}
Local aRecAF9 		:= {}
Local aRecAFA 		:= {}
Local aRecAFC 		:= {}
Local aRecAFD 		:= {}
Local aRecAJ4 		:= {}
Local aRelac		:= {}
Local aResources	:= {}
Local aRet 			:= {}
Local aTemp			:= {}
Local aTrbs			:= {}
Local nPosWork		:= {}

Local bContAFF 		:= .T.

Local cAFA_FIX 		:= CriaVar('AFA_FIX',.T.)
Local cAliasAFA 	:= RetSQLName("AFA")
Local cAliasAFD		:= RetSQLName("AFD")
Local cAliasAFP		:= RetSQLName("AFP")
Local cAliasTmp		:= getNextAlias()
Local cAllCalend	:= ""
Local cAllUM		:= ""
Local cCalend		:= ""
Local cCodUsr 		:= __cUserId
Local cExcTrfPms	:= SuperGetMv("MV_PMSTEXC",,"S")
Local cFilAE8 		:= xFilial("AE8")
Local cFilAFA 		:= xFilial("AFA")
Local cFilAFD		:= xFilial("AFD")
Local cFilAFF 		:= xFilial("AFF")
Local cFilAFP		:= xFilial("AFP")
Local cFilAJ4		:= xFilial("AJ4")
Local cFilSB1 		:= xFilial("SB1")
Local cHistCall		:= ""
Local cLogPath		:= ""
Local cMaxTsk		:= ""
Local cMens91		:= ""
Local cMens93		:= ""
Local cMens95		:= ""
Local cMensagem 	:= ""
Local cNivel		:= ""
Local cNivelOne		:= ""
Local cPictAF9 		:= ""
Local cPictAFC 		:= ""
Local cQrySelect	:= ""
Local cQuery		:= ""
Local cRestProject 	:= ""
Local cRetCod		:= ""
Local cTASKSUMMARY	:= ""
Local cTipoRest 	:= ""
Local cTipoTrf		:= ""
Local cYes       	:= ""

Local lAdNivel		:= .T.
Local lConsid26		:= .F.
Local lContinua		:= .T.
Local lFase91 		:= .F.
Local lFase93 		:= .F.
Local lFase95 		:= .F.
Local lInclusao		:= .T.
Local lIngles 		:= .F.
Local lLogCustom	:= ExistBlock("PMC010LOG")
Local lPergMais		:= .T.
Local lPMS010IM		:= ExistBlock("PMS010IM")
Local lPMSGetFld	:= ExistBlock("PMSGetFld")
Local lPMSPutFld	:= ExistBlock("PMSPutFld")
Local lPortugues	:= .F.
Local lRet 			:= .F.

Local i				:= 0
Local nAF9			:= 0
Local nC			:= 0
Local nConAFA		:= 0
Local nFieldAnt		:= 0
Local nMaxItem		:= 0
Local nMaxTsk		:= 0
Local nNivel1		:= 0
Local nPercComp		:= 0
Local nPosCal		:= ""
Local nStartMT 		:= SuperGetMv("MV_PMSQTMT",,200)
Local nT			:= 0
Local nTamAF9Ord	:= TamSx3('AF9_ORDEM')[1]
Local nTamAFAIte	:= TamSX3("AFA_ITEM")[1]
Local nTamAFCOrd	:= TamSx3('AFC_ORDEM')[1]
Local nTamAFDIte	:= TamSX3("AFD_ITEM")[1]
Local nTamAJ4Ite	:= TamSX3("AJ4_ITEM")[1]
Local nTamID		:= TamSX3("AFC_IDPROJ")[1]
Local nTamRec		:= TamSx3("AE8_RECURS")[1]
Local nw			:= 0
Local nz			:= 0
Local nE			:= 0
Local cEdtPai		:= ""
Local oProject
Local nEDTAnt		:= 0

Private aEDTPAI		:= {}
PRIVATE cFilAF9		:= xFilial("AF9")
PRIVATE cFilAFC 	:= xFilial('AFC')
Private cNivTX30 	:= ""
PRIVATE lHasCCT 	:= HasTemplate("CCT")
PRIVATE lNewCalend 	:= SuperGetMv("MV_PMSCALE" , .T. , .F. )
PRIVATE lTopConn	:= IfDefTopCTB()
Private nBuffer		:= 0
Private nTamAF9Niv	:= TamSX3("AF9_NIVEL")[1]
Private nTamAFCNiv	:= TamSX3("AFC_NIVEL")[1]

DEFAULT lUnico		:= .F.
DEFAULT nIDProject  := 1

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

oProcess:SetRegua1(8) // defino a quantidade de processos

oProcess:IncRegua1(STR0018) //"Importação do arquivo do MS-Project"
oProcess:SetRegua2(nMaxTsk) // defino a quantidade de processos

For nw := 1 to nMaxTsk

	oProcess:IncRegua2(STR0036+" "+AllTrim(Str(nw))+" "+STR0037+" "+cMaxTsk+ " "+STR0038)  //"Importando "##" de "##" tarefas do MS-Project..."

	//
	// Retorno se ?uma EDT, isto ? para o project se ?uma tarefa resumo.
	//
	cTASKSUMMARY := PmsReadTsk(nw,PJTASKSUMMARY)
	cTASKSUMMARY := Upper(Alltrim(cTASKSUMMARY))

	If MV_PMSTX30
		cTxt30 := PmsReadTsk(nw , PJCUSTOMTASKTEXT30)
		lContinua := cTxt30 == "1"
	Endif

	IF lContinua
		If cTASKSUMMARY==cYes

			aadd(aDadosTsk ,{	Val(PMSPonVir(PmsReadTsk(nw,PJTASKNUMBER1))); 							// AFC->AFC_QUANT := Val(PMSPonVir(aDadosPrj[nw][nx])
								, 	PmsReadData(nVersao, PmsReadTsk(nw,PJTASKSTART)); 						// AFC->AFC_START := PmsReadData(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadHora(nVersao, PmsReadTsk(nw,PJTASKSTART)); 						// AFC->AFC_HORAI := PmsReadHora(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadData(nVersao, PmsReadTsk(nw,PJTASKFINISH)); 						// AFC->AFC_FINISH:= PmsReadData(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadHora(nVersao, PmsReadTsk(nw,PJTASKFINISH)); 						// AFC->AFC_HORAF := PmsReadHora(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadCale(nVersao, PmsReadTsk(nw,PJTASKCALENDAR),@cAllCalend); 	// AFC->AFC_CALEND	:= PmsReadCale(nVersao,aDadosPrj[nw][nx]),@cAllCalend)
								, 	ALLTRIM(PmsReadTsk(nw,PJTASKNAME)); 														// AFC->AFC_DESCRI
								, 	PmsReadUM(PmsReadTsk(nw,PJTASKTEXT2) , AFC->AFC_DESCRI,@cAllUM); 	// AFC->AFC_UM := PmsReadUM(aDadosPrj[nw][nw],AFC->AFC_DESCRI,@cAllUM)
								, 	PmsReadTsk(nw,PJTASKID);														// AFC->AFC_ORDEM := StrZero(Val(aDadosPrj[nw][nw]),TamSx3('AFC_ORDEM')[1])
								, 	UPPER(PmsReadTsk(nw,PJTASKCONSTRAINTTYPE)); 						// AFC->AFC_RETRI := UPPER(aDadosPrj[nw][nx])
								, 	PmsReadData(nVersao,PmsReadTsk(nw,PJTASKCONSTRAINTDATE));		// AFC->AFC_DTREST := PmsReadData(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadHora(nVersao,PmsReadTsk(nw,PJTASKCONSTRAINTDATE));				// AFC->AFC_HRREST := PmsReadHora(nVersao,aDadosPrj[nw][nx])
								, 	Val(PMSPonVir(PmsReadTsk(nw,PJTASKWORK))); 						// AFC->AFC_HESF := Val(PMSPonVir(aDadosPrj[nw][nx]))
								, 	" " ; 		// AF9->AF9_AGCRTL
								, 	Val(PmsReadTsk(nw,PJTASKPRIORITY));	  								// AF9->AF9_PRIORI	:= Val(aDadosPrj[nw][nx])
								,	PmsReadTsk(nw,PJTASKTEXT1);
								,	PmsReadTsk(nw,PJTASKOUTLINELEVEL);
								,	PmsReadTsk(nw,PJTASKPERCENTCOMPLETE);
								,	PmsReadTsk(nw,PJTASKPREDECESSORS);
					  			,	PmsReadTsk(nw,PJTASKRESOURCENAMES);
								,	"resource work";
								, 	"AFC";  //ALIAS
								,	PmsReadTsk(nw,PJTASKTYPE); // tipo da tarefa  25
								,	PadR(PmsReadTsk(nw,PJTASKTEXT29),TAMSX3("AFC_IDPROJ")[1]); //_IDPROJ        26
								,	PmsReadTsk(nw,PJTASKTEXT26); //_TEXT26      27
								,	PmsReadTsk(nw,PJTASKTEXT27); //_TEXT27    28
								,	PmsReadTsk(nw,PJTASKTEXT28); //_TEXT28  29
								})
			If lPMSGetFld
				aDadosUsr := Execblock("PMSGetFld", .F.,.F., { aDadosUsr , 1 , nw } )
			Endif
		Else
     		nAF9++
		  	aadd(aDadosTsk ,{	Val(PMSPonVir(PmsReadTsk(nw,PJTASKNUMBER1))); // AF9->AF9_QUANT := Val(PMSPonVir(aDadosPrj[nw][nx])
								, 	PmsReadData(nVersao,PmsReadTsk(nw,PJTASKSTART)); 	// AF9->AF9_START := PmsReadData(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadHora(nVersao,PmsReadTsk(nw,PJTASKSTART));	// AF9->AF9_HORAI := PmsReadHora(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadData(nVersao,PmsReadTsk(nw,PJTASKFINISH)); 	// AF9->AF9_FINISH:= PmsReadData(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadHora(nVersao,PmsReadTsk(nw,PJTASKFINISH)); 	// AF9->AF9_HORAF := PmsReadHora(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadCale(nVersao,PmsReadTsk(nw,PJTASKCALENDAR),@cAllCalend);// AF9->AF9_CALEND	:= PmsReadCale(nVersao,aDadosPrj[nw][nx]),@cAllCalend)
								, 	ALLTRIM(PmsReadTsk(nw,PJTASKNAME)); 	// AF9->AF9_DESCRI
								, 	PmsReadUM(PmsReadTsk(nw,PJTASKTEXT2),AFC->AFC_DESCRI,@cAllUM);	// AF9->AF9_UM := PmsReadUM(aDadosPrj[nw][nx],AFC->AFC_DESCRI,@cAllUM)
								, 	PmsReadTsk(nw,PJTASKID);				// AF9->AF9_ORDEM := StrZero(Val(aDadosPrj[nw][nx]),TamSx3('AFC_ORDEM')[1])
								, 	UPPER(PmsReadTsk(nw,PJTASKCONSTRAINTTYPE));	// AF9->AF9_RETRI := UPPER(aDadosPrj[nw][nx])
								, 	PmsReadData(nVersao,PmsReadTsk(nw,PJTASKCONSTRAINTDATE));	// AF9->AF9_DTREST := PmsReadData(nVersao,aDadosPrj[nw][nx])
								, 	PmsReadHora(nVersao,PmsReadTsk(nw,PJTASKCONSTRAINTDATE));	// AF9->AF9_HRREST := PmsReadHora(nVersao,aDadosPrj[nw][nx])
								, 	Val(PMSPonVir(PmsReadTsk(nw,PJTASKWORK)));					// AF9->AF9_HESF := Val(PMSPonVir(aDadosPrj[nw][nx]))
								, 	PmsReadTsk(nw,PJTASKEFFORTDRIVEN); 		// AF9->AF9_AGCRTL
								, 	Val(PmsReadTsk(nw,PJTASKPRIORITY));		// AF9->AF9_PRIORI	:= Val(aDadosPrj[nw][nx])
								,	PmsReadTsk(nw,PJTASKTEXT1);
								,	PmsReadTsk(nw,PJTASKOUTLINELEVEL);
								,	PmsReadTsk(nw,PJTASKPERCENTCOMPLETE);
								,	PmsReadTsk(nw,PJTASKPREDECESSORS);
								,	PmsReadTsk(nw,PJTASKRESOURCENAMES);
								,	"resource work";
								, 	"AF9"; //ALIAS
								,	PmsReadTsk(nw,PJTASKTYPE); // tipo da tarefa
								, 	PadR(PmsReadTsk(nw,PJTASKTEXT29),TAMSX3("AF9_IDPROJ")[1]); //_IDPROJ
								,	PmsReadTsk(nw,PJTASKTEXT26); //_TEXT26
								,	PmsReadTsk(nw,PJTASKTEXT27); //_TEXT27
								,	PmsReadTsk(nw,PJTASKTEXT28); //_TEXT28
								})
			If lPMSGetFld
				aDadosUsr := Execblock("PMSGetFld", .F.,.F., { aDadosUsr , 2 , nw })
			Endif

		Endif
	Endif
Next nw

SX3->(dbSetOrder(2))
If SX3->(MsSeek("AFC_DESCRI"))
	cPictAFC :='"'+Alltrim(SX3->X3_PICTURE)+'"'
EndIf

SX3->(dbSetOrder(2))
If SX3->(MsSeek("AF9_DESCRI"))
	cPictAF9 :='"'+Alltrim(SX3->X3_PICTURE)+'"'
EndIf

If Len(aDadosTsk) > 0 
	//	lAdNivel := .F. //lAdNivel := !(Alltrim(aDadosTsk[1,_TEXT1]) == cProjeto)
	// Se existir o nivel de estrutura do MS-Project como 0, ¨¦ o a tarefa resumo do projeto
	// N?o deve acrescentar aumentar o nivel para o PMS
	lAdNivel := aScan(aDadosTsk,{|x|x[_OUTLINELEVEL]=="0"})==0
Endif

oProcess:IncRegua1(STR0094) //"Atualizando o projeto"
oProcess:SetRegua2(Len(aDadosTsk)) // defino a quantidade de processos

// o 1o nivel no PMS é o codigo do projeto equivalente ao nivel 0 no MS-Project
aAdd(aEDTPAI ,{AF8->AF8_PROJET ,cNivelOne})

Begin Transaction
For nw:=1 to Len(aDadosTsk)

	If nw%10 == 0
		oProcess:IncRegua2(STR0039+" "+AllTrim(Str(nw))+" "+STR0037+" "+AllTrim(Str(Len(aDadosTsk)))+ " "+STR0040) //"Gravando "##" de "##" EDT´s do MS-Project..."
	Endif

	If aDadosTsk[nw,_ALIAS] == "AFC"

   		// Nao se trata da tarefa resumo do projeto (EDT Principal)
   		If aDadosTsk[nw,_OUTLINELEVEL] <> '0'
			dbSelectArea("AFC")

			If lSemelhante

				If MV_PMSTX30
					// lemos a linha anterior
					nFieldAnt := Val(aDadosTsk[nW][_ORDEM])-1
					If nFieldAnt==0 .and. !Empty(aDadosTsk[nW][_TEXT26])
						lConsid26 := .T.
						cEdtPai := aDadosTsk[nW][_TEXT26]

					Elseif lConsid26
						cEdtPai := aDadosTsk[nW][_TEXT26]

					ElseIf !Empty(PmsReadTsk(nFieldAnt,PJTASKTEXT1)) //se nao for registro novo
						If PmsReadTsk(nFieldAnt,PJTASKOUTLINELEVEL) == aDadosTsk[nW][_OUTLINELEVEL] //mesmo nível
							If UPPER(PmsReadTsk(nFieldAnt,PJTASKSUMMARY)) <> cYes
								cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 1,.F.) // tarefa
							Else
								cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 2,.F.) // edt
							Endif

						Elseif UPPER(PmsReadTsk(nFieldAnt,PJTASKSUMMARY)) <> cYes // se nao for do mesmo nivel

							cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 3,.F.) // tarefa

						Elseif UPPER(PmsReadTsk(nFieldAnt,PJTASKSUMMARY)) == cYes

							cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 4, .F.) // edt

						Endif
					Else
						cEdtPai := AF8->AF8_PROJET	
					Endif

				Endif

				dbSetOrder(5) //AFC_FILIAL+AFC_IDPROJ+AFC_PROJET+AFC_REVISA+AFC_EDT
				If !Empty(aDadosTsk[nw,_IDPROJ]) .And. MsSeek(cFilAFC+aDadosTsk[nw,_IDPROJ]+AF8->AF8_PROJET+AF8->AF8_REVISA)
					RecLock("AFC",.F.)
					lInclusao := .F.
				Else
					lInclusao := .T.
				EndIf
			Else
			
				If MV_PMSTX30
					// lemos a linha anterior
					nFieldAnt := Val(aDadosTsk[nW][_ORDEM])-1
					If nFieldAnt==0 .and. !Empty(aDadosTsk[nW][_TEXT26])
						lConsid26 := .T.
						cEdtPai := aDadosTsk[nW][_TEXT26]

					Elseif lConsid26
						cEdtPai := aDadosTsk[nW][_TEXT26]

					ElseIf !Empty(PmsReadTsk(nFieldAnt,PJTASKTEXT1)) //se nao for registro novo
						If PmsReadTsk(nFieldAnt,PJTASKOUTLINELEVEL) == aDadosTsk[nW][_OUTLINELEVEL] //mesmo nível
							If UPPER(PmsReadTsk(nFieldAnt,PJTASKSUMMARY)) <> cYes
								cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 1,.F.) // tarefa
							Else
								cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 2,.F.) // edt
							Endif

						Elseif UPPER(PmsReadTsk(nFieldAnt,PJTASKSUMMARY)) <> cYes // se nao for do mesmo nivel
							If aDadosTsk[nw,22] == 'AF9'
								cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 3,.F.) // tarefa
							Else
								For nE := 1 to nFieldAnt-1 //Verifica os niveis anteriores para localizar a EDTPai
									If aDadosTsk[nE,22] = "AFC" .AND. Val(aDadosTsk[nE,_OUTLINELEVEL]) < Val(aDadosTsk[nW,_OUTLINELEVEL])
										nEDTAnt := Val(aDadosTsk[nE][_ORDEM])
									EndIf
								Next nE 
								cEdtPai := PmsGetPai(nEDTAnt,aDadosTsk[nW], 4,.F.) // edt
							EndIf

						Elseif UPPER(PmsReadTsk(nFieldAnt,PJTASKSUMMARY)) == cYes

							cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 4, .F.) // edt

						Endif
					Else
						cEdtPai := AF8->AF8_PROJET
					Endif

				Endif

				dbSetOrder(1)
				If !Empty(aDadosTsk[nw,_TEXT1]) .And. MsSeek(cFilAFC+AF8->AF8_PROJET+AF8->AF8_REVISA+aDadosTsk[nw,_TEXT1])
					RecLock("AFC",.F.)
					lInclusao := .F.
				Else
					lInclusao := .T.
				EndIf
			Endif

			If MV_PMSTX30
				nPosition := Val(aDadosTsk[nw][_ORDEM])
			Else
				nPosition := nW
			Endif

			If MV_PMSTX30 .AND. !lConsid26 .AND. !Empty(cNivTX30)
				cNivel := cNivTX30
			ElseIf MV_PMSTX30 .and. !Empty(aDadosTsk[nw,_TEXT27])
				cNivel	:= aDadosTsk[nw,_TEXT27]
			Else
				cNivel	:= If(lAdNivel,STRZERO(VAL(aDadosTsk[nw,_OUTLINELEVEL])+1, nTamAFCNiv),STRZERO(VAL(aDadosTsk[nw,_OUTLINELEVEL]), nTamAFCNiv))
			Endif

			If lInclusao
				cRetCod := Pmc010Cod("AFC",AF8->AF8_PROJET,AF8->AF8_REVISA,,,aDadosTsk[nw],lAdNivel)

				RecLock("AFC",.T.)
				AFC->AFC_FILIAL 	:= cFilAFC
				AFC->AFC_PROJET	:= AF8->AF8_PROJET
				AFC->AFC_REVISA	:= AF8->AF8_REVISA
				AFC->AFC_EDT		:= cRetCod
			Else
				If cNivel <> AFC->AFC_NIVEL
					cRetCod := Pmc010Cod("AFC",AF8->AF8_PROJET,AF8->AF8_REVISA,,,aDadosTsk[nw],lAdNivel)
					AFC->AFC_EDT := cRetCod
				EndIf
			EndIf

			aDadosTsk[nw,_TEXT1] := AFC->AFC_EDT
			AFC->AFC_QUANT	:= If(aDadosTsk[nw,_QUANT]==0,1,aDadosTsk[nw,_QUANT])
			AFC->AFC_START	:= aDadosTsk[nw,_START]
			AFC->AFC_HORAI	:= aDadosTsk[nw,_HORAI]
			AFC->AFC_FINISH	:= aDadosTsk[nw,_FINISH]
			AFC->AFC_HORAF	:= aDadosTsk[nw,_HORAF]
			AFC->AFC_CALEND	:= aDadosTsk[nw,_CALEND]
			AFC->AFC_NIVEL	:= cNivel

			If !MV_PMSTX30
				If !lConsid26
					If (AFC->AFC_NIVEL == cNivelOne)
						nNivel1++
						AFC->AFC_EDTPAI := ""
					Else
						AFC->AFC_EDTPAI := If(Empty(aEDTPAI),AF8->AF8_PROJET,PC010EdtPai(aEDTPai,aDadosTsk[nw],lAdNivel))
					EndIf
				Else
					AFC->AFC_EDTPAI := cEdtPai
				EndIf
			Else
				AFC->AFC_EDTPAI := cEdtPai
			Endif

			If Empty(cPictAFC)
				AFC->AFC_DESCRI	:= aDadosTsk[nw,_NAME]
			Else
				AFC->AFC_DESCRI	:= Transform(aDadosTsk[nw,_NAME],&cPictAFC)
			EndIf

			AFC->AFC_UM		:= aDadosTsk[nw,_UM]

			If MV_PMSTX30
				If !Empty( aDadosTsk[nw,_TEXT28] )
					AFC->AFC_ORDEM := StrZero(Val(aDadosTsk[nw,_TEXT28]) , nTamAFCOrd)
				Elseif lConsid26
					AFC->AFC_ORDEM := aDadosTsk[nw,_TEXT28]
				Else
					AFC->AFC_ORDEM := StrZero(Val(aDadosTsk[nw,_ORDEM]) , nTamAFCOrd)
				Endif
			Else
				AFC->AFC_ORDEM := StrZero(Val(aDadosTsk[nw,_ORDEM]) , nTamAFCOrd)
			Endif

			AFC->AFC_HESF := aDadosTsk[nw,_WORK]

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

			If lInclusao .OR. Empty(AFC->AFC_IDPROJ)
				AFC->AFC_IDPROJ := "AFC" + GetNewId(nTamID-3)
			Endif

			If lPMSPutFld
				ExecBlock("PMSPutFld", .F. , .F. , {aDadosUsr, 1, nw} )
			Endif

			oProject:Tasks(nPosition):SetField('PJTASKTEXT1',AFC->AFC_EDT)
			oProject:Tasks(nPosition):SetField('PJTASKTEXT29',AFC->AFC_IDPROJ)
			oProject:Tasks(nPosition):SetField('PJTASKNUMBER1', PMSPonVir(Str(AFC->AFC_QUANT)))

			nBuffer++
			FreeUsedCodes(.T.)
			aAdd(aRecAFC,AFC->(RecNo()))
			aAdd(aEDTPAI,{AFC->AFC_EDT,AFC->AFC_NIVEL})
			PMSLogInt("AFC", lInclusao)

			If AFC->AFC_NIVEL == cNivelOne
				Reclock("AF8",.F.)
					AF8->AF8_IDPROJ := AFC->AFC_IDPROJ
				MsUnlock()
			Endif

			If nNivel1 > 1
				Aviso(STR0030,STR0031+Chr(13)+chr(10)+STR0032,{STR0033},2)
				Exit
			Endif
		EndIf // nao se trata da tarefa resumo do projeto
	Else

		dbSelectArea("AF9")

		If lSemelhante
			If MV_PMSTX30
				// lemos a linha anterior
				nFieldAnt := Val(aDadosTsk[nW][_ORDEM])-1
				If !lConsid26 .AND. nFieldAnt==0 .and. !Empty(aDadosTsk[nW][_TEXT26])
					lConsid26 := .T.
				Elseif lConsid26
					cEdtPai := aDadosTsk[nW][_TEXT26]
				ElseIf !Empty(PmsReadTsk(nFieldAnt,PJTASKTEXT1)) //se nao for registro novo
					If PmsReadTsk(nFieldAnt,PJTASKOUTLINELEVEL) == aDadosTsk[nW][_OUTLINELEVEL] //mesmo nível
						If UPPER(PmsReadTsk(nFieldAnt,PJTASKSUMMARY)) <> cYes
							cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 1 , .T.) // tarefa
						Else
							cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 2 , .T.) // edt
						Endif
		
					Elseif UPPER(PmsReadTsk(nFieldAnt,PJTASKSUMMARY)) <> cYes // se nao for do mesmo nivel
		
						cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 3 , .T.) // tarefa
		
					Elseif UPPER(PmsReadTsk(nFieldAnt,PJTASKSUMMARY)) == cYes
		
						cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 4 , .T.) // edt
		
					Endif
				Else
					cEdtPai := AF8->AF8_PROJET
				Endif

			Endif
			dbSetOrder(7)
			If !Empty(aDadosTsk[nw,_IDPROJ]) .And.MsSeek(cFilAF9+aDadosTsk[nw,_IDPROJ]+AF8->AF8_PROJET+AF8->AF8_REVISA)
				RecLock("AF9",.F.)
				lInclusao := .F.
			Else
				lInclusao := .T.
			EndIf
        Else
        	If MV_PMSTX30
				// lemos a linha anterior
				nFieldAnt := Val(aDadosTsk[nW][_ORDEM])-1
				If !lConsid26 .AND. nFieldAnt==0 .and. !Empty(aDadosTsk[nW][_TEXT26])
					lConsid26 := .T.
				Elseif lConsid26
					cEdtPai := aDadosTsk[nW][_TEXT26]
				ElseIf !Empty(PmsReadTsk(nFieldAnt,PJTASKTEXT1)) //se nao for registro novo
					If PmsReadTsk(nFieldAnt,PJTASKOUTLINELEVEL) == aDadosTsk[nW][_OUTLINELEVEL] //mesmo nível
						If UPPER(PmsReadTsk(nFieldAnt,PJTASKSUMMARY)) <> cYes
							cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 1 , .T.) // tarefa
						Else
							cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 2 , .T.) // edt
						Endif
	
					Elseif UPPER(PmsReadTsk(nFieldAnt,PJTASKSUMMARY)) <> cYes // se nao for do mesmo nivel
	
						cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 3 , .T.) // tarefa
	
					Elseif UPPER(PmsReadTsk(nFieldAnt,PJTASKSUMMARY)) == cYes
	
						cEdtPai := PmsGetPai(nFieldAnt,aDadosTsk[nW], 4 , .T.) // edt
	
					Endif
				Else
					cEdtPai := AF8->AF8_PROJET
				Endif
			Endif

			dbSetOrder(1)
			If !Empty(aDadosTsk[nw,_TEXT1]) .And.MsSeek(cFilAF9+AF8->AF8_PROJET+AF8->AF8_REVISA+aDadosTsk[nw,_TEXT1])
				RecLock("AF9",.F.)
				lInclusao := .F.
			Else
				lInclusao := .T.
			EndIf
		Endif

		If MV_PMSTX30
			nPosition := Val(aDadosTsk[nw][_ORDEM])
		Else
			nPosition := nW
		Endif

		If MV_PMSTX30 .AND. !lConsid26 .and. !Empty(cNivTX30)
			cNivel := cNivTX30
		ElseIf MV_PMSTX30 .and. !Empty(aDadosTsk[nw,_TEXT27])
			cNivel := aDadosTsk[nw,_TEXT27]
		Else
			cNivel := If(lAdNivel,STRZERO(VAL(aDadosTsk[nw,_OUTLINELEVEL])+1, nTamAF9Niv),STRZERO(VAL(aDadosTsk[nw,_OUTLINELEVEL]), nTamAF9Niv))

		Endif

		If lInclusao
			cRetCod := Pmc010Cod("AF9",AF8->AF8_PROJET,AF8->AF8_REVISA,,,aDadosTsk[nw],lAdNivel)
			RecLock("AF9",.T.)
			AF9->AF9_FILIAL := cFilAF9
			AF9->AF9_PROJET	:= AF8->AF8_PROJET
			AF9->AF9_REVISA	:= AF8->AF8_REVISA
			AF9->AF9_TAREFA := cRetCod
		Else
			If cNivel <> AF9->AF9_NIVEL
				cRetCod := Pmc010Cod("AF9",AF8->AF8_PROJET,AF8->AF8_REVISA,,,aDadosTsk[nw],lAdNivel)
				AF9->AF9_TAREFA := cRetCod
			EndIf
		EndIf

		aDadosTsk[nw,_TEXT1] := AF9->AF9_TAREFA
		AF9->AF9_QUANT		:= If(aDadosTsk[nw,_QUANT]==0,1,aDadosTsk[nw,_QUANT])
		AF9->AF9_START		:= aDadosTsk[nw,_START]
		AF9->AF9_HORAI		:= aDadosTsk[nw,_HORAI]
		AF9->AF9_FINISH		:= aDadosTsk[nw,_FINISH]
		AF9->AF9_HORAF		:= aDadosTsk[nw,_HORAF]
		AF9->AF9_CALEND		:= aDadosTsk[nw,_CALEND]
		AF9->AF9_NIVEL 		:= cNivel

		If !MV_PMSTX30
			If !lConsid26
				AF9->AF9_EDTPAI 	:= If(Empty(aEDTPAI),AF8->AF8_PROJET,PC010EdtPai(aEDTPai,aDadosTsk[nw],lAdNivel))
			Endif
		Else
			AF9->AF9_EDTPAI 	:= cEDTPai
		Endif

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

		If MV_PMSTX30
			If !Empty( aDadosTsk[nw,_TEXT28] )
				AF9->AF9_ORDEM := StrZero(Val(aDadosTsk[nw,_TEXT28]) , nTamAF9Ord)
			Elseif lConsid26
				AF9->AF9_ORDEM := aDadosTsk[nw,_TEXT28]
			Else
				If ValType(aDadosTsk[nw,_ORDEM]) == "C" .AND. !Empty(aDadosTsk[nw,_ORDEM])
					AF9->AF9_ORDEM := StrZero(Val(aDadosTsk[nw,_ORDEM]),nTamAF9Ord)
				EndIf
			Endif
		Else
			If ValType(aDadosTsk[nw,_ORDEM]) == "C" .AND. !Empty(aDadosTsk[nw,_ORDEM])
				AF9->AF9_ORDEM := StrZero(Val(aDadosTsk[nw,_ORDEM]),nTamAF9Ord)
			EndIf
		Endif

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

		If lInclusao
			AF9->AF9_IDPROJ := "AF9" + GetNewId(nTamID-3)
		Endif

		If lPMSPutFld
			ExecBlock("PMSPutFld", .F. , .F. , {aDadosUsr, 2, nw} )
		Endif

		oProject:Tasks(nPosition):SetField('PJTASKTEXT1',AF9->AF9_TAREFA)
		oProject:Tasks(nPosition):SetField('PJTASKTEXT29',AF9->AF9_IDPROJ)
		oProject:Tasks(nPosition):SetField('PJTASKNUMBER1', PMSPonVir(Str(AF9->AF9_QUANT)))

		PMSLogInt("AF9" , lInclusao)
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
	cNivTX30 := ""
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

oProcess:IncRegua1(STR0041) // "Gravando amarrações:"

//Grava amarrações via multi-thread
If !MV_PMSTX30 .AND. Len(aDadosTsk) > nStartMT // start multi thread
	oProcess:SetRegua2(1) // defino a quantidade de processos
	PmsImpB(aDadosTsk,aResources,lPOC, nVersao, aRecAF9, nAF9,@aRecAmarr)
	oProcess:IncRegua2("")
Else
	oProcess:SetRegua2(Len(aDadosTsk)) // defino a quantidade de processos
	For nw := 1 to Len(aDadosTsk) // processa os relacionamentos da tarefa
		If nw%10 == 0
			oProcess:IncRegua2(STR0041+" "+AllTrim(Str(nw))+" "+STR0037+" "+AllTrim(Str(Len(aDadosTsk)))+ " "+STR0038) //"Gravando amarrações: "##" de "##" tarefas do MS-Project..."
	   	Endif

	   	IF aDadosTsk[nw,_ALIAS] == "AF9"
			dbSelectArea("AF9")
			nT++
		   	dbgoto(aRecAF9[nT])
		   	nPercComp := Val(aDadosTsk[nw,_PERCENTCOMPLETE])
		   	aRelac := {}

			 // processa o Percentual Realizado dos Eventos
			If lTopConn

				cQuery := " SELECT R_E_C_N_O_ RECNO_ FROM "+cAliasAFP
				cQuery += " WHERE AFP_FILIAL = '"+cFilAFP+"' "
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

			Else
				dbSelectArea("AFP")
				dbSetOrder(1)
				If MsSeek(cFilAFP+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
					While !Eof() .And. cFilAFP+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
									AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_TAREFA
						RecLock("AFP",.F.)
			        	AFP->AFP_DTCALC	:= PmsDtPrv(AF9->AF9_START,AF9->AF9_FINISH,AFP->AFP_PERC,AF9->AF9_TPMEDI)
						nBuffer++
						AFP->(dbSkip())
					EndDo
				EndIf

			Endif

			// processa o Percentual Realizado da Tarefa
			If lPOC .and. (nPercComp>0)
				dbSelectArea("AFF")
				dbSetOrder(1)
				If PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataBase,AF9->AF9_QUANT) <> nPercComp

					bContAFF := .T.

					If MsSeek(cFilAFF+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+DTOS(dDataBase))
						If nPercComp <> 0

							// alteracao de confirmacao
							If !lFase93
								bContAFF := .F.
								If PMSShowWar() <>2
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
								EndIf
								If PMSShowWar() <> 1
									PMSLogInt("AF9" , .F. ,'',,STR0020+" "+cMensagem)
								Endif
							EndIf
						Else

							// exclusao de confirmacao
							If !lFase95
								bContAFF := .F.
								If PMSShowWar() <> 2
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
								EndIf
								If PMSShowWar() <> 1
									PMSLogInt("AF9" , .F. ,'',,STR0021+""+cMensagem)
								EndIf
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
							EndIf
							If PMSShowWar() <> 1
								PMSLogInt("AF9" , .F. ,'',,STR0022+ " "+cMensagem)
							EndIf
						EndIf

						If bContAFF
							RecLock("AFF",.T.)
						EndIf
					EndIf

					If bContAFF
						AFF->AFF_FILIAL := cFilAFF
						AFF->AFF_PROJET	:= AF9->AF9_PROJET
						AFF->AFF_REVISA	:= AF9->AF9_REVISA
						AFF->AFF_TAREFA	:= AF9->AF9_TAREFA
						AFF->AFF_QUANT	:= AF9->AF9_QUANT*nPercComp/100
						AFF->AFF_USER	:= cCodUsr
						AFF->AFF_DATA	:= dDataBase

						PMSAvalAFF("AFF",1,,.F.,.T.)
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
			If lTopConn

				cAliasQry := GetNextAlias()

				cQuery := " SELECT AFA_ITEM, R_E_C_N_O_ RECNO_ FROM "+cAliasAFA
				cQuery += " WHERE AFA_FILIAL = '"+cFilAFA+"' "
				cQuery += " AND AFA_PROJET = '"+AF9->AF9_PROJET+"' "
				cQuery += " AND AFA_REVISA = '"+AF9->AF9_REVISA+"' "
				cQuery += " AND AFA_TAREFA = '"+AF9->AF9_TAREFA+"' "
				cQuery += " AND AFA_RECURS <> '' "
				cQuery += " AND D_E_L_E_T_ = ' ' "
				cQuery += " ORDER BY AFA_ITEM "
				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry , .T. , .T. )
				While (cAliasQry)->(!Eof())
					aAdd(aRecAFA, (cAliasQry)->(RECNO_) )
					nMaxItem := VAL((cAliasQry)->(AFA_ITEM))
					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())

			Else

				dbSelectArea("AFA")
				dbSetOrder(1)
				MsSeek(cFilAFA+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
				While !Eof() .And. cFilAFA+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
									AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA
					If !Empty(AFA->AFA_RECURS)
						aAdd(aRecAFA,AFA->(RecNo()))
					EndIf
					dbSkip()
				EndDo

			Endif

			AE8->(dbSetOrder(1))

			For nz := 1 to Len(aRelac)
				If AE8->(MsSeek(cFilAE8+Substr(aRelac[nz,1],1,nTamRec)))
					SB1->(dbSetOrder(1))
					SB1->(MsSeek(cFilSB1+AE8->AE8_PRODUT))
					If nz <= Len(aRecAFA)
						AFA->(dbGoto(aRecAFA[nz]))
					Endif
					If !Len(aRecAFA)==0 .and. AllTrim(Substr(aRelac[nz,1],1,nTamRec))==AllTrim(AFA->AFA_RECURS)

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
								nPosWork := aScan(aResources, {|x| Upper(AllTrim(x[1])) == Upper(Alltrim(AE8->AE8_RECURS)) })

								If nPosWork > 0
									AFA->AFA_QUANT := aResources[nPosWork][2]
								Else

									cCalend := If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,AF9->AF9_CALEND)
									If lNewCalend
										If !(cCalend $ cHistCall)

											aadd(aTrbs, PmsItvTRB(cCalend) )
											nPosCal	:= Len(aTrbs)
											cHistCall +=cCalend+"|"
										Else

											nPosCal := aScan(aTrbs, {|x| x[1]==cCalend } )
										Endif
										AFA->AFA_QUANT := (AFA->AFA_ALOC*PmsHrsItvl(AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,cCalend,AF9->AF9_PROJET,AE8->AE8_RECURS,aTrbs[nPosCal]))/100
									Else
										AFA->AFA_QUANT := (AFA->AFA_ALOC*PmsHrsItvl(AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,cCalend,AF9->AF9_PROJET,AE8->AE8_RECURS))/100
									EndIf
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
							PmsAvalAFA("AFA",3)

							RecLock("AFA",.F.)
						Else
							RecLock("AFA",.T.)
							AFA->AFA_ITEM	:= StrZero(nMaxItem+nConAFA, nTamAFAIte)
						EndIf

						nConAFA++
						AFA->AFA_FILIAL	:= cFilAFA
						AFA->AFA_PROJET	:= AF9->AF9_PROJET
						AFA->AFA_REVISA	:= AF9->AF9_REVISA
						AFA->AFA_TAREFA	:= AF9->AF9_TAREFA
						AFA->AFA_RECURS	:= Substr(aRelac[nz,1],1,nTamRec)
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

							cCalend := If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,AF9->AF9_CALEND)
							If lNewCalend
								If !(cCalend $ cHistCall)
									aadd(aTrbs, PmsItvTRB(cCalend) )
									nPosCal := Len(aTrbs)
									cHistCall +=cCalend+"|"
								Else
									nPosCal := aScan(aTrbs, {|x| x[1]==cCalend } )
								Endif

								AFA->AFA_QUANT 	:= (AFA->AFA_ALOC*PmsHrsItvl(AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,cCalend,AF9->AF9_PROJET,AE8->AE8_RECURS,,,,aTrbs[nPosCal]))/100

							Else
								AFA->AFA_QUANT 	:= (AFA->AFA_ALOC*PmsHrsItvl(AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,cCalend,AF9->AF9_PROJET,AE8->AE8_RECURS))/100
							EndIf
						EndIf

						AFA->AFA_DATPRF	:= AF9->AF9_START
						AFA->AFA_START	:= AF9->AF9_START
						AFA->AFA_HORAI	:= AF9->AF9_HORAI
						AFA->AFA_FINISH	:= AF9->AF9_FINISH
						AFA->AFA_HORAF	:= AF9->AF9_HORAF

						If !Empty(AE8->AE8_PRODUT)
							AFA->AFA_PRODUT	:= AE8->AE8_PRODUT
							AFA->AFA_CUSTD	:=  RetFldProd(SB1->B1_COD,"B1_CUSTD")
							AFA->AFA_MOEDA	:= VAL(SB1->B1_MCUSTD)
							If !Empty(AE8->AE8_VALOR)
								AFA->AFA_CUSTD := AE8->AE8_VALOR
							EndIf
						Else
							AFA->AFA_CUSTD	:= AE8->AE8_VALOR
							AFA->AFA_MOEDA	:= 1
						EndIf
						nBuffer++
						PmsAvalAFA("AFA",1)

					EndIf
				EndIf
			Next nZ

			nConAFA:=0
			If Len(aRecAFA)>Len(aRelac)
				For nz := Len(aRelac)+1 to Len(aRecAFA)
					AFA->(dbGoto(aRecAFA[nz]))

					PmsAvalAFA("AFA",3)

					RecLock("AFA",.F.,.T.)
					dbDelete()
					Msunlock()
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
			MsSeek(cFilAFD+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
			While !Eof() .And. cFilAFD+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
								AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA
				aAdd(aRecAFD,AFD->(RecNo()))
				dbSkip()
			EndDo

			// RELACIONAMENTOS EDT -> TAREFA
			aAtuAJ4	:= {}
			aRecAJ4	:= {}
			dbSelectArea("AJ4")
			dbSetOrder(1)
			MsSeek(cFilAJ4+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
			While AJ4->(!Eof()) .And. cFilAJ4+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
							AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA
				aAdd(aRecAJ4,AJ4->(RecNo()))
				dbSkip()
			EndDo

			AF9->(dbSetOrder(1))
			AFC->(dbSetOrder(1))
			For nz := 1 to Len(aRelac)
				// busca pela tarefa predecessora
				If aRelac[nz][1]	== Nil
					aRelac[nz][1]	:= " "
				EndIf
				If AF9->(MsSeek(cFilAF9+AF8->AF8_PROJET+AF8->AF8_REVISA+aRelac[nz][1]))
					RestArea(aAuxArea)
					If nz > Len(aRecAFD)
						RecLock("AFD",.T.)
					Else
						AFD->(dbGoto(aRecAFD[nz]))
						RecLock("AFD",.F.)
					EndIf
					AFD->AFD_FILIAL	:= cFilAFD
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
					If AFC->(MsSeek(cFilAFC+AF8->AF8_PROJET+AF8->AF8_REVISA+aRelac[nz][1]))
						RestArea(aAuxArea)
						If nz > Len(aRecAJ4)
							RecLock("AJ4",.T.)
						Else
							AJ4->(dbGoto(aRecAJ4[nz]))
							RecLock("AJ4",.F.)
						EndIF
						AJ4->AJ4_FILIAL	:= cFilAJ4
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
				   Endif
				EndIf
			Next nZ

			If Len(aRecAFD)> 0
				For nz := 1 to Len(aRecAFD) // relacionamentos do PMS
					nC := aScan(aAtuAFD,{|x|x ==aRecAFD[nz] }) // relacionamentos do project incluido/alterado no pms
					If nC == 0
						AFD->(dbGoto(aRecAFD[nz]))
						RecLock("AFD",.F.,.T.)
						dbDelete()
						Msunlock()
						nBuffer++
					EndIF
				Next nZ
			EndIf

			If Len(aRecAJ4)> 0
				For nz := 1 to Len(aRecAJ4) // relacionamentos do PMS
					nC := aScan(aAtuAJ4,{|x|x ==aRecAJ4[nz] }) // relacionamentos do project incluido/alterado no pms
					If nC == 0
						AJ4->(dbGoto(aRecAJ4[nz]))
						RecLock("AJ4",.F.,.T.)
						dbDelete()
						Msunlock()
						nBuffer++
					EndIF
				Next nZ
			EndIf

			If nBuffer > 1000
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
Endif

If lNewCalend
	PmsItvTRB("",aTrbs)
EndIf
cCalend 	:= ""
cHistCall	:= ""
nPosCal	:= 0
aTrbs		:= {}

oProcess:IncRegua1(STR0042) //"Atualizando Datas do projeto!"
If !MV_PMSTX30 .AND. Len(aDadosTsk) > nStartMT // start multi thread
	oProcess:SetRegua2(1) // defino a quantidade de processos
	PmsDtsAtu(aRecAF9,MV_PMSTX30)
	oProcess:IncRegua2("")
Else
	oProcess:SetRegua2(AF9->(RECCOUNT())) // defino a quantidade de processos

	dbSelectArea("AF9")
	dbSetOrder(1)
	MsSeek(cFilAF9+AF8->AF8_PROJET+AF8->AF8_REVISA)
	While AF9->(!Eof()) .And. cFilAF9+AF8->AF8_PROJET+AF8->AF8_REVISA==AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA

		oProcess:IncRegua2(STR0095)//"Recalculando a duração das tarefas"

		If aScan(aRecAF9,AF9->(RecNo()))>0

			If lNewCalend
				If !(AF9->AF9_CALEND $ cHistCall)
					aadd(aTrbs, PmsUtsTRB(AF9->AF9_CALEND) )
					nPosCal	:= Len(aTrbs)
					cHistCall +=cCalend+"|"
				Else
					nPosCal := aScan(aTrbs, {|x| x[1]==AF9->AF9_CALEND } )
				Endif
			EndIf

			If AF9->AF9_START==AF9->AF9_FINISH

				nDuracao := PmsHrUtil(AF9->AF9_START,"00"+AF9->AF9_HORAI,"00"+AF9->AF9_HORAF,AF9->AF9_CALEND,,AF9->AF9_PROJET,,,,,,, .T.,,IiF(lNewCalend, aTrbs[nPosCal],NIL) )

			Else
				nDuracao := 0
				dStart	:= AF9->AF9_START
				dFinish := AF9->AF9_FINISH
				If dStart != dFinish
					nDuracao:= PmsHrUtil(dStart,"00"+AF9->AF9_HORAI,"0024:00",AF9->AF9_CALEND,,AF9->AF9_PROJET,,,,,,,.T. ,,IiF(lNewCalend, aTrbs[nPosCal],NIL))
				Else
					nDuracao:= PmsHrUtil(dStart,"00"+AF9->AF9_HORAI,"00"+AF9->AF9_HORAF,AF9->AF9_CALEND,,AF9->AF9_PROJET,,,,,,,.T. ,,IiF(lNewCalend, aTrbs[nPosCal],NIL))
				Endif
				dStart++
				While dStart <= dFinish
					If dStart==dFinish
						nDuracao += PmsHrUtil(dStart,"0000:00","00"+AF9->AF9_HORAF,AF9->AF9_CALEND,,AF9->AF9_PROJET,,,,,,,.F.,.T.,IiF(lNewCalend, aTrbs[nPosCal],NIL))
					Else
						nDuracao += PmsHrUtil(dStart,"0000:00","0024:00",AF9->AF9_CALEND,,AF9->AF9_PROJET,,,,,,,,,,IiF(lNewCalend, aTrbs[nPosCal],NIL))
					EndIf
					dStart++
				EndDo
			EndIf
			RecLock("AF9")
			AF9->AF9_HDURAC := nDuracao
			AF9->AF9_HUTEIS := nDuracao
			MsUnlock()

		Elseif !MV_PMSTX30

			If (cExcTrfPms == "N" .And. GeralApp( AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA ) )
				If PMSShowWar() <> 2
					Aviso(STR0034,STR0035+ Chr(13) + Chr(10) + "Tarefa: "+Alltrim(AF9->AF9_TAREFA),{STR0033},2) //"Atencao"###"Existem apontamentos para esta tarefa, portanto nao pode ser excluida!"###"Fechar"
				Endif
				If PMSShowWar() <> 1
					PMSLogInt("AF9" , .F. ,,,STR0035)
				Endif
			Else
				PMSLogInt("AF9" , .F. ,'D')
				MaDelAF9(,,,AF9->(RecNo()))
			EndIf

		EndIf
		dbSelectArea("AF9")
		dbSetOrder(1)
		AF9->(dbSkip())
	EndDo
Endif

If lNewCalend
	PmsUtsTRB("",aTrbs)
EndIf

oProcess:IncRegua1(STR0096)//"Excluindo EDTs do Projeto desatualizadas"
oProcess:SetRegua2(AFC->(RecCount())) // defino a quantidade de processos

dbSelectArea("AFC")
dbSetOrder(1)
MsSeek(cFilAFC+AF8->AF8_PROJET+AF8->AF8_REVISA)
While AFC->(!Eof()) .And. cFilAFC+AF8->AF8_PROJET+AF8->AF8_REVISA==AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA
	oProcess:IncRegua2("")
	If aScan(aRecAFC,AFC->(Recno()))<=0  .and. AFC->AFC_NIVEL <> cNivelOne .and. !MV_PMSTX30
		PMSLogInt("AFC" , .F., 'D')
		MaDelAFC(,,,AFC->(RecNo()))
	EndIf
	AFC->(dbSkip())
EndDo

oProcess:IncRegua1(STR0019) //"Recalculando o progresso fisico e datas do projeto..."
//Atualiza datas do projeto
If !MV_PMSTX30 .AND. Len(aDadosTsk) > nStartMT
	oProcess:SetRegua2(1) // defino a quantidade de processos
	PmsThrDts(cFilAFC,AF8->AF8_PROJET,AF8->AF8_REVISA)
	oProcess:IncRegua2("")
Else
	oProcess:SetRegua2(2) // defino a quantidade de processos
	PmsEdtPrv( AF8->AF8_PROJET, AF8->AF8_REVISA, AF8->AF8_PROJET) // Atualizando progresso fisico e datas previstas
	oProcess:IncRegua2(STR0103) //"Atualizando progresso fisico e datas previstas..."
	PMSEdtReal( AF8->AF8_PROJET, AF8->AF8_REVISA, AF8->AF8_PROJET) // Atualizando progresso fisico e datas realizados
	oProcess:IncRegua2(STR0104)//"Atualizando progresso fisico e datas realizados..."
Endif

oProcess:IncRegua1(STR0097)//"Excluindo relacionamentos desatualizados do projeto"
If lTopConn
	nQtdReg := 0
	dbSelectArea("AFD")
	If ( Select( cAliasTmp ) > 0 )
		(cAliasTmp)->(dbCloseArea())
	EndIf

	// Seleciona os recno da tabela AFD, das quais o AFD_PREDEC não tem relacao com AF9_TAREFA da tabela AF9
	cQuery := " FROM "+cAliasAFD+" AFD "
	cQuery += " LEFT JOIN "+RetSqlName("AF9")+" AF9 ON AFD_PROJET=AF9_PROJET AND AFD_REVISA=AF9_REVISA AND AFD_PREDEC=AF9_TAREFA "
	cQuery += " AND AF9_FILIAL = '"+cFilAF9+"' AND AF9.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE AF9_TAREFA IS NULL "
	cQuery += " AND AF9_FILIAL = '"+cFilAF9+"' "
	cQuery += " AND AF9_PROJET = '"+AF8->AF8_PROJET+"' "
	cQuery += " AND AF9_REVISA = '"+AF8->AF8_REVISA+"' "
	cQuery += " AND AFD.D_E_L_E_T_ = ' ' "

	cQrySelect := "SELECT count(AFD.R_E_C_N_O_ ) QTDREG "
	cQrySelect := ChangeQuery(cQrySelect+cQuery)

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQrySelect), cAliasTmp, .F., .T.)
	If ( Select( cAliasTmp ) > 0 )
		nQtdReg := (cAliasTmp)->(QTDREG)
		(cAliasTmp)->(dbCloseArea())
	EndIf

	If nQtdReg >0
		oProcess:SetRegua2(nQtdReg) // defino a quantidade de processos
		cQrySelect := "SELECT AFD.R_E_C_N_O_ AFD_RECNO "
		cQrySelect := ChangeQuery(cQrySelect+cQuery)

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQrySelect), cAliasTmp, .F., .T.)
		If ( Select( cAliasTmp ) > 0 )
			While (cAliasTmp)->(!Eof())
				oProcess:IncRegua2(STR0101)//"Excluindo relacionamentos desatualizados da tarefa..."
				AFD->(dbGoto((cAliasTmp)->(AFD_RECNO)))
				RecLock("AFD",.F.,.T.)
					dbDelete()
				MsUnlock()

				(cAliasTmp)->(dbSkip())
			EndDo
			(cAliasTmp)->(dbCloseArea())
		EndIf
	EndIf

Else
	dbSelectArea("AF9")
	dbSetOrder(1)
	dbSelectArea("AFD")
	oProcess:SetRegua2(AFD->(RECCOUNT())) // defino a quantidade de processos
	dbSetOrder(1)
	MsSeek(cFilAFD+AF8->AF8_PROJET+AF8->AF8_REVISA)
	While AFD->(!Eof()) .And. cFilAFD+AF8->AF8_PROJET+AF8->AF8_REVISA==AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA

		oProcess:IncRegua2(STR0101)//"Excluindo relacionamentos desatualizados das tarefas..."
		dbSelectArea("AF9")
		If !MsSeek(cFilAF9+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_PREDEC)
			RecLock("AFD",.F.,.T.)
			dbDelete()
			MsUnlock()
		EndIf
		AFD->(dbSkip())
	EndDo
EndIf

oProcess:IncRegua1(STR0097)// "Excluindo relacionamentos desatualizados do projeto"

If lTopConn
	nQtdReg := 0

	If ( Select( cAliasTmp ) > 0 )
		(cAliasTmp)->(dbCloseArea())
	EndIf

	// Seleciona os recno da tabela AJ4, das quais o AJ4_PREDEC não tem relacao com AFC_TAREFA da tabela AFC
	cQuery := " FROM "+RetSqlName("AJ4")+" AJ4 "
	cQuery += " LEFT JOIN "+RetSqlName("AFC")+" AFC ON AJ4_PROJET=AFC_PROJET AND AJ4_REVISA=AFC_REVISA AND AJ4_PREDEC=AFC_EDT "
	cQuery += " AND AFC_FILIAL = '"+cFilAFC+"' AND AFC.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE AFC_EDT IS NULL "
	cQuery += " AND AJ4_FILIAL = '"+cFilAJ4+"' "
	cQuery += " AND AJ4_PROJET = '"+AF8->AF8_PROJET+"' "
	cQuery += " AND AJ4_REVISA = '"+AF8->AF8_REVISA+"' "
	cQuery += " AND AJ4.D_E_L_E_T_ = ' ' "

	cQrySelect := "SELECT COUNT(AJ4.R_E_C_N_O_) QTDREG "
	cQrySelect := ChangeQuery(cQrySelect+cQuery)

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQrySelect), cAliasTmp, .F., .T.)
	If ( Select( cAliasTmp ) > 0 )
		nQtdReg := (cAliasTmp)->(QTDREG)
		(cAliasTmp)->(dbCloseArea())
	EndIf

	If nQtdReg >0
		oProcess:SetRegua2(nQtdReg) // defino a quantidade de processos
		cQrySelect := "SELECT AJ4.R_E_C_N_O_ AJ4_RECNO "
		cQrySelect := ChangeQuery(cQrySelect+cQuery)

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQrySelect), cAliasTmp, .F., .T.)
		If ( Select( cAliasTmp ) > 0 )
			dbSelectArea("AJ4")
			While (cAliasTmp)->(!Eof())
				oProcess:IncRegua2(STR0102)//"Excluindo relacionamentos desatualizados das EDTs ..."
				AJ4->(dbGoto((cAliasTmp)->(AJ4_RECNO)))
				RecLock("AJ4",.F.,.T.)
					dbDelete()
				MsUnlock()

				(cAliasTmp)->(dbSkip())
			EndDo
			(cAliasTmp)->(dbCloseArea())
		EndIf
	EndIf
Else
	oProcess:SetRegua2(AJ4->(RECCOUNT())) // defino a quantidade de processos
	dbSelectArea("AFC")
	dbSetOrder(1)
	dbSelectArea("AJ4")
	dbSetOrder(1)
	MsSeek(cFilAJ4+AF8->AF8_PROJET+AF8->AF8_REVISA)
	While AJ4->(!Eof()) .And. cFilAJ4+AF8->AF8_PROJET+AF8->AF8_REVISA==AJ4->AJ4_FILIAL+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA
		oProcess:IncRegua2(STR0102) //"Excluindo relacionamentos desatualizados das EDTs ..."
		dbSelectArea("AFC")
		If !MsSeek(cFilAFC+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA+AJ4->AJ4_PREDEC)
			RecLock("AJ4",.F.,.T.)
			dbDelete()
			MsUnlock()
		EndIf
		AJ4->(dbSkip())
	EndDo
EndIf

msUnlockAll()

IncProc()
oApp:VISIBLE:= .T.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Aux010BExp
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
@param aEDTs,,
@param lSemelhante,,
@param lArqtemp,,
@param lCpyF7,,
@param aTRFs,,
@param lExport,,
@param nIDProject,,

@return

/*/
//-------------------------------------------------------------------
Function Aux010BExp(cAlias,nReg,nOpcx,oApp,nVersao,cArquivo,lRecurso,lAloc,lRelac,lPOC,aEDTs,lSemelhante, lArqtemp,lCpyF7,aTRFs,lExport, nIDProject,lExport)

Local aCalAFY		:=	{}
Local aCalBase  	:= {PJSUNDAY, PJMONDAY, PJTUESDAY, PJWEDNESDAY, PJTHURSDAY, PJFRIDAY, PJSATURDAY}
Local aCalend		:= {}
Local aProject	:= {}
Local aRecursos	:= {}
Local aSH7			:= {}
Local cFilAFD		:= xFilial("AFD")
Local cFilAFY 	:= xFilial("AFY")
Local cFilAJ4		:= xFilial("AJ4")
Local cFilSH7 	:= xFilial("SH7")
Local cTempPath 	:= GetTempPath()
Local dDataAFY	:= stod("")
Local lPMA010FR 	:= ExistBlock("PMA010FR")
Local lPMS410		:= alltrim(funname()) == "PMSA410"
Local nQtdTsk 	:= 0 // quantidade de tarefas j?existente no arquivo do project (*.MPP)
Local nx 			:= 0
Local nK			:= 0
Local oProject
Local aRecMSP		:= {}

Private aNivel		:= {}
Private cAliasAE8		:= RetSQLName("AE8")
Private cAliasAFA		:= RetSQLName("AFA")
Private cFilAE8		:= xFilial("AE8") // utilizado na funcao PmcAddPrj
Private cFilAF9		:= xFilial("AF9") // utilizado na funcao PmcAddPrj
Private cFilAFA		:= xFilial("AFA") // utilizado na funcao PmcAddPrj
Private cFilAFC		:= xFilial("AFC")// utilizado na funcao PmcAddPrj
Private lAE8EAFAC 	:= !Empty(FwFilial("AE8")) .AND. Empty(FwFilial("AFA")) // utilizado na funcao PmcAddPrj
Private lAllCompar	:= !Empty(FwFilial("AE8")) .AND. !Empty(FwFilial("AFA")) // utilizado na funcao PmcAddPrj
Private lPMS010EX		:= ExistBlock("PMS010EX") // utilizado na funcao PmcAddPrj
Private lPMSCust		:= SuperGetMv("MV_PMSCUST",.F.,"1") == "2" // utilizado na funcao PmcAddPrj
Private lPMSSetFld 	:= ExistBlock("PMSSetFld") // utilizado na funcao PmcAddPrj
PRIVATE lTopConn		:= IfDefTopCTB()
Private nAdd			:= 0
Private nTamID		:= TamSX3("AFC_IDPROJ")[1] // utilizado na funcao PmcAddPrj

DEFAULT lArqtemp		:= .T.
DEFAULT lSemelhante	:= .F.
DEFAULT lCpyF7		:= .F.
DEFAULT aTRFs			:= {}
DEFAULT lExport		:= .F.
DEFAULT nIdProject	:= 1
DEFAULT lExport		:= .F.

If Right(cTempPath,1) $ '/\'
	cTempPath	:=	Substr(cTempPath,1,Len(cTempPath)-1)
Endif

PmsIncProc(.T.,,STR0023) //'Inicializando MS Project'

oApp:VISIBLE:= .F.
If cArquivo <> Nil .And. !Empty(cArquivo)
	If lArqtemp
		__CopyFile( cArquivo , cTempPath+"\INTEGRACAO_MSPROJECT.MPP" )
		oApp:FileOpen(cTempPath+"\INTEGRACAO_MSPROJECT.MPP")
	Else
		oApp:FileOpen(cArquivo)
	Endif
Else
	oApp:Projects:Add(.F.)

	// altera os campos exibidos pelo MS-Project
	oApp:TableEdit( 'Ap6View', .T.,.T. , .T.,    ,'ID' ,               	,                  , 6, PJCENTER, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER )
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Text1'       	, 'Codigo', 15,  PJLEFT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER )
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Name'			, 'Nome da Tarefa' , 24,  PJLEFT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER )  //
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Number1'      , "Quantidade",  10, PJRIGHT, .T., .T., , 1, ,PJCENTER )  //
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Text2'       , "UM",  8, PJRIGHT, .T., .T., , 1, ,PJCENTER )  //
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Duration'    , "Duracao",  9, PJRIGHT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER ) //
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Start'       , "Inicio", 12, PJRIGHT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER ) //
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Finish'      , "Fim", 12, PJRIGHT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER ) //
	oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'PercentComplete'  , "% Concluida", 12,  PJLEFT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER ) //
	oApp:TableApply( 'Ap6View' )
EndIf

// Entende-se que o ultimo "projeto" adicionado é o que será trabalhado
nIDProject := oApp:Projects:GetCount()

// obtem a planilha do project atual
oProject := oApp:Projects(nIdProject)

// armazena a quantidade de tarefas existentes na planilha que est?sendo aberta.
nQtdTsk := oProject:Tasks:Count

// carrega os calendarios do sistema no MS-Project
PmsIncProc(.T.,,STR0043) //"Exportando calendarios..."
dbSelectArea("SH7")
dbSetOrder(1)
dbSeek(cFilSH7)

While !Eof() .And. SH7->H7_FILIAL == cFilSH7

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

DbSelectArea("AFY")
DbSetOrder(1) // AFY_FILIAL+AFY_PROJET+AFY_RECURS+DTOS(AFY_DATA)
dbSeek(cFilAFY)
While AFY->(!EOF()) .AND. AFY->AFY_FILIAL == cFilAFY
	If Empty(AFY->AFY_PROJET) .or. (AFY->AFY_PROJET==AF8->AF8_PROJET)
		aExcpt := {}
		aExcpt := PMSExcecpt(AFY_MALOC)
		lWork := !Empty(aExcpt[1, 2]) .or. !Empty(aExcpt[1, 3]) .or. ;
			!Empty(aExcpt[1, 4]) .or. !Empty(aExcpt[1, 5]) .or. ;
			!Empty(aExcpt[1, 6]) .or.  !Empty(aExcpt[1, 7]) .or. ;
			!Empty(aExcpt[1, 8]) .or. !Empty(aExcpt[1, 9]) .or. ;
			!Empty(aExcpt[1, 10]) .or. !Empty(aExcpt[1, 11])

		dDataAFY := AFY->AFY_DATA
		While dDataAFY <= AFY->AFY_DATAF
			For nx := 1 to Len(aSH7)
				oApp:BaseCalendarEditDays(aSH7[nx], dDataAFY, , , lWork ,PmsWrHora(nVersao,aExcpt[1, 2]), PmsWrHora(nVersao,aExcpt[1, 3]),;
					PmsWrHora(nVersao,aExcpt[1, 4]), PmsWrHora(nVersao,aExcpt[1, 5]),PmsWrHora(nVersao,aExcpt[1, 6]),PmsWrHora(nVersao,aExcpt[1, 7]),,PmsWrHora(nVersao,aExcpt[1, 8]),PmsWrHora(nVersao,aExcpt[1, 9]),;
					PmsWrHora(nVersao,aExcpt[1, 10]), PmsWrHora(nVersao,aExcpt[1, 11]))
			Next nx
			dDataAFY++
		EndDo
	Endif
	AFY->(DbSkip())
EndDo

If lRecurso .AND. !lUsaAJT
	For nK := 1 To oProject:Resources:GetCount()
		aAdd(aRecMSP, oProject:Resources(nK):GetField('PJRESOURCEINITIALS')) //Carrega os recursos existentes no project
	Next nX
	// carrega os recursos do sistema no MS-Project
	dbSelectArea("AE8")
	dbSetOrder(1)
	dbSeek(cFilAE8)
	While AE8->( !Eof() ) .And. cFilAE8 == AE8->AE8_FILIAL
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
			
			If Ascan(aRecMSP,AllTrim(AE8->AE8_RECURS)) == 0 //Caso o recuros ja exista não faz a carga novamente
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
		EndIf
		dbSelectArea("AE8")
		dbSkip()
	End
ElseIf lAloc .AND. !lUsaAJT

	// carrega somente os recusos alocados no projeto no MS-Project
	PmsIncProc(.T.,,STR0025) //'Exportando recursos alocados...'
	dbSelectArea("AFA")
	dbSetOrder(1)
	dbSeek(cFilAFA+AF8->AF8_PROJET+AF8->AF8_REVISA)
	While !Eof() .And. cFilAFA+AF8->AF8_PROJET+AF8->AF8_REVISA==AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA
		AE8->(dbSetOrder(1))
		AE8->(dbSeek(cFilAE8+AFA->AFA_RECURS))
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

// carrega o Projeto
PmsIncProc(.T.,,STR0026) // 'Exportando projeto...'
IF (!lPMS410 .AND. (!lSemelhante .And. nOpcx == 3) .Or. (nOpcx == 2)) .OR.;
	(lPMS410 .AND. nOpcx ==4 .AND. lExport)// nOpcx do PMSA410 (Projetos Mod. 2)

	If lCpyF7
		For nx:=1	to Len(aMark)
			If aMark[nx][1]=="AFC"
				("AFC")->(MsGoTo(aMark[nx][2]))
				PmcAddPrj(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,oApp,aProject,aRecursos,nVersao,lAloc,lPOC,aClone(aEDTs),lCpyF7,{},@nIDProject)
			Else
				("AF9")->(MsGoTo(aMark[nx][2]))
				aadd(aTRFs,	AF9->AF9_TAREFA )
				PmcAddPrj(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,oApp,aProject,aRecursos,nVersao,lAloc,lPOC,{},lCpyF7,aClone(aTRFs),@nIDProject)
			Endif
		Next nx

		dbSelectArea("AFC")
		dbSetOrder(3)
		MsSeek(cFilAFC+AF8->AF8_PROJET+AF8->AF8_REVISA+"002")
		While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
							AFC->AFC_NIVEL==cFilAFC+AF8->AF8_PROJET+AF8->AF8_REVISA+"002"
			If aScan(aEDTs, {|x| x==AFC->AFC_EDT}) > 0
				PmcAddPrj(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,oApp,aProject,aRecursos,nVersao,lAloc,lPOC,aEDTs,lCpyF7,aTRFs,@nIDProject)
			Endif
			AFC->(dbSkip())
		EndDo

	Else
		dbSelectArea("AFC")
		dbSetOrder(3)
		MsSeek(cFilAFC+AF8->AF8_PROJET+AF8->AF8_REVISA+"001")
		While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
							AFC->AFC_NIVEL==cFilAFC+AF8->AF8_PROJET+AF8->AF8_REVISA+"001"
			PmcAddPrj(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,oApp,aProject,aRecursos,nVersao,lAloc,lPOC,aEDTs,lCpyF7,aTRFs,@nIDProject)
			AFC->(dbSkip())
		EndDo
	Endif

	If lRelac
		PmsIncProc(.T.,,STR0027) //'Exportando relacionamentos...'

		// adiciona as predecessoras da tarefa
		dbSelectArea("AFD")
		dbSetOrder(1)
		MsSeek(cFilAFD+AF8->AF8_PROJET+AF8->AF8_REVISA)
		While !Eof() .And. cFilAFD+AF8->AF8_PROJET+AF8->AF8_REVISA==;
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
		MsSeek(cFilAJ4+AF8->AF8_PROJET+AF8->AF8_REVISA)
		While !Eof() .And. cFilAJ4+AF8->AF8_PROJET+AF8->AF8_REVISA==;
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
Endif
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
@param aEDT,,
@param lCpyF7,,
@param aTRF,,
@param nIDProject,,

@return

/*/
//-------------------------------------------------------------------
Static Function PmcAddPrj(cChave,oApp,aProject,aRecursos,nVersao,lAloc,lPOC,aEDT,lCpyF7,aTRF,nIdProject)
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFC	:= AFC->(GetArea())
Local aNodes 		:= {}
Local aRecAFA		:= {}
Local cAliasQry	:= "Exp"+getNextAlias()

Local cDataRest 	:= ""
Local cHDurac		:= ''
Local cHoraI		:= ""
Local cHoraF    	:= ""
Local cHoraRest 	:= ""
Local cIdAF9		:= ''
Local cIdAFC		:= ''
Local cNo      	:= IIF( nVersao == 2 /*ingles*/, "NO", IIf( nVersao == 3 /*espanhol*/, "NO", "NAO" ) )
Local cRecursos 	:= ""
Local cTipoAg  	:= ""
Local cTipoRest 	:= ""
Local cTipoTrf	:= ""
Local cYes     	:= IIF( nVersao == 2 /*ingles*/, "YES", IIf( nVersao == 3 /*espanhol*/, "SI", "SIM" ) )
Local nTamAF9Ord	:= 0
Local nTamAFCOrd	:= 0

Local nNode  		:= 0

Local lSelEDT		:= .F.

Local oProject

DEFAULT lCpyF7	:= .F.
DEFAULT aTRF		:= {}
DEFAULT nIDProject := 1

If lCpyF7
	lSelEDT := .T.
Else
	lSelEDT := TYPE("aEDT") <> "U" .and. Len(aEDT) > 0
Endif

oProject := oApp:Projects(nIDProject)

PmsIncProc(.T.,,STR0028+AFC->AFC_EDT+"'") // "' Exportando EDT '"

If PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,1,"ESTRUT",AFC->AFC_REVISA).And. (aEDT==Nil .Or. aScan(aEDT, {|x| x==AFC->AFC_EDT}) > 0)

	If Val(AFC->AFC_NIVEL) > 1 // Não se trata da EDT Principal(Tarefa resumo do projeto)
		nAdd++
		// adiciona a EDT no MS-Project
		aAdd(aProject,{"AFC",AFC->(RecNo()),AFC->AFC_EDT})
		oProject:Tasks:Add(AllTrim(StrGantt(AFC->AFC_DESCRI)))
		oProject:Tasks(Len(aProject)):Calendar	:= AFC->AFC_CALEND
		oProject:Tasks(Len(aProject)):Text1	:= AFC->AFC_EDT

		If (nPos := aScan(aNivel, {|x| x[1]==AFC->AFC_NIVEL})) == 0
			oProject:Tasks(Len(aProject)):SetField('PJTASKOUTLINELEVEL',Val(AFC->AFC_NIVEL))
			aadd(aNivel, { AFC->AFC_NIVEL , PmsReadTsk(nAdd,PJTASKOUTLINELEVEL) } )
		Else
			oProject:Tasks(Len(aProject)):SetField('PJTASKOUTLINELEVEL',aNivel[nPos][2])
		Endif
		oProject:Tasks(Len(aProject)):SetField('PJTASKNUMBER1', PMSPonVir(Str(AFC->AFC_QUANT)))
		oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT2',AFC->AFC_UM)
		oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT26',If(lSelEDT,AFC->AFC_EDTPAI,'') )
		oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT27',AFC->AFC_NIVEL)
		oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT28',AFC->AFC_ORDEM)

		If Empty(AFC->AFC_IDPROJ)
			cIdAFC := "AFC" + GetNewId(nTamID-3)
			oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT29', cIdAFC)

			Reclock('AFC',.F.)
				AFC_IDPROJET := cIdAFC
			MsUnlock()
		Else
			oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT29',AFC->AFC_IDPROJET)
		Endif

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
			oProject:Tasks(Len(aProject)):SetField('PJTASKBASELINESTART', , strZero(Day(AFC->AFC_START),2)+"/"+strZero(Month(AFC->AFC_START),2,0)+"/"+Right(strZero(Year(AFC->AFC_START),4),2)+" "+AFC->AFC_HORAI) // garantindo o formato em DD/MM/YY)
			oProject:Tasks(Len(aProject)):SetField('PJTASKBASELINEFINISH', strZero(Day(AFC->AFC_FINISH),2)+"/"+strZero(Month(AFC->AFC_FINISH),2)+"/"+Right(strZero(Year(AFC->AFC_FINISH),4),2)+" "+AFC->AFC_HORAF) // garantindo o formato em DD/MM/YY
			oProject:Tasks(Len(aProject)):SetField('PJCUSTOMTASKDATE1', strZero(Day(AFC->AFC_DTATUI),2)+"/"+strZero(Month(AFC->AFC_DTATUI),2,0)+"/"+Right(strZero(Year(AFC->AFC_DTATUI),4),2)) // garantindo o formato em DD/MM/YY
			oProject:Tasks(Len(aProject)):SetField('PJCUSTOMTASKDATE2', strZero(Day(AFC->AFC_DTATUF),2)+"/"+strZero(Month(AFC->AFC_DTATUF),2,0)+"/"+Right(strZero(Year(AFC->AFC_DTATUF),4),2)) // garantindo o formato em DD/MM/YY
		Endif

		oProject:Tasks(Len(aProject)):Duration := '0 h'

		oProject:Tasks(Len(aProject)):SetField('PJTASKMANUAL', '1') // Altero o modo de tarefa como manual

		oProject:Tasks(Len(aProject)):SetField('PJTASKWORK', AFC->AFC_HESF)

		If lPMSSetFld
			ExecBlock("PMSSetFld", .F. , .F. , {oProject, 1, Len(aProject)} )
		Endif
	EndIf
EndIf

If !lCpyF7 

	nTamAF9Ord := TamSx3('AF9_ORDEM')[1]
	nTamAFCOrd := TamSx3('AFC_ORDEM')[1]

	dbSelectArea("AF9")
	dbSetOrder(2)
	MsSeek(cFilAF9+cChave)
	While AF9->(!Eof()) .And. AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+;
								AF9->AF9_EDTPAI==cFilAF9+cChave

		aAdd(aNodes, {PMS_TASK,;
		              AF9->(Recno()),;
		              If(Empty(AF9->AF9_ORDEM), StrZero(0,nTamAF9Ord), AF9->AF9_ORDEM),;
		              AF9->AF9_TAREFA})
		AF9->(dbSkip())
	Enddo

	dbSelectArea("AFC")
	dbSetOrder(2)
	MsSeek(cFilAFC+cChave)
	While AFC->(!Eof()) .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
				AFC->AFC_EDTPAI==cFilAFC+cChave

		aAdd(aNodes, {PMS_WBS,;
		              AFC->(Recno()),;
		              If(Empty(AFC->AFC_ORDEM), StrZero(0,nTamAFCOrd), AFC->AFC_ORDEM),;
		              AFC->AFC_EDT})
		AFC->(dbSkip())
	End

	aSort(aNodes, , , {|x, y| x[3]+x[4] < y[3]+y[4]})
Endif

cTipoRest := ""
cDataRest := ""
cHoraRest := ""
cTipoAg   := ""
cTipoTrf  := ""

If lCpyF7 .AND. Len(aTRF) > 0 // CONTORNO PARA REUSO DO FOR ABAIXO
	aAdd(aNodes, {PMS_TASK} )
Endif
For nNode := 1 To Len(aNodes)
	If aNodes[nNode][1] == PMS_TASK
		If !lCpyF7 //senao ja estou posicionado
			AF9->(dbGoto(aNodes[nNode][2]))
		Endif

		PmsIncProc(.T.,,STR0029+AF9->AF9_TAREFA+"'")//"Exportando Tarefa '"

		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA, ,AF9->AF9_EDTPAI,1,"ESTRUT",AF9->AF9_REVISA) .And. ;
				Iif(lCpyF7, ;
					aTRF==Nil .Or. aScan(aTRF, {|x| x==AF9->AF9_TAREFA}) > 0 ,;
					(aEDT==Nil .Or. aScan(aEDT, {|x| x==AF9->AF9_EDTPAI}) > 0))

			nAdd++
			cDataI := IIf(!Empty(AF9->AF9_START),strZero(Day(AF9->AF9_START),2)+"/"+strZero(Month(AF9->AF9_START),2,0)+"/"+Right(strZero(Year(AF9->AF9_START),4),2),NIL) // garantindo o formato em DD/MM/YY
			cDataF := IIf(!Empty(AF9->AF9_FINISH),strZero(Day(AF9->AF9_FINISH),2)+"/"+strZero(Month(AF9->AF9_FINISH),2)+"/"+Right(strZero(Year(AF9->AF9_FINISH),4),2),NIL) // garantindo o formato em DD/MM/YY
			cHoraI := AF9->AF9_HORAI
			cHoraF := AF9->AF9_HORAF
			cTipoRest := ""
			aAdd(aProject,{"AF9",AF9->(RecNo()),AF9->AF9_TAREFA})
			oProject:Tasks:Add(AllTrim(StrGantt(AF9->AF9_DESCRI)))
			oProject:Tasks(Len(aProject)):Calendar	:= AF9->AF9_CALEND
			oProject:Tasks(Len(aProject)):Text1	:= AF9->AF9_TAREFA

			If (nPos := aScan(aNivel, {|x| x[1]==AF9->AF9_NIVEL})) == 0
				oProject:Tasks(Len(aProject)):SetField('PJTASKOUTLINELEVEL',Val(AF9->AF9_NIVEL)-1)
				aadd(aNivel, { AF9->AF9_NIVEL , PmsReadTsk(nAdd,PJTASKOUTLINELEVEL) } )
			Else
				oProject:Tasks(Len(aProject)):SetField('PJTASKOUTLINELEVEL', aNivel[nPos][2] )
			Endif
			oProject:Tasks(Len(aProject)):SetField('PJTASKNUMBER1', PMSPonVir(Str(AF9->AF9_QUANT)))
			oProject:Tasks(Len(aProject)):SetField('PJTASKPRIORITY',Max(AF9->AF9_PRIORI,0))
			oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT2',AF9->AF9_UM)
			oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT26',If(lSelEDT,AF9->AF9_EDTPAI,'') )
			oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT27',AF9->AF9_NIVEL)
			oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT28',AF9->AF9_ORDEM)

			If Empty(AF9->AF9_IDPROJ)
				cIdAF9 := "AF9" + GetNewId(nTamID-3)
				oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT29', cIdAF9)

				Reclock('AF9',.F.)
					AF9_IDPROJET := cIdAF9
				MsUnlock()
			Else
				oProject:Tasks(Len(aProject)):SetField('PJTASKTEXT29',AF9->AF9_IDPROJ)
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
				oProject:Tasks(Len(aProject)):SetField('PJTASKBASELINEFINISH', cDataF  + " " + cHoraF)
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
				If lTopConn
					cQuery  := " SELECT AFA.AFA_ALOC, AFA.AFA_RECURS, AFA.R_E_C_N_O_, AE8.AE8_DESCRI FROM "
					cQuery  += cAliasAFA +" AFA, "+cAliasAE8+" AE8 "
					cQuery  += " WHERE AFA.AFA_FILIAL = '"+cFilAFA+"' AND "
					cQuery  += " AFA.AFA_PROJET = '"+AF9->AF9_PROJET+"' AND "
					cQuery  += " AFA.AFA_REVISA = '"+AF9->AF9_REVISA+"' AND "
					cQuery  += " AFA.AFA_TAREFA = '"+AF9->AF9_TAREFA+"' AND "

					If lAllCompar
						cQuery  += " AE8.AE8_FILIAL = AFA.AFA_FILIAL AND"
					Elseif lAE8EAFAC
						cQuery  += " AE8.AE8_FILIAL = '"+cFilAE8+"' AND "
					Endif
					cQuery  += " AFA.AFA_RECURS = AE8.AE8_RECURS AND "
					cQuery  += " AFA.D_E_L_E_T_ = ' ' AND "
					cQuery  += " AE8.D_E_L_E_T_ = ' ' "

					cQuery	:= ChangeQuery(cQuery)
					dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry , .T. , .T. )

					//posiciona no registro referente a confirmação ate a database
					While (cAliasQry)->( !EOF() )
						AE8->(dbSetOrder(1))
						If AE8->(dbSeek(cFilAE8+(cAliasQry)->(AFA_RECURS) ) )
							If lPMS010EX
								nAFAAloc := ExecBlock("PMS010EX", .F., .F., { (cAliasQry)->(AFA_ALOC) , (cAliasQry)->(RECNO_) } )
							Else
								nAFAAloc := (cAliasQry)->(AFA_ALOC)
							Endif

							If Ascan(aRecAFA,(cAliasQry)->(AFA_RECURS) ) == 0
								cRecursos += AllTrim((cAliasQry)->(AFA_RECURS))+"-"+AllTrim(AE8->AE8_DESCRI)+"[" + Str(nAFAAloc,4,0)  + "%];"
								AAdd(aRecAFA,(cAliasQry)->(AFA_RECURS))
							Endif
						Endif

						(cAliasQry)->( dbSkip() )
					EndDo
					(cAliasQry)->(dbCloseArea())
					dbSelectArea("AFC")
				Else
					dbSelectArea("AFA")
					dbSetOrder(1)
					MsSeek(cFilAFA+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
					While AFA->(!Eof()) .And. cFilAFA+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
										AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA

						If !Empty(AFA->AFA_RECURS)
							AE8->(dbSetOrder(1))
							If AE8->(dbSeek(cFilAE8+AFA->AFA_RECURS))

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
				Endif

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

		PmcAddPrj(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,oApp,aProject,aRecursos,nVersao,lAloc,lPOC,aEDT,,,@nIDProject)
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

	If Empty(cCodDig)
		cRetCod := PmsNumAFC(AF8->AF8_PROJET,AF8->AF8_REVISA,If(Empty(aEDTPAI),cNivelOne,cNivelAFC),If(Empty(aEDTPAI),AF8->AF8_PROJET,aEDTPAI[Len(aEDTPAI),1]))
	Else
		dbSelectArea("AFC")
		dbSetOrder(1)
		If dbSeek(cFilAFC+cProjeto+cRevisa+cCodDig) .Or. Len(AllTrim(cCodDig))>Len(AFC->AFC_EDT)
			cRetCod := PmsNumAFC(AF8->AF8_PROJET,AF8->AF8_REVISA,If(Empty(aEDTPAI),cNivelOne,aEDTPAI[Len(aEDTPAI),2]),If(Empty(aEDTPAI),AF8->AF8_PROJET,aEDTPAI[Len(aEDTPAI),1]))
		Else
			cRetCod := cCodDig
		EndIf
	EndIf
	RestArea(aAreaAFC)
Else
	aAreaAF9 := AF9->(GetArea())
	cNivelAF9	:= STRZERO(VAL(aTask[_OUTLINELEVEL]), nTamAF9Niv)

	If Empty(cCodDig)
		cRetCod := PmsNumAF9(AF8->AF8_PROJET,AF8->AF8_REVISA,If(Empty(aEDTPAI),cNivelOne,cNivelAF9),If(Empty(aEDTPAI),AF8->AF8_PROJET,aEDTPAI[Len(aEDTPAI),1]))
	Else
		dbSelectArea("AF9")
		dbSetOrder(1)
		If dbSeek(cFilAF9+cProjeto+cRevisa+cCodDig) .Or. Len(AllTrim(cCodDig))>Len(AF9->AF9_TAREFA)
			cRetCod := PmsNumAF9(AF8->AF8_PROJET,AF8->AF8_REVISA,If(Empty(aEDTPAI),cNivelOne,aEDTPAI[Len(aEDTPAI),2]),If(Empty(aEDTPAI),AF8->AF8_PROJET,aEDTPAI[Len(aEDTPAI),1]))
		Else
			cRetCod := cCodDig
		EndIf
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
/*/{Protheus.doc} PMSC010B

Programa de Sincronizacao do Projeto com o MS-Project

@author Edson Maricate
@since 29.10.2002
@version P10 R4

@param cAlias,,
@param nReg,,
@param nOpcx,,

@return nulo

/*/
//-------------------------------------------------------------------
Function Pmsc010B(cAlias,nReg,nOpcx)
Local oApp
Local oProcess
Local nOpc 		:= 1
Local nFindPrj	:= 0
Local nIDProject	:= 1
Local aConfig		:= {}
Local aGrupoUsr	:= {}
Local lContinua	:= .T.
Local lOk 			:= .F.
Local cGrupoUsr 	:= ""
Local cPMSXMSP	:= SuperGetMv("MV_PMSXMSP",,"0")

Private aRecAmarr	:= {}
Private cRevisa	:= AF8->AF8_REVISA

aGrupoUsr	:= UsrRetGrp(__cUserID)
If ValType(aGrupoUsr)=="A" .AND. Len(aGrupoUsr) > 0
	cGrupoUsr := aGrupoUsr[1]
Endif

IncProc(STR0092)//"Carregando exececoes de calendario"
PmsAvalCal()

If PmsChkUser(AF8->AF8_PROJET,,AF8->AF8_PROJET, "" /*AFC->AFC_EDTPAI*/ ,2,"ESTRUT",AF8->AF8_REVISA) .or. PmsTemUser(AF8->AF8_PROJET,AF8->AF8_REVISA,__cUserID,cGrupoUsr)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Verifica se o projeto nao esta reservado.            ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AF8->AF8_PRJREV=="1" .And. AF8->AF8_STATUS<>"2" .And. GetNewPar("MV_PMSRBLQ","N")=="S"
		Aviso(STR0049 ,; // Gerenciamento de Revisoes
				STR0050 ,; // "Este projeto nao se encontra em revisao. Para realizar uma alteracao no projeto, deve-se primeiro Iniciar uma revisao no projeto atraves do Gerenciamento de Revisoes."
				{STR0033},2) // Fechar
		lContinua := .F.
	EndIf

	If lContinua
		PmsNewProc()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Verifica o evento de alteracao na fase atual ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lContinua := PmsVldFase("AF8",AF8->AF8_PROJET,"11")
	    If lContinua
			Aviso(STR0051,STR0052,{"Ok"},2)  // "Integracao Microsoft Project 2000" ; "Atencao! Certifique-se de que o formato da data no Microsoft Project (Ferramentas - Opcoes) esta configurado corretamente : 31/12/00 12:33"
				lContinua := ParamBox({	{3,STR0053,1,{STR0054,STR0055,STR0056},90,,.F.},; // "Selecione a versão do MS-Project" / "Microsoft Project 2000 Ingles" /  "Microsoft Project 2000 Espanhol"
									{6,STR0057,SPACE(200),"","Empty(mv_par02).Or.FILE(mv_par02)","", 65 ,.F.,STR0058,,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE},; // Projeto Modelo ; "Projetos MS-Project *.MPP |*.MPP"
									{4,STR0059,.T.,STR0060,80,,.F.},; //"Criar cópia em arquivo temp. ?" ; "SIM"
									{4,STR0061,.T.,STR0062,90,,.F.},;  // 'Exportar : "  "Planilha de Recursos"
									{4,"",.T.,STR0063,80,,.F.},; //"Recursos Alocados"
									{4,"",.T.,STR0064,70,,.F.},; //"Relacionamentos"
									{4,"",.T.,STR0065,80,,.F.},; //"Progresso Físico"
									{4,STR0066,.F.,STR0060,80,,.F.},; // "Habilitar MV_PMSTX30 ?"
									{4,STR0067,.F.,STR0060,80,,.F.},; // "Projetos semelhantes ?"
									{3,STR0068,1,{STR0069,STR0070,STR0071},90,,.F.},; // "Avisos" / "Mostrar" / "Logar" / "Ambos"
									{4,"",.T.,STR0072,80,,.F.}; // "Quebra Arquivo de Log ?"
									},STR0073,aConfig)  //"Configuracoes"
	    EndIf
	EndIf

	If lContinua .and. aConfig[9] .and. Empty(aConfig[2])
		Alert(STR0091) //"Favor informar um arquivo local de Project para realizar o sincronismo."
		lContinua := .F.
	Endif
	If lContinua
		While nFindPrj < 10 .And. !ApOleClient( "MsProject" )
			nFindPrj++
		EndDo

		lUsaAJT	:= AF8ComAJT( AF8->AF8_PROJET )
		If nFindPrj < 10

	        PmsShowWar(aConfig [10]) // Mostrar os Avisos
	        PMSC10SetW(.F.) // Nao ha erros logados.

			oApp := MsProject():New()
			nIdProject := oApp:Projects:Count()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Realiza a exportacao para o Microsoft Project        ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Processa({|| Aux010BExp(cAlias,nReg,nOpcx,@oApp,aConfig[1],aConfig[2],aConfig[4],aConfig[5],aConfig[6],aConfig[7],, aConfig[9],aConfig[3],,,,@nIDProject) },"Carregando Microsoft Project. Aguarde...")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Monta o assistent de importacao do Microsoft Project ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While nOpc == 1 .Or. nOpc == 2
				nOpc := Aviso(STR0074,STR0075+; //"Assistente de integracao." + "O projeto selecionado esta disponivel no Microsoft Project para atualizacao."
					CHR(10)+CHR(13)+CHR(10)+CHR(13)+STR0076+; // "- Selecione a opcao 'Importar' para realizar a atualizacao dos dados do projeto a partir do Microsoft Project. "
					CHR(13)+CHR(10)+STR0077+CHR(10)+CHR(13)+; // "- Selecione a opcao 'Visualizar' para consultar a estrutura do projeto."
					STR0078,{STR0079,STR0080,STR0081},3) // "- Selecione a opcao 'Sair' para finalizar a integracao com o Microsoft Project." // IMPORTAR  /  VISUALIZAR / SAIR
				PmsNewProc()
				If nOpc == 1
					If PMS200Rev()
						oProcess := MsNewProcess():New({||Aux010BGrv(@oProcess,cAlias,nReg,nOpcx,@oApp,aConfig[1],aConfig[2],aConfig[4],aConfig[5],aConfig[6],aConfig[7],aConfig[8],aConfig[9],@aRecAmarr, !aConfig[11], @nIDProject)},"Importando do MS-Project","Atualizando Projeto. Aguarde...")
						oProcess:Activate()
					EndIf
				EndIf
				If nOpc == 2
					PMSA200(2,AF8->AF8_REVISA)
				EndIf
				If cPMSXMSP == "1"
					If nOpc == 3
						lOk := MsgYesNo(STR0034+CHR(10)+CHR(13)+ STR0047+; // "Atenção !! - Verifique se o Projeto foi salvo no MsProject. "
						CHR(10)+CHR(13)+CHR(10)+CHR(13)+ STR0048)              // "Confirma encerramento da sincronização?"
						If !lOk
							nOpc := 2
							Loop
						EndIf
					EndIf
				EndIf
			EndDo

			If PMSC10SetW() // Ha erros logados
				MsgStop( STR0082 ) //"H?ocorrências gravadas no arquivo de LOG. Analise, por favor."
			EndIf

			oApp:Quit( 0 )
			oApp:Destroy()

		Else
			MsgStop( STR0083 ) //'Microsoft Project 2000 nao instalado.'
		EndIf
	EndIf

Else
	MsgAlert(STR0088, STR0089) // "Usuário sem permissão de acesso ?estrutura deste projeto. Favor verificar com Administrador." , "Permissão de Usuário"
Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PMC010BExp

Programa de Sincronizacao do Projeto com o MS-Project

@author Edson Maricate
@since 29.10.2002
@version P10 R4

@param cAlias,,
@param nReg,,
@param nOpcx,,

@return nulo

/*/
//-------------------------------------------------------------------
Function PMC010BExp(cAlias,nReg,nOpcx)
Local oApp
Local nFindPrj	:= 0
Local nx			:= 0
Local nIDProject 	:= 0
Local aConfig		:= {}
Local aTRFs		:= {}
Local aEDTs		:= {}
Local aGrupoUsr	:= {}
Local cGrupoUsr 	:= ""
Local cAviso		:= STR0090 // "Selecção inválida. Esta consulta permite apenas a selecção das tarefas do projecto. Verifique o objeto seleccionado."
Local lCpyF7		:= SuperGetMV("MV_PMSCPSL",,"2") == "1"

Private aRecAmarr	:= {}
Private aMark		:= {}

aGrupoUsr	:= UsrRetGrp(__cUserID)
If ValType(aGrupoUsr)=="A" .AND. Len(aGrupoUsr) > 0
	cGrupoUsr := aGrupoUsr[1]
Endif

If PmsChkUser(AF8->AF8_PROJET,,AF8->AF8_PROJET, "" /*AFC->AFC_EDTPAI*/ ,2,"ESTRUT",AF8->AF8_REVISA) .OR. PmsTemUser(AF8->AF8_PROJET,AF8->AF8_REVISA,__cUserID,cGrupoUsr)

	PmsNewProc()
	If ParamBox({	{3,STR0053,1,{STR0054,STR0055,STR0056},90,,.F.},;
				{6,STR0057,SPACE(200),"","Empty(mv_par02).Or.FILE(mv_par02)","", 65 ,.F.,STR0058,,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE},; //
				{4,STR0061,.T.,STR0062,70,,.F.},;	// Exportar    Planilha de Recursos
				{4,"",.T.,STR0063,80,,.F.},; 		// Recursos Alocados
				{4,"",.T.,STR0064,70,,.F.},; 		// Relacionamentos
				{4,"",.T.,STR0065,80,,.F.},;        // Progresso Fisico
				{3,STR0084,1,{STR0085,STR0086},80,,.F.}; // Projeto completo / Selecionar EDT
				},STR0073,aConfig)  // "Configurações"

		While nFindPrj < 10 .And. !ApOleClient( "MsProject" )
			nFindPrj++
		End

		lUsaAJT := AF8ComAJT( AF8->AF8_PROJET )                              '
		If nFindPrj < 10
			If aConfig[7]==2
				PmsSetF3('AF9',2)
				aRet := PmsSelTsk(STR0087,"AF8/AF9/AFC","AFC/AF9",cAviso,"AF8",AF8->AF8_PROJET,.F.,.F.,AF8->AF8_REVISA,@aMark)    //"Selecione as tarefas a exportar"
				If lCpyF7
					lContinua	:= Len(aMark)>0
					For nx:=1 to Len(aMark)
						If aMark[nx][1]=="AFC"
							("AFC")->(MsGoTo(aMark[nx][2]))
							aadd(aEDTs,	AFC->AFC_EDT )
						Else
							("AF9")->(MsGoTo(aMark[nx][2]))
							aadd(aTRFs,	AF9->AF9_TAREFA )
						Endif
					Next nx
				Else
					lContinua	:= Len(aRet)>0
					If lContinua
						AFC->(MsGoTo(aRet[2]))
						aEDTs	:=	{AFC->AFC_EDT}
						AFC->(DbSetOrder(2))
						PMSAFCFilh(@aEDTs,AFC->AFC_EDT)
					Endif
				Endif
			Else
				lContinua	:=	.T.
			Endif
			If lContinua
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Realiza a exportacao para o Microsoft Project        ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oApp := MsProject():New()
				nIdProject := oApp:Projects:Count()
				Processa({|| Aux010BExp(cAlias,nReg,nOpcx,@oApp,aConfig[1],aConfig[2],aConfig[3],aConfig[4],aConfig[5],aConfig[6],iif(aConfig[7]==2,aEDTs,),.T.,,(aConfig[7]==2.and.lCpyF7),aTRFs, .T.,@nIDProject,.T.) },"Carregando Microsoft Project. Aguarde...")
				Aviso(STR0074,STR0075+; // "Assistente de integracao.","O projeto selecionado esta disponivel no Microsoft Project para atualizacao."
					CHR(10)+CHR(13)+CHR(10)+CHR(13)+STR0078,{STR0081},3) // "- Selecione a opção 'Sair' para finalizar a integração com o Microsoft Project."
				oApp:Quit( 0 )
				oApp:Destroy()

			Endif
		Else
			MsgStop( STR0083 ) //'Microsoft Project 2000 nao instalado.'
		EndIf
	EndIf

Else

	MsgAlert(STR0088, STR0089) // "Usuário sem permissão de acesso ?estrutura deste projeto. Favor verificar com Administrador." , "Permissão de Usuário"

Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetNewId

Gera codigo para amarracao do registro do SIGAPMS com a linha do MsProject.

@author Clovis Magenta
@since 20/03/13
@version P10 R4

@param nLimite,,

@return nulo

/*/
//-------------------------------------------------------------------
Static Function GetNewId(nLimite)

Local nID			:= 0
Local nPosSep		:= 0
Local nPosIni		:= 1
Local nRecs		:= AFC->(Recno()) + AF9->(Recno())
Local nFator		:= Randomize(0, 32000)
Local cTime		:= time()
Local cNewTime	:= ""

While (nPosSep := At(":",cTime)) > 0
	cNewTime += Substr(cTime,nPosIni,nPosSep-1)
	cTime := Substr(cTime,nPosSep+1)
Enddo
cNewTime += cTime

nID := Val(DtoS(dDatabase) + cNewTime)
nID := (nID / nFator) - (nRecs)

cReturn:= alltrim(STR(nID))
cReturn:= SUBSTR(cReturn,1,nLimite)

Return cReturn


//-------------------------------------------------------------------
/*/{Protheus.doc} GetNewId

Funcao para pegar a EDT pai do registro importado do MSProject.
@author Clovis Magenta
@since 20/03/13
@version P10 R4

@param nFieldAnt,,
@param aDadosTsk,,
@param nOpc,,
@param lAF9,,

@return nulo

/*/
//-------------------------------------------------------------------
Static Function PmsGetPai(nFieldAnt,aDadosTsk,nOpc,lAF9)

Local aArea 		:= GetArea()
Local aAreaAF9 	:= AF9->(GetArea())
Local aAreaAFC 	:= AFC->(GetArea())
Local cEdtPai 	:= ""
Local cCodProject	:= PmsReadTsk(nFieldAnt,PJTASKTEXT29)
Local cNivel		:= ""

DEFAULT lAF9		:= .F.

If nOpc == 1 // Quando a anterior estiver no mesmo nível, basta procurar a EDT Pai da anterior (se for TAREFA)
	dbSelectArea("AF9")
	dbSetOrder(7)
	If MsSeek(cFilAF9+cCodProject)
		cEdtPai := AF9->AF9_EDTPAI
		cNivel	:= STRZERO( VAL(AF9->AF9_NIVEL)-1, nTamAFCNiv)
		cNivTX30 := AF9->AF9_NIVEL
		aAdd(aEDTPAI,{AF9->AF9_EDTPAI,cNivel}   )
	Endif
ElseIf nOpc == 2 // Quando a anterior estiver no mesmo nível, basta procurar a EDT Pai da anterior (se for EDT)
	dbSelectArea("AFC")
	dbSetOrder(5)
	If MsSeek(cFilAFC+cCodProject)
		cEdtPai := AFC->AFC_EDTPAI
		cNivel	:= STRZERO( VAL(AFC->AFC_NIVEL)-1, nTamAFCNiv)
		cNivTX30 := AFC->AFC_NIVEL
		aAdd(aEDTPAI,{AFC->AFC_EDTPAI,cNivel})
	Endif

ElseIf nOpc == 3  // Quando a anterior NÃO estiver no mesmo nível, procura EDT Pai da tarefa anterior
	If "AFC" $ cCodProject
		dbSelectArea("AFC")
		dbSetOrder(7)
		If MsSeek(cFilAFC+cCodProject)
			cEdtPai := AFC->AFC_EDT
			cNivel	:= STRZERO( VAL(AFC->AFC_NIVEL)+1, nTamAFCNiv)
			aAdd(aEDTPAI,{AFC->AFC_EDT,cNivel})
		Endif
	Else
		dbSelectArea("AF9")
		dbSetOrder(7)
		If MsSeek(cFilAF9+cCodProject+AF8->AF8_PROJET)
			dbSelectArea("AFC")
			dbSetOrder(1)
			If MsSeek(cFilAFC+AF9->(AF9_PROJET+AF9_REVISA+AF9_EDTPAI)) // PROCURAMOS A EDT PAI DA EDT DO MESMO NIVEL QUE ESTAMOS
				cEdtPai  := AFC->AFC_EDTPAI
				cNivel	 := STRZERO( VAL(AFC->AFC_NIVEL)-1, nTamAFCNiv)
				cNivTX30 := AFC->AFC_NIVEL
				aAdd(aEDTPAI,{AFC->AFC_EDTPAI,cNivel})
			Endif
		Endif
	Endif
ElseIf nOpc == 4  // Quando a anterior NÃO estiver no mesmo nível, procura EDT Pai da EDT anterior
	dbSelectArea("AFC")
	dbSetOrder(5)
	If MsSeek(cFilAFC+cCodProject)
		cEdtPai := AFC->AFC_EDT
		cNivel	:= STRZERO( VAL(AFC->AFC_NIVEL)+1, nTamAFCNiv)
		cNivTX30 := cNivel
		aAdd(aEDTPAI,{AFC->AFC_EDT,cNivel})
	Endif
Endif

RestArea(aAreaAFC)
RestArea(aAreaAF9)
RestArea(aArea)

Return cEdtPai


//-------------------------------------------------------------------
/*/{Protheus.doc} PmsTemUser

(desconhecido)

@author Clovis Magenta
@since 20/03/13
@version P10 R4

@param cProjeto,,
@param cRevisa,,
@param cUsuario,,
@param cGrupoUsr,,

@return nulo

/*/
//-------------------------------------------------------------------
Static Function PmsTemUser(cProjeto,cRevisa,cUsuario,cGrupoUsr)
Local cQuery	:= ""
Local cAlias	:= "UP"+getNextAlias()
Local lRet		:= .F.

cQuery	:= "SELECT COUNT(AFX_PROJET) QTDUSER FROM "+RetSqlName("AFX")
cQuery	+= " WHERE AFX_FILIAL = '"+xFilial("AFX")+"'"
cQuery 	+= " AND AFX_PROJET = '"+cProjeto+"' "
cQuery 	+= " AND AFX_EDT <> '"+cProjeto+"' "
cQuery 	+= " AND (AFX_REVISA = '"+cRevisa+"' OR AFX_REVISA = '"+SPACE(TAMSX3("AFX_REVISA")[1])+"')"
cQuery 	+= " AND (AFX_USER = '"+cUsuario+"' OR AFX_GRPUSR = '"+cGrupoUsr+"')"
cQuery	+= " AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T. )

If (cAlias)->(QTDUSER) > 0
	lRet := .T.
Endif

(cAlias)->( dbCloseArea() )

If !lRet
	cQuery	:= "SELECT COUNT(AFV_PROJET) QTDUSER FROM "+RetSqlName("AFV")
	cQuery	+= " WHERE AFV_FILIAL = '"+xFilial("AFV")+"'"
	cQuery 	+= " AND AFV_PROJET = '"+cProjeto+"' "
	cQuery 	+= " AND (AFV_REVISA = '"+cRevisa+"' OR AFV_REVISA = '"+SPACE(TAMSX3("AFV_REVISA")[1])+"')"
	cQuery 	+= " AND (AFV_USER = '"+cUsuario+"' OR AFV_GRPUSR = '"+cGrupoUsr+"')"
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T. )

	If (cAlias)->(QTDUSER) > 0
		lRet := .T.
	Endif

	(cAlias)->( dbCloseArea() )

Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PmsUpAEG

(desconhecido)

@author Clovis Magenta
@since 20/03/13
@version P10 R4

@param cCalend,,
@param cProjeto,,
@param cRevisa,,

@return nulo

/*/
//-------------------------------------------------------------------
Static Function PmsUpAEG(cCalend, cProjeto, cRevisa )
Local aCalendarios:= {}
Local nX		:= 0
DEFAULT cCalend	:= ""
STATIC _aAEGCal	:= {}
STATIC _aAEGExc	:= {}

/* Verifica outros calendarios neste projeto */
aCalendarios := GetAllCalend(cProjeto, cRevisa, cCalend)

/*
// CACHEAMENTO DO CALENDARIO ATUAL PARA CALCULO DE HORAS UTEIS POR SEMANA
// APÓS O USO DESTE CALENDARIO, DEVE ZERAR AS STATIC NA PMSDOWNAEG()
// USO DO ARRAY: ---> _aAEGCal
*/

DayXWeek(cCalend)

For nX:=1 to Len(aCalendarios)
	DayXWeek( aCalendarios[nX][1] )
Next nX

/*
// CACHEAMENTO DA EXCECAP DO ATUAL CALENDARIO PARA CALCULO DE HORAS UTEIS POR SEMANA
// APÓS O USO DESTE CALENDARIO, DEVE ZERAR AS STATIC NA PMSDOWNAEG()
*/

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DayXWeek

(desconhecido)

@author Clovis Magenta
@since 20/03/13
@version P10 R4

@param cCalend,,

@return nulo

/*/
//-------------------------------------------------------------------
STATIC Function DayXWeek(cCalend)
Local cQuery	:= ""
Local cAlias	:= "UP"+getNextAlias()

cQuery	:= "SELECT AEG_SEMANA, SUM(AEG_HUTEIS) HRSUTEIS FROM "+RetSqlName("AEG")
cQuery	+= " WHERE AEG_FILIAL = '"+xFilial("AEG")+"' AND AEG_CODIGO = '"+cCalend+"' "
cQuery 	+= " AND AEG_TIPO = 'C'"
cQuery	+= " AND D_E_L_E_T_ = ' ' "
cQuery	+= " GROUP BY AEG_SEMANA "
cQuery	+= " ORDER BY AEG_SEMANA "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T. )

While (cAlias)->(!EOF())
	aAdd( _aAEGCal , { (cAlias)->(AEG_SEMANA) , (cAlias)->(HRSUTEIS) } )
	(cAlias)->(dbSkip())
EndDo

(cAlias)->( dbCloseArea() )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAllCalend

(desconhecido)

@author Clovis Magenta
@since 20/03/13
@version P10 R4

@param cProjeto,,
@param cRevisa,,
@param cCalend,,

@return nulo

/*/
//-------------------------------------------------------------------
STATIC FUNCTION GetAllCalend(cProjeto, cRevisa,cCalend)
Local aCalend	:= {}
Local cQuery	:= ""
Local cAlias	:= "ALL"+getNextAlias()

cQuery	:= "SELECT DISTINCT AF9_CALEND FROM "+RetSqlName("AF9")
cQuery	+= " WHERE AF9_FILIAL = '"+xFilial("AF9")+"'"
cQuery 	+= " AND AF9_PROJET = '"+cProjeto+"'"
cQuery 	+= " AND AF9_REVISA = '"+cRevisa+"'"
cQuery 	+= " AND AF9_CALEND <> '"+cCalend+"'"
cQuery	+= " AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T. )

While (cAlias)->(!EOF())
	aAdd( aCalend , { (cAlias)->(AF9_CALEND) } )
	(cAlias)->(dbSkip())
EndDo

(cAlias)->( dbCloseArea() )
Return aCalend


//-------------------------------------------------------------------
/*/{Protheus.doc} PmsCalcAmar

(desconhecido)

@author Clovis Magenta
@since 20/03/13
@version P10 R4

@param cParm,,
@param aParam,,

@return nulo

/*/
//-------------------------------------------------------------------
Function PmsCalcAmar(cParm,aParam)
Local aDadosTsk		:= aParam[1]
Local aResources	:= aParam[2]
Local lPOC			:= aParam[3]
Local nVersao		:= aParam[4]
Local cProjeto		:= aParam[5]
Local nThread		:= aParam[6]
Local aRecAF9		:= aParam[7]
Local aRecAmarr		:= aParam[8]
Local cRevisa		:= aParam[9]
Local aAllTaks		:= aParam[10]
Local cMens93		:= ""
Local cMens95		:= ""
Local cMens91		:= ""
Local nPercComp		:= 0
Local aAuxArea		:= {}
Local aRecAFD		:= {}
Local aAtuAFD		:= {}
Local aRecAJ4		:= {}
Local aAtuAJ4		:= {}
Local aRecAFA		:= {}

Local aRelac		:= {}
Local cAliasQry		:= "Exp"+getNextAlias()
Local cAliasAFA		:= ""
Local cMensagem 	:= ""
Local cQuery		:= ""
Local cCalend		:= ""
Local cCodUsr 		:= __cUserId
Local cAliasAFP		:= RetSQLName("AFP")
Local cAliTmpAFP	:= "AFP"+GetNextAlias()
Local cFilAFP		:= xFilial("AFP")
Local cFilAFA 		:= xFilial("AFA")
Local cFilAJ4		:= xFilial("AJ4")
Local cFilAFF 		:= xFilial("AFF")
Local cFilAFD 		:= xFilial("AFD")
Local cFilAE8 		:= xFilial("AE8")
Local cFilSB1 		:= xFilial("SB1")
Local cAFA_FIX 		:= CriaVar('AFA_FIX',.T.)
Local nHdl			:= 0
Local aTrbs			:= {}
Local cHistCall		:= ""
Local nPosCal		:= ""
Local nT			:= 0
Local nw			:= 0
Local nz			:= 0
Local nc			:= 0
Local nMaxItem		:= 0
Local nConAFA		:= 0
Local nPosWork		:= 0
Local nBuffer		:= 0
Local nTamAFAIte 	:= TamSx3("AFA_ITEM")[1]
Local nTamAFDIte 	:= TamSx3("AFD_ITEM")[1]
Local nTamRec 		:= TAMSX3("AE8_RECURS")[1]
Local bContAFF		:= .T.

Local lFase93 		:= PmsVldFase("AF8", AF8->AF8_PROJET, "93", .F., @cMens93)
Local lFase95 		:= PmsVldFase("AF8", AF8->AF8_PROJET, "95", .F., @cMens95)
Local lFase91 		:= PmsVldFase("AF8", AF8->AF8_PROJET, "91", .F., @cMens91)
Local lPMS010IM		:= ExistBlock("PMS010IM")

Private lThread		:= .T.

dbselectarea("AF8")
dbSetOrder(1)
dbseek(xFilial("AF8")+cProjeto+cRevisa)

nHdl := FCreate("PMSIMPORT"+cProjeto+"_"+str(nThread), 16)
If nHdl >= 0
	For nw := 1 to Len(aDadosTsk) // processa os relacionamentos da tarefa

	   	IF aDadosTsk[nw,_ALIAS] == "AF9"
		   	nT++
			dbSelectArea("AF9")
		   	dbgoto(aRecAF9[nT])
		   	nPercComp := Val(aDadosTsk[nw,_PERCENTCOMPLETE])
		   	aRelac := {}
			 // processa o Percentual Realizado dos Eventos
			If !lTopConn

				dbSelectArea("AFP")
				dbSetOrder(1)
				If MsSeek(xFilial("AFP")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
					While !Eof() .And. xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
									AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_TAREFA
						RecLock("AFP",.F.)
			        	AFP->AFP_DTCALC	:= PmsDtPrv(AF9->AF9_START,AF9->AF9_FINISH,AFP->AFP_PERC,AF9->AF9_TPMEDI)
						nBuffer++
						AFP->( dbSkip() )
					EndDo
				EndIf

			Else

				cQuery := " SELECT R_E_C_N_O_ RECNO_ FROM "+cAliasAFP
				cQuery += " WHERE AFP_FILIAL = '"+cFilAFP+"' "
				cQuery += " AND AFP_PROJET = '"+AF9->AF9_PROJET+"' "
				cQuery += " AND AFP_REVISA = '"+AF9->AF9_REVISA+"' "
				cQuery += " AND AFP_TAREFA = '"+AF9->AF9_TAREFA+"' "
				cQuery += " AND D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliTmpAFP , .T. , .T. )
				While (cAliTmpAFP)->(!Eof())
					AFP->(DbGoTo((cAliTmpAFP)->RECNO_))

					RecLock("AFP",.F.)
			        	AFP->AFP_DTCALC	:= PmsDtPrv(AF9->AF9_START,AF9->AF9_FINISH, AFP->AFP_PERC ,AF9->AF9_TPMEDI)
					nBuffer++
					(cAliTmpAFP)->(dbSkip())
				EndDo

				(cAliTmpAFP)->(dbCloseArea())

			Endif

			// processa o Percentual Realizado da Tarefa
			If lPOC .and. (nPercComp>0)
				dbSelectArea("AFF")
				dbSetOrder(1)
				If PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataBase,AF9->AF9_QUANT) <> nPercComp

					bContAFF := .T.

					If MsSeek(cFilAFF+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+DTOS(dDataBase))
						If nPercComp <> 0
							// alteracao de confirmacao
							If !lFase93
								bContAFF := .F.
								If PMSShowWar() <> 1
									PMSLogInt("AF9" , .F. ,'',,STR0020+" "+cMensagem)
								Endif
							EndIf
						Else

							// exclusao de confirmacao
							If !lFase95
								bContAFF := .F.
								If PMSShowWar() <> 1
									PMSLogInt("AF9" , .F. ,'',,STR0021+""+cMensagem)
								EndIf
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
							If PMSShowWar() <> 1
								PMSLogInt("AF9" , .F. ,'',,STR0022+ " "+cMensagem)
							EndIf
						EndIf

						If bContAFF
							RecLock("AFF",.T.)
						EndIf
					EndIf

					If bContAFF
						AFF->AFF_FILIAL := cFilAFF
						AFF->AFF_PROJET	:= AF9->AF9_PROJET
						AFF->AFF_REVISA	:= AF9->AF9_REVISA
						AFF->AFF_TAREFA	:= AF9->AF9_TAREFA
						AFF->AFF_QUANT	:= AF9->AF9_QUANT*nPercComp/100
						AFF->AFF_USER	:= cCodUsr
						AFF->AFF_DATA	:= dDataBase

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
			If lTopConn

				cAliasAFA := RetSQLName("AFA")
				cAliasQry := GetNextAlias()

				cQuery := " SELECT AFA_ITEM, R_E_C_N_O_ RECNO_ FROM "+cAliasAFA
				cQuery += " WHERE AFA_FILIAL = '"+cFilAFA+"' "
				cQuery += " AND AFA_PROJET = '"+AF9->AF9_PROJET+"' "
				cQuery += " AND AFA_REVISA = '"+AF9->AF9_REVISA+"' "
				cQuery += " AND AFA_TAREFA = '"+AF9->AF9_TAREFA+"' "
				cQuery += " AND AFA_RECURS <> '' "
				cQuery += " AND D_E_L_E_T_ = ' ' "
				cQuery += " ORDER BY AFA_ITEM "

				dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry , .T. , .T. )
				While (cAliasQry)->(!Eof())
					aAdd(aRecAFA, (cAliasQry)->(RECNO_) )
					nMaxItem := VAL((cAliasQry)->(AFA_ITEM))
					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())

			Else

				dbSelectArea("AFA")
				dbSetOrder(1)

				MsSeek(cFilAFA+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
				While !Eof() .And. cFilAFA+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
									AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA
					If !Empty(AFA->AFA_RECURS)
						aAdd(aRecAFA,AFA->(RecNo()))
					EndIf
					AFA->(dbSkip())
				EndDo

			Endif
			For nz := 1 to Len(aRelac)
				AE8->(dbSetOrder(1))

				If AE8->(MsSeek(cFilAE8+Substr(aRelac[nz,1],1,nTamRec)))
					SB1->(dbSetOrder(1))
					SB1->(MsSeek(cFilSB1+AE8->AE8_PRODUT))
					If nz <= Len(aRecAFA)
						AFA->(dbGoto(aRecAFA[nz]))
					Endif
					If !Len(aRecAFA)==0 .and. AllTrim(Substr(aRelac[nz,1],1,nTamRec))==AllTrim(AFA->AFA_RECURS)

						RecLock("AFA",.F.)
						If lPMS010IM
							AFA->AFA_ALOC := ExecBlock("PMS010IM", .F., .F., {aRelac[nz,2]})
						Else
							If AFA->AFA_FIX == "1"
								AFA->AFA_ALOC := aRelac[nz,2]
							Else
								nPosWork := aScan(aResources, {|x| Upper(AllTrim(x[1])) == Upper(Alltrim(AE8->AE8_RECURS)) })
								If nPosWork > 0
									AFA->AFA_QUANT := aResources[nPosWork][2]
								Else

									cCalend := If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,AF9->AF9_CALEND)
									If !(cCalend $ cHistCall)

										aadd(aTrbs, PmsItvTRB(cCalend) )
										nPosCal	:= Len(aTrbs)
										cHistCall +=cCalend+"|"
									Else

										nPosCal := aScan(aTrbs, {|x| x[1]==cCalend } )
									Endif

									AFA->AFA_QUANT := (AFA->AFA_ALOC*PmsHrsItvl(AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,cCalend,AF9->AF9_PROJET,AE8->AE8_RECURS,aTrbs[nPosCal]))/100
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
							PmsAvalAFA("AFA",3)

							RecLock("AFA",.F.)
							AFA->AFA_FILIAL	:= cFilAFA
							nConAFA++
						Else
							RecLock("AFA",.T.)
							AFA->AFA_FILIAL	:= cFilAFA
							nConAFA++
							AFA->AFA_ITEM	:= StrZero(nMaxItem+nConAFA, nTamAFAIte)
						EndIf

						AFA->AFA_PROJET	:= AF9->AF9_PROJET
						AFA->AFA_REVISA	:= AF9->AF9_REVISA
						AFA->AFA_TAREFA	:= AF9->AF9_TAREFA
						AFA->AFA_RECURS	:= Substr(aRelac[nz,1],1,nTamRec)
						AFA->AFA_FIX    := cAFA_FIX

						If lPMS010IM
							AFA->AFA_ALOC := ExecBlock("PMS010IM", .F., .F., {aRelac[nz,2]})
						Else
							cCalend := If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,AF9->AF9_CALEND)
							If !(cCalend $ cHistCall)

								aadd(aTrbs, PmsItvTRB(cCalend) )
								nPosCal	:= Len(aTrbs)
								cHistCall +=cCalend+"|"
							Else

								nPosCal := aScan(aTrbs, {|x| x[1]==cCalend } )
							Endif

							AFA->AFA_ALOC	:= aRelac[nz,2]
							AFA->AFA_QUANT 	:= (AFA->AFA_ALOC*PmsHrsItvl(AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,cCalend,AF9->AF9_PROJET,AE8->AE8_RECURS,aTrbs[nPosCal]))/100
						EndIf

						AFA->AFA_DATPRF	:= AF9->AF9_START
						AFA->AFA_START	:= AF9->AF9_START
						AFA->AFA_HORAI	:= AF9->AF9_HORAI
						AFA->AFA_FINISH	:= AF9->AF9_FINISH
						AFA->AFA_HORAF	:= AF9->AF9_HORAF

						If !Empty(AE8->AE8_PRODUT)
							AFA->AFA_PRODUT	:= AE8->AE8_PRODUT
							AFA->AFA_CUSTD	:= SB1->B1_CUSTD
							AFA->AFA_MOEDA	:= VAL(SB1->B1_MCUSTD)
						EndIf
						nBuffer++
						PmsAvalAFA("AFA",1)

					EndIf
				EndIf
			Next
			nConAFA:=0
			If Len(aRecAFA)>Len(aRelac)
				For nz := Len(aRelac)+1 to Len(aRecAFA)
					AFA->(dbGoto(aRecAFA[nz]))

					PmsAvalAFA("AFA",2)
					PmsAvalAFA("AFA",3)

					RecLock("AFA",.F.,.T.)
					dbDelete()
					Msunlock()
				Next
			EndIf
			aRelac := {}
			aAuxArea	:= AF9->(GetArea())
			If !empty(aDadosTsk[nw,_PREDECESSORS])
				aRelac := PmsReadRela(nVersao,aDadosTsk[nw,_PREDECESSORS],aAllTaks, _ORDEM,_TEXT1)
			Endif
			aAtuAFD	:= {}
			aRecAFD	:= {}
			dbSelectArea("AFD")
			dbSetOrder(1)
			MsSeek(cFilAFD+AF9->AF9_PROJET+AF9->AF9_REVISA+aDadosTsk[nw,_TEXT1])
			While !Eof() .And. cFilAFD+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
								AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA
				aAdd(aRecAFD,AFD->(RecNo()))
				AFD->(dbSkip())
			EndDo

			// RELACIONAMENTOS EDT -> TAREFA
			aAtuAJ4	:= {}
			aRecAJ4	:= {}
			dbSelectArea("AJ4")
			dbSetOrder(1)
			MsSeek(cFilAJ4+AF9->AF9_PROJET+AF9->AF9_REVISA+aDadosTsk[nw,_TEXT1])
			While AJ4->(!Eof()) .And. cFilAJ4+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
							AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA
				aAdd(aRecAJ4,AJ4->(RecNo()))
				AJ4->(dbSkip())
			EndDo

			AF9->(dbSetOrder(1))
			AFC->(dbSetOrder(1))

			For nz := 1 to Len(aRelac)
				If AF9->(MsSeek(cFilAF9+AF8->AF8_PROJET+AF8->AF8_REVISA+aDadosTsk[nw,_TEXT1]))
					RestArea(aAuxArea)
					If nz > Len(aRecAFD)
						RecLock("AFD",.T.)
						AFD->AFD_FILIAL	:= cFilAFD
						AFD->AFD_PROJET	:= AF9->AF9_PROJET
						AFD->AFD_REVISA	:= AF9->AF9_REVISA
						AFD->AFD_TAREFA	:= AF9->AF9_TAREFA
						AFD->AFD_ITEM	:= STRZERO(nz,nTamAFDIte)
						AFD->AFD_PREDEC	:= aRelac[nz][1]
						AFD->AFD_TIPO	:= aRelac[nz][2]
						AFD->AFD_HRETAR	:= aRelac[nz][3]
					Else

						AFD->(dbGoto(aRecAFD[nz]))
						RecLock("AFD",.F.)
						AFD->AFD_FILIAL	:= cFilAFD
						AFD->AFD_PROJET	:= AF9->AF9_PROJET
						AFD->AFD_REVISA	:= AF9->AF9_REVISA
						AFD->AFD_TAREFA	:= AF9->AF9_TAREFA
						AFD->AFD_PREDEC	:= aRelac[nz][1]
						AFD->AFD_TIPO	:= aRelac[nz][2]
						AFD->AFD_HRETAR	:= aRelac[nz][3]
					EndIf

					aAdd(aAtuAFD, AFD->(recno()))

					nBuffer++
				ELSE
					If AFC->(MsSeek(cFilAFC+AF8->AF8_PROJET+AF8->AF8_REVISA+aDadosTsk[nw][_TEXT1]))
						RestArea(aAuxArea)
						If nz > Len(aRecAJ4)
							RecLock("AJ4",.T.)
							AJ4->AJ4_FILIAL	:= cFilAJ4
							AJ4->AJ4_PROJET	:= AF9->AF9_PROJET
							AJ4->AJ4_REVISA	:= AF9->AF9_REVISA
							AJ4->AJ4_TAREFA	:= AF9->AF9_TAREFA
							AJ4->AJ4_ITEM	:= STRZERO(nz,nTamAJ4Ite)
							AJ4->AJ4_PREDEC	:= aRelac[nz][1]
							AJ4->AJ4_TIPO	:= aRelac[nz][2]
							AJ4->AJ4_HRETAR	:= aRelac[nz][3]
						Else
							AJ4->(dbGoto(aRecAJ4[nz]))
							RecLock("AJ4",.F.)
							AJ4->AJ4_FILIAL	:= cFilAJ4
							AJ4->AJ4_PROJET	:= AF9->AF9_PROJET
							AJ4->AJ4_REVISA	:= AF9->AF9_REVISA
							AJ4->AJ4_TAREFA	:= AF9->AF9_TAREFA
							AJ4->AJ4_PREDEC	:= aRelac[nz][1]
							AJ4->AJ4_TIPO	:= aRelac[nz][2]
							AJ4->AJ4_HRETAR	:= aRelac[nz][3]
						EndIf

						aAdd(aAtuAJ4, AJ4->(recno()))

						nBuffer++
				   Endif
				EndIf
			Next
			If Len(aRecAFD)> 0
				For nz := 1 to Len(aRecAFD) // relacionamentos do PMS
					nC := aScan(aAtuAFD,{|x|x ==aRecAFD[nz] }) // relacionamentos do project incluido/alterado no pms
					If nC == 0
						AFD->(dbGoto(aRecAFD[nz]))
						RecLock("AFD",.F.,.T.)
						dbDelete()
						Msunlock()
						nBuffer++
					EndIF
				Next
			EndIf
			If Len(aRecAJ4)> 0
				For nz := 1 to Len(aRecAJ4) // relacionamentos do PMS
					nC := aScan(aAtuAJ4,{|x|x ==aRecAJ4[nz] }) // relacionamentos do project incluido/alterado no pms
					If nC == 0
						AJ4->(dbGoto(aRecAJ4[nz]))
						RecLock("AJ4",.F.,.T.)
						dbDelete()
						Msunlock()
						nBuffer++
					EndIF
				Next
			EndIf
			If nBuffer > 1000
				AFP->(MsUnlockAll())
				AFF->(MsUnlockAll())
				AFA->(MsUnlockAll())
				AFD->(MsUnlockAll())
				AJ4->(MsUnlockAll())
				nBuffer:= 0
			Endif
			RestArea(aAuxArea)
		endif
	Next nW

	FClose(nHdl)

Endif

If nBuffer > 0
	AFP->(MsUnlockAll())
	AFF->(MsUnlockAll())
	AFA->(MsUnlockAll())
	AFD->(MsUnlockAll())
	AJ4->(MsUnlockAll())
Endif

PmsItvTRB("",aTrbs)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PmsCalcDts

(desconhecido)

@author Clovis Magenta
@since 20/03/13
@version P10 R4

@param cParm,,
@param aParam,,

@return nulo

/*/
//-------------------------------------------------------------------
Function PmsCalcDts(cParam, aParam)

Local MV_PMSTX30	:= aParam[1]
Local aRecAF9		:= aParam[2]
Local aNewRec		:= aParam[3]
Local nThread		:= aParam[4]
Local cProjeto		:= aParam[5]
Local nPosCal		:= 0
Local aTrbs			:= {}
Local cHistCall		:= ""
Local cCalend		:= ""
Local nDuracao		:= 0
Local nX			:= 0
Local dStart
Local dFinish
Local cExcTrfPms:= SuperGetMv("MV_PMSTEXC",,"S")

PmsAvalCal()

nHdl := FCreate("PMSATUDTS_"+cProjeto+"_"+Alltrim(str(nThread)), 16)

If nHdl >= 0

	For nX := 1 to Len(aNewRec)
		dbSelectArea("AF9")
		dbGoTo(aNewRec[nx])
		If aScan(aRecAF9, aNewRec[nx] ) > 0

			If AF9->AF9_START==AF9->AF9_FINISH

				nDuracao := PmsHrUtil(AF9->AF9_START,"00"+AF9->AF9_HORAI,"00"+AF9->AF9_HORAF,AF9->AF9_CALEND,,AF9->AF9_PROJET,,,,,,, .T. )

			Else
				If !(AF9->AF9_CALEND $ cHistCall)
					aadd(aTrbs, PmsUtsTRB(AF9->AF9_CALEND) )
					nPosCal	:= Len(aTrbs)
					cHistCall +=cCalend+"|"
				Else
					nPosCal := aScan(aTrbs, {|x| x[1]==AF9->AF9_CALEND } )
				Endif
				nDuracao:= 0
				dStart	:= AF9->AF9_START
				dFinish	:= AF9->AF9_FINISH
				If dStart != dFinish
					nDuracao:= PmsHrUtil(dStart,"00"+AF9->AF9_HORAI,"0024:00",AF9->AF9_CALEND,,AF9->AF9_PROJET,,,,,,,.T. ,,aTrbs[nPosCal])
				Else
					nDuracao:= PmsHrUtil(dStart,"00"+AF9->AF9_HORAI,"00"+AF9->AF9_HORAF,AF9->AF9_CALEND,,AF9->AF9_PROJET,,,,,,,.T. ,,aTrbs[nPosCal])
				Endif
				dStart++
				While dStart <= dFinish
					If dStart==dFinish
						nDuracao += PmsHrUtil(dStart,"0000:00","00"+AF9->AF9_HORAF,AF9->AF9_CALEND,,AF9->AF9_PROJET,,,,,,,.F.,.T.,aTrbs[nPosCal])
					Else
						nDuracao += PmsHrUtil(dStart,"0000:00","0024:00",AF9->AF9_CALEND,,AF9->AF9_PROJET,,,,,,,,,,aTrbs[nPosCal])
					EndIf
					dStart++
				EndDo
			EndIf
			RecLock("AF9")
			AF9->AF9_HDURAC := nDuracao
			AF9->AF9_HUTEIS := nDuracao
			MsUnlock()

		Elseif !MV_PMSTX30

			If (cExcTrfPms == "N" .And. GeralApp( AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA ) )
				PMSLogInt("AF9" , .F. ,,,STR0035)
			Else
				PMSLogInt("AF9" , .F. ,'D')
				MaDelAF9(,,,AF9->(RecNo()))
			EndIf

		EndIf
		dbSelectArea("AF9")
		dbSetOrder(1)

	Next nX

	FClose(nHdl)

Endif
PmsUtsTRB("",aTrbs)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PmaCalcAtu

(desconhecido)

@author Clovis Magenta
@since 20/03/13
@version P10 R4

@param cParm,,
@param aParam,,

@return nulo

/*/
//-------------------------------------------------------------------
Function PmaCalcAtu(cParam, aParam)
Local cFilAFC	:= aParam[1]
Local cProjeto	:= aParam[2]
Local cRevisa	:= aParam[3]
Local aEDTs		:= aParam[4]
Local nThread	:= aParam[5]
Local nHdl		:= 0
Local nX		:= 0
Local nPosCal	:= 0
Local aTrbs		:= {}
Local cHistCall	:= ""
Local cCalend	:= ""

PmsAvalCal()

nHdl := FCreate("PMSCALDTS_"+cProjeto+"_"+str(nThread), 16)
If nHdl >= 0
	For nX:=1 to Len(aEDTs)

		cCalend := aEDTs[nX][2]
		If !(cCalend $ cHistCall)
			aadd(aTrbs, PmsItvTRB(cCalend) )
			nPosCal	:= Len(aTrbs)
			cHistCall +=cCalend+"|"
		Else
			nPosCal := aScan(aTrbs, {|x| x[1]==cCalend } )
		Endif

		PmsAtuEDT(cProjeto,cRevisa,aEDTs[nX][1],,,,.T.,,aTrbs[nPosCal],.T.)
		PmsAtuRlz(cProjeto,cRevisa,aEDTs[nX][1], dDataBase ,,.T. )
	Next nX

	FClose(nHdl)
Endif

PmsItvTRB( "" , aTrbs )

Return
