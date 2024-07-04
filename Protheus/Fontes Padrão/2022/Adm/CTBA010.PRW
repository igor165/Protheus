#include "ctba010.ch"
#include "protheus.ch"
#include "fweventviewconsts.ch"
#include "FWLIBVERSION.CH"

Static __lEAIC012   := NIL
Static __lPIMS      := NIL
Static __lEAIC010   := NIL

//Metricas apenas em Lib a partir de 20210517 e Binario 19.3.0.6
Static __lMetric	:= NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA010   ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao do Calendario Contabil                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA010()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA010(xAutoCab,xAutoItens,nOpcAuto)

PRIVATE aRotina := MenuDef()

PRIVATE cCadastro := OemtoAnsi(STR0006)	//"Calendario Contabil"
Private lExibMsg   := .F.   //variavel a ser utilizada no ctba140

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis para rotina automatica    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Private lAtfAuto   := ( ValType(xAutoCab) == "A"  .And. ValType(xAutoItens) == "A" )
Private aAutoCab   := {}
Private aAutoItens := {}

SetKey(VK_F12, { || Pergunte("CTB010", .T.) })

//Carrega as variaveis estaticas
LoadVar010()

If lAtfAuto
	aAutoCab		:= xAutoCab
	aAutoItens		:= xAutoItens
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"CTG")
Else
	mBrowse( 6, 1,22,75,"CTG")
EndIf

SetKey(VK_F12, Nil)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB010CAL ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 17.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe na tela o calendario e a getdados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb010Cal(cAlias,nReg,nOpc)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do Registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb010Cal(cAlias, nReg, nOpc)

Local aSaveArea:= GetArea()
Local cExerc
Local dData
Local nOpca 	:= 0
Local oDlg, oCalend
Local oGet
Local lRet := .T.

Local aWizCalen
Local aWizPanCal
Local aDatas, aTpPer,aDadCalen
Local bFinalWiz
Local aArea, aScreen, 	nWStage, nHStage
Local nX
Local nI
Local nA
Local oPnlBot, oSay, oButton
Local aColumns, aWindows
Local aAux, aDadosCale, cCodCale, cExerCale, oTreeCal
Local aDadosMoed, oTreeMoed
Local aDadoAmCal, oTreeAmar
Local lDeleta := .T.

Private aTELA[0][0],aGETS[0],aHeader[0]
Private aCols	:= {}
Private nUsado := 0
Private nPosDtIni, nPosDtFim, nPosStatus
Private cCalendCTB

Pergunte("CTB010", .F.)

DbSelectArea("CTG")
dbSetOrder(1)

//Ponto de entrada para bloquear o calendário quando executado por outro processo
If ExistBlock("CT010BLI")
	lRet := ExecBlock("CT010BLI",.F.,.F.,{nOpc})

	If ValType(lRet) <> "L"
		lRet := .T.
	Endif
Endif

If lRet

	If lAtfAuto .And. nOpc != 5
		nPosExe     := Ascan(aAutoCab,{|aCampo| Alltrim(aCampo[1]) == "CTG_EXERC" })
		nPosCalend  := Ascan(aAutoCab,{|aCampo| Alltrim(aCampo[1]) == "CTG_CALEND" })
		If nPosExe > 0 .And. nPosCalend > 0
			cExerc	    := aAutoCab[nPosExe][2]
			cCalendCTB	:= aAutoCab[nPosCalend][2]
		Else
			Help(" ",1,"CTB010AUTO2",,STR0045,3,1)//"Campos de Exercício e Código do Calendário são obrigatórios"
			lRet := .F.
		EndIf
	ElseIf nOpc == 3
		cExerc	:= Str(Year(dDataBase),4)
		cCalendCTB	:= CriaVar("CTG_CALEND")
	Else
		cExerc	:= CTG->CTG_EXERC
		cCalendCTB	:= CTG->CTG_CALEND
	EndIf

	If !lAtfAuto

		If MV_PAR01 == 1  .Or. nOpc == 4 .Or. nOpc == 5 //MODO TRADICIONAL
			DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) FROM 9,0 TO 23,80 OF oMainWnd //"Calendario Contabil"
	
				@ 005,010 Say OemToAnsi(STR0008) OF oDlg PIXEL
				@ 005,045 MSGET oCalendCTB VAR cCalendCTB When nOpc == 3 Valid NaoVazio(cCalendCTB) /*.AND. Ct010DgCod(@ccalendctb,@oCalendCTB)*/  .and. Ct010Calend(cCalendCTB,nOpc) .And. FreeForUse("CTG",cCalendCTB) SIZE 020,08 OF oDlg PIXEL

				@ 005,100 Say OemToAnsi(STR0007) OF oDlg PIXEL
				@ 005,150 MSGET cExerc When nOpc == 3 Valid NaoVazio(cExerc) SIZE 035,08 OF oDlg PIXEL

				oCalend:=MsCalend():New(20,0,oDlg)

				oCalend:bChange := {|| At010ChgDia(@oCalend,@oGet,@dData), oDlg:Refresh()}

				// Integração SIGAPFS x SIGAFIN - Desabilita exclusão de linhas
				IIf( FindFunction("JExcLinCTG"), lDeleta := JExcLinCTG() , lDeleta := .T. )

				FillGetDados(nOpc, "CTG") 
				
				AjustaHead() // Ajuste de aHeader para retirada dos campos Alias WT e Recno WT da tela Inclusão/Alteração tradicional
				Ctb010Acols(nOpc,cExerc,cCalendCTB)

				oGet := MSGetDados():New(020,140,86,314,nOpc,"Ct010LinOK","Ct010TudOK","+CTG_PERIOD", lDeleta)

				DEFINE SBUTTON FROM 090, 260 TYPE 1 ACTION (nOpca := 1,;
				If(Ct010TudOk(nOpc) .and. Ctb010Grava(nOpc, cExerc, cCalendCTB), oDlg:End(), nOpca := 0)) ENABLE Of oDlg

				DEFINE SBUTTON FROM 090, 290 TYPE 2 ACTION oDlg:End() ENABLE Of oDlg

			ACTIVATE MSDIALOG oDlg CENTERED

		ElseIf nOpc == 2 //visualizar quando por assistente

			aArea			:= GetArea()
			aScreen 		:= MsAdvSize(.F.)	//GetScreenRes()
			nWStage 		:= (aScreen[3] * 2) //aScreen[1]-65
			nHStage 		:= (aScreen[4] * 2)	//aScreen[2]-215

			DEFINE DIALOG oDlg TITLE cCadastro SIZE nWStage,nHStage PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

			//Painel inferior
			oPnlBot := TPanel():New(01,01,,oDlg,,,,,,200,10,.F.,.F.)
			oPnlBot:Align := CONTROL_ALIGN_BOTTOM
			//Clique com o botão direito
		   	oSay := TSay():New( 10, 20, MontaBlock("{||'"+STR0009+"'}"),oPnlBot,, /*oFont*/, .F., .F., .F., .T.,,, 20/*nLarguraSay*/, 10, .F., .F., .F., .F., .F. )  //"Clique com Botao Direito para Visualizar"
			oSay:Align := CONTROL_ALIGN_ALLCLIENT
		   	//Botão Sair
		   	oButton := TButton():New(0,0,STR0042,oPnlBot,{|| oDlg:End() },30,10,,,,.T.,,"",,,,)		//"Sair"
			oButton:Align := CONTROL_ALIGN_RIGHT

			aColumns := {"Col01","Col02","Col03"}
			aWindows := { 	{	{STR0008,{||},NIL},;  //"Calendario"
								{STR0010,{||},NIL} ;  //"Moeda"
							},;
							{;
								{STR0011,{||},NIL};  //"Moeda x Calendario"
							},;
							{;
								{STR0012,{||},NIL};  //"Cambio"
							};
						}

			Ctb010Layer(oDlg,aColumns,aWindows)

			aDadosCale := {}
			dbSelectArea("CTG")
			dbSetOrder(1)
			dbSeek(xFilial("CTG"))
			While CTG->(!Eof() .And. CTG_FILIAL == xFilial("CTG") )
				cCodCale := CTG->CTG_CALEND
				cExerCale := CTG->CTG_EXERC
				aAux := {}
				While CTG->(!Eof() .And. CTG_FILIAL == xFilial("CTG") .And. CTG_CALEND == cCodCale )
					aAdd(aAux, { STR0013+CTG->CTG_PERIOD+STR0014+DTOC(CTG->CTG_DTINI)+STR0015+DTOC(CTG->CTG_DTFIM),"CTG"+cCodCale+cExerCale+CTG->CTG_PERIOD,{|oTree|TreeVisual(oTree)} } )  //"Periodo "###" de : "###" ate : "
					CTG->(dbSkip())
				EndDo
				aAdd(aDadosCale, { cCodCale+STR0016+cExerCale, "CTG"+cCodCale, {|oTree|TreeVisual(oTree)}, aClone(aAux) })  //" - Exercicio : "
			EndDo
			oTreeCal := Ctb010Tree(aWindows[1,1,3], aDadosCale)

			aDadosMoed := {}
			dbSelectArea("CTO")
			dbSetOrder(1)
			dbSeek(xFilial("CTO"))
			While CTO->(!Eof() .And. CTO_FILIAL == xFilial("CTO") )
				cCodMoed := CTO->CTO_MOEDA
				cDesMoed := CTO->CTO_DESC
				CTO->(dbSkip())
				aAdd(aDadosMoed, { cCodMoed+"-"+cDesMoed, "CTO"+cCodMoed, {|oTree|TreeVisual(oTree)} })
			 EndDo
			oTreeMoed := Ctb010Tree(aWindows[1,2,3], aDadosMoed)

			dbSelectArea("CTE")
			dbSetOrder(1)

			aDadoAmCal := {}
			For nX := 1 TO Len(aDadosMoed)
				cCodMoed := Left(aDadosMoed[nX, 1], Len(CTO->CTO_MOEDA))
				dbSeek(xFilial("CTE")+cCodMoed)
				aAux := {}
				While CTE->(!Eof() .And. CTE_FILIAL == xFilial("CTE") .And. CTE_MOEDA == cCodMoed )
					aAdd(aAux, { STR0008+" : "+CTE->CTE_CALEND,"CTE"+cCodMoed+CTE->CTE_CALEND,{|oTree|TreeVisual(oTree)} } )  //"Calendario"
					CTE->(dbSkip())
				EndDo
				aAdd(aDadoAmCal, { STR0010+" : "+cCodMoed, "CTE"+cCodMoed, {|oTree|TreeVisual(oTree)}, aClone(aAux) })  //"Moeda"
			Next
			oTreeAmar := Ctb010Tree(aWindows[2,1,3], aDadoAmCal)

			Ctb010Camb(aWindows[3,1,3])

			ACTIVATE DIALOG oDlg CENTERED

			RestArea(aArea)
		ElseIf nOpc == 3  //ASSISTENTE SOMENTE PARA INCLUSAO
	    	Ctb010Wiz()
			MBrChgLoop(.F.)
		EndIf
	Else
		CTB010Ahead()
		If (__lEAIC010)
			nPosDtIni  := GdFieldPos("CTG_DTINI")
			nPosDtFim  := GdFieldPos("CTG_DTFIM")
			nPosStatus := GdFieldPos("CTG_STATUS")

			If MsGetDAuto(aAutoItens, {|| Ct010LinOK()}, {|| CT010AutoOk(nOpc) .and. Ct010TudOK()}, aAutoCab, nOpc)
				Ctb010Grava(nOpc, cExerc, cCalendCTB)
			EndIf
		Else
			//aCols := aAutoItens
			For nA := 01 To Len(aAutoItens)
				AAdd(aCols, {})
				For nI := 01 To Len(aAutoItens[nA])
					If ValType(aAutoItens[nA][nI]) == "A"					
						AAdd(aCols[Len(aCols)], aAutoItens[nA][nI, 02])
					Else
						AAdd(aCols[Len(aCols)], aAutoItens[nA][nI])
					EndIf
				Next nI
				AAdd(aCols[Len(aCols)], .F.)
			Next nA

			nPosDtIni  := Ascan(aHeader,{|x|Alltrim(x[2]) = "CTG_DTINI"})
			nPosDtFim  := Ascan(aHeader,{|x|Alltrim(x[2]) = "CTG_DTFIM"})
			nPosStatus := Ascan(aHeader,{|x|Alltrim(x[2]) = "CTG_STATUS"})
					
			If lRet
				lRet := CT010AutoOk(nOpc)
			Endif
			
			If lRet 		
				Ctb010Grava(nOpc, cExerc, cCalendCTB)				
			EndIf
		EndIf
	EndIf
