#include "pmsgantt.ch"
#include "protheus.ch"
#include "PMSICONS.CH"

Static aParam	:= {"",.F.,.F.,.F.}

//-------------------------------------------------------------------
/*{Protheus.doc} PmsGantt

Desenha um objeto Gantt na tela.

@param   aGantt,array, array contendo os dados do Gantt
			[x][1] : Array contendo os dados das tarefas.
			         Ex: {"Tarefa 1","29/11/01","20h"}
			[x][2] : Array contendo os intervalos das tarefas
			         Ex: {{dIni,HoraIni,dFim,HoraFim,cTexto..}..}
			              dIni : Data inicial
			              HoraIni : Hora Inicial (XX:XX)
			              dFim : Data Final
			              HoraFim : Hora Final   (XX:XX)
			              cTexto  : Texto a ser exibido na barra
			              cColor  : Cor do Gantt
			              bClick  : Code Block no Click
			              nAlign  : Metodo de Alinhamento
			                        1 - Normal
			                        2 - Acima a Direita
@param   aConfig,Array ,contendo as configuracoes do Gantt
			[1] Escala - 1-Diario,2-Semanal,3-Mensal
			[2],[3]...[n] - Indica os campos da exibicao .T.,.F.

@param   dIni,,Data Inicial da Escala ( opcional )
@param   dFim,, Data Final da Escala ( opcional )
@param   oDlg,, Objeto onde sera criado o Gantt
@param   aPos,, Array contendo as posicoes do Gantt no objeto
@param   aCampos,,Array contendo a descricao e tamanho dos dados das tarefas.
							Ex : {{"Descricao",40},{"Duracao",30},..}
@param   nTsk
@param   aDep
@param   cText
@param   oGantt
@param   lInternal
@param   aCmbSeek
@param   aRetRec
@param   lMsgTotal
@param   lProject

@return  oGantt

@obs Uma vez criado o objeto ele nao podera ser alterado.

@author  Edson Maricate
@version P11
@since   14/09/01

//-------------------------------------------------------------------
*/
Function PmsGantt(aGantt,aConfig,dIni,dFim,oDlg,aPos,aCampos,nTsk,aDep,cText,oGantt,lInternal,aCmbSeek,aRetRec,lMsgTotal ,lProject)
// Projeto TDI - TEGOAQ - Quantidade de tarefas no monitor
// Adiciona texto de QTD TAREFA no monitor
// lMsgTotal -> .T. exibe o total de tarefas
//   (para funcionar a rotina que chama esta funcao deve criar a variavel Private nQtdTarefas que deve conter a
//    quantidade de tarefas que serao exibidas no grafico)

Local nCol
Local nLin
Local nSize
Local nYear
Local nMonthIni
Local nMonthEnd
Local z,nx,ny,dx
Local nColIni	:= 50
Local cTextSay	:= ""
Local nMaxTsk	:= 0
Local aMeses	:= {STR0001,STR0002,STR0003,STR0004,STR0005,STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012} //"Jan"###"Fev"###"Mar"###"Abr"###"Mai"###"Jun"###"Jul"###"Ago"###"Set"###"Out"###"Nov"###"Dez"
Local aCombo	:= {}
Local aTskCmb	:= {}
Local cCombo	:= ""
Local cCombo2	:= ""
Local aCombo2	:= {}

Local oPanel
Local oPanel1
Local oPanel2
Local oPanel3
Local oPanel4
Local oPanel5
Local oPanel6
Local oBar
Local dDateAtu	:= MsDate()
Local nMes := 0
Local cAddText	:= ""
Local cMsgTotal := "Qtd Tarefas:"
Local oBmp
Local oCombo2
Local oCBX
Local nTskPsq
Local LPMSPGANT :=  EXISTBLOCK("PMSPGANT")

Local nTamProd	:= 0

DEFAULT lInternal	:= .F.
DEFAULT nTsk 		:= 1
DEFAULT aDep 		:= {}
DEFAULT cText		:= cCadastro
DEFAULT aCmbSeek	:= {1,2}
DEFAULT aGantt	:= {}
DEFAULT lProject 	:= .T.

DEFINE FONT oArialBold NAME "Arial" SIZE 0, -11 BOLD
DEFINE FONT oMonoAs NAME "Courier New" SIZE 6,-09
DEFINE FONT oArial NAME "Arial" SIZE 0, -10 BOLD

//Escala horaria
//"|                                          16/08/01                                           |
//"|   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23 |
//"|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//Escala horaria
//"|                  16/08/01                    |"
//"|   2   4   6   8  10  12  14  16  18  20  22  |"
//"||||||||||||||||||||||||||||||||||||||||||||||||"
//Escala diaria
//"|       16/08/01       | Terca 17, Abril 2001  |"
//"|     6    12    18    |                       |"
//"||||||||||||||||||||||||||||||||||||||||||||||||"
//Escala semanal
//"| 30 Setembro 2001  | 07 Outubro 2001   |"
//"|D  S  T  Q  Q  S  S|D  S  T  Q  Q  S  S|"
//"|||||||||||||||||||||||||||||||||||||||||"
//Escala mensal 100%
//"|        Janeiro/2001         |      Fevereiro/2001        |"
//"|    5        15        25    |    5        15        25   |"
//"||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
//Escala mensal 30%
//"|Jan/2001  |Fev/2001  |"
//"|   15     |   15     |"
//"|||||||||||||||||||||||"
//Escala bimestral
//"|01/2001   |03/2001   |"
//"|    1     |     1    |"
//"|||||||||||||||||||||||"

If oGantt==Nil
	oGantt	:= tPanel():New( aPos[1],aPos[2],"",oDlg,,.T.,.T.,,,aPos[4],30,.F.,.F.)
	oGantt:Align := CONTROL_ALIGN_ALLCLIENT
EndIf

// define o numero de tarefas por pagina, pela resolu豫o vertical.
Do Case
	Case GetScreenRes()[2] >= 1024
		nMaxTsk := 35
	Case GetScreenRes()[2] >= 768
		nMaxTsk := 28
	Otherwise
		nMaxTsk := 17
EndCase

// se a quantidade for impar deve excluir uma para compatibilizar quando for
// previsto x realizado
If nMaxTsk > 1 .AND. !((nMaxTsk % 2) == 0) .and. (nTsk+nMaxTsk) <= Len(aGantt)
	nMaxTsk -= 1
EndIf

oPanel1 := tPanel():New( aPos[1],aPos[2],"",oGantt,,.T.,.T.,,,aPos[4],30,.F.,.F.)
oPanel1:Align := CONTROL_ALIGN_TOP
oPanel	:= tPanel():New( aPos[1],aPos[2],"",oGantt,,.T.,.T.,,,aPos[4],30,.F.,.F.)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

If !Empty(aGantt)
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	//?Calcula a coluna inicial do Gantt e cria a legenda      ?
	//?das tarefas.                                            ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	For nx := 1 to Len(aCampos)
		If aConfig[nx+1]
			nColIni += aCampos[nx][2]
			cTextSay:= "{||' "+StrGantt(aCampos[nx][1])+" '}"
			If nx == 3 .AND. aConfig[2] .AND. aConfig[3]
				nColIni += 20
			EndIf
			oSay := TSay():New( 20,nColIni+3-aCampos[nx][2], MontaBlock(cTextSay) , oPanel1 , ,oArial,,,,.T.,CLR_BLACK,,,,,,,,)
		EndIf
	Next
	nColIni:=MAX(nColIni,110)
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	//?Verifica as datas iniciais e finais da escala.          ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	If Empty(dIni) .Or. aConfig[1]==6
		dIni := PMS_MAX_DATE
		dFim := PMS_MIN_DATE
		For	nx := MAX(nTsk,1) to MIN(Len(aGantt),Round((nTsk-1)+nMaxTsk,0))
			For ny := 1 to Len(aGantt[nx][2])
				If !Empty(aGantt[nx][2][ny][1]) .And. aGantt[nx][2][ny][1] < dIni
					dIni := aGantt[nx][2][ny][1]
				EndIf
				If !Empty(aGantt[nx][2][ny][3]).And. aGantt[nx][2][ny][3] > dFim
					dFim := aGantt[nx][2][ny][3]
				EndIf
			Next
		Next
	EndIf
	If aConfig[1] == Nil .Or. aConfig[1]==6
		Do Case
			Case dFim-dIni > 240
				aConfig[1] := 5
			Case dFim-dIni > 89
				aConfig[1] := 4
			Case dFim-dIni > 21
				aConfig[1] := 3
			Case dFim-dIni > 3
				aConfig[1] := 2
			Case dFim-dIni > 2
				aConfig[1] := 1
			OtherWise
				aConfig[1] := 0
		EndCase
	EndIf
	Do Case
		Case aConfig[1] == -1
			dFim := dIni+(((oPanel:nWidth/2)-nColIni)/288)
		Case aConfig[1] == 0
			dFim := dIni+(((oPanel:nWidth/2)-nColIni)/144)
		Case aConfig[1] == 1
			dFim := dIni+(((oPanel:nWidth/2)-nColIni)/72)
		Case aConfig[1] == 2
			If DOW(dIni)<>1
				dIni -= DOW(dIni)-1
			EndIf
			dFim := dIni+(((oPanel:nWidth/2)-nColIni)/9)
		Case aConfig[1] == 3
			dFim := dIni+(((oPanel:nWidth/2)-nColIni)/3)
		Case aConfig[1] == 4
			dFim := dIni+(((oPanel:nWidth/2)-nColIni))
		Case aConfig[1] == 5
			dFim := dIni+(((oPanel:nWidth/2)-nColIni)*2)
	EndCase
EndIf

