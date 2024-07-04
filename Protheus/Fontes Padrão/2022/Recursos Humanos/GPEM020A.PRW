#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM1020.CH"
#INCLUDE "SHELL.CH"

Static cFilUsua := ""

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM020A ³ Autor ³ Leandro Drumond            ³ Data   ³16/05/2016³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cálculo Unificado.					                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM020A()		                   	                             ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mensal                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³   Data ³   FNC     ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Function GPEM020A()
Local aColsMark		:= {}
Local cIdCab
Local cIdGrid
Local lMarcar     	:= .F.
Local oPanelUp
Local oTela
Local oPanelDown
Local oGroup
LOcal oFont
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local bCalcula 		:= {||If (GPM020IniProc(),oDlgMark:End(),Nil) }
Local bFiltro 		:= {||GPM020IniFilt() }

Private aRotMark   	:= {}
Private cFilCalc	:= Space( GetSx3Cache("RCH_FILIAL", "X3_TAMANHO") )
Private cFilFiltr	:= cFilCalc
Private cProcesso	:= Space( GetSx3Cache("RCH_PROCES", "X3_TAMANHO") )
Private cRoteiro	:= Space( GetSx3Cache("RCH_ROTEIR", "X3_TAMANHO") )
Private cPeriodo	:= Space( GetSx3Cache("RCH_PER", "X3_TAMANHO") )
Private cNumPag		:= Space( GetSx3Cache("RCH_NUMPAG", "X3_TAMANHO") )
Private cAliasMark 	:= "TABAUX"
Private oMark
Private oDlgMark	:= Nil
Private oTmpTable
Private lGestPubl := if(ExistFunc("fUsaGFP"),fUsaGFP(),.f.)
Private cPergBen  := ""

If cPaisLoc <> "BRA"
	Help( ,, STR0005,, STR0090, 1, 0) //"Rotina não disponivel."
	return
EndIf

If !fCriaTmp()
	Help( ,, STR0005,, STR0075, 1, 0) //"Nenhum dos roteiro aptos para cálculo possuem período ativo."
EndIf

DbSelectArea(cAliasMark)
SET FILTER TO TAB_PROC  == ""

aColsMark:= fMntColsMark()


aAdvSize	:= MsAdvSize( .F.,.F.,370)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 15 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

Define MsDialog oDlgMark FROM 0, 0 To 500, 800 Title STR0076 Pixel  ////"Cálculo Unificado"

// Cria o conteiner onde serão colocados os paineis
oTela     := FWFormContainer():New( oDlgMark )
cIdCab	  := oTela:CreateHorizontalBox( 13 )
cIdGrid   := oTela:CreateHorizontalBox( 80 )

oTela:Activate( oDlgMark, .F. )

//Cria os paineis onde serao colocados os browses
oPanelUp  	:= oTela:GeTPanel( cIdCab )
oPanelDown  := oTela:GeTPanel( cIdGrid )

	@ 0 , aObjSize[1,2]	GROUP oGroup TO 26,aObjSize[1,4]*0.62 LABEL OemToAnsi(STR0077) OF oPanelUp PIXEL	//"Selecione os filtros para cálculo"
	oGroup:oFont:=oFont

	@ aObjSize[1,1]*0.5, aObjSize[1,2]+1 		SAY   OemToAnsi(GetSx3Cache("RCH_FILIAL", "X3_TITULO")) SIZE 038,007 OF oPanelUp PIXEL
	@ (aObjSize[1,1]*0.5)+6, aObjSize[1,2]+1 	MSGET cFilCalc SIZE 010,007	OF oPanelUp F3 'SM0' PIXEL WHEN .T. VALID Gp20FilMark()

	@ aObjSize[1,1]*0.5, aObjSize[1,2]+80 		SAY   OemToAnsi(GetSx3Cache("RCH_PROCES", "X3_TITULO")) SIZE 038,007 OF oPanelUp PIXEL
	@ (aObjSize[1,1]*0.5)+6, aObjSize[1,2]+80 	MSGET cProcesso SIZE 010,007 OF oPanelUp F3 "RCJ" PIXEL WHEN .T. VALID ( Vazio() .OR. ExistCpo("RCJ") ) .and. Gp20FilMark()

	@ aObjSize[1,1]*0.5	, aObjSize[1,2]+160 	SAY   OemToAnsi(GetSx3Cache("RCH_ROTEIR", "X3_TITULO")) SIZE 038,007 OF oPanelUp PIXEL
	@ (aObjSize[1,1]*0.5)+6, aObjSize[1,2]+160	MSGET cRoteiro PICTURE "@!" SIZE 010,007	OF oPanelUp F3 "SRY" PIXEL WHEN .T. VALID Gp20FilMark()

	@ aObjSize[1,1]*0.5	, aObjSize[1,2]+240		SAY   OemToAnsi(GetSx3Cache("RCH_PER", "X3_TITULO")) SIZE 038,007 OF oPanelUp PIXEL
	@ (aObjSize[1,1]*0.5)+6, aObjSize[1,2]+240	MSGET cPeriodo SIZE 010,007	OF oPanelUp PIXEL WHEN .T. VALID Gp20FilMark()

	@ aObjSize[1,1]*0.5	, aObjSize[1,2]+320		SAY   OemToAnsi(GetSx3Cache("RCH_NUMPAG", "X3_TITULO")) SIZE 038,007 OF oPanelUp PIXEL
	@ (aObjSize[1,1]*0.5)+6, aObjSize[1,2]+320	MSGET cNumPag SIZE 010,007	OF oPanelUp PIXEL  WHEN .T.	VALID Gp20FilMark()

	oMark := FWMarkBrowse():New()

	oMark:SetAlias(cAliasMark)
	oMark:SetFields(aColsMark)

	//Indica o container onde sera criado o browse
	oMark:SetOwner(oPanelDown)

	oMark:AddButton(STR0003, bCalcula,,,, .F., 2 ) //'Calcular'
	oMark:AddButton(STR0078, bFiltro,,,, .F., 2 ) //'Filtrar Cálculo'

	oMark:bAllMark := { || SetMarkAll(oMark:Mark(),lMarcar := !lMarcar ), oMark:Refresh(.T.)  }

	// Define o campo que sera utilizado para a marcação
	oMark:SetFieldMark( 'TAB_OK')

	oMark:Activate()