EndIf

//Ponto de entrada para desbloquear calendario na mesma thread
If ExistBlock("CT010BLF")
	ExecBlock("CT010BLF",.F.,.F.)
Endif

RestArea(aSaveArea)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB010WIZ ³ Autor ³ Leandro F. Dourado    ³ Data ³25.10.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe na tela o calendario e a getdados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb010Cal(cAlias,nReg,nOpc)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do Registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb010Wiz(lNovaTela,aWizCalen,aWizPanCal,aPanel,nWiz)

Local nOpca 			:= 0
Local oGet
Local cExerc			:= Str(Year(dDataBase),4)
Local aDatas, aTpPer,aDadCalen
Local bFinalWiz
Local nA,nB,nC,nD,nE	//variaveis utilizadas para evitar array out of bounds ao utilizar o wizard
Local nX				:= 0
Local lOK				:= .F.

DEFAULT nWiz		:= 0
DEFAULT lNovaTela 	:= .F.
DEFAULT aWizCalen 	:= {}
DEFAULT aWizPanCal 	:= {}
DEFAULT aPanel 		:= {}

If nWiz == 0
	Private aHeader	:= {}
	Private aCols		:= {}
	Private aHeaderSv	:= {{},{},{}}		// Array para salvar aHeaders
	Private aColsSv	:= {{},{},{}}		// Array para salvar aCols
EndIf

If lNovaTela
	Private aTELA[0][0],aGETS[0]
	Private nUsado 	:= 4
	Private nPosDtIni, nPosDtFim, nPosStatus
	Private cCalendCTB:= CriaVar("CTG_CALEND")
	Private cCadastro := OemtoAnsi(STR0006) //"Cadastro Calendario Contabil"