If !lInternal
	If Type("bRfshGantt") <> "B"
		bRfshGantt	:= {|| (oGantt:Hide(),MsFreeObj(@oGantt,.T.);
		                    ,nTsk := iIf(nTsk>Len(aGantt),Len(aGantt),nTsk);
		                    ,PmsGantt(aGantt,aConfig,@dIni,@dFim,@oDlg,aPos,aCampos,@nTsk,aDep,@cText,@oGantt,.T.,,@aRetRec,,lProject),GanttCmb1(aCmbSeek,aGantt,@oCBX,aCombo,aTskCmb),GanttCmb2(@nTsk,aGantt,@oCombo2,aCombo2),oGantt:Show()) }
	Endif
	oPanel2 := tPanel():New( aPos[1]+28,aPos[2],"",oDlg,,.T.,.T.,,,10,30,.F.,.F.)
	oPanel2:Align := CONTROL_ALIGN_RIGHT

	@1,1 BTNBMP oBmp1 RESOURCE BMP_SETA_TOP   SIZE 25,25 ACTION (oGantt:Hide(),MsFreeObj(oGantt,.T.),nTsk:=1,PmsGantt(aGantt,aConfig,dIni,dFim,oDlg,aPos,aCampos,@nTsk,aDep,cText,@oGantt,.T.,,@aRetRec,,lProject),oGantt:Show()) WHEN nTsk > 1 Of oPanel2
	oBmp1:Align := CONTROL_ALIGN_TOP

	@1,1 BTNBMP oBmp1 RESOURCE BMP_SETA_UP   SIZE 25,25 ACTION (oGantt:Hide(),MsFreeObj(oGantt,.T.),nTsk-=(nMaxTsk-2),iIf(nTsk<1,nTsk:=1,.T.),PmsGantt(aGantt,aConfig,dIni,dFim,oDlg,aPos,aCampos,@nTsk,aDep,cText,@oGantt,.T.,,@aRetRec,,lProject),oGantt:Show()) WHEN nTsk > 1 Of oPanel2
	oBmp1:Align := CONTROL_ALIGN_TOP

	@1,1 BTNBMP oBmp1 RESOURCE BMP_ZOOM_OUT   SIZE 25,25 ACTION (oGantt:Hide(),MsFreeObj(oGantt,.T.),aConfig[1]++,PmsGantt(aGantt,aConfig,dIni,dFim,oDlg,aPos,aCampos,@nTsk,aDep,cText,@oGantt,.T.,,@aRetRec,,lProject),oGantt:Show()) WHEN aConfig[1] < 5 Of oPanel2
	oBmp1:Align := CONTROL_ALIGN_TOP

	@1,1 BTNBMP oBmp1 RESOURCE BMP_ZOOM_IN   SIZE 25,25 ACTION (oGantt:Hide(),MsFreeObj(oGantt,.T.),aConfig[1]--,PmsGantt(aGantt,aConfig,dIni,dFim,oDlg,aPos,aCampos,@nTsk,aDep,cText,@oGantt,.T.,,@aRetRec,,lProject),oGantt:Show()) WHEN aConfig[1] > -1 Of oPanel2
	oBmp1:Align := CONTROL_ALIGN_TOP

	@1,1 BTNBMP oBmp2 RESOURCE BMP_SETA_DOWN SIZE 25,25 ACTION (oGantt:Hide(),MsFreeObj(oGantt,.T.),nTsk+=(nMaxTsk-2),PmsGantt(aGantt,aConfig,dIni,dFim,oDlg,aPos,aCampos,@nTsk,aDep,cText,@oGantt,.T.,,@aRetRec,,lProject),oGantt:Show()) WHEN nTsk < Len(aGantt)-1-nMaxTsk Of oPanel2
	oBmp2:Align := CONTROL_ALIGN_TOP
	@1,1 BTNBMP oBmp2 RESOURCE BMP_SETA_BOTTOM SIZE 25,25 ACTION (oGantt:Hide(),MsFreeObj(oGantt,.T.),nTsk:=Len(aGantt)-nMaxTsk-1 ,PmsGantt(aGantt,aConfig,dIni,dFim,oDlg,aPos,aCampos,@nTsk,aDep,cText,@oGantt,.T.,,@aRetRec,,lProject),oGantt:Show()) WHEN nTsk < Len(aGantt)-1-nMaxTsk Of oPanel2
 	oBmp2:Align := CONTROL_ALIGN_TOP

	oPanel3 := tPanel():New( aPos[1]+28,aPos[2],"",oDlg,,.T.,.T.,,,13,13,.F.,.F.)
	oPanel3:Align := CONTROL_ALIGN_TOP

	oPanel6 := tPanel():New( aPos[1]+28,aPos[2],"",oPanel3,,.T.,.T.,,,10,9,.F.,.F.)
	oPanel6:Align := CONTROL_ALIGN_RIGHT

	@ 25,25 BTNBMP oBtn RESOURCE BMP_IMPRESSAO SIZE 25,25 ACTION (IIF( LPMSPGANT , EXECBLOCK("PMSPGANT",.F.,.F.,{cCadastro ,aGantt ,aConfig ,dIni , ,aCampos ,aDep}), PmsImpGantt( cCadastro ,aGantt ,aConfig ,dIni , ,aCampos ,aDep ,lProject) )) MESSAGE "Imprimir" of oPanel3

	oBtn:Align := CONTROL_ALIGN_RIGHT

	@5,5 BTNBMP oBmp1 RESOURCE BMP_SETA_DIREITA   SIZE 25,25 ACTION (oGantt:Hide(),MsFreeObj(oGantt,.T.),PmsNxtGnt(,oDlg,aConfig,@dIni,aGantt,@nTsk),PmsGantt(aGantt,aConfig,dIni,dFim,oDlg,aPos,aCampos,@nTsk,aDep,cText,@oGantt,.T.,,@aRetRec,,lProject),oGantt:Show()) Of oPanel3
	oBmp1:Align := CONTROL_ALIGN_RIGHT

	oPanel4 := tPanel():New( 4,4,"",oPanel3,,.T.,.T.,,,50,9,.F.,.F.)
	oPanel4:Align := CONTROL_ALIGN_RIGHT

	@1,1 BTNBMP oBmp2 RESOURCE BMP_SETA_ESQUERDA   SIZE 25,25 ACTION (oGantt:Hide(),MsFreeObj(oGantt,.T.),PmsPrvGnt(,oDlg,aConfig,@dIni,aGantt,@nTsk),PmsGantt(aGantt,aConfig,dIni,dFim,oDlg,aPos,aCampos,@nTsk,aDep,cText,@oGantt,.T.,,@aRetRec,,lProject),oGantt:Show()) Of oPanel3
	oBmp2:Align := CONTROL_ALIGN_RIGHT

	@1,1 BTNBMP oBmp1 RESOURCE BMP_SALVAR   SIZE 16,16 ACTION  GanttSave(dIni,aGantt,aCampos,aDep,aCmbSeek,cText,aConfig) Of oPanel3
	oBmp1:Align := CONTROL_ALIGN_RIGHT

	@1,1 BTNBMP oBmp1 RESOURCE BMP_RELOAD   SIZE 16,16 ACTION  Eval(bRfshGantt) Of oPanel3 When Type('bRfshGantt') <> "U"
	oBmp1:Align := CONTROL_ALIGN_RIGHT

	@ 2,1 MSGET oGet VAR dIni VALID (oGantt:Hide(),MsFreeObj(oGantt,.T.),PmsGantt(aGantt,aConfig,dIni,dFim,oDlg,aPos,aCampos,@nTsk,aDep,cText,@oGantt,.T.,,@aRetRec,cMsgTotal,lProject),oGantt:Show()) SIZE 50,9 OF oPanel4 PIXEL HASBUTTON

	@ 5,6  BUTTON oBmp PROMPT  "Gantt" SIZE 0,0   ACTION {|| Nil}  OF oPanel4 PIXEL

	@1,1 BTNBMP oBmp1 RESOURCE BMP_PESQUISAR   SIZE 22,22   Of oPanel3  ACTION If(PsqGntInt(aGantt,@nTskPsq,nTsk),(oGantt:Hide(),oCbx:nAt:=nTskPsq,MsFreeObj(oGantt,.T.),nTsk:=nTskPsq,dIni:=aGantt[nTsk][2][1][1] ,PmsGantt(aGantt,aConfig,dIni,dFim,oDlg,aPos,aCampos,@nTsk,aDep,cText,@oGantt,.T.,,@aRetRec,,lProject),GanttCmb2(nTsk,aGantt,@oCombo2,aCombo2),oGantt:Show()),Nil )
	oBmp1:Align := CONTROL_ALIGN_LEFT
	oBmp1:cToolTip := STR0014

	@1,1 BTNBMP oBmpP RESOURCE BMP_E5	SIZE 22,22   Of oPanel3  ACTION If(PsqGntInt(aGantt,@nTskPsq,nTsk,.T.),(oGantt:Hide(),oCbx:nAt:=nTskPsq,MsFreeObj(oGantt,.T.),nTsk:=nTskPsq,dIni:=aGantt[nTsk][2][1][1] ,PmsGantt(aGantt,aConfig,dIni,dFim,oDlg,aPos,aCampos,@nTsk,aDep,cText,@oGantt,.T.,,@aRetRec,,lProject),GanttCmb2(nTsk,aGantt,@oCombo2,aCombo2),oGantt:Show()),Nil )
	oBmpP:Align := CONTROL_ALIGN_LEFT
	oBmpP:cToolTip := STR0015

	oPanel5 := tPanel():New( aPos[1]+28,aPos[2],"",oPanel3,,.T.,.T.,,,285,9,.F.,.F.)
	oPanel5:Align := CONTROL_ALIGN_LEFT

	@ 2,1 COMBOBOX oCBX VAR cCombo ITEMS aCombo SIZE 220,220 OF oPanel5 PIXEL VALID CBXVld( oDlg ,oGantt ,oCbx ,oCombo2 ,@aTskCmb ,@aCombo2 ,@nTsk ,@dIni ,@dFim ,@aPos ,@aGantt ,@aConfig ,@aCampos, @aDep ,@cText ,@aRetRec ,lProject) FONT oArial

	@ 5,6  BUTTON oBmp PROMPT  "Gantt" SIZE 0,0   ACTION {|| Nil}  OF oPanel5 PIXEL

	@ 2,142 COMBOBOX oCombo2 VAR cCombo2 ITEMS aCombo2 SIZE 130,220 OF oPanel5 PIXEL VALID Combo2Vld( oDlg ,oGantt ,oCombo2 ,@nTsk ,@dIni ,@dFim ,@aPos ,@aGantt ,@aConfig ,@aCampos, @aDep ,@cText ,@aRetRec ,lProject) FONT oArial

	@ 5,6  BUTTON oBmp PROMPT  "Gantt" SIZE 0,0   ACTION {|| Nil}  OF oPanel5 PIXEL

	GanttCmb1(aCmbSeek,aGantt,@oCBX,aCombo,aTskCmb)
	GanttCmb2(nTsk,aGantt,@oCombo2,aCombo2)

	// Projeto TDI - TEGOAQ - Quantidade de tarefas no monitor
	// Adiciona texto de QTD TAREFA no monitor
	if lMsgTotal
		if Type("nQtdTarefas") == "N"
			@ 2,320 SAY Eval({|| cMsgTotal+" "+Alltrim(Str(nQtdTarefas))} ) SIZE 50,9 OF oPanel3 PIXEL FONT oArialBold
		Endif
	Endif

EndIf

@ 5,6  BUTTON oBmp PROMPT  "Gantt" SIZE 0,0   ACTION {|| Nil}  OF oPanel PIXEL
oBmp:Hide()

@ 5,6  SAY cText SIZE 140,20 Of oPanel1 PIXEL FONT oArialBold

