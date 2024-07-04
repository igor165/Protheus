#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "CSAA060.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CSAA060  ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Fatores e Graduacao das Avaliacoes GERAIS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CSAA060()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA060                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³07/07/14³TPZVTW³Incluido o fonte da 11 para a 12 e        ³±±
±±³            ³        ³      ³efetuada a limpeza.                       ³±±
±±³Mariana M.  ³16/01/15³TRJRYT³Ajuste para que o sistema mostre na rotina³±±
±±³            ³        ³      ³de Fatores de Avaliação em Grupo e Cargos ³±±
±±³            ³        ³      ³(botão F3 na pasta Fatores de Avaliação)  ³±±
±±³            ³        ³      ³todos os graus cadastrados.				  ³±±
±±³Luis Artuso ³21/10/15³TTJKCZ³Ajuste para retirar limite de inclusão de ³±±
±±³            ³        ³      ³registros por Fator na tabela SQV         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSAA060()
Local cFiltraRh		:= ""			//Variavel para filtro
Local cFiltra		:= ""			//Variavel para filtro

Private aIndexSQV	:= {}			//Variavel Para Filtro
Private bFiltraBrw 	:= {|| Nil}	//Variavel para Filtro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa 	 ³
//³ ----------- Elementos contidos por dimensao ------------	 ³
//³ 1. Nome a aparecer no cabecalho 							 ³
//³ 2. Nome da Rotina associada 								 ³
//³ 3. Usado pela rotina										 ³
//³ 4. Tipo de Transa‡„o a ser efetuada 						 ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados			 ³
//³    2 - Simplesmente Mostra os Campos						 ³
//³    3 - Inclui registros no Bancos de Dados					 ³
//³    4 - Altera o registro corrente							 ³
//³    5 - Remove o registro corrente do Banco de Dados 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

Private cCadastro := OemToAnsi(STR0008) //"Fatores de Avaliacao Geral e suas Graduacoes"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SQV")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"SQV","1")
cFiltraRh	:= "QV_SEQ == '01'"
If !Empty(cFiltra)
	cFiltraRh += ".And." + cFiltra
EndIf
bFiltraBrw 	:= {|| FilBrowse("SQV",@aIndexSQV,@cFiltraRh) }
Eval(bFiltraBrw)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE 						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SQV")
dbGotop()

mBrowse(6, 1, 22, 75,"SQV")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SQV",aIndexSQV,.T.)

dbSelectArea("SQV")
dbSetOrder(1)

dbSelectArea("SQ1")
dbSetOrder(1)

dbSelectArea("SQ2")
dbSetOrder(1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs060Rot ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para controle dos fatores e graduacao avaliacao   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CSA060Rot(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo 								  ³±±
±±³ 		 ³ ExpN1 = Numero do registro							   	  ³±±
±±³ 		 ³ ExpN2 = Numero da opcao Selecionada					   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA060  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060Rot(cAlias,nReg,nOpcx)
Local aKeys		:= GetKeys()
Local aSaveArea	:= GetArea()
Local bCampo
Local cChave	:= ""
Local ni		:= 0
Local nOpca		:= 0
Local nGrava	:= 0
Local lTrDel	:= If(nOpcx=2.Or.nOpcx=5,.F.,.T.)
Local lGetd 	:= .F.
Local oFont, oGet
Local oEnchoice
Local oDlgMain
Local aFields	:= {}
Local aAlter	:= {}
Local cFil		:= ""
Local cFator	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local nRegMaxSQV 	:= ( 36 ^ GetSx3Cache("QV_GRAU","X3_TAMANHO") )

Private cArqNtx 	:= ""
Private nOpcao		:= nOpcx
Private aCols		:= {}
Private aHeader		:= {}
Private aAuxCols	:= {}
Private aAuxHeader	:= {}
Private aTELA[0][0]
Private aGETS[0]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SQV",aIndexSQV,.T.)
aIndexSQV := {}
dbGoto(nReg)

bCampo := {|nCPO| Field(nCPO) }

If nOpcao == 3			//Inclusao
	cFil 	:= xFilial("SQV")
	cFator	:= GetSXENum("SQV","QV_FATOR")
	RollBackSX8() // Retorna numeracao anterior devido carregar initpad do campo abaixo.

	cChave 	:= cFil+cFator
	FOR ni := 1 TO FCount()
		DbSelectArea(cAlias)
		cCampo := EVAL(bCampo,ni)
		lInit := .f.
		If ExistIni(cCampo)
			lInit := .t.
			M->&(cCampo) := InitPad(SX3->X3_RELACAO)
			If ValType(M->&(cCampo)) = "C"
				M->&(cCampo) := PADR(M->&(cCampo),SX3->X3_TAMANHO)
			EndIf
			If M->&(cCampo) == NIL
				lInit := .f.
			EndIf
		EndIf
		If !lInit
			M->&(cCampo) := FieldGet(ni)
			If ValType(M->&(cCampo)) = "C"
				M->&(cCampo) := SPACE(LEN(M->&(cCampo)))
			ElseIf ValType(M->&(cCampo)) = "N"
				M->&(cCampo) := 0
			ElseIf ValType(M->&(cCampo)) = "D"
				M->&(cCampo) := CtoD("  /  /  ")
			ElseIf ValType(M->&(cCampo)) = "L"
				M->&(cCampo) := .F.
			EndIf
		EndIf
	Next ni
Else
	cChave := SQV->QV_FILIAL+SQV->QV_FATOR
	FOR ni := 1 TO FCount()
		M->&(EVAL(bCampo,ni)) := FieldGet(ni)
	NEXT ni
EndIf

If nOpcx != 2 .And. nOpcx != 5		// Visual/Excluir
	lGetD :=.T.
EndIf

// Campos que devem aparecer na Enchoice
Aadd(aFields,"QV_FATOR  ")
Aadd(aFields,"QV_DESCFAT")

// Verifica campos de usuario que devem aparecer na Enchoice
Cs060Usuario(@aFields)

// Campos que nao podem aparecer na getdados
aAlter:= aClone(aFields)
Aadd(aAlter,"QV_SEQ    ")

// Monta aHeader da GetDados
TrmHeader(@aAuxHeader,aAlter,"SQV")

// Monta o aCols da GetDados
Cs060aCols(1,@aAuxCols,nOpcx,"SQV","SQV->QV_FILIAL+SQV->QV_FATOR",cChave,aAuxHeader,1)

aCols 	:= aAuxCols
aHeader	:= aAuxHeader

SETAPILHA()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 030 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL

	Zero()
	oEnchoice:=MsMGet():New("SQV", nReg, nOpcx,,,,aFields,aObjSize[1],IIf(Str(nOpcx,1,0)$"34",Nil,{}) , , , , , , , ,.T. )

	oGet := MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpcx,"Cs060LOk","Cs060TOk","+QV_GRAU",lTrDel,,1,,nRegMaxSQV,,,,,oDlgMain)
	oGet:oBrowse:Default()

ACTIVATE DIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain,{|| If(oGet:TudoOk(),(nGrava:= 1,RestKeys(aKeys,.T.),oDlgMain:End()),.F.) }, {|| nGrava:=2,RestKeys(aKeys,.T.),oDlgMain:End()} )
SETAPILHA()

