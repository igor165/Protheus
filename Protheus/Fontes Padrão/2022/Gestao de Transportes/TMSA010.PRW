#Include "PROTHEUS.ch"
#Include "TMSA010.ch"
#INCLUDE "FWMVCDEF.CH"                 

Static lTMA010His := ExistBlock("TMA010HIS")
Static l010TudOk
Static l010MVC
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSA010  ³ Autor ³        Nava           ³ Data ³18.01.2001  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tabela de Frete                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA010()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1- No. da Rotina (Inclusao, Alteracao, Exclusao)         ³±±
±±³          ³ ExpC2- Titulo                                                ³±±
±±³          ³ ExpN1- Categoria da Tabela: 1-Frete a Receber/2-Frete a Pagar³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³ Estrutura do Array de Folders                                ³±±
±±³          ³ [1] -> Tipo "N" , Numero do Folder                           ³±±
±±³          ³ [2] -> Tipo "C" , Titulo do Folder                           ³±±
±±³          ³ [3] -> Tipo "A" , aColsRecno ( Recno() de cada aCols )       ³±±
±±³          ³ [4] -> Tipo "A  , aHeader   da GetDados do Folder            ³±±
±±³          ³ [5] -> Tipo "A" , aCols     da GetDados do Folder            ³±±
±±³          ³ [6] -> Tipo "C" , cLinhaOk  da GetDados do Folder            ³±±
±±³          ³ [7] -> Tipo "C" , cTudoOk   da GetDados do Folder            ³±±
±±³          ³ [8] -> Tipo "O" , oGetDados deste Folder                     ³±±
±±³          ³ [9] -> Tipo "A" , Campos que podem ser alterados             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010(nRotina, cCad, cCateg)

Local aArea      := GetArea()
Local aSavaFol   := Iif( Type("aFolder")  !="U",aClone(aFolder),	Nil)
Local lTM010Brw  := .F.
Local aIndex     := {}
Local bFiltraBrw
Local cFiltro    := ""
Local cFilMbrow  := ""
Local lUsaTabOld := SuperGetMv( "MV_TMSTFO",  .F., .F. )