If !Empty(aGantt)
	nCol:=nColIni
	@ 1,4 To 27,nCol+1 Label "" Of oPanel1 PIXEL
	@ 1,4 To 27+((nMaxTsk+1)*8),nCol+1 Label "" Of oPanel PIXEL
	If !Empty(dIni) .And. !Empty(dFim)
		Do Case
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			//?Cria o Gantt na escala 'horaria -1'                     ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			Case aConfig[1] == -1
				For dx := dIni to dFim
					nLin	:= 1
					@ nLin,nCol To nLin+26,nCol+289 Label "" Of oPanel1 PIXEL
					@ nLin,nCol To nLin+26+((nMaxTsk+1)*8),nCol+289 Label "" Of oPanel PIXEL
					If dx == dDateAtu
						@ -2,nCol-2+(Val(Substr(Time(),1,2))*12) To iIf( aPos[3]-28 > 27+((nMaxTsk+1)*8) ,aPos[3]-28 ,27+((nMaxTsk+1)*8) ) ,nCol+(Val(Substr(Time(),1,2))*12) Label "" Of oPanel PIXEL
					EndIf
					nLin += 6
					cTextSay:= "{||' "+SPACE(40)+DTOC(dx) +" '}"
					oSay := TSay():New( nLin,nCol, MontaBlock(cTextSay) , oPanel1 , ,oMonoAs,,,,.T.,CLR_BLACK,,,,,,,,)
					nLin += 10
					@ nLin,nCol Say "   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23 " COLORS CLR_BLACK Of oPanel1 FONT oMonoAs PIXEL
					nLin += 20
					nCol += 288
				Next dx
				nCol := nColIni
				nLin := 5
				For nx := Round(MAX(nTsk,1),0) to MIN(Len(aGantt),Round((nTsk-1)+nMaxTsk,0))
					aAdd(aCombo,"")
					nSize := 7
					For z := 1 to Len(aCampos)
						If aConfig[z+1]
							If aRetRec <> Nil .And. z == 1 .And. !Empty(StrGantt(aGantt[nx][1][z]))
								bGetBox	:= &("{|| MarkRecurso(@aRetRec,'"+StrGantt(aGantt[nx][1][z])+"')}" )
				   				oChkBox	:=	TCheckBox():New(nLin-2,5,"",,oPanel, 10,10,,bGetBox,,,,,,.T.,,,)
				   				nSize	+=	7
							Endif
							cTextSay:= "{||'"+StrGantt(aGantt[nx][1][z])+"'}"
							oSay	:= TSay():New( nLin,nSize, MontaBlock(cTextSay) , oPanel , ,If(aGantt[nx][4]!=Nil,aGantt[nx][4],oArial),,,,.T.,CLR_BLACK,,,,,,,,)
							If !IsInCallStack("PMSC125")
								If aConfig[3] .AND. aConfig[4] .AND. aConfig[5] .AND. z == 2
									nSize += 18
								EndIf
							Else
								nTamProd := Len(SB1->B1_COD) 
								If nTamProd > 15 .And. nSize < 15
									If nTamProd <= 20
										nSize := 16
									ElseIf nTamProd <= 25
										nSize := 31
									ElseIf nTamProd <= 30
										nSize := nTamProd * 1.5
									EndIf
								EndIf
							EndIf
							nSize	+= aCampos[z][2]
						EndIf
					Next z
					For ny := 1 to Len(aGantt[nx][2])
						If aGantt[nx][2][ny][1] >= dIni
							lInic := .T.
							nCol1 := nColIni+((aGantt[nx][2][ny][1]-dIni)*24*12)
							nCol1 += Val(Substr(aGantt[nx][2][ny][2],1,2))*12
						Else
							nCol1 := nColIni
							lInic := .F.
						EndIf
						If aGantt[nx][2][ny][3]<= dFim
							nCol2 := nColIni+((aGantt[nx][2][ny][3]-dIni)*24*12)
							nCol2 += Val(Substr(aGantt[nx][2][ny][4],1,2))*12
							lFinish := .T.
						Else
							nCol2 := nColIni+((dFim-dIni)*24*12)+96
							lFinish:=.F.
						EndIf
						nCol2:=If(nCol2<=nCol1+1,nCol1+1,nCol2)
						If 	( aGantt[nx][2][ny][1] >= dIni .And. aGantt[nx][2][ny][1] <= dFim ) .Or.;
							( aGantt[nx][2][ny][3] >= dIni .And. aGantt[nx][2][ny][3] <= dFim ) .Or.;
							( aGantt[nx][2][ny][1] <= dIni .And. aGantt[nx][2][ny][3] >= dFim )

							oBar := TPanel():New(nLin,nCol1,"",oPanel,, .T., .T.,,If(aGantt[nx][2][ny][6]!=Nil,aGantt[nx][2][ny][6],aGantt[nx][3]),nCol2-nCol1,4,.F.,.F. )
							If !Empty(aGantt[nx][2][ny][7])
	  							cBlock:= "{|oBar,x,y|"+AllTrim(aGantt[nx][2][ny][7])+"}"
								oBar:bLClicked := MontaBlock(cBlock)
							EndIf
							If len(aGantt[nx][2][ny])>=11 .And. !Empty(aGantt[nx][2][ny][11])
	  							cBlock:= "{|oBar,x,y|"+AllTrim(aGantt[nx][2][ny][11])+"}"
								oBar:bRClicked := MontaBlock(cBlock)
							EndIf

							If !Empty(aGantt[nx][2][ny][5]) .And. dFim >= aGantt[nx][2][ny][3] .And. dIni <= aGantt[nx][2][ny][3]
								Do Case
									Case aGantt[nx][2][ny][8] == 1
										cTextSay:= "{||'"+StrGantt(aGantt[nx][2][ny][5])+"'}"
										oSay	:= TSay():New( nLin-1,nCol2+10, MontaBlock(cTextSay) , oPanel , ,oArial,,,,.T.,aGantt[nx][2][ny][9],,,,,,,,)
									Case aGantt[nx][2][ny][8] == 2
										cTextSay:= "{||'"+StrGantt(aGantt[nx][2][ny][5])+"'}"
										oSay	:= TSay():New( nLin-5,nCol2-25, MontaBlock(cTextSay) , oPanel , ,oArial,,,,.T.,aGantt[nx][2][ny][9],,,,,,,,)
									Case aGantt[nx][2][ny][8] == 3
										oBar:cToolTip := aGantt[nx][2][ny][5]
								EndCase
							EndIf
							// desenha as tarefas predecessoras
							PreDecessora( aConfig[1] ,nLin ,nCol ,nColIni, dIni ,dFim ,nX ,{ aGantt[nx][1][1] ,nLin ,nCol1 ,nCol2 } ,aGantt ,aDep ,oPanel )

						EndIf

					Next ny
					nLin += 8
				Next nx
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			//?Cria o Gantt na escala 'horaria'                         ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			Case aConfig[1] == 0
				For dx := dIni to dFim
					nLin	:= 1
					@ nLin,nCol To nLin+26,nCol+145 Label "" Of oPanel1 PIXEL
					@ nLin,nCol To nLin+26+((nMaxTsk+1)*8),nCol+145 Label "" Of oPanel PIXEL
					If dx == dDateAtu
						@ -2,nCol-2+(Val(Substr(Time(),1,2))*6) To iIf( aPos[3]-28 > 27+((nMaxTsk+1)*8) ,aPos[3]-28 ,27+((nMaxTsk+1)*8) ) ,nCol+(Val(Substr(Time(),1,2))*6) Label "" Of oPanel PIXEL
					EndIf
					nLin += 6
					cTextSay:= "{||' "+SPACE(18)+DTOC(dx) +" '}"
					oSay := TSay():New( nLin,nCol, MontaBlock(cTextSay) , oPanel1 , ,oMonoAs,,,,.T.,CLR_BLACK,,,,,,,,)
					nLin += 10
					@ nLin,nCol Say "   2   4   6   8  10  12  14  16  18  20  22  " COLORS CLR_BLACK Of oPanel1 FONT oMonoAs PIXEL
					nLin += 20
					nCol += 144
				Next dx
				nCol := nColIni
				nLin := 5
				For nx := Round(MAX(nTsk,1),0) to MIN(Len(aGantt),Round((nTsk-1)+nMaxTsk,0))
					nSize := 7
					For z := 1 to Len(aCampos)
						If aConfig[z+1]
							If aRetRec <> Nil .And. z == 1 .And. !Empty(StrGantt(aGantt[nx][1][z]))
								bGetBox	:= &("{|| MarkRecurso(@aRetRec,'"+StrGantt(aGantt[nx][1][z])+"')}" )
					   			oChkBox	:=	TCheckBox():New(nLin-2,5,"",,oPanel, 10,10,,bGetBox,,,,,,.T.,,,)
				   				nSize	+=	7
							Endif
							cTextSay:= "{||'"+StrGantt(aGantt[nx][1][z])+"'}"
							oSay	:= TSay():New( nLin,nSize, MontaBlock(cTextSay) , oPanel , ,If(aGantt[nx][4]!=Nil,aGantt[nx][4],oArial),,,,.T.,CLR_BLACK,,,,,,,,)
							If !IsInCallStack("PMSC125")
								If aConfig[3] .AND. aConfig[4] .AND. aConfig[5] .AND. z == 2
									nSize += 18
								EndIf
							Else
								nTamProd := Len(SB1->B1_COD)
								If nTamProd > 15 .And. nSize < 15
									If nTamProd <= 20
										nSize := 16
									ElseIf nTamProd <= 25
										nSize := 31
									ElseIf nTamProd <= 30
										nSize := nTamProd * 1.5
									EndIf
								EndIf
							EndIf
							nSize	+= aCampos[z][2]
						EndIf
					Next z
					For ny := 1 to Len(aGantt[nx][2])
						If aGantt[nx][2][ny][1] >= dIni
							lInic := .T.
							nCol1 := nColIni+((aGantt[nx][2][ny][1]-dIni)*24*6)
							nCol1 += Val(Substr(aGantt[nx][2][ny][2],1,2))*6
						Else
							nCol1 := nColIni
							lInic := .F.
						EndIf
						If aGantt[nx][2][ny][3]<= dFim
							nCol2 := nColIni+((aGantt[nx][2][ny][3]-dIni)*24*6)
							nCol2 += Val(Substr(aGantt[nx][2][ny][4],1,2))*6
							lFinish := .T.
						Else
							nCol2 := nColIni+((dFim-dIni)*24*6)+48
							lFinish:=.F.
						EndIf
						nCol2:=If(nCol2<=nCol1+1,nCol1+1,nCol2)
						If 	( aGantt[nx][2][ny][1] >= dIni .And. aGantt[nx][2][ny][1] <= dFim ) .Or.;
							( aGantt[nx][2][ny][3] >= dIni .And. aGantt[nx][2][ny][3] <= dFim ) .Or.;
							( aGantt[nx][2][ny][1] <= dIni .And. aGantt[nx][2][ny][3] >= dFim )

							oBar := TPanel():New(nLin,nCol1,"",oPanel,, .T., .T.,,If(aGantt[nx][2][ny][6]!=Nil,aGantt[nx][2][ny][6],aGantt[nx][3]),nCol2-nCol1,4,.F.,.F. )
							If !Empty(aGantt[nx][2][ny][7])
	  							cBlock:= "{|oBar,x,y|"+AllTrim(aGantt[nx][2][ny][7])+"}"
								oBar:bLClicked := MontaBlock(cBlock)
							EndIf
							If len(aGantt[nx][2][ny])>=11 .And. !Empty(aGantt[nx][2][ny][11])
	  							cBlock:= "{|oBar,x,y|"+AllTrim(aGantt[nx][2][ny][11])+"}"
								oBar:bRClicked := MontaBlock(cBlock)
							EndIf

							If !Empty(aGantt[nx][2][ny][5]) .And. dFim >= aGantt[nx][2][ny][3] .And. dIni <= aGantt[nx][2][ny][3]
								Do Case
									Case aGantt[nx][2][ny][8] == 1
										cTextSay:= "{||'"+StrGantt(aGantt[nx][2][ny][5])+"'}"
										oSay	:= TSay():New( nLin-1,nCol2+10, MontaBlock(cTextSay) , oPanel , ,oArial,,,,.T.,aGantt[nx][2][ny][9],,,,,,,,)
									Case aGantt[nx][2][ny][8] == 2
										cTextSay:= "{||'"+StrGantt(aGantt[nx][2][ny][5])+"'}"
										oSay	:= TSay():New( nLin-5,nCol2-25, MontaBlock(cTextSay) , oPanel , ,oArial,,,,.T.,aGantt[nx][2][ny][9],,,,,,,,)
									Case aGantt[nx][2][ny][8] == 3
										oBar:cToolTip := aGantt[nx][2][ny][5]
								EndCase
							EndIf
							// desenha as tarefas predecessoras
							PreDecessora( aConfig[1] ,nLin ,nCol ,nColIni, dIni ,dFim ,nX ,{ aGantt[nx][1][1] ,nLin ,nCol1 ,nCol2 } ,aGantt ,aDep ,oPanel )

						EndIf

					Next ny
					nLin += 8
				Next nx
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			//?Cria o Gantt na escala 'diario'                         ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			Case aConfig[1] == 1
				For dx := dIni to dFim
					nLin	:= 1
					@ nLin,nCol To nLin+26,nCol+73 Label "" Of oPanel1 PIXEL
					@ nLin,nCol To nLin+26+((nMaxTsk+1)*8),nCol+73 Label "" Of oPanel PIXEL
					If dx == dDateAtu
						@ -2,nCol-2+(Val(Substr(Time(),1,2))*3) To iIf( aPos[3]-28 > 27+((nMaxTsk+1)*8) ,aPos[3]-28 ,27+((nMaxTsk+1)*8) ) ,nCol+(Val(Substr(Time(),1,2))*3) Label "" Of oPanel PIXEL
					EndIf
					nLin += 6
					cTextSay:= "{||' "+SPACE(7)+DTOC(dx)+SPACE(7)+" '}"
					oSay := TSay():New( nLin,nCol, MontaBlock(cTextSay) , oPanel1 , ,oMonoAs,,,,.T.,CLR_BLACK,,,,,,,,)
					nLin += 10
					@ nLin,nCol Say "      6    12    18     " COLORS CLR_BLACK Of oPanel1 FONT oMonoAs PIXEL
					nLin += 20
					nCol += 72
				Next dx
				nCol := nColIni
				nLin := 5
				For nx := Round(MAX(nTsk,1),0) to MIN(Len(aGantt),Round((nTsk-1)+nMaxTsk,0))
					nSize := 7
					For z := 1 to Len(aCampos)
						If aConfig[z+1]
							If aRetRec <> Nil .And. z == 1 .And. !Empty(StrGantt(aGantt[nx][1][z]))
								bGetBox	:= &("{|| MarkRecurso(@aRetRec,'"+StrGantt(aGantt[nx][1][z])+"')}" )
					   			oChkBox	:=	TCheckBox():New(nLin-2,5,"",,oPanel, 10,10,,bGetBox,,,,,,.T.,,,)
					   			nSize	+=	7
							Endif
							cTextSay:= "{||'"+StrGantt(aGantt[nx][1][z])+"'}"
							oSay	:= TSay():New( nLin,nSize, MontaBlock(cTextSay) , oPanel , ,If(aGantt[nx][4]!=Nil,aGantt[nx][4],oArial),,,,.T.,CLR_BLACK,,,,,,,,)
							If IsInCallStack("PmsMonit") .AND. aConfig[3] .AND. aConfig[4] .AND. aConfig[5] .AND. z == 2
								nSize += 18
							Else
								nTamProd := Len(SB1->B1_COD)
								If nTamProd > 15 .And. nSize < 15
									If nTamProd <= 20
										nSize := 16
									ElseIf nTamProd <= 25
										nSize := 31
									ElseIf nTamProd <= 30
										nSize := nTamProd * 1.5
									EndIf
								EndIf
							EndIf
							nSize	+= aCampos[z][2]
						EndIf
					Next z
					For ny := 1 to Len(aGantt[nx][2])
						If aGantt[nx][2][ny][1] >= dIni
							lInic := .T.
							nCol1 := nColIni+((aGantt[nx][2][ny][1]-dIni)*24*3)
							nCol1 += Val(Substr(aGantt[nx][2][ny][2],1,2))*3
						Else
							nCol1 := nColIni
							lInic := .F.
						EndIf
						If aGantt[nx][2][ny][3]<= dFim
							nCol2 := nColIni+((aGantt[nx][2][ny][3]-dIni)*24*3)
							nCol2 += Val(Substr(aGantt[nx][2][ny][4],1,2))*3
							lFinish := .T.
						Else
							nCol2 := nColIni+((dFim-dIni)*24*3)+24
							lFinish:=.F.
						EndIf
						nCol2:=If(nCol2<=nCol1+1,nCol1+1,nCol2)
						If 	( aGantt[nx][2][ny][1] >= dIni .And. aGantt[nx][2][ny][1] <= dFim ) .Or.;
							( aGantt[nx][2][ny][3] >= dIni .And. aGantt[nx][2][ny][3] <= dFim ) .Or.;
							( aGantt[nx][2][ny][1] <= dIni .And. aGantt[nx][2][ny][3] >= dFim )

							oBar := TPanel():New(nLin,nCol1,"",oPanel,, .T., .T.,,If(aGantt[nx][2][ny][6]!=Nil,aGantt[nx][2][ny][6],aGantt[nx][3]),nCol2-nCol1,4,.F.,.F. )
							If !Empty(aGantt[nx][2][ny][7])
	  							cBlock:= "{|oBar,x,y|"+AllTrim(aGantt[nx][2][ny][7])+"}"
								oBar:bLClicked := MontaBlock(cBlock)
							EndIf
							If len(aGantt[nx][2][ny])>=11 .And. !Empty(aGantt[nx][2][ny][11])
	  							cBlock:= "{|oBar,x,y|"+AllTrim(aGantt[nx][2][ny][11])+"}"
								oBar:bRClicked := MontaBlock(cBlock)
							EndIf

							If !Empty(aGantt[nx][2][ny][5]) .And. dFim >= aGantt[nx][2][ny][3] .And. dIni <= aGantt[nx][2][ny][3]
								Do Case
									Case aGantt[nx][2][ny][8] == 1
										cTextSay:= "{||'"+StrGantt(aGantt[nx][2][ny][5])+"'}"
										oSay	:= TSay():New( nLin-1,nCol2+10, MontaBlock(cTextSay) , oPanel , ,oArial,,,,.T.,aGantt[nx][2][ny][9],,,,,,,,)
									Case aGantt[nx][2][ny][8] == 2
										cTextSay:= "{||'"+StrGantt(aGantt[nx][2][ny][5])+"'}"
										oSay	:= TSay():New( nLin-5,nCol2-25, MontaBlock(cTextSay) , oPanel , ,oArial,,,,.T.,aGantt[nx][2][ny][9],,,,,,,,)
									Case aGantt[nx][2][ny][8] == 3
										oBar:cToolTip := aGantt[nx][2][ny][5]
								EndCase
							EndIf

							// desenha as tarefas predecessoras
							PreDecessora( aConfig[1] ,nLin ,nCol ,nColIni, dIni ,dFim ,nX ,{ aGantt[nx][1][1] ,nLin ,nCol1 ,nCol2 } ,aGantt ,aDep ,oPanel )

						EndIf

					Next ny
					nLin += 8
				Next nx
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			//?Cria o Gantt na escala 'semanal'                        ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			Case aConfig[1] == 2
				For dx := dIni to (dFim-1) Step 7
					nLin	:= 1
					@ nLin,nCol To nLin+26,nCol+2+(3*20) Label "" Of oPanel1 PIXEL
					@ nLin,nCol To nLin+26+((nMaxTsk+1)*8),nCol+2+(3*20) Label "" Of oPanel PIXEL
					If dDateAtu>=dx .And. dDateAtu<=(dx+6)
						@ -2,nCol-2+((dDateAtu-dx)*9)+((Val(Substr(Time(),1,2))/24)*9) To iIf( aPos[3]-28 > 27+((nMaxTsk+1)*8) ,aPos[3]-28 ,27+((nMaxTsk+1)*8) ) ,nCol+((dDateAtu-dx)*9)+((Val(Substr(Time(),1,2))/24)*9) Label "" Of oPanel PIXEL
					EndIf
					nLin += 6
					cTextSay:= "{||' "+DTOC(dx)+SPACE(12)+"'}"
					oSay := TSay():New( nLin,nCol, MontaBlock(cTextSay) , oPanel1 , ,oMonoAs,,,,.T.,CLR_BLACK,,,,,,,,)
					nLin += 10
					@ nLin,nCol Say STR0013 COLORS CLR_BLACK Of oPanel1 FONT oMonoAs PIXEL  //" D  S  T  Q  Q  S  S "
					nLin += 20
					nCol += 61
				Next dx
				nCol := nColIni
				nLin := 5
				For nx := Round(MAX(nTsk,1),0) to MIN(Len(aGantt),Round((nTsk-1)+nMaxTsk,0))
					nSize := 7
					For z := 1 to Len(aCampos)
						If aConfig[z+1]
							If aRetRec <> Nil .And. z == 1 .And. !Empty(StrGantt(aGantt[nx][1][z]))
								bGetBox	:= &("{|| MarkRecurso(@aRetRec,'"+StrGantt(aGantt[nx][1][z])+"')}" )
					   			oChkBox	:=	TCheckBox():New(nLin-2,5,"",,oPanel, 10,10,,bGetBox,,,,,,.T.,,,)
					   			nSize	+=	7
							Endif
							cTextSay:= "{||'"+StrGantt(aGantt[nx][1][z])+"'}"
							oSay	:= TSay():New( nLin,nSize, MontaBlock(cTextSay) , oPanel , ,If(aGantt[nx][4]!=Nil,aGantt[nx][4],oArial),,,,.T.,CLR_BLACK,,,,,,,,)
							If IsInCallStack("PmsMonit") .AND. aConfig[3] .AND. aConfig[4] .AND. aConfig[5] .AND. z == 2
								nSize += 18
							Else
								nTamProd := Len(SB1->B1_COD)
								If nTamProd > 15 .And. nSize < 15
									If nTamProd <= 20
										nSize := 16
									ElseIf nTamProd <= 25
										nSize := 31
									ElseIf nTamProd <= 30
										nSize := nTamProd * 1.5
									EndIf
								EndIf
							EndIf
							nSize	+= aCampos[z][2]
						EndIf
					Next z
					For ny := 1 to Len(aGantt[nx][2])
						If aGantt[nx][2][ny][1] >= dIni
							nCol1 := nColIni+((aGantt[nx][2][ny][1]-dIni)*9)
							nCol1 += (Val(Substr(aGantt[nx][2][ny][2],1,2))/24)*9
							lInic := .T.
						Else
							nCol1 := nColIni
							lInic := .F.
						EndIf
						If aGantt[nx][2][ny][3] <= dFim
							nCol2 := nColIni+((Min(aGantt[nx][2][ny][3],dFim)-dIni)*9)
							nCol2 += (Val(Substr(aGantt[nx][2][ny][4],1,2))/24)*9
							lFinish := .T.
						Else
							nCol2 := nColIni+((dFim-dIni)*9)+9
							lFinish := .F.
						EndIf
						nCol2:=If(nCol2<=nCol1+1,nCol1+1,nCol2)
						If 	( aGantt[nx][2][ny][1] >= dIni .And. aGantt[nx][2][ny][1] <= dFim ) .Or.;
							( aGantt[nx][2][ny][3] >= dIni .And. aGantt[nx][2][ny][3] <= dFim ) .Or.;
							( aGantt[nx][2][ny][1] <= dIni .And. aGantt[nx][2][ny][3] >= dFim )
							oBar := TPanel():New(nLin,nCol1,"",oPanel,, .T., .T.,,If(aGantt[nx][2][ny][6]!=Nil,aGantt[nx][2][ny][6],aGantt[nx][3]),nCol2-nCol1,4,.F.,.F. )
							If !Empty(aGantt[nx][2][ny][7])
	  							cBlock:= "{|oBar,x,y|"+AllTrim(aGantt[nx][2][ny][7])+"}"
								oBar:bLClicked := MontaBlock(cBlock)
							EndIf
							If len(aGantt[nx][2][ny])>=11 .And. !Empty(aGantt[nx][2][ny][11])
	  							cBlock:= "{|oBar,x,y|"+AllTrim(aGantt[nx][2][ny][11])+"}"
								oBar:bRClicked := MontaBlock(cBlock)
							EndIf

							If !Empty(aGantt[nx][2][ny][5]) .And. dFim >= aGantt[nx][2][ny][3] .And. dIni <= aGantt[nx][2][ny][3]
								Do Case
									Case aGantt[nx][2][ny][8] == 1
										cTextSay:= "{||'"+StrGantt(aGantt[nx][2][ny][5])+"'}"
										oSay	:= TSay():New( nLin-1,nCol2+10, MontaBlock(cTextSay) , oPanel , ,oArial,,,,.T.,aGantt[nx][2][ny][9],,,,,,,,)
									Case aGantt[nx][2][ny][8] == 2
										cTextSay:= "{||'"+StrGantt(aGantt[nx][2][ny][5])+"'}"
										oSay	:= TSay():New( nLin-5,nCol2-25, MontaBlock(cTextSay) , oPanel , ,oArial,,,,.T.,aGantt[nx][2][ny][9],,,,,,,,)
									Case aGantt[nx][2][ny][8] == 3
										oBar:cToolTip := aGantt[nx][2][ny][5]
								EndCase
							EndIf

							// desenha as tarefas predecessoras
							PreDecessora( aConfig[1] ,nLin ,nCol ,nColIni, dIni ,dFim ,nX ,{ aGantt[nx][1][1] ,nLin ,nCol1 ,nCol2 } ,aGantt ,aDep ,oPanel )

						EndIf
					Next ny
					nLin += 8
				Next nx
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			//?Cria o Gantt na escala 'mensal' 100%                    ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			Case aConfig[1] == 3
				dIni	:= CTOD("01/"+StrZero(MONTH(dIni),2,0)+"/"+StrZero(YEAR(dIni),4,0))
				nYear	:= YEAR(dIni)
				nMonthIni := MONTH(dIni)
				nMonthEnd := ((dFim-dIni)/30)+nMonthIni
				For nMes := nMonthIni to nMonthEnd
					nDias 	:= DAY(LastDay(CTOD("01/"+StrZero(nMes,2,0)+"/"+StrZero(nYear,4,0))))
					nLin	:= 1
					@ nLin,nCol To nLin+26,nCol+2+(3*(nDias)) Label "" Of oPanel1 PIXEL
					@ nLin,nCol To nLin+26+((nMaxTsk+1)*8),nCol+2+(3*(nDias)) Label "" Of oPanel PIXEL
					If nMes==Month(dDateAtu)
						@ -2 ,nCol-2+((dDateAtu-CTOD("01/"+StrZero(nMes,2,0)+"/"+StrZero(nYear,4,0)))*3)+(Val(Substr(Time(),1,2))/720) To iIf( aPos[3]-28 > 27+((nMaxTsk+1)*8) ,aPos[3]-28 ,27+((nMaxTsk+1)*8) ) ,nCol+((dDateAtu-CTOD("01/"+StrZero(nMes,2,0)+"/"+StrZero(nYear,4,0)))*3)+(Val(Substr(Time(),1,2))/720) Label "" Of oPanel PIXEL
					EndIf
					nLin += 6
					cTextSay:= "{||' "+aMeses[nMonthIni]+"/"+STRZERO(nYear,4,0)+"'}"
					oSay := TSay():New( nLin,nCol, MontaBlock(cTextSay) , oPanel1 , ,oMonoAs,,,,.T.,CLR_BLACK,,,,,,,,)
					nLin += 10
					@ nLin,nCol Say "    5        15        25" COLORS CLR_BLACK Of oPanel1 FONT oMonoAs PIXEL
					nLin += 20
					nCol += (nDias*3)+1
					nMonthIni++
					If nMonthIni > 12
						nYear++
						nMonthIni := 1
					EndIf
				Next nMes
				nCol := nColIni
				nLin := 5
				For nx := Round(MAX(nTsk,1),0) to MIN(Len(aGantt),Round((nTsk-1)+nMaxTsk,0))
					nSize := 7
					For z := 1 to Len(aCampos)
						If aConfig[z+1]
							If aRetRec <> Nil .And. z == 1 .And. !Empty(StrGantt(aGantt[nx][1][z]))
								bGetBox	:= &("{|| MarkRecurso(@aRetRec,'"+StrGantt(aGantt[nx][1][z])+"')}" )
				   				oChkBox	:=	TCheckBox():New(nLin-2,5,"",,oPanel, 10,10,,bGetBox,,,,,,.T.,,,)
				   				nSize	+=	7
							Endif
							cTextSay:= "{||'"+StrGantt(aGantt[nx][1][z])+"'}"
							oSay	:= TSay():New( nLin,nSize, MontaBlock(cTextSay) , oPanel , ,If(aGantt[nx][4]!=Nil,aGantt[nx][4],oArial),,,,.T.,CLR_BLACK,,,,,,,,)
							If IsInCallStack("PmsMonit") .AND. aConfig[3] .AND. aConfig[4] .AND. aConfig[5] .AND. z == 2
								nSize += 18
							Else
								nTamProd := Len(SB1->B1_COD)
								If nTamProd > 15 .And. nSize < 15
									If nTamProd <= 20
										nSize := 16
									ElseIf nTamProd <= 25
										nSize := 31
									ElseIf nTamProd <= 30
										nSize := nTamProd * 1.5
									EndIf
								EndIf
							EndIf
							nSize	+= aCampos[z][2]
						EndIf
					Next z
					For ny := 1 to Len(aGantt[nx][2])
						If aGantt[nx][2][ny][1] >= dIni
							nCol1 := nColIni+((aGantt[nx][2][ny][1]-dIni)*3)
							nCol1 += (Val(Substr(aGantt[nx][2][ny][2],1,2))/720)*3
							lInic := .T.
						Else
							nCol1 := nColIni
							lInic := .F.
						EndIf
						If aGantt[nx][2][ny][3] <= dFim
							nCol2 := nColIni+((aGantt[nx][2][ny][3]-dIni)*3)
							nCol2 += (Val(Substr(aGantt[nx][2][ny][4],1,2))/720)*3
							lFinish := .T.
						Else
							nCol2 := nColIni+((dFim-dIni)*3)
							lFinish := .F.
						EndIf
						nCol2:=If(nCol2<=nCol1+1,nCol1+1,nCol2)
						If 	( aGantt[nx][2][ny][1] >= dIni .And. aGantt[nx][2][ny][1] <= dFim ) .Or.;
							( aGantt[nx][2][ny][3] >= dIni .And. aGantt[nx][2][ny][3] <= dFim ) .Or.;
							( aGantt[nx][2][ny][1] <= dIni .And. aGantt[nx][2][ny][3] >= dFim )

							oBar := TPanel():New(nLin,nCol1,"",oPanel,, .T., .T.,,If(aGantt[nx][2][ny][6]!=Nil,aGantt[nx][2][ny][6],aGantt[nx][3]),nCol2-nCol1,4,.F.,.F. )
							If !Empty(aGantt[nx][2][ny][7])
	  							cBlock:= "{|oBar,x,y|"+AllTrim(aGantt[nx][2][ny][7])+"}"
								oBar:bLClicked := MontaBlock(cBlock)
							EndIf
							If len(aGantt[nx][2][ny])>=11 .And. !Empty(aGantt[nx][2][ny][11])
	  							cBlock:= "{|oBar,x,y|"+AllTrim(aGantt[nx][2][ny][11])+"}"
								oBar:bRClicked := MontaBlock(cBlock)
							EndIf

							If !Empty(aGantt[nx][2][ny][5]) .And. dFim >= aGantt[nx][2][ny][3] .And. dIni <= aGantt[nx][2][ny][3]
								Do Case
									Case aGantt[nx][2][ny][8] == 1
										cTextSay:= "{||'"+StrGantt(aGantt[nx][2][ny][5])+"'}"
										oSay	:= TSay():New( nLin-1,nCol2+10, MontaBlock(cTextSay) , oPanel , ,oArial,,,,.T.,aGantt[nx][2][ny][9],,,,,,,,)
									Case aGantt[nx][2][ny][8] == 2
										cTextSay:= "{||'"+StrGantt(aGantt[nx][2][ny][5])+"'}"
										oSay	:= TSay():New( nLin-5,nCol2-25, MontaBlock(cTextSay) , oPanel , ,oArial,,,,.T.,aGantt[nx][2][ny][9],,,,,,,,)
									Case aGantt[nx][2][ny][8] == 3
										oBar:cToolTip := aGantt[nx][2][ny][5]
								EndCase
							EndIf

							// desenha as tarefas predecessoras
							PreDecessora( aConfig[1] ,nLin ,nCol ,nColIni, dIni ,dFim ,nX ,{ aGantt[nx][1][1] ,nLin ,nCol1 ,nCol2 } ,aGantt ,aDep ,oPanel )

						EndIf
					Next ny
					nLin += 8
				Next nx
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			//?Cria o Gantt na escala 'mensal' 30%                     ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			Case aConfig[1] == 4
				dIni	:= CTOD("01/"+StrZero(MONTH(dIni),2,0)+"/"+StrZero(YEAR(dIni),4,0))
				nYear	:= YEAR(dIni)
				nMonthIni := MONTH(dIni)
				nMonthEnd := ((dFim-dIni)/30)+nMonthIni
				For nMes := nMonthIni to nMonthEnd
					nDias 	:= DAY(LastDay(CTOD("01/"+StrZero(nMes,2,0)+"/"+StrZero(nYear,4,0))))
					nLin	:= 1
					@ nLin,nCol To nLin+26,nCol+(nDias+1) Label "" Of oPanel1 PIXEL
					@ nLin,nCol To nLin+26+((nMaxTsk+1)*8),nCol+(nDias+1) Label "" Of oPanel PIXEL
					If nMes==Month(dDateAtu)
						@ -2,nCol-2+(dDateAtu-CTOD("01/"+StrZero(nMes,2,0)+"/"+StrZero(nYear,4,0)))+(Val(Substr(Time(),1,2))/720) To iIf( aPos[3]-28 > 27+((nMaxTsk+1)*8) ,aPos[3]-28 ,27+((nMaxTsk+1)*8) ) ,nCol+(dDateAtu-CTOD("01/"+StrZero(nMes,2,0)+"/"+StrZero(nYear,4,0)))+(Val(Substr(Time(),1,2))/720) Label "" Of oPanel PIXEL
					EndIf
					nLin += 6
					cTextSay:= "{||' "+aMeses[nMonthIni]+"/"+STRZERO(nYear,4,0)+"'}"
					oSay := TSay():New( nLin,nCol, MontaBlock(cTextSay) , oPanel1 , ,oArial,,,,.T.,CLR_BLACK,,,,,,,,)
					nLin += 10
					@ nLin,nCol Say "    15 " COLORS CLR_BLACK Of oPanel1 FONT oMonoAs PIXEL
					nLin += 20
					nCol += (nDias)
					nMonthIni++
					If nMonthIni > 12
						nYear++
						nMonthIni := 1
					EndIf
				Next nMes
				nCol := nColIni
				nLin := 5
				For nx := Round(MAX(nTsk,1),0) to MIN(Len(aGantt),Round((nTsk-1)+nMaxTsk,0))
					nSize := 7
					For z := 1 to Len(aCampos)
						If aConfig[z+1]
							If aRetRec <> Nil .And. z == 1 .And. !Empty(StrGantt(aGantt[nx][1][z]))
								bGetBox	:= &("{|| MarkRecurso(@aRetRec,'"+StrGantt(aGantt[nx][1][z])+"')}" )
								oChkBox	:=	TCheckBox():New(nLin-2,5,"",,oPanel, 10,10,,bGetBox,,,,,,.T.,,,)
						  		nSize	+=	7
							Endif
							cTextSay:= "{||'"+StrGantt(aGantt[nx][1][z])+"'}"
							oSay	:= TSay():New( nLin,nSize, MontaBlock(cTextSay) , oPanel , ,If(aGantt[nx][4]!=Nil,aGantt[nx][4],oArial),,,,.T.,CLR_BLACK,,,,,,,,)
							If IsInCallStack("PmsMonit") .And. aConfig[3] .AND. aConfig[4] .AND. aConfig[5] .AND. z == 2
								nSize += 18
							Else
								nTamProd := Len(SB1->B1_COD)
								If nTamProd > 15 .And. nSize < 15
									If nTamProd <= 20
										nSize := 16
									ElseIf nTamProd <= 25
										nSize := 31
									ElseIf nTamProd <= 30
										nSize := nTamProd * 1.5
									EndIf
								EndIf
							EndIf
							nSize	+= aCampos[z][2]
						EndIf
					Next z
					For ny := 1 to Len(aGantt[nx][2])
						If aGantt[nx][2][ny][1] >= dIni
							nCol1 := nColIni+((aGantt[nx][2][ny][1]-dIni))
							nCol1 += (Val(Substr(aGantt[nx][2][ny][2],1,2))/720)
							lInic := .T.
						Else
							nCol1 := nColIni
							lInic := .F.
						EndIf
						If aGantt[nx][2][ny][3] <= dFim
							nCol2 := nColIni+((aGantt[nx][2][ny][3]-dIni))
							nCol2 += (Val(Substr(aGantt[nx][2][ny][4],1,2))/720)
							lFinish := .T.
						Else
							nCol2 := nColIni+((dFim-dIni))
							lFinish := .F.
						EndIf
						nCol2:=If(nCol2<=nCol1+1,nCol1+1,nCol2)
						If 	( aGantt[nx][2][ny][1] >= dIni .And. aGantt[nx][2][ny][1] <= dFim ) .Or.;
							( aGantt[nx][2][ny][3] >= dIni .And. aGantt[nx][2][ny][3] <= dFim ) .Or.;
							( aGantt[nx][2][ny][1] <= dIni .And. aGantt[nx][2][ny][3] >= dFim )

							oBar := TPanel():New(nLin,nCol1,"",oPanel,, .T., .T.,,If(aGantt[nx][2][ny][6]!=Nil,aGantt[nx][2][ny][6],aGantt[nx][3]),nCol2-nCol1,4,.F.,.F. )
							If !Empty(aGantt[nx][2][ny][7])
	  							cBlock:= "{|oBar,x,y|"+AllTrim(aGantt[nx][2][ny][7])+"}"
								oBar:bLClicked := MontaBlock(cBlock)
							EndIf
							If len(aGantt[nx][2][ny])>=11 .And. !Empty(aGantt[nx][2][ny][11])
	  							cBlock:= "{|oBar,x,y|"+AllTrim(aGantt[nx][2][ny][11])+"}"
								oBar:bRClicked := MontaBlock(cBlock)
							EndIf

							If !Empty(aGantt[nx][2][ny][5]) .And. dFim >= aGantt[nx][2][ny][3] .And. dIni <= aGantt[nx][2][ny][3]
								Do Case
									Case aGantt[nx][2][ny][8] == 1
										cTextSay:= "{||'"+StrGantt(aGantt[nx][2][ny][5])+"'}"
										oSay	:= TSay():New( nLin-1,nCol2+10, MontaBlock(cTextSay) , oPanel , ,oArial,,,,.T.,aGantt[nx][2][ny][9],,,,,,,,)
									Case aGantt[nx][2][ny][8] == 2
										cTextSay:= "{||'"+StrGantt(aGantt[nx][2][ny][5])+"'}"
										oSay	:= TSay():New( nLin-5,nCol2-25, MontaBlock(cTextSay) , oPanel , ,oArial,,,,.T.,aGantt[nx][2][ny][9],,,,,,,,)
									Case aGantt[nx][2][ny][8] == 3
										oBar:cToolTip := aGantt[nx][2][ny][5]
								EndCase
							EndIf

							// desenha as tarefas predecessoras
							PreDecessora( aConfig[1] ,nLin ,nCol ,nColIni, dIni ,dFim ,nX ,{ aGantt[nx][1][1] ,nLin ,nCol1 ,nCol2 } ,aGantt ,aDep ,oPanel )

						EndIf
					Next ny
					nLin += 8
				Next nx
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			//?Cria o Gantt na escala bimestral                        ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			Case aConfig[1] == 5
				dIni	:= CTOD("01/"+StrZero(MONTH(dIni),2,0)+"/"+StrZero(YEAR(dIni),4,0))
				nYear	:= YEAR(dIni)
				nMonthIni := MONTH(dIni)
				nMonthEnd := ((dFim-dIni)/30)+nMonthIni
				For nMes := nMonthIni to nMonthEnd Step 2
					nDias 	:= DAY(LastDay(CTOD("01/"+StrZero(nMes,2,0)+"/"+StrZero(nYear,4,0))))+DAY(LastDay(CTOD("01/"+StrZero(nMes+1,2,0)+"/"+StrZero(If(nMes+1>12,nYear+1,nYear),4,0))))
					nLin	:= 1
					@ nLin,nCol To nLin+26,nCol+(nDias/2)+1 Label "" Of oPanel1 PIXEL
					@ nLin,nCol To nLin+26+((nMaxTsk+1)*8),nCol+(nDias/2)+1 Label "" Of oPanel PIXEL
					If nMes==Month(dDateAtu)
						@ -2,nCol-2+((dDateAtu-CTOD("01/"+StrZero(nMes,2,0)+"/"+StrZero(nYear,4,0)))/2)+(Val(Substr(Time(),1,2))/720)/2 To iIf( aPos[3]-28 > 27+((nMaxTsk+1)*8) ,aPos[3]-28 ,27+((nMaxTsk+1)*8) ) ,nCol+((dDateAtu-CTOD("01/"+StrZero(nMes,2,0)+"/"+StrZero(nYear,4,0)))/2)+(Val(Substr(Time(),1,2))/720)/2 Label "" Of oPanel PIXEL
					EndIf
					nLin += 6
     				cTextSay:= "{||' "+aMeses[nMonthIni]+"/"+STRZERO(nYear,4,0)+"'}"
					oSay := TSay():New( nLin,nCol, MontaBlock(cTextSay) , oPanel1 , ,oArial,,,,.T.,CLR_BLACK,,,,,,,,)
					nLin += 30
					nCol += (nDias/2)
					nMonthIni++
					nMonthIni++
					If nMonthIni > 12
						nYear++
						nMonthIni := 1
					EndIf
				Next nMes
				nCol := nColIni
				nLin := 5
				For nx := Round(MAX(nTsk,1),0) to MIN(Len(aGantt),Round((nTsk-1)+nMaxTsk,0))
					nSize := 7
					For z := 1 to Len(aCampos)
						If aConfig[z+1]
							If aRetRec <> Nil .And. z == 1 .And. !Empty(StrGantt(aGantt[nx][1][z]))
								bGetBox	:= &("{|| MarkRecurso(@aRetRec,'"+StrGantt(aGantt[nx][1][z])+"')}" )
				   				oChkBox	:=	TCheckBox():New(nLin-2,5,"",,oPanel, 10,10,,bGetBox,,,,,,.T.,,,)
				   				nSize	+=	7
							Endif
							cTextSay:= "{||'"+StrGantt(aGantt[nx][1][z])+"'}"
							oSay	:= TSay():New( nLin,nSize, MontaBlock(cTextSay) , oPanel , ,If(aGantt[nx][4]!=Nil,aGantt[nx][4],oArial),,,,.T.,CLR_BLACK,,,,,,,,)
							If IsInCallStack("PmsMonit") .AND. aConfig[3] .AND. aConfig[4] .AND. aConfig[5] .AND. z == 2
								nSize += 18
							Else
								nTamProd := Len(SB1->B1_COD)
								If nTamProd > 15 .And. nSize < 15
									If nTamProd <= 20
										nSize := 16
									ElseIf nTamProd <= 25
										nSize := 31
									ElseIf nTamProd <= 30
										nSize := nTamProd * 1.5
									EndIf
								EndIf
							EndIf
							nSize	+= aCampos[z][2]
						EndIf
					Next z
					For ny := 1 to Len(aGantt[nx][2])
						If aGantt[nx][2][ny][1] >= dIni
							nCol1 := nColIni+((aGantt[nx][2][ny][1]-dIni)/2)
							nCol1 += (Val(Substr(aGantt[nx][2][ny][2],1,2))/720)/2
							lInic := .T.
						Else
							nCol1 := nColIni
							lInic := .F.
						EndIf
						If aGantt[nx][2][ny][3] <= dFim
							nCol2 := nColIni+((aGantt[nx][2][ny][3]-dIni)/2)
							nCol2 += (Val(Substr(aGantt[nx][2][ny][4],1,2))/720)/2
							lFinish := .T.
						Else
							nCol2 := nColIni+((dFim-dIni)/2)
							lFinish := .F.
						EndIf
						nCol2:=If(nCol2<=nCol1+1,nCol1+1,nCol2)
						If 	( aGantt[nx][2][ny][1] >= dIni .And. aGantt[nx][2][ny][1] <= dFim ) .Or.;
							( aGantt[nx][2][ny][3] >= dIni .And. aGantt[nx][2][ny][3] <= dFim ) .Or.;
							( aGantt[nx][2][ny][1] <= dIni .And. aGantt[nx][2][ny][3] >= dFim )

							oBar := TPanel():New(nLin,nCol1,"",oPanel,, .T., .T.,,If(aGantt[nx][2][ny][6]!=Nil,aGantt[nx][2][ny][6],aGantt[nx][3]),nCol2-nCol1,4,.F.,.F. )
							If !Empty(aGantt[nx][2][ny][7])
	  							cBlock:= "{|oBar,x,y|"+AllTrim(aGantt[nx][2][ny][7])+"}"
								oBar:bLClicked := MontaBlock(cBlock)
							EndIf
							If len(aGantt[nx][2][ny])>=11 .And. !Empty(aGantt[nx][2][ny][11])
	  							cBlock:= "{|oBar,x,y|"+AllTrim(aGantt[nx][2][ny][11])+"}"
								oBar:bRClicked := MontaBlock(cBlock)
							EndIf

							If !Empty(aGantt[nx][2][ny][5]) .And. dFim >= aGantt[nx][2][ny][3] .And. dIni <= aGantt[nx][2][ny][3]
								Do Case
									Case aGantt[nx][2][ny][8] == 1
										cTextSay:= "{||'"+StrGantt(aGantt[nx][2][ny][5])+"'}"
										oSay	:= TSay():New( nLin-1,nCol2+10, MontaBlock(cTextSay) , oPanel , ,oArial,,,,.T.,aGantt[nx][2][ny][9],,,,,,,,)
									Case aGantt[nx][2][ny][8] == 2
										cTextSay:= "{||'"+StrGantt(aGantt[nx][2][ny][5])+"'}"
										oSay	:= TSay():New( nLin-5,nCol2-25, MontaBlock(cTextSay) , oPanel , ,oArial,,,,.T.,aGantt[nx][2][ny][9],,,,,,,,)
									Case aGantt[nx][2][ny][8] == 3
										oBar:cToolTip := aGantt[nx][2][ny][5]

								EndCase
							EndIf

							// desenha as tarefas predecessoras
							PreDecessora( aConfig[1] ,nLin ,nCol ,nColIni, dIni ,dFim ,nX ,{ aGantt[nx][1][1] ,nLin ,nCol1 ,nCol2 } ,aGantt ,aDep ,oPanel )

						EndIf

					Next ny
					nLin += 8
				Next nx
		EndCase

	EndIf