If nGrava == 1
	If nOpcao != 2	// Se nao visual
		Begin Transaction
			If nOpcao == 3			// Inclusao
				If __lSX8
					ConfirmSX8()
				EndIf
			EndIf
			Cs060Grava()
			EvalTrigger()
		End Transaction
	EndIf
Else
	If nOpcao == 3 		//Inclusao
		If __lSX8
			RollBackSX8()
		EndIf
	EndIf
EndIf

dbSelectArea("SQ2")
Set Filter To
RetIndex("SQ2")
dbSetOrder(1)
FErase (cArqNtx+OrdBagExt())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SQV")
Eval(bFiltraBrw)
dbGoTo(nReg)

RestArea(aSaveArea)
RestKeys(aKeys,.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs060Usuar ³ Autor ³ Cristina Ogura       ³ Data ³ 14.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica no SX3 se o usuario criou algum campo		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs060Usuar(aFields)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 := Array com os campos       			 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA060   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060Usuario(aFields)
Local aSaveArea	:= GetArea()

dbSelectArea("SX3")
dbSeek("SQV")
While !Eof() .And. (X3_ARQUIVO == "SQV")
	If X3_PROPRI == "U"
		Aadd(aFields,X3_CAMPO)
	EndIf
	dbSkip()
EndDo

RestArea(aSaveArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs060Grava ³ Autor ³ Cristina Ogura       ³ Data ³ 14.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza os arquivos SQV.                   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs060Grava()     				                       	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA060   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060Grava()
Local cFator	:= M->QV_FATOR
Local cDescFat 	:= AllTrim(M->QV_DESCFAT)
Local nSeq 		:= 0
Local nPosGrau	:= GdFieldPos("QV_GRAU")
Local nPosDGrau	:= GdFieldPos("QV_DESCGRA")
Local cFil      := ""
Local nx        := 0
Local ny		:= 0
Local lFound 	:= .F.
Local cGrau     := ""
Local nCont		:= 0
Local nI        := 0
Local cGrupo	:= ""

//Atualiza DESCFAT para gravar sem espaços no inicio do campo.
M->QV_DESCFAT := AllTrim(M->QV_DESCFAT)

If nOpcao == 5		//Exclusao
 	For nx := 1 to Len(aCols)
		cGrau := aCols[nx][nPosGrau]
		If !Cs060Grau(cFator,cGrau)				// Exclusao
			Return .F.
		EndIf
	Next nx

	Cs060Dele(cFator)

ElseIf 	nOpcao == 3							// Inclusao
	nSeq := 0
	For nx = 1 to Len(aCols)
		If !aCols[nx][Len(aCols[nx])]		// Nao for Deletado
			nSeq++
			RecLock("SQV",.T.)
				For ny := 1 to Len(aHeader)
					If 	aHeader[ny][10] != "V"
						cVar := Trim(aHeader[ny][2])
						Replace &cVar With aCols[nx][ny]
					EndIf
				Next ny

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Enchoice: Contemplando a Gravacao de outros campos criados pelo Usuario³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nI := 1 To FCount()
					If GdFieldPos(FieldName(nI)) == 0
						If ( FieldName(nI) == "QV_FILIAL" )
							FieldPut(nI, cFilial)
						Else
							FieldPut(nI, M->&(FieldName(nI)))
						EndIf
					Endif
				Next nI

				Replace QV_SEQ		WITH StrZero(nSeq,2)
			MsUnlock()
		EndIf
	Next nx

ElseIf nOpcao == 4								// Alteracao
	cFil := xFilial("SQV")
	dbSelectArea("SQV")
	dbSetOrder(1)
	nSeq := 0
	For nx := 1 To Len(aCols)
		cGrau := aCols[nx][nPosGrau]
		If !aCols[nx][Len(aCols[nx])]		// Deletado
			nSeq++
			If	dbSeek(cFil+cFator+cGrau)
				RecLock("SQV",.F.)
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava o Novo Grau na Graduacao dos Fatores SQ2 Independente// do Grupo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SQ2")
				SQ2->(DbSetOrder(1))
				SQ2->(DbGoTop())
				cGrupo:= ""

				While SQ2->(!Eof())
					If cFil+cFator == xFilial("SQ2",SQ2->Q2_FILIAL)+SQ2->Q2_FATOR
						If cGrupo <> SQ2->Q2_GRUPO
							cGrupo:= SQ2->Q2_GRUPO
							SQ2->(RecLock("SQ2",.T.))
							Replace Q2_FILIAL	With cFil
							Replace Q2_GRUPO	With cGrupo
							Replace Q2_FATOR	With cFator
							Replace Q2_GRAU		With cGrau
							Replace Q2_DESC		With aCols[nx][nPosDGrau]
							SQ2->(MsUnlock())
						EndIf
					EndIf
					SQ2->(Dbskip())
				EndDo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava o Novo Grau na Graduacao dos Fatores SQN Independente// do Grupo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SQN")
				SQN->(DbSetOrder(1))
				SQN->(DbGoTop())
				cGrupo:= ""

				While SQN->(!Eof())
					If cFil+cFator == xFilial("SQN",SQN->QN_FILIAL)+SQN->QN_FATOR
						If cGrupo <> SQN->QN_GRUPO
							cGrupo:= SQN->QN_GRUPO
							SQN->(RecLock("SQN",.T.))
							Replace QN_FILIAL	With cFil
							Replace QN_GRUPO	With cGrupo
							Replace QN_FATOR	With cFator
							Replace QN_GRAU		With cGrau
							SQN->(MsUnlock())
						EndIf
					EndIf
					SQN->(Dbskip())
				EndDo

				dbSelectArea("SQV")
				dbSetOrder(1)

				RecLock("SQV",.T.)
			EndIf

			For ny := 1 to Len(aHeader)
				If 	aHeader[ny][10] != "V"
					cVar := Trim(aHeader[ny][2])
					Replace &cVar WITH aCols[nx][ny]
				EndIf
			Next ny

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Enchoice: Contemplando a Gravacao de outros campos criados pelo Usuario³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nI := 1 To FCount()
					If GdFieldPos(FieldName(nI)) == 0
						If ( FieldName(nI) == "QV_FILIAL" )
							FieldPut(nI, cFilial)
						Else
							FieldPut(nI, M->&(FieldName(nI)))
						EndIf
					Endif
				Next nI

				Replace QV_SEQ		WITH StrZero(nSeq,2)


			Cs060Atu(cFator,cDescFat,cGrau,aCols[nx][nPosDGrau])

			MsUnlock()
		Else
            nCont := 0
			For ny := 1 To Len(aCols)
				If ( cGrau == aCols[ny][nPosGrau] ) .And. ( !aCols[ny][Len(aCols[ny])] )
					nCont++
				EndIf
			Next ny
			If nCont == 0
				If dbSeek(cFil+cFator+cGrau)
					RecLock("SQV",.F.)
						dbDelete()
					MsUnlock()
				EndIf
			EndIf

		EndIf
	Next nx
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs060LOk ³ Autor ³ Cristina Ogura        ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da linha da getdados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060LOk()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA060  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060LOk()
Local nPosGrau	:= GdFieldPos("QV_GRAU")
Local nPosDGrau	:= GdFieldPos("QV_DESCGRA")
Local lRet 		:= .T.
Local nx        := 0

If !aCols[n,Len(aCols[n])]
	If nPosGrau >0 .And. Empty(aCols[n][nPosGrau])
		Help("",1,"Cs060GRAU")		// Falta digitar o grau dos fatores
		lRet := .F.
	ElseIf nPosDGrau >0 .And. Empty(aCols[n][nPosDGrau])
		Help("",1,"Cs060DGRAU")		// Falta digitar a descricao do grau
		lRet := .F.
	EndIf

	If lRet
		For nx:=1 To Len(aCols)
			If aCols[n][nPosGrau] == aCols[nx][nPosGrau] .And.;
				!aCols[nx][Len(aCols[nx])] .And.;
				n != nx
				Help(" ",1,"Cs060JAEX")	// Codigo do grau ja existe
				lRet := .F.
				Exit
			EndIf
		Next nx
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs060TOK ³ Autor ³ Cristina Ogura        ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida toda a getdados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A060RsTOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA060  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060TOk()
Local lDel 		:= .T.
Local nPosGrau	:= GdFieldPos("QV_GRAU")
Local nPosDGrau	:= GdFieldPos("QV_DESCGRA")
Local cFator	:= M->QV_FATOR
Local cGrau		:= ""
Local nx 		:= 0

If !aCols[n,Len(aCols[n])]
	If nPosGrau >0 .And. Empty(aCols[n][nPosGrau])
		Help("",1,"Cs060GRAU")		// Falta digitar o grau dos fatores
		Return .F.
	ElseIf nPosDGrau >0 .And. Empty(aCols[n][nPosDGrau])
		Help("",1,"Cs060DGRAU")	// Falta digitar a descricao do grau
		Return .F.
	EndIf
EndIf

// Verificar se todos os graus estao deletados
For nx := 1 To Len(aCols)
	If 	!aCols[nx][Len(aCols[nx])]
		lDel := .F.
		Exit
	EndIf
Next nx

If 	lDel
	Help("",1,"Cs060TDel")
	Return .F.
EndIf

// Verificando del na getdados
For nx := 1 To Len(aCols)
	cGrau := aCols[nx][nPosGrau]
	If aCols[nx][Len(aCols[nx])] .And. !Cs060Grau(cFator,cGrau)
		Return .F.
	EndIf
Next nx

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs060aCols³ Autor ³ Cristina Ogura        ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta o acols da getdados                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs060aCols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA060   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060aCols(nQual,aAuxCols,nOpcx,cAlias,cCond,cChave,aAuxHeader,nOrdem)
Local nAcols	:= 0
Local nCntFor 	:= 0
Local nUsado  	:= Len(aAuxHeader)
Local nAuxOrdem := 0
Local nAuxReg  	:= 0

dbSelectArea(cAlias)
nAuxOrdem 	:= IndexOrd()
nAuxReg		:= RecNo()

If 	nQual == 1
	dbSetOrder(nOrdem)
	If dbSeek(cCHAVE)
	    While !Eof() .And. &cCond == cChave
			aadd(aAuxCols,Array(nUsado+If(nOpcx != 2 .AND. nOpcx != 5, 1, 0)))
			nAcols := Len(aAuxCols)

			For nCntFor := 1 To Len(aAuxHeader)
				If ( aAuxHeader[nCntFor][10] != "V")
					aAuxCols[nAcols][nCntFor] := FieldGet(FieldPos(aAuxHeader[nCntFor][2]))
				Else
					aAuxCols[nAcols][nCntFor] := CriaVar(aAuxHeader[nCntFor][2],.T.)
				EndIf
			Next nCntFor

			If nOpcx != 2 .And. nOpcx != 5
				aAuxCols[nAcols][nUsado+1] := .F.
			EndIf

			dbSelectArea(cAlias)
			dbSkip()
		EndDo
	Else
		dbSelectArea("SX3")
		dbSeek(cAlias)
		aadd(aAuxCols,Array(nUsado+If(nOpcx!=2.And.nOpcx!=5,1,0)))
		nAcols := Len(aAuxCols)
		For nCntFor := 1 To Len(aAuxHeader)
			If 	X3_TIPO == "C" .And. Trim(aAuxHeader[nCntFor][2]) $ "QV_GRAU"
				aAuxCols[1][nCntFor] := Repl("0",aAuxHeader[nCntFor][4]-1)+"1"
			Else
				aAuxCols[nAcols][nCntFor] := CriaVar(aAuxHeader[nCntFor][2],.T.)
			EndIf
		Next nCntFor
		If nOpcx != 2 .And. nOpcx != 5
			aAuxCols[1][nUsado+1] := .F.
		EndIf
	EndIf
ElseIf nQual ==2
	dbSetOrder(nOrdem)
	dbGotop()
    While !Eof()

    	cDescGrupo	:= TrmDesc("SQ0",Q2_GRUPO,"SQ0->Q0_DESCRIC")
    	cDescFator	:= TrmDesc("SQ1",Q2_GRUPO+Q2_FATOR,"SQ1->Q1_DESCSUM")

		aadd(aAuxCols,Array(nUsado))
		nAcols := Len(aAuxCols)
		For nCntFor := 1 To Len(aAuxHeader)
			If 	Alltrim(aAuxHeader[nCntFor][2]) == "XX_ATU"
				aAuxCols[nAcols][nCntFor] := STR0009	//"NAO"
			ElseIf 	Alltrim(aAuxHeader[nCntFor][2]) == "Q0_DESCRIC"
				aAuxCols[nAcols][nCntFor] := cDescGrupo
			ElseIf Alltrim(aAuxHeader[nCntFor][2]) == "Q1_DESCSUM"
				aAuxCols[nAcols][nCntFor] := cDescFator
			ElseIf 	Alltrim(aAuxHeader[nCntFor][2]) == "QV_FATOR"
				aAuxCols[nAcols][nCntFor] := Space(Len("QV_FATOR"))
			ElseIf	Alltrim(aAuxHeader[nCntFor][2]) == "QV_GRAU" 		.Or.;
					Alltrim(aAuxHeader[nCntFor][2]) == "QV_DESCFAT" 	.Or.;
					Alltrim(aAuxHeader[nCntFor][2]) == "QV_DESCGRA"
				aAuxCols[nAcols][nCntFor] := CriaVar(aAuxHeader[nCntFor][2],.F.)
			Else
				aAuxCols[nAcols][nCntFor] := FieldGet(FieldPos(aAuxHeader[nCntFor][2]))
			EndIf
		Next nCntFor
		dbSelectArea(cAlias)
		dbSkip()
	EndDo
EndIf

// Volto a posicao do SQV
dbSelectArea("SQV")
dbSetOrder(nAuxOrdem)
dbGoto(nAuxReg)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs060Dele ³ Autor ³ Cristina Ogura        ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de exclusao dos fatores gerais de avaliacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs060Dele()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA060   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060Dele(cFator)
Local lChkDelOk	:= .F.
Local cFil:= xFilial("SQV")

dbSelectArea("SQV")
dbSetOrder(1)
dbSeek(cFil+cFator)

lChkDelOk  := ChkDelRegs(	"SQV"				,;	//01 -> Alias do Arquivo Principal
							NIL					,;	//02 -> Registro do Arquivo Principal
							NIL					,;	//03 -> Opcao para a AxDeleta
							NIL					,;	//04 -> Filial do Arquivo principal para Delecao
							NIL					,;	//05 -> Chave do Arquivo Principal para Delecao
							NIL					,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
							NIL					,;	//07 -> Mensagem para MsgYesNo
							NIL					,;	//08 -> Titulo do Log de Delecao
							NIL					,;	//09 -> Mensagem para o corpo do Log
							NIL				 	,;	//10 -> Se executa AxDeleta
							NIL					,;	//11 -> Se deve Mostrar o Log
							NIL					,;	//12 -> Array com o Log de Exclusao
							NIL		 			,;	//13 -> Array com o Titulo do Log
							NIL					,;	//14 -> Bloco para Posicionamento no Arquivo
							NIL					,;	//15 -> Bloco para a Condicao While
							NIL					,;	//16 -> Bloco para Skip/Loop no While
							.T.					,;	//17 -> Verifica os Relacionamentos no SX9
							Nil				 	;	//18 -> Alias que nao deverao ser Verificados no SX9
					    )

If !lChkDelOk
	Return Nil
Endif

// Apaga os dados do SQV
dbSelectArea("SQV")
dbSetOrder(1)
dbSeek(cFil+cFator)
While !Eof() .And. QV_FILIAL+QV_FATOR == cFil+cFator
	RecLock("SQV",.F.)
		dbDelete()
	MsUnlock()
	dbSkip()
EndDo

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs060Atu  ³ Autor ³ Cristina Ogura        ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza dados do SQ1 e SQ2 quando for alteracao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs060Atu()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA060   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060Atu(cFator,cDescFat,cGrau,cDescGrau)
Local aSaveArea	:= GetArea()
Local cFilSQ1	:=	xFilial("SQ1")
Local cCond		:=	cFilSQ1+cFator
Local lGrava	:=	.T.


dbSelectArea("SQ1")
dbSetOrder(3)
If 	dbSeek(xFilial("SQ1")+cFator)

	Do While ( lGrava	:=	(cFilSQ1+cFator == cCond) .AND. (SQ1->(!EOF())) )

    	If 	!(Alltrim(SQ1->Q1_DESCSUM) == Alltrim(cDescFat))
    		RecLock("SQ1",.F.)
				Replace Q1_DESCSUM	WITH	cDescFat
			SQ1->( MsUnlock() )
		EndIf

		SQ1->( dbSkip() )
		cCond	:=	cFilSQ1+SQ1->Q1_FATOR

	EndDo

EndIf

dbSelectArea("SQ2")
dbSetOrder(2)

If 	dbSeek(xFilial("SQ2")+cFator+cGrau)
   	Do While (!EOF() . AND. (xFilial("SQ2")+cFator+cGrau) == (SQ2->Q2_FILIAL+SQ2->Q2_FATOR+SQ2->Q2_GRAU))
		If 	Alltrim(SQ2->Q2_DESC) != Alltrim(cDescGrau)
			RecLock("SQ2",.F.)
				Replace Q2_DESC	WITH cDescGrau
			MsUnlock()
		EndIf
  		SQ2->( dbSkip() )
	EndDo
EndIf

RestArea(aSaveArea)


Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs060Comp³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de compatibilizacao do SQ1 e SQ2 para SQV.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CSA060Comp(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo 								  ³±±
±±³ 		 ³ ExpN1 = Numero do registro							   	  ³±±
±±³ 		 ³ ExpN2 = Numero da opcao Selecionada					   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA060  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060Comp(cAlias,nReg,nOpcx)
Local aKeys		:= GetKeys()
Local aArea		:= GetArea()
Local lTrDel 	:= .F.
Local aAlter	:= {}
Local aAuxHeader:= {}
Local aAuxCols	:= {}
Local nGrava:=0
Local nRegMaxSQ2:= ( 36 ^ GetSx3Cache("Q2_GRAU","X3_TAMANHO") )

Local aAdv11Size	:= {}
Local aInfo11AdvSize:= {}
Local aObj11Size	:= {}
Local aObj11Coords	:= {}
Local oDlg1

Private aHeader	:= {}
Private aCols	:= {}
Private o1Get

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SQV",aIndexSQV,.T.)
aIndexSQV := {}
dbGoto(nReg)

dbSelectArea("SQV")
dbsetorder(1)
If 	Eof()
	Help("",1,"Cs060Comp")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Eval(bFiltraBrw)

	RestArea(aArea)

	Return .F.
EndIf

AVISO(STR0011,STR0012,{STR0013})	//"Aviso"###"Para maior agilidade e entendimento, sugere-se tirar o relatorio e preenche-lo antes de fazer a compatibilizacao."###"Ok"

// Monta aHeader da GetDados
Cs060Header(@aAuxHeader,@aAlter)

// Monta o aCols da GetDados
MsAguarde( {||Cs060aCols(2,@aAuxCols,nOpcx,"SQ2",,,aAuxHeader,1)},STR0014 ) //"Aguarde..."###" Montando tela de Reserva"

aCols 	:= aAuxCols
aHeader	:= aAuxHeader

If 	Len(aCols) == 0
	Help("",1,"Cs060NOCOMP")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Eval(bFiltraBrw)

	RestArea(aArea)

	Return .F.
EndIf

SETAPILHA()

aAdv11Size		:= MsAdvSize()
aInfo11AdvSize	:= { aAdv11Size[1] , aAdv11Size[2] , aAdv11Size[3] , aAdv11Size[4] , 5 , 5 }
aAdd( aObj11Coords , { 000 , 000 , .T. , .T. } )
aAdd( aObj11Coords , { 000 , 013 , .T. , .F. } )
aObj11Size		:= MsObjSize( aInfo11AdvSize , aObj11Coords )

DEFINE MSDIALOG oDlg1 FROM	aAdv11Size[7],0 TO aAdv11Size[6],aAdv11Size[5] TITLE cCadastro PIXEL

	@ aObj11Size[2,1],aObj11Size[2,2] SAY STR0015	PIXEL				//"<F4> no campo de Fator Geral para selecionar o Fator e Grau de Avaliacao Geral correspondente"
	o1Get := MSGetDados():New(aObj11Size[1,1],aObj11Size[1,2],aObj11Size[1,3],aObj11Size[1,4],nOpcx,"Cs060L2Ok","Cs060T2Ok","",lTrDel,aAlter,1,,nRegMaxSQ2,,,,,oDlg1)
	o1Get:oBrowse:Default()

	SetKEY(VK_F4,{|| Cs060F4()})



ACTIVATE DIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,	{|| If(o1Get:TudoOk(),(nGrava:= 1,RestKeys(aKeys,.T.),oDlg1:End()),.F.) },;
									{|| nGrava:=2,RestKeys(aKeys,.T.),oDlg1:End()},,;
									{{"COLINC",{||Cs060Incl(cAlias,nReg,nOpcx)},;
            						OeMToAnsi(STR0016),OeMToAnsi(STR0039)}}) //"Inclusao Fatores Gerais"#"Inclusão"

SETAPILHA()


If 	nGrava == 1
	Begin Transaction
		Cs060GravComp()
		EvalTrigger()
	End Transaction
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bFiltraBrw)
dbGoTo(nReg)

RestArea(aArea)
RestKeys(aKeys,.T.)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs060Header ³ Autor ³ Cristina Ogura     ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o aheader da compatibilizacao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060Header()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA060  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060Header(aAuxHeader,aAlter)
Local aCpoSX3 	:= {}
Local nx		:= 0
Local nTamCpoGr := GetSx3Cache("QV_GRAU","X3_TAMANHO")

aHeader		:= {}
aAuxHeader	:= {}

// Campos que podem ser alterados na getdados
Aadd(aAlter,"QV_FATOR")
Aadd(aAlter,"QV_GRAU")

// Coluna que indica quais foram preenchidos
Aadd(aAuxHeader,{OemtoAnsi(STR0017),"XX_ATU"	,"@!",03,0,"","û","C","","" } )	//"Atualiz"

Aadd(aCpoSX3,"Q2_GRUPO")
Aadd(aCpoSX3,"Q0_DESCRIC")
Aadd(aCpoSX3,"Q2_FATOR")
Aadd(aCpoSX3,"Q1_DESCSUM")
Aadd(aCpoSX3,"Q2_GRAU")
Aadd(aCpoSX3,"Q2_DESC")

For nx := 1 To Len(aCpoSX3)

	dbSelectArea("SX3")
	dbSetOrder(2)
	If	dbSeek(aCpoSX3[nx]) .And. X3USO(x3_usado) .AND. cNivel >= X3_NIVEL
		Aadd(aAuxHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
							x3_tamanho, x3_decimal, x3_valid,;
							x3_usado, x3_tipo, x3_arquivo, x3_context } )
	EndIf