ACTIVATE MSDIALOG oDlgMark CENTERED

If oTmpTable <> NIL
	oTmpTable:Delete()
	oTmpTable := Nil
Endif

Return Nil

/*/{Protheus.doc} GPM020IniProc
Inicia o processo de cálculo
@author Leandro Drumond
@since 16/05/2016
@version 1.0
/*/
Static Function GPM020IniProc()
Local cMarca 		:= oMark:Mark()
Local cPerAux       := ""
Local lRet			:= .T.
Local lRetPerg		:= .T.
Local lRotFer		:= .F.
Local lRot131		:= .F.
Local lRot132		:= .F.
Local lRotVTR		:= .F.
Local lRotVRF		:= .F.
Local lRotVAL		:= .F.
Local lPergBen      := .F.
Local lFilRPO   	:= SuperGetMv('MV_RPOFIL',, .F.)
Local aFilExec		:= {}

SetMnemonicos(xFilial("RCA", (cAliasMark)->TAB_FIL),NIL,.T.,"P_CCOMP13")
P_CCOMP13	:= If( Type("P_CCOMP13") == "U", 'N' , P_CCOMP13)

DbSelectArea(cAliasMark)
DbGoTop()

While !Eof()
	If oMark:IsMark(cMarca)
		aAdd(aRotMark,{TAB_PROC, TAB_ROT, TAB_PER, TAB_NPAG, TAB_TPROT, TAB_FIL})
		aAdd(aFilExec,TAB_FIL)
	EndIf

	//tela de parametros para roteiros 131, 132, Férias programadas VTR, VAL, e VRF
	If oMark:IsMark(cMarca) .and. TAB_TPROT == "5" .And. !lRot131
		If lGestPubl .AND. cModulo == "GFP"
			lRetPerg := Pergunte("GPM113MP",.T., STR0099)
		Else
			lRetPerg := Pergunte("GPEM250A",.T., STR0099)
		EndIf
		lRot131  := .T.
	ElseIf oMark:IsMark(cMarca) .And. !lRot132 .And. ((TAB_TPROT == "6" )  .or. (P_CCOMP13 == 'S'.AND. TAB_TPROT == "1" .And. fTemROT132(,TAB_PROC,TAB_PER,TAB_NPAG)))
		If !(lGestPubl .AND. cModulo == "GFP")
			lRetPerg := Pergunte("GPEM270A",.T., STR0100)
		EndIf
		lRot132  := .T.
	ElseIf oMark:IsMark(cMarca) .and. TAB_TPROT == "3" .and. !lRotFer
		lRetPerg := Pergunte("GPM062A",.T., STR0101)
		If mv_par02 == 2 .and. Empty(mv_par03)
			lRetPerg := .F.
			Help( ,, STR0005,, STR0094, 1, 0) //"A Data de Pagamento deve ser informada."
		ElseIf Empty(mv_par04) .or. Empty(mv_par05)
			lRetPerg := .F.
			Help( ,, STR0005,, STR0095, 1, 0) //"As datas de filtro da programação de férias devem ser informadas."
		EndIf
		lRotFer	 := .T.
	ElseIf oMark:IsMark(cMarca) .And. TAB_TPROT == "8" .And. !lRotVTR
		lRetPerg := Pergunte("GP021VTR", .T., STR0102)
		lRotVTR := .T.
		If !lPergBen .and. MV_PAR01 == 3
			cPerAux := SetPeriodCalc( TAB_PER )
			cPergBen := "GP020CPL"
			Pergunte(cPergBen, .T. )
			SetPeriodCalc( cPerAux )
			lPergBen := .T.
		EndIf
	ElseIf oMark:IsMark(cMarca) .And. TAB_TPROT == "D" .And. !lRotVRF
		lRetPerg := Pergunte("GP021VRF", .T., STR0103)
		lRotVRF := .T.
		If !lPergBen .and. MV_PAR06 == 1
			cPerAux := SetPeriodCalc( TAB_PER )
			cPergBen := "GP020CPL"
			Pergunte(cPergBen, .T. )
			SetPeriodCalc( cPerAux )
			lPergBen := .T.
		EndIf
	ElseIf oMark:IsMark(cMarca) .And. TAB_TPROT == "E" .And. !lRotVAL
		lRetPerg := Pergunte("GP021VAL", .T., STR0104)
		lRotVAL := .T.
		If !lPergBen .and. MV_PAR06 == 1
			cPerAux := SetPeriodCalc( TAB_PER )
			cPergBen := "GP020CPL"
			Pergunte(cPergBen, .T. )
			SetPeriodCalc( cPerAux )
			lPergBen := .T.
		EndIf
	EndIf

	DbSkip()
