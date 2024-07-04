// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 10      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "PROTHEUS.CH"
#include "OFIOM200.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOM200 ³ Autor ³ Andr‚                 ³ Data ³ 12/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Formas de Pagamentos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM200()

PRIVATE aRotina := MenuDef()
Private nUsado := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0007 // Formas de Pagamentos para Entrada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VSA")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OM200TP_? ³ Autor ³ Andr‚                 ³ Data ³ 14/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 2 = Visualizar / 3 = Incluir / 4 = Alterar / 5 = Excluir   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM200TP_2(cAlias, nReg, nOpc)
	nOpc := 2
	OM200TPPG(cAlias, nReg, nOpc)
Return()

Function OM200TP_3(cAlias, nReg, nOpc)
	nOpc := 3
	OM200TPPG(cAlias, nReg, nOpc)
Return()

Function OM200TP_4(cAlias, nReg, nOpc)
	nOpc := 4
	OM200TPPG(cAlias, nReg, nOpc)
Return()

Function OM200TP_5(cAlias, nReg, nOpc)
	nOpc := 5
	OM200TPPG(cAlias, nReg, nOpc)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OM200TP_? ³ Autor ³ Andr‚                 ³ Data ³ 14/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Formas de Pagamentos                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM200TPPG(cAlias, nReg, nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
////////////////////////////////////////////////////////////////////////////////////////////

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor := 0 , _ni := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cFieldOk , cLinOk , cTudOk
Local nPosRec  :=0  // Posicao do registro dentro do aCols

Private aTELA[0][0],aGETS[0]
Private aCpoEnchoice := {} , aCols := {} , aHeader := {}
Private nOpcX := nOpc
Private nLenAcols := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if nOpc == 2
	nOpcE := 2
	nOpcG := 2
Elseif nOpc == 3
	nOpcE := 3
	nOpcG := 3
Elseif nOpc == 4
	nOpcE := 4
	nOpcG := 4
Elseif nOpc == 5
	nOpcE := 5
	nOpcG := 5
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VSA",.T.)

aCpoEnchoice := {}

DbSelectArea("SX3")
DbGotop()
DbSeek("VSA")

While x3_arquivo == "VSA" .and. !eof()
	
	if X3USO(x3_usado).and.cNivel>=x3_nivel
		
		AADD(aCpoEnchoice,x3_campo)
		
		&( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
		
	Endif
	
	dbSkip()
	
EndDo

If nOpc # 3
	DbSelectArea("VSA")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VSB")
aHeader:={}

While !Eof().And.(x3_arquivo=="VSB")
	
	If X3USO(x3_usado).And.cNivel>=x3_nivel .and. !Alltrim(x3_campo) $ [VSB_TIPPAG]
		
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		
		&( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
		
	Endif
	
	dbSkip()
	
End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VSB")
ADHeadRec("VSB",aHeader)
// Posicao do registro
nPosRec:=Len(aHeader)
nUsado :=Len(aHeader)

aCols:={}

dbSelectArea("VSB")
dbSetOrder(1)
DbSeek(xFilial("VSB")+M->VSA_TIPPAG)

If nOpc == 3 .Or. !Found()
	
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	
	For _ni:=1 to nUsado
		
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VSB"
		Else
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf
		
	Next
	
Else
	
	While !eof() .And. VSB->VSB_FILIAL == xFilial("VSB") .And. VSB->VSB_TIPPAG == M->VSA_TIPPAG
		
		AADD(aCols,Array(nUsado+1))
		
		For _ni:=1 to nUsado
			
			&& verifica se e a coluna de controle do walk-thru
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VSB->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VSB"
			Else
				aCols[Len(aCols),_ni] := IIf(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			EndIf
			
		Next
		
		aCols[Len(aCols),nUsado+1]:=.F.
		
		dbSkip()
		
	End
	nLenaCols     := Len(aCols)
Endif

If Len(aCols)>0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo       := STR0007 //"Formas de Pagamentos para Entrada"
	cAliasEnchoice:= "VSA"
	cAliasGetD    := "VSB"
	cFieldOk      := "FG_MEMVAR() .and. OM200FILOK()"
	cLinOk        := "FG_OBRIGAT() .and. OM200LINOK()"
	cTudOk        := "OM200TUDOK()"
	aCpoEnchoice  := {}
	
	dbSelectArea("SX3")
	dbSeek("VSA")
	
	While !Eof().and.(x3_arquivo=="VSA")
		
		if X3USO(x3_usado).and.cNivel>=x3_nivel
			
			AADD(aCpoEnchoice,x3_campo)
			
		Endif
		
		dbSkip()
		
	End
	
	DbSelectArea("VSA")
	
	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 05, 50 , .T. , .F. } )  //Cabecalho
	AAdd( aObjects, { 01, 10 , .T. , .T. } )  //list box superior
	//AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
	//AAdd( aObjects, { 10, 10, .T. , .F. } )  //list box inferior
	//tamanho para resolucao 1024*768
	//aSizeAut[3]:= 508
	//aSizeAut[5]:= 1016
	// Fator de reducao de 0.8
	for nCntFor := 1 to Len(aSizeAut)
		aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
	next
	
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)
	
	DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL
	
	EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)
	
	oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudOk,"",IIf(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
	oGetDados:oBrowse:bChange    := {|| FG_AALTER("VSB",nLenaCols,oGetDados) }
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(FS_DELBRANCO().and.oGetDados:TudoOk().and.obrigatorio(aGets,aTela).and.FS_OM200GAR(nOpc),oDlg:End(),.f.) },{|| oDlg:End() }) CENTER
	
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_DELBRANCOºAutor³ Andre Luis Almeida º Data ³  08/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Deletar Linha do filho(VSB) qdo nada estiver informado     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DELBRANCO()
If Len(aCols) == 1 .and. !aCols[1,Len(aCols[1])]
	If Empty(M->VSB_SEQUCP+M->VSB_NOMECP+M->VSB_TIPOCP)
		aCols[1,Len(aCols[1])] := .t.
	EndIf
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_OM200GAºAutor  ³Fabio / Andre       º Data ³  09/21/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OM200GAR(nOpc)