Next nx

Aadd(aAuxHeader,{OemtoAnsi(STR0018),"QV_FATOR"		,"@E 99",02,0,"Cs060Valid(1)","û","C","","" } )	//"Fator Geral"
Aadd(aAuxHeader,{OemtoAnsi(STR0019),"QV_DESCFAT"	,"@!",30,0,"","û","C","","" } )					//"Descr Fator"
Aadd(aAuxHeader,{OemtoAnsi(STR0020),"QV_GRAU" 		,"@E 99",nTamCpoGr,0,"Cs060Valid(2)","û","C","","" } )	//"Grau Geral"
Aadd(aAuxHeader,{OemtoAnsi(STR0021),"QV_DESCGRA"	,"@!",30,0,"","û","C","","" } )					//"Descr Grau"

dbSelectArea("SX3")
dbSetOrder(1)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs060T2Ok   ³ Autor ³ Cristina Ogura     ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao que verifica todo o acols da compatiblizacao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060T2Ok()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA060  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060L2OK()
Local nPosNovFat	:= GdFieldPos("QV_FATOR")
Local nPosNovGrau	:= GdFieldPos("QV_GRAU")
Local nPosGrupo		:= GdFieldPos("Q2_GRUPO")
Local nPosFator		:= GdFieldPos("Q2_FATOR")
Local nx			:= 0