EndDo

If  (lRot131 .Or. lRot132)
	fAlert13()
EndIf

If Empty(aRotMark)
	Help( ,, STR0005,, STR0017, 1, 0) //"Nenhum roteiro selecionado."
	lRet := .F.
ElseIf lRetPerg
	If !lFilRPO
		GPCallCmpAll("SRY",.T.,.F.,,,aFilExec)
	EndIf
	Proc2BarGauge( { || GPM020Processa() } , STR0076 , NIL , NIL , .F. , .T. , .F. , .F. )	// "Cálculo Unificado"
EndIf

Return lRet

/*/{Protheus.doc} GPM020Processa
Processa os cálculos seleiconados
@author Leandro Drumond
@since 16/05/2016
@version 1.0
/*/
Static Function GPM020Processa()
Local aArea			:= GetArea()
Local aLogTitle		:= {}
Local aLogItens		:= {}
Local aLogThd		:= {}
Local aParams		:= {}
Local cFilBkp		:= ""
Local cFilRCJ		:= ""
Local cFilter		:= ""
Local cUID			:= "GPEM020A" + AllTrim(Str(ThreadID()))
Local cUserAux		:= __cUserId
Local cFilAux 		:= cFilAnt
Local cTimeIni		:= Time()		// Informacoes da Regua
Local lGrid			:= GetMvRH("MV_GRID",, .F.) // Se o parametro esta configurado para utilizacao do GRID
Local nTotThread	:= 0 // Se o parametro esta configurado para utilizacao do GRID
Local nPos			:= 0
Local nRotFim		:= 0
Local nThreads		:= 0
Local nTotProc		:= 0
Local nRotAux		:= 0
Local nX			:= 0
Local nPosAux		:= 0
Local nFimAux		:= 0
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T., .F.}) //[2]Ofuscamento
Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList({"RA_NOME"}), {})
Local lOfusca		:= Len(aFldRel) > 0
Local cFunExec  	:= "GetSrvVersion"

Private lAutoErrNoFile 	:= .T.
Private lAuto 			:= .T. //Utilizada para calcular férias no GPEM060

If FindFunction(cFunExec) .And. SubStr(&cFunExec.(), 1, 2) >= "17"
	nTotThread	:= GetMvRH("MV_CALCTHD",, 0)
Else
	nTotThread	:= Min(GetMvRH("MV_CALCTHD",, 0),5)
EndIf

BarGauge1Set( Len(aRotMark) )

cFilBkp := cFilAnt

DbSelectArea("SRA")
DbSetOrder(1)

nTotProc := Len(aRotMark)
PutGlbVars("lOfuscaJob", lOfusca)

If nTotProc > 1
	nThreads := Min(nTotProc,nTotThread)
	VarSetUID(cUID,.T.)
	VarSetXD(cUID,"nRotFim",0)
	VarSetAD(cUID,"aLogThd",{})
EndIf