If (l010MVC := !lUsaTabOld) 
	Private cCadastro
	Private cCatTab
	
	TMSA010A(nRotina, cCad, cCateg)
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva as variaveis utilizadas na GetDados Anterior.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SaveInter()
	
	Private aRotina := MenuDef()
	
	Private aFolder   := {}
	Private nCatTab   := 0
	Private cCadastro := ''
	
	Default cCateg    := StrZero(1, Len(DTL->DTL_CATTAB)) //-- Frete a Receber
	Default cCad      := STR0001 //-- "Tabela de Frete"
	
	cCatTab   := cCateg
	cCadastro := cCad
	
	RestArea(aArea)
	
	DT0->(DbSetOrder(4)) //-- DT0_FILIAL+DT0_CATTAB+DT0_TABFRE+DT0_TIPTAB+DT0_CDRORI+DT0_CDRDES+DT0_CODPRO
		
	If nRotina != Nil
		TMSA010Mnt("DT0",DT0->(RecNo()),nRotina)
	Else
		If ExistBlock("TM010BRW") //-- PE - Permite ao usuario filtrar a mbrowse
			cFiltro := ExecBlock("TM010BRW",.F.,.F.)
			If ValType(cFiltro) == "C" .And. !Empty(cFiltro)
				CursorWait()
				bFiltraBrw := {|| FilBrowse("DT0",@aIndex,@cFiltro) }
				Eval(bFiltraBrw)
				CursorArrow()
				lTM010Brw := .T.
			EndIf
		EndIf
	
		cFilMbrow := "DT0_FILIAL = '" + xFilial("DT0") + "' AND DT0_CATTAB = '" + cCatTab + "'"
		mBrowse( 6,1,22,75,'DT0',,,,,,,,,,,,,,cFilMbrow)
	
		If lTM010Brw
			EndFilBrw("DT0",aIndex)
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura os dados de entrada                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea( aArea )
	
	If !Empty(aSavaFol)
		aFolder := aClone(aSavaFol)
	EndIf
	RestInter()
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010Mnt ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Manutencao da Tabela de Frete                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010Mnt( ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Alias                                               ³±±
±±³          ³ExpC2 - Registro                                            ³±±
±±³          ³ExpC3 - Opcao Selecionada                                   ³±±
±±³          ³ExpL1 - Controla se devera mostrar a tela para escolher o   ³±±
±±³          ³        LayOut.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010Mnt(cAlias,nReg,nOpcx,lMemo)

Local aArea       := GetArea()
Local aAreaDT4    := DT4->( GetArea() )
Local aInfo       := {}
Local aPosObj     := {}
Local aObjects    := {}
Local aSize       := MsAdvSize()
Local aTitles     := {}
Local aPages      := {}
Local aVisual     := {}
Local oDlg , oEnchoice
Local lTudoOk, lRet
Local nGd1 := nGd2 := nGd3 := nGd4 := nLoop := nOpc := 0
Local aAlter 
Local cSeekdt4    := cSeekKey := " "
Local lContHis    := GetMv("MV_CONTHIS",.F.,.T.) //-- Controla Historico da Tabela de Frete
Local nLoop
Local nLinhasItem := 9999 //-- Numero de Itens que podem ser carregados
Local nDel := 0
Local aRecnoDVD := {}
Local nCont     := 0
Local aDT0Stru  := FwFormStruct(2,"DT0")

Private nFolder       := 1
Private aGets         := {}
Private aTela         := {}
Private aHeader       := {}
Private aCols         := {}
Private nOpcao        := nOpcx
Private oFolder       
Private aColsRecnoDTK := {}
Private aColsRecnoDVY := {}
Private aHeaderDTK    := {}
Private aHeaderDVY    := {}
Private aColsDTK      := {}
Private aColsDVY      := {}
Private cTabTarOld    := ''
Private aLayOut       := {}
Private aHeadDW1      := {}
Private aColsDW1      := {}

//-- Variaveis Private para o Calculo de Excedente por subfaixa
Private aHeadDY1      := {}
Private aColsDY1      := {}

Private aSetKey       := {}

cCadastro := IIf( Type("cCadastro")=="U", STR0001 , cCadastro) //"Tabela de Frete"

//-- Se a Categoria da Tabela nao foi definida
If Type("cCatTab") == "U"
	cCatTab := Posicione('DTl',1, xFilial('DTL')+DT0->DT0_TABFRE+DT0->DT0_TIPTAB, 'DTL_CATTAB')
EndIf

If ValType(lMemo) <> "L"
	lMemo := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Condicao de Incluir        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria a Trava com o Nome 'TABMAN'. Se algum usuario estiver incluindo Tabelas de  ³
	//³ Frete, a rotina de 'Gera Tabela de Frete' nao podera ser executada               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LockByName("TABMAN",.T.,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a rotina de 'Gera Tabela de Frete' estiver sendo executada, nao sera permitida³
	//³ a inclusao Manual de Tabela de Frete                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !LockByName("GERTAB",.T.,.F.)
		Help("",1,"TMSA01020") //A Inclusao de Tabelas nao podera ser efetuada, pois existe outro usuario gerando Tabelas de Frete
		UnLockByName("TABMAN",.T.,.F.) //-- Libera Lock
		Return( .F. )
	EndIf
	UnLockByName("GERTAB",.T.,.F.) //-- Libera Lock

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Configuracao da Tabela          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aLayOut := TMSLayOutTab(cCatTab, .T.,,{"15"}) 
	If Len(aLayOut)==0
		//-- Finaliza as Teclas de Atalhos
		TmsKeyOff(aSetKey)
		UnLockByName("TABMAN",.T.,.F.) //-- Libera Lock
		Return( .F. )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Condicao de Alterar/Excluir³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 4 .Or. nOpcx == 5

	//-- O Objetivo deste Ponto de Entrada, e' validar se sera' permitido Alterar/Excluir (independente
	//-- do conteudo do parametro MV_CONTHIS).
	If lTMA010His
		lRet := ExecBlock("TMA010HIS",.F.,.F.,{nOpcx,DT0->DT0_TABFRE,DT0->DT0_TIPTAB}) 
		If ValType(lRet) <> "L"
			lRet:=.T.
		EndIf
		lContHis := lRet
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controla Historico de Tabela            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContHis
		//-- Verifica se a tabela de frete esta em uso por um CTRC, AWB ou cotacao de frete nao cancelada.
		If	TmsTabUso(DT0->DT0_TABFRE,DT0->DT0_TIPTAB,DT0->DT0_CDRORI,DT0->DT0_CDRDES,.T.,cCatTab)
			//-- Finaliza as Teclas de Atalhos
			TmsKeyOff(aSetKey)
			UnLockByName("TABMAN",.T.,.F.) //-- Libera Lock
			Return( .F. )
		EndIf

	EndIf
		
	cTabTarOld := DT0->DT0_TABTAR
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as posicoes da Getdados a partir do folder    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aObjects := {	{ 100, 050, .T., .T. },;
				{ 100, 100, .T., .T. } }
aInfo    := { aSize[1], aSize[2], aSize[3], aSize[4], 5, 5 } 
aPosObj  := MsObjSize( aInfo, aObjects, .T. )

nGd1 := 2
nGd2 := 2
nGd3 := aPosObj[2,3]-aPosObj[2,1]-15 
nGd4 := aPosObj[2,4]-aPosObj[2,2]-4 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Enchoice ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nCont := 1 to Len(aDT0Stru:aFields)	

	//-- Nao mostrar o campo 'Tabela de Tarifa' se a Tabela de Frete for a Pagar
	If cCatTab ==  StrZero(2, Len(DT0->DT0_CATTAB))  .And. GetSX3Cache(aDT0Stru:aFields[nCont][1], "X3_CAMPO") == 'DT0_TABTAR'
		Loop
	EndIf
    AAdd( aVisual, GetSX3Cache(aDT0Stru:aFields[nCont][1], "X3_CAMPO"))

	//-- Verifica se deve limpar o conteudo das variaveis de memoria 
	If !lMemo .And. GetSX3Cache(aDT0Stru:aFields[nCont][1], "X3_CAMPO") $ 'DT0_TABFRE.DT0_TIPTAB.DT0_DESTIP.DT0_DESTAB'
		Loop
	EndIf

	If	( GetSX3Cache(aDT0Stru:aFields[nCont][1], "X3_CONTEXT") == "V"  .Or. Inclui )
		M->&(aDT0Stru:aFields[nCont][1]) := CriaVar(aDT0Stru:aFields[nCont][1])
	Else
		M->&( aDT0Stru:aFields[nCont][1]) := DT0->(FieldGet(FieldPos(aDT0Stru:aFields[nCont][1])))
	EndIf

Next nCont  
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Escolhe Configuracao da Tabela se For Inclusao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 3 .And. lMemo
	If !TMSABrowse( aLayOut, STR0020,,,,.T., { STR0001, STR0021, STR0058 } ) //"Escolha a Configuracao desta Tabela de Frete"###"Tabela de Frete"###"Tipo"###"Descricao"
		//-- Finaliza as Teclas de Atalhos
		TmsKeyOff(aSetKey)
		UnLockByName("TABMAN",.T.,.F.) //-- Libera Lock
		Return( .F. )
	EndIf
	nLoop := Ascan( aLayOut, { |aItem| aItem[1] == .T. } )
	M->DT0_TABFRE := Left( aLayOut[ nLoop ][2], 4 )
	M->DT0_TIPTAB := Left( aLayOut[ nLoop ][3], 2 )
	M->DT0_DESTIP := Tabela("M5", M->DT0_TIPTAB,.F.)
	If DTL->(FieldPos('DTL_DESCRI')) > 0
		M->DT0_DESTAB := Posicione('DTL',1,xFilial('DTL')+M->DT0_TABFRE+M->DT0_TIPTAB,'DTL->DTL_DESCRI')
	EndIf
	If DTL->(FieldPos('DTL_MOEDA')) > 0
		M->DT0_MOEDA := Posicione('DTL',1,xFilial('DTL')+M->DT0_TABFRE+M->DT0_TIPTAB,'DTL_MOEDA')
		If M->DT0_MOEDA == 0
			M->DT0_MOEDA := 1
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Folder   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMSA010Fol( nOpcx )

If Len(aFolder) == 0
	//-- Finaliza as Teclas de Atalhos
	TmsKeyOff(aSetKey)
	UnLockByName("TABMAN",.T.,.F.) //-- Libera Lock
	Return( .F. )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona Titles e Pages ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aeval( aFolder, { | aFolderLine | 	AAdd( aTitles, aFolderLine[2] ), AAdd( aPages,  "AHEADER" ) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem da Tela  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenha Enchoice ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oEnchoice := MsMGet():New( cAlias ,nReg, nOpcx, , , ,aVisual, aPosObj[1], aAlter, 3,,,,,, .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenha Folders  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oFolder := TFolder():New(	aPosObj[2,1],aPosObj[2,2],aTitles,aPages, oDlg,,,,.T.,.F.,;
									aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as GetDados na Ordem INVERSA de Apresentacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nLoop := Len( aFolder ) TO 1 STEP - 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o campo "Item" da GetDados                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFolder := aFolder[nLoop][1]
	aHeader := aClone( aFolder[nLoop][4] )
	aEval(aFolder[nLoop][5], {|x| IIF( Empty(x[GdFieldPos('DT1_ITEM')]), x[GdFieldPos('DT1_ITEM')]:= StrZero(1, Len(DT1->DT1_ITEM)), .T.) })
	aCols   := aClone( aFolder[nLoop][5] )

	//     (              nT, nL, nB, nR, nOpc, cLinhaOk, cTudoOk, cIniCpos,lDeleta, aAlter, nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)		                                   
	aFolder[nLoop][8] := MSGetDados():New(	nGd1,nGd2,nGd3,nGd4,nOpcx,;
															aFolder[nLoop][6],aFolder[nLoop][7],"+DT1_ITEM",nOpcx<>2,aFolder[nLoop][9],,,nLinhasItem,,,,,;
															oFolder:aDialogs[nLoop] )

	Aeval( aCols, { |x|  IIF(nOpcx==3.Or.nOpcx==4, ;
							 AjustaFold(aFolder[nLoop][8],nOpcao,cFolder,Len(aFolder[nLoop][5])) , .T.) } ) 

	aFolder[nLoop][5]:= aClone(aCols)
	aFolder[nLoop][8]:oBrowse:Refresh(.T.)
	If nLoop == 1
		aFolder[nLoop][8]:oBrowse:lDisablePaint := .F.
	Else
		aFolder[nLoop][8]:oBrowse:lDisablePaint := .T.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acerta OBRIGAT da MsGetDados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMSObgGetDados( aFolder[nLoop][8] )

Next nI	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita o Trocador de Folder³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oFolder:bSetOption:={|nAtu| TMSA010Chg( nAtu, oFolder:nOption ) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama Localizador de Folder Ativo ³
//³ Desenha a EnchoiceBar             ³
//³ Ativa Obrigat da Enchoice         ³
//³ Ativa Obrigat das GetDados        ³
//³ Ativa Dialog  Principal           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ACTIVATE MSDIALOG oDlg ON INIT ( TMSA010Loc( nOpcx, oFolder),; 
											TMSA010Bar( oDlg, { ||	lTudoOk := ( 	nOpcx != 2 .And. ;
																								Obrigatorio(aGets,aTela) .And.;
																								TMSA010Ok(oFolder:nOption, nOpcx) ), ;
																			If( lTudoOk .Or. nOpcx == 2, oDlg:End(), Nil ) },;
																			{|| oDlg:End() }, nOpcx ))


If ( lTudoOk ) .And. StrZero(nOpcx,2) $ "03|04|05"

	Begin Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a Gravacao de Tudo    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TMSA010Grv( nOpcx )
		
		If !Empty(aRecnoDVD)
			For nDel := 1 to Len(aRecnoDVD)
					DVD->(dbGoTo(aRecnoDVD[nDel]))
					RecLock('DVD',.F.)
					DVD->(dbDelete())
					DVD->(MsUnLock())		
			Next nDel
		EndIf
			
		If ( __lSX8 )
			ConfirmSX8()
		EndIf
		EvalTrigger()

	End Transaction

	//-- Ponto de Entrada apos gravacao da tabela de frete
	If	ExistBlock('TMA010GRV')
		aAreaAnt := GetArea()
		ExecBlock('TMA010GRV',.F.,.F.,nOpcx)
		RestArea(aAreaAnt)
	EndIf

	If nOpcx == 3  //-- Inclusao
		// Apos a Gravacao, Nao mostrar a Tela para Escolher o LayOut 
		// Manter o conteudo dos campos Tabela / Tipo
		TMSA010Mnt(cAlias,nReg,nOpcx,.F.)
	EndIf

Else
	If ( __lSX8 )
		RollBackSX8()
	EndIf

EndIf

UnLockByName("TABMAN",.T.,.F.) //-- Libera Lock

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a integridade dos dados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnLockAll()
RestArea(aArea)

//-- Finaliza as Teclas de Atalhos
TmsKeyOff(aSetKey)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010Chg ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Troca de Folder                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010Chg(ExpN1,ExpN2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - nTargetFolder - Folder Destino                      ³±±
±±³          ³ExpC2 -  nSourceFolder - Folder Atual                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. se a Troca de Folder foi permitida                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA010                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³ Checa a validacao da Getdados Atual e copia corretamente   ³±±
±±³          ³ aHeader e Acols dos Folders Atual e Destino                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010Chg( nTargetFolder, nSourceFolder )

Local nI
Local lRetorno
Local lEmpty    := .F.
Local aSavFold  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a GetDados nao esta deletada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Acols[1][Len(aHeader)+1]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se os campos obrigatorios estao vazios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Aeval( aFolder[nSourceFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .And. ;
																						Empty( aCols[1][aPosCol[2]] ), ;
																						lEmpty := .T.	, Nil ) } )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se TODOS estiverem vazios e nao sofre modificacao ³
	//³ deleta para passar no 'OBRIGAT'                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lEmpty .And. ! aFolder[nSourceFolder][8]:lChgField
		aCols[1][Len(aHeader)+1] := .T.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a Validacao da GetDados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aSavFold := AClone(aFolder)

If ( lRetorno := aFolder[nSourceFolder][8]:TudoOk() )

	aFolder := AClone(ASavFold)

	aFolder[nSourceFolder][8]:oBrowse:lDisablePaint := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava aHeader e Acols do Afolder com as mudancas     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFolder[nSourceFolder][4] := aClone( aHeader )
	aFolder[nSourceFolder][5] := aClone( aCols )
	n := Max( aFolder[nTargetFolder][8]:oBrowse:nAt,1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava aHeader e Acols a partir do aFolder            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := aClone( aFolder[nTargetFolder][4] )
	aCols   := aClone( aFolder[nTargetFolder][5] )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se os campos obrigatorios estao vazios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lEmpty := .F.
	Aeval( aFolder[nTargetFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .And. ;
																						Empty( aCols[1][aPosCol[2]] ), ;
																						lEmpty := .T.	, Nil ) } )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se TODOS estiverem vazios e nao sofre modificacao ³
	//³ dah RECALL porque esta funcao DELETOU !!          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If	aCols[1][Len(aHeader)+1] .And. lEmpty .And. ;
		! aFolder[nTargetFolder][8]:lChgField
		aCols[1][Len(aHeader)+1] := .F.
	EndIf

	aFolder[nTargetFolder][8]:oBrowse:lDisablePaint := .F.
	aFolder[nTargetFolder][8]:oBrowse:Refresh(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seta Variavel Private nFolder para o Folder Target ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nFolder := nTargetFolder

EndIf

Return( lRetorno )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010Grv ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacao da Enchoice e das GetDados dos Folders             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA010Grv( nOpcx )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA010Grv(nOpcx)

Local nPosItDW1  := 0
Local nPosItem   := 0
Local nPos       := 0
Local nI         := 0
Local nX         := 0
Local n1Cnt      := 0
Local n2Cnt      := 0
Local n3Cnt      := 0
Local cItem      := ''
Local aArea      := GetArea()
Local aAreaDT0   := DT0->(GetArea())
Local bCampo     := { |nCpo| Field(nCpo) }
Local lSubFaixa  := FindFunction("ALIASINDIC") .And. AliasInDic("DW1")
Local lSubExced  := FindFunction("ALIASINDIC") .And. lSubFaixa .and. AliasInDic("DY1")
Local nPosDesPas := Ascan(aHeaderDTK, {|x| AllTrim(x[2]) == 'DTK_CODPAS'})
Local nDesPasDVY := Ascan(aHeaderDVY, {|x| AllTrim(x[2]) == 'DVY_CODPAS'})

If nOpcx == 3 .Or. nOpcx == 4 //-- Inclusao ou Alteracao

	//-- Gravacao da Enchoice
	RecLock( "DT0", nOpcx== 3 )
	For n1Cnt:=1 TO FCount()
		If "FILIAL"$Field(n1Cnt)
			FieldPut(n1Cnt,xFilial("DT0"))
		ElseIf "CATTAB"$Field(n1Cnt)
			FieldPut(n1Cnt,cCatTab)
		Else
			If Type("M->"+FieldName(n1Cnt)) <> "U"
				FieldPut(n1Cnt,M->&(FieldName(n1Cnt)))
			EndIf
		EndIf
	Next n1Cnt
	DT0->(MsUnLock())

	//-- Gravacao dos itens da tabela de frete
	For n1Cnt := 1 To Len(aFolder)
		aHeader  := AClone(aFolder[n1Cnt,4])
		aCols    := AClone(aFolder[n1Cnt,5])
		nPosItem := GDFieldPos("DT1_ITEM")
		//-- Gravacao dos itens da tabela de frete
		For n2Cnt := 1 To Len(aCols)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O aCols NAO devera ser gravado, se for composto por elementos   ³
			//³de uma Tabela de Tarifa de Frete. Caso o elemento do acols tenha³
			//³sido informado (campo Tarifa=='Nao') grava-lo no arquivo DT1.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If GDFieldGet("DT1_TARIFA",n2Cnt) == StrZero(2,Len(DT1->DT1_TARIFA))
				If !GdDeleted(n2Cnt) .And. GDFieldGet('DT1_VALATE',n2Cnt) > 0
					DT1->(DbSetOrder(1)) //-- DT1_FILIAL+DT1_TABFRE+DT1_TIPTAB+DT1_CDRORI+DT1_CDRDES+DT1_CODPRO+DT1_CODPAS+DT1_ITEM
					If !DT1->(MsSeek(xFilial('DT1')+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+aFolder[n1Cnt,1]+aCols[n2Cnt,nPosItem]))
						RecLock("DT1",.T.)
						DT1->DT1_FILIAL := xFilial("DT1")
						DT1->DT1_TABFRE := M->DT0_TABFRE
						DT1->DT1_CDRORI := M->DT0_CDRORI
						DT1->DT1_CDRDES := M->DT0_CDRDES
						DT1->DT1_CODPRO := M->DT0_CODPRO
						DT1->DT1_TIPTAB := M->DT0_TIPTAB
						DT1->DT1_CODPAS := aFolder[n1Cnt,1]
					Else
						RecLock("DT1",.F.)
					EndIf
					For nI := 1 To Len(aHeader)
						If aHeader[nI,10] != 'V'
							DT1->(FieldPut(FieldPos(aHeader[nI,2]),GDFieldGet(aHeader[nI,2],n2Cnt)))
						EndIf
					Next nI
					DT1->(MsUnLock())
					//-- Gravacao das Sub-Faixas por item
					If lSubFaixa
						If (nPos:= Ascan( aColsDW1, { |x| x[1]+x[2] == aFolder[n1Cnt,1] + aCols[n2Cnt,nPosItem] } ) ) > 0
							nPosItDW1 := GDFieldPos("DW1_ITEM",aColsDW1[nPos,4])
							cChave := aFolder[n1Cnt,1] + aCols[n2Cnt,nPosItem]
							For n3Cnt := 1 To Len(aColsDW1[nPos,3])
								cItem := aColsDW1[nPos,3,n3Cnt,nPosItDW1]
								If !GdDeleted(n3Cnt,aColsDW1[nPos,4],aColsDW1[nPos,3])
									DW1->(DbSetOrder(1)) //-- DW1_FILIAL+DW1_TABFRE+DW1_TIPTAB+DW1_CDRORI+DW1_CDRDES+DW1_CODPRO+DW1_CODPAS+DW1_ITEDT1+DW1_ITEM
									If !DW1->(MsSeek(xFilial("DW1")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+aFolder[n1Cnt,1]+aCols[n2Cnt,nPosItem]+cItem))
										RecLock("DW1",.T.)
										DW1->DW1_FILIAL := xFilial("DW1")
										DW1->DW1_TABFRE := M->DT0_TABFRE
										DW1->DW1_TIPTAB := M->DT0_TIPTAB
										DW1->DW1_CDRORI := M->DT0_CDRORI
										DW1->DW1_CDRDES := M->DT0_CDRDES
										DW1->DW1_CODPRO := M->DT0_CODPRO
										DW1->DW1_CODPAS := aFolder[n1Cnt,1]
										DW1->DW1_ITEDT1 := aCols[n2Cnt,nPosItem]
									Else
										RecLock("DW1",.F.)
									EndIf
									For nI := 1 To Len(aColsDW1[nPos,4])
										If aColsDW1[nPos,4,nI,10] != 'V'
											DW1->(FieldPut(FieldPos(aColsDW1[nPos,4,nI,2]),GDFieldGet(aColsDW1[nPos,4,nI,2],n3Cnt,,aColsDW1[nPos,4],aColsDW1[nPos,3])))
										EndIf
									Next
									DW1->(MsUnlock())

									// Calculo do Excedente por Subfaixa
									// Aqui deve ser gravado o Excedente pro subfaixa para cada componente do DW1, na tabela DY0
									If lSubExced
										If (nPosDY1:= Ascan( aColsDY1, { |x| x[1]+x[2] == cChave })) > 0
											nposItemDY1  := Ascan( aColsDY1[1,4],{|e| Alltrim(e[2]) == 'DY1_ITEM'}) 									
											If !GdDeleted(1,aColsDY1[nPosDY1,4],aColsDY1[nPosDY1,3])
												DY1->(DbSetOrder(1)) //-- DY1_FILIAL+DY1_TABFRE+DY1_TIPTAB+DY1_CDRORI+DY1_CDRDES+DY1_CODPRO+DY1_CODPAS+DY1_ITEDT1+DY1_ITEM
												If	!DY1->(MsSeek(xFilial("DY1")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+cChave))
													RecLock("DY1",.T.)
													DY1->DY1_FILIAL := xFilial("DY1")
													DY1->DY1_TABFRE := M->DT0_TABFRE
													DY1->DY1_TIPTAB := M->DT0_TIPTAB
													DY1->DY1_CDRORI := M->DT0_CDRORI
													DY1->DY1_CDRDES := M->DT0_CDRDES
													DY1->DY1_CODPRO := M->DT0_CODPRO
													DY1->DY1_CODPAS := aFolder[n1Cnt,1]
													DY1->DY1_ITEDT1 := aCols[n2Cnt,nPosItem]
												Else
													RecLock("DY1",.F.)
												EndIf
												For nI := 1 To Len(aColsDY1[nPosDY1,4])
													If aColsDY1[nPosDY1,4,nI,10] != 'V'
														DY1->(FieldPut(FieldPos(aColsDY1[nPosDY1,4,nI,2]),aColsDY1[nPosDY1,3,1,nI]))
													EndIf
												Next
												MsUnlock()
											ElseIf GdDeleted(1,aColsDY1[nPosDY1,4],aColsDY1[nPosDY1,3])
												DY1->(DbSetOrder(1)) //-- DY1_FILIAL+DY1_TABFRE+DY1_TIPTAB+DY1_CDRORI+DY1_CDRDES+DY1_CODPRO+DY1_CODPAS+DY1_ITEDT1+DY1_ITEM
												If	DY1->(MsSeek(xFilial("DY1")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+cChave))
													RecLock("DY1",.F.)
													DY1->(DbDelete())
													MsUnlock()
												EndIf
											EndIf
										EndIf
									EndIf

								Else

									// Calculo do Excedente por Subfaixa
									// Exclusao do item de Excedente por subfaixa se foi marcado para exclusao ou se o valor estiver zerado
									If lSubExced
										DY1->(DbSetOrder(1)) //-- DY1_FILIAL+DY1_TABFRE+DY1_TIPTAB+DY1_CDRORI+DY1_CDRDES+DY1_CODPRO+DY1_CODPAS+DY1_ITEDT1+DY1_ITEM
										DY1->(MsSeek(cChaveDY1 := xFilial("DY1")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+cChave))
										Do While DY1->( ! Eof()) .and. cChave == DY1->(xFilial("DY1")+DY1_TABFRE + DY1_TIPTAB + DY1_CDRORI + DY1_CDRDES + DY1_CODPRO + DY1_CODPAS + DY1_ITEDT1)
											RecLock("DY1",.F.)
											DY1->(DbDelete())
											MsUnlock()
											DY1->( DbSkip())
										Enddo
									EndIf

									DW1->(DbSetOrder(1)) //-- DW1_FILIAL+DW1_TABFRE+DW1_TIPTAB+DW1_CDRORI+DW1_CDRDES+DW1_CODPRO+DW1_CODPAS+DW1_ITEDT1+DW1_ITEM
									If DW1->(MsSeek(xFilial("DW1")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+aFolder[n1Cnt,1]+aCols[n2Cnt,nPosItem]+cItem))
										RecLock("DW1",.F.)
										DW1->(DbDelete())
										DW1->(MsUnlock())
									EndIf
								EndIf
							Next n3Cnt
						EndIf
					EndIf
				Else
					//-- Exclusao das sub-faixas
					If lSubFaixa
						// Calculo do Excedente por Subfaixa
						// Exclusao dos itens de Excedente se a subfaixa foi excluida
						If lSubExced
							DY1->(MsSeek(cChaveDY1 := xFilial("DY1")+M->DT0_TABFRE + M->DT0_TIPTAB + M->DT0_CDRORI + M->DT0_CDRDES + M->DT0_CODPRO + aFolder[n1Cnt,1] ))
							Do While DY1->( ! Eof()) .and. cChaveDY1 == DY1->(xFilial("DY1")+DY1_TABFRE + DY1_TIPTAB + DY1_CDRORI + DY1_CDRDES + DY1_CODPRO + DY1_CODPAS)
								RecLock("DY1",.F.)
								DY1->(DbDelete())
								MsUnlock()
								DY1->( DbSkip())
							Enddo
						EndIf
							
						DW1->(DbSetOrder(1)) //-- DW1_FILIAL+DW1_TABFRE+DW1_TIPTAB+DW1_CDRORI+DW1_CDRDES+DW1_CODPRO+DW1_CODPAS+DW1_ITEDT1+DW1_ITEM
						If DW1->(MsSeek(xFilial("DW1")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+aFolder[n1Cnt,1]+aCols[n2Cnt,nPosItem]))
						While DW1->(!Eof()) .And. DW1->DW1_FILIAL + DW1->DW1_TABFRE + DW1->DW1_TIPTAB + DW1->DW1_CDRORI + DW1->DW1_CDRDES + DW1->DW1_CODPRO + DW1->DW1_CODPAS + DW1->DW1_ITEDT1 == ;
								xFilial("DW1") + M->DT0_TABFRE + M->DT0_TIPTAB + M->DT0_CDRORI + M->DT0_CDRDES + M->DT0_CODPRO + aFolder[n1Cnt,1] + aCols[n2Cnt,nPosItem]
								RecLock("DW1",.F.)
								DW1->(DbDelete())
								DW1->(MsUnlock())
								DW1->(DbSkip())
							EndDo
						EndIf
					EndIf
					//-- Exclusao do item da tabela de frete
					DT1->(DbSetOrder(1)) //-- DT1_FILIAL+DT1_TABFRE+DT1_TIPTAB+DT1_CDRORI+DT1_CDRDES+DT1_CODPRO+DT1_CODPAS+DT1_ITEM
					If DT1->(MsSeek(xFilial('DT1')+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+aFolder[n1Cnt,1]+aCols[n2Cnt,nPosItem]))
						RecLock("DT1",.F.)
						DT1->(DbDelete())
						DT1->(MsUnLock())
					EndIf
				EndIf
			EndIf
		Next n2Cnt
	Next n1Cnt

	//-- Gravacao do Complemento da Tabela de Frete (Valores Minimos)
	For n1Cnt := 1 to Len(aColsDTK)
		If !aColsDTK[n1Cnt][Len(aColsDTK[n1Cnt])] // Nao grava o Item se estiver deletado
			//-- So grava DTK se o campo DTK_CALPAS (Calcula Pasta) for igual a "Sim"
			If Len(aColsRecnoDTK) >= n1Cnt .And. DTK->(MsSeek(xFilial("DTK")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+aColsRecnoDTK[n1Cnt] ))
				RecLock("DTK",.F.)
			Else
				RecLock("DTK",.T.)
			EndIf
			For n2Cnt:= 1 to Len(aHeaderDTK)
				If aHeaderDTK[n2Cnt][10] # "V"
					DTK->(FieldPut(FieldPos(Trim(aHeaderDTK[n2Cnt][2])),aColsDTK[n1Cnt][n2Cnt]))
				EndIf
			Next n2Cnt
			DTK->DTK_FILIAL := xFilial("DTK")
			DTK->DTK_TABFRE := M->DT0_TABFRE
			DTK->DTK_CDRORI := M->DT0_CDRORI
			DTK->DTK_CDRDES := M->DT0_CDRDES
			DTK->DTK_TIPTAB := M->DT0_TIPTAB
			DTK->DTK_CODPAS := Posicione( "DT3", 1, xFilial("DT3")+aColsDTK[n1Cnt,nPosDesPas], "DT3_CODPAS" )
			DTK->DTK_CODPRO := M->DT0_CODPRO
			DTK->(MsUnLock())
		Else
			If DTK->(MsSeek(xFilial("DTK")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+aColsRecnoDTK[n1Cnt] ))
				RecLock("DTK",.F.)
				dbDelete()
				DTK->(MsUnLock())
			EndIf
		EndIf
	Next n1Cnt

	//-- Gravacao Base do Componente TDA
	If AliasInDic("DVY")
		For n1Cnt := 1 to Len(aColsDVY)
			If !aColsDVY[n1Cnt][Len(aColsDVY[n1Cnt])] // Nao grava o Item se estiver deletado
				//-- So grava DVY se o campo DVY_CALPAS (Calcula Pasta) for igual a "Sim"
				If DVY->(MsSeek(xFilial("DVY")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+aColsRecnoDVY[n1Cnt] ))
					RecLock("DVY",.F.)
				Else
					RecLock("DVY",.T.)
				EndIf
				For n2Cnt:= 1 to Len(aHeaderDVY)
					If aHeaderDVY[n2Cnt][10] # "V"
						DVY->(FieldPut(FieldPos(Trim(aHeaderDVY[n2Cnt][2])),aColsDVY[n1Cnt][n2Cnt]))
					EndIf
				Next n2Cnt
				DVY->DVY_FILIAL := xFilial('DVY')
				DVY->DVY_TABFRE := M->DT0_TABFRE
				DVY->DVY_CDRORI := M->DT0_CDRORI
				DVY->DVY_CDRDES := M->DT0_CDRDES
				DVY->DVY_TIPTAB := M->DT0_TIPTAB
				DVY->DVY_CODPAS := Posicione( "DT3", 1, xFilial("DT3")+aColsDVY[n1Cnt,nDesPasDVY], "DT3_CODPAS" )
				DVY->DVY_CODPRO := M->DT0_CODPRO
				DVY->(MsUnLock())
			Else
				If DVY->(MsSeek(xFilial("DVY")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+aColsRecnoDVY[n1Cnt] ))
					RecLock("DVY",.F.)
					dbDelete()
					DVY->(MsUnLock())
				EndIf
			EndIf
		Next n1Cnt
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o conteudo do campo 'Tabela de Tarifa' for Alterado, todos os ³
	//³Itens da Getdados gravados no DT1, deverao ser Excluidos.        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For n1Cnt := 1 TO Len( aFolder )
		cFolder    := aFolder[n1Cnt][1]
		If cCatTab <> StrZero(2, Len(DT0->DT0_CATTAB))
			If nOpcx == 4 .And. AllTrim(M->DT0_TABTAR) <> AllTrim(cTabTarOld)
				DT1->(DbSetOrder(1)) //-- DT1_FILIAL+DT1_TABFRE+DT1_TIPTAB+DT1_CDRORI+DT1_CDRDES+DT1_CODPRO+DT1_CODPAS+DT1_ITEM
				While DT1->(MsSeek(xFilial("DT1") + M->DT0_TABFRE + M->DT0_TIPTAB +M->DT0_CDRORI + M->DT0_CDRDES+M->DT0_CODPRO+cFolder))
					RecLock("DT1", .F.)
					DT1->(dbDelete())
					DT1->(MsUnLock())
					DT1->(DbSkip())
				EndDo

				// Calculo do Excedente por Subfaixa
				// Exclusao dos itens do Excedente por Subfaixa for uma alteracao para usar tarifa
				If lSubExced
					DY1->(MsSeek(cChaveDY1 := xFilial("DY1")+M->DT0_TABFRE + M->DT0_TIPTAB + M->DT0_CDRORI + M->DT0_CDRDES + M->DT0_CODPRO + cFolder ))
					Do While DY1->( ! Eof()) .and. cChaveDY1 == DY1->(xFilial("DY1")+DY1_TABFRE + DY1_TIPTAB + DY1_CDRORI + DY1_CDRDES + DY1_CODPRO + DY1_CODPAS)
						RecLock("DY1",.F.)
						DY1->(DbDelete())
						MsUnlock()
						DY1->( DbSkip())
					Enddo
				EndIf
			EndIf
		EndIf
	Next n1Cnt
Else

	//-- Exclusao do Complemento da Tabela de Frete
	DTK->(DbSetOrder(1)) //-- DTK_FILIAL+DTK_TABFRE+DTK_TIPTAB+DTK_CDRORI+DTK_CDRDES+DTK_CODPRO+DTK_CODPAS
	If DTK->(MsSeek(xFilial("DTK")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO))
		While DTK->(!Eof()) .And. DTK->DTK_FILIAL+DTK->DTK_TABFRE+DTK->DTK_TIPTAB+DTK->DTK_CDRORI+DTK->DTK_CDRDES+DTK->DTK_CODPRO == ;
				xFilial( "DTK" ) + M->DT0_TABFRE + M->DT0_TIPTAB + M->DT0_CDRORI + M->DT0_CDRDES + M->DT0_CODPRO
			RecLock( "DTK", .F. )
			DTK->(DbDelete())
			DTK->(MsUnlock())
			DTK->(DbSkip())
		EndDo
	EndIf

	//-- Exclusao Base do Componente TDA
	DTY->(DbSetOrder(1)) //-- DTY_FILIAL+DTY_NUMCTC
	If DTY->(MsSeek(xFilial("DTY")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO))
		While DTY->(!Eof()) .And. DTY->DTY_FILIAL+DTY->DTY_TABFRE+DTY->DTY_TIPTAB+DTY->DTY_CDRORI+DTY->DTY_CDRDES+DTY->DTY_CODPRO == ;
				xFilial( "DTY" ) + M->DT0_TABFRE + M->DT0_TIPTAB + M->DT0_CDRORI + M->DT0_CDRDES + M->DT0_CODPRO
			RecLock( "DTY", .F. )
			DTY->(DbDelete())
			DTY->(MsUnlock())
			DTY->(DbSkip())
		EndDo
	EndIf

	// Calculo do Excedente por Subfaixa
	// Exclusao dos itens de Excedente se a subfaixa foi excluida
	If lSubExced
		DY1->(MsSeek(cChaveDY1 := xFilial("DY1")+M->DT0_TABFRE + M->DT0_TIPTAB + M->DT0_CDRORI + M->DT0_CDRDES + M->DT0_CODPRO ))
		Do While DY1->( ! Eof()) .and. cChaveDY1 == DY1->(xFilial("DY1")+DY1_TABFRE + DY1_TIPTAB + DY1_CDRORI + DY1_CDRDES + DY1_CODPRO)
			RecLock("DY1",.F.)
			DY1->(DbDelete())
			MsUnlock()
			DY1->( DbSkip())
		Enddo
	EndIf

	//-- Exclusao das sub-faixas
	If lSubFaixa
		DW1->(DbSetOrder(1)) //-- DW1_FILIAL+DW1_TABFRE+DW1_TIPTAB+DW1_CDRORI+DW1_CDRDES+DW1_CODPRO+DW1_CODPAS+DW1_ITEDT1+DW1_ITEM
		If DW1->(MsSeek(xFilial("DW1")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO))
			While DW1->(!Eof()) .And. DW1->DW1_FILIAL + DW1->DW1_TABFRE + DW1->DW1_TIPTAB + DW1->DW1_CDRORI + DW1->DW1_CDRDES + DW1->DW1_CODPRO  == ;
				xFilial("DW1") + M->DT0_TABFRE + M->DT0_TIPTAB + M->DT0_CDRORI + M->DT0_CDRDES + M->DT0_CODPRO 
				RecLock("DW1",.F.)
				DW1->(DbDelete())
				DW1->(MsUnlock())
				DW1->(DbSkip())
			EndDo
		EndIf
	EndIf

	//-- Exclusao da tabela de frete
	DT1->(DbSetOrder(1)) //-- DT1_FILIAL+DT1_TABFRE+DT1_TIPTAB+DT1_CDRORI+DT1_CDRDES+DT1_CODPRO+DT1_CODPAS+DT1_ITEM
	If DT1->(MsSeek(xFilial('DT1')+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO))
		While DT1->(!Eof()) .And. DT1->DT1_FILIAL + DT1->DT1_TABFRE + DT1->DT1_TIPTAB + DT1->DT1_CDRORI + DT1->DT1_CDRDES+ DT1->DT1_CODPRO == ;
				 xFilial('DT1') + M->DT0_TABFRE + M->DT0_TIPTAB + M->DT0_CDRORI + M->DT0_CDRDES + M->DT0_CODPRO
			RecLock("DT1",.F.)
			DT1->(DbDelete())
			DT1->(MsUnLock())
			DT1->(DbSkip())
		EndDo
	EndIf

	//-- Exclusao do cabecalho
	RecLock('DT0',.F.)
	DT0->(DbDelete())
	DT0->(MsUnLock())

EndIf

MsUnLockAll()
RestArea( aArea )
RestArea(aAreaDT0)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010Ok  ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Tudo antes da Gravacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010Ok(ExpN1,ExpN2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1  - Folder Atual                                       ³±±
±±³          ³ExpN2  - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA010                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³Valida Folder a Folder comecando pelo atual                 ³±±
±±³          ³Checa se existe PELO MENOS UM Folder preenchido             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010Ok( nSourceFolder, nOpcx, aRecnoDVD )

Local lReturn    := .F.
Local aSavHead   := aClone(aHeader)
Local aSavCols   := aClone(aCols)
Local aSavFold   := {}
Local nSavN      := N
Local nLoop      := 0 
Local j 		   := 0
Local lEmpty     := .F.
Local lOk        := .F.
Local nSavFolder := nFolder
Local cAliasDVD  := GetNextAlias()
Local cQuery     := ''
Local lContHis   := GetMv("MV_CONTHIS",.F.,.T.)

Default aRecnoDVD := {}
 
If	l010TudOk ==  Nil
	l010TudOk  := If(ValType(l010TudOk)=="L",l010TudOk,ExistBlock("TMA010TOK"))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa na Inclusao a chave Duplicada                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 3
	DT0->(DbSetOrder(1)) //-- DT0_FILIAL+DT0_TABFRE+DT0_TIPTAB+DT0_CDRORI+DT0_CDRDES+CODPRO	
	If nOpcao == 3 .And. DT0->(MsSeek(xFilial("DT0")+M->DT0_TABFRE + M->DT0_TIPTAB + M->DT0_CDRORI + M->DT0_CDRDES+M->DT0_CODPRO))
		Help("",1,"JAGRAVADO") //Ja existe registro com esta informacao.
		Return( .F. )
	EndIf
EndIf

aFolder[oFolder:nOption][5] := Aclone(aCols)
aSavFold := aClone(aFolder)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe algum campo obrigatorio em Branco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aeval( aFolder[nSourceFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .And. ;
													Empty( aCols[1][aPosCol[2]] ), ;
													lEmpty := .T.	, Nil ) } )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se estah vazio e nao sofreu modificacao deleta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lEmpty .And. ! aFolder[nSourceFolder][8]:lChgField
	aCols[1][Len(aHeader)+1] := .T.
EndIf

lEmpty := .T.

If aFolder[nSourceFolder][8]:TudoOk()

	aFolder := AClone(aSavFold)
	aFolder[nSourceFolder][4] 	:= aClone( aHeader )
	aFolder[nSourceFolder][5] 	:= aClone( aCols )
	n := Max(aFolder[nSourceFolder][8]:oBrowse:nAt,1)

	lEmpty  := If( lEmpty, Ascan( aCols, { |e| e[Len(e)] == .F. } ) = 0, lEmpty )

	lReturn := .T.

	For nLoop := 1 TO Len( aFolder )

		If nLoop == nSourceFolder
			Loop
		EndIf
		aHeader := aClone( aFolder[nLoop][4] )
		aCols   := aClone( aFolder[nLoop][5] )
		n       := Max(aFolder[nLoop][8]:oBrowse:nAt,1)
		nFolder := nLoop
		lOK     :=.F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe algum campo obrigatorio em Branco ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aeval( aFolder[nLoop][8]:aPosCol, { |aPosCol| 	If ( Empty( aCols[1][aPosCol[2]] ), ;
																							lOK := .T.	, Nil ) } )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se estah vazio e nao sofreu modificacao deleta³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lOK .And. ! aFolder[nLoop][8]:lChgField
			aCols[1][Len(aHeader)+1] := .T.
		EndIf

		lOK := .F.

		If ( aFolder[nLoop][8]:TudoOk() ) 
			aFolder := AClone(aSavFold)
			lEmpty  := If( lEmpty, Ascan( aCols, { |e| e[Len(e)] == .F. }  ) = 0, lEmpty )
		Else
			aFolder := AClone(aSavFold)
			lReturn := .F.
			Exit
		EndIf
		
	Next nLoop
EndIf

//Validacao para Exclusao de Tabelas de Ajuste 
If !lContHis
	For nLoop := 1 TO Len( aFolder )
	
		aHeader := aClone( aFolder[nLoop][4] )
		aCols   := aClone( aFolder[nLoop][5] )
		
		For j := 1 to Len(aCols)
			If GDDeleted( j )
			   	n := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DT1_REC_WT' })
				DT1->(dbGoTo(aCols[j][n]))
				
				cQuery := " SELECT R_E_C_N_O_ as DVD_RECNO FROM " + RetSqlName("DVD") 
				cQuery += " WHERE DVD_FILIAL = '" + xFilial("DVD")  + "' "
				cQuery += " AND DVD_TABFRE = '" + DT1->DT1_TABFRE + "' "
				cQuery += " AND DVD_TIPTAB = '" + DT1->DT1_TIPTAB + "' "
				cQuery += " AND DVD_CDRORI = '" + DT1->DT1_CDRORI + "' "
				cQuery += " AND DVD_CDRDES = '" + DT1->DT1_CDRDES + "' "
				cQuery += " AND DVD_CODPRO = '" + DT1->DT1_CODPRO + "' "
				cQuery += " AND DVD_CODPAS = '" + DT1->DT1_CODPAS + "' "
				cQuery += " AND DVD_ITEM   = '" + DT1->DT1_ITEM   + "' "
				cQuery += " AND D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDVD, .F., .T.)
				
				Do While !(cAliasDVD)->(Eof())
					AAdd( aRecnoDVD,	(cAliasDVD)->DVD_RECNO )
					(cAliasDVD)->(DbSkip())
				EndDo							
				(cAliasDVD)->( DbCloseArea() )
			EndIf
		Next j
	Next nLoop
	
	If !Empty(aRecnoDVD)
		If !MsgNoYes(STR0062 + Chr(13) + STR0063) //"Os registros selecionados para exclusão possuem ajustes/reajustes que também serão excluídos."
		   	aRecnoDVD := {}
			lReturn := .F.
		EndIf	
	EndIf
EndIf


If lReturn .And. lEmpty
	Help(" ",1,"TMSA01006") //"Todas as 'Pastas' estao vazias !!"
	lReturn := .F.
EndIf

If lReturn .And. l010TudOk
	lReturn:=ExecBlock("TMA010TOK",.F.,.F.)
	If ValType(lReturn) # "L"
		lReturn:=.T.
	EndIf
EndIf	

aFolder := AClone(aSavFold)
aHeader := aClone(aSavHead)
aCols   := aClone(aSavCols)
N       := nSavN      
nFolder := nSavFolder

Return( lReturn )
	
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010Bar ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Enchoice bar especifica                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010Bar(ExpO1,ExpB1,ExpB2,ExpN1)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpB1  - Dialog do Window                                   ³±±
±±³          ³ExpB2  - Evento Ok                                          ³±±
±±³          ³ExpB3  - Evento Cancel                                      ³±±
±±³          ³ExpN1  - Opcao da Mbrowse                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Objeto EnchoiceBar                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA010Bar( oDlg, bOk, bCancel, nOpcx )

Local aButtons     := {}
Local nCntFor      := 0
Local aSomaButtons := {}

//-- Nao mostra os Botoes da Enchoice na Exclusao
If nOpcx <> 5
	AAdd(aSetKey, { VK_F4 , { || TMSA010Min(nOpcx) } } )
	AAdd( aButtons, { "PRECO", { || TMSA010Min( nOpcx ) }, STR0019 , STR0035 } ) //Complemento Tabela de Frete - <F4>
	
	If AliasInDic("DVY")
		AAdd(aSetKey, { VK_F6 , { || TMSA010TDA(nOpcx) } } )
		AAdd( aButtons, { "SIMULACA", {|| TMSA010TDA(nOpcx) }, STR0048 , STR0049 } ) //'Base Componente Tx. Dif. Acesso - <F6>', 'Base TDA'
		//-- Retorna Teclas de Atalhos
		TmsKeyOn(aSetKey)
	EndIf
EndIf

AAdd(aSetKey, { VK_F5 , { || TMSA010SFx(nOpcx) } } )
AAdd( aButtons, { "RELATORIO", {|| TMSA010SFx(nOpcx) }, STR0036 , STR0037 } ) //'Tabela de Frete - Subfaixa - <F5>'

//-- Botao de atalho para a rotina 'Tabela de Frete por Destinatário'                                              
If nOpcx == 2  .And. AliasInDic("DY9")     
 	AAdd( aButtons, { "FRETEDEST", {|| TMSA012Mnt(,,1,DT0->DT0_TABFRE,DT0->DT0_TIPTAB) }, STR0009 , STR0057 } ) //'Tabela de Frete' - 'Tab.Frete Dest.' 
EndIf	

//-- Ponto de entrada para incluir botoes na enchoicebar
If	ExistBlock('TM010BUT')
	aSomaButtons:=ExecBlock('TM010BUT',.F.,.F.,{nOpcx})
	If	ValType(aSomaButtons) == 'A'
		For nCntFor:=1 To Len(aSomaButtons)
			AAdd(aButtons,aSomaButtons[nCntFor])
		Next
	EndIf
EndIf

Return( EnchoiceBar( oDlg, bOK, bCancel,, aButtons ) )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010Loc ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Localizador de Folder Preenchido                            ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010Loc(ExpN1,ExpO1,ExpL1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1  - Dialog do Window                                   ³±±
±±³          ³ExpO1  - Objeto Folder                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³  - Na Inclusao deleta TODOS os folders menos o 1           ³±±
±±³          ³  - Caso contrario Localiza o primeiro folder preenchido    ³±±
±±³          ³  - Se o Folder 1 nao estiver preenchido :                  ³±±
±±³          ³  - Deleta o Folder 1                                       ³±±
±±³          ³  - Forca Troca do Folder para o Primeiro Preenchido        ³±±
±±³          ³  - Troca Folder dentro do objeto Folder                    ³±±
±±³          ³  - Refresh para refletir a mudanca no Objeto Folder        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA010Loc( nOpcx, oFolder)

Local nI
Local nJ
Local lEmpty
Local nFirstFolderOk := 0

If nOpcx == 3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta todos menos o Folder 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aeval( aFolder, { | aFold | 	aFold[5][1][Len( aFold[4] ) + 1] := .T. }, 2 ) 
	nFirstFolderOk := 1
	
Else

	For nI := 1 TO Len( aFolder )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Candidato a delecao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len( aFolder[nI][5] ) == 1
			lEmpty := .F.

			For nJ := 1 TO Len( aFolder[nI][8]:aPosCol ) // Valida Obrigat
				If !lEmpty .And. Empty( aFolder[nI][5][1][aFolder[nI][8]:aPosCol[nJ, 2]] )
					lEmpty := .T.
					Exit
				EndIf
			Next nJ

			If lEmpty
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Deleta porque a FillGetDados colocou para Inclusao ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				aFolder[nI][5][1][Len( aFolder[nI][4] ) + 1] := .T.

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se nao eh o Folder 1 e ainda nao Localizou nenhum ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			ElseIf nFirstFolderOk == 0
				nFirstFolderOk := nI
			EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se tem mais de uma linha e nao eh o Folder 1 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf nFirstFolderOk == 0
			nFirstFolderOk := nI
		EndIf

	Next nI

EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita apenas o 1o.  Folder    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Aeval( aFolder, { |aFold| 	aFold[8]:oBrowse:lDisablePaint := .F. } ) 

aFolder[1][8]:oBrowse:lDisablePaint := .F. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Primeiro Folder Preenchido nao eh o 1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFirstFolderOk > 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o Folder 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[1][Len(aHeader)+ 1] := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Forca Troca do Folder para o primeiro preenchido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TMSA010Chg( nFirstFolderOk, 1 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Troca o Folder no Objeto Folder ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder:nOption := nFirstFolderOk

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dah um Refresh para efetivar a mudanca ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder:Refresh()

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Padrao - Folder 1 estah preenchido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFolder[1][8]:oBrowse:Refresh(.T.)

EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010Fol ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega todos os Folder no aFolder                         ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA010Fol(nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile,;   ³±±
±±³          ³			bSeekFor, aNoFields, aYesFields, cLinhaOk, ;      ³±±
±±³          ³			cTudoOk )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1      - Opcao Selecionada                              ³±±
±±³          ³ExpC1      - Alias                                          ³±±
±±³          ³ExpN2      - Ordem                                          ³±±
±±³          ³ExpC2      - Chave de Seek para montar aCols                ³±±
±±³          ³ExpB1      - Condicao While                                 ³±±
±±³          ³ExpB2      - Condicao For                                   ³±±
±±³          ³ExpA1      - Campos a serem excluidos                       ³±±
±±³          ³ExpA2      - Campos a serem incluidos                       ³±±
±±³          ³ExpC3      - Valida Linha                                   ³±±
±±³          ³ExpC4      - Valida Tudo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³ Possui Ponto de Entrada p/ Mudanca de Folders pelo usuario ³±±
±±³          ³                                                            ³±±
±±³          ³ Estrutura do Array de Folders                              ³±±
±±³          ³                                                            ³±±
±±³          ³   [1] -> Tipo "N" , Numero do Folder ( DT3_CODPAS )        ³±±
±±³          ³   [2] -> Tipo "C" , Titulo do Folder                       ³±±
±±³          ³   [3] -> Tipo "A" , aColsRecno ( Recno() de cada aCols )   ³±±
±±³          ³   [4] -> Tipo "A  , aHeader   da GetDados do Folder        ³±±
±±³          ³   [5] -> Tipo "A" , aCols     da GetDados do Folder        ³±±
±±³          ³   [6] -> Tipo "C" , cLinhaOk  da GetDados do Folder        ³±±
±±³          ³   [7] -> Tipo "C" , cTudoOk   da GetDados do Folder        ³±±
±±³          ³   [8] -> Tipo "O" , oGetDados deste Folder                 ³±±
±±³          ³   [9] -> Tipo "A" , Campos que podem ser alterados         ³±±
±±³          ³                                                            ³±±
±±³          ³  Estrutura do Array aFillGetDados                          ³±±
±±³          ³                                                            ³±±
±±³          ³   [1] -> Tipo "C" , cAlias do Arquivo                      ³±±
±±³          ³   [2] -> Tipo "N" , nOrder	do Indice                     ³±±
±±³          ³   [3] -> Tipo "C" , cSeekKey, chave de Pesquisa            ³±±
±±³          ³   [4] -> Tipo "B" , bSeekWhile, Pesquisa  While            ³±±
±±³          ³   [5] -> Tipo "B" , bSeekFor, Pesquisa  For                ³±±
±±³          ³   [6] -> Tipo "A" , aNoFields, NAO vao aparecer no aHeader ³±±
±±³          ³   [7] -> Tipo "A" , aYesFields, VAO aparecer no aHeader    ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA010Fol( 	nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, bSeekFor, ;
										aNoFields, aYesFields, cLinhaOk, cTudoOk, aAlter )

Local nPosValAte,nPosValor,aBacCols,aHTmp,aArea,aBacNoFields,cCampo,cFolderName,nAtalho  ,nSeek 
Local cChave, cChave1, cDescComp, cCdrOri, cCdrDes, cSeekDTK , cSeekDVY
Local cTabTar      := ""
Local lOk          := .F.
Local aMsgErr      := {}
Local aRegiao      := {}
Local aRetBox      := {}
Local nCntFor      := 0
Local nLoop1       := 0
Local aAreaDT0     := DT0->(GetArea())
Local lAchou       := .T.
Local cAster       := ' '
Local aNoFieldsDW1 := {}
Local lSubFaixa    := FindFunction("ALIASINDIC") .And. AliasInDic("DW1")
Local lSubExced    := FindFunction("ALIASINDIC") .And. lSubFaixa .and. AliasInDic("DY1")
Local aColsAux     := {}
Local nPosItem     := 0

Default cAlias     := "DT1"
Default nOrder     := 1
Default cSeekKey   := xFilial( "DT0" ) + M->DT0_TABFRE + M->DT0_TIPTAB + M->DT0_CDRORI + ;
						  M->DT0_CDRDES + M->DT0_CODPRO

Default bSeekWhile := { || 	DT1->DT1_FILIAL + DT1->DT1_TABFRE + DT1->DT1_TIPTAB +  ;
										DT1->DT1_CDRORI + DT1->DT1_CDRDES+;
										DT1->DT1_CODPRO + DT1->DT1_CODPAS }
										
Default bSeekFor   := { || .T. } 

Default aNoFields  := { 	"DT1_TABFRE","DT1_CDRORI", "DT1_CDRDES", ;
									"DT1_TIPTAB", "DT1_CODPAS"}
									 

Default cLinhaOk   := "TMSA010LinOk"
Default cTudoOk    := "TMSA010LinOk"

aFolder := {}

//-- Carrega o aHeader auxiliar do DTK
If nOpcx == 2
	TMSA010Min(nOpcx, .F.)
EndIf


DVE->(DbSetOrder(1)) //-- DVE_FILIAL+DVE_TABFRE+TIPTAB+ITEM
DVE->(DbGoTop())

DVE->( MsSeek( xFilial("DVE") + M->DT0_TABFRE + M->DT0_TIPTAB ) )

Do While DVE->(!Eof()) .And. xFilial("DVE") + M->DT0_TABFRE + M->DT0_TIPTAB == DVE->DVE_FILIAL + DVE->DVE_TABFRE + DVE->DVE_TIPTAB

	aHeader := {}
	aCols   := {}
	nAtalho := 1
	cAster  := ' '
	aBacNoFields := Aclone(aNoFields)

	DT3->(DbSetOrder(1)) //-- DT3_FILAL+DT3_CODPAS
	DT3->( MsSeek( xFilial( "DT3" ) +  DVE->DVE_CODPAS ) )

	//-- Se o componente for "Praca de Pedagio" ou for calculado pelo "Cliente Destinatário", ou "TDA x Região" nao devera aparecer no folder 
	If DT3->DT3_TIPFAI == StrZero(9, Len(DT3->DT3_TIPFAI)) .Or. DT3->DT3_TIPFAI == "15" .Or. DT3->DT3_TIPFAI == '18'
		DVE->( DbSkip() )
		Loop
	EndIf

	If DT3->DT3_FAIXA  <> StrZero(1, Len(DT3->DT3_FAIXA))
		AAdd(aBacNoFields,'DT1_FATPES')
	EndIf

	//-- Qdo utilizar sub-faixa, nao sera apresentado 'Valor' e 'Fracao'.
	If !Empty(DT3->DT3_FAIXA2)
		AAdd(aBacNoFields,'DT1_VALOR' )
		AAdd(aBacNoFields,'DT1_INTERV')
	EndIf

	cDescComp := AllTrim(DT3->DT3_DESCRI)
	cTabTar   := If(cCatTab <> StrZero(2, Len(DT0->DT0_CATTAB)), M->DT0_TABTAR, "")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Na Visualizacao / Exclusao da Tabela Mae, nao trazer na Tela Pastas Vazias      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOpcx == 2 .Or. nOpcx == 5) 
		cCdrOri := M->DT0_CDRORI
		cCdrDes := M->DT0_CDRDES
		If !DT1->( MsSeek( xFilial("DT1") + M->DT0_TABFRE + M->DT0_TIPTAB +  ;
				M->DT0_CDRORI + M->DT0_CDRDES + M->DT0_CODPRO + DVE->DVE_CODPAS ) ) .And. ;
				!DTG->(MsSeek(xFilial("DTG") + M->DT0_TABFRE + M->DT0_TIPTAB+ cTabTar + DVE->DVE_CODPAS))
			If nOpcx == 5
				DVE->( DbSkip() )
				Loop
			Else
				// Se Nao Encontrou o Componente na Tabela Mae, procura nas Regioes Superiores.
				// Isto porque, existem componentes que, ao inves, de serem Cadastrados para todas
				// as Regioes, sao cadastrados apenas para a "Regiao Pai".Sao chamadas de Taxas Estaduais.
				lAchou  := .F.
				If TmsTabela( aMsgErr, M->DT0_TABFRE, M->DT0_TIPTAB, , @cCdrOri, @cCdrDes , , , M->DT0_CODPRO, , @cTabTar, DT3->DT3_TAXA, DVE->DVE_CODPAS, DT3->DT3_PSQTXA )
					lAchou  := .T.
					cSeekKey :=	 xFilial("DT0")+M->DT0_TABFRE+M->DT0_TIPTAB+cCdrOri+cCdrDes+M->DT0_CODPRO
					cAster :=  ' * '
				EndIf

				If !Empty( aMsgErr )
					TmsMsgErr( aMsgErr )
					DVE->( DbSkip() )
					Loop
				EndIf

				// O Componente Nao foi cadastrado nas regioes superiores
				If !lAchou
					DVE->( DbSkip() )
					Loop
				EndIf
			EndIf
		Else
			If !DT1->(Eof())
				cSeekKey := xFilial("DT1") + M->DT0_TABFRE + M->DT0_TIPTAB + M->DT0_CDRORI + M->DT0_CDRDES + M->DT0_CODPRO 
			ElseIf !DTG->(Eof())
				cSeekKey := xFilial("DTG") + M->DT0_TABFRE + M->DT0_TIPTAB+ cTabTar
			EndIf
		EndIf

		//-- Verificar se existe Valores Minimos (DTK) para o componente e carregar o array auxiliar. 
		//-- Se o componente for taxa, os seus valores minimos poderao estar cadastrados no estado. Neste caso,
		//-- o seek no DTK, sera' dado com as regioes origem / destino retornados pela funcao TMSTabela().
		//-- Se o componente NAO for taxa, o seek no DTK sera' dado  com as Regioes Origem / Destino,
		//-- informadas na Tabela de Frete.
		If nOpcx == 2 // Verificar somente na visualizacao, pois no estorno, o botao de "Complemento da Tabela" nao e' exibido na tela
			DTK->(DbSetOrder(1)) //-- DTK_FILIAL+DTK_TABFRE+DTK_TIPTAB+DTK_CDRORI+DTK_CDRDES+DTK_CODPRO+DTK_CODPAS
			cFolder  := DT3->DT3_CODPAS
			cSeekDTK := xFilial("DTK")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO
			If !DTK->( MsSeek( cSeekDTK + cFolder ) ) .Or. (Empty(DTK->DTK_VALMIN) .And. Empty(DTK->DTK_EXCMIN))
				cSeekDTK := xFilial("DTK")+M->DT0_TABFRE+M->DT0_TIPTAB+cCdrOri+cCdrDes+M->DT0_CODPRO
				DTK->( MsSeek( cSeekDTK + cFolder ) )
			EndIf

			If !DTK->(Eof())
				AAdd( aColsRecnoDTK, DTK->DTK_CODPAS)

				AAdd(aColsDTK,Array(Len(aHeaderDTK)+1))
				For nCntFor := 1 To Len(aHeaderDTK)
					If	aHeaderDTK[nCntFor,10] != "V"
						aColsDTK[Len(aColsDTK),nCntFor]:= DTK->(FieldGet(FieldPos(aHeaderDTK[nCntFor,2])))
					Else
						If aHeaderDTK[nCntFor,2] == "DTK_ALI_WT"
							aColsDTK[Len(aColsDTK),nCntFor] := "DTK"
						ElseIf aHeaderDTK[nCntFor,2] == "DTK_REC_WT"
							aColsDTK[Len(aColsDTK),nCntFor] := DTK->(Recno())
						Else
							aColsDTK[Len(aColsDTK),nCntFor] := CriaVar(aHeaderDTK[nCntFor,2])
						EndIf
					EndIf
				Next nCntFor
				aColsDTK[Len(aColsDTK),Len(aHeaderDTK)+1]:=.F.
			EndIf
		EndIf

	EndIf

	AAdd( aFolder, {DT3->DT3_CODPAS, ;
							cDescComp + cAster, 	;
							FillGetDados(	nOpcx, ;
													cAlias,	;
													nOrder,	;
													cSeekKey + DT3->DT3_CODPAS, ; 
													bSeekWhile, ;
													bSeekFor, ;
													aBacNoFields, ;
													/*aYesFields*/, ;
													/*lOnlyYes*/,;
													/*cQuery*/,;
													/*bMontCols*/;
												 ), ;
							aClone( aHeader ), ;
							aClone( aCols ), ;
							cLinhaOk, ;
							cTudoOk, ;
							Nil, ;
							aAlter } )

	nPosItem     := GDFieldPos("DT1_ITEM")
	aColsAux     := AClone(aCols)
	aBacNoFields := AClone(aNoFields)

	nSeek := AsCan(aCols, {|x| !x[Len(x)]  .And. !Empty(x[GdFieldPos('DT1_VALATE')]) })
	If nSeek == 0 // Se nao achou itens no DT1, alimenta a Acols com a tabela de tarifas
		TMSA010CTar(cTabTar,nOpcx)
	EndIf
	
	//-- Define letra de atalho para acessar o folder
	If	!Empty( DT3->DT3_ATALHO )
		nAtalho := At( DT3->DT3_ATALHO, UPPER(aFolder[ Len(aFolder), 2 ]) )
		If Empty( nAtalho )
			nAtalho := 1
		EndIf
	EndIf

	aFolder[ Len(aFolder), 2 ] := Stuff( aFolder[ Len(aFolder), 2 ], nAtalho, 0, '&' )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Troca do aHeader refletindo o nome da Pasta do Folder³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosValAte	:= Ascan( aFolder[Len(aFolder)][4], { |aField| aField[2] = "DT1_VALATE" } )

	If Empty(DT3->DT3_FAIXA) .Or. DT3->DT3_FAIXA == StrZero(0, Len(DT3->DT3_FAIXA))
		cFolderName := TMSValField('DT3->DT3_TIPFAI',.F.)
	Else
		//-- Esse array contem as descricoes existentes no ComboBox do campo DT3_FAIXA
		aRetBox := RetSx3Box(TMSA030BFX(),,, Len(DT3->DT3_FAIXA)) //-- Esse array contem as descricoes existentes no ComboBox do campo DT3_FAIXA 
		
		cFolderName := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == DT3->DT3_FAIXA} ), 3 ])
	EndIf

	aFolder[Len(aFolder)][4][nPosValAte][1] := getSx3Cache("DT1_VALATE","X3_Titulo") + Space( 10 ) + "(" +  cFolderName + ")" //"Ate"

	//-- Carrega Sub-Faixas
	If lSubFaixa .And. !Empty(DT3->DT3_FAIXA2)
		//-- Campos que nao deverao aparecer na getdados
		aNoFieldsDW1 := { "DW1_ITEDT1" }
		If DT3->DT3_FAIXA2 <> StrZero(1, Len(DT3->DT3_FAIXA2))
			AAdd(aNoFieldsDW1,'DW1_FATPES')
		EndIf
		For nCntFor := 1 To Len(aColsAux)
			If (nPos:= Ascan( aColsDW1, { |x| x[1]+x[2] == DVE->DVE_CODPAS + aColsAux[nCntFor,nPosItem] } ) ) == 0
				aCols   := {}
				aHeader := {}
				FillGetDados(	nOpcx, ;
									"DW1", ;
									1, 	 ;
									xFilial("DW1")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+DVE->DVE_CODPAS+aColsAux[nCntFor,nPosItem] , ;
									Iif(nOpcx <> 3,{ || DW1->DW1_FILIAL+DW1->DW1_TABFRE+DW1->DW1_TIPTAB+DW1->DW1_CDRORI+DW1->DW1_CDRDES+DW1->DW1_CODPRO+DW1->DW1_CODPAS+DW1->DW1_ITEDT1 },{|| ''   }), ;
									{|| .T.  },;
									aNoFieldsDW1,;
								 	/*aYesFields*/,;
								   	/*lOnlyYes*/,;
								    /*cQuery*/,;
									/*bMontCols*/)
										
				//-- Inicializa o primeiro item da sub-faixa.
				aEval(aCols, {|x| Iif( Empty(x[GdFieldPos('DW1_ITEM')]), x[GdFieldPos('DW1_ITEM')]:= StrZero(1, Len(DW1->DW1_ITEM)), .T.) })
				AAdd(aColsDW1,{ DVE->DVE_CODPAS, aColsAux[nCntFor,nPosItem], AClone(aCols), AClone(aHeader) } )

				// Calculo do Excedente por Subfaixa
				// Processa o ultimo item incluido no vetor para carregar o Excedente por subfaixa
				If lSubExced
					DbSelectArea("DY1")
					DY1->(DbSetOrder(1)) //-- DY1_FILIAL+DY1_TABFRE+DY1_TIPTAB+DY1_CDRORI+DY1_CDRDES+DY1_CODPRO+DY1_CODPAS+DY1_ITEDT1+DY1_ITEM
					posItemDw1 := Ascan(aColsDW1[1,4],{|e| e[2] = "DW1_ITEM" })
					For nLoop1 :=  1 to Len(aColsDW1[Len(aColsDW1),3])
						cItemDT1 := aColsDW1[Len(aColsDW1),2]
						cChave   := DVE->DVE_CODPAS + cItemDT1
						If (nPos:= Ascan( aColsDY1, { |x| x[1]+x[2] == cChave } ) ) == 0
							DbSelectArea("DY1")
							aCols   := {}
							aHeader := {}
							//-- Campos que nao deverao aparecer na getdados
							aNoFields    := { "DY1_CODPAS", "DY1_TABTAR", "DY0_ITEDT1" }
							FillGetDados(	nOpcx, ;
										"DY1", ;
										1, 	 ;
										xFilial("DY1")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+DVE->DVE_CODPAS+cItemDt1, ;
										Iif(nOpcx <> 3,{ || DY1->DY1_FILIAL+DY1->DY1_TABFRE+DY1->DY1_TIPTAB+DY1->DY1_CDRORI+DY1->DY1_CDRDES+DY1->DY1_CODPRO+DY1->DY1_CODPAS+DY1->DY1_ITEDT1 },{|| ''   }), ;
										{|| .T.  },;
										aNoFields,;
										/*aYesFields*/,;
										/*lOnlyYes*/,;
										/*cQuery*/,;
										/*bMontCols*/)
							//-- Inicializa o primeiro item da sub-faixa.
							aEval(aCols, {|x| Iif( Empty(x[GdFieldPos('DY1_ITEM')]), x[GdFieldPos('DY1_ITEM')]:= StrZero(1, Len(DY1->DY1_ITEM)), .T.) })
	
							//-- Armazena aHeader das sub-faixas da tabela de tarifa
							AAdd(aColsDY1,{ DTG->DTG_CODPAS, DTG->DTG_ITEM, AClone(aCols), AClone(aHeader) } )
						EndIf
					Next
				EndIf
			EndIf
			
		Next nCntFor
	EndIf

	DVE->( DbSkip() )

EndDo	

RestArea(aAreaDT0)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010LinO³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Linha da Getdados                                    ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010LinOk()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³ Verifica se a Getdados possui INTERVALO de frete jah       ³±±
±±³          ³ existente em outra linha, ou seja, se houve ENTRELACAMENTO ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010LinOk()

Local lReturn
Local nPosValAte := Ascan( aHeader, { |aField| aField[2] = "DT1_VALATE" } )
Local nPosFatPes := Ascan( aHeader, { |aField| aField[2] = "DT1_FATPES" } )
Local nValAte    := aCols[n][nPosValAte]
Local nValPes    := If(nPosFatPes > 0, aCols[n][nPosFatPes], 0)

Do Case

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Esta deletado                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case aCols[n][Len( aHeader ) + 1]
		lReturn := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Na primeira linha Valida p/ baixo  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Case  n = 1
		lReturn := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
								(nValAte >= aLine[nPosValAte]	.Or.;
								 IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )}, 2 ) = 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Na ultima linha Valida p/ cima ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Case  n = Len( aCols )
		lReturn := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
									(nValAte <= aLine[nPosValAte]	.Or.;
									IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) )}, 1, Len( Acols ) - 1 ) = 0
			
	OtherWise

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida Acima e Abaixo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lReturn := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. ;
									(nValAte <= aLine[nPosValAte] .Or. ;
									IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) ) } , 1, n - 1 ) = 0
	
		lReturn := lReturn .And. ;
					   Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. ;
									(nValAte >= aLine[nPosValAte] .Or.;
									IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )	}, n + 1 ) = 0