EndIf

Return oGantt


//-------------------------------------------------------------------
/*{Protheus.doc} preDecessora

encontra a predecessora da tarefa e faz o relacionamento

@param	nTipo - Escala (1-Diario,2-semanal,etc..
@param	nLin - posicao atual da linha
@param	nCol - posicao atual da coluna
@param	nColIni - posicao inicial da coluna da area do grafico
@param	dIni - Data de inicio corrente do relatorio
@param	dFim - Data de fim corrente do relatorio
@param	nPos - posicao atual no array aGantt da tarefa corrente
@param	aTarefa -  Dados da tarefa corrente
@param	aGantt - array que contem as informacoes das tarefas
@param	aDep -  array com os predecessores das tarefas
@param	oPanel - objeto Panel onde vai ser "desenhado"

@return

@author  Reynaldo Miyashita
@version P11
@since   19-11-2003

//-------------------------------------------------------------------
*/
Static Function PreDecessora( nTipo ,nLin ,nCol ,nColIni, dIni ,dFim ,nPos ,aTarefa ,aGantt ,aDep ,oPanel )

Local nPos1	:= 0
Local nX		:= 0
Local nY		:= 0
Local nZ		:= 0
Local nCol1	:= 0
Local nCol2	:= 0
Local nLinPre	:= 0

	// verifica se a tarefa tem predecessora
	nPos1 := aScan( aDep,{|aTar| aTar[1] == aGantt[nPos][1][1] })
	If nPos1 > 0
		// varre todas as tarefas predecessoras referentes a Tarefa
		For nZ := 1 to Len(aDep[nPos1][2])
			// Verifica se existe a tarefa predecessora.
			//
			// Se conter mais q 8 elementos, existe a identifica豫o se a tarefa ?prevista ou realizada.
			// Sen? ?o formato antigo e ser?mantido por seguran?
			If Len(aGantt[nPos ,01]) >8
				nX := aScan( aGantt ,{|aTar|aTar[01 ,01]+aTar[01 ,09] == aDep[nPos1 ,02 ,nZ ,01]+aGantt[nPos ,01 ,09] })
			Else
				nX := aScan( aGantt ,{|aTar|aTar[01 ,01] == aDep[nPos1 ,02 ,nZ ,01] })
			EndIf
			If nX > 0
				// dados da tarefa predecessora
				For nY := 1 to Len(aGantt[nX][2])
					Do Case
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
						//?Cria o Gantt na escala 'horario'                        ?
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
						Case nTipo == -1
							If aGantt[nx][2][ny][1] >= dIni
								lInic := .T.
								nCol1 := nColIni +((aGantt[nx][2][ny][1]-dIni)*24*12)
								nCol1 += Val(Substr(aGantt[nx][2][ny][2],1,2))*12
							Else
								nCol1 := nColIni
							EndIf
							If aGantt[nx][2][ny][3]<= dFim
								nCol2 := nColIni+((aGantt[nx][2][ny][3]-dIni)*24*12)
								nCol2 += Val(Substr(aGantt[nx][2][ny][4],1,2))*12
							Else
								nCol2 := nColIni+((dFim-dIni)*24*12)+96
					   		EndIf
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
						//?Cria o Gantt na escala 'horario'                        ?
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
						Case nTipo == 0
							If aGantt[nx][2][ny][1] >= dIni
								lInic := .T.
								nCol1 := nColIni +((aGantt[nx][2][ny][1]-dIni)*24*6)
								nCol1 += Val(Substr(aGantt[nx][2][ny][2],1,2))*6
							Else
								nCol1 := nColIni
							EndIf
							If aGantt[nx][2][ny][3]<= dFim
								nCol2 := nColIni+((aGantt[nx][2][ny][3]-dIni)*24*6)
								nCol2 += Val(Substr(aGantt[nx][2][ny][4],1,2))*6
							Else
								nCol2 := nColIni+((dFim-dIni)*24*6)+48
					   		EndIf
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
						//?Cria o Gantt na escala 'diario'                         ?
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
						Case nTipo == 1
							If aGantt[nx][2][ny][1] >= dIni
								lInic := .T.
								nCol1 := nColIni +((aGantt[nx][2][ny][1]-dIni)*24*3)
								nCol1 += Val(Substr(aGantt[nx][2][ny][2],1,2))*3
							Else
								nCol1 := nColIni
							EndIf
							If aGantt[nx][2][ny][3]<= dFim
								nCol2 := nColIni+((aGantt[nx][2][ny][3]-dIni)*24*3)
								nCol2 += Val(Substr(aGantt[nx][2][ny][4],1,2))*3
							Else
								nCol2 := nColIni+((dFim-dIni)*24*3)+24
					   		EndIf
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
						//?Cria o Gantt na escala 'semanal'                        ?
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
						Case nTipo == 2
							If aGantt[nx][2][ny][1] >= dIni
								nCol1 := nColIni+((aGantt[nx][2][ny][1]-dIni)*9)
								nCol1 += (Val(Substr(aGantt[nx][2][ny][2],1,2))/24)*9
							Else
								nCol1 := nColIni
							EndIf
							If aGantt[nx][2][ny][3] <= dFim
								nCol2 := nColIni+((Min(aGantt[nx][2][ny][3],dFim)-dIni)*9)
								nCol2 += (Val(Substr(aGantt[nx][2][ny][4],1,2))/24)*9
							Else
								nCol2 := nColIni+((dFim-dIni)*9)+9
							EndIf

						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
						//?Cria o Gantt na escala 'mensal' 100%                    ?
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
						Case nTipo == 3
							If aGantt[nx][2][ny][1] >= dIni
								nCol1 := nColIni+((aGantt[nx][2][ny][1]-dIni)*3)
								nCol1 += (Val(Substr(aGantt[nx][2][ny][2],1,2))/720)*3

							Else
								nCol1 := nColIni

							EndIf
							If aGantt[nx][2][ny][3] <= dFim
								nCol2 := nColIni+((aGantt[nx][2][ny][3]-dIni)*3)
								nCol2 += (Val(Substr(aGantt[nx][2][ny][4],1,2))/720)*3

							Else
								nCol2 := nColIni+((dFim-dIni)*3)

							EndIf
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
						//?Cria o Gantt na escala 'mensal' 30%                     ?
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
						Case nTipo == 4
							If aGantt[nx][2][ny][1] >= dIni
								nCol1 := nColIni+((aGantt[nx][2][ny][1]-dIni))
								nCol1 += (Val(Substr(aGantt[nx][2][ny][2],1,2))/720)

							Else
								nCol1 := nColIni

							EndIf
							If aGantt[nx][2][ny][3] <= dFim
								nCol2 := nColIni+((aGantt[nx][2][ny][3]-dIni))
								nCol2 += (Val(Substr(aGantt[nx][2][ny][4],1,2))/720)

							Else
								nCol2 := nColIni+((dFim-dIni))

							EndIf

						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
						//?Cria o Gantt na escala bimestral                        ?
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
						Case nTipo == 5
							If aGantt[nx][2][ny][1] >= dIni
								nCol1 := nColIni+((aGantt[nx][2][ny][1]-dIni)/2)
								nCol1 += (Val(Substr(aGantt[nx][2][ny][2],1,2))/720)/2

							Else
								nCol1 := nColIni

							EndIf
							If aGantt[nx][2][ny][3] <= dFim
								nCol2 := nColIni+((aGantt[nx][2][ny][3]-dIni)/2)
								nCol2 += (Val(Substr(aGantt[nx][2][ny][4],1,2))/720)/2

							Else
								nCol2 := nColIni+((dFim-dIni)/2)

							EndIf
					EndCase

					nLinPre :=  nLin - ( 8*( nPos - nX ) )

					//imprime a linha de relacionamento entre tarefas
					DrawRelation( aDep[nPos1][2][nZ][2] ,{ aDep[nPos1][2][nZ][1] ,nLinPre ,nCol1 ,nCol2 } ,aTarefa ,oPanel ,nColIni )

				Next nZ

			EndIf
		Next nY
	Endif