If 	nPosNovGrau > 0 .And. Empty(aCols[n][nPosNovGrau])
	Help("",1,"Cs060GRAU")		// Falta digitar o grau dos fatores
	Return .F.
EndIf

For nx:=1 To Len(aCols)
	If 	aCols[n][nPosNovFat] == aCols[nx][nPosNovFat] 	.And.;
		aCols[n][nPosNovGrau] == aCols[nx][nPosNovGrau] 	.And.;
		aCols[n][nPosGrupo] == aCols[nx][nPosGrupo] .And. ;
		aCols[n][nPosFator] == aCols[nx][nPosFator] .And.;
		nx != n .And. !Empty(aCols[n][nPosNovFat]) .And. !Empty(aCols[n][nPosNovGrau])
		Help("",1,"Cs060Ver")		// Verifique pois ja existe este fator e grau cadastrado
		Return .F.
	EndIf
Next nx

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs060T2Ok   ³ Autor ³ Cristina Ogura     ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao que verifica todo o acols da compatiblizacao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060T2Ok()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA060  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060T2OK()
Local nPosFator	:= GdFieldPos("QV_FATOR")
Local nPosGrau	:= GdFieldPos("QV_GRAU")
Local nPosSQ2Fat:= GdFieldPos("Q2_FATOR")
Local cFatorSQ2	:= ""
Local cFatorSQV	:= ""
Local nx		:= 0