For nPos := 1 to Len(aRotMark)
	nPosAux++
	IncPrcG1Time( STR0079 + aRotMark[nPos,6] + " / " + aRotMark[nPos,1] + " / " + aRotMark[nPos,2] + " / " + aRotMark[nPos,3] + " / " + aRotMark[nPos,4] , Len(aRotMark) , cTimeIni , .T. , 1 , 1 , .T. )

	If aRotMark[nPos,5] == "3"
		Pergunte("GPM062A",.F.)
		aParams := {aRotMark[nPos,1], mv_par01, mv_par02, mv_par03, mv_par04, mv_par05, mv_par06, mv_par07 }
		SetMVValue("GPM062","MV_PAR01",aRotMark[nPos,1])
		SetMVValue("GPM062","MV_PAR02",mv_par01)
		SetMVValue("GPM062","MV_PAR03",mv_par02)
		SetMVValue("GPM062","MV_PAR04",mv_par03)
		SetMVValue("GPM062","MV_PAR05",mv_par04)
		SetMVValue("GPM062","MV_PAR06",mv_par05)
		SetMVValue("GPM062","MV_PAR07",mv_par06)
		SetMVValue("GPM062","MV_PAR08",mv_par07)
		Pergunte("GPM062",.F.)
	ElseIf aRotMark[nPos,5] == "5"
		Pergunte("GPEM250A",.F.)
		aParams := {mv_par01, mv_par02, mv_par03, mv_par04, mv_par05, mv_par06, mv_par07, mv_par08, mv_par09 }
		SetMVValue("GPEM250A","MV_PAR01",mv_par01)
		SetMVValue("GPEM250A","MV_PAR02",mv_par02)
		SetMVValue("GPEM250A","MV_PAR03",mv_par03)
		SetMVValue("GPEM250A","MV_PAR04",mv_par04)
		SetMVValue("GPEM250A","MV_PAR05",mv_par05)
		SetMVValue("GPEM250A","MV_PAR06",mv_par06)
		SetMVValue("GPEM250A","MV_PAR07",mv_par07)
		SetMVValue("GPEM250A","MV_PAR08",mv_par08)
		SetMVValue("GPEM250A","MV_PAR09",mv_par09)
		Pergunte("GPEM250A",.F.)
	ElseIf aRotMark[nPos,5] == "1"
		Pergunte("GPEM270A",.F.)
		aParams := {mv_par01, mv_par02, mv_par03, mv_par04, mv_par05, mv_par06, mv_par07 }
		SetMVValue("GPEM270A","MV_PAR01",mv_par01)
		SetMVValue("GPEM270A","MV_PAR02",mv_par02)
		SetMVValue("GPEM270A","MV_PAR03",mv_par03)
		SetMVValue("GPEM270A","MV_PAR04",mv_par04)
		SetMVValue("GPEM270A","MV_PAR05",mv_par05)
		SetMVValue("GPEM270A","MV_PAR06",mv_par06)
		SetMVValue("GPEM270A","MV_PAR07",mv_par07)
		Pergunte("GPEM270A",.F.)		
	EndIf

	If SRA->(DbSeek(AllTrim(aRotMark[nPos,6]))) .or. nThreads > 1 //Busca primeiro funcionário da filial

		cFilter := ""

		If SRA->(DbSeek(AllTrim(aRotMark[nPos,6])))
			cFilAnt := SRA->RA_FILIAL
			cFilRCJ := AllTrim(xFilial("RCJ"))

			If !Empty(cFilUsua)
				cFilter := "( " + cFilUsua + " ) .AND. "
			EndIf

			cFilter += " RA_FILIAL >= '" + SubStr(cFilRCJ+Space(FWGETTAMFILIAL),1,FWGETTAMFILIAL) + "'"
			cFilter += " .and. RA_FILIAL <= '" + SubStr(cFilRCJ+Replicate("Z",FWGETTAMFILIAL),1,FWGETTAMFILIAL) + "'"
		EndIf
		If nThreads > 1
			If !Empty(cFilter)
				StartJob("Gpm020Thread",GetEnvServer(),.F.,cEmpAnt,cFilAnt,"000000",aRotMark,cFilter,nPos,aParams,cUID,lGrid)
			Else
				aAdd(aLogItens,{STR0057})

				//Soma 1 no controle de threads finalizadas
				VarBeginT(cUID,"nRotFim")
					VarGetXD(cUID,"nRotFim",@nRotAux)
					nRotAux++
					VarSetXD(cUID,"nRotFim",nRotAux)
				VarEndT(cUID,"nRotFim")

				nRotFim := nRotAux
			EndIf

			//Processa enquanto as threads não forem finalizadas
			While nPosAux == nTotThread .or. nPos == nTotProc
				VarGetXD(cUID,"nRotFim",@nRotFim)

				If nRotFim == nTotProc
					VarGetA(cUID,"aLogThd",@aLogThd)
					For nX := 1 to Len(aLogThd)
						If nX % 2 == 0
							aAdd(aLogItens,aLogThd[nX])
						Else
							aAdd(aLogTitle,aLogThd[nX][1])
						EndIf
					Next nX
					VarClean(cUID)
					Exit
				EndIf
				If nRotFim > nFimAux
					nPosAux -= ( nRotFim - nFimAux )
					nFimAux := nRotFim
				EndIf
			EndDo
		Else

			aAdd(aLogTitle,STR0080 + aRotMark[nPos,6] + " / " + STR0081 + aRotMark[nPos,1] + " / " + STR0082 + aRotMark[nPos,2] + " / " + STR0083 + aRotMark[nPos,3] + " / " + STR0084 + aRotMark[nPos,4])

			If xFilial("RCB", cFilAnt) != xFilial("RCB", cFilAux)
				RstGpexIni()
				If FindFunction("RstNroPed")
					RstNroPed()
				EndIf
			EndIf
			If cFilAnt <> cFilAux
				cFilAux := cFilAnt
				RstMnemonicos() //Reseta os mnemonicos para que sejam carregados os da filial de cálculo
				RstlDefaut()
			EndIf

			If aRotMark[nPos,5] == "3"
				GPM060Proc(cFilter,.T.)
			Else
				Gpem020(.T.,;			//Define Que a Chamada Esta Sendo Efetuada Atraves do WorkFlow
						aRotMark[nPos,1],;		//Define o processo que sera calculado
						aRotMark[nPos,2],;		//Define o roteiro que sera calculado
						cFilter;				//Filtro executado na rotina
						)
			 EndIf

			 aLogAux := GetAutoGRLog()
			 aAdd(aLogItens,aLogAux)

			 RstExecCalc() //Reseta variaveis staticas utilizadas no cálculo
		EndIf
	Else
		aAdd(aLogItens,{STR0057})
	EndIf

Next nPos

__cUserId := cUserAux

MsAguarde( { || fMakeLog( aLogItens, aLogTitle , "GPEM020A" , NIL , FunName() , STR0016 ) } ,  STR0016)
ClearGlbValue("lOfuscaJob")
cFilAnt := cFilBkp

SetMarkAll(oMark:Mark(),.F. )
aRotMark := {}

RestArea(aArea)

Return Nil

/*
{Protheus.doc} Gpm020Thread
Inicia threads de cálculo
@author Leandro Drumond
@since 19/10/2016
@version 1.0
*/
Function Gpm020Thread(xEmp,xFil,xUser,aRotMark,cFilter,nPos,aParams,cUID,lGrid)
Local aLogAux	:= {}
Local aLogThd	:= {}
Local aLogTitle	:= {}
Local nRotFim	:= 0

//Prepara ambiente
RPCSetType( 3 )
RpcSetEnv( xEmp, xFil,,,"GPE")
SetsDefault()

Private lAutoErrNoFile 	:= .T.
Private lAuto 			:= .T. //Utilizada para calcular férias no GPEM060

If Empty(cFilAnt)
	cFilAnt:= xFil
EndIf

__cUserId := xUser