Endif

	CTB010Ahead(.T.)
	Ctb010Acols(3,cExerc,cCalendCTB,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array aWizCalen - Estrutura:                        ³
//³ Posicao 1 - Titulo                                  ³
//³         2 - Mensagem Explicativa                    ³
//³         3 - bNext                                   ³
//³         4 - bFinish                                 ³
//³         5 - lPanel                                  ³
//³         6 - lNoFist                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nWiz == 0
	aWizPanCal  		:= {}
	aPanel				:= {}
	aAdd(aWizCalen, cCadastro)
	aAdd(aWizCalen, STR0017+cCadastro+STR0018)  //"Este assistente do "###" vai lhe orientar no preenchimento dos dados."
	aAdd(aWizCalen, {||.T.})
	aAdd(aWizCalen, {||.T.})
	aAdd(aWizCalen, .T.)
	aAdd(aWizCalen, .F.)
	nA					:= 1
	nB					:= 2
	nC					:= 3
	nD					:= 4
	nE					:= 5
ElseIf nWiz == 1
	nA					:= 2
	nB					:= 3
	nC					:= 4
	nD					:= 5
	nE					:= 6
Else
	nA					:= 3
	nB					:= 4
	nC					:= 5
	nD					:= 6
	nE					:= 7
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Paineis                                             ³
//³ Array aWizPanel - Estrutura:                        |
//³ Para cada linha deste array multidimensional        ³
//³ Posicao 1 - Titulo do painel                        ³
//³         2 - Mensagem Explicativa                    ³
//³         3 - bNext                                   ³
//³         4 - bFinish                                 ³
//³         5 - lPanel                                  ³
//³         6 - bBack                                   ³
//³         7 - bExecute                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDatas 		:= { CtoD("01/01/"+Substr(DTOs(dDataBase),3,2)) , CtoD("31/12/"+Substr(DTOs(dDataBase),3,2))}
aTpPer 		:= {3}  //1=Semanal;2=Quinzenal;3=Mensal;4=Bimestral;5=Semestral;6=Anual;7=Dißrio;8=trimestral
cCalendCTB	:= Left(cExerc,1)+Right(cExerc,2)
aDadCalen 	:= {cCalendCTB,cExerc,.F.,.F.}

aAdd(aWizPanCal, {cCadastro, STR0019 	, {||Ctb010WzDt(aDatas)} 		,{||.T.} , .T., {||.T.}		, {||Ctb010Per(aPanel[nA],aDatas),.T.} })   //"Digite o Periodo"
aAdd(aWizPanCal, {cCadastro, STR0020 	, {||.T.}						,{||.T.} , .T., {||.T.}		, {||Ctb010TPer(aPanel[nB],aTpPer),.T.} })  //"Escolha o Tipo de Periodo"
aAdd(aWizPanCal, {cCadastro, STR0021 	, {||.T.}						,{||.T.} , .T., {||aCols := {},oGet:SetArray(aCols),.T.}	, {||Ctb010Grd(aPanel[nC],@oGet,aDatas,aTpPer,.T.),.T.} })  //"Confira os periodos gerados"
aAdd(aWizPanCal, {cCadastro, STR0022 	, {||cCalendCTB:=aDadCalen[1],cExerc:=aDadCalen[2],nUsado:=4,lRet := Ct010Calend(cCalendCTB,3).And.Ct010TudOk(3/*nOpc*/),Iif(lRet,CtbWSave(cExerc), (nOpca := 0, .F.))};
																		,{||.T.} , .T., {||.T.}		, {||Ctb010Head(aPanel[nD],@aDadCalen,@cExerc,!lNovaTela ),.T.}})  //"Preencha e Confirme os Dados"
aAdd(aWizPanCal, {cCadastro, ""         , {||.T.}                       ,{||lOK:=.T.,.T.} , .T., {|| Help(NIL, NIL, "JAFINAL" , NIL, STR0061 /*A INCLUSÃO DO CALENDÁRIO JÁ FOI FINALIZADA, NÃO É POSSIVEL MAIS UTILIZAR A OPÇÃO "VOLTAR" */, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0062 /*FINALIZE O ASSISTENTE E INICIE NOVAMENTE*/})}     , {||CtbWFim(aPanel[nE],cExerc,!lNovaTela .And. aDadCalen[4])} })


CtbWizard(aWizCalen, aWizPanCal, aPanel, /*lCenter*/, bFinalWiz/*bValid*/, /*bInit*/, /*bWhen*/)

If lOK
	If aDadCalen[3]
		While aDadCalen[3]
			CTB140Inc("CTO",0,3)
			If Aviso(STR0023, STR0024, {STR0025, STR0026})==2  //"Atencao"###"Continua com inclusao de moeda ?"###"Sim"###"Nao"
				aDadCalen[3] := .F.
			EndIf
		EndDo
	EndIf

	If aDadCalen[4]  //faz amarracao com todas as moedas
		Ctb200Wiz(cCalendCTB, .T., nOpca)
	EndIf
EndIf

// Integração Jurídico - SIGAPFS x SIGAFIN
IIf (lOK .And. FindFunction("JLoadCQD"), JLoadCQD(cCalendCTB, cExerc), Nil)

IF !lOK
	cCalendCTB := Space(Len(cCalendCTB))
EndIf

Return cCalendCTB

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³At010ChgDi³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 17.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastrar cotacoes no dia escolhido                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³At010ChgDi(oCalend,oGet,dData)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Calendario                                  ³±±
±±³          ³ ExpO2 = Objeto Getdados                                    ³±±
±±³          ³ ExpD1 = Data Selecionada                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function At010ChgDia(oCalend,oGet,dData)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CTb010Ahea³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 17.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera matriz Aheader - para montagem posterior da acols     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb010Ahea()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum		                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb010Ahead(lWizard)

Local oStruCTG	:= FWFormStruct(1,"CTG")

Local aStruCTG	:= {}

Local nI		:= 0

Default lWizard := .F.

oStruCTG:RemoveField("CTG_FILIAL")
oStruCTG:RemoveField("CTG_EXERC")
oStruCTG:RemoveField("CTG_CALEND")

aStruCTG := aClone(oStruCTG:GetFields())
nUsado := 0

For nI := 1 to Len(aStruCTG)
	
	If ( !lWizard .Or. (lWizard .And. GetSX3Cache(aStruCTG[nI,3],"X3_PROPRI") <> "U" ) )

		nUsado++
		
		Aadd(aHeader,{	Alltrim(aStruCTG[nI,1]),;					//x3_titulo
						aStruCTG[nI,03],;							//x3_campo
						GetSX3Cache(aStruCTG[nI,03], "X3_PICTURE"),;//x3_picture
						aStruCTG[nI,05],;							//x3_tamanho
						aStruCTG[nI,06],; 							//x3_decimal
						aStruCTG[nI,08],;							//x3_valid
						GetSX3Cache(aStruCTG[nI,03], "X3_USADO"),;	//x3_usado
						aStruCTG[nI,04],;							//x3_tipo
						"CTG" } )									//x3_arquivo

	EndIf					

Next nI

If lWizard
	aHeaderSv[1] := aClone(aHeader)
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CTb010Acol³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 17.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera matriz ACOLS para preenchimento das cotacoes          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb010Acol(nOpc,cExerc,cCalendCTB)  	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum		                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao escolhida do menu (Inclusao / Alteracao..)   ³±±
±±³          ³ ExpC1 = Exercicio Contabil -> Ano                          ³±±
±±³          ³ ExpC2 = Calendario Contabil escolhido                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb010Acols(nOpc,cExerc,cCalendCTB,cFilCal,lWizard)

Local nCont := 1
Local cFilCTG	:= ""
Local aSaveArea := GetArea()

Default cFilCal := xFilial("CTG")
Default lWizard := .F.

cFilCTG := xFilial("CTG",cFilCal)

If __lEAIC010
	nPosDtIni	:= GdFieldPos("CTG_DTINI")
	nPosDtFim	:= GdFieldPos("CTG_DTFIM")
	nPosStatus	:= GdFieldPos("CTG_STATUS")
Else
	nPosDtIni	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "CTG_DTINI"})
	nPosDtFim	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "CTG_DTFIM"})
	nPosStatus	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "CTG_STATUS"})
EndIf

aCols := {}

dbSelectArea("CTG")
dbSetOrder(1)
If (nOpc == 2 .Or. nOpc == 4 .Or. nOpc == 5)  // Visualiza / Altera / Exclui
	dbSeek(cFilCTG+cCalendCTB+cExerc)
	While !Eof() .And. cFilCTG == CTG->CTG_FILIAL .And.;
			CTG->CTG_EXERC == cExerc .And. CTG->CTG_CALEND == cCalendCTB

		AADD(aCols,Array(Len(aHeader)+1))
	  //Ponto de entrada para tratamento de campo especifico de usuario
	  	If ExistBlock ("CT010Atu")
			ExecBlock("CT010Atu",.F.,.F.,{aHeader,aCols,nCont,1})
		EndIf
		aCols[nCont][1]			:= CTG->CTG_PERIOD
		aCols[nCont][nPosDtIni]	:= CTG->CTG_DTINI
		aCols[nCont][nPosDtFim]	:= CTG->CTG_DTFIM
		aCols[nCont][nPosStatus]:= CTG->CTG_STATUS
		aCols[nCont][Len(aHeader)+1]:= .F.
		nCont++
		dbSkip()

	EndDo