For nx := 1 To Len(aCols)
	If 	Empty(aCols[nx][nPosFator]) .Or. ;
		Empty(aCols[nx][nPosGrau])
		Help("",1,"Cs060BRANCO")
		Return .F.
	EndIf

	If 	Alltrim(cFatorSQ2)!= Alltrim(aCols[nx][nPosSQ2Fat])
		cFatorSQ2 := aCols[nx][nPosSQ2Fat]
		cFatorSQV := aCols[nx][nPosFator]
	EndIf

	If 	Alltrim(cFatorSQV) != Alltrim(aCols[nx][nPosFator])
		AVISO(STR0036,STR0037,{STR0038})	//"Aviso"###"O mesmo fator de Avaliacao nao pode ter mais de um Codigo Fator de compatibilizacao"###"Sair"
		Return .F.
	EndIf

Next nx

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs060F4     ³ Autor ³ Cristina Ogura     ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao que faz o tratamento do F4 na compatiblizacao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060F4() 	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA060  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060F4()
Local aKeys		:= GetKeys()
Local oDlgB, oLbx , bOK, bCancel
Local cCadastro	:= STR0022			//"Selecione o Fator e Grau correspondente"
Local aLbx		:= {}
Local cVar		:= ReadVar()
Local cFator	:= ""
Local cGrau		:= ""
Local cDescFat	:= ""
Local cDescGrau	:= ""
Local nPosFator	:= GdFieldPos("QV_FATOR")
Local nPosGrau	:= GdFieldPos("QV_GRAU")
Local nPosDFator:= GdFieldPos("QV_DESCFAT")
Local nPosDGrau	:= GdFieldPos("QV_DESCGRA")
Local nPosAtu  	:= GdFieldPos("XX_ATU")

Local aAdv12Size	:= {}
Local aInfo12AdvSize:= {}
Local aObj12Size	:= {}
Local aObj12Coords	:= {}

Private oOk 	:= LoadBitmap( GetResources(), "Enable" )
Private oNo 	:= LoadBitmap( GetResources(), "LBNO" )
Private o1Ok 	:= LoadBitmap( GetResources(), "LBOK" )

If 	Alltrim(cVar) != "M->QV_FATOR"
	Return .F.
EndIf

Cs060SQV(@aLbx)

SETAPILHA()
aAdv12Size		:= MsAdvSize()
aInfo12AdvSize	:= { aAdv12Size[1] , aAdv12Size[2] , aAdv12Size[3] , aAdv12Size[4] , 5 , 5 }
aAdd( aObj12Coords , { 000 , 000 , .T. , .T. , .T. } )
aObj12Size		:= MsObjSize( aInfo12AdvSize , aObj12Coords )

