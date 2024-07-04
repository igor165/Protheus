#Include "TOTVS.CH"
#Include "PROTHEUS.CH"
#Include "QMTA140.CH"

#DEFINE OBJ_ESCALA      1
#DEFINE OBJ_PONTO       2
#DEFINE OBJ_MEDICAO_1   3
#DEFINE OBJ_MEDICAO_2   4
#DEFINE OBJ_MEDICAO_4   5
#DEFINE OBJ_OBSERVACAO  6
#DEFINE OBJ_MEDEXT      7
#DEFINE OBJ_PADSEC      8
#DEFINE OBJ_INSTUTIL    9
#DEFINE OBJ_NAOCONFOR  10
#DEFINE OBJ_INCERT_B   11
#DEFINE OBJ_MEDICAO_3  12

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ QMTA140	³ Autor ³ Wanderley Goncalves   ³ Data ³ 16.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastra Medicoes 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Void QMTA140												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³String	 ³ Ultimo utilizado ->	  0036 - Proximo ->	  0037			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQMT													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Denis Martins ³19/02/02³Melhor³ Na montagem da estrutura escala tipo so³±±
±±³ 			 ³		  ³      ³ ma, permitir somente padrao com a data ³±±
±±³ 			 ³		  ³      ³ igual/inferior `a calibracao.          ³±±
±±³Denis Martins ³15/03/03³Melhor³ Criado funcao qmt140SetOpt - Retorna a ³±±
±±³ 			 ³		  ³      ³ posicao atual do folder e atualiza npos³±±
±±³ 			 ³		  ³      ³ ant para gravar acols corretamente.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

	Local aRotina := {{ STR0002,"AxPesqui", 0 , 1,,.F.},; //"Pesquisar"
	{ STR0003,"A140Mae" , 0 , 2    },; //"Visualizar"
	{ STR0004,"A140Mae" , 0 , 3    },; //"Incluir"
	{ STR0005,"A140Mae" , 0 , 4    },; //"Alterar"
	{ STR0006,"A140Exc" , 0 , 5, 3 },; //"Excluir"
	{ STR0113,"qmt140VDoc" , 0 , 6},;	//"Visual.Docto"
	{ STR0007,"A140Hist", 0 , 6    }} //"Historico"

Return aRotina

Function QMTA140(lExt)

	Local lQM140Brow   := ExistBlock("QM140BROW")
	Local nRet         := 0

	Private aHeadQMS   := {}
	Private aPagEsc    := {}
	Private aPagPad    := {}
	Private aTitEsc    := {}
	Private aTitPad    := {}
	Private cCadastro  := STR0001 //"Medicoes"
	Private cCdBitMap  := ""
	Private cMtRespQM2 := ""
	Private cNomin     := ""
	Private cPertMt140 := " "
	Private cUniMed    := ""
	Private dData      := CtoD(" / / ","DDMMYY")
	Private dDataVal   := Nil
	Private lBlkGrv    := .T.
	Private lGHist     := GetMV("MV_QMTGINS",.T.,"1") == "1"
	Private lQSOMINC   := SuperGetMv("MV_QSOMINC",.F.,.F.) //Soma o valor da incerteza total para o calculo da incerteza padrão secundario (.T./.F.).
	Private lWDistr    := .T.
	Private nCoef      := 1
	Private nOpcInclui := 3
	Private nQaConpad  := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa		³
//³ ----------- Elementos contidos por dimensao ------------	³
//³ 1. Nome a aparecer no cabecalho								³
//³ 2. Nome da Rotina associada									³
//³ 3. Usado pela rotina										³
//³ 4. Tipo de Transa‡„o a ser efetuada							³
//³	 1 - Pesquisa e Posiciona em um Banco de Dados				³
//³	 2 - Simplesmente Mostra os Campos							³
//³	 3 - Inclui registros no Bancos de Dados					³
//³	 4 - Altera o registro corrente								³
//³	 5 - Remove o registro corrente do Banco de Dados			³
//³	 6 - Nao permite incluir linha na getdados					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aRotina     := MenuDef()

	Default lExt		:= .F. // Utilizado para chamada externa Movimentacoes entre Filiais

	QM6->(DbSetOrder(1))


	If lExt // Chamada externa
		nRet := A140Mae("QM6",0,3)
		Return nRet
	Else
		// Fluxo Padrão da rotina QMTA140
		If lQM140Brow
			ExecBlock("QM140BROW",.F.,.F.) // Ponto de entrada para efetuar filtro ou tratamento especifico antes da montagem da tela.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Browse com as Medicoes cadastradas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		QM6->(dbSetOrder(4))  // Utiliza o indice Instr+Rev+Data Invertida
		If ExistBlock("QM140MBRO")
			ExecBlock("QM140MBRO",.F.,.F.) // Ponto de entrada para alterar o browse padrao para o customizado
		Else
			mBrowse(06,01,22,75,"QM6")  // Utiliza o indice Instr+Rev+Data Invertida
		Endif
	Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140Mae	³ Autor ³ Fernando Godoy	    ³ Data ³ 09.98    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Inclusao/Alteracao/Visualizacao de Medi‡äes	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A140Mae(ExpC1,ExpN1,ExpN2) 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = Numero do registro 								  ³±±
±±³			 ³ ExpN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA140													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140Mae(cAlias,nReg,nOpcx)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea 		:= GetArea()
	Local lContinua	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Objeto para os Gets ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Local oMtRevIns
	Local oMtSeq

	Local oBtn
	Local oBtn1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Handles das Getdados utilizadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local ni 	 := 1
	Local oSayD
	Local nX 	 := 1
	Local lIntQNC:= If(GetMV("MV_QINTQNC")=="S",.T.,.F.) .And. !ExistBlock("QMT140IN")
	Local aSavQM6:= {}
	Local nOpca	 := 0
	Local nLin	 := 014
	Local aStruAlias 	:= FWFormStruct(3, cAlias)[3]
	Local lQMT140CS 	:= ExistBlock("QMT140CS")

	Local aSize         := FWGetDialogSize(oMainWnd) // Obtém a a área de trabalho e tamanho da dialog

	Private oArialRe	:= TFont():New("Arial",9,11,,.F.)
	Private oBtnX
	Private oBtnF
	Private oSayOk
	Private bCampo:= {|nCPO| Field( nCPO ) }
	Private lJaMontTre	:= .F.
	Private lAlerta       := .F.

	If nOpcx == 3
		Inclui := .T.
	Else
		Inclui := .F.
	Endif

//Declaracao de numericas
	Private nPosEsc		:= 0 //Posicao nas Escalas
	Private nPosPad		:= 0 //Posicao nos Padroes
	Private nPosEsp		:= 0 //Posicao do Especificado
	Private nPosMed		:= 0 //Posicao no Array com medicoes
	Private nPosObs		:= 0 //Posicao na Observacao
	Private nPosSec		:= 0 //Posicao no Array com padrao secundario
	Private nPosIns		:= 0 //Posicao no Array com instrumento utilizado
	Private nPosNco		:= 0 //Posicao no Array com as nao conformidades
	Private nPosITB		:= 0 //Posicao na Incerteza tipo B
	Private nPosCar		:= 0 //Posicao na String para referencia no Folder
	Private nPosExt		:= 0 //Posicao na String para referencia no Folder
	Private nPosGer		:= 0 //Posicao na String para referencia no Folder
	Private nPosTp5		:= 0 //Posicao do array para escala tipo 5
	Private nPosAmed	:= 1
	Private nPosAnt		:= 1
	Private nUsado		:= 0
	Private	nTam		:= 0
	Private	nTamSo		:= 0
	Private nDesPad
	Private nInsTot
	Private nAmbiente	:= 1
	Private nTeste		:= 0
	Private nStop		:= 2
//Private nHandle		:= -1
	Private nTipo
	Private nTipoMd
	Private nGetEsp		:= 0
	Private nGot		:= 1

//Declaracao dos objetos
	Private oCouNew		:= TFont():New("Courier New",5,0) //TFont():New("Mono AS",5,15)
	Private oArialBo	:= TFont():New("Arial",6,14,,.T.)
	Private oArial		:= TFont():New("Arial",5,13)
	Private oSymbol		:= TFont():New("Symbol",14,22,,.T.)
	Private oArialGr	:= TFont():New("Arial",11,14,,.F.)
	Private oBitmap		:= LoadBitmap( GetResources(),"DISABLE")
	Private oBtnEsc
	Private oLabExt
	Private oNroCer
	Private oBtnPad
	Private oSayMin
	Private oSayMax
	Private oSayLIE
	Private oSayLSE
	Private oCbxEsc
	Private oCbxPad
	Private oFolderFix
	Private oDlgPri
	Private oGetEsp
	Private oBtOk
	Private oEnchoice1
	Private oGetMed1
	Private oGetMed2
	Private oGetSec
	Private oGetIns
	Private oGetNco
	Private oGetITB
	Private oGetText

//Declaracao de array's
	Private aCols		:= {}
	Private aHeader		:= {}
	Private aMedicoes	:= {} // Variavel com todas as caracteristicas e informacoes para o Folder
	Private aObj		:= {}
	Private aEscPad		:= {}
	Private aTitMed		:= {STR0053,STR0054,STR0055,STR0056,STR0057,STR0058,STR0059}
	Private aPagMed		:= {STR0053,STR0054,STR0055,STR0056,STR0057,STR0058,STR0059}
	Private aObjetos	:= Array(13)
	Private aFolder		:= {}
	Private aGrvSeq		:= {}
	Private	aCpos		:= {}
	Private aColAnx		:= {}
	Private aHeadAnx    := {}
	Private aCpUs		:= {}
//Declaracao de caracteres
	Private cMtInstr	:= Iif(Inclui,CriaVar("QM6_INSTR",.F.),QM6->QM6_INSTR)
	Private cMtRevIns	:= Iif(Inclui,CriaVar("QM6_REVINS",.F.),QM6->QM6_REVINS)
	Private cMtResp		:= Iif(Inclui,CriaVar("QM6_RESP",.T. ),QM6->QM6_RESP)
	Private cMtTotHr	:= Iif(Inclui,CriaVar("QM6_TOTHOR",.F.),QM6->QM6_TOTHOR)
	Private cMtRepRepr	:= Iif(Inclui,CriaVar("QM6_REPEPR",.F.),QM6->QM6_REPEPR)
	Private cMtSeq		:= Iif(Inclui,CriaVar("QM6_CSEQ",.F.),QM6->QM6_CSEQ)
	Private cMtFilRes	:= Iif(Inclui,cFilAnt,QM6->QM6_FILRES)
	Private cSeql		:= Iif(Inclui,"00",QM6->QM6_CSEQ)
	Private cCoteam		:= Iif(Inclui,CriaVar("QM6_COTEAM",.F.),QM6->QM6_COTEAM)
	Private cVarial
	Private cFilMat
	Private cBaudRate	:= ""
	Private cParity		:= ""
	Private cData		:= ""
	Private cStop		:= ""
	Private cFreqSch	:= GetMv("MV_QFREQAF")
	Private cPorta		:= ""
	Private cTimeout	:= "5000"
	Private cTextos		:= Space(TamSX3("QA2_TEXTO")[1])
	Private cPadr		:= ""
	Private cEscal		:= ""

//Declaracao de logicas
	Private lRetUnid	:= .T.
	Private lTamSom		:= GetMv("MV_QMTPCES")=="1" //Para escalas do tipo soma considerar decimais definida na escala
	Private lEscSchu	:= GETMV("MV_QMTISHU")=="1"
	Private lRepLab := .T.
	Private lAtual	:= .T.
	Private lAtributo
	Private lUniGual
	Private lGerChav	:= .T.
	Private lOn := .T.
	Private lOnLine := .F.
	Private dMtData	  := Iif(Inclui,dDatabase,QM6->QM6_DATA)

	Private M->QM8_VLRINI := ""
	Private M->QM8_VLRFIM := ""
	Private M->QM8_VLRIND := ""
	Private M->QM8_VLRFID := ""

	Private oBmpEsc
	Private oBmpPad

	Private aHeadPre := {}
	Private aHeadRel := {}
	Private aHeadAtr := {}
	Private aHeadTot := {}
	Private aHeadSim := {}
	Private lConEnch := .T.
	Private cDQM2Des := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Muda ordem do QM6 para testar condicao de recebimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QM6->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara variaveis para enchoice  							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory("QM6",.T.)
	aCpos := {}

//Verifica se campo nao podem ser alterados
	For nX := 1 To Len(aStruAlias)
		If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL")
			If lQMT140CS
				ExecBlock("QMT140CS",.F.,.F.,{aCpos})
			Else
				If (AllTrim(aStruAlias[nX,1]) $ "QM6_INSTR/QM6_REVINS/QM6_CSEQ/QM6_DATA/QM6_FILRES/QM6_RESP/QM6_TOTHOR/QM6_REPEPR/QM6_NOME/QM6_COTEAM")
					Aadd(aCpos,aStruAlias[nX,1])
				Else
					If GetSx3Cache(aStruAlias[nX,1], "X3_PROPRI") == "U" .and. GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") <> "V"
						Aadd(aCpUs,aStruAlias[nX,1])
					Endif
				EndIf
			Endif
		EndIf
	Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro responsavel por sugerir usuario logado como calibrador³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF GetMV("MV_QSULOG") == "1" .And. INCLUI
		cMtResp	:= qmt140VlRer()
		M->QM6_RESP := cMtResp
		cFilRes := M->QM6_FILRES
		DbSelectArea("QAA")
		DbSetOrder(1)
		If QAA->(dbSeek(cFilRes+cMtResp))
			M->QM6_NOME := QAA->QAA_NOME
		EndIf
	Else
		cMtResp := QM6->QM6_RESP
	EndIf


	If nOpcx == 4
		aSavQM6 := {QM6->QM6_INSTR,QM6->QM6_REVINS,QM6->QM6_CSEQ,QM6->(Recno())}
		DbSelectArea("QM6")
		QM6->(DbSetOrder(2))
		If QM6->(DbSeek(xFilial("QM6")+aSavQM6[1]+aSavQM6[2]))
			If val(aSavQM6[3]) < val(QM6->QM6_CSEQ)
				MsgAlert(STR0116)
				Return .F.
			EndIf
		EndIf
		QM6->(DbGoTo(aSavQM6[4]))
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a tabela Schumacker Existe ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	lContinua := A140ChkSch()

	If lContinua .and. !Inclui
		lContinua := Qmt140DelCa(.T.,cMtInstr,dMtData,nOpcx)
		If lContinua
			If !A140Start(@lJaMontTre,cMtInstr,dMtData,cMtRepRepr,cMtResp,cMtTotHr,cMtRevIns,oDlgPri,oBtn,nOpcx,cMtSeq,oSayD)
				lContinua := .F.
			Endif
		Endif
	Endif

	nTipo   := Iif(Inclui .Or. Altera,GD_INSERT+GD_UPDATE+GD_DELETE,0)
	nTipoMd := Iif(Inclui .Or. Altera,GD_UPDATE+GD_DELETE,0)
//Verifica se existe todos os parametros para integracao com QNC
	If lContinua .And. lIntQNC
		lContinua := QNCMSGERA()
	Endif
	If lContinua
		nTipo := Iif(Inclui .Or. Altera,GD_INSERT+GD_UPDATE+GD_DELETE,0)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desenha a tela de Inclusao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlgPri TITLE cCadastro FROM aSize[1],aSize[2] TO aSize[3],aSize[4] OF GetWndDefault() PIXEL //40,80 TO 432,690 745
		If !Inclui
			dbSelectArea("QM6")
			For nI := 1 To FCount()
				M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
			Next nI
		Endif

		nLin := 001


		//oEnchoice1 := MsMGet():New("QM6", nReg, nOpcx,,,,aCpos,{030,002,110+nLin,381} )
		oEnchoice1 := MsMGet():New("QM6", nReg, nOpcx,,,,aCpos,{030,002,130+nLin,((aSize[4] / 2) - 002)} )
		oFolderFix := TFolder():New(145+nLin,002,aTitMed, aPagMed,oDlgPri,,,, .T., .F.,((aSize[4] / 2) - 004),aSize[3] / 2)
		Aeval(oFolderFix:aDialogs,{|x|x := oDlgPri:oFont})
		oFolderFix:lReadOnly := .T.

		For nX := 1 to Len(oFolderFix:aDialogs)
			DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolderFix:aDialogs[nX]
		Next nX

		//@ 120+nLin,81 SAY oSayD PROMPT STR0096 OF oDlgPri  FONT oArialGr COLOR CLR_BLUE PIXEL SIZE 200,10
		@ 134+nLin,002 BUTTON oBtn PROMPT STR0096/* ">>" */ OF oDlgPri SIZE 120,10 PIXEL

		If !Inclui
			//oSayD:Hide()
			oBtn:Hide()
		Endif

		If !Inclui
			oBtn:Disable()
			oBtn:Hide()
		EndIf

		If ExistBlock("QMT140MD")
			@ 20, 210 BUTTON oBtn1 PROMPT OemToAnsi(STR0037) OF oDlgPri SIZE 30,9 PIXEL ACTION { || ExecBlock("QMT140MD",.F.,.F.) }  // "COLETOR"
		EndIf

		If Inclui
			oBtn:bAction := {||A140Start(@lJaMontTre,@cMtInstr,@dMtData,@cMtRepRepr,@cMtResp,@cMtTotHr,;
				@cMtRevIns,oDlgPri,oBtn,nOpcx,@cMtSeq,@oSayD),oBtn:SetFocus()}
		Else
			If A140MoFirst(oDlgPri,@oBtn,nOpcx,@oSayD)
				lJaMontTre := .T.
			Endif
		EndIf

		nTipo := Iif(Inclui .Or. Altera,GD_INSERT+GD_UPDATE+GD_DELETE,0)
		IF FUNNAME()=="QMTA230"
			M->QM6_INSTR:=QN5->QN5_INSTR
			M->QM6_REVINS:=QN5->QN5_REVINS
		Endif
		If !Inclui
			A141AprPad(oDlgPri,oBmpPad,oBmpEsc)
		EndIf


		ACTIVATE MSDIALOG oDlgPri ON INIT (QMTA140EnBar(oDlgPri,{||nOpca:=1,Iif(lJaMontTre,(qmt140unmed(@lJaMontTre),Iif(lJaMontTre,(nPosAnt := nPosAmed,Iif(FQMT140MSG() .and. a141ContrFld(nGot := 2,oFolderFix:nOption) .and. A140GrvAll(oDlgPri,nOpcx),(QM140ClKey(),oDlgPri:End()),)),)),)},{ || nOpca:=0,QM140ClKey(),oDlgPri:End()},nOpcx)) CENTERED

		aRotina[3,4] := If(GETMV("MV_QMTIOPC")=="1",3,6)

		Release Objects oCouNew
		Release Objects oArialBo
		Release Objects oArial
		Release Objects oSymbol
		Release Objects oArialGr
		Release Objects oArialRe
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Muda ordem do QM6 para exibir mbrowse invertido ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QM6->(DbSetOrder(2))

	RestArea( aArea )

Return nOpca

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140Calc()³ Autor ³ Wanderley Gon‡alves   ³ Data ³ 13.03.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula resultado da medicao por linha 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A140Calc(ExpN1,ExpL1,ExpL2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Linha do aMedicoes que esta relacionada com a Po-  ³±±
±±³			 ³ sicao no Folder											  ³±±
±±³			 ³ ExpL1 - Retorna ou Nao a Incerte com base na do Tipo B	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto ³ 15/06/00 ³ Alteracoes para calibrar Tipo de Calibracao Re- ³±±
±±³          ³          ³ logio.                        				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140Calc( nLin_aMed, lRetIncTot )
	Local aRetorno  := {} // Array com todos os calculos das escalas
	Local cAceits   := "75"
	Local cCalInc   := GetMv("MV_QCALINC")
	Local cDesQuad  := GetMV("MV_DESQUAD") //Utiliza desvio ao quadrado
	Local cEscs     := ""
	Local cIncDm    := GetMv("MV_QINCDM")
	Local cIncDp    := GetMv("MV_QINCDP")
	Local cStatus   := "" // Status/Laudo da Medicao
	Local cSumItb   := GetMV("MV_QSUMITB")
	Local lAceit    := .F. // Condicao p/ Aceitacao satisfeita
	Local lAdeq     := .F. // Condicao p/ Adequacao satisfeita
	Local lCalPerc  := GetNewPar("MV_QCLPERC","2") == "1"
	Local lCalStu   := .T.
	Local lExat     := .F. // Condicao p/ Exatidao satisfeita
	Local lPaItb    := .F.
	Local lQM140STU := ExistBlock("QM140STU")
	Local lqmt140AI := ExistBlock("qmt140AI")
	Local lqmt140EI := ExistBlock("qmt140EI")
	Local lqmt140Ex := ExistBlock("qmt140Ex")
	Local lqmt140UI := ExistBlock("qmt140UI")
	Local lSPSec    := GetMv("MV_QMSOMED")=="1" //Soma incerteza de padroes secundarios/inst utilizado nas incertezas
	Local lStat     := .f. // Auxiliar para verificacao de status de medicao
	Local nCntFor   := 0
	Local nCoef     := 1 // Coeficiente de multiplicacao
	Local nDesvMed  := 0 // Guarda Valor do Desvio M‚dio ou Incerteza Sistem tica
	Local nDesvPad  := 0 // Guarda Valor do Desvio PadrÆo
	Local nErroInd  := 0 // Tipo de Calibracao Relogio - Erro de Indicacao
	Local nErroMax  := 0 // Valor do Erro M ximo
	Local nEspec    := 0 // Valor Especificado, para c lculo do Desvio M‚dio
	Local nIncInst  := 0 // Guarda Valor da Incerteza do Instrumento
	Local nIncIUt   := 0 // Guarda Valor da Incerteza Total dos Instr.Util.
	Local nIncPad   := 0 // Guarda Valor da Incerteza do Padrao Primario
	Local nIncPSe   := 0 // Guarda Valor da Incerteza Total dos Padroes Secundarios
	Local nIncTot   := 0 // Guarda Valor da Incerteza Total
	Local nInter    := 0 // Guarda Valor do Range
	Local nLaudo    := 0 // Guarda Status/Laudo para compara com escolha do usuario
    Local nLimInf   := 0
    Local nLimSup   := 0
	Local nLoop     := 0
	Local nMedia    := 0 // Guarda media das medicoes
	Local nPasso    := 1 //Iif(Len(aMedicoes[nLin_aMed,nPosMed,1]) > 2,2,1)
	Local nRngPdMn  := 0 // Range Minimo do Padrao ( Especificado - Tolerancia)
	Local nRngPdMx  := 0 // Range Maximo do Padrao ( Especificado + Tolerancia)
    Local nValEsp   := 0
    Local nValMed   := 0
	Local nx        := 1

	Private lFazITB		:= .F.

	If Type("lAlerta") == "U"
		Private lAlerta := .F.
	EndIf

	If !(aMedicoes[nLin_aMed,nPosGer,1,2]) $ "4|8"
		dbSelectArea("QM3")
		dbSetOrder(01)
		dbSeek(xFilial("QM3")+aMedicoes[nLin_aMed][nPosPad])
		cUniMed	:= QM3->QM3_UNIMED
		cEspec	:= QM3->QM3_ESPEC
	Else
		dbSelectArea("QMG")
		dbSetOrder(1)
		dbSeek(xFilial("QMG")+cMtInstr+cMtRevIns+aMedicoes[nLin_aMed][nPosPad])
		cUniMed	:= QMG->QMG_UNIMED
		cEspec	:= QMG->QMG_NOMIN
	Endif

	dbSelectArea("QM9")
	dbSetOrder(1)
	If !dbSeek(xFilial("QM9")+aMedicoes[nLin_aMed][nPosEsc])
		dbSeek(xFilial("QM9")+aMedicoes[nLin_aMed][nPosCar]) // Trat.Escala/Instr. Malha
	Endif

	If QM9->QM9_UNIMED <> cUniMed
		dbSelectArea("SAP")
		dbSetOrder(1)
		If dbSeek(xFilial("SAP")+cUniMed+QM9->QM9_UNIMED)
			nCoef := SAP->AP_COEF
		Endif
	Endif

	If aMedicoes[nLin_aMed,nPosGer,1,3] <> "A" .And. !Empty(aMedicoes[nLin_aMed,nPosMed])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³      For de 1 Ate o Numero colunas de medicoes       ³
		//³ Uma coluna para tipo simples e calibrador            ³
		//³ Duas colunas para tipo completo, cal.completo e soma ³
		//³ Quatro para o tipo pressao ou Relogio                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nPasso := 1 To (Len(aMedicoes[nLin_aMed,nPosMed,1])) - 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa Vari veis ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nCntFor		:= 0
			nMedia		:= 0
			nDesvMed 	:= 0
			nDesvPad 	:= 0
			nInter		:= 0
			nIncInst 	:= 0
			nIncTot		:= 0
			nIncIUt		:= 0
			nIncPSe		:= 0
			nEspec		:= 0
			nRngPdMx 	:= 0
			nRngPdMn 	:= 0
			nErroMax 	:= 0
			nLaudo		:= 0
			lExat 		:= .F.
			lAceit		:= .F.
			lAdeq 		:= .F.
			nErroInd	:= 0	// Tipo de Calibracao Relogio - Erro de Indicacao

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula m‚dia das medi‡oes							³
			//³ nMedia		  = (Medicoes) / aColMed[nLinaCols,1]	³
			//³ Medicoes	  = Soma das Medi‡oes					³
			//³ aMedicoes[nLin_aMed,nPosGer,1,1] := Nr. de Med		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If !Empty(aMedicoes[nLin_aMed,nPosMed])	// Caso coletar medicoes
				nMedia := QMT140cMed(nLin_aMed, nPasso)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula Desvio M‚dio (Incerteza Sistem tica)			   		³
			//³ - Determina o Valor Especificado								³
			//³																   	³
			//³ - Para Escalas de Tipo Igual a Calibrador e Cal.Completo	 	³
			//³	- Se aCols[nLinaCols,nPosNom] >= LIE e 						   	³
			//³  aCols[nLinaCols,nPosNom] <= LSE							   	³
			//³			nEspec := aCols[nLinaCols,nPosNom]					   	³
			//³	  SenÆo														   	³
			//³			nEspec := (LSE + LIE) / 2							   	³
			//³																   	³
			//³ - Para Escalas de Tipo Igual a Soma							   	³
			//³	nEspec := Especificado por Tipo Soma						   	³
			//³																   	³
			//³ - Para as demais Escalas									   	³
			//³	nEspec := nMedia											   	³
			//³																   	³
			//³ - Formula Geral: 											   	³
			//³	nDesvMed 			= nEspec / aCols[nLinaCols,nPosNom] 	   	³
			//³																   	³
			//³ Todos eles devem respeitar a data de validade. 				   	³
			//³																   	³
			//³ nEspec	= Valor a ser usado como Especificado				   	³
			//³ LIE		= Limite Inferior Especificado - de acordo com arquivo 	³
			//³ LSE		= Limite Superior Especificado - de acordo com arquivo 	³
			//³ nMedia				= M‚dia das Medi‡äes 					   	³
			//³ aCols[nLinaCols,nPosNom]	  = Valor Nominal do PadrÆo		   	³
			//³ 			 												   	³
			//³ - Tipo de Calibracao Relogio								   	³
			//³ nErroInd = nMedia - nEspec  								   	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o Tipo do padrao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aMedicoes[nLin_aMed,nPosGer,1,2] $ '4|8'
				QMG->(DbSetOrder(1))
				If QMG->(DbSeek(xFilial('QMG')+cMtInstr+cMtRevIns+aMedicoes[nLin_aMed,nPosPad]))
					If !((SuperVal(aMedicoes[nLin_aMed,nPosEsp]) >= SuperVal(QMG->QMG_LIE)) .and.;
							(SuperVal(aMedicoes[nLin_aMed,nPosEsp]) <= SuperVal(QMG->QMG_LSE)))
						Set decimal to QA_NUMDEC(QMG->QMG_LIE)
						nEspec := ((SuperVal(QMG->QMG_LIE) + SuperVal(QMG->QMG_LSE) ) / 2)*nCoef
					Else
						Set decimal to QA_NUMDEC(aMedicoes[nLin_aMed,nPosEsp])
						nEspec := SuperVal(aMedicoes[nLin_aMed,nPosEsp])*nCoef
					EndIf
				Else
					Set decimal to QA_NUMDEC(aMedicoes[nLin_aMed,nPosEsp])
					nEspec := SuperVal(aMedicoes[nLin_aMed,nPosEsp])*nCoef
				EndIf
			Else
				Set decimal to QA_NUMDEC(aMedicoes[nLin_aMed,nPosEsp])
				nEspec := SuperVal(aMedicoes[nLin_aMed,nPosEsp])/* *nCoef */
			EndIf

			If EMPTY(aMedicoes[nLin_aMed,nPosEsp]) .AND. aMedicoes[nLin_aMed,nPosGer,1,3] $ "O|S" .AND. !lAlerta
				MsgAlert(STR0115) //"Verifique os padroes deste instrumento Valor Nominal inconsistente"
				lAlerta := .T.
			EndIf

			nDesvMed := ABS((nMedia /* * nCoef */)  - nEspec)
			nErroInd := (nMedia - nEspec)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula Intervalo								   	 ³
			//³ nInter		  = nDesvMed + aColMed[nLinaCols,7] 	 ³
			//³ nDesvMed	  = Desvio m‚dio (Incerteza Sistem tica) ³
			//³ aColMed[nLinaCols,7] = Tolerƒncia do Padrao 		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If Alltrim(aMedicoes[nLin_aMed,nPosGer,1,21]) <> "1"
				nInter := nDesvMed + (nEspec * (SuperVal(aMedicoes[nLin_aMed,nPosGer,1,7,1])*nCoef))/100
			Else
				nInter := nDesvMed + SuperVal(aMedicoes[nLin_aMed,nPosGer,1,7,1])*nCoef
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula Desvio Padrao								  		   			³
			//³ nDesvPad = RaizQ((Somatoria (Medicoes - nMedia) ^2) / Num.Med - 1   )	³
			//³														    				³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento de Escala / Instrumento Malha - VER609³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(aMedicoes[nLin_aMed,nPosCar])
				cEscs := aMedicoes[nLin_aMed,nPosEsc]
			Else
				cEscs := aMedicoes[nLin_aMed,nPosCar]
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se MV_QINCDP == 'S'- Verificar se deve pegar o maior desvio    ³
			//³ padrao para calculo da incerteza                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If cIncDp == 'S'
				nDesvPad := QMT140MDP(cEscs,nPasso)
			Else
				nDesvPad := QMT140CDPd(nLin_aMed,nPasso)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula Incerteza do Instrumento						³
			//³ nIncInst	  = aStudent[( aColMed[nLinaCols,1] - 1 ) *	³
			//³					 (nDesvPad / sqrt(aColMed[nLinaCols,1]))³
			//³ aStudent[(aColMed[nLinaCols,1] - 1) = Tabela de Student ³
			//³ (No.Medicoes -1) 										³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If QM9->(DbSeek(xFilial("QM9")+cEscs+Inverte(aMedicoes[nLin_aMed,nPosGer,1,11])))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de Entrada para considera a tabela T-Student no calculo da incerteza  ³
				//³do instrumento.															   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lQM140STU
					lCalStu := ExecBlock("QM140STU",.F.,.F.)
				EndIf

				If Inclui
					If Empty(aMedicoes[nLin_aMed,nPosGer,1,17,1])
						If lCalStu
							nIncInst := RetStud((aMedicoes[nLin_aMed,nPosGer,1,1]-1),aMedicoes[nLin_aMed,nPosGer,1,14],.T.)
							nIncInst := nIncInst * (nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1]))
						Else
							nIncInst := nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1])
						EndIf
					Else
						If lCalStu
							//Deve-se calcular a incerteza do Tipo A, mesmo que exista incerteza do tipo B
							//pois a mesma e comparada na funcao que calcula incerteza do tipo B
							aMedicoes[nLin_aMed,nPosGer,1,16] := 0
							aMedicoes[nLin_aMed,nPosGer,1,16] := RetStud((aMedicoes[nLin_aMed,nPosGer,1,1]-1),aMedicoes[nLin_aMed,nPosGer,1,14],.T.)
							aMedicoes[nLin_aMed,nPosGer,1,16] := aMedicoes[nLin_aMed,nPosGer,1,16] * (nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1]))
						Else
							aMedicoes[nLin_aMed,nPosGer,1,16] := nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1])
						EndIf

						If At(aMedicoes[nLin_aMed,nPosGer,1,17,1],".") == 0
							aMedicoes[nLin_aMed,nPosGer,1,17,1] := StrTran(aMedicoes[nLin_aMed,nPosGer,1,17,1],".",",")
						Endif

						If cSumItb == "1" //Somar incerteza tipo A com Incerteza tipo B
							If lCalStu
								nIncInst := RetStud((aMedicoes[nLin_aMed,nPosGer,1,1]-1),aMedicoes[nLin_aMed,nPosGer,1,14],.T.)
								nIncInst := nIncInst * (nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1]))
							Else
								nIncInst := nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1])
							EndIf

							nIncInst := nIncInst + SuperVal(aMedicoes[nLin_aMed,nPosGer,1,17,1]) //Ui -> incerteza tipo B
						Else
							nIncInst := SuperVal(aMedicoes[nLin_aMed,nPosGer,1,17,1])
						Endif
					Endif
				Else
					dbSelectArea("QMX")
					dbSetOrder(01)
					If !dbSeek(xFilial("QMX")+cMtInstr+cMtRevIns+DtoS(dMtData))
						If Empty(aMedicoes[nLin_aMed,nPosGer,1,17,1])
							For nx := 1 To Len(aMedicoes[nLin_aMed,nPosItb])
								If !aMedicoes[nLin_aMed,nPosItb,nx,10]
									lPaItb := .T.
									If lCalStu
										nIncInst := RetStud((aMedicoes[nLin_aMed,nPosGer,1,1]-1),aMedicoes[nLin_aMed,nPosGer,1,14],.T.)
										nIncInst := nIncInst * (nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1]))
									Else
										nIncInst := nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1])
									EndIf
								Endif
							Next nx
							//Associa a incerteza do tipo A somente...
							If !lPaItb
								If lCalStu
									aMedicoes[nLin_aMed,nPosGer,1,16] := RetStud((aMedicoes[nLin_aMed,nPosGer,1,1]-1),aMedicoes[nLin_aMed,nPosGer,1,14],.T.)
									aMedicoes[nLin_aMed,nPosGer,1,16] := aMedicoes[nLin_aMed,nPosGer,1,16] * (nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1]))
								Else
									aMedicoes[nLin_aMed,nPosGer,1,16] := nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1])
								EndIf
								nIncInst := aMedicoes[nLin_aMed,nPosGer,1,16]
							Endif
						Else
							If lCalStu
								aMedicoes[nLin_aMed,nPosGer,1,16] := 0
								aMedicoes[nLin_aMed,nPosGer,1,16] := RetStud((aMedicoes[nLin_aMed,nPosGer,1,1]-1),aMedicoes[nLin_aMed,nPosGer,1,14],.T.) // Estava = 0
								aMedicoes[nLin_aMed,nPosGer,1,16] := aMedicoes[nLin_aMed,nPosGer,1,16] * (nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1]))
							Else
								aMedicoes[nLin_aMed,nPosGer,1,16] := nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1])
							EndIf

							If At(aMedicoes[nLin_aMed,nPosGer,1,17,1],".") == 0
								aMedicoes[nLin_aMed,nPosGer,1,17,1] := StrTran(aMedicoes[nLin_aMed,nPosGer,1,17,1],".",",")
							Endif

							For nx := 1 To Len(aMedicoes[nLin_aMed,nPosItb])
								If !aMedicoes[nLin_aMed,nPosItb,nx,10]
									lPaItb := .T.
									If lCalStu
										nIncInst := RetStud((aMedicoes[nLin_aMed,nPosGer,1,1]-1),aMedicoes[nLin_aMed,nPosGer,1,14],.T.)
										nIncInst := nIncInst * (nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1]))
									Else
										nIncInst := nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1])
									EndIf
								Endif
							Next nx
							If cSumItb == "1" //Somar Incerteza tipo A com Incerteza tipo B
								If lCalStu
									nIncInst := RetStud((aMedicoes[nLin_aMed,nPosGer,1,1]-1),aMedicoes[nLin_aMed,nPosGer,1,14],.T.)
									nIncInst := nIncInst * (nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1]))
								Else
									nIncInst := nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1])
								EndIf
								nIncInst := nIncInst + SuperVal(aMedicoes[nLin_aMed,nPosGer,1,17,1])
							Else
								If lPaItb
									nIncInst := SuperVal(aMedicoes[nLin_aMed,nPosGer,1,17,1])
								Else
									nIncInst := aMedicoes[nLin_aMed,nPosGer,1,16]
								Endif
							Endif
						Endif
					Else
						If lCalStu
							aMedicoes[nLin_aMed,nPosGer,1,16] := 0
							aMedicoes[nLin_aMed,nPosGer,1,16] := RetStud((aMedicoes[nLin_aMed,nPosGer,1,1]-1),aMedicoes[nLin_aMed,nPosGer,1,14],.T.)//Estava = 0
							aMedicoes[nLin_aMed,nPosGer,1,16] := aMedicoes[nLin_aMed,nPosGer,1,16] * (nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1]))
						Else
							aMedicoes[nLin_aMed,nPosGer,1,16] := nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1])
						EndIf

						If At(aMedicoes[nLin_aMed,nPosGer,1,17,1],".") == 0
							aMedicoes[nLin_aMed,nPosGer,1,17,1] := StrTran(aMedicoes[nLin_aMed,nPosGer,1,17,1],".",",")
						Endif

						If cSumItb == "1" //Somar incerteza tipo A com Incerteza tipo B
							If lCalStu
								nIncInst := RetStud((aMedicoes[nLin_aMed,nPosGer,1,1]-1),aMedicoes[nLin_aMed,nPosGer,1,14],.T.)
								nIncInst := nIncInst * (nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1]))
							Else
								nIncInst := nDesvPad / Sqrt(aMedicoes[nLin_aMed,nPosGer,1,1])
							EndIf
							nIncInst := nIncInst + SuperVal(aMedicoes[nLin_aMed,nPosGer,1,17,1])
						Else
							nIncInst := SuperVal(aMedicoes[nLin_aMed,nPosGer,1,17,1])
						Endif

						If Empty(aMedicoes[nLin_aMed,nPosGer,1,17,1])
							lFazITB := .T.
						Endif

						If lFazITB
							a140CalITB(nLin_aMed) //Chamada da Funcao para Calcudo da Incerteza Combinada e Expandida
							lFazITB := .F.
						Endif
					EndIf
				Endif
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula Incerteza Total													³
			//³																			³
			//³ Parƒmetros 																³
			//³ - nIncInst -> Incerteza do Instrumento									³
			//³ - nDesvMed -> Desvio M‚dio												³
			//³ - nIncPad	-> Incerteza do Padrao Primario								³
			//³ - nRR		-> indice de RR (QM6->QM6_REPERR)							³
			//³ - nIncPSe	-> Incerteza Total dos Padroes Secundarios					³
			//³ - nIncIUt	-> Incerteza Total dos Instrum.Utilizados 					³
			//³ Obs: Seguir  a regra de quadr tica ou alg‚brica tamb‚m para cal-  		³
			//³					cular a incerteza total dos Instr.Util e do Padroes 	³
			//³					Secundarios 									  		³
			//³																	  		³
			//³ Se parametro MV_QCALINC == '1' (Incerteza p/ Soma Alg‚brica)      		³
			//³																	  		³
			//³ nIncTot := nIncInst + nIncPad + nIncIUt + nIncPSe + nRR + nDesvMed 		³
			//³														 	  				|             				|
			//³	Se parametro															|
			//|		 MV_QINCRR = "S"   <+	  +>MV_QINCDM = "S"							|
			//³																	  		³
			//³ Se parametro MV_QCALINC == '2' (Incerteza p/ Soma Quadr tica)     		³
			//³																	  		³
			//³ nIncTot := 														  		³
			//³ (nIncInst)^2+(nIncPad)^2+(nIncIUt)^2+(nIncPSe)^2+(nRR)^2+(nDesvMed)^2	³
			//³																			|
			//³	Se parametro															|
			//|	MV_QINCRR = "S" 														| 									  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura a Incerteza do Padrao Primario							  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nIncPad := SuperVal(aMedicoes[nLin_aMed,nPosGer,1,13])*nCoef

			If cCalInc == '1' // Soma Alg‚brica - MV_QCALINC

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula Incerteza dos Instrumentos Utilizados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				For nLoop := 1 To Len(aMedicoes[nLin_aMed,nPosIns])

					If !aMedicoes[nLin_aMed,nPosIns,nLoop,Len(aMedicoes[nLin_aMed,nPosIns,1])]
						nIncIUt += (SuperVal(aMedicoes[nLin_aMed,nPosIns,nLoop,3])*1000000)*nCoef
					EndIf
				Next nLoop

				nIncIUt := nIncIUt/1000000
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula Incerteza dos Padroes Secundarios ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nLoop := 1 To Len(aMedicoes[nLin_aMed,nPosSec])
					If ValType(aMedicoes[nLin_aMed,nPosSec,nLoop,Len(aMedicoes[nLin_aMed,nPosSec,1])]) $ "D"
						nPos := 4
					Else
						nPos := Len(aMedicoes[nLin_aMed,nPosSec,1])
					EndIf
					If !aMedicoes[nLin_aMed,nPosSec,nLoop,nPos]
						nIncPSe += (SuperVal(aMedicoes[nLin_aMed,nPosSec,nLoop,3])*1000000)*nCoef
					EndIf
				Next nLoop

				nIncPSe := nIncPSe/1000000

				If !empty(aMedicoes[nLin_aMed,nPosGer,1,17,2]) //Verifica Inc.Tipo B
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Caso o parametro MV_QSUMITB esteja com conteudo "1", somar³
					//³a incerteza do tipo A com incerteza do tipo B.            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cSumItb == "2" //MV_QSUMITB
						If lPaItb
							nIncTot := Val(aMedicoes[nLin_aMed,nPosGer,1,17,2])
						Else
							// Se parameto desvio medio no calculo de incerteza estiver ativo - MV_QINCDM
							If cIncDm == "S"
								If lSPSec
									nIncTot := nIncInst + nIncPad + nIncIUt + nIncPSe + SuperVal(cMtRepRepr)*nCoef+nDesvMed+Val(aMedicoes[nLin_aMed,nPosGer,1,17,2])
								Else
									nIncTot := nIncInst + nIncPad + SuperVal(cMtRepRepr)*nCoef+nDesvMed+Val(aMedicoes[nLin_aMed,nPosGer,1,17,2])
								Endif
							Else
								If lSPSec
									nIncTot := nIncInst + nIncPad + nIncIUt + nIncPSe + SuperVal(cMtRepRepr)*nCoef+Val(aMedicoes[nLin_aMed,nPosGer,1,17,2])
								Else
									nIncTot := nIncInst + nIncPad + SuperVal(cMtRepRepr)*nCoef+Val(aMedicoes[nLin_aMed,nPosGer,1,17,2])
								Endif
							EndIF
						Endif
					Else
						// Se parameto desvio medio no calculo de incerteza estiver ativo - MV_QINCDM
						If cIncDm == "S"
							If lSPSec
								nIncTot := nIncInst + nIncPad + nIncIUt + nIncPSe + SuperVal(cMtRepRepr)*nCoef+nDesvMed+Val(aMedicoes[nLin_aMed,nPosGer,1,17,2])
							Else
								nIncTot := nIncInst + nIncPad + SuperVal(cMtRepRepr)*nCoef+nDesvMed+Val(aMedicoes[nLin_aMed,nPosGer,1,17,2])
							Endif
						Else
							If lSPSec
								nIncTot := nIncInst + nIncPad + nIncIUt + nIncPSe + SuperVal(cMtRepRepr)*nCoef+Val(aMedicoes[nLin_aMed,nPosGer,1,17,2])
							Else
								nIncTot := nIncInst + nIncPad + SuperVal(cMtRepRepr)*nCoef+Val(aMedicoes[nLin_aMed,nPosGer,1,17,2])
							Endif
						EndIF
					Endif
				Else
					If cIncDm == "S" // Se parameto desvio medio no calculo de incerteza estiver ativo - MV_QINCDM
						If lSPSec
							nIncTot := nIncInst + nIncPad + nIncIUt + nIncPSe + SuperVal(cMtRepRepr)*nCoef+ nDesvMed
						Else
							nIncTot := nIncInst + nIncPad + SuperVal(cMtRepRepr)*nCoef+ nDesvMed
						Endif
					Else
						If lSPSec
							nIncTot := nIncInst + nIncPad + nIncIUt + nIncPSe + SuperVal(cMtRepRepr)*nCoef
						Else
							nIncTot := nIncInst + nIncPad + SuperVal(cMtRepRepr)*nCoef
						Endif
					EndIF
				Endif
			ElseIf cCalInc == '2' // Soma Quadr tica

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula Incerteza dos Instrumentos Utilizados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nLoop := 1 To Len(aMedicoes[nLin_aMed,nPosIns])
					If !aMedicoes[nLin_aMed,nPosIns,nLoop,Len(aMedicoes[nLin_aMed,nPosIns,1])]
						nIncIUt += ((SuperVal(aMedicoes[nLin_aMed,nPosIns,nLoop,3])*1000000)**2)*nCoef
					Endif
				Next

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula Incerteza dos Padroes Secundarios ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nLoop := 1 To Len(aMedicoes[nLin_aMed,nPosSec])
					If ValType(aMedicoes[nLin_aMed,nPosSec,nLoop,Len(aMedicoes[nLin_aMed,nPosSec,1])]) $ "D"
						nPos := 4
					Else
						nPos := Len(aMedicoes[nLin_aMed,nPosSec,1])
					EndIf
					If !aMedicoes[nLin_aMed,nPosSec,nLoop,nPos]
						nIncPSe += ((SuperVal(aMedicoes[nLin_aMed,nPosSec,nLoop,3])*1000000)**2)*nCoef
					Endif
				Next nLoop

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ ATENCAO: nIncIUT e nIncPSe ja estao elevados ao quadrado ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If !empty(aMedicoes[nLin_aMed,nPosGer,1,17,2]) //Verifica Inc.Tipo B
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Caso o parametro MV_QSUMITB esteja com conteudo "1", somar³
					//³a incerteza do tipo A com incerteza do tipo B.            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cSumItb == "2"
						nIncTot :=	Val(aMedicoes[nLin_aMed,nPosGer,1,17,2])
					Else
						// Se parameto desvio medio no calculo de incerteza estiver ativo - MV_QINCDM
						If cIncDm == "S"
							nIncTot := Iif (nIncInst!=0,(nIncInst*1000000)**2,0)
							nIncTot += Iif (nIncPad !=0,(nIncPad*1000000)**2 ,0)
							If lSPSec
								nIncTot += Iif (nIncIUt !=0,nIncIUt, 0)
								nIncTot += Iif (nIncPse !=0,nIncPse, 0)
							Endif
							If !empty(cMtRepRepr)
								nIncTot += (SuperVal(cMtRepRepr)*nCoef*1000000) //Verificar se esta ok com nCoef - Denis
							EndIf
							nIncTot += Iif (nDesvMed !=0, (nDesvMed*1000000)**2,0)
							nIncTot +=	(Val(aMedicoes[nLin_aMed,nPosGer,1,17,2])*1000000)
							nIncTot := Sqrt(nIncTot)/1000000
						Else
							nIncTot := Iif (nIncInst!=0,(nIncInst*1000000)**2,0)
							nIncTot += Iif (nIncPad !=0,(nIncPad*1000000)**2 ,0)
							If lSPSec
								nIncTot += Iif (nIncIUt !=0,nIncIUt, 0)
								nIncTot += Iif (nIncPse !=0,nIncPse, 0)
							Endif
							If !empty(cMtRepRepr)
								nIncTot += (SuperVal(cMtRepRepr)*1000000)
							EndIf
							nIncTot +=	(Val(aMedicoes[nLin_aMed,nPosGer,1,17,2])*1000000)
							nIncTot := Sqrt(nIncTot)/1000000
						EndIf
					Endif
				Else
					// Se parameto desvio medio no calculo de incerteza estiver ativo - MV_QINCDM
					If cIncDm == "S"
						nIncTot := Iif (nIncInst!=0,(nIncInst*1000000)**2,0)
						nIncTot += Iif (nIncPad !=0,(nIncPad*1000000)**2 ,0)
						If lSPSec
							nIncTot += Iif (nIncIUt !=0,nIncIUt, 0)
							nIncTot += Iif (nIncPse !=0,nIncPse, 0)
						Endif
						If !empty(cMtRepRepr)
							nIncTot += (SuperVal(cMtRepRepr)*nCoef*1000000) //Verificar se esta ok com nCoef - Denis
						EndIf
						nIncTot += Iif (nDesvMed !=0, (nDesvMed*1000000)**2,0)
						nIncTot := Sqrt(nIncTot)/1000000
					Else
						nIncTot := Iif (nIncInst!=0,(nIncInst*1000000)**2,0)
						nIncTot += Iif (nIncPad !=0,(nIncPad*1000000)**2 ,0)
						If lSPSec
							nIncTot += Iif (nIncIUt !=0,nIncIUt, 0)
							nIncTot += Iif (nIncPse !=0,nIncPse, 0)
						Endif
						If !empty(cMtRepRepr)
							nIncTot += (SuperVal(cMtRepRepr)*1000000)
						EndIf
						nIncTot := Sqrt(nIncTot)/1000000
					EndIf
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula Erro Maximo 										 ³
			//³ Se parametro MV_QCALINC == '1' (Incerteza p/ Soma Alg‚brica) ³
			//³	 nErroMax  = nIncTot + nDesvMed								 ³
			//³ Se parametro MV_QCALINC == '2' (Incerteza p/ Soma Quadr tica)³
			//³	 nErroMax  = Sqrt( (nIncTot)^2 + (nDesvMed)^2 ) 			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de Entrada para calculo de ERRO MAXIMO em MEDICOES INTERNAS. Deve-se  ³
			//³observar que os parametros MV_QINCDM(Soma Desvio Medio no Erro Maximo) e o  ³
			//³Parametro MV_QCALINC( considera Soma Algebrica ou Quadratica, ficara sendo  ³
			//³tratado dentro desse rdmake, dependendo da necessidade do cliente           ³
			//³Observa-se tambem que o retorno SEMPRE devera ser Numerico.                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If lqmt140EI
				nErroMax := ExecBlock("qmt140EI",.F.,.F.,{nIncTot,nDesvMed,nDesvPad,SuperVal(aMedicoes[nLin_aMed,nPosGer,1,17,1]),nIncTot-SuperVal(aMedicoes[nLin_aMed,nPosGer,1,17,1])})
			Else
				If cIncDm == "S" // Se somou o desvio medio no calculo de incerteza - MV_QINCDM
					nErroMax := nIncTot      // nao somar novamente o desvio medio
				Else
					If cCalInc == '1' // Soma Alg‚brica - MV_QCALINC
						nErroMax := nIncTot+ nDesvMed
					ElseIf cCalInc == '2' // Soma Quadr tica - MV_QCALINC
						nErroMax := (nIncTot*1000000)**2
						nErroMax += (nDesvMed*1000000)**2
						nErroMax := Sqrt(nErroMax)/1000000
					EndIf
				EndIf
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibe resultado para Laudo = Incerteza com Confirmacao Metrologica³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aMedicoes[nLin_aMed,nPosGer,1,6] == "1"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula Range para padrao 										  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If aMedicoes[nLin_aMed,nPosGer,1,2] $ "4|8"
					nRngPdMx := SuperVal(QMG->QMG_LSE)
					nRngPdMn := SuperVal(QMG->QMG_LIE)
				Else
					If Alltrim(aMedicoes[nLin_aMed,nPosGer,1,21]) <> "1"
						nRngPdMx := nEspec + (nEspec * (SuperVal(aMedicoes[nLin_aMed,nPosGer,1,7,1])*nCoef))/100
						nRngPdMn := nEspec - (nEspec * (SuperVal(aMedicoes[nLin_aMed,nPosGer,1,7,2])*nCoef))/100
					Else
						nRngPdMx := nEspec + SuperVal(aMedicoes[nLin_aMed,nPosGer,1,7,1])*nCoef
						nRngPdMn := nEspec - SuperVal(aMedicoes[nLin_aMed,nPosGer,1,7,2])*nCoef
					Endif
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Indice de Exatidao													³
				//³ Se QMR->QMR_PREC (Precisao Instrumento na escala) est  cadastrada	³
				//³		QMR->QMR_PREC >= nInter 	  E									³
				//³		nRngPdMn <= nMedia			  E									³
				//³		nRngPdMx >=	nMedia												³
				//³ senao																³
				//³		nRngPdMn <= nMedia			  E									³
				//³		nRngPdMx >=	nMedia												³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If lqmt140Ex
					lExat := ExecBlock("qmt140Ex",.F.,.F.,{nEspec,nMedia,QMR->QMR_PREC,nInter,nRngPdMn,nRngPdMx})
				Else
					If aMedicoes[nLin_aMed,nPosGer,1,1] == 0
						lExat := .T.	// Quando for medicao externa sem medicoes, nao existe
						// este calculo. Portanto, considerar Aceito
					Else
						lExat := nRngPdMn <= nMedia

						If lExat
							lExat := nRngPdMx >= nMedia
						EndIf

						If lExat
							QMR->(DbSetOrder(1))
							If QMR->(DbSeek(xFilial("QMR")+cMtInstr+cMtRevIns+cEscs))
								If !Empty(QMR->QMR_PREC)
									lExat := SuperVal(QMR->QMR_PREC) >= nInter
								EndIF
							EndIf
						EndIf
					EndIf
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Indice de Aceitabilidade (Obs.: Espec/Redutor p/Escala p/Instr.	³
				//³ nErroMax	<													³
				//³		(Superval(QMR->QMR_TOLPRO)/100)*(Especifica‡Æo do Processo / Redutor do Processo)	³
				//³			 	 ( QMR->QMR_TOLPRO 		    /	  QMR->QMR_REDUT )	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QMR->(DbSetOrder(1))
				If QMR->(DbSeek(xFilial("QMR")+cMtInstr+cMtRevIns+cEscs))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ponto de Entrada para Criterio de Aceitabilidade em MEDICOES INTERNAS.   ³
					//³Deve-se observar que o Parametro MV_DESQUAD(Considera o Desvio Medio,    ³
					//³na formula de Aceitabilidade(Calculo Padrao))sera considerado dentro do  ³
					//³Rdmake, conforme necessidade do cliente.                                 ³
					//³O retorno desse ponto de entrada SEMPRE devera ser logico.				³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If lqmt140AI
						lAceit := ExecBlock("qmt140AI",.F.,.F.,{nErroMax,nIncTot,nDesvMed})
					Else
						cAceits := QMR->QMR_ACEITA
						If Empty(QMR->QMR_ACEITA)
							cAceits := "75"
						Endif
						If Alltrim(cDesQuad) == "S"
							If lCalPerc .and. aMedicoes[nLin_aMed,nPosGer,1,21] == "2"
								lAceit := nErroMax < ( (Superval(cAceits)/100) *;
									(((Superval(QMR->QMR_TOLPRO)/100)*SuperVal(aMedicoes[nLin_aMed,nPosEsp])) / SuperVal(QMR->QMR_REDUT)))
							Else
								lAceit := nErroMax < ( (Superval(cAceits)/100) *;
									(Superval(QMR->QMR_TOLPRO) / SuperVal(QMR->QMR_REDUT) ))
							Endif
						Else
							If lCalPerc .and. aMedicoes[nLin_aMed,nPosGer,1,21] == "2"
								lAceit := nDesvMed+nInctot < ( (Superval(cAceits)/100) *;
									(((Superval(QMR->QMR_TOLPRO)/100)*SuperVal(aMedicoes[nLin_aMed,nPosEsp])) / SuperVal(QMR->QMR_REDUT)))
							Else
								IF !EMPTY(QMR->QMR_TOLPRO) .AND. !EMPTY(QMR->QMR_REDUT) 
									lAceit := nDesvMed+nInctot < ( (Superval(cAceits)/100) *;
										(Superval(QMR->QMR_TOLPRO) / SuperVal(QMR->QMR_REDUT) ))
								ELSE
									lAceit := lExat
								ENDIF
							Endif
						Endif
					Endif
				Else
					lAceit := .f.
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Indice de Adequa‡ao ao Uso										  ³
				//³ nErroMax < (Especifica‡ao do Processo / Redutor do Processo)	  ³
				//³						  QMR->QMR_TOLPRO 		/	  QMR->QMR_REDUT) ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !QMR->(Eof())

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ponto de Entrada para Criterio de Adequacao ao USO em MEDICOES INTERNAS.		³
					//³Deve-se observar que o Parametro MV_DESQUAD(Considera o Desvio Medio,		³
					//³na formula de Adequacao(Calculo Padrao))sera considerado dentro do Rdmake,	³
					//³conforme necessidade do cliente.                                   			³
					//³O retorno desse ponto de entrada SEMPRE devera ser logico. 					³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If lqmt140UI
						lAdeq := ExecBlock("qmt140UI",.F.,.F.,{nErroMax,nDesvMed,nIncTot})
					Else
						If Alltrim(cDesQuad) == "S"
							If lCalPerc .and. aMedicoes[nLin_aMed,nPosGer,1,21] == "2"
								lAdeq :=  nErroMax <= (((Superval(QMR->QMR_TOLPRO)/100)*SuperVal(aMedicoes[nLin_aMed,nPosEsp])) / SuperVal(QMR->QMR_REDUT))
							Else
								lAdeq :=  nErroMax <= ( SuperVal(QMR->QMR_TOLPRO) / SuperVal(QMR->QMR_REDUT) )
							Endif
						Else
							If lCalPerc .and. aMedicoes[nLin_aMed,nPosGer,1,21] == "2"
								lAdeq :=  nDesvMed+nIncTot <= (((Superval(QMR->QMR_TOLPRO)/100)*SuperVal(aMedicoes[nLin_aMed,nPosEsp])) / SuperVal(QMR->QMR_REDUT))
							Else
								If !EMPTY(QMR->QMR_TOLPRO) .AND. !EMPTY(QMR->QMR_REDUT) //Tolerancia e Redutor preenchidos
									lAdeq :=  nDesvMed+nIncTot <= ( SuperVal(QMR->QMR_TOLPRO) / SuperVal(QMR->QMR_REDUT) )
								Endif
								If EMPTY(QMR->QMR_TOLPRO) .AND. EMPTY(QMR->QMR_REDUT) //Tolerancia e Redutor em branco
									lAdeq:= lExat
								Endif
								If EMPTY(QMR->QMR_TOLPRO) .AND. !EMPTY(QMR->QMR_REDUT) //Tolerancia em branco e Redutor preenchido
									lAdeq :=  nDesvMed+nIncTot <= ( SuperVal(QMR->QMR_REDUT) / 1)
								Endif
								If !EMPTY(QMR->QMR_TOLPRO) .AND. EMPTY(QMR->QMR_REDUT) //Tolerancia preenchida e Redutor em branco
									lAdeq :=  nDesvMed+nIncTot <= ( SuperVal(QMR->QMR_TOLPRO) / 1 )
								Endif 
							Endif
						Endif
					Endif
				Else
					lAdeq := .f.
				EndIf

				If !aMedicoes[nLin_aMed,nPosGer,1,3] == "A"
					If lExat .and. lAceit .and. lAdeq
						cStatus := 'A'
					Else
						cStatus := 'R'
					EndIf
				Else
					If aMedicoes[nLin_aMed,nPosGer,1,3] == "A"
						cStatus := aMedicoes[nLin_aMed,nPosMed,1,1]
					Else
						cStatus := 'R'
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exibe resultado para Laudo = Incerteza sem Confirmacao Metrologica³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf aMedicoes[nLin_aMed,nPosGer,1,6] == "2"

				If Empty(aMedicoes[nLin_aMed][nPosCar])
					cEscs := aMedicoes[nLin_aMed][nPosEsc]
				Else
					cEscs := aMedicoes[nLin_aMed][nPosCar]
				Endif

				QMR->(DbSetOrder(1))
				If QMR->(DbSeek(xFilial("QMR")+cMtInstr+cMtRevIns+cEscs))

					If nIncTot <= SuperVal(QMR->QMR_INPERM)
						If nErroMax <= SuperVal(QMR->QMR_INPERM)
							cStatus := 'A'
						Else
							cStatus := 'R'
						EndIf
					Else
						cStatus := 'R'
					EndIf
				Else
					cStatus := 'R'
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exibe resultado para Laudo = Valor  Encontrado/Media 			  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf aMedicoes[nLin_aMed,nPosGer,1,6] == '3'
				If aMedicoes[nLin_aMed,nPosGer,1,2] $ '1,2,3,5,9'
					If Alltrim(aMedicoes[nLin_aMed,nPosGer,1,21]) <> "1"
						If nMedia < SuperVal(aMedicoes[nLin_aMed,nPosEsp])*nCoef - ((SuperVal(aMedicoes[nLin_aMed,nPosEsp])*SuperVal(aMedicoes[nLin_aMed,nPosGer,1,7,2])/100)*nCoef)  .or.;
								nMedia > SuperVal(aMedicoes[nLin_aMed,nPosEsp])*nCoef + ((SuperVal(aMedicoes[nLin_aMed,nPosEsp])*SuperVal(aMedicoes[nLin_aMed,nPosGer,1,7,1])/100)*nCoef)
							cStatus := 'R'
						Else
							cStatus := 'A'
						EndIf
					Else
						If nMedia < SuperVal(aMedicoes[nLin_aMed,nPosEsp])*nCoef - SuperVal(aMedicoes[nLin_aMed,nPosGer,1,7,2])*nCoef  .or.;
								nMedia > SuperVal(aMedicoes[nLin_aMed,nPosEsp])*nCoef + SuperVal(aMedicoes[nLin_aMed,nPosGer,1,7,1])*nCoef
							cStatus := 'R'
						Else
							cStatus := 'A'
						EndIf
					Endif
				ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] $ '4|8'
					If nMedia < SuperVal(QMG->QMG_LIE)  .or.;
							nMedia > SuperVal(QMG->QMG_LSE)
						cStatus := 'R'
					Else
						cStatus := 'A'
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exibe resultado para Laudo = Valor Encontrado/Valores Individuais ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf aMedicoes[nLin_aMed,nPosGer,1,6] == '4'
				cStatus := 'A'
				If aMedicoes[nLin_aMed,nPosGer,1,2] $ '1|2|3|5|9'
					For nCntFor := 1 to aMedicoes[nLin_aMed,nPosGer,1,1] // Quantidade de Medicoes
						If Alltrim(aMedicoes[nLin_aMed,nPosGer,1,21]) <> "1"
							nValMed := SuperVal(aMedicoes[nLin_aMed,nPosMed,nCntFor,nPasso])*nCoef //Medição Informada
							nValEsp := SuperVal(aMedicoes[nLin_aMed,nPosEsp])*nCoef                //Valor nominal
							nLimInf := SuperVal(aMedicoes[nLin_aMed,nPosGer,1,7,2])*nCoef          //Limite inferior
							nLimSup := SuperVal(aMedicoes[nLin_aMed,nPosGer,1,7,1])*nCoef          //Limite Superior

							If nValMed < Round(Iif(!empty(aMedicoes[nLin_aMed,nPosGer,1,7,2]), nValEsp - ( nValEsp *( nLimInf/100)),0), nTam); //nTam -> QA_NUMDEC(QM9->QM9_ESCALI)
							   .OR. ;
							   nValMed > Round(Iif(!empty(aMedicoes[nLin_aMed,nPosGer,1,7,1]), nValEsp + ( nValEsp *( nLimSup/100)),0), nTam)  //nTam -> QA_NUMDEC(QM9->QM9_ESCALI)
										cStatus:='R'
									EndIf
								Else
									If SuperVal(aMedicoes[nLin_aMed,nPosMed,nCntFor,nPasso])*nCoef <;
											SuperVal(aMedicoes[nLin_aMed,nPosEsp])*nCoef - ;
											If(!empty(aMedicoes[nLin_aMed,nPosGer,1,7,2]),;
												SuperVal(aMedicoes[nLin_aMed,nPosGer,1,7,2])*nCoef,0) .OR.;
												SuperVal(aMedicoes[nLin_aMed,nPosMed,nCntFor,nPasso])*nCoef >;
												SuperVal(aMedicoes[nLin_aMed,nPosEsp])*nCoef + ;
												If(!empty(aMedicoes[nLin_aMed,nPosGer,1,7,1]),;
													SuperVal(aMedicoes[nLin_aMed,nPosGer,1,7,1])*nCoef,0)
												cStatus:='R'
											EndIf
										Endif
									Next nCntFor
								ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] $ '4|8'
									For nCntFor := 1 to aMedicoes[nLin_aMed,nPosGer,1,1] // Quantidade de Medicoes
										If SuperVal(aMedicoes[nLin_aMed,nPosMed,nCntFor,nPasso]) <;
												SuperVal(QMG->QMG_LIE) .OR.;
												SuperVal(aMedicoes[nLin_aMed,nPosMed,nCntFor,nPasso]) >;
												SuperVal(QMG->QMG_LSE)
											cStatus:='R'
										EndIf
									Next nCntFor
								EndIf
							EndIf

							// Se todas as medicoes estiverem em branco e coleta medicoes estiver como "N",
							// considerar status como branco para que nao influa no resultado
							lStat := .f.
							For nLoop := 1 To Len(aMedicoes[nLin_aMed,nPosMed])
								If empty(aMedicoes[nLin_aMed,nPosMed,nLoop,nPasso]) .and. !lstat
									lstat := .t.
								EndIf
							Next nLoop
							If lStat .and. aMedicoes[nLin_aMed,nPosGer,1,20]=="N"
								cStatus := " "
							EndIf

							Aadd(aRetorno,{ nMedia, nDesvMed, nDesvPad, nIncInst, nIncTot, nErroMax,;
								lExat, lAceit, lAdeq,cStatus, nErroInd, nEspec, aMedicoes[nLin_aMed,nPosGer,1,16],aMedicoes[nLin_aMed,nPosEsc],aMedicoes[nLin_aMed,nPosPad],nMedia,nEspec,nRngPdMx,nRngPdMn})

						Next nPasso

					Else // Para medicoes externas
						If Empty(aMedicoes[nLin_aMed,nPosCar])
							cEscs := aMedicoes[nLin_aMed,nPosEsc]
						Else
							cEscs := aMedicoes[nLin_aMed,nPosCar]
						Endif
						If aMedicoes[nLin_aMed,nPosGer,1,4] == "E" .And. aMedicoes[nLin_aMed,nPosGer,1,1] == 0
							If !ExistBlock("qmt140AA")
								If !(aMedicoes[nLin_aMed,nPosGer,1,6] == " ")
									// Retorna o desvio padrao e a incerteza digitadas
									If !Empty(aMedicoes[nLin_aMed,nPosGer,1,9]) .and. !Empty(aMedicoes[nLin_aMed,nPosGer,1,10])
										nIncTot  := SuperVal(aMedicoes[nLin_aMed,nPosGer,1,10])
										nDesvMed := SuperVal(aMedicoes[nLin_aMed,nPosGer,1,9])
									Endif
									If aMedicoes[nLin_aMed,nPosGer,1,6] $ "1|2" // Se houver confirmacao metrologica, retorna tambem os criterios

										// Calcula Erro Maximo
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Ponto de Entrada para calculo de ERRO MAXIMO em MEDICOES EXTERNAS. Deve-se  ³
										//³observar que o Parametro MV_QCALINC( considera Soma Algebrica ou Quadratica,³
										//³ficara sendo tratado dentro desse rdmake, dependendo da necessidade do      ³
										//³cliente.								                                       ³
										//³Observa-se tambem que o retorno SEMPRE devera ser Numerico.                 ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If ExistBlock("qmt140EE")
											nErroMax := ExecBlock("qmt140EE",.F.,.F.,{nIncTot,nDesvMed})
										Else
											If cCalInc == '1' // Soma Alg‚brica - MV_QCALINC
												nErroMax := nIncTot+ nDesvMed
											ElseIf cCalInc == '2' // Soma Quadr tica - MV_QCALINC
												nErroMax := nIncTot**2
												nErroMax += nDesvMed**2
												nErroMax := Sqrt(nErroMax)
											EndIf
										Endif

										If aMedicoes[nLin_aMed,nPosGer,1,6] == "1"

											// Indice de Exatidao
											If ExistBlock("qmt140Ex")
												lExat := ExecBlock("qmt140Ex",.F.,.F.,{nEspec,nMedia,QMR->QMR_PREC,nInter,nRngPdMn,nRngPdMx})
											Else
												If !empty(aMedicoes[nLin_aMed,nPosMed,1,1])
													If aMedicoes[nLin_aMed,nPosMed,1,1] == "A"
														lExat := .T.
													ElseIf aMedicoes[nLin_aMed,nPosMed,1,1] == "R"
														lExat := .F.
													EndIf			// Quando for medicao externa sem medicoes,
												Else				// considerar o que for mencionado no atributo (medicao)
													lExat := .T.	// Se estiver vazio, considerar aprovado.
												EndIf
											Endif

											// Indice de Aceitabilidade (Obs.: Espec/Redutor p/Escala p/Instr.
											QMR->(DbSetOrder(1))
											If QMR->(DbSeek(xFilial("QMR")+cMtInstr+cMtRevIns+cEscs))
												//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
												//³Ponto de Entrada para Criterio de Aceitabiliade em MEDICOES EXTERNAS.      ³
												//³O retorno desse ponto de entrada SEMPRE devera ser logico.				  ³
												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

												If ExistBlock("qmt140AE")
													lAceit := ExecBlock("qmt140AE",.F.,.F.,{nErroMax})
												Else
													If !Empty(aMedicoes[nLin_aMed,nPosMed][1][1])
														If aMedicoes[nLin_aMed,nPosMed][1][1] == "A"  
															lAceit := .T.
														ElseIf aMedicoes[nLin_aMed,nPosMed][1][1] == "R"  
															lAceit := .F.
														Else
															cAceits := QMR->QMR_ACEITA
															If Empty(QMR->QMR_ACEITA)
																cAceits := "75"
															Endif
															If lCalPerc .and. aMedicoes[nLin_aMed,nPosGer,1,21] == "2"
																lAceit := nErroMax < ( (Superval(cAceits)/100) *;
																	(((Superval(QMR->QMR_TOLPRO)/100)*SuperVal(aMedicoes[nLin_aMed,nPosEsp])) / SuperVal(QMR->QMR_REDUT)))
															Else
																lAceit := nErroMax < ( (Superval(cAceits)/100) *;
																	(Superval(QMR->QMR_TOLPRO) / SuperVal(QMR->QMR_REDUT) ))
															Endif
														Endif
													Else
														lAceit := .T.	
													Endif	
												Endif
											Else
												lAceit := .f.
											EndIf

											// Indice de Adequa‡ao ao Uso - Medicoes Externas
											If !QMR->(Eof())
												//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
												//³Ponto de Entrada para Criterio de Adequacao ao USO em MEDICOES EXTERNAS.   ³
												//³O retorno desse ponto de entrada SEMPRE devera ser logico. 				  ³
												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
												If ExistBlock("qmt140UE")
													lAdeq := ExecBlock("qmt140UE",.F.,.F.,{nErroMax})
												Else
													If lCalPerc .and. aMedicoes[nLin_aMed,nPosGer,1,21] == "2"
														lAdeq :=  nErroMax <= (((Superval(QMR->QMR_TOLPRO)/100)*SuperVal(aMedicoes[nLin_aMed,nPosEsp])) / SuperVal(QMR->QMR_REDUT))
													Else
														lAdeq :=  nErroMax <= ( SuperVal(QMR->QMR_TOLPRO) / SuperVal(QMR->QMR_REDUT) )
													Endif
												Endif
											Else
												lAdeq := .f.
											EndIf

											If empty(aMedicoes[nLin_aMed,nPosMed,1,1])
												If lExat .and. lAceit .and. lAdeq
													cStatus := 'A'
												Else
													cStatus := 'R'
												EndIf
											Else
												If aMedicoes[nLin_aMed,nPosGer,1,3] == "A"
													cStatus := aMedicoes[nLin_aMed,nPosMed,1,1]
												Else
													cStatus := 'R'
												EndIf
											EndIf

											Aadd(aRetorno,{ 0,aMedicoes[nLin_aMed,nPosGer,1,9] , 0, 0, aMedicoes[nLin_aMed,nPosGer,1,10], 0, lExat, lAceit, lAdeq, cStatus, nErroInd, nEspec } )

										ElseIf aMedicoes[nLin_aMed,nPosGer,1,6] == "2" // Sem confirmaçao metrologica
											QMR->(DbSetOrder(1))
											If QMR->(DbSeek(xFilial("QMR")+cMtInstr+cMtRevIns+cEscs))
												If !Empty(aMedicoes[nLin_aMed,nPosGer,1,9]) .and. !Empty(aMedicoes[nLin_aMed,nPosGer,1,10]) //maior desvio ### incerteza total
													If nIncTot <= SuperVal(QMR->QMR_INPERM)
														If nErroMax <= SuperVal(QMR->QMR_INPERM)
															cStatus := 'A'
														Else
															cStatus := 'R'
														EndIf
													Else
														cStatus := 'R'
													EndIf
												Else
													If QMR->QMR_CAOBRI == "S" //Calibracao Obrigatoria?
														cStatus := 'R'
													Else
														cStatus := 'A'
													EndIf
												EndIf
											Else
												cStatus := 'R'
											Endif
											Aadd(aRetorno,{ 0,aMedicoes[nLin_aMed,nPosGer,1,9] , 0, 0, aMedicoes[nLin_aMed,nPosGer,1,10], 0, .t., .t., .t., cStatus, nErroInd, nEspec } )
										Else
											Aadd(aRetorno,{ 0, aMedicoes[nLin_aMed,nPosGer,1,9], 0, 0, aMedicoes[nLin_aMed,nPosGer,1,10], 0, .T., .T., .T.," ", nErroInd, nEspec } )
										EndIf
									EndIf
								Else
									Aadd(aRetorno,{ 0, aMedicoes[nLin_aMed,nPosGer,1,9], 0, 0, aMedicoes[nLin_aMed,nPosGer,1,10], 0, .T., .T., .T.,aMedicoes[nLin_aMed,nPosMed,1,1],nErroInd, nEspec } )
								EndIf
							Else
								If Alltrim(aMedicoes[nLin_aMed,nPosMed,1,1]) == "A"
									cStatus := "A"
								ElseIf Alltrim(aMedicoes[nLin_aMed,nPosMed,1,1]) == "R"
									cStatus := "R"
								Else
									cStatus := "R"
								Endif
								If aMedicoes[nLin_aMed,nPosGer,1,6] == "2"
									Aadd(aRetorno,{ 0,aMedicoes[nLin_aMed,nPosGer,1,9] , 0, 0, aMedicoes[nLin_aMed,nPosGer,1,10], 0, .t., .t., .t., cStatus, nErroInd, nEspec } )
								Else
									If cStatus == "R"
										lExat := .F.
										lAceit := .F.
										lAdeq := .F.
									Else
										lExat := .T.
										lAceit := .T.
										lAdeq := .T.
									Endif
									Aadd(aRetorno,{ 0,aMedicoes[nLin_aMed,nPosGer,1,9] , 0, 0, aMedicoes[nLin_aMed,nPosGer,1,10], 0, lExat, lAceit, lAdeq, cStatus, nErroInd, nEspec } )
								Endif
							Endif
						Else
							Aadd(aRetorno,{ 0, aMedicoes[nLin_aMed,nPosGer,1,9], 0, 0, aMedicoes[nLin_aMed,nPosGer,1,10], 0, .T., .T., .T.,aMedicoes[nLin_aMed,nPosMed,1,1], nErroInd, nEspec } )
						EndIf
					EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array aRetorno												³
//³							 		 		 		 		  	³
//³	 1 - Media		 		 		 		 		 	     	³
//³	 2 - Desv. Medio 		 		 		 		 	     	³
//³	 3 - Desv. Pad		 		 		 		 		     	³
//³	 4 - Incert			 		 		 		 		     	³
//³	 5 - Inc. total  		 		 		 		 	     	³
//³	 6 - Erro Max		 		 		 		 		     	³
//³	 7 - Exatid			 		 		 		 		     	³
//³	 8 - Aceitab 		 		 		 		 		     	³
//³	 9 - adequa			 		 		 		 	    	 	³
//³ 10 - Status		 		 		 		 		 	 	    ³
//³ 11 - Erro de Indicacao (Tipo de Calibracao Relogio (9)) 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Set decimal to 2

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QMT140cMed| Autor ³ Wanderley Goncalves Jr³ Data ³ 20/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula a media das medicoes                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpN1 - Media das Medicoes                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nLim_aMed - Linha do array em que o calculo esta atuando	  ³±±
±±³          ³ nPasso - Coluna em que o calculo esta atuando    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ A140Calc()                 								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT140cMed(nLin_aMed, nPasso)

	Local nMedia := 0
	Local nLoop := 0

	For nLoop := 1 To Len(aMedicoes[nLin_aMed,nPosMed])
		nMedia	+= If(!empty(aMedicoes[nLin_aMed,nPosMed,nLoop,nPasso]),;
			SuperVal(aMedicoes[nLin_aMed,nPosMed,nLoop,nPasso]),0)
	Next nLoop

	nMedia := nMedia / aMedicoes[nLin_aMed,nPosGer,1,1]

Return(nMedia)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QMT140CDPd|Autor  ³ Wanderley Goncalves Jr³ Data ³ 20/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o desvio padrao de um ponto                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpN1 - Valor do desvio padrao					  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nLim_aMed - Linha do array em que o calculo esta atuando	  ³±±
±±³          ³ nPasso - Coluna em que o calculo esta atuando    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ A140Calc()								  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT140CDPd(nLin_aMed,nPasso)

	Local nCntFor  := 0
	Local nDesvPad := 0
	Local nMedia   := 0

	nMedia := QMT140cMed(nLin_aMed, nPasso)

	For nCntFor := 1 to LEN(aMedicoes[nLin_aMed,nPosMed])
		If ValType(aMedicoes[nLin_aMed,nPosMed,nCntFor,nPasso]) == "C"
			nDesvPad += Iif(!Empty(aMedicoes[nLin_aMed,nPosMed,nCntFor,nPasso]),;
				((SuperVal(aMedicoes[nLin_aMed,nPosMed,nCntFor,nPasso]) - nMedia) ** 2),0)
		Endif
	Next nCntFor

	nDesvPad := sqrt( nDesvPad / ( aMedicoes[nLin_aMed,nPosGer,1,1] - 1 ) )

Return(nDesvPad)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QMT140MDP ³ Autor ³ Wanderley Goncalves   ³Data  ³17/12/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna maior desvio padrao dos pontos de uma escala		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Escala corrente									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpN1 - Maior Desvio Padrao								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140Calc										              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT140MDP(cEscala, nPasso)

	Local nMorDesv := 0
	Local nI	   := 0
	Local nDesv	   :=  0
	For nI := 1 to len(aMedicoes)
		If aMedicoes[nI,nPosEsc] == cEscala
			nDesv := QMT140CDPd(nI,nPasso)
			If nDesv > nMorDesv
				nMorDesv := nDesv
			EndIf
		EndIf
	Next nI

Return(nMorDesv)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³RetCond	³ Autor ³ Wanderley Goncalves Jr³ Data ³ 16/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna sugestao de condicao de recebimento, de acordo com ³±±
±±³			 ³ as medicoes anteriores									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpN1 - 1 -> Avaria / 2 -> Conforme / 3 -> Nao Conforme	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ A140GrvAll() - Radio Button								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetCond()

	Local lForaEsp := .F.
	Local nCond 	:= 0
	Local nCntFor	:= 0
	Local nLoop 	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe alguma medicao fora do especificado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCntFor := 1 To len(aMedicoes)
		For nLoop := 1 To len(aMedicoes[nCntFor, nPosMed])
			If aMedicoes[nCntFor,nPosGer,1,3] <> "A"
				If !qmt140VEsp("QM8_VLRFIM",nCntFor,.T.,;
						SuperVal(aMedicoes[nCntFor, nPosMed,nLoop,len(aMedicoes[nCntFor,nPosMed,1])-1]),;
						!Empty(aMedicoes[nCntFor, nPosMed,nLoop,len(aMedicoes[nCntFor,nPosMed,1])-1]))
					lForaEsp := .T.
					Exit
				EndIf
			EndIf
		Next nLoop
	Next nCntFor

	If QM6->(DbSeek(xFilial('QM6')+cMtInstr+cMtRevIns+dtos(dMtData)+cSeql)) // Alteracao
		If lForaEsp // Se fora de especificado, considerar avaria.
			nCond := 1	// Avaria
		ElseIf Empty(QM6->QM6_COND)
			nCond := 2	// Conforme
		Else
			nCond := Iif(QM6->QM6_COND == "A",1,Iif(QM6->QM6_COND=='C',2,3))
		EndIf
	Else	// Inclusao
		If lForaEsp // Se fora de especificado, considerar avaria.
			nCond := 1	// Avaria
		Else
			nCond := 2	// Conforme
		EndIf
	EndIf

Return( nCond )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt140PicS³ Autor ³ Wanderley Goncalves Jr³ Data ³ 19/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a picture de "cCampo" a partir de cValor.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ qmt140PicS(ExpC1,ExpC2,ExpL1)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do Campo que tera' a picture a ser definida   ³±±
±±³			 ³ ExpC2 = Valor do Campo referencia (cpo. que define a pict) ³±±
±±³			 ³ ExpL1 = Determina se deve aumentar em 2 o numero de casas  ³±±
±±³			 ³ 		  decimais do campo ExpC1							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA140													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt140PicS(cCampo,cValor,lDec)
	Local cPict := ""
	Local nValor
	Local nPict
	Local aArea := getArea()

	If lDec==Nil
		lDec:=.t.
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero de casas decimais do Valor de Referencia 			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nDec := QA_NumDec(cValor)	 // Valor de Referencia

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aumenta mais duas casas decimais alem das anteriores 		³
//³ se variavel lDec estiver ativa. 							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lDec .AND. nDec <= 6
		nDec := nDec + 2
	EndIf

	nValor	:= SuperVal(cValor)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a picture a partir no. casas decimais do cCampo		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nDec == 0
		cPict := "@E "+Replicate('9',10)
	Else
		if nValor < 0
			cPict := "@E "+Replicate('9',10-(nDec)) + '.' + Replicate('9',nDec)
		else
			cPict := "@E "+Replicate('9',10-(nDec+1)) + '.' + Replicate('9',nDec)
		endif
	EndIf

	nPict	:= SuperVal(Substr(cPict,4,13))

	If Int(nValor) > Int(nPict) //Reconstruir a Picture
		nDec := QA_NumDec(cValor)	 // Valor de Referencia
		cPict := "@E "+Replicate('9',10-(nDec+1)) + '.' + Replicate('9',nDec)
	Endif

restArea(aArea)
Return(cPict)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140VlHr	³ Autor ³ Fernando Godoy		³ Data ³ 9/1/1998 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida a hora digitada									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Hora informada									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 - .T. ou .F. 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140Inclui - Get da Hora 									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140VlHr(cMtTotHr)
	Local lRet	:= .T.

	If Val(Right(cMtTotHr,2)) > 59
		lRet	:= .F.
	EndIf

	If Alltrim(cMtTotHr) == ":" .or. Empty(cMtTotHr) 	// Vazia
		lRet := .T.
	ElseIf Len(Alltrim(cMtTotHr)) < 5
		lRet := .F.
	Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140MudaFr³ Autor ³ Wanderley Goncalves   ³ Data ³ 9/21/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Muda frequencia 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao escolhida no Radio Button 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA1														  ³±±
±±³			 ³Mensagem 1 - Extende / Diminui freq.afericao				  ³±±
±±³			 ³Mensagem 2 - Frequencia e data afericao com alteracao		  ³±±
±±³			 ³Mensagem 3 - Frequencia e data afericao sem alteracao		  ³±±
±±³			 ³Mensagem 4 - Dias de										  ³±±
±±³			 ³Mensagem 5 - Dias para									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140MudaFr( nCond, nOpcao)

	Local nFreqMin 	:= 0
	Local nFreqMax 	:= 0
	Local nReg			:= 0
	Local lUltCol		:= .F.
	Local dt_trb		:= Ctod("  /  /  ","DDMMYY")
	Local cCiclos		:= ""
	Local nFreqAnt 	:= 0
	Local nFreqNovo	:= 0
	Local cAcao 		:= ""
	Local nResp 		:= 0
	Local dProxAfer	:= CtoD("  /  /  ","DDMMYY")
	Local dProxAferA	:= CtoD("  /  /  ","DDMMYY")
	Local aRet			:= {}
	Local cTexto		:= ""
	Local cPerg
	Local nRec			:= QM6->(recno())
	Local lConFreq		:= IIf(Alltrim(cFreqSch) == "S",.T.,.F.)
	Local cFreqsAnt		:= ""
	Local cFreqsAtu		:= ""
	Local lFzQMF		:= .T.
	Local cChv			:= ""
	Local aFres			:= {}
	Local nValQM6       := 0
	Local nValDaf		:= 0

	Default nOpcao      := 2
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nCond 1 - Avaria	   ³
//³		 2 - Conforme	   ³
//³		 3 - Nao Conforme  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os limites da frequencia da tabela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nCond == 0
		nCond := 1
	EndIf

	DbSelectArea("QMF")
	DbSetOrder(1)
	dbGoTop()
	nFreqMin := Val(QMF_RED_MX)
	dbGoBottom()
	nFreqMax := Val(QMF_EXTEND)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no QM2 e carrega frequencia e validade ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("QM2")
	DbSetOrder(1)
	DbSeek(xFilial("QM2")+cMtInstr+Inverte(cMtRevIns))
//Na visualização, sempre realizar a conta através das frequencias da tabela QM6
	If !Altera
		If (nOpcao == 2 .AND. !Inclui )
			aAreaQM2	:= GetArea()
			nValDaf 	:= QM2->QM2_VALDAF
			DbselectArea("QM6")
			DbSetOrder(01)
			If DbSeek(xFilial("QM6")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql)
				nValQM6 := QM6->QM6_VALDAF
				RestArea( aAreaQM2 )
				If ((nValDaf <> nValQM6) .AND. (QM2->QM2_FREQAN > 0))
					nFreqAnt 	:= QM6->QM6_VALDAF - QM6->QM6_DATA
				Else
					nFreqAnt 	:= QM2->QM2_FREQAF
				EndIf
			EndIf
		Else
			nFreqAnt 	:= QM2->QM2_FREQAF
		Endif
	Else
		//Se jah existir alguma medicao com esse instrumento nessa revisao pegar o FREQAF
		dbSelectArea("QM6")
		dbSetOrder(01)
		If DbSeek(xFilial("QM6")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql)
			nFreqAnt 	:= QM2->QM2_FREQAF
		Else
			nFreqAnt 	:= QM2->QM2_FREQAN
		Endif
		If nFreqAnt == 0 //Caso a frequencia anterior seja zero, associo a frequencia atual.
			nFreqAnt := QM2->QM2_FREQAF
		Endif
	Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ So permite alteracao da freq.afericao da proxima coleta ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lConFreq
		DbSelectArea('QM6')
		DbSetOrder(01)
		DbSeek(xFilial('QM6')+cMtInstr+cMtRevIns+dtos(dMtData)+cSeql)
		nReg		:= Recno()
		lUltCol	:= .T.

		While cMtInstr == QM6->QM6_INSTR .And. dtos(dMtData) == dtos(QM6->QM6_DATA) .And. cMtRevIns == QM6->QM6_REVINS .And. ! QM6->(Eof())
			QM6->(DbSkip())
		Enddo
		If cMtInstr == QM6->QM6_INSTR
			lUltCol := .F.
		Endif
		cChv := QM6->QM6_CHAVE
		QM6->(DbSeek(xFilial("QM6")+cMtInstr))
		While .T.
			While cMtInstr == QM6->QM6_INSTR .And. ! QM6->(Eof())
				cChv := QM6->QM6_CHAVE
				If QM6->QM6_DATA == dMtData .And. cMtInstr == QM6->QM6_INSTR  .And. cMtRevIns == QM6->QM6_REVINS .and. cChv == QM6->QM6_CHAVE .and. cSeql == QM6->QM6_CSEQ
					Exit
				Endif
				dt_trb	:= QM6->QM6_DATA
				cCiclos	+= QM6->QM6_COND
				cChv := Str(Val(QM6->QM6_CHAVE)+1)
				While cMtInstr == QM6->QM6_INSTR .And. dt_trb == QM6->QM6_DATA .And. cMtRevIns == QM6->QM6_REVINS .And. cChv == QM6->QM6_CHAVE .And. ! Qm6->(Eof())
					QM6->(DbSkip())
				Enddo
				cChv := QM6->QM6_CHAVE
				dbSkip()
			Enddo
			QM6->(DbGoto(nReg))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao for a ultima coleta, nao altera a frequencia ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lUltCol
				nFreqNovo := nFreqAnt
				Exit
			Endif
			cCiclos += Iif(nCond==1,'A',Iif(nCond==2,'C',Iif(nCond==3,'N',' ')))
			If len(cCiclos) < 3 && Quantidade minima para a freq.automatica
				nFreqNovo := nFreqAnt
				Exit
			Endif
			cCiclos := Right(cCiclos,4)
			cCiclos := Space(4-len(cCiclos))+cCiclos
			Do Case
			Case cCiclos $ 'CCCC.ACCC'
				cAcao	:= 'E'
			Case cCiclos $ 'CCCN.NCCN.ACCN'
				cAcao	:= 'D'
			Case cCiclos $ 'CCCA.NCCA.ACCA.NCCC'
				cAcao	:= 'P'
			Case Right(cCiclos,3) $ 'CNC.CAC.NCA.NCC.NNC.NAC.'+;
					'ACA.ACC.ANC.AAC'
				cAcao	:= 'P'
			Case Right(cCiclos,3) $ 'CNA.CNN.CAA.CAN.NCN.NNA.'+;
					'NNN.NAA.NAN.ANA.ANN.AAA.AAN'
				cAcao	:= 'M'
			Case Right(cCiclos,3) $ 'ACN'
				cAcao	:= 'D'
			Endcase
			If ! empty(cAcao)
				If (cAcao == 'M'.Or. cAcao == 'D') .And. nFreqAnt <= nFreqMin
					cTexto	:= STR0014 //"A frequencia nao podera ser inferior ao menor numero de dias especificado na tabela de Schumacher"
					cPerg 	:= "A"   // Aviso
					nResp 	:= 1
					nFreqNovo	:= nFreqAnt
				Elseif cAcao == 'E' .And. nFreqAnt >= nFreqMax
					nResp 	:= 1
					cPerg 	:= "A"   // Aviso
					cTexto	:= STR0015 //"A frequencia nao podera ser superior ao maior numero de dias especificado na tabela de Schumacher"
					nFreqNovo:= nFreqAnt
				Else
					If !Inclui .and. !Altera
						nFreqNovo:= nFreqAnt
					Else
						If (cAcao == 'M' .or. cAcao == 'D') .and. nFreqAnt > nFreqMax
							If (Len(Alltrim(Str(nFreqAnt))) > Len(Alltrim(Str(nFreqMax))))
								nResp 	:= 1
								cPerg 	:= "A"   // Aviso
								cTexto	:= STR0015 //"A frequencia nao podera ser superior ao maior numero de dias especificado na tabela de Schumacher"
								nFreqNovo:= nFreqAnt
								lFzQMF	:= .F. //Nao procurar na tabela de Schumacker qdo o tamanho da freq.Ant for maior que
							Endif	           //o tamanho da Frequencia Maxima
						Endif

						If lFzQMF
							DbSelectArea("QMF")
							dbSetOrder(1)
							QMF->(dbGoTop())
							While QMF->(!Eof())
								If Val(QMF->QMF_DIAS) >= nFreqAnt
									Exit
								Endif
								dbSelectArea("QMF")
								dbSkip()
							Enddo
							nFreqNovo := Iif(cAcao=='E',Val(QMF->QMF_EXTEND),Iif(cAcao=='D',Val(QMF->QMF_DIMIN),;
								Iif(cAcao=='M',Val(QMF->QMF_RED_MX),Iif(cAcao=='P',Val(QMF->QMF_PERM),nFreqAnt))))
							If nFreqNovo == 0 //Se ultrapassou o limite de Schumacker, pega sempre a ultima frequencia - QMF
								dbSelectArea("QMF")
								dbGoTo(QMF->(RecCount()))
								nFreqNovo := Iif(cAcao=='E',Val(QMF->QMF_EXTEND),Iif(cAcao=='D',Val(QMF->QMF_DIMIN),;
									Iif(cAcao=='M',Val(QMF->QMF_RED_MX),Iif(cAcao=='P',Val(QMF->QMF_PERM),nFreqAnt))))
							Endif
							nResp := 2
							cPerg := "A"
							If nFreqNovo # nFreqAnt
								If Len(Alltrim(str(nFreqAnt,4))) <= 3
									cFreqsAnt := str(nFreqAnt,3)
								Else
									cFreqsAnt := str(nFreqAnt,4)
								Endif

								If Len(Alltrim(str(nFreqNovo,4))) <= 3
									cFreqsAtu := str(nFreqNovo,3)
								Else
									cFreqsAtu := str(nFreqNovo,4)
								Endif

								Do Case
								Case cAcao == 'E'
									cPerg 	:= "P" // Pergunta
									cTexto:= Oemtoansi(STR0016) + ' ' +cFreqsAnt+;       // "Extender a freq.afer. de"
									" " + OemToAnsi(STR0017) +' '+cFreqsAtu+ ;   // "para"
									" " + OemToAnsi(STR0018)                              // "dias"

								Case cacao == 'D' .Or. cacao == 'M'
									cPerg 	:= "P"  // Pergunta
									cTexto:= OemToAnsi(STR0019)+' '+cFreqsAnt+;     // "Diminuir a freq.afer. de"
									' '+OemToAnsi(STR0020)+' '+cFreqsAtu+;   // "para"
									' '+OemToAnsi(STR0021)                          //"dias"
								Endcase
							Endif
						Endif
					Endif
				Endif
			Endif
			If Empty(cAcao)
				nFreqNovo := nFreqAnt
			Endif
			Exit
		Enddo
	Else
		nFreqNovo := nFreqAnt
		cPerg	:= "A"
	Endif

	dProxAfer := dMtData
	dProxAferA:= dMtData

//somente qdo status = reprovado
	If ExistBlock("QMT140SFre")
		dbSelectArea("QM2")
		dbSetOrder(1)
		If dbSeek(xFilial("QM2")+cMtInstr+Inverte(cMtRevIns))
			aFres := ExecBlock("QMT140SFre",.F.,.F.,{dProxAfer,dProxAferA,nFreqNovo,nFreqAnt})
			If Len(aFres) > 0
				dProxAfer := aFres[1] //Data Nova
				dProxAferA:= aFres[2] //Data Antiga
				dProxAfer := QM010ValAf(dProxAfer, aFres[3])
				dProxAferA:= QM010ValAf(dProxAferA,aFres[4])
			Else
				dProxAfer := QM010ValAf(dProxAfer, nFreqNovo)
				dProxAferA:= QM010ValAf(dProxAferA,nFreqAnt)
			Endif
		Endif
	Else
		dProxAfer := QM010ValAf(dProxAfer, nFreqNovo)
		dProxAferA:= QM010ValAf(dProxAferA,nFreqAnt)
	Endif

	aRet := {cTexto,cPerg,;
		STR0022+Alltrim(Str(nFreqNovo))+STR0023+DtoC(dProxAfer),; //"Frequência: " ### " dias Val.Calibraçäo: "
	STR0024+Alltrim(Str(nFreqAnt))+STR0025+DtoC(dProxAferA),; //"Frequência: " ### " dias Val.Calibraçäo: "
	dProxAfer,nFreqNovo,;
		dProxAferA,nFreqAnt,cAcao}

	QM6->(DbGoto(nRec))

Return aRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140HIST	³ Autor ³ Wanderley Goncalves   ³ Data ³ 13.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega programa de Historico de Instrumento 		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void A140Hist(Void)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QMTA140													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140Hist()

	DbSelectArea("QM2")
	DbSetOrder(1)
	If QM2->(DbSeek(xFilial()+QM6->QM6_INSTR+Inverte(QM6->QM6_REVINS)))
		A010Text(,,6)
	EndIf

Return(Nil)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³qmt140Chv ³ Autor ³ Wanderley Goncalves   ³ Data ³ 13/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡ao dos campos chave								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA140 - E' chamada no X3_VALID do campos chaves do QM6   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt140Chv(cMtResp,cMtTotHr,cMtRepRepr,cMtInstr,cMtRevIns,dMtData,oDlgPri,oBtn,cMtSeq,cMtFilRes)
	Local lRet := .T.
	Local nRec
	Default cMtResp		:= M->QM6_RESP
	Default cMtTotHr	:= M->QM6_TOTHOR
	Default cMtRepRepr	:= M->QM6_REPEPR
	Default cMtInstr	:= M->QM6_INSTR
	Default cMtRevIns	:= M->QM6_REVINS
	Default dMtData		:= M->QM6_DATA
	Default cMtSeq		:= M->QM6_CSEQ
	cMtFilRes			:= M->QM6_FILRES
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Data n„o pode ser futura ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dMtData > dDataBase
		MessageDlg(STR0026,,1) // "Data inválida, informe um data menor que a data base do Sistema."
		lRet := .F.
	EndIf

	If lRet
		If !Empty( cMtInstr ) .And.;
				Empty( cMtRevIns )
			lRet := .T.
		ElseIf !Empty( cMtInstr ) .And. !Empty( cMtRevIns ) .And.;
				!Empty( dMtData )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica existencia do registro ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QM6")
			If dbSeek(xFilial("QM6")+cMtInstr+cMtRevIns+DtoS(dMtData))
				While !QM6->(Eof()) .And. xFilial("QM6")+cMtInstr+cMtRevIns+DtoS(dMtData) ==;
						QM6->QM6_FILIAL+QM6->QM6_INSTR+QM6->QM6_REVINS+DTOS(QM6->QM6_DATA)
					cSeql := QM6->QM6_CSEQ
					cSeql := Str(Val(cSeql) + 1)
					If Val(Alltrim(cSeql)) <= 9
						cSeql := "0"+Alltrim(cSeql)
					Endif
					QM6->(dbSkip())
				Enddo
				cMtSeq := cSeql
				M->QM6_CSEQ := cSeql
				oEnchoice1:Show()
				oEnchoice1:Refresh()
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se data ‚ menor que a ultima ocorrencia do mesmo instr³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nRec := QM6->(Recno())
				If dbSeek( xFilial("QM6")+cMtInstr+cMtRevIns )
					dData := QM6->QM6_DATA
					Do While xFilial("QM6")+cMtInstr+cMtRevIns ==;
							QM6->QM6_FILIAL + QM6->QM6_INSTR + QM6->QM6_REVINS .and.;
							!QM6->(Eof())
						If dData > dMtData
							MessageDlg(STR0028,,1) //"Data Invalida. Existem calibracoes cadastradas com datas superiores"
							lRet := .F.
							Exit
						Else
							lRet := .T.
						EndIf
						QM6->(DbSkip())
						dData := QM6->QM6_DATA
					EndDo
					cMtSeq := cSeql
					oEnchoice1:Show()
					oEnchoice1:Refresh()
				Else
					cMtSeq := "00"
					M->QM6_CSEQ := "00"
					oEnchoice1:Show()
					oEnchoice1:Refresh()
				EndIf
			EndIf
		EndIf
	EndIf
/*
	If !lRet
	oMtResp:Disable()
	oMtTotHr:Disable()
	oMtRepRepr:Disable()
	SetFocus(oMtInstr:hWnd)
	oMtInstr:SetPos(1,Len(cMtInstr))
	Else
	oMtResp:Enable()
	oMtTotHr:Enable()
	oMtRepRepr:Enable()
	EndIf

oMtResp:Refresh()
oMtTotHr:Refresh()
oMtRepRepr:Refresh()
*/
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt140Pict³ Autor ³ Wanderley Goncalves   ³ Data ³ 17/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna picture do(s) campo(s) valor(es) encontrado(s) em  ³±±
±±³			 ³ relacao ao campo nominal do padrao. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA140 - X3_PICTVAR de QM8_VLRINI e QM8_VLRFIM 			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt140Pict( lCasas )

	Local cCampo
	Local cPict := ""
	Local nCoef := 1
	Local nLin_aMed := IF (Funname() <> "LERDA" .and. Funname() <> "MPVIEW" .And. Funname() <> "EDAPP",Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])}),)
	Local cTamEsc := GetNewPar("MV_QDECPAD","1") //Considerar o tamanho de casas decimais do padrao
	Default lCasas := .F.

	IF Funname() <> "LERDA" .and. Funname() <> "MPVIEW" .And. Funname() <> "EDAPP"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Diferencia‡„o para tipo = soma(5)							 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aMedicoes[nLin_aMed,nPosGer,1,2] = '5'
			If lTamSom
				If !Empty(QM9->QM9_ESCALI)
					nTam := QA_NUMDEC(QM9->QM9_ESCALI)
					cPict := qmt140Pics("QM8_VALINI",QM9->QM9_ESCALI,lCasas)
				Else
					cPict := qmt140Pics("QM8_VALINI",aMedicoes[nLin_aMed,nPosEsp],lCasas)
				Endif
			Else
				cPict := qmt140Pics("QM8_VALINI",aMedicoes[nLin_aMed,nPosEsp],lCasas)
			Endif
		Else
			If !(aMedicoes[nLin_aMed,nPosGer,1,2] $ '4|8')
				If QM3->QM3_UNIMED <> QM9->QM9_UNIMED .and. !empty(QM9->QM9_UNIMED)
					nCoef := SAP->AP_COEF
				Endif
				If Alltrim(cTamEsc) == "1"
					dbSelectArea("QM9")
					dbSetOrder(1)
					If dbSeek(xFilial("QM9")+aMedicoes[nPosAmed,nPosEsc]) .and. !Empty(QM9->QM9_ESCALI) 
						nTam := QA_NUMDEC(QM9->QM9_ESCALI)
					Else
						nTam := QA_NUMDEC(aMedicoes[nLin_aMed,nPosEsp])+QA_NUMDEC(StrTran(Str(nCoef),".",","))
					Endif
				Else
					nTam := QA_NUMDEC(aMedicoes[nLin_aMed,nPosEsp])
				Endif
				dbSelectArea("QM3")
				dbSetOrder(1)
				dbSeek(xFilial("QM3")+aMedicoes[nLin_aMed,nPosPad])
				cCampo := "QM3_ESPEC"
				cPict := QA_PICT(cCampo,StrTran(Str(SuperVal(&cCampo)*nCoef,Len(&cCampo),nTam),".",","))
			Else
				dbSelectArea("QMG")
				dbSetOrder(1)
				QMG->(DbSeek(xFilial("QMG")+cMtInstr+cMtRevIns+aMedicoes[nLin_aMed,nPosPad]))
				cCampo:= "QMG_NOMIN"
				nTam  := QA_NUMDEC(&cCampo)
				cPict := QA_PICT(cCampo,StrTran(Str(SuperVal(&cCampo),Len(&cCampo),nTam),".",","))
			EndIf
		Endif
		If lOnline .and. Upper(cPorta) == "TECLADO"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Zera a picture, para considerar o sinal negativo.³
			//³Instrumentos Mitutoyo conectado por Teclado      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cPict := ""
		Endif
	Endif

Return(cPict)

/*
antiga a140ValEsp
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³qmt140VEsp³ Autor ³ Wanderley Goncalves   ³ Data ³ 17/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se medicao esta fora do especificado e caso esteja³±±
±±³			 ³ avisa ao usuario. 							  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Campo							  				  ³±±
±±³			 ³ ExpN1 = Posicao no acols						 	  		  ³±±
±±³			 ³ ExpL1 = Logico que indica se deve exibir mensagem de fora  ³±±
±±³			 ³ 		  de especificado e retorno de consistencia			  ³±±
±±³			 ³ ExpN2 = Valor a ser comparado					  		  ³±±
±±³			 ³ ExpL2 = Indica se foi preenchido mesmo que com zero 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA140 - X3_Valid do QM8_VLRINI e QM8_VLRFIM		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto ³ 15/06/00 ³ Alteracoes para calibrar Tipo de Calibracao Re- ³±±
±±³          ³          ³ logio.                        		  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt140VEsp(cCampo,nPos,lFora,nValor, lInformado)

	Local aArea 	:= GetArea()
	Local nVal		:= 0
	Local nValMax	:= 0
	Local nValMin	:= 0
	Local nOrd		:= 0
	Local nRec		:= 0
	Local lRet		:= .T.
	Local cCampoVer:= ""
	Local lNumVer	:= .T.
	Local nI			:= 0
	Local nCoef		:= 1
	Local cEscs		:= ""
	Local nValores	:= 0
	Local nDecs		:= 0

	Default nPos := Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})//GetPosAtu()
	Default lFora := .F.
	Default nValor := 0
	Default aCols  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se parametros MV_QVLINIF - para valor inicial e   ³
//³ MV_QVLFIMF - para valores finais, estao ativos para exibir ³
//³ mensagem de fora de especificado.						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cCampo == "QM8_VLRINI" .And. GetMv("MV_QVLINIF") == "S") .Or.;
			(cCampo == "QM8_VLRFIM" .And. GetMv("MV_QVLFIMF") == "S") .Or.;
			(cCampo == "QM8_VLRIND" .And. GetMv("MV_QVLINIF") == "S") .Or.;
			(cCampo == "QM8_VLRFID" .And. GetMv("MV_QVLFIMF") == "S")

		If lOnline .and. Upper(cPorta) == "TECLADO"
			nDecs := Qa_Numdec(aMedicoes[nPos,nPosEsp])
			If Alltrim(cCampo) == "QM8_VLRINI"
				nValores := Val(StrTran(M->QM8_VLRINI,",","."))
				M->QM8_VLRINI := Str(nValores,Len(M->QM8_VLRINI),nDecs)
				M->QM8_VLRINI := StrTran(M->QM8_VLRINI,".",",")
			ElseIf Alltrim(cCampo) == "QM8_VLRFIM"
				nValores := Val(StrTran(M->QM8_VLRFIM,",","."))
				M->QM8_VLRFIM := Str(nValores,Len(M->QM8_VLRFIM),nDecs)
				M->QM8_VLRFIM := StrTran(M->QM8_VLRFIM,".",",")
			ElseIf Alltrim(cCampo) == "QM8_VLRIND"
				nValores := Val(StrTran(M->QM8_VLRIND,",","."))
				M->QM8_VLRIND := Str(nValores,Len(M->QM8_VLRIND),nDecs)
				M->QM8_VLRIND := StrTran(M->QM8_VLRIND,".",",")
			ElseIf Alltrim(cCampo) == "QM8_VLRFID"
				nValores := Val(StrTran(M->QM8_VLRFID,",","."))
				M->QM8_VLRFID := Str(nValores,Len(M->QM8_VLRFID),nDecs)
				M->QM8_VLRFID := StrTran(M->QM8_VLRFID,".",",")
			Endif
		Endif

		If Empty(aMedicoes[nPos][nPosCar])
			cEscs := aMedicoes[nPos][nPosEsc]
		Else
			cEscs := aMedicoes[nPos][nPosCar]
		Endif

		dbselectArea("QM3")
		dbSetOrder(1)

		dbSelectArea("QM9")
		dbSetOrder(1)
		dbSeek(xFilial("QM9")+alltrim(cEscs))

		If aMedicoes[nPos,nPosGer,1,2] $ '1,2,3,9'

			nOrd := QM3->(IndexOrd())
			nRec := QM3->(Recno())
			QM3->(DbSeek(xFilial("QM3")+alltrim(aMedicoes[nPos,nPosPad])))
			If QM9->QM9_UNIMED <> QM3->QM3_UNIMED
				dbSelectArea("SAP")
				dbSetOrder(1)
				If dbSeek(xFilial("SAP")+QM3->QM3_UNIMED+QM9->QM9_UNIMED)
					nCoef := SAP->AP_COEF
				Endif
			Endif

			If QM3->QM3_TIPTOL == "1" //Verifica qual e o calculo da Tolerancia
				nValMin := SuperVal(aMedicoes[nPos,nPosEsp])*nCoef - SuperVal(aMedicoes[nPos,nPosGer,1,7,2])*nCoef
				nValMax := SuperVal(aMedicoes[nPos,nPosEsp])*nCoef + SuperVal(aMedicoes[nPos,nPosGer,1,7,1])*nCoef
			Else
				nValMin :=	SuperVal(aMedicoes[nPos,nPosEsp])/* *nCoef */ - ((SuperVal(aMedicoes[nPos,nPosEsp])/* *nCoef */) * SuperVal(aMedicoes[nPos,nPosGer,1,7,2])*nCoef)/100
				nValMax :=	SuperVal(aMedicoes[nPos,nPosEsp])/* *nCoef */ + ((SuperVal(aMedicoes[nPos,nPosEsp])/* *nCoef */) * SuperVal(aMedicoes[nPos,nPosGer,1,7,1])*nCoef)/100
			Endif

			nValMin := Round(nValMin, nTam) //nTam -> QA_NUMDEC(QM9->QM9_ESCALI)
			nValMax := Round(nValMax, nTam) //nTam -> QA_NUMDEC(QM9->QM9_ESCALI)

			QM3->(DbSetOrder(nOrd))
			QM3->(DbGoto(nRec))

		ElseIf aMedicoes[nPos,nPosGer,1,2] == '5'

			nValMin := SuperVal(aMedicoes[nPos,nPosEsp]) - SuperVal(aMedicoes[nPos,nPosGer,1,7,2])
			nValMax := SuperVal(aMedicoes[nPos,nPosEsp]) + SuperVal(aMedicoes[nPos,nPosGer,1,7,1])
			If lTamSom
				If !Empty(QM9->QM9_ESCALI)
					nValMin := Round(nValMin,QA_NUMDEC(QM9->QM9_ESCALI))
					nValMax := Round(nValMax,QA_NUMDEC(QM9->QM9_ESCALI))
				Endif
			Endif
		ElseIf aMedicoes[nPos,nPosGer,1,2] $ '4|8'

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se tipo for calibrador ou calibrador completo, pegar valor do ³
			//³ limite inferior e do limite inferior						  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QMG")
			dbSetOrder(1)
			If DbSeek(xFilial("QMG")+cMtInstr+cMtRevIns+aMedicoes[nPos,nPosPad])
				nValMin := SuperVal(QMG->QMG_LIE)
				nValMax := SuperVal(QMG->QMG_LSE)
			EndIf

		EndIf
		If cCampo == "QM8_VLRINI" .Or. cCampo == "QM8_VLRIND"
			If lFora
				nVal := nValor
			Else
				If cCampo == "QM8_VLRINI"
					nVal := M->QM8_VLRINI
				ElseIf cCampo == "QM8_VLRIND"
					nVal := M->QM8_VLRIND
				EndIf
			EndIf
		Else
			If lFora
				nVal := nValor
			Else
				If cCampo == "QM8_VLRFIM"
					nVal := M->QM8_VLRFIM
				ElseIf cCampo == "QM8_VLRFID"
					nVal := M->QM8_VLRFID
				EndIf
			EndIf
		EndIf
		If SuperVal(nVal) < nValMin .Or. SuperVal(nVal) > nValMax
			If !lFora
				MsgInfo(STR0029,STR0039)	//"Medicao fora do Especificado"
			Else
				//Se a medição é obrigatória ou foi informada...
				If Posicione("QMR",1,xFilial("QMR")+cMtInstr+cMtRevIns+aMedicoes[nPos,nPosPad], 'QMR_CAOBRI') = 'S' .Or. lInformado
					lRet := .F.
				EndIf
			EndIf
		Else
			If aMedicoes[nPosAMed,nPosGer,1,2] <> "1"   // Tipo Simples

				If ( cCampo == "QM8_VLRINI" .Or. cCampo == "QM8_VLRIND") .And. Len(aCols) >= 1
					lNumVer := .T.
					If cCampo == "QM8_VLRINI"
						cCampoVer := AllTrim(aCols[n,1])
					ElseIf  cCampo == "QM8_VLRIND"
						cCampoVer := AllTrim(aCols[n,4])
					EndIf
					If Len(cCampoVer) >= 1
						For nI = 1 To Len(cCampoVer)
							If !(Subs(cCampoVer,nI,1)$"0123456789,.")
								lNumVer := .F.
								Exit
							EndIf
						Next
					Else
						lNumVer := .T.  // pode ser zero
					EndIf
					// S¢ atualiza VlrFim se Vlrfim estiver vazio
					If lNumVer
						If Len(cCampoVer) == 0
							If cCampo == "QM8_VLRINI"
								If !(aMedicoes[nPosAMed,nPosGer,1,2]) $ "1|4"
									aCols[n,2]    := StrTran(nVal,".",",")
									M->QM8_VLRFIM := StrTran(nVal,".",",")
								Endif
							ElseIf  cCampo == "QM8_VLRIND"
								aCols[n,4]    := StrTran(nVal,".",",")
								M->QM8_VLRFID := StrTran(nVal,".",",")
							EndIf
						EndIf
					EndIf
				EndIf
			Endif
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A140RetEsc³ Autor ³ Fernando Godoy		³ Data ³ 23/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna Escala/Incerteza selecionada						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA140													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140RetEsc( aEscalas,oLbx, nPosPad, nPosInc, cRevQM6, oGetDad )
	Local lRetu := .T.
	Local nPos		:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMS_PADSEC" })
	Local nPosEPad	:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMS_ESCPAD" })
	Local cTipEsc
	Local cUnidMed
	Local nCoef := 1
	Local nLin_aMed	:= Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})
	Local nI := 1

	If nPos == 0 // Se for chamado pelo Instrumento Utilizado
		nPos := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMI_INSUT" })
	Else
		cRevQM6 := QM2->QM2_REVINS
	Endif

	If nPosEPad == 0 // Se for chamado pelo Instrumento Utilizado
		nPosEPad := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMI_ESCPAD" })
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Padrao Secund. e Escalas ja' existem ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 to Len(oGetDad:aCols)
		If !oGetDad:aCols[nI][Len(oGetDad:aCols[nI])]   // Verifica se ja foi deletado
			If aCols[oGetDad:oBrowse:nAt][nPos] == aCols[nI][nPos] .and.;
					aEscalas[oLbx:nAt,1] == aCols[nI][nPosPad] .and. nI <> n
				MessageDlg(STR0050,,3)	//"Padrao Secundario/Escala ja relacionados a esta medicao. Informe outro."
				lRetu := .F.
			EndIf
		EndIf
	Next nI

	If lRetu
		dbSelectArea("QM9")
		dbSetOrder(01)
		If dbSeek(xFilial("QM9")+aEscalas[oLbx:nAt,1]+Inverte(aEscalas[oLbx:nAt,3]))
			cTipEsc := QM9->QM9_TIPAFE
			cUnidMed := QM9->QM9_UNIMED
			If cTipEsc $ "4|8"
				dbSelectArea("QMG")
				dbSetOrder(01)
				If dbSeek(xFilial("QMG")+aCols[oGetDad:oBrowse:nAt][nPos]+cRevQM6)
					While !Eof() .and. QMG->QMG_FILIAL+QMG->QMG_INSTR == xFilial("QMG")+aCols[oGetDad:oBrowse:nAt][nPos]
						If Alltrim(cUnidMed) <> Alltrim(QMG->QMG_UNIMED)
							If QMG->QMG_UNIMED <> cUnidMed
								dbSelectArea("SAP")
								dbSetOrder(1)
								If dbSeek(xFilial("SAP")+QM9->QM9_UNIMED+cUnidMed)
									nCoef := SAP->AP_COEF
								Else
									If nPosEPad == 0 // Se foi chamado pelo Instrumento Utilizado
										Acols[oGetDad:oBrowse:nAt][nPosPad]	:= Criavar("QMS_PADSEC")
										Acols[oGetDad:oBrowse:nAt][nPosEPad]	:= Criavar("QMS_ESCPAD")
										Acols[oGetDad:oBrowse:nAt][nPosInc]	:= Criavar("QMS_INCERT")
									Else
										Acols[oGetDad:oBrowse:nAt][nPosPad]	:= Criavar("QMI_INSUT")
										Acols[oGetDad:oBrowse:nAt][nPosEPad]	:= Criavar("QMI_ESCPAD")
										Acols[oGetDad:oBrowse:nAt][nPosInc]	:= Criavar("QMI_INCERT")
									Endif
									Help( " ", 1, "A140UNIDIF" )//Unidades de Medidas Incompativeis. Cadastre as mesmas.
									lRetu := .F.
									Exit
								Endif
							Else
								nCoef := 1
							Endif
						Endif
						dbSelectArea("QMG")
						dbSkip()
					Enddo
				Else
					MessageDlg(STR0064,,3) //"Instrumento/Revisao nao Encontrado"
					lRetu := .F.
				Endif
			Else
				If Alltrim(aMedicoes[nLin_aMed,nPosGer,1,2]) $ "4|8"
					dbSelectArea("QMG")
					dbSetOrder(01)
					If dbSeek(xFilial("QMG")+cMtInstr+cMtRevIns+aMedicoes[nLin_aMed][nPosPad])
						If QMG->QMG_UNIMED <> cUnidMed
							dbSelectArea("SAP")
							dbSetOrder(1)
							If dbSeek(xFilial("SAP")+QMG->QMG_UNIMED+cUnidMed)
								nCoef := SAP->AP_COEF
							Else
								If nPosEPad == 0 // Se foi chamado pelo Instrumento Utilizado
									Acols[oGetDad:oBrowse:nAt][nPosPad]	:= Criavar("QMS_PADSEC")
									Acols[oGetDad:oBrowse:nAt][nPosEPad]	:= Criavar("QMS_ESCPAD")
									Acols[oGetDad:oBrowse:nAt][nPosInc]	:= Criavar("QMS_INCERT")
								Else
									Acols[oGetDad:oBrowse:nAt][nPosPad]	:= Criavar("QMI_INSUT")
									Acols[oGetDad:oBrowse:nAt][nPosEPad]	:= Criavar("QMI_ESCPAD")
									Acols[oGetDad:oBrowse:nAt][nPosInc]	:= Criavar("QMI_INCERT")
								Endif
								Help( " ", 1, "A140UNIDIF" )//Unidades de Medidas Incompativeis. Cadastre as mesmas.
								lRetu := .F.
							Endif
						Endif
					Endif
				ElseIf Alltrim(aMedicoes[nLin_aMed,nPosGer,1,2]) ==  "5"
					If Alltrim(aMedicoes[nLin_aMed,nPosGer,1,22]) <> Alltrim(QM9->QM9_UNIMED)
						dbSelectArea("SAP")
						dbSetOrder(1)
						If dbSeek(xFilial("SAP")+QM9->QM9_UNIMED+aMedicoes[nLin_aMed,nPosGer,1,22])
							nCoef := SAP->AP_COEF
						Else
							If nPosEPad == 0 // Se foi chamado pelo Instrumento Utilizado
								Acols[oGetDad:oBrowse:nAt][nPosPad]	:= Criavar("QMS_PADSEC")
								Acols[oGetDad:oBrowse:nAt][nPosEPad]	:= Criavar("QMS_ESCPAD")
								Acols[oGetDad:oBrowse:nAt][nPosInc]	:= Criavar("QMS_INCERT")
							Else
								Acols[oGetDad:oBrowse:nAt][nPosPad]	:= Criavar("QMI_INSUT")
								Acols[oGetDad:oBrowse:nAt][nPosEPad]	:= Criavar("QMI_ESCPAD")
								Acols[oGetDad:oBrowse:nAt][nPosInc]	:= Criavar("QMI_INCERT")
							Endif
							Help( " ", 1, "A140UNIDIF" )//Unidades de Medidas Incompativeis. Cadastre as mesmas.
							lRetu := .F.
						Endif

					Endif
				Else
					dbSelectArea("QM3")
					dbSetOrder(1)
					If dbSeek(xFilial("QM3")+aMedicoes[nLin_aMed][nPosPad])
						cUnidMed := QM3->QM3_UNIMED
						If Alltrim(cUnidMed) <> Alltrim(QM9->QM9_UNIMED)
							dbSelectArea("SAP")
							dbSetOrder(1)
							If dbSeek(xFilial("SAP")+QM9->QM9_UNIMED+cUnidMed)
								nCoef := SAP->AP_COEF
							Else
								If nPosEPad == 0 // Se foi chamado pelo Instrumento Utilizado
									Acols[oGetDad:oBrowse:nAt][nPosPad]	:= Criavar("QMS_PADSEC")
									Acols[oGetDad:oBrowse:nAt][nPosEPad]	:= Criavar("QMS_ESCPAD")
									Acols[oGetDad:oBrowse:nAt][nPosInc]	:= Criavar("QMS_INCERT")
								Else
									Acols[oGetDad:oBrowse:nAt][nPosPad]	:= Criavar("QMI_INSUT")
									Acols[oGetDad:oBrowse:nAt][nPosEPad]	:= Criavar("QMI_ESCPAD")
									Acols[oGetDad:oBrowse:nAt][nPosInc]	:= Criavar("QMI_INCERT")
								Endif
								Help( " ", 1, "A140UNIDIF" )//Unidades de Medidas Incompativeis. Cadastre as mesmas.
								lRetu := .F.
							Endif
						Endif
					Else
						MessageDlg(STR0065,,3) //"Padrao nao Encontrado"
					Endif
				Endif
			Endif
		Else
			MessageDlg(STR0066,,3) //"Escala/Revisao Nao Encontrada"
		Endif
	Endif

	If lRetu
		aCols[oGetDad:oBrowse:nAt,nPosPad] := aEscalas[oLbx:nAt,1]
		aCols[oGetDad:oBrowse:nAt,nPosInc] := StrTran(Str(SuperVal(aEscalas[oLbx:nAt,2])*nCoef),".",",")
	Endif

Return lRetu

/*
antigo a140VlNC
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt140VlNC³ Autor ³ Wanderley Goncalves   ³ Data ³ 11/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo de Nao Conformidades						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA140 - E' chamada no X3_VALID do cpo. QMJ_NAOCON - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt140VlNC()

	Local lRetu 	:= .T.
	LOcal nI 		:= 0
	Local cVar		:= &(readvar()) // Conteudo da variavel do campo Instr.Util.
	Local nPosNC	:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMJ_NAOCON" })
	Local nPosDs	:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMJ_DESC" })
	Local nPosCl	:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMJ_CLASS" })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se mudou a Nao Conformidade (Alterou o campo ja' digitado)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(oGetNco:aCols[oGetNco:oBrowse:nAt][nPosNC]) .and. !Empty(cVar) .and. oGetNco:aCols[oGetNco:oBrowse:nAt][nPosNC] <> cVar
		MessageDlg(STR0030,,3) //"Campo não pode ser alterado. Caso desejar apagar o instrumento pressione a tecla DEL para deixar a linha em branco."
		lRetu := .f.
	EndIf

	If lRetu
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a Nao Conformidade esta' cadastrada ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetNco:aCols[oGetNco:oBrowse:nAt][nPosNC] := M->QMJ_NAOCON
		SAG->(DbSetOrder(1))
		SAG->(DbSeek(xFilial('SAG')+oGetNco:aCols[oGetNco:oBrowse:nAt][nPosNc]))
		If !SAG->(Eof())
			M->QMJ_TEXTO		 := SAG->AG_DESCPO
			oGetNco:aCols[oGetNco:oBrowse:nAt][nPosDs]	 := SAG->AG_DESCPO
			M->QMJ_CLASS		 := SAG->AG_CLASSE
			oGetNco:aCols[oGetNco:oBrowse:nAt][nPosCl]	 := SAG->AG_CLASSE
		Else
			MessageDlg(STR0031,,1)	//"A Não Conformidade informada não se encontra no banco de dados. Informe uma Não Conformidade válida."
			lRetu := .f.
		EndIf
	EndIf

	If lRetu
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a NÆo Conformidade ja' existe       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI := 1 to len(oGetNco:aCols)
			If !oGetNco:aCols[nI][len(aHeader)+1]   // Verifica se ja foi deletado
				If cVar == oGetNco:acols[nI][nPosNC] .and. nI <> n // Se ja' existir este padrao sec.
					MessageDlg(STR0032,,3)	//"Não Conformidade já relacionado a esta medição. Informe outra."
					lRetu := .f.
				EndIf
			EndIf
		Next nI
	EndIf

	If !lRetu
		M->QMJ_NAOCON		:= CriaVar("QMJ_NAOCON")
		oGetNco:aCols[oGetNco:oBrowse:nAt][nPosNC]	:= CriaVar("QMJ_NAOCON")
	EndIf

Return(lRetu)
/*
antigo a140WhRR
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt140WhRR³ Autor ³ Wanderley Gon‡alves   ³ Data ³ 12.03.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Libera campo para digita‡Æo de valor de R&R				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ qmt140WhRR()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ MsgGet da Funcao A140Mae - oMtReprPr						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt140WhRR()

	Local lRet := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o parametro Incluir R&R no calculo de incerteza estiver ativo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetMv("MV_QINCRR") = "S"
		lRet := .T.
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A140GatRev³ Autor ³ Wanderley Gon‡alves   ³ Data ³ 12.03.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para retornar ultima revisao						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A140GatRev()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Gatilho do campo QM6_INSTR p/ QM6_REVINS					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto ³10/05/00³  --	  ³ Inclusão da consistencia para instrumentos³±±
±±³          ³        ³  --	  ³ com status M (Malha)                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140GatRev(oMtRevIns)
	Local cRev	:= Space(2)
	Local lRet	:= .T.

	If !Empty(cMtInstr)
		QM2->(DbSetOrder(1))
		If QM2->(DbSeek(xFilial("QM2")+cMtInstr))
			If QM2->QM2_STATUS = "0"		// Malha
				msgstop(OemToAnsi(StrTran(STR0038,"%@@",ALLTRIM(QM2->QM2_LOCAL))),OemToAnsi(STR0039))	// "Instrumento pertence a Malha %@@, deve ser calibrado com ela." ### "Atencao"
				cRev := Space(2)
				lRet := .F.
			Else
				cRev := QM2->QM2_REVINS
			EndIf
		Else
			MessageDlg(STR0033,,1)	//"Instrumento não cadastrado"
			cMtInstr:= CriaVar("QM2_INSTR")
			cRev	:= CriaVar("QM2_REVINS")
			lRet	:= .F.
		EndIf
		cMtRevIns := cRev
		oMtRevIns:Refresh()
	Endif

Return lRet

/*
antigo a140DesBr
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³qmt140DesB³ Autor ³ Alessandro B. Freire  ³ Data ³ 16/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra a descricao do campo na mBrowse.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Descricao do campo QM6_LAUDO								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_INIBRW do campo QM6_DESLAU 							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt140DesB()

	LOCAL cRetorno := ""

	Do Case
	Case QM6->QM6_LAUDO == "A" // APROVADO
		cRetorno := GetMv("MV_QAPROV")
	Case QM6->QM6_LAUDO == "R" // REPROVADO
		cRetorno := GetMv("MV_QREPRO")
	Case QM6->QM6_LAUDO == "C" // APROVADO CONDICIONAL
		cRetorno := GetMv("MV_QAPCON")
	EndCase

Return(cRetorno)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140CarMed³ Autor ³ Fernando Godoy	    ³ Data ³ 8/12/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza array aMedicoes para monta o Tree.			  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum 									  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³logico 									  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140MoFisrt() 								  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto ³ 15/06/00 ³ Alteracoes para calibrar Tipo de Calibracao Re- ³±±
±±³          ³          ³ logio.                        		  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140CarMed()

	Local aArea 	:= GetArea()
	Local nEspec	:= 0
	Local nDec		:= 0
	Local cEspeci	:= ""
	Local aTexto	:= {}
	Local aColMed	:= {}
	Local aExterna := {}
	Local aPs		:= {}
	Local aIu		:= {}
	Local aITB		:= {}
	Local aNco		:= {}
	Local cRevPad	:= ""
	Local aPadTp5	:= {}
	Local lFound	:= .T.
	Local cTipPad	:= " "
	Local lRet		:= .T.
	Local cRevTip  := ""
	Local lAtrib   := .F.
	Local cToler   := ""
	Local cTolMin  := ""
	Local dDatAnt  := CTOD("  /  /  ","DDMMYY")
	Local lGrvInv	:= .f.
	Local nRecQM7	:= 0
	Local nRecQM3	:= 0
	Local cUnin		:= ""
	Local nRecQMA	:= 0
	Local nRecQMT	:= 0
	Local lFzSom	:= .F.
	Local lOrEsPto  := GetMv("MV_QMOESPT")=="1"
	Local nTotQMA   := 0
	Local cKey      := ""
	Local lMVPADVAL := SuperGetMV("MV_PADVAL",.T.,.F.)
	Private lSugIncB:= GetMv("MV_QSUGINB")=="1"
	aTitEsc 			:= {}
	aPagEsc 			:= {}
	aTitPad 			:= {}
	aPagPad 			:= {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Descricao do Array aMedicoes que contem todas as informacoes³
//³ necessarias para se montar o Folder.					    ³
//³																³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³Col	  Descricao 	     			    Tipo de Dado		³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³ 01	³ Escalas						    ³ String			³
//³ 02	³ Padroes						    ³ String			³
//³ 03	³ Especificado 					   	³ String			³
//³ 04	³ Array com medicoes 		 	   	³ Array				³
//³ 05	³ Observacao						³ String			³
//³ 06	³ Array com padrao secundario 		³ Array				³
//³ 07	³ Array com instrumento utilizado	³ Array				³
//³ 08	³ Array com as nao conformidades 	³ Array				³
//³ 09	³ Incerteza tipo B					³ Array				³
//³ 10	³ Nil                             	³ String			³
//³ 11	³ Array com Medicoes externas 		³ Array				³
//³ 12	³ Array Com informacoes gerais		³ Array				³
//³ 13	³ Array Com Padroes p Esc Tipo 5 	³ Array				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conteudo do array com informacoes Gerais (aColMed)				³
//³ 1o. Elemento - Numero de Medicoes						    	³
//³ 2o. Elemento - Tipo de Afericao 					 		  	³
//³ 3o. Elemento - Tipo do padrao (Mensuravel ou Atributo)		 	³
//³ 4o. Elemento - Destino da Calibracao (Externa ou Interna)	 	³
//³ 5o. Elemento - Usa ou nÆo instrumento Utilizado				 	³
//³ 6o. Elemento - Tipo de Laudo 								 	³
//³ 7o. Elemento - Valor da Tolerancia Maxima / Tolerancia Minima	³
//³ 8o. Elemento - Cadastra Medicoes							 	³
//³ 9o. Elemento - Desvio (para medicoes externas, senao 0) 	 	³
//³10o. Elemento - Incerteza (para medicoes externas, senao 0)   	³
//³11o. Elemento - Revisao da Escala							 	³
//³12o. Elemento - Revisao do Padrao							 	³
//³13o. Elemento - Incerteza do Padrao Primario 				 	³
//³14o. Elemento - Nivel de confianca							 	³
//³15o. Elemento - Valor especificado							 	³
//³16o. Elemento - Incerteza do Tipo A atual 					 	³
//³17o. Elemento - Incerteza do Tipo B atual (Incerteza / Inc.Tot 	|
//³18o. Elemento - LIE para calibrador 							 	³
//³19o. Elemento - LSE para calibrador 							 	³
//³20o. Elemento - Coleta todas as medicoes (QM9_COLETA)   		 	³ 
//³21o. Elemento - Unidade de Medida Ponto                 		 	³
//³22o. Elemento - Unidade de Medida Escala               		 	³
//³																 	³
//³	(ATENCAO!!! - Nos casos em que o numero de medicoes for			³
//³	igual a zero, assume-se que o valor de medicoes ‚ igual			³
//³	a um para funcionarem os "FOR/NEXT". Na validacao do			³
//³	campo, para liberacao da digit.(se coluna a ser digitada		³
//³	‚ maior que o numero de medicoes),verifico acolmed[n,8],		³
//³	ou  seja, se deve ou nao cadastrar medicoes. Portanto,			³
//³	NEM SEMPRE numero de medicoes = 1 indica realmente que e-		³
//³	xiste uma unica medicao.								     	³
//³	Ja o 20o. elemento indica se todos os pontos de medicao da  	³
//³	escala deve realmente conter medicoes cadastradas. Se tiver 	³
//³	igual a "N", significa que nao e necessario pedir justifi-  	³
//³	cativa de falta de medicoes e efetuar todos os calculos com 	³ 
//³	o que foi informado.										 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QM2")
	dbSetOrder(1)
	dbSeek(xFilial("QM2")+cMtInstr+Inverte(cMtRevIns))
	cCdBitMap := QM2->QM2_BITMAP
	cMtRespQM2 := QM2->QM2_RESP
	cDQM2Des   := QM2->QM2_DESCR
	If QM2->QM2_ONLINE == "1" //Se utiliza leitura de dados on line
		lOnLine := .T.
		cBaudRate := QM2->QM2_BAUDRA
		Do Case
		Case cBaudRate == "1"
			cBaudRate := "2400"
		Case cBaudRate == "2"
			cBaudRate := "4800"
		Case cBaudRate == "3"
			cBaudRate := "9600"
		Case cBaudRate == "4"
			cBaudRate := "14400"
		Case cBaudRate == "5"
			cBaudRate := "19200"
		Case cBaudRate == "6"
			cBaudRate := "38400"
		Case cBaudRate == "7"
			cBaudRate := "56000"
		Case cBaudRate == "8"
			cBaudRate := "128000"
		Case cBaudRate == "9"
			cBaudRate := "256000"
		EndCase
	Else
		lOnLine := .F.
	Endif
	If lOnLine
		cParity	:= QM2->QM2_PARITY
		Do Case
		Case cParity == "1"
			cParity := "None"
		Case cParity == "2"
			cParity := "Odd"
		Case cParity == "3"
			cParity := "EvenParity"
		Case cParity == "4"
			cParity := "Mark"
		EndCase
	Else
		lOnLine := .F.
	Endif
	If lOnline
		Do Case
		Case  QM2->QM2_PORTA == "1"
			cPorta	:= "COM1"
		Case QM2->QM2_PORTA == "2"
			cPorta	:= "COM2"
		Case QM2->QM2_PORTA == "3"
			cPorta	:= "COM3"
		Case QM2->QM2_PORTA == "4"
			cPorta	:= "COM4"
		Case QM2->QM2_PORTA == "5"
			cPorta	:= "TECLADO"
		EndCase
	Else
		lOnLine := .F.
	Endif
	If lOnLine
		cData	:= QM2->QM2_BITDAD
		Do Case
		Case cData == "1"
			cData := "4"
		Case cData == "2"
			cData := "5"
		Case cData == "3"
			cData := "6"
		Case cData == "4"
			cData := "7"
		Case cData == "5"
			cData := "8"
		EndCase
	Else
		lOnline := .F.
	Endif

	If lOnLine
		nStop	:= QM2->QM2_STOPS
		Do Case
		Case nStop == "1"
			nStop := 1
		Case nStop == "2"
			nStop := 1.5
		Case nStop == "3"
			nStop := 2
		EndCase
	Else
		lOnLine := .F.
	Endif

	If Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a data da ultima calibracao, usada nas funcoes ³
		//³	MontPSec e MontPIns										³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dDatAnt := a140DatAnt(cMtInstr,cMtRevIns)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³											 				 ³
		//³ Caso Seja inclusao e exista no QMR, senao procura no QMK ³
		//³											   	 			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QMR")
		dbSetOrder(1)
		dbGoTop()
		dbSelectArea("QM9")
		dbSetOrder(1)
		dbGoTop()
		If QMR->(dbSeek(xFilial("QMR")+QM2->QM2_INSTR+QM2->QM2_REVINS))
			Do While !Eof() .AND. xFilial("QMR")+QM2->QM2_INSTR+QM2->QM2_REVINS ==;
					QMR->QMR_FILIAL+QMR->QMR_INSTR+QMR->QMR_REVINS
				aPdSes := {}
				aPSecuns := {}
				If QM9->(dbSeek(xFilial("QM9")+QMR->QMR_ESCALA))
					If !Eof() .And. !(QM9->QM9_TIPAFE $ "4|8")  //Calibrador - Calib.Completo

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Tipos 1,2,3,6,7 e 9  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !QM9->QM9_TIPAFE  $ "5| " //Tipo Soma
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Medicao externa sem coleta ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							dbSelectArea("QMC")
							dbSetOrder(1)
							QMC->(dbSeek(xFilial("QMC")+QMR->QMR_ESCALA,.f.))
							cRevisao := QMC->QMC_REVESC

							While ( !Eof() .And. QMR->QMR_ESCALA == QMC->QMC_ESCALA ) ;
									.And. cRevisao == QMC->QMC_REVESC .And. xFilial("QMC") ==;
									QMC->QMC_FILIAL
								QM3->(dbSetOrder(1))
								QM3->(dbSeek( xFilial("QM3")+QMC->QMC_PADRAO ))
								cRevPad	:= QM3->QM3_REVPAD
								If QM3->QM3_INVRPD == "  " .and. QM3->(!Eof())
									lGrvInv := .T.
								Else
									If (Alltrim(Inverte(QM3->QM3_REVPAD)) <> Alltrim(QM3->QM3_INVRPD)) .and. QM3->(!Eof())
										lGrvInv := .T.
									Endif
								Endif

								If lGrvInv
									dbSelectArea("QM3")
									dbSetOrder(01)
									RecLock("QM3",.F.)
									Replace QM3->QM3_INVRPD With Inverte(QM3->QM3_REVPAD)
									MsUnLock()
								Endif
								If !(Alltrim(FunName())) $ "QMTM900"
									If !Empty(QM3->QM3_VALDAF)
										If dDataBase > QM3->QM3_VALDAF .AND. QMR->QMR_CAOBRI == "S"
											lYesNo := MsgYesNo(STR0091+Chr(13)+Chr(10)+Alltrim(QM3->QM3_PADRAO)+"  -  "+; //"Para calibracao do instrumento, existe a necessidade da calibracao do padrao: "
											QM3->QM3_REVPAD+"  -  "+DtoC(QM3->QM3_VALDAF)+"."+Chr(13)+Chr(10)+Chr(13)+Chr(10)+STR0092,STR0093)//Deseja Continuar? / Padrao Vencido

											If lMVPADVAL .Or. !lYesNo
												aMedicoes := {}
												Return .F.
											Endif
										Endif
									Endif
								Endif
								aTexto := MontTexto(QMR->QMR_ESCALA,QMC->QMC_PADRAO,cRevisao,cRevPad)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Carrega Medicoes Externas ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aColMed := {}
								Aadd(aColMed,{QM9->QM9_NROMED,;
									QM9->QM9_TIPAFE,QM3->QM3_TIPPAD,;
									QM9->QM9_ORGAFE,QM9->QM9_INSUTI,QM9->QM9_LAUDO,;
									{If(!empty(QMC->QMC_TOLER),QMC->QMC_TOLER,QM3->QM3_TOLER),;
									If(!empty(QMC->QMC_TOLMIN),QMC->QMC_TOLMIN,QM3->QM3_TOLMIN)},;
										If(QM9->QM9_NROMED>0,"S","N"), CriaVar("QM7_ERSIST"), CriaVar("QM7_INCERT"),;  //COLETA
											QM9->QM9_REVESC,QM3->QM3_REVPAD,;
											QM3->QM3_INCERT, QM9->QM9_NCONF,;
											QM9->QM9_VALESP,0,{"",""},"","",QMR->QMR_CAOBRI,QM3->QM3_TIPTOL,;
											QM3->QM3_UNIMED,QM9->QM9_UNIMED})
										QM7->(dbSetOrder(1))
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Carrega Medicoes Externas ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										aExterna := {}
										Aadd( aExterna, { CriaVar("QM7_LABOR"),;
											CriaVar("QM7_NRCERT")} )
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Carrega padroes secundarios ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										aPs := {}
										aPs := MontPSec(QMR->QMR_ESCALA, QMC->QMC_PADRAO,dDatAnt,QM7->QM7_CSEQ,QM3->QM3_UNIMED)
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Carrega Instrumento Utilizado ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										aIu := {}
										aIu := MontPIns(QMR->QMR_ESCALA, QMC->QMC_PADRAO,dDatAnt,QM7->QM7_CSEQ,QM3->QM3_UNIMED)
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Carrega Nao conformidades ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										aNco := {}
										aNco := MontNco(QMR->QMR_ESCALA, QMC->QMC_PADRAO)
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Carrega Incertezas Tipo B ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										aITB := {}
										aITB := MontITB(QMR->QMR_ESCALA, QMC->QMC_PADRAO)
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Adiciona no aMedicoes ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										Aadd(aMedicoes, { QMR->QMR_ESCALA, QMC->QMC_PADRAO,;
											QM3->QM3_ESPEC, MontAmed(QM3->QM3_PADRAO,cRevPad,;
											QM3->QM3_TIPPAD), Aclone(aTexto), Aclone(aPs),;
											Aclone(aIu),Aclone(aNco),Aclone(aITB),"",;
											Aclone(aExterna) , Aclone(aColMed), {} } )

										If QM9->QM9_UNIMED <> QM3->QM3_UNIMED
											dbSelectArea("SAP")
											dbSetOrder(1)
											If dbSeek(xFilial("SAP")+QM3->QM3_UNIMED+QM9->QM9_UNIMED)
												nCoef := SAP->AP_COEF
												//aMedicoes[LEN(aMedicoes),3] := StrTran(Str(SuperVal(aMedicoes[LEN(aMedicoes),3])*nCoef,Len(aMedicoes[LEN(aMedicoes),3]),QA_NUMDEC(aMedicoes[LEN(aMedicoes),3])),".",",")
												aMedicoes[LEN(aMedicoes),3] := StrTran(CVALTOCHAR(SuperVal(aMedicoes[LEN(aMedicoes),3])*nCoef),".",",")
											Endif
										Endif

										If Ascan(aTitEsc,{|x| x ==QMR->QMR_ESCALA}) == 0
											Aadd(aTitEsc,QMR->QMR_ESCALA)
											Aadd(aPagEsc,QMR->QMR_ESCALA)
										EndIf

										dbSelectArea("QMC")
										dbSkip()
									EndDo
								Elseif QM9->QM9_TIPAFE =="5"
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Tipo 5 - Soma ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									dbSelectArea("QMA")
									dbSetOrder(1)
									If QMA->(dbSeek(xFilial("QMA")+QM9->QM9_ESCALA + QM9->QM9_REVESC))
										nTotQMA := 0
										While QMA->QMA_ESCALA+QMA->QMA_REVESC ==;
												QM9->QM9_ESCALA+QM9->QM9_REVESC .And. !Eof() .And.;
												QMA->QMA_FILIAL == xFilial("QMA")
											cRevisao := QMA->QMA_REVESC
											cFaixa	:= QMA->QMA_FAIXA
											nEspec 	:= 0
											aPadTp5	:= {}
											If lTamSom
												nDec := 0
											Endif
											While QMA->QMA_ESCALA+QMA->QMA_REVESC+QMA->QMA_FAIXA ==;
													QM9->QM9_ESCALA+QM9->QM9_REVESC+cFaixa .And.;
													QMA->QMA_FILIAL == xFilial("QMA") .And. !Eof()
												dbSelectArea("QM3")
												QM3->(DbSetOrder(1))
												QM3->(DbSeek(xFilial("QM3") + QMA->QMA_PADRAO))
												If !(Alltrim(FunName())) $ "QMTM900"
													If !Empty(QM3->QM3_VALDAF)
														If dDataBase > QM3->QM3_VALDAF
															If !MsgYesNo(STR0091+Chr(13)+Chr(10)+Alltrim(QM3->QM3_PADRAO)+"  -  "+;
																	QM3->QM3_REVPAD+"  -  "+DtoC(QM3->QM3_VALDAF)+"."+Chr(13)+Chr(10)+Chr(13)+Chr(10)+STR0092,STR0093)
																Return .F.
															Endif
														Endif
													Endif
												Endif
												If dMtData >= QM3->QM3_DATREV
													Aadd( aPadTp5, {QM3->QM3_PADRAO, QM3->QM3_REVPAD} )
													nRecQMA := QMA->(RecNo())
													If !QM3->QM3_TIPPAD == "A"
														nEspec += SuperVal(QM3->QM3_ESPEC)
														nDEC := If(nDec>QA_NUMDEC(QM3->QM3_ESPEC),nDEC,;
															QA_NUMDEC(QM3->QM3_ESPEC))
														cToler	:= QMA->QMA_TOLER
														cTolMin	:= QMA->QMA_TOLMIN
														cUnin	:= QM3->QM3_UNIMED
													Else
														lAtrib := .T.
													EndIf
												Endif
												QMA->(DbSkip())
											EndDo
											nTotQMA := QMA->(RecNo())
											QMA->(dbGoto(nRecQMA))
											If nRecQMA == 0 .and. QMA->(Eof()) .and. Len(aPadTp5) = 0
												MessageDlg(STR0107,,2) //"Data de Calibracao do instrumento inferior a data do(s) ponto(s)/padrao(oes). Verifique os ponto(s)/padrao(oes) bem como a data de calibracao."
												Exit
											Endif
											If Len(aPadTp5) > 0
												cEspeci := Str(nEspec,TamSx3("QM3_ESPEC")[1],nDec)
												If Alltrim(SubStr(cEspeci,1,1)) == "*"
													cEspeci := Str(nEspec,TamSx3("QM3_ESPEC")[1],nDec-1)
												Endif
												cEspeci := StrTran(cEspeci,'.',',')
												If QM9->QM9_NROMED > 0		//QM9->QM9_COLETA == "S"
													If QM9->QM9_NROMED > 0
														Do Case
														Case QM9->QM9_TIPAFE $ "1|4"  // Simples
															aMed := Array(QM9->QM9_NROMED,1)
														Case QM9->QM9_TIPAFE $ "2|5|8"   // Completa
															aMed := Array(QM9->QM9_NROMED,2)
														Case QM9->QM9_TIPAFE $ "3|9"   // Pressao ou Relogio
															aMed := Array(QM9->QM9_NROMED,4)
														EndCase
													Else
														aMed := {}
													EndIf
												Else
													aMed := {}
												EndIf
												aTexto	:= MontTexto(QMR->QMR_ESCALA,QMA->QMA_FAIXA,cRevisao,cFaixa)
												aColMed := {}
												Aadd(aColMed,{QM9->QM9_NROMED,QM9->QM9_TIPAFE,;
													If(lAtrib,"A","O"),QM9->QM9_ORGAFE,QM9->QM9_INSUTI,QM9->QM9_LAUDO,;
														{cToler,cTolMin}, If(QM9->QM9_NROMED>0,"S","N"), 0, 0,;  //COLETA
													QM9->QM9_REVESC,"  ",QMT140IPS(cFaixa),QM9->QM9_NCONF,;
														QM9->QM9_VALESP,0,{"",""},"","",QMR->QMR_CAOBRI,QMA->QMA_TIPTOL,;
														cUnin,QM9->QM9_UNIMED }) // Incerteza sera calculada
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ Carrega Medicoes Externas ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													aExterna := {}
													Aadd( aExterna, { CriaVar("QM7_LABOR"),;
														CriaVar("QM7_NRCERT")} )
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ Carrega padroes secundarios ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													aPs := {}
													aPs := MontPSec(QMR->QMR_ESCALA, QMA->QMA_FAIXA,dDatAnt,QM7->QM7_CSEQ,cUnin)
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ Carrega Instrumento Utilizado ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													aIu := {}
													aIu := MontPIns(QMR->QMR_ESCALA, QMA->QMA_FAIXA,dDatAnt,QM7->QM7_CSEQ,cUnin)
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ Carrega Nao conformidades ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													aNco := {}
													aNco := MontNco(QMR->QMR_ESCALA, QMA->QMA_FAIXA)
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ Carrega Incertezas Tipo B ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													aITB := {}
													aITB := MontITB(QMR->QMR_ESCALA, QMA->QMA_FAIXA)
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³					  	  ³
													//³ Adiciona no aMedicoes ³
													//³					  	  ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													Aadd(aMedicoes, { QMR->QMR_ESCALA,cFaixa,;
														cEspeci, MontAmed(cFaixa,,If(lAtrib,"A","O")), Aclone(aTexto),;
														Aclone( aPs),Aclone(aIu),Aclone(aNco),Aclone(aITB),"",;
														Aclone(aExterna),AClone(aColMed), Aclone(aPadTp5) } )

													Aadd(aTitEsc,QMR->QMR_ESCALA)
													Aadd(aPagEsc,QMR->QMR_ESCALA)
												Endif
												dbSelectArea("QMA")
												dbSkip()
											EndDo
										EndIf
									Elseif empty(QM9->QM9_TIPAFE) // Externo
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Instrumento externo sem medicao ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If QM9->QM9_ORGAFE == "E" //.And. QM9->QM9_NROMED == 0
											cRevisao := QM9->QM9_REVESC
											cRevPad	:= Criavar("QM3_REVPAD",.F.)
											aTexto := MontTexto(QMR->QMR_ESCALA,"PADRAOEXT",cRevisao,cRevPad)
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Carrega aColMed ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											aColMed := {}
											Aadd(aColMed,{QM9->QM9_NROMED,;
												QM9->QM9_TIPAFE,"A",;
												QM9->QM9_ORGAFE,QM9->QM9_INSUTI,QM9->QM9_LAUDO,;
												{0,0},If(QM9->QM9_NROMED>0,"S","N"), CriaVar("QM7_INCERT"), CriaVar("QM7_INCERT"),;   //COLETA
											QM9->QM9_REVESC,cRevPad,;
												0, QM9->QM9_NCONF,;
												QM9->QM9_VALESP,0,{"",""},"","",QMR->QMR_CAOBRI,QM3->QM3_TIPTOL,;
												QM3->QM3_UNIMED,QM9->QM9_UNIMED })
											QM7->(dbSetOrder(1))
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Carrega Medicoes Externas ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											aExterna := {}
											Aadd( aExterna, { CriaVar("QM7_LABOR"),;
												CriaVar("QM7_NRCERT")} )
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Carrega padroes secundarios ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											aPs := {}
											aPs := MontPSec(QMR->QMR_ESCALA, "PADRAOEXT",dDatAnt,QM7->QM7_CSEQ,QM3->QM3_UNIMED)
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Carrega Instrumento Utilizado ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											aIu := {}
											aIu := MontPIns(QMR->QMR_ESCALA, "PADRAOEXT",dDatAnt,QM7->QM7_CSEQ,QM3->QM3_UNIMED)
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Carrega Nao conformidades ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											aNco := {}
											aNco := MontNco(QMR->QMR_ESCALA, "PADRAOEXT")
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Carrega Incertezas Tipo B ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											aITB := {}
											aITB := MontITB(QMR->QMR_ESCALA, "PADRAOEXT")
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³					  	  ³
											//³ Adiciona no aMedicoes ³
											//³					  	  ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											Aadd(aMedicoes, { QMR->QMR_ESCALA, "PADRAOEXT",;
												"", MontAmed("PADRAOEXT",cRevPad,;
												"A"), Aclone(aTexto), Aclone(aPs),;
												Aclone(aIu),Aclone(aNco),Aclone(aITB),"",;
												Aclone(aExterna) , Aclone(aColMed), {} } )

											Aadd(aTitEsc,QMR->QMR_ESCALA)
											Aadd(aPagEsc,QMR->QMR_ESCALA)
										Endif
									EndIf

								Else
									If !Eof() .And. QM9->QM9_TIPAFE $ "4|8"
										If QMR->QMR_CAOBRI == "S"
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Para tipos = calibrador e calibrador completo ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											dbSelectArea("QMG")
											dbSetOrder(1)
											If dbSeek(xFilial("QMG")+cMtInstr+cMtRevIns,.f.)
												While ( !Eof() .And. cMtInstr + cMtRevIns == QMG->QMG_INSTR + QMG->QMG_REVINS )
													aTexto	:= MontTexto(QMR->QMR_ESCALA,QMG->QMG_PONTO,QM9->QM9_REVESC,Space(2))
													aColMed := {}
													Aadd(aColMed,{QM9->QM9_NROMED,QM9->QM9_TIPAFE,;
														QMG->QMG_TIPCAL,QM9->QM9_ORGAFE,QM9->QM9_INSUTI,;
														QM9->QM9_LAUDO,{0,0}, If(QM9->QM9_NROMED>0,"S","N"),CriaVar("QM7_INCERT"),CriaVar("QM7_INCERT"),;  //COLETA
													QM9->QM9_REVESC,"  ", "0",QM9->QM9_NCONF,;
														QM9->QM9_VALESP,0,{"",""},QMG->QMG_LIE,QMG->QMG_LSE,QM9->QM9_COLETA,QMG->QMG_TIPTOL,;
														QMG->QMG_UNIMED,QM9->QM9_UNIMED})
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ Carrega Medicoes Externas ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													aExterna := {}
													Aadd( aExterna, { CriaVar("QM7_LABOR"),;
														CriaVar("QM7_NRCERT")} )
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ Carrega padroes secundarios ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													aPs := {}
													aPs := MontPSec(QMR->QMR_ESCALA, QMG->QMG_PONTO,dDatAnt,QM7->QM7_CSEQ,QMG->QMG_UNIMED)
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ Carrega Instrumento Utilizado ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													aIu := {}
													aIu := MontPIns(QMR->QMR_ESCALA, QMG->QMG_PONTO,dDatAnt,QM7->QM7_CSEQ,QMG->QMG_UNIMED)
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ Carrega Nao conformidades ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													aNco := {}
													aNco := MontNco(QMR->QMR_ESCALA, QMG->QMG_PONTO)
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ Carrega Incertezas Tipo B ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													aITB := {}
													aITB := MontITB(QMR->QMR_ESCALA, QMG->QMG_PONTO)
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ Adiciona no aMedicoes ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													Aadd(aMedicoes, { QMR->QMR_ESCALA, QMG->QMG_PONTO,;
														QMG->QMG_NOMIN, MontAmed(QMG->QMG_PONTO,,QMG->QMG_TIPCAL),;
														Aclone(aTexto),Aclone( aPs ),Aclone(aIu),Aclone(aNco),Aclone(aITB),;
														"" ,AClone(aExterna), Aclone(aColMed),{} } )

													Aadd(aTitEsc,QMR->QMR_ESCALA)
													Aadd(aPagEsc,QMR->QMR_ESCALA)
													dbSelectArea("QMG")
													dbSkip()
												EndDo
											EndIf
										Endif
									Endif
								EndIf
							EndIf
							DbSelectArea("QMR")
							QMR->(DbSkip())
						EndDo
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Caso Seja inclusao procura no QMK, senao procura no QM7 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("QMK")
						dbSetOrder(1)
						If dbSeek(xFilial("QMK")+QM2->QM2_TIPO)

							dbSelectArea("QM9")
							dbSetOrder(1)
							If dbSeek(xFilial("QM9")+QMK->QMK_ESCALA)
								If !Eof() .And. !(QM9->QM9_TIPAFE $ "4|8")
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Tipos 1,2,3,5,6,7,9  ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cRevTip := QMK->QMK_REVTIP
									While (!Eof() .And. QM2->QM2_TIPO + cRevTip ==;
											QMK->QMK_TIPO + QMK->QMK_REVTIP)
										dbSelectArea("QM9")
										dbSetOrder(1)
										dbSeek(xFilial("QM9")+QMK->QMK_ESCALA)

										QMR->(DbSetOrder(1))

										If QMR->(DbSeek(xFilial("QMR")+cMtInstr+cMtRevIns+QMK->QMK_ESCALA))

											If QMR->QMR_CAOBRI == "S"
												//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
												//³ Tipos 1,2,3,6,7 e 9  ³
												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
												If !QM9->QM9_TIPAFE  $ "5| " //Tipo Soma
													dbSelectArea("QM9")
													dbSetOrder(1)
													dbSeek(xFilial("QM9")+QMK->QMK_ESCALA)
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ Medicao externa sem coleta ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													dbSelectArea("QMC")
													dbSetOrder(1)
													dbSeek(xFilial("QMC")+QMK->QMK_ESCALA,.f.)

													cRevisao := QMC->QMC_REVESC
													cRevPad	:= QM3->QM3_REVPAD

													While ( !Eof() .And. QMK->QMK_ESCALA == QMC->QMC_ESCALA ) ;
															.And. cRevisao == QMC->QMC_REVESC .And. xFilial("QMC") ==;
															QMC->QMC_FILIAL

														QM3->(dbSetOrder(1))
														QM3->(dbSeek( xFilial("QM3")+QMC->QMC_PADRAO ))
														If !(Alltrim(FunName())) $ "QMTM900"
															If !Empty(QM3->QM3_DATAF)
																If dDataBase > QM3->QM3_DATAF
																	If !MsgYesNo(STR0091+Chr(13)+Chr(10)+Alltrim(QM3->QM3_PADRAO)+"  -  "+;
																			QM3->QM3_REVPAD+"  -  "+DtoC(QM3->QM3_VALDAF)+"."+Chr(13)+Chr(10)+Chr(13)+Chr(10)+STR0092,STR0093)
																		Return .F.
																	Endif
																Endif
															Endif
														Endif
														aTexto := MontTexto(QMK->QMK_ESCALA,QMC->QMC_PADRAO,cRevisao,cRevPad)

														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
														//³ Carrega Medicoes Externas ³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
														aColMed := {}
														Aadd(aColMed,{QM9->QM9_NROMED,;
															QM9->QM9_TIPAFE,QM3->QM3_TIPPAD,;
															QM9->QM9_ORGAFE,QM9->QM9_INSUTI,QM9->QM9_LAUDO,;
															{If(!empty(QMC->QMC_TOLER),QMC->QMC_TOLER,QM3->QM3_TOLER),;
															If(!empty(QMC->QMC_TOLMIN),QMC->QMC_TOLMIN,QM3->QM3_TOLMIN)},;
																If(QM9->QM9_NROMED>0,"S","N"), CriaVar("QM7_ERSIST"), CriaVar("QM7_INCERT"),;  //COLETA
																QM9->QM9_REVESC,QM3->QM3_REVPAD,;
																	QM3->QM3_INCERT, QM9->QM9_NCONF,;
																	QM9->QM9_VALESP,0,{"",""},"","",QMR->QMR_CAOBRI,QM3->QM3_TIPTOL,;
																	QM3->QM3_UNIMED,QM9->QM9_UNIMED })

																QM7->(dbSetOrder(1))

																//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																//³ Carrega Medicoes Externas ³
																//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																aExterna := {}
																Aadd( aExterna, { CriaVar("QM7_LABOR"),;
																	CriaVar("QM7_NRCERT")} )

																//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																//³ Carrega padroes secundarios ³
																//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																aPs := {}
																aPs := MontPSec(QMK->QMK_ESCALA, QMC->QMC_PADRAO,dDatAnt,QM7->QM7_CSEQ,QM3->QM3_UNIMED)

																//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																//³ Carrega Instrumento Utilizado ³
																//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																aIu := {}
																aIu := MontPIns(QMK->QMK_ESCALA, QMC->QMC_PADRAO,dDatAnt,QM7->QM7_CSEQ,QM3->QM3_UNIMED)

																//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																//³ Carrega Nao conformidades ³
																//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																aNco := {}
																aNco := MontNco(QMK->QMK_ESCALA, QMC->QMC_PADRAO)

																//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																//³ Carrega Incertezas Tipo B ³
																//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																aITB := {}
																aITB := MontITB(QMK->QMK_ESCALA, QMC->QMC_PADRAO)

																//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																//³						  ³
																//³ Adiciona no aMedicoes ³
																//³						  ³
																//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																Aadd(aMedicoes, { QMK->QMK_ESCALA, QMC->QMC_PADRAO,;
																	QM3->QM3_ESPEC, MontAmed(QM3->QM3_PADRAO,cRevPad,;
																	QM3->QM3_TIPPAD), Aclone(aTexto), Aclone(aPs),;
																	Aclone(aIu),Aclone(aNco),Aclone(aITB),"",;
																	Aclone(aExterna) , Aclone(aColMed), {} } )

																Aadd(aTitEsc,QMK->QMK_ESCALA)
																Aadd(aPagEsc,QMK->QMK_ESCALA)

																dbSelectArea("QMC")
																dbSkip()
															EndDo
														Elseif QM9->QM9_TIPAFE =="5"
															//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
															//³ Tipos 5 - Soma ³
															//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
															dbSelectArea("QM9")
															dbSetOrder(1)
															If dbSeek(xFilial("QM9")+QMK->QMK_ESCALA)
																dbSelectArea("QMA")
																dbSetOrder(1)
																If dbSeek(xFilial("QMA")+QM9->QM9_ESCALA + QM9->QM9_REVESC)
																	While QMA->QMA_ESCALA+QMA->QMA_REVESC ==;
																			QM9->QM9_ESCALA+QM9->QM9_REVESC .And. !Eof() .And.;
																			QMA->QMA_FILIAL == xFilial("QMA")
																		cRevisao := QMA->QMA_REVESC
																		cFaixa	:= QMA->QMA_FAIXA
																		nEspec	:= 0
																		aPadTp5	:= {}
																		Do While QMA->QMA_ESCALA+QMA->QMA_REVESC+QMA->QMA_FAIXA ==;
																				QM9->QM9_ESCALA+QM9->QM9_REVESC+cFaixa .And.;
																				QMA->QMA_FILIAL == xFilial("QMA") .And. !Eof()

																			QM3->(DbSetOrder(1))
																			QM3->(DbSeek(xFilial("QM3") + QMA->QMA_PADRAO))
																			If !(Alltrim(FunName())) $ "QMTM900"
																				If !Empty(QM3->QM3_DATAF)
																					If dDataBase > QM3->QM3_DATAF
																						If !MsgYesNo(STR0091+Chr(13)+Chr(10)+Alltrim(QM3->QM3_PADRAO)+"  -  "+;
																								QM3->QM3_REVPAD+"  -  "+DtoC(QM3->QM3_VALDAF)+"."+Chr(13)+Chr(10)+Chr(13)+Chr(10)+STR0092,STR0093)
																							Return .F.
																						Endif
																					Endif
																				Endif
																			Endif
																			If dMtData >= QM3->QM3_DATREV
																				Aadd( aPadTp5, {QM3->QM3_PADRAO, QM3->QM3_REVPAD} )
																				If !QM3->QM3_TIPPAD == "A"
																					nEspec += SuperVal(QM3->QM3_ESPEC)
																					nDEC := If(nDec>QA_NUMDEC(QM3->QM3_ESPEC),nDEC,;
																						QA_NUMDEC(QM3->QM3_ESPEC))
																					cToler := QMA->QMA_TOLER
																					cTolMin:= QMA->QMA_TOLMIN
																				Else
																					lAtrib := .T.
																				EndIf
																			Endif
																			QMA->(DbSkip())
																		EndDo
																		If Len(aPadTp5)
																			cEspeci := Str(nEspec,TamSx3("QM3_ESPEC")[1],nDec)
																			If Alltrim(SubStr(cEspeci,1,1)) == "*"
																				cEspeci := Str(nEspec,TamSx3("QM3_ESPEC")[1],nDec-1)
																			Endif
																			cEspeci := StrTran(cEspeci,'.',',')

																			If QM9->QM9_NROMED > 0
																				If QM9->QM9_NROMED > 0
																					Do Case
																					Case QM9->QM9_TIPAFE $ "1|4"  // Simples
																						aMed := Array(QM9->QM9_NROMED,1)
																					Case QM9->QM9_TIPAFE $ "2|5|8"   // Completa
																						aMed := Array(QM9->QM9_NROMED,2)
																					Case QM9->QM9_TIPAFE $ "3|9"   // Pressao ou Relogio
																						aMed := Array(QM9->QM9_NROMED,4)
																					EndCase
																				Else
																					aMed := {}
																				EndIf
																			Else
																				aMed := {}
																			EndIf

																			aTexto	:= MontTexto(QMK->QMK_ESCALA,QMA->QMA_FAIXA,cRevisao,cFaixa)

																			aColMed := {}
																			Aadd(aColMed,{QM9->QM9_NROMED,QM9->QM9_TIPAFE,;
																				If(lAtrib,"A","O"),QM9->QM9_ORGAFE,QM9->QM9_INSUTI,QM9->QM9_LAUDO,;
																					{cToler,cTolMin}, If(QM9->QM9_NROMED>0,"S","N"), 0, 0,;  //COLETA
																				QM9->QM9_REVESC,"  ", "0",QM9->QM9_NCONF,;
																					QM9->QM9_VALESP,0,{"",""},"","",QMR->QMR_CAOBRI,QM3->QM3_TIPTOL,;
																					QM3->QM3_UNIMED,QM9->QM9_UNIMED }) // Incerteza sera calculada
																				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																				//³ Carrega Medicoes Externas ³
																				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																				aExterna := {}
																				Aadd( aExterna, { CriaVar("QM7_LABOR"),;
																					CriaVar("QM7_NRCERT")} )

																				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																				//³ Carrega padroes secundarios ³
																				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																				aPs := {}
																				aPs := MontPSec(QMK->QMK_ESCALA, QMA->QMA_FAIXA,dDatAnt,QM7->QM7_CSEQ,QM3->QM3_UNIMED)

																				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																				//³ Carrega Instrumento Utilizado ³
																				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																				aIu := {}
																				aIu := MontPIns(QMK->QMK_ESCALA, QMA->QMA_FAIXA,dDatAnt,QM7->QM7_CSEQ,QM3->QM3_UNIMED)

																				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																				//³ Carrega Nao conformidades ³
																				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																				aNco := {}
																				aNco := MontNco(QMK->QMK_ESCALA, QMA->QMA_FAIXA)

																				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																				//³ Carrega Incertezas Tipo B ³
																				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																				aITB := {}
																				aITB := MontITB(QMK->QMK_ESCALA, QMA->QMA_FAIXA)

																				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																				//³ Adiciona no aMedicoes ³
																				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																				Aadd(aMedicoes, { QMK->QMK_ESCALA,cFaixa,;
																					cEspeci, MontAmed(cFaixa,,If(lAtrib,"A","O")), Aclone(aTexto),;
																					Aclone( aPs),Aclone(aIu),Aclone(aNco),Aclone(aITB),"",;
																					Aclone(aExterna),AClone(aColMed), Aclone(aPadTp5) } )

																				Aadd(aTitEsc,QMK->QMK_ESCALA)
																				Aadd(aPagEsc,QMK->QMK_ESCALA)
																			Endif
																		EndDo
																	EndIf
																EndIf

															Elseif empty(QM9->QM9_TIPAFE) // Externo
																//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																//³ Instrumento externo sem medicao ³
																//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																If QM9->QM9_ORGAFE == "E" .And. QM9->QM9_NROMED == 0

																	cRevisao := QM9->QM9_REVESC
																	cRevPad	:= Criavar("QM3_REVPAD",.F.)

																	aTexto := MontTexto(QMK->QMK_ESCALA,"PADRAOEXT",cRevisao,cRevPad)

																	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																	//³ Carrega aColMed ³
																	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																	aColMed := {}
																	Aadd(aColMed,{QM9->QM9_NROMED,;
																		QM9->QM9_TIPAFE,"A",;
																		QM9->QM9_ORGAFE,QM9->QM9_INSUTI,QM9->QM9_LAUDO,;
																		{0,0},If(QM9->QM9_NROMED>0,"S","N"), CriaVar("QM7_INCERT"), CriaVar("QM7_INCERT"),;   //COLETA
																	QM9->QM9_REVESC,cRevPad,;
																		0, QM9->QM9_NCONF,;
																		QM9->QM9_VALESP,0,{"",""},"","",QMR->QMR_CAOBRI,QM3->QM3_TIPTOL,;
																		QM3->QM3_UNIMED,QM9->QM9_UNIMED})

																	QM7->(dbSetOrder(1))

																	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																	//³ Carrega Medicoes Externas ³
																	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																	aExterna := {}
																	Aadd( aExterna, { CriaVar("QM7_LABOR"),;
																		CriaVar("QM7_NRCERT")} )

																	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																	//³ Carrega padroes secundarios ³
																	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																	aPs := {}
																	aPs := MontPSec(QMK->QMK_ESCALA, "PADRAOEXT",dDatAnt,QM7->QM7_CSEQ,QM3->QM3_UNIMED)

																	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																	//³ Carrega Instrumento Utilizado ³
																	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																	aIu := {}
																	aIu := MontPIns(QMK->QMK_ESCALA, "PADRAOEXT",dDatAnt,QM7->QM7_CSEQ,QM3->QM3_UNIMED)

																	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																	//³ Carrega Nao conformidades ³
																	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																	aNco := {}
																	aNco := MontNco(QMK->QMK_ESCALA, "PADRAOEXT")

																	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																	//³ Carrega Incertezas Tipo B ³
																	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																	aITB := {}
																	aITB := MontITB(QMK->QMK_ESCALA, "PADRAOEXT")

																	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																	//³ Adiciona no aMedicoes ³
																	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																	Aadd(aMedicoes, { QMK->QMK_ESCALA, "PADRAOEXT",;
																		"", MontAmed("PADRAOEXT",cRevPad,;
																		"A"), Aclone(aTexto), Aclone(aPs),;
																		Aclone(aIu),Aclone(aNco),Aclone(aITB),"",;
																		Aclone(aExterna) , Aclone(aColMed), {} } )

																	Aadd(aTitEsc,QMK->QMK_ESCALA)
																	Aadd(aPagEsc,QMK->QMK_ESCALA)
																Endif
															EndIf
														EndIf
													EndIf

													dbSelectArea("QMK")
													dbSkip()
												EndDo
											Else
												If !Eof() .And. QM9->QM9_TIPAFE $ "4|8"
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ Para tipos = calibrador e calibrador completo ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													dbSelectArea("QMG")
													dbSetOrder(1)
													If dbSeek(xFilial("QMG")+cMtInstr+cMtRevIns,.f.)
														While ( !Eof() .And. cMtInstr + cMtRevIns == QMG->QMG_INSTR + QMG->QMG_REVINS )

															aTexto	:= MontTexto(QMK->QMK_ESCALA,QMG->QMG_PONTO,QM9->QM9_REVESC,Space(2))

															aColMed := {}
															Aadd(aColMed,{QM9->QM9_NROMED,QM9->QM9_TIPAFE,;
																QMG->QMG_TIPCAL,QM9->QM9_ORGAFE,QM9->QM9_INSUTI,;
																QM9->QM9_LAUDO,{0,0}, If(QM9->QM9_NROMED>0,"S","N"),CriaVar("QM7_INCERT"),CriaVar("QM7_INCERT"),;  //COLETA
															QM9->QM9_REVESC,"  ", "0",QM9->QM9_NCONF,;
																QM9->QM9_VALESP,0,{"",""},QMG->QMG_LIE,QMG->QMG_LSE,QM9->QM9_COLETA,QMG->QMG_TIPTOL,;
																QMG->QMG_UNIMED,QM9->QM9_UNIMED})

															//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
															//³ Carrega Medicoes Externas ³
															//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
															aExterna := {}
															Aadd( aExterna, { CriaVar("QM7_LABOR"),;
																CriaVar("QM7_NRCERT")} )

															//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
															//³ Carrega padroes secundarios ³
															//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
															aPs := {}
															aPs := MontPSec(QMK->QMK_ESCALA, QMG->QMG_PONTO,dDatAnt,QM7->QM7_CSEQ,QMG->QMG_UNIMED)

															//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
															//³ Carrega Instrumento Utilizado ³
															//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
															aIu := {}
															aIu := MontPIns(QMK->QMK_ESCALA, QMG->QMG_PONTO,dDatAnt,QM7->QM7_CSEQ,QMG->QMG_UNIMED)

															//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
															//³ Carrega Nao conformidades ³
															//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
															aNco := {}
															aNco := MontNco(QMK->QMK_ESCALA, QMG->QMG_PONTO)

															//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
															//³ Carrega Incertezas Tipo B ³
															//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
															aITB := {}
															aITB := MontITB(QMK->QMK_ESCALA, QMG->QMG_PONTO)

															//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
															//³ Adiciona no aMedicoes ³
															//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
															Aadd(aMedicoes, { QMK->QMK_ESCALA, QMG->QMG_PONTO,;
																QMG->QMG_NOMIN, MontAmed(QMG->QMG_PONTO,,QMG->QMG_TIPCAL),;
																Aclone(aTexto),Aclone( aPs ),Aclone(aIu),Aclone(aNco),Aclone(aITB),;
																"" ,AClone(aExterna), Aclone(aColMed),{} } )

															Aadd(aTitEsc,QMK->QMK_ESCALA)
															Aadd(aPagEsc,QMK->QMK_ESCALA)
															dbSelectArea("QMG")
															dbSkip()
														EndDo
													EndIf
												Endif
											EndIf
										EndIf
									EndIf
								EndIf
							Else
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Cria Array aMedicoes para Alteracao , Visualizacao ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								DbSelectArea("QM7")
								DbSetOrder(1)
								If DbSeek(xFilial("QM7")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql)
									While QM7->QM7_FILIAL + QM7->QM7_INSTR + QM7->QM7_REVINS +;
											DtoS(QM7->QM7_DATA)+QM7->QM7_CSEQ == xFilial("QM7")+cMtInstr+cMtRevIns+;
											DtoS(dMtData)+cSeql .And. !Eof()
										nRecQM7 := QM7->(Recno())
										DbSelectArea("QM9")
										DbSetOrder(1)
										If DbSeek(xFilial("QM9")+QM7->QM7_ESCALA+Inverte(QM7->QM7_REVESC))

											aColMed := {}

											If QM9->QM9_TIPAFE $  "1|2|3|6|9"

												DBSelectArea("QM3")
												DbSetOrder(1)
												If DbSeek(xFilial("QM3")+QM7->QM7_PONTO+"  ") .and. QM3->(!Eof())
													lGrvInv := .T.
												Else
													If (Alltrim(Inverte(QM3->QM3_REVPAD)) <> Alltrim(QM3->QM3_INVRPD)) .and. QM3->(!Eof())
														lGrvInv := .T.
													Endif
												Endif

												If lGrvInv
													RecLock("QM3",.F.)
													QM3->QM3_INVRPD := Inverte(QM3->QM3_REVPAD)
													MsUnLock()
												Endif

												If DbSeek(xFilial("QM3")+QM7->QM7_PONTO+Inverte(QM7->QM7_REVPAD))

													cTipPad := QM3->QM3_TIPPAD

													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ Posiciona no QMC para buscar tolerancia ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													dbSelectArea("QMC")
													dbSetOrder(1)
													dbSeek(xFilial("QMC")+QM7->QM7_ESCALA+;
														Inverte(QM7->QM7_REVESC)+QM7->QM7_PONTO)

													Aadd(aColMed,{QM9->QM9_NROMED,;
														QM9->QM9_TIPAFE,QM3->QM3_TIPPAD,;
														QM9->QM9_ORGAFE,QM9->QM9_INSUTI,QM9->QM9_LAUDO,;
														{If(!empty(QMC->QMC_TOLER),QMC->QMC_TOLER,QM3->QM3_TOLER),;
														If(!empty(QMC->QMC_TOLMIN),QMC->QMC_TOLMIN,QM3->QM3_TOLMIN)},;
															If(QM9->QM9_NROMED>0,"S","N"), CriaVar("QM7_INCERT"), CriaVar("QM7_INCERT"),;   //COLETA
															QM7->QM7_REVESC,QM7->QM7_REVPAD,;
																QM3->QM3_INCERT, QM9->QM9_NCONF,;
																QM9->QM9_VALESP,0,{"",""},"","",QM9->QM9_COLETA,QM3->QM3_TIPTOL,;
																QM3->QM3_UNIMED,QM9->QM9_UNIMED})
														Else
															lFound := .F.
														EndIf

													Elseif QM9->QM9_TIPAFE $ "4|8"
														dbSelectArea("QMG")
														dbSetOrder(1)
														If dbSeek(xFilial("QMG")+cMtInstr+cMtRevIns+QM7->QM7_PONTO)

															cTipPad := QMG->QMG_TIPCAL

															Aadd(aColMed,{QM9->QM9_NROMED,QM9->QM9_TIPAFE,;
																QMG->QMG_TIPCAL,QM9->QM9_ORGAFE,QM9->QM9_INSUTI,;
																QM9->QM9_LAUDO,{0,0}, If(QM9->QM9_NROMED>0,"S","N"),CriaVar("QM7_INCERT"),CriaVar("QM7_INCERT"),;  //COLETA
															QM7->QM7_REVESC,CriaVar("QM7_REVPAD"), "0",QM9->QM9_NCONF,;
																QM9->QM9_VALESP,0,{"",""},QMG->QMG_LIE,QMG->QMG_LSE, QM9->QM9_COLETA,QMG->QMG_TIPTOL,;
																QMG->QMG_UNIMED,QM9->QM9_UNIMED})
														Else
															lFound := .F.
														EndIf
													Elseif QM9->QM9_TIPAFE == "5"
														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
														//³ Carrega Tolerancia no QMA ³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
														DbSelectArea("QMT")
														DbSetOrder(1)
														If DbSeek(xFilial("QMT")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql+QM7->QM7_ESCALA+QM7->QM7_REVESC+QM7->QM7_PONTO)
															Do While !Eof() .and. QMT->QMT_FILIAL+QMT->QMT_INSTR+QMT->QMT_REVINS+DtoS(QMT->QMT_DATA)+QMT->QMT_CSEQ+QMT->QMT_ESCALA+QMT->QMT_REVESC+QMT->QMT_PONTO ==;
																	xFilial("QMT")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql+QM7->QM7_ESCALA+QM7->QM7_REVESC+QM7->QM7_PONTO
																nRecQMT := QMT->(RecNo())
																lFound := .T.
																aAreaQM3 := {}
																If dMtData == QMT->QMT_DATA

																	dbSelectArea("QM3")
																	dbSetOrder(1)
																	aAreaQM3 := GetArea()
																	cKey   := "QM3_FILIAL+QM3_PADRAO+QM3_INVRPD"
																	cQuery := "SELECT QM3.QM3_FILIAL,QM3.QM3_PADRAO,QM3.QM3_REVPAD,QM3.QM3_INVRPD,QM3.QM3_TIPPAD,QM3.QM3_DATREV,QM3.QM3_UNIMED "
																	cQuery += "FROM " + RetSqlName("QM3")+" QM3 "
																	cQuery += "WHERE QM3.QM3_FILIAL = '"+xFilial("QM3")+"' AND "
																	cQuery += "QM3.QM3_PADRAO = '"+ QMT->QMT_PADRAO+"'  AND "
																	cQuery += "QM3.QM3_DATREV <='"+ DtoS(dMtData)  +"'  AND "
																	cQuery += "QM3.D_E_L_E_T_ <> '*' "

																	cQuery += " ORDER BY " + SqlOrder(cKey)

																	cQuery := ChangeQuery(cQuery)

																	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QM3TRB", .F., .T.)

																	While !QM3TRB->(Eof())
																		If  QM3TRB->QM3_DATREV <= DtoS(dMtData)
																			cTipPad := QM3TRB->QM3_TIPPAD
																			cUnin	:= QM3TRB->QM3_UNIMED
																		Endif
																		dbSkip()
																	Enddo

																	QM3TRB->(dbCloseArea())
																	RestArea(aAreaQM3)
																	QMT->(dbGoTo(nRecQMT))
																	If !Empty(cTipPad) //Se nao encontrou escala/padrao na rev. que estou posicionado
																		dbSelectArea("QMA")
																		dbSetOrder(01)
																		If dbSeek(xFilial("QMA")+QM9->QM9_ESCALA+QM9->QM9_REVESC+QMT->QMT_PONTO+QMT->QMT_PADRAO)
																			lFzSom := .T.
																		Else //Caso nao encontre tenta montar...
																			If dbSeek(xFilial("QMA")+QM9->QM9_ESCALA+QM9->QM9_REVESC)
																				lFzSom := .T.
																			Endif
																		Endif
																		If lFzSom
																			If !Empty(cTipPad)
																				Aadd(aColMed,{QM9->QM9_NROMED,QM9->QM9_TIPAFE,;
																					cTipPad,QM9->QM9_ORGAFE,QM9->QM9_INSUTI,QM9->QM9_LAUDO,;
																					{QMA->QMA_TOLER,QMA->QMA_TOLMIN}, If(QM9->QM9_NROMED>0,"S","N"), CriaVar("QM7_INCERT"), CriaVar("QM7_INCERT"),;  //COLETA
																				QM7->QM7_REVESC,CriaVar("QM7_REVPAD"), QMT140IPS(QM7->QM7_PONTO),QM9->QM9_NCONF,;
																					QM9->QM9_VALESP,0,{"",""},"","",QM9->QM9_COLETA,QMA->QMA_TIPTOL,;
																					cUnin,QM9->QM9_UNIMED}) // Incerteza sera calculada
																			Else
																				MessageDlg(STR0085,,3) //"Problemas de integridade - Escala Tipo Soma"
																			Endif
																		Endif
																	Else
																		lFound := .F. // Seta .F. pq naum encontrou escala/padrao
																	Endif
																Endif
																dbSelectArea("QMT")
																dbSkip()
															Enddo
														Else
															lFound := .F.
														EndIf
													Elseif QM9->QM9_TIPAFE == " "

														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
														//³ calibracao externa sem medicao ³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

														cTipPad := "A" // Forca atributo pois somente precisa de Aprovado e Reprovado

														Aadd(aColMed,{QM9->QM9_NROMED,QM9->QM9_TIPAFE,;
															cTipPad,QM9->QM9_ORGAFE,QM9->QM9_INSUTI,QM9->QM9_LAUDO,;
															{"0","0"}, "N", QM7->QM7_ERSIST, QM7->QM7_INCERT,QM7->QM7_REVESC,QM7->QM7_REVPAD,;
															"0",QM9->QM9_NCONF,QM9->QM9_VALESP,0,{"",""},"","", QM9->QM9_COLETA,QM3->QM3_TIPTOL,;
															QM3->QM3_UNIMED,QM9->QM9_UNIMED})

														lFound := .T.

													EndIf

													If lFound
														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
														//³ Verificar med Externa ³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
														aExterna := {}
														Aadd( aExterna, { QM7->QM7_LABOR, QM7->QM7_NRCERT } )

														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
														//³ Carrega padroes secundarios ³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
														aPs := {}
														aPs := MontPSec(QM7->QM7_ESCALA, QM7->QM7_PONTO,dDatAnt,QM7->QM7_CSEQ,QM3->QM3_UNIMED)

														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
														//³ Carrega Instrumento Utilizado ³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
														QM7->(dbGoTo(nRecQM7))

														cSeql := QM7->QM7_CSEQ

														aIu := {}
														aIu := MontPIns(QM7->QM7_ESCALA, QM7->QM7_PONTO,dDatAnt,QM7->QM7_CSEQ,QM3->QM3_UNIMED)

														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
														//³ Carrega Nao conformidades ³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
														aNco := {}
														aNco := MontNco(QM7->QM7_ESCALA, QM7->QM7_PONTO)

														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
														//³ Carrega Incertezas Tipo B ³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
														aITB := {}
														aITB := MontITB(QM7->QM7_ESCALA, QM7->QM7_PONTO)

														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
														//³ Carrega Observacao da Medicao ³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
														aTexto	:= MontTexto(QM7->QM7_ESCALA,QM7->QM7_PONTO,QM7->QM7_REVESC,QM7->QM7_REVPAD)

														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
														//³ Adiciona no aMedicoes ³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
														Aadd(aMedicoes, { QM7->QM7_ESCALA, QM7->QM7_PONTO,;
															QM7->QM7_ESPEC, MontAmed(QM7->QM7_PONTO,QM7->QM7_REVPAD,;
															cTipPad),Aclone(aTexto),;
															Aclone( aPs ),Aclone(aIu),Aclone(aNco),Aclone(aITB),;
															"" ,AClone(aExterna),Aclone(aColMed),{} } )
													EndIf
													lFound := .T.
												EndIf
												dbSelectArea("QM7")
												dbSkip()
											EndDo
										EndIf
									EndIf

									RestArea(aArea)

									If Len(aMedicoes) <= 0
										If !(Alltrim(FunName())) $ "QMTM900|QMTR140|QMTR030"
											MessageDlg(STR0034+Alltrim(TitSx3("QM9_ESCALA")[1])+STR0049,,2)	// STR0034"As(os) Escalas/Padroes nao foram completamente relacionadas(os) com este instrumento, favor verificar para que possam ser digitados os resultados."
											lRet := .F.
										Else
											lRet := .F.
										Endif
									Else
										nPosEsc	:= 01
										nPosPad	:= 02
										nPosEsp	:= 03
										nPosMed	:= 04
										nPosObs	:= 05
										nPosSec	:= 06
										nPosIns	:= 07
										nPosNco	:= 08
										nPosITB	:= 09
										nPosCar	:= 10
										nPosExt	:= 11
										nPosGer	:= 12
										nPosTp5	:= 13
										If  lOrEsPto
											Aeval(aMedicoes,{|x,y|aSort(aMedicoes,,,{|z,w| z[12,1,2]+z[12,1,3]<w[12,1,2]+w[12,1,3]})})
										Endif
									EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140GrvDad³ Autor ³ Fernando Godoy	    ³ Data ³ 9/22/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava dos os dados da medicao. 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array com resultado final.						  ³±±
±±³			 ³ExpC1 - Memo com justificativa de Nao Dig.Medicoes		  ³±±
±±³			 ³ExpC2 - Memo com justificativa de Mudancao de Cond.Inst	  ³±±
±±³			 ³ExpC3 - Memo com justificativa de Mudancao de Laudo 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 - .T. Sucesso ou .F. Fracasso						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140GrvAll() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Iuri Seto    ³28/07/00³ 4403 ³  Acerto do erro que ocorria quando a   ³±±
±±³              ³        ³      ³  observacao da escala era apagada,     ³±±
±±³              ³        ³      ³  havia um check que nao atualizava a   ³±±
±±³              ³        ³      ³  observacao na tabela se estivesse     ³±±
±±³              ³        ³      ³  vazia.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140Grvdad( aResFim,cMemo1,cMemo2,cMemo3,cFreq,dDataVal,oMeter )

	Local lRet		:= .T.
	Local nloop 	:= 0
	Local nloop2	:= 0
	Local aTotPad	:= {}
	Local nTotCol	:= 0
	Local aArea 	:= GetArea()
	Local nIncert	:= 0
	Local nErsist	:= 0
	Local lAdeq 	:= .T.
	Local lAceit	:= .T.
	Local lExat 	:= .T.
	Local lFlag 	:= .F.
	Local cChave	:= ""
	Local cEspec	:= ""
	Local cTexto	:= ""
	Local lCert 	:= .f. // Indica se deve gerar numero interno de certificado
	Local cCert 	:= ""
	Local axTexto	:= {}
	Local cInsEsc	:= ""
	Local nMeter	:= 0
	Local nTotal	:= Len(aMedicoes)
	Local nd		:= 0
	Local cEscs		:= ""
	Local cSeqUlt	:= ""
	Local dDataPr
	Local nPosII	:= 0
	Local lGrvs		:= .F.
	Local cChvQM7	:= ""
	Local aInstQMS	:= {}
	Local cRevDoc	:= ""
	Local cRevTp	:= ""
	Local aUseQI2   := QA_USUARIO()
	Local cPrQual   := ""
	Local lIntQNC   := If(GetMV("MV_QINTQNC")=="S",.T.,.F.).And. !ExistBlock("QMT140IN")
	Local nh		:= 0
	Local cResMat   := Alltrim(SUPERGETMV("MV_QNCMRES", .F., "")) //Define na Integracao com QNC a Matricula do Responsavel da FNC
	Local cOriDep   := Alltrim(SUPERGETMV("MV_QNCDORI", .F., "")) //Define na Integracao com QNC o Departamento de Origem da FNC
		
	Private cMemoNew1 := cMemo1
	Private cMemoNew2 := cMemo2
	Private cMemoNew3 := cMemo3
	Private aQNQI2	  := {}
	Private aAliasQN  := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Descricao do Array aMedicoes que contem todas as informacoes ³
//³ necessarias para se montar o Folder.					     ³
//³																 ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³Col	  Descricao 						 Tipo de Dado		 ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³											³					 ³
//³ 01	³ Escalas							³ String 		  	 ³
//³ 02	³ Padroes							³ String 		  	 ³
//³ 03	³ Especificado 						³ String 		  	 ³
//³ 04	³ Array com medicoes 				³ Array			  	 ³
//³ 05	³ Observacao						³ String 			 ³
//³ 06	³ Array com padrao secundario 		³ Array				 ³
//³ 07	³ Array com instrumento utilizado	³ Array				 ³
//³ 08	³ Array com as nao conformidades 	³ Array				 ³
//³ 09	³ Incerteza tipo B					³ Array				 ³
//³ 10	³ Escala                          	³ String 			 ³
//³ 11	³ Array com Medicoes externas 		³ Array				 ³
//³ 12	³ Array Com informacoes gerais		³ Array				 ³
//³																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³* Array aMedicoes *³
//³					  ³
//³	nPosEsc	:= 01     ³
//³	nPosPad	:= 02  	  ³
//³	nPosEsp	:= 03     ³
//³	nPosMed	:= 04     ³
//³	nPosObs	:= 05     ³
//³	nPosSec	:= 06     ³
//³	nPosIns	:= 07     ³
//³	nPosNco	:= 08     ³
//³	nPosITB	:= 09     ³
//³	nPosCar	:= 10     ³
//³	nPosExt	:= 11     ³
//³	nPosGer	:= 12     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ * Array aTotPad * ³
//³					  ³
//³	1 - Media		  ³
//³	2 - Desv. Medio   ³
//³	3 - Desv. Pad	  ³
//³	4 - Incert		  ³
//³	5 - Inc. total    ³
//³	6 - Erro Max	  ³
//³	7 - Exatid		  ³
//³	8 - Aceitab 	  ³
//³	9 - adequa		  ³
//³  10 - Status	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Proximas linhas adaptadas para retirar tprogress
	oMeter:SetTotal(nTotal)
	oMeter:Set(0)
	oMeter:Refresh()
	SysRefresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe alguma medicao interna. Se sim, gerar nu- ³
//³ mero sequencial do certificado.								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Inclui // Somente se for inclusao
		For nLoop := 1 to len(aMedicoes)
			If aMedicoes[nLoop,nPosGer,1,4] == "I"
				lCert := .t.
			EndIf
		Next nLoop

		If lCert
			If ExistBlock("QMT140Cert")
				cCert := ExecBlock("QMT140Cert",.F.,.F.,{cMtInstr,cMtRevIns,DtoS(dMtData),aMedicoes})
			Else
				cCert := QA_SEQU("QMT_CERT"+Alltrim(Str(Year(dDataBase))),TamSx3("QM7_NRCERT")[1],"S")
			Endif
		EndIf
	EndIf

//Busca nova chave e demais campos de funcoes externas
	cChave	:= xFilial("QM6")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql
	cChave	:= Qa_CvKey(cChave,"QM6",3)
	cInves	:= Inverte(cMtRevIns)
	cDtQM6Inv := Inverte(dMtData)
	cInvSql := Inverte(cSeql)

	Begin Transaction
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Resultados dos pontos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nLoop := 1 To Len(aMedicoes)

			nTotCol	:= Iif(!Empty(aMedicoes[nLoop,nPosMed]),(Len(aMedicoes[nLoop,nPosMed,1]) - 1),0)

			Aadd( aTotPad , A140Calc(nLoop) )
			If valtype(aTotPad[nLoop,nTotCol,5]) = "C"
				If aMedicoes[nLoop,nPosGer,1,4] == "E" .And. aMedicoes[nLoop,nPosGer,1,1] == 0
					If aMedicoes[nLoop,nPosGer,1,6] == "2"
						If !Empty(aTotPad[nLoop,ntotCol,5])
							aTotPad[nLoop,nTotCol,5] := SuperVal(aTotPad[nLoop,ntotCol,5])
						Endif
					Else
						aTotPad[nLoop,nTotCol,5] := SuperVal(aTotPad[nLoop,ntotCol,5])
					Endif
				Else
					aTotPad[nLoop,nTotCol,5] := SuperVal(aTotPad[nLoop,ntotCol,5])
				Endif
			EndIf
			If valtype(aTotPad[nLoop,nTotCol,2]) = "C"
				If aMedicoes[nLoop,nPosGer,1,4] == "E" .And. aMedicoes[nLoop,nPosGer,1,1] == 0
					If aMedicoes[nLoop,nPosGer,1,6] == "2"
						If !Empty(aTotPad[nLoop,ntotCol,2])
							aTotPad[nLoop,nTotCol,2] := SuperVal(aTotPad[nLoop,ntotCol,2])
						Endif
					Else
						aTotPad[nLoop,nTotCol,2] := SuperVal(aTotPad[nLoop,ntotCol,2])
					Endif
				Else
					aTotPad[nLoop,nTotCol,2] := SuperVal(aTotPad[nLoop,nTotCol,2])
				Endif
			EndIf
			If !Empty(aTotPad[nLoop,nTotCol,5])
				nIncert	:= Iif(aTotPad[nLoop,nTotCol,5] > nIncert,aTotPad[nLoop,nTotCol,5],nIncert)
			Else
				nIncert	:= SuperVal(aTotPad[nLoop,nTotCol,5])
			Endif
			If !Empty(aTotPad[nLoop,nTotCol,2])
				nErSist	:= Iif(aTotPad[nLoop,nTotCol,2]	> nErSist,aTotPad[nLoop,nTotCol,2],nErSist)
			Else
				nErSist	:= SuperVal(aTotPad[nLoop,nTotCol,2])
			Endif
			If aMedicoes[nLoop,nPosGer,1,6] == "1"
				lFlag := .T.
				If lAdeq
					lAdeq 	:= Iif(!aTotPad[nLoop,nTotCol,9],.F.,.T.)
				EndIf
				If lAceit
					lAceit	:= Iif(!aTotPad[nLoop,nTotCol,8],.F.,.T.)
				EndIf
				If lExat
					lExat 	:= Iif(!aTotPad[nLoop,nTotCol,7],.F.,.T.)
				EndIf
			EndIf
		Next nLoop

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³									³
//³ Gravacao do cabecalho da rotina ³
//³									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QM2")
		dbSetOrder(1)
		dbSeek(xFilial("QM2")+cMtInstr+cInves)

		dbSelectArea("QM1")
		dbSetOrder(1)
		dbSeek(xFilial("QM1")+QM2->QM2_TIPO)
		cPrQual := QM1->QM1_PROCAL
		nRecQM1 := QM1->(RecNo())

		If !Inclui
			dbSelectArea("QM6")
			dbSetOrder(1)
			If dbSeek(xFilial("QM6") + cMtInstr + cMtRevIns + Dtos(dMtData) + cSeql)
				cRevTp := QM6->QM6_REVTIP
			Endif

			dbSelectArea("QM1")
			dbSetOrder(1)
			dbSeek(xFilial("QM1")+QM2->QM2_TIPO+cRevTp)
			cPrQual := QM1->QM1_PROCAL
			//Volta o registro atual da familia para gravacao correta dos dados...
			QM1->(dbGoTo(nRecQM1))
		Endif

		If !Empty(cPrQual)
			dbSelectArea("QA5")
			dbSetOrder(1)
			If dbSeek(xFilial()+"C"+cPrQual)
				If !Empty(QA5->QA5_DOCTO)
					//Gravar codigo do documento - integracao QDO
					cRevDoc := QA_UltRvDc(QA5->QA5_DOCTO,QM6->QM6_DATA,.F.,.T.)
				Endif
			Endif
		Endif

		dbSelectArea("QM6")
		dbSetOrder(1)
		If dbSeek(xFilial("QM6") + cMtInstr + cMtRevIns + Dtos(dMtData) + cSeql)
			RecLock("QM6",.F.)
		Else
			RecLock("QM6",.T.)
			QM6->QM6_DTPREV := QM2->QM2_VALDAF
		EndIf

		QM6->QM6_FILIAL	:= xFilial("QM6")
		QM6->QM6_INSTR 	:= cMtInstr
		QM6->QM6_REVINS	:= cMtRevINs
		QM6->QM6_REVINV	:= cInves
		QM6->QM6_DATA	:= dMtData
		QM6->QM6_DATINV	:= cDtQM6Inv
		QM6->QM6_RESP	:= cMtResp
		QM6->QM6_TOTHOR	:= cMtTotHr
		QM6->QM6_REPEPR	:= cMtRepRepr
		QM6->QM6_CSEQ	:= cSeql
		QM6->QM6_FILRES	:= cMtFilRes
		QM6->QM6_INVSEQ	:= cInvSql
		QM6->QM6_COTEAM	:= M->QM6_COTEAM

		If Valtype(nIncert) == "C"
			If !Empty(nIncert)
				QM6->QM6_INCERT	:= Alltrim(Str(nIncert))
			Else
				QM6->QM6_INCERT	:= ""
			Endif
		ElseIf Valtype(nIncert) == "N"
			QM6->QM6_INCERT	:= Alltrim(Str(nIncert))
		Endif
		If Valtype(nErSist) == "C"
			If !Empty(nErSist)
				QM6->QM6_ERSIST	:= AllTrim(Str(nErSist))
			Else
				QM6->QM6_ERSIST	:= ""
			Endif
		ElseIf Valtype(nErSist) == "N"
			QM6->QM6_ERSIST	:= AllTrim(Str(nErSist))
		Endif
		If lblkgrv
			QM6->QM6_LAUDO 	:= aResFim[1]
			QM6->QM6_VALDAF	:= dDataVal
			QM6->QM6_COND	:= aResFim[3]
			QM6->QM6_FLGEXP	:= "*"
			QM6->QM6_TIPO	:= QM2->QM2_TIPO
			QM6->QM6_REVTIP	:= Iif(INCLUI,QM1->QM1_REVTIP,QM6->QM6_REVTIP)
			QM6->QM6_ADEQ	:= Iif(lFlag,Iif(lAdeq ,"A","R"),"")
			QM6->QM6_ACEIT 	:= Iif(lFlag,Iif(lAceit,"A","R"),"")
			QM6->QM6_EXAT	:= Iif(lFlag,Iif(lExat ,"A","R"),"")
			QM6->QM6_STATUS := aResFim[4]
		EndIf

		If empty(QM6->QM6_DTPREV)
			QM6->QM6_DTPREV := QM6->QM6_DATA
		EndIf

		If lGerChav
			QM6->QM6_CHAVE	:= cChave
		Else
			cChave := QM6->QM6_CHAVE
		Endif

		If !Empty(cRevDoc)
			QM6->QM6_CODDOC := QA5->QA5_DOCTO
			QM6->QM6_REVDOC := cRevDoc
		Endif
//Grava campos de usuarios diferente de virtual
		For nh := 1 to Len(aCpUs)
			FieldPut(FieldPos(AllTrim(aCpUs[nh])),&("M->"+Alltrim(aCpUs[nh])))
		Next nh

		MsUnLock()
		FKCOMMIT()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a Gravacao de justificativa de cada linha - QA3 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lblkgrv
			cSeqUlt	:= ""
			dbSelectArea("QA3")
			dbSetOrder(1)

			For nLoop := 1 To 3
				axTexto := {}
				cEspec	:= Iif(nLoop == 1,"QMTA140L",Iif(nLoop == 2,"QMTA140M","QMTA140S"))
				cTexto	:= "cMemoNew"+Alltrim(Str(nLoop,1))
				cTexto	:= &cTexto
				If Altera
					If DbSeek(xFilial("QA3")+cEspec+cChave)
						Do While !Eof() .and. QA3->QA3_ESPEC+QA3->QA3_CHAVE == cEspec+cChave
							RecLock("QA3",.F.)
							dbDelete()
							MsUnlock()
							dbSkip()
						Enddo
					Endif
				Endif
				If !Empty(cTexto)
					Aadd(axTexto, { 1,cTexto })
					Qa_GrvTxt(cChave,cEspec,1,axTexto,"QA3",TamSX3("QA3_TEXTO")[1])
				EndIf
			Next nLoop
		EndIf

		For nLoop := 1 To Len(aMedicoes)
			cChvQM7	:= Qa_CvKey(xFilial("QM7")+cMtInstr+cMtRevIns+	Dtos(dMtData)+cSeql+oCbxEsc:aItems[oCbxEsc:nAt]+oCbxPad:aItems[oCbxPad:nAt],"QM7",4)
			If Empty(aMedicoes[nLoop][nPosCar])
				cEscs := aMedicoes[nLoop][nPosEsc]
			Else
				cEscs := aMedicoes[nLoop][nPosCar]
			Endif

			nTotCol	:= Iif(!Empty(aMedicoes[nLoop,nPosMed]),(Len(aMedicoes[nLoop,nPosMed,1]) - 1),0)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³									   ³
			//³ Gravacao dos resultados dos pontos ³
			//³									   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QM7")
			dbSetOrder(1)
			If dbSeek(xFilial("QM7")+QM6->QM6_INSTR+QM6->QM6_REVINS+Dtos(QM6->QM6_DATA)+cSeql+cEscs+aMedicoes[nLoop,nPosGer,1,11]+aMedicoes[nLoop,nPOsPad]+aMedicoes[nLoop,nPosGer,1,12])
				RecLock("QM7",.F.)
			Else
				RecLock("QM7",.T.)
			EndIf
			QM7->QM7_FILIAL	:= xFilial("QM7")
			QM7->QM7_INSTR 	:= QM6->QM6_INSTR
			QM7->QM7_REVINS	:= QM6->QM6_REVINS
			QM7->QM7_DATA	:= QM6->QM6_DATA
			QM7->QM7_ESCALA	:= If(Empty(aMedicoes[nLoop,nPosCar]),cEscs,aMedicoes[nLoop,nPosCar])
			QM7->QM7_REVESC	:= aMedicoes[nLoop,nPosGer,1,11]
			QM7->QM7_PONTO 	:= aMedicoes[nLoop,nPosPad]
			QM7->QM7_REVPAD	:= aMedicoes[nLoop,nPosGer,1,12]
			QM7->QM7_ESPEC 	:= aMedicoes[nLoop,nPosEsp]

			If aMedicoes[nLoop,nPosGer,1,4] == "E" .and.;
					aMedicoes[nLoop,nPosGer,1,1] ==  0 // Se medicao externa, pegar valor digitado
				If ValType(aTotPad[nLoop,nTotCol,5]) == "C"
					If !Empty(aTotPad[nLoop,nTotCol,5])
						QM7->QM7_INCERT	:= AllTrim(StrTran(Str(aTotPad[nLoop,nTotCol,5]),".",","))
					Else
						QM7->QM7_INCERT	:= 	""
					Endif
				ElseIf ValType(aTotPad[nLoop,nTotCol,5]) == "N"
					QM7->QM7_INCERT	:= AllTrim(StrTran(Str(aTotPad[nLoop,nTotCol,5]),".",","))
				Endif
			Else
				QM7->QM7_INCERT	:= Iif(Empty(aMedicoes[nLoop,nPosGer,1,17,1]),AllTrim(StrTran(Str(aTotPad[nLoop,nTotCol,5]),".",",")),;
					StrTran(aMedicoes[nLoop,nPosGer,1,17,1],".",","))
			EndIf
			If ValType(aTotPad[nLoop,nTotCol,2]) == "C"
				If !Empty(aTotPad[nLoop,nTotCol,2])
					QM7->QM7_ERSIST	:= AllTrim(StrTran(Str(aTotPad[nLoop,nTotCol,2]),".",","))
				Else
					QM7->QM7_ERSIST	:=  ""
				Endif
			ElseIf ValType(aTotPad[nLoop,nTotCol,2]) == "N"
				QM7->QM7_ERSIST	:= AllTrim(StrTran(Str(aTotPad[nLoop,nTotCol,2]),".",","))
			Endif

			QM7->QM7_RESULT	:= aTotPad[nLoop,nTotCol,10]
			QM7->QM7_LABOR 	:= Iif(aMedicoes[nLoop,nPosGer,1,4] == "E",aMedicoes[nLoop,nPosExt,1,1],"")

			If aMedicoes[nLoop,nPosGer,1,4] == "E"
				QM7->QM7_NRCERT	:= aMedicoes[nLoop,nPosExt,1,2]
			Else
				If INCLUI
					QM7->QM7_NRCERT	:= cCert
				EndIf
			EndIf

			If lblkgrv

				QM7->QM7_ADEQ		:= Iif(aMedicoes[nLoop,nPosGer,1,6] == "1",Iif(aTotPad[nLoop,nTotCol,9],"A","R"),"")
				QM7->QM7_ACEIT 	:= Iif(aMedicoes[nLoop,nPosGer,1,6] == "1",Iif(aTotPad[nLoop,nTotCol,8],"A","R"),"")
				QM7->QM7_EXAT		:= Iif(aMedicoes[nLoop,nPosGer,1,6] == "1",Iif(aTotPad[nLoop,nTotCol,7],"A","R"),"")
			EndIf

			QM7->QM7_CHAVE 	:= Iif(Empty(QM7->QM7_CHAVE),cChvQM7,QM7->QM7_CHAVE)

			QM7->QM7_CSEQ := cSeql
			cChvQM7	:= QM7->QM7_CHAVE
			MsUnLock()
			FKCOMMIT()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava texto de observacao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			axTexto := {}

			Aadd(axTexto, { 1,aMedicoes[nLoop,nPosObs,1,2] })
			Qa_GrvTxt(cChvQM7,"QMTA140O",1,axTexto,"QA2")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravacao do QM8 - Medicoes ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QM8")
			dbSetOrder(1)
			For nLoop2 := 1 To Len(aMedicoes[nLoop,nPosMed])
				If dbSeek(xFilial("QM8")+QM6->QM6_INSTR+QM6->QM6_REVINS+Dtos(QM6->QM6_DATA)+cSeql+cEscs+aMedicoes[nLoop,nPosGer,1,11]+aMedicoes[nLoop,nPosPad]+aMedicoes[nLoop,nPosGer,1,12]+StrZero(nLoop2,2))
					RecLock("QM8",.F.)
				Else
					RecLock("QM8",.T.)
				EndIf

				QM8->QM8_FILIAL	:= xFilial("QM8")
				QM8->QM8_INSTR 	:= QM6->QM6_INSTR
				QM8->QM8_REVINS	:= QM6->QM6_REVINS
				QM8->QM8_DATA	:= QM6->QM6_DATA
				QM8->QM8_ESCALA	:= QM7->QM7_ESCALA
				QM8->QM8_REVESC	:= QM7->QM7_REVESC
				QM8->QM8_PADRAO	:= QM7->QM7_PONTO
				QM8->QM8_REVPAD	:= QM7->QM7_REVPAD
				QM8->QM8_VLRINI	:= Iif(nTotCol > 1,aMedicoes[nLoop,nPosMed,nLoop2,1],"")
				QM8->QM8_VLRFIM	:= Iif(nTotCol == 1 .And. aMedicoes[nLoop,nPosGer,1,3] <> "A",aMedicoes[nLoop,nPosMed,nLoop2,1],Iif(nTotCol > 1,aMedicoes[nLoop,nPosMed,nLoop2,2],""))
				QM8->QM8_VLRIND	:= Iif(nTotCol > 2,aMedicoes[nLoop,nPosMed,nLoop2,3],"")
				QM8->QM8_VLRFID	:= Iif(nTotCol > 2,aMedicoes[nLoop,nPosMed,nLoop2,4],"")
				QM8->QM8_ATRIB 	:= Iif(aMedicoes[nLoop,nPosGer,1,3] == "A",aMedicoes[nLoop,nPosMed,nLoop2,1],"")
				QM8->QM8_NUMMED	:= StrZero(nLoop2,2)
				QM8->QM8_CSEQ	:= cSeql

				MsUnLock()

			Next nLoop2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravacao dos Instrumentos Utilizados ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QMI")
			dbSetOrder(1)
			nUsado	:= Len(aMedicoes[nLoop,nPosIns,1])
			Aeval(aMedicoes,{|x,y|aSort(aMedicoes[nLoop,nPosIns],,,{|w,z|w[nUsado] > z[nUsado]})})
			aInstQMS := {}
			If !Empty(aMedicoes[nLoop,nPosIns,1,1])
				For nLoop2 := 1 To Len(aMedicoes[nLoop,nPosIns])
					If dbSeek(xFilial("QMI")+QM6->QM6_INSTR+QM6->QM6_REVINS+Dtos(QM6->QM6_DATA)+cSeql+QM7->QM7_ESCALA+QM7->QM7_PONTO+aMedicoes[nLoop,nPosIns,nLoop2,1])
						RecLock("QMI",.F.)
						If aMedicoes[nLoop,nPosIns,nLoop2,nUsado]
							If Alltrim(QMI->QMI_INCERT) == Alltrim(aMedicoes[nLoop,nPosIns,nLoop2,3])
								DbDelete()
							Else
								Aadd(aInstQMS,{QMI->QMI_INSUT,QMI->QMI_ESCPAD,QMI->QMI_INCERT,QMI->QMI_CSEQPR,QMI->QMI_REVQPR,QMI->QMI_DATQPR})
							Endif
							Loop
						EndIf
					Else
						If aMedicoes[nLoop,nPosIns,nLoop2,nUsado]
							Loop
						EndIf
						RecLock("QMI",.T.)
					EndIf

					If Altera
						For nd := 1 To Len(aGrvSeq)

							nPosII := Ascan(aGrvSeq,{|x,y| Alltrim(x[1])+Alltrim(x[5])+Alltrim(x[6])+Alltrim(x[7])=;
								Alltrim(aMedicoes[nLoop,nPosIns,nLoop2,1])+Alltrim(aMedicoes[nLoop,nPosIns,nLoop2,3])+Alltrim(aMedicoes[nLoop][1])+Alltrim(aMedicoes[nLoop][2])})

							If nPosII > 0
								If !aMedicoes[nLoop,nPosIns,nLoop2,nUsado]
									cRevsPr	:= aGrvSeq[nPosII][2]
									cSeqUlt := aGrvSeq[nPosII][3]
									dDataPr	:= aGrvSeq[nPosII][4]
									lGrvs	:= .T.
									Exit
								Endif
							Endif
						Next
					Endif

					If lGrvs
						aDel( aGrvSeq, nPosII )
						aSize( aGrvSeq, Len( aGrvSeq ) -1 )
					Endif

					If !lGrvs
						nRegQM6 := QM6->(RecNo())
						dbSelectArea("QM6")
						dbSetOrder(4)
						If QM6->(!Eof())
							If Inclui
								If dbSeek(xFilial("QM6")+aMedicoes[nLoop,nPosIns,nLoop2,1])
									While QM6->(!Eof()) .and. QM6->QM6_FILIAL+QM6->QM6_INSTR ==;
											xFilial("QM6")+aMedicoes[nLoop,nPosIns,nLoop2,1]
										If QM6->QM6_DATA <= dMtData
											cSeqUlt := QM6->QM6_CSEQ
											dDataPr := QM6->QM6_DATA
											cRevsPr := QM6->QM6_REVINS
											Exit
										Endif
										dbSkip()
									Enddo
								Endif
							Else
								If Len(aInstQMS) > 0
									cSeqUlt := aInstQMS[1][4]
									cRevsPr := aInstQMS[1][5]
									dDataPr := aInstQMS[1][6]
								Endif
							Endif
						Endif
						QM6->(dbGoTo(nRegQM6))
					Endif

					lGrvs	:= .F.

					QMI->QMI_FILIAL	:= xFilial("QMI")
					QMI->QMI_INSTR 	:= QM6->QM6_INSTR
					QMI->QMI_REVINS	:= QM6->QM6_REVINS
					QMI->QMI_DATA	:= QM6->QM6_DATA
					QMI->QMI_ESCALA	:= QM7->QM7_ESCALA
					QMI->QMI_PONTO 	:= QM7->QM7_PONTO
					QMI->QMI_INSUT 	:= aMedicoes[nLoop,nPosIns,nLoop2,1]
					QMI->QMI_ESCPAD	:= aMedicoes[nLoop,nPosIns,nLoop2,2]
					QMI->QMI_INCERT	:= PADL(SUBS(ALLTRIM(aMedicoes[nLoop,nPosIns,nLoop2,3]),1,TamSX3("QMI_INCERT")[1]),TamSX3("QMI_INCERT")[1]," ")
					QMI->QMI_CSEQ 	:= cSeql
					If !Empty(cSeqUlt)
						QMI->QMI_CSEQPR	:= cSeqUlt
						QMI->QMI_DATQPR := dDataPr
						QMI->QMI_REVQPR := cRevsPr
					Endif
					QMI->QMI_REVINV	:= cInves
					MsUnLock()
					dbSelectArea("QMI")
					dbSetOrder(1)
				Next nLoop2
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravacao das Incertezas do Tipo B	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QMX")
			dbSetOrder(1)
			nUsado	:= Len(aMedicoes[nLoop,nPosITB,1])
			If !Empty(aMedicoes[nLoop,nPosITB,1,1])
				For nLoop2 := 1 To Len(aMedicoes[nLoop,nPosITB])
					If dbSeek(xFilial("QMX")+QM6->QM6_INSTR+QM6->QM6_REVINS+Dtos(QM6->QM6_DATA)+QM7->QM7_CSEQ+QM7->QM7_ESCALA+QM7->QM7_PONTO+aMedicoes[nLoop,nPosITB,nLoop2,1]+cSeql)
						RecLock("QMX",.F.)
						If aMedicoes[nLoop,nPosITB,nLoop2,nUsado]
							DbDelete()
							Loop
						EndIf
					Else
						If aMedicoes[nLoop,nPosITB,nLoop2,nUsado]
							Loop
						EndIf
						RecLock("QMX",.T.)
					EndIf
					QMX->QMX_FILIAL	:= xFilial("QMX")
					QMX->QMX_INSTR 	:= QM6->QM6_INSTR
					QMX->QMX_REVINS	:= QM6->QM6_REVINS
					QMX->QMX_DATA	:= QM6->QM6_DATA
					QMX->QMX_ESCALA	:= QM7->QM7_ESCALA
					QMX->QMX_PONTO 	:= QM7->QM7_PONTO
					QMX->QMX_CODINC	:= aMedicoes[nLoop,nPosITB,nLoop2,1]
					QMX->QMX_VALINC	:= aMedicoes[nLoop,nPosITB,nLoop2,4]
					QMX->QMX_DIV	:= aMedicoes[nLoop,nPosITB,nLoop2,6]
					QMX->QMX_CSENS 	:= aMedicoes[nLoop,nPosITB,nLoop2,7]
					QMX->QMX_UI 	:= Alltrim(aMedicoes[nLoop,nPosITB,nLoop2,8])
					QMX->QMX_VI 	:= aMedicoes[nLoop,nPosITB,nLoop2,9]
					QMX->QMX_CSEQ	:= cSeql

					MsUnLock()
				Next nLoop2
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravacao das Nao Conformidades ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			nUsado	:= Len(aMedicoes[nLoop,nPosNco,1])
			If !Empty(aMedicoes[nLoop,nPosNco,1,1])
				aArrayQMJ 	:= {}
				For nLoop2 := 1 To Len(aMedicoes[nLoop,nPosNco])
					aCpoQNC		:= {}
					lFazQI2		:= .F.
					dbSelectArea("SAG")
					dbSetOrder(01)
					dbSeek(xFilial("SAG")+aMedicoes[nLoop,nPosNCo,nLoop2,1])

					dbSelectArea("QMJ")
					dbSetOrder(1)
					If dbSeek(xFilial("QMJ")+QM6->QM6_INSTR+QM6->QM6_REVINS+Dtos(QM6->QM6_DATA)+cSeql+QM7->QM7_ESCALA+QM7->QM7_PONTO+aMedicoes[nLoop,nPosNco,nLoop2,1])
						aArrayQMJ := {}
						Aadd(aArrayQMJ,{QMJ->QMJ_NAOCON})
						Aadd(aArrayQMJ,{QMJ->QMJ_CLASS})
						RecLock("QMJ",.F.)
						If aMedicoes[nLoop,nPosNCo,nLoop2,nUsado]
							DbDelete()
							If lIntQNC
								aCpoQNC := {xFilial("QI2"),QMJ->QMJ_CODNC,QMJ->QMJ_REVNC}
								QncGera(2,aCpoQNC)
							Endif
							Loop
						EndIf
					Else
						If aMedicoes[nLoop,nPosNco,nLoop2,nUsado]
							Loop
						EndIf
						RecLock("QMJ",.T.)
					EndIf
					QMJ->QMJ_FILIAL	:= xFilial("QMJ")
					QMJ->QMJ_INSTR 	:= QM6->QM6_INSTR
					QMJ->QMJ_REVINS	:= QM6->QM6_REVINS
					QMJ->QMJ_DATA	:= QM6->QM6_DATA
					QMJ->QMJ_ESCALA	:= QM7->QM7_ESCALA
					QMJ->QMJ_PONTO 	:= QM7->QM7_PONTO
					QMJ->QMJ_NAOCON	:= aMedicoes[nLoop,nPosNco,nLoop2,1]
					QMJ->QMJ_CLASS 	:= aMedicoes[nLoop,nPosNco,nLoop2,3]
					QMJ->QMJ_FLGEXP	:= "*"
					QMJ->QMJ_CSEQ	:= cSeql

					If Inclui
						lFazQI2 := .T.
					Elseif Altera
						If Len(aArrayQMJ) <> 0	//Ja existe no QMJ. Verifico se alterou NC ou Classe.
							If	aMedicoes[nLoop,nPosNco,nLoop2,1] != aArrayQMJ[1][1] .or.;
									aMedicoes[nLoop,nPosNco,nLoop2,3] != aArrayQMJ[2][1]
								lFazQI2 := .T.
							Endif
						Else
							lFazQI2 := .T.	//Alteracao na rotina nao existe no QMJ.
						Endif
					Endif

					If lIntQNC .And. lFazQI2
						Aadd(aCpoQNC,{"QI2_ORIGEM"	,"QMT"})
						Aadd(aCpoQNC,{"QI2_DESCR"	,STR0042+aMedicoes[nLoop,nPosNco,nLoop2,1]})
						Aadd(aCpoQNC,{"QI2_TPFIC"	,"2"})
						Aadd(aCpoQNC,{"QI2_INSTR"	,QMJ->QMJ_INSTR})
						Aadd(aCpoQNC,{"QI2_REVINS"	,QMJ->QMJ_REVINS})
						Aadd(aCpoQNC,{"QI2_MEMO1"	,SAG->AG_DESCPO})
						Aadd(aCpoQNC,{"QI2_FILMAT"	,cMtFilRes}) //xFilial("QAA")
						Aadd(aCpoQNC,{"QI2_MAT"		,cMtResp})
						Aadd(aCpoQNC,{"QI2_FILRES"	,cMtFilRes}) //xFilial("QAA")
						Aadd(aCpoQNC,{"QI2_MATRES"	,IIF(EMPTY(cResMat), cMtRespQM2, cResMat)})
						Aadd(aCpoQNC,{"QI2_FILORI"	,cMtFilRes}) //xFilial("QAA")
						Aadd(aCpoQNC,{"QI2_ORIDEP"	,IIF(EMPTY(cOriDep),aUseQI2[4], cOriDep)})


						aRetQNC := QncGera(1,aCpoQNC)

						QMJ->QMJ_CODNC	:= aRetQNC[2]
						QMJ->QMJ_REVNC	:= aRetQNC[3]
					Endif
					MsUnLock()

				Next nLoop2
			EndIf
			aInstQMS := {}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravacao dos Padroes Secundarios ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QMS")
			dbSetOrder(1)
			nUsado	:= Len(aMedicoes[nLoop,nPosSec,1])
			Aeval(aMedicoes,{|x,y|aSort(aMedicoes[nLoop,nPosSec],,,{|w,z|w[nUsado] > z[nUsado]})})
			If !Empty(aMedicoes[nLoop,nPosSec,1,1])
				For nLoop2 := 1 To Len(aMedicoes[nLoop,nPosSec])
					If dbSeek(xFilial("QMS")+QM6->QM6_INSTR+QM6->QM6_REVINS+Dtos(QM6->QM6_DATA)+QM7->QM7_ESCALA+QM7->QM7_PONTO+aMedicoes[nLoop,nPosSec,nLoop2,1]+aMedicoes[nLoop,nPosSec,nLoop2,2]+cSeql)
						RecLock("QMS",.F.)
						If aMedicoes[nLoop,nPosSec,nLoop2,nUsado]
							If Alltrim(QMS->QMS_INCERT) == Alltrim(aMedicoes[nLoop,nPosSec,nLoop2,3])
								DbDelete()
							Else
								Aadd(aInstQMS,{QMS->QMS_PADSEC,QMS->QMS_ESCPAD,QMS->QMS_INCERT,QMS->QMS_CSEQPR,QMS->QMS_REVQPR,QMS->QMS_DATQPR})
							Endif
							Loop
						EndIf
					Else
						If aMedicoes[nLoop,nPosSec,nLoop2,nUsado]
							Loop
						EndIf
						RecLock("QMS",.T.)
					EndIf

					If Altera
						For nd := 1 To Len(aGrvSeq)

							nPosII := Ascan(aGrvSeq,{|x,y| Alltrim(x[1])+Alltrim(x[5])+Alltrim(x[6])+Alltrim(x[7])=;
								Alltrim(aMedicoes[nLoop,nPosSec,nLoop2,1])+Alltrim(aMedicoes[nLoop,nPosSec,nLoop2,3])+Alltrim(aMedicoes[nLoop][1])+Alltrim(aMedicoes[nLoop][2])})

							If nPosII > 0
								If !aMedicoes[nLoop,nPosSec,nLoop2,nUsado]
									cRevsPr	:= aGrvSeq[nPosII][2]
									cSeqUlt := aGrvSeq[nPosII][3]
									dDataPr	:= aGrvSeq[nPosII][4]
									lGrvs	:= .T.
									Exit
								Endif
							Endif
						Next
					Endif
					If !lGrvs
						nRegQM6 := QM6->(RecNo())
						dbSelectArea("QM6")
						dbSetOrder(4)
						If QM6->(!Eof())
							If Inclui
								If dbSeek(xFilial("QM6")+aMedicoes[nLoop,nPosSec,nLoop2,1])
									While QM6->(!Eof()) .and. QM6->QM6_FILIAL+QM6->QM6_INSTR ==;
											xFilial("QM6")+aMedicoes[nLoop,nPosSec,nLoop2,1]
										If QM6->QM6_DATA <= dMtData
											cSeqUlt := QM6->QM6_CSEQ
											dDataPr := QM6->QM6_DATA
											cRevsPr := QM6->QM6_REVINS
											Exit
										Endif
										dbSkip()
									Enddo
								Endif
							Else
								If Len(aInstQMS) > 0
									cSeqUlt := aInstQMS[1][4]
									cRevsPr := aInstQMS[1][5]
									dDataPr := aInstQMS[1][6]
								Endif
							Endif
						Endif
						QM6->(dbGoTo(nRegQM6))
					Else
						aDel( aGrvSeq, nPosII )
						aSize( aGrvSeq, Len( aGrvSeq ) -1 )
					Endif
					lGrvs	:= .F.
					QMS->QMS_FILIAL	:= xFilial("QMS")
					QMS->QMS_INSTR 	:= QM6->QM6_INSTR
					QMS->QMS_REVINS	:= QM6->QM6_REVINS
					QMS->QMS_DATA	:= QM6->QM6_DATA
					QMS->QMS_ESCALA	:= QM7->QM7_ESCALA
					QMS->QMS_PONTO 	:= QM7->QM7_PONTO
					QMS->QMS_PADSEC	:= aMedicoes[nLoop,nPosSec,nLoop2,1]
					QMS->QMS_ESCPAD	:= aMedicoes[nLoop,nPosSec,nLoop2,2]
					QMS->QMS_INCERT	:= alltrim(aMedicoes[nLoop,nPosSec,nLoop2,3])
					QMS->QMS_CSEQ 	:= cSeql
					If !Empty(cSeqUlt)
						QMS->QMS_CSEQPR	:= cSeqUlt
						QMS->QMS_DATQPR := dDataPr
						QMS->QMS_REVQPR := cRevsPr
					Endif
					QMS->QMS_REVINV	:= cInves
					MsUnLock()
					dbSelectArea("QMS")
					dbSetOrder(1)
				Next nLoop2
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravacao dos Padroes do Tipo Soma ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QMT")
			dbSetOrder(1)
			If !Empty(aMedicoes[nLoop,nPosTp5])
				For nLoop2 := 1 To Len(aMedicoes[nLoop,nPosTp5])
					If dbSeek(xFilial("QMT")+QM6->QM6_INSTR+QM6->QM6_REVINS+Dtos(QM6->QM6_DATA)+QM6->QM6_CSEQ+QM7->QM7_ESCALA+QM7->QM7_REVESC+QM7->QM7_PONTO)
						Do While xFilial("QMT")+QM6->QM6_INSTR+QM6->QM6_REVINS+Dtos(QM6->QM6_DATA)+QM6->QM6_CSEQ+QM7->QM7_ESCALA+QM7->QM7_REVESC+QM7->QM7_PONTO ==;
								xFilial("QMT")+QMT->QMT_INSTR+QMT->QMT_REVINS+DTOS(QMT->QMT_DATA)+QMT->QMT_CSEQ+QMT->QMT_ESCALA+QMT->QMT_REVESC+QMT->QMT_PONTO
							RecLock("QMT",.F.)
							DbDelete()
							MsUnlock()
							DbSkip()
						EndDo
					EndIf
				Next
				For nLoop2 := 1 To Len(aMedicoes[nLoop,nPosTp5])
					RecLock("QMT",.T.)
					QMT->QMT_FILIAL	:= xFilial("QMT")
					QMT->QMT_INSTR 	:= QM6->QM6_INSTR
					QMT->QMT_REVINS	:= QM6->QM6_REVINS
					QMT->QMT_DATA	:= QM6->QM6_DATA
					QMT->QMT_ESCALA	:= QM7->QM7_ESCALA
					QMT->QMT_REVESC	:= QM7->QM7_REVESC
					QMT->QMT_PONTO 	:= QM7->QM7_PONTO
					QMT->QMT_PADRAO	:= aMedicoes[nLoop,nPosTp5,nLoop2,1]
					QMT->QMT_REVPAD	:= aMedicoes[nLoop,nPosTp5,nLoop2,2]
					QMT->QMT_CSEQ	:= cSeql
					MsUnLock()
				Next nLoop2
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetua a Gravacao do novo periodo e validade da afericao	 ³
			//³ para instrumentos que pertencem a uma Malha                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cInsEsc := A140InsEsc(QM6->QM6_INSTR,cEscs)
			If !EMPTY(cInsEsc)
				dbSelectArea("QM2")
				dbSetOrder(1)
				If DbSeek(xFilial("QM2")+cInsEsc)
					RecLock("QM2",.F.)
					If Inclui
						If cFreqSch == "S"
							If Empty(QM2->QM2_FREQAN)
								QM2->QM2_FREQAN := Val(cFreq)
								QM2->QM2_VALDAN := dDataVal
							Else
								QM2->QM2_FREQAN := QM2->QM2_FREQAF
								QM2->QM2_VALDAN := QM2->QM2_VALDAF
							EndIf
							QM2->QM2_FREQAF := Val(cFreq)
							QM2->QM2_VALDAF := dDataVal
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Como n„o h  controle da varia‡„o da frequˆncia ³
							//³ gravar a situa‡„o anterior  n„o precisa		   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							QM2->QM2_VALDAF := dDataVal
						EndIf
					Elseif Altera
						If cFreqSch == "S"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Se anterior estiver vazio e comecou ³
							//³	 a fazer controle, grava.			³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If Empty(QM2->QM2_FREQAN)
								QM2->QM2_FREQAN := Val(cFreq)
								QM2->QM2_VALDAN := dDataVal
							Else
								QM2->QM2_FREQAN := QM2->QM2_FREQAN
								QM2->QM2_VALDAN := QM2->QM2_VALDAN
							EndIf
							QM2->QM2_FREQAF := Val(cFreq)
							QM2->QM2_VALDAF := dDataVal
						EndIf
					EndIf
					QM2->QM2_LAUDO  := Iif(aResFim[1] == "A","3",Iif(aResFim[1] == "C","2","1"))
				EndIf
			EndIf

			nMeter++
			oMeter:Set(nMeter)
			SysRefresh()
		Next nLoop

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a Gravacao do novo periodo e validade da afericao	 ³
//³ Exemplo de procedimento para controle da mudanca de periodo  ³
//³	  Acao		  Periodo Anterior				Periodo Atual	 ³
//³	(Novo)				(Vazio)							 (Vazio) ³
//³	Inclusao 			  90 (anterior=atual)			 90		 ³
//³	Inclusao 			  90 (passa atu p/ ant) 		 95		 ³
//³	Alteracao			  90 (mantem ant. altera atu)  92		 ³
//³	Inclusao 			  92 (passa atu p/ ant) 		 ...	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lblkgrv
			dbSelectArea("QM2")
			dbSetOrder(1)
			If DbSeek(xFilial("QM2")+QM6->QM6_INSTR+Inverte(QM6->QM6_REVINS))
				RecLock("QM2",.F.)
				If Inclui
					If cFreqSch == "S"
						If Empty(QM2->QM2_FREQAN)
							QM2->QM2_FREQAN := Val(cFreq)
							QM2->QM2_VALDAN := dDataVal
						Else
							QM2->QM2_FREQAN := QM2->QM2_FREQAF
							QM2->QM2_VALDAN := QM2->QM2_VALDAF
						EndIf
						QM2->QM2_FREQAF := Val(cFreq)
						QM2->QM2_VALDAF := dDataVal
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Como n„o h  controle da varia‡„o da frequˆncia ³
						//³ gravar a situa‡„o anterior  n„o precisa		   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						QM2->QM2_VALDAF := dDataVal
						//Quando o tratamento de frequencia eh feita de maneira
						//diferente a Schumacker. - Ponto de Entrada QMT140FrAf
						If ExistBlock("QMT140FrAf")
							QM2->QM2_FREQAF := Val(cFreq)
							If Empty(QM2->QM2_FREQAN)
								QM2->QM2_FREQAN := Val(cFreq)
								QM2->QM2_VALDAN := dDataVal
							Else
								QM2->QM2_FREQAN := QM2->QM2_FREQAF
								QM2->QM2_VALDAN := QM2->QM2_VALDAF
							EndIf
						Endif
					EndIf
				Elseif Altera
					If cFreqSch == "S"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se anterior estiver vazio e comecou ³
						//³	 a fazer controle, grava.			³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty(QM2->QM2_FREQAN)
							QM2->QM2_FREQAN := Val(cFreq)
							QM2->QM2_VALDAN := dDataVal
						Else
							QM2->QM2_FREQAN := QM2->QM2_FREQAN
							QM2->QM2_VALDAN := QM2->QM2_VALDAN
						EndIf
						QM2->QM2_FREQAF := Val(cFreq)
						QM2->QM2_VALDAF := dDataVal
					Else
						If ExistBlock("QMT140FrAf")
							QM2->QM2_FREQAF := Val(cFreq)
							If Empty(QM2->QM2_FREQAN)
								QM2->QM2_FREQAN := Val(cFreq)
								QM2->QM2_VALDAN := dDataVal
							Else
								QM2->QM2_FREQAN := QM2->QM2_FREQAF
								QM2->QM2_VALDAN := QM2->QM2_VALDAF
							EndIf
						Endif
					EndIf
				EndIf
				QM2->QM2_STATUS := aResFim[4]
				QM2->QM2_LAUDO  := Iif(aResFim[1] == "A","3",Iif(aResFim[1] == "C","2","1"))
			EndIf
		EndIf

	End Transaction

	RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CalcFreq	³ Autor ³ Fernando Godoy		³ Data ³ 9/25/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula a Frequencia e Data de Validade 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 -> Texto para a tela								  ³±±
±±³			 ³ExpC1 -> Frequencia										  ³±±
±±³			 ³ExpD1 -> Data de Validade									  ³±±
±±³			 ³Obs: Todos passados por Referencia						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140GrvAll() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CalcFreq( cTextFr, cFreq,dDataVal )
	QM2->(dbSetOrder(1))
	QM2->(dbSeek(xFilial("QM2")+cMtInstr+Inverte(cMtRevIns)))
	If !ExistBlock("QMT140FrAf")
		cFreq 	:= Str(QM2->QM2_FREQAF,0)
		dDataVal := dMtData + QM2->QM2_FREQAF
	Endif

	cTextFr := OemToAnsi(STR0024)+cFreq+OemToAnsi(STR0025)+Dtoc(dDataVal)//"Frequência: " / " Dias  Val.Calibração: "

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140ChgFrq³ Autor ³ Fernando Godoy		³ Data ³ 9/25/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra na tela Freq e Data de Val Conf. resposta no RadioBut³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array com as novas e velhas freq. e Datas			  ³±±
±±³			 ³ExpC1 - Variavel que contera a freq. e Data.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140GrvAll() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ChgFrq(aStatus,cTextFr,nOption,oSay3,cFreq,dDataVal,cSemana,oSay17)

	If nOption == 1
		cTextFr	:= aStatus[3]
		dDataVal := aStatus[5]
		cFreq 	:= Str(aStatus[6])
		cSemana 	:= RetSem(dDataVal)
	Else
		cTextFr	:= aStatus[4]
		dDataVal := aStatus[7]
		cFreq 	:= Str(aStatus[8])
		cSemana	:= RetSem(dDataVal)
	EndIf

	oSay3:Refresh()
	oSay17:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140ChkSch³ Autor ³ Fernando Godoy		³ Data ³ 9/30/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se a tabela de Schumacker existe					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 - .T. = Eiste .F. = Nao existe 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140Mae													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ChkSch( )
	Local lRet	:= .T.

	If cFreqSch == "S"
		DbSelectArea("QMF")
		DbSetOrder(1)
		dbGoTop()
		nFreqMin := Val(QMF_RED_MX)
		dbGoBottom()
		nFreqMax := Val(QMF_EXTEND)

		If nFreqMin == 0 .or. nFreqMax == 0
			MessageDlg(STR0035,,1)	//"Problemas na tabela de Schumacher (QMF). Provavelmente a tabela foi perdida. Consulte Suporte Microsiga informando esta mensagem. As medições não poderão ser gravadas."
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³RetTextAtu³ Autor ³ Fernando Godoy		³ Data ³ 9/30/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna os texto gravado no QA3 para a finalizacao		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Numero do Get para referencia na dbSeek onde:		  ³±±
±±³			 ³ 		 1 -> Justificativa pela nao dig.das medicoes		  ³±±
±±³			 ³ 		 2 -> Justificativa pela mudanca de Status			  ³±±
±±³			 ³ 		 3 -> Justificativa pela mudanca de Laudo 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpC1 - Textos Gravado no QA3								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140GrvAll() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetTextAtu( nTexto )
	Local cTextRet := ""
	Local aArea 	:= GetArea()
	Local cChave	:= ""
	Local cEspec	:= ""
	Local axTextos  := {}
	Default nTexto := 1

	dbSelectArea("QA3")
	dbSetOrder(1)

	cChave := QM6->QM6_CHAVE

	cEspec := Iif(nTexto == 1,"QMTA140L",Iif(nTexto == 2,"QMTA140M","QMTA140S"))
	cTextRet := QA_Rectxt(cChave,cEspec,1,TamSX3("QA3_TEXTO")[1],"QA3",axTextos)

	If !Empty(cTextRet)
		lGerChav	:= .F.
	EndIf

	RestArea(aArea)

Return cTextRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140VerMed³ Autor ³ Fernando Godoy		³ Data ³ 9/18/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se foram digitadas todas as medicoes				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 -> .T. Digitou - .F. Nao Digitou					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140GrvAll												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140VerMed()
	Local lRet		:= .T.
	Local nCntFor	:= 0
	Local nLoop 	:= 0
	Local nLoop2	:= 0

	For nCntFor := 1 To len(aMedicoes)
		If !Empty(aMedicoes[nCntFor, nPosMed]) // Coleta medicoes
			For nLoop := 1 To len(aMedicoes[nCntFor, nPosMed,1]) - 1 // -1 porque a ultima coluna é .T. ou .f. para o aCols
				If aMedicoes[nCntFor,nPosGer,1,3] <> "A"
					For nLoop2 := 1 To Len(aMedicoes[nCntFor,nPosMed])
						If Empty(aMedicoes[nCntFor,nPosMed,nLoop2,nLoop]) .and.;
								aMedicoes[nCntFor,nPosGer,1,20] == "S" //Deve coletar todas as medicoes
							lRet	:= .F.
							Exit
						EndIf
					Next nLoop2
				EndIf
			Next nLoop
		EndIf
	Next nCntFor

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³RetString ³ Autor ³ Fernando Godoy		³ Data ³ 9/21/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna string sem o caracter & . 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - String Contendo &.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpC2 - String livre de &									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Generico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetString( cString )
	Local nLoop := 0
	Local cNewString	:= ""
	Default cString := ""

	For nLoop := 1 To Len(cString)
		If Alltrim(Substr(cString,nLoop,1)) <> "&"
			cNewString := cNewString + Substr(cString,nLoop,1)
		EndIf
	Next nLoop

Return cNewString

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³RetStatus ³ Autor ³ Fernando Godoy		³ Data ³ 9/21/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Pesquisa no cadastro de status e retorna conf. parametro	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - T -> indica para retornar array om todos os Status  ³±±
±±³			 ³ 		 A -> Retornar String apenas com o Status atual 	  ³±±
±±³			 ³ 		 I -> Retornar String apenas com o Status Inativo	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpU1 - ARRAY Com todos os Status ou STRING com atual		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140GrvAll() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetStatus( cTipo )
	Local uRetorno := {}
	Local aArea 	:= GetArea()
	Local cStatAtu := ""

	dbSelectArea("QM2")
	dbSetOrder(1)
	dbSeek(xFilial("QM2")+cMtInstr+Inverte(cMtRevIns) )
	cStatAtu := QM2->QM2_STATUS

	If cTipo == "T"
		dbSelectArea("QMP")
		dbSetOrder(1)
		dbGotop()
		While !Eof()
			Aadd( uRetorno , QMP->QMP_STATUS + " - " + QMP->QMP_DESCR )
			dbSkip()
		EndDo
	Elseif cTipo == "A"
		dbSelectArea("QMP")
		dbSetOrder(1)
		If dbSeek(xFilial("QMP")+cStatAtu )
			uRetorno := QMP->QMP_STATUS + " - " + QMP->QMP_DESCR
		Else
			dbSeek(xFilial("QMP")+"A") // Procura status Ativo que nunca pode ser excluido
			uRetorno := QMP->QMP_STATUS + " - " + QMP->QMP_DESCR
		EndIf
	Elseif cTipo == "I"
		dbSelectArea("QMP")
		dbSetOrder(1)
		If dbSeek(xFilial("QMP")+"I") // Procura status Inativo que nunca pode ser excluido
			uRetorno := QMP->QMP_STATUS + " - " + QMP->QMP_DESCR
		Else
			RecLock("QMP",.T.)
			QMP->QMP_FILIAL := xFilial("QMP")
			QMP->QMP_STATUS := "I"
			QMP->QMP_DESCR  := "Inativo"
			QMP->QMP_ATUAL  := "S"
			MsUnLock()
			uRetorno := QMP->QMP_STATUS + " - " + QMP->QMP_DESCR
		EndIf
	EndIf

	RestArea( aArea )

Return uRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140TelAtv³ Autor ³ Fernando Godoy		³ Data ³ 9/22/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Indica que a tela esta ativa								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Numero de pagina da tela							  ³±±
±±³			 ³ExpA1 - Handles dos objetos da Dlg						  ³±±
±±³			 ³ExpN2 - Posicao sugerida pelo sistema para Laudo 			  ³±±
±±³			 ³ExpC1 - Posicao sugerida pelo sistema para Status de Instr  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA2 - Array com as talas ativas							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140GrvAll() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140TelAtv( nNumPag,aHandle,nRad2Atu,cStatAtu )
	Local aAtivos	:= {}
	Local nLoop 	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for Visualiza‡Æo, so exibe a ultima pagina     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(Altera .or. Inclui)

		For nLoop := 1 to nNumPag
			Aadd( aAtivos, .F. )
		Next nLoop
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa array com .T. dependendo do num de paginas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nLoop := 1 To nNumPag
			Aadd( aAtivos, .T. )
		Next nLoop

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a primeira pagina esta ativa ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If A140VerMed()	// Verifica se digitou todas as medicoes
			aAtivos[1] := .F.
		EndIf

		If Alltrim(cFreqSch) <> "S"
			aAtivos[2] := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a pagina de justificativa de status esta ativa ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nRad2Atu == aHandle[6]:nOption
			aAtivos[5]	:= .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a pagina de justificativa de laudo esta ativa ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Alltrim(cStatAtu) == Alltrim(aHandle[8]:GetSelText())
			aAtivos[7]	:= .F.
		EndIf

	EndIf

Return aAtivos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140DelNil³ Autor ³ Fernando Godoy		³ Data ³ 9/23/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Deleta linhas em branco no Acols desde que nao seja a primer³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³GetDados													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                    		
Function A140DelNil( oObj )

	If Empty(aCols[Len(aCols),1]) .And. Len(aCols) > 1
		Adel( aCols, Len(aCols) )
		ASize( aCols, Len( aCols) - 1)
		n := Len( aCols )
		oObj:oBrowse:Refresh()
	EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140ChkExt³ Autor ³ Fernando Godoy		³ Data ³ 9/24/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Checa se existe medicao externa e verifica se usuario digi- ³±±
±±³			 ³tou o laboratorio e o numero do certificado.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 - .T. Digitou e .F. nao digitou						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140GrvAll() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ChkExt()
	Local lRet	:= .T.
	Local nLoop := 0

	For nLoop := 1 To Len(aMedicoes)
		If aMedicoes[nLoop,nPosGer,1,4] == "E"
			If Empty(aMedicoes[nLoop,nPosExt,1,1]) .Or. Empty(aMedicoes[nLoop,nPosExt,1,2])
				IF Posicione("QMR",1,xFilial("QMR")+cMtInstr+cMtRevIns+aMedicoes[nLoop,1], 'QMR_CAOBRI') == "S"
					lRet := .F.
					Exit
				ENDIF
			EndIf
		EndIf
	Next nLoop

	If !lRet
		MessageDlg(STR0036,,1)	//"Este instrumento tem medicoes externas mas o usuario não digitou informações sobre Laboratório e Número de certificado. Estes dados são obrigatórios. Por Favor verifique na pasta de medições Externas quando a existência de falta de dados."
		If Alltrim(aMedicoes[nPosAmed,12,1,4]) == "E"
			nPosAmed := Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})
			aObjetos[OBJ_MEDEXT][1]:Show()
			aObjetos[OBJ_MEDEXT][2]:Show()
			aObjetos[OBJ_MEDEXT][3]:Show()
			aObjetos[OBJ_MEDEXT][4]:Show()
			aObjetos[OBJ_MEDEXT][5]:cText := aMedicoes[nPosAmed,nPosExt,1,1]
			aObjetos[OBJ_MEDEXT][5]:SetText(aObjetos[OBJ_MEDEXT][5]:cText)
			aObjetos[OBJ_MEDEXT][5]:Show()				
			aObjetos[OBJ_MEDEXT][6]:Enable()
			aObjetos[OBJ_MEDEXT][6]:cText := aMedicoes[nPosAmed,nPosExt,1,2] 
			aObjetos[OBJ_MEDEXT][6]:SetText(aObjetos[OBJ_MEDEXT][6]:cText)	
			aObjetos[OBJ_MEDEXT][6]:Show()		
			aObjetos[OBJ_MEDEXT][6]:SetFocus()	
			aObjetos[OBJ_MEDEXT][7]:Hide()
		Else
			aObjetos[OBJ_MEDEXT][7]:Show()
			aObjetos[OBJ_MEDEXT][1]:Hide()
			aObjetos[OBJ_MEDEXT][2]:Hide()
			aObjetos[OBJ_MEDEXT][3]:Hide()
			aObjetos[OBJ_MEDEXT][4]:Hide()
			aObjetos[OBJ_MEDEXT][5]:Hide()
			aObjetos[OBJ_MEDEXT][6]:Hide()
		Endif
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140DatAnt³ Autora³ Iuri Seto             ³ Data ³ 17/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica a data da última calibração  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Código do Instrumento          					  ³±±
±±³          ³ExpC2 : Revisao do Instrumento          					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpD1 : Data da última calibração 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTA140 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140DatAnt(cMtInstr,cRevIns)
	Local cOldAlias := Select()
	Local nRec		:= Recno()
	Local dDatAnt	:= CTOD("  /  /  ","DDMMYY")

	dbSelectArea("QM6")
	dbSetOrder(2)
	If QM6->(dbSeek(xFilial("QM6")+cMtInstr+cRevIns))
		dDatAnt := QM6->QM6_DATA
	EndIf

	dbSelectArea(cOldAlias)
	dbGoto(nRec)

Return(dDatAnt)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140InsEsc³ Autora³ Iuri Seto             ³ Data ³ 15/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o Código do Instrumento que se refere a Malha      ³±±
±±³          ³ enviada como parâmetro.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Codigo do Instrumento Malha     					  ³±±
±±³          ³ ExpC2 : Escala do Instrumento Malha     					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpC1 : Código do Instrumento Filho                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QMTA140													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140InsEsc(cInstr,cEscala)
	Local cOldAlias := Select()
	LocaL nReg := Recno()
	Local cInsEsc

	cInsEsc := ""

	dbSelectArea("QM2")
	dbSetOrder(7)
	If QM2->(dbSeek(xFilial("QM2")+"0"+cInstr+cEscala))
		cInsEsc := QM2->QM2_INSTR
	EndIf

	dbSelectArea(cOldAlias)
	dbGoto(nReg)
Return(cInsEsc)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QMT140IPS ³ Autor ³ Wanderley Goncalves   ³ Data ³ 24/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a soma das incertezas dos padroes para o tipo soma ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                         					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpC1 : Valor da incerteza total                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QMTA140													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QMT140IPS(cCodFaixa)

	Local cValor:= ""
	Local nValor:= 0
	Local nOrd	:= QMA->(IndexOrd())
	Local nRecNo:= QMA->(recno())
	Local cFaixa:= xFilial("QMA")+QM9->QM9_ESCALA+QM9->QM9_REVESC+cCodFaixa
	Local nValor1:= 0
	Local nOrdQMT:= QMT->(IndexOrd())
	Local nRQMT	:=  QMT->(recno())

	dbSelectArea("QM3")
	DbSetOrder(1)
	If Inclui
		dbSelectArea("QMA")
		dbSetOrder(1)
		If dbSeek(cFaixa)
			Do While !Eof() .and. cFaixa == xFilial("QMA")+QMA->QMA_ESCALA+QMA->QMA_REVESC+QMA->QMA_FAIXA
				DbSelectArea("QM3")
				If QM3->(DbSeek(xFilial("QM3")+QMA->QMA_PADRAO))
					nValor := nValor + SuperVal(QM3->QM3_INCERT)
				EndIf
				DbSelectArea("QMA")
				DbSkip()
			EndDo
		EndIf
		QMA->(DbSetOrder(nOrd))
		QMA->(DbGoto(nRecNo))
	Else
		nOrdQMT	:= QMT->(IndexOrd())
		nRQMT	:= QMT->(recno())
		cFaixa	:= QMT->QMT_FILIAL+cMtInstr+cMtRevIns+DtoS(dMtData)+QMT->QMT_CSEQ+QMT->QMT_ESCALA+QMT->QMT_REVESC+QMT->QMT_PONTO
		nValor1 := 0
		dbSelectArea("QMT")
		QMT->(dbSetOrder(1))
		If QMT->(dbSeek(cFaixa))
			Do While !Eof() .and. cFaixa == xFilial("QMT")+QMT->QMT_INSTR+QMT->QMT_REVINS+DTOS(QMT->QMT_DATA)+QMT->QMT_CSEQ+QMT->QMT_ESCALA+QMT->QMT_REVESC+QMT->QMT_PONTO
				DbSelectArea("QM3")
				If QM3->(DbSeek(xFilial("QM3")+QMT->QMT_PADRAO))
					While !QM3->(Eof()) .and. QM3->QM3_FILIAL+QM3->QM3_PADRAO == QMT->QMT_FILIAL+QMT->QMT_PADRAO
						If DtoS(QM3->QM3_DATREV) <= DtoS(QMT->QMT_DATA)
							nValor1 := SuperVal(QM3->QM3_INCERT)
						Endif
						QM3->(dbSkip())
					Enddo
					nValor := nValor + nValor1
				EndIf

				QMT->(DbSkip())
			EndDo
		EndIf
		QMT->(DbSetOrder(nOrdQMT))
		QMT->(DbGoto(nRQMT))
	Endif

	QMA->(DbSetOrder(nOrd))
	QMA->(DbGoto(nRecNo))

	cValor := StrTran(Str(nValor),".",",")

Return(cValor)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A140ListPS³ Autor ³ Wanderley Goncalves Jr³ Data ³ 29/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro para Selecao de Padroes Secundarios				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A140ListPS()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SXB XB_CONTEM de consulta PSE 							  ³±±
±±³			 ³ e na funao A140VLPS() do X3_VALID do QMS_PADSEC 			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ListPS()

	Local cPertence	:= ""
	Local lRet			:= .F.
	Local nLin_aMed	:= Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})
	Local cEscala	:= If (Empty(aMedicoes[nLin_aMed,nPosCar]),aMedicoes[nLin_aMed,nPosEsc],aMedicoes[nLin_aMed,nPosCar])

	dbSelectArea("QMH")
	dbSetOrder(1)
	If dbSeek(xFilial("QMH")+cEscala)
		While QMH->QMH_ESCALA == cEscala .And. QMH->QMH_FILIAL == xFilial("QMH")
			cPertence += QMH->QMH_PADSEC
			QMH->(DbSkip())
		EndDo
	EndIf

	dbSelectArea("QM2")

	If QM2->QM2_TIPO $ cPertence
		lRet := .T.
	EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³a140MtResp³ Autor ³ Denis Martins         ³ Data ³ 01/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Nao permitir digitacao de responsavel com status demitido. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ a140MtResp()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA140                               				      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a140MtResp()
	Local aArea 	:= GetArea()
	Local lRet      := .T.
	Local cFils		:= ""

	If Inclui
		cFils := cMtFilRes
	Else
		cFils := QM6->QM6_FILRES
	Endif

	dbSelectArea("QAA")
	dbSetOrder(1)
	If dbSeek(cFils+cMtResp)
		If ! QA_SitFolh()	//Bloquear responsavel demitido.
			msgStop(OemToAnsi(STR0040))//Responsavel nao pode ser alocado, pois status e demitido
			lRet := .F.
		Endif
	Else
		msgStop(OemToAnsi(STR0041))//Nao foi encontrado o responsavel informado. Informe outro
		lRet := .F.
	Endif

	RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a140PadSecºAutor  ³Denis Martins       º Data ³  02/22/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retornar padroes secundarios apos pressionamento de F4.     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Qmta140()                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a140PadSec()
	Local cPertence	:= ""
	Local nPosAm	:= Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})
	Local cEscala
	Local cIndexQMH
	Local cChaveQMH
	Local nIndex
	Local cCond
	Local oQual
	Local oDlgA
	Local aRegQM2 := {}
	Local nOpc := 0
	Local nRegQM2 := 0
	Local nQM2Ins := 0
	Local cIndexQM2
	Local cChaveQM2
	Local cCondQM2
	Local nIndexQM2

	Local cChv := ""
	Local cFiltro := ""


	If Alltrim(ReadVar()) == Alltrim("M->QMS_PADSEC")
		cEscala		:= If(Empty(aMedicoes[nPosAm][nPosCar]),aMedicoes[nPosAm][nPosEsc],aMedicoes[nPosAm][nPosCar])
		dbSelectArea("QMH")
		dbSetOrder(1)
		If dbSeek(xFilial("QMH")+cEscala)
			cIndexQMH	:= CriaTrab(nil,.f.)
			cChaveQMH	:= "QMH_ESCALA"
			cCond		:= 'QMH_ESCALA == "'+cEscala+'"'
			IndRegua("QMH",cIndexQMH,cChaveQMH,,cCond,OemToAnsi(STR0048))  //"Selecionando Registros..."
			nIndex := RetIndex("QMH")
			dbSelectArea("QMH")
			dbSetOrder(nIndex+1)
			dbGoTop()
			While !Eof() .and. QMH->QMH_ESCALA == cEscala .And. QMH->QMH_FILIAL == xFilial("QMH")
				If QMH->QMH_PADSEC <> cPertence
					cPertence += "'"+QMH->QMH_PADSEC+"',"
				Endif
				QMH->(DbSkip())
			EndDo

			cPertence := SubStr(cPertence,1,Len(cPertence)-1)
			cChv := "QM2_FILIAL,QM2_INSTR,QM2_REVINV"
			cFiltro := "SELECT QM2.QM2_FILIAL,QM2.QM2_INSTR,QM2.QM2_REVINV,QM2.QM2_REVINS,QM2.QM2_VALDAF,QM2.QM2_TIPO,QM2.QM2_STATUS "
			cFiltro += "FROM "+RetSqlName("QM2")+" QM2 "
			cFiltro += "WHERE "
			cFiltro += "QM2.QM2_FILIAL ='"+ xFilial("QM2")+"' AND "
			cFiltro += "QM2.QM2_TIPO IN ("+cPertence+") AND "
			cFiltro += "QM2.QM2_FLAG ='1' AND "
			cFiltro += "QM2.D_E_L_E_T_ <> '*' "
			cFiltro += " ORDER BY " + SqlOrder(cChv)

			cFiltro := ChangeQuery(cFiltro)

			dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro),"TR2", .F., .T.)

			TcSetField("TR2","QM2_VALDAF","D",8,0)
			dbSelectArea( "TR2" )
			nQM2Ins := 0
			While !Eof()
				If TR2->QM2_TIPO $ cPertence
					If nQM2Ins := ASCAN(aRegQM2,{|x| alltrim(x[1]) = Alltrim(TR2->QM2_INSTR)}) == 0
						If DtoS(dMtData) <= DtoS(TR2->QM2_VALDAF)
							If QMTXSTAT(TR2->QM2_STATUS) .and. (Alltrim(cMtInstr) <> Alltrim(TR2->QM2_INSTR))
								Aadd(aRegQM2,{TR2->QM2_INSTR,TR2->QM2_REVINS,TR2->QM2_VALDAF})
							Endif
						Endif
					Endif
				Endif
				dbSelectArea("TR2")
				dbSkip()
			EndDo
			TR2->(dbCloseArea())

			If Len(aRegQM2) <> 0
				aSort(aRegQM2,,,{|x,y| x[1] < y[1]})
				DEFINE MSDIALOG oDlgA TITLE OemToAnsi(STR0046) From 09,0 To 21.5,50 OF oMainWnd //Padroes Secundarios
				@ .5,1 LISTBOX oQual	 VAR cVar Fields HEADER OemToAnsi(STR0008),OemToAnsi(STR0012),OemToAnsi(STR0047) SIZE 150,80 OF oDlgA  //42
				oQual:SetArray(aRegQM2)
				oQual:bLine := { || {aRegQM2[oQual:nAT,1],aRegQM2[oQual:nAT,2],aRegQM2[oQual:nAT,3]}}
				DEFINE SBUTTON FROM 10	,166	TYPE 1 ENABLE OF oDlgA ACTION (nOpc := 1,nRegQM2 := oQual:nAT ,oDlgA:End())
				DEFINE SBUTTON FROM 22.5,166	TYPE 2 ACTION (nOpc := 0,oDlgA:End()) ENABLE OF oDlgA
				ACTIVATE MSDIALOG oDlgA Centered
			Endif
			If nOpc == 1
				M->QMS_PADSEC := aRegQM2[nRegQM2][1]
			Endif

			dbSelectArea("QMH")
			Set Filter to
			RetIndex("QMH")
		Endif
	Endif

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PegaStatusºAutor  ³Denis Martins       º Data ³  05/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca a descricao do status do Instrumento.                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PegaStatus(cTipo)
	Local cDesc
	Local aArea := GetArea()

	dbSelectArea("QMP")
	dbSetOrder(01)
	If dbSeek(xFilial("QMP")+cTipo)
		cDesc := cTipo+" - "+QMP->QMP_DESCR
	Else
		MessageDlg(OemToAnsi(STR0051),,3)//Status nao encontrado
	Endif

	RestArea(aArea)

Return cDesc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A140Legd  ºAutor  ³Denis Martins       º Data ³  08/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mostrar a Legenda com as respectivas cores de escala e pa-  º±±
±±º          ³droes.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA140                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140Legd()
	Local aLegenda := {{"BR_VERDE"	   ,	STR0061	},;			//"Escalas / Padroes Aprovados"
	{"BR_VERMELHO"	,	STR0062 },;		//Escalas / Padroes Reprovados
	{"BR_PRETO"	   ,	STR0063 }}		//Escalas / Padroes Nao Digitados

	Local lSimples	:= .F.
	Local lCompl	:= .F.
	Local lPressao	:= .F.
	Local lCalibC 	:= .F.
	Local lCalib 	:= .F.
	Local lSoma     := .F.
	Local lRelogio	:= .F.
	Local nPsRow	:=  1

	If Len(aMedicoes) > 0
		BrwLegenda(cCadastro,STR0052,aLegenda)  //Medicoes / Legenda

		If aObjetos[OBJ_NAOCONFOR] <> NIL
			//Integridade - Permitir incluir/alterar as getdados
			If Inclui .or. Altera
				aObjetos[OBJ_PADSEC][2]:oBrowse:nOpc := 3
				aObjetos[OBJ_INSTUTIL][4]:oBrowse:nOpc := 3
				aObjetos[OBJ_NAOCONFOR][2]:oBrowse:nOpc := 3
				aObjetos[OBJ_INCERT_B][3]:oBrowse:nOpc := 3
			Else
				aObjetos[OBJ_PADSEC][2]:oBrowse:nOpc := 2
				aObjetos[OBJ_INSTUTIL][4]:oBrowse:nOpc := 2
				aObjetos[OBJ_NAOCONFOR][2]:oBrowse:nOpc := 2
				aObjetos[OBJ_INCERT_B][3]:oBrowse:nOpc := 2
			Endif
		Endif

		If aMedicoes[nPosAMed,nPosGer,1,2] == "1"   // Tipo Simples
			lSimples	:= .T.
		ElseIf aMedicoes[nPosAMed,nPosGer,1,2] == "2"   // Tipo Completa
			lCompl		:= .T.
		ElseIf aMedicoes[nPosAMed,nPosGer,1,2] == "3"   // Tipo Pressao
			lPressao	:= .T.
		ElseIf aMedicoes[nPosAMed,nPosGer,1,2] $ "4|8"   // Tipo Calibradores
			lCalibC 	:= .T.
			lCalib 		:= .T.
		ElseIf aMedicoes[nPosAMed,nPosGer,1,2] == "5"   // Tipo Soma
			lSoma       := .T.
		ElseIf aMedicoes[nPosAMed,nPosGer,1,2] == "9"   // Tipo Relogio
			lRelogio	:= .T.
		EndIf

		//Controle para Refresh da GetDados Medicoes
		If oFolderFix:nOption == 1
			If aMedicoes[nPosAMed,nPosGer,1,1] <> 0 //.and. aMedicoes[nLin_aMed,nPosGer,1,4] <> "E"
				nPsRow	:=  aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:nRowPos
				If aMedicoes[nPosAMed,nPosGer,1,1] > 1
					If lPressao .or. lRelogio .or. lSoma .or. lCompl
						aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:SetFocus()
						aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:nRowPos := nPsRow
					ElseIf lCalibC .or. lCalib .or.	lSimples
						aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:SetFocus()
						aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:nRowPos := nPsRow
					Endif
					aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:SetFocus()
				Endif
			Endif
		Endif
	Endif

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a140CalITBºAutor  ³Denis Martins       º Data ³  07/25/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula a Incerteza Combinada e Expandida para ser visuali- º±±
±±º          ³zada na Tela de  Resultado do Padrao.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a140CalITB(nLin_aMed)
	Local nDivisor	:= 1
	Local cTotal	:= ""
	Local nTotal	:= 0
	Local nVeff 	:= 0
	Local cVeff 	:= ""
	Local nValMin	:= 0
	Local nValMax	:= 0
	Local nMedMin	:= 0
	Local nMedMax	:= 0
	Local nKp		:= 0
	Local cKp		:= ""
	Local nIEC		:= 0	 // Incerteza expandida calculada
	Local cIEC		:= ""
	Local aArea		:= GetArea()
	Local cEscs		:= ""

	If Empty(aMedicoes[nLin_aMed,nPosCar])
		cEscs := aMedicoes[nLin_aMed,nPosEsc]
	Else
		cEscs := aMedicoes[nLin_aMed,nPosCar]
	Endif

	dbSelectArea("QMX")
	While !Eof()
		SET DECIMALS TO 7
		If QMX->QMX_FILIAL+QMX->QMX_INSTR+QMX_REVINS+DtoS(QMX->QMX_DATA)+QMX_CSEQ+;
				QMX->QMX_ESCALA+QMX->QMX_PONTO == xFilial("QMX")+cMtInstr+;
				cMtRevIns+DtoS(dMtData)+cSeql+cEscs+aMedicoes[nLin_aMed,nPosPad]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o valor da incerteza padronizada combinada ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Alltrim(QMX->QMX_CSEQ) == Alltrim(cSeql)
				If !Empty(QMX->QMX_VALINC) .and. !Empty(QMX->QMX_DIV) .and. !Empty(QMX->QMX_CSENS)
					If Upper(Left(QMX->QMX_DIV,1)) == "R"
						nDivisor := Sqrt(SuperVal(Substr(QMX->QMX_DIV,2,Len(QMX->QMX_DIV))))
					Else
						nDivisor := SuperVal(QMX->QMX_DIV)
					EndIf

					nTotalUi := QMX->QMX_UI
					If At(nTotalUi,".") == 0
						nTotalUi := StrTran(nTotalUi,",",".")
					Endif

					nTotal += Val(nTotalUi)**2

					If !Empty(QMX->QMX_VI)
						If At(QMX->QMX_VI,".") == 0
							nTotalVi := StrTran(QMX->QMX_VI,",",".")
						Endif
						nVeff+= (Val(nTotalUi)**4)/Val(nTotalVi)
					EndIf
				Endif
			Endif
		Endif
		dbSkip()
	Enddo

	nTotal	:= Sqrt(nTotal)
	cTotal	:= AllTrim(AlgSignif(nTotal,5))

	aMedicoes[nLin_aMed,nPosGer,1,17,1] := cTotal //Associa Incerteza Combinada

	nVeff := (nTotal**4)/nVeff

	cVeff := AllTrim(AlgSignif(nVeff))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o valor de Kp	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nValMin := RetStud(nVeff,aMedicoes[nLin_aMed,nPosGer,1,14],.T.)
	nValMax := RetStud(nVeff,aMedicoes[nLin_aMed,nPosGer,1,14],.F.)
	nMedMin := Int(nVeff)
	nMedMax := Int(nVeff)+1

	nKp := (((nVeff-nMedMin)*(nValMax-nValMin))/(nMedMax-nMedMin))+nValMin

	cKp := AllTrim(AlgSignif(nKp))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o valor da Incerteza Expandida Calculada   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nIEC := nTotal * nKp

	cIEC := AllTrim(AlgSignif(nIEC))

	aMedicoes[nLin_aMed,nPosGer,1,17,2] := cIEC //Associa Incerteza Expandida
	SET DECIMALS TO 2
	RestArea(aArea)
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QMTA140EnBar³ Autor ³ Denis Martins              ³ Data ³ 09/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta a Enchoice Bar                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QMTA140EnBar( oDlg, bOk, bCancel, nOpc )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oDlg       ³ Objeto da Tela que contera a enchoice                ³±±
±±³           ³ bOk        ³ Bloco executado quando da confirmacao(Botao Ok)      ³±±
±±³           ³ bCancel    ³ Bloco executado quando do cancelamento(Botao Cancela)³±±
±±³           ³ nOpc       ³ Opcao de selecao do aRotina                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QMTA140                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMTA140EnBar( oDlgPri, bOk, bCancel, nOpc )
Local aButtons := {}

aAdd(aButtons,{"SDUPROP"	,{|| A140Legd()}, OemToAnsi(STR0074)}) //Legenda
aAdd(aButtons,{"NOTE"	,{|| A140ConMed(oFolderFix,nPosAmed)}, OemToAnsi(STR0099)}) //"Medidas"
aAdd(aButtons,{"GRAF3D"		,{|| Qmt140MGraf(oFolderFix,nPosAmed,oDlgPri)}, OemToAnsi(STR0095)}) //"MSA"
aAdd(aButtons,{"AUTOM"		,{|| If(Len(aMedicoes) > 0,(nPosAnt := nPosAmed,a141ContrFld(nGot:=oFolderFix:nOption,oFolderFix:nOption,.F.),A140ShwEsc(oDlgPri,oBmpEsc,oBmpPad,oFolderFix)),.F.)}, STR0043}) //"Faixa"
aAdd(aButtons,{"BMPINCLUIR"	,{|| If(Len(aMedicoes) > 0,(nPosAnt := nPosAmed,a141ContrFld(nGot:=oFolderFix:nOption,oFolderFix:nOption,.F.),A140ShwPad(oCbxEsc,oCbxPad,oFolderFix,oDlgPri),A141AprPad(oDlgPri,oBmpPad,oBmpEsc)),.F.)}, STR0044 }) //"Padroes"
aAdd(aButtons,{"PROJETPMS"	,{|| If(Len(aMedicoes) > 0,Qmt140Foto(),.F.)}, OemToAnsi(STR0100)}) //"Foto"
aAdd(aButtons,{"DOC"	,{|| If(Len(aMedicoes) > 0,QMT140Doc(),.F.)}, OemToAnsi(STR0113)}) //"Documento"
If ChkFile("QN7")
	aAdd(aButtons,{"RELATORIO" , {|| FQMTANEXO( nOpc,@aColAnx,@aHeadAnx) }, OemToAnsi( STR0108 ), OemtoAnsi(STR0109) } )  //"Documento Anexo"  //"Doc.Anexo"
Endif
EnchoiceBar(oDlgPri,bOk,bCancel,,aButtons)

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QMTA140BtOff ³ Autor ³ Denis Martins            ³ Data ³ 15/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Habilita/desabilita CRTL O e CTRL X                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QMTA140BtOff( bSet15, bSet24, lOk )                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ bSet15     ³ Bloco com valor ASCII para CTRL 0                    ³±±
±±³           ³ bSet24     ³ Bloco com valor ASCII para CTRL X                    ³±±
±±³           ³ lOk        ³ Valor logico que permite habilitar ou desabilitar    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ Siga Quality ( Metrologia )                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QMTA140BtOff( bSet15, bSet24, lOk )
Default lOk := .T.

	If lOk
   SetKey( 15, bSet15 )
   SetKey( 24, bSet24 )
	EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A140ConMedºAutor  ³Denis Martins       º Data ³  01/16/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mostrar Dialog para informacao de conversao de medidas      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA140/QMTA141/QMTA142                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ConMed(oFolderFix,nPosAmed)
	Local oDlgC
	Local nOpca := 0
	Local cDescD	:= ""
	Local cDescP	:= ""
	Private cConDe	:= Space(02)
	Private cConPara:= Space(02)
	Private nConver	:= 0
	If Len(aMedicoes) > 0
		If nPosAmed > 0
			IIf(!Empty(cUniMed),cConde := aMedicoes[nPosAmed][12][1][22],cConde := Space(02))
		Else
			IIf(!Empty(cUniMed),cConde := cUniMed,cConde := Space(02))
		Endif
		cConPara := QM9->QM9_UNIMED
		DEFINE MSDIALOG oDlgC TITLE OemToAnsi(STR0079) FROM 33,25 TO 180,349 PIXEL  //Conversao de Medidas

		@ 012,005 To 69,155 OF oDlgC PIXEL
		@ 006,008 SAY OemToAnsi(STR0078) SIZE 120, 7 OF oDlgC PIXEL  // Informe o Fator de Conversao
		@ 020,008 SAY OemToAnsi(STR0080) SIZE 55, 7 OF oDlgC PIXEL  // De:
		@ 020,038 MSGET cConde F3 "SAH" Valid (ExistCpo("SAH") .and. a140ShwDD(@cDescD,cConde)) OF oDlgC PIXEL
		@ 020,061 SAY cDescD SIZE 150, 7 OF oDlgC PIXEL
		@ 035,008 SAY OemToAnsi(STR0077) SIZE 18, 7 OF oDlgC PIXEL  //Para:
		@ 035,038 MSGET cConPara F3 "SAH" Valid (ExistCpo("SAH") .and. a140ShwDP(@cDescP,cConPara)) OF oDlgC PIXEL
		@ 035,061 SAY cDescP OF oDlgC SIZE 150, 7 PIXEL
		@ 049,008 SAY OemToAnsi(STR0081) SIZE 34, 7 OF oDlgC PIXEL	//Conversao
		@ 049,038 MSGET nConver Picture PesqPict("SAP","AP_COEF") SIZE 45, 11 OF oDlgC PIXEL

		DEFINE SBUTTON FROM 36, 120 TYPE 1 ACTION (nOpca := 1,a140grsap(cConde,cConPara,nConver,oFolderFix,oDlgC)) ENABLE OF oDlgC
		DEFINE SBUTTON FROM 52, 120 TYPE 2 ACTION (nOpca := 0, oDlgC:End()) ENABLE OF oDlgC

		If aObjetos[OBJ_NAOCONFOR] <> Nil
			//Integridade - Permitir incluir/alterar as getdados
			If Inclui .or. Altera
				aObjetos[OBJ_PADSEC][2]:oBrowse:nOpc := 3
				aObjetos[OBJ_INSTUTIL][4]:oBrowse:nOpc := 3
				aObjetos[OBJ_NAOCONFOR][2]:oBrowse:nOpc := 3
				aObjetos[OBJ_INCERT_B][3]:oBrowse:nOpc := 3
			Else
				aObjetos[OBJ_PADSEC][2]:oBrowse:nOpc := 2
				aObjetos[OBJ_INSTUTIL][4]:oBrowse:nOpc := 2
				aObjetos[OBJ_NAOCONFOR][2]:oBrowse:nOpc := 2
				aObjetos[OBJ_INCERT_B][3]:oBrowse:nOpc := 2
			Endif
		Endif
		ACTIVATE MSDIALOg oDlgC CENTERED
	Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a140grsap ºAutor  ³Denis Martins       º Data ³  01/17/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realizar gravacao de conversao de medidas                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA140/QMTA141/QMTA142                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a140grsap(cConde,cConPara,nConver,oFolderFix,oDlgC)
	Local aArea := GetArea()
	Local lRet	:= .T.
	If cConde == cConPara
		MessageDlg(STR0083,,3)
		lRet := .F.
	Endif

	If lRet
		If nConver == 0
			MessageDlg(STR0094,,3)	//Nao eh permitido conversao de medidas com valores igual a zero
			lRet := .F.
		Endif
	Endif

	If lRet
		dbSelectArea("SAP")
		dbSetOrder(1)
		If !dbSeek(xFilial("SAP")+cConde+cConPara)
			Reclock("SAP",.T.)
			Replace AP_DE	with cConde
			Replace AP_PARA	with cConPara
			Replace AP_COEF	with nConver
			MsUnlock()
		Endif
		oDlgC:End()
	Endif

	oFolderFix:lReadOnly := .F.

	If oCbxEsc <> Nil
		oCbxEsc:lReadOnly := .F.
	Endif

	If oCbxPad <> Nil
		oCbxPad:lReadOnly := .F.
	Endif

	lRetUnid := .T.
	RestArea(aArea)
Return .T.

Static Function a140ShwDD(cDescD,cConde)
	dbSelectArea("SAH")
	dbSetOrder(01)
	dbSeek(xFilial("SAH")+cConde)
	cDescD := SAH->AH_UMRES
Return .T.

Static Function a140ShwDP(cDescP,cConPara)
	dbSelectArea("SAH")
	dbSetOrder(01)
	dbSeek(xFilial("SAH")+cConPara)
	cDescP := SAH->AH_UMRES
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt140unmedºAutor  ³Denis Martins       º Data ³  01/19/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pela verificacao dos fatores de conversao º±±
±±º          ³de medidas entre escalas e pontos - Calibrador/Calib.Completoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA140/141/142                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt140unmed(lJaMontTre)
	Local nx := 0
	For nx := 1 TO Len(aMedicoes)
		If aMedicoes[nx,nPosGer,1,2] $ "4|8"
			If aMedicoes[nx,nPosGer,1,22] <> aMedicoes[nx,nPosGer,1,23]
				If Alltrim(aMedicoes[nx,nPosGer,1,3]) <> "A" //Se for diferente de Atributo
					dbSelectArea("SAP")
					dbSetOrder(1)
					If !dbSeek(xFilial("SAP")+aMedicoes[nx,nPosGer,1,22]+aMedicoes[nx,nPosGer,1,23])
						lJaMontTre := .F.
						MessageDlg(OemToAnsi(STR0082)+aMedicoes[nx,nPosGer,1,22]+OemToAnsi(STR0077)+aMedicoes[nx,nPosGer,1,23],,3)//Unidades de Medidas Incompativeis. Cadastre as mesmas.
						Exit
					Endif
				Endif
			Endif
		Else
			lJaMontTre := .T.
		Endif
	Next nx
Return lJaMontTre


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt140SetOptºAutor  ³Microsiga           º Data ³  03/15/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica em qual posicao do folter estou atualizando nposant	º±±
±±º          ³para nao perder foco de tela e grava acols corretamente.    	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt140SetOpt(nGot)

	oFolderFix:bSetOption :={|nAt|nPosAnt := Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])}),a141ContrFld(nGot:=nAt,oFolderFix:nOption)}

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt140VlRerºAutor  ³Denis Martins       º Data ³  10/14/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Sugere como Responsavel pela calibracao o usuario logado     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA140                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt140VlRer()

	Local cVar		:= Upper(cUserName)
	Local aArea		:= GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Responsavel cadastrado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QAA")
	dbSetOrder(6)
	If dbSeek(cVar)
		cMtResp := QAA->QAA_MAT
	Else
		MessageDlg(STR0084,,3) //"Responsavel nao cadastrado. Informe ou cadastre um valido."
		cMtResp := CriaVar("QM6_RESP",.T. )
	Endif

	RestArea(aArea)

Return cMtResp


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qmt140MGrafºAutor  ³Denis Martins       º Data ³  08/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pela chamada das impressoes de graficos   º±±
±±º          ³apartir da Tela de Calibracoes                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA140 / QMTA141 / QMTA142                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt140MGraf(oFolderFix,nPosAmed,oDlgPri)
	Local lRet := .t.
	Local cInstrumento := cMtInstr+cMtRevIns
	Local lCalib := .T.
	Private cTitulo    := ""
	Private nLinearA   := 0
	Private nLinearB   := 0
	Private nLinearR2  := 0
	Private nLinearVp  := 0
	Private nLinear    := 0
	Private nLinearP   := 0
	Private lMsa3Ed	   := .F.
	Private aTab   	   := array(20,21)
	Private aTbv	   := array(20,21)

	If Len(aMedicoes) > 0
		//Salva a Acols caso tenha mudado...
		a141ContrFld(nGot := 2,oFolderFix:nOption)
		If (!Pergunte("QMA190",.T.))
			lRet := .F.
		EndIf

		If lRet

			If MV_PAR06 == 2 //Pegar valores dos estudos do MSA
				lCalib := .F.
			Endif

			If MV_PAR07 == 2 //Considerar MSA 3 Edicao..
				lMsa3Ed := .T.
			Endif

			Do Case
			Case MV_PAR01 == 1
				cTitulo := OemToAnsi(STR0104) //"Tendencia"
			Case MV_PAR01 == 2
				cTitulo := OemToAnsi(STR0105) //"Linearidade"
			Case MV_PAR01 == 3
				If lMsa3Ed
					cTitulo := OemToAnsi(STR0106)+"/"+OemToAnsi(STR0104) //"Estabilidade" - "Tendencia"
				Else
					cTitulo := OemToAnsi(STR0106) //"Estabilidade"
				Endif
			EndCase
			If Inclui
				dbSelectArea("QM2")
				dbSetOrder(1)
				If dbSeek(xFilial()+cMtInstr+Inverte(cMtRevIns))
					cTitulo += " - "+cMtInstr+"/"+cMtRevIns
				Endif
			Else
				cTitulo += " - "+QM6->QM6_INSTR+"/"+QM6->QM6_REVINS
			Endif

			GraphIni(lCalib,cInstrumento,cTitulo,.T.,cMtInstr,cMtRevIns,cDQM2Des)

		Endif
	Endif
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qmt140FotoºAutor  ³Denis Martins       º Data ³  12/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Apresenta a foto do instrumento                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA140 / QMTA141 e QMTA142                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt140Foto()
	Local oDlgPs
	Local oBmpS
	Local oGrpS
	Local oGrpIS
	DEFINE MSDIALOG oDlgPs TITLE OemToAnsi(STR0100) FROM 40,80 TO 450,500 OF GetWndDefault() PIXEL //Foto
	@ 1,2	Group oGrpS TO 36,209 LABEL STR0101 OF oDlgPs PIXEL COLOR CLR_HRED //"Informacoes Instrumento"
	@ 10,6 SAY STR0008+": "+Alltrim(cMtInstr)+" - "+cMtRevIns OF oDlgPs PIXEL //Instrumento
	@ 10,125 SAY STR0102+Alltrim(cMtFilRes) OF oDlgPs PIXEL //Filial
	@ 20,6 SAY STR0010+": "+DtoC(dMtData) OF oDlgPs PIXEL	//Data
	@ 20,125 SAY STR0103+Alltrim(cMtResp) OF oDlgPs PIXEL	//"Resp.: "
	@ 40,2	Group oGrpIS TO 200,209 LABEL STR0008 OF oDlgPs PIXEL COLOR CLR_HRED //Instrumento
	@ 51,30 REPOSITORY oBmpS SIZE 140,140 OF oDlgPs NOBORDER PIXEL //049,038
	oBmpS:lStretch := .t.

	ShowBitmap(oBmpS,cCdBitMap,"INSPAD")

	DEFINE SBUTTON FROM 180,180	TYPE 1 ENABLE OF oDlgPs ACTION (oDlgPs:End())

	ACTIVATE MSDIALOG oDlgPs CENTERED
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qmt140Del ºAutor  ³Denis Martins       º Data ³  11/21/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se e permitido a alteracao e delecao de calibracoesº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA140 / QMTA141                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt140DelCa(lAlt,cInsts,dDatCa,nOpca)
	Local lRet		:= .T.
	Local aReQM6	:= GetArea()
	Local nRecQM6	:= QM6->(Recno())
	Local lQPdDel 	:= GetMv("MV_QPDELCA") == "2"
	Local cRevIs    := QM6->QM6_REVINS
	Default lAlt	:= .F.

	If nOpca == 4 .or. nOpca == 5 //Alteracao ou Exclusao
		If lQPdDel
			dbSelectArea("QM6")
			DbSetOrder(4)
			dbSeek(xFilial("QM6")+cInsts)
			While QM6->(!Eof()) .and. xFilial("QM6")+cInsts == QM6->QM6_FILIAL+QM6->QM6_INSTR
				If DtoS(QM6->QM6_DATA) > DtoS(dDatCa)
					lRet := .F.
					Exit
				Endif
				dbSkip()
			Enddo
			Dbgoto(nRecQM6)
			If !lRet
				If lAlt
					MsgStop(STR0097)	//"Alteracao nao permitida, pois existe calibracoes posteriores."
				Else
					MsgStop(STR0098)	//"Delecao nao permitida, pois existe calibracoes posteriores."
				Endif
			Endif
		Endif
	Endif

	If lRet .and. nOpca == 5 // Verifica se o instrumento esta sendo ultilizado com o conceito de padrao secundario
		dbSelectArea("QMS")
		DbSetOrder(2)
		If dbSeek(xFilial("QMS")+cInsts)
			While QMS->(!Eof()) .and. (cInsts == QMS->QMS_PADSEC)
				If (QMS->QMS_REVQPR == cRevIs) .AND. (DtoS(QMS->QMS_DATQPR) == DtoS(dDatCa))
					If !MsgYesNo(STR0110+RTrim(cInsts)+STR0111)   //"O instrumento "###" esta sendo utilizado com conceito de padrao secundario em outra(s) calibracao(oes)! Deseja excluir?"
						lRet := .F.
					EndIf
					Exit
				EndIf
				QMS->(dbSkip())
			End
		Endif
	EndIf

	If lRet .and. nOpca == 5 // Verifica se o instrumento esta sendo ultilizado com o conceito de instrumento utilizado
		dbSelectArea("QMI")
		DbSetOrder(2)
		If dbSeek(xFilial("QMI")+cInsts)
			While QMI->(!Eof()) .and. (cInsts == QMI->QMI_INSUT)
				If (QMI->QMI_REVQPR == cRevIs) .AND. (DtoS(QMI->QMI_DATQPR) == DtoS(dDatCa))
					If !MsgYesNo(STR0110+RTrim(cInsts)+STR0112)   // "O instrumento "###" esta sendo utilizado com conceito de Instrumento Utilizado em outra(s) calibracao(oes)! Deseja excluir?"
						lRet := .F.
					EndIf
					Exit
				EndIf
				QMI->(dbSkip())
			End
		Endif
	EndIf

	RestArea(aReQM6)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QM140ClKeyºAutor  ³Denis Martins       º Data ³  05/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Limpa os valores das teclas de atalho - tela de calibracoes º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA140 / QMTA141										  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM140ClKey()

	SetKey(VK_F4,{|| Nil })
	SetKey(VK_F5,{|| Nil })
	SetKey(VK_F6,{|| Nil })
	SetKey(VK_F8,{|| Nil })

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQMT140SEQ³ Autor ³ Aldo Marini Junior    ³ Data ³ 06/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa generico para Buscar Sequencias                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA140                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function FQMT140SEQ
Return ( If(Len(aCols) == 1,"001",StrZero(Val(aCols[Len(aCols)-1,1])+1,3,0)))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt140VDocºAutor  ³Denis Martins       º Data ³  08/13/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualiza documento associado ao Procedimento de Medicao 	  º±±
±±º          ³(Word)                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA140                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt140VDoc()

	If !Empty(QM6->QM6_CODDOC)
		QDOVIEW( , QM6->QM6_CODDOC, QM6->QM6_REVDOC ) //Visualiza documento Word...
	Else
		MsgInfo(STR0114) //"Nao existe documento associado a esta Calibracao"
	Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTA140   ºAutor  ³Nilton MK           º Data ³  16/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Notifica lab. externo sem atributo                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FQMT140MSG
	Local lRet		:= .T.
	Local nCntFor	:= 0
	Local nLoop 	:= 0
	Local nLoop2	:= 0

	If Alltrim(aMedicoes[nPosAnt][nPosPad]) == "PADRAOEXT"
		For nCntFor := 1 To len(aMedicoes)
			If !Empty(aMedicoes[nCntFor, nPosMed]) // Coleta medicoes
				For nLoop := 1 To len(aMedicoes[nCntFor, nPosMed,1]) - 1 // -1 porque a ultima coluna é .T. ou .f. para o aCols
					If aMedicoes[nCntFor,nPosGer,1,3] == "A"
						For nLoop2 := 1 To Len(aMedicoes[nCntFor,nPosMed])
							If Empty(aMedicoes[nCntFor,nPosMed,nLoop2,nLoop]) .Or. (aMedicoes[nCntFor,nPosMed,nLoop2,nLoop] == ' ')
								IF Posicione("QMR",1,xFilial("QMR")+cMtInstr+cMtRevIns+aMedicoes[nCntFor,nLoop], 'QMR_CAOBRI') == "S"
									MSGALERT ("Atributo deve ser Aprovado ou reprovado para padrão externo","Atributo")
									Exit
								ENDIF
							EndIf
						Next nLoop2
					EndIf
				Next nLoop
			EndIf
		Next nCntFor
	EndIf
Return lret

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTA140   ºAutor  ³Equipe Quality      º Data ³  29/09/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Visualiza documento /procedimento para gerar a calibracao º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³     QM2 e QM1 obrigatório mesmo compartilhamento           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QMT140Doc

	Local cIntru  := M->QM6_INSTR
	Local cRevIn  := Inverte(M->QM6_REVINS)
	Local cRev    := M->QM6_REVINS
	Local cPrQual := ""
	Local nRecQM1 := 0
	Local cCodDoc := ""


	dbSelectArea("QM2")
	dbSetOrder(1)
	dbSeek(xFilial("QM2")+cIntru+cRevIn)

	dbSelectArea("QM1")
	dbSetOrder(1)
	dbSeek(xFilial("QM1")+QM2->QM2_TIPO)
	cPrQual := QM1->QM1_PROCAL


	If !Empty(cPrQual)
		dbSelectArea("QA5")
		dbSetOrder(1)
		If dbSeek(xFilial()+"C"+cPrQual)
			If !Empty(QA5->QA5_DOCTO)
				cCodDoc := QA5->QA5_DOCTO
			Endif
		Endif
	Endif


	If !Empty(cCodDoc)
		QDOVIEW( , cCodDoc, cRev ) //Visualiza documento Word...
	Else
		MsgInfo(STR0114) //"Nao existe documento associado a esta Calibracao"
	Endif

	dbCloseArea("QM1")
	dbCloseArea("QM2")
	dbCloseArea("QA5")


Return Nil