ElseIf ( nOpc == 3 )			// Inclusao
	
	AADD(aCols,Array(Len(aHeader)+1))
	
	For nCont := 1 to Len(aHeader)

		If ( aHeader[nCont,8] == "C" .And. ExistIni(aHeader[nCont,3]) )
			aCols[Len(aCols),nCont] := InitPad(GetSX3Cache(aHeader[nCont,3],"X3_RELACAO"))
		Else
			aCols[Len(aCols),nCont] := ATFCastType(,aHeader[nCont,8],,aHeader[nCont,4])
		EndIf

	Next nCont

	nUsado := Len(aHeader)
	
	aCols[1][nUsado+1]	:= .F.
	aCols[1][1]			:= "01"

EndIf

RestArea(aSaveArea)

If lWizard
	aColsSv[1] 	:= aClone(aCols)
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CTb010Grav³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 17.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as datas do calendario contabil                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb010Grava(nOpc,cExerc,cCalendCTB)  	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum		                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³	ExpN1 = Opcao escolhida do menu (Inclusao / Alteracao..)  ³±±
±±³          ³	ExpC1 = Exercicio Contabil -> Ano                         ³±±
±±³          ³  ExpC2 = Calendario Contabil escolhido                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb010Grava(nOpc,cExerc,cCalendCTB)

Local lRet       := .T.
Local aSaveArea  := GetArea()
Local nCont      := 0
Local lExclui    := .T.
Local lPergCTE   := .T.
Local lDelCTE    := .F.
Local cStatusAnt := ""
Local oModelCTG  := Nil
Local aErro      := {}
Local lTradi	 :=  (ValType(mv_par01) == "N" ) .And. mv_par01 == 1//Calendario em modo tradicional

Begin Transaction