Return( NIL )


//-------------------------------------------------------------------
/*{Protheus.doc} DrawRelation

desenha o relacionamento entre tarefas

@param
@param	cTipo - Tipo de relacionamento ( "1" - fim no inicio,  "2" - inicio no inicio, ...)
@param	aPosTar1 - tarefa predecessora
@param	aPosTar2 - tarefa
@param	oPanel - objeto Panel onde vai ser "desenhado"
@param	nColIni - poiscao inicial da coluna da area do grafico

@return nulo

@author	Reynaldo Miyashita
@version 	P11
@since   	19/04/2013

//-------------------------------------------------------------------
*/
Static Function DrawRelation( cTipo ,aPosTar1 ,aPosTar2 ,oPanel ,nColIni )
Local nMinLi     := 0
Local nMaxLi     := 0
Local nMinCol    := 0
Local nMaxCol    := 0
Local nLinA      := 0
Local nLinB      := 0
Local lCimaBaixo := .T.
Local oBmp

	If aPosTar1[2] <= aPosTar2[2]
		nMinLi := aPosTar1[2]+0.5
		nMaxLi := aPosTar2[2]+0.5
		lCimaBaixo := .T.
	Else
		nMinLi := aPosTar2[2]+0.5
		nMaxLi := aPosTar1[2]+0.5
		lCimaBaixo := .F.
	Endif

	// se a posicao da coluna for menor que da area do grafico
	If aPosTar1[3] < nColIni
		aPosTar1[3] := nColIni
	EndIf

	// se a posicao da coluna for menor que da area do grafico
	If aPosTar2[3] < nColIni
		aPosTar2[3] := nColIni
	EndIf

	// se a posicao da coluna for menor que da area do grafico
	If aPosTar1[4] < nColIni
		aPosTar1[4] := nColIni
	EndIf

	// se a posicao da coluna for menor que da area do grafico
	If aPosTar2[4] < nColIni
		aPosTar2[4] := nColIni
	EndIf

	// Menor posicao da coluna
	If aPosTar1[3] <= aPosTar2[3]
		nMinCol := aPosTar1[3]
	Else
		nMinCol := aPosTar2[3]
	Endif

	// Maior posicao da coluna
	If aPosTar1[4] >= aPosTar2[4]
		nMaxCol := aPosTar1[4]
	Else
		nMaxCol := aPosTar2[4]
	Endif

	If nMinCol <> nMaxCol
		nLinA := aPosTar1[2]+0.5
		nLinB := aPosTar2[2]+0.5

		Do Case
			// fim no inicio
			Case cTipo == "1"
				If lCimaBaixo
					@ nLinA      ,aPosTar1[4]   To nLinA      ,aPosTar2[3]   Label "" Of oPanel PIXEL
					@ nMinLi     ,aPosTar2[3]   To nMaxLi-4 ,aPosTar2[3]+1 Label "" Of oPanel PIXEL
					If aPosTar2[3]-2 > nColIni
						@ nMaxLi-5.5 ,aPosTar2[3]-2 BITMAP oBmp RESNAME BMP_TRIANGULO_DOWN SIZE 11,11 NOBORDER Of oPanel PIXEL
					EndIf
				Else
					@ nLinA      ,aPosTar1[4]   To nLinA    ,aPosTar2[3]+1 Label "" Of oPanel PIXEL
					@ nMinLi+3   ,aPosTar2[3]   To nMaxLi+1 ,aPosTar2[3]+1 Label "" Of oPanel PIXEL
					If aPosTar2[3]-2 > nColIni
						@ nMinLi+2   ,aPosTar2[3]-2 BITMAP oBmp RESNAME BMP_TRIANGULO_UP SIZE 11,11 NOBORDER Of oPanel PIXEL
					EndIf
				Endif

			// inicio no inicio
			Case cTipo == "2"
				If nMinCol-5 < nColIni
					nMinCol := nColIni+5
				EndIf
				If aPosTar2[3]-5 < nColIni
					aPosTar2[3] := nColIni+5
				EndIf
				@ nLinA     ,nMinCol-5     To nLinA    ,aPosTar1[3]   Label "" Of oPanel PIXEL
				@ nMinLi -1 ,nMinCol-5     To nMaxLi+2 ,nMinCol-4     Label "" Of oPanel PIXEL
				@ nLinB     ,nMinCol-5     To nLinB    ,aPosTar2[3]-2 Label "" Of oPanel PIXEL
				If aPosTar2[3]-4 > nColIni
					@ nLinB-2     ,aPosTar2[3]-4 BITMAP oBmp RESNAME BMP_TRIANGULO_RIGHT SIZE 11,11 NOBORDER Of oPanel PIXEL
				EndIf

			// fim no fim
			Case cTipo == "3"
				@ nLinA    ,aPosTar1[4]     To nLinA    ,nMaxCol+5 Label "" Of oPanel PIXEL
				@ nMinLi-1 ,nMaxCol+4       To nMaxLi+2 ,nMaxCol+5 Label "" Of oPanel PIXEL
				@ nLinB    ,aPosTar2[4]+2   To nLinB    ,nMaxCol+5 Label "" Of oPanel PIXEL
				If aPosTar2[4]-1 > nColIni
					@ nLinB-2    ,aPosTar2[4]-1 BITMAP oBmp RESNAME BMP_TRIANGULO_LEFT   SIZE 11,11 NOBORDER Of oPanel PIXEL
				EndIf

			// inicio no fim
			Case cTipo == "4"
				If lCimaBaixo
					@ nLinA                      ,aPosTar1[3]-5 To nLinA                          ,aPosTar1[3]   Label "" Of oPanel PIXEL
					@ nMinLi                     ,aPosTar1[3]-6 To nMinLi+1+((nMaxLi-nMinLi)/2)   ,aPosTar1[3]-5 Label "" Of oPanel PIXEL
					@ nMinLi+((nMaxLi-nMinLi)/2) ,aPosTar2[4]+5 To (nMinLi-1)+((nMaxLi-nMinLi)/2) ,aPosTar1[3]-5 Label "" Of oPanel PIXEL
					@ nMinLi+((nMaxLi-nMinLi)/2) ,aPosTar2[4]+4 To nMaxLi+1                       ,aPosTar2[4]+5 Label "" Of oPanel PIXEL
					@ nLinB                      ,aPosTar2[4]+3 To nLinB                          ,aPosTar2[4]+5 Label "" Of oPanel PIXEL
				Else
					@ nLinA                      ,aPosTar1[3]-5 To nLinA                        ,aPosTar1[3]   Label "" Of oPanel PIXEL
					@ nMinLi-1                   ,aPosTar2[4]+4 To nMinLi+((nMaxLi-nMinLi)/2)   ,aPosTar2[4]+5 Label "" Of oPanel PIXEL
					@ nMinLi+((nMaxLi-nMinLi)/2) ,aPosTar1[3]-5 To (nMinLi)+((nMaxLi-nMinLi)/2) ,aPosTar2[4]+5 Label "" Of oPanel PIXEL
					@ nMinLi+((nMaxLi-nMinLi)/2) ,aPosTar1[3]-5 To nMaxLi+1                     ,aPosTar1[3]-4 Label "" Of oPanel PIXEL
					@ nLinB                      ,aPosTar2[4]+3 To nLinB                        ,aPosTar2[4]+5 Label "" Of oPanel PIXEL
				Endif
				If aPosTar2[4]-1 > nColIni
					@ nLinB-2    ,aPosTar2[4]-1 BITMAP oBmp RESNAME BMP_TRIANGULO_LEFT   SIZE 11,11 NOBORDER Of oPanel PIXEL
				EndIf
		EndCase
	EndIf