DEFINE MSDIALOG oDlgB FROM	aAdv12Size[7],0 TO aAdv12Size[6],aAdv12Size[5] TITLE cCadastro OF oMainWnd PIXEL
	@  aObj12Size[1,1],aObj12Size[1,2] LISTBOX oLbx FIELDS;
		  	HEADER	"",;
						OemtoAnsi(STR0023),;	//"Fator"
						OemtoAnsi(STR0024),;	//"Descricao do Fator"
						OemtoAnsi(STR0025),;	//"Grau"
						OemtoAnsi(STR0026) SIZE aObj12Size[1,3],aObj12Size[1,4] PIXEL 	//"Descricao Grau"
	oLbx:bldblclick :={|nRow, nCol| Cs060Click(oLbx:nAt,@aLbx,oLbx)}
	oLbx:SetArray(aLbx)
	oLbx:bLine:= {||{ 	If(aLbx[oLbx:nAt,1],o1Ok,oNo),;
						aLbx[oLbx:nAt,2],;
						aLbx[oLbx:nAt,3],;
						aLbx[oLbx:nAt,4],;
						aLbx[oLbx:nAt,5]}}

 	bOK		:= {||Cs060Marcado(aLbx,@cFator,@cGrau,@cDescFat,@cDescGrau),RestKeys(aKeys,.T.),oDlgB:End()}
    bCancel	:= {||RestKeys(aKeys,.T.),oDlgB:End()}

ACTIVATE DIALOG oDlgB ON INIT EnchoiceBar(oDlgB,bOK, bCancel)     CENTERED

SETAPILHA()

M->QV_FATOR				:= cFator
aCols[n][nPosFator]		:= cFator
aCols[n][nPosGrau] 		:= cGrau
aCols[n][nPosDFator]	:= AllTrim(cDescFat)
aCols[n][nPosdGrau] 	:= cDescGrau
aCols[n][nPosAtu] 		:= STR0027		//"SIM"

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs060SQV    ³ Autor ³ Cristina Ogura     ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o listbox com os dados do SQV para mostrar na tela.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060SQV() 	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA060  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060SQV(aLbx)
Local aSaveArea	:= GetArea()

dbSelectArea("SQV")
dbSetOrder(1)
dbGotop()
While !Eof()
	Aadd(aLbx,{.F.,SQV->QV_FATOR,Subst(SQV->QV_DESCFAT,1,30),SQV->QV_GRAU,Substr(SQV->QV_DESCGRA,1,30),SQV->QV_FATOR,SQV->QV_DESCFAT})
    dbSkip()
EndDo

