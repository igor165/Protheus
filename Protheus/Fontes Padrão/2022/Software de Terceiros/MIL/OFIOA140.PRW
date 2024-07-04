#INCLUDE "ofioa140.ch"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOA140 ³ Autor ³  Emilton              ³ Data ³ 06/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tabela de Revisoes                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Gestao de concessionarias (SIGAOFI)                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA140
Local aCores    := {{ 'VO6_AGRSER == "S"','BR_VERMELHO' },;  //Tabela de Revisoes
{'VO6_AGRSER # "S"','BR_VERDE'}} //Tabela de Servicos

Private cCadastro := OemToAnsi(STR0001)   //"Tabela de Revisoes"
Private aMemos := {{"VO6_DESMEM","VO6_DESDET"}}
Private oTemFab, oTemCon, nTemFab, nTemCon
Private nUsado := 0
Private aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("VO6")
dbSetOrder(1)

mBrowse( 6, 1,22,75,"VO6",,,,,,aCores)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AP140     ºAutor  ³Fabio               º Data ³  08/29/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta tela                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AP140(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {} 
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0
Local nTam := 0
////////////////////////////////////////////////////////////////////////////////////////////
Local bCampo   := { |nCPO| Field(nCPO) }
Local nPos := 0
Local lProcura := .t. , _ni := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk , nUsado := 0
Local nPosRecF := nPosRecS := nPosRecP := 0
Private oTemFab , oTemCon
Private aTELA[0][0],aGETS[0] , nTemFab := 0 , nTemCon := 0 , nOpca := nOpc
Private aCpoEnchoice := {}
Private aHeaderPec   :={}, aColsPec:={}, naColsPec := 0
Private aHeaderSrv   :={}, aColsSrv:={}, naColsSrv := 0
Private aHeaderFer   :={}, aColsFer:={}, naColsFer := 0
Private aHeader      :={}, aCols   :={}

If VO6->VO6_AGRSER == "N" .and. nOpc <> 3
	//Help("  ",1,"DOCINVALID")
	///////////////////////////////////////////////
	// ALTERACAO DA MENSAEGM | RAFAEL GONCALVES  //
	// F N C   -   16086/2009					 //
	///////////////////////////////////////////////

	If nOpc == 2    // VISUALIZAR        // antonio FNC 22291/2009
		MsgAlert(STR0033 +chr(13)+chr(10)+" "+ STR0032,STR0015)	//"A visualização do serviço deverá ser realizada pela rotina de -"  'Tabela de Serviços' ### ATENCAO
		//FIM DA VIZUALIZACAO	
	ElseIf nOpc == 4 // ALTERAR
		MsgAlert(STR0031 +chr(13)+chr(10)+" "+ STR0032,STR0015)	//"A alteração do serviço deverá ser realizada pela rotina de -  'Tabela de Serviços' ### ATENCAO
		//FIM DA VIZUALIZACAO	
	ElseIf nOpc == 5 // EXCLUIR          // antonio FNC 22291/2009
		MsgAlert(STR0034 +chr(13)+chr(10)+" "+ STR0032,STR0015)  	//"A Exclusão do serviço deverá ser realizada pela rotina de -  " 'Tabela de Serviços' ### ATENCAO
		//FIM DA EXCLUSAO	
    EndIf

	DbSelectArea("VO6")
	DbSetOrder(1)
	Return .t.

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VO6",.t.)         // .t. para carregar campos virtuais

If nOpc == 3
	nOpcE := 3
	nOpcG := 3
ElseIf nOpc == 4
	nOpcE := 4
	nOpcG := 4
ElseIf nOpc == 2
	nOpcE := 2
	nOpcG := 2
Else
	nOpcE := 5
	nOpcG := 5
EndIf

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VO6")
While !Eof().and.(x3_arquivo=="VO6")
	if X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(x3_campo $ [VO6_AGRSER/VO6_TEMFAB/VO6_TEMCON])
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&("M->"+x3_campo) := CriaVar(x3_campo)
	DbSkip()
End
If !(Inclui)
	DbSelectArea("VO6")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VO8")
aHeader:={}
While !Eof().And.(x3_arquivo=="VO8")
	
	If !(Alltrim(x3_campo) $ [VO8_CODMAR/VO8_DESMAR/VO8_MODVEI/VO8_SEGMOD/VO8_DESMOD/VO8_CODSER/VO8_DESSER/VO8_DESGRU/VO8_TIPAGR])
		
		// Ferramentas
		If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !( Alltrim(x3_campo) $ [VO8_SEQUEN/VO8_GRUITE/VO8_DESGRU/VO8_CODITE/VO8_DESITE/VO8_QTDITE/VO8_CODSRV/VO8_DESSRV/VO8_TEMFAB/VO8_TEMCON])
			Aadd(aHeaderFer,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		Endif
		
		// Servicos
		If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !( Alltrim(x3_campo) $ [VO8_GRUITE/VO8_DESGRU/VO8_CODITE/VO8_DESITE/VO8_QTDITE/VO8_CODFER/VO8_DESFER])
			Aadd(aHeaderSrv,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		Endif
		
		// Pecas
		If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !( Alltrim(x3_campo) $ [VO8_SEQUEN/VO8_CODSRV/VO8_DESSRV/VO8_TEMFAB/VO8_TEMCON/VO8_CODFER/VO8_DESFER])
			Aadd(aHeaderPec,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		Endif
		
	EndIf
	
	&("M->"+x3_campo) := CriaVar(x3_campo)
	
	DbSkip()
End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VO8")
ADHeadRec("VO8",aHeaderFer)
nPosRecF:=Len(aHeaderFer)
// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VO8")
ADHeadRec("VO8",aHeaderSrv)
nPosRecS:=Len(aHeaderSrv)
// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VO8")
ADHeadRec("VO8",aHeaderPec)
nPosRecP:=Len(aHeaderPec)

aColsFer:={}
aColsSrv:={}
aColsPec:={}

dbSelectArea("VO8")
dbSetOrder(1)
dbSeek(xFilial("VO8")+ FG_MARSRV(M->VO6_CODMAR,M->VO6_CODSER) +M->VO6_MODVEI+M->VO6_SEGMOD+M->VO6_CODSER)

While !eof() .And. VO8->VO8_FILIAL == xFilial("VO8") .And. VO8->VO8_CODMAR+VO8->VO8_MODVEI+VO8->VO8_SEGMOD+VO8->VO8_CODSER == FG_MARSRV(M->VO6_CODMAR,M->VO6_CODSER) +M->VO6_MODVEI+M->VO6_SEGMOD+M->VO6_CODSER
	
	If VO8->VO8_TIPAGR == "0"        // Ferramenta
		
		AADD(aColsFer,Array(Len(aHeaderFer)+1))
		For _ni:=1 to Len(aHeaderFer)
			If IsHeadRec(aHeaderFer[_ni,2])
				aColsFer[Len(aColsFer),_ni] := VO8->(RecNo())
			ElseIf IsHeadAlias(aHeaderFer[_ni,2])
				aColsFer[Len(aColsFer),_ni] := "VO8"
			Else
				aColsFer[Len(aColsFer),_ni]:=If(aHeaderFer[_ni,10] # "V",FieldGet(FieldPos(aHeaderFer[_ni,2])),CriaVar(aHeaderFer[_ni,2]))
			EndIf
		Next
		aColsFer[Len(aColsFer),Len(aHeaderFer)+1]:=.F.
		
	ElseIf VO8->VO8_TIPAGR == "1"    // Servicos
		
		AADD(aColsSrv,Array(Len(aHeaderSrv)+1))
		For _ni:=1 to Len(aHeaderSrv)
			If IsHeadRec(aHeaderSrv[_ni,2])
				aColsSrv[Len(aColsSrv),_ni] := VO8->(RecNo())
			ElseIf IsHeadAlias(aHeaderSrv[_ni,2])
				aColsSrv[Len(aColsSrv),_ni] := "VO8"
			Else
				aColsSrv[Len(aColsSrv),_ni]:=If(aHeaderSrv[_ni,10] # "V",FieldGet(FieldPos(aHeaderSrv[_ni,2])),CriaVar(aHeaderSrv[_ni,2]))
			EndIf
		Next
		aColsSrv[Len(aColsSrv),Len(aHeaderSrv)+1]:=.F.
		
	Else                              // Pecas
		
		AADD(aColsPec,Array(Len(aHeaderPec)+1))
		For _ni:=1 to Len(aHeaderPec)
			If IsHeadRec(aHeaderPec[_ni,2])
				aColsPec[Len(aColsPec),_ni] := VO8->(RecNo())
			ElseIf IsHeadAlias(aHeaderPec[_ni,2])
				aColsPec[Len(aColsPec),_ni] := "VO8"
			Else
				aColsPec[Len(aColsPec),_ni]:=If(aHeaderPec[_ni,10] # "V",FieldGet(FieldPos(aHeaderPec[_ni,2])),CriaVar(aHeaderPec[_ni,2]))
			EndIf
		Next
		aColsPec[Len(aColsPec),Len(aHeaderPec)+1]:=.F.
		
	EndIf
	
	DbSelectArea("VO8")
	DbSkip()
	
End

naColsFer := Len(aColsFer)
naColsSrv := Len(aColsSrv)
naColsPec := Len(aColsPec)

// Ferramenta
If Len( aColsFer ) == 0
	aColsFer:={Array(Len(aHeaderFer)+1)}
	aColsFer[1,Len(aHeaderFer)+1]:=.F.
	For _ni:=1 to Len(aHeaderFer)
		If IsHeadRec(aHeaderFer[_ni,2])
			aColsFer[Len(aColsFer),_ni] := 0
		ElseIf IsHeadAlias(aHeaderFer[_ni,2])
			aColsFer[Len(aColsFer),_ni] := "VO8"
		Else
			aColsFer[1,_ni]:=CriaVar(aHeaderFer[_ni,2])
		EndIf
	Next
EndIf

// Servico
If Len( aColsSrv ) == 0
	nPos := FG_POSVAR("VO8_SEQUEN","aHeaderSrv")
	aColsSrv:={Array(Len(aHeaderSrv)+1)}
	aColsSrv[1,Len(aHeaderSrv)+1]:=.F.
	For _ni:=1 to Len(aHeaderSrv)
		If IsHeadRec(aHeaderSrv[_ni,2])
			aColsSrv[Len(aColsSrv),_ni] := 0
		ElseIf IsHeadAlias(aHeaderSrv[_ni,2])
			aColsSrv[Len(aColsSrv),_ni] := "VO8"
		Else
			aColsSrv[1,_ni]:=CriaVar(aHeaderSrv[_ni,2])
		EndIf
	Next
EndIf

// Pecas
If Len( aColsPec ) == 0
	aColsPec:={Array(Len(aHeaderPec)+1)}
	aColsPec[1,Len(aHeaderPec)+1]:=.F.
	For _ni:=1 to Len(aHeaderPec)
		If IsHeadRec(aHeaderPec[_ni,2])
			aColsPec[Len(aColsPec),_ni] := 0
		ElseIf IsHeadAlias(aHeaderPec[_ni,2])
			aColsPec[Len(aColsPec),_ni] := "VO8"
		Else
			aColsPec[1,_ni]:=CriaVar(aHeaderPec[_ni,2])
		EndIf
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a Modelo 3                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo       :=STR0001    //"Tabela de Revisoes"
cAliasEnchoice:="VO6"
cAliasGetD    :="VO8"
//cLinOk        :="FG_OBRIGAT()"
cLinOk        :="If(FS_VP140(),FG_OBRIGAT(),.F.)"
cTudOk        :="FS_CALTEM().and.FS_VP140G(nOpca)"
cFieldOk      :="FG_MEMVAR() .AND. FS_SEQ140('F') .AND. FS_POETMP()"

If !(Inclui)
	DbSelectArea("VO6")
	DbSetOrder(1)
	dbSeek(xFilial("VO6")+M->VO6_SERINT)
Endif 

   // Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 120 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
//AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
//AAdd( aObjects, { 10, 10, .T. , .F. } )  //list box inferior
//tamanho para resolucao 1024*768
//aSizeAut[3]:= 508 
//aSizeAut[5]:= 1016  
// Fator de reducao de 0.8
//for nCntFor := 1 to Len(aSizeAut)
//	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
//next   

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)    

DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

	EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)
	
	SetEnch("")
//	@ 131,001 FOLDER oFolder SIZE 316,260 OF oDlg PROMPTS STR0008,STR0009,STR0010 PIXEL //"&Ferramentas"###"&Servicos"###"&Pecas" 
	@ aPosObj[2,1],aPosObj[2,2] FOLDER oFolder SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] OF oDlg PROMPTS STR0008,STR0009,STR0010 PIXEL //"&Ferramentas"###"&Servicos"###"&Pecas"
	// Abas do Folder
	FG_INIFOLDER("oFolder")
	
	FS_ABA(1)
	oGetFer := MsGetDados():New(01,1,aPosObj[2,3]-aPosObj[2,1]-14,aPosObj[2,4]-004,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk,,,,oFolder:aDialogs[1])
	oGetFer:oBrowse:bChange := { || FG_AALTER("VO8",naColsFer,oGetFer,aHeaderFer) }
	
	FS_ABA(2)
	oGetSrv := MsGetDados():New(01,1,aPosObj[2,3]-aPosObj[2,1]-23,aPosObj[2,4]-004,nOpcG,cLinOk,cTudOk,"+VO8_SEQUEN",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk,,,,oFolder:aDialogs[2])
	oGetSrv:oBrowse:bChange   := {|| FS_SEQ140("L"), FG_AALTER("VO8",naColsSrv,oGetSrv,aHeaderSrv) }
	oGetSrv:oBrowse:bEditCol  := {|| FS_ATUTEM() }
	
	
	nTam := ( aPosObj[2,4] / 2 ) //varaivel que armazena o resutlado da divisao da tela.                        
	@ aPosObj[2,3]-aPosObj[2,1]-22,aPosObj[2,2]+(nTam*0)+005 Say OemToAnsi(STR0011)        SIZE 110,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_HBLUE //"Tempo de Fabrica"
	@ aPosObj[2,3]-aPosObj[2,1]-22,aPosObj[2,2]+(nTam*0)+085 Say oTemFab VAR Transform(nTemFab, "@R 999:99") SIZE 110,08 OF oFolder:aDialogs[2] PIXEL
	@ aPosObj[2,3]-aPosObj[2,1]-22,aPosObj[2,2]+(nTam*1)+005 Say OemToAnsi(STR0012)        SIZE 110,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_HBLUE //"Tempo de Concessionaria"
	@ aPosObj[2,3]-aPosObj[2,1]-22,aPosObj[2,2]+(nTam*1)+085 Say oTemCon VAr Transform(nTemCon, "@R 999:99") SIZE 110,08 OF oFolder:aDialogs[2] PIXEL
	
	FS_ABA(3)
	oGetPec := MsGetDados():New(01,1,aPosObj[2,3]-aPosObj[2,1]-14,aPosObj[2,4]-004,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk,,,,oFolder:aDialogs[3])
	oGetPec:oBrowse:bChange    := {|| FG_AALTER("VO8",naColsPec,oGetPec,aHeaderPec)  }
	
	oFolder:bSetOption := {|| FS_SETOPTION(oFolder:nOption) }
	oFolder:bChange    := {|| FS_ABA(oFolder:nOption) }
	
	FS_ABA(2)
	
ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| If(obrigatorio(aGets,aTela) .And. FS_SETOPTION(oFolder:nOption) .and. &(cTudOk).And.FS_GRASRVAG(nOpc) , oDlg:End() , .f. ) },{|| oDlg:End() }) , FS_ABA(1) )

DbSelectArea("VO6")
DbSetOrder(1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ABA    ºAutor  ³Fabio               º Data ³  08/10/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla abas                                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ABA(nAba)

aCols   := {}
aHeader := {}

If nAba == 1
	
	aheader := Aclone( aHeaderFer )
	aCols   := Aclone( aColsFer )
	
	M->VO8_TIPAGR := "0"
	
	If Type("oGetFer") # "U" .And. Type("oGetSrv") # "U" .And. Type("oGetPec") # "U"
		oGetFer:oBrowse:Enable()
		oGetSrv:oBrowse:Disable()
		oGetPec:oBrowse:Disable()
		n := oGetFer:oBrowse:nAt
		oGetFer:oBrowse:Refresh()
	EndIf
	
ElseIf nAba == 2
	
	aheader := Aclone( aHeaderSrv )
	aCols   := Aclone( aColsSrv )
	
	M->VO8_TIPAGR := "1"
	
	If Type("oGetFer") # "U" .And. Type("oGetSrv") # "U" .And. Type("oGetPec") # "U"
		oGetFer:oBrowse:Disable()
		oGetSrv:oBrowse:Enable()
		oGetPec:oBrowse:Disable()
		n := oGetSrv:oBrowse:nAt
		oGetSrv:oBrowse:Refresh()
	EndIf
	
	If Type("oTemFab") # "U" .And. Type("oTemCon") # "U"
		
		FS_CALTEM()
		FS_ATUTEM()
		
	EndIf
	
Else
	
	aheader := Aclone( aHeaderPec )
	aCols   := Aclone( aColsPec )
	
	M->VO8_TIPAGR := "2"
	
	If Type("oGetFer") # "U" .And. Type("oGetSrv") # "U" .And. Type("oGetPec") # "U"
		oGetFer:oBrowse:Disable()
		oGetSrv:oBrowse:Disable()
		oGetPec:oBrowse:Enable()
		n := oGetPec:oBrowse:nAt
		oGetPec:oBrowse:Refresh()
	EndIf
	
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_SETOPTIºAutor  ³Fabio               º Data ³  08/10/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida mudanca de aba                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SETOPTION(nAba)

Local nColuna := 0


If nAba == 1
	
	aHeaderFer := Aclone( aHeader )
	aColsFer   := Aclone( aCols )
	
ElseIf nAba == 2
	
	aheaderSrv := Aclone( aHeader )
	aColsSrv   := Aclone( aCols )
	
Else
	
	aheaderPec := Aclone( aHeader )
	aColsPec   := Aclone( aCols )
	
EndIf

// Verifica caso tenha sido digitado algum conteudo na linha se todo os campos obrigatorios foram informados
For nColuna := 1 to Len(aHeader)
	
	If !Empty(aCols[n,nColuna])
		
		If !Empty(aCols[n,1]) .or. !Empty(aCols[n,2])
			
			If !FG_OBRIGAT() .Or. !FS_VP140()
				Return(.f.)
			Else
				Exit
			EndIf
		EndIf
		
	EndIf
	
Next

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIOA140  ºAutor  ³Microsiga           º Data ³  08/09/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRASRVAG(nOpc)

Private lMsFinalAuto := .T., lMsHelpAuto := .f.
If !FS_VALGRASRVAG( nOpc , .t. )
	
	MostraErro()
	Return( .f. )
	
EndIf

Begin Transaction

FS_VALGRASRVAG( nOpc )

End Transaction
lMsHelpAuto := .f.


Return( .t. )

Static Function FS_VALGRASRVAG( nOpc , lValid )

Local   lRet := .t. , aVetValid := {} , i := 0
Private lMsHelpAuto , cVar

lValid := If( lValid == NIL , .f. , lValid )

If !FS_SETOPTION(oFolder:nOption)
	
	Return(.f.)
	
EndIf

If Posicione("VE4" , 1, xFilial("VE4") + M->VO6_CODMAR , "VE4_SEGMOD" ) == "1" ;
	.And. Empty( M->VO6_SEGMOD )
	
	Help("  " , 1 , "SEGMODNVAL" )
	Return( .f. )
	
EndIf

lMsHelpAuto := .t.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # 2
	
	DbSelectArea("VO6")
	DbSetOrder(1)
	DbSeek(xFilial("VO6")+M->VO6_SERINT)
	
	// grava arquivo pai
	
	If !lValid
		
		If nOpc == 3 .or. nOpc == 4
			
			If !RecLock("VO6", !Found() )
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			Endif
			
			FG_GRAVAR("VO6")
			VO6->VO6_AGRSER := [S]
			
			cVar := aMemos[1][2]
			MSMM(,TamSx3("VO6_DESDET")[1],,&cVar,1,,,"VO6","VO6_DESMEM")
			
			ConfirmSX8()
			MsUnlock()
			
		EndIf
		
		// grava arquivo filho Ferramentas
		For i:=1 to len(aColsFer)
			
			If (i > naColsFer .and. aColsFer[i,Len(aColsFer[i])]) .Or. Empty(aColsFer[I,FG_POSVAR("VO8_CODFER","aHeaderFer")])
				Loop
			EndIf
			DbSelectArea("VO8")
			DbSetOrder(1)
			DbSeek(xFilial()+M->VO6_CODMAR+M->VO6_MODVEI+M->VO6_SEGMOD+M->VO6_CODSER+"0"+aColsFer[I,FG_POSVAR("VO8_CODFER","aHeaderFer")])
			
			If (nOpc == 3 .Or. nOpc == 4) .And. !aColsFer[i,len(aColsFer[i])]
				
				If !RecLock("VO8", !Found() )
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				FG_GRAVAR("VO8",aColsFer,aHeaderFer,i)
				VO8->VO8_FILIAL := xFilial("VO8")
				VO8->VO8_CODMAR := M->VO6_CODMAR
				VO8->VO8_MODVEI := M->VO6_MODVEI
				VO8->VO8_SEGMOD := M->VO6_SEGMOD
				VO8->VO8_CODSER := M->VO6_CODSER
				VO8->VO8_TIPAGR := "0"
				MsUnlock()
				
			ElseIf Found()
				
				If !RecLock("VO8",.F.,.T.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				dbdelete()
				MsUnlock()
				WriteSx2("VO8")
				
			Endif
			
		Next
		
		// grava arquivo filho Servico
		For i:=1 to len(aColsSrv)
			
			If (i > naColsSrv .and. aColsSrv[i,Len(aColsSrv[i])]) .Or. Empty(aColsSrv[I,FG_POSVAR("VO8_SEQUEN","aHeaderSrv")])
				Loop
			EndIf
			DbSelectArea("VO8")
			DbSetOrder(2)
			DbSeek(xFilial()+M->VO6_CODMAR+M->VO6_MODVEI+M->VO6_SEGMOD+M->VO6_CODSER+"1"+aColsSrv[I,FG_POSVAR("VO8_SEQUEN","aHeaderSrv")])
			
			If (nOpc == 3 .Or. nOpc == 4) .And. !aColsSrv[i,len(aColsSrv[i])]
				
				If !RecLock("VO8", !Found() )
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				FG_GRAVAR("VO8",aColsSrv,aHeaderSrv,i)
				VO8->VO8_FILIAL := xFilial("VO8")
				VO8->VO8_CODMAR := M->VO6_CODMAR
				VO8->VO8_MODVEI := M->VO6_MODVEI
				VO8->VO8_SEGMOD := M->VO6_SEGMOD
				VO8->VO8_CODSER := M->VO6_CODSER
				VO8->VO8_TIPAGR := "1"
				MsUnlock()
				
			ElseIf Found()
				
				If !RecLock("VO8",.F.,.T.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				dbdelete()
				MsUnlock()
				WriteSx2("VO8")
				
			Endif
			
		Next
		
		// grava arquivo filho Pecas
		For i:=1 to len(aColsPec)
			
			If (i > naColsPec .and. aColsPec[i,Len(aColsPec[i])]) .Or. Empty(aColsPec[I,FG_POSVAR("VO8_GRUITE","aHeaderPec")]+aColsPec[I,FG_POSVAR("VO8_CODITE","aHeaderPec")])
				Loop
			EndIf
			
			DbSelectArea("VO8")
			DbSetOrder(3)
			DbSeek(xFilial()+M->VO6_CODMAR+M->VO6_MODVEI+M->VO6_SEGMOD+M->VO6_CODSER+"2"+aColsPec[I,FG_POSVAR("VO8_GRUITE","aHeaderPec")]+aColsPec[I,FG_POSVAR("VO8_CODITE","aHeaderPec")])
			
			If (nOpc == 3 .Or. nOpc == 4) .And. !aColsPec[i,len(aColsPec[i])]
				
				If !RecLock("VO8", !Found() )
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				FG_GRAVAR("VO8",aColsPec,aHeaderPec,i)
				VO8->VO8_FILIAL := xFilial("VO8")
				VO8->VO8_CODMAR := M->VO6_CODMAR
				VO8->VO8_MODVEI := M->VO6_MODVEI
				VO8->VO8_SEGMOD := M->VO6_SEGMOD
				VO8->VO8_CODSER := M->VO6_CODSER
				VO8->VO8_TIPAGR := "2"
				MsUnlock()
				
			ElseIf Found()
				
				If !RecLock("VO8",.F.,.T.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				dbdelete()
				MsUnlock()
				WriteSx2("VO8")
				
			Endif
			
		Next
		
	EndIf
	
	// Exclui arquivo pai
	DbSelectArea("VO6")
	
	If !(Inclui .or. Altera) .And. Found()
		
		If lValid
			
			aVetValid := {}
			Aadd(aVetValid,{"VE3" , "VE3_CODSER" , VO6->VO6_CODSER  , NIL })
			Aadd(aVetValid,{"VFA" , "VFA_CODMAR+VFA_CODSER" , VO6->VO6_CODMAR+VO6->VO6_CODSER  , NIL })
			Aadd(aVetValid,{"VFB" , "VFB_CODSER" , VO6->VO6_CODSER  , NIL })
			Aadd(aVetValid,{"VG5" , "VG5_CODMAR+VG5_CODSER" , VO6->VO6_CODMAR+VO6->VO6_CODSER  , NIL })
			Aadd(aVetValid,{"VG6" , "VG6_CODMAR+VG6_CODSER" , VO6->VO6_CODMAR+VO6->VO6_CODSER  , NIL })
			Aadd(aVetValid,{"VG8" , "VG8_CODMAR+VG8_CODSER" , VO6->VO6_CODMAR+VO6->VO6_CODSER  , NIL })
			Aadd(aVetValid,{"VO4" , 4 , VO6->VO6_CODSER  , NIL })
			Aadd(aVetValid,{"VOC" , "VOC_CODMAR+VOC_CODSER" , VO6->VO6_CODMAR+VO6->VO6_CODSER  , NIL })
			Aadd(aVetValid,{"VS4" , "VS4_CODSER" , VO6->VO6_CODSER  , NIL })
			Aadd(aVetValid,{"VSD" , "VSD_CODSER" , VO6->VO6_CODSER  , NIL })
			Aadd(aVetValid,{"VSC" , 2 , VO6->VO6_CODSER  , NIL })
			
			If !FG_DELETA(aVetValid)
				Return( .f. )
			EndIf
			
		Else
			
			If !RecLock("VO6",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf
			
			dbdelete()
			MsUnlock()
			WriteSx2("VO6")
			
		EndIf
		
	Endif
	
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ATUTEM ºAutor  ³Fabio               º Data ³  08/09/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza TOTAL tempo fabrica e concessionaria               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ATUTEM()

Local nxx := 0

nTemFab := 0
nTemCon := 0

For nxx:=1 to Len(aCols)
	
	If aCols[nxx,Len(aCols[n])]
		M->VO6_TEMFAB -= nTemFab -= aCols[nxx,FG_POSVAR("VO8_TEMFAB")]
		M->VO6_TEMCON -= nTemCon -= aCols[nxx,FG_POSVAR("VO8_TEMCON")]
		
		oTemFab:refresh()
		oTemCon:refresh()
	Else
		M->VO6_TEMFAB += nTemFab += aCols[nxx,FG_POSVAR("VO8_TEMFAB")]
		M->VO6_TEMCON += nTemCon += aCols[nxx,FG_POSVAR("VO8_TEMCON")]
		
		oTemFab:refresh()
		oTemCon:refresh()
	Endif
	
Next

return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_POETMP ºAutor  ³Fabio               º Data ³  08/09/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza tempo fabrica e concessionaria                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_POETMP()

If ReadVar() == "M->VO8_CODSRV"
	
	If FG_SEEK("VO7","FG_MARSRV(M->VO6_CODMAR,M->VO8_CODSRV)+M->VO8_CODSRV+M->VO6_MODVEI+M->VO6_SEGMOD",1,.f.)
		
		FG_SEEK("VO6","FG_MARSRV(M->VO6_CODMAR,M->VO8_CODSRV)+M->VO8_CODSRV",2,.f.,"VO8_DESSRV","VO6_DESSER")
		aCols[n,FG_POSVAR("VO8_DESSRV")] := VO6->VO6_DESSER
		aCols[n,FG_POSVAR("VO8_TEMFAB")] := VO7->VO7_TEMFAB
		aCols[n,FG_POSVAR("VO8_TEMCON")] := VO7->VO7_TEMCON
		M->VO8_TEMFAB := VO7->VO7_TEMFAB
		M->VO8_TEMCON := VO7->VO7_TEMCON
		
	Else
		
		If FG_SEEK("VO6","FG_MARSRV(M->VO6_CODMAR,M->VO8_CODSRV)+M->VO8_CODSRV",2,.f.,"VO8_DESSRV","VO6_DESSER")
			aCols[n,FG_POSVAR("VO8_DESSRV")] := VO6->VO6_DESSER
			aCols[n,FG_POSVAR("VO8_TEMFAB")] := VO6->VO6_TEMFAB
			aCols[n,FG_POSVAR("VO8_TEMCON")] := VO6->VO6_TEMCON
			M->VO8_TEMFAB := VO6->VO6_TEMFAB
			M->VO8_TEMCON := VO6->VO6_TEMCON
		Else
			Return .f.
		EndIf
		
	EndIf
	
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_CALTEM ºAutor  ³Fabio               º Data ³  08/29/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Soma tempos                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CALTEM()

Local i := 0

If nOpcG == 4 .or. nOpcG == 2
	
	M->VO6_TEMFAB := 0
	M->VO6_TEMCON := 0
	
	For i:=1 to len(aColsSrv)
		
		M->VO6_TEMFAB += aColsSrv[I,FG_POSVAR("VO8_TEMFAB","aHeaderSrv")]
		M->VO6_TEMCON += aColsSrv[I,FG_POSVAR("VO8_TEMCON","aHeaderSrv")]
		
	Next
	
	nTemFab := M->VO6_TEMFAB
	nTemCon := M->VO6_TEMCON
	oTemFab:refresh()
	oTemCon:refresh()
	
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_TEMPOS ºAutor  ³Fabio               º Data ³  08/29/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³atualiza tempo do acols                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TEMPOS()

M->VO8_TEMFAB := VO6->VO6_TEMFAB
M->VO8_TEMCON := VO6->VO6_TEMCON

aCols[n,FG_POSVAR("VO8_TEMFAB")] := VO6->VO6_TEMFAB
aCols[n,FG_POSVAR("VO8_TEMCON")] := VO6->VO6_TEMCON

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_SEQ140 ºAutor  ³Fabio               º Data ³  08/29/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³valida chave                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SEQ140( cOperacao )

Local nSeq := 0 , nxx := 0
Local nwnk := 0

// Aba de Servico
If oFolder:nOption == 1
	
	If ReadVar() == "M->VO8_CODFER"
		nxx := FG_POSVAR("VO8_CODFER")
		If nxx > 0
			For nwnk := 1 To Len(aCols)
				If !aCols[nwnk,Len(aCols[nwnk])] .and. nwnk <> n
					If aCols[nwnk,nxx]==M->VO8_CODFER
						Help("  ",1,"EXISTCHAV")
						Return( .f. )
					Endif
				Endif
			Next
		Endif
		
	EndIf
	
ElseIf oFolder:nOption == 2
	
	// L - Line
	If cOperacao == "L" .And. Empty( aCols[n,FG_POSVAR("VO8_SEQUEN")] )
		
		For nxx:=1 to Len(aCols)
			
			If nxx # n .And. Val(aCols[nxx,FG_POSVAR("VO8_SEQUEN")]) > nSeq
				nSeq := Val(aCols[nxx,FG_POSVAR("VO8_SEQUEN")])
			Endif
			
		Next
		
		aCols[n,FG_POSVAR("VO8_SEQUEN")] := StrZero((nSeq+1),2)
		
		oGetSrv:oBrowse:Refresh()
		
		// F - Field
	ElseIf cOperacao == "F" .And. ReadVar() == "M->VO8_CODSRV"
		
		nxx := FG_POSVAR("VO8_CODSRV")
		If nxx > 0
			For nwnk := 1 To Len(aCols)
				If !aCols[nwnk,Len(aCols[nwnk])] .and. nwnk <> n
					If aCols[nwnk,nxx]==M->VO8_CODSRV
						Help("  ",1,"EXISTCHAV")
						Return( .f. )
					Endif
				Endif
			Next
		Endif
	Endif
Else
	
	If ReadVar() == "M->VO8_GRUITE" .Or. ReadVar() == "M->VO8_CODITE"
		
		nxx := Ascan( aCols , {|x| x[FG_POSVAR("VO8_GRUITE")] + x[FG_POSVAR("VO8_CODITE")] == M->VO8_GRUITE+M->VO8_CODITE .and. !x[Len(x)]} )
		
		If nxx # 0 .And. nxx # n
			
			Help("  ",1,"EXISTCHAV")
			
			Return( .f. )
			
		EndIf
		
	EndIf
	
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VP140  ºAutor  ³Fabio               º Data ³  08/19/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla Pastas                                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VP140()

Local nReg    := 0
Local ix1     := 0

FG_MEMVAR()

For ix1 := 1 to len(aCols)
	
	If aCols[ix1,len(aHeader)+1]
		loop
	EndIf
	Do Case
		Case oFolder:nOption == 1
			
			If aCols[ix1,FG_POSVAR("VO8_CODFER")] == M->VO8_CODFER
				
				nReg ++
				If nReg > 1
					Help("  ",1,"EXISTCHAV")
					Return( .f. )
				EndIf
			Else
				Loop
			EndIf
			
		Case oFolder:nOption == 2
			
			If aCols[ix1,FG_POSVAR("VO8_SEQUEN")] == M->VO8_SEQUEN
				nReg ++
				If nReg > 1
					Help("  ",1,"EXISTCHAV")
					Return( .f. )
				EndIf
			Else
				Loop
			EndIf
			
		Case oFolder:nOption == 3
			
			If Empty(aCols[ix1,FG_POSVAR("VO8_GRUITE")]) .and. Empty(aCols[ix1,FG_POSVAR("VO8_CODITE")])
				Loop
			EndIf
			if Valtype(aCols[ix1,FG_POSVAR("VO8_QTDITE")]) == "C"
				aCols[ix1,FG_POSVAR("VO8_QTDITE")] := Val(aCols[ix1,FG_POSVAR("VO8_QTDITE")])
			endif
			If aCols[ix1,FG_POSVAR("VO8_QTDITE")] < 1
				Help("  ",1,"A140SEMQTD")
				Return( .f. )
			EndIf
			
			If aCols[ix1,FG_POSVAR("VO8_GRUITE")]+aCols[ix1,FG_POSVAR("VO8_CODITE")] == M->VO8_GRUITE+M->VO8_CODITE
				nReg ++
				If nReg > 1
					Help("  ",1,"EXISTCHAV")
					Return( .f. )
				EndIf
			Else
				Loop
			EndIf
			
	EndCase
	
Next

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VP140G ºAutor  ³Fabio               º Data ³  08/19/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla Pastas                                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VP140G(nOpc)

Local nRegFer := 0
Local nRegSrv := 0
Local nRegPec := 0
Local ix1     := 0

FG_MEMVAR()

If nOpc == 5
	Return .t.
EndIf

For ix1 := 1 to len(aColsFer)
	If aColsFer[ix1,len(aHeaderFer)+1]
		loop
	EndIf
	If aColsFer[ix1,FG_POSVAR("VO8_CODFER","aHeaderFer")] == M->VO8_CODFER
		nRegFer ++
		If nRegFer > 1
			Help("  ",1,"EXISTCHAV")
			Return( .f. )
		EndIf
	Else
		Loop
	EndIf
Next

For ix1 := 1 to len(aColsSrv)
	If aColsSrv[ix1,len(aHeaderSrv)+1]
		loop
	EndIf
	If aColsSrv[ix1,FG_POSVAR("VO8_SEQUEN","aHeaderSrv")] == M->VO8_SEQUEN
		nRegSrv ++
		If nRegSrv > 1
			Help("  ",1,"EXISTCHAV")
			Return( .f. )
		EndIf
	Else
		Loop
	EndIf
Next

For ix1 := 1 to len(aColsPec)
	If aColsPec[ix1,len(aHeaderPec)+1]
		loop
	EndIf
	If Empty(aColsPec[ix1,FG_POSVAR("VO8_GRUITE","aHeaderPec")]) .and. Empty(aColsPec[ix1,FG_POSVAR("VO8_CODITE","aHeaderPec")])
		Loop
	EndIf
	If aColsPec[ix1,FG_POSVAR("VO8_QTDITE","aHeaderPec")] < 1
		Help("  ",1,"A140SEMQTD")
		Return( .f. )
	EndIf
	
	If aColsPec[ix1,FG_POSVAR("VO8_GRUITE","aHeaderPec")]+aColsPec[ix1,FG_POSVAR("VO8_CODITE","aHeaderPec")] == M->VO8_GRUITE+M->VO8_CODITE
		nRegPec ++
		If nRegPec > 1
			Help("  ",1,"EXISTCHAV")
			Return( .f. )
		EndIf
	Else
		Loop
	EndIf
Next

Return( .t. )

Function OFIOA140R() // Replicar o cadastro de Revisoes
Local lOk := .f.
Local ni  := 0
Local nj  := 0
Local cCodMar := M->VO6_CODMAR := VO6->VO6_CODMAR
Local cCodMod := VO6->VO6_MODVEI
Local cCodSeg := VO6->VO6_SEGMOD
Local cDesMar := Posicione("VE1",1,xFilial("VE1")+cCodMar,"VE1_DESMAR")
Local cDesMod := Posicione("VV2",1,xFilial("VV2")+cCodMar+cCodMod+cCodSeg,"VV2_DESMOD")
Local cDesSeg := Posicione("VVX",1,xFilial("VVX")+cCodMar+cCodSeg,"VVX_DESSEG")
Local cGruSer := VO6->VO6_GRUSER
Local cCodSer := VO6->VO6_CODSER
Local cDesSer := VO6->VO6_DESSER
Local cDesAbr := VO6->VO6_DESABR
Local nQtdMec := VO6->VO6_QTDMEC
Local cSerAti := VO6->VO6_SERATI
Local nValHor := VO6->VO6_VALHOR
Local	nTemFab := VO6->VO6_TEMFAB
Local	nTemCon := VO6->VO6_TEMCON
Local	cAgrSer := VO6->VO6_AGRSER
Local	cAutori := VO6->VO6_AUTORI
Local	cContro := VO6->VO6_CONTRO
Local	cAplica := VO6->VO6_APLICA
Local	cModEng := VO6->VO6_MODENG
Local	cDetEng := VO6->VO6_DETENG
Local	nTemAnt := VO6->VO6_TEMANT
Local	cSrvAdi := VO6->VO6_SRVADI
Local aVO8    := {}
Local cQAlVO6 := "SQLVO6"
Local cQuery  := ""
Local cQuAux  := ""
Local OXverde
Local OXvermelho
Local OXazull
Private overde   := LoadBitmap( GetResources(), "BR_verde")
Private overmelho:= LoadBitmap( GetResources(), "BR_vermelho")
Private oazull   := LoadBitmap( GetResources(), "BR_azul")
Private aModelo  := {}
Private lMarcar  := .f.
If VO6->VO6_AGRSER <> "S"
	MsgAlert(STR0016,STR0015)
	DbSelectArea("VO6")
	DbSetOrder(1)
	Return .t.
EndIf
DbSelectArea("VO8")
DbSetOrder(1)
DbSeek( xFilial("VO8") + If(!Empty(cCodMar),cCodMar,"   ") + cCodMod + cCodSeg + cCodSer )
While !Eof() .and. xFilial("VO8")==VO8->VO8_FILIAL .and. ( VO8->VO8_CODMAR + VO8->VO8_MODVEI + VO8->VO8_SEGMOD + VO8->VO8_CODSER ) == ( If(!Empty(cCodMar),cCodMar,"   ") + cCodMod + cCodSeg + cCodSer )
	Aadd(aVO8,{VO8->VO8_CODFER,VO8->VO8_SEQUEN,VO8->VO8_CODSRV,VO8->VO8_GRUITE,VO8->VO8_CODITE,VO8->VO8_QTDITE,VO8->VO8_TIPAGR})
	DbSkip()
EndDo
cQuAux := "SELECT COUNT(VO6.VO6_CODSER) QTD FROM "+RetSqlName("VO6")+" VO6 WHERE VO6.VO6_FILIAL='"+xFilial("VO6")+"' AND VO6.VO6_AGRSER='S' AND VO6.VO6_CODSER='"+cCodSer+"' AND "
If !Empty(cCodMar)
	cQuAux += "VO6.VO6_CODMAR='"+cCodMar+"' AND "
Else
	cQuAux += "VO6.VO6_CODMAR='   ' AND "
EndIf
DbSelectArea("VV2")
DbSetOrder(1)
DbSeek( xFilial("VV2") + If(!Empty(cCodMar),cCodMar,"") )
While !Eof() .and. xFilial("VV2")==VV2->VV2_FILIAL .and. If(!Empty(cCodMar),VV2->VV2_CODMAR==cCodMar,.t.)
	cQuery := cQuAux
	cQuery += "VO6.VO6_MODVEI='"+VV2->VV2_MODVEI+"' AND VO6.VO6_SEGMOD='"+VV2->VV2_SEGMOD+"' AND VO6.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO6 , .F. , .T. )
	If !( cQAlVO6 )->( Eof() )
		cCor := If(( cQAlVO6 )->( QTD )>0,"azul","verm")
	Else
		cCor := "verm"
	EndIf
	( cQAlVO6 )->( dbCloseArea() )
	DbSelectArea("VV2")
	Aadd(aModelo,{cCor,VV2->VV2_CODMAR,VV2->VV2_MODVEI,VV2->VV2_DESMOD,VV2->VV2_SEGMOD,Posicione("VVX",1,xFilial("VVX")+VV2->VV2_CODMAR+VV2->VV2_SEGMOD,"VVX_DESSEG")})
	DbSkip()
EndDo
If len(aModelo) <= 0
	Aadd(aModelo,{"azul","","","","",""})
EndIf
DEFINE MSDIALOG oReplServ FROM 000,000 TO 030,063 TITLE (STR0001+" - "+STR0013) OF oMainWnd
@ 008,005 SAY (STR0017+":") SIZE 65,10 OF oReplServ PIXEL COLOR CLR_BLUE
@ 008,035 MSGET oCodMar VAR cCodMar PICTURE "@!" SIZE 30,08 OF oReplServ PIXEL COLOR CLR_BLUE WHEN .f.
@ 008,065 MSGET oDesMar VAR cDesMar PICTURE "@!" SIZE 180,08 OF oReplServ PIXEL COLOR CLR_BLUE WHEN .f.
@ 018,005 SAY (STR0018+":") SIZE 65,10 OF oReplServ PIXEL COLOR CLR_BLUE
@ 018,035 MSGET oCodMod VAR cCodMod PICTURE "@!" SIZE 75,08 OF oReplServ PIXEL COLOR CLR_BLUE WHEN .f.
@ 018,110 MSGET oDesMod VAR cDesMod PICTURE "@!" SIZE 135,08 OF oReplServ PIXEL COLOR CLR_BLUE WHEN .f.
@ 028,005 SAY (STR0019+":") SIZE 65,10 OF oReplServ PIXEL COLOR CLR_BLUE
@ 028,035 MSGET oCodSeg VAR cCodSeg PICTURE "@!" SIZE 75,08 OF oReplServ PIXEL COLOR CLR_BLUE WHEN .f.
@ 028,110 MSGET oDesSeg VAR cDesSeg PICTURE "@!" SIZE 135,08 OF oReplServ PIXEL COLOR CLR_BLUE WHEN .f.
@ 038,005 SAY (STR0020+":") SIZE 65,10 OF oReplServ PIXEL COLOR CLR_BLUE
@ 038,035 MSGET oGruSer VAR cGruSer PICTURE "@!" SIZE 20,08 OF oReplServ PIXEL COLOR CLR_BLUE WHEN .f.
@ 038,055 MSGET oCodSer VAR cCodSer PICTURE "@!" SIZE 90,08 OF oReplServ PIXEL COLOR CLR_BLUE WHEN .f.
@ 038,145 MSGET oDesSer VAR cDesSer PICTURE "@!" SIZE 100,08 OF oReplServ PIXEL COLOR CLR_BLUE WHEN .f.
@ 001,002 TO 050,247 LABEL (" "+STR0022+" ") OF oReplServ PIXEL
@ 051,002 TO 210,247 LABEL (" "+STR0023+" ") OF oReplServ PIXEL
@ 058,003 LISTBOX oLxRepl FIELDS HEADER "",STR0017,STR0018,STR0021,STR0019,STR0021 COLSIZES 10,20,50,75,30,50 SIZE 243,151 OF oReplServ PIXEL ON DBLCLICK FS_SELECT("1")
oLxRepl:SetArray(aModelo)
oLxRepl:bLine := { || {	 If(aModelo[oLxRepl:nAt,1]=="verd",overde,If(aModelo[oLxRepl:nAt,1]=="verm",overmelho,oazull)) , aModelo[oLxRepl:nAt,2] , aModelo[oLxRepl:nAt,3] ,	aModelo[oLxRepl:nAt,4] , aModelo[oLxRepl:nAt,5] , aModelo[oLxRepl:nAt,6] }}
@ 058,004 CHECKBOX oSelTodos VAR lMarcar PROMPT " " OF oReplServ ON CLICK If( FS_SELECT("T") , .t. , ( lMarcar:=!lMarcar , oSelTodos:Refresh() ) ) SIZE 10,08 PIXEL COLOR CLR_BLUE
@ 215,005 BITMAP OXverde RESOURCE "BR_verde" OF oReplServ PIXEL NOBORDER SIZE 10,10 when .f.
@ 215,013 SAY STR0024 SIZE 80,10 OF oReplServ PIXEL COLOR CLR_BLUE
@ 215,054 BITMAP OXvermelho RESOURCE "BR_vermelho" OF oReplServ PIXEL NOBORDER SIZE 10,10 when .f.
@ 215,062 SAY STR0025 SIZE 80,10 OF oReplServ PIXEL COLOR CLR_BLUE
@ 215,113 BITMAP OXazull RESOURCE "BR_azul" OF oReplServ PIXEL NOBORDER SIZE 10,10 when .f.
@ 215,121 SAY STR0026 SIZE 80,10 OF oReplServ PIXEL COLOR CLR_BLUE
@ 214,162 BUTTON oReplicar PROMPT OemToAnsi(STR0013) OF oReplServ SIZE 40,10 PIXEL ACTION ( lOk := .t. , oReplServ:End() ) // Replicar
@ 214,206 BUTTON oSAIR PROMPT OemToAnsi(STR0027) OF oReplServ SIZE 40,10 PIXEL ACTION ( oReplServ:End() ) // Sair
ACTIVATE MSDIALOG oReplServ CENTER
If lOk
	lOk := .f.
	For ni := 1 to Len(aModelo)
		If aModelo[ni,1] == "verd"
			lOk := .t.
			DbSelectArea("VO6")
			RecLock("VO6",.t.)
			VO6->VO6_FILIAL := xFilial("VO6")
			VO6->VO6_SERINT := CriaVar("VO6_SERINT")
			VO6->VO6_CODMAR := aModelo[ni,2]
			VO6->VO6_MODVEI := aModelo[ni,3]
			VO6->VO6_SEGMOD := aModelo[ni,5]
			VO6->VO6_GRUSER := cGruSer
			VO6->VO6_CODSER := cCodSer
			VO6->VO6_DESSER := cDesSer
			VO6->VO6_DESABR := cDesAbr
			VO6->VO6_QTDMEC := nQtdMec
			VO6->VO6_SERATI := cSerAti
			VO6->VO6_VALHOR := nValHor
			VO6->VO6_TEMFAB := nTemFab
			VO6->VO6_TEMCON := nTemCon
			VO6->VO6_AGRSER := cAgrSer
			VO6->VO6_AUTORI := cAutori
			VO6->VO6_CONTRO := cContro
			VO6->VO6_APLICA := cAplica
			VO6->VO6_MODENG := cModEng
			VO6->VO6_DETENG := cDetEng
			VO6->VO6_TEMANT := nTemAnt
			VO6->VO6_SRVADI := cSrvAdi
			ConfirmSx8("VO6")
			MsUnLock()
			For nj := 1 to len(aVO8)
				DbSelectArea("VO8")
				RecLock("VO8",.t.)
				VO8->VO8_FILIAL := xFilial("VO8")
				VO8->VO8_CODMAR := aModelo[ni,2]
				VO8->VO8_MODVEI := aModelo[ni,3]
				VO8->VO8_SEGMOD := aModelo[ni,5]
				VO8->VO8_CODSER := cCodSer
				VO8->VO8_CODFER := aVO8[nj,1]
				VO8->VO8_SEQUEN := aVO8[nj,2]
				VO8->VO8_CODSRV := aVO8[nj,3]
				VO8->VO8_GRUITE := aVO8[nj,4]
				VO8->VO8_CODITE := aVO8[nj,5]
				VO8->VO8_QTDITE := aVO8[nj,6]
				VO8->VO8_TIPAGR := aVO8[nj,7]
				MsUnLock()
			Next
		EndIf
	Next
	If lOk
		MsgAlert(STR0028,STR0015)
	Else
		MsgStop(STR0029,STR0015)
	EndIf
EndIf
DbSelectArea("VO6")
DbSetOrder(1)
Return()

Static Function FS_SELECT(cTipo) // Selecionando Modelos para Replicar o cadastro de Revisoes
Local ni := 0
If cTipo == "1"
	If aModelo[oLxRepl:nAt,1] <> "azul"
		If aModelo[oLxRepl:nAt,1] == "verm"
			aModelo[oLxRepl:nAt,1] := "verd"
		Else
			aModelo[oLxRepl:nAt,1] := "verm"
		EndIf
	Else
		MsgAlert(STR0030,STR0015)
	EndIf
Else // cTipo == "T"
	For ni := 1 to len(aModelo)
		If aModelo[ni,1] <> "azul"
			If lMarcar
				aModelo[ni,1] := "verd"
			Else
				aModelo[ni,1] := "verm"
			EndIf
		EndIf
	Next
	oLxRepl:Refresh()
EndIf
Return(.t.)

Function OFIOA140S()
If Empty(aCols[n,1]).and.Empty(aColsSrv[n,1])
	aCols[n,1] := aColsSrv[n,1] := M->VO8_SEQUEN := "01"
EndIf
Return(.t.)

Function OFIOA140T(cTip)
Local nRet := 0
If FG_SEEK("VO7","FG_MARSRV(M->VO6_CODMAR,VO8->VO8_CODSRV)+VO8->VO8_CODSRV+M->VO6_MODVEI+M->VO6_SEGMOD",1,.f.)
	If cTip == "FAB"
		nRet := M->VO8_TEMFAB := VO7->VO7_TEMFAB
	Else //If cTip == "CON"
		nRet := M->VO8_TEMCON := VO7->VO7_TEMCON
	EndIf
ElseIf FG_SEEK("VO6","FG_MARSRV(M->VO6_CODMAR,VO8->VO8_CODSRV)+VO8->VO8_CODSRV",2,.f.,"VO8_DESSRV","VO6_DESSER")
	If cTip == "FAB"
		nRet := M->VO8_TEMFAB := VO6->VO6_TEMFAB
	Else //If cTip == "CON"
		nRet := M->VO8_TEMCON := VO6->VO6_TEMCON
	EndIf
EndIf
Return(nRet)

Static Function MenuDef()
Local aRotina := { { STR0002 ,"axPesqui"	, 0 , 1},;  //Pesquisar
{ STR0003 ,"Ap140"	, 0 , 2},;	//Visualizar
{ STR0004 ,"Ap140"	, 0 , 3},;	//Incluir
{ STR0005 ,"Ap140"	, 0 , 4},;	//Alterar
{ STR0006 ,"Ap140"	, 0 , 5},; 	//Excluir
{ STR0013 ,"OFIOA140R",0 , 2},; 	//Replicar
{ STR0014 ,"OA030LEG",0,2,0,.f.}} //Legenda
Return aRotina