If nOpc == 3 .Or. nOpc == 4		// Inclusao / Alteracao
	dbSelectArea("CTG")
	dbSetOrder(1)
	For nCont := 1 To Len(aCols)

		If !aCols[nCont][Len(aHeader)+1]
			If !dbSeek(xFilial() + cCalendCTB + cExerc + aCols[nCont][1], .F.)
				RecLock("CTG", .T.)
				Replace CTG_FILIAL  With xFilial("CTG")
				Replace CTG_CALEND  With cCalendCTB
				Replace CTG_EXERC   With cExerc
				Replace CTG_PERIOD  With aCols[nCont][1]
			Else
				RecLock("CTG", .F.)
			EndIf

			//Guarda o status anterior do resgistro do calendário
			cStatusAnt := CTG_STATUS

			Replace CTG_DTINI  With aCols[nCont][nPosDtIni]
			Replace CTG_DTFIM  With aCols[nCont][nPosDtFim]
			Replace CTG_STATUS With aCols[nCont][nPosStatus]
			MsUnlock()

			If ExistBlock ("CT010Atu")
				ExecBlock("CT010Atu",.F.,.F.,{aHeader,aCols,nCont,2})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Integracao PIMS GRAOS         								  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc == 4 .And. aCols[nCont][nPosStatus] == "4" .And. cStatusAnt <> "4"
				If __lEAIC012
					MsgRun( STR0046,, {|| lRet := CTBA012A(aCols[nCont][nPosDtIni],aCols[nCont][nPosDtFim]) } )//"Exportando saldos para PIMS"
				Else
					If __lPIMS
						PIMSGerCTB({aCols[nCont][1],aCols[nCont][nPosDtIni],aCols[nCont][nPosDtFim],aCols[nCont][nPosStatus]})
					EndIf
				EndIF
			EndIf

			// Altera Bloquei de processos
			If nOpc == 4
				CTBA012ALT(cCalendCTB,cExerc,aCols[nCont][1],aCols[nCont][nPosStatus])
			EndIF
		Else
			If dbSeek(xFilial()+cCalendCTB+cExerc+aCols[nCont][1])
				// Verifica se existem laçamentos contábeis para o período a ser excluído
				IF ExiSalCQ("CTG",/*cFiltro*/,CTG->CTG_DTINI,CTG->CTG_DTFIM,/*cConta*/,/*cCC*/,/*cItem*/,/*cClasse*/)
					Help(" ",1,"EXISTELAN")
					lRet := .F.
					Exit
				Else
					RecLock("CTG",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
		EndIf

	Next nCont

ElseIf nOpc == 5				// Exclusao
	dbSelectArea("CTG")
	dbSetOrder(1)

	If	dbSeek(xFilial()+cCalendCTB+cExerc)
		// Verifica se existem lançamentos para o calendário a ser excluído.
		// Verifica se existem laçamentos contábeis para o período a ser excluído
		IF ExiSalCQ("CTG",/*cFiltro*/,CTG->CTG_DTINI,CTG->CTG_DTFIM,/*cConta*/,/*cCC*/,/*cItem*/,/*cClasse*/)
			Help(" ",1,"EXISTELAN")
			lRet := .F.
		Else
			/// verifica se tem amarrações de moeda para o calendario
			dbSelectArea("CTE")
			dbSetOrder(1)
			MsSeek(xFilial("CTE"),.T.)
			lPergCTE	:= .T.
			lDelCTE		:= .F.
			While CTE->(!Eof()) .and. CTE->CTE_FILIAL == xFilial("CTE")
				If CTE->CTE_CALEND == cCalendCTB
					If lPergCTE
						Help(" ",1,"CT010INCTE")
						If !isBlind()
							If MsgYesNo(STR0044+"?")
								lDelCTE := .T.
							Else
								lRet := .F.
								Exit
							Endif
						Else
							lDelCTE := .F.
						EndIf
						lPergCTE := .F.
					Endif
					If lDelCTE
						RecLock("CTE",.F.)
						dbDelete()
						CTE->(MsUnlock())
					Endif
				EndIf
				CTE->(dbSkip())
			EndDo

			If lDelCTE
				CTE->(FkCommit())
			Endif

			If ExistBlock ("CT010DELLN")
				ExecBlock("CT010DELLN",.F.,.F.,{cCalendCTB,cExerc})
			EndIf

			If lRet
				// Exclui o calendário, caso não existam lançamentos
				If CTG->( dbSeek( xFilial( 'CTG' ) + cCalendCTB + cExerc ) )

					oModelCTG := FwLoadModel("CTBA012")
					oModelCTG:SetOperation( nOpc )
					oModelCTG:Activate()
	
					If lRet
						If lRet := oModelCTG:VldData()
							// oModelCTG:CommitData()
							If !__lEAIC010
								While CTG->(!EOF()) .And. CTG->CTG_FILIAL == xFilial('CTG') .And. CTG->CTG_CALEND == cCalendCTB .And. CTG->CTG_EXERC == cExerc

									CTG->(Reclock("CTG",.F.))
									CTG->(dbDelete())
									CTG->(MsUnLock())
									CTG->(DbSkip())
								EndDo
								CTG->(FkCommit())
							EndIF
						Else
							aErro := oModelCTG:GetErrorMessage()
							Help(" ",1,,,aErro[6])
						EndIf
					EndIf
	
					oModelCTG:DeActivate()

				EndIf

			EndIf
		Endif
	EndIf
EndIf

//Metrica para verificar se está sendo utilizado o modo tradicional do calendario
If __lMetric .And. lTradi .And. lRet
	
	nQtd := 1
	
	CTB010Metrics("01" /*cEvent*/,/*nStart*/, "001" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/, nQtd)

Endif

If lRet
	// Integração EAI
	If lRet .and. __lEAIC010 
		MsgRun("Exportando EAI",, {|| lRet := CTBA010EAI(cCalendCTB, cExerc, (nOpc == 5))})
	Endif
Else
	DisarmTransaction()
Endif

End Transaction

If ExistBlock("CT010GRV")
	ExecBlock("CT010GRV", .F., .F., {nOpc, cExerc, cCalendCTB, aHeader, aCols})
EndIf

RestArea(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CT010Calen³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 17.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do cadastro do calendario contabil               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct010Calen(nOpc,cExerc,cCalendCTB)  	                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Calendario Contabil Escolhido                      ³±±
±±³          ³ ExpN1 = Opcao do Menu escolhida (Inclusao / Alteraca..)    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct010Calend(cCalendCTB,nOpc)

Local lRet 		:= .T.
Local aSaveArea := GetArea()

If nOpc == 3		// Inclusao
	dbSelectAREA("CTG")
	dbSetOrder(1)
	If dbSeek(xFilial()+cCalendCTB)
		Help(" ",1,"JAEXISCALE")
		lRet := .F.
	EndIf
ElseIf nOpc == 4	// Alteracao
	dbSelectAREA("CTG")
	dbSetOrder(1)
	If !dbSeek(xFilial()+cCalendCTB)
		Help(" ",1,"NOEXISCALE")
		lRet := .F.
	EndIf
EndIf

RestArea(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CT010LinOK³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 17.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a linha da getdados                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct010LinOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.  		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct010LinOK()

Local lRet := .T.

If !aCols[n][Len(aHeader)+1]
	If Empty(aCols[n][nPosDtIni]) .Or. Empty(aCols[n][nPosDtFim])
		Help(" ",1,"C010EMPTY")
		lRet := .F.
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CT010TudOK³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 17.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a getdados completa                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct010TudOk()			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.  		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct010TudOK(nOpc)

Local aSaveArea:= GetAREA()
Local lRet		:=	.T.
Local nCont
Local nLenCols	:= Len(aCols)
Local dLastData
Local lCT010TOK := ExistBlock( "CT010TOK" )

If !IsBlind()
	For nCont := 1 To nLenCols
		If !Ct010LinOK()
			lRet := .F.
			Exit
		EndIf
	Next nCont
EndIF

//// VALIDACAO DE INTERVALO COM LINHAS DELETADAS
For nCont := 1 to nLenCols
	If !aCols[nCont][Len(aHeader)+1]
		If nCont > 1 .and. ValType(dLastData) == "D"
			If aCols[nCont][nPosDtIni] <> dLastData+1
				Help(" ",1,"CT010DIAS")
				lRet := .F.
				Exit
			Endif
		Endif
		dLastData := aCols[nCont][nPosDtFim]
	EndIF
Next

//ponto de entrada para validacao do usuario ao pressionar o botao OK
If lRet .And. lCT010TOK
	lRet := ExecBlock( "CT010TOK",.F.,.F.,{nOpc})
EndIf

//Validações usadas na integração com Jurídico (SIGAPFS)
If lRet .And. FindFunction("JVldCalend") .And. nOpc <> 5
	lRet := JVldCalend(aCols)
EndIf

RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ct010Datas ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se data inicial eh maior que data final           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct010Datas()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACTB  		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct010Datas()

Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local dDataFim	:= &(ReadVar())

If aCols[n][nPosDtIni] > dDataFim
	Help(" ",1,"CT010DATAS")
	lRet := .F.
EndIf

RestArea(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ct010DtIni ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se data final do periodo anterior eh menor do que ³±±
±±³          ³ a data inicial do periodo seguinte.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct010DtIni()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGACTB   		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct010DtIni()

Local lRet 		:= .T.
Local aSaveArea := GetArea()
Local dDataIni	:= &(ReadVar())
Local nAntCols  := n-1

If VALTYPE(n) != "N" .OR. n == 1
	lRet := .T.
Else
	If aCols[nAntCols][nPosDtFim] > dDataIni .or. aCols[nAntCols][nPosDtFim]-dDataIni = 0
		Help(" ",1,"CT010DTINI")
		lRet := .F.
	EndIf
	If lRet
		If (dDataIni - aCols[nAntCols][nPosDtFim]) > 1
			Help(" ",1,"CT010DIAS")
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ct010DgCod ³ Autor ³ Lucimara Soares      ³ Data ³ 10/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Força o código do calendário a possuir três dígitos.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct010DgCod() 	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGACTB   		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ct010DgCod(cCalendCTB,oCalendCTB)

cCalendCTB := STRZERO(Val(cCalendCTB),3)

oCalendCTB:Refresh()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Paulo Carnelossi      ³ Data ³07/03/07  ³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
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

Local aRotina := {	{STR0001, "AxPesqui",   0, 1,, .F.},;  // "Pesquisar"
					{STR0002, "Ctb010Cal",  0, 2},;        // "Visualizar"
					{STR0003, "Ctb010Cal",  0, 3},;        // "Incluir"
					{STR0004, "Ctb010Cal",  0, 4},;        // "Alterar"
					{STR0005, "Ctb010Cal",  0, 5},;        // "Excluir"
					{STR0051, "CTBA012",    0, 6},;        // "Bloqueio de Processo"
					{STR0052, "CTBA012",    0, 7},;        // "Visualizar Bloqueio"
					{STR0053, "Ctb010Bloq", 0, 8}}         // "Bloqueio Automático"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. utilizado para adicionar itens no Menu da mBrowse       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CT010BRW")
	aRotAdic := ExecBlock("CT010BRW",.F.,.F.,{aRotina})
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb010WzDt   ºAutor  ³William Pires    º Data ³  15/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a data inicial e maior que a data final no     º±±
±±º          ³ assistente para inclusao de calendario contabil            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Bloco bNext da funcao CtbWizard (CTBXFUNA)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb010WzDt(aDatas)

Local lRet := .T.

Default aDatas := {}

If Len(aDatas) > 1

	If Empty(aDatas[1]) .OR. Empty(aDatas[2])
		Help(" ",1,"C010EMPTY")
		lRet := .F.
	Else
		If aDatas[1] > aDatas[2]
			Help(" ",1,"CT010DATAS")
			lRet := .F.
		EndIf
	EndIf

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb010Per   ºAutor  ³Microsiga         º Data ³  30/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para digitação do periodos inicial / final no         º±±
±±º          ³ assistente para inclusao de calendario contabil            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ctb010Per(oDlg, aDatas)
Local aParam := {	{ 1 ,STR0027, aDatas[1] ,"@D" 	 ,""  ,"" ,".T." ,65 ,.T. }, ; //"Data inicial"
					{ 1 ,STR0028, aDatas[2] ,"@D" 	 ,""  ,"" ,".T." ,65 ,.T. } } //"Data final"

Default aDatas := {dDataBase, dDataBase+90 }

ParamBox(aParam ,STR0013, aDatas,,,.F.,120,3, oDlg)    //"Periodo"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb010TPer  ºAutor  ³Microsiga         º Data ³  30/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para selecionar tipo do periodos no assistente para   º±±
±±º          ³ inclusao de calendario contabil                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb010TPer(oDlg, aTpPer)
Local aOpcoes := { STR0029,;  //"1=Semanal"
					STR0030,;  //"2=Quinzenal"
					STR0031,;  //"3=Mensal"
					STR0032,;  //"4=Bimestral"
					STR0033,;  //"5=Semestral"
					STR0034,;  //"6=Anual"
					STR0035,;  //"7=Diario"
					STR0036;   //"8=trimestral"
				}
Local aParametros  := { {3,STR0037,aTpPer[1],aOpcoes,160,,.F.} }  //"Selecione Tipo de Periodo"
Default aTpPer 		:= {3}

ParamBox(aParametros ,STR0038, aTpPer,,,.F.,120,aTpPer[1], oDlg)   //"Tipo de Periodo"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb010Grd   ºAutor  ³Microsiga         º Data ³  30/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para apresentacao dos periodos no assistente para     º±±
±±º          ³ inclusao de calendario contabil                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ctb010Grd(oDlg, o_GetD, aDatas, aTpPer, lWizard)
Local aPerAux  := {}
Local aPeriodo := {}
Local nCont
Local nInicio := 1

If lWizard
	aHeader := aClone(aHeaderSv[1])
	aCols	:= aClone(aColsSv[1])
EndIf

	aPeriodo := PcoRetPer(aDatas[1], aDatas[2], Str(aTpPer[1],1,0), .F., aPerAux)
	If __lEAIC010
		nPosDtIni	:= GdFieldPos("CTG_DTINI")
		nPosDtFim	:= GdFieldPos("CTG_DTFIM")
		nPosStatus	:= GdFieldPos("CTG_STATUS")
	Else
		nPosDtIni	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "CTG_DTINI"})
		nPosDtFim	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "CTG_DTFIM"})
		nPosStatus	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "CTG_STATUS"})
	EndIf
	If Len(aCols) == 1
		aCols[1, 2] := STOD(aPerAux[1,1])
		aCols[1, 3] := STOD(aPerAux[1,2])
		aCols[1, 4] := "1"
		nInicio := 2
	Else
		aCols := {}
	EndIf
	For nCont := nInicio TO Len(aPerAux)
		AADD(aCols,Array(Len(aHeader)+1))
		aCols[nCont][1]				:= If( nCont<100,StrZero(nCont, Len(CTG->CTG_PERIOD)), Soma1(aCols[nCont-1,1]) )
		aCols[nCont][nPosDtIni]		:= STOD(aPerAux[nCont,1])
		aCols[nCont][nPosDtFim]		:= STOD(aPerAux[nCont,2])
		aCols[nCont][nPosStatus]	:= "1"
		aCols[nCont][Len(aHeader)+1]:= .F.
	Next
	If ValType(o_GetD)!="O"
		o_GetD := MSGetDados():New(0,0,154,70,2,"Ct010LinOK","Ct010TudOK","+CTG_PERIOD",,,,,9999,,,,,oDlg)
		o_GetD:oBrowse:Align := CONTROL_ALIGN_TOP
	Else
		o_GetD:SetArray(aCols)
		N := Len(aCols)
		o_GetD:oBrowse:Refresh()
	EndIf