EndCase

If !lReturn
	Help(" ",1,"TMSA01007") //"Campo Ate'/Fator Peso Invalido ou ja existente"
EndIf

If lReturn .And. !GDdeleted(n)
	If nPosFatPes >0 .And. GDFieldGet('DT1_FATPES',n) < GDFieldGet('DT1_VALATE',n)
		Help("", 1,"TMSA01008")  //"O Fator de Peso Nao pode ser menor do que o Peso ..."
		lReturn := .F.
	EndIf
	//-- Valida sub-faixa do componente.
	If lReturn
		If !GDDeleted(n) .And. !TMSA010Vd2(aFolder[nFolder,1],GDFieldGet('DT1_ITEM',n))
			Help("",1,"TMSA01017") //Nao foi informada a sub-faixa para o item.
			lReturn := .F.
		EndIf
	EndIf

	//-- Valida o componente tipo TAXA  
	If lReturn .And. DT3->DT3_TAXA == "1" .And. (DT1->(FieldPos('DT1_INTERV')) > 0)
		If GDFieldGet('DT1_INTERV',n) != Nil .And. GDFieldGet('DT1_INTERV',n) > 0
			Help("",1,"TMSA01023") //Componente e do tipo Taxa, nao deve ter valor de fracao
			lReturn := .F.
		EndIf
	EndIf