Return( NIL )


//-------------------------------------------------------------------
/*{Protheus.doc} PmsNxtGnt

Exibe uma tela com as configuracoes de visualizacao do Gantt

@param	cVersao
@param	oDlg
@param	aConfig
@param	dIni
@param	aGantt
@param	nTsk

@return nulo

@author	Edson Maricate
@version 	P11
@since   	09-02-2001

//-------------------------------------------------------------------
*/
Static Function PmsNxtGnt(cVersao,oDlg,aConfig,dIni,aGantt,nTsk)

Do Case
	Case aConfig[1] == 0 .Or. aConfig[1] == -1
		dIni += 1
	Case aConfig[1] == 1
		dIni += 2
	Case aConfig[1] == 2
		dIni += 14
	Case aConfig[1] == 3
		dIni += 35
		dIni := FirstDay(dIni)
	Case aConfig[1] == 4
		dIni += 70
		dIni := FirstDay(dIni)
	Case aConfig[1] == 5
		dIni += 130
		dIni := FirstDay(dIni)
EndCase

Return


//-------------------------------------------------------------------
/*{Protheus.doc} PmsPrvGnt

Exibe uma tela com as configuracoes de visualizacao do Gantt

@param	cVersao
@param	oDlg
@param	aConfig
@param	dIni
@param	aGantt
@param	nTsk

@return nulo

@author	Edson Maricate
@version 	P11
@since   	09-02-2001

//-------------------------------------------------------------------
*/
Static Function PmsPrvGnt(cVersao,oDlg,aConfig,dIni,aGantt,nTsk)