aAdd(aLogTitle,STR0080 + aRotMark[nPos,6] + " / " + STR0081 + aRotMark[nPos,1] + " / " + STR0082 + aRotMark[nPos,2] + " / " + STR0083 + aRotMark[nPos,3] + " / " + STR0084 + aRotMark[nPos,4])

If aRotMark[nPos,5] == "3"
	SetMVValue("GPM062","MV_PAR01",aParams[1])
	SetMVValue("GPM062","MV_PAR02",aParams[2])
	SetMVValue("GPM062","MV_PAR03",aParams[3])
	SetMVValue("GPM062","MV_PAR04",aParams[4])
	SetMVValue("GPM062","MV_PAR05",aParams[5])
	SetMVValue("GPM062","MV_PAR06",aParams[6])
	SetMVValue("GPM062","MV_PAR07",aParams[7])
	SetMVValue("GPM062","MV_PAR08",aParams[8])
	Pergunte("GPM062",.F.)
	GPM060Proc(cFilter,.T.)
Else
	If aRotMark[nPos,5] == "5"
		SetMVValue("GPEM250A","MV_PAR01",aParams[1])
		SetMVValue("GPEM250A","MV_PAR02",aParams[2])
		SetMVValue("GPEM250A","MV_PAR03",aParams[3])
		SetMVValue("GPEM250A","MV_PAR04",aParams[4])
		SetMVValue("GPEM250A","MV_PAR05",aParams[5])
		SetMVValue("GPEM250A","MV_PAR06",aParams[6])
		SetMVValue("GPEM250A","MV_PAR07",aParams[7])
		SetMVValue("GPEM250A","MV_PAR08",aParams[8])
		SetMVValue("GPEM250A","MV_PAR09",aParams[9])
		Pergunte("GPEM250A",.F.)
	ElseIf aRotMark[nPos,5] == "1"
		SetMVValue("GPEM270A","MV_PAR01",aParams[1])
		SetMVValue("GPEM270A","MV_PAR02",aParams[2])
		SetMVValue("GPEM270A","MV_PAR03",aParams[3])
		SetMVValue("GPEM270A","MV_PAR04",aParams[4])
		SetMVValue("GPEM270A","MV_PAR05",aParams[5])
		SetMVValue("GPEM270A","MV_PAR06",aParams[6])
		SetMVValue("GPEM270A","MV_PAR07",aParams[7])
		Pergunte("GPEM270A",.F.) 
	EndIf
	If lGrid
		fSetThdGrid(StrZero(nPos,1))
	EndIf
	Gpem020(.T.,;			//Define Que a Chamada Esta Sendo Efetuada Atraves do WorkFlow
			aRotMark[nPos,1],;		//Define o processo que sera calculado
			aRotMark[nPos,2],;		//Define o roteiro que sera calculado
			cFilter;				//Filtro executado na rotina
			)
EndIf

aLogAux := GetAutoGRLog()

If !Empty(aLogAux)
	VarBeginT(cUID,"aLogThd")
	VarGetAD(cUID,"aLogThd",@aLogThd)
	aAdd(aLogThd, aLogTitle)
	aAdd(aLogThd, aLogAux)
	VarSetAD(cUID,"aLogThd",aLogThd)
	VarEndT(cUID,"aLogThd")
EndIf

//Soma 1 no controle de threads finalizadas
VarBeginT(cUID,"nRotFim")
	VarGetXD(cUID,"nRotFim",@nRotFim)
	nRotFim++
	VarSetXD(cUID,"nRotFim",nRotFim)
VarEndT(cUID,"nRotFim")

RstExecCalc() //Reseta variaveis staticas utilizadas no cálculo

Return Nil

/*/{Protheus.doc} fCriaTmp
Cria tabela temporária para uso do FwMarkBrowse
@author Leandro Drumond
@since 16/05/2016
@version 1.0
/*/
Static Function fCriaTmp()
Local aArea		 := GetArea()
Local aColumns	 := {}
Local cQuery	 := ''
Local cKeyAux	 := ''
Local cAliasRCH	 := 'QRCH'
Local cAcessaSRA := &( " { || " + IF( Empty( cAcessaSRA := ChkRH( "GPEM020" , "SRA" , "2" ) ) , ".T." , cAcessaSRA ) + " } " )
Local lOpeSoc	 := SuperGetMv("MV_OPESOC", NIL, .F.) 
Local lRet		 := .F.

If Select(cAliasMark) > 0
	DbSelectArea(cAliasMark)
	DbCloseArea()
EndIf

aAdd( aColumns, { "TAB_OK"		,"C",02,00 })
aAdd( aColumns, { "TAB_ROT"		,"C",TAMSX3("RY_CALCULO")[1],TAMSX3("RY_CALCULO")[2]})
aAdd( aColumns, { "TAB_DESC"	,"C",TAMSX3("RY_DESC")[1],TAMSX3("RY_DESC")[2]})
aAdd( aColumns, { "TAB_PROC"	,"C",TAMSX3("RCH_PROCES")[1],TAMSX3("RCH_PROCES")[2]})
aAdd( aColumns, { "TAB_PER"		,"C",TAMSX3("RCH_PER")[1],TAMSX3("RCH_PER")[2]})
aAdd( aColumns, { "TAB_NPAG"	,"C",TAMSX3("RCH_NUMPAG")[1],TAMSX3("RCH_NUMPAG")[2]})
aAdd( aColumns, { "TAB_TPROT"	,"C",TAMSX3("RY_TIPO")[1],TAMSX3("RY_TIPO")[2]})
aAdd( aColumns, { "TAB_FIL"		,"C",TAMSX3("RCH_FILIAL")[1],TAMSX3("RCH_FILIAL")[2]})