If lWizard
	aHeaderSv[1]	:= aClone(aHeader)
   	aColsSv[1]		:= aClone(aCols)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb010Head  ºAutor  ³Microsiga         º Data ³  30/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para finalizacao do assistente para inclusao de       º±±
±±º          ³ calendario contabil                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ctb010Head(oDlg, aDadCalen, cExerc, lCont)
Local aParam := {}
Default lCont := .T.

aAdd(aParam,{ 1 ,STR0008		, aDadCalen[1] 	,"@!" 	 	,""  ,"" ,".T." ,65 ,.T. }) //"Calendario"
aAdd(aParam,{ 1 ,STR0007	 	, aDadCalen[2]	,"@!" 	 	,""  ,"" ,".T." ,65 ,.T. }) //"Exercicio Contabil"
If lCont
	aAdd(aParam,{ 4 ,""				, aDadCalen[3]	,STR0039	,165 ,.F.,.F.}) //"Incluir novas Moedas"
	aAdd(aParam,{ 4 ,""				, aDadCalen[4]	,STR0041	,165 ,.F.,.F.}) //"Amarrar Calendario com Moedas"
EndIf

ParamBox(aParam ,STR0013, aDadCalen,,,.F.,120,3, oDlg)  //"Periodo"

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbWFim  ³ Autor ³ Leandro F. Dourado     ³ Data ³ 25/10/11³  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela para salvar as moedas cadastradas                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtbWFim(oDlg,cExerc, lCont)
Local oSay
Local oFont
Local cMsgCont
Default lCont := .T.

cMsgCont := IIF(lCont,STR0047,"")//"Você agora será direcionado ao assistente de amarrações de calendário contábil x moeda contábil."


oFont 	:= TFont():New(,,-12,,, )
oFont2 := TFont():New(,,-18,,.T., )

oSay := TSay():Create(oDlg, {||STR0048},,130,,oFont2,,,,,,,,)//"Atenção!"
oSay := TSay():Create(oDlg, {||STR0049+CRLF+cMsgCont},20,20,,oFont,,,,,,,,60)//"Você finalizou cadastro de calendário contábil."

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbWSave  ³ Autor ³ Leandro F. Dourado     ³ Data ³ 25/10/11³  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela para salvar as moedas cadastradas                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbWSave(cExerc)

nUsado := 4
Ctb010Grava(3, cExerc, cCalendCTB)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb010Tree  ºAutor  ³Microsiga         º Data ³  30/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Tree na dialog informada com os dados fornecidos     º±±
±±º          ³ calendario contabil                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ctb010Tree(oDlg, aDados)
Local oTree
Local oPanel

oPanel := TScrollBox():New( oDlg, 005, 005, oDlg:nClientHeight,oDlg:nClientWidth,.T.,.T.,.T.)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

//------------------------------------------------------------------------------------------//
//CRIACAO DA ARVORE
//------------------------------------------------------------------------------------------//
oTree:= Xtree():New(005,005,oPanel:nClientHeight,oPanel:nClientWidth,oPanel)

Ctb010Node(oTree, aDados)

Return(oTree)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb010Node  ºAutor  ³Microsiga         º Data ³  30/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta nodes na Tree da dialog informada com os dados       º±±
±±º          ³ fornecidos calendario contabil                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ctb010Node(oTree, aDados, lEndTree)
Local nX

Default lEndTree := .T.

For nX := 1 TO Len(aDados)

	oTree:AddTree	( aDados[nX,1],; //descricao do node //
						"IndicatorCheckBox", ; //bitmap fechado
						"IndicatorCheckBoxOver",; //bitmap aberto
						aDados[nX,2], ;  //cargo (id)
						,;//bAction - bloco de codigo para exibir
						aDados[nX,3] ;
					)

	If Len(aDados[nX]) > 3
		Ctb010Node(oTree, aDados[nX,4])
	EndIf

	If lEndTree
		oTree:EndTree()
	EndIf

Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb010Layer ºAutor  ³Microsiga         º Data ³  30/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta layer para exibicao dos dados                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb010Layer(oDlg,aColumns,aWindows)
Local oFWLayer, oWin
Local nX, nY

// Cria instancia do fwlayer
oFWLayer := FWLayer():New()

// Inicializa componente passa a Dialog criada,
// o segundo parametro é para criação de um botao de fechar utilizado para Dlg sem cabeçalho
oFWLayer:init( oDlg, .T. )

For nX := 1 To Len(aColumns)
	// Adiciona coluna passando nome, porcentagem da largura, e se ela é redimensionada ou não
	oFWLayer:addCollumn( "Col"+StrZero(nX,1), 1/Len(aColumns)*100, .T. )

	For nY:=1 TO Len(aWindows[nX])
		// Cria windows passando, nome da coluna onde sera criada, nome da window
		// titulo da window, a porcentagem da altura da janela, se esta habilitada para click,
		// se é redimensionada em caso de minimizar outras janelas e a ação no click do split
		oFWLayer:addWindow( "Col"+StrZero(nX,1), "Win"+StrZero(nX,1)+StrZero(nY,1), aWindows[nX,nY,1], 100/Len(aWindows[nX]) , .F., .T., aWindows[nX,nY,2],,)
		oWin := oFWLayer:getWinPanel('Col'+StrZero(nX,1),'Win'+StrZero(nX,1)+StrZero(nY,1))
      	aWindows[nX,nY,3] := oWin
	Next

Next

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb010Camb  ºAutor  ³Microsiga         º Data ³  30/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ MOnta um grid (browse) para a tabela CTP - CAMBIO          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb010Camb(oDlg)
Local oBrowse
Local bBlock
Local oPanel
Local cPicture

oPanel := TScrollBox():New( oDlg, 10, 10, oDlg:nClientHeight, oDlg:nClientWidth)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

oBrowse := BrGetDDB():New( 1,1,oDlg:nClientWidth,oDlg:nClientHeight,,,,oPanel,,,,,,,,,,,,.F.,'CTP',.T.,,.F.,,, )
oBrowse:bRClicked  := {|z,x| TreeVisual(,,,.F.)}
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek( "CTP" )
While !Eof() .And. X3_ARQUIVO == "CTP"
	IF X3USO(X3_USADO) .And. cNivel >= x3_nivel
		If ALLTRIM(X3_CAMPO) == "CTP_BLOQ"
		    bBlock := MontaBlock("{||If(CTP->"+X3_CAMPO+"=='1', 'Sim','Nao')}")
		    cPicture := ""
		Else
		    bBlock := MontaBlock("{||CTP->"+X3_CAMPO+"}")
		    cPicture := AllTrim(X3_PICTURE)
	 	EndIf
		oBrowse:AddColumn(TCColumn():New(TRIM(X3Titulo()),bBlock,cPicture,,,'LEFT',,.F.,.F.,,,,.F.,))
	Endif
	dbSkip()