RestArea(aSaveArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs060Click  ³ Autor ³ Cristina Ogura     ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao que faz o tratamento do click no F4                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060Click()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA060  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060Click(nQual,aLbx,oLbx)
Local nx	:= 0

For nx := 1 To Len(aLbx)
	If 	nx != nQual
		aLbx[nx][1] := .F.
	Else
		aLbx[nx][1] := .T.
	EndIf
Next nx
oLbx:Refresh()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs060Valid  ³ Autor ³ Cristina Ogura     ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tratamento dos valores no campo de Fator e Grau.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060Valid()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA060  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060Valid(nQual)
Local lRet		:= .T.
Local nReg		:= 0
Local cVar		:= Alltrim(&(ReadVar()))
Local nPosFator	:= 0
Local nPosGrau 	:= 0
Local nPosDFat	:= 0
Local nPosDGrau	:= 0
Local nPosAtu	:= 0

dbSelectArea("SQV")
dbSetOrder(1)
nReg := RecNo()

If 	nQual == 1		// Fator Geral
	nPosDFat 	:= GdFieldPos("QV_DESCFAT")
	If 	!dbSeek(xFilial("SQV")+cVar)
		Help("",1,"Cs060NFATOR")		// Nao existe este fator geral.
		lRet := .F.
	EndIf
	If 	lRet
		aCols[n][nPosDFat]	:= AllTrim(SQV->QV_DESCFAT)
	EndIf
ElseIf nQual ==2	// Grau do Fator Geral
	nPosFator := GdFieldPos("QV_FATOR")
	nPosDGrau := GdFieldPos("QV_DESCGRA")
	nPosAtu   := GdFieldPos("XX_ATU")

	If 	Empty(aCols[n][nPosFator])
		Help("",1,"Cs060NFATOR")
		lRet := .F.
	EndIf

	If 	lRet .And. nPosFator > 0 .And. !dbSeek(xFilial("SQV")+Alltrim(aCols[n][nPosFator])+cVar)
		Help("",1,"Cs060NGRAU")		// Nao existe este grau para este fator.
		lRet := .F.
	EndIf

	If 	lRet
		aCols[n][nPosDGrau]:= SQV->QV_DESCGRA
		aCols[n][nPosAtu]	:= STR0028	//"SIM"
	EndIf
EndIf

dbSelectArea("SQV")
dbSetOrder(1)
dbGoto(nReg)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs060GravComp ³ Autor ³ Cristina Ogura   ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava dados da compatiblizacao no SQ1/SQ2/SQ8/RAF/SQI      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060GravComp()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA060  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060GravComp()
Local nx         	:= 0
Local nPosGrupo		:= GdFieldPos("Q2_GRUPO")
Local nPosFator		:= GdFieldPos("Q2_FATOR")
Local nPosGrau		:= GdFieldPos("Q2_GRAU")
Local nPosDGrupo	:= GdFieldPos("Q0_DESCRIC")
Local nPosDFator	:= GdFieldPos("Q1_DESCSUM")
Local nPosDGrau 	:= GdFieldPos("Q2_DESC")
Local nPosNovFat	:= GdFieldPos("QV_FATOR")
Local nPosNovGrau	:= GdFieldPos("QV_GRAU")
Local nPosNovDFat	:= GdFieldPos("QV_DESCFAT")
Local nPosNovDGrau	:= GdFieldPos("QV_DESCGRA")
Local nAchou		:= 0
Local cFil			:= ""
Local cSQ3Grupo		:= ""
Local cCargo		:= ""
Local aSQ4:={}, aSQ8:={}, aRAF:={}, aSQI:={}

For nx := 1 To Len(aCols)
	If 	nPosGrupo > 0 .And. nPosFator> 0 .And. nPosGrau > 0

		// Alterar no SQ1 - Q1_FATOR e Q1_DESCSUM
		dbSelectArea("SQ1")
		dbSetOrder(1)
		If 	dbSeek(xFilial("SQ1")+aCols[nx][nPosGrupo]+aCols[nx][nPosFator])
			RecLock("SQ1",.F.)
				Replace Q1_FATOR	With 	aCols[nx][nPosNovFator]
				Replace Q1_DESCSUM	With	aCols[nx][nPosNovDFat]
			MsUnLock()
		EndIf

		// Alterar no SQ2 - Q2_FATOR, Q2_GRAU e Q2_DESC
		dbSelectArea("SQ2")
		dbSetOrder(1)
		If 	dbSeek(xFilial("SQ2")+aCols[nx][nPosGrupo]+aCols[nx][nPosFator]+aCols[nx][nPosGrau])
			RecLock("SQ2",.F.)
				Replace Q2_FATOR	With 	aCols[nx][nPosNovFator]
				Replace Q2_GRAU		With	aCols[nx][nPosNovGrau]
				Replace Q2_DESC		With	aCols[nx][nPosNovDGrau]
			MsUnLock()
		EndIf

	EndIf
Next nx

// Alterando os Fatores e Graduacoes do Cargo - SQ4
// Verificar qual Grupo o cargo pertence
dbSelectArea("SQ3")
dbSetOrder(1)
dbGoTop()
While !Eof()

    aSQ4		:= {}
	cSQ3Grupo 	:= SQ3->Q3_GRUPO

	// Alterar no SQ4 - Q4_FATOR e Q4_GRAU
	dbSelectArea("SQ4")
	dbSetOrder(2)
	If 	dbSeek(xFilial("SQ4")+SQ3->Q3_CARGO+SQ3->Q3_CC)
		While !Eof() .And.	SQ4->Q4_FILIAL+SQ4->Q4_CARGO+SQ4->Q4_CC == ;
							xFilial("SQ4")+SQ3->Q3_CARGO+SQ3->Q3_CC

			// Procuro no aCols o Fator e Grau novo
			nAchou :=0
			nAchou := Ascan(aCols,{ |x| 	x[nPosGrupo] = cSQ3Grupo .And.;
											x[nPosFator] = SQ4->Q4_FATOR .And.;
											x[nPosGrau] = SQ4->Q4_GRAU })

			If 	nAchou > 0
				// Salvo os dados antes, pois o FATOR faz parte da chave no SQ4
				Aadd(aSQ4,{RECNO(),aCols[nAchou][nPosNovFat],aCols[nAchou][nPosNovGra]})
			EndIf

			dbSelectArea("SQ4")
			dbSetOrder(2)
			dbSkip()
		EndDo
	EndIf

	// Atualizando o SQ4
	For nx:=1 To Len(aSQ4)
		dbSelectArea("SQ4")
		dbGoto(aSQ4[nx][1])
		RecLock("SQ4",.F.)
			Replace Q4_FATOR		With aSQ4[nx][2]
			Replace Q4_GRAU			With aSQ4[nx][3]
		MsUnlock()
	Next nx

	dbSelectArea("SQ3")
	dbSetOrder(1)
	dbSkip()
EndDo

// Alterando os Fatores e Graduacao dos Funcionarios e suas Referencias - SQ8 e RAF
dbSelectArea("SRA")
dbSetOrder(1)
dbGotop()
While !Eof()

	aSQ8 := {}
	aRAF := {}

	// Buscar no Cadastro de Cargo o Grupo SQ3->Q3_GRUPO
	dbSelectArea("SQ3")
    dbSetOrder(1)

    cCargo := fGetCargo(SRA->RA_MAT)
    If 	dbSeek(xFilial("SQ3")+cCargo)
    	cSQ3Grupo := SQ3->Q3_GRUPO

    	dbSelectArea("SQ8")
    	dbSetOrder(1)
	    If	dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
	    	While !Eof() .And. SQ8->Q8_FILIAL+SQ8->Q8_MAT ==;
								SRA->RA_FILIAL+SRA->RA_MAT

				// Procuro no aCols o Fator e Grau novo
				nAchou :=0
				nAchou := Ascan(aCols,{ |x| 	x[nPosGrupo] = cSQ3Grupo .And.;
												x[nPosFator] = SQ8->Q8_FATOR .And.;
												x[nPosGrau] = SQ8->Q8_GRAU })

				// Alterar no SQ8 - Q8_FATOR e Q8_GRAU
				If 	nAchou > 0
					// Salvo os dados antes, pois o FATOR faz parte da chave no SQ8
					Aadd(aSQ8,{RECNO(),aCols[nAchou][nPosNovFat],aCols[nAchou][nPosNovGra]})
				EndIf

				dbSelectArea("SQ8")
				dbSkip()
			EndDo
	    EndIf

    	dbSelectArea("RAF")
    	dbSetOrder(1)
    	If 	dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
    		While !Eof() .And. RAF->RAF_FILIAL+RAF->RAF_MAT == ;
								SRA->RA_FILIAL+SRA->RA_MAT

				// Procuro no aCols o Fator
				nAchou :=0
				nAchou := Ascan(aCols,{ |x| 	x[nPosGrupo] = cSQ3Grupo .And.;
												x[nPosFator] = RAF->RAF_FATOR })

				// Alterar no RAF - RAF_FATOR
				If 	nAchou > 0
					// Salvo os dados antes, pois o FATOR faz parte da chave no SQ8
					Aadd(aRAF,{RECNO(),aCols[nAchou][nPosNovFat]})
				EndIf

				dbSelectArea("RAF")
				dbSkip()
			EndDo
    	EndIf
	EndIf

	// Alterando pelo RECNO dos arquivos SQ8 e RAF
	For nx:= 1 To Len(aSQ8)
		dbSelectArea("SQ8")
		dbGoto(aSQ8[nx][1])
		RecLock("SQ8",.F.)
			Replace Q8_FATOR		With	aSQ8[nx][2]
			Replace Q8_GRAU			With	aSQ8[nx][3]
		MsUnlock()
	Next nx

	For nx:=1 To Len(aRAF)
		dbSelectArea("RAF")
		dbGoto(aRAF[nx][1])
		RecLock("RAF",.F.)
			Replace RAF_FATOR		With	aRAF[nx][2]
		MsUnlock()
	Next nx

	dbSelectArea("SRA")
	dbSkip()
EndDo

// Alterar na Qualificacao do curriculo os fatores de Avaliacao - SQI
dbSelectArea("SQI")
dbSetOrder(1)
dbGotop()
While !Eof()

	// Procuro no aCols o Fator e Grau novo
	nAchou :=0
	nAchou := Ascan(aCols,{ |x| 	x[nPosGrupo] = SQI->QI_GRUPO .And.;
									x[nPosFator] = SQI->QI_FATOR .And.;
									x[nPosGrau] = SQI->QI_GRAU })

	// Alterar no SQI - QI_FATOR e QI_GRAU
	If 	nAchou > 0
		Aadd(aSQI,{RecNo(),aCols[nAchou][nPosNovFat],aCols[nAchou][nPosNovGra]})
	EndIf

	dbSelectArea("SQI")
	dbSkip()

EndDo

For nx:=1 To Len(aSQI)
	dbSelectArea("SQI")
	dbSetOrder(1)
	dbGoto(aSQI[nx][1])
	RecLock("SQI",.F.)
		Replace QI_FATOR		With	aSQI[nx][2]
		Replace QI_GRAU			With	aSQI[nx][3]
	MsUnlock()
Next nx

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs060Marcado  ³ Autor ³ Cristina Ogura   ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Traz os dados que foram marcados no Listbox                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060Marcado()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA060  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060Marcado(aLbx,cFator, cGrau, cDescFat, cDescGrau)
Local nx

For nx:=1 To Len(aLbx)
	If 	aLbx[nx][1]
		cFator		:= aLbx[nx][6]
		cGrau		:= aLbx[nx][4]
		cDescFat	:= aLbx[nx][7]
		cDescGrau	:= aLbx[nx][5]
		Exit
	EndIf
Next nx

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Cs060Incl³ Autor ³ R.H. - Cristina Ogura ³ Data ³ 02.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de inclusao chamada de dentro da compatibilizacao   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Csr60Imp()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico 											  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060Incl(cAlias,nReg,nOpcx)
inclui := .T.
Cs060Rot(cAlias,nReg,3.0000000000)
inclui := .F.
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Csr060Imp³ Autor ³ R.H. - Cristina Ogura ³ Data ³ 02.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime os fatores de avaliacao da empresas.     		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Csr60Imp()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico 											  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Csr060Imp(cAlias,nReg,nOpcx)
Local cDesc1  	:= STR0029		//"Rela‡„o dos Fatores de Avaliacao e seus graus para serem compatibilizados"
Local cDesc2  	:= STR0030		//"Ser  impresso todos os fatores e graus de avaliacao"
Local cDesc3  	:= ""
Local cString 	:= "SQ0"
Local aOrd		:= {}

Private aReturn  := {STR0031,1,STR0032,2,2,1,"",1 } //"Zebrado"###"Administra‡„o"
Private NomeProg := "COMPATI"
Private aLinha	 := {}
Private nLastKey := 0
Private cPerg	 := ""
Private nOrdem 	 := 1

Private AT_PRG	 := "COMPATI"
Private wCabec0  := 1
Private wCabec1  := STR0033 	//"FATOR DESCRICAO DO FATOR             GRAU DESCRICAO DO GRAU               CODIGO DO NOVO FATOR       CODIGO DO NOVO GRAU
								//    99 123456789012345678901234567890   12 123456789012345678901234567890  12345678901234567890      12345678901234567890
Private Contfl   := 1
Private Li		 := 0
Private nTamanho := "M"
Private TITULO   := STR0034			//" Preencha os CODIGOS GEROS de Fator e Grau "

dbSelectArea("SQV")
If 	Eof()
	Help("",1,"Cs060Comp")
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="COMPATI"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@TITULO,cDesc1,cDesc2,cDesc3,.F.,aOrd)

