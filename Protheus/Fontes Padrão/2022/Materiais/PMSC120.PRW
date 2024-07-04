#INCLUDE "pmsc120.ch"
#include "protheus.ch"
#include "pmsicons.ch"

Static _nSM0Empresa := 1
Static _nSM0Filial  := 2

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ PMSC120  ณ Autor ณ Totvs                 ณ Data ณ 28-05-2010 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Programa de consulta as Tarefas em andamento da Equipe.      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPMS                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSC120( aConfig, dIniGnt, aGantt, nTsk, cRecurso, aDep, aTskAppont, aCfgGantt, aRecAE8 )
Local nTop      := oMainWnd:nTop+35
Local nLeft     := oMainWnd:nLeft+10
Local nBottom   := oMainWnd:nBottom-12
Local nRight    := oMainWnd:nRight-10

Local oFont
Local oBar 
Local oPanel
Local lRet		:= .F.
Local lContinua	:= .T.
Local aButtons	:= {}
Local oGantt
Local bOldRfGnt

Local aGanttOld	:= aClone( aGantt )
Local aConfigOld:= aClone( aConfig )
Local dIniGntOld:= dIniGnt

Private bRfshGantt
Private bRfshGant1
Private oDlg
Private cMsg		:= If(!Empty(aTskAppont[3]),STR0002+Alltrim(aTskAppont[3])+"/"+AllTrim(aTskAppont[5])+"-"+Alltrim(aTskAppont[6])+STR0003+DTOC(STOD(aTskAppont[7]))+" "+aTskAppont[8],Padr(STR0004,120)) //"Em Execu็ใo : "###" Inicio : "###"Recurso Ocioso"

nRecno := Val(AllTrim(aTskAppont[2]))

If aConfig == Nil
	aConfig		:= {6,.F.,.T.,.T.,.T.,dDataBase-320,dDataBase+25,3,""}
	lContinua	:= PmsCfgRec(@oDlg,@aConfig,@dIniGnt,@aGantt)
EndIf

If lContinua
	RegToMemory("AFA",.T.) // preventiva para nใo gerar error.log, por causa da AFA_SIMBMO
	RegToMemory("AFB",.T.) // preventiva para nใo gerar error.log, por causa da AFB_SIMBMO
	aGantt	:= {}
	
	//
	// carrega as tarefas referente ao recurso informado
	//
	LoadArray(aGantt,cRecurso,aConfig,aDep,aTskAppont,aRecAE8)
	
	If Empty(aGantt)
		Aviso(STR0005,STR0006,{STR0007},2) //"Atencao!"###"Nao existem projetos alocados para este recurso na data selecionada. Verifique o recurso e o periodo selecionado."###"Fechar"
	Else
		// 
		// permite customizar o menu de contexto da tarefa, adicionando novos itens de menu
		//
		MENU oMnuGannt POPUP
			MENUITEM STR0008 ACTION (GttActive(oGantt,.F.),AF9->(dbGoto(nRecNo)),PMSA203(2,,"000"),GttActive(oGantt)) //"&Visualizar Tarefa"
			MENUITEM STR0009 ACTION (GttActive(oGantt,.F.),AF9->(dbGoto(nRecNo)),PmMonSwTsk()     ,GttActive(oGantt)) //"&Informacoes da Tarefa"
		ENDMENU

		//
		// adiciona botใo de filtro na barra de bot๕es da dialog
		//
		aAdd(aButtons ,{BMP_OPCOES,{||(GttActive(oGantt,.F.),If(PmsCfgRec(@oDlg,aConfig,@dIniGnt,aGantt),(Eval(bRfshGantt)),Nil),GttActive(oGantt))},STR0010 }) //"Op็๕es"

		DEFINE FONT oFont NAME "Arial" SIZE 0, -10
		DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD
		DEFINE MSDIALOG oDlg TITLE STR0001 OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight  //"Tarefas em Andamento pela Equipe"
			oDlg:lMaximized := .T.	
			@ 1000,38 BUTTON "OK" SIZE 35,12 ACTION {|| Nil} OF oDlg PIXEL
	
			PmsGantt(aGantt,aCfgGantt,@dIniGnt,,oDlg,{14,1,(nBottom/2)-40,(nRight/2)-4},{{STR0011,95},{STR0012,30},{STR0013,105}},@nTsk,aDep,,@oGantt,,{1,2,3}) //"Projeto/Tarefa"###"Codigo"###"Nome"
	
			bOldRfGnt  := bRfshGantt 
			bRfshGant1 := {|| LoadArray(aGantt,cRecurso,aConfig,aDep,aTskAppont),Eval(bOldRfGnt)} 
			bRfshGantt := {|| LoadArray(@aGantt,cRecurso,@aConfig,@aDep,aTskAppont),Eval(bOldRfGnt)}
		
		FATPDLogUser("PMSC120")
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aButtons)
	EndIf