End

DbSelectArea('CTP')

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TreeVisual  ºAutor  ³Microsiga         º Data ³  30/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ axvisual para exibicao dos cadastros                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TreeVisual(oTree,cAlias,cSeek,lSeek)
Local aArea := GetArea()
Local oDlg

Default lSeek := .T.

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) FROM 9,0 TO 23,80 OF oMainWnd //"Calendario Contabil"

If lSeek
	If oTree == NIL
		cAlias := If(cAlias == NIL, Alias(), cAlias)
		cSeek := If(cSeek == NIL, "", cSeek)
	Else
		cAlias := If(cAlias == NIL, Left(oTree:GetCargo(),3), cAlias)
		cSeek := If(cSeek == NIL, Substr(oTree:GetCargo(),4), cSeek)
	EndIf
	dbSelectArea(cAlias)
	If dbSeek(xFilial()+cSeek)
		axVisual(Alias(),Recno(),2,,,,,,.F./*lMaximized*/,,.T.,oDlg,,,,,)
	EndIf
Else
	axVisual(Alias(),Recno(),2,,,,,,.F./*lMaximized*/,,.T.,oDlg,,,,,)
EndIf

ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aArea)

Return


/*/{Protheus.doc} IntegDef
Função para integração via Mensagem Única Totvs.

@author  Felipe Raposo
@version P12.1.22
@since   10/05/2018
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return CTBI010(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA010EAIºAutor  ³Alvaro Camillo Neto  º Data ³ 10/09/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina que envia para o EAI também dividindo a mensagem    º±±
±±º          ³ caso seja tenha muitos registros                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBA010EAI(cCalendCTB, cExerc, lExclui)

Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaCTG   := CTG->(GetArea())
Local nCont      := 0
Local nContMax   := 12  // Envia 12 períodos por vez.
Local aEaiRet    := {}
Local aLotes     := {}
Local aPeriodos  := {}
Local nX

Default cCalendCTB := CTG->CTG_CALEND
Default cExerc     := CTG->CTG_EXERC
Default lExclui    := .F.

// Monta lotes de envio.
nCont := nContMax
CTG->(dbSetOrder(1))  // CTG_FILIAL, CTG_CALEND, CTG_EXERC, CTG_PERIOD.
CTG->(dbSeek(xFilial("CTG") + cCalendCTB + cExerc, .F.))
Do While CTG->(!EOF() .And. CTG_FILIAL + CTG_CALEND + CTG_EXERC == xFilial("CTG") + cCalendCTB + cExerc)
	If nCont = nContMax
		aAdd(aLotes, {CTG->CTG_PERIOD, ""})
		aPeriodos := aTail(aLotes)
		nCont := 1
	Else
		nCont ++
	Endif
	aPeriodos[2] := CTG->CTG_PERIOD

	CTG->(dbSkip())
EndDo

// Envia os lotes.
CTG->(dbSetOrder(1))  // CTG_FILIAL, CTG_CALEND, CTG_EXERC, CTG_PERIOD.
CTG->(dbSeek(xFilial("CTG") + cCalendCTB + cExerc, .F.))
For nX := 1 to len(aLotes)
	aPeriodos := aLotes[nX]
	CTI010Ini(aPeriodos[1])
	CTI010Fim(aPeriodos[2])

	aEaiRet := FWIntegDef('CTBA010',,,, 'CTBA010')
	If !aEaiRet[1]
		Help(" ", 1, "HELP", "Erro EAI", "Problemas na integração EAI. Transação não executada." + CRLF + aEaiRet[2], 3, 1)
		DisarmTransaction()
		lRet := .F.
		Exit
	Endif
Next nX

If lRet .and. lExclui
	If CTG->( dbSeek( xFilial( 'CTG' ) + cCalendCTB + cExerc ) )
		While CTG->(!EOF()) .And. CTG->CTG_CALEND == cCalendCTB .And. CTG->CTG_EXERC == cExerc

			CTG->(Reclock("CTG",.F.))
			CTG->(dbDelete())
			CTG->(MsUnLock())
			CTG->(DbSkip())
		EndDo
		CTG->(FkCommit())
	EndIF
EndIF
CTI010Ini("")
CTI010Fim("")

RestArea(aAreaCTG)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}Ctb010Bloq
Bloqueio do Calendario em Lote.
@author Kaique Schiller
@since  29/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Function Ctb010Bloq()
Local aSaveArea	:= GetArea()
Local aAreaCQD	:= CQD->(GetArea())
Local aAreaCTG	:= CTG->(GetArea())
Local cStatus	:= ""
Local cQry		:= ""
Local cAliasQry	:= GetNextAlias()
Local aSelFil 	:= {}
Local cPeriodo  := ""
Local cHtml 	:= ""
Local cCalend   := ""
Local nCont		:= 0
Local lPeHtml := ExistBlock("CT010BWF")
Local cHtmlPe := ""
Local lIntPFS := .F. //Alteracao SOLICTADA PELO MODULO SIGAPFS

If !Pergunte("CTB012A",.T.)
	Return
Endif

cQry := "SELECT CTG_FILIAL, CTG_DTINI, CTG_DTFIM, CQD_ITEM, CQD_PROC, CQD_DESC, CQD_STATUS,CTG.R_E_C_N_O_ RECCTG, CQD.R_E_C_N_O_ RECCQD "+CRLF
cQry += "FROM "+ RetSqlName("CTG") +" CTG "+CRLF
cQry += "INNER JOIN "+ RetSqlName("CQD") + " CQD ON "+CRLF
cQry += "CTG_FILIAL 	= CQD.CQD_FILIAL "+CRLF
cQry += "AND CTG_CALEND = CQD.CQD_CALEND "+CRLF
cQry += "AND CTG_EXERC 	= CQD.CQD_EXERC "+CRLF
cQry += "AND CTG_PERIOD = CQD.CQD_PERIOD "+CRLF
cQry += "INNER JOIN " + RetSqlName("CTE") + " CTE ON "+CRLF
cQry += "CTG_FILIAL 	= CTE.CTE_FILIAL "+CRLF
cQry += "AND CTG_CALEND = CTE.CTE_CALEND "+CRLF
cQry += "WHERE CTG_DTINI >= '"+DTOS(MV_PAR01)+"' "+CRLF
cQry += "AND CTG_DTFIM   <= '"+DTOS(MV_PAR02)+"' "+CRLF
cQry += "AND CQD.CQD_PROC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+CRLF

IIf(FindFunction("JQryCalLot"), cQry += JQryCalLot(), Nil) // Integração SIGAPFS x SIGAFIN

If MV_PAR06 == 1
	aSelFil := AdmGetFil()
	If Empty(aSelFil)
		Return
	Else
		cQry += "AND CTG_FILIAL "+GetRngFil(aSelFil,"CTG")+CRLF
	Endif
Else
	cQry += "AND CTG_FILIAL = '" + XFilial("CTG") + "' "+CRLF
Endif
cQry += "AND CTE_MOEDA = '01'"+CRLF
cQry += "AND CTG.D_E_L_E_T_=''"+CRLF
cQry += "AND CQD.D_E_L_E_T_=''"+CRLF
cQry += "AND CTE.D_E_L_E_T_=''"+CRLF
cQry += "ORDER BY CQD_FILIAL, CQD_CALEND,CQD_EXERC,CQD_PERIOD,CQD_PROC"

cQry := ChangeQuery( cQry )

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQry) , cAliasQry , .T. , .F.)

If MV_PAR05 == 1
	cStatus := "1"
Elseif MV_PAR05 == 2
	cStatus := "4"
Endif

//Alteracao SOLICTADA PELO MODULO SIGAPFS
lIntPFS := cStatus == '1' .And. CQD->(ColumnPos("CQD_PFSREC")) > 0 .And. SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

DbSelectArea("CTG")
DbSelectArea("CQD")

While (cAliasQry)->(!Eof())
	CTG->(DbGoto((cAliasQry)->RECCTG))
	CQD->(DbGoto((cAliasQry)->RECCQD))
	RecLock("CQD",.F.)
	CQD->CQD_STATUS := cStatus
	If lIntPFS //Alteracao SOLICTADA PELO MODULO SIGAPFS
		CQD->CQD_PFSREC := "1"
	EndIf
	CQD->CQD_DTINI  := CTOD(SPACE(8))
	CQD->CQD_DTFIM  := CTOD(SPACE(8))
	CQD->(MsUnLock())

	If cPeriodo <> CQD->CQD_PERIOD .OR. cCalend <> CTG->CTG_CALEND
		If nCont == 4
			cHtml += '<br><br>'
			cHtml += '<table style="text-align: left; width: 100%;" border="0" cellpadding="2" cellspacing="1"><tbody>'
			cHtml += '<tr style="font-family: Arial;"><th valign="center" style="background-color: gray; font-weight: bold; color: white;"><small>'
			cHtml += '</font></font></body></html>'
			Ctb010EnWf(,cHtml)
			nCont := 0
		Endif

		If nCont == 0
			cHtml := '<html><body><font face="Arial"><br>'
		Endif

		cHtml += '<hr style="width: 100%; height: 2px; font-family: Arial;">'
		cHtml += '<br> '+Ctb012Sx3("CTG_FILIAL")+':'+CTG->CTG_FILIAL
		cHtml += '&nbsp&nbsp&nbsp'+Ctb012Sx3("CTG_CALEND")+': '+CTG->CTG_CALEND
		cHtml += '&nbsp&nbsp&nbsp '+Ctb012Sx3("CTG_DTINI")+': '+DTOC(CTG->CTG_DTINI)
		cHtml += '&nbsp&nbsp&nbsp '+Ctb012Sx3("CTG_DTFIM")+': '+DTOC(CTG->CTG_DTFIM)
		cHtml += '<p align=center > '+STR0054+' </p>' //"Processos alterados"
		cHtml += '<hr style="width: 100%; height: 2px; font-family: Arial;">'
		nCont++
	Endif

	cPeriodo := CQD->CQD_PERIOD
	cCalend := CTG->CTG_CALEND

	cHtml += '<br> '+X3Combo("CQD_STATUS",CQD->CQD_STATUS)
	cHtml += '&nbsp&nbsp'+CQD->CQD_PROC
	cHtml += '&nbsp&nbsp'+CQD->CQD_DESC

	If lPeHtml
		cHtmlPe := 	ExecBlock("CT010BWF",.F.,.F.,{ cHtml, nCont })

		If ValType(cHtmlPe) != "C" .OR. Empty(Alltrim(cHtmlPE))
			Help(" ",1,"CT010BWF_ERR",,"Error PE WF - HTML!",3,1)
		Else
			cHtml := cHtmlPe
		EndIf
	EndIf

	(cAliasQry)->(DbSkip())

EndDo

If (cAliasQry)->(Eof())
	cHtml += '<br><br>'
	cHtml += '<table style="text-align: left; width: 100%;" border="0" cellpadding="2" cellspacing="1"><tbody>'
	cHtml += '<tr style="font-family: Arial;"><th valign="center" style="background-color: gray; font-weight: bold; color: white;"><small>'
	cHtml += '</font></font></body></html>'
	Ctb010EnWf(,cHtml)
Endif

(cAliasQry)->(DBCloseArea())

RestArea(aAreaCTG)
RestArea(aAreaCQD)
RestArea(aSaveArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} '
Envia E-mail.
@author Kaique Schiller
@since 29/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Function Ctb010EnWf(cEventID,cMensagem,cTitulo)
Default cEventID	:= "061"
Default cMensagem 	:= ""
Default cTitulo 	:= STR0055 //"Bloqueio de Processos, Calendário Contábil"

EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,""/*cCargo*/,cTitulo,cMensagem,.T.)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CT010AutoOk³ Autor ³ Squad Control        ³ Data ³ 16.11.18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a linha da getdados excauto                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CT010AutoOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.  		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CT010AutoOk(nOpc)