EndIf

Return( lReturn )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010Cop ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Copia da Tabela de Frete                                    ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010Cop()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010Cop()

Local oDlg
Local oCopOri
Local oCopDes
Local nOpcao    := 0
Local lCopOri   := .F.

Private lCopDes := .F.

DEFINE MSDIALOG oDlg FROM 00,00 TO 110,290 PIXEL TITLE STR0034 //-- 'Tipo de Copia'

//-- 'Origem'
@ 05,05 CHECKBOX oCopOri VAR lCopOri PROMPT OemToAnsi(STR0011) SIZE 100,010 ; // Origem
	ON CLICK( lCopDes := .F., oCopDes:Refresh() ) OF oDlg PIXEL

//-- 'Destino'
@ 20,05 CHECKBOX oCopDes VAR lCopDes PROMPT OemToAnsi(STR0033) SIZE 100,010 ; // Destino
	ON CLICK( lCopOri := .F., oCopOri:Refresh() ) OF oDlg PIXEL


DEFINE SBUTTON FROM 05,115 TYPE 1 OF oDlg ENABLE ACTION (nOpcao := 1,oDlg:End())
DEFINE SBUTTON FROM 20,115 TYPE 2 OF oDlg ENABLE ACTION (nOpcao := 0,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

//-- Copia de Tabela de Frete
If nOpcao == 1
	TMSA010PCop()
EndIf

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010PCop³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa Copia da Tabela de Frete                           ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010PCop()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA010PCop()

Local oDlg
Local nRecDT0    := DT0->(Recno()) 
Local aAreaDT0   := DT0->(GetArea())
Local nOpc       := 2
Local cKeyDT0    := If(lCopDes,DT0->DT0_CDRDES,DT0->DT0_CDRORI)
Local cDescReg, cKeyDT1
Local aCampos    := {}
Local aButtons   := {}
Local aEstruExp  := {}
Local lInvert    :=.F.
Local cQuery     := ''
Local cQueryAux  := ''
Local cTemp      := ''
Local cAlias     := 'DT0'
Local cRealName	 := ""
Local cTabFre    := DT0->DT0_TABFRE
Local cTipTab    := DT0->DT0_TIPTAB
Local cCdrOri    := DT0->DT0_CDRORI
Local cCdrDes    := DT0->DT0_CDRDES
Local nI         := 0
Local lRet       := .T.
Local cNewReg    := Space(Len(DT0_CDRORI))
Local oMark 
Local cKeyDW1    := ''
Local cKeyDJS	 := ''
Local lSubFaixa  := FindFunction("ALIASINDIC") .And. AliasInDic("DW1")
Local lSubExced  := FindFunction("ALIASINDIC") .And. lSubFaixa .and. AliasInDic("DY1")

Private cMark := GetMark()

//-- Se a Categoria da Tabela nao foi definida
If Type("cCatTab") == "U"
	cCatTab := Posicione('DTl',1, xFilial('DTL')+DT0->DT0_TABFRE+DT0->DT0_TIPTAB, 'DTL_CATTAB')
EndIf

If !TMSTbAtiva( DT0->DT0_TABFRE, DT0->DT0_TIPTAB,,,cCatTab, .T. )
	Return( .F. )
EndIf

DUY->(DbSetOrder(1)) //-- DUY_FILAL+DUY_GRPVEN
DUY->( MsSeek( xFilial('DUY') + cKeyDT0, .F.) )

cDescReg := DUY->DUY_DESCRI
cDescNewOri := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para Funcionar ExistChav !³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Inclui := .T.

//-- Filtra a Tabela de Frete e Gera Arquivo de Trabalho
aEstruExp := (cAlias)->( dbStruct() )
AAdd(aEstruExp, { "MARK", "C", 2, 0 } )
AAdd(aEstruExp, { "RECNO", "N", 14 , 0 } )

cQueryAux := "SELECT "

For nI := 1 To Len( aEstruExp )
	If !(AllTrim(aEstruExp[nI,1]) $ 'MARK|RECNO')
		If nI > 1
			cQueryAux += ", "
		EndIf
		cQueryAux += aEstruExp[ nI, 1 ]
	EndIf
Next
cQueryAux += ", '"+cMark+"' MARK, R_E_C_N_O_  RECNO, D_E_L_E_T_  "

cQueryAux += "FROM "+RetSqlName(cAlias) + " " + cAlias + " "
cQueryAux += "WHERE "+cAlias+"_FILIAL  = '"+xFilial(cAlias)+"'"
cQueryAux += "  AND "+cAlias+"_TABFRE  = '"+cTabFre+"'"
cQueryAux += "  AND "+cAlias+"_TIPTAB  = '"+cTipTab+"'" 
If lCopDes
	cQueryAux += "  AND "+cAlias+"_CDRDES  = '"+cCdrDes+"'" 
Else
	cQueryAux += "  AND "+cAlias+"_CDRORI  = '"+cCdrOri+"'" 
EndIf
cQueryAux += "  AND D_E_L_E_T_ = ' ' " 

//-- ChangeQuery()
//-- 1o Parametro : Query 
//-- 2o Parametro : Se .F., nao insere FOR READ ONLY no final das querys para AS/400 e/ou DB2
cQueryAux := ChangeQuery(cQueryAux, .F.)

cTemp   := GetNextAlias()

oTempTable := FWTemporaryTable():New( cTemp )
oTempTable:SetFields( aEstruExp )
oTempTable:AddIndex("01", {"DT0_CDRORI"} )
oTempTable:AddIndex("02", {"DT0_CDRDES"} )
oTempTable:Create()

cRealName:= oTempTable:GetRealName()

cQuery := "INSERT INTO " + cRealName + " ( "
For nI := 1 To Len( aEstruExp )
	If nI > 1
		cQuery += ", "
	EndIf
	cQuery += aEstruExp[ nI, 1 ]
Next

cQuery += " ,D_E_L_E_T_ ) " + cQueryAux

If TCSqlExec( cQuery ) <> 0
	oTempTable:Delete()
	Return( .F. )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do aCampos para utilisar no MarkBrow               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCopDes
	aCampos := {	{"MARK"  ,"A010Marca", "Ok"},;
					{"DT0_CDRORI","A010Marca", AllTrim(getSx3Cache("DT0_CDRORI","X3_Titulo")) },;
					{ {||Posicione('DUY',1,xFilial('DUY')+(cTemp)->DT0_CDRORI,'DUY_DESCRI')},"A010Marca",' '},;
					{"DT0_CODPRO","A010Marca", AllTrim(getSx3Cache("DT0_CODPRO","X3_Titulo")) },;
					{ {||Posicione('SB1',1,xFilial('SB1')+(cTemp)->DT0_CODPRO,'B1_DESC')} ,"A010Marca",'  '},;
					{"DT0_TABTAR","A010Marca", AllTrim(getSx3Cache("DT0_TABTAR","X3_Titulo")) }}
Else
	aCampos := {	{"MARK"  ,"A010Marca", "Ok"},;
					{"DT0_CDRDES","A010Marca", AllTrim(getSx3Cache("DT0_CDRDES","X3_Titulo")) },;
					{ {||Posicione('DUY',1,xFilial('DUY')+(cTemp)->DT0_CDRDES,'DUY_DESCRI')},"A010Marca",' '},;
					{"DT0_CODPRO","A010Marca", AllTrim(getSx3Cache("DT0_CODPRO","X3_Titulo")) },;
					{ {||Posicione('SB1',1,xFilial('SB1')+(cTemp)->DT0_CODPRO,'B1_DESC')} ,"A010Marca",'  '},;
					{"DT0_TABTAR","A010Marca", AllTrim(getSx3Cache("DT0_TABTAR","X3_Titulo")) }}
EndIf

DEFINE MSDIALOG oDlg TITLE STR0043 +  DT0->DT0_TABFRE + "/" +DT0->DT0_TIPTAB From 2,0 To 30,90 OF oMainWnd //Copia da Tabela de Frete : 

	If lCopDes
		@ 035,010 SAY 	 STR0030 SIZE 100,15 COLOR CLR_HBLUE PIXEL 	//Do Destino
		@ 035,053 SAY 	 cKeyDT0+ " - " + cDescReg  SIZE 200,15 PIXEL
		@ 055,010 SAY 	 STR0031 SIZE 100,15 COLOR CLR_HBLUE PIXEL 	//Para o Destino
		
		@ 055,050 MSGET cNewReg  F3 "DUY"  PICTURE  PesqPict("DT0","DT0_CDRDES") SIZE 6,9 WHEN ( DbGoTo( nRecDT0 ), .T. ) ;
			VALID (cNewReg<>DT0->DT0_CDRDES) .And. TMSA010Cpo(cNewReg,cTemp) PIXEL
		
		@ 055,085 MSGET  cDescNewOri  When .F. SIZE 70,9  OF oDlg PIXEL
	Else
		@ 035,010 SAY 	 STR0010 SIZE 100,15 COLOR CLR_HBLUE PIXEL 	//Da Origem
		@ 035,053 SAY 	 cKeyDT0+ " - " + cDescReg  SIZE 200,15 PIXEL
		@ 055,010 SAY 	 STR0011 SIZE 100,15 COLOR CLR_HBLUE PIXEL 	//Para a Origem
		
		@ 055,050 MSGET cNewReg  F3 "DUY"  PICTURE  PesqPict("DT0","DT0_CDRORI") SIZE 6,9 WHEN ( DbGoTo( nRecDT0 ), .T. ) ;
			VALID (cNewReg<>DT0->DT0_CDRORI) .And. TMSA010Cpo(cNewReg,cTemp) PIXEL
		
		@ 055,085 MSGET  cDescNewOri  When .F. SIZE 70,9  OF oDlg PIXEL
	EndIf
	
	(cTemp)->(dbGoTop())
		
	oMark := MsSelect():New(cTemp,"MARK",,aCampos,@lInvert,@cMark,{70,02,210,354})
	oMark:oBrowse:lHasMark		:= .T.
	oMark:oBrowse:lCanAllMark 	:= .T.
	oMark:bAval := {|| TMA010Mrk(cRealName,cTemp,oMark,.F.)} //-- Marca / Desmarca o Item posicionado
	oMark:oBrowse:bAllMark := {| | TMA010Mrk(cRealName,cTemp,oMark,.T.)} //-- Marca / Desmarca todos os Itens

	AAdd(aButtons,	{'PESQUISA',{|| TMSA010Psq(cNewReg,cTemp,lCopDes,oMark) }, STR0041, STR0042 })	//Pesquisa	
	
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpc:=1, If( !Empty(cNewReg) ,oDlg:End(),nOpc := 0)},{||oDlg:End()},,aButtons )