Do Case
	Case aConfig[1] == 0 .Or. aConfig[1] == -1
		dIni -= 1
	Case aConfig[1] == 1
		dIni -= 2
	Case aConfig[1] == 2
		dIni -= 14
	Case aConfig[1] == 3
		dIni -= 10
		dIni := FirstDay(dIni)
	Case aConfig[1] == 4
		dIni -= 40
		dIni := FirstDay(dIni)
	Case aConfig[1] == 5
		dIni -= 100
		dIni := FirstDay(dIni)
EndCase

Return


//-------------------------------------------------------------------
/*{Protheus.doc} GanttCmb1


@param	aCmbSeek
@param	aGantt
@param	oCombo1
@param	aCombo
@param	aTskCmb

@return nulo

@author	(desconhecido)
@version 	P11
@since   	(desconhecido)

//-------------------------------------------------------------------
*/
Static Function GanttCmb1(aCmbSeek,aGantt,oCombo1,aCombo,aTskCmb)
Local cAddText
Local nx
Local nZ

aCombo := {}
For nx := 1 to Len(aGantt)
	cAddText := ""
	For nZ := 1 to Len(aCmbSeek)
		If Len(aGantt[nx][1])>=aCmbSeek[nZ]
			cAddText += aGantt[nx][1][aCmbSeek[nZ]]+" "
		EndIf
	Next nZ
	If !Empty(cAddText)
		aAdd(aCombo,cAddText)
		aAdd(aTskCmb,nx)
	EndIf
Next nX

If !Empty(aCombo)
	oCombo1:SetItems(aCombo)
	oCombo1:Show()