EndIf		

PMSFREEOBJ(oBar)
PMSFREEOBJ(oGantt)

// Restaura estado original do monitor de tarefas
aGantt 	:= aClone( aGanttOld )
aConfig	:= aClone( aConfigOld )
dIniGnt	:= dIniGntOld

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadArray บAutor  ณMicrosiga           บ Data ณ  09/21/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para carregar o grafico gantt                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadArray(aGantt,cRecurso,aConfig,aDep,aTskAppont,aRecAE8)
Local nInc		:= 1
Local aRecurso	:= {}
Local aRecTrf	:= {}
Local nCFil     := 0
Local aSM0      := {}
Local cBkpEmp   := cEmpAnt
Local cBkpFil   := cFilAnt
Local aArea := GetArea()
Private aMarkAE8 := {}



If FUNNAME() == "PMSC110"
	aMarkAE8 := aClone(aRecAE8)
	If !Pergunte("PMSC110",.T.)
		Return .F.
	Else
		cRecurso := alltrim(MV_PAR01)
	EndIf
Else
	If !Pergunte("PMSC120",.T.)
		Return .F.
	EndIf
Endif

aSM0 := AdmAbreSM0()
/*For nCFil := 1 to Len(aSM0)
	RpcSetType(3)
	RpcSetEnv(aSM0[nCFil][_nSM0Empresa],aSM0[nCFil][_nSM0Filial])
	RpcClearEnv()
	OpenSm0Excl()
Next nCFil */


// Verifica os recursos no nivel abaixo da hierarquia de quem consulta.
aRecurso	:= PAConsEquipe( cRecurso )

///****************///******************///*******************
// Insercao de Ponto de entrada para permitir a alteracao dos recursos que serao exibidos na consulta
If ExistBlock("PMC120USR")
   aRecurso := ExecBlock("PMC120USR",.F.,.F.,{aRecurso})
EndIf

// Determina inicialmente todos os recursos estao ociosos, atribuindo zero como RecNo
aRecTrf		:= Array( Len( aRecurso ) )
aFill( aRecTrf, 0 )

///****************///******************///*******************
// Insercao de laco FOR para permitir a alteracao dos recursos que serao exibidos na consulta

For nCFil := 1 to Len(aSM0)
	//	RpcSetType(3)
	//	RpcSetEnv(aSM0[nCFil][_nSM0Empresa],aSM0[nCFil][_nSM0Filial])
		cEmpAnt := aSM0[nCFil][_nSM0Empresa]
		cFilAnt := aSM0[nCFil][_nSM0Filial]

	If Upper(MV_PAR01) <= cFilAnt .AND. cFilAnt <= Upper(MV_PAR02)
		///****************///******************///*******************
		
		// Localiza os recursos com tarefa em execucao
		For nInc := 1 To Len( aRecurso )
			DbSelectArea( "AFW" )
			AFW->( DbSetOrder( 1 ) )
			If AFW->( DbSeek( xFilial( "AFW" ) + aRecurso[nInc] ) )
				DbSelectArea( "AF8" )
				AF8->( DbSetOrder( 1 ) )
				If AF8->( DbSeek( xFilial( "AF8" ) + AFW->AFW_PROJET ) )
					DbSelectArea( "AF9" )
					AF9->( DbSetOrder( 1 ) )
					If AF9->( DbSeek( xFilial( "AF9" ) + AFW->AFW_PROJET + AF8->AF8_REVISA + AFW->AFW_TAREFA ) )
						aRecTrf[nInc] := AF9->( RecNo() )	// Executando...
					EndIf
				EndIf
			EndIf
		Next
		
		///****************///******************///*******************
		// Insercao de laco FOR para permitir a alteracao dos recursos que serao exibidos na consulta
		//	RpcClearEnv()
		//	OpenSm0Excl()
	EndIf