If nOpc == 1

	If ( lCopDes .And. Aviso( "AVISO", STR0032 + DT0->DT0_CDRDES + " " + ; //"Copiar todas as Tabela de Frete de Destino"
			STR0033 + " " + cNewReg, { STR0016, STR0017 },, STR0018 ) == 1 ) .Or. ; //"Para o Destino"###"Confirma"###"Cancela"###"Confirmacao"	   
		( !lCopDes .And. Aviso( "AVISO", STR0014 + DT0->DT0_CDRORI + " " + ; //"Copiar todas as Tabela de Frete de Origem"
			STR0015 + " " + cNewReg, { STR0016, STR0017 },, STR0018 ) == 1 ) //"Para a Origem"###"Confirma"###"Cancela"###"Confirmacao"	   

		CursorWait()
		
		DbSelectArea(cTemp)
		dbGoTop()

		Do While  !Eof()

			If	Empty((cTemp)->MARK)
				(cTemp)->(DbSkip())
				Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se ja existe uma tabela com a nova Regiao Origem/Destino ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCopDes
				cSeek := xFilial('DT0')+(cTemp)->DT0_CDRORI+cNewReg+(cTemp)->DT0_TABFRE+(cTemp)->DT0_TIPTAB+(cTemp)->DT0_CODPRO
			Else
				cSeek := xFilial('DT0')+cNewReg+(cTemp)->DT0_CDRDES+(cTemp)->DT0_TABFRE+(cTemp)->DT0_TIPTAB+(cTemp)->DT0_CODPRO
			EndIf

			DbSelectArea("DT0")
			DT0->(DbSetOrder(2)) //-- DT0_FILIAL+DT0_CDRORI+DT0_CDRDES+DT0_TABFRE+DT0_TIPTAB+CODPRO
			If  (DT0->(MsSeek(cSeek)))
				DbSelectArea(cTemp)	
				DbSkip()
				Loop
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Copia Cabecalho da Tabela de Frete  (DT0)                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCampos := {}
			If lCopDes
				AAdd( aCampos, { "DT0_CDRDES", cNewReg } )
			Else
				AAdd( aCampos, { "DT0_CDRORI", cNewReg } )
			EndIf
			DT0->(MsSeek(xFilial('DT0')+(cTemp)->DT0_CDRORI+(cTemp)->DT0_CDRDES+(cTemp)->DT0_TABFRE+(cTemp)->DT0_TIPTAB+(cTemp)->DT0_CODPRO))		
			DT0->(TmsCopyReg(aCampos))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Copia Itens da Tabela de Frete (DT1)                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCampos := {}
			If lCopDes
				AAdd( aCampos, { "DT1_CDRDES", cNewReg } )
			Else
				AAdd( aCampos, { "DT1_CDRORI", cNewReg } )
			EndIf
			DbSelectArea( "DT1" )
			DbSetOrder(1)
			MsSeek(cKeyDT1 := xFilial("DT1") + DT0->DT0_TABFRE + DT0->DT0_TIPTAB + DT0->DT0_CDRORI + DT0->DT0_CDRDES + DT0->DT0_CODPRO)
			Do While xFilial("DT1") + DT1_TABFRE  + DT1_TIPTAB + DT1_CDRORI + DT1_CDRDES + DT1_CODPRO == cKeyDT1
				DT1->(TmsCopyReg(aCampos))
				DbSelectArea("DT1")
				DbSkip()
			EndDo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Copia Complemento da Tabela de Frete (DTK)                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCampos := {}
			If lCopDes
				AAdd( aCampos, { "DTK_CDRDES", cNewReg } )
			Else
				AAdd( aCampos, { "DTK_CDRORI", cNewReg } )
			EndIf
			DbSelectArea( "DTK" )
			DbSetOrder(1)
			MsSeek(cKeyDTK := xFilial("DTK") + DT0->DT0_TABFRE + DT0->DT0_TIPTAB + DT0->DT0_CDRORI + DT0->DT0_CDRDES + DT0->DT0_CODPRO)
			Do While xFilial("DTK") + DTK_TABFRE  + DTK_TIPTAB + DTK_CDRORI + DTK_CDRDES + DTK_CODPRO == cKeyDTK
				DTK->(TmsCopyReg(aCampos))
				DbSelectArea("DTK")
				DbSkip()
			EndDo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Copia Base Componente TDA (DVY)                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AliasInDic("DVY")
				aCampos := {}
				If lCopDes
					AAdd( aCampos, { "DVY_CDRDES", cNewReg } )
				Else
					AAdd( aCampos, { "DVY_CDRORI", cNewReg } )
				EndIf
				DbSelectArea( "DVY" )
				DbSetOrder(1)
				If MsSeek(cKeyDVY := xFilial("DVY") + DT0->DT0_TABFRE + DT0->DT0_TIPTAB + DT0->DT0_CDRORI + DT0->DT0_CDRDES + DT0->DT0_CODPRO)
					Do While xFilial("DVY") + DVY_TABFRE  + DVY_TIPTAB + DVY_CDRORI + DVY_CDRDES + DVY_CODPRO == cKeyDVY
						DVY->(TmsCopyReg(aCampos))
						DbSelectArea("DVY")
						DbSkip()
					EndDo
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Copia Base % por Componente TRT (DJS)                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AliasInDic("DJS")
				aCampos := {}
				If lCopDes
					AAdd( aCampos, { "DJS_CDRDES", cNewReg } )
				Else
					AAdd( aCampos, { "DJS_CDRORI", cNewReg } )
				EndIf
				DbSelectArea( "DJS" )
				DbSetOrder(1)
				If MsSeek(cKeyDJS := xFilial("DJS") + DT0->DT0_TABFRE + DT0->DT0_TIPTAB + DT0->DT0_CDRORI + DT0->DT0_CDRDES + DT0->DT0_CODPRO)
					Do While xFilial("DJS") + DJS_TABFRE  + DJS_TIPTAB + DJS_CDRORI + DJS_CDRDES + DJS_CODPRO == cKeyDJS
						DJS->(TmsCopyReg(aCampos))
						DbSelectArea("DJS")
						DbSkip()
					EndDo
				EndIf
			EndIf
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Copia Sub-Faixas da Tabela de Frete (DW1)                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lSubFaixa 
				aCampos := {}
				If lCopDes
					AAdd( aCampos, { "DW1_CDRDES", cNewReg } )
				Else
					AAdd( aCampos, { "DW1_CDRORI", cNewReg } )
				EndIf
				DbSelectArea( "DW1" )
				DbSetOrder(1)
				MsSeek(cKeyDW1 := xFilial("DW1") + DT0->DT0_TABFRE + DT0->DT0_TIPTAB + DT0->DT0_CDRORI + DT0->DT0_CDRDES + DT0->DT0_CODPRO)
				While xFilial("DW1") + DW1_TABFRE  + DW1_TIPTAB + DW1_CDRORI + DW1_CDRDES + DW1_CODPRO == cKeyDW1
					DW1->(TmsCopyReg(aCampos))
					DbSelectArea("DW1")
					DbSkip()
				EndDo
			EndIf

			// Calculo do Excedente por Subfaixa
			// Copia dos dados de excedente por subfaixa
			If lSubExced
				If lCopDes
					AAdd( aCampos, { "DY1_CDRDES", cNewReg } )
				Else
					AAdd( aCampos, { "DY1_CDRORI", cNewReg } )
				EndIf
				DbSelectArea( "DY1" )
				DbSetOrder(1)
				MsSeek(cKeyDY1 := xFilial("DY1") + DT0->DT0_TABFRE + DT0->DT0_TIPTAB + DT0->DT0_CDRORI + DT0->DT0_CDRDES + DT0->DT0_CODPRO)
				While xFilial("DY1") + DY1_TABFRE  + DY1_TIPTAB + DY1_CDRORI + DY1_CDRDES + DY1_CODPRO == cKeyDY1
					DY1->(TmsCopyReg(aCampos))
					DbSelectArea("DY1")
					DbSkip()
				EndDo

			EndIf

			DbSelectArea(cTemp)
			DbSkip()
		EndDo
	EndIf
EndIf

(cTemp)->(dbCloseArea())

//-- Apaga temporario
oTempTable:Delete()

RestArea(aAreaDT0)

CursorArrow()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010Tar ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preenche Folders da Tarifacao                               ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010Tar()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010Tar()

Local nLoop
Local nLoop1
Local aHeader1
Local aCols1
Local nCodPas,cTabFre, cTipTab, cTabTar
Local nPosTar  
Local nPosItem 
Local lAlter
Local lSubFaixa    := FindFunction("ALIASINDIC") .And. AliasInDic("DW1")
Local lSubExced    := FindFunction("ALIASINDIC") .And. AliasInDic("DY1") .And. AliasIndic("DY0")
Local nPos         := 0
Local nCntFor      := 0
Local aNoFields    := {}
Local aNoFieldsDW1 := {}

If l010MVC
	Return TMA10ATar()
Else
	nPosItem     := Ascan( aHeader,{|aElem|Trim(aElem[2]) == "DT1_ITEM"})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o aCols do Folder, pois, caso NAO tenha sido executada a mudanca de pasta, ³
	//³ o aCols do Folder nao esta com o mesmo conteudo do aCols.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFolder[oFolder:nOption][5] := Aclone(aCols)
	
	If cCatTab <> StrZero(2, Len(DT0->DT0_CATTAB))
		If !Empty( M->DT0_TABTAR ) .And. !ExistCpo( "DTF", M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_TABTAR, 1 )
			Return( .F. )
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpar os aCols das GetDados ... Isso tem que ser feito, pois os Folders     ³
	//³terao que atualizados todas vez que o campo de Tabela de Tarifa for Alterado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aFolder) > 0
		aColsDW1 := {}
		For nLoop:=1 To Len(aFolder)
			aHeader1 := aFolder[nLoop][4]
			aCols1   := aFolder[nLoop][5]
			nPosTar  := Ascan(aHeader1, {|x| AllTrim(x[2]) == "DT1_TARIFA" } )
			If !Empty(aCols1)
				aCols1:={}
				AAdd(aCols1, Array( Len( aHeader1 ) + 1 ) )
				For nCntFor := 1 To Len(aHeader1)
					If	aHeader1[nCntFor,10] != "V"
						aCols1[Len(aCols1),nCntFor]:= CriaVar(aHeader1[nCntFor,2])
					Else
						If aHeader1[nCntFor,2] == "DT1_ALI_WT" 
							aCols1[Len(aCols1),nCntFor]:= "DT1"
						ElseIf aHeader1[nCntFor,2] == "DT1_REC_WT"
							aCols1[Len(aCols1),nCntFor]:= 0
						Else
							aCols1[Len(aCols1),nCntFor]:= CriaVar(aHeader1[nCntFor,2])
						EndIf
					EndIf
				Next nCntFor
	
				aCols1[ Len( aCols1 ) ][ Len( aHeader1 ) + 1 ] := .F.
				aCols1[ Len( aCols1 ) ][nPosItem] := StrZero(1, Len(DT1->DT1_ITEM))
				aFolder[nLoop][5]:=AClone(aCols1)
				aFolder[nLoop][3]:= {}
				aFolder[nLoop][8]:lChgField := .F.
	
				aFolder[nLoop][8]:oBrowse:nOpc:=If(Inclui,3,4)
				aFolder[nLoop][8]:lDeleta:= .T.
				aFolder[nLoop][8]:nMax   :=9999
			EndIf
		Next
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega todos os Folders com elementos da Tabela de Tarifa   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cCatTab <> StrZero(2, Len(DT0->DT0_CATTAB))
			DTG->(DbSetOrder(1)) //-- DTG_FILIAL+DTG_TABFRE+DTG_TIPTAB+DTG_TABTAR+DTG_CODPAS+DTG_ITEM
			DTG->( MsSeek( xFilial("DTG") + M->DT0_TABFRE +M->DT0_TIPTAB+M->DT0_TABTAR) )
			Do While !DTG->(Eof()) .And. DTG->DTG_FILIAL + DTG->DTG_TABFRE +DTG->DTG_TIPTAB+ DTG->DTG_TABTAR == ;
					xFilial("DTG") + M->DT0_TABFRE +M->DT0_TIPTAB+M->DT0_TABTAR
	
				If ( nLoop := Ascan( aFolder, { |Folder| Folder[1] == DTG->DTG_CODPAS } ) ) > 0
	
					aFolder[nLoop][5] := {}
					aHeader1 := aFolder[nLoop][4]
					aCols1   := aFolder[nLoop][5]
					nCodPas  := DTG->DTG_CODPAS
					cTabFre  := DTG->DTG_TABFRE
					cTiptab  := DTG->DTG_TIPTAB
					cTabTar  := DTG->DTG_TABTAR
					Do While DTG->DTG_FILIAL+DTG->DTG_TABFRE+DTG->DTG_TIPTAB+ DTG->DTG_TABTAR+DTG->DTG_CODPAS == xFilial('DTG')+cTabFre+cTipTab+cTabTar+nCodPas
	
						AAdd(aCols1, Array( Len( aHeader1 ) + 1 ) )
						For nCntFor := 1 To Len(aHeader1)
							If	aHeader1[nCntFor,10] != "V"
								aCols1[Len(aCols1),nCntFor]:= CriaVar(aHeader1[nCntFor,2])
							Else
								If aHeader1[nCntFor,2] == "DT1_ALI_WT" 
									aCols1[Len(aCols1),nCntFor]:= "DT1"
								ElseIf aHeader1[nCntFor,2] == "DT1_REC_WT"
									aCols1[Len(aCols1),nCntFor]:= 0
								Else
									aCols1[Len(aCols1),nCntFor]:= CriaVar(aHeader1[nCntFor,2])
								EndIf
							EndIf
						Next nCntFor
	   
						aCols1[Len(aCols1)][Len( aHeader1 ) + 1 ] := .F. 
						aCols1[Len(aCols1)][GdFieldPos('DT1_ITEM',aHeader1)  ] := DTG->DTG_ITEM  
						aCols1[Len(aCols1)][GdFieldPos('DT1_VALATE',aHeader1)] := DTG->DTG_VALATE
						If GdFieldPos('DT1_VALOR',aHeader1) > 0
							aCols1[Len(aCols1)][GdFieldPos('DT1_VALOR',aHeader1) ] := DTG->DTG_VALOR
						EndIf
						If GdFieldPos('DT1_INTERV',aHeader1) > 0
							aCols1[Len(aCols1)][GdFieldPos('DT1_INTERV',aHeader1)] := DTG->DTG_INTERV
						EndIf
						If GdFieldPos('DT1_FATPES',aHeader1) > 0
							aCols1[Len(aCols1)][GdFieldPos('DT1_FATPES',aHeader1)] := DTG->DTG_FATPES
						EndIf
						aCols1[Len(aCols1)][GdFieldPos('DT1_TARIFA',aHeader1)] := "1"
						aCols1[Len(aCols1)][GdFieldPos('DT1_ALI_WT',aHeader1)] := "DTG"
						aCols1[Len(aCols1)][GdFieldPos('DT1_REC_WT',aHeader1)] := DTG->(Recno())
	
						//-- Salva Area
						SaveInter()
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se o campo Tabela de Tarifa estiver preenchido, carregar o acols com as     ³
						//³ sub-faixas da Tabela de Tarifa (DW0).                                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DT3->(DbSetOrder(1)) //-- DT3_FILAL+DT3_CODPAS
						If lSubFaixa .And. ;
							DT3->(MsSeek(xFilial("DT3")+DTG->DTG_CODPAS)) .And. ;
							!Empty(DT3->DT3_FAIXA2)
							If (nPos:= Ascan( aColsDW1, { |x| x[1]+x[2] == DTG->DTG_CODPAS + DTG->DTG_ITEM } ) ) == 0
								aCols   := {}
								aHeader := {}
								//-- Campos que nao deverao aparecer na getdados
								aNoFields    := { "DW0_TABTAR", "DW0_ITEDTG" }
								aNoFieldsDW1 := { "DW1_ITEDT1" }
								If DT3->DT3_FAIXA2 <> StrZero(1, Len(DT3->DT3_FAIXA2))
									AAdd(aNoFields   ,'DW0_FATPES')
									AAdd(aNoFieldsDW1,'DW1_FATPES')
								EndIf
								FillGetDados(	2, ;
													"DW0", ;
													1, 	 ;
													xFilial("DW0")+M->DT0_TABFRE+M->DT0_TIPTAB+DTG->DTG_TABTAR+DTG->DTG_CODPAS+DTG->DTG_ITEM , ;
													{ || DW0->DW0_FILIAL+DW0->DW0_TABFRE+DW0->DW0_TIPTAB+DW0->DW0_TABTAR+DW0->DW0_CODPAS+DW0->DW0_ITEDTG }, ;
													{|| .T.  },;
												  	aNoFields,;
													/*aYesFields*/,;
										 	  		/*lOnlyYes*/,;
										   			/*cQuery*/,;
													/*bMontCols*/ )
											
								//-- Inicializa o primeiro item da sub-faixa.
								aEval(aCols, {|x| Iif( Empty(x[GdFieldPos('DW0_ITEM')]), x[GdFieldPos('DW0_ITEM')]:= StrZero(1, Len(DW0->DW0_ITEM)), .T.) })
								//-- Armazena aHeader das sub-faixas da tabela de frete.
								If !Empty(aHeadDW1)
									aHeader := aClone(aHeadDW1)
								Else
									aHeadDW1 := TMA010HdDW1(aNoFieldsDW1)
									aHeader  := aClone(aHeadDW1)
								EndIf
								AAdd(aColsDW1,{ DTG->DTG_CODPAS, DTG->DTG_ITEM, AClone(aCols), AClone(aHeader) } )
	
								// Calculo do Excedente por Subfaixa
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Se o campo Tabela de Tarifa estiver preenchido, carregar o acols com os     ³
								//³ excedentes das sub-faixas da Tabela de Tarifa (DY1).                        ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lSubExced   
									//-- Salva Area
									SaveInter()
		
									// processa o ultimo item incluido no vetor para carregar o Excedente por subfaixa
									DY1->(DbSetOrder(1)) //-- DY1_FILIAL+DY1_TABFRE+DY1_TIPTAB+DY1_CDRORI+DY1_CDRDES+DY1_CODPRO+DY1_CODPAS+DY1_ITEDT1+DY1_ITEM
									DY0->(DbSetOrder(1)) //-- DY0_
									posItemDw1 := Ascan(aColsDW1[1,4],{|e| e[2] = "DW1_ITEM" })
									For nLoop1 :=  1 to Len(aColsDW1[Len(aColsDW1),3])
										cItemDw1 := aColsDW1[Len(aColsDW1),3,nLoop1,posItemDw1]
										cChave := DTG->DTG_CODPAS+	DTG->DTG_ITEM
										If (nPos:= Ascan( aColsDY1, { |x| x[1]+x[2] == cChave } ) ) == 0
											DbSelectArea("DY0")
											aCols   := {}
											aHeader := {}
											//-- Campos que nao deverao aparecer na getdados
											aNoFields    := { "DY0_CODPAS", "DY0_TABTAR", "DY0_ITEDTG" }
											aNoFieldsDY0 := { "DY1_CODPAS", "DY1_ITEDT1" }
											FillGetDados(	2, ;
																"DY0", ;
																1, 	 ;
																xFilial("DY0")+M->DT0_TABFRE+M->DT0_TIPTAB+DTG->DTG_TABTAR+DTG->DTG_CODPAS+DTG->DTG_ITEM, ;
																{ || DY0->DY0_FILIAL+DY0->DY0_TABFRE+DY0->DY0_TIPTAB+DY0->DY0_TABTAR+DY0->DY0_CODPAS+DY0->DY0_ITEDTG}, ;
																{|| .T.  },;
															  	aNoFields,;
																/*aYesFields*/,;
													 	  		/*lOnlyYes*/,;
													   			/*cQuery*/,;
																/*bMontCols*/ )
														
											//-- Inicializa o primeiro item da sub-faixa.
											aEval(aCols, {|x| Iif( Empty(x[GdFieldPos('DY0_ITEM')]), x[GdFieldPos('DY0_ITEM')]:= StrZero(1, Len(DY0->DY0_ITEM)), .T.) })
											//-- Armazena aHeader das sub-faixas da tabela de frete.
											If !Empty(aHeadDY1)
												aHeader := aClone(aHeadDY1)
											Else
												aHeadDY1 := TMA010HdDY1(aNoFieldsDY0)
												aHeader  := aClone(aHeadDY1)
											EndIf
											AAdd(aColsDY1,{ DTG->DTG_CODPAS, DTG->DTG_ITEM , AClone(aCols), AClone(aHeader) } )
										EndIf
									Next
									
									//-- Restaura Area
									RestInter()
								EndIf
							
							EndIf
						EndIf
						//-- Restaura Area
						RestInter()
	
	
						DTG->( DbSkip() )
					EndDo
					aFolder[nLoop][5]:= aClone( aCols1 )
					aFolder[nLoop][8]:oBrowse:nOpc:=2
					aFolder[nLoop][8]:lDeleta:= .F.
					aFolder[nLoop][8]:nMax   :=Len(aCols1)
					Loop
				EndIf
	
				DTG->( DbSkip() )
			EndDo
		EndIf
		aCols := aClone( aFolder[nFolder][5] )
		aFolder[nFolder][8]:ForceRefresh()
	EndIf
EndIf	
Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010Min ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Complemento da Tabela de Frete                              ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010Min(ExpN1, ExpL1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±³          ³ExpL1 - Verifica se Mostra ou Nao a GetDados                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA010Min( nOpcx, lMostraGetD )

Local ni
Local aArea       := GetArea()
Local aAreaDT0    := DT0->(GetArea())
Local aOldaHeader := Aclone( aHeader )
Local aOldaCols   := Aclone( aCols )
Local lRet        := .T.
Local nSeek       := 0
Local cSeekKey    := xFilial( "DTK" ) + M->DT0_TABFRE + M->DT0_TIPTAB +  M->DT0_CDRORI + M->DT0_CDRDES + M->DT0_CODPRO
Local cWhile      := "DTK->DTK_FILIAL + DTK->DTK_TABFRE + DTK->DTK_TIPTAB +  DTK->DTK_CDRORI + DTK->DTK_CDRDES + DTK->DTK_CODPRO"
Local aNoFields   := {"DTK_TABFRE","DTK_CDRORI","DTK_CDRDES","DTK_TIPTAB","DTK_CALPAS","DTK_APLAJU"}
Local nOpc        := 0
Local oDlg
Local oGetD
Local nSavN       := IIf(Type('n')=="U",1, n)
Local nCntFor     := 0

Private cFolder

Default lMostraGetD := .T.

//-- Finaliza as Teclas de Atalhos
TmsKeyOff(aSetKey)
aHeader	:= {}
aCols	:= {}

//-- Se for Visualizacao ou Estorno da Tabela de Frete, os arrays auxiliares aHeaderDTK e aColsDTK
//-- ja foram preenchidos pela funcao TMSA010Fol().
If Len(aHeaderDTK) == 0
	FillGetDados( nOpcx, "DTK",1, cSeekKey, {|| &cWhile }, {||.T.}, aNoFields, /*aYesFields*/, /*lOnlyYes*/, /*cQuery*/, {|| MontaAcols("DTK") }/*bMontCols*/)
	aHeaderDTK := AClone(aHeader)
Else
	aHeader := Aclone(aHeaderDTK)
	MontaAcols("DTK")
EndIf

If lMostraGetD

	DEFINE MSDIALOG oDlg TITLE STR0019 From 9,0 To 27.5,80 OF oMainWnd //"Valores Minimos

		oGetD := MSGetDados():New(30,3,138,314,nOpcx,'AllwaysTrue()','AllwaysTrue()',,IIf(nOpcx<>2,.T.,Nil),,,,Len(aFolder) ) 

		TMSA010AjuMin(aColsDTK, aCols)

		oGetD:Refresh(.T.)

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpc :=1, oDlg:End()},{||oDlg:End()}),oGetD:Refresh()) CENTERED	