//Efetua a criacao do arquivo temporario
oTmpTable := FWTemporaryTable():New(cAliasMark)
oTmpTable:SetFields( aColumns )
oTmpTable:Create()

dbSelectArea( "RCH" )
DbSetOrder(RetOrdem("RCH","RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG"))

cQuery := "SELECT RY_DESC, RY_TIPO, RCH_FILIAL, RCH_PROCES, RCH_ROTEIR, RCH_PER, RCH_NUMPAG, RCH_DTINI"
cQuery += 		" FROM " + RetSqlName("RCH") + " RCH"
cQuery +=			" INNER JOIN " + RetSqlName("SRY") + " SRY"
cQuery +=			" ON RCH_ROTEIR = RY_CALCULO AND "
cQuery +=			FWJoinFilial( "RCH", "SRY" )
cQuery +=		" WHERE"
cQuery +=			" RY_TIPO NOT IN  ('4','G','J') AND"
If cPaisLoc == "BRA" .And. !lOpeSoc
	cQuery +=		" RY_TIPO NOT IN ('O') AND"
EndIf
cQuery +=			" ( RCH_PERSEL = '1' OR RY_TIPO = '3' ) AND"
cQuery +=			" RCH_DTINTE = '        ' AND"
cQuery +=			" SRY.D_E_L_E_T_ = ' ' AND RCH.D_E_L_E_T_ = ' '"
cQuery += 		" ORDER BY RCH_FILIAL, RCH_PROCES, RCH_PER, RCH_NUMPAG, RCH_ROTEIR "

cQuery := ChangeQuery( cQuery )

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRCH)

DbSelectArea(cAliasRCH)

DbSelectArea(cAliasMark)

While (cAliasRCH)->(!Eof())
	If cKeyAux <> (cAliasRCH)->(RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG)

		If ( !(Empty((cAliasRCH)->RCH_FILIAL)) .And. !(AllTrim((cAliasRCH)->RCH_FILIAL) $ fValidFil()) ) .Or. !Eval( cAcessaSRA )
			dbSelectArea(cAliasRCH)
			dbSkip()
			Loop
		EndIf

		lRet := .T.

		RecLock(cAliasMark,.T.)
		(cAliasMark)->TAB_FIL 	:= (cAliasRCH)->RCH_FILIAL
		(cAliasMark)->TAB_ROT 	:= (cAliasRCH)->RCH_ROTEIR
		(cAliasMark)->TAB_DESC 	:= (cAliasRCH)->RY_DESC
		(cAliasMark)->TAB_PROC	:= (cAliasRCH)->RCH_PROCES
		(cAliasMark)->TAB_PER	:= (cAliasRCH)->RCH_PER
		(cAliasMark)->TAB_NPAG	:= (cAliasRCH)->RCH_NUMPAG
		(cAliasMark)->TAB_TPROT	:= (cAliasRCH)->RY_TIPO

		MsUnLock()
		cKeyAux := (cAliasRCH)->(RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG)
	EndIf

	(cAliasRCH)->(DbSkip())

EndDo

( cAliasRCH )->( dbCloseArea() )

RestArea(aArea)

Return lRet