Local i := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # 2
	
	If nOpc == 5
		aVetValid := {}
		Aadd(aVetValid, {"SE1", "E1_TIPO" , VSA->VSA_TIPPAG  , NIL } )
		Aadd(aVetValid, {"SE2", "E2_TIPO" , VSA->VSA_TIPPAG  , NIL } )
		Aadd(aVetValid, {"SE5", "E5_TIPO" , VSA->VSA_TIPPAG  , NIL } )
		Aadd(aVetValid, {"SL4", "L4_FORMA" , PadR(VSA->VSA_TIPPAG,TamSX3("L4_FORMA")[1])  , NIL } )
		If !FG_DELETA( aVetValid )
			Return .f.
		Endif
	Endif
	
	Begin Transaction
	
	DbSelectArea("VSA")
	
	If (nOpc == 3 .Or. nOpc == 4) // Incluir ou Alterar
		
		RecLock("VSA", IIf(nOpc == 3,.T.,.F.) )
		FG_GRAVAR("VSA")
		MsUnlock()
		
		dbSelectArea("SX5")
		dbSetOrder(1)
		If dbSeek(xFilial("SX5")+"05"+M->VSA_TIPPAG) .and. Alltrim(M->VSA_TIPPAG) == Alltrim(SX5->X5_CHAVE)
			RecLock("SX5",.f.)
		Else
			RecLock("SX5",.t.)
		Endif
		X5_TABELA := "05"
		X5_CHAVE  := M->VSA_TIPPAG
		X5_DESCRI := M->VSA_DESPAG
		MsUnlock()
		
		dbSelectArea("SX5")
		dbSetOrder(1)
		If dbSeek(xFilial("SX5")+"24"+M->VSA_TIPPAG) .and. Alltrim(M->VSA_TIPPAG) == Alltrim(SX5->X5_CHAVE)
			RecLock("SX5",.f.)
		Else
			RecLock("SX5",.t.)
		Endif
		X5_TABELA := "24"
		X5_CHAVE  := M->VSA_TIPPAG
		X5_DESCRI := M->VSA_DESPAG
		MsUnlock()
		
	Else // Excluir
		
		RecLock("VSA",.F.,.T.)
		dbdelete()
		MsUnlock()
		WriteSx2("VSA")
		
		dbSelectArea("SX5")
		dbSetOrder(1)
		If dbSeek(xFilial("SX5")+"05"+M->VSA_TIPPAG) .and. Alltrim(M->VSA_TIPPAG) == Alltrim(SX5->X5_CHAVE)
			RecLock("SX5",.F.,.T.)
			dbdelete()
			MsUnlock()
		Endif
		
		dbSelectArea("SX5")
		dbSetOrder(1)
		If dbSeek(xFilial("SX5")+"24"+M->VSA_TIPPAG) .and. Alltrim(M->VSA_TIPPAG) == Alltrim(SX5->X5_CHAVE)
			RecLock("SX5",.F.,.T.)
			dbdelete()
			MsUnlock()
		Endif

		
	EndIf
	
	For i:=1 to Len(aCols)
		
		If i > nLenaCols .and. aCols[i,Len(aCols[i])]
			Loop
		EndIf
		
		DbSelectArea("VSB")
		DbSetOrder(1)
		DbSeek( xFilial("VSB") + M->VSA_TIPPAG + aCols[i,1] )
		
		If (nOpc == 3 .Or. nOpc == 4) .And. !aCols[i,len(aCols[i])]
			
			if !Empty(M->VSB_NOMECP)
				RecLock("VSB", !Found() )
				FG_GRAVAR("VSB",aCols,aHeader,i)
				VSB->VSB_FILIAL := xFilial("VSB")
				VSB->VSB_TIPPAG := M->VSA_TIPPAG
				VSB->VSB_NOMECP := aCols[i,FG_POSVAR("VSB_NOMECP")]
				MsUnlock()
			Endif
			
		ElseIf Found()
			
			RecLock("VSB",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VSB")
			
		EndIf
		
	Next
	
	End Transaction
	
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM200LINOKºAutor  ³Ricardo Farinelli   º Data ³  24/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a Linha digitada pelo usuario                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM200LINOK(nLinha)
Local lRet := .T.
Local nwnk := 0
Local nPosCpo := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VSB_NOMECP"})
Local nPosSeq := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VSB_SEQUCP"})
Local cString := ""
Local cString2:= ""

If nOpcX == 2 .or. nOpcX == 5
	Return .T.
Endif

If nLinha <> nil
	n := nLinha
Endif

If aCols[n,Len(aCols[n])]
	Return .T.
Endif
cstring := aCols[n,nPosCpo]
cstring2:= aCols[n,nPosSeq]
For nwnk := 1 To Len(aCols)
	If nwnk <> n .and. !aCols[nwnk,Len(aCols[nwnk])]
		If cString == aCols[nwnk,nPosCpo] .or. cString2==aCols[nwnk,nPosSeq]
			Help(" ",1,"EXISTCHAV")
			Return .F.
		Endif
	Endif
Next

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM200TUDOKºAutor  ³Ricarfo Farinelli   º Data ³  24/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a confirmacao da tela na getdados                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM200TUDOK()
Local lRet := .T.
Local nwnk := 0

For nwnk := 1 To Len(aCols)
	If !aCols[nwnk,Len(aCols[nwnk])]
		If !OM200LINOK(nwnk)
			Return .F.
		Endif
	Endif
Next

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM200FILOKºAutor  ³Ricardo Farinelli   º Data ³  24/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o campo digitado pelo usuario                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM200FILOK()
Local lRet := .T.
Local nwnk := 0
Local cString := ""
If nOpcX == 2 .or. nOpcX == 5
	Return .T.
Endif
If aCols[n,Len(aCols[n])]
	Return .T.
Endif
If !ReadVar()=="M->VSB_NOMECP"
	Return .T.
Endif
cString := "ABCDEFGHIJKLMNOPQRSTUVXYWZ_"
For nwnk := 1 To Len(Alltrim(M->VSB_NOMECP))
	If !Substr(M->VSB_NOMECP,nwnk,1)$cString
		Help(" ",1,"TEXTO")
		Return .F.
	Endif
Next
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Andr‚                 ³ Data ³ 14/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ MenuDef montagem do aRotina                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { { STR0001 ,"AxPesqui()" , 0 , 1},; 		//Pesquisar
					{ STR0002 ,"OM200TP_2", 0 , 2},; 	//Visualizar
					{ STR0004 ,"OM200TP_3", 0 , 3},; 		//Incluir
					{ STR0005 ,"OM200TP_4", 0 , 4},; 		//Alterar
					{ STR0006 ,"OM200TP_5", 0 , 5}} 		//Excluir
Return aRotina