Else

	nOpc := 1

EndIf

If nOpc == 1
	aColsDTK   := AClone(aCols)
EndIf

aHeader := aClone( aOldaHeader )
aCols   := aClone( aOldaCols )
n       := nSavN

RestArea( aArea )
RestArea( aAreaDT0 )

//-- Inicializa as Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010AjuM³ Autor ³ Patricia A. Salomao³ Data ³ 19/02/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Os Itens do aCols do DTK aparecerao deletados na 1a. chamada³±±
±±³          ³do 'Botao de Complemento da Tabela'.Nas outras chamadas,    ³±±
±±³          ³estes itens poderao estar deletados ou nao.Esta funcao serve³±±
±±³          ³para auxiliar a GetDados a mostrar os itens deletados.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010AjuMin(ExpA1,ExpA2)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - aCols Auxiliar do DTK                               ³±±
±±³          ³ExpA2 - aCols                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Funcao TMSA010Min()                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function  TMSA010AjuMin(aColsDTK, aCols)	 

Local nX

// Se o Item do aCols Auxiliar estiver deletado, deleta este item tambem no aCols 
// Isto tem que ser feito, para que a GetDados mostre os itens deletados na Tela
For nX := 1 To Len(aColsDTK)
	If aColsDTK[nX][Len(aColsDTK[nX])]
		aCols[nX][Len(aCols[nX])] := .T.
	EndIf
Next

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010MOk ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³TudoOk da Tela de Complemento da Tabela de Frete            ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010MOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010MOk()
Local aAreaDT0 := DT0->(GetArea())
Local lRet     := .T.

DT0->(DbSetOrder(1)) //-- DT0_FILIAL+DT0_TABFRE+DT0_TIPTAB+DT0_CDRORI+DT0_CDRDES+CODPRO
If !DT0->(MsSeek(xFilial('DT0')+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO))
	Help("",1, "REGNOIS") //Nao existe registro relacionado a este codigo.
	RestArea(aAreaDT0)
	Return( .F. )
EndIf

If !TMSTbAtiva( DT0->DT0_TABFRE, DT0->DT0_TIPTAB )
	RestArea(aAreaDT0)
	Return( .F. )
EndIf

RestArea(aAreaDT0)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010Vld ³ Autor ³Patricia A. Salomao ³ Data ³ 09/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a Validacao de alguns Campos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010Vld()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010Vld()

Local lRet   := .T.
Local cCampo := ReadVar()
Local aArea  := GetArea()

If cCampo == "M->DT0_CDRORI"
	If !TmsTipReg(M->DT0_CDRORI, StrZero(1, Len(DTN->DTN_TIPREG)))
		lRet := .F.
	EndIf
	DUY->(DbSetOrder(1)) //-- DUY_FILAL+DUY_GRPVEN
	If lRet .And. DUY->(MsSeek(xFilial('DUY')+M->DT0_CDRORI)) .And. Empty(DUY->DUY_GRPSUP)
		Help("",1,"TMSA01021") //Esta Regiao nao podera ser utilizada, pois nao existe no cadastro de Estrutura de Regioes
		lRet := .F.
	EndIf
ElseIf cCampo == "M->DT0_CDRDES" 
	If !TmsTipReg(M->DT0_CDRDES, StrZero(2, Len(DTN->DTN_TIPREG)))
		lRet := .F.
	EndIf
	DUY->(DbSetOrder(1)) //-- DUY_FILAL+DUY_GRPVEN
	If lRet .And. DUY->(MsSeek(xFilial('DUY')+M->DT0_CDRDES)) .And. Empty(DUY->DUY_GRPSUP)
		Help("",1,"TMSA01021") //Esta Regiao nao podera ser utilizada, pois nao existe no cadastro de Estrutura de Regioes   
		lRet := .F.
	EndIf
ElseIf cCampo == "M->DT0_CODPRO"
	If Vazio()
		Return( .T. )
	EndIf
	If !ExistCpo("SB1",M->DT0_CODPRO,1)
		Return( .F. )
	EndIf
EndIf

RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010XBI ³ Autor ³Patricia A. Salomao ³ Data ³ 15/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a Rotina de Inclusao da Tabela de Frete             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010XBI()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consulta SXB - DT0                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010XBI()

TMSA010(3)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010XBV ³ Autor ³Patricia A. Salomao ³ Data ³ 15/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a Rotina de Visualizacao da Tabela de Frete         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010XBV()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consulta SXB - DT0                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010XBV()

TMSA010(2)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AjustaFold   ³ Autor ³Patricia A. Salomao ³ Data ³ 15/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Altera as propriedades do Folder                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AjustaFold(ExpA1,ExpN1,ExpC1)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Objeto Getdados do Folder                             ³±±
±±³          ³ExpN1 - Opcao Selecionada                                     ³±±
±±³          ³ExpC1 - Folder                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AjustaFold(aFolder,nOpcao,cFolder,nMax) 

// Se For elemento de uma Tabela de Tarifa de Frete.
If GdFieldGet("DT1_TARIFA" )== "1" 
	aFolder:oBrowse:nOpc:=2
	aFolder:lDeleta:= .F.
	aFolder:nMax   := nMax
EndIf	

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMA010FilDT³ Autor ³Patricia A. Salomao ³ Data ³ 02/05/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Filtra o Arquivo DTF                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA010XFilDTF()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Filtro da Consulta                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consulta DTF - DT0 (SXB)                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA010FilDTF()
Return( DTF->(DTF_TABFRE+DTF_TIPTAB) == M->DT0_TABFRE+M->DT0_TIPTAB )
  
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010Cpo ³ Autor ³Patricia A. Salomao ³ Data ³ 06/05/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa alguns campos a partir da Regiao Origem informada³±±
±±³          ³na Copia da Tabela de Frete                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010Cpo()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Nova Regiao de Origem                               ³±±
±±³          ³ExpC2 - Alias do Arquivo Temporario                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010Cpo(cNewReg, cAlias)

Local lRet     := .T.
Local aAreaDT0 := DT0->(GetArea())

If Empty(cNewReg)
	Help("",1,"TMSA01013") // Informe a Nova Regiao de Origem ...
	lRet := .F.
EndIf

If lRet
	DUY->(DbSetOrder(1)) //-- DUY_FILAL+DUY_GRPVEN
	If DUY->(MsSeek(xFilial('DUY')+cNewReg))
		cDescNewOri := DUY->DUY_DESCRI
		lRet := .T.
	Else
		Help("",1,"TMSA01014") // Regiao de Origem Nao Cadastrada ...
		lRet := .F.
	EndIf
EndIf

If lRet
	lRet := TmsTipReg(cNewReg, StrZero(1, Len(DTN->DTN_TIPREG)))
EndIf

(cAlias)->(dbGoTop())

RestArea(aAreaDT0)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010Whe ³ Autor ³Patricia A. Salomao ³ Data ³ 25/05/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao de Campo (X3_WHEN)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010Whe()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010Whe()
Local lRet   := .T.   
Local cCampo :=ReadVar()

If cCampo=='M->DT0_CODPRO'
	lRet := Inclui
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010Psq ³ Autor ³Patricia A. Salomao ³ Data ³ 23/09/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Botao de Pesquisa                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010Psq()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1- Nova Regiao de Origem                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA010Psq(cNewReg,cAlias,lCopDes,oMkOld)

Local aCbx		:= {}
Local cCampo	:= ''
Local cOrd
Local lSeek		:= .F.
Local nOrdem	:= 1
Local oCbx, oDlg, oPsqGet

If Empty(cNewReg)
	Help("",1,"TMSA01013") // Informe a Nova Regiao de Origem ...
	Return( .F. )
EndIf

cCampo := AllTrim(getSx3Cache(If(lCopDes,'DT0_CDRORI','DT0_CDRDES'),"X3_Titulo"))
AAdd( aCbx, cCampo )

cCampo := Space( 40 )

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0041 //'Pesquisa'

	@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt
	
	@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL
	
	DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
	DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()
	
ACTIVATE MSDIALOG oDlg CENTERED

If	lSeek
	cCampo := AllTrim( cCampo )
	(cAlias)->(DbSetOrder(If(lCopDes,2,1)))
	(cAlias)->(MsSeek(cCampo))
EndIf

If	!(cAlias)->(Eof())
	oMkOld:oBrowse:nAt:=(cAlias)->(Recno())
	oMkOld:oBrowse:Refresh(.T.)
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMA010Est   ³ Autor ³Patricia A. Salomao ³ Data ³06.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza a Estrutura do Cadastro de Tabela de Frete (DT0) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA010Est()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010Est()

Local aAreaAnt	:= GetArea()
Local aSizeAut	:= MsAdvSize( .F. )
Local aObjects	:= {}
Local aInfo		:= {}
Local aObj		:= {}
Local nOpcA		:= 0
Local cCadOld	:= cCadastro
Local aButtons	:= {}
Local oDlg
Local oBrowse	:= GetMBrowse()

Private oTree
Private aSetKey := {}

cCatTab     := IIf( ValType(cCatTab)=="C", cCatTab, StrZero(1, Len(DT0->DT0_CATTAB)) ) 

cCadastro   := STR0047  //'Estrutura de Tabelas'

AAdd(aSetKey, { VK_F4, { || TMSA010Pes(oTree) } } )
AAdd(aSetKey, { VK_F5, { || TMSA010Vis() } } )
AAdd(aSetKey, { VK_F6, { || TmsA010Leg() } } )

//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

AAdd( aButtons, {"PESQUISA"	,	{||TMSA010Pes(oTree)},	STR0046,	STR0042}) //"Pesquisar - <F4>"
AAdd( aButtons, {"RELATORIO",	{||TMSA010Vis()},		STR0045,	STR0044}) //"Visualizar Tabela - <F5>"
AAdd( aButtons, {"PLNPROP"	,	{||TmsA010Leg()},		STR0040,	STR0039}) //"Legenda da categoria do grupo de regioes - <F6>"
aSize := MsAdvSize()

AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg FROM aSizeAut[7],00 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL 

	oTree := DbTree():New( aObj[1,1], aObj[1,2], aObj[1,3], aObj[1,4],oDlg,,,.T.)
	oTree:LShowHint := .F.

	//-- Chama a rotina de construcao do Tree
	Processa( { || TMA010Monta( @oTree, cCatTab ) }, , STR0038 ) //"Construindo Estrutura"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1, If(nOpca==1,oDlg:End(),nOpca := 0)},{||oDlg:End()},, aButtons )             

cCadastro := cCadOld

RestArea(aAreaAnt)

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMA010Monta ³ Autor ³Patricia A. Salomao ³ Data ³06.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o tree.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA010Monta(ExpO1,ExpC1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto Tree                                        ³±±
±±³          ³ ExpC1 - Categoria da Tab.Frete : 1-Tabela Frete a Receber  ³±±
±±³          ³                                  2-Tabela Frete a Pagar    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA010Monta( oTree, cCatTab )

Local aAreaAnt	:=  GetArea()
Local aAreaDT0	:=  DT0->( GetArea() )
Local cCargo	:=  ''
Local cSeek		:=  xFilial('DT0')
Local cSeek1	:=  ''
Local cSeek2	:=  ''
Local lAchou    :=  .F.
Local cCadOld   := ''
Local cDesc     := ''
Local cProd     := ''
Local cAliasTRB := ''
Local cAliasDT0 := 'DT0'
Local cAliasSB1 := 'SB1'
Local cDescri   := ''
Local cCdrCol   := ''
Local cCatReg   := ''
Local cCatGrp   := ''
Local cTabFre   := DT0->DT0_TABFRE
Local cTipTab   := DT0->DT0_TIPTAB
Local bWhile
   
Default cCatTab := StrZero(1,Len(DT0->DT0_CATTAB)) 

cAliasTRB := GetNextAlias()
cQuery := " SELECT DT0.DT0_FILIAL DT0_FILIAL, DT0.DT0_CDRORI DT0_CDRORI, DT0.DT0_CDRDES DT0_CDRDES, "
cQuery += "        DT0.DT0_CODPRO DT0_CODPRO, DT0.DT0_TABFRE DT0_TABFRE, DT0.DT0_TIPTAB DT0_TIPTAB, "
cQuery += "        DUYD.DUY_DESCRI D_DESCRI , DUYD.DUY_CDRCOL D_CDRCOL , DUYD.DUY_CATREG D_CATREG , "
cQuery += "        DUYD.DUY_CATGRP D_CATGRP , DUYO.DUY_DESCRI O_DESCRI , DUYO.DUY_CDRCOL O_CDRCOL , "
cQuery += "        DUYO.DUY_CATREG O_CATREG , DUYO.DUY_CATGRP O_CATGRP , "
cQuery += "        B1_DESC "
cQuery += " FROM " + RetSqlName("DT0") + " DT0  "
cQuery += " JOIN " + RetSqlName("DUY") + " DUYD "
cQuery += "   ON  DUYD.DUY_FILIAL = '" + xFilial("DUY") + "' "
cQuery += "   AND DUYD.DUY_GRPVEN = DT0.DT0_CDRDES "
cQuery += "   AND DUYD.D_E_L_E_T_ = ' ' "
cQuery += " JOIN " + RetSqlName("DUY") + " DUYO "
cQuery += "   ON  DUYO.DUY_FILIAL = '" + xFilial("DUY") + "' "
cQuery += "   AND DUYO.DUY_GRPVEN = DT0.DT0_CDRORI "
cQuery += "   AND DUYO.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN " + RetSqlName("SB1") + " SB1 "
cQuery += "   ON  SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += "   AND SB1.B1_COD = DT0.DT0_CODPRO "
cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE DT0.DT0_FILIAL  = '" + xFilial("DT0") + "' "
cQuery += "   AND DT0.DT0_CATTAB  = '" + cCatTab + "' "
cQuery += "   AND DT0.DT0_TABFRE  = '" + DT0->DT0_TABFRE + "' "
cQuery += "   AND DT0.DT0_TIPTAB  = '" + DT0->DT0_TIPTAB + "' "
cQuery += "   AND DT0.D_E_L_E_T_  = ' ' "
cQuery += " ORDER BY DT0_FILIAL,DT0_CDRORI, DT0_CDRDES "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB, .F., .T.)
cAliasDT0 := cAliasTRB
cAliasSB1 := cAliasTRB
bWhile    := { || .T. }

oTree:AddTree(PadR( STR0001 +" ( "+DT0->DT0_TABFRE+" - "+DT0->DT0_TIPTAB+" ) ", 150),.T.,,,'FOLDER5','FOLDER6',Padr('0MA-MAINGR', 40))

Do While !(cAliasDT0)->(Eof()) .And. Eval( bWhile )
	
	cDescri := (cAliasTRB)->O_DESCRI
	cCdrCol := (cAliasTRB)->O_CDRCOL
	cCatReg := (cAliasTRB)->O_CATREG
	cCatGrp := (cAliasTRB)->O_CATGRP
	
	//-- Monta a descricao da pasta.
	cDesc   := PadR( (cAliasDT0)->DT0_CDRORI  + '-' + Capital( cDescri ) + Iif(Empty(cCdrCol),'',Space(10) +'(' + STR0013 + cCdrCol + ')'), 150 ) //"Coligada a Região: "
	cCadOld := cCargo
	
	//-- Adiciona nova pasta no tree contendo a Regiao Origem
	cCargo := '01' + (cAliasDT0)->DT0_CDRORI

	//-- Base para Taxa
	If	cCatReg == StrZero(2,Len(DUY->DUY_CATREG))
		oTree:AddTree(cDesc,.T.,,,'FOLDER7','FOLDER8',cCargo)
	Else
		//-- Estado
		If	cCatGrp == StrZero(1,Len(DUY->DUY_CATGRP))
			oTree:AddTree(cDesc,.T.,,,'FOLDER10','FOLDER11',cCargo)
			//-- Filial
		ElseIf cCatGrp == StrZero(2,Len(DUY->DUY_CATGRP))
			oTree:AddTree(cDesc,.T.,,,'FOLDER12','FOLDER13',cCargo)
			//-- Regiao
		ElseIf cCatGrp == StrZero(3,Len(DUY->DUY_CATGRP))
			oTree:AddTree(cDesc,.T.,,,'FOLDER5','FOLDER6',cCargo)
		EndIf
	EndIf
	
	cSeek1 := xFilial('DT0') +  (cAliasDT0)->DT0_CDRORI
	Do While (cAliasDT0)->( ! Eof() .And. (cAliasDT0)->DT0_FILIAL + (cAliasDT0)->DT0_CDRORI == cSeek1 )
		
		cDescri := (cAliasTRB)->D_DESCRI
		cCdrCol := (cAliasTRB)->D_CDRCOL
		cCatReg := (cAliasTRB)->D_CATREG
		cCatGrp := (cAliasTRB)->D_CATGRP
		
		cCargo := '01' + (cAliasDT0)->DT0_CDRORI
		//-- Monta a descricao da pasta.
		cDesc := Padr( (cAliasDT0)->DT0_CDRDES + '-' + Capital( cDescri ) + Iif(Empty(cCdrCol),'',Space(10) + '(' + STR0013 + cCdrCol + ')'), 150 ) //"Coligada a Região: "
		
		//-- Adiciona nova pasta no tree contendo todas as Regioes de Destino Cadastradas para
		//-- a Regiao de Origem
		cCargo := '02' + (cAliasDT0)->DT0_CDRORI+(cAliasDT0)->DT0_CDRDES+(cAliasDT0)->DT0_TABFRE+(cAliasDT0)->DT0_TIPTAB
		
		//-- Base para Taxa
		If	cCatReg == StrZero(2,Len(DUY->DUY_CATREG))
			oTree:AddTree(cDesc,.T.,,,'FOLDER7','FOLDER8',cCargo)
		Else
			//-- Estado
			If	cCatGrp == StrZero(1,Len(DUY->DUY_CATGRP))
				oTree:AddTree(cDesc,.T.,,,'FOLDER10','FOLDER11',cCargo)
				//-- Filial
			ElseIf cCatGrp == StrZero(2,Len(DUY->DUY_CATGRP))
				oTree:AddTree(cDesc,.T.,,,'FOLDER12','FOLDER13',cCargo)
				//-- Regiao
			ElseIf cCatGrp == StrZero(3,Len(DUY->DUY_CATGRP))
				oTree:AddTree(cDesc,.T.,,,'FOLDER5','FOLDER6',cCargo)
			EndIf
		EndIf
		
		cSeek2 := xFilial('DT0')+ (cAliasDT0)->DT0_CDRORI + (cAliasDT0)->DT0_CDRDES
		
		Do While (cAliasDT0)->( ! Eof() .And. (cAliasDT0)->DT0_FILIAL + (cAliasDT0)->DT0_CDRORI+(cAliasDT0)->DT0_CDRDES == cSeek2 )
			
			lAchou  := .T.

			//-- Produto
			If !Empty((cAliasDT0)->DT0_CODPRO)
				cDesc := (cAliasSB1)->B1_DESC
				cProd := STR0029 + Substr(cDesc,1,25) //Produto :
				//-- Monta a descricao da pasta.
				cDesc  := PadR( cProd , 150)	
				//-- Adiciona nova pasta no tree contendo todas as Configuracoes Cadastradas para as Tabelas com
				//-- esta Regiao de Origem e Destino
				cCargo := '03' + (cAliasDT0)->DT0_CDRORI+(cAliasDT0)->DT0_CDRDES+(cAliasDT0)->DT0_TABFRE+(cAliasDT0)->DT0_TIPTAB+(cAliasDT0)->DT0_CODPRO			
				oTree:AddTreeItem(cDesc,'FOLDER5','FOLDER6',cCargo)
			EndIf

			(cAliasDT0)->(DbSkip())
		EndDo
		oTree:EndTree()
		If !lAchou
			(cAliasDT0)->(DbSkip())
		EndIf
	EndDo
	oTree:EndTree()
	cCargo := cCadOld
EndDo

RestArea(aAreaAnt)

(cAliasTRB)->(DbCloseArea())

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA010Vis  ³ Autor ³Patricia A. Salomao ³ Data ³06.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza a Tabela de Frete Posicionada no Tree            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA010Vis()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA010Vis()

Local lRet     := .T.
Local cCargo   := oTree:GetCargo()
Local aAreaDT0 := DT0->(GetArea())

//-- Finaliza as Teclas de Atalhos
TmsKeyOff(aSetKey)

If Left( cCargo, 2 ) == '02' .Or. Left( cCargo, 2 ) == '03' // Pasta que contem a Configuracao da Tabela
	DT0->(DbSetOrder(2)) //-- DT0_FILIAL+DT0_CDRORI+DT0_CDRDES+DT0_TABFRE+DT0_TIPTAB+CODPRO
	If DT0->( MsSeek( xFilial( 'DT0' ) + AllTrim(SubStr(cCargo, 3, Len(AllTrim(cCargo))))  ) )
		If l010MVC
			FWExecView(STR0003,"VIEWDEF.TMSA010", MODEL_OPERATION_VIEW,, { || .T. } ,,  /*nPerReducTela*/ ) //"Visualizar"
		Else
			TMSA010Mnt('DT0' ,DT0->(Recno() ), 2 )
		EndIf
	EndIf