Next nCFil

cEmpAnt := cBkpEmp   
cFilAnt := cBkpFil

///****************///******************///*******************
RestArea(aArea)

Return Processa( { ||AuxLoadArray( aGantt, aRecurso, aConfig, aDep, aTskAppont, aRecTrf ) }, STR0014 ) //"Carregando Tarefas do Recurso."

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAuxLoadArrayบAutorณMicrosiga           บ Data ณ  09/21/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar para carregar o grafico                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AuxLoadArray(aGantt,aRecurso,aConfig,aDep,aTskAppont,aRecTrf)
Local aArea := GetArea()
Local aAreaAE8 := AE8->(GetArea())
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAFA := AFA->(GetArea())
Local aAreaAFD := AFD->(GetArea())
Local aRGB := {}
Local aCorBarras := LoadCorBarra( "MV_PMSACOR" )
Local aAloc	:= {}
Local aRecAF9	:= {}
Local aLoadCache := {}
Local nx
Local oFnt                                       
Local lContinua:=	.T.        
Local lPMSUserMnt := ExistBlock("PMSUserMnt")
Local cRecurso	:= ""
Local nInc		:= 0

DEFINE FONT oFnt NAME "Arial" SIZE 0, -11 BOLD

aGantt  := {}
aDep	:= {}

