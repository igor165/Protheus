// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 25     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "OFIGM000.ch"
#Include "Protheus.ch"
#Include "Fileio.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIGM000 ³ Autor ³  Renata               ³ Data ³ 24/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao na Garantia Solicitada VW                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MODELO 3                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GARANTIA                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes³ Boby 24/10/10 - Alterado MSGETDADOS por MSNEWGETDADOS      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function OFIGM000(cCodMar,cNumOsv,nOpc)
Private cIndVO6, cChave, cCond
Private cTipLib := "1"

Private aRotina := { { STR0002 ,"axPesqui", 0 , 1},;    // Pesquisar
{ STR0003 ,"GM000"   , 0 , 2},;   // VIZUALIZAR
{ STR0031 ,"GM000"   , 0 , 3},;   // INCLUIR
{ STR0004 ,"GM000"   , 0 , 4},;   // ALTERAR
{ STR0007 ,"GM000P"  , 0 , 2}}    // Imp. Pc Acao Of.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0001)   //"Garantia Solicitada VW"
Private nIndex:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

FS_OKilGar() // Alterar campo VGA_KILGAR para obrigatorio. - FNC 25422 - Antonio

DbSelectArea("VGA")
DbSetOrder(1)

cIndex := CriaTrab(nil,.f.)
cChave  := IndexKey()  //"VGA_FILIAL+VGA_CODMAR+VGA_NUMOSV+VGA_ESPGAR"
cCond   := 'VGA_EXPGAR=="S".and.VGA_IMPOSV="S".AND.VGA_ESPGAR="S"'
IndRegua("VGA",cIndex,cChave,,cCond,STR0006)

DbSelectArea("VGA")
nIndex := RetIndex("VGA")+1
#IFNDEF TOP
	DbSetIndex(cIndex+ordBagExt())
#ENDIF
DbSetOrder(nIndex)

If cCodMar # NIL .And. cNumOsv # NIL
	
	DbSelectArea("VGA")
	DbSetOrder(1)
	DbSeek( xFilial("VGA") + cCodMar + cNumOsv )
	
	GM000("VGA",RecNo(),nOpc)
	
Else
	
	mBrowse( 6, 1,22,75,"VGA",,,,"VGA_TRANSM == 'N'")
	
EndIf

DbSelectArea("VGA")
RetIndex("VGA")
DbSetOrder(1)
#IFNDEF TOP
	If File(cIndex+OrdBagExt())
		fErase(cIndex+OrdBagExt())
	Endif
#ENDIF

return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GM000     ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Altera e visualiza dados no VGA/VG5 modelo 3                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM000(cAlias,nReg,nOpc)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GM000(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
////////////////////////////////////////////////////////////////////////////////////////////

Local bCampo  := { |nCPO| Field(nCPO) }
Local nCntFor := 0 , nUsado := 0 , _ni := 0 , nFlag := 0 , oDlg

Private cCpoAPeca      := "VG5_GRUITE/VG5_CODITE/VG5_DESITE/VG5_PECINT/VG5_QTDITE/VG5_VALPEC"
Private cCpoASrv       := "VG5_CODSER/VG5_DESSER/VG5_SERINT/VG5_TEMPAD"
Private aColsNormal    := {} , aHeaderNormal    := {}
Private aColsAdicional := {} , aHeaderAdicional := {} , aCpoEnchoice := {}
Private aCols          := {} , aHeader          := {}
Private aTELA[0][0],aGETS[0]
Private cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Private oEnchoice
Private aAlterN:= {}
Private aAlterA:= {}
Private aControleG  := {}

DbSelectArea("VGA")
If nOpc # 3 .and. !&(cCond)
	DbSetOrder(nIndex)
	Return
EndIf

DbSetOrder(nIndex)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RegToMemory("VGA",IIF(nopc==3,.t.,.f.))
//RegToMemory("VGA",.t.)         // .t. para carregar campos virtuais

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VGA")

While !Eof().and.(x3_arquivo=="VGA")
	
	If X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(x3_campo $ [VGA_ESPGAR/VGA_CODREV/VGA_GRUREV/VGA_DNRESP/VGA_IMPOSV/VGA_NUMNFI/VGA_SERIEN/VGA_TRANSM/VGA_ARQFAB/VGA_SITOSV/VGA_TRANSM/VGA_NUMNFI/VGA_SERIEN/VGA_EXPGAR])
		AADD(aCpoEnchoice,x3_campo)
	Endif
	
	&( "M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)
	
	DbSkip()
	
End

If nOpc # 3
	
	DbSelectArea("VGA")
	
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
	
Endif

If (M->VGA_ESPGAR = 'R' .or. M->VGA_IMPOSV = 'N')
	Help(" ",1,"OFIGM00001")
	return
Endif

If nOpc  == 3       //INCLUIR
	nOpcE := 3
	nOpcG := 3
Elseif nOpc == 4   //ALTERAR
	nOpcE := 4
	nOpcG := 4
Elseif nOpc == 2   //VIZUALIZAR
	nOpcE := 2
	nOpcG := 2
Else
	nOpcE := 5      //EXCLUIR
	nOpcG := 5
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("SX3")
DbSeek("VG5")

While !Eof().And.(x3_arquivo=="VG5")
	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VG5_NUMOSV/VG5_CODMAR/VG5_DESMAR/VG5_DESGRU/VG5_TRANSM/VG5_NUMNFI/VG5_SERIEN/VG5_ITEEXT/VG5_SEREXT])
		
		IF SX3->X3_VISUAL <> "V"
			Aadd(aAlterN,SX3->X3_CAMPO)
			Aadd(aAlterA,SX3->X3_CAMPO)
		ENDIF
		
	Endif
	
	DbSkip()
	