Else
	oCombo1:Hide()
EndIf

Return


//-------------------------------------------------------------------
/*{Protheus.doc} GanttCmb2


@param	nGantt
@param	aGantt
@param	oCombo2
@param	aCombo2

@return nulo

@author	(desconhecido)
@version 	P11
@since   	(desconhecido)

//-------------------------------------------------------------------
*/
Static Function GanttCmb2(nGantt, aGantt, oCombo2, aCombo2)
Local ny := 0

DEFAULT nGantt := 0

aCombo2 := {}

If ValType(aGantt)=="A" .AND. Len(aGantt) > 0
	If nGantt <=0 .OR. nGantt > Len(aGantt)
		nGantt := Len(aGantt)
	EndIf
	If Len(aGantt[nGantt]) > 1
		If Len(aGantt[nGantt][2]) > 1
			For ny := 1 to Len(aGantt[nGantt][2])
				If !Empty(aGantt[nGantt][2][ny][5])
					aAdd(aCombo2,aGantt[nGantt][2][ny][5])
				Else
					aAdd(aCombo2, " " + DToC(aGantt[nGantt][2][ny][1]) + ;
					              "  " + aGantt[nGantt][2][ny][2] + " - " + ;
					              DToC(aGantt[nGantt][2][ny][3]) + "  " + ;
					              aGantt[nGantt][2][ny][4])
				EndIf
			Next
		EndIf
	EndIf
EndIf

If !Empty(aCombo2) .AND. Len(aGantt) > 0
	oCombo2:SetItems(aCombo2)
	oCombo2:Show()
Else
	oCombo2:Hide()
EndIf

Return


//-------------------------------------------------------------------
/*{Protheus.doc} StrGantt


@param	cText

@return cRet

@author	(desconhecido)
@version 	P11
@since   	(desconhecido)

//-------------------------------------------------------------------
*/
Function StrGantt(cText)
Local aTextos	:= {{"'",'"'},;
					 {CHR(10),""},;
					 {CHR(13)," "}}
Local cRet		:= ""
Local nPosChr	:= 0
Local nX		:= 0

cText	:=	Alltrim(cText)
For nX := 1 To Len(cText)
	If (nPosChr	:=	Ascan(aTextos,{|x| x[1]==Substr(cText,nX,1) })) > 0
		cRet	+=	aTextos[nPosChr][2]
	Else
		cRet	+=	Substr(cText,nX,1)
	Endif
Next nX

Return cRet


//-------------------------------------------------------------------
/*{Protheus.doc} MarkRecurso


@param	aRetRec
@param	cRecurso

@return lRet

@obs funcao macroexecutada na funcao PMSGantt


@author	(desconhecido)
@version 	P11
@since   	(desconhecido)

//-------------------------------------------------------------------
*/
Static Function MarkRecurso(aRetRec,cRecurso)
Local nPosRec	:=	Ascan(aRetRec,cRecurso)

If nPosRec > 0
	aRetRec := aDel(aRetRec,nPosRec)
	aRetRec := aSize(aRetRec,Len(aRetRec)-1)
	lRet	:=	.F.
Else
	AAdd(aRetRec,cRecurso)
	lRet	:=	.T.
Endif

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} PsqGntInt


@param	aGantt
@param	nTskPsq
@param	nInicio
@param	lDireto

@return lRet

@author	(desconhecido)
@version 	P11
@since   	(desconhecido)

//-------------------------------------------------------------------
*/
Static Function PsqGntInt(aGantt,nTskPsq,nInicio,lDireto)
Local lRet := .F.

DEFAULT nInicio := 0
DEFAULT lDireto := .F.

If lDireto .Or. ParamBox( { { 1,STR0016 ,Padr(aParam[1],200),"@" 	 ,""  ,""    ,"" ,120 ,.F. },;
				{5,STR0017,aParam[2],90,,.F.},;
				{5,STR0018,aParam[3],115,,.F.},;
				{5,STR0019,aParam[4],100,,.F.}	 }, STR0014, aParam )

	cPesqGnt := aParam[1]

	If !aParam[4]
		cTexto := UPPER(aParam[1])
	Else
		cTexto := aParam[1]
	EndIf

	If aParam[3] .And. !lDireto
		nInicio := 0
	EndIf

	If !Empty(cTexto)
		If !aParam[2]
			nTskPsq1 := aScan(aGantt,{|x|  aScan(x[1],{|y| AllTrim(cTexto)$AllTrim(y) })>0    },nInicio+1)
			nTskPsq2 := aScan(aGantt,{|x|  aScan(x[2],{|y| AllTrim(cTexto)$AllTrim(y[5]) })>0    },nInicio+1)
			If nTskPsq1 >0 .And. nTskPsq2 > 0
				nTskPsq := Min(nTskPsq1,nTskPsq2)
			Else
				nTskPsq := Max(nTskPsq1,nTskPsq2)
			EndIf
			lRet := (nTskPsq>0)
		Else
			nTskPsq1 := aScan(aGantt,{|x|  aScan(x[1],{|y| AllTrim(y)=AllTrim(cTexto) })>0    },nInicio+1)
			nTskPsq2 := aScan(aGantt,{|x|  aScan(x[2],{|y| AllTrim(y[5])=AllTrim(cTexto) })>0    },nInicio+1)
			If nTskPsq1 >0 .And. nTskPsq2 > 0
				nTskPsq := Min(nTskPsq1,nTskPsq2)
			Else
				nTskPsq := Max(nTskPsq1,nTskPsq2)
			EndIf
			lRet := (nTskPsq>0)
		EndIf
		If !lRet
			Aviso(STR0014,STR0020+AllTrim(cTexto)+STR0021,{"Ok"},2)
		EndIf
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} GanttSave


@param	dIni
@param	aGantt
@param	aCampos
@param	aDep
@param	aCmbSeek
@param	cText
@param	aConfig

@return nulo

@author	(desconhecido)
@version 	P11
@since   	(desconhecido)

//-------------------------------------------------------------------
*/
Function GanttSave(dIni,aGantt,aCampos,aDep,aCmbSeek,cText,aConfig)
Local aRet		:= {}
Local aSave	:= {}

MakeDir("\GANTT\")

If ParamBox({	{6,STR0022,SPACE(50),"","","", 55 ,.T.,STR0024+" .GGR |*.GGR","SERVIDOR\GANTT\"} },STR0023,@aRet,,,,,,,,.F.)

	If !(".GGR"$UPPER(aRet[1]))
		aRet[1] := AllTrim(aRet[1])+".GGR"
	EndIf
	If !("\"$aRet[1])
		aRet[1] := "\GANTT\"+aRet[1]
	EndIf

	aSave := {aGantt,dIni,aCampos,aDep,aCmbSeek,cText,aConfig}
	__VSave(aSave,aRet[1])

EndIf

Return


//-------------------------------------------------------------------
/*{Protheus.doc} GanttLoad


@param	dIni
@param	aGantt
@param	aCampos
@param	aDep
@param	aCmbSeek
@param	cText
@param	aConfig

@return lRet

@author	(desconhecido)
@version 	P11
@since   	(desconhecido)

//-------------------------------------------------------------------
*/
Function GanttLoad(dIni,aGantt,aCampos,aDep,aCmbSeek,cText,aConfig)
Local aLoad	:= {}
Local aRet		:= {}
Local lRet		:= .F.

MakeDir("\GANTT\")

If ParamBox({	{6,STR0025 ,SPACE(50),"","FILE(mv_par01)","", 55 ,.T.,STR0024+" .GGR |*.GGR","SERVIDOR\GANTT\"} },STR0023,@aRet,,,,,,,,.F.)
	If !(".GGR"$UPPER(aRet[1]))
		aRet[1] := AllTrim(aRet[1])+".GGR"
	EndIf
	If !("\"$aRet[1])
		aRet[1] := "\GANTT\"+aRet[1]
	EndIf
	If File(aRet[1])
		aLoad := __VRestore(aRet[1])
		If Len(aLoad) == 7
			aGantt	:= aLoad[1]
			dIni 		:= aLoad[2]
			aCampos	:= aLoad[3]
			aDep		:= aLoad[4]
			aCmbSeek	:= aLoad[5]
			cText		:= aLoad[6]
			aConfig	:= aLoad[7]
			lRet := .T.
		Else
			Aviso(STR0026,STR0027 ,{STR0028},2)
		EndIf
	Else
		Aviso(STR0029,STR0030 ,{STR0028},2)
	Endif
EndIf

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} CBXVld

@param	oDlg
@param	oGantt
@param	oCbx
@param	oCombo2
@param	aTskCmb
@param	aCombo2
@param	nTsk
@param	dIni
@param	dFim
@param	aPos
@param	aGantt
@param	aConfig
@param aCampos
@param	aDep
@param	cText
@param	aRetRec
@param	lProject

@return verdadeiro

@author	(desconhecido)
@version 	P11
@since   	(desconhecido)

//-------------------------------------------------------------------
*/
Static Function CBXVld( oDlg ,oGantt ,oCbx ,oCombo2 ,aTskCmb ,aCombo2 ,nTsk ,dIni ,dFim ,aPos ,aGantt ,aConfig ,aCampos ,aDep ,cText ,aRetRec, lProject )
Local lContinua := .F.

DEFAULT nTsk 		:= 0
DEFAULT lProject	:= .T.

	If aTskCmb == NIL .OR. ValType(aTskCmb) <> "A"
		aTskCmb := {}
	EndIf
	If aGantt == NIL .OR. ValType(aGantt) <> "A"
		aGantt := {}
	EndIf

	oGantt:Hide()

	If ValType(aTskCmb) == "A" .and. Len(aTskCmb) >= oCbx:nAT
		If ValType(aGantt) == "A" .and. (nTsk > 0 .AND. Len(aGantt) >= nTsk)
			If ValType(aGantt[nTsk]) == "A" .AND. Len( aGantt[nTsk] ) > 1
				If ValType(aGantt[nTsk][2]) == "A" .AND. Len( aGantt[nTsk][2] ) > 0
					If ValType(aGantt[nTsk][2][1]) == "A" .AND. Len( aGantt[nTsk][2][1] ) > 0
						lContinua := .T.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If lContinua

		MsFreeObj(oGantt,.T.)

		nTsk := aTskCmb[oCbx:nAT]
		dIni := aGantt[nTsk][2][1][1]
		PmsGantt(aGantt,aConfig,dIni,dFim,oDlg,aPos,aCampos,@nTsk,aDep,cText,@oGantt,.T.,,@aRetRec,lProject)

		GanttCmb2(nTsk,aGantt,@oCombo2,aCombo2)

    EndIf

	oGantt:Show()

Return( .T. )


//-------------------------------------------------------------------
/*{Protheus.doc} Combo2Vld

@param	oDlg
@param	oGantt
@param	oCombo2
@param	nTsk
@param	dIni
@param	dFim
@param	aPos
@param	aGantt
@param	aConfig
@param aCampos
@param	aDep
@param	cText
@param	aRetRec
@param	lProject


@return verdadeiro

@author	(desconhecido)
@version 	P11
@since   	(desconhecido)

//-------------------------------------------------------------------
*/
Static Function Combo2Vld( oDlg ,oGantt ,oCombo2 ,nTsk ,dIni ,dFim ,aPos ,aGantt ,aConfig ,aCampos ,aDep ,cText ,aRetRec ,lProject )
Local lContinua := .F.

DEFAULT nTsk 		:= 0
DEFAULT lProject	:= .T.

	If aGantt == NIL .OR. ValType(aGantt) <> "A"
		aGantt := {}
	EndIf

	oGantt:Hide()

	If ValType(aGantt) == "A" .and. (nTsk > 0  .AND. Len(aGantt) >= nTsk)
		If ValType(aGantt[nTsk]) == "A" .AND. Len( aGantt[nTsk] ) > 1
			If ValType(aGantt[nTsk][2]) == "A" .AND. Len( aGantt[nTsk][2] ) >= oCombo2:nAT
				If ValType(aGantt[nTsk][2][oCombo2:nAT]) == "A" .AND. Len( aGantt[nTsk][2][oCombo2:nAT] ) > 0

					lContinua := .T.

				EndIf
			EndIf
		EndIf
	EndIf

	If lContinua
		MsFreeObj(oGantt,.T.)

		dIni := aGantt[nTsk][2][oCombo2:nAT][1]
		PmsGantt( aGantt ,aConfig ,dIni ,dFim ,oDlg ,aPos ,aCampos ,@nTsk ,aDep ,cText ,@oGantt ,.T. ,,@aRetRec,lProject)
	EndIf

	oGantt:Show()

Return( .T. )