Else
	Help('',1,'TMSA01015') //Escolha o Lay-Out da Tabela para visualizar
	lRet := .F.
EndIf

RestArea(aAreaDT0)

//-- Inicializa as Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA010Pes  ³ Autor ³ Patricia A. Salomao³ Data ³09.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa a Reg. Origem / Destino no Tree                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA010Pes(ExpO1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Tree                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010Pes( oTree )

Local cChavePsq1 := CriaVar('DT0_CDRDES', .F.)
Local cChavePsq2 := CriaVar('DT0_CDRORI', .F.)
Local nOpca      := 0
Local oDlg, oBut1, oBut2, oGetPesq1, oGetPesq2

//-- Finaliza as Teclas de Atalhos
TmsKeyOff(aSetKey)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 09,0 TO 21.2,43.5 OF oMainWnd

	@ 0, 0 BITMAP oBmp RESNAME 'LOGIN' 	OF oDlg	SIZE 30,120 NOBORDER WHEN .F.	PIXEL
	@ 14, 30 TO 16 ,400 LABEL '' OF oDlg PIXEL
	@ 22, 40 SAY STR0028 SIZE 40, 09 PIXEL //Localizar :
	@ 35, 40 SAY Rtrim(RetTitle("DT0_CDRORI"))			SIZE 40, 09	PIXEL
	@ 35, 80 MSGET oGetPesq1 VAR cChavePsq1 F3 'DUY'	SIZE 80, 10 VALID .T. PIXEL
	@ 48, 40 SAY Rtrim(RetTitle("DT0_CDRDES"))			SIZE 40, 09	PIXEL 
	@ 48, 80 MSGET oGetPesq2 VAR cChavePsq2	F3 'DUY'	SIZE 80, 10 VALID .T. PIXEL
	
	DEFINE SBUTTON oBut1 FROM 67,  99 TYPE 1 ACTION ( nOpca := 1,oDlg:End() ) ENABLE OF oDlg
	DEFINE SBUTTON oBut2 FROM 67, 132 TYPE 2 ACTION ( nOpca := 0,oDlg:End() ) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1 .And. !oTree:TreeSeek("02"+cChavePsq1+cChavePsq2)
	Help(' ',1,'TMSA01016') //-- Regiao de Origem / Destino Nao Encontradas na Estrutura de Tabelas
	//-- Inicializa as Teclas de Atalhos
	TmsKeyOn(aSetKey)
	Return( .F. )
EndIf

//-- Inicializa as Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010RedL³ Autor ³ Patricia A. Salomao³ Data ³ 15.03.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³LinhaOk da Tela de Redespacho                               ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010RedLOk()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA010RedLOk()

Local lRet := .T.

If !GdDeleted(n)
	lRet := MaCheckCols(aHeader,aCols,n)
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA010Leg ³ Autor ³ Eduardo de Souza     ³ Data ³ 20/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Apresenta a Legenda                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA010Leg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA010Leg()

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

TmsA120Leg()

//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( Nil )

//-- Utilizada para validar se o programa esta atualizado na chamada da TmsCalFret().
Function TMSA010UPD()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMA010Mrk  ³ Autor ³ Patricia A. Salomao³ Data ³ 02.05.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Marca / Desmarca item para copia                            ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA010Mrk()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Arquivo Temporario                                  ³±± 
±±³          ³ExpC2 - Alias do Arquivo Temporario                         ³±±
±±³          ³ExpC3 - Objeto da Mark                                      ³±± 
±±³          ³ExpL1 - Verifica se Marca / Desmarca todos os itens         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA010Mrk(cTemp,cAlias,oMark, lMarkAll)
Local lRet       := .T.
Local cQuery     := ""
Local l010Marca  := (cAlias)->( IsMark( 'MARK', ThisMark(), ThisInv() ) )
Default lMarkAll := .F.

CursorWait()

cMark := ThisMark()

If !l010Marca
	cQuery  := "UPDATE " + cTemp + " SET MARK = '"+cMark+"'"
	If !lMarkAll //-- Marca somente o item posicionado
		cQuery  += " WHERE R_E_C_N_O_ = " + Str( (cAlias)->( Recno() ) ) 
	EndIf
Else
	cQuery  := "UPDATE " + cTemp + " SET MARK = '  ' "
	If !lMarkAll //-- Desmarca somente o item posicionado
		cQuery  += " WHERE R_E_C_N_O_ = " + Str( (cAlias)->( Recno() ) )
	EndIf
EndIf

If TCSqlExec( cQuery ) <> 0
	Help("",1,"TMSA01022") //Erro ao Marcar/Desmarcar Item
	lRet := .F.
EndIf

TCRefresh(cTemp)

oMark:oBrowse:DrawSelect()

oMark:oBrowse:Refresh()

CursorArrow()

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMSA010Vd2  ³ Autor ³ Eduardo de Souza     ³ Data ³ 27/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida sub-faixa para o componente principal.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA080Vd2()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA080                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA010Vd2(cCodPas,cItem)

Local lRet := .F.
Local nPos := 0

//-- Verifica se o componente de frete utiliza sub-faixa.
If Empty(Posicione("DT3",1,xFilial("DT3")+cCodPas,"DT3_FAIXA2"))
	lRet := .T.
Else
	//-- Verifica se foi informado alguma sub-faixa para o componente.
	If (nPos := Ascan( aColsDW1, { |x| x[1]+x[2] == cCodPas + cItem } )) > 0 .And. ;
			Ascan( aColsDW1[nPos,3], { |x| ! x[Len(x)] } ) > 0
		lRet := .T.
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMSA010SFx  ³ Autor ³ Eduardo de Souza     ³ Data ³ 26/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apresenta Sub-Faixa                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA010SFx()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA010SFx(nOpcx)

Local cTitTabFre  := AllTrim(RetTitle("DW1_TABFRE"))
Local cTitTipTab  := AllTrim(RetTitle("DW1_TIPTAB"))
Local cTitCodPas  := AllTrim(RetTitle("DW1_CODPAS"))
Local cTitItem    := AllTrim(RetTitle("DW1_ITEM"  ))
Local oDlgEsp
Local oGetSub
Local aSize       := {}
Local aInfo       := {}
Local aObjects    := {}
Local aPosObj     := {}
Local nPos        := 0
Local nOpcao      := 0
Local lAchou      := .F.
Local nCnt        := 0
Local cCodPas     := aFolder[nFolder,1]
Local cItem       := GDFieldGet("DT1_ITEM",n)
Local lTarifa     := ( GDFieldGet("DT1_TARIFA",n) == StrZero(1,Len(DT1->DT1_TARIFA)) ) //-- Preenchido pela tarifa
Local aNoFields   := { "DW1_ITEDT1" }
Local nPosValAte  := 0
Local aRetBox     := {}
Local cFolderName := ''

// Calculo do Excedente por Subfaixa
Local aButtons    := {}

SaveInter() //-- Salva Area

aCols   := {}
aHeader := {}

//-- Verifica se existe o componente de frete.
DT3->(DbSetOrder(1)) //-- DT3_FILAL+DT3_CODPAS
If !DT3->(MsSeek(xFilial("DT3")+cCodPas))
	Help("",1,"TMSA01018") //-- Componente de frete nao encontrado.
	RestInter() //-- Restaura Area
	Return( .F. )
EndIf

//-- Verifica se o componente utiliza sub-faixa.
If Empty(DT3->DT3_FAIXA2)
	Help("",1,"TMSA01019") //-- Componente de frete nao configurado para utilizar sub-faixa.
	RestInter() //-- Restaura Area
	Return( .F. )
EndIf

// Calculo do Excedente por Subfaixa
If FindFunction("TMSA010Comp") .And. AliasInDic("DY1")
	AAdd(aButtons,	{'PRECO',{|| TMSA010Comp(nOpcx,cItem,lTarifa) },STR0053, STR0054 })
EndIf

//-- preenchimento automatico pela tarifa.
If lTarifa
	nOpcx := 2
EndIf

If DT3->DT3_FAIXA2 <> StrZero(1, Len(DT3->DT3_FAIXA2))
	AAdd(aNoFields,'DW1_FATPES')
EndIf

If (nPos:= Ascan( aColsDW1, { |x| x[1]+x[2] == cCodPas + cItem } ) ) == 0
	FillGetDados(	nOpcx, ;
						"DW1", ;
						1, 	 ;
						xFilial("DW1")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+cCodPas+cItem , ;
						Iif(nOpcx <> 3,{ || DW1->DW1_FILIAL+DW1->DW1_TABFRE+DW1->DW1_TIPTAB+DW1->DW1_CDRORI+DW1->DW1_CDRDES+DW1->DW1_CODPRO+DW1->DW1_CODPAS+DW1->DW1_ITEDT1 },{|| ''   }), ;
						{|| .T.  },;
						aNoFields,;
				 		/*aYesFields*/,;
				   		/*lOnlyYes*/,;
				  	  	/*cQuery*/,;
						/*bMontCols*/)
						
	//-- Inicializa o primeiro item da sub-faixa.
	aEval(aCols, {|x| Iif( Empty(x[GdFieldPos('DW1_ITEM')]), x[GdFieldPos('DW1_ITEM')]:= StrZero(1, Len(DW1->DW1_ITEM)), .T.) })
Else
	lAchou   := .T.
	aCols    := AClone(aColsDW1[nPos,3]	)
	aHeader  := AClone(aColsDW1[nPos,4])
	//-- Inicializa todas as linhas do aCols como nao deletado, devido a falha na GetDados
	For nCnt := 1 To Len(aCols)
		aCols[nCnt,Len(aHeader)+1] := .F.
	Next nCnt
EndIf

//-- Inicio da troca do aHeader refletindo o nome da faixa.
nPosValAte	:= Ascan( aHeader, { |aField| aField[2] = "DW1_VALATE" } )

//-- Esse array contem as descricoes existentes no ComboBox do campo DT3_FAIXA2
aRetBox 	:= RetSx3Box(TMSA030BFX(),,, Len(DT3->DT3_FAIXA2)) //-- Esse array contem as descricoes existentes no ComboBox do campo DT3_FAIXA 
cFolderName := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == DT3->DT3_FAIXA2} ), 3 ])

aHeader[nPosValAte,1] := AllTrim(getSx3Cache("DW1_VALATE",'X3_Titulo')) + Space( 10 ) + "(" +  cFolderName + ")" 
//-- Fim da troca do aHeader refletindo o nome da faixa.

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 90, 010, .T., .T. } )
AAdd( aObjects, { 90, 080, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE STR0027 FROM aSize[7]/2,00 TO aSize[6]/2,aSize[5]/2+100 PIXEL 	//Tabela de Frete - Subfaixa

@ aPosObj[1,1],010 SAY cTitTabFre + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],038 SAY M->DT0_TABFRE Of oDlgEsp PIXEL SIZE 29 ,9

@ aPosObj[1,1],055 SAY cTitTipTab + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],070 SAY M->DT0_TIPTAB Of oDlgEsp PIXEL SIZE 10 ,9

@ aPosObj[1,1],080 SAY cTitCodPas + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 35 ,9
@ aPosObj[1,1],115 SAY Posicione("DT3",1,xFilial("DT3")+cCodPas,"DT3_DESCRI") Of oDlgEsp PIXEL SIZE 40 ,9

@ aPosObj[1,1],185 SAY cTitItem + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],200 SAY cItem Of oDlgEsp PIXEL SIZE 10 ,9

oGetSub:=MSGetDados():New(aPosObj[2,1]/2, aPosObj[2,2]/2, aPosObj[2,3]/2, aPosObj[2,4]/2+50, nOpcx, 'TMSA010SLOk()','AllWaysTrue',"+DW1_ITEM",nOpcx<>2)

//-- Atualiza aCols corrigindo a falha na GetDados
If(lAchou,aCols := AClone(aColsDW1[nPos,3]),.T.)
oGetSub:Refresh(.T.)

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| If(oGetSub:TudoOk(),(nOpcao:= 1,oDlgEsp:End()),.F.)},{|| oDlgEsp:End() },,aButtons ) CENTERED

//-- Atualiza array de aCols da sub-faixa
If nOpcao == 1
	If (nPos:= Ascan( aColsDW1, { |x| x[1]+x[2] == cCodPas+cItem } ) ) == 0
		AAdd(aColsDW1,{ cCodPas, cItem, AClone(aCols), AClone(aHeader) } )
	Else
		aColsDW1[nPos,3] := AClone(aCols)
	EndIf
EndIf

RestInter() //-- Restaura Area

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMSA010SLOk ³ Autor ³ Eduardo de Souza     ³ Data ³ 27/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida linha da sub-faixa                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA010SLOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010SLOk()

Local lRet       := .F.
Local nPosValAte := GDFieldPos("DW1_VALATE")
Local nPosFatPes := GDFieldPos("DW1_FATPES")
Local nValAte	 := aCols[n][nPosValAte]
Local nValPes    := If(nPosFatPes > 0, aCols[n][nPosFatPes], 0)

lRet := MaCheckCols(aHeader,aCols,n)

//-- Valida se esta deletado
If lRet
	If GDDeleted(n)
		lRet := .T.
	//-- Na primeira linha Valida p/ baixo
	ElseIf n == 1
		lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
										(nValAte >= aLine[nPosValAte] .Or. ;
										IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )}, 2 ) == 0
	//-- Na ultima linha Valida p/ cima
	ElseIf n == Len( aCols )
		lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
										(nValAte <= aLine[nPosValAte]	.Or.;
										IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) )}, 1, Len( Acols ) - 1 ) == 0
	//-- Valida Acima e Abaixo
	Else			
		lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
										(nValAte <= aLine[nPosValAte] .Or. ;
										IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) ) } , 1, n - 1 ) == 0
		
		lRet := lRet .And. ;
				   Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. ;
										(nValAte >= aLine[nPosValAte] .Or.;
										IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )	}, n + 1 ) == 0
	EndIf
	
	If !lRet
		Help(" ",1,"TMSA01007") //"Campo Ate'/Fator Peso Invalido ou ja existente"
	EndIf

	If lRet .And. !GdDeleted(n) .And. nPosFatPes >0 .And. GDFieldGet('DW1_FATPES',n) < GDFieldGet('DW1_VALATE',n)
		Help("", 1,"TMSA01008")  //"O Fator de Peso Nao pode ser menor do que o Peso ..."
		lRet := .F.
	EndIf

EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMSA010CTar ³ Autor ³ Eduardo de Souza     ³ Data ³ 02/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Alimenta Tarifas                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA010CTar()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA010CTar(cTabTar,nOpcx)

Local aHTmp        := {}
Local nCntFor      := 0
Local nLoop1       := 0
Local cCampo       := ''
Local lSubFaixa    := FindFunction("ALIASINDIC") .And. AliasInDic("DW1")
Local lSubExced    := FindFunction("ALIASINDIC") .And. lSubFaixa .And. AliasInDic("DY1") .And. AliasIndic("DY0")
Local aNoFields    := {}
Local aNoFieldsDW1 := {}

//-- Campos que nao deverao aparecer na getdados
If lSubFaixa
	aNoFields    := { "DW0_TABTAR", "DW0_ITEDTG" }
	aNoFieldsDW1 := { "DW1_ITEDT1" }
	If DT3->DT3_FAIXA2 <> StrZero(1, Len(DT3->DT3_FAIXA2))
		AAdd(aNoFields   ,'DW0_FATPES')
		AAdd(aNoFieldsDW1,'DW1_FATPES')
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o campo Tabela de Tarifa estiver preenchido, carregar o acols com os     ³
//³ componentes da Tabela de Tarifa (DTG).                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DTG->(DbSetOrder(1)) //-- DTG_FILIAL+DTG_TABFRE+DTG_TIPTAB+DTG_TABTAR+DTG_CODPAS+DTG_ITEM
If !Empty(cTabTar) .And. DTG->(MsSeek(xFilial("DTG")+M->DT0_TABFRE+M->DT0_TIPTAB+cTabTar+DT3->DT3_CODPAS))
	aHTmp := Aclone(aHeader)
	aCols := {}
	DbSelectArea("DTG")
	While DTG->(!Eof()) .And. DTG->DTG_FILIAL+DTG->DTG_TABFRE+DTG->DTG_TIPTAB+DTG->DTG_TABTAR+DTG->DTG_CODPAS == xFilial("DTG")+M->DT0_TABFRE+M->DT0_TIPTAB+cTabTar+DT3->DT3_CODPAS
		AAdd(aCols,Array(Len(aHTmp)+1))
		For nCntFor:= 1 To Len(aHTmp)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Troca o Prefixo do AHeader de DT1 para DTG                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCampo := StrTran(aHTmp[nCntFor,2],"DT1",PrefixoCpo("DTG"))
			If DTG->(FieldPos(cCampo))> 0
				aHTmp[nCntFor,2] := cCampo
				If	aHTmp[nCntFor,10] != "V"
					aCols[Len(aCols),nCntFor]:=FieldGet(FieldPos(aHTmp[nCntFor,2]))
				Else
					aCols[Len(aCols),nCntFor]:=CriaVar(aHTmp[nCntFor,2])
				EndIf
			ElseIf cCampo == "DTG_ALI_WT"
				aCols[Len(aCols),nCntFor]:= "DTG"
			ElseIf cCampo == "DTG_REC_WT"
				aCols[Len(aCols),nCntFor]:= DTG->(Recno())
			EndIf
		Next nCntFor
		aEval(aCols, {|x| x[GdFieldPos('DT1_TARIFA')]:= "1"})
		aCols[Len(aCols),Len(aHTmp)+1]:=.F.
		//-- Salva Area
		SaveInter()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o campo Tabela de Tarifa estiver preenchido, carregar o acols com as     ³
		//³ sub-faixas da Tabela de Tarifa (DW0).                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSubFaixa .And. !Empty(DT3->DT3_FAIXA2)
			If (nPos:= Ascan( aColsDW1, { |x| x[1]+x[2] == DTG->DTG_CODPAS + DTG->DTG_ITEM } ) ) == 0
				aCols   := {}
				aHeader := {}
				FillGetDados(	nOpcx, ;
									"DW0", ;
									1, 	 ;
									xFilial("DW0")+M->DT0_TABFRE+M->DT0_TIPTAB+DTG->DTG_TABTAR+DTG->DTG_CODPAS+DTG->DTG_ITEM , ;
									Iif(nOpcx <> 3,{ || DW0->DW0_FILIAL+DW0->DW0_TABFRE+DW0->DW0_TIPTAB+DW0->DW0_TABTAR+DW0->DW0_CODPAS+DW0->DW0_ITEDTG },{|| ''   }), ;
									{|| .T.  },;
									aNoFields,;
							 		/*aYesFields*/,;
							   		/*lOnlyYes*/,;
							     	/*cQuery*/,;
							   		/*bMontCols*/)
									
				//-- Inicializa o primeiro item da sub-faixa.
				aEval(aCols, {|x| Iif( Empty(x[GdFieldPos('DW0_ITEM')]), x[GdFieldPos('DW0_ITEM')]:= StrZero(1, Len(DW0->DW0_ITEM)), .T.) })
				//-- Armazena aHeader das sub-faixas da tabela de frete.
				If !Empty(aHeadDW1)
					aHeader := aClone(aHeadDW1)
				Else
					aHeadDW1 := TMA010HdDW1(aNoFieldsDW1)
					aHeader  := aClone(aHeadDW1)
				EndIf
				AAdd(aColsDW1,{ DTG->DTG_CODPAS, DTG->DTG_ITEM, AClone(aCols), AClone(aHeader) } )
				
				// Calculo do Excedente por Subfaixa
				// processa o ultimo item incluido no vetor para carregar o Excedente por subfaixa
				If lSubExced
					DY1->(DbSetOrder(1)) //-- DY1_FILIAL+DY1_TABFRE+DY1_TIPTAB+DY1_CDRORI+DY1_CDRDES+DY1_CODPRO+DY1_CODPAS+DY1_ITEDT1+DY1_ITEM
					DY0->(DbSetOrder(1))
					posItemDw1 := Ascan(aColsDW1[1,4],{|e| e[2] = "DW1_ITEM" })
					For nLoop1 :=  1 to Len(aColsDW1[Len(aColsDW1),3])
						cItemDw1 := aColsDW1[Len(aColsDW1),3,nLoop1,posItemDw1]
						cChave := DTG->DTG_CODPAS+	DTG->DTG_ITEM
						If (nPos:= Ascan( aColsDY1, { |x| x[1]+x[2] == cChave } ) ) == 0
							DbSelectArea("DY0")
							aCols   := {}
							aHeader := {}
							//-- Campos que nao deverao aparecer na getdados
							aNoFields    := { "DY0_CODPAS", "DY0_TABTAR", "DY0_ITEDTG" }
							aNoFieldsDY0 := { "DY1_CODPAS", "DY1_ITEDT1" }
							FillGetDados(	2, ;
												"DY0", ;
												1, 	 ;
												xFilial("DY0")+M->DT0_TABFRE+M->DT0_TIPTAB+DTG->DTG_TABTAR+DTG->DTG_CODPAS+DTG->DTG_ITEM, ;
												{ || DY0->DY0_FILIAL+DY0->DY0_TABFRE+DY0->DY0_TIPTAB+DY0->DY0_TABTAR+DY0->DY0_CODPAS+DY0->DY0_ITEDTG }, ;
												{|| .T.  },;
											  	aNoFields,;
												/*aYesFields*/,;
										 	  	/*lOnlyYes*/,;
										   		/*cQuery*/,;
												/*bMontCols*/ )
											
							//-- Inicializa o primeiro item da sub-faixa.
							aEval(aCols, {|x| Iif( Empty(x[GdFieldPos('DY0_ITEM')]), x[GdFieldPos('DY0_ITEM')]:= StrZero(1, Len(DY0->DY0_ITEM)), .T.) })
							If !Empty(aHeadDY1)
								aHeader := aClone(aHeadDY1)
							Else
								aHeadDY1 := TMA010HdDY1(aNoFieldsDY0)
								aHeader  := aClone(aHeadDY1)
							EndIf
							//-- Armazena aHeader das sub-faixas da tabela de tarifa
							AAdd(aColsDY1,{ DTG->DTG_CODPAS, DTG->DTG_ITEM, AClone(aCols), AClone(aHeader) } )
						EndIf
					Next
				EndIf
				
			EndIf
		EndIf
		//-- Restaura Area
		RestInter()
		DbSelectArea("DTG")
		DTG->(DbSkip())
	EndDo
	aFolder[Len(aFolder)][5] := Aclone(aCols)
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMA010HdDW1 ³ Autor ³ Eduardo de Souza     ³ Data ³ 02/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ aHeader da sub-faixa da tabela de tarifa                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA010CTar()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA010HdDW1(aNoFieldsDW1)