nOrdem  := aReturn[8]

If 	nLastKey == 27
	Return Nil
EndIf

SetDefault(aReturn,cString)

If 	nLastKey == 27
	Return Nil
EndIf

RptStatus({|lEnd| Cs060ImpC()},TITULO)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CS060Imp ³ Autor ³ R.H. - Cristina Ogura ³ Data ³ 02.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime os quadros de vagas das empresas.          		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Cs060Imp()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico 											  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060ImpC()
Local cGrupo	:= Replicate("!", GetSx3Cache("Q2_GRUPO", "X3_TAMANHO"))
Local cDescGrupo:= ""

dbSelectArea("SQ2")
dbSetOrder(1)
dbGotop()

SetRegua(SQ2->(RecCount()))

While	!Eof()
	IncRegua()

	If cGrupo != SQ2->Q2_GRUPO
	   	cDescGrupo	:= TrmDesc("SQ0",Q2_GRUPO,"SQ0->Q0_DESCRIC")
		cDet	:=  STR0035  + SQ2->Q2_GRUPO + "-"+ cDescGrupo  // "Grupo: "
		IMPR(cDet,"C")
		cGrupo := SQ2->Q2_GRUPO
	EndIf

   	cDescFator	:= TrmDesc("SQ1",Q2_GRUPO+Q2_FATOR,"SQ1->Q1_DESCSUM")

	//"FATOR DESCRICAO DO FATOR             GRAU DESCRICAO DO GRAU               CODIGO DO FATOR GERAL       CODIGO DO GRAU GERAL
	//    99 123456789012345678901234567890   12 123456789012345678901234567890   12345678901234567890       12345678901234567890

	cDet:=	Space(03)+SQ2->Q2_FATOR
	cDet+= 	Space(01)+cDescFator
	cDet+=	Space(03)+SQ2->Q2_GRAU
	cDet+= 	Space(01)+SQ2->Q2_DESC
	cDet+= 	Space(03)+"____________________"
	cDet+= 	Space(07)+"____________________"

	IMPR(cDet,"C")

	dbSkip()
EndDo

//--Termino do Relatorio                                         ³
IMPR("","F")

Set Device To Screen

dbSelectArea("SQ2")
dbSetOrder(1)

If aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel)
EndIf

MS_FLUSH()

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs060Grau ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 09/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verif. se existe Graduacao nos Fat.Grupo antes de excluir. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060Grau(ExpC1,ExpC2)		                        	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Fator                                   	  	  ³±±
±±³			 ³ ExpC2 := Grau                                      	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA060													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs060Grau(cFator,cGrau)
Local aSaveArea	:= GetArea()
Local lRet 		:= .T.
Local nx		:= 0
Local nPosGrau	:= GdFieldPos("QV_GRAU")
Local nCont		:= 0

// Verifica se existe algum Fator de Avaliacao no Grupo
dbSelectArea("SQ2")
dbSetOrder(2)
If dbSeek(xFilial("SQ2")+cFator+cGrau)
	If nOpcao == 3 .Or. nOpcao == 4
		For nx := 1 To Len(aCols)
			If ( cGrau == aCols[nx][nPosGrau] ) .And. ( !aCols[nx][Len(aCols[nx])] )
				nCont++
			EndIf
		Next nx
		If nCont == 0
			Help("",1,"Cs060NPODE")   		// Nao posso excluir este codigo fator pois existem grupos com este fator de avaliacao
			lRet := .F.
		EndIf
	Else
		Help("",1,"Cs060NPODE")   		// Nao posso excluir este codigo fator pois existem grupos com este fator de avaliacao
		lRet := .F.
	EndIf
EndIf

RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SQVGRAUWHEN³ Autor ³ Emerson Grassi Rocha ³ Data ³ 17/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ When do campo QV_GRAU.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SqvGrauWhen()				                        	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 						                               	  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_WHEN do Campo QV_GRAU									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SqvGrauWhen()
Local aSaveArea	:= GetArea()
Local lRet		:= .F.
Local cFator	:= ""
Local nPosFator	:= 0

If Type("M->QV_FATOR") == "U"	//Compatibilizacao
	If ( nPosFator := GdFieldPos("QV_FATOR")  ) > 0
		cFator := aCols[n][nPosFator]
	EndIf
Else
	cFator := M->QV_FATOR
EndIf

If Inclui .Or. Empty(SQV->QV_GRAU)
	lRet := .T.
Else
	dbSelectArea("SQV")
	dbSetOrder(1)
	If !dbSeek(xFilial("SQV")+cFator+M->QV_GRAU)
		lRet := .T.
	EndIf
EndIf

RestArea(aSaveArea)
Return lRet

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³28/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³CSAA060                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()

 Local aRotina :=  {	{ STR0001,"PesqBrw", 0 , 1,,.F.},; 	//"Pesquisar"
                    	{ STR0002,"Cs060Rot", 0 , 2},; //"Visualizar"
                    	{ STR0003,"Cs060Rot", 0 , 3},; //"Incluir"
                    	{ STR0004,"Cs060Rot", 0 , 4},; //"Alterar"
                    	{ STR0005,"Cs060Rot", 0 , 5}}//"Excluir"
Return aRotina