/*/{Protheus.doc} FMntColsMark
Carrega tabela temporária com dados para exibição na MarkBrowse
@author Leandro Drumond
@since 16/05/2016
@version 1.0
/*/
Static Function fMntColsMark()
Local aArea		:= GetArea()
Local aColsAux 	:=`{}
Local aColsSX3	:= {}
Local aCampos  	:= {"RCH_FILIAL","RCH_PROCES","RCH_PER","RY_CALCULO","RY_DESC","RCH_NUMPAG"}
Local aDados	:= {{||(cAliasMark)->TAB_FIL},{||(cAliasMark)->TAB_PROC},{||(cAliasMark)->TAB_PER},{||(cAliasMark)->TAB_ROT}, {||(cAliasMark)->TAB_DESC},{||(cAliasMark)->TAB_NPAG}}
Local nX		:= 0

DbSelectArea("SX3")
DbSetOrder(2)

For nX := 1 to Len(aCampos)
	If SX3->( dbSeek(aCampos[nX]) )
	    aColsSX3 := {X3Titulo(),aDados[nX], SX3->X3_TIPO, SX3->X3_PICTURE,1,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,,,,,,,,1}
	    aAdd(aColsAux,aColsSX3)
	    aColsSX3 := {}
	EndIf
Next nX

RestArea(aArea)

Return aColsAux

/*/{Protheus.doc} SetMarkAll
Marca/Desmarca todos os itens da markbrowse
@author Leandro Drumond
@since 16/05/2016
@version 1.0
/*/
Static Function SetMarkAll(cMarca,lMarcar )

Local aAreaMark  := (cAliasMark)->( GetArea() )

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	RecLock( (cAliasMark), .F. )
	(cAliasMark)->TAB_OK := IIf( lMarcar, cMarca, '  ' )
	MsUnLock()
	(cAliasMark)->( dbSkip() )
EndDo

RestArea( aAreaMark )

Return .T.

/*/{Protheus.doc} GP20FilMark
Filtra dados da MarkBrowse de acordo com opções preenchidas
@author Leandro Drumond
@since 16/05/2016
@version 1.0
/*/
Static Function Gp20FilMark()

	cFilFiltr := cFilCalc
	If !Empty(cFilFiltr)
		cFilFiltr := xFilial("RCH",cFilFiltr) //Altera o cFilCalc para ficar de acordo com o compartilhamento utilizado.
	EndIf

	DbSelectArea(cAliasMark)
	SET FILTER TO

	DbSelectArea(cAliasMark)

	If Empty(cFilFiltr)
		If !Empty(cProcesso) .and. !Empty(cPeriodo) .and. !Empty(cNumPag) .and. !Empty(cRoteiro)
			SET FILTER TO TAB_PROC == cProcesso .And.  TAB_PER ==  cPeriodo .And. TAB_NPAG ==cNumPag .And.  TAB_ROT  ==   cRoteiro
		ElseIf !Empty(cProcesso) .and. !Empty(cPeriodo) .and. !Empty(cNumPag) .and. Empty(cRoteiro)
			SET FILTER TO TAB_PROC == cProcesso .And.  TAB_PER ==  cPeriodo .And. TAB_NPAG ==cNumPag
		ElseIf !Empty(cProcesso) .and. !Empty(cPeriodo) .and. Empty(cNumPag) .and. !Empty(cRoteiro)
		 	SET FILTER TO TAB_PROC == cProcesso .And.  TAB_PER ==  cPeriodo .And.  TAB_ROT  ==   cRoteiro
		ElseIf !Empty(cProcesso) .and. Empty(cPeriodo) .and. !Empty(cNumPag) .and. !Empty(cRoteiro)
			SET FILTER TO TAB_PROC == cProcesso .And. TAB_NPAG == cNumPag .And. TAB_ROT == cRoteiro
		ElseIf !Empty(cProcesso) .and. Empty(cPeriodo) .and. !Empty(cNumPag) .and. Empty(cRoteiro)
			SET FILTER TO TAB_PROC == cProcesso .And. TAB_NPAG ==cNumPag
		ElseIf !Empty(cProcesso) .and. Empty(cPeriodo) .and. Empty(cNumPag) .and. !Empty(cRoteiro)
			SET FILTER TO TAB_PROC == cProcesso .And. TAB_ROT  == cRoteiro
		ElseIf !Empty(cProcesso) .and. !Empty(cPeriodo) .and. Empty(cNumPag) .and. Empty(cRoteiro)
			SET FILTER TO TAB_PROC == cProcesso .And.  TAB_PER == cPeriodo
		ElseIf !Empty(cProcesso) .and. Empty(cPeriodo) .and. Empty(cNumPag) .and. Empty(cRoteiro)
			SET FILTER TO TAB_PROC == cProcesso
		ElseIf Empty(cProcesso) .and. !Empty(cPeriodo) .and. Empty(cNumPag) .and. Empty(cRoteiro)
			SET FILTER TO TAB_PER == cPeriodo
		ElseIf Empty(cProcesso) .and. !Empty(cPeriodo) .and. !Empty(cNumPag) .and. !Empty(cRoteiro)
			SET FILTER TO TAB_PER == cPeriodo .And. TAB_NPAG == cNumPag .And. TAB_ROT == cRoteiro
		ElseIf Empty(cProcesso) .and. !Empty(cPeriodo) .and. !Empty(cNumPag) .and. Empty(cRoteiro)
			SET FILTER TO TAB_PER == cPeriodo .And. TAB_NPAG == cNumPag
		ElseIf Empty(cProcesso) .and. !Empty(cPeriodo) .and. Empty(cNumPag) .and. !Empty(cRoteiro)
			SET FILTER TO  TAB_PER ==  cPeriodo .And.  TAB_ROT  ==   cRoteiro
		ElseIf Empty(cProcesso) .and. Empty(cPeriodo) .and. !Empty(cNumPag) .and. !Empty(cRoteiro)
			SET FILTER TO  TAB_NPAG == cNumPag .And.  TAB_ROT == cRoteiro
		ElseIf Empty(cProcesso) .and. Empty(cPeriodo) .and. !Empty(cNumPag) .and. Empty(cRoteiro)
			SET FILTER TO TAB_NPAG == cNumPag
		ElseIf Empty(cProcesso) .and. Empty(cPeriodo) .and. Empty(cNumpag) .and. !Empty(cRoteiro)
			SET FILTER TO TAB_ROT == cRoteiro
		EndIf
	Else
		If !Empty(cProcesso) .and. !Empty(cPeriodo) .and. !Empty(cNumPag) .and. !Empty(cRoteiro)
			SET FILTER TO TAB_FIL == cFilFiltr .And. TAB_PROC == cProcesso .And.  TAB_PER ==  cPeriodo .And. TAB_NPAG ==cNumPag .And.  TAB_ROT  ==   cRoteiro
		ElseIf !Empty(cProcesso) .and. !Empty(cPeriodo) .and. !Empty(cNumPag) .and. Empty(cRoteiro)
			SET FILTER TO TAB_FIL == cFilFiltr .And. TAB_PROC == cProcesso .And.  TAB_PER ==  cPeriodo .And. TAB_NPAG ==cNumPag
		ElseIf !Empty(cProcesso) .and. !Empty(cPeriodo) .and. Empty(cNumPag) .and. !Empty(cRoteiro)
		 	SET FILTER TO TAB_FIL == cFilFiltr .And. TAB_PROC == cProcesso .And.  TAB_PER ==  cPeriodo .And. TAB_ROT  ==   cRoteiro
		ElseIf !Empty(cProcesso) .and. Empty(cPeriodo) .and. !Empty(cNumPag) .and. !Empty(cRoteiro)
			SET FILTER TO TAB_FIL == cFilFiltr .And. TAB_PROC == cProcesso .And. TAB_NPAG == cNumPag .And. TAB_ROT == cRoteiro
		ElseIf !Empty(cProcesso) .and. Empty(cPeriodo) .and. !Empty(cNumPag) .and. Empty(cRoteiro)
			SET FILTER TO TAB_FIL == cFilFiltr .And. TAB_PROC == cProcesso .And. TAB_NPAG ==cNumPag
		ElseIf !Empty(cProcesso) .and. Empty(cPeriodo) .and. Empty(cNumPag) .and. !Empty(cRoteiro)
			SET FILTER TO TAB_FIL == cFilFiltr .And. TAB_PROC == cProcesso .And. TAB_ROT  == cRoteiro
		ElseIf !Empty(cProcesso) .and. !Empty(cPeriodo) .and. Empty(cNumPag) .and. Empty(cRoteiro)
			SET FILTER TO TAB_FIL == cFilFiltr .And. TAB_PROC == cProcesso .And.  TAB_PER == cPeriodo
		ElseIf !Empty(cProcesso) .and. Empty(cPeriodo) .and. Empty(cNumPag) .and. Empty(cRoteiro)
			SET FILTER TO TAB_FIL == cFilFiltr .And. TAB_PROC == cProcesso
		ElseIf Empty(cProcesso) .and. !Empty(cPeriodo) .and. Empty(cNumPag) .and. Empty(cRoteiro)
			SET FILTER TO TAB_FIL == cFilFiltr .And. TAB_PER == cPeriodo
		ElseIf Empty(cProcesso) .and. !Empty(cPeriodo) .and. !Empty(cNumPag) .and. !Empty(cRoteiro)
			SET FILTER TO TAB_FIL == cFilFiltr .And. TAB_PER == cPeriodo .And. TAB_NPAG == cNumPag .And. TAB_ROT == cRoteiro
		ElseIf Empty(cProcesso) .and. !Empty(cPeriodo) .and. !Empty(cNumPag) .and. Empty(cRoteiro)
			SET FILTER TO TAB_FIL == cFilFiltr .And. TAB_PER == cPeriodo .And. TAB_NPAG == cNumPag
		ElseIf Empty(cProcesso) .and. !Empty(cPeriodo) .and. Empty(cNumPag) .and. !Empty(cRoteiro)
			SET FILTER TO TAB_FIL == cFilFiltr .And. TAB_PER ==  cPeriodo .And.  TAB_ROT  ==   cRoteiro
		ElseIf Empty(cProcesso) .and. Empty(cPeriodo) .and. !Empty(cNumPag) .and. !Empty(cRoteiro)
			SET FILTER TO TAB_FIL == cFilFiltr .And. TAB_NPAG == cNumPag .And.  TAB_ROT == cRoteiro
		ElseIf Empty(cProcesso) .and. Empty(cPeriodo) .and. !Empty(cNumPag) .and. Empty(cRoteiro)
			SET FILTER TO TAB_FIL == cFilFiltr .And. TAB_NPAG == cNumPag
		ElseIf Empty(cProcesso) .and. Empty(cPeriodo) .and. Empty(cNumpag) .and. !Empty(cRoteiro)
			SET FILTER TO TAB_FIL == cFilFiltr .And. TAB_ROT == cRoteiro
		Else
			SET FILTER TO TAB_FIL == cFilFiltr
		EndIf
	EndIf

	oMark:Refresh(.T.)

Return .T.

/*
{Protheus.doc} GPM020IniFilt
Monta filtro utilizado no cálculo
@author Leandro Drumond
@since 16/05/2016
@version 1.0
*/
Static Function GPM020IniFilt()

GpFltBldExp( "SRA" , NIL , @cFilUsua , NIL )

Return Nil

User Function GPEM020A()

Local oDlg
Local cLink 	:= 'http://tdn.totvs.com/pages/viewpage.action?pageId=368083530'
Local oFont1	:= TFont():New("Tahoma",,-12,.T.,.T.)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0005) FROM 0,0 TO 200,760 PIXEL //"Atenção"

TSay():New( 010,010,{||OemToAnsi(STR0106)},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK) //A função U_GPEM020A foi descontinuada e sua chamada no menu deve ser substituída pela nova função, GPEM020A.
TSay():New( 025,010,{||OemToAnsi(STR0107)},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK) //"Consulte mais informações sobre esta alteração no TDN:"
TGet():New( 040,010,{||cLink },oDlg, 195, 09, "@!",,,,,,,.T.,,,,,,,.T.)

TButton():New(040,230, OemToAnsi(STR0108), oDlg,{|| OpenTDN() },030,011,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Abrir Link"
TButton():New(040,350, OemToAnsi(STR0046), oDlg,{|| oDlg:End() },26,11,,,.F.,.T.,.F.,,.F.,,,.F. ) //Ok

ACTIVATE MSDIALOG oDlg CENTER

Return()

/*/{Protheus.doc} OpenTDN
Abre o navegador padrão com a página sobre o Meu RH
@author jose.silveira
@since 09/02/2018
@version 12.1.17
/*/
Static Function OpenTDN()

	Local cURL := "http://tdn.totvs.com/pages/viewpage.action?pageId=368083530"

	shellExecute("Open", cURL, "", "", SW_NORMAL)

Return Nil