For nInc := 1 To Len( aRecurso )
	cRecurso	:= aRecurso[nInc]
	aRecAF9		:= {}
	aLoadCache 	:= {}
	
	dbSelectArea("AE8")
	dbSetOrder(1)
	If dbSeek(xFilial("AE8")+cRecurso)
	
		ProcRegua(1)
		IncProc( STR0015 ) //"Selecionando as tarefas. Aguarde..."
		aLoadCache 	:= aClone(aRecTrf)
		aAloc		:= PmsRetAloc(AE8->AE8_RECURS,aConfig[7],"00:00",aConfig[8],"24:00",aConfig[9],,,,aRecAF9,,@aLoadCache,aConfig[10])
		aRecTrf 	:= aClone(aLoadCache)
		aRecAF9		:= aClone(aRecTrf)
		
		If !Empty(aAloc)
			aAdd(aGantt,{{"",AE8->AE8_RECURS,FATPDObfuscate(AE8->AE8_DESCRI,"AE8_DESCRI",,.T.)},{},CLR_HBLUE,oFnt}) 
			For nx := 1 to Len(aAloc)-1  
				If aAloc[nx][3] > 0
					dIni	:= aAloc[nx][1]
					cHIni	:= aAloc[nx][2]
					dFim	:= aAloc[nx+1][1]
					cHFim	:= aAloc[nx+1][2]
					cView	:= "PmsDispBox({	{'"+STR0016+"','"+AE8->AE8_RECURS+"'},"+; //"Recurso "
											"	{'"+STR0017+"','"+FATPDObfuscate(AE8->AE8_DESCRI,"AE8_DESCRI",,.T.)+"'},"+; //"Descricao"
											"	{'"+STR0018+"','"+Transform(AE8->AE8_UMAX,"@E 9999.99%")+"'},"+; //"% Aloc.Max."
											"	{'"+STR0019+"','"+If(AE8->AE8_SUPALO=="1",STR0023,STR0024)+"'},"+; //"Perm.Sup.Alo."###"Sim"###"Nใo"
											"	{'"+STR0020+"','"+DTOC(dIni)+"-"+cHIni+"'},"+; // //"Data Inicial"
											"	{'"+STR0021+"','"+DTOC(dFim)+"-"+cHFim+"'},"+; //"Data Final"
											"	{'"+STR0022+"','"+Transform(aAloc[nx][3],"@E 9999.99%")+"'}},2,'"+STR0025+"',{40,120},,1)" //"% Aloc.Periodo"###"Detalhes"
					aRGB := ValorCorBarra( "2" ,aCorBarras ,2 )
					aAdd(aGantt[Len(aGantt)][2],{dIni,cHIni,dFim,cHFim,IIf(nx==1,FATPDObfuscate(AE8->AE8_DESCRI,"AE8_DESCRI",,.T.),""),If(aAloc[nx][3]>AE8->AE8_UMAX ,ValorCorBarra( "1" ,aCorBarras ) ;
											 		,RGB( (255-Int((aAloc[nx][3]/AE8->AE8_UMAX*100)*((255-aRGB[1])/100))) ,(255-Int((aAloc[nx][3]/AE8->AE8_UMAX*100)*((255-aRGB[2])/100))) ,(255-Int((aAloc[nx][3]/AE8->AE8_UMAX*100)*((255-aRGB[3])/100))) ) ;
																),cView,2,CLR_BLACK})
				EndIf
			Next nX
		Else
			aAdd( aGantt, { { "", AE8->AE8_RECURS, FATPDObfuscate(AE8->AE8_DESCRI,"AE8_DESCRI",,.T.) }, {}, CLR_HBLUE, oFnt } )
			dIni	:= dDatabase
			cHIni	:= "00:00"
			dFim	:= dDatabase+1  
			cHFim	:= "24:00"
		EndIf

		// Apresenta como recurso ocioso
		If aRecTrf[nInc] == 0
			aAdd( aGantt,{ { "RECURSO OCIOSO", "", "" }, { { dIni, cHIni, dFim, cHFim, "RECURSO OCIOSO",, "", 1, CLR_BLACK } }, CLR_HRED, oFnt } )
		EndIf  

		ProcRegua(Len(aRecAF9))
		If aConfig[6]
			dbSelectArea("AFA")
			dbSetOrder(5)
			For nx := 1 to Len(aRecAF9)
				lContinua := .T.
				IncProc( STR0026 ) //"Carregando as tarefas..."
				dbSelectArea("AF9")
				dbGoto(aRecAF9[nx])

			 	nColor	:= RGB( (255-Int(MAx(AF9->AF9_PRIORI,100)/10*((255-ValorCorBarra( "3" ,aCorBarras,2 )[1])/100))) ,(255-Int(Max(AF9->AF9_PRIORI,100)/10*((255-ValorCorBarra( "3" ,aCorBarras,2 )[2])/100))) ,(255-Int(Max(AF9->AF9_PRIORI,100)/10*((255-ValorCorBarra( "3" ,aCorBarras,2 )[3])/100))) )
				If AFA->(MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+cRecurso ))
					Do Case
						Case !Empty(aTskAppont[2]) .And. Val(aTskAppont[2])==aRecAF9[nx]
							nColor := CLR_BLACK
							nColorBar := CLR_BLACK
						Case !Empty(AFA->AFA_RESP) .And. AFA->AFA_RESP <> "1"   // Recurso nใo ้ responsavel pela tarefa.
							nColorBar := CLR_MAGENTA
						Case !Empty(AF9->AF9_DTATUF)
							nColorBar := CLR_GRAY
						Case !Empty(AF9->AF9_DTATUI)
							nColorBar := CLR_BROWN
						Case dDataBase > AF9->AF9_START
							nColorBar := CLR_HRED
						OtherWise
							nColorBar := CLR_GREEN
					EndCase
					                    
					If lPMSUserMnt
						If ExecBlock("PMSUserMnt")
							aAdd(aGantt,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,"",""},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,AllTrim(AF9->AF9_PROJET)+":"+Alltrim(AF9->AF9_DESCRI)+"-"+AllTrim(TransForm(AFA->AFA_ALOC,"@E 99999.99%"))+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9_PROJET,AF9_REVISA,AF9_TAREFA,CTOD("01/12/2020")),"@E 999.99%")),,"(nRecno:="+Str(AF9->(Recno()))+",oMnuGannt:Activate(x,y,oBar))",1,nColorBar}},nColor,oFnt})
						Else
							lContinua := .F.
						Endif
					Else
						aAdd(aGantt,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,"",""},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,AllTrim(AF9->AF9_PROJET)+":"+Alltrim(AF9->AF9_DESCRI)+"-"+AllTrim(TransForm(AFA->AFA_ALOC,"@E 99999.99%"))+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9_PROJET,AF9_REVISA,AF9_TAREFA,CTOD("01/12/2020")),"@E 999.99%")),,"(nRecno:="+Str(AF9->(Recno()))+",oMnuGannt:Activate(x,y,oBar))",1,nColorBar}},nColor,oFnt})
					Endif
					
					// se existe predecessora pra tarefa
					If lContinua
						dbSelectArea("AFD")
						dbSetOrder(1)
						MsSeek(xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
						While !AFD->(EOF()) .And. xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA
							nPos := aScan( aDep ,{|aTarefa| aTarefa[1] == AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_TAREFA})
							If nPos > 0
								aAdd( aDep[nPos][2],{ AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_PREDEC ,AFD->AFD_TIPO } )
							Else	                               
								aAdd( aDep ,{ AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_TAREFA ,{ {AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_PREDEC ,AFD->AFD_TIPO} }} )
							Endif		

							AFD->( dbSkip() )
						EndDo
					Endif
				Endif
			Next
		EndIf
	EndIf 
Next

RestArea(aAreaAFD)
RestArea(aAreaAFA)
RestArea(aAreaAF9)
RestArea(aAreaAE8)
RestArea(aArea)

// se existir estouro de objetos
GanttObjMax(aGantt)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGanttObjMax บAutorณMicrosiga           บ Data ณ  09/21/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para controlar a quantida de itens no grafico para  บฑฑ
ฑฑบ          ณ evitar estouro do objeto.                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GanttObjMax(aGantt)
Local lRet := .T.
Local nTskMax := int((999*0.65)/10)
Local nCnt := 0
Local aGntTmp := {}
    
	// se a quantidade de tarefas permitidas forem menor que o filtro solicitado
	If nTskMax < (Len(aGantt))
		Aviso(STR0027,STR0028,{STR0007},2) //"Excedido a quantidade de tarefas"###"Parโmetros informados ultrapassam a quantidade mแxima de tarefas permitidas, serแ apresentado somente o permitido"###"Fechar"
		For nCnt := 1 To nTskMax
			aAdd(aGntTmp ,aGantt[nCnt])
		Next nCnt
		aGntTmp := aClone(aGantt)
		lRet := .F.
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GttActive  บAutorณMicrosiga           บ Data ณ  09/21/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua o controle do objeto para habilitar e desabilitar   บฑฑ
ฑฑบ          ณ quando utilizado o menu auxiliar no grafico.               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GttActive(oObject,lActive)

DEFAULT lActive := .T.

	If lActive
		oObject:Enable()
	Else
		oObject:Disable()
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSC110   บAutor  ณMicrosiga           บ Data ณ  03/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Filtro utilizado na consulta padrao AE81 - Recursos c/     บฑฑ
ฑฑบ          ณ filtro.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSC120F3()
Local cFilter  := " "                // Variavel de retorno do filtro
Local nCount   := 0                  // Contador no For
Local aAreaAE8 := AE8->(GetArea())  // Armazena a area da tabela AE8
Local aArea    := GetArea()         // Armazena a area corrente

cFilter := "( "

dbselectarea("AE8")	

For nCount:=1 to len(aMarkAE8)

	AE8->(dbGoto(aMarkAE8[nCount])) 
 	cFilter += "AE8->AE8_RECURS == '"+AE8->AE8_RECURS+"' "

	if nCount < len(aMarkAE8)
		cFilter += " .or. "
	elseif nCount <= len(aMarkAE8)
		cFilter += " ) .and. AE8->AE8_ATIVO <> '2' "
	endif	

Next nCount

RestArea(aAreaAE8)
RestArea(aArea)

Return &cFilter

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

