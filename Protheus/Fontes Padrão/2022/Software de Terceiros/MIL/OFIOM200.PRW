// 浜様様様曜様様様様�
// � Versao � 10      �
// 藩様様様擁様様様様�
#include "PROTHEUS.CH"
#include "OFIOM200.CH"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OFIOM200 � Autor � Andr�                 � Data � 12/07/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri�ao � Formas de Pagamentos                                       咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Generico                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIOM200()

PRIVATE aRotina := MenuDef()
Private nUsado := 0

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Define o cabecalho da tela de atualizacoes                   �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
PRIVATE cCadastro := STR0007 // Formas de Pagamentos para Entrada

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Endereca a funcao de BROWSE                                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
mBrowse( 6, 1,22,75,"VSA")

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    �OM200TP_? � Autor � Andr�                 � Data � 14/03/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � 2 = Visualizar / 3 = Incluir / 4 = Alterar / 5 = Excluir   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
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
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    �OM200TP_? � Autor � Andr�                 � Data � 14/03/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao �Formas de Pagamentos                                        咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
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
//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Opcoes de acesso para a Modelo 3                             �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
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

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria variaveis M->????? da Enchoice                          �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
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

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria aHeader e aCols da GetDados                             �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
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
	//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
	//� Executa a Modelo 3                                           �
	//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
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
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様様僕様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FS_DELBRANCO�Autor� Andre Luis Almeida � Data �  08/09/10   艮�
臼麺様様様様謡様様様様様様瞥様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao � Deletar Linha do filho(VSB) qdo nada estiver informado     艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function FS_DELBRANCO()
If Len(aCols) == 1 .and. !aCols[1,Len(aCols[1])]
	If Empty(M->VSB_SEQUCP+M->VSB_NOMECP+M->VSB_TIPOCP)
		aCols[1,Len(aCols[1])] := .t.
	EndIf
EndIf
Return(.t.)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FS_OM200GA�Autor  �Fabio / Andre       � Data �  09/21/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Grava                                                       艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function FS_OM200GAR(nOpc)

Local i := 0

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Executar processamento                                       �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
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
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OM200LINOK�Autor  �Ricardo Farinelli   � Data �  24/08/01   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Valida a Linha digitada pelo usuario                        艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
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
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OM200TUDOK�Autor  �Ricarfo Farinelli   � Data �  24/08/01   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Valida a confirmacao da tela na getdados                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
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
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OM200FILOK�Autor  �Ricardo Farinelli   � Data �  24/08/01   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Valida o campo digitado pelo usuario                        艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
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
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � MenuDef  � Autor � Andr�                 � Data � 14/03/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � MenuDef montagem do aRotina                                咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef()
Local aRotina := { { STR0001 ,"AxPesqui()" , 0 , 1},; 		//Pesquisar
					{ STR0002 ,"OM200TP_2", 0 , 2},; 	//Visualizar
					{ STR0004 ,"OM200TP_3", 0 , 3},; 		//Incluir
					{ STR0005 ,"OM200TP_4", 0 , 4},; 		//Alterar
					{ STR0006 ,"OM200TP_5", 0 , 5}} 		//Excluir
Return aRotina