End

nUsado:=0

DbSelectArea("SX3")
DbSeek("VG5")

aHeaderNormal    :={}
aHeaderAdicional :={}

While !Eof().And.(x3_arquivo=="VG5")
	
	If X3USO(X3_USADO).And.cNivel>=x3_nivel  .And.!(Alltrim(x3_campo) $ [VG5_NUMOSV/VG5_CODMAR/VG5_DESMAR/VG5_DESGRU/VG5_TRANSM/VG5_NUMNFI/VG5_SERIEN/VG5_ITEEXT/VG5_SEREXT])
		
		nUsado:=nUsado+1
		
		Aadd(aHeaderNormal   ,{ TRIM(X3Titulo()), SX3->X3_CAMPO  , SX3->X3_PICTURE, SX3->X3_TAMANHO, ;
		SX3->X3_DECIMAL, SX3->X3_VALID  , SX3->X3_USADO  , ;
		SX3->X3_TIPO   , SX3->X3_F3     , SX3->X3_CONTEXT, ;
		X3CBOX()       , SX3->X3_RELACAO } )
		
		Aadd(aHeaderAdicional,{ TRIM(X3Titulo()), SX3->X3_CAMPO  , SX3->X3_PICTURE, SX3->X3_TAMANHO, ;
		SX3->X3_DECIMAL, SX3->X3_VALID  , SX3->X3_USADO  , ;
		SX3->X3_TIPO   , SX3->X3_F3     , SX3->X3_CONTEXT, ;
		X3CBOX()       , SX3->X3_RELACAO } )
		
		&( "M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)
		
	Endif
	
	DbSkip()
	
End

//(aColsNormal)
If nOpc == 3
	aColsNormal:={Array(nUsado+1)}
	aColsNormal[1,nUsado+1] := .F.
	For _ni:=1 to nUsado
		aColsNormal[1,_ni] := CriaVar(aHeaderNormal[_ni,2])
	Next
EndIf

//(aColsAdicional)
If nOpc == 3
	aColsAdicional:={Array(nUsado+1)}
	aColsAdicional[1,nUsado+1] := .F.
	For _ni:=1 to nUsado
		aColsAdicional[1,_ni] := CriaVar(aHeaderAdicional[_ni,2])
	Next
EndIf


Aadd(aControleG,{})  && GetDados Normal
Aadd(aControleG,{})  && GetDados Adicional

If nOpc # 3
	
	aColsNormal   :={}
	aColsAdicional:={}
	
	DbSelectArea("VG5")
	DbSetOrder(3)
	DbSeek(xFilial()+M->VGA_CODMAR+M->VGA_NUMOSV)
	
	While !Eof() .And. VG5->VG5_CODMAR+VG5->VG5_NUMOSV == M->VGA_CODMAR+M->VGA_NUMOSV .And. VG5->VG5_FILIAL == xFilial("VG5")
		
		&& Pecas e servicoS normal
		If VG5->VG5_ITEEXT == "0" .Or. VG5->VG5_SEREXT == "0"
			AADD(aColsNormal,Array(nUsado+1))
			For _ni:=1 to nUsado
				aColsNormal[Len(aColsNormal),_ni] := If( aHeaderNormal[_ni,10] == "V" , Criavar(aHeaderNormal[_ni,2]), FieldGet(FieldPos(aHeaderNormal[_ni,2])))
			Next
			
			aColsNormal[Len(aColsNormal),nUsado+1]:=.F.
			
			&& Controle de registro para gravacao
			Aadd(aControleG[1], RecNo() )
			
		EndIf
		
		&& Pecas E  Servicos adicionais
		If VG5->VG5_ITEEXT == "1" .Or. VG5->VG5_SEREXT == "1"
			AADD(aColsAdicional,Array(nUsado+1))
			For _ni:=1 to nUsado
				aColsAdicional[Len(aColsAdicional),_ni]:= If( aHeaderAdicional[_ni,10] == "V" , Criavar( aHeaderAdicional[_ni,2]), FieldGet(FieldPos(aHeaderAdicional[_ni,2])))
			Next
			
			aColsAdicional[Len(aColsAdicional),nUsado+1]:=.F.
			
			&& Controle de registro para gravacao
			Aadd(aControleG[2], RecNo() )
			
		EndIf
		
		DbSkip()
		
	EndDo
	
Endif

If nOpc # 3
	
	DbSelectArea("VGA")
	DbSetOrder(1)
	DbSeek( xFilial("VGA") + M->VGA_CODMAR + M->VGA_NUMOSV )
	
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a Modelo 3                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo          :=STR0001    //"Garantia Solicitada"
cAliasEnchoice   :="VGA"
cAliasGetD       :="VG5"
cLinOk           :="FG_OBRIGAT()"
cTudOk           :="FS_TudOk()"
cFieldOkNormal   :="FS_CODINT(1)"
cFieldOkAdicional:="FS_CODINT(2),FS_LIMPACPO()"
cLinOkAdicional  :="AllwaysTrue()"

nOpca := 0

Private aNewBot := {} //"Impressao das Etiquetas"
If ExistBlock("M_RETQVW")
	AADD(aNewBot, {"IMPRESSAO",{ || ExecBlock("M_RETQVW",.f.,.f.) },( STR0034 )} ) //"Impressao das Etiquetas"
EndIf

DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

aObjects := {}
AAdd( aObjects, { 1, 10, .T. , .T. } )  //GetDados Normal
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

oFoldGM000 := TFolder():New(aPosObj[1,1], aPosObj[1,2], {STR0008,STR0009}, {STR0008,STR0009}, oDlg, , , , .t. , , aPosObj[1,4], aPosObj[1,3]-aPosObj[1,1] )
oFoldGM000:Align := CONTROL_ALIGN_ALLCLIENT

// Aba de GARANTIA - ENCHOICE
//         1       2     3   4 5 6       7                                          8                            9                         10  11 12    13     14                   15   16  17  18  19  20
oEnChoice:=MsMGet():New(cAliasEnchoice,nReg,nOpcE, , , ,aCpoEnchoice,{01,1,aPosObj[1,3]-aPosObj[1,1]-14,aPosObj[1,4]-2}, IIf(nOpcE==2,{}, )/*aCpoEnchoice*/ ,3 ,  ,  ,      ,oFoldGM000:aDialogs[1],.F.,.T.,.F.,"",.F.,.F.)

// Aba de ITENS - GETDADOS
aObjects := {}
AAdd( aObjects, { 1, 10, .T. , .T. } )  //GetDados Normal
AAdd( aObjects, { 1, 10, .T. , .T. } )  //GetDados Adicional
aPosObj := MsObjSize( { 01 , 01 , aPosObj[1,4] , aPosObj[1,3] - 20 , 2, 2 } , aObjects , .F.)

&& Normais                                  1               2             3               4                            5                               6       7             8               9     10  11      12        13 14           15                 16           17
oGetNormal   := MsNewGetDados():New((aPosObj[1,1]),(aPosObj[1,2]),(aPosObj[1,3]),(aPosObj[1,4]),IIf(nOpcG==2,0,GD_INSERT+GD_UPDATE+GD_DELETE) ,cLinOk ,cTudOk , /*"VG5_ORDITE"*/ , aAlterN  ,000,999,cFieldOkNormal,  ,  ,oFoldGM000:aDialogs[2],aHeaderNormal,aColsNormal)
oGetNormal:oBrowse:bChange := {|| FG_MEMVAR(oGetNormal:aHeader,oGetNormal:aCols,oGetNormal:nAt) }

&& Adicionais
@ aPosObj[2,1],aPosObj[2,2] TO aPosObj[2,3],aPosObj[2,4] LABEL STR0011 OF oFoldGM000:aDialogs[2] PIXEL
&&                                         1                     2                 3            4                           5                                        6         7    8      9      10   11      12           13   14             15                  16               17
oGetAdicional:= MsNewGetDados():New((aPosObj[2,1]+08),(aPosObj[2,2]+2),(aPosObj[2,3]-2),(aPosObj[2,4]-2),IIf(nOpcG==2,0,GD_INSERT+GD_UPDATE+GD_DELETE),cLinOkAdicional,cTudOk,  , aAlterA  ,000,999,cFieldOkAdicional,  ,      ,oFoldGM000:aDialogs[2],aHeaderAdicional,aColsAdicional)
oGetAdicional:oBrowse:bChange := {|| FG_MEMVAR(oGetAdicional:aHeader,oGetAdicional:aCols,oGetAdicional:nAt) }

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If( oGetNormal:TudoOk() .And. oGetAdicional:TudoOk() .And. obrigatorio(aGets,aTela) .And. OFIGM000Chv() .And. FS_GRAMS( nOpc ),(nOpca := 1,oDlg:End()),.f.) },{|| nOpca := 2, oDlg:End() },,aNewBot )