Local lRet := .T.
Local nX

For nX := 1 to Len(aCols)
	If !aCols[nX][Len(aHeader)+1]
		If Empty(aCols[nX][nPosDtIni]) .Or. Empty(aCols[nX][nPosDtFim])
			Help(" ",1,"C010EMPTY")
			lRet := .F.
		EndIf
	EndIf
Next nX

If !__lEAIC010
	If lRet
		lRet := Ct010TudOk(nOpc)
	EndIF
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} '
Ajusta aHeader
Feito ajuste do aheader nessa função, pois não estava funcionando pelos 
parâmetros da FilGetDados
@author Totvs
@since 15/10/2018
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function AjustaHead()
Local aHeaderAux := {}
Local nI 		 := 0
Local cNoFields  := "CTG_FILIAL/CTG_EXERC/CTG_CALEND/CTG_ALI_WT/CTG_REC_WT"

For nI := 1 to Len(aHeader)
	If !(AllTrim(aHeader[nI,2])$cNoFields)
		aAdd(aHeaderAux,aHeader[nI])
	EndIf
Next nI

aHeader := aClone(aHeaderAux)

Return

/*/{Protheus.doc} CTB010Metrics
	
	CTB010Metrics - Fun??o utilizada para metricas no ATFA271

	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function CTB010Metrics(cEvent, nStart, cSubEvent, cSubRoutine, nQtdReg)

Local cFunBkp	:= ""
Local cFunMet	:= ""

Local nFim := 0

Local cIdMetric  := ""
Local dDateSend := CtoD("") 
Local nLapTime := 0
Local cTotal := ""
Local nTotal := 0

Default cEvent := ""
Default nStart := Seconds()
Default cSubEvent := ""
Default cSubRoutine := Alltrim(ProcName(1))
Default nQtdReg := 0

//S? capturar metricas se a vers?o da lib for superior a 20210517
If __lMetric .And. !Empty(cEvent)
	
	//grava funname atual na variavel cFunBkp
	cFunBkp := FunName()

	If cEvent == "01" //Evento 01 - Metrica de tempo m?dio

		
		//Evento 01 - Metrica de quantidade total de gravacao do tipo 15 - AF012Grv15
		If cEvent == "01" 

			If cSubEvent == '001'

				cFunMet := Iif(AllTrim(cFunBkp)=='RPC',"RPCTBA010",cFunBkp)
				SetFunName(cFunMet)

				//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics
				cSubRoutine := Alltrim(cSubRoutine)			
				cIdMetric  := "contabilidade-gerencial-protheus_cadastro-calendario-tradicional-qtd_total"
				nTotal := nQtdReg //trocar para ntotal se for sum
				dDateSend := LastDay( Date() )
				FwCustomMetrics():SetSumMetric(cSubRoutine, cIdMetric, nTotal, dDateSend, nLapTime)

			EndIf
		EndIf
	EndIf

	//Restaura setfunname a partir da variavel salva cFunBkp
	SetFunName(cFunBkp)
EndIf

Return

//Carrega variaveis estaticas
Function LoadVar010()

// Variaveis de controle de integracoes
If	__lEAIC010 == NIL
	__lEAIC010   := FWHasEAI("CTBA010",.T.,,.T.)
EndIf

If	__lEAIC012 == NIL
	__lEAIC012 := FWHasEAI("CTBA012",.T.,,.T.)
EndIf

If	__lPIMS == NIL
	__lPIMS    := (SuperGetMV("MV_PIMSINT",.F.,.F.) .And. FindFunction("PIMSGerCTB"))
EndIf

If __lMetric == NIL
	__lMetric	:= FwLibVersion() >= "20210517" .And. GetSrvVersion() >= "19.3.0.6"
EndIf

Return