//--Armazena aCols e aHeader
SaveInter()

aCols   := {}
aHeader := {}
//-- Monta o array aHeader para a GetDados()
If Len(aHeadDW1) == 0
	FillGetDados(nOpcao,"DW1",1,/*xFilial("DW1")*/,{|| },{||.T.},aNoFieldsDW1,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/)
	aHeadDW1 := aClone(aHeader)
EndIf

//--Restaura aCols e aHeader
RestInter()

Return( aHeadDW1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
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
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()
Local aRotAux
If l010MVC
	aRotAux := FWLoadMenuDef( 'TMSA010A' )
Else
	Private aRotina	:=	{	{ STR0002 ,"TmsXPesqui", 0, 1,0,.F. },;	//"Pesquisar"
							{ STR0003 ,"TMSA010Mnt", 0, 2,0,Nil },;	//"Visualizar"
							{ STR0004 ,"TMSA010Mnt", 0, 3,0,Nil },;	//"Incluir"
							{ STR0005 ,"TMSA010Mnt", 0, 4,0,Nil },;	//"Alterar"
							{ STR0006 ,"TMSA010Mnt", 0, 5,0,Nil },;	//"Excluir"
							{ STR0008 ,"TMSA010Cop", 0, 7,0,Nil },;	//"Copiar"
							{ STR0012 ,"TMSA010Est", 0, 8,0,Nil } }	//"Estrutura"
	
	
	If ExistBlock("TMA010MNU")
		ExecBlock("TMA010MNU",.F.,.F.)
	EndIf
	aRotAux := aClone(aRotina)
EndIf

Return( aRotAux )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaAcols  ³ Autor ³ Rodolfo K. Rosseto   ³ Data ³ 30/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para montar o aCols                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MontaAcols(cAlias)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MontaAcols(cAlias,nOpcx)

Local nI         := 0
Local nCntFor    := 0
Local cSeekKey   := xFilial( "DTK" ) + M->DT0_TABFRE + M->DT0_TIPTAB +  M->DT0_CDRORI + M->DT0_CDRDES + M->DT0_CODPRO

DEFAULT nOpcx    := 0

(cAlias)->(DbSetOrder(1))
(cAlias)->(dbGotop())

If cAlias == "DTK"
	cSeekKey := xFilial( "DTK" ) + M->DT0_TABFRE + M->DT0_TIPTAB +  M->DT0_CDRORI + M->DT0_CDRDES + M->DT0_CODPRO	

	If Len(aColsDTK) == 0
		aColsRecnoDTK := {}
		For nI := 1 To Len( aFolder )
			cFolder := aFolder[nI][1]
			AAdd( aColsRecnoDTK, cFolder)
			If (cAlias)->( MsSeek( cSeekKey + aFolder[nI][1] ) )
				AAdd(aCols,Array(Len(aHeader)+1))
				For nCntFor := 1 To Len(aHeader)
					If	aHeader[nCntFor,10] != "V"
						aCols[Len(aCols),nCntFor]:=(cAlias)->(FieldGet(FieldPos(aHeader[nCntFor,2])))
					Else
						If aHeader[nCntFor,2] == "DTK_ALI_WT" 
							aCols[Len(aCols),nCntFor]:= cAlias
						ElseIf aHeader[nCntFor,2] == "DTK_REC_WT"
							aCols[Len(aCols),nCntFor]:= (cAlias)->(Recno())
						Else
							aCols[Len(aCols),nCntFor]:=CriaVar(aHeader[nCntFor,2])
						EndIf
					EndIf
				Next nCntFor
				//-- Se nao encontrou item no DTK, traz na tela o item desmarcado
				aCols[Len(aCols),Len(aHeader)+1]   := .F.
			Else
				AAdd( aCols, Array( Len(aHeader) + 1 ) )
				For nCntFor := 1 To Len(aHeader)
					If	aHeader[nCntFor,10] != "V"
						aCols[Len(aCols),nCntFor]:= CriaVar(aHeader[nCntFor,2])
					Else
						If aHeader[nCntFor,2] == "DTK_ALI_WT" 
							aCols[Len(aCols),nCntFor]:= cAlias
						ElseIf aHeader[nCntFor,2] == "DTK_REC_WT"
							aCols[Len(aCols),nCntFor]:= 0
						Else
							aCols[Len(aCols),nCntFor]:= CriaVar(aHeader[nCntFor,2])
						EndIf
					EndIf
				Next nCntFor
				aCols[Len(aCols),Len(aHeader)+1] := .T.
			EndIf
		Next nI
		aColsDTK := AClone(aCols)
	Else
		aCols := AClone(aColsDTK)
		Aeval( aCols, {|x| x[Len(x)] := .F. }) // Os Itens do aCols nao poderao estar deletados
	EndIf
ElseIF cAlias== "DVY"
	cSeekKey := xFilial( "DVY" ) + M->DT0_TABFRE + M->DT0_TIPTAB +  M->DT0_CDRORI + M->DT0_CDRDES + M->DT0_CODPRO	

	If Len(aColsDVY) == 0
		aColsRecnoDVY := {}
		For nI := 1 To Len( aFolder )
			cFolder := aFolder[nI][1]  
			DT3->(DbSetOrder(1)) //-- DT3_FILAL+DT3_CODPAS
			DT3->(DbSeek(xFilial('DT3')+cFolder))
			If !(DT3->DT3_TIPFAI $ '13/14' )
				AAdd( aColsRecnoDVY, cFolder)
				If (cAlias)->( MsSeek( cSeekKey + aFolder[nI][1] ) )
					AAdd(aCols,Array(Len(aHeader)+1))
					For nCntFor := 1 To Len(aHeader)
						If	aHeader[nCntFor,10] != "V"
							aCols[Len(aCols),nCntFor]:=(cAlias)->(FieldGet(FieldPos(aHeader[nCntFor,2])))
						Else
							If aHeader[nCntFor,2] == "DVY_ALI_WT" 
								aCols[Len(aCols),nCntFor]:= cAlias
							ElseIf aHeader[nCntFor,2] == "DVY_REC_WT"
								aCols[Len(aCols),nCntFor]:= (cAlias)->(Recno())
							Else
								aCols[Len(aCols),nCntFor]:=CriaVar(aHeader[nCntFor,2])
							EndIf
						EndIf
					Next nCntFor
					//-- Se nao encontrou item no DVY, traz na tela o item desmarcado
					aCols[Len(aCols),Len(aHeader)+1] := .F.
				ElseIF nOpcx <> 2
					AAdd( aCols, Array( Len(aHeader) + 1 ) )
					For nCntFor := 1 To Len(aHeader)
						If	aHeader[nCntFor,10] != "V"
							aCols[Len(aCols),nCntFor]:= CriaVar(aHeader[nCntFor,2])
						Else
							If aHeader[nCntFor,2] == "DVY_ALI_WT" 
								aCols[Len(aCols),nCntFor]:= cAlias
							ElseIf aHeader[nCntFor,2] == "DVY_REC_WT"
								aCols[Len(aCols),nCntFor]:= 0
							Else
								aCols[Len(aCols),nCntFor]:= CriaVar(aHeader[nCntFor,2])
							EndIf
						EndIf
					Next nCntFor
					aCols[Len(aCols),Len(aHeader)+1] := .T.
				EndIf
			EndIf
		Next nI
		aColsDVY := AClone(aCols)
	Else
		aCols := AClone(aColsDVY)
		Aeval( aCols, {|x| x[Len(x)] := .F. }) // Os Itens do aCols nao poderao estar deletados
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA010TDA ³ Autor ³ Andre Sperandio    ³ Data ³ 09.Abr.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Base Componente Taxa Dificil Acesso                         ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA010TDA(ExpN1, ExpL1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±³          ³ExpL1 - Verifica se Mostra ou Nao a GetDados                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA010TDA( nOpcx, lMostraGetD )

Local ni
Local aArea       := GetArea()
Local aAreaDT0    := DT0->(GetArea())
Local aOldaHeader := Aclone( aHeader )
Local aOldaCols   := Aclone( aCols )
Local cCodPas     := aFolder[nFolder,1]
Local lRet        := .T.
Local nSeek       := 0
Local cSeekKey    := xFilial( "DVY" ) + M->DT0_TABFRE + M->DT0_TIPTAB +  M->DT0_CDRORI + M->DT0_CDRDES + M->DT0_CODPRO
Local cWhile      := "DVY->DVY_FILIAL + DVY->DVY_TABFRE + DVY->DVY_TIPTAB +  DVY->DVY_CDRORI + DVY->DVY_CDRDES + DVY->DVY_CODPRO"
Local aNoFields   := {"DVY_FILIAL","DVY_TABFRE","DVY_CDRORI","DVY_CDRDES","DVY_TIPTAB","DVY_CALPAS","DVY_APLAJU","DVY_CODPRO"}
Local nOpc        := 0
Local oDlg
Local oGetD
Local nSavN       := IIf(Type('n')=="U",1, n)
Local nCntFor     := 0

Private cFolder

Default lMostraGetD := .T.

//-- Verifica se o componente utiliza TDA.
DT3->(DbSetOrder(1)) //-- DT3_FILAL+DT3_CODPAS
If DT3->(MsSeek(xFilial("DT3")+cCodPas))
	If DT3->DT3_TIPFAI <> '13'
		Help("",1,"TMSA01024") //-- Componente de frete nao configurado para utilizar TDA.
		Return( .F. )
	EndIf
EndIf

//-- Finaliza as Teclas de Atalhos
TmsKeyOff(aSetKey)
aHeader	:= {}
aCols	:= {}

//-- Se for Visualizacao ou Estorno da Tabela de Frete, os arrays auxiliares aHeaderDVY e aColsDVY
//-- ja foram preenchidos pela funcao TMSA010Fol().
If Len(aHeaderDVY) == 0
	FillGetDados( nOpcx, "DVY",1, cSeekKey, {|| &cWhile }, {||.T.}, aNoFields, /*aYesFields*/, /*lOnlyYes*/, /*cQuery*/, {|| MontaAcols("DVY",nOpcx) }/*bMontCols*/)
	aHeaderDVY := AClone(aHeader)	
Else
	aHeader := Aclone(aHeaderDVY)
	MontaAcols("DVY",nOpcx)
EndIf

If lMostraGetD

	DEFINE MSDIALOG oDlg TITLE STR0050 From 9,0 To 27.5,80 OF oMainWnd //"Base Componente Taxa de Dificil Acesso"

		oGetD := MSGetDados():New(15,3,138,314,nOpcx,'AllwaysTrue()','AllwaysTrue()',,IIf(nOpcx<>2,.T.,Nil),,,,Len(aColsDVY) ) 

		TM010AjTDA(aColsDVY, aCols)

		oGetD:Refresh(.T.)

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpc :=1, oDlg:End()},{||oDlg:End()}),oGetD:Refresh()) CENTERED

Else
	nOpc := 1
EndIf

If nOpc == 1
	aColsDVY   := AClone(aCols)
EndIf
aHeader := aClone( aOldaHeader )
aCols   := aClone( aOldaCols )
n       := nSavN

RestArea( aArea )
RestArea( aAreaDT0 )

//-- Inicializa as Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TM010AjTDA ³ Autor ³ Andre Sperandio    ³ Data ³ 09.Abr.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Os Itens do aCols do DVY aparecerao deletados na 1a. chamada³±±
±±³          ³do 'Botao Base Componente TDA'.Nas outras chamadas,         ³±±
±±³          ³estes itens poderao estar deletados ou nao.Esta funcao serve³±±
±±³          ³para auxiliar a GetDados a mostrar os itens deletados.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TM010AjTDA(ExpA1,ExpA2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - aCols Auxiliar do DVY                               ³±±
±±³          ³ExpA2 - aCols                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Funcao TMSA010TDA()                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function  TM010AjTDA(aColsDVY, aCols)

Local nX

// Se o Item do aCols Auxiliar estiver deletado, deleta este item tambem no aCols 
// Isto tem que ser feito, para que a GetDados mostre os itens deletados na Tela
For nX := 1 To Len(aColsDVY)
	If aColsDVY[nX][Len(aColsDVY[nX])]
		aCols[nX][Len(aCols[nX])] := .T.
	EndIf
Next

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMSA010Comp ³ Autor ³Aldo Barbosa dos Santos³ Data ³ 12/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apresenta Sub-Faixa                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA010Comp()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA010                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA010Comp(nOpcx,cItemDT1,lTarifa)

Local cTitTabFre := AllTrim(RetTitle("DW1_TABFRE"))
Local cTitTipTab := AllTrim(RetTitle("DW1_TIPTAB"))
Local cTitCodPas := AllTrim(RetTitle("DW1_CODPAS"))
Local cTitItem   := AllTrim(RetTitle("DW1_ITEM"  ))
Local oDlgEsp
Local oGetSub
Local aSize      := {}
Local aInfo      := {}
Local aObjects   := {}
Local aPosObj    := {}
Local nPos       := 0
Local nOpcao     := 0
Local lAchou     := .F.
Local nCnt       := 0
Local cCodPas    := aFolder[nFolder,1]
Local cItem      := GDFieldGet("DW1_ITEM",n)
Local aNoFields  := {"DY1_CODPAS","DY1_ITEDT1" }
Local aArea      := {DY1->(GetArea()), GetArea()}
Local aButtons   := {}

Local nA

SaveInter() //-- Salva Area

aCols   := {}
aHeader := {}

DbSelectArea("DY1")

//-- Verifica se existe o componente de frete.
DT3->(DbSetOrder(1)) //-- DT3_FILAL+DT3_CODPAS
If !DT3->(MsSeek(xFilial("DT3")+cCodPas))
	Help("",1,"TMSA01018") //-- Componente de frete nao encontrado.
	RestInter() //-- Restaura Area
	Return( .F. )
EndIf

//-- Verifica se o componente utiliza sub-faixa.
If Empty(DT3->DT3_FAIXA2)
	Help("",1,"TMSA01019") //-- Componente de frete nao configurado para utilizar sub-faixa.
	RestInter() //-- Restaura Area
	Return( .F. )
EndIf

//-- preenchimento automatico pela tarifa.
If lTarifa
	nOpcx := 2
EndIf

If (nPos:= Ascan( aColsDY1, { |x| x[1]+x[2] == cCodPas + cItemDT1 } ) ) == 0 
		FillGetDados(	nOpcx, ;
							"DY1", ;
							1, 	 ;
							xFilial("DY1")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+cCodPas+cItemDt1 , ;
							Iif(nOpcx <> 3,{ || DY1->DY1_FILIAL+DY1->DY1_TABFRE+DY1->DY1_TIPTAB+DY1->DY1_CDRORI+DY1->DY1_CDRDES+DY1->DY1_CODPRO+DY1->DY1_CODPAS+DY1->DY1_ITEDT1 },{|| ''   }), ;
							{|| .T.  },;
							aNoFields,;
							/*aYesFields*/,;
							/*lOnlyYes*/,;
							/*cQuery*/,;
							/*bMontCols*/)
	//-- Inicializa o primeiro item da sub-faixa.
	aEval(aCols, {|x| Iif( Empty(x[GdFieldPos('DY1_ITEM')]), x[GdFieldPos('DY1_ITEM')]:= StrZero(1, Len(DY1->DY1_ITEM)), .T.) })
Else
	lAchou   := .T.
	aCols    := AClone(aColsDY1[nPos,3])
	aHeader  := AClone(aColsDY1[nPos,4])
	//-- Inicializa todas as linhas do aCols como nao deletado, devido a falha na GetDados
	For nCnt := 1 To Len(aCols)
		aCols[nCnt,Len(aHeader)+1] := .F.
	Next nCnt
EndIf

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 015, .T., .T. } )
AAdd( aObjects, { 100, 085, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE STR0051 FROM aSize[7]/2,00 TO aSize[6]/2,aSize[5]/2+100 PIXEL

@ aPosObj[1,1],010 SAY cTitTabFre + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],038 SAY M->DT0_TABFRE Of oDlgEsp PIXEL SIZE 29 ,9

@ aPosObj[1,1],055 SAY cTitTipTab + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],070 SAY M->DT0_TIPTAB Of oDlgEsp PIXEL SIZE 10 ,9

@ aPosObj[1,1],080 SAY cTitCodPas + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 35 ,9
@ aPosObj[1,1],115 SAY Posicione("DT3",1,xFilial("DT3")+cCodPas,"DT3_DESCRI") Of oDlgEsp PIXEL SIZE 40 ,9

@ aPosObj[1,1],180 SAY STR0052 COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],200 SAY cItemDT1 Of oDlgEsp PIXEL SIZE 10 ,9

aAltera := {"DY1_EXCMIN", "DY1_VALMIN", "DY1_VALMAX", "DY1_VALOR", "DY1_INTERV"}
//          MsGetDados(                nT ,            nL,             nB,               nR,     nOpc,    cLinhaOk,       cTudoOk,    cIniCpos,  lDeleta,    aAlter ,nFreeze,lEmpty, nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
oGetSub:=MSGetDados():New(aPosObj[2,1]/2, aPosObj[2,2]/2, aPosObj[2,3]/2, aPosObj[2,4]/2+50, nOpcx, 'TMSA010CLOk()','AllWaysTrue',"+DY1_ITEM",nOpcx<>2, aAltera, 3     ,      ,1  )

//-- Atualiza aCols corrigindo a falha na GetDados
If(lAchou,aCols := AClone(aColsDY1[nPos,3]),.T.)
oGetSub:Refresh(.T.)

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| If(oGetSub:TudoOk(),(nOpcao:= 1,oDlgEsp:End()),.F.) }, {|| oDlgEsp:End() },, ) CENTERED

//-- Atualiza array de aCols da sub-faixa
If nOpcao == 1
	If (nPos:= Ascan( aColsDY1, { |x| x[1]+x[2] == cCodPas+cItemDT1 } ) ) == 0
		AAdd(aColsDY1,{ cCodPas, cItemDT1, AClone(aCols), AClone(aHeader) } )
	Else
		aColsDY1[nPos,3] := AClone(aCols)
	EndIf
EndIf

RestInter() //-- Restaura Area

For nA := 1 to Len(aArea)
	RestArea(aArea[nA])
Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMSA010CLOk ³ Autor ³Aldo Barbosa dos Santos³ Data ³12/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida linha do excedente da sub-faixa                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA010CLOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA010CLOk()

Local lRet       := .F.
Local nPosExcMin := GDFieldPos("DY1_EXCMIN")
Local nPosValMin := GDFieldPos("DY1_VALMIN")
Local nPosValMax := GDFieldPos("DY1_VALMAX")
Local nPosValor  := GDFieldPos("DY1_VALOR")
Local nPosInterv := GDFieldPos("DY1_INTERV")

Local nExcMin
Local nValMin
Local nValMax
Local nValor 
Local nInterv

If Len(aCols) > 0
	nExcMin := aCols[n][nPosExcMin]
	nValMin := aCols[n][nPosValMin]
	nValMax	:= aCols[n][nPosValMax]
	nValor 	:= aCols[n][nPosValor]
	nInterv	:= aCols[n][nPosInterv]
Endif

lRet := MaCheckCols(aHeader,aCols,n)

//-- Valida se esta deletado
If lRet .and. Len(aCols) > 0
	If GDDeleted(n)
		lRet := .T.
	//-- Na primeira linha Valida p/ baixo
	ElseIf n == 1
		lRet := Ascan( aCols, {|aLine| ! aLine[Len(aLine)] .And. nExcMin >= aLine[nPosExcMin] }, 2 ) == 0
	//-- Na ultima linha Valida p/ cima
	ElseIf n == Len( aCols )
		lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. nExcMin <= aLine[nPosExcMin]}, 1, Len( Acols ) - 1 ) == 0
	//-- Valida Acima e Abaixo
	Else
		lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. nExcMin <= aLine[nPosExcMin]} , 1, n - 1 ) == 0
		
		lRet := lRet .And. ;
				   Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. nExcMin >= aLine[nPosExcMin] }, n + 1 ) == 0
	EndIf

	If !lRet
		//Help("",1,"",, "Campo Excesso Minimo Invalido ou ja existente", 4, 1)
		Alert(STR0055)
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMA010HdDY1 ³ Autor ³Aldo Barbosa dos Santos³ Data³ 12/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ aHeader da sub-faixa da tabela de tarifa                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA010CTar()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA010HdDY1(aNoFieldsDY1)

//--Armazena aCols e aHeader
SaveInter()

aCols   := {}
aHeader := {}
//-- Monta o array aHeader para a GetDados()
If Len(aHeadDY1) == 0
	FillGetDados(nOpcao,"DY1",1,/*xFilial("DW1")*/,{|| },{||.T.},aNoFieldsDY1,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/)
	aHeadDY1 := aClone(aHeader)
EndIf

//--Restaura aCols e aHeader
RestInter()

Return( aHeadDY1 )

/*/{Protheus.doc} Menudef
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param $Nenhum, $Nil

@return $aRotina, $Array com os dados de menu da rotina

@description

Menu Funcional

/*/
Static Function ModelDef()
Return FwLoadModel("TMSA010A")

/*/{Protheus.doc} ViewDef
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param ${nenhum}, ${Nil}

@return ${oView}, ${Visão MVC}

@description

Visão dos dados MVC

/*/
Static Function ViewDef()
Return FwLoadView("TMSA010A")