DbSelectArea("VGA")
DbSetOrder(nIndex)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GRAMS  ºAutor  ³Renata              º Data ³  08/16/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Garantia                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAMS( nOpc )

Local i := 0 , lAdd := .t.
Local nFlag
PRIVATE aMemos  := {{"VGA_OBSMEM","VGA_OBSERV"}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Ponto de Entrada para verificações de TudoOK depois de clicar o botão "Ok" da EnchoiceBar
// Permite abortar a operação caso retorne "falso"
If ExistBlock("OG000TOK")
	If !ExecBlock("OG000TOK",.f.,.f.)
		return .f.
	Endif
Endif

If nOpc # 2
	
	Begin Transaction
	
	DbSelectArea("VGA")
	DbSetOrder(1)
	DbSeek(xFilial("VGA")+M->VGA_CODMAR+M->VGA_NUMOSV)
	
	RecLock("VGA", !Found() )
	FG_GRAVAR("VGA")
	VGA->VGA_FILIAL := xFilial("VGA")
	VGA->VGA_CODMAR := M->VGA_CODMAR
	VGA->VGA_NUMOSV := M->VGA_NUMOSV
	VGA->VGA_ESPGAR := M->VGA_ESPGAR
	VGA->VGA_TRANSM := "N"
	
	IF nOpc == 3
		VGA->VGA_ESPGAR := "S"
		VGA->VGA_IMPOSV := "S"
		VGA->VGA_EXPGAR := "S"
	ENDIF
	
	MSMM(,TamSx3("VGA_OBSERV")[1],,&(aMemos[1][2]),1,,,"VGA","VGA_OBSMEM")
	MsUnlock()
	
	&& Normal
	DbSelectArea("VG5")
	
	For i:=1 to len(oGetNormal:aCols)
		
		lAdd := .f.
		If i > Len(aControleG[1])
			lAdd := .t.
		Else
			DbGoTo( aControleG[1,i] )
		EndIf
		
		//		lAdd := .T.
		//		DbSelectArea("VG5")
		//		DbSetOrder(3)
		//		DbSeek(xFilial("VG5")+M->VGA_CODMAR+M->VGA_NUMOSV+(oGetNormal:aCols[i,FG_POSVAR("VG5_ORDITE","oGetNormal:aHeader")]) )
		//		While !Eof() .and. xFilial("VG5") == VG5->VG5_FILIAL
		//			If (VG5->VG5_ITEEXT == "0" .OR. VG5->VG5_SEREXT == "0")
		//				lAdd := .F.
		//				Exit
		//			EndIf
		//			dbSkip()
		//		End
		//		If nOpc # 5 .And. !oGetNormal:aCols[i,  len(oGetNormal:aCols[i])] //.And. !Empty(oGetNormal:aCols[i,FG_POSVAR("VG5_ORDITE","oGetNormal:aHeader")])
		
		If ( nOpc == 3 .Or. nOpc == 4 ) .And. !oGetNormal:aCols[i,len(oGetNormal:aCols[i])]
			
			If Empty(oGetNormal:aCols[i,FG_POSVAR("VG5_ORDITE","oGetNormal:aHeader")])
				Loop
			EndIf
			
			RecLock("VG5", lAdd)
			FG_GRAVAR("VG5",oGetNormal:aCols,oGetNormal:aHeader,i)
			VG5->VG5_FILIAL := xFilial("VG5")
			VG5->VG5_CODMAR := VGA->VGA_CODMAR
			VG5->VG5_NUMOSV := VGA->VGA_NUMOSV
			VG5->VG5_TRANSM := "N"
			
			&& Marca Flag do Item
			VG5->VG5_ITEEXT := ""
			For nFlag:=1 To Len(cCpoAPeca) Step 11
				If !Empty(oGetNormal:aCols[i,FG_POSVAR(Substr(cCpoAPeca,nFlag,10),"oGetNormal:aHeader" )])
					VG5->VG5_ITEEXT := "0"
				EndIf
			Next
			&& Marca Flag do Servico
			VG5->VG5_SEREXT := ""
			For nFlag:=1 To Len(cCpoASrv) Step 11
				If !Empty(oGetNormal:aCols[i,FG_POSVAR(Substr(cCpoASrv,nFlag,10), "oGetNormal:aHeader" )])
					VG5->VG5_SEREXT := "0"
				EndIf
			Next
			MsUnlock()
			
		ElseIf !lAdd
			
			RecLock("VG5",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VG5")
			
		Endif
		
	Next
	
	&& Adicional
	DbSelectArea("VG5")
	
	For i:=1 to len(oGetAdicional:aCols)
		
		//		lAdd := .T.
		//		DbSelectArea("VG5")
		//		DbSetOrder(3)
		//		DbSeek(xFilial("VG5")+M->VGA_CODMAR+M->VGA_NUMOSV+(oGetAdicional:aCols[i,FG_POSVAR("VG5_ORDITE","oGetAdicional:aHeader")]) )
		//		While !Eof() .and. xFilial("VG5") == VG5->VG5_FILIAL
		//			If (VG5->VG5_ITEEXT == "1" .OR. VG5->VG5_SEREXT == "1")
		//				lAdd := .F.
		//				Exit
		//			EndIf
		//			dbSkip()
		//		End
		//		If nOpc # 5 .And. !oGetAdicional:aCols[i,  len(oGetAdicional:aCols[i])] //.And. !Empty(oGetAdicional:aCols[i,FG_POSVAR("VG5_ORDITE","oGetAdicional:aHeader")])
		
		lAdd := .f.
		If i > Len(aControleG[2])
			lAdd := .t.
		Else
			DbGoTo( aControleG[2,i] )
		EndIf
		
		If ( nOpc == 3 .Or. nOpc == 4 ) .And. !oGetAdicional:aCols[i,len(oGetAdicional:aCols[i])]
			
			If Empty(oGetAdicional:aCols[i,FG_POSVAR("VG5_ORDITE", "oGetAdicional:aHeader")])
				Loop
			EndIf
			
			RecLock("VG5", lAdd)
			FG_GRAVAR("VG5",oGetAdicional:aCols,oGetAdicional:aHeader,i)
			VG5->VG5_FILIAL := xFilial("VG5")
			VG5->VG5_CODMAR := VGA->VGA_CODMAR
			VG5->VG5_NUMOSV := VGA->VGA_NUMOSV
			VG5->VG5_TRANSM := "N"
			
			&& Marca Flag do Item
			VG5->VG5_ITEEXT := ""
			For nFlag:=1 To Len(cCpoAPeca) Step 11
				If !Empty(oGetAdicional:aCols[i,FG_POSVAR(Substr(cCpoAPeca,nFlag,10), "oGetAdicional:aHeader")])
					VG5->VG5_ITEEXT := "1"
				EndIf
			Next
			&& Marca Flag do Servico
			VG5->VG5_SEREXT := ""
			For nFlag:=1 To Len(cCpoASrv) Step 11
				If !Empty(oGetAdicional:aCols[i,FG_POSVAR(Substr(cCpoASrv,nFlag,10), "oGetAdicional:aHeader")])
					VG5->VG5_SEREXT := "1"
				EndIf
			Next
			MsUnlock()
			
		ElseIf !lAdd
			
			RecLock("VG5",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VG5")
			
		Endif
		
	Next
	
	End Transaction
	
Endif

Return(.T.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA_ORDGAVW³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica a numeracao das pecas                              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_ORDGAVW(nOrdIte,nNumOsv)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OrdGaVw()
*****************************

Local nOrdem := 0 , nDupl:=0 , nQtdOrd:=0 , lRet:=.T.

&& Normais
For nOrdem := 1 to len(oGetNormal:aCols)
	
	If !oGetNormal:aCols[nOrdem,Len(oGetNormal:aCols[nOrdem])]
		
		nQtdOrd:=0
		For nDupl := 1 to len(oGetNormal:aCols)
			
			If !oGetNormal:aCols[nDupl,Len(oGetNormal:aCols[nDupl])]
				
				nQtdOrd++
				If nDupl#nOrdem .And. oGetNormal:aCols[nDupl,FG_POSVAR("VG5_ORDITE","oGetNormal:aHeader")] == oGetNormal:aCols[nOrdem,FG_POSVAR("VG5_ORDITE","oGetNormal:aHeader")]
					Help(" ",1,"OFIGM00004",, oGetNormal:aHeader[FG_POSVAR("VG5_ORDITE"),1]+" - "+oGetNormal:aCols[nOrdem,FG_POSVAR("VG5_ORDITE","oGetNormal:aHeader")] ,5,1)
					lRet:=.F.
					Return(lRet)
				Endif
				
			EndIf
			
		Next
		
		If Val(oGetNormal:aCols[nOrdem,FG_POSVAR("VG5_ORDITE","oGetNormal:aHeader")]) > nQtdOrd
			Help(" ",1,"OFIGM00003",, oGetNormal:aHeader[FG_POSVAR("VG5_ORDITE"),1]+" - "+oGetNormal:aCols[nOrdem,FG_POSVAR("VG5_ORDITE","oGetNormal:aHeader")] ,5,1)
			lRet:=.F.
			Return(lRet)
		EndIf
		
	EndIf
	
Next

&& Adicionais
For nOrdem := 1 to len(oGetAdicional:aCols)
	
	If !oGetAdicional:aCols[nOrdem,Len(oGetAdicional:aCols[nOrdem])] .And. !Empty( oGetAdicional:aCols[nOrdem,FG_POSVAR("VG5_ORDITE","oGetAdicional:aHeader")] )
		
		If Ascan(oGetNormal:aCols,{|x| x[FG_POSVAR("VG5_ORDITE","oGetNormal:aHeader")] == oGetAdicional:aCols[nOrdem,FG_POSVAR("VG5_ORDITE","oGetAdicional:aHeader")] .And. x[Len(oGetNormal:aCols[1])] == .f. }) == 0
			lRet:=.F.
			Return( MsgYesNo( STR0028 + oGetNormal:aHeader[FG_POSVAR("VG5_ORDITE"),1]+" - "+oGetAdicional:aCols[nOrdem,FG_POSVAR("VG5_ORDITE")]+ STR0029 ,STR0005) )
		EndIf
		
	EndIf
	
Next

Return(lRet)


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_CODINT ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca os codigos internos do item e do servico              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³FS_CODINT()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CodInt(nTpRegistro)
*****************

Local aAuxACols := {} , nOrdem := 0

If readvar() == 'M->VG5_CODITE'
	
	If !Empty(M->VG5_CODITE)
		IF nTpRegistro == 1
			oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG5_PECINT","oGetNormal:aHeader")]:=SB1->B1_COD   //[5]
			oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG5_DESITE","oGetNormal:aHeader")]:=SB1->B1_DESC
		ElseIf nTpRegistro == 2
			oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG5_PECINT","oGetAdicional:aHeader")]:=SB1->B1_COD   //[5]
			oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG5_DESITE","oGetAdicional:aHeader")]:=SB1->B1_DESC
		Endif
	Endif
	
ElseIf readvar() == 'M->VG5_CODDEF'
	
	If !Empty(M->VG5_CODDEF)
		IF nTpRegistro == 1
			oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG5_DESDEF","oGetNormal:aHeader")] := VG0->VG0_DESDEF
		ElseIf nTpRegistro == 2
			oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG5_DESDEF","oGetAdicional:aHeader")] := VG0->VG0_DESDEF
		Endif
	Endif
	
Elseif  readvar() == 'M->VG5_CODSER'
	
	If !Empty(M->VG5_CODSER)
		IF nTpRegistro == 1
			oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG5_SERINT","oGetNormal:aHeader")]:=VO6->VO6_SERINT    //[12]
			oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG5_DESSER","oGetNormal:aHeader")]:=VO6->VO6_DESSER    //[12]
		ElseIf nTpRegistro == 2
			oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG5_SERINT","oGetAdicional:aHeader")]:=VO6->VO6_SERINT    //[12]
			oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG5_DESSER","oGetAdicional:aHeader")]:=VO6->VO6_DESSER    //[12]
		Endif
	Endif
	
ElseIf readvar() == 'M->VG5_ORDITE'
	
	nOrdem := 0
	
	// nTpRegistro = 1-Normal
	IF nTpRegistro == 1 .and. !oGetNormal:aCols[oGetNormal:nAt,Len(oGetNormal:aCols[oGetNormal:nAt])]
		
		nQtdOrd   := 0
		
		For nOrdem := 1 to len(oGetNormal:aCols)
			
			If !oGetNormal:aCols[nOrdem,Len(oGetNormal:aCols[nOrdem])]
				
				nQtdOrd	++
				
				// Se for outra linha da aCols e tiver o mesmo numero de ordem item
				If nOrdem # n .And. oGetNormal:aCols[nOrdem,FG_POSVAR("VG5_ORDITE","oGetNormal:aHeader")] == M->VG5_ORDITE
					Help(" ",1,"OFIGM00004",, oGetNormal:aHeader[FG_POSVAR("VG5_ORDITE","oGetNormal:aHeader"),1]+" - "+oGetNormal:aCols[nOrdem,FG_POSVAR("VG5_ORDITE","oGetNormal:aHeader")] ,5,1)
					Return(.f.)
				Endif
			ENDIF
			
		Next
		
		If Val(M->VG5_ORDITE) > nQtdOrd
			Help(" ",1,"OFIGM00003",, oGetNormal:aHeader[FG_POSVAR("VG5_ORDITE"),1]+" - "+M->VG5_ORDITE ,5,1)
			Return(.f.)
		EndIf
		
		// nTpRegistro = 2-Adicional
	ELSEIF nTpRegistro == 2 .and. !Empty(M->VG5_ORDITE) .and. !oGetAdicional:aCols[oGetAdicional:nAt,Len(oGetAdicional:aCols[oGetAdicional:nAt])]
		
		// Procura na aColsNormal um registro com o mesmo numero de ORDEM
		
		If Ascan(oGetNormal:aCols,{|x| x[FG_POSVAR("VG5_ORDITE","oGetNormal:aHeader")] == M->VG5_ORDITE .And. x[Len(oGetNormal:aCols[1])] == .f. }) == 0
			MsgAlert(STR0028 + oGetAdicional:aHeader[FG_POSVAR("VG5_ORDITE"),1]+" - "+M->VG5_ORDITE,STR0005)
			Return .f.
		EndIf
		
	ENDIF
	
Endif

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_GAROK  ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica os tipos de garantia com as demais informacoes     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_GAROK()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GarOk()
****************

Local lvol := .T.

/*If M->VGA_KILGAR > 0 .and. alltrim(M->VGA_CODGAR) $ "4/5"
Help(" ",1,"OFIGM00005")
lVol := .F.
Elseif Empty(M->VGA_KILGAR) .and. !alltrim(M->VGA_CODGAR) $ "3/4/5"
Help(" ",1,"OFIGM00006")
lVol := .F.
Endif
*/
If VG1->(FieldPos("VG1_KMOBRI")) # 0
	//updofic5
	DbselectArea("VG1")
	DbSetORder(1)
	If DbSeek(xFilial("VG1")+M->VGA_CODMAR+M->VGA_CODGAR)
		If VG1->VG1_KMOBRI=="1"
			If M->VGA_KILGAR <= 0
				Help(" ",1,"OFIGM00006")
				lVol := .f.
			EndIF
		EndIF
	EndIF
EndIF

If Empty(M->VGA_AUTFAB) .and. lvol .and. alltrim(M->VGA_CODGAR) $ "1/A"
	Help(" ",1,"OFIGM00009")
	lVol := .T.
//Elseif !Empty(M->VGA_AUTFAB) .and. lvol .and. !alltrim(M->VGA_CODGAR) $ "0/1/2/3/6/9/A/B/M/C"    //03/07/12-RENATA-SEGUNDO OS GARANTISTA QQ COD PODE TER AUTORIZACAO DE FABRICA
//	Help(" ",1,"OFIGM00010")
//	lVol := .F.
Endif

If Empty(M->VGA_CHAINT) .and. !alltrim(M->VGA_CODGAR) $ "4/5"
	Dbgotop()
	DbSeek(xFilial("VO1")+M->VGA_NUMOSV)
	M->VGA_CHAINT := VO1->VO1_CHAINT
Endif

Return lvol

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_VERGAR ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica a garantia as informacoes da garantia              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_VERGAR()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VerGar()
****************

Local lVolta := .T.

If readvar() == 'M->VGA_KILGAR'
	
	/*	If M->VGA_KILGAR > 0 .and. alltrim(M->VGA_CODGAR) $ "4/5"
	Help(" ",1,"OFIGM00005")
	lVolta := .F.
	Endif
	*/
Elseif readvar() == 'M->VGA_SEGMOD'
	
	DbSelectArea("VVX")
	DbSetOrder(1)
	If DbSeek( xFilial("VVX")+M->VGA_CODMAR+M->VGA_SEGMOD )
		
		If !Empty(M->VGA_SEGMOD) .and. alltrim(M->VGA_CODGAR) $ "4/5"
			Help(" ",1,"OFIGM00007")
			lVolta := .F.
		Endif
		
	Else
		lVolta := .F.
	EndIf
	
Elseif readvar() == 'M->VGA_AUTFAB'
	
	If Empty(M->VGA_AUTFAB) .and. alltrim(M->VGA_CODGAR) $ "1/A"
		Help(" ",1,"OFIGM00009")
		lVolta := .F.
	Endif
	
Endif

Return lVolta

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_TUDOK  ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Da um ok final nos dados informados                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_TUDOK()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TudOk()
***************

Local lret := .t.

If FS_GarOk().And.FS_OrdGaVw()
	lret := .t.
Else
	MsgStop(STR0035) //"Tipos de garantia (Adicionais) inválidos! Verifique!"
	lret := .f.
Endif

/*Help(" ",1,"OFIGM00005") //Kilometragtem com valor para os tipos 3,4,5
Help(" ",1,"OFIGM00006") //kilometragem zerada
Help(" ",1,"OFIGM00007") //modelo com conteudo para os tipos 4 ou 5
Help(" ",1,"OFIGM00008") //modelo sem conteudo
Help(" ",1,"OFIGM00009") //autorizassao de fabrica sem conteudo para os tipos 1 ou A
*/
Return lret

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GM000P    ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os itens da acao de campo cadastrado no VSD           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM000P(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GM000P(cAlias,nReg,nOpc)
**************************

DbSelectArea("VGA")
DbSetOrder(nIndex)

If !Pergunte("OFIG00",.t.)
	Return
Endif

Begin Transaction

FG_SEEK("VSD","MV_PAR03",1,.F.)

DbSelectArea("VSD")

Do While !eof() .and. VSD->VSD_NUMCAM == MV_PAR03 .And. VSD->VSD_FILIAL == xFilial("VSD")
	
	DbSelectArea("VG5")
	DbSetOrder(1)
	DbSeek(xFilial("VG5")+MV_PAR01+STRZERO(VAL(MV_PAR02),8)+VSD->VSD_PECINT)
	
	RecLock("VG5", !Found() )
	VG5->VG5_FILIAL := xFilial("VG5")
	VG5->VG5_CODMAR := MV_PAR01
	VG5->VG5_NUMOSV := STRZERO(VAL(MV_PAR02),8)
	VG5->VG5_GRUITE := VSD->VSD_GRUITE
	VG5->VG5_CODITE := VSD->VSD_CODITE
	VG5->VG5_PECINT := VSD->VSD_PECINT
	VG5->VG5_QTDITE := VSD->VSD_QTDITE
	VG5->VG5_CODDEF := VSD->VSD_CODDEF
	VG5->VG5_CODFOR := VSD->VSD_CODFOR
	VG5->VG5_CODSER := VSD->VSD_CODSER
	VG5->VG5_SERINT := VSD->VSD_SERINT
	VG5->VG5_ITEEXT := "1"
	VG5->VG5_SEREXT := "1"
	VG5->VG5_TRANSM := "N"
	MsUnlock()
	
	DbselectArea("VSD")
	Dbskip()
	
Enddo

End Transaction

//Help(" ",1,"OFIGM00012")
MsgStop(STR0036) //"Peças foram importadas!"

Return

////////////////////////////////

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_VALVG5 ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao no VG5								              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM000P(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALVG5()

local lRet := .t.

if FG_WhenVG5("ITE")
	if inclui
		M->VG5_QTDITE := 0
		lRet := .f.
	Endif
Endif

Return(lRet)

///////////////////////////////

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_TPAD	³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao no tempo padrao						              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM000P(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TPAD()

IIf(oFoldGM000:nOption==2,;
oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG5_TEMPAD","oGetAdicional:aHeader")] := FG_TEMPAD(M->VGA_CHAINT,oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG5_CODSER","oGetAdicional:aHeader")],"1"),;
oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG5_TEMPAD","oGetNormal:aHeader")] := FG_TEMPAD(M->VGA_CHAINT,oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG5_CODSER","oGetNormal:aHeader")],"1");
)

FG_MEMVAR()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_LIMPACPºAutor  ³FAbio               º Data ³  01/29/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Limpa campo adicionais                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_LIMPACPO()

Local nLimpa:=0

For nLimpa:=1 To Len(oGetAdicional:aHeader)
	
	If ( Substr(ReadVar(),4) $ cCpoASrv .And. oGetAdicional:aHeader[nLimpa,2] $ cCpoAPeca ) ;
		.Or. ( Substr(ReadVar(),4) $ cCpoAPeca .And. oGetAdicional:aHeader[nLimpa,2] $ cCpoASrv )
		
		oGetAdicional:aCols[n,nLimpa] := CriaVar(oGetAdicional:aHeader[nLimpa,2],.f.)
		
	EndIf
	
Next

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIGM000Val ºAutor  ³Rubens            º Data ³  21/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a Marca Selecionada                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIGM000Val(cAuxCampo)

IF FG_MARCA("VOLKS",cAuxCampo) .or. FG_MARCA("FORD",cAuxCampo)
	Return .t.
Else
	Return .f.
EndIf

Return .f.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIGM000Chv ºAutor  ³Rubens            º Data ³  21/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida chave da Tabela na Inclusao (Marca + Num OS)         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIGM000Chv()

IF Inclui .and. FunName() == "OFIGM000"
	DbSelectArea("VGA")
	DbSetOrder(1)
	If DbSeek(xFilial("VGA")+M->VGA_CODMAR+M->VGA_NUMOSV)
		MsgStop(STR0033 + CHR(13) + CHR(10) +  CHR(13) + CHR(10) + AllTrim(RetTitle("VGA_CODMAR")) + ": " + M->VGA_CODMAR + CHR(13) + CHR(10) + AllTrim(RetTitle("VGA_NUMOSV")) + ": " + M->VGA_NUMOSV, STR0005)
		Return .f.
	EndIf
Endif

Return .t.


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_OKilGar³ Autor ³ Boby                  ³ Data ³ 22/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizar SX3 do campo VGA_KILGAR para obrigatorio         ³±±
±±³          ³ e campo TES                                                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Siga Veiculos                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function FS_OKilGar()

Local aArea    := GetArea()

SX1->(DbSetOrder(1))                         // Alteracao do parametro de Numerico para caractere - FNC 25422
If SX1->(MsSeek("OFIG00    "+"03"))
	RecLock("SX1",.F.)
	Replace X1_TIPO    With 'C'
	Replace X1_TAMANHO With 6
	MsUnlock()
EndIf

RestArea(aArea)

Return
